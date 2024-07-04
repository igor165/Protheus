#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"
#Include "JURA286.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA286
Preferência de Usuários
( Função de referência no X2_SYSOBJ da Tabela O16. )
/*/ 
//-------------------------------------------------------------------
Function JURA286()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //'Preferência de usuário'
oBrowse:SetAlias( "O16" )
oBrowse:SetLocate()
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo de Preferências de usuário
@since 08/12/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := nil
Local oStrO16 := FWFormStruct(1,'O16')

oModel := MPFormModel():New('JURA286', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('O16MASTER',/*cOwner*/,oStrO16,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:SetDescription(STR0001) //'Preferência de usuário'

oModel:GetModel('O16MASTER'):SetDescription(STR0001) //'Preferência de usuário'
oModel:SetPrimaryKey( { "O16_FILIAL", "O16_CODUSR", "O16_TIPO" } )

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} J286UsrPref
Função resposável por buscar informações da preferência do usuário

@param cType, character, Tipo de prefêrencia

@since 13/05/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function J286UsrPref(cType)
Local oPrefUser := JsonObject():new()
Local cConfig   := ""

Default cType := '2'

	If FWAliasInDic("O16") .AND. !Empty(__cUserID)
		                                        // O16_FILIAL    + O16_CODUSR + O16_TIPO
		cConfig  := Alltrim( JurGetDados("O16", 1, xFilial("O16") + __cUserID + cType, "O16_JSON") )

		If !Empty(cConfig)
			FWJsonDeserialize(cConfig, @oPrefUser)
		EndIf
	EndIf

Return oPrefUser

//------------------------------------------------------------------------------
/* /{Protheus.doc} J286PrefQry
Função que trata informações obtida da preferência do usuário para retornar no
formato esperado de 'in' na query

@param cType, character, Tipo de prefêrencia

@since 13/05/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Function J286PrefQry(cType)
Local oPrefUser := J286UsrPref(cType)
Local cTpAsPref := ''
Local nI        := 1

	If oPrefUser <> Nil .And. Len(oPrefUser) .And. cType == '2'
		For nI := 1 to Len(oPrefUser[1]:filtAssJur)
			If !Empty(oPrefUser[1]:filtAssJur[nI])
				cTpAsPref += If(nI == 1, '', ',')
				cTpAsPref += oPrefUser[1]:filtAssJur[nI]
			EndIf
		Next
	EndIf

Return cTpAsPref
