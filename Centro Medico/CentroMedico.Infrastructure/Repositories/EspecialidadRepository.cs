using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class EspecialidadRepository : IEspecialidadRepository
    {
        public List<Especialidad> ObtenerTodas()
        {
            var lista = new List<Especialidad>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand("SELECT EspecialidadID, Nombre FROM Especialidades ORDER BY Nombre", conn);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(new Especialidad
                {
                    EspecialidadID = reader.GetInt32(0),
                    Nombre = reader.GetString(1)
                });

            return lista;
        }
    }
}