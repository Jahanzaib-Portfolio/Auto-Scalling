#!/bin/bash
# Update system
yum update -y

# Install Python3, pip3, and git
yum install -y python3 git

# Upgrade pip
pip3 install --upgrade pip

# Clone the GitHub repository or pull the latest changes
cd /home/ec2-user
if [ ! -d "Auto-Scalling" ]; then
    git clone https://github.com/Jahanzaib-Portfolio/Auto-Scalling.git
else
    cd Auto-Scalling
    git pull origin main
fi

cd Auto-Scalling

# Install dependencies
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt
else
    pip3 install flask
fi


# Run the app in the background
nohup python3 auto_scaling_app.py > /home/ec2-user/app.log 2>&1 &
