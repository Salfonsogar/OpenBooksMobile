import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/bookmark.dart';
import '../../logic/cubit/bookmark_cubit.dart';
import '../../logic/cubit/bookmark_state.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/cubit/reader_settings_cubit.dart';
import '../widgets/reader_colors.dart';
import '../widgets/reader_settings.dart';
import '../widgets/toc_dialog.dart';
import '../widgets/search_dialog.dart';

class ReaderDialogs {
  ReaderDialogs._();
  static void showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ReaderSettingsCubit>(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const ReaderSettingsSheet(),
        ),
      ),
    );
  }

  static void showToc({
    required BuildContext context,
    required ReaderState state,
    required ReaderColors colors,
    required int libroId,
    required void Function(int chapterIndex) onChapterTap,
  }) {
    if (state is! ReaderLoaded) return;

    final toc = state.manifest.toc;
    if (toc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay índice disponible')),
      );
      return;
    }

    final bookmarkState = context.read<BookmarkCubit>().state;
    final bookmarks = bookmarkState is BookmarkLoaded ? bookmarkState.bookmarks : <Bookmark>[];

    showTocDialog(
      context: context,
      colors: colors,
      bookTitle: state.manifest.titulo,
      toc: toc,
      bookmarks: bookmarks,
      currentChapterIndex: state.currentChapterIndex,
      chapters: state.manifest.readingOrder,
      callbacks: TocDialogCallbacks(
        onChapterTap: onChapterTap,
        onCreateBookmark: (title) {
          context.read<BookmarkCubit>().crearBookmark(
            bookId: libroId,
            chapterIndex: state.currentChapterIndex,
            title: title,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Marcador "$title" agregado')),
          );
        },
        onUpdateBookmark: (id, title) {
          context.read<BookmarkCubit>().actualizarBookmark(
            id: id,
            bookId: libroId,
            chapterIndex: state.currentChapterIndex,
            title: title,
          );
        },
        onDeleteBookmark: (id) {
          context.read<BookmarkCubit>().eliminarBookmark(id, libroId);
        },
      ),
    );
  }

  static void showSearch({
    required BuildContext context,
    required ReaderState state,
    required ReaderColors colors,
    required void Function(int chapterIndex, String text) onResultTap,
  }) {
    if (state is! ReaderLoaded) return;

    showSearchDialog(
      context: context,
      colors: colors,
      callbacks: SearchCallbacks(
        onSearch: (query) async {
          final results = <SearchResult>[];
          final queryLower = query.toLowerCase();
          final chapters = state.manifest.readingOrder;

          for (var i = 0; i < chapters.length; i++) {
            final content = await context.read<ReaderCubit>().obtenerContenido(i);
            if (content != null && content.toLowerCase().contains(queryLower)) {
              final toc = state.manifest.toc;
              String chapterTitle = 'Capítulo ${i + 1}';
              if (i < toc.length) {
                chapterTitle = toc[i].titulo;
              }

              results.add(SearchResult(
                text: content,
                chapterIndex: i,
                chapterTitle: chapterTitle,
              ));

              if (results.length >= 10) break;
            }
          }

          return results;
        },
        onResultTap: onResultTap,
      ),
    );
  }
}