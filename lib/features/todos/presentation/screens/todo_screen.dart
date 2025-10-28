import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/config/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/todo_providers.dart';

/// Todos screen - main todo list view
class TodosScreen extends HookConsumerWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskController = useTextEditingController();
    final todosAsync = ref.watch(todosStreamProvider);

    // Listen for errors
    ref.listen<AsyncValue<void>>(todoControllerProvider, (previous, next) {
      if (next.hasError) {
        ErrorUtils.showErrorSnackBar(context, next.error);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldSignOut == true && context.mounted) {
                ref.read(authControllerProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add todo section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: 'New todo',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) async {
                      if (value.trim().isNotEmpty) {
                        await ref
                            .read(todoControllerProvider.notifier)
                            .createTodo(value.trim());
                        taskController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (taskController.text.trim().isNotEmpty) {
                      await ref
                          .read(todoControllerProvider.notifier)
                          .createTodo(taskController.text.trim());
                      taskController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          // Todo list
          Expanded(
            child: todosAsync.when(
              loading: () => const LoadingWidget(message: 'Loading todos...'),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    Text(
                      ErrorUtils.getErrorMessage(error),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(todosStreamProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (todos) {
                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          'No todos yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Add a new todo to get started!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];

                    return ListTile(
                      leading: Checkbox(
                        value: todo.completed,
                        onChanged: (_) async {
                          await ref
                              .read(todoControllerProvider.notifier)
                              .toggleTodo(todo);
                        },
                      ),
                      title: Text(
                        todo.task,
                        style: TextStyle(
                          decoration: todo.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.completed ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(
                        'Created: ${_formatDate(todo.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Todo'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await ref
                                .read(todoControllerProvider.notifier)
                                .deleteTodo(todo.id);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Format date with locale-aware formatting
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      final formatter = DateFormat('HH:mm', 'tr_TR');
      return 'Today ${formatter.format(date)}';
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != date.day)) {
      final formatter = DateFormat('HH:mm', 'tr_TR');
      return 'Yesterday ${formatter.format(date)}';
    } else if (difference.inDays < 7) {
      final formatter = DateFormat('EEEE HH:mm', 'tr_TR');
      return formatter.format(date);
    } else {
      final formatter = DateFormat('dd/MM/yyyy HH:mm', 'tr_TR');
      return formatter.format(date);
    }
  }
}
