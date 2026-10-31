*IF !EOF() AND !(m.anulada) AND MaeDesDe.estado != "M"
IF !EOF() AND !(m.anulada) AND MaeDesDe.cambio != "M"
	SELECT MaeDistr
	IF RLOCK()
		m.transanro = MaeDistr.ulttransa + 1
		m.ulttransa = m.transanro

		SELECT MaeNCrEn
		IF FLOCK()

			GO BOTTOM
			m.ncrnro = PADL(ALLTRIM(STR(VAL(MaeNCrEn.ncrnro)+1,7,0)),7,'0')
			m.ValorNoCr = 0.00
			m.numconsec = 1
*			m.ncrconsec = 1

			m.new_ajus = MaeDistr.ultajust + 1
			m.ajunro = PADL(ALLTRIM(STR(m.new_ajus,7,0)),7,"0")
			m.AjuTotBru = 0.00
			m.AjuTotDes = 0.00
			m.AjuTotIva = 0.00
			m.ValorAjus = 0.00
			m.ajuconsec = 1

			m.transanro = MaeDistr.ulttransa + 1
			m.ulttransa = m.transanro
			m.ultajust = m.new_ajus

			SELECT TmpNcrDe
			GO TOP
			SCAN
				IF !EMPTY(TmpNcrDe.facnro)
					SCATTER FIELDS facnro, codprov, codlin, codarti, ncrcant, ajucant, precvent, ;
						ultcosto, procosto, descvent, porciva, valortot MEMVAR

					IF !EMPTY(m.codprov) AND !EMPTY(m.codlin) AND !EMPTY(m.codarti) AND !EMPTY(m.ncrcant)
						m.codbode = "5"+m.codprov
						***
						*** Actualiza el KARDEX, y retorna la cantidad almacenada en él.
						***
						m.ncrcant = fupdatekdx(m.anocont, m.mescont, m.codbode, m.codprov, m.codlin, m.codarti, m.ncrcant, m.ultcosto, "SUMA",.F.)
					ENDIF

					IF !EMPTY(m.codprov) AND !EMPTY(m.codlin) AND !EMPTY(m.codarti) AND !EMPTY(m.ajucant)
						m.codbode = "0"+m.codprov
						***
						*** Actualiza el KARDEX, y retorna la cantidad almacenada en él.
						***
						m.ajucant = fupdatekdx(m.anocont, m.mescont, m.codbode, m.codprov, m.codlin, m.codarti, m.ajucant, m.ultcosto, "SUMA",.F.)
					ENDIF

					SELECT MaeCamDe
					SET ORDER TO TAG PePrLiRe
					SELECT TmpNcrDe
					
					IF SEEK(TmpNcrDe.pednro+m.codprov+m.codlin+m.codarti,"MaeCamDe")
						SELECT MaeCamDe
						REPLACE coddevbad WITH TmpNcrDe.coddevbad ;
							cantefe WITH m.ncrcant
SUSPEND
						DO CASE
							CASE MaeCamDe.tipocambio == "MM"
	*Omar 2010Ago18*								SELECT MaeDistr
	*Omar 2010Ago18*								IF RLOCK()
	*Omar 2010Ago18*									m.new_ajus = MaeDistr.ultajust + 1
	*Omar 2010Ago18*									m.transanro = MaeDistr.ulttransa + 1
	*Omar 2010Ago18*									m.ulttransa = m.transanro
	*Omar 2010Ago18*									m.ultajust = m.new_ajus
	*Omar 2010Ago18*									m.ajunro = PADL(ALLTRIM(STR(m.new_ajus,7,0)),7,"0")


								IF m.ncrcant > 0.00
									m.codbode = "5"+m.codprov
									m.ajucant  = m.ncrcant
									m.vlrbruto = m.ajucant * m.ultcosto
									m.vlrdscto = 0.00
									m.vlriva   = 0.00
									m.valortot = m.vlrbruto - m.vlrdscto + m.vlriva

									SELECT MaeAjuDe
									m.consecu = PADL(ALLTRIM(STR(m.numconsec,3,0)),3,"0")
									m.clave = m.ajunro + m.codbode + m.codprov + m.codlin + m.codarti
									IF SEEK(m.clave)
										GATHER MEMVAR
									ELSE
										INSERT INTO MaeAjuDe FROM MEMVAR
									ENDIF

									m.AjuTotBru = m.AjuTotBru + m.vlrbruto
									m.AjuTotIva = m.AjuTotIva + m.vlriva
									m.numconsec = m.numconsec + 1
								ENDIF
								IF TmpNcrDe.ajucant > 0.00
									m.codbode = "0"+m.codprov
									m.ajucant  = TmpNcrDe.ajucant
									m.vlrbruto = m.ajucant * m.ultcosto
									m.vlrdscto = 0.00
									m.vlriva   = 0.00
									m.vlripcmo = TmpNcrDe.ajucant * TmpNcrDe.vimpcsmo
									m.valortot = m.vlrbruto - m.vlrdscto + m.vlriva

									SELECT MaeAjuDe
									m.consecu = PADL(ALLTRIM(STR(m.ajuconsec,3,0)),3,"0")
									m.clave = m.ajunro + m.codbode + m.codprov + m.codlin + m.codarti
									IF SEEK(m.clave) AND MaeAjuDe.codbode == m.codbode
										GATHER MEMVAR
									ELSE
										INSERT INTO MaeAjuDe FROM MEMVAR
									ENDIF

									m.AjuTotBru = m.AjuTotBru + m.vlrbruto
									m.AjuTotIva = m.AjuTotIva + m.vlriva
									m.ajuconsec = m.ajuconsec + 1
								ENDIF
	*Omar 2010Ago18*							ENDIF




							
							CASE MaeCamDe.tipocambio == "RC"
								SELECT MaeNCrEn
								GO BOTTOM
								m.ncrnro = PADL(ALLTRIM(STR(VAL(MaeNCrEn.ncrnro)+1,7,0)),7,'0')

	*Omar 2010Ago18*							m.ValorNoCr = 0.00
	*Omar 2010Ago18*							m.numconsec = 1

	*Omar 2010Ago18*							SELECT MaeDistr
	*Omar 2010Ago18*							IF RLOCK()
	*Omar 2010Ago18*								m.transanro = MaeDistr.ulttransa + 1
	*Omar 2010Ago18*								m.ulttransa = m.transanro


								SELECT MaeNcrDe
								morderact = SET('ORDER')
								SET ORDER TO TAG NoCrRefe
								m.consecu = PADL(ALLTRIM(STR(m.numconsec,3,0)),3,"0")
								m.clave = m.ncrnro + m.codprov + m.codlin + m.codarti

								IF !SEEK(m.clave)
									INSERT INTO MaeNcrDe FROM MEMVAR
								ELSE
								ENDIF
								m.numconsec = m.numconsec + 1
								SET ORDER TO &morderact

								maliasact = ALIAS()

								IF creditdist
									SELECT MaeCuxCo
									SEEK m.facnro
									REPLACE vlrtotabo WITH vlrtotabo+m.valortot
								ENDIF

								m.ValorNoCr = m.ValorNoCr + m.ValorTot

	*Omar 2010Ago18*							ENDIF
						ENDCASE
					ENDIF

					SELECT TmpNcrDe
				ENDIF
			ENDSCAN
	*		m.ValorFact = m.VlrTotBru - m.VlrTotDes + m.VlrTotIva
	*OOOOOOOOOOOOOOOOJJJJJJJJJJJJJJOOOOOOOOOOOOOOOO Omar 2010Ago18*
			m.ValorAjus = m.AjuTotBru + m.AjuTotIva
			IF m.ValorAjus > 0
				m.ajufecha = m.facfecha
				m.codajus = "09"
				m.last_user = ALLTRIM(m.myuser)
				m.last_date = DATETIME()
				IF SEEK(m.ajunro,"MaeAjuEn")
					SELECT MaeAjuEn
					GATHER MEMVAR
				ELSE
					INSERT INTO MaeAjuEn FROM MEMVAR
				ENDIF

				SELECT MaeDistr
				GATHER MEMVAR FIELD ultajust, ulttransa
			ELSE
				DELETE FROM MaeAjuEn WHERE MaeAjuEn.ajunro = m.ajunro
				DELETE FROM MaeAjuDe WHERE MaeAjuDe.ajunro = m.ajunro
			ENDIF
		ELSE
		ENDIF

		USE IN MaeAjuEn
		USE IN MaeAjuDe

		SELECT 0
		USE MaeAjuDe ORDER TAG Detalle

		SELECT 0
		USE MaeAjuEn ORDER TAG Ajuste
*FIN OOOOOOOOOOOOOOOOJJJJJJJJJJJJJJOOOOOOOOOOOOOOOO Omar 2010Ago18*
*OOOOOOOOOOOOOOOOJJJJJJJJJJJJJJOOOOOOOOOOOOOOOO Omar 2010Ago18*
		IF m.ValorNoCr > 0
			m.ncrfecha  = m.facfecha
			m.last_user = ALLTRIM(m.myuser)
			m.last_date = DATETIME()
			IF SEEK(m.ncrnro,"MaeNcrEn")
				SELECT MaeNcrEn
				GATHER MEMVAR
			ELSE
				INSERT INTO MaeNcrEn FROM MEMVAR
			ENDIF

*!*				SELECT MaeCamDe
*!*				REPLACE ncrnro WITH m.ncrnro

			SELECT MaeDistr
			GATHER MEMVAR FIELD ulttransa
		ELSE
			DELETE FROM MaeNcrEn WHERE MaeNcrEn.ncrnro = m.ncrnro
			DELETE FROM MaeNcrDe WHERE MaeNcrDe.ncrnro = m.ncrnro
		ENDIF

		USE IN MaeCuxCo
		USE IN MaeNcrEn
		USE IN MaeNcrDe

		SELECT 0
		USE MaeNcrDe ORDER TAG Detalle

		SELECT 0
		USE MaeNcrEn ORDER TAG NotCre

		SELECT 0
		USE MaeCuxCo ORDER TAG factura
*FIN OOOOOOOOOOOOOOOOJJJJJJJJJJJJJJOOOOOOOOOOOOOOOO Omar 2010Ago18*
	ENDIF
	UNLOCK IN MaeDistr
	USE IN MaeDistr
	USE MaeDistr IN 0


*		WAIT CLEAR
*		m.nocract  = MaeNcrEn.ncrnro


*		SEEK m.nocract

*!*			SELECT TmpNcrEn
*!*			DO pscatter
*!*		ELSE 			&& Si el pago no es nuevo
*!*		ENDIF 		&& Si el pao es nuevo
***
	m.ctrledit = 'E'
*	SHOW GET m.bcnea,3 ENABLE
*!*		SHOW GET m.bcgc,1  DISABLE
*!*		SHOW GET m.bcprint ENABLE

	SHOW GETS



*	SELECT MaePreve
	SELECT MaeDesDe
	m.cambio    = "M"
	m.ncrnrocam = m.ncrnro
	GATHER MEMVAR FIELDS cambio, ncrnrocam
	= MESSAGEBOX('Cambio confirmado con éxito!!!',btn_ac+icn_inf,sysnom)



*!*		= MESSAGEBOX('Imposible acceder al registro. No es una factura.',btn_ac+icn_inf,sysnom)
*!*		DO FORM deg_anfa.scx NAME Vdeg_anfa LINKED

	SELECT MaeFacEn
	SEEK m.factact
	SCATTER MEMVAR FIELDS EXCEPT anocont, mescont
*	IF SEEK(DTOS(m.desfecha)+STR(m.orddesp,1,0)+m.cod_cond+m.remnro,"MaePreve")
*		m.facnro = MaePreve.facnro
	IF SEEK(m.despanro+m.facnro,"MaeDesDe")
*2014Sep		m.facnro = MaeDesDe.facnro
		= SEEK(m.remnro,"MaeRemEn")
*2014Sep		m.pednro   = MaeFacEn.pednro
		m.remfecha = MaeRemEn.remfecha
		m.valorremi = MaeRemEn.valorremi
		= SEEK(m.codred+m.coddsto+m.codzona+m.codloca+m.ideclien,"MaeNegoc")
		m.dirnego = ALLTRIM(MaeNegoc.dirnego)
		m.rasoclien = ALLTRIM(MaeClien.rasoclien)
		= SEEK(m.cod_vend,"Maevende")
		m.nom_vend = ALLTRIM(Maevende.nom1_vend) + " " + ALLTRIM(Maevende.nom2_vend) + " " + ALLTRIM(Maevende.apel1_vend) + " " + ALLTRIM(Maevende.apel2_vend)
		m.factact = MaeFacEn.facnro
		m.factest  = IIF(MaeFacEn.anulada,'Si','No')
		IF UPPER(m.factest)='SI'
			SHOW GET m.bcverest,1 PROMPT 'Anulada' DISABLE
		ELSE
*			IF MaePreve.estado == "M"
*!*				IF MaeDesDe.estado == "M"
			IF MaeDesDe.cambio == "M"
				SHOW GET m.bcverest,1 PROMPT 'Cambio' DISABLE
			ELSE
				SHOW GET m.bcverest,1 PROMPT 'Activa' ENABLE
			ENDIF
		ENDIF
		SHOW GET m.bcredes	ENABLE
		SHOW GET m.bccancel	ENABLE
		SHOW GETS
		THISFORMSET.FrmDegDevPa.PageFrame1.Page1.txtRemnro23.SetFocus
	ENDIF
ELSE
	= MESSAGEBOX('Imposible acceder al registro.',btn_ac+icn_inf,sysnom)
ENDIF