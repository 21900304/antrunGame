import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: AntPlayerPainter(),
      ),
    );
  }
}

class AntPlayerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 몸통 색상
    final bodyPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;

    // 얼굴 색상
    final facePaint = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.fill;

    // 다리 색상
    final legPaint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // 눈 색상
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 동전 색상
    final coinPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final coinBorderPaint = Paint()
      ..color = Colors.amber.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 몸통 그리기 (타원)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * 0.5, height * 0.5),
        width: width * 0.65,
        height: height * 0.45,
      ),
      bodyPaint,
    );

    // 머리 그리기 (원)
    canvas.drawCircle(
      Offset(width * 0.3, height * 0.35),
      width * 0.2,
      facePaint,
    );

    // 다리 그리기 (6개)
    // 왼쪽 다리 3개
    canvas.drawLine(
      Offset(width * 0.3, height * 0.55),
      Offset(width * 0.15, height * 0.7),
      legPaint,
    );
    canvas.drawLine(
      Offset(width * 0.4, height * 0.6),
      Offset(width * 0.25, height * 0.8),
      legPaint,
    );
    canvas.drawLine(
      Offset(width * 0.5, height * 0.6),
      Offset(width * 0.35, height * 0.85),
      legPaint,
    );

    // 오른쪽 다리 3개
    canvas.drawLine(
      Offset(width * 0.6, height * 0.6),
      Offset(width * 0.75, height * 0.85),
      legPaint,
    );
    canvas.drawLine(
      Offset(width * 0.7, height * 0.5),
      Offset(width * 0.85, height * 0.7),
      legPaint,
    );
    canvas.drawLine(
      Offset(width * 0.75, height * 0.45),
      Offset(width * 0.9, height * 0.55),
      legPaint,
    );

    // 눈 그리기 (2개)
    canvas.drawCircle(
      Offset(width * 0.25, height * 0.3),
      width * 0.05,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(width * 0.35, height * 0.3),
      width * 0.05,
      eyePaint,
    );

    // 눈동자 그리기
    canvas.drawCircle(
      Offset(width * 0.25, height * 0.3),
      width * 0.02,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(width * 0.35, height * 0.3),
      width * 0.02,
      Paint()..color = Colors.black,
    );

    // 입 그리기
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(width * 0.3, height * 0.4),
        width: width * 0.15,
        height: height * 0.1,
      ),
      0.1,
      3.0,
      false,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 더듬이 그리기
    canvas.drawLine(
      Offset(width * 0.25, height * 0.2),
      Offset(width * 0.15, height * 0.1),
      legPaint,
    );
    canvas.drawLine(
      Offset(width * 0.35, height * 0.2),
      Offset(width * 0.45, height * 0.05),
      legPaint,
    );

    // 동전 그리기 (개미가 들고 있는)
    canvas.drawCircle(
      Offset(width * 0.75, height * 0.25),
      width * 0.15,
      coinPaint,
    );
    canvas.drawCircle(
      Offset(width * 0.75, height * 0.25),
      width * 0.15,
      coinBorderPaint,
    );

    // 동전에 $ 표시
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          color: Colors.amber.shade900,
          fontSize: width * 0.2,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        width * 0.75 - textPainter.width / 2,
        height * 0.25 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}