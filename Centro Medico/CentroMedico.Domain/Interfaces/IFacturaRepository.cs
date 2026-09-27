using System;
using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IFacturaRepository
    {
        Factura ObtenerPorId(int id);
        List<Factura> ObtenerTodas();
        List<Factura> ObtenerPorRangoFechas(DateTime desde, DateTime hasta);
    }
}