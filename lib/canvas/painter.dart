import 'package:animated_fav_button/model/bubble.dart';
import 'package:flutter/material.dart';

class ReactPainter extends CustomPainter {
  final double value;
  List<Bubble> bubbles;
  ReactPainter({required this.value, required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      _drawIcon(canvas, bubble);
    }
  }

  void _drawIcon(Canvas canvas, Bubble bubble) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final iconSize = bubble.r * 4; // Usar el radio como factor de tamaño

    textPainter.text = TextSpan(
      text: String.fromCharCode(bubble.icon.codePoint),
      style: TextStyle(
        color: bubble.color,
        fontSize: iconSize,
        fontFamily: bubble.icon.fontFamily,
        package: bubble.icon.fontPackage,
      ),
    );

    textPainter.layout();

    // Centrar el icono en la posición de la burbuja
    final offset = Offset(
      bubble.dx - textPainter.width / 2,
      bubble.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
