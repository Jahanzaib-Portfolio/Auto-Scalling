from flask import Flask
app = Flask(__name__)

@app.route('/')
def main():
    return "This is the application for Auto Scalling Project"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)
