import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mFirebase/utilities/server_response.dart';

class AuthService {
  // instances //
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // getters //
  Stream<User?> get userStream => _auth.authStateChanges();

  User? get firebaseUser => _auth.currentUser;

  // init //
  AuthService() {
    unawaited(_auth.setSettings(appVerificationDisabledForTesting: true));
  }

  Future<void> init() async {
    print("##--AuthService---Init-------##");
  }

  // methods //

  Future<ServerResponse> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);

      return ServerResponse(ResponseStatus.Success,
          data: _auth.currentUser?.uid);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return ServerResponse(ResponseStatus.Error, errorMessage: e.message);
    } catch (e) {
      print("Error ========>$e");
      return ServerResponse(ResponseStatus.Error, errorMessage: e.toString());
    }
  }

  Future<ServerResponse> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final UserCredential response = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (response.user != null) {
        return ServerResponse<User>(ResponseStatus.Success,
            data: response.user);
      } else {
        return ServerResponse<User>(ResponseStatus.Error,
            errorMessage: "User is null please try again");
      }
    } on FirebaseAuthException catch (e) {
      return ServerResponse(ResponseStatus.Error, errorMessage: e.message);
    } catch (e) {
      return ServerResponse(ResponseStatus.Error, errorMessage: e.toString());
    }
  }

  Future<ServerResponse> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final UserCredential response = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (response.user != null) {
        return ServerResponse<User>(ResponseStatus.Success,
            data: response.user);
      } else {
        return ServerResponse<User>(ResponseStatus.Error,
            errorMessage: "User is null please try again");
      }
    } on FirebaseAuthException catch (e) {
      return ServerResponse(ResponseStatus.Error, errorMessage: e.message);
    } catch (e) {
      return ServerResponse(ResponseStatus.Error, errorMessage: e.toString());
    }
  }

  Future<ServerResponse> sendOtp(String phoneNumber) async {
    String? _verifcationId;
    dynamic _error;
    try {
      print("Calling verify phone number =>$phoneNumber .....");
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
        verificationFailed: (FirebaseAuthException error) {
          print(error);
          throw error;
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          _verifcationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e, stk) {
      print(e);
      print(stk);
      _error = e;
      throw Exception(e);
    }
    if (_verifcationId != null) {
      return ServerResponse(ResponseStatus.Success, data: _verifcationId);
    } else {
      return ServerResponse(ResponseStatus.Error, errorMessage: _error);
    }
  }

  Future<ServerResponse> verifyOtp(String verificationId, String otp) async {
    UserCredential? _user;
    dynamic _error;
    try {
      final PhoneAuthCredential _credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      _user = await _auth.signInWithCredential(_credential);
    } catch (e, stk) {
      print(e);
      print(stk);
      _error = e;
      throw Exception(e);
    }
    if (_user != null) {
      return ServerResponse(ResponseStatus.Success, data: _user.user);
    } else {
      return ServerResponse(ResponseStatus.Error, errorMessage: _error);
    }
  }

  Future signOut() async {
    await _auth.signOut();
  }
}
