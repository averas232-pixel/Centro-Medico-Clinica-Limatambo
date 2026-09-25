using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class FacturaRepository : IFacturaRepository
    {
        public Factura ObtenerPorId(int id)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT FacturaID, CitaID, Serie, Correlativo, Subtotal, IGV, Total, MetodoPago, Estado " +
                "FROM Facturas WHERE FacturaID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            Factura factura;
            using (var reader = cmd.ExecuteReader())
            {
                if (!reader.Read()) return null;
                factura = Mapear(reader);
            }

            using var cmdDet = new SqlCommand(
                "SELECT DetalleFacturaID, FacturaID, Descripcion, Cantidad, PrecioUnitario, Subtotal " +
                "FROM DetalleFactura WHERE FacturaID = @id", conn);
            cmdDet.Parameters.AddWithValue("@id", id);
            using var readerDet = cmdDet.ExecuteReader();
            while (readerDet.Read())
                factura.Detalles.Add(new DetalleFactura
                {
                    DetalleFacturaID = readerDet.GetInt32(0),
                    FacturaID = readerDet.GetInt32(1),
                    Descripcion = readerDet.GetString(2),
                    Cantidad = readerDet.GetInt32(3),
                    PrecioUnitario = readerDet.GetDecimal(4),
                    Subtotal = readerDet.GetDecimal(5)
                });

            return factura;
        }

        public List<Factura> ObtenerPorRangoFechas(DateTime desde, DateTime hasta)
        {
            var lista = new List<Factura>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT FacturaID, CitaID, Serie, Correlativo, Subtotal, IGV, Total, MetodoPago, Estado " +
                "FROM Facturas WHERE FechaEmision BETWEEN @desde AND @hasta ORDER BY FechaEmision DESC", conn);
            cmd.Parameters.AddWithValue("@desde", desde);
            cmd.Parameters.AddWithValue("@hasta", hasta);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(Mapear(reader));

            return lista;
        }

        private static Factura Mapear(SqlDataReader reader) => new Factura
        {
            FacturaID = reader.GetInt32(0),
            CitaID = reader.GetInt32(1),
            Serie = reader.GetString(2),
            Correlativo = reader.GetString(3),
            Subtotal = reader.GetDecimal(4),
            IGV = reader.GetDecimal(5),
            Total = reader.GetDecimal(6),
            MetodoPago = Enum.Parse<MetodoPago>(reader.GetString(7).Replace("/", "")),
            Estado = Enum.Parse<EstadoFactura>(reader.GetString(8))
        };
    }
}