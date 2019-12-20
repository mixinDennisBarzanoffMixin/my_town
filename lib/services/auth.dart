import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  /// singleton
  AuthService._internal();
  static AuthService instance = AuthService._internal();

  factory AuthService() {
    return instance;
  }

  Future<FirebaseUser> get getUser => _auth.currentUser();

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      var authResult = await _auth.signInWithCredential(credential); // todo use link with credential instead
      FirebaseUser user = authResult.user;
      
      updateUserData(user);

      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<FirebaseUser> anonLogin() async {
    var authResult = await _auth.signInAnonymously();
    FirebaseUser user = authResult.user;
    updateUserData(user);
    return user;
  }

  Future<void> updateUserData(FirebaseUser user) {
    // DocumentReference reportRef = _db.collection('reports').document(user.uid);

    // return reportRef.setData({
    //   'uid': user.uid,
    //   'lastActivity': DateTime.now()
    // }, merge: true);

  }

  Future<void> signOut() {
    return _auth.signOut();
  }

}