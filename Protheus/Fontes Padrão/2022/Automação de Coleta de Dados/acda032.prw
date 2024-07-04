#INCLUDE "Acda032.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³                                 ³±±
±±³      02  ³Erike Yuri da Silva       ³06/12/2005                       ³±±
±±³      03  ³                          ³                                 ³±±
±±³      04  ³Erike Yuri da Silva       ³11/01/2006                       ³±±
±±³      05  ³Erike Yuri da Silva       ³11/01/2006                       ³±±
±±³      06  ³Erike Yuri da Silva       ³23/12/2005                       ³±±
±±³      07  ³Erike Yuri da Silva       ³23/12/2005                       ³±±
±±³      08  ³                          ³                                 ³±±
±±³      09  ³                          ³                                 ³±±
±±³      10  ³Erike Yuri da Silva       ³ 06/12/2005                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³         FUNCOES DISPONIVEIS NO PROGRAMA DE MONITORAMENTO DO INVENTARIO DO ACD 								 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ARVORE DE FUNCOES                    ³T.FUNCAO| DESCRICAO                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ACDA032                              ³Function³Funcao princial                                            ³±±
±±³ ÃÄÄÄ>Info_DB                        ³Static  ³Cria arrays auxiliares para trabalho com Browse            ³±±
±±³ ÃÄÄÄ>GetBrwProd                     ³Static  ³Gera arrays de trabalho com as qtd. coletadas, montando sua³±±
±±³ ³                                   ³        ³estrutra a partir do tipo de inventario (Produto,Endereco).³±±
±±³ ÃÄÄÄ>Tela                           ³        ³                                             			     ³±±
±±³ ³     ÃÄÄÄ>ViewFerret               ³Static  ³Visualiza/Oculta a barra de ferramentas                    ³±±
±±³ ³     ÃÄÄÄ>AtuGetDados              ³Static  ³Redimensiona os objetos contidos nos folders apos a        ³±±
±±³ ³     ³                             ³        ³execucao da funcao ViewFerret()                            ³±±
±±³ ³     ÃÄÄÄ>AtuBrw                   ³Static  ³Funcao que atualiza o objeto MsGetDados do controle  de    ³±±
±±³ ³     ³                             ³        ³contagens do inventario.                                   ³±±
±±³ ³     ÃÄÄÄ>AtuBLine                 ³Static  ³Cria as colunas para atualizaco do oBrw:bLine              ³±±
±±³ ³     ÀÄÄÄ>AtuColsBrw               ³Static  ³Atualiza a coluna do browser informado no array.Lembrando  ³±±
±±³ ³             ³                     ³        ³que para esta alteracao ter efeito sera necessario fechar a³±±
±±³ ³             ³                     ³        ³dialog e chamar a funcao novamente.                        ³±±
±±³ ³             ÀÄÄÄ>ConfigCols       ³Static  ³Configura a visualizaco das colunas do brw a partir do InI ³±±
±±³ ÃÄÄÄ>Atu                            ³Static  ³Atualiza os objetos de tela a partir das funcoes auxiliares³±±
±±³ ³                                   ³        ³Esta rotina eh chamada por objetos de tela e por um timer  ³±±
±±³ ÃÄÄÄ>NovoHeader                     ³Static  ³Cria um aHeader para ser utilizado por um MsGetDado        ³±±
±±³ ÃÄÄÄ>ColsCont                       ³Static  ³Cria um aCols para ser utilizado por um MsGetDados do      ³±±
±±³ ³                                   ³        ³controle  de contagens.                                    ³±±
±±³ ÃÄÄÄ>LocProd                        ³Static  ³Pesquisa o Produto no Browse                               ³±±
±±³ ÃÄÄÄ>RetItemOper                    ³Static  ³Garrega informacoes dos Itens lidos do operador possiciona-³±±
±±³ ³                                   ³        ³do na planilha.                                            ³±±
±±³ ÃÄÄÄ>RetQtd                         ³Static  ³Retorna a quantidade inventariada                          ³±±
±±³ ÃÄÄÄ>RetTituloCpo                   ³Static  ³Retorna o titulo do dicionario do campo informado.         ³±±
±±³ ÃÄÄÄ>ElegeCount                     ³Static  ³Funcao que elege a contagem batida                         ³±±
±±³ ÃÄÄÄ>AnaInv                         ³Static  ³Analisa e acerta o mestre de inventario possicionadado. Tal³±±
±±³ ³                                   ³        ³validacao eh feita pela funcao CBAnaInv  do programa       ³±±
±±³ ³                                   ³        ³ACDV035.PRG.                                               ³±±
±±³ ÃÄÄÄ>SelExclCont                    ³Static  ³Janela que permite selecionar a contagem a ser excluida    ³±±
±±³ ³     ÀÄÄÄ>VldDelCont               ³Static  ³Funcao que valida a exclusao da contagens.                 ³±±
±±³ ³            ÃÄÄÄ>DelCBBCont        ³Static  ³Exclui a Contagem do CBB                                   ³±±
±±³ ³            ÀÄÄÄ>DelCBC            ³Static  ³Exclui contagens do CBC                                    ³±±
±±³ ÀÄÄÄ>Funcoes Genericas              ³        ³                                                           ³±±
±±³        ÃÄÄÄ>RetInfoCBB              ³Static  ³Carrega informacoes da tabela CBB em um array              ³±±
±±³        ÃÄÄÄ>RetOpers                ³Static  ³Carrega informacoes dos Operados das contagens em um array ³±±
±±³        ÀÄÄÄ>AtivaTimer              ³Static  ³Ativa/Desativa o Timer                                     ³±±
±±³CB032VCB                             ³Function³Valida e Grava a quantidade inventariada, alterada no      ³±±
±±³                                     ³        ³monitor.Funcao usada no valid do campo CBC_QUANT do        ³±±
±±³                                     ³        ³MsGetDados de controle de contagens.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data da finalizacao do beta teste 01: 15/07/04                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDA032   ºAutor  ³ACD (by Erike)      º Data ³  07/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monitoramento do Inventario de Estoque do ACD, permitindo   º±±
±±º          ³realizar manutencoes.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACDA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA032()
Local oPesquisa,oGrup1,oGrup2,oGrup3,oGrup4,nOpca :=0
Local cAlias		:= If(CBA->CBA_TIPINV == "1","SB1","SBF")
Local cTitulo		:= STR0001 //"Monitoramento Inventario"
Local cPesquisa		:= Padr("",Tamsx3("B1_COD")[1])
Local cEstView		:= ""
Local cAux			:= ""
Local cDescProd		:= ""
Local cChave		:= "" 
Local cIDunit		:= ""
Local nI			:= 0
Local nPosProd      := 0
Local nTop      	:= oMainWnd:nTop
Local nLeft     	:= oMainWnd:nLeft
Local nBottom   	:= oMainWnd:nBottom -30
Local nRight    	:= oMainWnd:nRight -10
Local nLetBotao		:= (nRight/2) - 50
Local nIntervalo	:= 5000
Local lBloq			:= .F.
Local lFistCarga	:= .T.
Local lContinua		:= .T.
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local lWmsNew   	:= SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aSB7			:= SB7->(GetArea())
Local aButtons 		:= {}
Local aCfgItens		:= {}
Local aCfgSB7		:= {}
Local aCampos1		:= {}
Local aCampos2		:= {}
Local aProdutos     := {}
Local aPages		:= { "Plan01","Plan02","Info" }
Local aTitulo		:= { STR0002,STR0003,STR0004 } //"Planilha de &Manutencao"###"Planilha de &Operadores"###"&Informacoes"
Local aLegenda		:= {	{"BR_VERDE",	STR0005},; //"Contagem Batida"
							{"BR_PRETO",	STR0006},; //"Contagem nao Batida"
							{"BR_AMARELO",	STR0007},; //"Contagem em Andamento"
							{"BR_VERMELHO",	STR0008} } //"Contagem Finalizada"

Local oFont1		:= TFont():New("Arial",, -12, .T., .F.)
Local oFont2		:= TFont():New("Arial",, -12, .T., .T.)
Local nTamLote   	:= TamSX3("B8_LOTECTL")[1]
Local nTamSLote  	:= TamSX3("B8_NUMLOTE")[1]
Local nTamEnd   	:= TamSX3("BF_LOCALIZ")[1]
Local nTamSeri  	:= TamSX3("BF_NUMSERI")[1]


PRIVATE cProd,cArm,cEnd,cLote,cSLote,cNumSeri
PRIVATE cClasses		:= ""
PRIVATE lMsErroAuto
PRIVATE lMsHelpAuto
PRIVATE lModelo1		:= GetMV("MV_CBINVMD") =="1"
PRIVATE nPosSaldo		:= 10
PRIVATE aCols			:= {}
PRIVATE aHeader[0]
PRIVATE aProdBrw		:= Array(2)          // [1]: Array Completo;	[2]:Visualizacao
PRIVATE aBrwItens		:= Array(3)          // [Planilha dos operadores] Browse de Itens [1]: Titulos [2]:Sizes das Colunas [3]:Todos campos
PRIVATE aRotina   		:= { { "" , "        ", 0 , 6}}
PRIVATE aInfoBrow		:= {}
PRIVATE aOperadores 	:= {}
PRIVATE aItensOpers 	:= {}
PRIVATE aProdEnd		:= {}
PRIVATE aRegB7			:= {}
PRIVATE aHeadB7			:= Array(3)
PRIVATE aVinculo     	:= {}
PRIVATE aCores  		:= {	LoadBitmap( GetResources(), aLegenda[1,1] ), ;
LoadBitmap( GetResources(), aLegenda[2,1] ),;
LoadBitmap( GetResources(), aLegenda[3,1] ),;
LoadBitmap( GetResources(), aLegenda[4,1] )}

PRIVATE oDlgMain,oFolder,oBrw,oGetBrw,oTimer,oListOper,oItensOpers,oSayContRz,oEstView,oRegB7
PRIVATE nRecnoCBA 		:= CBA->(Recno())
PRIVATE lUsaCB001 		:= UsaCB0("01")
PRIVATE lTemHist		:= .T.
PRIVATE lAtualiz		:= .F.	//Indica se o processo esta em atualizacao ou nao
PRIVATE lCBA03201		:= ExistBlock("CBA03201")
PRIVATE lShowZero		:= .F.

If ! SuperGetMV("MV_CBPE012",.F.,.F.)
	Alert(STR0009) //"Necessario ativar o parametro MV_CBPE012"
	lContinua := .F.
EndIf

DbSelectArea("CBB")
CBB->(dbSetOrder(3))

If lContinua .And. CBA->(!Eof()) .And. ( CBA->CBA_STATUS == "0" .Or. !CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))  )
	IW_MSGBOX(	STR0019+chr(13)+chr(10)+ ; //"Nao e possivel iniciar monitoramento, pois ainda"
				STR0020,STR0021) 			//"nao existem contagens para serem analisadas!"###"Aviso"
	lContinua := .F.
EndIf


If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define botoes                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aButtons, {"PMSRRFSH",	{|| Atu((MV_PAR01==1),NIL,.T.)},"Refresh"})
	AADD(aButtons, {"FERRAM",	{|| ViewFerret()},STR0010}) //"Ferramentas"
	If  CBA->CBA_STATUS $ "123"  // 1=Em Andamento / 2=Em Pausa / 3=Contado
		If ! lModelo1
			AADD(aButtons, {"NOVACELULA",{||AutRecon()},STR0011}) //"Autoriza Recontagem"
		EndIf
		AADD(aButtons, {"BMPTRG",{||AnaInv()},STR0012}) //"Gera Inventario(SB7)"
	EndIf
	If lUsaCB001
		AADD(aButtons, {"BMPEMERG",{||DifsCont(cChave)},STR0013}) //"Comparacao de Contagens"
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do Array de Campos do Browse da Listagem de Produto³
	//³ -------------------------------------------------------------³
	//³ aCampos1[1] : Nome do Campo                                  ³
	//³ aCampos1[2] : Descricao                                      ³
	//³ aCampos1[3] : Ordem do Indice                                ³
	//³ aCampos1[4] : Chave de Pesquisa                              ³
	//³ aCampos1[5] : Visualizacao do Campo                          ³
	//³ aCampos1[6] : Valor Padrao do Campo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMv("MV_LOCALIZ")== "S"  // Controla Endereco
		aCampos1 := {;
					{"STATUS"		," ",NIL,NIL,.T.,NIL}	,	;
					{"BF_PRODUTO"	,NIL,NIL,NIL,.T.,NIL} 	, 	;
					{"B1_DESC"		,NIL,1,"SBF->BF_PRODUTO",.T.,NIL}	,	;
					{"BF_LOTECTL"	,NIL,NIL,NIL,.T.,NIL}	,	;
					{"BF_NUMLOTE"	,NIL,NIL,NIL,.T.,NIL}	,	;
					{"BF_LOCAL"		,NIL,NIL,NIL,.T.,NIL}	,	;
					{"BF_LOCALIZ"	,NIL,NIL,NIL,.T.,NIL}	,	;
					{"BF_NUMSERI"	,NIL,NIL,NIL,.T.,NIL}	,	;
					{"B3_CLASSE" 	,NIL,1,"SBF->BF_PRODUTO",.T.,NIL}	,	;
					{"BF_QUANT"  	,STR0014	,NIL,NIL,.T.,NIL}	,	; //"Sld.Estoque"
					{"CBC_QUANT"	,STR0015	,NIL	,NIL					,.T.,NIL} ,  ; //"Qtd.Eleita"
					{"BF_PRODUTO"	,STR0170  ,NIL	,NIL					,.T.,NIL}, ;	//"Ajustado"
					{"CBC_IDUNIT"	,STR0171,NIL,NIL					,Iif(lWmsNew .And. lUniCPO,.T.,.F.),NIL}}  // Unitizador 
	Else
		aCampos1 :=	{;
					{"STATUS"		," ",NIL,NIL,.T.,NIL	}	,	;
					{"B2_COD"    	,NIL,NIL,NIL,.T.,NIL	} 	, 	;
					{"B1_DESC"		,NIL,1,"SB2->B2_COD",.T.,NIL}	,	;
					{"BF_LOTECTL"	,NIL,NIL,NIL,.T.,Space(nTamLote)}	,	;
					{"BF_NUMLOTE"	,NIL,NIL,NIL,.T.,Space(nTamSLote)}	,	;
					{"B2_LOCAL"		,NIL,NIL,NIL,.T.,NIL}	,	;
					{"BF_LOTECTL"	,NIL,NIL,NIL,.T.,Space(nTamLote)}	,	;
					{"BF_NUMLOTE"	,NIL,NIL,NIL,.T.,Space(nTamSLote)}	,	;
					{"B3_CLASSE" 	,NIL,1,"SB2->B2_COD",.T.,NIL}	,	;
					{"B2_QATU"		,NIL,NIL,NIL,.T.,NIL},;
					{"CBC_QUANT"	,STR0015,NIL,NIL,.T.,NIL},; //"Ajustado"
					{"BF_PRODUTO"	,STR0170,NIL,NIL,.T.,NIL},;	
					{"CBC_IDUNIT"	,STR0171,NIL,NIL,Iif(lWmsNew .And. lUniCPO,.T.,.F.),NIL}}  // Unitizador 
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do Array de Campos do Browse da Listagem de Produto³
	//³ -------------------------------------------------------------³
	//³ aCampos2[1] : Nome do Campo                                  ³
	//³ aCampos2[2] : Descricao                                      ³
	//³ aCampos2[3] : Valid                                          ³
	//³--------------------------------------------------------------³
	//³ Atencao: Se o indice 2 e 3 for definido com NIL sera assumido³
	//³          os conteudos do dicionario de dados.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos2 :=	{;
				{"CBB_NUM"		,STR0016	,".F."}	,; //"Contagem"
				{"CBB_NUM"		,STR0017	,".F."}	,; //"Controle"
				{"CB1_NOME"		,			,".F."}	,;
				{"CBC_QUANT"	,			,"CB032VCB()"},;
				{"CBC_QTDORI"	,			,".F."},;
				{"CBB_STATUS"	,			,".F."},;
				{"XX_TPINCL"	,STR0018	,".F."} } //"Tipo de Inclusao"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do Array de Titulo do Browse da Listagem de Itens  ³
	//³ Lidos dos Operadores                                         ³
	//³--------------------------------------------------------------³
	//³ aCfgItens[1] : Link com aCampos1                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aCfgItens := {	aCampos1[03,1],; //Descricao   2
					aCampos1[06,1],; //Armazem     3
					aCampos1[07,1],; //Endereco    4
					aCampos1[04,1],; //Lote        5
					aCampos1[05,1],; //Sub-Lote    6
					aCampos1[08,1],; //N.Serie     7
					aCampos1[10,1]} //Quantidade 10
					 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do Array de Titulo do Browse da Listagem do SB7    ³
	//³--------------------------------------------------------------³
	//³ aCfgItens[1] : Link com aCampos1                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCfgSB7 := {	aCampos1[06,1],; //Armazem    3
					aCampos1[07,1],; //Endereco   4
					aCampos1[04,1],; //Lote       5
					aCampos1[05,1],; //Sub-Lote   6
					aCampos1[08,1],; //N.Serie    7
					aCampos1[10,1]}  //Quantidade 8
				

	If CBA->CBA_STATUS == "5"  // Processado
		CBM->(DbSetOrder(1))
		If !CBM->(DbSeek(xFilial("CBM")+CBA->CBA_CODINV))
			Aviso(	STR0021,STR0022			+ ;	//"Aviso"###"Este mestre de inventario nao possui historico, talvez os dados "
					STR0023 				+ ;	//"visualizados no monitor nao estejam corretos (Sld. em Estoque X Qtd. Eleita), "
					STR0024,{STR0025})			//"pois os saldos em estoque dos produtos poderiam ser outros na epoca do inventario!"###"Ok"
			lTemHist := .F.
		EndIf
	EndIf

	dbSelectArea(cAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analisando Classificacao por curva ABC                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CBA->CBA_CLASSA=="1"
		cClasses+="A"
	EndIf
	If CBA->CBA_CLASSB=="1"
		cClasses+="B"
	EndIf
	If CBA->CBA_CLASSC=="1"
		cClasses+="C"
	EndIf



	Pergunte("ACD032",.T.)

	If MV_PAR02 < 6
		nIntervalo := 6000
	Else
		nIntervalo := MV_PAR02 * 1000
	EndIf

	// Mostra Contagens Zeradas?
	If MV_PAR03 == 1
		lShowZero := .T.
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa arrays de controle de Inventario                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CBLoadEst(aProdEnd,.f.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis do browse                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConfigCols(aCampos1,2)
	aInfoBrow := Info_DB(aCampos1)
	MsAguarde({|| aProdBrw := GetBrwProd(aInfoBrow)},STR0166,STR0165) //"Aguarde!" ### "Selecionando Registros..."

	aOperadores 	:= RetOpers()
	If !Empty(aOperadores)
		aItensOpers := RetItemOper(aOperadores[1,1])
	EndIf
	aBrwItens		:= aClone(RetHdItensOp(aCfgItens))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste dados a serem visualizados                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aProdBrw[2])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria browse de Registros de Inventario (SB7)                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CBA->CBA_STATUS $ "54"   // 4=Finalizado / 5=Processado
			Aadd(aPages,"RegSB7")
			Aadd(aTitulo,STR0027) //"&Registros de Inventario"
			aHeadB7 := RetHdSB7(aCfgSB7)

			CBC->(DbSetOrder(3))
			CBC->(DbSeek(xFilial("CBC")+CBA->CBA_CODINV))
			While CBC->(!Eof()) .And. CBC->CBC_CODINV == CBA->CBA_CODINV
				aAdd(aProdutos, {CBC->CBC_COD, CBC->CBC_LOCAL})
				CBC->(DbSkip())
			End

			SB7->(DbOrderNickName("ACDSB701"))
			SB7->(DbSeek(xFilial("SB7")+CBA->CBA_CODINV))
			While SB7->(!Eof() .AND. B7_FILIAL+B7_DOC==xFilial("SB7")+CBA->CBA_CODINV)
				nPosProd := aScan(aProdutos,{|x| x[1] == SB7->B7_COD .And. x[2] == SB7->B7_LOCAL })
				If (!lShowZero .And. SB7->B7_QUANT == 0) .Or. nPosProd == 0
					SB7->(DbSkip())
					loop
				EndIf			
				Aadd(aRegB7,{SB7->B7_STATUS,SB7->B7_DOC,SB7->B7_COD,SB7->B7_LOCAL,SB7->B7_LOCALIZ,SB7->B7_LOTECTL, ;
				SB7->B7_NUMLOTE,SB7->B7_NUMSERI,Transform(SB7->B7_QUANT,X3Picture("B7_QUANT")),SB7->B7_DATA})
				If SB7->B7_STATUS == "2" //Processado
					aRegB7[Len(aRegB7),1] := aCores[1]
				Else
					aRegB7[Len(aRegB7),1] := aCores[4]
				EndIf
				SB7->(DbSkip())
			EndDo
			RestArea(aSB7)

			If Len(aRegB7) > 0 .AND. CBA->CBA_STATUS == "4" //Finalizado
				AADD(aButtons, {"AUTOM",{|| Acerto()},STR0028})	 //"Executa Acerto de Inventario"
			ElseIf Len(aRegB7)== 0
				Aadd(aRegB7,{" "," "," "," "," "," ",	" "," ",Transform(SB7->B7_QUANT,X3Picture("B7_QUANT")),CTOD("")})
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definicao de Teclas de Atalho                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetKey( VK_F12	, { || SelExclCont() } )
		SetKey( VK_F10	, { || BrwLegenda(cTitulo, STR0029, aLegenda) } ) //"Legenda do Inventario"

		SETAPILHA() //Tenho que ver o que eh isto... (se organiza a pilha da thread ou nao)
		oMainWnd:ReadClientCoors()

		If lModelo1
			cTitulo+=STR0030 //" - Modelo 1"
		Else
			cTitulo+=STR0031 //" - Modelo 2"
		EndIf

		DEFINE DIALOG oDlgMain TITLE cTitulo   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10  OF oMainWnd  PIXEL
		EnchoiceBar(oDlgMain,{||If(oGetBrw:TudoOK(),(oDlgMain:End()),)},{||oDlgMain:End()},,aButtons)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Objetos do Panel de Ferramenta Lateral                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBarLeft					:=	TPanel():New(000,000, ,oDlgMain, , , , , , 100, 15, .T.,.F. )
		oBarLeft:align				:= CONTROL_ALIGN_LEFT
		oBarLeft:lVisibleControl 	:= .F.

		//Pesquisar
		TSay():New( 002, 002, {||STR0032},oBarLeft, ,oFont1, , , ,.T., , , 40, 12) //"Pesquisar Produto:"
		@ 010,002 GET oPesquisa  VAR cPesquisa  SIZE 85, 9 OF oBarLeft PIXEL
		TButton():New(009,086, STR0033, oBarLeft, {||LocProd(cPesquisa)}, 14, 13, , , .F., .T., , , .T.) //"&Ok"

		//Listar
		TSay():New( 025, 002, {||STR0034},oBarLeft, ,oFont1 , , , ,.T., , , 40, 12) //"Listar:"
		@ 032, 002 COMBOBOX oEstView VAR cEstView ITEMS {STR0035,STR0036,STR0037,; //"1-Todas Contagens"###"2-Contagens Batidas"###"3-Contagens Divergentes"
		STR0038} SIZE 80, 50 OF oBarLeft ON CHANGE(Atu(.T.)) PIXEL //"4-Contagens Qtd. Zerados"

		TGroup():New( 048, 002, 130, 100, STR0039, oBarLeft, , , .T.,) //"Visualizar Campos:"
		//So  nao criei dinamicamente os objetos abaixo pois me gerou problemas
		TCheckBox():New( 55, 004, RetTituloCpo(aCampos1[3,1]), bSETGET(aCampos1[3,5]), oBarLeft, 60, 12, ,{||.T.}, ,,, ,, .T.,,,)
		TCheckBox():New( 65, 004, RetTituloCpo(aCampos1[4,1]), bSETGET(aCampos1[4,5]), oBarLeft, 60, 12, ,{||.T.}, ,,, ,, .T.,,,)
		TCheckBox():New( 75, 004, RetTituloCpo(aCampos1[5,1]), bSETGET(aCampos1[5,5]), oBarLeft, 60, 12, ,{||.T.}, ,,, ,, .T.,,,)
		TCheckBox():New( 85, 004, RetTituloCpo(aCampos1[6,1]), bSETGET(aCampos1[6,5]), oBarLeft, 60, 12, ,{||.T.}, ,,, ,, .T.,,,)
		TCheckBox():New( 95, 004, RetTituloCpo(aCampos1[7,1]), bSETGET(aCampos1[7,5]), oBarLeft, 60, 12, ,{||.T.}, ,,, ,, .T.,,,)
		TCheckBox():New(105, 004, RetTituloCpo(aCampos1[8,1]), bSETGET(aCampos1[8,5]), oBarLeft, 60, 12, ,{||.T.}, ,,, ,, .T.,,,)
		TCheckBox():New(115, 004, RetTituloCpo(aCampos1[9,1]), bSETGET(aCampos1[9,5]), oBarLeft, 60, 12, ,{||.T.}, ,,, ,, .T.,,,)
				

		TButton():New(055,065, STR0040, oBarLeft, {||AtuColsBrw(aCampos1)}, 27, 15, , , .F., .T., , , .T.) //"&Atualizar"

		oFolder			 := TFolder():New(0,0,aTitulo,aPages,oDlgMain,,,, .F., .F.,nLetBotao -10,80,)
		oFolder:align 	 := CONTROL_ALIGN_ALLCLIENT
		oFolder:Refresh()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Objetos do Folder 01  (PLANILHA DE MANUTENCAO)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrw			:= TwBrowse():New(000,000,(oDlgMain:nClientHeight -55),oDlgMain:nClientWidth -3,,aInfoBrow[1],aInfoBrow[3],oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oBrw:bChange 	:= {||AtuBrw(oBrw:nAT,@cChave) }
		oBrw:SetArray( aProdBrw[2] )
		oBrw:bLine		:= {|| &(AtuBLine(1))}
		NovoHeader(1,aCampos2)
		If Len(aProdBrw[2])>0
			cProd		:= aProdBrw[1][oBrw:nAT,2]
			cArm		:= aProdBrw[1][oBrw:nAT,6]
			cEnd		:= aProdBrw[1][oBrw:nAT,7]
			cLote		:= aProdBrw[1][oBrw:nAT,4]
			cSLote		:= aProdBrw[1][oBrw:nAT,5]
			cNumSeri	:= aProdBrw[1][oBrw:nAT,8]
			If lUniCPO  .And. lWmsNew  
				cIDunit	:= aProdBrw[1][oBrw:nAT,13]
				ColsCont(cProd+cArm+cEnd+cLote+cSLote+cNumSeri+cIdunit)
			else
				ColsCont(cProd+cArm+cEnd+cLote+cSLote+cNumSeri)
			EndIf
		EndIf
		oGetBrw 				:= MSGetDados():New(0,0,080,oDlgMain:nClientWidth -3,1,,,"",.F.,NIL,NIL,NIL,,,,,,oFolder:aDialogs[1])
		oGetBrw:oBrowse:align 	:= CONTROL_ALIGN_BOTTOM
		oBrw:align 				:= CONTROL_ALIGN_ALLCLIENT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Objetos do Folder 02  (PLANILHA DE Operadores)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 000,001 LISTBOX oListOper VAR cVarCab Fields HEADER STR0041, STR0042,STR0043 ; //"N.Conferencia"###"Usuario               "###"Status"
		SIZE 280,80 PIXEL of oFolder:aDialogs[2] ON CHANGE Atu(.F.,NIL,NIL,@lFistCarga)
		If Empty( aOperadores )
			aadd(aOperadores,{"","",""})
		EndIf
		oListOper:SetArray( aOperadores )
		oListOper:bLine 			:= { || {	aOperadores[oListOper:nAT,1], aOperadores[oListOper:nAT,2], ;
		aOperadores[oListOper:nAT,3]} }
		oListOper:align 			:= CONTROL_ALIGN_TOP
		oListOper:Refresh()

		oItensOpers			:= TwBrowse():New(100,001,800,300,,aBrwItens[1],aBrwItens[2],oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oItensOpers:SetArray( aItensOpers )
		oItensOpers:bLine	:= {|| &(AtuBLine(2))}
		oItensOpers:align	:= CONTROL_ALIGN_ALLCLIENT
		oItensOpers:Refresh()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Objetos do Folder 03  (INFORMACOES)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Grupo Mestre de Inventario ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oGrup1:=TGroup():New( 001, 001, 85, 250/*370*/, STR0044, oFolder:aDialogs[3], /*<nClrFore>*/, /*<nClrBack>*/, .T., .T. )	 //"Mestre de Inventario"
		oGrup1:oFont  := oFont2
		oGrup1:nWidth := 500 //775

		TSay():New( 008, 002, {||STR0045},oGrup1, ,oFont2, ,.T. , ,.T., , , 70, 12) //"Identificador:"
		TSay():New( 006, 075, {||CBA->CBA_CODINV},oFolder:aDialogs[3], , TFont():New("Arial",, -18, .T., .T.), , , ,.T.,CLR_HBLUE , , 90, 12)

		TSay():New( 017, 002, {||STR0046},oFolder:aDialogs[3], , oFont1, , .T. , ,.T., , , 70, 12) //"Data: "
		TSay():New( 017, 075, {||DTOC(CBA->CBA_DATA)},oFolder:aDialogs[3], , oFont2, , , ,.T., CLR_HBLUE, , 90, 12)

		TSay():New( 025, 002, {||STR0047},oFolder:aDialogs[3], , oFont1, ,.T. , ,.T., , ,70, 12) //"Numero de Contagens: "
		TSay():New( 025, 075, {||StrZero(CBA->CBA_CONTS,2)},oFolder:aDialogs[3], , oFont2, ,.T., ,.T.,CLR_HBLUE, , 10, 12)

		TSay():New( 033, 002, {||STR0048},oFolder:aDialogs[3], , oFont1, ,.T. , ,.T., , ,70, 12) //"Contagens Realizadas: "
		oSayContRz := TSay():New( 033, 075, {||StrZero(CBA->CBA_CONTR,2)},oFolder:aDialogs[3], , oFont2, ,.T., ,.T.,CLR_HBLUE, , 10, 12)

		TSay():New( 041, 002, {||STR0049},oFolder:aDialogs[3], , oFont1, ,.T. , ,.T., , , 70, 12) //"Almoxarifado: "
		TSay():New( 041, 075, {||CBA->CBA_LOCAL},oFolder:aDialogs[3], , oFont2, , , ,.T., CLR_HBLUE, , 90, 12)

		TSay():New( 049, 002, {||STR0050},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , , 70, 12) //"Tipo de Inventario: "
		TSay():New( 049, 075, {||If(CBA->CBA_TIPINV=="1",STR0051,STR0052)},oFolder:aDialogs[3], , oFont2, , , ,.T., CLR_HBLUE, , 90, 12) //"Por Produto"###"Por Endereco"

		If CBA->CBA_TIPINV == "1"
			cDescProd := Posicione("SB1",1,xFilial("SB1")+CBA->CBA_PROD,"B1_DESC")
			TSay():New( 057, 002, {||STR0053},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , , 70, 12) //"Produto: "
			TSay():New( 057, 075, {||CBA->CBA_PROD +" : "+Posicione("SB1",1,xFilial("SB1")+CBA->CBA_PROD,"B1_DESC")},oFolder:aDialogs[3], , oFont2, , , ,.T.,CLR_HBLUE , ,200, 12)
		Else
			TSay():New( 057, 002, {||STR0054},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , , 70, 12) //"Endereco: "
			TSay():New( 057, 075, {||CBA->CBA_LOCALI},oFolder:aDialogs[3], , oFont2, , , ,.T., CLR_HBLUE, , 90, 12)

			TSay():New( 057, 075, {||STR0167},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , , 150, 12) //"Total de Prod. Analisado(s):"
			TSay():New( 057, 230, {||If(aProdBrw[2]#NIL,StrZero(Len(aProdBrw[2]),4),"0")},oFolder:aDialogs[3], , oFont2, , , ,.T., CLR_HBLUE, , 90, 12)
		EndIf

		TSay():New( 065, 002, {||STR0055},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,70, 12) //"Status: "
		TSay():New( 065, 075, {||If(CBA->CBA_STATUS=="0",STR0056,If(CBA->CBA_STATUS=="1",STR0057, ; //"Nao Iniciado"###"Em Andamento"
		IIf(CBA->CBA_STATUS=="2",STR0058,IIf(CBA->CBA_STATUS=="3",STR0059, ; //"Em Pausa"###"Contado"
		IIf(CBA->CBA_STATUS=="4",STR0060,STR0061)))))},oFolder:aDialogs[3], , oFont2, , , ,.T., CLR_GREEN , , 80, 12) //"Finalizado"###"Processado"
		If ! lModelo1
			TSay():New(073, 002, {||STR0062},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,70, 12) //"Recontagem: "
			TSay():New(073, 075, {||If(CBA->CBA_AUTREC=="1",STR0063,STR0064)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(CBA->CBA_AUTREC=="1",CLR_GREEN, CLR_RED) , , 80, 12) //"Autorizada"###"Bloqueada"
		EndIf

		//Grupo Classificacao Curva ABC ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oGrup4			:= TGroup():New(001,260, 85, 250, STR0065, oFolder:aDialogs[3], , , .T., .F. )	 //"Classificacao Curva ABC:"
		oGrup4:oFont	:= oFont2
		oGrup4:nWidth 	:= 257

		TSay():New( 008, 265, {||STR0066},oFolder:aDialogs[3], , oFont1, ,.F., ,.T., , ,40, 12) //"Classe A:"
		TSay():New( 008, 300, {||If(CBA->CBA_CLASSA=="1",STR0067,STR0068)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(CBA->CBA_CLASSA=="1",CLR_GREEN, CLR_RED) , , 20, 12) //"Sim"###"Nao"

		TSay():New( 016, 265, {||STR0069},oFolder:aDialogs[3], ,oFont1 , ,.F. , ,.T., , ,40, 12) //"Classe B:"
		TSay():New( 016, 300, {||If(CBA->CBA_CLASSB=="1",STR0067,STR0068)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(CBA->CBA_CLASSB=="1",CLR_GREEN, CLR_RED) , , 20, 12) //"Sim"###"Nao"

		TSay():New( 024, 265, {||STR0070},oFolder:aDialogs[3], ,oFont1 , ,.F. , ,.T., , ,40, 12) //"Classe C:"
		TSay():New( 024, 300, {||If(CBA->CBA_CLASSC=="1",STR0067,STR0068)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(CBA->CBA_CLASSC=="1",CLR_GREEN, CLR_RED) , , 20, 12) //"Sim"###"Nao"



		//Grupo Configuracoes do Inventario ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oGrup2			:= TGroup():New( 90, 001, 30, 250, STR0071, oFolder:aDialogs[3], /*<nClrFore>*/, /*<nClrBack>*/, .T., .F. )	 //"Configuracoes do Inventario"
		oGrup2:oFont	:= oFont2
		oGrup2:nHeight	:= 150
		oGrup2:nWidth	:= 500

		TSay():New( 096, 002, {||STR0072},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Controle de Endereco: "
		TSay():New( 096, 115, {||If(GetMv("MV_LOCALIZ")=="S",STR0073,STR0074)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(GetMv("MV_LOCALIZ")=="S",CLR_GREEN, CLR_RED) , ,70, 12) //"Ativado"###"Desativado"
		TSay():New( 104, 002, {||STR0075},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Controle de Rastro: "
		TSay():New( 104, 115, {||If(GetMv("MV_RASTRO")=="S",STR0076,STR0077)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(GetMv("MV_RASTRO")=="N",CLR_RED,CLR_GREEN) , ,70, 12) //"Ativado"###"Desativado"
		TSay():New( 112, 002, {||STR0078},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Analise de Inventario:"
		TSay():New( 112, 115, {||If(GetMv("MV_ANAINV")=="1",STR0079,STR0080)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(GetMv("MV_ANAINV")=="1",CLR_GREEN, CLR_RED) , ,70, 12) //"Ativado para Coletor"###"Ativado para Monitor"
		TSay():New( 120, 002, {||STR0081},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Acerto Automatico de Inventario:"
		TSay():New( 120, 115, {|| {STR0074,STR0079,STR0080,STR0082}[val(GetMv("MV_INVAUT"))+1]},oFolder:aDialogs[3], , oFont2, , , ,.T.,CLR_GREEN , ,70, 12) //"Desativado"###"Ativado para Coletor"###"Ativado para Monitor"###"Ativado "
		If CBA->CBA_TIPINV =="1"
			If ! Empty(CBA->CBA_PROD)
				SB2->(DBSetOrder(1))
				SB2->(DbSeek(xFilial("SB2")+CBA->(CBA_PROD+CBA_LOCAL)))
				TSay():New( 128, 002, {||STR0083},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Bloqueio do Produto:"
				TSay():New( 128, 115, {||If(GetMv("MV_VLDTINV") == "1",STR0084+Dtoc(SB2->B2_DTINV) ,STR0085)},oFolder:aDialogs[3], , oFont2, , , ,.T.,CLR_GREEN, ,120, 12)		 //"Por Data: "###"Por Tempo de Execucao do Inventario"
				TSay():New( 136, 002, {||STR0086},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Status do Produto:"
			Else
				SB2->(DBSetOrder(2))
				SB2->(DbSeek(xFilial("SB2")+CBA->CBA_LOCAL))
				TSay():New( 128, 002, {||STR0087},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Bloqueio do Armazem:"
				TSay():New( 128, 115, {||If(GetMv("MV_VLDTINV") == "1",STR0084+Dtoc(SB2->B2_DTINV),STR0085)},oFolder:aDialogs[3], , oFont2, , , ,.T.,CLR_GREEN, ,120, 12)		 //"Por Data: "###"Por Tempo de Execucao do Inventario"
				TSay():New( 136, 002, {||STR0088},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Status do Armazem:"
			EndIf
			If CBProdLib(SB2->B2_LOCAL,SB2->B2_COD,.f.)
				TSay():New( 136, 115, {|| STR0090 },oFolder:aDialogs[3], , oFont2, , , ,.T.,CLR_GREEN, ,100, 12)				 //"Liberado"
			Else
				TSay():New( 136, 115, {|| STR0089},oFolder:aDialogs[3], , oFont2, , , ,.T.,CLR_RED, ,100, 12)		 //"Bloqueado"		
			EndIf
		Else
			TSay():New( 128, 002, {||STR0091},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Bloqueio do Endereco:"
			TSay():New( 128, 115, {||If(GetMv("MV_VLDTINV") == "1",STR0084+Dtoc(Posicione("SBE",1,xFilial("SBE")+CBA->(CBA_LOCAL+CBA_LOCALI),"BE_DTINV")),STR0085)},oFolder:aDialogs[3], , oFont2, , , ,.T.,CLR_GREEN, ,120, 12) //"Por Data: "###"Por Tempo de Execucao do Inventario"
			TSay():New( 136, 002, {||STR0092},oFolder:aDialogs[3], , oFont1, ,.T., ,.T., , ,110, 12) //"Status do Endereco:"
			TSay():New( 136, 115, {||If(CBEndLib(CBA->CBA_LOCAL,CBA->CBA_LOCALI),STR0090,STR0089)},oFolder:aDialogs[3], , oFont2, , , ,.T.,If(CBEndLib(CBA->CBA_LOCAL,CBA->CBA_LOCALI),CLR_GREEN,CLR_RED), ,70, 12)		 //"Liberado"###"Bloqueado"
		EndIf

		//Grupo Legenda das Teclas de AtalhoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oGrup3			:=TGroup():New( 90, 260, 30, 250, STR0093, oFolder:aDialogs[3], , , .T., .F. )	 //"Teclas de Atalho:"
		oGrup3:oFont	:= oFont2
		oGrup3:nHeight	:= 150
		oGrup3:nWidth	:= 257

		TSay():New( 096, 265, {||STR0094},oFolder:aDialogs[3], , , ,.F. , ,.T., , ,100, 12) //"F12	: Exclusao de Contagem"
		TSay():New( 103, 265, {||STR0095},oFolder:aDialogs[3], , , ,.F. , ,.T., , ,110, 12) //"F10	: Legenda do Inventario"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Objetos do Folder 04  (REGISTRO DE INVENTARIO)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CBA->CBA_STATUS$"45"  // 4=Finalizado / 5=Processado
			oRegB7			:= TwBrowse():New(100,001,800,300,,aHeadB7[1],aHeadB7[2],oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oRegB7:SetArray( aRegB7 )
			oRegB7:bLine	:= {|| &(AtuBLine(3))}
			oRegB7:align	:= CONTROL_ALIGN_ALLCLIENT
			oRegB7:Refresh()
		EndIf

		DEFINE TIMER oTimer INTERVAL nIntervalo ACTION Atu(.T.,NIL,NIL,@lFistCarga) OF oDlgMain
		oTimer:Activate()

		If MV_PAR01 == 2
			Atu(.F.,,.T.)
		EndIf

		ACTIVATE MSDIALOG oDlgMain ON INIT (AtuGetDados()) VALID (VldClose())
		SetKey(VK_F12,{|| .T.})
		SetKey(VK_F10,{|| .T.})
	Else
		IW_MSGBOX(	STR0026,STR0021) //"Nao existem dados a serem visualizados!"###"Aviso"	
	EndIf
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³VldClose()          ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Validacao da finalizacao da tela de monitoramento  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Logico                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldClose()
While lAtualiz
	MsgRun(STR0096,STR0097,{||(lAtualiz := .F.,ProcessMessage())}) //"Finalizando processos..."###"Aguarde..."
EndDo
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³AtivaTimer(lAtiva)  ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Ativa/Desativa o Timer                             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³lAtiva   : Ativa/Desativa                          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtivaTimer(lAtiva)
If ValType(oTimer)=="O"
	If lAtiva .And. MV_PAR01==1
		oTimer:Activate()
	Else
		oTimer:DeActivate()
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³ViewFerret()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Visualiza/Oculta a barra de ferramentas            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ViewFerret()
oBarLeft:lVisibleControl := !oBarLeft:lVisibleControl
AtuGetDados()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³AtuGetDados()       ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Redimensiona os objetos contidos nos folders apos  ³
³          ³a execucao da funcao ViewFerret()                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtuGetDados()
oFolder:bChange := {||.T.}
If Left(cVERSAO,3)=="AP7"
	oFolder:nOption := 3
	oFolder:nOption := 1
EndIf
oFolder:bChange := {||Atu(.t.) }
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³AtuBrw()            ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Funcao que atualiza o objeto MsGetDados do controle³
³          ³de contagens do inventario.                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ nLinha : Numero da linha do browse de Produtos    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtuBrw(nLinha,cChave)
Local nPos
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local lWmsNew   	:= SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cIDunit :=" "
Default cChave := ""
aCols := {}
If Len(aProdBrw[2])>0
	nPos 		:= Ascan(aVinculo,{|x| x[2]==oBrw:nAT })

	cProd		:= aProdBrw[1][aVinculo[nPos,1],2]
	cArm		:= aProdBrw[1][aVinculo[nPos,1],6]
	cEnd		:= aProdBrw[1][aVinculo[nPos,1],7]
	cLote		:= aProdBrw[1][aVinculo[nPos,1],4]
	cSLote		:= aProdBrw[1][aVinculo[nPos,1],5]
	cNumSeri	:= aProdBrw[1][aVinculo[nPos,1],8]
	If lUniCPO  .And. lWmsNew  
		cIDunit	:= aProdBrw[1][aVinculo[nPos,1],13]
		cChave		:= cProd+cArm+cEnd+cLote+cSLote+cNumSeri+cIDunit
	Else
		cChave		:= cProd+cArm+cEnd+cLote+cSLote+cNumSeri
	EndIf
	
	ColsCont(cChave)
EndIf 
n := 1
oGetBrw:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³AtuBLine()          ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Cria as colunas para atualizaco do oBrw:bLine      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ String com a estrutura do bLine                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtuBLine(nOpc)
Local cBLINE 		:= "{"
Local nI,nG  		:= 2
Default	nOpc 		:= 1

If nOpc == 1
	cBLINE +=  "aProdBrw[2][oBrw:nAT,01],aProdBrw[2][oBrw:nAT,02]"
	For nI:=3 To Len(aInfoBrow[2])
		If aInfoBrow[2][nI,5]
			nG++
			cBLINE += ",aProdBrw[2][oBrw:nAT,"+StrZero(nG,2)+"]"
		EndIf
	Next
ElseIf nOpc == 2
	cBLINE += "aItensOpers[oItensOpers:nAT,01]"
	For nI:=2 To Len(aBrwItens[3])
		If UPPER(Trim(aBrwItens[3,nI]))=="QUANTIDADE"
			cBLINE += ',Transform(aItensOpers[oItensOpers:nAT,'+StrZero(nI,2)+'],"@E 999,999,999.99")'
			Loop
		EndIf
		If AsCan(aBrwItens[1],{|x| Trim(x)==Trim(aBrwItens[3,nI])}) > 0
			cBLINE += ",aItensOpers[oItensOpers:nAT,"+StrZero(nI,2)+"]"
		EndIf
	Next
ElseIf nOpc == 3
	cBLINE += "aRegB7[oRegB7:nAT,01],aRegB7[oRegB7:nAT,02],aRegB7[oRegB7:nAT,03]"
	For nI:=4 To Len(aHeadB7[3])
		If aHeadB7[3,nI]=="B7_STATUS" .OR. aHeadB7[3,nI]=="B7_COD" .OR. aHeadB7[3,nI]=="B7_DOC" .OR. ;
			aHeadB7[3,nI]=="B7_DATA" .OR. UPPER(Trim(aHeadB7[3,nI]))=="QUANTIDADE"
			cBLINE += ",aRegB7[oRegB7:nAT,"+StrZero(nI,2)+"]"
			Loop
		EndIf

		If AsCan(aHeadB7[1],{|x| Trim(x)==Trim(aHeadB7[3,nI])}) > 0
			cBLINE += ",aRegB7[oRegB7:nAT,"+StrZero(nI,2)+"]"
		EndIf
	Next
EndIf
cBLINE += "}"
Return cBLINE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³Info_DB(aCampos)    ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao 	³Cria arrays auxiliares para trabalho com Browse   ³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros	³ aCampos : Array com os campos que sera a base    ³
³          	³           para os demais arrays	               ³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  	³ aRet[1] := Array de Titulos                      ³
³			³ aRet[2] := Array de Campos                       ³
³			³ aRet[3] := Array de Tamanhos                     ³
³ 			³ aRet[4] := Array de Alias                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function Info_DB(aCampos)
Local nX	:= 0
Local aRet 	:= Array(4)
aRet[1] := {}
aRet[2] := {}
aRet[3] := {}
aRet[4] := {}

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 To Len(aCampos)
	If SX3->(DbSeek(aCampos[nx][1]))
		If aCampos[nX][5]
			AADD(aRet[1],  If(Empty(aCampos[nx,2]),TRIM(X3Titulo()),aCampos[nx,2]) )
			AADD(aRet[3],  iif(X3_TAMANHO > len(TRIM(X3Titulo())),X3_TAMANHO*4.1,len(TRIM(X3Titulo()))*4.1))
		EndIf
		AADD(aRet[4] ,	X3_ARQUIVO)
	Else
		If aCampos[nX][5]
			AADD(aRet[1],  If(aCampos[nx][2]=NIL,aCampos[nx][1],aCampos[nx][2]) )
			AADD(aRet[3],  If(aCampos[nx][2]=NIL,Len(aCampos[nx][1]),Len(aCampos[nx][2])) )
		EndIf
		AADD(aRet[4],	"")
	EndIf
	AADD(aRet[2],{aCampos[nx][1],aCampos[nx][2],aCampos[nx][3],aCampos[nx][4],aCampos[nx][5],aCampos[nx][6]})
Next
Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³GetBrwProd()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Gera arrays de trabalho com as qtd. coletadas,     ³
³          ³montando sua estrutra a partir do tipo de inventa- ³
³          ³rio (Produto,Endereco).                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ aInfoDB  : Array Multi-dimensional tratamentos e  ³
³          ³            controle que servirao como base para   ³
³          ³            criacao dos arrays de manipulacao e    ³
³          ³            visualizacao do browse.                ³
³          ³ nOpc     : Indicador de filtro para visualizacao  ³
³          ³            do browse.                             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ aRet[1] : Array de Controle dos dados coletados   ³
³          ³ aRet[2] : Array de Visualizacao dos dados coletado³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function GetBrwProd(aInfoDB,nOpc)
Local nI,nJ,nG  := 0
Local nTamArray := 0
Local nTamCpo   := 0
Local aControle := {}
Local aViewBrw  := {}
Local aInfoCBB  := RetInfoCBB()
Local aEleito   := Array(2)
Local cAliasSBF := "SBF"
Local cAliasSB2 := "SB2"
Local cQuery    := ""
Local cWhere    := ""
Local cClasse   := Space(1)
Local aArea     := GetArea()
Local aAreaSB2  := SB2->(GetArea())
Local lContinua := .T.
Local lAC032FIL := ExistBlock("AC032FIL")
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lAjuMonit := CBM->(ColumnPos("CBM_AJUST")) > 0
Local lUniCPO   := CBC->(ColumnPos("CBC_IDUNIT")) > 0
Private nTamEle  := 0 
Default nOpc		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimentando variaveis de controle                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nContagem	:= Len(aInfoCBB)
nTamCpo		:= Len(aInfoDB[2])
nTamEle       := Ascan(aInfoDB[1],{|x| x == STR0015})
nTamArray	:= nTamCpo+nContagem 	//Total de Campos + Qtd.Contagens = Tamanho do Array a ser Criado

If CBA->CBA_STATUS $ "57" .AND. lTemHist // PROCESSADO e tem HISTORICO
	SB1->(DbSetOrder(1))
	CBM->(DbSetOrder(1))
	CBM->(DbSeek(xFilial("CBM")+CBA->CBA_CODINV))
	While CBM->(! Eof() .and. CBM_FILIAL+CBM_CODINV ==xFilial("CBM")+CBA->CBA_CODINV)
	 	IF MV_PAR04 == 1 .and. Iif(lAjuMonit,CBM->CBM_AJUST == '1',.F.)
	 		CBM->(DbSkip())
	 	Else
			SB1->(DbSeek(xFilial("SB1")+CBM->CBM_COD))
			CBM->(AADD(aControle,{NIL,CBM_COD,SB1->B1_DESC,CBM_LOTECT,CBM_NUMLOT,CBM_LOCAL,CBM_LOCALI,CBM_NUMSER,CBM_CLASSE,CBM_QTDORI,0,IIF(lAjuMonit,IIF(CBM_AJUST == '1',STR0067,STR0068),""),;
				IIF(lUniCPO .And.lWmsNew,CBM->CBM_IDUNIT,"" )}))
			If lUniCPO .And.lWmsNew
				aEleito 	:= CBM->(ElegeCount(CBM_COD+CBM_LOCAL+CBM_LOCALI+CBM_LOTECT+CBM_NUMLOT+CBM_NUMSER+CBM_IDUNIT))
			Else
				aEleito 	:= CBM->(ElegeCount(CBM_COD+CBM_LOCAL+CBM_LOCALI+CBM_LOTECT+CBM_NUMLOT+CBM_NUMSER))
			EndIf
			
			aControle[Len(aControle),nPosSaldo+1]	:= aEleito[1]  //Quantidade Eleita
			//Atualiza a legenda do Status
			If aEleito[2]
				aControle[Len(aControle),1] := aCores[1]
			Else
				aControle[Len(aControle),1] := aCores[2]
			EndIf
			CBM->(DbSkip())
		EndIf	
	End
	//Cria SubArray para o array principal de produtos aProdBrw[1]
	SetSubArray(aControle,nTamCpo,aInfoCBB)	
ELSE
	If !Empty(CBA->CBA_PROD)    // TEM PRODUTO
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(xFilial("SB2")+CBA->CBA_PROD+CBA->CBA_LOCAL))
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+CBA->CBA_PROD+CBA->CBA_LOCAL)
				CriaSB2(CBA->CBA_PROD,CBA->CBA_LOCAL)
			Else
				Aviso(I18N(STR0168,{CBA->CBA_PROD}),STR169,{"Ok"}) // "Produto #1 nao localizado no cadastro de produtos"
				lContinua := .F.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisando Classificacao por curva ABC, somente inv. por prod.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cClasse := " "
		If lContinua .And. CBA->CBA_TIPINV=="1" .and. !Empty(cClasses)
			If !CBClABC(SB2->B2_COD,cClasses,.T.,@cClasse)
				lContinua := .F.
			EndIf
		EndIf
		If lContinua 
			If Localiza(CBA->CBA_PROD,.T.) // Se o Produto possuir localizacao
				cQuery := " SELECT SBF.BF_FILIAL, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_PRODUTO, SBF.BF_NUMSERI, SBF.BF_LOTECTL, SBF.BF_NUMLOTE"
				If lUniCPO
					cQuery +=   ", ' ' IDUNIT"
				EndIf
				cQuery +=   " FROM "+RetSqlName("SBF")+" SBF"
				cQuery +=  " WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"'"
				cQuery +=    " AND SBF.BF_LOCAL = '"+CBA->CBA_LOCAL+"'"
				cQuery +=    " AND SBF.BF_PRODUTO = '"+CBA->CBA_PROD+"'"
				cQuery +=    " AND SBF.D_E_L_E_T_ = ' '"
				// União com a D14 para usar na query se tiver integração com o novo WMS
				If lWmsNew
					cQuery +=  " UNION"
					cQuery += " SELECT D14.D14_FILIAL, D14.D14_LOCAL, D14.D14_ENDER, D14.D14_PRODUT, D14.D14_NUMSER, D14.D14_LOTECT, D14.D14_NUMLOT"
					If lUniCPO
						cQuery += ", D14.D14_IDUNIT"
					EndIf
					cQuery +=   " FROM "+RetSqlName("D14")+" D14"
					cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
					cQuery +=    " AND D14.D14_LOCAL  = '"+CBA->CBA_LOCAL+"'"
					cQuery +=    " AND D14.D14_PRODUT = '"+CBA->CBA_PROD+"'"
					cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
				EndIf
				cQuery := ChangeQuery(cQuery)
				cAliasSBF := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSBF,.F.,.T.)
				Do While (cAliasSBF)->(!Eof())
					GetArray(aControle,nTamCPo,.T.,cAliasSBF)
					(cAliasSBF)->(dbSkip())
				EndDo
				(cAliasSBF)->(dbCloseArea())
			Else
				DbSelectArea("SB1")
				DbSetOrder(1)
				If MsSeek(xFilial("SB1")+SB2->B2_COD)
					GetArray(aControle,nTamCPo)
				EndIf
			EndIf
		EndIf
	Else // TODOS OS PRODUTOS
		If GetMv("MV_LOCALIZ") == "S"  // Controle por endereco
			If CBA->CBA_TIPINV =="2"//Somente do Endereco Informado
				cAliasSBF := GetNextAlias()
				cQuery := " SELECT SBF.BF_FILIAL, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_PRODUTO, SBF.BF_NUMSERI, SBF.BF_LOTECTL, SBF.BF_NUMLOTE"
				If lUniCPO
					cQuery +=   ", ' ' IDUNIT"
				EndIf
				cQuery +=   " FROM "+RetSqlName("SBF")+" SBF, "+RetSqlName("CBA")+" CBA "
				//Tratativa para utilizar o PE AC032FIL
				cQuery += " WHERE SBF.BF_FILIAL  = '" + xFilial('SBF')+ "'"
				cQuery +=   " AND SBF.BF_LOCAL   = CBA.CBA_LOCAL"
				cQuery +=   " AND SBF.BF_LOCALIZ = CBA.CBA_LOCALI"
				cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
				cQuery +=   " AND CBA.CBA_FILIAL = '" + xFilial('CBA')+ "'"
				cQuery +=   " AND CBA.D_E_L_E_T_ = ' '" 
				//filtro para selecionar apenas os saldos do endereço que está sendo inventariado, não foi retirado o vinculo com a CBA acima para não impactar no PE AC032FIL
				cQuery +=   " AND SBF.BF_LOCAL   = '" + CBA->CBA_LOCAL + "'"
				cQuery +=   " AND SBF.BF_LOCALIZ = '" + CBA->CBA_LOCALIZ + "'"
				cQuery +=   " AND CBA.CBA_CODINV = '"+ CBA->CBA_CODINV+"'" 

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ AC032FIL - Ponto de Entrada para filtro dos ³
				//³ itens do monitor do mestre de inventário    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAC032FIL
					cWhere := ExecBlock("AC032FIL",.F.,.F.,{cQuery})
					If ValType(cWhere) == "C" .And. Len(cWhere) > 1
						cQuery += ' AND '+ cWhere + ' '
					EndIf
				EndIf

				// União com a D14 para usar na query se tiver integração com o novo WMS
				If lWmsNew
					cQuery += " UNION "
					cQuery += " SELECT D14.D14_FILIAL, D14.D14_LOCAL, D14.D14_ENDER, D14.D14_PRODUT, D14.D14_NUMSER, D14.D14_LOTECT, D14.D14_NUMLOT"
					If lUniCPO
						cQuery += ", D14.D14_IDUNIT"
					EndIf
					cQuery +=   " FROM " + RetSqlName("D14") + " D14"
					cQuery +=  " WHERE D14.D14_FILIAL = '" + xFilial('D14') + "'"
					cQuery +=    " AND D14.D14_LOCAL  = '" + CBA->CBA_LOCAL + "'"
					cQuery +=    " AND D14.D14_ENDER  = '" + CBA->CBA_LOCALIZ + "'"
					cQuery +=    " AND D14.D_E_L_E_T_ = ' '" 
				EndIf
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSBF,.F.,.T.)
				While (cAliasSBF)->(!Eof())
					GetArray(aControle,nTamCPo,.T.,cAliasSBF)
					(cAliasSBF)->(DbSkip())
				EndDo
				(cAliasSBF)->(DbCloseArea())
			Else //De Todos Enderecos
				cAliasSBF := GetNextAlias()
				cQuery := " SELECT SBF.BF_FILIAL, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_PRODUTO, SBF.BF_NUMSERI, SBF.BF_LOTECTL, SBF.BF_NUMLOTE"
				If lUniCPO
					cQuery +=   ", ' ' IDUNIT"
				EndIf
				cQuery +=   " FROM "+RetSqlName("SBF")+" SBF, "+RetSqlName("CBA")+" CBA "
				//Tratativa para utilizar o PE AC032FIL
				cQuery += " WHERE SBF.BF_FILIAL = '" + xFilial('SBF')+ "'"
				cQuery += " AND SBF.BF_LOCAL = CBA.CBA_LOCAL"
				cQuery += " AND SBF.D_E_L_E_T_ = ' '"
				cQuery += " AND CBA.CBA_FILIAL = '" + xFilial('CBA')+ "'"
				//filtro para selecionar apenas os saldos do endereço que está sendo inventariado, não foi retirado o vinculo com a CBA acima para não impactar no PE AC032FIL
				cQuery +=   " AND CBA.CBA_LOCAL  = '" + CBA->CBA_LOCAL + "'"
				cQuery +=   " AND CBA.CBA_CODINV = '"+ CBA->CBA_CODINV+"'" 
				cQuery +=   " AND CBA.D_E_L_E_T_ = ' '" 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ AC032FIL - Ponto de Entrada para filtro dos ³
				//³ itens do monitor do mestre de inventário    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAC032FIL
					cWhere := ExecBlock("AC032FIL",.F.,.F.,{cQuery})
					If ValType(cWhere) == "C" .And. Len(cWhere) > 1
						cQuery += ' AND '+ cWhere + ' '
					EndIf
				EndIf

				// União com a D14 para usar na query se tiver integração com o novo WMS
				If lWmsNew
					cQuery += " UNION "
					cQuery += " SELECT D14.D14_FILIAL, D14.D14_LOCAL, D14.D14_ENDER, D14.D14_PRODUT, D14.D14_NUMSER, D14.D14_LOTECT, D14.D14_NUMLOT"
					If lUniCPO
						cQuery += ", D14.D14_IDUNIT"
					EndIf
					cQuery +=   " FROM " + RetSqlName("D14") + " D14"
					cQuery +=  " WHERE D14.D14_FILIAL = '" + xFilial('D14') + "'"
					cQuery +=    " AND D14.D14_LOCAL  = '" + CBA->CBA_LOCAL + "'"
					cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
				EndIf
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSBF,.F.,.T.)
				While (cAliasSBF)->(!Eof())
					GetArray(aControle,nTamCPo,.T.,cAliasSBF)
					(cAliasSBF)->(DbSkip())
				EndDo
				(cAliasSBF)->(DbCloseArea())
			EndIf
		Else
		
			cAliasSB2 := GetNextAlias()
			cQuery    := "SELECT * FROM "+RetSqlName("SB2")+" SB2, "+RetSqlName("CBC")+" CBC  "
			cQuery    += "WHERE SB2.B2_FILIAL ='"+xFilial("SB2")   +"' AND "
			cQuery    += "CBC.CBC_CODINV='"+CBA->CBA_CODINV+"'         AND "
			cQuery    += "CBC.CBC_FILIAL = SB2.B2_FILIAL AND "
			cQuery    += "CBC.CBC_COD = SB2.B2_COD AND "
			cQuery    += "CBC.CBC_LOCAL = SB2.B2_LOCAL AND "
			If !lShowZero
				cQuery    += "CBC.CBC_QUANT > 0 AND " // Filtrar Zeradas
			EndIf
			cQuery    += "CBC.D_E_L_E_T_ =' '                          AND "
			cQuery    += "SB2.D_E_L_E_T_ =' ' "
			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB2,.T.,.T.)
		    (cAliasSB2)->(DbGoTop())
			While (cAliasSB2)->(!EOF())
				GetArray(aControle,nTamCpo,.F.,cAliasSB2)
				(cAliasSB2)->(DbSkip())
			End

		EndIf
	EndIf
	//Verifica se tem um CBC lido que nao faz parte do end"ereco ou do sb2  PRODUTO+ARMAZEM
	SetCBCArray(aControle,nTamArray,nTamCpo,aInfoCBB)
	//Cria SubArray para o array principal de produtos aProdBrw[1]
	SetSubArray(aControle,nTamCpo,aInfoCBB)
EndIf
If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao de array de visualizacao do browse               ³
	//³--------------------------------------------------------------³
	//³Onde: oEstView:nAT = nOpc                                     ³
	//³                      1- Visualiza Todas Contagens            ³
	//³                      2- Visualiza Contagens Batidas          ³
	//³                      3- Visualiza Contagens Divergentes      ³
	//³                      4- Visualiza Contagens Qtd. Zerados     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aVinculo:={}
	For nJ:=1 To Len(aControle)
		nG := 0
		If lModelo1
			If nOpc == 2
				If ValType(aControle[nJ,nTamEle])=="C"  // O tipo sera Caracter se o conteudo estiver em branco, ou seja contagem nao batida
					Loop
				EndIf
			ElseIf nOpc == 3
				If ValType(aControle[nJ,nTamEle])=="N"  // O tipo sera Numerico se o conteudo da variavel estiver preenchido, ou seja contagem batida
					Loop
				EndIf
			ElseIf nOpc == 4
				If ValType(aControle[nJ,nTamEle])=="C" .OR. aControle[nJ,nTamEle]>0
					Loop
				EndIf
			EndIf
		Else
			If nOpc == 2
				If Str(aControle[nJ,nPosSaldo],14,4) # Str(aControle[nJ,nPosSaldo+1],14,4)
					Loop
				EndIf
			ElseIf nOpc == 3
				If Str(aControle[nJ,nPosSaldo],14,4) == Str(aControle[nJ,nPosSaldo+1],14,4)
					Loop
				EndIf
			ElseIf nOpc == 4
				If aControle[nJ,nPosSaldo+1]>0
					Loop
				EndIf
			EndIf
		EndIf
		AADD(aViewBrw,Array(Len(aInfoDB[1])))
		AADD(aVinculo,{nJ,len(aViewBrw)})
		For nI:=1 To Len(aInfoDB[2])
			//Verifico se a coluna nao esta visivel
			If !aInfoDB[2][nI,5]
				Loop
			EndIf
			nG++
			aViewBrw[Len(aViewBrw)][nG] := aControle[nJ,nI]
		Next
	Next
EndIf
RestArea(aAreaSB2)
RestArea(aArea)
Return {aClone(aControle),aClone(aViewBrw)}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³Atu(lTimer,aCampos) ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Atualiza os objetos de tela a partir das funcoes   ³
³          ³auxiliares. Esta rotina eh chamada por objetos de  ³
³          ³tela e por um objeto timer.                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ lTimer  : Logico que permite considerar ou nao o  ³
³          ³           objeto timer para ativa-lo/desativa-lo. ³
³          ³ aCampos : Array de campos para controle dos arrays³
³          ³ lForExec: Array de campos para controle dos arrays³
³          ³ lFCarga : Indica se eh primeira carga(se for nao  ³
³          ³           nao faz nada para nao ocorrer sobrecarga³
³          ³           )lembrando q. utilizada como referencia.³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function Atu(lTimer,aCampos,lForExec,lFCarga)
Local nI
Local lContinua		:= .T.
DEFAULT aCampos 	:= aInfoBrow[2]
DEFAULT lForExec	:= .F.
DEFAULT lFCarga		:= .F.

//Verifica se o timer esta desativado
If !lForExec .And. MV_PAR01#1
	Return
EndIf

//Se for primeira carga ignora, pois ja foi carregado anteriormente
If lFCarga
	lFCarga 	:= .F.
	lContinua   := .F.
EndIf
If lContinua
	lAtualiz := .T.
	If lTimer
		AtivaTimer(.F.)
	EndIf

	If oFolder:nOption == 1  //Planilha de Manutencao
		aInfoBrow		:= Info_DB(aCampos)
		aProdBrw		:= GetBrwProd(aInfoBrow,oEstView:nAT)
		oBrw:SetArray( aProdBrw[2] )
		oBrw:bLine		:= {||&(AtuBLine())}
		oBrw:Refresh()
		If !lAtualiz	// Esta variavel estara falsa neste comento so se o usuario finalizar a aplicacao
			lContinua := .F.
		Else
			If Len(aProdBrw[2]) > 0
				AtuBrw(oBrw:nAT)
			Else
				AtuBrw(0)
			EndIf
		EndIf
	ElseIf oFolder:nOption == 2 //Planilha de Operadores
		aOperadores		:= RetOpers()
		oListOper:SetArray( aOperadores )
		oListOper:bLine	:= { || {	aOperadores[oListOper:nAT,1], aOperadores[oListOper:nAT,2], ;
		aOperadores[oListOper:nAT,3]} }
		oListOper:Refresh()
		aItensOpers			:= RetItemOper(aOperadores[oListOper:nAT,1])
		oItensOpers:SetArray( aItensOpers )
		oItensOpers:bLine	:= {|| &(AtuBLine(2))}
		oItensOpers:Refresh()
	EndIf
	
	If	lContinua
		CBA->(dbSetOrder(1))
		CBA->(dbSeek(xFilial("CBA")+CBA_CODINV)) //-- Comando para forcar atualiz. info na tela
		oSayContRz:cCaption := StrZero(CBA->CBA_CONTR,2)
		oSayContRz:Refresh()
		If	lTimer
			AtivaTimer(.T.)
		EndIf
		lAtualiz := .F.
	EndIf
EndIf
Return    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³NovoHeader()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Cria um aHeader para ser utilizado por um MsGetDado³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ nF        : ID do aHeader caso tenha mais de um;  ³
³          ³ aCampos   : Campos que construirao o aHeader      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function NovoHeader(nF,aCampos)
Local	cUsado	:= REPLICATE(Chr(128),14)+CHR(160)
Local	nX
Default	nF		:= 1
Default	aCampos	:= {}

RegToMemory("CBC", .F.)
aHeader := {}
dbSelectArea("SX3")
Aadd(aHeader,{ ""	,"LEGENDA","@BMP",0,0,"",cUsado,"C","CBC","V"})
SX3->(DbSetOrder(2))
For nX := 1 To Len(aCampos)
	If SX3->(DbSeek(aCampos[nx,1]))
		AADD(aHeader,  { IIf(Empty(aCampos[nx,2]), TRIM(X3Titulo()),aCampos[nx,2]), SX3->x3_campo, ;
		IIf(Empty(SX3->x3_picture).and. SX3->X3_TIPO=="N","@E 9999,999.99",SX3->x3_picture), SX3->x3_tamanho, ;
		SX3->x3_decimal,IIf(Empty(aCampos[nX,3]),SX3->x3_valid,aCampos[nX,3]), ;
		IIf(aCampos[nx,3]==".F.",cUsado,SX3->x3_usado), SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_context } )
	ElseIf aCampos[nx,1]=="XX_TPINCL"
		Aadd(aHeader,{STR0018,"XX_TPINCL","@!",23,0,"",cUsado,"C","CBC","V"}) //"Tipo de Inclusao"
	EndIf
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³ColsCont(cChave)    ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Cria um aCols para ser utilizado por um MsGetDados ³
³          ³do controle de contagens.                          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cChave : Chave de pesquisa para possicionamento   ³
³          ³             no CBB e CBC para carregar o aCOLS    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ColsCont(cChave)
Local cCampo		:= ""
Local nI			:=	0
Local nCount		:= 0
Local nPos			:= 0
Local aCBB		  	:= {}
Local aRetSaldo		:= {}
AtivaTimer(.F.)
aCols := {}
CBB->(dbSetOrder(3))
CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))
CBC->(DbSetOrder(2)) 
While CBB->(!EOF() .AND. CBB_FILIAL+CBB_CODINV==xFilial("CBB")+CBA->CBA_CODINV)
	If !CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM+cChave)) // Se Não encontrar o item na tabela CBC, passa para a próxima contagem.
  		CBB->(DbSkip())
  		CBC->(DbGoTop())
  		Loop
	EndIf	
	nCount++
	aRetSaldo := RetQtd(CBB->CBB_NUM,cChave,nCount)
	AADD(aCols,Array(Len(aHeader)))
	For nI:=1 to Len(aHeader)
		cCampo	:=	Alltrim(aHeader[nI,2])
		If aHeader[nI,10] # "V"
			If cCampo=="CBC_QUANT"     			//Quantidade
				aCols[Len(aCols)][nI] := aRetSaldo[1]
			ElseIf cCampo=="CBC_QTDORI"     			//Quantidade
				aCols[Len(aCols)][nI] := aRetSaldo[2]
			ElseIf cCampo=="CBB_NUM" .AND.  nI==2 //
				aCols[Len(aCols)][nI] := StrZero(nCount,3)
			ElseIf cCampo=="CB1_NOME"
				aCols[Len(aCols)][nI] := Posicione("CB1",1,xFilial("CB1")+CBB->CBB_USU,"CB1_NOME")
			Else
				aCols[Len(aCols)][nI] := &(aHeader[nI,9]+"->"+cCampo) //
			EndIf
		Else
			If aHeader[nI,3] =="@BMP"
				aCols[Len(aCols)][nI] := If(CBB->CBB_STATUS=="1",aCores[3],aCores[4])
			ElseIf cCampo=="XX_TPINCL"
				CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM+cChave))
				aCols[Len(aCols)][nI] := If(Empty(CBC->CBC_QTDORI),STR0099,STR0100)				 //"Criado Automatico"###"Leitura pelo Operador"
			Else
				aCols[Len(aCols)][nI] := CriaVar(cCampo)
			EndIf
		Endif
	Next
	CBB->(DbSkip())
EndDo
AtivaTimer(.T.)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³LocProd(cProduto)   ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Pesquisa Produto                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cProduto : Codigo do produto a ser pesquisado     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function LocProd(cProduto)
Local nPos
nPos := Ascan(aProdBrw[2],{|x| Trim(x[2])==Trim(cProduto)})
If nPos = 0
	MsgAlert(STR0101,STR0102) //"Produto nao localizado!"###"ATENCAO"
Else
	oBrw:nAt := nPos
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Programa ³CB032VCB()       ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÄÄÄÁÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Valida e Grava a quantidade inventariada, alterada ³
³          ³no monitor.Funcao usada no valid do campo CBC_QUANT³
³          ³do MsGetDados de controle de contagens.            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Logico                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function CB032VCB()
Local cProduto		:= aProdBrw[2][oBrw:nAT,2]         		//Codigo do Produto
Local lContFim		:= aCols[oGetBrw:oBrowse:nROWPOS,7]=="2"	//Contagem do operador finalizada
Local nQtd			:= aCols[oGetBrw:oBrowse:nROWPOS,5]   		//Quantidade anterior
Local cNum			:= aCols[oGetBrw:oBrowse:nROWPOS,3]			//Numero de Controle
Local nCont 		:= Val(aCols[oGetBrw:oBrowse:nROWPOS,2])+Len(aInfoBrow[2])	// Numero da Contagem
Local nPos			:= 0
Local cArm,cEnd,cLote,cSLote,cNumSer
Local lRet			:= .T.
Local lContinua		:= .T.

If ! lModelo1
	If Len(aCols) <> oGetBrw:oBrowse:nAT
		lRet := .f.
	EndIf
EndIf

If lRet .And. Empty(aCols)
	lRet := .F.
EndIf

CBA->(DbGoTop())
// esta linha foi colocada para funcionar como refresh do registro, pois o mesmo ate
// este momento nao esta atualizando.......
CBA->(DbGoto(nRecnoCBA))
If lRet
	AtivaTimer(.F.)
EndIf
If lRet .And. CBA->CBA_STATUS == "5"
	Aviso(STR0103,STR0104,{STR0025}) //"Atencao"###"Mestre de Inventario ja processado!!!"###"Ok"
	lRet := .F.
EndIf

If lRet .And. CBA->CBA_STATUS == "4"
	Aviso(	STR0103,STR0105+ ; //"Atencao"###"Mestre de Inventario ja finalizado, favor excluir este mestre de inventario "
	STR0106,{STR0025}) //"para que o status do mestre seja alterado para inventario em andamento!!!"###"Ok"
	lRet := .F.
EndIf

If lRet .And. !lContFim
	Aviso(STR0103,STR0107,{STR0025}) //"Atencao"###"Nao eh possivel alterar a quantidade, pois a contagem nao foi finalizada!"###"Ok"
	lRet := .F.
EndIf

If lRet .And. lUsaCB001
	Aviso(STR0103,STR0108,{STR0025}) //"Atencao"###"So eh permitido fazer alteracao de valores com controle de etiqueta na opcao Difs. Vide barra de ferramentas"###"Ok"
	lRet := .F.
EndIf

If lRet .And. M->CBC_QUANT == nQtd
	lContinua := .F.
EndIf

If lRet .And. lContinua
	cArm	:= aProdBrw[1][oBrw:nAT,6]
	cEnd	:= aProdBrw[1][oBrw:nAT,7]
	cLote	:= aProdBrw[1][oBrw:nAT,4]
	cSLote	:= aProdBrw[1][oBrw:nAT,5]
	cNumSer	:= aProdBrw[1][oBrw:nAT,8]

	nPos	:= AsCan(aProdBrw[1],{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[8]==cProduto+cArm+cEnd+cLote+cSLote+cNumSer})
	If nPos > 0
		aProdBrw[1,nPos,nCont,2]:= M->CBC_QUANT
	EndIf

	Begin Transaction
		CBC->(DbSetOrder(2))
		CBC->(DbSeek(xFilial("CBC")+cNum+cProduto+cArm+cEnd+cLote+cSLote+cNumSer))
		If CBC->(Eof())
			Reclock("CBC",.T.)
			CBC->CBC_FILIAL	:= xFilial("CBC")
			CBC->CBC_CODINV	:= CBA->CBA_CODINV
			CBC->CBC_NUM	:= cNum
			CBC->CBC_COD	:= cProduto
			CBC->CBC_LOCAL	:= cArm
			CBC->CBC_LOTECT	:= cLote
			CBC->CBC_NUMLOT	:= cSLote
			CBC->CBC_LOCALI	:= cEnd
			CBC->CBC_NUMSER	:= cNumSer
		Else
			RecLock("CBC",.F.)
		EndIf

		CBC->CBC_QUANT	:= M->CBC_QUANT
		If !lModelo1
			If CBC->(Str(CBC_QUANT,14,4)<>Str(CBC_QTDORI,14,4)) .OR. ;
				Str(CBC->CBC_QUANT,14,4)==Str(aProdBrw[1][oBrw:nAT,nPosSaldo],14,4)
				CBC->CBC_CONTOK	:= "1"
			Else
				CBC->CBC_CONTOK	:= " "
			EndIf
		EndIf

		CBC->(MsUnLock())
	End Transaction

	//Atualiza a visualizacao do browse
	Atu(.F.)

	AtivaTimer(.T.)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³RetInfoCBB()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Carrega informacoes da tabela CBB em um array      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Array com os numeros de contagem,usuario e status ³
³          ³ da tabela CBB.                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetInfoCBB()
Local aRet       := {}
	CBB->(dbSetOrder(3))  
	CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))
	While CBB->(!EOF() .AND. CBB_FILIAL+CBB_CODINV==xFilial("CBB")+CBA->CBA_CODINV)
		Aadd(aRet,{CBB->CBB_NUM,CBB->CBB_USU,CBB->CBB_STATUS})
		CBB->(DbSkip())
	EndDo
Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³RetOpers()          ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Carrega informacoes dos Operados das contagens em  ³
³          ³um array.                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Array com o numeros de contagem,nome do usuario e ³
³          ³ status da contagem.(Esta funcao so difere da func.³
³          ³ RetInfoCBB, por trazer o nome do operador e nao o ³
³          ³ seu codigo)                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetOpers()
Local nI
Local cStatus 	:= ""
Local aCBB 		:= RetInfoCBB()
Local aRet 		:= {}
For nI:=1 To Len(aCBB)
	If aCBB[nI,3] == "1"
		cStatus := STR0109 //"Em andamento"
	ElseIf aCBB[nI,3] == "2"
		cStatus := STR0110 //"Finalizado"
	Else
		cStatus := STR0111 //"Nao iniciado"
	EndIf
	AADD(aRet,{aCBB[nI,1],Posicione("CB1",1,xFilial("CB1")+aCBB[nI,2],"CB1_NOME"),cStatus})
Next
If Empty(aRet)
	AADD(aRet,{Space(6),Space(3),Space(15)})
EndiF
Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³RetItemOper()       ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Garrega informacoes dos Itens lidos do operador    ³
³          ³possicionado na planilha.                          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cContagem : Numero da Contagem (CBB_NUM)           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Array                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetItemOper(cContagem)
Local cAliasCBC := "CBC"
Local cQuery    := ""
Local nPos	    := 0
Local aRet	    := {}
Local lWmsNew   	:= SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0
	
	cAliasCBC := GetNextAlias()
	cQuery    := "SELECT CBC_FILIAL,CBC_NUM,CBC_COD,CBC_LOCAL,CBC_LOCALI,CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,CBC_CODETI,CBC_QUANT,B1_DESC "
	If lUniCPO .And. lWmsNew
		cQuery    += ",CBC_IDUNIT " 
	EndIf
	cQuery    += "FROM "+RetSqlName("CBC")+" CBC, "
	cQuery    += +RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE CBC.CBC_FILIAL ='"+xFilial("CBC")+"' AND "
	cQuery    += "SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
	cQuery    += "CBC.CBC_NUM = '" + cContagem + "' AND "
	cquery    += "CBC.CBC_CODINV = '" + CBA->CBA_CODINV + "' AND "
	cQuery    += "CBC.CBC_COD = SB1.B1_COD AND "
				If !lShowZero
					cQuery    += "CBC.CBC_QUANT > 0 AND " // Filtrar Zeradas
				EndIf
	cQuery    += "CBC.D_E_L_E_T_ =' ' AND "
	cQuery    += "SB1.D_E_L_E_T_ =' ' "
	cQuery    += "ORDER BY CBC_NUM,CBC_COD,CBC_LOCAL,CBC_LOCALI,CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER "
	cQuery    := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCBC,.T.,.T.)
	
	
	If lUniCPO .And. lWmsNew
		While (cAliasCBC)->(!Eof() .and. CBC_FILIAL+CBC_NUM == xFilial("CBC")+cContagem)
			nPos := Ascan(aRet,{|x| x[1]+x[3]+x[4]+x[5]+x[6]+x[7]+x[9]+x[10] == (cAliasCBC)->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOTE+CBC_NUMSER+CBC_CODETI+CBC_IDUNIT)})
			If nPos == 0
				AADD(aRet,{(cAliasCBC)->CBC_COD,(cAliasCBC)->B1_DESC,(cAliasCBC)->CBC_LOCAL,(cAliasCBC)->CBC_LOCALI,(cAliasCBC)->CBC_LOTECT,(cAliasCBC)->CBC_NUMLOTE,(cAliasCBC)->CBC_NUMSER,(cAliasCBC)->CBC_QUANT,(cAliasCBC)->CBC_CODETI,(cAliasCBC)->CBC_IDUNIT})
			Else
				aRet[nPos][8] += (cAliasCBC)->CBC_QUANT
			EndIf
			(cAliasCBC)->(DbSkip())
		End
	Else
		While (cAliasCBC)->(!Eof() .and. CBC_FILIAL+CBC_NUM == xFilial("CBC")+cContagem)
			nPos := Ascan(aRet,{|x| x[1]+x[3]+x[4]+x[5]+x[6]+x[7]+x[9] == (cAliasCBC)->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOTE+CBC_NUMSER+CBC_CODETI)})
			If nPos == 0
				AADD(aRet,{(cAliasCBC)->CBC_COD,(cAliasCBC)->B1_DESC,(cAliasCBC)->CBC_LOCAL,(cAliasCBC)->CBC_LOCALI,(cAliasCBC)->CBC_LOTECT,(cAliasCBC)->CBC_NUMLOTE,(cAliasCBC)->CBC_NUMSER,(cAliasCBC)->CBC_QUANT,(cAliasCBC)->CBC_CODETI})
			Else
				aRet[nPos][8] += (cAliasCBC)->CBC_QUANT
			EndIf
			(cAliasCBC)->(DbSkip())
		End
	EndIf
	
	If Empty(aRet)
		If lUniCPO .And. lWmsNew
			aadd(aRet,{"","","","","","","",0,"",""})
		Else
			aadd(aRet,{"","","","","","","",0,""})
		EndIf
	EndIf
Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³RetQtd()            ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Retorna a quantidade inventariada                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cControle:Numero de controle do Inventario(CBB_NUM)³
³          ³cChave   :Chave de pesquisa                        ³
³          ³nCont    :Numero da contagem informado no msgetdado³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Numerico contendo a quantidade inventariada        ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetQtd(cControle,cChave,nCont,lRetBranco)
Local	nQtd	:= 0
Local	nQtdOri	:= 0
Local	nPos	:= 0
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0 
Default	nCont	:= 1

If lWmsNew .And. lUniCPO
	If CBC->(DbSeek(xFilial("CBC")+cControle))
		nCont	+= Len(aInfoBrow[2])
		nPos	:= AsCan(aProdBrw[1],{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[6]==cChave})
		CBC->(dbSetOrder(2))
		CBC->(dbSeek(xFilial("CBC")+cControle+cChave))
		While CBC->(!EOF() .and. CBC_FILIAL+CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+CBC_IDUNIT==xFilial("CBC")+cControle+cChave )
			nQtd   +=CBC->CBC_QUANT
			nQtdOri+=CBC->CBC_QTDORI
			CBC->(DbSkip())
		EndDo
	EndIf
Else 
	If CBC->(DbSeek(xFilial("CBC")+cControle))
		nCont	+= Len(aInfoBrow[2])
		nPos	:= AsCan(aProdBrw[1],{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[6]==cChave})
	
		CBC->(dbSetOrder(2))
		CBC->(dbSeek(xFilial("CBC")+cControle+cChave))
		While CBC->(!EOF() .and. CBC_FILIAL+CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER==xFilial("CBC")+cControle+cChave )
			nQtd   +=CBC->CBC_QUANT
			nQtdOri+=CBC->CBC_QTDORI
			CBC->(DbSkip())
		EndDo
	EndIf
EndIf
	
Return {nQtd,nQtdOri}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³RetTituloCpo()      ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Retorna o titulo do dicionario do campo informado. ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cCampos: Nome do campo do dicionario de dados.     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetTituloCpo(cCampo)
Local cTitulo := ""
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If SX3->(DbSeek(cCampo))
	cTitulo := TRIM(X3Titulo())
EndIf
Return cTitulo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³ElegeCount(cChave)  ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Funcao que elege a contagem batida                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cChave:  Chave do produto a ser analisado          ³
³          ³         cProd+cArm+cEnd+cLote+cSLote              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Se qtd. estiver batida o retorno ser NUMERICO      ³
³          ³caso contrario, o retorno ser CARACTER(branco)     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ElegeCount(cChave)
Local aArea      	:= GetArea()
Local aAreaCBC	:= CBC->(GetArea())
Local nRecnoCBC	:= CBC->(Recno())
Local aRetCBB	:= RetInfoCBB()
Local aQtdCount	:= {}
Local aContOk 	:= {}
Local aRet		:= {" ",.F.}
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0 
Local nPos 		:= 0
Local nQtd		:= 0
Local nQtdOri	:= 0
Local nTamInc	:= Len(aInfoBrow[2]) 			// Tamanho Inicial = Total de campos fixos
Local nContagen
Local nI
Local aRetorno	:= {} 
Local lContinua := .T.

if lWmsNew .And. lUniCPO
	nPos:= Ascan(aProdBrw[1],{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[8]+x[13]==cChave})
Else
	nPos:= Ascan(aProdBrw[1],{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[8]==cChave})
EndIf

If !Empty(nPos)

	nContagen:= Len(aProdBrw[1,nPos])-nTamInc

	If len(aRetCBB) == len(aProdBrw[1,nPos])-nTamInc

		//-----------------------  Validacao de controle para CB0 ----------------------------
		If lModelo1 .AND. lUsaCB001
			aRetorno := ElegEti(cChave,aRetCBB)
			If !aRetorno[2]
				lContinua := .F.
			EndIf
			If lContinua
				aRet := aClone(aRetorno) //Ate indentificar o valor cumulativo
				lContinua := .F.
			EndIf
		EndIf
		//------------------------------------------------------------------------------------

		If lContinua
			For nI:=1 To nContagen
				If nI > len(aRetCBB)
					Loop
				EndIf
				If ! CBC->(DbSeek(xFilial("CBC")+aRetCBB[nI,1]))
					Aadd(aQtdCount,0)
					Loop
				EndIf
				If aRetCBB[nI,1]==aProdBrw[1][nPos,nTamInc+nI,3] .and. aRetCBB[nI,3]=="0" //Se o valor anterior e igual ao alterado ou se a contagem nao foi iniciada, nao faz nada
					Loop
				EndIf
				aRetorno	:= RetQtd(aProdBrw[1][nPos,nTamInc+nI,3],cChave)
				nQtd		:= aRetorno[1]
				nQtdOri		:= aRetorno[2]
				Aadd(aQtdCount,nQtd)
			Next
		EndIf
		If lContinua .And. Empty(aQtdCount)
			lContinua := .F.
		EndIf
		If lContinua
			If lModelo1
				For nI:= 1 To Len(aQtdCount)
					nPos := Ascan(aContOk,{|x| x[1]==aQtdCount[nI]})
					If nPos == 0
						Aadd(aContOk,{aQtdCount[nI],1})
					Else
						aContOk[nPos,2]++
					EndIf
				Next
				For nI := 1 to len(aContOk)
					If aContOk[nI,2] >= CBA->CBA_CONTS
						aRet[1] := aContOk[nI,1]
						aRet[2] := .T.
						Exit
					Else
						aRet[1] := " "
					EndIf
				Next

			Else
				aRet[1] := aQtdCount[len(aQtdCount)]
				If aProdBrw[1][nPos,nPosSaldo] == aQtdCount[len(aQtdCount)]
					aRet[2] := .T.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaCBC)
CBC->(DBGoto(nRecnoCBC))
RestArea(aArea)
Return aClone(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³AnaInv()            ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Analisa e acerta o mestre de inventario possiciona-³
³          ³dado. Tal validacao eh feita pela funcao   CBAnaInv³
³          ³do programa ACDV035.PRG                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AnaInv()
Local nX
Local aCBB
Local lContinua := .T.
PRIVATE lMsErroAuto := .F.

CBA->(DbGoTop())
// esta linha foi colocada para funcionar como refresh do registro, pois o mesmo ate
// este momento nao esta atualizando.......
CBA->(DbGoto(nRecnoCBA))

// analisar se tem contagem em andamento
aCBB := RetInfoCBB()
If Empty(aCBB)
	MsgAlert(STR0112) //"Nao existem contagens para este mestre de inventario!"
	lContinua := .F.
EndIf
If lContinua
	For nX := 1 to len(aCBB)
		If aCBB[nX,3] == "1"
			MsgAlert(STR0113) //"Existem contagens em andamento"
			lContinua := .F.
			Exit
		EndIf
	Next
EndIf
If lContinua
	AtivaTimer(.F.)
	If CBA->CBA_STATUS $ "45"  // 4=Finalizado / 5=Processado
		MsgAlert(STR0114) //"Analise de inventario ja realizado por outro usuario"
		oDlgMain:End()
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If MsgYesNo(STR0115) //"Deseja analisar o Inventario?"
		CBAnaInv(.t.,.f.)
	EndIf
	Pergunte("ACD032",.F.)
	AtivaTimer(.t.)
	If CBA->CBA_STATUS $ "45" // 4=Finalizado / 5=Processado
		oDlgMain:End()
	EndIf
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³SelExclCont()       ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Janela que permite selecionar a contagem a ser     ³
³          ³excluida                                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function SelExclCont()
Local oDlg,oCbx
Local cContagem
Local nI
Local aCbx			:= {}
Local aContagens	:= RetInfoCBB()

AADD(aCbx,"")

For nI:=1 To Len(aContagens)
	AADD(aCbx,aContagens[nI,1]+ " - "+Posicione("CB1",1,xFilial("CB1")+aContagens[nI,2],"CB1_NOME"))
Next

If Empty(aCbx)
	Alert(STR0116) //"Nao existe contagens para serem excluidas!"
Else
	DEFINE DIALOG oDlg TITLE STR0117 FROM 0, 0 TO 22, 75 SIZE 200, 70 //"Exclusao de Contagem"
	TSay():New( 002, 002, {||STR0118},oDlg, ,, , , ,.T., , , 70, 12) //"Selecione a Contagem:"
	oCbx := TComboBox():New(010,002, bSETGET(cContagem),aCbx, 100, 70, oDlg, ,,,,,.T.,,,,,,,)
	TButton():New(023,035, STR0119, oDlg, {|| If(VldDelCont(cContagem,oCbx,aCbx),oDlg:End(),.T.)}, 30, 14, , , .F., .T., , , .T.) //"&Excluir"
	TButton():New(023,070, STR0120, oDlg, {||oDlg:End()}, 30, 14, , , .F., .T., , , .T.) //"&Sair"
	ACTIVATE DIALOG oDlg   CENTER
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³VldDelCont()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Funcao que valida a exclusao da contagens.         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cContagem: Numero da contagem (CBB_NUM)            ³
³          ³oCBX     : Objeto Combobox que contem a lista de   ³
³          ³           contagens                               ³
³          ³aContagens:Array das contagens                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Logico                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldDelCont(cContagem,oCbx,aContagens)
Local cAux := cContagem
Local nPos
Local lRet	:= .T.

If Empty(cContagem)
	Alert(STR0121) //"Selecione uma contagem valida!"
	lRet := .F.
EndIf

If lRet .And. CBA->CBA_STATUS=="5"
	Alert(STR0122) //"Nao e possivel excluir a contagem, pois o mestre ja esta processada."
	lRet := .F.
EndIf

If lRet .And. CBA->CBA_STATUS=="4"
	Aviso(	STR0103,STR0123+ ; //"Atencao"###"Nao e possível excluir esta contagem, pois o mestre de inventario ja esta finalizado! "
	STR0124+; //"Favor efetuar a exclusao do mestre de inventario para que o status seja alterado de "Finalizado" "###" "+;
	STR0125, {"Ok"}) //"para "Em Andamento"."
	lRet := .F.
EndIf

cContagem := Left(cContagem,TamSx3("CBB_NUM")[1])
//Excluir Contatem
If lRet .And. !DelCBBCont(cContagem)
	Alert(STR0127)    //"Nao foi possivel excluir esta contagem"
	lRet := .F.
EndIf
If lRet
	If  oCbx<>NIL .AND. aContagens<>NIL
		nPos := AsCan(aContagens,{|x| Trim(x)==Trim(cAux)})
		If nPos > 0
			aDel(aContagens,nPos)
			aSize(aContagens,Len(aContagens)-1)
			oCbx:aItems := aClone(aContagens)
			oCbx:Refresh()
			ColsCont(aProdBrw[2][oBrw:nAT,2])
		EndIf
	EndIf
	AtuGetDados()
EndIf
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³DelCBBCont()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Exclui a Contagem do CBB                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cContagem: Numero da contagem (CBB_NUM)            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Logico                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function DelCBBCont(cContagem)
Local lUltContagem := .F.
Local lRet	:= .T.
Local cCodInv   := ""

CBB->(DbSetOrder(3))
If !CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV+cContagem))
	Alert(STR0128)    //"Contagem nao localizada no CBB!!!"
	lRet := .F.
EndIf

cCodInv := CBB->CBB_CODINV

If lRet .And. CBB->CBB_STATUS=="1"
	If ! CBB->(RLock())
		Alert(STR0129)    //"Contagem em Andamento!!!"
		lRet := .F.
	EndIf
	CBB->(MSUnLock())
EndIf

If lRet
	//Verifica a ultima contagem
	lUltContagem := (CBUltCont(CBA->CBA_CODINV) == cContagem)
	Begin Transaction
		//Exclui CBCs
		DelCBC(cContagem)
		//Exclui CBB
		RecLock("CBB",.F.)
		CBB->(DbDelete())
		CBB->(MsUnlock())
		RecLock("CBA",.F.)
		If !lModelo1
			CBA->CBA_AUTREC	:= "1"
		Else
			CBA->CBA_STATUS := "1"
		EndIf
		CBA->(MsUnlock())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Decrementa numero de contagens realizadas do mestre          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CBAtuContR(cCodInv, 2)
		
	End Transaction
EndIf
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³DelCBBCont()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Exclui as Contagens do CBC                         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cContagem: Numero da contagem (CBB_NUM)            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function DelCBC(cContagem)
CBC->(DbSetOrder(2))
CBC->(DbSeek(xFilial("CBC")+cContagem))
While CBC->(!Eof() .AND. CBC_FILIAL+CBC_NUM==xFilial("CBC")+cContagem)
	RecLock("CBC",.F.)
	CBC->(DbDelete())
	CBC->(MsUnlock())
	CBC->(DbSkip())
EndDo
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³ConfigCols()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Configura a visualizaco das colunas a partir do InI³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aCampos: Array com os campos passados              ³
³          ³nOpc   : 1-Gravacao; 2-Leitura.                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ConfigCols(aCampos,nOpc)
Local cIniFile	:= "ACDA032.INI"
Local cChave	:=	If(CBA->CBA_TIPINV== "1","ARRAYPRODUTO","ARRAYENDERECO")
Local nI
Local cValor	:= ""

For nI:=3 To Len(aCampos)-2
	If nOpc==1
		cValor := WritePPros( cChave,aCampos[nI,1],If(aCampos[nI,5],".T.",".F."), cIniFile)
	Else
		cValor := GetPvProfString(cChave,aCampos[nI,1] ,".T.", cIniFile)
	EndIf

	If ValType(cValor)=="C"
		If Trim(cValor)==".T."
			aCampos[nI,5] := .T.
		Else
			aCampos[nI,5] := .F.
		EndIf
	Else
		aCampos[nI,5]	:= cValor
	EndIf
Next
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³AtuColsBrw()        ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Atualiza a coluna do browser informado no array.   ³
³          ³Lembrando que para esta alteracao ter efeito sera  ³
³          ³necessario fechar a dialog e chamar a funcao nova- ³
³          ³mente.                                             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aCampos: Array com os campos passados              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtuColsBrw(aCampos)
AtivaTimer(.F.)
If !MsgYesNo(	STR0130+CHR(13)+CHR(10)+ ; //"Para que suas alterecoes surtam efeito, o Monitor sera fechado. Favor reabri-lo novamente!"
	STR0131) //"Deseja realizar as alteracoes?"
	AtivaTimer(.T.)
Else
	ConfigCols(aCampos,1)
	oDlgMain:End()
EndIf
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³AutRecon()          ³Autor³ACD                ³20/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Autoriza  a recontagem do inventario somente quan- ³
³          ³estiver no modelo 2                                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AutRecon()
Local nX
Local aProdutos	:= aClone(aProdBrw[1])
Local cProduto,cArm,cEnd,cLote,cSLote,cNumSer
Local cNumCBC
Local cChave	:= ""
Local lAutRecon	:= .F.
Local lContinua	:= .T.
Local aUltCont	:={}
Local aInfoCBB	:={}

AtivaTimer(.f.)
CBA->(DbGoTop())
// esta linha foi colocada para funcionar como refresh do registro, pois o mesmo ate
// este momento nao esta atualizando.......
CBA->(DbGoto(nRecnoCBA))

//Verifica se existe contagem pendente
aInfoCBB := RetInfoCBB()
For nX:=1 to len(aInfoCBB)
	If aInfoCBB[nX,3]== "0"
		IW_MSGBOX(STR0132+aInfoCBB[nX,1]+STR0133+; //"Nao eh permitda a recontagem pois a contagem ""###"", nao esta "
		STR0134,STR0021) //"iniciada ou esta em andamento!"###"Aviso"
		lContinua := .F.
		Exit
	EndIf
Next
If lContinua
	If Empty(aInfoCBB)
		lAutRecon := .T.
	EndIf

	For nX:= 1 to len(aProdutos)
		cProduto	:= aProdutos[nX,2]
		cArm		:= aProdutos[nX,6]
		cEnd		:= aProdutos[nX,7]
		cLote		:= aProdutos[nX,4]
		cSLote		:= aProdutos[nX,5]
		cNumSer		:= aProdutos[nX,8]
		nSaldo		:= aProdutos[nX,nPosSaldo]
		If len(aProdutos[nx])< 11
			Loop
		EndIf
		aUltCont	:= aClone(aProdutos[nX,len(aProdutos[nX])])
		cNumCBC		:= aUltCont[3]
		CBC->(DbSetOrder(2))
		If CBC->(DbSeek(xFilial("CBC")+cNumCBC+cProduto+cArm+cEnd+cLote+cSLote+cNumSer))
			cChave	:= xFilial("CBC")+cNumCBC+cProduto+cArm+cEnd+cLote+cSLote+cNumSer
		Else
			Loop
		Endif
		While CBC->(!Eof() .and. cChave == CBC->(CBC_FILIAL+CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER))
			If (Str(CBC->CBC_QTDORI,14,4) == Str(CBC->CBC_QUANT,14,4)) .AND. (Str(CBC->CBC_QUANT,14,4)  #  Str(nSaldo,14,4))
				lAutRecon	:= .T.
				Exit
			EndIf
			CBC->(DbSkip())
		EndDo
		If lAutRecon .or. (Len(aInfoCBB)==0)
			Exit
		EndIf
	Next

	If Empty(cChave)
		lAutRecon := .T.
	Endif
EndIf

If lContinua .And. !lAutRecon
	IW_MSGBOX(STR0135,STR0021) //"Nao eh permitda a recontagem pois o inventario ja foi auditado!"###"Aviso"
	lContinua := .F.
EndIf

If lContinua .And. !MsgYesNo(STR0136) //"Autoriza nova recontagem para este Mestre de Inventario?"
	AtivaTimer(.t.)
	lContinua := .F.
EndIf

If lContinua
	Begin Transaction
		RecLock("CBA")
		CBA->CBA_AUTREC:= "1"
		CBA->(MsUnLock())

		For nX:= 1 to len(aProdutos)
			cProduto	:= aProdutos[nX,2]
			cArm		:= aProdutos[nX,6]
			cEnd		:= aProdutos[nX,7]
			cLote		:= aProdutos[nX,4]
			cSLote		:= aProdutos[nX,5]
			cNumSer		:= aProdutos[nX,8]
			nSaldo		:= aProdutos[nX,nPosSaldo]
			If len(aProdutos[nx])< 11
				Loop
			EndIf
			aUltCont	:= aClone(aProdutos[nX,len(aProdutos[nX])])
			cNumCBC		:= aUltCont[3]
			CBC->(DbSetOrder(2))
			CBC->(DbSeek(xFilial("CBC")+cNumCBC+cProduto+cArm+cEnd+cLote+cSLote+cNumSer))
			While CBC->(!Eof() .and. CBC_FILIAL+CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER ==;
				xFilial("CBC")+cNumCBC+cProduto+cArm+cEnd+cLote+cSLote+cNumSer)
				RecLock("CBC",.F.)
				If Empty(CBC->CBC_CONTOK)
					If Str(nSaldo,14,4) == Str(aUltCont[1],14,4)
						CBC->CBC_CONTOK	:="1"
					EndIf
				EndIf
				CBC->(MsUnLock())
				CBC->(DbSkip())
			EndDo
		Next
	End Transaction
	
	If ExistBlock("AC32RECON")
		ExecBlock("AC32RECON",.F.,.F.)
	EndIf   
	
	oDlgMain:End()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³RetHdItensOp        ³Autor³ACD                ³20/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Retorna os arrays de controle para visualizacao dos³
³          ³itens lidos por operador (Folder Operadores)       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aCfgItens: Array com os campos que poderao ser ocu-³
³          ³           ltados pelo usario do monitor.          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Array                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetHdItensOp(aCfgItens)
Local cCampo	:= ""
Local aRet 		:= Array(3)
Local nI,nPos
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0 
Local nTamID		:= Iif(lUniCPO, TamSX3("CBC_IDUNIT")[1],6)

aRet[1] := {STR0155} //"Produto"
aRet[2] := {45}
aRet[3] := {STR0155} //"Produto"

For nI:=1 To Len(aCfgItens)
	cCampo := Trim(RetTituloCpo(aCfgItens[nI]))
	nPos := Ascan(aInfoBrow[1],{|x| Trim(x)==cCampo })
	If nPos > 0
		Aadd(aRet[1],aInfoBrow[1,nPos]) //Titulo do Campo
		Aadd(aRet[2],aInfoBrow[3,nPos]) //Tamanho
	ElseIf Upper(cCampo)=="QUANTIDADE"
		Aadd(aRet[1],STR0156) //Titulo do Campo //"Quantidade"
		Aadd(aRet[2],45) //Tamanho
	EndIf
	Aadd(aRet[3],cCampo)
Next
Aadd(aRet[1],STR0157) //Titulo do Campo //"Etiqueta"
Aadd(aRet[2],40) //Tamanho
Aadd(aRet[3],STR0157) //"Etiqueta"
If lWmsNew .And. lUniCPO
	Aadd(aRet[1],STR0171) //Titulo do Campo //"Unitizador"
	Aadd(aRet[2],nTamID) //Tamanho
	Aadd(aRet[3],STR0171) //"Unitizador"
EndIf

Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³RetHdSB7            ³Autor³ACD                ³20/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Retorna os arrays de controle para visualizacao dos³
³          ³Registros de Inventario - SB7 (Registro de Invtari)³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aCfgSB7  : Array com os campos que poderao ser ocu-³
³          ³           ltados pelo usario do monitor.          ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Array                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RetHdSB7(aCfgSB7)
Local cCampo	:= ""
Local aRet 		:= Array(3)
Local nI,nPos

aRet[1]:= {" ",STR0137,STR0138} //"Documento"###"Produto"
aRet[2]:= {4.1,45,45}
aRet[3]:= {"B7_STATUS","B7_DOC","B7_COD"}


For nI:=1 To Len(aCfgSB7)
	cCampo := Trim(RetTituloCpo(aCfgSB7[nI]))
	nPos := Ascan(aInfoBrow[1],{|x| Trim(x)==cCampo })
	If nPos > 0
		Aadd(aRet[1],aInfoBrow[1,nPos]) //Titulo do Campo
		Aadd(aRet[2],aInfoBrow[3,nPos]) //Tamanho
	ElseIf Upper(cCampo)=="QUANTIDADE"
		Aadd(aRet[1],STR0156) //Titulo do Campo //"Quantidade"
		Aadd(aRet[2],45) //Tamanho
	EndIf
	Aadd(aRet[3],cCampo)
Next
Aadd(aRet[1],STR0158) //Titulo do Campo //"Data Inv."
Aadd(aRet[2],40) //Tamanho
Aadd(aRet[3],"B7_DATA")
Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³Acerto()            ³Autor³ACD                ³20/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Faz acerto do inventario a partir da tabela SB7    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function Acerto()
Local aAreaSB7 := SB7->(GetArea())

If MsgYesNo(STR0139) //"Confirma o Acerto de Inventario?"
	SB7->(DbOrderNickName("ACDSB701"))
	If SB7->(DbSeek(xFilial("SB7")+CBA->CBA_CODINV))
		MATA340(.T.,CBA->CBA_CODINV,.F.)
	EndIf
	RestArea(aAreaSB7)
	Pergunte("ACD032",.F.)
	oDlgMain:End()
	If lUsaCB001
		CBATUCB0()
	EndIf	
EndIf
Return

Static Function GetArray(aControle,nTamCPo,lLocaliz,cAlias)
Local nI         := 0
Local nPos       := 0
Local cClasse    := " "
Local aEleito    := Array(2)
Local lSubLote   := .F.
Local lContinua  := .T.
Local nTamLote   := TamSX3("B8_LOTECTL")[1]
Local nTamSLote  := TamSX3("B8_NUMLOTE")[1]
Local nTamEnd    := TamSX3("BF_LOCALIZ")[1]
Local nTamSeri   := TamSX3("BF_NUMSERI")[1]
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lPrdCtrWms := .F.
Local oSaldoWMS  := Nil
Local lUniCPO    := CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local cChave     := ""
Local cCodUnit	:= CriaVar('D14_IDUNIT', .F.)
Default lLocaliz:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisando Classificacao por curva ABC, somente inv. por prod.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CBA->CBA_TIPINV=="1" .and. !Empty(cClasses)
	If !CBClABC(If(lLocaliz,SBF->BF_PRODUTO,SB2->B2_COD),cClasses,.T.,@cClasse)
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If lWmsNew .And. lLocaliz .And. cAlias <> NIL
		lPrdCtrWms := IntWms((cAlias)->BF_PRODUTO)
	EndIf
	//Tratativa para o novo WMS
	If lWmsNew .and. lPrdCtrWms 
		If ExistCpo("SB1",(cAlias)->BF_PRODUTO,1,,.F.)
			oSaldoWMS := WMSDTCEstoqueEndereco():New()
			SB1->(MsSeek(xFilial("SB1")+(cAlias)->BF_PRODUTO))
			aadd(aControle,{NIL,(cAlias)->BF_PRODUTO,SB1->B1_DESC,(cAlias)->BF_LOTECTL,(cAlias)->BF_NUMLOTE,(cAlias)->BF_LOCAL, ;
			(cAlias)->BF_LOCALIZ,(cAlias)->BF_NUMSERI,cClasse,;
			oSaldoWMS:GetSldWMS((cAlias)->BF_PRODUTO,(cAlias)->BF_LOCAL,(cAlias)->BF_LOCALIZ,(cAlias)->BF_LOTECTL,(cAlias)->BF_NUMLOTE,(cAlias)->BF_NUMSERI,.F.,Iif( lUniCPO,(cAlias)->IDUNIT,NIL)),0,"",Iif( lUniCPO,(cAlias)->IDUNIT,"")})
		EndIf
		
		If Len(aControle) > 0
			cChave := aControle[Len(aControle),2]+aControle[Len(aControle),6]+aControle[Len(aControle),7]+;
						 aControle[Len(aControle),4]+aControle[Len(aControle),5]+aControle[Len(aControle),8]
			If lUniCPO
				cChave += aControle[Len(aControle),13]
			EndIf
			aEleito := ElegeCount(cChave)
			aControle[Len(aControle),nTamEle] := aEleito[1]  //Quantidade Eleita
			//Atualiza a legenda do Status
			If aEleito[2]
				aControle[Len(aControle),1] := aCores[1]
			Else
				aControle[Len(aControle),1] := aCores[2]
			EndIf
		EndIf
		
	ElseIf lLocaliz
		If lCBA03201
			lContinua := ExecBlock("CBA03201",.F.,.F.,{SBF->BF_PRODUTO,SBF->BF_LOCAL,SBF->BF_LOCALIZ,SBF->BF_NUMSERI,SBF->BF_LOTECTL,SBF->BF_NUMLOTE})
			If ValType(lRet)#"L"
				lContinua := .T.
			EndIf
		Endif

		If lContinua
			If cAlias # Nil
				If FindFunction("A340SldSBF")
					nSaldo := SB7->(A340SldSBF((cAlias)->BF_LOCAL,(cAlias)->BF_LOCALIZ,(cAlias)->BF_PRODUTO,(cAlias)->BF_NUMSERI,(cAlias)->BF_LOTECTL,(cAlias)->BF_NUMLOTE))
				Else
					nSaldo := SaldoSBF((cAlias)->BF_LOCAL,(cAlias)->BF_LOCALIZ,(cAlias)->BF_PRODUTO,(cAlias)->BF_NUMSERI,(cAlias)->BF_LOTECTL,(cAlias)->BF_NUMLOTE)
				EndIf
				If ExistCpo("SB1",(cAlias)->BF_PRODUTO,1,,.F.)
					SB1->(MsSeek(xFilial("SB1")+(cAlias)->BF_PRODUTO))
					aadd(aControle,{NIL,(cAlias)->BF_PRODUTO,SB1->B1_DESC,(cAlias)->BF_LOTECTL,(cAlias)->BF_NUMLOTE,(cAlias)->BF_LOCAL, ;
									(cAlias)->BF_LOCALIZ,(cAlias)->BF_NUMSERI,cClasse,nSaldo,0,"",cCodUnit})
				EndIf
			Else
				If FindFunction("A340SldSBF")
					nSaldo := SB7->(A340SldSBF(SBF->BF_LOCAL,SBF->BF_LOCALIZ,SBF->BF_PRODUTO,SBF->BF_NUMSERI,SBF->BF_LOTECTL,SBF->BF_NUMLOTE))
				Else
					nSaldo := SaldoSBF(SBF->BF_LOCAL,SBF->BF_LOCALIZ,SBF->BF_PRODUTO,SBF->BF_NUMSERI,SBF->BF_LOTECTL,SBF->BF_NUMLOTE)
				EndIf				
				If ExistCpo("SB1",SBF->BF_PRODUTO,1,,.F.)
					SB1->(MsSeek(xFilial("SB1")+SBF->BF_PRODUTO))
					aadd(aControle,{NIL,SBF->BF_PRODUTO,SB1->B1_DESC,SBF->BF_LOTECTL,SBF->BF_NUMLOTE,SBF->BF_LOCAL, ;
									SBF->BF_LOCALIZ,SBF->BF_NUMSERI,cClasse,nSaldo,0,"",cCodUnit})
				EndIf
			EndIf
			
			If Len(aControle) > 0
				aEleito	:= ElegeCount(aControle[Len(aControle),2]+aControle[Len(aControle),6]+aControle[Len(aControle),7]+ ;
								aControle[Len(aControle),4]+aControle[Len(aControle),5]+aControle[Len(aControle),8])
				aControle[Len(aControle),nTamEle]		:= aEleito[1]  //Quantidade Eleita
		
				//Atualiza a legenda do Status
				If aEleito[2]
					aControle[Len(aControle),1] := aCores[1]
				Else
					aControle[Len(aControle),1] := aCores[2]
				EndIf
			EndIf
		EndIf
	Else
		If cAlias # Nil .And. Rastro((cAlias)->B2_COD)
			lSubLote := Rastro((cAlias)->B2_COD, "S")
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))			
			SB1->(MsSeek(xFilial("SB1")+(cAlias)->B2_COD))
			DbSelectArea("SB8")
			SB8->(DbSetOrder(3))
			SB8->(MsSeek(xFilial("SB8")+(cAlias)->(B2_COD+B2_LOCAL+CBC_LOTECT+CBC_NUMLOT)))
			If lSubLote
				aadd(aControle,{NIL,(cAlias)->B2_COD,SB1->B1_DESC,(cAlias)->CBC_LOTECT,IIf(lSubLote,(cAlias)->CBC_NUMLOT,Space(nTamSLote)),(cAlias)->B2_LOCAL,Space(nTamEnd),Space(nTamSeri),cClasse,SB8Saldo(),0,"",cCodUnit})				
			Else
				nPos := AsCan(aControle,{|x|x[2]+x[6]+x[4]==(cAlias)->B2_COD+(cAlias)->B2_LOCAL+(cAlias)->CBC_LOTECT})				
				If Empty(nPos)
					aadd(aControle,{NIL,(cAlias)->B2_COD,SB1->B1_DESC,(cAlias)->CBC_LOTECT,IIf(lSubLote,(cAlias)->CBC_NUMLOT,Space(nTamSLote)),(cAlias)->B2_LOCAL,Space(nTamEnd),Space(nTamSeri),cClasse,SB8Saldo(),0,"",cCodUnit})										
				Else
					aControle[nPos,nPosSaldo]+= SB8Saldo()
				EndIf
			EndIf

			nI := len(aControle)
			aEleito	:= ElegeCount(aControle[nI,2]+aControle[nI,6]+aControle[nI,7]+aControle[nI,4]+aControle[nI,5]+aControle[nI,8])
			aControle[nI,nTamEle]		:= aEleito[1]  //Quantidade Eleita

			//Atualiza a legenda do Status
			If aEleito[2]
				aControle[nI,1] := aCores[1]
			Else
				aControle[nI,1] := aCores[2]
			EndIf
		ElseIf Rastro(SB2->B2_COD)
			lSubLote := Rastro(SB2->B2_COD, "S")
			DbSelectArea("SB8")
			SB8->(DbSetOrder(3))
			SB8->(MsSeek(xFilial("SB8")+SB2->(B2_COD+B2_LOCAL)))
			SB8->(MsSeek(xFilial("SB1")+SB8->B8_PRODUTO))
			While SB8->( !Eof() .And. B8_FILIAL+B8_PRODUTO+B8_LOCAL == xFilial("SB8")+SB2->(B2_COD+B2_LOCAL))
				If lSubLote
					aadd(aControle,{NIL,B8_PRODUTO,SB1->B1_DESC,B8_LOTECTL,IIf(lSubLote,B8_NUMLOTE,Space(nTamSLote)),B8_LOCAL,Space(nTamEnd),Space(nTamSeri),cClasse,SB8Saldo(),0,"",cCodUnit})				
				Else
					nPos := AsCan(aControle,{|x|x[2]+x[6]+x[4]==B8_PRODUTO+B8_LOCAL+B8_LOTECTL})				
					If Empty(nPos)
						aadd(aControle,{NIL,B8_PRODUTO,SB1->B1_DESC,B8_LOTECTL,IIf(lSubLote,B8_NUMLOTE,Space(nTamSLote)),B8_LOCAL,Space(nTamEnd),Space(nTamSeri),cClasse,SB8Saldo(),0,"",cCodUnit})										
					Else
						aControle[nPos,nPosSaldo]+= SB8Saldo()
					EndIf
				EndIf
				SB8->(DbSkip())
			EndDo
			For nI:=1 To Len(aControle)
				aEleito	:= ElegeCount(aControle[nI,2]+aControle[nI,6]+aControle[nI,7]+aControle[nI,4]+aControle[nI,5]+aControle[nI,8])
				aControle[nI,nTamEle]		:= aEleito[1]  //Quantidade Eleita

				//Atualiza a legenda do Status
				If aEleito[2]
					aControle[nI,1] := aCores[1]
				Else
					aControle[nI,1] := aCores[2]
				EndIf
			Next
		Else
		    If cAlias # Nil 
				SB1->(MsSeek(xFilial("SB1")+(cAlias)->B2_COD))
				aadd(aControle,{NIL,(cAlias)->B2_COD,SB1->B1_DESC,Space(nTamLote),Space(nTamSLote),(cAlias)->B2_LOCAL,Space(nTamEnd),Space(nTamSeri),cClasse,SaldoSB2(,.F.,,,,cAlias),0,"",""})
	        Else 
				SB1->(MsSeek(xFilial("SB1")+SB2->B2_COD))
				aadd(aControle,{NIL,SB2->B2_COD,SB1->B1_DESC,Space(nTamLote),Space(nTamSLote),SB2->B2_LOCAL,Space(nTamEnd),Space(nTamSeri),cClasse,SaldoSB2(,.F.),0,"",""})
			EndIf
			aEleito	:= ElegeCount(aControle[Len(aControle),2]+aControle[Len(aControle),6]+aControle[Len(aControle),7]+aControle[Len(aControle),4]+aControle[Len(aControle),5]+aControle[Len(aControle),8])
			aControle[Len(aControle),nTamEle]		:= aEleito[1]  //Quantidade Eleita

			//Atualiza a legenda do Status
			If aEleito[2]
				aControle[Len(aControle),1] := aCores[1]
			Else
				aControle[Len(aControle),1] := aCores[2]
			EndIf
		EndIf
	EndIf
EndIf
Return


//NOVO CBC      1234567890
Static Function SetCBCArray(aControle,nTamArray,nTamCpo,aInfoCBB)
Local cAliasCBC  := "CBC"
Local cQuery		:= ""
Local cCodUnit   := " "
Local nJ
Local aEleito		:= Array(2)
Local nSaldoSB8
Local nSaldoSB2
Local aAreaSB2   := SB2->(GetArea())
Local aAreaSB8   := SB8->(GetArea())

Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0

DbSelectArea("SB8")
SB8->(DbSetOrder(3))

DbSelectArea("SB2")
SB2->(DbSetOrder(1))

For nJ:= 1 To Len(aInfoCBB)
	cAliasCBC := GetNextAlias()
	cQuery    := "SELECT CBC_FILIAL,CBC_NUM,CBC_COD,CBC_LOCAL,CBC_LOCALI,CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,B1_DESC "
	If lWmsNew .And. lUniCPO
		cQuery +=" ,CBC_IDUNIT "
	EndIf
	cQuery    += "FROM "+RetSqlName("CBC")+" CBC, "
	cQuery    += +RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE CBC.CBC_FILIAL ='"+xFilial("CBC")+"' AND "
	cQuery    += "CBC.CBC_NUM = '" + aInfoCBB[nJ,1] + "' AND "
	cquery	  += "CBC.CBC_CODINV = '" +CBA->CBA_CODINV+"' AND "
	cQuery    += "CBC.CBC_COD = SB1.B1_COD AND "
				If !lShowZero
					cQuery    += "CBC.CBC_QUANT > 0 AND " // Filtrar Zeradas
				EndIf
	cQuery    += "CBC.D_E_L_E_T_ =' ' "
	If lWmsNew .And. lUniCPO
		cQuery    += "ORDER BY CBC_NUM,CBC_COD,CBC_LOCAL,CBC_LOCALI,CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,CBC_IDUNIT "
	Else
		cQuery    += "ORDER BY CBC_NUM,CBC_COD,CBC_LOCAL,CBC_LOCALI,CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER "
	EndIf
	cQuery    := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCBC,.T.,.T.)
	While (cAliasCBC)->(!Eof() .AND. CBC_FILIAL+CBC_NUM==xFilial("CBC")+aInfoCBB[nJ,1])
		If lWmsNew .And. lUniCPO
			If Ascan(aControle,{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[8]+x[13]==(cAliasCBC)->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+CBC_IDUNIT)}) > 0
				(cAliasCBC)->(DbSkip())
				Loop
			EndIf
		Else
			If Ascan(aControle,{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[8]==(cAliasCBC)->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER)}) > 0
				(cAliasCBC)->(DbSkip())
				Loop
			EndIf
		EndIf

		AADD(aControle,Array(nTamArray))
		aControle[Len(aControle),02] := (cAliasCBC)->CBC_COD
		aControle[Len(aControle),03] := (cAliasCBC)->B1_DESC
		aControle[Len(aControle),04] := (cAliasCBC)->CBC_LOTECT
		aControle[Len(aControle),05] := (cAliasCBC)->CBC_NUMLOT
		aControle[Len(aControle),06] := (cAliasCBC)->CBC_LOCAL
		aControle[Len(aControle),07] := (cAliasCBC)->CBC_LOCALI
		aControle[Len(aControle),08] := (cAliasCBC)->CBC_NUMSER
		If lWmsNew .And. lUniCPO
			aControle[Len(aControle),13] := (cAliasCBC)->CBC_IDUNIT
			cCodUnit:= aControle[Len(aControle),13]
		EndIf	

		If !Localiza((cAliasCBC)->CBC_COD,.T.)
			If Rastro((cAliasCBC)->CBC_COD)			
				If SB8->(dbSeek( xFilial( "SB8" ) + (cAliasCBC)->CBC_COD + (cAliasCBC)->CBC_LOCAL + (cAliasCBC)->CBC_LOTECT, .F.))
					nSaldoSB8 	:= SB8->B8_SALDO 
					aControle[Len(aControle),nPosSaldo] := nSaldoSB8
				Else
					aControle[Len(aControle),nPosSaldo] := 0
				Endif
			Else			
				If SB2->(dbSeek( xFilial( "SB2" ) + (cAliasCBC)->CBC_COD + (cAliasCBC)->CBC_LOCAL, .F.))
					nSaldoSB2 	:= SB2->B2_QATU
					aControle[Len(aControle),nPosSaldo] := nSaldoSB2
				Else
					aControle[Len(aControle),nPosSaldo] := 0
				EndIf						
			EndIf
		Else
			aControle[Len(aControle),nPosSaldo] := 0
		EndIf
	 
		cProd		:= aControle[Len(aControle),2]
		cArm		:= aControle[Len(aControle),6]
		cEnd		:= aControle[Len(aControle),7]
		cLote		:= aControle[Len(aControle),4]
		cSLote		:= aControle[Len(aControle),5]
		cNumSeri	:= aControle[Len(aControle),8]
		If lWmsNew .And. lUniCPO
			aEleito		:= ElegeCount(cProd+cArm+cEnd+cLote+cSLote+cNumSeri+cCodUnit)
		Else
			aEleito		:= ElegeCount(cProd+cArm+cEnd+cLote+cSLote+cNumSeri)
		EndIf
			
		aControle[Len(aControle),nTamEle]	:= aEleito[1]  //Quantidade Eleita
	
		//Atualiza a legenda do Status
		If aEleito[2]
			aControle[Len(aControle),1] := aCores[1]
		Else
			aControle[Len(aControle),1] := aCores[2]
		EndIf
		(cAliasCBC)->(DbSkip())
    EndDo
    (cAliasCBC)->(dbCloseArea())
Next      

RestArea(aAreaSB8)
RestArea(aAreaSB2)
dbCloseArea("SB8")
dbCloseArea("SB2")

Return

//Cria SubArray para o aProdBrw[1]
Static Function SetSubArray(aControle,nTamCpo,aInfoCBB)
Local nI	:= 0
Local nG	:= 0
Local nPos	:= 0

Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lUniCPO 	:= CBC->(ColumnPos("CBC_IDUNIT")) > 0 

For nI:=1 To Len(aInfoCBB)
	For nG:=1 To Len(aControle)
		If nTamCpo+nI > len(aControle[nG])
			aadd(aControle[nG],NIL)
		EndIf
		If aControle[nG,nTamCpo+nI]==NIL
			aControle[nG,nTamCpo+nI] := {0,NIL,aInfoCBB[nI,1]}
		EndIf
		IF lWmsNew .And. lUniCPO
			nPos := Ascan(aProdBrw[1],{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[8]+x[13] == aControle[nG,2]+aControle[nG,6]+aControle[nG,7]+aControle[nG,4]+aControle[nG,5]+aControle[nG,8]+aControle[nG,13]})
			If (nPos > 0)  .AND. (Len(aProdBrw[1][nPos])>=nTamCpo+nI) .AND. (aProdBrw[1][nPos,nTamCpo+nI][2]<> NIL)  //CHECAR TAMBEM O CONTROLE DA CONTAGEM
				aControle[nG,nTamCpo+nI][1] := aProdBrw[1][nPos,nTamCpo+nI][1]
				aControle[nG,nTamCpo+nI][2] := aProdBrw[1][nPos,nTamCpo+nI][2]
			Else
				cProd		:= aControle[nG,2]
				cArm		:= aControle[nG,6]
				cEnd		:= aControle[nG,7]
				cLote		:= aControle[nG,4]
				cSLote		:= aControle[nG,5]
				cNumSeri	:= aControle[nG,8]
				cIdunit 	:= IIF ((aControle[nG,13]) == NIL, " " , aControle[nG,13])
				aControle[nG,nTamCpo+nI][1] := RetQtd(aInfoCBB[nI][1],cProd+cArm+cEnd+cLote+cSLote+cNumSeri+cIdunit,nI)[1]
			EndIf
		Else
			nPos := Ascan(aProdBrw[1],{|x| x[2]+x[6]+x[7]+x[4]+x[5]+x[8]==aControle[nG,2]+aControle[nG,6]+aControle[nG,7]+aControle[nG,4]+aControle[nG,5]+aControle[nG,8]})
			If (nPos > 0)  .AND. (Len(aProdBrw[1][nPos])>=nTamCpo+nI) .AND. (aProdBrw[1][nPos,nTamCpo+nI][2]<> NIL)  //CHECAR TAMBEM O CONTROLE DA CONTAGEM
				aControle[nG,nTamCpo+nI][1] := aProdBrw[1][nPos,nTamCpo+nI][1]
				aControle[nG,nTamCpo+nI][2] := aProdBrw[1][nPos,nTamCpo+nI][2]
			Else
				cProd		:= aControle[nG,2]
				cArm		:= aControle[nG,6]
				cEnd		:= aControle[nG,7]
				cLote		:= aControle[nG,4]
				cSLote		:= aControle[nG,5]
				cNumSeri	:= aControle[nG,8]
				aControle[nG,nTamCpo+nI][1] := RetQtd(aInfoCBB[nI][1],cProd+cArm+cEnd+cLote+cSLote+cNumSeri,nI)[1]
			EndIf
		EndIf
	Next
Next
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIFSCONT  ºAutor  ³Erike Yuri da Silva º Data ³  23/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Janela que possibilita visualizar a diferencas das contagensº±±
±±º          ³permitindo realizar o ajuste, conforme as configuracoes pre-º±±
±±º          ³definidas.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIFSCONT                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DifsCont(cChave)
Local 	oDlgDifs,oBrwDifs, oStatus,oSeek
Local 	cUsado		:= REPLICATE(Chr(128),14)+CHR(160)
Local	cSeek		:= Space(TamSx3("CB0_CODETI")[1])
Local 	nI, nX
Local 	nPos,nPos2
Local	nOpcao		:= 0
Local 	nTamCpo 	:= TamSx3("CBC_COD")[1]
Local	lFiltra		:= .F.
Local 	aTamQtd		:= aClone(TamSx3("CBC_QUANT"))
Local 	aInfoCBB	:= RetInfoCBB()
Local 	aButtons 	:= {}
Local 	aBkpaHead	:= aClone(aHeader)
Local 	aEtiqueta	:= {}
Local 	aProds		:= {}
Local 	aOrganiz	:= {}
Local 	aAltera		:= {}			//Array com campos que podem ser alterados
Local	aOkCont		:= {}

Private	nMaxCol		:= 0
Private aUndo		:= {}
Private	lQtdVari	:= GetMv("MV_VQTDINV")=="1" .OR. CBQtdVar(Left(cChave,Tamsx3("B1_COD")[1]))

If Empty(aInfoCBB) .or. Empty(cChave)
	IW_MSGBOX(STR0026,STR0021) //"Nao existem dados a serem visualizados!"###"Aviso"
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa o timer                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AtivaTimer(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela para selecao das contagens que serao comparadas       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aInfoCBB := SelContDifs(aInfoCBB)

If Empty(aInfoCBB)
	IW_MSGBOX(STR0026,STR0021) //"Nao existem dados a serem visualizados!"###"Aviso"
	AtivaTimer(.T.)
	Return
EndIf

If lUsaCB001
	nTamCpo 	:= TamSx3("CBC_CODETI")[1]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incializa Browse de Manutencao                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:= {}
aHeader	:= {}

Aadd(aHeader,{ ""	,"LINHA","@!",0,0,"",cUsado,"","CBC","V"})
Aadd(aHeader,{ ""	,"LEGENDA","@BMP",0,0,"",cUsado,"","CBC","V"})
If lUsaCB001
	Aadd(aHeader,{ STR0140,"CBC_CODETI","@!",nTamCPO,0,"",cUsado,"C","CBC","V"}) //"Etiqueta"
Else
	Aadd(aHeader,{ STR0138 ,STR0141,"@!",nTamCPO,0,"",cUsado,"C","CBC","V"})	 //"Produto"###"CodProd"
EndIf

For nI:=1 To Len(aInfoCBB)
	Aadd(aHeader,{ STR0142+aInfoCBB[nI,1]  ,"Qtd"+aInfoCBB[nI,1],"@E 9999,999.99",aTamQtd[1],aTamQtd[2],"",cUsado,"N","CBC","V"})	 //"Qtd.Cont:"
	If lQtdVari .or. CBQTDVAR(Left(cChave,Tamsx3("B1_COD")[1]))
		Aadd(aAltera,aHeader[Len(aHeader),2]) //Permite editar as colunas de quantidades
	EndIf
Next
Aadd(aHeader,{ ""	,"FAMTASMA","",0,0,"",cUsado,"","CBC","V"}) //Campo fantasma para impedir que a ultima coluna nao seja visualizada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tamanho total de colunas menos campo fantasma                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMaxCol := Len(aHeader)-1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com sub-arrays vazios                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CBC->(DbSetOrder(2))
For nI:=1 To Len(aInfoCBB)
	CBC->(DbSeek(xFilial("CBC")+aInfoCBB[nI,1]+cChave))
	While CBC->(!EOF().AND. CBC_FILIAL+CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+;
		CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER==xFilial("CBC")+aInfoCBB[nI,1]+cChave)
		//Quando for codigo interno e nao possuir codigo de etiqueta deve ser ignorado, pois esta contagem foi incluida
		//automaticamente na finalizacao da contagem. (nao havia sido encontrada)
		If lUsaCB001 .and. Empty(CBC->CBC_CODETI)
			CBC->(DbSkip())
			Loop
		EndIf

		nPos := AsCan(aProds,{|x| TRIM(x[1])+x[2]==TRIM(CBC->CBC_CODETI)+CBC->CBC_NUM})
		If Empty(nPos)
			Aadd(aProds,{CBC->CBC_CODETI,CBC->CBC_NUM,CBC->CBC_QUANT})
		Else
			aProds[nPos,3] += CBC->CBC_QUANT
		EndIf
		CBC->(DbSkip())
	EndDo
Next

aProds := aSort(aProds,,,{|x,y| x[1] < y[1] })
For nI:=1 To Len(aProds)
	If AsCan(aCols,{|x| x[3]==aProds[nI,1]})>0
		Loop
	EndIf
	AADD(aCols,Array(Len(aHeader)))
	aCols[Len(aCols)][1]  	:= StrZero(Len(aCols),3)
	aCols[Len(aCols)][2]	:= aCores[4]
	aCols[Len(aCols)][3]	:= aProds[nI,1]
Next

aProds := aSort(aProds,,,{|x,y| x[2] < y[2] })
For nX:=1 To Len(aProds)
	nPos 	:= Ascan(aCols,{|x| x[3]==aProds[nX,1]})
	nPos2	:= Ascan(aHeader,{|x| Right(x[1],6)==aProds[nX,2]})
	If Empty(nPos) .or. Empty(nPos2)
		Loop
	EndIf
	aCols[nPos][nPos2] := aProds[nX,3]
Next

//-- Modelo1 do Inventario (Efetuado por contagens batidas)
If lModelo1
	For nX:=1 To Len(aCols)
		aOkCont := {}
		For nI:=4 To nMaxCol
			//Nao considerar na eleicao etiquetas que nao foram lidas na contagem
			If aCols[nX,nI]==Nil
				Loop
			EndIf
			nPos := Ascan(aOkCont,{|x| x[1]==aCols[nX,nI]})
			If Empty(nPos)
				Aadd(aOkCont,{aCols[nX,nI],1})
			Else
				aOkCont[nPos,2]++
			EndIf
		Next

		//-- Alteracao da legenda
		For nI:=1 To Len(aOkCont)
			If lModelo1 .AND. aOkCont[nI,2]>=CBA->CBA_CONTS
				aCols[nX,2] := aCores[1]
				Exit
			EndIf
		Next
	Next

//-- Modelo2 do Inventario (Efetuado por Saldos em Estoque)
Else 
	For nX:=1 To Len(aCols)
		For nI:=4 To nMaxCol
			If aCols[nX,4]<>aCols[nX,nI]
				aCols[nX,2] := aCores[4]
				Exit
			EndIf
			aCols[nX,2] := aCores[1]
		Next
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se nao esta vazio                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols)
	IW_MSGBOX(STR0026,STR0021) //"Nao existem dados a serem visualizados!"###"Aviso"
	aHeader := aClone(aBkpaHead)
	AtivaTimer(.T.)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos Botoes                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CBA->CBA_STATUS $ "123"  // 1=Em Andamento / 2=Em Pausa / 3=Contado
	AADD(aButtons, {"FERRAM",{||ElegeEtiqD(@oBrwDifs)},STR0143}) //"Eleger Etiqueta Posicionada"
	AADD(aButtons, {"ESTOMOVI",{||UndoDifs(@oBrwDifs)},STR0144}) //"Desfazer"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela de Manutencao                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE DIALOG oDlgDifs TITLE STR0145+Left(cChave,TamSx3("B1_COD")[1]) FROM 0, 0 TO 22, 75 SIZE 650, 400 //"Comparacao de Contagens do Produto "
EnchoiceBar(oDlgDifs,{||nOpcao := 1,oDlgDifs:End()},{||oDlgDifs:End()},,aButtons)
oStatus 		:=	TPanel():New(000,000, ,oDlgDifs, , , , , ,oDlgDifs:nClientWidth, 15, .T.,.F. )
oStatus:align 	:= CONTROL_ALIGN_BOTTOM

//-- Pesquisar
TSay():New( 002, 004, {||STR0146},oStatus, , , , , ,.T., , , 50, 12) //"Pesquisar Etiqueta:"
@ 002,055 GET oSeek  VAR cSeek  SIZE 85, 9 OF oStatus PIXEL
TButton():New(002,140, STR0033, oStatus, {||LocEti(cSeek,@oBrwDifs)}, 14, 12, , , .F., .T., , , .T.) //"&Ok"

oBrwDifs := MSGetDados():New(0,0,1000,1000,1,,,"",.F.,aAltera,NIL,NIL,,,,,,oDlgDifs)
oBrwDifs:oBrowse:bLDbLClick	:= {|| ElegeEtiqD(@oBrwDifs) }
oBrwDifs:oBrowse:align		:= CONTROL_ALIGN_ALLCLIENT
oBrwDifs:Refresh()
ACTIVATE DIALOG oDlgDifs   CENTER

If (nOpcao == 1) .and. (CBA->CBA_STATUS $ "123") // 1=Em Andamento / 2=Em Pausa / 3=Contado
	GrvDifs()
EndIf

aHeader 	:= aClone(aBkpaHead)
aCols		:= {}
Atu(.F.)
AtivaTimer(.T.)
Return


Static Function GrvDifs()
Local nI,nJ
Local nIncCol	:= If(lModelo1,4,nMaxCol) //Coluna inicial - se for modelo 1 checa todas contagens caso contrario so o ultimo.
Local cEtiq		:= ""
Local cContagem	:= ""

If !MsgYesNo(STR0147) //"Deseja gravar os dados visualizados no diffs de contagem?"
	Return
EndIf
Begin Transaction
	CBC->(DbSetOrder(1))
	For nI:=1 To Len(aCols)
		If aCols[nI,2]<>aCores[3] //Nao foi alterado
			Loop
		EndIf
		cEtiq	:= aCols[nI,3]
		For nJ:=nIncCol To nMaxCol
			cContagem	:= Right(aHeader[nJ,1],6)

			//Caso o gestor tenha eleito uma qtd. vazia(seu conteudo igual a nil), sera considerado que nao
			//devera haver contagem para esta etiqueta sendo necessario deletar todos contagens desta etiqueta.
			//por isso deve se tomar muito cuidado com esta operacao.
			If aCols[nI,nJ]==NIL
				If CBC->(DbSeek(xFilial("CBC")+cContagem+cEtiq))
					RecLock("CBC",.F.)
					CBC->(DbDelete())
					CBC->(MsUnLock())
				EndIf
				Loop
			EndIf

			//Caso o valor eleito nao seja nil, sera executado as linhas abaixo.
			If CBC->(DbSeek(xFilial("CBC")+cContagem+cEtiq))
				RecLock("CBC",.F.)
			Else
				//Nao estou usando o cChave mais sim as variaveis private para alimentar o cadastro
				Reclock("CBC",.T.)
				CBC->CBC_FILIAL	:= xFilial("CBC")
				CBC->CBC_CODINV	:= CBA->CBA_CODINV
				CBC->CBC_NUM	:= cContagem
				CBC->CBC_COD	:= cProd
				CBC->CBC_LOCAL 	:= cArm
				CBC->CBC_LOTECT	:= cLote
				CBC->CBC_NUMLOT	:= cSLote
				CBC->CBC_LOCALI	:= cEnd
				CBC->CBC_NUMSER	:= cNumSeri
				CBC->CBC_CODETI	:= cEtiq
			EndIf
			CBC->CBC_QUANT 	:= If(Empty(aCols[nI,nJ]),0,aCols[nI,nJ])
			CBC->CBC_CONTOK	:= "1"
			CBC->(MsUnLock())
		Next
	Next
End Transaction
Return

Static Function ElegeEtiqD(oBrwDifs)
Local oDlg,oCbx,oGet
Local nI,nJ
Local nLin		:= oBrwDifs:oBrowse:nAt
Local nCol		:= oBrwDifs:oBrowse:nColPos+2
Local nIncCol	:= If(lModelo1,4,nMaxCol)
Local nQtd		:= 0
Local nQtdOld	:= 0
Local cConteudo
Local cContagem
Local cOpc		:= ""
Local cMsg		:= ""
Local lElege	:= .F.
Local lVazio	:= aCols[nLin,nCol]==NIL
Local aCbx		:= {STR0148,STR0149} //"1-Somente Contagem Selecionada"###"2-Toda Contagem"
Local aContTmp	:= Array(Len(aHeader)-3)

If (nCol > nMaxCol) .OR. !(CBA->CBA_STATUS $ "123")
	Return
EndIf
If nCol < 4
	IW_MSGBOX(STR0159,STR0021)	 //"Favor possicionar nas colunas de quantidades das contagens!"###"Aviso"
	Return
EndIf

nQtdOld	:= aCols[nLin,nCol]

If !lVazio
	nQtd	:= nQtdOld
EndIf

cContagem	:= Right(aHeader[nCol,1],6)
cOpc		:= aCbx[1]

DEFINE DIALOG oDlg TITLE STR0150 FROM 0, 0 TO 22, 75 SIZE 200, 110 //"Eleicao"
TSay():New( 002, 002, {||STR0151},oDlg, ,, , , ,.T., , , 70, 12) //"Informe a Quantidade:"
@ 010,002 GET oGet  VAR nQtd PICTURE "@E 9,999,999.99" WHEN (lQtdVari .AND. !lVazio) SIZE 50, 9 OF oDlg PIXEL

TSay():New( 022, 002, {||STR0152},oDlg, ,, , , ,.T., , , 70, 12) //"Escolha o tipo de eleicao:"
oCbx := TComboBox():New(030,002, bSETGET(cOpc),aCbx, 100, 70, oDlg, ,,,,,.T.,,,,,,,)
TButton():New(043,035, STR0153, oDlg, {|| lElege := .T.,oDlg:End()}, 30, 14, , , .F., .T., , , .T.) //"&Confirmar"
TButton():New(043,070, STR0120, oDlg, {||oDlg:End()}, 30, 14, , , .F., .T., , , .T.) //"&Sair"
ACTIVATE DIALOG oDlg   CENTER

If !lElege
	Return
EndIf

If lVazio
	cConteudo			:= "<vazio>"
Else
	cConteudo			:= Str(nQtd,12,2)
	aCols[nLin,nCol]	:= nQtd
EndIf

If Left(cOpc,1)=="2"
	If !MsgYesNo(STR0160+cContagem+STR0161) //"Deseja eleger o conteudo de toda contagem ""###"", para as demais contagens?"
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as variaveis no aCols                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nJ:=1 To Len(aCols)
		aContTmp := Array(Len(aHeader)-3)
		For nI:=nIncCol To nMaxCol
			If nJ==nLin .and. nI==nCol
				aContTmp[nI-3] := nQtdOld
			Else
				aContTmp[nI-3] := aCols[nJ,nI]
			EndIf
			aCols[nJ,nI] := aCols[nJ,nCol]
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava na pilha os arrays as alteracoes para serem retornadas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aUndo,{aCols[nJ,1],aCols[nJ,2],aContTmp})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza as status no aCols                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols[nJ,2] := aCores[3]
	Next
Else
	If !MsgYesNo(STR0162+cConteudo+STR0163+cContagem+STR0161) //"Deseja eleger o conteudo ""###"" da contagem ""###"", para as demais contagens?"
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as variaveis no aCols                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:=nIncCol To nMaxCol
		aContTmp[nI-3] := aCols[nLin,nI]
		aCols[nLin,nI] := If(cConteudo=="<vazio>",Nil,Val(cConteudo))
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava na pilha os arrays as alteracoes para serem retornadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aUndo,{aCols[nLin,1],aCols[nLin,2],aContTmp})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as status no aCols                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[nLin,2] := aCores[3]
EndIf
oBrwDifs:Refresh()
Return

Static Function UndoDifs(oBrwDifs)
Local cLin 	:= 0
Local nI	:= 0
Local nPos	:= 0
Local nLast	:= 0
Local aTmp	:= {}

If Empty(aUndo)
	Return
EndIf

nLast:= Len(aUndo)
cLin := aUndo[nLast,1]
aTmp := aClone(aUndo[nLast,3])
nPos := AsCan(aCols,{|x|x[1]==cLin})
If Empty(nPos)
	Return
EndIf

aCols[nPos,2] := aUndo[nLast,2]
For nI:=1 To Len(aTmp)
	aCols[nPos,3+nI] := aTmp[nI]
Next

aDel(aUndo,nLast)
aSize(aUndo,nLast-1)
oBrwDifs:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³LocEti()            ³Autor³Erike Yuri da Silva³29/09/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Pesquisa Etiqueta (CB0)                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cEtiqueta: Codigo da etiqueta a ser pesquisada    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³ Nenhum                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function LocEti(cEtiqueta,oBrw)
Local nPos
nPos := Ascan(aCols,{|x| Trim(x[3])==Trim(cEtiqueta)})
If nPos = 0
	MsgAlert(STR0154,STR0102) //"Etiqueta nao localizado!"###"ATENCAO"
	Return
EndIf
oBrw:oBrowse:nAt := nPos
oBrw:oBrowse:Refresh()
Return


Static Function ElegEti(cChave,aRetCBB)
Local cProduto,cArm,cEnd,cLote,cSLote,cNumSeri
Local cCodCBB 	:= CBB->CBB_NUM
Local cAux		:= ""
Local nSaldo    := 0
Local nPos      := 0
Local i         := 0
Local j         := 0
Local aProds  	:= {}
Local aProdAux	:= {}
Local aProdOK 	:= {}
Local aProdOK2	:= {}
Local aProdNoOk	:= {}
Local aEtiQtdOK	:= {}
Local aEtiLidas	:= {}
Local nTamLocal  	:= TamSX3("B2_LOCAL")[1]
Local nTamProd  	:= TamSX3("B1_COD")[1]
Local nTamLote   	:= TamSX3("B8_LOTECTL")[1]
Local nTamSLote  	:= TamSX3("B8_NUMLOTE")[1]
Local nTamEnd   	:= TamSX3("BF_LOCALIZ")[1]
Local nTamSeri  	:= TamSX3("BF_NUMSERI")[1]
Local nTamEtiq   	:= TamSX3("CBC_CODETI")[1]
Local lContBatida := .F.

Private aCods 	:= {}

For i:=1 To Len(aRetCBB)
	If aRetCBB[i,3] == "2"
		Aadd(aCods,aRetCBB[i,1])
	EndIf
Next

CBC->(dbSetOrder(2))
For i := 1 To Len(aCods)
	CBC->(dbSeek(xFilial("CBC")+aCods[i]+cChave))
	While CBC->(!Eof().and. CBC_FILIAL+CBC->CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER==xFilial("CBC")+aCods[i]+cChave)
		cAux := Space(nTamEtiq)
		If lUsaCB001 .and.  CBProdUnit(CBC->CBC_COD)
			cAux:= CBC->CBC_CODETI
		EndIf
		If lUsaCB001
			If Ascan(aEtiLidas,CBC->CBC_CODETI) == 0
				aadd(aEtiLidas,CBC->CBC_CODETI)
			EndIf
		EndIf
		nPos := Ascan(aProds,{|x| x[1] == CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux) .and. x[3]==CBC->CBC_NUM })
		If nPos > 0
			aProds[nPos,2] +=  CBC->CBC_QUANT
		Else
			Aadd(aProds,{CBC->( CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+cAux),CBC->CBC_QUANT,CBC->CBC_NUM})
		Endif
		CBC->(dbSkip())
	EndDo
Next i
For i := 1 to len(aProds)
	For j:= 1 to len(aCods)
		CBC->(dbSetOrder(2))
		If ! CBC->(DBSeek(xFilial("CBC")+aCods[j]+aProds[i,1]))
			If Ascan(aProds,{|x| x[1] == aProds[i,1] .and. x[2] ==0 .and. x[3] == aCods[j]  }) == 0
				Aadd(aProds,{aProds[i,1],0,aCods[j]})
			EndIF
		EndIf
	Next
Next
For i := 1 to len(aProds)
	nPos := Ascan(aProdAux,{|x| Padr(x[1],nTamLocal+nTamProd+nTamLote+nTamSLote+nTamEnd+nTamSeri+nTamEtiq) == ;
									Padr(aProds[i,1],nTamLocal+nTamProd+nTamLote+nTamSLote+nTamEnd+nTamSeri+nTamEtiq) ;
									.And. StrZero(x[2],12,4) == StrZero(aProds[i,2],12,4) })
	If nPos==0
		Aadd(aProdAux,{aProds[i,1],aProds[i,2],1})
	Else
		aProdAux[nPos,3]++
	EndIF
Next
For i := 1 to len(aProdAux)
	If aProdAux[i,3] >= CBA->CBA_CONTS
		lContBatida := .T.
		nPos := Ascan(aProdOK,{|x| x[1] == aProdAux[i,1]})
		If nPos== 0
			aadd(aProdOk,{aProdAux[i,1],aProdAux[i,2]})
			If Subs(aProdAux[i,1],nTamLocal+nTamProd+nTamLote+nTamSLote+nTamEnd+nTamSeri+1,nTamEtiq) <> Space(nTamEtiq)
				aadd(aEtiQtdOK,{Subs(aProdAux[i,1],nTamLocal+nTamProd+nTamLote+nTamSLote+nTamEnd+nTamSeri+1,10),aProdAux[i,2]})
			EndIf
		EndIf
	Else
		nPos := Ascan(aProdNoOK,{|x| x[1] == aProdAux[i,1]})
		If nPos == 0
			aadd(aProdNoOK,{aProdAux[i,1]})
		EndIf
	EndIf
Next
nSaldo := 0
For i := 1 to len(aProdOk)
	nPos := Ascan(aProdNoOK,{|x| x[1] == aProdOK[i,1]})
	If nPos == 0 .And. lModelo1 .And.  lContBatida .And. lUsaCB001
		nPos := Ascan(aProdNoOK,{|x| x[1] == Subs(aProdOK[i,1],1,nTamLocal+nTamProd+nTamLote+nTamSLote+nTamEnd+nTamSeri)+Space(nTamEtiq)})
	EndIf
	If nPos > 0
		aDel(aProdNoOk,nPos)
		aSize(aPRodNoOk,Len(aProdNoOK)-1)
	EndIf
	nSaldo += aProdOk[i,2]
Next

Return {nSaldo,IIF(!lContBatida,(len(aProdNoOK)==0),lContBatida)}

