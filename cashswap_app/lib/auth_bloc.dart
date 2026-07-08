import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class PhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;
  PhoneNumberSubmitted(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class OtpSubmitted extends AuthEvent {
  final String otp;
  final String verificationId;
  OtpSubmitted({required this.otp, required this.verificationId});
  @override
  List<Object?> get props => [otp, verificationId];
}

class LoggedOut extends AuthEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String userId;
  AuthAuthenticated(this.userId);
  @override
  List<Object?> get props => [userId];
}
class AuthUnauthenticated extends AuthState {}
class AuthCodeSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  AuthCodeSent({required this.verificationId, required this.phoneNumber});
  @override
  List<Object?> get props => [verificationId, phoneNumber];
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<PhoneNumberSubmitted>(_onPhoneSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final token = await SecureStore.getToken();
    final userId = await SecureStore.getUserId();
    if (token != null && userId != null) {
      emit(AuthAuthenticated(userId));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onPhoneSubmitted(
      PhoneNumberSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      String? verificationId;
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval (Android only)
          await _signInWithCredential(credential, emit);
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(e.message ?? 'Verification failed'));
        },
        codeSent: (String vId, int? resendToken) {
          verificationId = vId;
          emit(AuthCodeSent(
            verificationId: vId,
            phoneNumber: event.phoneNumber,
          ));
        },
        codeAutoRetrievalTimeout: (String vId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOtpSubmitted(
      OtpSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otp,
      );
      await _signInWithCredential(credential, emit);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Invalid OTP'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _signInWithCredential(
      PhoneAuthCredential credential, Emitter<AuthState> emit) async {
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final idToken = await userCredential.user!.getIdToken();

    // Exchange Firebase token for CashSwap JWT
    final response = await ApiClient.instance.loginWithFirebase(idToken!);
    final jwtToken = response['access_token'] as String;
    final userId = response['user_id'] as String;

    await SecureStore.saveToken(jwtToken);
    await SecureStore.saveUserId(userId);
    emit(AuthAuthenticated(userId));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    await SecureStore.clear();
    emit(AuthUnauthenticated());
  }
}
