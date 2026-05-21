import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const AndariegoApp());
}

class AndariegoApp extends StatelessWidget {
  const AndariegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Andariego',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
