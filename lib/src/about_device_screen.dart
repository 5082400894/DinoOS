import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutDeviceScreen extends StatefulWidget {
  const AboutDeviceScreen({super.key});

  @override
  State<AboutDeviceScreen> createState() => AboutDeviceScreenState();
}

class AboutDeviceScreenState extends State<AboutDeviceScreen> {
  static const platform = MethodChannel('com.example.dino_os/device_info');
  
  Map<String, String> deviceInfo = {};


  @override
  void initState() {
    super.initState();
    loadDeviceInfo();
  }

  Future<void> loadDeviceInfo() async {
    final info = <String, String>{};

    // Basic platform info from dart:io
    info['Number of Processors'] = Platform.numberOfProcessors.toString();

    // Try to get info via platform channel
    if (Platform.isAndroid) {
      try {
        final androidInfo = await platform.invokeMethod('getDeviceInfo');
        if (androidInfo != null) {
          info.addAll(Map<String, String>.from(androidInfo));
        }
      } catch (e) {
        debugPrint('Error getting Android device info: $e');
      }
    }

    setState(() {
      deviceInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.greenAccent.shade400,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Device',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent.shade400,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/assets/wallpaper.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Device Info Card
                  buildInfoCard(
                    'Device Information',
                    [

                      buildInfoRow('Brand', deviceInfo['Brand'] ?? 'Unknown'),
                      buildInfoRow('Model', deviceInfo['Model'] ?? 'Unknown'),
                      buildInfoRow('Manufacturer', deviceInfo['Manufacturer'] ?? 'Unknown'),
                      buildInfoRow('OS', deviceInfo['OS'] ?? 'Unknown'),
                      buildInfoRow('Build Number', deviceInfo['Build Number'] ?? 'Unknown'),
                      buildInfoRow('Kernel Version', deviceInfo['Kernel Version'] ?? 'Unknown'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hardware Information
                  buildInfoCard(
                    'Hardware Information',
                    [
                      buildInfoRow('Number of Processors', deviceInfo['Number of Processors'] ?? 'Unknown'),
                      buildInfoRow('Memory (RAM)', deviceInfo['Memory'] ?? 'Unknown'),
                      buildInfoRow('Storage (Total)', deviceInfo['Storage Total'] ?? 'Unknown'),
                      buildInfoRow('Storage (Available)', deviceInfo['Storage Available'] ?? 'Unknown'),
                      buildInfoRow('Hardware', deviceInfo['Hardware'] ?? 'Unknown'),

                    ],
                  ),

                ],
              ),
            ),
    );
  }

  Widget buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.greenAccent.shade400.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent.shade400,
            ),
          ),
          const Divider(
            color: Colors.greenAccent,
            thickness: 1,
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.greenAccent,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

