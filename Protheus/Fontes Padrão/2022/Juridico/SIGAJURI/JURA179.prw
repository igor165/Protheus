#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA179.CH"
			
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA179
Valores históricos dos valores em discussão

@author Jorge Luis Branco Martins Junior
@since 20/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA179(cValor, cBrwFilial)
Local oBrowse
Local lRet := (SuperGetMV("MV_JVLHIST",.F.,'2') == '2')

//Valida se os valores históricos estão habilitados e caso não estejam, fecha a tela;
If lRet
	JurMsgErro(STR0001) //"O parâmetro MV_JVLHIST deve ser configurado para abrir o histórico de valores."
Else

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0002 ) //"Valores Históricos"
	oBrowse:SetAlias( "NZ1" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NZ1" )
	JurSetBSize( oBrowse )
	
	If !Empty(cValor)
		oBrowse:SetFilterDefault( " NZ1_FILIAL == '" + cBrwFilial + "' .AND. NZ1_CVALOR == '" + cValor + "'" )
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
aAdd( aRotina, { STR0004, "VIEWDEF.JURA179", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA179", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA179", 0, 8, 0, NIL } ) // "Imprimir"
                                              	
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
Local oView
Local oModel  := FWLoadModel( "JURA179" )
Local oStructNZ1 := FWFormStruct( 2, "NZ1" )

JurSetAgrp( 'NZ1',, oStructNZ1 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA0179_VIEW", oStructNZ1, "NZ1MASTER"  )   
oView:CreateHorizontalBox( "PRINCIPAL" , 100 )
oView:SetOwnerView( "JURA0179_VIEW" , "PRINCIPAL" )

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
Local oStructNZ1 := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNZ1 := FWFormStruct(1,"NZ1")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA179", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NZ1MASTER", /*cOwner*/, oStructNZ1,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NZ1MASTER" ):SetDescription( STR0002 ) //"Valores Históricos"

JurSetRules( oModel, "NZ1MASTER",, 'NZ1' )

Return oModel

