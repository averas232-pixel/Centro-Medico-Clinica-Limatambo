using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Application.Services
{
    public interface IPacienteService
    {
        List<Paciente> ObtenerTodos();
        Paciente ObtenerPorId(int id);
    }
}