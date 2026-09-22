namespace CentroMedico.Domain.Entities
{
    public class Medico
    {
        public int MedicoID { get; set; }
        public string CMP { get; set; }
        public string Nombres { get; set; }
        public string Apellidos { get; set; }
        public int EspecialidadID { get; set; }
        public string Especialidad { get; set; }
        public bool Activo { get; set; }

        public string NombreCompleto => $"{Nombres} {Apellidos}";
    }
}