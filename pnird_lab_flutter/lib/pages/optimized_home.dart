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
  bool _isLoading = false;
  List<Post> _posts = [];
  int _currentPage = 1;
  final int _postsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    futurePosts = getPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate pagination - in real app, you'd pass page number to API
      final newPosts = await getPosts();
      setState(() {
        _posts.addAll(newPosts);
        _currentPage++;
      });
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts.clear();
      _currentPage = 1;
    });
    
    try {
      final posts = await getPosts();
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      print('Error refreshing posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _posts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futurePosts = getPosts();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              if (_posts.isEmpty) {
                _posts = snapshot.data!;
              }
              
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < _posts.length) {
                          return OptimizedPostCard(post: _posts[index]);
                        } else if (_isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: _posts.length + (_isLoading ? 1 : 0),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text('No posts available'),
              );
            }
          },
        ),
      ),
    );
  }
}

