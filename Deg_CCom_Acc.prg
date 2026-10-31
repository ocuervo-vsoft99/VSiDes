DO CASE
	CASE m.bcgc = "Generar"
		IF !EMPTY(m.fechin) AND !EMPTY(m.fechfi)
*!*				m.sfechin = DTOS(m.fechin)
*!*				m.sfechfi = DTOS(m.fechfi)

*!*				wherefac = ""
*!*				whererem = ""

*!*				IF !EMPTY(ALLTRIM(m.cod_vend))
*!*					wherefac = wherefac + " AND MaeFacEn.cod_vend == m.cod_vend"
*!*					whererem = whererem + " AND MaeRemEn.cod_vend == m.cod_vend"
*!*				ENDIF

			SET TALK ON

			m.camb_regs = 0
			DO MetaCambios

***			COPY TO MetaCambios

			IF m.camb_regs > 0

*!*				SELECT MaeFacEn.facnro, MaeFacEn.facfecha AS docfecha, ;
*!*					MaeFacEn.codred, MaeFacEn.coddsto, MaeFacEn.codzona, MaeFacEn.codloca, ;
*!*					MaeFacEn.ideclien, ;
*!*					MaeFacEn.cod_vend ;
*!*					FROM  maefacen ;
*!*					WHERE DTOS(MaeFacEn.facfecha) BETWEEN m.sfechin AND m.sfechfi ;
*!*					&wherefac. ;
*!*					AND EMPTY(ALLTRIM(MaeFacEn.remnro)) ;
*!*					AND NOT(MaeFacEn.anulada);
*!*					INTO CURSOR QryFacEn

*!*				SELECT MaeRemEn.remnro, MaeRemEn.remfecha AS docfecha, ;
*!*					MaeRemEn.codred, MaeRemEn.coddsto, MaeRemEn.codzona, MaeRemEn.codloca, ;
*!*					MaeRemEn.ideclien, ;
*!*					MaeRemEn.cod_vend ;
*!*					FROM  maeremen ;
*!*					WHERE DTOS(MaeRemEn.remfecha) BETWEEN m.sfechin AND m.sfechfi;
*!*					&whererem. ;
*!*					AND NOT(MaeRemEn.anulada);
*!*					INTO CURSOR QryRemEn

*!*				whrfacde = ""
*!*				whrremde = ""

*!*	*!*				IF !EMPTY(ALLTRIM(m.codprov)) AND !EMPTY(ALLTRIM(m.codlin)) AND !EMPTY(ALLTRIM(m.codarti))
*!*	*!*					whrfacde = whrfacde + "WHERE MaeFacDe.codprov+MaeFacDe.codlin+MaeFacDe.codarti == m.codprov+m.codlin+m.codarti"
*!*	*!*					whrremde = whrremde + "WHERE MaeRemDe.codprov+MaeRemDe.codlin+MaeRemDe.codarti == m.codprov+m.codlin+m.codarti"
*!*	*!*				ELSE
*!*					IF !EMPTY(ALLTRIM(m.codprov)) AND !EMPTY(ALLTRIM(m.codlin))
*!*						whrfacde = whrfacde + "WHERE MaeFacDe.codprov+MaeFacDe.codlin == m.codprov+m.codlin"
*!*						whrremde = whrremde + "WHERE MaeRemDe.codprov+MaeRemDe.codlin == m.codprov+m.codlin"
*!*					ELSE
*!*						IF !EMPTY(ALLTRIM(m.codprov))
*!*							whrfacde = whrfacde + "WHERE MaeFacDe.codprov == m.codprov"
*!*							whrremde = whrremde + "WHERE MaeRemDe.codprov == m.codprov"
*!*						ELSE
*!*						ENDIF
*!*					ENDIF
*!*	*!*				ENDIF

*!*				SELECT QryFacEn.codred, QryFacEn.coddsto, QryFacEn.codzona, QryFacEn.codloca, ;
*!*					QryFacEn.ideclien, QryFacEn.cod_vend, ;
*!*					MaeFacDe.codprov, MaeFacDe.codlin, MaeFacDe.codarti, ;
*!*					MaeFacDe.faccant AS cantvend, MaeFacDe.precvent, ;
*!*					0000000000.00 AS vlrtotal ;
*!*					FROM  maefacde INNER JOIN qryfacen ;
*!*					ON  MaeFacDe.facnro = QryFacEn.facnro;
*!*					&whrfacde. ;
*!*					INTO CURSOR QryFactu READWRITE

*!*				m.reg_fac = _TALLY

*!*				REPLACE vlrtotal WITH (cantvend*precvent) ALL

*!*				SELECT QryRemEn.codred, QryRemEn.coddsto, QryRemEn.codzona, QryRemEn.codloca, ;
*!*					QryRemEn.ideclien, QryRemEn.cod_vend, ;
*!*					MaeRemDe.codprov, MaeRemDe.codlin, MaeRemDe.codarti, ;
*!*					MaeRemDe.remcant AS cantvend, MaeRemDe.precvent, ;
*!*					0000000000.00 AS vlrtotal ;
*!*					FROM  maeremde INNER JOIN qryremen ;
*!*					ON  MaeRemDe.remnro = QryRemEn.remnro;
*!*					&whrremde. ;
*!*					INTO CURSOR QryRemis READWRITE

*!*				m.reg_rem = _TALLY

*!*				REPLACE vlrtotal WITH (cantvend*precvent) ALL

*!*				IF m.reg_fac > 0 AND m.reg_rem > 0
*!*					SELECT QryFactu.* ;
*!*						FROM  qryfactu ;
*!*					UNION ALL ;
*!*						SELECT QryRemis.* ;
*!*							FROM  qryremis ;
*!*						INTO CURSOR QryVtasDe
*!*				ELSE
*!*					IF m.reg_fac > 0
*!*						SELECT QryFactu.* ;
*!*							FROM  qryfactu ;
*!*						INTO CURSOR QryVtasDe
*!*					ELSE
*!*						SELECT QryRemis.* ;
*!*							FROM  qryremis ;
*!*							INTO CURSOR QryVtasDe
*!*					ENDIF
*!*				ENDIF

*!*				SELECT QryVtasDe.cod_vend, ;
*!*					QryVtasDe.codred, QryVtasDe.coddsto, QryVtasDe.codzona, QryVtasDe.codloca, ;
*!*					QryVtasDe.ideclien, ;
*!*					QryVtasDe.codprov, QryVtasDe.codlin, QryVtasDe.codarti, ;
*!*					SUM(QryVtasDe.cantvend) AS unidades, ;
*!*					SUM(QryVtasDe.vlrtotal) AS pesos_vta;
*!*					FROM  qryvtasde ;
*!*					GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9 ;
*!*					ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9 ;
*!*					INTO CURSOR VtasRefNeg

*!*				whereneg = ""

*!*				IF !EMPTY(ALLTRIM(m.codred)) AND !EMPTY(ALLTRIM(m.coddsto)) AND !EMPTY(ALLTRIM(m.codzona))
*!*					whereneg = whereneg + "WHERE MaeNegoc.codred+MaeNegoc.coddsto+MaeNegoc.codzona == m.codred+m.coddsto+m.codzona"
*!*				ELSE
*!*					IF !EMPTY(ALLTRIM(m.codred)) AND !EMPTY(ALLTRIM(m.coddsto))
*!*						whereneg = whereneg + "WHERE MaeNegoc.codred+MaeNegoc.coddsto == m.codred+m.coddsto"
*!*					ELSE
*!*						IF !EMPTY(ALLTRIM(m.codred))
*!*							whereneg = whereneg + "WHERE MaeNegoc.codred == m.codred"
*!*						ELSE
*!*						ENDIF
*!*					ENDIF
*!*				ENDIF

*!*				IF !EMPTY(ALLTRIM(m.ideclien))
*!*					whereneg = whereneg + IIF(EMPTY(ALLTRIM(whereneg)),"WHERE "," AND ")+"MaeNegoc.ideclien == m.ideclien"
*!*				ENDIF

*!*				IF !EMPTY(ALLTRIM(m.coddepto)) AND !EMPTY(ALLTRIM(m.codciuda))
*!*					whereneg = whereneg + IIF(EMPTY(ALLTRIM(whereneg)),"WHERE "," AND ")+"MaeNegoc.coddepto+MaeNegoc.codciuda == m.coddepto+m.codciuda"
*!*				ELSE
*!*					IF !EMPTY(ALLTRIM(m.coddepto))
*!*						whereneg = whereneg + IIF(EMPTY(ALLTRIM(whereneg)),"WHERE "," AND ")+"MaeNegoc.coddepto == m.coddepto"
*!*					ELSE
*!*					ENDIF
*!*				ENDIF

*!*				IF !EMPTY(ALLTRIM(m.codtineg))
*!*					whereneg = whereneg + IIF(EMPTY(ALLTRIM(whereneg)),"WHERE "," AND ")+"MaeNegoc.codtineg == m.codtineg"
*!*				ENDIF

*!*				SELECT VtasRefNeg.cod_vend, ;
*!*					VtasRefNeg.codred, VtasRefNeg.coddsto, VtasRefNeg.codzona, VtasRefNeg.codloca, ;
*!*					VtasRefNeg.ideclien, ;
*!*					SPACE(50) AS cliente, MaeNegoc.nomnego AS Negocio, MaeNegoc.dirnego AS dir_negoc, MaeNegoc.telnego AS tel_negoc, ;
*!*					VtasRefNeg.codprov, VtasRefNeg.codlin, VtasRefNeg.codarti, ;
*!*					VtasRefNeg.unidades, ;
*!*					VtasRefNeg.pesos_vta, ;
*!*					MaeNegoc.codtineg, SPACE(30) AS tipo_negoc, MaeNegoc.coddepto, MaeNegoc.codciuda, SPACE(35) AS Ciudad ;
*!*					FROM  vtasrefneg LEFT JOIN maenegoc ;
*!*					ON VtasRefNeg.codred+VtasRefNeg.coddsto+VtasRefNeg.codzona+VtasRefNeg.codloca+VtasRefNeg.ideclien = MaeNegoc.codred+MaeNegoc.coddsto+MaeNegoc.codzona+MaeNegoc.codloca+MaeNegoc.ideclien ;
*!*					&whereneg. ;
*!*					INTO CURSOR TmpVtasNeg READWRITE

*!*				USE IN MaeNegoc

*!*				USE MaeClien IN 0 ORDER TAG ideclien
*!*				SELECT TmpVtasNeg
*!*				SET RELATION TO TmpVtasNeg.ideclien INTO MaeClien
*!*				REPLACE TmpVtasNeg.cliente WITH MaeClien.rasoclien ALL
*!*				USE IN MaeClien

*!*				IF !EMPTY(ALLTRIM(m.codruta))
*!*					SELECT MaeRutas.codred, MaeRutas.coddsto, MaeRutas.codzona, MaeRutas.codloca, ;
*!*						MaeRutas.codruta, MaeRutas.ideclien ;
*!*						FROM maerutas ;
*!*						WHERE MaeRutas.codred+MaeRutas.coddsto+MaeRutas.codzona+MaeRutas.codruta = m.codred+m.coddsto+m.codzona+m.codruta ;
*!*						AND MaeRutas.estado = "A";
*!*						AND !EMPTY(MaeRutas.orden);
*!*						INTO CURSOR QryRutas

*!*					USE IN MaeRutas

*!*					SELECT TmpVtasNeg.* ;
*!*						FROM  qryrutas INNER JOIN tmpvtasneg ;
*!*						ON QryRutas.codred+QryRutas.coddsto+QryRutas.codzona+QryRutas.codloca+QryRutas.ideclien = TmpVtasNeg.codred+TmpVtasNeg.coddsto+TmpVtasNeg.codzona+TmpVtasNeg.codloca+TmpVtasNeg.ideclien ;
*!*						INTO CURSOR PreVtasNeg READWRITE
*!*				ELSE
*!*					SELECT TmpVtasNeg.* ;
*!*						FROM  tmpvtasneg ;
*!*						INTO CURSOR PreVtasNeg READWRITE
*!*				ENDIF

*!*				SELECT PreVtasNeg
*!*				SET RELATION TO PreVtasNeg.codtineg INTO MaeTiNeg
*!*				REPLACE PreVtasNeg.tipo_negoc WITH MaeTiNeg.desctineg ALL

*!*				SET RELATION TO PreVtasNeg.coddepto+PreVtasNeg.codciuda INTO MaeCiuda
*!*				REPLACE PreVtasNeg.ciudad WITH MaeCiuda.ciudad ALL

*!*	*!*				SELECT IniVtasNeg.codred, IniVtasNeg.coddsto, IniVtasNeg.codzona, IniVtasNeg.codloca, ;
*!*	*!*					IniVtasNeg.ideclien, IniVtasNeg.codtineg, MaeTiNeg.desctineg AS tipo_negoc, IniVtasNeg.Negocio, ;
*!*	*!*					IniVtasNeg.dir_negoc, IniVtasNeg.tel_negoc, MaeCiuda.ciudad, ;
*!*	*!*					IniVtasNeg.cod_vend, ;
*!*	*!*					IniVtasNeg.codprov, IniVtasNeg.codlin, IniVtasNeg.codarti, ;
*!*	*!*					IniVtasNeg.unidades, ;
*!*	*!*					IniVtasNeg.pesos_vta;
*!*	*!*					FROM  maetineg INNER JOIN inivtasneg ;
*!*	*!*					ON MaeTiNeg.codtineg = IniVtasNeg.codtineg ;
*!*	*!*					INNER JOIN maeciuda ;
*!*	*!*					ON MaeCiuda.coddepto+MaeCiuda.codciuda = IniVtasNeg.coddepto+IniVtasNeg.codciuda ;
*!*	*!*					INTO CURSOR PreVtasNeg

*!*				SELECT PreVtasNeg.cod_vend, ;
*!*					PreVtasNeg.codred, PreVtasNeg.coddsto, PreVtasNeg.codzona, PreVtasNeg.codloca, ;
*!*					PreVtasNeg.ideclien, PreVtasNeg.cliente, PreVtasNeg.negocio, ;
*!*					PreVtasNeg.codtineg, PreVtasNeg.tipo_negoc, ;
*!*					PreVtasNeg.dir_negoc, PreVtasNeg.tel_negoc, PreVtasNeg.ciudad, ;
*!*					PreVtasNeg.codprov, PreVtasNeg.codlin, PreVtasNeg.codarti, ;
*!*					PreVtasNeg.unidades, ;
*!*					(PreVtasNeg.unidades*MaeArtic.facconkgs) AS kilos, ;
*!*					PreVtasNeg.pesos_vta;
*!*					FROM  prevtasneg INNER JOIN maeartic ;
*!*					ON PreVtasNeg.codprov+PreVtasNeg.codlin+PreVtasNeg.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
*!*					ORDER BY 1, 2, 3, 4, 5, 6, 14, 15, 16 ;
*!*					INTO CURSOR QryVtasNeg


			DO CASE
				CASE m.brtygro = "Total"
					SELECT MetaCams.codcambio, ;
						SUM(MetaCams.vlrtotal) AS pesos_conc ;
						FROM metacams ;
						GROUP BY MetaCams.codcambio ;
						ORDER BY MetaCams.codcambio ;
						INTO CURSOR PreCamsConc

*						INTO CURSOR PreVtasVend

					DO CASE
						CASE m.filtrovta = 1
							SELECT PreCamsConc.codcambio, ;
								PreCamsConc.pesos_conc ;
								FROM precamsconc ;
								WHERE PreCamsConc.pesos_conc >= m.limuno ;
								ORDER BY PreCamsConc.codcambio ;
								INTO CURSOR QryCamsConc

*								INTO CURSOR QryVtasVend
						CASE m.filtrovta = 2
							SELECT PreCamsConc.codcambio, ;
								PreCamsConc.pesos_conc ;
								FROM precamsconc ;
								WHERE PreCamsConc.pesos_conc <= m.limuno ;
								ORDER BY PreCamsConc.codcambio ;
								INTO CURSOR QryCamsConc
						CASE m.filtrovta = 3
							SELECT PreCamsConc.codcambio, ;
								PreCamsConc.pesos_conc ;
								FROM precamsconc ;
								WHERE PreCamsConc.pesos_conc BETWEEN m.limuno AND m.limdos ;
								ORDER BY PreCamsConc.codcambio ;
								INTO CURSOR QryCamsConc
					ENDCASE

					SELECT QryCamsConc.codcambio, MetaCams.desccambio, ;
						MetaCams.cod_prov AS codprov, MetaCams.cod_linea AS codlin, ;
						MetaCams.cod_refe AS codarti, MetaCams.referencia, ;
						SUM(MetaCams.doccant) AS unidades, ;
						SUM(MetaCams.dockilos) AS kilos, ;
						SUM(MetaCams.vlrtotal) AS pesos_cam;
						FROM qrycamsconc LEFT JOIN metacams ;
						ON QryCamsConc.codcambio == MetaCams.codcambio ;
						GROUP BY 1, 3, 4, 5  ;
						ORDER BY 1, 3, 4, 5  ;
						INTO CURSOR CamsConCDe

					DO CASE
						CASE m.brtyqry = "Distribuidor"
							SELECT SUM(CamsConCDe.unidades) AS totunid, ;
								SUM(CamsConCDe.kilos) AS totklgs, ;
								SUM(CamsConCDe.pesos_cam) AS totpesos ;
								FROM camsconcde ;
								INTO CURSOR TotDistri

							SELECT CamsConCDe.codcambio, CamsConCDe.desccambio, ;
								SUM(CamsConCDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(CamsConCDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(CamsConCDe.pesos_cam) AS pesos_cam, ;
								00.000 AS vlr_part ;
								FROM camsconcde ;
								GROUP BY 1 ;
								ORDER BY 1 ;
								INTO CURSOR CamsConce READWRITE

							REPLACE ALL CamsConce.Uni_part WITH IIF(EMPTY(totdistri.totunid),0.000,(CamsConce.unidades/totdistri.totunid)*100) ;
								CamsConce.Kgs_part WITH IIF(EMPTY(totdistri.totklgs),0.000,(CamsConce.kilos/totdistri.totklgs)*100) ;
								CamsConce.Vlr_part WITH IIF(EMPTY(totdistri.totpesos),0.000,(CamsConce.pesos_cam/totdistri.totpesos)*100)

							DO CASE
								CASE m.codunim = "KLG"
									SELECT CamsConce.codcambio, CamsConce.desccambio, ;
										CamsConce.kilos, ;
										CamsConce.Kgs_part, ;
										CamsConce.pesos_cam, ;
										CamsConce.vlr_part ;
										FROM  camsconce ;
										ORDER BY 1 ;
										INTO CURSOR QryCamsCo
								CASE m.codunim = "UNI"
									SELECT CamsConce.codcambio, CamsConce.desccambio, ;
										CamsConce.unidades, ;
										CamsConce.Uni_part, ;
										CamsConce.pesos_cam, ;
										CamsConce.vlr_part ;
										FROM  camsconce ;
										ORDER BY 1 ;
										INTO CURSOR QryCamsCo
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrccod"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF
						CASE m.brtyqry = "Proveedor"
							SELECT VtasVendDe.cod_vend, ;
								SUM(VtasVendDe.unidades) AS totunid, ;
								SUM(VtasVendDe.kilos) AS totklgs, ;
								SUM(VtasVendDe.pesos_vta) AS totpesos ;
								FROM vtasvendde ;
								GROUP BY VtasVendDe.cod_vend ;
								ORDER BY VtasVendDe.cod_vend ;
								INTO CURSOR TotVende READWRITE

							INDEX ON cod_vend TAG Codigo

							SELECT VtasVendDe.cod_vend, VtasVendDe.vendedor, ;
								VtasVendDe.codprov, ;
								SUM(VtasVendDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtasVendDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtasVendDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM vtasvendde ;
								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov ;
								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov ;
								INTO CURSOR VtasVende READWRITE

							SET RELATION TO VtasVende.cod_vend INTO totvende ADDITIVE

							REPLACE ALL VtasVende.Uni_part WITH IIF(EMPTY(TotVende.totunid),0.000,(VtasVende.unidades/TotVende.totunid)*100) ;
								VtasVende.Kgs_part WITH IIF(EMPTY(TotVende.totklgs),0.000,(VtasVende.kilos/TotVende.totklgs)*100) ;
								VtasVende.Vlr_part WITH IIF(EMPTY(TotVende.totpesos),0.000,(VtasVende.pesos_vta/TotVende.totpesos)*100)

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
										VtasVende.codprov, MaeProve.nocoprov, ;
										VtasVende.kilos, ;
										VtasVende.Kgs_part, ;
										VtasVende.pesos_vta, ;
										VtasVende.vlr_part ;
										FROM  vtasvende INNER JOIN maeprove ;
										ON VtasVende.codprov = MaeProve.codprov ;
										ORDER BY 1, 3 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
										VtasVende.codprov, MaeProve.nocoprov, ;
										VtasVende.unidades, ;
										VtasVende.Uni_part, ;
										VtasVende.pesos_vta, ;
										VtasVende.vlr_part ;
										FROM  vtasvende INNER JOIN maeprove ;
										ON VtasVende.codprov = MaeProve.codprov ;
										ORDER BY 1, 3 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvep"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF
						CASE m.brtyqry = "Linea"
							SELECT VtasVendDe.cod_vend, VtasVendDe.codprov, ;
								SUM(VtasVendDe.unidades) AS totunid, ;
								SUM(VtasVendDe.kilos) AS totklgs, ;
								SUM(VtasVendDe.pesos_vta) AS totpesos ;
								FROM vtasvendde ;
								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov ;
								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov ;
								INTO CURSOR TotVenPro READWRITE

							INDEX ON cod_vend+codprov TAG Codigo

							SELECT VtasVendDe.cod_vend, VtasVendDe.vendedor, ;
								VtasVendDe.codprov, VtasVendDe.codlin, ;
								SUM(VtasVendDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtasVendDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtasVendDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM vtasvendde ;
								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
								INTO CURSOR VtasVende READWRITE

							SET RELATION TO VtasVende.cod_vend+VtasVende.codprov INTO totvenpro ADDITIVE

							REPLACE ALL VtasVende.Uni_part WITH IIF(EMPTY(TotVenPro.totunid),0.000,(VtasVende.unidades/TotVenPro.totunid)*100) ;
								VtasVende.Kgs_part WITH IIF(EMPTY(TotVenPro.totklgs),0.000,(VtasVende.kilos/TotVenPro.totklgs)*100) ;
								VtasVende.Vlr_part WITH IIF(EMPTY(TotVenPro.totpesos),0.000,(VtasVende.pesos_vta/TotVenPro.totpesos)*100)

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
										VtasVende.codprov, ;
										VtasVende.codlin, MaeLinea.desclin, ;
										VtasVende.kilos, ;
										VtasVende.Kgs_part, ;
										VtasVende.pesos_vta, ;
										VtasVende.vlr_part ;
										FROM  vtasvende INNER JOIN maelinea ;
										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
										VtasVende.codprov, ;
										VtasVende.codlin, MaeLinea.desclin, ;
										VtasVende.unidades, ;
										VtasVende.Uni_part, ;
										VtasVende.pesos_vta, ;
										VtasVende.vlr_part ;
										FROM  vtasvende INNER JOIN maelinea ;
										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvel"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF
						CASE m.brtyqry = "Referencia"
							SELECT VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin, ;
								SUM(VtasVendDe.unidades) AS totunid, ;
								SUM(VtasVendDe.kilos) AS totklgs, ;
								SUM(VtasVendDe.pesos_vta) AS totpesos ;
								FROM vtasvendde ;
								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
								INTO CURSOR ToVePrLi READWRITE

							INDEX ON cod_vend+codprov+codlin TAG Codigo

							SELECT VtasVendDe.cod_vend, VtasVendDe.vendedor, ;
								VtasVendDe.codprov, VtasVendDe.codlin, ;
								VtasVendDe.codarti, VtasVendDe.referencia, ;
								SUM(VtasVendDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtasVendDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtasVendDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM vtasvendde ;
								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin, VtasVendDe.codarti ;
								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin, VtasVendDe.codarti ;
								INTO CURSOR VtasVende READWRITE

							SET RELATION TO VtasVende.cod_vend+VtasVende.codprov+VtasVende.codlin INTO toveprli ADDITIVE

							REPLACE ALL VtasVende.Uni_part WITH IIF(EMPTY(ToVePrLi.totunid),0.000,(VtasVende.unidades/ToVePrLi.totunid)*100) ;
								VtasVende.Kgs_part WITH IIF(EMPTY(ToVePrLi.totklgs),0.000,(VtasVende.kilos/ToVePrLi.totklgs)*100) ;
								VtasVende.Vlr_part WITH IIF(EMPTY(ToVePrLi.totpesos),0.000,(VtasVende.pesos_vta/ToVePrLi.totpesos)*100)

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
										VtasVende.codprov, VtasVende.codlin, MaeLinea.desclin, ;
										VtasVende.codarti, VtasVende.referencia, ;
										VtasVende.kilos, ;
										VtasVende.Kgs_part, ;
										VtasVende.pesos_vta, ;
										VtasVende.vlr_part ;
										FROM  vtasvende INNER JOIN maelinea ;
										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4, 5 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
										VtasVende.codprov, VtasVende.codlin, MaeLinea.desclin, ;
										VtasVende.codarti, VtasVende.referencia, ;
										VtasVende.unidades, ;
										VtasVende.Uni_part, ;
										VtasVende.pesos_vta, ;
										VtasVende.vlr_part ;
										FROM  vtasvende INNER JOIN maelinea ;
										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4, 5 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcver"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF
					ENDCASE
********************************Inicia x Zona
				CASE m.brtygro = "Zona"
					SELECT MetaCams.codcambio, ;
						MetaCams.codred, MetaCams.coddsto, MetaCams.codzona, ;
						SUM(MetaCams.vlrtotal) AS pesos_conc ;
						FROM metacams ;
						GROUP BY MetaCams.codred, MetaCams.coddsto, MetaCams.codzona ;
						ORDER BY MetaCams.codred, MetaCams.coddsto, MetaCams.codzona ;
						INTO CURSOR PCamConZon

*						INTO CURSOR PVtaVenZon

					DO CASE
						CASE m.filtrovta = 1
							SELECT PCamConZon.codcambio, ;
								PCamConZon.codred, PCamConZon.coddsto, PCamConZon.codzona, ;
								PCamConZon.pesos_conc ;
								FROM pcamconzon ;
								WHERE PCamConZon.pesos_conc >= m.limuno ;
								ORDER BY PCamConZon.codred, PCamConZon.coddsto, PCamConZon.codzona ;
								INTO CURSOR QCamConZon

*								INTO CURSOR QVtaVenZon
						CASE m.filtrovta = 2
							SELECT PCamConZon.codcambio, ;
								PCamConZon.codred, PCamConZon.coddsto, PCamConZon.codzona, ;
								PCamConZon.pesos_conc ;
								FROM pcamconzon ;
								WHERE PCamConZon.pesos_conc <= m.limuno ;
								ORDER BY PCamConZon.codred, PCamConZon.coddsto, PCamConZon.codzona ;
								INTO CURSOR QCamConZon
						CASE m.filtrovta = 3
							SELECT PCamConZon.codcambio, ;
								PCamConZon.codred, PCamConZon.coddsto, PCamConZon.codzona, ;
								PCamConZon.pesos_conc ;
								FROM pcamconzon ;
								WHERE PCamConZon.pesos_conc BETWEEN m.limuno AND m.limdos ;
								ORDER BY PCamConZon.codred, PCamConZon.coddsto, PCamConZon.codzona ;
								INTO CURSOR QCamConZon
					ENDCASE

					SELECT QCamConZon.codcambio, MetaCams.desccambio, ;
						MetaCams.codred, MetaCams.coddsto, MetaCams.codzona, MetaCams.zona, ;
						MetaCams.cod_prov AS codprov, MetaCams.cod_linea AS codlin, ;
						MetaCams.cod_refe AS codarti, MetaCams.referencia, ;
						SUM(MetaCams.doccant) AS unidades, ;
						SUM(MetaCams.dockilos) AS kilos, ;
						SUM(MetaCams.vlrtotal) AS pesos_cam ;
						FROM qcamconzon INNER JOIN metacams ;
						ON QCamConZon.codred+QCamConZon.coddsto+QCamConZon.codzona == MetaCams.codred+MetaCams.coddsto+MetaCams.codzona ;
						GROUP BY 1, 3, 4, 5, 7, 8, 9 ;
						ORDER BY 1, 3, 4, 5, 7, 8, 9 ;
						INTO CURSOR CamConZonDe

					DO CASE
						CASE m.brtyqry = "Distribuidor"
							SELECT CamConZonDe.codcambio, ;
								SUM(CamConZonDe.unidades) AS totunid, ;
								SUM(CamConZonDe.kilos) AS totklgs, ;
								SUM(CamConZonDe.pesos_cam) AS totpesos ;
								FROM CamConZonDe ;
								GROUP BY CamConZonDe.codcambio ;
								ORDER BY CamConZonDe.codcambio ;
								INTO CURSOR TotDistri READWRITE

							INDEX ON codcambio TAG Codigo

							SELECT CamConZonDe.codcambio, CamConZonDe.desccambio, ;
								CamConZonDe.codred, CamConZonDe.coddsto, CamConZonDe.codzona, ;
								CamConZonDe.zona, ;
								SUM(CamConZonDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(CamConZonDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(CamConZonDe.pesos_cam) AS pesos_cam, ;
								00.000 AS vlr_part ;
								FROM CamConZonDe ;
								GROUP BY 1, 3, 4, 5 ;
								ORDER BY 1, 3, 4, 5 ;
								INTO CURSOR CamConcZon READWRITE

							SET RELATION TO CamConCZon.codcambio INTO TotDistri ADDITIVE

							REPLACE ALL CamConCZon.Uni_part WITH IIF(EMPTY(TotDistri.totunid),0.000,(CamConCZon.unidades/TotDistri.totunid)*100) ;
								CamConCZon.Kgs_part WITH IIF(EMPTY(TotDistri.totklgs),0.000,(CamConCZon.kilos/TotDistri.totklgs)*100) ;
								CamConCZon.Vlr_part WITH IIF(EMPTY(TotDistri.totpesos),0.000,(CamConCZon.pesos_cam/TotDistri.totpesos)*100)

							DO CASE
								CASE m.codunim = "KLG"
									SELECT CamConCZon.codcambio, CamConCZon.desccambio, ;
										CamConCZon.codred, CamConCZon.coddsto, CamConCZon.codzona, ;
										CamConCZon.zona, ;
										CamConCZon.kilos, ;
										CamConCZon.Kgs_part, ;
										CamConCZon.pesos_cam, ;
										CamConCZon.vlr_part ;
										FROM  CamConCZon ;
										ORDER BY 1, 3, 4, 5 ;
										INTO CURSOR QryCamsCo
								CASE m.codunim = "UNI"
									SELECT CamConCZon.codcambio, CamConCZon.desccambio, ;
										CamConCZon.codred, CamConCZon.coddsto, CamConCZon.codzona, ;
										CamConCZon.zona, ;
										CamConCZon.unidades, ;
										CamConCZon.Uni_part, ;
										CamConCZon.pesos_cam, ;
										CamConCZon.vlr_part ;
										FROM  CamConCZon ;
										ORDER BY 1, 3, 4, 5 ;
										INTO CURSOR QryCamsCo
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcczd"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF

						CASE m.brtyqry = "Proveedor"
							SELECT VtaVenZonDe.cod_vend, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
								SUM(VtaVenZonDe.unidades) AS totunid, ;
								SUM(VtaVenZonDe.kilos) AS totklgs, ;
								SUM(VtaVenZonDe.pesos_vta) AS totpesos ;
								FROM vtavenzonde ;
								GROUP BY VtaVenZonDe.cod_vend, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona ;
								ORDER BY VtaVenZonDe.cod_vend, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona ;
								INTO CURSOR TotVendZon READWRITE

							INDEX ON cod_vend+codred+coddsto+codzona TAG Codigo

							SELECT VtaVenZonDe.cod_vend, VtaVenZonDe.vendedor, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
								VtaVenZonDe.zona, ;
								VtaVenZonDe.codprov, ;
								SUM(VtaVenZonDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtaVenZonDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtaVenZonDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM vtavenzonde ;
								GROUP BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, VtaVenZonDe.codprov ;
								ORDER BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, VtaVenZonDe.codprov ;
								INTO CURSOR VtaVendZon READWRITE

							SET RELATION TO VtaVendZon.cod_vend+VtaVendZon.codred+VtaVendZon.coddsto+VtaVendZon.codzona INTO totvendzon ADDITIVE

							REPLACE ALL VtaVendZon.Uni_part WITH IIF(EMPTY(TotVendZon.totunid),0.000,(VtaVendZon.unidades/TotVendZon.totunid)*100) ;
								VtaVendZon.Kgs_part WITH IIF(EMPTY(TotVendZon.totklgs),0.000,(VtaVendZon.kilos/TotVendZon.totklgs)*100) ;
								VtaVendZon.Vlr_part WITH IIF(EMPTY(TotVendZon.totpesos),0.000,(VtaVendZon.pesos_vta/TotVendZon.totpesos)*100)

*!*								SELECT DISTINCT VtaVenZonDe.cod_vend, ;
*!*									VtaVenZonDe.codred+VtaVenZonDe.coddsto+VtaVenZonDe.codzona AS negocio ;
*!*									FROM vtavenzonde ;
*!*									ORDER BY VtaVenZonDe.cod_vend ;
*!*									INTO CURSOR PreTotNeg

*!*								SELECT PreTotNeg.cod_vend, ;
*!*									COUNT(PreTotNeg.negocio) AS tot_neg_vend ;
*!*									FROM pretotneg ;
*!*									GROUP BY PreTotNeg.cod_vend ;
*!*									ORDER BY PreTotNeg.cod_vend ;
*!*									INTO CURSOR TotNegoc READWRITE

*!*								INDEX ON cod_vend TAG Codigo

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
										VtaVendZon.zona, ;
										VtaVendZon.codprov, MaeProve.nocoprov, ;
										VtaVendZon.kilos, ;
										VtaVendZon.Kgs_part, ;
										VtaVendZon.pesos_vta, ;
										VtaVendZon.vlr_part ;
										FROM  vtavendzon INNER JOIN maeprove ;
										ON VtaVendZon.codprov = MaeProve.codprov ;
										ORDER BY 1, 3, 4, 5 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
										VtaVendZon.zona, ;
										VtaVendZon.codprov, MaeProve.nocoprov, ;
										VtaVendZon.unidades, ;
										VtaVendZon.Uni_part, ;
										VtaVendZon.pesos_vta, ;
										VtaVendZon.vlr_part ;
										FROM  vtavendzon INNER JOIN maeprove ;
										ON VtaVendZon.codprov = MaeProve.codprov ;
										ORDER BY 1, 3, 4, 5 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
*!*									SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE

								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvzp"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF

						CASE m.brtyqry = "Linea"
							SELECT VtaVenZonDe.cod_vend, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
								VtaVenZonDe.codprov, ;
								SUM(VtaVenZonDe.unidades) AS totunid, ;
								SUM(VtaVenZonDe.kilos) AS totklgs, ;
								SUM(VtaVenZonDe.pesos_vta) AS totpesos ;
								FROM vtavenzonde ;
								GROUP BY VtaVenZonDe.cod_vend, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, VtaVenZonDe.codprov ;
								ORDER BY VtaVenZonDe.cod_vend, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, VtaVenZonDe.codprov ;
								INTO CURSOR TotVendZon READWRITE

							INDEX ON cod_vend+codred+coddsto+codzona+codprov TAG Codigo

							SELECT VtaVenZonDe.cod_vend, VtaVenZonDe.vendedor, ;
								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
								VtaVenZonDe.zona, ;
								VtaVenZonDe.codprov, VtaVenZonDe.codlin, ;
								SUM(VtaVenZonDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtaVenZonDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtaVenZonDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM vtavenzonde ;
								GROUP BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
								VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
								ORDER BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
								VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
								INTO CURSOR VtaVendZon READWRITE

							SET RELATION TO VtaVendZon.cod_vend+VtaVendZon.codred+VtaVendZon.coddsto+VtaVendZon.codzona+VtaVendZon.codprov INTO TotVendZon ADDITIVE

							REPLACE ALL VtaVendZon.Uni_part WITH IIF(EMPTY(TotVendZon.totunid),0.000,(VtaVendZon.unidades/TotVendzon.totunid)*100) ;
								VtaVendZon.Kgs_part WITH IIF(EMPTY(TotVendZon.totklgs),0.000,(VtaVendZon.kilos/TotVendZon.totklgs)*100) ;
								VtaVendZon.Vlr_part WITH IIF(EMPTY(TotVendZon.totpesos),0.000,(VtaVendZon.pesos_vta/TotVendZon.totpesos)*100)

*!*								SELECT DISTINCT VtaVenNegDe.cod_vend, ;
*!*									VtaVenNegDe.codred+VtaVenNegDe.coddsto+VtaVenNegDe.codzona+VtaVenNegDe.codloca+VtaVenNegDe.ideclien AS negocio ;
*!*									FROM vtavennegde ;
*!*									ORDER BY VtaVenNegDe.cod_vend ;
*!*									INTO CURSOR PreTotNeg

*!*								SELECT PreTotNeg.cod_vend, ;
*!*									COUNT(PreTotNeg.negocio) AS tot_neg_vend ;
*!*									FROM pretotneg ;
*!*									GROUP BY PreTotNeg.cod_vend ;
*!*									ORDER BY PreTotNeg.cod_vend ;
*!*									INTO CURSOR TotNegoc READWRITE

*!*								INDEX ON cod_vend TAG Codigo

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
										VtaVendZon.zona, ;
										VtaVendZon.codprov, MaeProve.nocoprov, ;
										VtaVendZon.codlin, MaeLinea.desclin, ;
										VtaVendZon.kilos, ;
										VtaVendZon.Kgs_part, ;
										VtaVendZon.pesos_vta, ;
										VtaVendZon.vlr_part ;
										FROM  vtavendzon INNER JOIN maeprove ;
										ON VtaVendZon.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4, 5, 7, 9 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
										VtaVendZon.zona, ;
										VtaVendZon.codprov, MaeProve.nocoprov, ;
										VtaVendZon.codlin, MaeLinea.desclin, ;
										VtaVendZon.unidades, ;
										VtaVendZon.Uni_part, ;
										VtaVendZon.pesos_vta, ;
										VtaVendZon.vlr_part ;
										FROM  vtavendzon INNER JOIN maeprove ;
										ON VtaVendZon.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4, 5, 7, 9 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
*!*								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE

								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvzl"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF

						CASE m.brtyqry = "Referencia"
								SELECT VtaVenZonDe.cod_vend, ;
									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
									VtaVenZonDe.codprov, VtaVenZonDe.codlin, ;
									SUM(VtaVenZonDe.unidades) AS totunid, ;
									SUM(VtaVenZonDe.kilos) AS totklgs, ;
									SUM(VtaVenZonDe.pesos_vta) AS totpesos ;
									FROM vtavenzonde ;
									GROUP BY VtaVenZonDe.cod_vend, ;
									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
									VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
									ORDER BY VtaVenZonDe.cod_vend, ;
									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
									VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
									INTO CURSOR ToVeZoLi READWRITE

							INDEX ON cod_vend+codred+coddsto+codzona+codprov+codlin TAG Codigo

								SELECT VtaVenZonDe.cod_vend, VtaVenZonDe.vendedor, ;
									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
									VtaVenZonDe.zona, ;
									VtaVenZonDe.codprov, VtaVenZonDe.codlin, VtaVenZonDe.codarti, ;
									SUM(VtaVenZonDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(VtaVenZonDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(VtaVenZonDe.pesos_vta) AS pesos_vta, ;
									00.000 AS vlr_part ;
									FROM vtavenzonde ;
									GROUP BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
									VtaVenZonDe.codprov, VtaVenZonDe.codlin, VtaVenZonDe.codarti ;
									ORDER BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
									VtaVenZonDe.codprov, VtaVenZonDe.codlin, VtaVenZonDe.codarti ;
									INTO CURSOR VtaVendZon READWRITE

							SET RELATION TO VtaVendZon.cod_vend+VtaVendZon.codred+VtaVendZon.coddsto+VtaVendZon.codzona+VtaVendZon.codprov+VtaVendZon.codlin INTO ToVeZoLi ADDITIVE

							REPLACE ALL VtaVendZon.Uni_part WITH IIF(EMPTY(ToVeZoLi.totunid),0.000,(VtaVendZon.unidades/ToVeZoLi.totunid)*100) ;
								VtaVendZon.Kgs_part WITH IIF(EMPTY(ToVeZoLi.totklgs),0.000,(VtaVendZon.kilos/ToVeZoLi.totklgs)*100) ;
								VtaVendZon.Vlr_part WITH IIF(EMPTY(ToVeZoLi.totpesos),0.000,(VtaVendZon.pesos_vta/ToVeZoLi.totpesos)*100)

*!*								SELECT DISTINCT VtaVenNegDe.cod_vend, ;
*!*									VtaVenNegDe.codred+VtaVenNegDe.coddsto+VtaVenNegDe.codzona+VtaVenNegDe.codloca+VtaVenNegDe.ideclien AS negocio ;
*!*									FROM vtavennegde ;
*!*									ORDER BY VtaVenNegDe.cod_vend ;
*!*									INTO CURSOR PreTotNeg

*!*								SELECT PreTotNeg.cod_vend, ;
*!*									COUNT(PreTotNeg.negocio) AS tot_neg_vend ;
*!*									FROM pretotneg ;
*!*									GROUP BY PreTotNeg.cod_vend ;
*!*									ORDER BY PreTotNeg.cod_vend ;
*!*									INTO CURSOR TotNegoc READWRITE

*!*								INDEX ON cod_vend TAG Codigo
*!*								CALCULATE SUM(tot_neg_vend) TO m.TotNegoc

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
										VtaVendZon.zona, ;
										VtaVendZon.codprov, MaeProve.nocoprov, ;
										VtaVendZon.codlin, MaeLinea.desclin, ;
										VtaVendZon.codarti, MaeArtic.nocoarti, ;
										VtaVendZon.kilos, ;
										VtaVendZon.Kgs_part, ;
										VtaVendZon.pesos_vta, ;
										VtaVendZon.vlr_part ;
										FROM  vtavendzon INNER JOIN maeprove ;
										ON VtaVendZon.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										INNER JOIN maeartic ;
										ON VtaVendZon.codprov+VtaVendZon.codlin+VtaVendZon.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
										ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
										VtaVendZon.zona, ;
										VtaVendZon.codprov, MaeProve.nocoprov, ;
										VtaVendZon.codlin, MaeLinea.desclin, ;
										VtaVendZon.codarti, MaeArtic.nocoarti, ;
										VtaVendZon.unidades, ;
										VtaVendZon.Uni_part, ;
										VtaVendZon.pesos_vta, ;
										VtaVendZon.vlr_part ;
										FROM  vtavendzon INNER JOIN maeprove ;
										ON VtaVendZon.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										INNER JOIN maeartic ;
										ON VtaVendZon.codprov+VtaVendZon.codlin+VtaVendZon.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
										ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
*!*								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE

								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvzr"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF
					ENDCASE
*!******	aqui voy para las zonas


********************************Inicia x Vendedor
					CASE m.brtygro = "Vendedor"
						SELECT MetaCams.codcambio, ;
							SUM(MetaCams.vlrtotal) AS pesos_conc ;
							FROM metacams ;
							GROUP BY MetaCams.codcambio ;
							ORDER BY MetaCams.codcambio ;
							INTO CURSOR PCamConVen

*							INTO CURSOR PVtaZonVen

						DO CASE
							CASE m.filtrovta = 1
								SELECT PCamConVen.codcambio, ;
									PCamConVen.pesos_conc ;
									FROM pcamconven ;
									WHERE PCamConVen.pesos_conc >= m.limuno ;
									ORDER BY PCamConVen.codcambio ;
									INTO CURSOR QCamConVen

*									INTO CURSOR QVtaZonVen
							CASE m.filtrovta = 2
								SELECT PCamConVen.codcambio, ;
									PCamConVen.pesos_conc ;
									FROM pcamconven ;
									WHERE PCamConVen.pesos_conc <= m.limuno ;
									ORDER BY PCamConVen.codcambio ;
									INTO CURSOR QCamConVen
							CASE m.filtrovta = 3
								SELECT PCamConVen.codcambio, ;
									PCamConVen.pesos_conc ;
									FROM pcamconven ;
									WHERE PCamConVen.pesos_conc BETWEEN m.limuno AND m.limdos ;
									ORDER BY PCamConVen.codcambio ;
									INTO CURSOR QCamConVen
						ENDCASE

						SELECT QCamConVen.codcambio, MetaCams.desccambio, ;
							MetaCams.cod_vend, MetaCams.vendedor, ;
							MetaCams.cod_prov AS codprov, MetaCams.cod_linea AS codlin, ;
							MetaCams.cod_refe AS codarti, MetaCams.referencia, ;
							SUM(MetaCams.doccant) AS unidades, ;
							SUM(MetaCams.dockilos) AS kilos, ;
							SUM(MetaCams.vlrtotal) AS pesos_cam ;
							FROM qcamconven INNER JOIN MetaCams ;
							ON QCamConVen.codcambio == MetaCams.codcambio ;
							GROUP BY 1, 3, 5, 6, 7 ;
							ORDER BY 1, 3, 5, 6, 7 ;
							INTO CURSOR CamConVenDe

						DO CASE
							CASE m.brtyqry = "Distribuidor"
								SELECT CamConVenDe.codcambio, ;
									SUM(CamConVenDe.unidades) AS totunid, ;
									SUM(CamConVenDe.kilos) AS totklgs, ;
									SUM(CamConVenDe.pesos_cam) AS totpesos ;
									FROM camconvende ;
									GROUP BY CamConVenDe.codcambio ;
									ORDER BY CamConVenDe.codcambio ;
									INTO CURSOR TotDistri READWRITE

								INDEX ON codcambio TAG Codigo

								SELECT CamConVenDe.codcambio, CamConVenDe.desccambio, ;
									CamConVenDe.cod_vend, CamConVenDe.vendedor, ;
									SUM(CamConVenDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(CamConVenDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(CamConVenDe.pesos_cam) AS pesos_cam, ;
									00.000 AS vlr_part ;
									FROM camconvende ;
									GROUP BY 1, 3 ;
									ORDER BY 1, 3 ;
									INTO CURSOR CamConcVen READWRITE

								SET RELATION TO CamConcVen.codcambio INTO TotDistri ADDITIVE

								REPLACE ALL CamConcVen.Uni_part WITH IIF(EMPTY(TotDistri.totunid),0.000,(CamConcVen.unidades/TotDistri.totunid)*100) ;
									CamConcVen.Kgs_part WITH IIF(EMPTY(TotDistri.totklgs),0.000,(CamConcVen.kilos/TotDistri.totklgs)*100) ;
									CamConcVen.Vlr_part WITH IIF(EMPTY(TotDistri.totpesos),0.000,(CamConcVen.pesos_cam/TotDistri.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT CamConcVen.codcambio, CamConcVen.desccambio, ;
											CamConcVen.cod_vend, CamConcVen.vendedor, ;
											CamConcVen.kilos, ;
											CamConcVen.Kgs_part, ;
											CamConcVen.pesos_cam, ;
											CamConcVen.vlr_part ;
											FROM  camconcven ;
											ORDER BY 1, 3 ;
											INTO CURSOR QryCamsCo
									CASE m.codunim = "UNI"
										SELECT CamConcVen.codcambio, CamConcVen.desccambio, ;
											CamConcVen.cod_vend, CamConcVen.vendedor, ;
											CamConcVen.unidades, ;
											CamConcVen.Uni_part, ;
											CamConcVen.pesos_cam, ;
											CamConcVen.vlr_part ;
											FROM  camconcven ;
											ORDER BY 1, 3 ;
											INTO CURSOR QryCamsCo
								ENDCASE
								SET TALK OFF

								m.reg_sel = _TALLY

								IF m.reg_sel > 0
									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrccvd"
								ELSE
									= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
								ENDIF

							CASE m.brtyqry = "Proveedor"
								SELECT CamConVenDe.codcambio, ;
									CamConVenDe.cod_vend, ;
									SUM(CamConVenDe.unidades) AS totunid, ;
									SUM(CamConVenDe.kilos) AS totklgs, ;
									SUM(CamConVenDe.pesos_cam) AS totpesos ;
									FROM camconvende ;
									GROUP BY CamConVenDe.codcambio, CamConVenDe.cod_vend ;
									ORDER BY CamConVenDe.codcambio, CamConVenDe.cod_vend ;
									INTO CURSOR TotCamVen READWRITE

								INDEX ON codcambio+cod_vend TAG Codigo

								SELECT CamConVenDe.CodCambio, CamConVenDe.DescCambio, ;
									CamConVenDe.cod_vend, CamConVenDe.vendedor, ;
									CamConVenDe.codprov, ;
									SUM(CamConVenDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(CamConVenDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(CamConVenDe.pesos_cam) AS pesos_cam, ;
									00.000 AS vlr_part ;
									FROM camconvende ;
									GROUP BY CamConVenDe.codcambio, CamConVenDe.cod_vend, CamConVenDe.codprov ;
									ORDER BY CamConVenDe.codcambio, CamConVenDe.cod_vend, CamConVenDe.codprov ;
									INTO CURSOR CamVenPro READWRITE

								SET RELATION TO CamVenPro.codcambio+CamVenPro.cod_vend INTO totcamven ADDITIVE

								REPLACE ALL CamVenPro.Uni_part WITH IIF(EMPTY(TotCamVen.totunid),0.000,(CamVenPro.unidades/TotCamVen.totunid)*100) ;
									CamVenPro.Kgs_part WITH IIF(EMPTY(TotCamVen.totklgs),0.000,(CamVenPro.kilos/TotCamVen.totklgs)*100) ;
									CamVenPro.Vlr_part WITH IIF(EMPTY(TotCamVen.totpesos),0.000,(CamVenPro.pesos_vta/TotCamVen.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT CamVenPro.codcambio, CamVenPro.DescCambio, ;
											CamVenPro.cod_vend, CamVenPro.vendedor, ;
											CamVenPro.codprov, MaeProve.nocoprov, ;
											CamVenPro.kilos, ;
											CamVenPro.Kgs_part, ;
											CamVenPro.pesos_vta, ;
											CamVenPro.vlr_part ;
											FROM  camvenpro INNER JOIN maeprove ;
											ON CamVenPro.codprov = MaeProve.codprov ;
											ORDER BY 1, 3, 5 ;
											INTO CURSOR QryCambios
									CASE m.codunim = "UNI"
										SELECT CamVenPro.codcambio, CamVenPro.DescCambio, ;
											CamVenPro.cod_vend, CamVenPro.vendedor, ;
											CamVenPro.codprov, MaeProve.nocoprov, ;
											CamVenPro.unidades, ;
											CamVenPro.Uni_part, ;
											CamVenPro.pesos_vta, ;
											CamVenPro.vlr_part ;
											FROM  camvenpro INNER JOIN maeprove ;
											ON CamVenPro.codprov = MaeProve.codprov ;
											ORDER BY 1, 3, 5 ;
											INTO CURSOR QryCambios
								ENDCASE
								SET TALK OFF

								m.reg_sel = _TALLY

								IF m.reg_sel > 0
									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrczvp"
								ELSE
									= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
								ENDIF

							CASE m.brtyqry = "Linea"
								SELECT VtaZonVenDe.cod_zona, ;
									VtaZonVenDe.cod_vend, ;
									VtaZonVenDe.codprov, ;
									SUM(VtaZonVenDe.unidades) AS totunid, ;
									SUM(VtaZonVenDe.kilos) AS totklgs, ;
									SUM(VtaZonVenDe.pesos_vta) AS totpesos ;
									FROM vtazonvende ;
									GROUP BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, VtaZonVenDe.codprov ;
									ORDER BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, VtaZonVenDe.codprov ;
									INTO CURSOR TotZonaVen READWRITE

								INDEX ON cod_zona+cod_vend+codprov TAG Codigo

								SELECT VtaZonVenDe.cod_zona, VtaZonVenDe.Zona, ;
									VtaZonVenDe.cod_vend, VtaZonVenDe.vendedor, ;
									VtaZonVenDe.codprov, VtaZonVenDe.codlin, ;
									SUM(VtaZonVenDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(VtaZonVenDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(VtaZonVenDe.pesos_vta) AS pesos_vta, ;
									00.000 AS vlr_part ;
									FROM vtazonvende ;
									GROUP BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
									VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
									ORDER BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
									VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
									INTO CURSOR VtaZonaVen READWRITE

								SET RELATION TO VtaZonaVen.cod_zona+VtaZonaVen.cod_vend+VtaZonaVen.codprov INTO TotZonaVen ADDITIVE

								REPLACE ALL VtaZonaVen.Uni_part WITH IIF(EMPTY(TotZonaVen.totunid),0.000,(VtaZonaVen.unidades/TotZonaVen.totunid)*100) ;
									VtaZonaVen.Kgs_part WITH IIF(EMPTY(TotZonaVen.totklgs),0.000,(VtaZonaVen.kilos/TotZonaVen.totklgs)*100) ;
									VtaZonaVen.Vlr_part WITH IIF(EMPTY(TotZonaVen.totpesos),0.000,(VtaZonaVen.pesos_vta/TotZonaVen.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
											VtaZonaVen.codprov, MaeProve.nocoprov, ;
											VtaZonaVen.codlin, MaeLinea.desclin, ;
											VtaZonaVen.kilos, ;
											VtaZonaVen.Kgs_part, ;
											VtaZonaVen.pesos_vta, ;
											VtaZonaVen.vlr_part ;
											FROM  vtazonaven INNER JOIN maeprove ;
											ON VtaZonaVen.codprov = MaeProve.codprov ;
											INNER JOIN maelinea ;
											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											ORDER BY 1, 3, 4, 5, 7, 9 ;
											INTO CURSOR QryVentas
									CASE m.codunim = "UNI"
										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
											VtaZonaVen.codprov, MaeProve.nocoprov, ;
											VtaZonaVen.codlin, MaeLinea.desclin, ;
											VtaZonaVen.unidades, ;
											VtaZonaVen.Uni_part, ;
											VtaZonaVen.pesos_vta, ;
											VtaZonaVen.vlr_part ;
											FROM  vtazonaven INNER JOIN maeprove ;
											ON VtaZonaVen.codprov = MaeProve.codprov ;
											INNER JOIN maelinea ;
											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											ORDER BY 1, 3, 4, 5, 7, 9 ;
											INTO CURSOR QryVentas
								ENDCASE
								SET TALK OFF

								m.reg_sel = _TALLY

								IF m.reg_sel > 0
									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrczvl"
								ELSE
									= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
								ENDIF

							CASE m.brtyqry = "Referencia"
									SELECT VtaZonVenDe.cod_zona, ;
										VtaZonVenDe.cod_vend, ;
										VtaZonVenDe.codprov, VtaZonVenDe.codlin, ;
										SUM(VtaZonVenDe.unidades) AS totunid, ;
										SUM(VtaZonVenDe.kilos) AS totklgs, ;
										SUM(VtaZonVenDe.pesos_vta) AS totpesos ;
										FROM vtazonvende ;
										GROUP BY VtaZonVenDe.cod_zona, ;
										VtaZonVenDe.cod_vend, VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
										ORDER BY VtaZonVenDe.cod_zona, ;
										VtaZonVenDe.cod_vend, VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
										INTO CURSOR ToZoVeLi READWRITE

								INDEX ON cod_zona+cod_vend+codprov+codlin TAG Codigo

									SELECT VtaZonVenDe.cod_zona, VtaZonVenDe.Zona, ;
										VtaZonVenDe.cod_vend, VtaZonVenDe.vendedor, ;
										VtaZonVenDe.codprov, VtaZonVenDe.codlin, VtaZonVenDe.codarti, ;
										SUM(VtaZonVenDe.unidades) AS unidades, ;
										00.000 AS Uni_part, ;
										SUM(VtaZonVenDe.kilos) AS kilos, ;
										00.000 AS Kgs_part, ;
										SUM(VtaZonVenDe.pesos_vta) AS pesos_vta, ;
										00.000 AS vlr_part ;
										FROM vtazonvende ;
										GROUP BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
										VtaZonVenDe.codprov, VtaZonVenDe.codlin, VtaZonVenDe.codarti ;
										ORDER BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
										VtaZonVenDe.codprov, VtaZonVenDe.codlin, VtaZonVenDe.codarti ;
										INTO CURSOR VtaZonaVen READWRITE

								SET RELATION TO VtaZonaVen.cod_zona+VtaZonaVen.cod_vend+VtaZonaVen.codprov+VtaZonaVen.codlin INTO ToZoVeLi ADDITIVE

								REPLACE ALL VtaZonaVen.Uni_part WITH IIF(EMPTY(ToZoVeLi.totunid),0.000,(VtaZonaVen.unidades/ToZoVeLi.totunid)*100) ;
									VtaZonaVen.Kgs_part WITH IIF(EMPTY(ToZoVeLi.totklgs),0.000,(VtaZonaVen.kilos/ToZoVeLi.totklgs)*100) ;
									VtaZonaVen.Vlr_part WITH IIF(EMPTY(ToZoVeLi.totpesos),0.000,(VtaZonaVen.pesos_vta/ToZoVeLi.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
											VtaZonaVen.codprov, MaeProve.nocoprov, ;
											VtaZonaVen.codlin, MaeLinea.desclin, ;
											VtaZonaVen.codarti, MaeArtic.nocoarti, ;
											VtaZonaVen.kilos, ;
											VtaZonaVen.Kgs_part, ;
											VtaZonaVen.pesos_vta, ;
											VtaZonaVen.vlr_part ;
											FROM  vtazonaven INNER JOIN maeprove ;
											ON VtaZonaVen.codprov = MaeProve.codprov ;
											INNER JOIN maelinea ;
											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											INNER JOIN maeartic ;
											ON VtaZonaVen.codprov+VtaZonaVen.codlin+VtaZonaVen.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
											ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
											INTO CURSOR QryVentas
									CASE m.codunim = "UNI"
										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
											VtaZonaVen.codprov, MaeProve.nocoprov, ;
											VtaZonaVen.codlin, MaeLinea.desclin, ;
											VtaZonaVen.codarti, MaeArtic.nocoarti, ;
											VtaZonaVen.unidades, ;
											VtaZonaVen.Uni_part, ;
											VtaZonaVen.pesos_vta, ;
											VtaZonaVen.vlr_part ;
											FROM  vtazonaven INNER JOIN maeprove ;
											ON VtaZonaVen.codprov = MaeProve.codprov ;
											INNER JOIN maelinea ;
											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
											INNER JOIN maeartic ;
											ON VtaZonaVen.codprov+VtaZonaVen.codlin+VtaZonaVen.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
											ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
											INTO CURSOR QryVentas
								ENDCASE
								SET TALK OFF

								m.reg_sel = _TALLY

								IF m.reg_sel > 0

									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrczvr"
								ELSE
									= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
								ENDIF
						ENDCASE



********************************
				CASE m.brtygro = "Negocio"
					SELECT MetaCams.cod_vend, ;
						MetaCams.negocio_id, ;
						SUM(MetaCams.vlrtotal) AS pesos_vend ;
						FROM metacams ;
						GROUP BY MetaCams.negocio_id ;
						ORDER BY MetaCams.negocio_id ;
						INTO CURSOR PVtaVenNeg

					DO CASE
						CASE m.filtrovta = 1
							SELECT PVtaVenNeg.cod_vend, SPACE(50) AS vendedor, ;
								PVtaVenNeg.negocio_id, ;
								PVtaVenNeg.pesos_vend ;
								FROM pvtavenneg ;
								WHERE PVtaVenNeg.pesos_vend >= m.limuno ;
								ORDER BY PVtaVenNeg.negocio_id ;
								INTO CURSOR QVtaVenNeg READWRITE
						CASE m.filtrovta = 2
							SELECT PVtaVenNeg.cod_vend, SPACE(50) AS vendedor, ;
								PVtaVenNeg.negocio_id, ;
								PVtaVenNeg.pesos_vend ;
								FROM pvtavenneg ;
								WHERE PVtaVenNeg.pesos_vend <= m.limuno ;
								ORDER BY PVtaVenNeg.negocio_id ;
								INTO CURSOR QVtaVenNeg READWRITE
						CASE m.filtrovta = 3
							SELECT PVtaVenNeg.cod_vend, SPACE(50) AS vendedor, ;
								PVtaVenNeg.negocio_id, ;
								PVtaVenNeg.pesos_vend ;
								FROM pvtavenneg ;
								WHERE PVtaVenNeg.pesos_vend BETWEEN m.limuno AND m.limdos ;
								ORDER BY PVtaVenNeg.negocio_id ;
								INTO CURSOR QVtaVenNeg READWRITE
					ENDCASE

					SELECT QVtaVenNeg.cod_vend, QVtaVenNeg.vendedor, ;
						MetaCams.codred, MetaCams.coddsto, MetaCams.codzona, MetaCams.codloca, ;
						MetaCams.ideclien, ;
						MetaCams.cliente, MetaCams.negocio, ;
						MetaCams.cod_prov AS codprov, MetaCams.cod_linea AS codlin, ;
						MetaCams.cod_refe AS codarti, MetaCams.referencia, ;
						SUM(MetaCams.doccant) AS unidades, ;
						SUM(MetaCams.dockilos) AS kilos, ;
						SUM(MetaCams.vlrtotal) AS pesos_vta ;
						FROM qvtavenneg INNER JOIN metacams ;
						ON QVtaVenNeg.negocio_id == MetaCams.negocio_id ;
						GROUP BY 1, 3, 4, 5, 6, 7, 10, 11, 12 ;
						ORDER BY 1, 3, 4, 5, 6, 7, 10, 11, 12 ;
						INTO CURSOR VtaVenNegDe

					DO CASE
						CASE m.brtyqry = "Distribuidor"
							SELECT VtaVenNegDe.cod_vend, ;
								SUM(VtaVenNegDe.unidades) AS totunid, ;
								SUM(VtaVenNegDe.kilos) AS totklgs, ;
								SUM(VtaVenNegDe.pesos_vta) AS totpesos ;
								FROM vtavennegde ;
								GROUP BY VtaVenNegDe.cod_vend ;
								ORDER BY VtaVenNegDe.cod_vend ;
								INTO CURSOR TotDistri READWRITE

							INDEX ON cod_vend TAG Codigo

							SELECT VtaVenNegDe.cod_vend, VtaVenNegDe.vendedor, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, VtaVenNegDe.ideclien, ;
								VtaVenNegDe.cliente, VtaVenNegDe.negocio, ;
								SUM(VtaVenNegDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtaVenNegDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtaVenNegDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM VtaVenNegDe ;
								GROUP BY 1, 3, 4, 5, 6, 7 ;
								ORDER BY 1, 3, 4, 5, 6, 7 ;
								INTO CURSOR VtaVendNeg READWRITE

							SET RELATION TO VtaVendNeg.cod_vend INTO TotDistri ADDITIVE

							REPLACE ALL VtaVendNeg.Uni_part WITH IIF(EMPTY(TotDistri.totunid),0.000,(VtaVendNeg.unidades/TotDistri.totunid)*100) ;
								VtaVendNeg.Kgs_part WITH IIF(EMPTY(TotDistri.totklgs),0.000,(VtaVendNeg.kilos/TotDistri.totklgs)*100) ;
								VtaVendNeg.Vlr_part WITH IIF(EMPTY(TotDistri.totpesos),0.000,(VtaVendNeg.pesos_vta/TotDistri.totpesos)*100)

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.kilos, ;
										VtaVendNeg.Kgs_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg ;
										ORDER BY 1, 3, 4, 5, 6, 7 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.unidades, ;
										VtaVendNeg.Uni_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg ;
										ORDER BY 1, 3, 4, 5, 6, 7 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvcd"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF
						CASE m.brtyqry = "Proveedor"
							SELECT VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, ;
								SUM(VtaVenNegDe.unidades) AS totunid, ;
								SUM(VtaVenNegDe.kilos) AS totklgs, ;
								SUM(VtaVenNegDe.pesos_vta) AS totpesos ;
								FROM vtavennegde ;
								GROUP BY VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien ;
								ORDER BY VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien ;
								INTO CURSOR TotVendNeg READWRITE

							INDEX ON cod_vend+codred+coddsto+codzona+codloca+ideclien TAG Codigo

							SELECT VtaVenNegDe.cod_vend, VtaVenNegDe.vendedor, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, VtaVenNegDe.ideclien, ;
								VtaVenNegDe.cliente, VtaVenNegDe.negocio, ;
								VtaVenNegDe.codprov, ;
								SUM(VtaVenNegDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtaVenNegDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtaVenNegDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM vtavennegde ;
								GROUP BY VtaVenNegDe.cod_vend, VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, VtaVenNegDe.codprov ;
								ORDER BY VtaVenNegDe.cod_vend, VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, VtaVenNegDe.codprov ;
								INTO CURSOR VtaVendNeg READWRITE

							SET RELATION TO VtaVendNeg.cod_vend+VtaVendNeg.codred+VtaVendNeg.coddsto+VtaVendNeg.codzona+VtaVendNeg.codloca+VtaVendNeg.ideclien INTO totvendneg ADDITIVE

							REPLACE ALL VtaVendNeg.Uni_part WITH IIF(EMPTY(TotVendNeg.totunid),0.000,(VtaVendNeg.unidades/TotVendNeg.totunid)*100) ;
								VtaVendNeg.Kgs_part WITH IIF(EMPTY(TotVendNeg.totklgs),0.000,(VtaVendNeg.kilos/TotVendNeg.totklgs)*100) ;
								VtaVendNeg.Vlr_part WITH IIF(EMPTY(TotVendNeg.totpesos),0.000,(VtaVendNeg.pesos_vta/TotVendNeg.totpesos)*100)

							SELECT DISTINCT VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred+VtaVenNegDe.coddsto+VtaVenNegDe.codzona+VtaVenNegDe.codloca+VtaVenNegDe.ideclien AS negocio ;
								FROM vtavennegde ;
								ORDER BY VtaVenNegDe.cod_vend ;
								INTO CURSOR PreTotNeg

							SELECT PreTotNeg.cod_vend, ;
								COUNT(PreTotNeg.negocio) AS tot_neg_vend ;
								FROM pretotneg ;
								GROUP BY PreTotNeg.cod_vend ;
								ORDER BY PreTotNeg.cod_vend ;
								INTO CURSOR TotNegoc READWRITE

							INDEX ON cod_vend TAG Codigo

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.codprov, MaeProve.nocoprov, ;
										VtaVendNeg.kilos, ;
										VtaVendNeg.Kgs_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg INNER JOIN maeprove ;
										ON VtaVendNeg.codprov = MaeProve.codprov ;
										ORDER BY 1, 3, 4, 5, 6, 7 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.codprov, MaeProve.nocoprov, ;
										VtaVendNeg.unidades, ;
										VtaVendNeg.Uni_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg INNER JOIN maeprove ;
										ON VtaVendNeg.codprov = MaeProve.codprov ;
										ORDER BY 1, 3, 4, 5, 6, 7 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvcp"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF

						CASE m.brtyqry = "Linea"
							SELECT VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, ;
								VtaVenNegDe.codprov, ;
								SUM(VtaVenNegDe.unidades) AS totunid, ;
								SUM(VtaVenNegDe.kilos) AS totklgs, ;
								SUM(VtaVenNegDe.pesos_vta) AS totpesos ;
								FROM vtavennegde ;
								GROUP BY VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, VtaVenNegDe.codprov ;
								ORDER BY VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, VtaVenNegDe.codprov ;
								INTO CURSOR TotVendNeg READWRITE

							INDEX ON cod_vend+codred+coddsto+codzona+codloca+ideclien+codprov TAG Codigo

							SELECT VtaVenNegDe.cod_vend, VtaVenNegDe.vendedor, ;
								VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, ;
								VtaVenNegDe.cliente, VtaVenNegDe.negocio, ;
								VtaVenNegDe.codprov, VtaVenNegDe.codlin, ;
								SUM(VtaVenNegDe.unidades) AS unidades, ;
								00.000 AS Uni_part, ;
								SUM(VtaVenNegDe.kilos) AS kilos, ;
								00.000 AS Kgs_part, ;
								SUM(VtaVenNegDe.pesos_vta) AS pesos_vta, ;
								00.000 AS vlr_part ;
								FROM vtavennegde ;
								GROUP BY VtaVenNegDe.cod_vend, VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, VtaVenNegDe.codprov, VtaVenNegDe.codlin ;
								ORDER BY VtaVenNegDe.cod_vend, VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
								VtaVenNegDe.ideclien, VtaVenNegDe.codprov, VtaVenNegDe.codlin ;
								INTO CURSOR VtaVendNeg READWRITE

							SET RELATION TO VtaVendNeg.cod_vend+VtaVendNeg.codred+VtaVendNeg.coddsto+VtaVendNeg.codzona+VtaVendNeg.codloca+VtaVendNeg.ideclien+VtaVendNeg.codprov INTO TotVendNeg ADDITIVE

							REPLACE ALL VtaVendNeg.Uni_part WITH IIF(EMPTY(TotVendNeg.totunid),0.000,(VtaVendNeg.unidades/TotVendNeg.totunid)*100) ;
								VtaVendNeg.Kgs_part WITH IIF(EMPTY(TotVendNeg.totklgs),0.000,(VtaVendNeg.kilos/TotVendNeg.totklgs)*100) ;
								VtaVendNeg.Vlr_part WITH IIF(EMPTY(TotVendNeg.totpesos),0.000,(VtaVendNeg.pesos_vta/TotVendNeg.totpesos)*100)

							SELECT DISTINCT VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred+VtaVenNegDe.coddsto+VtaVenNegDe.codzona+VtaVenNegDe.codloca+VtaVenNegDe.ideclien AS negocio ;
								FROM vtavennegde ;
								ORDER BY VtaVenNegDe.cod_vend ;
								INTO CURSOR PreTotNeg

							SELECT PreTotNeg.cod_vend, ;
								COUNT(PreTotNeg.negocio) AS tot_neg_vend ;
								FROM pretotneg ;
								GROUP BY PreTotNeg.cod_vend ;
								ORDER BY PreTotNeg.cod_vend ;
								INTO CURSOR TotNegoc READWRITE

							INDEX ON cod_vend TAG Codigo

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.codprov, MaeProve.nocoprov, ;
										VtaVendNeg.codlin, MaeLinea.desclin, ;
										VtaVendNeg.kilos, ;
										VtaVendNeg.Kgs_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg INNER JOIN maeprove ;
										ON VtaVendNeg.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendNeg.codprov+VtaVendNeg.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4, 5, 6, 7, 10, 12 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.codprov, MaeProve.nocoprov, ;
										VtaVendNeg.codlin, MaeLinea.desclin, ;
										VtaVendNeg.unidades, ;
										VtaVendNeg.Uni_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg INNER JOIN maeprove ;
										ON VtaVendNeg.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendNeg.codprov+VtaVendNeg.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										ORDER BY 1, 3, 4, 5, 6, 7, 10, 12 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvcl"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF

						CASE m.brtyqry = "Referencia"
								SELECT VtaVenNegDe.cod_vend, ;
									VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
									VtaVenNegDe.ideclien, ;
									VtaVenNegDe.codprov, VtaVenNegDe.codlin, ;
									SUM(VtaVenNegDe.unidades) AS totunid, ;
									SUM(VtaVenNegDe.kilos) AS totklgs, ;
									SUM(VtaVenNegDe.pesos_vta) AS totpesos ;
									FROM vtavennegde ;
									GROUP BY VtaVenNegDe.cod_vend, ;
									VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
									VtaVenNegDe.ideclien, VtaVenNegDe.codprov, VtaVenNegDe.codlin ;
									ORDER BY VtaVenNegDe.cod_vend, ;
									VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
									VtaVenNegDe.ideclien, VtaVenNegDe.codprov, VtaVenNegDe.codlin ;
									INTO CURSOR ToVeNeLi READWRITE

							INDEX ON cod_vend+codred+coddsto+codzona+codloca+ideclien+codprov+codlin TAG Codigo

								SELECT VtaVenNegDe.cod_vend, VtaVenNegDe.vendedor, ;
									VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
									VtaVenNegDe.ideclien, ;
									VtaVenNegDe.cliente, VtaVenNegDe.negocio, ;
									VtaVenNegDe.codprov, VtaVenNegDe.codlin, VtaVenNegDe.codarti, ;
									SUM(VtaVenNegDe.unidades) AS unidades, ;
									00.000 AS Uni_part, ;
									SUM(VtaVenNegDe.kilos) AS kilos, ;
									00.000 AS Kgs_part, ;
									SUM(VtaVenNegDe.pesos_vta) AS pesos_vta, ;
									00.000 AS vlr_part ;
									FROM vtavennegde ;
									GROUP BY VtaVenNegDe.cod_vend, VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
									VtaVenNegDe.ideclien, VtaVenNegDe.codprov, VtaVenNegDe.codlin, VtaVenNegDe.codarti ;
									ORDER BY VtaVenNegDe.cod_vend, VtaVenNegDe.codred, VtaVenNegDe.coddsto, VtaVenNegDe.codzona, VtaVenNegDe.codloca, ;
									VtaVenNegDe.ideclien, VtaVenNegDe.codprov, VtaVenNegDe.codlin, VtaVenNegDe.codarti ;
									INTO CURSOR VtaVendNeg READWRITE

							SET RELATION TO VtaVendNeg.cod_vend+VtaVendNeg.codred+VtaVendNeg.coddsto+VtaVendNeg.codzona+VtaVendNeg.codloca+VtaVendNeg.ideclien+VtaVendNeg.codprov+VtaVendNeg.codlin INTO ToVeNeLi ADDITIVE

							REPLACE ALL VtaVendNeg.Uni_part WITH IIF(EMPTY(ToVeNeLi.totunid),0.000,(VtaVendNeg.unidades/ToVeNeLi.totunid)*100) ;
								VtaVendNeg.Kgs_part WITH IIF(EMPTY(ToVeNeLi.totklgs),0.000,(VtaVendNeg.kilos/ToVeNeLi.totklgs)*100) ;
								VtaVendNeg.Vlr_part WITH IIF(EMPTY(ToVeNeLi.totpesos),0.000,(VtaVendNeg.pesos_vta/ToVeNeLi.totpesos)*100)

							SELECT DISTINCT VtaVenNegDe.cod_vend, ;
								VtaVenNegDe.codred+VtaVenNegDe.coddsto+VtaVenNegDe.codzona+VtaVenNegDe.codloca+VtaVenNegDe.ideclien AS negocio ;
								FROM vtavennegde ;
								ORDER BY VtaVenNegDe.cod_vend ;
								INTO CURSOR PreTotNeg

							SELECT PreTotNeg.cod_vend, ;
								COUNT(PreTotNeg.negocio) AS tot_neg_vend ;
								FROM pretotneg ;
								GROUP BY PreTotNeg.cod_vend ;
								ORDER BY PreTotNeg.cod_vend ;
								INTO CURSOR TotNegoc READWRITE

							INDEX ON cod_vend TAG Codigo
							SET TALK OFF
							CALCULATE SUM(tot_neg_vend) TO m.TotNegoc
							SET TALK OFF

							DO CASE
								CASE m.codunim = "KLG"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.codprov, MaeProve.nocoprov, ;
										VtaVendNeg.codlin, MaeLinea.desclin, ;
										VtaVendNeg.codarti, MaeArtic.nocoarti, ;
										VtaVendNeg.kilos, ;
										VtaVendNeg.Kgs_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg INNER JOIN maeprove ;
										ON VtaVendNeg.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendNeg.codprov+VtaVendNeg.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										INNER JOIN maeartic ;
										ON VtaVendNeg.codprov+VtaVendNeg.codlin+VtaVendNeg.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
										ORDER BY 1, 3, 4, 5, 6, 7, 10, 12, 14 ;
										INTO CURSOR QryVentas
								CASE m.codunim = "UNI"
									SELECT VtaVendNeg.cod_vend, VtaVendNeg.vendedor, ;
										VtaVendNeg.codred, VtaVendNeg.coddsto, VtaVendNeg.codzona, VtaVendNeg.codloca, VtaVendNeg.ideclien, ;
										VtaVendNeg.cliente, VtaVendNeg.negocio, ;
										VtaVendNeg.codprov, MaeProve.nocoprov, ;
										VtaVendNeg.codlin, MaeLinea.desclin, ;
										VtaVendNeg.codarti, MaeArtic.nocoarti, ;
										VtaVendNeg.unidades, ;
										VtaVendNeg.Uni_part, ;
										VtaVendNeg.pesos_vta, ;
										VtaVendNeg.vlr_part ;
										FROM  vtavendneg INNER JOIN maeprove ;
										ON VtaVendNeg.codprov = MaeProve.codprov ;
										INNER JOIN maelinea ;
										ON VtaVendNeg.codprov+VtaVendNeg.codlin = MaeLinea.codprov+MaeLinea.codlin ;
										INNER JOIN maeartic ;
										ON VtaVendNeg.codprov+VtaVendNeg.codlin+VtaVendNeg.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
										ORDER BY 1, 3, 4, 5, 6, 7, 10, 12, 14 ;
										INTO CURSOR QryVentas
							ENDCASE
							SET TALK OFF

							m.reg_sel = _TALLY

							IF m.reg_sel > 0
								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE
								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvcr"
							ELSE
								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
							ENDIF
					ENDCASE
*!*	>>>>>>>> aqui vooooyyyyyyyyyyyyyyyyyyyyyyyyyy
			ENDCASE
			ELSE
				= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
			ENDIF
		ELSE
			= MESSAGEBOX('Fechas NO válidas.',btn_ac+icn_inf,sysnom)
		ENDIF
		


		CLOSE TABLES ALL
				
		SELECT 0
		USE MaeProve.dbf ORDER TAG Codigo

		SELECT 0
		USE MaeLinea.dbf ORDER TAG Codigo

		SELECT 0
		USE MaeArtic.dbf ORDER TAG Codigo

		SELECT 0
		USE MaeUnidm.dbf ORDER TAG Codigo

		SELECT 0
		USE MaeTiNeg ORDER TAG Codigo

		SELECT MaeTiNeg.desctineg, MaeTiNeg.codtineg;
			FROM maetineg;
			INTO CURSOR QryTiNeg

		SELECT 0
		USE MaeCiuda ORDER TAG Codigo

		SELECT DISTINCT MaeCiuda.nomdepto, MaeCiuda.coddepto;
			FROM maeciuda;
			INTO CURSOR Qrydepto
				
		
		
		
		
		
		
	CASE m.bcgc = "Cancelar"
		m.fechin    = m.inimesact
		m.fechfi    = m.finmesact
		m.codunim   = 2
		m.brtyqry   = "Distribuidor"
		m.bcgc      = "Cancelar"

		m.codprov   = SPACE(2)
		m.nocoprov  = SPACE(15)
		m.codlin    = SPACE(4)
		m.desclin   = SPACE(30)
*!*		m.codarti   = SPACE(4)
		m.nolaarti  = SPACE(30)
ENDCASE
SHOW GETS
_CUROBJ = 1
