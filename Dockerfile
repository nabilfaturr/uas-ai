# Use official Python runtime as base image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY API.py .
COPY UAS_WEB.html .
COPY labels.json .
COPY resnet50_roadsigns_balanced.pth .

# Expose port
EXPOSE 8080

# Run Flask app
CMD ["python", "API.py"]
