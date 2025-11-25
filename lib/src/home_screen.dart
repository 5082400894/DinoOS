import 'package:flutter/material.dart';
import 'about_device_screen.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';
import 'file_manager_page.dart';
import 'contacts_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Apps 
    final apps = [
      {"name": "About Device", "icon": Icons.info},
      {"name": "File Manager", "icon": Icons.folder},
      {"name": "Camera", "icon": Icons.camera_alt},
      {"name": "Gallery", "icon": Icons.photo_library},
      {"name": "Contacts", "icon": Icons.contacts},
    ];

    return Scaffold(
       body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/wallpaper.jpg"),
            fit: BoxFit.cover, 
          ),
        ),
      child: SafeArea(
        child: Column(
          children: [
            // Status bar 
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                "DinoOS Home",
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent.shade400,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grid of apps
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, 
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return GestureDetector(
                    onTap: () {
                      // App navigations will go here
                      if (app['name'] == 'About Device') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutDeviceScreen(),
                          ),
                        );
                      } else if (app['name'] == 'Camera') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraScreen(),
                          ),
                        );
                      } else if (app['name'] == 'Gallery') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GalleryScreen(),
                          ),
                        );
                      } else if (app['name'] == 'File Manager') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FileManagerPage(),
                          ),
                        );
                      }else if (app['name'] == 'Contacts') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactPage(),
                          ),
                        );
                      }  

                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${app['name']} opening...")),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.greenAccent.shade400,
                          child: Icon(
                            app['icon'] as IconData,
                            size: 28,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          app['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}