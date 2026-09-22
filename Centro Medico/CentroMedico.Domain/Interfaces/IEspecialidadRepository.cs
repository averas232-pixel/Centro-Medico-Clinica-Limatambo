using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IEspecialidadRepository
    {
        List<Especialidad> ObtenerTodas();
    }
}