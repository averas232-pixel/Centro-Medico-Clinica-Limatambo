using System;

namespace CentroMedico.Domain.Entities
{
    public enum TipoMovimiento { Entrada, Salida }

    public class MovimientoInsumo
    {
        public int MovimientoID { get; set; }
        public int InsumoID { get; set; }
        public TipoMovimiento TipoMovimiento { get; set; }
        public int Cantidad { get; set; }
        public int StockAnterior { get; set; }
        public int StockNuevo { get; set; }
        public string Motivo { get; set; }
        public int? ReferenciaDetalleRecetaID { get; set; }
        public DateTime FechaMovimiento { get; set; }
    }
}