# PLAN TÉCNICO - APP MÓVIL OPENBOOK (FLUTTER)

## CONFIGURACIÓN CONFIRMADA

| Aspecto        | Decisión                                          |
|----------------|---------------------------------------------------|
| Offline        | Solo lectura descargada (sin sync de operaciones) |
| Admin          | Misma app, acceso por rol                         |
| Notificaciones | SignalR + Locales (sin FCM)                       |
| UI             | Material Design estándar                          |
| Navegación     | Bottom Navigation o Tabs (según pantalla)         |

## 1. RESUMEN DEL BACKEND ANALIZADO

### Stack Tecnológico
- **Backend**: ASP.NET Core 8 + Entity Framework Core
- **DB**: PostgreSQL
- **Auth**: JWT Bearer Token
- **Tiempo Real**: SignalR Hub (`/Hub/NotificacionesHub`)

---

## 1.1 ENDPOINTS DEL BACKEND

### Autenticación (No requiere auth)

| Método | Endpoint                              | Descripción                          | Body/Params                                                    |
|--------|---------------------------------------|--------------------------------------|----------------------------------------------------------------|
| POST   | `/api/Usuarios/Login`                 | Iniciar sesión                       | `{ correo, contrasena }`                                       |
| POST   | `/api/Usuarios/Register`              | Registrarse                          | `{ nombreUsuario, correo, contraseña, rolId, nombreCompleto }` |
| POST   | `/api/Usuarios/SolicitarRecuperacion` | Solicitar recuperación de contraseña | `{ correo }`                                                   |
| POST   | `/api/Usuarios/ResetearContrasena`    | Resetear contraseña                  | `{ token, nuevaContraseña }`                                   |

### Usuarios

| Método | Endpoint             | Descripción                | Auth  | Body/Params                                              |
|--------|----------------------|----------------------------|-------|----------------------------------------------------------|
| GET    | `/api/Usuarios`      | Listar usuarios (paginado) | Admin | `pageNumber, pageSize`                                   |
| GET    | `/api/Usuarios/{id}` | Obtener usuario por ID     | Sí    | -                                                        |
| PATCH  | `/api/Usuarios/{id}` | Actualizar usuario         | Sí    | `{ userName?, email?, nombreCompleto? }`                 |
| POST   | `/api/Usuarios`      | Crear usuario              | Admin | `{ userName, email, contraseña, rolId, nombreCompleto }` |
| DELETE | `/api/Usuarios/{id}` | Eliminar usuario           | Admin | -                                                        |

### Libros

| Método | Endpoint                         | Descripción                        | Auth  | Body/Params                                                              |
|--------|----------------------------------|------------------------------------|-------|--------------------------------------------------------------------------|
| GET    | `/api/Libros`                    | Listar libros (búsqueda, filtrado) | No    | `query, page, pageSize, categorias, autor`                               |
| GET    | `/api/Libros/{id}`               | Descargar archivo EPUB             | Sí    | -                                                                        |
| GET    | `/api/Libros/{id}/detalle`       | Ver detalle con reseñas            | No    | `page, pageSize`                                                         |
| GET    | `/api/Libros/{id}/portada`       | Obtener portada                    | No    | -                                                                        |
| GET    | `/api/Libros/{id}/descargar`     | Descargar libro                    | Sí    | -                                                                        |
| GET    | `/api/Libros/{id}/epub/manifest` | Obtener índice del libro           | No    | -                                                                        |
| GET    | `/api/Libros/{id}/epub/resource` | Obtener contenido de capítulo      | No    | `path`                                                                   |
| POST   | `/api/Libros/upload`             | Subir libro (EPUB)                 | Admin | `form-data: titulo, autor, descripcion, portada, archivo, categoriasIds` |
| PATCH  | `/api/Libros/{id}`               | Actualizar libro                   | Admin | `form-data`                                                              |
| DELETE | `/api/Libros/{id}`               | Eliminar libro                     | Admin | -                                                                        |

### Biblioteca (del usuario)

| Método | Endpoint                                       | Descripción                | Auth |
|--------|------------------------------------------------|----------------------------|------|
| GET    | `/api/Biblioteca/{usuarioId}/libros`           | Obtener libros del usuario | Sí   |
| POST   | `/api/Biblioteca/{usuarioId}/libros/{libroId}` | Agregar libro a biblioteca | Sí   |
| DELETE | `/api/Biblioteca/{usuarioId}/libros/{libroId}` | Quitar libro de biblioteca | Sí   |

### Valoraciones

| Método | Endpoint                            | Descripción                  | Auth | Body/Params               |
|--------|-------------------------------------|------------------------------|------|---------------------------|
| POST   | `/api/Valoraciones`                 | Crear valoración             | Sí   | `{ libroId, puntuacion }` |
| PUT    | `/api/Valoraciones`                 | Actualizar valoración        | Sí   | `{ libroId, puntuacion }` |
| DELETE | `/api/Valoraciones`                 | Eliminar valoración          | Sí   | `idLibro`                 |
| GET    | `/api/Valoraciones/libro/{idLibro}` | Ver valoraciones de libro    | No   | -                         |
| GET    | `/api/Valoraciones/top5`            | Top 5 libros mejor valorados | No   | -                         |

### Reseñas

| Método | Endpoint                       | Descripción              | Auth | Body/Params               |
|--------|--------------------------------|--------------------------|------|---------------------------|
| POST   | `/api/Resenas`                 | Crear reseña             | Sí   | `{ libroId, texto }`      |
| PUT    | `/api/Resenas/{idResena}`      | Actualizar reseña        | Sí   | `{ texto }`               |
| DELETE | `/api/Resenas/{idResena}`      | Eliminar reseña          | Sí   | -                         |
| GET    | `/api/Resenas/libro/{idLibro}` | Ver reseñas de libro     | No   | `page, pageSize`          |
| GET    | `/api/Resenas`                 | Listar todas las reseñas | No   | `idLibro, page, pageSize` |

### Categorías

| Método | Endpoint               | Descripción          | Auth  | Body/Params                 |
|--------|------------------------|----------------------|-------|-----------------------------|
| GET    | `/api/Categorias`      | Listar categorías    | No    | `pageNumber, pageSize`      |
| GET    | `/api/Categorias/{id}` | Obtener categoría    | No    | -                           |
| POST   | `/api/Categorias`      | Crear categoría      | Admin | `{ nombre, descripcion }`   |
| PATCH  | `/api/Categorias/{id}` | Actualizar categoría | Admin | `{ nombre?, descripcion? }` |
| DELETE | `/api/Categorias/{id}` | Eliminar categoría   | Admin | -                           |

### Historial de Lectura

| Método | Endpoint                    | Descripción                   | Auth | Body/Params |
|--------|-----------------------------|-------------------------------|------|-------------|
| GET    | `/api/Historial/mis-libros` | Obtener historial del usuario | Sí   | `cantidad`  |

### Denuncias

| Método | Endpoint             | Descripción       | Auth  | Body/Params                                    |
|--------|----------------------|-------------------|-------|------------------------------------------------|
| POST   | `/api/Denuncia`      | Crear denuncia    | Sí    | `{ usuarioDenunciadoId, motivo, descripcion }` |
| GET    | `/api/Denuncia`      | Listar denuncias  | Admin | `pagina, tamanoPagina`                         |
| DELETE | `/api/Denuncia/{id}` | Eliminar denuncia | Admin | -                                              |

### Sugerencias

| Método | Endpoint               | Descripción         | Auth  | Body/Params               |
|--------|------------------------|---------------------|-------|---------------------------|
| POST   | `/api/Sugerencia`      | Crear sugerencia    | Sí    | `{ titulo, descripcion }` |
| GET    | `/api/Sugerencia`      | Listar sugerencias  | Admin | `pagina, tamanoPagina`    |
| DELETE | `/api/Sugerencia/{id}` | Eliminar sugerencia | Admin | -                         |

### Sanciones

| Método | Endpoint                           | Descripción                | Auth  | Body/Params                       |
|--------|------------------------------------|----------------------------|-------|-----------------------------------|
| POST   | `/api/Sancion`                     | Crear sanción              | Admin | `{ idUsuario, motivo, fechaFin }` |
| GET    | `/api/Sancion/usuario/{idUsuario}` | Ver sanciones de usuario   | Admin | -                                 |
| GET    | `/api/Sancion`                     | Listar todas las sanciones | Admin | `page, pageSize`                  |
| DELETE | `/api/Sancion/{id}`                | Eliminar sanción           | Admin | -                                 |

### Roles

| Método | Endpoint         | Descripción    | Auth  |
|--------|------------------|----------------|-------|
| GET    | `/api/Rols`      | Listar roles   | No    |
| GET    | `/api/Rols/{id}` | Obtener rol    | No    |
| POST   | `/api/Rols`      | Crear rol      | Admin |
| PATCH  | `/api/Rols/{id}` | Actualizar rol | -     |
| DELETE | `/api/Rols/{id}` | Eliminar rol   | -     |

### SignalR (Tiempo Real)

| Hub               | Endpoint                 | Descripción                          |
|-------------------|--------------------------|--------------------------------------|
| NotificacionesHub | `/Hub/NotificacionesHub` | Recibe notificaciones en tiempo real |

---

### Modelos de Datos Principales

#### Usuario
```json
{
  "id": 1,
  "userName": "string",
  "nombreCompleto": "string",
  "email": "string",
  "estado": true,
  "sancionado": false,
  "fechaRegistro": "2024-01-01T00:00:00Z",
  "nombreRol": "Usuario",
  "rolId": 2,
  "fotoPerfil": "byte[]"
}
```

#### LoginResponse
```json
{
  "usuario": { ...Usuario },
  "token": "jwt_token_string"
}
```

#### Libro (respuesta lista)
```json
{
  "id": 1,
  "titulo": "string",
  "autor": "string",
  "descripcion": "string",
  "portadaBase64": "string",
  "categorias": ["string"]
}
```

#### LibroDetalle
```json
{
  "id": 1,
  "titulo": "string",
  "autor": "string",
  "descripcion": "string",
  "promedioValoraciones": 4.5,
  "cantidadValoraciones": 10,
  "resenas": [...],
  "totalResenas": 5
}
```

#### EpubManifest
```json
{
  "titulo": "string",
  "autor": "string",
  "toc": [{ "titulo": "string", "href": "string" }],
  "readingOrder": [{ "href": "string", "type": "string" }]
}
```

#### PagedResult (respuesta paginada)
```json
{
  "page": 1,
  "pageSize": 10,
  "total": 100,
  "totalPages": 10,
  "data": [...]
}
```

---

## 2. ARQUITECTURA: FEATURE-FIRST

La arquitectura Feature-First organiza el código por **funcionalidades** en lugar de por capas. Cada feature contiene todo lo necesario para funcionar de manera independiente.

```
┌─────────────────────────────────────────────────────────┐
│                    FEATURES (Módulos)                  │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐ │
│  │  Auth   │ │  Libros │ │ Reader  │ │   Admin     │ │
│  │  - data │ │  - data │ │  - data │ │   - data   │ │
│  │  - logic│ │  - logic│ │  - logic│ │   - logic  │ │
│  │  - ui   │ │  - ui   │ │  - ui   │ │   - ui     │ │
│  └─────────┘ └─────────┘ └─────────┘ └─────────────┘ │
├─────────────────────────────────────────────────────────┤
│                      SHARED (Común)                    │
│  - Core (network, theme, utils, constants)             │
│  - Services (storage, signalr, connectivity)          │
│  - Routing                                            │
│  - DI Container                                       │
└─────────────────────────────────────────────────────────┘
```

**Stack**: Flutter + flutter_bloc (Cubit) + dio + get_it + go_router

### SessionCubit (Estado Global)

Se implementará un `SessionCubit` en la raíz de la aplicación para manejar el estado global de la sesión:

```dart
// shared/core/session/session_cubit.dart
class SessionCubit extends Cubit<SessionState> {
  final StorageService _storage;
  
  SessionCubit(this._storage) : super(SessionInitial());
  
  // Estados
  // - SessionInitial
  // - SessionLoading
  // - SessionAuthenticated(user, token)
  // - SessionUnauthenticated
  
  Future<void> checkSession() async { ... }
  Future<void> login(LoginResponse response) async { ... }
  Future<void> logout() async { ... }
  Future<void> updateUser(Usuario user) async { ... }
}
```

**Responsabilidades del SessionCubit:**
- Gestionar el usuario actualmente autenticado
- Almacenar y persistir el JWT token
- Determinar estado de autenticación (auth/unauth)
- Realizar logout global
- Verificar rol de administrador
- Sincronizar estado entre toda la app

## 3. ESTRUCTURA DE CARPETAS (FEATURE-FIRST)

```
lib/
├── features/                    # FEATURES (cada carpeta es un módulo independiente)
│   ├── auth/                   # AUTENTICACIÓN
│   │   ├── data/
│   │   │   ├── models/        # DTOs: login_request, login_response, user
│   │   │   ├── datasources/   # API calls
│   │   │   └── repositories/  # Implementación repository
│   │   ├── logic/
│   │   │   ├── cubit/         # AuthCubit, AuthState
│   │   │   └── usecases/      # Login, Register, Recovery
│   │   └── ui/
│   │       ├── pages/         # LoginPage, RegisterPage, RecoveryPage
│   │       └── widgets/       # Auth específicos
│   │
│   ├── libros/                # CATÁLOGO DE LIBROS
│   │   ├── data/
│   │   ├── logic/
│   │   └── ui/
│   │
│   ├── reader/                # LECTOR EPUB
│   │   ├── data/
│   │   │   ├── epub_parser.dart
│   │   │   └── reader_cache.dart
│   │   ├── logic/
│   │   │   ├── cubit/         # ReaderCubit, ReaderSettingsCubit
│   │   │   └── usecases/
│   │   └── ui/
│   │       ├── pages/         # ReaderPage
│   │       └── widgets/       # ReaderHeader, TOCSidebar, BookmarksSidebar, etc.
│   │
│   ├── biblioteca/           # BIBLIOTECA PERSONAL
│   ├── perfil/               # PERFIL DE USUARIO
│   ├── admin/                # PANEL ADMINISTRATIVO
│   │   ├── data/
│   │   ├── logic/
│   │   │   └── cubit/        # AdminUsersCubit, AdminBooksCubit, etc.
│   │   └── ui/
│   │       └── pages/        # Dashboard, GestionUsuarios, GestionLibros, etc.
│   │
│   └── notificaciones/       # NOTIFICACIONES
│
├── shared/                    # SHARED (recursos compartidos)
│   ├── core/                 # Configuraciones centrales
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── environment/
│   │   │   └── env.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── error_interceptor.dart
│   │   │   └── retry_interceptor.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── reader_theme.dart
│   │   ├── session/
│   │   │   ├── session_cubit.dart
│   │   │   ├── session_state.dart
│   │   │   └── session_repository.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       └── extensions.dart
│   │
│   ├── services/             # Servicios singleton
│   │   ├── storage_service.dart
│   │   ├── connectivity_service.dart
│   │   ├── signalr_service.dart
│   │   └── epub_download_service.dart
│   │
│   └── widgets/              # Widgets compartidos
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── loading_widget.dart
│       └── error_widget.dart
│
├── routing/                  # NAVEGACIÓN
│   ├── app_router.dart
│   ├── auth_guard.dart
│   ├── admin_guard.dart
│   └── routes.dart
│
└── injection_container.dart  # INYECCIÓN DE DEPENDENCIAS
```

### Estructura de una Feature

```
mi_feature/
├── data/                    # Capa de datos
│   ├── models/              # Modelos DTO (JSON serializable)
│   ├── datasources/         # Llamadas API específicas
│   └── repositories/        # Repositorio concreto
│
├── logic/                   # Lógica de negocio
│   ├── cubit/               # Cubits y Estados (flutter_bloc)
│   └── usecases/            # Casos de uso específicos
│
└── ui/                      # Capa de presentación
    ├── pages/               # Screens completas
    └── widgets/             # Widgets específicos de la feature
```

---

## 4. FLUJOS DE USUARIO

### Usuario Regular
1. Login/Registro → 2. Home (catálogo) → 3. Detalle libro → 4. Biblioteca/Reader

### Administrador
1. Login → 2. Dashboard Admin → 3. Gestión (usuarios/libros/categorías/denuncias)

---

## 5. MAPA DE CASOS DE USO → PANTALLAS MÓVILES

### Flujo USUARIO

| #  | Caso de Uso           | Pantalla Flutter      | Endpoint                                      |
|----|-----------------------|-----------------------|-----------------------------------------------|
| 1  | Login                 | `LoginPage`           | POST /api/Usuarios/Login                      |
| 2  | Registro              | `RegisterPage`        | POST /api/Usuarios/Register                   |
| 3  | Recuperar contraseña  | `RecoveryPage`        | POST /api/Usuarios/SolicitarRecuperacion      |
| 4  | Catálogo libros       | `HomePage`            | GET /api/Libros                               |
| 5  | Buscar libros         | `SearchPage`          | GET /api/Libros?query=                        |
| 6  | Filtrar por categoría | `FilterSheet`         | GET /api/Categorias                           |
| 7  | Detalle libro         | `BookDetailPage`      | GET /api/Libros/{id}/detalle                  |
| 8  | Valorar libro         | `RatingDialog`        | POST /api/Valoraciones                        |
| 9  | Escribir reseña       | `ReviewDialog`        | POST /api/Resenas                             |
| 10 | Agregar a biblioteca  | `BookDetailPage`      | POST /api/Biblioteca/{uid}/libros/{lid}       |
| 11 | Mi biblioteca         | `LibraryPage`         | GET /api/Biblioteca/{uid}/libros              |
| 12 | Leer libro (EPUB)     | `ReaderPage`          | GET /api/Libros/{id}/epub/manifest + resource |
| 13 | Configuración reader  | `ReaderSettingsPanel` | Local (SharedPreferences)                     |
| 14 | Marcadores            | `BookmarksSidebar`    | Local (SQLite)                                |
| 15 | Resaltados            | `HighlightMenu`       | Local (SQLite)                                |
| 16 | Historial             | `HistoryPage`         | GET /api/Historial/mis-libros                 |
| 17 | Mi perfil             | `ProfilePage`         | GET/PATCH /api/Usuarios/{id}                  |
| 18 | Crear denuncia        | `ReportDialog`        | POST /api/Denuncia                            |
| 19 | Crear sugerencia      | `SuggestionDialog`    | POST /api/Sugerencia                          |

### Flujo ADMINISTRADOR

| # | Caso de Uso          | Pantalla Flutter       | Endpoint                                          |
|---|----------------------|------------------------|---------------------------------------------------|
| 1 | Dashboard admin      | `AdminDashboardPage`   | GET /api/Usuarios, /api/Denuncia, /api/Sugerencia |
| 2 | Gestionar usuarios   | `AdminUsersPage`       | GET/DELETE /api/Usuarios                          |
| 3 | Gestionar libros     | `AdminBooksPage`       | GET/DELETE /api/Libros                            |
| 4 | Subir libro          | `AdminUploadBookPage`  | POST /api/Libros/upload                           |
| 5 | Gestionar categorías | `AdminCategoriesPage`  | CRUD /api/Categorias                              |
| 6 | Ver denuncias        | `AdminDenunciasPage`   | GET /api/Denuncia                                 |
| 7 | Ver sugerencias      | `AdminSugerenciasPage` | GET /api/Sugerencia                               |
| 8 | Gestionar sanciones  | `AdminSancionesPage`   | CRUD /api/Sancion                                 |
| 9 | Estadísticas         | `AdminStatsPage`       | Endpoints agregados                               |

---

## 6. LECTOR EPUB (Funcionalidades)

Basándose en el código React existente, estas son las funcionalidades a implementar:

### 6.1 Estados del Reader
```dart
class ReaderState {
  final String? bookId;
  final EpubManifest? manifest;
  final int currentIndex;
  final String? currentContent;
  final ReaderStatus status; // idle, loading, succeeded, failed
  final String? error;
  final Map<String, String> resourceCache;
}
```

### 6.2 Settings (persistidos localmente)
| Setting    | Valores              | Default |
|------------|----------------------|---------|
| fontSize   | 80-200%              | 100%    |
| lineHeight | 1.2, 1.5, 1.8, 2.0   | 1.6     |
| marginMode | narrow, normal, wide | normal  |
| theme      | light, dark, sepia   | light   |

### 6.3 Funcionalidades
- [ ] **Manifest**: Cargar índice del libro (readingOrder + TOC)
- [ ] **Navegación**: Siguiente/anterior capítulo, ir a índice
- [ ] **TOC Sidebar**: Mostrar tabla de contenidos
- [ ] **Bookmarks**: Crear, listar, eliminar, navegar
- [ ] **Highlights**: Seleccionar texto, elegir color, guardar, mostrar
- [ ] **Settings Panel**: Ajustes de visualización
- [ ] **Footer**: Indicador de progreso + slider
- [ ] **Caché**: Guardar capítulos descargados para offline
- [ ] **Progreso**: Sincronizar con backend (historial)

### 6.4 Colores de Resaltado
- Amarillo: `#FFEB3B`
- Verde: `#4CAF50`
- Azul: `#2196F3`
- Rosa: `#E91E63`
- Naranja: `#FF9800`

---

## 6.1 CONSIDERACIONES TÉCNICAS DEL EPUB READER

### 1. Estrategia de Renderizado

El sistema **no utilizará WebView ni librerías de renderizado HTML completas**.
Se implementará un **renderer propio de EPUB basado en Flutter Widgets**.

El flujo de procesamiento del contenido será:

```
EPUB Resource (HTML/XHTML)
        ↓
HTML Parser
        ↓
DOM Tree
        ↓
Renderer
        ↓
Flutter Widgets
```

Para el parsing del HTML se utilizará la librería:

```
html (pub.dev/html)
```

Esta librería permitirá convertir el contenido HTML/XHTML en un árbol DOM que posteriormente será transformado en widgets de Flutter.

---

### 2. Arquitectura del Renderer

El reader tendrá la siguiente arquitectura interna:

```
ReaderCubit
      ↓
ChapterLoader
      ↓
HTML Parser
      ↓
Node Tree
      ↓
Widget Renderer
```

Componentes:

**ReaderCubit**

Responsable del estado del reader:

* libro actual
* índice del capítulo
* contenido cargado
* navegación entre capítulos

**ChapterLoader**

Encargado de solicitar al backend los recursos EPUB:

```
GET /api/Libros/{id}/epub/manifest
GET /api/Libros/{id}/epub/resource?path={resource}
```

**HTML Parser**

Convierte el contenido HTML/XHTML en un DOM navegable.

**Widget Renderer**

Transforma los nodos HTML en widgets Flutter equivalentes.

Ejemplo de mapeo inicial:

| HTML       | Flutter               |
|------------|-----------------------|
| p          | Text                  |
| h1-h6      | Text con estilos      |
| img        | Image                 |
| strong     | TextStyle.bold        |
| em         | TextStyle.italic      |
| blockquote | Container con padding |

---

### 3. Resolución de Recursos Relativos

Los capítulos EPUB pueden contener referencias relativas a recursos como imágenes o estilos.

Ejemplo:

```
<img src="../images/img1.jpg">
<link rel="stylesheet" href="../styles/style.css">
```

El reader deberá resolver estas rutas para consumir correctamente la API:

```
/api/Libros/{id}/epub/resource?path=images/img1.jpg
```

Por lo tanto se implementará un **resolver de rutas relativas** que transforme las rutas internas del EPUB en rutas válidas para el endpoint de recursos.

---

### 4. Manejo de XHTML

Los archivos EPUB suelen utilizar **XHTML**, que puede contener atributos adicionales como:

```
epub:type
id
class
```

El renderer ignorará atributos no necesarios y procesará únicamente aquellos relevantes para el renderizado visual.

---

### 5. Estrategia de Renderizado para Rendimiento

Los capítulos EPUB pueden contener grandes cantidades de contenido.

Para evitar problemas de rendimiento:

* el contenido se dividirá en **bloques (párrafos o nodos principales)**
* se renderizará mediante:

```
ListView.builder
```

Esto permitirá que Flutter solo construya los widgets visibles en pantalla.

---

### 6. Cache de Recursos

Para evitar múltiples solicitudes HTTP y mejorar la experiencia de lectura se implementará un cache en memoria:

```
resourceCache
```

El cache almacenará:

* capítulos ya descargados
* imágenes cargadas
* recursos EPUB utilizados

Esto permitirá navegación entre capítulos sin latencia adicional.

---

### 7. Consideraciones de Memoria

Algunos EPUB pueden contener:

* capítulos grandes
* imágenes embebidas
* contenido base64

El renderer deberá manejar estos casos con cuidado para evitar consumo excesivo de memoria.

Las imágenes en base64 serán convertidas a `Uint8List` antes de renderizarse.

---

### 8. Alcance Inicial del Reader

Para la primera versión del reader se soportarán los siguientes elementos HTML:

* p
* h1–h6
* img
* strong
* em
* blockquote
* a

Elementos más complejos podrán agregarse en iteraciones futuras.

---

### 9. Estrategia de Navegación

El reader utilizará el `readingOrder` del `manifest` EPUB para navegar entre capítulos.

Ejemplo:

```
readingOrder:
  - chapter1.xhtml
  - chapter2.xhtml
  - chapter3.xhtml
```

La navegación cambiará el índice actual del capítulo dentro del `ReaderState`.

---

### 10. Dependencia para Parsing de HTML

El reader implementará un renderer propio, por lo tanto se requiere una librería para parsear HTML/XHTML y convertirlo a un árbol DOM.

Se usará la librería:

```
html: ^0.15.4
```

Esta librería permitirá convertir el contenido HTML/XHTML obtenido desde el endpoint:

```
GET /api/Libros/{id}/epub/resource?path={resource}
```

en una estructura DOM que posteriormente será transformada en widgets de Flutter.

---

### 11. Corrección: Progreso de Lectura

El progreso de lectura **no se sincronizará con el backend en esta versión**.

El progreso será **persistido únicamente de forma local**.

```
Progreso de lectura: Persistencia local únicamente (sin sincronización con backend)
```

El progreso podrá almacenarse en SQLite junto con bookmarks y highlights.

---

### 12. Estrategia de Renderizado por Bloques

Para evitar problemas de rendimiento en capítulos grandes, el reader utilizará una estrategia de **renderizado por bloques**.

En lugar de convertir todo el HTML en widgets inmediatamente, el capítulo se transformará primero en una lista de bloques estructurados.

Flujo:

```
HTML/XHTML capítulo
        ↓
HTML Parser
        ↓
DOM Tree
        ↓
Lista de bloques
        ↓
Renderer de bloques
        ↓
Flutter Widgets
```

Ejemplo de estructura interna:

```dart
class ReaderBlock {
  final String type;
  final dynamic content;
}
```

Ejemplo de bloques generados:

```dart
[
  ReaderBlock(type: "h1", content: "Capítulo 1"),
  ReaderBlock(type: "p", content: "Era una noche oscura..."),
  ReaderBlock(type: "p", content: "El viento soplaba..."),
  ReaderBlock(type: "img", content: "images/img1.jpg"),
]
```

Cada bloque representa una unidad de renderizado independiente.

---

### 13. Renderer por Bloques

El renderer convertirá cada bloque en widgets de Flutter mediante un componente especializado.

Ejemplo conceptual:

```dart
class BlockRenderer extends StatelessWidget {
  final ReaderBlock block;

  const BlockRenderer(this.block);

  @override
  Widget build(BuildContext context) {

    switch (block.type) {

      case "p":
        return Text(block.content);

      case "h1":
        return Text(
          block.content,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        );

      case "img":
        return Image.network(block.content);

      default:
        return SizedBox();
    }
  }
}
```

Esta arquitectura permite extender fácilmente el soporte de nuevos elementos HTML.

---

### 14. Paginación tipo Reader (sin scroll continuo)

El reader **no utilizará scroll vertical continuo** como en un navegador.

En su lugar se implementará un sistema de **paginación similar a lectores profesionales (Kindle, Apple Books, etc.)**.

Características:

* navegación por páginas
* gesto horizontal para cambiar página
* contenido dividido dinámicamente según tamaño de pantalla
* experiencia de lectura más cómoda

Flujo de renderizado:

```
Capítulo HTML
      ↓
Parser
      ↓
Bloques
      ↓
Layout Engine
      ↓
Páginas
      ↓
PageView
```

El widget principal será:

```dart
PageView
```

Cada página contendrá un subconjunto de bloques que caben en el viewport actual.

Esto permite:

* navegación por gestos horizontales
* menor consumo de memoria
* mejor experiencia de lectura
* renderizado eficiente en dispositivos móviles

---

### 15. Precarga de Capítulos

Para mejorar la experiencia del usuario, el reader precargará el siguiente capítulo.

Estrategia:

```
Capítulo actual
      ↓
Cargar capítulo
      ↓
Parsear y generar bloques
      ↓
Cache
```

Mientras el usuario lee un capítulo, el siguiente capítulo podrá descargarse y procesarse en segundo plano.

Esto permite transiciones instantáneas entre capítulos.

---

### 16. Ventajas de esta Arquitectura

La combinación de:

* parser HTML
* renderizado por bloques
* paginación con PageView
* layout incremental
* cache de capítulos

permite construir un reader escalable capaz de manejar capítulos grandes sin problemas de rendimiento.

Beneficios:

* menor consumo de memoria
* scroll/paginación fluida
* mejor rendimiento en dispositivos móviles
* arquitectura extensible
* experiencia de lectura similar a aplicaciones profesionales

---

### 17. Layout Incremental del Reader

Los capítulos EPUB pueden contener grandes cantidades de contenido HTML, que en algunos casos puede superar varios megabytes.

Renderizar o paginar todo el capítulo al mismo tiempo puede generar:

* alto consumo de memoria
* tiempos de carga largos
* bloqueos temporales de la interfaz
* lag al calcular páginas

Para evitar estos problemas, el reader implementará una estrategia de **Layout Incremental**.

---

#### 17.1 Concepto

El Layout Incremental consiste en **calcular y construir páginas progresivamente**, en lugar de generar el layout completo del capítulo.

Flujo:

```
HTML capítulo
      ↓
Parser
      ↓
Lista de bloques
      ↓
Generador de páginas
      ↓
PageView
```

El generador de páginas crea nuevas páginas **solo cuando el usuario se acerca a ellas**.

---

#### 17.2 Estrategia de generación de páginas

Las páginas se generarán dinámicamente utilizando una ventana de páginas activa.

Ejemplo:

```
Página actual: 10

Páginas cargadas en memoria:
8 | 9 | 10 | 11 | 12
```

Cuando el usuario avance:

```
Página actual: 11

Páginas cargadas:
9 | 10 | 11 | 12 | 13
```

Las páginas que quedan muy atrás se liberan de memoria.

Esto reduce significativamente el consumo de memoria en capítulos largos.

---

#### 17.3 Pipeline de generación

El sistema de layout tendrá el siguiente pipeline:

```
Blocks
  ↓
Layout Engine
  ↓
Page Builder
  ↓
Page Cache
  ↓
PageView
```

Componentes:

**Blocks**

Lista de bloques generados desde el parser HTML.

**Layout Engine**

Calcula cuánto contenido cabe en una página según:

* tamaño de pantalla
* tamaño de fuente
* lineHeight
* márgenes

**Page Builder**

Construye una página con los bloques que caben dentro del viewport.

**Page Cache**

Mantiene en memoria solo un conjunto reducido de páginas cercanas.

**PageView**

Widget encargado de la navegación horizontal entre páginas.

---

#### 17.4 Recalculo dinámico de páginas

Cuando el usuario cambie configuraciones del reader:

* tamaño de fuente
* lineHeight
* márgenes
* orientación del dispositivo

el layout se recalculará automáticamente.

Proceso:

```
Cambiar setting
      ↓
Invalidar páginas
      ↓
Recalcular layout
      ↓
Generar páginas nuevamente
```

Esto garantiza que el texto siempre se adapte correctamente al nuevo formato.

---

#### 17.5 Ventajas del Layout Incremental

Implementar layout incremental proporciona múltiples beneficios:

* manejo eficiente de capítulos muy grandes
* menor consumo de memoria
* menor tiempo de carga inicial
* navegación fluida entre páginas
* mejor experiencia en dispositivos de gama media

Esta técnica es utilizada en lectores profesionales como Kindle y Apple Books.

---

#### 17.6 Integración con el sistema de caché

El layout incremental trabajará junto con el sistema de cache del reader:

```
Cache de capítulos
        +
Cache de páginas
```

Esto permite:

* cargar rápidamente capítulos visitados
* mantener páginas cercanas en memoria
* reducir solicitudes repetidas al backend.

---

#### 17.7 Objetivo de la arquitectura

La combinación de:

* parser HTML
* renderizado por bloques
* paginación con PageView
* layout incremental
* cache de recursos

permitirá que el reader soporte capítulos grandes de EPUB con una experiencia de lectura fluida y estable.

---

## 7. CONFIGURACIÓN .ENV

```env
API_BASE_URL=http://localhost:7080
API_TIMEOUT=30000
SIGNALR_URL=http://localhost:7080/Hub/NotificacionesHub
```

### Implementación
```dart
// lib/core/environment/env.dart
class Env {
  static final Env _instance = Env._internal();
  factory Env() => _instance;
  Env._internal();
  
  late String apiBaseUrl;
  late int apiTimeout;
  late String signalrUrl;
  
  void init() {
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:7080';
    // ...
  }
}
```

---

## 8. ESTRATEGIA OFFLINE (Solo Lectura Descargada)

### SQLite Tables
```sql
-- Reader cache
CREATE TABLE reader_cache (
  book_id TEXT PRIMARY KEY,
  manifest_json TEXT,
  chapters_json TEXT
);

-- Bookmarks
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY,
  book_id TEXT,
  chapter_index INTEGER,
  title TEXT,
  created_at INTEGER
);

-- Highlights
CREATE TABLE highlights (
  id INTEGER PRIMARY KEY,
  book_id TEXT,
  chapter_index INTEGER,
  text TEXT,
  color TEXT,
  created_at INTEGER
);
```

---

## 9. ESTRATEGIA DE NOTIFICACIONES

### SignalR (Backend)
```dart
// services/signalr_service.dart
class SignalRService {
  HubConnection? _hub;
  
  Future<void> connect(String token) async {
    _hub = HubConnectionBuilder()
      .withUrl('${Env().signalrUrl}')
      .withAutomaticReconnect()
      .build();
    
    await _hub!.start();
    
    _hub!.on('Notificacion', (message) {
      // Handle notification
    });
  }
}
```

### Notificaciones Locales
Usar Flutter Local Notifications para:
- Recordatorio de lectura
- Notificaciones desde SignalR

### Casos de Uso
| Notificación              | Origen  | Tipo       |
|---------------------------|---------|------------|
| Nueva sanción             | SignalR | Push       |
| Nueva sugerencia aceptada | SignalR | Push       |
| Recordatorio de lectura   | Local   | Programada |

---

## 10. PLAN DE DESARROLLO (FASES)

### Fase 1: Setup (Semana 1)
- [ ] Proyecto Flutter creado
- [ ] Dependencias configuradas
- [ ] Estructura Feature-First
- [ ] Variables de entorno (.env)
- [ ] Theme base (light/dark)
- [ ] Routing con GoRouter
- [ ] Inyección de dependencias (GetIt)

### Fase 2: Autenticación (Semana 1-2)
- [ ] Modelos Auth
- [ ] API Client con interceptors
- [ ] Login + Registro + Recuperación
- [ ] Persistencia JWT (SecureStorage)
- [ ] Auth Cubit/Bloc
- [ ] Guards de ruta

### Fase 3: Catálogo de Libros (Semana 2-3)
- [ ] Modelos Libro
- [ ] API: Lista, búsqueda, filtros
- [ ] Home Page con grid
- [ ] Search Page
- [ ] Book Detail Page
- [ ] Valoraciones + Reseñas

### Fase 4: Biblioteca + Perfil (Semana 3)
- [ ] Agregar/Quitar de biblioteca
- [ ] Mi Biblioteca
- [ ] Historial de lectura
- [ ] Perfil de usuario
- [ ] Editar perfil

### Fase 5: LECTOR EPUB - CORE (Semana 4)
- [ ] Estructura de carpetas feature reader
- [ ] Modelos: EpubManifest, ReaderSettings
- [ ] Data layer: EpubDataSource, EpubRepository
- [ ] ReaderCubit: carga manifest, navegación capítulos
- [ ] ReaderSettingsCubit: configuraciones
- [ ] Parser HTML → Widgets (soporte: p, h1-h6, img, strong, em, blockquote, a)
- [ ] ReaderPage básica con PageView
- [ ] Navegación: siguiente/anterior capítulo

### Fase 5.1: LECTOR EPUB - UI COMPLETA (Semana 4)
- [ ] Header: título libro, botón TOC, botón settings
- [ ] TOC Sidebar: tabla de contenidos
- [ ] Settings Panel: fontSize (80-200%), lineHeight (1.2-2.0), marginMode (narrow/normal/wide), theme (light/dark/sepia)
- [ ] Reader Footer: indicador de progreso + slider
- [ ] Tocar centro para mostrar/ocultar UI
- [ ] Gesture horizontal para cambiar página

### Fase 5.2: LECTOR EPUB - AVANZADO (Semana 5)
- [ ] Resolución de rutas relativas (../images/)
- [x] Cache en memoria de capítulos
- [x] Precarga de siguiente capítulo
- [ ] Layout incremental (generación dinámica de páginas)
- [ ] Recalculo de páginas al cambiar settings

### Fase 5.3: LECTOR EPUB - BOOKMARKS (Semana 5)
- [x] Modelo Bookmark
- [x] Crear marcador desde capítulo actual
- [x] Sidebar de marcadores (integrado con índice)
- [x] Eliminar marcador
- [x] Navegar a marcador
- [x] Persistencia de marcadores

### Fase 5.4: LECTOR EPUB - HIGHLIGHTS (Semana 5)
- [ ] Modelo Highlight
- [ ] Colores: Amarillo, Verde, Azul, Rosa, Naranja
- [ ] Guardar highlight con color
- [ ] Mostrar highlights en texto
- [ ] Eliminar highlight
- [ ] Persistencia SQLite de highlights

### Fase 6: Notificaciones (Semana 5)
- [ ] SignalR Service
- [ ] Conexión en background
- [ ] Manejo de notificaciones
- [ ] Notificaciones locales

### Fase 7: Flujo Administrador (Semana 5-6)
- [ ] Dashboard Admin
- [ ] Gestión de usuarios
- [ ] Gestión de libros (upload)
- [ ] Gestión de categorías
- [ ] Denuncias y sugerencias
- [ ] Sanciones

### Fase 8: Offline + Testing (Semana 6)
- [ ] SQLite setup
- [ ] Cache lectura offline (capítulos)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Optimizaciones

---

## 11. DEPENDENCIAS RECOMENDADAS

```yaml
dependencies:
  flutter_bloc: ^8.1.3        # Estado (Cubit/BLoC)
  dio: ^5.3.0                 # HTTP client
  get_it: ^7.6.4              # Inyección de dependencias
  go_router: ^12.1.1          # Navegación
  shared_preferences: ^2.2.2  # Local storage simple
  flutter_secure_storage: ^9.0.0  # Token seguro
  cached_network_image: ^3.3.0  # Imágenes
  json_annotation: ^4.8.1    # JSON
  equatable: ^2.0.5           # Comparación de estados
  sqflite: ^2.3.0            # SQLite (offline)
  path_provider: ^2.1.1      # Rutas de archivos
  flutter_local_notifications: ^14.0.0  # Notificaciones locales
  connectivity_plus: ^5.0.0  # Estado de red
  html: ^0.15.4             # Parser HTML para EPUB Reader
  
dev_dependencies:
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0
```

---

## 12. PLAN DETALLADO FASE 5: LECTOR EPUB

### Fase 5.0: CORE - Estructura Base

#### Archivos a crear:
```
lib/features/reader/
├── data/
│   ├── models/
│   │   ├── epub_manifest.dart
│   │   └── reader_settings.dart
│   ├── datasources/
│   │   └── epub_datasource.dart
│   └── repositories/
│       └── epub_repository.dart
├── logic/
│   └── cubit/
│       ├── reader_cubit.dart
│       └── reader_settings_cubit.dart
└── ui/
    ├── pages/
    │   └── reader_page.dart
    └── widgets/
        └── chapter_content.dart
```

#### Implementación:

**1. epub_manifest.dart**
```dart
class EpubManifest {
  final String titulo;
  final String autor;
  final List<TocItem> toc;
  final List<String> readingOrder;
}

class TocItem {
  final String titulo;
  final String href;
}
```

**2. reader_settings.dart**
```dart
class ReaderSettings {
  final double fontSize;     // 0.8 - 2.0 (80% - 200%)
  final double lineHeight;    // 1.2, 1.5, 1.8, 2.0
  final String marginMode;   // narrow, normal, wide
  final String theme;        // light, dark, sepia
  
  // Valores por defecto
  static const defaultSettings = ReaderSettings(
    fontSize: 1.0,
    lineHeight: 1.6,
    marginMode: 'normal',
    theme: 'light',
  );
}
```

**3. epub_datasource.dart**
```dart
class EpubDataSource {
  // GET /api/Libros/{id}/epub/manifest
  Future<EpubManifest> getManifest(int libroId);
  
  // GET /api/Libros/{id}/epub/resource?path={path}
  Future<String> getResource(int libroId, String path);
}
```

**4. reader_cubit.dart**
```dart
// Estados
- ReaderInitial
- ReaderLoading  
- ReaderLoaded(manifest, currentIndex, content)
- ReaderError(message)

// Métodos
- cargarLibro(libroId)
- cargarCapitulo(index)
- siguienteCapitulo()
- capituloAnterior()
- irACapitulo(index)
```

**5. epub_parser.dart**
```dart
class EpubParser {
  // Convierte HTML → List<ReaderBlock>
  // Soporte: p, h1-h6, img, strong, em, blockquote, a
  List<ReaderBlock> parse(String html);
}

class ReaderBlock {
  final String type;  // p, h1, h2, img, etc.
  final dynamic content;
}
```

**6. reader_page.dart**
```dart
// PageView con paginación
// Carga manifest al iniciar
// Muestra capítulo actual
// Gesture horizontal para navegación
```

---

### Fase 5.1: UI COMPLETA

#### Archivos a crear/actualizar:
```
lib/features/reader/
├── ui/
│   ├── pages/
│   │   └── reader_page.dart        (actualizar)
│   └── widgets/
│       ├── reader_header.dart      (nuevo)
│       ├── toc_sidebar.dart       (nuevo)
│       ├── settings_panel.dart    (nuevo)
│       └── reader_footer.dart     (nuevo)
```

#### Implementación:

**1. reader_header.dart**
- Título del libro
- Botón TOC (abre sidebar)
- Botón Settings (abre bottom sheet)
- Botón volver

**2. toc_sidebar.dart**
- Slide-in desde izquierda
- Lista de capítulos (del manifest.toc)
- Al tocar → navegar a capítulo

**3. settings_panel.dart**
- Bottom sheet con:
  - **FontSize**: Slider 80%-200%
  - **LineHeight**: Opción (1.2, 1.5, 1.8, 2.0)
  - **Margin**: Opción (narrow, normal, wide)
  - **Theme**: Opción (light, dark, sepia)
- Persiste en SharedPreferences

**4. reader_footer.dart**
- "Capítulo X de Y"
- Slider de progreso
- Al cambiar → navegar a capítulo

**5. reader_page.dart (actualizar)**
- Integrar header, content, footer
- Tocar centro → mostrar/ocultar UI
- Gesture horizontal → siguiente/anterior página

---

### Fase 5.2: AVANZADO

#### Mejoras técnicas:

**1. Resolución de rutas relativas**
```dart
// Transforma: ../images/img1.jpg
// Hacia: api/Libros/{id}/epub/resource?path=images/img1.jpg
String resolveRelativePath(String relativePath, String currentPath);
```

**2. Cache en memoria**
```dart
class ChapterCache {
  final Map<String, String> _cache = {};
  
  String? get(String path);
  void put(String path, String content);
  void clear();
}
```

**3. Precarga de capítulo**
```dart
// Mientras lee capítulo actual, descarga siguiente en background
Future<void> precargarSiguiente();
```

**4. Layout incremental**
```dart
// Genera páginas dinámicamente
// Solo construye las visibles en viewport
class PageGenerator {
  List<Widget> generatePages(List<ReaderBlock> blocks, Size viewport);
}
```

**5. Recalculo de páginas**
```dart
// Cuando cambia settings → recalcular páginas
void onSettingsChanged(ReaderSettings settings);
```

---

### Fase 5.3: BOOKMARKS

#### Modelo:
```dart
class Bookmark {
  final int id;
  final int bookId;
  final int chapterIndex;
  final String title;
  final DateTime createdAt;
}
```

#### Implementación:

**1. SQLite Table**
```sql
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER,
  chapter_index INTEGER,
  title TEXT,
  created_at INTEGER
);
```

**2. ReaderCubit (agregar métodos)**
```dart
- crearBookmark(titulo)
- eliminarBookmark(id)
- getBookmarks(bookId)
- navegarABookmark(bookmark)
```

**3. bookmarks_sidebar.dart**
- Lista de marcadores del libro actual
- Al tocar → navegar al capítulo
- Swipe para eliminar

---

### Fase 5.4: HIGHLIGHTS

#### Modelo:
```dart
class Highlight {
  final int id;
  final int bookId;
  final int chapterIndex;
  final String text;
  final String color;  // #FFEB3B, #4CAF50, #2196F3, #E91E63, #FF9800
  final DateTime createdAt;
}
```

#### Colores disponibles:
| Color   | Hex       |
|---------|-----------|
| Amarillo | #FFEB3B |
| Verde   | #4CAF50  |
| Azul    | #2196F3  |
| Rosa    | #E91E63  |
| Naranja | #FF9800  |

#### Implementación:

**1. SQLite Table**
```sql
CREATE TABLE highlights (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER,
  chapter_index INTEGER,
  text TEXT,
  color TEXT,
  created_at INTEGER
);
```

**2. ReaderCubit (agregar métodos)**
```dart
- crearHighlight(texto, color)
- eliminarHighlight(id)
- getHighlights(bookId, chapterIndex)
```

**3. highlight_menu.dart**
- Al seleccionar texto → mostrar menú
- Elegir color
- Guardar highlight

**4. chapter_content.dart (actualizar)**
- Renderizar highlights con BackgroundColor
- Al tocar highlight → opciones (eliminar)

---

## 13. SECURITY

- No guardar passwords localmente
- Usar HTTPS siempre
- Limpiar datos sensibles en logout
- Token en SecureStorage (no SharedPreferences)
- Validar certificados SSL

---

*Documento generado para el desarrollo de la aplicación móvil OpenBooks*
