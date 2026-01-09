import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../theme.dart';
import '../providers/settings_provider.dart';

/// 设置页
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题
          _buildHeader(theme),

          // 设置列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: NebulaTheme.spacingLg,
              ),
              children: [
                _buildSection(
                  theme,
                  title: '下载',
                  children: [
                    _buildSettingTile(
                      theme,
                      icon: Icons.folder_outlined,
                      title: '下载位置',
                      subtitle: settings.downloadPath.isEmpty ? '未设置' : settings.downloadPath,
                      onTap: () => _selectDownloadPath(context, settings),
                    ),
                  ],
                ),
                const SizedBox(height: NebulaTheme.spacingLg),
                _buildSection(
                  theme,
                  title: '外观',
                  children: [
                    _buildSwitchTile(
                      theme,
                      icon: Icons.dark_mode_outlined,
                      title: '深色模式',
                      subtitle: '使用深色主题',
                      value: settings.isDarkMode,
                      onChanged: (value) => settings.setDarkMode(value),
                    ),
                  ],
                ),
                const SizedBox(height: NebulaTheme.spacingLg),
                _buildSection(
                  theme,
                  title: '常规',
                  children: [
                    _buildSwitchTile(
                      theme,
                      icon: Icons.power_settings_new_outlined,
                      title: '开机启动',
                      subtitle: '系统启动时自动运行 (仅标记，暂未实装)',
                      value: settings.autoStart,
                      onChanged: (value) => settings.setAutoStart(value),
                    ),
                  ],
                ),
                const SizedBox(height: NebulaTheme.spacingLg),
                _buildSection(
                  theme,
                  title: '关于',
                  children: [
                    _buildSettingTile(
                      theme,
                      icon: Icons.info_outline,
                      title: '版本',
                      subtitle: 'Nebula v0.1.0',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      theme,
                      icon: Icons.code_outlined,
                      title: 'GitHub',
                      subtitle: 'https://github.com/GZXiaoBai/Nebula',
                      onTap: () {
                        launchUrlString('https://github.com/GZXiaoBai/Nebula');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(NebulaTheme.spacingLg),
      child: Text(
        '设置',
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.nebulaTextPrimary,
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: NebulaTheme.spacingSm,
            bottom: NebulaTheme.spacingSm,
          ),
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.nebulaTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.nebulaCard,
            borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
            border: Border.all(
              color: theme.nebulaBorder.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(NebulaTheme.spacingMd),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.nebulaCardHover,
                  borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
                ),
                child: Icon(icon, color: theme.nebulaTextSecondary, size: 20),
              ),
              const SizedBox(width: NebulaTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.nebulaTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.nebulaTextMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.nebulaTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(NebulaTheme.spacingMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.nebulaCardHover,
              borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
            ),
            child: Icon(icon, color: theme.nebulaTextSecondary, size: 20),
          ),
          const SizedBox(width: NebulaTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.nebulaTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.nebulaTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: NebulaTheme.primaryStart,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDownloadPath(BuildContext context, SettingsProvider settings) async {
    // 简化版：显示对话框让用户输入路径
    final controller = TextEditingController(text: settings.downloadPath);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置下载位置'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入下载目录路径',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await settings.setDownloadPath(result);
    }
  }
}
