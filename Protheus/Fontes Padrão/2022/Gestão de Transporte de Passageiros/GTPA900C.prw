#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA900C.CH"

/*/{Protheus.doc} GTPA900C()
    Rotina para checklist dos documentos operacionais do contrato
    @type  Static Function
    @author Flavio Martins
    @since 19/08/2022
    @version 1
    @param 
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/ 
Function GTPA900C()
Local cMsgErro  := ''
Local oModel    := Nil 

Default cRotina := ''

If G900BVlDic(@cMsgErro)  
    
    oModel := FwLoadModel('GTPA900B')  
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:GetModel("H69DETAIL"):SetLoadFilter(, "H69_EXIGEN IN ('1','3')")

    oModel:Activate()

    FwMsgRun(, {|| FwExecView(STR0001, "VIEWDEF.GTPA900C", MODEL_OPERATION_UPDATE,,{|| .T.},,50,,,,,oModel)},"", STR0002) // "Checklist de documentos do contrato","VIEWDEF.GTPA900B", "Carregando documentos..."

    oModel:DeActivate()

Else
    FwAlertHelp(cMsgErro, STR0005) // "Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return

/*/{Protheus.doc} ViewDef
    View Documentos X Orçamento Contrato
    @type  Static Function
    @author Flavio Martins
    @since 22/08/2022
    @version 1
    @param 
    @return oView, objeto, instância da Classe FwFormView
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= Nil
Local oModel    := FwLoadModel("GTPA900B")
Local cFldsGY0  := "GY0_NUMERO|GY0_REVISA|GY0_CLIENT|GY0_LOJACL|GY0_DTINIC"
Local cFldsH69  := "H69_CHKLST|H69_CODG6U|H69_DSCG6U|H69_TPPERI|H69_QTDPER|H69_DATAUL|H69_EXPIRA|H69_EXIGEN"
Local aFldsGY0  := StrToKarr(cFldsGY0, "|")
Local aFldsH69  := StrToKarr(cFldsH69, "|")
Local oStruGY0	:= FwFormStruct(2, "GY0",{|cCpo| (AllTrim(cCpo)) $ cFldsGY0})
Local oStruH69	:= FwFormStruct(2, "H69",{|cCpo| (AllTrim(cCpo)) $ cFldsH69})
Local nX        := 0

// Cria o objeto de View
oView := FwFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField("VIEW_HEADER", oStruGY0, "GY0MASTER")
oView:AddGrid("VIEW_DETAIL", oStruH69, "H69DETAIL")

oView:CreateHorizontalBox("HEADER", 20)
oView:CreateHorizontalBox("DETAIL", 80)

oView:SetOwnerView("VIEW_HEADER", "HEADER")
oView:SetOwnerView("VIEW_DETAIL", "DETAIL")

oView:EnableTitleView('VIEW_HEADER', STR0003) // 'Dados do Contrato' 
oView:EnableTitleView('VIEW_DETAIL', STR0004) // 'Documentos Operacionais'

For nX := 1 To Len(aFldsGY0)
    oStruGY0:SetProperty(aFldsGY0[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

For nX := 1 To Len(aFldsH69)
    oStruH69:SetProperty(aFldsH69[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

oStruH69:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStruH69:SetProperty("H69_CHKLST", MVC_VIEW_CANCHANGE, .T.)

oView:GetModel('H69DETAIL'):SetNoInsertLine(.T.)
oView:GetModel('H69DETAIL'):SetNoDeleteLine(.T.)

Return oView
