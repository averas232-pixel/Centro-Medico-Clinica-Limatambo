using System;
using CentroMedico.Domain.Contracts;

namespace CentroMedico.Application.Validators
{
    public static class CierreConsultaValidator
    {
        public static void Validar(CierreConsultaData datos)
        {
            if (datos.CitaID <= 0)
                throw new ArgumentException("Debe indicar una cita válida.");
            if (string.IsNullOrWhiteSpace(datos.Diagnostico))
                throw new ArgumentException("El diagnóstico es obligatorio.");
            if (datos.MontoConsulta <= 0)
                throw new ArgumentException("El monto de consulta debe ser mayor a 0.");
            foreach (var item in datos.InsumosRecetados)
                if (item.Cantidad <= 0)
                    throw new ArgumentException($"Cantidad inválida para el insumo {item.InsumoID}.");
        }
    }
}