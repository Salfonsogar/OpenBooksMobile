import 'package:flutter/material.dart';

class ReaderStatesView extends StatelessWidget {
  const ReaderStatesView({
    super.key,
    required this.isLoading,
    required this.loadingMessage,
    required this.hasError,
    required this.errorMessage,
    required this.onRetry,
    required this.onGoBack,
  });

  final bool isLoading;
  final String loadingMessage;
  final bool hasError;
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(loadingMessage),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(errorMessage, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onGoBack,
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}