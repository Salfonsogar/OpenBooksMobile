import 'package:flutter/material.dart';

class OptionsList extends StatelessWidget {
  final List<OptionItem> options;

  const OptionsList({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) => _buildOptionTile(context, option)).toList(),
    );
  }

  Widget _buildOptionTile(BuildContext context, OptionItem option) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(option.icon, color: Theme.of(context).colorScheme.onSurface),
        title: Text(
          option.title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: option.onTap,
      ),
    );
  }
}

class OptionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const OptionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
