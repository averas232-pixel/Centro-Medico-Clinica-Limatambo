using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class MovimientoInsumoRepository : IMovimientoInsumoRepository
    {
        public List<MovimientoInsumo> ObtenerPorInsumo(int insumoId)
        {
            var lista = new List<MovimientoInsumo>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT MovimientoID, InsumoID, TipoMovimiento, Cantidad, StockAnterior, StockNuevo, " +
                "Motivo, ReferenciaDetalleRecetaID, FechaMovimiento " +
                "FROM MovimientosInsumo WHERE InsumoID = @id ORDER BY FechaMovimiento DESC", conn);
            cmd.Parameters.AddWithValue("@id", insumoId);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(new MovimientoInsumo
                {
                    MovimientoID = reader.GetInt32(0),
                    InsumoID = reader.GetInt32(1),
                    TipoMovimiento = reader.GetString(2) == "Entrada" ? TipoMovimiento.Entrada : TipoMovimiento.Salida,
                    Cantidad = reader.GetInt32(3),
                    StockAnterior = reader.GetInt32(4),
                    StockNuevo = reader.GetInt32(5),
                    Motivo = reader.GetString(6),
                    ReferenciaDetalleRecetaID = reader.IsDBNull(7) ? (int?)null : reader.GetInt32(7),
                    FechaMovimiento = reader.GetDateTime(8)
                });

            return lista;
        }
    }
}