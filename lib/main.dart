import 'package:flutter/material.dart';
import 'src/boot_screen.dart';

void main() {
  runApp(const DinoOS());
}

class DinoOS extends StatelessWidget {
  const DinoOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DinoOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'monospace',
            color: Colors.greenAccent,
          ),
        ),
      ),
      home: const BootScreen(),
    );
  }
}