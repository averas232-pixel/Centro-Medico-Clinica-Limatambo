using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IInsumoRepository
    {
        Insumo ObtenerPorId(int id);
        List<Insumo> ObtenerTodos();
    }
}