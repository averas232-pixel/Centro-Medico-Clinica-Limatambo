using System;
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

        public int RegistrarPaciente(Paciente paciente)
        {
            if (string.IsNullOrWhiteSpace(paciente.DNI) || paciente.DNI.Length != 8)
                throw new ArgumentException("El DNI debe tener 8 dígitos.");
            if (string.IsNullOrWhiteSpace(paciente.Nombres) || string.IsNullOrWhiteSpace(paciente.Apellidos))
                throw new ArgumentException("Nombres y apellidos son obligatorios.");

            paciente.Activo = true;
            return _pacienteRepository.Registrar(paciente);
        }
    }
}