"use strict";
/**
 * Servicio de Autoventa y Liquidación de Rutas Móviles
 * Reimplementación de AutoVeDi.prg, MaeAutEn, MaeAutDe y deg_saes.prg de Visual FoxPro
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.AutoventaService = void 0;
const database_1 = require("../../config/database");
const kardex_service_1 = require("../inventario/kardex.service");
class AutoventaService {
    /**
     * Registra el cargue inicial de mercancía en el vehículo de autoventa
     * Realiza traslado de inventario: Salida de Bodega Principal -> Entrada a Bodega Móvil
     */
    static async registrarCargueVehiculo(dto) {
        const client = await database_1.pool.connect();
        try {
            await client.query('BEGIN');
            const fecha = new Date(dto.fecha);
            const anoContable = fecha.getFullYear();
            const mesContable = fecha.getMonth() + 1;
            const numeroDocumento = `CRG-${Date.now().toString().slice(-6)}`;
            for (const item of dto.items) {
                // Obtener costo del artículo
                const artRes = await client.query('SELECT costo_promedio FROM maestros.articulos WHERE id = $1', [item.articuloId]);
                const costoUnitario = Number(artRes.rows[0]?.costo_promedio) || 0;
                // 1. Salida de Bodega Principal
                await kardex_service_1.KardexService.registrarMovimiento({
                    anoContable,
                    mesContable,
                    bodegaId: dto.bodegaOrigenId,
                    articuloId: item.articuloId,
                    tipoMovimiento: 'AJUSTE_SALIDA',
                    documentoTipo: 'REM',
                    documentoId: 1,
                    numeroDocumento,
                    cantidad: item.cantidadCargada,
                    costoUnitario,
                    usuarioId: dto.usuarioId,
                }, client);
                // 2. Entrada a Bodega Móvil (Vehículo)
                await kardex_service_1.KardexService.registrarMovimiento({
                    anoContable,
                    mesContable,
                    bodegaId: dto.bodegaVehiculoId,
                    articuloId: item.articuloId,
                    tipoMovimiento: 'AJUSTE_ENTRADA',
                    documentoTipo: 'REM',
                    documentoId: 1,
                    numeroDocumento,
                    cantidad: item.cantidadCargada,
                    costoUnitario,
                    usuarioId: dto.usuarioId,
                }, client);
            }
            await client.query('COMMIT');
            return { success: true, numeroDocumento };
        }
        catch (error) {
            await client.query('ROLLBACK');
            throw error;
        }
        finally {
            client.release();
        }
    }
    /**
     * Liquidación de Ruta de Autoventa al cierre de jornada
     * Compara el inventario cargado vs. facturado vs. recaudado
     */
    static async liquidarJornadaAutoventa(bodegaVehiculoId, vendedorId, fecha) {
        // 1. Stock remanente en el vehículo
        const stockVehiculo = await database_1.pool.query(`
      SELECT 
        a.codigo_articulo,
        a.nombre_articulo,
        km.saldo_final as stock_actual,
        a.precio_base
      FROM inventario.kardex_mensual km
      JOIN maestros.articulos a ON km.articulo_id = a.id
      WHERE km.bodega_id = $1 AND km.saldo_final > 0
    `, [bodegaVehiculoId]);
        // 2. Total de ventas facturadas por el vendedor en la jornada
        const ventasDia = await database_1.pool.query(`
      SELECT 
        COUNT(id) as total_facturas,
        COALESCE(SUM(subtotal), 0) as subtotal_ventas,
        COALESCE(SUM(total_iva), 0) as iva_ventas,
        COALESCE(SUM(total_factura), 0) as total_ventas,
        COALESCE(SUM(CASE WHEN forma_pago = 'CONTADO' THEN total_factura ELSE 0 END), 0) as ventas_contado,
        COALESCE(SUM(CASE WHEN forma_pago = 'CREDITO' THEN total_factura ELSE 0 END), 0) as ventas_credito
      FROM ventas.facturas
      WHERE vendedor_id = $1
        AND fecha_emision::date = $2::date
        AND estado_factura != 'ANULADA'
    `, [vendedorId, fecha]);
        // 3. Total de recaudos en efectivo / cheques
        const recaudosDia = await database_1.pool.query(`
      SELECT 
        COALESCE(SUM(CASE WHEN forma_pago = 'EFECTIVO' THEN total_recaudo ELSE 0 END), 0) as efectivo_recaudado,
        COALESCE(SUM(CASE WHEN forma_pago = 'CHEQUE' THEN total_recaudo ELSE 0 END), 0) as cheques_recaudados,
        COALESCE(SUM(total_recaudo), 0) as total_recaudo
      FROM cartera.recibos_caja
      WHERE vendedor_id = $1
        AND fecha_recaudo::date = $2::date
    `, [vendedorId, fecha]);
        const resumenVentas = ventasDia.rows[0];
        const resumenRecaudos = recaudosDia.rows[0];
        const dineroEsperadoEnCaja = Number(resumenVentas.ventas_contado) + Number(resumenRecaudos.total_recaudo);
        return {
            fecha,
            vendedorId,
            bodegaVehiculoId,
            resumenVentas,
            resumenRecaudos,
            dineroEsperadoEnCaja,
            inventarioRemanenteEnVehiculo: stockVehiculo.rows,
        };
    }
}
exports.AutoventaService = AutoventaService;
