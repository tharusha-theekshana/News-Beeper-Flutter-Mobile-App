import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newsbeeper/providers/saved_news_provider.dart';
import 'package:newsbeeper/services/saved_news_service.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/news_provider.dart';
import 'providers/user_provider.dart';
import 'services/app_config_service.dart';
import 'services/auth_service.dart';
import 'providers/app_config_provider.dart';
import 'providers/auth_provider.dart';
import 'services/news_service.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final _router = AppRouter().routers;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppConfigProvider(AppConfigService()),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(UserService()),
        ),
        ChangeNotifierProvider(
          create: (context) => NewsProvider(
            NewsService(),
            context.read<AppConfigProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SavedNewsProvider(SavedNewsService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'News Beeper',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}