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
*Future*						CASE m.brtyqry = "Linea"
*Future*							SELECT VtasVendDe.cod_vend, VtasVendDe.codprov, ;
*Future*								SUM(VtasVendDe.unidades) AS totunid, ;
*Future*								SUM(VtasVendDe.kilos) AS totklgs, ;
*Future*								SUM(VtasVendDe.pesos_vta) AS totpesos ;
*Future*								FROM vtasvendde ;
*Future*								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov ;
*Future*								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov ;
*Future*								INTO CURSOR TotVenPro READWRITE

*Future*							INDEX ON cod_vend+codprov TAG Codigo

*Future*							SELECT VtasVendDe.cod_vend, VtasVendDe.vendedor, ;
*Future*								VtasVendDe.codprov, VtasVendDe.codlin, ;
*Future*								SUM(VtasVendDe.unidades) AS unidades, ;
*Future*								00.000 AS Uni_part, ;
*Future*								SUM(VtasVendDe.kilos) AS kilos, ;
*Future*								00.000 AS Kgs_part, ;
*Future*								SUM(VtasVendDe.pesos_vta) AS pesos_vta, ;
*Future*								00.000 AS vlr_part ;
*Future*								FROM vtasvendde ;
*Future*								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
*Future*								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
*Future*								INTO CURSOR VtasVende READWRITE

*Future*							SET RELATION TO VtasVende.cod_vend+VtasVende.codprov INTO totvenpro ADDITIVE

*Future*							REPLACE ALL VtasVende.Uni_part WITH IIF(EMPTY(TotVenPro.totunid),0.000,(VtasVende.unidades/TotVenPro.totunid)*100) ;
*Future*								VtasVende.Kgs_part WITH IIF(EMPTY(TotVenPro.totklgs),0.000,(VtasVende.kilos/TotVenPro.totklgs)*100) ;
*Future*								VtasVende.Vlr_part WITH IIF(EMPTY(TotVenPro.totpesos),0.000,(VtasVende.pesos_vta/TotVenPro.totpesos)*100)

*Future*							DO CASE
*Future*								CASE m.codunim = "KLG"
*Future*									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
*Future*										VtasVende.codprov, ;
*Future*										VtasVende.codlin, MaeLinea.desclin, ;
*Future*										VtasVende.kilos, ;
*Future*										VtasVende.Kgs_part, ;
*Future*										VtasVende.pesos_vta, ;
*Future*										VtasVende.vlr_part ;
*Future*										FROM  vtasvende INNER JOIN maelinea ;
*Future*										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										ORDER BY 1, 3, 4 ;
*Future*										INTO CURSOR QryVentas
*Future*								CASE m.codunim = "UNI"
*Future*									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
*Future*										VtasVende.codprov, ;
*Future*										VtasVende.codlin, MaeLinea.desclin, ;
*Future*										VtasVende.unidades, ;
*Future*										VtasVende.Uni_part, ;
*Future*										VtasVende.pesos_vta, ;
*Future*										VtasVende.vlr_part ;
*Future*										FROM  vtasvende INNER JOIN maelinea ;
*Future*										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										ORDER BY 1, 3, 4 ;
*Future*										INTO CURSOR QryVentas
*Future*							ENDCASE
*Future*							SET TALK OFF

*Future*							m.reg_sel = _TALLY

*Future*							IF m.reg_sel > 0
*Future*								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvel"
*Future*							ELSE
*Future*								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
*Future*							ENDIF
*Future*						CASE m.brtyqry = "Referencia"
*Future*							SELECT VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin, ;
*Future*								SUM(VtasVendDe.unidades) AS totunid, ;
*Future*								SUM(VtasVendDe.kilos) AS totklgs, ;
*Future*								SUM(VtasVendDe.pesos_vta) AS totpesos ;
*Future*								FROM vtasvendde ;
*Future*								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
*Future*								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin ;
*Future*								INTO CURSOR ToVePrLi READWRITE

*Future*							INDEX ON cod_vend+codprov+codlin TAG Codigo

*Future*							SELECT VtasVendDe.cod_vend, VtasVendDe.vendedor, ;
*Future*								VtasVendDe.codprov, VtasVendDe.codlin, ;
*Future*								VtasVendDe.codarti, VtasVendDe.referencia, ;
*Future*								SUM(VtasVendDe.unidades) AS unidades, ;
*Future*								00.000 AS Uni_part, ;
*Future*								SUM(VtasVendDe.kilos) AS kilos, ;
*Future*								00.000 AS Kgs_part, ;
*Future*								SUM(VtasVendDe.pesos_vta) AS pesos_vta, ;
*Future*								00.000 AS vlr_part ;
*Future*								FROM vtasvendde ;
*Future*								GROUP BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin, VtasVendDe.codarti ;
*Future*								ORDER BY VtasVendDe.cod_vend, VtasVendDe.codprov, VtasVendDe.codlin, VtasVendDe.codarti ;
*Future*								INTO CURSOR VtasVende READWRITE

*Future*							SET RELATION TO VtasVende.cod_vend+VtasVende.codprov+VtasVende.codlin INTO toveprli ADDITIVE

*Future*							REPLACE ALL VtasVende.Uni_part WITH IIF(EMPTY(ToVePrLi.totunid),0.000,(VtasVende.unidades/ToVePrLi.totunid)*100) ;
*Future*								VtasVende.Kgs_part WITH IIF(EMPTY(ToVePrLi.totklgs),0.000,(VtasVende.kilos/ToVePrLi.totklgs)*100) ;
*Future*								VtasVende.Vlr_part WITH IIF(EMPTY(ToVePrLi.totpesos),0.000,(VtasVende.pesos_vta/ToVePrLi.totpesos)*100)

*Future*							DO CASE
*Future*								CASE m.codunim = "KLG"
*Future*									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
*Future*										VtasVende.codprov, VtasVende.codlin, MaeLinea.desclin, ;
*Future*										VtasVende.codarti, VtasVende.referencia, ;
*Future*										VtasVende.kilos, ;
*Future*										VtasVende.Kgs_part, ;
*Future*										VtasVende.pesos_vta, ;
*Future*										VtasVende.vlr_part ;
*Future*										FROM  vtasvende INNER JOIN maelinea ;
*Future*										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										ORDER BY 1, 3, 4, 5 ;
*Future*										INTO CURSOR QryVentas
*Future*								CASE m.codunim = "UNI"
*Future*									SELECT VtasVende.cod_vend, VtasVende.vendedor, ;
*Future*										VtasVende.codprov, VtasVende.codlin, MaeLinea.desclin, ;
*Future*										VtasVende.codarti, VtasVende.referencia, ;
*Future*										VtasVende.unidades, ;
*Future*										VtasVende.Uni_part, ;
*Future*										VtasVende.pesos_vta, ;
*Future*										VtasVende.vlr_part ;
*Future*										FROM  vtasvende INNER JOIN maelinea ;
*Future*										ON VtasVende.codprov+VtasVende.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										ORDER BY 1, 3, 4, 5 ;
*Future*										INTO CURSOR QryVentas
*Future*							ENDCASE
*Future*							SET TALK OFF

*Future*							m.reg_sel = _TALLY

*Future*							IF m.reg_sel > 0
*Future*								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcver"
*Future*							ELSE
*Future*								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
*Future*							ENDIF
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

*Future*						CASE m.brtyqry = "Linea"
*Future*							SELECT VtaVenZonDe.cod_vend, ;
*Future*								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*								VtaVenZonDe.codprov, ;
*Future*								SUM(VtaVenZonDe.unidades) AS totunid, ;
*Future*								SUM(VtaVenZonDe.kilos) AS totklgs, ;
*Future*								SUM(VtaVenZonDe.pesos_vta) AS totpesos ;
*Future*								FROM vtavenzonde ;
*Future*								GROUP BY VtaVenZonDe.cod_vend, ;
*Future*								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, VtaVenZonDe.codprov ;
*Future*								ORDER BY VtaVenZonDe.cod_vend, ;
*Future*								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, VtaVenZonDe.codprov ;
*Future*								INTO CURSOR TotVendZon READWRITE

*Future*							INDEX ON cod_vend+codred+coddsto+codzona+codprov TAG Codigo

*Future*							SELECT VtaVenZonDe.cod_vend, VtaVenZonDe.vendedor, ;
*Future*								VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*								VtaVenZonDe.zona, ;
*Future*								VtaVenZonDe.codprov, VtaVenZonDe.codlin, ;
*Future*								SUM(VtaVenZonDe.unidades) AS unidades, ;
*Future*								00.000 AS Uni_part, ;
*Future*								SUM(VtaVenZonDe.kilos) AS kilos, ;
*Future*								00.000 AS Kgs_part, ;
*Future*								SUM(VtaVenZonDe.pesos_vta) AS pesos_vta, ;
*Future*								00.000 AS vlr_part ;
*Future*								FROM vtavenzonde ;
*Future*								GROUP BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*								VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
*Future*								ORDER BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*								VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
*Future*								INTO CURSOR VtaVendZon READWRITE

*Future*							SET RELATION TO VtaVendZon.cod_vend+VtaVendZon.codred+VtaVendZon.coddsto+VtaVendZon.codzona+VtaVendZon.codprov INTO TotVendZon ADDITIVE

*Future*							REPLACE ALL VtaVendZon.Uni_part WITH IIF(EMPTY(TotVendZon.totunid),0.000,(VtaVendZon.unidades/TotVendzon.totunid)*100) ;
*Future*								VtaVendZon.Kgs_part WITH IIF(EMPTY(TotVendZon.totklgs),0.000,(VtaVendZon.kilos/TotVendZon.totklgs)*100) ;
*Future*								VtaVendZon.Vlr_part WITH IIF(EMPTY(TotVendZon.totpesos),0.000,(VtaVendZon.pesos_vta/TotVendZon.totpesos)*100)

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

*Future*							DO CASE
*Future*								CASE m.codunim = "KLG"
*Future*									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
*Future*										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
*Future*										VtaVendZon.zona, ;
*Future*										VtaVendZon.codprov, MaeProve.nocoprov, ;
*Future*										VtaVendZon.codlin, MaeLinea.desclin, ;
*Future*										VtaVendZon.kilos, ;
*Future*										VtaVendZon.Kgs_part, ;
*Future*										VtaVendZon.pesos_vta, ;
*Future*										VtaVendZon.vlr_part ;
*Future*										FROM  vtavendzon INNER JOIN maeprove ;
*Future*										ON VtaVendZon.codprov = MaeProve.codprov ;
*Future*										INNER JOIN maelinea ;
*Future*										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										ORDER BY 1, 3, 4, 5, 7, 9 ;
*Future*										INTO CURSOR QryVentas
*Future*								CASE m.codunim = "UNI"
*Future*									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
*Future*										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
*Future*										VtaVendZon.zona, ;
*Future*										VtaVendZon.codprov, MaeProve.nocoprov, ;
*Future*										VtaVendZon.codlin, MaeLinea.desclin, ;
*Future*										VtaVendZon.unidades, ;
*Future*										VtaVendZon.Uni_part, ;
*Future*										VtaVendZon.pesos_vta, ;
*Future*										VtaVendZon.vlr_part ;
*Future*										FROM  vtavendzon INNER JOIN maeprove ;
*Future*										ON VtaVendZon.codprov = MaeProve.codprov ;
*Future*										INNER JOIN maelinea ;
*Future*										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										ORDER BY 1, 3, 4, 5, 7, 9 ;
*Future*										INTO CURSOR QryVentas
*Future*							ENDCASE
*Future*							SET TALK OFF

*Future*							m.reg_sel = _TALLY

*Future*							IF m.reg_sel > 0
*!*								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE

*Future*								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvzl"
*Future*							ELSE
*Future*								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
*Future*							ENDIF

*Future*						CASE m.brtyqry = "Referencia"
*Future*								SELECT VtaVenZonDe.cod_vend, ;
*Future*									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*									VtaVenZonDe.codprov, VtaVenZonDe.codlin, ;
*Future*									SUM(VtaVenZonDe.unidades) AS totunid, ;
*Future*									SUM(VtaVenZonDe.kilos) AS totklgs, ;
*Future*									SUM(VtaVenZonDe.pesos_vta) AS totpesos ;
*Future*									FROM vtavenzonde ;
*Future*									GROUP BY VtaVenZonDe.cod_vend, ;
*Future*									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*									VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
*Future*									ORDER BY VtaVenZonDe.cod_vend, ;
*Future*									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*									VtaVenZonDe.codprov, VtaVenZonDe.codlin ;
*Future*									INTO CURSOR ToVeZoLi READWRITE

*Future*							INDEX ON cod_vend+codred+coddsto+codzona+codprov+codlin TAG Codigo

*Future*								SELECT VtaVenZonDe.cod_vend, VtaVenZonDe.vendedor, ;
*Future*									VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*									VtaVenZonDe.zona, ;
*Future*									VtaVenZonDe.codprov, VtaVenZonDe.codlin, VtaVenZonDe.codarti, ;
*Future*									SUM(VtaVenZonDe.unidades) AS unidades, ;
*Future*									00.000 AS Uni_part, ;
*Future*									SUM(VtaVenZonDe.kilos) AS kilos, ;
*Future*									00.000 AS Kgs_part, ;
*Future*									SUM(VtaVenZonDe.pesos_vta) AS pesos_vta, ;
*Future*									00.000 AS vlr_part ;
*Future*									FROM vtavenzonde ;
*Future*									GROUP BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*									VtaVenZonDe.codprov, VtaVenZonDe.codlin, VtaVenZonDe.codarti ;
*Future*									ORDER BY VtaVenZonDe.cod_vend, VtaVenZonDe.codred, VtaVenZonDe.coddsto, VtaVenZonDe.codzona, ;
*Future*									VtaVenZonDe.codprov, VtaVenZonDe.codlin, VtaVenZonDe.codarti ;
*Future*									INTO CURSOR VtaVendZon READWRITE

*Future*							SET RELATION TO VtaVendZon.cod_vend+VtaVendZon.codred+VtaVendZon.coddsto+VtaVendZon.codzona+VtaVendZon.codprov+VtaVendZon.codlin INTO ToVeZoLi ADDITIVE

*Future*							REPLACE ALL VtaVendZon.Uni_part WITH IIF(EMPTY(ToVeZoLi.totunid),0.000,(VtaVendZon.unidades/ToVeZoLi.totunid)*100) ;
*Future*								VtaVendZon.Kgs_part WITH IIF(EMPTY(ToVeZoLi.totklgs),0.000,(VtaVendZon.kilos/ToVeZoLi.totklgs)*100) ;
*Future*								VtaVendZon.Vlr_part WITH IIF(EMPTY(ToVeZoLi.totpesos),0.000,(VtaVendZon.pesos_vta/ToVeZoLi.totpesos)*100)

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

*Future*							DO CASE
*Future*								CASE m.codunim = "KLG"
*Future*									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
*Future*										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
*Future*										VtaVendZon.zona, ;
*Future*										VtaVendZon.codprov, MaeProve.nocoprov, ;
*Future*										VtaVendZon.codlin, MaeLinea.desclin, ;
*Future*										VtaVendZon.codarti, MaeArtic.nocoarti, ;
*Future*										VtaVendZon.kilos, ;
*Future*										VtaVendZon.Kgs_part, ;
*Future*										VtaVendZon.pesos_vta, ;
*Future*										VtaVendZon.vlr_part ;
*Future*										FROM  vtavendzon INNER JOIN maeprove ;
*Future*										ON VtaVendZon.codprov = MaeProve.codprov ;
*Future*										INNER JOIN maelinea ;
*Future*										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										INNER JOIN maeartic ;
*Future*										ON VtaVendZon.codprov+VtaVendZon.codlin+VtaVendZon.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
*Future*										ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
*Future*										INTO CURSOR QryVentas
*Future*								CASE m.codunim = "UNI"
*Future*									SELECT VtaVendZon.cod_vend, VtaVendZon.vendedor, ;
*Future*										VtaVendZon.codred, VtaVendZon.coddsto, VtaVendZon.codzona, ;
*Future*										VtaVendZon.zona, ;
*Future*										VtaVendZon.codprov, MaeProve.nocoprov, ;
*Future*										VtaVendZon.codlin, MaeLinea.desclin, ;
*Future*										VtaVendZon.codarti, MaeArtic.nocoarti, ;
*Future*										VtaVendZon.unidades, ;
*Future*										VtaVendZon.Uni_part, ;
*Future*										VtaVendZon.pesos_vta, ;
*Future*										VtaVendZon.vlr_part ;
*Future*										FROM  vtavendzon INNER JOIN maeprove ;
*Future*										ON VtaVendZon.codprov = MaeProve.codprov ;
*Future*										INNER JOIN maelinea ;
*Future*										ON VtaVendZon.codprov+VtaVendZon.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*										INNER JOIN maeartic ;
*Future*										ON VtaVendZon.codprov+VtaVendZon.codlin+VtaVendZon.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
*Future*										ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
*Future*										INTO CURSOR QryVentas
*Future*							ENDCASE
*Future*							SET TALK OFF

*Future*							m.reg_sel = _TALLY

*Future*							IF m.reg_sel > 0
*!*								SET RELATION TO QryVentas.cod_vend INTO TotNegoc ADDITIVE

*Future*								DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrcvzr"
*Future*							ELSE
*Future*								= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
*Future*							ENDIF
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
									CamVenPro.Vlr_part WITH IIF(EMPTY(TotCamVen.totpesos),0.000,(CamVenPro.pesos_cam/TotCamVen.totpesos)*100)

								DO CASE
									CASE m.codunim = "KLG"
										SELECT CamVenPro.codcambio, CamVenPro.DescCambio, ;
											CamVenPro.cod_vend, CamVenPro.vendedor, ;
											CamVenPro.codprov, MaeProve.nocoprov, ;
											CamVenPro.kilos, ;
											CamVenPro.Kgs_part, ;
											CamVenPro.pesos_cam, ;
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
											CamVenPro.pesos_cam, ;
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

*Future*							CASE m.brtyqry = "Linea"
*Future*								SELECT VtaZonVenDe.cod_zona, ;
*Future*									VtaZonVenDe.cod_vend, ;
*Future*									VtaZonVenDe.codprov, ;
*Future*									SUM(VtaZonVenDe.unidades) AS totunid, ;
*Future*									SUM(VtaZonVenDe.kilos) AS totklgs, ;
*Future*									SUM(VtaZonVenDe.pesos_vta) AS totpesos ;
*Future*									FROM vtazonvende ;
*Future*									GROUP BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, VtaZonVenDe.codprov ;
*Future*									ORDER BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, VtaZonVenDe.codprov ;
*Future*									INTO CURSOR TotZonaVen READWRITE

*Future*								INDEX ON cod_zona+cod_vend+codprov TAG Codigo

*Future*								SELECT VtaZonVenDe.cod_zona, VtaZonVenDe.Zona, ;
*Future*									VtaZonVenDe.cod_vend, VtaZonVenDe.vendedor, ;
*Future*									VtaZonVenDe.codprov, VtaZonVenDe.codlin, ;
*Future*									SUM(VtaZonVenDe.unidades) AS unidades, ;
*Future*									00.000 AS Uni_part, ;
*Future*									SUM(VtaZonVenDe.kilos) AS kilos, ;
*Future*									00.000 AS Kgs_part, ;
*Future*									SUM(VtaZonVenDe.pesos_vta) AS pesos_vta, ;
*Future*									00.000 AS vlr_part ;
*Future*									FROM vtazonvende ;
*Future*									GROUP BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
*Future*									VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
*Future*									ORDER BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
*Future*									VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
*Future*									INTO CURSOR VtaZonaVen READWRITE

*Future*								SET RELATION TO VtaZonaVen.cod_zona+VtaZonaVen.cod_vend+VtaZonaVen.codprov INTO TotZonaVen ADDITIVE

*Future*								REPLACE ALL VtaZonaVen.Uni_part WITH IIF(EMPTY(TotZonaVen.totunid),0.000,(VtaZonaVen.unidades/TotZonaVen.totunid)*100) ;
*Future*									VtaZonaVen.Kgs_part WITH IIF(EMPTY(TotZonaVen.totklgs),0.000,(VtaZonaVen.kilos/TotZonaVen.totklgs)*100) ;
*Future*									VtaZonaVen.Vlr_part WITH IIF(EMPTY(TotZonaVen.totpesos),0.000,(VtaZonaVen.pesos_vta/TotZonaVen.totpesos)*100)

*Future*								DO CASE
*Future*									CASE m.codunim = "KLG"
*Future*										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
*Future*											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
*Future*											VtaZonaVen.codprov, MaeProve.nocoprov, ;
*Future*											VtaZonaVen.codlin, MaeLinea.desclin, ;
*Future*											VtaZonaVen.kilos, ;
*Future*											VtaZonaVen.Kgs_part, ;
*Future*											VtaZonaVen.pesos_vta, ;
*Future*											VtaZonaVen.vlr_part ;
*Future*											FROM  vtazonaven INNER JOIN maeprove ;
*Future*											ON VtaZonaVen.codprov = MaeProve.codprov ;
*Future*											INNER JOIN maelinea ;
*Future*											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*											ORDER BY 1, 3, 4, 5, 7, 9 ;
*Future*											INTO CURSOR QryVentas
*Future*									CASE m.codunim = "UNI"
*Future*										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
*Future*											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
*Future*											VtaZonaVen.codprov, MaeProve.nocoprov, ;
*Future*											VtaZonaVen.codlin, MaeLinea.desclin, ;
*Future*											VtaZonaVen.unidades, ;
*Future*											VtaZonaVen.Uni_part, ;
*Future*											VtaZonaVen.pesos_vta, ;
*Future*											VtaZonaVen.vlr_part ;
*Future*											FROM  vtazonaven INNER JOIN maeprove ;
*Future*											ON VtaZonaVen.codprov = MaeProve.codprov ;
*Future*											INNER JOIN maelinea ;
*Future*											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*											ORDER BY 1, 3, 4, 5, 7, 9 ;
*Future*											INTO CURSOR QryVentas
*Future*								ENDCASE
*Future*								SET TALK OFF

*Future*								m.reg_sel = _TALLY

*Future*								IF m.reg_sel > 0
*Future*									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrczvl"
*Future*								ELSE
*Future*									= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
*Future*								ENDIF

*Future*							CASE m.brtyqry = "Referencia"
*Future*									SELECT VtaZonVenDe.cod_zona, ;
*Future*										VtaZonVenDe.cod_vend, ;
*Future*										VtaZonVenDe.codprov, VtaZonVenDe.codlin, ;
*Future*										SUM(VtaZonVenDe.unidades) AS totunid, ;
*Future*										SUM(VtaZonVenDe.kilos) AS totklgs, ;
*Future*										SUM(VtaZonVenDe.pesos_vta) AS totpesos ;
*Future*										FROM vtazonvende ;
*Future*										GROUP BY VtaZonVenDe.cod_zona, ;
*Future*										VtaZonVenDe.cod_vend, VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
*Future*										ORDER BY VtaZonVenDe.cod_zona, ;
*Future*										VtaZonVenDe.cod_vend, VtaZonVenDe.codprov, VtaZonVenDe.codlin ;
*Future*										INTO CURSOR ToZoVeLi READWRITE

*Future*								INDEX ON cod_zona+cod_vend+codprov+codlin TAG Codigo

*Future*									SELECT VtaZonVenDe.cod_zona, VtaZonVenDe.Zona, ;
*Future*										VtaZonVenDe.cod_vend, VtaZonVenDe.vendedor, ;
*Future*										VtaZonVenDe.codprov, VtaZonVenDe.codlin, VtaZonVenDe.codarti, ;
*Future*										SUM(VtaZonVenDe.unidades) AS unidades, ;
*Future*										00.000 AS Uni_part, ;
*Future*										SUM(VtaZonVenDe.kilos) AS kilos, ;
*Future*										00.000 AS Kgs_part, ;
*Future*										SUM(VtaZonVenDe.pesos_vta) AS pesos_vta, ;
*Future*										00.000 AS vlr_part ;
*Future*										FROM vtazonvende ;
*Future*										GROUP BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
*Future*										VtaZonVenDe.codprov, VtaZonVenDe.codlin, VtaZonVenDe.codarti ;
*Future*										ORDER BY VtaZonVenDe.cod_zona, VtaZonVenDe.cod_vend, ;
*Future*										VtaZonVenDe.codprov, VtaZonVenDe.codlin, VtaZonVenDe.codarti ;
*Future*										INTO CURSOR VtaZonaVen READWRITE

*Future*								SET RELATION TO VtaZonaVen.cod_zona+VtaZonaVen.cod_vend+VtaZonaVen.codprov+VtaZonaVen.codlin INTO ToZoVeLi ADDITIVE

*Future*								REPLACE ALL VtaZonaVen.Uni_part WITH IIF(EMPTY(ToZoVeLi.totunid),0.000,(VtaZonaVen.unidades/ToZoVeLi.totunid)*100) ;
*Future*									VtaZonaVen.Kgs_part WITH IIF(EMPTY(ToZoVeLi.totklgs),0.000,(VtaZonaVen.kilos/ToZoVeLi.totklgs)*100) ;
*Future*									VtaZonaVen.Vlr_part WITH IIF(EMPTY(ToZoVeLi.totpesos),0.000,(VtaZonaVen.pesos_vta/ToZoVeLi.totpesos)*100)

*Future*								DO CASE
*Future*									CASE m.codunim = "KLG"
*Future*										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
*Future*											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
*Future*											VtaZonaVen.codprov, MaeProve.nocoprov, ;
*Future*											VtaZonaVen.codlin, MaeLinea.desclin, ;
*Future*											VtaZonaVen.codarti, MaeArtic.nocoarti, ;
*Future*											VtaZonaVen.kilos, ;
*Future*											VtaZonaVen.Kgs_part, ;
*Future*											VtaZonaVen.pesos_vta, ;
*Future*											VtaZonaVen.vlr_part ;
*Future*											FROM  vtazonaven INNER JOIN maeprove ;
*Future*											ON VtaZonaVen.codprov = MaeProve.codprov ;
*Future*											INNER JOIN maelinea ;
*Future*											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*											INNER JOIN maeartic ;
*Future*											ON VtaZonaVen.codprov+VtaZonaVen.codlin+VtaZonaVen.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
*Future*											ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
*Future*											INTO CURSOR QryVentas
*Future*									CASE m.codunim = "UNI"
*Future*										SELECT VtaZonaVen.cod_zona, VtaZonaVen.Zona, ;
*Future*											VtaZonaVen.cod_vend, VtaZonaVen.vendedor, ;
*Future*											VtaZonaVen.codprov, MaeProve.nocoprov, ;
*Future*											VtaZonaVen.codlin, MaeLinea.desclin, ;
*Future*											VtaZonaVen.codarti, MaeArtic.nocoarti, ;
*Future*											VtaZonaVen.unidades, ;
*Future*											VtaZonaVen.Uni_part, ;
*Future*											VtaZonaVen.pesos_vta, ;
*Future*											VtaZonaVen.vlr_part ;
*Future*											FROM  vtazonaven INNER JOIN maeprove ;
*Future*											ON VtaZonaVen.codprov = MaeProve.codprov ;
*Future*											INNER JOIN maelinea ;
*Future*											ON VtaZonaVen.codprov+VtaZonaVen.codlin = MaeLinea.codprov+MaeLinea.codlin ;
*Future*											INNER JOIN maeartic ;
*Future*											ON VtaZonaVen.codprov+VtaZonaVen.codlin+VtaZonaVen.codarti = MaeArtic.codprov+MaeArtic.codlin+MaeArtic.codarti ;
*Future*											ORDER BY 1, 3, 4, 5, 7, 9, 11 ;
*Future*											INTO CURSOR QryVentas
*Future*								ENDCASE
*Future*								SET TALK OFF

*Future*								m.reg_sel = _TALLY

*Future*								IF m.reg_sel > 0

*Future*									DO FORM Prn_Gen.scx NAME VPrn_Gen LINKED WITH "Degrczvr"
*Future*								ELSE
*Future*									= MESSAGEBOX('No se encontraron cambios con los anteriores parámetros.',btn_ac+icn_adv,sysnom)
*Future*								ENDIF
						ENDCASE



********************************
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
