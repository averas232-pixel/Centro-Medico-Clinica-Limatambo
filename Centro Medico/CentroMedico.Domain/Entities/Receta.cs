using System;
using System.Collections.Generic;

namespace CentroMedico.Domain.Entities
{
    public class Receta
    {
        public int RecetaID { get; set; }
        public int HistorialID { get; set; }
        public DateTime FechaEmision { get; set; }
        public string Indicaciones { get; set; }
        public List<DetalleReceta> Detalles { get; set; } = new();
    }

    public class DetalleReceta
    {
        public int DetalleRecetaID { get; set; }
        public int RecetaID { get; set; }
        public int InsumoID { get; set; }
        public int Cantidad { get; set; }
        public string Dosis { get; set; }
    }
}