import 'package:flutter/material.dart';
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/services/post_service.dart';
import 'package:pnirdlab/widgets/optimized_post_card.dart';

class OptimizedHomePage extends StatefulWidget {
  const OptimizedHomePage({super.key});

  @override
  _OptimizedHomePageState createState() => _OptimizedHomePageState();
}

class _OptimizedHomePageState extends State<OptimizedHomePage> {
  late Future<List<Post>> futurePosts;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    futurePosts = getPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = getPosts();
    });
    await futurePosts;
  }

  Widget _emptyState(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(Icons.forum_outlined, size: 64, color: color),
        const SizedBox(height: 16),
        Text(
          'No posts yet',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'When lab staff share updates, they will show up here.\nPull down to refresh.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _errorState(BuildContext context, Object error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          'Could not load the feed',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '$error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _refreshPosts,
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _errorState(context, snapshot.error!);
            }

            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return _emptyState(context);
            }

            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => OptimizedPostCard(
                      post: posts[index],
                      onDeleted: _refreshPosts,
                    ),
                    childCount: posts.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
