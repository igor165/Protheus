#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA130.CH"
  
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA130

Chamada do cadastro de especificações.

@sample		CRMA130()

@param			Nenhum

@return		Nenhum

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function CRMA130( cAlias )

Private aRotina 	:= MenuDef()

Default cAlias		:= Alias()

//-------------------------------------
// Browse do Cadastro Especificações. 
//-------------------------------------
BrowseDef( /*oMBrowse*/, cAlias ) 

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse do Cadastro Especificações.

@sample	BrowseDef( oMBrowse, cAlias ) 

@param		oMBrowse	, Objeto	, Browse criado pelo Widget da Area de Trabalho.
			cAlias		, Caracter	, Tabela relacionada a especificação.
		
@return	oMBrowse	, Objeto	, Retorna o objeto FWMBrowse.

@author	Anderson Silva
@since		20/04/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef( oMBrowse, cAlias ) 

Local oTableAtt 		:= Nil
Local aDadosSX2 		:= {}
Local cUnico 			:= ""
Local cFiltro			:= ""
Local lWidget			:= .F.

Default oMBrowse	:= Nil
Default cAlias		:= Alias()

If Empty( oMBrowse )
	oMBrowse	:= FWMBrowse():New()
	oMBrowse:SetAlias("AO0")
Else
	lWidget	:= .T.
EndIf

oMBrowse:SetCanSaveArea(.T.)  

If FunName() <> "CRMA130"  
	aDadosSX2	:= CRMXGetSX2( cAlias )
	cUnico		:= xFilial(cAlias)+(cAlias)->&(aDadosSX2[1])
	cFiltro 	:= "AO1_FILIAL = '"+xFilial("AO1")+"' AND AO1_ALIAS = '"+cAlias+"' AND AO1_UNICO = '"+cUnico+"'""
	oMBrowse:DeleteFilter("AO0_FIL")
	oMBrowse:AddFilter(STR0002,cFiltro,.T.,.T.,"AO1",,,"AO0_FIL")	// "Filtro Especificação X Entidades" 
	oMBrowse:ExecuteFilter()
EndIf 

oMBrowse:SetDescription(STR0001) // "Cadastro de Especificações"

If !lWidget 
	oTableAtt 	:= TableAttDef()
	oMBrowse:SetAttach( .T. )
	oMBrowse:SetViewsDefault( oTableAtt:aViews )
	oMBrowse:SetMainProc("CRMA130")
	oMBrowse:SetTotalDefault("AO0_FILIAL","COUNT",STR0012) // "Total de Registros"
	oMBrowse:Activate() 
EndIf 	
	
Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gráficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oAtivos		:= Nil // Especificações Ativas
Local oInativos		:= Nil // Especificações Inativas
Local oTableAtt 	:= FWTableAtt():New()

oTableAtt:SetAlias("AO0")

// Especificações Ativas 
oAtivos := FWDSView():New()
oAtivos:SetName(STR0013) // "Especificações Ativas"
oAtivos:SetID("Ativos") 
oAtivos:SetOrder(1) // AO0_FILIAL+AO0_CODESP
oAtivos:SetCollumns({"AO0_CODESP","AO0_TITULO","AO0_TIPO","AO0_DTVAL","AO0_DTULTM","AO0_HRULTM"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0013, "AO0_MSBLQL == '2'") // "Especificações Ativas"

oTableAtt:AddView(oAtivos)

// Especificações Inativas
oInativos := FWDSView():New()
oInativos:SetName(STR0014) // "Especificações Inativas"
oInativos:SetID("Inativos") 
oInativos:SetOrder(1) // AO0_FILIAL+AO0_CODESP
oInativos:SetCollumns({"AO0_CODESP","AO0_TITULO","AO0_TIPO","AO0_DTVAL","AO0_DTULTM","AO0_HRULTM"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0014, "AO0_MSBLQL == '1'") // "Especificações Inativas"

oTableAtt:AddView(oInativos)

Return (oTableAtt)	

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados do Cadastro de Especificações.

@sample		ModelDef()

@param			Nenhum

@return		ExpO - Objeto MPFormModel

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStruAO0		:= FWFormStruct(1,"AO0",/*bAvalCampo*/,/*lViewUsado*/,/*lVirtual*/)

oModel := MPFormModel():New("CRMA130",/*bPreValidacao*/,/*bPosValidação*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields("AO0MASTER",/*cOwner*/,oStruAO0,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({ 'AO0_FILIAL', 'AO0_CODESP' })	
oModel:SetDescription("Cadastro de Especificações")  
oModel:GetModel("AO0MASTER"):SetDescription("AO0")

Return (oModel)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface do Cadastro de Especificações.	

@sample		ViewDef()

@param			Nenhum

@return		ExpO - Objeto FWFormView

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//-------------------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel("CRMA130") 
Local oStruAO0 := FWFormStruct(2,"AO0")

oView := FWFormView():New()
oView:SetContinuousForm()
oView:SetModel(oModel)

oStruAO0:RemoveField( "AO0_DTULTM" )
oStruAO0:RemoveField( "AO0_HRULTM" )

oView:AddField("VIEW_AO0",oStruAO0,"AO0MASTER")

//Especificações
oView:CreateHorizontalBox("SUPERIOR",20)
oView:EnableTitleView("VIEW_AO0","Especificações")
oView:SetOwnerView("VIEW_AO0","SUPERIOR")

Return (oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação

@sample		MenuDef()

@param			Nenhum

@return   		aRotina - Array das operações

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0005 	ACTION 'PesqBrw'			OPERATION 1	ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.CRMA130A'	OPERATION 2	ACCESS 0 //"Visualizar"

If FunName() == "CRMA130"
	ADD OPTION aRotina TITLE STR0008 	ACTION 'VIEWDEF.CRMA130'	OPERATION 3	ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0009 	ACTION 'VIEWDEF.CRMA130A'	OPERATION 4	ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0010 	ACTION 'VIEWDEF.CRMA130A'	OPERATION 5	ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0011 	ACTION 'MsDocument("AO0",AO0->(RECNO()),4)'	OPERATION 4	ACCESS 0 //"Anexar"
EndIf
	
Return(aRotina)