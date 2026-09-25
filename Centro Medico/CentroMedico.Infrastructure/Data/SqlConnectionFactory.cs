using System.Data;
using Microsoft.Data.SqlClient;

namespace CentroMedico.Infrastructure.Data
{
    public static class SqlConnectionFactory
    {
        // Ajusta "Server" al nombre de tu instancia (el mismo que usas para
        // conectarte en SSMS). Ejemplos comunes: "localhost", ".\SQLEXPRESS",
        // "(localdb)\MSSQLLocalDB".
        private const string ConnectionString =
            "Server=localhost;Database=CentroMedicoDB;User Id=sa;Password=TommyKaliLinux2025@;TrustServerCertificate=True;";

        public static IDbConnection CrearConexion()
        {
            var connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }
    }
}