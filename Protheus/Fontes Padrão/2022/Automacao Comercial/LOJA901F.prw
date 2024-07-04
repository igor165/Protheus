#Include 'Protheus.ch'
#INCLUDE "FWMBROWSE.CH"
#Include "LOJA901F.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA901f
Função para consulta pedido e financeiro CiaShop integracao Protheus e-commerce CiaShop 
@param   sem parâmetros
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs     
@sample LOJA901F()
/*/
//-------------------------------------------------------------------
Function LOJA901F()

Local aArea 		:= GetArea() //Irei gravar a area atual
Local cPedido 		:= ""
Local cPerg			:= "LJ901F"
Local oBrowse
Local bLeg			:= {|| LJ900LEG() }
Local bFin			:= {|| LJ900FIN() }
Local bPed			:= {|| LJ900PED() }
Local cFilBrw		:= ""


// cria arquivo de perguntas
If !Pergunte(cPerg,.T.)
	Return
EndIF

// Monta Filtro Browse

// Cliente até
If !Empty(mv_par03)	
	cFilBrw += "C5_CLIENTE >= '"+mv_par01+"' .And. C5_CLIENTE <= '"+mv_par03+"' "
EndIf

// Loja até
If !Empty(mv_par04)
	If !Empty(cFilBrw)
		cFilBrw += " .And. "
	EndIf	
	cFilBrw += "C5_LOJACLI >= '"+mv_par02+"' .And. C5_LOJACLI <= '"+mv_par04+"' "
EndIf

// Pedido Protheus de / até
If !Empty(mv_par06)	
	If !Empty(cFilBrw)
		cFilBrw += " .And. "
	EndIf	
	cFilBrw += "C5_NUM >= '"+mv_par05+"' .And. C5_NUM <= '"+mv_par06+"' "
EndIf

// Pedido E-commerce de / até
If !Empty(mv_par08)	
	If !Empty(cFilBrw)
		cFilBrw += " .And. "
	EndIf	
	cFilBrw += "C5_PEDECOM >= '"+mv_par07+"' .And. C5_PEDECOM <= '"+mv_par08+"' "
EndIf

// Data de Emissão de / até
If !Empty(mv_par10)	
	If !Empty(cFilBrw)
		cFilBrw += " .And. "
	EndIf	
	cFilBrw += "C5_EMISSAO >= '"+Dtoc(mv_par09)+"' .And. C5_EMISSAO <= '"+Dtoc(mv_par10)+"' "
EndIf

// Posiciona cliente pelo CPF/CNPJ
IF !Empty(mv_par11)
	SA1->(DbSetOrder(3)) // A1_FILIAL+A1_CGC
	If SA1->(DbSeek(xFilial("SA1")+AllTrim(mv_par11)))
		If !Empty(cFilBrw)
			cFilBrw += " .And. "
		EndIf	
		cFilBrw += "C5_CLIENTE == '"+SA1->A1_COD+"' .And. C5_LOJACLI == '"+SA1->A1_LOJA+"' "
	EndIf
EndIf

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Definição da tabela do Browse
oBrowse:SetAlias('SC5')

//define as colunas para o browse
aColunas:={;
{STR0033 ,"C5_NUM" ,"C",TamSx3("C5_NUM")[1],0,"@!"},;					//"Pedido"
{STR0034 ,"C5_PEDECOM" ,"C",TamSx3("C5_PEDECOM")[1],0,"@!"},;			//"EComm."
{STR0035 ,"C5_TIPO" ,"C",TamSx3("C5_TIPO")[1],0,"@!"},;					//"Tipo"
{STR0036 ,"C5_CLIENTE" ,"C",TamSx3("C5_CLIENTE")[1],0,"@!"},;			//"Cliente"
{STR0037 ,"C5_LOJACLI" ,"C",TamSx3("C5_LOJACLI")[1],0,"@!"},;			//"Loja"
{STR0038 ,"C5_EMISSAO" ,"C",TamSx3("C5_EMISSAO")[1],0,"@D"},;			//"Emissão"
{STR0039 ,"C5_STATUS" ,"C",TamSx3("C5_STATUS")[1],0,"@!"},;				//"Status"
{STR0040 ,"C5_RASTR" ,"C",TamSx3("C5_RASTR")[1],0,"@!"}}				//"Rastreio"


//seta as colunas para o browse
oBrowse:SetFields(aColunas)

// Definição da legenda
// 00=Gerado; 05=Em analise; 10=Pagamento confirmado; 15=Embalado; 21=Parcialmente enviado; 30=Enviado; 90=cancelado; 91=Devolvido
oBrowse:AddLegend( "C5_STATUS=='00'", "BROWN", STR0001) 	// "Gerado" 
oBrowse:AddLegend( "C5_STATUS=='10'", "BLUE", STR0002) 		// "Pagamento confirmado" 
oBrowse:AddLegend( "C5_STATUS=='15'", "YELLOW", STR0003) 	// "Embalado" 
oBrowse:AddLegend( "C5_STATUS=='21'", "ORANGE", STR0004) 	// "Parcialmente enviado" 
oBrowse:AddLegend( "C5_STATUS=='30'", "GREEN", STR0005) 	// "Enviado" 
oBrowse:AddLegend( "C5_STATUS=='90'", "RED", STR0006) 		// "Cancelado" 
oBrowse:AddLegend( "C5_STATUS=='91'", "BLACK", STR0007) 	// "Devolvido" 
oBrowse:AddLegend( "C5_STATUS=='  '", "WHITE", STR0008) 	// "Não Informado" 

// Definição de filtro
oBrowse:SetFilterDefault( cFilBrw )

// Titulo da Browse
oBrowse:SetDescription(STR0009) // 'Pedido de venda - CiaShop'

// Execução
oBrowse:bldblclick        := {|| LJ900PED() }        // acao ao duplo clique em uma linha
oBrowse:bheaderclick        := {|| LJ900FIN()}        // acao ao clique no header do brwse

// oBrowse:AddButton("Legenda", "Alert('x')", , 5, 0)
oBrowse:AddButton(STR0043, bLeg )				//"Legenda"
oBrowse:AddButton(STR0044, bFin )				//"Consulta Financeiro"

// Ativação da Classe
oBrowse:Activate()

Return NIL
	
//-------------------------------------------------------------------
/*/{Protheus.doc} LJ900PED
Função para consulta pedido CiaShop integracao Protheus e-commerce CiaShop 
@param   sem parâmetros
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs     
@sample LJ900PED()
/*/
//-------------------------------------------------------------------
Static Function LJ900PED()	
	
	Local cPedido := SC5->C5_NUM
	
	Private Inclui    := .F. //defino que a inclusão é falsa
	Private Altera    := .T. //defino que a alteração é verdadeira
	Private nOpca     := 1   //obrigatoriamente passo a variavel nOpca com o conteudo 1
	Private cCadastro := STR0009 // "Pedido de Vendas" //obrigatoriamente preciso definir com private a variável cCadastro
	Private aRotina := {} //obrigatoriamente preciso definir a variavel aRotina como private
	
	
	DbSelectArea("SC5") //Abro a tabela SC5
	SC5->(dbSetOrder(1)) //Ordeno no índice 1
	If SC5->(dbSeek(xFilial("SC5")+cPedido)) //Localizo o meu pedido
		MatA410(Nil, Nil, Nil, Nil, "A410Visual") //executo a função padrão MatA410
	Endif
	SC5->(DbCloseArea()) //quando eu sair da tela de visualizar pedido, fecho o meu alias
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ900LEG
Função LJ900LEG mostra legenda
@param   sem parâmetros
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs     
@sample LJ900LEG()
/*/
//-------------------------------------------------------------------
Function LJ900LEG()

Local cCadastro := "Legenda"
Local aLegenda := {}

AADD(aLegenda,{"BR_BRANCO", "Não Informado"} )
AADD(aLegenda,{"BR_AZUL", STR0002 } ) // "Pagamento confirmado"
AADD(aLegenda,{"BR_AMARELO", STR0003} ) // "Embalado"
AADD(aLegenda,{"BR_LARANJA", STR0004} ) // "Parcialmente enviado"
AADD(aLegenda,{"BR_VERDE", STR0005} )	// "Enviado"
AADD(aLegenda,{"BR_MARROM", STR0001} ) // "Gerado"
AADD(aLegenda,{"BR_VERMELHO", STR0006} ) // "Cancelado"
AADD(aLegenda,{"BR_PRETO", STR0007} ) // "Devolvido"

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ900FIN
Função LJ900FIN - mostra os títulos a receber 
@param   sem parâmetros
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs     
@sample LJ900FIN()
/*/
//-------------------------------------------------------------------
Function LJ900FIN()

Local cWhere 		:= "" //Condicional da query
Local cAliasTmp  	:= GetNextAlias() //Alias a consulta
Local cPedido := SC5->C5_NUM

//Condicional para a query		
cWhere := "%"
cWhere += " C5_FILIAL = '" + xFilial("SC5") + "'"
cWhere += " AND C5_NUM = '" + cPedido + "'"
cWhere += " AND SC5.D_E_L_E_T_ <> '*'" 
cWhere += " AND L1_FILIAL = '" + xFilial("SL1") + "'" 	
cWhere += " AND L1_ECFLAG = '1'" 	   			
cWhere += " AND SL1.D_E_L_E_T_ <> '*'"
cWhere += "%"              											
			                                          
//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		C5_FILIAL, C5_NUM, C5_PEDECOM, L1_FILIAL, L1_NUM,
		L1_DOCPED, L1_SERPED, C5_CLIENTE, C5_LOJACLI 
	FROM %table:SC5% SC5	
	INNER JOIN %table:SL1% SL1 
	ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC 	 )						
	WHERE %exp:cWhere% 			
EndSql	

//Posiciona no inicio do arquivo
(cAliasTmp)->(dbGoTop())

//Monta consulta 	
If (cAliasTmp)->(!Eof()) .And. !Empty(cPedido)
	// SE1->(DbSetOrder(2))	// E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSetOrder(1))	// E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	// If SE1->(DbSeek(xFilial("SE1")+(cAliasTmp)->(C5_CLIENTE+C5_LOJACLI+L1_SERPED+L1_DOCPED)))
	If SE1->(DbSeek(xFilial("SE1")+(cAliasTmp)->(L1_SERPED+L1_DOCPED)))
		FINC040(2, SE1->E1_PREFIXO,SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)
	Else
		Alert(STR0010) // 'Titulo não encontrado.'
	EndIf
	
EndIF

Return Nil