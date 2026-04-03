# AGENTS - Open Books Mobile

Guía técnica para agentes de código que operan en este repositorio.

---

## Stack Tecnológico

- **Framework**: Flutter 3.x / Dart 3.x
- **Estado**: flutter_bloc (Cubit) ^8.x
- **HTTP Client**: Dio ^5.x
- **DI**: get_it ^7.x
- **Navegación**: go_router ^14.x
- **Almacenamiento**: flutter_secure_storage ^9.x

---

## Comandos de Desarrollo

### Análisis y Lint

```bash
flutter analyze              # Analizar todo el proyecto
flutter analyze lib/          # Analizar directorio específico
flutter analyze lib/main.dart # Analizar archivo específico
```

### Testing

```bash
flutter test                 # Ejecutar todos los tests
flutter test test/           # Ejecutar tests de un directorio
flutter test test/path/file_test.dart # Ejecutar test específico
flutter test --name "pattern" # Ejecutar tests que coincidan con patrón
flutter test test/ --reporter compact # Output compacto
flutter test --coverage      # Con coverage
```

### Build

```bash
flutter build apk --debug    # Debug APK Android
flutter build apk --release  # Release APK Android
flutter build ios --simulator # iOS Simulator
flutter run                 # Run por defecto
```

---

## Convenciones de Código

### Archivos y Naming

| Elemento          | Convención   | Ejemplo             |
|-------------------|--------------|---------------------|
| Archivos Dart     | snake_case   | `auth_cubit.dart`   |
| Clases/States     | PascalCase   | `AuthState`         |
| Variables/Func    | camelCase    | `authRepository`    |
| Constantes        | UPPER_SNAKE  | `MAX_RETRIES`       |
| Rutas             | kebab-case   | `/book-detail`      |

### Imports

```dart
// 1. Paquetes externos
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 2. Paquetes internos (relative)
import '../../logic/cubit/auth_cubit.dart';
import '../widgets/my_widget.dart';
```

### Estructura de Feature

```
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── logic/cubit/
└── ui/
    ├── pages/
    └── widgets/
```

### UI y Tema

- Usar `Theme.of(context)` para colores, textos, estilos
- Todos los widgets deben soportar tema claro/oscuro
- Usar `context.watch<T>()` o `BlocBuilder` para rebuilds

### Error Handling

- exceptions/ en `shared/core/` para excepciones de infraestructura
- failures/ en `shared/core/` para errores del dominio
- Siempre usar `Either<Failure, T>` en repositories
- Mostrar mensajes apropiados según código de error HTTP

---

## Puntos Críticos

- **Sesión**: Usar `SessionCubit.login()` y `SessionCubit.logout()`
- **EPUB**: Manejar UTF-8 e ISO-8859-1 en `features/reader/`
- **SignalR**: Implementar reconexión al foreground en `shared/services/`
- **Descarga**: Cancelar descargas al salir de la página

---

## API Base

- **URL**: Configurable via `.env` (default: `http://10.0.2.2:5201`)
- **Auth**: JWT Bearer Token
- **Errores comunes**: 401 → logout, 403 → "No permiso", 404 → "No encontrado"

---

## Git Workflow

```bash
git checkout -b feat/nombre-rama
git commit -m "feat(auth): Agregar login"
git push -u origin feat/nombre-rama
```

Commits: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

---

## Testing Template

```dart
blocTest<AuthCubit, AuthState>(
  'emits [Loading, Success] when login succeeds',
  build: () => AuthCubit(authRepository: mockAuthRepo),
  act: (cubit) => cubit.login('test@test.com', 'pass'),
  expect: () => [isA<AuthLoading>(), isA<AuthLoginSuccess>()],
);
```

---

*Última actualización: 2026-03-31*