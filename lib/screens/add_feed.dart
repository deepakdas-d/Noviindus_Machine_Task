import 'dart:io';
import 'package:flutter/material.dart';
import 'package:noviindus/providers/add_feed_provider.dart';
import 'package:noviindus/widgets/DottedBorderContainer.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class AddFeed extends StatelessWidget {
  const AddFeed({super.key});

  Future<bool> _requestPermission(BuildContext context) async {
    var status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Please enable access.'),
        ),
      );
      openAppSettings();
      return false;
    }
  }

  Future<void> pickVideo(BuildContext context) async {
    if (!await _requestPermission(context)) return;

    final picker = ImagePicker();
    final file = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (file != null) {
      if (!file.path.toLowerCase().endsWith('.mp4')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only MP4 videos are allowed')),
        );
        return;
      }

      Provider.of<FeedProvider>(
        context,
        listen: false,
      ).setVideo(File(file.path));
    }
  }

  Future<void> pickImage(BuildContext context) async {
    if (!await _requestPermission(context)) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      Provider.of<FeedProvider>(
        context,
        listen: false,
      ).setImage(File(file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeedProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Feed', style: TextStyle(color: Colors.white)),
        actions: [
          // Share button
          Consumer<FeedProvider>(
            builder: (context, provider, _) => SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        try {
                          await provider.submitFeed();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feed uploaded successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(' Opps: ${e.toString()}'),
                              backgroundColor: const Color.fromARGB(
                                255,
                                166,
                                120,
                                117,
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    63,
                    39,
                    39,
                  ), // Fill color
                  foregroundColor: Colors.white, // Text/Icon color
                  side: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ), // Border color & width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ), // Optional padding
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Share',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: provider.loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Consumer<FeedProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Video Selection with remove option
                    DottedBorderContainer(
                      width: double.infinity,
                      height: 180,
                      borderColor: Colors.grey.shade700,
                      onTap: () => pickVideo(context),
                      child: provider.selectedVideo == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A3A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    'assets/Group 2364.png',
                                    width: 48,
                                    height: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Select a video from Gallery',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            )
                          : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: const Color(0xFF3A3A3A),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/Group 2364.png',
                                          width: 48,
                                          height: 48,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          path.basename(
                                            provider.selectedVideo!.path,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Remove button
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: provider.removeVideo,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Thumbnail Selection
                    DottedBorderContainer(
                      width: double.infinity,
                      height: 80,
                      borderColor: Colors.grey.shade700,
                      onTap: () => pickImage(context),
                      child: provider.selectedImage == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add a Thumbnail',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        provider.selectedImage!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Thumbnail Selected',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: provider
                                        .removeImage, // Add this in FeedProvider
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Description Field
                    const Text(
                      'Add Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'write a description for your feed...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: provider.setDesc,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Categories Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories This Project',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.categories.map((cat) {
                        return FilterChip(
                          label: Text(cat.title),
                          selected: cat.isSelected,
                          onSelected: (_) => provider.toggleCategory(cat),
                          backgroundColor: const Color(0xFF2A2A2A),
                          selectedColor: Colors.blue.shade700,
                          labelStyle: TextStyle(
                            color: cat.isSelected
                                ? Colors.white
                                : Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: cat.isSelected ? Colors.blue : Colors.red,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Upload progress
                    if (provider.uploadProgress > 0)
                      LinearProgressIndicator(
                        value: provider.uploadProgress,
                        backgroundColor: const Color(0xFF2A2A2A),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
