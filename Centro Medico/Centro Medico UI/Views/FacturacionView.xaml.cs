using System.Windows;
using System.Windows.Controls;
using CentroMedico.Domain.Entities;
using Centro_Medico_UI.ViewModels;

namespace Centro_Medico_UI.Views
{
    public partial class FacturacionView : UserControl
    {
        public FacturacionView()
        {
            InitializeComponent();
        }

        private void FacturaItem_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button boton && boton.DataContext is Factura factura &&
                DataContext is FacturacionViewModel vm)
            {
                vm.FacturaSeleccionada = factura;
            }
        }
    }
}