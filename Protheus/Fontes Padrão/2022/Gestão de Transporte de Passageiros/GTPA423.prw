#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrH65	:= FWFormStruct(1,'H65')

SetModelStruct(oStrH65)

oModel := MPFormModel():New('GTPA423', /*bPreValidacao*/,, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('H65MASTER',/*cOwner*/,oStrH65)

oModel:SetDescription("Bloqueio de agências") //'Cadastro de Tipos de Ocorrencia'

oModel:GetModel('H65MASTER'):SetDescription("Bloqueio de agências")

If H65->(FieldPos('H65_CODIGO')) > 0
	oModel:SetPrimaryKey({'H65_FILIAL','H65_CODIGO'})
EndIf

Return oModel

/*/{Protheus.doc} SetModelStruct
	(long_description)
	@type  Static Function
	@author henrique.toyada
	@since 24/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SetModelStruct(oStrH65)

Local bTrig 	:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField| FieldInit(oMdl,cField)}

	If H65->(FieldPos('H65_DESAGE')) > 0
		oStrH65:SetProperty('H65_DESAGE' , MODEL_FIELD_INIT, bInit )
	EndIf
	If H65->(FieldPos('H65_HORABR')) > 0
		oStrH65:SetProperty('H65_HORABR' , MODEL_FIELD_INIT, bInit )
	EndIf

	If H65->(FieldPos('H65_AGENCI')) > 0
		oStrH65:AddTrigger('H65_AGENCI'  , 'H65_AGENCI'  ,  { || .T. }, bTrig )
	EndIf

	If H65->(FieldPos('H65_BLOQUE')) > 0
		oStrH65:AddTrigger('H65_BLOQUE'  , 'H65_BLOQUE'  ,  { || .T. }, bTrig ) 
	EndIf

Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

@type Function
@author henrique.toyada 
@since 24/05/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField)

Local uRet      := nil
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
Local aArea     := GetArea()

Do Case 
    Case cField == "H65_DESAGE"
        uRet := If(!lInsert,POSICIONE("GI6",1,xFilial('GI6')+ H65->H65_AGENCI,'GI6_DESCRI'),'')
	Case cField == "H65_HORABR"
		uRet := If(!lInsert,H65->H65_HORABR,SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2))
EndCase 

RestArea(aArea)

Return uRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA850ATrig
Função que preenche trigger

@sample	GA850ATrig()

@author henrique.toyada
@since 24/05/2022
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

	Do Case 
		Case cField == 'H65_AGENCI'
			oMdl:SetValue("H65_DESAGE" , POSICIONE("GI6",1,xFilial('GI6')+ uVal,'GI6_DESCRI'))
		Case cField == 'H65_BLOQUE'
			If uVal == '1'
				oMdl:SetValue("H65_USUBLO" , __CUSERID)
				oMdl:SetValue("H65_USUDES" , '')
			Else
				oMdl:SetValue("H65_USUDES" , __CUSERID)
				oMdl:SetValue("H65_USUBLO" , '')
			EndIf
	EndCase 

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA423')
Local oStrH65	:= FWFormStruct(2, 'H65')

SetViewStruct(oStrH65)

oView:SetModel(oModel)

oView:AddField('VIEW_H65' ,oStrH65,'H65MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_H65','TELA')

oView:SetDescription("Bloqueio de agências")

Return oView

/*/{Protheus.doc} SetViewStruct
	(long_description)
	@type  Static Function
	@author henrique.toyada
	@since 24/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SetViewStruct(oStrH65)
	
	oStrH65:RemoveField("H65_ORIGEM")
	oStrH65:RemoveField("H65_USUBLO")
	oStrH65:RemoveField("H65_USUDES")

Return
