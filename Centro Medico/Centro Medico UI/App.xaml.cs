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

        protected override void OnStartup(StartupEventArgs e)
        {
            var services = new ServiceCollection();
            ConfigurarServicios(services);
            ServiceProvider = services.BuildServiceProvider();

            base.OnStartup(e);

            var mainWindow = ServiceProvider.GetRequiredService<MainWindow>();
            mainWindow.Show();
        }

        private void ConfigurarServicios(ServiceCollection services)
        {
            // Repositorios (Infrastructure)
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

            // Servicios (Application)
            services.AddScoped<IConsultaService, ConsultaService>();
            services.AddScoped<ICitaService, CitaService>();
            services.AddScoped<IPacienteService, PacienteService>();
            services.AddScoped<IInsumoService, InsumoService>();

            // Ventanas
            services.AddTransient<MainWindow>();
        }
    }
}