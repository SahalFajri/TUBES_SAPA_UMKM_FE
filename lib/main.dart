import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const SapaUmkmApp());
}

class SapaUmkmApp extends StatelessWidget {
  const SapaUmkmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sapa UMKM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
