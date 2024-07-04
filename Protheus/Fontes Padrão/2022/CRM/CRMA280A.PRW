#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CRMA280A.ch'


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA280A

Rotina Complemento de Funçao para envio de Email 


@sample     CRMA280A()

      


@return     Nenhum

@author     Ronaldo Robes
@since          15/05/2015
@version     12.1.5
/*/
//------------------------------------------------------------------------------



Function CRMA280A()

Local oBrowse := FwMBrowse():New()


	oBrowse:SetAlias('AZB')
	oBrowse:SetDescription( STR0001 )//COMPLEMENTO DE FUNÇAO 
	oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Formaçao da Model Def rotina de complemento de Função  

@author Ronaldo Robes 
@since 08/05/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrAZB	:= Nil
	
	oStrAZB 	:= FWFormStruct( 1, 'AZB' )
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('CRMA280A')//,,,bCommit)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('AZBMASTER',,oStrAZB)

	oModel:setprimarykey({"AZB_ENTIDADE"})

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription ( STR0001 )//COMPLEMENTO DE FUNÇAO 
	oModel:GetModel('AZBMASTER'):SetDescription( STR0001 )//COMPLEMENTO DE FUNÇAO 
	


Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

	Formaçao da ViewDef pertencente a  rotina de complemento de Função  

@author Ronaldo Robes 
@since 05/06/2015
@version 12
/*/
//-------------------------------------------------------------------



Static Function ViewDef()

	Local oView
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'CRMA280A' )
	Local oStrAZB	:= Nil


	oStrAZB := FWFormStruct( 2, 'AZB')//, bFieldsView )
	

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)   

	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_AZB'	, oStrAZB, 'AZBMASTER')


	// Criar "box" horizontal para receber algum elemento da view

	oView:CreateHorizontalBox('CORPO',100)


	// Relaciona o ID da View com o "box" para exibicao
	
	oView:SetOwnerView( 'VIEW_AZB' ,'CORPO'  )

	// Define campos que terao relaçao


	oView:EnableTitleView( 'VIEW_AZB' )


Return(oView)
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Define as operações realizadas pela aplicação.	

@author Ronaldo Robes 
@since 05/06/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina := {}


	aRotina := FWMVCMENU("CRMA280A")

Return(aRotina)


//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA280ADelete



@author Ronaldo Robes 
@since 05/06/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function CRMA280ADelete(oView)

Return(.T.)



