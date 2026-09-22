using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IMedicoRepository
    {
        Medico ObtenerPorId(int id);
        List<Medico> ObtenerActivos();
    }
}