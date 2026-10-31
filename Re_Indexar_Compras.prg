
		fileopen = .T.
		WAIT WINDOW "Reindexando archivo de Detalle de Entrada de Mercancía !!!" NOWAIT
		SELECT 0
		USE MaeEntDe EXCLUSIVE
		IF fileopen
			DELETE TAG ALL

			*******************************************************************
			* Parche para ajustar a la estructura de movimientos de referencia
			*******************************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("consecu")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				WAIT CLEAR
				WAIT WINDOW "Generando nueva estructura !!!" NOWAIT
				SELECT MaeEntDe.nrofactu AS facnro, MaeEntDe.consec AS consecu, ;
					MaeEntDe.codbode, MaeEntDe.codprov, MaeEntDe.codlin, MaeEntDe.codarti, ;
					MaeEntDe.canti AS faccant, MaeEntDe.valoruni AS precvent, MaeEntDe.ultcosto, Maeentde.procosto, ;
					MaeEntDe.porciva, MaeEntDe.valordes AS vlrtotdes, 0000000000.00 AS valortot;
					FROM maeentde ;
					ORDER BY 1, 2 ;
					INTO CURSOR QryEntDe

				USE IN MaeEntDe

				SORT TO &dirdbf.\MaeEntDe.dbf ON facnro, consecu

				WAIT CLEAR
	*!*				ADD TABLE &dirdbf.\MaeEntDe.dbf

				WAIT WINDOW "Reindexando archivo de Detalle de Entrada de Mercancía !!!" NOWAIT
				USE MaeEntDe EXCLUSIVE
			ENDIF
			***********************************************************************
			* FIN Parche para ajustar a la estructura de movimientos de referencia
			***********************************************************************

			**********************************************
			* Parche para campo de descuento
			**********************************************
			m.altertable = .F.
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("vlrtotdes")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF (m.camposok)
				ALTER TABLE MaeEntDe ADD COLUMN vlrdscto N(13,2) NULL
				REPLACE vlrdscto WITH vlrtotdes ALL
				ALTER TABLE MaeEntDe DROP COLUMN vlrtotdes
				m.altertable = .T.
			ELSE
				FOR mcuenta = 1 TO FCOUNT()
					IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("vlrdscto")
						m.camposok = .T.
					ENDIF
				ENDFOR
				IF !(m.camposok)
					ALTER TABLE MaeEntDe ADD COLUMN vlrdscto N(13,2) NULL
					m.altertable = .T.
				ENDIF
			ENDIF
			**********************************************
			* Fin Parche para campo de descuento
			**********************************************
			**********************************************
			* Parche para campo de Grupo de referencias
			**********************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("codprov")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF (m.camposok)
				m.campo2ok = .F.
				FOR mcuenta = 1 TO FCOUNT()
					IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("codgrupo")
						m.campo2ok = .T.
					ENDIF
				ENDFOR
				IF !(m.campo2ok)
					ALTER TABLE MaeEntDe ADD COLUMN codgrupo C(2) NULL
					m.altertable = .T.
					UPDATE MaeEntDe SET codgrupo = MaeEntDe.codprov
				ENDIF
			ELSE
				ALTER TABLE MaeEntDe ADD COLUMN codprov C(2) NULL
				m.campo2ok = .F.
				FOR mcuenta = 1 TO FCOUNT()
					IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("codgrupo")
						m.campo2ok = .T.
					ENDIF
				ENDFOR
				IF !(m.campo2ok)
					ALTER TABLE MaeEntDe ADD COLUMN codgrupo C(2) NULL
				ENDIF
				UPDATE MaeEntDe SET codprov = MaeEntDe.codgrupo
				m.altertable = .T.
			ENDIF
			************************************************
			* Fin Parche para campo de Grupo de referencias
			************************************************
			************************************************
			* Parche para campo de referencia proveedor
			************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("codartip")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntDe ADD COLUMN codartip C(15) NULL
				m.altertable = .T.
			ENDIF
			*************************************************
			* Fin Parche para campo de referencia proveedor
			*************************************************

*ojo con este código
			LOCATE FOR EMPTY(MaeEntDe.valortot)
			IF FOUND( )
				REPLACE MaeEntDe.valortot WITH (((MaeEntDe.faccant*MaeEntDe.precvent)-MaeEntDe.vlrdscto)*(1+(MaeEntDe.porciva/100))) ALL FOR EMPTY(MaeEntDe.valortot)
			ENDIF

			*******************************************************
			* Parche para la ampliación de la cantidad en factura
			*******************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("faccant")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF (m.camposok)
				IF FSIZE('faccant') = 10
					ALTER TABLE MaeEntDe ALTER COLUMN faccant N(13,2)
					m.altertable = .T.
				ENDIF
			ENDIF
			***********************************************************
			* Fin Parche para la amplición de la cantidad en factura
			***********************************************************

			*******************************************************
			* Parche para la adicion del impuesto al consumo
			*******************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("vlrotrim")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntDe ADD COLUMN vlrotrim N(13,2)
				m.altertable = .T.
			ENDIF
			***********************************************************
			* Fin Parche para la adicion del impuesto al consumo
			***********************************************************

			*******************************************************
			* Parche para la adicion del porcentaje de descuento
			*******************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("desccomp")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntDe ADD COLUMN desccomp N(6,2)
				m.altertable = .T.
			ENDIF
			***********************************************************
			* Fin Parche para la adicion del porcentaje de descuento
			***********************************************************

			*************************************************************
			* Parche para aumentar los decimales del ultcosto y procosto
			*************************************************************
			m.altertable = .F.
			IF FSIZE('ultcosto') = 10
				ALTER TABLE MaeEntDe ALTER COLUMN ultcosto N(13,4);
					ALTER COLUMN procosto N(13,4)
				m.altertable = .T.
			ENDIF
			*****************************************************************
			* Fin Parche para aumentar los decimales del ultcosto y procosto
			*****************************************************************

			***************************************************
			* Parche para aumentar los digitos del consecutivo
			***************************************************
			m.altertable = .F.
			IF FSIZE('consecu') = 2
				ALTER TABLE MaeEntDe ADD COLUMN oldconsecu C(2) NULL
				UPDATE MaeEntDe SET oldconsecu = MaeEntDe.consecu
				ALTER TABLE MaeEntDe ALTER COLUMN consecu C(3)
				UPDATE MaeEntDe SET consecu = PADL(ALLTRIM(MaeEntDe.oldconsecu),3,"0")
				ALTER TABLE MaeEntDe DROP COLUMN OldConsecu
				m.altertable = .T.
			ENDIF
			*******************************************************
			* Fin Parche para aumentar los digitos del consecutivo
			*******************************************************
			*******************************************************
			* Parche para la adicion del impuesto saludable
			*******************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("impBUA")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntDe ADD COLUMN ImpBUA N(6,2)
				ALTER TABLE MaeEntDe ADD COLUMN ImpCUI N(6,2)
				m.altertable = .T.
			ENDIF
			***********************************************************
			* Fin Parche para la adicion del impuesto saludable
			***********************************************************

			*PACK
			INDEX ON facnro TAG factura
			INDEX ON codgrupo+facnro TAG IndPri ADDITIVE
			INDEX ON codgrupo+facnro+consecu TAG EntConseDe ADDITIVE
*!*				INDEX ON facnro+codprov+codlin+codarti TAG facrefe ADDITIVE
*!*				INDEX ON facnro+consecu+codprov+codlin+codarti TAG detalle ADDITIVE
			USE IN MaeEntDe
			IF m.altertable
				DELETE FILE &dirdbf.\MaeEntDe.Bak RECYCLE
			ENDIF
		ENDIF
		ADD TABLE &dirdbf.\MaeEntDe.dbf
		addprikey = .T.
		ALTER TABLE MaeEntDe ADD PRIMARY KEY codgrupo+facnro+codprov+codlin+codarti TAG Detalle
		CLOSE TABLES ALL
		IF NOT addprikey
			SELECT 0
			USE MaeEntDe EXCLUSIVE
			INDEX ON codgrupo+facnro+codprov+codlin+codarti TAG Detalle ADDITIVE

			CLOSE TABLES ALL
		ENDIF
		WAIT CLEAR

		fileopen = .T.
		WAIT WINDOW "Reindexando archivo de Encabezado de Entrada de Mercancía !!!" NOWAIT
		SELECT 0
		USE MaeEntEn EXCLUSIVE
		IF fileopen
			DELETE TAG ALL
			PACK

			*******************************************************************
			* Parche para ajustar a la estructura de movimientos de referencia
			*******************************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("anocont")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				WAIT CLEAR
				WAIT WINDOW "Generando nueva estructura !!!" NOWAIT
				SELECT MaeEntEn.nrofactu AS facnro, ;
					MaeCalen.anocont, MaeCalen.mescont, MaeEntEn.fecha AS facfecha, ;
					MaeProve.nitprov AS ideprove, ;
					MaeEntEn.valorfact, MaeEntEn.vlrtotdes, MaeEntEn.vlrtotiva, MaeEntEn.anulada, ;
					SPACE(15) AS last_user, DATETIME() AS last_date;
					FROM maeenten INNER JOIN maecalen ;
					ON DTOS(MaeEntEn.fecha) BETWEEN DTOS(maecalen.fecinimes) AND DTOS(maecalen.fecfinmes) ;
					INNER JOIN maeprove ;
					ON MaeEntEn.codprov == MaeProve.codprov ;
					ORDER BY 4 ;
					INTO CURSOR QryEntEn

				USE IN MaeCalen
				USE IN MaeProve
				USE IN MaeEntEn

				SORT TO &dirdbf.\MaeEntEn.dbf ON facfecha

				WAIT CLEAR
	*!*				ADD TABLE &dirdbf.\MaeEntEn.dbf

				WAIT WINDOW "Reindexando archivo de Encabezado de Entrada de Mercancía !!!" NOWAIT
				USE MaeEntEn EXCLUSIVE
				SCATTER FIELDS last_date MEMVAR BLANK
				REPLACE ALL last_date WITH m.last_date
			ENDIF
			***********************************************************************
			* FIN Parche para ajustar a la estructura de movimientos de referencia
			***********************************************************************

	********Inicio campos para log
			m.altertable = .F.
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("last_user")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntEn ADD COLUMN last_user C(15) NULL
				m.altertable = .T.
			ENDIF

			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("last_date")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntEn ADD COLUMN last_date T NULL
				m.altertable = .T.
			ENDIF
	********Fin campos para log
			**********************************************
			* Parche para consecutivo de transacciones
			**********************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("transanro")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntEn ADD COLUMN transanro N(10,0) NULL
				m.altertable = .T.
			ENDIF
			**********************************************
			* Fin Parche para consecutivo de transacciones
			**********************************************

			*************************************************
			* Parche para la adicion del impuesto al consumo
			*************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("vlrtotipo")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntEn ADD COLUMN vlrtotipo N(13,2) NULL
				m.altertable = .T.
			ENDIF
			*****************************************************
			* Fin Parche para la adicion del impuesto al consumo
			*****************************************************

			***************************************************
			* Parche para el cambio de tipo de dato de anulada
			***************************************************
			IF TYPE("Anulada") = "L"
				ALTER TABLE MaeEntEn ADD COLUMN LAnulada L NULL
				UPDATE MaeEntEn SET LAnulada = MaeEntEn.Anulada
				ALTER TABLE MaeEntEn ALTER COLUMN Anulada C(1)
				UPDATE MaeEntEn SET Anulada = "T" WHERE MaeEntEn.LAnulada
				ALTER TABLE MaeEntEn DROP COLUMN LAnulada
			ENDIF
			*******************************************************
			* Fin Parche para el cambio de tipo de dato de anulada
			*******************************************************
			*************************************************
			* Parche para la adicion del impuesto saluble
			*************************************************
			m.camposok = .F.
			FOR mcuenta = 1 TO FCOUNT()
				IF UPPER(ALLTRIM(FIELD(mcuenta))) == UPPER("vlrtotisalud")
					m.camposok = .T.
				ENDIF
			ENDFOR
			IF !(m.camposok)
				ALTER TABLE MaeEntEn ADD COLUMN vlrtotisalud N(13,2) NULL
				m.altertable = .T.
			ENDIF
			*****************************************************
			* Fin Parche para la adicion del impuesto saludable
			*****************************************************

*!*				INDEX ON facnro TAG Factura
			INDEX ON DTOS(facfecha) TAG Fecha ADDITIVE
			INDEX ON ideprove TAG Proveedor ADDITIVE
			INDEX ON ideprove+facnro TAG IndPri ADDITIVE
			INDEX ON facnro TAG Factura ADDITIVE
			USE IN MaeEntEn
			IF m.altertable
				DELETE FILE &dirdbf.\MaeEntEn.Bak RECYCLE
			ENDIF
		ENDIF
		ADD TABLE &dirdbf.\MaeEntEn.dbf
		addprikey = .T.
*!*			ALTER TABLE MaeEntEn ADD PRIMARY KEY facnro TAG Factura
		CLOSE TABLES ALL

		DO WHILE NOT addprikey
			SELECT 0
			USE MaeEntEn IN 0 ORDER TAG IndPri EXCLUSIVE
*!*				INDEX ON facnro TAG Factura ADDITIVE

			SELECT MaeEntEn.ideprove+MaeEntEn.facnro AS docnro, COUNT(MaeEntEn.ideprove+MaeEntEn.facnro) as veces ;
				FROM maeenten ;
				GROUP BY MaeEntEn.ideprove, MaeEntEn.facnro ;
				ORDER BY 2 DESC ;
				INTO CURSOR QryEntEn

			SELECT QryEntEn
			GO TOP
			SCAN
				SCATTER MEMVAR
				IF m.veces > 1
					IF SEEK(m.docnro,"MaeEntEn")
						SELECT MaeEntEn
						DELETE
						SELECT QryEntEn
					ENDIF
				ENDIF
			ENDSCAN
			SELECT MaeEntEn
			PACK
			addprikey = .T.
			ALTER TABLE MaeEntEn ADD PRIMARY KEY ideprove+facnro TAG IndPri
			CLOSE TABLES ALL
		ENDDO
		WAIT CLEAR
