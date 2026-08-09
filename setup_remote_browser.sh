#!/usr/bin/env bash
# Run this inside a GitHub Codespace terminal.
# Sets up a real, visible, fullscreen Chrome browser you can view and
# control remotely through your own browser (via noVNC), so any
# CAPTCHA that appears can be solved normally with mouse clicks.
set -e

WIDTH=1920
HEIGHT=1080
DEPTH=16   # lower color depth = less data over VNC = snappier remote view

echo "==> Installing Playwright (Python package) in the background..."
pip install --user playwright --break-system-packages &
PIP_PID=$!

echo "==> Installing system packages (Xvfb, VNC, noVNC)..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends xvfb x11vnc novnc websockify

wait $PIP_PID

echo "==> Installing Chromium + required OS libraries..."
python3 -m playwright install --with-deps chromium

echo "==> Starting virtual display (${WIDTH}x${HEIGHT}, ${DEPTH}-bit)..."
Xvfb :1 -screen 0 ${WIDTH}x${HEIGHT}x${DEPTH} -nolisten tcp &
sleep 2
export DISPLAY=:1

echo "==> Starting VNC server..."
x11vnc -display :1 -nopw -forever -shared -noxdamage -bg

echo "==> Starting noVNC web client on port 6080..."
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

echo "==> Launching fullscreen Chrome (no window manager needed)..."
DISPLAY=:1 python3 launch_browser.py &

echo ""
echo "Setup complete."
echo "1. Open the 'Ports' tab in the Codespace, forward port 6080 (set it to Private)."
echo "2. Open this URL (swap in your forwarded host):"
echo "   https://<your-codespace-url>-6080.app.github.dev/vnc.html?resize=scale&autoconnect=true"
echo "   'resize=scale' stretches the remote screen to fill your browser window."