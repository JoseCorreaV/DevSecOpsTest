from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.get("/")
def root():
    return jsonify({"my_secret": os.getenv("MY_SECRET", "NOT_SET")})

@app.get("/health")
def health():
    return jsonify({"status": "ok"})
