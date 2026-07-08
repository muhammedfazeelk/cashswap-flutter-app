import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(

    options:
    DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const CashSwapApp(),
  );
}

class CashSwapApp extends StatelessWidget {

  const CashSwapApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'CashSwap',

      theme: ThemeData(

        scaffoldBackgroundColor:
        const Color(0xFFF8FAFC),

        fontFamily: 'Roboto',

        colorScheme: ColorScheme.fromSeed(

          seedColor:
          const Color(0xFF2563EB),
        ),

        useMaterial3: true,
      ),

      home: FirebaseAuth.instance.currentUser
          != null

          ? const DashboardScreen()

          : const LoginScreen(),
    );
  }
}