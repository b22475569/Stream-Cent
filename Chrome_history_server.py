"""
╔══════════════════════════════════════════════════════════════╗
║   CHROME HISTORY LOCAL SERVER — Stream Content Hub          ║
║   Reads:  C:\\Users\\Administrator\\AppData\\Local\\Google\\       ║
║           Chrome\\User Data\\Default\\History                  ║
║   Serves: http://localhost:8765/history                      ║
║   Run:    python chrome_history_server.py                    ║
╚══════════════════════════════════════════════════════════════╝
"""

import sqlite3, shutil, json, os, sys, tempfile
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from datetime import datetime, timezone

# ── Config ────────────────────────────────────────────────────
CHROME_HISTORY = r"C:\Users\Administrator\AppData\Local\Google\Chrome\User Data\Default\History"
PORT            = 8765
MAX_RESULTS     = 500          # max rows to return
# ──────────────────────────────────────────────────────────────

def chrome_time_to_iso(chrome_ts):
    """Convert Chrome's microseconds-since-1601 to ISO-8601 string."""
    if not chrome_ts:
        return ""
    try:
        epoch_diff = 11644473600          # seconds between 1601-01-01 and 1970-01-01
        ts_sec = (chrome_ts / 1_000_000) - epoch_diff
        return datetime.fromtimestamp(ts_sec, tz=timezone.utc).astimezone().isoformat()
    except Exception:
        return ""

def read_history(limit=MAX_RESULTS, search=""):
    """Copy DB to temp, query it, return list of dicts."""
    if not os.path.exists(CHROME_HISTORY):
        return {"error": f"History file not found: {CHROME_HISTORY}"}

    # Chrome locks the file — copy to temp first
    tmp = tempfile.mktemp(suffix=".db")
    try:
        shutil.copy2(CHROME_HISTORY, tmp)
    except PermissionError as e:
        return {"error": f"Cannot copy History file — make sure Chrome is CLOSED. ({e})"}

    rows = []
    try:
        con = sqlite3.connect(tmp)
        con.row_factory = sqlite3.Row
        cur = con.cursor()

        if search:
            sql = """
                SELECT u.id, u.url, u.title, u.visit_count,
                       u.last_visit_time, u.typed_count
                FROM   urls u
                WHERE  lower(u.url) LIKE lower(?) OR lower(u.title) LIKE lower(?)
                ORDER  BY u.last_visit_time DESC
                LIMIT  ?
            """
            like = f"%{search}%"
            cur.execute(sql, (like, like, limit))
        else:
            sql = """
                SELECT u.id, u.url, u.title, u.visit_count,
                       u.last_visit_time, u.typed_count
                FROM   urls u
                ORDER  BY u.last_visit_time DESC
                LIMIT  ?
            """
            cur.execute(sql, (limit,))

        for r in cur.fetchall():
            rows.append({
                "id":           r["id"],
                "url":          r["url"],
                "title":        r["title"] or r["url"],
                "visit_count":  r["visit_count"],
                "typed_count":  r["typed_count"],
                "last_visit":   chrome_time_to_iso(r["last_visit_time"]),
            })
        con.close()
    except Exception as e:
        return {"error": str(e)}
    finally:
        try:
            os.remove(tmp)
        except Exception:
            pass

    return {"count": len(rows), "rows": rows}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(f"[{datetime.now().strftime('%H:%M:%S')}]", fmt % args)

    def send_cors(self):
        self.send_header("Access-Control-Allow-Origin",  "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_cors()
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        params = parse_qs(parsed.query)

        if parsed.path == "/history":
            limit  = int(params.get("limit",  [MAX_RESULTS])[0])
            search = params.get("search", [""])[0]
            data   = read_history(limit=limit, search=search)
            body   = json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type",   "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_cors()
            self.end_headers()
            self.wfile.write(body)

        elif parsed.path == "/ping":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_cors()
            self.end_headers()
            self.wfile.write(b"pong")

        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not found")


if __name__ == "__main__":
    if not os.path.exists(CHROME_HISTORY):
        print(f"\n⚠️  History file not found:\n   {CHROME_HISTORY}")
        print("   Make sure Chrome is installed and has been opened at least once.\n")
    else:
        print(f"\n✅  History file found: {CHROME_HISTORY}")

    print(f"\n🚀  Starting Chrome History Server on http://localhost:{PORT}")
    print(f"    Endpoints:")
    print(f"    GET http://localhost:{PORT}/history          — latest {MAX_RESULTS} entries")
    print(f"    GET http://localhost:{PORT}/history?limit=50 — custom limit")
    print(f"    GET http://localhost:{PORT}/history?search=google — filter by keyword")
    print(f"\n    Press Ctrl+C to stop.\n")

    server = HTTPServer(("localhost", PORT), Handler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑  Server stopped.")
