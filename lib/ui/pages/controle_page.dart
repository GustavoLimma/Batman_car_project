import 'package:batman/ui/widgets/botao_widget.dart';
import 'package:batman/ui/widgets/joystick_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/firebase_service.dart';
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

    // --- FAROL ---
    if (cmd.contains("ativar farol") || cmd.contains("ligar farol")) {
       FirebaseService.farolRef.set(true);
    } 
    else if (cmd.contains("desligar farol") || cmd.contains("apagar farol")) {
       FirebaseService.farolRef.set(false);
    }

    // --- TURBO ---
    else if (cmd.contains("ativar turbo") || cmd.contains("modo turbo")) {
       FirebaseService.turboRef.set(true);
       FirebaseService.stealthRef.set(false);
    }
    else if (cmd.contains("desligar turbo") || cmd.contains("desativar turbo")) {
       FirebaseService.turboRef.set(false);
    }

    // --- STEALTH (MODO FURTIVO) ---
    else if (cmd.contains("ativar modo furtivo") || cmd.contains("modo furtivo")) {
       FirebaseService.stealthRef.set(true);
       FirebaseService.turboRef.set(false);
       FirebaseService.farolRef.set(false);
    }
    else if (cmd.contains("desativar modo furtivo") || cmd.contains("desligar modo furtivo")) {
       FirebaseService.stealthRef.set(false);
    }

    // --- CABINE ---
    else if (cmd.contains("abrir cabine") || cmd.contains("ativar cabine")) {
       FirebaseService.cockpitRef.set(true);
    }
    else if (cmd.contains("fechar cabine") || cmd.contains("desativar cabine")) {
       FirebaseService.cockpitRef.set(false);
    }

    // --- IGNIÇÃO ---
    else if (cmd.contains("ignição") || cmd.contains("ignicao")) {
       if (cmd.contains("ligar") || cmd.contains("ativar")) {
          FirebaseService.ignicaoRef.set(true);
       } else if (cmd.contains("desligar") || cmd.contains("desativar")) {
          FirebaseService.ignicaoRef.set(false);
       }
    }
    else if (cmd.contains("ligar carro") || cmd.contains("ligar motor")) {
       FirebaseService.ignicaoRef.set(true);
    }
    else if (cmd.contains("desligar carro") || cmd.contains("desligar motor")) {
       FirebaseService.ignicaoRef.set(false);
    }

    // --- MOTORES ---
    else if (cmd.contains("frente") || cmd.contains("andar")) {
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
            // Header
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
                    // Sensor de Distância (Novo)
                    StreamBuilder<DatabaseEvent>(
                      stream: FirebaseService.distanciaRef.onValue,
                      builder: (context, snapshot) {
                        String valorDistancia = "--";
                        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                          valorDistancia = snapshot.data!.snapshot.value.toString();
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Distância Obstáculo",
                                      style: TextStyle(
                                        color: Colors.white70, // white with opacity 0.7
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "$valorDistancia cm",
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),

                    // Action Toggles - Linha 1
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
                            child: StreamBuilder<DatabaseEvent>(
                              stream: FirebaseService.farolRef.onValue,
                              builder: (context, snapshot) {
                                final isOn = (snapshot.data?.snapshot.value ?? false) as bool;
                                return BotaoWidget(
                                  title: "Farol",
                                  icon: Icons.light_mode,
                                  isOn: isOn,
                                  primaryColor: primaryColor,
                                  backgroundDark: backgroundDark,
                                  onPressed: () => FirebaseService.farolRef.set(!isOn),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder<DatabaseEvent>(
                              stream: FirebaseService.turboRef.onValue,
                              builder: (context, snapshot) {
                                final isOn = (snapshot.data?.snapshot.value ?? false) as bool;
                                return BotaoWidget(
                                  title: "Turbo",
                                  icon: Icons.rocket_launch,
                                  isOn: isOn,
                                  primaryColor: primaryColor,
                                  backgroundDark: backgroundDark,
                                  onPressed: () => FirebaseService.turboRef.set(!isOn),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder<DatabaseEvent>(
                              stream: FirebaseService.stealthRef.onValue,
                              builder: (context, snapshot) {
                                final isOn = (snapshot.data?.snapshot.value ?? false) as bool;
                                return BotaoWidget(
                                  title: "Stealth",
                                  icon: Icons.visibility_off,
                                  isOn: isOn,
                                  primaryColor: primaryColor,
                                  backgroundDark: backgroundDark,
                                  onPressed: () => FirebaseService.stealthRef.set(!isOn),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),

                    // Action Toggles - Linha 2 (Cabine e Ignição)
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
                          // Botão Cabine
                          Expanded(
                            child: StreamBuilder<DatabaseEvent>(
                              stream: FirebaseService.cockpitRef.onValue,
                              builder: (context, snapshot) {
                                final isOn = (snapshot.data?.snapshot.value ?? false) as bool;
                                return BotaoWidget(
                                  title: "Cabine",
                                  icon: Icons.airline_seat_recline_extra,
                                  isOn: isOn,
                                  primaryColor: primaryColor,
                                  backgroundDark: backgroundDark,
                                  onPressed: () => FirebaseService.cockpitRef.set(!isOn),
                                );
                              },
                            ),
                          ),
                          
                          // Botão Ignição
                          Expanded(
                            child: StreamBuilder<DatabaseEvent>(
                              stream: FirebaseService.ignicaoRef.onValue,
                              builder: (context, snapshot) {
                                final isOn = (snapshot.data?.snapshot.value ?? false) as bool;
                                return BotaoWidget(
                                  title: "Ignição",
                                  icon: Icons.power_settings_new,
                                  isOn: isOn,
                                  primaryColor: Colors.greenAccent,
                                  backgroundDark: backgroundDark,
                                  onPressed: () => FirebaseService.ignicaoRef.set(!isOn),
                                );
                              },
                            ),
                          ),
                        ]
                      )
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
                          final dx = (offset.dx * 100).clamp(-100, 100).toInt();
                          final dy = (-offset.dy * 100).clamp(-100, 100).toInt();

                          FirebaseService.joystickXRef.set(dx);
                          FirebaseService.joystickYRef.set(dy);
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
}
