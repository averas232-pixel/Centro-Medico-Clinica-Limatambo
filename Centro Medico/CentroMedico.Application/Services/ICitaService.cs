using System;
using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Application.Services
{
    public interface ICitaService
    {
        List<Cita> ObtenerAgendaDelDia(DateTime fecha);
        int RegistrarCita(NuevaCitaDto dto);
    }
}