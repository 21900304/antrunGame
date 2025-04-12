import 'package:flutter/material.dart';
import 'package:antrun_game/services/game_service.dart';
import 'package:antrun_game/models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final GameService gameService;

  const QuizScreen({
    Key? key,
    required this.gameService,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizModel? _currentQuiz;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  void _loadQuiz() {
    // 랜덤 퀴즈 가져오기
    setState(() {
      _currentQuiz = QuizDatabase.getRandomQuiz();
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });

    // 정답 확인 후 일정 시간 후 게임 계속
    final isCorrect = _currentQuiz!.checkAnswer(index);
    final reward = _currentQuiz!.calculateReward();

    Future.delayed(const Duration(seconds: 2), () {
      widget.gameService.submitQuizAnswer(_currentQuiz!, index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuiz == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
          width: 600,
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
              // 타이틀
              Row(
                children: [
                  Icon(
                    Icons.quiz,
                    color: Colors.amber,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '금융 퀴즈 타임!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(_currentQuiz!.difficulty),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getDifficultyLabel(_currentQuiz!.difficulty),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 질문
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Text(
                  _currentQuiz!.question,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 선택지
              ...List.generate(_currentQuiz!.options.length, (index) {
                final isSelected = _selectedAnswerIndex == index;
                final isCorrect = _currentQuiz!.correctAnswerIndex == index;

                // 정답 여부에 따른 색상
                Color backgroundColor = Colors.grey.shade100;
                Color borderColor = Colors.grey.shade300;

                if (_isAnswered) {
                  if (isCorrect) {
                    backgroundColor = Colors.green.shade100;
                    borderColor = Colors.green;
                  } else if (isSelected && !isCorrect) {
                    backgroundColor = Colors.red.shade100;
                    borderColor = Colors.red;
                  }
                } else if (isSelected) {
                  backgroundColor = Colors.blue.shade100;
                  borderColor = Colors.blue;
                }

                return GestureDetector(
                  onTap: () => _selectAnswer(index),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + index)}.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentQuiz!.options[index],
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (_isAnswered && isCorrect)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        else if (_isAnswered && isSelected && !isCorrect)
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ),
                );
              }),

              // 결과 및 설명
              if (_isAnswered)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '설명',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentQuiz!.explanation,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '보상: ${_currentQuiz!.calculateReward()} 코인',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return '쉬움';
      case 2:
        return '보통';
      case 3:
        return '어려움';
      default:
        return '';
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}