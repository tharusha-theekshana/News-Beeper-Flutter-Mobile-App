import 'package:go_router/go_router.dart';
import 'package:news_beeper/core/router/app_route_names.dart';
import 'package:news_beeper/views/splash/splash_view.dart';

class AppRouter {
  late final GoRouter routers = GoRouter(
    initialLocation: AppRouteNames.splash,
    routes: [
      GoRoute(
        path: AppRouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),
    ],
  );
}