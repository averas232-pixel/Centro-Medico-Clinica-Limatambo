using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace Centro_Medico_UI.Views
{
    /// <summary>
    /// Lógica de interacción para AgendaView.xaml
    /// </summary>
    public partial class AgendaView : UserControl   
    {
        private void NuevaCita_Click(object sender, RoutedEventArgs e)
        {
            if (DataContext is not Centro_Medico_UI.ViewModels.AgendaViewModel agenda) return;
            using var scope = Microsoft.Extensions.DependencyInjection.ServiceProviderServiceExtensions.CreateScope(App.ServiceProvider);
            var provider = scope.ServiceProvider;
            var dialog = new NuevaCitaWindow(
                Microsoft.Extensions.DependencyInjection.ServiceProviderServiceExtensions.GetRequiredService<CentroMedico.Application.Services.IPacienteService>(provider),
                Microsoft.Extensions.DependencyInjection.ServiceProviderServiceExtensions.GetRequiredService<CentroMedico.Domain.Interfaces.IMedicoRepository>(provider),
                Microsoft.Extensions.DependencyInjection.ServiceProviderServiceExtensions.GetRequiredService<CentroMedico.Application.Services.ICitaService>(provider),
                agenda.FechaSeleccionada)
            { Owner = Window.GetWindow(this) };
            if (dialog.ShowDialog() == true)
            {
                if (agenda.FechaSeleccionada.Date == dialog.FechaRegistrada.Date)
                    agenda.CargarAgendaCommand.Execute(null);
                else
                    agenda.FechaSeleccionada = dialog.FechaRegistrada.Date;
                MessageBox.Show(Window.GetWindow(this), "Cita registrada correctamente.", "Nueva cita",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        public AgendaView()
        {
            InitializeComponent();
        }
    }
}