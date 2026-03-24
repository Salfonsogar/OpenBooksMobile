# Diagrama UML del Proyecto OpenBooks

## Arquitectura General

El proyecto OpenBooks consiste en dos aplicaciones:
- **Backend**: API REST en .NET 8 (OpeenBookBack)
- **Frontend**: Aplicación móvil en Flutter (open_books_mobile)

---

## Modelo de Datos (Backend)

---
config:
  class:
    hideEmptyMembersBox: true
---
classDiagram
    direction TB

    class UsuarioIdentity {
        +int Id
        +string UserName
        +string Email
        +bool Estado
        +bool Sancionado
        +bool EsSuscriptorActivo
        +DateTime FechaRegistro
        +string NombreCompleto
        +byte[] FotoPerfil
    }

    class Rol {
        +int Id
        +string Nombre
        +string Descripcion
    }

    class Libro {
        +int Id
        +string Titulo
        +string Autor
        +string Descripcion
        +byte[] Portada
        +string PortadaContentType
        +byte[] Archivo
        +string ArchivoContentType
        +DateTime FechaPublicacion
        +bool Activo
        +bool EsPremium
        +int? PropietarioId
        +bool EsPrivado
    }

    class Categoria {
        +int Id
        +string Nombre
        +string Descripcion
    }

    class Suscripcion {
        +int Id
        +int UsuarioId
        +DateTime FechaInicio
        +DateTime FechaFin
        +string Tipo
        +string Estado
    }

    class Pago {
        +int Id
        +int UsuarioId
        +int SuscripcionId
        +string TransaccionId
        +decimal Monto
        +string Moneda
        +string MetodoPago 
        +DateTime FechaPago
        +string EstadoPago
    }

    class Biblioteca {
        +int Id
        +int UsuarioId
        +int LibroId
        +DateTime FechaAgregado
        +int? Progreso
        +bool Descargado
    }

    class Resaltador {
        +int Id
        +int UsuarioId
        +int LibroId
        +string IdResaltador
        +string Href
        +string CfiRange
        +string Texto
        +string Color
        +DateTime Fecha
    }

    class Marcador {
        +int Id
        +int UsuarioId
        +int LibroId
        +int Pagina
        +string CFI
        +DateTime Fecha
    }

    class Denuncia {
        +int Id
        +int IdDenunciante
        +int IdDenunciado
        +string Comentario
        +string Estado
        +DateTime Fecha
    }

    class Sancion {
        +int Id
        +int UsuarioId
        +string Tipo
        +DateTime FechaInicio
        +string Motivo
        +bool Activa
    }

    class Sugerencia {
        +int Id
        +int UsuarioId
        +string Titulo
        +string Descripcion
        +string Categoria
        +DateTime Fecha
        +bool Resuelta
    }

    %% Relaciones Modificadas
    UsuarioIdentity "1" -- "*" Pago : Realiza
    UsuarioIdentity "1" -- "1..*" Suscripcion : Tiene
    Suscripcion "1" -- "*" Pago : Se vincula a

    %% Resto de Relaciones
    UsuarioIdentity "N" --> "1" Rol : Tiene
    UsuarioIdentity "1" -- "0..*" Biblioteca : Posee
    Libro "1" -- "0..*" Biblioteca : Está en
    UsuarioIdentity "1" -- "0..*" Libro : Es dueño de
    Libro "N" -- "M" Categoria : Clasificado en
    UsuarioIdentity "1" -- "*" Resaltador : Crea
    Libro "1" -- "*" Resaltador : Referenciado en
    UsuarioIdentity "1" -- "*" Marcador : Crea
    Libro "1" -- "*" Marcador : Marcado en
    UsuarioIdentity "1" -- "*" Denuncia : Emite/Recibe
    UsuarioIdentity "1" -- "*" Sancion : Sufre
    UsuarioIdentity "1" -- "*" Sugerencia : Propone
