import '../entities/todo_entity.dart';

/// Todo repository interface
abstract class TodoRepository {
  /// Watch todos with real-time updates
  Stream<List<TodoEntity>> watchTodos(String userId);

  /// Create new todo
  Future<void> createTodo({required String userId, required String task});

  /// Update todo completion status
  Future<void> updateTodo({required String id, required bool completed});

  /// Delete todo
  Future<void> deleteTodo(String id);
}
