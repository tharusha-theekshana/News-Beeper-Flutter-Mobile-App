import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_messages.dart';
import '../../core/enums/config_status.dart';
import '../../core/router/app_route_names.dart';
import '../../core/widgets/loader/app_loader.dart';
import '../../core/widgets/logo/app_logo.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/auth_provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late Size _deviceSize;

  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Duration _minSplashTime = Duration(milliseconds: 2000);

  static const int _retryDelaySeconds = 5;
  Timer? _retryTimer;
  final ValueNotifier<int> _secondsLeft = ValueNotifier<int>(
    _retryDelaySeconds,
  );

  @override
  void initState() {
    super.initState();

    // For logo animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Initialize app data
  Future<void> _initApp() async {
    final configProvider = context.read<AppConfigProvider>();
    final authProvider = context.read<AuthProvider>();

    final results = await Future.wait<dynamic>([
      configProvider.loadConfig(),
      Future<void>.delayed(_minSplashTime),
    ]);

    if (!mounted) return;

    final configLoaded = results[0] as bool;

    if (!configLoaded) {
      _startRetryCountdown();
      return;
    }
    context.go(
      authProvider.isLoggedIn ? AppRouteNames.home : AppRouteNames.signIn,
    );
  }

  // Retry connecting to server
  void _startRetryCountdown() {
    _retryTimer?.cancel();
    _secondsLeft.value = _retryDelaySeconds;

    _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _secondsLeft.value--;

      if (_secondsLeft.value <= 0) {
        timer.cancel();
        _initApp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        height: _deviceSize.height,
        width: _deviceSize.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: _deviceSize.height * 0.1),
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(scale: _scaleAnimation, child: AppLogo()),
            ),
            _bottomArea(),
          ],
        ),
      ),
    );
  }

  // Bottom widgets
  Widget _bottomArea() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 24, right: 24),
      child: Consumer<AppConfigProvider>(
        builder: (context, configProvider, _) {
          final hasError = configProvider.status == ConfigStatus.error;

          return Column(
            children: [
              if (hasError) ...[
                const AppLoader(),
                const SizedBox(height: 15),
                Text(
                  AppMessages.connectingToServer,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
              ] else
                Column(
                  children: [
                    const AppLoader(),
                    const SizedBox(height: 15),
                    Text(
                      "Discover. Read. Stay informed with the stories that matter.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
