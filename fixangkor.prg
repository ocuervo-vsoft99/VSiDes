*************************
* CONDICIONES INICIALES *
*************************

m.uniini = SYS(5)
m.dirini = m.uniini + SYS(2003)
m.dirbmp = m.dirini + "\bmps"
m.dirdbf = m.dirini + "\dbfs"
m.dirrep = m.dirini + "\reports"

SET CENTURY ON
SET CONFIRM ON
SET DEBUG OFF
SET DEFAULT TO &dirini
SET DATE YMD
SET DELETE ON
SET ESCAPE OFF
SET EXCLUSIVE OFF
*SET LIBRARY TO SYS(2004)+"FOXTOOLS" ADDITIVE
SET PROCEDURE TO DegProce
SET PATH TO &dirbmp, &dirdbf, &dirrep
SET REPROCESS TO -1
SET SAFETY OFF

***********************************************
*   Especifica propiedades y métodos para la  * 
*   ventana principal de Visual SiDeg.        *
***********************************************
_Screen.Caption = "VisualSOFT.com S.A.S."
_Screen.WindowState = 2


*!*	DIMENSION aFiles[1]

*!*	sysfile = SYS(2014, SYS(16,0))

*!*	AGETFILEVERSION(aFiles,sysfile)
*!*	sysver = aFiles(4)
*!*	sysfec = FDATE(sysfile, 1)

*!*	RELEASE aFile

_Screen.AddObject("oImg", "image")
_Screen.oImg.Picture = "&dirbmp.\ColVSiDeg.jpg"
_Screen.oImg.Top = _Screen.Height/2 - _Screen.oImg.Height/2
_Screen.oImg.Left = _Screen.Width/2 - _Screen.oImg.Width/2
_Screen.oImg.Visible = .T.

*************************************************************
*		RESTAURA EL PATH PARA LA BASE DE DATOS				*
*************************************************************
m.pathfile = dirdbf+'\VSiDeg.Dbc'
IF !FILE(m.pathfile)
	RESTORE FROM VSiDeg ADDITIVE
	m.dirdbf = m.rutadbc
	IF !EMPTY(ALLTRIM(m.dirdbf))
		m.pathfile = dirdbf+'\VSiDeg.Dbc'
		IF !FILE(m.pathfile)
			DO FORM Deg_Data.scx  NAME VSiDeg_Data LINKED
		ELSE
			*
		ENDIF
	ELSE
		QUIT
	ENDIF
ELSE
ENDIF

IF !EMPTY(m.dirdbf)
	SET PATH TO &dirdbf, &dirbmp 
ELSE
	QUIT
ENDIF

**********************************************************
* 		ABRE LA BASE DE DATOS 		                     *
**********************************************************

OPEN DATABASE VSiDeg  && Abre la base de datos VisualSiDeg.

SELECT 0
USE MaeDistr

SELECT 0
USE MaeRedes ORDER TAG codigo

SELECT 0
USE MaeDstos ORDER TAG Codigo

SELECT 0
USE MaeZonas ORDER TAG Codigo

SELECT 0
USE MaeLocal ORDER TAG Codigo

SELECT 0
USE MaeVende ORDER TAG Codigo

USE MaeClien IN 0 ORDER TAG IdeClien

USE MaeNegoc IN 0 ORDER TAG LocaClien

SELECT 0
USE MaeFacDe ORDER TAG Factura

SELECT 0
USE MaeFacEn ORDER TAG Factura

m.FacPrefi = "FEMV    "
FOR m.facnron = 4038 TO 4185

*	IF MaeDistr.factelec
m.facnro = PADL(ALLTRIM(STR(m.facnron,8,0)),8,"0")

		USE IN 0 MaeCiuda ORDER TAG Codigo
		USE IN 0 MaeLinea ORDER TAG Codigo
		USE IN 0 MaePedMg ORDER TAG Pedido
		USE IN 0 MaeImIVA ORDER TAG Porciva
		USE IN 0 MaeRutas ORDER TAG LocClien

		SELECT MaeNegoc
		SET RELATION TO MaeNegoc.coddepto+MaeNegoc.codciuda INTO MaeCiuda ADDITIVE

		m.FldExIVACiu = .F.
		m.FldExIVALin = .F.
		m.faccon = 0

		SET TALK  ON

		m.wherefacen = "MaeFacEn.facprefi+MaeFacEn.facnro == m.FacPrefi+m.FacNro"	&& AND MaeFacEn.prn_ok == .F."

		DO QryImpFac
		SET TALK  OFF

		IF m.faccon > 0
			m.fileAngkor = m.dirdbf + "\MaeAngkor.dbf"

			IF FILE("&fileAngkor.")
				SELECT 0
				USE &fileAngkor. ALIAS Angkor

				SELECT QryFactu
				GO TOP
				SCAN
					DO FillQryAngkor WITH ALLTRIM(STR(VAL(QryFactu.facnro),10,0)), ;
						STR(YEAR(QryFactu.FacFecha),4,0)+"-"+PADL(ALLTRIM(STR(MONTH(QryFactu.FacFecha),2,0)),2,"0")+"-"+PADL(ALLTRIM(STR(DAY(QryFactu.FacFecha),2,0)),2,"0")+" "+TTOC(QryFactu.FacFecha,2), ;
						STR(VAL(QryFactu.IdeClien),11,0), ;
						MaeCiuda.NomDepto, ;
						MaeCiuda.Ciudad, ;
						MaeNegoc.DirNego, ;
						MaeClien.Nom1Clien, ;
						MaeClien.Nom2Clien, ;
						MaeClien.Apel1Clien, ;
						MaeClien.RaSoClien, ;
						STR(QryFactu.VlrTotIVA,20,2), ;
						STR(QryFactu.PorcIVA,20,2), ;
						STR(QryFactu.ValorFact - QryFactu.VlrTotIVA - QryFactu.VlrTotIpo + QryFactu.VlrTotDes,20,2), ;
						STR(0.00,20,2), ;
						STR(0.00,20,2), ;
						STR(QryFactu.ValorFact - QryFactu.VlrTotIVA - QryFactu.VlrTotIpo + QryFactu.VlrTotDes,20,2), ;
						STR(QryFactu.VlrTotIpo,20,2), ;
						STR(0.00,20,2), ;
						STR(QryFactu.ValorFact - QryFactu.VlrTotIVA - QryFactu.VlrTotIpo + QryFactu.VlrTotDes,20,2), ;
						STR(QryFactu.VlrTotIVA + 0.00 + QryFactu.VlrTotIpo,20,2), ;
						STR(QryFactu.ValorFact,20,2), ;
						IIF(QryFactu.FacPlazo = 0,"1","2"), ;
						"1", ;
						STR(QryFactu.FacPlazo,4,0), ;
						IIF(MaeClien.TipIdClien = "C","N","J"), ;
						SUBSTR(QryFactu.Consecu,2,3), ;
						QryFactu.NoLaArti, ;
						STR(QryFactu.PrecVent,15,2), ;
						STR(QryFactu.FacCant,10,2), ;
						STR(QryFactu.ValorDesc,15,2), ;
						STR(QryFactu.DescVent,10,2), ;
						STR(QryFactu.ValorIVA,15,2), ;
						STR(QryFactu.PorcIVA,10,2), ;
						STR(QryFactu.ValorBase-QryFactu.ValorDesc,15,2), ;
						IIF(EMPTY(ALLTRIM(MaeNegoc.e_mail)),MaeDistr.e_mail, MaeNegoc.e_mail), ;
						m.FacPrefi, ;
						MaePedMg.PedMsg, ;
						MaeCiuda.CodDepto+MaeCiuda.CodCiuda, ;
						MaeCiuda.CodDepto, ;
						Nit_DV(QryFactu.IdeClien), ;
						SPACE(20), ;
						MaeNegoc.TelNego, ;
						QryFactu.CodLin+QryFactu.CodArti, ;
						QryFactu.PedNro, ;
						QryFactu.Cod_Vend+"-"+ALLTRIM(MaeVende.Nom1_Vend)+IIF(EMPTY(ALLTRIM(MaeVende.Nom2_Vend)),""," "+ALLTRIM(MaeVende.Nom2_Vend))+IIF(EMPTY(ALLTRIM(MaeVende.Apel1_Vend)),""," "+ALLTRIM(MaeVende.Apel1_Vend))+IIF(EMPTY(ALLTRIM(MaeVende.Apel2_Vend)),""," "+ALLTRIM(MaeVende.Apel2_Vend)), ;
						MaeNegoc.NomNego, ;
						ALLTRIM(MaeNegoc.BarrioNego), ;
						SPACE(20), ;
						SPACE(5), ;
						SPACE(20), ;
						"01", ;						&&'01' para facturas,'41' para notas credito,'42' para notas debito
						SPACE(64), ;
						SPACE(2), ;
						SPACE(20), ;					&& Numero de documento de referencia
						VAL(QryFactu.facnro), ;
						QryFactu.ItemsFact
				ENDSCAN

				m.prn_ok = .T.
				SELECT MaeFacEn
				SET ORDER TO TAG factura
				IF SEEK(m.FacPrefi+m.FacNro,"MaeFacEn")
					SELECT MaeFacEn
*					GATHER MEMVAR FIELD prn_ok
					SELECT QryFactu
				ENDIF

				USE IN Angkor
			ELSE
			ENDIF
		ENDIF
		USE IN MaeRutas
		USE IN MaeImIVA
		USE IN MaePedMg
		USE IN MaeLinea
		USE IN MaeCiuda
*	ENDIF
ENDFOR

CLOSE DATABASES ALL

QUIT