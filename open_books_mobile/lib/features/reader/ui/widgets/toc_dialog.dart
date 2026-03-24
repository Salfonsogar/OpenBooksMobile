import 'package:flutter/material.dart';

import '../../data/models/bookmark.dart';
import '../../data/models/epub_manifest.dart';
import 'reader_colors.dart';
import 'bookmark_dialogs.dart';

class TocDialogCallbacks {
  final void Function(int chapterIndex) onChapterTap;
  final void Function(String title) onCreateBookmark;
  final void Function(int id, String title) onUpdateBookmark;
  final void Function(int id) onDeleteBookmark;

  const TocDialogCallbacks({
    required this.onChapterTap,
    required this.onCreateBookmark,
    required this.onUpdateBookmark,
    required this.onDeleteBookmark,
  });
}

void showTocDialog({
  required BuildContext context,
  required ReaderColors colors,
  required String bookTitle,
  required List<TocItem> toc,
  required List<Bookmark> bookmarks,
  required int currentChapterIndex,
  required List<ReadingOrderItem> chapters,
  required TocDialogCallbacks callbacks,
}) {
  if (toc.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay índice disponible')),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _TocDialogContent(
      colors: colors,
      bookTitle: bookTitle,
      toc: toc,
      bookmarks: bookmarks,
      currentChapterIndex: currentChapterIndex,
      chapters: chapters,
      callbacks: callbacks,
    ),
  );
}

class _TocDialogContent extends StatefulWidget {
  final ReaderColors colors;
  final String bookTitle;
  final List<TocItem> toc;
  final List<Bookmark> bookmarks;
  final int currentChapterIndex;
  final List<ReadingOrderItem> chapters;
  final TocDialogCallbacks callbacks;

  const _TocDialogContent({
    required this.colors,
    required this.bookTitle,
    required this.toc,
    required this.bookmarks,
    required this.currentChapterIndex,
    required this.chapters,
    required this.callbacks,
  });

  @override
  State<_TocDialogContent> createState() => _TocDialogContentState();
}

class _TocDialogContentState extends State<_TocDialogContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.bookTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: widget.colors.icon),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          TabBar(
            labelColor: widget.colors.accent,
            unselectedLabelColor: widget.colors.text,
            indicatorColor: widget.colors.accent,
            dividerColor: widget.colors.text.withValues(alpha: 0.2),
            tabs: [
              Tab(text: 'Índice (${widget.toc.length})'),
              Tab(text: 'Marcadores (${widget.bookmarks.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTocList(),
                _buildBookmarksList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTocList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.toc.length,
      itemBuilder: (context, index) {
        final item = widget.toc[index];
        final isSelected = index == widget.currentChapterIndex;

        return ListTile(
          title: Text(
            item.titulo,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? widget.colors.accent : widget.colors.text,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            final chapterIndex = widget.chapters.indexWhere(
              (c) => c.href == item.href,
            );
            if (chapterIndex >= 0) {
              widget.callbacks.onChapterTap(chapterIndex);
            }
          },
        );
      },
    );
  }

  Widget _buildBookmarksList() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            final currentTocItem = widget.toc.isNotEmpty && widget.currentChapterIndex < widget.toc.length
                ? widget.toc[widget.currentChapterIndex]
                : null;
            final defaultTitle = currentTocItem?.titulo ?? 'Capítulo ${widget.currentChapterIndex + 1}';

            showCreateBookmarkDialog(
              context: context,
              colors: widget.colors,
              defaultTitle: defaultTitle,
              onConfirm: (title) {
                widget.callbacks.onCreateBookmark(title);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: widget.colors.text.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: widget.colors.accent),
                const SizedBox(width: 12),
                Text(
                  'Agregar marcador en capítulo actual',
                  style: TextStyle(
                    color: widget.colors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: widget.bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: widget.colors.text.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay marcadores',
                        style: TextStyle(
                          color: widget.colors.text.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = widget.bookmarks[index];
                    final isCurrentChapter = bookmark.chapterIndex == widget.currentChapterIndex;

                    return ListTile(
                      leading: Icon(
                        Icons.bookmark,
                        color: widget.colors.accent,
                      ),
                      title: Text(
                        bookmark.title,
                        style: TextStyle(
                          fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
                          color: widget.colors.text,
                        ),
                      ),
                      subtitle: Text(
                        'Capítulo ${bookmark.chapterIndex + 1}',
                        style: TextStyle(
                          color: widget.colors.text.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: widget.colors.text,
                        ),
                        color: widget.colors.background,
                        onSelected: (value) {
                          if (value == 'edit') {
                            showEditBookmarkDialog(
                              context: context,
                              colors: widget.colors,
                              currentTitle: bookmark.title,
                              onConfirm: (title) {
                                widget.callbacks.onUpdateBookmark(bookmark.id!, title);
                              },
                            );
                          } else if (value == 'delete') {
                            showDeleteBookmarkDialog(
                              context: context,
                              colors: widget.colors,
                              title: bookmark.title,
                              onConfirm: () {
                                widget.callbacks.onDeleteBookmark(bookmark.id!);
                              },
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: widget.colors.text),
                                const SizedBox(width: 8),
                                Text('Editar', style: TextStyle(color: widget.colors.text)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: widget.colors.text),
                                const SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: widget.colors.text)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        widget.callbacks.onChapterTap(bookmark.chapterIndex);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
