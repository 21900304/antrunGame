import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final int level;
  final int experience;
  final int coins;
  final int highScore;
  final List<Map<String, dynamic>>? portfolio;
  final Timestamp createdAt;
  final Timestamp? lastPlayedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.level,
    required this.experience,
    required this.coins,
    required this.highScore,
    this.portfolio,
    required this.createdAt,
    this.lastPlayedAt,
  });

  // Firestore에서 데이터 매핑
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nickname: map['nickname'] ?? '',
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
      coins: map['coins'] ?? 0,
      highScore: map['highScore'] ?? 0,
      portfolio: map['portfolio'] != null
          ? List<Map<String, dynamic>>.from(map['portfolio'])
          : null,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      lastPlayedAt: map['lastPlayedAt'],
    );
  }

  // Firestore에 저장할 데이터 매핑
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'level': level,
      'experience': experience,
      'coins': coins,
      'highScore': highScore,
      'portfolio': portfolio,
      'createdAt': createdAt,
      'lastPlayedAt': lastPlayedAt,
    };
  }

  // 레벨업 계산 로직
  int calculateRequiredExp() {
    // 레벨에 따른 필요 경험치 계산 (예: 레벨 * 100)
    return level * 100;
  }

  // 사용자 모델 복사본 생성 (업데이트용)
  UserModel copyWith({
    String? nickname,
    int? level,
    int? experience,
    int? coins,
    int? highScore,
    List<Map<String, dynamic>>? portfolio,
    Timestamp? lastPlayedAt,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      coins: coins ?? this.coins,
      highScore: highScore ?? this.highScore,
      portfolio: portfolio ?? this.portfolio,
      createdAt: this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}