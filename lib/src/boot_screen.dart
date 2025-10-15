import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  final List<String> bootMessages = [
    "[OK] Initializing kernel...",
    "[OK] Loading system libraries...",
    "[OK] Setting up virtual memory...",
    "[OK] Mounting file system...",
    "[OK] Starting system services...",
    "[OK] DinoOS secure environment ready.",
    "[DONE] Boot complete. Launching login..."
  ];

  final List<String> visibleMessages = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    startBootSequence();
  }

  void startBootSequence() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentIndex < bootMessages.length) {
        setState(() {
          visibleMessages.add(bootMessages[currentIndex]);
          currentIndex++;
        });
      } else {
        timer.cancel();
        
        // Navigate to Home Screen after boot
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
               MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DinoOS Logo Animation
            const Spacer(),

            Image.asset(
              "lib/assets/DinoRun.gif",
              height: 120, 
              width: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),

            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    "DinoOS",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent.shade400,
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Console boot messages
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: visibleMessages.length,
                itemBuilder: (context, index) {
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      visibleMessages[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.greenAccent,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
