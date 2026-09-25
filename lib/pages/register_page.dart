import 'package:flutter/material.dart';
import 'package:shared_todo/components/my_button.dart';
import 'package:shared_todo/components/my_textfield.dart';
import 'package:provider/provider.dart';
import 'package:shared_todo/presentation/viewmodels/auth_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign user in method
  void signUserUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      showErrorMessage('Passwords do not match');
      return;
    }

    final viewModel = context.read<AuthViewModel>();

    final success = await viewModel.register(
      emailController.text.trim(),
      passwordController.text,
    );

    if (!success && mounted) {
      showErrorMessage(viewModel.errorMessage ?? 'An error occurred');
    }
  }

  // Show dynamic error messages in a clean way
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: Center(
            child: Text(message, style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),

                Icon(Icons.lock, size: 50),

                SizedBox(height: 50),

                Text(
                  "let's create an account for you",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                SizedBox(height: 25),

                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                SizedBox(height: 10),

                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                SizedBox(height: 10),

                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                SizedBox(height: 10),

                SizedBox(height: 25),

                MyButton(onTap: signUserUp, text: "Sign Up"),

                SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Login now",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
