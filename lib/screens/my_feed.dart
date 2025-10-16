import 'package:flutter/material.dart';
import 'package:noviindus/providers/my_feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MyFeed extends StatefulWidget {
  const MyFeed({super.key});

  @override
  State<MyFeed> createState() => _MyFeedState();
}

class _MyFeedState extends State<MyFeed> {
  late MyFeedProvider _provider;
  final ScrollController _scrollController = ScrollController();
  ChewieController? _chewieController;
  int _activeVideoIndex = -1;

  @override
  void initState() {
    super.initState();
    _provider = MyFeedProvider();
    _provider.loadInitialFeeds();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          _provider.hasMore) {
        _provider.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(int index) async {
    if (_activeVideoIndex == index) return;

    _chewieController?.dispose();
    _chewieController = null;

    setState(() => _activeVideoIndex = index);

    final videoUrl = _provider.feeds[index].video;
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
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('My Feed')),
        body: Consumer<MyFeedProvider>(
          builder: (context, provider, _) {
            final feeds = provider.feeds;

            if (feeds.isEmpty && provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (feeds.isEmpty) {
              return const Center(
                child: Text(
                  'No feeds available',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: feeds.length + (provider.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == feeds.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final feed = feeds[index];

                return Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
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
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feed.user.name ?? 'Unknown User',
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
                      // Video/Image
                      GestureDetector(
                        onTap: feed.video.isNotEmpty
                            ? () => _initializeVideoPlayer(index)
                            : null,
                        child: SizedBox(
                          width: double.infinity,
                          height: 200,
                          child:
                              _activeVideoIndex == index &&
                                  _chewieController != null
                              ? Chewie(controller: _chewieController!)
                              : (feed.image.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          feed.image,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white70,
                                        ),
                                      )),
                        ),
                      ),
                      // Description
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          feed.description,
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
