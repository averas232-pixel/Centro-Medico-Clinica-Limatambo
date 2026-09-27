using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class UsuarioRepository : IUsuarioRepository
    {
        public Usuario ObtenerPorNombreUsuario(string nombreUsuario)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT UsuarioID, NombreUsuario, PasswordHash, Salt, NombreCompleto, Rol, Activo " +
                "FROM Usuarios WHERE NombreUsuario = @user AND Activo = 1", conn);
            cmd.Parameters.AddWithValue("@user", nombreUsuario);

            using var reader = cmd.ExecuteReader();
            if (!reader.Read()) return null;

            return new Usuario
            {
                UsuarioID = reader.GetInt32(0),
                NombreUsuario = reader.GetString(1),
                PasswordHash = reader.GetString(2),
                Salt = reader.GetString(3),
                NombreCompleto = reader.GetString(4),
                Rol = reader.GetString(5),
                Activo = reader.GetBoolean(6)
            };
        }
    }
}