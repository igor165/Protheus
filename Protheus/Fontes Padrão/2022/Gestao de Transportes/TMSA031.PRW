#INCLUDE "TMSA031.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} TMSA031()
Cadastro de Caracteristicas

Uso: SIGATMS

@sample
//TMSA031()

@author Rafael Souza
@since 17/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Function TMSA031()
Local oBrowse   := Nil				// Recebe o  Browse

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.


oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DJ0")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSA031")		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)		//"Cadastro de Caracteristicas "

oBrowse:Activate()

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional

Uso: TMSA031

@sample
//MenuDef()

@author Rafael Souza.
@since 17/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 DISABLE MENU // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSA031" OPERATION 2 ACCESS 0 DISABLE MENU // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSA031" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSA031" OPERATION 4 ACCESS 0 DISABLE MENU // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSA031" OPERATION 5 ACCESS 0 DISABLE MENU // "Excluir"

Return(aRotina)

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSA031

@sample
//ModelDef()

@author Rafael Souza
@since 17/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ModelDef()

Local oModel	 := Nil		// Objeto do Model
Local oStruDJ0 := Nil		// Recebe a Estrutura da tabela DJ0

oStruDJ0:= FWFormStruct( 1, "DJ0" )

oModel := MPFormModel():New( "TMSA031",,,/*bCommit*/, /*bCancel*/ )
oModel:AddFields( 'MdFieldDJ0',, oStruDJ0,,,/*Carga*/ )

oModel:GetModel( 'MdFieldDJ0' ):SetDescription( STR0001 ) 	//"Cadastro de Caracteristicas"

oModel:SetPrimaryKey({"DJ0_FILIAL" , "DJ0_CODIGO"})

oModel:SetActivate( )

Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da View

Uso: TMSA031

@sample
//ViewDef()

@author Rafael Souza
@since 17/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ViewDef()
Local oModel	:= Nil		   // Objeto do Model
Local oStruDJ0	:= Nil		// Recebe a Estrutura da tabela DJ0
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSA031")
oStruDJ0 := FWFormStruct( 2, "DJ0" )


oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField('VwFieldDJ0', oStruDJ0 , 'MdFieldDJ0')

oView:CreateHorizontalBox('CABECALHO', 100)
oView:SetOwnerView('VwFieldDJ0','CABECALHO')

Return oView
