import 'package:go_router/go_router.dart';
import 'package:newsbeeper/models/news_model.dart';

import '../../models/sign_up_data.dart';
import '../../views/auth/forgot_password/forgot_password.dart';
import '../../views/auth/sign_in/sign_in_view.dart';
import '../../views/auth/sign_up/set_password_view.dart';
import '../../views/auth/sign_up/sign_up_view.dart';
import '../../views/home/home_view.dart';
import '../../views/news_detail/news_detail_view.dart';
import '../../views/saved_news/saved_news_view.dart';
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
      GoRoute(
        path: AppRouteNames.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInView(),
      ),

      // Sign up STEP 1: full name, mobile, email
      GoRoute(
        path: AppRouteNames.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpView(),
      ),

      // Sign up STEP 2: set password.
      // The data from step 1 arrives in `state.extra`. If someone lands here
      // without it (app restored on this page, deep link...), we send them
      // back to step 1 instead of crashing on a null value.
      GoRoute(
        path: AppRouteNames.setPassword,
        name: 'setPassword',
        redirect: (context, state) =>
        state.extra is SignUpData ? null : AppRouteNames.signUp,
        builder: (context, state) =>
            SetPasswordView(data: state.extra as SignUpData),
      ),

      GoRoute(
        path: AppRouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: AppRouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),

      // News details. The article arrives in `state.extra`.
      // Without it (app restored on this page...) go back to home.
      GoRoute(
        path: AppRouteNames.newsDetail,
        name: 'newsDetail',
        redirect: (context, state) =>
        state.extra is NewsModel? null : AppRouteNames.home,
        builder: (context, state) =>
            NewsDetailView(article: state.extra as NewsModel),
      ),
      GoRoute(
        path: AppRouteNames.savedNews,
        name: 'savedNews',
        builder: (context, state) => const SavedNewsView(),
      ),
    ],
  );
}