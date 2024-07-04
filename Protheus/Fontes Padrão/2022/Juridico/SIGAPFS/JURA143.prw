#INCLUDE "JURA143.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE nPGrCli     1
#DEFINE nPClien     2
#DEFINE nPLoja      3
#DEFINE nPCaso      4
#DEFINE nPContr     5
#DEFINE nPDtIni     6
#DEFINE nPDtFim     7
#DEFINE nPTipo      8
#DEFINE nPCobraNVY  9
#DEFINE nPCobraNRH  10
#DEFINE nPCobraNTK  11
#DEFINE nPCobraNUC  12
#DEFINE nPDtInc     13
#DEFINE nPMotWODesp 14
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA143
Inclusão de WO - Despesas

@author David Gonçalves Fernandes
@since 29/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA143()
	Local lJura049      := IsInCallStack( "JCall143" )
	Local lVldUser      := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)
	
	Private cQueryTmp   := ""
	Private oBrw143     := Nil
	Private lMarcar     := .F.
	Private oTmpTable   := Nil
	Private TABLANC     := ""
	Private cDefFiltro  := ""
	Private cGetClie    := "" // Variável de filtro da consulta SA1NUH
	Private cGetLoja    := "" // Variável de filtro da consulta SA1NUH
	
	If lVldUser
		If ! lJura049 .And. ExistFunc( "JurFiltrWO" ) // Função para filtrar o browse criada no fonte JURXFUNC
			JurFiltrWO("NVY")
			If Type( "oTmpTable" ) == "O"
				oTmpTable:Delete() //Apaga a Tabela temporária
			EndIf
		Else
			TABLANC     := "NVY"
			cDefFiltro  := "NVY_SITUAC == '1'"
	
			oBrw143 := FWMarkBrowse():New()
			If !IsInCallStack( 'JURA143' ) .And. !IsInCallStack( 'JURA202' )
				oBrw143:SetDescription( STR0007 )
			Else
				oBrw143:SetDescription( STR0012 )
			EndIf
	
			oBrw143:SetAlias( TABLANC )
			oBrw143:SetMenuDef( "JURA143" ) // Redefine o menu a ser utilizado
			oBrw143:SetLocate()
			oBrw143:SetFilterDefault( cDefFiltro )
			oBrw143:SetFieldMark( 'NVY_OK' )
			oBrw143:bAllMark := { || JurMarkALL(oBrw143, "NVY", 'NVY_OK', lMarcar := !lMarcar,, .F.), oBrw143:Refresh() }
			JurSetLeg( oBrw143, "NVY" )
			JurSetBSize( oBrw143 )
			oBrw143:Activate()
		EndIf
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR143BrwR
Função para executar um processa para abrir o browse (JUR143Brw)

@param   aFiltros , array    , Campos e valores de filtros
@param   lAtualiza, lógico   , Reabre browse com novos filtros

@author  Bruno Ritter
@since   19/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR143BrwR(aFiltros, lAtualiza)
Local lRet := .F.

FWMsgRun( , {|| lRet := JUR143Brw(aFiltros, lAtualiza)}, STR0056, STR0057 ) // "Processando" - "Processando a rotina..."

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR143Brw
Função para montar o browse de WO com filtros

@param   aFiltros , array , Campos e valores de filtros
@param   lAtualiza, logico, Reabre browse com novos filtros

@author  Abner Fogaça
@since   10/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR143Brw(aFiltros, lAtualiza)
Local aTemp         := {}
Local aFields       := {}
Local aOrder        := {}
Local aFldsFilt     := {}
Local aTmpFld       := {}
Local aTmpFilt      := {}
Local aCmpAcBrw     := {}
Local aTitCpoBrw    := {}
Local bseek         := {||}
Local aStruAdic     := {}
Local cLojaAuto     := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aRotina       := MenuDef()
Local nRot          := 0
Local lRet          := .T.

Default aFiltros    := Array(14)
Default lAtualiza   := .F.

cQueryTmp := J143QryTmp( aFiltros )

If lAtualiza
	lRet := J143AtuBrw(cQueryTmp)
Else
	aStruAdic  := J143StruAdic()
	aCmpAcBrw  := J143CmpAcBrw()
	aTitCpoBrw := J143TitCpoBrw()
	aTemp      := JurCriaTmp(GetNextAlias(), cQueryTmp, "NVY", , aStruAdic, aCmpAcBrw, {"REC", "NVY_ACAOLD", "NVY_CCLILD", "NVY_CLJLD", "NVY_CCSLD", "NVY_PARTLD", "NVY_CMOTWO", "NVY_OBSWO", "NVY_CDWOLD"}, .F., , aTitCpoBrw)
	oTmpTable  := aTemp[1]
	aTmpFilt   := aTemp[2]
	aOrder     := aTemp[3]
	aTmpFld    := aTemp[4]
	TABLANC    := oTmpTable:GetAlias()

	If (TABLANC)->( Eof() )
		lRet := JurMsgErro(STR0048) // "Não foram encontrados dados!"
	Else
		If(cLojaAuto == "1")
			AEVAL(aTmpFld , {|aX| Iif(aX[2] $ "NVY_CLOJA |REC", , Aadd(aFields  , aX))})
			AEVAL(aTmpFilt, {|aX| Iif(aX[1] $ "NVY_CLOJA |REC", , Aadd(aFldsFilt, aX))})
		Else
			aFields   := aTmpFld
			aFldsFilt := aTmpFilt
		EndIf

		oBrw143 := FWMarkBrowse():New()
		If !IsInCallStack( 'JURA049' )
			oBrw143:SetDescription( STR0007 ) // "WO - Despesas"
		Else
	    	oBrw143:SetDescription( STR0012 ) // "Operações em lote - Despesas"
		EndIf
		oBrw143:SetAlias( TABLANC )
		oBrw143:SetTemporary( .T. )
		oBrw143:SetFields(aFields)
		
		oBrw143:oBrowse:SetDBFFilter(.T.)
		oBrw143:oBrowse:SetUseFilter()
		//------------------------------------------------------
		// Precisamos trocar o Seek no tempo de execucao,pois
		// na markBrowse, ele não deixa setar o bloco do seek
		// Assim nao conseguiriamos  colocar a filial da tabela 
		//------------------------------------------------------
		
		bseek := {|oSeek| MySeek(oSeek, oBrw143:oBrowse)}
		oBrw143:oBrowse:SetIniWindow({|| oBrw143:oBrowse:oData:SetSeekAction(bseek)})
		oBrw143:oBrowse:SetSeek(.T., aOrder) 
		
		oBrw143:oBrowse:SetFieldFilter(aFldsFilt)
		oBrw143:oBrowse:bOnStartFilter := Nil
		
		oBrw143:SetMenuDef( '' )
		oBrw143:SetFieldMark( 'NVY_OK' )
		oBrw143:bAllMark := { || JurMarkALL(oBrw143, TABLANC, 'NVY_OK', lMarcar := !lMarcar,, .F.), oBrw143:Refresh() }
		oBrw143:SetValid( {|| J143VlrRec(oBrw143:Alias(),,.t. ) })
		JurSetBSize( oBrw143 )
		
		For nRot := 1 To Len( aRotina )
			oBrw143:AddButton(aRotina[nRot][1], aRotina[nRot][2],, aRotina[nRot][4])
		Next nRot
		
		If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
			oBrw143:oBrowse:SetObfuscFields(aTemp[7])
		EndIf

		oBrw143:Activate()
	EndIf
EndIf
	
Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina  := {}
Local lJura049 := IsInCallStack( "JCall143" )
Local cView    := Iif(lJura049, "JA143View((TABLANC)->(Recno()))", "JA143View((TABLANC)->REC)")

aAdd( aRotina, { STR0013, "JA143SET()", 0, 2, 0, NIL } ) // "WO"
aAdd( aRotina, { STR0002, cView, 0, 2, 0, NIL } ) // "Visualizar"

If !lJura049 .And. IsInCallStack( 'JURA143' ) .And. ExistFunc( "JurFiltrWO" )
	aAdd( aRotina, { STR0049, 'JurFiltrWO("NVY", .T.)', 0, 3, 0, NIL } ) // "Filtros"
EndIf

If IsInCallStack( 'JURA049' )
	aAdd( aRotina, { STR0014, "JA143DLG()", 0, 6, 0, NIL } ) // "Alterar lote" 
EndIf 

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} J143AtuBrw
Atualiza o browse com o novo filtro.

@param    cQuery , caracter, Query que será usada como filtro

@author   Abner Fogaça
@since    10/04/2018
@version  1.0
/*/
//-------------------------------------------------------------------
Static Function J143AtuBrw(cQuery)
	Local cAlsBrw    := oTmpTable:GetAlias()
	Local aStruAdic  := {}
	Local aCmpAcBrw  := {}
	Local aTitCpoBrw := {}
	Local lEmpty     := .F.
	Local cTmpQry    := GetNextAlias()
	Local lFecha     := .T.
	
	// Executa a query da tabela temporária para verificar se está vazia.
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmpQry, .T., .T.)
	
	lEmpty := (cTmpQry)->( EOF() )
	(cTmpQry)->(dbCloseArea())
	
	If lEmpty
		If !IsBlind()
			lFecha := JurMsgErro(STR0050) // "Não foram encontrados registros para o filtro indicado!"
		EndIf
	Else
		oTmpTable:Delete()
		
		aStruAdic  := J143StruAdic()
		aCmpAcBrw  := J143CmpAcBrw()
		aTitCpoBrw := J143TitCpoBrw()
		oTmpTable  := JurCriaTmp(cAlsBrw, cQueryTmp, "NVY", , aStruAdic, aCmpAcBrw, {"REC"}, .T., , aTitCpoBrw)[1]
		oBrw143:Refresh(.T.)
	EndIf

Return ( lFecha )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de WO - Despesas

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA143" )
Local oStructNVY := FWFormStruct( 2, "NVY" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Iif(cLojaAuto == "1", oStructNVY:RemoveField( "NVY_CLOJA" ), )
JurSetAgrp( 'NVY',, oStructNVY )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA143_NVY", oStructNVY, "NVYMASTER" )
oView:CreateHorizontalBox( "NVYFIELDS", 100 )
oView:SetOwnerView( "JURA143_NVY", "NVYFIELDS" )

If !IsInCallStack( 'JURA049' )
	oView:SetDescription( STR0007 ) // "WO - Despesas"
Else
	oView:SetDescription( STR0012 ) // "Operações em lote - Despesas"
EndIf
	
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de WO - Despesas

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNVY := FWFormStruct( 1, "NVY" )

oModel:= MPFormModel():New( "JURA143", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NVYMASTER", NIL, oStructNVY, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de WO - Despesas"
oModel:GetModel( "NVYMASTER" ):SetDescription( STR0009 ) // "Dados de WO - Despesas"
JurSetRules( oModel, "NVYMASTER",, "NVY",, )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA143SET
Envia os Lançamentos para WO: Cria um registro na Tabela de WO, 
vincula os lançamentos ao número do WO e 
atualiza o valor dos lançamentos na tabela WO Caso

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA143SET()
Local lRet       := .T.
Local lWOLanc    := .F.
Local cMarca     := oBrw143:Mark()
Local lInvert    := oBrw143:IsInvert()
Local nCountNVY  := 0
Local nQtdDesp   := 0
Local nMotWO     := 0
Local cFiltro    := ""
Local cMsg       := ""
Local cQuery     := ""
Local cDefFiltro := "NVY_SITUAC == '1'"
Local aOBS       := {}
Local aTimShePro := {}
Local aTimeSNWO  := {}
Local aMotWO     := {{""}}
Local lNVYCMotWR := NVY->(ColumnPos("NVY_CMOTWR")) > 0 // Proteção 12.1.33

cFiltro := oBrw143:FWFilter():GetExprADVPL()

If Empty(cFiltro)
	cFiltro += "(NVY_OK " + IIF(lInvert, "<>", "==") + " '" + cMarca + "')"
Else
	cFiltro += " .And. (NVY_OK " + IIF(lInvert, "<>", "==") + " '" + cMarca + "')"
EndIf

cAux := &( '{|| ' + cFiltro + ' }')
(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
(TABLANC)->( dbSetOrder(1) )

(TABLANC)->(DbEval({|| nCountNVY++}))

If nCountNVY == 0
	lRet := JurMsgErro(STR0029) //"Não há dados marcados para execução em lote!"
EndIf

If lRet .And. lNVYCMotWR
	cQuery := "SELECT NVY_CMOTWR "
	cQuery +=  " FROM " + IIF(Type("oTmpTable") == "O", oTmpTable:GetRealName(), RetSqlName("NVY"))
	cQuery += " WHERE NVY_OK " + IIF(lInvert, "<>", "=") + " '" + cMarca + "'"
	cQuery += " GROUP BY NVY_CMOTWR "

	aMotWO := JurSQL(cQuery, {"NVY_CMOTWR"})
	aMotWO := IIf(Len(aMotWO) == 0, {{""}}, aMotWO)
EndIf

If lRet .And. MsgYesNo(STR0034) // "Todos os registros marcados serão alterados. Deseja Continuar?"
	For nMotWO := 1 To Len(aMotWO)
		If Empty(aMotWO[nMotWO][1])
			aOBS      := JurMotWO('NUF_OBSEMI', STR0007, STR0037, "2") // "Inclusão de WO - Despesas" - "Observação - WO"
			cFilMotWO := cFiltro + IIf(lNVYCMotWR, " .And. (Empty(NVY_CMOTWR))", "")
		Else
			aOBS      := {STR0059, aMotWO[nMotWO][1]} // "Observação do WO disponível na(s) despesa(s)."
			cFilMotWO := cFiltro + IIf(lNVYCMotWR, " .And. (NVY_CMOTWR == '" + aMotWO[nMotWO][1] + "')", "")
		EndIf

		If !Empty(aOBS)
			lWOLanc  := .T. // Indica que houveram registros enviados para WO

			cAux := &( '{|| ' + cFilMotWO + ' }')
			(TABLANC)->( dbSetFilter( cAux, cFilMotWO ) )
			(TABLANC)->( dbSetOrder(1) )

			nQtdDesp += JAWOLANCTO(2, aOBS, cFilMotWO, cDefFiltro, TABLANC, @aTimShePro, @aTimeSNWO)
		EndIf
	Next

	If lWOLanc
		cMsg := Alltrim(Str(nQtdDesp)) + STR0011 // " lançamentos alterados."
		If ExistBlock('JA143ADD')
			ExecBlock('JA143ADD', .F., .F., { cFiltro, cDefFiltro } )
		EndIf
	EndIf
EndIf

cAux := &( "{|| " + cDefFiltro + " }") // Retorna o Filtro padrão - somente lançamentos ativos...
(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )

If Len(aTimeSNWO) > 0
	cMsg += CRLF + CRLF + Alltrim(Str(Len(aTimeSNWO))) + STR0058 + CRLF // "Lançamentos não alterados:"
	aEval(aTimeSNWO,{ |t| IIF( !Empty(t[2] ), cMsg := cMsg + t[2] + CRLF, )})
EndIf

If !Empty(cMsg)
	If JurGetLog()
		AutoGrLog( cMsg )
		JurLogLote()  // Mostra o Log da operação
	Else
		JurLogLote() //Descarta o arquivo de log utlizado
		ApMsgInfo( cMsg )
	EndIf
EndIf

JA143ATU()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA143DLG()
Monta a tela para Alteração de Despesas.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA143DLG()
Local aArea       := GetArea()
Local lRet        := .T.
Local cMarca      := oBrw143:Mark()
Local lInvert     := oBrw143:IsInvert()
Local cDefFiltro  := "NVY_SITUAC == '1'"
Local cFiltro     := oBrw143:FWFilter():GetExprADVPL()
Local nCountNVY   := 0
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oLayer      := FWLayer():New()
Local oMainColl   := Nil
Local nLocLj      := 0
Local cJcaso      := SuperGetMv("MV_JCASO1", .F., '1')  //1 – Por Cliente; 2 – Independente de cliente
Local aCposLGPD   := {}
Local aNoAccLGPD  := {}
Local aDisabLGPD  := {}
Local lExecTir    := __CUSERID == "000481" .And. CUSERNAME == "PFSCOMPART" .And. GetRemoteType() == REMOTE_HTML // Execução via TIR

Private oCliOr    := Nil
Private oDesCli   := Nil
Private oLojaOr   := Nil
Private oCasoOr   := Nil
Private oAdv      := Nil
Private oDesAdv   := Nil
Private oDesCas   := Nil
Private oDesp     := Nil
Private oDesDesp  := Nil
Private cCobra    := "1"
Private cSigla    := CriaVar('NVY_SIGLA', .F.)
Private oObsCob   := Nil

Private oChkCli   := Nil
Private oChkDesp  := Nil
Private oChkCob   := Nil
Private oChkAdv   := Nil

Private oDlg
Private cCliOr    := CriaVar('NVY_CCLIEN')
Private cDesCli   := ""
Private cLojaOr   := CriaVar('NVY_CLOJA')
Private cCliGrp   := CriaVar('A1_GRPVEN')
Private cCasoOr   := CriaVar('NVY_CCASO')
Private cDesCas   := ""
Private cAdv      := CriaVar('NVY_CPART')
Private cDesAdv   := ""
Private cDesp     := CriaVar('NVY_CTPDSP')
Private cDesDesp  := ""
Private cObsCob   := CriaVar('NVY_OBSCOB')

Private lChkCli   := lExecTir
Private lChkDesp  := lExecTir
Private lChkCob   := lExecTir
Private lChkAdv   := lExecTir

If Empty(cFiltro)
	cFiltro += "(NVY_OK " + IIF(lInvert, "<>", "==") + " '" + cMarca + "')" + " .And. (NVY_FILIAL = '" + xFilial( "NVY" ) + "')"
Else
	cFiltro += " .And. (NVY_OK " + IIF(lInvert, "<>", "==") + " '" + cMarca + "')" + " .And. (NVY_FILIAL = '" + xFilial( "NVY" ) + "')"
EndIf

cAux := &( '{|| ' + cFiltro + ' }')
(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
(TABLANC)->( dbSetOrder(1) )

(TABLANC)->(DbEval({||nCountNVY++}))

If nCountNVY == 0
	lRet := JurMsgErro(STR0029) //"Não há dados marcados para execução em lote!"
EndIf

If lRet

	If _lFwPDCanUse .And. FwPDCanUse(.T.)
		aCposLGPD := {"NVY_DCLIEN","NVY_DCASO","NVY_DPART","NVY_DTPDSP"}
  
		aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0015 FROM 0, 0 TO 340, 520 PIXEL //"Alteração de Despesas em lote"
	oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	// "Ativar"//
	oChkCli := TJurCheckBox():New(015, 005, "", {|| }, oMainColl, 08, 08, , {|| }, , , , , , .T., , , )
	oChkCli:SetCheck(lChkCli)
	oChkCli:bChange := {|| lChkCli := oChkCli:Checked(),;
	                       JurChkCli(@oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oDesCli, @cDesCli, @oCasoOr, @cCasoOr, @oDesCas, @cDesCas, lChkCli)}

	// "Cód Cliente" //
	oCliOr := TJurPnlCampo():New(005, 015, 060, 022, oMainColl, AllTrim(RetTitle("NVY_CCLIEN")), ("A1_COD"), {|| }, {|| },,,, 'SA1NUH')
	oCliOr:SetValid({|| JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, "CLI",;
	                                ,,@oDesCli, @cDesCli, @oDesCas, @cDesCas) })
	oCliOr:SetWhen({||lChkCli})

	// "Loja" //
	oLojaOr := TJurPnlCampo():New(005, 085, 045, 022, oMainColl, AllTrim(RetTitle("NX1_CLOJA")), ("A1_LOJA"), {|| }, {|| },,,)
	oLojaOr:SetValid({|| JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, "LOJ",;
	                                ,, @oDesCli, @cDesCli, @oDesCas, @cDesCas) })
	oLojaOr:SetWhen({||lChkCli})
	If (cLojaAuto == "1")
		oLojaOr:Hide()
		nLocLj := 45
	EndIf

	// "NOME CLIENTE" //
	oDesCli := TJurPnlCampo():New(005, 130 - nLocLj, 120 + nLocLj, 022, oMainColl, AllTrim(RetTitle("NVY_DCLIEN")), ("A1_NOME"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NVY_DCLIEN") > 0)
	oDesCli:SetWhen({||.F.})

	//----------------

	// "CÓD CASO" //
	oCasoOr := TJurPnlCampo():New(030, 015, 060, 022, oMainColl, AllTrim(RetTitle("NVY_CCASO")), ("NVY_CCASO"), {|| }, {|| },,,, 'NVELOJ')
	oCasoOr:SetValid({|| JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, "CAS",;
	                                ,, @oDesCli, @cDesCli, @oDesCas, @cDesCas, "NVE_LANDSP") })
	oCasoOr:SetWhen({||lChkCli .AND. ((cJcaso == "1" .AND. !Empty(cLojaOr)) .OR. cJcaso == "2")})

	// "TÍTULO CASO" //
	oDesCas := TJurPnlCampo():New(030, 085, 165, 022, oMainColl, AllTrim(RetTitle("NVY_DCASO")), ("NVY_DCASO"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NVY_DCASO") > 0)
	oDesCas:SetWhen({||.F.})

	//-----------------

	// "Ativar" //
	oChkAdv := TJurCheckBox():New(065, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkAdv:SetCheck(lChkAdv)
	oChkAdv:bChange := {||lChkAdv := oChkAdv:Checked(), JurValAdv(@cSigla, @oAdv, @cDesAdv, @oDesAdv)}

	// "Sig Solicita" //
	oAdv := TJurPnlCampo():New(055, 015, 060, 022, oMainColl, AllTrim(RetTitle("NVY_SIGLA")), ("NVY_SIGLA"), {|| }, {|| },,,, 'RD0ATV')
	oAdv:SetValid({|| JurDesAdv(cSigla, @cDesAdv, @oDesAdv)})
	oAdv:SetWhen({||lChkAdv})
	oAdv:SetChange ({|| cSigla := oAdv:GetValue(), oDesAdv:SetValue(Posicione('RD0', 9, xFilial('RD0') + Alltrim(cSigla), 'RD0_NOME'))})

	// "Desc Solicita" //
	oDesAdv := TJurPnlCampo():New(055, 085, 165, 022, oMainColl, AllTrim(RetTitle("NVY_DPART")), ("NVY_DPART"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NVY_DPART") > 0)
	oDesAdv:SetWhen({||.F.})
	oDesAdv:SetChange ({|| cDesAdv := oDesAdv:GetValue()})

	//-----------------

	// "Ativar" //
	oChkDesp := TJurCheckBox():New(090, 005, "",  {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkDesp:SetCheck(lChkDesp)
	oChkDesp:bChange := {||lChkDesp := oChkDesp:Checked(), ValDesp()}

	// "Cód Tp Desp" //
	oDesp := TJurPnlCampo():New(080, 015, 060, 022, oMainColl, AllTrim(RetTitle("NVY_CTPDSP")), ("NVY_CTPDSP"), {|| }, {|| },,,, 'NRH')
	oDesp:SetValid({|| DesDesp() })
	oDesp:SetWhen({||lChkDesp})
	oDesp:SetChange ({|| cDesp := oDesp:GetValue(),;
	                     oDesDesp:SetValue(JurGetDados('NRH', 1, xFilial('NRH') + Alltrim(cDesp), 'NRH_DESC')) })

	// "Desc Tp Desp" //
	oDesDesp := TJurPnlCampo():New(080, 085, 165, 022, oMainColl, AllTrim(RetTitle("NVY_DTPDSP")), ("NVY_DTPDSP"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NVY_DTPDSP") > 0)
	oDesDesp:SetWhen({||.F.})
	oDesDesp:SetChange ({|| cDesDesp := oDesDesp:GetValue()})

	//------------------

	// "Ativar" //
	oChkCob := TJurCheckBox():New(115, 005, "", {|| }, oMainColl, 08, 08, ,{|| } , , , , , , .T., , , )
	oChkCob:SetCheck(lChkCob)
	oChkCob:bChange := {||lChkCob := oChkCob:Checked(), ValCob()}

	// "Cobrar?" //
	oCobra := TJurPnlCampo():New(105, 015, 050, 025, oMainColl, AllTrim(RetTitle("NVY_COBRAR")), ("NVY_COBRAR"), {|| }, {|| },,,,) 
	oCobra:SetWhen({||lChkCob})
	oCobra:SetChange ({|| cCobra := oCobra:GetValue(), Iif(cCobra != "2", (oObsCob:SetValue(""), cObsCob := ""),)})

	// "Obs Não Cob" //
	oObsCob := TJurPnlCampo():New(105, 085, 165, 022, oMainColl, AllTrim(RetTitle("NVY_OBSCOB")), ("NVY_OBSCOB"), {|| }, {|| },,,,)
	oObsCob:SetWhen({|| (cCobra == "2" .AND. lChkCob) })
	oObsCob:SetChange ({|| cObsCob := oObsCob:GetValue()})

	//------------------

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
				(oDlg, {|| IIf(JA143ALT(), oDlg:End(), Nil)}, {|| oDlg:End() },; //"Sair"
				, /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F. )

EndIf

cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )

RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ValDesp()
Função habilitar/ Desabilitar o Tipo de Despesa da alteração de DP em lote

@Param cCampo Campo a ser validado

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//------------------------------------------------------------------- 
Static Function ValDesp()
Local lRet := .T.

If lChkDesp   
	oDesp:Enable()
	oDesp:Refresh()
	oDesDesp:Enable()
	oDesDesp:Refresh()
Else
    cDesp:= CriaVar('NVY_CTPDSP')
	oDesp:Disable()
	oDesp:SetValue(cDesp)
	cDesDesp := ""
	oDesDesp:Disable()
	oDesDesp:SetValue(cDesDesp)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValCob()
Função habilitar/ Desabilitar o Cobrar? da alteração de Despesa em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------  
Static Function ValCob()
Local lRet := .T.

If lChkCob   
	oCobra:Enable()
	oCobra:Refresh()
Else
	cCobra := ""
    oCobra:Disable()
	oCobra:SetValue(cCobra)
EndIf

Return (lRet)   

//-------------------------------------------------------------------
/*/{Protheus.doc} JA143ALT()
Alterar as Despesas em Lote

@author Luciano Pereira dos Santos
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA143ALT()
Local lRet := .T.
	Processa( {|| lRet := JA143ALT2() }, STR0015, STR0038, .F. ) // "Alteração de Despesas em lote" "Aguarde..."
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA143ALT2()
Alterar as Despesas em Lote

@author Luciano Pereira dos Santos
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA143ALT2()
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local aAreaNVY   := NVY->(GetArea())
Local lRet       := .T.
Local cMarca     := oBrw143:Mark()
Local lInvert    := oBrw143:IsInvert()
Local cDefFiltro := "NVY_SITUAC == '1'"
Local cFiltro    := oBrw143:FWFilter():GetExprADVPL()
Local nCountNVY  := 0
Local cCobOld    := ""
Local cCobNew    := cCobra
Local lJura049   := IsInCallStack( "JCall143" )
Local nPosicao   := Iif(lJura049, (TABLANC)->(Recno()), (TABLANC)->REC)	
Local lJA143LOT  := ExistBlock( 'JA143LOT' )
Local cMemoLog   := ""
Local aErro      := {}
Local nQtdNVY    := 0
Local nCount     := 0
Local cVldMsg    := ""
Local lJurBlqLnc := .F.

If Empty(cCliOr) .And. Empty(cDesp) .And. Empty(cCobra) .And. Empty(cCasoOr) .And. Empty(cLojaOr) .And. Empty(cSigla)
	lRet := JurMsgErro(STR0025) //"Informe um item para alterar!"
EndIf

If !Empty(cClior) .Or. !Empty(cLojaOr) .And. lRet
	If Empty(cCasoOr)
		lRet := JurMsgErro(STR0024) //"Informe cliente, loja e caso!"
	EndIf
EndIf

If !Empty(cCasoOr) .And. lRet
	If Empty(cClior) .Or. Empty(cLojaOr)
		lRet := JurMsgErro(STR0025) //"Informe cliente, loja e caso!"
	EndIf
EndIf

If (cCobNew == "2") .And. Empty(cObsCob) .And. lRet
	lRet := JurMsgErro(STR0036) //"A observação de não cobrável é obrigatória!"
EndIf

If lRet .And. ExistBlock( 'JA143CAN' )
	/*
	PARAMIXB
	Variavel
	oBrw143 [01] O  Objeto de MarkBrowse
	lChkCli	[02] L	.T. Indica operação de Cliente/Loja/Caso
	cCliOr	[03] C	Cód. Cliente
	cLojaOr	[04] C 	Cód. Loja
	cCasoOr	[05] C 	Cód. Caso
	lChkAdv	[06] L	.T. Indica operação com Participante (Sigla)
	cSigla	[07] C 	Sigla Solicit.
	lChkDesp[08] L 	.T. Indica operação com Tipo de Despesa
	cDesp	[09] C 	Cód. Tipo Despesa
	lChkCob	[10] L 	.T. Indica operação de cobrar
	cCobra	[11] C  Cobrar Sim/Não
	cObsCob [12] C  Observação para Não Cobrar
	*/
	lRet := ExecBlock( 'JA143CAN', .F., .F., {oBrw143, lChkCli, cCliOr, cLojaOr, cCasoOr, lChkAdv, cSigla, lChkDesp, cDesp, lChkCob, cCobra, cObsCob} )
EndIf

If lRet
	If Empty(cFiltro)
		cFiltro += "(NVY_OK " + IIF(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .And. (NVY_FILIAL = '" + xFilial("NVY") + "')"
	Else
		cFiltro += " .And. (NVY_OK " + IIF(lInvert, "<>", "==") + " '" + cMarca + "')" + " .And. (NVY_FILIAL = '" + xFilial("NVY") + "')"
	EndIf
	
	cAux := &( '{|| ' + cFiltro + ' }')
	(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
	(TABLANC)->( dbSetOrder(1) )
	
	(TABLANC)->(DbEval({|| nQtdNVY++}))
	
	If nQtdNVY == 0
		lRet := JurMsgErro(STR0029) //"Não há dados marcados para execução em lote!"
	EndIf
	
	If lRet .And. MsgYesNo( STR0034 ) //"Todos os registros marcados serão alterados. Deseja Continuar?" 
		ProcRegua(nQtdNVY)
		(TABLANC)->( dbgotop() )
		
		AutoGrLog(STR0015) //"Alteração de Time-sheets em lote"
		AutoGrLog(Replicate('-', 65) + CRLF) 
		
		oModelFW := FWLoadModel( "JURA049" )
		JurSetRules( oModelFW, "NVYMASTER",, "NVY",, )
		(TABLANC)->(DbSetOrder(1))
		While !((TABLANC)->( EOF() ))
			nCount++ //regua
			If lJurBlqLnc
				cVldMsg := JurBlqLnc((TABLANC)->NVY_CCLIEN, (TABLANC)->NVY_CLOJA, (TABLANC)->NVY_CCASO, (TABLANC)->NVY_DATA, "DEP", "0")
			EndIf
			
			If(Empty(cVldMsg)) .And. NVY->(DbSeek((xFilial("NVY") + (TABLANC)->NVY_COD))) //reposiciona o registro
				oModelFW:SetOperation( 4 )
				oModelFW:Activate()
			
				If !Empty(cCliOr)
					oModelFW:ClearField("NVYMASTER", "NVY_CCASO")
					oModelFW:ClearField("NVYMASTER", "NVY_CLOJA")
					oModelFW:ClearField("NVYMASTER", "NVY_CCLIEN")
					oModelFW:ClearField("NVYMASTER", "NVY_CGRUPO")
					lRet := oModelFW:SetValue("NVYMASTER", "NVY_CCLIEN", cClior) .And. ;
					        oModelFW:SetValue("NVYMASTER", "NVY_CLOJA", cLojaOr) .And. ; 
					        oModelFW:SetValue("NVYMASTER", "NVY_CCASO", cCasoOr)
					JA049VALC()
				EndIf
				
				If !Empty(cSigla)
					lRet := oModelFW:SetValue("NVYMASTER", "NVY_SIGLA", cSigla)
				EndIf
				
				If !Empty(cDesp) .And. lRet
					lRet := oModelFW:SetValue("NVYMASTER", "NVY_CTPDSP", cDesp)
					JA049VALC()
				EndIf
				
				If !Empty(cCobra) .And. lRet
					cCobOld := oModelFW:GetValue("NVYMASTER", "NVY_COBRAR")
					
					If cCobOld != cCobNew
						lRet := oModelFW:SetValue("NVYMASTER", "NVY_COBRAR", cCobNew)
						JA49VLDCB(JurUsuario(__cUserID), .F., oModelFW)
						If cCobNew == "2"
							lRet := oModelFW:SetValue("NVYMASTER", "NVY_OBSCOB", cObsCob)
						EndIf
					EndIf
				EndIf
				
				If lRet := oModelFW:VldData()
	
					oModelFW:CommitData()
					ncountNVY++
					
					RecLock(TABLANC, .F.)
					(TABLANC)->NVY_OK := "" 
					(TABLANC)->(MsUnlock())
					(TABLANC)->(DbCommit())

				Else
					aErro := oModelFW:GetErrorMessage()
				 	
				 	cMemoLog += ( STR0039 + (TABLANC)->NVY_COD ) + CRLF //"Despesa: "
					If !Empty(AllToChar(aErro[4]))
						cMemoLog += ( STR0040 + AllToChar(aErro[4]) ) + CRLF //"Campo: "
					EndIf
					cMemoLog += ( STR0041 + AllToChar(aErro[6]) ) + CRLF //"Erro: "
				 	AutoGrLog(cMemoLog) //Grava o Log
				 	cMemoLog := ""  // Limpa a critica para o proximo TimeSheet
			
				EndIf
				oModelFW:DeActivate()
			
			Else
				cMemoLog += ( STR0039 + (TABLANC)->NVY_COD ) + CRLF //"Despesa: "
				cMemoLog += ( STR0041 + AllToChar(cVldMsg) ) + CRLF //"Erro: "
				AutoGrLog(cMemoLog) //Grava o Log
				cMemoLog := ""  // Limpa a critica para o proximo TimeSheet
			EndIf
			
			IncProc(STR0038 + " " + AllTrim(Str(nCount)) + " / " + AllTrim(Str(nQtdNVY))) //#"Aguarde..."
			
			If lJA143LOT
				/*
				PARAMIXB
				Variavel 
				lRet	[01] L	Operação realizada (.T.) ou não (.F.) para a despesa
				lChkCli	[02] L	.T. Indica operação de Cliente/Loja/Caso  
				cCliOr	[03] C	Cód. Cliente
				cLojaOr	[04] C 	Cód. Loja
				cCasoOr	[05] C 	Cód. Caso
				lChkAdv	[06] L	.T. Indica operação com Participante (Sigla) 
				cSigla	[07] C 	Sigla Solicit.
				lChkDesp[08] L 	.T. Indica operação com Tipo de Despesa
				cDesp	[09] C 	Cód. Tipo Despesa
				lChkCob	[10] L 	.T. Indica operação de cobrar
				cCobra	[11] C  Cobrar Sim/Não
				cObsCob [12] C  Observação para Não Cobrar
				*/
				ExecBlock( 'JA143LOT', .F., .F., {lRet, lChkCli, cCliOr, cLojaOr, cCasoOr, lChkAdv, cSigla, lChkDesp, cDesp, lChkCob, cCobra, cObsCob} )
			EndIf
			
			lRet := .T.  //Volta para .T. para validar a próxima DP
			(TABLANC)->( dbSkip())
		EndDo
		oModelFW:Destroy()
		cMemoLog := CRLF + Replicate('-', 65) + CRLF
		If (ncountNVY) != 0
			cMemoLog += AllTrim(Str(ncountNVY)) + STR0028 + CRLF //" Despesa(s) alterada(s) com sucesso!"
		EndIf
		If (nQtdNVY - ncountNVY) != 0
			cMemoLog += AllTrim(Str(nQtdNVY - ncountNVY)) + STR0044 + CRLF //# " Time-sheet(s) não alterado(s)!"
		EndIf
		cMemoLog += Replicate('-', 65) + CRLF 
		AutoGrLog(cMemoLog)
		JurSetLog(.T.)

		cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
		(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )
		
		(TABLANC)->(DbGoTO(nPosicao))
		
		JA143ATU()
		JurLogLote()  // Mostra o Log da operação
	
	Else
		lRet := .F.
	EndIf
	
EndIf

RestArea( aAreaNVY )
RestArea( aAreaNX0 )
RestArea( aArea )

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} DesDesp()
Função para carregar a descrição de despesas

@author Luciano Pereira dos Santos
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DesDesp()
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNRH := NRH->(GetArea())

If !Empty(cDesp)
	NRH->(DbSetOrder(1))
	If NRH->(Dbseek(xFilial('NRH') + cDesp))
		cDesDesp := JurGetDados('NRH', 1, xFilial('NRH') + Alltrim(cDesp), 'NRH_DESC')
	Else
		cDesp := CriaVar('NRH_COD', .F.)
		oDesp:SetValue(cDesp)
		cDesDesp := ""
		ApMsgStop(STR0046) //"Despesa inválida."
		lRet := .F.
	EndIf
Else
	cDesDesp := ""
EndIf

oDesDesp:SetValue(cDesDesp)
RestArea(aAreaNRH)
RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA143ATU()
Atualiza a tela.

@author bruno.ritter
@since 24/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA143ATU()
Local lJura049  := IsInCallStack( "JCall143" )
Local cAliasTab := ""
Local aStruAdic := {}

If !lJura049
	cAliasTab := oTmpTable:GetAlias()
	oTmpTable:Delete()
	
	aStruAdic := J143StruAdic()
	oTmpTable := JurCriaTmp(cAliasTab, cQueryTmp, "NVY", , aStruAdic)[1]
EndIf

oBrw143:Refresh()
oBrw143:GoTop(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA143View()
Visualização do lançamento com base em tabela temporária.

@param  nRecno número da tabela NVY

@author bruno.ritter
@since 13/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA143VIEW(nRecno)
Local aArea    := GetArea()
Local aAreaNVY := NVY->(GetArea())

NVY->(DbGoTO(nRecno))
If NVY->(NVY_FILIAL + NVY_COD) == (TABLANC)->(NVY_FILIAL + NVY_COD)
	FWExecView(STR0002, 'JURA049', 1,, { || lOk := .T., lOk }) // #"Visualizar"
Else
	JurMsgErro( STR0047 ) //"Registro não encontrado!"
EndIf

RestArea( aAreaNVY )
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J143QryTmp()
Rotina para gerar uma query da NVY para gerar a tabela temporária na função JurCriaTmp
(Cópia da J049QryTmp devido a congelamento da 12.1.17. Após o congelamento, excluir essa
função e usar a da JURA049).

@author bruno.ritter - Cristina Cintra
@since 31/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J143QryTmp( aFiltros )
	Local cQry       := ""
	Local cJoinCont  := ""
	Local cCondic    := ""
	Local cCampos    := JurCmpSelc("NVY", {})
	Local aCamposJL  := {}
	Local cCamposJL  := ""
	Local lSubQry    := .F.
	Local lNVYCMotWR := NVY->(ColumnPos("NVY_CMOTWR")) > 0 // Proteção 12.1.33
	
	cCampos := StrTran(cCampos, "NVY_OK    ,")
	Aadd(aCamposJL,{"ACY.ACY_DESCRI" , "NVY_DGRUPO" })
	Aadd(aCamposJL,{"SA1.A1_NOME"    , "NVY_DCLIEN" })
	Aadd(aCamposJL,{"NVE.NVE_TITULO" , "NVY_DCASO" })
	Aadd(aCamposJL,{"RD0.RD0_SIGLA"  , "NVY_SIGLA" })
	Aadd(aCamposJL,{"NUT.NUT_CCONTR" , "NT0_COD"})
	Aadd(aCamposJL,{"NRH.NRH_DESC"   , "NVY_DTPDSP" })
	IIf(lNVYCMotWR, Aadd(aCamposJL, {"NXV.NXV_DESC", "NVY_DMOTWR"}), Nil)
	cCamposJL := JurCaseJL(aCamposJL)

	cQry := "SELECT " + cCampos + cCamposJL
	cQry += " ' ' NVY_OK, NVY.R_E_C_N_O_ REC, "

	cQry += " CASE "
	cQry += " WHEN NRH.NRH_COBRAR = '1' THEN '" + STR0051 + "' " // "Sim" 
 	cQry += " ELSE '" + STR0052 + "' " // Não
	cQry += " END NRH_COBRAR, "
	
	cQry += " CASE "
	cQry += " WHEN NUT.NUT_CCONTR IS NULL THEN '   ' "
	cQry += " WHEN EXISTS(SELECT NTK.R_E_C_N_O_ FROM " + RetSqlName("NTK") + " NTK WHERE NTK.NTK_FILIAL = '" + xFilial("NTK") + "' AND NTK.NTK_CCONTR = NUT.NUT_CCONTR AND NTK.NTK_CTPDSP = NVY.NVY_CTPDSP AND NTK.D_E_L_E_T_ = ' ' ) "
	cQry +=            " THEN '" + STR0052 + "' " // "Não" 
 	cQry += " ELSE '" + STR0051 + "' " // "Sim"
	cQry += " END NTKCOBRAR, "
	
	cQry += " CASE "
	cQry += " WHEN EXISTS(SELECT NUC.R_E_C_N_O_ FROM " + RetSqlName("NUC") + " NUC WHERE NUC.NUC_FILIAL = '" + xFilial("NUC") + "' AND NUC.NUC_CCLIEN = NVY.NVY_CCLIEN AND NUC.NUC_CLOJA = NVY.NVY_CLOJA AND NUC.NUC_CTPDES = NVY.NVY_CTPDSP AND NUC.D_E_L_E_T_ = ' ') "
	cQry +=            " THEN '" + STR0052 + "' " // "Não"
 	cQry += " ELSE '" + STR0051 + "' " // "Sim"
	cQry += " END NUCCOBRAR "

	cQry += " FROM " + RetSqlName( 'NVY' ) + " NVY "
	cQry += " INNER JOIN "+ RetSqlName( 'NRH' ) + " NRH "
	cQry += " ON  NRH.NRH_COD = NVY.NVY_CTPDSP "
	
	If ! Empty( aFiltros[nPCobraNRH] ) // 10 - Tipo de Despesa - NRH
		cQry += " AND NRH.NRH_COBRAR = '" + aFiltros[nPCobraNRH] + "' "
	EndIf
	
	cQry +=                                         " AND NRH.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NRH.NRH_FILIAL = '" + xFilial("NRH") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'ACY' ) + " ACY "
	cQry +=                                         " ON  ACY.ACY_GRPVEN = NVY.NVY_CGRUPO "
	cQry +=                                         " AND ACY.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
	cQry +=                                         " ON  SA1.A1_COD  = NVY.NVY_CCLIEN "
	cQry +=                                         " AND SA1.A1_LOJA = NVY.NVY_CLOJA "
	cQry +=                                         " AND SA1.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'NVE' ) + " NVE "
	cQry +=                                         " ON  NVE.NVE_CCLIEN = NVY.NVY_CCLIEN "
	cQry +=                                         " AND NVE.NVE_LCLIEN = NVY.NVY_CLOJA "
	cQry +=                                         " AND NVE.NVE_NUMCAS = NVY.NVY_CCASO "
	cQry +=                                         " AND NVE.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0 "
	cQry +=                                         " ON  RD0.RD0_CODIGO = NVY.NVY_CPART "
	cQry +=                                         " AND RD0.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	
	If lNVYCMotWR
		cQry += " LEFT JOIN " + RetSqlName("NXV") + " NXV "
		cQry +=   " ON NXV.NXV_FILIAL = '" + xFilial("NXV") + "' "
		cQry +=  " AND NXV.NXV_COD = NVY.NVY_CMOTWR "
		cQry +=  " AND NXV.D_E_L_E_T_ = ' ' "
	EndIf

	If ! Empty( aFiltros[nPContr] ) .Or. ! Empty( aFiltros[nPContr] ) // 5 - Contrato
		cJoinCont := " INNER JOIN "
	Else
		cJoinCont := " LEFT JOIN "
	EndIf

	cQry += cJoinCont + RetSqlName("NUT") + " NUT "
	cQry +=                                       " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQry +=                                       " AND NUT.NUT_CCLIEN = NVY.NVY_CCLIEN "
	cQry +=                                       " AND NUT.NUT_CLOJA = NVY.NVY_CLOJA "
	cQry +=                                       " AND NUT.NUT_CCASO = NVY.NVY_CCASO "
	If ! Empty( aFiltros[nPContr] ) // 5 - Contrato
		cQry +=                                   " AND NUT.NUT_CCONTR = '" + aFiltros[nPContr] + "' " // 5 - Contrato
	EndIf
	cQry +=                                       " AND NUT.D_E_L_E_T_ = ' ' "

	cQry += " WHERE NVY.NVY_SITUAC = '1' "
	cQry += " AND NVY.D_E_L_E_T_ = ' ' "
	cQry += " AND NVY.NVY_FILIAL = '" + xFilial( "NVY" ) + "' "
	cQry += " AND (NUT.NUT_CCONTR IS NULL OR EXISTS (SELECT NT0.R_E_C_N_O_ FROM " + RetSqlName("NT0") + " NT0 "
	cQry +=                                       " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQry +=                                       " AND NT0.NT0_COD = NUT.NUT_CCONTR "
	cQry +=                                       " AND NT0.NT0_DESPES = '1' "
	cQry +=                                       " AND NT0.D_E_L_E_T_ = ' ' )) "
	
	If !Empty( aFiltros[nPGrCli] ) .And. ( Empty( aFiltros[nPClien] ) .And. Empty( aFiltros[nPLoja] ) ) // 1 - Filtra Grupo - Apenas quando o Cliente e Loja estiverem vazios
		cQry += " AND NVY.NVY_CGRUPO = '" + aFiltros[1] + "' "
	EndIf
	
	If ! Empty( aFiltros[nPClien] ) // 2 - Filtra Cliente
		cQry += " AND NVY.NVY_CCLIEN = '" + aFiltros[2] + "' "
	EndIf
	
	If ! Empty( aFiltros[nPLoja] ) // 3 - Filtra Loja
		cQry += " AND NVY.NVY_CLOJA = '" + aFiltros[3] + "' "
	EndIf
	
	If ! Empty( aFiltros[nPCaso] ) // 4 - Filtra Caso
		cQry += " AND NVY.NVY_CCASO = '" + aFiltros[4] + "' "
	EndIf
	
	If ! Empty( aFiltros[nPDtIni] ) .Or. ! Empty( aFiltros[nPDtFim] ) // 6 - Data inicial // 7 - Data Final
		If Empty( aFiltros[nPDtFim] )
			cQry += "  AND NVY.NVY_DATA >= '" + DtoS( aFiltros[nPDtIni] ) + "' "
		Else
			cQry += " AND NVY.NVY_DATA BETWEEN '" + DtoS( aFiltros[nPDtIni] ) + "' " + " AND '" + DtoS( aFiltros[nPDtFim] ) + "' "
		EndIf
	EndIf
	
	If ! Empty( aFiltros[nPTipo] ) // 8 - Tipo de Despesa - NVY
		cQry += " AND NVY.NVY_CTPDSP = '" + aFiltros[8] + "' "
	EndIf
	
	If ! Empty( aFiltros[nPCobraNVY] ) // 9 - Cobrar na despesa?
		cQry += " AND NVY.NVY_COBRAR = '" + aFiltros[9] + "' "
	EndIf

	If !Empty(aFiltros[nPMotWODesp]) // 14 - Filtra apenas despesas com motivo de WO preenchido?
		If SubStr(aFiltros[nPMotWODesp], 1, 1) == "1"
			cQry += " AND NVY.NVY_CMOTWR <> '" + AvKey(" ", "NVY_CMOTWR") + "' "
		Else
			cQry += " AND NVY.NVY_CMOTWR = '" + AvKey(" ", "NVY_CMOTWR") + "' "
		EndIf
	EndIf

	// Filtra depesas no contrato e/ou no cliente
	If ! Empty( aFiltros[nPCobraNTK] ) // 11 - Despesas cobráveis no contrato?
		//----------------
		// Monta subquery 
		//----------------
		cQry     := J143SubQry( cQry )
		lSubQry  := .T.
	
		Do Case
			Case aFiltros[nPCobraNTK] == "1" // Filtra somente despesas cobráveis no contrato
				cQry += " NTKCOBRAR = '" + STR0051 + "' " // "Sim"
		
			Case aFiltros[nPCobraNTK] == "2" // Filtra somente despesas NÃO cobráveis no contrato
				cQry += " NTKCOBRAR = '" + STR0052 + "' " // "Não"
		End Case
	EndIf
	
	If ! Empty( aFiltros[nPCobraNUC] ) // 12 - Despesas cobráveis no cliente?
		//--------------------------------------------------------
		// Verifica se existe subquery e monta condição do WHERE
		//--------------------------------------------------------
		If lSubQry
			cCondic := " AND "
		Else
			cQry := J143SubQry( cQry )
		EndIf
	
		Do Case
			Case aFiltros[nPCobraNUC] == "1" // Filtra somente despesas cobráveis no cliente
				cQry += AllTrim( cCondic ) + " NUCCOBRAR = '" + STR0051 + "' " // "Sim"
			Case aFiltros[nPCobraNUC] == "2" // Filtra somente despesas NÃO cobráveis no cliente
				cQry += AllTrim( cCondic ) + " NUCCOBRAR = '" + STR0052 + "' " // "Não"
		End Case
	EndIf

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} J143SubQry
Monta subquery para filtrar despesas no contrato ou cliente

@param   cQry, caracter, Query principal

@author  Jonatas Martins
@since   16/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J143SubQry( cQry )
	Local cSubQry := ""
		
	cSubQry := " SELECT QRY.* FROM ( "
	cSubQry += cQry + " ) QRY "
	cSubQry += " WHERE "

Return ( cSubQry )

//-------------------------------------------------------------------
/*/{Protheus.doc} J143StruAdic
Estrutura adicional para incluir na tabela temporária caso exista na query. - Opcional
        Ex: aStruAdic[n][1] "NVE_SITUAC"     //Nome do campo
            aStruAdic[n][2] "Situação"       //Descrição do campo
            aStruAdic[n][3] "C"              //Tipo
            aStruAdic[n][4] 1                //Tamanho
            aStruAdic[n][5] 0                //Decimal
            aStruAdic[n][6] "@X"             //Picture

@return aStruAdic, array, Campos da estutrura adicional

@author  Jonatas Martins
@since   31/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function  J143StruAdic()
	Local aStruAdic := {}

	Aadd(aStruAdic, { "REC", "REC", "N", 100, 0, ""})
	Aadd(aStruAdic, { "NTKCOBRAR", STR0053, "C", 3, 0, ""}) // "Cobra Cont."
	Aadd(aStruAdic, { "NUCCOBRAR", STR0054, "C", 3, 0, ""}) // "Cobra Clien."

Return ( aStruAdic )

//-------------------------------------------------------------------
/*/{Protheus.doc} J143CmpAcBrw
Monta array simples de campos onde o X3_BROWSE está como NÃO e devem
ser considerados no Browse (independentemente do seu uso)

@return aCmpAcBrw, array, Campos onde o X3_BROWSE está como NÃO e devem
                          ser considerados no Browse

@author  Jonatas Martins
@since   31/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J143CmpAcBrw()
Local aCmpAcBrw  := {}
Local lNVYCMotWR := NVY->(ColumnPos("NVY_CMOTWR")) > 0 // Proteção 12.1.33

	aCmpAcBrw := {"NVY_COBRAR"}

	If lNVYCMotWR
		Aadd(aCmpAcBrw, "NVY_CMOTWR")
		Aadd(aCmpAcBrw, "NVY_DMOTWR")
	EndIf

Return ( aCmpAcBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J143TitCpoBrw
Monta array com para considerar títulos de campos diferentes do SX3

@return aTitCpoBrw, array, Títulos a ser considerados no browse

@author  Jonatas Martins
@since   31/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J143TitCpoBrw()
	Local aTitCpoBrw := {}

	Aadd(aTitCpoBrw, {"NT0_COD", STR0055}) // "Cod. Contrato"

Return ( aTitCpoBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J143VlrRec
Função que retorna se pode ser realizado o lançamento de WO da despesa
@param  cAlias   - Alias do Registro
@param  cMsg     - Mensagem de retorno
@param  lShowMsg - Exibe a mensagem se registro não pode ser selecionado
@return lValid   - Registro pode se processado/selecionado

@author  fabiana.silva
@since   11/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function J143VlrRec(cAlias, cMsg, lShowMsg)
	Local lValid     := .T.
	
	Default cMsg     := ""
	Default lShowMsg := .F.

	If ExistBlock('J143VlRc')
		aValid := ExecBlock( 'J143VlRc', .F., .F. , {cAlias} )
		lValid := aValid[01]
		cMsg   := aValid[02]
		If !lValid .AND. !Empty(cMsg) .AND. lShowMsg
			JurMsgErro(cMsg, 'J143VlRc')
		EndIf
	EndIf

Return lValid
