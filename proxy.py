"""
Minimal HTTP proxy that forwards requests to google.com.

Run this in a GitHub Codespace (not on your own machine) and use the
Codespace's port-forwarding feature to access it remotely. Because it
runs in GitHub's cloud, requests to google.com originate from there,
not from your laptop.

Usage:
    python3 proxy.py
Then open the forwarded "8080" port shown in the Codespace "Ports" tab.
"""

from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.request
import urllib.error

TARGET = "https://www.google.com"
PORT = 8080

# Headers that shouldn't be copied straight through (they don't apply
# once content has passed through this proxy).
HOP_BY_HOP = {"content-encoding", "transfer-encoding", "connection", "content-length"}


class ProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self._proxy()

    def do_POST(self):
        self._proxy()

    def _proxy(self):
        url = TARGET + self.path
        try:
            body = None
            if self.command == "POST":
                length = int(self.headers.get("Content-Length", 0))
                body = self.rfile.read(length) if length else None

            req = urllib.request.Request(
                url,
                data=body,
                method=self.command,
                headers={"User-Agent": "Mozilla/5.0 (compatible; CodespaceProxy/1.0)"},
            )

            with urllib.request.urlopen(req, timeout=10) as resp:
                self.send_response(resp.status)
                for header, value in resp.getheaders():
                    if header.lower() not in HOP_BY_HOP:
                        self.send_header(header, value)
                self.end_headers()
                self.wfile.write(resp.read())

        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read() if e.fp else b"")
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(f"Proxy error: {e}".encode())

    def log_message(self, fmt, *args):
        # Quieter default logging
        print(f"[proxy] {self.address_string()} - {fmt % args}")


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), ProxyHandler)
    print(f"Proxy listening on 0.0.0.0:{PORT}, forwarding to {TARGET}")
    server.serve_forever()
