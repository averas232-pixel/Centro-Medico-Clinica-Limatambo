using System.Collections.Generic;

namespace CentroMedico.Domain.Entities
{
    public enum MetodoPago { Efectivo, Tarjeta, YapePlin, Transferencia }
    public enum EstadoFactura { Pagada, Anulada }

    public class Factura
    {
        public int FacturaID { get; set; }
        public int CitaID { get; set; }
        public string NombrePaciente { get; set; } = string.Empty;
        public string Serie { get; set; }
        public string Correlativo { get; set; }
        public decimal Subtotal { get; set; }
        public decimal IGV { get; set; }
        public decimal Total { get; set; }
        public MetodoPago MetodoPago { get; set; }
        public EstadoFactura Estado { get; set; }
        public List<DetalleFactura> Detalles { get; set; } = new();
    }

    public class DetalleFactura
    {
        public int DetalleFacturaID { get; set; }
        public int FacturaID { get; set; }
        public string Descripcion { get; set; }
        public int Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Subtotal { get; set; }
    }
}