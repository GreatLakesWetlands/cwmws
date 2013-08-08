import SimpleHTTPServer
import SocketServer
import socket
import urlparse
import urllib2

PORT = 8800

class ProxyHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        print self.path
        if "/PROXY/?" in self.path:
            parts = urlparse.urlparse(self.path)
            query = urlparse.parse_qs(parts.query)
            data = urllib2.urlopen(query['url'][0]).read()
            # self.send_header('Content-length', len(data))
            # self.end_headers()
            self.wfile.write(data)
        else:
            SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

Handler = ProxyHandler

while 1:
    try:
        httpd = SocketServer.TCPServer(("", PORT), Handler)
        break
    except:
        PORT += 1

print "serving at port", PORT
httpd.serve_forever()