// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/responsive_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gunakan provider untuk mendapatkan state saat ini
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context)!; // Helper untuk terjemahan

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ResponsiveLayout(
        child: ListView(
          children: [
            // Pengaturan Tema
            ListTile(
              title: Text(l10n.theme),
              trailing: DropdownButton<ThemeMode>(
                value: settingsProvider.themeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(l10n.system),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(l10n.light),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(l10n.dark),
                  ),
                ],
                onChanged: (newTheme) {
                  settingsProvider.updateTheme(newTheme);
                },
              ),
            ),
            // Pengaturan Bahasa
            ListTile(
              title: Text(l10n.language),
              trailing: DropdownButton<Locale>(
                value: settingsProvider.locale,
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('id'),
                    child: Text('Indonesia'),
                  ),
                ],
                onChanged: (newLocale) {
                  if (newLocale != null) {
                    settingsProvider.updateLanguage(newLocale);
                  }
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}