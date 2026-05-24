import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer

class WebhookHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # When Automate hits this specific URL path, execute the action
        if self.path == '/open-whatsapp':
        # Forces native Windows CMD to open the protocol
            subprocess.run(['cmd', '/c', 'start', 'whatsapp://'], shell=True)
            
            # Send a success response back to Automate
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"WhatsApp Opened!")
        else:
            self.send_response(404)
            self.end_headers()

# Listens on port 8080 across your local network
server = HTTPServer(('0.0.0.0', 8080), WebhookHandler)
print("Listening for Android triggers on port 8080...")
server.serve_forever()