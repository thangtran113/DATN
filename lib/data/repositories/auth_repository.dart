import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/entities/user.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  GoogleSignIn? _googleSignIn;

  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    // Only initialize GoogleSignIn on non-web or when client ID is configured
    if (!kIsWeb) {
      _googleSignIn = googleSignIn ?? GoogleSignIn();
    } else {
      _googleSignIn = null; // Will be initialized when needed on web
    }
  }

  // Get current user stream
  Stream<User?> get userStream {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirestore(firebaseUser.uid);
    });
  }

  // Get current user
  Future<User?> get currentUser async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirestore(firebaseUser.uid);
  }

  // Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      // Update last login time
      await _updateLastLoginTime(credential.user!.uid);

      return await _getUserFromFirestore(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Registration failed');
      }

      // Update display name if provided
      if (displayName != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      // Create user document in Firestore
      final user = User(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _createUserInFirestore(user);

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException during registration: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unknown error during registration: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      if (_googleSignIn == null) {
        throw Exception('Google Sign In is not available on this platform');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign in failed');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user document
        final user = User(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _createUserInFirestore(user);
        return user;
      } else {
        // Update last login time
        await _updateLastLoginTime(userCredential.user!.uid);
        return await _getUserFromFirestore(userCredential.user!.uid);
      }
    } catch (e) {
      throw Exception('Google sign in error: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      if (_googleSignIn != null) _googleSignIn!.signOut(),
    ]);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user logged in');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update({
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  // Private helper methods
  Future<User> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User document not found');
    }
    return User.fromJson(doc.data()!);
  }

  Future<void> _createUserInFirestore(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<void> _updateLastLoginTime(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': DateTime.now().toIso8601String(),
    });
  }

  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
