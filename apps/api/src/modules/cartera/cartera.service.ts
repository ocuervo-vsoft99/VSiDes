/**
 * Servicio de Cartera y Recaudos
 * Reimplementación de deg_cmvto.scx, deg_pago.prg y cálculo de edades de cartera de VSiDeS
 */

import { pool } from '../../config/database';

export interface ImputacionPagoDTO {
  cuentaCobrarId: number;
  valorAplicado: number;
  descuentoProntoPago?: number;
  retencionFuente?: number;
  retencionIva?: number;
  retencionIca?: number;
}

export interface ReciboCajaCreacionDTO {
  consecutivo: string;
  puntoVentaId: number;
  vendedorId?: number;
  formaPago: 'EFECTIVO' | 'CHEQUE' | 'TRANSFERENCIA';
  totalRecaudo: number;
  observaciones?: string;
  usuarioId: number;
  imputaciones: ImputacionPagoDTO[];
}

export class CarteraService {
  /**
   * Registro atómico de Recibo de Caja con amortización de saldos en facturas
   */
  public static async registrarReciboCaja(dto: ReciboCajaCreacionDTO) {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      // 1. Insertar encabezado del recibo de caja
      const insertReciboSql = `
        INSERT INTO cartera.recibos_caja (
          consecutivo, punto_venta_id, vendedor_id, forma_pago,
          total_recaudo, observaciones, usuario_id
        ) VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id
      `;

      const reciboRes = await client.query(insertReciboSql, [
        dto.consecutivo,
        dto.puntoVentaId,
        dto.vendedorId || null,
        dto.formaPago,
        dto.totalRecaudo,
        dto.observaciones || null,
        dto.usuarioId,
      ]);

      const reciboId = reciboRes.rows[0].id;

      // 2. Procesar cada imputación a las cuentas por cobrar pendientes
      for (const imp of dto.imputaciones) {
        // Bloqueo pesimista de la cuenta por cobrar
        const cxcRes = await client.query(
          'SELECT id, saldo_actual, valor_total FROM cartera.cuentas_cobrar WHERE id = $1 FOR UPDATE',
          [imp.cuentaCobrarId]
        );

        if (cxcRes.rowCount === 0) {
          throw new Error(`Cuenta por cobrar con ID ${imp.cuentaCobrarId} no encontrada.`);
        }

        const cxc = cxcRes.rows[0];
        const saldoActual = Number(cxc.saldo_actual);
        const valorTotalDeducir = imp.valorAplicado + (imp.descuentoProntoPago || 0) + (imp.retencionFuente || 0) + (imp.retencionIva || 0) + (imp.retencionIca || 0);

        if (valorTotalDeducir > saldoActual + 0.01) {
          throw new Error(`El valor a imputar ($${valorTotalDeducir}) excede el saldo pendiente ($${saldoActual}).`);
        }

        const nuevoSaldo = Math.max(0, saldoActual - valorTotalDeducir);
        const nuevoEstado = nuevoSaldo === 0 ? 'PAGADA' : 'PENDIENTE';

        // Actualizar saldo de la factura en cartera
        await client.query(`
          UPDATE cartera.cuentas_cobrar
          SET saldo_actual = $1, estado = $2
          WHERE id = $3
        `, [nuevoSaldo, nuevoEstado, imp.cuentaCobrarId]);

        // Registrar detalle del recibo
        await client.query(`
          INSERT INTO cartera.recibo_detalles (
            recibo_id, cuenta_cobrar_id, valor_aplicado, descuento_aplicado,
            retencion_fuente, retencion_iva, retencion_ica
          ) VALUES ($1, $2, $3, $4, $5, $6, $7)
        `, [
          reciboId,
          imp.cuentaCobrarId,
          imp.valorAplicado,
          imp.descuentoProntoPago || 0,
          imp.retencionFuente || 0,
          imp.retencionIva || 0,
          imp.retencionIca || 0,
        ]);
      }

      await client.query('COMMIT');
      return { success: true, reciboId, consecutivo: dto.consecutivo };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Consulta del informe de Edades de Cartera agrupado por cliente y vencimiento
   */
  public static async consultarEdadesCartera() {
    const sql = `
      SELECT 
        c.identificacion,
        c.razon_social,
        pv.nombre_negocio,
        COUNT(cxc.id) as total_facturas,
        SUM(cxc.saldo_actual) as saldo_total,
        SUM(CASE WHEN cxc.fecha_vencimiento >= CURRENT_DATE THEN cxc.saldo_actual ELSE 0 END) as corriente,
        SUM(CASE WHEN CURRENT_DATE - cxc.fecha_vencimiento BETWEEN 1 AND 30 THEN cxc.saldo_actual ELSE 0 END) as dias_1_30,
        SUM(CASE WHEN CURRENT_DATE - cxc.fecha_vencimiento BETWEEN 31 AND 60 THEN cxc.saldo_actual ELSE 0 END) as dias_31_60,
        SUM(CASE WHEN CURRENT_DATE - cxc.fecha_vencimiento BETWEEN 61 AND 90 THEN cxc.saldo_actual ELSE 0 END) as dias_61_90,
        SUM(CASE WHEN CURRENT_DATE - cxc.fecha_vencimiento > 90 THEN cxc.saldo_actual ELSE 0 END) as mas_90_dias
      FROM cartera.cuentas_cobrar cxc
      JOIN maestros.puntos_venta pv ON cxc.punto_venta_id = pv.id
      JOIN maestros.clientes c ON pv.cliente_id = c.id
      WHERE cxc.estado = 'PENDIENTE' AND cxc.saldo_actual > 0
      GROUP BY c.identificacion, c.razon_social, pv.nombre_negocio
      ORDER BY saldo_total DESC;
    `;

    const res = await pool.query(sql);
    return res.rows;
  }
}
