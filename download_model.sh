#!/bin/bash
# Download model from external storage

echo "Downloading model..."

# Option 1: From Google Drive (you need to upload first and get share link)
# FILE_ID="YOUR_GOOGLE_DRIVE_FILE_ID"
# wget --no-check-certificate "https://drive.google.com/uc?export=download&id=${FILE_ID}" -O resnet50_roadsigns_balanced.pth

# Option 2: From Hugging Face (recommended - free unlimited storage)
# You need to upload model to huggingface.co first
# wget https://huggingface.co/YOUR_USERNAME/YOUR_MODEL/resolve/main/resnet50_roadsigns_balanced.pth

# For now, we'll check if file exists locally (for testing)
if [ ! -f "resnet50_roadsigns_balanced.pth" ]; then
    echo "ERROR: Model file not found!"
    echo "Please upload model to cloud storage and update this script"
    exit 1
fi

echo "Model ready!"
