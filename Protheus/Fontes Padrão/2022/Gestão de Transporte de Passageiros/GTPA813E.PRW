#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA813e.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA813e
Função responsavel pela definição da view
@type Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA813e()
Local aButtons  := {}

If (GI9->GI9_STATRA <> "6") 
	aButtons  := GtpBtnView()
	If (GI9->GI9_STATUS == "1")
		FWExecView(STR0001,"VIEWDEF.GTPA813e",MODEL_OPERATION_INSERT, /*oDlg*/, /*bCloseOk*/,/*bOk*/,75/*nPercRed*/,aButtons)//"Encerramento"
	Else
		FwAlertHelp(STR0002,STR0003,STR0004)//"Não é possivel realizar a operação de Encerramento em um manifesto que não se encontra em Aberto","Verifique o registro selecionado","Atenção"
	Endif
Else
	FwAlertHelp(STR0008)//'Não Existem Eventos para Manifestos Operacionais'
	Return
EndIf

Return 
	
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 25/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= FwLoadModel('GTPA813')
Local oMdlGIK	:= oModel:GetModel('GIKMASTER')
Local oStrGIK	:= oMdlGIK:GetStruct()
Local bTrig 	:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }


oStrGIK:DeActivate()


GTPxCriaCpo(oStrGIK,{"GI6_CODIGO","GI6_DESCRI","GI9_EMISSA","GI1_UF","GI1_DESUF","GI1_CDMUNI","GI1_DSMUNI"},.T.)

oStrGIK:SetProperty('GIK_TPEVEN',MODEL_FIELD_INIT,{||'2'})
oStrGIK:SetProperty('GI9_EMISSA',MODEL_FIELD_INIT,{||dDataBase})

oStrGIK:SetProperty("GI1_CDMUNI",MODEL_FIELD_TAMANHO,7)

oStrGIK:SetProperty("GI6_CODIGO",MODEL_FIELD_OBRIGAT,.T.)
oStrGIK:SetProperty("GI9_EMISSA",MODEL_FIELD_OBRIGAT,.T.)
oStrGIK:SetProperty("GI1_UF"	,MODEL_FIELD_OBRIGAT,.T.)
oStrGIK:SetProperty("GI1_CDMUNI",MODEL_FIELD_OBRIGAT,.T.)

oStrGIK:SetProperty('GI6_CODIGO', MODEL_FIELD_VALID	, bFldVld)
oStrGIK:SetProperty("GI9_EMISSA", MODEL_FIELD_VALID	, bFldVld)
oStrGIK:SetProperty("GI1_UF"	, MODEL_FIELD_VALID	, bFldVld)
oStrGIK:SetProperty("GI1_CDMUNI", MODEL_FIELD_VALID	, bFldVld)


oStrGIK:AddTrigger('GI6_CODIGO'	,'GI6_CODIGO'	,{||.T.}, bTrig)

oStrGIK:Activate()


Return oModel


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
Local aAreaSm0	:= nil
Local aAreaGI6	:= nil
Local cCodMun	:= ""

Do Case
	Case cField == "GI6_CODIGO"
		aAreaGI6	:= GI6->(GetArea())
		GI6->(DbSetOrder(1))
		If GI6->(DbSeek(xFilial('GI6')+uVal))
			
			aAreaSm0	:= SM0->(GetArea())
			cCodMun		:= Posicione('SM0', 1, cEmpAnt + GI6->GI6_FILRES, 'M0_CODMUN')

			oMdl:SetValue("GI6_DESCRI"	,GI6->GI6_DESCRI)
			oMdl:SetValue("GI1_UF"		,GetDadosUf(SubStr(cCodMun,1,2),2,1))
			oMdl:SetValue("GI1_CDMUNI"	,cCodMun)
			oMdl:SetValue("GI1_DESUF"	,GetDadosUf(SubStr(cCodMun,1,2),2,3) )
			oMdl:SetValue("GI1_DSMUNI"	,Posicione('CC2',1,xFilial('CC2')+GetDadosUf(SubStr(cCodMun,1,2),2,1)+SubStr(cCodMun,3),"CC2_MUN") ) 

			RestArea(aAreaSm0)
		Endif
		RestArea(aAreaGI6)
EndCase

Return uVal



//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
	Case cField == 'GI6_CODIGO' 

        IF !GTPExistCpo('GI6',uNewValue)
            lRet        := .F.
            cMsgErro	:= STR0005//"Agencia selecionada não encontrada ou se encontra inativa"
            cMsgSol	    := STR0006//"Selecione uma agencia valida"
        ElseIf !GxVldAgEnc(uNewValue)
            lRet        := .F.
            cMsgErro	:= STR0007//"Agencia selecionada não é do tipo de Encomenda"
            cMsgSol	    := STR0006//"Selecione uma agencia valida"
       	ElseIf !ValidUserAg(oMdl,cField,uNewValue,uOldValue)
            lRet        := .F.
		Endif
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 27/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA813E')
Local oStrGIK	:= FWFormViewStruct():New() 

SetViewStruct(oStrGIK)

oView:SetModel(oModel)

oView:AddField('VIEW_GIK' ,oStrGIK,'GIKMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GIK','TELA')

oView:SetDescription(STR0001) //'Encerramento'

Return oView


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 27/11/2019
@version 1.0
@param oStrGIK, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrGIK)

GTPxCriaCpo(oStrGIK,{"GI6_CODIGO","GI6_DESCRI","GI9_EMISSA","GI1_UF","GI1_DESUF","GI1_CDMUNI","GI1_DSMUNI"},.F.)

oStrGIK:SetProperty('*'			, MVC_VIEW_CANCHANGE , .F. )
oStrGIK:SetProperty('GI6_CODIGO', MVC_VIEW_CANCHANGE , .T. )

oStrGIK:SetProperty("*"			, MVC_VIEW_LOOKUP , "GI6FIL")
oStrGIK:SetProperty("GI6_CODIGO", MVC_VIEW_LOOKUP , "GI6FIL")

Return 
