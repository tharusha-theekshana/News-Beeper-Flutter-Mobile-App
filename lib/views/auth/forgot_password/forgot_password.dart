import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_messages.dart';
import '../../../core/constants/app_validators.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/logo/app_logo.dart';
import '../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../core/widgets/text_input/app_text_input.dart';
import '../../../core/widgets/texts/app_copyright_text.dart';
import '../../../core/widgets/toaster/app_snack_bar.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late Size _deviceSize;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controller
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      appBar: AppBar(),
      avoidBottomInsets: true,
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

  /// Back arrow (left) + logo (center).
  Widget _topWidgets() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _deviceSize.height * 0.015),
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
        _backToSignInLink(),
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
            'Forgot password',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Enter the email you used to sign up and we will send you a link to reset your password.',
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
            textInputAction: TextInputAction.done,
            maxLength: 100,
            validator: AppValidators.email,
            onEditingComplete: _sendResetLink,
          ),
          const SizedBox(height: 20),
          _sendButton(),
        ],
      ),
    );
  }

  // Send password reset link button
  Widget _sendButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AppButton(
          label: 'Send reset link',
          isLoading: authProvider.isLoading,
          onPressed: _sendResetLink,
        );
      },
    );
  }

  // Back to sign in button
  Widget _backToSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password ? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            ' Sign in',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // Send reset link
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendPasswordResetEmail(email: email);

    if (!mounted) return;

    if (success) {
      AppSnackBar.success(context, AppMessages.passwordResetSent(email));
      context.pop();
    } else {
      AppSnackBar.error(
        context,
        authProvider.errorMessage ?? AppMessages.genericError,
      );
    }
  }
}