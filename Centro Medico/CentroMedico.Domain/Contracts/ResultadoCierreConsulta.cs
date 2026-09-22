namespace CentroMedico.Domain.Contracts
{
    public class ResultadoCierreConsulta
    {
        public bool Exitoso { get; set; }
        public string MensajeError { get; set; }
        public int FacturaID { get; set; }
        public string SerieCorrelativo { get; set; }
        public decimal Total { get; set; }
    }
}