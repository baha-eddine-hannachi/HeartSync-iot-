#include <TensorFlowLite_ESP32.h>
#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include <WiFi.h>
#include <FirebaseESP32.h> 

// Include your generated model file
#include "model.h"

// ========== WiFi Credentials ==========
const char* ssid = "";           
const char* password = "";           

// ========== Firebase Credentials ==========
#define FIREBASE_HOST ""
#define FIREBASE_AUTH ""

// ========== Hardware & Sensor Setup ==========
const int PULSE_PIN = 32;
const int SAMPLE_DELAY_MS = 20; // 50 Hz sampling rate

// ========== Timing Variables ==========
unsigned long lastSampleTime = 0; 
unsigned long lastSendTime = 0;
const unsigned long SEND_INTERVAL = 5000; // Send data every 5 seconds

// ========== BPM Tracking Variables ==========
const int bufferSize = 10;
int readings[bufferSize];
int readIndex = 0;
int total = 0;
int filteredValue = 0;

int dynamicThreshold = 2000;
unsigned long lastThresholdTime = 0;
int maxSignal = 0;
int minSignal = 4095;

unsigned long lastBeatTime = 0;
float currentBPM = 0.0;
bool isBeat = false;

// ========== TFLite Globals ==========
tflite::ErrorReporter* error_reporter = nullptr;
const tflite::Model* tflite_model = nullptr;
tflite::MicroInterpreter* interpreter = nullptr;
TfLiteTensor* input = nullptr;
TfLiteTensor* output = nullptr;

constexpr int kTensorArenaSize = 15 * 1024;
uint8_t tensor_arena[kTensorArenaSize];

int samples_read = 0;
int expected_samples = 0;

// ========== Firebase Setup ==========
// Updated to match the Mobizt library requirements
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

// ========== Data Structure for Firebase ==========
struct HeartData {
  float bpm;
  float confidence;
  String prediction;
  long timestamp;
};

// ========== Function Prototypes ==========
void connectToWiFi();
void initializeFirebase();
void sendToRealtimeDatabase(HeartData data);

void setup() {
  Serial.begin(115200);
  delay(1000);

  analogReadResolution(12);
  for (int i = 0; i < bufferSize; i++) readings[i] = 0;

  Serial.println("\n=== ESP32 PPG Inference with Firebase ===");
  
  Serial.println("Connecting to WiFi...");
  connectToWiFi();
  
  Serial.println("Initializing Firebase...");
  initializeFirebase();

  Serial.println("Initializing TensorFlow Lite Micro...");
//chargement du model
  static tflite::MicroErrorReporter micro_error_reporter;
  error_reporter = &micro_error_reporter;

  tflite_model = tflite::GetModel(model);
  if (tflite_model->version() != TFLITE_SCHEMA_VERSION) {
    Serial.println("Model schema version mismatch!");
    while (1);
  }

  static tflite::AllOpsResolver resolver;
  static tflite::MicroInterpreter static_interpreter(
      tflite_model, resolver, tensor_arena, kTensorArenaSize, error_reporter);
  interpreter = &static_interpreter;

  if (interpreter->AllocateTensors() != kTfLiteOk) {
    Serial.println("AllocateTensors() failed!");
    while (1);
  }

  input = interpreter->input(0);
  output = interpreter->output(0);
  expected_samples = input->bytes / sizeof(int8_t);

  Serial.print("✓ Model loaded! Expected features: ");
  Serial.println(expected_samples);
  Serial.println("Starting sensor reads...");
}

void loop() {
  unsigned long currentMillis = millis();

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected! Reconnecting...");
    connectToWiFi();
  }

  if (currentMillis - lastSampleTime >= SAMPLE_DELAY_MS) {
    lastSampleTime = currentMillis; // Reset the timer

    // 1. Read sensor
    int raw_value = analogRead(PULSE_PIN);

    // 2. Apply moving average filter
    total = total - readings[readIndex];
    readings[readIndex] = raw_value;
    total = total + readings[readIndex];
    readIndex = (readIndex + 1) % bufferSize;
    filteredValue = total / bufferSize;

    if (currentMillis - lastThresholdTime > 2000) {
      dynamicThreshold = (maxSignal + minSignal) / 2;
      maxSignal = 0;
      minSignal = 4095;
      lastThresholdTime = currentMillis;
    } else {
      if (filteredValue > maxSignal) maxSignal = filteredValue;
      if (filteredValue < minSignal) minSignal = filteredValue;
    }

    // 4. Calculate BPM
    if (filteredValue > dynamicThreshold && !isBeat) {
      unsigned long timeDelta = currentMillis - lastBeatTime;
      if (timeDelta > 300 && timeDelta < 1500) {
        currentBPM = 60000.0 / timeDelta;
      }
      lastBeatTime = currentMillis;
      isBeat = true;
    } else if (filteredValue < dynamicThreshold - 50 && isBeat) {
      isBeat = false;
    }

    // 5. Run AI Model
    float normalized_value = (float)raw_value / 4095.0;
    int8_t quantized_input = (normalized_value / input->params.scale) + input->params.zero_point;
    input->data.int8[samples_read] = quantized_input;
    samples_read++;

    // 6. Inference (when window is full)
    if (samples_read >= expected_samples) {
      if (interpreter->Invoke() != kTfLiteOk) {
        Serial.println("Inference failed!");
        return;
      }

      int8_t quantized_output = output->data.int8[0];
      float output_val = (quantized_output - output->params.zero_point) * output->params.scale;

      // Print locally
      Serial.print("Prediction: ");
      String prediction = (output_val < 0.5) ? "ABNORMAL" : "NORMAL";
      Serial.print(prediction);
      Serial.print(" (Conf: ");
      Serial.print(output_val, 4);
      Serial.print(") | BPM: ");
      Serial.println(currentBPM, 1);

      // 7. Send to Firebase every 5 seconds
      if (currentMillis - lastSendTime > SEND_INTERVAL) {
        HeartData data;
        data.bpm = currentBPM;
        data.confidence = output_val;
        data.prediction = prediction;
        data.timestamp = currentMillis;

        sendToRealtimeDatabase(data);
        lastSendTime = currentMillis; // Reset Firebase timer
      }

      samples_read = 0; // Reset tensor collection window
    }
  }
}

// ========== Helper Functions ==========

void connectToWiFi() {
  WiFi.begin(ssid, password);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✓ WiFi Connected!");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n WiFi Connection Failed!");
  }
}

void initializeFirebase() {
  // Updated initialization syntax for Mobizt library
  config.database_url = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Serial.println(" Firebase initialized!");
}

void sendToRealtimeDatabase(HeartData data) {
  String path = "/users/user001/heart_data"; // Change "user001" to your user ID if desired
  
  FirebaseJson json;
  json.set("bpm", data.bpm);
  json.set("confidence", data.confidence);
  json.set("prediction", data.prediction);
  json.set("timestamp", data.timestamp);
  
  if (Firebase.pushJSON(firebaseData, path, json)) {
    Serial.println("✓ Data sent to Firebase!");
  } else {
    Serial.print("✗ Firebase Error: ");
    Serial.println(firebaseData.errorReason());
  }
}