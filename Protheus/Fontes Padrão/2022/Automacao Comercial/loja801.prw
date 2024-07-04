#INCLUDE "PROTHEUS.CH"                                              
#INCLUDE "APWIZARD.CH" 
#INCLUDE "LOJA801.CH"

Static oCodPro 					   												// Codigo do Produto
Static cCodPro 			:= CriaVar("B1_COD",.F.)								// Codigo do Produto 
Static cNomePro			:= CriaVar("B1_DESC",.F.)								// Nome do Produto
Static oNomePro		   															// Nome do Produto 
Static cAliasTRB		:="TRB"                                              
Static cMarca  			:= GetMark()  
Static nQtdeVend        :=0 
Static oChkData         														//permite altera็ใo de data
Static lChkData	    														    // permite alteracao da data
Static oAtencao
Static cAtencao 
Static aProdCad 											 					//Array contendo os produtos jแ cadastrados
Static oDlg             														// Tela dos produtos jแ cadastrados
Static oMark                                                                   
Static oWizard
Static oDBTree

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	 ณLOJA801   ณ Autor ณ Vendas Cliente        ณ Data ณ 08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Rotina que efetua atraves do wizard a sugestao de vendas    ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ SIGALOJA - VENDA ASSISTIDA                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LOJA801()  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis locaisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nTpProc		:= 1      													// Opcao selecionada. 1-Produto especifico 2-Quantidade vendida
Local aGrid 		:= {}       												// Campos da tabela SL2 que serao exibidos na MsSelect                                                  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao dos Objetos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cSugestao 	:=CriaVar("ACU_DESC",.F.)   								// Nome da Sugestao da Venda
Local dDataIni		:= dDataBase										        // Data Inicial para filtrar as vendas efetuadas         
Local dDataFim		:= dDataBase										        // Data Final para filtrar as vendas efetuadas  
Local oDataIniP		:= NIL															// Data Inicial para filtro do produto especํfico
Local oDataFimP     := NIL   											           	// Data Final para filtro do produto especํfico
Local aStruTRB 		:={}                                                        // array de estrutura dos arquivos temporarios
Local aNomeTMP		:= {}                                                      //  Array tamporario
Local lQtdeVen		:=.F.														//verifica se o grid esta em quantuidade vendida   
Local nTpSubCat		:= 0	  						                                //Verifica se havera sub categoria       

If !LJ801aVlUs()
	Return(Nil)  
EndIf         

Lj801aGetS(@aGrid,@aStruTRB,@aNomeTMP)   

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem dos paineis do WIZARD , cada funcao representa um painel |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P1() 
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do segundo painel  |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P2(@nTpProc,@oDataIniP,@oDataFimP)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Terceiro painel |                   
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P3(@nTpProc ,@lQtdeVen,@dDataIni,@dDataFim,@oDataIniP,@oDataFimP)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Quarto painel   |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P4(@nTpProc,@lQtdeVen)   
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Quinto painel   |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P5(@nTpProc,@oDataIniP,@oDataFimP,@lQtdeVen,@aGrid)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Sexto painel    |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P6(@nTpSubCat)   
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Setimo painel   |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P7(@nTpSubCat,@cSugestao)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Oitavo painel   |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P8(@nTpProc,@aGrid,@cCodPro)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Nono painel     |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P9(@nTpProc) 
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Montagem do Decimo painel   |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Lja801P10()
                        
Return(Nil)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P1	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Definicao e primeiro painel do Wizard                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P1()
	//ฺฤฤฤฤฤฤฤฟ
	//ณPanel 1ณ
	//ภฤฤฤฤฤฤฤู           
	
	DEFINE WIZARD oWizard TITLE OemToAnsi(STR0001) HEADER OemToAnsi(STR0002) MESSAGE " " ;      //Assistente de sugestใo de Venda
	TEXT OemToAnsi(STR0003)+OemToAnsi(STR0004) PANEL NEXT {|| .T.} FINISH {|| .F.}	//Processo de sugestใo de Vendas do Sistema loja
	/*Este assistente ira ajuda-lo a relacionar produtos que normalmente sใo vendidos em conjunto (Sugestใo de Vendas)."
	 Clique em avancar para iniciar o assistente"*/

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P2	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Segundo Painel do Wizard, nesse painel o usuario seleciona ณฑฑ
ฑฑณ          ณo tipo de  consulta que ira fazer, se eh por 1-produto      ณฑฑ
ฑฑณ          ณespecifico ou por 2-quantidade vendida, indicados pela      ณฑฑ
ฑฑณ          ณvariavel nTpProc                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpProc: Tipo escolhido                                    ณฑฑ
ฑฑณ				       [1] Produto especifico                             ณฑฑ
ฑฑณ          ณ         [2] quantidade vendida                             ณฑฑ
ฑฑณ          ณ oDataIniP: Objeto Data inicial                             ณฑฑ
ฑฑณ          ณ oDataFimP: Objeto Data Final                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P2(nTpProc,oDataIniP,oDataFimP)
//Os objetos de data inicial e data final foram incluidos nessa funcao pois eles serao habilitados ou desabilitados
// de acordo com a opcao selecionada
Local   oTpProc			:= NIL						//objeto tipo do processo 1 prod especifico 2 quantidade vendida
Default oWizard 		:= NIL                     // objeto Wizard
Default nTpProc 		:= 0                       // variavel de tipo de processo
Default oDataIniP 		:= Nil                    //  objeto de pesquisa para data inicial
Default oDataFimP 		:= Nil                    //  objeto de pesquisa para data final

	/*Selecao do processo"
	 Deseja relacionar os produtos por qual crit้rio? */ 
	CREATE PANEL oWizard  HEADER STR0005  MESSAGE OemToAnsi(STR0006) ;
	BACK {|| .T. } ;
	NEXT {||  Lj801aNe2(@nTpProc,1,@oCodPro,@oDataIniP,@oDataFimP)} ;	
	FINISH {||  .F. } PANEL 
	@ 001,01 TO 139,300 
	@ 01,01  TO 139,300 LABEL STR0004		OF oWizard:GetPanel(2) PIXEL //Clique em avancar para iniciar o assistente
	@ 20,20 RADIO oTpProc  		VAR nTpProc ITEMS STR0008,STR0007  	SIZE 70,10 PIXEL OF oWizard:GetPanel(2) ;       
	   
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P3	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Terceiro Painel do Wizard, nesse painel o usuario selecionaณฑฑ
ฑฑณ          ณo produto que deseja consultar, a data inicial e final e    ณฑฑ
ฑฑณ          ณporcentagem inicial e final, sendo que eh necessario informarฑฑ
ฑฑณ          ณo produto e data inicial e final, com isso sera executada a ณฑฑ
ฑฑณ          ณfuncao Lj801aNe3  que efetuara filtro e exibira os produtos ณฑฑ
ฑฑณ          ณno grid do painel 5 - cinco                                 ณฑฑ
ฑฑณ          ณa variavel lQtdeVen representa que sera por produto especif.ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpProc: Tipo escolhido                                    ณฑฑ
ฑฑณ				       [1] Produto especifico                             ณฑฑ
ฑฑณ          ณ         [2] quantidade vendida                             ณฑฑ
ฑฑณ          ณ oDataIniP: Objeto Data inicial                             ณฑฑ
ฑฑณ          ณ oDataFimP: Objeto Data Final                               ณฑฑ
ฑฑณ          ณ dDataIniP:        Data inicial                             ณฑฑ
ฑฑณ          ณ dDataFimP:        Data Final                               ณฑฑ
ฑฑณ          ณ lQtdeVen: qtde vendida = .F. , Prod. Especifico :T         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P3(nTpProc,	lQtdeVen,	dDataIni,	dDataFim,;
                            oDataIniP,	oDataFimP)        
                            
Local nPerceIni	   		:= 0												//Percentual inicial
Local oPerceIni         := NIL												//Objeto Percentual inicial
Local nPerceFim			:= 0												//Percentual Final
Local oPerceFim         := NIL												//Objeto Percentual Final
Default oWizard 		:= Nil
Default nTpProc 		:=0
Default lQtdeVen 		:=.F.
Default dDataIni 		:=dDataBase
Default dDataFim 		:=dDataBase
Default oDataIniP 		:=Nil   
Default oDataFimP 		:=Nil    
Default cCodPro     	:=""  

	/*Selecao do processo
	Nesse painel iremos informar o produto que serแ pesquisado, intervalo de Data e/ou porcentagem, lembrando que a porcentagem diz 
	respeito a quantidade vendida	*/
	CREATE PANEL oWizard HEADER OemToAnsi(STR0005) MESSAGE OemToAnsi(STR0041+CHR(10)+CHR(13)+(STR0039));
	 PANEL BACK {|| Lj801aNe3(@nTpProc  ,2, @cCodPro, dDataINI,dDataFIM,nPerceIni,nPerceFim )};
	 NEXT   {|| Lj801aNe3(@nTpProc  ,1, @cCodPro, dDataINI,dDataFIM,nPerceIni,nPerceFim ,@lQtdeVen)};
                FINISH {|| .F.} PANEL

	oWizard:GetPanel(3)

	@ 01,01 TO 139,300 LABEL 	OF oWizard:GetPanel(3) PIXEL
	@ 10,8 TO 40,292 LABEL STR0010	OF oWizard:GetPanel(3) PIXEL //"Informa็๕es sobre o Produto
	@ 22,16  SAY  STR0011     		   	OF oWizard:GetPanel(3) PIXEL SIZE 50,9 //"Produto:"
	@ 20,50  MSGET 	oCodPro  	VAR cCodPro  	SIZE 40,10 	Picture "@!" F3 "SB1" 	OF  oWizard:GetPanel(3) ;
	         VALID (If(!EMPTY(cCodPro), cNomePro:=Lj801aDescP(cCodPro),oNomePro:Refresh())) ;
	         PIXEL
	@ 20,110 SAY 	oNomePro 	Var cNomePro 	OF oWizard:GetPanel(3) COLOR CLR_RED PIXEL SIZE 210,9
	@ 40,8   TO 100,148 LABEL STR0015	OF oWizard:GetPanel(3) PIXEL //"Intervalo de Datas :       
	@ 40,152   TO 100,292 LABEL STR0009	OF oWizard:GetPanel(3) PIXEL //"Porcentagem : 
	@ 53,30  SAY  STR0012 		OF oWizard:GetPanel(3) 	SIZE 50,9 PIXEL //"Data Inicial
	@ 50,65  MSGET oDataIniP 	VAR dDataIni   			SIZE 50,10 	OF  oWizard:GetPanel(3) VALID( If(nTpProc == 1,!EMPTY(dDataIni),.T.) , IIf(!Empty(dDataFim),dDataFim >= dDataIni,.T.)) PIXEL 
	@ 73,30 SAY  STR0013 		OF oWizard:GetPanel(3) 	SIZE 50,9 PIXEL //"Data Final
	@ 70,65 MSGET	oDataFimP  	VAR dDataFim   			SIZE 50,10 	OF  oWizard:GetPanel(3) VALID( If(nTpProc == 1,!EMPTY(dDataFim),.T.) ,  dDataFim >= dDataIni) PIXEL
	@ 53,155  SAY  STR0036  		OF oWizard:GetPanel(3) 	SIZE 50,15 PIXEL //Porcentagem inicial
	@ 52,210  MSGET	oPerceIni  	VAR nPerceIni   			SIZE 40,10 Picture "@E 99.99"	OF  oWizard:GetPanel(3) VALID( If(nTpProc == 1,!EMPTY(nPerceIni),.T.)) PIXEL
	@ 73,155  SAY  STR0037  		OF oWizard:GetPanel(3) 	SIZE 50,15 PIXEL //Porcentagem final
	@ 72,210  MSGET	oPerceFim  	VAR nPerceFim   			SIZE 40,10 Picture "@R 999.99" OF  oWizard:GetPanel(3) VALID( LjVldPorc(nTpProc,nPerceFim) ) PIXEL

	lChkData := .F.
	oChkData := TCheckBox():New(88,100,"Alterar Data",,oWizard:GetPanel(3), 150,400,,,,,,,,.T.,,,)
	oChkData:Disable()
	oChkData:Refresh()	
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P4	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Quarto Painel do Wizard, nesse painel o usuario seleciona  ณฑฑ
ฑฑณ          ณa data inicial e data final alem da quantidade vendida iniciณฑฑ
ฑฑณ          ณal com o intuido de buscar na base de dados todos os produtosฑฑ
ฑฑณ          ณque satisfizerem as condicoes da consulta, sera executada a ณฑฑ
ฑฑณ          ณfuncao Lj801aNe4 que efetuara filtro e exibira os produtos  ณฑฑ
ฑฑณ          ณno grid do painel 5 - cinco                                 ณฑฑ
ฑฑณ          ณa variavel lQtdeVen representa que sera por qtade vendida   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpProc: Tipo escolhido                                    ณฑฑ
ฑฑณ				       [1] Produto especifico                             ณฑฑ
ฑฑณ          ณ         [2] quantidade vendida                             ณฑฑ
ฑฑณ          ณ lQtdeVen: qtde vendida = .F. , Prod. Especifico :T         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P4(nTpProc,lQtdeVen)

Local cQuantIni			:=CriaVar("B1_COD",.F.)                             //Quantidade Inicial
Local oQuantIni			:= NIL													//Quantidade Inicial
Local cQuantFim			:=CriaVar("B1_COD",.F.)    							//Quantidade Final
Local oQuantFim 		:= NIL													//Quantidade Final    
Local oDataIni			:= NIL											    	// Data Inicial para filtro da quantidade vendida
Local oDataFim        	:= NIL										           	// Data Final para filtro das Notas Fiscais de Saida
Local dDataIni			:= dDataBase									    // Data Inicial para filtrar as vendas efetuadas         
Local dDataFim			:= dDataBase									    // Data Final para filtrar as vendas efetuadas  
Default oWizard 		:= Nil
Default nTpProc 		:=0
Default lQtdeVen 		:=.F.

	CREATE PANEL oWizard HEADER OemToAnsi(STR0005) MESSAGE "";   //Sele็ใo do processo
	PANEL BACK {||  Lj801aNe4( nTpProc,2 ,dDataINI,dDataFIM  ,cQuantIni, cQuantFim,@lQtdeVen)};
	NEXT {||  Lj801aNe4( nTpProc,1 ,dDataINI,dDataFIM  ,cQuantIni, cQuantFim,@lQtdeVen)} ;	
    FINISH {|| .F.} 
   	@ 40,8   TO 100,148 LABEL STR0015 	OF oWizard:GetPanel(4) PIXEL //"Data       
	@ 40,152   TO 100,292 LABEL STR0047	OF oWizard:GetPanel(4) PIXEL //Quantidade Vendida
	
	@ 53,30  SAY  STR0012 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL //"Data Inicial
	@ 50,64  MSGET oDataIni 	VAR dDataIni   			SIZE 50,10 	OF  oWizard:GetPanel(4) VALID( If(nTpProc == 1,!EMPTY(dDataIni),.T.) , IIf(!Empty(dDataFim),dDataFim >= dDataIni,.T.)) PIXEL 
	@ 73,30 SAY  STR0013 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL //"Data Final 
	@ 70,64 MSGET	oDataFim  	VAR dDataFim   			SIZE 50,10 	OF  oWizard:GetPanel(4) VALID( If(nTpProc == 1,!EMPTY(dDataFim),.T.) ,  dDataFim >= dDataIni) PIXEL 	 
 	@ 53,180  SAY  STR0022 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL // Quantidade vendida de 
	@ 50,210  MSGET oQuantIni 	VAR cQuantIni   			SIZE 40,10 Picture "@E 999999999"	OF  oWizard:GetPanel(4)  PIXEL 				
	@ 73,180  SAY  STR0023 		OF oWizard:GetPanel(4) 	SIZE 50,9 PIXEL //ate
	@ 70,210  MSGET	oQuantFim 	VAR cQuantFim   			SIZE 40,10 Picture "@E 999999999"	OF  oWizard:GetPanel(4)  PIXEL 		

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P5	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Quinto Painel do Wizard, nesse painel sera exibido o grid  ณฑฑ
ฑฑณ          ณcom as informacoes passadas pelo painel 3 ( prod especifico)ณฑฑ
ฑฑณ          ณou 4 ( quantidade vendida ) caso seja painel 3 sera efetuada|ฑฑ
ฑฑณ          ณvalidacao de escolha de pelo menos um item do grid, se for  ณฑฑ
ฑฑณ          ณpelo painel 4, sera possivel apenas a escolha de UM produto ณฑฑ
ฑฑณ          ณpois sera retornado ao painel 3 com o produto selecionado no|ฑฑ
ฑฑณ          ณgrid para uma nova busca na base com o produto sel no grid  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpProc: Tipo escolhido                                    ณฑฑ
ฑฑณ				       [1] Produto especifico                             ณฑฑ
ฑฑณ          ณ         [2] quantidade vendida                             ณฑฑ
ฑฑณ          ณ oDataIniP: Objeto Data inicial                             ณฑฑ
ฑฑณ          ณ oDataFimP: Objeto Data Final                               ณฑฑ
ฑฑณ          ณ lQtdeVen: qtde vendida = .F. , Prod. Especifico :T         ณฑฑ
ฑฑณ          ณ aGrid   : Grid dos produtos encontrados                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P5(nTpProc,oDataIniP,oDataFimP,lQtdeVen,;
				  aGrid)
Default oWizard 	:= Nil
Default nTpProc 	:= 0
Default lQtdeVen 	:= .F.
Default oDataIniP 	:= Nil   
Default oDataFimP 	:= Nil
Default aGrid 		:= {}

// caso seja quantidade vendida, apos selecionar apenas um produto a rotina voltara para o
// painel 3 , com o codigo do produto e as datas desabilitadas 

		//Neste painel sใo exibidos os produtos que foram vendidos no perํodo selecionado, juntamente com o produto escolhido anteriormente."
	CREATE PANEL oWizard  HEADER STR0001  MESSAGE OemToAnsi(STR0014+CHR(10)+CHR(13)+(STR0038)) ; 
	BACK {|| Lj801aNe5(nTpProc   ,2) }; 
	NEXT {|| Lj801aNe5(@nTpProc   ,1,@cCodPro,@oCodPro,@cNomePro,@oNomePro,@oDataIniP,@oDataFimP,lQtdeVen)} ;							
	FINISH {|| .F.} PANEL 

	oWizard:GetPanel(5)

	@ 03,02 SAY ""  OF oWizard:GetPanel(5) SIZE 120,8 PIXEL 
  	@ 10,10 SAY STR0018	OF oWizard:GetPanel(5) PIXEL SIZE 801,801  //Selecione o produto para relacionar na sugestใo de vendas
	@ 125,30  SAY 	oAtencao 	Var cAtencao 	OF oWizard:GetPanel(5) 	SIZE 200,9 PIXEL //"Data Inicial        
	
    
    oMark := MsSelect():New(cAliasTRB,"L2_OK",,aGrid,.F.,@cMarca,{05,02,115,300},"SD2->(DbGotop())","SD2->(DbGoBottom())",oWizard:GetPanel(5))
	oMark:oBrowse:lhasMark    := .T.
	oMark:oBrowse:lCanAllmark := .F.
    
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P6	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Sexto Painel do Wizard, nesse painel o usuario ira decidir ณฑฑ
ฑฑณ          ณse o produto selecionado inicialmente vai ser ou nao "pai"  ณฑฑ
ฑฑณ          ณdo(s) produto(s) escolhidos posteriormente                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpSubCat: Se o produto sera pai ou nao                    ณฑฑ
ฑฑณ				       [1] Sim                                            ณฑฑ
ฑฑณ          ณ         [2] nao                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P6(nTpSubCat)
Local oTpSubCat		:= NIL							//Verifica se havera sub categoria
Default oWizard 	:= NIL                          //Objeto do wizard

Default nTpSubCat 	:=0
		/*Selecao do processo"
	 Definir o produto selecionado como produto 'Pai'?"*/ 
	CREATE PANEL oWizard  HEADER STR0055 MESSAGE OemtoAnsi (STR0056+CHR(10)+CHR(13)+(STR0040)) ;
	BACK {|| .T. } ;
	NEXT {|| .T.} ;	
	FINISH {||  .F. } PANEL          
	@ 001,01 TO 139,300 LABEL STR0050 OF oWizard:GetPanel(6) PIXEL 
	@ 01,01  TO 139,300 LABEL	      OF oWizard:GetPanel(6) PIXEL 
	@ 20,20 RADIO oTpSubCat  		VAR nTpSubCat ITEMS STR0026,STR0027  	SIZE 70,10 PIXEL OF oWizard:GetPanel(6) ;    

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P7	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Setimo Painel do Wizard, nesse painel o usuario ira digitarณฑฑ
ฑฑณ          ณo nome da categoria que sera cadastrada apos selecao dos prodฑฑ
ฑฑณ          ณdutos, o parametro nTpSubCat determina se o produto sera paiณฑฑ
ฑฑณ          ณou nao dos produtos selecionados no grid                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpSubCat: Se o produto sera pai ou nao                    ณฑฑ
ฑฑณ				       [1] Sim                                            ณฑฑ
ฑฑณ          ณ         [2] nao                                            ณฑฑ
ฑฑณ          ณ cSugestao: Nome da sugestao que sera cadastrada            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P7(nTpSubCat,cSugestao)
Local oSugestao		:= NIL														//Nome da Sugestao da Venda    
Default oWizard 	:= Nil
Default nTpSubCat 	:=0
Default cSugestao 	:=""

		//Finaliza็ใo de Processo"
        //Informe o nome da Sugestใo de vendas que acabou de criar.
	CREATE PANEL oWizard  HEADER STR0057  MESSAGE OemToAnsi(STR0032) ; 
	BACK {||  , .T. }; 
	NEXT {|| Lj801aNe7( 1,cSugestao,nTpSubCat)} ;							
	FINISH {|| .F.} PANEL
	
	@ 001,01 TO 139,300 LABEL 		OF oWizard:GetPanel(7) PIXEL 
   	@ 30,16  SAY  STR0058     		    	OF oWizard:GetPanel(7) PIXEL SIZE 200,80 //"Nome da Sugestใo:
	@ 40,16  MSGET	oSugestao  	VAR cSugestao   SIZE 80,10 	Picture "@!" 	OF  oWizard:GetPanel(7)  PIXEL 				

	oWizard:GetPanel(7) 
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P8	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Oitavo Painel do Wizard, esse painel eh parecido com o     ณฑฑ
ฑฑณ          ณpainel 5, ele eh acionado quando o usuario seleciona um     |ฑฑ
ฑฑณ          ณproduto que ja tem sugestao cadastrada, que alem de ter o   ณฑฑ
ฑฑณ          ณgrid como o painel 5 tem o botao detalhes que exibe todos osณฑฑ
ฑฑณ          ณprodutos que estao associados a essa sugestao, com isso depoisฑ
ฑฑณ          ณde selecionar um produto, sera verificado se na sugestao cadasฑ
ฑฑณ          ณtrada existe um produto pai, caso nao exista, sera acrescentaฑฑ
ฑฑณ          ณdo o novo produto, caso tenha, sera envidado ao proximo painelฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpProc: Tipo escolhido                                    ณฑฑ
ฑฑณ			 |	       [1] Produto especifico                             ณฑฑ
ฑฑณ          ณ         [2] quantidade vendida                             ณฑฑ
ฑฑณ          | oDBTree: Objeto de Exibicao em forma hierarquica "arvore"  ณฑฑ
ฑฑณ          ณ aGrid   : Grid dos produtos encontrados                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P8(nTpProc,aGrid,cCodPro)
Local oButton  := NIL                               // Objeto para Botao
Local cCateg := AllTrim(LJ801aRetC(cCodPro))// Retorna a categoria do respectivo produto 
Default oWizard 	:= Nil
Default nTpProc 	:=0
Default aGrid 		:={}
  
	//Neste painel sใo exibidos os produtos que foram vendidos no perํodo selecionado, juntamente com o produto escolhido no painel anterior"
	CREATE PANEL oWizard  HEADER STR0001  MESSAGE OemToAnsi(STR0014+CHR(10)+CHR(13)+(STR0038)) ; 
	BACK {|| Lj801aNe3(@nTpProc  ,2,@cCodPro)};
	NEXT {|| Lj801aNe8(@nTpProc  ,1,@cCodPro)} ;
	FINISH {|| .F.} PANEL 

	oWizard:GetPanel(8)
	@ 03,02 SAY ""  OF oWizard:GetPanel(8) SIZE 120,8 PIXEL 
  	@ 10,10 SAY ""	OF oWizard:GetPanel(8) PIXEL SIZE 801,801  // Selecione o produto para relacionar na sugestใo de vendas
	@ 125,30  SAY 	oAtencao 	Var cAtencao 	OF oWizard:GetPanel(8) 	SIZE 200,9 PIXEL //"Data Inicial

	aAdd(aGrid,{"L2_PORCENT"	,,STR0009," "})							 	//Porcentagem
	oMark := MsSelect():New(cAliasTRB,"L2_OK",,aGrid,.F.,@cMarca,{05,02,115,300},"SD2->(DbGotop())","SD2->(DbGoBottom())",oWizard:GetPanel(8))
	oMark:oBrowse:lhasMark    := .T.
	oMark:oBrowse:lCanAllmark := .F.

		oButton:=tButton():New(120,260,STR0045,oWizard:GetPanel(8),{||oWizard:GetPanel(8):End()},30,12,,,,.T.)  //Detalhes
		oButton:bAction := {|| Ljc801ExGr()}       
     
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P9	ณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Nono  Painel do Wizard, esse painel exibe um DbTree com a  ณฑฑ
ฑฑณ          ณestrutura da sugestao ja existente, perguntando ao usuario  |ฑฑ
ฑฑณ          ณem que hierarquia deseja inserir o produto selecionado, se  ณฑฑ
ฑฑณ          ณeh na mesma estrutura do produto pai ou na sub sugestao dos ณฑฑ
ฑฑณ          ณprodutos filhos, a resposta sera obtida pelo retorno da     ณฑฑ
ฑฑณ          ณfuncao GetCargo() do DbTree. No DbTree serao exibidas tanto asฑ
ฑฑณ          ณsugestoes como o produtos que fazem parte delas             |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑณ          ณ nTpProc: Tipo escolhido                                    ณฑฑ
ฑฑณ			 |	       [1] Produto especifico                             ณฑฑ
ฑฑณ          ณ         [2] quantidade vendida                             ณฑฑ
ฑฑณ          | oDBTree: Objeto de Exibicao em forma hierarquica "arvore"  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P9(nTpProc) 
Default oWizard 	:= Nil
Default nTpProc 	:=0

	//Neste painel sใo exibidos os produtos que foram vendidos no perํodo selecionado, juntamente com o produto escolhido no painel anterior"
	CREATE PANEL oWizard  HEADER STR0001  MESSAGE OemToAnsi(STR0053) ; //Selecione em qual categoria o produto selecionado no grid deve ser inserido
	BACK {|| Lj801aNe8(nTpProc  ,2,@cCodPro)};
	NEXT {|| Lj801aNe9(nTpProc ,3,,oDBTree:GetCargo())} ;										
	FINISH {|| .F.} PANEL 
	oWizard:GetPanel(9)
	@ 03,02 SAY ""  OF oWizard:GetPanel(9) SIZE 120,8 PIXEL 
  	@ 10,10 SAY ""	OF oWizard:GetPanel(9) PIXEL SIZE 801,801  
	@ 125,30  SAY 	oAtencao 	Var cAtencao 	OF oWizard:GetPanel(9) 	SIZE 200,9 PIXEL   

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801P10 |Autor  ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Decimo Painel do Wizard, indica a finalizacao do wizard    ณฑฑ
ฑฑณ          ณestrutura da sugestao ja existente, perguntando ao usuario  |ฑฑ
ฑฑณ          ณem que hierarquia deseja inserir o produto selecionado, se  ณฑฑ
ฑฑณ          ณeh na mesma estrutura do produto pai ou na sub sugestao dos ณฑฑ
ฑฑณ          ณprodutos filhos, a resposta sera obtida pelo retorno da     ณฑฑ
ฑฑณ          ณfuncao GetCargo() do DbTree. No DbTree serao exibidas tanto asฑ
ฑฑณ          ณsugestoes como o produtos que fazem parte delas             |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ oWizard: Objeto do Wizard                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lja801P10()
Default oWizard 	:= Nil 

	CREATE PANEL oWizard HEADER STR0025 MESSAGE OemToAnsi(STR0059) ; 
	BACK {|| .F. } ; 
	NEXT {||  .F. } ;	 
	FINISH {|| .T.} PANEL
     	@ 45,16  SAY  STR0024 		OF oWizard:GetPanel(10) 	SIZE 150,60 PIXEL //"	Os produtos foram gravados com sucesso
	ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.} VALID {||.T.}

Return
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801ExCaณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Exibte a categoria selecionada ao clicar no dbtree         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ cCargo: String retornada ao clicar no dbtree               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/         
Function Lja801ExCa(cCargo)  
Local cArea := "LJVC" 	//Alias temporario                
                        
cQuery:= "SELECT  ACU_DESC, ACU_CODPAI, ACU_COD FROM " +   RetSQLName("ACU") + " WHERE  D_E_L_E_T_ = ' '  AND ACU_COD IN( "
cQuery+= "SELECT ACV_CATEGO FROM "+   RetSQLName("ACV") + " WHERE ACV_CATEGO = '" + cCargo + "' AND D_E_L_E_T_ = ' ' )"
LJa801ExQu(cArea,@cQuery)
cCondPai := AllTrim((cArea)->ACU_DESC)     
cCodProP := Alltrim((cArea)->ACU_COD)
cDescP   := Alltrim((cArea)->ACU_DESC)

If cCondPai <> '' 
	cAtencao := STR0051 + cCodProp + " - " + cDescP //"A categoria seleccionada e : "
Else
	cAtencao:=""
EndIf
oAtencao:Refresh()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Ljc801ExGrณ Autor ณ Vendas Cliente        ณ Data ณ08.11.10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Exbibe grid de produtos que ja foram relacionados ao produtoฑฑ
ฑฑณ          ณ selecionado no painel 3                                     ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณParametrosณ cProduto: Produto necessario para desc sugestao de Vendas  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Ljc801ExGr(cProduto) 
Local oOK 	:= LoadBitmap(GetResources(),'br_verde')  //Botao verde somente para exibicao

DEFINE MSDIALOG oDlg FROM 0,0 TO 310,402 PIXEL TITLE STR0046      //Produtos Relacionados 

oBrowse := TWBrowse():New( 5 , 5, 195,  130,,;
		{'',STR0028,STR0029},{20,40,40}, oDlg, ,,,,;
		{||},,,,,,,.F.,,.T.,,.F.,,, )
  
oBrowse:SetArray(aProdCad)    
oBrowse:bLine := {||{;
If(aProdCad[oBrowse:nAt,01],oOK,oOK),;
	aProdCad[oBrowse:nAt,02],;
	aProdCad[oBrowse:nAt,03]} }

ACTIVATE MSDIALOG oDlg CENTERED
oDlg:=Nil
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |Lja801Descณ Autor ณ Vendas Cliente        ณ Data ณ27/10/10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Retorna a descricao da categoria em que o produto passado  ณฑฑ
ฑฑณ          ณ como parametro eh pai                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cProd: Produto selecionado                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJa801Desc(cProd)
Local cCateg	:=""		//variavel de retorno     
Local cQuery	:=""       // Variavel de consulta
Local cArea 	:="LJVC" 	//Alias temporario

cQuery:= "SELECT  ACU_DESC FROM " +   RetSQLName("ACU") + " WHERE  D_E_L_E_T_ = ' '  AND ACU_COD IN( "
cQuery+= "SELECT ACV_CATEGO FROM "+   RetSQLName("ACV") + " WHERE ACV_CODPRO = '" + cProd + "' AND D_E_L_E_T_ = ' ')"
LJa801ExQu(cArea,@cQuery)
cCateg := AllTrim((cArea)->ACU_DESC)
(cArea)->(DbCloseArea())

Return cCateg
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |LJa801ExQuณ Autor ณ Vendas Cliente        ณ Data ณ27/110/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao que executa querys                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cArea   : Arquivo temporario                               ณฑฑ
ฑฑณ          ณ cQuery  : Query que vai ser executada                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJa801ExQu(cArea,cQuery) 
Default cArea 	:="LJVC"
Default cQuery	:=""
If Select(cArea) > 0
	(cArea)->(DbCloseArea())
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cArea,.F.,.T.)

Return                                                                                 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |LJa801HDatณ Autor ณ Vendas Cliente        ณ Data ณ27/10/10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Habilita ou desabilita as datas na sugestใo de vendas      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ oDataini: Data inicial                                     ณฑฑ
ฑฑณ          ณ oDataFim: Data final                                       ณฑฑ
ฑฑณ          ณ lHabilita: Verifica se irแ habilitar ou desabilitar as datasฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJa801HDat(oDataini,oDataFim,lHabilita)
Default oDataini 	:=Nil	
Default oDataFim 	:=Nil   
Default  lHabilita 	:=.F. 
If lHabilita                            
	oDataini:Enable()
	oDataFim:Enable()
Else
	oDataini:Disable()
	oDataFim:Disable()
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |LJa801GRAVณ Autor ณ Vendas Cliente        ณ Data ณ22/10/10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de Gravacao da sugestao de vendas                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ lRet, .T. para gravado com sucesso                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cCodPro: Codigo do Produto                                 ณฑฑ
ฑฑณ          ณ cSugestao : Nome da sugestao de Vendas que serแ cadastrada ณฑฑ
ฑฑณ          ณ nTipo  : Deseja considerar o produto selecionado no painel ณฑฑ
ฑฑณ          ณ 3 como produto pai ?                                       ณฑฑ
ฑฑณ			 |	       [1] Sim                                            ณฑฑ
ฑฑณ          ณ         [2] Nao                                            ณฑฑ 
ฑฑณ          ณ cCategoria : Caso seja inclusao de um produto a uma sugestaoฑฑ
ฑฑณ          ณ existente, caso o array aProdCad tiver informacao indica queฑฑ
ฑฑณ          ณ sera inclusao de um prod. em uma categoria existente, caso |ฑฑ
ฑฑณ          ณ contrario ser de um prod. em uma categoria existente, caso |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJa801GRAV(cCodPro,cSugestao,nTipo,cCategoria)
Local lRet 			:= .T.       				//Variavel de Retorno
Local cCateg        := ""                           	//Categoria
Local cAlias 	    := cAliasTrb               // Alias temporario
Local lIntPOS 		:= (SuperGetMV("MV_LJSYNT",,"0") == "1")
Local lACV_POSFLG	:= ACV->(FieldPos("ACV_POSFLG")) > 0
Local lACU_POSFLG	:= ACU->(FieldPos("ACU_POSFLG")) > 0
Default	cCodPro 	:=""
Default cSugestao 	:=""
Default nTipo		:=0
Default cCategoria	:=""

//Caso nใo tenha informacoes no aProdCad sera inclusao caso contrario sera alteracao
If Len(aProdCad)==0       // Somente quando for inclusao de item que nao tem ja sugestao cadastrada esse array estara zerado
	//Inclusao
	DbSelectArea("ACU")
	cCateg := AllTrim(LJ801aRetC())       // Retorna a primeira categoria disponivel
	Reclock("ACU",.T.)
    
	REPLACE	ACU->ACU_FILIAL	WITH  xFilial("ACU")
	REPLACE	ACU->ACU_COD 	WITH cCateg
	REPLACE	ACU->ACU_DESC	WITH AllTrim(cSugestao)
	REPLACE	ACU->ACU_MSBLQL	WITH "2"
	If lIntPOS .AND. lACU_POSFLG
		REPLACE ACU->ACU_POSFLG WITH "1"
	EndIf
	ACU->(MsUnlock())
	
	Reclock("ACV",.T.)

	REPLACE	ACV->ACV_FILIAL		WITH  xFilial("ACU")
	REPLACE	ACV->ACV_CATEGO 	WITH  cCateg
	REPLACE	ACV->ACV_CODPRO		WITH  AllTrim(cCodPro)
	REPLACE	ACV->ACV_SUVEND		WITH  "1"
	If lIntPOS .AND. lACV_POSFLG
		REPLACE ACV->ACV_POSFLG WITH "1"
	EndIf
	ACV->(MsUnlock())

	If nTipo == 1    
		Reclock("ACU",.T.)        
	    
		REPLACE	ACU->ACU_FILIAL	WITH xFilial("ACU")
		REPLACE	ACU->ACU_CODPAI	WITH cCateg    
		cCateg := Soma1(cCateg)
		REPLACE	ACU->ACU_COD   	WITH AllTRIM(cCateg)
		REPLACE	ACU->ACU_DESC	WITH "Filho " +  AllTrim(cSugestao)
		REPLACE	ACU->ACU_MSBLQL	WITH "2" 
		If lIntPOS .AND. lACU_POSFLG
			REPLACE ACU->ACU_POSFLG WITH "1"
		EndIf
		ACU->(MsUnlock())
	EndIf	

Else
	// ALTERACAO
	cCateg := AllTrim(LJ801aRetC(cCodPro))// Retorna a categoria do respectivo produto
	
EndIf

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

While (cAlias)->( !Eof() )
   If !Empty(AllTrim((cAlias)->L2_OK))
		Reclock("ACV",.T.)
   		REPLACE	ACV->ACV_FILIAL		WITH xFilial("ACU")
   		REPLACE	ACV->ACV_CATEGO 	WITH AllTrim(cCateg)
		REPLACE	ACV->ACV_CODPRO		WITH (cAlias)->L2_PRODUTO
		REPLACE	ACV->ACV_SUVEND		WITH "1"
		If lIntPOS .AND. lACV_POSFLG
			REPLACE ACV->ACV_POSFLG WITH "1"
		EndIf
		ACV->(MsUnlock())
   EndIf
   (cAlias)->(DbSkip())
End

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  |Lj801aDescP บAutor  ณ Vendas Cliente     บ Data ณ  26/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Devolve o nome do produto baseado no codigo que foi        บฑฑ
ฑฑบ          ณ digitado.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodPro - Codigo do Produto                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aDescP(cCodPro)
Local cDesc 		:= CRIAVAR("B1_DESC",.F.)                //Nome do Produto
Local aArea			:= GetArea()                             //Area atual para restaurar no final da funcao
Default cCodpro 	:=""                             			

If !Empty(cCodPro) 
	DbSelectArea("SB1")
	If SB1->(DbSeek(xFilial("SB1")+cCodPro))
		cDesc := SB1->B1_DESC
	Endif	
Endif

RestArea(aArea)

Return cDesc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe2    บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao executada quando eh clicado no botao avancar do pai- บฑฑ
ฑฑบ          ณnel 2 o parametro principal eh nTpProc que vai determinar   บฑฑ
ฑฑบ          ณo proximo painel                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ nTpProc: tipo processo 1 prod especifico 2 quant vendida   บฑฑ
ฑฑบ          ณ nAvanc: Verifica se estแ avancando ou voltando             บฑฑ
ฑฑบ          ณ oCodPro: Codigo do produto                                 บฑฑ
ฑฑบ          ณ oDataIni: Data inicial                                     บฑฑ
ฑฑบ          ณ oDataFim: Data final                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   |  Retorna Verdadeiro caso efetuado com sucesso              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj801aNe2(nTpProc, nAvanc,oCodPro,oDataIni,;
                   oDataFim) 
Local lRet 			:= .T.     // Variavel de retorno
Default oWizard 	:=Nil
Default nTpProc 	:=0 
Default nAvanc 		:=0  
Default oCodPro 	:=Nil
Default oDataIni 	:=Nil   
Default oDataIni 	:=Nil		
If nAvanc  ==1
	If nTpProc ==1       // Produto especifico, habilita os campos de data para alteracao 
 		oWizard:SetPanel(2)
	   	oDataIni:Enable()
		oDataFim:Enable()
		oCodPro:Enable()
		oCodPro:Refresh()
		oDataIni:Refresh()
		oDataFim:Refresh()
		oChkData:bSetGet 	:= {|| .T. }
		oChkData:Disable()
		oChkData:Refresh()	
 	Else  //Quantidade vendida, pula um painel
     	oWizard:SetPanel(3)    		
    EndIf
EndIf

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe3    บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que retorna os os produtos de acordo com as informacoesฑ
ฑฑบ          ณpassadas no painel 3                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ nTpProc: tipo processo 1 prod especifico 2 quant vendida   บฑฑ
ฑฑบ          ณ nAvanc: Verifica se estแ avancando ou voltando             บฑฑ
ฑฑบ          ณ cCodProd: Codigo do produto                                บฑฑ
ฑฑบ          ณ dDataIni: Data inicial                                     บฑฑ
ฑฑบ          ณ dDataFIM: Data final                                       บฑฑ
ฑฑบ          ณ nPorceIni: Porcentagem inicial                             บฑฑ
ฑฑบ          ณ lQtdeVen : Indifica se eh qtde vendida ou prod. especifico บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aNe3(nTpProc	, nAvanc    ,  cCodProd,	dDataIni,;
                   dDataFIM , nPorceIni , nPorceFim,	lQtdeVen ) 
Local lRet 			:= .T.       //Variavel de retorno
Default oWizard 	:=Nil
Default nTpProc 	:=0 
Default nAvanc 		:=0
Default cCodProd 	:=""
Default dDataini 	:=""
Default dDataFIM	:=""
Default nPorceIni 	:=0
Default nPorceFim 	:=0
Default lQtdeVen	:=.T.
lQtdeVen:=.T.                

If nAvanc  ==1
	If Empty(cCodProd) 
		Alert(STR0016)//"O codigo do produto deve ser informado
		lRet:= .F.
	Else
 		DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
  	    If !SB1->(DbSeek(xFilial("SB1")+cCodProd))
	      //"O Produto nao existe
	      	Alert(STR0016)
	    	lRet  := .F.       
	    ElseIf Lj801cFilP(@cCodProd,DTOS(dDataIni),DTOS(dDataFIM),1, ,,nPorceIni, nPorceFim )  // efetua filtro de acordo com os dados informados
     	   	cAtencao := OemToAnsi(STR0028) + AllTrim(@cCodPro) + OemToAnsi(STR0042);// O produto x foi vendido y vezes no periodo
     	   	 +  AllTrim(STR(@nQtdeVend)) + OemToAnsi(STR0043)   
			oAtencao:Refresh()
			If Len(aProdCad)>0   // Caso esse array tenha informa็๕es indica que ja existe sugestao de vendas para esse produto, ou seja, sera atleracao
			  	MsgAlert(STR0044)//Este produto jแ tem sugestใo de vendas relacionada, para mais informar็๕es pressione o botใo Detalhes "
				oWizard:SetPanel(7)
			Else
			 	oWizard:SetPanel(4)
			EndIf
		Else
			MsgAlert(STR0030) //Nใo foi encontrado nenhum produto com a sele็ใo informada!
			lRet := .F.
			oWizard:SetPanel(3)				   
   		EndIf
	Endif
Else
	oWizard:SetPanel(3)	

	
EndIf
Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe4    บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณEsse painel filtra os produtos de acordo com a quantidade   บฑฑ
ฑฑบ          ณvendida                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ nTpProc: tipo processo 1 prod especifico 2 quant vendida   บฑฑ
ฑฑบ          ณ nAvanc: Verifica se estแ avancando ou voltando             บฑฑ
ฑฑบ          ณ dDataIni: Data inicial                                     บฑฑ
ฑฑบ          ณ dDataFIM: Data final                                       บฑฑ
ฑฑบ          ณ nQuantIni: Quantidade inicial                              บฑฑ
ฑฑบ          ณ nQuantFin: Quantidade Final                                บฑฑ
ฑฑบ          ณ lQtdeVen : Indifica se eh qtde vendida ou prod. especifico บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aNe4( nTpProc  , nAvanc    ,dDataIni	,dDataFIM,;
                    nQuantIni, nQuantFin ,lQtdeVen ) 
Local lRet 			:= .T.   //Variavel de retorno
Default oWizard 	:=Nil
Default nTpProc 	:=0 
Default nAvanc 		:=0
Default dDataini 	:= dDataBase
Default dDataFIM	:= dDataBase
Default nQuantIni 	:=0
Default nQuantFin 	:=0
Default lQtdeVen	:=.F.
lQtdeVen:=.F.
If nAvanc  ==1
	If Empty(nQuantIni)  .OR.  Empty(nQuantFin) 
	 	MsgAlert(STR0017)		//Informe a quantidade vendida
		lRet := .F.
	ElseIf Lj801cFilP(cCodPro,DTOS(dDataIni),DTOS(dDataFIM),2,nQuantIni,nQuantFin)   // efetua o filtro por quantidade vendida
	    cAtencao:=""
	    oAtencao:Refresh()
	Else
		MsgAlert(STR0030)    //Nใo foi encontrado nenhum produto com a sele็ใo informada!
		lRet := .F.
	EndIf   
Else
oWizard:SetPanel(3)  
  
EndIf
Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe5    บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que valida se o produto do grid  foi selecionado ou naoฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ nTpProc: tipo processo 1 prod especifico 2 quant vendida   บฑฑ
ฑฑบ          ณ nAvanc: Verifica se estแ avancando ou voltando             บฑฑ
ฑฑบ          ณ cCodProd: Codigo do produto                                บฑฑ
ฑฑบ          ณ oCodPro:Objeto codigo do produto                           บฑฑ
ฑฑบ          ณ cNomePro: Nome do produto                                  บฑฑ
ฑฑบ          ณ oNomePro: Objeto nome do produto                           บฑฑ
ฑฑบ          ณ oDataIni: Objeto data inicial                              บฑฑ
ฑฑบ          ณ oDataFim: Objeto data Final                                บฑฑ
ฑฑบ          ณ cAliasTrb: Alias arquivo temporario                        บฑฑ
ฑฑบ          ณ lQtdeVen: Verifica se o grid ant. foi o qtde vendida       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aNe5(nTpProc	 , 	nAvanc	 ,cCodPro ,oCodPro,;
                   cNomePro  ,	oNomePro ,oDataIni,oDataFim,;
                   lQtdeVen )                  
                   
Local lRet           := .F.    		//Variavel de retorno
Local lChkData    := .F.		//Define se o componente ochkData estara marcado ou nao 
Local nTipo          := 0           //Variavel de controle de Tipo
Default oWizard   :=Nil
Default nTpProc   :=0 
Default nAvanc     :=0
Default cCodPro   :=""
Default oCodPro   := Nil
Default cNomePro :=""
Default oNomePro := Nil
Default oDataIni     :=Nil
Default oDataFim   :=Nil
Default lQtdeVen   :=.T. 

Do Case
    Case nAvanc  ==1     				// Indica que veio do painel numero 3, e que vai validar se o usuario selecionou ou nao o produto do grid
    	If lQtdeVen
       		nTipo :=1	  
    	Else
       		nTipo :=2    		
    	EndIf
		If Lj801aSelPr(nTipo,@cCodPro) // valida se foi selecionado o produto
			If nTipo ==2       					// caso seja  por quantidade vendida ira desabilitar alguns campos
			  	cNomePro:=Lj801aDescP(cCodPro)
				oNomePro:Refresh()
				oDataIni:Disable()
				oDataFim:Disable()
				oCodPro:Disable()
				oCodPro:Refresh()
				oDataIni:Refresh()
				oDataFim:Refresh()
			  	oWizard:SetPanel(2)
				oChkData:Enable()
				oChkData:bSetGet 	:= {|| lChkData }
				oChkData:bLClicked	:= {|| lChkData:=!lChkData,LJa801HDat(oDataIni,oDataFim,lChkData) }
				oChkData:Refresh()                     
			Else                                                         
			
				oCodPro:Refresh()  
				// fazer novo painel
		
			EndIf
			lRet :=.T.
		EndIf
	Case nAvanc  ==2 //estแ voltando e deve ir ao painel de selecionar por produto especifico ou quantidade vendida
		 oWizard:SetPanel(2)

Endcase

Return lRet 
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe7    บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณValida o nome da sugestao de vendas e chama funcao de gravacaoฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ nAvanc: Verifica se estแ avancando ou voltando             บฑฑ
ฑฑบ          ณ cSugestao:Nome da sugestao de vendas que sera cadastrada   บฑฑ
ฑฑบ          ณ nTipoCateg: Verifica se vai usuar sub categoria ou nao     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aNe7(nAvanc,cSugestao,nTipoCateg ) 
Local lRet 			:= .T. 		//Variavel de Retorno

Default oWizard 	:=Nil
Default nAvanc 		:=0 
Default cSugestao 	:= ""
Default nTipoCateg 	:=0        

If nAvanc  ==1
	If Empty(cSugestao)
	 	MsgAlert(STR0031)		//Informe a Sugestใo
		lRet := .F.		
	ElseIf LJa801GRAV(cCodPro,cSugestao,nTipoCateg)  // Funcao de gravacao a sugestao de vendas
		oWizard:SetPanel(9)
	Else
		lRet := .F.			
	EndIf
EndIf

Return lRet

/*/                        
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe8    บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que valida se o produto do grid  foi selecionado ou naoฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ nTpProc: tipo processo 1 prod especifico 2 quant vendida   บฑฑ
ฑฑบ          ณ nAvanc: Verifica se estแ avancando ou voltando             บฑฑ
ฑฑบ          ณ cCodProd: Codigo do produto                                บฑฑ
ฑฑบ          ณ oDBTree: Objeto arvore                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aNe8(nTpProc, nAvanc,cCodPro)
Local cCateg := AllTrim(LJ801aRetC(cCodPro))// Retorna a categoria do respectivo produto 
Local lRet := .F.    		//Variavel de retorno 
Default oWizard	:=Nil
Default nTpProc		:=0
Default nAvanc		:=0
Default cCodPro		:=""

If nAvanc  ==1  //Caso seja inclusao de um produto em uma sugestao de vendas existente, sera considerado alteracao e irแ para o ultimo painel
	If Lj801aSelPr(nTpProc,@cCodPro)    
		If Lj801aSuCa(cCateg)
				cAtencao:=""
			    oAtencao:Refresh()
		Else
			If LJa801GRAV(cCodPro, , ,AllTrim(LJ801aRetC(cCodPro))) 
				oWizard:SetPanel(9)
			EndIf
	  	EndIf
	  	lRet :=.T.
	EndIf
Else  //Caso seja retorno ao Painel, exibe novamente Grid com os produtos que podem ser associados ao Principal
	Lj801aSelPr(nTpProc,@cCodPro)
  	oWizard:SetPanel(8)   	      	 
  	
	oDBTree:Reset()

	cAtencao := OemToAnsi(STR0028) + AllTrim(cCodPro) + OemToAnsi(STR0042);// O produto x foi vendido y vezes no periodo
     	   	 +  AllTrim(STR(@nQtdeVend)) + OemToAnsi(STR0043)   
	oAtencao:Refresh()
	
EndIf

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe9    บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a categoria foi selecionada                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ nTpProc: tipo processo 1 prod especifico 2 quant vendida   บฑฑ
ฑฑบ          ณ nAvanc: Verifica se estแ avancando ou voltando             บฑฑ
ฑฑบ          ณ cCodProd: Codigo do produto                                บฑฑ
ฑฑบ          ณ cCateg: Sugestao  nao formatada                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aNe9(nTpProc, nAvanc,cCodPro,cCateg) 
Local lRet 				:=.F.		//Variavel de retorno
Local cQuery         := ""                //Variavel de consulta
Local cArea	        :="LJVC"    //variavel de Area temporaria para consulta           
Default oWizard		:=Nil
Default nTpProc		:=0
Default nAvanc		:=0
Default cCodPro		:=""       

cQuery := "SELECT V.ACV_CODPRO, U.ACU_CODPAI FROM "+ RetSqlName("ACU") +" U LEFT JOIN "+ RetSqlName("ACV") +" V "
cQuery += "ON V.ACV_CATEGO = U.ACU_COD WHERE U.ACU_COD = '"+ cCateg +"' AND V.ACV_SUVEND = '1' "
cQuery += "AND V.D_E_L_E_T_ = ' ' AND U.D_E_L_E_T_ = ' '"
LJa801ExQu(cArea,@cQuery)                        

cCodPro    := Alltrim((cArea)->ACV_CODPRO)    

If cAtencao = ''                                                                             
   	MsgAlert(STR0060)
Else 
  	lRet:=	LJa801GRAV(cCodPro,,,cCateg)
EndIf
                     
Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aNe10   บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel por limpar todos os campos do wizard funcao eh  บฑฑ
ฑฑบ          ณexecutada no ultimo painel                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oWizard: Wizard atual                                      บฑฑ
ฑฑบ          ณ cCodProd: Codigo do produto                                บฑฑ
ฑฑบ          ณ oCodPro:Objeto codigo do produto                           บฑฑ
ฑฑบ          ณ oQtdeIni: Objeto Quantidade inicial                        บฑฑ
ฑฑบ          ณ oQtdeFim: Objeto Quantidade Final                          บฑฑ
ฑฑบ          ณ dDataIni: Data inicial                                     บฑฑ
ฑฑบ          ณ dDataFIM: Data final                                       บฑฑ
ฑฑบ          ณ nQtdeIni: Quantidade inicial                               บฑฑ
ฑฑบ          ณ nQtdeFim: Quantidade Final                                 บฑฑ
ฑฑบ          ณ cSugestao:Nome da sugestao de vendas que sera cadastrada   บฑฑ
ฑฑบ          ณ oSugestao:Objeto  sugestao de vendas que sera cadastrada   บฑฑ 
ฑฑบ          ณ oDataIni: Objeto data inicial                              บฑฑ
ฑฑบ          ณ oDataFim: Objeto data Final                                บฑฑ
ฑฑบ          ณ nPercentIni:Nome da sugestao de vendas que sera cadastrada บฑฑ
ฑฑบ          ณ oPercentIni:Objeto  sugestao de vendas que sera cadastrada บฑฑ 
ฑฑบ          ณ nPercentFim: Objeto data inicial                           บฑฑ
ฑฑบ          ณ oPercentFim: Objeto data Final                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aNe10() 
Local lRet := .T.        //Variavel de Retorno                                                                                                             

oWizard:SetPanel(1)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aSuCa   บAutor  ณ Vendas Cliente    บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o produto selecionado tem ou nao sub categorias บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCateg: Categoria do produto                               บฑฑ
ฑฑบ          ณ oDBTree: Objeto de de exibicao das categorias em forma     บฑฑ
ฑฑบ          ณ hierarquica                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aSuCa(cCateg)  
Local cQuery        := ""				//Query que sera executada
Local lRet 			:=.F.			// variavel de retorno
Local cCat          := ""        		// Categoria que sera inserida no dbtree
Local cArea 		:= "LJVC"		// tabela temporaria
Local cBmp1 		:= "PMSEDT3"    // icone das categorias
Local cBmp2 		:= "PMSDOC"     // icone dos produtos
Default cCateg 		:=""                                                                                          

oDBTree := dbTree():New(10,10,95,300,oWizard:GetPanel(9),{||Lja801ExCa(oDBTree:GetCargo())},,.T.)	                     
oDBTree:PTRefresh()
  
cQuery:= "SELECT ACU_COD, ACU_DESC, ACU_CODPAI FROM "+ RetSqlName("ACU") + " WHERE ACU_CODPAI ='"+cCateg+"'  OR ACU_COD ='" +cCateg + "' "
cQuery+= " AND D_E_L_E_T_ = ' '"
LJa801ExQu(cArea,@cQuery)

While !(cArea) ->(EOF())
	cCat  := Alltrim((cArea)->ACU_COD) + " - " + (cArea)->ACU_DESC
   	If(AllTrim(cCateg)==AllTrim((cArea)->ACU_COD)) 
		oDBTree:AddTree(cCat ,.T.,cBmp1,cBmp1,,,(cArea)->ACU_COD)
		cQuery :=" SELECT DISTINCT C.ACV_CATEGO,C.ACV_CODPRO,P.B1_DESC FROM  "+ RetSqlName("ACV") + " C LEFT JOIN "+ RetSqlName("SB1") + " P "
		cQuery += "ON P.B1_COD = C.ACV_CODPRO WHERE C.ACV_CATEGO ='"+cCateg+"' "
		cQuery += "AND C.D_E_L_E_T_ = ' ' AND P.D_E_L_E_T_ = ' '"
		LJa801ExQu("LJPAI",@cQuery)

		While !LJPAI->(EOF())
			cCat:= AllTrim(LJPAI->ACV_CODPRO) + " - "+ (LJPAI->B1_DESC)
			oDBTree:AddItem(cCat,(LJPAI->ACV_CODPRO),cBmp2,,,2)
			LJPAI ->(DBSKIP())
		End
		LJPAI->(DbCloseArea())    
		
	Else
		oDBTree:AddTree(cCat ,.F.,cBmp1,cBmp1,,,(cArea)->ACU_COD)
		cQuery :=" SELECT DISTINCT C.ACV_CATEGO,C.ACV_CODPRO,P.B1_DESC FROM "+ RetSqlName("ACV") + " C LEFT JOIN "+ RetSqlName("SB1") + " P "
		cQuery += "ON P.B1_COD = C.ACV_CODPRO WHERE C.ACV_CATEGO ='"+(cArea)->ACU_COD+"' "  
		cQuery += "AND C.D_E_L_E_T_ = ' ' AND P.D_E_L_E_T_ = ' '"
		LJa801ExQu("LJPAI",@cQuery)                                                                                  
		
		While !LJPAI->(EOF())
			cCat:= Alltrim((LJPAI->ACV_CODPRO)) + " - "+ (LJPAI->B1_DESC)
  			oDBTree:AddTreeItem(cCat, cBmp2,,(LJPAI->ACV_CODPRO))
		
			LJPAI ->(DBSKIP())
		End
		
		lRet:=.T.	
		LJPAI->(DbCloseArea())  
	EndIf 
	(cArea) ->(DBSKIP()) 
End
oDBTree:EndTree()
oDBTree:PTRefresh()
(cArea)->(DbCloseArea())

Return  lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801SelPr  บAutor  ณ Vendas Cliente     บ Data ณ 28/10/2010บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica os produtos selecionados pela quantidade vendida  บฑฑ
ฑฑบ          ณ ou produto especifico                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnTipo - por prod especifico ou qtdade vendida               บฑฑ
ฑฑบ          ณcprodSel - retorna o produto selecionado                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aSelPr(nTipo,cProdSel)

Local lRet 			:= .F.			//Variavel de retorno  
    
Default nTipo 		:=0
Default cProdSel 	:=""

DbSelectArea(cAliasTRB)
(cAliasTRB)->(DbGoTop())

While (cAliasTRB)->( !Eof() )
    If !Empty(AllTrim((cAliasTRB)->L2_OK))
    	If nTipo ==1         // caso seja por produto especifico sera necessario selecionar pelo menos um produto
    		lRet :=.T.
    		Exit
    	Else// caso seja por quantidade vendida sera necessario selecionar APENAS  um produto
    		If lRet
	    		lRet :=.F.
	    		Exit		    		     
    		EndIf
    		lRet :=.T.
    		cProdSel := (cAliasTRB)->L2_PRODUTO
    	Endif
    EndIf
	(cAliasTRB)->(DbSkip())
End
If !lRet
	If nTipo ==1
		MsgAlert(STR0033)
	Else
		MsgAlert(STR0034)
	EndIf

	/*/
ษ necessแrio informar pelo menos um produto.
Selecione apenas um produto.
/*/

EndIf
(cAliasTRB)->(DbGoTop())
Return lRet              

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801cFilP  บAutor  ณ Vendas Cliente     บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra os produtos de acordo com a selecao informada ao    บฑฑ
ฑฑบ          ณ usuario                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodProduto - Codigo do produto                             บฑฑ
ฑฑบ          ณcDataInicial - Data inicial da consulta                     บฑฑ
ฑฑบ          |cDataFinal - Data final da consulta                         บฑฑ
ฑฑบ          |nTipo - Tipo - se e por produto especifico ou qtde vendida  บฑฑ
ฑฑบ          ณnQuantIni - Quantidade inicial                              บฑฑ
ฑฑบ          ณnQuantFim - Quantidade Final                                บฑฑ
ฑฑบ          ณnPercenIni - Porcentagem inicial                            บฑฑ
ฑฑบ          ณnPercenFim - Porcentagem final                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801cFilP (cCodProduto, cDataInicial, cDataFinal, nTipo,;
                     nQuantIni  , nQuantFim    , nPercenIni, nPercenFim)   

Local cOrcament 					:=  RetSQLName("SL2")			//Verificar qual eh a tabela de orcamento
Local cArea							:= "LJVC"  						//Alias temporario
Local lRet						    :=.F.							//Variแvel de retorno
Local cQuerySel   					:=""								//Query
Local nPos                          :=0                              //variavel de controle de posicao
Default cCodProduto 				:=""
Default cDataInicial 				:="20100101"
Default cDataFinal	 				:="20101231"
Default nTipo 						:= 0
Default	nPercenIni 					:=0
Default	nPercenFim 					:=0
Default nQuantIni 					:=0
Default nQuantFim 					:=0


If Empty(nPercenIni)
	nPercenIni = 00.01
Endif
If Empty(nPercenFim)
	nPercenFim = 100
Endif

aProdCad:={}
If ntipo == 1     // caso seja produto especifico
	Lj801cVlPr(cCodProduto)     // verifica se o produto informado ja tem sugestao cadastrada
	nQtdeVend:=	Lj801aLocQ(cCodProduto, cDataInicial, cDataFinal)   // verifica a quantidade vendida do produto no periodo
	cQuerySel := "SELECT DISTINCT L2_PRODUTO, SUM(L2_QUANT) L2_QUANT, '.F.' L2_OK,   	L2_DESCRI FROM "  +  cOrcament
	cQuerySel += " WHERE  L2_NUM IN (  SELECT L2_NUM FROM " + cOrcament + " 	WHERE D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "' )"
  	cQuerySel += " AND  L2_PRODUTO <> '" + AllTrim(cCodProduto) + "' AND L2_EMISSAO BETWEEN '" + cDataInicial  + "' AND '" + cDataFinal + "' "  
  	cQuerySel += " AND D_E_L_E_T_ = ' ' AND (L2_DOC <> '" + Space(TamSx3("L2_DOC")[1]) + "' OR L2_PEDRES <> '" + Space(TamSx3("L2_PEDRES")[1]) +  "') "
	cQuerySel += " GROUP BY L2_PRODUTO,  L2_DESCRI"
	cQuerySel += " HAVING SUM(L2_QUANT)"
  	cQuerySel += " BETWEEN "
  	cQuerySel += "( (SELECT SUM (L2_QUANT) FROM " + cOrcament + " WHERE  D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "')*"  + STR(nPercenIni) + ") /100 AND "
  	cQuerySel += "( (SELECT SUM (L2_QUANT) FROM " + cOrcament + " WHERE  D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "')*"  + STR(nPercenFim) + ") /100     "
Else
    nQtdeVend:=0
	cQuerySel := "SELECT DISTINCT L2_PRODUTO, SUM(L2_QUANT) AS L2_QUANT,	L2_DESCRI FROM "  +  cOrcament
	cQuerySel += " WHERE L2_EMISSAO 	BETWEEN '" + cDataInicial  + "' AND '" + cDataFinal + "'
	cQuerySel += " AND D_E_L_E_T_ = ' '  AND (L2_DOC <> '" + Space(TamSx3("L2_DOC")[1]) + "' OR L2_PEDRES <> '" + Space(TamSx3("L2_PEDRES")[1]) +  "')"
	cQuerySel += " GROUP BY L2_PRODUTO, L2_DESCRI HAVING  SUM(L2_QUANT)"
	cQuerySel += " BETWEEN " + nQuantIni + " AND "  +  nQuantfim
Endif

cQuerySel += " ORDER BY L2_QUANT DESC "
LJa801ExQu(cArea,@cQuerySel)
DbSelectArea(cAliasTRB)
(cAliasTRB)->(__dbZap())
DbSelectArea(cArea)   
While !(cArea) ->(EOF())  // passa da tabela temporaria  LJVC para a TRB que ira preencher o grid
    nPos := aScan(aProdCad, {|c| c[2] == AllTrim((cArea)->L2_PRODUTO)} )     // verifica se os produtos retornados ja estao cadastrados
    If	nPos  == 0      // retorna zero quando o produto retornado nao esta cadastrado
		Reclock("TRB",.T.)
		(cAliasTRB)->L2_PRODUTO:=(cArea)->L2_PRODUTO                       // codigo do produto
		(cAliasTRB)->L2_DESCRI:=(cArea)->L2_DESCRI                         // Descricao do produto
		(cAliasTRB)->L2_QUANT:=(cArea)->L2_QUANT                           // quantidade vendida no periodo
		(cAliasTRB)->L2_PORCENT:= ((cArea)->L2_QUANT * 100)/ nQtdeVend     // porcentagem 
		(cAliasTRB)->L2_OK:=" "
	    lRet :=.T.
    EndIf
	(cArea) ->(DBSKIP())
End

(cAliasTRB)->(DbGoTop())  

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801cVlPr  บAutor  ณ Vendas Cliente     บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se jแ existe o produto na sugestใo de vendas      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodPro - Codigo do produto                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801cVlPr(cCodPro) 

Local cArea	    := "LJVC"  						//Alias temporario	
Local cQuery 	:= ""                               //Variavel de Consulta
Default cCodPro :=""

cQuery:="SELECT DISTINCT C.ACV_CATEGO,C.ACV_CODPRO,P.B1_DESC FROM " + RetSqlName("ACV") +" C LEFT JOIN "+ RetSqlName("SB1") +" P " 
cQuery+="ON P.B1_COD = C.ACV_CODPRO WHERE  C.ACV_CATEGO IN ("
cQuery+="SELECT ACU_COD FROM  " + RetSqlName("ACU") +" WHERE ACU_CODPAI IN" 
cQuery+="(SELECT ACV_CATEGO FROM  " + RetSqlName("ACV") +" WHERE ACV_CODPRO ='" + (cCodPro) + "' AND D_E_L_E_T_ = ' ')) OR C.ACV_CATEGO IN("
cQuery+="(SELECT ACV_CATEGO FROM  " + RetSqlName("ACV") +" WHERE ACV_CODPRO ='" + (cCodPro) + "' AND D_E_L_E_T_ = ' ')) "
cQuery+="AND C.ACV_CODPRO <> '" + (cCodPro) + "' "
cQuery+="AND C.D_E_L_E_T_ =' '"   

LJa801ExQu(cArea,@cQuery)
While !(cArea) ->(EOF())
	AAdd(aProdCad, { .T., AllTrim((cArea)->ACV_CODPRO),(cArea)->B1_DESC} )  // preenche no array os produtos encontrados que ja estao cadastrados 
	(cArea) ->(DBSKIP())														//na sugestao de vendas
End	
(cArea)->(DbCloseArea())

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aGetS  บAutor  ณ Vendas Cliente     บ Data ณ  28/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a estrutura do grid e da tabela temporaria de produ บฑฑ
ฑฑบ          ณ tos                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaGrid - array de Campos para o grid de produtos             บฑฑ
ฑฑบ          ณaStruTRB - Array com estrutura da tabela temporaria         บฑฑ
ฑฑบ          ณaNomeTMP - Array com os arquviso temporarios                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aGetS(aGrid,aStruTRB,	aNomeTMP)
Local aTamD2_ITEM		:= TamSx3("L2_ITEM")		// Tamanho do campo D2_ITEM
Local aTamD2_COD		:= TamSx3("L2_PRODUTO")		// Tamanho do campo D2_COD
Local aTamB1_DESC		:= TamSx3("L2_DESCRI")		// Tamanho do campo B1_DESC
Local aTamD2_QTD		:= TamSx3("L2_QUANT")		// Tamanho do campo D2_QUANT
Local oTempTable		:= Nil 						// Objeto tabela temporaria

Default aGrid 			:= {}
Default aStruTrB 		:= {}
Default aNomeTMP 		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe estiver utilizando rastreablidade, mostra os campos de ณ
//ณcontrole de lote.                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   
AADD(aStruTRB,{"L2_OK"		,"C",aTamD2_ITEM[1]			,aTamD2_ITEM[2]		}) 
AADD(aStruTRB,{"L2_PRODUTO"	,"C",aTamD2_COD[1]			,aTamD2_COD[2]		})
AADD(aStruTRB,{"L2_DESCRI" 	,"C",aTamB1_DESC[1]			,aTamB1_DESC[2]		})
AADD(aStruTRB,{"L2_QUANT" 	,"N",aTamD2_QTD[1]			,aTamD2_QTD[2]		})
AADD(aStruTRB,{"L2_RECNO"   ,"C",10						,0					})
AADD(aStruTRB,{"L2_PORCENT"	,"N",aTamD2_QTD[1]			,aTamD2_QTD[2]		})

aAdd(aGrid,{"L2_OK"		,," "	 ," "})		
aAdd(aGrid,{"L2_PRODUTO",,STR0011," "}) 		//"Produto		
aAdd(aGrid,{"L2_DESCRI"	,,STR0029," "})			//"Descricao		
aAdd(aGrid,{"L2_QUANT"	,,STR0021," "})			//Quantidade

If Select(cAliasTRB) > 0
	If( ValType(oTempTable) == "O")
	  oTempTable:Delete()
	  FreeObj(oTempTable)
	  oTempTable := Nil
	EndIf
EndIf

//Cria tabela temporaria
oTempTable := LjCrTmpTbl(cAliasTRB, aStruTRB, {"L2_RECNO","L2_OK"})

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLj801aLocQ  บAutor  ณ Vendas Cliente     บ Data ณ  20/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica a quantidade vendida de um determinado produto em บฑฑ
ฑฑบ          ณ um intervalo de tempo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodProduto - Codigo do produto                             บฑฑ
ฑฑบ          ณcDataInicial - Data inicial da consulta                     บฑฑ
ฑฑบ          |cDataFinal - Data final da consulta                         บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณRetorna a quantidade vendida do produto                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA - VENDA ASSISTIDA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Lj801aLocQ (cCodProduto, cDataInicial, cDataFinal)     
Local nQuant 		:= 0				 	//Variavel de retorno
Local cOrcament 	:= RetSQLName("SL2")	//Verificar qual eh a tabela de orcamento
Local cArea			:= "LJVC"    			//Alias temporario 
Local cQuery       	:= ""                   //Variavel de Consulta
Default cCodProduto := ""
Default cDataInicial:= ""
Default cDataFinal 	:= ""

cQuery := " SELECT SUM(L2_QUANT) AS L2_QUANT FROM "  +  cOrcament
cQuery += " WHERE  L2_NUM IN (  SELECT L2_NUM FROM " + cOrcament + " 	WHERE D_E_L_E_T_ = ' '  AND L2_PRODUTO = '" +  cCodProduto + "')"
cQuery += " AND  L2_PRODUTO = '" + AllTrim(cCodProduto) + "' AND L2_EMISSAO BETWEEN '" + cDataInicial  + "' AND '" + cDataFinal + "' "
cQuery += " AND D_E_L_E_T_ = ' '  AND (L2_DOC <> '" + Space(TamSx3("L2_DOC")[1]) + "' OR L2_PEDRES <> '" + Space(TamSx3("L2_PEDRES")[1]) +  "') "
cQuery += " GROUP BY L2_PRODUTO,  L2_DESCRI"
cQuery += " ORDER BY L2_QUANT DESC "
LJa801ExQu(cArea,@cQuery)

nQuant := LJVC->L2_QUANT

(cArea)->(DbCloseArea())

Return nQuant
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    |LJ801aRetC  บAutor ณVendas               บ Data ณ 28/10/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณRetorna ultima Categora cadastrada                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณcCodPro = codigo do produto                	              ณฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    	
Function LJ801aRetC(cCodPro) 
Local cCateg  := "" 	// Variavel de Retorno
Local cQuery  := ""  // Query
Local cACU	  :=  RetSQLName("ACU")  //Define a tabela a ser utilizada em consulta
Local cArea	  := "LJVC"             //Area temporaria para consulta

Default	cCodPro	:=""

If !Empty(AllTrim(cCodPro)) // Caso tenha produto sera efetuada busca do produto para alteracao
	cQuery :="SELECT ACV_CATEGO FROM " + RetSQLName("ACV") + " WHERE ACV_CODPRO ='" + cCodPro + "' AND ACV_SUVEND = '1' AND D_E_L_E_T_ = ' '"
	LJa801ExQu(cArea,@cQuery)
	DbSelectArea(cArea) 
	cCateg := LJVC->ACV_CATEGO  //campo ้ tipo varchar
Else      
	cQuery :="SELECT MAX(ACU_COD) COD FROM " + cAcu +" WHERE D_E_L_E_T_ = ' '"
 	LJa801ExQu(cArea,@cQuery)
	DbSelectArea(cArea) 
	cCateg := Soma1(LJVC->COD)		//campo alfanumerico
EndIf
(cArea)->(DbCloseArea())

Return cCateg

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณLJ801aVlUsณ Autor ณ RAFAEL MARQUES        ณ Data ณ25/10/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Valida se o usuario esta habilitado para usar a rotina     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ LOJA801()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Void                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ                                                                        ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJ801aVlUs()
Local lCat	:= SuperGetMV("MV_LJCATPR",,.F.) 	// Verifica se o usuario esta com o parametro setado como True  
Local lRet  := .F.                       // Variavel de retorno

#IFDEF TOP 
	lRet := .T.
#ELSE	
	MsgStop(STR0065,STR0064) //"Rotina disponivel apenas para ambiente TOPCONECT."."###"Aten็ใo !"
#ENDIF                                                

If lRet
	If !lCat  
		MsgStop(STR0066,STR0064) //"O parametro MV_LJCATPR deve estar habilitado."."###"Aten็ใo !"
		lRet := .F.	
	EndIf	
EndIf 

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LjVldPorc
Usado para valida็ใo do valor informado no campo de porcentagem final

@param   nTpProc - Tipo escolhido (1-Produto especifico;2-quantidade vendida
@param   nPerceFim - Valor de porcentagem informado 
@author  Varejo
@version P11
@since   21/10/2014
@return  lRet - booleana com o retorno de sucesso (.T.) ou problema (.F.) 
/*/
//-------------------------------------------------------------------
Static Function LjVldPorc(nTpProc, nPerceFim)
Local lRet := .T.

If nTpProc == 1 .And. nPerceFim > 100	//Produto especifico
	lRet := .F.
	MsgInfo(STR0063, STR0064) //#"A porcentagem final nใo pode ser supeior a 100%." //##"Aten็ใo"
EndIf

Return lRet
