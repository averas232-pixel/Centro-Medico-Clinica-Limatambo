using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IRecetaRepository
    {
        Receta ObtenerPorId(int id);
        List<Receta> ObtenerPorPaciente(int pacienteId);
    }
}