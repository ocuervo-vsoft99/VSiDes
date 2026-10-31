/**
 * Servicio de Interfaces y Enlaces EDI con Fabricantes y Software Contable
 * Reimplementación de colombinafacturas.prg, Mondolez_VSiDeg.prg, SysCafeVentas2020.prg y SIIGO2_Ventas.prg
 */

import { pool } from '../../config/database';

export class FabricantesService {
  /**
   * Generación de archivo plano de ventas e inventario para Mondelēz / Colombina TrackSales
   * Formato delimitado por tuberías (|) o posiciones fijas estándar de la industria
   */
  public static async exportarTrackSalesFabricante(proveedorId: number, fechaInicio: string, fechaFin: string): Promise<string> {
    const sql = `
      SELECT 
        f.prefijo || '-' || f.consecutivo as numero_factura,
        TO_CHAR(f.fecha_emision, 'YYYYMMDD') as fecha_factura,
        c.identificacion as nit_cliente,
        c.razon_social as nombre_cliente,
        pv.codigo_establecimiento,
        pv.direccion as direccion_entrega,
        a.codigo_articulo,
        a.codigo_barras,
        a.nombre_articulo,
        fd.cantidad,
        fd.precio_unitario,
        fd.porcentaje_descuento,
        fd.total_linea,
        v.codigo_vendedor,
        v.primer_nombre || ' ' || v.primer_apellido as nombre_vendedor,
        r.codigo_ruta
      FROM ventas.factura_detalles fd
      JOIN ventas.facturas f ON fd.factura_id = f.id
      JOIN maestros.articulos a ON fd.articulo_id = a.id
      JOIN maestros.lineas l ON a.linea_id = l.id
      JOIN maestros.puntos_venta pv ON f.punto_venta_id = pv.id
      JOIN maestros.clientes c ON pv.cliente_id = c.id
      JOIN maestros.vendedores v ON f.vendedor_id = v.id
      LEFT JOIN geografia.rutas r ON pv.ruta_id = r.id
      WHERE l.proveedor_id = $1
        AND f.fecha_emision::date BETWEEN $2::date AND $3::date
        AND f.estado_factura != 'ANULADA'
      ORDER BY f.fecha_emision ASC, f.consecutivo ASC;
    `;

    const res = await pool.query(sql, [proveedorId, fechaInicio, fechaFin]);
    
    // Encabezado estándar EDI TrackSales
    const header = [
      'NUM_FAC', 'FECHA', 'NIT_CLIENTE', 'RAZON_SOCIAL', 'COD_SUCURSAL', 
      'DIRECCION', 'COD_SKU', 'EAN13', 'DESCRIPCION', 'CANTIDAD', 
      'PRECIO_UNI', 'DSCTO_PCT', 'TOTAL_NETO', 'COD_VENDEDOR', 'VENDEDOR', 'COD_RUTA'
    ].join('|');

    const lines = res.rows.map(r => [
      r.numero_factura,
      r.fecha_factura,
      r.nit_cliente,
      `"${r.nombre_cliente.replace(/"/g, '""')}"`,
      r.codigo_establecimiento,
      `"${r.direccion_entrega.replace(/"/g, '""')}"`,
      r.codigo_articulo,
      r.codigo_barras || '',
      `"${r.nombre_articulo.replace(/"/g, '""')}"`,
      Number(r.cantidad).toFixed(2),
      Number(r.precio_unitario).toFixed(2),
      Number(r.porcentaje_descuento).toFixed(2),
      Number(r.total_linea).toFixed(2),
      r.codigo_vendedor,
      `"${r.nombre_vendedor.replace(/"/g, '""')}"`,
      r.codigo_ruta || ''
    ].join('|'));

    return [header, ...lines].join('\r\n');
  }

  /**
   * Generación de Comprobante Contable para SIIGO y SysCafé
   * Crea el archivo plano con Débitos y Créditos (Cuentas 4135 Comercio, 2408 IVA, 1305 Clientes, 1105 Caja)
   */
  public static async generarComprobanteContable(fechaInicio: string, fechaFin: string): Promise<string> {
    const sql = `
      SELECT 
        f.prefijo || '-' || f.consecutivo as documento,
        TO_CHAR(f.fecha_emision, 'DD/MM/YYYY') as fecha,
        c.identificacion as nit_tercero,
        f.subtotal,
        f.total_iva,
        f.total_factura,
        f.forma_pago
      FROM ventas.facturas f
      JOIN maestros.puntos_venta pv ON f.punto_venta_id = pv.id
      JOIN maestros.clientes c ON pv.cliente_id = c.id
      WHERE f.fecha_emision::date BETWEEN $1::date AND $2::date
        AND f.estado_factura != 'ANULADA';
    `;

    const res = await pool.query(sql, [fechaInicio, fechaFin]);
    const comprobanteLineas: string[] = [];

    res.rows.forEach(r => {
      const doc = r.documento;
      const fec = r.fecha;
      const nit = r.nit_tercero;
      const subtotal = Number(r.subtotal).toFixed(2);
      const iva = Number(r.total_iva).toFixed(2);
      const total = Number(r.total_factura).toFixed(2);

      // Línea 1: Cuenta por cobrar o Caja (Débito)
      const cuentaCobro = r.forma_pago === 'CREDITO' ? '13050501' : '11050501';
      comprobanteLineas.push(`FV|${doc}|${fec}|${nit}|${cuentaCobro}|${total}|0.00|Venta Factura ${doc}`);

      // Línea 2: Ingreso por ventas (Crédito)
      comprobanteLineas.push(`FV|${doc}|${fec}|${nit}|41352401|0.00|${subtotal}|Ingreso Venta ${doc}`);

      // Línea 3: IVA por pagar si aplica (Crédito)
      if (Number(r.total_iva) > 0) {
        comprobanteLineas.push(`FV|${doc}|${fec}|${nit}|24080101|0.00|${iva}|IVA Generado 19% ${doc}`);
      }
    });

    return comprobanteLineas.join('\r\n');
  }
}
