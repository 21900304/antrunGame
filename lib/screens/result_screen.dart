import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:antrun_game/models/stock_model.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> results;

  const ResultScreen({
    Key? key,
    required this.results,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();

    // 원래 화면 모드로 복원
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 세로 모드 허용
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 결과'),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 결과 요약 카드
                _buildSummaryCard(),

                const SizedBox(height: 24),

                // 포트폴리오 카드
                _buildPortfolioCard(),

                const SizedBox(height: 24),

                // 게임 통계 카드
                _buildStatsCard(),

                const SizedBox(height: 24),

                // 투자 조언 카드
                _buildAdviceCard(),

                const SizedBox(height: 24),

                // 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '홈으로 돌아가기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 결과 요약 카드
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '게임 완료!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            '최종 점수',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '${widget.results['score']}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResultItem(
                icon: Icons.straighten,
                label: '달린 거리',
                value: '${widget.results['distance']}m',
              ),
              _buildResultItem(
                icon: Icons.monetization_on,
                label: '획득한 코인',
                value: '${widget.results['coins']}',
              ),
              _buildResultItem(
                icon: Icons.trending_up,
                label: '효율성',
                value: widget.results['efficiency'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 결과 아이템 위젯
  Widget _buildResultItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade800, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 포트폴리오 카드
  Widget _buildPortfolioCard() {
    final portfolio = widget.results['portfolio'] as List<dynamic>? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 포트폴리오',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '총 가치: ${widget.results['portfolioValue']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          portfolio.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '아직 수집한 종목이 없습니다',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          )
              : Column(
            children: [
              // 표 헤더
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        '종목',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '종류',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '수량',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '매입가',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '현재가',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),

              // 포트폴리오 항목
              ...portfolio.map((item) {
                final stock = StockDatabase.findById(item['id']);
                final purchasePrice = item['purchasePrice'] as int;
                final currentPrice = item['currentPrice'] as int? ?? purchasePrice;
                final priceChange = currentPrice - purchasePrice;
                final isPriceUp = priceChange >= 0;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${item['name']} (${item['symbol']})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _getStockTypeLabel(item['type'] ?? ''),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item['quantity']}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '$purchasePrice',
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '$currentPrice',
                          style: TextStyle(
                            color: isPriceUp ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  // 게임 통계 카드
  Widget _buildStatsCard() {
    final portfolio = widget.results['portfolio'] as List<dynamic>? ?? [];

    // 보유 종목 유형별 개수 집계
    final Map<String, int> stockTypeCounts = {};
    for (final item in portfolio) {
      final type = item['type'] ?? '';
      stockTypeCounts[type] = (stockTypeCounts[type] ?? 0) + 1;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '게임 통계',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 포트폴리오 다양성
          _buildStatProgressBar(
            label: '포트폴리오 다양성',
            value: stockTypeCounts.length / 4, // 4개 종류 중 몇 개를 가지고 있는지
            description: '다양한 종류의 자산을 보유하고 있을수록 좋습니다',
          ),

          // 수집 효율성
          _buildStatProgressBar(
            label: '수집 효율성',
            value: double.parse(widget.results['efficiency']) / 3.0, // 임의의 최대값
            description: '이동 거리 대비 높은 점수를 획득했습니다',
          ),
        ],
      ),
    );
  }

  // 통계 프로그레스 바
  Widget _buildStatProgressBar({
    required String label,
    required double value,
    required String description,
  }) {
    // 값은 0.0 ~ 1.0 범위로 제한
    final clampedValue = value.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(clampedValue * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(clampedValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clampedValue,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(clampedValue),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 진행도에 따른 색상
  Color _getProgressColor(double value) {
    if (value < 0.3) {
      return Colors.red;
    } else if (value < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // 투자 조언 카드
  Widget _buildAdviceCard() {
    final portfolio = widget.results['portfolio'] as List<dynamic>? ?? [];

    // 조언 생성 로직
    String adviceTitle = '투자 조언';
    String adviceContent = '게임을 더 플레이하여 다양한 투자 경험을 쌓아보세요!';

    if (portfolio.isEmpty) {
      adviceTitle = '포트폴리오를 구성해보세요';
      adviceContent = '다양한 종목을 수집하여 포트폴리오를 구성해보세요. 여러 종류의 자산에 분산 투자하는 것이 위험을 줄이는 좋은 방법입니다.';
    } else {
      // 종목 유형별 카운트
      int stockCount = 0;
      int cryptoCount = 0;
      int bondCount = 0;
      int commodityCount = 0;

      for (final item in portfolio) {
        final type = item['type'] ?? '';
        if (type.contains('stock')) {
          stockCount++;
        } else if (type.contains('crypto')) {
          cryptoCount++;
        } else if (type.contains('bond')) {
          bondCount++;
        } else if (type.contains('commodity')) {
          commodityCount++;
        }
      }

      // 조언 생성
      if (cryptoCount > (stockCount + bondCount + commodityCount)) {
        adviceTitle = '변동성이 높은 포트폴리오';
        adviceContent = '암호화폐에 많이 투자하고 있습니다. 변동성이 높은 자산에 집중 투자하면 큰 수익을 얻을 수 있지만, 리스크도 큽니다. 안정적인 자산도 함께 보유하는 것이 좋습니다.';
      } else if (bondCount > (stockCount + cryptoCount + commodityCount)) {
        adviceTitle = '안정적인 포트폴리오';
        adviceContent = '채권 위주의 안정적인 포트폴리오를 구성했습니다. 낮은 리스크와 함께 안정적인 수익을 기대할 수 있지만, 성장성이 높은 자산도 일부 포함시키는 것을 고려해보세요.';
      } else if (stockCount > 0 && bondCount > 0 && (cryptoCount > 0 || commodityCount > 0)) {
        adviceTitle = '균형 잡힌 포트폴리오';
        adviceContent = '다양한 자산에 골고루 투자하고 있습니다. 분산 투자는 리스크를 줄이고 안정적인 수익을 얻는 좋은 전략입니다. 계속해서 포트폴리오를 관리하고 재조정해보세요.';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Text(
                adviceTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            adviceContent,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '실제 투자는 더 복잡합니다. 투자에 앞서 충분히 공부하고 전문가와 상담하세요.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 종목 유형 라벨 가져오기
  String _getStockTypeLabel(String typeStr) {
    if (typeStr.contains('stock')) {
      return '주식';
    } else if (typeStr.contains('crypto')) {
      return '암호화폐';
    } else if (typeStr.contains('bond')) {
      return '채권';
    } else if (typeStr.contains('commodity')) {
      return '원자재';
    } else {
      return '기타';
    }
  }
}