import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User data model for API layer
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'user_metadata') Map<String, dynamic>? userMetadata,
  }) = _UserModel;

  const UserModel._();

  /// Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Create model from Supabase User
  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      userMetadata: user.userMetadata,
    );
  }

  /// Convert model to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: userMetadata?['name'] as String?,
    );
  }
}
