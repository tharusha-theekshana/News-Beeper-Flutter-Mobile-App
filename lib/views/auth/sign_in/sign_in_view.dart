import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_messages.dart';
import '../../../core/constants/app_regex.dart';
import '../../../core/enums/app_button_type.dart';
import '../../../core/router/app_route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/logo/app_logo.dart';
import '../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../core/widgets/text_input/app_text_input.dart';
import '../../../core/widgets/texts/app_copyright_text.dart';
import '../../../core/widgets/texts/divider_text.dart';
import '../../../core/widgets/toaster/app_snack_bar.dart';
import '../../../providers/auth_provider.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  late Size _deviceSize;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _topWidgets(),
            Expanded(child: SingleChildScrollView(child: _bodyWidgets())),
            _footerWidgets(),
          ],
        ),
      ),
    );
  }

  // Top widgets with logo
  Widget _topWidgets() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: _deviceSize.height * 0.015,
      ),
      child: AppLogo(size: _deviceSize.height * 0.2),
    );
  }

  Widget _bodyWidgets() {
    return Column(
      children: [
        SizedBox(height: _deviceSize.height * 0.02),
        _viewTexts(),
        SizedBox(height: _deviceSize.height * 0.025),
        _formArea(),
        SizedBox(height: _deviceSize.height * 0.03),
        _linkArea(),
      ],
    );
  }

  // Footer text
  Widget _footerWidgets() {
    return AppCopyrightText();
  }

  // Text areas
  Widget _viewTexts() {
    return SizedBox(
      width: _deviceSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign In',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Stay informed with the latest headlines, breaking news, and stories that matter to you.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Form area
  Widget _formArea() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextInput(
            controller: _emailController,
            label: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            maxLength: 100,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!AppRegex.emailRegex.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          AppTextInput(
            controller: _passwordController,
            label: 'Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              } else if (!AppRegex.passwordRegex.hasMatch(value)) {
                return 'Password must have at least one uppercase letter and one number';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _signInButton(),
        ],
      ),
    );
  }

  // All links
  Widget _linkArea() {
    return Column(
      children: [
        _forgotPassword(),
        SizedBox(height: _deviceSize.height * 0.02),
        DividerText(),
        SizedBox(height: _deviceSize.height * 0.02),
        _googleButton(),
        SizedBox(height: _deviceSize.height * 0.025),
        _signUpLink(),
        SizedBox(height: _deviceSize.height * 0.01),
      ],
    );
  }

  // Forgot password text area
  Widget _forgotPassword() {
    return GestureDetector(
      // CHANGED: opens the forgot password screen (was an empty function).
      onTap: () => context.push(AppRouteNames.forgotPassword),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Forgot Password ?",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  // Sign up with google button
  Widget _googleButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AppButton(
          label: 'Continue with Google',
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
          type: AppButtonType.outlined,
          backgroundColor: AppTheme.secondaryColor,
          icon: Icons.mail,
          isLoading: authProvider.isGoogleLoading,
          isDisabled: authProvider.isLoading,
          onPressed: _signInWithGoogle,
        );
      },
    );
  }

  // Sign up link
  Widget _signUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account ? ",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () => context.push(AppRouteNames.signUp),
          child: Text(
            ' Sign up',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // Sign in button
  Widget _signInButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AppButton(
          label: 'Sign In',
          isLoading: authProvider.isLoading,
          isDisabled: authProvider.isGoogleLoading,
          onPressed: _signIn,
        );
      },
    );
  }

  // Sign in function (email + password)
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRouteNames.home);
    } else {
      AppSnackBar.error(
        context,
        authProvider.errorMessage ?? AppMessages.genericError,
      );
    }
  }

  // Google sign in function
  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      context.go(AppRouteNames.home);
    } else if (authProvider.errorMessage != null) {
      AppSnackBar.error(context, authProvider.errorMessage!);
    }
  }
}
