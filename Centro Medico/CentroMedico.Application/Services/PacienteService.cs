using System.Collections.Generic;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;

namespace CentroMedico.Application.Services
{
    public class PacienteService : IPacienteService
    {
        private readonly IPacienteRepository _pacienteRepository;

        public PacienteService(IPacienteRepository pacienteRepository)
        {
            _pacienteRepository = pacienteRepository;
        }

        public List<Paciente> ObtenerTodos() => _pacienteRepository.ObtenerTodos();
        public Paciente ObtenerPorId(int id) => _pacienteRepository.ObtenerPorId(id);
    }
}