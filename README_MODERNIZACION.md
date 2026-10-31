# VSiDeS Modern - Sistema de Distribución y Mayoristas

Modernización integral del ERP comercial **VSiDeS / Visual SiDeg** de **Visual FoxPro** a **React**, **TypeScript** y **PostgreSQL**.

---

## 📁 Estructura del Proyecto

```
VSiDeg.FE/
├── apps/
│   ├── api/                       # Backend Node.js + TypeScript
│   │   ├── src/
│   │   │   ├── config/database.ts # Conexión a PostgreSQL (Pool TCP)
│   │   │   ├── modules/
│   │   │   │   ├── inventario/    # Kardex y costo promedio (fupdatekdx)
│   │   │   │   ├── ventas/        # Facturación, autoventa y liquidación
│   │   │   │   ├── cartera/       # Cuentas por cobrar y recibos de caja
│   │   │   │   └── integraciones/ # DIAN FE (CUFE/QR), Mondelēz, Colombina, SIIGO
│   │   │   └── index.ts           # Servidor REST API
│   │   ├── test/                  # Suite de pruebas unitarias de negocio
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── web/                       # Frontend React 19 + TypeScript + Vite
│       ├── src/
│       │   ├── types/             # Interfaces de Clientes, Artículos, Facturas
│       │   ├── App.tsx            # Terminal de ventas con atajos F-keys, Kardex y Dashboard
│       │   ├── main.tsx
│       │   └── index.css          # Estilos Tailwind y atajos de teclado
│       ├── index.html
│       ├── vite.config.ts
│       └── package.json
│
├── database/
│   ├── schema.sql                 # Esquema relacional DDL PostgreSQL (8 esquemas)
│   └── seed.sql                   # Datos maestros reales (DANE, proveedores, clientes, kardex)
│
├── scripts/
│   └── migrate_dbf_to_postgres.ts # Script ETL para migrar datos de tablas DBF
│
└── [Archivos Legacy FoxPro]       # PRGs, SCXs, DBFs originales conservados intactos
```

---

## 🚀 Puesta en Marcha

### 1. Base de Datos (PostgreSQL)
1. Instalar y arrancar el servicio de PostgreSQL 16+.
2. Crear la base de datos:
   ```sql
   CREATE DATABASE vsideg_modern;
   ```
3. Ejecutar el esquema y los datos iniciales:
   ```bash
   psql -U postgres -d vsideg_modern -f database/schema.sql
   psql -U postgres -d vsideg_modern -f database/seed.sql
   ```

### 2. Backend API (Node.js + TypeScript)
```bash
cd apps/api
npm install
npm run dev
```
La API estará disponible en `http://localhost:4000/api/health`.

### 3. Frontend Web (React + Vite)
```bash
cd apps/web
npm install
npm run dev
```
La aplicación web se abrirá en `http://localhost:3000`.

### 4. Pruebas Unitarias de Reglas de Negocio
Para verificar que el cálculo de CUFE SHA-384, la fórmula de Costo Promedio de Kardex y los descuentos con IVA operan correctamente:
```bash
cd apps/api
npx tsx test/business-logic.test.ts
```

---

## ⌨️ Atajos de Teclado (Compatibilidad con Visual FoxPro)
El frontend incluye detección nativa de teclas de función para digitación ultrarrápida sin necesidad de ratón:
- **`F1`**: Menú de ayuda del sistema.
- **`F2`**: Terminal de Facturación y Venta Directa.
- **`F3`**: Maestro de Clientes y Puntos de Venta.
- **`F4`**: Consulta de Kardex y Existencias.
- **`F5`**: Módulo de Cartera y Recaudos.
- **`F9`**: Emisión y timbrado de Factura Electrónica.
