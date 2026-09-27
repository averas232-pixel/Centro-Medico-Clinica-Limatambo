using System.Collections.Generic;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;

namespace CentroMedico.Application.Services
{
    public class HistorialService : IHistorialService
    {
        private readonly IHistorialRepository _historialRepository;

        public HistorialService(IHistorialRepository historialRepository)
        {
            _historialRepository = historialRepository;
        }

        public List<HistorialClinico> ObtenerPorPaciente(int pacienteId)
            => _historialRepository.ObtenerPorPaciente(pacienteId);
    }
}