import 'package:flutter/material.dart';

class ObstacleWidget extends StatelessWidget {
  final int type; // 장애물 유형 (0, 1, 2)
  final bool isHit; // 충돌 여부

  const ObstacleWidget({
    Key? key,
    required this.type,
    this.isHit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 장애물 유형에 따른 디자인
    Widget obstacleWidget;

    switch (type) {
      case 0: // 구름 (경제 불황)
        obstacleWidget = _buildCloudObstacle();
        break;
      case 1: // 불 (시장 충격)
        obstacleWidget = _buildFireObstacle();
        break;
      case 2: // 돌 (규제)
        obstacleWidget = _buildRockObstacle();
        break;
      default:
        obstacleWidget = _buildDefaultObstacle();
    }

    // 이미 충돌한 경우 투명하게 표시
    if (isHit) {
      return Opacity(
        opacity: 0.3,
        child: obstacleWidget,
      );
    }

    return obstacleWidget;
  }

  // 구름 장애물 (경제 불황)
  Widget _buildCloudObstacle() {
    return Container(
      width: 70,
      height: 50,
      child: CustomPaint(
        painter: CloudPainter(),
      ),
    );
  }

  // 불 장애물 (시장 충격)
  Widget _buildFireObstacle() {
    return Container(
      width: 50,
      height: 70,
      child: CustomPaint(
        painter: FirePainter(),
      ),
    );
  }

  // 돌 장애물 (규제)
  Widget _buildRockObstacle() {
    return Container(
      width: 60,
      height: 50,
      child: CustomPaint(
        painter: RockPainter(),
      ),
    );
  }

  // 기본 장애물
  Widget _buildDefaultObstacle() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.warning,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

// 구름 그리기
class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final width = size.width;
    final height = size.height;

    // 구름 모양 그리기 (여러 원의 조합)
    final path = Path();

    // 중앙 큰 원
    path.addOval(
      Rect.fromCenter(
        center: Offset(width * 0.5, height * 0.6),
        width: width * 0.6,
        height: height * 0.7,
      ),
    );

    // 왼쪽 원
    path.addOval(
      Rect.fromCenter(
        center: Offset(width * 0.25, height * 0.5),
        width: width * 0.4,
        height: height * 0.5,
      ),
    );

    // 오른쪽 원
    path.addOval(
      Rect.fromCenter(
        center: Offset(width * 0.75, height * 0.5),
        width: width * 0.4,
        height: height * 0.5,
      ),
    );

    // 상단 원
    path.addOval(
      Rect.fromCenter(
        center: Offset(width * 0.5, height * 0.3),
        width: width * 0.5,
        height: height * 0.5,
      ),
    );

    canvas.drawPath(path, paint);
    canvas.drawPath(path, outlinePaint);

    // 번개 그리기
    final boltPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final boltPath = Path();
    boltPath.moveTo(width * 0.4, height * 0.4);
    boltPath.lineTo(width * 0.55, height * 0.6);
    boltPath.lineTo(width * 0.5, height * 0.6);
    boltPath.lineTo(width * 0.65, height * 0.9);
    boltPath.lineTo(width * 0.55, height * 0.65);
    boltPath.lineTo(width * 0.6, height * 0.65);
    boltPath.lineTo(width * 0.4, height * 0.4);

    canvas.drawPath(boltPath, boltPaint);

    // 텍스트 추가
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '불황',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        width * 0.5 - textPainter.width / 2,
        height * 0.5 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// 불 그리기
class FirePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 불 그리기
    final firePath = Path();

    // 불꽃 시작점
    firePath.moveTo(width * 0.2, height * 0.8);

    // 왼쪽 불꽃
    firePath.quadraticBezierTo(
      width * 0.1, height * 0.5,
      width * 0.3, height * 0.4,
    );

    // 중앙 불꽃
    firePath.quadraticBezierTo(
      width * 0.4, height * 0.1,
      width * 0.5, height * 0.3,
    );

    // 오른쪽 불꽃
    firePath.quadraticBezierTo(
      width * 0.65, height * 0.15,
      width * 0.7, height * 0.4,
    );

    // 마무리
    firePath.quadraticBezierTo(
      width * 0.9, height * 0.6,
      width * 0.8, height * 0.8,
    );

    // 닫기
    firePath.lineTo(width * 0.2, height * 0.8);

    // 그라데이션 채우기
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.yellow,
        Colors.orange,
        Colors.red.shade800,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, width, height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(firePath, paint);

    // 텍스트 추가
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '충격',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        width * 0.5 - textPainter.width / 2,
        height * 0.55,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// 돌 그리기
class RockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 돌 모양 그리기
    final rockPath = Path();

    rockPath.moveTo(width * 0.3, height * 0.8);
    rockPath.lineTo(width * 0.1, height * 0.5);
    rockPath.lineTo(width * 0.2, height * 0.3);
    rockPath.lineTo(width * 0.5, height * 0.2);
    rockPath.lineTo(width * 0.8, height * 0.3);
    rockPath.lineTo(width * 0.9, height * 0.6);
    rockPath.lineTo(width * 0.7, height * 0.8);
    rockPath.lineTo(width * 0.3, height * 0.8);

    // 그라데이션 채우기
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.shade500,
        Colors.grey.shade700,
        Colors.grey.shade900,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, width, height),
      )
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(rockPath, paint);
    canvas.drawPath(rockPath, outlinePaint);

    // 텍스트 추가
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '규제',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        width * 0.5 - textPainter.width / 2,
        height * 0.5 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}