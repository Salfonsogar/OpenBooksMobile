import 'package:flutter/material.dart';

class MultiSelectBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) labelBuilder;
  final String Function(T) subtitleBuilder;
  final List<T> selectedItems;
  final Function(List<T>) onConfirm;
  final String title;

  const MultiSelectBottomSheet({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.subtitleBuilder,
    required this.selectedItems,
    required this.onConfirm,
    this.title = 'Seleccionar',
  });

  @override
  State<MultiSelectBottomSheet<T>> createState() => _MultiSelectBottomSheetState<T>();
}

class _MultiSelectBottomSheetState<T> extends State<MultiSelectBottomSheet<T>> {
  late List<T> _tempSelected;
  late final Set<T> _selectedSet;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedItems);
    _selectedSet = widget.selectedItems.toSet();
  }

  bool _isSelected(T item) => _selectedSet.contains(item);

  void _toggle(T item) {
    setState(() {
      if (_isSelected(item)) {
        _tempSelected.remove(item);
        _selectedSet.remove(item);
      } else {
        _tempSelected.add(item);
        _selectedSet.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onConfirm(_tempSelected);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Aceptar',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.outline),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return CheckboxListTile(
                      value: _isSelected(item),
                      activeColor: colorScheme.primary,
                      onChanged: (_) => _toggle(item),
                      title: Text(
                        widget.labelBuilder(item),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        widget.subtitleBuilder(item),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
