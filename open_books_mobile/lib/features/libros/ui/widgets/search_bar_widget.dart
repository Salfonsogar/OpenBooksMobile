import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showFilters;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleFilters;
  final VoidCallback onBack;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.showFilters,
    required this.onChanged,
    required this.onToggleFilters,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: onBack,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar libros...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: showFilters 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: showFilters 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: onToggleFilters,
            ),
          ),
        ],
      ),
    );
  }
}