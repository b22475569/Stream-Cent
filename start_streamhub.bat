@echo off
REM Stream Hub 快速啟動腳本
echo ================================
echo   Stream Hub 正在啟動...
echo ================================
echo.

REM 切換到 HTML 檔案所在目錄（請修改成你的實際路徑）
cd /d "%~dp0"

REM 啟動 Python 伺服器
echo 正在啟動本地伺服器...
start "Stream Hub Server" python -m http.server 8000

REM 等待 2 秒讓伺服器完全啟動
timeout /t 2 /nobreak >nul

REM 自動開啟瀏覽器 - 使用 Chrome
echo 正在開啟 Chrome 瀏覽器...
start chrome http://localhost:8000/Stream-hub_Ver-9_2_with_98-XP_sound-Smooth-Slide-bar.html

echo.
echo ================================
echo   Stream Hub 已啟動！
echo   按任意鍵關閉此視窗
echo   （伺服器會繼續在背景執行）
echo ================================
pause >nul
