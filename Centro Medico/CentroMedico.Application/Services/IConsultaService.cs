using CentroMedico.Domain.Contracts;

namespace CentroMedico.Application.Services
{
    public interface IConsultaService
    {
        ResultadoCierreConsulta CerrarConsulta(CierreConsultaData datos);
    }
}