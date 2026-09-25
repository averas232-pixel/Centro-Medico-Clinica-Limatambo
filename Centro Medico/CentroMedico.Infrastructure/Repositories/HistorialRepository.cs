using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class HistorialRepository : IHistorialRepository
    {
        public HistorialClinico ObtenerPorCitaId(int citaId)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT HistorialID, CitaID, Diagnostico, Observaciones, FechaRegistro FROM HistorialClinico WHERE CitaID = @id", conn);
            cmd.Parameters.AddWithValue("@id", citaId);

            using var reader = cmd.ExecuteReader();
            return reader.Read() ? Mapear(reader) : null;
        }

        public List<HistorialClinico> ObtenerPorPaciente(int pacienteId)
        {
            var lista = new List<HistorialClinico>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT h.HistorialID, h.CitaID, h.Diagnostico, h.Observaciones, h.FechaRegistro " +
                "FROM HistorialClinico h JOIN Citas c ON c.CitaID = h.CitaID " +
                "WHERE c.PacienteID = @pacId ORDER BY h.FechaRegistro DESC", conn);
            cmd.Parameters.AddWithValue("@pacId", pacienteId);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(Mapear(reader));

            return lista;
        }

        private static HistorialClinico Mapear(SqlDataReader reader) => new HistorialClinico
        {
            HistorialID = reader.GetInt32(reader.GetOrdinal("HistorialID")),
            CitaID = reader.GetInt32(reader.GetOrdinal("CitaID")),
            Diagnostico = reader.GetString(reader.GetOrdinal("Diagnostico")),
            Observaciones = reader.IsDBNull(reader.GetOrdinal("Observaciones")) ? null : reader.GetString(reader.GetOrdinal("Observaciones")),
            FechaRegistro = reader.GetDateTime(reader.GetOrdinal("FechaRegistro"))
        };
    }
}