import 'dart:ui';

import 'package:barcode_app/qrcodescannerpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'landing screens/drawer_screen.dart';
import 'landing screens/sign_in_screen.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  _QRCodeScannerScreenState createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  String _scannedResult = '';
  WebViewController? _webViewController;

  Future<void> _scanQRCode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QRCodeScannerPage(
              onScan: (code) {
                setState(() {
                  _scannedResult = code;
                });
              },
            ),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    String url = _scannedResult.trim();

    // Check if the scanned result is a valid URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // If it's not a URL, perform a web search using a search engine
      url = 'https://www.google.com/search?q=$url';
      print('urlcheck ${url}');
    }

    Uri uri = Uri.parse(url);

    // ✅ Force external browser mode
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Failed to open URL: $url'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _shareQRCode() async {
    if (_scannedResult.isNotEmpty) {
      Share.share(_scannedResult);
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text('No QR/BarCode scanned yet.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            ),
      );
    }
  }

  void _copyUrl() {
    Clipboard.setData(ClipboardData(text: _scannedResult)).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder:
          (context, child) => Scaffold(
            appBar: AppBar(
              //  iconTheme: IconThemeData(color: Colors.black, size: 32),
              // automaticallyImplyLeading: false,
              backgroundColor: Color.fromARGB(255, 215, 139, 25),
              title: RichText(
                text: TextSpan(
                  text: 'Q&B',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' Scanner',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // actions: [IconButton(onPressed: _signOut, icon: Icon(Icons.logout))],
            ),
            drawer: Drawer(child: DrawerScreen()),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 20.h),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          // color: Color.fromARGB(255, 215, 139, 25),
                          elevation: 2.0, // Controls the shadow depth
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ), // Defines the border radius
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 20.h),
                              ListTile(
                                leading: Icon(Icons.search),
                                title: Text('Web Search'),
                                subtitle: TextButton(
                                  onPressed: _openInBrowser,
                                  child: Text(_scannedResult),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.copy),
                                title: Text('Copy Url'),
                                subtitle: TextButton(
                                  onPressed: _copyUrl,
                                  child: Text('Copy Qr/BarCode'),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.share),
                                title: Text('Share'),
                                subtitle: TextButton(
                                  onPressed: _shareQRCode,
                                  child: Text('Share QR/BarCode'),
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 5.h),
                    Center(
                      child: InkWell(
                        onTap: _scanQRCode,
                        child: Container(
                          height: 130.h,
                          width: 130.h,
                          child: Image.asset(
                            'assets/images/Slice 1.png',
                            height: 110.h,
                            width: 110.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    InkWell(
                      onTap: _scanQRCode,
                      child: Text(
                        'Tap to\n Scan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
