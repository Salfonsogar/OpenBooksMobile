# Plan: Datos Online/Offline Strategy

## Objetivo
- **Online**: Mostrar SOLO datos del API
- **Offline**: Mostrar SOLO datos locales
- **Agregar libro**: Requiere conexión (error si offline)

##current State (Problema)
- Repository hace merge + overwrite local con datos remotos
- UseCase decide online/offline pero repository hace lógica extra
- Lógica duplicada en Biblioteca + Historial

---

## FASE 1: Repository - Separar operaciones remotas

### Biblioteca Repository
| Método | Función |
|--------|---------|
| `getRemoto(uid)` | Llama API, retorna datos puros |
| `getBiblioteca(uid)` | Retorna SOLO datos locales |
| `addLibro(uid, libroId)` | **Requiere conexión** (lanza error si offline) |
| `removeLibro(uid, libroId)` | **Requiere conexión** (lanza error si offline) |

### Historial Repository - Mismo patrón

**Cambios específicos**:
- Eliminar lógica de merge/overwrite en `getBiblioteca()`
- Agregar check `isConnected` en `addLibro()`/`removeLibro()`

---

## FASE 2: UseCases - Elegir fuente según conexión

```dart
// get_biblioteca_usecase.dart
Future call(uid) async {
  if (await networkInfo.isConnected) {
    return repository.getRemoto(uid);  // Solo API
  }
  return repository.getBiblioteca(uid);        // Solo local
}
```

Mismo cambio en `get_historial_usecase.dart`

---

## FASE 3: UI - Feedback claro de conexión

**BibliotecaCubit**
- Agregar estado `BibliotecaError('Sin conexión')` cuando offline + sin datos locales
- Agregar check en `_agregarLibro()`: si offline, mostrar error "Sin conexión"

---

## FASE 4: SyncService - Solo background sync

**Sin cambios en comportamiento actual**:
- Progreso de lectura → sync en background
- Sesiones de lectura → sync en background
- Cola de operaciones → reintentar cuando hay conexión

---

## Resumen de archivos a modificar

| Fase | Archivo | Cambio |
|-----|---------|--------|
| 1 | `biblioteca_repository_impl.dart` | Separar getRemoto + add/remove requieren online |
| 1 | `historial_repository_impl.dart` | Mismo patrón |
| 2 | `get_biblioteca_usecase.dart` | Decide fuente según conexión |
| 2 | `get_historial_usecase.dart` | Mismo patrón |
| 3 | `biblioteca_cubit.dart` | Manejar error offline |

---

## Pendiente por implementar

- [x] FASE 1: biblioteca_repository_impl.dart
- [x] FASE 1: historial_repository_impl.dart
- [x] FASE 2: get_biblioteca_usecase.dart
- [x] FASE 2: get_historial_usecase.dart
- [x] FASE 3: biblioteca_cubit.dart (manejar error offline al agregar)
- [ ] Verificar compile