using System;
using System.Windows;
using Microsoft.Extensions.DependencyInjection;
using CentroMedico.Application.Services;
using CentroMedico.Domain.Entities;

namespace Centro_Medico_UI
{
    public partial class NuevoPacienteWindow : Window
    {
        public Paciente PacienteCreado { get; private set; }

        public NuevoPacienteWindow()
        {
            InitializeComponent();
        }

        private void Guardar_Click(object sender, RoutedEventArgs e)
        {
            if (DniText.Text.Trim().Length != 8)
            { MostrarError("El DNI debe tener 8 dígitos."); return; }
            if (string.IsNullOrWhiteSpace(NombresText.Text) || string.IsNullOrWhiteSpace(ApellidosText.Text))
            { MostrarError("Nombres y apellidos son obligatorios."); return; }
            if (FechaNacPicker.SelectedDate is not DateTime fechaNac)
            { MostrarError("Selecciona la fecha de nacimiento."); return; }
            if (SexoCombo.SelectedItem is not System.Windows.Controls.ComboBoxItem sexoItem)
            { MostrarError("Selecciona el sexo."); return; }
            if (string.IsNullOrWhiteSpace(TelefonoText.Text) || string.IsNullOrWhiteSpace(DireccionText.Text))
            { MostrarError("Teléfono y dirección son obligatorios."); return; }

            var paciente = new Paciente
            {
                DNI = DniText.Text.Trim(),
                Nombres = NombresText.Text.Trim(),
                Apellidos = ApellidosText.Text.Trim(),
                FechaNacimiento = fechaNac,
                Sexo = sexoItem.Content.ToString()[0],
                Telefono = TelefonoText.Text.Trim(),
                Direccion = DireccionText.Text.Trim(),
                Email = string.IsNullOrWhiteSpace(EmailText.Text) ? null : EmailText.Text.Trim()
            };

            try
            {
                var pacienteService = App.ServiceProvider.GetRequiredService<IPacienteService>();
                paciente.PacienteID = pacienteService.RegistrarPaciente(paciente);
                PacienteCreado = paciente;
                DialogResult = true;
            }
            catch (Exception ex)
            {
                MostrarError($"No se pudo registrar: {ex.Message}");
            }
        }

        private void MostrarError(string mensaje)
        {
            ErrorText.Text = mensaje;
            ErrorText.Visibility = Visibility.Visible;
        }
    }
}