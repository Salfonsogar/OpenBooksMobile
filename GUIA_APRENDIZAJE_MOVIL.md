# Guía de Aprendizaje - Desarrollo Móvil con Flutter

Guía práctica para aprender desarrollo móvil usando Flutter, basada en el proyecto **Open Books Mobile**. Esta guía te llevará desde los fundamentos hasta conceptos avanzados.

---

## Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Fundamentos de Flutter](#2-fundamentos-de-flutter)
3. [Arquitectura del Proyecto](#3-arquitectura-del-proyecto)
4. [Manejo de Estado (BLoC / Cubit)](#4-manejo-de-estado-bloc--cubit)
5. [Navegación](#5-navegación)
6. [Consumo de APIs](#6-consumo-de-apis)
7. [Inyección de Dependencias](#7-inyección-de-dependencias)
8. [Manejo de Datos](#8-manejo-de-datos)
9. [Persistencia Local](#9-persistencia-local)
10. [Flujo Real del Proyecto](#10-flujo-real-del-proyecto)
11. [Buenas Prácticas](#11-buenas-prácticas)
12. [Errores Comunes](#12-errores-comunes)
13. [Mapa Mental del Proyecto](#13-mapa-mental-del-proyecto)
14. [Siguientes Pasos](#14-siguientes-pasos)

---

## 1. Introducción

### 1.1 Qué Voy a Aprender

Esta guía te enseñará desarrollo móvil con Flutter, cubriendo:

- **Fundamentos de Flutter**: Widgets, estado, ciclos de vida
- **Arquitectura de proyectos**: Cómo estructurar una app escalable
- **Estado global**: BLoC/Cubit para gestión de estado
- **Comunicación con backend**: HTTP con Dio
- **Navegación**: go_router para rutas declarativas
- **Persistencia**: Almacenamiento seguro local
- **Patrones de diseño**: Repository, Datasource, Inyección de dependencias

### 1.2 Cómo Usar Esta Guía

1. **Lee en orden**: Las secciones se construyen sobre las anteriores
2. **Código real**: Cada concepto se explica con ejemplos del proyecto
3. **Comparaciones con React**: Si vienes de web, facilita el aprendizaje
4. **Experimenta**: Modifica el código y ve qué pasa

### 1.3 Relación Entre Desarrollo Móvil y Web

| Concepto          | Desarrollo Web (React) | Desarrollo Móvil (Flutter) |
|-------------------|------------------------|----------------------------|
| Unidad base       | Componente             | Widget                     |
| Estado local      | useState               | StatefulWidget o Cubit     |
| Estado global     | Redux / Context        | Cubit / BLoC               |
| Routing           | React Router           | go_router                  |
| HTTP Client       | fetch / axios          | Dio                        |
| Inyección de deps | Context / Providers    | get_it                     |

**Diferencia fundamental**: En Flutter, todo es un widget. La UI ES el código. No hay HTML/CSS separado.

---

## 2. Fundamentos de Flutter

### 2.1 ¿Qué es Flutter?

Flutter es un framework de Google para crear apps nativas para iOS, Android, web y desktop desde un **único código base**.

```
┌─────────────────────────────────────┐
│              Flutter                │
├─────────────────────────────────────┤
│  Dart (lenguaje)                   │
│  └─► Compila a código nativo       │
│                                     │
│  Widgets (UI)                      │
│  └─► Todo es un widget             │
│                                     │
│  Skia (renderizado)                 │
│  └─► Dibuja píxeles directamente   │
└─────────────────────────────────────┘
```

**Analogía con React**: Si React renderiza DOM virtual, Flutter renderiza widgets nativos directamente. No hay puente JavaScript (salvo en web).

### 2.2 Widgets (Comparación con Componentes en React)

En Flutter, **todo es un widget**. Un widget puede ser:

- Un botón
- Un texto
- Una página completa
- Un layout
- Una animación

**En React:**

```jsx
function Boton({ onClick, children }) {
  return (
    <button onClick={onClick} className="btn">
      {children}
    </button>
  );
}
```

**En Flutter:**

```dart
class Boton extends StatelessWidget {
  final VoidCallback onClick;
  final Widget child;

  const Boton({
    super.key,
    required this.onClick,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick,
      child: child,
    );
  }
}
```

**Del proyecto - ReaderPage** (`reader_page.dart:1-28`):

```dart
class ReaderPage extends StatefulWidget {
  final int libroId;  // Props como en React

  const ReaderPage({super.key, required this.libroId});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}
```

### 2.3 Stateless vs Stateful (Comparación con Componentes)

#### StatelessWidget - Sin Estado Interno

**En React (componente funcional sin estado):**

```jsx
function Titulo({ texto }) {
  return <h1>{texto}</h1>;
}
```

**En Flutter:**

```dart
class Titulo extends StatelessWidget {
  final String texto;

  const Titulo({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(texto);
  }
}
```

**Cuándo usarlo**: Cuando el widget solo recibe datos y los muestra.

#### StatefulWidget - Con Estado Interno

**En React (con useState):**

```jsx
function Contador() {
  const [count, setCount] = useState(0);
  
  return (
    <button onClick={() => setCount(c => c + 1)}>
      Clicks: {count}
    </button>
  );
}
```

**En Flutter:**

```dart
class Contador extends StatefulWidget {
  const Contador({super.key});

  @override
  State<Contador> createState() => _ContadorState();
}

class _ContadorState extends State<Contador> {
  int _count = 0;  // Estado interno

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _count++),
      child: Text('Clicks: $_count'),
    );
  }
}
```

**Del proyecto - HomePage** (`home_page.dart:18-39`):

```dart
class _HomePageState extends State<HomePage> {
  // Estado interno
  final _scrollController = ScrollController();
  List<Libro> _recomendados = [];
  List<Libro> _librosCategoria = [];
  Categoria? _categoriaRandom;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _cargarSecciones();  // Carga inicial de datos
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 2.4 Build Method (Comparación con Render en React)

**En React:**

```jsx
function App() {
  return <div>{/* JSX */}</div>;
}
// React llama a esta función cuando el estado cambia
```

**En Flutter:**

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Mi App')),
      body: Center(child: Text('Contenido')),
    ),
  );
}
// Flutter llama a este método cuando el estado cambia
```

**Diferencia clave**: En Flutter, `build()` puede llamarse frecuentemente. Debe ser:

- **Puro**: No tiene efectos secundarios
- **Rápido**: Sin operaciones pesadas
- **Idempotente**: Mismo input = mismo output

**Del proyecto - ReaderPage** (`reader_page.dart:67-85`):

```dart
@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: true,
    child: MultiBlocProvider(  // Proveedor de estado
      providers: [
        BlocProvider.value(value: _readerCubit),
        BlocProvider.value(value: _settingsCubit),
        BlocProvider.value(value: _bookmarkCubit),
        BlocProvider.value(value: _highlightCubit),
      ],
      child: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
        builder: (context, settings) {
          return _buildScaffold(settings);  // Construye la UI
        },
      ),
    ),
  );
}
```

### 2.5 Árbol de Widgets (Comparación con Virtual DOM)

**En React:**

```
Virtual DOM
├── <App>
│   ├── <Header>
│   │   ├── <Logo />
│   │   └── <Navigation links />
│   ├── <MainContent>
│   │   ├── <BookList>
│   │   │   └── <BookCard /> x N
│   │   └── <Pagination />
│   └── <Footer />
```

**En Flutter:**

```
Widget Tree
├── MaterialApp
│   └── Scaffold
│       ├── AppBar
│       │   ├── Logo
│       │   └── Navigation Icons
│       ├── Body
│       │   ├── BlocBuilder<LibrosCubit>
│       │   │   └── _buildGridView / _buildSecciones
│       │   │       └── GridView
│       │   │           └── LibroCard x N
│       │   └── ScrollController
│       └── BottomNavigationBar
```

**Del proyecto - HomePage** (`home_page.dart:161-185`):

```dart
Widget _buildSecciones() {
  return RefreshIndicator(  // Wrapper para pull-to-refresh
    onRefresh: _cargarSecciones,
    child: SingleChildScrollView(  // Scroll vertical
      controller: _scrollController,
      child: Column(  // Contenedor vertical
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recomendados.isNotEmpty)
            _buildSeccion('eBooks recomendados', _recomendados),
          if (_categoriaRandom != null)
            _buildSeccion(_categoriaRandom!.nombre, _librosCategoria),
          if (_top5.isNotEmpty)
            _buildSeccion('Más valorados', _top5),
        ],
      ),
    ),
  );
}
```

---

## 3. Arquitectura del Proyecto

### 3.1 Arquitectura Basada en Features

El proyecto usa una **arquitectura por features** (características), no por capas tradicionales.

**Estructura tradicional (por capas):**

```
src/
├── components/
├── pages/
├── services/
├── store/
```

**Estructura del proyecto (por features):**

```
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── logic/
│   │   └── ui/
│   ├── libros/
│   │   ├── data/
│   │   ├── logic/
│   │   └── ui/
│   └── reader/
│       ├── data/
│       ├── logic/
│       └── ui/
├── shared/
│   └── core/
└── main.dart
```

**¿Por qué arquitectura por features?**

| Beneficio          | Descripción                                  |
|--------------------|----------------------------------------------|
| **Escalabilidad**  | Agregar features no afecta los existentes    |
| **Cohesión**       | Todo lo relacionado a una feature está junto |
| **Mantenibilidad** | Cambiar auth no toca código de libros        |
| **Testabilidad**   | Testeas cada feature de forma aislada        |

### 3.2 Estructura Completa de lib/

```
lib/
├── main.dart                          # Punto de entrada
├── injection_container.dart           # Configuración DI
├── routing/
│   └── app_router.dart               # Navegación
│
├── features/                          # Cada feature es independiente
│   ├── auth/
│   │   ├── data/                      # Datos (API, modelos)
│   │   │   ├── datasources/          # Comunicación con API
│   │   │   ├── models/               # Estructuras de datos
│   │   │   └── repositories/         # Abstracción de datasources
│   │   ├── logic/                    # Negocio (estado)
│   │   │   └── cubit/                # Estados y lógica
│   │   └── ui/                       # Presentación
│   │       └── pages/                # Pantallas completas
│   │
│   ├── libros/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── logic/
│   │   │   └── cubit/
│   │   └── ui/
│   │       ├── pages/
│   │       └── widgets/              # Componentes reutilizables
│   │
│   └── reader/
│       └── ... (misma estructura)
│
├── shared/                            # Código compartido
│   ├── core/
│   │   ├── constants/               # Constantes de la app
│   │   ├── environment/              # Variables de entorno
│   │   ├── errors/                   # Excepciones y fallos
│   │   ├── network/                  # Cliente HTTP
│   │   ├── session/                 # Estado de sesión global
│   │   └── theme/                   # Estilos
│   ├── services/                     # Servicios (SignalR)
│   └── ui/
│       └── widgets/                  # Widgets compartidos
```

### 3.3 Comparación con Estructura Típica en React

**React (Next.js / typical):**

```
src/
├── app/                    # Páginas
│   ├── page.tsx           # Home
│   ├── books/
│   │   └── page.tsx       # Lista de libros
│   └── book/
│       └── [id]/page.tsx  # Detalle libro
├── components/             # Componentes reutilizables
│   ├── BookCard.tsx
│   └── Header.tsx
├── services/              # API calls
│   └── api.ts
├── store/                 # Estado global (Redux)
│   ├── authSlice.ts
│   └── booksSlice.ts
├── hooks/                 # Custom hooks
└── types/                 # TypeScript types
```

**Flutter (proyecto):**

```
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/auth_datasource.dart  # ≈ services/api.ts
│   │   │   ├── models/usuario.dart              # ≈ types/user.ts
│   │   │   └── repositories/auth_repository.dart # ≈ servicios
│   │   ├── logic/
│   │   │   └── cubit/auth_cubit.dart            # ≈ Redux slice
│   │   └── ui/
│   │       └── pages/login_page.dart             # ≈ page.tsx
│   └── libros/
│       ├── data/
│       │   └── datasources/libros_datasource.dart
│       ├── models/
│       │   └── libro.dart
│       ├── repositories/libros_repository.dart
│       ├── logic/
│       │   └── cubit/libros_cubit.dart
│       └── ui/
│           ├── pages/home_page.dart              # ≈ page.tsx
│           └── widgets/libro_card.dart           # ≈ components/BookCard.tsx
├── shared/
│   └── core/network/api_client.dart              # ≈ api.ts
```

### 3.4 Flujo de Datos en la Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                 │
│  LoginPage ───► Presiona "Ingresar"                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Logic Layer                               │
│  AuthCubit.login(email, password)                               │
│  ├── Validación de input                                        │
│  └── Llamada a repository                                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                               │
│  AuthRepository.login()                                         │
│  └── AuthDataSource.login() → API /api/Usuarios/Login           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Core Layer                                 │
│  ApiClient (Dio) + AuthInterceptor (token)                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Manejo de Estado (BLoC / Cubit)

### 4.1 ¿Qué es el Estado?

El **estado** es toda información que puede cambiar durante la vida de tu app:

```dart
// Estados en el proyecto
class SessionState extends Equatable {
  final int userId;           // ¿Quién está logueado?
  final String userName;       // Su nombre
  final String token;          // Su sesión
  final bool sancionado;       // ¿Tiene sanción?
  final String nombreRol;       // ¿Qué permisos tiene?
}
```

**Analogía con React**: El estado en Flutter es como `useState`, pero:

- Puede vivir en múltiples lugares (local, Cubit, global)
- Se propaga a través del árbol de widgets
- Cambios en estado = reconstrucciones de UI

### 4.2 ¿Qué Problema Resuelve?

**Sin estado management:**

```dart
// ❌ Problema: Todo en un widget
class MiPagina extends StatefulWidget {
  @override
  State<MiPagina> createState() => _MiPaginaState();
}

class _MiPaginaState extends State<MiPagina> {
  List<Libro> libros = [];      // Estado de libros
  bool isLoading = false;      // Estado de loading
  String? error;              // Estado de error
  String searchQuery = '';    // Estado de búsqueda
  
  Future<void> buscarLibros() async {
    setState(() { isLoading = true; });
    try {
      final resultado = await api.buscar(searchQuery);
      setState(() { libros = resultado; isLoading = false; });
    } catch (e) {
      setState(() { error = e.toString(); isLoading = false; });
    }
  }
}
```

**Problemas:**

1. Lógica de negocio mezclada con UI
2. Difícil compartir estado entre pantallas
3. Imposible testear la lógica sin widget
4. Estado duplicado en múltiples lugares

**Con Cubit:**

```dart
// ✅ Solución: Separación de concerns
class LibrosCubit extends Cubit<LibrosState> {
  final LibrosRepository _repository;

  Future<void> buscarLibros(String query) async {
    emit(LibrosLoading());  // Estado: cargando
    try {
      final resultado = await _repository.getLibros(query: query);
      emit(LibrosLoaded(libros: resultado));  // Estado: éxito
    } catch (e) {
      emit(LibrosError(e.toString()));  // Estado: error
    }
  }
}
```

### 4.3 Cómo Funciona Cubit en el Proyecto

**Anatomía de un Cubit:**

```
┌─────────────────────────────────────────────────┐
│                     Cubit                       │
│  ┌─────────────────────────────────────────┐   │
│  │ Estados (State)                         │   │
│  │ ┌───────────────────────────────────┐   │   │
│  │ │ abstract class LibrosState {}     │   │   │
│  │ │ class LibrosInitial extends...   │   │   │
│  │ │ class LibrosLoading extends...   │   │   │
│  │ │ class LibrosLoaded extends...    │   │   │
│  │ │ class LibrosError extends...     │   │   │
│  │ └───────────────────────────────────┘   │   │
│  └─────────────────────────────────────────┘   │
│                      │                          │
│                      ▼                          │
│  ┌─────────────────────────────────────────┐   │
│  │ Métodos (Acciones)                      │   │
│  │ ┌───────────────────────────────────┐   │   │
│  │ │ void buscarLibros(String query)  │   │   │
│  │ │ void filtrarPorCategoria(...)    │   │   │
│  │ │ void cargarMasLibros()            │   │   │
│  │ └───────────────────────────────────┘   │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

**Del proyecto - AuthCubit** (`auth_cubit.dart:1-54`):

```dart
// 1. Definición del Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final RolesRepository _rolesRepository;
  final SessionCubit _sessionCubit;

  // 2. Constructor con dependencias inyectadas
  AuthCubit({
    required AuthRepository authRepository,
    required RolesRepository rolesRepository,
    required SessionCubit sessionCubit,
  })  : _authRepository = authRepository,
        _rolesRepository = rolesRepository,
        _sessionCubit = sessionCubit,
        super(AuthInitial());  // Estado inicial

  // 3. Método que cambia el estado
  Future<void> login(String correo, String contrasena) async {
    emit(AuthLoading());  // Emite estado de loading
  
    try {
      // Lógica de negocio
      final response = await _authRepository.login(correo, contrasena);
    
      // Obtener rol
      String nombreRol = 'Usuario';
      try {
        final rol = await _rolesRepository.getRol(response.usuario.rolId);
        if (rol != null) nombreRol = rol.nombre;
      } catch (_) {}

      // Guardar sesión
      await _sessionCubit.login(
        userId: response.usuario.id,
        token: response.token,
        // ... más datos
      );

      emit(AuthLoginSuccess(usuario: response.usuario, token: response.token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
```

**Del proyecto - AuthState** (`auth_state.dart:1-60`):

```dart
// Estados inmutables (equivalentes a TypeScript discriminated unions)
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}  // Estado inicial
class AuthLoading extends AuthState {}   // Cargando

class AuthLoginSuccess extends AuthState {
  final Usuario usuario;
  final String token;
  const AuthLoginSuccess({required this.usuario, required this.token});
  @override
  List<Object?> get props => [usuario, token];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
```

### 4.4 Comparación con useState, useReducer y Redux

#### Comparación con useState (React)

| Aspecto       | Flutter (StatefulWidget)     | React (useState)                        |
|---------------|------------------------------|-----------------------------------------|
| Declaración   | `int _count = 0;`            | `const [count, setCount] = useState(0)` |
| Actualización | `setState(() => _count++)`   | `setCount(c => c + 1)`                  |
| Scope         | Solo en ese widget           | Solo en ese componente                  |
| Persistencia  | Se pierde al destruir widget | Se pierde al desmontar                  |

**Uso en proyecto - HomePage** (`home_page.dart:18-27`):

```dart
class _HomePageState extends State<HomePage> {
  // Equivalent a useState
  List<Libro> _recomendados = [];     // const [recomendados, setRecomendados]
  Categoria? _categoriaRandom;         // const [categoria, setCategoria]
  bool _isLoading = true;             // const [isLoading, setIsLoading]
  
  void _actualizarLibros(List<Libro> nuevos) {
    setState(() {                      // Equivalente a setRecomendados
      _recomendados = nuevos;
    });
  }
}
```

#### Comparación con useReducer (React)

| Aspecto   | Flutter (Cubit)                    | React (useReducer)    |
|-----------|------------------------------------|-----------------------|
| Estado    | Defined in separate State class    | Defined inline        |
| Acciones  | Methods on Cubit                   | dispatch(action)      |
| Reducer   | No hay reducer (lógica en métodos) | Pure reducer function |
| Inyección | Vía constructor                    | Via context           |

**Cubit ≈ useReducer mejorado con estructura**

```dart
// Flutter: Lógica en métodos del Cubit
class AuthCubit extends Cubit<AuthState> {
  Future<void> login(email, password) async {
    emit(AuthLoading());
    // ... lógica
    emit(AuthSuccess());
  }
}

// React: Lógica en reducer
const authReducer = (state, action) => {
  switch (action.type) {
    case 'LOGIN_LOADING':
      return { ...state, loading: true };
    case 'LOGIN_SUCCESS':
      return { ...state, loading: false, user: action.payload };
  }
};
```

#### Comparación con Redux (React)

| Aspecto      | Flutter (Cubit)           | Redux                  |
|--------------|---------------------------|------------------------|
| Store global | SessionCubit es global    | Single store           |
| Reducers     | No hay reducers           | Pure reducer functions |
| Actions      | Métodos del Cubit         | Action objects         |
| Middleware   | No hay (lógica en Cubit)  | Redux Thunk/Saga       |
| Selectors    | BlocBuilder con condición | createSelector         |

**Arquitectura similar:**

```
Redux                          Flutter Cubit
─────────────────────          ─────────────────────
Store                          SessionCubit (global)
  └─ authSlice                  └─ AuthCubit
       ├─ state                      ├─ state
       ├─ actions                    └─ methods (login, logout)
       └─ reducers                   └─ repositories
```

**Del proyecto - SessionCubit como Store Global** (`session_cubit.dart:11-52`):

```dart
class SessionCubit extends Cubit<SessionState> {
  // Equivalente al Redux Store
  final FlutterSecureStorage _storage = SecureStorage();
  SignalRService? _signalRService;

  // Estado inicial
  SessionCubit() : super(SessionInitial());

  // Equivalente a una action: LOGIN
  Future<void> login({
    required int userId,
    required String userName,
    required String token,
    // ... más params
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    // ... guardar usuario
  
    // Equivalente a dispatch({ type: 'LOGIN_SUCCESS', payload })
    emit(SessionAuthenticated(
      userId: userId,
      userName: userName,
      token: token,
      // ...
    ));
  
    _connectSignalR();
  }

  // Equivalente a una action: LOGOUT
  Future<void> logout() async {
    await _signalRService?.disconnect();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    emit(SessionUnauthenticated());
  }
}
```

### 4.5 BlocBuilder y BlocConsumer

**BlocBuilder** - Escucha estado y reconstruye UI:

```dart
// Equivalente a useSelector en React
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();  // Muestra loading
    }
    if (state is AuthError) {
      return Text(state.message);  // Muestra error
    }
    return LoginForm();  // Muestra formulario
  },
)
```

**BlocConsumer** - Escucha estado Y reacciona a cambios (listener):

```dart
// Equivalente a useEffect + useSelector
BlocConsumer<ReaderCubit, ReaderState>(
  listener: (context, state) {
    // Equivalente a useEffect: se ejecuta cuando cambia el estado
    if (state is ReaderLoaded) {
      _chapters = state.manifest.readingOrder;
    }
  },
  builder: (context, state) {
    // Equivalente a useSelector: reconstruye UI
    return _buildContent(state);
  },
)
```

**Del proyecto - ReaderPage** (`reader_page.dart:92-103`):

```dart
BlocConsumer<ReaderCubit, ReaderState>(
  listener: (context, state) {
    // Listener: Solo reacciona, no reconstruye
    if (state is ReaderLoaded) {
      setState(() {
        _chapters = state.manifest.readingOrder;
        _currentIndex = state.currentChapterIndex;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(state.currentChapterIndex);
      }
    }
  },
  builder: (context, state) {
    // Builder: Reconstruye la UI basándose en el estado
    return GestureDetector(
      onTap: () => setState(() => _showUi = !_showUi),
      child: Stack(
        children: [
          _buildContent(state, settings),
          if (_showUi) _buildHeader(state, settings),
          if (_showUi) _buildFooter(state, settings),
        ],
      ),
    );
  },
)
```

---

## 5. Navegación

### 5.1 Cómo Funciona la Navegación en Flutter

Flutter tiene dos tipos de navegación:

1. **Navegación imperativa** (旧): `Navigator.push()`, `Navigator.pop()`
2. **Navegación declarativa** (nueva): `go_router`

El proyecto usa `go_router` para navegación declarativa.

### 5.2 Comparación con React Router

**React Router v6:**

```jsx
import { BrowserRouter, Routes, Route, useNavigate } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/book/:id" element={<BookDetail />} />
        <Route path="/login" element={<Login />} />
      </Routes>
    </BrowserRouter>
  );
}

function BookCard({ book }) {
  const navigate = useNavigate();
  return (
    <button onClick={() => navigate(`/book/${book.id}`)}>
      Ver libro
    </button>
  );
}
```

**Flutter con go_router:**

```dart
// app_router.dart
class AppRouter {
  final SessionCubit sessionCubit;
  AppRouter({required this.sessionCubit});

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) => _redirectLogic(state),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: '/book/:id', builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BookDetailPage(libroId: id);
      }),
    ],
  );
}

// Navegación programática
context.push('/book/${libro.id}');  // Equivalente a navigate()
context.pop();  // Equivalente a navigate(-1)
```

**Del proyecto - app_router.dart:116-127**:

```dart
GoRoute(
  path: '/book/:id',
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return BookDetailPage(libroId: id);
  },
),

GoRoute(
  path: '/reader/:id',
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return ReaderPage(libroId: id);
  },
),
```

### 5.3 Redirección Basada en Estado

**Concepto**: Si el usuario no está logueado, redirigir a login automáticamente.

**React Router:**

```jsx
function ProtectedRoute({ children }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" />;
  return children;
}
```

**Flutter con go_router:**

```dart
// app_router.dart:42-69
redirect: (context, state) {
  final sessionState = sessionCubit.state;
  final isLoggedIn = sessionState is SessionAuthenticated;
  final isLoggingIn = state.matchedLocation == '/login' ||
      state.matchedLocation == '/register';

  // No logueado → ir a login
  if (!isLoggedIn && !isLoggingIn) {
    return '/login';
  }

  // Logueado y en login → ir a home
  if (isLoggedIn && isLoggingIn) {
    return isAdmin ? '/admin' : '/home';
  }

  // Admin route sin permisos → ir a home
  if (isAdminRoute && !isAdmin) {
    return '/home';
  }

  return null;  // Continúa normalmente
}
```

### 5.4 ShellRoute para Navegación con Bottom Bar

**Problema**: En apps con bottom navigation, cada tab debe mantener su propio stack.

**Solución**: ShellRoute.

```dart
ShellRoute(
  builder: (context, state, child) {
    return MainShell(child: child);  // Incluye BottomNavigationBar
  },
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomePage()),
    GoRoute(path: '/library', builder: (context, state) => LibraryPage()),
    GoRoute(path: '/history', builder: (context, state) => HistoryPage()),
  ],
)
```

**Del proyecto - MainShell** (`app_router.dart:204-266`):

```dart
class MainShell extends StatelessWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchHeader(...),  // Header compartido
          Expanded(child: child),  // Contenido del tab activo
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.library), label: 'Biblioteca'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}
```

---

## 6. Consumo de APIs

### 6.1 Cómo Se Usa Dio en el Proyecto

**Dio** es un cliente HTTP poderoso para Dart/Flutter con características como:

- Interceptores
- Manejo de errores centralizado
- Retry automático
- Transformación de datos

### 6.2 Requests, Responses, Interceptors

#### ApiClient - Configuración Base

**Del proyecto - api_client.dart:1-34**:

```dart
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5201',
        connectTimeout: Duration(milliseconds: 30000),
        receiveTimeout: Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),      // Añade token automáticamente
      LogInterceptor(         // Log de requests/responses
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }
}
```

#### Interceptores

**AuthInterceptor** - Añade token a requests:

**Del proyecto - auth_interceptor.dart:1-35**:

```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_shouldAddToken(options.path)) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);  // Continúa con el request
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: _tokenKey);  // Limpia sesión en 401
    }
    handler.next(err);
  }

  bool _shouldAddToken(String path) {
    // Rutas que NO necesitan token
    const noAuthPaths = [
      '/api/Usuarios/Login',
      '/api/Usuarios/Register',
      '/api/Usuarios/SolicitarRecuperacion',
    ];
    return !noAuthPaths.any((noAuthPath) => path.contains(noAuthPath));
  }
}
```

### 6.3 Comparación con fetch / axios en React

#### fetch (JavaScript vanilla)

```javascript
// fetch sin interceptor
const login = async (email, password) => {
  const response = await fetch('/api/Usuarios/Login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });
  
  if (!response.ok) {
    throw new Error('Login failed');
  }
  
  return response.json();
};

// fetch con token manual
const getBooks = async () => {
  const token = localStorage.getItem('token');
  const response = await fetch('/api/Libros', {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  return response.json();
};
```

#### axios (JavaScript)

```javascript
// axios con interceptor
const api = axios.create({
  baseURL: '/api',
  timeout: 30000,
});

// Interceptor de request
api.interceptors.request.use(config => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor de response
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Uso
const login = (email, password) => api.post('/Usuarios/Login', { email, password });
const getBooks = () => api.get('/Libros');
```

#### Dio (Flutter)

```dart
// api_client.dart - Configuración con interceptores
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:5201',
      connectTimeout: Duration(milliseconds: 30000),
    ));

    _dio.interceptors.addAll([
      AuthInterceptor(),   // Token automático
      LogInterceptor(),    // Logging
    ]);
  }
}

// Uso en datasource
class AuthDataSource {
  final ApiClient _apiClient;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      '/api/Usuarios/Login',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data);
  }
}
```

### 6.4 Datasource - Capa de Comunicación

**Del proyecto - auth_datasource.dart:1-90**:

```dart
class AuthDataSource {
  final ApiClient _apiClient;

  AuthDataSource(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/Usuarios/Login',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);  // Conversión a excepción del dominio
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Credenciales incorrectas');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['message'];
      return Exception(message ?? 'Error en la solicitud');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Usuario no encontrado');
    }
    return Exception('Error de conexión. Intenta más tarde.');
  }
}
```

---

## 7. Inyección de Dependencias

### 7.1 ¿Qué es DI?

**Inyección de Dependencias (DI)** es un patrón donde las dependencias se pasan desde "afuera" en lugar de crearse internamente.

**Sin DI:**

```dart
// ❌ Problema: Alto acoplamiento, difícil testear
class AuthCubit extends Cubit<AuthState> {
  final _repository = AuthRepository();  // Crea su propia dependencia
  final _session = SessionCubit();       // Crea su propia dependencia
  
  Future<void> login(email, password) async {
    // usa _repository y _session
  }
}
```

**Con DI:**

```dart
// ✅ Solución: Dependencias inyectadas
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SessionCubit _sessionCubit;

  AuthCubit({
    required AuthRepository authRepository,
    required SessionCubit sessionCubit,
  })  : _authRepository = authRepository,
        _sessionCubit = sessionCubit,
        super(AuthInitial());
}
```

### 7.2 Cómo Se Usa get_it en el Proyecto

**get_it** es un service locator simple para Dart.

**Registro de dependencias:**

**Del proyecto - injection_container.dart:53-81**:

```dart
final getIt = GetIt.instance;  // Singleton global

Future<void> setupDependencies() async {
  // Core: Singleton (una sola instancia para toda la app)
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<SessionCubit>(() => SessionCubit());

  // Auth: LazySingleton para repository, Factory para Cubit
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

**Tipos de registro:**

| Método                  | Uso                      | Cuándo                             |
|-------------------------|--------------------------|------------------------------------|
| `registerLazySingleton` | Una instancia compartida | Servicios, repositories, ApiClient |
| `registerFactory`       | Nueva instancia cada vez | Cubits (porque tienen estado)      |
| `registerSingleton`     | Una instancia inmediata  | Raro, solo si no hay async         |

### 7.3 Comparación con Context / Providers en React

#### Context (React)

```tsx
// AuthContext.tsx
const AuthContext = createContext<AuthContextType | null>(null);

function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState(null);
  
  const login = async (email: string, pass: string) => {
    const response = await authService.login(email, pass);
    setUser(response.user);
    localStorage.setItem('token', response.token);
  };

  return (
    <AuthContext.Provider value={{ user, login }}>
      {children}
    </AuthContext.Provider>
  );
}

// Uso
function LoginButton() {
  const { login } = useContext(AuthContext);
  return <button onClick={() => login(email, pass)}>Login</button>;
}
```

#### Providers (React Native / Widgets)

```dart
// Equivalente conceptual en Flutter
Provider<AuthRepository>(
  create: (_) => AuthRepository(),
  child: BlocProvider<AuthCubit>(
    create: (context) => AuthCubit(
      authRepository: context.read<AuthRepository>(),
    ),
    child: MyApp(),
  ),
);
```

#### get_it (Flutter - Proyecto)

```dart
// injection_container.dart
final getIt = GetIt.instance;

// Registro
getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());

// Uso en cualquier parte de la app
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());
}

// En la página
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = getIt<AuthCubit>();  // Obtiene instancia
    return BlocProvider.value(
      value: cubit,
      child: SomeWidget(),
    );
  }
}
```

### 7.4 Beneficios de get_it

1. **Desacoplamiento**: Las clases no saben quién las crea
2. **Testabilidad**: Fácil reemplazar con mocks
3. **Singletons**: Una instancia compartida sin global state
4. **Lazy loading**: Solo se crea cuando se necesita

```dart
// Test con mocks - super fácil
test('AuthCubit emits error on bad credentials', () {
  final mockRepo = MockAuthRepository();
  when(() => mockRepo.login(any(), any()))
      .thenThrow(Exception('Credenciales inválidas'));

  final cubit = AuthCubit(
    authRepository: mockRepo,  // Mock inyectado
    rolesRepository: MockRolesRepository(),
    sessionCubit: MockSessionCubit(),
  );

  cubit.login('bad', 'creds');
  expect(cubit.state, isA<AuthError>());
});
```

---

## 8. Manejo de Datos

### 8.1 Modelos

Los **modelos** representan la estructura de datos de tu app.

**Del proyecto - libro.dart:1-42**:

```dart
class Libro {
  final int id;
  final String titulo;
  final String autor;
  final String descripcion;
  final String? portadaBase64;      // Nullable: puede no tener portada
  final List<String> categorias;    // Lista de strings

  // Constructor con named parameters
  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.descripcion,
    this.portadaBase64,
    required this.categorias,
  });

  // Factory para crear desde JSON (API response)
  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',  // Default si null
      autor: json['autor'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      portadaBase64: json['portadaBase64'] as String?,
      categorias: (json['categorias'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],  // Lista vacía si null
    );
  }

  // Método para convertir a JSON (envío a API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'descripcion': descripcion,
      'portadaBase64': portadaBase64,
      'categorias': categorias,
    };
  }
}
```

### 8.2 Parsing JSON

**Flujo típico:**

```
API Response (JSON)
    │
    ▼
Datasource llama API
    │
    ▼
LoginResponse.fromJson(response.data)
    │
    ▼
LoginResponse.usuario.toJson() / fromJson()
    │
    ▼
Modelo listo para usar en la UI
```

**Del proyecto - Modelo de LoginResponse** (`login_response.dart`):

```dart
class LoginResponse {
  final Usuario usuario;
  final String token;

  LoginResponse({required this.usuario, required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

class Usuario {
  final int id;
  final String userName;
  final String email;
  final int rolId;

  Usuario({
    required this.id,
    required this.userName,
    required this.email,
    required this.rolId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      rolId: json['rolId'] as int? ?? 2,
    );
  }
}
```

### 8.3 Comparación con Manejo de Datos en Frontend Web

#### TypeScript (React)

```typescript
// types/libro.ts
interface Libro {
  id: number;
  titulo: string;
  autor: string;
  descripcion: string;
  portadaBase64?: string;  // Optional
  categorias: string[];
}

// API call
const getLibro = async (id: number): Promise<Libro> => {
  const response = await fetch(`/api/libros/${id}`);
  const data = await response.json();
  return data as Libro;  // Type assertion
};

// Uso
const libro: Libro = await getLibro(1);
console.log(libro.titulo);
```

#### Dart (Flutter)

```dart
// Equivalente a TypeScript - mismo concepto
class Libro {
  final int id;
  final String titulo;
  final String autor;
  final String? portadaBase64;  // Nullable con ?
  final List<String> categorias;

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',
      // ...
    );
  }
}

// Uso
final libro = await getLibro(1);
print(libro.titulo);
```

### 8.4 Inmutabilidad en Dart

**Importancia**: Los estados deben ser inmutables para que BLoC detecte cambios.

```dart
// ✅ Estado inmutable (correcto)
class LibrosLoaded extends LibrosState {
  final List<Libro> libros;
  final int page;
  final bool hasMore;

  const LibrosLoaded({
    required this.libros,
    required this.page,
    required this.hasMore,
  });

  // copyWith: crea nueva instancia con valores actualizados
  LibrosLoaded copyWith({
    List<Libro>? libros,
    int? page,
    bool? hasMore,
  }) {
    return LibrosLoaded(
      libros: libros ?? this.libros,  // Usa actual si no proveído
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
```

---

## 9. Persistencia Local

### 9.1 FlutterSecureStorage

El proyecto usa `FlutterSecureStorage` para guardar datos sensibles como tokens.

**Del proyecto - session_cubit.dart:1-77**:

```dart
class SessionCubit extends Cubit<SessionState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> login({
    required int userId,
    required String token,
    // ...
  }) async {
    // 1. Guardar token de forma segura
    await _storage.write(key: _tokenKey, value: token);

    // 2. Guardar datos de usuario como JSON
    final user = {
      'id': userId,
      'token': token,
      // ...
    };
    await _storage.write(key: _userKey, value: jsonEncode(user));

    // 3. Emitir estado de sesión activa
    emit(SessionAuthenticated(...));
  }

  Future<void> checkSession() async {
    // Verificar si hay sesión guardada al iniciar la app
    final token = await _storage.read(key: _tokenKey);
    final userData = await _storage.read(key: _userKey);

    if (token != null && userData != null) {
      // Restaurar sesión
      final user = jsonDecode(userData);
      emit(SessionAuthenticated(
        userId: user['id'],
        token: token,
        // ...
      ));
    } else {
      emit(SessionUnauthenticated());
    }
  }

  Future<void> logout() async {
    // Limpiar todo al cerrar sesión
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    emit(SessionUnauthenticated());
  }
}
```

### 9.2 Comparación con localStorage / IndexedDB

#### localStorage (JavaScript)

```javascript
// Guardar
localStorage.setItem('token', 'abc123');
localStorage.setItem('user', JSON.stringify({ id: 1, name: 'Juan' }));

// Leer
const token = localStorage.getItem('token');
const user = JSON.parse(localStorage.getItem('user'));

// Eliminar
localStorage.removeItem('token');
localStorage.clear();  // Todo
```

#### FlutterSecureStorage

```dart
// Guardar (cifrado automático)
await _storage.write(key: 'token', value: 'abc123');
await _storage.write(key: 'user', value: jsonEncode({'id': 1, 'name': 'Juan'}));

// Leer
final token = await _storage.read(key: 'token');
final userData = await _storage.read(key: 'user');
final user = jsonDecode(userData!);

// Eliminar
await _storage.delete(key: 'token');
await _storage.deleteAll();  // Todo
```

### 9.3 Diferencias Clave

| Aspecto       | localStorage         | FlutterSecureStorage  |
|---------------|----------------------|-----------------------|
| Cifrado       | No                   | Sí (AES)              |
| Capacidad     | ~5-10 MB             | Menor pero suficiente |
| Tipo de datos | Solo strings         | Solo strings          |
| Acceso        | Sincrónico           | Asincrónico           |
| Seguridad     | Datos en texto plano | Datos cifrados        |

**¿Cuándo usar cada uno?**

| localStorage       | FlutterSecureStorage         |
|--------------------|------------------------------|
| Datos no sensibles | Tokens JWT                   |
| Preferencias de UI | Datos de usuario             |
| Cache simple       | Contraseñas (si las hubiera) |

---

## 10. Flujo Real del Proyecto

Esta sección explica paso a paso qué sucede cuando un usuario interactúa con la app.

### 10.1 Flujo de Autenticación

```
┌──────────────────────────────────────────────────────────────────────┐
│                        LOGIN FLOW                                    │
└──────────────────────────────────────────────────────────────────────┘

USUARIO                    UI                       CUIT                 REPOSITORY
  │                        │                         │                      │
  │  1. Ingresa credenciales                        │                      │
  │───────────────────────►│                        │                      │
  │                        │                         │                      │
  │                        │  2. login(email, pass)  │                      │
  │                        │────────────────────────►│                      │
  │                        │                         │                      │
  │                        │                         │  3. _authRepository  │
  │                        │                         │  .login(email, pass)  │
  │                        │                         │─────────────────────►│
  │                        │                         │                      │
  │                        │                         │     4. POST /api/    │
  │                        │                         │        Usuarios/     │
  │                        │                         │        Login         │
  │                        │                         │─────────────────────►│
  │                        │                         │                      │
  │                        │                         │     5. { token,      │
  │                        │                         │        usuario }    │
  │                        │                         │◄─────────────────────│
  │                        │                         │                      │
  │                        │  6. emit(AuthSuccess)   │                      │
  │                        │◄────────────────────────│                      │
  │                        │                         │                      │
  │                        │  7. _sessionCubit.login │                      │
  │                        │────────────────────────►│                      │
  │                        │                         │                      │
  │                        │  8. Guardar token en    │                      │
  │                        │     SecureStorage       │                      │
  │                        │────────────────────────►│                      │
  │                        │                         │                      │
  │                        │  9. emit(SessionAuth)   │                      │
  │                        │◄────────────────────────│                      │
  │                        │                         │                      │
  │  10. Redirigir a /home │                         │                      │
  │◄───────────────────────│                         │                      │
```

**Código paso a paso:**

1. **UI - LoginPage**: Usuario presiona botón

   ```dart
   // login_page.dart
   onPressed: () {
     context.read<AuthCubit>().login(
       _emailController.text,
       _passwordController.text,
     );
   }
   ```
2. **Cubit - AuthCubit.login()**: Recibe y procesa

   ```dart
   // auth_cubit.dart:22-54
   Future<void> login(String correo, String contrasena) async {
     emit(AuthLoading());  // Estado: cargando

     try {
       final response = await _authRepository.login(correo, contrasena);

       // Obtener rol del usuario
       final rol = await _rolesRepository.getRol(response.usuario.rolId);

       // Guardar sesión
       await _sessionCubit.login(
         userId: response.usuario.id,
         userName: response.usuario.userName,
         email: response.usuario.email,
         token: response.token,
         // ...
       );

       emit(AuthLoginSuccess(usuario: response.usuario, token: response.token));
     } catch (e) {
       emit(AuthError(e.toString()));  // Estado: error
     }
   }
   ```
3. **Repository**: Abstrae el datasource

   ```dart
   // auth_repository.dart
   Future<LoginResponse> login(String email, String password) async {
     final request = LoginRequest(email: email, password: password);
     return await _authDataSource.login(request);
   }
   ```
4. **Datasource**: Hace la llamada HTTP

   ```dart
   // auth_datasource.dart
   Future<LoginResponse> login(LoginRequest request) async {
     final response = await _apiClient.post(
       '/api/Usuarios/Login',
       data: request.toJson(),
     );
     return LoginResponse.fromJson(response.data);
   }
   ```
5. **SessionCubit**: Guarda sesión globalmente

   ```dart
   // session_cubit.dart:54-92
   Future<void> login({...}) async {
     await _storage.write(key: _tokenKey, value: token);
     await _storage.write(key: _userKey, value: jsonEncode(user));
     emit(SessionAuthenticated(...));
     _connectSignalR();  // Conecta notificaciones
   }
   ```

### 10.2 Flujo de Lectura de Libros

```
┌──────────────────────────────────────────────────────────────────────┐
│                    HOME PAGE - CARGA DE LIBROS                       │
└──────────────────────────────────────────────────────────────────────┘

PANTALLA                     CUIT (LibrosCubit)          REPOSITORY
    │                                │                          │
    │  1. initState()                │                          │
    │───────────────────────────────►│                          │
    │                                │                          │
    │  2. getCategorias()            │                          │
    │                                │──────────────────────────►│
    │                                │     3. GET /api/Categorias│
    │                                │──────────────────────────►│
    │                                │                          │
    │                                │     4. [Categoria]        │
    │                                │◄──────────────────────────│
    │                                │                          │
    │  5. emit(CategoriasLoaded)     │                          │
    │◄───────────────────────────────│                          │
    │                                │                          │
    │  6. getLibrosAleatorios()       │                          │
    │                                │──────────────────────────►│
    │                                │     7. GET /api/Libros   │
    │                                │                          │
    │                                │     8. [Libro, ...]      │
    │                                │◄──────────────────────────│
    │                                │                          │
    │  9. emit(LibrosLoaded)         │                          │
    │◄───────────────────────────────│                          │
    │                                │                          │
    │  10. UI reconstruye con BlocBuilder                        │
    │═══════════════════════════════════════════════════════════════│
```

**Código:**

```dart
// home_page.dart:41-84
Future<void> _cargarSecciones() async {
  setState(() => _isLoading = true);  // UI: mostrar loading

  final cubit = context.read<LibrosCubit>();
  
  // Carga categorías
  final categoriasResult = await cubit.getCategorias();
  final categorias = categoriasResult.data;
  
  // Carga libros recomendados
  final recomendados = await cubit.getLibrosAleatorios();
  
  // Carga top 5
  final top5 = await cubit.getTop5Libros();
  
  // Actualiza UI
  if (mounted) {
    setState(() {
      _recomendados = recomendados;
      _top5 = top5;
      _isLoading = false;
    });
  }
}
```

### 10.3 Flujo del Reader (Lector de Libros)

```
┌──────────────────────────────────────────────────────────────────────┐
│                      READER PAGE - CARGA EPUB                        │
└──────────────────────────────────────────────────────────────────────┘

PANTALLA              CUIT (ReaderCubit)          DATASOURCE
    │                         │                        │
    │  1. initState()         │                        │
    │────────────────────────►│                        │
    │                         │                        │
    │  2. cargarLibro()       │                        │
    │                         │                        │
    │                         │  3. _epubRepository    │
    │                         │     .getEpubContent(id)│
    │                         │───────────────────────►│
    │                         │                        │
    │                         │  4. Descarga EPUB zip  │
    │                         │───────────────────────►│
    │                         │                        │
    │                         │  5. Parse EPUB         │
    │                         │     (manifest + spine) │
    │                         │◄───────────────────────│
    │                         │                        │
    │  6. emit(ReaderLoaded)  │                        │
    │◄────────────────────────│                        │
    │                         │                        │
    │  7. UI muestra índice   │                        │
    │     y primer capítulo   │                        │
```

### 10.4 Explicación: UI → Lógica → Datos

```
┌─────────────────────────────────────────────────────────────────┐
│                        ARQUITECTURA EN CAPAS                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  CAPA 1: UI (Presentation)                                       │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Widgets que observan estados y emiten eventos           │    │
│  │                                                            │    │
│  │ BlocBuilder<AuthCubit, AuthState>                        │    │
│  │   ├── builder: Muestra UI según estado                   │    │
│  │   └── onTap: Llama a cubit.login()                       │    │
│  └─────────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────────┘
                             │ Events (login, logout, etc.)
                             │ States (AuthLoading, AuthSuccess, etc.)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  CAPA 2: Lógica (Business Logic)                                │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Cubits que contienen lógica de negocio                  │    │
│  │                                                            │    │
│  │ AuthCubit                                                  │    │
│  │   ├── Estados: AuthInitial, AuthLoading, AuthSuccess... │    │
│  │   ├── Métodos: login(), logout(), register()             │    │
│  │   └── Dependencias: AuthRepository, SessionCubit         │    │
│  └─────────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────────┘
                             │ Repository methods
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  CAPA 3: Datos (Data)                                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Repositories + Datasources                              │    │
│  │                                                            │    │
│  │ AuthRepository                                           │    │
│  │   └── AuthDataSource                                     │    │
│  │        └── ApiClient.post('/api/Usuarios/Login')         │    │
│  └─────────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP requests
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  CAPA 4: Infraestructura (Core)                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ApiClient + Interceptors                                 │    │
│  │                                                            │    │
│  │ - AuthInterceptor: Añade token                           │    │
│  │ - LogInterceptor: Logging                                │    │
│  │ - Error handling: 401, 404, 500...                       │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 11. Buenas Prácticas

### 11.1 Separación de Responsabilidades

**Principio**: Cada capa tiene una responsabilidad única.

| Capa       | Responsabilidad                 | NO debe hacer                    |
|------------|---------------------------------|----------------------------------|
| UI         | Mostrar datos, capturar eventos | Lógica de negocio, llamadas HTTP |
| Cubit      | Estado, lógica de presentación  | Llamadas HTTP directas           |
| Repository | Abstraer datasource             | Serialización JSON               |
| Datasource | Comunicación API                | Lógica de negocio                |
| Model      | Estructura de datos             | Lógica de negocio                |

**Ejemplo de MAL código:**

```dart
// ❌ Datasource haciendo lógica de negocio
class AuthDataSource {
  Future<LoginResponse> login(email, pass) async {
    // ❌ Validando en datasource
    if (email.isEmpty) throw Exception('Email requerido');
    if (pass.length < 6) throw Exception('Contraseña muy corta');
  
    // ... API call
  }
}
```

**Código correcto:**

```dart
// ✅ Datasource solo comunica con API
class AuthDataSource {
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      '/api/Usuarios/Login',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data);
  }
}

// ✅ Validator en Cubit o UI
class AuthCubit {
  Future<void> login(String email, String pass) async {
    // Validación
    if (email.isEmpty || pass.isEmpty) {
      emit(AuthError('Todos los campos son requeridos'));
      return;
    }
  
    // ... proceed
  }
}
```

### 11.2 Clean Architecture

El proyecto sigue principios de Clean Architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    CLEAN ARCHITECTURE                        │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                    UI LAYER                         │   │
│   │  Pages, Widgets (Flutter)                          │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              APPLICATION LAYER                     │   │
│   │  Cubits, States (Orquestación)                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                 DOMAIN LAYER                        │   │
│   │  Models, Repository Interfaces                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              INFRASTRUCTURE LAYER                   │   │
│   │  Datasources, ApiClient, Storage                    │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 11.3 Escalabilidad

**Beneficios de la arquitectura del proyecto:**

1. **Agregar features es fácil:**

   ```dart
   // Solo crear nuevo folder en features/
   lib/features/
   └── nuevafeature/
       ├── data/
       ├── logic/
       └── ui/
   ```
2. **Compartir código es claro:**

   ```dart
   // Código compartido va en shared/
   lib/shared/
   ├── core/
   │   ├── network/
   │   ├── errors/
   │   └── session/
   └── ui/widgets/
   ```
3. **Testear es aislado:**

   ```bash
   # Cada feature se testa independientemente
   flutter test test/features/auth/
   flutter test test/features/libros/
   ```

---

## 12. Errores Comunes y Cómo Evitarlos

### 12.1 setState en StatelessWidget

```dart
// ❌ ERROR: StatelessWidget no tiene setState
class MiWidget extends StatelessWidget {
  int _contador = 0;  // Esto no funciona
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_contador'),
        ElevatedButton(
          onPressed: () {
            _contador++;  // No causa re-render
            setState(() {});  // ERROR: StatelessWidget no tiene setState
          },
          child: Text('Incrementar'),
        ),
      ],
    );
  }
}

// ✅ CORRECTO: Usar StatefulWidget o Cubit
class MiWidget extends StatefulWidget {
  @override
  State<MiWidget> createState() => _MiWidgetState();
}

class _MiWidgetState extends State<MiWidget> {
  int _contador = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_contador'),
        ElevatedButton(
          onPressed: () => setState(() => _contador++),
          child: Text('Incrementar'),
        ),
      ],
    );
  }
}
```

### 12.2 Olvidar dispose()

```dart
// ❌ ERROR: Memory leak
class MiPagina extends StatefulWidget {
  @override
  State<MiPagina> createState() => _MiPaginaState();
}

class _MiPaginaState extends State<MiPagina> {
  final _scrollController = ScrollController();
  final _streamSubscription = Stream.periodic().listen(() {});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 100,
      itemBuilder: (_, __) => ListTile(title: Text('Item')),
    );
  }
  // ❌ NO hay dispose(): memory leak seguro
}

// ✅ CORRECTO: Siempre hacer dispose()
class _MiPaginaState extends State<MiPagina> {
  final _scrollController = ScrollController();
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Stream.periodic().listen(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();  // Libera controller
    _subscription.cancel();      // Cancela subscription
    super.dispose();              // Siempre llamar al final
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 100,
      itemBuilder: (_, __) => ListTile(title: Text('Item')),
    );
  }
}
```

### 12.3 Capturar contextos antes de async

```dart
// ❌ ERROR: Context usado después de async
class _MiPaginaState extends State<MiPagina> {
  Future<void> _cargarDatos() async {
    final cubit = context.read<AuthCubit>();  // ❌ Puede ser null si popeo
  
    await Future.delayed(Duration(seconds: 2));
  
    cubit.login();  // ❌ Crash si navigated away
  }
}

// ✅ CORRECTO: Verificar mounted
class _MiPaginaState extends State<MiPagina> {
  Future<void> _cargarDatos() async {
    final cubit = context.read<AuthCubit>();
  
    await Future.delayed(Duration(seconds: 2));
  
    if (mounted) {  // ✅ Verifica que sigamos montados
      cubit.login();
    }
  }
}
```

### 12.4 No cerrar Cubits creados

```dart
// ❌ ERROR: Cubit nunca se cierra
class _MiPaginaState extends State<MiPagina> {
  late final AuthCubit _cubit = getIt<AuthCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,  // ❌ Nunca llama _cubit.close()
      child: SomeWidget(),
    );
  }
}

// ✅ CORRECTO: Cerrar en dispose
class _MiPaginaState extends State<MiPagina> {
  late final AuthCubit _cubit = getIt<AuthCubit>();

  @override
  void dispose() {
    _cubit.close();  // ✅ Cierra el Cubit
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: SomeWidget(),
    );
  }
}
```

### 12.5 Ignorar el parámetro `key`

```dart
// ⚠️ WARNING: Sin key, Flutter no puede optimizar re-renders
class LibroCard extends StatelessWidget {
  final Libro libro;
  
  const LibroCard({super.key, required this.libro});  // ✅ Key disponible
}

// En un ListView, siempre usar keys únicas
ListView.builder(
  itemCount: libros.length,
  itemBuilder: (context, index) {
    return LibroCard(
      key: ValueKey(libros[index].id),  // ✅ Key única para cada item
      libro: libros[index],
    );
  },
);
```

### 12.6 No manejar estados nulos

```dart
// ❌ ERROR: Asume que el estado siempre tiene datos
Widget build(BuildContext context) {
  final state = context.read<LibrosCubit>().state;
  
  // ❌ Crash si es null o no es LibrosLoaded
  return Text(state.libros.first.titulo);
}

// ✅ CORRECTO: Verificar tipo y null safety
Widget build(BuildContext context) {
  return BlocBuilder<LibrosCubit, LibrosState>(
    builder: (context, state) {
      if (state is! LibrosLoaded) {  // ✅ Verificar tipo
        return CircularProgressIndicator();
      }
    
      if (state.libros.isEmpty) {    // ✅ Verificar contenido
        return Text('No hay libros');
      }
    
      return Text(state.libros.first.titulo);
    },
  );
}
```

---

## 13. Mapa Mental del Proyecto

### 13.1 Visión General de Conexiones

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           OPEN BOOKS MOBILE                             │
│                          ARQUITECTURA GENERAL                           │
└─────────────────────────────────────────────────────────────────────────┘

                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              main.dart                                   │
│  1. Env.init()         → Carga variables de entorno                    │
│  2. setupDependencies() → Registra todo en get_it                      │
│  3. runApp()           → Inicia la app                                │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            AppRouter                                    │
│  • Configura rutas con go_router                                         │
│  • Redirect basado en SessionCubit (logueado/no logueado)               │
│  • ShellRoute para bottom navigation                                     │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
┌─────────────────────────┐         ┌─────────────────────────┐
│     USUARIO NO          │         │     USUARIO             │
│     LOGUEADO            │         │     LOGUEADO            │
├─────────────────────────┤         ├─────────────────────────┤
│  /login                 │         │  /home (Libros)         │
│  /register              │         │  /library (Biblioteca)   │
│  /recovery              │         │  /history (Historial)   │
│                         │         │  /book/:id (Detalle)    │
│                         │         │  /reader/:id (Lector)   │
│                         │         │  /profile (Perfil)      │
│                         │         │  /settings (Ajustes)    │
│                         │         │  /notifications         │
│                         │         │                         │
│                         │         │  (Si es admin:)        │
│                         │         │  /admin/*               │
└─────────────────────────┘         └─────────────────────────┘
```

### 13.2 Flujo de Datos Entre Features

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          FLUJO DE DATOS                                  │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    AUTH       │     │    LIBROS     │     │   READER     │
├──────────────┤     ├──────────────┤     ├──────────────┤
│              │     │              │     │              │
│ LoginPage    │     │ HomePage     │     │ ReaderPage   │
│     │        │     │     │        │     │     │        │
│     ▼        │     │     ▼        │     │     ▼        │
│ AuthCubit    │     │ LibrosCubit  │     │ ReaderCubit │
│     │        │     │     │        │     │     │        │
│     ▼        │     │     ▼        │     │     ▼        │
│ AuthRepo     │     │ LibrosRepo   │     │ EpubRepo    │
│     │        │     │     │        │     │     │        │
└─────┼────────┘     └─────┼────────┘     └─────┼────────┘
      │                   │                   │
      │                   │                   │
      ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────────┐
│                    SHARED CORE                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────┐ │
│  │   ApiClient   │  │ SessionCubit  │  │ Dio        │ │
│  │   (Dio HTTP)  │  │ (Global State)│  │ Interceptor│ │
│  └───────────────┘  └───────────────┘  └────────────┘ │
│                                                         │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────┐ │
│  │ SecureStorage │  │ SignalR       │  │ Errors     │ │
│  │ (Tokens/JWT)  │  │ (Notifications│  │ (Exceptions│ │
│  └───────────────┘  └───────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        EXTERNAL SERVICES                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────┐         ┌─────────────────────┐               │
│  │   REST API Backend  │         │  SignalR Hub        │               │
│  │   /api/Usuarios/*   │         │  /Hub/Notificaciones│               │
│  │   /api/Libros/*     │         │                     │               │
│  │   /api/Biblioteca/* │         │  (Push notifications)│              │
│  └─────────────────────┘         └─────────────────────┘               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 13.3 Estados Globales y Locales

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       ESTADOS EN LA APP                                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        ESTADO GLOBAL                                    │
│  (Accessible desde cualquier parte de la app)                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  SessionCubit                                                          │
│  ├── SessionUnauthenticated → No hay usuario                          │
│  ├── SessionLoading → Verificando sesión                               │
│  ├── SessionAuthenticated                                               │
│  │   ├── userId, userName, email                                       │
│  │   ├── token (JWT)                                                    │
│  │   ├── rolId, nombreRol                                               │
│  │   ├── sancionado (¿tiene sanción?)                                  │
│  │   └── fotoPerfilBase64                                               │
│  │                                                                     │
│  └── isAdmin (getter: rolId == 1)                                      │
│                                                                         │
│  ReaderSettingsCubit                                                   │
│  ├── theme (light/sepia/dark)                                          │
│  ├── fontSize, fontFamily                                              │
│  ├── lineHeight, marginHorizontal                                       │
│  └── (Persiste preferencias del usuario)                                │
│                                                                         │
│  NotificationCubit                                                     │
│  └── List<AppNotification>                                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        ESTADOS POR FEATURE                              │
│  (Solo accesibles dentro de su feature)                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │   AUTH      │  │   LIBROS    │  │ BIBLIOTECA  │  │  READER     │ │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤  ├─────────────┤ │
│  │AuthInitial  │  │LibrosInitial│  │BibInitial   │  │ReaderLoading│ │
│  │AuthLoading  │  │LibrosLoading│  │BibLoading   │  │ReaderLoaded │ │
│  │AuthSuccess  │  │LibrosLoaded │  │BibLoaded    │  │ReaderError  │ │
│  │AuthError    │  │LibrosError  │  │BibError     │  │             │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 14. Siguientes Pasos

### 14.1 Qué Aprender Después

#### Nivel Intermedio

1. **Testing**

   - Unit tests con `flutter_test`
   - Mocking con `mocktail`
   - Integration tests
2. **Performance**

   - Optimización de ListViews
   - Image caching con `cached_network_image`
   - Const constructors
3. **Animaciones**

   - `AnimatedBuilder`
   - `Hero` transitions
   - Page transitions

#### Nivel Avanzado

1. **State Management Alternativo**

   - Riverpod (más moderno, similar a hooks)
   - Drift (base de datos local)
2. **Arquitectura**

   - Repository Pattern completo
   - Use Cases
   - Domain Driven Design
3. **DevOps**

   - CI/CD con GitHub Actions
   - Firebase (Analytics, Crashlytics)
   - App Store / Play Store deployment

### 14.2 Qué Mejorar en Este Proyecto

#### Alta Prioridad

- [ ] **Tests**: Agregar tests unitarios para Cubits

  ```bash
  flutter test test/features/auth/
  ```
- [ ] **Manejo de errores mejorado**: Mostrar mensajes de error más amigables
- [ ] **Offline support**: Cache de libros para uso sin conexión

#### Media Prioridad

- [ ] **Dark mode completo**: Mejorar tema oscuro en reader
- [ ] **Optimización de imágenes**: Usar `cached_network_image`
- [ ] **Validación robusta**: Agregar validators en formularios

#### Baja Prioridad

- [ ] **Animaciones**: Transiciones suaves entre pantallas
- [ ] **i18n**: Soporte para múltiples idiomas
- [ ] **PWA**: Optimizar build para web

### 14.3 Recursos Recomendados

| Recurso                   | Tipo       | Link                          |
|---------------------------|------------|-------------------------------|
| Documentación Flutter     | Oficial    | flutter.dev/docs              |
| flutter_bloc              | Paquete    | pub.dev/packages/flutter_bloc |
| Dart Language Tour        | Oficial    | dart.dev/guides/language      |
| Reso Coder (YouTube)      | Tutoriales | YouTube/@ResoCoder            |
| Official Flutter Codelabs | Práctico   | flutter.dev/codelabs          |

### 14.4 Checklist de Competencias

Después de estudiar este proyecto, deberías poder:

- [ ] Crear un nuevo feature desde cero
- [ ] Implementar un nuevo Cubit con estados
- [ ] Conectar la UI con un Cubit usando BlocBuilder
- [ ] Hacer llamadas HTTP con Dio
- [ ] Registrar dependencias en get_it
- [ ] Configurar rutas con go_router
- [ ] Guardar datos en SecureStorage
- [ ] Manejar errores de forma centralizada
- [ ] Entender el flujo de datos completo de la app

---

## Anexo: Glosario Rápido

| Término           | Significado                                                  |
|-------------------|--------------------------------------------------------------|
| **Widget**        | Componente UI en Flutter (equivalente a componente en React) |
| **Cubit**         | Gestión de estado simplificada (como useReducer + useState)  |
| **BlocBuilder**   | Observador de estado (como useSelector en Redux)             |
| **get_it**        | Service locator / DI container                               |
| **Dio**           | Cliente HTTP con interceptores                               |
| **go_router**     | Librería de navegación declarativa                           |
| **SecureStorage** | Almacenamiento cifrado (como localStorage pero seguro)       |
| **Feature**       | Módulo/característica de la app                              |
| **Datasource**    | Capa que se comunica con APIs/externa                        |
| **Repository**    | Abstracción que oculta el datasource                         |
| **Equatable**     | Mixin para comparar estados por valor                        |

---

*Documento creado en base al proyecto Open Books Mobile*
*Última actualización: 2026-03-22*
