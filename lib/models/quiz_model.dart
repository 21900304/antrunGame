class QuizModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int difficulty; // 1: 쉬움, 2: 보통, 3: 어려움
  final String category; // 주식, 채권, 암호화폐, 경제 등

  const QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
    required this.category,
  });

  // 정답 확인
  bool checkAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  // 난이도에 따른 보상 계산
  int calculateReward() {
    switch (difficulty) {
      case 1:
        return 50; // 쉬움
      case 2:
        return 100; // 보통
      case 3:
        return 200; // 어려움
      default:
        return 0;
    }
  }
}

// 미리 정의된 퀴즈 데이터베이스
class QuizDatabase {
  static List<QuizModel> getQuizzes() {
    return [
      // 주식 관련 퀴즈
      QuizModel(
        id: 'stock_01',
        question: '주가수익비율(PER)이 낮은 주식은 어떤 의미를 가질까요?',
        options: [
          '성장성이 높다',
          '저평가되어 있을 가능성이 있다',
          '배당금이 많다',
          '변동성이 크다'
        ],
        correctAnswerIndex: 1,
        explanation: 'PER(주가수익비율)이 낮은 주식은 현재 주가가 기업의 수익에 비해 저평가되어 있을 가능성이 있습니다. 하지만 항상 좋은 투자라는 의미는 아니니 다른 지표들도 함께 살펴봐야 합니다.',
        difficulty: 2,
        category: '주식',
      ),

      // 채권 관련 퀴즈
      QuizModel(
        id: 'bond_01',
        question: '금리가 상승하면 채권 가격은 어떻게 될까요?',
        options: [
          '상승한다',
          '변동이 없다',
          '하락한다',
          '예측할 수 없다'
        ],
        correctAnswerIndex: 2,
        explanation: '일반적으로 금리와 채권 가격은 반대로 움직입니다. 금리가 상승하면 새로 발행되는 채권의 이자율이 높아지기 때문에 기존 채권의 가치는 하락합니다.',
        difficulty: 1,
        category: '채권',
      ),

      // 암호화폐 관련 퀴즈
      QuizModel(
        id: 'crypto_01',
        question: '비트코인의 총 발행량은 얼마인가요?',
        options: [
          '1000만 개',
          '2100만 개',
          '무제한',
          '5000만 개'
        ],
        correctAnswerIndex: 1,
        explanation: '비트코인은 최대 2100만 개까지만 발행되도록 설계되어 있습니다. 이러한 희소성이 비트코인의 가치 상승 요인 중 하나입니다.',
        difficulty: 1,
        category: '암호화폐',
      ),

      // 경제 관련 퀴즈
      QuizModel(
        id: 'econ_01',
        question: '인플레이션이 발생하면 어떤 자산이 유리할까요?',
        options: [
          '현금',
          '정기예금',
          '실물자산(부동산, 금 등)',
          '국채'
        ],
        correctAnswerIndex: 2,
        explanation: '인플레이션 시기에는 화폐 가치가 하락하므로 현금이나 고정 수익 상품보다는 부동산, 금과 같은 실물자산이 상대적으로 유리합니다.',
        difficulty: 2,
        category: '경제',
      ),

      // 투자 전략 관련 퀴즈
      QuizModel(
        id: 'strategy_01',
        question: '분산투자의 주요 목적은 무엇인가요?',
        options: [
          '수익률 극대화',
          '세금 절감',
          '위험 분산',
          '거래비용 절감'
        ],
        correctAnswerIndex: 2,
        explanation: '분산투자의 주요 목적은 여러 자산에 투자함으로써 위험을 분산시키는 것입니다. "모든 달걀을 한 바구니에 담지 말라"는 투자 격언이 이를 잘 표현합니다.',
        difficulty: 1,
        category: '투자전략',
      ),
    ];
  }

  // 난이도별 퀴즈 가져오기
  static List<QuizModel> getQuizzesByDifficulty(int difficulty) {
    return getQuizzes().where((quiz) => quiz.difficulty == difficulty).toList();
  }

  // 카테고리별 퀴즈 가져오기
  static List<QuizModel> getQuizzesByCategory(String category) {
    return getQuizzes().where((quiz) => quiz.category == category).toList();
  }

  // 랜덤 퀴즈 가져오기
  static QuizModel getRandomQuiz() {
    final quizzes = getQuizzes();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % quizzes.length;
    return quizzes[randomIndex];
  }
}