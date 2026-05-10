import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubit/libros_cubit.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class HomeStatesView extends StatelessWidget {
  const HomeStatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibrosCubit, LibrosState>(
      builder: (context, state) {
        if (state is LibrosLoading) {
          return const HomeLoadingView();
        }

        if (state is LibrosError) {
          return HomeErrorView(
            message: state.message,
            onRetry: () => context.read<LibrosCubit>().refresh(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}