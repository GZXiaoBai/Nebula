import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/settings.dart' as old_settings;
import 'pages/main_shell.dart';
import 'src/rust/api/download.dart';
import 'src/rust/frb_generated.dart';
import 'settings.dart';
import 'theme.dart';
import 'providers/download_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  
  // 初始化下载管理器
  final downloadDir = await AppSettings.getDownloadPath();
  await initDownloadManager(downloadDir: downloadDir);
  
  runApp(const NebulaApp());
}

class NebulaApp extends StatelessWidget {
  const NebulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()..init()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Nebula',
            debugShowCheckedModeBanner: false,
            theme: NebulaTheme.lightTheme,
            darkTheme: NebulaTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
