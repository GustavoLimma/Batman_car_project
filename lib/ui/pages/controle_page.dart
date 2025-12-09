import 'package:batman/ui/widgets/botao_widget.dart';
import 'package:batman/ui/widgets/joystick_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/firebase_service.dart';
import 'map_page.dart';

class ControlePage extends StatelessWidget {
  const ControlePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF2D00D);
    const Color backgroundDark = Color(0xFF221F10);

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
                    // Stats Panel
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

                    // Action Toggles — agora usando BotaoWidget
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
                          // FAROL
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

                          // TURBO
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

                          // STEALTH
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
                          final dy = (offset.dy * 100).clamp(-100, 100).toInt();

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
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: primaryColor,
          elevation: 10,
          shape: const CircleBorder(),
          child: Icon(Icons.mic, color: backgroundDark, size: 32),
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
}
