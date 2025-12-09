import 'package:flutter/material.dart';
import 'dart:math';

class JoystickWidget extends StatefulWidget {
  final double size;
  final double innerSize;
  final ValueChanged<Offset> onChanged;
  final Color primaryColor;
  final Color backgroundDark;

  const JoystickWidget({
    Key? key,
    required this.size,
    required this.innerSize,
    required this.onChanged,
    required this.primaryColor,
    required this.backgroundDark,
  }) : super(key: key);

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  Offset _dragPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final double radius = widget.size / 2;
    final double innerRadius = widget.innerSize / 2;

    return GestureDetector(
      onPanUpdate: (details) {
        final localPos = details.localPosition - Offset(radius, radius);

        final distance = min(localPos.distance, radius - innerRadius);
        final angle = atan2(localPos.dy, localPos.dx);

        final clamped = Offset(
          cos(angle) * distance,
          sin(angle) * distance,
        );

        setState(() => _dragPosition = clamped);

        widget.onChanged(Offset(
          clamped.dx / (radius - innerRadius),
          clamped.dy / (radius - innerRadius),
        ));
      },
      onPanEnd: (_) {
        setState(() => _dragPosition = Offset.zero);
        widget.onChanged(Offset.zero);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.1),
                    blurRadius: 15,
                  ),
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.1),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),

            // Círculo intermediário
            Container(
              width: widget.size * 0.75,
              height: widget.size * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),

            // Círculo interno
            Container(
              width: widget.size * 0.50,
              height: widget.size * 0.50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),

            // Botão central (amarelo) com movimento
            Transform.translate(
              offset: _dragPosition,
              child: Container(
                width: widget.innerSize,
                height: widget.innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
