import 'package:flutter/material.dart';

class CloseHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClose;
  final String? title;

  const CloseHeader({
    super.key,
    required this.onClose,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      title: title != null
          ? Text(
              title!,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            )
          : null,
      actions: [
        IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: onClose,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
