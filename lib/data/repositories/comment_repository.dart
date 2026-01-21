import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';

/// Repository để quản lý comments trong Firestore
class CommentRepository {
  final FirebaseFirestore _firestore;

  CommentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference for comments
  CollectionReference get _commentsCollection =>
      _firestore.collection('comments');

  /// Add a new comment
  /// Returns the ID of the created comment
  Future<String> addComment({
    required String userId,
    required String userName,
    String? userAvatar,
    required String movieId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final comment = {
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        // Chỉ lưu movieId cho comment gốc, không lưu cho reply để tránh duplicate
        if (parentCommentId == null) 'movieId': movieId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'likedBy': [],
        'parentCommentId': parentCommentId,
        'replyCount': 0,
        'isEdited': false,
        'isReported': false,
      };

      final docRef = await _commentsCollection.add(comment);

      // If this is a reply, increment parent's reply count
      if (parentCommentId != null) {
        await _commentsCollection.doc(parentCommentId).update({
          'replyCount': FieldValue.increment(1),
        });
      }

      print('✅ Bình luận đã thêm: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Lỗi khi thêm bình luận: $e');
      rethrow;
    }
  }

  /// Get all comments for a movie (top-level only, no replies)
  /// Sorted by newest first
  Stream<List<Comment>> getMovieComments(String movieId) {
    return _commentsCollection
        .where('movieId', isEqualTo: movieId)
        .where('parentCommentId', isEqualTo: null)
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs
              .map((doc) => Comment.fromFirestore(doc))
              .toList();

          // Sort in memory to avoid composite index requirement
          comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return comments;
        });
  }

  /// Get replies for a specific comment
  /// Sorted by oldest first (chronological order)
  Stream<List<Comment>> getCommentReplies(String parentCommentId) {
    return _commentsCollection
        .where('parentCommentId', isEqualTo: parentCommentId)
        .snapshots()
        .map((snapshot) {
          final replies = snapshot.docs
              .map((doc) => Comment.fromFirestore(doc))
              .toList();

          // Sort in memory (oldest first)
          replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return replies;
        });
  }

  /// Get a single comment by ID
  Future<Comment?> getCommentById(String commentId) async {
    try {
      final doc = await _commentsCollection.doc(commentId).get();
      if (doc.exists) {
        return Comment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy bình luận: $e');
      return null;
    }
  }

  /// Update comment text
  Future<void> updateComment(String commentId, String newText) async {
    try {
      await _commentsCollection.doc(commentId).update({
        'text': newText,
        'updatedAt': FieldValue.serverTimestamp(),
        'isEdited': true,
      });
      print('✅ Bình luận đã cập nhật: $commentId');
    } catch (e) {
      print('❌ Lỗi khi cập nhật bình luận: $e');
      rethrow;
    }
  }

  /// Delete a comment
  /// If it has replies, those will be deleted too
  Future<void> deleteComment(String commentId) async {
    try {
      // Get the comment to check if it's a reply
      final comment = await getCommentById(commentId);
      if (comment == null) return;

      // If it's a reply, decrement parent's reply count
      if (comment.parentCommentId != null) {
        await _commentsCollection.doc(comment.parentCommentId).update({
          'replyCount': FieldValue.increment(-1),
        });
      }

      // Delete all replies to this comment
      final repliesSnapshot = await _commentsCollection
          .where('parentCommentId', isEqualTo: commentId)
          .get();

      final batch = _firestore.batch();
      for (var doc in repliesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the comment itself
      batch.delete(_commentsCollection.doc(commentId));

      await batch.commit();
      print(
        '✅ Comment deleted: $commentId (and ${repliesSnapshot.docs.length} replies)',
      );
    } catch (e) {
      print('❌ Lỗi khi xóa bình luận: $e');
      rethrow;
    }
  }

  /// Toggle like on a comment
  /// If user has already liked, remove like. Otherwise, add like.
  Future<void> toggleLike(String commentId, String userId) async {
    try {
      final doc = await _commentsCollection.doc(commentId).get();
      if (!doc.exists) return;

      final comment = Comment.fromFirestore(doc);

      if (comment.isLikedBy(userId)) {
        // Remove like
        await _commentsCollection.doc(commentId).update({
          'likedBy': FieldValue.arrayRemove([userId]),
        });
        print('👎 Thích đã xóa khỏi bình luận: $commentId');
      } else {
        // Add like
        await _commentsCollection.doc(commentId).update({
          'likedBy': FieldValue.arrayUnion([userId]),
        });
        print('👍 Thích đã thêm vào bình luận: $commentId');
      }
    } catch (e) {
      print('❌ Lỗi khi chuyển đổi thích: $e');
      rethrow;
    }
  }

  /// Report a comment as inappropriate
  Future<void> reportComment(String commentId) async {
    try {
      await _commentsCollection.doc(commentId).update({'isReported': true});
      print('🚩 Bình luận đã báo cáo: $commentId');
    } catch (e) {
      print('❌ Lỗi khi báo cáo bình luận: $e');
      rethrow;
    }
  }

  /// Get total comment count for a movie (including replies)
  /// Since replies don't have movieId, we need to count top-level comments + their replyCount
  Future<int> getMovieCommentCount(String movieId) async {
    try {
      final snapshot = await _commentsCollection
          .where('movieId', isEqualTo: movieId)
          .get();

      // Count top-level comments + sum of all reply counts
      int totalCount = snapshot.docs.length;
      for (var doc in snapshot.docs) {
        final comment = Comment.fromFirestore(doc);
        totalCount += comment.replyCount;
      }

      return totalCount;
    } catch (e) {
      print('❌ Lỗi khi lấy số lượng bình luận: $e');
      return 0;
    }
  }

  /// Get user's comments
  Stream<List<Comment>> getUserComments(String userId) {
    return _commentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Comment.fromFirestore(doc))
              .toList();
        });
  }
}
