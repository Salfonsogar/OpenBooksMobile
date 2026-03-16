# Open Books Mobile 📚

Una aplicación móvil para gestionar y leer tus libros favoritos, desarrollada con Flutter.

## ¿Qué es?

Open Books Mobile te permite:

- Explorar un catálogo de libros
- Buscar libros por título, autor o categoría
- Ver detalles de cada libro
- Valorar y dejar reseñas de libros
- Gestionar tu cuenta de usuario

## Características

- 📖 **Catálogo**: Explora libros por categorías
- 🔍 **Búsqueda**: Encuentra libros fácilmente
- ⭐ **Valoraciones**: Califica libros del 1 al 5
- 📝 **Reseñas**: Escribe y lee opiniones de otros usuarios

## Requisitos

- Flutter SDK 3.x
- Dart 3.x
- Android Studio o VS Code

## Instalación

1. Clona el repositorio
2. Ejecuta `flutter pub get`
3. Configura las variables de entorno en `lib/shared/core/environment/env.dart`
4. Ejecuta `flutter run`

## Estructura del Proyecto

```
lib/
├── features/                  # Funcionalidades de la app
│   ├── auth/                  # Autenticación de usuarios
│   │   ├── data/              # Modelos, repositorios, datasources
│   │   ├── logic/             # Cubits para estado
│   │   └── ui/                # Páginas y widgets
│   └── libros/               # Gestión de libros
│       ├── data/              # Modelos, repositorios, datasources
│       ├── logic/             # Cubits para estado
│       └── ui/                # Páginas y widgets
├── shared/
│   └── core/                  # Configuraciones compartidas
│       ├── constants/         # Constantes de la app
│       ├── environment/       # Variables de entorno
│       ├── errors/            # Manejo de errores
│       ├── network/           # Cliente API
│       ├── session/           # Gestión de sesión
│       └── theme/             # Temas y estilos
├── injection_container.dart   # Inyección de dependencias
├── main.dart                  # Punto de entrada
└── routing/                   # Configuración de rutas
```

## Tecnologías

- **Flutter** - Framework de UI
- **Dart** - Lenguaje de programación
- **flutter_bloc** - Gestión de estado
- **dio** - Cliente HTTP
- **get_it** - Inyección de dependencias

## Licencia

MIT License
