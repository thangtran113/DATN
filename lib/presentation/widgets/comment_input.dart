import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';

/// Widget nhập comment mới
class CommentInput extends StatefulWidget {
  final String movieId;
  final String? parentCommentId;
  final String? replyToUserName;
  final VoidCallback? onCommentAdded;

  const CommentInput({
    super.key,
    required this.movieId,
    this.parentCommentId,
    this.replyToUserName,
    this.onCommentAdded,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    // Tự động thêm @username khi trả lời
    if (widget.replyToUserName != null) {
      _controller.text = '@${widget.replyToUserName} ';
      // Đặt cursor ở cuối
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void didUpdateWidget(CommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu replyToUserName thay đổi, cập nhật text
    if (widget.replyToUserName != oldWidget.replyToUserName) {
      if (widget.replyToUserName != null) {
        _controller.text = '@${widget.replyToUserName} ';
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final commentProvider = context.watch<CommentProvider>();
    final currentUser = authProvider.user;

    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Vui lòng đăng nhập để bình luận',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFF8FDADB)
              : Colors.white.withOpacity(0.1),
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chỉ báo trả lời
          if (widget.replyToUserName != null) ...[
            Row(
              children: [
                Icon(
                  Icons.reply,
                  size: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang trả lời ${widget.replyToUserName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Hàng nhập liệu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF234199),
                backgroundImage: currentUser.photoUrl != null
                    ? NetworkImage(currentUser.photoUrl!)
                    : null,
                child: currentUser.photoUrl == null
                    ? Text(
                        (currentUser.displayName ?? currentUser.username)[0]
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Trường văn bản
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: widget.parentCommentId != null
                        ? 'Viết phản hồi...'
                        : 'Viết bình luận...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show/hide button
                  },
                ),
              ),
            ],
          ),

          // Nút gửi
          if (_controller.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.replyToUserName != null)
                  TextButton(
                    onPressed: () {
                      _controller.clear();
                      _focusNode.unfocus();
                      widget.onCommentAdded?.call();
                    },
                    child: const Text('Hủy'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: commentProvider.isSubmitting
                      ? null
                      : () => _submitComment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FDADB),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: commentProvider.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          widget.parentCommentId != null
                              ? 'Trả lời'
                              : 'Bình luận',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitComment(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final commentProvider = context.read<CommentProvider>();
    final currentUser = authProvider.user;

    if (currentUser == null) return;

    final success = await commentProvider.addComment(
      userId: currentUser.id,
      userName: currentUser.displayName ?? currentUser.username,
      userAvatar: currentUser.photoUrl,
      movieId: widget.movieId,
      text: text,
      parentCommentId: widget.parentCommentId,
    );

    if (success && mounted) {
      _controller.clear();
      _focusNode.unfocus();
      widget.onCommentAdded?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.parentCommentId != null
                ? 'Đã thêm câu trả lời!'
                : 'Đã thêm bình luận!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
