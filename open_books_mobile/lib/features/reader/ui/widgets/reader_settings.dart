import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/reader_settings.dart';
import '../../logic/cubit/reader_settings_cubit.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
      builder: (context, settings) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Tema'),
                      _buildThemeSelector(context, settings),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Tamaño de fuente'),
                      _buildFontSizeSlider(context, settings),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Familia de fuente'),
                      _buildFontFamilySelector(context, settings),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Interlineado'),
                      _buildLineHeightSelector(context, settings),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Márgenes'),
                      _buildMarginSelector(context, settings),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ReaderSettings settings) {
    final themes = [
      {'key': 'light', 'label': 'Claro', 'bg': Colors.white, 'text': Colors.black},
      {'key': 'sepia', 'label': 'Sepia', 'bg': const Color(0xFFF4ECD8), 'text': const Color(0xFF5B4636)},
      {'key': 'dark', 'label': 'Oscuro', 'bg': Colors.grey[900]!, 'text': Colors.grey[300]!},
    ];

    return Row(
      children: themes.map((theme) {
        final isSelected = settings.theme == theme['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<ReaderSettingsCubit>().actualizarTheme(theme['key'] as String);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme['bg'] as Color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.text_fields,
                    color: theme['text'] as Color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme['label'] as String,
                    style: TextStyle(
                      color: theme['text'] as Color,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, ReaderSettings settings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('A', style: TextStyle(fontSize: 12)),
            Text(
              '${settings.fontSize.toInt()}px',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('A', style: TextStyle(fontSize: 24)),
          ],
        ),
        Slider(
          value: settings.fontSize,
          min: 12,
          max: 28,
          divisions: 8,
          onChanged: (value) {
            context.read<ReaderSettingsCubit>().actualizarFontSize(value);
          },
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector(BuildContext context, ReaderSettings settings) {
    final fonts = [
      {'key': 'sans-serif', 'label': 'Sans', 'family': 'Roboto'},
      {'key': 'serif', 'label': 'Serif', 'family': 'Georgia'},
      {'key': 'monospace', 'label': 'Mono', 'family': 'Courier'},
    ];

    return Row(
      children: fonts.map((font) {
        final isSelected = settings.fontFamily == font['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<ReaderSettingsCubit>().actualizarFontFamily(font['key'] as String);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  font['label'] as String,
                  style: TextStyle(
                    fontFamily: font['family'] as String,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineHeightSelector(BuildContext context, ReaderSettings settings) {
    final heights = [1.2, 1.5, 1.8, 2.0];

    return Row(
      children: heights.map((height) {
        final isSelected = settings.lineHeight == height;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<ReaderSettingsCubit>().actualizarLineHeight(height);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  height.toString(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarginSelector(BuildContext context, ReaderSettings settings) {
    final margins = [
      {'key': 'narrow', 'label': 'Pequeño'},
      {'key': 'normal', 'label': 'Normal'},
      {'key': 'wide', 'label': 'Grande'},
    ];

    return Row(
      children: margins.map((margin) {
        final isSelected = settings.marginMode == margin['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<ReaderSettingsCubit>().actualizarMarginMode(margin['key'] as String);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  margin['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
