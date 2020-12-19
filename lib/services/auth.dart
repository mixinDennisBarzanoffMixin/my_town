import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_town/shared/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_town/shared/user.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  /// singleton
  Stream<User> user$;

  AuthService._internal() {
    print('initialised authservce');
    this.user$ = _auth.onAuthStateChanged
        .switchMap((firebaseUser) {
          print('A new user signed in');
          print(firebaseUser);
          if (firebaseUser != null) {
            return _db
                .collection('users')
                .document(firebaseUser.uid)
                .snapshots();
          } else {
            return Stream.value(null);
          }
        })
        .map((doc) => doc != null ? doc.toUser(): null)
        .doOnData((val) {
          // print('received user');
          print(val);
        });
  }
  static AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  Future<User> get getUser => _auth
      .currentUser()
      .then((firebaseUser) => firebaseUser != null
          ? _db.document('users/${firebaseUser.uid}').get()
          : null)
      .then((doc) => doc != null
          ? doc.toUser()
          : null); // TODO duplicating and unnecessary logic

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      var authResult = await _auth.signInWithCredential(
          credential); // todo use link with credential instead
      FirebaseUser user = authResult.user;

      print('got new user');
      // updateUserData(user);
      print(user);
      // tried listening to the real user, but too hard
      updateUserData(user);
      // var userRef = ;
      // this._userSubject.add(await userRef.get().then((snap) => User.fromDocument(snap)));
      // // this._currentUser = userRef.get().then((snap) => User.fromDocument(snap));
      // return userRef.get().then((snap) => User.fromDocument(snap));
      // return user;
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<FirebaseUser> anonLogin() async {
    var authResult = await _auth.signInAnonymously();
    FirebaseUser user = authResult.user;
    // updateUserData(user);
    return user;
  }

  Future<void> updateUserData(FirebaseUser user) {
    DocumentReference userRef = _db.collection('users').document(user.uid);

    return userRef.setData({
      // update the user data in case it has changed
      // 'uid': user.uid,
      'photoUrl': user.photoUrl,
      'displayName': user.displayName,
      'providerId': user.providerId,
    }, merge: true);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
