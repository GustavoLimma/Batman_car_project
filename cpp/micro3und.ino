#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

// --- 1. Credenciais ---
const char* ssid = "Gnitro"; 
const char* password = "12348765"; 

const char* api_key = "AIzaSyDw324gMIJ4hsgJkvWh5FURPBEBXjkq3Js";
const char* database_url = "esp32a-4d42c-default-rtdb.firebaseio.com";

// --- 2. Definição dos Pinos (Ponte H com ENA/ENB) ---
#define IN1 12
#define IN2 13
#define ENA 32
#define IN3 26
#define IN4 27
#define ENB 33

#define FAROL_PIN 2

// --- Sensor Ultrassônico ---
#define TRIG 4
#define ECHO 5   // Passa pelo divisor 1k + 2k Para ligar o sensor na ESP32 com segurança, conectamos o pino ECHO ao GPIO passando por um resistor de 1k, e do ponto intermediário ligamos um resistor de 2k ao GND, formando um divisor de tensão que reduz os 5V para cerca de 3.3V.

// --- 3. Objetos Firebase e Variáveis ---
FirebaseData streamData;
FirebaseAuth auth;
FirebaseConfig config;

int joyX = 0;
int joyY = 0;

// --- Controle do tempo para medir distância ---
unsigned long ultimaMedicao = 0;
const unsigned long intervaloMedicao = 200; // 200ms

// --- Função do Ultrassônico ---
long medirDistancia() {
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);

  long duracao = pulseIn(ECHO, HIGH, 30000); // timeout 30ms
  long distancia = duracao * 0.034 / 2;

  return distancia; 
}

// --- Controle dos motores ---
void acionarMotor(int pinoIn1, int pinoIn2, int pinoEnable, int velocidade) {
  analogWrite(pinoEnable, abs(velocidade));

  if (velocidade > 0) {
    digitalWrite(pinoIn1, HIGH);
    digitalWrite(pinoIn2, LOW);
  } 
  else if (velocidade < 0) {
    digitalWrite(pinoIn1, LOW);
    digitalWrite(pinoIn2, HIGH);
  } 
  else {
    digitalWrite(pinoIn1, LOW);
    digitalWrite(pinoIn2, LOW);
    analogWrite(pinoEnable, 0); 
  }
}

void atualizarRodas() {
  int motorEsq = joyY + joyX;
  int motorDir = joyY - joyX;

  motorEsq = constrain(motorEsq, -100, 100);
  motorDir = constrain(motorDir, -100, 100);

  if (abs(motorEsq) < 10) motorEsq = 0;
  if (abs(motorDir) < 10) motorDir = 0;

  int pwmEsq = motorEsq * 2.55;
  int pwmDir = motorDir * 2.55;

  acionarMotor(IN1, IN2, ENA, pwmEsq);
  acionarMotor(IN3, IN4, ENB, pwmDir);
}

// --- Callback do Firebase ---
void streamCallback(FirebaseStream data) {
  String caminho = data.dataPath();
  String tipo = data.dataType();

  if (caminho == "/farol") {
     if (tipo == "boolean") digitalWrite(FAROL_PIN, data.boolData());
  } 
  else if (caminho == "/joystickX") {
    if (tipo == "int" || tipo == "float") {
      joyX = data.intData();
      atualizarRodas();
    }
  } 
  else if (caminho == "/joystickY") {
    if (tipo == "int" || tipo == "float") {
      joyY = data.intData();
      atualizarRodas();
    }
  }
}

void streamTimeoutCallback(bool timeout) {
  if(timeout) Serial.println("Stream Timeout - Reconectando...");
}

void setup() {
  Serial.begin(115200);
  
  pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT); pinMode(ENA, OUTPUT);
  pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT); pinMode(ENB, OUTPUT);
  pinMode(FAROL_PIN, OUTPUT);

  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { Serial.print("."); }

  config.api_key = api_key;
  config.database_url = database_url;
  Firebase.signUp(&config, &auth, "", "");
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Firebase.RTDB.beginStream(&streamData, "/");
  Firebase.RTDB.setStreamCallback(&streamData, streamCallback, streamTimeoutCallback);
}

void loop() {

  // --- MEDIÇÃO COM millis() ---
  unsigned long agora = millis();

  if (agora - ultimaMedicao >= intervaloMedicao) {
    ultimaMedicao = agora;

    long d = medirDistancia();
    Firebase.RTDB.setInt(&streamData, "/distancia", d);

    Serial.print("Distancia: ");
    Serial.print(d);
    Serial.println(" cm");
  }

  // loop sempre livre → Firebase Stream fica rápido
}