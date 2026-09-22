using System.Collections.Generic;
using CentroMedico.Domain.Entities;

namespace CentroMedico.Domain.Interfaces
{
    public interface IPacienteRepository
    {
        Paciente ObtenerPorId(int id);
        List<Paciente> ObtenerTodos();
        int Registrar(Paciente paciente);
    }
}