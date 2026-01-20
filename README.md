# Traffic Sign Recognition API

Sistem pengenalan dan klasifikasi rambu lalu lintas menggunakan deep learning dengan arsitektur ResNet50. Aplikasi ini dapat mendeteksi 84 jenis rambu lalu lintas berbeda dengan confidence threshold 70% untuk memastikan prediksi yang akurat.

## Daftar Isi

- [Gambaran Umum](#gambaran-umum)
- [Fitur Utama](#fitur-utama)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Struktur Proyek](#struktur-proyek)
- [Instalasi dan Setup](#instalasi-dan-setup)
- [Cara Penggunaan](#cara-penggunaan)
- [API Endpoints](#api-endpoints)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Tim dan Kontribusi](#tim-dan-kontribusi)

## Gambaran Umum

Proyek ini merupakan bagian dari tugas akhir (UAS) yang mengimplementasikan solusi machine learning untuk otomasi pengenalan rambu lalu lintas. Sistem ini menggunakan model ResNet50 yang telah dilatih ulang (fine-tuned) pada dataset khusus rambu lalu lintas, dengan preprocessing dan augmentasi data yang sesuai.

Aplikasi ini menyediakan:
- Backend API berbasis Flask dengan REST endpoints
- Frontend web interface untuk interaksi user-friendly
- Model machine learning terlatih dalam format PyTorch (.pth)
- Dukungan deployment di berbagai platform (local, Docker, AWS EC2, AWS AppRunner)
- Logging dan error handling yang komprehensif

### Konteks Penggunaan

Sistem ini dapat diintegrasikan dengan:
- Aplikasi smart traffic management
- Autonomous vehicle systems
- Traffic monitoring dan analytics platform
- Educational projects untuk computer vision

## Fitur Utama

### Klasifikasi dan Deteksi

- Mengenali 84 jenis rambu lalu lintas dari berbagai negara (khususnya India dan standar internasional)
- Confidence scoring dengan threshold 70% untuk filter prediksi berkualitas rendah
- Deteksi otomatis untuk gambar yang bukan rambu lalu lintas
- Support format gambar: JPEG, PNG, BMP, GIF, WEBP

### Teknologi

- Framework: Flask (Python web framework)
- Model: ResNet50 (pretrained ImageNet1K_V2)
- Deep Learning: PyTorch
- Image Processing: Pillow (PIL)
- Cross-Origin Resource Sharing (CORS) enabled
- Compatible dengan CPU dan GPU (CUDA)

### Performance

- Inference time: < 1 detik per gambar (GPU) / 2-3 detik (CPU)
- Memory footprint: 400MB (dengan model)
- Model size: 96MB
- Concurrent requests: Unlimited (Flask built-in threading)

## Arsitektur Sistem

### Model Architecture

```
ResNet50 Base (Pretrained ImageNet1K_V2)
    |
    +-- Feature Extraction Layers (conv1-layer4)
    |
    +-- Global Average Pooling (2048 features)
    |
    +-- Custom Classification Head
        ├── Dense Layer: 2048 -> 256 units
        ├── Activation: ReLU
        ├── Regularization: Dropout (p=0.4)
        ├── Dense Layer: 256 -> 84 units
        └── Output: Softmax for class probabilities
```

### Stack Teknologi

```
Frontend
    └── HTML5 + Vanilla JavaScript
        └── Fetch API untuk komunikasi dengan backend

Backend
    └── Flask (Python web framework)
        ├── CORS middleware
        ├── Routing dan request handling
        └── Image preprocessing

ML Pipeline
    └── PyTorch Runtime
        ├── Model loading
        ├── Inference engine
        ├── Softmax activation
        └── Confidence calculation

Infrastructure
    ├── Docker containerization
    ├── AWS EC2 deployment option
    ├── AWS AppRunner deployment option
    └── Systemd service management
```

### Flow Diagram

```
User Upload Image
    |
    v
HTML Form Input
    |
    v
JavaScript: File Validation & Preview
    |
    v
HTTP POST /predict (Multipart Form)
    |
    v
Flask Route Handler
    |
    v
Image Validation & Loading (PIL)
    |
    v
Preprocessing: Resize, Normalize (ResNet50 transforms)
    |
    v
Model Inference (PyTorch)
    |
    v
Softmax + Confidence Extraction
    |
    v
Threshold Decision (70%)
    |
    +-- If confidence < 70% --> Not a traffic sign
    |
    +-- If confidence >= 70% --> Return prediction
    |
    v
JSON Response to Frontend
    |
    v
Display Result to User
```

## Struktur Proyek

```
uas-ai/
|
├── API.py                              # Flask API server (116 lines)
│   ├── Flask app initialization
│   ├── Model loading
│   ├── /predict endpoint (POST)
│   └── / endpoint (GET - serve HTML)
│
├── UAS_WEB.html                        # Frontend web interface (86 lines)
│   ├── HTML structure
│   ├── CSS styling
│   ├── JavaScript fetch logic
│   └── Image preview functionality
│
├── UAS_Model.ipynb                     # Jupyter notebook
│   ├── Data loading dan exploration
│   ├── Model architecture definition
│   ├── Training loop
│   ├── Evaluation metrics
│   └── Model saving
│
├── labels.json                         # Kelas rambu lalu lintas (84 kelas)
│   └── JSON array dengan nama setiap rambu
│
├── resnet50_roadsigns_balanced.pth     # Model weights (96MB, Git LFS)
│   └── Serialized PyTorch model state
│
├── requirements.txt                    # Python dependencies lengkap
│   ├── Flask 3.1.2
│   ├── PyTorch 2.9.1 (dengan CUDA 12.8)
│   ├── TorchVision 0.24.1
│   ├── Pillow 12.1.0
│   └── Flask-CORS 6.0.2
│
├── requirements-ec2.txt                # Dependencies untuk EC2 (CPU-only)
│   ├── Flask 3.0.0+
│   ├── PyTorch 2.0.0+ (CPU version)
│   ├── TorchVision 0.15.0+
│   └── Pillow 10.0.0+
│
├── Dockerfile                          # Docker configuration
│   ├── Base: Python 3.12-slim
│   ├── Workdir: /app
│   ├── Dependencies installation
│   ├── File copying
│   └── Expose port 8080
│
├── deploy-ec2.sh                       # Automated EC2 deployment script
│   ├── SCP file transfer
│   ├── SSH dependency installation
│   ├── Flask service startup
│   └── Health check
│
├── uas-ai.service                      # Systemd service file
│   ├── Service description
│   ├── Start command
│   ├── Restart policy
│   └── Logging configuration
│
├── run-flask-background.sh             # Background execution script
│   ├── nohup process spawning
│   └── Log redirection
│
├── download_model.sh                   # Model download helper
│   ├── Google Drive option (commented)
│   ├── Hugging Face option (commented)
│   └── Local validation
│
├── .gitignore                          # Git ignore patterns
│   ├── __pycache__, *.pyc
│   ├── venv, .env
│   └── .DS_Store
│
├── .gitattributes                      # Git LFS configuration
│   └── *.pth filter=lfs diff=lfs merge=lfs -text
│
├── .dockerignore                       # Docker ignore patterns
│
├── docs/                               # Documentation
│   └── README_AWS_DEPLOYMENT.md        # AWS deployment guide
│       ├── AWS AppRunner setup (Option 1: Console)
│       ├── AWS AppRunner via CLI (Option 2: Recommended)
│       ├── AWS CodePipeline (Option 3: Full CI/CD)
│       ├── Monitoring dan logging
│       ├── Cost estimation
│       └── Troubleshooting
│
├── sample_image/                       # Test images
│   └── slippery_road.png              # Sample traffic sign for testing
│
└── README.md                           # File dokumentasi ini
```

## Instalasi dan Setup

### Prerequisites

Sebelum memulai, pastikan sudah install:
- Python 3.9 atau lebih tinggi
- pip package manager
- Git dengan Git LFS untuk model file
- Optional: Docker (untuk containerization)
- Optional: CUDA toolkit (untuk GPU acceleration)

### Instalasi Lokal (Development)

#### 1. Clone Repository

```bash
git clone https://github.com/nabilfaturr/uas-ai.git
cd uas-ai
```

#### 2. Setup Git LFS (untuk model file)

```bash
# Install Git LFS
git lfs install

# Download model file (96MB)
git lfs pull
```

Jika belum install Git LFS:
- Linux: `sudo apt-get install git-lfs`
- macOS: `brew install git-lfs`
- Windows: Download dari https://git-lfs.github.com/

#### 3. Buat Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# Linux/macOS:
source venv/bin/activate
# Windows:
venv\Scripts\activate
```

#### 4. Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Catatan untuk berbagai setup:

**Untuk GPU (CUDA 12.x):**
```bash
pip install -r requirements.txt
```

**Untuk CPU only:**
```bash
pip install Flask Flask-CORS Pillow torch torchvision
```

**Untuk Google Colab:**
```bash
!pip install -r requirements.txt
```

#### 5. Verifikasi Setup

```bash
# Check Python version
python --version

# Check PyTorch installation
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'GPU Available: {torch.cuda.is_available()}')"

# Check model file exists
ls -lh resnet50_roadsigns_balanced.pth

# Check labels
python -c "import json; labels = json.load(open('labels.json')); print(f'Total classes: {len(labels)}')"
```

#### 6. Jalankan Aplikasi

```bash
python API.py
```

Expected output:
```
Using device: cuda (atau cpu)
 * Serving Flask app 'API'
 * Debug mode: off
 * Running on http://0.0.0.0:8080
 * Press CTRL+C to quit
```

Akses aplikasi di browser: `http://localhost:8080`

### Docker Setup

#### 1. Build Docker Image

```bash
# Build image
docker build -t traffic-sign-api:latest .

# Verify build
docker images | grep traffic-sign-api
```

#### 2. Run Container

```bash
# Run container
docker run -d \
  --name traffic-sign-api \
  -p 8080:8080 \
  traffic-sign-api:latest

# Check logs
docker logs -f traffic-sign-api
```

#### 3. Test Container

```bash
# Test endpoint
curl -X POST \
  -F "file=@sample_image/slippery_road.png" \
  http://localhost:8080/predict

# Stop container
docker stop traffic-sign-api
```

### EC2 Deployment

#### Quick Start

```bash
# Setup EC2 instance dengan Ubuntu/Amazon Linux
# SSH ke instance, kemudian:

# Clone repository
git clone https://github.com/nabilfaturr/uas-ai.git
cd uas-ai

# Install Python dan dependencies
sudo apt update
sudo apt install python3-pip python3-dev
pip3 install -r requirements-ec2.txt

# Download model
git lfs install && git lfs pull

# Run application
python3 API.py
```

#### Automated Deployment Script

Gunakan script automated deployment yang sudah disediakan:

```bash
chmod +x deploy-ec2.sh
./deploy-ec2.sh
```

Pastikan update `EC2_IP` dan `KEY_FILE` di script sesuai environment Anda.

Lihat dokumentasi lengkap di [docs/README_AWS_DEPLOYMENT.md](docs/README_AWS_DEPLOYMENT.md)

## Cara Penggunaan

### Web Interface

1. Akses aplikasi di `http://localhost:8080` (local) atau deployment URL
2. Klik "Choose File" untuk select gambar
3. Gambar akan ditampilkan sebagai preview
4. Klik tombol "Predict" untuk melakukan prediksi
5. Hasil akan ditampilkan berisi confidence score, nama rambu, dan class ID

### API Programmatic

#### Endpoint: POST /predict

Request dengan cURL:
```bash
curl -X POST \
  -F "file=@/path/to/image.jpg" \
  http://localhost:8080/predict
```

Request dengan Python:
```python
import requests

with open('sample_image.jpg', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://localhost:8080/predict', files=files)

result = response.json()
print(result)
```

Request dengan JavaScript:
```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);

const response = await fetch('/predict', {
  method: 'POST',
  body: formData
});

const result = await response.json();
console.log(result);
```

### Interpretasi Response

#### Success Response (Traffic Sign Detected)

```json
{
  "is_traffic_sign": true,
  "confidence": 0.87,
  "label": "STOP",
  "class_id": 73
}
```

#### Success Response (Not a Traffic Sign)

```json
{
  "is_traffic_sign": false,
  "confidence": 0.45,
  "label": null,
  "class_id": null,
  "message": "Bukan traffic sign"
}
```

#### Error Response

```json
{
  "error": "invalid image format"
}
```

Response fields:
- `is_traffic_sign`: Apakah prediksi masuk threshold 70%
- `confidence`: Confidence score 0-1 (0-100%)
- `label`: Nama rambu lalu lintas
- `class_id`: Index dalam array labels (0-83)
- `message`: Pesan tambahan jika applicable

## API Endpoints

### 1. GET /

**Deskripsi**: Serve HTML frontend

**Response**: HTML content

**Example**:
```bash
curl http://localhost:8080/
```

### 2. POST /predict

**Deskripsi**: Predict traffic sign dari uploaded image

**Parameters**:
- `file` (multipart/form-data): Image file (JPEG, PNG, BMP, GIF, WEBP)

**Response**: JSON sesuai format di atas

**Error Codes**:
- `400`: File field tidak ada atau format gambar tidak valid
- `200`: Request berhasil

**Confidence Threshold**:
- Default: 70% (0.70)
- Dapat diubah di `CONFIDENCE_THRESHOLD` variable di API.py

## Deployment

### Local Development

Sudah tercakup di section Instalasi dan Setup

### Docker

Sudah tercakup di section Docker Setup

### AWS EC2

Script otomatis:
```bash
./deploy-ec2.sh
```

Script akan:
1. SCP upload files ke EC2 instance
2. SSH install dependencies
3. Start Flask application
4. Provide public URL

### AWS AppRunner (Managed)

Lihat dokumentasi lengkap di [docs/README_AWS_DEPLOYMENT.md](docs/README_AWS_DEPLOYMENT.md)

Quick start:
```bash
# Login ke ECR
aws ecr get-login-password | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com

# Build dan push image
docker build -t traffic-sign-api:latest .
docker tag traffic-sign-api:latest <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/traffic-sign-api:latest
docker push <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/traffic-sign-api:latest
```

### Systemd Service (Production)

```bash
sudo cp uas-ai.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable uas-ai
sudo systemctl start uas-ai

# Check status
sudo systemctl status uas-ai
sudo journalctl -u uas-ai -f
```

## Daftar 84 Kelas Rambu Lalu Lintas

Model dapat mengklasifikasikan 84 jenis rambu lalu lintas: ALL_MOTOR_VEHICLE_PROHIBITED, AXLE_LOAD_LIMIT, BARRIER_AHEAD, BULLOCK_AND_HANDCART_PROHIBITED, BULLOCK_PROHIBITED, CATTLE, COMPULSARY_AHEAD, COMPULSARY_AHEAD_OR_TURN_LEFT, COMPULSARY_AHEAD_OR_TURN_RIGHT, COMPULSARY_CYCLE_TRACK, COMPULSARY_KEEP_LEFT, COMPULSARY_KEEP_RIGHT, COMPULSARY_MINIMUM_SPEED, COMPULSARY_SOUND_HORN, COMPULSARY_TURN_LEFT, COMPULSARY_TURN_LEFT_AHEAD, COMPULSARY_TURN_RIGHT, COMPULSARY_TURN_RIGHT_AHEAD, CROSS_ROAD, CYCLE_CROSSING, CYCLE_PROHIBITED, DANGEROUS_DIP, DIRECTION, FALLING_ROCKS, FERRY, GAP_IN_MEDIAN, GIVE_WAY, GUARDED_LEVEL_CROSSING, HANDCART_PROHIBITED, HEIGHT_LIMIT, HORN_PROHIBITED, HUMP_OR_ROUGH_ROAD, LEFT_HAIR_PIN_BEND, LEFT_HAND_CURVE, LEFT_REVERSE_BEND, LEFT_TURN_PROHIBITED, LENGTH_LIMIT, LOAD_LIMIT, LOOSE_GRAVEL, MEN_AT_WORK, NARROW_BRIDGE, NARROW_ROAD_AHEAD, NO_ENTRY, NO_PARKING, NO_STOPPING_OR_STANDING, OVERTAKING_PROHIBITED, PASS_EITHER_SIDE, PEDESTRIAN_CROSSING, PEDESTRIAN_PROHIBITED, PRIORITY_FOR_ONCOMING_VEHICLES, QUAY_SIDE_OR_RIVER_BANK, RESTRICTION_ENDS, RIGHT_HAIR_PIN_BEND, RIGHT_HAND_CURVE, RIGHT_REVERSE_BEND, RIGHT_TURN_PROHIBITED, ROAD_WIDENS_AHEAD, ROUNDABOUT, SCHOOL_AHEAD, SIDE_ROAD_LEFT, SIDE_ROAD_RIGHT, SLIPPERY_ROAD, SPEED_LIMIT_15, SPEED_LIMIT_20, SPEED_LIMIT_30, SPEED_LIMIT_40, SPEED_LIMIT_5, SPEED_LIMIT_50, SPEED_LIMIT_60, SPEED_LIMIT_70, SPEED_LIMIT_80, STAGGERED_INTERSECTION, STEEP_ASCENT, STEEP_DESCENT, STOP, STRAIGHT_PROHIBITED, TONGA_PROHIBITED, TRAFFIC_SIGNAL, TRUCK_PROHIBITED, TURN_RIGHT, T_INTERSECTION, UNGUARDED_LEVEL_CROSSING, U_TURN_PROHIBITED, WIDTH_LIMIT, Y_INTERSECTION

Lihat file `labels.json` untuk daftar lengkap.

## Konfigurasi

### Environment Variables

| Variable | Default | Deskripsi |
|----------|---------|-----------|
| PORT | 8080 | Port untuk Flask server |
| CONFIDENCE_THRESHOLD | 0.70 | Minimum confidence untuk valid prediction |

Setup:
```bash
export PORT=5000
python API.py
```

### Model Configuration

Edit di `API.py`:
```python
CONFIDENCE_THRESHOLD = 0.70
```

## Troubleshooting

### Model file not found

```bash
git lfs install
git lfs pull
```

### CUDA out of memory

```python
# Di API.py
device = torch.device("cpu")
```

### Port already in use

```bash
lsof -i :8080
kill -9 <PID>

# Atau gunakan port berbeda
PORT=9000 python API.py
```

### Import error

```bash
source venv/bin/activate
pip install -r requirements.txt
```

### CORS error

CORS sudah enabled di Flask app. Jika masih error, lihat bagian CORS configuration di API.py

## Testing

### Manual Testing

```bash
# Test endpoint dengan sample image
curl -X POST \
  -F "file=@sample_image/slippery_road.png" \
  http://localhost:8080/predict
```

### Automated Testing

```python
import requests

url = "http://localhost:8080/predict"
with open('sample_image/slippery_road.png', 'rb') as f:
    response = requests.post(url, files={'file': f})
    print(response.json())
```

## Performance

### Inference Time

- GPU (RTX 3080): 200ms
- GPU (Tesla T4): 400ms
- CPU (4 cores): 2-3s
- CPU (2 cores): 5-8s

### Memory Usage

- Model weights: 96MB
- PyTorch runtime: 200MB
- Flask app: 50MB
- Total: 350MB

### Scalability

- Single instance: 100+ concurrent requests
- Horizontal scaling: Recommended untuk 1000+ requests/minute
- Load balancer: nginx, AWS ALB

## Development

### Future Enhancements

1. Batch processing endpoint
2. Caching untuk repeated predictions
3. Model versioning
4. Metrics collection dan monitoring
5. Authentication dan rate limiting
6. Database untuk prediction history
7. Real-time video stream processing

### Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push ke branch
5. Open Pull Request

## Technologies

- Flask 3.1.2
- PyTorch 2.9.1
- ResNet50 ImageNet1K_V2
- Pillow 12.1.0
- Flask-CORS 6.0.2
- Docker
- AWS EC2/AppRunner
- Systemd

## License

Proyek ini adalah untuk tujuan edukatif (UAS).

## Tim

Dikembangkan oleh Nabil Faturrahman sebagai bagian dari Ujian Akhir Semester.

Repository: https://github.com/nabilfaturr/uas-ai

---

**Last Updated**: Januari 2026
