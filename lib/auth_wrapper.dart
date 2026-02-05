import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_todo/services/auth_service.dart';
import 'pages/home_screen.dart';
import 'pages/login_or_register_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // If logged in, show home screen
          return const HomeScreen();
        }

        // If not logged in, show login or register page
        return const LoginOrRegisterPage();
      },
    );
  }
}
