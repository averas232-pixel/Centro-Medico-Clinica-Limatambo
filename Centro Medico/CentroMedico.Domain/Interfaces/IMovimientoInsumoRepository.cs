using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IMovimientoInsumoRepository
    {
        List<MovimientoInsumo> ObtenerPorInsumo(int insumoId);
    }
}