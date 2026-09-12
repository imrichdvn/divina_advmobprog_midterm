import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'post_card.dart';

class PostList extends StatefulWidget {
  final int? userId;
  const PostList({super.key, this.userId});
  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList>
    with AutomaticKeepAliveClientMixin {
  final _service = PostService();
  List<Post> _posts = [];
  bool _busy = false;
  bool _hasMore = true;
  String? _error;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final posts = widget.userId == null
          ? await _service.getPosts(skip: refresh ? 0 : _posts.length)
          : await _service.getPostsByUser(widget.userId!);
      if (!mounted) return;
      setState(() {
        _posts = refresh || widget.userId != null
            ? posts
            : [..._posts, ...posts];
        _hasMore = widget.userId == null && posts.length == 30;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to load posts. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _posts.length + 1,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index < _posts.length) {
            return PostCard(
              key: ValueKey(_posts[index].id),
              post: _posts[index],
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: _busy
                  ? const CircularProgressIndicator()
                  : _error != null
                  ? Column(
                      children: [
                        Text(_error!),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    )
                  : _posts.isEmpty
                  ? const Text('No posts yet.')
                  : _hasMore
                  ? TextButton(onPressed: _load, child: const Text('Load More'))
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
