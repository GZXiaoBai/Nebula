import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/settings.dart';
import '../theme.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _downloadDirController;
  late TextEditingController _proxyHostController;
  late TextEditingController _proxyPortController;
  late TextEditingController _proxyUsernameController;
  late TextEditingController _proxyPasswordController;
  late TextEditingController _listenPortController;
  late TextEditingController _trackersController;

  @override
  void initState() {
    super.initState();
    _downloadDirController =
        TextEditingController(text: widget.settings.downloadDir);
    _proxyHostController =
        TextEditingController(text: widget.settings.proxy.host);
    _proxyPortController =
        TextEditingController(text: widget.settings.proxy.port.toString());
    _proxyUsernameController =
        TextEditingController(text: widget.settings.proxy.username ?? '');
    _proxyPasswordController =
        TextEditingController(text: widget.settings.proxy.password ?? '');
    _listenPortController =
        TextEditingController(text: widget.settings.torrent.listenPort.toString());
    _trackersController = TextEditingController(
        text: widget.settings.torrent.customTrackers.join('\n'));
  }

  @override
  void dispose() {
    _downloadDirController.dispose();
    _proxyHostController.dispose();
    _proxyPortController.dispose();
    _proxyUsernameController.dispose();
    _proxyPasswordController.dispose();
    _listenPortController.dispose();
    _trackersController.dispose();
    super.dispose();
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond == 0) return '无限制';
    if (bytesPerSecond < 1024) return '$bytesPerSecond B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(0)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(NebulaTheme.spacingLg),
        children: [
          // 通用设置
          _buildSectionTitle('通用设置'),
          _buildCard([
            _buildTextFieldTile(
              icon: Icons.folder_rounded,
              title: '下载目录',
              controller: _downloadDirController,
              onChanged: (value) => widget.settings.downloadDir = value,
            ),
            const Divider(height: 1),
            _buildSliderTile(
              icon: Icons.download_rounded,
              title: '最大并行任务',
              value: widget.settings.maxConcurrentTasks.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '${widget.settings.maxConcurrentTasks}',
              onChanged: (value) {
                setState(() {
                  widget.settings.maxConcurrentTasks = value.toInt();
                });
              },
            ),
            const Divider(height: 1),
            _buildSliderTile(
              icon: Icons.speed_rounded,
              title: '下载限速',
              subtitle: _formatSpeed(widget.settings.downloadSpeedLimit),
              value: widget.settings.downloadSpeedLimit.toDouble(),
              min: 0,
              max: 10 * 1024 * 1024, // 10 MB/s
              onChanged: (value) {
                setState(() {
                  widget.settings.downloadSpeedLimit = value.toInt();
                });
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.content_paste_go_rounded,
              title: '剪贴板监控',
              subtitle: '自动识别复制的下载链接',
              value: widget.settings.clipboardMonitor,
              onChanged: (value) {
                setState(() {
                  widget.settings.clipboardMonitor = value;
                });
              },
            ),
          ]),
          const SizedBox(height: NebulaTheme.spacingLg),

          // 代理设置
          _buildSectionTitle('代理设置'),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.vpn_key_rounded,
              title: '启用代理',
              value: widget.settings.proxy.enabled,
              onChanged: (value) {
                setState(() {
                  widget.settings.proxy.enabled = value;
                });
              },
            ),
            if (widget.settings.proxy.enabled) ...[
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.category_rounded,
                title: '代理类型',
                value: widget.settings.proxy.type,
                items: const [
                  DropdownMenuItem(value: ProxyType.http, child: Text('HTTP')),
                  DropdownMenuItem(
                      value: ProxyType.socks5, child: Text('SOCKS5')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      widget.settings.proxy.type = value;
                    });
                  }
                },
              ),
              const Divider(height: 1),
              _buildTextFieldTile(
                icon: Icons.dns_rounded,
                title: '代理地址',
                controller: _proxyHostController,
                onChanged: (value) => widget.settings.proxy.host = value,
              ),
              const Divider(height: 1),
              _buildTextFieldTile(
                icon: Icons.numbers_rounded,
                title: '端口',
                controller: _proxyPortController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  widget.settings.proxy.port = int.tryParse(value) ?? 8080;
                },
              ),
            ],
          ]),
          const SizedBox(height: NebulaTheme.spacingLg),

          // BitTorrent 设置
          _buildSectionTitle('BitTorrent 设置'),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.hub_rounded,
              title: 'DHT 网络',
              subtitle: '分布式哈希表，无需 Tracker',
              value: widget.settings.torrent.enableDHT,
              onChanged: (value) {
                setState(() {
                  widget.settings.torrent.enableDHT = value;
                });
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.router_rounded,
              title: 'UPnP 端口映射',
              subtitle: '自动配置路由器端口转发',
              value: widget.settings.torrent.enableUPnP,
              onChanged: (value) {
                setState(() {
                  widget.settings.torrent.enableUPnP = value;
                });
              },
            ),
            const Divider(height: 1),
            _buildTextFieldTile(
              icon: Icons.numbers_rounded,
              title: '监听端口',
              controller: _listenPortController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                widget.settings.torrent.listenPort =
                    int.tryParse(value) ?? 6881;
              },
            ),
            const Divider(height: 1),
            _buildSliderTile(
              icon: Icons.people_rounded,
              title: '最大连接数',
              value: widget.settings.torrent.maxConnections.toDouble(),
              min: 50,
              max: 500,
              divisions: 9,
              label: '${widget.settings.torrent.maxConnections}',
              onChanged: (value) {
                setState(() {
                  widget.settings.torrent.maxConnections = value.toInt();
                });
              },
            ),
          ]),
          const SizedBox(height: NebulaTheme.spacingLg),

          // 关于
          _buildSectionTitle('关于'),
          _buildCard([
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(NebulaTheme.spacingSm),
                decoration: BoxDecoration(
                  gradient: NebulaTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: NebulaTheme.textPrimary,
                ),
              ),
              title: const Text('Nebula'),
              subtitle: const Text('v0.1.0'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: NebulaTheme.spacingSm,
        bottom: NebulaTheme.spacingSm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: NebulaTheme.textSecondary,
            ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: NebulaTheme.card,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
        border: Border.all(color: NebulaTheme.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: NebulaTheme.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: NebulaTheme.primaryStart,
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required double value,
    required double min,
    required double max,
    int? divisions,
    String? label,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: NebulaTheme.textSecondary),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            activeColor: NebulaTheme.primaryStart,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldTile({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: NebulaTheme.textSecondary),
      title: Text(title),
      subtitle: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required IconData icon,
    required String title,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: NebulaTheme.textSecondary),
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        dropdownColor: NebulaTheme.card,
      ),
    );
  }
}
