#!/bin/bash

# Install updates, Python, Git, and pip
apt update -y
apt install -y python3 python3-pip git

# Clone the GitHub repo and get only the needed Python file
git clone https://github.com/Jahanzaib-Portfolio/Auto-Scalling.git
cp Auto-Scalling/auto_scaling_app.py .

# Install Flask
pip3 install flask

# Create a simple Flask app to display content from auto_scaling_app.py
echo "
from flask import Flask
import subprocess

app = Flask(__name__)

@app.route('/')
def home():
    result = subprocess.getoutput('python3 auto_scaling_app.py')
    return result

app.run(host='0.0.0.0', port=3000)
" > app.py

# Run the Flask app in background
nohup python3 app.py &
