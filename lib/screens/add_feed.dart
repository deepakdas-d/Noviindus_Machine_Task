import 'dart:io';
import 'package:flutter/material.dart';
import 'package:noviindus/providers/add_feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddFeed extends StatelessWidget {
  const AddFeed({super.key});

  Future<bool> _requestPermission(BuildContext context) async {
    var status = await Permission.photos.request(); // iOS
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.storage.request(); // Android
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
      appBar: AppBar(title: const Text('Add Feed')),
      body: FutureBuilder(
        future: provider.loadCategories(), // Load categories once
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<FeedProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onChanged: provider.setDesc,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => pickVideo(context),
                      child: Text(
                        provider.selectedVideo == null
                            ? 'Pick Video'
                            : 'Video Selected',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => pickImage(context),
                      child: Text(
                        provider.selectedImage == null
                            ? 'Pick Thumbnail'
                            : 'Image Selected',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ...provider.categories.map((cat) {
                      return CheckboxListTile(
                        value: cat.isSelected,
                        title: Text(cat.title),
                        onChanged: (_) => provider.toggleCategory(cat),
                      );
                    }),
                    const SizedBox(height: 16),
                    if (provider.uploadProgress > 0)
                      LinearProgressIndicator(value: provider.uploadProgress),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              try {
                                await provider.submitFeed();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Feed uploaded successfully!',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                  ),
                                );
                              }
                            },
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Upload Feed'),
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
