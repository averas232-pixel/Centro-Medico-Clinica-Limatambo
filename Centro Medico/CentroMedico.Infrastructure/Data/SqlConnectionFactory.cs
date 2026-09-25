using System.Data;
using Microsoft.Data.SqlClient;

namespace CentroMedico.Infrastructure.Data
{
    public static class SqlConnectionFactory
    {
        
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