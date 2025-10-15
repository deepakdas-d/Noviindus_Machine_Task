import 'package:flutter/material.dart';
import 'package:noviindus/providers/home_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ReusableFeedsWidget extends StatefulWidget {
  final HomeProvider feeds;

  const ReusableFeedsWidget({super.key, required this.feeds});

  @override
  State<ReusableFeedsWidget> createState() => _ReusableFeedsWidgetState();
}

class _ReusableFeedsWidgetState extends State<ReusableFeedsWidget> {
  ChewieController? _chewieController;
  int _activeVideoIndex = -1;

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(int index) async {
    if (_activeVideoIndex == index) return;

    _chewieController?.dispose();
    _chewieController = null;

    setState(() => _activeVideoIndex = index);

    final videoUrl = widget.feeds.feeds[index].video;
    if (videoUrl.isNotEmpty) {
      final videoPlayerController = VideoPlayerController.network(videoUrl);
      await videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        showControls: true,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feeds.feeds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No feeds available.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.feeds.feeds.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final feed = widget.feeds.feeds[index];
            return Card(
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info row above image/video
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // User profile image or silhouette
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[700],
                          backgroundImage:
                              feed.user.image != null &&
                                  feed.user.image!.isNotEmpty
                              ? NetworkImage(feed.user.image!)
                              : null,
                          child:
                              (feed.user.image == null ||
                                  feed.user.image!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white70)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        // User name
                        Expanded(
                          child: Text(
                            feed.user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Video or Thumbnail
                  if (feed.video.isNotEmpty)
                    GestureDetector(
                      onTap: () => _initializeVideoPlayer(index),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child:
                            _activeVideoIndex == index &&
                                _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : (feed.image.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        feed.image,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                height: 200,
                                                width: double.infinity,
                                                color: Colors.grey[800],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                height: 200,
                                                width: double.infinity,
                                                color: Colors.grey[800],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white70,
                                                ),
                                              );
                                            },
                                      ),
                                    )
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white70,
                                      ),
                                    )),
                      ),
                    )
                  else if (feed.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        feed.image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white70,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white70,
                      ),
                    ),
                  // Description below image/video
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      feed.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
