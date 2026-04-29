import http.server
import socketserver

PORT = 8081

class MonitorHandler(http.server.SimpleHTTPRequestHandler):
	def do_GET(self):
		self.send_response(200)
		self.send_header("content-type", "text/html")
		self.end_headers()

		with open('/proc/meminfo', 'r') as file:
			ram_info = file.readline().strip()

		with open('/proc/loadavg', 'r') as file:
			cpu_info = file.read().strip()

		html_content = f"""
		<html>
		<head>
			<title>Monitoring DevOps</title>
			<style>
				body {{ font-family: Arial, sans-serif; background: #222; color: #0f0; text-align: center; padding-top: 50px; }}
				h1 {{ color: #fff; }}
				.box {{ border: 1px solid #0f0; padding: 20px; display: inline-block; margin: 10px; border-radius: 10px; }}
			</style>
		</head>
		<body>
			<h1>Terminal de Monitoring (Agent Python Custom)</h1>
			<div class="box">
				<h2>Memoire (RAM)</h2>
				<p>{ram_info}</p>
				</div>
				<div class="box">
				<h2>Charge CPU (1min, 5min, 15min)</h2>
				<p>{cpu_info}</p>
				</div>
				</body>
				</html>
				"""
		self.wfile.write(html_content.encode("utf-8"))
with socketserver.TCPServer(("", PORT), MonitorHandler) as httpd:
	print(f"Monitoring Server running on port {PORT}")
	httpd.serve_forever()
