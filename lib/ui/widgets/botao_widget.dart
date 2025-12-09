import 'package:flutter/material.dart';

class BotaoWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isOn;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color backgroundDark;

  const BotaoWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.isOn,
    required this.onPressed,
    required this.primaryColor,
    required this.backgroundDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
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
  }
}
