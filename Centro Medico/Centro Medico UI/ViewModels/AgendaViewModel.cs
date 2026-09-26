using System;
using System.Collections.ObjectModel;
using System.Windows.Input;
using CentroMedico.Domain.Entities;
using CentroMedico.Application.Services;
using Centro_Medico_UI.Commands;

namespace Centro_Medico_UI.ViewModels
{
    public class AgendaViewModel : ViewModelBase
    {
        private readonly ICitaService _citaService;

        private ObservableCollection<Cita> _citas;
        public ObservableCollection<Cita> Citas
        {
            get => _citas;
            set => SetProperty(ref _citas, value);
        }

        private DateTime _fechaSeleccionada = DateTime.Today;
        public DateTime FechaSeleccionada
        {
            get => _fechaSeleccionada;
            set
            {
                if (SetProperty(ref _fechaSeleccionada, value))
                    CargarAgenda();
            }
        }

        private string _mensaje;
        public string Mensaje
        {
            get => _mensaje;
            set => SetProperty(ref _mensaje, value);
        }

        public ICommand CargarAgendaCommand { get; }

        public AgendaViewModel(ICitaService citaService)
        {
            _citaService = citaService;
            Citas = new ObservableCollection<Cita>();
            CargarAgendaCommand = new RelayCommand(_ => CargarAgenda());

            CargarAgenda();
        }

        private void CargarAgenda()
        {
            try
            {
                var lista = _citaService.ObtenerAgendaDelDia(FechaSeleccionada);
                Citas = new ObservableCollection<Cita>(lista);
                Mensaje = Citas.Count == 0 ? "No hay citas para esta fecha." : string.Empty;
            }
            catch (Exception ex)
            {
                Mensaje = $"Error al cargar la agenda: {ex.Message}";
            }
        }
    }
}