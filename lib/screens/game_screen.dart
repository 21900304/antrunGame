import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:antrun_game/models/user_model.dart';
import 'package:antrun_game/models/game_state.dart';
import 'package:antrun_game/services/game_service.dart';
import 'package:antrun_game/services/firestore_service.dart';
import 'package:antrun_game/services/auth_service.dart';
import 'package:antrun_game/screens/result_screen.dart';
import 'package:antrun_game/screens/quiz_screen.dart';

import '../widget/item_widget.dart';
import '../widget/obstacle_widget.dart';
import '../widget/player_widget.dart';

class GameScreen extends StatefulWidget {
  final UserModel? userData;

  const GameScreen({Key? key, this.userData}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameService _gameService;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isGameStarted = false;
  GameDifficulty _selectedDifficulty = GameDifficulty.normal;

  // 플레이어 위치 및 레인
  int _playerLane = 1; // 0: 상단, 1: 중앙, 2: 하단

  @override
  void initState() {
    super.initState();
    _gameService = GameService();

    // 전체 화면 모드로 설정
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 가로 모드 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 원래 화면 모드로 복원
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 세로 모드 허용
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  // 게임 시작
  void _startGame() {
    setState(() {
      _isGameStarted = true;
    });

    _gameService.startGame(_selectedDifficulty);

    // 키보드 이벤트 리스너 추가 (실제 앱에서는 터치로 구현)
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // 게임 일시정지
  void _pauseGame() {
    _gameService.pauseGame();
  }

  // 게임 재개
  void _resumeGame() {
    _gameService.resumeGame();
  }

  // 게임 종료 및 결과 저장
  // 에러가 있는 코드 부분 (게임 종료 부분)
  Future<void> _endGame() async {
    // 게임 종료
    _gameService.endGame();

    // 게임 결과 계산
    final results = _gameService.gameState.calculateFinalResults();

    try {
      // 결과 저장
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        await _firestoreService.saveGameResult(userId, results);

        // 경험치 업데이트 (거리에 비례)
        int expGained = results['distance'] ~/ 20;
        await _firestoreService.updateUserExperience(userId, expGained);

        // 포트폴리오 저장
        if (results['portfolio'] != null) {
          await _firestoreService.savePortfolio(
            userId,
            List<Map<String, dynamic>>.from(results['portfolio']),
          );
        }
      }

      // 결과 화면으로 이동
      if (mounted) {  // 이 부분이 중요! mounted 체크
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(results: results),
          ),
        );
      }
    } catch (e) {
      // 이 부분이 문제가 됩니다
      if (mounted) {  // mounted 체크를 추가!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게임 결과 저장 중 오류가 발생했습니다')),
        );
      }
    }
  }

  // 레인 변경
  void _changePlayerLane(int newLane) {
    if (newLane >= 0 && newLane <= 2) {
      setState(() {
        _playerLane = newLane;
      });
      _gameService.changePlayerLane(newLane);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameService,
      child: Scaffold(
        body: _isGameStarted
            ? _buildGameScreen()
            : _buildGameStartMenu(),
      ),
    );
  }

  // 게임 시작 메뉴 UI
  Widget _buildGameStartMenu() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade900,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '난이도 선택',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _buildDifficultyOption(
                label: '쉬움',
                description: '느린 속도, 적은 장애물',
                difficulty: GameDifficulty.easy,
              ),

              _buildDifficultyOption(
                label: '보통',
                description: '중간 속도, 기본 난이도',
                difficulty: GameDifficulty.normal,
              ),

              _buildDifficultyOption(
                label: '어려움',
                description: '빠른 속도, 많은 장애물',
                difficulty: GameDifficulty.hard,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '게임 시작',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 난이도 선택 옵션 UI
  Widget _buildDifficultyOption({
    required String label,
    required String description,
    required GameDifficulty difficulty,
  }) {
    final isSelected = _selectedDifficulty == difficulty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<GameDifficulty>(
              value: difficulty,
              groupValue: _selectedDifficulty,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
              activeColor: Colors.blue.shade700,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 게임 화면 UI
  Widget _buildGameScreen() {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        final gameState = gameService.gameState;

        // 퀴즈 타임인 경우
        if (gameState.status == GameStatus.quizTime) {
          return QuizScreen(
            gameService: gameService,
          );
        }

        // 게임 일시정지 화면
        if (gameState.status == GameStatus.paused) {
          return _buildPauseScreen();
        }

        // 게임 오버 화면
        if (gameState.status == GameStatus.gameOver) {
          // 결과 저장 및 화면 이동
          Future.delayed(Duration.zero, _endGame);

          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 게임 플레이 화면
        return Stack(
          children: [
            // 배경
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade300,
                    Colors.blue.shade700,
                  ],
                ),
              ),
            ),

            // 게임 UI
            Column(
              children: [
                // 상단 정보 바
                _buildGameInfoBar(gameState),

                // 게임 영역
                Expanded(
                  child: Stack(
                    children: [
                      // 배경 레인 라인
                      _buildLaneLines(),

                      // 장애물 렌더링
                      ..._buildObstacles(gameService.obstacles),

                      // 아이템 렌더링
                      ..._buildItems(gameService.items),

                      // 플레이어 캐릭터
                      Positioned(
                        left: 100, // 플레이어 x 위치 (고정)
                        top: 50.0 + (_playerLane * 120.0), // 레인에 따른 y 위치
                        child: const PlayerWidget(),
                      ),

                      // 뉴스 이벤트 표시
                      if (gameState.currentNewsEvent != null)
                        _buildNewsEventOverlay(gameState.currentNewsEvent!),

                      // 게임 컨트롤 버튼
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'up',
                              mini: true,
                              onPressed: () => _changePlayerLane(_playerLane - 1),
                              child: Icon(Icons.arrow_upward),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              heroTag: 'down',
                              mini: true,
                              onPressed: () => _changePlayerLane(_playerLane + 1),
                              child: Icon(Icons.arrow_downward),
                            ),
                          ],
                        ),
                      ),

                      // 일시정지 버튼
                      Positioned(
                        right: 20,
                        top: 20,
                        child: FloatingActionButton(
                          heroTag: 'pause',
                          mini: true,
                          onPressed: _pauseGame,
                          child: Icon(Icons.pause),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 게임 정보 표시 바
  Widget _buildGameInfoBar(GameState gameState) {
    return Container(
      height: 60,
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 점수
          _buildInfoItem(
            icon: Icons.score,
            label: '점수',
            value: '${gameState.score}',
            color: Colors.amber,
          ),

          // 체력
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '체력',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: gameState.health / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade700,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      gameState.health > 60
                          ? Colors.green
                          : gameState.health > 30
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 거리
          _buildInfoItem(
            icon: Icons.straighten,
            label: '거리',
            value: '${gameState.distance}m',
            color: Colors.blue,
          ),

          // 속도
          _buildInfoItem(
            icon: Icons.speed,
            label: '속도',
            value: '${gameState.speed.toStringAsFixed(1)}x',
            color: Colors.purple,
          ),

          // 코인
          _buildInfoItem(
            icon: Icons.monetization_on,
            label: '코인',
            value: '${gameState.coins}',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  // 정보 아이템 위젯
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 배경 레인 라인
  Widget _buildLaneLines() {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 400),
      painter: LaneLinePainter(),
    );
  }

  // 장애물 위젯 생성
  List<Widget> _buildObstacles(List<Map<String, dynamic>> obstacles) {
    return obstacles.map((obstacle) {
      return Positioned(
        left: obstacle['x'].toDouble(),
        top: 50.0 + (obstacle['lane'] * 120.0),
        child: ObstacleWidget(
          type: obstacle['type'],
          isHit: obstacle['hit'],
        ),
      );
    }).toList();
  }

  // 아이템 위젯 생성
  List<Widget> _buildItems(List<Map<String, dynamic>> items) {
    return items.map((item) {
      return Positioned(
        left: item['x'].toDouble(),
        top: 50.0 + (item['lane'] * 120.0),
        child: ItemWidget(
          stockId: item['stockId'],
          isCollected: item['collected'],
        ),
      );
    }).toList();
  }

  // 뉴스 이벤트 오버레이
  Widget _buildNewsEventOverlay(Map<String, dynamic> newsEvent) {
    return Positioned(
      top: 70,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                newsEvent['title'] ?? '뉴스 이벤트',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                newsEvent['description'] ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 일시정지 화면
  Widget _buildPauseScreen() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '일시정지',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _resumeGame,
                icon: Icon(Icons.play_arrow),
                label: Text('계속하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: () {
                  _gameService.endGame();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.exit_to_app),
                label: Text('게임 종료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 레인 라인 그리는 CustomPainter
class LaneLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 상단 레인 라인
    canvas.drawLine(
      Offset(0, 110),
      Offset(size.width, 110),
      paint,
    );

    // 하단 레인 라인
    canvas.drawLine(
      Offset(0, 230),
      Offset(size.width, 230),
      paint,
    );

    // 점선 그리기 (도로 중앙선처럼)
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    double dashWidth = 20;
    double dashSpace = 10;
    double startX = 0;

    while (startX < size.width) {
      // 상단 레인 중앙 점선
      canvas.drawLine(
        Offset(startX, 50),
        Offset(startX + dashWidth, 50),
        dashPaint,
      );

      // 중앙 레인 중앙 점선
      canvas.drawLine(
        Offset(startX, 170),
        Offset(startX + dashWidth, 170),
        dashPaint,
      );

      // 하단 레인 중앙 점선
      canvas.drawLine(
        Offset(startX, 290),
        Offset(startX + dashWidth, 290),
        dashPaint,
      );

      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}