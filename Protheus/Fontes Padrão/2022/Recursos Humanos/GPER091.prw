#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'
#INCLUDE 'GPER091.CH'

/*/{Protheus.doc} GPER091
//	Relatório para impressão da Memória de Cálculo do Funcionário.
@author esther.viveiro
@since 12/01/2018
@version P12
/*/
Function GPER091()
Local	aArea 	:= GetArea()
Local	oReport:= Nil

	If ChkFile('RFT')
		oReport := GetReport()
	
		if(oReport <> Nil)
			oReport:PrintDialog()
		endIf
	
		oReport := Nil
		RestArea(aArea)
	Else
		cMensagem := CRLF + OemToAnsi(STR0018) + CRLF
		cMensagem += OemToAnsi(STR0019) + CRLF + OemToAnsi(STR0020)
		Help("",1,OemToAnsi(STR0021), Nil,cMensagem, 1, 0 )
	EndIf
Return


/*/{Protheus.doc} GetReport
//	Definição do relatório, seções e células.
@author esther.viveiro
@since 12/01/2018
@version P12
/*/
Static Function GetReport()
Local oReport	:= Nil
Local oSecFil	:= Nil
Local oSecCab		:= Nil
Local oSecItems	:= Nil

Local cMyAlias	:= GetNextAlias()
Local cRptTitle	:= OemToAnsi(STR0001)//'Memória de Cálculo por Funcionário'
Local cRptDescr	:= OemToAnsi(STR0002)//'Impressão do log de Memória de Cálculo gerado por Funcionário a partir das rotinas de cálculo. O relatório é filtrado por data e hora de geração.'
Local aOrderBy	:= {}
Local cNomePerg	:=	"GPER091"

	aAdd(aOrderBy,OemToAnsi(STR0003))//'1 - Filial + Matrícula

	Pergunte(cNomePerg,.F.)

	DEFINE REPORT oReport NAME "GPER091" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cMyAlias,cNomePerg)} DESCRIPTION cRptDescr
	oReport:nFontBody:=8.5
	oReport:cFontBody:="Arial"
	oReport:nDevice := 6 //pdf pre-selecionado

	DEFINE SECTION oSecFil	OF oReport TITLE cRptTitle	TABLES "RFT","SRA" ORDERS aOrderBy
		DEFINE CELL NAME "RFT_FILIAL"	OF 	oSecFil ALIAS "RFT" 
		DEFINE CELL NAME "RFT_MAT"	OF 	oSecFil ALIAS "RFT"
		DEFINE CELL NAME "RA_NOME"	OF 	oSecFil ALIAS "SRA"
		DEFINE CELL NAME "RA_ADMISSA"	OF 	oSecFil ALIAS "SRA"
		DEFINE CELL NAME "Situação"	OF 	oSecFil BLOCK {|| If(Empty((cMyAlias)->RFT_SITFUN),OemToAnsi(STR0004),If((cMyAlias)->RFT_SITFUN=="A",OemToAnsi(STR0005),If((cMyAlias)->RFT_SITFUN=="F",OemToAnsi(STR0006),If((cMyAlias)->RFT_SITFUN=="T",OemToAnsi(STR0007),OemToAnsi(STR0008))))) }
		oSecFil:SetColSpace(05)

	DEFINE SECTION oSecCab	OF oSecFil TITLE ''	TABLES "RFT"
		DEFINE CELL NAME "RFT_DATA"	OF 	oSecCab ALIAS "RFT"
		DEFINE CELL NAME "RFT_HORA"	OF 	oSecCab ALIAS "RFT"
		DEFINE CELL NAME "RFT_USER"	OF 	oSecCab ALIAS "RFT"
		DEFINE CELL NAME "RFT_PROCES"	OF 	oSecCab ALIAS "RFT"
		DEFINE CELL NAME "RFT_ROTEIR"	OF 	oSecCab ALIAS "RFT"
		DEFINE CELL NAME "RFT_PERIOD"	OF 	oSecCab ALIAS "RFT"
		DEFINE CELL NAME "RFT_SEMANA"	OF 	oSecCab ALIAS "RFT"
		oSecCab:SetColSpace(02)
		oSecCab:SetLeftMargin(2)

	DEFINE SECTION oSecItems	OF oSecCab TITLE ''	TABLES "RFV"
		DEFINE CELL NAME "RFV_SEQUEN" 	OF 	oSecItems ALIAS "RFV" SIZE(05)
		DEFINE CELL NAME "Descrição" 	OF 	oSecItems SIZE(40) BLOCK {|| fDesc("RC2",Substr( (cMyAlias)->RFV_FORMUL, 3 , 7 ),"RC2_DESC",,,2)}
		DEFINE CELL NAME "RFV_FORMUL" 	OF 	oSecItems ALIAS "RFV" SIZE(17)
		oSecItems:SetLineStyle(.T.)
		oSecItems:SetLeftMargin(2)

	DEFINE SECTION oSecItems2	OF oSecItems TITLE ''	TABLES "RFV"
		DEFINE CELL NAME "RFV_LOG" 	OF 	oSecItems2 ALIAS "RFV"
		oSecItems2:SetLeftMargin(4)
		oSecItems2:SetHeaderSection(.F.)

Return oReport


/*/{Protheus.doc} PrintReport
//	Impressão do relatório, execução da query de consulta.
@author esther.viveiro
@since 12/01/2018
@version P12
@param oReport, object, Informações da estrutura do relatório.
@param cMyAlias, caracters, Alias utilizado para a query de consulta.
@param cNomePerg, caracters, Nome do grupo de perguntas do relatório.
/*/
Static Function PrintReport(oReport,cMyAlias,cNomePerg)
	Local oSecFil		:= oReport:Section(1)
	Local oSecCab		:= oSecFil:Section(1)
	Local oSecItems	:= oSecCab:Section(1)
	Local oSecItems2	:= oSecItems:Section(1)
	Local oBreakItems	:= Nil
	Local oBreakFil	:= Nil
	Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
	Local cLayoutGC 	:= ''
	Local nStartEmp	:= 0
	Local nStartUnN	:= 0
	Local nEmpLength	:= 0
	Local nUnNLength	:= 0	
	Local cTitFil		:= ''
	Local cTitUniNeg	:= ''
	Local cTitEmp		:= ''
	Local cProcesso	:= ""
	Local cRoteiro	:= ""
	Local cPeriodo	:= ""
	Local cSemana	:= ""
	Local cData	:= ""
	Local cHora	:= ""

	DEFINE BREAK oBreakItems OF oReport WHEN {|| (cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT + (cMyAlias)->RFV_SEQUEN}
	oBreakItems:OnBreak({|x| oReport:ThinLine(), oReport:SkipLine(),})

	//QUEBRA FILIAL
	DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->RFT_FILIAL}	
	oBreakFil:OnBreak({|x|cTitFil := OemToAnsi(STR0009) + x, oReport:ThinLine()})
	oBreakFil:SetTotalText({||cTitFil})
	oBreakFil:SetTotalInLine(.T.)
	DEFINE FUNCTION NAME "DA" FROM oSecFil:Cell("RFT_MAT") TITLE OemToAnsi(STR0010) FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT

	If oReport:nDevice == 4 //se planilha
		oSecItems:SetLineStyle(.F.)
		oSecItems2:SetPageBreak(.T.)
	EndIf

	If lCorpManage
		cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		nStartEmp	:= At("E",cLayoutGC)
		nStartUnN	:= At("U",cLayoutGC)
		nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
		nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
	EndIf

	MakeSqlExpr(cNomePerg)
	cProcesso	:= "%'" + MV_PAR01 + "'%"
	cRoteiro	:= "%'" + MV_PAR02 + "'%"
	cPeriodo	:= "%'" + MV_PAR03 + "'%"
	cSemana	:= "%'" + MV_PAR04 + "'%"
	cData	:= "%'" + DtoS(MV_PAR05) + "'%"
	cHora	:= "%'" + MV_PAR06 + "'%"

	BEGIN REPORT QUERY oSecFil
		BeginSql alias cMyAlias	
			SELECT RFT_FILIAL, RFT_MAT, RFT_PROCES, RFT_PERIOD, RFT_SEMANA, RFT_ROTEIR, RFT_DATA, RFT_HORA, RFT_SITFUN, RFT_USER,
					RFV_SEQUEN, RFV_FORMUL, RFV_LOG,
					RA_NOME, RA_ADMISSA
			FROM %table:RFT% RFT
				INNER JOIN %table:SRA% SRA ON
					RFT_FILIAL = RA_FILIAL AND RFT_MAT = RA_MAT
				INNER JOIN %table:RFV% RFV ON 
					RFT_FILIAL = RFV_FILIAL AND RFT_MAT = RFV_MAT AND RFT_PROCES = RFV_PROCES AND
					RFT_PERIOD = RFV_PERIOD AND RFT_SEMANA = RFV_SEMANA AND RFT_ROTEIR = RFV_ROTEIR  AND RFT_DATA = RFV_DATA AND RFT_HORA = RFV_HORA
			WHERE 
				RFT_PROCES = %exp:cProcesso% AND RFT_PERIOD = %exp:cPeriodo%  AND RFT_SEMANA = %exp:cSemana%  AND RFT_ROTEIR = %exp:cRoteiro%  AND RFT_DATA = %exp:cData%  AND RFT_HORA = %exp:cHora% 
			ORDER BY RFT_FILIAL, RFT_MAT, RFT_PROCES, RFT_PERIOD, RFT_SEMANA, RFT_ROTEIR, RFT_DATA, RFT_HORA, RFV_SEQUEN
		EndSql
	END REPORT QUERY oSecFil PARAM MV_PAR07, MV_PAR08 //parametros ranges

	DEFINE BREAK oBreakItems OF oReport WHEN {|| ((cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT)}
	oBreakItems:SetTotalInLine(.T.)	

	oSecCab:SetParentQuery()
	oSecCab:SetParentFilter({|cParam| ((cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT) == cParam},{|| ((cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT) })

	oSecItems:SetParentQuery()
	oSecItems:SetParentFilter({|cParam| ((cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT) == cParam},{|| ((cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT) })


	oSecItems2:SetParentQuery()
	oSecItems2:SetParentFilter({|cParam| ((cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT + (cMyAlias)->RFV_SEQUEN ) == cParam},{|| ((cMyAlias)->RFT_FILIAL + (cMyAlias)->RFT_MAT + (cMyAlias)->RFV_SEQUEN ) })

	oSecFil:Print()
Return Nil


/*/{Protheus.doc} Gp091Fields
//	Função de Consulta Específica (F3) para preenchimento das perguntas Período, Nr.Pagamento, Data e Hora
@author esther.viveiro
@since 12/01/2018
@version P12
@param cProcLog, caracters, Código do Processo selecionado.
@param cRotLog, caracters, Código do Roteiro selecionado.
/*/
Function Gp091Fields(cProcLog,cRotLog)
Local aArea		:= GetArea()
Local aObjCoords:= {}
Local aAdvSize	:= {}
Local aInfoAdvSize	:= {}
Local aObjSize 	:= {}
Local cAliasQry	:= "QRFT"
Local cWhere	:= ""
Local lOK     	:= .F.
Local nPosLbxA	:= 0.00
Local oPesq		:= NIL
Local oDlg		:= NIL
Local oLbxA		:= NIL
Local nOpca		:= 0

Local bSet15 := {|| NIL}
Local bSet24 := {|| NIL}

	aLbxA := {}
	VAR_IXB := {"","","",""}

	cWhere := "%"
	cWhere += "RFT_PROCES = '" + cProcLog + "' AND "
	cWhere += "RFT_ROTEIR = '" + cRotLog + "' "
	cWhere += "%"

	BeginSql alias cAliasQry
		SELECT	DISTINCT RFT_FILIAL, RFT_PROCES, RFT_PERIOD, RFT_SEMANA, RFT_DATA, RFT_HORA
		FROM 		%table:RFT% RFT
		WHERE 		%exp:cWhere% AND
					RFT.%NotDel%
		ORDER BY RFT_DATA DESC, RFT_HORA DESC
	EndSql

	While (cAliasQry)->( !Eof() )
		(cAliasQry)->( aAdd( aLbxA, { RFT_PERIOD, RFT_SEMANA, DtoC(StoD(RFT_DATA)), RFT_HORA, RFT_FILIAL, RFT_PROCES } ) )
		(cAliasQry)->( dbSkip() )
	EndDo

	If Empty(aLbxA)
		aAdd( aLbxA , {'','','','','','','' } )
	EndIf

	( cAliasQry )->( dbCloseArea() )

	aAdvSize		:= MsAdvSize( , .T., 390)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 10 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
	DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0011) PIXEL		// "Selecione o Log da Memória de Cálculo"
		//Período, Nr.Pagamento, Data Geração, Hora Geração, Filial, Processo
		@ aObjSize[1,1], aObjSize[1,2] LISTBOX oLbxA FIELDS HEADER OemToAnsi(STR0012), OemToAnsi(STR0013), OemToAnsi(STR0014), OemToAnsi(STR0015), OemToAnsi(STR0016), OemToAnsi(STR0017) SIZE aAdvSize[5]*0.47,aAdvSize[6]*0.38;	
		OF oDlg PIXEL ON DBLCLICK ( lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End() )

		oLbxA:SetArray(aLbxA) 
		oLbxA:bLine := { || {aLbxA[oLbxA:nAt,1],aLbxA[oLbxA:nAt,2],aLbxA[oLbxA:nAt,3],aLbxA[oLbxA:nAt,4],aLbxA[oLbxA:nAt,5],aLbxA[oLbxA:nAt,6]}}

		bSet15 := { || nOpca := 1, lOk := .T., nPosLbxA:=oLbxA:nAt,oDlg:End()}
		bSet24 := { || nOpca := 0, lOk := .F., oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, bSet15, bSet24))

	If ( lOk )
		VAR_IXB[1]	:= aLbxA[nPosLbxA,1]
		VAR_IXB[2]	:= aLbxA[nPosLbxA,2]
		VAR_IXB[3]	:= CtoD(aLbxA[nPosLbxA,3])
		VAR_IXB[4]	:= aLbxA[nPosLbxA,4]
		lVldCons	:= .F.
	EndIf

	RestArea( aArea )
	
Return lOk


/*/{Protheus.doc} Gp91VldPrc
//	Função para validacao do pergunte Processo
@author esther.viveiro
@since 12/01/2018
@version P12
@return lFound, logic, Indica se valor informado é válido.
/*/
Function Gp91VldPrc()
Local aArea	:= GetArea()
Local lFound	:= .F.
Local cProcLog	:= &(ReadVar())

	If !Empty(cProcLog)
		DbSelectArea("RCJ")
		DbSetOrder(1)
		If Empty(RCJ->RCJ_FILIAL)
		//na segunda vez que passa pela validação, após digitar periodo errado, a filial é perdida pois o DbSeek foi até o fim do arquivo.
			RCJ->(DbGoTop())
		EndIf
		If DbSeek(RCJ->RCJ_FILIAL + cProcLog)
			lFound := .T.
		Else
			Help(" ",1,"REGNOIS")
		EndIf
	Else
		Help(" ",1,"NVAZIO")
	EndIf

RestArea(aArea)
Return( lFound )


/*/{Protheus.doc} Gp91VldRot
//	Função para validacao dos perguntes
@author esther.viveiro
@since 12/01/2018
@version P12
@return lFound, logic, Indica se valor informado é válido.
/*/
Function Gp91VldRot()
Local aArea	:= GetArea()
Local lFound	:= .F.
Local cRotLog	:= &(ReadVar())

	If !Empty(cRotLog)
		DbSelectArea("SRY")
		DbSetOrder(1)
		If Empty(SRY->RY_FILIAL)
		//na segunda vez que passa pela validação, após digitar periodo errado, a filial é perdida pois o DbSeek foi até o fim do arquivo.
			SRY->(DbGoTop())
		EndIf
		If DbSeek(SRY->RY_FILIAL + cRotLog)
			lFound := .T.
		Else
			Help(" ",1,"REGNOIS")
		EndIf
	Else
		Help(" ",1,"NVAZIO")
	EndIf

RestArea(aArea)
Return( lFound )
