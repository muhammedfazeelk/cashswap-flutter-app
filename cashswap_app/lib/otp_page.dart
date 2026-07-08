import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go('/');
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify OTP'),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('Enter verification code', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'Sent to ${widget.phoneNumber}',
                style: AppTextStyles.body.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              // 6-digit OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _focusNodes[i + 1].requestFocus();
                    } else if (val.isEmpty && i > 0) {
                      _focusNodes[i - 1].requestFocus();
                    }
                    if (_otp.length == 6) _submit(context);
                  },
                )),
              ),
              const SizedBox(height: 40),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is AuthLoading ? null : () => _submit(context),
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2),
                          )
                        : const Text('Verify & Login'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_otp.length == 6) {
      // verificationId is passed via GoRouter state; get from BLoC state
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthCodeSent) {
        context.read<AuthBloc>().add(OtpSubmitted(
          otp: _otp,
          verificationId: authState.verificationId,
        ));
      }
    }
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48, height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary, fontFamily: 'Sora',
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
