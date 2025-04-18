import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CreateUser {

  Future<UserCredential> createUserWithEmailAndPassword( String email, String password) async {
    
    // ignore: unused_local_variable
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );  
    return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<bool> checkIfUserExistsWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      print("User canceled the sign-in");
      return false; 
    }

    print("User signing in with Google");

    final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        print("New user signed in");
      } else {
        print("User already signed in");
      }
      return userCredential.additionalUserInfo?.isNewUser == false;
    } catch (e) {
      print("Error during sign-in: $e");
      return false;
    }
  }
}
