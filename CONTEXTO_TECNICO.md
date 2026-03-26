# Contexto Técnico - Open Books Mobile

Guía técnica para desarrolladores del proyecto Open Books Mobile.

---

## Índice

1. Contexto del Sistema
2. Endpoints del Backend
3. Motivos de Denuncia (Reseñas)
4. Arquitectura y Estructura de Carpetas
5. Reglas del Proyecto
6. Flujo de Ejecución y Casos de Uso
7. Puntos Críticos
8. Workflow Git
9. Testing
10. Configuración y Entorno
11. Manejo de Errores y Logging
12. Mejoras Futuras
13. Glosario

---

## 1. Contexto del Sistema

### Stack Tecnológico

| Componente                 | Tecnología            | Versión |
| -------------------------- | ---------------------- | -------- |
| Framework                  | Flutter                | 3.x      |
| Lenguaje                   | Dart                   | 3.x      |
| Estado                     | flutter_bloc (Cubit)   | ^8.x     |
| HTTP Client                | Dio                    | ^5.x     |
| Inyección de Dependencias | get_it                 | ^7.x     |
| Navegación                | go_router              | ^14.x    |
| Almacenamiento Seguro      | flutter_secure_storage | ^9.x     |
| Variables de Entorno       | flutter_dotenv         | ^5.x     |
| Comunicación Real-time    | signalr_client         | ^3.x     |

### API Backend

- **Base URL**: Configurable via `.env` (default: `http://10.0.2.2:5201` para emuladores Android)
- **Autenticación**: JWT Bearer Token
- **Protocolo**: REST API + SignalR para notificaciones

---

## 2. Endpoints del Backend

### Auth

- `POST /api/Usuarios/Register` - Registro de usuario
- `POST /api/Usuarios/Login` - Login
- `POST /api/Usuarios/SolicitarRecuperacion` - Solicitar recuperación de contraseña
- `POST /api/Usuarios/ResetearContrasena` - Resetear contraseña

### Usuarios

- `GET /api/Usuarios` - Listar usuarios (paginado, admin)
- `GET /api/Usuarios/{id}` - Obtener usuario por ID
- `PATCH /api/Usuarios/{id}` - Actualizar usuario
- `POST /api/Usuarios` - Crear usuario (admin)
- `DELETE /api/Usuarios/{id}` - Eliminar usuario (admin)

### Libros

- `GET /api/Libros` - Listar libros (con filtros: query, page, pageSize, categorias, autor)
- `GET /api/Libros/{id}` - Descargar archivo EPUB del libro
- `GET /api/Libros/{id}/portada` - Obtener portada
- `GET /api/Libros/{id}/detalle` - Obtener detalle del libro (con reseñas y valoraciones)
- `GET /api/Libros/{id}/epub/manifest` - Obtener manifest EPUB
- `GET /api/Libros/{id}/epub/resource` - Obtener recurso EPUB
- `GET /api/Libros/{id}/descargar` - Descargar libro (usuario autenticado)
- `POST /api/Libros/upload` - Subir libro (admin)
- `PATCH /api/Libros/{id}` - Actualizar libro (admin)
- `DELETE /api/Libros/{id}` - Eliminar libro (admin)

### Valoraciones

- `POST /api/Valoraciones` - Crear/actualizar valoración
- `PUT /api/Valoraciones` - Actualizar valoración
- `DELETE /api/Valoraciones?idLibro={id}` - Eliminar valoración
- `GET /api/Valoraciones/libro/{idLibro}` - Obtener valoraciones de un libro
- `GET /api/Valoraciones/top5` - Obtener top 5 libros valorados

### Resenas

- `POST /api/Resenas` - Crear reseña
- `PUT /api/Resenas/{idResena}` - Actualizar reseña
- `DELETE /api/Resenas/{idResena}` - Eliminar reseña
- `GET /api/Resenas/libro/{idLibro}` - Obtener reseñas de un libro (paginado)
- `GET /api/Resenas` - Obtener todas las reseñas (paginado)

### Denuncias

- `POST /api/Denuncia` - Crear denuncia (usuario autenticado)
- `GET /api/Denuncia` - Listar denuncias (solo admin, paginado)
- `DELETE /api/Denuncia/{id}` - Eliminar denuncia (solo admin)

### Biblioteca

- `GET /api/Biblioteca/{usuarioId}/libros` - Obtener libros del usuario (paginado)
- `POST /api/Biblioteca/{usuarioId}/libros/{libroId}` - Agregar libro a biblioteca
- `DELETE /api/Biblioteca/{usuarioId}/libros/{libroId}` - Eliminar libro de biblioteca

### Historial

- `GET /api/Historial/mis-libros` - Obtener historial de lectura del usuario

### Categorias

- `GET /api/Categorias` - Listar categorías (paginado)
- `GET /api/Categorias/{id}` - Obtener categoría por ID
- `POST /api/Categorias` - Crear categoría (admin)
- `PATCH /api/Categorias/{id}` - Actualizar categoría (admin)
- `DELETE /api/Categorias/{id}` - Eliminar categoría (admin)

### Sugerencias

- `POST /api/Sugerencia` - Crear sugerencia (usuario autenticado)
- `GET /api/Sugerencia` - Listar sugerencias (solo admin, paginado)
- `DELETE /api/Sugerencia/{id}` - Eliminar sugerencia (solo admin)

### Sanciones

- `POST /api/Sancion` - Crear sanción (admin)
- `GET /api/Sancion/usuario/{idUsuario}` - Obtener sanciones de un usuario
- `GET /api/Sancion` - Listar todas las sanciones (paginado, admin)
- `DELETE /api/Sancion/{id}` - Eliminar sanción (admin)

### Roles

- `GET /api/Rols` - Listar roles
- `GET /api/Rols/{id}` - Obtener rol por ID
- `POST /api/Rols` - Crear rol (admin)
- `PATCH /api/Rols/{id}` - Actualizar rol
- `DELETE /api/Rols/{id}` - Eliminar rol

---

## 3. Motivos de Denuncia (Reseñas)

- Contenido inapropiado
- Spam o publicidad
- Lenguaje ofensivo o abusivo
- Información falsa o engañosa
- No relacionado con el libro
- Otro (con descripción opcional)

---

## 4. Arquitectura y Estructura de Carpetas

### Patrón de Arquitectura

```
UI Layer → Logic Layer → Data Layer → Core Layer
```

### Estructura de Carpetas

```
open_books_mobile/lib/
├── main.dart
├── injection_container.dart
├── routing/app_router.dart
├── features/
│   ├── auth/
│   ├── libros/
│   ├── biblioteca/
│   ├── perfil/
│   ├── historial/
│   ├── reader/
│   ├── notifications/
│   ├── settings/
│   └── admin/
├── shared/
│   ├── core/
│   ├── services/
│   └── ui/widgets/
└── test/
```

### Convenciones de Naming

| Elemento            | Convención | Ejemplo             |
| ------------------- | ----------- | ------------------- |
| Archivos Dart       | snake_case  | `auth_cubit.dart` |
| Clases              | PascalCase  | `AuthCubit`       |
| Variables/Funciones | camelCase   | `authRepository`  |
| Estados de Cubit    | PascalCase  | `AuthLoading`     |
| Rutas               | kebab-case  | `/book-detail`    |

---

## 5. Reglas del Proyecto

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

### Inyección de Dependencias

- Usar `registerLazySingleton` para servicios y repositorios compartidos
- Usar `registerFactory` para Cubits
- Inyectar dependencias vía constructor

### Formato de Commits

`<tipo>(<scope>): <descripción>`

Tipos: `feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`

---

## 6. Flujo de Ejecución y Casos de Uso

### Flujo de Arranque

```
main.dart → Env.init() → setupDependencies() → runApp() → AppRouter
```

### Flujo de Autenticación

```
LoginPage → AuthCubit.login() → AuthRepository → SessionCubit → AppRouter redirect
```

### Flujo de Catálogo de Libros

```
HomePage → LibrosCubit.loadLibros() → Repository → HomePage rebuild
```

### Flujo de Detalle de Libro

```
BookDetailPage → LibroDetalleCubit.load() → Repository → BookDetailPage
```

### Flujo de Lectura

```
ReaderPage → ReaderCubit.load() → EpubRepository → ReaderPage
```

---

## 7. Puntos Críticos

### Gestión de Tokens y Sesión

- Ubicación: `shared/core/session/`
- Usar `SessionCubit.login()` y `SessionCubit.logout()`

### Parsing de EPUB

- Ubicación: `features/reader/ui/widgets/epub_parser.dart`
- Manejar codificaciones UTF-8, ISO-8859-1

### SignalR para Notificaciones

- Ubicación: `shared/services/signalr_service.dart`
- Implementar reconexión al volver a foreground

### Sistema de Roles

- Verificar rol en backend para operaciones sensibles

### Descarga de EPUB

- Cancelar descargas si el usuario sale de la página

---

## 8. Workflow Git

### Ramas

```
main
├── feature/
├── fix/
├── refactor/
└── docs/
```

### Proceso de Contribución

1. Crear rama desde `main`
2. Desarrollar y hacer commits
3. Mantener `main` actualizada (rebase)
4. Push y crear PR

---

## 9. Testing

### Ejecutar Tests

```bash
flutter test
flutter test test/features/auth/
flutter test --coverage
```

### Unit Testing (Cubits)

```dart
blocTest<AuthCubit, AuthState>(
  'emits [Loading, LoginSuccess] when login succeeds',
  build: () => AuthCubit(authRepository: mockAuthRepo),
  act: (cubit) => cubit.login('test@test.com', 'password'),
  expect: () => [isA<AuthLoading>(), isA<AuthLoginSuccess>()],
);
```

---

## 10. Configuración y Entorno

### Variables de Entorno (.env)

```env
API_BASE_URL=http://10.0.2.2:5201
API_TIMEOUT=30000
SIGNALR_URL=http://10.0.2.2:5201/Hub/NotificacionesHub
```

### URLs por Entorno

| Entorno                       | URL Base                      |
| ----------------------------- | ----------------------------- |
| Desarrollo Android (Emulador) | `http://10.0.2.2:5201`      |
| Desarrollo Android (Físico)  | `http://<IP_LOCAL>:5201`    |
| Desarrollo iOS (Simulator)    | `http://localhost:5201`     |
| Producción                   | `https://api.openbooks.com` |

### AndroidManifest

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true" ...>
```

---

## 11. Manejo de Errores y Logging

### Jerarquía de Excepciones

```
ServerException
NetworkException
AuthException
CacheException
ValidationException
```

### Jerarquía de Failures

```
ServerFailure
NetworkFailure
AuthFailure
CacheFailure
ValidationFailure
```

### Errores de API Comunes

| Código | Significado   | Acción                            |
| ------- | ------------- | ---------------------------------- |
| 400     | Bad Request   | Mostrar errores de validación     |
| 401     | Unauthorized  | Limpiar sesión, redirigir a login |
| 403     | Forbidden     | Mostrar "No tienes permiso"        |
| 404     | Not Found     | Mostrar "Recurso no encontrado"    |
| 500     | Server Error  | Mostrar "Error del servidor"       |
| 0       | No Connection | Mostrar "Sin conexión"            |

---

## 12. Mejoras Futuras

### Prioridad Alta

- Sistema de Offline
- Sync de Progreso
- Tests E2E
- Dark Mode Completo

### Prioridad Media

- Búsqueda Offline
- Notificaciones Push
- Analytics
- Crash Reporting

### Prioridad Baja

- Web Support
- Escritorio
- Importar EPUB

---

## 13. Glosario

| Término   | Definición                               |
| ---------- | ----------------------------------------- |
| Cubit      | Implementación simplificada de BLoC      |
| Feature    | Módulo funcional de la aplicación       |
| DI         | Inyección de Dependencias                |
| Repository | Abstracción que oculta el datasource     |
| Datasource | Fuente de datos (API, BD local)           |
| State      | Estado inmutable que representa la UI     |
| Failure    | Representación de un error en el dominio |
| Exception  | Error a nivel de infraestructura          |
| SignalR    | Comunicación en tiempo real              |
| EPUB       | Formato estándar de libros electrónicos |

---

*Última actualización: 2026-03-26*
