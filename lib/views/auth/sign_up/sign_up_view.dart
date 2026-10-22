import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_messages.dart';
import '../../../core/constants/app_validators.dart';
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
import '../../../models/sign_up_data.dart';
import '../../../providers/auth_provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late Size _deviceSize;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _topWidgets(),
          Expanded(
            child: SingleChildScrollView(
              child: _bodyWidgets(),
            ),
          ),
          _footerWidgets(),
        ],
      ),
    );
  }

  // Top widgets with logo
  Widget _topWidgets() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _deviceSize.height * 0.01),
      child: AppLogo(size: _deviceSize.height * 0.2),
    );
  }

  Widget _bodyWidgets() {
    return Column(
      children: [
        SizedBox(height: _deviceSize.height * 0.01),
        _viewTexts(),
        SizedBox(height: _deviceSize.height * 0.02),
        _formArea(),
        SizedBox(height: _deviceSize.height * 0.025),
        const DividerText(),
        SizedBox(height: _deviceSize.height * 0.02),
        _googleButton(),
        SizedBox(height: _deviceSize.height * 0.02),
        _signInLink(),
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
    return SizedBox(
      width: _deviceSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create account',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: _deviceSize.height * 0.005),
          Text(
            'Step 1 of 2',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: _deviceSize.height * 0.01),
          Text(
            'Tell us a little about yourself. You will set your password in the next step.',
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
            controller: _fullNameController,
            label: 'Full name',
            hintText: 'John Perera',
            prefixIcon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            maxLength: 50,
            validator: AppValidators.fullName,
          ),
          const SizedBox(height: 10),
          AppTextInput(
            controller: _mobileController,
            label: 'Mobile number',
            hintText: '0771234567',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 10, // 0 + 9 digits
            validator: AppValidators.mobile,
          ),
          const SizedBox(height: 10),
          AppTextInput(
            controller: _emailController,
            label: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            maxLength: 100,
            validator: AppValidators.email,
            onEditingComplete: _goToNextStep,
          ),
          const SizedBox(height: 20),
          AppButton(label: 'Next', onPressed: _goToNextStep),
        ],
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

  // Sign in link
  Widget _signInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account ? ',
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

  // Go to password set screen
  void _goToNextStep() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.push(
      AppRouteNames.setPassword,
      extra: SignUpData(
        fullName: _fullNameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
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
      AppSnackBar.error(
        context,
        authProvider.errorMessage ?? AppMessages.genericError,
      );
    }
  }
}