import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_clone/features/auth/domain/entities/app_user.dart';
import 'package:social_media_clone/features/auth/domain/repos/auth_repo.dart';
import 'package:social_media_clone/features/auth/data/username_utils.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // attempt sign in
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // fetch user document from firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) return null;

      // create user from doc
      final data = userDoc.data() as Map<String, dynamic>;
      return AppUser.fromJson(data);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password, {
    required String usernameRaw,
  }) async {
    final username = normalizeUsername(usernameRaw);

    if (!isValidUsername(username)) {
      throw Exception(
        'Invalid username. Use 3-30 chars: lowercase letters, numbers, underscore.',
      );
    }

    UserCredential? createdCredential;

    try {
      // Option A (recommended UX): check availability first to avoid creating orphan auth users
      // Fast single-doc read
      final usernameSnap = await firebaseFirestore
          .collection('usernames')
          .doc(username)
          .get();

      if (usernameSnap.exists) {
        throw Exception('Username already taken');
      }

      // 1) create auth user
      createdCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = createdCredential.user!.uid;

      final newUser = AppUser(
        uid: uid,
        email: email,
        name: name,
        username: username,
      );

      final userDocRef = firebaseFirestore.collection('users').doc(uid);
      final usernameDocRef = firebaseFirestore
          .collection('usernames')
          .doc(username);

      // 2) run transaction to ensure username uniqueness and write both docs atomically
      await firebaseFirestore.runTransaction((transaction) async {
        final usernameSnapInTx = await transaction.get(usernameDocRef);
        if (usernameSnapInTx.exists) {
          // username taken -> abort (this handles rare race where someone took it between our earlier check and now)
          throw Exception('Username already taken');
        }

        transaction.set(usernameDocRef, {'uid': uid});
        transaction.set(userDocRef, newUser.toJson());
      });

      return newUser;
    } on FirebaseAuthException catch (e) {
      // auth error (bad email/password etc)
      // map firebase errors as needed
      throw Exception('Auth error: ${e.message}');
    } catch (e) {
      // cleanup: if we created an auth user but failed to write DB, delete auth user to avoid orphan
      try {
        final firebaseUser =
            createdCredential?.user ?? firebaseAuth.currentUser;
        if (firebaseUser != null) {
          // Deleting requires recent sign-in; best-effort
          await firebaseUser.delete();
        }
      } catch (_) {
        // ignore cleanup errors
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // get current logged in user from firebase
    final firebaseUser = firebaseAuth.currentUser;

    // no user logged in
    if (firebaseUser == null) {
      return null;
    }

    // fetch user document from firestore
    DocumentSnapshot userDoc = await firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    // check if user doc exists
    if (!userDoc.exists) {
      return null;
    }

    // user exists
    return AppUser.fromJson(userDoc.data() as Map<String, dynamic>);
  }

  // Check availability by looking up usernames/{username}
  @override
  Future<bool> isUsernameAvailable(String usernameRaw) async {
    final username = normalizeUsername(usernameRaw);
    if (!isValidUsername(username)) return false;
    final snap = await firebaseFirestore
        .collection('usernames')
        .doc(username)
        .get();
    return !snap.exists;
  }

  // Change username safely
  @override
  Future<void> changeUsername({
    required String uid,
    required String currentUsername,
    required String newUsernameRaw,
  }) async {
    final newUsername = normalizeUsername(newUsernameRaw);
    if (!isValidUsername(newUsername)) {
      throw Exception('Invalid username');
    }

    final newRef = firebaseFirestore.collection('usernames').doc(newUsername);
    final oldRef = firebaseFirestore
        .collection('usernames')
        .doc(currentUsername);
    final userRef = firebaseFirestore.collection('users').doc(uid);

    await firebaseFirestore.runTransaction((tx) async {
      final newSnap = await tx.get(newRef);
      if (newSnap.exists) throw Exception('Username taken');

      final oldSnap = await tx.get(oldRef);
      if (!oldSnap.exists || oldSnap['uid'] != uid) {
        throw Exception('Current username does not match user');
      }

      tx.set(newRef, {'uid': uid});
      tx.delete(oldRef);
      tx.update(userRef, {'username': newUsername});
    });
  }
}
