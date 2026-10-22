import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_messages.dart';
import '../../../core/constants/app_validators.dart';
import '../../../core/router/app_route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../core/widgets/text_input/app_text_input.dart';
import '../../../core/widgets/texts/app_copyright_text.dart';
import '../../../core/widgets/toaster/app_snack_bar.dart';
import '../../../models/sign_up_data.dart';
import '../../../providers/auth_provider.dart';

class SetPasswordView extends StatefulWidget {
  final SignUpData data;

  const SetPasswordView({super.key, required this.data});

  @override
  State<SetPasswordView> createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  late Size _deviceSize;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _bodyWidgets(),
              ),
            ),
            _footerWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _bodyWidgets() {
    return Column(
      children: [
        SizedBox(height: _deviceSize.height * 0.01),
        _viewTexts(),
        SizedBox(height: _deviceSize.height * 0.025),
        _formArea(),
        SizedBox(height: _deviceSize.height * 0.02),
      ],
    );
  }

  // Footer text
  Widget _footerWidgets() {
    return AppCopyrightText();
  }

  // Text areas
  Widget _viewTexts() {
    final firstName = widget.data.fullName.trim().split(' ').first;

    return SizedBox(
      width: _deviceSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your password',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: _deviceSize.height * 0.005),
          Text(
            'Step 2 of 2',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: _deviceSize.height * 0.01),
          Text(
            'Almost there, $firstName! Choose a strong password to protect your account.',
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
            controller: _passwordController,
            label: 'Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: AppValidators.password,
          ),
          const SizedBox(height: 10),
          AppTextInput(
            controller: _confirmPasswordController,
            label: 'Confirm password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            // Compares with whatever is typed in the password field.
            validator: (value) =>
                AppValidators.confirmPassword(value, _passwordController.text),
            onEditingComplete: _createAccount,
          ),
          const SizedBox(height: 20),
          _createAccountButton(),
        ],
      ),
    );
  }

  // Create account button
  Widget _createAccountButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AppButton(
          label: 'Create account',
          isLoading: authProvider.isLoading,
          onPressed: _createAccount,
        );
      },
    );
  }

  // Create account functionality
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signUp(
      fullName: widget.data.fullName,
      mobile: widget.data.mobile,
      email: widget.data.email,
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
}