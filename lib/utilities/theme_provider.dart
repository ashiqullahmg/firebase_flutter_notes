import 'package:firebase_flutter_notes/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
ThemeData light = ThemeData(
  brightness: Brightness.light,
    primaryColor: Color(0xFF303F9F),
    textTheme: TextTheme(

    ),
    fontFamily: 'Coda-Regular',
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
  // backgroundColor: Palette.lightDark,
  selectedItemColor: Colors.indigo,
  unselectedItemColor: Colors.indigo,
  // selectedIconTheme: IconThemeData(color: Palette.grey),
  // showUnselectedLabels: true,
  //   showSelectedLabels: true,
),
);

ThemeData dark = ThemeData(
  primaryColor: Palette.lightDark,
  brightness: Brightness.dark,
    fontFamily: 'Coda-Regular',
    scaffoldBackgroundColor: Palette.lightDark,
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.black.withOpacity(.2),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
  // backgroundColor: Palette.lightDark,
  selectedItemColor: Palette.grey,
  unselectedItemColor: Palette.grey,
  // selectedIconTheme: IconThemeData(color: Palette.grey),
  // showUnselectedLabels: true,
  //   showSelectedLabels: true,
),
);

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? _pref;
  bool? _darkTheme;

  bool? get darkTheme => _darkTheme;

  ThemeNotifier() {
    _darkTheme = false;
    _loadFromPrefs();
  }

  toggleTheme() {
    _darkTheme = !_darkTheme!;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _pref!.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _pref!.setBool(key, _darkTheme!);
  }
}
