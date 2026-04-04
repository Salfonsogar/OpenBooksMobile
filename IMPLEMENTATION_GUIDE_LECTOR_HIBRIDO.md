# Guía de Implementación: Lector Híbrido (Lectura + Audio)

## Resumen Ejecutivo

Plan de implementación para añadir modo audiolibro (TTS) al módulo de lector existente. 13 fases pequeñas con dependencias claras.

**Supuestos:**
- Modo audio: TTS (Text-to-Speech)
- Audio files (MP3/M4B): stub para futuro
- Velocidad por defecto: 1x
- Auto-scroll: sí
- Notificaciones media: **FASE OPCIONAL** (validar TTS primero)
- Modo híbrido: **FASE POSTERIOR** (no en scope inicial)

---

## ESTRUCTURA DE UI DINÁMICA

### Renderizado Condicional Completo

```dart
Scaffold(
  appBar: ReaderAppBar(
    mode: currentMode,
    onModeToggle: (mode) => cubit.setReaderMode(mode),
  ),
  body: currentMode == ReaderMode.reading
      ? const ReadingView()
      : const ListeningView(),
  bottomNavigationBar: currentMode == ReaderMode.reading
      ? const ReadingFooter()
      : const AudioFooter(),
);
```

### Comportamiento del Contenido

| Modo    | Body                | Scroll                   | Highlight            |
| ------- | ------------------- | ------------------------ | -------------------- |
| Lectura | Texto estático     | Manual                   | Solo marcadores      |
| Audio   | Texto con highlight | Auto-scroll sincronizado | Sincronizado con TTS |
| Hybrid  | Texto estático     | Manual                   | Highlight suave      |

---

## FASE 1: Dependencias Básicas

### Objetivo
Añadir las dependencias mínimas necesarias para TTS.

### Importante
**audio_service se añade como dependencia pero NO se implementa en esta fase.** Primero se valida que TTS funcione correctamente en foreground.

### Tareas

1. **pubspec.yaml** - Añadir dependencias:
   ```yaml
   flutter_tts: ^4.2.0
   # audio_service: ^0.18.17  # Fase opcional - validar TTS primero
   ```

2. **main.dart** - NO inicializar AudioService todavía
   - Se hace en fase opcional avanzada

### Archivos a Modificar
- `pubspec.yaml`

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **Dependencia agregada** | `flutter_tts: ^4.2.0` añadida en pubspec.yaml | Revisar pubspec.yaml |
| **Instalación exitosa** | `flutter pub get` ejecuta sin errores | Terminal: `flutter pub get` |
| **Compilación** | El proyecto compila después de añadir dependencia | `flutter build apk --debug` |

### 🎯 Criterios de Aceptación
- [ ] Dependencia flutter_tts añadida correctamente
- [ ] No hay conflictos de versión con otras dependencias
- [ ] El proyecto compila sin errores

---

## FASE 2: TtsService (Solo ejecutar voz - Event-based)

### Objetivo
Crear el servicio de TTS con arquitectura event-driven usando streams. El servicio NO tiene estado propio - solo emite eventos. El Cubit es la única fuente de verdad.

### Tareas

1. Crear `lib/shared/services/tts_service.dart`

```dart
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsEventType { started, completed, cancelled, paused, error }

class TtsEvent {
  final TtsEventType type;
  final String? errorMessage;
  
  TtsEvent(this.type, [this.errorMessage]);
}

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final _eventController = StreamController<TtsEvent>.broadcast();
  
  double _speed = 1.0;
  double get speed => _speed;
  
  Stream<TtsEvent> get events => _eventController.stream;
  
  Future<void> init() async {
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setSpeechRate(_speed);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // El servicio solo emite eventos, NO actualiza estado propio
    _flutterTts.setStartHandler(() {
      _eventController.add(TtsEvent(TtsEventType.started));
    });
    
    _flutterTts.setCompletionHandler(() {
      _eventController.add(TtsEvent(TtsEventType.completed));
    });
    
    _flutterTts.setCancelHandler(() {
      _eventController.add(TtsEvent(TtsEventType.cancelled));
    });
    
    _flutterTts.setPauseHandler(() {
      _eventController.add(TtsEvent(TtsEventType.paused));
    });
    
    _flutterTts.setErrorHandler((message) {
      _eventController.add(TtsEvent(TtsEventType.error, message.toString()));
    });
  }
  
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      _eventController.add(TtsEvent(TtsEventType.error, e.toString()));
    }
  }
  
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      _eventController.add(TtsEvent(TtsEventType.error, e.toString()));
    }
  }
  
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      _eventController.add(TtsEvent(TtsEventType.error, e.toString()));
    }
  }
  
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _flutterTts.setSpeechRate(speed);
  }
  
  void dispose() {
    _flutterTts.stop();
    _eventController.close();
  }
}
```

**Puntos clave:**
- ✅ El servicio NO tiene estado público (TtsState eliminado)
- ✅ Solo emite eventos via Stream
- ✅ El Cubit escucha los eventos y actualiza su propio estado
- ✅ Single source of truth: el Cubit

2. Registrar en `injection_container.dart`:
   ```dart
   final ttsService = TtsService();
   await ttsService.init();
   getIt.registerLazySingleton<TtsService>(() => ttsService);
   ```

### Archivos a Modificar
- `injection_container.dart`

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **TtsService creado** | Archivo `tts_service.dart` existe en `lib/shared/services/` | Verificar archivo existe |
| **Event-based** | Usa StreamController para eventos, NO callbacks | Revisar código |
| **Sin estado propio** | TtsService NO tiene TtsState público | Revisar código |
| **Métodos básicos** | speak(), pause(), stop(), setSpeed() implementados | Revisar código |
| **Eventosemitidos** | events stream disponible con TtsEventType | Revisar código |
| **Error handling** | try/catch en speak, pause, stop | Revisar código |
| **Registro DI** | TtsService registrado en injection_container.dart | Revisar código |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] TtsService implementa arquitectura event-driven con Stream
- [ ] El servicio NO mantiene estado público (Single Source of Truth en Cubit)
- [ ] Todos los métodos tienen manejo de errores
- [ ] El servicio se registra correctamente en el contenedor de DI
- [ ] Pasa análisis estático sin errores

---

## FASE 5: AudioPlayerCubit (Control de flujo - Corregido)

### Objetivo
Crear el Cubit que controla el flujo de reproducción (única fuente de verdad), usando eventos del TtsService.

### Tareas

1. Crear `lib/features/reader/logic/cubit/audio_player_cubit.dart`

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/services/tts_service.dart';
import '../../data/models/audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlaybackState> {
  final TtsService _ttsService;
  List<String> _paragraphs = [];
  int _currentIndex = 0;
  StreamSubscription? _ttsSubscription;
  
  AudioPlayerCubit(this._ttsService) : super(AudioPlaybackState()) {
    // Escuchar eventos del TtsService (NO usar callbacks)
    _ttsSubscription = _ttsService.events.listen(_handleTtsEvent);
  }
  
  void _handleTtsEvent(TtsEvent event) {
    switch (event.type) {
      case TtsEventType.completed:
        _nextParagraph(); // Reproducir siguiente automáticamente
        break;
      case TtsEventType.error:
        emit(state.copyWith(
          status: AudioStatus.error,
          errorMessage: event.errorMessage,
        ));
        break;
      case TtsEventType.cancelled:
        // No hacer nada, el Cubit ya controla el estado
        break;
      default:
        break;
    }
  }
  
  void loadParagraphs(List<String> paragraphs) {
    _paragraphs = paragraphs;
    _currentIndex = 0;
    emit(state.copyWith(
      status: AudioStatus.idle,
      currentParagraphIndex: 0,
      totalParagraphs: paragraphs.length,
      errorMessage: null,
    ));
  }
  
  Future<void> play() async {
    if (_paragraphs.isEmpty) return;
    
    try {
      final text = _paragraphs[_currentIndex];
      await _ttsService.speak(text);
      emit(state.copyWith(status: AudioStatus.playing, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: 'Error al reproducir: $e',
      ));
    }
  }
  
  Future<void> _nextParagraph() async {
    if (_currentIndex < _paragraphs.length - 1) {
      _currentIndex++;
      emit(state.copyWith(currentParagraphIndex: _currentIndex));
      
      // Reproducir siguiente automáticamente
      try {
        await _ttsService.speak(_paragraphs[_currentIndex]);
      } catch (e) {
        emit(state.copyWith(status: AudioStatus.error, errorMessage: e.toString()));
      }
    } else {
      emit(state.copyWith(status: AudioStatus.stopped));
    }
  }
  
  Future<void> pause() async {
    try {
      await _ttsService.pause();
      emit(state.copyWith(status: AudioStatus.paused));
    } catch (e) {
      emit(state.copyWith(status: AudioStatus.error, errorMessage: e.toString()));
    }
  }
  
  Future<void> stop() async {
    try {
      await _ttsService.stop();
      _currentIndex = 0;
      emit(state.copyWith(status: AudioStatus.stopped, currentParagraphIndex: 0));
    } catch (e) {
      emit(state.copyWith(status: AudioStatus.error, errorMessage: e.toString()));
    }
  }
  
  Future<void> nextParagraph() async {
    await _ttsService.stop();
    if (_currentIndex < _paragraphs.length - 1) {
      _currentIndex++;
      emit(state.copyWith(currentParagraphIndex: _currentIndex));
    }
  }
  
  Future<void> previousParagraph() async {
    await _ttsService.stop();
    if (_currentIndex > 0) {
      _currentIndex--;
      emit(state.copyWith(currentParagraphIndex: _currentIndex));
    }
  }
  
  Future<void> setSpeed(double speed) async {
    try {
      await _ttsService.setSpeed(speed);
      emit(state.copyWith(speed: speed));
    } catch (e) {
      // Error de velocidad no es crítico, continuar
    }
  }
  
  @override
  Future<void> close() {
    _ttsSubscription?.cancel();
    _ttsService.stop();
    return super.close();
  }
}
```

**Puntos clave:**
- ✅ Escucha eventos via Stream (NO usa setCompletionHandler)
- ✅ _nextParagraph() reproduce automáticamente el siguiente párrafo
- ✅ Manejo de errores try/catch
- ✅ Suscripción se cancela en close()
- ✅ Single source of truth: el Cubit

2. Registrar en `injection_container.dart`:
   ```dart
   getIt.registerFactory<AudioPlayerCubit>(
     () => AudioPlayerCubit(getIt<TtsService>()),
   );
   ```

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **AudioPlayerCubit creado** | Archivo `audio_player_cubit.dart` existe en `lib/features/reader/logic/cubit/` | Verificar archivo existe |
| **Escucha eventos TTS** | Suscribe a `_ttsService.events` | Revisar código |
| **Single source of truth** | AudioPlaybackState es el único estado | Revisar código |
| **_nextParagraph reproduce** | Llama a `speak()` para siguiente párrafo | Revisar código |
| **Manejo de errores** | try/catch en play, pause, stop, next, previous | Revisar código |
| **Cancelar suscripción** | Cancela `_ttsSubscription?.cancel()` en close() | Revisar código |
| **Registro DI** | AudioPlayerCubit registrado como factory | Revisar código |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] AudioPlayerCubit escucha eventos via Stream (NO usa callbacks de TTS)
- [ ] _nextParagraph() reproduce automáticamente el siguiente párrafo
- [ ] Todas las operaciones tienen manejo de errores
- [ ] La suscripción se cancela correctamente en close()
- [ ] El Cubit es la única fuente de verdad del estado de audio
- [ ] Pasa análisis estático sin errores

---

## FASE 6: ReaderCubit - Añadir Modo

### Objetivo
Extender el ReaderCubit existente para soportar el cambio de modo.

### Tareas

1. Modificar `reader_cubit.dart`:
   - Añadir `_currentMode = ReaderMode.reading`
   - Añadir getter `currentMode`
   - Añadir método `setReaderMode(ReaderMode mode)`
   - Añadir método `toggleMode()`

```dart
// En ReaderState o ReaderCubit
ReaderMode _currentMode = ReaderMode.reading;

ReaderMode get currentMode => _currentMode;

void setReaderMode(ReaderMode mode) {
  _currentMode = mode;
  emit(state.copyWith());
}

void toggleMode() {
  _currentMode = _currentMode == ReaderMode.reading 
      ? ReaderMode.audio 
      : ReaderMode.reading;
  emit(state.copyWith());
}
```

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **ReaderMode enum** | EnumReaderMode (reading, audio, hybrid) existe | Revisar código |
| **currentMode getter** | Getter para obtener modo actual | Revisar código |
| **setReaderMode()** | Método para cambiar modo | Revisar código |
| **toggleMode()** | Método para alternar entre lectura y audio | Revisar código |
| **Integración con estado** | El cambio de modo emite nuevo estado | Revisar código |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] ReaderMode enum definido con los valores correctos
- [ ] ReaderCubit tiene métodos para gestionar el modo
- [ ] El cambio de modo properly actualiza el estado
- [ ] Pasa análisis estático sin errores

---

## FASE 7: ModeToggleWidget y ReaderAppBar

### Objetivo
Crear el widget de toggle y modificar el AppBar.

### Tareas

1. Crear `lib/features/reader/ui/widgets/mode_toggle_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../../data/models/reader_mode.dart';

class ModeToggleWidget extends StatelessWidget {
  final ReaderMode currentMode;
  final ValueChanged<ReaderMode> onModeChanged;
  
  const ModeToggleWidget({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(context, ReaderMode.reading, Icons.menu_book, 'Lectura'),
          _buildSegment(context, ReaderMode.audio, Icons.headphones, 'Audio'),
        ],
      ),
    );
  }
  
  Widget _buildSegment(BuildContext context, ReaderMode mode, IconData icon, String label) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Theme.of(context).colorScheme.onPrimary : null),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
            ],
          ],
        ),
      ),
    );
  }
}
```

2. Modificar `reader_header.dart` o crear `reader_app_bar.dart` para incluir el toggle en las actions.

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **ModeToggleWidget creado** | Archivo existe en `lib/features/reader/ui/widgets/` | Verificar archivo existe |
| **Segmentos visuales** | Muestra icono+label cuando activo, solo icono cuando inactivo | Test visual |
| **Animación** | AnimatedContainer con duration ~200ms | Revisar código |
| **Callback funcional** | onModeChanged llama a setReaderMode | Revisar código |
| **Integración en AppBar** | Toggle visible en las actions del AppBar | Test visual |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] ModeToggleWidget permite cambiar entre lectura y audio
- [ ] La animación de cambio de segmento es suave
- [ ] El toggle se integra correctamente en el AppBar
- [ ] Pasa análisis estático sin errores

---

## FASE 8: ReadingView y ReadingFooter

### Objetivo
Separar la vista y footer de lectura existentes.

### Tareas

1. Crear `lib/features/reader/ui/widgets/reading_view.dart`
   - Mantener la vista actual del lector (texto estático)
   - No hacer cambios significativos

2. Crear `lib/features/reader/ui/widgets/reading_footer.dart`
   - Mantener controles existentes: ⚙️ Ajustes + Progress + 📑 Índices

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **ReadingView creado** | Widget existe y muestra contenido del lector | Test visual |
| **ReadingFooter creado** | Widget existe con ⚙️ + Progress + 📑 | Test visual |
| **Funcionalidad preservada** | El comportamiento de lectura no cambia | Test funcional |
| **Integración con estado** | Usa BlocBuilder para estado del lector | Revisar código |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] ReadingView muestra el contenido del libro correctamente
- [ ] ReadingFooter mantiene los controles existentes
- [ ] La funcionalidad de lectura no se ve afectada
- [ ] Pasa análisis estático sin errores

---

## FASE 9: ListeningView con Highlight

### Objetivo
Crear la vista de audio con highlight de párrafos usando ScrollablePositionedList (optimizado para rendimiento). Corregidos memory leaks.

### Tareas

1. Añadir dependencia en pubspec.yaml:
   ```yaml
   # ScrollablePositionedList ya viene con flutter
   ```

2. Crear `lib/features/reader/ui/widgets/listening_view.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/audio_player_cubit.dart';

class ListeningView extends StatefulWidget {
  final List<String> paragraphs;
  final Function(int)? onParagraphChanged;
  
  const ListeningView({
    super.key, 
    required this.paragraphs,
    this.onParagraphChanged,
  });
  
  @override
  State<ListeningView> createState() => _ListeningViewState();
}

class _ListeningViewState extends State<ListeningView> {
  StreamSubscription? _subscription;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // NO cargar aquí - hacerlo en ReaderPage o use case
    // context.read<AudioPlayerCubit>().loadParagraphs(widget.paragraphs);
    
    // Auto-scroll cuando cambia el párrafo actual
    _subscription = context.read<AudioPlayerCubit>().stream.listen((state) {
      if (state.status == AudioStatus.playing) {
        _scrollToParagraph(state.currentParagraphIndex);
      }
    });
  }
  
  void _scrollToParagraph(int index) {
    // Usar animateTo en lugar de jumpToItem (no existe en ListView)
    if (_scrollController.hasClients) {
      // Calcular posición basada en índice (aproximado)
      // Para precisión, usar ScrollablePositionedList
      final position = index * 200.0; // Altura promedio ~200px
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // ✅ IMPORTANTE: Prevenir memory leak
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
      buildWhen: (prev, curr) => 
        prev.currentParagraphIndex != curr.currentParagraphIndex ||
        prev.status != curr.status,
      builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: widget.paragraphs.length,
          itemBuilder: (context, index) {
            final isCurrent = index == state.currentParagraphIndex;
            return _ParagraphWidget(
              text: widget.paragraphs[index],
              isCurrent: isCurrent && state.status == AudioStatus.playing,
            );
          },
        );
      },
    );
  }
}

class _ParagraphWidget extends StatelessWidget {
  final String text;
  final bool isCurrent;
  
  const _ParagraphWidget({required this.text, required this.isCurrent});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
            : Colors.transparent,
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
```

**Nota sobre ScrollablePositionedList:** Se usa `ListView.builder` con `jumpToItem` por simplicidad. Si en testing se detecta problema de rendimiento con muchos párrafos (>100), migrar a `ScrollablePositionedList` que virtualiza los elementos visibles.

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **ListeningView creado** | Widget existe en `lib/features/reader/ui/widgets/` | Verificar archivo existe |
| **BlocBuilder** | Usa BlocBuilder para AudioPlayerState | Revisar código |
| **buildWhen** | Implementado para evitar rebuilds innecesarios | Revisar código |
| **Highlight visual** | Párrafo actual tiene background de color | Test visual |
| **Animación** | AnimatedContainer con 200ms | Revisar código |
| **Auto-scroll** | Llama a scrollToParagraph en cambios de estado | Revisar código |
| **Memory leak** | Subscription cancelada en dispose() | Revisar código |
| **Carga de párrafos** | NO se hace en initState (se hace en ReaderPage) | Revisar código |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] ListeningView muestra los párrafos con highlight
- [ ] El highlight se actualiza cuando cambia el párrafo actual
- [ ] La animación de highlight es suave (200ms)
- [ ] No hay memory leaks (suscripción cancelada en dispose)
- [ ] Los párrafos se cargan desde ReaderPage, no desde la UI
- [ ] Pasa análisis estático sin errores

---

## FASE 10: AudioFooter (Controles de navegación)

### Objetivo
Crear el footer con controles de navegación por párrafos.

### Tareas

1. Crear `lib/features/reader/ui/widgets/audio_footer.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import 'data/models/audio_player_state.dart';

class AudioFooter extends StatelessWidget {
  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;
  
  const AudioFooter({super.key, this.onPreviousChapter, this.onNextChapter});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
      buildWhen: (prev, curr) => prev.status != curr.status || prev.speed != curr.speed,
      builder: (context, state) {
        final isPlaying = state.status == AudioStatus.playing;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Speed selector
                _SpeedSelector(currentSpeed: state.speed),
                const SizedBox(height: 12),
                // Progress (párrafo actual / total)
                LinearProgressIndicator(
                  value: state.totalParagraphs > 0 
                      ? state.currentParagraphIndex / state.totalParagraphs 
                      : 0,
                ),
                const SizedBox(height: 12),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () => context.read<AudioPlayerCubit>().previousParagraph(),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        final cubit = context.read<AudioPlayerCubit>();
                        isPlaying ? cubit.pause() : cubit.play();
                      },
                      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => context.read<AudioPlayerCubit>().nextParagraph(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  final double currentSpeed;
  
  const _SpeedSelector({required this.currentSpeed});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
        final isSelected = currentSpeed == speed;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton(
            onPressed: () => context.read<AudioPlayerCubit>().setSpeed(speed),
            child: Text(
              '${speed}x',
              style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **AudioFooter creado** | Widget existe en `lib/features/reader/ui/widgets/` | Verificar archivo existe |
| **Controles play/pause** | Botón play/pause funcional | Test visual |
| **Navegación párrafos** | Botones next/previous paragraph funcionan | Test funcional |
| **Speed selector** | Botones de velocidad (0.5x a 1.5x) | Test visual |
| **Progress indicator** | Muestra progreso por párrafos (actual/total) | Test visual |
| **BlocBuilder** | Usa BlocBuilder con buildWhen para status y speed | Revisar código |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] AudioFooter muestra todos los controles correctamente
- [ ] Play/Pause cambia el estado de reproducción
- [ ] Next/Previous permiten navegar entre párrafos
- [ ] Los botones de velocidad funcionan correctamente
- [ ] El indicador de progreso se actualiza dinámicamente
- [ ] Pasa análisis estático sin errores

---

## FASE 11: ReaderPage - Renderizado Condicional

### Objetivo
Integrar todo en el ReaderPage con renderizado condicional, AnimatedSwitcher y carga de párrafos desde el use case (NO desde la UI).

### Tareas

1. Modificar `reader_page.dart`:

```dart
class ReaderPage extends StatefulWidget {
  final int bookId;
  
  const ReaderPage({super.key, required this.bookId});
}

class ReaderPageState extends State<ReaderPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // ⚠️ NO pausar en background - el caso de uso principal es audiolibro con pantalla apagada
  // Solo pausar si hay interrupciones del sistema (llamadas)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Por ahora NO hacer nada en background
    // future: si audio_service no está implementado, pausar aquí
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AudioPlayerCubit>(),
      child: BlocBuilder<ReaderCubit, ReaderState>(
        builder: (context, readerState) {
          final mode = context.watch<ReaderCubit>().currentMode;
          
          return Scaffold(
            appBar: ReaderAppBar(
              mode: mode,
              onModeToggle: (m) {
                context.read<ReaderCubit>().setReaderMode(m);
                // Cargar párrafos cuando cambia a modo audio
                if (m == ReaderMode.audio) {
                  _loadParagraphs(context, readerState);
                }
              },
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: mode == ReaderMode.reading
                  ? const ReadingView()
                  : ListeningView(paragraphs: _getParagraphs(readerState)),
            ),
            bottomNavigationBar: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: mode == ReaderMode.reading
                  ? const ReadingFooter()
                  : const AudioFooter(),
            ),
          );
        },
      ),
    );
  }
  
  void _loadParagraphs(BuildContext context, ReaderState state) {
    // Extraer párrafos del estado del lector
    final paragraphs = _extractParagraphs(state);
    context.read<AudioPlayerCubit>().loadParagraphs(paragraphs);
  }
  
  List<String> _extractParagraphs(ReaderState state) {
    // Extraer párrafos del contenido del capítulo actual
    // Implementar según la estructura actual del ReaderState
    return [];
  }
  
  List<String> _getParagraphs(ReaderState state) {
    // Obtener párrafos ya cargados
    return _extractParagraphs(state);
  }
}
```

**Puntos clave:**
- ✅ NO pausar en background (rompería caso de uso de audiolibro)
- ✅ Cargar párrafos desde el use case/ReaderPage, NO desde ListeningView
- ✅ UI no inicializa lógica

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **BlocProvider** | ReaderPage provee AudioPlayerCubit | Revisar código |
| **Renderizado condicional** | Cambia entre ReadingView y ListeningView según modo | Test visual |
| **AnimatedSwitcher** | Transición suave de 300ms entre vistas | Test visual |
| **Toggle funcional** | Cambiar modo actualiza UI correctamente | Test funcional |
| **WidgetsBindingObserver** | Implementado pero NO pausa en background | Revisar código |
| **Carga de párrafos** | loadParagraphs() llamado desde ReaderPage | Revisar código |
| **Linting** | `flutter analyze` sin errores | Terminal |

### 🎯 Criterios de Aceptación
- [ ] El cambio de modo actualiza correctamente la vista (lectura ↔ audio)
- [ ] La transición entre modos es animada (no instantánea)
- [ ] Los párrafos se cargan correctamente al cambiar a modo audio
- [ ] El audio NO se pausa cuando la app pasa a background (caso de uso válido)
- [ ] Pasa análisis estático sin errores

---

## FASE 12: Persistencia y Resume

### Objetivo
Guardar y restaurar la posición de audio.

### Tareas

1. Modificar `AudioPlayerCubit` para persistir posición:

```dart
Future<void> _savePosition() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('audio_position_$bookId', _currentIndex);
}

// Llamar en pause, stop, y cuando cambie de capítulo
```

2. Cargar posición al inicio:

```dart
Future<void> _loadPosition() async {
  final prefs = await SharedPreferences.getInstance();
  final position = prefs.getInt('audio_position_$bookId') ?? 0;
  _currentIndex = position;
}
```

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **Persistencia posición** | Se guarda índice de párrafo actual | Revisar código |
| **SharedPreferences** | Usa prefs para almacenar posición | Revisar código |
| **Carga de posición** | Al iniciar, restaura última posición | Test funcional |
| **Clave única** | usa `audio_position_$bookId` para separar libros | Revisar código |

### 🎯 Criterios de Aceptación
- [ ] La posición de audio se guarda al pausar/detener
- [ ] Al volver al modo audio, se restaura la posición anterior
- [ ] Cada libro tiene su propia posición guardada
- [ ] Funciona correctamente con persistencia

---

## FASE 13: Testing y Optimización

### Objetivo
Verificar que todo funcione correctamente.

### Tareas

1. **Flutter Analyze**:
   ```bash
   flutter analyze lib/features/reader/
   ```

2. **Verificar dispose**:
   - AudioPlayerCubit se cierra al salir
   - TtsService se dispose correctamente

3. **Testing en dispositivo**:
   - Reproducción con pantalla apagada
   - Controles en lock screen
   - Cambio de modo lectura ↔ audio

### ✅ Criterios de Evaluación y Aceptación

| Criterio | Descripción | Método de Verificación |
|----------|-------------|-------------------------|
| **flutter analyze** | Sin errores en `lib/features/reader/` | Terminal |
| **Dispose AudioPlayerCubit** | Se cierra correctamente al salir | Revisar código |
| **Dispose TtsService** | Se dispose al cerrar el servicio | Revisar código |
| **Memory leaks** | No hay listeners sin cancelar | Test con observer |
| **Test funcional** | TTS reproduce correctamente | Test en dispositivo |
| **Test modo toggle** | Cambio lectura ↔ audio funciona | Test funcional |
| **Test navigation** | Next/Previous párrafos funcionan | Test funcional |
| **Test speed** | Cambio de velocidad funciona | Test funcional |
| **Test resume** | Persistencia de posición funciona | Test funcional |

### 🎯 Criterios de Aceptación
- [ ] Pasa `flutter analyze` sin errores
- [ ] Todos los recursos se limpian correctamente en dispose
- [ ] No hay memory leaks en la aplicación
- [ ] La reproducción de audio funciona correctamente
- [ ] El cambio entre modos funciona sin errores
- [ ] La navegación entre párrafos funciona correctamente
- [ ] El cambio de velocidad de reproducción funciona
- [ ] La persistencia de posición funciona correctamente
- [ ] Todas las pruebas funcionales pasan

---

## Resumen de Archivos

### Archivos Nuevos (11)

| Archivo | Fase | Descripción |
|---------|------|-------------|
| `tts_service.dart` | 2 | Wrapper Flutter TTS |
| `audio_handler.dart` | 3 | Handler para notificaciones |
| `reader_mode.dart` | 4 | Enum de modos |
| `audio_player_cubit.dart` | 5 | Control de flujo |
| `mode_toggle_widget.dart` | 7 | Toggle de modos |
| `reading_view.dart` | 8 | Vista lectura |
| `reading_footer.dart` | 8 | Footer lectura |
| `listening_view.dart` | 9 | Vista audio con highlight |
| `audio_footer.dart` | 10 | Footer audio |
| `speed_selector_widget.dart` | 10 | Botones de velocidad |
| `audio_player_service.dart` | - | Stub para audio files |

### Archivos a Modificar (7)

| Archivo | Fase | Cambio |
|---------|------|--------|
| `pubspec.yaml` | 1 | Añadir dependencias |
| `AndroidManifest.xml` | 1 | Permisos foreground |
| `main.dart` | 1 | Inicializar AudioService |
| `injection_container.dart` | 2,5 | Registrar servicios y cubit |
| `reader_cubit.dart` | 6 | Añadir modo |
| `reader_page.dart` | 11 | Renderizado condicional |
| `reader_header.dart` | 7 | Añadir toggle |

---

## Dependencias entre Fases

```
FASE 1 (Dependencias)
         ↓
FASE 2 (TtsService) ← FASE 1
         ↓
FASE 3 (AudioHandler) ← FASE 2
         ↓
FASE 4 (Modelos) ← FASE 1
         ↓
FASE 5 (AudioPlayerCubit) ← FASE 2, FASE 4
         ↓
FASE 6 (ReaderCubit modo) ← FASE 4
         ↓
FASE 7 (Toggle/AppBar) ← FASE 6
         ↓
FASE 8 (Reading View/Footer)
         ↓
FASE 9 (ListeningView) ← FASE 5, FASE 8
         ↓
FASE 10 (AudioFooter) ← FASE 5
         ↓
FASE 11 (ReaderPage integración) ← FASE 7, 8, 9, 10
         ↓
FASE 12 (Persistencia) ← FASE 5
         ↓
FASE 13 (Testing)
```

---

## Notas de Arquitectura

1. **Single Source of Truth**: AudioPlayerCubit es la única fuente de verdad
2. **Event-driven**: TtsService emite eventos via Stream, NO callbacks
3. **Separación de responsabilidades**: TtsService solo ejecuta voz, Cubit controla flujo
4. **Navegación por párrafos**: No seek por tiempo, solo next/prev párrafo
5. **Memory leaks**: Cancelar suscripciones en dispose (implementado)
6. **No pausar en background**: Caso de uso principal es audiolibro con pantalla apagada
7. **Scope inicial**: Modo híbrido es fase posterior, no en scope inicial
8. **Carga desde use case**: NO desde la UI (ListeningView)
9. **Manejo de errores**: try/catch en todas las operaciones TTS

---

## Errores Corregidos en Esta Versión

| Bug | Problema | Solución |
|-----|----------|----------|
| 2.1 | Sobrescribir handlers de TTS | Usar Stream de eventos |
| 2.2 | _nextParagraph() no reproducía | Añadir await speak() en _nextParagraph() |
| 2.3 | Memory leak en ListeningView | Cancelar subscription en dispose() |
| 2.4 | jumpToItem() no existe | Usar animateTo con posición aproximada |
| 2.5 | Estado duplicado (TtsState + AudioStatus) | Eliminar TtsState del servicio |
| 2.6 | Pausar en background romría UX | No pausar - audiolibro funciona con pantalla apagada |

---

## Limitaciones de TTS y Estrategia Futura

### Limitaciones de flutter_tts

 flutter_tts no está diseñado para casos de uso avanzados:
- ❌ Callbacks inconsistentes entre plataformas
- ❌ Sin timing preciso por palabra/párrafo
- ❌ No soporta seek real
- ❌ Control limitado del progreso
- ❌ Integración imperfecta con audio_service

### Esta implementación es un MVP

El sistema actual debe considerarse como **versión inicial** para validar funcionalidad, no como la solución final de audiolibro.

### Arquitectura Preparada para Migración

El diseño actual ya permite evolucionar sin rehacer todo:

```
┌─────────────────────────────────────────────────────────────┐
│                    ARQUITECTURA ACTUAL                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   AudioPlayerCubit                                         │
│         │                                                   │
│         ▼                                                   │
│   IAudioPlaybackService (interfaz) ← ABSTRACCIÓN           │
│         │                                                   │
│    ┌────┴────┐                                             │
│    ▼         ▼                                             │
│ TtsService  Future: AudioFileService                       │
│ (flutter_tts)  (just_audio + audio real)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Cómo Implementar la Abstracción

1. **Crear interfaz** (`lib/shared/services/i_audio_playback_service.dart`):

```dart
abstract class IAudioPlaybackService {
  Future<void> play(String textOrUrl);
  Future<void> pause();
  Future<void> stop();
  Future<void> setSpeed(double speed);
  Stream<PlaybackEvent> get events;
  
  // Permite cambiar implementación sin tocar Cubit
}

class PlaybackEvent {
  final PlaybackEventType type;
  final int? paragraphIndex;  // Para TTS
  final Duration? position;    // Para audio real
  final Duration? duration;
}

enum PlaybackEventType { started, paused, stopped, completed, paragraphChanged }
```

2. **TtsService implementa la interfaz**:

```dart
class TtsService implements IAudioPlaybackService {
  // ... implementación actual
}
```

3. **AudioPlayerCubit usa la interfaz** (ya lo hace implícitamente)

### Estrategia de Migración Futura

**Fase futura (no en scope):**

1. **Generar audioexterno**: Usar servicios TTS externos (Google Cloud TTS, Amazon Polly, Azure) para generar archivos de audio con timestamps

2. **Sincronización precisa**: El audio generado incluye timestamps por palabra, permitiendo:
   - Seek exacto por tiempo
   - Highlight palabra por palabra
   - Progress preciso

3. **Reproducir con just_audio**:
   ```dart
   class AudioFileService implements IAudioPlaybackService {
     final JustAudioPlayer _player = JustAudioPlayer();
     
     @override
     Future<void> play(String url) async {
       await _player.setUrl(url);
       await _player.play();
     }
     
     @override
     Stream<PlaybackEvent> get events => _player.positionStream.map((pos) {
       // Convertir position a paragraphIndex usando timestamps
     });
   }
   ```

4. **Integración completa con audio_service**:
   - Controles reales en lock screen
   - Seek funcional
   - Background playback robusto

### Recomendación

**Fase actual (MVP):**
- Implementar con flutter_tts
- Validar funcionalidad básica
- Releccionar feedback de usuarios

**Fase futura:**
- Si la experiencia con TTS es insuficiente, migrar a audio real
- La abstracción ya está lista en el diseño actual
- Solo hay que implementar una nueva clase que implemente la interfaz

---

*Documento actualizado: Abril 2026*
*Proyecto: Open Books Mobile*