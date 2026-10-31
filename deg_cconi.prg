PUBLIC mb_aceptar, mb_aceptarcancelar, mb_anularrepetirignorar, mb_sinocancelar, ;
	mb_sino, mb_repetircancelar, iconoalto, iconointerrogacion, iconoadmiracion, ;
	iconoinformacion, defboton2, defboton3, idaceptar, idcancelar, idanular, ;
	idrepetir, idignorar, idsi, idno, fileopen, m.myuser, ;
	sysnom, m.nom_dist, m.codregdist, m.codzondist, m.typedist, m.compreprn, m.factype, m.factypeprn, costo_desc, ;
	m.security, m.autovedist, m.obj_grid, m.grid_act


CLOSE DATABASES ALL

*************************
* CONDICIONES INICIALES *
*************************
*m.dirini = SYS(2004)
m.uniini = SYS(5)
m.dirini = m.uniini + SYS(2003)
m.dirbmp = m.dirini + "\bmps"
m.dirdbf = m.dirini + "\dbfs"
m.direxp = m.dirini + "\exports"
m.dirrep = m.dirini + "\reports"
m.dirwap = m.dirini + "\wap"

SET CENTURY ON
SET CONFIRM ON
SET DEBUG OFF
SET DEFAULT TO &dirini
SET DATE YMD
SET DELETED ON
SET ESCAPE OFF
SET EXCLUSIVE OFF
*!*	SET PATH TO &dirbmp, &dirdbf, &dirrep
SET PROCEDURE TO DegProce
SET REPROCESS TO -1
SET SAFETY OFF

*!*	*!*	SET CLASSLIB TO wwIPStuff ADDITIVE
*!*	*!*	SET PROCEDURE TO wwHTTP ADDITIVE
*!*	*!*	SET PROCEDURE TO wwUtils ADDITIVE
*!*	*!*	SET CLASSLIB TO wwXML ADDIT

ON KEY LABEL F1  DO psysayuda
ON KEY LABEL F2  ?? CHR(07)
ON KEY LABEL F3  ?? CHR(07)
ON KEY LABEL F4  ?? CHR(07)
ON KEY LABEL F5  DO pcamayuda
ON KEY LABEL F6  ?? CHR(07)
ON KEY LABEL F7  RUN /N CALC.EXE
ON KEY LABEL F8  ?? CHR(07)
ON KEY LABEL F9  ?? CHR(07)
ON KEY LABEL F10 ?? CHR(07)
ON KEY LABEL F11 ?? CHR(07)
ON KEY LABEL F12 ?? CHR(07)

ON SHUTDOWN DO PSalir

*ON ERROR DO ctrlerr WITH ;
*	ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO()

***********************************************
*   Especifica propiedades y métodos para la  * 
*   ventana principal de Visual SiDeg.        *
***********************************************
_Screen.Caption = "Visual SIDEG by VisualSOFT.com S.A.S."
_Screen.WindowState = 2

***********************************************
*   VARIABLE DE CONTROL DEL MENU PRINCIPAL    *
***********************************************
m.terminar = .F.

***********************************************
*   VARIABLE DE CONTROL DE ACCESO AL SISTEMA  *
***********************************************
m.security = 0

**/*********************************************
*/   VARIABLE DE CONTROL DE ACCESO A AUTOVENTA *
**/*********************************************
*/m.sysautoven = .F.

************************************************
*   VARIABLE DE CONTROL DE ACCESO A UN GRID    *
************************************************
m.grid_act = .F.

*************************************************************
*		CONSTANTES PARA CAJAS DE MENSAJES DE WINDOWS		*
*************************************************************

*!*	TABLA TIPO BOTON
btn_ac     = 0				&& Sólo presenta el botón "Aceptar".
btn_acca   = 1				&& Presenta los botones "Aceptar" y "Cancelar".
btn_anreig = 2				&& Presenta los botones "Anular", "Repetir" e "Ignorar".
btn_sinoca = 3				&& Presenta los botones "Sí", "No" y "Cancelar".
btn_sino   = 4				&& Presenta los botones "Sí" y "No".
btn_reca   = 5				&& Presenta los botones "Repetir" y "Cancelar".

*!*	TABLA ESTILO ICONO
icn_nin    = 0				&& No presenta icono.
icn_cri    = 16				&& Presenta icono Mensaje crítico.
icn_con    = 32				&& Presenta icono Consulta de advertencia.
icn_adv    = 48				&& Presenta icono Mensaje de advertencia.
icn_inf    = 64				&& Presenta icono Mensaje de información.

*!*	TABLA BOTON PREDETERMINADO
prd_btn_1  = 0				&& El primer botón es el predeterminado.
prd_btn_2  = 256			&& El segundo botón es el predeterminado.
prd_btn_3  = 512			&& El tercer botón es el predeterminado.

*!*	TABLA BOTON PRESIONADO
pss_btn_ac = 1				&& "Aceptar"
pss_btn_ca = 2				&& "Cancelar"
pss_btn_an = 3				&& "Anular"
pss_btn_re = 4				&& "Repetir"
pss_btn_ig = 5				&& "Ignorar"
pss_btn_si = 6				&& "Sí"
pss_btn_no = 7				&& "No"

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
	SET PATH TO &dirbmp, &dirdbf
ELSE
	QUIT
ENDIF

*************************************************************
*					ABRE LA BASE DE DATOS					*
*************************************************************
OPEN DATABASE VSiDeg  && Abre la BD de Visual SIDEG

*************************************************************
*   DEFINE VARIABLE PARA ABRIR ARCHIVOS DE FORMA EXCLUSIVA  *
*************************************************************
fileopen = .T.

*************************************************************
*       Reconstruccion del Registro del Distribuidor        *
*************************************************************
SELECT 0
USE MaeDistr
IF RECCOUNT("MaeDistr") = 0
	m.nom_dist = ""
	DO degsetup
ELSE
	m.nom_dist = PADC(ALLTRIM(MaeDistr.nocodist),15," ")
	SCATTER FIELDS compreprn, codregdist, codzondist, typedist, creditdist, autovedist MEMVAR 

	m.camposok = .F.
	FOR mcuenta = 1 TO FCOUNT()
		IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("factypeprn")
			m.camposok = .T.
		ENDIF
	ENDFOR
	IF (m.camposok)
		SCATTER FIELDS factypeprn MEMVAR 
	ELSE
	ENDIF

	m.camposok = .F.
	FOR mcuenta = 1 TO FCOUNT()
		IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("factype")
			m.camposok = .T.
		ENDIF
	ENDFOR
	IF (m.camposok)
		SCATTER FIELDS factype MEMVAR 
	ELSE
	ENDIF

	m.camposok = .F.
	FOR mcuenta = 1 TO FCOUNT()
		IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("costo_desc")
			m.camposok = .T.
		ENDIF
	ENDFOR
	IF (m.camposok)
		SCATTER FIELDS costo_desc MEMVAR 
	ELSE
		m.costo_desc = .T.
	ENDIF
ENDIF
USE IN MaeDistr

*************************************************************
*  CONSTANTE DEL TITULO DE LAS CAJAS DE MENSAJES DE WINDOWS *
*************************************************************
sysnom = " Visual SIDEG by VisualSOFT.com S.A.S. "
_Screen.Caption = "Visual SIDEG by VisualSOFT.com S.A.S."

*************************************************************
* 			INVOCA PANTALLA DE ACCESO A LA APLICACION 			*
*************************************************************
_Screen.AddObject("oImg", "image")
_Screen.oImg.Picture = "&dirbmp.\ColVSiDeg.jpg"
_Screen.oImg.Top = _Screen.Height/2 - _Screen.oImg.Height/2
_Screen.oImg.Left = _Screen.Width/2 - _Screen.oImg.Width/2
_Screen.oImg.Visible = .T.

*************************************************************
* 			INVOCA PANTALLA DE ACCESO A LA APLICACION 			*
*************************************************************
IF !EMPTY(ALLTRIM(m.nom_dist))
	DO deg_acce
	IF m.security = 9
	ENDIF
ELSE
	QUIT
ENDIF

*************************************************************
* 				INVOCA MENU DE ACCESO A LA APLICACION 				*
*************************************************************
*DO FORM Vtas_x_Mes.scx NAME Vtas_x_Mes LINKED
DO FORM VenDiaCli.scx NAME VenDiaCli LINKED

ON SHUTDOWN
QUIT
