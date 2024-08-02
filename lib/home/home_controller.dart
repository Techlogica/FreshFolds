import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeController extends GetxController {
  late WebViewController _controller;
  final String url = 'https://freshfolds.ae';
  RxBool _isOffline = false.obs;
  RxBool _isWebViewLoaded = false.obs;
  late DateTime currentTime;


  // late Rx<WebViewController> webController = Rx(WebViewController());
  // final Completer<WebViewController> completerController =
  //     Completer<WebViewController>();
  //
  // final String replaceHtml = '</head>';
  // final String replacedHtml =
  //     '<style type="text/css">footer {display: none;}.navbar-collapse '
  //     '{position: fixed;top: 70px;left: 0;padding-left: 15px;'
  //     'padding-right: 15px;padding-bottom: 15px;width: 75%;height: 100%;'
  //     'width: 90% !important; -webkit-transition: all 0.4s ease; '
  //     '-moz-transition: all 0.4s ease;transition: all 0.4s ease;}'
  //     '.navbar-collapse.collapsing {left: -75%;}.navbar-collapse.show '
  //     '{left: 0;}nav.navbar.bootsnav ul.nav>li>a {font-size: 18px;}'
  //     'nav.navbar.bootsnav .navbar-nav>li>a{padding: 25px 0 !important;'
  //     'border: 0 !important;}nav.navbar.bootsnav.no-full .navbar-collapse'
  //     '{max-height: none;overflow-y: hidden !important;}nav.navbar'
  //     '.navbar-default.navbar-regular.navbar-common.bootsnav.view-btn'
  //     '.on.no-full{position: fixed;}</style></head>';
  //
  // RxString changeUrl = ''.obs;
  //
  // static const String homeContent = 'homeContent';
  // static const String servicesContent = 'servicesContent';
  // static const String pricesContent = 'pricesContent';
  // static const String reviewsContent = 'reviewsContent';
  // static const String faqsContent = 'faqsContent';

  @override
  Future<void> onInit() async {
    super.onInit();
    _checkInternetConnection();
    currentTime = DateTime.now();
    // //await loadLocalWebsite();
    // //await downloadWebsiteContent();
    // await checkForInternet();
    // currentTime = DateTime.now();
    // webController.value = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onUrlChange: (url) async {
    //         if (url.url != 'about:blank') {
    //           webController.value.loadHtmlString(await loadLocalWebsite());
    //         }
    //       },
    //       onProgress: (int progress) {
    //         // Update loading bar.
    //       },
    //       onPageStarted: (String url) {
    //         changeUrl.value = url;
    //         print('start url :::: $url');
    //       },
    //       onPageFinished: (String url) {},
    //       onWebResourceError: (WebResourceError error) {},
    //       onNavigationRequest: (NavigationRequest request) {
    //         if (request.url.startsWith('https://www.youtube.com/')) {
    //           return NavigationDecision.prevent;
    //         }
    //         return NavigationDecision.navigate;
    //       },
    //     ),
    //   )
    //   ..loadHtmlString(await loadLocalWebsite());
  }



  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _isOffline.value = false;

        _loadUrl(url);
      }
    } on SocketException catch (_) {
        _isOffline.value = true;
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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (!_isOffline.value) {
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
               _isWebViewLoaded.value = true;

            _navigateToHomeScreen();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:') ||
                request.url.startsWith('whatsapp:')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _navigateToHomeScreen() {
    if (_isWebViewLoaded.value) {
      // Get.off(() => HomeScreen(controller: _controller));
    }
  }
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }














  // Future<String> loadLocalWebsite() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? htmlContent;
  //   if (changeUrl.value.contains('/services')) {
  //     htmlContent = prefs.getString(servicesContent);
  //   } else if (changeUrl.value.contains('/prices')) {
  //     htmlContent = prefs.getString(pricesContent);
  //   } else if (changeUrl.value.contains('/reviews')) {
  //     htmlContent = prefs.getString(reviewsContent);
  //   } else if (changeUrl.value.contains('/faqs')) {
  //     htmlContent = prefs.getString(faqsContent);
  //   } else {
  //     htmlContent = prefs.getString(homeContent);
  //   }
  //   htmlContent = htmlContent!.replaceAll(replaceHtml, replacedHtml);
  //   return htmlContent ?? '';
  // }
  //
  // Future<void> downloadAndStoreContent(String url, String contentKey) async {
  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     // Parse HTML content
  //     htmlDom.Document document = htmlParser.parse(response.body);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setString(contentKey, document.outerHtml);
  //   } else {
  //     throw Exception('Failed to load website content from $url');
  //   }
  // }
  //
  // Future<void> downloadWebsiteContent() async {
  //   await downloadAndStoreContent('https://freshfolds.ae', homeContent);
  //   await downloadAndStoreContent(
  //       'https://freshfolds.ae/services/', servicesContent);
  //   await downloadAndStoreContent(
  //       'https://freshfolds.ae/prices/', pricesContent);
  //   await downloadAndStoreContent(
  //       'https://freshfolds.ae/reviews/', reviewsContent);
  //   await downloadAndStoreContent('https://freshfolds.ae/faqs/', faqsContent);
  // }
  //
  // checkForInternet() async {
  //   final connectivity = await Connectivity().checkConnectivity();
  //   if (connectivity.contains(ConnectivityResult.wifi) ||
  //       connectivity.contains(ConnectivityResult.mobile)) {
  //     try {
  //       // Load live website content
  //       webController.value.loadRequest(Uri.parse('https://freshfolds.ae'));
  //       await downloadWebsiteContent();
  //     } catch (e) {
  //       // Handle download error
  //       // print('Error downloading website content: $e');
  //       // Load local website content
  //       webController.value
  //           .loadRequest(Uri.dataFromString(await loadLocalWebsite()));
  //     }
  //   } else {
  //     // Load local website content
  //     // print('Offline Data ::: ${await loadLocalWebsite()}');
  //     webController.value.loadHtmlString(await loadLocalWebsite());
  //   }
  // }
}
