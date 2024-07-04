#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "TECA805A.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Associa��o CheckList x Produto
@description	Defini��o do Model
@sample	 		ModelDef()
@param			Nenhum
@return			ExpO: Objeto FwFormModel
@author 		filipe.goncalves
@since 			21/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil
Local oStrCab		:= FWFormStruct(1, "TWE", {|cCampo| !AllTrim(cCampo)$ "TWE_FILIAL|TWE_CODPRO|TWE_DESPRO|TWE_CODTWE"})	// Cabe�alho
Local oStrGri 	:= FWFormStruct(1, "TWE", {|cCampo| !AllTrim(cCampo)$ "TWE_CODTWC|TWE_DESTWC"})	// Itens

// Cria o objeto do modelo de dados principal
oModel := MPFormModel():New("TECA805A",/*bPreValid*/, /*bP�sValid*/, /*bCommit*/, /*bCancel*/)

// Cria a antiga Enchoice do grupo de comunica��o
oModel:AddFields("CABMASTER", /*cOwner*/ , oStrCab, /*{|oModel, cAction, cCampo, xValor|TC805VldBl(oModel, cAction, cCampo, xValor)}*/)

// Cria a grid das etapas do grupo de comunica��o
oModel:AddGrid("GRIDETAIL","CABMASTER",oStrGri,/*bPreValidacao*/ ,/*bPosValidacao*/,,, /*bCarga*/)

//Chave prim�ria
oModel:SetPrimaryKey({'TWE_CODTWC'})

//Cria��o dos relacionamentos
oModel:SetRelation("GRIDETAIL", {{"TWE_FILIAL" , "xFilial('TWE')"}, {"TWE_CODTWE","TWE_CODTWC"}}, TWE->(IndexKey(1)))

//N�o Grava Cabe�alho
oModel:GetModel( 'CABMASTER' ):SetOnlyQuery ( .T. )

//Campos que n�o ser�o repetidos 
oModel:GetModel('GRIDETAIL'):SetUniqueLine( { 'TWE_CODPRO' } )

//Defini��o das descri��es
oModel:GetModel("GRIDETAIL"):SetDescription(STR0002)

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Defini��o da View
@sample	 		ViewDef()
@param			Nenhum
@return			ExpO	Objeto FwFormView 
@author 		filipe.goncalves 
@since 			21/06/2016
@version		P12   
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil						// Interface de visualiza��o constru�da	
Local oModel	:= ModelDef()				// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStrCAB	:= FWFormStruct(2, "TWE", {|cCampo| !AllTrim(cCampo)$ "TWE_FILIAL|TWE_CODPRO|TWE_DESPRO|TWE_CODTWE"})	// Cria a estrutura a ser usada na View
Local oStrGRI := FWFormStruct(2, "TWE", {|cCampo| !AllTrim(cCampo)$ "TWE_CODTWC|TWE_DESTWC|TWE_CODTWE"})	

// Cria o objeto de View
oView	:= FWFormView():New()

// Define qual modelo de dados ser� utilizado
oView:SetModel(oModel)

oView:AddField("VIEW_CAB", oStrCAB, "CABMASTER")	// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddGrid("VIEW_GRID", oStrGRI, "GRIDETAIL")		// Cria as grids para o modelo

//Define divis�o da tela para o cabe�alho e itens
oView:CreateHorizontalBox("CABEC", 20)
oView:CreateHorizontalBox("GRID", 80)

// Relaciona o identificador (ID) da View com o "box" para sua exibi��o
oView:SetOwnerView("VIEW_CAB", "CABEC")
oView:SetOwnerView("VIEW_GRID", "GRID")
				
// Identifica��o (Nomea��o) da VIEW
oView:SetDescription(STR0001) // "CheckList"

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} TC805APROD()
@description	Valid do campo TWE_CODPRO
@param			Nenhum
@return			lRet 	L�gico (T/F)
@author 		filipe.goncalves
@since 			23/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function TC805APROD(oModTWE,cCampo,xValor,nLine)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local lRet 		:= .T.

TWE->(dbSetOrder(2))
If TWE->(DbSeek(xFilial("TWE")+xValor))
	lRet := .F.
	Help("",1,'TC805APROD',,STR0003,4,1)	//"Este produto j� foi associado a um cadastro de CheckList x Produto. Escolha outro produto!"
EndIf
FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet 