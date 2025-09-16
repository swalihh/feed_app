import 'package:feeds_task/core/services/connectivity_service.dart';
import 'package:feeds_task/core/services/media_cache_service.dart';
import 'package:feeds_task/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';
import 'features/feed/presentation/pages/feed_page.dart';
import 'injection_container.dart' as di;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.setupLocator();

  await ConnectivityService().initialize();
  await MediaCacheService().initialize();
  await ThemeService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Media Feed',
          debugShowCheckedModeBanner: false,
          theme: _themeService.currentTheme,
          home: BlocProvider(
            create: (context) => di.locator<FeedBloc>(),
            child: const FeedPage(),
          ),
        );
      },
    );
  }
}
