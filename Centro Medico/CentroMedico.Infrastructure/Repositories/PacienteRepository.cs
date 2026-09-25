using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class PacienteRepository : IPacienteRepository
    {
        public Paciente ObtenerPorId(int id)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT PacienteID, DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Direccion, Email, Activo " +
                "FROM Pacientes WHERE PacienteID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            using var reader = cmd.ExecuteReader();
            if (reader.Read())
                return Mapear(reader);
            return null;
        }

        public List<Paciente> ObtenerTodos()
        {
            var lista = new List<Paciente>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT PacienteID, DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Direccion, Email, Activo " +
                "FROM Pacientes WHERE Activo = 1 ORDER BY Apellidos, Nombres", conn);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(Mapear(reader));

            return lista;
        }

        public int Registrar(Paciente paciente)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "INSERT INTO Pacientes (DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Direccion, Email) " +
                "VALUES (@dni, @nombres, @apellidos, @fnac, @sexo, @tel, @dir, @email); " +
                "SELECT CAST(SCOPE_IDENTITY() AS INT);", conn);

            cmd.Parameters.AddWithValue("@dni", paciente.DNI);
            cmd.Parameters.AddWithValue("@nombres", paciente.Nombres);
            cmd.Parameters.AddWithValue("@apellidos", paciente.Apellidos);
            cmd.Parameters.AddWithValue("@fnac", paciente.FechaNacimiento);
            cmd.Parameters.AddWithValue("@sexo", paciente.Sexo.ToString());
            cmd.Parameters.AddWithValue("@tel", paciente.Telefono);
            cmd.Parameters.AddWithValue("@dir", paciente.Direccion);
            cmd.Parameters.AddWithValue("@email", (object)paciente.Email ?? System.DBNull.Value);

            return (int)cmd.ExecuteScalar();
        }

        private static Paciente Mapear(SqlDataReader reader) => new Paciente
        {
            PacienteID = reader.GetInt32(reader.GetOrdinal("PacienteID")),
            DNI = reader.GetString(reader.GetOrdinal("DNI")),
            Nombres = reader.GetString(reader.GetOrdinal("Nombres")),
            Apellidos = reader.GetString(reader.GetOrdinal("Apellidos")),
            FechaNacimiento = reader.GetDateTime(reader.GetOrdinal("FechaNacimiento")),
            Sexo = reader.GetString(reader.GetOrdinal("Sexo"))[0],
            Telefono = reader.GetString(reader.GetOrdinal("Telefono")),
            Direccion = reader.GetString(reader.GetOrdinal("Direccion")),
            Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
            Activo = reader.GetBoolean(reader.GetOrdinal("Activo"))
        };
    }
}