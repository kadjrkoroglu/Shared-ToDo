import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Listen to auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Start Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Get auth details
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in to Firebase
      UserCredential result = await _auth.signInWithCredential(credential);

      // If user is new, save to Firestore with Unique ID
      if (result.additionalUserInfo?.isNewUser == true && result.user != null) {
        await createNewUser(result.user!);
      }

      return result;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Generate unique 6-character ID (e.g. Xy4Z2p)
  String _generateUniqueID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      6,
      (index) => chars[Random().nextInt(chars.length)],
    ).join();
  }

  // Save new user to Firestore with Unique ID
  Future<void> createNewUser(User user) async {
    String uniqueID = _generateUniqueID();

    // Check for ID collisions
    var doc = await _db
        .collection('users')
        .where('uniqueID', isEqualTo: uniqueID)
        .get();
    while (doc.docs.isNotEmpty) {
      uniqueID = _generateUniqueID();
      doc = await _db
          .collection('users')
          .where('uniqueID', isEqualTo: uniqueID)
          .get();
    }
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'uniqueID': uniqueID,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 1. Register with Email and Password
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await createNewUser(user); // Save to Firestore with ID
      }
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 2. Sign In with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
