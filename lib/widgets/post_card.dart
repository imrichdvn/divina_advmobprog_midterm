import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../screens/detail_screen.dart';
import 'like_button.dart';
import 'user_avatar.dart';

class PostCard extends StatefulWidget {
  final Post? post;
  final String userName;
  final String postContent;
  final String date;
  final int numOfLikes;
  final String imageUrl;
  final String profileImageUrl;
  final String adsMarket;
  final bool openDetails;

  const PostCard({
    super.key,
    this.post,
    this.userName = '',
    this.postContent = '',
    this.date = '',
    this.numOfLikes = 0,
    this.imageUrl = '',
    this.profileImageUrl = '',
    this.adsMarket = '',
    this.openDetails = true,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Future<User>? _author;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  void _loadAuthor() {
    final post = widget.post;
    _author = post == null || widget.userName.isNotEmpty
        ? null
        : UserService.instance.getUser(post.userId);
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post?.userId != widget.post?.userId) _loadAuthor();
  }

  void _open() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailScreen(
        post: widget.post,
        userName: widget.userName,
        postContent: widget.postContent,
        date: widget.date,
        numOfLikes: widget.numOfLikes + (_liked ? 1 : 0),
        imageUrl: widget.imageUrl,
        profileImageUrl: widget.profileImageUrl,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final date = post?.createdAt ?? widget.date;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<User>(
            future: _author,
            builder: (context, snapshot) => Row(
              children: [
                UserAvatar(
                  imageUrl:
                      snapshot.data?.profileImageUrl ?? widget.profileImageUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    snapshot.data?.fullName ??
                        (widget.userName.isNotEmpty
                            ? widget.userName
                            : post == null
                            ? ''
                            : 'User ${post.userId}'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (snapshot.hasError)
                  IconButton(
                    tooltip: 'Reload author',
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(_loadAuthor),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: widget.openDetails ? _open : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(post?.body ?? widget.postContent),
            ),
          ),
          if (date.isNotEmpty)
            Text(date, style: Theme.of(context).textTheme.bodySmall),
          if (widget.imageUrl.isNotEmpty && widget.imageUrl != 'N/A')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: widget.imageUrl.startsWith('http')
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) =>
                          const Icon(Icons.broken_image_outlined),
                    )
                  : Image.asset(
                      widget.imageUrl.startsWith('assets/')
                          ? widget.imageUrl
                          : 'assets/images/${widget.imageUrl}',
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
            ),
          const SizedBox(height: 8),
          if (widget.adsMarket.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.adsMarket),
              trailing: IconButton(
                tooltip: 'More details',
                onPressed: _open,
                icon: const Icon(Icons.arrow_forward),
              ),
            )
          else
            Wrap(
              spacing: 12,
              children: [
                if (post != null)
                  LikeButton(
                    reactionKey: 'post.${post.id}',
                    initialLikes: post.likes + (_liked ? 1 : 0),
                  )
                else
                  TextButton.icon(
                    onPressed: () => setState(() => _liked = !_liked),
                    icon: Icon(
                      _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    ),
                    label: Text('${widget.numOfLikes + (_liked ? 1 : 0)}'),
                  ),
                if (widget.openDetails)
                  TextButton.icon(
                    onPressed: _open,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Comments'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
