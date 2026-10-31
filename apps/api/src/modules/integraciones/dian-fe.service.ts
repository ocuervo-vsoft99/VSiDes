/**
 * Servicio de Facturación Electrónica DIAN Colombia (UBL 2.1)
 * Reimplementación moderna de factelecxml.prg y FillDetailXML.prg de Visual FoxPro
 */

import crypto from 'crypto';

export interface FacturaDianDatos {
  numeroFactura: string;         // Ej: SETT-990000001
  prefijo: string;
  consecutivo: number;
  fechaEmision: string;          // YYYY-MM-DD
  horaEmision: string;           // HH:mm:ss-05:00
  nitEmisor: string;
  dvEmisor: string;
  nitAdquirente: string;
  dvAdquirente: string;
  tipoPersonaAdquirente: '1' | '2'; // 1: Jurídica, 2: Natural
  razonSocialAdquirente: string;
  direccionAdquirente: string;
  ciudadDaneAdquirente: string;
  emailAdquirente: string;
  telefonoAdquirente: string;
  valorBruto: number;
  valorBaseIva: number;
  valorIva: number;
  valorTotal: number;
  claveTecnicaDian: string;      // Clave técnica provista por la DIAN
  tipoAmbiente: '1' | '2';       // 1: Producción, 2: Pruebas
  lineas: Array<{
    consecutivo: number;
    codigoArticulo: string;
    nombreArticulo: string;
    cantidad: number;
    unidadMedida: string;
    precioUnitario: number;
    valorIva: number;
    porcentajeIva: number;
    totalLinea: number;
  }>;
}

export class DianFeService {
  /**
   * Cálculo del CUFE (Código Único de Facturación Electrónica) según Anexo Técnico DIAN UBL 2.1
   * Algoritmo: SHA-384
   * Cadena: NumFac + FecFac + HorFac + ValFac + CodImp1 + ValImp1 + CodImp2 + ValImp2 + CodImp3 + ValImp3 + ValTot + NitOFE + NumAdq + ClaveTecnica + TipoAmb
   */
  public static calcularCUFE(datos: FacturaDianDatos): string {
    const valFacStr = datos.valorBruto.toFixed(2);
    const codImp1 = '01'; // IVA
    const valImp1Str = datos.valorIva.toFixed(2);
    const codImp2 = '04'; // Impuesto al consumo (si aplica)
    const valImp2Str = '0.00';
    const codImp3 = '03'; // ICA
    const valImp3Str = '0.00';
    const valTotStr = datos.valorTotal.toFixed(2);

    const cadenaCUFE = 
      datos.numeroFactura +
      datos.fechaEmision +
      datos.horaEmision +
      valFacStr +
      codImp1 +
      valImp1Str +
      codImp2 +
      valImp2Str +
      codImp3 +
      valImp3Str +
      valTotStr +
      datos.nitEmisor +
      datos.nitAdquirente +
      datos.claveTecnicaDian +
      datos.tipoAmbiente;

    return crypto.createHash('sha384').update(cadenaCUFE).digest('hex');
  }

  /**
   * Generación de contenido del Código QR para la representación gráfica PDF
   */
  public static generarCadenaQR(datos: FacturaDianDatos, cufe: string): string {
    return [
      `NumFac=${datos.numeroFactura}`,
      `FecFac=${datos.fechaEmision}`,
      `HorFac=${datos.horaEmision}`,
      `NitFac=${datos.nitEmisor}`,
      `DocAdq=${datos.nitAdquirente}`,
      `ValFac=${datos.valorBruto.toFixed(2)}`,
      `ValIva=${datos.valorIva.toFixed(2)}`,
      `ValOtro=0.00`,
      `ValTotal=${datos.valorTotal.toFixed(2)}`,
      `CUFE=${cufe}`,
      `QRCode=https://catalogo-vpfe.dian.gov.co/document/searchqr?documentkey=${cufe}`
    ].join('\n');
  }

  /**
   * Generación del XML estándar UBL 2.1 Invoice
   */
  public static generarXmlUBL21(datos: FacturaDianDatos, cufe: string): string {
    const xmlLineas = datos.lineas.map(l => `
    <cac:InvoiceLine>
        <cbc:ID>${l.consecutivo}</cbc:ID>
        <cbc:InvoicedQuantity unitCode="${l.unidadMedida}">${l.cantidad.toFixed(2)}</cbc:InvoicedQuantity>
        <cbc:LineExtensionAmount currencyID="COP">${(l.cantidad * l.precioUnitario).toFixed(2)}</cbc:LineExtensionAmount>
        <cac:TaxTotal>
            <cbc:TaxAmount currencyID="COP">${l.valorIva.toFixed(2)}</cbc:TaxAmount>
            <cac:TaxSubtotal>
                <cbc:TaxableAmount currencyID="COP">${(l.cantidad * l.precioUnitario).toFixed(2)}</cbc:TaxableAmount>
                <cbc:TaxAmount currencyID="COP">${l.valorIva.toFixed(2)}</cbc:TaxAmount>
                <cac:TaxCategory>
                    <cbc:Percent>${l.porcentajeIva.toFixed(2)}</cbc:Percent>
                    <cac:TaxScheme>
                        <cbc:ID>01</cbc:ID>
                        <cbc:Name>IVA</cbc:Name>
                    </cac:TaxScheme>
                </cac:TaxCategory>
            </cac:TaxSubtotal>
        </cac:TaxTotal>
        <cac:Item>
            <cbc:Description><![CDATA[${l.nombreArticulo}]]></cbc:Description>
            <cac:SellersItemIdentification>
                <cbc:ID>${l.codigoArticulo}</cbc:ID>
            </cac:SellersItemIdentification>
        </cac:Item>
        <cac:Price>
            <cbc:PriceAmount currencyID="COP">${l.precioUnitario.toFixed(2)}</cbc:PriceAmount>
            <cbc:BaseQuantity unitCode="${l.unidadMedida}">1.00</cbc:BaseQuantity>
        </cac:Price>
    </cac:InvoiceLine>`).join('');

    return `<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
         xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
         xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
         xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
         xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">
    <cbc:UBLVersionID>UBL 2.1</cbc:UBLVersionID>
    <cbc:CustomizationID>10</cbc:CustomizationID>
    <cbc:ProfileID>DIAN 2.1: Factura Electrónica de Venta</cbc:ProfileID>
    <cbc:ProfileExecutionID>${datos.tipoAmbiente}</cbc:ProfileExecutionID>
    <cbc:ID>${datos.numeroFactura}</cbc:ID>
    <cbc:UUID schemeName="CUFE-SHA384">${cufe}</cbc:UUID>
    <cbc:IssueDate>${datos.fechaEmision}</cbc:IssueDate>
    <cbc:IssueTime>${datos.horaEmision}</cbc:IssueTime>
    <cbc:InvoiceTypeCode>01</cbc:InvoiceTypeCode>
    <cbc:DocumentCurrencyCode>COP</cbc:DocumentCurrencyCode>
    
    <cac:AccountingSupplierParty>
        <cbc:AdditionalAccountID>1</cbc:AdditionalAccountID>
        <cac:Party>
            <cac:PartyTaxScheme>
                <cbc:RegistrationName><![CDATA[VISUALSOFT DISTRIBUCIONES]]></cbc:RegistrationName>
                <cbc:CompanyID schemeAgencyID="195" schemeAgencyName="CO, DIAN" schemeID="${datos.dvEmisor}">${datos.nitEmisor}</cbc:CompanyID>
                <cac:TaxScheme>
                    <cbc:ID>01</cbc:ID>
                    <cbc:Name>IVA</cbc:Name>
                </cac:TaxScheme>
            </cac:PartyTaxScheme>
        </cac:Party>
    </cac:AccountingSupplierParty>

    <cac:AccountingCustomerParty>
        <cbc:AdditionalAccountID>${datos.tipoPersonaAdquirente}</cbc:AdditionalAccountID>
        <cac:Party>
            <cac:PartyTaxScheme>
                <cbc:RegistrationName><![CDATA[${datos.razonSocialAdquirente}]]></cbc:RegistrationName>
                <cbc:CompanyID schemeAgencyID="195" schemeAgencyName="CO, DIAN" schemeID="${datos.dvAdquirente}">${datos.nitAdquirente}</cbc:CompanyID>
                <cac:TaxScheme>
                    <cbc:ID>01</cbc:ID>
                    <cbc:Name>IVA</cbc:Name>
                </cac:TaxScheme>
            </cac:PartyTaxScheme>
        </cac:Party>
    </cac:AccountingCustomerParty>

    <cac:LegalMonetaryTotal>
        <cbc:LineExtensionAmount currencyID="COP">${datos.valorBruto.toFixed(2)}</cbc:LineExtensionAmount>
        <cbc:TaxExclusiveAmount currencyID="COP">${datos.valorBruto.toFixed(2)}</cbc:TaxExclusiveAmount>
        <cbc:TaxInclusiveAmount currencyID="COP">${datos.valorTotal.toFixed(2)}</cbc:TaxInclusiveAmount>
        <cbc:PayableAmount currencyID="COP">${datos.valorTotal.toFixed(2)}</cbc:PayableAmount>
    </cac:LegalMonetaryTotal>

    ${xmlLineas}
</Invoice>`;
  }
}
