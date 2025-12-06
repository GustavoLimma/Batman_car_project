import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final farolRef = FirebaseDatabase.instance.ref("farol");
  static final turboRef = FirebaseDatabase.instance.ref("turbo");
  static final stealthRef = FirebaseDatabase.instance.ref("stealth");
}
