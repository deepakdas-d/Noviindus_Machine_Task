import 'package:flutter/material.dart';
import 'package:noviindus/providers/category_provider.dart';
import 'package:noviindus/providers/home_provider.dart';
import 'package:noviindus/widgets/reuseablefeed.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import 'dart:developer' as developer;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<void> _initializationFuture;
  int _selectedCategoryIndex = -1;
  @override
  void initState() {
    super.initState();
    // Delay fetching after first frame to prevent build conflicts
    _initializationFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // Fetch categories if empty
    if (categoryProvider.categories.isEmpty && !categoryProvider.isLoading) {
      await categoryProvider.fetchCategories();
    }

    // Always fetch home feeds
    await homeProvider.fetchFeeds();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(12),
              child: ShimmerHomeSkeleton(),
            ),
          );
        }

        return Consumer2<CategoryProvider, HomeProvider>(
          builder: (context, categoryProvider, homeProvider, child) {
            // Show shimmer if either provider is loading
            if (categoryProvider.isLoading || homeProvider.isLoading) {
              return const Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(12),
                  child: ShimmerHomeSkeleton(),
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 100,
                surfaceTintColor:
                    Colors.transparent, // Prevents dimming on scroll
                backgroundColor: Colors.black, // or your color
                title: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hello, user\n',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Welcome back to this section',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    color: Colors.white,
                    iconSize: 30,
                    tooltip: 'Navigate',
                    onPressed: () {
                      Navigator.pushNamed(context, '/myfeed');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 28),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await authProvider.logout(context);
                    },
                  ),
                ],
              ),

              body: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait<void>([
                        categoryProvider.fetchCategories(),
                        homeProvider.fetchFeeds(),
                      ]);
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            ReusableCategoriesWidget(
                              categories: categoryProvider,
                              selectedIndex: _selectedCategoryIndex,
                              onCategorySelected: (index) {
                                setState(() {
                                  _selectedCategoryIndex = index;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            if (homeProvider.hasError)
                              _buildErrorWidget(homeProvider)
                            else
                              ReusableFeedsWidget(feeds: homeProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30, // adjust vertical position
                    right: 40, // adjust horizontal position
                    child: SizedBox(
                      width: 70, // increase size
                      height: 70, // increase size
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/addfeed');
                        },
                        backgroundColor: const Color(0xFFC70000),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(HomeProvider homeProvider) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 8),
        Text(
          homeProvider.error ?? 'Unknown error occurred',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            homeProvider.clearError();
            homeProvider.fetchFeeds();
          },
          child: const Text('Retry'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Reusable Categories Widget
class ReusableCategoriesWidget extends StatelessWidget {
  final CategoryProvider categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const ReusableCategoriesWidget({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isLoading) return const CategoryShimmer();

    if (categories.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No categories available.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.categories.length,
        itemBuilder: (context, index) {
          final category = categories.categories[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () {
              onCategorySelected(index); // Notify parent
              developer.log('Selected category: ${category.title}');
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? Colors.grey[850]! : Colors.transparent,
                border: Border.all(
                  color: Colors.grey[850]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(
                  category.title,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Shimmer Widgets
class ShimmerHomeSkeleton extends StatelessWidget {
  const ShimmerHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              const CategoryShimmer(),
              const SizedBox(height: 24),

              const SizedBox(height: 12),
              const FeedShimmer(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.grey[850],
            child: const ListTile(
              title: SizedBox(
                width: double.infinity,
                height: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              subtitle: SizedBox(
                width: 100,
                height: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
