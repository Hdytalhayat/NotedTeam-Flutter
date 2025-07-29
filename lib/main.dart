// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/team_provider.dart'; // Impor provider baru
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Gunakan MultiProvider
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TeamProvider>(
          create: (ctx) => TeamProvider(),
          update: (ctx, auth, previousTeamProvider) {
            // Setiap kali AuthProvider berubah, update token di TeamProvider
            previousTeamProvider?.updateAuthToken(auth.token);
            return previousTeamProvider!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'NotedTeam',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

// 3. Widget Wrapper untuk logika pemilihan layar
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance provider
    final authProvider = Provider.of<AuthProvider>(context);

    // Jika sudah terotentikasi, langsung ke HomeScreen
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      // Jika tidak, coba auto-login.
      // FutureBuilder akan menampilkan layar yang sesuai.
      return FutureBuilder(
        future: authProvider.tryAutoLogin(),
        builder: (ctx, authResultSnapshot) {
          // Selama masih loading, tampilkan splash screen
          if (authResultSnapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          // Setelah selesai, tampilkan LoginScreen
          // karena tryAutoLogin() tidak berhasil mengubah isAuthenticated
          return const LoginScreen();
        },
      );
    }
  }
}