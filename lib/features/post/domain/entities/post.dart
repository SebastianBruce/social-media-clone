import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_clone/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String handle;
  final String text;
  final String imageUrl;
  final DateTime timestamp;

  /// load from the /Likes subcollection
  final List<String> likes;

  /// calculated at fetch time
  final int likeCount;

  /// not stored — used for UI
  final bool isLikedByUser;

  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.handle,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.likeCount = 0,
    this.isLikedByUser = false,
  });

  Post copyWith({
    String? imageUrl,
    List<String>? likes,
    int? likeCount,
    bool? isLikedByUser,
  }) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      handle: handle,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      likeCount: likeCount ?? this.likeCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      comments: comments,
    );
  }

  // Convert post -> JSON (NOTE: no likes saved)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': userName,
      'username': handle,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),

      // Likes REMOVED because now a subcollection
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // Convert JSON -> Post (likes will be manually loaded later)
  factory Post.fromJson(Map<String, dynamic> json) {
    final List<Comment> comments =
        (json['comments'] as List<dynamic>?)
            ?.map((c) => Comment.fromJson(c))
            .toList() ??
        [];

    return Post(
      id: json['id'],
      userId: json['userId'],
      userName: json['name'],
      handle: json['username'],
      text: json['text'],
      imageUrl: json['imageUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),

      // EMPTY because likes come from subcollection
      likes: [],
      likeCount: 0,
      isLikedByUser: false,

      comments: comments,
    );
  }
}
