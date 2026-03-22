#!/bin/bash
# Stream Hub Quick Launch Script (Mac/Linux)

echo "================================"
echo "  Stream Hub is starting..."
echo "================================"
echo

# Change to the directory where this script is located
cd "$(dirname "$0")"

# Start Python server (run in background)
echo "Starting local server..."
python3 -m http.server 8000 &
SERVER_PID=$!

# Wait 2 seconds for the server to fully start
sleep 2

# Auto-open browser - prefer Chrome
echo "Opening Chrome browser..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac - prefer Chrome
    if [ -d "/Applications/Google Chrome.app" ]; then
        open -a "Google Chrome" http://localhost:8000/Stream-Hub_Ver-161_2_with_98-XP_sound-Smooth-Carousel_Securd.html
    else
        open http://localhost:8000/Stream-Hub_Ver-178_1_with_98-XP_sound-Smooth-Carousel_Securd.html
    fi
else
    # Linux - prefer Chrome
    if command -v google-chrome &> /dev/null; then
<<<<<<< HEAD
        google-chrome http://localhost:8000/Stream-hub_Ver-169_2_with_98-XP_sound-Smooth-Slide-bar.html &
    elif command -v chromium-browser &> /dev/null; then
        chromium-browser http://localhost:8000/Stream-hub_Ver-169_2_with_98-XP_sound-Smooth-Slide-bar.html &
    else
        xdg-open http://localhost:8000/Stream-hub_Ver-169_2_with_98-XP_sound-Smooth-Slide-bar.html
=======
        google-chrome http://localhost:8000/Stream-hub_Ver-169_1_with_98-XP_sound-Smooth-Slide-bar.html &
    elif command -v chromium-browser &> /dev/null; then
        chromium-browser http://localhost:8000/Stream-hub_Ver-169_1_with_98-XP_sound-Smooth-Slide-bar.html &
    else
        xdg-open http://localhost:8000/Stream-hub_Ver-169_1_with_98-XP_sound-Smooth-Slide-bar.html
>>>>>>> 16ce1063c6b40ca04b26c2b3a7e75f4421cd35f5
    fi
fi

echo
echo "================================"
echo "  Stream Hub is running!"
echo "  Server PID: $SERVER_PID"
echo "  To stop the server, run: kill $SERVER_PID"
echo "================================"
