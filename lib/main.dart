import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle ESP32',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ControlePage(),
    );
  }
}

class ControlePage extends StatefulWidget {
  const ControlePage({super.key});

  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
  // Referências no Firebase
  final DatabaseReference farolRef = FirebaseDatabase.instance.ref("farol");
  final DatabaseReference turboRef = FirebaseDatabase.instance.ref("turbo");
  final DatabaseReference stealthRef = FirebaseDatabase.instance.ref("stealth");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carro do Batman – Controles'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ========== FAROL ==========
            StreamBuilder(
              stream: farolRef.onValue,
              builder: (context, snapshot) {
                final data = snapshot.data?.snapshot.value;
                bool isOn = (data is bool) ? data : false;

                return _buildSmallButton(
                  title: "Farol",
                  isOn: isOn,
                  iconOn: Icons.light_mode,
                  iconOff: Icons.light_mode_outlined,
                  onPressed: () => farolRef.set(!isOn),
                );
              },
            ),

            const SizedBox(width: 20),

            // ========== TURBO ==========
            StreamBuilder(
              stream: turboRef.onValue,
              builder: (context, snapshot) {
                final data = snapshot.data?.snapshot.value;
                bool isOn = (data is bool) ? data : false;

                return _buildSmallButton(
                  title: "Turbo",
                  isOn: isOn,
                  iconOn: Icons.speed,
                  iconOff: Icons.speed_outlined,
                  onPressed: () => turboRef.set(!isOn),
                );
              },
            ),

            const SizedBox(width: 20),

            // ========== STEALTH ==========
            StreamBuilder(
              stream: stealthRef.onValue,
              builder: (context, snapshot) {
                final data = snapshot.data?.snapshot.value;
                bool isOn = (data is bool) ? data : false;

                return _buildSmallButton(
                  title: "Stealth",
                  isOn: isOn,
                  iconOn: Icons.visibility_off,
                  iconOff: Icons.visibility,
                  onPressed: () => stealthRef.set(!isOn),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET DO BOTÃO =================
  Widget _buildSmallButton({
    required String title,
    required bool isOn,
    required IconData iconOn,
    required IconData iconOff,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        backgroundColor: isOn ? Colors.red.shade100 : Colors.green.shade100,
        minimumSize: const Size(90, 90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOn ? iconOn : iconOff, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
