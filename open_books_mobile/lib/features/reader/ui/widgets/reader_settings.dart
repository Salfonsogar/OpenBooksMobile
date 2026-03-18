import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/reader_settings.dart';
import '../../logic/cubit/reader_settings_cubit.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  Map<String, Color> _getThemeColors(String theme) {
    switch (theme) {
      case 'sepia':
        return {
          'background': const Color(0xFFF4ECD8),
          'text': const Color(0xFF5B4636),
          'header': const Color(0xFFF4ECD8),
          'icon': const Color(0xFF5B4636),
        };
      case 'dark':
        return {
          'background': Colors.grey[900]!,
          'text': Colors.grey[300]!,
          'header': Colors.grey[800]!,
          'icon': Colors.white,
        };
      default:
        return {
          'background': Colors.white,
          'text': Colors.black87,
          'header': Colors.white,
          'icon': Colors.black87,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
      builder: (context, settings) {
        final themeColors = _getThemeColors(settings.theme);
        
        return Container(
          decoration: BoxDecoration(
            color: themeColors['background'],
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
                  color: themeColors['text']!.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeColors['text'],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: themeColors['icon']),
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
                      _buildSectionTitle('Tema', themeColors),
                      _buildThemeSelector(context, settings, themeColors),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Tamaño de fuente', themeColors),
                      _buildFontSizeSlider(context, settings, themeColors),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Familia de fuente', themeColors),
                      _buildFontFamilySelector(context, settings, themeColors),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Interlineado', themeColors),
                      _buildLineHeightSelector(context, settings, themeColors),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Márgenes', themeColors),
                      _buildMarginSelector(context, settings, themeColors),
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

  Widget _buildSectionTitle(String title, Map<String, Color> themeColors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: themeColors['text']!.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ReaderSettings settings, Map<String, Color> themeColors) {
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
                  color: isSelected ? themeColors['text']! : Colors.grey[300]!,
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

  Widget _buildFontSizeSlider(BuildContext context, ReaderSettings settings, Map<String, Color> themeColors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('A', style: TextStyle(fontSize: 12, color: themeColors['text'])),
            Text(
              '${settings.fontSize.toInt()}px',
              style: TextStyle(fontWeight: FontWeight.bold, color: themeColors['text']),
            ),
            Text('A', style: TextStyle(fontSize: 24, color: themeColors['text'])),
          ],
        ),
        Slider(
          value: settings.fontSize,
          min: 12,
          max: 28,
          activeColor: themeColors['icon'],
          inactiveColor: themeColors['text']!.withValues(alpha: 0.3),
          onChanged: (value) {
            context.read<ReaderSettingsCubit>().actualizarFontSize(value);
          },
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector(BuildContext context, ReaderSettings settings, Map<String, Color> themeColors) {
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
                color: isSelected ? themeColors['icon']!.withValues(alpha: 0.1) : themeColors['background'],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? themeColors['icon']! : themeColors['text']!.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  font['label'] as String,
                  style: TextStyle(
                    fontFamily: font['family'] as String,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: themeColors['text'],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineHeightSelector(BuildContext context, ReaderSettings settings, Map<String, Color> themeColors) {
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
                color: isSelected ? themeColors['icon']!.withValues(alpha: 0.1) : themeColors['background'],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? themeColors['icon']! : themeColors['text']!.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  height.toString(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: themeColors['text'],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarginSelector(BuildContext context, ReaderSettings settings, Map<String, Color> themeColors) {
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
                color: isSelected ? themeColors['icon']!.withValues(alpha: 0.1) : themeColors['background'],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? themeColors['icon']! : themeColors['text']!.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  margin['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: themeColors['text'],
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
