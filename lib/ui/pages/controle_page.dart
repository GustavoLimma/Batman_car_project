import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../widgets/controle_widgets.dart';

class ControlePage extends StatelessWidget {
  const ControlePage({super.key});

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

            // Farol
            StreamBuilder(
              stream: FirebaseService.farolRef.onValue,
              builder: (context, snapshot) {
                bool isOn = (snapshot.data?.snapshot.value ?? false) as bool;

                return SmallButton(
                  title: "Farol",
                  isOn: isOn,
                  iconOn: Icons.light_mode,
                  iconOff: Icons.light_mode_outlined,
                  onPressed: () =>
                      FirebaseService.farolRef.set(!isOn),
                );
              },
            ),

            const SizedBox(width: 20),

            // Turbo
            StreamBuilder(
              stream: FirebaseService.turboRef.onValue,
              builder: (context, snapshot) {
                bool isOn = (snapshot.data?.snapshot.value ?? false) as bool;

                return SmallButton(
                  title: "Turbo",
                  isOn: isOn,
                  iconOn: Icons.speed,
                  iconOff: Icons.speed_outlined,
                  onPressed: () =>
                      FirebaseService.turboRef.set(!isOn),
                );
              },
            ),

            const SizedBox(width: 20),

            // Stealth
            StreamBuilder(
              stream: FirebaseService.stealthRef.onValue,
              builder: (context, snapshot) {
                bool isOn = (snapshot.data?.snapshot.value ?? false) as bool;

                return SmallButton(
                  title: "Stealth",
                  isOn: isOn,
                  iconOn: Icons.visibility_off,
                  iconOff: Icons.visibility,
                  onPressed: () =>
                      FirebaseService.stealthRef.set(!isOn),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
