import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/todo_entity.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

/// Todo data model for API layer
@freezed
abstract class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'user_id') required String userId,
    required String task,
    required bool completed,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TodoModel;

  const TodoModel._();

  /// Create model from JSON
  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  /// Convert model to domain entity
  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      userId: userId,
      task: task,
      completed: completed,
      createdAt: createdAt,
    );
  }
}
