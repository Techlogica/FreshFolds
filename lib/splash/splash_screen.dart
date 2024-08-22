import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freshfolds_laundry/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:http/http.dart' as http;
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late WebViewController _controller;
  String initialUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF13283F),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
                'assets/logo-white.png',
                fit: BoxFit.contain,
                width: 250,
                height: 250,
                semanticLabel:"Splash Screen for the application"
            ),
          ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 6), () => Get.off(() => HomeScreen(controller: _controller)));
    // Timer(const Duration(seconds: 6), () => Get.off(() => const LoginScreen()));
    _preloadWebView();
  }

  // Future<void> _preloadWebView() async {
  //   _controller = WebViewController();
  //   await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
  //   await _controller.loadRequest(Uri.parse('https://freshfolds.ae/mobile-1/'));
  // }


  Future<void> _preloadWebView() async {
    _controller = WebViewController();
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    bool isLoggedIn = await _checkLoginStatus();

    initialUrl = isLoggedIn
        ? 'https://freshfolds.ae/mobile-1/'
        : 'https://freshfolds.ae/mobile-main-page/';

    await _controller.loadRequest(Uri.parse(initialUrl));
  }

  Future<bool> _checkLoginStatus() async {
    try {
      final response = await http.get(Uri.parse('https://freshfolds.ae/wp-content/themes/freshfold/api-redirect.php'));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }


}
