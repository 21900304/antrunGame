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
     QuizModel(
    id: 'stock_02',
    question: 'PBR이 1보다 낮다는 것은 무엇을 의미하나요?',
    options: [
      '회사가 고평가됨',
      '회사의 자산 대비 저평가됨',
      '배당이 많음',
      '성장성이 매우 높음'
    ],
    correctAnswerIndex: 1,
    explanation: 'PBR이 1보다 낮으면 자산 가치보다 낮은 주가로 거래되고 있다는 의미로, 저평가 가능성이 있습니다.',
    difficulty: 2,
    category: '주식',
  ),
   QuizModel(
  id: 'stock_03',
  question: 'ROE(Return on Equity)는 어떤 지표인가요?',
  options: ['자기자본 대비 수익률', '총자산 수익률', '부채 비율', '영업이익률'],
  correctAnswerIndex: 1,
  explanation: '정답은 1번: 자기자본 대비 수익률. ROE는 자기자본 대비 순이익의 비율로, 기업의 수익성을 나타내는 중요한 지표입니다.',
  difficulty: 2,
  category: '주식',
),
   QuizModel(
  id: 'stock_04',
  question: '주당순이익(EPS)은 무엇을 의미하나요?',
  options: ['순이익 ÷ 주식수', '매출 ÷ 주식수', '배당금 ÷ 주식수', '영업이익 ÷ 주식수'],
  correctAnswerIndex: 1,
  explanation: '정답은 1번: 순이익 ÷ 주식수. EPS는 순이익을 발행 주식 수로 나눈 값으로, 1주당 벌어들인 이익을 의미합니다.',
  difficulty: 2,
  category: '주식',
),
   QuizModel(
  id: 'stock_05',
  question: '배당수익률이 높다는 것은 일반적으로 어떤 의미인가요?',
  options: ['고배당 또는 저주가', '주가 상승 가능성', '성장 기대', '리스크 없음'],
  correctAnswerIndex: 1,
  explanation: '정답은 1번: 고배당 또는 저주가. 배당수익률은 배당금 ÷ 주가로 계산되며, 고배당 혹은 주가가 낮은 경우 높게 나타납니다.',
  difficulty: 1,
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

     QuizModel(
  id: 'bond_02',
  question: '채권의 표면이자율이란?',
  options: ['액면가 기준 연간 이자율', '시장가 기준 이자율', '할인율', '실질 수익률'],
  correctAnswerIndex: 1,
  explanation: '정답은 1번: 액면가 기준 연간 이자율. 표면이자율은 액면가에 대해 지급되는 연간 이자의 비율입니다.',
  difficulty: 1,
  category: '채권',
),

QuizModel(
  id: 'bond_03',
  question: '듀레이션이 길수록 어떤 특징이 있나요?',
  options: ['이자 수익이 낮음', '금리 변화에 민감함', '만기가 짧다', '리스크가 낮다'],
  correctAnswerIndex: 2,
  explanation: '정답은 2번: 금리 변화에 민감함. 듀레이션은 채권 가격의 금리 민감도를 나타내며, 길수록 금리 변동에 민감합니다.',
  difficulty: 1,
  category: '채권',
),

QuizModel(
  id: 'bond_04',
  question: '정크본드는 어떤 채권인가요?',
  options: ['신용등급이 낮은 고위험 채권', '정부가 발행하는 채권', '만기 없는 채권', '우량 등급 채권'],
  correctAnswerIndex: 1,
  explanation: '정답은 1번: 신용등급이 낮은 고위험 채권. 정크본드는 신용등급이 낮아 위험이 크지만 수익률이 높은 채권입니다.',
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