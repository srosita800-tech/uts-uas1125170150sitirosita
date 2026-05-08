// ignore: unused_import
import 'package:flutter/material.dart';

abstract class AuthRepository {
  /// Verifikasi Firebase token ke backend, kembalikan Backend JWT
  Future<String> verifyFirebaseToken(String firebaseToken);
}