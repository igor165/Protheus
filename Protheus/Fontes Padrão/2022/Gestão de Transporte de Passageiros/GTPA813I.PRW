#Include "Protheus.ch"
#Include "FWMVCDEF.CH"
#Include "GTPA813I.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA813i
Função responsavel pela definição da view
@type Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA813i()
Local aButtons  := {}

If (GI9->GI9_STATRA <> "6") 
    aButtons  := GtpBtnView()
    FWExecView(STR0001,"VIEWDEF.GTPA813I",MODEL_OPERATION_INSERT, /*oDlg*/, /*bCloseOk*/,/*bOk*/,75/*nPercRed*/,aButtons)//"Inclusão de Condutor"
Else
	FwAlertHelp(STR0007) //'Não Existem Eventos para Manifestos Operacionais'
	Return
EndIf

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= NIL
Local oStrCab   := FwFormModelStruct():New()
Local oStrFake	:= FwFormModelStruct():New()
Local bActivate := {|oMdl| ModelActivate(oMdl) }
Local bCommit   := {|oMdl| ModelCommit(oMdl)}

SetModelStruct(oStrCab,oStrFake)

oModel := MPFormModel():New('GTPA813I', /*bPreValidacao*/, /*bPosValid*/, bCommit, /*bCancel*/ )

oModel:AddFields('CABMASTER',/*cOwner*/,oStrCab,/*bPre*/,/*bPos*/,/*bLoad*/)
oModel:addGrid('FAKEDETAIL','CABMASTER',oStrFake, /*bPreLine*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)

oModel:SetDescription(STR0001)//"Inclusão de Condutor"
oModel:GetModel('CABMASTER'):SetDescription(STR0001)//"Inclusão de Condutor"
oModel:GetModel('FAKEDETAIL'):SetDescription(STR0002)//'Lista de Condutores'

//Limitado a 10 condutores por envio
oModel:GetModel('FAKEDETAIL'):SetMaxLine(10)

oModel:SetPrimaryKey({})

oModel:GetModel( 'CABMASTER'):SetOnlyQuery ( .T. )
oModel:GetModel( 'FAKEDETAIL'):SetOnlyQuery ( .T. )

oModel:SetActivate(bActivate)

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelActivate()
CRIADO SOMENTE PARA TER ALTERAÇÃO NO MODELO PRINCIPAL
@type Function
@author 
@since 13/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelActivate(oModel)
Local oMdlCab   := oModel:GetModel('CABMASTER')

oMdlCab:SetValue('GIK_CODIGO',GI9->GI9_CODIGO)

Return .T.

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelCommit

@type Static Function
@author jacomo.fernandes
@since 18/11/2019
@version 1.0
@param oModel, character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelCommit(oModel)
Local lRet      := .T.
Local oMdlFake  := oModel:GetModel('FAKEDETAIL')
Local oMdlEvent := FwLoadModel('GTPA813')
Local oMdlGIK   := oMdlEvent:GetModel('GIKMASTER')
Local oStrGIK   := oMdlGIK:GetStruct()
Local nX        := 0
Local aRecnos	:= {}
Local oGtpLog	:= GtpLog():New("Inclusão de Condutor")

oStrGIK:DeActivate()

SetModelStruct(,oStrGIK)
oStrGIK:SetProperty('GIK_TPEVEN',MODEL_FIELD_INIT,{||'3'})

oStrGIK:Activate()

oMdlEvent:SetOperation(MODEL_OPERATION_INSERT)

For nX  := 1 to oMdlFake:Length()
    If !oMdlFake:IsDeleted(nX)
        oMdlEvent:Activate()
		
		oMdlGIK:SetValue('GYG_CODIGO'   ,oMdlFake:GetValue('GYG_CODIGO',nX))
        oMdlGIK:SetValue('GYG_NOME'     ,oMdlFake:GetValue('GYG_NOME',nX))
        oMdlGIK:SetValue('GYG_CPF'      ,oMdlFake:GetValue('GYG_CPF',nX))
        If !(oMdlEvent:VldData() .and. oMdlEvent:CommitData())
			lRet    := .F.
		else
			aAdd(aRecnos,{GIK->(Recno()),AllTrim(oMdlGIK:GetValue('GYG_NOME')) } )
		Endif
		
    Endif
	oMdlEvent:Deactivate()
Next

oMdlEvent:Destroy()

Sleep(5000)


oGtpLog:SetText(STR0003)//"Log de Transmissão:"

For nX := 1 to Len(aRecnos )
	GIK->(DbGoTo(aRecnos[nX][1]))
	Ga813ConUn()

	oGtpLog:SetText(I18n(STR0004,{aRecnos[nX][2],GIK->GIK_STATUS,GIK->GIK_MOTIVO}) )//"Condutor:#1 |Status:#2 |Motivo:#3"

Next
oGtpLog:SetText(STR0005)//"Para Mais Informações, visualize o cadastro de eventos"


If oGtpLog:HasInfo() 
	
	oGtpLog:ShowLog()

Endif


Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrCab,oStrFake)
Local bTrig := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}


If ValType(oStrCab) == "O"
    GTPxCriaCpo(oStrCab,{"GIK_CODIGO"},.T.)
Endif
    
If ValType(oStrFake) == "O"
    GTPxCriaCpo(oStrFake,{"GYG_CODIGO","GYG_NOME","GYG_CPF"},.T.)
    
    oStrFake:SetProperty("GYG_CODIGO"   ,MODEL_FIELD_VALID,{|oMdl,cFld,uVal|Vazio() .or. ExistCpo('GYG') })
    oStrFake:SetProperty("GYG_CPF"      ,MODEL_FIELD_VALID,{|oMdl,cFld,uVal|Vazio() .or. CGC(uVal) })
    
	oStrFake:SetProperty("GYG_CODIGO"	,MODEL_FIELD_OBRIGAT,.T.)
	oStrFake:SetProperty("GYG_NOME"		,MODEL_FIELD_OBRIGAT,.T.)
	oStrFake:SetProperty("GYG_CPF"		,MODEL_FIELD_OBRIGAT,.T.)

    oStrFake:AddTrigger("GYG_CODIGO", "GYG_CODIGO", {||.T.}, bTrig)

Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
    Case cField == "GYG_CODIGO"
        oMdl:SetValue('GYG_NOME', ALLTRIM(Posicione('GYG',1,xFilial('GYG')+uVal,"GYG_NOME")))
        oMdl:SetValue('GYG_CPF' , ALLTRIM(Posicione('GYG',1,xFilial('GYG')+uVal,"GYG_CPF" )))
EndCase

Return uVal
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA813I')
Local oStrFake  := FwFormViewStruct():New()

SetViewStruct(oStrFake)

oView:SetModel(oModel)

oView:addGrid('VIEW_FAKE' ,oStrFake,'FAKEDETAIL')

oView:CreateHorizontalBox('TELA'	, 100)

oView:SetOwnerView('VIEW_FAKE','TELA')

oView:SetDescription(STR0006) //'Cadastro de Eventos'

Return oView



//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrFake)

GTPxCriaCpo(oStrFake,{"GYG_CODIGO","GYG_NOME","GYG_CPF"},.F.)

oStrFake:SetProperty("*"         ,MVC_VIEW_CANCHANGE,.F.)
oStrFake:SetProperty("GYG_CODIGO",MVC_VIEW_CANCHANGE,.T.)
oStrFake:SetProperty("GYG_CODIGO",MVC_VIEW_LOOKUP   ,"GYG")

Return 
