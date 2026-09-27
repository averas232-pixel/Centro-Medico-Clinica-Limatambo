using System.Collections.Generic;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;

namespace CentroMedico.Application.Services
{
    public class FacturaService : IFacturaService
    {
        private readonly IFacturaRepository _facturaRepository;

        public FacturaService(IFacturaRepository facturaRepository)
        {
            _facturaRepository = facturaRepository;
        }

        public List<Factura> ObtenerTodas() => _facturaRepository.ObtenerTodas();
        public Factura ObtenerPorId(int id) => _facturaRepository.ObtenerPorId(id);
    }
}