import 'package:flutter/material.dart';

class SmallButton extends StatelessWidget {
  final String title;
  final bool isOn;
  final IconData iconOn;
  final IconData iconOff;
  final VoidCallback onPressed;

  const SmallButton({
    super.key,
    required this.title,
    required this.isOn,
    required this.iconOn,
    required this.iconOff,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
