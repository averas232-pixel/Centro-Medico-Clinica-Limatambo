using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows.Input;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Contracts;
using CentroMedico.Application.Services;
using Centro_Medico_UI.Commands;

namespace Centro_Medico_UI.ViewModels
{
    public class ItemRecetaVM
    {
        public int InsumoID { get; set; }
        public string NombreInsumo { get; set; }
        public int Cantidad { get; set; }
        public string Dosis { get; set; }
    }

    public class ConsultaViewModel : ViewModelBase
    {
        private readonly IConsultaService _consultaService;
        private readonly ICitaService _citaService;
        private readonly IInsumoService _insumoService;

        public ObservableCollection<Cita> Citas { get; } = new();
        public ObservableCollection<Insumo> InsumosDisponibles { get; } = new();
        public ObservableCollection<ItemRecetaVM> ItemsReceta { get; } = new();
        public Array MetodosPago => Enum.GetValues(typeof(MetodoPago));

        private Cita _citaSeleccionada;
        public Cita CitaSeleccionada
        {
            get => _citaSeleccionada;
            set => SetProperty(ref _citaSeleccionada, value);
        }

        private string _diagnostico;
        public string Diagnostico
        {
            get => _diagnostico;
            set => SetProperty(ref _diagnostico, value);
        }

        private string _observaciones;
        public string Observaciones
        {
            get => _observaciones;
            set => SetProperty(ref _observaciones, value);
        }

        private string _indicacionesReceta;
        public string IndicacionesReceta
        {
            get => _indicacionesReceta;
            set => SetProperty(ref _indicacionesReceta, value);
        }

        private decimal _montoConsulta = 50m;
        public decimal MontoConsulta
        {
            get => _montoConsulta;
            set => SetProperty(ref _montoConsulta, value);
        }

        private MetodoPago _metodoPagoSeleccionado = MetodoPago.Efectivo;
        public MetodoPago MetodoPagoSeleccionado
        {
            get => _metodoPagoSeleccionado;
            set => SetProperty(ref _metodoPagoSeleccionado, value);
        }

        private Insumo _insumoSeleccionado;
        public Insumo InsumoSeleccionado
        {
            get => _insumoSeleccionado;
            set => SetProperty(ref _insumoSeleccionado, value);
        }

        private int _cantidadInsumo = 1;
        public int CantidadInsumo
        {
            get => _cantidadInsumo;
            set => SetProperty(ref _cantidadInsumo, value);
        }

        private string _dosisInsumo;
        public string DosisInsumo
        {
            get => _dosisInsumo;
            set => SetProperty(ref _dosisInsumo, value);
        }

        private string _mensaje;
        public string Mensaje
        {
            get => _mensaje;
            set => SetProperty(ref _mensaje, value);
        }

        private bool _esError;
        public bool EsError
        {
            get => _esError;
            set => SetProperty(ref _esError, value);
        }

        public ICommand AgregarInsumoCommand { get; }
        public ICommand QuitarInsumoCommand { get; }
        public ICommand CerrarConsultaCommand { get; }

        public ConsultaViewModel(IConsultaService consultaService, ICitaService citaService, IInsumoService insumoService)
        {
            _consultaService = consultaService;
            _citaService = citaService;
            _insumoService = insumoService;

            AgregarInsumoCommand = new RelayCommand(_ => AgregarInsumo());
            QuitarInsumoCommand = new RelayCommand(item => QuitarInsumo(item as ItemRecetaVM));
            CerrarConsultaCommand = new RelayCommand(_ => EjecutarCierreConsulta());

            CargarDatosIniciales();
        }

        private void CargarDatosIniciales()
        {
            var citas = _citaService.ObtenerTodas();
            Citas.Clear();
            foreach (var c in citas) Citas.Add(c);

            var insumos = _insumoService.ObtenerTodos();
            InsumosDisponibles.Clear();
            foreach (var i in insumos) InsumosDisponibles.Add(i);
        }

        private void AgregarInsumo()
        {
            if (InsumoSeleccionado == null)
            {
                Mensaje = "Selecciona un insumo antes de agregarlo.";
                EsError = true;
                return;
            }
            if (CantidadInsumo <= 0)
            {
                Mensaje = "La cantidad debe ser mayor a 0.";
                EsError = true;
                return;
            }

            ItemsReceta.Add(new ItemRecetaVM
            {
                InsumoID = InsumoSeleccionado.InsumoID,
                NombreInsumo = InsumoSeleccionado.Nombre,
                Cantidad = CantidadInsumo,
                Dosis = string.IsNullOrWhiteSpace(DosisInsumo) ? "Según indicación médica" : DosisInsumo
            });

            CantidadInsumo = 1;
            DosisInsumo = string.Empty;
            Mensaje = string.Empty;
        }

        private void QuitarInsumo(ItemRecetaVM item)
        {
            if (item != null) ItemsReceta.Remove(item);
        }

        private void EjecutarCierreConsulta()
        {
            if (CitaSeleccionada == null)
            {
                Mensaje = "Debes seleccionar una cita.";
                EsError = true;
                return;
            }

            var datos = new CierreConsultaData
            {
                CitaID = CitaSeleccionada.CitaID,
                Diagnostico = Diagnostico,
                Observaciones = Observaciones,
                IndicacionesReceta = IndicacionesReceta,
                MontoConsulta = MontoConsulta,
                MetodoPago = MetodoPagoSeleccionado,
                InsumosRecetados = ItemsReceta.Select(i => new ItemInsumoDto
                {
                    InsumoID = i.InsumoID,
                    Cantidad = i.Cantidad,
                    Dosis = i.Dosis
                }).ToList()
            };

            ResultadoCierreConsulta resultado;
            try
            {
                resultado = _consultaService.CerrarConsulta(datos);
            }
            catch (Exception ex)
            {
                Mensaje = $"No se pudo cerrar la consulta: {ex.Message}";
                EsError = true;
                return;
            }

            if (resultado.Exitoso)
            {
                Mensaje = $"Consulta cerrada con éxito. Boleta {resultado.SerieCorrelativo} - Total S/ {resultado.Total:F2}";
                EsError = false;
                LimpiarFormulario();
                CargarDatosIniciales(); 
            }
            else
            {
                Mensaje = $"La transacción se revirtió (Rollback): {resultado.MensajeError}";
                EsError = true;
            }
        }

        private void LimpiarFormulario()
        {
            CitaSeleccionada = null;
            Diagnostico = string.Empty;
            Observaciones = string.Empty;
            IndicacionesReceta = string.Empty;
            MontoConsulta = 50m;
            MetodoPagoSeleccionado = MetodoPago.Efectivo;
            ItemsReceta.Clear();
        }
    }
}