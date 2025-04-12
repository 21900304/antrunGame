import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:antrun_game/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 정보 저장
  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        data,
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) {
        print('사용자 정보 저장 오류: $e');
      }
      rethrow;
    }
  }

  // 사용자 정보 가져오기
  Future<UserModel?> getUserData(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('사용자 정보 조회 오류: $e');
      }
      return null;
    }
  }

  // 게임 결과 저장
  Future<void> saveGameResult(String userId, Map<String, dynamic> gameResult) async {
    try {
      // 게임 기록 저장
      await _firestore.collection('users').doc(userId)
          .collection('gameHistory')
          .add({
        ...gameResult,
        'playedAt': FieldValue.serverTimestamp(),
      });

      // 사용자 정보 업데이트 (최고 점수, 코인 등)
      final userData = await getUserData(userId);

      if (userData != null) {
        final int currentHighScore = userData.highScore;
        final int gameScore = gameResult['score'] ?? 0;
        final int earnedCoins = gameResult['coins'] ?? 0;
        final int currentCoins = userData.coins;

        // 최고 점수 갱신 여부 확인
        if (gameScore > currentHighScore) {
          await _firestore.collection('users').doc(userId).update({
            'highScore': gameScore,
            'coins': currentCoins + earnedCoins,
            'lastPlayedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await _firestore.collection('users').doc(userId).update({
            'coins': currentCoins + earnedCoins,
            'lastPlayedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('게임 결과 저장 오류: $e');
      }
      rethrow;
    }
  }

  // 포트폴리오 저장
  Future<void> savePortfolio(String userId, List<Map<String, dynamic>> portfolio) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'portfolio': portfolio,
      });
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 저장 오류: $e');
      }
      rethrow;
    }
  }

  // 리더보드 가져오기
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore.collection('users')
          .orderBy('highScore', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'nickname': data['nickname'] ?? '익명',
          'highScore': data['highScore'] ?? 0,
          'level': data['level'] ?? 1,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('리더보드 조회 오류: $e');
      }
      return [];
    }
  }

  // 사용자 경험치 및 레벨 업데이트
  // 사용자 경험치 및 레벨 업데이트
  Future<void> updateUserExperience(String userId, int experienceGained) async {
    try {
      // 트랜잭션으로 처리
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(_firestore.collection('users').doc(userId));

        if (!userDoc.exists) {
          throw Exception('사용자를 찾을 수 없습니다');
        }

        final userData = UserModel.fromMap(userDoc.data()!);
        int newExperience = userData.experience + experienceGained;
        int newLevel = userData.level;

        // 레벨업 체크
        while (newExperience >= userData.calculateRequiredExp()) {
          newExperience -= userData.calculateRequiredExp();
          newLevel++;
        }

        // 데이터 업데이트
        transaction.update(_firestore.collection('users').doc(userId), {
          'experience': newExperience,
          'level': newLevel,
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('경험치 업데이트 오류: $e');
      }
      // 여기서는 에러를 다시 throw하지 말고 처리만 하거나
      // 에러 로깅만 진행하는 것이 좋습니다
      // rethrow; // 이 라인 제거 또는 주석 처리
    }
  }
}