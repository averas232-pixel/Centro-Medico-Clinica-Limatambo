using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class CitaRepository : ICitaRepository
    {
        private const string ConsultaCitas =
            "SELECT c.CitaID, c.PacienteID, c.MedicoID, c.FechaHora, c.Estado, c.Motivo, " +
            "LTRIM(RTRIM(CONCAT(p.Nombres, ' ', p.Apellidos))) AS NombrePaciente, " +
            "LTRIM(RTRIM(CONCAT(m.Nombres, ' ', m.Apellidos))) AS NombreMedico " +
            "FROM Citas c " +
            "LEFT JOIN Pacientes p ON p.PacienteID = c.PacienteID " +
            "LEFT JOIN Medicos m ON m.MedicoID = c.MedicoID ";

        public Cita ObtenerPorId(int id)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                ConsultaCitas + "WHERE c.CitaID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            using var reader = cmd.ExecuteReader();
            return reader.Read() ? Mapear(reader) : null;
        }

        public List<Cita> ObtenerAgendaDelDia(DateTime fecha)
        {
            var lista = new List<Cita>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                ConsultaCitas + "WHERE CAST(c.FechaHora AS DATE) = @fecha ORDER BY c.FechaHora", conn);
            cmd.Parameters.AddWithValue("@fecha", fecha.Date);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(Mapear(reader));

            return lista;
        }

        public List<Cita> ObtenerTodas()
        {
            var lista = new List<Cita>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                ConsultaCitas + "ORDER BY c.FechaHora DESC", conn);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(Mapear(reader));

            return lista;
        }

        public int Registrar(Cita cita)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "INSERT INTO Citas (PacienteID, MedicoID, FechaHora, Estado, Motivo) " +
                "VALUES (@pac, @med, @fecha, @estado, @motivo); SELECT CAST(SCOPE_IDENTITY() AS INT);", conn);

            cmd.Parameters.AddWithValue("@pac", cita.PacienteID);
            cmd.Parameters.AddWithValue("@med", cita.MedicoID);
            cmd.Parameters.AddWithValue("@fecha", cita.FechaHora);
            cmd.Parameters.AddWithValue("@estado", cita.Estado.ToString());
            cmd.Parameters.AddWithValue("@motivo", cita.Motivo);

            return (int)cmd.ExecuteScalar();
        }

        private static Cita Mapear(SqlDataReader reader) => new Cita
        {
            CitaID = reader.GetInt32(reader.GetOrdinal("CitaID")),
            PacienteID = reader.GetInt32(reader.GetOrdinal("PacienteID")),
            MedicoID = reader.GetInt32(reader.GetOrdinal("MedicoID")),
            NombrePaciente = reader.GetString(reader.GetOrdinal("NombrePaciente")),
            NombreMedico = reader.GetString(reader.GetOrdinal("NombreMedico")),
            FechaHora = reader.GetDateTime(reader.GetOrdinal("FechaHora")),
            Estado = Enum.Parse<EstadoCita>(reader.GetString(reader.GetOrdinal("Estado"))),
            Motivo = reader.GetString(reader.GetOrdinal("Motivo"))
        };
    }
}
