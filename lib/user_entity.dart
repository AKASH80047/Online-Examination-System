import 'package:equatable/equatable.dart';

enum UserRole { admin, user }

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final bool isEmailVerified;
  final String? deviceId;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.isEmailVerified = false,
    this.deviceId,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    name,
    role,
    isEmailVerified,
    deviceId,
  ];
}
