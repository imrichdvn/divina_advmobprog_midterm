import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class LikeButton extends StatelessWidget {
  final String reactionKey;
  final int initialLikes;
  const LikeButton({
    super.key,
    required this.reactionKey,
    required this.initialLikes,
  });

  @override
  Widget build(BuildContext context) {
    final reactions = PreferencesService.instance;
    return AnimatedBuilder(
      animation: reactions,
      builder: (context, _) {
        final liked = reactions.isLiked(reactionKey);
        return TextButton.icon(
          onPressed: reactions.savingLike
              ? null
              : () async {
                  try {
                    await reactions.toggleLike(reactionKey);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not save your like. Please retry.',
                          ),
                        ),
                      );
                    }
                  }
                },
          icon: Icon(liked ? Icons.thumb_up : Icons.thumb_up_outlined),
          label: Text('${initialLikes + (liked ? 1 : 0)}'),
          style: TextButton.styleFrom(
            foregroundColor: liked
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
