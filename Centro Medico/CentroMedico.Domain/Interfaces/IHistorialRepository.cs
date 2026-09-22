using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IHistorialRepository
    {
        HistorialClinico ObtenerPorCitaId(int citaId);
        List<HistorialClinico> ObtenerPorPaciente(int pacienteId);
    }
}