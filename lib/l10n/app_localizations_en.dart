// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myTeams => 'My Teams';

  @override
  String get myInvitations => 'My Invitations';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get logout => 'Logout';

  @override
  String get noPendingInvitations => 'No pending invitations.';

  @override
  String get noTeamsJoined => 'It\'s Empty Here';

  @override
  String get createTeamToGetStarted => 'Create a team to get started.';
}
