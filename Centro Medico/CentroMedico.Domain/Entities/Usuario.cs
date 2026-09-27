namespace CentroMedico.Domain.Entities
{
    public class Usuario
    {
        public int UsuarioID { get; set; }
        public string NombreUsuario { get; set; }
        public string PasswordHash { get; set; }
        public string Salt { get; set; }
        public string NombreCompleto { get; set; }
        public string Rol { get; set; }
        public bool Activo { get; set; }
    }
}