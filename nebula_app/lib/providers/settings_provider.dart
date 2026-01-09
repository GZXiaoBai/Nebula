import 'package:flutter/material.dart';
import '../settings.dart';

class SettingsProvider extends ChangeNotifier {
  String _downloadPath = '';
  bool _isDarkMode = true;
  bool _autoStart = false;

  String get downloadPath => _downloadPath;
  bool get isDarkMode => _isDarkMode;
  bool get autoStart => _autoStart;

  Future<void> init() async {
    _downloadPath = await AppSettings.getDownloadPath();
    _isDarkMode = await AppSettings.isDarkMode();
    _autoStart = await AppSettings.isAutoStart();
    notifyListeners();
  }

  Future<void> setDownloadPath(String path) async {
    await AppSettings.setDownloadPath(path);
    _downloadPath = path;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await AppSettings.setDarkMode(value);
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> setAutoStart(bool value) async {
    await AppSettings.setAutoStart(value);
    _autoStart = value;
    notifyListeners();
  }
}
