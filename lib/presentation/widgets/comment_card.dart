import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/comment.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';

/// Widget hiển thị một comment card
class CommentCard extends StatefulWidget {
  final Comment comment;
  final void Function(String commentId, String userName)? onReply;
  final bool showReplies;

  const CommentCard({
    Key? key,
    required this.comment,
    this.onReply,
    this.showReplies = true,
  }) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _showReplies = false;
  bool _isEditing = false;
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final commentProvider = context.watch<CommentProvider>();
    final currentUser = authProvider.user;
    final isOwnComment = currentUser?.id == widget.comment.userId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề: Avatar + Tên + Thời gian + Hành động
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF234199),
                backgroundImage: widget.comment.userAvatar != null
                    ? NetworkImage(widget.comment.userAvatar!)
                    : null,
                child: widget.comment.userAvatar == null
                    ? Text(
                        widget.comment.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Tên + Thời gian
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.comment.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.comment.isEdited) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(edited)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeago.format(widget.comment.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions menu (edit, delete, report)
              if (isOwnComment)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  color: const Color(0xFF1A2F47),
                  onSelected: (value) {
                    if (value == 'edit') {
                      setState(() {
                        _isEditing = true;
                        _editController.text = widget.comment.text;
                      });
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, commentProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.flag_outlined,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: () => _showReportDialog(context, commentProvider),
                  tooltip: 'Report',
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment text or edit field
          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _editController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Edit your comment...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_editController.text.trim().isNotEmpty) {
                          final success = await commentProvider.updateComment(
                            widget.comment.id,
                            _editController.text.trim(),
                          );
                          if (success && mounted) {
                            setState(() => _isEditing = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FDADB),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Text(
              widget.comment.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),

          const SizedBox(height: 12),

          // Hành động: Thích + Trả lời + Số lượng trả lời
          Row(
            children: [
              // Like button
              InkWell(
                onTap: currentUser != null
                    ? () {
                        commentProvider.toggleLike(
                          widget.comment.id,
                          currentUser.id,
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.comment.isLikedBy(currentUser?.id ?? '')
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 16,
                        color: widget.comment.isLikedBy(currentUser?.id ?? '')
                            ? const Color(0xFF8FDADB)
                            : Colors.white.withOpacity(0.6),
                      ),
                      if (widget.comment.likesCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${widget.comment.likesCount}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Reply button - hiển thị cho tất cả comments
              if (widget.onReply != null)
                InkWell(
                  onTap: () => widget.onReply!(
                    widget.comment.id,
                    widget.comment.userName,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Show replies button
              if (!widget.comment.isReply &&
                  widget.comment.replyCount > 0 &&
                  widget.showReplies)
                InkWell(
                  onTap: () {
                    setState(() => _showReplies = !_showReplies);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showReplies
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.comment.replyCount} ${widget.comment.replyCount == 1 ? 'reply' : 'replies'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Replies list
          if (_showReplies && !widget.comment.isReply)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 16),
              child: StreamBuilder<List<Comment>>(
                stream: commentProvider.watchCommentReplies(widget.comment.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8FDADB),
                      ),
                    );
                  }

                  final replies = snapshot.data!;
                  return Column(
                    children: replies.map((reply) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CommentCard(
                          comment: reply,
                          showReplies: false,
                          // Reply vào reply sẽ reply vào parent comment gốc
                          onReply: widget.onReply,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CommentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2F47),
        title: const Text(
          'Delete Comment',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteComment(widget.comment.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, CommentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2F47),
        title: const Text(
          'Report Comment',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to report this comment as inappropriate?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.reportComment(widget.comment.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã báo cáo bình luận. Cảm ơn bạn!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
