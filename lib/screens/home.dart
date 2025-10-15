import 'package:flutter/material.dart';
import 'package:noviindus/models/my_feed_model.dart';
import 'package:noviindus/providers/home_provider.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<MyFeedProvider>(context, listen: false);

    // Wrap the content in FutureBuilder to fetch data only once
    return FutureBuilder(
      future: _initData(categoryProvider, feedProvider),
      builder: (context, snapshot) {
        // Show loading while initial fetch
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Feed'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () async {
                  await authProvider.logout(context);
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await feedProvider.fetchMyFeed();
              await categoryProvider.fetchCategories();
            },
            child: Consumer2<MyFeedProvider, CategoryProvider>(
              builder: (context, feed, categories, _) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to your personalized feed!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Categories
                        if (categories.categories.isNotEmpty)
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.categories.length,
                              itemBuilder: (context, index) {
                                final category = categories.categories[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Feed section
                        if (feed.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (feed.feeds.isEmpty)
                          const Center(
                            child: Text(
                              'No feeds available right now.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: feed.feeds.length,
                            itemBuilder: (context, index) {
                              final feedItem = feed.feeds[index];
                              return _buildFeedCard(feedItem);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Initialize data only once
  Future<void> _initData(
    CategoryProvider categoryProvider,
    MyFeedProvider feedProvider,
  ) async {
    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.fetchCategories();
    }
    if (feedProvider.feeds.isEmpty) {
      await feedProvider.fetchMyFeed();
    }
  }

  Widget _buildFeedCard(Result feed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: feed.image.isNotEmpty
                ? Image.network(
                    feed.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: feed.user.image != null
                          ? NetworkImage(feed.user.image!)
                          : null,
                      backgroundColor: Colors.grey[700],
                      radius: 20,
                      child: feed.user.image == null
                          ? const Icon(Icons.person, color: Colors.white70)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      feed.user.name ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  feed.description,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
