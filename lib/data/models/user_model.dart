import 'package:payliteapp/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.uid, required super.email});

  factory UserModel.fromFirebase(dynamic user) {
    return UserModel(uid: user.uid, email: user.email ?? '');
  }
}
