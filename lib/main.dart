import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com os dados que você forneceu
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDw324gMIJ4hsgJkvWh5FURPBEBXjkq3Js",
      appId: "1:856004869950:web:1a56fab0566c844c8ff66f",
      messagingSenderId: "856004869950",
      projectId: "esp32a-4d42c",
      // Necessário especificar a URL do Database manualmente aqui
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
      home: const LedControllerPage(),
    );
  }
}

class LedControllerPage extends StatefulWidget {
  const LedControllerPage({super.key});

  @override
  State<LedControllerPage> createState() => _LedControllerPageState();
}

class _LedControllerPageState extends State<LedControllerPage> {
  // Referência para o caminho "/led" no banco de dados
  final DatabaseReference _ledRef = FirebaseDatabase.instance.ref("led");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle ESP32'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: StreamBuilder(
          // Ouve as mudanças no banco de dados em tempo real
          stream: _ledRef.onValue,
          builder: (context, snapshot) {
            // Verifica se está carregando ou se tem erro
            if (snapshot.hasError) {
              return const Text('Erro de conexão');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // Pega o valor atual (true ou false). Se for nulo, assume false.
            final data = snapshot.data?.snapshot.value;
            bool isLedOn = (data is bool) ? data : false;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb,
                  size: 100,
                  color: isLedOn ? Colors.yellow : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  isLedOn ? "O LED está LIGADO" : "O LED está DESLIGADO",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    // Inverte o valor e envia para o Firebase
                    _ledRef.set(!isLedOn);
                  },
                  icon: Icon(isLedOn ? Icons.power_off : Icons.power),
                  label: Text(
                    isLedOn ? "DESLIGAR" : "LIGAR",
                    style: const TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: isLedOn ? Colors.red.shade100 : Colors.green.shade100,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}