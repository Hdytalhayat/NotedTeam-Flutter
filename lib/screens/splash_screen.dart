// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan warna latar yang sedikit off-white seperti logo
      backgroundColor: const Color(0xFFF8F5F1), 
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.6, // Buat logo mengambil 60% lebar layar
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }
}