using System;

namespace CentroMedico.Domain.Entities
{
    public class Paciente
    {
        public int PacienteID { get; set; }
        public string DNI { get; set; }
        public string Nombres { get; set; }
        public string Apellidos { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public char Sexo { get; set; }
        public string Telefono { get; set; }
        public string Direccion { get; set; }
        public string Email { get; set; }
        public bool Activo { get; set; }

        public string NombreCompleto => $"{Nombres} {Apellidos}";
    }
}