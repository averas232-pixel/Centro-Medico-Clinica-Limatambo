using System;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using CentroMedico.Application.Services;
using CentroMedico.Domain.Entities;
using CentroMedico.Domain.Interfaces;

namespace Centro_Medico_UI.Views
{
    public partial class NuevaCitaWindow : Window
    {
        private readonly IPacienteService _pacientes;
        private readonly IMedicoRepository _medicos;
        private readonly ICitaService _citas;
        private bool _guardando;
        public DateTime FechaRegistrada { get; private set; }

        public NuevaCitaWindow(IPacienteService pacientes, IMedicoRepository medicos,
            ICitaService citas, DateTime fecha)
        {
            InitializeComponent();
            _pacientes = pacientes;
            _medicos = medicos;
            _citas = citas;
            FechaPicker.DisplayDateStart = DateTime.Today;
            FechaPicker.SelectedDate = fecha.Date < DateTime.Today ? DateTime.Today : fecha.Date;
        }

        private async void Window_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                var pacientes = await Task.Run(() => _pacientes.ObtenerTodos()
                    .Where(p => p.Activo).OrderBy(p => p.Apellidos).ThenBy(p => p.Nombres).ToList());
                var medicos = await Task.Run(() => _medicos.ObtenerActivos());
                PacienteCombo.ItemsSource = pacientes;
                MedicoCombo.ItemsSource = medicos;
                if (pacientes.Count == 0 || medicos.Count == 0)
                {
                    EstadoText.Text = "Se necesita al menos un paciente y un médico activos para crear una cita.";
                    return;
                }
                Formulario.IsEnabled = true;
                GuardarButton.IsEnabled = true;
                EstadoText.Text = "Selecciona el paciente y el médico.";
                PacienteCombo.Focus();
            }
            catch (Exception ex)
            {
                EstadoText.Text = "No se pudieron cargar los datos. Cierra y vuelve a intentar.";
                EstadoText.ToolTip = ex.Message;
            }
        }

        private void NuevoPaciente_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new NuevoPacienteWindow { Owner = this };
            if (dialog.ShowDialog() == true && dialog.PacienteCreado != null)
            {
                var pacientes = _pacientes.ObtenerTodos()
                    .Where(p => p.Activo).OrderBy(p => p.Apellidos).ThenBy(p => p.Nombres).ToList();
                PacienteCombo.ItemsSource = pacientes;
                PacienteCombo.SelectedItem = pacientes.FirstOrDefault(p => p.PacienteID == dialog.PacienteCreado.PacienteID);
            }
        }

        private void Error(string mensaje, Control campo)
        {
            EstadoText.Text = mensaje;
            EstadoText.Foreground = (System.Windows.Media.Brush)FindResource("ErrorBrush");
            campo.Focus();
        }

        private async void Guardar_Click(object sender, RoutedEventArgs e)
        {
            if (_guardando) return;
            if (PacienteCombo.SelectedItem is not Paciente paciente)
            { Error("Selecciona un paciente.", PacienteCombo); return; }
            if (MedicoCombo.SelectedItem is not Medico medico)
            { Error("Selecciona un médico.", MedicoCombo); return; }
            if (FechaPicker.SelectedDate is not DateTime fecha)
            { Error("Selecciona una fecha.", FechaPicker); return; }
            if (!DateTime.TryParseExact(HoraText.Text.Trim(), "HH:mm", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out var hora))
            { Error("Escribe una hora válida en formato de 24 horas, por ejemplo 14:30.", HoraText); return; }
            var fechaHora = fecha.Date.Add(hora.TimeOfDay);
            if (fechaHora <= DateTime.Now)
            { Error("La fecha y hora deben ser futuras.", FechaPicker); return; }
            if (string.IsNullOrWhiteSpace(MotivoText.Text))
            { Error("Escribe el motivo de la cita.", MotivoText); return; }

            var datos = new NuevaCitaDto
            {
                PacienteID = paciente.PacienteID,
                MedicoID = medico.MedicoID,
                FechaHora = fechaHora,
                Motivo = MotivoText.Text.Trim()
            };
            _guardando = true;
            Formulario.IsEnabled = GuardarButton.IsEnabled = CancelarButton.IsEnabled = false;
            GuardarButton.Content = "Guardando…";
            EstadoText.Foreground = (System.Windows.Media.Brush)FindResource("TextSecondaryBrush");
            EstadoText.Text = "Registrando la cita…";
            try
            {
                await Task.Run(() => _citas.RegistrarCita(datos));
                FechaRegistrada = fechaHora;
                _guardando = false;
                DialogResult = true;
            }
            catch (Exception ex)
            {
                EstadoText.Text = "No se pudo confirmar el registro. Revisa la agenda antes de volver a intentarlo.";
                EstadoText.Foreground = (System.Windows.Media.Brush)FindResource("ErrorBrush");
                EstadoText.ToolTip = ex.Message;
            }
            finally
            {
                _guardando = false;
                Formulario.IsEnabled = GuardarButton.IsEnabled = CancelarButton.IsEnabled = true;
                GuardarButton.Content = "Guardar cita";
            }
        }

        private void Window_Closing(object? sender, CancelEventArgs e)
        {
            if (_guardando) e.Cancel = true;
        }
    }
}