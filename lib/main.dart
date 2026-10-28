import 'package:flutter/material.dart';
import 'package:hyper_local_employee/utils/app-colorpage.dart';
import 'Splash/employeesplashscreenpage.dart';

import 'services/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();
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