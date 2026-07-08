import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/phone_login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/match/presentation/pages/match_detail_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../auth/presentation/bloc/auth_bloc.dart';

class AppRouter {
  static GoRouter router(AuthState authState) => GoRouter(
        initialLocation: '/',
        redirect: (context, state) {
          final isLoggedIn = authState is AuthAuthenticated;
          final isAuthRoute = state.matchedLocation.startsWith('/auth');

          if (!isLoggedIn && !isAuthRoute) return '/auth/phone';
          if (isLoggedIn && isAuthRoute) return '/';
          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/auth/phone',
            builder: (_, __) => const PhoneLoginPage(),
          ),
          GoRoute(
            path: '/auth/otp',
            builder: (context, state) {
              final phone = state.extra as String;
              return OtpPage(phoneNumber: phone);
            },
          ),
          GoRoute(
            path: '/match/:matchId',
            builder: (context, state) {
              final matchId = state.pathParameters['matchId']!;
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return MatchDetailPage(matchId: matchId, matchData: extra);
            },
          ),
          GoRoute(
            path: '/chat/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return ChatPage(roomId: roomId, matchData: extra);
            },
          ),
          GoRoute(
            path: '/profile/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return ProfilePage(userId: userId);
            },
          ),
        ],
      );
}
