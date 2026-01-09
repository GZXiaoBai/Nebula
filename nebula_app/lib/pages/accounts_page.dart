import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme.dart';
import '../src/rust/api/download.dart';
import '../settings.dart';

/// 账号管理页
class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool _isBilibiliLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() => _isLoading = true);
    try {
      final dataDir = await AppSettings.getDataDir();
      final loggedIn = await isBilibiliLoggedIn(dataDir: dataDir);
      setState(() {
        _isBilibiliLoggedIn = loggedIn;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题
          _buildHeader(theme),

          // 账号列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: NebulaTheme.spacingLg,
              ),
              children: [
                _buildBilibiliCard(theme),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '账号管理',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.nebulaTextPrimary,
            ),
          ),
          const SizedBox(height: NebulaTheme.spacingSm),
          Text(
            '登录账号后可下载会员专属高画质视频',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.nebulaTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBilibiliCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(NebulaTheme.spacingLg),
      decoration: BoxDecoration(
        color: theme.nebulaCard,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
        border: Border.all(
          color: theme.nebulaBorder.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Bilibili Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFB7299), Color(0xFFFF9CB8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: NebulaTheme.spacingMd),

          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bilibili',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.nebulaTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (_isLoading)
                  Text(
                    '检查中...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.nebulaTextMuted,
                    ),
                  )
                else if (_isBilibiliLoggedIn)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: NebulaTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '已登录 · 可下载 4K/8K 视频',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: NebulaTheme.success,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '未登录',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.nebulaTextMuted,
                    ),
                  ),
              ],
            ),
          ),

          // 操作按钮
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_isBilibiliLoggedIn)
            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: NebulaTheme.error,
                side: const BorderSide(color: NebulaTheme.error),
              ),
              child: const Text('退出登录'),
            )
          else
            FilledButton.icon(
              onPressed: _showLoginDialog,
              icon: const Icon(Icons.qr_code_rounded, size: 18),
              label: const Text('扫码登录'),
            ),
        ],
      ),
    );
  }

  Future<void> _showLoginDialog() async {
    // 重新生成后，BilibiliLoginStatus 等类型可用
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _BilibiliLoginDialog(),
    );

    if (result == true) {
      _checkLoginStatus();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('退出后将无法下载会员专属高画质视频'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: NebulaTheme.error,
            ),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dataDir = await AppSettings.getDataDir();
        await logoutBilibili(dataDir: dataDir);
        _checkLoginStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已退出 Bilibili 账号')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('退出失败: $e')),
          );
        }
      }
    }
  }
}

/// Bilibili 扫码登录对话框
class _BilibiliLoginDialog extends StatefulWidget {
  const _BilibiliLoginDialog();

  @override
  State<_BilibiliLoginDialog> createState() => _BilibiliLoginDialogState();
}

class _BilibiliLoginDialogState extends State<_BilibiliLoginDialog> {
  String? _qrCodeUrl;
  String? _qrCodeKey;
  String _statusText = '正在生成二维码...';
  bool _isLoading = true;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<void> _generateQrCode() async {
    setState(() {
      _isLoading = true;
      _isExpired = false;
      _statusText = '正在生成二维码...';
    });

    try {
      final dataDir = await AppSettings.getDataDir();
      final qr = await generateBilibiliQrcode(dataDir: dataDir);
      setState(() {
        _qrCodeUrl = qr.url;
        _qrCodeKey = qr.qrcodeKey;
        _isLoading = false;
        _statusText = '请使用 Bilibili App 扫描二维码';
      });
      _startPolling();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusText = '生成二维码失败: $e';
      });
    }
  }

  Future<void> _startPolling() async {
    if (_qrCodeKey == null) return;

    while (mounted && _qrCodeKey != null && !_isExpired) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      try {
        final dataDir = await AppSettings.getDataDir();
        final status = await pollBilibiliLogin(
          dataDir: dataDir,
          qrcodeKey: _qrCodeKey!,
        );

        status.when(
          waitingScan: () => setState(() => _statusText = '等待扫描...'),
          waitingConfirm: () => setState(() => _statusText = '扫描成功，请在手机上确认'),
          success: () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          },
          expired: () => setState(() {
            _isExpired = true;
            _statusText = '二维码已过期，请刷新';
          }),
          failed: (error) => setState(() => _statusText = '登录失败: $error'),
        );
        
        if (status is BilibiliLoginStatus_Success) return; 
        if (status is BilibiliLoginStatus_Expired) return;
        if (status is BilibiliLoginStatus_Failed) return;

      } catch (e) {
        // 继续轮询
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NebulaTheme.radiusLg),
      ),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(NebulaTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.qr_code_rounded, size: 24),
                const SizedBox(width: NebulaTheme.spacingSm),
                Text(
                  'Bilibili 扫码登录',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: NebulaTheme.spacingLg),

            // 二维码
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _qrCodeUrl != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImageView(
                              data: _qrCodeUrl!,
                              size: 180,
                              backgroundColor: Colors.white,
                            ),
                            if (_isExpired)
                              Container(
                                color: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  onPressed: _generateQrCode,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 48,
                                    color: NebulaTheme.primaryStart,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : const Center(
                          child: Icon(Icons.error_outline, size: 48),
                        ),
            ),
            const SizedBox(height: NebulaTheme.spacingMd),

            // 状态文字
            Text(
              _statusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _isExpired ? NebulaTheme.warning : theme.nebulaTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NebulaTheme.spacingMd),

            // 刷新按钮
            if (_isExpired)
              FilledButton.icon(
                onPressed: _generateQrCode,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('刷新二维码'),
              ),
          ],
        ),
      ),
    );
  }
}
