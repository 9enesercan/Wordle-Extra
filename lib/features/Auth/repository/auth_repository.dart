// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';

final AuthRepositoryProvider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance));

class AuthRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;

  AuthRepository({required this.auth, required this.firebaseFirestore});

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> storeUserInfo(UserModel userModel) async {
    userModel.id = auth.currentUser!.uid;

    await firebaseFirestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .set(userModel.toMap());
  }
}
