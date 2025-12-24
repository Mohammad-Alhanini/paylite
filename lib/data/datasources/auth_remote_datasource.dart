import 'package:firebase_auth/firebase_auth.dart';
import 'package:payliteapp/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserEntity> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      return UserEntity(uid: user.uid, email: user.email ?? '');
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserEntity?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserEntity(uid: user.uid, email: user.email ?? '');
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User disabled';
      case 'too-many-requests':
        return 'Too many requests';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
