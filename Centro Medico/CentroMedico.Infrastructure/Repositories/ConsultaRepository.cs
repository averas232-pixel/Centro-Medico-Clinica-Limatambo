using System;
using System.Data;
using Microsoft.Data.SqlClient;
using CentroMedico.Domain.Contracts;
using CentroMedico.Domain.Interfaces;
using CentroMedico.Infrastructure.Data;

namespace CentroMedico.Infrastructure.Repositories
{
    public class ConsultaRepository : IConsultaRepository
    {
        public ResultadoCierreConsulta CerrarConsulta(CierreConsultaData datos)
        {
            using var conn = (SqlConnection)SqlConnectionFactory.CrearConexion();
            using SqlTransaction transaction = conn.BeginTransaction();

            try
            {
                //Registrar el historial clínico
                int historialId = InsertarHistorial(conn, transaction, datos);

                //Generar la receta
                int recetaId = InsertarReceta(conn, transaction, historialId, datos.IndicacionesReceta);

                //Por cada insumo recetado: validar stock, descontar y dejar rastro en el kardex
                decimal totalInsumos = 0m;
                foreach (var item in datos.InsumosRecetados)
                {
                    totalInsumos += ProcesarInsumo(conn, transaction, recetaId, item);
                }

                //Calcular montos y emitir la factura
                decimal subtotal = datos.MontoConsulta + totalInsumos;
                decimal igv = Math.Round(subtotal * 0.18m, 2);
                decimal total = subtotal + igv;

                var (serie, correlativo) = GenerarSerieCorrelativo(conn, transaction);
                int facturaId = InsertarFactura(conn, transaction, datos.CitaID, serie, correlativo,
                    subtotal, igv, total, datos.MetodoPago);

                InsertarDetalleFacturaConsulta(conn, transaction, facturaId, datos.MontoConsulta);
                if (totalInsumos > 0)
                    InsertarDetalleFacturaInsumos(conn, transaction, facturaId, totalInsumos);

                // Cerrar la cita
                ActualizarEstadoCita(conn, transaction, datos.CitaID);

                // Todo salió bien: confirmar los cambios de una sola vez
                transaction.Commit();

                return new ResultadoCierreConsulta
                {
                    Exitoso = true,
                    FacturaID = facturaId,
                    SerieCorrelativo = $"{serie}-{correlativo}",
                    Total = total
                };
            }
            catch (Exception ex)
            {
                // Si algo falló en cualquier paso, se deshace TODO: nada de historial,
                transaction.Rollback();

                return new ResultadoCierreConsulta
                {
                    Exitoso = false,
                    MensajeError = ex.Message
                };
            }
        }

        private int InsertarHistorial(SqlConnection conn, SqlTransaction tx, CierreConsultaData datos)
        {
            using var cmd = new SqlCommand(
                "INSERT INTO HistorialClinico (CitaID, Diagnostico, Observaciones, FechaRegistro) " +
                "VALUES (@citaId, @diag, @obs, GETDATE()); SELECT CAST(SCOPE_IDENTITY() AS INT);",
                conn, tx);
            cmd.Parameters.AddWithValue("@citaId", datos.CitaID);
            cmd.Parameters.AddWithValue("@diag", datos.Diagnostico);
            cmd.Parameters.AddWithValue("@obs", (object)datos.Observaciones ?? DBNull.Value);
            return (int)cmd.ExecuteScalar();
        }

        private int InsertarReceta(SqlConnection conn, SqlTransaction tx, int historialId, string indicaciones)
        {
            using var cmd = new SqlCommand(
                "INSERT INTO Recetas (HistorialID, FechaEmision, Indicaciones) " +
                "VALUES (@histId, GETDATE(), @ind); SELECT CAST(SCOPE_IDENTITY() AS INT);",
                conn, tx);
            cmd.Parameters.AddWithValue("@histId", historialId);
            cmd.Parameters.AddWithValue("@ind", indicaciones ?? "Sin indicaciones adicionales.");
            return (int)cmd.ExecuteScalar();
        }

        private decimal ProcesarInsumo(SqlConnection conn, SqlTransaction tx, int recetaId, ItemInsumoDto item)
        {
            // Bloquea la fila del insumo hasta el commit/rollback (evita que dos consultas
            using var cmdStock = new SqlCommand(
                "SELECT Stock, PrecioUnitario FROM Insumos WITH (UPDLOCK, ROWLOCK) WHERE InsumoID = @id",
                conn, tx);
            cmdStock.Parameters.AddWithValue("@id", item.InsumoID);

            int stockActual;
            decimal precioUnitario;
            using (var reader = cmdStock.ExecuteReader())
            {
                if (!reader.Read())
                    throw new InvalidOperationException($"El insumo #{item.InsumoID} no existe.");
                stockActual = reader.GetInt32(0);
                precioUnitario = reader.GetDecimal(1);
            }

            if (stockActual < item.Cantidad)
                throw new InvalidOperationException(
                    $"Stock insuficiente para el insumo #{item.InsumoID}: disponible {stockActual}, solicitado {item.Cantidad}.");

            int stockNuevo = stockActual - item.Cantidad;

            // Línea de la receta
            using var cmdDetalle = new SqlCommand(
                "INSERT INTO DetalleReceta (RecetaID, InsumoID, Cantidad, Dosis) " +
                "VALUES (@recId, @insId, @cant, @dosis); SELECT CAST(SCOPE_IDENTITY() AS INT);",
                conn, tx);
            cmdDetalle.Parameters.AddWithValue("@recId", recetaId);
            cmdDetalle.Parameters.AddWithValue("@insId", item.InsumoID);
            cmdDetalle.Parameters.AddWithValue("@cant", item.Cantidad);
            cmdDetalle.Parameters.AddWithValue("@dosis", item.Dosis ?? "Según indicación médica");
            int detalleId = (int)cmdDetalle.ExecuteScalar();

            // Kardex: deja rastro del descuento
            using var cmdMov = new SqlCommand(
                "INSERT INTO MovimientosInsumo (InsumoID, TipoMovimiento, Cantidad, StockAnterior, StockNuevo, " +
                "Motivo, ReferenciaDetalleRecetaID, FechaMovimiento) " +
                "VALUES (@insId, 'Salida', @cant, @anterior, @nuevo, @motivo, @detId, GETDATE())",
                conn, tx);
            cmdMov.Parameters.AddWithValue("@insId", item.InsumoID);
            cmdMov.Parameters.AddWithValue("@cant", item.Cantidad);
            cmdMov.Parameters.AddWithValue("@anterior", stockActual);
            cmdMov.Parameters.AddWithValue("@nuevo", stockNuevo);
            cmdMov.Parameters.AddWithValue("@motivo", $"Consumo por receta médica - Detalle #{detalleId}");
            cmdMov.Parameters.AddWithValue("@detId", detalleId);
            cmdMov.ExecuteNonQuery();

            // Descuenta el stock
            using var cmdUpdate = new SqlCommand(
                "UPDATE Insumos SET Stock = @nuevo WHERE InsumoID = @id", conn, tx);
            cmdUpdate.Parameters.AddWithValue("@nuevo", stockNuevo);
            cmdUpdate.Parameters.AddWithValue("@id", item.InsumoID);
            cmdUpdate.ExecuteNonQuery();

            return precioUnitario * item.Cantidad;
        }

        private (string serie, string correlativo) GenerarSerieCorrelativo(SqlConnection conn, SqlTransaction tx)
        {
            using var cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CAST(Correlativo AS INT)), 0) + 1 FROM Facturas WHERE Serie = 'B001'",
                conn, tx);
            int siguiente = (int)cmd.ExecuteScalar();
            return ("B001", siguiente.ToString("D8"));
        }

        private int InsertarFactura(SqlConnection conn, SqlTransaction tx, int citaId, string serie,
            string correlativo, decimal subtotal, decimal igv, decimal total, Domain.Entities.MetodoPago metodoPago)
        {
            string metodoTexto = metodoPago == Domain.Entities.MetodoPago.YapePlin ? "Yape/Plin" : metodoPago.ToString();

            using var cmd = new SqlCommand(
                "INSERT INTO Facturas (CitaID, Serie, Correlativo, FechaEmision, Subtotal, IGV, Total, MetodoPago, Estado) " +
                "VALUES (@citaId, @serie, @correlativo, GETDATE(), @subtotal, @igv, @total, @metodo, 'Pagada'); " +
                "SELECT CAST(SCOPE_IDENTITY() AS INT);", conn, tx);
            cmd.Parameters.AddWithValue("@citaId", citaId);
            cmd.Parameters.AddWithValue("@serie", serie);
            cmd.Parameters.AddWithValue("@correlativo", correlativo);
            cmd.Parameters.AddWithValue("@subtotal", subtotal);
            cmd.Parameters.AddWithValue("@igv", igv);
            cmd.Parameters.AddWithValue("@total", total);
            cmd.Parameters.AddWithValue("@metodo", metodoTexto);
            return (int)cmd.ExecuteScalar();
        }

        private void InsertarDetalleFacturaConsulta(SqlConnection conn, SqlTransaction tx, int facturaId, decimal monto)
        {
            using var cmd = new SqlCommand(
                "INSERT INTO DetalleFactura (FacturaID, Descripcion, Cantidad, PrecioUnitario, Subtotal) " +
                "VALUES (@facId, 'Consulta médica especializada', 1, @monto, @monto)", conn, tx);
            cmd.Parameters.AddWithValue("@facId", facturaId);
            cmd.Parameters.AddWithValue("@monto", monto);
            cmd.ExecuteNonQuery();
        }

        private void InsertarDetalleFacturaInsumos(SqlConnection conn, SqlTransaction tx, int facturaId, decimal montoInsumos)
        {
            using var cmd = new SqlCommand(
                "INSERT INTO DetalleFactura (FacturaID, Descripcion, Cantidad, PrecioUnitario, Subtotal) " +
                "VALUES (@facId, 'Insumos y medicamentos recetados', 1, @monto, @monto)", conn, tx);
            cmd.Parameters.AddWithValue("@facId", facturaId);
            cmd.Parameters.AddWithValue("@monto", montoInsumos);
            cmd.ExecuteNonQuery();
        }

        private void ActualizarEstadoCita(SqlConnection conn, SqlTransaction tx, int citaId)
        {
            using var cmd = new SqlCommand(
                "UPDATE Citas SET Estado = 'Atendida' WHERE CitaID = @id", conn, tx);
            cmd.Parameters.AddWithValue("@id", citaId);
            cmd.ExecuteNonQuery();
        }
    }
}