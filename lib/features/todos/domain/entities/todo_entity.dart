import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_entity.freezed.dart';

/// Todo domain entity
@freezed
abstract class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,
    required String userId,
    required String task,
    required bool completed,
    required DateTime createdAt,
  }) = _TodoEntity;

  const TodoEntity._();
}
