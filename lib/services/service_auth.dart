import "package:firebase_auth/firebase_auth.dart";
import "package:food_deliver/utils/utils_logger.dart";

class AuthService {
  const AuthService._();

  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<UserCredential> signInWithEmailPassword(
      String email, password) async {
    return await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> signUpWithEmailPassword(
      String email, password) async {
    return await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

  static Future<bool> changePassword(
      String oldPassword, String newPassword) async {
    User? user = getCurrentUser();
    if (user == null) {
      return false;
    }
    String? email = user.email;
    if (email == null || email.isEmpty) {
      return false;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      LoggerUtils.e(e);
    }
    return false;
  }
}
