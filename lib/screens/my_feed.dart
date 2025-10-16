import 'package:flutter/material.dart';
import 'package:noviindus/providers/my_feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';

class MyFeed extends StatefulWidget {
  const MyFeed({super.key});

  @override
  State<MyFeed> createState() => _MyFeedState();
}

class _MyFeedState extends State<MyFeed> {
  final ScrollController _scrollController = ScrollController();
  ChewieController? _chewieController;
  int _activeVideoIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize provider after first frame
      final provider = context.read<MyFeedProvider>();
      provider.loadInitialFeeds();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    final provider = context.read<MyFeedProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        provider.hasMore &&
        !provider.isLoadingMore) {
      provider.loadMoreFeeds();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<MyFeedProvider>().refreshFeeds();
  }

  void _initializeVideoPlayer(String url, int index) async {
    if (!mounted || _activeVideoIndex == index) return;

    // Pause current video if different
    if (_activeVideoIndex != -1 && _activeVideoIndex != index) {
      final currentProvider = context.read<MyFeedProvider>();
      if (_activeVideoIndex < currentProvider.feeds.length) {
        // You might want to pause the previous video here
      }
    }

    // Dispose previous controller
    await _chewieController?.videoPlayerController.dispose();
    _chewieController?.dispose();
    _chewieController = null;

    try {
      final controller = VideoPlayerController.network(url);
      await controller.initialize();

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        allowFullScreen: true,
        showControls: true,
        allowMuting: true,
      );

      if (mounted) {
        setState(() {
          _activeVideoIndex = index;
          _chewieController = chewie;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _activeVideoIndex = -1;
          _chewieController = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyFeedProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('My Feed'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: provider.isLoading
                ? _buildShimmerList()
                : _buildFeedList(provider),
          ),
        );
      },
    );
  }

  Widget _buildFeedList(MyFeedProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: provider.feeds.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.feeds.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final feed = provider.feeds[index];
        return _buildFeedCard(feed, index);
      },
    );
  }

  Widget _buildFeedCard(dynamic feed, int index) {
    final isActiveVideo =
        _activeVideoIndex == index && _chewieController != null;
    final hasVideo = feed.video?.isNotEmpty == true;
    final hasImage = feed.image?.isNotEmpty == true;

    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: (feed.user?.image?.isNotEmpty == true)
                      ? NetworkImage(feed.user!.image!)
                      : null,
                  child: (feed.user?.image?.isEmpty != false)
                      ? const Icon(Icons.person, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feed.user?.name ?? 'Unknown User',
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

          // Video or Image
          GestureDetector(
            onTap: hasVideo
                ? () => _initializeVideoPlayer(feed.video!, index)
                : null,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: isActiveVideo
                  ? Chewie(controller: _chewieController!)
                  : hasImage
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      child: Image.network(
                        feed.image!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildErrorWidget(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : _buildErrorWidget(),
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              feed.description ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[800],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.white70,
        size: 50,
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Container(
          height: 280,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
