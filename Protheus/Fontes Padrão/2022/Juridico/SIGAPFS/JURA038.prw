#INCLUDE "JURA038.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA038
Area Juridica
  
@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA038()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRB" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRB" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------- -----------------------------------------------
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

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA038", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA038", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA038", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA038", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA038", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Area Juridica

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA038" )
Local oStruct := FWFormStruct( 2, "NRB" )

JurSetAgrp( 'NRB',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA038_VIEW", oStruct, "NRBMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA038_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Area Juridica"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Area Juridica

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0

@obs NRBMASTER - Dados do Area Juridica
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NRB" )
Local oCommit    := JA038Commit():New()

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA038", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRBMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Area Juridica"
oModel:GetModel( "NRBMASTER" ):SetDescription( STR0009 ) // "Dados de Area Juridica"

oModel:InstallEvent("JA038Commit", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NRBMASTER',, 'NRB' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA038SetRst
Função para chamada da JurSetRest() - Restrição de Cadastros, quando 
for inclusão pelo SIGAJURI. 

@author Jorge Luis Branco Martins Junior
@since 12/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA038SetRst(oModel)
Local cCod := oModel:GetValue("NRBMASTER","NRB_COD")
Local nOpc := oModel:GetOperation()
  
	If nOpc == 3 .And. nModulo == 76
		JurSetRest('NRB',cCod)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA038Commit
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA038Commit FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA038Commit
Return

Method InTTS(oSubModel, cModelId) Class JA038Commit
	JFILASINC(oSubModel:GetModel(), "NRB", "NRBMASTER", "NRB_COD")
	JA038SetRst(oSubModel:GetModel())
Return  