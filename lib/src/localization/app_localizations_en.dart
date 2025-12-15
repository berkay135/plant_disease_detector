// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Plant Disease Detector';

  @override
  String get welcomeTitle => 'Identify Your Plants';

  @override
  String get welcomeSubtitle =>
      'Take a photo of your plant and let our AI identify diseases and provide treatment suggestions.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get login => 'Login';

  @override
  String get home => 'Home';

  @override
  String get diagnose => 'Diagnose';

  @override
  String get garden => 'My Garden';

  @override
  String get settings => 'Settings';

  @override
  String get accountManagement => 'Account Management';

  @override
  String get appSettings => 'App Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Log Out';

  @override
  String get identifyPlant => 'Identify Your Plant';

  @override
  String get history => 'History';
}
