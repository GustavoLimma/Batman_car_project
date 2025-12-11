import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/firebase_service.dart';
import '../widgets/joystick_widget.dart';
import 'map_page.dart';

class ControlePage extends StatefulWidget {
  const ControlePage({super.key});

  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Pressione o microfone para falar';
  
  // Cores
  static const Color primaryColor = Color(0xFFF2D00D);
  static const Color backgroundDark = Color(0xFF221F10);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
           if (val == 'done' || val == 'notListening') {
             setState(() => _isListening = false);
           }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
              if (val.finalResult) {
                _processVoiceCommand(_text);
              }
            });
          },
          localeId: 'pt_BR',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processVoiceCommand(String command) {
    String cmd = command.toLowerCase();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Comando reconhecido: $cmd"), 
        duration: const Duration(milliseconds: 1500),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      )
    );

    // Lógica para Farol
    if (cmd.contains("farol") || cmd.contains("luz")) {
       if (cmd.contains("ligar") || cmd.contains("acender") || cmd.contains("ativar")) {
          FirebaseService.farolRef.set(true);
       } else if (cmd.contains("desligar") || cmd.contains("apagar") || cmd.contains("desativar")) {
          FirebaseService.farolRef.set(false);
       }
    }

    // Lógica para Stealth (melhorado para capturar variações fonéticas comuns se necessário, mas focado na palavra chave)
    if (cmd.contains("stealth") || cmd.contains("stelt") || cmd.contains("estel")) {
       if (cmd.contains("ativar") || cmd.contains("modo") || cmd.contains("ligar")) {
          FirebaseService.stealthRef.set(true);
          FirebaseService.turboRef.set(false);
          FirebaseService.farolRef.set(false);
       } else if (cmd.contains("desativar") || cmd.contains("desligar")) {
          FirebaseService.stealthRef.set(false);
       }
    }

    // Lógica para Turbo
    if (cmd.contains("turbo")) {
       if (cmd.contains("ativar") || cmd.contains("modo") || cmd.contains("ligar")) {
          FirebaseService.turboRef.set(true);
          FirebaseService.stealthRef.set(false);
       } else if (cmd.contains("desativar") || cmd.contains("desligar")) {
          FirebaseService.turboRef.set(false);
       }
    }

    // Comandos de Movimento
    if (cmd.contains("frente") || cmd.contains("andar")) {
      FirebaseService.motorDireitoRef.set(100);
      FirebaseService.motorEsquerdoRef.set(100);
    }
    else if (cmd.contains("parar") || cmd.contains("pare")) {
      FirebaseService.motorDireitoRef.set(0);
      FirebaseService.motorEsquerdoRef.set(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.signal_cellular_alt, color: primaryColor, size: 32),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Central de Comando',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      icon: const Icon(Icons.map, color: primaryColor, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard("Velocidade", "88 km/h"),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard("Bateria", "92%"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      height: 56,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggleButton(
                              "Farol",
                              Icons.light_mode,
                              FirebaseService.farolRef,
                              primaryColor,
                              backgroundDark,
                            ),
                          ),
                          Expanded(
                            child: _buildToggleButton(
                              "Turbo",
                              Icons.rocket_launch,
                              FirebaseService.turboRef,
                              primaryColor,
                              backgroundDark,
                            ),
                          ),
                          Expanded(
                            child: _buildToggleButton(
                              "Stealth",
                              Icons.visibility_off,
                              FirebaseService.stealthRef,
                              primaryColor,
                              backgroundDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Joystick
                    Center(
                      child: JoystickWidget(
                        size: 256,
                        innerSize: 128,
                        primaryColor: primaryColor,
                        backgroundDark: backgroundDark,
                        onChanged: (offset) {
                          // Futuramente aqui será implementada a lógica de envio
                          // de comando manual do joystick para o Firebase.
                          // Por enquanto, é apenas visual como solicitado.
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: _listen,
          backgroundColor: _isListening ? Colors.redAccent : primaryColor,
          elevation: 10,
          shape: const CircleBorder(),
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none, 
            color: backgroundDark, 
            size: 36
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String title,
    IconData icon,
    DatabaseReference ref,
    Color primaryColor,
    Color backgroundDark,
  ) {
    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snapshot) {
        bool isOn = false;
        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          isOn = snapshot.data!.snapshot.value as bool;
        }

        return GestureDetector(
          onTap: () {
            ref.set(!isOn);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isOn ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isOn ? backgroundDark : Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isOn ? backgroundDark : Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
