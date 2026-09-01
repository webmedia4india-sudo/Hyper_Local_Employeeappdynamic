import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'Splash/employeesplashscreenpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyper Local Jobs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const EmployeeSplashScreenPage(),
    );
  }
}