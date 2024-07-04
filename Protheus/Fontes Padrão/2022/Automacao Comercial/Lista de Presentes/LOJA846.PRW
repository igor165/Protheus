#INCLUDE "LOJA846.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE TOTCREDBLQ	1	//credito bloqueado
#DEFINE TOTCREDLIB	2	//credito liberado
#DEFINE TOTCREDUSD	3	//total credito usado
#DEFINE TOTCREDGER	4	//total credito gerado
#DEFINE TOTDEBITO	5	//total dos debitos
#DEFINE TOTSALDO	6	//saldo

#DEFINE CODLISTA	1	//Obrigatorio
#DEFINE ITLISTA		2	//Opcional
#DEFINE CODPROD		3	//Opcional
#DEFINE QUANT		4	//Opcional
#DEFINE VALOR		5	//Obrigatorio
#DEFINE EMPORI		6	//Obrigatorio
#DEFINE FILORI		7	//Obrigatorio
#DEFINE ORCAMENTO	8 	//Opcional
#DEFINE ITORC		9 	//Opcional
#DEFINE PEDIDO		10	//Opcional
#DEFINE ITPEDIDO	11	//Opcional
#DEFINE DOCUMENTO	12	//Opcional
#DEFINE SERIE		13	//Opcional
#DEFINE EMISSAO		14	//Obrigatorio
#DEFINE PREFIXO		15	//Opcional
#DEFINE TITULO		16	//Opcional
#DEFINE PARCELA		17	//Opcional
#DEFINE TIPOTIT		18	//Opcional
#DEFINE CODCLI		19	//Obrigatorio
#DEFINE LOJACLI		20	//Obrigatorio

#DEFINE CRDEBO		1	//Credito, Debito e Bonus
#DEFINE CREDITO		2	//Somente Credito e Bonus
#DEFINE DEBITO		3	//Somente Debito
#DEFINE	NCC			4	//Somente NCC
#DEFINE	SO_CREDITO	5	//Somente Credito 
#DEFINE DEB_BONUS   6   //Debito do Bonus - estorno NF Saída
#DEFINE CRED_DEB	7   //Credito e Debito
#DEFINE CR_USA_DEB	8	//Credito Usado, Debito e Bonus

#DEFINE QTDELEMDD	20	//Quantidade de elementos do Array aDados na funcao Lj8GeraCC (Rotina que gera os registros da conta corrente) 

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Loja846	 ³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Conta Corrente da Lista de Presentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodLista - Codigo da Lista								  ³±±
±±³			 ³ cItLista  - Item da Lista								  ³±±
±±³			 ³ lEncerra  - Determina se é para encerrar a Lista ou nao	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA846(cCodLista,cItLista,lEncerra)

Local aTotais	:= {0,0,0,0,0,0}								// Variavel usada para guardar os valores totais da Conta Corrente
Local aFuncoes	:= {}											// Array para criacao de botoes na EnchoiceBar
Local aCpoEnc	:= {}											// Array contendo os campos da Enchoice
Local oEncCC													// Objeto da Enchoice
Local oDlg														// Objeto principal
Local aItensCC := {}											// Array contendo os itens a serem apresentados da conta corrente
Local aItensLib:= {}											// Array contendo os itens liberados que estao disponiveis para geracao de credito ao organizador
Local aColItens:= {}											// Array contendo o nome dos campos que serao mostrados em tela
Local oItensCC													// Objeto do ListBox
Local oCredBlq													// Objeto do Credito Bloqueado
Local oCredLib													// Objeto do Credito Liberado
Local oCredUsd													// Objeto do Credito Usado
Local oCredGer													// Objeto do Credito Geral
Local oDebito													// Objeto de Debito
Local oSaldo													// Objeto do Saldo
Local oFld														// Objeto do Folder
Local aSize1 	:= MsAdvSize()									// Tamanho da tela
Local aLegenda	:= {}											// Codido de legendas //"Debito"###"Credito"
Local aAuxCombo	:= RetSx3Box( Posicione("SX3", 2, PadR("ME4_TIPREG",10), "X3CBox()" ),,, 1 )	//Array contendo os status da consulta de conta corrente
Local aCores	:= {}											// Array que determina as cores que serao apresentadas no TcBrowse
																// Botao da selecao de itens para gerar o credito ao organizador
Local bBtnSelIt	:= {|| IIF(Lj8SelItens(aItensLib,aColItens,cCodLista,aTotais),;         ////////Veronica - TI4501 - 20.06.11-> Incluiu aTotais para o ponto de entrada para chamada Impressao de NCC do saldo Disponivel para Listas Antigas
						Lj8AtuItens(@aItensCC,@aColItens,@aTotais,@aItensLib,;
									@oItensCC,@oDlg,aLegenda,aCores),.T.) }
Local bBtnCanc	:= {|| IIF(Lj8CanCred(aItensCC,oItensCC,aColItens),;
						   Lj8AtuItens( @aItensCC,@aColItens,@aTotais,@aItensLib,;
						   				@oItensCC,@oDlg,aLegenda,aCores),.T.)}

Default cCodLista	:= ""			//Codigo da Lista
Default cItLista	:= ""			//Item da Lista
Default lEncerra	:= .F.			//Determina se é encerramento da lista de presentes ou nao (.T. = Encerra e .F. = Mostra a Tela normalmente)

//Incrementa o array de Legenda com os status disponiveis
aAdd(aLegenda,{"ENABLE"		,aAuxCombo[1][3]})	//Credito Liberado
aAdd(aLegenda,{"DISABLE"	,aAuxCombo[2][3]})	//Debito
aAdd(aLegenda,{"BR_AMARELO"	,aAuxCombo[3][3]})	//Credito Bloqueado
aAdd(aLegenda,{"BR_AZUL"	,aAuxCombo[4][3]})	//Credito Usado 
aAdd(aLegenda,{"BR_MARROM"	,aAuxCombo[6][3]})	//Devolucao 

//Adiciono as regras de cores no array a Cores
aAdd(aCores,{{"ME4_TIPREG",'ME4_TIPREG == "' + Alltrim(aAuxCombo[1,3]) + '"'},aLegenda[1][1]})
aAdd(aCores,{{"ME4_TIPREG",'ME4_TIPREG == "' + Alltrim(aAuxCombo[2,3]) + '"'},aLegenda[2][1]})
aAdd(aCores,{{"ME4_TIPREG",'ME4_TIPREG == "' + Alltrim(aAuxCombo[3,3]) + '"'},aLegenda[3][1]})
aAdd(aCores,{{"ME4_TIPREG",'ME4_TIPREG == "' + Alltrim(aAuxCombo[4,3]) + '"'},aLegenda[4][1]})
aAdd(aCores,{{"ME4_TIPREG",'ME4_TIPREG == "' + Alltrim(aAuxCombo[6,3]) + '"'},aLegenda[5][1]})

//Caso nao venha por parametro de entrada, apresenta tela de pesquisa por Lista de Presentes.
If lEncerra .AND. Empty(cCodLista)
	MsgInfo(STR0052)   /// "Codigo de lista em branco"
	Return .F.
ElseIf Empty(cCodLista)
	cCodLista := Lj8BscLista()
EndIf

//Verifica se a Lista de Presentes existe
DbSelectArea("ME1")
DbSetOrder(2)	//ME1_FILIAL+ME1_CODIGO+ME1_TIPO+ME1_CODCLI+ME1_LOJCLI 
If !ME1->( DbSeek( xFilial("ME1") + cCodLista ) )
	MsgInfo(STR0001) //"Codigo de Lista nao encontrado"
	Return .F.
EndIf

//Caso seja encerramento chamo somente as rotinas para criar o credito final
If lEncerra
	If ME1->ME1_STATUS == "2"
		MsgInfo(STR0053)     // "Lista de Presentes ja encerrada"
		Return .F.
	ElseIf Aviso(STR0054,STR0055,{STR0056,STR0057},2) == 1    /// "Encerramento da Lista de Presentes" // "Confirma o Encerramento da Lista de Presentes?"  // Sim // "Nao"
	
		//Rotina para selecionar todos os itens e valores para gerar o valor do credito
		Lj8AtuItens(@aItensCC,@aColItens,@aTotais,@aItensLib,@oItensCC,@oDlg,aLegenda,aCores,lEncerra)
		
		//Rotina para Gerar o Credito
		If Len(aItensLib) == 0 .OR. aTotais[TOTSALDO] == 0
			MsgInfo(STR0058)    /// "Nao existem mais dados para gerar credito."
			Return .T.
		ElseIf !Lj8GerCred(aItensLib,aTotais[TOTSALDO],cCodLista,.F.,lEncerra)
			MsgInfo(STR0059)    /// "Nao foi possivel gerar o credito de encerramento da lista de presentes"
			Return .F.		
		EndIf
	Else
		MsgInfo(STR0060)  // "Encerramento da Lista de Presentes cancelada"
		Return .F.		
	EndIf
Else

	//Funcao que busca as informacoes que serao apresentadas na tela
	Lj8AtuItens(@aItensCC,@aColItens,@aTotais,@aItensLib,;
				@oItensCC,@oDlg,aLegenda,aCores)
	
	//Verifica se existem registros a serem apresentados na consulta
	If Len(aItensCC) == 0 
		MsgInfo(STR0002 + ME1->ME1_CODIGO) //"Nao existem registros para o codigo de lista "
		Return	
	EndIf
	
	//Verifica se existem colunas para serem apresentadas
	If Len(aColItens) == 0
		MsgInfo(STR0003) //"Nao existe nenhuma coluna com o status USADO na tabela ME4"
		Return
	EndIf
	
	//Inclusao dos botoes da EnchoiceBar
	aAdd(aFuncoes,{"DBG07"		,{|| BrwLegenda(STR0004,STR0005,aLegenda)}	,STR0005}) //"Legendas dos tipos de registros"###"Legenda"###"Legenda"
	aAdd(aFuncoes,{"EXCLUIR"	,bBtnCanc									,STR0006}) //"Canc. Credito"
	aAdd(aFuncoes,{"SIMULACA"	,bBtnSelIt									,STR0007}) //"Sel. Itens Lib."
	
	DEFINE MSDIALOG oDlg TITLE STR0008 FROM aSize1[7],0 TO aSize1[6],aSize1[5] PIXEL //"Consulta Conta Corrente"
	
		RegToMemory("ME1", .F., .F.)
		
		DbSelectArea( "SX3" )
		DbSetOrder( 1 )	// X3_ARQUIVO+X3_ORDEM
		DbSeek("ME1")
		While !Eof() .AND. SX3->X3_ARQUIVO == "ME1"
			If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
				aAdd( aCpoEnc, SX3->X3_CAMPO )
			EndIf
			
			SX3->( DbSkip() )
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe a enchoice com os campos do ME1.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oEncCC   := MsMGet()	:New("ME1", ME1->( Recno() ), 2, , , , aCpoEnc, {C(010),C(005),C(056),C(372)}, , 3, , , , , , .T. )
		oEncCC:oBox:Align	:= CONTROL_ALIGN_TOP
	
		//Rodape dos Totalizadores
		oFld	:= TFolder():New(C(50),C(002),{STR0009},{},oDlg,,,,.T.,.F.,C(050),C(050),) //"Totalizadores"
		oFld:Align := CONTROL_ALIGN_BOTTOM
	
		@ C(002),C(008) Say STR0010 Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oFld:aDialogs[1] //"Total de Creditos Bloqueados"
		@ C(001),C(083) MsGet oCredBlq Var aTotais[TOTCREDBLQ] Size C(041),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" When .F. PIXEL OF oFld:aDialogs[1]
	
		@ C(002),C(209) Say STR0011 Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oFld:aDialogs[1] //"Total de Creditos Liberados"
		@ C(001),C(279) MsGet oCredLib Var aTotais[TOTCREDLIB] Size C(041),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" When .F. PIXEL OF oFld:aDialogs[1]
	
		@ C(012),C(008) Say STR0012 Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oFld:aDialogs[1] //"Total de Creditos Usados"
		@ C(011),C(083) MsGet oCredUsd Var aTotais[TOTCREDUSD] Size C(041),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" When .F. PIXEL OF oFld:aDialogs[1]
	
		@ C(012),C(209) Say STR0013 Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oFld:aDialogs[1] //"Total de Creditos Geral"
		@ C(011),C(279) MsGet oCredGer Var aTotais[TOTCREDGER] Size C(041),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" When .F. PIXEL OF oFld:aDialogs[1]
	
		@ C(022),C(008) Say STR0014 Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oFld:aDialogs[1] //"Total de Debitos"
		@ C(021),C(083) MsGet oDebito Var aTotais[TOTDEBITO] Size C(041),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" When .F. PIXEL OF oFld:aDialogs[1]
	
		@ C(022),C(209) Say STR0015 Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oFld:aDialogs[1] //"Saldo de Creditos Disponiveis"
		@ C(021),C(279) MsGet oSaldo Var aTotais[TOTSALDO] Size C(041),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" When .F. PIXEL OF oFld:aDialogs[1]
	
		//Chama a rotina componentizada que monta o objeto do TcBrowse		 
		LjMntBrw(	@oDlg,;						//01 - Objeto Janela
					@aItensCC,;					//02 - Alias ou Array de Dados
					{0,0,0,0},;					//03 - Array contendo as coordenadas
					@oItensCC,;					//04 - Objeto que sera criado
					.T.,;						//05 - Utilizar dicionario para compor colunas
					aColItens,;					//06 - Lista de campos desejados
					NIL,;						//07 - Expressao para Legenda Automatica
					aLegenda,;					//08 - Codigo de cores para legenda automatica
					NIL,;						//09 - Expressao para posicionamento no inicio
					NIL,;						//10 - Expressao para posicionamento no final
					{|| NIL},;					//11 - Expressao ao clicar em um item da lista
					NIL,;						//12 - Coluna que ficara congelada na exibicao
					NIL,;						//13 - Classificacao por cabecalho (header)
					aCores,;					//14 - Array de Legenda
					.F.,;						//15 - Formatar dados com a picture informada (origem array)
					.F.)						//16 - A ordem dos campos deve respeitar o SX3 (origem alias)
	
	    oItensCC:Align		:= CONTROL_ALIGN_ALLCLIENT
		oItensCC:bLDblClick	:= {|| Lj8Observacao(aItensCC,oItensCC,aColItens) }
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End() },{|| oDlg:End() },,aFuncoes)
EndIf

Return(.T.)





/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8BscLista³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Conta Corrente da Lista de Presentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ cCodLista - Codigo da Lista de Presentes selecionada		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj8BscLista()

Local aFiltros	:= {}	//Array com as perguntas que serao apresentadas
Local aResult	:= {}	//Array com o conteudo selecionado pelo usuario
Local cCodLista	:= ""	//Variavel para guardar o codigo da lista selecionada 

Aadd(aFiltros,{1, STR0016  	 ,Space(6),"","","ME1","",60,.F.}) //"Codigo Lista"

If ParamBox(aFiltros,STR0017,@aResult) //"Parametros da Rotina"
	cCodLista	:= aResult[1]
EndIf

Return cCodLista




/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8AtuItens³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Conta Corrente da Lista de Presentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aItensCC	- Itens da Consulta de Conta Corrente			  ³±±
±±³			 ³aColItens - Colunas que serao apresentadas na consulta	  ³±±
±±³			 ³aTotais   - Contem os totalizadores da conta corrente	  	  ³±±
±±³			 ³aItensLib - Itens liberados para geracao de credito		  ³±±
±±³			 ³oItensCC  - objeto dos itens da Conta Corrente			  ³±±
±±³			 ³oDlg      - objeto do Dialog								  ³±±
±±³			 ³aLegenda  - Array com legenda que informa o status do reg.  ³±±
±±³			 ³aCores    - Array com as cores da Legenda					  ³±±
±±³			 ³lEncerra  - Determina se é para encerrar a Lista ou nao	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj8AtuItens(aItensCC 	,aColItens	,aTotais ,aItensLib ,;
							oItensCC 	,oDlg 		,aLegenda,aCores	,;
							lEncerra	)

Local aArea		:= GetArea()					//Variavel de gravacao da Area para posterior restauracao
Local aAreaSX3	:= SX3->( GetArea() )			//Variavel de gravacao da Area para posterior restauracao
Local aAreaME4	:= ME4->( GetArea() )			//Variavel de gravacao da Area para posterior restauracao
Local nCols		:= 0							//Variavel para laco 
Local nQtdDVlBlq:= SuperGetMV("MV_LJLPDBL",,7)	//Busca no parametro a quantidade de dias que um item fica bloqueado para geracao de credito
Local nQtdColIt	:= 0							//Variavel que guarda a quantidade de Colunas que serao usadas na tela
Local aAuxCombo	:= {}							//Array auxiliar para montagem do combo

Default aItensCC	:= {}						//Itens Conta Corrente
Default aColItens 	:= {}						//Coluna dos Itens
Default aTotais		:= {}						//totais
Default aItensLib	:= {}						//Itens liberados
Default oItensCC	:= NIL						//objeto dos itens da Conta Corrente
Default oDlg 		:= NIL						//objeto do dialog
Default aLegenda	:= {}						//array da legenda
Default aCores		:= {}						//array das cores da legenda
Default lEncerra	:= .F.						//Determina se é para encerrar a Lista ou nao

//Verifico se o array esta em branco para incluir as informacoes
If Len(aColItens) == 0
	DbSelectArea( "SX3" )
	DbSetOrder( 1 )	// X3_ARQUIVO+X3_ORDEM
	DbSeek("ME4")
					
	While !Eof() .AND. SX3->X3_ARQUIVO == "ME4"
		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_TIPO <> "M"
			aAdd( aColItens	,{	SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								AllTrim(X3Titulo()),;
								SX3->X3_TAMANHO,;
								SX3->X3_TIPO})
		EndIf

		SX3->( DbSkip() )
	End
EndIf

nQtdColIt := Len(aColItens)

//Posiciono na tabela de Conta Corrente para buscar as informacoes da Lista de Presentes
DbSelectArea("ME4")
DbSetOrder(3)	//ME4_FILIAL+ME4_CODIGO+ME4_SEQ+ME4_ITLST

If ME4->( DbSeek( xFilial("ME4") + ME1->ME1_CODIGO ) )
	//Zero as variaveis de registros e totais
	aItensCC	:= {}
	aTotais		:= {0,0,0,0,0,0}
	aItensLib	:= {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Elementos do array aTotais              ³
	//³aTotais[1] -> Total de Credito Bloqueado³
	//³aTotais[2] -> Total de Credito Liberado ³
	//³aTotais[3] -> Total de Credito Usado    ³
	//³aTotais[4] -> Total de Credito Geral    ³
	//³aTotais[5] -> Total de Debito           ³
	//³aTotais[6] -> Saldo Disponivel          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	While !ME4->( Eof() ) .AND. xFilial("ME4") + ME1->ME1_CODIGO == ME4->ME4_FILIAL + ME4->ME4_CODIGO
		aAdd(aItensCC,Array(nQtdColIt) )

		For nCols := 1 to nQtdColIt
			If nCols == 1
				aItensCC[Len(aItensCC)][nCols]	:= ME4->&(aColItens[nCols][1])
			ElseIf Alltrim(aColItens[nCols][1]) == "ME4_TIPO"
				aItensCC[Len(aItensCC)][nCols]	:= Alltrim(Tabela("ZI",ME4->&(aColItens[nCols][1]),.F.))
			ElseIf Alltrim(aColItens[nCols][1]) == "ME4_TIPREG"
				//Busca o conteudo do box num array
				aAuxCombo	:= RetSx3Box( Posicione("SX3", 2, PadR(aColItens[nCols][1],10), "X3CBox()" ),,, 1 )
				
				//Atualiza o item com a descricao do combo
				aItensCC[Len(aItensCC)][nCols]	:= Alltrim(aAuxCombo[Val(ME4->&(aColItens[nCols][1])),3])
			Else
				aItensCC[Len(aItensCC)][nCols]	:= ME4->&(aColItens[nCols][1])
			EndIf
		Next nCols
		
		//Atualizo o totalizador de Debito
		If ME4->ME4_TIPREG == "2"		//Debito
			aTotais[TOTDEBITO]	+=  ME4->ME4_VALOR
		ElseIf ME4->ME4_TIPREG == "4"		//Credito Usado
			aTotais[TOTCREDUSD] +=  ME4->ME4_VALOR
		Else
			//Atualizo os totalizadores de Credito Bloqueado e Credito Liberado	
			If (ME4->ME4_EMISSA + nQtdDVlBlq) > dDataBase .AND. !lEncerra
				aTotais[TOTCREDBLQ] +=  ME4->ME4_VALOR      
				//Caso tenha sido alterado o parametro de bloqueio e o status esteja liberado, muda o status
				If ME4->ME4_TIPREG == "1"		//Credito Liberado
					RecLock("ME4",.F.)
					ME4->ME4_TIPREG := "3"
					ME4->( MsUnLock() )
				EndIf

			Else
				//Caso o status esteja como credito bloqueado, mas ja tenha vencido o periodo, altera o status para "1" (Credito Liberado)
				If ME4->ME4_TIPREG == "3"		//Credito Bloqueado
					RecLock("ME4",.F.)
					ME4->ME4_TIPREG := "1"
					ME4->( MsUnLock() )
				EndIf
				
				aTotais[TOTCREDLIB] +=  ME4->ME4_VALOR
				
				//Incluo os registros no array de itens liberados para geracao de credito ao organizador
				aAdd(aItensLib, Array( nQtdColIt + 2 ) )
				For nCols := 1 to nQtdColIt
					If Alltrim(aColItens[nCols][1]) == "ME4_TIPO"
						aItensLib[Len(aItensLib)][nCols + 1] := Alltrim(Tabela("ZI",ME4->&(aColItens[nCols][1]),.F.))
					ElseIf Alltrim(aColItens[nCols][1]) == "ME4_TIPREG"
						//Busca o conteudo do box num array
						aAuxCombo	:= RetSx3Box( Posicione("SX3", 2, PadR(aColItens[nCols][1],10), "X3CBox()" ),,, 1 )
						
						//Atualiza o item com a descricao do combo
						aItensLib[Len(aItensLib)][nCols + 1] := Alltrim(aAuxCombo[Val(ME4->&(aColItens[nCols][1])),3])
					Else
						aItensLib[Len(aItensLib)][nCols + 1] := ME4->&(aColItens[nCols][1])
					EndIf
				Next nCols
				
				aItensLib[Len(aItensLib)][1] 			:= lEncerra				//Coluna usada para marcar/desmarcar no listbox
				aItensLib[Len(aItensLib)][nQtdColIt + 2]:= ME4->( Recno() )		//Coluna que guarda o RECNO do Registro para facilitar a pesquisa
			EndIf
		EndIf
		
		ME4->( DbSkip() )
	End

	//Atualizo os totalizadores gerais e saldo
	aTotais[TOTCREDGER]	:= aTotais[TOTCREDBLQ] + aTotais[TOTCREDLIB] + aTotais[TOTCREDUSD]
	aTotais[TOTSALDO]	:= aTotais[TOTCREDGER] - aTotais[TOTDEBITO] - aTotais[TOTCREDBLQ]
	
	If oItensCC <> NIL
		//Chama a rotina componentizada que monta o objeto do TcBrowse
		LjMntBrw(	@oDlg,;						//01 - Objeto Janela
					@aItensCC,;					//02 - Alias ou Array de Dados
					{0,0,0,0},;					//03 - Array contendo as coordenadas
					@oItensCC,;					//04 - Objeto que sera criado
					.T.,;						//05 - Utilizar dicionario para compor colunas
					aColItens,;					//06 - Lista de campos desejados
					NIL,;						//07 - Expressao para Legenda Automatica
					aLegenda,;					//08 - Codigo de cores para legenda automatica
					NIL,;						//09 - Expressao para posicionamento no inicio
					NIL,;						//10 - Expressao para posicionamento no final
					{|| NIL},;					//11 - Expressao ao clicar em um item da lista
					NIL,;						//12 - Coluna que ficara congelada na exibicao
					NIL,;						//13 - Classificacao por cabecalho (header)
					aCores,;					//14 - Array de Legenda
					.F.,;						//15 - Formatar dados com a picture informada (origem array)
					.F.)						//16 - A ordem dos campos deve respeitar o SX3 (origem alias)
					
		oItensCC:Refresh()
	EndIf
EndIf

//Restaura as areas gravadas anteriormente
RestArea(aArea)
RestArea(aAreaSX3)
RestArea(aAreaME4)

Return





/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8SelItens³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Conta Corrente da Lista de Presentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aItensLib - Itens Liberados para gerar Credito			  ³±±
±±³			 ³ aColItens - Cabecalho das colunas a serem apresentadas	  ³±±
±±³			 ³ cCodLista - Codigo da Lista que esta sendo analisada		  ³±±  
±±³			 ³ aTotais   - Array dos totais da Conta Corrente			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±  
±±³Retorno   ³lRet[L]  : Retorno logico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj8SelItens(aItensLib,aColItens,cCodLista,aTotais)

Local oTotSel											// Objeto do GET oTotSel
Local nTotSel 	:= 0									// Variavel que mostra ao usuario o total selecionado
Local oPanel											// Objeto do Painel
Local oSay												// Objeto do Say
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")	//Objeto da coluna de selecao - Opcao -> Selecionado
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")	//Objeto da coluna de selecao - Opcao -> Nao Selecionado
Local oItensSel									   		//Objeto do ListBox
Local oDlg												//Objeto da janela principal
Local aColName	:= {}									//Array com o nome da Coluna
Local nSeqCol	:= 0									//Sequencia do laco
Local cLine		:= ""									//Monta a linha do bLine
Local nQtdColIt	:= 0									//Quantidade de Registros no array de colunas
Local nPVlrItem	:= 0									//Posicao do campo de Valor do 
Local aFuncoes	:= {}									//Array contendo os botoes que serao apresentados na EnchoiceBar
Local lRet		:= .F.									//Variavel logica que determina se foi criado o titulo de NCC
Local nItemLib	:= 0									//variavel de laço

Default aItensLib	:= {}								//itens liberados
Default aColItens	:= {}								//colunas dos itens
Default cCodLista	:= "" 								//codigo da lista
Default aTotais		:= {}								//array com totais da conta corrente

 
If Len(aItensLib) == 0       
	If ExistBlock("LJ846DIS") //ponto de entrada para chamada Impressao de NCC do saldo Disponivel para Listas Antigas
		If !LJProfile(27,NIL,NIL,NIL,NIL,.T.,NIL)	//Valida se o usuario pode Gerar a NCC de saldo disponivel
			Return .F.
		EndIf
	    If (ME1->ME1_DTEVEN<=CtoD("11/04/30") .AND. ME1->ME1_DTEVEN>=CtoD("10/01/01")) .and. aTotais[TOTSALDO] > 0.00      ////Val(cCodLista) < 700000 .and.
			If !ExecBlock("LJ846DIS",.F.,.F.,{cCodLista,aTotais[TOTSALDO]})
			   Alert(STR0061)                     //"NCC nao pode ser gerada!"
			Endif
			Return .T.
		EndIf
	EndIf
	MsgInfo(STR0018) //"Lista de Presentes nao possui itens liberados para gerar credito"
	Return .F.
Else
	For nItemLib := 1 to Len(aItensLib)
		aItensLib[nItemLib][1] := .F.
	Next nItemLib
EndIf

nQtdColIt := Len(aColItens)

//Monto o novo array com as colunas novas e o bLine
aAdd(aColName,"Sel")

cLine := "{|| {"
cLine += "If(aItensLib[oItensSel:nAT,1],oOk,oNo),"

For nSeqCol := 1 to nQtdColIt
	aAdd(aColName,aColItens[nSeqCol][3])
	
	cLine += "aItensLib[oItensSel:nAt," + AllTrim(Str(nSeqCol+1)) + "]" + IIf(nSeqCol < nQtdColIt,",","") 	
	
	If Alltrim(aColItens[nSeqCol][1]) == "ME4_VALOR"
		nPVlrItem := nSeqCol + 1
	EndIf
Next nSeqCol

cLine += "}}"

//Inclusao dos botoes da EnchoiceBar
aAdd(aFuncoes,{"USER", {|| IIF(lRet := Lj8GerCred(aItensLib,nTotSel,cCodLista),oDlg:End(),.T.) }, STR0019 }) //"Gera Credito"

DEFINE MSDIALOG oDlg TITLE STR0020 FROM 000, 000  TO 500, 700 PIXEL //"Selecione os Registros para Gerar o Credito"

	@ 226, 001 MSPANEL oPanel SIZE 345, 021 OF oDlg RAISED
	oPanel:ALIGN := CONTROL_ALIGN_BOTTOM
	
	@ 007, 004 SAY oSay PROMPT STR0021 SIZE 047, 010 OF oPanel PIXEL //"Total Selecionado"
	@ 006, 050 MSGET oTotSel VAR nTotSel SIZE 101, 010 Picture "@E 999,999,999.99" When .F.OF oPanel PIXEL
	
	oItensSel := TWBrowse():New(0,0,0,0,,aColName,,oDlg,,,,,,,,,,,,.F.,,.F.,,.F.,,,)
	oItensSel:SetArray(aItensLib)
	oItensSel:bLine := &cLine 
	oItensSel:Align	:= CONTROL_ALIGN_ALLCLIENT

	oItensSel:bHeaderClick	:= {|oObj, nCol| Lj8SelItCrd(2,@aItensLib,@oItensSel,@nTotSel,oTotSel,nPVlrItem,nCol) }
	oItensSel:bLDblClick	:= {|| Lj8SelItCrd(1,@aItensLib,@oItensSel,@nTotSel,oTotSel,nPVlrItem) }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End() },{|| oDlg:End() },,aFuncoes)

Return lRet




/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8SelItCrd³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Conta Corrente da Lista de Presentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc      - Mostra de onde foi chamada a rotina, sendo	  ³±±
±±³			 ³ 			 1 - Selecao diretamente no item do listBox		  ³±±
±±³			 ³ 			 2 - Selecao no cabecalho do ListBox		      ³±±
±±³			 ³ aItensLib - Itens Liberados para gerar Credito			  ³±±
±±³			 ³ oItensSel - Objeto dosItens Liberados para gerar Credito	  ³±±
±±³			 ³ nTotSel   - Variavel totalizadora dos itens selecionados	  ³±±
±±³			 ³ oTotSel   - Objeto da variavel totalizadora				  ³±±
±±³			 ³ nPVlrItem - Posicao do campo de valor no Array aItensLib	  ³±±
±±³			 ³ nCol      - Numero da coluna clicada pelo usuario		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj8SelItCrd(nOpc   ,aItensLib,oItensSel,nTotSel,;
							oTotSel,nPVlrItem,nCol)

Local nSeqItLib	:= 0				//Variavel usada para gerar sequencia dos itens liberados
Local nQtdItLib	:= Len(aItensLib)	//Variavel que guarda a quantidade total de itens liberados

Default nOpc		:= 0 				//Mostra de onde foi chamada a rotina
Default nTotSel		:= 0				//Objeto da variavel totalizadora
Default nPVlrItem	:= 0				//Posicao do campo de valor no Array aItensLib
Default nCol		:= 0				//Numero da coluna clicada pelo usuario
Default aItensLib	:= {}				//Itens Liberados para gerar Credito
Default oItensSel	:= NIL				//Variavel totalizadora dos itens selecionados
Default oTotSel		:= NIL				//Objeto da variavel totalizadora


If nOpc == 1
	aItensLib[oItensSel:nAt,1] := !aItensLib[oItensSel:nAt,1]
	
	If aItensLib[oItensSel:nAt,1]
		nTotSel += aItensLib[oItensSel:nAt,nPVlrItem]
	Else
		nTotSel -= aItensLib[oItensSel:nAt,nPVlrItem]
	EndIf
	oTotSel:Refresh()
	oItensSel:DrawSelect()
Else
	If nCol == 1
		For nSeqItLib := 1 to nQtdItLib
			aItensLib[nSeqItLib,1] := !aItensLib[nSeqItLib,1]

			If aItensLib[nSeqItLib,1]
				nTotSel += aItensLib[nSeqItLib,nPVlrItem]
			Else
				nTotSel -= aItensLib[nSeqItLib,nPVlrItem]
			EndIf
		Next nSeqItLib
		oTotSel:Refresh()
		oItensSel:DrawSelect()
		oItensSel:Refresh()
	Else
		aItensLib := aSort(aItensLib,,,{|x,y| x[nCol]<y[nCol]})
		oItensSel:DrawSelect()
		oItensSel:Refresh()
	EndIf
EndIf

Return





/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8GerCred ³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Conta Corrente da Lista de Presentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aItensLib - Itens Liberados para gerar Credito			  ³±±
±±³			 ³ nTotSel   - Total Selecionado pelo usuario				  ³±± 
±±³			 ³ cCodLista - Codigo da Lista que esta sendo analisada		  ³±±
±±³			 ³ lEncPV    - Informa se e encerramento de pedido de venda   ³±± 
±±³			 ³ lEncerra  - Informa se e encerramento da lista de presentes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±  
±±³Retorno   ³lRet[L]  : Retorno logico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj8GerCred(aItensLib	,nTotSel,cCodLista,lEncPV,;
					lEncerra	)

Local aGrvSe1		:= {}								//Array contendo os dados para criacao do titulo de credito
Local cNatureza		:= &(SuperGetMV("MV_NATNCC")) 		//Parametro que determina a natureza de credito que será usada no titulo-->BT
Local cPrefixo		:= "LPR"							//Prefixo do Titulo
Local cNumero		:= ""								//Numero do Titulo
Local cParcela		:= Space(TamSX3("E1_PARCELA")[1])	//Parcela do Titulo
Local cTipo			:= "NCC"							//Tipo do Titulo
Local cMay			:= ""								//Variavel de controle do proximo numero
Local aArea			:= GetArea()						//Salva a Area atual
Local aAreaME1		:= ME1->( GetArea() )				//Salva a Area da tabela ME1
Local aAreaSA1		:= SA1->( GetArea() )				//Salva a Area da tabela SA1
Local aAreaME4		:= ME4->( GetArea() )				//Salva a Area da tabela ME4
Local nQtdDVenNCC	:= 0								//Quantidade de dias para vencimento da NCC
Local lRet			:= .F.								//Variavel logica de Retorno
Local dDtVencto		:= cTod("  /  /  ")					//Data de Vencimento do Titulo
Local nItSel		:= 0								//Variavel de laco
Local nQtdItLib		:= Len(aItensLib)					//Quantidade de itens liberados 
Local nPosRecno		:= Len(aItensLib[1])				//Busca a posicao do campo RECNO no array de itens liberados
Local aRegCtaC		:= {}								//Array usado para incluir o registro de NCC na tabela de Conta Corrente

Private lMsErroAuto := .F.								//Variavel usada para o retorno da EXECAUTO

Default aItensLib	:= {}								//Array contendo os itens liberados
Default nTotSel		:= 0								//Variavel contendo o valor do credito a ser gerado
Default lEncPV		:= .F.								//Variavel que informa se e encerramento de pedido de venda (eliminacao de residuo)
Default lEncerra	:= .F.								//variavel que informa se e encerramento da lista de presentes

//Caso nao seja selecionado nenhum titulo, retorna a tela anterior
If nTotSel == 0
	MsgInfo(STR0022) //"Nao foi selecionado nenhum registro para gerar o credito ao organizador"
	lRet := .F.
Else
	//Tabela Cabecalho da Lista de Presentes
	DbSelectArea("ME1")
	DbSetOrder(2)	//ME1_FILIAL+ME1_CODIGO+ME1_TIPO+ME1_CODCLI+ME1_LOJCLI 
	DbSeek( xFilial("ME1") + cCodLista )
	
	DbSelectArea("SE1")
	DbSetOrder(1)	//E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	
	//busca na tabela de tipos de eventos (ME3) a quantidade de dias para vencimento do credito
	nQtdDVenNCC := GetAdvFVal("ME3","ME3_VENNCC",xFilial("ME3") + ME1->ME1_TPEVEN,1,"")
	
	//Monta o vencimento do titulo
	dDtVencto	:= dDataBase + nQtdDVenNCC
	
	cNumero	:= GetSx8Num("SE1","E1_NUM")		//Numero do Titulo	 
	cMay 	:= "SE1" + ALLTRIM( xFilial("SE1") ) + cNumero
	While !Eof() .AND. ( SE1->( DbSeek(xFilial("SE1") + cPrefixo + cNumero) ) .OR. !MayIUseCode(cMay) )
		cNumero := Soma1(cNumero, TamSX3("E1_NUM")[1] )
		cMay 	:= "SE1" + ALLTRIM( xFilial("SE1") ) + cNumero
	End
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + ME1->ME1_CODCLI + ME1->ME1_LOJCLI )

	aGrvSe1 := { 	{ "E1_FILIAL"	, xFilial("SE1") 					, Nil },;
					{ "E1_PREFIXO"	, cPrefixo 							, Nil },;
					{ "E1_NUM"		, cNumero							, Nil },;
					{ "E1_PARCELA"	, cParcela							, Nil },;
					{ "E1_TIPO"		, cTipo								, Nil },;
					{ "E1_NATUREZ"	, cNatureza 						, Nil },;					
					{ "E1_PORTADO"	, Space(TamSX3("E1_PORTADO")[1])	, Nil },;
					{ "E1_CLIENTE"	, ME1->ME1_CODCLI  					, Nil },;
					{ "E1_LOJA"   	, ME1->ME1_LOJCLI   				, Nil },;
					{ "E1_NOMCLI"	, SA1->A1_NREDUZ 					, Nil },;
					{ "E1_EMISSAO"	, dDataBase							, Nil },;
					{ "E1_EMIS1"	, dDataBase							, Nil },;
					{ "E1_VENCTO"	, dDtVencto							, Nil },;
					{ "E1_VENCORI"	, dDtVencto							, Nil },;
					{ "E1_VENCREA"	, DataValida(dDtVencto)				, Nil },;
					{ "E1_VALOR"  	, nTotSel							, Nil },;
					{ "E1_SALDO"  	, nTotSel							, Nil },;
					{ "E1_MOEDA"	, 1									, Nil },;	//como buscar a moeda automaticamente
					{ "E1_VLCRUZ" 	, nTotSel					 		, Nil },;
					{ "E1_HIST"   	, STR0023 + cCodLista	, Nil },; //"Lista de Presentes " 
					{ "E1_ORIGEM" 	, "FINA040"   						, Nil } }
	
	Begin Transaction 
		MsExecAuto({ | x,y | Fina040(x,y) },aGrvSe1,3)   
		If lMsErroAuto
			lRet := .F.
			RollBackSX8()
			MostraErro()
			DisarmTransaction()
		Else
			lRet := .T.
			
			DbSelectArea("ME4")
			
			For nItSel := 1 to nQtdItLib
				If aItensLib[nItSel][1]
					ME4->( dbGoTo( aItensLib[nItSel][nPosRecno] ) )
					RecLock("ME4",.F.)
					ME4->ME4_PRFTIT	:= cPrefixo
					ME4->ME4_NUMTIT	:= cNumero
					ME4->ME4_PARTIT	:= cParcela
					ME4->ME4_TIPTIT	:= cTipo
					ME4->ME4_TIPREG	:= "4"			//Credito Usado
					ME4->( MsUnLock() )
				EndIf
			Next nItSel
			
			//Alimenta o array com os itens que serao gravados na tabela de Conta Corrente da Lista de Presentes
			aAdd(aRegCtaC,cCodLista)		//01 - Codigo da Lista
			aAdd(aRegCtaC,Nil)				//02 - Item da Lista
			aAdd(aRegCtaC,Nil)				//03 - Codigo do Produto
			aAdd(aRegCtaC,Nil)				//04 - Quantidade
			aAdd(aRegCtaC,nTotSel)			//05 - Valor
			aAdd(aRegCtaC,cEmpAnt)			//06 - Empresa Original
			aAdd(aRegCtaC,cFilAnt)			//07 - Filial Original
			aAdd(aRegCtaC,Nil)				//08 - Numero do Orcamento
			aAdd(aRegCtaC,Nil)				//09 - Item do Orcamento
			aAdd(aRegCtaC,Nil)				//10 - Numero do Pedido de Venda
			aAdd(aRegCtaC,Nil)				//11 - Item do Pedido de Venda
			aAdd(aRegCtaC,Nil)				//12 - Numero do Documento
			aAdd(aRegCtaC,Nil)				//13 - Serie do Documento
			aAdd(aRegCtaC,dDataBase)		//14 - Emissao do documento/titulo
			aAdd(aRegCtaC,cPrefixo)			//15 - Prefixo do Titulo
			aAdd(aRegCtaC,cNumero)			//16 - Numero do Titulo
			aAdd(aRegCtaC,cParcela)			//17 - Parcela do Titulo
			aAdd(aRegCtaC,cTipo)			//18 - Tipo do Titulo
			aAdd(aRegCtaC,ME1->ME1_CODCLI)	//19 - Codigo do Cliente
			aAdd(aRegCtaC,ME1->ME1_LOJCLI)	//20 - Loja do Cliente
			
			//Funcao que cria o registro de NCC na tabela de Consulta da Conta Corrente da Lista de Presentes
			If !Lj8GeraCC(aRegCtaC,4,lEncPV)
				lRet := .F.
				RollBackSX8()
				DisarmTransaction()
			Else
				ConfirmSX8()
			EndIf

			If ExistBlock("LJ846NCC") 
				ExecBlock("LJ846NCC",.F.,.F.)
			EndIf
			
		EndIf
	
	End Transaction
EndIf

RestArea(aArea)
RestArea(aAreaME1)
RestArea(aAreaSA1)
RestArea(aAreaME4)

Return lRet




/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8GeraCC  ³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Conta Corrente da Lista de Presentes			  ³±±
±±³			 ³ A rotina deve ser chamada dentro de uma transacao		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados 	 - Array contendo os dados que devem ser gravados ³±±
±±³			 ³ nOpc		 - Opcao de criacao do registro, sendo:			  ³±± 
±±³			 ³ 		     1 - Credito, Debito e Bonus					  ³±±
±±³			 ³ 		     2 - Credito e Bonus							  ³±±
±±³			 ³ 		     3 - Somente Debito								  ³±±
±±³			 ³ 		     4 - Somente NCC								  ³±±
±±³			 ³ 		     5 - Somente Credito							  ³±±
±±³			 ³ lEncPV    - Encerramento do Pedido de Venda por Eliminacao ³±±
±±³			 ³ lDevolucao- Credito gerado a partir de uma Devolucao		  ³±±
±±³			 ³ lCanc     - Cancelamento de um credito gerado			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj8GeraCC(	aDados	,nOpc,lEncPV,lDevolucao,;
					lCanc	)

Local aArea		:= GetArea()							//Salva a Area
Local aAreaME1	:= ME1->( GetArea() )					//Salva a Area da tabela ME1
Local nSeqVld	:= 0									//Sequencia do laco para validacao do conteudo do array
Local xTpReg											//Tipo do Registro
Local nQtdReg	:= 0									//Mostra a quantidade de registros que serao criados
Local nReg		:= 0									//Contador para o laco
Local nBonus	:= 0									//Percentual de bonus da lista de presentes
Local nQtdDVlBlq:= SuperGetMV("MV_LJLPDBL",,7)			//Busca no parametro a quantidade de dias que um item fica bloqueado para geracao de credito
Local cSeq		:= Replicate("0",TamSX3("ME4_SEQ")[1])	//Variavel sequencial do campo ME4_SEQ
Local cQuery	:= ""									//variavel de tratamento para Query
Local cAlias	:= GetNextAlias()						//Proximo alias disponivel
Local cNomeCli	:= ""									//Nome do Cliente
Local lInsertME4:= .T. 									//Conrola se insere ou nao registro na tabela ME4.

Default aDados		:= {}								//Array contendo os dados que devem ser gravados
Default nOpc		:= 1								//Opcao de criacao do registro
Default lEncPV		:= .F. 								//Encerramento do Pedido de Venda por Eliminacao
Default lDevolucao	:= .F.								//Credito gerado a partir de uma Devolucao
Default	lCanc		:= .F.								//Cancelamento de um credito gerado

If Valtype(nOpc) <> "N"
	If !IsBlind()
		MsgInfo(STR0024) //"Tipo de operacao invalida"
	EndIf
	Return .F.
EndIf

//Verifico a opcao reportada para saber a quantidade de registros que sera necessario criar
If nOpc == NCC .OR. nOpc == DEBITO .OR. nOpc == SO_CREDITO  .or. nOpc == DEB_BONUS
	nQtdReg	:= 1 
ElseIf nOpc == CREDITO .Or. nOpc == CRED_DEB
	nQtdReg	:= 2
Else
	nQtdReg	:= 3
EndIf

//Verifico se o array possui informacoes contidas nele
If Len(aDados) == 0
	If !IsBlind()
		MsgInfo(STR0025) //"Nao foram enviados dados para geracao de registros na conta corrente"
	EndIf
	Return .F.
Else
	For nSeqVld := 1 to QTDELEMDD
		If Len(aDados) < nSeqVld .OR. ValType(aDados[nSeqVld]) == "U"
			If nSeqVld == EMISSAO
				xTpReg	:= cTod("  /  /  ")
			ElseIf nSeqVld == QUANT .OR. nSeqVld == VALOR
				xTpReg	:= 0
			Else
				xTpReg	:= ""
			EndIf
			
			If Len(aDados) < nSeqVld
				aAdd(aDados,xTpReg)
			Else
				aDados[nSeqVld] := xTpReg
			EndIf
		Else
			If nSeqVld == EMISSAO .AND. ValType(aDados[nSeqVld]) <> "D"
				If !IsBlind()
					MsgInfo(STR0026) //"O tipo do registro emissao esta diferente de DATA"
				EndIf
				Return .F.
			ElseIf (nSeqVld == QUANT .OR. nSeqVld == VALOR) .AND. ValType(aDados[nSeqVld]) <> "N"
				If !IsBlind()
					MsgInfo(STR0027) //"O tipo do registro Quantidade e/ou Valor esta diferente de NUMERICO"
				EndIf
				Return .F.
			ElseIf nSeqVld <> EMISSAO .AND. nSeqVld <> QUANT .AND. nSeqVld <> VALOR .AND. ValType(aDados[nSeqVld]) <> "C"
				If !IsBlind()
					MsgInfo(STR0028) //"O tipo do registro invalido"
				EndIf
				Return .F.				
			EndIf
		EndIf
	Next nSeqVld
EndIf

//Valida o codigo da lista de presentes
DbSelectArea("ME1")
DbSetOrder(2)	//ME1_FILIAL+ME1_CODIGO+ME1_TIPO+ME1_CODCLI+ME1_LOJCLI 
If ME1->( DbSeek( xFilial("ME1") + aDados[CODLISTA] ) )
	nBonus	:= ME1->ME1_PBONUS
	
	If !lDevolucao .And. !lCanc
		//Verifica se jah existe o registro na tabela ME4, para nao incluir o registro indevidamente.
		cQuery	:= " SELECT count(ME4_CODIGO) QTDREG"
		cQuery	+= " FROM " + RetSQLName("ME4")
		cQuery	+= "WHERE ME4_FILIAL = '" + xFilial("ME4") + "'"
		cQuery	+= "  AND ME4_CODIGO = '" + aDados[CODLISTA] + "'"
		cQuery	+= "  AND ME4_NUMORC = '" + aDados[ORCAMENTO] + "'"
		cQuery	+= "  AND ME4_ITORC	 = '" + aDados[ITORC] + "'"
		cQuery	+= "  AND ME4_DOC	 = '" + aDados[DOCUMENTO] + "'"
		cQuery	+= "  AND ME4_SERIE  = '" + aDados[SERIE] + "'"
		cQuery	+= "  AND D_E_L_E_T_ = ' '"
		cQuery	:= ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
		If !(cAlias)->( Eof() ) .And. (cAlias)->QTDREG > 0
			lInsertME4 := .F. //Jah existe registro, entao nao insere novamente
		EndIf
		(cAlias)->( DbCloseArea() )
	EndIf

Else
	If !IsBlind()
		MsgInfo(STR0001) //"Codigo de Lista nao encontrado"
	EndIf
	Return .F.
EndIf

//Valida a quantidade reportada
If aDados[VALOR] <= 0
	If !IsBlind()
		MsgInfo(STR0029) //"Conteudo do registro valor invalido"
	EndIf
	Return .F.
EndIf

//Valida se esta preenchida a empresa e a filial original
If Empty(aDados[EMPORI]) .OR. Empty(aDados[FILORI])
	If !IsBlind()
		MsgInfo(STR0030) //"Conteudo do registro Empresa Original e/ou Filial Original  estao em branco"
	EndIf
	Return .F.
EndIf

//Valida a data de emissao
If Empty(aDados[EMISSAO])
	If !IsBlind()
		MsgInfo(STR0031) //"Data de Emissao invalida"
	EndIf
	Return .F.
EndIf

If Empty(aDados[CODCLI]) .OR. Empty(aDados[LOJACLI])
	If !IsBlind()
		MsgInfo(STR0032) //"Dados do Cliente invalidos"
	EndIf
	Return .F.	
Else
	cNomeCli	:= Posicione("SA1", 1, xFilial("SA1") + aDados[CODCLI] + aDados[LOJACLI], "A1_NOME")
	If Empty(cNomeCli)
		If !IsBlind()
			MsgInfo(STR0033 + aDados[CODCLI] + "/" + aDados[LOJACLI] + STR0034) //"Cliente ("###") nao encontrado"
		EndIf
		Return .F.
	EndIf
EndIf

If nOpc == CRDEBO .OR. nOpc == CREDITO .OR. nOpc == DEBITO .OR. nOpc == SO_CREDITO .or. nOpc == DEB_BONUS .Or. nOpc == CRED_DEB .Or. nOpc == CR_USA_DEB
	//Valido o Item da Lista
	If Empty(aDados[ITLISTA]) .and. nOpc <> DEB_BONUS
		If !IsBlind()
			MsgInfo(STR0035) //"A Sequencia de item da lista de presentes esta em branco"
		EndIf
		Return .F.
	EndIf
	
	//Valida o Codigo do Produto
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !SB1->( dbSeek( xFilial("SB1") + aDados[CODPROD] ) )
		If !IsBlind()
			MsgInfo(STR0036 + aDados[CODPROD] + STR0037) //"Codigo do produto"###" nao encontrado"
		EndIf
		Return .F.		
	EndIf

	//Valida a quantidade do registro
	If aDados[QUANT] <= 0
		If !IsBlind()
			MsgInfo(STR0038) //"Conteudo do registro quantidade invalido"
		EndIf
		Return .F.
	EndIf
	
	//Valida se o numero do documento e a serie estao preenchidos
	If Empty(aDados[DOCUMENTO]) .OR. Empty(aDados[SERIE])
		If !IsBlind()
			MsgInfo(STR0039) //"Conteudo do registro Documento e/ou Serie estao em branco"
		EndIf
		Return .F.
	EndIf
ElseIf nOpc == NCC
	If Empty(aDados[PREFIXO]) .OR. Empty(aDados[TITULO]) .OR. Empty(aDados[TIPOTIT])
		If !IsBlind()
			MsgInfo(STR0040) //"Dados do titulo (Prefixo/Titulo/Tipo) invalidos"
		EndIf
		Return .F.
	EndIf
Else
	If !IsBlind()
		MsgInfo(STR0041 + cValtoChar(nOpc) + STR0042) //"Opcao "###" invalida"
	EndIf
	Return .F.
EndIf

If lInsertME4 .or. FunName() == "LOJA845"
	//Verifica qual o proximo SEQ a ser utilizado
	cQuery	:= "select max(me4_seq) MAXSEQ from " + RetSqlName("ME4")
	cQuery	+= " where me4_filial = '" + xFilial("ME4") + "'"
	cQuery	+= "   and me4_codigo = '" + aDados[CODLISTA] + "'"
	cQuery	+= "   and d_e_l_e_t_ = ' '"
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	If !(cAlias)->( Eof() )
		cSeq	:= (cAlias)->MAXSEQ
	EndIf
	
	(cAlias)->( DbCloseArea() )
	
	For nReg := 1 to nQtdReg

		//Nao gerar bonus em branco
		If nBonus == 0 .And. ( ( nReg == 2 .And. nOpc # CRED_DEB ) .or. nOpc == DEB_BONUS) 	//Registro do Bonus - sempre depois de incluir o registro de credito
			Loop
		EndIf

		cSeq := Soma1(cSeq,TamSX3("ME4_SEQ")[1])
	
		RecLock("ME4",.T.)
		ME4->ME4_FILIAL	:= xFilial("ME4")
		ME4->ME4_CODIGO	:= aDados[CODLISTA]
		ME4->ME4_ITLST	:= aDados[ITLISTA]
		ME4->ME4_COD	:= aDados[CODPROD]
		ME4->ME4_QUANT	:= aDados[QUANT]
	
		If ( nReg == 2 .And. nOpc # CRED_DEB ) .or. nOpc == DEB_BONUS 	//Registro do Bonus - sempre depois de incluir o registro de credito
			ME4->ME4_VALOR	:= Round(aDados[VALOR] * (nBonus /100),TamSX3("ME4_VALOR")[2])
		Else			//Todos os demais
			ME4->ME4_VALOR	:= aDados[VALOR]
		EndIf
	
		If nOpc == NCC
			ME4->ME4_TIPO	:= IIF(lEncPV,"5","3")	//Resgate de Credito por Encerramento do PV#Resgate de Credito
			ME4->ME4_TIPREG	:= "2"	//Debito
		ElseIf nOpc == DEBITO
			ME4->ME4_TIPO	:= IIF(lCanc,"7","4")	//Resgate de Produto
			ME4->ME4_TIPREG	:= "2"	//Debito
		ElseIf nReg == 2 .And. nOpc # CRED_DEB
			ME4->ME4_TIPO	:= "2"	//Bonus
			ME4->ME4_TIPREG	:= IIF(nQtdDVlBlq > 0,"3","1")	//Credito Liberado#Credito Bloqueado
		ElseIf nReg == 3 .Or. (nReg == 2 .And. nOpc == CRED_DEB)
			ME4->ME4_TIPO	:= "4"	//Resgate de Produto
			ME4->ME4_TIPREG	:= "2"	//Debito
		ElseIf nOpc == DEB_BONUS  
		    ME4->ME4_TIPO	:= "2"	//Bonus
		    ME4->ME4_TIPREG	:= "2"  //Debito
		Else
			ME4->ME4_TIPO	:= "1"	//Venda
			ME4->ME4_TIPREG	:= IIF(lDevolucao,"6",IIF(nQtdReg == 3 .Or. nOpc == CRED_DEB .Or. nOpc == CR_USA_DEB,"4",IIF(nQtdDVlBlq > 0,"3","1")))	//Devolucao#Credito Usado#Credito Bloqueado#Credito Liberado
		EndIf
	
		ME4->ME4_EMPMOV	:= aDados[EMPORI]
		ME4->ME4_FILMOV	:= aDados[FILORI]
		ME4->ME4_NUMORC	:= aDados[ORCAMENTO]
		ME4->ME4_ITORC	:= aDados[ITORC]
		ME4->ME4_PEDIDO	:= aDados[PEDIDO]
		ME4->ME4_ITPED	:= aDados[ITPEDIDO]
		ME4->ME4_DOC	:= aDados[DOCUMENTO]
		ME4->ME4_SERIE	:= aDados[SERIE]
		ME4->ME4_EMISSA	:= aDados[EMISSAO]
		ME4->ME4_PRFTIT	:= aDados[PREFIXO]
		ME4->ME4_NUMTIT	:= aDados[TITULO]
		ME4->ME4_PARTIT	:= aDados[PARCELA]
		ME4->ME4_TIPTIT	:= aDados[TIPOTIT]
		ME4->ME4_CODCLI	:= aDados[CODCLI]
		ME4->ME4_LOJCLI	:= aDados[LOJACLI]
		ME4->ME4_NOMCLI	:= cNomeCli
		ME4->ME4_SEQ	:= cSeq
		ME4->( MsUnLock() )
	Next nQtdReg

EndIf

RestArea(aArea)
RestArea(aAreaME1)

Return .T.





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8CanCred ³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina que efetua o cancelamento de um credito gerado	  ³±±
±±³			 ³ Será cancelado tambem o bonus, caso existe				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aItensCC - Array contendo todos os itens da consulta		  ³±±
±±³			 ³oItensCC - Objeto da Consulta Conta Corrente				  ³±±
±±³			 ³aColItens- Array contendo todos os campos apresentados	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±  
±±³Retorno   ³lRet[L]  : Retorno logico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj8CanCred(aItensCC,oItensCC,aColItens)

Local lRet		:= .F.																	//Variavel de retorno
Local cTxtColTR	:= aColItens[aScan(aColItens,{|x| Alltrim(x[1]) == "ME4_TIPREG"})][3]	//Texto da coluna ME4_TIPREG para pesquina no objeto
Local cTxtColTP	:= aColItens[aScan(aColItens,{|x| Alltrim(x[1]) == "ME4_TIPO"})][3]		//Texto da coluna ME4_TIPO para pesquina no objeto
Local nPTpReg	:= aScan(oItensCC:aHeaders,{|x| Alltrim(x) == Alltrim(cTxtColTR)})		//Posicao do campos Tipo de Registro
Local nPTipo	:= aScan(oItensCC:aHeaders,{|x| Alltrim(x) == Alltrim(cTxtColTP)})		//Posicao do campos Tipo
Local aAuxCombo	:= RetSx3Box(Posicione("SX3",2,PadR("ME4_TIPREG",10),"X3CBox()"),,, 1)	//Array contendo os status da consulta de conta corrente
Local nPCombo	:= 0																	//POsicao no combo box do campo ME4_TIPREG
Local nPItemCC	:= oItensCC:nAt															//Linha do objeto que o usuario esta posicionado
Local cObs	 	:= ""																	//Observacao obrigatoria para o cancelamento do credito
Local nOpc		:= 0																	//Opcao selecionada pelo usuario
Local oObs																				//Objeto da observacao
Local oDlg																				// Dialog Principal
Local cTitulo	:= STR0043	//Titulo da janela de Observacao //"Observacao do Cancelamento de Credito (Preenchimento Obrigatorio)"
Local aArea		:= GetArea()															//Salva a Area Atual
Local aAreaME4	:= ME4->( GetArea() )													//Salva a Area da tabela ME4
Local aRegCtaC	:= {}																	//Array para criar o registro de Credito na tabela de conta corrente

//Variaveis para posicionamento de atualizacao
Local cTxtItLst	:= aColItens[aScan(aColItens,{|x| Alltrim(x[1]) == "ME4_ITLST"})][3]	//Texto da coluna ME4_ITLST para pesquina no objeto
Local nPItemLst	:= aScan(oItensCC:aHeaders,{|x| Alltrim(x) == Alltrim(cTxtItLst)})		//Posicao do campos Item da Lista
Local cTxtSeq	:= aColItens[aScan(aColItens,{|x| Alltrim(x[1]) == "ME4_SEQ"})][3]		//Texto da coluna ME4_SEQ para pesquina no objeto
Local nPSeq		:= aScan(oItensCC:aHeaders,{|x| Alltrim(x) == Alltrim(cTxtSeq)})		//Posicao do campos Item da Lista

Default aItensCC := {}																	//- Array contendo todos os itens da consulta	
Default oItensCC := NIL																	//- Objeto da Consulta Conta Corrente			
Default aColItens:=	{}																	//- Array contendo todos os campos apresentados


nPCombo	:= aScan(aAuxCombo,{|x| Alltrim(x[3]) == Alltrim(aItensCC[nPItemCC][nPTpReg]) })

//Se nao contrar nenhum registro no combo box retorna
If nPCombo == 0
	MsgInfo(STR0044) //"Status nao encontrado"
	Return .F.
	
//So serao cancelados registros de credito liberado e credito bloqueado	
ElseIf !(Alltrim(aAuxCombo[nPCombo][2]) $ "1|3")

	MsgInfo(STR0045 + aAuxCombo[1][3] + STR0046 + aAuxCombo[3][3]) //"Só serao cancelados registros dos tipos "###" e "
	Return .F.
	
//caso seja credito liberado ou credito bloqueado, mas o registro foi gerado a partir da devolucao de venda. 
//Retorno, pois nesse caso tem que fazer encerramento do pedido de venda (LOJA854)
ElseIf Alltrim(aAuxCombo[nPCombo][2]) $ "1|3" .AND. aItensCC[nPItemCC][nPTipo] == "6"
	MsgInfo(STR0047) //"Credito gerado a partir de uma Devolucao criando um Pedido de Venda. E necessario efetuar o encerramento de pedido de venda nesse caso"
	Return .F.	
EndIf
If !LJProfile(27,NIL,NIL,NIL,NIL,.T.,NIL)	//Valida se o usuario pode realizar Cancelamento de Credito da Lista de Presentes
	Return .F.
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo FROM C(178),C(181) TO C(339),C(527) PIXEL
	@ C(008),C(002) GET oObs Var cObs MEMO Size C(161),C(044) PIXEL OF oDlg
	oObs:Align	:= CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg, {||nOpc	:= 1 ,oDlg:End() },{|| oDlg:End() },,)

If nOpc == 1 .AND. Empty(cObs)
	MsgInfo(STR0048) //"Para efetuar o cancelamento e obrigatorio o preenchimento da observacao."
ElseIf nOpc == 1
	If ExistBlock("LJ846CAN")        /////  Ponto de Entrada para gerar NCC do convidado - TI4501 25.05.11
       ME4->( DbSeek( xFilial("ME4") + M->ME1_CODIGO + aItensCC[nPItemCC][nPItemLst] + aItensCC[nPItemCC][nPSeq] ) )
	   If !ExecBlock("LJ846CAN",.F.,.F.,{cObs})
	      Alert(STR0061)    //"NCC nao pode ser gerada!"
	   EndIf
	Else
		Begin Transaction
			DbSelectArea("ME4")
			DbSetOrder(1)

			If ME4->( DbSeek( xFilial("ME4") + M->ME1_CODIGO + aItensCC[nPItemCC][nPItemLst] + aItensCC[nPItemCC][nPSeq] ) )

				RecLock("ME4",.F.)
				ME4->ME4_TIPREG	:= "4"	//Credito Usado
				ME4->( MsUnLock() )
				
				aRegCtaC	:= {}
				aAdd(aRegCtaC,M->ME1_CODIGO)	   						//01 - Codigo da Lista
				aAdd(aRegCtaC,ME4->ME4_ITLST)	   						//02 - Item da Lista
				aAdd(aRegCtaC,ME4->ME4_COD)		   						//03 - Codigo do Produto
				aAdd(aRegCtaC,ME4->ME4_QUANT)	   						//04 - Quantidade
				aAdd(aRegCtaC,ME4->ME4_VALOR)	   						//05 - Valor
				aAdd(aRegCtaC,cEmpAnt)			   						//06 - Empresa Original
				aAdd(aRegCtaC,cFilAnt)									//07 - Filial Original
				aAdd(aRegCtaC,ME4->ME4_NUMORC)							//08 - Numero do Orcamento
				aAdd(aRegCtaC,ME4->ME4_ITORC)							//09 - Item do Orcamento
				aAdd(aRegCtaC,ME4->ME4_PEDIDO)							//10 - Numero do Pedido de Venda
				aAdd(aRegCtaC,ME4->ME4_ITPED)							//11 - Item do Pedido de Venda
				aAdd(aRegCtaC,Replicate("X",TamSX3("ME4_DOC")[1]))		//12 - Numero do Documento
				aAdd(aRegCtaC,Replicate("X",TamSX3("ME4_SERIE")[1]))	//13 - Serie do Documento
				aAdd(aRegCtaC,dDataBase)		  						//14 - Emissao do documento/titulo
				aAdd(aRegCtaC,NIL)				   						//15 - Prefixo do Titulo
				aAdd(aRegCtaC,NIL)				   						//16 - Numero do Titulo
				aAdd(aRegCtaC,NIL)				  						//17 - Parcela do Titulo
				aAdd(aRegCtaC,NIL)				  						//18 - Tipo do Titulo
				aAdd(aRegCtaC,ME4->ME4_CODCLI)	  						//19 - Codigo do Cliente
				aAdd(aRegCtaC,ME4->ME4_LOJCLI)	  						//20 - Loja do Cliente
	
				//Chama a rotina que cria o registo de debito na tabela de conta corrente
				If !Lj8GeraCC(aRegCtaC,3,NIL,NIL,.T.)
					DisarmTransaction()
				Else
					lRet := .T.
				EndIf
			EndIf
		End Transaction
	EndIf
Else
	MsgInfo(STR0049) //"Cancelamento nao efetuado"
EndIf

RestArea(aArea)
RestArea(aAreaME4)

Return lRet






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj8CanCred ³ Autor ³ Vendas Cliente       ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina que efetua o cancelamento de um credito gerado	  ³±±
±±³			 ³ Será cancelado tambem o bonus, caso existe				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aItensCC - Array contendo todos os itens da consulta		  ³±±
±±³			 ³oItensCC - Objeto da Consulta Conta Corrente				  ³±±
±±³			 ³aColItens- Array contendo todos os campos apresentados	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj8Observacao(aItensCC,oItensCC,aColItens)

Local cTxtItLst	:= aColItens[aScan(aColItens,{|x| Alltrim(x[1]) == "ME4_ITLST"})][3]	//Texto da coluna ME4_ITLST para pesquina no objeto
Local nPItemLst	:= aScan(oItensCC:aHeaders,{|x| Alltrim(x) == Alltrim(cTxtItLst)})		//Posicao do campos Item da Lista
Local cTxtSeq	:= aColItens[aScan(aColItens,{|x| Alltrim(x[1]) == "ME4_SEQ"})][3]	//Texto da coluna ME4_SEQ para pesquina no objeto
Local nPSeq		:= aScan(oItensCC:aHeaders,{|x| Alltrim(x) == Alltrim(cTxtSeq)})		//Posicao do campos Item da Lista
Local cObs	 	:= ""																	//Observacao obrigatoria para o cancelamento do credito
Local cTitulo	:= STR0050																//Titulo da janela de Observacao
Local aArea		:= GetArea()															//Salva a Area Atual
Local nPItemCC	:= oItensCC:nAt															//Linha do objeto que o usuario esta posicionado
Local aAreaME4	:= ME4->( GetArea() )													//Salva a Area da tabela ME4
Local oObs																				//Objeto da observacao
Local oDlg																				// Dialog Principal

Default aItensCC := {} 																	//- Array contendo todos os itens da consulta
Default oItensCC := NIL 																//- Objeto da Consulta Conta Corrente
Default aColItens:= {}																	//- Array contendo todos os campos apresentados


DbSelectArea("ME4")
DbSetOrder(1)
DbSeek( xFilial("ME4") + M->ME1_CODIGO + aItensCC[nPItemCC][nPItemLst] + aItensCC[nPItemCC][nPSeq] )
cObs := ME4->ME4_OBS

If !Empty(cObs)
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM C(178),C(181) TO C(339),C(527) PIXEL
		@ C(008),C(002) GET oObs Var cObs MEMO Size C(161),C(044) PIXEL OF oDlg
		oObs:Align	:= CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg, {|| oDlg:End() },{|| oDlg:End() },,)
Else
	MsgInfo(STR0051)
EndIf

RestArea(aArea)
RestArea(aAreaME4)

Return





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ Automacao Comercial										 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³	nTam - Tamanho para resolucao							  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³	nTam - Tamanho para resolucao							  	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

Default nTam := 0

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).OR.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

Return Int(nTam)


//--------------------------------------------------
/*/{Protheus.doc} Lj8EstCC
Na exclusao de uma venda, cancela (lanca uma contra-partida) para os creditos
@param	 cFilOrc - Filial do Orçamento
@param	 aNumOrc - orcamentos ( no caso de um orcamento possuir sub-orcamentos)
@param	 cCliente - código do cliente
@param	 cLoja - código da loja
@author  Varejo
@version P11.8
@since   02/03/2015
@return  lRet
/*/
//--------------------------------------------------
Function Lj8EstCC(cFilOrc, aNumOrc, cCliente, cLoja)

Local cResultSet	:= GetNextAlias()	
Local cNumOrc		:= ""
Local nI			:= 0
Local lRet			:= .F.	
Local aItLstPre		:= {}
Local aME4Area		:= {}

Default cFilOrc		:= ""
Default aNumOrc		:= {}
Default cCliente	:= ""
Default cLoja		:= ""

//atraves da clausa IN, trazemos os suborcamentos
For nI := 1 to Len(aNumOrc)
	cNumOrc += (aNumOrc[nI] + ",")
Next
cNumOrc := SubStr( cNumOrc, 1, (Len(cNumOrc)-1) )	//retira a ultima virgula

//
// Obtem os dados da Conta Corrente da Lista de Presente
// Observacoes:
// 1 - utilizamos a query, pois nenhum indice na ME4 era capaz de fazer uma busca pelo item
// 2 - ganho de performance, pois cada item pode ter n registros, o que ocasionaria um loop para cada registro
// 3 - fazemos um JOIN com SL2 para trazer o valor total do item, pois a funcao Lj8GeraCC utiliza esse valor para fazer o estorno do bonus
//
BeginSQL Alias cResultSet

	column ME4_EMISSA as Date

	SELECT
		ME4.ME4_FILIAL,
		ME4.ME4_CODIGO,
		ME4.ME4_ITLST,
		ME4.ME4_COD,
		ME4.ME4_QUANT,
		SL2.L2_FILIAL,
		SL2.L2_VLRITEM,
		ME4.ME4_NUMORC,
		ME4.ME4_ITORC,
		ME4.ME4_DOC,
		ME4.ME4_SERIE,
		ME4.ME4_EMISSA,
		ME4.ME4_CODCLI,
		ME4.ME4_LOJCLI,
		ME4.ME4_TIPO,
		ME4.ME4_TIPREG,
		ME4.R_E_C_N_O_
	FROM
		%table:ME4% ME4
	INNER JOIN			
		%table:SL2% SL2
	ON  ME4.ME4_CODIGO = SL2.L2_CODLPRE
		AND ME4.ME4_NUMORC = SL2.L2_NUM
		AND ME4.ME4_ITORC = SL2.L2_ITEM
		AND ME4.ME4_COD = SL2.L2_PRODUTO
		AND ME4.D_E_L_E_T_ = SL2.D_E_L_E_T_
	WHERE ME4.%notDel%
		AND SL2.L2_FILIAL = %exp:cFilOrc%
		AND ME4.ME4_FILIAL = %xFilial:ME4%
		AND ME4.ME4_NUMORC IN (%exp:cNumOrc%)
		AND ME4.ME4_CODCLI = %exp:cCliente%
		AND ME4.ME4_LOJCLI = %exp:cLoja%
		AND ( NOT EXISTS
				(SELECT 1 FROM %table:ME4% ME4SUB
				WHERE ME4SUB.ME4_NUMORC = ME4.ME4_NUMORC
				AND ME4SUB.ME4_ITORC = ME4.ME4_ITORC
				AND ME4SUB.D_E_L_E_T_ = ME4.D_E_L_E_T_
				AND ME4SUB.ME4_TIPO = '4' AND ME4SUB.ME4_TIPREG = '2')	//filtra somente os itens que nao foram retirados (DEBITO)
			OR 
				(ME4.ME4_TIPO = '2' AND ME4.ME4_TIPREG = '1') 			//bonus
			)
EndSQL

//
// Gera os Debitos referente aos ITENS e BONUS	
//
If (cResultSet)->( !Eof() )

	aME4Area := ME4->(GetArea())
	DbSelectArea(cResultSet)
	(cResultSet)->( DbGoTop() )
	
	While (cResultSet)->( !EoF() )
		Aadd( aItLstPre, (cResultSet)->ME4_CODIGO )
		Aadd( aItLstPre, (cResultSet)->ME4_ITLST )
		Aadd( aItLstPre, (cResultSet)->ME4_COD )
		Aadd( aItLstPre, (cResultSet)->ME4_QUANT )
		Aadd( aItLstPre, (cResultSet)->L2_VLRITEM )
		Aadd( aItLstPre, cEmpAnt )
		Aadd( aItLstPre, cFilAnt )
		Aadd( aItLstPre, (cResultSet)->ME4_NUMORC )
		Aadd( aItLstPre, (cResultSet)->ME4_ITORC )
		Aadd( aItLstPre, Nil )
		Aadd( aItLstPre, Nil )
		Aadd( aItLstPre, (cResultSet)->ME4_DOC )
		Aadd( aItLstPre, (cResultSet)->ME4_SERIE )
		Aadd( aItLstPre, (cResultSet)->ME4_EMISSA )
		Aadd( aItLstPre, Nil )
		Aadd( aItLstPre, Nil )
		Aadd( aItLstPre, Nil )
		Aadd( aItLstPre, Nil )
		Aadd( aItLstPre, (cResultSet)->ME4_CODCLI)
		Aadd( aItLstPre, (cResultSet)->ME4_LOJCLI)

		If (cResultSet)->ME4_TIPO $ "1|4" .AND. (cResultSet)->ME4_TIPREG == "1"		
			//o segundo parametro igual a 3, indica que é um cancelamento de um item
			Lj8GeraCC( aItLstPre, 3, Nil, Nil, .T. )

		ElseIf (cResultSet)->ME4_TIPO == "2" .AND. (cResultSet)->ME4_TIPREG == "1"
			//o segundo parametro igual a 6, indica que é um cancelamento de um bonus
			Lj8GeraCC( aItLstPre, 6, Nil, Nil, .T. )

			If (cResultSet)->R_E_C_N_O_ > 0

				ME4->( dbGoTo( (cResultSet)->R_E_C_N_O_ ) )
				If RecLock("ME4",.F.)
					ME4->ME4_TIPREG	:= "4" //Credito Usado
					ME4->( MsUnLock() )			
				EndIf
			EndIf

		EndIf

		(cResultSet)->( DbSkip() )
		aItLstPre := {}
	EndDo

	RestArea(aME4Area)
Else
	lRet := .F.
EndIf

(cResultSet)->( DbCloseArea() )

Return lRet


//-----------------------------------------------------------
/*/{Protheus.doc} Lj8EstQtd
Restaura a Quantidade e Status dos itens da Lista de Presente
@param	 cCodLstPre - codigo da lista de presente
@param	 cItLstPre - numero do item na lista de presente
@param	 nQtdCan - quantidade a ser estornada
@author  Varejo
@version P11.8
@since   03/03/2015
@return  lRet - indica se os estornos foram realizados
/*/
//-----------------------------------------------------------
Function Lj8EstQtd(cCodLstPre, cItLstPre, nQtdCan)

Local lRet 		:= .T.
Local nQtdTot	:= 0		//quantidade atendida apos o estorno
Local cStatus	:= ""		//status da lista de presente (A-aberta P-parcial E-encerrada)
Local aME2Area	:= ME2->( GetArea() )

Default cCodLstPre	:= ""
Default cItLstPre	:= ""
Default nQtdCan		:= ""

DbSelectArea("ME2")
ME2->( DbSetOrder(1) )	//ME2_FILIAL + ME2_CODIGO + ME2_ITEM

If ME2->( DbSeek(xFilial("ME2") + cCodLstPre + cItLstPre) )

	If ME2->ME2_ORIGEM == "O"
		nQtdTot := ME2->ME2_QTDATE - nQtdCan

		Do Case
			Case nQtdTot <= 0
				cStatus := "A"
				nQtdTot := iIf(nQtdTot < 0, 0, nQtdTot)
			Case nQtdTot > 0 .AND. nQtdTot < ME2->ME2_QTDSOL
				cStatus := "P"
			Case nQtdTot == ME2->ME2_QTDSOL
				cStatus := "E"
		End Case

		RecLock("ME2", .F.)
			Replace ME2->ME2_QTDATE with nQtdTot
			Replace ME2->ME2_STATUS with cStatus
		ME2->( MsUnlock() )

	//deletamos um item que nao faça parte da Lista de Presentes
	ElseIf ME2->ME2_ORIGEM == "C"
		RecLock("ME2", .F.)
			ME2->( DbDelete() )
		ME2->( MsUnlock() )
	EndIf

Else
	lRet := .F.
EndIf

RestArea( aME2Area )

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} Lj8SetObs
Na exclusao de uma venda, preenche o campo de observações para indicar que houve 
o cancelamento.
@param	 cFilOrc - Filial do Orçamento
@param	 aNumOrc - orcamentos ( no caso de um orcamento possuir sub-orcamentos)
@param	 aDocs - numero dos documentos
@param	 cCliente - código do cliente
@param	 cLoja - código da loja
@author  Varejo
@version P11.8
@since   26/11/2015
@return  lRet
/*/
//--------------------------------------------------
Function Lj8SetObs(cFilOrc, aNumOrc, aDocs, cCliente, cLoja)
Local lRet			:= .T.
Local cNumOrc		:= ""
Local cDocs		:= ""
Local cSeries		:= ""
Local nI			:= 0
Local cResultSet	:= GetNextAlias()
Local cCondDoc	:= "% %"

Default cFilOrc	:= ""
Default aNumOrc	:= {}
Default aDocs		:= {}
Default cCliente	:= ""
Default cLoja		:= ""

//atraves da clausa IN, trazemos os suborcamentos
For nI := 1 to Len(aNumOrc)
	cNumOrc += (aNumOrc[nI] + ",")
Next
cNumOrc := SubStr( cNumOrc, 1, (Len(cNumOrc)-1) )	//retira a ultima virgula

For nI := 1 to Len(aDocs)
	cDocs	+= ("'"+AllTrim(aDocs[nI,1])+"'" + ",")
	cSeries	+= ("'"+allTrim(aDocs[nI,2])+"'" + ",")
Next
cDocs		:= SubStr( cDocs, 1, (Len(cDocs)-1) )	//retira a ultima virgula
cSeries	:= SubStr( cSeries, 1, (Len(cSeries)-1) )	//retira a ultima virgula

If !Empty(cDocs) .And. !Empty(cSeries) 
	cCondDoc := "% ME4.ME4_DOC IN ("+cDocs+") AND ME4.ME4_SERIE IN ("+cSeries+")%"
Else
	cCondDoc := "% ME4.ME4_DOC = '' AND ME4.ME4_SERIE = '' %"
EndIf

BeginSQL Alias cResultSet

	column ME4_EMISSA as Date

	SELECT 
		ME4.R_E_C_N_O_
	FROM
		%table:ME4% ME4
	INNER JOIN			
		%table:SL2% SL2
	ON  ME4.ME4_CODIGO		= SL2.L2_CODLPRE
		AND ME4.ME4_NUMORC	= SL2.L2_NUM
		AND ME4.ME4_ITORC	= SL2.L2_ITEM
		AND ME4.ME4_COD		= SL2.L2_PRODUTO
		AND ME4.D_E_L_E_T_	= SL2.D_E_L_E_T_
	WHERE ME4.%notDel%
		AND SL2.L2_FILIAL	=	%exp:cFilOrc%
		AND ME4.ME4_FILIAL	=	%xFilial:ME4%
		AND ME4.ME4_NUMORC	IN	(%exp:cNumOrc%)
		AND ME4.ME4_CODCLI	=	%exp:cCliente%
		AND ME4.ME4_LOJCLI	=	%exp:cLoja%
		AND %exp:cCondDoc%
EndSQL

If (cResultSet)->( !Eof() )

	DbSelectArea(cResultSet)

	While (cResultSet)->( !EoF() )

		If (cResultSet)->R_E_C_N_O_ > 0

			ME4->(DBGoTo((cResultSet)->R_E_C_N_O_))
			If RecLock("ME4", .F.)
				If SuperGetMv("MV_LJLPHIS",.F.,"1") == "2" //2-Mantem o historico das vendas canceladas.

					ME4->ME4_OBS := "Venda Cancelada." //"Item de Venda Cancelada"
				Else //1-Deleta o registro para nao ter historico

					ME4->(DbDelete())
				EndIf
				ME4->(MSUnlock())
			EndIf
		EndIf
		(cResultSet)->( DbSkip() )
	EndDo
Else
	lRet := .F.
EndIf

(cResultSet)->( DbCloseArea() )

Return lRet


//--------------------------------------------------
/*/{Protheus.doc} Lj8GrvPed
Efetua a gravação dos campos de pedido na lista de presente quando entrega
@param	 aSL2		- Array com os itens
@param	 cNumPai	- Numero do orçamento pai
@param	 cOrcFilho	- Numero do orçamento filho
@param	 cPedido	- Numero do pedido de venda

@author  Varejo
@version P11.8
@since   23/05/2016
@return  lRet
/*/
//--------------------------------------------------
Function Lj8GrvPed(aSL2, cNumPai, cOrcFilho, cPedido )
Local lRet			:= .T.
Local nI			:= 0
Local cDocPPai	:= ""
Local cSerPPai	:= ""
Local aAreaSl1	:= SL1->(GetArea())
Local aAreaSl2	:= SL2->(GetArea())
Local nPosItem	:= 0

Default aSL2		:= {}
Default cNumPai	:= ""
Default cOrcFilho	:= ""
Default cPedido	:= ""

If Len(aSL2) > 0 .And. !Empty(cNumPai)
	cDocPPai	:= Posicione("SL1",1,xFilial("SL1")+cNumPai,"L1_DOCPED")
	cSerPPai	:= Posicione("SL1",1,xFilial("SL1")+cNumPai,"L1_SERPED")
	
	SL2->(DbSetOrder(1))	//Filial + Numero + Item
	For nI := 1 To Len(aSL2)
		nPosItem	:= Ascan(aSL2[nI], {|x| AllTrim(x[1]) == "L2_ITEM"	})		
		If nPosItem > 0.And. SL2->(DbSeek(xFilial("SL2") + cOrcFilho + aSL2[nI][nPosItem][2])) .And. !Empty(SL2->L2_CODLPRE)
			ExecGrvPed(	SL2->L2_FILIAL, cNumPai			, cDocPPai,	cSerPPai,;
							cPedido		, SL2->L2_ITESC6	)
		EndIf
	Next nI
EndIf

RestArea(aAreaSl2)
RestArea(aAreaSl1)

Return lRet 

//--------------------------------------------------
/*/{Protheus.doc} ExecGrvPed
Executa a query para efetuar a gravação dos campos de pedido na lista de presente quando entrega
@param	 cFilOrc	- Filial do Orçamento
@param	 aNumOrc	- orcamentos ( no caso de um orcamento possuir sub-orcamentos)
@param	 cNumOrc	- numero do orçamento
@param	 cDocs		- Numero do documento

@author  Varejo
@version P11.8
@since   20/05/2016
@return  lRet
/*/
//--------------------------------------------------
Static Function ExecGrvPed(	cFilOrc	,cNumOrc	,cDocs	,cSeries,;
					 			cNumPed	,cItPed)
Local lRet			:= .T.
Local cResultSet	:= GetNextAlias()

Default cFilOrc	:= ""
Default cNumOrc	:= ""
Default cDocs		:= ""
Default cSeries	:= ""
Default cNumPed	:= ""
Default cItPed	:= ""

BeginSQL Alias cResultSet

	column ME4_EMISSA as Date

	SELECT 
		ME4.R_E_C_N_O_
	FROM
		%table:ME4% ME4
	INNER JOIN
		%table:SL2% SL2
	ON  ME4.ME4_CODIGO		= SL2.L2_CODLPRE
		AND ME4.ME4_NUMORC	= SL2.L2_NUM
		AND ME4.ME4_ITORC		= SL2.L2_ITEM
		AND ME4.ME4_COD		= SL2.L2_PRODUTO
		AND ME4.D_E_L_E_T_	= SL2.D_E_L_E_T_
	WHERE ME4.%notDel%
		AND SL2.L2_FILIAL		= %exp:cFilOrc%
		AND ME4.ME4_FILIAL	= %xFilial:ME4%
		AND ME4.ME4_NUMORC	= %exp:cNumOrc%
		AND ME4.ME4_DOC		= %exp:cDocs%
		AND ME4.ME4_SERIE		= %exp:cSeries%

EndSQL

If (cResultSet)->( !Eof() )

	DbSelectArea(cResultSet)

	While (cResultSet)->( !EoF() )

		If (cResultSet)->R_E_C_N_O_ > 0

			ME4->(DBGoTo((cResultSet)->R_E_C_N_O_))
			If RecLock("ME4", .F.)
				ME4->ME4_PEDIDO	:= cNumPed
				ME4->ME4_ITPED	:= cItPed
				ME4->(MSUnlock())
			EndIf
		EndIf
		(cResultSet)->( DbSkip() )
	EndDo
Else
	lRet := .F.
EndIf

(cResultSet)->( DbCloseArea() )

Return lRet
