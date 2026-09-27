using System.Windows;
using Microsoft.Extensions.DependencyInjection;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Repositories;
using CentroMedico.Application.Services;

namespace Centro_Medico_UI
{
    public partial class App : Application
    {
        public static IServiceProvider ServiceProvider { get; private set; }
        public static CentroMedico.Domain.Entities.Usuario UsuarioActual { get; set; }

        protected override void OnStartup(StartupEventArgs e)
        {
            ShutdownMode = ShutdownMode.OnExplicitShutdown; // no cerrar automáticamente al cerrar el login

            var services = new ServiceCollection();
            ConfigurarServicios(services);
            ServiceProvider = services.BuildServiceProvider();

            base.OnStartup(e);

            var login = new LoginWindow();
            bool loginExitoso = login.ShowDialog() == true;

            if (loginExitoso)
            {
                UsuarioActual = login.UsuarioAutenticado;
                var mainWindow = ServiceProvider.GetRequiredService<MainWindow>();
                ShutdownMode = ShutdownMode.OnMainWindowClose; // ahora sí, cerrar cuando se cierre MainWindow
                mainWindow.Show();
            }
            else
            {
                Shutdown();
            }
        }

        private void ConfigurarServicios(ServiceCollection services)
        {
            services.AddScoped<IPacienteRepository, PacienteRepository>();
            services.AddScoped<IMedicoRepository, MedicoRepository>();
            services.AddScoped<IEspecialidadRepository, EspecialidadRepository>();
            services.AddScoped<ICitaRepository, CitaRepository>();
            services.AddScoped<IHistorialRepository, HistorialRepository>();
            services.AddScoped<IInsumoRepository, InsumoRepository>();
            services.AddScoped<IMovimientoInsumoRepository, MovimientoInsumoRepository>();
            services.AddScoped<IRecetaRepository, RecetaRepository>();
            services.AddScoped<IFacturaRepository, FacturaRepository>();
            services.AddScoped<IConsultaRepository, ConsultaRepository>();
            services.AddScoped<IUsuarioRepository, UsuarioRepository>();

            services.AddScoped<IConsultaService, ConsultaService>();
            services.AddScoped<ICitaService, CitaService>();
            services.AddScoped<IPacienteService, PacienteService>();
            services.AddScoped<IInsumoService, InsumoService>();
            services.AddScoped<IHistorialService, HistorialService>();
            services.AddScoped<IFacturaService, FacturaService>();
            services.AddScoped<IAuthService, AuthService>();

            services.AddTransient<MainWindow>();
        }
    }
}