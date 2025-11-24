import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity> imagevar = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Request permission
      final PermissionState permission = await PhotoManager.requestPermissionExtend();

      // Get all images from gallery
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      if (albums.isEmpty) {
        setState(() {
          imagevar = [];
          isLoading = false;
        });
        return;
      }

      // Get images from the first album 
      final AssetPathEntity recentAlbum = albums.first;
      final List<AssetEntity> images = await recentAlbum.getAssetListRange(
        start: 0,
        end: 10000, // 10000 images
      );

      setState(() {
        imagevar = images;
        isLoading = false;
      });


    } catch (e) {
      setState(() {
        errorMessage = 'Error loading images: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> showImageDialog(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
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
          'Gallery',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent.shade400,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.greenAccent.shade400,
            ),
            onPressed: loadImages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/wallpaper.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.greenAccent.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading gallery...',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.greenAccent.shade400,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.red.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: loadImages,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade400,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : imagevar.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 80,
                              color: Colors.greenAccent.shade400.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No images found',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 18,
                                color: Colors.greenAccent.shade400.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take some photos with the Camera app',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                color: Colors.greenAccent.shade400.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: imagevar.length,
                        itemBuilder: (context, index) {
                          final asset = imagevar[index];
                          return GestureDetector(
                            onTap: () => showImageDialog(asset),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.greenAccent.shade400.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: FutureBuilder<File?>(
                                  future: asset.file,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done &&
                                        snapshot.hasData &&
                                        snapshot.data != null) {
                                      return Image.file(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade900,
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey.shade600,
                                            ),
                                          );
                                        },
                                      );
                                    }
                                    return Container(
                                      color: Colors.grey.shade900,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.greenAccent.shade400,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

