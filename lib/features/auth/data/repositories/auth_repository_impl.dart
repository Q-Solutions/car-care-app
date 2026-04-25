import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn);

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmail(
      String email, String password, String displayName) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();
    return credential;
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint("Starting Google Sign-In (v7 logic)...");

      // authenticate() is the core method in v7.x for interactive sign-in
      final GoogleSignInAccount user = await _googleSignIn.authenticate();
      
      debugPrint("Google User obtained: ${user.email}");
      
      final GoogleSignInAuthentication gAuth = user.authentication;
      debugPrint("Tokens received → ID Token: ${gAuth.idToken != null}");

      if (gAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google ID Token is missing',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
      );

      debugPrint("Signing into Firebase...");
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      debugPrint("Firebase Sign-In successful: ${userCredential.user?.uid}");

      return userCredential;
    } on PlatformException catch (e, stack) {
      debugPrint("Google Sign-In Platform Error: ${e.code} - ${e.message}");
      debugPrint("Stack Trace: $stack");

      if (!kIsWeb && Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Google Sign-In Platform Error: ${e.code}');
      }

      String message;
      String code = 'google-sign-in-failed';

      switch (e.code) {
        case '12501':
          code = 'google-sign-in-cancelled';
          message = 'Google sign-in was cancelled by the user.';
          break;
        case '10':
          message = 'Developer error: This usually means the SHA-1 fingerprint is missing in Firebase or the configuration is incorrect.';
          break;
        case '12500':
          message = 'Sign-in failed. Please ensure Google Play Services is updated and you have a valid internet connection.';
          break;
        case '7':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'An unknown Google Sign-In error occurred (Code: ${e.code})';
      }

      throw FirebaseAuthException(
        code: code,
        message: message,
      );
    } catch (e, stack) {
      debugPrint("Google Sign-In Unexpected Error: $e");
      debugPrint("Stack Trace: $stack");

      if (!kIsWeb && Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Google Sign-In Unexpected Error');
      }

      if (e is FirebaseAuthException) {
        rethrow;
      }

      final error = e.toString().toLowerCase();
      if (error.contains('cancel') || error.contains('abort')) {
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign-in was cancelled by user',
        );
      }

      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    await _firebaseAuth.currentUser?.reload();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _firebaseAuth.currentUser?.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }
}
