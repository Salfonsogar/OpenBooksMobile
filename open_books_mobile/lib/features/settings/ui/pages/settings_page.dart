import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../../../shared/ui/widgets/close_header.dart';
import '../../../reader/data/models/reader_settings.dart';
import '../../../reader/logic/cubit/reader_settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ReaderSettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseHeader(
        title: 'Ajustes',
        onClose: () => context.pop(),
      ),
      body: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
        builder: (context, settings) {
          return ListView(
            children: [
              const _SectionTitle('Apariencia'),
              _ThemeSelector(currentTheme: settings.theme),
              const Divider(),
              const _SectionTitle('Vista previa'),
              _ThemePreviewCard(theme: settings.theme),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String currentTheme;

  const _ThemeSelector({required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    final themes = [
      _ThemeOption(
        id: 'light',
        name: 'Claro',
        icon: Icons.light_mode,
        background: Colors.white,
        text: Colors.black87,
      ),
      _ThemeOption(
        id: 'dark',
        name: 'Oscuro',
        icon: Icons.dark_mode,
        background: Colors.grey[900]!,
        text: Colors.white,
      ),
      _ThemeOption(
        id: 'sepia',
        name: 'Sepia',
        icon: Icons.wb_sunny,
        background: const Color(0xFFF4ECD8),
        text: const Color(0xFF5B4636),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: themes.map((theme) {
          final isSelected = currentTheme == theme.id;
          return GestureDetector(
            onTap: () {
              context.read<ReaderSettingsCubit>().actualizarTheme(theme.id);
            },
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    theme.icon,
                    color: theme.text,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  theme.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ThemeOption {
  final String id;
  final String name;
  final IconData icon;
  final Color background;
  final Color text;

  const _ThemeOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.background,
    required this.text,
  });
}

class _ThemePreviewCard extends StatelessWidget {
  final String theme;

  const _ThemePreviewCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors(theme);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors['background'],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vista previa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors['text'],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Este es un ejemplo de texto con el tema seleccionado. '
              'Puedes ver cómo se ve el estilo de lectura.',
              style: TextStyle(
                fontSize: 14,
                color: colors['text'],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors['accent'],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Botón de ejemplo',
                    style: TextStyle(
                      color: colors['background'],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _getThemeColors(String theme) {
    switch (theme) {
      case 'sepia':
        return {
          'background': const Color(0xFFF4ECD8),
          'text': const Color(0xFF5B4636),
          'accent': const Color(0xFF8B4513),
        };
      case 'dark':
        return {
          'background': Colors.grey[900]!,
          'text': Colors.grey[300]!,
          'accent': Colors.white,
        };
      default:
        return {
          'background': Colors.white,
          'text': Colors.black87,
          'accent': const Color(0xFF2196F3),
        };
    }
  }
}
