#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

// --- 1. Credenciais ---
const char* ssid = "Gnitro"; 
const char* password = "12348765"; 

const char* api_key = "AIzaSyDw324gMIJ4hsgJkvWh5FURPBEBXjkq3Js";
const char* database_url = "esp32a-4d42c-default-rtdb.firebaseio.com";

// --- 2. Definição dos Pinos (Ponte H com ENA/ENB) ---
// Motor A
#define IN1 12
#define IN2 13
#define ENA 32
// Motor B
#define IN3 26
#define IN4 27
#define ENB 33

#define FAROL_PIN 2

// --- 3. Objetos Firebase e Variáveis ---
FirebaseData streamData;
FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;

int joyX = 0;
int joyY = 0;

// --- 4. Função Auxiliar: Controla UM Motor ---
// Agora recebe também o pinoEnable
void acionarMotor(int pinoIn1, int pinoIn2, int pinoEnable, int velocidade) {
  
  // 1. Controla a VELOCIDADE no pino Enable (0 a 255)
  // abs() garante que o PWM seja sempre positivo
  analogWrite(pinoEnable, abs(velocidade));

  // 2. Controla a DIREÇÃO nos pinos IN
  if (velocidade > 0) {
    // FRENTE
    digitalWrite(pinoIn1, HIGH);
    digitalWrite(pinoIn2, LOW);
  } 
  else if (velocidade < 0) {
    // TRÁS
    digitalWrite(pinoIn1, LOW);
    digitalWrite(pinoIn2, HIGH);
  } 
  else {
    // PARADO (Freio motor)
    digitalWrite(pinoIn1, LOW);
    digitalWrite(pinoIn2, LOW);
    // Garante PWM zero para não forçar o motor
    analogWrite(pinoEnable, 0); 
  }
}

// --- 5. O Misturador (Mixer com Curvas Suaves) ---
void atualizarRodas() {
  // Lógica de direção diferencial (Tank Drive)
  // Y = Aceleração | X = Curva
  int motorEsq = joyY + joyX;
  int motorDir = joyY - joyX;

  // Trava os valores entre -100 e 100
  motorEsq = constrain(motorEsq, -100, 100);
  motorDir = constrain(motorDir, -100, 100);

  // Zona Morta (Deadzone) para evitar zumbido com joystick solto
  if (abs(motorEsq) < 10) motorEsq = 0;
  if (abs(motorDir) < 10) motorDir = 0;

  // Converte escala de 100 para 255 (PWM do ESP32)
  int pwmEsq = motorEsq * 2.55;
  int pwmDir = motorDir * 2.55;

  // Envia para o hardware
  // Note que agora passamos o pino ENA e ENB
  acionarMotor(IN1, IN2, ENA, pwmEsq);
  acionarMotor(IN3, IN4, ENB, pwmDir);
}

// --- 6. Callback do Firebase ---
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
  
  // Configura todos os pinos como SAÍDA
  pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT); pinMode(ENA, OUTPUT);
  pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT); pinMode(ENB, OUTPUT);
  pinMode(FAROL_PIN, OUTPUT);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nWiFi Conectado!");

  config.api_key = api_key;
  config.database_url = database_url;
  Firebase.signUp(&config, &auth, "", "");
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  if (!Firebase.RTDB.beginStream(&streamData, "/")) {
    Serial.printf("Erro Stream: %s\n", streamData.errorReason().c_str());
  }
  Firebase.RTDB.setStreamCallback(&streamData, streamCallback, streamTimeoutCallback);
}

void loop() {
  // Loop vazio para máxima eficiência do Stream
}