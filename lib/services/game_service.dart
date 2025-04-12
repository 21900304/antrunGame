import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:antrun_game/models/game_state.dart';
import 'package:antrun_game/models/stock_model.dart';
import 'package:antrun_game/models/quiz_model.dart';

class GameService with ChangeNotifier {
  final GameState gameState = GameState();
  final Random _random = Random();

  // 타이머
  Timer? _gameTimer;
  Timer? _eventTimer;
  Timer? _obstacleTimer;
  Timer? _itemTimer;
  Timer? _quizTimer;

  // 아이템 및 장애물 위치 관리
  List<Map<String, dynamic>> obstacles = [];
  List<Map<String, dynamic>> items = [];

  // 뉴스 이벤트 목록
  final List<Map<String, dynamic>> _newsEvents = [
    {
      'title': '미국 금리 인상',
      'description': '미 연준에서 기준금리를 0.5%p 인상했습니다.',
      'impact': -0.2, // 부정적 영향
      'affectedType': 'StockType.stock',
      'gameImpact': {
        'health': -10,
        'speed': 0.1,
        'score': 0,
      },
    },
    {
      'title': '코로나 백신 개발 성공',
      'description': '신약 개발사에서 코로나 백신 개발에 성공했습니다.',
      'impact': 0.3, // 긍정적 영향
      'affectedType': 'StockType.stock',
      'gameImpact': {
        'health': 5,
        'speed': 0,
        'score': 20,
      },
    },
    {
      'title': '비트코인 채굴 난이도 증가',
      'description': '비트코인 반감기로 채굴 난이도가 상승했습니다.',
      'impact': -0.1,
      'affectedType': 'StockType.crypto',
      'gameImpact': {
        'health': -5,
        'speed': 0,
        'score': 0,
      },
    },
    {
      'title': '금 가격 상승',
      'description': '세계적 불확실성 증가로 금 가격이 상승세입니다.',
      'impact': 0.2,
      'affectedType': 'StockType.commodity',
      'gameImpact': {
        'health': 5,
        'speed': 0,
        'score': 10,
      },
    },
    {
      'title': '국채 수익률 하락',
      'description': '경기 침체 우려로 국채 수익률이 하락했습니다.',
      'impact': -0.1,
      'affectedType': 'StockType.bond',
      'gameImpact': {
        'health': 0,
        'speed': -0.1,
        'score': -5,
      },
    },
  ];

  // 게임 시작
  void startGame(GameDifficulty difficulty) {
    // 게임 상태 초기화
    gameState.initGame(difficulty);

    // 아이템 및 장애물 초기화
    obstacles = [];
    items = [];

    // 게임 타이머 설정
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), _updateGame);

    // 이벤트 타이머 설정
    _eventTimer = Timer.periodic(const Duration(seconds: 30), _generateNewsEvent);

    // 장애물 생성 타이머
    _obstacleTimer = Timer.periodic(const Duration(seconds: 2), _generateObstacle);

    // 아이템 생성 타이머
    _itemTimer = Timer.periodic(const Duration(seconds: 3), _generateItem);

    // 퀴즈 타이머
    _quizTimer = Timer.periodic(const Duration(seconds: 10), _triggerQuiz);

    notifyListeners();
  }

  // 게임 업데이트 (타이머 콜백)
  void _updateGame(Timer timer) {
    if (gameState.status != GameStatus.running) return;

    // 거리 증가
    gameState.updateGame(
      distanceIncrease: (gameState.speed * 5).toInt(),
      scoreIncrease: (gameState.speed * 1).toInt(),
    );

    // 체력 서서히 감소
    if (_random.nextInt(10) == 0) {
      gameState.updateGame(healthChange: -1);
    }

    // 아이템 및 장애물 업데이트
    _updateItemsAndObstacles();

    notifyListeners();
  }

  // 아이템 및 장애물 업데이트
  void _updateItemsAndObstacles() {
    final playerPosition = 100; // 플레이어의 x 위치 (고정)
    final hitRange = 40; // 충돌 범위

    // 장애물 업데이트
    for (int i = obstacles.length - 1; i >= 0; i--) {
      obstacles[i]['x'] -= (5 * gameState.speed).toInt();

      // 충돌 검사
      if ((obstacles[i]['x'] - playerPosition).abs() < hitRange &&
          obstacles[i]['lane'] == 1 && // 플레이어와 같은 레인에 있는 경우
          !obstacles[i]['hit']) {

        obstacles[i]['hit'] = true;
        gameState.updateGame(healthChange: -15);
      }

      // 화면 밖으로 나간 장애물 제거
      if (obstacles[i]['x'] < -50) {
        obstacles.removeAt(i);
      }
    }

    // 아이템 업데이트
    for (int i = items.length - 1; i >= 0; i--) {
      items[i]['x'] -= (5 * gameState.speed).toInt();

      // 충돌 검사
      if ((items[i]['x'] - playerPosition).abs() < hitRange &&
          items[i]['lane'] == 1 && // 플레이어와 같은 레인에 있는 경우
          !items[i]['collected']) {

        items[i]['collected'] = true;

        // 종목 아이템 획득 처리
        final stock = StockDatabase.findById(items[i]['stockId']);
        if (stock != null) {
          gameState.collectStock(stock);
        }
      }

      // 화면 밖으로 나간 아이템 제거
      if (items[i]['x'] < -50) {
        items.removeAt(i);
      }
    }
  }

  // 장애물 생성
  void _generateObstacle(Timer timer) {
    if (gameState.status != GameStatus.running) return;

    obstacles.add({
      'x': 800, // 화면 오른쪽 끝에서 시작
      'lane': _random.nextInt(3), // 0, 1, 2 레인 (1이 플레이어 레인)
      'type': _random.nextInt(3), // 장애물 종류
      'hit': false,
    });

    notifyListeners();
  }

  // 아이템 생성
  void _generateItem(Timer timer) {
    if (gameState.status != GameStatus.running) return;

    // 랜덤하게 종목 선택
    final stocks = StockDatabase.getStocks();
    final stock = stocks[_random.nextInt(stocks.length)];

    items.add({
      'x': 800, // 화면 오른쪽 끝에서 시작
      'lane': _random.nextInt(3), // 0, 1, 2 레인
      'stockId': stock.id,
      'collected': false,
    });

    notifyListeners();
  }

  // 뉴스 이벤트 생성
  void _generateNewsEvent(Timer timer) {
    if (gameState.status != GameStatus.running) return;

    final event = _newsEvents[_random.nextInt(_newsEvents.length)];
    gameState.triggerNewsEvent(event);

    notifyListeners();
  }

  // 퀴즈 생성
  void _triggerQuiz(Timer timer) {
    if (gameState.status != GameStatus.running) return;

    gameState.startQuiz();
    notifyListeners();
  }

  // 퀴즈 정답 제출
  void submitQuizAnswer(QuizModel quiz, int selectedAnswerIndex) {
    final isCorrect = quiz.checkAnswer(selectedAnswerIndex);
    final reward = quiz.calculateReward();

    gameState.processQuizResult(isCorrect, reward);
    notifyListeners();
  }

  // 플레이어 레인 변경
  void changePlayerLane(int newLane) {
    // 게임 구현에서 플레이어의 레인(상/중/하) 변경 로직
    // 실제 충돌 감지는 _updateItemsAndObstacles 메서드에서 처리
    notifyListeners();
  }

  // 게임 일시정지
  void pauseGame() {
    gameState.pauseGame();
    notifyListeners();
  }

  // 게임 재개
  void resumeGame() {
    gameState.resumeGame();
    notifyListeners();
  }

  // 게임 종료
  void endGame() {
    _cancelTimers();
    gameState.status = GameStatus.gameOver;
    notifyListeners();
  }

  // 타이머 취소
  void _cancelTimers() {
    _gameTimer?.cancel();
    _eventTimer?.cancel();
    _obstacleTimer?.cancel();
    _itemTimer?.cancel();
    _quizTimer?.cancel();
  }

  // 서비스 종료
  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}