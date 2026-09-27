using System;
using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Application.Services
{
    public interface IFacturaService
    {
        List<Factura> ObtenerTodas();
        Factura ObtenerPorId(int id);
    }
}