<div align="center">

<img src="https://img.shields.io/badge/HeartSync-Pro-red?style=for-the-badge&logo=heart&logoColor=white" alt="HeartSync"/>

# 🫀 HeartSync — Intelligent Real-Time Cardiac Monitoring

**TinyML · ESP32 · Firebase · Flutter · ReactJS**

[![TinyML](https://img.shields.io/badge/TinyML-TFLite_INT8-orange?style=flat-square&logo=tensorflow)](https://www.tensorflow.org/lite)
[![ESP32](https://img.shields.io/badge/MCU-ESP32_240MHz-blue?style=flat-square)](https://www.espressif.com/)
[![Firebase](https://img.shields.io/badge/Cloud-Firebase-yellow?style=flat-square&logo=firebase)](https://firebase.google.com/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter_Android-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![React](https://img.shields.io/badge/Web-ReactJS-61DAFB?style=flat-square&logo=react)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![PFA](https://img.shields.io/badge/PFA-2025--2026-purple?style=flat-square)](.)

<br/>

> **HeartSync** is a complete IoT + AI cardiac monitoring system that detects arrhythmias in **12ms** directly on an ESP32 microcontroller — no cloud inference required.

<br/>

[Features](#-features) · [Architecture](#-architecture) · [AI Model](#-ai-model) · [Setup](#-getting-started) · [Results](#-results) · [Team](#-team)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Hardware](#-hardware)
- [AI Model](#-ai-model)
- [Firebase Structure](#-firebase-structure)
- [Mobile App — Flutter](#-mobile-app--flutter)
- [Web Dashboard — ReactJS](#-web-dashboard--reactjs)
- [Getting Started](#-getting-started)
- [Results & Performance](#-results--performance)
- [Project Structure](#-project-structure)
- [Security](#-security)
- [Future Work](#-future-work)
- [Team](#-team)
- [License](#-license)

---

## 🌟 Overview

Cardiovascular diseases are the **#1 cause of death worldwide** (WHO). HeartSync addresses the gap between expensive hospital Holter monitors and simple, non-intelligent pulse oximeters.

HeartSync is a **portable, intelligent, and low-cost** cardiac monitoring system that:

- Continuously acquires PPG signals via the **SEN-11574** optical sensor
- Classifies heart rhythm (**NORMAL / ABNORMAL**) in real time using a **TinyML model on ESP32**
- Streams results to **Firebase Realtime Database** every 5 seconds
- Displays live data on a **Flutter mobile app** (patient-facing)
- Gives doctors a full **ReactJS dashboard** to supervise all patients

---

## ✨ Features

| Feature | Status |
|---|---|
| Continuous PPG acquisition at 50 Hz | ✅ Done |
| Adaptive threshold BPM detection | ✅ Done |
| On-device TinyML inference (12 ms) | ✅ Done |
| Firebase Realtime sync | ✅ Done |
| Flutter app with Firebase Auth | ✅ Done |
| Live ECG animation synced to BPM | ✅ Done |
| NORMAL / ABNORMAL color alerts | ✅ Done |
| Doctor ReactJS dashboard | ✅ Done |
| BPM history chart (Recharts) | ✅ Done |
| ECG Simulator (web) | ✅ Done |
| Push notifications on anomaly | 🔜 Planned |
| Battery-powered portable device | 🔜 Planned |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    HeartSync System                     │
│                                                         │
│  ┌──────────────┐    ┌──────────────────────────────┐  │
│  │  SEN-11574   │───▶│          ESP32               │  │
│  │  PPG Sensor  │    │  ┌────────────────────────┐  │  │
│  │  (Optical IR)│    │  │  TinyML INT8 Model     │  │  │
│  └──────────────┘    │  │  Accuracy > 97%        │  │  │
│                      │  │  Latency : 12 ms       │  │  │
│                      │  └────────────────────────┘  │  │
│                      └──────────────┬───────────────┘  │
│                                     │ WiFi / HTTPS      │
│                      ┌──────────────▼───────────────┐  │
│                      │    Firebase Realtime DB       │  │
│                      │    /users/{uid}/heart_data    │  │
│                      └──────┬───────────────┬────────┘  │
│                             │               │           │
│                    ┌────────▼──┐    ┌───────▼────────┐ │
│                    │  Flutter  │    │   ReactJS      │ │
│                    │  Patient  │    │  Doctor Dash   │ │
│                    │   App     │    │                │ │
│                    └───────────┘    └────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Hardware

| Component | Role | Specs |
|---|---|---|
| **ESP32** | Main microcontroller | Dual-core 240 MHz, 520 KB RAM, WiFi |
| **SEN-11574** (SparkFun) | PPG optical sensor | IR reflective, analog output, 3.3V–5V |
| **USB Cable** | Power supply | 5V via USB port |

**Acquisition parameters:**

| Parameter | Value |
|---|---|
| Sampling frequency | 50 Hz (every 20 ms) |
| ADC resolution | 12-bit (0–4095) |
| Reading pin | GPIO 32 (ADC1_CH4) |
| Moving average buffer | 10 samples |
| Firebase send interval | 5 seconds |

---

## 🤖 AI Model

### Dataset — PPG-DaLiA

The model was trained on the **PPG-DaLiA** dataset, a widely-used benchmark of photoplethysmography signals:

- **Class 0 — ABNORMAL**: Irregular heart rhythm (arrhythmia, tachycardia, bradycardia)
- **Class 1 — NORMAL**: Normal sinus rhythm
- **Train set**: 43,215 samples · **Test set**: 21,482 samples
- **Class balance**: ~49% / 51% (no class imbalance)
- **Window size**: 511 time points per sample

### Neural Network Architecture

```
Input (511 features)
        │
   Dense(64, ReLU)
        │
   Dropout(0.30)
        │
   Dense(32, ReLU)
        │
   Dropout(0.20)
        │
   Dense(16, ReLU)
        │
   Dense(1, Sigmoid)
        │
   Output: NORMAL / ABNORMAL
```

**Total parameters: 35,393 (138.25 KB)**

### Training Configuration

| Parameter | Value |
|---|---|
| Optimizer | Adam (lr = 0.001) |
| Loss function | Binary Crossentropy |
| Max epochs | 30 (Early Stopping, patience = 5) |
| Batch size | 32 |
| Validation split | 15% of training set |

### Performance

| Metric | Value |
|---|---|
| **Accuracy** | **> 97%** |
| **F1-Score** | **> 0.97** |
| Inference latency (ESP32) | ≈ 12 ms |
| TFLite INT8 model size | < 100 KB |

> **Why Dense NN over LSTM/CNN?**  
> The ESP32 has only 520 KB RAM. An equivalent LSTM would be 3–5× larger and exceed the latency budget. The Dense NN processes a pre-windowed 511-point feature vector, where temporal structure is captured implicitly in the window shape — making it both accurate and hardware-compatible.

### TFLite Conversion & INT8 Quantization

The Keras model is converted to TFLite with **full INT8 quantization**, providing:
- 4× model size reduction vs float32
- Faster inference on microcontroller
- Compatibility with TensorFlow Lite Micro for ESP32

The quantized model is exported as a C header file (`model.h`) for direct integration into the Arduino firmware.

---

## 🔥 Firebase Structure

```
heartsync-01-default-rtdb.firebaseio.com/
└── users/
    └── {uid}/
        ├── profile/          ← user information
        └── heart_data/
            └── {pushKey}/
                ├── bpm         (float)  — heart rate in BPM
                ├── prediction  (string) — "NORMAL" or "ABNORMAL"
                ├── confidence  (float)  — confidence score 0.0–1.0
                └── timestamp   (long)   — ms since device boot
```

**Security rules** (production-ready):
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read":  "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

---

## 📱 Mobile App — Flutter

### Structure

| File | Role |
|---|---|
| `main.dart` | Entry point, Firebase init, auth routing |
| `login.dart` | Email/password login screen |
| `register.dart` | Registration screen |
| `home.dart` | Main dashboard with bottom navigation |
| `ecg.dart` | Animated ECG visualization synced to real BPM |
| `alert.dart` | Alert page with medical advice |

### Key Features

- **Monitor tab** — Live BPM, prediction status, confidence score
- **ECG tab** — Animated ECG curve whose speed matches the real BPM
- **Alerts tab** — Contextual medical advice based on prediction
- Background color switches automatically: **white** for NORMAL, **red** for ABNORMAL
- Real-time sync via `onChildAdded` + `onChildChanged` Firebase listeners

### Dependencies

```yaml
firebase_core: ^3.1.0
firebase_auth: ^5.1.0
firebase_database: ^11.1.0
```

---

## 🖥 Web Dashboard — ReactJS

A doctor-facing dashboard built with ReactJS, connected directly to Firebase Realtime Database.

### Pages

**Page 1 — Patient Dashboard**
- Total monitored patients count
- Normal / Abnormal patient counts
- Live patient table: ID, BPM, status, confidence, last detection time

**Page 2 — Alerts & History**
- BPM evolution chart (Recharts LineChart) per patient
- Full history table with date/time, BPM, status, confidence
- Interactive ECG Simulator driven by real Firebase BPM

### Tech Stack

| Technology | Role |
|---|---|
| ReactJS | Frontend framework |
| Firebase Realtime DB | Real-time data source (onValue listener) |
| Firebase Auth | Doctor authentication (Dr. admin) |
| Recharts | BPM evolution chart |
| Custom CSS | HeartSync red/white branding |

### Role Separation

> Only the doctor account (`Dr. admin`) has read access to the entire `/users` node. Patients can only access their own data via the Flutter app — ensuring medical data confidentiality.

---

## 🚀 Getting Started

### Prerequisites

- Arduino IDE with ESP32 board support
- Python 3.9+ (for training notebook)
- Flutter SDK
- Node.js + npm (for React dashboard)
- Firebase project (Realtime Database + Authentication enabled)

### 1. ESP32 Firmware

```bash
# Open in Arduino IDE
ESP32_Firebase_Integration.ino

# Required libraries (install via Arduino Library Manager)
- TensorFlowLite_ESP32
- FirebaseESP32 (by Mobizt)
- WiFi.h (built-in)
```

Create a `secrets.h` file (excluded from Git):
```cpp
#define WIFI_SSID     "your_wifi_ssid"
#define WIFI_PASSWORD "your_wifi_password"
#define FIREBASE_HOST "your-project.firebaseio.com"
#define FIREBASE_AUTH "your_firebase_database_secret"
```

### 2. AI Model Training (Google Colab)

```bash
# Open the training notebook
ESP32_TS_COMPATIBLE.ipynb

# Place your dataset files in Colab
PPGDalia_TRAIN.ts
PPGDalia_TEST.ts

# Run all cells — outputs:
# model_esp32.tflite
# model.h  ← copy this into your Arduino sketch folder
```

### 3. Flutter App

```bash
cd flutter_app/
flutter pub get
flutter run
```
<img width="1080" height="2400" alt="image" src="https://github.com/user-attachments/assets/4384cf9a-6dd9-4d60-a487-ada3061816aa" />
<img width="1080" height="2400" alt="image" src="https://github.com/user-attachments/assets/5cf75f57-557b-4f55-9cfb-f126a9e84ad1" />
<img width="1080" height="2400" alt="image" src="https://github.com/user-attachments/assets/36b5893e-a2ac-4bdd-9d6c-5ec8a001d3bc" />
<img width="1080" height="2400" alt="image" src="https://github.com/user-attachments/assets/180be1c2-963c-44c9-9a26-86de8f27ab26" />
<img width="1080" height="2400" alt="image" src="https://github.com/user-attachments/assets/9e635fdf-9c49-49a3-a983-1523cb4de61a" />






### 4. ReactJS Dashboard

```bash
cd web_dashboard/
npm install
npm start
# Open http://localhost:3000




```
<img width="1895" height="871" alt="image" src="https://github.com/user-attachments/assets/d16cb76d-0876-4f52-811c-b8b9e4f26477" />
<img width="1897" height="870" alt="image" src="https://github.com/user-attachments/assets/5feffb43-775a-480c-bddd-88c89c27930e" />
<img width="1897" height="861" alt="image" src="https://github.com/user-attachments/assets/48326989-857d-4300-9790-087611aad840" />
<img width="1879" height="861" alt="image" src="https://github.com/user-attachments/assets/03172b16-1f31-4d07-8b42-dc125ff56c1d" />

---

## 📊 Results & Performance

| Criterion | Value |
|---|---|
| Classification accuracy | **> 97%** |
| F1-Score | **> 0.97** |
| ESP32 inference latency | **≈ 12 ms** |
| Firebase sync latency | **< 2 seconds** |
| Embedded model size | **< 100 KB** |
| App update frequency | Every 5 seconds |
| Mobile platform | Android (Flutter) |

---

## 📁 Project Structure

```
HeartSync/
├── firmware/
│   ├── ESP32_Firebase_Integration.ino   # Main ESP32 firmware
│   ├── model.h                          # TFLite model as C header
│   └── secrets.h                        # WiFi & Firebase credentials (gitignored)
│
├── ml/
│   ├── ESP32_TS_COMPATIBLE.ipynb        # Training notebook (Google Colab)
│   └── model_esp32.tflite               # TFLite binary model
│
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── login.dart
│   │   ├── register.dart
│   │   ├── home.dart
│   │   ├── ecg.dart
│   │   └── alert.dart
│   └── pubspec.yaml
│
├── web_dashboard/
│   ├── src/
│   │   ├── App.js
│   │   ├── pages/
│   │   │   ├── Patients.jsx
│   │   │   ├── Alerts.jsx
│   │   │   └── ECGSimulator.jsx
│   │   └── firebase.js
│   └── package.json
│
└── README.md
```

---

## 🔒 Security

| Measure | Status | Description |
|---|---|---|
| Firebase Authentication | ✅ Active | Email + Password login |
| HTTPS | ✅ Active | All communications encrypted |
| Firebase Rules (UID-based) | ✅ Active | Users access only their own data |
| `secrets.h` excluded from Git | ⚠️ Recommended | Add to `.gitignore` |
| Data encryption at rest | 🔜 Production | Encrypt before Firebase storage |
| Push medical notifications | 🔜 Planned | Alert on anomaly detection |


```

---

## 🔮 Future Work

- [ ] Stream raw ECG data to Firebase for richer visualization
- [ ] Push notifications on abnormal detection
- [ ] BPM history graphs in the Flutter app
- [ ] Extend model to detect multiple arrhythmia subtypes
- [ ] Validate model on real SEN-11574 sensor data
- [ ] Add lithium battery for full portability
- [ ] GDPR-compliant data handling for production deployment

---

## 👥 Team

| Name | Role |
|---|---|
| [baha eddine hannachi] | IoT Firmware · TinyML · Firebase |
| [baha eddine hannachi] | Flutter Mobile App |
| [ayoub ebdelli] | ReactJS Dashboard |

**Supervisor:** [Dr. Eng. Mohamed Ould-Elhassen Aoueileyine]  
**Institution:** [Your Institution]  
**Academic Year:** 2025 – 2026

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---


