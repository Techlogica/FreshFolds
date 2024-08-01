import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  final WebViewController controller;

  const HomeScreen({super.key,required this.controller});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late WebViewController _controller;
  final String url = 'https://freshfolds.ae';
  bool _isOffline = false;
  // bool _isWebViewLoaded = false;
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _checkInternetConnection();
    currentTime = DateTime.now();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isOffline = false;
        });
        _loadUrl(url);
      }
    } on SocketException catch (_) {
      setState(() {
        _isOffline = true;
      });
      _loadUrl('file://${await _getFilePath()}');
    }
  }

  Future<String> _getFilePath() async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/cached_page.html';
    await file.copy(filePath);
    return filePath;
  }

  void _loadUrl(String url) {
    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (!_isOffline) {
              final content =
              await _controller.runJavaScriptReturningResult(
                  "document.documentElement.outerHTML")
              as String;
              final bytes = Uint8List.fromList(content.codeUnits);
              final directory = await getApplicationDocumentsDirectory();
              final filePath = '${directory.path}/cached_page.html';
              final file = File(filePath);
              await file.writeAsBytes(bytes);
              await DefaultCacheManager().putFile(url, bytes);
            }
            // setState(() {
            //   _isWebViewLoaded = true;
            // });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            } else if( request.url.startsWith('whatsapp://send'))
            {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13283F),
      body: WillPopScope(
        onWillPop: onWillPop,
        child:  WebViewWidget(controller: _controller)
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      DateTime now = DateTime.now();
      if (now.difference(currentTime) > const Duration(seconds: 2)) {
        currentTime = now;
        Fluttertoast.showToast(msg: 'Press again to exit');
        return Future.value(false);
      } else {
        SystemNavigator.pop();
        return Future.value(true);
      }
    }
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
