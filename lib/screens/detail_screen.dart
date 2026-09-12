import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../widgets/post_card.dart';
import '../widgets/like_button.dart';

class DetailScreen extends StatefulWidget {
  final Post? post;
  final String userName;
  final String postContent;
  final String date;
  final String imageUrl;
  final String profileImageUrl;
  final int numOfLikes;
  const DetailScreen({
    super.key,
    this.post,
    this.userName = '',
    this.postContent = '',
    this.date = '',
    this.imageUrl = '',
    this.profileImageUrl = '',
    this.numOfLikes = 0,
  });
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _service = CommentService();
  final _text = TextEditingController();
  final _scroll = ScrollController();
  List<Comment> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = UserService.instance.currentUser?.id ?? 0;
      final comments = await _service.getComments(widget.post!.id, userId);
      if (mounted) setState(() => _comments = comments);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load comments.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    if (_sending || _loading || _error != null || _text.text.trim().isEmpty) {
      return;
    }
    setState(() => _sending = true);
    try {
      final user = UserService.instance.currentUser;
      if (user == null) throw StateError('Sign in to comment.');
      final comment = await _service.addComment(
        widget.post!.id,
        user,
        _text.text,
      );
      if (!mounted) return;
      setState(() => _comments.add(comment));
      _text.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment was not saved. Please retry.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.userName.isEmpty ? 'Post' : widget.userName),
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            children: [
              PostCard(
                post: widget.post,
                openDetails: false,
                userName: widget.userName,
                postContent: widget.postContent,
                date: widget.date,
                imageUrl: widget.imageUrl,
                profileImageUrl: widget.profileImageUrl,
                numOfLikes: widget.numOfLikes,
              ),
              if (widget.post != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Center(
                    child: Column(
                      children: [
                        Text(_error!),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No comments yet.'),
                  )
                else
                  ..._comments.map(
                    (comment) => Padding(
                      key: ValueKey(comment.id),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.userName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(comment.body),
                          LikeButton(
                            reactionKey: 'comment.${comment.id}',
                            initialLikes: comment.likes,
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (widget.post != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      enabled: !_sending && !_loading && _error == null,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _text,
                    builder: (context, value, _) => IconButton.filled(
                      tooltip: 'Send comment',
                      onPressed:
                          _sending ||
                              _loading ||
                              _error != null ||
                              value.text.trim().isEmpty
                          ? null
                          : _send,
                      icon: _sending
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
