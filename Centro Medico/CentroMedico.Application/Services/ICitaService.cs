using System;
using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Application.Services
{
    public interface ICitaService
    {
        List<Cita> ObtenerAgendaDelDia(DateTime fecha);
        List<Cita> ObtenerTodas();
        int RegistrarCita(NuevaCitaDto dto);
    }
}