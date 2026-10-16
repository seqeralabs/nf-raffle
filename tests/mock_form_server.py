#!/usr/bin/env python3
"""Local stand-in for a Google Form endpoint (and a minimal Seqera Platform API) for tests.

POST /formResponse appends the form body to a JSON-lines file as
{"path": ..., "fields": {...}} and replies 200. Any other request gets a canned
JSON reply that is enough for `-with-tower http://localhost:<port>` to complete,
so tests can exercise platform_enabled=true without a real Platform account.
Standard library only.

    python3 tests/mock_form_server.py --port 8765 --log requests.jsonl
"""

import argparse
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs

PLATFORM_REPLY = json.dumps({"workflowId": "mockWorkflowId", "watchUrl": "http://localhost/watch"}).encode()


def make_handler(log_path):
    class Handler(BaseHTTPRequestHandler):
        def reply(self, status, content_type, body):
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def handle_any(self):
            body = self.rfile.read(int(self.headers.get("Content-Length", 0))).decode()
            if self.command == "POST" and self.path.endswith("/formResponse"):
                fields = {k: v[0] for k, v in parse_qs(body, keep_blank_values=True).items()}
                with open(log_path, "a") as fh:
                    fh.write(json.dumps({"path": self.path, "fields": fields}) + "\n")
                self.reply(200, "text/plain", b"mock form: response recorded\n")
            else:
                self.reply(200, "application/json", PLATFORM_REPLY)

        do_GET = do_POST = do_PUT = handle_any

        def log_message(self, fmt, *args):
            pass

    return Handler


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--log", default="mock_form_requests.jsonl")
    args = parser.parse_args()
    ThreadingHTTPServer(("127.0.0.1", args.port), make_handler(args.log)).serve_forever()


if __name__ == "__main__":
    main()
