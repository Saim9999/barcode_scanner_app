import 'package:barcode_app/landing%20screens/sign_in_screen.dart';
import 'package:barcode_app/qcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return QRCodeScannerScreen();
          } else {
            return SignInScreen();
          }
          // if (snapshot.hasData) {
          //   print(snapshot.data);
          //   if (snapshot.data!.emailVerified) {
          //     return Homepage();
          //   } else {
          //     return VerifyPage();
          //   }
          // }
          //  else {
          //   return LoginPage();
          // }
        },
      ),
    );
  }
}
