using System;

namespace CentroMedico.Domain.Entities
{
    public enum EstadoCita { Programada, Atendida, Cancelada }

    public class Cita
    {
        public int CitaID { get; set; }
        public int PacienteID { get; set; }
        public int MedicoID { get; set; }
        public string NombrePaciente { get; set; } = string.Empty;
        public string NombreMedico { get; set; } = string.Empty;
        public DateTime FechaHora { get; set; }
        public EstadoCita Estado { get; set; }
        public string Motivo { get; set; }
    }
}
