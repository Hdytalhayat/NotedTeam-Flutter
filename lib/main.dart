// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/team_provider.dart'; // Impor provider baru
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
        ChangeNotifierProvider(create: (ctx) => SettingsProvider()), 
        ChangeNotifierProxyProvider<AuthProvider, TeamProvider>(
          create: (ctx) => TeamProvider(),
          update: (ctx, auth, previousTeamProvider) {
            // Setiap kali AuthProvider berubah, update token di TeamProvider
            previousTeamProvider?.updateAuthToken(auth.token);
            return previousTeamProvider!;
          },
        ),
      ],
      
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          const primaryColor = Color(0xFF6B7A8F);
          const backgroundColor = Color(0xFFF8F5F1);
          return MaterialApp(
            title: 'NotedTeam',
            themeMode: settingsProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: primaryColor,
              scaffoldBackgroundColor: backgroundColor,
              appBarTheme: const AppBarTheme(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.black87,
                elevation: 0.5,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                brightness: Brightness.light,
                background: backgroundColor
              ),
              textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: primaryColor,
              scaffoldBackgroundColor: const Color(0xFF1a1a1a),
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).primaryTextTheme),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),

            // --- KONFIGURASI LOKALISASI ---
            locale: settingsProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('id', ''), // Indonesian
            ],

            home: const AuthWrapper(),
          );
        },
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