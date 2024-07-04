#INCLUDE "JURA164.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA164
Tipo de Prestacao de Contas

@author Fabio Crespo Arruda
@since 28/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA164()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NUO" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NUO" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Fabio Crespo Arruda
@since 28/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA164", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA164", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA164", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA164", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Prestacao de Contas

@author Fabio Crespo Arruda
@since 28/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA164" )
Local oStruct := FWFormStruct( 2, "NUO" )

JurSetAgrp( 'NUO',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA164_VIEW", oStruct, "NUOMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA164_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Tipo de Prestacao de Contas"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Prestacao de Contas

@author Fabio Crespo Arruda
@since 28/07/09
@version 1.0

@obs NUOMASTER - Dados do Tipo de Prestacao de Contas

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NUO" )
Local oCommit    := JA164COMMIT():New()

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA164", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NUOMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo de Prestacao de Contas"
oModel:GetModel( "NUOMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo de Prestacao de Contas"

oModel:InstallEvent("JA164COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, "NUOMASTER",, "NUO",, "JURA164" )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA164COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA164COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA164COMMIT
Return

Method InTTS(oModel, cModelId) Class JA164COMMIT
	JFILASINC(oModel:GetModel(), "NUO", "NUOMASTER", "NUO_COD")
Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } J164ValNat
Validação de Naturezas

@param  cNatur, Código da Natureza

@return lRet  , Natureza Valida

@author Fabiana Cristina Pereira da Silva
@since  01/02/2021
/*/
//-------------------------------------------------------------------
Function J164ValNat(cNatur)
Local lRet       := .T.
Local cListCusto := ""
Local cCCNatOri  := ""
Local aErro      := {}

Default cNatur   := ""

	lRet :=  Empty(cNatur) .Or. (J235AVlNat(cNatur)) // Validação de Naturezas

	If lRet
		cCCNatOri := JurGetDados("SED", 1, xFilial("SED") + cNatur, {"ED_CCJURI"})

		If !Empty(cNatur) .And. cCCNatOri $ "|5|6|7|8"
			cListCusto := CRLF + STR0010 //"Sem definição."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '1', "3") + "."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '2', "3") + "."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '3', "3") + "."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '4', "3") + "."
			aErro      := {STR0011, STR0012 + cListCusto} // "Centro de custo jurídico inválido na natureza de origem" "Só é possível utilizar natureza de origem com os seguentes centros de custos jurídico:"
			lRet       := JurMsgErro(aErro[1],, aErro[2])
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J164When
Habilitação dos campos da rotina 

@param cCampo, Código do Campo

@return lRet, Habilita o campo

@author Fabiana Cristina Pereira da Silva
@since  01/02/2021
/*/
//-------------------------------------------------------------------
Function J164When(cCampo)
Local lRet    := .F.
Local aRetNat := {}
Local cRatJur := ""

Default cCampo := ""

	If cCampo == "NUO_RATJUR"
		cRatJur := FwFldGet("NUO_NATJUR")
		If !Empty(cRatJur)
			aRetNat := JurGetDados("SED", 1, xFilial("SED") + cRatJur, {"ED_CCJURI", "ED_BANCJUR"})

			If Len(aRetNat) = 2
				lRet := aRetNat[01] =='4' .And. aRetNat[02] == "2"
			EndIf
		EndIf
	EndIf

Return lRet
