using System;
using System.Collections.Generic;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;

namespace CentroMedico.Application.Services
{
    public class CitaService : ICitaService
    {
        private readonly ICitaRepository _citaRepository;

        public CitaService(ICitaRepository citaRepository)
        {
            _citaRepository = citaRepository;
        }

        public List<Cita> ObtenerAgendaDelDia(DateTime fecha)
            => _citaRepository.ObtenerAgendaDelDia(fecha);

        public int RegistrarCita(NuevaCitaDto dto)
        {
            if (dto.PacienteID <= 0 || dto.MedicoID <= 0)
                throw new ArgumentException("Debe seleccionar paciente y médico.");
            if (dto.FechaHora < DateTime.Now)
                throw new ArgumentException("No se puede agendar una cita en el pasado.");

            var cita = new Cita
            {
                PacienteID = dto.PacienteID,
                MedicoID = dto.MedicoID,
                FechaHora = dto.FechaHora,
                Motivo = dto.Motivo,
                Estado = EstadoCita.Programada
            };
            return _citaRepository.Registrar(cita);
        }
    }
}