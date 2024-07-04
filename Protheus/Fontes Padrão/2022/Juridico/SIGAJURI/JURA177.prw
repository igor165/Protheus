#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA177.CH"
			
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA177
Valores históricos dos processos

@author André Spirigoni Pinto
@since 06/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA177(cProcesso, cBrwFilial)
Local oBrowse
Local lRet := (SuperGetMV("MV_JVLHIST",.F.,'2') == '2')

//Valida se os valores históricos estão habilitados e caso não estejam, fecha a tela;
If lRet
	JurMsgErro(STR0006) //"O parâmetro MV_JVLHIST deve ser habilitado para abrir o histórico de valores."
Else
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0001 ) //"Valores Históricos"
	oBrowse:SetAlias( "NYZ" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NYZ" )
	JurSetBSize( oBrowse )
	
	If !Empty(cProcesso)
		oBrowse:SetFilterDefault( " NYZ_FILIAL == '"+cBrwFilial +"' .AND. NYZ_CAJURI == '" + cProcesso + "'" )
	Endif
	
	oBrowse:Activate()
	
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura

@author André Spirigoni Pinto
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA177", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA177", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA177", 0, 8, 0, NIL } ) // "Imprimir"
                                              	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de parâmetros que serão sincronizados

@author André Spirigoni Pinto
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel( "JURA177" )
Local oStructNYZ := FWFormStruct( 2, "NYZ" )
Local oView      := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "NYZMASTER", oStructNYZ, "NYZMASTER"  )   
oView:CreateHorizontalBox( "PRINCIPAL" , 100 )
oView:SetOwnerView( "NYZMASTER" , "PRINCIPAL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da lista de parâmetros que serão sincronizados

@author André Spirigoni Pinto
@since 06/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNYZ := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNYZ := FWFormStruct(1,"NYZ")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA177", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NYZMASTER", /*cOwner*/, oStructNYZ,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NYZMASTER" ):SetDescription( STR0001 ) //"Valores Históricos"

JurSetRules( oModel, "NYZMASTER",, 'NYZ' )

Return oModel

