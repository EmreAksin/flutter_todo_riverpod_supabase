import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Widget to show empty state with icon and message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? actionButton;
  final double iconSize;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionButton,
    this.iconSize = 64.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color:
                  iconColor ??
                  theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppTheme.spacing8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: AppTheme.spacing32),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget to show error state
class ErrorStateWidget extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final double iconSize;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.iconSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String errorMessage = 'An error occurred';

    try {
      errorMessage = error.toString();
    } catch (_) {
      // Use default message if parsing fails
    }

    return EmptyStateWidget(
      icon: Icons.error_outline,
      iconSize: iconSize,
      iconColor: theme.colorScheme.error,
      title: 'Error',
      description: errorMessage,
      actionButton: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          : null,
    );
  }
}

/// Widget to show no internet connection
class NoConnectionWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'No Connection',
      description: 'Please check your internet connection and try again.',
      actionButton: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          : null,
    );
  }
}

/// Widget to show empty search results
class SearchEmptyWidget extends StatelessWidget {
  final String? searchTerm;
  final VoidCallback? onClear;

  const SearchEmptyWidget({super.key, this.searchTerm, this.onClear});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results',
      description: searchTerm != null
          ? 'No results found for "$searchTerm".'
          : 'No results found for your search.',
      actionButton: onClear != null
          ? TextButton(onPressed: onClear, child: const Text('Clear Search'))
          : null,
    );
  }
}

/// Widget to show coming soon feature
class ComingSoonWidget extends StatelessWidget {
  final String? featureName;

  const ComingSoonWidget({super.key, this.featureName});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.construction,
      title: 'Coming Soon',
      description: featureName != null
          ? '$featureName feature is coming soon!'
          : 'This feature is coming soon!',
      iconColor: Colors.orange,
    );
  }
}
