#!/bin/bash
# Script to run Flask app in background using nohup

cd ~
nohup python3 API.py > flask.log 2>&1 &
echo "Flask app started in background. PID: $!"
echo "Check logs: tail -f ~/flask.log"
echo "Stop app: pkill -f 'python3 API.py'"
