#INCLUDE "TMKC010A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH" 

#DEFINE cPerg "TMKC10"

//Define dos arrays da tela de contatos
#DEFINE CAB_CPO01     01 
#DEFINE CAB_CPO02     02 
#DEFINE CAB_CPO03     03 
#DEFINE CAB_CPO04     04 
#DEFINE CAB_CPO05     05 
#DEFINE CAB_CPO06     06 
#DEFINE CAB_CPO07     07 
#DEFINE CAB_CPO08     08 
#DEFINE CAB_CPO09     09 
#DEFINE CAB_CPO10     10 
#DEFINE CAB_CPO11     11 
#DEFINE CAB_BRW_END   12
#DEFINE CAB_BRW_FONE  13

//Define os arrays da tela de oportunidades
#DEFINE SUP_CPO01	01
#DEFINE SUP_CPO02	02
#DEFINE SUP_CPO03	03
#DEFINE SUP_CPO04	04
#DEFINE SUP_CPO05	05
#DEFINE SUP_CPO06	06
#DEFINE SUP_CPO07	07
#DEFINE SUP_CPO08	08
#DEFINE SUP_CPO09	09
#DEFINE SUP_CPO10	10
#DEFINE SUP_CPO11	11
#DEFINE SUP_CPO12	12
#DEFINE FLB_BCONC	13
#DEFINE FLB_BTIME	14
#DEFINE FLB_BPARC	15
#DEFINE FLB_BCONT	16
#DEFINE FLB_BPROD	17
#DEFINE FLB_BEVOL	18

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn01  ºAutor  ³Armando M. Tessaroli   º Data ³  12/06/02  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Consulta Perfil do Contato   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³--Revisao do fonte:Sintaxe,Documentacao,e Logicaº±±
±±ºHanna C.  |30/03/07|9.12  ³Bops 118469 - Alterado o nome dos Bitmaps   	  ³±±
±±º        	 ³        |      ³definidos pela Engenharia para o Protheus 10	  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn01(oExplorer, nPanel, aEmpCont)
Local aArea    := GetArea()                                             // Salva a area atual
Local oGraphic															// Objeto do definicao do grafico
Local nSerie	:= 0													// Numero de series que contera o grafico
Local aSerie   	:= {}													// Valores dos itens que farao parte da serie
Local nBottom  	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)		// Posicao inicial DIREITA	
Local nI 		:= 0 													// Contador Auxiliar
Local nAuxLen	:= 0													// Contador Auxiliar para o FOR	

Pergunte(cPerg,.F.)	// Posiciona nos parametros de usuario

If Empty(Mv_Par01)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O departamento de tecnologia alterou a classe de grafico do   ³
	//³remote, em funcao disso limitou tb a quantidade de graficos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Falta definir o parametro para o tipo de grafico deste painel de informacoes."
									STR0002,; //"Os Tipos de Graficos disponiveis sao:"
									STR0003,; //"	01) GRP_LINE		Codigo GRF01"
									STR0004,; //"	02) GRP_AREA		Codigo GRF02"
									STR0005,; //"	03) GRP_POINT		Codigo GRF03"
									STR0006,; //"	04) GRP_BAR			Codigo GRF04"
									STR0012,; //"	10) GRP_PIE			Codigo GRF10"
									})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Substituir este set pela variavel nSerie ao adicionar o aSerie para criar varias series   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSerie := Val( Mv_Par01 )

Aadd(aSerie, {nSerie, 0, STR0018, 65280} )			// CLR_HGREEN 	//"Atendimentos"
Aadd(aSerie, {nSerie, 0, STR0019, 16711680} )		// CLR_HBLUE 	//"Telemarketing"
Aadd(aSerie, {nSerie, 0, STR0020, 16711935} )		// CLR_HMAGENTA //"Televendas"
Aadd(aSerie, {nSerie, 0, STR0021, 12632256} )		// CLR_HGRAY 	//"Telecobrança"
Aadd(aSerie, {nSerie, 0, STR0022, 65535} )			// CLR_YELLOW 	//"Encerrados"
Aadd(aSerie, {nSerie, 0, STR0023, 255} )			// CLR_HRED 	//"Pendentes"

aSerie := TKC010VP01(aSerie, aEmpCont)				// Carrega as series com os valores

TkC010Grap(@oGraphic,02,02,nRight,(nBottom * .80),oExplorer:GetPanel(nPanel),aSerie)	

@ (nBottom * .83),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

@ (nBottom * .85),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
//"Os dados apurados para os demostrativos sao baseados apenas no contato e na empresa selecionados"
TSay():New((nBottom * .85),21,{|| STR0024 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) 

@ (nBottom * .90),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
//"Encerramento para televendas, foi considerado os pedidos com notas fiscais emitidas"
TSay():New((nBottom * .90),21,{|| STR0025 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) 

@ (nBottom * .95),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
//"Encerramento para telecobrança, foi considerada a data de retorno ao contato, quando não informada"
TSay():New((nBottom * .95),21,{|| STR0026 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn02  ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Contato, que contem os da- º±±
±±º          ³dos cadastrais do contato escolhido.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±º          ³        ³      ³                                              º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC010Pn02(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()											// Salva a area atual
Local nTop		:= 02													// Posicao inicial TOP	
Local nLeft		:= 02													// Posicao inicial ESQUERDA
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)		// Posicao inicial DIREITA
Local aCoord	:= {}													// Array com as posicoes de tela	

Aadd(aCoord, { nTop, nLeft, nBottom, nRight } )
MsMGet():New("SU5",RecNo(),2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn03  ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Telemarketing              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±º          ³        ³      ³                                              º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn03(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                            // Salva a area atual
Local oGraphic															// Objeto do definicao do grafico
Local nSerie															// Numero de series que contera o grafico
Local aSerie   	:= {}													// Valores dos itens que farao parte da serie
Local nLeft    	:= 02													// Posicao inicial ESQUERDA
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO	
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)		// Posicao inicial DIREITA	
Local aCabeca  	:= {}													
Local oLB01Pn003                                                    	// Painel 
Local nI 		:= 0 													// Contador auxiliar
Local nLenAux	:= 0 													// Contador auxiliar para o FOR

aCabeca := TKCListBox("SUC", aEmpCont, nPanel,,P_UNDEF)
If len(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, { STR0027,; 	//"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
								  "",;
								  STR0028,;	 	//"	01} SUC - Cabecalho do atendimento Telemarketing"
								  STR0029  }) 	//"	02) SUD - Itens do atendimento de Telemarketing"
	Return(Nil)
Endif

Pergunte(cPerg,.F.)	// Posiciona nos parametros de usuario

If Empty(Mv_Par02)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O departamento de tecnologia alterou a classe de grafico do   ³
	//³remote, em funcao disso limitou tb a quantidade de graficos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Falta definir o parametro para o tipo de grafico deste painel de informacoes."
									STR0002,; //"Os Tipos de Graficos disponiveis sao:"
									STR0003,; //"	01) GRP_LINE		Codigo GRF01"
									STR0004,; //"	02) GRP_AREA		Codigo GRF02"
									STR0005,; //"	03) GRP_POINT		Codigo GRF03"
									STR0006,; //"	04) GRP_BAR			Codigo GRF04"
									STR0012,; //"	10) GRP_PIE			Codigo GRF10"
									})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Substituir este set pela variavel nSerie ao adicionar o aSerie³
//³para criar varias series.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSerie := Val( Mv_Par02 )

Aadd(aSerie, {nSerie, 0, STR0030, 65280} )		// CLR_HGREEN 	//"Atendimento"
Aadd(aSerie, {nSerie, 0, STR0031, 16711680} )	// CLR_HBLUE 	//"Planejado"
Aadd(aSerie, {nSerie, 0, STR0032, 16711935} )	// CLR_HMAGENTA //"Encerrado"
Aadd(aSerie, {nSerie, 0, STR0033, 12632256} )	// CLR_HGRAY 	//"Pendente"
Aadd(aSerie, {nSerie, 0, STR0034, 65535} )		// CLR_YELLOW 	//"Ativo"
Aadd(aSerie, {nSerie, 0, STR0035, 255} )		// CLR_HRED 	//"Receptivo"
Aadd(aSerie, {nSerie, 0, STR0036, 16777215} )	// CLR_WHITE 	//"Follow Up"

aSerie := TKC010VP03(aSerie, aEmpCont)			// Carrega os valores para as series

TkC010Grap(@oGraphic,02,02,nRight,(nBottom * .60),oExplorer:GetPanel(nPanel),aSerie)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho dos Atendimentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ (nBottom*.63), nLeft	ListBox oLB01Pn003 Fields;
	Header	STR0119,;// 10 - Filial
			STR0038,; // 01 - Codigo 
			STR0039,; // 02 - Data 
			STR0040,; // 03 - Operador 
			STR0041,; // 04 - Midia 
			STR0042,; // 05 - Operacao 
			STR0043,; // 06 - Status 
			STR0044,; // 07 - Tipo 
			STR0045,; // 08 - Campanha 
			STR0046;  // 09 - Retorno 
	Size nRight,nBottom/2.8 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn003:SetArray(aCabeca)
oLB01Pn003:bLine:={||{	aCabeca[oLB01Pn003:nAt,10],;
						aCabeca[oLB01Pn003:nAt,1],;
						aCabeca[oLB01Pn003:nAt,2],;
						aCabeca[oLB01Pn003:nAt,3],;
						aCabeca[oLB01Pn003:nAt,4],;
						aCabeca[oLB01Pn003:nAt,5],;
						aCabeca[oLB01Pn003:nAt,6],;
						aCabeca[oLB01Pn003:nAt,7],;
						aCabeca[oLB01Pn003:nAt,8],;
						aCabeca[oLB01Pn003:nAt,9]  }}
oLB01Pn003:nAt := 1
oLB01Pn003:Default()

If Type("aDados") == "A"
	aDados[1]:=aCabeca
EndIf

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010PnTMK ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo dos paineis de telemarketing que sao os º±±
±±º          ³de numero:                                                    º±±
±±º          ³ 04-Encerramentos                                             º±±
±±º          ³ 05-Ativos                                                    º±±
±±º          ³ 06-Receptivos												º±±
±±º          ³ 07-Follow Up                                                 º±±
±±º          ³ 08-Pendencias											    º±±
±±º          ³ 09-Chamado Tecnico											º±±
±±º          ³ 10-Atendimentos											    º±±
±±º          ³ 44-Atendimento do field service.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K ³18/11/03³710   ³ Revisao da funcao bops 68111               	º±±
±±ºCleber M. ³17/01/07³115805³-Adequacao para montagem do aCols e aHeader 	º±±
±±º          ³        ³9.12  ³pela FillGetDados (Walk-thru)               	º±±
±±º          ³        ³      ³                                            	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010PnTMK(oExplorer, nPanel, aEmpCont, cPanel)

Local aArea    	:= GetArea()                                            // Salva a area atual 
Local nTop      := 05													// Coordenadas da tela
Local nLeft     := 05													
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01TMK															// Listbox do Cabecalho - SUC
Local aCabeca   := {}													// Array com os registros do SUC - Cabecalho do atendimento
Local oGetDados															// Getdados dos itens (SUD)	
Local nPosHeader														// Contador auxilar
Local oObs																// Observacao do MEMO
Local cObs      := ""													// String com a descricao do MEMO		
Local oEncMemo															// Observacao do ENCERRAMENTO - MEMO		
Local cEncMemo  := ""													// String com a descricao do ENCERRAMENTO
Local oCancMemo															// Observacao do CANCELAMENTO - MEMO		
Local cCancMemo := ""													// String com a descricao do CANCELAMENTO	
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSUDExc	:= (X2ModAcess("SUD") == "E")							// Indica se o SUD esta como exclusivo

Default cPanel := "" // Para release 11.7 o controle sera pelo nome do panel

aCabeca := TKCListBox("SUC", aEmpCont, nPanel,,cPanel)
If len(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0027,; //"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
									"",;
									STR0028,; //"	01} SUC - Cabeçalho do atendimento telemarketing"
									STR0029,; //"	02) SUD - Itens do atendimento de telemarketing"
									STR0114;  //"	03) AB1 - Chamado tecnico"
								 })
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SUD"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSUDExc .AND. cFilAnt <> aCabeca[1][10]
			cFilAnt := aCabeca[1][10]
		EndIf
		TkMontaItens( "SUD", aCabeca[1][1], "M" )
		cFilAnt := cFilAtu
		Aadd(aAllHeader, {"SUD", aHeader})
	EndIf
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft 	ListBox oLB01TMK Fields;
Header	STR0119,;// 01 - Filial
		STR0038,; // 02 - Codigo 
		STR0039,; // 03 - Data 
		STR0040,; // 04 - Operador 
		STR0041,; // 05 - Midia 
		STR0042,; // 06 - Operacao 
		STR0043,; // 07 - Status 
		STR0044,; // 08 - Tipo 
		STR0045,; // 09 - Campanha 
		STR0046;  // 10 - Retorno 
		SIZE nRight,(nBottom*.3) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01TMK:Cargo := "TELEMARKETING"
oLB01TMK:SetArray(aCabeca)
oLB01TMK:bLine:={||{	aCabeca[oLB01TMK:nAt,10],;
						aCabeca[oLB01TMK:nAt,1],;
						aCabeca[oLB01TMK:nAt,2],;
						aCabeca[oLB01TMK:nAt,3],;
						aCabeca[oLB01TMK:nAt,4],;
						aCabeca[oLB01TMK:nAt,5],;
						aCabeca[oLB01TMK:nAt,6],;
						aCabeca[oLB01TMK:nAt,7],;
						aCabeca[oLB01TMK:nAt,8],;
						aCabeca[oLB01TMK:nAt,9]}}

oLB01TMK:Default()
oLB01TMK:bChange := {||	If( (lSUDExc .AND. cFilAnt <> aCabeca[1][10]), (cFilAnt := Eval(oLB01TMK:bLine)[1]), .T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SUD"}),;
						aHeader := IIF(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "SUD"})][2])),;
						TkC10CargaTmk(	oGetDados	,Eval(oLB01TMK:bLine)[2]	,@cObs		,;
										oObs		,@cEncMemo					,oEncMemo	,;
										@cCancMemo  ,oCancMemo),;
						cFilAnt := cFilAtu	}
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um browser tipo MSGetDados Read Only dos itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MSGetDados():New((nBottom*.35),nLeft,(nBottom*.64),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra campos memo existentes para o atendimento selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ (nBottom * .66),nLeft SAY STR0047 OF oExplorer:GetPanel(nPanel) COLOR CLR_HBLUE ,CLR_WHITE PIXEL  //"Observacoes"
@ (nBottom * .695),nLeft GET oObs VAR cObs MEMO SIZE nRight*.3,nBottom/3.25 READONLY OF oExplorer:GetPanel(nPanel) PIXEL

@ (nBottom * .66),nRight*.36 SAY STR0048 OF oExplorer:GetPanel(nPanel) COLOR CLR_HBLUE,CLR_WHITE PIXEL //"Motivos"
@ (nBottom * .695),nRight*.36 GET oEncMemo VAR cEncMemo MEMO SIZE nRight*.3,nBottom/3.25 READONLY  OF oExplorer:GetPanel(nPanel) PIXEL

@ (nBottom * .66),nRight*.69 SAY STR0049 OF oExplorer:GetPanel(nPanel) COLOR CLR_HBLUE,CLR_WHITE PIXEL  //"Cancelamento"
@ (nBottom * .695),nRight*.69 GET oCancMemo VAR cCancMemo MEMO SIZE nRight*.3,nBottom/3.25 READONLY  OF oExplorer:GetPanel(nPanel) PIXEL

Eval(oLB01TMK:bChange) 
oLB01TMK:Refresh()

RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn11  ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Conhecimento               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±ºCleber M. ³17/01/07³115805³-Adequacao para montagem do aCols e aHeader 	º±±
±±º          ³        ³9.12  ³pela FillGetDados (Walk-thru)               	º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn11(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas da tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn11															// Listbox do Cabecalho - ACB
Local aCabeca    := {}													// Array com os registros do ACB - Cabecalho do banco de conhecimento
Local oGetDados                                                         // MsGetdados com os itens do banco de conhecimento ACC

DEFINE Cursor cMao HAND		// Muda o cursor quando posicionar o objeto no browser para abri-lo com duplo click

aCabeca := TKCListBox("ACB", aEmpCont, nPanel)
If len(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0027,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0050,; //"	01} ACB - Cabeçalho do banco de conhecimentos"
									STR0051,; //"	02) ACC - Itens do banco de conhecimentos"
									STR0115;  //"	03) AC9 - Relacionamento do contato com o objeto de conhecimento"
									})
	Return(Nil)
Else

	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACC"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkMontaItens( "ACC", aCabeca[1][1], "" )
		Aadd(aAllHeader, {"ACC", aHeader})
	Endif
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft 	ListBox oLB01Pn11 Fields;
	Header	STR0038,; // 01 - Codigo
			STR0052,; // 02 - Objeto
			STR0053;  // 03 - Desccricao
	SIZE nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) PIXEL;
	ON DblClick( MsDocView( Eval(oLB01Pn11:bLine)[2]) )

oLB01Pn11:SetArray(aCabeca)
oLB01Pn11:bLine:={||{	aCabeca[oLB01Pn11:nAt,1],;
						aCabeca[oLB01Pn11:nAt,2],;
						aCabeca[oLB01Pn11:nAt,3];
						}}
oLB01Pn11:oCursor := cMao
oLB01Pn11:nAt := 1
oLB01Pn11:Default()

oLB01Pn11:bChange := {||nPosHeader := Ascan(aAllHeader, {|x| x[1] == "ACC"}),;
											aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "ACC"})][2])),;
											TkMontaItens( "ACC", Eval(oLB01Pn11:bLine)[1], "" ),;
											oGetDados:oBrowse:Refresh()	}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um browser tipo MSGetDados Read Only dos itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MSGetDados():New((nBottom*.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn12  ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Análise Banco de conhecimenº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±º          ³        ³      ³                                              º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn12(oExplorer, nPanel, aEmpCont)

Local aArea    	 := GetArea()                                           // Salva a area atual
Local nTop       := 05													// Coordenadas da tela

Local nBottom	 := Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	 := Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)

Local aResultado := {}
Local aListBox   := {}
Local aOrdem     := { STR0054, STR0055 } 								//"Ocorrencias","Descricao"

Local cKeyWord   := Space( 100 )
Local cDescri    := Space( 40 )
Local cResultado := ""
Local cOrdem     := ""
Local cObjeto    := Space( 200 )

Local lExata     := .F.
Local lKeyWord   := .F.

Local oListBox
Local oBut1
Local oBut2
Local oPesqExata
Local oOrdem

@  0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oExplorer:GetPanel(nPanel) SIZE nRight/6, nBottom+10 NOBORDER WHEN .F. PIXEL ADJUST

TSay():New(nTop, nRight*.1,{|| STR0057 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"LOCALIZAR E VISUALIZAR CONHECIMENTO"

@ nBottom*.07, nRight*.1 TO nBottom, nRight LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

TSay():New(nBottom*.17, nRight*.18,{|| STR0052 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Objeto"
@ nBottom*.17, nRight*.33 MSGET oGetPesq3 VAR cObjeto PICTURE "@!" SIZE 80, 10 VALID .T. OF oExplorer:GetPanel(nPanel) PIXEL

TSay():New(nBottom*.24, nRight*.18,{|| STR0055 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Descricao"
@ nBottom*.24, nRight*.33 MSGET oGetPesq2 VAR cDescri PICTURE "@!" SIZE 80, 10 VALID .T. OF oExplorer:GetPanel(nPanel) PIXEL

TSay():New(nBottom*.31, nRight*.18,{|| STR0058 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Palavras chave"
@ nBottom*.31, nRight*.33 MSGET oGetPesq1 VAR cKeyWord PICTURE "@!" SIZE 80, 10 VALID .T. OF oExplorer:GetPanel(nPanel) PIXEL

TSay():New(nBottom*.38, nRight*.18,{|| STR0059 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Ordenar por"
@ nBottom*.38, nRight*.33	COMBOBOX oOrdem VAR cOrdem ITEMS aOrdem SIZE 80,10 OF oExplorer:GetPanel(nPanel) PIXEL;
		ON CHANGE Ft340Show( @oListBox, @aResultado, oOrdem, @lKeyWord )

@ nBottom*.45, nRight*.33 LISTBOX oListBox VAR cResultado ITEMS aListBox PIXEL SIZE nRight*.58, nBottom*.37 OF oExplorer:GetPanel(nPanel) MULTI

@ nBottom*.85, nRight*.33 CHECKBOX oPesqExata VAR lExata SIZE 60,8 PIXEL OF oExplorer:GetPanel(nPanel) PROMPT STR0060 //"Pesquisa Exata"

DEFINE SBUTTON oBut1 FROM nBottom*.85, nRight*.72 TYPE 15 ENABLE ONSTOP STR0061 OF oExplorer:GetPanel(nPanel); //"Pesquisar"
ACTION FT340LocLz(	@oListBox	,cKeyWord, cDescri	,cObjeto,;
					@aResultado	,lExata  , oOrdem	,@lKeyWord)

DEFINE SBUTTON oBut2 FROM nBottom*.85, nRight*.82 TYPE 14 ENABLE ONSTOP STR0062 OF oExplorer:GetPanel(nPanel); //"Abrir"
ACTION (ACB->( DbSetOrder(1) ),ACB->( DbGoto(aResultado[oListBox:nAt][2])),MsDocView(ACB->ACB_OBJETO)) WHEN !Empty(cResultado)

RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC01Camp   ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Campanha                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±º          ³        ³      ³                                              º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC01Camp(oExplorer, nPanel, aEmpCont, cPanel)

Local aArea    	:= GetArea()                                                // Salva a area atual
Local nTop      := 05														// Coordenadas da tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Camp																// Listbox do Cabecalho - ACI
Local aCabeca   := {}														// Array com os registros do ACI - Cabecalho da campanha
Local oGraphic
Local nSerie
Local aSerie    := {}
Local nI 		:= 0 

Default cPanel := "" //Para Release 11.7 o controle será por nome do painel.

aCabeca := TKCListBox("ACI", aEmpCont, nPanel,,cPanel)

If len(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0027,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0063,; //"	01} ACI - Movimentos de campanhas"
									STR0116; //"	02} SUO - Cadastro de campanhas"
									})
	Return(Nil)
Endif

Pergunte(cPerg,.F.)	// posiciona nas perguntas

If Empty(Mv_Par03)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O departamento de tecnologia alterou a classe de grafico do   ³
	//³remote, em funcao disso limitou tb a quantidade de graficos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Falta definir o parametro para o tipo de gráfico deste painel de informacoes."
									STR0002,; //"Os Tipos de Graficos disponiveis sao:"
									STR0003,; //"	01) GRP_LINE		Codigo GRF01"
									STR0004,; //"	02) GRP_AREA		Codigo GRF02"
									STR0005,; //"	03) GRP_POINT		Codigo GRF03"
									STR0006,; //"	04) GRP_BAR			Codigo GRF04"
									STR0012,; //"	10) GRP_PIE			Codigo GRF10"
								})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Substituir este set pela variavel nSerie ao adicionar o aSerie³
//³para criar varias series.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSerie := Val( Mv_Par03 )

Aadd(aSerie, {nSerie, 0, STR0045, 65280} )		// CLR_HGREEN 	//"Campanha"
Aadd(aSerie, {nSerie, 0, STR0064, 16711680} )	// CLR_HBLUE 	//"Participou"
Aadd(aSerie, {nSerie, 0, STR0019, 16711935} )	// CLR_HMAGENTA //"Telemarketing"
Aadd(aSerie, {nSerie, 0, STR0020, 65535} )		// CLR_YELLOW 	//"Televendas"
Aadd(aSerie, {nSerie, 0, STR0021, 16777215} )	// CLR_WHITE 	//"Telecobrança"

aSerie := TKC01DadosCamp(aSerie, aEmpCont, nPanel, cPanel)		// Busca os valores para cada serie

TkC010Grap(@oGraphic,05,05,nRight,(nBottom * .5),oExplorer:GetPanel(nPanel),aSerie)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ (nBottom*.55),nLeft	ListBox oLB01Camp Fields;
	Header	STR0045,; // 01 - Campanha 
			STR0065,; // 02 - Descricao
			STR0066,; // 03 - Objetivo
			STR0067,; // 04 - Inicio
			STR0068,; // 05 - Fim
			STR0044,; // 06 - Tipo
			STR0030,; // 07 - Atendimento
			STR0069,; // 08 - Publico
			STR0065,; // 09 - Descricao
			STR0070,; // 10 - Responsavel
			STR0071,; // 11 - Coordenador
			STR0072,; // 12 - Departamento
			STR0073,; // 13 - Meta Camp.
			STR0074,; // 14 - Meta Oper.
			STR0075,; // 15 - Custo
			STR0076,; // 16 - ROI
			STR0077,; // 17 - % ROI
			STR0078,; // 18 - Leads Prev.
			STR0079,; // 19 - % Sucesso
			STR0080;  // 20 - % Fracasso
	Size nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Camp:Cargo := "CAMPANHAS"
oLB01Camp:SetArray(aCabeca)
oLB01Camp:bLine:={||{	aCabeca[oLB01Camp:nAt,1],;
						aCabeca[oLB01Camp:nAt,2],;
						aCabeca[oLB01Camp:nAt,3],;
						aCabeca[oLB01Camp:nAt,4],;
						aCabeca[oLB01Camp:nAt,5],;
						aCabeca[oLB01Camp:nAt,6],;
						aCabeca[oLB01Camp:nAt,7],;
						aCabeca[oLB01Camp:nAt,8],;
						aCabeca[oLB01Camp:nAt,9],;
						aCabeca[oLB01Camp:nAt,10],;
						aCabeca[oLB01Camp:nAt,11],;
						aCabeca[oLB01Camp:nAt,12],;
						aCabeca[oLB01Camp:nAt,13],;
						aCabeca[oLB01Camp:nAt,14],;
						aCabeca[oLB01Camp:nAt,15],;
						aCabeca[oLB01Camp:nAt,16],;
						aCabeca[oLB01Camp:nAt,17],;
						aCabeca[oLB01Camp:nAt,18],;
						aCabeca[oLB01Camp:nAt,19],;
						aCabeca[oLB01Camp:nAt,20];
						}}
oLB01Camp:nAt := 1
oLB01Camp:Default()

If Type("aDados") == "A"
	aDados[2] := aCabeca
EndIf

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC02Camp   ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Detalhado de campanha      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±º          ³        ³      ³                                              º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC02Camp(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()											// Salva a area atual				
Local nTop      := 05													// Coordenadas da tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Camp															// Browser da campanha - ACI
Local aCamp     := {}													// Dados da campanhas - ACI
Local oLB02Camp															// Browser do script - SUZ
Local aCabeca   := {}													// Scripts da capanha - SUZ

aCamp := TKCListBox("ACI", aEmpCont, nPanel)
If len(aCamp) == 0
	TKC010SD(oExplorer, nPanel, {	STR0027,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0063,; //"	01} ACI - Movimentos de campanhas"
									STR0081,; //"	02} SUZ - Script da campanha"
									STR0117; //"	03} SUW - Relacionamento de Script com a Campanha"
									})
	Return(Nil)
Endif

aCabeca := TKCListBox("SUZ", aEmpCont, nPanel, {aCamp[1][1]} )
If len(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0027,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0063,; //"	01} ACI - Movimentos de campanhas"
									STR0081,; //"	02} SUZ - Script da campanha"
									STR0117; //"	03} SUW - Relacionamento de Script com a Campanha"
									})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox da Campanha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop,nLeft	ListBox oLB01Camp Fields;
	Header	STR0045,; // 01 - Campanha 
			STR0065,; // 02 - Descricao 
			STR0066,; // 03 - Objetivo 
			STR0067,; // 04 - Inicio 
			STR0068,; // 05 - Fim 
			STR0044,; // 06 - Tipo 
			STR0030,; // 07 - Atendimento 
			STR0069,; // 08 - Public "
			STR0065,; // 09 - Descricao 
			STR0070,; // 10 - Responsavel 
			STR0071,; // 11 - Coordenador 
			STR0072,; // 12 - Departamento 
			STR0073,; // 13 - Meta Camp. 
			STR0074,; // 14 - Meta Oper. 
			STR0075,; // 15 - Custo 
			STR0076,; // 16 - ROI 
			STR0077,; // 17 - % ROI  
			STR0078,; // 18 - Leads Prev. 
			STR0079,; // 19 - % Sucesso 
			STR0080;  // 20 - % Fracasso 
	Size nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Camp:SetArray(aCamp)
oLB01Camp:bLine:={||{	aCamp[oLB01Camp:nAt,1],;
						aCamp[oLB01Camp:nAt,2],;
						aCamp[oLB01Camp:nAt,3],;
						aCamp[oLB01Camp:nAt,4],;
						aCamp[oLB01Camp:nAt,5],;
						aCamp[oLB01Camp:nAt,6],;
						aCamp[oLB01Camp:nAt,7],;
						aCamp[oLB01Camp:nAt,8],;
						aCamp[oLB01Camp:nAt,9],;
						aCamp[oLB01Camp:nAt,10],;
						aCamp[oLB01Camp:nAt,11],;
						aCamp[oLB01Camp:nAt,12],;
						aCamp[oLB01Camp:nAt,13],;
						aCamp[oLB01Camp:nAt,14],;
						aCamp[oLB01Camp:nAt,15],;
						aCamp[oLB01Camp:nAt,16],;
						aCamp[oLB01Camp:nAt,17],;
						aCamp[oLB01Camp:nAt,18],;
						aCamp[oLB01Camp:nAt,19],;
						aCamp[oLB01Camp:nAt,20];
						}}
oLB01Camp:nAt := 1
oLB01Camp:Default()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Script ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ (nBottom*.55),nLeft	ListBox oLB02Camp Fields;
	Header	STR0082,; // 01 - Script 
			STR0065,; // 02 - Descricao 
			STR0083,; // 03 - Tempo 
			STR0044,; // 04 - Tipo  
			STR0084,; // 05 - Formato 
			STR0085,; // 06 - ArmResp 
			STR0086,; // 07 - ScorMin 
			STR0087,; // 08 - ProcMin 
			STR0088,; // 09 - ScorMax 
			STR0089;  // 10 - ProcMax 
	Size nRight,(nBottom*.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
	
oLB02Camp:SetArray(aCabeca)
oLB02Camp:bLine:={||{	aCabeca[oLB02Camp:nAt,1],;
						aCabeca[oLB02Camp:nAt,2],;
						aCabeca[oLB02Camp:nAt,3],;
						aCabeca[oLB02Camp:nAt,4],;
						aCabeca[oLB02Camp:nAt,5],;
						aCabeca[oLB02Camp:nAt,6],;
						aCabeca[oLB02Camp:nAt,7],;
						aCabeca[oLB02Camp:nAt,8],;
						aCabeca[oLB02Camp:nAt,9],;
						aCabeca[oLB02Camp:nAt,10];
						}}
oLB02Camp:nAt := 1
oLB02Camp:Default()

oLB01Camp:bChange := {||	aCabeca := TKCListBox("SUZ", aEmpCont, nPanel, {Eval(oLB01Camp:bLine)[1]}),;
oLB02Camp:SetArray(aCabeca),;
oLB02Camp:bLine:={||{	aCabeca[oLB02Camp:nAt,1],;
						aCabeca[oLB02Camp:nAt,2],;
						aCabeca[oLB02Camp:nAt,3],;
						aCabeca[oLB02Camp:nAt,4],;
						aCabeca[oLB02Camp:nAt,5],;
						aCabeca[oLB02Camp:nAt,6],;
						aCabeca[oLB02Camp:nAt,7],;
						aCabeca[oLB02Camp:nAt,8],;
						aCabeca[oLB02Camp:nAt,9],;
						aCabeca[oLB02Camp:nAt,10]}},;
						oLB02Camp:nAt := 1,;
						oLB02Camp:Refresh();
						}

oLB02Camp:Default()
RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC03Camp   ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Análise Scripts de campanhaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±º          ³        ³      ³                                              º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC03Camp(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                                // Salva a area atual
Local nTop      := 05														// Coordenadas da tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Camp																// Browser da campanha
Local aCamp      := {}														// Campanhas
Local oLB02Camp																// Browser do script
Local aCabeca    := {}														// Scripts da capanha
Local oTreeScript                                                           // TREE

aCamp := TKCListBox("ACI", aEmpCont, nPanel)
If len(aCamp) == 0
	TKC010SD(oExplorer, nPanel, {	STR0027,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
	"",;
	STR0063,; //"	01} ACI - Movimentos de campanhas"
	STR0081,; //"	02} SUZ - Script da campanha"
	STR0117,; //"	03} SUW - Relacionamento de Script com a Campanha"
	STR0118; //"	04} SUP - Itens do script dinamico"
	})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox da Campanha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop,nLeft	ListBox oLB01Camp Fields;
	Header	STR0045,; // 01 - Campanha
			STR0065,; // 02 - Descricao
			STR0066,; // 03 - Objetivo
			STR0067,; // 04 - Inicio
			STR0068,; // 05 - Fim
			STR0044,; // 06 - Tipo
			STR0030,; // 07 - Atendimento
			STR0069,; // 08 - Publico
			STR0065,; // 09 - Descricao
			STR0070,; // 10 - Responsavel 
			STR0071,; // 11 - Coordenador 
			STR0072,; // 12 - Departamento 
			STR0073,; // 13 - Meta Camp. 
			STR0074,; // 14 - Meta Oper. 
			STR0075,; // 15 - Custo 
			STR0076,; // 16 - ROI 
			STR0077,; // 17 - % ROI 
			STR0078,; // 18 - Leads Prev. 
			STR0079,; // 19 - % Sucesso 
			STR0080;  // 20 - % Fracasso 
	Size nRight,(nBottom*.25) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Camp:SetArray(aCamp)
oLB01Camp:bLine:={||{	aCamp[oLB01Camp:nAt,1],;
						aCamp[oLB01Camp:nAt,2],;
						aCamp[oLB01Camp:nAt,3],;
						aCamp[oLB01Camp:nAt,4],;
						aCamp[oLB01Camp:nAt,5],;
						aCamp[oLB01Camp:nAt,6],;
						aCamp[oLB01Camp:nAt,7],;
						aCamp[oLB01Camp:nAt,8],;
						aCamp[oLB01Camp:nAt,9],;
						aCamp[oLB01Camp:nAt,10],;
						aCamp[oLB01Camp:nAt,11],;
						aCamp[oLB01Camp:nAt,12],;
						aCamp[oLB01Camp:nAt,13],;
						aCamp[oLB01Camp:nAt,14],;
						aCamp[oLB01Camp:nAt,15],;
						aCamp[oLB01Camp:nAt,16],;
						aCamp[oLB01Camp:nAt,17],;
						aCamp[oLB01Camp:nAt,18],;
						aCamp[oLB01Camp:nAt,19],;
						aCamp[oLB01Camp:nAt,20];
						}}
oLB01Camp:nAt := 1
oLB01Camp:Default()

oLB01Camp:bChange := {||	aCabeca := TKCListBox("SUZ", aEmpCont, nPanel, {Eval(oLB01Camp:bLine)[1]}),;
oLB02Camp:SetArray(aCabeca),;
oLB02Camp:bLine:={||{	aCabeca[oLB02Camp:nAt,1],;
						aCabeca[oLB02Camp:nAt,2],;
						aCabeca[oLB02Camp:nAt,3],;
						aCabeca[oLB02Camp:nAt,4],;
						aCabeca[oLB02Camp:nAt,5],;
						aCabeca[oLB02Camp:nAt,6],;
						aCabeca[oLB02Camp:nAt,7],;
						aCabeca[oLB02Camp:nAt,8],;
						aCabeca[oLB02Camp:nAt,9],;
						aCabeca[oLB02Camp:nAt,10]}},;
						oLB02Camp:nAt := 1,;
						oLB02Camp:Refresh();
						}

oLB02Camp:Default()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Script ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ (nBottom*.3),nLeft	ListBox oLB02Camp Fields;
	Header	STR0082,; // 01 - Script 
			STR0065,; // 02 - Descricao
			STR0083,; // 03 - Tempo
			STR0044,; // 04 - Tipo
			STR0084,; // 05 - Formato
			STR0085,; // 06 - ArmResp 
			STR0086,; // 07 - ScorMin 
			STR0087,; // 08 - ProcMin 
			STR0088,; // 09 - ScorMax 
			STR0089;  // 10 - ProcMax 
	Size nRight,(nBottom*.25) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB02Camp:SetArray(aCabeca)
oLB02Camp:bLine:={||{	aCabeca[oLB02Camp:nAt,1],;
						aCabeca[oLB02Camp:nAt,2],;
						aCabeca[oLB02Camp:nAt,3],;
						aCabeca[oLB02Camp:nAt,4],;
						aCabeca[oLB02Camp:nAt,5],;
						aCabeca[oLB02Camp:nAt,6],;
						aCabeca[oLB02Camp:nAt,7],;
						aCabeca[oLB02Camp:nAt,8],;
						aCabeca[oLB02Camp:nAt,9],;
						aCabeca[oLB02Camp:nAt,10];
						}}
oLB02Camp:nAt := 1
oLB02Camp:Default()
oLB02Camp:bChange := {||	TKC010Brow( "SUP", "S", Eval(oLB02Camp:bLine)[1], oTreeScript ),;
							oTreeScript:Refresh()	}

oTreeScript := DbTree():New((nBottom*.6),nLeft,nBottom,nRight+5, oExplorer:GetPanel(nPanel),,,.T.)

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn14  ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Empresa que contem os dadosº±±
±±º          ³cadastrais da empresa anteriormente selecionada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±º          ³        ³      ³                                              º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn14(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                            // Salva a area atual 
Local nTop     	:= 02													// Coordenadas da tela
Local nLeft    	:= 02
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local aCoord   	:= {}													// Coordenadas da criacao do enchoice MSMGET

Aadd(aCoord, { nTop, nLeft, nBottom, nRight } )
DbSelectArea(aEmpCont[9][3])
MsMGet():New(aEmpCont[9][3],RecNo(),2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn15  ºAutor  ³Armando M. Tessaroliº Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Televendas                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcelo K.³16/11/04³8.11  ³-Revisao do fonte:Sintaxe,Documentacao,Logica º±±
±±ºCleber M. ³17/01/07³115805³-Adequacao para montagem do aCols e aHeader 	º±±
±±º          ³        ³9.12  ³pela FillGetDados (Walk-thru)               	º±±
±±º          ³        ³      ³                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn15(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()                                            // Salva a area atual
Local nTop      := 0													// Coordenadas da tela
Local nLeft     := 0
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local aCoord    := {}													// Array com as coordenadas
Local oLB01Pn17															// Listbox do Cabecalho - SUA	
Local aCabeca   := {}													// Array com os registros do SUA - Cabecalho do atendimento de televendas
Local oGraphic															// Grafico dessa consulta
Local nSerie															// Serie do grafico
Local aSerie    := {}													// Array com as series
Local oFolder															// Folder	
Local nRec      := SUA->(RecNo())										// Flag com o recno do SUA
Local oEnchoice															// Enchoice com o SUA
Local oGetDados															// Getdados com o SUB (itens do atendimento televendas)		
Local nPosHeader														// Contador do aheader
Local oMercadoria														// Objeto GET Total da mercadoria
Local nMercadoria:= 0													// Total da mercadoria
Local oAcrescimo        												// Objeto GET Total do acrescimo
Local nAcrescimo:= 0	                                                // Variavel com o Total do acrescimo 
Local oDespesa															// Objeto GET Total da despesa
Local nDespesa  := 0													// Variavel com o Total da despesa
Local oDesconto															// Objeto GET Total do desconto	
Local nDesconto := 0                                                    // Variavel com o Total do desconto                    
Local oFrete															// Objeto GET Total do frete
Local nFrete    := 0                                                    // Variavel com o Total do frete                 
Local oTotal															// Objeto GET Total do atendimento
Local nTotal    := 0													// Variavel com o Total do atendimento
Local nI 		:= 0 													// Objeto GET Contador auxilar
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSUAExc	:= (X2ModAcess("SUA") == "E")							// Indica se o SUD esta como exclusivo

aCabeca := TKCListBox("SUA", aEmpCont, nPanel)

If Len(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0027,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
	"",;
	STR0090,; //"	01} SUA - Cabeçalho do atendimento televendas"
	STR0091; //"	02) SUB - Produtos do atendimento do televendas"
	})
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SUB"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSUAExc .AND. cFilAnt <> aCabeca[1][14]
			cFilAnt := aCabeca[1][14]
		EndIf
		TkMontaItens( "SUB", aCabeca[1][1], "V" )
		cFilAnt := cFilAtu	
		Aadd(aAllHeader, {"SUB", aHeader})
	EndIf
	
EndIf

Pergunte(cPerg,.F.)	// posiciona no grupo de perguntas

If Empty(Mv_Par04)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O departamento de tecnologia alterou a classe de grafico do   ³
	//³remote, em funcao disso limitou tb a quantidade de graficos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TKC010SD(oExplorer, nPanel, {	STR0001,; // Falta definir o parametro para o tipo de grafico deste painel de informacoes."
									STR0002,; // Os Tipos de Gráficos disponiveis sao:"
									STR0003,; //  	01) GRP_LINE		Codigo GRF01"
									STR0004,; //  	02) GRP_AREA		Codigo GRF02"
									STR0005,; //  	03) GRP_POINT		Codigo GRF03"
									STR0006,; //  	04) GRP_BAR			Codigo GRF04"
									STR0012,; //  	10) GRP_PIE			Codigo GRF10"
									})
	Return(Nil)
Endif

oFolder := TFolder():New(nTop,nLeft,{STR0092,STR0093},{},oExplorer:GetPanel(nPanel),,,,.T.,.F.,nRight,nBottom) //"Sintetico"###"Venda"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Substituir este set pela variavel nSerie ao adicionar o aSerie para criar varias series ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSerie := Val( Mv_Par04 )

Aadd(aSerie, {nSerie, 0, STR0020, 12632256} )	// CLR_HGRAY 	// Televendas 
Aadd(aSerie, {nSerie, 0, STR0094, 16711680} )	// CLR_HBLUE 	// Orcamento 
Aadd(aSerie, {nSerie, 0, STR0095, 16711935} )	// CLR_HMAGENTA // Faturado 
Aadd(aSerie, {nSerie, 0, STR0030, 65280} )	// CLR_HGREEN 	// Atendimento 
Aadd(aSerie, {nSerie, 0, STR0096, 65535} )	// CLR_YELLOW 	// Cancelado  
Aadd(aSerie, {nSerie, 0, STR0097, 255} )		// CLR_RED 		// SigaLoja 
Aadd(aSerie, {nSerie, 0, STR0098, 16777215} )	// CLR_WHITE 	// Bonus 

aSerie := TKC010VP17(aSerie, aEmpCont)			// Carrega os valores nas series criadas para o grafico

TkC010Grap(@oGraphic,05,05,nRight-10,(nBottom * .5)-10,oFolder:aDialogs[1],aSerie)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ (nBottom*.52),nLeft+5	ListBox oLB01Pn17 Fields;
	Header	STR0119,;// 01 - Filial
			STR0038,; // 02 - Codigo 
			STR0040,; // 03 - Operador 
			STR0099,; // 04 - Tabela 
			STR0042,; // 05 - Operacao 
			STR0041,; // 06 - Midia 
			STR0100,; // 07 - Vendedor 
			STR0101,; // 08 - Emissao 
			STR0045,; // 09 - Campanha 
			STR0102,; // 10 - Ocorrencia 
			STR0103,; // 11 - Cond. Pagamento 
			STR0104,; // 12 - Form. Pagamento 
			STR0043,; // 13 - Status 
			STR0105;  // 14 - Transportadora 
	Size nRight-10,(nBottom*.5)-25 NoScroll Of oFolder:aDialogs[1] Pixel

oLB01Pn17:Cargo := "TELEVENDAS"
oLB01Pn17:SetArray(aCabeca)
oLB01Pn17:bLine:={||{	aCabeca[oLB01Pn17:nAt,14],;
						aCabeca[oLB01Pn17:nAt,1],;
						aCabeca[oLB01Pn17:nAt,2],;
						aCabeca[oLB01Pn17:nAt,3],;
						aCabeca[oLB01Pn17:nAt,4],;
						aCabeca[oLB01Pn17:nAt,5],;
						aCabeca[oLB01Pn17:nAt,6],;
						aCabeca[oLB01Pn17:nAt,7],;
						aCabeca[oLB01Pn17:nAt,8],;
						aCabeca[oLB01Pn17:nAt,9],;
						aCabeca[oLB01Pn17:nAt,10],;
						aCabeca[oLB01Pn17:nAt,11],;
						aCabeca[oLB01Pn17:nAt,12],;
						aCabeca[oLB01Pn17:nAt,13]}}
oLB01Pn17:nAt := 1
oLB01Pn17:Default()

oLB01Pn17:bChange := {||	If((lSUAExc .AND. cFilAnt <> Eval(oLB01Pn17:bLine)[1]),(cFilAnt := Eval(oLB01Pn17:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SUA", "E", Eval(oLB01Pn17:bLine)[2] ),;
							oEnchoice:Refresh(),;
							SUA->(DbGoTo(nRec)),;
							nMercadoria:= SUA->UA_VALMERC,;
							oMercadoria:Refresh(),;
							nAcrescimo:= SUA->UA_ACRECND,;
							oAcrescimo:Refresh(),;
							nDespesa:= SUA->UA_DESPESA,;
							oDespesa:Refresh(),;
							nDesconto:= SUA->UA_DESCONT,;
							oDesconto:Refresh(),;
							nFrete:= SUA->UA_FRETE,;
							oFrete:Refresh(),;
							nTotal:= SUA->UA_VLRLIQ,;
							oTotal:Refresh(),;
							nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SUB"}),;
							aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "SUB"})][2])),;
							TkMontaItens( "SUB", Eval(oLB01Pn17:bLine)[2], "V" ),;
							oGetDados:oBrowse:Refresh(),;
							cFilAnt := cFilAtu	}
						
If Type("aDados") == "A"
	aDados[3] := aCabeca
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um Enchoice tipo MsMGet Read Only do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCoord, { nTop+5, nLeft+5, nBottom*.355, nRight-5 } )

If lSUAExc .AND. cFilAnt <> aCabeca[1][14]
	cFilAnt := aCabeca[1][14]
EndIf

nRec := TKC010Brow( "SUA", "E", aCabeca[1][1] )
oEnchoice := MsMGet():New("SUA",nRec,2,,,,,aCoord[1],,3,,,,oFolder:aDialogs[2],,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um browser tipo MSGetDados Read Only dos itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MSGetDados():New((nBottom*.37),nLeft+5,(nBottom*.65),nRight-6,2,"","","",.T.,,,.F.,,,,,,oFolder:aDialogs[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria dois folders com os inpostos e valores totais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFdImp := TFolder():New(nBottom*.66,nLeft+5,{STR0106,STR0107},{},oFolder:aDialogs[2],,,,.T.,.F.,nRight-10,nBottom*.26) //"Totais"###"Impostos"

@ nBottom*.018,nRight*.0123 SAY STR0108 OF oFdImp:aDialogs[1] PIXEL SIZE 55,9 //"Valor Mercadoria"
@ nBottom*.018,nRight*.16 MSGET oMercadoria VAR nMercadoria Picture PesqPict("SUA","UA_VALMERC") OF oFdImp:aDialogs[1] PIXEL When .F. SIZE 70 ,9

@ nBottom*.068,nRight*.0123 SAY STR0109 OF oFdImp:aDialogs[1] PIXEL SIZE 58,9 //"Acrescimo"
@ nBottom*.068,nRight*.16 MSGET oAcrescimo VAR nAcrescimo Picture PesqPict("SUA","UA_ACRECND") OF oFdImp:aDialogs[1] PIXEL When .F. SIZE 70 ,9

@ nBottom*.118,nRight*.0123 SAY STR0110 OF oFdImp:aDialogs[1] PIXEL SIZE 50,9 //"Despesas"
@ nBottom*.118,nRight*.16 MSGET oDespesa VAR nDespesa Picture PesqPict("SUA","UA_DESPESA") OF oFdImp:aDialogs[1] PIXEL When .F. SIZE 70 ,9

@ nBottom*.018,nRight*.5123 SAY STR0111 OF oFdImp:aDialogs[1] PIXEL SIZE 49,9 //"Descontos"
@ nBottom*.018,nRight*.66 MSGET oDesconto VAR nDesconto Picture PesqPict("SUA","UA_DESCONT") OF oFdImp:aDialogs[1] PIXEL When .F. SIZE 70 ,9

@ nBottom*.068,nRight*.5123 SAY STR0112 OF oFdImp:aDialogs[1] PIXEL SIZE 45,9 //"Valor do Frete"
@ nBottom*.068,nRight*.66 MSGET oFrete VAR nFrete Picture PesqPict("SUA","UA_FRETE") OF oFdImp:aDialogs[1] PIXEL When .F. SIZE 70 ,9

@ nBottom*.118,nRight*.5123 SAY STR0113 OF oFdImp:aDialogs[1] PIXEL SIZE 58,9 COLOR CLR_RED //"Total do Pedido"
@ nBottom*.118,nRight*.66 MSGET oTotal VAR nTotal Picture PesqPict("SUA","UA_VLRLIQ") OF oFdImp:aDialogs[1] PIXEL When .F. SIZE 70 ,9 COLOR CLR_RED

MaFisRodape(1,oFdImp:aDialogs[2],,{nBottom*.018,nRight*.0123,nRight-20,nBottom*.15},,.F.)

cFilAnt := cFilAtu

Eval(oLB01Pn17:bChange)
oEnchoice:Refresh()
RestArea(aArea)

Return(Nil)


/*                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkCargaTmk   ³ Autor ³ Luis Marcelo Kotaki ³ Data ³ 20/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os items gravados de cada ligacao selecionada        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³Perfil do Contato													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkC10CargaTmk(	oGetHist	,cCodLig	,cObsMemo	,;
						oObsMemo	,cEnceMemo	,oEnceMemo	,;
						cCancMemo	,oCancMemo)

Local aFirst[1][Len(aHeader)+1]		// Inicializa o array do aHeader
Local aArea 	:= GetArea()		// Salva a area atual

aCols := aClone(aFirst)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o acols com os itens da ligacao selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkMontaItens("SUD",cCodLig,"M")

oGetHist:oBrowse:Refresh()

DbSelectarea("SUC")
DbSetorder(1)
If DbSeek(xFilial("SUC")+cCodLig)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrego a observa‡„o da liga‡„o 							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cObsMemo:= ""
	cObsMemo:= MSMM(SUC->UC_CODOBS,TamSx3("UC_OBS")[1])
	oObsMemo:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o motivo do encerramento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEnceMemo:= ""
	cEnceMemo:= MSMM(SUC->UC_CODMOT,TamSx3("UC_OBSMOT")[1])
	oEnceMemo:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o motivo do cancelamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCancMemo:= ""
	cCancMemo:= MSMM(SUC->UC_CODCANC,TamSx3("UC_OBSCANC")[1])
	oCancMemo:Refresh()
Endif	

RestArea(aArea)

Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10ScrDm

Consulta Scripts Dinâmicos.

@sample 	Tkc10ScrDm(oDlg)

@param		ExpO1 Objeto do tipo Janela. 

@return	ExpL Verdadeiro 

@author	Anderson Silva
@since		03/07/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function Tkc10ScrDm(oDlg,cEntidade,cChave,cCodCont)

Local oFWLayer     	:= Nil												// Layer da tela
Local oBrowse		:= Nil												// Browse da lista de scripts executados
Local aScripts		:= Tkc10RtScr(cEntidade,cChave,cCodCont)			// Array dos scripts executados
Local aSize			:= {}												// Array com as dimensoes da tela
Local oDlgIdScr		:= Nil												// Dialog do grid de scripts executados
Local oDlgIdScrR	:= Nil												// Dialog das perguntas e respostas do script executado
Local oDlgIdGraf	:= Nil												// Dialog do gráfico de score
Local oColumns	   	:= Nil												// Colunas do grid de scripts executados
Local oTSEditor		:= Nil												// Objeto editor de texto das perguntas e resposta do script
Local aSerie 		:= {}												// Array com as series do grafico
Local oGraphic 		:= Nil												// Objeto grafico
Local oPnlSair		:= Nil												// Panel do botão sair
Local oBtnSair		:= Nil												// Botão sair
Local nX			:= 0												// Variavel de incremento 
Local aObsFields	:= {}												// Campos Ofuscados do Browse

Default oDlg 			:= Nil	
Default cEntidade		:= ""
Default cChave			:= ""
Default cCodCont		:= ""

/*Instancia a dialog dentro do define*/
If oDlg == Nil
	aSize := FWGetDialogSize( oMainWnd ) 
	DEFINE DIALOG oDlg TITLE STR0120 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL // "Scripts de Atendimento"
EndIf

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.)

/*Cria o grid dos Scripts Executados*/
oFWLayer:AddLine("LINETOP",50,.T.)
oFWLayer:AddCollumn("SCRIPTS",100,.T.,"LINETOP")
oDlgIdScr := oFWLayer:getColPanel("SCRIPTS","LINETOP")

If Empty(cCodCont) .AND. ( !Empty(cEntidade) .AND. !Empty(cChave) )
	aObsFields	:= {"U5_CONTAT"}
Elseif !Empty(cCodCont) .AND. ( Empty(cEntidade) .AND. Empty(cChave) )
	aObsFields	:= {"A1_NOME"}
Endif

DEFINE FWFORMBROWSE oBrowse DATA ARRAY ARRAY aScripts DESCRIPTION STR0121 LINE BEGIN 1 CHANGE {|| IIF(ValType(oTSEditor) == "O",oTSEditor:Load(aScripts[oBrowse:At()][16]),Nil) }OF oDlgIdScr // "Scripts Dinâmicos"

	If Len(aObsFields) > 0
		oBrowse:SetObfuscFields(aObsFields)
	EndIf

	/*Adiciona colunas da tabela dos indicadores de conversao*/
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][1] }") TITLE STR0122 SIZE 6		ID "UZ_CODSCRI" OF oBrowse  	// "Cod.Script"
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][2] }") TITLE STR0123 SIZE 30	ID "UZ_DESC"	OF oBrowse   	// "Descrição"
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][3] }") TITLE STR0124 SIZE 8 	ID "ACI_DATA" 	OF oBrowse     	// "Dt.Exec"
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][4] }") TITLE STR0125 SIZE 5 	ID "UK_SCORE" 	OF oBrowse 		// "Score"
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][5]}")  TITLE STR0126 SIZE 6 	ID "UO_CODCAMP" OF oBrowse 		// "Cod.Camp"
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][6]}")  TITLE STR0127 SIZE 30	ID "UO_DESC" 	OF oBrowse		// "Descrição"
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][7]}")  TITLE STR0128 SIZE 6 	ID "ACI_ATEND" 	OF oBrowse		// "Cod.Atend"
	ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][9]}")  TITLE STR0129 SIZE 10	ID "ACI_ROTINA" OF oBrowse  	// "Tipo Atend"
	
	If Empty(cCodCont) .AND. ( !Empty(cEntidade) .AND. !Empty(cChave) )
		ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][10]}")  TITLE STR0130 SIZE 6  ID "ACI_CODCON"	OF oBrowse	//	"Contato"
		ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][11]}")  TITLE STR0131 SIZE 10 ID "U5_CONTAT"	OF oBrowse	// "Nome"
	EndIf
	
	If !Empty(cCodCont) .AND. ( Empty(cEntidade) .AND. Empty(cChave) )
		ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][12]}")  TITLE STR0132 SIZE 6 ID "ACI_ENTIDA" 	OF oBrowse		// "Entidade"
		ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][13]}")  TITLE STR0133 SIZE 6 ID "A1_COD" 		OF oBrowse		// "Cod. Entidade"
		ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][14]}")  TITLE STR0134 SIZE 6 ID "A1_LOJA" 		OF oBrowse		// "Loja"
		ADD COLUMN oColumns DATA &("{ || aScripts[oBrowse:At()][15]}")  TITLE STR0135 SIZE 6 ID "A1_NOME" 		OF oBrowse		// "Nome Entidade" 
	EndIf
	
	oBrowse:AddButton(STR0136,{|| IIF(!Empty(aScripts[oBrowse:At()][7]),Tkc10VAtd(aScripts[oBrowse:At()][7],aScripts[oBrowse:At()][8]),Nil) },,,,.F.,2) // "Atendimento"
	oBrowse:AddButton(STR0137,{|| IIF(!Empty(aScripts[oBrowse:At()][5]),Tkc10VCamp(aScripts[oBrowse:At()][5]),Nil) },,,,.F.,2) 	 						 // "Campanha"
	
	If Empty(cCodCont) .AND. ( !Empty(cEntidade) .AND. !Empty(cChave) )
		oBrowse:AddButton(STR0130,{|| IIF(!Empty(aScripts[oBrowse:At()][5]),Tkc10VCont(aScripts[oBrowse:At()][10]),Nil)},,,,.F.,2)	// "Contato"
	EndIf
	
ACTIVATE FWFORMBROWSE oBrowse

/*Cria dialog perguntas e respostas*/
oFWLayer:AddLine("LINECENTER",46,.T.)
oFWLayer:AddCollumn("SCR_PERXRES",50,.F.,"LINECENTER")
oFWLayer:AddWindow("SCR_PERXRES","oDlgIdSrcR",STR0138,100,.F.,.F.,,"LINECENTER")	// "Perguntas x Respostas"
oDlgIdSrcR := oFWLayer:getWinPanel("SCR_PERXRES","oDlgIdSrcR" ,"LINECENTER" )

oTSEditor := TSimpleEditor():New(0,0,oDlgIdSrcR,0,0,/*cText*/,.F.)
oTSEditor:Align := CONTROL_ALIGN_ALLCLIENT		
oTSEditor:Load(aScripts[oBrowse:At()][16]) //Carrega o script na criação do componente.

oFwLayer:SetColSplit("SCR_PERXRES",CONTROL_ALIGN_RIGHT,"LINECENTER",{|| IIF(ValType(oGraphic)=="O",(FreeObj(oGraphic),;
TkC010Grap(@oGraphic,0,0,(oDlgIdGraf:nRight/2),(oDlgIdGraf:nBottom/2)-15,oDlgIdGraf,aSerie)),Nil)})

/*Cria dialog gráfico*/
oFWLayer:AddCollumn("GRAFICO",51,.F.,"LINECENTER")
oFWLayer:AddWindow("GRAFICO","oDlgIdGraf",STR0125,100,.F.,.F.,,"LINECENTER")	// "Score"
oDlgIdGraf := oFWLayer:getWinPanel("GRAFICO","oDlgIdGraf" ,"LINECENTER" )

/*Adiciona as series do grafico*/
For nX:=1 to Len(aScripts)
	Aadd(aSerie, {Val(MV_PAR03), aScripts[nX,4], Capital(aScripts[nX,2])  } ) 
Next	

/*Função para gerar grafico*/		
TkC010Grap(@oGraphic,0,0,(oDlgIdGraf:nRight/2),(oDlgIdGraf:nBottom/2)-15,oDlgIdGraf,aSerie)
	
If Valtype(oDlg) == "O" .AND. oDlg:ClassName() == "TDIALOG" 
	/*Reservado para botao sair*/
	oFWLayer:AddLine("LINEBOTTOM",4,.T.)
	oFWLayer:AddCollumn("SAIRTKC010",100,.T.,"LINEBOTTOM")
	oPnlSair := oFWLayer:GetColPanel("SAIRTKC010","LINEBOTTOM")
	@001,(oPnlSair:nWidth/2)-43 BUTTON oBtnSair PROMPT STR0139 SIZE 040, 012 OF oPnlSair ACTION oDlg:End() PIXEL //"Sair"
	
	ACTIVATE DIALOG oDlg CENTERED
EndIf

Return( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10RtScr

Monta array dos scripts executados.

@sample		Tkc10RtScr()

@param			cEntidade	- Código da entidade
				cChave		- Codigo da entidade + codigo da loja
				cCodCont	- Código do contato						

@return		Array dos scrits executados

@author		Aline Kokumai
@since			03/07/2013
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function Tkc10RtScr(cEntidade,cChave,cCodCont)  

Local cQuery		:= ""														//Query dos scrits executados
Local cAlias		:= GetNextAlias()											//Alias atual
Local aScripts		:= {}														//Array dos scrits executados
Local nTotScr		:= 0														//Total do score
Local aCampos		:=	{{"SA1","A1_COD","A1_LOJA","A1_NOME"},; 				//Array auxiliar para bucar dados (posicione)
						 {"ACH","ACH_CODIGO","ACH_LOJA","ACH_RAZAO"},;
						 {"SUS","US_COD","US_LOJA","US_NOME"}}
Local nPosEnt		:= 0														//Auxiliar para posicionar no array aCampos
Local cCodEnt		:= ""														//Codigo da entidade para buscar dados (posicione)
Local cLojaEnt		:= ""														//Loja da entidade para buscar dados (posicione)
Local lEntidade   	:= .F.														//Logica para condicao de busca contato ou empresa 

Default cEntidade	:= ""
Default cChave		:= ""
Default cCodCont	:= ""

#IFDEF TOP 

	/*Executa query para buscar scripts executados*/
	cQuery :=	"SELECT SUZ.UZ_CODSCRI SCRIPT "
	cQuery +=	"	  ,SUZ.UZ_DESC DESCSCR "		
	cQuery +=	"	  ,ACI.ACI_DATA DTEXEC "
	cQuery +=	"	  ,(SELECT SUM(SUK.UK_SCORE) FROM "+RetSqlName("SUK")+ " SUK WHERE SUK.UK_FILIAL='"+xFilial("SUK")+"' AND SUK.UK_CODIGO=ACI.ACI_CODIGO AND SUK.D_E_L_E_T_ = ' ' ) SCORE "
	cQuery +=	"	  ,SUO.UO_CODCAMP	 CODCAMP "
	cQuery +=	"	  ,SUO.UO_DESC	 DESCAMP "
	cQuery +=	"	  ,ACI.ACI_ATEND	 ATDTMK "
	cQuery +=	"	  ,ACI.ACI_CODCON	 CODCONT "
	cQuery +=	"	  ,SU5.U5_CONTAT	 NOMCONT "
	cQuery +=	"	  ,ACI.ACI_ENTIDA	 ENTIDA "
	cQuery +=	"	  ,ACI.ACI_CHAVE	 CHAVE " 
	cQuery +=	"	  ,ACI.ACI_ROTINA	 ROTINA "
	cQuery +=	"	  ,ACI.ACI_CODIGO	 CODIGO " 
	cQuery +=	"FROM "+RetSqlName("ACI")+" ACI "			
	cQuery +=	"INNER JOIN "+ RetSqlName("SUZ")+" SUZ ON SUZ.UZ_FILIAL='"+xFilial("SUZ")+"' AND SUZ.UZ_CODSCRI=ACI.ACI_CODSCR AND SUZ.D_E_L_E_T_ = ' ' "
	cQuery +=	"INNER JOIN "+ RetSqlName("SUO")+" SUO ON SUO.UO_FILIAL='"+xFilial("SUO")+"' AND SUO.UO_CODCAMP=ACI.ACI_CODCAM AND SUO.D_E_L_E_T_ = ' ' "
	cQuery +=	"INNER JOIN "+ RetSqlName("SU5")+" SU5 ON SU5.U5_FILIAL='"+xFilial("SU5")+"' AND SU5.U5_CODCONT=ACI.ACI_CODCON AND SU5.D_E_L_E_T_ = ' ' "
	cQuery +=	"WHERE ACI.ACI_FILIAL='"+xFilial("ACI")+"' AND ACI.D_E_L_E_T_ = ' '"
	
	If !Empty(cEntidade) .AND. !Empty(cChave) .OR. !Empty(cCodCont)
		
		/*Adiciona colunas do contato caso seja o perfil do cliente*/
		If !Empty(cEntidade) .AND. !Empty(cChave)
			cQuery +=  "AND ACI.ACI_ENTIDA='"+ cEntidade +"' "
			cQuery +=  "AND ACI.ACI_CHAVE='"+  cChave +"' "
		EndIf
		
		If !Empty(cCodCont)
			cQuery +=  "AND ACI.ACI_CODCON='"+cCodCont+"' "
		EndIf
	Else
		/*Força retorno do vazio.*/
		cQuery += "AND 1 > 2"
	EndIf	

	IIF(Select(cAlias)>0,(cAlias)->(DbCloseArea()),Nil)
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
		/*Alimenta array com resultado da query*/
		While (cAlias)->(!Eof())
			nPosEnt 	:= aScan(aCampos,{|x| x[1]==(cAlias)->ENTIDA}) //Retorna a linha do aCampos

			If nPosEnt > 0

				cCodEnt 	:= SubStr((cAlias)->CHAVE,1,TamSX3(aCampos[nPosEnt,2])[1])											//Codigo da entidade
				cLojaEnt 	:= SubStr((cAlias)->CHAVE,TamSX3(aCampos[nPosEnt,2])[1]+1,TamSX3(aCampos[nPosEnt,3])[1])		//Loja da entidade
								
				AAdd(aScripts, {(cAlias)->SCRIPT																				,; //Codigo do script
								 AllTrim((cAlias)->DESCSCR)													 					,; //Descrição do script
								 Stod((cAlias)->DTEXEC)																			,; //Data da execução
								 (cAlias)->SCORE																					,; //Score
								 (cAlias)->CODCAMP																				,; //Código da campanha
								 (cAlias)->DESCAMP																				,; //Descrição da campanha
								 (cAlias)->ATDTMK																					,; //Código do atendimento
								 (cAlias)->ROTINA																					,; //Codigo da rotina (1=tlmkt,2=televenda,3=telecobranca,4=teleatendimento)
								 IIF((cAlias)->ROTINA	=="1",STR0140,IIF((cAlias)->ROTINA=="2",STR0141,IIF((cAlias)->ROTINA=="3",STR0142,STR0143))),; //Descrição da rotina ("Telemarketing",televenda,telecobranca,teleatendimento)	
								 (cAlias)->CODCONT																				,; //Código do contato
								 AllTrim((cAlias)->NOMCONT)																		,; //Nome do contato						 						 
								 IIF((cAlias)->ENTIDA=="SA1",STR0144,IIF((cAlias)->ENTIDA=="SUS",STR0145,STR0146))				,; //Descrição da entidade "Cliente"#"Prospect"#"Suspect"
								 cCodEnt 																							,; //Codigo da entidade
								 cLojaEnt																							,; //Loja da entidade
								 Posicione(aCampos[nPosEnt,1],1,xFilial(aCampos[nPosEnt,1])+cCodEnt+cLojaEnt,aCampos[nPosEnt,4])	,; //Nome da entidade
								 Tkc10MScr((cAlias)->CODIGO) }) 																			   //Script de perguntas e respostas
				(cAlias)->(DbSkip()) 
				
			EndIf
			
		EndDo
		
#ELSE //DBF
		
	DbSelectArea("ACI") //Campanhas Executadas
	DbSetOrder(1)
	
	/*Seta condição de acordo com os parametros informados*/
	If !Empty(cEntidade) .AND. !Empty(cChave) .OR. !Empty(cCodCont)
		
		If !Empty(cEntidade) .AND. !Empty(cChave)
			cCondicao := "ACI->ACI_ENTIDA+AllTrim(ACI->ACI_CHAVE) == '"+(cEntidade+cChave)+"'" //Perfil do cliente
			lEntidade := .T.
		EndIf
		
		If !Empty(cCodCont)
			If lEntidade
				cCondicao += " .AND. ACI->ACI_CODCON == '"+(cCodCont)+"'" //Perfil do contato
			Else
				cCondicao += " ACI->ACI_CODCON == '"+(cCodCont)+"'" //Perfil do contato de todas entidades relacionadas
			EndIf	
		EndIf		
		 
	EndIf		 
		
	If ACI->(DbSeek(xFilial("ACI"))) 
		
		While ACI->(!Eof() .AND. ACI->ACI_FILIAL == xFilial("ACI")) 		
			
			If &(cCondicao) 
			
				If(SUK->(dbSeek(xFilial("SUK")+ACI->ACI_CODIGO)))
								
					While SUK->(!Eof() .AND. SUK->UK_CODIGO==ACI->ACI_CODIGO)
						nTotScr+=SUK->UK_SCORE
						SUK->(DbSkip())												
					EndDo
						
					nPosEnt 	:= aScan(aCampos,{|x| x[1]==ACI->ACI_ENTIDA}) //Retorna a linha do aCampos
					
					If nPosEnt > 0
					
						cCodEnt 	:= SubStr(ACI->ACI_CHAVE,1,TamSX3(aCampos[nPosEnt,2])[1])
						cLojaEnt 	:= SubStr(ACI->ACI_CHAVE,TamSX3(aCampos[nPosEnt,2])[1]+1,TamSX3(aCampos[nPosEnt,3])[1])
						 				
						AAdd(aScripts,	{	ACI->ACI_CODSCR																,;//Codigo do script
												Posicione("SUZ",1,xFilial("SUZ")+AllTrim(ACI->ACI_CODSCR),"UZ_DESC")	,;//Descrição do script
												ACI->ACI_DATA																	,;//Data da execução
												nTotScr																		,;//Score
												ACI->ACI_CODCAM																,;//Código da campanha
												Posicione("SUO",1,xFilial("SUO")+AllTrim(ACI->ACI_CODCAM),"UO_DESC")	,;//Descrição da campanha
												ACI->ACI_ATEND																,;//Código do atendimento
												ACI->ACI_ROTINA																,;//Código da rotina (1=tlmkt,2=televenda,3=telecobranca,4=teleatendimento)
												IIF(ACI->ACI_ROTINA=="1",STR0140,IIF(ACI->ACI_ROTINA=="2",STR0141,IIF(ACI->ACI_ROTINA=="3",STR0142,STR0143))),; //Descrição da rotina ("Telemarketing",televenda,telecobranca,teleatendimento)
												ACI->ACI_CODCON																,;//Código do contato
												Posicione("SU5",1,xFilial("SU5")+ACI->ACI_CODCON,"U5_CONTAT")			,;//Nome do contato	
												IIF(ACI->ACI_ENTIDA=="SA1",STR0144,IIF(ACI->ACI_ENTIDA=="SUS",STR0145,STR0146)),;//Descrição da entidade
												cCodEnt																		,;//Codigo da entidade
												cLojaEnt																		,;//Loja da entidade
												Posicione(aCampos[nPosEnt,1],1,xFilial(aCampos[nPosEnt,1])+cCodEnt+cLojaEnt,aCampos[nPosEnt,4]),;//Nome da entidade
												Tkc10MScr(ACI->ACI_CODIGO) })												 //Script de perguntas e respostas																	
					EndIf	
				EndIf
			EndIf
		ACI->(DbSkip())
		EndDo
	EndIf

#ENDIF
	
	/*Alimenta primeira posicao do array com valores vazios*/
	If Len(aScripts) == 0
		aAdd(aScripts,{"","",cTod("//"),0,"","","","","","","","","","","",""})
	EndIf

Return aScripts

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10MScr

Monta texto em html com as perguntas e respostas do script executado na campanha

@sample		Tkc10MScr(cCodExec)

@param			cCodExec: Código de execução da campanha						

@return		html das perguntas e respostas

@author		Aline Kokumai
@since			03/07/2013
@version		P12
/*/
//------------------------------------------------------------------------------
Function Tkc10MScr(cCodExec)

Local cQuery		:= ""					//Query das respostas do script executado
Local cAlias		:= GetNextAlias()		//Alias atual
Local aRespostas	:= {}					//Array perguntasXrepostas
Local nScore		:= 0					//Totalizador do score
local cFlagPerg		:= ""					//Flag indicador da pergunta inserida no texto de retorno
Local cTexto		:= ""					//Texto de retorno das perguntas e respostas
Local aPerg			:= {}					//Array contendo o tipo e descricao da pergunta
Local aResp			:= {}					//Array contendo a descricao da resposta
Local cResposta		:= ""					//Texto com a descricao da resposta
Local nX			:= 0					//Variavel de incremento

				


#IFDEF TOP
/*Executa query para buscar perguntas e resposta do script executado*/
cQuery :=  "SELECT SUK.UK_CODIGO ExecucaoCampanha "+;
			"	 , SUP.UP_TIPOOBJ Tipo "+;
			"	 , SUP.UP_DESC Pergunta "+;
			"	 , CASE "+;
			"			WHEN SUP.UP_TIPOOBJ='3' THEN 'Tkc10ScRep' "+;
			"			ELSE SUP1.UP_DESC "+;
			"		END Resposta"+;
			"	 , SUK.UK_COMPRES Complemento "+;
			"	 , SUP1.UP_SCORE Score "+;
			"	 , ACI.ACI_DATA DataExecucao "+;
			"	 , SUK.UK_CODPERG CODPERG "+;
			"	 , SUK.UK_CODRESP CODRESP "+; 	 
			"FROM "+ RetSqlName("SUK")+" SUK "+; 
			"INNER JOIN "+ RetSqlName("ACI")+" ACI ON ACI.ACI_FILIAL='"+xFilial("ACI")+"' AND ACI.ACI_CODIGO=SUK.UK_CODIGO AND ACI.D_E_L_E_T_ <> '*' "+;
			"LEFT JOIN  "+ RetSqlName("SUP")+" SUP ON SUP.UP_FILIAL='"+xFilial("SUP")+"' AND ACI.ACI_CODSCR=SUP.UP_CODCAMP AND UK_CODPERG=SUP.UP_CARGO AND SUP.D_E_L_E_T_<> '*' "+;
			"LEFT JOIN  "+ RetSqlName("SUP")+" SUP1 ON SUP1.UP_FILIAL='"+xFilial("SUP")+"' AND ACI.ACI_CODSCR=SUP1.UP_CODCAMP AND UK_CODRESP=SUP1.UP_CARGO AND SUP1.D_E_L_E_T_<> '*' "+;
			"WHERE SUK.UK_FILIAL='"+xFilial("SUK")+"' "+;
			"	AND SUK.UK_CODIGO='"+cCodExec+"' "+;
			"	AND SUK.D_E_L_E_T_<>'*' "+;
			"GROUP BY SUK.UK_CODIGO "+;
			"		,SUP.UP_TIPOOBJ "+;
			"		,SUP.UP_DESC "+;
			"		,UK_CODMEMO "+;
			"		,SUP1.UP_DESC "+;
			"		,SUK.UK_COMPRES "+;
			"		,SUP1.UP_SCORE "+;
			"		,ACI.ACI_DATA "+;
			"		,SUP.R_E_C_N_O_"+;
			"		,SUP1.R_E_C_N_O_ "+;
			"		,SUK.UK_CODPERG "+;
			"		,SUK.UK_CODRESP "+;
			"ORDER BY SUP.R_E_C_N_O_,SUP1.R_E_C_N_O_ ASC"		

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	/*Alimenta array com resultado da query*/
	While (cAlias)->(!Eof())
		AAdd(aRespostas,{	(cAlias)->Tipo													,;	//Tipo de pergunta 1=unica escolha, 2=multipla escolha, 3=dissertativa
							(cAlias)->Pergunta												,;	//Descricao da pergunta
							IIF(Empty((cAlias)->Complemento),"",(cAlias)->Complemento)	,;	//Complemento da resposta
							IIF(Alltrim((cAlias)->Resposta)=="Tkc10ScRep",Tkc10ScRep(cCodExec,(cAlias)->CODPERG,(cAlias)->CODRESP),(cAlias)->Resposta),;	//Descricao da resposta
							(cAlias)->Score })													//Score da resposta
		
		(cAlias)->(DbSkip())
	EndDo
	
#ELSE //DBF

	DbSelectArea("SUK")
	DbSetOrder(1)
	
	DbSelectArea("SUP")
	DbSetOrder(2)
	
	nTamMemo := TAMSX3("UK_RESMEMO")[1]

	If SUK->(DbSeek(xFilial("SUK")))  
		
		While SUK->(!Eof())
		
			If (SUK->UK_FILIAL == xFilial("SUK") .AND. SUK->UK_CODIGO == cCodExec) 
		
				aPerg 		:= Tkc10RSUP(ACI->ACI_CODSCR,SUK->UK_CODPERG) //Busca tipo e descricao da pergunta 
				aResp 		:= Tkc10RSUP(ACI->ACI_CODSCR,SUK->UK_CODRESP) //Busca descricao da resposta
				cResposta  := IIF(aPerg[1] == "3",MSMM(SUK->UK_CODMEMO,nTamMemo),aResp[2])	 //Se pergunta dissertativa, busca resposta no memo
				/*Alimenta array com resultado das buscas*/				 				
				AAdd(aRespostas,	{	aPerg[1]					,;	//Tipo de pergunta 1=unica escolha, 2=multipla escolha, 3=dissertativa
										aPerg[2]					,;	//Descricao da pergunta
										AllTrim(SUK->UK_COMPRES),;	//Complemento da resposta
										cResposta					,;	//Complemento da resposta
										SUK->UK_SCORE})				//Score da resposta
			EndIf			
			SUK->(DbSkip())		
		EndDo
				
	EndIf
	
#ENDIF
	
	/*Monta texto de peruntas e resposta em HTML*/
	cTexto += "<table>"
	For nX := 1 to Len(aRespostas)
		/*Unica Escolha*/
		If(aRespostas[nX][1]=="1")
			cTexto += "<tr><td width=100%><font size=3 color=blue><b>"+STR0147+"</b></font><font size=3 color=Black><b>"+ aRespostas[nX][2]+ "</b></font><br>" 		// "Pergunta: "  
			cTexto += "<font size=3 color=grey><b>"+STR0148+"</b></font><font size=3 color=Black><b>"+ aRespostas[nX][4]+ "</font><br>"							// "Resposta: "
			If (!Empty(aRespostas[nX][3]))
				cTexto += "<font size=3 color=grey><b>"+STR0149+"</b><font size=3 color=Black><b>"+ aRespostas[nX][3]+ "</font><br>"								// "Complemento: "    
			EndIf
			cTexto += "<font size=3 color=Black><b>"+STR0150+"</b></font><font size=3 color=Black><b>"+ cValToChar(aRespostas[nX][5])+ "</b></font><br><br></td></tr>" 	// "Score: "
		/*Multipla Escolha*/
		ElseIf (aRespostas[nX][1]=="2")
			cTexto += "<tr><td width=100%> 
			If(aRespostas[nX][2]!=cFlagPerg)
				cTexto += "<font size=3 color=blue><b>"+STR0151+"</b></font><font size=3 color=Black><b>"+ aRespostas[nX][2]+ "</b></font><br>" 					// "Pergunta (Multipla Escolha): "      
				cFlagPerg:= aRespostas[nX][2]
			EndIf			
			cTexto += "<font size=3 color=grey><b>"+STR0148+"</b></font><font size=3 color=Black><b>"+ aRespostas[nX][4]+ "</font><br>" 							// "Resposta: "
			If (!Empty(aRespostas[nX][3]))
				cTexto += "<font size=3 color=grey><b>"+STR0149+"</b><font size=3 color=Black><b>"+ aRespostas[nX][3]+ "</font><br>"								// "Complemento: "  
			EndIf
			cTexto += "<font size=3 color=Black><b>"+STR0150+"</b></font><font size=3 color=Black><b>"+ cValToChar(aRespostas[nX][5])+ "</font><br><br></td></tr>"  		// "Score: "
		/*Dissertativa*/
		ElseIf (aRespostas[nX][1]=="3") 
			cTexto += "<tr><td width=100%><font size=3 color=blue><b>"+STR0147+"</b></font><font size=3 color=Black><b>"+ aRespostas[nX][2]+ "</b></font><br>"						// "Pergunta: " 
			cTexto += "<font size=3 color=grey><b>"+STR0148+"</b></font><font size=3 color=Black><b>"+ aRespostas[nX][4]+ "</font><br><br></td></tr>" 						// "Resposta: "
		EndIf
			/*Calcula score total*/	
			nScore += aRespostas[nX][5]	
	Next nX 
		cTexto += "<tr><td width=100%><font size=3 color=red><b>"+STR0152+"</b></font><font size=3 color=black><b>"+ cValToChar(nScore)+ "</b></font><br></td></td></tr></table>" 						// "Total do Score: "     
	
Return cTexto

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10RSUP

Busca descricao da pergunta e reposta na tabela SUP

@sample		Tkc10RSUP(cCodScr,cCodigo)

@param			cCodScr: Código do script dinamico
				cCodigo: Código de execução da campanha						

@return		Nulo

@author		Anderson Silva
@since			08/07/2013
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function Tkc10RSUP(cCodScr,cCodigo)
Local aArea			:= GetArea()
Local aAreaSUP		:= SUP->(GetArea())
Local aRet			:= {}

If SUP->(DbSeek(xFilial("SUP")+cCodScr+cCodigo))
	aRet := {SUP->UP_TIPOOBJ,SUP->UP_DESC}	
EndIf

RestArea(aAreaSUP)
RestArea(aArea)	 

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10VCont

Visualiza cadastro do contato

@sample		Tkc10VCont(cCodCont)

@param			cCodCont: Código do contato						

@return		Nulo

@author		Aline Kokumai
@since			03/07/2013
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function Tkc10VCont(cCodCont)

Local aArea 	:= GetArea()
Local aAreaSU5 	:= SU5->(GetArea())

Private aRotina 	:= {{ STR0153 ,"A70Visual"  , 0 , 2 , , .T. }}	// "Visualizar"
Private cCadastro 	:= STR0154 										// "Contatos - VISUALIZAR"			
Private INCLUI 		:= .F.

DbSelectArea("SU5")
DbSetOrder(1)

If DbSeek(xFilial("SU5")+cCodCont)
	A70Visual("SU5",SU5->(RecNo()),1)
EndIf

RestArea(aAreaSU5)
RestArea(aArea) 

Return Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10VCamp

Visualiza o cadastro de campanha.

@sample		Tkc10VCamp(cCampanha)

@param			ExpC1 Código da Campanha					

@return		Nulo

@author		Anderson Silva	
@since			04/07/2013
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function Tkc10VCamp(cCampanha) 

Local aArea 	:= GetArea()
Local aAreaSUO 	:= SUO->(GetArea())

Private cCadastro 	:= STR0155												// "Campanha - VISUALIZAR" 
Private INCLUI 		:= .F.
Private aRotina 	:= {	{ STR0156 ,"AxPesqui"   		, 0 , 1 , , .F.},; 	    // "Pesquisar"
							{ STR0153 ,"VIEWDEF.TMKA310"  	, 0 , 2 , , .T. } } 	// "Visualizar"
DbSelectArea("SUO")
DbSetOrder(1)

If DbSeek(xFilial("SUO")+cCampanha)
	FWExecView( STR0177, "TMKA310", 1 )//"Informações de Campanha" ## Visualizar
EndIf

RestArea(aAreaSUO)
RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10VAtd

Visualiza o atendimento no Call Center.

@sample		Tkc10VAtd(cCodAtd)

@param		ExpC1 Código do Atendimento					

@return		Nulo

@author		Anderson Silva	
@since		04/07/2013
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function Tkc10VAtd(cCodAtd,cTipoAtd)

Local aArea			:= GetArea()
Local aAreaAtd		:= {}
Local aTipo			:= {{"1","SUC"},{"2","SUA"},{"3","ACF"},{"4","ADE"}} //Telemarketing, televenda,telecobranca,teleatendimento
Local nPos			:= 0
Local cAlias		:= ""

Private INCLUI		:= .F.
Private aRotina   	:= {}

nPos		:= aScan(aTipo,{|x| x[1]==cTipoAtd}) //Posiciona na array de acordo com o tipo de atendimento
cAlias		:= aTipo[nPos][2] //seta alias do tipo de atendimento

	If(cAlias $ "SUC|SUA|ACF") //Visualiza cadastro dos tipos telemarketing, televenda,telecobranca
       
       aAreaAtd := (cAlias)->(GetArea())
       aRotina  := {		{ STR0156 ,"AxPesqui"                 , 0 , 1 , , .F. },; // "Pesquisar"      
                    		{ STR0153 ,"TK271CallCenter"  , 0 , 2 , , .T. }  }  // "Visualizar"
       
       DbSelectArea(cAlias)
       DbSetOrder(1)
       
       If DbSeek(xFilial(cAlias)+cCodAtd)
             TkGetTipoAte(aTipo[nPos][1])
             TK271CallCenter(cAlias,(cAlias)->(Recno()),2)
       EndIf

	ElseIf (cAlias $ "ADE") //Visualiza cadastro do tipo teleatendimento

       aAreaAtd := (cAlias)->(GetArea())
       aRotina  := {		{ STR0156   ,"AxPesqui"                     , 0 , 1 , , .F. },;             // "Pesquisar"    
                    		{ STR0153 ,"TK503AOpc"  , 0 , 2 , , .T. }  }                          		// "Visualizar"
       
       DbSelectArea(cAlias)
       DbSetOrder(1)
       
       If DbSeek(xFilial(cAlias)+cCodAtd)
             TK503AOpc(cAlias,(cAlias)->(Recno()),2)
       EndIf
End

RestArea(aAreaAtd)
RestArea(aArea)

Return Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc10ScRep

Monta texto da resposta para a pergunta dissertativa

@sample		Tkc10ScRep(cCodExec)

@param			cCodExec:	Código de execução da campanha		
				codPerg:	Código da Pergunta
				codResp:	Código da Resposta				

@return		Texto da resposta

@author		Aline Kokumai
@since			05/11/2013
@version		P11.8
/*/
//------------------------------------------------------------------------------
Static Function Tkc10ScRep(cCodExec, codPerg, codResp)

Local aArea		:= GetArea()
Local cResposta	:= ""					//Texto com a descricao da resposta
Local nTamMemo	:= 0

Default cCodExec	:= ""

	DbSelectArea("SUK")
	DbSetOrder(1)
	
	nTamMemo := TAMSX3("UK_RESMEMO")[1]

	If SUK->(DbSeek(xFilial("SUK")+cCodExec))		
		While SUK->(!Eof() .AND. SUK->UK_FILIAL == xFilial("SUK") .AND. SUK->UK_CODIGO == cCodExec)	
			If SUK->UK_CODPERG == Alltrim(codPerg) .AND. SUK->UK_CODRESP==Alltrim(codResp) 	
				cResposta  += MSMM(SUK->UK_CODMEMO,nTamMemo)	 //Busca resposta no memo
			EndIf
			SUK->(DbSkip())		
		EndDo				
	EndIf
	
RestArea(aArea)

Return (	cResposta	)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010PnCT

FWBrowse do perfil do cliente - tela de contatos 

@sample			Tkc010PnCT(oExplorer,nPanel,aEmpCont)

@param			ExpC - Objeto da tela principal
				ExpC - Painel 
				ExpC - Array com os dados da entidade posicionada

@return		    Nil

@author		Thamara Villa Jacomo
@since			16/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------

Function Tkc010PnCT(oExplorer,nPanel,aEmpCont) 

Local oPanel	  := oExplorer:aPanel[nPanel]
Local aArea		  := GetArea()
Local aCab 		  := {} //Array com todos os dados que serão exibidos no Browse
Local aEnd 		  := {} //Array que guarda a posição da linha principal p/ criar o dinamismo no folder de endereço
Local aTel 		  := {} //Array que guarda a posição da linha principal p/ criar o dinamismo no folder de telefone
Local aFolder 	  := { STR0173, STR0174 }  //"Endereço(s)","Telefone(s)"
Local oFWLayer 	  := Nil
Local oDlgContato := Nil
Local oDlgEntd	
Local oColumn	  := NIl
Local oCab		  := Nil
Local oEnd	      := Nil
Local oTel		  := Nil
Local cEntida	  := aEmpCont[9][3]
Local cConta	  := aEmpCont[10][3]
Local oFolder     := Nil
Local aObsFields  := {}
Local aPdFields	  := {}
 
cConta := SubStr( cConta, 1, 6 )

oFWLayer := FWLayer():New()
oFWLayer:Init(oPanel,.F.)

/*	                  
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³      ***ESTRUTURA DO ARRAY aCAB***	  	 ³
 ³  ***SU5 - Contatos***			      	 ³ 
 ³  1  - Codigo                               ³
 ³  2  - Nome								 ³
 ³  3  - CPF								 ³
 ³  4  - E-mail							 ³
 ³  5  - Ativo							 ³
 ³  6  - Ultimo Contato                       ³
 ³  7  - Nível                                ³
 ³  8  - Cargo                                ³
 ³  9  - Departamento                         ³
 ³  10 - Renda                                ³
 ³  11 - Recebe E-mail                        ³
 ³     12 - ***AGA - Entidades x Endereços*** ³
 ³     	 1  - Código                         ³             
 ³		 2  - Tipo                           ³
 ³		 3  - Endereço                       ³
 ³		 4  - CEP                            ³
 ³		 5  - Bairro                         ³
 ³		 6  - Estado                         ³
 ³		 7  - Municipio                      ³
 ³		 8  - Padrão                         ³
 ³	 	 9  - País                           ³
 ³	     10 - Complemento                     ³
 ³     13 - ***AGB - Entidades x Telefones*** ³
 ³    	 1  - Código                         ³
 ³		 2  - Tipo                           ³
 ³		 3  - DDI                            ³
 ³		 4  - DDD                            ³
 ³		 5  - Telefone                       ³
 ³		 6  - Complemento                    ³
 ³		 7  - Padrão                         ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/		     

aCab := aClone( Tkc010QrCt( cConta, cEntida ) )      
         
If Len( aCab ) == 0
	TKC010SD(oExplorer, nPanel, { STR0027,; //"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
							      "",;
							      "01} SU5 - "+Trim( Posicione( "SX2", 1, "SU5", "X2NOME()" ) ),;
							      "02} AC8 - "+Trim( Posicione( "SX2", 1, "AC8", "X2NOME()" ) ),;
							      "03} AGA - "+Trim( Posicione( "SX2", 1, "AGA", "X2NOME()" ) ),;
							      "04} AGB - "+Trim( Posicione( "SX2", 1, "AGB", "X2NOME()" ) ) }) 	
Else
	
	aPdFields := {"U5_CONTAT","U5_EMAIL","U5_CPF","U5_RENDA","AGA_BAIRRO","AGA_CEP","AGA_COMP","AGA_END","AGA_EST","AGA_MUNDES","AGA_PAIS",;
		"AGB_DDI","AGB_DDD","AGB_TELEFO","AGB_COMP"}
	FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields, /*cSource*/) 
	//Superior
	oFWLayer:AddLine( "LINETOP", 60, .F. )
	oFWLayer:AddCollumn( "COL_CONTATOS", 100, .F., "LINETOP" )
	oFWLayer:AddWindow( "COL_CONTATOS", "oDlgContato", STR0157, 100, .F., .F.,, "LINETOP" )	//"Contatos"
	oDlgContato := oFWLayer:GetWinPanel( "COL_CONTATOS", "oDlgContato", "LINETOP" )
	
	DEFINE FWBROWSE oCab DATA ARRAY ARRAY aCab CHANGE {|| TkC10ABrwAt(aCab,aEnd,aTel,oCab,oEnd,oTel) } LINE BEGIN 1 OF oDlgContato
		
		If FATPDIsObFuscated("U5_CONTAT")
			aAdd(aObsFields, "U5_CONTAT" )
		EndIf

		If FATPDIsObFuscated("U5_EMAIL")
			aAdd(aObsFields, "U5_EMAIL" )
		EndIf 

		If FATPDIsObFuscated("U5_CPF")
			aAdd(aObsFields, "U5_CPF" )
		EndIf 

		If FATPDIsObFuscated("U5_RENDA")
			aAdd(aObsFields, "U5_RENDA" )
		EndIf

		If FATPDActive() .And. FTPDUse(.T.)
			oCab:SetObfuscFields(aObsFields)
		EndIf
		
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO01 )+'] }') TITLE TxSX3Campo("U5_CODCONT")[1]		SIZE TAMSX3("U5_CODCONT")[1]  ALIGN 1 HEADERCLICK { || } ID "U5_CODCONT" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO02 )+'] }') TITLE TxSX3Campo("U5_CONTAT")[1]		SIZE TAMSX3("U5_CONTAT")[1]   ALIGN 1 HEADERCLICK { || } ID "U5_CONTAT" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO03 )+'] }') TITLE TxSX3Campo("U5_CPF")[1]	   		SIZE TAMSX3("U5_CPF")[1]      ALIGN 1 HEADERCLICK { || } ID "U5_CPF" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO04 )+'] }') TITLE TxSX3Campo("U5_EMAIL")[1]			SIZE TAMSX3("U5_EMAIL")[1]    ALIGN 1 HEADERCLICK { || } ID "U5_EMAIL" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO05 )+'] }') TITLE TxSX3Campo("U5_ATIVO")[1]	   		SIZE TAMSX3("U5_ATIVO")[1]    ALIGN 1 HEADERCLICK { || } ID "U5_ATIVO" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO06 )+'] }') TITLE TxSX3Campo("U5_ULTCONT")[1]		SIZE TAMSX3("U5_ULTCONT")[1]  ALIGN 1 HEADERCLICK { || } ID "U5_ULTCONT" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO07 )+'] }') TITLE STR0158								SIZE 50 ALIGN 1 HEADERCLICK { || } OF oCab //"Descrição"
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO08 )+'] }') TITLE TxSX3Campo("UM_DESC")[1]	   		SIZE TAMSX3("UM_DESC")[1]     ALIGN 1 HEADERCLICK { || } ID "UM_DESC" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO09 )+'] }') TITLE TxSX3Campo("QB_DESCRIC ")[1]		SIZE TAMSX3("QB_DESCRIC ")[1] ALIGN 1 HEADERCLICK { || } ID "QB_DESCRIC" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO10 )+'] }') TITLE TxSX3Campo("U5_RENDA")[1]	   		SIZE TAMSX3("U5_RENDA")[1]    ALIGN 1 HEADERCLICK { || } ID "U5_RENDA" OF oCab
		ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( CAB_CPO11 )+'] }') TITLE TxSX3Campo("U5_AUTORIZ")[1]		SIZE TAMSX3("U5_AUTORIZ")[1]  ALIGN 1 HEADERCLICK { || } ID "U5_AUTORIZ" OF oCab
		
	ACTIVATE FWBROWSE oCab

	aSize(aObsFields, 0)

	//Inferior
	oFWLayer:AddLine( "LINEDOWN", 35, .F. )
	oFWLayer:AddCollumn( "COL_ENTD", 100, .F., "LINEDOWN" )
	oFWLayer:AddWindow( "COL_ENTD", "oDlgEntd", STR0159, 100, .F., .F.,,"LINEDOWN" )//"Dados Adicionais"
	oDlgEntd := oFWLayer:GetWinPanel( "COL_ENTD", "oDlgEntd" ,"LINEDOWN" )
	     
	oFolder := TFolder():New( 000, 000, aFolder,, oDlgEntd,,,,.T.,,oDlgEntd:nWidth/2, oDlgEntd:nHeight/2 )
    
	//Guarda posições para criar o dinamismo na alteração das linhas
	aEnd := aCab[oCab:At()][CAB_BRW_END]                            
	
	//Folder 1 Entidade x Endereço
	DEFINE FWBROWSE oEnd DATA ARRAY ARRAY aEnd LINE BEGIN 1 OF oFolder:aDialogs[ 1 ]//Define o folder de exibicao dos dados
		
		If FATPDIsObFuscated("AGA_BAIRRO")
			aAdd(aObsFields, "AGA_BAIRRO" )
		EndIf

		If FATPDIsObFuscated("AGA_CEP")
			aAdd(aObsFields, "AGA_CEP" )
		EndIf

		If FATPDIsObFuscated("AGA_COMP")
			aAdd(aObsFields, "AGA_COMP" )
		EndIf

		If FATPDIsObFuscated("AGA_END")
			aAdd(aObsFields, "AGA_END" )
		EndIf

		If FATPDIsObFuscated("AGA_EST")
			aAdd(aObsFields, "AGA_EST" )
		EndIf

		If FATPDIsObFuscated("AGA_MUNDES")
			aAdd(aObsFields, "AGA_MUNDES" )
		EndIf

		If FATPDIsObFuscated("AGA_PAIS")
			aAdd(aObsFields, "AGA_PAIS" )
		EndIf

		If FATPDActive() .And. FTPDUse(.T.)
			oEnd:SetObfuscFields(aObsFields)
		EndIf
        
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][1]  }') TITLE TxSX3Campo("AGA_CODENT")[1]	SIZE TAMSX3("AGA_CODENT")[1]  ALIGN 1 HEADERCLICK { || } ID "AGA_CODENT" OF oEnd
        ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][2]  }') TITLE TxSX3Campo("AGA_TIPO")[1]		SIZE TAMSX3("AGA_TIPO")[1]    ALIGN 1 HEADERCLICK { || } ID "AGA_TIPO" 	 OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][3]  }') TITLE TxSX3Campo("AGA_END")[1]		SIZE TAMSX3("AGA_END")[1]     ALIGN 1 HEADERCLICK { || } ID "AGA_END"    OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][4]  }') TITLE TxSX3Campo("AGA_CEP")[1]		SIZE TAMSX3("AGA_CEP")[1]     ALIGN 1 HEADERCLICK { || } ID "AGA_CEP" 	 OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][5]  }') TITLE TxSX3Campo("AGA_BAIRRO")[1]	SIZE TAMSX3("AGA_BAIRRO")[1]  ALIGN 1 HEADERCLICK { || } ID "AGA_BAIRRO" OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][6]  }') TITLE TxSX3Campo("AGA_EST")[1]		SIZE TAMSX3("AGA_EST")[1]     ALIGN 1 HEADERCLICK { || } ID "AGA_EST"    OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][7]  }') TITLE TxSX3Campo("AGA_MUNDES")[1]	SIZE TAMSX3("AGA_MUNDES")[1]  ALIGN 1 HEADERCLICK { || } ID "AGA_MUNDES" OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][8]  }') TITLE TxSX3Campo("AGA_PADRAO")[1]	SIZE TAMSX3("AGA_PADRAO")[1]  ALIGN 1 HEADERCLICK { || } ID "AGA_PADRAO" OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][9]  }') TITLE TxSX3Campo("YA_DESCR")[1]		SIZE TAMSX3("YA_DESCR")[1]    ALIGN 1 HEADERCLICK { || } ID "AGA_PAIS"   OF oEnd
		ADD COLUMN oColumn DATA &('{ || aEnd[oEnd:At()][10] }') TITLE TxSX3Campo("AGA_COMP")[1]		SIZE TAMSX3("AGA_COMP")[1]    ALIGN 1 HEADERCLICK { || } ID "AGA_COMP"	 OF oEnd
		
	ACTIVATE FWBROWSE oEnd             
	aSize(aObsFields, 0)

	//Guarda posições para criar o dinamismo na alteração das linhas
	aTel := aCab[oCab:At()][CAB_BRW_FONE]
	
	//Folder 2 Entidade x Telefones
	DEFINE FWBROWSE oTel DATA ARRAY ARRAY aTel LINE BEGIN 1 OF oFolder:aDialogs[ 2 ]//Define o folder de exibicao dos dados

		If FATPDIsObFuscated("AGB_DDI")
			aAdd(aObsFields, "AGB_DDI" )
		EndIf

		If FATPDIsObFuscated("AGB_DDD")
			aAdd(aObsFields, "AGB_DDD" )
		EndIf

		If FATPDIsObFuscated("AGB_TELEFO")
			aAdd(aObsFields, "AGB_TELEFO" )
		EndIf

		If FATPDIsObFuscated("AGB_COMP")
			aAdd(aObsFields, "AGB_COMP" )
		EndIf

		If FATPDActive() .And. FTPDUse(.T.)
			oTel:SetObfuscFields(aObsFields)
		EndIf
		
		ADD COLUMN oColumn DATA &('{ || aTel[oTel:At()][1] }') TITLE TxSX3Campo("AGB_CODENT")[1]	SIZE TAMSX3("AGB_CODENT")[1]  ALIGN 1 HEADERCLICK { || } ID "AGB_CODENT" OF oTel
        ADD COLUMN oColumn DATA &('{ || aTel[oTel:At()][2] }') TITLE TxSX3Campo("AGB_TIPO")[1]		SIZE TAMSX3("AGB_TIPO")[1]    ALIGN 1 HEADERCLICK { || } ID "AGB_TIPO" 	 OF oTel
		ADD COLUMN oColumn DATA &('{ || aTel[oTel:At()][3] }') TITLE TxSX3Campo("AGB_DDI")[1]		SIZE TAMSX3("AGB_DDI")[1]     ALIGN 1 HEADERCLICK { || } ID "AGB_DDI" 	 OF oTel
		ADD COLUMN oColumn DATA &('{ || aTel[oTel:At()][4] }') TITLE TxSX3Campo("AGB_DDD")[1]		SIZE TAMSX3("AGB_DDD")[1]     ALIGN 1 HEADERCLICK { || } ID "AGB_DDD" 	 OF oTel
		ADD COLUMN oColumn DATA &('{ || aTel[oTel:At()][5] }') TITLE TxSX3Campo("AGB_TELEFO")[1]	SIZE TAMSX3("AGB_TELEFO")[1]  ALIGN 1 HEADERCLICK { || } ID "AGB_TELEFO" OF oTel
		ADD COLUMN oColumn DATA &('{ || aTel[oTel:At()][6] }') TITLE TxSX3Campo("AGB_COMP")[1]		SIZE TAMSX3("AGB_COMP")[1]    ALIGN 1 HEADERCLICK { || } ID "AGB_COMP"	 OF oTel
		ADD COLUMN oColumn DATA &('{ || aTel[oTel:At()][7] }') TITLE TxSX3Campo("AGB_PADRAO")[1]	SIZE TAMSX3("AGB_PADRAO")[1]  ALIGN 1 HEADERCLICK { || } ID "AGB_PADRAO" OF oTel
	 		 	 	 
  	ACTIVATE FWBROWSE oTel             

	aSize(aObsFields, 0)
	
	//Possibilita a visualizacao cheia do Browse superior
	oFWLayer:SetLinSplit( "LINEDOWN", CONTROL_ALIGN_TOP,, )
	
EndIf

FATPDUnload()
RestArea( aArea )

Return( Nil )  

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010QrCt

Executa a query de filtro de contatos por entidade selecionada

@sample			Tkc010QrCt(cCodigo, cEntid)

@param			ExpC1 - Codigo da entidade
				ExpC2 - Tipo da entidade 

@return		ExpL Array com a query montada

@author		Thamara Villa Jacomo
@since			16/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------

Static Function Tkc010QrCt( cCodigo, cEntid )

Local cAlias    := GetNextAlias()
Local aDados   	:= {}
Local cQuery   	:= ""

Default cCodigo := ""
Default cEntid  := ""

//Query para Clientes
If !Empty( cCodigo ) .And. Alltrim( cEntid ) == 'SA1'

	BEGINSQL ALIAS cAlias

		SELECT DISTINCT SU5.U5_CODCONT, SU5.U5_CONTAT, SU5.U5_CPF, SU5.U5_EMAIL, SU5.U5_ATIVO, SU5.U5_ULTCONT,
				SX5.X5_DESCRI, SUM.UM_DESC, SQB.QB_DESCRIC, SU5.U5_RENDA, SU5.U5_AUTORIZ 

		FROM %Table:SU5% SU5

		INNER JOIN %Table:AC8% AC8 ON ( AC8.AC8_FILIAL = %Exp:xFilial( "AC8" )% AND AC8.AC8_CODCON = SU5.U5_CODCONT AND AC8.%NotDel% ) 
		INNER JOIN %Table:SA1% SA1 ON ( SA1.A1_FILIAL  = %Exp:xFilial( "SA1" )% AND SA1.A1_COD = SubString( AC8.AC8_CODENT, 1, 6 ) AND 
			SA1.A1_LOJA = SubString( AC8.AC8_CODENT, 7, 2 ) AND SA1.%NotDel% )
		LEFT JOIN %Table:SX5% SX5 ON ( SX5.X5_FILIAL  = %Exp:xFilial( "SX5" )% AND SX5.X5_CHAVE = SU5.U5_NIVEL AND SX5.X5_TABELA = 'T6' AND SX5.%NotDel% )
		LEFT JOIN %Table:SUM% SUM ON ( SUM.UM_FILIAL  = %Exp:xFilial( "SUM" )% AND SUM.UM_CARGO = SU5.U5_FUNCAO AND SUM.%NotDel% )
		LEFT JOIN %Table:SQB% SQB ON ( SQB.QB_FILIAL  = %Exp:xFilial( "SQB" )% AND SQB.QB_DEPTO = SU5.U5_DEPTO  AND SQB.%NotDel% )

		WHERE SU5.U5_FILIAL = %Exp:xFilial( "SU5" )% AND SU5.%NotDel% AND AC8_ENTIDA = 'SA1' AND SA1.A1_COD = %Exp:cCodigo% 
	
		ORDER BY SU5.U5_CODCONT

	ENDSQL           
//Query para Prospects
ElseIf !Empty( cCodigo ) .And. Alltrim( cEntid ) == 'SUS' 
	BEGINSQL ALIAS cAlias

		SELECT DISTINCT SU5.U5_CODCONT, SU5.U5_CONTAT, SU5.U5_CPF, SU5.U5_EMAIL, SU5.U5_ATIVO, SU5.U5_ULTCONT,
				SX5.X5_DESCRI, SUM.UM_DESC, SQB.QB_DESCRIC, SU5.U5_RENDA, SU5.U5_AUTORIZ 

		FROM %Table:SU5% SU5

		INNER JOIN %Table:AC8% AC8 ON ( AC8.AC8_FILIAL = %Exp:xFilial( "AC8" )% AND AC8.AC8_CODCON = SU5.U5_CODCONT AND AC8.%NotDel% ) 
		INNER JOIN %Table:SUS% SUS ON ( SUS.US_FILIAL  = %Exp:xFilial( "SUS" )% AND SUS.US_COD = SubString( AC8.AC8_CODENT, 1, 6 ) AND 
			SUS.US_LOJA = SubString( AC8.AC8_CODENT, 7, 2 ) AND SUS.%NotDel% )
		LEFT JOIN %Table:SX5% SX5 ON ( SX5.X5_FILIAL  = %Exp:xFilial( "SX5" )% AND SX5.X5_CHAVE = SU5.U5_NIVEL AND SX5.X5_TABELA = 'T6' AND SX5.%NotDel% )
		LEFT JOIN %Table:SUM% SUM ON ( SUM.UM_FILIAL  = %Exp:xFilial( "SUM" )% AND SUM.UM_CARGO = SU5.U5_FUNCAO AND SUM.%NotDel% )
		LEFT JOIN %Table:SQB% SQB ON ( SQB.QB_FILIAL  = %Exp:xFilial( "SQB" )% AND SQB.QB_DEPTO = SU5.U5_DEPTO  AND SQB.%NotDel% )

		WHERE SU5.U5_FILIAL = %Exp:xFilial( "SU5" )% AND SU5.%NotDel% AND AC8_ENTIDA = 'SUS' AND SUS.US_COD = %Exp:cCodigo% 
	
		ORDER BY SU5.U5_CODCONT
                      
	ENDSQL            
//Query para Suspects	
Else
	BEGINSQL ALIAS cAlias

		SELECT DISTINCT SU5.U5_CODCONT, SU5.U5_CONTAT, SU5.U5_CPF, SU5.U5_EMAIL, SU5.U5_ATIVO, SU5.U5_ULTCONT,
				SX5.X5_DESCRI, SUM.UM_DESC, SQB.QB_DESCRIC, SU5.U5_RENDA, SU5.U5_AUTORIZ 

		FROM %Table:SU5% SU5

		INNER JOIN %Table:AC8% AC8 ON ( AC8.AC8_FILIAL = %Exp:xFilial( "AC8" )% AND AC8.AC8_CODCON = SU5.U5_CODCONT AND AC8.%NotDel% ) 
		INNER JOIN %Table:ACH% ACH ON ( ACH.ACH_FILIAL  = %Exp:xFilial( "ACH" )% AND ACH.ACH_CODIGO = SubString( AC8.AC8_CODENT, 1, 6 ) AND 
			ACH.ACH_LOJA = SubString( AC8.AC8_CODENT, 7, 2 ) AND ACH.%NotDel% )
		LEFT JOIN %Table:SX5% SX5 ON ( SX5.X5_FILIAL  = %Exp:xFilial( "SX5" )% AND SX5.X5_CHAVE = SU5.U5_NIVEL AND SX5.X5_TABELA = 'T6' AND SX5.%NotDel% )
		LEFT JOIN %Table:SUM% SUM ON ( SUM.UM_FILIAL  = %Exp:xFilial( "SUM" )% AND SUM.UM_CARGO = SU5.U5_FUNCAO AND SUM.%NotDel% )
		LEFT JOIN %Table:SQB% SQB ON ( SQB.QB_FILIAL  = %Exp:xFilial( "SQB" )% AND SQB.QB_DEPTO = SU5.U5_DEPTO  AND SQB.%NotDel% )

		WHERE SU5.U5_FILIAL = %Exp:xFilial( "SU5" )% AND SU5.%NotDel% AND AC8_ENTIDA = 'ACH' AND ACH.ACH_CODIGO = %Exp:cCodigo%   
	
		ORDER BY SU5.U5_CODCONT

	ENDSQL 
    
EndIf     

DbSelectArea( cAlias )

While ( cAlias )->( !Eof() )        
  	
	aAdd( aDados, {  ( cAlias )->U5_CODCONT   ,;
			         ( cAlias )->U5_CONTAT	  ,;
	                 ( cAlias )->U5_CPF	      ,;
                   	 ( cAlias )->U5_EMAIL	  ,;
				     X3COMBO( "U5_ATIVO",( cAlias )->U5_ATIVO )	  ,;
	 				 STod( ( cAlias )->U5_ULTCONT ) ,;
     	             ( cAlias )->X5_DESCRI	  ,;
		     	     ( cAlias )->UM_DESC	  ,;  	
     				 ( cAlias )->QB_DESCRIC   ,;
					 Transform( ( cAlias )->U5_RENDA, "@E 999,999.99" ),;
					 X3COMBO( "U5_AUTORIZ",( cAlias )->U5_AUTORIZ ),;
					 Tkc010QrEnd( ( cAlias )->U5_CODCONT ) ,;
					 Tkc010QrFon( ( cAlias )->U5_CODCONT ) } )	   				 
 
   ( cAlias )->( DbSkip() )
EndDo

( cAlias )->( DbCloseArea() )
	                                                          
Return( aDados )         

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010QrEnd

Executa a query de filtro de Endereços de contatos por entidade selecionada

@sample		Tkc010QrEnd( cEntidad )

@param		cEntidad -> Codigo do SU5(Contatos) 

@return		aLowEnd  -> Array com os endereços do contato

@author		Thamara Villa Jacomo
@since			16/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function Tkc010QrEnd( cEntidad )

Local cAliasAGA := GetNextAlias()
Local aLowEnd 	:= {}  
Local cQryAGA	:= ""

Default cEntidad := ""
                       
                       
//Query Folder Enderecos X Entidade( AGA )                        
BEGINSQL ALIAS cAliasAGA

	SELECT AGA.AGA_CODIGO, AGA.AGA_CODENT, AGA.AGA_TIPO, AGA.AGA_END, AGA.AGA_CEP, AGA.AGA_BAIRRO, AGA.AGA_EST, AGA.AGA_MUNDES,
			AGA.AGA_PADRAO, SYA.YA_DESCR, AGA.AGA_COMP

	FROM %Table:AGA% AGA                     
	LEFT JOIN %Table:SYA% SYA ON ( SYA.YA_FILIAL = %Exp:xFilial( "SYA" )% AND SYA.YA_CODGI = AGA.AGA_PAIS AND SYA.%NotDel% )
	WHERE AGA.AGA_FILIAL = %Exp:xFilial( "AGB" )% AND AGA.AGA_ENTIDA = 'SU5' AND AGA.AGA_CODENT = %Exp:cEntidad% AND AGA.%NotDel%
		
	ORDER BY AGA.AGA_CODIGO

ENDSQL

DbSelectArea( cAliasAGA )

While ( cAliasAGA )->( !Eof() )

	aAdd( aLowEnd, { ( cAliasAGA )->AGA_CODENT	  ,;
	                X3COMBO( "AGA_TIPO",( cAliasAGA )->AGA_TIPO )	  ,; 
				   ( cAliasAGA )->AGA_END		  ,;
				   Iif( cPaisLoc == "BRA", Transform( ( cAliasAGA )->AGA_CEP, "@R 99999-999" ),( cAliasAGA )->AGA_CEP ) ,;
				   ( cAliasAGA )->AGA_BAIRRO	  ,;
				   ( cAliasAGA )->AGA_EST		  ,;
 				   ( cAliasAGA )->AGA_MUNDES	  ,;
				   X3COMBO( "AGA_PADRAO",( cAliasAGA )->AGA_PADRAO ) ,;		   
				   ( cAliasAGA )->YA_DESCR 	  ,;
				   ( cAliasAGA )->AGA_COMP	} )

	( cAliasAGA )->( DbSkip() )

EndDo

( cAliasAGA )->( DbCloseArea() )

Return( aLowEnd )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010QrFon

Executa a query de filtro de Telefones de contatos por entidade selecionada

@sample		Tkc010QrFon( cEntidad )

@param		cEntidad -> Codigo do SU5(Contatos) 

@return		aLowFone -> Array com os telefones do contato

@author		Thamara Villa Jacomo
@since			21/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------

Static Function Tkc010QrFon( cEntidad )
                     
Local cAliasAGB := GetNextAlias()
Local cQryAGB	:= ""
Local aLowFone	:= {}

Default cEntidad := ""

//Query Folder Telefone x Entidade ( AGB )
BEGINSQL ALIAS cAliasAGB

	SELECT AGB.AGB_CODIGO,AGB.AGB_CODENT, AGB.AGB_TIPO, AGB.AGB_DDI, AGB.AGB_DDD, AGB.AGB_TELEFO, AGB.AGB_COMP, AGB.AGB_PADRAO 
	FROM %Table:AGB% AGB  
	WHERE AGB.AGB_FILIAL = %Exp:xFilial( "AGB" )% AND AGB.AGB_ENTIDA = 'SU5' AND AGB.AGB_CODENT = %Exp:cEntidad% AND AGB.%NotDel%
	ORDER BY AGB.AGB_CODENT
	
ENDSQL

DbSelectArea( cAliasAGB )

While ( cAliasAGB )->( !Eof() )

	aAdd( aLowFone, { ( cAliasAGB )->AGB_CODENT ,;
				  	  X3COMBO( "AGB_TIPO", ( cAliasAGB )->AGB_TIPO ) ,;
	 			      ( cAliasAGB )->AGB_DDI	,;
				  	  ( cAliasAGB )->AGB_DDD	,;
				  	  ( cAliasAGB )->AGB_TELEFO ,;
				  	  ( cAliasAGB )->AGB_COMP	,;
				  	  X3COMBO( "AGB_PADRAO", ( cAliasAGB )->AGB_PADRAO ) } )		

    ( cAliasAGB )->( DbSkip() )
EndDo                                                                            

 ( cAliasAGB )->( DbCloseArea() ) 

Return( aLowFone )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC10ABrwAt

Executa o Change para criar o dinamismo do Browse superior com os Folders.

@sample		TkC10ABrwAt(aCab,aEnd,aTel,oCab,oEnd,oTel)

@param		ExpC1 -> Array contendo a query de todos os dados a serem 
									exibidos no Browse. 
			ExpC2 -> Array do folder de endereço que guarda a posição da 
						linha pai para criar o dinamismo na tela.
			ExpC3 -> Array do folder de Telefone que guarda a posição da 
						linha pai para criar o dinamismo na tela.
			ExpC4 -> Objeto do painel principal(superior).
			ExpC5 -> Objeto do Folder 1 - Endereço
			ExpC6 -> Objeto do Folder 2 - Telefone

@return		Nil

@author		Thamara Villa Jacomo
@since			21/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function TkC10ABrwAt(aCab,aEnd,aTel,oCab,oEnd,oTel)

If ValType( oEnd ) == "O" .AND. ValType( oTel ) == "O" 
	aEnd := aCab[oCab:At()][CAB_BRW_END]
	oEnd:SetArray(aCab[oCab:At()][CAB_BRW_END])
	aTel := aCab[oCab:At()][CAB_BRW_FONE]
	oTel:SetArray(aCab[oCab:At()][CAB_BRW_FONE])
	oEnd:Refresh()
	oTel:Refresh() 
EndIf	    
	
Return( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Opt

FWBrowse do perfil do cliente(Oportunidades) - tela de contatos 

@sample		Tkc010Opt(oExplorer,nPanel,aEmpCont,cStatus)

@param			ExpC - Objeto da tela principal
				ExpC - Painel 
				ExpC - Array com os dados da entidade posicionada
				ExpC - Status da oporunidade

@return		    Nil

@author		Thamara Villa Jacomo
@since			16/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------

Function Tkc010Opt(oExplorer,nPanel,aEmpCont,cStatus)

Local oPanel	  := oExplorer:aPanel[nPanel]
Local aCab		  := {}  //Array principal com todas as querys que serão exibidas no Browse
Local aFolder	  := { STR0160,STR0161,STR0162,STR0163,STR0164, STR0165 }//"Concorrente","Time de Vendas","Parceiros","Produtos","Evolução da Venda"
Local oFWLayer	  := Nil //Objeto do FWLAyer
Local oDlgOportu  := Nil //Objeto do Browse principal
Local oDlgFolders := Nil //Objeto dos Folders             
Local oColumn 	  := Nil //Objeto das Colunas
Local oCab		  := Nil //Objeto do Browse superior
Local oConc		  := Nil //Objeto do Folder Concorrentes
Local oTime		  := Nil //Objeto do Folder Time de Vendas
Local oParc		  := NIl //Objeto do Folder Parceiros
Local oContac 	  := Nil //Objeto do Folder Contatos
Local oProd		  := Nil //Objeto do Folder Produtos
Local oEvol		  := Nil //Objeto do Folder Evol. da Venda
Local oFolder		  := Nil
Local cEntidad	  := aEmpCont[9][3]
Local cConta	  := aEmpCont[10][3]                  
Local cLoja		  := aEmpCont[10][3]
Local dData		  := aEmpCont[16][3]
Local cTitle	  := ""
Local aConc		  := {}                         
Local aTime		  := {}
Local aParc		  := {}
Local aCont		  := {}
Local aProd		  := {}
Local aEvol		  := {}	
Local aPDFields   := {}		
Local aObsFields  := {}

cConta := SubStr( cConta, 1, 6 )
cLoja  := SubStr( cLoja, 7, 8 )	
                                     
Do Case
	Case Alltrim( cStatus ) == '1'
		cTitle := STR0166		//"Oportunidade(s) Aberta(s)"
	Case Alltrim( cStatus ) == '2'
		cTitle := STR0167		//"Oportunidade(s) Perdida(s)"   
	Case Alltrim( cStatus ) == '3'
		cTitle := STR0168		//"Oportunidade(s) Suspensa(s)"
	Case Alltrim( cStatus ) == '9'
		cTitle := STR0169		//"Oportunidade(s) Ganha"
	OtherWise			
		cTitle := STR0170		//"Todas Oportunidades"
EndCase                     

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oPanel,.F.)
	                                                  
cStatus := Alltrim( cStatus )
aCab := ( aClone( Tkc010Qpt( cConta, cLoja, cEntidad, cStatus, dData ) ) )

If Len( aCab ) == 0

		TKC010SD(oExplorer, nPanel, { STR0027,; 	//"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
							      "",;
							      "01} AD1 - "+Trim( Posicione( "SX2", 1, "AD1", "X2NOME()" ) ),;
							      "02} AD2 - "+Trim( Posicione( "SX2", 1, "AD2", "X2NOME()" ) ),;
							      "03} AD3 - "+Trim( Posicione( "SX2", 1, "AD3", "X2NOME()" ) ),;
   							      "04} AD4 - "+Trim( Posicione( "SX2", 1, "AD4", "X2NOME()" ) ),;
   							      "05} AD9 - "+Trim( Posicione( "SX2", 1, "AD9", "X2NOME()" ) ),;
							      "06} ADJ - "+Trim( Posicione( "SX2", 1, "ADJ", "X2NOME()" ) ),;   							      
							      "07} AIJ - "+Trim( Posicione( "SX2", 1, "AIJ", "X2NOME()" ) ),; 
							      "08} SA1 - "+Trim( Posicione( "SX2", 1, "SA1", "X2NOME()" ) ),;
   							      "09} SUS - "+Trim( Posicione( "SX2", 1, "SUS", "X2NOME()" ) ) }) 	
Else

//Superior
oFWLayer:AddLine( "LINESUP", 55, .F. )
oFWLayer:AddColumn( "COL_OPORTU", 100, .F., "LINESUP" ) 
oFWLayer:AddWindow( "COL_OPORTU", "oDlgOportu", STR0171 , 100, .F., .F.,, "LINESUP" )	//"Oportunidades"
oDlgOportu	:= oFWLayer:GetWinPanel( "COL_OPORTU", "oDlgOportu", "LINESUP" ) 
                                                                           
DEFINE FWBROWSE oCab DATA ARRAY ARRAY aCab CHANGE {|| TkC10ABrOpr(aCab,aConc,aTime,aParc,aCont,aProd,aEvol,oCab,oConc,oTime,oParc,oContac,oProd,oEvol)} LINE BEGIN 1 OF oDlgOportu
	
	OnlyGrid( oCab )

	aPDFields := {"A3_NOME","AC3_NOME","AC4_NOME","U5_CONTAT"}
	FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields, /*cSource*/)

	If FATPDIsObFuscated("A3_NOME")
		aObsFields := {"A3_NOME"}
	EndIf

	If FATPDActive() .And. FTPDUse(.T.)
		oCab:SetObfuscFields(aObsFields)
	EndIf

	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO01 )+ '] }') TITLE TxSX3Campo("AD1_FILIAL")[1]		SIZE TAMSX3("AD1_FILIAL")[1] ALIGN 1 HEADERCLICK { || } ID "AD1_FILIAL" OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO02 )+ '] }') TITLE TxSX3Campo("AD1_NROPOR")[1]		SIZE TAMSX3("AD1_NROPOR")[1] ALIGN 1 HEADERCLICK { || } ID "AD1_NROPOR" OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO03 )+ '] }') TITLE TxSX3Campo("AD1_REVISA")[1]		SIZE TAMSX3("AD1_REVISA")[1] ALIGN 1 HEADERCLICK { || } ID "AD1_REVISA" OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO04 )+ '] }') TITLE TxSX3Campo("AD1_DESCRI")[1]		SIZE TAMSX3("AD1_DESCRI")[1] ALIGN 1 HEADERCLICK { || } ID "AD1_DESCRI" OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO05 )+ '] }') TITLE TxSX3Campo("AD1_VEND")[1]		SIZE TAMSX3("AD1_VEND")[1]   ALIGN 1 HEADERCLICK { || } ID "AD1_VEND" 	OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO06 )+ '] }') TITLE TxSX3Campo("A3_NOME")[1]			SIZE TAMSX3("A3_NOME")[1]    ALIGN 1 HEADERCLICK { || } ID "A3_NOME" 	OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO07 )+ '] }') TITLE TxSX3Campo("AD1_VERBA")[1]		TYPE GetSx3Cache("AD1_VERBA","X3_TIPO")  SIZE TAMSX3("AD1_VERBA")[1] DECIMAL TAMSX3("AD1_VERBA")[2] PICTURE PesqPict("AD1","AD1_VERBA") ALIGN 1 HEADERCLICK { || } ID "AD1_VERBA" OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO08 )+ '] }') TITLE TxSX3Campo("AD1_DTINI")[1] 		TYPE GetSx3Cache("AD1_DTINI","X3_TIPO")  SIZE TAMSX3("AD1_DTINI")[1]  ALIGN 1 HEADERCLICK { || } ID "AD1_DTINI" 	OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO09 )+ '] }') TITLE TxSX3Campo("AD1_DTPFIM")[1]		TYPE GetSx3Cache("AD1_DTPFIM","X3_TIPO") SIZE TAMSX3("AD1_DTPFIM")[1] ALIGN 1 HEADERCLICK { || } ID "AD1_DTPFIM" 	OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO10 )+ '] }') TITLE TxSX3Campo("AD1_PROVEN")[1]		SIZE TAMSX3("AD1_PROVEN")[1] ALIGN 1 HEADERCLICK { || } ID "AD1_PROVEN" OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO11 )+ '] }') TITLE TxSX3Campo("AD1_STAGE")[1]		SIZE TAMSX3("AD1_STAGE")[1]  ALIGN 1 HEADERCLICK { || } ID "AD1_STAGE" 	OF oCab
	ADD COLUMN oColumn DATA &('{ || aCab[oCab:At(),'+cValToChar( SUP_CPO12 )+ '] }') TITLE TxSX3Campo("AD1_FEELIN")[1]		SIZE TAMSX3("AD1_FEELIN")[1] ALIGN 1 HEADERCLICK { || } ID "AD1_FEELIN" OF oCab
 					
ACTIVATE FWBROWSE oCab


//Inferior
oFWLayer:AddLine( "LINEINF", 40, .F. )
oFWLayer:AddColumn( "COL_FOLDER", 100, .F., "LINEINF" )
oFWLayer:AddWindow( "COL_FOLDER", "oDlgFolders", STR0159, 100, .F., .F.,, "LINEINF" )	//"Dados adicionais"
oDlgFolders := oFWLayer:GetWinPanel( "COL_FOLDER", "oDlgFolders", "LINEINF" )

oFolder := TFolder():New( 000, 000, aFolder,, oDlgFolders,,,,.T.,,oDlgFolders:nWidth/2, oDlgFolders:nHeight/2 )   

//Guarda posições para criar o dinamismo na alteração das linhas
aConc := aCab[oCab:At()][FLB_BCONC]
             
//Folder 1: Concorrentes
DEFINE FWBROWSE oConc DATA ARRAY ARRAY aConc LINE BEGIN 1 OF oFolder:aDialogs[ 1 ]

	OnlyGrid( oConc )

	If FATPDIsObFuscated("AC3_NOME")
		aObsFields := {"AC3_NOME"}
	EndIf

	If FATPDActive() .And. FTPDUse(.T.)
		oConc:SetObfuscFields(aObsFields)
	EndIf

	ADD COLUMN oColumn DATA &('{ || aConc[oConc:At()][1]  }') TITLE TxSX3Campo("AD3_CODCON")[1] 	SIZE TAMSX3("AD3_CODCON")[1] ALIGN 1 HEADERCLICK { || } ID "AD3_CODCON" OF oConc
	ADD COLUMN oColumn DATA &('{ || aConc[oConc:At()][2]  }') TITLE TxSX3Campo("AC3_NOME")[1] 	 	SIZE TAMSX3("AC3_NOME")[1]   ALIGN 1 HEADERCLICK { || } ID "AC3_NOME" OF oConc
	ADD COLUMN oColumn DATA &('{ || aConc[oConc:At()][3]  }') TITLE TxSX3Campo("AD3_PRECO")[1]  	TYPE GetSx3Cache("AD3_PRECO","X3_TIPO") SIZE TAMSX3("AD3_PRECO")[1] DECIMAL TAMSX3("AD3_PRECO")[2] PICTURE PesqPict("AD3","AD3_PRECO") ALIGN 1 HEADERCLICK { || } ID "AD3_PRECO" OF oConc
	ADD COLUMN oColumn DATA &('{ || aConc[oConc:At()][4]  }') TITLE TxSX3Campo("AD3_FCS")[1] 		SIZE TAMSX3("AD3_FCS")[1]    ALIGN 1 HEADERCLICK { || } ID "AD3_FCS" OF oConc
	ADD COLUMN oColumn DATA &('{ || aConc[oConc:At()][5]  }') TITLE STR0158 					SIZE 55 ALIGN 1 HEADERCLICK { || } OF oConc	//"Descricao"
	ADD COLUMN oColumn DATA &('{ || aConc[oConc:At()][6]  }') TITLE TxSX3Campo("AD3_FCI")[1]		SIZE TAMSX3("AD3_FCI")[1]    ALIGN 1 HEADERCLICK { || } ID "AD3_FCI" OF oConc
	ADD COLUMN oColumn DATA &('{ || aConc[oConc:At()][7]  }') TITLE STR0158 					SIZE 55 ALIGN 1 HEADERCLICK { || } OF oConc	//"Descricao"

ACTIVATE FWBROWSE oConc	
                                                    
aTime := aCab[oCab:At()][FLB_BTIME]
                            
//Folder 2: Time de Vendas
DEFINE FWBROWSE oTime DATA ARRAY ARRAY aTime LINE BEGIN 1 OF oFolder:aDialogs[ 2 ]

	OnlyGrid( oTime )

	If FATPDIsObFuscated("A3_NOME")
		aObsFields := {"A3_NOME"}
	EndIf

	If FATPDActive() .And. FTPDUse(.T.)
		oTime:SetObfuscFields(aObsFields)
	EndIf

	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][1]  }') TITLE TxSX3Campo("AD2_VEND")[1] 		SIZE TAMSX3("AD2_VEND")[1]   ALIGN 1 HEADERCLICK { || } OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][2]  }') TITLE TxSX3Campo("A3_NOME")[1] 		SIZE TAMSX3("A3_NOME")[1]    ALIGN 1 HEADERCLICK { || } ID "A3_NOME" OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][3]  }') TITLE TxSX3Campo("AD2_PERC")[1] 		TYPE GetSx3Cache("AD2_PERC","X3_TIPO") SIZE TAMSX3("AD2_PERC")[1] ALIGN 1 HEADERCLICK { || } OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][4]  }') TITLE TxSX3Campo("UM_DESC")[1] 		SIZE TAMSX3("UM_DESC")[1]    ALIGN 1 HEADERCLICK { || } OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][5]  }') TITLE TxSX3Campo("AD2_UNIDAD")[1] 	SIZE TAMSX3("AD2_UNIDAD")[1] ALIGN 1 HEADERCLICK { || } OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][6]  }') TITLE TxSX3Campo("ADK_NOME")[1]		SIZE TAMSX3("ADK_NOME")[1]   ALIGN 1 HEADERCLICK { || } OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][7]  }') TITLE TxSX3Campo("AD2_RESPUN")[1] 	SIZE TAMSX3("AD2_RESPUN")[1] ALIGN 1 HEADERCLICK { || } OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][8]  }') TITLE TxSX3Campo("A3_NOME")[1]		SIZE TAMSX3("A3_NOME")[1]    ALIGN 1 HEADERCLICK { || } ID "A3_NOME" OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][9]  }') TITLE TxSX3Campo("AD2_CODPAP")[1] 	SIZE TAMSX3("AD2_CODPAP")[1] ALIGN 1 HEADERCLICK { || } OF oTime
	ADD COLUMN oColumn DATA &('{ || aTime[oTime:At()][10] }') TITLE TxSX3Campo("UM_DESC")[1] 		SIZE TAMSX3("UM_DESC")[1]    ALIGN 1 HEADERCLICK { || } OF oTime

ACTIVATE FWBROWSE oTime            

aParc := aCab[oCab:At()][FLB_BPARC]

//Folder 3: Parceiros  
DEFINE FWBROWSE oParc DATA ARRAY ARRAY aParc LINE BEGIN 1 OF oFolder:aDialogs[ 3 ]

	OnlyGrid( oParc )

	If FATPDIsObFuscated("AC4_NOME")
		aObsFields := {"AC4_NOME"}
	EndIf

	If FATPDActive() .And. FTPDUse(.T.)
		oParc:SetObfuscFields(aObsFields)
	EndIf
	
	ADD COLUMN oColumn DATA &('{ || aParc[oParc:At()][1]  }') TITLE TxSX3Campo("AD4_PARTNE")[1] 	 SIZE TAMSX3("AD4_PARTNE")[1] ALIGN 1 HEADERCLICK { || } ID "AD4_PARTNE" OF oParc
	ADD COLUMN oColumn DATA &('{ || aParc[oParc:At()][2]  }') TITLE TxSX3Campo("AC4_NOME")[1]    	 SIZE TAMSX3("AC4_NOME")[1]   ALIGN 1 HEADERCLICK { || } ID "AC4_NOME" OF oParc
	ADD COLUMN oColumn DATA &('{ || aParc[oParc:At()][3]  }') TITLE STR0172 SIZE 80 ALIGN 1 HEADERCLICK { || } OF oParc		//"Observações"

ACTIVATE FWBROWSE oParc            

aCont := aCab[oCab:At()][FLB_BCONT]
//Folder 4: Contatos  
DEFINE FWBROWSE oContac DATA ARRAY ARRAY aCont LINE BEGIN 1 OF oFolder:aDialogs[ 4 ]

	OnlyGrid( oContac )

	If FATPDIsObFuscated("U5_CONTAT")
		aObsFields := {"U5_CONTAT"}
	EndIf

	If FATPDActive() .And. FTPDUse(.T.)
		oContac:SetObfuscFields(aObsFields)
	EndIf
	
	ADD COLUMN oColumn DATA &('{ || aCont[oContac:At()][1]  }') TITLE TxSX3Campo("AD9_CODCON")[1]    SIZE TAMSX3("AD9_CODCON")[1] ALIGN 1 HEADERCLICK { || } ID "AD9_CODCON"  OF oContac
	ADD COLUMN oColumn DATA &('{ || aCont[oContac:At()][2]  }') TITLE TxSX3Campo("U5_CONTAT")[1]     SIZE TAMSX3("U5_CONTAT")[1]  ALIGN 1 HEADERCLICK { || } ID "U5_CONTAT" OF oContac

ACTIVATE FWBROWSE oContac

aProd := aCab[oCab:At()][FLB_BPROD]
//Folder 5: Produtos 
DEFINE FWBROWSE oProd DATA ARRAY ARRAY aProd LINE BEGIN 1 OF oFolder:aDialogs[ 5 ]
	
	OnlyGrid( oProd )

	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][1]   }') TITLE TxSX3Campo("ADJ_PROD")[1]    SIZE TAMSX3("ADJ_PROD")[1]   ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][2]   }') TITLE TxSX3Campo("B1_DESC")[1]     SIZE TAMSX3("B1_DESC")[1]    ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][3]   }') TITLE TxSX3Campo("ADJ_QUANT")[1]   TYPE GetSx3Cache("ADJ_QUANT","X3_TIPO")  SIZE TAMSX3("ADJ_QUANT")[1] DECIMAL TAMSX3("ADJ_QUANT")[2] PICTURE PesqPict("ADJ","ADJ_QUANT") ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][4]   }') TITLE TxSX3Campo("ADJ_PRUNIT")[1]  TYPE GetSx3Cache("ADJ_PRUNIT","X3_TIPO") SIZE TAMSX3("ADJ_PRUNIT")[1] DECIMAL TAMSX3("ADJ_PRUNIT")[2] PICTURE PesqPict("ADJ","ADJ_PRUNIT") ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][5]   }') TITLE TxSX3Campo("ADJ_VALOR")[1]   TYPE GetSx3Cache("ADJ_VALOR","X3_TIPO")  SIZE TAMSX3("ADJ_VALOR")[1] DECIMAL TAMSX3("ADJ_VALOR")[2] PICTURE PesqPict("ADJ","ADJ_VALOR") ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][6]   }') TITLE TxSX3Campo("ADJ_NUMORC")[1]  SIZE TAMSX3("ADJ_NUMORC")[1] ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][7]   }') TITLE TxSX3Campo("ADJ_PROPOS")[1]  SIZE TAMSX3("ADJ_PROPOS")[1] ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][8]   }') TITLE TxSX3Campo("ADJ_TPVEND")[1]  SIZE TAMSX3("ADJ_TPVEND")[1] ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][9]   }') TITLE TxSX3Campo("ADJ_CATEG")[1]   SIZE TAMSX3("AD9_CODCON")[1] ALIGN 1 HEADERCLICK { || } OF oProd
	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][10]  }') TITLE TxSX3Campo("ACU_DESC")[1]    SIZE TAMSX3("AD9_CODCON")[1] ALIGN 1 HEADERCLICK { || } OF oProd
	
ACTIVATE FWBROWSE oProd

//	ADD COLUMN oColumn DATA &('{ || aProd[oProd:At()][3]   }') TITLE TxSX3Campo("ADJ_QUANT")[1]   TYPE GetSx3Cache("ADJ_QUANT","X3_TIPO")  SIZE TAMSX3("ADJ_QUANT")[1] PICTURE PesqPict("ADJ","ADJ_QUANT") ALIGN 1 HEADERCLICK { || } OF oProd  ALIGN 1 HEADERCLICK { || } OF oProd

aEvol := aCab[oCab:At()][FLB_BEVOL]
//Folder 6: Evolução da Venda
DEFINE FWBROWSE oEvol DATA ARRAY ARRAY aEvol LINE BEGIN 1 OF oFolder:aDialogs[ 6 ]
	
	OnlyGrid( oEvol )

	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][1]   }') TITLE TxSX3Campo("AIJ_PROVEN")[1]   SIZE TAMSX3("AIJ_PROVEN")[1] ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][2]   }') TITLE TxSX3Campo("AIJ_STAGE  ")[1]  SIZE TAMSX3("AIJ_STAGE  ")[1] ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][3]   }') TITLE TxSX3Campo("AC2_DESCRI")[1]   SIZE TAMSX3("AC2_DESCRI")[1] ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][4]   }') TITLE TxSX3Campo("AIJ_DTINIC")[1]   TYPE GetSx3Cache("ADJ_QUANT","X3_TIPO") SIZE TAMSX3("AIJ_DTINIC")[1] ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][5]   }') TITLE TxSX3Campo("AIJ_HRINIC ")[1]  SIZE TAMSX3("AIJ_HRINIC ")[1] PICTURE PesqPict("AIJ","AIJ_HRINIC") ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][6]   }') TITLE TxSX3Campo("AIJ_DTLIMI")[1]   TYPE GetSx3Cache("ADJ_QUANT","X3_TIPO") SIZE TAMSX3("AIJ_DTLIMI")[1] ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][7]   }') TITLE TxSX3Campo("AIJ_HRLIMI")[1]   SIZE TAMSX3("AIJ_HRLIMI")[1] PICTURE PesqPict("AIJ","AIJ_HRLIMI") ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][8]   }') TITLE TxSX3Campo("AIJ_DTENCE")[1]   TYPE GetSx3Cache("ADJ_QUANT","X3_TIPO") SIZE TAMSX3("AIJ_DTENCE")[1] ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][9]   }') TITLE TxSX3Campo("AIJ_HRENCE")[1]   SIZE TAMSX3("AIJ_HRENCE")[1] PICTURE PesqPict("AIJ","AIJ_HRENCE") ALIGN 1 HEADERCLICK { || } OF oEvol
	ADD COLUMN oColumn DATA &('{ || aEvol[oEvol:At()][10]  }') TITLE TxSX3Campo("AIJ_STATUS ")[1]  SIZE TAMSX3("AIJ_STATUS ")[1] ALIGN 1 HEADERCLICK { || } OF oEvol
	
ACTIVATE FWBROWSE oEvol

//Possibilita a visualizacao cheia do Browse superior
oFWLayer:SetLinSplit( "LINEINF", CONTROL_ALIGN_TOP,, )

FATPDUnload()

EndIf

aSize(aObsFields, 0)
aSize(aPDFields, 0)

Return( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Qpt

Query de Oportunidades

@sample		Tkc010Qpt(cConta, cLoja, cEntidad, cStatus, dData)
                                                                    
@param		ExpC - Codigo da conta
			ExpC - Loja da conta
			ExpC - Tipo de entidade( Ex.: SA1, SUS )	
			ExpC - Status da Oportunidade
			ExpC - Data do parametro

@return		    Array da query

@author		Thamara Villa Jacomo
@since			23/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------

Static Function Tkc010Qpt(cConta, cLoja, cEntidad, cStatus, dData)

Local cAlias	 := GetNextAlias()   
Local cQuery 	 := "" 
Local cWhere	 := ""
Local aOport	 := {}

cWhere := "%(" 
If Alltrim( cStatus ) == '1,2,3,9'
	cWhere += " (AD1.AD1_STATUS IN "+FormatIn(cStatus,",")+") "
Else
	cWhere += " (AD1.AD1_STATUS ='"+cStatus+"') "
EndIf
cWhere += ")%"

If AllTrim( cEntidad ) == 'SA1'

	BEGINSQL ALIAS cAlias

		SELECT AD1.AD1_FILIAL, AD1.AD1_NROPOR, AD1.AD1_REVISA, AD1.AD1_DESCRI, AD1.AD1_VEND, SA3.A3_NOME, AD1.AD1_VERBA
			,AD1.AD1_DTINI, AD1.AD1_DTPFIM, AD1.AD1_PROVEN, AD1.AD1_STAGE, AD1.AD1_FEELIN, AD1.AD1_STATUS

		FROM %Table:AD1% AD1

		LEFT JOIN %Table:SA3% SA3 ON ( SA3.A3_FILIAL = %Exp:xFilial( "SA3" )% AND SA3.A3_COD = AD1.AD1_VEND AND SA3.%NotDel% )
		INNER JOIN %Table:SA1% SA1 ON ( SA1.A1_FILIAL = %Exp:xFilial( "SA1" )% AND SA1.A1_COD = AD1.AD1_CODCLI AND SA1.A1_LOJA = AD1.AD1_LOJCLI AND SA1.%NotDel% )
		WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_CODCLI = %Exp:cConta% AND AD1.AD1_LOJCLI = %Exp:cLoja% 
			AND  %Exp:cWhere% AND AD1.AD1_DATA >= %Exp:dData%		
		ORDER BY AD1.AD1_NROPOR                              
		
	ENDSQL  
Else
	BEGINSQL ALIAS cAlias

		SELECT AD1.AD1_FILIAL, AD1.AD1_NROPOR, AD1.AD1_REVISA, AD1.AD1_DESCRI, AD1.AD1_VEND, SA3.A3_NOME, AD1.AD1_VERBA
			,AD1.AD1_DTINI, AD1.AD1_DTPFIM, AD1.AD1_PROVEN, AD1.AD1_STAGE, AD1.AD1_FEELIN, AD1.AD1_STATUS

		FROM %Table:AD1% AD1

		LEFT JOIN %Table:SA3% SA3 ON ( SA3.A3_FILIAL = %Exp:xFilial( "SA3" )% AND SA3.A3_COD = AD1.AD1_VEND AND SA3.%NotDel% )
		INNER JOIN %Table:SUS% SUS ON ( SUS.US_FILIAL = %Exp:xFilial( "SUS" )% AND SUS.US_COD = AD1.AD1_PROSPE AND SUS.US_LOJA = AD1.AD1_LOJPRO AND SUS.%NotDel% )	
		WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_PROSPE = %Exp:cConta% AND AD1.AD1_LOJPRO = %Exp:cLoja% 
			AND  %Exp:cWhere% AND AD1.AD1_DATA >= %Exp:dData%
		ORDER BY AD1.AD1_NROPOR

	ENDSQL  
EndIf
                                                            
cQuery := GetLastQuery()[ 2 ]
                                                                
DbSelectArea( cAlias )
DbGoTop()
	While ( cAlias )->( !EOF() )
	
		aAdd( aOport, { ( cAlias )->AD1_FILIAL	,;                                    
						( cAlias )->AD1_NROPOR	,;
						( cAlias )->AD1_REVISA	,;
						( cAlias )->AD1_DESCRI	,;
						( cAlias )->AD1_VEND	,;          		
						( cAlias )->A3_NOME		,;
						( cAlias )->AD1_VERBA	,;
						STod( ( cAlias )->AD1_DTINI )	,;
						STod( ( cAlias )->AD1_DTPFIM )  ,;
						( cAlias )->AD1_PROVEN	,;
						( cAlias )->AD1_STAGE	,;  
						( cAlias )->AD1_FEELIN  ,;
						Tkc010Cnc( ( cAlias )->AD1_NROPOR ) ,;
						Tkc010Tim( ( cAlias )->AD1_NROPOR )	,;
						Tkc010Par( ( cAlias )->AD1_NROPOR ) ,;   
						Tkc010Con( ( cAlias )->AD1_NROPOR ) ,;
						Tkc010Prd( ( cAlias )->AD1_NROPOR ) ,;
						Tkc010Evo( ( cAlias )->AD1_NROPOR ) } )				
	
	    ( cAlias )->( DbSkip())
	EndDo                      

( cAlias )->( DbCloseArea() )
	
Return( aOport )	

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Cnc

Query de Concorrentes

@sample	Tkc010Cnc( cNrOpor )   
                
@param		ExpC - Oportunidades
			

@return		    Array da query

@author		Thamara Villa Jacomo
@since			23/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function Tkc010Cnc( cNrOpor )   

Local cAliasConc  := GetNextAlias()
Local aQryConc	  := {}
Local cQryConc	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Concorrentes   			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGINSQL ALIAS cAliasConc

	SELECT AD1.AD1_NROPOR, AD3.AD3_NROPOR, AD3.AD3_FILIAL, AD3.AD3_REVISA, AD3.AD3_HISTOR, AD3.AD3_CODCON, AC3.AC3_NOME,
	  AD3.AD3_PRECO, AD3.AD3_MOEDA, AD3.AD3_FCS, SX5.X5_DESCRI, AD3.AD3_FCI, SX52.X5_DESCRI X5_DESCRI2
	
	FROM %Table:AD1% AD1 
	
	LEFT JOIN %Table:AD3% AD3 ON AD3.AD3_FILIAL = %Exp:xFilial( "AD3" )% AND AD3.AD3_NROPOR = AD1.AD1_NROPOR AND AD3.AD3_REVISA = AD1.AD1_REVISA AND AD3.%NotDel%
	LEFT JOIN %Table:AC3% AC3 ON AC3.AC3_FILIAL = %Exp:xFilial( "AC3" )% AND AC3.AC3_CODCON = AD3.AD3_CODCON AND AC3.%NotDel%
	LEFT JOIN %Table:SX5% SX5 ON  SX5.X5_FILIAL = %Exp:xFilial( "SX5" )% AND   SX5.X5_CHAVE = AD3.AD3_FCS AND SX5.X5_TABELA = 'A6' AND SX5.%NotDel%
	LEFT JOIN %Table:SX5% SX52 ON SX52.X5_FILIAL = %Exp:xFilial( "SX5" )% AND  SX52.X5_CHAVE = AD3.AD3_FCI AND SX52.X5_TABELA = 'A6' AND SX52.%NotDel% 
	 
	WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_NROPOR = %Exp:cNrOpor% 
	
	ORDER BY AD1.AD1_NROPOR
	                                           
ENDSQL                                        
          
cQryConc := GetLastQuery()[ 2 ]

DbSelectArea( cAliasConc )
DbGoTop()              

	While ( cAliasConc )->( !EOF() )
		aAdd( aQryConc, { ( cAliasConc )->AD3_CODCON   ,;
							( cAliasConc )->AC3_NOME     ,;
						( cAliasConc )->AD3_PRECO		,;                            
						( cAliasConc )->AD3_FCS      ,;
						( cAliasConc )->X5_DESCRI    ,;
						( cAliasConc )->AD3_FCI      ,;
						( cAliasConc )->X5_DESCRI2   } )
					
		( cAliasConc )->( DbSkip() )					
	EndDo

( cAliasConc )->( DbCloseArea() )

Return( aQryConc )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Tim

Query de Time de Vendas

@sample	Tkc010Tim( cNrOpor )
                
@param		ExpC - Oportunidade
			

@return		    Array da query

@author		Thamara Villa Jacomo
@since			23/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function Tkc010Tim( cNrOpor )   

Local cAliasTime  := GetNextAlias()
Local aQryTime	  := {}
Local cQryTime 	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Time de Vendas  			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGINSQL ALIAS cAliasTime

	SELECT AD1.AD1_NROPOR, AD2.AD2_FILIAL, AD2.AD2_REVISA, AD2.AD2_HISTOR, AD2.AD2_VEND, SA3.A3_NOME, AD2.AD2_PERC
			,SUM.UM_DESC, AD2.AD2_UNIDAD, ADK.ADK_NOME, AD2.AD2_RESPUN, SA32.A3_NOME A3_NOME2, AD2.AD2_CODPAP, SUM2.UM_DESC UM_DESC2
	
	FROM %Table:AD1% AD1

		INNER JOIN %Table:AD2% AD2  ON AD2.AD2_FILIAL = %Exp:xFilial( "AD2" )% AND AD2.AD2_NROPOR = AD1.AD1_NROPOR AND AD2.AD2_REVISA = AD1.AD1_REVISA AND AD2.%NotDel%
		LEFT JOIN %Table:SA3% SA3  ON SA3.A3_FILIAL = %Exp:xFilial( "SA3" )% AND SA3.A3_COD = AD2.AD2_VEND AND SA3.%NotDel%
		LEFT JOIN %Table:SA3% SA32 ON SA32.A3_FILIAL = %Exp:xFilial( "SA3" )% AND SA32.A3_COD = AD2.AD2_RESPUN AND SA32.%NotDel%
		LEFT JOIN %Table:SUM% SUM   ON SUM.UM_FILIAL = %Exp:xFilial( "SUM" )% AND SUM.UM_CARGO = AD2.AD2_CODCAR AND SUM.%NotDel%
		LEFT JOIN %Table:SUM% SUM2  ON SUM2.UM_FILIAL = %Exp:xFilial( "SUM" )% AND SUM2.UM_CARGO = AD2.AD2_CODPAP AND SUM2.%NotDel%
		LEFT JOIN %Table:ADK% ADK   ON ADK.ADK_FILIAL = %Exp:xFilial( "ADK" )% AND ADK.ADK_COD = AD2.AD2_UNIDAD AND ADK.%NotDel%
		
	WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_NROPOR = %Exp:cNrOpor% 
	
	ORDER BY AD1.AD1_NROPOR
		
ENDSQL

cQryTime := GetLastQuery()[ 2 ]

DbSelectArea( cAliasTime )
DbGoTop()
	While ( cAliasTime )->( !EOF() )
		aAdd( aQryTime, { ( cAliasTime )->AD2_VEND   ,;
						  ( cAliasTime )->A3_NOME    ,;
						  ( cAliasTime )->AD2_PERC	 ,;                            
						  ( cAliasTime )->UM_DESC    ,;
						  ( cAliasTime )->AD2_UNIDAD ,;
						  ( cAliasTime )->ADK_NOME   ,;
						  ( cAliasTime )->AD2_RESPUN ,;
                          ( cAliasTime )->A3_NOME2	 ,;
						  ( cAliasTime )->AD2_CODPAP ,;
						  ( cAliasTime )->UM_DESC2  } )			
					
		( cAliasTime )->( DbSkip() )					
	EndDo

( cAliasTime )->( DbCloseArea() )                                        

Return( aQryTime )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Par

Query de Parceiros

@sample	Tkc010Par( cNrOpor )
                
@param		ExpC - Oportunidade
			

@return		    Array da query

@author		Thamara Villa Jacomo
@since			23/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function Tkc010Par( cNrOpor )   

Local cAliasParc  := GetNextAlias()
Local aQryParc	  := {}
Local cQryParc 	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parceiros 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGINSQL ALIAS cAliasParc
	SELECT AD1.AD1_NROPOR, AD4.AD4_FILIAL, AD4.AD4_NROPOR, AD4.AD4_REVISA, AD4.AD4_HISTOR, AD4.AD4_PARTNE, 
		AC4.AC4_NOME, SYP.YP_TEXTO

	FROM %Table:AD1% AD1

	INNER JOIN %Table:AD4% AD4 ON AD4.AD4_FILIAL = %Exp:xFilial( "AD4" )% AND AD4.AD4_NROPOR = AD1.AD1_NROPOR AND AD4.AD4_REVISA = AD1.AD1_REVISA AND AD4.%NotDel%
	INNER JOIN %Table:AC4% AC4 ON AC4.AC4_FILIAL = %Exp:xFilial( "AC4" )% AND AC4.AC4_PARTNE = AD4.AD4_PARTNE AND AC4.%NotDel%
	 LEFT JOIN %Table:SYP% SYP ON SYP.YP_FILIAL = %Exp:xFilial( "SYP" )% AND SYP.YP_CHAVE = AD4.AD4_CODMEM AND SYP.%NotDel%

	WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_NROPOR = %Exp:cNrOpor%

ORDER BY AD1.AD1_NROPOR 

ENDSQL

cQryParc := GetLastQuery()[ 2 ]

DbSelectArea( cAliasParc )
DbGoTop()

While ( cAliasParc )->( !Eof() )  

	aAdd( aQryParc, { ( cAliasParc )->AD4_PARTNE 	,;
					  ( cAliasParc )->AC4_NOME      ,;
					  ( cAliasParc )->YP_TEXTO      } )

	  ( cAliasParc )->( DbSkip() )
EndDo 

( cAliasParc )->( DbCloseArea() )

Return( aQryParc ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Con

Query de Concorrentes

@sample	Tkc010Con( cNrOpor )
                
@param		ExpC - Oportunidade
		

@return		    Array da query

@author		Thamara Villa Jacomo
@since			23/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function Tkc010Con( cNrOpor )   

Local cAliasCont  := GetNextAlias()
Local aQryCont	  := {}
Local cQryCont 	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Contatos		 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGINSQL ALIAS cAliasCont
	SELECT AD1.AD1_NROPOR, AD9.AD9_FILIAL, AD9.AD9_REVISA, AD9.AD9_HISTOR, AD9.AD9_CODCON, SU5.U5_CONTAT

	FROM %Table:AD1% AD1

	INNER JOIN %Table:AD9% AD9 ON AD9.AD9_FILIAL = %Exp:xFilial( "AD9" )% AND AD9.AD9_NROPOR = AD1.AD1_NROPOR AND AD9.AD9_REVISA = AD1.AD1_REVISA AND AD9.%NotDel%
	INNER JOIN %Table:SU5% SU5 ON SU5.U5_FILIAL = %Exp:xFilial( "SU5" )% AND SU5.U5_CODCONT = AD9.AD9_CODCON AND SU5.%NotDel%

	WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_NROPOR = %Exp:cNrOpor%

ORDER BY AD1.AD1_NROPOR 

ENDSQL

cQryCont := GetLastQuery()[ 2 ]

DbSelectArea( cAliasCont )
DbGoTop()

While ( cAliasCont )->( !Eof() )  

	aAdd( aQryCont, { ( cAliasCont )->AD9_CODCON 	,;
					  ( cAliasCont )->U5_CONTAT     } )

	  ( cAliasCont )->( DbSkip() )
EndDo 

( cAliasCont )->( DbCloseArea() )

Return( aQryCont ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Prd

Query de Produtos

@sample	Tkc010Prd( cNrOpor )
                
@param		ExpC - Oportunidades
			

@return		    Array da query

@author		Thamara Villa Jacomo
@since			23/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function Tkc010Prd( cNrOpor )   

Local cAliasProd  := GetNextAlias()
Local aQryProd	  := {}
Local cQryProd 	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Produtos		 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGINSQL ALIAS cAliasProd
	SELECT AD1.AD1_NROPOR, ADJ.ADJ_FILIAL, ADJ.ADJ_REVISA, ADJ.ADJ_ITEM, ADJ.ADJ_PROD, SB1.B1_DESC, ADJ.ADJ_QUANT, ADJ.ADJ_PRUNIT,
		ADJ.ADJ_VALOR, ADJ.ADJ_NUMORC, ADJ.ADJ_PROPOS, ADJ.ADJ_TPVEND, ADJ.ADJ_HISTOR, ADJ.ADJ_CATEG, ACU.ACU_DESC

	FROM %Table:AD1% AD1

	INNER JOIN %Table:ADJ% ADJ ON ADJ.ADJ_FILIAL = %Exp:xFilial( "ADJ" )% AND ADJ.ADJ_NROPOR = AD1.AD1_NROPOR AND ADJ.ADJ_REVISA = AD1.AD1_REVISA AND ADJ.%NotDel%
   	 LEFT JOIN %Table:SB1% SB1 ON  SB1.B1_FILIAL = %Exp:xFilial( "SB1" )% AND SB1.B1_COD = ADJ.ADJ_PROD AND SB1.%NotDel%
   	 LEFT JOIN %Table:ACU% ACU ON ACU.ACU_FILIAL = %Exp:xFilial( "ACU" )% AND ACU.ACU_COD = ADJ.ADJ_CATEG AND ACU.%NotDel%

	WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_NROPOR = %Exp:cNrOpor%

ORDER BY AD1.AD1_NROPOR 

ENDSQL

cQryProd := GetLastQuery()[ 2 ]

DbSelectArea( cAliasProd )
DbGoTop()

While ( cAliasProd )->( !Eof() )  

	aAdd( aQryProd, { ( cAliasProd )->ADJ_PROD		,;
   					  ( cAliasProd )->B1_DESC		,;
   					  ( cAliasProd )->ADJ_QUANT     ,;
   					  ( cAliasProd )->ADJ_PRUNIT	,;
   					  ( cAliasProd )->ADJ_VALOR		,;
					  ( cAliasProd )->ADJ_NUMORC	,;   					  
					  ( cAliasProd )->ADJ_PROPOS	,;
					  X3COMBO( "ADJ_TPVEND",( cAliasProd )->ADJ_TPVEND ) ,;
  					  ( cAliasProd )->ADJ_CATEG 	,;
					  ( cAliasProd )->ACU_DESC     } )

	  ( cAliasProd )->( DbSkip() )
EndDo 

( cAliasProd )->( DbCloseArea() )

Return( aQryProd )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tkc010Evo

Query de Oportunidades

@sample	Tkc010Evo( cNrOpor )  
                
@param		ExpC - Codigo da oportunidade
			

@return		    Array da query

@author		Thamara Villa Jacomo
@since			23/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function Tkc010Evo( cNrOpor )   

Local cAliasEvol  := GetNextAlias()
Local aQryEvol	  := {}
Local cQryEvol 	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Evolutos		 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGINSQL ALIAS cAliasEvol
	SELECT AD1.AD1_NROPOR, AIJ.AIJ_FILIAL, AIJ.AIJ_REVISA, AIJ.AIJ_PROVEN, AIJ.AIJ_STAGE, AC2.AC2_DESCRI, AIJ.AIJ_DTINIC,
	 AIJ.AIJ_HRINIC, AIJ.AIJ_DTLIMI, AIJ.AIJ_HRLIMI, AIJ.AIJ_DTENCE, AIJ.AIJ_HRENCE, AIJ.AIJ_HISTOR, AIJ.AIJ_STATUS

	FROM %Table:AD1% AD1

	INNER JOIN %Table:AIJ% AIJ ON AIJ.AIJ_FILIAL = %Exp:xFilial( "AIJ" )% AND AIJ.AIJ_NROPOR = AD1.AD1_NROPOR AND AIJ.AIJ_REVISA = AD1.AD1_REVISA AND AIJ.%NotDel%
	INNER JOIN %Table:AC2% AC2 ON AC2.AC2_FILIAL = %Exp:xFilial( "AC2" )% AND AC2.AC2_PROVEN = AIJ.AIJ_PROVEN AND AC2.AC2_STAGE = AIJ.AIJ_STAGE AND AC2.%NotDel% 

	WHERE AD1.AD1_FILIAL = %Exp:xFilial( "AD1" )% AND AD1.%NotDel% AND AD1.AD1_NROPOR = %Exp:cNrOpor%

ORDER BY AD1.AD1_NROPOR 

ENDSQL

cQryEvol := GetLastQuery()[ 2 ]

DbSelectArea( cAliasEvol )
DbGoTop()

While ( cAliasEvol )->( !Eof() )  

	aAdd( aQryEvol, { ( cAliasEvol )->AIJ_PROVEN		  ,;
  					  ( cAliasEvol )->AIJ_STAGE          ,;
  					  ( cAliasEvol )->AC2_DESCRI		  ,;				
  					  STod( ( cAliasEvol )->AIJ_DTINIC ) ,;
   					  ( cAliasEvol )->AIJ_HRINIC     	  ,;
  					  STod( ( cAliasEvol )->AIJ_DTLIMI ) ,;
   					  ( cAliasEvol )->AIJ_HRLIMI		  ,;
					  STod( ( cAliasEvol )->AIJ_DTENCE ) ,;   					  
					  ( cAliasEvol )->AIJ_HRENCE		  ,;
  					   X3COMBO( "AIJ_STATUS",( cAliasEvol )->AIJ_STATUS )  } )

	  ( cAliasEvol )->( DbSkip() )
EndDo 

( cAliasEvol )->( DbCloseArea() )

Return( aQryEvol )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC10ABrOpr

Executa o Change para criar o dinamismo do Browse superior com os Folders.

@sample	TkC10ABrOpr(aCab,aConc,aTime,aParc,aCont,aProd,aEvol,oCab,oConc,oTime,oParc,oContac,oProd,oEvol)

@param		ExpC1 -> Array contendo a query de todos os dados a serem 
									exibidos no Browse. 
			ExpC2 -> Array do folder de concorrentes que guarda a posição da 
						linha pai para criar o dinamismo na tela.
			ExpC3 -> Array do folder de Time de Vendas que guarda a posição da 
						linha pai para criar o dinamismo na tela.
			ExpC4 -> Array do folder de Parceiros que guarda a posição da 
						linha pai para criar o dinamismo na tela.
			ExpC5 -> Array do folder de Contatos que guarda a posição da 
						linha pai para criar o dinamismo na tela.
			ExpC6 -> Array do folder de Produtos que guarda a posição da 
						linha pai para criar o dinamismo na tela.
			ExpC7 -> Array do folder de Evolução que guarda a posição da 
						linha pai para criar o dinamismo na tela.						
			ExpC8 -> Objeto do painel principal(superior).
			ExpC9  -> Objeto do Folder 1 - Concorrente
			ExpC10 -> Objeto do Folder 2 - Time de Vendas
			ExpC11 -> Objeto do Folder 3 - Parceiros
			ExpC12 -> Objeto do Folder 4 - Contatos
			ExpC13 -> Objeto do Folder 5 - Produtos
			ExpC14 -> Objeto do Folder 6 - Evolução 

@return		Nil

@author		Thamara Villa Jacomo
@since			21/10/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function TkC10ABrOpr(aCab,aConc,aTime,aParc,aCont,aProd,aEvol,oCab,oConc,oTime,oParc,oContac,oProd,oEvol)

If ValType( oConc ) == "O" .AND. ValType( oTime ) == "O" .And. ValType( oParc ) == "O" ;
	.And. ValType( oContac ) == "O" .And. ValType( oProd ) == "O" .And. ValType( oEvol ) == "O"
	
	aConc := aCab[oCab:At()][FLB_BCONC]
	oConc:SetArray(aCab[oCab:At()][FLB_BCONC])
	aTime := aCab[oCab:At()][FLB_BTIME]
	oTime:SetArray(aCab[oCab:At()][FLB_BTIME])
	aParc := aCab[oCab:At()][FLB_BPARC]
	oParc:SetArray(aCab[oCab:At()][FLB_BPARC])
	aCont := aCab[oCab:At()][FLB_BCONT]
	oContac:SetArray(aCab[oCab:At()][FLB_BCONT])
	aProd := aCab[oCab:At()][FLB_BPROD]
	oProd:SetArray(aCab[oCab:At()][FLB_BPROD]) 
	aEvol := aCab[oCab:At()][FLB_BEVOL]
	oEvol:SetArray(aCab[oCab:At()][FLB_BEVOL])

	oConc:Refresh() 
	oTime:Refresh()
	oParc:Refresh()
	oContac:Refresh()
	oProd:Refresh()
	oEvol:Refresh()
EndIf	    
	
Return( Nil )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive

//-----------------------------------------------------------------------------
/*/{Protheus.doc} OnlyGrid
    @description
    Função que desabilita os componentes de configuração, filtros, busca e
	relatório referente ao objeto FWBrowse passado como parâmetro.

    @type  Function
    @sample OnlyGrid( oBrowse )
    @author Squad CRM & Faturamento
    @since 16/07/2020
    @version P12.1.27    
    @return return, Nulo
/*/
//-----------------------------------------------------------------------------
Static Function OnlyGrid( oObj )

oObj:DisableConfig()
oObj:DisableFilter()
oObj:DisableLocate()
oObj:DisableReport()
oObj:DisableSaveConfig()
oObj:DisableSeek()

Return Nil