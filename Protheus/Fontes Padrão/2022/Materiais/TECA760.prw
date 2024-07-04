#INCLUDE 'Protheus.ch' 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TECA760.CH"
#INCLUDE "SHELL.ch"

Static cABBAlias := ""
Static oGSTmpTb
Static aABBCheck := {}
Static aPergT760 := {}

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA760
Monitor de Check In
@sample 	TECA760()
@since		29/08/2016
@version 	P12
@return 	cRet, Caractere, Retorna numero do Contrato
/*/
//------------------------------------------------------------------------------
Function TECA760()
Local lGsGerOs := SuperGetMV("MV_GSGEROS",.F.,"1") == "1" 

Private cCadastro	:= STR0001 // "Monitor de Atendentes"

If lGsGerOs
	At760Avis()
EndIf

If At760SavMV()
	AT760Brow()
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760Brow
Monta Browse para Exibição das Informações
@sample 	AT760Brow()
@since		25/08/2016
@version 	P12
@return 	cRet, Caractere, Retorna numero do Contrato
/*/
//------------------------------------------------------------------------------
Static Function AT760Brow()

Local aStru	:= AT760aStru()
Local oBrw		:= Nil
Local bTimer	:= {||AT760AtBrw(@oBrw)}
Local aColumns := {}

aABBCheck := {}
oBrw := FwMarkBrowse():New()
oBrw:oBrowse:SetDataQuery(.F.)
oBrw:oBrowse:SetDataTable(.T.)

At760Cria(@oBrw)

oBrw:SetMenuDef("")
oBrw:AddButton(STR0003,{|| AxVisual('ABB',( At760RCNO(@oBrw) ),2)},2)
oBrw:AddButton(STR0004,{|| AT760CfCh(,@oBrw)},4)
oBrw:AddButton(STR0005,{|| AT760MntAg(,@oBrw)},4)
oBrw:AddButton(STR0017,{|| AT760RetHtml()},4) //"Batidas do Atendente"

oBrw:SetDescription( OEmToAnsi( STR0002 ) ) // Monitor de Check-In

oBrw:AddLegend({|| AT760Legen() == 1 }, "BR_BRANCO"  , STR0008) //"Agenda futura"
oBrw:AddLegend({|| AT760Legen() == 2 }, "BR_AMARELO" , STR0009) //"Em alerta de chegada"
oBrw:AddLegend({|| AT760Legen() == 3 }, "BR_VERMELHO", STR0010) //"Atendente atrasado"
oBrw:AddLegend({|| AT760Legen() == 4 }, "BR_PRETO"   , STR0011) //"Manutenção solicitada"
oBrw:AddLegend({|| AT760Legen() == 5 }, "BR_VERDE", STR0012) //Atendente chegou no horário
oBrw:AddLegend({|| AT760Legen() == 6 }, "BR_AZUL", STR0013) //Atendente chegou atrasado

aColumns := AT760aCols(aStru)
oBrw:AddMarkColumns({||IIf((cABBAlias)->ABB_OK == 1,"LBOK", "LBNO")},{||At760Check(cABBAlias)},{||AT760AMark(@oBrw)})
oBrw:SetColumns(aColumns)
//oBrw:SetSeek(.T.,aSeeks) 
oBrw:SetUseFilter(.T.)

oBrw:SetTimer( bTimer, aPergT760[1] * 60000 ) // 60.000 aproximadamente 1 Minuto
oBrw:SetParam({|| At760SavMV(), AT760AtBrw(@oBrw)})
If !IsBlind()
	SetKey(VK_F5,{ ||AT760AtBrw(@oBrw) })
	oBrw:activate()
	SetKey(VK_F5, Nil)
EndIf	
aABBCheck := {}

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760AtBrw
Utilizado no Timer do Browse
@sample 	AT760AtBrw()
@since		29/08/2016
@version 	P12
@return 	cRet, Caractere, Retorna numero do Contrato
/*/
//------------------------------------------------------------------------------
Static Function AT760AtBrw(oBrw)

( At760Alias() )->(DbCloseArea())

At760Cria(@oBrw)

oBrw:Refresh(.T.)
aABBCheck := {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760CalH
Faz o Calculo das horas
@sample 	AT760CalH()
@since		29/08/2016
@version 	P12
@param		xQtdHor, Value, Quantidade de Horas
@param		lSoma, Bolleano, .T. Soma, .F. Subtrai
@return 	cRet, Caractere, Contendo a Hora
/*/
//------------------------------------------------------------------------------
Static Function AT760CalH(xQtdHor,lSoma)

Local cRet			:= ''
Local aHor			:= {}

DEFAULT lSoma		:= .T.

If lSoma
	cRet := INCTIME(LEFT(TIME(),5),xQtdHor)//SOMAHORAS(LEFT(TIME(),5),xQtdHor)
Else
	cRet := DECTIME(LEFT(TIME(),5),xQtdHor)//SUBHORAS(LEFT(TIME(),5),xQtdHor)
EndIf

aHor := StrTokArr(cRet,':')

If lSoma .And. (val(aHor[1]) <= 0  .OR. val(aHor[1]) > 24)
	cRet := '23:59'
ElseIf !lSoma .And. (val(aHor[1]) <= 0  .OR. val(aHor[1]) > 24)
	cRet := '00:00'
EndIf
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760ProCf
Chamada no Meno para confirmar Chegadas
@sample 	ATChegABB()
@since		26/08/2016
@version 	P12
/*/
//------------------------------------------------------------------------------
Function AT760CfCh(cCodABB,oBrw)

If !IsBlind()
	Processa({|| AT760ProCf(,@oBrw)}, STR0005 ) //Confirmando Chegadas...
Else
	AT760ProCf(cCodABB,oBrw)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760ProCf
Rotina para Confirmar chegadas
@sample 	ATChegABB()
@since		26/08/2016
@version 	P12
/*/
//------------------------------------------------------------------------------
Static Function AT760ProCf(cCodABB,oBrw)

Local nY
Local lMobile	:= ( ABB->(ColumnPos('ABB_HRCHIN')) > 0 )

If lMobile
	//Tratado para Automação
	BEGIN TRANSACTION
		dbSelectArea('ABB')
		
		If !IsBlind() .AND. Len(aABBCheck) > 0
			ProcRegua(Len(aABBCheck))
		EndIf
		
		If Len(aABBCheck) > 0
			For nY	:= 1 To Len(aABBCheck)
				If !IsBlind()
					IncProc()
				EndIf
				ABB->(DbGoTo(aABBCheck[nY][2]))
				RecLock("ABB",.F.)
				ABB->ABB_CHEGOU := 'S'
				ABB->ABB_ATENDE := '1'
				ABB->ABB_SAIU := 'S'
				ABB->ABB_HRCHIN := Left(Time(),5)
				If Left(Time(),5) > ABB->ABB_HRFIM .AND. ABB->ABB_HRINI > ABB->ABB_HRFIM
					ABB->ABB_HRCOUT := ABB->ABB_HRFIM
				ElseIf Left(Time(),5) > ABB->ABB_HRFIM 
					ABB->ABB_HRCOUT := Left(Time(),5)
				Else
					ABB->ABB_HRCOUT := ABB->ABB_HRFIM
				EndIf
				ABB->(MsUnlock())
			Next nY
			If !ISBlind()
				If AT760AtBrw(@oBrw)
					oBrw:Refresh(.T.)
					oBrw:GoTop(.T.)
				EndIf
			EndIf
		Else
			If !Empty(cCodABB)
				dbSelectArea("ABB")
				ABB->(dbSetOrder(8))
				If ABB->(DbSeek(XFilial("ABB")+ cCodABB))
					RecLock("ABB",.F.)
					ABB->ABB_CHEGOU := 'S'
					ABB->ABB_ATENDE := '1'
					ABB->ABB_SAIU := 'S'
					ABB->ABB_HRCHIN := Left(Time(),5)
					If Left(Time(),5) > ABB->ABB_HRFIM .AND. ABB->ABB_HRINI > ABB->ABB_HRFIM
						ABB->ABB_HRCOUT := ABB->ABB_HRFIM
					ElseIf Left(Time(),5) > ABB->ABB_HRFIM 
						ABB->ABB_HRCOUT := Left(Time(),5)
					Else
						ABB->ABB_HRCOUT := ABB->ABB_HRFIM
					EndIf
					ABB->(MsUnlock())
					If !ISBlind()
						If AT760AtBrw(@oBrw)
							oBrw:Refresh(.T.)
							oBrw:GoToP(.T.)
						EndIf
					EndIf
				EndIf
			Else
				Help(' ', 1, "At760Incom", , STR0014, 1, 0) // "Para confirmação de Chegada, é necessário selecionar ao menos uma agenda!"
			EndIf
		EndIf
	END TRANSACTION	
Else
	Help(' ', 1, "At760Incom", , STR0007, 1, 0) //"Dicionário de dados incompatível para a execução. Operação cancelada."
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760MntAg
Chama Rotina de Manutenção TECA540
@sample 	AT760MntAg()
@since		25/08/2016
@version 	P12
/*/
//------------------------------------------------------------------------------
Function AT760MntAg(cCodABB,oBrw)

Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())

If VALTYPE(oBrw) == 'O'
	At760RCNO(oBrw)
EndIf

If !IsBlind()
	If (At760Alias())->ABB_CHEGOU <> 'S'
		TECA540( (At760Alias())->ABB_DTINI, (At760Alias())->ABB_DTFIM )
	Else
		Help(' ', 1, "AT760MntAg", , STR0015, 1, 0) //A agenda selecionada já foi atendida e não pode receber manutenções!
	EndIf
Else
	If !Empty(cCodABB)
		dbSelectArea("ABB")
		ABB->(dbSetOrder(8))//ABB_FILIAL+ABB_CODIGO
		If ABB->(DbSeek(XFilial("ABB")+ cCodABB))
			TECA540( ABB->ABB_DTINI, ABB->ABB_DTFIM )
		EndIf
	EndIf
EndIf
RestArea(aAreaABB)
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760AMark
Troca a marcação de todos os itens
@sample 	AT760AMark()
@since		08/01/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Function AT760AMark(oBrw)
Local nAt := oBrw:At()
oBrw:GoTop()
While (oBrw:Alias())->(!Eof())
	If (oBrw:Alias())->ABB_CHEGOU <> "S"
		At760Check(oBrw:Alias())
	EndIf
	(oBrw:Alias())->(DbSkip())
End
oBrw:GoTo(nAt, .T.)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760Legen
Retorna a legenda da agenda
@sample 	AT760Legen()
@since		08/01/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Static Function AT760Legen()
Local nRet := 1 //Agenda futura
Local lMobile := ( ABB->(ColumnPos('ABB_HRCHIN')) > 0 )
Local nAlerta

If lMobile
	If VALTYPE(MV_PAR08) != 'N' .OR. aPergT760[8] < 0
		nAlerta := 0
	Else
		nAlerta := aPergT760[8]
	EndIf
Else
	nAlerta := 0
EndIf
If (At760Alias())->ABB_CHEGOU == 'S'
	If VAL(ALLTRIM(STRTRAN((At760Alias())->ABB_HRINI, ":", ""))) < VAL(ALLTRIM(STRTRAN((At760Alias())->ABB_HRCHIN, ":", "")))
		nRet := 6 // Atendente Chegou Atrasado
	Else
		nRet := 5 // Atendente chegou no horário
	EndIf
Else
	If (At760Alias())->ABB_MANIN == "S"
		nRet := 4 //Manutenção
	Else
		If VAL(ALLTRIM(STRTRAN((At760Alias())->ABB_HRINI, ":", ""))) < VAL(ALLTRIM(STRTRAN(Left(Time(),5), ":", "")))
			nRet := 3 //Atrasado
		EndIf
		If lMobile .AND. nRet != 3
			IF VAL(STRTRAN(LEFT(DECTIME(LEFT((At760Alias())->ABB_HRINI,5), (nAlerta / 60)),5),":","")) <= VAL(STRTRAN(LEFT(TIME(),5), ":",""))
				nRet := 2 //Alerta
			EndIf
		EndIf
	EndIf	
EndIf
Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760Alias
Retorna/Define o Alias atual do browse
@since		20/08/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At760Alias(cSetValue)

If VALTYPE(cSetValue) == 'C'
	cABBAlias := cSetValue
EndIf

Return cABBAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760QryGen
Gera o WHERE que filtrará os registros no MarkBrowse
@since		20/08/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At760QryGen()
Local cQuery	:= ""
Local nHrsMen
Local nHrsMai
Local lMV_MultFil := TecMultFil()
Local cFilABBABS := FWJoinFilial("ABB" , "ABS" , "ABB", "ABS", .T.)

nHrsMai	:= AT760CalH(aPergT760[3])
nHrsMen	:= AT760CalH(aPergT760[2],.F.)

cQuery += " SELECT DISTINCT ABB.ABB_FILIAL, ABB.ABB_CODTEC, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_LOCAL, "
cQuery += " AA1.AA1_NOMTEC, ABQ.ABQ_CONTRT,ABB.ABB_MANIN,ABB.ABB_HRCHIN, ABB.ABB_HRCOUT, ABB.ABB_CODIGO, ABB.ABB_CHEGOU, ABS.ABS_DESCRI, 0 ABB_OK, ABB.R_E_C_N_O_ AS RECNO "
cQuery += " FROM " + RetSqlName('ABB') + " ABB "
cQuery += " JOIN " + RetSqlName('AA1') + " AA1 ON "
cQuery += " AA1.AA1_CODTEC = ABB.ABB_CODTEC "
cQuery += " JOIN " + RetSqlName('ABQ') + " ABQ ON  "
cQuery += " ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
If lMV_MultFil
	cQuery += " AND ABB.ABB_FILIAL = ABQ.ABQ_FILTFF "
EndIf
cQuery += " JOIN " + RetSqlName('ABS') + " ABS ON  "
cQuery += " ABB.ABB_LOCAL  = ABS.ABS_LOCAL AND "
cQuery += cFilABBABS
cQuery += " WHERE "

If At760Visao() == 2
	cQuery += " ABB.ABB_CHEGOU <> 'S' AND "
	cQuery += " ABB.ABB_ATENDE =  '2' AND "
EndIf

cQuery += " ABB.ABB_ATIVO  =  '1' AND "
cQuery += "  ABB.ABB_DTINI  =  '" + DTOS(DDATABASE) + "' AND "
cQuery += " (ABB.ABB_FILIAL >= '" + aPergT760[4]  + "' AND ABB.ABB_FILIAL <= '" + aPergT760[5] + "') AND "
cQuery += " (ABB.ABB_LOCAL  >= '" + aPergT760[6]  + "' AND ABB.ABB_LOCAL  <= '" + aPergT760[7] + "') AND "
cQuery += " (ABB.ABB_HRINI  >= '" + nHrsMen   + "' AND ABB.ABB_HRINI  <= '" + nHrsMai  + "') AND "
cQuery += "  ABB.D_E_L_E_T_ = ' ' AND AA1.D_E_L_E_T_ = ' ' AND ABQ.D_E_L_E_T_ = ' ' AND ABS.D_E_L_E_T_ = ' ' "
IF TYPE("MV_PAR09") == 'N'
	If aPergT760[9] == 1
		cQuery += " ORDER BY AA1.AA1_NOMTEC "
	ElseIf aPergT760[9] == 2
		cQuery += " ORDER BY ABB.ABB_HRINI "
	ElseIf aPergT760[9] == 3
		cQuery += " ORDER BY ABS.ABS_DESCRI "
	ElseIf aPergT760[9] == 4
		cQuery += " ORDER BY ABB.ABB_LOCAL "
	ElseIf aPergT760[9] == 5
		cQuery += " ORDER BY ABQ.ABQ_CONTRT "
	Else
		cQuery += " ORDER BY ABB.ABB_HRINI "
	EndIf
Else
	cQuery += " ORDER BY ABB.ABB_HRINI "
EndIf

Return ChangeQuery(cQuery)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760Cria
Cria o Alias que será utilizado pelo browse
@since		20/08/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At760Cria(oBrw)
Local cAliasABB := IIF( EMPTY(At760Alias()) , GetNextAlias() , At760Alias())
Local aTmpStruct := AT760aStru()
Local aInsert := {}
Local nX
Local xValue
Local cAliasAux := GetNextAlias()
//Local aIndx := At760Index()
Local lRet := .F.

If VALTYPE(oGSTmpTb) == 'O'
	oGSTmpTb:Close()
	TecDestroy(oGSTmpTb)
EndIf

oGSTmpTb := GSTmpTable():New(cAliasABB,aTmpStruct,/*aIndx*/,)

If !oGSTmpTb:CreateTMPTable()
	oGSTmpTb:ShowErro()
Else
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,At760QryGen()),cAliasAux, .F., .T.)
	While (cAliasAux)->(!EOF())
		aInsert := {}
		For nX := 1 To LEN(aTmpStruct)
			xValue := (&("(cAliasAux)->" + aTmpStruct[nX][1]))
			IF aTmpStruct[nX][2] == 'D'
				Aadd(aInsert, {aTmpStruct[nX][1], STOD(xValue) })
			Else
				Aadd(aInsert, {aTmpStruct[nX][1], xValue })
			EndIf
		Next
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

At760Alias(oGSTmpTb:cAliasTmp)
( At760Alias() )->(DbGoTop())
oBrw:SetAlias((At760Alias()))

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760aStru
Retorna o array com a estrutura dos campos utilizados no browse
@since		20/08/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Static Function AT760aStru()
Local aRet := {}
	
	Aadd(aRet, {"ABB_OK"		, "N", 1	, 											0})
	Aadd(aRet, {"ABB_FILIAL"	, "C", TamSX3("ABB_FILIAL")[1]	, TamSX3("ABB_FILIAL")[2]})
	Aadd(aRet, {"ABB_LOCAL"		, "C", TamSX3("ABB_LOCAL")[1]	, TamSX3("ABB_LOCAL")[2]})
	Aadd(aRet, {"ABS_DESCRI"	, "C", TamSX3("ABS_DESCRI")[1]	, TamSX3("ABS_DESCRI")[2]})
	Aadd(aRet, {"ABB_CODTEC"	, "C", TamSX3("ABB_CODTEC")[1]	, TamSX3("ABB_CODTEC")[2]})
	Aadd(aRet, {"AA1_NOMTEC"	, "C", TamSX3("AA1_NOMTEC")[1]	, TamSX3("AA1_NOMTEC")[2]})
	Aadd(aRet, {"ABB_DTINI"		, "D", TamSX3("ABB_DTINI")[1]	, TamSX3("ABB_DTINI")[2]})
	Aadd(aRet, {"ABB_HRINI"		, "C", TamSX3("ABB_HRINI")[1]	, TamSX3("ABB_HRINI")[2]})
	Aadd(aRet, {"ABB_HRFIM"		, "C", TamSX3("ABB_HRFIM")[1]	, TamSX3("ABB_HRFIM")[2]})
	Aadd(aRet, {"ABB_DTFIM"		, "D", TamSX3("ABB_DTFIM")[1]	, TamSX3("ABB_DTFIM")[2]})
	Aadd(aRet, {"ABB_MANIN"		, "C", TamSX3("ABB_MANIN")[1]	, TamSX3("ABB_MANIN")[2]})
	Aadd(aRet, {"ABB_HRCHIN"	, "C", TamSX3("ABB_HRCHIN")[1]	, TamSX3("ABB_HRCHIN")[2]})
	Aadd(aRet, {"ABB_HRCOUT"	, "C", TamSX3("ABB_HRCOUT")[1]	, TamSX3("ABB_HRCOUT")[2]})
	Aadd(aRet, {"ABQ_CONTRT"	, "C", TamSX3("ABQ_CONTRT")[1]	, TamSX3("ABQ_CONTRT")[2]})
	Aadd(aRet, {"ABB_CODIGO"	, "C", TamSX3("ABB_CODIGO")[1]	, TamSX3("ABB_CODIGO")[2]})
	Aadd(aRet, {"ABB_CHEGOU"	, "C", TamSX3("ABB_CHEGOU")[1]	, TamSX3("ABB_CHEGOU")[2]})
	Aadd(aRet, {"RECNO"			, "N", 8						,						0})
	
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT760aCols
Retorna o array com as colunas utilziadas no browse
@since		20/08/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Static Function AT760aCols(aStru)
Local nY
Local aColumns := {}
Local cTela := "ABB_FILIAL|ABQ_CONTRT|ABB_LOCAL|ABS_DESCRI|AA1_NOMTEC|ABB_CODTEC|ABB_DTINI|ABB_HRINI|ABB_HRFIM|ABB_HRCHIN|ABB_HRCOUT"

For nY := 1 To Len(aStru)
	If aStru[nY][1] $ cTela
		AAdd(aColumns,FWBrwColumn():New())
		If aStru[nY][2] == 'C'
			aColumns[Len(aColumns)]:SetData(&("{||Rtrim("+(At760Alias())+"->"+(aStru[nY][1])+")}"))
		Else
			aColumns[Len(aColumns)]:SetData(&("{||"+At760Alias()+"->"+aStru[nY][1]+"}"))
		EndIf
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nY][1]))
		aColumns[Len(aColumns)]:SetSize(aStru[nY][3])
		aColumns[Len(aColumns)]:SetDecimal(aStru[nY][4])
	EndIf
Next nY

Return aColumns

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760RCNO
Posiciona na ABB

@since		20/08/2018
@author	mateus.boiani
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At760RCNO(oBrw)
Local aArea := GetArea()

DbSelectArea("ABB")
ABB->(DbGoTo( ( (oBrw:Alias())->RECNO ) ))
RestArea(aArea)
Return ( (oBrw:Alias())->RECNO )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At760Visao
Retorna variável lógica para qual visão o usuário irá utilizar

@since		23/08/2018
@author		diego.bezerra
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At760Visao()

Local nVisao := 0

If VALTYPE(MV_PAR10) == 'N'
	If(aPergT760[10]) == 1
		nVisao := 1
	Else
		nVisao := 2
	EndIf
Else	
	nVisao := 1
EndIf

Return nVisao


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At760Check
Atualiza markColumn do browse

@since		28/08/2018 
@version 	P12
@author		diego.bezerra
@param		cAliasABB 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At760Check(cAlias)

Local checkabb := ''

If (cAlias)->ABB_CHEGOU == "S"
	Help(' ', 1, "At760Check", , STR0016, 1, 0) //"Não é possível selecionar essa agenda! Agenda já confirmada!"
Else	
	If (cAlias)->ABB_OK == 0
		checkabb := "LBNO"
		(cAlias)->ABB_OK := 1
		AADD(aABBCheck, {(cAlias)->ABB_CODTEC, (cAlias)->RECNO})
	Else
		(cAlias)->ABB_OK := 0
		checkabb := "LBOK"
		ADEL(aABBCheck, ASCAN(aABBCheck, {|x| x[2] == (cAlias)->RECNO}))
		ASIZE(aABBCheck,(Len(aABBCheck)-1))
	EndIf
EndIf

Return checkabb

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760RetHtml

@description Função para envio do email com relatorio HTML
@author	Luiz Gabriel
@since	05/11/2019
/*/
//------------------------------------------------------------------------------
Function At760RetHtml(cAttendant,cBeginDate,cEndDate,lMobile)
Local cRet			:= ""
Local cPathServer	:= Alltrim(SuperGetMv("MV_TECPATH"))	//Diretorio que estao os DOTS originais
Local cHTMLSrc		:= cPathServer + "TECA760_mail001.html"  // \samples\documents\GS\portugues\
Local cHTMLDst		:= cPathServer + "TECA760.htm" //Destino deve ser .htm pois o metodo :SaveFile salva somente neste formato.
Local cMsg			:= ""
Local cEmail		:= ""
Local lRet			:= .T.
Local aErro 		:= {} //Array com mensagem de erro e retorno da função
Local dDataIni		:= Ctod("")
Local dDataFim		:= Ctod("")
Local lPergunte		:= TecHasPerg("MV_PAR01","TECM760") .AND. Pergunte("TECM760",.T.)
Local oDlg	 		:= Nil
Local cLink  		:= "https://tdn.totvs.com/pages/viewpage.action?pageId=268818008"

Default cAttendant	:= ""
Default cBeginDate	:= ""
Default cEndDate	:= ""
Default lMobile		:= .F.

If !lMobile
	 If lPergunte
		cAttendant	:= MV_PAR01
		dDataIni 	:= MV_PAR02
		dDataFim	:= MV_PAR03
	Else
		lRet := .F.	
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0021) FROM 0,0 TO 200,760 PIXEL
		TSay():New( 010,010,{||OemToAnsi(STR0029)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  // "Para usar a funcionalidade, por favor, crie o perugunte TECM760."
		TSay():New( 025,010,{||OemToAnsi(STR0030)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK) // "Consulte mais informações sobre esta função no TDN:"
		TGet():New( 040,010,{||cLink },oDlg, 195, 09, "@!",,,,,,,.T.,,,,,,,.T.)
		
		TButton():New(040,230, OemToAnsi(STR0031), oDlg,{|| ShellExecute("Open", cLink, "", "", SW_NORMAL), oDlg:End() },030,011,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Abrir Link"
		TButton():New(040,300, OemToAnsi(STR0032), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Ok"
		
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
Else
	cAttendant	:= At760ExTec(cAttendant)
	dDataIni 	:= sToD(cBeginDate)
	dDataFim	:= sTod(cEndDate)
EndIf

If lRet
	If At760Param(cAttendant,dDataIni,dDataFim,@cMsg)
		cRet := At760TempHtml( cAttendant,dDataIni,dDataFim,cHTMLSrc, cHTMLDst, @cEmail, @lRet,@cMsg)

		If lRet
			If !Empty(cRet) .And. !Empty(cEmail)
				//Enviar o e-mail
				lRet := SendMailGS(cEmail,cRet,STR0019,cHTMLDst,@cMsg) //"Marcações do Funcionário"
				FErase(cHTMLDst)
			EndIf 
		EndIf
	Else
		lRet := .F.				
	EndIf
	aAdd(aErro,{lRet,cMsg})
EndIf

If !lMobile .And. !Empty(cMsg)
	AtShowLog( cMsg, STR0021, .T., .T., .T.) // Marcações		
EndIf

Return aErro

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760TempHtml

@param cAttendant - caracter - Codigo do atendente
@param dDatIni - Data - Data inicial a ser pesquisada
@param dDatFim - Data - Data final a ser pesquisada
@param cHTMLSrc - caracter - Caminho do template HTML original - via parametro MV_TECPATH
@param cHTMLDst - caracter - caminho onde será salvo o HTML editado
@param cEmail - caracter - e-mail do atendente, parametro passado por referencia
@param lRet - lógico - Retorno da função, passado como referencia
@param cMsg - caracter - Mensagem de retorno - passado como referencia

@description Função para preenchimento do relatorio relatorio HTML
@author	Luiz Gabriel
@since	05/11/2019
/*/
//------------------------------------------------------------------------------
Static Function At760TempHtml(cAttendant,dDatIni,dDatFim,cHTMLSrc, cHTMLDst, cEmail, lRet,cMsg )
Local cRet		:= ""
Local cAliasABB	:= GetNextAlias()
Local nColuna	:= SuperGetMv("MV_GSCOLMA",,4)	//Define a quantidade de colunas de entra e saida do template HTML
Local nEntrada	:= 0
Local oHTMLBody	:= Nil
Local lPrimeira := .T.
Local nX		:= 0
Local nY		:= 0
Local lExistPE	:= ExistBlock("At760UHTML") //Ponto de Entrada para custoização do HTML
Local cBranco := Replicate("-", 3)

If File(cHTMLSrc)
	oHTMLBody:= TWFHTML():New(cHTMLSrc)
	lRet	 := .T.
	At760Query( @cAliasABB, cAttendant, dDatIni, dDatFim )

	If ( cAliasABB )->( Eof() )
		lRet := .F.
		cMsg := STR0027 //"Não há dados a serem informados."
	EndIf 
Else 
	lRet := .F.
	cMsg := STR0028 //"O Template TECA760_mail001.html não foi encontrado no caminho especificado"	
EndIf

If lRet 
	If !Empty((cAliasABB)->AA1_EMAIL)
		cEmail := (cAliasABB)->AA1_EMAIL
		//- Cabeçalho do informe.
		oHTMLBody:ValByName('cCodigo'	, cAttendant)
		oHTMLBody:ValByName('cNome'		, (cAliasABB)->AA1_NOMTEC)
		oHTMLBody:ValByName('cDataIni'	, dDatIni)
		oHTMLBody:ValByName('cDataFim'	, dDatFim)
		
		//- Detalhamento dos itens
		While (cAliasABB)->(!EOF())
			nDif := DateDiffDay( dDatIni, sToD((cAliasABB)->ABB_DTINI))  
			If nDif > 1  
				For nX := 1 To nDif - 1
					aADD(oHTMLBody:ValByName('It.Data')		, dDatIni + nX)
					aADD(oHTMLBody:ValByName('It.Dia')		, DiaSemana( dDatIni + nX ))
					For nY := 1 To nColuna
						aADD(oHTMLBody:ValByName('It.Entrada'+cValToChar(nY))	,cBranco)
						aADD(oHTMLBody:ValByName('It.Saida'+cValToChar(nY))	,cBranco)
					Next nY
				Next nX
			EndIf
			If dDatIni == sToD((cAliasABB)->ABB_DTINI) .AND. !lPrimeira
				aADD(oHTMLBody:ValByName('It.Entrada' + cValToChar(++nEntrada))	,IIF(!Empty((cAliasABB)->ABB_HRCHIN), (cAliasABB)->ABB_HRCHIN, cBranco))
				If (cAliasABB)->ABB_SAIU = 'S'
					aADD(oHTMLBody:ValByName('It.Saida' + cValToChar(nEntrada))	,(cAliasABB)->ABB_HRCOUT)
				Else
					aADD(oHTMLBody:ValByName('It.Saida' + cValToChar(nEntrada))	,cBranco)
				EndIf
			Else
				If !lPrimeira
					For nX := nEntrada + 1 To nColuna
						aADD(oHTMLBody:ValByName('It.Entrada'+cValToChar(nX))	,cBranco)
						aADD(oHTMLBody:ValByName('It.Saida'+cValToChar(nX))	,cBranco)
					Next nX
				Else
					lPrimeira := .F.
					dDatIni := StoD("")
				EndIf 
				nEntrada := 1
				dDatIni := sToD((cAliasABB)->ABB_DTINI)
				aADD(oHTMLBody:ValByName('It.Data')		,dDatIni)
				aADD(oHTMLBody:ValByName('It.Dia')		,DiaSemana( dDatIni ))
				aADD(oHTMLBody:ValByName('It.Entrada1')	,IIF(!Empty((cAliasABB)->ABB_HRCHIN), (cAliasABB)->ABB_HRCHIN, cBranco))
				If (cAliasABB)->ABB_SAIU = 'S'
					aADD(oHTMLBody:ValByName('It.Saida1')	,(cAliasABB)->ABB_HRCOUT)
				Else
					aADD(oHTMLBody:ValByName('It.Saida1') 	, cBranco)
				EndIf
			EndIf	
			(cAliasABB)->(DbSkip())
		End
		// Necessario para casa não seja preenchido todos os campos ocorrer a quebra de linha, para o ultimo registro.
		For nX := nEntrada + 1 To nColuna
				aADD(oHTMLBody:ValByName('It.Entrada'+cValToChar(nX))	,cBranco)
				aADD(oHTMLBody:ValByName('It.Saida'+cValToChar(nX))	,cBranco)
		Next nX
		If dDatIni <> dDatFim	
			dDatIni++
			While dDatIni <= dDatFim
				aADD(oHTMLBody:ValByName('It.Data')		, dDatIni)
				aADD(oHTMLBody:ValByName('It.Dia')		, DiaSemana( dDatIni ))
				For nX := 1 To nColuna
					aADD(oHTMLBody:ValByName('It.Entrada'+cValToChar(nX))	,cBranco)
					aADD(oHTMLBody:ValByName('It.Saida'+cValToChar(nX))	,cBranco)
				Next nX
				dDatIni++	    	
			End	
		EndIf
		
		If lExistPE //Ponto de entrada para customização do HTML.
			ExecBlock("At760UHTML",.F.,.F.,{oHTMLBody})
		EndIf

		oHTMLBody:SaveFile(cHTMLDst)
		cRet:= MtHTML2Str(cHTMLDst)
		If Empty(cRet)
			lRet := .F.
			cMsg := STR0020 //"Ocorreu problemas na geração do e-mail. Por favor verifique o template TECA760_mail001.html"
		EndIf
	Else
		lRet := .F.
		cMsg 	:= STR0018 //"O Atendente informado não possui e-mail cadastrado. Por favor acesse a rotina de atendentes e verefique o email cadastrado." 
	EndIf	
	
	If Select(cAliasABB) > 0
		(cAliasABB)->(DbCloseArea())
	EndIf	
Else
	If Select(cAliasABB) > 0
		(cAliasABB)->(DbCloseArea())
	EndIf
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760Query

@description Query para retorno das agendas no periodo do atendente
@author	Augusto Albuquerque
@since	31/10/2019
/*/
//------------------------------------------------------------------------------
Function At760Query( cAliasABB, cAttendant, cBeginDate, cEndDate )
Local cVazio 		:= space(TamSx3("ABB_HRCHIN")[1])
Local lMV_MultFil 	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cQuery		:= ""

cQuery += "SELECT AA1.AA1_CDFUNC, AA1.AA1_EMAIL, AA1.AA1_NOMTEC, " 
cQuery += "ABB.ABB_HRCHIN, ABB.ABB_HRCOUT, ABB.ABB_DTINI, "
cQuery += "ABB.ABB_CHEGOU, ABB.ABB_SAIU,TDV.TDV_DTREF "
cQuery += " FROM "  + RetSqlName( "ABB" ) + " ABB "
cQuery += " INNER JOIN "+RetSqlName("TDV")+" TDV ON "
If lMV_MultFil
		cQuery += FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.)
Else
		cQuery += " TDV.TDV_FILIAL='"+xfilial("TDV")+"' "
EndIf
cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
cQuery += " AND TDV.D_E_L_E_T_= ' ' "
cQuery += " INNER JOIN "+RetSqlName("AA1")+" AA1 ON "
cQuery += " AA1.AA1_FILIAL='"+xfilial("AA1")+"' AND "
cQuery += "AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
cQuery += "AA1.D_E_L_E_T_= ' ' "
cQuery += "WHERE "
If !lMV_MultFil
	cQuery += "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
EndIf 
cQuery += "ABB.ABB_CODTEC = '" + cAttendant + "' AND " 
cQuery += "ABB.ABB_DTINI BETWEEN '" + DtoS(cBeginDate) + "' AND " 
cQuery += " '" + DtoS(cEndDate) + "' AND "
cQuery += "ABB.D_E_L_E_T_= ' ' "
cQuery += "AND (ABB.ABB_HRCHIN <> '" + cVazio + "' OR " 
cQuery += "ABB.ABB_HRCOUT <> '" + cVazio + "' ) "
cQuery += "ORDER BY ABB.ABB_DTINI, ABB.ABB_HRCHIN"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABB, .F., .T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760ExTec

@description Query para retorno do codigo do atendente

@author	Augusto Albuquerque
@since	31/10/2019
/*/
//------------------------------------------------------------------------------
Static Function At760ExTec(cAttendant)
Local cCodTec	:= ""
Local cTemp		:= GetNextAlias()

BeginSQL Alias cTemp		
	SELECT 
		AA1_CODTEC
	FROM 	
		%Table:AA1% AA1
	WHERE 
		AA1.AA1_FILIAL = %Exp:xFilial("AA1")% AND
		AA1.AA1_NREDUZ = %Exp:cAttendant% AND
		AA1.%NotDel%
EndSql

If ( cTemp )->( !Eof() )
	cCodTec := ( cTemp )->AA1_CODTEC		
EndIf

Return cCodTec

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760Param

@description Realiza a validação dos parametros

@author	Augusto Albuquerque
@since	31/10/2019
/*/
//------------------------------------------------------------------------------
Static Function At760Param(cAttendant, dDataIni, dDataFim, cMsg)
Local lRet := .T.

If Empty(cAttendant)
	lRet := .F.
	cMsg := STR0023 //"É necessario informar o codigo do atendente válido"
EndIf

If lRet .And. (Empty(dDataIni) .Or. Empty(dDataFim))
	lRet := .F.
	cMsg := STR0024 //"É necessario informar as datas"
EndIf 

If lRet .And. (dDataFim < dDataIni)
	lRet := .F.
	cMsg := STR0025 //"A data final não pode ser menor que a data inicial"
EndIf 

If lRet .And. DateDiffDay( dDataIni, dDataFim) > 60
	lRet := .F.
	cMsg := STR0026 //"O período pesquisado não pode ultrapassar 60 dias"
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At760Avis()

Aviso informando que para usar a rotina é necessário que o parâmetro MV_GSGEROS esteja desabilitado

@author Junior Santos
@since 21/10/2020
/*/
//------------------------------------------------------------------------------
Function At760Avis()
Local oDlg	 := Nil
Local cLink  := "https://tdn.totvs.com/pages/releaseview.action?pageId=555849119"

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0034) FROM 0,0 TO 200,760 PIXEL //Atenção

TSay():New( 010,010,{||OemToAnsi(STR0033)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"Para utilizar esta rotina o parâmetro MV_GSGEROS deve estar desabilitado."
TSay():New( 025,010,{||OemToAnsi(STR0030)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK) //"Consulte mais informações sobre esta alteração no TDN:"
TGet():New( 040,010,{||cLink },oDlg, 195, 09, "@!",,,,,,,.T.,,,,,,,.T.)

TButton():New(040,230, OemToAnsi(STR0031), oDlg,{|| ShellExecute("Open", cLink, "", "", SW_NORMAL) },030,011,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Abrir Link"
TButton():New(040,300, OemToAnsi(STR0032), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Ok"

ACTIVATE MSDIALOG oDlg CENTER

Return ( .T. )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At760SavMV()

Uso de variavel STATIC aPergT760 para guardar parametros MV_PAR do Pergunte
evitando concorrência de usuarios

@author flavio.vicco
@since 28/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At760SavMV()

Local cPerg := "TECA760"
Local lRet  := .F.
/*
01	Intervalo Atualizacao (Min) ? 	N
02	Per. Visib. Anterior (Horas) ?	N
03	Per. Visib. Posterior(Horas) ?	N
04	Filial De ?                   	C
05	Filial Ate ?                  	C
06	Local De ?                    	C
07	Local Ate ?                   	C
08	Alerta (Minutos) ?            	N
09	Ordenacao ?                   	N
10	Agendas Efetivadas ?          	N
*/
	If Pergunte(cPerg,.T.)
		lRet := .T.
		aPergT760 := Array(10)
		aPergT760[1] := MV_PAR01
		aPergT760[2] := MV_PAR02
		aPergT760[3] := MV_PAR03
		aPergT760[4] := MV_PAR04
		aPergT760[5] := MV_PAR05
		aPergT760[6] := MV_PAR06
		aPergT760[7] := MV_PAR07
		aPergT760[8] := MV_PAR08
		aPergT760[9] := MV_PAR09
		aPergT760[10] := MV_PAR10
	EndIf

Return lRet
