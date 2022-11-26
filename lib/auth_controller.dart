import 'package:fireauth/utilities/auth_response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // instances //
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // getters //
  Stream<User?> get userStream => _auth.authStateChanges();

  User? get firebaseUser => _auth.currentUser;

  // init //

  Future<void> init() async {
    print("##--AuthService---Init-------##");

    // await _updateUserInfo();
  }

  // methods //

  Future<AuthResponse> signInwithGoogle() async {
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

      return AuthResponse(ResponseStatus.Success, data: _auth.currentUser?.uid);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return AuthResponse(ResponseStatus.Error, errorMessage: e.message);
    } catch (e) {
      print("Error ========>$e");
      return AuthResponse(ResponseStatus.Error, errorMessage: e.toString());
    }
  }

  Future<AuthResponse> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential response = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (response.user != null) {
        return AuthResponse<User>(ResponseStatus.Success, data: response.user);
      } else {
        return AuthResponse<User>(ResponseStatus.Error,
            errorMessage: "User is null please try again");
      }
    } on FirebaseAuthException catch (e) {
      return AuthResponse(ResponseStatus.Error, errorMessage: e.message);
    } catch (e) {
      return AuthResponse(ResponseStatus.Error, errorMessage: e.toString());
    }
  }

  Future<AuthResponse> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential response = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (response.user != null) {
        return AuthResponse<User>(ResponseStatus.Success, data: response.user);
      } else {
        return AuthResponse<User>(ResponseStatus.Error,
            errorMessage: "User is null please try again");
      }
    } on FirebaseAuthException catch (e) {
      return AuthResponse(ResponseStatus.Error, errorMessage: e.message);
    } catch (e) {
      return AuthResponse(ResponseStatus.Error, errorMessage: e.toString());
    }
  }

  Future signOut() async {
    await _auth.signOut();
  }
}
