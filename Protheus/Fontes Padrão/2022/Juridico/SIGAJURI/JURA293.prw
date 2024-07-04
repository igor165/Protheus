#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"
#Include "JURA293.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA293
'Configura��o do TOTVS Jur�dico Departamento (PO UI)'
( Fun��o de refer�ncia no X2_SYSOBJ da Tabela O18. )
/*/ 
//-------------------------------------------------------------------
Function JURA293()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) // 'Configura��o do TOTVS Jur�dico Departamento (PO UI)'
oBrowse:SetAlias( "O18" )
oBrowse:SetLocate()
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o respons�vel pela defini��o da Configura��o do TOTVS Jur�dico Dept. (PO UI)

@Since 11/05/2021
@Version 1.0

@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStrO18 := FWFormStruct(1,'O18')

oModel := MPFormModel():New('JURA293', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('O18MASTER', /*cOwner*/, oStrO18, /*bPre*/, /*bPos*/, /*bLoad*/)

oModel:SetDescription(STR0001) // 'Configura��o do TOTVS Jur�dico Departamento (PO UI)'

oModel:GetModel('O18MASTER'):SetDescription(STR0001) // 'Configura��o do TOTVS Jur�dico Departamento (PO UI)'

oModel:SetPrimaryKey({'O18_FILIAL', 'O18_TIPO'})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} J293CfgProd(cCfgProd)
Fun��o respons�vel por obter as Configura��o do TOTVS Jur�dico Dept. (PO UI)

@Param cCfgProd: Tipo de configura��o do produto

@Since 11/05/2021
@Version 1.0
/*/
//------------------------------------------------------------------------------

Static Function J293CfgProd(cCfgProd)
Local oJson := Nil

Default cCfgProd := ''

	If !Empty(cCfgProd)
		dbSelectArea("O18")
		O18->( dbSetOrder( 1 ) )

		// O18_FILIAL + O18_TIPO
		If O18->(dbSeek(xFilial('O18') + cCfgProd))
		 	oJson := JSONObject():New()
			oJson:fromJson(O18->O18_JSON)
		EndIf

		O18->(dbCloseArea())
	EndIf

Return oJson

//------------------------------------------------------------------------------
/*/{Protheus.doc} J293CfgQry(cCfgProd, cTLegal)
Fun��o que trata informa��es obtida da Configura��o do TOTVS Jur�dico Dept. (PO UI)
para retornar no formato esperado de 'in' na query

@Param cCfgProd: Tipo de configura��o do produto
@Param cTLegal: 'true' indica que vem e 'false' indica que n�o vem do Totvs Legal

@Since 11/05/2021
@Version 1.0
/*/
//------------------------------------------------------------------------------
Function J293CfgQry(cCfgProd, cTLegal)
Local nI       := 1
Local oCfgProd := Nil
Local cTpAsCfg := ''
Local lCfgProd := FWAliasInDic('O18')

Default cTLegal := "true"

	If cTLegal == "true" .And. lCfgProd
		oCfgProd := J293CfgProd(cCfgProd)

		If oCfgProd <> Nil
			For nI := 1 to Len(oCfgProd)
				If !Empty(oCfgProd[nI])
					cTpAsCfg += If(nI == 1, '', ',')
					cTpAsCfg += oCfgProd[nI]
				EndIf
			Next
		EndIf
	EndIF

Return cTpAsCfg
