import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freshfolds_laundry/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late WebViewController _controller;

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
    _preloadWebView();
  }

  Future<void> _preloadWebView() async {
    _controller = WebViewController();
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.loadRequest(Uri.parse('https://freshfolds.ae'));
  }

}