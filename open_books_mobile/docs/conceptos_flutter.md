# Conceptos de Flutter usados en Open Books Mobile

---

## Conceptos Básicos (Aplican a Flutter y al Desarrollo Móvil en General)

### WidgetsIngección (Widget Tree / Element Tree / Render Tree)

Flutter construye la UI con **tres árboles internos** que operan juntos:

1. **Widget Tree** (configuración): lo que escribes en código. Los widgets son livianos, se crean y destruyen constantemente.
2. **Element Tree** (instancia): puente entre widget y render object. Mantiene el estado de los `StatefulWidget`.
3. **Render Tree** (pintado): se encarga del layout, pintado y hit testing.

Cuando cambias un widget, Flutter lo reconstruye, pero el `Element` y `RenderObject` subyacentes **se reutilizan** si la key y el tipo coinciden. Por eso Flutter es rápido: no destruye toda la UI en cada rebuild.

**Diferencia clave**: `StatelessWidget` vs `StatefulWidget`. El primero no tiene estado mutable. El segundo separa el widget (config) de su estado (State) para persistir datos a través de rebuilds.

### Keys en Flutter

Las `Key` ayudan a Flutter a identificar widgets cuando el árbol cambia. Se usan para:

- **Preservar estado** en widgets que se mueven dentro de una lista (`ValueKey`, `ObjectKey`, `UniqueKey`).
- **Forzar recreación** de un widget cuando se necesita reiniciar su estado.

```dart
ListView.builder(
  itemBuilder: (_, i) => TextItem(key: ValueKey(item.id), item: item),
)
```

Sin key, Flutter usa la posición en el árbol. Con key, usa la key para identificar el elemento, permitiendo animaciones, reordenamiento y preservación de estado.

### Ciclo de Vida de una App Móvil

`WidgetsBindingObserver` permite escuchar cambios de estado de la app:

| Estado | Significado |
|---|---|
| `resumed` | App visible y acepta input (activa) |
| `inactive` | App visible pero no acepta input (ej: llamada entrante) |
| `paused` | App en background (iOS: estado suspendido) |
| `detached` | App separada del engine (raro, típicamente al cerrar) |

**Por qué importa**: En `paused` deberías guardar estado crítico. En `resumed` reconectar websockets, refrescar datos, reanudar reproducción. Ignorar el ciclo de vida causa bugs como conexiones muertas o datos no guardados.

### Context en Flutter

`BuildContext` es la **ubicación de un widget en el árbol de elementos**. Es el mecanismo para:

- Acceder al tema: `Theme.of(context)`
- Navegar: `Navigator.of(context)` o `context.go()`
- Leer providers: `context.read<Cubit>()`, `context.watch<Cubit>()`
- Acceder a MediaQuery: `MediaQuery.of(context)`

**Regla**: `context` solo es válido mientras el widget está montado. Usarlo después del dispose causa errores. Por eso los BlocListeners reciben un context seguro.

### Diferencia entre Hot Reload y Hot Restart

| Hot Reload | Hot Restart |
|---|---|
| Mantiene el estado de la app | Reinicia la app desde cero |
| Recompila widgets modificados | Recompila todo |
| No ejecuta `main()` de nuevo | Ejecuta `main()` de nuevo |
| Rápido (~1s) | Lento (~5-10s) |
| Ideal para UI | Ideal para cambios en `main()`, `initState()`, `didChangeDependencies()` |

Si cambias el registro de dependencias (get_it), rutas, o `main()`, necesitas **hot restart**. Para cambios de UI, hot reload basta.

### async / await y el Event Loop de Dart

Dart es **single-threaded** con un event loop (como JavaScript). El `async`/`await` no crea threads; programa tareas en la cola de eventos:

```dart
Future<void> fetchData() async {
  print('1');                   // Síncrono, ejecuta ahora
  final data = await api.get(); // Pausa, cede el hilo, continúa cuando la respuesta llegue
  print('2');                   // Se ejecuta después
}
```

Mientras una función está "awaitando", el hilo principal procesa otros eventos (taps, animaciones, rebuilds). **Esto es clave para mantener la UI fluida** — si bloqueas el hilo con un bucle síncrono (ej: `for` pesado), la UI se congela.

### Const vs Final vs Var

| Keyword | Se asigna en | Se reasigna después |
|---|---|---|
| `const` | Compilación | No (valor fijo en tiempo de compilación) |
| `final` | Runtime (1 vez) | No |
| `var` | Runtime | Sí |

**Optimización**: Usar `const` widgets (ej: `const Text('hola')`) permite a Flutter reutilizar la misma instancia, reduciendo el trabajo del GC y acelerando rebuilds.

### Modelos y JSON

Toda app que consume APIs necesita convertir JSON ↔ objetos Dart. En el proyecto se usa `json_annotation` + `json_serializable`:

```dart
// libro.dart
@JsonSerializable()
class Libro {
  final int id;
  final String titulo;

  Libro({required this.id, required this.titulo});

  factory Libro.fromJson(Map<String, dynamic> json) => _$LibroFromJson(json);
  Map<String, dynamic> toJson() => _$LibroToJson(this);
}
```

Se genera el código con `flutter pub run build_runner build`. Beneficio: evita escribir manualmente el mapeo campo por campo.

### Inmutabilidad

En Flutter/Dart moderno los objetos de estado deben ser **inmutables**. No modificas propiedades; creas una nueva instancia con los cambios:

```dart
// Bien
final newState = state.copyWith(fontSize: 16.0);
emit(newState);

// Mal
state.fontSize = 16.0;
emit(state); // ❌ Misma instancia, BlocBuilder no detecta cambio
```

La inmutabilidad evita bugs donde el estado se modifica sin que la UI lo sepa.

---

## 1. Widgets y Árbol de Widgets

En Flutter **todo es un widget**. La UI se construye anidando widgets en un árbol jerárquico. Hay dos tipos:

- **StatelessWidget**: Widget inmutable, no cambia después de construirse. Ej: `LoginPage`, `ProfilePage`.
- **StatefulWidget**: Widget con estado mutable que puede cambiar en el tiempo. Ej: `OpenBooksApp` (escucha ciclo de vida).

Cada widget tiene un método `build()` que retorna el subtree. Flutter repinta widgets de forma eficiente comparando el árbol anterior con el nuevo.

**En el proyecto**: `MaterialApp.router` es el widget raíz, dentro hay `MultiBlocProvider` (hereda de `StatelessWidget`), `BlocBuilder`, `Scaffold`, `NavigationBar`, etc.

---

## 2. Manejo de Estado con Bloc / Cubit

### ¿Qué es un Cubit?

Un Cubit es una clase que extiende `Cubit<T>` y **expone métodos** que emiten nuevos estados. Es la variante más simple de Bloc (sin eventos).

```
Usuario llama método → Cubit ejecuta lógica → Cubit emite nuevo estado → UI se rebuild
```

### Anatomy de un Cubit

```dart
// auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : super(AuthInitial()); // Estado inicial

  Future<void> login(String email, String password) async {
    emit(AuthLoading()); // 1. Emite loading
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthLoginSuccess(user)); // 2. Emite éxito
    } catch (e) {
      emit(AuthError(e.toString())); // 3. Emite error
    }
  }
}
```

### Anatomy de un State

```dart
// auth_state.dart
abstract class AuthState extends Equatable { // Equatable permite comparar estados por valor
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthLoginSuccess extends AuthState {
  final Usuario usuario;
  const AuthLoginSuccess(this.usuario);
  @override
  List<Object?> get props => [usuario]; // Props = propiedades que definen igualdad
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
```

**Patrón de estados en el proyecto**: Siempre `Initial → Loading → Success | Error`. Esto es predecible y fácil de testear.

### ¿Por qué Equatable?

`Equatable` sobreescribe `==` y `hashCode` para que dos instancias con los mismos valores sean consideradas iguales. Esto evita rebuilds innecesarios en la UI porque BlocBuilder solo se repinta cuando el estado **cambia por valor**, no por referencia.

### Cómo se usa en la UI

```dart
// En página:
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return CircularProgressIndicator();
    if (state is AuthLoginSuccess) return Text('Bienvenido');
    if (state is AuthError) return Text('Error: ${state.message}');
    return LoginForm();
  },
);

// Para acciones (sin rebuild):
context.read<AuthCubit>().login(email, pass);

// Para side-effects (navegación, snackbars):
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthLoginSuccess) context.go('/home');
  },
  child: ...
);
```

### Cubits del proyecto

| Cubit | Scope | Propósito |
|---|---|---|
| `SessionCubit` | **Global** (singleton) | Sesión del usuario, token JWT, SignalR |
| `NotificationCubit` | **Global** | Notificaciones en tiempo real |
| `ReaderSettingsCubit` | **Global** | Tema (claro/oscuro/sepia), tamaño letra |
| `OnboardingCubit` | **Global** | Estado del onboarding |
| `AuthCubit` | **Scoped** (por ruta) | Login, registro, recuperación |
| `LibrosCubit` | **Scoped** | Listado de libros |
| `BibliotecaCubit` | **Scoped** | Biblioteca personal del usuario |
| `HistorialCubit` | **Scoped** | Historial de lectura |
| `ReaderCubit` | **Scoped** | Renderizado de EPUB |
| `PerfilCubit` | **Scoped** | Perfil de usuario |

### Regla de oro del proyecto

- Cubits **globales**: solo 4 (Session, Notification, ReaderSettings, Onboarding)
- Cubits **scoped**: se crean nuevos cada vez que entras a una ruta (router)
- **NUNCA** uses `getIt<Cubit>()` en UI. Siempre `context.read<Cubit>()`
- Los cubits scoped se cierran automáticamente al salir de la ruta

---

## 3. Inyección de Dependencias con get_it

### ¿Qué es?

`get_it` es un **Service Locator** (no un DI Container tradicional). Permite registrar dependencias en un contenedor global y resolverlas desde cualquier parte del código.

### Registros

```dart
final getIt = GetIt.instance;

// Singleton (una instancia para toda la app)
getIt.registerLazySingleton<ApiClient>(() => ApiClient());

// Factory (nueva instancia cada vez que se pide)
getIt.registerFactory<AuthCubit>(() => AuthCubit(...));

// Factory con parámetros
getIt.registerFactoryParam<ReaderCubit, int, void>(
  (libroId, _) => ReaderCubit(repository, libroId),
);
```

### ¿Por qué no solo singletons?

Los cubits **scoped** se registran como `registerFactory` para que cada ruta obtenga una instancia fresca. Si fueran singleton, compartirían estado entre rutas y no se reiniciarían al navegar.

### Arquitectura de DI en el proyecto

```
injection_container.dart → Registra TODO en getIt (391 líneas)
    ↓
app_initializer.dart → Llama setupDependencies(), crea AppInjector
    ↓
app_injector.dart → Clase con los 5 singletons globales:
    - SyncService, SessionCubit, NotificationCubit, ReaderSettingsCubit, OnboardingCubit
    ↓
app.dart → Toma los 5 del injector, los provee con BlocProvider.value()
```

### ¿Qué significa scoped vs global?

- **Global**: existe durante toda la vida de la app. Ej: `SessionCubit` debe saber siempre si hay sesión.
- **Scoped**: existe solo mientras estás en una pantalla. Ej: `AuthCubit` solo se necesita en login/registro. Al salir, se destruye.

---

## 4. Navegación con go_router

### ¿Qué es go_router?

Es un paquete de routing declarativo basado en URL. Similar a React Router o Vue Router.

### Configuración básica

```dart
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) { /* lógica de redirección */ },
  routes: [
    GoRoute(path: '/', redirect: ...),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/book/:id', builder: (context, state) {
      final id = state.pathParameters['id']!; // Parámetro de ruta
      return BookDetailPage(libroId: int.parse(id));
    }),
    ShellRoute( /* wraps child con un layout */ ),
  ],
);
```

### ShellRoute

`ShellRoute` permite envolver rutas hijas con un layout común. En el proyecto hay dos:

1. **MainShell**: Aplica a `/home`, `/library`, `/history`. Renderiza `SearchHeader` arriba y `NavigationBar` abajo (bottom tabs).
2. **Admin shell**: Aplica a todas las rutas `/admin/*`. Renderiza el layout de admin con sidebar.

### Redirect global

El `redirect` del router se ejecuta en cada navegación. Lógica del proyecto:

1. ¿No ha visto onboarding y no está logueado? → `/onboarding`
2. ¿No logueado? → `/login`
3. ¿Logueado pero en ruta de auth? → `/home` o `/admin`
4. ¿Ruta admin pero no es admin? → `/home`
5. ¿Admin en ruta normal (no exenta)? → `/admin`

### Navegación programática

```dart
context.go('/home');          // Reemplaza el stack
context.push('/book/123');    // Apila una ruta
context.pushReplacement('/home');  // Reemplaza la actual
```

### refreshListenable

```dart
refreshListenable: RouterRefreshNotifier(sessionCubit),
```

Un `ChangeNotifier` que reconstruye el router cada vez que `SessionCubit` emite un nuevo estado. Así el `redirect` se re-evalúa automáticamente cuando el usuario inicia/cierra sesión.

---

## 5. BlocProvider y MultiBlocProvider

Son widgets que ponen un Cubit/Bloc a disposición de todo el subtree.

### BlocProvider.value()

```dart
BlocProvider.value(value: existingCubit, child: Child())
```

Usa una instancia **existente** (normalmente un singleton global). El cubit NO se cierra al salir.

### BlocProvider(create:)

```dart
BlocProvider(create: (_) => getIt<AuthCubit>(), child: Child())
```

Crea una **nueva instancia** cuando el widget se monta y la **cierra** cuando se desmonta. Esto es lo que hace que los cubits scoped tengan ciclo de vida ligado a la ruta.

### Árbol de providers en la app

```
MultiBlocProvider (raíz en app.dart)
├── SessionCubit (value)
├── NotificationCubit (value)
├── ReaderSettingsCubit (value)
│
└── [Ruta actual]
    ├── AuthCubit (create - se destruye al salir)
    ├── LibrosCubit (create)
    └── ...
```

---

## 6. MaterialApp.router

```dart
MaterialApp.router(
  routerConfig: _appRouter.router,
  theme: ThemeFactory.build(settings.appTheme, Brightness.light),
  darkTheme: ThemeFactory.build(settings.appTheme, Brightness.dark),
  themeMode: ThemeFactory.getMode(settings.appTheme),
)
```

En lugar de `MaterialApp(routes: {...})`, se usa `.router` que delega toda la navegación a go_router. Esto permite:
- Redirecciones globales
- Parámetros de ruta
- Navegación declarativa
- Control total del stack de navegación

---

## 7. Equatable

Paquete que evita tener que escribir manualmente `==` y `hashCode`. Cada estado de cubit extiende `Equatable` y declara `props`:

```dart
class AuthLoginSuccess extends AuthState {
  final Usuario usuario;
  final String token;

  @override
  List<Object?> get props => [usuario, token]; // Define igualdad por valor
}
```

Sin Equatable, dos instancias con los mismos datos serían consideradas diferentes (`identical()` por referencia), causando rebuilds innecesarios.

---

## 8. Dio (HTTP Client)

`Dio` es el cliente HTTP usado en lugar del `http` package nativo porque ofrece:

- **Interceptors**: `AuthInterceptor` añade el token JWT automáticamente a cada request.
- **Logging**: `LogInterceptor` muestra requests/responses en consola para debugging.
- **Timeouts configurables**: via `.env`.
- **Cancelación**: con `CancelToken` (usado en descargas).
- **Descarga de archivos**: método `download()` con progreso.

```dart
// api_client.dart - wrapper alrededor de Dio
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201',
      connectTimeout: Duration(milliseconds: 30000),
      headers: { 'Content-Type': 'application/json' },
    ));
    _dio.interceptors.addAll([AuthInterceptor(), LogInterceptor()]);
  }
}
```

---

## 9. Arquitectura de Carpetas (Clean Architecture Lite)

Cada feature sigue una estructura de 3 capas:

```
feature/
├── data/               # Capa de datos
│   ├── datasources/    # Llamadas API o BD local
│   ├── models/         # Modelos con fromJson/toJson
│   └── repositories/   # Implementación de repositorios
├── logic/              # Capa de lógica/estado
│   └── cubit/          # Cubits + States
└── ui/                 # Capa de presentación
    ├── pages/          # Pantallas completas
    └── widgets/        # Widgets reutilizables
```

### DataSources
Son los que realmente hacen peticiones HTTP o consultas SQLite. Cada datasource recibe `ApiClient` o `LocalDatabase`.

### Repositories
Coordinan entre datasources remotos y locales. Algunos implementan offline-first con `NetworkInfo`:

```dart
class BibliotecaRepositoryImpl implements BibliotecaRepository {
  Future<Either<Failure, List<Libro>>> getBiblioteca() async {
    if (await networkInfo.isConnected) {
      return _getFromRemote();
    } else {
      return _getFromLocal();
    }
  }
}
```

### Models
Clases con `fromJson` / `toJson`. Usan `json_annotation` + `json_serializable` para generación automática.

---

## 10. Either y dartz (Programación Funcional)

```dart
typedef Result<T> = Either<Failure, T>;
```

`Either` representa un valor que puede ser de dos tipos: `Left` (error) o `Right` (éxito). Se usa en repositorios para manejar errores sin excepciones:

```dart
final result = await repository.getLibros();
result.fold(
  (failure) => emit(ErrorState(failure.message)),
  (libros) => emit(LoadedState(libros)),
);
```

### Jerarquía de Failures

```dart
abstract class Failure { final String message; }
class ServerFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
```

---

## 11. SignalR (Tiempo Real)

`signalr_netcore` se usa para recibir notificaciones en tiempo real. La conexión se establece al hacer login y se cierra al hacer logout.

```dart
// session_cubit.dart
void _connectSignalR() {
  _signalRService = SignalRService(
    onNotificationReceived: _handleNotification,
    onConnected: () {},
    onError: (error) {},
  );
  _signalRService!.connect();
}
```

Se reconecta automáticamente cuando la app vuelve a foreground (`didChangeAppLifecycleState`).

---

## 12. Almacenamiento Local

- **flutter_secure_storage**: Token JWT y datos del usuario (cifrado).
- **shared_preferences**: Settings del lector (tema, tamaño fuente).
- **sqflite**: Base de datos SQLite local para:
  - Biblioteca offline
  - Historial de lectura
  - Cola de sincronización (SyncService)
  - Notificaciones almacenadas
  - Contenido EPUB cacheados

---

## 13. SyncService (Sincronización Offline)

Servicio que mantiene una cola de operaciones pendientes en SQLite. Cuando hay conexión, intenta sincronizar con backoff exponencial:

```
Operación offline → cola_sync SQLite → al reconectar → ejecuta pendientes
Retry: delay * 2^intento (máx 3 intentos)
```

---

## 14. Tema Claro/Oscuro/Seppia

`ThemeFactory.build(theme, brightness)` genera un `ThemeData` según el tema seleccionado. El `ReaderSettingsCubit` expone `appTheme` que puede ser `'light'`, `'dark'` o `'sepia'`.

```dart
// app.dart
BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
  builder: (context, settings) {
    return MaterialApp.router(
      theme: ThemeFactory.build(settings.appTheme, Brightness.light),
      darkTheme: ThemeFactory.build(settings.appTheme, Brightness.dark),
      themeMode: ThemeFactory.getMode(settings.appTheme),
    );
  },
);
```

---

## 15. Ciclo de Vida de la App

`OpenBooksApp` implementa `WidgetsBindingObserver` para escuchar cambios en el ciclo de vida:

```dart
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    syncService.onAppResumed(); // Reconectar SignalR, sincronizar
  }
}
```

---

## 16. Widgets Clave del Proyecto

| Widget | Propósito |
|---|---|
| `NotificationOverlayManager` | Envuelve toda la app, muestra toasts de notificaciones |
| `SearchHeader` | Header con buscador integrado en el shell principal |
| `NavigationBar` | Bottom navigation (Material 3) con Inicio/Biblioteca/Historial |
| `MainShell` | Layout del shell principal (header + contenido + bottom nav) |
| `AdminPage` | Layout del panel admin |

---

## Resumen del Flujo de Inicialización

```
main()
  ↓
WidgetsFlutterBinding.ensureInitialized()
  ↓
AppInitializer.init()
  ├── dotenv.load()                 ← Carga .env
  ├── setupDependencies()           ← Registra todo en getIt
  └── AppInjector(...)              ← Extrae los 5 singletons
  ↓
runApp(OpenBooksApp(injector))
  ├── MultiBlocProvider (3 globales + providers)
  ├── BlocBuilder<ReaderSettingsCubit>
  └── MaterialApp.router
       └── GoRouter (redirects + rutas scoped)
```

## Reglas de Oro del Proyecto

1. **Solo 5 dependencias globales**: SessionCubit, NotificationCubit, ReaderSettingsCubit, OnboardingCubit, SyncService. Todo lo demás es scoped.
2. **No usar getIt en UI**: Siempre `context.read<Cubit>()` a través de BlocProvider.
3. **No cerrar cubits manualmente**: BlocProvider(create:) lo hace automáticamente. Excepto si usas `BlocProvider.value()` con singletons.
4. **Siempre Equatable en estados**: Para comparación por valor y evitar rebuilds innecesarios.
5. **Estados predecibles**: Initial → Loading → Success | Error.
6. **Either<Failure, T> en repositorios**: Nunca lanzar excepciones desde repositorios, siempre retornar Failure.
