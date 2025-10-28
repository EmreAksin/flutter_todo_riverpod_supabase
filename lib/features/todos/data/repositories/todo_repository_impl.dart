import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_remote_datasource.dart';

/// Implementation of todo repository
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;

  TodoRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<TodoEntity>> watchTodos(String userId) {
    return _remoteDataSource
        .watchTodos(userId)
        .map((todoModels) => todoModels.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> createTodo({
    required String userId,
    required String task,
  }) async {
    await _remoteDataSource.createTodo(userId: userId, task: task);
  }

  @override
  Future<void> updateTodo({required String id, required bool completed}) async {
    await _remoteDataSource.updateTodo(id: id, completed: completed);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _remoteDataSource.deleteTodo(id);
  }
}
