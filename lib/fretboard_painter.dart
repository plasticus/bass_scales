import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'music_engine.dart';

class FretboardPainter extends CustomPainter {
  final String rootNote;
  final Set<String> activeNotes;
  final List<int> tuning;
  final String labelMode;
  final bool isLeftHanded;
  final String woodType;
  final String inlayStyle;
  final bool showStars;
  final double starIntensity;
  final double fretWidth;

  FretboardPainter({
    required this.rootNote, required this.activeNotes, required this.tuning,
    required this.labelMode, required this.isLeftHanded, required this.woodType,
    required this.inlayStyle, required this.showStars, required this.starIntensity,
    required this.fretWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isLeftHanded) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final paint = Paint();
    final double stringCount = tuning.length.toDouble();
    final double chartHeight = size.height - 30;
    final double stringHeight = chartHeight / (stringCount + 1);

    // 1. BIGGER LETTERS: Decoupled from fretWidth to stay legible
    final double circleSize = (fretWidth * 0.28).clamp(18.0, 32.0);
    final double fontSize = (fretWidth * 0.12 + 22.0).clamp(24.0, 38.0);

    if (showStars) {
      final random = math.Random(42);
      paint.color = Colors.white.withOpacity(starIntensity);
      for (int i = 0; i < 600; i++) {
        canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 2, paint);
      }
    }

    if (woodType != 'Clear') {
      paint.color = (woodType == 'Rosewood') ? const Color(0xFF3E2723) : const Color(0xFFFFF9C4);
      canvas.drawRect(Rect.fromLTWH(fretWidth, stringHeight / 2, size.width - fretWidth, chartHeight - stringHeight), paint);
    }

    _drawInlays(canvas, chartHeight, fretWidth, stringHeight);

    // Draw Frets and Numbers
    for (int i = 0; i <= 24; i++) {
      double x = (i + 1) * fretWidth;
      if (i == 0) {
        paint.color = Colors.white;
        paint.strokeWidth = 12;
      } else {
        paint.color = const Color(0xFFBDBDBD);
        paint.strokeWidth = 4;
      }
      canvas.drawLine(Offset(x, stringHeight / 2), Offset(x, chartHeight - stringHeight / 2), paint);

      if (i > 0) {
        final numPainter = TextPainter(
          text: TextSpan(text: i.toString(), style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();

        // 3. TIGHTER NUMBERS: Moved up to hug the fretboard
        double numberY = chartHeight - (stringHeight * 0.45);

        if (isLeftHanded) {
           canvas.save();
           canvas.translate(x, numberY);
           canvas.scale(-1, 1);
           numPainter.paint(canvas, Offset(-numPainter.width / 2, 0));
           canvas.restore();
        } else {
           numPainter.paint(canvas, Offset(x - numPainter.width / 2, numberY));
        }
      }
    }

    // Draw Strings and Notes
    for (int i = 0; i < tuning.length; i++) {
      double y = (i + 1) * stringHeight;
      paint.color = Colors.grey[400]!;
      paint.strokeWidth = 3 + (i * 1.2);
      canvas.drawLine(Offset(fretWidth, y), Offset(size.width, y), paint);

      int openNoteIndex = tuning[i];
      for (int f = 0; f <= 24; f++) {
        int currentNoteIndex = (openNoteIndex + f) % 12;
        String noteName = MusicEngine.chromaticScale[currentNoteIndex];

        if (activeNotes.contains(noteName)) {
          double x = (f + 0.5) * fretWidth;
          paint.color = (noteName == rootNote) ? Colors.orange : Colors.blueAccent;
          canvas.drawCircle(Offset(x, y), circleSize, paint);

          if (labelMode != 'None') {
            String displayText = (labelMode == 'Intervals') ? MusicEngine.getInterval(rootNote, noteName) : noteName;
            final textPainter = TextPainter(
              text: TextSpan(text: displayText, style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold)),
              textDirection: TextDirection.ltr,
            )..layout();

            if (isLeftHanded) {
              canvas.save();
              canvas.translate(x, y);
              canvas.scale(-1, 1);
              textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
              canvas.restore();
            } else {
              textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
            }
          }
        }
      }
    }

    if (isLeftHanded) canvas.restore();
  }

  void _drawInlays(Canvas canvas, double chartHeight, double fretWidth, double stringHeight) {
    if (inlayStyle == 'None') return;
    final List<int> markFrets = [3, 5, 7, 9, 12, 15, 17, 19, 21, 24];
    final paint = Paint();
    paint.color = (woodType == 'Maple') ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.50);

    for (int f in markFrets) {
      double x = (f + 0.5) * fretWidth;
      double y = chartHeight / 2;
      bool isDouble = (f == 12 || f == 24);

      if (inlayStyle == 'Quasar') {
         _drawBigQuasar(canvas, Offset(x, y), paint.color, isDouble, fretWidth);
      } else if (inlayStyle == 'Dots') {
         if (isDouble) {
           canvas.drawCircle(Offset(x, y - stringHeight), 12, paint);
           canvas.drawCircle(Offset(x, y + stringHeight), 12, paint);
         } else {
           canvas.drawCircle(Offset(x, y), 12, paint);
         }
      } else if (inlayStyle == 'Blocks') {
         canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: fretWidth * 0.5, height: chartHeight * 0.5), paint);
      }
    }
  }

  void _drawBigQuasar(Canvas canvas, Offset center, Color color, bool isDouble, double currentFretWidth) {
    final qPaint = Paint()..color = color..strokeWidth = 5;
    final double qScale = (currentFretWidth / 100.0).clamp(0.5, 1.5);

    void drawOne(Offset c) {
      canvas.drawCircle(c, 15 * qScale, qPaint);
      canvas.drawLine(Offset(c.dx, c.dy - (60 * qScale)), Offset(c.dx, c.dy + (60 * qScale)), qPaint);
      canvas.drawLine(Offset(c.dx - (35 * qScale), c.dy), Offset(c.dx + (35 * qScale), c.dy), qPaint);
    }
    if (isDouble) {
      drawOne(center.translate(0, -80));
      drawOne(center.translate(0, 80));
    } else {
      drawOne(center);
    }
  }

  @override
  bool shouldRepaint(covariant FretboardPainter oldDelegate) => true;
}