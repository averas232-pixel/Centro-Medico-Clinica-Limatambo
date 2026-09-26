using System;
using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface ICitaRepository
    {
        Cita ObtenerPorId(int id);
        List<Cita> ObtenerAgendaDelDia(DateTime fecha);
        List<Cita> ObtenerTodas();
        int Registrar(Cita cita);
    }
}