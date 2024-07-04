#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"
#INCLUDE "PARMTYPE.CH"
#Include "JURA294.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cadastro de tipo de Certidões e Licenças das Empresas no TOTVS Jurídico

@since 05/07/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA294" )
Local oStruct := FWFormStruct( 2, "O19" )

JurSetAgrp( 'NQG',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA294_VIEW", oStruct, "O19MASTER"  )
oView:SetDescription( STR0001 ) //"Tipo de certidões e licenças"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cadastro de tipo de Certidões e Licenças das Empresas no TOTVS Jurídico

@Since 02/07/2021

@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStruO19 := FWFormStruct( 1, 'O19' )

If oStruO19:HasField('O19_PRAZO')
	oStruO19:SetProperty( 'O19_PRAZO', MODEL_FIELD_VALID, { |oMdl,cField,uNewValue,uOldValue| J294VPrazo(oMdl,cField,uNewValue,uOldValue) } )
Endif

oModel := MPFormModel():New('JURA294', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('O19MASTER', /*cOwner*/, oStruO19, /*bPre*/, /*bPos*/, /*bLoad*/)

oModel:SetDescription(STR0001) // Cadastro de tipo de Certidões e Licenças das Empresas no TOTVS Jurídico
oModel:GetModel('O19MASTER'):SetDescription(STR0001) // Cadastro de tipo de Certidões e Licenças das Empresas no TOTVS Jurídico

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} J294VPrazo(oMdl, cField, uNewValue, uOldValue)
Valida se o prazo possui somente valor numérico

@param oMdl      - Modelo
@param cField    - Campo
@param uNewValue - Valor novo
@param uOldValue - Valor antigo
@return lRet     - .T./.F.

@Since 13/07/2021
/*/
//------------------------------------------------------------------------------
Static Function J294VPrazo(oMdl, cField, uNewValue, uOldValue)

Local lRet     := .T.
Local cMsgSol  := ""
Local nI       := 0
Local cMsgErro := STR0002 // "Valor preenchido nao e valido! Sao permitidos somente valores numericos inteiros, verifique."
Local oModel   := oMdl:GetModel()
Local cMdlId   := oMdl:GetId()

	uNewValue := ALLTRIM(uNewValue)

	For nI := 1 To Len(uNewValue)
		if !(lRet := isDigit( SUBSTR(uNewValue, nI, 1) ))
			Exit
		Endif
	Next nI

	If !lRet
		oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"J294VPrazo",cMsgErro,cMsgSol,uNewValue,uOldValue)
	EndIf

Return lRet
