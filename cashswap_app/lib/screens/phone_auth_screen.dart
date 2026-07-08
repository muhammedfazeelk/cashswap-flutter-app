import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {

  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() =>
      _PhoneAuthScreenState();
}

class _PhoneAuthScreenState
    extends State<PhoneAuthScreen> {

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  String verificationId = "";

  Future<void> sendOTP() async {

    await FirebaseAuth.instance.verifyPhoneNumber(

      phoneNumber: phoneController.text,

      verificationCompleted:
          (PhoneAuthCredential credential) {},

      verificationFailed:
          (FirebaseAuthException e) {

        print(e.message);
      },

      codeSent:
          (String verId, int? resendToken) {

        setState(() {
          verificationId = verId;
        });

        print("OTP Sent");
      },

      codeAutoRetrievalTimeout:
          (String verId) {},
    );
  }

  Future<void> verifyOTP() async {

    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.text,
    );

    await FirebaseAuth.instance
        .signInWithCredential(credential);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login Successful"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("CashSwap Login"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: sendOTP,
              child: const Text("Send OTP"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: verifyOTP,
              child: const Text("Verify OTP"),
            ),

          ],
        ),
      ),
    );
  }
}