# Clínica Limatambo — Sistema de Gestión Clínica

Sistema de escritorio para la gestión de un centro médico: agenda de citas, historial clínico, recetas con control de insumos y facturación. Desarrollado con **C#, WPF y ADO.NET** aplicando **Clean Architecture** y el patrón **MVVM**.

Proyecto final del curso *Desarrollo de Software con C#, ADO.NET y WPF* — Universidad Nacional de Cajamarca.

---

## Transacción crítica: Cierre de Consulta

Al cerrar una consulta, el sistema ejecuta en **una sola `SqlTransaction`**:

1. Registro del diagnóstico en el historial clínico
2. Generación de la receta médica
3. Descuento de insumos del inventario, con registro en el kardex (`MovimientosInsumo`)
4. Emisión de la boleta (subtotal, IGV 18% y total)
5. Cambio de estado de la cita

Si cualquiera de estos pasos falla (por ejemplo, stock insuficiente o una cita ya cerrada), se ejecuta `Rollback()` y **no queda ningún dato parcial** en la base de datos.

La implementación está en `CentroMedico.Infrastructure/Repositories/ConsultaRepository.cs`.

## Módulos

| Módulo | Descripción |
|---|---|
| **Agenda de Citas** | Agenda por fecha, con nombre de paciente y médico. Registro de nuevas citas. |
| **Cierre de Consulta** | Diagnóstico, receta con insumos, monto y método de pago. Dispara la transacción crítica. |
| **Historial Clínico** | Búsqueda de pacientes por nombre o DNI y línea de tiempo de consultas. |
| **Facturación** | Resumen de ingresos, listado de boletas con estado y detalle tipo comprobante. |
| **Inicio de sesión** | Autenticación con contraseñas almacenadas como hash SHA-256 con salt. |

## Arquitectura

```
Centro Medico/
├── CentroMedico.Domain           Entidades, contratos y interfaces de repositorio (sin dependencias)
├── CentroMedico.Application      Casos de uso, servicios y validaciones
├── CentroMedico.Infrastructure   Repositorios con ADO.NET puro (SqlConnection, SqlCommand, SqlTransaction)
└── Centro Medico UI              WPF + MVVM (Views, ViewModels, Commands, Converters, Styles)
```

Dependencias entre capas: `UI → Application → Domain` y `Infrastructure → Domain`. La capa Domain no depende de ninguna otra.

**MVVM:** `INotifyPropertyChanged`, `ObservableCollection<T>`, comandos con `RelayCommand` (`ICommand`), y vistas sin lógica de negocio en el code-behind. La inyección de dependencias se configura en `App.xaml.cs` con `Microsoft.Extensions.DependencyInjection`.

## Base de datos

Motor: **SQL Server**. Base de datos: `CentroMedicoDB`.

Tablas: `Especialidades`, `Medicos`, `Pacientes`, `Citas`, `HistorialClinico`, `Insumos`, `Recetas`, `DetalleReceta`, `MovimientosInsumo`, `Facturas`, `DetalleFactura`, `Usuarios`.

Scripts en la carpeta [`database/`](database/):

1. `CentroMedico_schema_seed.sql` — crea la base de datos, las tablas y los datos de prueba (30 o más registros por tabla) y el procedimiento `sp_ImprimirFacturaASCII`.
2. `crear_usuarios.sql` — crea la tabla `Usuarios` con los usuarios de prueba.

## Puesta en marcha

**Requisitos:** Visual Studio 2022 (carga de trabajo *Desarrollo de escritorio de .NET*), SQL Server y SQL Server Management Studio.

1. Clonar el repositorio.
2. Ejecutar en SQL Server, en este orden, los dos scripts de `database/`.
3. Crear el archivo `Centro Medico/CentroMedico.Infrastructure/Data/SqlConnectionFactory.cs` (está excluido del repositorio para no compartir credenciales locales):

```csharp
using System.Data;
using Microsoft.Data.SqlClient;

namespace CentroMedico.Infrastructure.Data
{
    public static class SqlConnectionFactory
    {
        private const string ConnectionString =
            "Server=localhost;Database=CentroMedicoDB;Trusted_Connection=True;TrustServerCertificate=True;";

        public static IDbConnection CrearConexion()
        {
            var connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }
    }
}
```

   Ajustar `Server` (y usar `User Id` / `Password` si el servidor usa autenticación de SQL Server).

4. Abrir la solución en Visual Studio, establecer `Centro Medico UI` como proyecto de inicio y ejecutar con `F5`.

**Usuarios de prueba**

| Usuario | Contraseña | Rol |
|---|---|---|
| `admin` | `Admin123` | Administrador |
| `doctor` | `Doctor123` | Medico |

## Demostración del Rollback

Dos formas de provocar un fallo controlado en el cierre de consulta:

- Recetar una cantidad de un insumo **mayor al stock disponible**.
- Intentar cerrar una **cita que ya tiene historial clínico** (restricción `UNIQUE` sobre `HistorialClinico.CitaID`).

En ambos casos la interfaz informa que la transacción se revirtió y las tablas `HistorialClinico`, `Recetas`, `DetalleReceta`, `MovimientosInsumo`, `Facturas` e `Insumos` quedan sin cambios.

## Tecnologías

C# · .NET · WPF · ADO.NET (`Microsoft.Data.SqlClient`) · SQL Server · Clean Architecture · MVVM · Git

## Equipo

- Antony Vera Sánchez — [@averas232-pixel](https://github.com/averas232-pixel)
- Samuel Arce — [@samuelarce](https://github.com/samuelarce)
- Trujilo Bazán - [@JoseT1428]((https://github.com/JoseT1428)
- Terán Chavez Anderson - [@tonyander](https://github.com/tonyander)
