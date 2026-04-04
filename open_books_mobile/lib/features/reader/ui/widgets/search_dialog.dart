import 'package:flutter/material.dart';

import 'reader_colors.dart';

class SearchResult {
  final String text;
  final int chapterIndex;
  final String chapterTitle;

  const SearchResult({
    required this.text,
    required this.chapterIndex,
    required this.chapterTitle,
  });
}

class SearchCallbacks {
  final Future<List<SearchResult>> Function(String query) onSearch;
  final void Function(int chapterIndex, String text) onResultTap;

  const SearchCallbacks({
    required this.onSearch,
    required this.onResultTap,
  });
}

void showSearchDialog({
  required BuildContext context,
  required ReaderColors colors,
  required SearchCallbacks callbacks,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) => _SearchDialogContent(
      colors: colors,
      callbacks: callbacks,
    ),
  );
}

class _SearchDialogContent extends StatefulWidget {
  final ReaderColors colors;
  final SearchCallbacks callbacks;

  const _SearchDialogContent({
    required this.colors,
    required this.callbacks,
  });

  @override
  State<_SearchDialogContent> createState() => _SearchDialogContentState();
}

class _SearchDialogContentState extends State<_SearchDialogContent> {
  final TextEditingController _controller = TextEditingController();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _query = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _query = query;
    });

    try {
      final results = await widget.callbacks.onSearch(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: widget.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.colors.text.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              style: TextStyle(color: widget.colors.text),
              decoration: InputDecoration(
                hintText: 'Buscar en el libro...',
                hintStyle: TextStyle(color: widget.colors.text.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: widget.colors.icon),
                filled: true,
                fillColor: widget.colors.text.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _performSearch,
              autofocus: true,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isEmpty) {
      return Center(
        child: Text(
          'Escribe para buscar en el contenido',
          style: TextStyle(color: widget.colors.text.withValues(alpha: 0.5)),
        ),
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: widget.colors.text.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: TextStyle(
                color: widget.colors.text.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return ListTile(
          leading: Icon(Icons.text_snippet, color: widget.colors.accent),
          title: Text(
            result.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: widget.colors.text),
          ),
          subtitle: Text(
            result.chapterTitle,
            style: TextStyle(
              color: widget.colors.text.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          onTap: () {
            widget.callbacks.onResultTap(result.chapterIndex, result.text);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
