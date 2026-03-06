#!/bin/bash
# Stream Hub 快速啟動腳本 (Mac/Linux)

echo "================================"
echo "  Stream Hub 正在啟動..."
echo "================================"
echo

# 切換到腳本所在目錄
cd "$(dirname "$0")"

# 啟動 Python 伺服器（背景執行）
echo "正在啟動本地伺服器..."
python3 -m http.server 8000 &
SERVER_PID=$!

# 等待 2 秒讓伺服器完全啟動
sleep 2

# 自動開啟瀏覽器 - 優先使用 Chrome
echo "正在開啟 Chrome 瀏覽器..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac - 優先使用 Chrome
    if [ -d "/Applications/Google Chrome.app" ]; then
        open -a "Google Chrome" http://localhost:8000/Stream-Hub_Ver-161_2_with_98-XP_sound-Smooth-Carousel_Securd.html
    else
        open http://localhost:8000/Stream-Hub_Ver-169_2_with_98-XP_sound-Smooth-Carousel_Securd.html
    fi
else
    # Linux - 優先使用 Chrome
    if command -v google-chrome &> /dev/null; then
        google-chrome http://localhost:8000/Stream-hub_Ver-169_2_with_98-XP_sound-Smooth-Slide-bar.html &
    elif command -v chromium-browser &> /dev/null; then
        chromium-browser http://localhost:8000/Stream-hub_Ver-169_2_with_98-XP_sound-Smooth-Slide-bar.html &
    else
        xdg-open http://localhost:8000/Stream-hub_Ver-169_2_with_98-XP_sound-Smooth-Slide-bar.html
    fi
fi

echo
echo "================================"
echo "  Stream Hub 已啟動！"
echo "  伺服器 PID: $SERVER_PID"
echo "  要停止伺服器請執行: kill $SERVER_PID"
echo "================================"
