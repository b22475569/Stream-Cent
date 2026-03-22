#!/usr/bin/env python3
"""
chrome_history_server.py  —  Stream Hub Chrome 歷史伺服器
監聽 Port 8178，提供 /history 端點給 Stream Hub HTML 使用。
放在與 HTML 相同的資料夾後，由啟動腳本自動執行。
"""

import os
import re
import json
import shutil
import sqlite3
import tempfile
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime, timezone

PORT = 8178  # ← changed from 8765

# Chrome History 資料庫位置（Windows）
CHROME_HISTORY_PATH = os.path.join(
    os.environ.get("LOCALAPPDATA", ""),
    "Google", "Chrome", "User Data", "Default", "History"
)


def get_history(limit=500, search=""):
    """從 Chrome SQLite 資料庫讀取瀏覽歷史。"""
    if not os.path.exists(CHROME_HISTORY_PATH):
        return {"error": "找不到 Chrome 歷史資料庫。請確認 Chrome 已安裝。", "rows": [], "count": 0}

    # 複製資料庫（Chrome 鎖定時仍可讀）
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".db")
    tmp.close()
    try:
        shutil.copy2(CHROME_HISTORY_PATH, tmp.name)
        conn = sqlite3.connect(tmp.name)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Chrome 時間戳：自 1601-01-01 起的微秒數
        if search:
            cursor.execute("""
                SELECT url, title, visit_count,
                       datetime((last_visit_time / 1000000) - 11644473600, 'unixepoch') AS last_visit
                FROM urls
                WHERE url LIKE ? OR title LIKE ?
                ORDER BY last_visit_time DESC
                LIMIT ?
            """, (f"%{search}%", f"%{search}%", limit))
        else:
            cursor.execute("""
                SELECT url, title, visit_count,
                       datetime((last_visit_time / 1000000) - 11644473600, 'unixepoch') AS last_visit
                FROM urls
                ORDER BY last_visit_time DESC
                LIMIT ?
            """, (limit,))

        rows = [dict(r) for r in cursor.fetchall()]
        conn.close()
        return {"rows": rows, "count": len(rows), "error": None}

    except Exception as e:
        return {"error": str(e), "rows": [], "count": 0}
    finally:
        try:
            os.unlink(tmp.name)
        except Exception:
            pass


class HistoryHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # 靜默日誌

    def do_OPTIONS(self):
        self.send_response(200)
        self._cors()
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)

        if parsed.path == "/history":
            limit = int(params.get("limit", [500])[0])
            search = params.get("search", [""])[0]
            result = get_history(limit=limit, search=search)
            body = json.dumps(result, ensure_ascii=False).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self._cors()
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")


if __name__ == "__main__":
    server = HTTPServer(("localhost", PORT), HistoryHandler)
    print(f"Chrome 歷史伺服器已啟動：http://localhost:{PORT}/history")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("伺服器已停止。")
