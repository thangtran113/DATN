import 'package:flutter/foundation.dart';
import '../../domain/entities/comment.dart';
import '../../data/repositories/comment_repository.dart';

/// Provider quản lý state của comments
class CommentProvider with ChangeNotifier {
  final CommentRepository _repository;

  CommentProvider({CommentRepository? repository})
    : _repository = repository ?? CommentRepository();

  // State
  List<Comment> _comments = [];
  Map<String, List<Comment>> _replies = {}; // commentId -> list of replies
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // Getters
  List<Comment> get comments => _comments;
  Map<String, List<Comment>> get replies => _replies;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  /// Load comments for a movie (top-level only)
  Stream<List<Comment>> watchMovieComments(String movieId) {
    return _repository.getMovieComments(movieId);
  }

  /// Load replies for a comment
  Stream<List<Comment>> watchCommentReplies(String commentId) {
    return _repository.getCommentReplies(commentId);
  }

  /// Get replies from cache
  List<Comment> getReplies(String commentId) {
    return _replies[commentId] ?? [];
  }

  /// Add a new comment
  Future<bool> addComment({
    required String userId,
    required String userName,
    String? userAvatar,
    required String movieId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();

      await _repository.addComment(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        movieId: movieId,
        text: text,
        parentCommentId: parentCommentId,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      print('❌ Error in CommentProvider.addComment: $e');
      return false;
    }
  }

  /// Update a comment
  Future<bool> updateComment(String commentId, String newText) async {
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();

      await _repository.updateComment(commentId, newText);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      print('❌ Error in CommentProvider.updateComment: $e');
      return false;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();

      await _repository.deleteComment(commentId);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      print('❌ Error in CommentProvider.deleteComment: $e');
      return false;
    }
  }

  /// Toggle like on a comment
  Future<void> toggleLike(String commentId, String userId) async {
    try {
      await _repository.toggleLike(commentId, userId);
      // No need to notifyListeners - Firestore stream will update automatically
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Error in CommentProvider.toggleLike: $e');
    }
  }

  /// Report a comment
  Future<bool> reportComment(String commentId) async {
    try {
      await _repository.reportComment(commentId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Error in CommentProvider.reportComment: $e');
      return false;
    }
  }

  /// Get total comment count
  Future<int> getCommentCount(String movieId) async {
    try {
      return await _repository.getMovieCommentCount(movieId);
    } catch (e) {
      print('❌ Error in CommentProvider.getCommentCount: $e');
      return 0;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
