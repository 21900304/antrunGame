import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antrun_game/services/auth_service.dart';
import 'package:antrun_game/services/firestore_service.dart';
import 'package:antrun_game/models/user_model.dart';
import 'package:antrun_game/screens/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLeaderboard();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getUserData();

      setState(() {
        _userData = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 정보를 불러오는 중 오류가 발생했습니다')),
        );
      }
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboard = await _firestoreService.getLeaderboard(limit: 5);
      setState(() {
        _leaderboard = leaderboard;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리더보드를 불러오는 중 오류가 발생했습니다')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 중 오류가 발생했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
          child: Column(
            children: [
              // 상단 앱바
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '개미런',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 사용자 정보 카드
                      _buildUserInfoCard(),

                      const SizedBox(height: 24),

                      // 게임 시작 버튼
                      _buildStartGameButton(),

                      const SizedBox(height: 24),

                      // 리더보드
                      _buildLeaderboard(),

                      const SizedBox(height: 24),

                      // 게임 설명
                      _buildGameInfoCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
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
              CircleAvatar(
                backgroundColor: Colors.amber,
                radius: 30,
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData?.nickname ?? '투자자',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lv. ${_userData?.level ?? 1}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.monetization_on,
                color: Colors.amber,
                label: '코인',
                value: '${_userData?.coins ?? 0}',
              ),
              _buildStatItem(
                icon: Icons.star,
                color: Colors.orange,
                label: '최고점수',
                value: '${_userData?.highScore ?? 0}',
              ),
              _buildStatItem(
                icon: Icons.trending_up,
                color: Colors.green,
                label: '경험치',
                value: '${_userData?.experience ?? 0}/${_userData?.calculateRequiredExp() ?? 100}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
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

  Widget _buildStartGameButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(userData: _userData),
          ),
        ).then((_) {
          // 게임 종료 후 사용자 데이터 다시 로드
          _loadUserData();
          _loadLeaderboard();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_arrow,
            size: 32,
          ),
          const SizedBox(width: 8),
          Text(
            '게임 시작',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
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
            '리더보드',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _leaderboard.isEmpty
              ? Center(
            child: Text(
              '리더보드 데이터가 없습니다',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          )
              : Column(
            children: _leaderboard.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == 0
                      ? Colors.amber
                      : index == 1
                      ? Colors.grey.shade400
                      : index == 2
                      ? Colors.brown.shade300
                      : Colors.blue.shade200,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  player['nickname'] ?? '익명',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Lv. ${player['level'] ?? 1}'),
                trailing: Text(
                  '${player['highScore'] ?? 0}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoCard() {
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
            '게임 방법',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildGameInfoItem(
            icon: Icons.directions_run,
            title: '달리기',
            description: '좌우로 이동하여 장애물을 피하고 종목 아이템을 수집하세요',
          ),
          _buildGameInfoItem(
            icon: Icons.monetization_on,
            title: '투자',
            description: '수집한 종목은 포트폴리오에 추가되고 게임 내 능력치를 올려줍니다',
          ),
          _buildGameInfoItem(
            icon: Icons.quiz,
            title: '퀴즈',
            description: '가끔 등장하는 금융 퀴즈에 답하면 보상을 획득할 수 있습니다',
          ),
          _buildGameInfoItem(
            icon: Icons.newspaper,
            title: '뉴스',
            description: '뉴스 이벤트가 발생하면 종목 가치와 게임 상태가 변합니다',
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
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
    );
  }
}