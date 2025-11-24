import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  final ImagePicker picker = ImagePicker();
  File? capturedImage;
  bool isCapturing = false;
  bool isSaving = false;
  String statusMessage = 'Ready to capture';

  Future<void> takePicture() async {
    setState(() {
      isCapturing = true;
      statusMessage = 'Opening camera...';
    });

    try {
      // Take picture using image picker
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo != null) {
        final file = File(photo.path);
        
        setState(() {
          capturedImage = file;
          statusMessage = 'Photo captured! Saving to gallery...';
          isCapturing = false;
          isSaving = true;
        });

        // Save to gallery using gal
        try {
          await Gal.putImage(photo.path);
          
          setState(() {
            statusMessage = 'Photo saved to gallery!';
            isSaving = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Photo saved to gallery',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent.shade400,
                  ),
                ),
                backgroundColor: Colors.black87,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          setState(() {
            statusMessage = 'Error saving to gallery: ${e.toString()}';
            isSaving = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error saving photo: ${e.toString()}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                backgroundColor: Colors.red.shade900,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        setState(() {
          statusMessage = 'Photo capture cancelled';
          isCapturing = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error: ${e.toString()}';
        isCapturing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error capturing photo: ${e.toString()}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            backgroundColor: Colors.red.shade900,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
          'Camera',
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
        child: SafeArea(
          child: Column(
            children: [
              // Status message
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  statusMessage,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    color: Colors.greenAccent.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Image preview area
              Expanded(
                child: Center(
                  child: capturedImage != null
                      ? Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.greenAccent.shade400,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.shade400.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              capturedImage!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.greenAccent.shade400.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 80,
                                  color: Colors.greenAccent.shade400.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No photo captured',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 16,
                                    color: Colors.greenAccent.shade400.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              // Camera controls
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Capture button
                    GestureDetector(
                      onTap: (isCapturing || isSaving) ? null : takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isCapturing || isSaving)
                              ? Colors.grey.shade700
                              : Colors.greenAccent.shade400,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isCapturing || isSaving)
                                  ? Colors.grey.shade900
                                  : Colors.greenAccent.shade400.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: (isCapturing || isSaving)
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isCapturing
                          ? 'Capturing...'
                          : isSaving
                              ? 'Saving...'
                              : 'Tap to capture',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Colors.greenAccent.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

