#INCLUDE 'FISA180.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE FISA180_NomeCadastro STR0006 //"Complemento Fiscal do Produto"
#DEFINE FISA180_NomeRotina "FISA180"
#DEFINE FISA180_AliasPrincipal "F2Q"

/*/{Protheus.doc} FISA180
Rotina de Complemento Fiscal de produto
@author reynaldo
@since 28/06/2018
@version 1.0
@return NIL, ${return_description}

@type function
/*/
FUNCTION FISA180()
Local oBrowse	As Object

	oBrowse := BrowseDef()
	oBrowse:Activate()

RETURN

/*/{Protheus.doc} BrowseDef
Definição do browse principal do Complemento Fiscal dos produtos
@author reynaldo
@since 28/06/2018
@version 1.0
@return Object, FwMBrowse

@type function
/*/
STATIC FUNCTION BrowseDef() As Object
Local oBrowse	As Object

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( FISA180_AliasPrincipal )
oBrowse:SetDescription(FISA180_NomeCadastro)

RETURN oBrowse

/*/{Protheus.doc} MenuDef
Montagem do array aRotinas
@author reynaldo
@since 28/06/2018
@version 1.0
@return Array, ${return_description}

@type function
/*/
Static Function MenuDef() As Array
Local aRotina	As Array

aRotina := {}

//ADD OPTION aRotina TITLE "Pesquisar" ACTION 'PesqBrw'		OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.FISA180'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FISA180'	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA180'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA180'	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA180'	OPERATION 9 ACCESS 0 //"Copia"

RETURN aRotina

/*/{Protheus.doc} ModelDef
Definição da modelagem da tabela F2Q
@author reynaldo
@since 28/06/2018
@version 1.0
@return oModel, ${return_description}

@type function
/*/
Static Function ModelDef() As Object
Local oModel	As Object
Local oStrF2Q	As Object

oStrF2Q := FWFormStruct(1 ,FISA180_AliasPrincipal)

oModel := MPFormModel():New( FISA180_NomeRotina ,/* bPreValidacao */ ,/* bPosValidacao */  )

oModel:SetDescription(FISA180_NomeCadastro)
oModel:AddFields('F2QMASTER' ,,oStrF2Q)

RETURN oModel

/*/{Protheus.doc} ViewDef
Definição da montagem da janela da tabela F2Q
@author reynaldo
@since 28/06/2018
@version 1.0
@return oView, ${return_description}

@type function
/*/
Static Function ViewDef() As Object
Local oModel	As Object
Local oStrF2Q	As Object
Local oView		As Object

oModel := FWLoadModel( FISA180_NomeRotina )
oStrF2Q	:= FWFormStruct( 2 ,FISA180_AliasPrincipal )
oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('F2QMASTER' ,oStrF2Q)

oView:CreateVerticalBox( 'BOXMAIN' ,100)
oView:SetOwnerView('F2QMASTER' ,'BOXMAIN')

RETURN oView

/*/{Protheus.doc} MATA010FISA180
Classe para ser utilizada na rotina MATA010
@author reynaldo
@since 28/06/2018
@version 1.0
@return NIL, ${return_description}

@type class
/*/
CLASS MATA010FISA180 FROM FWModelEvent

	DATA cModelProduto	As Character
	DATA lProdutoCadastro As Logical

	METHOD New(cModelMaster) CONSTRUCTOR
	METHOD VldActivate(oModel, cModelId)

	METHOD ViewDefMata010(oView)
	METHOD A010CanActivate(oView)
	METHOD ModelDefMata010(oModel)

EndClass

/*/{Protheus.doc} New
Metodo de criação do objeto
@author reynaldo
@since 28/06/2018
@version 1.0
@param Character,
@return NIL, ${return_description}

@type method
/*/
METHOD New(cModelMaster) CLASS MATA010FISA180

	::cModelProduto := cModelMaster
	::lProdutoCadastro := "F2Q" $ SuperGetMv("MV_CADPROD",,"|SBZ|SB5|SGI|")
	
RETURN

/*/{Protheus.doc} VldActivate
Metodo de interceptação do método VldActivate do Model ITEM
@author reynaldo
@since 28/06/2018
@version 1.0
@param Object,
@param Character,
@return ${return}, ${return_description}

@type method
/*/
METHOD VldActivate(oModel, cModelId) CLASS MATA010FISA180

	::ModelDefMata010(oModel)

RETURN .T.

/*/{Protheus.doc} ViewDefMata010
Definição para utilizar o objeto Edicao por campo a ser apresentado na janela de Produtos
@author reynaldo
@since 28/06/2018
@version 1.0
@param Object,
@return NIL, ${return_description}

@type method
/*/
METHOD ViewDefMata010(oView) CLASS MATA010FISA180

	If ::lProdutoCadastro
		oView:AddField("FORMF2Q" ,FWFormStruct(2 ,"F2Q" ,{|cField| !(AllTrim(Upper(cField)) $ "F2Q_PRODUT") }) ,"F2QDETAIL")
	EndIf

RETURN

/*/{Protheus.doc} A010CanActivate
Metodo chamado no objeto oView do produto no metodo A010CanActivate para habilitar ou não a View da tabela F2Q
@author reynaldo
@since 28/06/2018
@version 1.0
@param Object,
@return ${return}, ${return_description}

@type method
/*/
METHOD A010CanActivate(oView) CLASS MATA010FISA180
Local nOpc	:= 0

	If ::lProdutoCadastro
		nOpc := oView:GetOperation()
		If MPUserHasAccess("FISA180", nOpc) // checa se o ususario tem acesso a rotina na opcao escolhida
			oView:CreateHorizontalBox( 'BOXFORMF2Q' ,10)
			oView:SetOwnerView("FORMF2Q" ,'BOXFORMF2Q')
			oView:EnableTitleView("FORMF2Q" ,FwX2Nome("F2Q"))
		EndIf
	EndIf
RETURN

/*/{Protheus.doc} ModelDefMata010
Definição da modelagem da tabela F2Q para ser adicionada no Model da tabela de produtos
@author reynaldo
@since 28/06/2018
@version 1.0
@param Object,
@return ${return}, ${return_description}

@type method
/*/
METHOD ModelDefMata010(oModel) CLASS MATA010FISA180
Local oStruF2Q As Object

	If ::lProdutoCadastro
		oStruF2Q := FWFormStruct(1, "F2Q", {|cField| !(AllTrim(Upper(cField)) $ "F2Q_PRODUT") })

		oModel:AddFields("F2QDETAIL" ,::cModelProduto ,oStruF2Q)
		oModel:SetRelation("F2QDETAIL" ,{ { 'F2Q_FILIAL', 'xFilial("F2Q")' } ,{ 'F2Q_PRODUT' ,'B1_COD' } } ,F2Q->(IndexKey(1)) )
		oModel:GetModel("F2QDETAIL"):SetOptional(.T.)
	EndIf

RETURN
