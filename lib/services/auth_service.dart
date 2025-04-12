import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:antrun_game/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 인증 상태 변경 스트림 얻기
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 로그인
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // 회원가입
  Future<UserCredential> registerWithEmail(String email, String password, String nickname) async {
    try {
      // 이메일/비밀번호로 계정 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 정보 저장
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          nickname: nickname,
          level: 1,
          experience: 0,
          coins: 1000, // 초기 코인
          highScore: 0,
          createdAt: Timestamp.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());
      }

      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // 사용자 정보 가져오기
  Future<UserModel?> getUserData() async {
    try {
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('사용자 정보 가져오기 오류: $e');
      }
      return null;
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(data);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}