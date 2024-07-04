#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"
#Include "JURA287.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo responsavel pela manutenção do cadastro de causa raiz vinculado ao processo
@since 29/12/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := nil
Local oStrO05 := FWFormStruct(1,'O05')
Local bPosValid := {|oMdl| ModelPosValid(oMdl)}

oModel := MPFormModel():New('JURA287', , bPosValid)

oModel:AddFields('O05MASTER', ,oStrO05)

oModel:SetDescription(STR0001) //'Causa raíz do processo'

oModel:GetModel('O05MASTER'):SetDescription(STR0001) //'Causa raíz do processo'

oModel:SetPrimaryKey({'O05_FILIAL','O05_CAJURI','O05_CCAUSA'})

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Função responsavel pela validação do modelo completa
@since 29/12/2020
@param oModel, object 
@return lRet, Retorno lógico
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local aArea       := GetArea()
Local lRet        := .T.
Local oMdlO05     := oModel:GetModel('O05MASTER')
Local cMdlId      := oModel:GetId()

	If( (oModel:GetOperation() != MODEL_OPERATION_DELETE) .And. oModel:IsFieldUpdated("O05MASTER", "O05_CCAUSA"))
		DbSelectArea( 'O05' )
		O05->( dbSetOrder( 1 ) ) //O05_FILIAL+O05_CAJURI+O05_CCAUSA
		If ( DbSeek(xFilial('O05') + oMdlO05:GetValue('O05_CAJURI') + oMdlO05:GetValue('O05_CCAUSA')) ) 
			lRet := .F.
			oModel:SetErrorMessage(cMdlId,'',cMdlId,'',"ModelPosValid",STR0002,STR0003)
			// STR0002 'Causa raíz já cadastrada no processo'
			// STR0003 'Escolha uma causa raíz diferente'
		EndIf
	EndIf

	RestArea(aArea)

Return lRet
