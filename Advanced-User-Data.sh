# my modified user data script so it runs once at first launch, and then automatically on every reboot and get updated pyhton file from source (Git).

#!/bin/bash

# Update and install essentials
yum update -y
yum install -y python3 git

# Upgrade pip and install Flask
pip3 install --upgrade pip
pip3 install flask

# Create your startup script
cat <<'EOF' > /home/ec2-user/startup_script.sh
#!/bin/bash
cd /home/ec2-user
echo "Running startup script at $(date)" >> /home/ec2-user/debug.log

# Clone or update your GitHub repo
rm -rf Auto-Scalling
git clone https://github.com/Jahanza
