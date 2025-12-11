#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <ESP32Servo.h>

// --- 1. Credenciais ---
const char* ssid = "Gnitro";
const char* password = "12348765";

const char* api_key = "AIzaSyDw324gMIJ4hsgJkvWh5FURPBEBXjkq3Js";
const char* database_url = "esp32a-4d42c-default-rtdb.firebaseio.com";

// --- 2. Definição dos Pinos ---
#define IN1 12
#define IN2 13
#define ENA 32
#define IN3 26
#define IN4 27
#define ENB 33

#define FAROL_PIN 2
#define BUZZER_PIN 15
#define SERVO_PIN 4

// --- NOVO PINO: LED DA CABINE ---
#define LED_CABINE_PIN 19 

// --- PINOS SENSOR ---
#define TRIG_PIN 5
#define ECHO_PIN 18

// --- 3. Objetos Firebase e Variáveis ---
FirebaseData streamData; 
FirebaseData fbdo;       
FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false; 

Servo cockpitServo;

int joyX = 0;
int joyY = 0;

// Variáveis de Modos
bool stealthMode = false;
bool turboMode = false;
bool desiredFarolState = false;
bool ignitionState = false; 
bool cockpitState = false;

// Variáveis para o Sensor (Timer)
unsigned long previousMillis = 0;
const long interval = 2000; 

// --- 4. Função Auxiliar Motor ---
void acionarMotor(int pinoIn1, int pinoIn2, int pinoEnable, int velocidade) {
  if (velocidade > 255) velocidade = 255;
  if (velocidade < -255) velocidade = -255;

  analogWrite(pinoEnable, abs(velocidade));

  if (velocidade > 0) {
    digitalWrite(pinoIn1, HIGH); digitalWrite(pinoIn2, LOW);
  } else if (velocidade < 0) {
    digitalWrite(pinoIn1, LOW); digitalWrite(pinoIn2, HIGH);
  } else {
    digitalWrite(pinoIn1, LOW); digitalWrite(pinoIn2, LOW);
    analogWrite(pinoEnable, 0);
  }
}

// --- 5. O Misturador ---
void atualizarRodas() {
  if (!ignitionState) {
    acionarMotor(IN1, IN2, ENA, 0);
    acionarMotor(IN3, IN4, ENB, 0);
    return; 
  }

  int motorEsq = joyY - joyX;
  int motorDir = joyY + joyX;

  motorEsq = constrain(motorEsq, -100, 100);
  motorDir = constrain(motorDir, -100, 100);

  if (abs(motorEsq) < 10) motorEsq = 0;
  if (abs(motorDir) < 10) motorDir = 0;

  float factor;
  if (stealthMode) factor = 0.765f;      // 30%
  else if (turboMode) factor = 2.55f;    // 100%
  else factor = 1.275f;                  // 50%

  int pwmEsq = (int)(motorEsq * factor);
  int pwmDir = (int)(motorDir * factor);

  pwmEsq = constrain(pwmEsq, -255, 255);
  pwmDir = constrain(pwmDir, -255, 255);

  acionarMotor(IN1, IN2, ENA, pwmEsq);
  acionarMotor(IN3, IN4, ENB, pwmDir);
}

// --- 6. Controle de Periféricos ---
void applyFarolState() {
  if (stealthMode) {
    digitalWrite(FAROL_PIN, LOW);
  } else {
    digitalWrite(FAROL_PIN, desiredFarolState ? HIGH : LOW);
  }
}

void updateBuzzerState() {
  if (stealthMode || !ignitionState) {
    noTone(BUZZER_PIN);
    return;
  }
  if (turboMode) tone(BUZZER_PIN, 2000); 
  else noTone(BUZZER_PIN);
}

// --- LÓGICA DO SERVO E DO LED DA CABINE ---
void applyCockpitState() {
  // Garante conexão
  if (!cockpitServo.attached()) {
    cockpitServo.attach(SERVO_PIN, 500, 2400);
  }

  if (cockpitState) {
    // Se TRUE: Abre a cabine e acende o LED
    cockpitServo.write(90); 
    digitalWrite(LED_CABINE_PIN, HIGH); 
  } else {
    // Se FALSE: Fecha a cabine e apaga o LED
    cockpitServo.write(0);  
    digitalWrite(LED_CABINE_PIN, LOW);
  }
}

// --- 7. Função de Leitura do Sensor ---
int lerDistanciaCM() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH);
  int distance = duration * 0.034 / 2;
  return distance;
}

// --- 8. Callback do Firebase ---
void streamCallback(FirebaseStream data) {
  String caminho = data.dataPath();
  String tipo = data.dataType();

  if (caminho == "/farol") {
     if (tipo == "boolean") {
       desiredFarolState = data.boolData();
       applyFarolState();
     }
  } 
  else if (caminho == "/joystickX") {
      joyX = data.intData();
      atualizarRodas();
  } 
  else if (caminho == "/joystickY") {
      joyY = data.intData();
      atualizarRodas();
  }
  else if (caminho == "/stealth") {
      stealthMode = data.boolData();
      applyFarolState();
      updateBuzzerState();
      atualizarRodas(); 
  }
  else if (caminho == "/turbo") {
      turboMode = data.boolData();
      updateBuzzerState();
      atualizarRodas();
  }
  else if (caminho == "/ignicao") {
      ignitionState = data.boolData();
      atualizarRodas();
      updateBuzzerState();
  }
  else if (caminho == "/cockpit") {
      cockpitState = data.boolData();
      applyCockpitState();
  }
}

void streamTimeoutCallback(bool timeout) {
  if(timeout) Serial.println("Stream Timeout...");
}

void setup() {
  Serial.begin(115200);

  pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT); pinMode(ENA, OUTPUT);
  pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT); pinMode(ENB, OUTPUT);
  pinMode(FAROL_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Configuração LED Cabine
  pinMode(LED_CABINE_PIN, OUTPUT);
  digitalWrite(LED_CABINE_PIN, LOW); // Começa apagado

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Inicializa o servo
  cockpitServo.setPeriodHertz(50);
  cockpitServo.attach(SERVO_PIN, 500, 2400); 
  cockpitServo.write(0);
  
  // Estado inicial
  digitalWrite(IN1, LOW); digitalWrite(IN2, LOW); analogWrite(ENA, 0);
  digitalWrite(IN3, LOW); digitalWrite(IN4, LOW); analogWrite(ENB, 0);
  digitalWrite(FAROL_PIN, LOW);
  noTone(BUZZER_PIN);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nWiFi Conectado!");

  config.api_key = api_key;
  config.database_url = database_url;
  Firebase.signUp(&config, &auth, "", "");
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Conectando ao Firebase...");
  long t = millis();
  while (!Firebase.ready() && millis() - t < 10000) {
    delay(100);
  }
  if (Firebase.ready()) {
    signupOK = true;
    Serial.println("Firebase Pronto!");
  } else {
    Serial.println("Falha Firebase");
  }

  if (!Firebase.RTDB.beginStream(&streamData, "/")) {
    Serial.printf("Erro Stream: %s\n", streamData.errorReason().c_str());
  }
  Firebase.RTDB.setStreamCallback(&streamData, streamCallback, streamTimeoutCallback);
}

void loop() {
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    int dist = lerDistanciaCM();
    
    if (Firebase.ready() && signupOK) { 
       if (!Firebase.RTDB.setIntAsync(&fbdo, "/distancia", dist)) {
          // Erro silencioso
       }
    }
  }
  delay(10);
}