import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Improved login method
  static Future<User?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code} - ${e.message}');
      return null;
    }
  }

  // Improved registration method
  static Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save additional user data
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'email': email,
        'username': username,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.code} - ${e.message}');
      return false;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}