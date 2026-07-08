import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneController = TextEditingController(text: '+91');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthCodeSent) {
          context.push('/auth/otp', extra: state.phoneNumber);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.error),
          );
        } else if (state is AuthAuthenticated) {
          context.go('/');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.swap_horiz_rounded,
                            color: Colors.black, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text('CashSwap',
                          style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary, fontFamily: 'Sora',
                          )),
                    ],
                  ),
                  const SizedBox(height: 48),
                  const Text('Welcome back', style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your phone number to swap cash & digital money',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 36),
                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontFamily: 'Sora', fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone, color: AppTheme.primary),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 10) return 'Enter valid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // OTP button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                      PhoneNumberSubmitted(_phoneController.text.trim()));
                                }
                              },
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.black, strokeWidth: 2),
                              )
                            : const Text('Send OTP'),
                      );
                    },
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms of Service',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
