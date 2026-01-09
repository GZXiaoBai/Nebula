import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// 静态设置帮助类 (用于新 UI 页面)
class AppSettings {
  static const _keyDownloadPath = 'download_path';
  static const _keyDarkMode = 'dark_mode';
  static const _keyAutoStart = 'auto_start';

  /// 获取下载路径
  static Future<String> getDownloadPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_keyDownloadPath);
    if (path != null && path.isNotEmpty) {
      return path;
    }
    // 默认下载目录
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/Downloads';
  }

  /// 设置下载路径
  static Future<void> setDownloadPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDownloadPath, path);
  }

  /// 获取数据目录 (用于 Bilibili cookies 等)
  static Future<String> getDataDir() async {
    final downloadPath = await getDownloadPath();
    final dataDir = '$downloadPath/.nebula';
    await Directory(dataDir).create(recursive: true);
    return dataDir;
  }

  /// 是否深色模式
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? true;
  }

  /// 设置深色模式
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  /// 是否开机启动
  static Future<bool> isAutoStart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoStart) ?? false;
  }

  /// 设置开机启动
  static Future<void> setAutoStart(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoStart, value);
  }
}
