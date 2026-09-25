using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class InsumoRepository : IInsumoRepository
    {
        public Insumo ObtenerPorId(int id)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT InsumoID, Nombre, Stock, PrecioUnitario, UnidadMedida FROM Insumos WHERE InsumoID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            using var reader = cmd.ExecuteReader();
            return reader.Read() ? Mapear(reader) : null;
        }

        public List<Insumo> ObtenerTodos()
        {
            var lista = new List<Insumo>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT InsumoID, Nombre, Stock, PrecioUnitario, UnidadMedida FROM Insumos WHERE Activo = 1 ORDER BY Nombre", conn);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(Mapear(reader));

            return lista;
        }

        private static Insumo Mapear(SqlDataReader reader) => new Insumo
        {
            InsumoID = reader.GetInt32(reader.GetOrdinal("InsumoID")),
            Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
            Stock = reader.GetInt32(reader.GetOrdinal("Stock")),
            PrecioUnitario = reader.GetDecimal(reader.GetOrdinal("PrecioUnitario")),
            UnidadMedida = reader.GetString(reader.GetOrdinal("UnidadMedida"))
        };
    }
}