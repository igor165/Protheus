#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECA765.CH"

Static cTmpAlias := ""
Static oGSTmpTb

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA765
Monitor de Marcações de Atendentes
@sample 	TECA765()
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Function TECA765()

	Local cPerg := "TECA765"
	Local aArea := GetArea()

	Private cCadastro := STR0001 //"Monitor de Marcações de Atendentes"

	If AliasInDic("T40")
		DbSelectArea("T40")

		If Pergunte(cPerg,.T.)
    		AT765Brow()
		Endif	

		RestArea(aArea)
	Else
		Help( " ", 1, "TECA765", Nil, STR0004, 1 ) //"Tabela T40 não existe no dicionário de Dados"
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765Brow
Definicao do Objeto Browse
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765Brow(cPerg)

	Local oBrowse  := Nil
	Local aStru    := AT765aStru()
	Local bTimer   := {||AT765AtBrw(@oBrowse)}
	Local aColumns := {}
	Local aSeek     := {}

	oBrowse:= FWmBrowse():New()
	oBrowse:SetDataQuery(.F.)
	oBrowse:SetDataTable(.T.)

	At765Cria(@oBrowse)

	oBrowse:SetMenuDef("")
	oBrowse:SetDescription(cCadastro)

	oBrowse:AddLegend("T40_AGEINT $ 'S'" ,"BR_VERDE",   STR0002) //"Marcação Integrada"
	oBrowse:AddLegend("T40_AGEINT $ 'N '","BR_VERMELHO",STR0003) //"Marcação Não Integrada"

	aColumns := AT765aCols(aStru)
	oBrowse:SetColumns(aColumns)

	aAdd(aSeek, {TxDadosCpo('ABB_FILIAL')[1],{{'','C',TamSX3('ABB_FILIAL')[1],TamSX3('ABB_FILIAL')[2],TxDadosCpo('ABB_FILIAL')[1],PesqPict('ABB','ABB_FILIAL'),NIL}},1,.T.})
	aAdd(aSeek, {TxDadosCpo('ABB_CODTEC')[1],{{'','C',TamSX3('ABB_CODTEC')[1],TamSX3('ABB_CODTEC')[2],TxDadosCpo('ABB_CODTEC')[1],PesqPict('ABB','ABB_CODTEC'),NIL}},2, .T.})

	oBrowse:SetSeek(.T., aSeek) 

	oBrowse:SetTimer(bTimer, MV_PAR01 * 60000) // 60.000 aproximadamente 1 Minuto
	oBrowse:SetParam({||Pergunte(cPerg,.T.),AT765AtBrw(@oBrowse)})

	oBrowse:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765AtBrw
Criacao do Objeto Browse
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765AtBrw(oBrw)

	(At765Alias())->(DbCloseArea())

	At765Cria(@oBrw)

	oBrw:Refresh(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Alias
Retorna alias uso do browse
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Function At765Alias(cSetValue)

	If VALTYPE(cSetValue) == 'C'
		cTmpAlias := cSetValue
	EndIf

Return cTmpAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Alias
Retorna query uso do browse
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Function At765QryGen(aTmpStruct)

	Local cQuery   := ""
	Local aFiliais := {}
	Local cxFilTDV := " = '" + xFilial("TDV",cFilAnt) + "'"
	Local nX       := 0
	Local nTam     := 0

	If !Empty(MV_PAR02)
		aFiliais := StrTokArr(MV_PAR02,";")
		nTam := Len(aFiliais)-1
		cxFilTDV := "IN ("
		For nX := 1 to nTam
		    cxFilTDV += "'" + xFilial("TDV",aFiliais[nX]) +  "',"
		Next nX
		cxFilTDV := Substring(cxFilTDV,1,Len(cxFilTDV)-1)
		cxFilTDV += ")"
	Endif
	cQuery += " SELECT "
	For nX := 1 To Len(aTmpStruct)
		cQuery += aTmpStruct[nX,1] + ","
	Next nX
	cQuery := Substring(cQuery,1,Len(cQuery)-1)
	// Integração de marcações
	cQuery += " FROM "+ RetSqlName('T40') + " T40 "
	// Funcionários
	cQuery += " INNER JOIN "+RetSqlName('SRA')+" SRA ON  SRA.RA_FILIAL='"+xFilial("SRA")+"' AND SRA.RA_PIS = T40.T40_CODPIS  AND SRA.D_E_L_E_T_ = '' "
	// Atendentes
	cQuery += " INNER JOIN "+RetSqlName('AA1')+" AA1 ON  AA1.AA1_FILIAL='"+xFilial("AA1")+"' AND AA1.AA1_CDFUNC = SRA.RA_MAT AND AA1.AA1_FUNFIL = SRA.RA_FILIAL AND AA1.D_E_L_E_T_ = '' "
	// Agenda de Atendentes
	cQuery += " INNER JOIN ( "
	cQuery += " SELECT DISTINCT ABB_FILIAL, ABB_CODTEC, ABB_LOCAL, ABB_DTINI, AA1_CODTEC SUP_CODTEC, AA1_NOMTEC SUP_NOMTEC "
	cQuery += " FROM "+RetSqlName('ABB')+" ABB "
	cQuery += " LEFT JOIN "+RetSqlName('TXI')+" TXI ON TXI.TXI_FILIAL='"+xFilial("TXI")+"' AND TXI.TXI_LOCAL = ABB.ABB_LOCAL AND ABB.ABB_DTINI BETWEEN TXI.TXI_DTINI AND TXI.TXI_DTFIM AND TXI.D_E_L_E_T_ = ' ' 
	cQuery += " LEFT JOIN "+RetSqlName('AA1')+" SUP ON SUP.AA1_FILIAL='"+xFilial("AA1")+"' AND SUP.AA1_CODTEC = TXI.TXI_CODTEC AND SUP.D_E_L_E_T_ = ' '
	cQuery += " WHERE ABB_FILIAL " + cxFilTDV + " AND ABB.D_E_L_E_T_ = ' ' "
	cQuery += " AND ABB.ABB_LOCAL >= '"+MV_PAR03+"' AND ABB.ABB_LOCAL <= '"+MV_PAR04+"' "
	cQuery += " AND ABB.ABB_DTINI BETWEEN '"+DtOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"') AGE "
	cQuery += " ON AGE.ABB_CODTEC = AA1.AA1_CODTEC AND AGE.ABB_DTINI = T40.T40_DATMAR "
	cQuery += " INNER JOIN "+RetSqlName('ABS')+" ABS ON ABS.ABS_FILIAL='"+xFilial("ABS")+"' AND ABS.ABS_LOCAL=AGE.ABB_LOCAL AND ABS.D_E_L_E_T_ = ' ' 
	cQuery += " WHERE "
	cQuery += " T40_FILIAL = '" + xFilial("T40",cFilAnt) + "' AND "
	cQuery += " T40_DATMAR BETWEEN '" + DTOS(MV_PAR05) + "' AND '"+ DTOS(MV_PAR06) + "' AND "
	cQuery += " T40.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY T40_DATMAR, T40_NUMMAR"
	cQuery := ChangeQuery(cQuery)

Return cQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Cria
Criacao tabela temporaria
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Function At765Cria(oBrw)

	Local cAliasTmp  := IIF( EMPTY(At765Alias()) , GetNextAlias() , At765Alias())
	Local aTmpStruct := AT765aStru()
	Local aInsert    := {}
	Local aIdx       := {}
	Local nX         := 0
	Local cAliasAux  := GetNextAlias()
	Local lRet       := .F.
	Local xValue

	If VALTYPE(oGSTmpTb) == 'O'
		oGSTmpTb:Close()
		TecDestroy(oGSTmpTb)
	EndIf

	//Cria indices para a tabela temporária 
	Aadd(aIdx, {"I1",{ 'ABB_FILIAL' },{ 'ABB_DTINI' },{ 'ABB_CODTEC' }})
	Aadd(aIdx, {"I2",{ 'ABB_CODTEC' }})

	oGSTmpTb := GSTmpTable():New(cAliasTmp,aTmpStruct,aIdx)
	If !oGSTmpTb:CreateTMPTable()
		oGSTmpTb:ShowErro()
	Else
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,At765QryGen(aTmpStruct)),cAliasAux, .F., .T.)
		While (cAliasAux)->(!EOF())
			aInsert := {}
			For nX := 1 To LEN(aTmpStruct)
				xValue := (&("(cAliasAux)->" + aTmpStruct[nX][1]))
				If aTmpStruct[nX][1] == 'T40_NUMMAR'
					Aadd(aInsert, {aTmpStruct[nX][1], StrZero(int(xValue)/3600,2)+":"+StrZero(((xValue/3600)-int(xValue/3600))*60,2) })
				ElseIf aTmpStruct[nX][2] == 'D'
					Aadd(aInsert, {aTmpStruct[nX][1], STOD(xValue) })
				Else
					Aadd(aInsert, {aTmpStruct[nX][1], xValue })
				EndIf
			Next nX
			If ( lRet := ( oGSTmpTb:Insert(aInsert) .AND. oGSTmpTb:Commit() ) )
				(cAliasAux)->(DbSkip())
			Else
				oGSTmpTb:ShowErro()
				Exit
			EndIf
		End
		If ( Select( cAliasAux ) > 0 )
			DbSelectArea(cAliasAux)
			(cAliasAux)->(DbCloseArea())
			cAliasAux := ""
		EndIf
	EndIf
	At765Alias(oGSTmpTb:cAliasTmp)
	( At765Alias() )->(DbGoTop())
	oBrw:SetAlias((At765Alias()))

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765aStru
Definicao dos campos uso do browse
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765aStru()

    Local aRet := {}

	Aadd(aRet, At765Field("ABB_FILIAL"))
	Aadd(aRet, At765Field("ABB_CODTEC"))
	Aadd(aRet, At765Field("AA1_NOMTEC"))
	Aadd(aRet, At765Field("T40_DATMAR"))
	Aadd(aRet, {"T40_NUMMAR","C",05,0 })
	Aadd(aRet, {"SUP_CODTEC","C",14,0 })
	Aadd(aRet, {"SUP_NOMTEC","C",30,0 })
	Aadd(aRet, At765Field("ABB_DTINI" ))
	Aadd(aRet, At765Field("ABB_LOCAL" ))
	Aadd(aRet, At765Field("ABS_DESCRI"))
	Aadd(aRet, At765Field("T40_CODREL"))
	Aadd(aRet, At765Field("T40_CODFUN"))
	Aadd(aRet, At765Field("T40_LOGIP" ))
	Aadd(aRet, At765Field("T40_CODNSR"))
	Aadd(aRet, At765Field("T40_CODPIS"))
	Aadd(aRet, At765Field("T40_CODREP"))
	Aadd(aRet, At765Field("T40_CODUNI"))
	Aadd(aRet, At765Field("T40_CODUSU"))
	Aadd(aRet, At765Field("T40_LONGIT"))
	Aadd(aRet, At765Field("T40_LATITU"))
	Aadd(aRet, At765Field("T40_GEOFEN"))
	Aadd(aRet, At765Field("T40_AGEINT"))

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Field
Definicao das colunas uso do browse
@since  23/08/2022
@author Equipe TECA
@return Array Campo, Tipo, Tamanho, Decimais
/*/
//------------------------------------------------------------------------------
Static Function At765Field(cField)

	Local aRet   := {}
	Local aField := {}

	aRet   := FwTamSx3(cField)
	aField := {cField, aRet[3], aRet[1], aRet[2]}

Return aField

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765aCols
Definicao das colunas uso do browse
@since		23/08/2022
@author Equipe TECA
@return 	Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765aCols(aStru)

	Local nY       := 0
	Local nTam     := 0
	Local aColumns := {}
	Local cAlias   := At765Alias()
	Local cField   := ""
	Local cMasc    := ""
	Local cTitle   := ""

	For nY := 1 To Len(aStru)
		cField := aStru[nY][1]
		If !cField $ "T40_AGEINT"
			cMasc  := X3Picture(cField)
			cTitle := RetTitle(cField)
			If cField=="T40_NUMMAR"
				cMasc := "@E 99:99"
			EndIf
			If cField=="SUP_CODTEC"
				cTitle := "Cod. Supervisor"
			ElseIf cField=="SUP_NOMTEC"
				cTitle := "Nome Supervisor"
			EndIf
			AAdd(aColumns,FWBrwColumn():New())
			nTam := Len(aColumns)
			If aStru[nY][2] == 'C'
				aColumns[nTam]:SetData(&("{||Rtrim("+(cAlias)+"->"+(cField)+")}"))
			Else
				aColumns[nTam]:SetData(&("{||"+cAlias+"->"+cField+"}"))
			EndIf
			aColumns[nTam]:SetTitle(cTitle)
			aColumns[nTam]:SetSize(aStru[nY][3])
			aColumns[nTam]:SetDecimal(aStru[nY][4])
			aColumns[nTam]:SetPicture(cMasc)
		EndIf
	Next nY

Return aColumns
