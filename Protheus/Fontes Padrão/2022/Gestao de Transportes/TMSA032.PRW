#INCLUDE "TMSA032.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} TMSA032()
Cadastro de Check List

Uso: SIGATMS

@sample
//TMSA032()

@author Rafael Souza
@since 18/03/2015
@version 1.0
/*/
//-----------------------------------------------------------/*/
Function TMSA032()
	Local oBrowse   := Nil				// Recebe o  Browse

	Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DJ3")			    // Alias da tabela utilizada
	oBrowse:SetMenuDef("TMSA032")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)		//"Cadastro de Check List "

	oBrowse:Activate()

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional

Uso: TMSA032

@sample
//MenuDef()

@author Rafael Souza.
@since 18/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 DISABLE MENU // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSA032" OPERATION 2 ACCESS 0 DISABLE MENU // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSA032" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSA032" OPERATION 4 ACCESS 0 DISABLE MENU // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSA032" OPERATION 5 ACCESS 0 DISABLE MENU // "Excluir"

Return(aRotina)

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSA032

@sample
//ModelDef()

@author Rafael Souza
@since 18/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ModelDef()

	Local oModel	 := Nil		// Objeto do Model
	Local oStruDJ3 := Nil		// Recebe a Estrutura da tabela DJ3

	oStruDJ3:= FWFormStruct( 1, "DJ3" )

	oModel := MPFormModel():New( "TMSA032",,,/*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'MdFieldDJ3',, oStruDJ3,,,/*Carga*/ )

	oModel:GetModel( 'MdFieldDJ3' ):SetDescription( STR0001 ) 	//"Cadastro de Check List"

	oModel:SetPrimaryKey({"DJ3_FILIAL" , "DJ3_CODIGO"})

	oModel:SetActivate( )

Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da View

Uso: TMSA032

@sample
//ViewDef()

@author Rafael Souza
@since 18/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= Nil		   // Objeto do Model
	Local oStruDJ3	:= Nil		// Recebe a Estrutura da tabela DJ3
	Local oView					// Recebe o objeto da View

	oModel   := FwLoadModel("TMSA032")
	oStruDJ3 := FWFormStruct( 2, "DJ3" )


	oView := FwFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VwFieldDJ3', oStruDJ3 , 'MdFieldDJ3')

	oView:CreateHorizontalBox('CABECALHO', 100)
	oView:SetOwnerView('VwFieldDJ3','CABECALHO')

Return oView