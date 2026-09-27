using System.Windows;
using Microsoft.Extensions.DependencyInjection;
using CentroMedico.Application.Services;
using CentroMedico.Domain.Entities;

namespace Centro_Medico_UI
{
    public partial class LoginWindow : Window
    {
        public Usuario UsuarioAutenticado { get; private set; }

        public LoginWindow()
        {
            InitializeComponent();
        }

        private void LoginButton_Click(object sender, RoutedEventArgs e)
        {
            var usuario = UsuarioText.Text.Trim();
            var password = PasswordBox.Password;

            if (string.IsNullOrWhiteSpace(usuario) || string.IsNullOrWhiteSpace(password))
            {
                MostrarError("Ingresa usuario y contraseña.");
                return;
            }

            var authService = App.ServiceProvider.GetRequiredService<IAuthService>();
            var resultado = authService.Login(usuario, password);

            if (resultado == null)
            {
                MostrarError("Usuario o contraseña incorrectos.");
                return;
            }

            UsuarioAutenticado = resultado;
            DialogResult = true;
        }

        private void MostrarError(string mensaje)
        {
            ErrorText.Text = mensaje;
            ErrorText.Visibility = Visibility.Visible;
        }
    }
}