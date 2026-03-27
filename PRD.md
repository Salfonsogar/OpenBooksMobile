# Product Requirements Document (PRD)
## Open Books Mobile - Lector EPUB

---

## 1. Descripción del Producto

**Nombre del Producto:** Open Books Mobile  
**Tipo:** Aplicación móvil multiplataforma (Android/iOS)  
**Core Feature:** Lector EPUB integrado para lectura de libros electrónicos

**Resumen:** Open Books Mobile es una aplicación móvil que permite a los usuarios descubrir, descargar y leer libros en formato EPUB. El lector EPUB es el componente central de la experiencia del usuario, ofreciendo una experiencia de lectura personalizada con soporte para marcadores, resaltados, búsqueda y configuración visual avanzada.

**Versión del Documento:** 1.0  
**Fecha:** 27/03/2026  
**Estado:** Draft

---

## 2. Objetivos del Producto

### Objetivos Principales
1. **Experiencia de lectura fluida** - Proporcionar una lectura sin interrupciones con carga rápida de capítulos y navegación fluida
2. **Personalización total** - Permitir al usuario adaptar la experiencia de lectura a sus preferencias (tema, fuente, tamaño, márgenes)
3. **Gestión de contenido** - Facilitar la organización mediante marcadores y resaltados persistentes
4. **Accesibilidad offline** - Habilitar la lectura sin conexión mediante caché inteligente

### Objetivos Secundarios
- Reducir el consumo de memoria manteniendo rendimiento óptimo
- Minimizar el uso de datos mediante caché de capítulos
- Proporcionar accesibilidad mediante soporte para temas de alto contraste

---

## 3. Alcance del Producto

### ✅ Incluido en el PRD
| Módulo | Funcionalidad |
|--------|---------------|
| **Visualización de Contenido** | Renderizado de HTML/XHTML del EPUB con soporte para párrafos, encabezados, imágenes, blockquotes, enlaces |
| **Navegación** | PageView con swipe, TOC (Table of Contents), navegación programática por capítulos |
| **Configuración de Lectura** | Temas (Claro/Oscuro/Sepia), tamaño de fuente (12-28px), familia de fuente, interlineado, márgenes |
| **Marcadores** | Crear, editar, eliminar, persistencia local |
| **Resaltados** | Selección de texto, 5 colores, persistencia local |
| **Búsqueda** | Búsqueda global en el libro, navegación a resultados |
| **Caché** | Caché de hasta 10 capítulos en memoria, precarga automática |

### ❌ Excluido del Alcance (v1.0)
- Descarga completa del libro para lectura offline
- Sincronización de progreso entre dispositivos
- Notas personales (solo resaltados)
- Diccionario integrado
- Texto a voz (TTS)
- Animaciones de página avanzadas (efecto física)
- Integración con lectores de pantalla nativa

---

## 4. Requisitos Funcionales

### 4.1 Carga y Visualización de Libros

| ID | Requisito | Prioridad | Descripción |
|----|-----------|-----------|-------------|
| RF-01 | Carga de manifest | Alta | El sistema debe obtener la estructura del libro (manifiesto) desde la API al iniciar la lectura |
| RF-02 | Renderizado de contenido | Alta | El sistema debe convertir el contenido HTML del capítulo en widgets renderizables |
| RF-03 | Soporte de elementos HTML | Alta | Debe soportar: p, h1-h6, img, blockquote, br, a |
| RF-04 | Corrección de rutas | Media | Las rutas relativas de imágenes deben convertirse a absolutas para su carga correcta |
| RF-05 | Manejo de codificación | Alta | Debe manejar UTF-8 e ISO-8859-1 |

### 4.2 Navegación

| ID | Requisito | Prioridad | Descripción |
|----|-----------|-----------|-------------|
| RF-06 | Navegación por swipe | Alta | El usuario debe poder navegar entre capítulos mediante gestos horizontales |
| RF-07 | Botones anterior/siguiente | Alta | Botones visibles para navegación programática |
| RF-08 | Table of Contents | Alta | Mostrar TOC desde el manifest del EPUB |
| RF-09 | Selector de capítulo | Media | Selector en footer para cambiar directamente de capítulo |
| RF-10 | Barra de progreso | Alta | Indicador visual del progreso de lectura |
| RF-11 | Mantener posición | Alta | Al volver a un capítulo, mantener la posición de scroll |

### 4.3 Configuración de Lectura

| ID | Requisito | Prioridad | Descripción |
|----|-----------|-----------|-------------|
| RF-12 | Cambio de tema | Alta | Tres temas: Claro, Oscuro, Sepia |
| RF-13 | Tamaño de fuente | Alta | Slider de 12px a 28px |
| RF-14 | Familia de fuente | Media | Opciones: Sans-serif, Serif, Monospace |
| RF-15 | Interlineado | Media | Opciones: 1.2, 1.5, 1.8, 2.0 |
| RF-16 | Márgenes | Media | Opciones: Narrow (8px), Normal (16px), Wide (32px) |
| RF-17 | Persistencia de settings | Alta | La configuración debe persistir entre sesiones |

### 4.4 Marcadores

| ID | Requisito | Prioridad | Descripción |
|----|-----------|-----------|-------------|
| RF-18 | Crear marcador | Alta | Crear marcador en la posición actual con título personalizado |
| RF-19 | Listar marcadores | Alta | Mostrar lista de marcadores del libro actual |
| RF-20 | Editar marcador | Media | Permitir cambiar el título del marcador |
| RF-21 | Eliminar marcador | Alta | Eliminar marcador existente |
| RF-22 | Navegar a marcador | Alta | Al seleccionar un marcador, navegar a su posición |
| RF-23 | Persistencia local | Alta | Los marcadores deben guardarse en SharedPreferences |

### 4.5 Resaltados (Highlights)

| ID | Requisito | Prioridad | Descripción |
|----|-----------|-----------|-------------|
| RF-24 | Selección de texto | Alta | El usuario debe poder seleccionar texto para resaltar |
| RF-25 | Colores de resaltado | Alta | 5 colores: Amarillo, Verde, Azul, Rosa, Naranja |
| RF-26 | Ver resaltados | Alta | Los resaltados deben ser visibles en el texto |
| RF-27 | Eliminar resaltado | Alta | Tap en resaltado para eliminar |
| RF-28 | Persistencia local | Alta | Los resaltados deben guardarse en SharedPreferences |

### 4.6 Búsqueda

| ID | Requisito | Prioridad | Descripción |
|----|-----------|-----------|-------------|
| RF-29 | Búsqueda en libro | Alta | Buscar texto en todo el libro |
| RF-30 | Resultados por capítulo | Alta | Mostrar resultados agrupados por capítulo |
| RF-31 | Navegación a resultado | Alta | Al seleccionar resultado, navegar a su ubicación |

### 4.7 Caché y Rendimiento

| ID | Requisito | Precendencia | Descripción |
|----|-----------|--------------|-------------|
| RF-32 | Caché de capítulos | Alta | Mantener hasta 10 capítulos en memoria |
| RF-33 | Precarga automática | Media | Cargar automáticamente el siguiente capítulo |
| RF-34 | Limpieza de caché | Media | Eliminar capítulos no cercanos al actual |

---

## 5. Requisitos No Funcionales

### 5.1 Rendimiento

| ID | Requisito | Criterio |
|----|-----------|----------|
| RNF-01 | Tiempo de carga de capítulo | < 2 segundos en red 3G |
| RNF-02 | Tiempo de inicio del lector | < 1 segundo (manifest en memoria) |
| RNF-03 | Memoria máxima | < 150MB con 10 capítulos en caché |
| RNF-04 | Scroll fluido | 60 FPS |

### 5.2 Compatibilidad

| ID | Requisito | Criterio |
|----|-----------|----------|
| RNF-05 | Versión mínima de Flutter | 3.x |
| RNF-06 | Versión mínima de Android | API 21 (Android 5.0) |
| RNF-07 | Orientación | Portrait y Landscape |
| RNF-08 | Tamaños de pantalla | phones y tablets |

### 5.3 UX/UI

| ID | Requisito | Criterio |
|----|-----------|----------|
| RNF-09 | Temas accesibles | Alto contraste en todos los temas |
| RNF-10 | Tamaño mínimo de touch | 48x48dp |
| RNF-11 | Feedback visual | Indicadores de carga y navegación |

### 5.4 Seguridad y Datos

| ID | Requisito | Criterio |
|----|-----------|----------|
| RNF-12 | Almacenamiento seguro | SharedPreferences para datos locales |
| RNF-13 | Sin caching de contenido sensible | Solo en memoria durante la sesión |

---

## 6. Casos de Uso

### UC-01: Iniciar Lectura de un Libro
**Actor:** Usuario  
**Flujo:**
1. Usuario selecciona un libro de la biblioteca
2. Sistema obtiene el manifest del EPUB
3. Sistema carga el primer capítulo
4. Sistema muestra el contenido en el Reader
5. Sistema restaura última posición de lectura si existe

### UC-02: Personalizar Experiencia de Lectura
**Actor:** Usuario  
**Flujo:**
1. Usuario abre configuración de lectura
2. Usuario ajusta tema, tamaño, fuente, interlineado, márgenes
3. Sistema aplica cambios en tiempo real
4. Sistema guarda configuración

### UC-03: Crear Marcador
**Actor:** Usuario  
**Flujo:**
1. Usuario está leyendo un capítulo
2. Usuario toca el botón de marcador
3. Sistema muestra diálogo para ingresar título
4. Usuario ingresa título y confirma
5. Sistema guarda marcador con posición actual

### UC-04: Resaltar Texto
**Actor:** Usuario  
**Flujo:**
1. Usuario selecciona texto en el capítulo
2. Sistema muestra menú de resaltado
3. Usuario selecciona color
4. Sistema guarda resaltado con texto y posición

### UC-05: Buscar en el Libro
**Actor:** Usuario  
**Flujo:**
1. Usuario abre diálogo de búsqueda
2. Usuario ingresa término de búsqueda
3. Sistema busca en todos los capítulos
4. Sistema muestra resultados por capítulo
5. Usuario selecciona resultado
6. Sistema navega a la posición del resultado

### UC-06: Navegar por Tabla de Contenidos
**Actor:** Usuario  
**Flujo:**
1. Usuario toca el botón de TOC
2. Sistema muestra lista de capítulos
3. Usuario selecciona capítulo
4. Sistema navega al capítulo seleccionado

---

## 7. Flujos de Usuario

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUJO PRINCIPAL                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [Biblioteca] ──► [Detalle del Libro] ──► [Reader Page]        │
│                                                  │              │
│                                                  ▼              │
│                                         ┌──────────────┐       │
│                                         │ Reader Loaded│       │
│                                         └──────────────┘       │
│                                              │                  │
│           ┌──────────────────────────────────┼────────────────┐│
│           │                                  │                ││
│           ▼                                  ▼                ▼│
│  ┌─────────────────┐           ┌──────────────────┐ ┌─────────┐│
│  │ Reader Settings │           │ Table of Contents│ │ Search  ││
│  │ - Tema          │           │ - Cap. 1         │ │ - Query ││
│  │ - Fuente        │           │ - Cap. 2         │ │ - Results│
│  │ - Tamaño        │           │ - ...            │ └─────────┘│
│  │ - Interlineado  │           └──────────────────┘            │
│  │ - Márgenes      │                                              │
│  └─────────────────┘                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Arquitectura y Diseño Técnico

### 8.1 Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ ReaderPage  │  │ ReaderHeader│  │ ReaderFooter        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Logic Layer (Cubits)                      │
│  ┌──────────────┐ ┌──────────────────┐ ┌──────────────────┐  │
│  │ ReaderCubit  │ │ ReaderSettingsCubit│ │ BookmarkCubit   │  │
│  └──────────────┘ └──────────────────┘ └──────────────────┘  │
│  ┌──────────────┐ ┌──────────────────┐                       │
│  │HighlightCubit│ │ BookmarkCubit    │                       │
│  └──────────────┘ └──────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────────┐  ┌────────────────────────────────┐   │
│  │ BookmarkRepository│  │ EpubRepository                │   │
│  └──────────────────┘  └────────────────────────────────┘   │
│                              │                                │
│                              ▼                                │
│  ┌──────────────────┐  ┌────────────────────────────────┐   │
│  │ BookmarkDatasource│ │ EpubDatasource                │   │
│  └──────────────────┘  └────────────────────────────────┘   │
│                              │                                │
│                              ▼                                │
│                   ┌──────────────────┐                       │
│                   │    Dio HTTP      │                       │
│                   └──────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework | Flutter | 3.x |
| Estado | flutter_bloc (Cubit) | ^8.1.3 |
| HTTP | Dio | ^5.3.0 |
| Parsing HTML | html | ^0.15.4 |
| Local Storage | shared_preferences | ^2.2.2 |

### 8.3 Endpoints del API

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/Libros/{id}/epub/manifest` | GET | Obtiene estructura del libro |
| `/api/Libros/{id}/epub/resource?path={ruta}` | GET | Obtiene contenido de capítulo |

---

## 9. Métricas de Éxito

| Métrica | Target | Descripción |
|---------|--------|-------------|
| Tiempo de carga de capítulo | < 2s | Promedio en red 3G |
| FPS de scroll | ≥ 55 FPS | Durante navegación |
| Tasa de error de carga | < 1% | Fallos al cargar capítulos |
| Uso de memoria | < 150 MB | Con 10 capítulos en caché |
| Retención de usuarios | > 70% | Usuarios que usan el lector >3 veces/semana |

---

## 10. Riesgos y Dependencias

### 10.1 Riesgos Identificados

| ID | Riesgo | Impacto | Mitigación |
|----|--------|---------|------------|
| R-01 | Contenido EPUB no estándar | Alto | Validación de formato, manejo de errores robusto |
| R-02 | Imágenes grandes/pesadas | Medio | Lazy loading, compresión en servidor |
| R-03 | Pérdida de progreso por crash | Medio | Persistencia periódica de posición |
| R-04 | Memoria insuficiente en dispositivos low-end | Alto | Reducir caché a 5 capítulos en Android < 4GB RAM |
| R-05 | Conexión inestable | Alto | Retry logic, caché offline (v2.0) |

### 10.2 Dependencias Externas

| Dependencia | Descripción | Disponibilidad |
|-------------|-------------|----------------|
| Backend API | Endpoints de EPUB | Requerida |
| Servidor de imágenes | CDN de portadas e imágenes | Requerida |
| flutter_bloc | Estado de la aplicación | Estable |
| html package | Parsing de contenido | Estable |

---

## 11. Timeline Tentativo

| Fase | Duración | Entregables |
|------|----------|-------------|
| **Fase 1: Fundamentos** | 2 semanas | Reader básico, carga de capítulos, navegación |
| **Fase 2: Configuración** | 1 semana | Temas, fuentes, tamaño, persistencia |
| **Fase 3: Funciones avanzadas** | 2 semanas | Marcadores, resaltados, búsqueda |
| **Fase 4: Optimización** | 1 semana | Caché, precarga, métricas |
| **Fase 5: Testing** | 1 semana | Pruebas, bug fixes, release |

**Total estimado:** 7 semanas

---

## 12. Glosario

| Término | Definición |
|---------|------------|
| EPUB | Formato estándar de libro electrónico (Electronic PUBlication) |
| Manifest | Archivo que define la estructura de un EPUB (toc, reading order) |
| TOC | Table of Contents - Índice del libro |
| Highlight | Resaltado de texto |
| Bookmark | Marcador de posición |
| Chapter Cache | Almacenamiento temporal de capítulos |

---

## 13. Aprobaciones

| Rol | Nombre | Fecha | Firma |
|-----|--------|-------|-------|
| Product Owner | | | |
| Tech Lead | | | |
| UX Lead | | | |

---

**Fin del documento**
