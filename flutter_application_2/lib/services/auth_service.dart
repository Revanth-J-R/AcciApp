import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Required for Navigator

import '../main.dart'; // Import for `navigatorKey`

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String residentialAddress,
    required List<Map<String, String>> nominees,
    required String password,
    String? deviceToken,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      List<Map<String, String>> nomineeData = nominees;

      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'residentialAddress': residentialAddress,
        'nominees': nomineeData,
        'deviceToken': deviceToken,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Login existing user
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout user and navigate to login page
  Future<void> logout() async {
    await _auth.signOut();
    // Navigate to the login screen
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }
}
