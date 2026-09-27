namespace CentroMedico.Domain.Interfaces
{
    public interface IUsuarioRepository
    {
        Domain.Entities.Usuario ObtenerPorNombreUsuario(string nombreUsuario);
    }
}