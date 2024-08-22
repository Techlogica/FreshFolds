import 'package:flutter/material.dart';
import 'package:freshfolds_laundry/splash/splash_binding.dart';
import 'package:freshfolds_laundry/splash/splash_screen.dart';
import 'package:get/get.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final pages = [
    GetPage(
      name: '/splash_screen',
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
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
