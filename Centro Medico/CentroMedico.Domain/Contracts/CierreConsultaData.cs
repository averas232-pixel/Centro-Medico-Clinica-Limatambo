using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Contracts
{
    public class CierreConsultaData
    {
        public int CitaID { get; set; }
        public string Diagnostico { get; set; }
        public string Observaciones { get; set; }
        public string IndicacionesReceta { get; set; }
        public List<ItemInsumoDto> InsumosRecetados { get; set; } = new();
        public MetodoPago MetodoPago { get; set; }
        public decimal MontoConsulta { get; set; }
    }

    public class ItemInsumoDto
    {
        public int InsumoID { get; set; }
        public int Cantidad { get; set; }
        public string Dosis { get; set; }
    }
}