// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:notedteamfrontend/screens/forgot_password_screen.dart';
import 'package:notedteamfrontend/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(message), backgroundColor: Colors.red),
    // );
    if (message.contains("Account not verified")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please verify your email before logging in."),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }

  }

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Tambahkan validasi sederhana
      _showErrorDialog("Email and password cannot be empty.");
      return;
    }

    setState(() { _isLoading = true; });

    // Dapatkan provider, tapi jangan dengarkan perubahan di sini
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Panggil metode login
      await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      // --- BAGIAN PENTING ---
      // Setelah login berhasil, state di provider sudah berubah.
      // Sekarang kita navigasi secara manual dan menghapus semua rute sebelumnya.
      // Hal ini memastikan pengguna tidak bisa menekan tombol kembali ke layar login.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const HomeScreen()),
        (route) => false,
      );
      // ----------------------

    } catch (error) {
      // Jika ada error (misal: password salah), tampilkan dialog
      // Kita hapus prefix "Exception: " agar lebih rapi
      _showErrorDialog(error.toString().replaceFirst("Exception: ", ""));
    } finally {
      // Pastikan _isLoading di-set false bahkan jika widget sudah tidak ada di pohon
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login NotedTeam')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Login'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const RegisterScreen()),
                );
              },
              child: const Text('Belum punya akun? Daftar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ForgotPasswordScreen()),
                );
              },
              child: const Text('Forgot Password?'),
            )
          ],
        ),
      ),
    );
  }
}