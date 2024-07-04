#include "MATA852.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA852()

Analise de rentabilidade por Pedidos
  
@param [lPergunta] - Determina se exibe o pergunte "MATA852"
@param [cNumPedido] - numero do pedido 
  
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------    
Function MATA852(lPergunta, cNumPedido) 

Default lPergunta := .T.
Default cNumPedido := ""

INCLUI:= IF(Type("INCLUI") == "U", .F., INCLUI)
ALTERA:= IF(Type("ALTERA") == "U", .F., ALTERA)

If !lPergunta .OR. Pergunte("MATA852", lPergunta)
	//recebe codigo do orçamento/pedido na chamada da funcao
	If !lPergunta
		mv_par01 := cNumPedido
	EndIf
					
	FWExecView( Iif(nModulo==12,STR0010,STR0001) + cNumPedido ,'MATA852',  MODEL_OPERATION_VIEW,,  {|| .T. } , ,  )//'Orçamento/Venda '//###"Pedido"
EndIf	


Return



//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Menu - Analise de rentabilidade por Pedidos
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function MenuDef() 
Return FWLoadMenuDef( "MATA850" ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

ModelDef - Analise de rentabilidade por Pedidos
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------   
Static Function ModelDef() 
Local oModel := FWLoadModel( "MATA850" )   			//herda o model padrao para a consulta
Local oModelGrid := oModel:GetModel("MODEL_GRID")		//pega o model do grid
Local oStructGrid	:= oModelGrid:GetStruct()			//pega a estrutura do grid (para add novos campos)
Local aDados := {}
Local lChamada:= IsInCallStack("MATA851") // Verifica se o fonte MATA851 esta na pilha de chamada

If !( IsBlind() )
	//monta array de dados para fazer a carga de dados e adiciona campos novos na estrutura do model do grid 
	MsgRun(STR0003, STR0002, { || aDados := M852Itens(mv_par01,lChamada) } )//"Aguarde"//"Carregando dados. Aguarde....."
Else
	Pergunte("MATA852", .F. )
	aDados := M852Itens(mv_par01,lChamada)
EndIf

oStructGrid:AddField(STR0004, "" , "ZAB_QTDE", "N", 9, 2 )//"Qtde"
oStructGrid:AddField(STR0005, "" , "ZAB_UNIT", "N", 11, 2 )//"Unitario"

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
oStructGrid:SetProperty("ZAB_ID", MODEL_FIELD_TITULO, STR0006)//"Cód Produto"
oStructGrid:SetProperty("ZAB_DESC", MODEL_FIELD_TITULO, STR0007)//"Produto"


oModelGrid:SetLoad( {|| M850LoadGrid(aDados)} )

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Analise de rentabilidade por Pedidos
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ViewDef() 
  
Local oModel 	:= FWLoadModel( 'MATA852' ) 			//Utiliza o model deste fonte
Local oView := FWLoadView( "MATA850" )				//herda a view padrao para a consulta
Local oStruGrid := oView:GetViewStruct("VIEW_GRID") 	//pega a estrutura do grid (view)
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado     
	
//add os novos campos na estrutura da view do grid
M850ViewStr(oModel, @oStruGrid) 	

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
oStruGrid:SetProperty("ZAB_ID", MVC_VIEW_TITULO, STR0008)//"Cód Produto"
oStruGrid:SetProperty("ZAB_DESC", MVC_VIEW_TITULO, STR0009)//"Produto"


//--------------------------------------------------------------------------
// add botoes com as acoes
// determina que a legenda do grafico sera baseada no campo ZAB_DESC
//--------------------------------------------------------------------------
If lUpdLo118
	oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel , /*bDetail*/ , "ZAB_DESC", /*cTitle*/,;
									    {|| M850ImpRel(oModel,oView:GetViewStruct("VIEW_GRID") , STR0012),STR0009 })} ) //"Analise de rentabilidade por Produtos Orçamentos/Vendas" //"Produtos"
Else
	oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel , /*bDetail*/ , "ZAB_DESC", /*cTitle*/) }) 
EndIf

oView:SetOwnerView( 'VIEW_BOTOES', 'SUPERIOR' )
oView:SetModel(oModel) //associa a view com o model


Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} M852Itens()

Consulta de itens do pedidos

@param cNumPedido, caracter, número do pedido
@param lChamada

@return aItens ( ID, Descricao, Custo, Preco, .....<campos adicionais> )
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------
Function M852Itens(cNumPedido,lChamada) 

Local aArea := GetArea()
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSL2 := SL2->(GetArea())
Local aAreaSC6aux 
Local aItens := {} //array de itens retornado
Local dDtEmis := CTOD("  /  /  ")  // Data de emissao do orçamento/venda
/* aItens
[n] Item do pedido
[n][01] ExpC:Id
[n][02] ExpC:Descricao
[n][03] ExpN:Custo
[n][04] ExpN:Preco
.....   campos adicionais (opicional)
*/	

Local nCustoAux := 0 //armazena o custo total do item
Local nPrecoAux := 0 //armazena o valor presente total do item
Local nQtdeAux := 0 //acumula o total do produto (quando tem mais de um item do pedido com o mesmo produto)
Local cDescAux := "" //armazena a descricao do produto
Local nIndiceItem := 0 //auxiliar para pegar o indice do item no array aRentab
Local aRentab := {}  // Array de rentabilidade do produto
Local nI := 0        // contador
Local aRet:= {}      // Array de retorno da funcao  PegaCMAtu
Local nMoeda := SuperGetMV("MV_LJMDORC",,1) // moeda do sistema 
/*
aRentab
[n]    Item do pedido
[n][1] codigo do produto
[n][2] Valor Total (unit * qtde)
[n][3] C.M.V. (custo)
[n][4] Valor Presente
[n][5] Lucro Bruto (Valor presente - CMV)
[n][6] Margem de Contribuicao (%)
*/
Default lChamada:= .F.

If nModulo <> 12
	//busca custo medio e valor presente de todos os pedidos da venda 
	aRentab := Mat410Rent(cNumPedido)
	DbSelectArea("SC6")
	DbSetOrder(2) //C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM
	For nI := 1 to Len(aRentab) - 1 //nao le a ultima linha do aRentab pq eh o total do pedido
	
		nCustoAux := aRentab[nI][3]
		nPrecoAux := aRentab[nI][4]
		
		If DbSeek(xFilial("SC6") + aRentab[nI][1] + cNumPedido )
			
			//Verifica se existe mais de um item com o mesmo produto e soma as quantidades para agrupar num item soh - pq o aRentab vem com os valores agrupados quando ha mais de um item com o mesmo produto
			nQtdeAux := 0	
			aAreaSC6aux := SC6->(GetArea())
			While SC6->(!EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. (SC6->C6_NUM == cNumPedido) .AND. SC6->C6_PRODUTO == aRentab[nI][1]
				nQtdeAux += SC6->C6_QTDVEN 
				SC6->(DbSkip())
			EndDo
			SC6->(RestArea(aAreaSC6aux))
			
			cDescAux :=  Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")
			AADD(aItens, {SC6->C6_PRODUTO, cDescAux, nCustoAux, nPrecoAux, nQtdeAux , SC6->C6_PRCVEN})  
			
		EndIf
	
	Next nI
Else 
	//Procura orçamentos/vendas
	DbSelectArea("SL1")
	DbSetOrder(1) //L1_FILIAL+DTOS(L1_EMISSAO)+		
	//Pesquisa pela data de emissao do orçamento/venda - pega todos os orçamentos/vendas entre 2 datas - SoftSeek = .T.	 
	If DbSeek(xFilial("SL1") + cNumPedido, .T.)
		
		dDtEmis:= Iif(Empty(SL1->L1_EMISNF),SL1->L1_EMISSAO,SL1->L1_EMISNF)
		DbSelectArea("SL2")
		DbSetOrder(1) //L2_FILIAL+L2_NUM
		DbSeek(xFilial("SL2") + cNumPedido, .T. )
		While SL2->(!EOF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2")+cNumPedido
			nCustoAux:= 0
			nPrecoAux:= 0

	        aRet:= PegaCMAtu(SL2->L2_PRODUTO,SL2->L2_LOCAL)   
	        nCustoAux += SL2->L2_QUANT*aRet[nMoeda]
	        nPrecoAux += MaValPres(SL2->L2_VLRITEM,dDtEmis,,,dDtEmis)
			AADD(aItens, {SL2->L2_PRODUTO, SL2->L2_DESCRI, nCustoAux, nPrecoAux, SL2->L2_QUANT , SL2->L2_VLRITEM})  
		    SL2->(DbSkip())
		EndDo 
	EndIf		    
EndIf
	
SC6->(RestArea(aAreaSC6))
RestArea(aArea)

Return aItens