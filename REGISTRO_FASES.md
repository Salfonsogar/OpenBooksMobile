# Registro de Fases del Proyecto OpenBooks

## Información General del Proyecto

| Aspecto | Detalle |
|---------|---------|
| **Nombre del Proyecto** | OpenBooks |
| **Aplicación** | Plataforma de lectura de libros electrónicos |
| **Frontend** | Flutter (Antigravity) - App móvil multiplataforma |
| **Backend** | .NET 8 (C#) - API REST |
| **Base de Datos** | SQL Server |
| **Estado** | En desarrollo |

---

## Resumen de Fases

| Fase | Descripción | Tiempo Estimado | Estado |
|------|-------------|-----------------|--------|
| **1. Análisis** | Investigación, requisitos y planificación | 3 semanas | ✅ Completada |
| **2. Diseño** | Arquitectura, modelos y prototipos | 4 semanas | ✅ Completada |
| **3. Desarrollo** | Implementación de código | 12 semanas | ✅ En curso |
| **4. Pruebas** | Testing unitario, integración y UX | 4 semanas | ⏳ Pendiente |
| **5. Despliegue** | Publicación en tiendas | 2 semanas | ⏳ Pendiente |

---

## Fase 1: Análisis

### Objetivos
- Definir el alcance del proyecto
- Identificar requisitos funcionales y no funcionales
- Analizar el mercado y competidores
- Determinar tecnologías a utilizar

### Actividades Realizadas

#### Análisis de Requisitos

**Requisitos Funcionales:**
- Registro e inicio de sesión de usuarios
- Catálogo de libros con búsqueda y filtros
- Detalle de libro (sinopsis, reseñas, valoraciones)
- Biblioteca personal del usuario
- Sistema de lectura de EPUB
- Sistema de resaltado de texto (5 colores)
- Historial de lectura con progreso
- Perfil de usuario editable
- Subida de libros por usuarios
- Panel de administración (gestión de libros, usuarios, categorías)
- Sistema de denuncias y sanciones
- Sugerencias de usuarios
- Notificaciones en tiempo real

**Requisitos No Funcionales:**
- Interfaz adaptativa (tema claro/oscuro)
- Rendimiento optimizado para lectura
- Seguridad en autenticación (JWT)
- Base de datos relacional (SQL Server)

#### Análisis Tecnológico

| Componente | Tecnología Elegida | Justificación |
|------------|-------------------|---------------|
| Frontend | Flutter | Multiplataforma (iOS/Android), widgets nativos |
| Backend | .NET 8 | Framework robusto, Entity Framework |
| Base de Datos | SQL Server | Integración con .NET, escalabilidad |
| Autenticación | JWT + Identity | Estándar industria, seguridad |
| Estado | Flutter Bloc | Separación clara de lógica y UI |
| Navegación | GoRouter | Manejo declarative de rutas |
| Notificaciones | SignalR | Tiempo real, bidireccional |

#### Análisis de Mercado
- Estudio de apps existentes (Wattpad, Webtoon, Storytel)
- Identificación de funcionalidades diferenciadoras:
  - Sistema de resaltado de texto
  - Subida de libros por usuarios
  - Moderación de contenido

### Entregables Fase 1
- Documento de requisitos funcionales
- Documento de requisitos no funcionales
- Matriz de trazabilidad
- Estimación de esfuerzo

### Tiempo Total Fase 1
**3 semanas** (Octubre 2025)

---

## Fase 2: Diseño

### Objetivos
- Diseñar arquitectura del sistema
- Crear modelo de datos
- Diseñar interfaces de usuario
- Definir estructura del código

### Actividades Realizadas

#### Diseño de Arquitectura

**Arquitectura Backend:**
```
┌─────────────────────────────────────────────────────┐
│                  API REST (.NET 8)                  │
├─────────────────────────────────────────────────────┤
│  Controllers → Services → Repositories → EF Core  │
│       ↓                                            │
│   SignalR Hub (Notificaciones en tiempo real)     │
└─────────────────────────────────────────────────────┘
```

**Arquitectura Frontend:**
```
┌─────────────────────────────────────────────────────┐
│              FLUTTER APP                            │
├─────────────────────────────────────────────────────┤
│  UI Layer (Pages, Widgets)                         │
│       ↓                                            │
│  BLoC Layer (Cubits, States)                      │
│       ↓                                            │
│  Data Layer (Repositories, DataSources, Models)   │
└─────────────────────────────────────────────────────┘
```

#### Diseño de Modelo de Datos

**Entidades Principales:**
- Usuario (Identity)
- Rol
- Libro
- Categoría (N:M con Libro)
- BibliotecaUsuario
- BibliotecaLibro
- HistorialLectura
- Resena
- Valoracion
- Denuncia
- Sancion
- Sugerencia
- Marcador
- Resaltador

#### Diseño de Interfaces

**Pantallas del Frontend:**
1. Login/Registro
2. Home (catálogo de libros)
3. Búsqueda avanzada
4. Detalle de libro
5. Lector EPUB
6. Biblioteca personal
7. Historial de lectura
8. Perfil de usuario
9. Configuración
10. Panel Admin (Dashboard, Libros, Categorías, Usuarios, Moderación)

#### Diseño de Componentes Reutilizables
- SearchHeader
- CloseHeader
- AdminHeader
- HighlightMenu
- EpubParser
- FilterSheet
- RatingDialog

### Entregables Fase 2
- Diagrama UML de arquitectura
- Modelo de datos completo
- Mockups de interfaces principales
- Estructura de carpetas del proyecto

### Tiempo Total Fase 2
**4 semanas** (Noviembre 2025)

---

## Fase 3: Desarrollo

### Objetivos
- Implementar código fuente
- Integrar frontend con backend
- Implementar funcionalidades del sistema

### Subtareas de Desarrollo

#### Sprint 1-2: Configuración Inicial (2 semanas)

**Backend:**
- ✅ Configurar proyecto .NET 8
- ✅ Configurar Entity Framework
- ✅ Crear modelos de datos
- ✅ Configurar Identity
- ✅ Implementar JWT

**Frontend:**
- ✅ Configurar proyecto Flutter
- ✅ Configurar GoRouter
- ✅ Configurar inyección de dependencias (GetIt)
- ✅ Implementar temas claro/oscuro

#### Sprint 3-4: Autenticación (2 semanas)

**Backend:**
- ✅ AuthController (login, register, logout)
- ✅ TokenService
- ✅ UsuarioService

**Frontend:**
- ✅ Pantalla Login
- ✅ Pantalla Registro
- ✅ Recuperación de contraseña
- ✅ SessionCubit (gestión de sesión)

#### Sprint 5-6: Catálogo de Libros (2 semanas)

**Backend:**
- ✅ LibrosController (CRUD)
- ✅ CategoriaController
- ✅ LibroService
- ✅ CategoriaService

**Frontend:**
- ✅ HomePage (catálogo)
- ✅ SearchPage (búsqueda)
- ✅ BookDetailPage (detalle)
- ✅ FilterSheet (filtros)
- ✅ SearchHeader

#### Sprint 7-8: Biblioteca y Historial (2 semanas)

**Backend:**
- ✅ BibliotecaController
- ✅ HistorialController
- ✅ BibliotecaService

**Frontend:**
- ✅ LibraryPage (biblioteca)
- ✅ UploadLibroPage (subir libros)
- ✅ HistorialPage
- ✅ SearchHeader con badge de notificaciones

#### Sprint 9-10: Lector EPUB (2 semanas)

**Backend:**
- ✅ EpubService (extracción)
- ✅ HistorialService (progreso)

**Frontend:**
- ✅ ReaderPage
- ✅ EpubParser (renderizado)
- ✅ HighlightMenu
- ✅ Sistema de resaltado (5 colores)
- ✅ BookmarkCubit

#### Sprint 11-12: Reseñas y Valoraciones (2 semanas)

**Backend:**
- ✅ ResenasController
- ✅ ValoracionesController

**Frontend:**
- ✅ RatingDialog
- ✅ ReviewDialog

#### Sprint 13-14: Perfil y Configuración (2 semanas)

**Backend:**
- ✅ Perfil endpoints

**Frontend:**
- ✅ ProfilePage
- ✅ EditProfilePage
- ✅ SettingsPage
- ✅ ReaderSettingsCubit

#### Sprint 15-16: Panel Admin (2 semanas)

**Backend:**
- ✅ Admin endpoints (libros, usuarios, categorías)
- ✅ DenunciasController
- ✅ SancionesController
- ✅ SugerenciasController

**Frontend:**
- ✅ AdminDashboardPage
- ✅ AdminLibrosPage
- ✅ AdminUsuariosPage
- ✅ AdminCategoriasPage
- ✅ AdminModeracionPage

#### Sprint 17-18: Notificaciones y Extras (2 semanas)

**Backend:**
- ✅ SignalR Hub
- ✅ NotificacionesService

**Frontend:**
- ✅ SignalR Service
- ✅ NotificationCubit
- ✅ NotificationsPage
- ✅ SafeArea en headers

### Entregables Fase 3
- Código fuente completo
- Integración frontend-backend
- Funcionalidades implementadas

### Tiempo Total Fase 3
**12 semanas** (Diciembre 2025 - Febrero 2026)

**Estado Actual:** En desarrollo

---

## Fase 4: Pruebas

### Objetivos
- Verificar funcionalidad del sistema
- Detectar y corregir errores
- Validar experiencia de usuario

### Tipos de Pruebas a Realizar

#### Pruebas Unitarias
| Módulo | Cobertura Objetivo |
|--------|-------------------|
| Backend Services | 80% |
| Frontend Cubits | 70% |
| Repositories | 75% |

#### Pruebas de Integración
- Login y autenticación
- CRUD de libros
- Biblioteca personal
- Sistema de lectura
- Subida de archivos

#### Pruebas de UI/UX
- Validación de temas claro/oscuro
- Navegación entre pantallas
- Responsive design
- Accesibilidad

#### Pruebas de Rendimiento
- Carga de catálogos grandes
- Renderizado de EPUB
- Tiempo de respuesta API

### Herramientas de Testing

| Tipo | Herramienta |
|------|-------------|
| Unitarias Backend | xUnit, NUnit |
| Unitarias Flutter | flutter_test |
| Integración | Postman, Swagger |
| UI Automation | Flutter Driver |
| Rendimiento | Flutter Performance |

### Tiempo Estimado Fase 4
**4 semanas** (Marzo 2026)

---

## Fase 5: Despliegue

### Objetivos
- Publicar aplicación en tiendas
- Configurar servidores de producción
- Monitorear y mantener

### Despliegue Backend

**Servidor:**
- Azure App Service / VPS propio
- SQL Server (Azure SQL / SQL Server Local)

**Configuración:**
- Variables de entorno
- Certificados SSL
- Logs y monitoreo
- Backups automáticos

### Despliegue Frontend

**Google Play Store:**
- ✅ APK debug (desarrollo)
- ⏳ Firma y optimización
- ⏳ Play Store Console

**Apple App Store:**
- ⏳ Configuración Apple Developer
- ⏳ Build para iOS
- ⏳ App Store Connect

### Checklist de Despliegue

- [ ] Pruebas unitarias pasando
- [ ] Pruebas de integración pasando
- [ ] Documentación actualizada
- [ ] Términos y condiciones
- [ ] Política de privacidad
- [ ] Iconos y screenshots
- [ ] Descripción de tienda

### Tiempo Estimado Fase 5
**2 semanas** (Abril 2026)

---

## Cronograma Resumido

```
2025
┌──────────────────────────────────────────────────────────────────────────┐
│ OCT          NOV          DIC          ENE          FEB          MAR   │
├──────────────────────────────────────────────────────────────────────────┤
│█████ FASE 1 │████ FASE 2 │████████████████████████ FASE 3 █████████████│
│  Análisis   │  Diseño    │              Desarrollo                      │
└──────────────────────────────────────────────────────────────────────────┘

2026
┌──────────────────────────────────────────────────────────────────────────┐
│ MAR          ABR                                                      │
├──────────────────────────────────────────────────────────────────────────┤
│███ FASE 4 ██│██ FASE 5 ██│                                                    │
│  Pruebas    │Despliegue  │                                                    │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Recursos del Proyecto

### Repositorios
- Frontend: `OpenBooksMobile/open_books_mobile`
- Backend: `NatalySCH/Opeenbook-Backend`

### Tecnologías por Componente

| Componente | Tecnología |
|------------|-------------|
| Frontend | Flutter |
| Backend | .NET 8 |
| Base de Datos | SQL Server |
| Estado | Flutter Bloc |
| Navegación | GoRouter |
| Inyección DI | GetIt |
| HTTP Client | Dio |
| Auth | JWT + Identity |
| Notificaciones | SignalR |

---

## Estado Actual del Proyecto

**Desarrollo: 85% Completado**

### Módulos Completados
- ✅ Autenticación
- ✅ Catálogo de libros
- ✅ Biblioteca personal
- ✅ Lector EPUB con resaltado
- ✅ Perfil de usuario
- ✅ Panel Admin básico

### Módulos en Desarrollo
- 🔄 Subida de libros por usuarios
- 🔄 Sistema de denuncias
- 🔄 Notificaciones en tiempo real

### Módulos Pendientes
- ⏳ Pruebas unitarias
- ⏳ Optimización de rendimiento
- ⏳ Despliegue

---

*Documento generado automáticamente - OpenBooks Project*
*Última actualización: Marzo 2026*
