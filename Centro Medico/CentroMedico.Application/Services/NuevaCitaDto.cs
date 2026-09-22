using System;

namespace CentroMedico.Application.Services
{
    public class NuevaCitaDto
    {
        public int PacienteID { get; set; }
        public int MedicoID { get; set; }
        public DateTime FechaHora { get; set; }
        public string Motivo { get; set; }
    }
}