import 'dart:async';

import 'package:barcode_app/qcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SPlashScreen extends StatefulWidget {
  const SPlashScreen({super.key});

  @override
  State<SPlashScreen> createState() => _SPlashScreenState();
}

class _SPlashScreenState extends State<SPlashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () => Get.to(QRCodeScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder:
          (context, child) => Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/10 Linkup scan Report 1.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 110.h,
                    width: 110.h,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Image.asset(
                                'assets/images/Group 32 (1).png',
                                height: 50.h,
                                width: 50.h,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                'assets/images/Group 44.png',
                                height: 50.h,
                                width: 50.h,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Image.asset(
                                'assets/images/Group 41.png',
                                height: 50.h,
                                width: 50.h,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Image.asset(
                                'assets/images/Group 46.png',
                                height: 50.h,
                                width: 50.h,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  RichText(
                    text: TextSpan(
                      text: 'Q&B',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '      Scanner',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
