import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path/path.dart' as path;

import '../models/ui_helper.dart';
import '../qcode_scanner.dart';
import 'sign_in_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isSigningUp = false;
  bool _obscureText = true;
  bool _obscureText1 = true;
  File? _profileImage;

  void _selectProfileImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_profileImage == null) {
      return null;
    }

    final storageRef =
        FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
    final uploadTask = storageRef.putFile(_profileImage!);
    final snapshot = await uploadTask.whenComplete(() {});
    final imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  void signUp(context) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          setState(() {
            _isSigningUp = true;
          });

          // Create user in Firebase Authentication
          UserCredential? userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Upload profile image and get the image URL
          final imageUrl = await _uploadProfileImage(userCredential.user!.uid);

          // Save additional user data to Firebase Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': _nameController.text,
            'email': _emailController.text,
            'profileImageUrl': imageUrl ?? '',
          });

          setState(() {
            _isSigningUp = false;
          });

          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully!'),
            ),
          );

          // Navigate to the sign-in screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            setState(() {
              UIHelper.showAlertDialog(
                context,
                "Error Occurred!",
                "Email already in use. Please sign in instead.",
              );
              _isSigningUp = false;
            });
          } else {
            print("123455${e.toString()}");
            setState(() {
              UIHelper.showAlertDialog(
                context,
                "Error Occurred!",
                "An error occurred. Please try again later.",
              );
              _isSigningUp = false;
            });
          }
        } catch (e) {
          print("123455${e.toString()}");
          setState(() {
            UIHelper.showAlertDialog(
              context,
              "Error Occurred!",
              "An error occurred. Please try again later.",
            );
            _isSigningUp = false;
          });
        }
      } else {
        setState(() {
          UIHelper.showAlertDialog(
            context,
            "Error Occurred!",
            "Passwords do not match!",
          );
        });
      }
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signUpWithGoogle(context) async {
    try {
      setState(() {
        _isSigningUp = true;
      });

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
      final String? profileImageUrl = user.photoURL;

      // Save additional user data to Firebase Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'profileImageUrl': profileImageUrl ?? '',
      });

      setState(() {
        _isSigningUp = false;
      });

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
        ),
      );

      // Navigate to the sign-in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      print('Sign-up with Google failed: $e');
      setState(() {
        _isSigningUp = false;
      });
      // Show an error dialog
      UIHelper.showAlertDialog(
        context,
        "Error Occurred!",
        "An error occurred while signing up with Google. Please try again later.",
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
              backgroundColor: Color.fromARGB(255, 215, 139, 25)
            ),
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
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      GestureDetector(
                          onTap: _selectProfileImage,
                          child: Center(
                              child: Container(
                            height: 120.h,
                            width: 120.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Color.fromARGB(255, 215, 139, 25),
                              ),
                              borderRadius: BorderRadius.circular(100.r),
                            ),
                            child: Container(
                              height: 120.h,
                              width: 120.h,
                              decoration: _profileImage != null
                                  ? BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(100.r),
                                      image: DecorationImage(
                                          image: FileImage(_profileImage!),
                                          fit: BoxFit.cover),
                                    )
                                  : null,
                              child: _profileImage == null
                                  ? Icon(
                                      Icons.camera_alt,
                                      size: 50.0,
                                      color: Color.fromARGB(255, 215, 139, 25),
                                    )
                                  : null,
                            ),
                          ))),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Name',
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
                            return 'Please enter your name.';
                          }
                          return null;
                        },
                      ),
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
                        textInputAction: TextInputAction.next,
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
                              color: const Color.fromARGB(255, 215, 139, 25),
                            ),
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
                            return 'Please enter a password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          } else if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                            return 'Password must contain at least one letter';
                          } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must contain at least one number';
                          }
                          return null; // Return null if the validation passes
                        },
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 215, 139, 25)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 215, 139, 25)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText1
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color.fromARGB(255, 215, 139, 25),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText1 = !_obscureText1;
                              });
                            },
                          ),
                        ),
                        cursorColor: Color.fromARGB(255, 215, 139, 25),
                        obscureText: _obscureText1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please confirm your password.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 215, 139, 25)),
                        onPressed: 
                        () async {
                          bool isConnected = await checkInternetConnectivity();
                          if (isConnected) {
                           _isSigningUp ? null : signUp(context);
                         } else {
                           showNoInternetDialog(context);
                         }
                        },
                        // _isSigningUp ? null : signUp,
                        
                        
                        child: Text('Sign Up'),
                      ),
                      if (_isSigningUp)
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(
                            height: 10.h,
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
                            _isSigningUp ? null : signUpWithGoogle(context);
                         } else {
                           showNoInternetDialog(context);
                         }
                        },
                        
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 8),
                            Text('Sign Up with   '),
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
                      Row(
                        children: [
                          Text('Already have an account!'),
                          TextButton(
                            onPressed: () {
                              Get.to(SignInScreen());
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 215, 139, 25)),
                            ),
                          ),
                        ],
                      )
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
