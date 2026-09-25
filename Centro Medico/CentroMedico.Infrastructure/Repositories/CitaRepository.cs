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
        public Cita ObtenerPorId(int id)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT CitaID, PacienteID, MedicoID, FechaHora, Estado, Motivo FROM Citas WHERE CitaID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            using var reader = cmd.ExecuteReader();
            return reader.Read() ? Mapear(reader) : null;
        }

        public List<Cita> ObtenerAgendaDelDia(DateTime fecha)
        {
            var lista = new List<Cita>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT CitaID, PacienteID, MedicoID, FechaHora, Estado, Motivo FROM Citas " +
                "WHERE CAST(FechaHora AS DATE) = @fecha ORDER BY FechaHora", conn);
            cmd.Parameters.AddWithValue("@fecha", fecha.Date);

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
            FechaHora = reader.GetDateTime(reader.GetOrdinal("FechaHora")),
            Estado = Enum.Parse<EstadoCita>(reader.GetString(reader.GetOrdinal("Estado"))),
            Motivo = reader.GetString(reader.GetOrdinal("Motivo"))
        };
    }
}