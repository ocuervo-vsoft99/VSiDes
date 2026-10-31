/**
 * Servicio de Autoventa y Liquidación de Rutas Móviles
 * Reimplementación de AutoVeDi.prg, MaeAutEn, MaeAutDe y deg_saes.prg de Visual FoxPro
 */

import { pool } from '../../config/database';
import { KardexService } from '../inventario/kardex.service';

export interface CargueVehiculoItem {
  articuloId: number;
  cantidadCargada: number;
}

export interface CargueAutoventaDTO {
  conductorId: number;
  bodegaOrigenId: number;   // Bodega Principal
  bodegaVehiculoId: number; // Bodega Móvil del vehículo
  vendedorId: number;
  rutaId: number;
  fecha: string;
  items: CargueVehiculoItem[];
  usuarioId: number;
}

export class AutoventaService {
  /**
   * Registra el cargue inicial de mercancía en el vehículo de autoventa
   * Realiza traslado de inventario: Salida de Bodega Principal -> Entrada a Bodega Móvil
   */
  public static async registrarCargueVehiculo(dto: CargueAutoventaDTO) {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');
      const fecha = new Date(dto.fecha);
      const anoContable = fecha.getFullYear();
      const mesContable = fecha.getMonth() + 1;
      const numeroDocumento = `CRG-${Date.now().toString().slice(-6)}`;

      for (const item of dto.items) {
        // Obtener costo del artículo
        const artRes = await client.query(
          'SELECT costo_promedio FROM maestros.articulos WHERE id = $1',
          [item.articuloId]
        );
        const costoUnitario = Number(artRes.rows[0]?.costo_promedio) || 0;

        // 1. Salida de Bodega Principal
        await KardexService.registrarMovimiento({
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
        await KardexService.registrarMovimiento({
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
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Liquidación de Ruta de Autoventa al cierre de jornada
   * Compara el inventario cargado vs. facturado vs. recaudado
   */
  public static async liquidarJornadaAutoventa(bodegaVehiculoId: number, vendedorId: number, fecha: string) {
    // 1. Stock remanente en el vehículo
    const stockVehiculo = await pool.query(`
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
    const ventasDia = await pool.query(`
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
    const recaudosDia = await pool.query(`
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
