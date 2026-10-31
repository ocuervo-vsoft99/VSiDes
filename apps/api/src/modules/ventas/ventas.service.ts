/**
 * Servicio de Ventas y Facturación
 * Manejo de pedidos, facturas de venta, deducción de inventario y cuentas por cobrar
 */

import { pool } from '../../config/database';
import { KardexService } from '../inventario/kardex.service';

export interface DetalleVentaInput {
  articuloId: number;
  cantidad: number;
  precioUnitario: number;
  porcentajeDescuento?: number;
  porcentajeIva?: number;
}

export interface FacturaCreacionDTO {
  prefijo: string;
  consecutivo: number;
  pedidoId?: number;
  puntoVentaId: number;
  vendedorId: number;
  bodegaId: number;
  plazoDias: number;
  formaPago: 'CONTADO' | 'CREDITO';
  detalles: DetalleVentaInput[];
  usuarioId: number;
}

export class VentasService {
  public static async emitirFactura(dto: FacturaCreacionDTO) {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      // 1. Calcular totales de la factura
      let subtotalTotal = 0;
      let descuentoTotal = 0;
      let ivaTotal = 0;

      const lineasCalculadas = dto.detalles.map((d) => {
        const subtotal = d.cantidad * d.precioUnitario;
        const descuento = subtotal * ((d.porcentajeDescuento || 0) / 100);
        const base = subtotal - descuento;
        const iva = base * ((d.porcentajeIva || 19) / 100);
        const total = base + iva;

        subtotalTotal += base;
        descuentoTotal += descuento;
        ivaTotal += iva;

        return {
          ...d,
          descuentoValor: descuento,
          ivaValor: iva,
          subtotalLinea: subtotal,
          totalLinea: total,
        };
      });

      const totalFactura = subtotalTotal + ivaTotal;
      const fechaEmision = new Date();
      const fechaVencimiento = new Date();
      fechaVencimiento.setDate(fechaVencimiento.getDate() + (dto.plazoDias || 0));

      // 2. Insertar encabezado de factura
      const insertFacSql = `
        INSERT INTO ventas.facturas (
          prefijo, consecutivo, pedido_id, punto_venta_id, vendedor_id,
          fecha_emision, fecha_vencimiento, plazo_dias, forma_pago,
          subtotal, total_descuento, total_iva, total_factura,
          estado_factura, estado_dian
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'EMITIDA', 'PENDIENTE')
        RETURNING id
      `;

      const facRes = await client.query(insertFacSql, [
        dto.prefijo,
        dto.consecutivo,
        dto.pedidoId || null,
        dto.puntoVentaId,
        dto.vendedorId,
        fechaEmision,
        fechaVencimiento,
        dto.plazoDias,
        dto.formaPago,
        subtotalTotal,
        descuentoTotal,
        ivaTotal,
        totalFactura,
      ]);

      const facturaId = facRes.rows[0].id;
      const anoContable = fechaEmision.getFullYear();
      const mesContable = fechaEmision.getMonth() + 1;

      // 3. Insertar detalles y actualizar inventario en Kardex
      for (const linea of lineasCalculadas) {
        // Obtener costo actual del artículo
        const artRes = await client.query(
          'SELECT costo_promedio FROM maestros.articulos WHERE id = $1',
          [linea.articuloId]
        );
        const costoUnitario = Number(artRes.rows[0]?.costo_promedio) || 0;

        await client.query(`
          INSERT INTO ventas.factura_detalles (
            factura_id, articulo_id, cantidad, precio_unitario, costo_unitario,
            porcentaje_descuento, porcentaje_iva, valor_iva, total_linea
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        `, [
          facturaId,
          linea.articuloId,
          linea.cantidad,
          linea.precioUnitario,
          costoUnitario,
          linea.porcentajeDescuento || 0,
          linea.porcentajeIva || 19,
          linea.ivaValor,
          linea.totalLinea,
        ]);

        // Reducción de inventario en Kardex (RESTA)
        await KardexService.registrarMovimiento({
          anoContable,
          mesContable,
          bodegaId: dto.bodegaId,
          articuloId: linea.articuloId,
          tipoMovimiento: 'VENTA',
          documentoTipo: 'FAC',
          documentoId: facturaId,
          numeroDocumento: `${dto.prefijo}-${dto.consecutivo}`,
          cantidad: linea.cantidad,
          costoUnitario,
          usuarioId: dto.usuarioId,
        }, client);
      }

      // 4. Si la venta es a crédito, generar cuenta por cobrar en cartera
      if (dto.formaPago === 'CREDITO') {
        await client.query(`
          INSERT INTO cartera.cuentas_cobrar (
            factura_id, punto_venta_id, fecha_emision, fecha_vencimiento,
            valor_total, saldo_actual, estado
          ) VALUES ($1, $2, $3, $4, $5, $6, 'PENDIENTE')
        `, [
          facturaId,
          dto.puntoVentaId,
          fechaEmision,
          fechaVencimiento,
          totalFactura,
          totalFactura,
        ]);
      }

      await client.query('COMMIT');
      return {
        success: true,
        facturaId,
        numeroCompleto: `${dto.prefijo}-${dto.consecutivo}`,
        totalFactura,
      };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}
