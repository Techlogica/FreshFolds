import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
class HomeScreen extends StatefulWidget {
  final WebViewController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late WebViewController _controller;
  String url = '';
  bool _isOffline = false;
  late DateTime currentTime;
  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
    _controller = widget.controller;
    _checkInternetConnection();
    currentTime = DateTime.now();
  }

  // Future<void> _checkLoginStatus() async {
  //   try {
  //     final response = await http.get(Uri.parse('https://freshfolds.ae/wp-json/custom/v1/is_logged_in'));
  //     if (response.statusCode == 200) {
  //       if (response.body == 'true') {
  //         setState(() {
  //           url = 'https://freshfolds.ae/mobile-1/';
  //         });
  //       } else {
  //         setState(() {
  //           url = 'https://freshfolds.ae/mobile-main-page/';
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error checking login status: $e');
  //   }
  // }

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
          onPageStarted: (String url){
            _injectCSS();
          },
          onProgress: (int progress) {
            _injectCSS();
          },
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
            _injectCSS();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('whatsapp://send')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _injectCSS() {
    String cssStyles = """
      .page-id-3329 .whatsapp.mobonly {
        display: block !important;
        position: relative;
        bottom: 0px;
        width: 24px;
      }
      .page-id-3329 .whatsapp {
        display: none;
      }
      .page-id-3329 #displayAppMob {
        display: block !important;
      }
      .page-id-3329 header#home {
        display: none;
      }
      .dn-m {
        display: none;
      }
      .page-id-3329 h2.elementor-heading-title.elementor-size-default {
        font-family: "Roboto", Sans-serif !important;
        font-size: 18px;
        margin: 40px 0 2px 0;
        line-height: 1.6em;
        font-weight: 600 !important;
        letter-spacing: 0.5px;
      }
      .page-id-3329 .elementor-widget-divider--view-line.elementor-widget.elementor-widget-divider {
        display: none;
      }
      .page-id-3329 .pricesList h3.elementor-heading-title.elementor-size-default {
        font-size: 16px !important;
        letter-spacing: 0.4px;
      }
      .page-id-3329 .pricesList.e-flex.e-con-boxed.e-con.e-parent {
        padding: 0;
      }
      .page-id-3329 .pricesList .elementor-element.e-con-full.e-flex.e-con.e-child {
        margin-bottom: 5%;
        padding: 6% 3%;
        box-shadow: 0px 0px 10px 0px rgb(185 185 185 / 28%);
      }
      .page-id-3329 section#conTactForm {
        display: none;
      }
      .page.page-id-3329 .page-content.default-padding {
        background: none;
      }
      .page-id-3329 .OnlyMob {
        margin-top: 70px;
      }
      .page-id-3329 .margin-bmApp {
        display: none;
      }
      .page-id-3329 .pricesList.pm {
        padding-bottom: 60px !important;
      }
    """;

    String jsCode = """
      var style = document.createElement('style');
      style.innerHTML = `$cssStyles`;
      document.head.appendChild(style);
    """;

    _controller.runJavaScript(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13283F),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (await _controller.canGoBack()) {
      DateTime now = DateTime.now();
      if (now.difference(currentTime) > const Duration(seconds: 2)) {
        currentTime = now;
        Fluttertoast.showToast(msg: 'Press again to exit');
        return Future.value(false);
      } else {
        SystemNavigator.pop();
        return Future.value(true);
      }
      // _controller.goBack();
      // return Future.value(false);
    } else {
      _controller.goBack();
      return Future.value(false);
      // DateTime now = DateTime.now();
      // if (now.difference(currentTime) > const Duration(seconds: 2)) {
      //   currentTime = now;
      //   Fluttertoast.showToast(msg: 'Press again to exit');
      //   return Future.value(false);
      // } else {
      //   SystemNavigator.pop();
      //   return Future.value(true);
      // }
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