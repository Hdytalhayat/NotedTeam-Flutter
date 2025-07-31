// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      // Setelah sukses daftar, arahkan ke login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => VerifyEmailScreen(email: _emailController.text),
        ),
      );

    } catch (error) {
      _showErrorDialog(error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      // 1. Ganti Padding dengan SingleChildScrollView
      body: SingleChildScrollView(
        // 2. Letakkan Padding di dalam SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Beri padding sedikit lebih besar
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center, // Ini mungkin tidak lagi diperlukan
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 200,
                child: Image.asset('assets/images/logo.png'),
              ),
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                // Bungkus dengan SizedBox agar tombolnya lebar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Register'),
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Already have an account? Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
