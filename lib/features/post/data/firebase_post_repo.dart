// lib\features\post\data\firebase_post_repo.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_clone/features/auth/domain/entities/app_user.dart';
import 'package:social_media_clone/features/post/domain/entities/comment.dart';
import 'package:social_media_clone/features/post/domain/entities/post.dart';
import 'package:social_media_clone/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the posts in a collection called 'posts'
  final CollectionReference postsCollection = FirebaseFirestore.instance
      .collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts(String currentUid) async {
    try {
      // 1. Load blocked user IDs
      final blockedSnapshot = await firestore
          .collection('users')
          .doc(currentUid)
          .collection('BlockedUsers')
          .get();

      final blockedUserIds = blockedSnapshot.docs.map((d) => d.id).toList();

      // 2. Fetch all posts
      final postsSnapshot = await postsCollection
          .orderBy('timestamp', descending: true)
          .get();

      final allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // 3. Get all unique authors
      final authorIds = allPosts.map((p) => p.userId).toSet().toList();

      // 4. Batch fetch each author's BlockedUsers once
      final Map<String, Set<String>> blockedUsersMap = {};

      for (final authorId in authorIds) {
        final blockedSnap = await firestore
            .collection('users')
            .doc(authorId)
            .collection('BlockedUsers')
            .get();

        blockedUsersMap[authorId] = blockedSnap.docs.map((d) => d.id).toSet();
      }

      // 5. Filter out posts where author has blocked currentUid
      final filtered = allPosts
          .where(
            (post) =>
                !(blockedUsersMap[post.userId]?.contains(currentUid) ?? false),
          )
          .where((post) => !blockedUserIds.contains(post.userId))
          .toList();

      return filtered;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      // fetch posts snapshot with this uid
      final postsSnapshot = await postsCollection
          .where('userId', isEqualTo: userId)
          .get();

      // convert firestore documents from json -> list of posts
      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("Error fetching posts by user:  $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final likeRef = postsCollection
          .doc(postId)
          .collection("Likes")
          .doc(userId);

      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        // UNLIKE
        await likeRef.delete();
      } else {
        // LIKE
        await likeRef.set({'createdAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        // convert json object -> post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.add(comment);

        // update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        // convert json object -> post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        // update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error deleting comment $e");
    }
  }

  // report post
  @override
  Future<void> reportPost(Post post, AppUser currentUser) async {
    // get current user id
    final currentUserId = currentUser.uid;

    // create a report map
    final report = {
      'reportedBy': currentUserId,
      'messageId': post.id,
      'messageOwnerId': post.userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // update in firestore
    await FirebaseFirestore.instance.collection("reports").add(report);
  }
}
