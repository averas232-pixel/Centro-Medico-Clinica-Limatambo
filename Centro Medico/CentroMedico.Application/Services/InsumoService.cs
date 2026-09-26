using System.Collections.Generic;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;

namespace CentroMedico.Application.Services
{
    public class InsumoService : IInsumoService
    {
        private readonly IInsumoRepository _insumoRepository;

        public InsumoService(IInsumoRepository insumoRepository)
        {
            _insumoRepository = insumoRepository;
        }

        public List<Insumo> ObtenerTodos() => _insumoRepository.ObtenerTodos();
    }
}