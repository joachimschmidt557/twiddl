#!/usr/bin/env python3

import http.server
import time
import subprocess

HOST_NAME = 'localhost' # !!!REMEMBER TO CHANGE THIS!!!
PORT_NUMBER = 8080 # Maybe set this to 9000.

#Handler class

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_HEAD(s):
        s.send_response(200)
        s.send_header("Content-type", "text/plain")
        s.end_headers()
    def do_GET(s):
        """Respond to a GET request."""
        s.send_response(200)
        s.send_header("Content-type", "text/plain")
        s.end_headers()

        url = s.path
        if url == "/trigger-make":
            print("Triggered make")
            subprocess.call("make", shell=True)
    def do_POST(s):
        """Respond to a POST request."""
        s.send_response(200)
        s.send_header("Content-type", "text/plain")
        s.end_headers()

        url = s.path
        if url == "/trigger-make":
            print("Triggered make")
            subprocess.call("make", shell=True)

if __name__ == '__main__':
    print("Now starting server. ")

    server_class = http.server.HTTPServer
    httpd = server_class(("", PORT_NUMBER), MyHandler)
    print(time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER))
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print(time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER))
