import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseSettingsRepo {
  // Get list of blocked user ids
  Stream<List<String>> streamBlockedUids() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
