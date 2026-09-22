using CentroMedico.Domain.Contracts;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Application.Validators;

namespace CentroMedico.Application.Services
{
    public class ConsultaService : IConsultaService
    {
        private readonly IConsultaRepository _consultaRepository;

        public ConsultaService(IConsultaRepository consultaRepository)
        {
            _consultaRepository = consultaRepository;
        }

        public ResultadoCierreConsulta CerrarConsulta(CierreConsultaData datos)
        {
            CierreConsultaValidator.Validar(datos);
            return _consultaRepository.CerrarConsulta(datos);
        }
    }
}