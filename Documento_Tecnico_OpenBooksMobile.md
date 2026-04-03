# DOCUMENTO TÉCNICO DEL SISTEMA

**Open Books Mobile**

---

## 1. DESCRIPCIÓN DEL SISTEMA

### 1.1 Identificación del Problema

El presente documento describe el sistema **Open Books Mobile**, una aplicación móvil de lectura y gestión de biblioteca de libros electrónicos desenvolvida para la plataforma Android e iOS mediante el framework Flutter.

**Contexto del problema:** En la actualidad, existe una creciente demanda de acceso a contenido bibliográfico digital desde dispositivos móviles. Los usuarios requieren herramientas que les permitan no solo consumir contenido digital, sino también gestionar su propia biblioteca personal, realizar anotaciones, mantener un historial de lectura y recibir notificaciones en tiempo real sobre actualizaciones o recomendaciones.

**Limitaciones identificadas:** Las soluciones existentes en el mercado suelen ser propietarias, restrictivas en cuanto a formatos soportados, o carecen de funcionalidades esenciales como la integración con sistemas de gestión de contenidos, la moderación de contenido generado por usuarios, o herramientas avanzadas de lectura (marcadores, resaltado de texto, personalización visual). Adicionalmente, muchas aplicaciones no ofrecen un panel de administración que permita la gestión eficiente de usuarios, contenidos y moderación.

**Justificación del desarrollo:** El desarrollo de Open Books Mobile responde a la necesidad de proporcionar una alternativa flexible, de código abierto y completamente funcional que combine las capacidades de una biblioteca digital personal con las herramientas necesarias para la gestión administrativa de una plataforma de distribución de libros electrónicos. El sistema automatiza procesos de autenticación, búsqueda, descarga, lectura y gestión que tradicionalmente requerirían múltiples aplicaciones o herramientas.

### 1.2 Descripción del Sistema o Aplicación

**Propósito del sistema:** Open Books Mobile es una aplicación móvil multiplataforma que permite a los usuarios acceder a un catálogo de libros electrónicos en formato EPUB, gestionar su biblioteca personal, leer libros con herramientas avanzadas de anotación, y mantener un registro automático de su historial de lectura. Adicionalmente, el sistema incluye un panel de administración completo para la gestión de contenidos, usuarios y moderación.

**Funcionalidades principales:**

- **Autenticación y gestión de usuarios:** Registro de nuevos usuarios, inicio de sesión con credenciales JWT, recuperación de contraseña mediante correo electrónico, y gestión de perfiles de usuario incluyendo actualización de datos personales y foto de perfil.

- **Catálogo de libros:** Exploración del catálogo general de libros con capacidades de búsqueda por título o autor, filtrado por categorías, visualización de detalles completos incluyendo portada, descripción, valoración promedio y reseñas.

- **Valoraciones y reseñas:** Sistema de valoración con escala de 1 a 5 estrellas, creación y edición de reseñas textuales, visualización de reseñas de otros usuarios, y sistema de denuncias para contenido inapropiado.

- **Biblioteca personal:** Agregar y eliminar libros de la biblioteca personal del usuario, acceso offline a libros descargados, y organización de la colección privada.

- **Lector EPUB avanzado:** Carga y renderizado de libros en formato EPUB, navegación por tabla de contenidos, funcionalidad de marcadores (bookmarks), sistema de resaltado de texto con múltiples colores, búsqueda dentro del libro, y configuración personalizable (tema claro/oscuro, tamaño de fuente, tipo de letra, interlineado).

- **Historial de lectura:** Registro automático del progreso de lectura por cada libro, visualización del historial de libros leídos recientemente, y sincronización del estado de lectura con el servidor.

- **Notificaciones en tiempo real:** Sistema de notificaciones push mediante SignalR, alertas sobre nuevos libros en categorías de interés, recomendaciones personalizadas, y notificaciones del sistema.

- **Panel de administración:** Dashboard con estadísticas globales (usuarios, libros, valoraciones), gestión completa de libros (CRUD), gestión de usuarios (activar/desactivar, asignar roles), gestión de categorías, herramienta de moderación (gestión de denuncias, sanciones a usuarios), gestión de sugerencias y opiniones, y administración de roles y permisos.

**Usuarios del sistema:**

- **Usuario general:** Cualquier persona que desee acceder al catálogo de libros, gestionar su biblioteca personal y leer libros electrónicos. Puede realizar valoraciones, reseñas, y denuncias.

- **Administrador:** Usuario con privilegios especiales que gestiona el contenido, usuarios, categorías y la moderación de la plataforma. Tiene acceso al panel de administración completo.

**Tecnologías y stack empleado:**

| Componente              | Tecnología            | Versión |
|-------------------------|-----------------------|---------|
| Framework móvil         | Flutter               | 3.x     |
| Lenguaje                | Dart                  | 3.x     |
| Gestión de estado       | flutter_bloc (Cubit) | ^8.x    |
| Cliente HTTP            | Dio                   | ^5.x    |
| Inyección de dependencias | get_it              | ^7.x    |
| Navegación              | go_router             | ^14.x   |
| Almacenamiento seguro   | flutter_secure_storage | ^9.x   |
| Comunicación tiempo real | signalr_netcore     | ^3.x    |
| Variables de entorno   | flutter_dotenv         | ^5.x    |

**Metodología de desarrollo:** El sistema fue desarrollado siguiendo una metodología de **Ciclo de Vida** (desarrollo tradicional), adoptando las fases clásicas de ingeniería de software: planificación, análisis de requisitos, diseño, implementación, pruebas y mantenimiento. Esta metodología permite un control riguroso del progreso del proyecto y garantiza la documentación adecuada de cada fase del desarrollo.

**Arquitectura del sistema:** La aplicación sigue una arquitectura de capas claras que promueve la separación de responsabilidades y la mantenibilidad del código:

- **Capa de presentación (UI):** Widgets de Flutter que definen la interfaz de usuario, incluyendo páginas, componentes reutilizables y diálogos.

- **Capa de lógica de negocio (Logic):** Implementada mediante Cubits de flutter_bloc, gestiona el estado de la aplicación y la interacción entre la UI y los repositorios.

- **Capa de datos (Data):** Repositorios que abstraen las fuentes de datos, modelos de transferencia de datos (DTOs), y data sources que conectan con APIs externas o almacenamiento local.

- **Capa core/shared:** Componentes transversales incluyendo manejo de errores (excepciones y failures), gestión de sesión, configuración del entorno, theme de la aplicación, y utilidades comunes.

---

## 2. REQUISITOS DEL SISTEMA

### 2.1 Requisitos Funcionales

| Código | Descripción |
|--------|-------------|
| **RF-01** | **Registro de usuario:** El sistema debe permitir a nuevos usuarios crear una cuenta proporcionando correo electrónico, nombre de usuario y contraseña. La validación de datos debe realizarse tanto en cliente como en servidor. |
| **RF-02** | **Inicio de sesión:** El sistema debe autenticar a los usuarios mediante correo electrónico y contraseña, generando y almacenando un token JWT para sesiones subsiguientes. |
| **RF-03** | **Recuperación de contraseña:** El sistema debe permitir a los usuarios solicitar un correo de recuperación y posteriormente actualizar su contraseña mediante un token de verificación. |
| **RF-04** | **Gestión de perfil:** El sistema debe permitir a los usuarios autenticados actualizar su información personal (nombre, biografía) y foto de perfil. |
| **RF-05** | **Listado de libros:** El sistema debe mostrar un catálogo paginado de libros disponibles con información básica (título, autor, portada, valoración). |
| **RF-06** | **Búsqueda de libros:** El sistema debe permitir buscar libros por título o nombre del autor, con resultados actualizados en tiempo real. |
| **RF-07** | **Filtrado por categoría:** El sistema debe permitir filtrar el catálogo de libros por una o múltiples categorías seleccionadas. |
| **RF-08** | **Detalle de libro:** El sistema debe mostrar información completa del libro incluyendo descripción extendida, lista de capítulos, portada en alta resolución, valoraciones promedio y reseñas. |
| **RF-09** | **Valoración de libros:** El sistema debe permitir a usuarios autenticados calificar un libro con una puntuación de 1 a 5 estrellas. Solo se permite una valoración por usuario por libro. |
| **RF-10** | **Creación de reseñas:** El sistema debe permitir a usuarios autenticados escribir reseñas textuales sobre un libro. Las reseñas pueden ser editadas o eliminadas por su autor. |
| **RF-11** | **Denuncia de reseñas:** El sistema debe permitir a cualquier usuario autenticado reportar reseñas inapropiadas seleccionando un motivo predefinido o proporcionando una descripción. |
| **RF-12** | **Agregar a biblioteca:** El sistema debe permitir a usuarios autenticados agregar libros a su biblioteca personal. No se permiten duplicados. |
| **RF-13** | **Eliminar de biblioteca:** El sistema debe permitir a usuarios autenticados eliminar libros de su biblioteca personal. |
| **RF-14** | **Ver biblioteca personal:** El sistema debe mostrar la lista de libros agregados a la biblioteca del usuario con opciones de acceso directo a la lectura. |
| **RF-15** | **Descarga de EPUB:** El sistema debe permitir la descarga del archivo EPUB de un libro para lectura offline, mostrando el progreso de descarga. |
| **RF-16** | **Lectura de EPUB:** El sistema debe renderizar el contenido del libro EPUB permitiendo la navegación por capítulos, scroll vertical y lectura continua. |
| **RF-17** | **Tabla de contenidos:** El sistema debe mostrar una tabla de contenidos navegable que permita saltar directamente a cualquier capítulo o sección del libro. |
| **RF-18** | **Marcadores (Bookmarks):** El sistema debe permitir crear, visualizar y eliminar marcadores en posiciones específicas del libro para facilitar el retorno a puntos importantes. |
| **RF-19** | **Resaltado de texto:** El sistema debe permitir seleccionar texto y aplicar resaltado en múltiples colores. Los resaltados deben persistirse y sincronizarse. |
| **RF-20** | **Búsqueda dentro del libro:** El sistema debe permitir buscar texto dentro del contenido del libro y resaltar las ocurrencias encontradas. |
| **RF-21** | **Configuración del lector:** El sistema debe permitir personalizar la experiencia de lectura incluyendo: tema (claro/oscuro/sistema), tamaño de fuente, tipo de letra, y interlineado. La configuración debe persistirse. |
| **RF-22** | **Historial de lectura:** El sistema debe registrar automáticamente el progreso de lectura (capítulo actual, porcentaje) y mostrar un historial de libros leídos recientemente. |
| **RF-23** | **Notificaciones push:** El sistema debe recibir y mostrar notificaciones en tiempo real sobre eventos relevantes (nuevos libros, respuestas a reseñas) mediante SignalR. |
| **RF-24** | **Dashboard administrativo:** El sistema debe mostrar al administrador un panel con estadísticas globales: total de usuarios, libros, valoraciones, y actividad reciente. |
| **RF-25** | **Gestión de libros (admin):** El sistema debe permitir al administrador crear, modificar, eliminar y subir nuevos libros al catálogo. |
| **RF-26** | **Gestión de usuarios (admin):** El sistema debe permitir al administrador listar usuarios, ver detalles, modificar roles y desactivar cuentas. |
| **RF-27** | **Gestión de categorías (admin):** El sistema debe permitir al administrador crear, modificar y eliminar categorías de libros. |
| **RF-28** | **Moderación de denuncias:** El sistema debe permitir al administrador revisar denuncias de reseñas, aceptarlas (eliminando la reseña) o rechazarlas. |
| **RF-29** | **Gestión de sanciones:** El sistema debe permitir al administrador aplicar sanciones temporales a usuarios que incumplan las normas, limitando su acceso temporalmente. |
| **RF-30** | **Gestión de sugerencias:** El sistema debe permitir a usuarios enviar sugerencias y al administrador revisarlas y eliminarlas. |

### 2.2 Requisitos No Funcionales

| Código | Categoría | Descripción |
|--------|-----------|-------------|
| **RNF-01** | Rendimiento | La aplicación debe cargar el catálogo de libros en menos de 3 segundos en condiciones de red normales (3G o superior). La navegación entre páginas debe ser instantánea (< 200ms). |
| **RNF-02** | Rendimiento | El lector EPUB debe renderizar las páginas sin retardo perceptible, permitiendo scroll fluido a 60fps. La apertura de un libro debe completarse en menos de 2 segundos. |
| **RNF-03** | Seguridad | Las credenciales de usuario deben almacenarse de forma segura utilizando almacenamiento cifrado (flutter_secure_storage). Los tokens JWT deben incluirse en todas las requests autenticadas. |
| **RNF-04** | Seguridad | Las acciones administrativas deben validarse tanto en cliente como en servidor. El acceso a endpoints de administración debe requerir rol de administrador. |
| **RNF-05** | Usabilidad | La interfaz debe ser intuitiva y requerir mínimo aprendizaje. Los flujos principales (buscar, leer, valorar) deben completarse en menos de 3 toques. |
| **RNF-06** | Usabilidad | La aplicación debe soportar modo claro y oscuro, adaptándose automáticamente al tema del sistema operativo. |
| **RNF-07** | Escalabilidad | El sistema debe soportar al menos 10,000 libros en el catálogo sin degradación perceptible en el rendimiento de búsqueda. |
| **RNF-08** | Disponibilidad | La aplicación debe manejar gracefully la pérdida de conexión, mostrando mensajes apropiados y permitiendo acceso a contenido previamente descargado. |
| **RNF-09** | Compatibilidad | La aplicación debe funcionar en Android 6.0 (API 23) o superior, y iOS 12.0 o superior. |
| **RNF-10** | Mantenibilidad | El código debe seguir patrones consistentes (Clean Architecture), estar modularizado por características, y utilizar inyección de dependencias para facilitar pruebas y evolución. |

---

## 3. CONTROL DE VERSIONES

| Versión | Fecha | Descripción |
|---------|-------|-------------|
| 1.0.0 | 2026-03-31 | Versión inicial del documento técnico |

---

*Documento generado para el proyecto Open Books Mobile*