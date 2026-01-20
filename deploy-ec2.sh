#!/bin/bash
set -e

EC2_IP="3.25.220.222"
KEY_FILE="$HOME/Documents/uas-ai-key-pair.pem"

echo "=== Deploying to EC2: $EC2_IP ==="

# 1. Upload files
echo "Uploading application files..."
scp -i "$KEY_FILE" API.py UAS_WEB.html labels.json requirements.txt ec2-user@$EC2_IP:~/

echo "Uploading model file (96MB, this may take a while)..."
scp -i "$KEY_FILE" resnet50_roadsigns_balanced.pth ec2-user@$EC2_IP:~/

# 2. Install dependencies
echo "Installing Python dependencies..."
ssh -i "$KEY_FILE" ec2-user@$EC2_IP <<'ENDSSH'
    pip3 install --user -r requirements.txt
ENDSSH

# 3. Run Flask app
echo "Starting Flask application..."
ssh -i "$KEY_FILE" ec2-user@$EC2_IP <<'ENDSSH'
    # Kill existing Flask processes
    pkill -f "python3.*API.py" || true
    
    # Run Flask in background
    nohup python3 API.py > flask.log 2>&1 &
    
    echo "Flask app started!"
    echo "Waiting for server to be ready..."
    sleep 5
    
    # Check if running
    if pgrep -f "python3.*API.py" > /dev/null; then
        echo "✓ Flask is running!"
        echo "✓ Access your app at: http://3.25.220.222:8080"
    else
        echo "✗ Flask failed to start. Check logs:"
        tail -20 flask.log
    fi
ENDSSH

echo ""
echo "=== Deployment Complete! ==="
echo "Application URL: http://3.25.220.222:8080"
