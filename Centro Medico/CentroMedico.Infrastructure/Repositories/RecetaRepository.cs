using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class RecetaRepository : IRecetaRepository
    {
        public Receta ObtenerPorId(int id)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT RecetaID, HistorialID, FechaEmision, Indicaciones FROM Recetas WHERE RecetaID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            Receta receta;
            using (var reader = cmd.ExecuteReader())
            {
                if (!reader.Read()) return null;
                receta = new Receta
                {
                    RecetaID = reader.GetInt32(0),
                    HistorialID = reader.GetInt32(1),
                    FechaEmision = reader.GetDateTime(2),
                    Indicaciones = reader.GetString(3)
                };
            }

            using var cmdDet = new SqlCommand(
                "SELECT DetalleRecetaID, RecetaID, InsumoID, Cantidad, Dosis FROM DetalleReceta WHERE RecetaID = @id", conn);
            cmdDet.Parameters.AddWithValue("@id", id);
            using var readerDet = cmdDet.ExecuteReader();
            while (readerDet.Read())
                receta.Detalles.Add(new DetalleReceta
                {
                    DetalleRecetaID = readerDet.GetInt32(0),
                    RecetaID = readerDet.GetInt32(1),
                    InsumoID = readerDet.GetInt32(2),
                    Cantidad = readerDet.GetInt32(3),
                    Dosis = readerDet.GetString(4)
                });

            return receta;
        }

        public List<Receta> ObtenerPorPaciente(int pacienteId)
        {
            var lista = new List<Receta>();
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using var cmd = new SqlCommand(
                "SELECT r.RecetaID, r.HistorialID, r.FechaEmision, r.Indicaciones " +
                "FROM Recetas r JOIN HistorialClinico h ON h.HistorialID = r.HistorialID " +
                "JOIN Citas c ON c.CitaID = h.CitaID WHERE c.PacienteID = @pacId ORDER BY r.FechaEmision DESC", conn);
            cmd.Parameters.AddWithValue("@pacId", pacienteId);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                lista.Add(new Receta
                {
                    RecetaID = reader.GetInt32(0),
                    HistorialID = reader.GetInt32(1),
                    FechaEmision = reader.GetDateTime(2),
                    Indicaciones = reader.GetString(3)
                });

            return lista;
        }
    }
}