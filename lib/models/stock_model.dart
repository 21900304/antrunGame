enum StockType {
  stock,    // 주식
  crypto,   // 암호화폐
  bond,     // 채권
  commodity // 원자재
}

enum RiskLevel {
  low,      // 저위험
  medium,   // 중위험
  high      // 고위험
}

class StockModel {
  final String id;
  final String name;
  final String symbol;
  final StockType type;
  final RiskLevel riskLevel;
  final int basePrice;
  final double volatility; // 변동성 (0.0 ~ 1.0)
  final String imageAsset;
  final String description;

  // 게임 내 효과
  final int healthBonus;    // 체력 보너스
  final int speedBonus;     // 속도 보너스
  final int scoreMultiplier; // 점수 배율

  const StockModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.riskLevel,
    required this.basePrice,
    required this.volatility,
    required this.imageAsset,
    required this.description,
    this.healthBonus = 0,
    this.speedBonus = 0,
    this.scoreMultiplier = 1,
  });

  // 가격 변동 계산 (랜덤 요소 포함)
  int calculatePriceChange(Map<String, dynamic> newsEvent) {
    // 뉴스 이벤트에 따른 가격 변동 로직
    double impact = newsEvent['impact'] ?? 0.0;

    // 종목 유형에 따른 영향도 조정
    if (newsEvent['affectedType'] == type.toString()) {
      impact *= 1.5; // 해당 종목 유형에 더 큰 영향
    }

    // 변동성에 따른 가격 변동 계산
    double randomFactor = -1.0 + (2.0 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
    double changePercent = impact + (randomFactor * volatility);

    // 최종 가격 변동 계산 (-30% ~ +30% 범위 제한)
    changePercent = changePercent.clamp(-0.3, 0.3);
    return (basePrice * changePercent).round();
  }

  // 게임 내 아이템 효과 계산
  Map<String, int> calculateGameEffects() {
    return {
      'health': healthBonus,
      'speed': speedBonus,
      'score': scoreMultiplier,
    };
  }

  // 위험도에 따른 수익률 기대값 계산
  double expectedReturn() {
    switch (riskLevel) {
      case RiskLevel.low:
        return 0.05; // 5%
      case RiskLevel.medium:
        return 0.10; // 10%
      case RiskLevel.high:
        return 0.20; // 20%
      default:
        return 0.0;
    }
  }
}

// 미리 정의된 종목 리스트
class StockDatabase {
  static List<StockModel> getStocks() {
    return [
      // 주식
      StockModel(
        id: 'samsung',
        name: '삼성전자',
        symbol: '005930',
        type: StockType.stock,
        riskLevel: RiskLevel.low,
        basePrice: 70000,
        volatility: 0.2,
        imageAsset: 'assets/images/items/samsung.png',
        description: '국내 최대 전자기업',
        healthBonus: 10,
        scoreMultiplier: 1,
      ),
      StockModel(
        id: 'tesla',
        name: '테슬라',
        symbol: 'TSLA',
        type: StockType.stock,
        riskLevel: RiskLevel.medium,
        basePrice: 800000,
        volatility: 0.5,
        imageAsset: 'assets/images/items/tesla.png',
        description: '전기차 및 클린 에너지 기업',
        speedBonus: 5,
        scoreMultiplier: 2,
      ),

      // 암호화폐
      StockModel(
        id: 'bitcoin',
        name: '비트코인',
        symbol: 'BTC',
        type: StockType.crypto,
        riskLevel: RiskLevel.high,
        basePrice: 50000000,
        volatility: 0.8,
        imageAsset: 'assets/images/items/bitcoin.png',
        description: '최초의 암호화폐',
        healthBonus: -5,
        speedBonus: 10,
        scoreMultiplier: 3,
      ),

      // 채권
      StockModel(
        id: 'treasury',
        name: '국채',
        symbol: 'BOND',
        type: StockType.bond,
        riskLevel: RiskLevel.low,
        basePrice: 10000,
        volatility: 0.1,
        imageAsset: 'assets/images/items/bond.png',
        description: '안전하지만 수익률이 낮은 투자',
        healthBonus: 20,
        speedBonus: -5,
        scoreMultiplier: 1,
      ),

      // 원자재
      StockModel(
        id: 'gold',
        name: '금',
        symbol: 'GOLD',
        type: StockType.commodity,
        riskLevel: RiskLevel.medium,
        basePrice: 2000000,
        volatility: 0.3,
        imageAsset: 'assets/images/items/gold.png',
        description: '인플레이션 헷지 자산',
        healthBonus: 15,
        scoreMultiplier: 1,
      ),
    ];
  }

  // ID로 종목 찾기
  static StockModel? findById(String id) {
    try {
      return getStocks().firstWhere((stock) => stock.id == id);
    } catch (e) {
      return null;
    }
  }
}