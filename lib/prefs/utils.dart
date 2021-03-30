import 'package:shared_preferences/shared_preferences.dart';

class Prefs{
  static SharedPreferences preferences;

  static final Prefs _instance = Prefs._internal();

  factory Prefs() {
    return _instance;
  }

  Prefs._internal();
}