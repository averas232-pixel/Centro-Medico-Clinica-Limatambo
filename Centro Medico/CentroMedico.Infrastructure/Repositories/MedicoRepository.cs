using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class MedicoRepository : IMedicoRepository
    {
        public Medico ObtenerPorId(int id)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT m.MedicoID, m.CMP, m.Nombres, m.Apellidos, m.EspecialidadID, e.Nombre AS Especialidad, m.Activo " +
                "FROM Medicos m JOIN Especialidades e ON e.EspecialidadID = m.EspecialidadID " +
                "WHERE m.MedicoID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            using var reader = cmd.ExecuteReader();
            return reader.Read() ? Mapear(reader) : null;
        }

        public List<Medico> ObtenerActivos()
        {
            var lista = new List<Medico>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT m.MedicoID, m.CMP, m.Nombres, m.Apellidos, m.EspecialidadID, e.Nombre AS Especialidad, m.Activo " +
                "FROM Medicos m JOIN Especialidades e ON e.EspecialidadID = m.EspecialidadID " +
                "WHERE m.Activo = 1 ORDER BY m.Apellidos, m.Nombres", conn);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(Mapear(reader));

            return lista;
        }

        private static Medico Mapear(SqlDataReader reader) => new Medico
        {
            MedicoID = reader.GetInt32(reader.GetOrdinal("MedicoID")),
            CMP = reader.GetString(reader.GetOrdinal("CMP")),
            Nombres = reader.GetString(reader.GetOrdinal("Nombres")),
            Apellidos = reader.GetString(reader.GetOrdinal("Apellidos")),
            EspecialidadID = reader.GetInt32(reader.GetOrdinal("EspecialidadID")),
            Especialidad = reader.GetString(reader.GetOrdinal("Especialidad")),
            Activo = reader.GetBoolean(reader.GetOrdinal("Activo"))
        };
    }
}