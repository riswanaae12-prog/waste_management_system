import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          userType: userType,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());
        return user;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }

  Future<User?> loginUser({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final user = User.fromJson(userDoc.data() ?? {});
          if (user.userType == userType) {
            return user;
          } else {
            await _firebaseAuth.signOut();
            throw Exception('Access Denied: Incorrect user role.');
          }
        }
        return null;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        return User.fromJson(userDoc.data() ?? {});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> logoutUser() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
    String? gender,
    int? age,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (profileImage != null) updateData['profileImage'] = profileImage;
      if (gender != null) updateData['gender'] = gender;
      if (age != null) updateData['age'] = age;

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
