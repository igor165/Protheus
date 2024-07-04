#INCLUDE "CTBS470.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWLIBVERSION.CH"

Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6" //Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS470
Cadastro de Lancamentos De Transferencia de Saldo 


@author galo.julyane
@since 08-01-2021
@version P12
/*/
//-------------------------------------------------------------------
Function CTBS470()
    Local oBrowse470
	Local cFiltro := "CQW_FILIAL == '" + CT2->CT2_FILIAL + "' .AND. CQW_DATA == '"+DTOS(CT2->CT2_DATA)+ "' .AND. CQW_LOTE == '"+CT2->CT2_LOTE+ "' .AND. CQW_SBLOTE == '"+CT2->CT2_SBLOTE+ "' .AND. CQW_DOC == '" + CT2->CT2_DOC + "' .AND. CQW_LINHA == '" +CT2->CT2_LINHA +"'"
	Local aRotOld := {}
	
	//Valida existência da tabela e campo
	If !TableInDic('CQW') 
		MsgInfo(STR0011,STR0012)
		Return
	ElseIf CQW->(FieldPos("CQW_SEQ")) == 0
		MsgInfo(STR0020,STR0019) // Campo CQW_SEQ não existe no dicionário de dados - Atualizar dicionário de dados
		Return
	EndIf
	
	aRotOld := aClone(aRotina)
	aRotina := MenuDef (.T.)

    oBrowse470 := FWMBrowse():New()
    oBrowse470:SetAlias("CQW")
    oBrowse470:SetDescription(STR0009)  // "Cadastro Lancamentos De Transferencia de Saldo"
	oBrowse470:SetFilterDefault( cFiltro )
	oBrowse470:Activate()

	aRotina := aClone(aRotOld)

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do Cadastro Lancamentos De Transferencia de Saldo

@author galo.julyane
@since 08-01-2021
@version P12
/*/
//-------------------------------------------------------------------


Static Function MenuDef()
Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CTBS470" OPERATION 2 ACCESS 0  //"Visualizar" 	
    ADD OPTION aRotina TITLE STR0003 ACTION "CtbLctVers(3)" OPERATION 3 ACCESS 0  //"Incluir"    	   	
	ADD OPTION aRotina TITLE STR0004 ACTION "CtbLctVers(4)" OPERATION 4 ACCESS 0  //"Alterar"    	
    ADD OPTION aRotina TITLE STR0005 ACTION "CtbLctVers(5)" OPERATION 5 ACCESS 0  //"Excluir"    	
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CTBS470" OPERATION 8 ACCESS 0  //"Imprimir"  	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model do Cadastro Lancamentos De Transferencia de Saldo


@author galo.julyane
@since 08-01-2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStru := FWFormStruct(1, "CQW", /*bAvalCampo*/,/*lViewUsado*/)
    Local oModel := MPFormModel():New("CTBS470", /*bPre*/, { |oModel| Valid(oModel) })

    oModel:AddFields("CQWMASTER", /*cOwner*/, oStru,/*bPreVld*/,/*bPosVld*/,/*bLoad*/) 
    oModel:SetDescription(STR0001)  //"Cadastro Lancamentos De Transferencia de Saldo"
	oModel:SetPrimaryKey({'CQW_FILIAL', 'CQW_DATA','CQW_LOTE','CQW_SBLOTE','CQW_DOC','CQW_LINHA', 'CQW_INDCNT','CQW_SEQ'})
    oModel:GetModel("CQWMASTER"):SetDescription(STR0001)  //"Cadastro Lancamentos De Transferencia de Saldo"

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View do Cadastro Lancamentos De Transferencia de Saldo


@author galo.julyane
@since 08-01-2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oView
    Local oModel := FWLoadModel("CTBS470")
    Local oStru := FWFormStruct(2, "CQW")


	If IsinCallStack("CtbLctVers")
		oStru:SetProperty("CQW_DATA"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CQW_LOTE"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CQW_SBLOTE"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CQW_DOC"		,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CQW_LINHA"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CQW_SEQ"		,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CQW_INDCNT"	,MVC_VIEW_CANCHANGE,.T.)
		oStru:SetProperty("CQW_CONTA"	,MVC_VIEW_CANCHANGE,.T.)
		oStru:SetProperty("CQW_CCUSTO"	,MVC_VIEW_CANCHANGE,.T.)
		oStru:SetProperty("CQW_ZERA"	,MVC_VIEW_CANCHANGE,.T.)
		oStru:SetProperty("CQW_DATAAL"	,MVC_VIEW_CANCHANGE,.T.)
	EndIf
	If ALTERA
		oStru:SetProperty("CQW_INDCNT"	,MVC_VIEW_CANCHANGE,.F.)
	EndIf	

    oView := FWFormView():New()
    oView:SetCloseOnOk({||.T.})
    oView:SetModel(oModel)

    oView:AddField("VIEW_CQW", oStru, "CQWMASTER")

    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_CQW", "TELA")


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbLctVers
Cadastro Lancamentos De Transferencia de Saldo em ações relacionadas na mbrowse da CT2


@author galo.julyane
@since 08-01-2021
@version P12
/*/
//-------------------------------------------------------------------
Function CtbLctVers(nOpc)

Local lRet := .F.
Local lInclui := .F.
Local lAltera := .F.
Local lExclui := .F.
Local lFound  := .F.
Local nRetAviso := 0
Local oModelCQW := FWLoadModel( 'CTBS470' )

Default nOpc := 0

If ALTERA
	lAltera := .T.
ElseIf INCLUI
	lInclui := .T.
Else
	lExclui := .T.
EndIf			

If !TableInDic('CQW') 
	MsgInfo(STR0011,STR0012)
	lRet := .F.
Else
	If lInclui

		cSeq := Soma1(LastSeqCQW(CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_LINHA))
		oModelCQW:SetOperation(MODEL_OPERATION_INSERT)
		oModelCQW:Activate()

		oModelCQW:SetValue("CQWMASTER", "CQW_FILIAL",CT2->CT2_FILIAL)
		oModelCQW:SetValue("CQWMASTER", "CQW_DATA",CT2->CT2_DATA)
		oModelCQW:SetValue("CQWMASTER", "CQW_LOTE",CT2->CT2_LOTE)
		oModelCQW:SetValue("CQWMASTER", "CQW_SBLOTE",CT2->CT2_SBLOTE)
		oModelCQW:SetValue("CQWMASTER", "CQW_DOC",CT2->CT2_DOC)
		oModelCQW:SetValue("CQWMASTER", "CQW_LINHA",CT2->CT2_LINHA)
		oModelCQW:SetValue("CQWMASTER", "CQW_SEQ",cSeq)
		


		//abre formulario inclusao de dados e carrega os dados importados
		lRet := ( FWExecView(STR0009,"CTBS470", MODEL_OPERATION_INSERT, , , , 30, , , , , oModelCQW ) == 0 )  //"Inclusão por FWExecView"	
	EndIf
	If lAltera
		oModelCQW:SetOperation(MODEL_OPERATION_UPDATE)
		oModelCQW:Activate()
		lRet := ( FWExecView(STR0009,"CTBS470", MODEL_OPERATION_UPDATE, , , , 30, , , , , oModelCQW ) == 0 )  //"Alteração por FWExecView"
	EndIf

	If lExclui
		oModelCQW:SetOperation(MODEL_OPERATION_DELETE)
		oModelCQW:Activate()
		lRet := ( FWExecView(STR0009,"CTBS470", MODEL_OPERATION_DELETE, , , , 30, , , , , oModelCQW ) == 0 )  //"Exclusao por FWExecView"
	EndIf	

	//Metrica para verificar a utilizacao da transferencia de saldo via ctba102
	If __lMetric .And. lRet
		CTB102Metrics("02" /*cEvent*/,/*nStart*/, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/, 1)
	Endif

	oModelCQW:DeActivate()
	oModelCQW := NIL
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} LastSeqCQW
Retornar última sequência da CQW para aquele lançamento. 

@author galo.julyane
@since 08-01-2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function LastSeqCQW(cData, cLote, cSbLote, cDoc, cLinha)
Local cQuery := ""
Local cSeq := ""


cQuery := GetNextAlias()


BeginSQL alias cQuery
    SELECT MAX(CQW_SEQ) SEQ_MAX
      FROM %table:CQW%
     WHERE CQW_FILIAL = %xfilial:CQW%
       AND CQW_DATA = %exp:cData%
	   AND CQW_LOTE = %exp:cLote%
	   AND CQW_SBLOTE = %exp:cSbLote%
	   AND CQW_DOC = %exp:cDoc%
	   AND CQW_LINHA = %exp:cLinha%
       AND %notDel%
EndSQL

If !(cQuery)->(Eof())
    cSeq := (cQuery)->SEQ_MAX
Else
    cSeq := ""
Endif

(cQuery)->(DBCloseArea())


If !Empty("CQW")
    DBSelectArea("CQW")
Endif

return cSeq

Static Function Valid(oModel)
Local lRet := .T.
Local lFound := .F.

CQW->(dbSetOrder(1))
lFound  :=  CQW->(dbSeek(xFilial("CQW")+DTOS(oModel:GetValue("CQWMASTER", "CQW_DATA"))+oModel:GetValue("CQWMASTER", "CQW_LOTE")+oModel:GetValue("CQWMASTER", "CQW_SBLOTE")+oModel:GetValue("CQWMASTER", "CQW_DOC")+oModel:GetValue("CQWMASTER", "CQW_LINHA")+oModel:GetValue("CQWMASTER", "CQW_INDCNT")+oModel:GetValue("CQWMASTER", "CQW_CONTA")+oModel:GetValue("CQWMASTER", "CQW_CCUSTO")))

If Empty(oModel:GetValue("CQWMASTER", "CQW_CONTA")) .and. Empty(oModel:GetValue("CQWMASTER", "CQW_CCUSTO"))
	Help(, , STR0013, , STR0014, 1, 0, , , , , , {STR0015})
	lRet := .F.
EndIf	

Return (lRet)

