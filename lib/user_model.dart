import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
    super.isEmailVerified,
    super.deviceId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserModel.parseRole(data['role']),
      isEmailVerified: data['isEmailVerified'] ?? false,
      deviceId: data['deviceId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'isEmailVerified': isEmailVerified,
      'deviceId': deviceId,
    };
  }

  static UserRole parseRole(String? role) {
    if (role == 'admin') return UserRole.admin;
    return UserRole.user;
  }

  // toEntity method for UserModel
  UserEntity toEntity() => UserEntity(
    uid: uid,
    email: email,
    name: name,
    role: role,
    isEmailVerified: isEmailVerified,
    deviceId: deviceId,
  );
}
