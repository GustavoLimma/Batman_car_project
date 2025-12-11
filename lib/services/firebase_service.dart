import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final farolRef = FirebaseDatabase.instance.ref("farol");
  static final turboRef = FirebaseDatabase.instance.ref("turbo");
  static final stealthRef = FirebaseDatabase.instance.ref("stealth");
  
  // Referencias para navegacao autonoma
  static final destinoXRef = FirebaseDatabase.instance.ref("destinoX");
  static final destinoYRef = FirebaseDatabase.instance.ref("destinoY");
  static final modoDirecaoRef = FirebaseDatabase.instance.ref("modoDirecao");
  static final cockpitRef = FirebaseDatabase.instance.ref("cockpit");

  // Referencias para motores (Joystick e Comando de Voz)
  static final motorDireitoRef = FirebaseDatabase.instance.ref("motorDireito");
  static final motorEsquerdoRef = FirebaseDatabase.instance.ref("motorEsquerdo");
}
