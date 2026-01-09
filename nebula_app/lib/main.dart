import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/settings.dart' as old_settings;
import 'pages/main_shell.dart';
import 'src/rust/api/download.dart';
import 'src/rust/frb_generated.dart';
import 'settings.dart';
import 'theme.dart';

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
    return ChangeNotifierProvider(
      create: (_) => old_settings.AppSettings(),
      child: MaterialApp(
        title: 'Nebula',
        debugShowCheckedModeBanner: false,
        theme: NebulaTheme.lightTheme,
        darkTheme: NebulaTheme.darkTheme,
        themeMode: ThemeMode.dark, // 默认深色模式
        home: const MainShell(),
      ),
    );
  }
}
