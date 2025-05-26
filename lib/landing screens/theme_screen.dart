import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';

class ThemeSetting extends StatelessWidget {
  const ThemeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        builder: (context, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 215, 139, 25),
                title: Text('Settings'),
              ),
              body: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return ListView(
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Theme Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '${themeProvider.isDarkMode ? 'Dark Theme' : 'Light Theme'}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider
                                  .toggleTheme(); // Toggle the theme using the provider
                            },
                          ),
                        ],
                      ),
                      Divider()
                    ],
                  );
                },
              ),
            ));
  }
}
