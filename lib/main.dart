import 'package:barcode_app/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'landing screens/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const QRCodeScannerApp());
}

class QRCodeScannerApp extends StatelessWidget {
  const QRCodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'QR Code Scanner',
                // You can use the library anywhere in the app even in theme
                // theme: ThemeData(
                //   primarySwatch: Colors.blue,
                //   // textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
                // ),
                theme: themeProvider.themeData,
                home: child,
              );
            },
            child: SPlashScreen(),
          );
        },
      ),
    );
  }
}
