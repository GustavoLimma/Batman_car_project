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

                    // Action Toggles
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
                      child: Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.2),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 192,
                              height: 192,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Joystick Handle
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
