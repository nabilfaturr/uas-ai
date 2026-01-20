from flask import Flask, request, jsonify, send_file, render_template_string
from flask_cors import CORS
from PIL import Image, UnidentifiedImageError
import torch
from torchvision.models import resnet50, ResNet50_Weights
import torch.nn as nn
import json
import os


# CONFIG

CONFIDENCE_THRESHOLD = 0.70  # 7.00 = 70%


# APP

app = Flask(__name__, static_folder='static', static_url_path='/static')
CORS(app)


# LOAD LABELS

with open("labels.json") as f:
    LABELS = json.load(f)

NUM_CLASSES = len(LABELS)


# DEVICE

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Using device:", device)


# MODEL

weights = ResNet50_Weights.IMAGENET1K_V2
model = resnet50(weights=weights)

model.fc = nn.Sequential(
    nn.Linear(model.fc.in_features, 256),
    nn.ReLU(),
    nn.Dropout(0.4),
    nn.Linear(256, NUM_CLASSES)
)

state = torch.load("resnet50_roadsigns_balanced.pth", map_location=device)
model.load_state_dict(state)

model.to(device)
model.eval()

# SAME transform as training
transform = weights.transforms()


# ROUTES

@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error": "file field is required"}), 400

    file = request.files["file"]

    try:
        image = Image.open(file.stream).convert("RGB")
    except UnidentifiedImageError:
        return jsonify({"error": "invalid image format"}), 400

    x = transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        outputs = model(x)
        probs = torch.softmax(outputs, dim=1)

        confidence, pred = torch.max(probs, dim=1)
        confidence = confidence.item()
        pred = pred.item()

    
    # DECISION LOGIC (IMPORTANT)
   
    if confidence < CONFIDENCE_THRESHOLD:
        return jsonify({
            "is_traffic_sign": False,
            "confidence": confidence,
            "label": None,
            "class_id": None,
            "message": "Bukan traffic sign"
        })

    return jsonify({
        "is_traffic_sign": True,
        "confidence": confidence,
        "label": LABELS[pred],
        "class_id": int(pred)
    })


@app.route("/")
def home():
    # Serve HTML frontend
    try:
        with open("UAS_WEB.html", "r", encoding="utf-8") as f:
            html_content = f.read()
        return html_content
    except FileNotFoundError:
        return "API OK - Frontend not found"


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
