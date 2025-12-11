import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final farolRef = FirebaseDatabase.instance.ref("farol");
  static final turboRef = FirebaseDatabase.instance.ref("turbo");
  static final stealthRef = FirebaseDatabase.instance.ref("stealth");
  static final cockpitRef = FirebaseDatabase.instance.ref("cockpit");
  static final ignicaoRef = FirebaseDatabase.instance.ref("ignicao");
  
  // Leitura de Sensores
  static final distanciaRef = FirebaseDatabase.instance.ref("distancia");
  
  // Referencias para navegacao autonoma
  static final destinoXRef = FirebaseDatabase.instance.ref("destinoX");
  static final destinoYRef = FirebaseDatabase.instance.ref("destinoY");
  static final modoDirecaoRef = FirebaseDatabase.instance.ref("modoDirecao");
  
  static final joystickXRef = FirebaseDatabase.instance.ref("joystickX");
  static final joystickYRef = FirebaseDatabase.instance.ref("joystickY");

  // Referencias para motores (Joystick e Comando de Voz)
  static final motorDireitoRef = FirebaseDatabase.instance.ref("motorDireito");
  static final motorEsquerdoRef = FirebaseDatabase.instance.ref("motorEsquerdo");
}
