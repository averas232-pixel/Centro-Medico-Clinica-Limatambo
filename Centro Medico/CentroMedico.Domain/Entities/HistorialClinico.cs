using System;

namespace CentroMedico.Domain.Entities
{
    public class HistorialClinico
    {
        public int HistorialID { get; set; }
        public int CitaID { get; set; }
        public string Diagnostico { get; set; }
        public string Observaciones { get; set; }
        public DateTime FechaRegistro { get; set; }
    }
}