#INCLUDE "JURA244.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
Static _lFwPDCanUse := FindFunction("FwPDCanUse")


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA244
Histórico de Cobrança

@author Jorge Luis Branco Martins Junior
@since 28/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA244()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) // "Histórico de Cobrança"
oBrowse:SetAlias( "OHD" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "OHD" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

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

@author Jorge Luis Branco Martins Junior
@since 28/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "VIEWDEF.JURA244", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA244", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA244", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Histórico de Cobrança

@author Jorge Luis Branco Martins Junior
@since 28/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   := Nil
Local oModel  := FWLoadModel( "JURA244" )
Local oStruct := FWFormStruct( 2, "OHD" )

oStruct:RemoveField("OHD_COD")
oStruct:RemoveField("OHD_PREFIX")
oStruct:RemoveField("OHD_NUM")
oStruct:RemoveField("OHD_PARCEL")
oStruct:RemoveField("OHD_TIPO")
oStruct:RemoveField("OHD_CPART")
oStruct:RemoveField("OHD_ACRESU")

JurSetAgrp( 'OHD',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA244_VIEW", oStruct, "OHDMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA244_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Histórico de Cobrança"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Histórico de Cobrança

@author Jorge Luis Branco Martins Junior
@since 28/09/2017
@version 1.0

@obs OHDMASTER - Dados do Histórico de Cobrança
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOHD := FWFormStruct( 1, "OHD" )
Local oCommit    := JA244COMMIT():New()

oModel:= MPFormModel():New( "JURA244", /*Pre-Validacao*/, { |oModel| J244TOK(oModel) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "OHDMASTER", NIL, oStructOHD, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Histórico de Cobrança"
oModel:GetModel( "OHDMASTER" ):SetDescription( STR0009 ) // "Dados de Histórico de Cobrança"
oModel:InstallEvent("JA244COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'OHDMASTER',, 'OHD' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J244TOK(oModel)
Rotinas executadas no pós-validação do model

@author Jorge Martins
@since 02/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J244TOK(oModel)
Local lRet  := .T.
Local nOpc  := oModel:GetOperation()
Local cPart := ""

If JurIsRest()
	If nOpc != MODEL_OPERATION_VIEW
		JurMsgErro(STR0022,, STR0023) //"Para este modelo é permitida apenas a ação de Visualização (GET) via REST." -- "Altere o tipo da chamada para GET ou realize o ajuste via Protheus."
		lRet := .F.	
	EndIf
Else
	cPart := JURUSUARIO(__CUSERID)
	If nOpc == MODEL_OPERATION_UPDATE .And. Empty(cPart)
		JurMsgErro(STR0020,, STR0021) //'Não é possível realizar a alteração, pois usuário logado não está relacionado a nenhum participante.' -- 'Verifique o cadastro de participantes e realize o vínculo.'
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA244COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Martins
@since 27/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA244COMMIT FROM FWModelEvent
	Method New()
	Method BeforeTTS()
	Method InTTS()
End Class

Method New() Class JA244COMMIT
Return

Method BeforeTTS(oModel, cModelId) Class JA244COMMIT
Local nModelOp  := oModel:GetOperation()
Local oModelOHD := oModel:GetModel("OHDMASTER")
Local cAcao     := ""
Local cResumo   := ""

	If nModelOp == MODEL_OPERATION_INSERT .Or. nModelOp == MODEL_OPERATION_UPDATE
		oModelOHD:LoadValue("OHD_CPART", JURUSUARIO(__CUSERID))
	EndIf

	If nModelOp == MODEL_OPERATION_UPDATE
		cAcao   := oModelOHD:GetValue("OHD_ACAO")
		cResumo := SubStr(cAcao, 1, 250) + IIf(Len(cAcao) > 250, "...", "")
		cResumo := StrTran(cResumo, CRLF, " ")

		oModelOHD:LoadValue("OHD_ACRESU", cResumo )
	EndIf
	
Return

Method InTTS(oModel, cModelId) Class JA244COMMIT

	JFILASINC(oModel:GetModel(), "OHD", "OHDMASTER", "OHD_COD")

Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } J244BrwInc
Função criar uma janela para fazer a inclusão em lote de histórico de cobrança

@author bruno.ritter
@since 29/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J244BrwInc(cAliasInc, lAutomato, cTestCase)
Local oDlg       := Nil
Local oLayer     := FWLayer():new()
Local oMainColl  := Nil
Local dData      := Date()
Local oData      := Nil
Local cHora      := Time()
Local oHora      := Nil
Local cCodHist   := ""
Local oCodHist   := Nil
Local oDesHist   := Nil
Local cAcao      := ""
Local oAcao      := Nil
Local lExecutou  := .F.
Local bOk        := {||}
Local lCodHisVal := .T.
Local aCposLGPD     := {}
Local aNoAccLGPD    := {}
Local aDisabLGPD    := {}

Default lAutomato := .F.
Default cTestCase := "JURA244TestCase"

	If lAutomato
		If FindFunction("GetParAuto")
			aRetAuto   := GetParAuto(cTestCase)[1]
			Iif( Len(aRetAuto) >= 1 .AND. ValType(aRetAuto[1]) != "U", dData    := aRetAuto[1], ) //"Data Ação"
			Iif( Len(aRetAuto) >= 2 .AND. ValType(aRetAuto[2]) != "U", cHora    := aRetAuto[2], ) //"Hora Ação"
			Iif( Len(aRetAuto) >= 3 .AND. ValType(aRetAuto[3]) != "U", cAcao    := aRetAuto[3], ) //"Acao"
			Iif( Len(aRetAuto) >= 4 .AND. ValType(aRetAuto[4]) != "U", cCodHist := aRetAuto[4], ) //"Código Histórico Padrão"
			
			J244ExeInc(cAliasInc, dData, cHora, cCodHist, cAcao)
		EndIf
	Else

		If _lFwPDCanUse .And. FwPDCanUse(.T.)
			aCposLGPD := {"OHD_DHISTP"}

			aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
			AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

		EndIf
		DEFINE MSDIALOG oDlg TITLE STR0010 FROM 0,0 TO 430 ,440 PIXEL // "Inclusão em lote de Histórico de Cobrança"
	
		oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
		oMainColl := oLayer:GetColPanel("MainColl")
	
		oData     := TJurPnlCampo():New(005,005,060,022,oMainColl, AllTrim(RetTitle("OHD_DTACAO")) ,("OHD_DTACAO"),{|| },{|| },dData,,,)
		oData:SetValid({|| Iif(Empty(oData:GetValue()),JurMsgErro(STR0011,; //"O campo não pode ser vazio"
														"J244ExeInc",i18n(STR0012,{AllTrim(RetTitle("OHD_DTACAO"))})),) }) // "Informe um valor para o campo '#1'."
	
		oHora     := TJurPnlCampo():New(005,070,030,022,oMainColl, AllTrim(RetTitle("OHD_HRACAO")) ,("OHD_HRACAO"),{|| },{|| },cHora,,,)
		oHora:SetValid({|| AtVldHora(oHora:GetValue()) })
	
		oCodHist  := TJurPnlCampo():New(035,005,060,022,oMainColl, AllTrim(RetTitle("OHD_CHISTP")) ,("OHD_CHISTP"),{|| },{|| },cCodHist,,,)
		oCodHist:SetChange({|| lCodHisVal := J244VldHis(@oCodHist, @oDesHist, @oAcao) })
		oCodHist:SetValid({|| lCodHisVal })
	
		oDesHist  := TJurPnlCampo():New(035,070,149,022,oMainColl, AllTrim(RetTitle("OHD_DHISTP")) ,("OHD_DHISTP"),{|| },{|| },,,.F.,,,,,,aScan(aNoAccLGPD,"OHD_DHISTP") > 0)
	
		oAcao     := TJurPnlCampo():New(065,005,212,115,oMainColl, AllTrim(RetTitle("OHD_ACAO")) ,("OHD_ACAO"),{|| },{|| },cAcao,,,)
	
		bOk := {|| lExecutou := J244ExeInc(cAliasInc, oData:GetValue(), oHora:GetValue(), oCodHist:GetValue(), oAcao:GetValue()), Iif(lExecutou,oDlg:End(),)}

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| Processa(bOk, STR0013, STR0014, .F.) },; //"Inclusão de cobrança em lote" "Aguarde..."
															{||(oDlg:End())}, ,,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )
	EndIf
	
Return lExecutou

//-------------------------------------------------------------------.
/*/ { Protheus.doc } J244ExeInc
Função para realizar a inclusão em lote de histórico de cobrança

@obs: Utilizar passagem de parâmetro por referência

@author bruno.ritter
@since 29/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J244ExeInc(cAliasInc, dData, cHora, cCodHist, cAcao)
Local cPart      := ""
Local lRet       := .T.
Local cTitleAcao := ""

ProcRegua( 0 )
IncProc()
IncProc()
IncProc()
IncProc()

If Empty(cAcao)
	cTitleAcao := AllTrim(RetTitle("OHD_ACAO"))
	JurMsgErro(i18n(STR0015, {cTitleAcao}),, i18n(STR0016, {cTitleAcao})) //"O campo '#1' é obrigatório." "Informe um valor válido para o campo '#1'."
	lRet := .F.
EndIf

If lRet
	cPart := JURUSUARIO(__CUSERID)

	If Empty(cPart)
		JurMsgErro(STR0019,, STR0021) //'Não é possível realizar a inclusão, pois usuário logado não está relacionado a nenhum participante.' -- 'Verifique o cadastro de participantes e realize o vínculo.'
		lRet := .F.
	EndIf
EndIf

If lRet

	While !(cAliasInc)->( EOF() )

		cResumo := SubStr(cAcao, 1, 250) + IIf( Len(cAcao) > 250, "...", "") 
		cResumo := StrTran(cResumo, CRLF, " ")

		RecLock("OHD", .T.)
		OHD->OHD_FILIAL := (cAliasInc)->E1_FILIAL  
		OHD->OHD_PREFIX := (cAliasInc)->E1_PREFIXO
		OHD->OHD_NUM    := (cAliasInc)->E1_NUM
		OHD->OHD_PARCEL := (cAliasInc)->E1_PARCELA
		OHD->OHD_TIPO   := (cAliasInc)->E1_TIPO
		OHD->OHD_COD    := JurGetNum('OHD', 'OHD_COD')
		OHD->OHD_DTACAO := dData
		OHD->OHD_HRACAO := cHora
		OHD->OHD_CPART  := cPart
		OHD->OHD_CHISTP := cCodHist
		OHD->OHD_ACAO   := cAcao
		OHD->OHD_ACRESU := cResumo

		OHD->(MsUnlock())
		OHD->(DbCommit())
		If __lSX8
			ConfirmSX8()
			J170GRAVA("OHD", OHD->OHD_FILIAL + OHD->OHD_COD, "3")
		EndIf
		
		(cAliasInc)->( DbSkip() )
	EndDo
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J244VldHis
Função para validar o histórico e executar gatilho

@author bruno.ritter
@since 29/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J244VldHis(oCodHist, oDesHist, oAcao)
Local aRetDados := JurGetDados("OHA", 1, xFilial("OHA") + oCodHist:GetValue(), {"OHA_RESUMO", "OHA_TEXTO"})
Local lRet      := .T.

If Empty(oCodHist:GetValue()) .Or. JurGetDados("OHA", 1, xFilial("OHA") + oCodHist:GetValue(), "OHA_COBRAN") == '1'

	If !Empty(aRetDados) .And. Len(aRetDados) == 2
		oDesHist:SetValue(aRetDados[1])
		If Empty(oAcao:GetValue()) .And. !Empty(aRetDados[2])
			oAcao:SetValue(aRetDados[2])
		EndIf
	Else
		oDesHist:SetValue("")
	EndIf

Else
	JurMsgErro(STR0017,, STR0018) //"Histórico padrão inválido" "Informe um código válido para o histórico padrão."
	lRet :=.F.
EndIf

Return lRet
