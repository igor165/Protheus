#INCLUDE 'FINA915.ch'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} FINA915
Função importação e processamento do arquivo enviado pela caixa economica federal referente aos recebimentos
do projeto Minha Casa Minha Vida. 

@author Totvs
@since 13/01/2015	
@version 11.80
/*/


Function FINA915()


Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FJP')
oBrowse:SetDescription(OemToAnsi(STR0001))
oBrowse:AddLegend( "FJP_SITUACA =='1'", "YELLOW"	, OemToAnsi(STR0002))
oBrowse:AddLegend( "FJP_SITUACA =='2'", "BLUE"	, OemToAnsi(STR0003))
oBrowse:AddLegend( "FJP_SITUACA =='3'", "RED"		, OemToAnsi(STR0004))
oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
Menu Funcional.
@author Totvs
@since  13/01/2015
@version 11.80
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0005)	 	Action 'VIEWDEF.FINA915'	OPERATION 1 ACCESS 0	//'Pesquisar'	
ADD OPTION aRotina Title OemToAnsi(STR0006)  	 	Action 'VIEWDEF.FINA915'	OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina Title OemToAnsi(STR0007) 	 	Action 'FINA915A'			OPERATION 3 ACCESS 0	
ADD OPTION aRotina Title OemToAnsi(STR0008) 		Action 'FINA915B'			OPERATION 4 ACCESS 0	
ADD OPTION aRotina Title OemToAnsi(STR0009) 		Action 'FINR915'			OPERATION 1 ACCESS 0

Return aRotina



/*/{Protheus.doc} ModelDef
Modelo de negócio do processamento do arquivo
@author Totvs
@since  13/01/2015
@version 11.80
/*/

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados 
Local oStruFJP := FWFormStruct( 1, 'FJP', /*bAvalCampo*/,/*lViewUsado*/ )
// Cria o objeto do Modelo de Dados
Local oModel 	 := MPFormModel():New('FINA915')//, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oModel|F915GRV(oModel)}*/, /*bCancel*/ )
Local oCab		 := FWFormModelStruct():New()


oModel:AddFields('FJPMASTER', /*cOwner*/, oStruFJP)
oModel:SetDescription( OemToAnsi(STR0010) )
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FJPMASTER' ):SetDescription( OemToAnsi(STR0010))


Return oModel


/*/{Protheus.doc} ViewDef
Interface do processamento de arquivo.
@author Totvs
@since  13/01/2015
@version 11.80
/*/

Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel  	 := FWLoadModel( 'FINA915' )
// Cria a estrutura a ser usada na View
Local oStruFJP 	:= FWFormStruct( 2, 'FJP' )
//Local oFJP	  		:= FWFormStruct(1, 'FJP')
// Cria o objeto de View
Local oView		:= FWFormView():New()
//Local cCampos 	:= {}

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:Addfield( 'VIEW_FJP', oStruFJP, 'FJPMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FJP', 'TELA' )

//oSubFJP  := oModel:GetModel("FJPDETAIL")

Return oView


