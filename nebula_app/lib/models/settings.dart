import 'package:flutter/foundation.dart';

/// 应用设置
class AppSettings extends ChangeNotifier {
  // 下载目录
  String _downloadDir = '/Users/zhoujunjie/Downloads';
  String get downloadDir => _downloadDir;
  set downloadDir(String value) {
    _downloadDir = value;
    notifyListeners();
  }

  // 最大并行任务数
  int _maxConcurrentTasks = 3;
  int get maxConcurrentTasks => _maxConcurrentTasks;
  set maxConcurrentTasks(int value) {
    _maxConcurrentTasks = value.clamp(1, 10);
    notifyListeners();
  }

  // 下载速度限制 (0 = 无限制, bytes/s)
  int _downloadSpeedLimit = 0;
  int get downloadSpeedLimit => _downloadSpeedLimit;
  set downloadSpeedLimit(int value) {
    _downloadSpeedLimit = value.clamp(0, 1024 * 1024 * 100); // 最大 100 MB/s
    notifyListeners();
  }

  // 上传速度限制 (0 = 无限制, bytes/s)
  int _uploadSpeedLimit = 0;
  int get uploadSpeedLimit => _uploadSpeedLimit;
  set uploadSpeedLimit(int value) {
    _uploadSpeedLimit = value.clamp(0, 1024 * 1024 * 100);
    notifyListeners();
  }

  // 剪贴板监控
  bool _clipboardMonitor = false;
  bool get clipboardMonitor => _clipboardMonitor;
  set clipboardMonitor(bool value) {
    _clipboardMonitor = value;
    notifyListeners();
  }

  // 代理设置
  ProxySettings _proxy = ProxySettings();
  ProxySettings get proxy => _proxy;
  set proxy(ProxySettings value) {
    _proxy = value;
    notifyListeners();
  }

  // BitTorrent 设置
  TorrentSettings _torrent = TorrentSettings();
  TorrentSettings get torrent => _torrent;
  set torrent(TorrentSettings value) {
    _torrent = value;
    notifyListeners();
  }
}

/// 代理类型
enum ProxyType { http, socks5 }

/// 代理设置
class ProxySettings {
  bool enabled;
  ProxyType type;
  String host;
  int port;
  String? username;
  String? password;

  ProxySettings({
    this.enabled = false,
    this.type = ProxyType.http,
    this.host = '',
    this.port = 8080,
    this.username,
    this.password,
  });

  String get proxyUrl {
    if (!enabled || host.isEmpty) return '';
    final auth =
        username != null && password != null ? '$username:$password@' : '';
    final scheme = type == ProxyType.socks5 ? 'socks5' : 'http';
    return '$scheme://$auth$host:$port';
  }
}

/// BitTorrent 设置
class TorrentSettings {
  bool enableDHT;
  bool enableUPnP;
  int listenPort;
  int maxConnections;
  List<String> customTrackers;

  TorrentSettings({
    this.enableDHT = true,
    this.enableUPnP = true,
    this.listenPort = 6881,
    this.maxConnections = 200,
    this.customTrackers = const [],
  });
}
