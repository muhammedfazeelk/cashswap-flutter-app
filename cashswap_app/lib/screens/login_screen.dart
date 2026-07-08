import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final phoneController =
      TextEditingController();

  final otpController =
      TextEditingController();

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  String verificationId = "";

  bool otpSent = false;

  bool isLoading = false;

  Future<void> sendOTP() async {

    setState(() {
      isLoading = true;
    });

    await auth.verifyPhoneNumber(

      phoneNumber:
      phoneController.text,

      verificationCompleted:
          (PhoneAuthCredential credential)
      async {

        await auth.signInWithCredential(
          credential,
        );
      },

      verificationFailed:
          (FirebaseAuthException e) {

        print(e.message);
      },

      codeSent:
          (String verId, int? resendToken) {

        setState(() {

          verificationId =
              verId;

          otpSent = true;
        });
      },

      codeAutoRetrievalTimeout:
          (String verId) {},
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> verifyOTP() async {

    try {

      PhoneAuthCredential credential =

      PhoneAuthProvider.credential(

        verificationId:
        verificationId,

        smsCode:
        otpController.text,
      );

      await auth.signInWithCredential(
        credential,
      );

      if (mounted) {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
            const DashboardScreen(),
          ),
        );
      }

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> loginTestUser() async {

    try {

      await FirebaseAuth.instance
          .signOut();

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(

        email:
        "jasontt82@gmail.com",

        password:
        "123456",
      );

      print(
        FirebaseAuth.instance
            .currentUser
            ?.uid,
      );

      if (mounted) {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
            const DashboardScreen(),
          ),
        );
      }

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF8FAFC),

      body: Padding(

        padding:
        const EdgeInsets.all(24),

        child: SingleChildScrollView(

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(
                height: 80,
              ),

              const Text(

                "Welcome to CashSwap",

                style: TextStyle(

                  fontSize: 34,

                  fontWeight:
                  FontWeight.bold,

                  color:
                  Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 12),

              const Text(

                "Secure nearby cash exchange",

                style: TextStyle(

                  color: Colors.grey,

                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              TextField(

                controller:
                phoneController,

                keyboardType:
                TextInputType.phone,

                decoration:
                InputDecoration(

                  hintText:
                  "+91XXXXXXXXXX",

                  filled: true,

                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(20),

                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (otpSent)

                TextField(

                  controller:
                  otpController,

                  keyboardType:
                  TextInputType.number,

                  decoration:
                  InputDecoration(

                    hintText:
                    "Enter OTP",

                    filled: true,

                    fillColor:
                    Colors.white,

                    border:
                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(20),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              SizedBox(

                width:
                double.infinity,

                height: 58,

                child: ElevatedButton(

                  onPressed:
                  isLoading

                      ? null

                      : otpSent

                      ? verifyOTP

                      : sendOTP,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xFF2563EB),

                    foregroundColor:
                    Colors.white,

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                  ),

                  child:
                  isLoading

                      ? const CircularProgressIndicator(
                    color:
                    Colors.white,
                  )

                      : Text(

                    otpSent

                        ? "Verify OTP"

                        : "Send OTP",

                    style:
                    const TextStyle(

                      fontSize: 18,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(

                width:
                double.infinity,

                height: 58,

                child: ElevatedButton(

                  onPressed:
                  loginTestUser,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.green,

                    foregroundColor:
                    Colors.white,

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),

                  child: const Text(

                    "Login as Test User",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}