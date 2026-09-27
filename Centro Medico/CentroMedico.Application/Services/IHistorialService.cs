using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Application.Services
{
    public interface IHistorialService
    {
        List<HistorialClinico> ObtenerPorPaciente(int pacienteId);
    }
}