#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA178.CH"
			
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA178
Valores históricos das garantias

@author Jorge Luis Branco Martins Junior
@since 20/06/14

@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA178(cGarantia, cBrwFilial)
Local oBrowse
Local lRet := (SuperGetMV("MV_JVLHIST",.F.,'2') == '2')

//Valida se os valores históricos estão habilitados e caso não estejam, fecha a tela;
If lRet
	JurMsgErro(STR0001) //"O parâmetro MV_JVLHIST deve ser configurado para abrir o histórico de valores."
Else

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0002 ) //"Valores Históricos"
	oBrowse:SetAlias( "NZ0" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NZ0" )
	JurSetBSize( oBrowse )
	
	If !Empty(cGarantia)
		oBrowse:SetFilterDefault( " NZ0_FILIAL == '" + cBrwFilial + "' .AND. NZ0_CGARAN == '" + cGarantia + "'" )
	Endif
	
	oBrowse:Activate()
	
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura

@author Jorge Luis Branco Martins Junior
@since 20/06/14

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA178", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA178", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA178", 0, 8, 0, NIL } ) // "Imprimir"
                                              	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de parâmetros que serão sincronizados

@author Jorge Luis Branco Martins Junior
@since 20/06/14

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel( "JURA178" )
Local oStructNZ0 := FWFormStruct( 2, "NZ0" )
Local oView := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "NZ0MASTER", oStructNZ0, "NZ0MASTER"  )                                                   
oView:CreateHorizontalBox( "PRINCIPAL" , 100 )
oView:SetOwnerView( "NZ0MASTER" , "PRINCIPAL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da lista de parâmetros que serão sincronizados

@author Jorge Luis Branco Martins Junior
@since 20/06/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNZ0 := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNZ0 := FWFormStruct(1,"NZ0")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA178", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NZ0MASTER", /*cOwner*/, oStructNZ0,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NZ0MASTER" ):SetDescription( STR0002 ) //"Valores Históricos"

JurSetRules( oModel, "NZ0MASTER",, 'NZ0' )

Return oModel

