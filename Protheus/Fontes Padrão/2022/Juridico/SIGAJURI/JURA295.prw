#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"
#INCLUDE "PARMTYPE.CH"
#Include "JURA295.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cadastro de Certidões e Licenças das Empresas no TOTVS Jurídico

@Since 06/07/2021
@Version 1.0

@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStruO1A := FWFormStruct( 1, 'O1A' )

oModel := MPFormModel():New('JURA295', /*bPreValidacao*/, {|oX|JA295TOK(oX)} /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('O1AMASTER', /*cOwner*/, oStruO1A, /*bPre*/, /*bPos*/, /*bLoad*/)

oModel:SetDescription(STR0001) // Cadastro de Certidões e Licenças das Empresas no TOTVS Jurídico
oModel:GetModel('O1AMASTER'):SetDescription(STR0001) // Cadastro de Certidões e Licenças das Empresas no TOTVS Jurídico

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA295TOK
Pós valid do modelo

@param oModel - Modelo
@return lRet - boolean - .T. / .F.

@Since 12/07/2021
@Version 1.0
/*/
//------------------------------------------------------------------------------
Static Function JA295TOK(oModel)

Local lRet := .T.
Local nOpc := oModel:GetOperation()

	If nOpc == 5
		lRet := JurExcAnex('O1A',oModel:GetValue("O1AMASTER","O1A_CODIGO"))
	EndIf

Return lRet
