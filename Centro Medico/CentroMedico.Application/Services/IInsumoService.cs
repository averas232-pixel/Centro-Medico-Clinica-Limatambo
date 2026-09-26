using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Application.Services
{
    public interface IInsumoService
    {
        List<Insumo> ObtenerTodos();
    }
}