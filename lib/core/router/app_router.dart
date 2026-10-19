import 'package:go_router/go_router.dart';

import '../../views/splash/splash_view.dart';
import 'app_route_names.dart';


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