import 'package:antrun_game/screens/auth/login_screen.dart';
import 'package:antrun_game/screens/home_screen.dart';
import 'package:antrun_game/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';

const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyAHJ7VeTBcEcYchDCucmbvkWnWdnumKzEA",
    authDomain: "antrun-game.firebaseapp.com",
    projectId: "antrun-game",
    storageBucket: "antrun-game.firebasestorage.app",
    messagingSenderId: "169483559398",
    appId: "1:169483559398:web:209eee5c449e50e0db3627"
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: '개미런: 투자도 달리기처럼',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          return const HomeScreen();
        }

        // 로딩 중 보여줄 화면
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}