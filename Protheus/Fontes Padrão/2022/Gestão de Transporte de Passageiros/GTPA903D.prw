#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA903D.CH"

/*/{Protheus.doc} GTPA903D()
    Rotina para checklist dos documentos operacionais da apuração
    @type  Static Function
    @author Flavio Martins
    @since 29/08/2022
    @version 1
    @param 
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/ 
Function GTPA903D(cRotina)
Local cMsgErro  := ''

If G900BVlDic(@cMsgErro)    
    FwMsgRun(, {|| FwExecView(STR0001, "VIEWDEF.GTPA903D", MODEL_OPERATION_UPDATE,,{|| .T.},,50)},"", STR0001)  // "Checklist da apuração de contrato" "Carregando documentos..."
Else
    FwAlertHelp(cMsgErro, STR0003) // "Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return

/*/{Protheus.doc} ModelDef
    View Documentos X Orçamento Contrato
    @type  Static Function
    @author Flavio Martins
    @since 29/08/2022
    @version 1
    @param 
    @return oModel, objeto, instÃ¢ncia da Classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function ModelDef()
Local oModel	:= Nil
Local oStruGQR	:= FwFormStruct(1,'GQR')
Local oStruG9W	:= FwFormStruct(1,'G9W')
Local oStruH69  := FwFormStruct(1,'H69')

oModel := MpFormModel():New('GTPA903D',,/*{|oModel|TP903TudOK(oModel)}*/)

oModel:AddFields('GQRMASTER',/*cOwner*/,oStruGQR)
oModel:AddGrid("G9WDETAIL","GQRMASTER",oStruG9W)
oModel:AddGrid("H69DETAIL","G9WDETAIL",oStruH69)

oModel:SetRelation('G9WDETAIL', {{ 'G9W_FILIAL', 'xFilial( "GQR")'}, {'G9W_CODGQR', 'GQR_CODIGO'}} , G9W->(IndexKey(1))) 
oModel:SetRelation('H69DETAIL', {{ 'H69_FILIAL', 'xFilial( "H69")'}, {'H69_NUMERO', 'G9W_NUMGY0'}, {'H69_REVISA', 'G9W_REVISA'}} , H69->(IndexKey(1))) 

oModel:GetModel("H69DETAIL"):SetLoadFilter(, "H69_EXIGEN IN ('2','3')")

oModel:GetModel('GQRMASTER'):SetOnlyView(.T.)
oModel:GetModel('G9WDETAIL'):SetOnlyView(.T.)

oModel:GetModel("H69DETAIL" ):SetOptional(.T.)

oModel:GetModel('GQRMASTER'):SetDescription(STR0004) // "Dados da apuração"
oModel:GetModel('G9WDETAIL'):SetDescription(STR0005) // "Contratos da apuração"
oModel:GetModel('H69DETAIL'):SetDescription(STR0006) // "Documentos do Contrato"

Return oModel

/*/{Protheus.doc} ViewDef
    View Documentos X Orçamento Contrato
    @type  Static Function
    @author Flavio Martins
    @since 29/08/2022
    @version 1
    @param 
    @return oView, objeto, instância da Classe FwFormView
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= Nil
Local oModel    := FwLoadModel("GTPA903D")
Local cFldsGQR  := "GQR_CODIGO|GQR_CLIENT|GQR_LOJA|GQR_DTINIA|GQR_DTFINA"
Local cFldsG9W  := "G9W_NUMGY0|G9W_REVISA|G9W_CONTRA|G9W_DTINIA"
Local cFldsH69  := "H69_CHKLST|H69_CODG6U|H69_DSCG6U|H69_TPPERI|H69_QTDPER|H69_DATAUL|H69_EXPIRA|H69_EXIGEN"
Local aFldsGQR  := StrToKarr(cFldsGQR, "|")
Local aFldsG9W  := StrToKarr(cFldsG9W, "|")
Local aFldsH69  := StrToKarr(cFldsH69, "|")
Local oStruGQR	:= FwFormStruct(2, "GQR",{|cCpo| (AllTrim(cCpo)) $ cFldsGQR})
Local oStruG9W	:= FwFormStruct(2, "G9W",{|cCpo| (AllTrim(cCpo)) $ cFldsG9W})
Local oStruH69	:= FwFormStruct(2, "H69",{|cCpo| (AllTrim(cCpo)) $ cFldsH69})
Local nX        := 0

oView := FwFormView():New()

oView:SetModel(oModel)

oView:AddField("FIELD_GQR", oStruGQR, "GQRMASTER")
oView:AddGrid("VIEW_G9W", oStruG9W, "G9WDETAIL")
oView:AddGrid("VIEW_H69", oStruH69, "H69DETAIL")

oView:CreateHorizontalBox("FIELD", 20)
oView:CreateHorizontalBox("GRID_G9W", 30)
oView:CreateHorizontalBox("GRID_H69", 50)

oView:SetOwnerView("FIELD_GQR", "FIELD")
oView:SetOwnerView("VIEW_G9W", "GRID_G9W")
oView:SetOwnerView("VIEW_H69", "GRID_H69")

oView:EnableTitleView('FIELD_GQR', STR0004) // "Dados da apuração") 
oView:EnableTitleView('VIEW_G9W',  STR0005) // "Contratos da apuração" 
oView:EnableTitleView('VIEW_H69',  STR0006) // "Documentos do Contrato"

For nX := 1 To Len(aFldsGQR)
    oStruGQR:SetProperty(aFldsGQR[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

For nX := 1 To Len(aFldsG9W)
    oStruG9W:SetProperty(aFldsG9W[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

For nX := 1 To Len(aFldsH69)
    oStruH69:SetProperty(aFldsH69[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

oStruH69:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStruH69:SetProperty("H69_CHKLST", MVC_VIEW_CANCHANGE, .T.)

oView:GetModel('H69DETAIL'):SetNoInsertLine(.T.)
oView:GetModel('H69DETAIL'):SetNoDeleteLine(.T.)

Return oView
