using CentroMedico.Domain.Entities;

namespace CentroMedico.Application.Services
{
    public interface IAuthService
    {
        Usuario Login(string nombreUsuario, string password);
    }
}