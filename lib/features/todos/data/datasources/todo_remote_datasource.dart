import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo_model.dart';

/// Todo remote data source interface
abstract class TodoRemoteDataSource {
  Stream<List<TodoModel>> watchTodos(String userId);
  Future<void> createTodo({required String userId, required String task});
  Future<void> updateTodo({required String id, required bool completed});
  Future<void> deleteTodo(String id);
}

/// Supabase implementation of todo data source
class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final SupabaseClient _supabaseClient;

  TodoRemoteDataSourceImpl(this._supabaseClient);

  @override
  Stream<List<TodoModel>> watchTodos(String userId) {
    if (kDebugMode) {
      print('🔵 Stream started - userId: $userId');
    }

    return _supabaseClient
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          try {
            final models = data
                .map((json) => TodoModel.fromJson(json))
                .toList();

            // Sort by newest first
            models.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (kDebugMode) {
              print('🟢 Stream update received - ${models.length} todos');
              for (var model in models) {
                print('  - ${model.task}: completed=${model.completed}');
              }
            }

            return models;
          } catch (e) {
            if (kDebugMode) {
              print('❌ Stream parsing error: $e');
            }
            throw Exception('Failed to parse todo list: $e');
          }
        });
  }

  @override
  Future<void> createTodo({
    required String userId,
    required String task,
  }) async {
    try {
      await _supabaseClient.from('todos').insert({
        'user_id': userId,
        'task': task,
        'completed': false,
      });
    } catch (e) {
      throw Exception('Failed to create todo: $e');
    }
  }

  @override
  Future<void> updateTodo({required String id, required bool completed}) async {
    try {
      await _supabaseClient
          .from('todos')
          .update({'completed': completed})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await _supabaseClient.from('todos').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}
