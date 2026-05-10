import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubit/libros_cubit.dart';

class SearchLoadingView extends StatelessWidget {
  const SearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class SearchErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SearchErrorView({
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

class SearchStatesView extends StatelessWidget {
  const SearchStatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibrosCubit, LibrosState>(
      builder: (context, state) {
        if (state is LibrosLoading) {
          return const SearchLoadingView();
        }

        if (state is LibrosError) {
          return SearchErrorView(
            message: state.message,
            onRetry: () => context.read<LibrosCubit>().cargarLibros(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}