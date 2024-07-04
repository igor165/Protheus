#INCLUDE 'PROTHEUS.CH'
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#INCLUDE 'GPER025CHI.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³GPER025CHI³ Autor ³ alfredo.medrano     ³ Data ³ 04/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comprobante Feriado Legal (Chile)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER025CHI()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generar el informe llamado “Comprobante de Feriado Legal”  ³±±
±±³          ³ para el trabajador cuando toman días de vacaciones.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo     ³09/06/15³TMSFU7     ³Modificaciones ciclos vacacionales ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gSantacruz    ³25/08/15³TTESCN     ³Alinear las firmas/Se empalmaban   ³±±
±±³              ³        ³           ³los textos y los numeros delos dias³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo     ³02/09/15³TTGM65     ³Obtencion de datos S013			  ³±±
±±³Jonathan Glez ³24/11/15³PCREQ-7944 ³Localizacion CHI v12               ³±±
±±³              ³        ³           ³-Se prueba que funcione de manera  ³±±
±±³              ³        ³           ³correcta en v12, solo se realizaron³±±
±±³              ³        ³           ³cambios en diccionario             ³±±
±±³Alejandro P.  ³23/07/20³DMICNS-8873³Compilacion a versión 12.1.27	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER025CHI()

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Grupo de Preguntas GPER025CHI ³
	³						       ³
	³Sucursal         MV_PAR01     ³
	³Proceso          MV_PAR02     ³
	³Empleados        MV_PAR03     ³
	³Fecha De         MV_PAR04     ³
	³Fecha A          MV_PAR05     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*/

	If Pergunte( 'GPER025CHI', .T. )
		GPER0025CN()
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPER0025CN³ Autor ³ Alfredo Medrano       ³ Data ³04/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Obtiene y filtra los registros que se mostraran en reporte  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER0025CN( )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER025CHI()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GPER0025CN()

	Local		cAliasBus	:= criatrab( nil, .f. )
	Local		cQuery 	:= ""
	Local		aArea 	:= getArea()
	Local		cSuc   	:= ""
	Local		cPro   	:= ""
	Local		cEmp   	:= ""
	Local 		nTotalR	:= 0
	Local 		nResImpr:= 0
	Local 		cMat	:= "" //Matricula
	Local 		cPD		:= "" //Código concepto
	Local 		nBan	:= 0
	Local 		nDur	:= 0
	Local		nPrReg 	:= 0
	Local 		nPdia  	:= 0
	Local	 	cMsgNoRe:= OemToAnsi(STR0029)
	Local 		dDtIni	:= CTOD(" / / ")
	Local 		dDtFim	:= ctod(" / / ")
	Private		nDiasH	:= 0  //Dias habiles
	Private	 	aFechas	:= {} // Fechas
	Private 	cNombre	:= ""
	Private 	cCveEmp := "" // RA_EMPRESA
	Private 	cRCIC	:= ""
	Private  	aPerio	:= {} // Periodo
	Private  	aToPar	:= {} // Total o parcial
	Private  	aDiasH	:= {} // Periodo
	Private  	nTDomH	:= 0  // total de dias inhabiles (Domingos y dias Festivos)
	Private 	oPrinter

	//convierte parametros tipo Range a expresion sql
	//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
	MakeSqlExpr("GPER025CHI")

	cSuc := trim(MV_PAR01) //Sucursal
	cPro := trim(MV_PAR02) //Proceso
	cEmp := trim(MV_PAR03) //Empleados
	dDtIni := MV_PAR04
	dDTFim := MV_PAR05

	//Se filtran los datos de las tablas SR8 (Ausentismos) con relacion a la Tabla SRV(Conceptos), SRA (Empleados) y RCM
	cQuery := " SELECT R8_FILIAL,R8_MAT,R8_PD,R8_DATAINI,R8_DATAFIM,R8_DURACAO,
	cQuery += " R8_TIPOAFA,R8_SDPAGAR,RCM_TIPO,RCM_TIPOAF,RV_CODFOL,RV_COD, RA_NOME, RA_CIC, RA_MAT, RA_EMPRESA "
	cQuery += " FROM " + RetSqlName("SR8") + " SR8, "
	cQuery += 	  RetSqlName("SRV") + " SRV, "
	cQuery += 	  RetSqlName("SRA") + " SRA, "
	cQuery += 	  RetSqlName("RCM") + " RCM  "
	cQuery += " WHERE RV_COD = R8_PD AND R8_MAT = RA_MAT AND RCM_PD=R8_PD "
	cQuery += " AND R8_SDPAGAR <> 0
	If	!Empty( cSuc )
		cQuery += " AND " + cSuc
	EndIf
	If	!Empty( cPro )
		cQuery += " AND " + cPro
	EndIf
	If	!Empty( cEmp )
		cQuery += " AND " + cEmp
	EndIf
	cQuery += " AND RCM_TIPOAF    	= '4' "  //Tipo de Ausencia VACACIONES LEGALES
	cQuery += " AND R8_FILIAL 	= '" + XFILIAL('SR8') + "' "
	cQuery += " AND RV_FILIAL 	= '" + XFILIAL('SRV') + "' "
	cQuery += " AND RA_FILIAL	= '" + XFILIAL('SRA') + "' "
	cQuery += " AND RCM_FILIAL 	= '" + XFILIAL('RCM') + "' "
	cQuery += " AND R8_DATAINI >= '" + DTOS(dDtIni)+ "' "
	cQuery += " AND R8_DATAINI <= '" + DTOS(dDtFim)+ "' "
	cQuery += " AND SR8.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND SRV.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND SRA.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND RCM.D_E_L_E_T_ 	= ' ' "
	cQuery += " ORDER BY R8_FILIAL,R8_MAT,R8_PD,R8_DATAINI,R8_DATAFIM,R8_DURACAO, "
	cQuery += " R8_TIPOAFA,R8_SDPAGAR,RCM_TIPO,RCM_TIPOAF,RV_CODFOL,RV_COD, RA_NOME, RA_CIC, RA_MAT"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBus,.T.,.T.)
	TCSetField(cAliasBus,"R8_DATAINI","D",8,0) // Formato de fecha
	TCSetField(cAliasBus,"R8_DATAFIM","D",8,0) // Formato de fecha
	Count to nTotalR
	(cAliasBus)->(dbgotop())//primer registro de tabla

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ se inicializa el objeto FWMSPrinter         ³
	//³ solo si hay registros para procesar         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	nTotalR > 0
		oPrinter := FWMSPrinter():New('GPER025CHI',6,.F.,,.T.,,,,,.F.) //inicializa el objeto
		oPrinter:Setup() 				   	//abre el objeto
		oPrinter:SetPortrait()
		nResImpr := oPrinter:nModalResult 	//obtiene nModalResult=1 confimada --- nModalResult=2 cancelada
	Else
		MsgStop( cMsgNoRe ) // Sin registros para mostrar.
	EndIf

	If nResImpr == 1
		While  (cAliasBus)->(!EOF())
			nBan++
				If cMat == ( cAliasBus )-> R8_MAT
					nDiasH := nDiasH + ( cAliasBus )-> R8_DURACAO
				 	If cPD != ( cAliasBus )-> R8_PD
						cNombre:=(cAliasBus)-> RA_NOME
						cCveEmp:= (cAliasBus)-> RA_EMPRESA
						cRCIC	:=(cAliasBus)-> RA_CIC
						AADD(aFechas,{( cAliasBus )-> R8_DATAINI,( cAliasBus )-> R8_DATAFIM,( cAliasBus )-> R8_DURACAO})
						GPER0025DH(( cAliasBus )->R8_DATAINI,( cAliasBus )->R8_DATAFIM, ( cAliasBus )-> R8_FILIAL, ( cAliasBus )-> R8_MAT )
						GPER0025DD(( cAliasBus )-> R8_MAT,( cAliasBus )-> R8_PD,( cAliasBus )-> R8_DURACAO, ( cAliasBus )-> RV_CODFOL,( cAliasBus )-> R8_SDPAGAR )	//Control dias derecho
					EndIf
					nPrReg := 1
					nPdia  := 1
				Else
					If  nPrReg == 1
						GPER0025PR() //imprime Formato
						nPrReg := 0
					    nPdia  := 0
					EndIF
				EndIf

			If  nPrReg == 0
				If  nPdia == 0
					nDiasH := ( cAliasBus )-> R8_DURACAO
				EndIf
				cNombre:=(cAliasBus)-> RA_NOME
				cRCIC	:=(cAliasBus)-> RA_CIC
				cCveEmp:= (cAliasBus)-> RA_EMPRESA
				AADD(aFechas,{( cAliasBus )-> R8_DATAINI,( cAliasBus )-> R8_DATAFIM, ( cAliasBus )-> R8_DURACAO})
				GPER0025DH(( cAliasBus )->R8_DATAINI,( cAliasBus )->R8_DATAFIM, ( cAliasBus )-> R8_FILIAL, ( cAliasBus )-> R8_MAT )
				GPER0025DD(( cAliasBus )-> R8_MAT,( cAliasBus )-> R8_PD,( cAliasBus )-> R8_DURACAO, ( cAliasBus )-> RV_CODFOL,( cAliasBus )-> R8_SDPAGAR )	//Control dias derecho
				nPrReg := 1
				nPdia  := 1
			EndIf

		 	nDur 	:= ( cAliasBus )-> R8_DURACAO
		 	cMat	:= ( cAliasBus )-> R8_MAT
		 	cPD		:= ( cAliasBus )-> R8_PD

		 	If nBan == nTotalR
		 		GPER0025PR() //imprime Formato
		 	EndIf

			( cAliasBus )-> (dbskip())
		EndDo

		If 	nTotalR > 0
			oPrinter:Preview()   // previsualiza el archivo PDF
		EndIf

	EndIf

	(cAliasBus)->( dbCloseArea())
	restArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPER0025DD³ Autor ³ Alfredo Medrano       ³ Data ³05/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Obtiene registros para Vacaciones                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER0025DD(ExpC1,ExpC2,ExpN3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³ cMat     := Matricula del Empleado                         ³±±
±±³          ³ cR8_PD   := Codigo Concepto                                ³±±
±±³          ³ nDURACAO := Duracion Vacaiones                             ³±±
±±³          ³ cVac     := Cod Reg Vacaiones                              ³±±
±±³          ³ nSald    := Saldo Nomina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER0025CN()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPER0025DD(cMat,cR8_PD, nDURACAO,cVac, nSald )

	Local	cAliasC	:= criatrab( nil, .f. )
	Local	cQuery 	:= ""
	Local nX			:= 0
	Local cPedC   	:= OemToAnsi(STR0002) // "PERIODO CONTRACTUAL DEL"
	Local cAlo   	:= OemToAnsi(STR0003) // "AL"
	Local cPar   	:= OemToAnsi(STR0009) // "PARTE"
	Local cTot   	:= OemToAnsi(STR0035) // "TOTALIDAD "
	Local cGuion    := OemToAnsi(STR0027) // "-"
	Local nTotalR	:= 0
	Local cSpac		:= space (2)
	Local cPerio	:= ""
	Local cParTo	:= ""
	Local nDias		:= 0
	Local cAnioI	:= ""
	Local cAnioF	:= ""
	Local cFil		:= XFILIAL('SRF')
	Local cTipoF	:= ""
	Local c0072		:= FGETCODFOL("0072")
	Local c1382		:= FGETCODFOL("1383")
	Local cPD		:= ""
	Local nAux		:= 0
	Local nDurAux	:= 0

	cQuery := " SELECT RF_FILIAL,RF_MAT,RF_PD,RF_DATABAS,RF_DATAFIM,"
	cQuery += " RF_DIASDIR,RF_DFERVAT,RF_DIASANT,RF_DFERANT,RF_STATUS "
	cQuery += 	" FROM " + RetSqlName("SRF")
	cQuery += " WHERE RF_MAT = '" + cMat + "' AND RF_PD = '"+cR8_PD+"' "
	cQuery += " AND (RF_DFERANT < RF_DFERVAT OR (RF_DIASANT <> 0 AND RF_DIASANT > RF_DFERANT))  "
	cQuery += " AND RF_FILIAL = '" + cFil + "' "
	cQuery += " AND RF_STATUS <> '2' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY RF_DATABAS, RF_DATAFIM"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasC,.T.,.T.)
	TCSetField(cAliasC,"RF_DATABAS","D",8,0) // Formato de fecha
	TCSetField(cAliasC,"RF_DATAFIM","D",8,0) // Formato de fecha
	Count to nTotalR
	(cAliasC)->(dbgotop())//primer registro de tabla

	nAux :=  nDuracao

	While  (cAliasC)->(!EOF())	.and. nAux > 0

		nDias   :=    (cAliasC)-> RF_DFERVAT + (cAliasC)-> RF_DIASANT - (cAliasC)-> RF_DFERANT
		nDurAux := nAux
		If !(nAux <= ((cAliasC)-> RF_DFERVAT + (cAliasC)-> RF_DIASANT - (cAliasC)-> RF_DFERANT))//nDias)
			nAux := nDias //((cAliasC)-> RF_DFERVAT + (cAliasC)-> RF_DIASANT - (cAliasC)-> RF_DFERANT)
		EndIF

		nx := nTotalR -1

		cAnioI:= AllTrim(STR(YEAR((cAliasC)->RF_DATABAS)))
		cAnioF:= AllTrim(STR(YEAR((cAliasC)->RF_DATAFIM)))
		cPerio := cPedC + cSpac + DTOC((cAliasC)-> RF_DATABAS) + cSpac + cAlo  + cSpac + DTOC((cAliasC)-> RF_DATAFIM)
		cPD := (cAliasC)->RF_PD
		AADD(aPerio, cPerio)

		//Si R8_DURACAO >= SRF->RF_DEFERVAT Entonces “TOTAL” si no “PARTE”
		cParTo	:= IIF(nAux >= nDias,cTot,cPar )
		cTipoF	:= IIF(c0072 $ cPD,STR0031 , IIF(c1382 $ cPD,STR0032," "))
		AADD( aToPar,alltrim(STR(nAux)) +STR0033 + cParTo +cSpac + STR0034 + cSpac +   cAnioI + cGuion + cAnioF + cSpac + STR0022 + cSpac+ cTipoF)

		AADD(aDiasH, { cAnioI, cAnioF, nDias, cVac, cR8_PD, nSald,nAux } )
		nAux := nDurAux - nAux
	 	(cAliasC )-> (dbskip())

	 EndDo
	(cAliasC)->( dbCloseArea())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPER0025PR³ Autor ³ Alfredo Medrano       ³ Data ³04/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Imprime archivo con los registros obtenidos  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER0025PR()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER0025CN                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPER0025PR()
	Local oFontT
	Local oFontP
	Local oFontPP
	Local nX  		:= 0
	Local cTit1   	:= OemToAnsi(STR0001) // "COMPROBANTE DE FERIADO LEGAL"
	Local cPedC   	:= OemToAnsi(STR0002) // "PERIODO CONTRACTUAL DEL"
	Local cAlo   	:= OemToAnsi(STR0003) // "AL"
	Local cDme   	:= OemToAnsi(STR0004) // "Y"
	Local cTex1    := OemToAnsi(STR0005) // "En cumplimiento a las disposiciones legales vigentes se deja constancia que a contar de
	Local cTrab		:= OemToAnsi(STR0024) // "las fechas que se indican, el trabajador:"
	Local cDnia   	:= OemToAnsi(STR0006) // "Don(ña):  "
	Local cRut   	:= OemToAnsi(STR0007) // "Rut.:  "
	Local cHus   	:= OemToAnsi(STR0008) // "Hará uso"
	Local cPar   	:= OemToAnsi(STR0009) // "PARTE"
	Local cTot   	:= OemToAnsi(STR0010) // "TOTAL"
	Local cDsu   	:= OemToAnsi(STR0011) // "de su"
	Local cTex2   	:= OemToAnsi(STR0012) // "feriado anual con remuneración integra de acuerdo al siguiente detalle:"
	Local cTit2   	:= OemToAnsi(STR0013) // "DESCANSO EFECTIVO ENTRE LAS FECHAS QUE SE INDICAN:"
	Local cVaI   	:= OemToAnsi(STR0014) // "DESDE EL: "
	Local cDHab   	:= OemToAnsi(STR0015) // "Días hábiles."
	Local cDet   	:= OemToAnsi(STR0016) // "DETALLE DEL FERIADO"
	Local cDHb1   	:= OemToAnsi(STR0017) // "Días hábiles"
	Local cDosP   	:= OemToAnsi(STR0028) // ":"
	Local cDmIn   	:= "" // "Domingos e Inabilites"
	Local cSlPH   	:= "" // "Saldo Pendiente Hábiles"
	Local cNmFir  	:= AllTrim(OemToAnsi(STR0021)) // "Nombre y firma del trabajador"
	Local cDe   	:= OemToAnsi(STR0022) // "de"
	Local cDel   	:= OemToAnsi(STR0023) // "del"
	Local cGuion  	:= OemToAnsi(STR0027) // "-"
	Local cDiasHab	:= ""
	Local cCiud		:= SM0->M0_CIDENT
	Local cEmpre	:= SM0->M0_NOMECOM
	Local dFecha	:= dDataBase
	Local cSpac		:= space(2)
	Local nEsp 		:= 85   // posición inicial del formato de impresión
	Local nReg		:= 0
	Local nSaldo	:= 0
	Local nDes		:= 0
	Local cNomDir	:= ""//AllTrim(GETMV("MV_REPEMP")) 	 // Nombre del director o representante de la empresa
	Local cPuest	:= ""//AllTrim(GETMV("MV_REPPUE"))	 // Descripción del puesto de representate
	Local cStartPath := GetSrvProfString("Startpath","")
	Local cNameFile	:= ""
	Local nLeft		:= 35
	Local cText		:= ""
	Local nLoop     := 0
	Local aFirmas   := {}
	Local nLineF    := 500
	Local nColuF    := 0

	cNomDir := GetParameter("S013",cCveEmp,5)
	cPuest	:= GetParameter("S013",cCveEmp,7)

		oFontT	:= TFont():New('Courier New',,14,.T.,.T.)  //Fuente del Titulo
		oFontP	:= TFont():New('Courier New',,12,,.F.,,,,.T.,.F.)    //Fuente del Párrafo
		oFontPN := TFont():New('Courier New',,12,.T.,.T.)     //Fuente del Párrafo Negritas
		oFontPP	:= TFont():New('Courier New',,12,,.F.,,,,.T.,.F.)    //Fuente del Párrafo
		cValInL	:= space(90)

		oPrinter:StartPage() // se agrega una nueva página a la impresión


		cStartPath := AjuBarPath(cStartPath)
		If cPaisLoc == "CHI"
			cNameFile  := cStartPath+"lgrl01.bmp" //cEmpAnt  y cFilAnt variables Globales
		EndIf
		If !File(cNameFile)	//verifica que exista el logo de la empresa.
			cNameFile := cStartPath+"lgrl"+cEmpAnt+".bmp" //Asigna imagen default
		Endif
		oPrinter:SayBitmap(25,nLeft,cNameFile,80,50) // imprime Logo de la empesa en la parte superior izquierda

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Agrega Titulo del Reporte Y Fecha impresion ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrinter:Say(nEsp+3,nLeft, AlignText(60,cTit1) ,oFontT)
			nEsp := nEsp + 55
			oPrinter:Say(nEsp,  nLeft, Alltrim(cCiud) + ", " +  LTRIM(STR(DAY(dFecha))) + cSpac + cDe + cSpac + MESEXTENSO(MONTH(dFecha))+ cSpac  + cDel + cSpac + AllTrim(STR(YEAR(dFecha))) , oFontP)
			nEsp := nEsp + 11
			For nx:=1 to  Len(aPerio)
				nReg := Len(aPerio)
				nReg := nReg - 1
				nEsp := nEsp + 11
				oPrinter:Say(nEsp,  nLeft, aPerio[nx] + cSpac + IIF(nReg >= nx, cDme,"")  , oFontP)
			Next

			nEsp := nEsp + 21
			oPrinter:Say(nEsp,  nLeft,cTex1  , oFontP)
			nEsp := nEsp + 11
			oPrinter:Say(nEsp,  nLeft, cTrab , oFontP)
			nEsp := nEsp + 11
			oPrinter:Say(nEsp,  nLeft,cDnia + cSpac + cNombre + cSpac + cRut + cSpac + transform(cRCIC,"@R XX.999.999-X")  , oFontP)
			nEsp := nEsp + 11
			oPrinter:Say(nEsp,  nLeft,cHus + "  ", oFontP)

			For nx:=1 to  Len(aToPar)
				nEsp := nEsp + 11
				oPrinter:Say(nEsp,  nLeft, aToPar[nx]  , oFontP)
			Next

			nEsp := nEsp + 11
			oPrinter:Say(nEsp,  nLeft, cDsu + Space(1) + cTex2  , oFontP)
			nEsp := nEsp + 21
			oPrinter:Say(nEsp,  nLeft, cTit2  , oFontPN)
			nEsp := nEsp + 21
			
			aFechas := ASORT(aFechas,,,{ |x,y| x[1] < y[1] })
			For nloop:=1 to len(aFechas)
				oPrinter:Say(nEsp,  nLeft,cVaI + cSpac + DTOC(aFechas[nloop,1]) +  cSpac + cAlo + cSpac + DTOC(aFechas[nloop,2]) + " "+ Alltrim(STR(aFechas[nloop,3])) + cSpac + cDHab   , oFontP)
				nEsp := nEsp + 11
			Next
			nEsp := nEsp + 21
			
			oPrinter:Say(nEsp,  nLeft, cDet , oFontP)
			//obtiene RV_CODFOL: si es 0072 Indica que el registro es de Vacaciones
			nEsp := nEsp + 21
			For nx:=1 to  Len(aDiasH)
				If	aDiasH[nx][4]=="0072"
					cText := STR0031
				ElseIf aDiasH[nx][4]=="1383"
					cText := STR0032
				EndIF

				cDiasHab := cDHb1 + " " + STR0034 + " " + aDiasH[nx][1] + cGuion + aDiasH[nx][2] + " " + cText + cDosP
				cDiasHab := cDiasHab +  Replicate(" ",35-Len(Alltrim(cDiasHab)))
				oPrinter:Say(nEsp,  nLeft,  cDiasHab+Alltrim(STR(aDiasH[nx][7])) , oFontP)
				nEsp := nEsp + 11
				nDes += aDiasH[nx][7] // 6
				nSaldo := nSaldo + aDiasH[nx][3]
			Next
			nSaldo := nSaldo - nDes

			cDmIn := AllTrim(OemToAnsi(STR0019)) + Replicate(" ",len(cDiasHab)- Len(Alltrim(OemToAnsi(STR0019)))-1) + cDosP
			oPrinter:Say(nEsp,  nLeft,  cDmIn + AllTrim(Str(nTDomH))   , oFontP)
			nEsp := nEsp + 11

			cSlPH := AllTrim(OemToAnsi(STR0020)) + Replicate(" ",len(cDiasHab)-Len(Alltrim(OemToAnsi(STR0020)))-1) + cDosP
			oPrinter:Say(nEsp,  nLeft,  cSlPH+AllTrim(Str(nSaldo))  , oFontP)
			nEsp := nEsp + 11

			AADD(aFirmas,{cNomDir,Replicate("_",30),cPuest,cEmpre})
			AADD(aFirmas,{cNombre,Replicate("_",30),cNmFir,""})

			If  ExistBlock("Gp025PPag")
				aFirmas := ExecBlock("Gp025PPag", .F., .F., {aFirmas})
			Endif
			
			For nloop:=1  to len(aFirmas)
				//nContL++
				nColuF := IIf(Mod(nloop,2)==0,295,10)
				nLineF += IIf(Mod(nloop,2)==0,(-45),30)
				
				// Nombre + Línea
				nLineF += 15
				oPrinter:Say(nLineF,  nColuF , AlignText(40, aFirmas[nloop,1]), oFontPP) 
				oPrinter:Say(nLineF,  nColuF , AlignText(40, aFirmas[nloop,2]), oFontPP) 
				//Puesto/Descripción
				nLineF += 15
				oPrinter:Say(nLineF,  nColuF , AlignText(40, aFirmas[nloop,3]), oFontPP) 
				//Adicional
				nLineF += 15
				oPrinter:Say(nLineF,  nColuF , AlignText(40, aFirmas[nloop,4]), oFontPP) 
			Next

			//Limpiamos variables Privadas
			aFechas		:= {}
			cNombre 	:= ""
			cRCIC		:= ""
			nDiasH		:= 0
			aPerio		:= {} // Periodo
			aToPar		:= {} // Total o parcial
			aDiasH		:= {} // Dias Habiles
			nSald		:= 0
			nTDomH		:= 0
			NsALDO 		:= 0
			nDes		:= 0
		oPrinter:EndPage()  // Finaliza la página
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPER0025DH³ Autor ³ Alfredo Medrano       ³ Data ³09/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula los días inhabilles (Domingos y dias Feriados)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER0025DH()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dFechaI = Fecha Inicial                                    ³±±
±±³          ³ dFechaF = Fecha Final                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER0025CN                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function GPER0025DH(dFechaI,dFechaF,cFilSR8,cMatSR8)
	Local  nDiasHab	:= 0
	Default cFilSR8 := ""
	Default cMatSR8 := ""
	
	If  !Empty(dFechaI) .And. !Empty(dFechaF)
		GpeCalend(cFilSR8,cMatSR8,,,, dFechaI, dFechaF, @nDiasHab, "D",,.F. )
		nTDomH += ((dFechaF - dFechaI ) + 1 ) - nDiasHab
	Endif
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AlignText ³ Autor ³ Alfredo Medrano       ³ Data ³23/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Centra un texto                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AlignText()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTam = Tamaño del espacio en donde se centrara el texto    ³±±
±±³          ³ cTex = Texto                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER0025PR                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function AlignText(nTam, cTex)
Local 		nTamTxt	:= 0
Local 		nRes	  	:= 0
Local 		nEsp		:= 0
Local		cRegTex	:= ""
default 	nTam		:= 0
default 	cTex 		:= ""
cRegTex	:= space(nTam)
If nTam > 0

 If cTex  != ""
	nTamTxt:= Len(AllTrim(cTex))
	If nTamTxt > nTam
		cTex 	:= AllTrim(Substr(cTex,1,nTam))
		nTamTxt:= Len(cTex)
	EndIf
	nRes	:=  nTam - nTamTxt
	nEsp	:= nRes / 2
	cRegTex:= Space(nEsp) + AllTrim(cTex) + Space(nEsp)
 Else
 	cRegTex := Space(nTam)
 EndIf

End If

return cRegTex

Static Function GetParameter(cTab,cFilTab, nPosCol)
	Local nLin 	:= 0
	Local cReturn := ""
	Local aArea := getArea()
	dbselectarea("RCC")
	RCC->(DBGOTOP())
	nLin 	:= fPostab(cTab,cFilTab,"=",4)
	nLin 	:= IIF(nLin == 0 .or. nLin == NIL, 1, nLin)
	cReturn:= fTabela(cTab, nLin, nPosCol)

	RestArea(aArea)
Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TipAusOpcBox³ Autor ³Alejandro Parrales   ³ Data ³04/08/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna la lista de opciones para el campo RCM_TPIMSS		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TipAusOpcBox()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno	                                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TipAusOpcBox()
	Local cTipAus := ""
	cTipAus += ("00="+ STR0037 +";") //"Sin Movimiento"
	cTipAus += ("03="+ STR0038 +";") //"Subsidio"
	cTipAus += ("04="+ STR0039 +";") //"Permiso Sin Goce"
	cTipAus += ("06="+ STR0040 +";") //"Accidente de trabajo"
	cTipAus += ("11="+ STR0041 +";") //"Otros Ausentismos"
	cTipAus += ("13="+ STR0042 +";") //"Suspensión por acto de autoridad"
	cTipAus += ("14="+ STR0043 +";") //"Suspensión por pacto"
	cTipAus += ("15="+ STR0044) //"Reducción de jornada laboral"

Return cTipAus
