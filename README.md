# Traffic Sign Recognition API

Sistem pengenalan dan klasifikasi rambu lalu lintas menggunakan deep learning ResNet50. Aplikasi ini dapat mendeteksi 84 jenis rambu lalu lintas dengan confidence threshold 70%.

## Daftar Isi

- [Gambaran Umum](#gambaran-umum)
- [Fitur Utama](#fitur-utama)
- [Instalasi](#instalasi)
- [Cara Penggunaan](#cara-penggunaan)
- [API Endpoints](#api-endpoints)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## Gambaran Umum

Proyek ini merupakan tugas akhir (UAS) yang mengimplementasikan solusi machine learning untuk pengenalan rambu lalu lintas. Sistem menggunakan model ResNet50 yang telah di-fine-tune pada dataset rambu lalu lintas, dengan preprocessing dan augmentasi data yang sesuai.

Aplikasi terdiri dari:
- Backend API berbasis Flask dengan REST endpoints
- Frontend web interface untuk upload dan prediksi gambar
- Model PyTorch ResNet50 terlatih (96MB)
- Dukungan deployment di local, Docker, AWS EC2, dan AWS AppRunner

## Fitur Utama

- Klasifikasi 84 jenis rambu lalu lintas
- Confidence threshold 70% untuk validasi prediksi
- Deteksi otomatis gambar yang bukan rambu lalu lintas
- REST API dengan response JSON
- Web interface user-friendly
- Support format: JPEG, PNG, BMP, GIF, WEBP
- CORS enabled
- Compatible CPU dan GPU (CUDA)

## Struktur Proyek

```
uas-ai/
├── API.py                          # Flask API server
├── UAS_WEB.html                    # Frontend interface
├── UAS_Model.ipynb                 # Training notebook
├── labels.json                     # 84 kelas rambu
├── resnet50_roadsigns_balanced.pth # Model weights (96MB, Git LFS)
├── requirements.txt                # Dependencies dengan CUDA
├── requirements-ec2.txt            # Dependencies CPU-only
├── Dockerfile                      # Docker config
├── deploy-ec2.sh                   # EC2 deployment script
├── uas-ai.service                  # Systemd service
├── run-flask-background.sh         # Background runner
├── docs/README_AWS_DEPLOYMENT.md   # AWS guide lengkap
├── sample_image/                   # Test images
└── README.md                       # Dokumentasi ini
```

## Instalasi

### Prerequisites

- Python 3.9+
- pip
- Git dengan Git LFS
- Optional: Docker, CUDA toolkit

### Lokal Development

```bash
# Clone repository
git clone https://github.com/nabilfaturr/uas-ai.git
cd uas-ai

# Setup Git LFS
git lfs install
git lfs pull

# Buat virtual environment
python3 -m venv venv
source venv/bin/activate  # atau venv\Scripts\activate di Windows

# Install dependencies
pip install -r requirements.txt

# Verifikasi setup
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'GPU: {torch.cuda.is_available()}')"

# Jalankan aplikasi
python API.py
```

Akses di browser: `http://localhost:8080`

### Docker

```bash
# Build image
docker build -t traffic-sign-api:latest .

# Run container
docker run -d -p 8080:8080 --name traffic-sign-api traffic-sign-api:latest

# Test
curl -X POST -F "file=@sample_image/slippery_road.png" http://localhost:8080/predict
```

### EC2 Deployment

```bash
# Setup EC2 instance (Ubuntu/Amazon Linux)
git clone https://github.com/nabilfaturr/uas-ai.git
cd uas-ai

sudo apt update
sudo apt install python3-pip python3-dev
pip3 install -r requirements-ec2.txt

git lfs install && git lfs pull
python3 API.py
```

Atau gunakan script otomatis:
```bash
chmod +x deploy-ec2.sh
./deploy-ec2.sh
```

### AWS AppRunner

Lihat dokumentasi di [docs/README_AWS_DEPLOYMENT.md](docs/README_AWS_DEPLOYMENT.md)

## Cara Penggunaan

### Web Interface

1. Akses `http://localhost:8080` atau deployment URL
2. Klik "Choose File" untuk upload gambar
3. Preview gambar ditampilkan
4. Klik "Predict"
5. Hasil dengan confidence score ditampilkan

### API dengan cURL

```bash
curl -X POST \
  -F "file=@/path/to/image.jpg" \
  http://localhost:8080/predict
```

### API dengan Python

```python
import requests

with open('traffic_sign.jpg', 'rb') as f:
    response = requests.post(
        'http://localhost:8080/predict',
        files={'file': f}
    )
print(response.json())
```

### API dengan JavaScript

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

## API Endpoints

### GET /

Serve HTML frontend

```bash
curl http://localhost:8080/
```

### POST /predict

Predict traffic sign dari uploaded image

**Parameters:**
- `file` (multipart/form-data): Image file

**Success Response (Traffic Sign Detected):**
```json
{
  "is_traffic_sign": true,
  "confidence": 0.87,
  "label": "STOP",
  "class_id": 73
}
```

**Success Response (Not a Traffic Sign):**
```json
{
  "is_traffic_sign": false,
  "confidence": 0.45,
  "label": null,
  "class_id": null,
  "message": "Bukan traffic sign"
}
```

**Error Response:**
```json
{
  "error": "invalid image format"
}
```

**Response Fields:**
- `is_traffic_sign`: Apakah prediksi masuk threshold 70%
- `confidence`: Confidence score 0-1
- `label`: Nama rambu lalu lintas
- `class_id`: Index kelas (0-83)
- `message`: Pesan tambahan

## Deployment

### Local Development
Sudah tercakup di section [Instalasi](#instalasi)

### Docker
Sudah tercakup di section [Instalasi](#instalasi)

### Production dengan Systemd

```bash
sudo cp uas-ai.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable uas-ai
sudo systemctl start uas-ai

# Check status
sudo systemctl status uas-ai
sudo journalctl -u uas-ai -f
```

### Monitoring dan Logs

```bash
# Local development
tail -f flask.log

# EC2 dengan systemd
sudo journalctl -u uas-ai -f

# Docker
docker logs -f traffic-sign-api
```

## Konfigurasi

### Environment Variables

| Variable | Default | Deskripsi |
|----------|---------|-----------|
| PORT | 8080 | Port Flask server |
| CONFIDENCE_THRESHOLD | 0.70 | Minimum confidence untuk valid prediction |

```bash
export PORT=5000
python API.py
```

## 84 Kelas Rambu Lalu Lintas

Model dapat mengklasifikasikan: ALL_MOTOR_VEHICLE_PROHIBITED, AXLE_LOAD_LIMIT, BARRIER_AHEAD, BULLOCK_AND_HANDCART_PROHIBITED, BULLOCK_PROHIBITED, CATTLE, COMPULSARY_AHEAD, COMPULSARY_CYCLE_TRACK, COMPULSARY_KEEP_LEFT, COMPULSARY_KEEP_RIGHT, DANGEROUS_DIP, FALLING_ROCKS, GIVE_WAY, HEIGHT_LIMIT, HUMP_OR_ROUGH_ROAD, LEFT_TURN_PROHIBITED, NO_ENTRY, NO_PARKING, NO_STOPPING_OR_STANDING, OVERTAKING_PROHIBITED, PEDESTRIAN_CROSSING, RIGHT_TURN_PROHIBITED, SLIPPERY_ROAD, SPEED_LIMIT_5, SPEED_LIMIT_15, SPEED_LIMIT_20, SPEED_LIMIT_30, SPEED_LIMIT_40, SPEED_LIMIT_50, SPEED_LIMIT_60, SPEED_LIMIT_70, SPEED_LIMIT_80, STOP, TRAFFIC_SIGNAL, dan lainnya (total 84 kelas).

Lihat file `labels.json` untuk daftar lengkap.

## Troubleshooting

### Model file not found

```bash
git lfs install
git lfs pull
```

### CUDA out of memory

```python
# Di API.py - force CPU
device = torch.device("cpu")
```

### Port already in use

```bash
lsof -i :8080
kill -9 <PID>

# Atau gunakan port berbeda
PORT=9000 python API.py
```

### Module not found error

```bash
source venv/bin/activate
pip install -r requirements.txt
```

### Application tidak accessible dari internet

Pastikan:
- EC2 security group port 8080 terbuka
- Flask running dengan `host="0.0.0.0"`
- Public IP bisa diakses

### Prediction selalu "Bukan traffic sign"

Possible causes:
- Confidence score di bawah 70%
- Image quality buruk atau blur
- Bukan rambu dari 84 kelas yang ada

Solution:
- Gunakan image berkualitas lebih baik
- Turunkan CONFIDENCE_THRESHOLD jika perlu

### CORS error di browser

CORS sudah enabled di Flask. Jika masih error:
```python
# Di API.py
CORS(app, resources={r"/*": {"origins": "*"}})
```

## Performance

- Inference time: 200ms (GPU RTX 3080), 2-3s (CPU 4 cores)
- Memory: 350MB total
- Model size: 96MB
- Concurrent requests: 100+ per instance

## Technologies

- Flask 3.1.2, PyTorch 2.9.1
- ResNet50 ImageNet1K_V2
- Pillow 12.1.0, Flask-CORS 6.0.2
- Docker, AWS EC2/AppRunner
- Systemd

## Kontribusi

1. Fork repository
2. Buat feature branch
3. Commit changes
4. Push dan buat Pull Request

## License

Proyek ini adalah untuk tujuan edukatif (UAS).

## Tim

Dikembangkan oleh Nabil Faturrahman untuk Ujian Akhir Semester.

Repository: https://github.com/nabilfaturr/uas-ai

---

**Last Updated**: Januari 2026
