import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';

part 'todo_providers.g.dart';

/// Provider for todo remote data source
@riverpod
TodoRemoteDataSource todoRemoteDataSource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return TodoRemoteDataSourceImpl(supabaseClient);
}

/// Provider for todo repository
@riverpod
TodoRepository todoRepository(Ref ref) {
  final remoteDataSource = ref.watch(todoRemoteDataSourceProvider);
  return TodoRepositoryImpl(remoteDataSource);
}

/// Provider for todos stream with real-time updates
@riverpod
Stream<List<TodoEntity>> todosStream(Ref ref) async* {
  final currentUserAsync = await ref.watch(currentUserProvider.future);

  if (currentUserAsync == null) {
    yield [];
    return;
  }

  final repository = ref.watch(todoRepositoryProvider);
  yield* repository.watchTodos(currentUserAsync.id);
}

/// Todo controller for CRUD operations
@riverpod
class TodoController extends _$TodoController {
  @override
  FutureOr<void> build() {}

  /// Create new todo
  Future<void> createTodo(String task) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('Please login first');
      }

      final repository = ref.read(todoRepositoryProvider);
      await repository.createTodo(userId: currentUser.id, task: task);

      if (!ref.mounted) return;

      ref.invalidate(todosStreamProvider);
    });
  }

  /// Toggle todo completion status
  Future<void> toggleTodo(TodoEntity todo) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(todoRepositoryProvider);
      await repository.updateTodo(id: todo.id, completed: !todo.completed);

      if (!ref.mounted) return;

      ref.invalidate(todosStreamProvider);
    });
  }

  /// Delete todo
  Future<void> deleteTodo(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(todoRepositoryProvider);
      await repository.deleteTodo(id);

      if (!ref.mounted) return;

      ref.invalidate(todosStreamProvider);
    });
  }
}
