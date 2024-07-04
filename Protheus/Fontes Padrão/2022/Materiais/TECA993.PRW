#Include "TECA993.ch"
#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA993
Agrupadores de custos

@author fabiana.silva
@since 26/09/2019
@version P12.1.27
@return  Nil

/*/
//-------------------------------------------------------------------------------------

Function TECA993()

Local oBrowse
Private cCadastro:= ""	
Private aRotina := {}

If AliasInDic("TXG")
	cCadastro:= FwSX2Util():GetX2Name( "TXG" )	
	aRotina := MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse :SetAlias('TXG')
	oBrowse :SetDescription(cCadastro) 
	oBrowse :Activate()
Else
	Help( " ", 1, "TECA993", Nil, STR0001, 1 ) //"Tabela TXG não existe no dicionário de Dados"
EndIf

Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - Agrupadores de custos

@author fabiana.silva
@since 26/09/2019
@version P12.1.27
@return  aRotina - Array de Menus

/*/
//-------------------------------------------------------------------------------------

Static Function MenuDef()  

Local aRotina := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transacao a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//³    6 - Alteracao sem inclusao de registro                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'			 	OPERATION 1	ACCESS 0 //STR0002 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA993'	OPERATION 2	ACCESS 0 //STR0003 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TECA993'	OPERATION 3	ACCESS 0 //STR0004 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TECA993'	OPERATION 4	ACCESS 0 //STR0005 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TECA993'	OPERATION 5	ACCESS 0 //STR0006 //"Excluir"

Return aRotina

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Modeldef
ModelDef - Agrupadores de custos

@author fabiana.silva
@since 26/09/2019
@version P12.1.27
@return  oModel  - Modelo Dados

/*/
//-------------------------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel
Local oStruTXGM		:= FWFormStruct(1,'TXG',{|cCampo| AllTrim(cCampo)+"|" $ "TXG_FILIAL|TXG_CODIGO|TXG_DESCR|"})
Local oStruTXGD  		:= FWFormStruct(1,'TXG')


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('TECA993',/*bPreValidacao*/,/*{|oMdl| At080IncOk(oMdl)}*/,/*bCommit*/,/*bCancel*/)

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields('TXGMASTER',/*cOwner*/,oStruTXGM,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

// Adiciona ao modelo uma estrutura de formulario de edicao por grid
oModel:AddGrid( 'TXGDETAIL','TXGMASTER',oStruTXGD,/*bPreValidacao*/,/*bLinePost*/,/*bCarga*/,{ |oMdl| At993tOk(oMdl)}) // Adiciona uma Grid ao modelo

// Faz relaciomanto entre os compomentes do model
oModel:SetRelation("TXGDETAIL",{{"TXG_FILIAL",'xFilial("TXG")'},{"TXG_CODIGO","TXG_CODIGO"}},TXG->(IndexKey(2)))

oStruTXGD:SetProperty('TXG_DESCR',MODEL_FIELD_OBRIGAT, .F.  )
oStruTXGD:SetProperty('TXG_CODIGO',MODEL_FIELD_OBRIGAT, .F. )
oStruTXGD:SetProperty('TXG_CODIGO', MODEL_FIELD_INIT,{|| "" } )

//Incializador configurado no modelo porque no dicionário não funciona
oStruTXGD:SetProperty('TXG_DESPLA',MODEL_FIELD_INIT,{|| At993DsPl()  } )

//Chave primaria para a entidade principal do modelo de dados.
oModel:SetPrimaryKey({'TXG_FILIAL','TXG_CODIGO'}) 

oModel:GetModel( 'TXGDETAIL' ):SetUniqueLine( { 'TXG_PLANIL', 'TXG_CELULA' } )

Return oModel

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - Agrupadores de custos

@author fabiana.silva
@since 26/09/2019
@version P12.1.27
@return  oView - Modelo Visual

/*/
//-------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel('TECA993')
Local oStruTXGM		:= FWFormStruct(2,'TXG',{|cCampo| AllTrim(cCampo)+"|" $ "TXG_FILIAL|TXG_CODIGO|TXG_DESCR|"})
Local oStruTXGD  		:= FWFormStruct(2,'TXG', {|cCampo| ! (AllTrim(cCampo)+"|" $ "TXG_FILIAL|TXG_CODIGO|TXG_DESCR|")})

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruTXGM,'TXGMASTER')
oView:AddGrid('VIEW_GRID',oStruTXGD,'TXGDETAIL')

oView:AddIncrementField( 'VIEW_GRID', 'TXG_ITEM' )		// Item Incremental do Grid


oView:CreateHorizontalBox('SUPERIOR',15)
oView:CreateHorizontalBox('INFERIOR',85)

oView:SetOwnerView('VIEW_CAB','SUPERIOR')
oView:SetOwnerView('VIEW_GRID','INFERIOR')

oView:EnableTitleView('VIEW_CAB', STR0007) //"Cadastro Agrupador"
oView:EnableTitleView('VIEW_GRID', STR0008) //"Definições Planilhas e Células"

Return oView

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At993TOk
At993TOk - Agrupadores de custos

@author fabiana.silva
@since 26/09/2019
@version P12.1.27
@param oMdlGrd  - SubModelo 
@return  lRet - SubModelo Válido

/*/
//-------------------------------------------------------------------------------------
Static Function At993TOk(oMdlGrd)
Local oModel		:= oMdlGrd:GetModel()
Local nOperation 	:= oModel:GetOperation()
Local lRet 			:= .T.
Local cDescr		:= "" //Descrição do Modelo
Local nC			:= 0
Local aSaveLines	:= {}


If nOperation <> MODEL_OPERATION_DELETE .AND. !oMdlGrd:IsEmpty()

	aSaveLines := FwSaveRows()
	cDescr := oModel:GetModel("TXGMASTER"):GetValue("TXG_DESCR") 


	For nC := 1 to oMdlGrd:Length()
		oMdlGrd:GoLine(nC)
		
		If !oMdlGrd:IsDeleted()
		
			If oMdlGrd:GetValue("TXG_DESCR") <> cDescr
				oMdlGrd:LoadValue("TXG_DESCR", cDescr)
			EndIf
			
		EndIf
	Next 
	
	FwRestRows(aSaveLines)
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At993DsPl
At993DsPl - Inicializador Padrão Campo TXG_DESPLAN

@author fabiana.silva
@since 26/09/2019
@return  cRet - Descrição da Planilha
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------
Static Function At993DsPl()
Local cRet 		:= ""
Local oModel 	:= FwModelActive()
Local lInsert 	:= .F.
Local oSubModel := NIL


If ValType(oModel) == "O" .And. oModel:IsActive() 
	lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT
	If !lInsert
		oSubModel := oModel:GetModel("TXGDETAIL")
		lInsert :=  ValType(oSubModel) == "O" .AND. oSubModel:IsActive() .AND. oSubModel:lInsertLine
	EndIf
EndIf

If !lInsert
	cRet := GetAdvFval("ABW","ABW_DESC",xFilial("ABW")+TXG->TXG_PLANIL, 1, "", .T.)
EndIf

Return cRet
