using CentroMedico.Domain.Contracts;

namespace CentroMedico.Domain.Interfaces
{
    public interface IConsultaRepository
    {
        ResultadoCierreConsulta CerrarConsulta(CierreConsultaData datos);
    }
}