import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity đại diện cho một comment trên phim
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? movieId;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> likedBy; // List of user IDs who liked this comment
  final String?
  parentCommentId; // null if top-level, otherwise ID of parent comment
  final int replyCount; // Number of replies to this comment
  final bool isEdited;
  final bool isReported;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.movieId,
    required this.text,
    required this.createdAt,
    this.updatedAt,
    required this.likedBy,
    this.parentCommentId,
    this.replyCount = 0,
    this.isEdited = false,
    this.isReported = false,
  });

  /// Number of likes
  int get likesCount => likedBy.length;

  /// Check if user has liked this comment
  bool isLikedBy(String userId) => likedBy.contains(userId);

  /// Check if this is a reply (nested comment)
  bool get isReply => parentCommentId != null;

  /// Create Comment from Firestore document
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle null timestamp (when using serverTimestamp, it can be null temporarily)
    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    final createdAt = createdAtTimestamp?.toDate() ?? DateTime.now();

    return Comment(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userAvatar: data['userAvatar'] as String?,
      movieId: data['movieId'] as String?,
      text: data['text'] as String,
      createdAt: createdAt,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      parentCommentId: data['parentCommentId'] as String?,
      replyCount: data['replyCount'] as int? ?? 0,
      isEdited: data['isEdited'] as bool? ?? false,
      isReported: data['isReported'] as bool? ?? false,
    );
  }

  /// Convert Comment to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'movieId': movieId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likedBy': likedBy,
      'parentCommentId': parentCommentId,
      'replyCount': replyCount,
      'isEdited': isEdited,
      'isReported': isReported,
    };
  }

  /// Create a copy with modified fields
  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? movieId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? likedBy,
    String? parentCommentId,
    int? replyCount,
    bool? isEdited,
    bool? isReported,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      movieId: movieId ?? this.movieId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likedBy: likedBy ?? this.likedBy,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyCount: replyCount ?? this.replyCount,
      isEdited: isEdited ?? this.isEdited,
      isReported: isReported ?? this.isReported,
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, userId: $userId, userName: $userName, text: $text, likes: $likesCount, replies: $replyCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
