			DO MetaCompras

			IF m.meta_regs > 0
				DO ComprasNetas

				DO CASE
					CASE m.brtygro = "Proveedor"
						SELECT ComprasNetas.cod_prov, ;
							SUM(ComprasNetas.vlrtotal) AS pesos_prov ;
							FROM ComprasNetas ;
							GROUP BY ComprasNetas.cod_prov ;
							ORDER BY ComprasNetas.cod_prov ;
							INTO CURSOR PreComprasProv

						DO CASE
							CASE m.filtrovta = 1
								SELECT PreComprasProv.cod_prov, ;
									PreComprasProv.pesos_prov ;
									FROM preComprasprov ;
									WHERE PreComprasProv.pesos_prov >= m.limuno ;
									ORDER BY PreComprasProv.cod_prov ;
									INTO CURSOR QryComprasProv
							CASE m.filtrovta = 2
								SELECT PreComprasProv.cod_prov, ;
									PreComprasProv.pesos_prov ;
									FROM preComprasprov ;
									WHERE PreComprasProv.pesos_prov <= m.limuno ;
									ORDER BY PreComprasProv.cod_prov ;
									INTO CURSOR QryComprasProv
							CASE m.filtrovta = 3
								SELECT PreComprasProv.cod_prov, ;
									PreComprasProv.pesos_prov ;
									FROM preComprasprov ;
									WHERE PreComprasProv.pesos_prov BETWEEN m.limuno AND m.limdos ;
									ORDER BY PreComprasProv.cod_prov ;
									INTO CURSOR QryComprasProv
						ENDCASE

						SELECT QryComprasProv.cod_prov AS codprov, ;
							ComprasNetas.doccant AS unidades, ;
							ComprasNetas.dockilos AS kilos, ;
							ComprasNetas.vlrtotal AS pesos_Compra;
							FROM qryComprasprov LEFT JOIN Comprasnetas ;
							ON QryComprasProv.cod_prov == ComprasNetas.cod_prov ;
							ORDER BY 1 ;
							INTO CURSOR ComprasProvDe

						DO CASE
							CASE m.brtyqry = "Distribuidor"
								SELECT SUM(ComprasProvDe.unidades) AS totunid, ;
									SUM(ComprasProvDe.kilos) AS totklgs, ;
									SUM(ComprasProvDe.pesos_Compra) AS totpesos ;
									FROM Comprasprovde ;
									INTO CURSOR TotDistri

								SELECT ComprasProvDe.codprov, ;
									SUM(ComprasProvDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(ComprasProvDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(ComprasProvDe.pesos_Compra) AS pesos_Compra, ;
									00.000 AS vlr_part ;
									FROM Comprasprovde ;
									GROUP BY 1 ;
									ORDER BY 1 ;
									INTO CURSOR ComprasProve READWRITE

								REPLACE ALL ComprasProve.Uni_part WITH IIF(EMPTY(totdistri.totunid),0.000,(ComprasProve.unidades/totdistri.totunid)*100) ;
									ComprasProve.Kgs_part WITH IIF(EMPTY(totdistri.totklgs),0.000,(ComprasProve.kilos/totdistri.totklgs)*100) ;
									ComprasProve.Vlr_part WITH IIF(EMPTY(totdistri.totpesos),0.000,(ComprasProve.pesos_Compra/totdistri.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT ComprasProve.codprov, MaeProve.nocoprov AS proveedor, ;
											ComprasProve.kilos, ;
											ComprasProve.Kgs_part, ;
											ComprasProve.pesos_Compra, ;
											ComprasProve.vlr_part ;
											FROM  Comprasprove INNER JOIN maeprove ;
											ON ComprasProve.codprov = MaeProve.codprov ;
											ORDER BY 1 ;
											INTO CURSOR QryVentas
									CASE m.codunim = "UNI"
										SELECT ComprasProve.codprov, MaeProve.nocoprov AS proveedor, ;
											ComprasProve.unidades, ;
											ComprasProve.Uni_part, ;
											ComprasProve.pesos_Compra, ;
											ComprasProve.vlr_part ;
											FROM  Comprasprove INNER JOIN maeprove ;
											ON ComprasProve.codprov = MaeProve.codprov ;
											ORDER BY 1 ;
											INTO CURSOR QryVentas
								ENDCASE
								SET TALK OFF

								m.reg_sel = _TALLY

								IF m.reg_sel > 0
									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degretpr"
								ELSE
									= MESSAGEBOX('No se encontraron compras con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
								ENDIF
							CASE m.brtyqry = "Zona"
								* Nothing
							CASE m.brtyqry = "Vendedor"
								* Nothing
							CASE m.brtyqry = "Negocio"
								* Nothing
						ENDCASE
					CASE m.brtygro = "Línea"
						SELECT ComprasNetas.cod_prov, ComprasNetas.cod_linea, ;
							SUM(ComprasNetas.vlrtotal) AS pesos_linea ;
							FROM Comprasnetas ;
							GROUP BY ComprasNetas.cod_prov, ComprasNetas.cod_linea  ;
							ORDER BY ComprasNetas.cod_prov, ComprasNetas.cod_linea ;
							INTO CURSOR PCompraProLin

						DO CASE
							CASE m.filtrovta = 1
								SELECT PCompraProLin.cod_prov, PCompraProLin.cod_linea, ;
									PCompraProLin.pesos_linea ;
									FROM pCompraprolin ;
									WHERE PCompraProLin.pesos_linea >= m.limuno ;
									ORDER BY PCompraProLin.cod_prov, PCompraProLin.cod_linea ;
									INTO CURSOR QCompraProLin
							CASE m.filtrovta = 2
								SELECT PCompraProLin.cod_prov, PCompraProLin.cod_linea, ;
									PCompraProLin.pesos_linea ;
									FROM pCompraprolin ;
									WHERE PCompraProLin.pesos_linea <= m.limuno ;
									ORDER BY PCompraProLin.cod_prov, PCompraProLin.cod_linea ;
									INTO CURSOR QCompraProLin
							CASE m.filtrovta = 3
								SELECT PCompraProLin.cod_prov, PCompraProLin.cod_linea, ;
									PCompraProLin.pesos_linea ;
									FROM pCompraprolin ;
									WHERE PCompraProLin.pesos_linea BETWEEN m.limuno AND m.limdos ;
									ORDER BY PCompraProLin.cod_prov, PCompraProLin.cod_linea ;
									INTO CURSOR QCompraProLin
						ENDCASE

						SELECT QCompraProLin.cod_prov AS codprov, QCompraProLin.cod_linea AS codlin, ;
							ComprasNetas.doccant AS unidades, ;
							ComprasNetas.dockilos AS kilos, ;
							ComprasNetas.vlrtotal AS pesos_Compra ;
							FROM qCompraprolin INNER JOIN Comprasnetas ;
							ON QCompraProLin.cod_prov+QCompraProLin.cod_linea == ComprasNetas.cod_prov+ComprasNetas.cod_linea ;
							ORDER BY 1, 2 ;
							INTO CURSOR CompraProvLinDe

						DO CASE
							CASE m.brtyqry = "Distribuidor"
								SELECT CompraProvLinDe.codprov, ;
									SUM(CompraProvLinDe.unidades) AS totunid, ;
									SUM(CompraProvLinDe.kilos) AS totklgs, ;
									SUM(CompraProvLinDe.pesos_Compra) AS totpesos ;
									FROM Compraprovlinde ;
									GROUP BY CompraProvLinDe.codprov ;
									ORDER BY CompraProvLinDe.codprov ;
									INTO CURSOR TotDistri READWRITE

								INDEX ON codprov TAG Codigo

								SELECT CompraProvLinDe.codprov, CompraProvLinDe.codlin, ;
									SUM(CompraProvLinDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(CompraProvLinDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(CompraProvLinDe.pesos_Compra) AS pesos_Compra, ;
									00.000 AS vlr_part ;
									FROM CompraProvLinDe ;
									GROUP BY 1, 2 ;
									ORDER BY 1, 2 ;
									INTO CURSOR CompraProvLin READWRITE

								SET RELATION TO CompraProvLin.codprov INTO TotDistri ADDITIVE

								REPLACE ALL CompraProvLin.Uni_part WITH IIF(EMPTY(TotDistri.totunid),0.000,(CompraProvLin.unidades/TotDistri.totunid)*100) ;
									CompraProvLin.Kgs_part WITH IIF(EMPTY(TotDistri.totklgs),0.000,(CompraProvLin.kilos/TotDistri.totklgs)*100) ;
									CompraProvLin.Vlr_part WITH IIF(EMPTY(TotDistri.totpesos),0.000,(CompraProvLin.pesos_Compra/TotDistri.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT CompraProvLin.codprov, MaeProve.nocoprov AS proveedor, ;
											CompraProvLin.codlin, MaeLinea.desclin AS linea, ;
											CompraProvLin.kilos, ;
											CompraProvLin.Kgs_part, ;
											CompraProvLin.pesos_Compra, ;
											CompraProvLin.vlr_part ;
											FROM  Compraprovlin INNER JOIN maeprove ;
											ON CompraProvLin.codprov = MaeProve.codprov ;
											INNER JOIN MaeLinea ;
											ON CompraProvLin.codprov+CompraProvLin.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											ORDER BY 1, 3 ;
											INTO CURSOR QryVentas
									CASE m.codunim = "UNI"
										SELECT CompraProvLin.codprov, MaeProve.nocoprov AS proveedor, ;
											CompraProvLin.codlin, MaeLinea.desclin AS linea, ;
											CompraProvLin.unidades, ;
											CompraProvLin.Uni_part, ;
											CompraProvLin.pesos_Compra, ;
											CompraProvLin.vlr_part ;
											FROM  Compraprovlin INNER JOIN maeprove ;
											ON CompraProvLin.codprov = MaeProve.codprov ;
											INNER JOIN MaeLinea ;
											ON CompraProvLin.codprov+CompraProvLin.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											ORDER BY 1, 3 ;
											INTO CURSOR QryVentas
								ENDCASE
								SET TALK OFF

								m.reg_sel = _TALLY

								IF m.reg_sel > 0
									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degretli"
								ELSE
									= MESSAGEBOX('No se encontraron compras con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
								ENDIF
							CASE m.brtyqry = "Zona"
								* Nothing
							CASE m.brtyqry = "Vendedor"
								* Nothing
							CASE m.brtyqry = "Negocio"
								* Nothing
						ENDCASE
					CASE m.brtygro = "Referencia"
						SELECT ComprasNetas.cod_prov, ComprasNetas.cod_linea, ComprasNetas.cod_refe, ;
							SUM(ComprasNetas.vlrtotal) AS pesos_linea ;
							FROM Comprasnetas ;
							GROUP BY ComprasNetas.cod_prov, ComprasNetas.cod_linea, ComprasNetas.cod_refe ;
							ORDER BY ComprasNetas.cod_prov, ComprasNetas.cod_linea, ComprasNetas.cod_refe ;
							INTO CURSOR PCompraPrLiRe

						DO CASE
							CASE m.filtrovta = 1
								SELECT PCompraPrLiRe.cod_prov, PCompraPrLiRe.cod_linea, PCompraPrLiRe.cod_refe, ;
									PCompraPrLiRe.pesos_linea ;
									FROM pCompraprlire ;
									WHERE PCompraPrLiRe.pesos_linea >= m.limuno ;
									ORDER BY PCompraPrLiRe.cod_prov, PCompraPrLiRe.cod_linea, PCompraPrLiRe.cod_refe ;
									INTO CURSOR QCompraPrLiRe
							CASE m.filtrovta = 2
								SELECT PCompraPrLiRe.cod_prov, PCompraPrLiRe.cod_linea, PCompraPrLiRe.cod_refe, ;
									PCompraPrLiRe.pesos_linea ;
									FROM pCompraprlire ;
									WHERE PCompraPrLiRe.pesos_linea <= m.limuno ;
									ORDER BY PCompraPrLiRe.cod_prov, PCompraPrLiRe.cod_linea, PCompraPrLiRe.cod_refe ;
									INTO CURSOR QCompraPrLiRe
							CASE m.filtrovta = 3
								SELECT PCompraPrLiRe.cod_prov, PCompraPrLiRe.cod_linea, PCompraPrLiRe.cod_refe, ;
									PCompraPrLiRe.pesos_linea ;
									FROM pCompraprlire ;
									WHERE PCompraPrLiRe.pesos_linea BETWEEN m.limuno AND m.limdos ;
									ORDER BY PCompraPrLiRe.cod_prov, PCompraPrLiRe.cod_linea, PCompraPrLiRe.cod_refe ;
									INTO CURSOR QCompraPrLiRe
						ENDCASE

						SELECT QCompraPrLiRe.cod_prov AS codprov, QCompraPrLiRe.cod_linea AS codlin, QCompraPrLiRe.cod_refe AS codarti, ;
							ComprasNetas.referencia, ;
							ComprasNetas.doccant AS unidades, ;
							ComprasNetas.dockilos AS kilos, ;
							ComprasNetas.vlrtotal AS pesos_Compra ;
							FROM  qCompraprlire INNER JOIN Comprasnetas ;
							ON QCompraPrLiRe.cod_prov+QCompraPrLiRe.cod_linea+QCompraPrLiRe.cod_refe == ComprasNetas.cod_prov+ComprasNetas.cod_linea++ComprasNetas.cod_refe ;
							ORDER BY 1, 2 ;
							INTO CURSOR CompraProLiReDe

						DO CASE
							CASE m.brtyqry = "Distribuidor"
								SELECT CompraProLiReDe.codprov, CompraProLiReDe.codlin, CompraProLiReDe.codarti, ;
									SUM(CompraProLiReDe.unidades) AS totunid, ;
									SUM(CompraProLiReDe.kilos) AS totklgs, ;
									SUM(CompraProLiReDe.pesos_Compra) AS totpesos ;
									FROM  Compraprolirede ;
									GROUP BY CompraProLiReDe.codprov, CompraProLiReDe.codlin ;
									ORDER BY CompraProLiReDe.codprov, CompraProLiReDe.codlin ;
									INTO CURSOR ToPrLiRe READWRITE

								INDEX ON codprov+codlin TAG Codigo

								SELECT CompraProLiReDe.codprov, CompraProLiReDe.codlin, CompraProLiReDe.codarti, ;
									CompraProLiReDe.referencia, ;
									SUM(CompraProLiReDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(CompraProLiReDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(CompraProLiReDe.pesos_Compra) AS pesos_Compra, ;
									00.000 AS vlr_part ;
									FROM  Compraprolirede ;
									GROUP BY CompraProLiReDe.codprov, CompraProLiReDe.codlin, CompraProLiReDe.codarti ;
									ORDER BY CompraProLiReDe.codprov, CompraProLiReDe.codlin, CompraProLiReDe.codarti ;
									INTO CURSOR CompraPrLiRe READWRITE

								SET RELATION TO CompraPrLiRe.codprov+CompraPrLiRe.codlin INTO ToPrLiRe ADDITIVE

								REPLACE ALL CompraPrLiRe.Uni_part WITH IIF(EMPTY(ToPrLiRe.totunid),0.000,(CompraPrLiRe.unidades/ToPrLiRe.totunid)*100) ;
									CompraPrLiRe.Kgs_part WITH IIF(EMPTY(ToPrLiRe.totklgs),0.000,(CompraPrLiRe.kilos/ToPrLiRe.totklgs)*100) ;
									CompraPrLiRe.Vlr_part WITH IIF(EMPTY(ToPrLiRe.totpesos),0.000,(CompraPrLiRe.pesos_Compra/ToPrLiRe.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT CompraPrLiRe.codprov, MaeProve.nocoprov AS proveedor, ;
											CompraPrLiRe.codlin, MaeLinea.desclin AS linea, ;
											CompraPrLiRe.codarti, CompraPrLiRe.referencia, ;
											CompraPrLiRe.kilos, ;
											CompraPrLiRe.Kgs_part, ;
											CompraPrLiRe.pesos_Compra, ;
											CompraPrLiRe.vlr_part ;
											FROM  Compraprlire INNER JOIN maeprove ;
											ON CompraPrLiRe.codprov = MaeProve.codprov ;
											INNER JOIN maelinea ;
											ON CompraPrLiRe.codprov+CompraPrLiRe.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											ORDER BY 1, 3, 5 ;
											INTO CURSOR QryVentas
									CASE m.codunim = "UNI"
										SELECT CompraPrLiRe.codprov, MaeProve.nocoprov AS proveedor, ;
											CompraPrLiRe.codlin, MaeLinea.desclin AS linea, ;
											CompraPrLiRe.codarti, CompraPrLiRe.referencia, ;
											CompraPrLiRe.unidades, ;
											CompraPrLiRe.Uni_part, ;
											CompraPrLiRe.pesos_Compra, ;
											CompraPrLiRe.vlr_part ;
											FROM  Compraprlire INNER JOIN maeprove ;
											ON CompraPrLiRe.codprov = MaeProve.codprov ;
											INNER JOIN maelinea ;
											ON CompraPrLiRe.codprov+CompraPrLiRe.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											ORDER BY 1, 3, 5 ;
											INTO CURSOR QryVentas
								ENDCASE
								SET TALK OFF

								m.reg_sel = _TALLY

								IF m.reg_sel > 0
	*!*								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE

									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degretre"
								ELSE
									= MESSAGEBOX('No se encontraron compras con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
								ENDIF
							CASE m.brtyqry = "Zona"
								* Nothing
							CASE m.brtyqry = "Vendedor"
								* Nothing
							CASE m.brtyqry = "Negocio"
								* Nothing
						ENDCASE
				ENDCASE
			ELSE
				= MESSAGEBOX('No se encontraron compras con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
			ENDIF
		ELSE
			= MESSAGEBOX('Fechas NO válidas.',btn_ac+icn_inf,sysnom)
		ENDIF
