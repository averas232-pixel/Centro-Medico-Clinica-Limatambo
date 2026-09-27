using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Input;
using CentroMedico.Domain.Entities;
using CentroMedico.Application.Services;
using Centro_Medico_UI.Commands;

namespace Centro_Medico_UI.ViewModels
{
    public class HistorialViewModel : ViewModelBase
    {
        private readonly IPacienteService _pacienteService;
        private readonly IHistorialService _historialService;

        private ObservableCollection<Paciente> TodosPacientes { get; } = new();
        public ObservableCollection<Paciente> Sugerencias { get; } = new();
        public ObservableCollection<HistorialClinico> Historiales { get; } = new();

        private string _busquedaPaciente = string.Empty;
        public string BusquedaPaciente
        {
            get => _busquedaPaciente;
            set
            {
                if (SetProperty(ref _busquedaPaciente, value))
                    FiltrarSugerencias();
            }
        }

        private Paciente _pacienteSeleccionado;
        public Paciente PacienteSeleccionado
        {
            get => _pacienteSeleccionado;
            private set
            {
                if (SetProperty(ref _pacienteSeleccionado, value))
                {
                    OnPropertyChanged(nameof(FichaVisible));
                    OnPropertyChanged(nameof(EdadPaciente));
                }
            }
        }

        public int? EdadPaciente
        {
            get
            {
                if (PacienteSeleccionado == null) return null;
                var hoy = DateTime.Today;
                var nacimiento = PacienteSeleccionado.FechaNacimiento;
                var edad = hoy.Year - nacimiento.Year;
                if (nacimiento.Date > hoy.AddYears(-edad)) edad--;
                return edad;
            }
        }

        public Visibility FichaVisible => PacienteSeleccionado != null ? Visibility.Visible : Visibility.Collapsed;
        public Visibility SugerenciasVisibles => Sugerencias.Count > 0 ? Visibility.Visible : Visibility.Collapsed;
        public Visibility SinSeleccionVisible => PacienteSeleccionado == null ? Visibility.Visible : Visibility.Collapsed;
        public Visibility SinHistorialVisible => PacienteSeleccionado != null && Historiales.Count == 0 ? Visibility.Visible : Visibility.Collapsed;

        public ICommand SeleccionarPacienteCommand { get; }

        public HistorialViewModel(IPacienteService pacienteService, IHistorialService historialService)
        {
            _pacienteService = pacienteService;
            _historialService = historialService;
            SeleccionarPacienteCommand = new RelayCommand(p => SeleccionarPaciente(p as Paciente));

            CargarPacientes();
        }

        private void CargarPacientes()
        {
            var pacientes = _pacienteService.ObtenerTodos();
            TodosPacientes.Clear();
            foreach (var p in pacientes) TodosPacientes.Add(p);
        }

        private void FiltrarSugerencias()
        {
            Sugerencias.Clear();

            if (!string.IsNullOrWhiteSpace(BusquedaPaciente))
            {
                var texto = BusquedaPaciente.Trim().ToLowerInvariant();
                var resultados = TodosPacientes
                    .Where(p => p.NombreCompleto.ToLowerInvariant().Contains(texto) || p.DNI.Contains(texto))
                    .Take(8);
                foreach (var p in resultados) Sugerencias.Add(p);
            }

            OnPropertyChanged(nameof(SugerenciasVisibles));
        }

        private void SeleccionarPaciente(Paciente paciente)
        {
            if (paciente == null) return;

            PacienteSeleccionado = paciente;
            _busquedaPaciente = paciente.NombreCompleto; 
            OnPropertyChanged(nameof(BusquedaPaciente));
            Sugerencias.Clear();
            OnPropertyChanged(nameof(SugerenciasVisibles));

            CargarHistorial();
        }

        private void CargarHistorial()
        {
            Historiales.Clear();
            var lista = _historialService.ObtenerPorPaciente(PacienteSeleccionado.PacienteID);
            foreach (var h in lista) Historiales.Add(h);
            OnPropertyChanged(nameof(SinHistorialVisible));
        }
    }
}