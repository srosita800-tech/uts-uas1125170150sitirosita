import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/secure_storage_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;
  Map<String, dynamic>? _userModel;

  // Getters
  Map<String, dynamic>? get userModel => _userModel;
  bool get isAdmin => _userModel?['role'] == 'admin';
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> initializeAuth() async {
    _status = AuthStatus.loading;
    notifyListeners(); // Beritahu UI untuk show loading

    _firebaseUser = _auth.currentUser;
    final savedToken = await SecureStorageService.getToken();

    if (_firebaseUser != null && savedToken != null) {
      try {
        await _firebaseUser?.reload();
        _firebaseUser = _auth.currentUser;

        if (_firebaseUser!.emailVerified) {
          _backendToken = savedToken;
          // Langsung verifikasi ke backend untuk ambil data user terbaru
          await _verifyTokenToBackend();
        } else {
          _status = AuthStatus.emailNotVerified;
        }
      } catch (e) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    _setLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;

      if (_firebaseUser != null) {
        // Update nama di Firebase Profile
        await _firebaseUser?.updateDisplayName(name);
        
        // Simpan data awal ke Backend
        await DioClient.instance.post(
          ApiConstants.register,
          data: {
            'uid': _firebaseUser!.uid,
            'name': name,
            'email': email,
          },
        );

        await _firebaseUser?.sendEmailVerification();
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Gagal mendaftar ke server: $e');
      return false;
    }
  }

  Future<bool> loginWithEmail({required String email, required String password}) async {
    _setLoading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _firebaseUser = credential.user;
      await _firebaseUser?.reload();
      _firebaseUser = _auth.currentUser;

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      return await _verifyTokenToBackend();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Login gagal: $e');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCred = await _auth.signInWithCredential(credential);
      _firebaseUser = userCred.user;

      return await _verifyTokenToBackend();
    } catch (e) {
      _setError('Gagal login dengan Google: $e');
      return false;
    }
  }

  Future<bool> _verifyTokenToBackend() async {
    try {
      // Force refresh token untuk mendapatkan yang terbaru
      final firebaseToken = await _firebaseUser?.getIdToken(true); 
      
      // Menggunakan debugPrint alih-alih print biasa (Standar Flutter)
      debugPrint("DEBUG: Mengirim token ke backend...");

      final response = await DioClient.instance.post(
        ApiConstants.verifyToken,
        data: {'firebase_token': firebaseToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        
        _backendToken = responseData['access_token'];
        _userModel = responseData['user'];

        if (_backendToken != null) {
          await SecureStorageService.saveToken(_backendToken!);
        }

        _status = AuthStatus.authenticated;
        _errorMessage = null; 
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("DEBUG: Verifikasi Backend Gagal: $e");
      _setError('Gagal verifikasi ke server.');
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        _firebaseUser = _auth.currentUser; 

        if (_firebaseUser?.emailVerified ?? false) {
          return await _verifyTokenToBackend();
        }
      }
    } catch (e) {
      debugPrint("Gagal polling email: $e");
    }
    return false;
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _firebaseUser?.sendEmailVerification();
    } catch (e) {
      debugPrint("Gagal kirim ulang email: $e");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await SecureStorageService.clearAll();
      
      _firebaseUser = null;
      _backendToken = null;
      _userModel = null; 
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(String code) => switch (code) {
        'email-already-in-use' => 'Email sudah terdaftar.',
        'user-not-found' => 'Akun tidak ditemukan.',
        'wrong-password' => 'Password salah.',
        'invalid-email' => 'Format email tidak valid.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        'invalid-credential' => 'Email atau password salah.',
        _ => 'Terjadi kesalahan: $code',
      };
}