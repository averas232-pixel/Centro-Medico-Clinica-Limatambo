using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using CentroMedico.Domain.Entities;
using CentroMedico.Application.Services;

namespace Centro_Medico_UI.ViewModels
{
    public class FacturacionViewModel : ViewModelBase
    {
        private readonly IFacturaService _facturaService;

        public ObservableCollection<Factura> Facturas { get; } = new();

        private Factura _facturaSeleccionada;
        public Factura FacturaSeleccionada
        {
            get => _facturaSeleccionada;
            set
            {
                if (SetProperty(ref _facturaSeleccionada, value))
                    OnPropertyChanged(nameof(DetalleVisible));
            }
        }

        public Visibility DetalleVisible => FacturaSeleccionada != null ? Visibility.Visible : Visibility.Collapsed;
        public Visibility SinSeleccionVisible => FacturaSeleccionada == null ? Visibility.Visible : Visibility.Collapsed;

        public decimal TotalFacturado => Facturas.Where(f => f.Estado == EstadoFactura.Pagada).Sum(f => f.Total);
        public int CantidadPagadas => Facturas.Count(f => f.Estado == EstadoFactura.Pagada);
        public int CantidadAnuladas => Facturas.Count(f => f.Estado == EstadoFactura.Anulada);

        public FacturacionViewModel(IFacturaService facturaService)
        {
            _facturaService = facturaService;
            CargarFacturas();
        }

        public void CargarFacturas()
        {
            Facturas.Clear();
            var lista = _facturaService.ObtenerTodas();
            foreach (var f in lista) Facturas.Add(f);

            OnPropertyChanged(nameof(TotalFacturado));
            OnPropertyChanged(nameof(CantidadPagadas));
            OnPropertyChanged(nameof(CantidadAnuladas));
        }
    }
}