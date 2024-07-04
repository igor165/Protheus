#INCLUDE 'MATA036.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

/*/{Protheus.doc} MATA036
Rotina de Complemento de produto
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@Return NIL, ${Return_description}

@type function
/*/
FUNCTION MATA036()
Local oBrowse	As Object

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return

/*/{Protheus.doc} BrowseDef
Definição do browse principal do Complemento Fiscal dos produtos
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@Return Object, FwMBrowse

@type function
/*/
STATIC FUNCTION BrowseDef() As Object
Local oBrowse	As Object

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "D3E" )
oBrowse:SetDescription(STR0007)

Return oBrowse

/*/{Protheus.doc} MenuDef
Montagem do array aRotinas
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@Return Array, ${Return_description}

@type function
/*/
Static Function MenuDef() As Array
Local aRotina	As Array

aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MATA036'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA036'	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA036'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA036'	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MATA036'	OPERATION 9 ACCESS 0 //"Copia"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição da modelagem da tabela F2Q
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@Return oModel, ${Return_description}

@type function
/*/
Static Function ModelDef() As Object
Local oStrD3E 	:= FWFormStruct(1 ,"D3E")
Local oModel 	:= MPFormModel():New( "MATA036" ,/* bPreValidacao */ ,/* bPosValidacao */  )

oModel:SetDescription( STR0007 )
oModel:AddFields('D3EMASTER' ,, oStrD3E )

Return oModel

/*/{Protheus.doc} ViewDef
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@Return oView, ${Return_description}

@type function
/*/
Static Function ViewDef() As Object
Local oModel	:= FWLoadModel( "MATA036" )
Local oStrD3E	:= FWFormStruct( 2 ,"D3E" )
Local oView		:= FWFormView():New()

oView:SetModel(oModel)
oView:AddField( 'D3EMASTER', oStrD3E )
oView:CreateVerticalBox( 'BOXMAIN' , 100 )
oView:SetOwnerView('D3EMASTER', 'BOXMAIN' )

Return oView

/*/{Protheus.doc} Mata010Mata036
Classe para ser utilizada na rotina MATA010
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@Return NIL, ${Return_description}

@type Class
/*/

Class Mata010Mata036 From FwModelEvent
Data cModelProduto	As Character
Data lProdutoCadastro As Logical

Method New( cModelMaster ) Constructor
Method VldActivate( oModel, cModelId )
Method ViewDefMata036( oView )
Method A036CanActivate( oView )
Method ModelDefMata036( oModel )

EndClass


/*/{Protheus.doc} New
Metodo de criação do objeto
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@param Character,
@Return NIL, ${Return_description}

@type Method
/*/
Method New( cModelMaster ) Class Mata010Mata036
	Self:cModelProduto 	  := cModelMaster
	Self:lProdutoCadastro := "D3E" $ SuperGetMv( "MV_CADPROD",,"|SBZ|SB5|SGI|D3E" )
Return

/*/{Protheus.doc} VldActivate
Metodo de interceptação do método VldActivate do Model ITEM
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@param Object,
@param Character,
@Return ${Return}, ${Return_description}

@type Method
/*/
Method VldActivate( oModel, cModelId ) Class Mata010Mata036
	Self:ModelDefMata036(oModel)
Return .T.

/*/{Protheus.doc} ViewDefMata036
Definição para utilizar o objeto Edicao por campo a ser apresentado na janela de Produtos
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@param Object,
@Return NIL, ${Return_description}

@type Method
/*/
Method ViewDefMata036( oView ) Class Mata010Mata036
	If Self:lProdutoCadastro
		oView:AddField("FORMD3E" ,FWFormStruct(2 ,"D3E" ,{|cField| !(AllTrim(Upper(cField)) $ "D3E_COD") }) ,"D3EDETAIL")
	EndIf
Return

/*/{Protheus.doc} A010CanActivate
Metodo chamado no objeto oView do produto no metodo A010CanActivate para habilitar ou não a View da tabela D3E
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@param Object,
@Return ${Return}, ${Return_description}

@type Method
/*/
Method A036CanActivate( oView ) Class Mata010Mata036
Local nOpc	:= 0

	If Self:lProdutoCadastro
		nOpc := oView:GetOperation()
		If MPUserHasAccess("MATA036", nOpc) // checa se o ususario tem acesso a rotina na opcao escolhida
			oView:CreateHorizontalBox( 'BOXFORMD3E' ,10)
			oView:SetOwnerView("FORMD3E" ,'BOXFORMD3E')
			oView:EnableTitleView("FORMD3E" ,FwX2Nome("D3E"))
		EndIf
	EndIf
Return

/*/{Protheus.doc} ModelDefMata036
Definição da modelagem da tabela D3E  para ser adicionada no Model da tabela de produtos
@author Andre / Beraldo
@since 04/10/2018
@version 1.0
@param Object,
@Return ${Return}, ${Return_description}

@type Method
/*/
Method ModelDefMata036(oModel) Class Mata010Mata036
Local oStD3E As Object

	If Self:lProdutoCadastro
		oStD3E := FWFormStruct(1, "D3E", {|cField| !(AllTrim(Upper(cField)) $ "D3E_COD") })
		oModel:AddFields("D3EDETAIL" ,::cModelProduto ,oStD3E)
		oModel:SetRelation("D3EDETAIL" ,{ { 'D3E_FILIAL', 'xFilial("D3E")' } ,{ 'D3E_COD' ,'B1_COD' } } ,D3E->(IndexKey(1)) )
		oModel:GetModel("D3EDETAIL"):SetOptional(.T.)
	EndIf

Return

/*/{Protheus.doc} 
Validação Cliente
@author Andre 
@since 16/10/2018
@version 1.0
@param Object,
@Return ${Return}, ${Return_description}
@type Function
/*/


Function A036PROD()
	
Local lRet  := .T.

If Empty(M->D3E_CLIENT)
	M->D3E_LOJPROC :=Space(TamSX3("D3E_LOJA")[1])
Else
	SA1->(DbSetOrder(1))
	If !SA1->(DbSeek(xFilial("SA1")+M->D3E_CLIENT))
		Help("  ",1,"REGNOIS")
		lRet := .F.
	EndIf
Endif
	
Return(lRet)

/*/{Protheus.doc} 
Validação Loja
@author Andre 
@since 16/10/2018
@version 1.0
@param Object,
@Return ${Return}, ${Return_description}
@type Function
/*/

Function A036LojProc()
Local lRet := .T.
Local cVar:= &(ReadVar())
Local aAreaSB1 := GetArea()

If Empty(cVar) .And. Empty(M->D3E_CLIENT)
    lRet := .T.
elseIf !ExistCpo("SA1",M->D3E_CLIENT+cVar)
    lRet := .F.
EndIf

RestArea(aAreaSB1)
Return lRet