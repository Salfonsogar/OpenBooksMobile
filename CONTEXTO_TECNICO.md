# Contexto Técnico - Open Books Mobile

Guía técnica para desarrolladores del proyecto Open Books Mobile.

---

## 1. Contexto del Sistema

### 1.1 Propósito de la Aplicación
Open Books Mobile es una aplicación móvil desarrollada en Flutter para la gestión y lectura de libros electrónicos. Permite a los usuarios:

- Explorar y buscar libros por título, autor o categoría
- Ver detalles de libros, incluyendo reseñas y valoraciones
- Gestionar su biblioteca personal
- Leer libros en formato EPUB
- Gestionar su cuenta de usuario (registro, login, recuperación de contraseña)
- Recibir notificaciones en tiempo real

### 1.2 Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework | Flutter | 3.x |
| Lenguaje | Dart | 3.x |
| Estado | flutter_bloc (Cubit) | ^8.x |
| HTTP Client | Dio | ^5.x |
| Inyección de Dependencias | get_it | ^7.x |
| Navegación | go_router | ^14.x |
| Almacenamiento Seguro | flutter_secure_storage | ^9.x |
| Variables de Entorno | flutter_dotenv | ^5.x |
| Comunicación Real-time | signalr_client | ^3.x |

### 1.3 API Backend
- **Base URL**: Configurable via `.env` (default: `http://10.0.2.2:5201` para emuladores Android)
- **Autenticación**: JWT Bearer Token
- **Protocolo**: REST API + SignalR para notificaciones

---

## 2. Arquitectura y Estructura de Carpetas

### 2.1 Patrón de Arquitectura
El proyecto sigue una **Arquitectura Basada en Features** con los siguientes principios:

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│   (Pages, Widgets - Solo presentación, sin lógica de negocio)│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Logic Layer                             │
│   (Cubits - Manejo de estado y lógica de presentación)       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│   (Repositories - Abstracción de datasources)                │
│   (Datasources - Comunicación con API/externa)                │
│   (Models - Entidades de datos)                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Core Layer                              │
│   (Network, Session, Theme, Constants, Errors)              │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Estructura de Carpetas

```
open_books_mobile/lib/
├── main.dart                          # Punto de entrada
├── injection_container.dart          # Configuración de DI
├── routing/
│   └── app_router.dart               # Configuración de rutas (go_router)
│
├── features/                          # Features de la aplicación
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/          # AuthDataSource, RolesDataSource
│   │   │   ├── models/               # Usuario, LoginRequest, RegisterRequest
│   │   │   └── repositories/          # AuthRepository, RolesRepository
│   │   ├── logic/
│   │   │   └── cubit/                # AuthCubit, AuthState
│   │   └── ui/
│   │       └── pages/                # LoginPage, RegisterPage, RecoveryPage
│   │
│   ├── libros/
│   │   ├── data/
│   │   │   ├── datasources/          # LibrosDataSource, CategoriasDataSource
│   │   │   ├── models/               # Libro, Categoria, Resena, Valoracion
│   │   │   └── repositories/         # LibrosRepository
│   │   ├── logic/
│   │   │   └── cubit/                # LibrosCubit, CategoriasCubit
│   │   └── ui/
│   │       ├── pages/                # HomePage, SearchPage, BookDetailPage
│   │       └── widgets/              # LibroCard, FilterSheet, RatingDialog
│   │
│   ├── biblioteca/
│   │   ├── data/
│   │   ├── logic/
│   │   └── ui/
│   │
│   ├── perfil/
│   │   ├── data/
│   │   ├── logic/
│   │   └── ui/
│   │
│   ├── historial/
│   │   ├── data/
│   │   ├── logic/
│   │   └── ui/
│   │
│   ├── reader/
│   │   ├── data/
│   │   │   ├── datasources/          # EpubDataSource, BookmarkDataSource
│   │   │   ├── models/               # EpubManifest, Bookmark
│   │   │   └── repositories/         # EpubRepository, BookmarkRepository
│   │   ├── logic/
│   │   │   └── cubit/                # ReaderCubit, BookmarkCubit
│   │   └── ui/
│   │       ├── pages/                # ReaderPage
│   │       └── widgets/              # EpubParser, ReaderSettings
│   │
│   ├── notifications/
│   │   ├── data/
│   │   ├── logic/
│   │   └── ui/
│   │
│   ├── settings/
│   │   └── ui/
│   │
│   └── admin/                        # Módulo de administración
│       ├── dashboard/
│       ├── usuarios/
│       ├── libros/
│       ├── categorias/
│       ├── moderacion/
│       └── sugerencias/
│
├── shared/
│   ├── core/
│   │   ├── constants/                 # AppConstants, ApiConstants
│   │   ├── environment/               # Env (variables de entorno)
│   │   ├── errors/                    # Failures, Exceptions
│   │   ├── network/                   # ApiClient, AuthInterceptor
│   │   ├── session/                  # SessionCubit, SessionState
│   │   └── theme/                    # AppTheme
│   ├── services/                     # SignalRService
│   └── ui/
│       └── widgets/                  # Widgets compartidos
│
└── test/
    └── widget_test.dart
```

### 2.3 Convenciones de Naming

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Archivos Dart | snake_case | `auth_cubit.dart` |
| Clases | PascalCase | `AuthCubit` |
| Variables/Funciones | camelCase | `authRepository` |
| Constantes | camelCase | `apiBaseUrl` |
| Estados de Cubit | PascalCase | `AuthLoading` |
| Rutas | kebab-case | `/book-detail` |

---

## 3. Reglas del Proyecto

### 3.1 Convenciones de Código

#### Estructura de Feature
Cada feature debe seguir la estructura:
```
feature_name/
├── data/
│   ├── datasources/
│   │   └── nombre_datasource.dart
│   ├── models/
│   │   └── nombre_model.dart
│   └── repositories/
│       └── nombre_repository.dart
├── logic/
│   └── cubit/
│       ├── nombre_cubit.dart
│       └── nombre_state.dart
└── ui/
    ├── pages/
    │   └── nombre_page.dart
    └── widgets/
        └── nombre_widget.dart
```

#### Inyección de Dependencias
- Usar `registerLazySingleton` para servicios y repositorios compartidos
- Usar `registerFactory` para Cubits que necesitan nueva instancia
- Inyectar dependencias vía constructor

```dart
// ✅ Correcto
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SessionCubit _sessionCubit;

  AuthCubit({
    required AuthRepository authRepository,
    required SessionCubit sessionCubit,
  }) : _authRepository = authRepository,
       _sessionCubit = sessionCubit,
       super(AuthInitial());
}

// ❌ Incorrecto
class AuthCubit extends Cubit<AuthState> {
  final _authRepository = getIt<AuthRepository>();
  AuthCubit() : super(AuthInitial());
}
```

#### Manejo de Estado en Cubits
- Usar estados inmutables (recordemos que son data classes)
- Nombrar estados de forma descriptiva
- Mantener un solo Cubit por feature cuando sea posible

```dart
// Estados para AuthCubit
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthLoginSuccess extends AuthState { final Usuario usuario; ... }
class AuthError extends AuthState { final String message; }
```

### 3.2 Reglas de Commits

Formato: `<tipo>(<scope>): <descripción>`

Tipos:
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `refactor`: Refactorización sin cambio de funcionalidad
- `style`: Cambios de formato, indentación (sin cambio de lógica)
- `docs`: Cambios en documentación
- `test`: Agregar o modificar tests
- `chore`: Tareas de mantenimiento, dependencias

Scope: módulo afectado (auth, libros, reader, ui, etc.)

Ejemplos:
```
feat(auth): agregar opción de recuperación de contraseña
fix(libros): corregir paginación en búsqueda
refactor(reader): separar EpubParser en clases independientes
docs: actualizar README con nuevas features
```

---

## 4. Decisiones Técnicas

### 4.1 BLoC / Cubit (flutter_bloc)

#### ¿Por qué usar BLoC/Cubit?

**Separación UI / Lógica**
- La UI solo observa estados y emite eventos
- La lógica de negocio vive en el Cubit
- Cambios en la UI no afectan la lógica y viceversa

```dart
// UI solo observa y emite eventos
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return CircularProgressIndicator();
    if (state is AuthError) return Text(state.message);
    return LoginForm();
  },
);

// Lógica en el Cubit
class AuthCubit extends Cubit<AuthState> {
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(email, password);
      emit(AuthLoginSuccess(response.usuario));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

**Escalabilidad por Features**
- Cada feature tiene su propio Cubit
- Los Cubits son independientes entre sí
- Fácil agregar nuevos features sin tocar código existente

```
features/
├── auth/logic/cubit/auth_cubit.dart
├── libros/logic/cubit/libros_cubit.dart
├── biblioteca/logic/cubit/biblioteca_cubit.dart
```

**Testabilidad**
- Los Cubits se pueden testear sin widget testing
- Mocking de dependencias es trivial

```dart
test('AuthCubit emits error on failed login', () {
  final mockRepo = MockAuthRepository();
  when(mockRepo.login(any, any)).thenThrow(Exception('Credenciales inválidas'));
  
  final cubit = AuthCubit(authRepository: mockRepo);
  cubit.login('test@test.com', 'wrong');
  
  expect(cubit.state, isA<AuthError>());
});
```

### 4.2 Dio

#### ¿Por qué usar Dio?

**Interceptores**
Dio permite interceptar requests y responses para funcionalidad transversal.

```dart
// AuthInterceptor - Adjunta token automáticamente
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_shouldAddToken(options.path)) {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: 'auth_token');
    }
    handler.next(err);
  }
}

// LogInterceptor - Logging de requests/responses
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  error: true,
));
```

**Manejo Centralizado de Errores**
Todas las llamadas HTTP pasan por el ApiClient, permitiendo manejo centralizado:

```dart
class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201',
      connectTimeout: Duration(milliseconds: 30000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }
  
  // Método genérico GET con manejo de errores
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

**Características Adicionales**
- Retry automático en fallos de red
- Transformación de request/response
- Cancelación de requests
- Download con progreso

### 4.3 get_it (Inyección de Dependencias)

#### ¿Por qué usar get_it?

**Desacoplamiento**
Las clases no crean sus dependencias, las reciben:

```dart
// ❌ Sin DI - Alto acoplamiento
class AuthCubit {
  final authRepository = AuthRepository(); // Creado internamente
}

// ✅ Con DI - Bajo acoplamiento
class AuthCubit {
  final AuthRepository _authRepository;
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository;
}
```

**Facilita Testing (Mocking)**
Mocking es trivial porque las dependencias se inyectan:

```dart
// Test con mock
final mockAuthRepo = MockAuthRepository();
final mockRolesRepo = MockRolesRepository();
final mockSessionCubit = MockSessionCubit();

final authCubit = AuthCubit(
  authRepository: mockAuthRepo,
  rolesRepository: mockRolesRepo,
  sessionCubit: mockSessionCubit,
);
```

**Registro Centralizado**
Todas las dependencias se registran en un solo lugar:

```dart
// injection_container.dart
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<SessionCubit>(() => SessionCubit());

  // Auth
  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthDataSource>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      rolesRepository: getIt<RolesRepository>(),
      sessionCubit: getIt<SessionCubit>(),
    ),
  );
}
```

### 4.4 go_router

Navegación declarativa con soporte para:
- Navegación programática
- Deep linking
- Redirecciones basadas en estado de autenticación
- Rutas anidadas (ShellRoute)

---

## 5. Flujo de Ejecución y Casos de Uso

### 5.1 Flujo de Arranque de la App

```
main.dart
    │
    ▼
Env.init() → Carga variables de entorno
    │
    ▼
setupDependencies() → Registra todas las dependencias en getIt
    │
    ▼
runApp() → Inicia la aplicación
    │
    ▼
AppRouter → Evalúa estado de sesión
    │
    ├── Usuario autenticado → /home o /admin (según rol)
    │
    └── Usuario no autenticado → /login
```

### 5.2 Flujo de Autenticación

```
┌─────────────┐
│ LoginPage   │
└──────┬──────┘
       │ onTap Login (email, password)
       ▼
┌─────────────────────────────────────────┐
│ AuthCubit.login()                        │
│ 1. emit(AuthLoading)                    │
│ 2. _authRepository.login(email, pass)   │
│ 3. _rolesRepository.getRol(rolId)       │
│ 4. _sessionCubit.login(token, user)      │
│ 5. emit(AuthLoginSuccess)                │
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ AppRouter redirect()                     │
│ SessionAuthenticated → /home o /admin   │
└─────────────────────────────────────────┘
```

### 5.3 Flujo de Catálogo de Libros

```
┌─────────────┐
│ HomePage    │
└──────┬──────┘
       │ initState → LibrosCubit.loadLibros()
       ▼
┌─────────────────────────────────────────┐
│ LibrosCubit                             │
│ 1. emit(LibrosLoading)                   │
│ 2. _repository.getLibros()               │
│ 3. _repository.getCategorias()           │
│ 4. emit(LibrosLoaded(libros, categorias))│
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ HomePage rebuilds                        │
│ Muestra categorías, libros, búsqueda     │
└─────────────────────────────────────────┘
```

### 5.4 Flujo de Detalle de Libro

```
┌─────────────────┐
│ BookDetailPage   │
└──────┬──────────┘
       │ initState → LibroDetalleCubit.load(libroId)
       ▼
┌─────────────────────────────────────────┐
│ LibroDetalleCubit                        │
│ 1. emit(Loading)                         │
│ 2. _repository.getLibroDetalle(id)      │
│ 3. _repository.getResenas(id)           │
│ 4. _bibliotecaDataSource.estaEnBiblioteca(id)
│ 5. emit(Loaded(libro, resenas, enBiblioteca))
└─────────────────────────────────────────┘
       │
       ├── onTap Agregar Biblioteca → BibliotecaCubit.agregar()
       ├── onTap Agregar Resena → ResenasDataSource.crear()
       └── onTap Leer → Navegar a /reader/:id
```

### 5.5 Flujo de Lectura (Reader)

```
┌─────────────┐
│ ReaderPage  │
└──────┬──────┘
       │ initState → ReaderCubit.load(libroId)
       ▼
┌─────────────────────────────────────────┐
│ ReaderCubit                             │
│ 1. emit(Loading)                        │
│ 2. _epubRepository.getEpubContent(id)   │
│ 3. _bookmarkRepository.getMarcadores(id)
│ 4. emit(Loaded(content, marcadores))    │
└─────────────────────────────────────────┘
       │
       ├── Cambiar capítulo → EpunDataSource.getChapter()
       ├── Agregar highlight → HighlightCubit.agregar()
       └── Agregar bookmark → BookmarkCubit.toggle()
```

### 5.6 Flujo de Notificaciones en Tiempo Real

```
┌─────────────────────────────────────────┐
│ SignalRService                          │
│ 1. connect() → Conecta al hub           │
│ 2. on('ReceiveNotification') → Muestra   │
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ NotificationOverlayManager              │
│ Muestra popup cuando llega notificación  │
└─────────────────────────────────────────┘
```

---

## 6. Puntos Críticos y Áreas Delicadas

### 6.1 Gestión de Tokens y Sesión

**Ubicación**: `shared/core/session/`, `shared/core/network/auth_interceptor.dart`

**Consideraciones**:
- El token JWT se almacena en `FlutterSecureStorage` (cifrado)
- El `AuthInterceptor` adjunta el token automáticamente a todas las requests
- Si el servidor retorna 401, el interceptor elimina el token
- `SessionCubit` es el estado global de la sesión

**⚠️ Punto Crítico**: Nunca modificar el token manualmente. Usar siempre `SessionCubit.login()` y `SessionCubit.logout()`.

### 6.2 Parsing de EPUB

**Ubicación**: `features/reader/ui/widgets/epub_parser.dart`

**Consideraciones**:
- Los archivos EPUB son ZIP con HTML, CSS, XML
- El parser debe extraer el manifest y spine del OPF
- Los capítulos se cargan bajo demanda
- Se implementa cache de capítulos en memoria

**⚠️ Punto Crítico**: Manejo de caracteres especiales y codificaciones (UTF-8, ISO-8859-1).

### 6.3 SignalR para Notificaciones

**Ubicación**: `shared/services/signalr_service.dart`

**Consideraciones**:
- Conexión persistente al hub de notificaciones
- Reconexión automática en caso de caída
- El servicio es un singleton global

**⚠️ Punto Crítico**: La conexión puede perderse en background. Implementar reconexión al volver a foreground.

### 6.4 Sistema de Roles

**Ubicación**: `features/auth/`

**Consideraciones**:
- Los roles se cargan del API (RolesDataSource)
- Se cachean localmente
- El rol determina acceso a rutas admin

**⚠️ Punto Crítico**: Verificar rol en backend para operaciones sensibles (no confiar solo en frontend).

### 6.5 Descarga de EPUB

**Ubicación**: `shared/core/network/api_client.dart` (método `download`)

**Consideraciones**:
- Usa una instancia separada de Dio sin interceptores de logging
- Timeout extendido (5 minutos) para archivos grandes
- Progress callback para UI de descarga

**⚠️ Punto Crítico**: Cancelar descargas pendientes si el usuario sale de la página.

---

## 7. Workflow Git

### 7.1 Ramas

```
main                    ← Rama principal (producción)
├── documentacion       ← Documentación
├── fase-2-autenticacion
├── fase-3-catalogo-libros
├── fase-4-biblioteca-perfil
├── fase-5-reader
├── fase-6
└── fase-7
```

### 7.2 Nomenclatura de Ramas

Formato: `<tipo>/<descripcion-corta>`

Tipos:
- `feature/` → Nueva funcionalidad
- `fix/` → Corrección de bug
- `refactor/` → Refactorización
- `docs/` → Documentación
- `chore/` → Mantenimiento

Ejemplos:
```
feature/reader-highlights
fix/bookmark-not-saving
refactor/auth-logic
docs/update-api-docs
```

### 7.3 Proceso de Contribución

1. **Crear rama desde `main`**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/nueva-funcionalidad
   ```

2. **Desarrollar y hacer commits**:
   ```bash
   git add .
   git commit -m "feat(reader): agregar sistema de highlights"
   ```

3. **Mantener `main` actualizada** (rebase):
   ```bash
   git fetch origin
   git rebase origin/main
   ```

4. **Push y crear PR**:
   ```bash
   git push -u origin feature/nueva-funcionalidad
   ```

### 7.4 Conventional Commits

| Tipo | Descripción |
|------|-------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Solo documentación |
| `style` | Formato, indentación |
| `refactor` | Refactorización |
| `test` | Tests |
| `chore` | Dependencias, build |

---

## 8. Testing

### 8.1 Estrategia de Testing

**Pirámide de Testing**:
```
        ┌─────────┐
        │   E2E   │  ← Pocos, críticos
        ├─────────┤
        │Integración│ ← Algunos, flujos completos
├─────────────────┤
│    Unitarios    │ ← Muchos, lógica de negocio
└─────────────────┘
```

### 8.2 Unit Testing (Cubits y Repositories)

```dart
// test/features/auth/auth_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    authCubit = AuthCubit(authRepository: mockAuthRepo);
  });

  blocTest<AuthCubit, AuthState>(
    'emits [Loading, LoginSuccess] when login succeeds',
    build: () {
      when(() => mockAuthRepo.login(any(), any()))
          .thenAnswer((_) async => LoginResponse(...));
      return authCubit;
    },
    act: (cubit) => cubit.login('test@test.com', 'password'),
    expect: () => [isA<AuthLoading>(), isA<AuthLoginSuccess>()],
  );
}
```

### 8.3 Testing de Repositories

```dart
// test/features/auth/auth_repository_test.dart

test('AuthRepository.login returns Usuario on success', () async {
  // Arrange
  final mockDataSource = MockAuthDataSource();
  when(() => mockDataSource.login(any()))
      .thenAnswer((_) async => {...});
  
  final repository = AuthRepository(mockDataSource);
  
  // Act
  final result = await repository.login('test@test.com', 'pass');
  
  // Assert
  expect(result.usuario.email, 'test@test.com');
});
```

### 8.4 Widget Testing

```dart
testWidgets('LoginPage shows error on failed login', (tester) async {
  when(() => mockAuthCubit.state).thenReturn(AuthError('Credenciales inválidas'));
  
  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: mockAuthCubit,
      child: const MaterialApp(home: LoginPage()),
    ),
  );
  
  expect(find.text('Credenciales inválidas'), findsOneWidget);
});
```

### 8.5 Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests específicos
flutter test test/features/auth/

# Con coverage
flutter test --coverage
```

---

## 9. Configuración y Entorno

### 9.1 Variables de Entorno

El archivo `.env` en la raíz del proyecto:

```env
# API Configuration
API_BASE_URL=http://10.0.2.2:5201
API_TIMEOUT=30000

# SignalR
SIGNALR_URL=http://10.0.2.2:5201/Hub/NotificacionesHub
```

### 9.2 Acceso a Variables

```dart
// shared/core/environment/env.dart

class Env {
  static final Env _instance = Env._internal();
  factory Env() => _instance;
  Env._internal();

  late String apiBaseUrl;
  late int apiTimeout;
  late String signalrUrl;

  Future<void> init() async {
    await dotenv.load(fileName: '.env');
    
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201';
    apiTimeout = int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
    signalrUrl = dotenv.env['SIGNALR_URL'] 
        ?? 'http://10.0.2.2:5201/Hub/NotificacionesHub';
  }
}
```

### 9.3 Configuración de ApiClient

```dart
// shared/core/network/api_client.dart

ApiClient() {
  _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201',
      connectTimeout: Duration(milliseconds: 
          int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000),
      receiveTimeout: Duration(milliseconds: 
          int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}
```

### 9.4 URLs por Entorno

| Entorno | URL Base | Uso |
|---------|----------|-----|
| Desarrollo Android (Emulador) | `http://10.0.2.2:5201` | Emulador Android Studio |
| Desarrollo Android (Físico) | `http://<IP_LOCAL>:5201` | Dispositivo real en misma red |
| Desarrollo iOS (Simulator) | `http://localhost:5201` | iOS Simulator |
| Producción | `https://api.openbooks.com` | Servidor producción |

### 9.5 AndroidManifest (Permisos de Red)

Para desarrollo local, agregar en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

Para debug en dispositivo físico, agregar `android:usesCleartextTraffic="true"`:

```xml
<application
    android:label="OpenBooksMobile"
    android:usesCleartextTraffic="true"
    ...>
```

---

## 10. Manejo de Errores y Logging

### 10.1 Jerarquía de Excepciones

```
exceptions.dart
├── ServerException      # Errores del servidor (500, etc.)
├── NetworkException     # Sin conexión, timeout
├── AuthException        # 401, credenciales inválidas
├── CacheException       # Errores de almacenamiento local
└── ValidationException # 400, datos inválidos
```

### 10.2 Jerarquía de Failures

```
failures.dart
├── ServerFailure        # Fallo en servidor
├── NetworkFailure       # Fallo de red
├── AuthFailure          # Fallo de autenticación
├── CacheFailure         # Fallo de cache
└── ValidationFailure    # Fallo de validación (con mapa de errores)
```

### 10.3 Conversión Exception → Failure

Los repositories convierten exceptions en failures:

```dart
class AuthRepository {
  final AuthDataSource _dataSource;
  
  Future<Either<Failure, LoginResponse>> login(
      String email, String password) async {
    try {
      final result = await _dataSource.login(email, password);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }
}
```

### 10.4 Manejo en Cubits

```dart
class AuthCubit extends Cubit<AuthState> {
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    final result = await _authRepository.login(email, password);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) => emit(AuthLoginSuccess(success.usuario)),
    );
  }
}
```

### 10.5 Logging

El `LogInterceptor` de Dio registra automáticamente:

- Request: método, URL, headers, body
- Response: status, body
- Errores: mensaje, stack trace

```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,   // Incluir body del request
  responseBody: true,   // Incluir body del response
  error: true,         // Incluir errores
  logPrint: (obj) => debugPrint(obj.toString()), // Usar print de Flutter
));
```

### 10.6 Errores No Manejados

Para errores no capturados, Flutter usa `FlutterError`:

```dart
// En main.dart
void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log a servicio de crash reporting (Firebase, Sentry, etc.)
    FirebaseCrashlytics.instance.recordError(
      details.exception,
      details.stack,
    );
  };
  
  runApp(const MyApp());
}
```

### 10.7尝Errores de API Comunes

| Código | Significado | Acción |
|--------|-------------|--------|
| 400 | Bad Request | Mostrar errores de validación al usuario |
| 401 | Unauthorized | Limpiar sesión, redirigir a login |
| 403 | Forbidden | Mostrar "No tienes permiso" |
| 404 | Not Found | Mostrar "Recurso no encontrado" |
| 500 | Server Error | Mostrar "Error del servidor, intenta más tarde" |
| 0 | No Connection | Mostrar "Sin conexión a internet" |

---

## 11. Mejoras Futuras

### 11.1 Prioridad Alta

- [ ] **Sistema de Offline**: Cache de libros y biblioteca para uso sin conexión
- [ ] **Sync de Progreso**: Sincronizar posición de lectura entre dispositivos
- [ ] **Tests E2E**: Implementar integration testing con `flutter_test` y ` Patrol`
- [ ] **Dark Mode Completo**: Mejorar soporte para tema oscuro en reader

### 11.2 Prioridad Media

- [ ] **Búsqueda Offline**: Indexar libros descargados para búsqueda local
- [ ] **Notificaciones Push**: Migrar de SignalR a Firebase Cloud Messaging
- [ ] **Analytics**: Integrar Firebase Analytics o similar
- [ ] **Crash Reporting**: Integrar Firebase Crashlytics

### 11.3 Prioridad Baja

- [ ] **Web Support**: Habilitar y optimizar para web (ya hay build)
- [ ] **Escritorio**: Soporte para Windows/macOS/Linux
- [ ] **Importar EPUB**: Permitir importar libros EPUB externos
- [ ] **Comunidad**: Sistema de usuarios verificados, premios

### 11.4 Deuda Técnica

- [ ] **Migrar a Riverpod**: Considerar migrar de Cubit a Riverpod para mejor escalabilidad
- [ ] **API Versioning**: Implementar versionado de API en el cliente
- [ ] **Retry Logic**: Implementar retry automático con exponential backoff
- [ ] **State Management Global**: Considerar Zustand o Redux para estado global

### 11.5 Performance

- [ ] **Lazy Loading**: Mejorar carga de imágenes en listas grandes
- [ ] **Code Splitting**: Dividir bundles por feature
- [ ] **Tree Shaking**: Optimizar imports para reducir bundle size
- [ ] **Image Caching**: Implementar cache de portadas con `cached_network_image`

---

## Anexo: Glosario

| Término | Definición |
|---------|------------|
| Cubit | Implementación simplificada de BLoC, usa emit() directo |
| Feature | Módulo funcional de la aplicación |
| DI | Inyección de Dependencias |
| Repository | Abstracción que oculta el datasource |
| Datasource | Fuente de datos (API, BD local, etc.) |
| State | Estado inmutable que representa la UI |
| Failure | Representación de un error en el dominio |
| Exception | Error a nivel de infraestructura |
| SignalR | Biblioteca para comunicación en tiempo real |
| EPUB | Formato estándar de libros electrónicos |

---

*Última actualización: 2026-03-22*
