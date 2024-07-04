#INCLUDE "PROTHEUS.CH"
#INCLUDE "report.ch"
#INCLUDE "GPER014COL.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER014COL³ Autor  ³  Miguel Angel Rojas G.   ³ Data ³ 11.11.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comparativo Verba do Funcionário                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER014COL                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COLOMBIA                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³MIGUEL.ROJAS³14/01/14³          ³ Falla en Query periodos distintos rd/rc  ³±±
±±³Jonathan Glz³23/06/16³TVJRU7    ³ Se cambian nombres fijos en los querys.  ³±±
±±³Jonathan Glz³14/07/16³TVJRU7    ³ Se realiza ajsute para impresion de tipo ³±±
±±³            ³        ³          ³ planilla en formato tabla, pues no salia ³±±
±±³            ³        ³          ³ informacion                              ³±±
±±³ Marco A.   ³28/11/16³ MMI-4228 ³ Replica para V12.1.7 de cambios realiza- ³±±
±±³            ³        ³          ³ dos en V11.8 del Pais Colombia           ³±±
±±³ Marco A.   ³15/12/16³ MMI-4431 ³ Replica para V12.1.14 de cambios realiza-³±±
±±³            ³        ³          ³ dos en V12.1.7 del Pais Colombia.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER014COL()

	Local	oReport	:= Nil                             
	Local	aArea	:= GetArea()

	Private cString		:= GetNextAlias() // Alias del Archivo Princial
	Private lCorpManage	:= fIsCorpManage(FWGrpCompany())

	If lCorpManage
		Private lEmpFil		:= !Empty(FWSM0Layout(cEmpAnt, 1))  
		Private cLayoutGC	:= FWSM0Layout(cEmpAnt)
		Private nStartEmp	:= At("E",cLayoutGC)
		Private nStartUnN	:= At("U",cLayoutGC)
		Private nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
		Private nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()                      

	RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef ³ Autor ³ Miguel Angel Rojas   ³ Data ³  11.11.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definición del Reporte                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local oReport	:= Nil
	Local oBreakPg	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil

	Local cTitulo	:= STR0001
	Local cPerg		:= "GPER014COL"

	//-- Definición del Reporte
	DEFINE REPORT oReport NAME "GPER014COL" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION OemToAnsi(STR0001)
	oReport:SetLandscape()

	//-- Datos del Empleado
	DEFINE SECTION oSection1 OF oReport ORDERS {} TITLE cTitulo TOTAL IN COLUMN
	oSection1 :SetHeaderSection()

	DEFINE CELL NAME "RV_COD"      OF oSection1 Alias " " SIZE 12 TITLE oemToAnsi(STR0002)
	DEFINE CELL NAME "RV_DESC"     OF oSection1 Alias " " SIZE 18 TITLE oemToAnsi(STR0003)
	DEFINE CELL NAME "RA_FILIAL"   OF oSection1 ALIAS " "         TITLE oemToAnsi(STR0004)
	DEFINE CELL NAME "RA_MAT"      OF oSection1 ALIAS " " SIZE 13 TITLE oemToansi(STR0005)
	DEFINE CELL NAME "RA_NOME"     OF oSection1 ALIAS " "         TITLE oemToansi(STR0006)
	DEFINE CELL NAME "RA_RG"       OF oSection1 ALIAS " "         TITLE oemToansi(STR0007)
	DEFINE CELL NAME "RA_CC"       OF oSection1 ALIAS " " SIZE 13 TITLE oemToansi(STR0008)
	DEFINE CELL NAME "RD_ENTIDAD"  OF oSection1 ALIAS " "         TITLE oemToansi(STR0009)

	//-- Datos del Empleado
	DEFINE SECTION oSection2 OF oSection1   TITLE OemToAnsi(STR0002)
	oSection2 :SetHeaderSection()

	DEFINE CELL NAME "RV_COD"   OF oSection2 Alias " " SIZE 15 TITLE oemToAnsi(STR0002)
	DEFINE CELL NAME "RV_DESC"  OF oSection2 Alias " " SIZE 30 TITLE oemToAnsi(STR0003)

	oSection1:Cell("RA_FILIAL"):Disable()
	oSection1:Cell("RV_COD"):Disable()
	oSection1:Cell("RV_DESC"):Disable()

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReport ºAutor  ³Miguel Angel Rojas  º Data ³  11/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)
	
	Local oSection1		:= oReport:Section(1) // Empleado
	Local oSection2		:= oReport:Section(1):Section(1) // Concepto
	Local cPicture		:= "@E 999,999,999,999.99"
	Local cPerg			:= "GPER014COL"
	Local cQrySRA		:= GetNextAlias()
	Local cFilialSRA	:= xFilial("SRA")
	Local cFilialSRV	:= xFilial("SRV")
	Local bImprimir		:= .T. //Bandera control de impresión si .T. se ejecutará el reporte.
	Local nReg			:= 0
	Local nTotalR		:= 0
	Local cFiltro		:= ""
	Local cSitQuery		:= ""
	Local cCatQuery		:= ""
	Local cPrefx		:= ""
	Local cAliasAux		:= ""
	Local cPrefx2		:= ""
	Local cAliasAux2	:= ""
	Local cTitEFil		:= ""
	Local cStPer1		:= ""
	Local cStPer2		:= ""
	Local cCncpto		:= ""
	Local cCpto			:= ""
	Local cCod			:= ""
	Local cSucursal		:= ""
	Local cCntCosto		:= ""
	Local cMatricula	:= ""
	Local cNombre		:= ""
	Local cSituacion	:= ""
	Local cCategoria	:= ""
	Local cConceptos	:= ""
	Local cProceso		:= ""
	Local cRoteiro		:= ""
	Local cPeriodo1		:= ""
	Local cPago1		:= ""
	Local cPeriodo2		:= ""
	Local cPago2		:= ""
	Local oBreakFil		:= Nil		
	Local oBreakEFil	:= Nil
	Local cPrefxSuc		:= ""
	Local cPrefx2Suc	:= ""

	CursorWait()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preguntas selecionadas - GPER014COL    ³
	//³ Variable utilizadas para parametros    ³
	//³ mv_par01     // ¿Sucursal?             ³
	//³ mv_par02     // ¿Centro de Costos?     ³
	//³ mv_par03     // ¿Matrícula?            ³
	//³ mv_par04     // ¿Nombre?               ³
	//³ mv_par05     // ¿Situacion?            ³
	//³ mv_par06     // ¿Categoria?            ³
	//³ mv_par07     // ¿Concepto?             ³
	//³ mv_par08     // ¿Proceso?              ³
	//³ mv_par09     // ¿Procedimiento?        ³
	//³ mv_par10     // ¿Periodo 1?            ³
	//³ mv_par11     // ¿No. Pago 1?           ³
	//³ mv_par12     // ¿Periodo 2?            ³
	//³ mv_par13     // ¿No. Pago 2?           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte( cPerg , .F. )
	
	cSucursal    := StrTran(MV_PAR01, "'", "")
	cCntCosto    := StrTran(MV_PAR02, "'", "")
	cMatricula   := StrTran(MV_PAR03, "'", "")
	cNombre      := StrTran(MV_PAR04, "'", "")
	cSituacion   := MV_PAR05
	cCategoria   := MV_PAR06
	cConceptos   := StrTran(MV_PAR07, "'", "")
	cProceso	 := MV_PAR08
	cRoteiro     := MV_PAR09
	cPeriodo1    := MV_PAR10
	cPago1 	     := MV_PAR11
	cPeriodo2    := MV_PAR12
	cPago2       := MV_PAR13

	If  cPeriodo1 == cPeriodo2 .AND. cPago1 == cPago2
		Aviso( STR0024 , STR0025 + cPeriodo1 + " " + cPago1 , { "Ok" } )
		bImprimir := .F.
	Endif

	If !Empty( cSucursal )// Filtro Sucursal
		cFiltro += "AND SRA." + RANGESX1( "RA_FILIAL" , cSucursal )
	EndIf
	If !Empty( cCntCosto )// Filtro de Centro de Costos
		cFiltro += "AND SRA." + RANGESX1( "RA_CC" , cCntCosto )
	EndIf
	If !Empty( cMatricula ) // Filtro Matricula
		cFiltro += "AND SRA." + RANGESX1( "RA_MAT" , cMatricula )
	EndIf
	If !Empty( cNombre ) // Filtro Nombre
		cFiltro += "AND SRA." + RANGESX1( "RA_NOME" , cNombre )
	EndIF

	// Filtro para Situaciones
	For nReg := 1 To Len( cSituacion )
		CSitQuery += "'" + Subs( cSituacion , nReg , 1 ) + "'"
		If ( nReg + 1 ) <= Len( cSituacion )
			cSitQuery += ","
		Endif
	Next nReg

	For nReg := 1 To Len(cCategoria )
		cCatQuery += "'" + Subs( cCategoria , nReg , 1 ) + "'"
		If ( nReg + 1 ) <= Len( cCategoria )
			cCatQuery += ","
		Endif
	Next nReg
	
	cConceptos = Alltrim(cConceptos)
	cCncpto := Subs(cConceptos,Len(cConceptos),Len(cConceptos)-1)
	If cCnCpto == ';'
		cCncpto := Subs(cConceptos,1,Len(cConceptos)-1)
	EndIf

	oReport:CTITLE := STR0001+" " +STR0020+cRoteiro+" "+STR0021+" "+cPeriodo1+" "+cPago1+" "+STR0022+cPeriodo2+" "+cPago2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica que exista el periodo en RCH y define ³
	//³ que tabla se usará SRC o SRD, en caso de que   ³
	//³ no se encuentren datos manda un                ³
	//³ Aviso informando que no hay datos a comparar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If bImprimir
		Dbselectarea("RCH")
		RCH ->(DBSetOrder(1))
		RCH ->(	Dbseek(xFilial("RCH")+cProceso+cPeriodo1+cPago1+cRoteiro)) // Determina si el Periodo 1 esta Abierto o Cerrado

		If (Empty(RCH->RCH_DTFECH) .AND.(!EOF()))
			cPrefx    := "RC"    //  Valor si es periodo1 abierto
			cAliasAux := "SRC"
			cStPer1 :="A"
		Else
			If !EOF()
				cPrefx    := "RD"    //  Valor si es periodo1 cerrado
				cAliasAux := "SRD"
				cStPer1 := "C"
				bImprimir := .t.
			Else
				bImprimir := .f.  // Si no encuentra datos en RCH manda un Aviso
				Aviso( STR0024,STR0023+cPeriodo1+" "+cPago1, {"Ok"} )
			EndIf
		EndIf
	EndIf
  
	If bImprimir
		RCH ->(DBSetOrder(1))
		RCH ->(	Dbseek(xFilial("RCH")+cProceso+cPeriodo2+cPago2+cRoteiro)) // Determina si el Periodo 2 esta Abierto o Cerrado

		If Empty(RCH->RCH_DTFECH) .AND.(!EOF())
			cPrefx2     := "RC"    //  Valor si es periodo2 abierto
			cAliasAux2  := "SRC"
			cStPer2 +="A"
		Else
			If !EOF()
				cPrefx2    := "RD"    //  Valor si es periodo2 cerrado
				cAliasAux2 := "SRD"
				cStPer2 := "C"
			Else
				bImprimir := .f.     // Si no encuentra datos en RCH manda un Aviso
				Aviso( STR0024,STR0023+cPeriodo2+" "+cPago2, {"Ok"} )
			EndIf
		EndIf
	EndIf

	If bImprimir
		// Valida que existan datos en los periodos
		// Arma el Query para el primer periodo
		cQuery := "SELECT  RV_COD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC, " + cPreFx + "_HORAS, " + cPreFx + "_VALOR"
		cQuery += "	FROM " + RetSqlName("SRV") + " SRV, "	+ RetSqlName("SRA") + " SRA "
		cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
		cQuery += "           "+cAliasAux+"."+cPrefx+"_FILIAL     = SRA.RA_FILIAL       AND "
		cQuery += "			  "+cAliasAux+"."+cPrefx+"_MAT        = SRA.RA_MAT         AND "
		cQuery += "	  		  ("+cAliasAux+"."+cPrefx+"_PERIODO    = '"+cPeriodo1+"')  AND "
		cQuery += "	  		  ("+cAliasAux+"."+cPrefx+"_SEMANA    = '"+cPago1+"')  AND "
		cQuery += "	   		  "+cAliasAux+"."+cPrefx+"_ROTEIR     = '"+cRoteiro+"'     AND "

		If !Empty(cCncpto)
			cCpto := cAliasAux+"."+RANGESX1(cPreFx+"_PD"  ,cCnCpto)  // Filtro Conceptos
			cQuery += cCpto + "  AND "
		EndIf

		cQuery += "	         "+cAliasAux+".D_E_L_E_T_ = ' ' "
		cQuery += "		WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
		cQuery += "       SRV.RV_COD ="+cAliasAux+"."+cPrefx+"_PD     AND  "
		cQuery += "			  SRA.RA_CATFUNC	IN	("+cCatQuery+") 	AND "
		cQuery += "			  SRA.RA_PROCES      =  '"+cProceso+"' 	AND "
		cQuery += "	 		  SRA.D_E_L_E_T_     = ' '       AND "
		cQuery += "	 		  SRV.D_E_L_E_T_     = ' '      "
		If !Empty(cFiltro)    // Agrega los filtros al Query
			cQuery += cFiltro
		EndIf

		cQuery  := ChangeQuery(cQuery) /// Carga Query

		If Select(cQrySRA) > 0
			(cQrySRA)->( DBCloseArea() )
		EndIf
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
		Count To nTotalR

		If nTotalR == 0
			Aviso( STR0024,STR0023+cPeriodo1+" "+cPago1, {"Ok"} )
			bImprimir := .f.
		Else
			/// Valida si Existen datos en el segundo Periodo
			(cQrySRA)->( DBCloseArea() )
			cQueryA := cQuery

			/// Armado del Query para el periodo 2
			cQuery := "SELECT  RV_COD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC,"+cPreFx2+"_HORAS, "+cPreFx2+"_VALOR"
			cQuery += "	FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA "
			cQuery += "	INNER JOIN " + RetSqlName(cAliasAux2) + " "+cAliasAux2+" ON "
			cQuery += "           "+cAliasAux2+"."+cPrefx2+"_FILIAL     = SRA.RA_FILIAL       AND "
			cQuery += "			  "+cAliasAux2+"."+cPrefx2+"_MAT        = SRA.RA_MAT         AND "
			cQuery += "	  		  ("+cAliasAux2+"."+cPrefx2+"_PERIODO    = '"+cPeriodo2+"')  AND "
			cQuery += "	  		  ("+cAliasAux2+"."+cPrefx2+"_SEMANA    = '"+cPago2+"')  AND "
			cQuery += "	   		  "+cAliasAux2+"."+cPrefx2+"_ROTEIR     = '"+cRoteiro+"'     AND "

			If !Empty(cCncpto)
				cCpto := cAliasAux2+"."+RANGESX1(cPreFx2+"_PD"  ,cCnCpto)  // Filtro Conceptos
				cQuery += cCpto + "  AND "
			EndIf

			cQuery += "	         "+cAliasAux2+".D_E_L_E_T_ = ' ' "
			cQuery += "		WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
			cQuery += "       SRV.RV_COD ="+cAliasAux2+"."+cPrefx2+"_PD     AND  "
			cQuery += "			  SRA.RA_CATFUNC	IN	("+cCatQuery+") 	AND "
			cQuery += "			  SRA.RA_PROCES      =  '"+cProceso+"' 	AND "
			cQuery += "	 		  SRA.D_E_L_E_T_     = ' '      AND"
			cQuery += "	 		  SRV.D_E_L_E_T_     = ' '      "

			If !Empty(cFiltro)    // Agrega los filtros al Query
				cQuery += cFiltro
			EndIf

			cQuery  := ChangeQuery(cQuery) // Carga Query

			If Select(cQrySRA) > 0
				(cQrySRA)->( DBCloseArea() )
			EndIf

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
			Count To nTotalR  	// Cuenta el total de registros en el Query

			If nTotalR == 0
				Aviso( STR0024,STR0023+cPeriodo2+" "+cPago2, {"Ok"} )
				bImprimir := .f.
			Else
				(cQrySRA)->( DBCloseArea() )
				bImprimir := .t.
				cQueryB := cQuery
			EndIf
		Endif
	EndIf

	If bImprimir    /// Arma el Query para el Informe si los dos periodos tienen datos para comparar
		DEFINE CELL NAME "REFPER1"    OF oSection1 ALIAS cString TITLE oemToansi(STR0010) SIZE 25 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALORPER1"  OF oSection1 ALIAS cString TITLE oemToansi(STR0011) SIZE 20 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "REFPER2"    OF oSection1 ALIAS cString TITLE oemToansi(STR0012) SIZE 25 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALORPER2"  OF oSection1 ALIAS cString TITLE oemToansi(STR0013) SIZE 20 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "DIF_HORAS"  OF oSection1 ALIAS cString TITLE oemToansi(STR0014) SIZE 25 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "PORC_HORAS" OF oSection1 ALIAS cString TITLE oemToansi(STR0015) SIZE 25 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "DIF_VALOR"  OF oSection1 ALIAS cString TITLE oemToansi(STR0016) SIZE 25 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "PORC_VALOR" OF oSection1 ALIAS cString TITLE oemToansi(STR0017) SIZE 25 PICTURE cPicture ALIGN RIGHT HEADER ALIGN RIGHT

		If cStPer1 == cStPer2    //// Armado de Query si los datos estan en la misma tabla (SRD ó SRC) dependiendo si los periodos estan abiertos o cerrados
			cQuery := " SELECT  RV_COD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC,"+cPreFx+"_ENTIDAD  AS ENTIDAD "
			cQuery += ", SUM(CASE WHEN "+cPreFx+"_PERIODO = '"+cPeriodo1+"' AND "+cPreFx+"_SEMANA = '"+cPago1+"' THEN "+cPreFx+"_HORAS ELSE 0 END) AS REFPER1"  //Column 09
			cQuery += ", SUM(CASE WHEN "+cPreFx+"_PERIODO = '"+cPeriodo1+"' AND "+cPreFx+"_SEMANA = '"+cPago1+"' THEN "+cPreFx+"_VALOR ELSE 0 END) AS REFVAL1 " //Column 10
			cQuery += ", SUM(CASE WHEN "+cPreFx2+"_PERIODO = '"+cPeriodo2+"' AND "+cPreFx2+"_SEMANA = '"+cPago2+"' THEN "+cPreFx2+"_HORAS ELSE 0 END)AS REFPER2 " 	//Column 11
			cQuery += ", SUM(CASE WHEN "+cPreFx2+"_PERIODO = '"+cPeriodo2+"' AND "+cPreFx2+"_SEMANA = '"+cPago2+"' THEN "+cPreFx2+"_VALOR ELSE 0 END)AS REFVAL2 "  //Column 12

			cQuery += "	FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA "
			cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
			cQuery += "           "+cAliasAux+"."+cPrefx+"_FILIAL     = SRA.RA_FILIAL      AND "
			cQuery += "			  "+cAliasAux+"."+cPrefx+"_MAT        = SRA.RA_MAT         AND "
			cQuery += "	  		  ("+cAliasAux+"."+cPrefx+"_PERIODO    = '"+cPeriodo1+"' OR "+cAliasAux+"."+cPrefx2+"_PERIODO    = '"+cPeriodo2+"')     AND "
			cQuery += "	   		  "+cAliasAux+"."+cPrefx+"_ROTEIR     = '"+cRoteiro+"'              AND "
			
			cCpto := cAliasAux+"."+RANGESX1(cPrefx+"_PD"  ,cCnCpto)  // Filtro Conceptos

			If !Empty(cCncpto)
				cCpto := cAliasAux2+"."+RANGESX1(cPreFx2+"_PD"  ,cCnCpto)  // Filtro Conceptos
				cQuery += cCpto + " AND "
			EndIf

			cQuery += "	   		  "+cAliasAux+".D_E_L_E_T_ = ' ' "
			cQuery += "		WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
			cQuery += "      SRV.RV_COD ="+cAliasAux+"."+cPreFX+"_PD    AND"

		Else  // Armado de Query si los datos se encuentran en diferentes tablas (SRD y SRC) dependiendo cual periodo esta abierto y cual cerrado
			If  !Empty(cSucursal)
				cPrefxSuc  :=  " "+RANGESX1(cPrefx+"_FILIAL"  ,cSucursal)  // Filtro sucursal
				cPrefx2Suc :=  " "+RANGESX1(cPrefx2+"_FILIAL"  ,cSucursal)  
			Endif
			
			cQuery :=" SELECT RV_COD, RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG,RA_CC,ENTIDAD,REFPER1,REFVAL1,REFPER2,REFVAL2 "
			cQuery +="            FROM " + RetSqlName("SRV")+  " SRV, " + RetSqlName("SRA")+ " SRA,( "
			cQuery +=" SELECT "+cPrefx+"_FILIAL AS FILIAL,"+cPrefx+"_PD AS CODIGO,"+cPrefx+"_MAT AS MATRICULA,"+cPrefx+"_ENTIDAD AS ENTIDAD,"
			cQuery +=" SUM("+cPrefx+"_HORAS) AS REFPER1,"
			cQuery +=" SUM("+cPrefx+"_VALOR) AS REFVAL1,"
			cQuery +=" SUM("+cPrefx2+"_HORAS) AS REFPER2,"
			cQuery +=" SUM("+cPrefx2+"_VALOR) AS REFVAL2"
			cQuery +="  FROM  "+RetSqlName(cAliasAux)+" "+cAliasAux+"   LEFT OUTER JOIN  "+RetSqlName(cAliasAux2)+" "+cAliasAux2
			cQuery +="  ON   "+cPrefx+"_FILIAL = "+cPrefx2+"_FILIAL"
			cQuery +="  AND  "+cPrefx+"_PD = "+cPrefx2+"_PD"
			cQuery +="  AND  "+cPrefx+"_MAT = "+cPrefx2+"_MAT"
			cQuery +="  AND  "+cPrefx2+"_PERIODO = '"+cPeriodo2+"'"
			cQuery +="  AND  "+cPrefx2+"_SEMANA = '"+cPago2+"'"
			cQuery +="  AND  "+cPrefx2+"_ROTEIR = '"+cRoteiro+"'"
			If  !Empty(cSucursal)
				cQuery +="  AND "+cPrefx2Suc 
			Else
				cQuery +="  AND  "+cPrefx2+"_FILIAL = '"+cFilialSRA+"'"
			Endif
			cQuery +="  AND  "+cAliasAux2+".D_E_L_E_T_ = ' ' "
			cQuery +="  WHERE "+cPrefx+"_PERIODO = '"+cPeriodo1+"'"
			cQuery +="  AND  "+cPrefx+"_SEMANA = '"+cPago1+"'"
			cQuery +="  AND  "+cPrefx+"_ROTEIR = '"+cRoteiro+"'"
			If  !Empty(cSucursal)
				cQuery +="  AND "+cPrefxSuc
			Else
				cQuery +="  AND  "+cPrefx+"_FILIAL = '"+cFilialSRA+"'"
			Endif
			cQuery +="  AND  "+cPrefx2+"_VALOR IS NULL "

			If !Empty(cCncpto)
				cCpto := cAliasAux+"."+RANGESX1(cPrefx+"_PD"  ,cCnCpto)  // Filtro Conceptos
				cQuery += "  AND " + cCpto 
			EndIf

			cQuery +="  AND "+cAliasAux+".D_E_L_E_T_ = ' ' "
			cQuery +=" GROUP BY "+cPrefx+"_FILIAL,"+cPrefx+"_PD,"+cPrefx+"_MAT,"+cPrefx+"_ENTIDAD"
			cQuery +="  UNION ALL"
			cQuery +=" SELECT "+cPreFx2+"_FILIAL AS FILIAL,"+cPreFx2+"_PD AS CODIGO,"+cPreFx2+"_MAT AS MATRICULA,"+cPrefx2+"_ENTIDAD AS ENTIDAD,"
			cQuery +=" SUM("+cPrefx+"_HORAS) AS REFPER1,"
			cQuery +=" SUM("+cPrefx+"_VALOR) AS REFVAL1,"
			cQuery +=" SUM("+cPrefx2+"_HORAS) AS REFPER2,"
			cQuery +=" SUM("+cPrefx2+"_VALOR) AS REFVAL2"
			cQuery +="  FROM  "+RetSqlName(cAliasAux2)+" "+cAliasAux2+"   LEFT OUTER JOIN  "+RetSqlName(cAliasAux)+" "+cAliasAux
			cQuery +="  ON   "+cPrefx+"_FILIAL = "+cPrefx2+"_FILIAL"
			cQuery +="  AND  "+cPrefx+"_PD = "+cPrefx2+"_PD"
			cQuery +="  AND  "+cPrefx+"_MAT = "+cPrefx2+"_MAT"
			cQuery +="  AND  "+cPrefx+"_PERIODO = '"+cPeriodo1+"'"
			cQuery +="  AND  "+cPrefx+"_SEMANA = '"+cPago1+"'"
			cQuery +="  AND  "+cPrefx+"_ROTEIR = '"+cRoteiro+"'"
			If  !Empty(cSucursal)
				cQuery +="  AND "+cPrefxSuc 
			Else
				cQuery +="  AND  "+cPrefx+"_FILIAL = '"+cFilialSRA+"'
			Endif
			cQuery +="  AND  "+cAliasAux+".D_E_L_E_T_ = ' ' "
			cQuery +="  WHERE "+cPrefx2+"_PERIODO = '"+cPeriodo2+"'"
			cQuery +="  AND  "+cPrefx2+"_SEMANA = '"+cPago2+"'"
			cQuery +="  AND  "+cPrefx2+"_ROTEIR = '"+cRoteiro+"' " 

			If !Empty(cCncpto)
				cCpto := cAliasAux2+"."+RANGESX1(cPreFx2+"_PD"  ,cCnCpto)  // Filtro Conceptos
				cQuery +=  " AND " + cCpto
			EndIf

			If  !Empty(cSucursal)
				cQuery +="  AND "+cPrefx2Suc 
			Else
				cQuery +="  AND  "+cPrefx2+"_FILIAL = '"+cFilialSRA+"'"
			Endif
			cQuery +="  AND  "+cAliasAux2+".D_E_L_E_T_ = ' '"
			cQuery +="  GROUP BY "+cPrefx2+"_FILIAL,"+cPrefx2+"_PD,"+cPrefx2+"_MAT,"+cPrefx2+"_ENTIDAD) cResult"
			cQuery +="	 WHERE SRA.RA_FILIAL = FILIAL  AND SRA.RA_MAT = MATRICULA  AND  SRV.RV_COD = CODIGO "
			cQuery +="  AND  SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "

		EndIf

		cQuery +="       SRV.RV_FILIAL = '"+cFilialSRV+"'            AND  "
		If  Empty(cSucursal)
			cQuery +="       SRA.RA_FILIAL = '"+cFilialSRA+"'            AND  "
		Endif
		cQuery += "			  SRA.RA_CATFUNC	IN	("+cCatQuery+") 	  AND "
		cQuery += "			  SRA.RA_PROCES      =  '"+cProceso+"'  AND "
		cQuery += "	 		  SRA.D_E_L_E_T_     = ' '      AND"
		cQuery += "	 		  SRV.D_E_L_E_T_     = ' '      "

		If !Empty(cFiltro)    // Agrega los filtros al Query
			cQuery += cFiltro
		EndIf

		If cStPer1 == cStPer2
			cQuery += " GROUP BY RV_COD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC,"+cPreFx+"_ENTIDAD "
		EndIf

		cQuery += "  ORDER BY RA_FILIAL,RV_COD,RA_MAT"
		cQuery := ChangeQuery(cQuery) ///    Carga Query

		If Select(cQrySRA) > 0
			(cQrySRA)->( DBCloseArea() )
		EndIf

		nReg := 0
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
		Count To nReg

		If lCorpManage  // Totaliza
			DEFINE BREAK oBreakEFil OF oReport WHEN oSection2:Cell("RV_COD") // Totales por Concepto
			DEFINE FUNCTION NAME "REFPER1"    FROM oSection1:Cell("REFPER1" )   FUNCTION SUM  BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "VALORPER1"  FROM oSection1:Cell("VALORPER1" ) FUNCTION SUM  BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "REFPER2"    FROM oSection1:Cell("REFPER2" )   FUNCTION SUM  BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "VALORPER2"  FROM oSection1:Cell("VALORPER2" ) FUNCTION SUM  BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "DIF_HORAS"  FROM oSection1:Cell("DIF_HORAS" ) FUNCTION SUM  BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "DIF_VALOR"  FROM oSection1:Cell("DIF_VALOR" ) FUNCTION SUM  BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE cPicture
			oBreakEFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0019)})
			oBreakEFil:SetTotalText({ || cTitEFil })
			oBreakEFil:SetTotalInLine(.F.)

			DEFINE BREAK oBreakFil OF oReport   WHEN oSection1:Cell("RA_FILIAL") // Total General
			DEFINE FUNCTION NAME "REFPER1"    FROM oSection1:Cell("REFPER1" )   FUNCTION SUM  BREAK oBreakFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "VALORPER1"  FROM oSection1:Cell("VALORPER1" ) FUNCTION SUM  BREAK oBreakFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "REFPER2"    FROM oSection1:Cell("REFPER2" )   FUNCTION SUM  BREAK oBreakFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "VALORPER2"  FROM oSection1:Cell("VALORPER2" ) FUNCTION SUM  BREAK oBreakFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "DIF_HORAS"  FROM oSection1:Cell("DIF_HORAS" ) FUNCTION SUM  BREAK oBreakFil NO END SECTION NO END REPORT PICTURE cPicture
			DEFINE FUNCTION NAME "DIF_VALOR"  FROM oSection1:Cell("DIF_VALOR" ) FUNCTION SUM  BREAK oBreakFil NO END SECTION NO END REPORT PICTURE cPicture
			oBreakFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0018)})
			oBreakFil:SetTotalText({ || cTitEFil })
			oBreakFil:SetTotalInLine(.F.)
		EndIf

		CursorArrow()
		oReport:SetMeter(nReg)
		( cQrySRA )->(DBGOTOP()) // posiciona al primer registro del archivo de datos

		cCod  := ""
		While ( cQrySRA )->(!eof())	 //--- Impresión del reporte
			oReport:IncMeter()
			oSection1:INIT()
			oSection1:cell("RA_MAT"):SetValue(( cQrySRA )->(RA_MAT))
			oSection1:cell("RA_NOME"):SetValue(( cQrySRA )->(RA_NOME))
			oSection1:cell("RA_RG"):SetValue(( cQrySRA )->(RA_RG))
			oSection1:cell("RA_CC"):SetValue(( cQrySRA )->(RA_CC))
			oSection1:cell("RD_ENTIDAD"):SetValue(( cQrySRA )->(ENTIDAD))

			If bImprimir
				oSection1:cell("REFPER1"):SetValue(( cQrySRA )->(REFPER1))
				oSection1:cell("VALORPER1"):SetValue(( cQrySRA )->(REFVAL1))
				oSection1:cell("REFPER2"):SetValue(( cQrySRA )->(REFPER2))
				oSection1:cell("VALORPER2"):SetValue(( cQrySRA )->(REFVAL2))
				oSection1:cell("DIF_HORAS"):SetValue((( cQrySRA )->(REFPER2) - ( cQrySRA )->(REFPER1)))
				oSection1:cell("PORC_HORAS"):SetValue(IIF(( cQrySRA )->(REFPER1) <> 0,(((( cQrySRA )->(REFPER2) / ( cQrySRA )->(REFPER1))) - 1)*100,0))
				oSection1:cell("DIF_VALOR"):SetValue((( cQrySRA )->(REFVAL2) - ( cQrySRA )->(REFVAL1)))
				oSection1:cell("PORC_VALOR"):SetValue(IIF(( cQrySRA )->(REFVAL1) <> 0,(((( cQrySRA )->(REFVAL2) / ( cQrySRA )->(REFVAL1))) - 1)*100,0))
			EndIf
			oSection1:PrintLine()

			If cCod <> (cQrySRA)->(RV_COD)
				oSection2:Init()
				oSection2:cell("RV_COD"):SetValue(( cQrySRA )->(RV_COD))
				oSection2:cell("RV_DESC"):SetValue(( cQrySRA )->(RV_DESC))
				oSection2:PrintLine()
				oSection2:Finish()
				cCod := (cQrySRA)->(RV_COD)
			EndIf
			oSection1:Finish()
			( cQrySRA )->(dbSkip())
		EndDo
	EndIf  /// Endif de la validacion de periodos

	If Select(cQrySRA) > 0
		(cQrySRA)->( DBCloseArea() )
	EndIf

Return
