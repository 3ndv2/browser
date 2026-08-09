"""
Launches a real, visible Chrome browser (via Playwright) and navigates
to google.com. Meant to run inside a virtual display (Xvfb) on a
GitHub Codespace, viewed remotely through noVNC. Because it's a real
browser, CAPTCHAs render and can be solved normally by clicking
through the VNC view.
"""

import time
from playwright.sync_api import sync_playwright

URL = "https://www.google.com"

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=False,
            args=["--start-maximized", "--no-sandbox", "--disable-dev-shm-usage"],
        )
        context = browser.new_context(no_viewport=True)
        page = context.new_page()
        page.goto(URL)
        print(f"Browser open at {URL}. Keeping session alive — connect via noVNC to interact.")

        # Keep the process (and browser) alive indefinitely
        while True:
            time.sleep(3600)

if __name__ == "__main__":
    main()
