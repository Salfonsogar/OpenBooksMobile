import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/biblioteca_cubit.dart';
import '../widgets/index.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BibliotecaCubit>().cargarBiblioteca();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/library/upload'),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<BibliotecaCubit, BibliotecaState>(
        builder: (context, state) {
          if (state is BibliotecaLoading || state is BibliotecaInitial) {
            return const LibraryLoadingView();
          }

          if (state is BibliotecaError) {
            return LibraryErrorView(
              message: state.message,
              onRetry: () => context.read<BibliotecaCubit>().cargarBiblioteca(),
            );
          }

          if (state is BibliotecaLoaded) {
            if (state.libros.isEmpty) {
              return LibraryEmptyView(
                onExplore: () => context.go('/home'),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<BibliotecaCubit>().refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.libros.length,
                itemBuilder: (context, index) {
                  final libro = state.libros[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LibraryBookItem(
                      libro: libro,
                      onTap: () => context.pushReplacement('/reader/${libro.id}'),
                      onDownload: () => LibraryActions.descargarLibro(
                        context,
                        context.read<BibliotecaCubit>(),
                        libro.id,
                        libro.titulo,
                      ),
                      onEdit: () => LibraryActions.editarLibro(context, libro.id),
                      onDelete: () => LibraryActions.eliminarLibro(
                        context,
                        context.read<BibliotecaCubit>(),
                        libro.id,
                        libro.titulo,
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const LibraryLoadingView();
        },
      ),
    );
  }
}