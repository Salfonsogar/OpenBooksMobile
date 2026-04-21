# Diseño Técnico: Módulo de Seguimiento de Lectura

**Fecha:** 2023-10-27  
**Versión:** 1.0.0  
**Objetivo:** Diseñar la estructura completa de la API, la base de datos y la interfaz de usuario para gestionar el progreso de lectura de los usuarios, soportando funcionalidades offline y sincronización de datos.

---

## I. Backend Design (API & Data Model)

El backend estara construido sobre una arquitectura RESTful API, utilizando un patron de persistencia que soporte transacciones complejas y sincronizacion de conflictos.

### A. Modelo de Base de Datos (Schema)

#### 1. reading_progress (Motor de seguimiento principal)

Esta tabla rastrea el estado actual de lectura.

| Campo | Tipo | Descripcion | Notas |
|-------|------|--------------|-------|
| progress_id | UUID | PK | Identificador del progreso |
| book_id | UUID | FK | Libro asociado |
| current_page | Integer | Ultima pagina leida | El dato critico |
| last_read_at | Timestamp | Fecha y hora de la ultima lectura | Para notificaciones |
| reading_streak | Integer | Racha de lectura continua (dias) | Calculado/sincronizado |
| sync_status | Enum | Estado de sincronizacion | SYNCED, PENDING_UPLOAD, CONFLICT |
| local_version | Integer | Contador local de version | Ayuda en deteccion de conflictos |

#### 2. reading_sessions (Historial)

Tabla de auditoria para registrar cada sesion.

| Campo | Tipo | Descripcion | Notas |
|-------|------|--------------|-------|
| session_id | UUID | PK | Identificador de la sesion |
| progress_id | UUID | FK | Progreso afectado |
| pages_read_in_session | Integer | Paginas leidas en esta sesion | |
| session_timestamp | Timestamp | Cuandooccurrio la sesion | |
| notes | Text | Notas del usuario sobre la sesion | Opcional |

### B. API Endpoints (RESTful)

Se asume que todos los endpoints requieren autenticacion (Bearer Token).

| Endpoint | Metodo | Descripcion | Cuerpo (Body) | Respuesta (Success) | Notas Clave |
|----------|--------|--------------|----------------|---------------------|--------------|
| /api/v1/books | POST | Crear un nuevo registro de libro | {title, author, isbn, pages} | {book_id} | Sincronizacion inicial |
| /api/v1/progress | GET | Obtener progreso actual del usuario | Ninguno | [{book_id, current_page, streak, last_read_at}] | Debe considerar el estado offline |
| /api/v1/progress/{book_id} | PUT | Actualizar la posicion de lectura | {current_page, session_notes} | {message: "Updated successfully"} | Endpoint principal de escritura. El cliente debe enviar el local_version |
| /api/v1/progress/sync | POST | Sincronizar datos en lote | {updates: [{book_id, current_page, local_version, timestamp}]} | {status: "Sync complete", conflicts: [...]} | Maneja el conflicto de versiones |
| /api/v1/history/{book_id} | GET | Obtener el historial de sesiones | Ninguno | [{session_id, pages_read_in_session, session_timestamp}] | Solo lectura |

### C. Logica de Sincronizacion (Offline First)

La clave del sistema es la "Offline First":

1. **Lectura (Read):** Los datos consultados son los que se guardaron localmente hasta la ultima sincronizacion exitosa.
2. **Escritura (Write):** Cuando el usuario esta offline, todas las actualizaciones (current_page, session_notes) se guardan en una Cola Local de Transacciones en el dispositivo.
3. **Sincronizacion (Sync):** Al recuperar la conexion, el dispositivo envia la cola completa (/sync) al servidor.
4. **Resolucion de Conflictos:**
   - El servidor compara el local_version recibido con su global_version en reading_progress.
   - **Caso 1 (OK):** Si el local_version es menor o igual al global_version y la marca de tiempo es posterior, el registro se actualiza y el servidor incrementa la version.
   - **Caso 2 (Conflicto):** Si el local_version es stagnado o el servidor detecta una actualizacion mas reciente de otra fuente, se retorna un conflicto. Se recomienda la logica "Latest Write Wins" (basado en el timestamp mas reciente) o notificar al usuario para que revise dos entradas diferentes.

---

## II. Frontend Design (UX Flow & Components)

El frontend (aplicacion movil/web) debe priorizar la experiencia de lectura inmersiva y la facilidad de actualizacion.

### A. Flujo de Usuario Principal (Core Loop)

1. **Inicio/Dashboard:** Mostrar un resumen de los libros en los que el usuario esta leyendo activamente, destacando el progreso y la racha actual.
2. **Pantalla de Lectura (Reading View):**
   - **Componente Central:** Visualizacion del texto principal, paginacion simulada.
   - **Mecanica de Progreso:** Al pasar de una "pagina" simulada, se debe ejecutar el envio automatico de la actualizacion de progreso a la cola local.
   - **Post-Lectura:** Al cerrar la vista, se presenta un modal/panel deslizante para "Confirmar/Ajustar Progreso", permitiendo al usuario anadir notas de la sesion y forzar la sincronizacion si es posible.
3. **Biblioteca/Gestion de Libros:** Vista catalogo donde se listan todos los libros. Cada entrada muestra el progreso actual y un boton de accion rapida ("Continuar Leyendo").

### B. Componentes Reutilizables

- **ProgressBar:** Muestra (Paginas Actuales / Paginas Totales) con un indicador visual claro.
- **SyncStatusIndicator:** Un icono que indica cuantas actualizaciones pendientes hay en la cola local. Al hacer clic, se fuerza la sincronizacion manual.
- **SessionNoteInput:** Un area de texto persistente que captura los logs de la sesion.

### C. Manejo del Estado Offline (UX Feedback)

Es vital que el usuario nunca sepa si su progreso se guardo o no:

1. **Offline:** Mostrar un banner persistente y visible: "Sin conexion. Tus avances se guardaran localmente y se sincronizaran cuando te conectes."
2. **Sincronizacion Exitosa:** Un toast de confirmacion positivo: "Progreso sincronizado exitosamente."
3. **Error de Sync:** Un toast claro: "Fallo la sincronizacion. Por favor, revisa tu conexion."

---

## III. Plan de Implementacion por Fases

> **Nota:** Este proyecto es un frontend Flutter. Se asume que el backend ya tiene los endpoints de progreso y las tablas necesarias (reading_progress, reading_sessions).

### Fase 1: Extender Base de Datos Local (Semana 2)

**Objetivo:** Anadir soporte offline para progreso de lectura.

1. **Extender biblioteca_local**
   - Ya tiene progreso (double 0-100) y page (numero de pagina)
   - Anadir last_read_at, reading_streak, sync_status

2. **Nueva tabla reading_sessions**
   - Crear tabla local para historial de sesiones
   - Guardar pages_read_in_session, session_timestamp, notes

**Criterios de Aceptacion:**
- [ ] La tabla biblioteca_local tiene los campos last_read_at, reading_streak, sync_status
- [ ] Se puede guardar y recuperar el progreso de un libro desde SQLite
- [ ] Se puede guardar una sesion de lectura con notas
- [ ] Las consultas de progreso funcionan correctamente
- [ ] El schema local permite versionamiento (local_version)

---

### Fase 2: Extender SyncService con Fallback Local (Semanas 3-4)

**Objetivo:** Integrar progreso de lectura al sistema de sincronizacion, con soporte para guardar localmente si los endpoints fallan.

1. **Semana 3 - Integracion de Progreso**
   - Anadir handling de progreso en SyncService
   - Implementar logica de cola para updates de progreso
   - Anadir retry logic especifica para progreso

2. **Semana 4 - Fallback Local y Resolucion de Conflictos**
   - **Fallback automatico:** Si el endpoint falla (error de conexion o 404/500), guardar automaticamente en cola local para reintentar luego
   - **Detectar respuestas de error:** Manejar casos donde el endpoint no existe (404) o el servidor no responde
   - **Estrategia "Latest Write Wins":** Para resolucion de conflictos
   - **Sistema de notificaciones:** Alertar al usuario cuando hay conflictos pendientes

**Criterios de Aceptacion:**
- [ ] SyncService procesa updates de progreso correctamente
- [ ] Al fallar un endpoint (404/500/time out), el progreso se guarda en cola local
- [ ] La cola local se reintenta automaticamente al recuperar conexion
- [ ] Se implementa estrategia "Latest Write Wins" para conflictos
- [ ] El sistema notifica al usuario cuando hay conflictos pendientes de resolver
- [ ] Retry logic conbackoff exponencial para reintentos fallidos

---

### Fase 3: UI - Componentes y Vistas (Semanas 5-6)

**Objetivo:** Implementar componentes reutilizables y actualizar vistas existentes.

1. **Semana 5 - Componentes Base**
   - Actualizar ProgressBar existente
   - Crear SyncStatusIndicator (mostrar pendientes de sync)
   - Crear SessionNoteInput (notas de sesion)

2. **Semana 6 - Vistas Existentes**
   - Anadir indicador de progreso en library_page.dart
   - Anadir progreso visual en home_page.dart
   - Actualizar book_detail_page.dart con historial

**Criterios de Aceptacion:**
- [ ] ProgressBar muestra correctamente el porcentaje de lectura
- [ ] SyncStatusIndicator muestra el numero de actualizaciones pendientes
- [ ] SessionNoteInput permite guardar y recuperar notas de sesion
- [ ] Library muestra el progreso de cada libro con barra visual
- [ ] Home muestra los libros activos con su progreso y racha
- [ ] BookDetail muestra historial de sesiones del libro

---

### Fase 4: Reader - Integracion de Progreso (Semanas 7-8)

**Objetivo:** Conectar el reader existente con el sistema de progreso.

1. **Semana 7 - Tracking en Reader**
   - Modificar ReaderCubit para guardar posicion automaticamente
   - Guardar en cola local al cambiar capitulo/pagina
   - Anadir debounce para no saturar la cola

2. **Semana 8 - Post-Lectura**
   - Modal de confirmacion al cerrar reader
   - Guardar notas de sesion
   - Forzar sync si hay conexion

**Criterios de Aceptacion:**
- [ ] Al cambiar de capitulo, se guarda la posicion automaticamente
- [ ] El progreso se guarda en SQLite incluso sin conexion
- [ ] Hay un debounce (minimo 5 seg) antes de guardar para evitar saturacion
- [ ] Al cerrar el reader se muestra modal de confirmacion de progreso
- [ ] El usuario puede agregar notas antes de cerrar
- [ ] Si hay conexion, se intenta sincronizar al cerrar
- [ ] El reader reanuda desde la ultima posicion guardada

---

### Fase 5: UX Offline (Semanas 9-10)

**Objetivo:** Feedback visual para estados offline y sync.

1. **Semana 9 - Feedback UX**
   - Banner "Sin conexion" (reutilizar existente si hay)
   - Toast de sync exitoso
   - Toast de error de sync

2. **Semana 10 - Testing y Ajuste**
   - Pruebas de escenarios offline
   - Pruebas de conflictos
   - Ajustes de UX

**Criterios de Aceptacion:**
- [ ] Se muestra un banner visible cuando el dispositivo esta sin conexion
- [ ] El banner indica que el progreso se guardara localmente
- [ ] Aparece un toast cuando la sincronizacion es exitosa
- [ ] Aparece un toast claro cuando falla la sincronizacion
- [ ] El usuario puede reintentar manualmente la sincronizacion
- [ ] El indicador de progreso se actualiza tras una sincronizacion exitosa

---

### Fase 6: Optimizacion (Semanas 11-12)

**Objetivo:** Pulir y optimizar.

1. **Semana 11 - Rendimiento**
   - Optimizar queries SQLite
   - Reducir tamano de payloads
   - Cacheo de datos frecuentes

2. **Semana 12 - Documentacion**
   - Documentar API extendido
   - Actualizar README tecnico

**Criterios de Aceptacion:**
- [ ] Las consultas de progreso en SQLite tienen indices apropiados
- [ ] Los payloads de sincronizacion estan optimizados (solo datos necesarios)
- [ ] El cacheo de datos frecuentes reduce llamadas a la API
- [ ] El tiempo de carga de la biblioteca con progreso es menor a 1 segundo
- [ ] La documentacion API esta actualizada con los nuevos endpoints
- [ ] El README tecnico refleja la nueva funcionalidad de progreso

---

## IV. Resumen de Interacciones Clave

| Accion del Usuario | Cliente (App) Maneja | Servicio (Backend) | API Llamada | Razon |
|-------------------|---------------------|---------------------|-------------|-------|
| Leer Pagina (Avance) | Guarda localmente el timestamp y el numero de pagina | POST /api/progress/sync (Batch) | No se envia en tiempo real; se agrupa y se envia al perder conexion o al salir de la app |
| Ver Lista de Libros | Obtiene metadatos de la API | GET /api/books/{book_id} | Lectura de datos estaticos |
| Forzar Sync | Revisa cola local y envia transacciones | POST /api/progress/sync | Intenta enviar todas las entradas pendientes |
| Crear Libro/Editar | Envia nueva estructura textual y metadatos | POST /api/books o PUT /api/books/{id} | Gestion de contenido |