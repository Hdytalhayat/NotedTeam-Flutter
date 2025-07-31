// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get myTeams => 'Tim Saya';

  @override
  String get myInvitations => 'Undangan Saya';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get system => 'Sistem';

  @override
  String get logout => 'Keluar';

  @override
  String get noPendingInvitations => 'Tidak ada undangan tertunda.';

  @override
  String get noTeamsJoined => 'Masih sepi nih';

  @override
  String get createTeamToGetStarted => 'Bikin tim dulu, yuk!';
}
