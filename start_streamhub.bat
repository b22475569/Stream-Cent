@echo off
setlocal

REM ============================================================
REM  Stream Hub 啟動腳本 — 完整修正版
REM  需要同時啟動兩個伺服器：
REM   1) python -m http.server 8048   -> 提供 HTML 頁面
REM   2) python chrome_history_server.py -> Port 8765 Chrome 歷史
REM ============================================================

set "SITE_DIR=C:\Users\da07222024\OneDrive\Desktop\Site Web en ligne-Forwin10"
set "HTML_FILE=Stream-Hub_Ver-169_1_with_98-XP_sound-Smooth-Carousel_Securd.html"
set "PORT=8048"
set "HISTORY_PORT=8765"
set "URL=http://localhost:8048/Stream-Hub_Ver-169_1_with_98-XP_sound-Smooth-Carousel_Securd.html"

echo ============================================================
echo   Stream Hub 正在啟動...
echo ============================================================
echo.

REM -- 確認資料夾存在
if not exist "%SITE_DIR%\" (
    echo [錯誤] 找不到資料夾：%SITE_DIR%
    pause
    exit /b 1
)

REM -- 確認 HTML 檔案存在
if not exist "%SITE_DIR%\%HTML_FILE%" (
    echo [錯誤] 找不到 HTML 檔案：%HTML_FILE%
    pause
    exit /b 1
)

REM -- 切換到網站目錄
cd /d "%SITE_DIR%"

REM -- 伺服器1：HTTP 靜態伺服器 Port 8048
netstat -ano | find ":8048 " | find "LISTENING" >nul 2>&1
if errorlevel 1 (
    echo [1/2] 啟動 HTTP 伺服器 Port 8048...
    start "StreamHub-HTTP" /min cmd /c "cd /d "%SITE_DIR%" && python -m http.server 8048"
    timeout /t 2 /nobreak >nul
) else (
    echo [1/2] HTTP 伺服器 Port 8048 已在執行，略過。
)

REM -- 伺服器2：Chrome 歷史伺服器 Port 8765
netstat -ano | find ":8765 " | find "LISTENING" >nul 2>&1
if errorlevel 1 (
    if exist "%SITE_DIR%\chrome_history_server.py" (
        echo [2/2] 啟動 Chrome 歷史伺服器 Port 8765...
        start "StreamHub-History" /min cmd /c "cd /d "%SITE_DIR%" && python chrome_history_server.py"
        timeout /t 2 /nobreak >nul
    ) else (
        echo [2/2] 找不到 chrome_history_server.py - Chrome 歷史功能離線
    )
) else (
    echo [2/2] Chrome 歷史伺服器 Port 8765 已在執行，略過。
)

REM -- 開啟 Chrome
echo.
echo 正在開啟 Chrome...

set "CHROME="
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "CHROME=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
)

if defined CHROME (
    start "" "%CHROME%" --new-window "%URL%"
) else (
    echo Chrome 未找到，使用預設瀏覽器。
    start "" "%URL%"
)

echo.
echo ============================================================
echo   Stream Hub 已啟動！
echo   網址：%URL%
echo   關閉此視窗不影響伺服器執行。
echo ============================================================
timeout /t 5 /nobreak >nul
