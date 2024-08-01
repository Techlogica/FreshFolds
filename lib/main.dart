import 'package:flutter/material.dart';
import 'package:freshfolds_laundry/splash/splash_binding.dart';
import 'package:freshfolds_laundry/splash/splash_screen.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'home/home_binding.dart';
import 'home/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // This widget is the root of your application.
  final pages = [
    GetPage(
      name: '/splash_screen',
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    // GetPage(
    //   name: '/home_screen',
    //   // page: () => const  HomeScreen(),
    //   binding: HomeBinding(),
    // )
  ];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      color: const Color(0xFF13283F),
      title: 'Fresh Folds Laundry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF13283F)),
        useMaterial3: true,
      ),
      getPages: pages,
      initialRoute: '/splash_screen',
    );
  }
}
