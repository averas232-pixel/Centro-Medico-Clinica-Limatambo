using System;
using System.Globalization;
using System.Windows.Data;
using System.Windows.Media;
using CentroMedico.Domain.Entities;

namespace Centro_Medico_UI.Converters
{
    public class EstadoFacturaBgConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is EstadoFactura estado)
                return estado == EstadoFactura.Pagada
                    ? new SolidColorBrush(Color.FromRgb(0xE6, 0xF4, 0xEA))
                    : new SolidColorBrush(Color.FromRgb(0xEF, 0xEF, 0xEF));
            return Brushes.Transparent;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
            => throw new NotImplementedException();
    }

    public class EstadoFacturaFgConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is EstadoFactura estado)
                return estado == EstadoFactura.Pagada
                    ? new SolidColorBrush(Color.FromRgb(0x1E, 0x8E, 0x3E))
                    : new SolidColorBrush(Color.FromRgb(0x6B, 0x6B, 0x6B));
            return Brushes.Black;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
            => throw new NotImplementedException();
    }
}