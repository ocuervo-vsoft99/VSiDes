import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { pool } from './config/database';
import { VentasService } from './modules/ventas/ventas.service';
import { CarteraService } from './modules/cartera/cartera.service';
import { DianFeService, FacturaDianDatos } from './modules/integraciones/dian-fe.service';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

// -----------------------------------------------------------------------------
// 1. HEALTH CHECK & STATUS
// -----------------------------------------------------------------------------
app.get('/api/health', async (_req: Request, res: Response) => {
  try {
    const dbRes = await pool.query('SELECT NOW() as now, current_database() as database');
    res.json({
      status: 'UP',
      system: 'VSiDeS Modern API (TypeScript + PostgreSQL)',
      timestamp: dbRes.rows[0].now,
      database: dbRes.rows[0].database,
    });
  } catch (err: any) {
    res.status(500).json({ status: 'DOWN', error: err.message });
  }
});

// -----------------------------------------------------------------------------
// 2. DASHBOARD & KPIs COMERCIALES (Indicadores DEG)
// -----------------------------------------------------------------------------
app.get('/api/dashboard/kpis', async (_req: Request, res: Response) => {
  try {
    const ventasMes = await pool.query(`
      SELECT COALESCE(SUM(total_factura), 0) as total_ventas,
             COUNT(id) as total_facturas
      FROM ventas.facturas
      WHERE estado_factura != 'ANULADA'
        AND date_trunc('month', fecha_emision) = date_trunc('month', CURRENT_DATE)
    `);

    const carteraRes = await pool.query(`
      SELECT 
        COALESCE(SUM(saldo_actual), 0) as total_cartera,
        COALESCE(SUM(CASE WHEN fecha_vencimiento < CURRENT_DATE THEN saldo_actual ELSE 0 END), 0) as cartera_vencida
      FROM cartera.cuentas_cobrar
      WHERE estado = 'PENDIENTE' AND saldo_actual > 0
    `);

    const pedidosRes = await pool.query(`
      SELECT COUNT(id) as pedidos_hoy, COALESCE(SUM(total_pedido), 0) as valor_pedidos
      FROM ventas.pedidos
      WHERE date_trunc('day', fecha_pedido) = date_trunc('day', CURRENT_DATE)
    `);

    const topArticulos = await pool.query(`
      SELECT a.codigo_articulo, a.nombre_articulo, SUM(fd.cantidad) as total_unidades, SUM(fd.total_linea) as total_pesos
      FROM ventas.factura_detalles fd
      JOIN maestros.articulos a ON fd.articulo_id = a.id
      GROUP BY a.codigo_articulo, a.nombre_articulo
      ORDER BY total_pesos DESC
      LIMIT 5
    `);

    res.json({
      ventas: ventasMes.rows[0],
      cartera: carteraRes.rows[0],
      pedidos: pedidosRes.rows[0],
      topArticulos: topArticulos.rows,
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// -----------------------------------------------------------------------------
// 3. MAESTROS: CLIENTES Y NEGOCIOS
// -----------------------------------------------------------------------------
app.get('/api/clientes', async (req: Request, res: Response) => {
  try {
    const q = req.query.search ? `%${req.query.search}%` : '%';
    const result = await pool.query(`
      SELECT c.id, c.identificacion, c.digito_verificacion, c.razon_social, c.telefono, c.email_facturacion,
             COUNT(pv.id) as total_negocios
      FROM maestros.clientes c
      LEFT JOIN maestros.puntos_venta pv ON pv.cliente_id = c.id
      WHERE c.identificacion ILIKE $1 OR c.razon_social ILIKE $1
      GROUP BY c.id
      ORDER BY c.razon_social ASC
      LIMIT 50
    `, [q]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// -----------------------------------------------------------------------------
// 4. MAESTROS: ARTÍCULOS Y STOCK EN BODEGA
// -----------------------------------------------------------------------------
app.get('/api/articulos', async (req: Request, res: Response) => {
  try {
    const q = req.query.search ? `%${req.query.search}%` : '%';
    const result = await pool.query(`
      SELECT a.id, a.codigo_articulo, a.nombre_articulo, a.codigo_barras, a.unidad_medida,
             a.precio_base, a.costo_promedio, a.iva_porcentaje,
             l.nombre_linea, p.razon_social as proveedor
      FROM maestros.articulos a
      LEFT JOIN maestros.lineas l ON a.linea_id = l.id
      LEFT JOIN maestros.proveedores p ON l.proveedor_id = p.id
      WHERE a.codigo_articulo ILIKE $1 OR a.nombre_articulo ILIKE $1 OR a.codigo_barras ILIKE $1
      ORDER BY a.nombre_articulo ASC
      LIMIT 100
    `, [q]);
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// -----------------------------------------------------------------------------
// 5. VENTAS: FACTURACIÓN
// -----------------------------------------------------------------------------
app.post('/api/facturas', async (req: Request, res: Response) => {
  try {
    const resultado = await VentasService.emitirFactura(req.body);
    res.status(201).json(resultado);
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

// -----------------------------------------------------------------------------
// 6. FACTURACIÓN ELECTRÓNICA DIAN (UBL 2.1 XML / CUFE)
// -----------------------------------------------------------------------------
app.post('/api/dian/generar-cufe', (req: Request, res: Response) => {
  try {
    const datos: FacturaDianDatos = req.body;
    const cufe = DianFeService.calcularCUFE(datos);
    const qrData = DianFeService.generarCadenaQR(datos, cufe);
    const xmlUBL21 = DianFeService.generarXmlUBL21(datos, cufe);

    res.json({
      cufe,
      qrData,
      xml: xmlUBL21,
    });
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

// -----------------------------------------------------------------------------
// 7. CARTERA Y RECAUDOS
// -----------------------------------------------------------------------------
app.get('/api/cartera/edades', async (_req: Request, res: Response) => {
  try {
    const edades = await CarteraService.consultarEdadesCartera();
    res.json(edades);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/cartera/recibos', async (req: Request, res: Response) => {
  try {
    const resultado = await CarteraService.registrarReciboCaja(req.body);
    res.status(201).json(resultado);
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

// -----------------------------------------------------------------------------
// 8. REPORTES ANALÍTICOS (Business Intelligence DEG)
// -----------------------------------------------------------------------------
app.get('/api/reportes/ventas-por-linea', async (_req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT * FROM ventas.vw_ventas_por_linea LIMIT 50');
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/reportes/ventas-por-vendedor', async (_req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT * FROM ventas.vw_ventas_por_vendedor_zona LIMIT 50');
    res.json(result.rows);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(` Servidor VSiDeS Backend ejecutándose en http://localhost:${PORT}`);
});
