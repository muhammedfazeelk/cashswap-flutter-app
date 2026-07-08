import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/match/presentation/bloc/match_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CashSwapApp());
}

class CashSwapApp extends StatelessWidget {
  const CashSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AppStarted())),
        BlocProvider(create: (_) => MatchBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final router = AppRouter.router(state);
          return MaterialApp.router(
            title: 'CashSwap',
            theme: AppTheme.dark,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
