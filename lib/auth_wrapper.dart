import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_todo/presentation/viewmodels/auth_viewmodel.dart';
import 'pages/home_screen.dart';
import 'pages/login_or_register_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthViewModel>().status;

    switch (status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginOrRegisterPage();
    }
  }
}
