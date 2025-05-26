import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../models/ui_helper.dart';
import '../qcode_scanner.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  void signIn(context) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isLoading = true; // Start showing the progress indicator
      });
      try {
        final authResult =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (authResult.user != null) {
          // FocusScope.of(context).unfocus();
          // Navigate to the home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
          );
        } else {
          // Show alert dialog if sign-in is unsuccessful
          UIHelper.showAlertDialog(context, "Error Occurred!",
              "Invalid email or password. Please try again.");
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          // Show alert dialog for wrong password
          UIHelper.showAlertDialog(
              context, "Error Occurred!", "Wrong password. Please try again!");
        } else {
          // Show alert dialog for other sign-in errors
          UIHelper.showAlertDialog(
              context, "Error Occurred!", "Please enter valid email!");
        }
      } catch (e) {
        // Handle other errors
        print('Sign-in Error: $e');
      } finally {
        setState(() {
          _isLoading = false; // Stop showing the progress indicator
        });
      }
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signInWithGoogle(context) async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential using the Google sign-in token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Get the user details
      final User? user = userCredential.user;
      final String? name = user!.displayName;
      final String? email = user.email;

      // Check if the user signed up with Google
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.size > 0) {
        // User signed up with Google, navigate to the QR code screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
        );
      } else {
        // User did not sign up with Google, show an alert dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign Up with Google First'),
            content: Text(
                'You need to sign up with Google before you can log in with Google.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Sign-in with Google failed: $e');
      // Show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error Occurred!'),
          content: Text(
              'An error occurred while signing in with Google. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Function to check internet connectivity
  Future<bool> checkInternetConnectivity() async {
    return await InternetConnectionChecker.instance.hasConnection;
  }

// Function to display the "No Internet" dialog box
  void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet!'),
          content: Text('Please connect to your internet.'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 215, 139, 25)),
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      builder: (context, child) => Scaffold(
        body: Column(
          children: [
            Container(
              height: 250.h,
              width: double.infinity.w,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/Group 51 (4).png'),
                      fit: BoxFit.cover)),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 215, 139, 25)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 215, 139, 25)),
                          ),
                        ),
                        cursorColor: Color.fromARGB(255, 215, 139, 25),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 215, 139, 25)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 215, 139, 25)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color.fromARGB(255, 215, 139, 25)),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        cursorColor: Color.fromARGB(255, 215, 139, 25),
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 215, 139, 25)),
                        onPressed: 
                        //  _isLoading ? null : signIn,
                        () async {
                          bool isConnected = await checkInternetConnectivity();
                          if (isConnected) {
                            _isLoading ? null : signIn(context);
                          } else {
                            showNoInternetDialog(context);
                          }
                        },
                        child: Text(
                          'Sign In',
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      if (_isLoading)
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                Get.to(ForgotPasswordScreen());
                              },
                              child: Text(
                                'Forgot your Password',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 215, 139, 25)),
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Divider(
                                thickness: 1,
                              )),
                          SizedBox(
                            width: 30.w,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Or',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Color.fromARGB(255, 215, 139, 25)),
                            ),
                          ),
                          Expanded(
                              flex: 3,
                              child: Divider(
                                thickness: 1,
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 215, 139, 25),
                        ),
                        onPressed: () async {
                          bool isConnected = await checkInternetConnectivity();
                          if (isConnected) {
                            signInWithGoogle(context);
                          } else {
                            showNoInternetDialog(context);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 8),
                            Text('Sign In with   '),
                            Container(
                              height: 25.h,
                              width: 25.h,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/google (1).png'))),
                            )
                          ],
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: signInWithGoogle,
                      //   child: Text('Sign In with Google'),
                      // ),
                      Row(
                        children: [
                          Text('Dont have an account?'),
                          TextButton(
                            onPressed: () {
                              Get.to(SignupScreen());
                            },
                            child: Text('Sign Up',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 215, 139, 25))),
                          ),
                        ],
                      ),
                      // ElevatedButton(
                      //   onPressed: _signInWithGoogle,
                      //   child: Text('Sign in with Google'),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
