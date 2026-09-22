namespace CentroMedico.Domain.Entities
{
    public class Insumo
    {
        public int InsumoID { get; set; }
        public string Nombre { get; set; }
        public int Stock { get; set; }
        public decimal PrecioUnitario { get; set; }
        public string UnidadMedida { get; set; }
    }
}