import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _resetPassword(context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text,
        );

        // Show success message or navigate to a success screen
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Password Reset'),
                content: Text(
                  'An email with password reset instructions has been sent to your email address.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to sign-in screen or any other desired screen
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
                backgroundColor: Color.fromARGB(255, 215, 139, 25),
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
      builder:
          (context, child) => Scaffold(
            body: Column(
              children: [
                Container(
                  height: 250.h,
                  width: double.infinity.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Group 51 (4).png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 215, 139, 25),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 215, 139, 25),
                                ),
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
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                215,
                                139,
                                25,
                              ),
                            ),
                            onPressed: () async {
                              bool isConnected =
                                  await checkInternetConnectivity();
                              if (isConnected) {
                                _isLoading ? null : _resetPassword(context);
                              } else {
                                showNoInternetDialog(context);
                              }
                            },

                            child:
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
                                      'Reset Password',
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
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
