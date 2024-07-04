#include 'AGRA005.CH'
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"


Function AGRA005()
	Local aArea    	:= GetArea()
	Private oBrowse	:= Nil

	//-------------------------
	//Instancia o objeto Browse
	//-------------------------
	oBrowse := FWMBrowse():New( , , , , , , , , , ,)
	oBrowse:SetAlias('NN2')
	oBrowse:SetDescription( STR0010 ) //"Cadastro de Fardões"
	oBrowse:AddLegend( "NN2_ATIVA=='A'", "GREEN", STR0008 )
	oBrowse:AddLegend( "NN2_ATIVA=='I'", "RED" , STR0009 )
	oBrowse:Activate()

	RestArea(aArea)
Return ()


Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNN2  := FwFormStruct( 1, "NN2" ) 

	//-----------------------------
	// Instancia o modelo de dados
	//-----------------------------
	oModel := MpFormModel():New( "AGRA005",/*bPre*/ ,/*bPost*/ ,/*bCommit*/ , /*bCancel*/ )
	oModel:SetDescription( STR0010 ) 

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGRA005_NN2", , oStruNN2,/*bPre*/ ,/*bPost*/ ,/*bLoad*/ )
	oModel:GetModel( "AGRA005_NN2" ):SetDescription( STR0010 ) 
	oModel:SetPrimaryKey( { "NN2_FILIAL", "NN2_CODIGO" } )
Return oModel


Static Function ViewDef()
	Local oStruNN2  := FwFormStruct( 2, "NN2" )  
	Local oModel	:= FwLoadModel( "AGRA005" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	If NN2->(ColumnPos('NN2_ID')) > 0 
		oStruNN2:RemoveField('NN2_ID')
	EndIf

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NN2', oStruNN2, 'AGRA005_NN2' )
	oView:CreateHorizontalBox( 'TELA', 100 )
	oView:SetOwnerView( 'VIEW_NN2', 'TELA' )

Return (oView)


Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGRA005' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGRA005' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGRA005' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.AGRA005' OPERATION 5 ACCESS 0

Return aRotina


/*/{Protheus.doc} IntegDef
@author brunosilva
@since 09/10/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}
	
	If ExistFunc('AGRI005')
		aRet:= AGRI005( cXml, nTypeTrans, cTypeMessage )
	EndIf
	
Return aRet
