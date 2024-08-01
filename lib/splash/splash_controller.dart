import 'dart:async';

import 'package:get/get.dart';
import 'package:html/dom.dart' as htmlDom;
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Get.toNamed('/home_screen');
  }
}
