#INCLUDE "JURA078.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA078
Cadastro de feriados por escritório.

@author Andréia Silva N. de Lima
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA078()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) // "Feriados"
oBrowse:SetAlias( "NW9" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NW9" )
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
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Andréia S. N. de Lima
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA078", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA078", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA078", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA078", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Feriados

@author Andréia S. N. de Lima
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA078" )
Local oStruct := FWFormStruct( 2, "NW9" )

JurSetAgrp( 'NW9',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA078_VIEW", oStruct, "NW9MASTER" )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA078_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Feriados"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Feriados Regionais

@author Andréia S. N. de Lima
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NW9" )
Local oCommit    := JA078COMMIT():New()

oModel:= MPFormModel():New( "JURA078", /*Pre-Validacao*/, { |oX| J078POSVAL(oX) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NW9MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo Feriados"
oModel:GetModel( "NW9MASTER" ):SetDescription( STR0009 ) // "Feriados"

oModel:InstallEvent("JA078COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, "NW9MASTER",, "NW9",, "JURA078" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J078POSVAL(oModel)
Rotinas executadas na pós-validação do modelo.

@author Cristina Cintra
@since 16/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J078POSVAL(oModel)
Local lRet      := .T.
Local aArea     := GetArea()

If (oModel:GetOperation()) ==  3 .Or. (oModel:GetOperation()) ==  4 // se for Inclusão ou Alteração
	If !ExistChav('NW9', DtoS(oModel:GetValue("NW9MASTER", "NW9_DATA")) + oModel:GetValue("NW9MASTER", "NW9_CESCR"), 2)
		lRet := .F.
		JurMsgErro(STR0010,, STR0011) // "Já existe registro cadastrado com mesma data para este escritório. Verifique!" || "Altere a data ou o escritório."
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA078COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA078COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA078COMMIT
Return

Method InTTS(oModel, cModelId) Class JA078COMMIT
	JFILASINC(oModel:GetModel(), "NW9", "NW9MASTER", "NW9_COD")
Return 
