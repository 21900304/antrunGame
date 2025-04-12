import 'package:flutter/foundation.dart';
import 'package:antrun_game/models/stock_model.dart';

enum GameDifficulty {
  easy,
  normal,
  hard
}

enum GameStatus {
  notStarted,
  running,
  paused,
  quizTime,
  gameOver
}

class GameState with ChangeNotifier {
  // 게임 설정
  GameDifficulty difficulty = GameDifficulty.normal;
  GameStatus status = GameStatus.notStarted;

  // 게임 상태
  int score = 0;
  int health = 100;
  int distance = 0;
  double speed = 1.0;
  int coins = 0;
  int level = 1;

  // 플레이어 포트폴리오
  List<Map<String, dynamic>> portfolio = [];

  // 현재 뉴스 이벤트
  Map<String, dynamic>? currentNewsEvent;

  // 게임 초기화
  void initGame(GameDifficulty selectedDifficulty) {
    difficulty = selectedDifficulty;
    status = GameStatus.running;
    score = 0;
    health = 100;
    distance = 0;
    coins = 0;

    // 난이도에 따른 속도 설정
    switch (difficulty) {
      case GameDifficulty.easy:
        speed = 1.0;
        break;
      case GameDifficulty.normal:
        speed = 1.5;
        break;
      case GameDifficulty.hard:
        speed = 2.0;
        break;
    }

    portfolio = [];
    currentNewsEvent = null;

    notifyListeners();
  }

  // 게임 상태 업데이트
  void updateGame({
    int? scoreIncrease,
    int? healthChange,
    int? distanceIncrease,
    double? speedChange,
    int? coinsCollected,
  }) {
    if (status != GameStatus.running) return;

    if (scoreIncrease != null) score += scoreIncrease;
    if (healthChange != null) health = (health + healthChange).clamp(0, 100);
    if (distanceIncrease != null) distance += distanceIncrease;
    if (speedChange != null) speed = (speed + speedChange).clamp(0.5, 3.0);
    if (coinsCollected != null) coins += coinsCollected;

    // 체력이 0이 되면 게임 오버
    if (health <= 0) {
      status = GameStatus.gameOver;
    }

    notifyListeners();
  }

  // 종목 수집 처리
  void collectStock(StockModel stock) {
    // 점수 및 게임 상태 업데이트
    final effects = stock.calculateGameEffects();

    updateGame(
      healthChange: effects['health'],
      speedChange: effects['speed'] != null ? effects['speed']! / 10 : 0,
      scoreIncrease: 10 * (effects['score'] ?? 1),
      coinsCollected: 5,
    );

    // 포트폴리오에 추가
    final existingStockIndex = portfolio.indexWhere((item) => item['id'] == stock.id);

    if (existingStockIndex >= 0) {
      // 이미 가지고 있는 종목이면 수량 증가
      final updatedStock = {...portfolio[existingStockIndex]};
      updatedStock['quantity'] = (updatedStock['quantity'] as int) + 1;
      portfolio[existingStockIndex] = updatedStock;
    } else {
      // 새로운 종목 추가
      portfolio.add({
        'id': stock.id,
        'name': stock.name,
        'symbol': stock.symbol,
        'type': stock.type.toString(),
        'purchasePrice': stock.basePrice,
        'quantity': 1,
        'purchasedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }

    notifyListeners();
  }

  // 뉴스 이벤트 발생
  void triggerNewsEvent(Map<String, dynamic> newsEvent) {
    currentNewsEvent = newsEvent;

    // 뉴스 이벤트에 따른 게임 상태 변화
    final impact = newsEvent['gameImpact'] as Map<String, dynamic>? ?? {};

    updateGame(
      healthChange: impact['health'],
      speedChange: impact['speed'],
      scoreIncrease: impact['score'],
    );

    // 포트폴리오 가격 영향
    _updatePortfolioPrices(newsEvent);

    notifyListeners();
  }

  // 포트폴리오 가격 업데이트
  void _updatePortfolioPrices(Map<String, dynamic> newsEvent) {
    for (int i = 0; i < portfolio.length; i++) {
      final stock = StockDatabase.findById(portfolio[i]['id']);
      if (stock != null) {
        final priceChange = stock.calculatePriceChange(newsEvent);
        final updatedStock = {...portfolio[i]};
        updatedStock['currentPrice'] = stock.basePrice + priceChange;
        portfolio[i] = updatedStock;
      }
    }
  }

  // 퀴즈 시작
  void startQuiz() {
    status = GameStatus.quizTime;
    notifyListeners();
  }

  // 퀴즈 결과 처리
  void processQuizResult(bool isCorrect, int reward) {
    if (isCorrect) {
      score += reward;
      health = (health + 20).clamp(0, 100);
      coins += reward ~/ 2;
    }

    status = GameStatus.running;
    notifyListeners();
  }

  // 게임 일시 정지
  void pauseGame() {
    if (status == GameStatus.running) {
      status = GameStatus.paused;
      notifyListeners();
    }
  }

  // 게임 재개
  void resumeGame() {
    if (status == GameStatus.paused) {
      status = GameStatus.running;
      notifyListeners();
    }
  }

  // 게임 재시작
  void restartGame() {
    initGame(difficulty);
  }

  // 최종 결과 계산
  Map<String, dynamic> calculateFinalResults() {
    // 포트폴리오 가치 계산
    int portfolioValue = 0;
    for (final stock in portfolio) {
      final currentPrice = stock['currentPrice'] ?? stock['purchasePrice'];
      portfolioValue += (currentPrice as int) * (stock['quantity'] as int);
    }

    // 최종 점수 = 기본 점수 + 거리 보너스 + 포트폴리오 가치의 일부
    final finalScore = score + (distance ~/ 10) + (portfolioValue ~/ 100);

    return {
      'score': finalScore,
      'distance': distance,
      'coins': coins,
      'portfolioValue': portfolioValue,
      'portfolio': portfolio,
      'efficiency': (finalScore / (distance > 0 ? distance : 1)).toStringAsFixed(2),
    };
  }
}