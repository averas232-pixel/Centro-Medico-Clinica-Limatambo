using System.Security.Cryptography;
using System.Text;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;

namespace CentroMedico.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUsuarioRepository _usuarioRepository;

        public AuthService(IUsuarioRepository usuarioRepository)
        {
            _usuarioRepository = usuarioRepository;
        }

        public Usuario Login(string nombreUsuario, string password)
        {
            var usuario = _usuarioRepository.ObtenerPorNombreUsuario(nombreUsuario);
            if (usuario == null) return null;

            var hashCalculado = CalcularHash(password, usuario.Salt);
            return hashCalculado == usuario.PasswordHash ? usuario : null;
        }

        private static string CalcularHash(string password, string salt)
        {
            using var sha256 = SHA256.Create();
            var bytes = Encoding.UTF8.GetBytes(password + salt);
            var hash = sha256.ComputeHash(bytes);
            var sb = new StringBuilder();
            foreach (var b in hash) sb.Append(b.ToString("x2"));
            return sb.ToString();
        }
    }
}