import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDw324gMIJ4hsgJkvWh5FURPBEBXjkq3Js",
      appId: "1:856004869950:web:1a56fab0566c844c8ff66f",
      messagingSenderId: "856004869950",
      projectId: "esp32a-4d42c",
      databaseURL: "https://esp32a-4d42c-default-rtdb.firebaseio.com",
    ),
  );

  runApp(const MyApp());
}
