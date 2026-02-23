from flask import Flask, jsonify, Response
import socket
import datetime
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUESTS = Counter("app_requests_total", "Total number of requests to the app")

@app.route("/")
def home():
    REQUESTS.inc()
    return f"""
    🚀 SelfHealing App Running!<br>
    Host: {socket.gethostname()}<br>
    Time: {datetime.datetime.now()}
    """

@app.route("/health")
def health():
    return jsonify(status="OK"), 200

@app.route("/info")
def info():
    return jsonify(
        app="SelfHealingApp Demo",
        version="1.0",
        environment="dev"
    )

@app.route("/metrics")
def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
