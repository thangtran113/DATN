import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/comment.dart';
import '../providers/comment_provider.dart';
import 'comment_card.dart';
import 'comment_input.dart';

/// Widget hiển thị toàn bộ comments section
class CommentsSection extends StatefulWidget {
  final String movieId;

  const CommentsSection({super.key, required this.movieId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  String? _replyToCommentId;
  String? _replyToUserName;

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Text(
              'Bình luận',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            FutureBuilder<int>(
              future: commentProvider.getCommentCount(widget.movieId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FDADB).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${snapshot.data}',
                      style: const TextStyle(
                        color: Color(0xFF8FDADB),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Comment input
        CommentInput(
          movieId: widget.movieId,
          parentCommentId: _replyToCommentId,
          replyToUserName: _replyToUserName,
          onCommentAdded: () {
            setState(() {
              _replyToCommentId = null;
              _replyToUserName = null;
            });
          },
        ),

        const SizedBox(height: 24),

        // Danh sách bình luận
        StreamBuilder<List<Comment>>(
          stream: commentProvider.watchMovieComments(widget.movieId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF8FDADB)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.withOpacity(0.6),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi khi tải bình luận',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white.withOpacity(0.3),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có bình luận',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hãy là người đầu tiên bình luận!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentCard(
                  comment: comment,
                  onReply: (commentId, userName) {
                    setState(() {
                      // Nếu reply vào một reply, vẫn reply vào parent comment gốc
                      _replyToCommentId = comment.id;
                      _replyToUserName = userName;
                    });
                    // Scroll to input
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
