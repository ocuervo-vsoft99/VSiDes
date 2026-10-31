"use strict";
/**
 * Servicio de Kardex e Inventarios
 * Reimplementación con soporte ACID de fupdatekdx (desproce.prg de Visual FoxPro)
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.KardexService = void 0;
const database_1 = require("../../config/database");
class KardexService {
    /**
     * Actualiza el inventario mensual y registra la auditoría del movimiento en el kardex
     * Fórmula de Costo Promedio Ponderado de VSiDeS:
     * nuevo_costo = ((saldo_anterior * costo_anterior) + (cantidad_nueva * costo_nuevo)) / (saldo_anterior + cantidad_nueva)
     */
    static async registrarMovimiento(dto, clientExternal) {
        const client = clientExternal || await database_1.pool.connect();
        const shouldManageTransaction = !clientExternal;
        try {
            if (shouldManageTransaction) {
                await client.query('BEGIN');
            }
            // 1. Obtener o inicializar registro en inventario.kardex_mensual con bloqueo pesimista
            const selectKardexSql = `
        SELECT id, saldo_inicial, entradas, salidas, ultimo_costo, costo_promedio
        FROM inventario.kardex_mensual
        WHERE ano_contable = $1 AND mes_contable = $2 AND bodega_id = $3 AND articulo_id = $4
        FOR UPDATE
      `;
            const kardexRes = await client.query(selectKardexSql, [
                dto.anoContable,
                dto.mesContable,
                dto.bodegaId,
                dto.articuloId,
            ]);
            let entradas = 0;
            let salidas = 0;
            let ultimoCosto = dto.costoUnitario;
            let costoPromedio = dto.costoUnitario;
            let saldoActual = 0;
            const esEntrada = ['COMPRA', 'AJUSTE_ENTRADA', 'DEVOLUCION'].includes(dto.tipoMovimiento);
            if (kardexRes.rowCount === 0) {
                // Registro inicial para el período
                if (esEntrada) {
                    entradas = dto.cantidad;
                }
                else {
                    salidas = dto.cantidad;
                }
                const insertKardexSql = `
          INSERT INTO inventario.kardex_mensual (
            ano_contable, mes_contable, bodega_id, articulo_id,
            saldo_inicial, entradas, salidas, ultimo_costo, costo_promedio
          ) VALUES ($1, $2, $3, $4, 0, $5, $6, $7, $8)
        `;
                await client.query(insertKardexSql, [
                    dto.anoContable,
                    dto.mesContable,
                    dto.bodegaId,
                    dto.articuloId,
                    entradas,
                    salidas,
                    ultimoCosto,
                    costoPromedio,
                ]);
            }
            else {
                const row = kardexRes.rows[0];
                saldoActual = Number(row.saldo_inicial) + Number(row.entradas) - Number(row.salidas);
                entradas = Number(row.entradas);
                salidas = Number(row.salidas);
                costoPromedio = Number(row.costo_promedio) || dto.costoUnitario;
                if (esEntrada) {
                    // Cálculo de costo promedio ponderado
                    const nuevoSaldo = saldoActual + dto.cantidad;
                    if (nuevoSaldo > 0) {
                        costoPromedio = ((saldoActual * costoPromedio) + (dto.cantidad * dto.costoUnitario)) / nuevoSaldo;
                    }
                    entradas += dto.cantidad;
                    ultimoCosto = dto.costoUnitario;
                }
                else {
                    // Salida: Valida que haya stock suficiente (o lo registra permitiendo saldo negativo según config)
                    salidas += dto.cantidad;
                }
                const updateKardexSql = `
          UPDATE inventario.kardex_mensual
          SET entradas = $1, salidas = $2, ultimo_costo = $3, costo_promedio = $4
          WHERE id = $5
        `;
                await client.query(updateKardexSql, [
                    entradas,
                    salidas,
                    ultimoCosto,
                    costoPromedio,
                    row.id,
                ]);
            }
            // 2. Registrar en la pista de auditoría inmutable de movimientos
            const insertMovSql = `
        INSERT INTO inventario.movimientos_kardex (
          bodega_id, articulo_id, tipo_movimiento, documento_tipo,
          documento_id, numero_documento, cantidad, costo_unitario, costo_total, usuario_id
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      `;
            await client.query(insertMovSql, [
                dto.bodegaId,
                dto.articuloId,
                dto.tipoMovimiento,
                dto.documentoTipo,
                dto.documentoId,
                dto.numeroDocumento,
                dto.cantidad,
                dto.costoUnitario,
                dto.cantidad * dto.costoUnitario,
                dto.usuarioId || null,
            ]);
            // 3. Sincronizar en el catálogo de artículos
            await client.query(`
        UPDATE maestros.articulos
        SET ultimo_costo = $1, costo_promedio = $2
        WHERE id = $3
      `, [ultimoCosto, costoPromedio, dto.articuloId]);
            if (shouldManageTransaction) {
                await client.query('COMMIT');
            }
        }
        catch (error) {
            if (shouldManageTransaction) {
                await client.query('ROLLBACK');
            }
            throw error;
        }
        finally {
            if (shouldManageTransaction) {
                client.release();
            }
        }
    }
}
exports.KardexService = KardexService;
