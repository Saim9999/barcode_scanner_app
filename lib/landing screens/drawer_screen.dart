import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'profile_screen.dart';
import 'sign_in_screen.dart';
import 'theme_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the sign-in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      // Handle logout errors
      print('Logout Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder:
          (context, child) => Scaffold(
            body: ListView(
              children: [
                SizedBox(height: 20.h),
                Image.asset(
                  'assets/images/Slice 1.png',
                  height: 100.h,
                  width: 100.h,
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    // visualDensity: const VisualDensity(horizontal: 4, vertical: -4),
                    onTap: () {
                      Get.to(ProfileScreen());
                    },
                    leading: Icon(Icons.person),
                    title: const Text('Profile'),
                    // horizontalTitleGap: 0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    // visualDensity: const VisualDensity(horizontal: 4, vertical: -4),
                    onTap: () {
                      Get.to(ThemeSetting());
                    },
                    leading: Icon(Icons.settings),
                    title: const Text('App Theme'),
                    // horizontalTitleGap: 0,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    // visualDensity: const VisualDensity(horizontal: 4, vertical: -4),
                    onTap: _signOut,
                    leading: Icon(Icons.logout),
                    title: const Text('LogOut'),
                    // horizontalTitleGap: 0,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
