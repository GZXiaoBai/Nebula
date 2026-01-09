import 'package:flutter/material.dart';
import '../theme.dart';
import 'downloads_page.dart';
import 'completed_page.dart';
import 'accounts_page.dart';
import 'settings_page.dart';

/// 导航项定义
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}

/// 主布局框架 - 侧边栏导航 + 内容区
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isExpanded = true;

  late final AnimationController _sidebarController;
  late final Animation<double> _sidebarAnimation;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.download_outlined,
      activeIcon: Icons.download_rounded,
      label: '下载中',
      page: const DownloadsPage(),
    ),
    NavItem(
      icon: Icons.check_circle_outline_rounded,
      activeIcon: Icons.check_circle_rounded,
      label: '已完成',
      page: const CompletedPage(),
    ),
    NavItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: '账号',
      page: const AccountsPage(),
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: '设置',
      page: const SettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: NebulaTheme.animNormal,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeOutCubic,
    );
    if (_isExpanded) {
      _sidebarController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _sidebarController.forward();
    } else {
      _sidebarController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              final width = NebulaTheme.sidebarCollapsedWidth +
                  (_sidebarAnimation.value *
                      (NebulaTheme.sidebarWidth -
                          NebulaTheme.sidebarCollapsedWidth));
              return Container(
                width: width,
                decoration: BoxDecoration(
                  color: theme.nebulaSidebar,
                  border: Border(
                    right: BorderSide(
                      color: theme.nebulaBorder.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Logo 区域
                    _buildLogoArea(theme, width),
                    const SizedBox(height: NebulaTheme.spacingMd),

                    // 导航项
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NebulaTheme.spacingSm,
                        ),
                        itemCount: _navItems.length,
                        itemBuilder: (context, index) {
                          return _buildNavItem(
                            context,
                            _navItems[index],
                            index,
                            _isExpanded,
                          );
                        },
                      ),
                    ),

                    // 底部折叠按钮
                    _buildCollapseButton(theme),
                  ],
                ),
              );
            },
          ),

          // 内容区
          Expanded(
            child: AnimatedSwitcher(
              duration: NebulaTheme.animNormal,
              child: _navItems[_selectedIndex].page,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoArea(ThemeData theme, double width) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: NebulaTheme.spacingMd),
      child: Row(
        children: [
          // Logo 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: NebulaTheme.primaryGradient,
              borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
              boxShadow: NebulaTheme.glowShadow,
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          // Logo 文字 (仅在展开时显示)
          if (_isExpanded) ...[
            const SizedBox(width: NebulaTheme.spacingMd),
            Expanded(
              child: AnimatedOpacity(
                opacity: _sidebarAnimation.value,
                duration: NebulaTheme.animFast,
                child: Text(
                  'Nebula',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.nebulaTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    int index,
    bool isExpanded,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
          child: AnimatedContainer(
            duration: NebulaTheme.animFast,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? NebulaTheme.spacingMd : NebulaTheme.spacingSm,
              vertical: NebulaTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
              color: isSelected
                  ? NebulaTheme.primaryStart.withOpacity(0.15)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: NebulaTheme.primaryStart.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment:
                  isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: NebulaTheme.animFast,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? NebulaTheme.primaryStart
                        : theme.nebulaTextMuted,
                    size: 22,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: NebulaTheme.spacingMd),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _sidebarAnimation.value,
                      duration: NebulaTheme.animFast,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? NebulaTheme.primaryStart
                              : theme.nebulaTextSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(NebulaTheme.spacingMd),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
        child: InkWell(
          onTap: _toggleSidebar,
          borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
          child: Container(
            padding: const EdgeInsets.all(NebulaTheme.spacingSm),
            child: AnimatedRotation(
              turns: _isExpanded ? 0 : 0.5,
              duration: NebulaTheme.animNormal,
              child: Icon(
                Icons.keyboard_double_arrow_left_rounded,
                color: theme.nebulaTextMuted,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
