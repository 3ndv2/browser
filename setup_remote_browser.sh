#!/usr/bin/env bash
# Run this inside a GitHub Codespace terminal.
# Sets up a real, visible Chrome browser you can view and control
# remotely through your own browser (via noVNC), so any CAPTCHA
# that appears can be solved normally with mouse clicks.
set -e

echo "==> Installing system packages..."
sudo apt-get update
sudo apt-get install -y xvfb x11vnc novnc websockify fluxbox

echo "==> Installing Playwright + Chromium..."
pip install --user playwright --break-system-packages
python3 -m playwright install --with-deps chromium

echo "==> Starting virtual display on :1..."
Xvfb :1 -screen 0 1366x768x24 &
sleep 2
export DISPLAY=:1

echo "==> Starting lightweight window manager..."
fluxbox &
sleep 1

echo "==> Starting VNC server on 5900..."
x11vnc -display :1 -nopw -forever -shared -bg

echo "==> Starting noVNC web client on port 6080..."
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

echo "==> Launching Chrome (this window shows up in the VNC view)..."
DISPLAY=:1 python3 launch_browser.py &

echo ""
echo "Setup complete."
echo "1. Open the 'Ports' tab in the Codespace, forward port 6080 (set it to Private)."
echo "2. Click the forwarded URL and append /vnc.html to it, e.g.:"
echo "   https://<your-codespace-url>-6080.app.github.dev/vnc.html"
echo "3. Click Connect. You'll see the live Chrome window — interact with it"
echo "   normally, including clicking through any CAPTCHA that appears."
