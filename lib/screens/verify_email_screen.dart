// lib/screens/verify_email_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/responsive_layout.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;
  const VerifyEmailScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text(
                    'Verify Your Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'A verification link has been sent to your email address:\n$email',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Please click the link in the email to activate your account. You can close this window after verification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    child: const Text('Back to Login'),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],

              ),
            ),
          ),
        ),
      ),

    );
  }
}