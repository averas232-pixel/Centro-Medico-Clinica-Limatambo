using System.Windows;
using Microsoft.Extensions.DependencyInjection;
using CentroMedico.Application.Services;
using Centro_Medico_UI.ViewModels;
using Centro_Medico_UI.Views;

namespace Centro_Medico_UI
{
    public partial class MainWindow : Window
    {
        private AgendaView _agendaView;
        private ConsultaView _consultaView;

        public MainWindow()
        {
            InitializeComponent();
            NavAgenda.IsChecked = true;
        }

        private void NavAgenda_Checked(object sender, RoutedEventArgs e)
        {
            if (_agendaView == null)
            {
                var citaService = App.ServiceProvider.GetRequiredService<ICitaService>();
                var viewModel = new AgendaViewModel(citaService);
                _agendaView = new AgendaView { DataContext = viewModel };
            }
            ContenidoPrincipal.Content = _agendaView;
        }

        private void NavConsulta_Checked(object sender, RoutedEventArgs e)
        {
            if (_consultaView == null)
            {
                var consultaService = App.ServiceProvider.GetRequiredService<IConsultaService>();
                var citaService = App.ServiceProvider.GetRequiredService<ICitaService>();
                var insumoService = App.ServiceProvider.GetRequiredService<IInsumoService>();
                var viewModel = new ConsultaViewModel(consultaService, citaService, insumoService);
                _consultaView = new ConsultaView { DataContext = viewModel };
            }
            ContenidoPrincipal.Content = _consultaView;
        }

        private void NavHistorial_Checked(object sender, RoutedEventArgs e)
        {
        }

        private void NavFacturacion_Checked(object sender, RoutedEventArgs e)
        {
        }
    }
}