#INCLUDE "CTBS460.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWLIBVERSION.CH"


Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6" //Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS460
Cadastro de Lancamentos Extemporaneos


@author Paulo Carnelossi
@since 19-02-2019
@version P12
/*/
//-------------------------------------------------------------------
Function CTBS460()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CSQ")
    oBrowse:SetDescription(STR0001)  // "Cadastro de Lançamentos Extemporâneos"
    oBrowse:Activate()
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do Cadastro de Lancamentos Extemporaneos


@author Paulo Carnelossi
@since 19-02-2019
@version P12
/*/
//-------------------------------------------------------------------


Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CTBS460" OPERATION 2 ACCESS 0  //"Visualizar" 	
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CTBS460" OPERATION 3 ACCESS 0  //"Incluir"    	
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CTBS460" OPERATION 4 ACCESS 0  //"Alterar"    	
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CTBS460" OPERATION 5 ACCESS 0  //"Excluir"    	
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CTBS460" OPERATION 8 ACCESS 0  //"Imprimir"  	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model do Cadastro de Lancamentos Extemporaneos


@author Paulo Carnelossi
@since 19-02-2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStru := FWFormStruct(1, "CSQ", /*bAvalCampo*/,/*lViewUsado*/)
    Local oModel := MPFormModel():New("CTBS460", /*bPre*/, /*bPos*/)

    oModel:AddFields("CSQMASTER", /*cOwner*/, oStru)
    oModel:SetDescription(STR0001)  //"Cadastro de Lançamentos Extemporâneos"
    oModel:GetModel("CSQMASTER"):SetDescription(STR0001)  //"Cadastro de Lançamentos Extemporâneos"
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View do Cadastro de Lancamentos Extemporaneos


@author Paulo Carnelossi
@since 19-02-2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oView
    Local oModel := FWLoadModel("CTBS460")
    Local oStru := FWFormStruct(2, "CSQ")


	If IsinCallStack("CtbLctExtp")
		oStru:SetProperty("CSQ_DATA"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CSQ_LOTE"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CSQ_SBLOTE"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CSQ_DOC"		,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CSQ_LINHA"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CSQ_EMPORI"	,MVC_VIEW_CANCHANGE,.F.)
		oStru:SetProperty("CSQ_FILORI"	,MVC_VIEW_CANCHANGE,.F.)
	EndIf

    oView := FWFormView():New()
    oView:SetCloseOnOk({||.T.})
    oView:SetModel(oModel)

    oView:AddField("VIEW_CSQ", oStru, "CSQMASTER")

    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_CSQ", "TELA")
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbLctExtp
Cadastro de Lancamentos Extemporaneos em ações relacionadas na mbrowse da CT2


@author Paulo Carnelossi
@since 19-02-2019
@version P12
/*/
//-------------------------------------------------------------------
Function CtbLctExtp()

Local lRet := .F.
Local lInclui := .F.
Local lAltera := .F.
Local lExclui := .F.
Local lFound  := .F.
Local nRetAviso := 0
Local oModelCSQ

CSQ->(dbSetOrder(1))
lFound  :=  CSQ->(dbSeek(CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA+CT2->CT2_EMPORI+CT2->CT2_FILORI))

If lFound
	nRetAviso := Aviso(STR0007, STR0008, {STR0004, STR0005,STR0010})
	
	If nRetAviso == 3
		Return .F.
	EndIf
	 
	If nRetAviso == 1
		lAltera := .T.
	Else
		lExclui := .T.
	EndIf
Else
	lInclui := .T.
EndIf

oModelCSQ := FWLoadModel( 'CTBS460' )

If lInclui

	oModelCSQ:SetOperation(MODEL_OPERATION_INSERT)
	oModelCSQ:Activate()

	oModelCSQ:SetValue("CSQMASTER", "CSQ_FILIAL",CT2->CT2_FILIAL)
	oModelCSQ:SetValue("CSQMASTER", "CSQ_DATA",CT2->CT2_DATA)
	oModelCSQ:SetValue("CSQMASTER", "CSQ_LOTE",CT2->CT2_LOTE)
	oModelCSQ:SetValue("CSQMASTER", "CSQ_SBLOTE",CT2->CT2_SBLOTE)
	oModelCSQ:SetValue("CSQMASTER", "CSQ_DOC",CT2->CT2_DOC)
	oModelCSQ:SetValue("CSQMASTER", "CSQ_LINHA",CT2->CT2_LINHA)
	oModelCSQ:SetValue("CSQMASTER", "CSQ_EMPORI",CT2->CT2_EMPORI)
	oModelCSQ:SetValue("CSQMASTER", "CSQ_FILORI",CT2->CT2_FILORI)

	//abre formulario inclusao de dados e carrega os dados importados
	lRet := ( FWExecView(STR0009,"CTBS460", MODEL_OPERATION_INSERT, , , , 30, , , , , oModelCSQ ) == 0 )  //"Inclusão por FWExecView"

Else

	If lAltera
		oModelCSQ:SetOperation(MODEL_OPERATION_UPDATE)
	Else
		oModelCSQ:SetOperation(MODEL_OPERATION_DELETE)
	EndIf
	
	oModelCSQ:Activate()
	
	//abre formulario de dados
	If lAltera
		lRet := ( FWExecView(STR0009,"CTBS460", MODEL_OPERATION_UPDATE, , , , 30, , , , , oModelCSQ ) == 0 )  //"Alteração por FWExecView"
	Else
		lRet := ( FWExecView(STR0009,"CTBS460", MODEL_OPERATION_DELETE, , , , 30, , , , , oModelCSQ ) == 0 )  //"Exclusao por FWExecView"
	EndIf
	

EndIf

//Metrica para pegar a quantidade de utilizacao dos lancamentos extemporaneos.
If __lMetric .And. lRet
	CTB102Metrics("01" /*cEvent*/,/*nStart*/, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/,1)
Endif

oModelCSQ:DeActivate()
oModelCSQ := NIL

Return(lRet)
