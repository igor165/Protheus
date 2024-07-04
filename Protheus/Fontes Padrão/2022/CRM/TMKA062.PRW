#INCLUDE "TMKA062.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH" 

#DEFINE VISUAL  	2
#DEFINE INCLUIR 	3
#DEFINE ALTERAR 	4
#DEFINE EXCLUIR 	5
#DEFINE PENDENTE   2

/*
	Array aAutoCab - Estrutura do SU4 para rotinas automaticas
	ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³01³ U4_FILIAL    ³ Filial  							  									         ³
	³02³ U4_LISTA     ³ Codigo sequencial da lista                   									 ³
	³03³ U4_DESC      ³ Descricao da lista                           									 ³
	³04³ U4_DATA      ³ Data de vigencia   										                       	 ³
	³05³ U4_TIPO      ³ Tipo de lista(1-Marketing / 2-Cobranca / 3- Vendas)                              ³ 
	³06³ U4_FORMA     ³ Tipo de Contato (1-Voz/2-Fax/3-Cross Posting4-Mala direta 5-Pendencia 6-WebSite) ³
	³  ³              ³                                                                                  ³
	³07³ U4_TELE      ³ 1-Telemarketing/ 2-Televendas/ 3-Telecobranca/ 4-Ambos (Legado) - USO INTERNO 811³
	³  ³              ³                                                                                  ³
	³08³ U4_OPERAD    ³ Operador																		 ³
	³09³ U4_CONFIG    ³ Codigo da Configuracao Telemarketing											 ³
	³10³ U4_TIPOTEL	  ³ Tipo de telefone( 1-Residencial/ 2-Celular/ 3-Fax/ 4-Comercial 1/ 5- Comercial 2)³
	³11³ U4_MALADIR   ³ Arquivo de mala direta														   	 ³
	³12³ U4_TIPOEND   ³ Endereco para mala direta														 ³
	³13³ U4_LABEL     ³ Etiqueta (1-Sim / 2-Nao)  													   	 ³
	³14³ U4_ETIQUET   ³ Arquivo de Etiqueta															     ³
	³15³ U4_CODCAMP   ³ Codigo da campanha															     ³
	³16³ U4_SCRIPT    ³ Codigo do script 															     ³
	³17³ U4_EVENTO    ³ Codigo do evento 														     	 ³
	ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	Array aAutoItens - Estrutura do SU6 para rotinas automaticas
	ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³01³ U6_FILIAL    ³ Filial  							  	   ³
	³02³ U6_LISTA     ³ Codigo sequencial da lista                 ³
	³03³ U6_CODIGO    ³ Codigo da ligacao                          ³
	³04³ U6_FILENT    ³ Filial da entidade 					       ³
	³05³ U6_ENTIDA    ³ Entidade       						       ³
	³06³ U6_CODENT    ³ Codigo da entidade                         ³
	³07³ U6_ORIGEM    ³ Origem (1-Lista/ 2-Manual /3-Atendimento)  ³
	³08³ U6_CONTATO   ³ Contato								       ³
	³09³ U6_DATA      ³ Data                                       ³
	³10³ U6_HRINI     ³ Hora inicial                               ³
	³11³ U6_HRFIM     ³ Hora final                                 ³
	³12³ U6_STATUS    ³ Status(1-Nao enviado /2- Em uso/ 3-Enviado)³
	³13³ U6_CODLIG    ³ Codigo da ligacao efetuada                 ³
	ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMKA062  ³ Autor ³ Vendas Clientes       ³ Data ³ 10/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista de Contatos para Telecobranca                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA062(xAutoCab,xAutoItens,nOpcAuto)

Local aArea 		:= GetArea()			// armazena area para posterior reposicionamento de tabelas.
Local nX			:= 0					// Variavel auxiliar para for.
Local lRet			:= .F.					// Retorno da funcao
Local nPos			:= 0 					// Variavel de auxilio para identificar a posicao do item no aRotina(Rotina automatica)
Local aCores    	:= {	{"VAL(SU4->U4_TIPO) == 3", "BR_VERDE"	},;// Vendas    
   							{"VAL(SU4->U4_TIPO) == 1", "BR_AZUL"    },;// Marketing 
   							{"VAL(SU4->U4_TIPO) == 2", "BR_VERMELHO"}} // Cobranca 
Local cUltimo	   	:= SuperGetMv("MV_TMKSK1")	// Data e hora da ultima atualizacao realizada no SK1
Local aPDFields		:= {}

Private la062Auto  	:= (xAutoCab <> NIL  .AND. xAutoItens <> NIL) // Identifica se utiliza rotina automatica
Private aAutoCab   	:= {}					// Array com os dados do cabecalho da rotina automatica
Private aAutoItens 	:= {}        			// Array com os Itens da rotina automatica
Private aTELA[0][0],aGETS[0]				// Variáveis privates para validacoes internas de campos.(Uso rotinas automaticas.)
                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := STR0007 // //"Gerador Listas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Antes de gerar a lista preciso ajustar o SK1 = SE1. Essa rotina devera ser ³
//³executada separadamente se nao estiver atualizada, pois dependendo da base ³
//³de dados do cliente, o processamento pode demorar.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cUltimo) .OR. CTOD(SubStr( cUltimo, 1, At( "-", cUltimo ) - 1 )) <> dDataBase
	If !lA062Auto
		MsgStop(STR0119 + SubStr( cUltimo, 1, At( "-", cUltimo ) - 1 ) + STR0120 ,STR0121)		//"A ultima atualização da tabela SK1 - Referencia de Titulos Vencidos foi feita dia " /" . Favor executar a atualização dessa tabela para ser possível realizar a geração de listas de cobrança."/ATENÇÃO
	Endif
	Return(.F.)	
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e rotina automatica                              ³c
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lA062Auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida array com os dados do cabecalho                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAutoCab := SU4->(MSArrayXDb(xAutoCab,,nOpcAuto))
	If ( Len(aAutoCab) == 0 )
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a validacao dos itens.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(xAutoItens)
		AAdd(aAutoItens,SU6->(MSArrayXDb(xAutoItens[nX],,nOpcAuto,.T.)))
		If Empty(aAutoItens[nX])
			Return(lRet)
		Endif
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a opcao desejada do menu solicitada via rotina automatica      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU4")
	nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
	If ( nPos # 0 )
		bBlock := &( "{ |x,y,z,k| " + aRotina[ nPos,2 ] + "(x,y,z,k) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
	Endif

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a MBrowse normal caso nao seja rotina automatica               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Protege rotina para que seja usada apenas no SIGATMK ou SIGACRM
	If !AMIIn(13,73)			// 13 = SIGATMK, 73 = SIGACRM
		Return(lRet)
	Endif

	// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	aPDFields := {"U5_CONTAT","U7_NOME"}
	FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Configura aRotina para Listas para OutBound.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If (TkPosto(TkOperador(),"U0_TIPOCTI")  == "2") .AND. (TkPosto(TkOperador(),"U0_TIPOATE") == "1") //CTI e Lista de OutBound 
		 aRotina := {}
		 aRotina := {		{ STR0001	,"AxPesqui"  	, 0 , 1} ,;		// "Pesquisar"
						  	{ STR0115	,"Tk062Lista" 	, 0 , 2} ,;		// "Visualizar"
							{ STR0003	,"Tk062Lista"	, 0 , 3} ,;		// "Incluir"
							{ STR0004	,"Tk062Altera"	, 0 , 4} ,;		// "Alterar"
							{ STR0005	,"Tk062Del"     , 0 , 5} ,;		// "Excluir"
							{ STR0008	,"Tk062Ativa" 	, 0 , 4} ,;		// "OutBound"
							{ STR0006	,"Tk062Imp" 	, 0 , 5} ,;		// "Imprimir"
							{ STR0118   ,"TK062Legenda"	, 0	, 3} } 		// "Legenda"
    
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU4")
	MBrowse(6, 1,22,75,"SU4",,,,,,aCores)
	
	//Finaliza o gerenciamento dos campos com proteção de dados.
	FATPDUnLoad()     
Endif
lRet := .T.
RestArea(aArea)

Return(lRet)  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas Clientes       ³ Data ³08/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:=	{		{ STR0001	,"AxPesqui"  	, 0 , 1 , , .F.} ,; //"Pesquisar"
					 	{ STR0115	,"Tk062Lista" 	, 0 , 2 , , .T.} ,; //"Visualizar"
						{ STR0003	,"Tk062Lista"	, 0 , 3 , , .T.} ,; //"Incluir"
						{ STR0004	,"Tk062Altera"	, 0 , 4 , , .T.} ,; //"Alterar"
						{ STR0005	,"Tk062Del"     , 0 , 5 , , .T.} ,; //"Excluir"
						{ STR0006	,"Tk062Imp" 	, 0 , 5 , , .T.} ,; //"Imprimir"
						{ STR0118   ,"TK062Legenda"	, 0	, 3 , , .T.} }	 // "Legenda"

Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK062Altera³Autor ³ Vendas Clientes       ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela validacao da entrada da alteracao de³±±
±±³          ³lista.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias: Alias da Rotina                  	              	  ³±±
±±³          ³nReg:   Registro posicionado          	              	  ³±±
±±³          ³nOpc:   Opcao selecionada             	              	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk062Altera(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A funcao ValAlt verifica se esta lista ja foi executada. ³
//³Em caso positivo a lista nao podera ser alterada.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk062ValAlt(cAlias,nReg,nOpc)
	Tk062Lista(cAlias,nReg,nOpc)
Else
	If !lA062Auto
		MsgStop(STR0131 ,STR0121) //"Esta lista já foi executada e não poderá ser modificada."###"ATENCAO"
	EndIf
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK062Del   ³Autor ³ Vendas Clientes       ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela validacao da exclusao de listas     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias: Alias da Rotina                  	              	  ³±±
±±³          ³nReg:   Registro posicionado          	              	  ³±±
±±³          ³nOpc:   Opcao selecionada             	              	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk062Del(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a lista nao foi executada pode ser feita a exclusao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk062ValAlt(cAlias,nReg,nOpc)
	Tk062Lista(cAlias,nReg,nOpc)
Else
	If !lA062Auto
		MsgStop(STR0132 ,STR0121) //"Esta lista já foi executada e não poderá ser excluida."###"ATENCAO"
	EndIf
Endif

Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk062Lista   ³ Autor ³ Vendas Clientes    ³ Data ³ 28/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta a tela principal do sistema com a opcao de entrada    ³±±
±±³          ³automatica e a TOOLBAR                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk062Lista(cAlias,nReg,nOpc)

Local oSayEnt			                    		// SAY "Entidade"
Local cNomEnt  	:= STR0009							// Nome da Entidade Selecionada //"Clientes"
Local oEnchoice         							// ITENS DA LISTA - GETDADOS
Local oDlg    										// Tela principal
Local oGet											// objeto da getdados
Local cCadastro := STR0010 							//"Atualiza‡„o das Listas" //"Atualização das Listas"
Local cFiltro 	:= ""								// Descricao do filtro generico
Local cEntidade	:= "SA1"							// Alias da entidade selecionada para gerar a lista
Local cPergunte	:= "TMKA062"						// Pergunte utilizada
Local cMensagem	:= Space(400) 						// Corpo do E-mail
Local cAssunto 	:= CriaVar("U4_ASSUNTO",.F.)		// Assunto do E-mail
Local cAttach  	:= ""								// Nome do arquivo Anexo do E-Mail
Local aAttach  	:= {}								// Array de arquivo ANEXO do e-mail
Local aPosObj   := {}								// Array para redimensionamento da tela
Local aObjects  := {}								// Array para redimensionamento da tela
Local aSize     := {}								// Array para redimensionamento da tela
Local aCampos 	:= Tk062RetU4Cmp(nOpc,cAlias,nReg)	// Array com todos os campos do SU4 - menos U4_TIPO
Local lRet      := .F.  							// Valida retorno da funcao
Local nT		:= 0
Local nTipo		:= 1							// Especifico para telecobranca. Se = 2 então monta lista diferente 
Local nChamadas := 0								// Especifico para telecobranca. Se > zero então monta lista diferente
Local nSaveSX8	:= GetSx8Len()						// Controle de numeracao da 8.11
Local cText		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nUsado       := 0
Private aCols        := {}
Private aHeader[0]
Private aValidGet    := {}
Private lA061Auto	 := Iif( lA062auto, .T., .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a regra de selecao permite gerar lista.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SK0")
DbSetOrder(1)
If MSSeeK(xFilial("SK0"))
	If !(SK0->K0_ORDEM == "000001" .AND. SK0->K0_PRAZO == "999999")
		Help(" ",1,"TK062NLIST")
		Return(lRet)
	Endif
Else
	Help(" ",1,"TK062NLIST")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa desta forma para criar uma nova instancia de variaveis private ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU4")
DbSetOrder(1)
RegToMemory( "SU4", IIF(nOpc == INCLUIR,.T., .F.) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao da rotina automatica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lA062auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, { 100, 025, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	If (nOpc <> INCLUIR)	
		AAdd( aObjects, { 100, 100, .T., .T. } )
	Endif
	
	aSize   := MsAdvSize()  		// Devolve o tamanho da tela atualmente no micro do usuario
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DbSelectArea("SU4")
	DbSetOrder(1)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] PIXEL

		// GroupBox
		@ aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3] ,aPosObj[1,4] LABEL '' OF oDlg  PIXEL

		// Botao da Entidade
		DEFINE SBUTTON FROM aPosObj[1,1]+6,aPosObj[1,2]+3 TYPE 5  ENABLE OF oDlg ONSTOP STR0011 ACTION (Pergunte("TMK062")) WHEN nOpc=INCLUIR //PARAMETROS //"Parâmetros do Cliente"

		DEFINE SBUTTON oBtnPrf FROM aPosObj[1,1]+6,aPosObj[1,2]+33 TYPE 11 ENABLE OF oDlg ONSTOP STR0012 ACTION (Pergunte("TMK060")) WHEN nOpc=INCLUIR //PERFIL DO CONTATO //"Perfil do Contato"

		// Say da Entidade
		@ aPosObj[1,1]+8 ,aPosObj[1,2]+70   SAY STR0013 OF oDlg PIXEL SIZE 250,16 //"Entidade : "
		@ aPosObj[1,1]+8, aPosObj[1,2]+100 SAY oSayEnt PROMPT cNomEnt OF oDlg PIXEL COLOR CLR_HRED SIZE 250,16
		
		// Enchoice com os dados
		M->U4_TELE := "3" // Somente telecobranca
		M->U4_TIPO := "2" // Cobranca
		
		oEnchoice := MSMGet():New( "SU4", nReg, nOpc, , , , ,aPosObj[2],aCampos,3,,,oDlg)
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao exibe a GETDADOS na inclusao.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nOpc <> INCLUIR)
			cFiltro		:= SU4->U4_FILTRO
			cMensagem   := IIF(!Empty(SU4->U4_CODMENS),MSMM(SU4->U4_CODMENS,80),Space(400))
			cAssunto    := SU4->U4_ASSUNTO
			cAttach     := SU4->U4_ATTACH
		Endif	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega o aCols com os itens do SU6³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nOpc <> INCLUIR)
			
			Processa({|| Tk062Itens(SU4->U4_LISTA,@cEntidade)},STR0014,,.T., nOpc) //"Operadores - Avaliação/Gravação automática"
			
			//Os itens da lista sempre devem ser apenas VISUALIZADOS
			oGet:= MsGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],2,"AlwaysTrue","AlwaysTrue","",.F.) 
			oGet:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],AlwaysTrue(),oGet:oBrowse:Refresh(.F.)}
			FATPDLogUser('TK062LISTA')
		
		Endif

		Tk062Perg(cEntidade,@cPergunte,.F.)
		
	ACTIVATE MSDIALOG oDlg ON INIT Tk062Bar(	nOpc,		oDlg,		@cFiltro	,@cEntidade	,;
												@cMensagem	,@cAssunto	,@aAttach	,@cAttach	,;
												@cPergunte	,@nChamadas	,@cNomEnt	,@oSayEnt	,;
												nSaveSX8,@nTipo)
											
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se as variaveis automaticas foram enviadas.         ³
	//³Estas variaveis irao simular os botoes padroes da ToolBar que³
	//³em alguns casos sao obrigatorios para execucao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If (nT := ASCAN(aAutoCab,{|x| x[1]='AUTENTIDADE'})) > 0
		cEntidade := aAutoCab[nT,2]
	Endif
	
	If cEntidade == "SA1"

	
		If (nT := ASCAN(aAutoCab,{|x| x[1]='AUTMENSAGEM'})) > 0
			cMensagem := aAutoCab[nT,2]
		Endif
		
		If (nT := ASCAN(aAutoCab,{|x| x[1]='AUTASSUNTO'})) > 0
			cAssunto := aAutoCab[nT,2]
		Endif
		
		If (nT := ASCAN(aAutoCab,{|x| x[1]='AUTATTACH'})) > 0
			cAttach := aAutoCab[nT,2]
		Endif
		
		If (nT := ASCAN(aAutoCab,{|x| x[1]='AUTFILTRO'})) > 0
			cFiltro := aAutoCab[nT,2]
		Endif
		
		If (nT := ASCAN(aAutoCab,{|x| x[1]='AUTPERG'})) > 0
			cPergunte := aAutoCab[nT,2]
		Endif
		
		If ! SU4->(MsVldGAuto(aValidGet)) // consiste os gets
			nOpc := 0
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se as variaveis para Cross Posting foram preenchidas e se for um³
		//³caso de alteracao preencho todas aquelas que nao vieram preenchidas.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc > 0 .AND. nOpc <> INCLUIR
			cFiltro	    := If(!Empty(cFiltro),cFiltro,SU4->U4_FILTRO)
			cMensagem   := IIF(!Empty(cMensagem),cMensagem,(IF(!Empty(SU4->U4_CODMENS),MSMM(SU4->U4_CODMENS,80),Space(400))))
			cAssunto    := If(!Empty(cAssunto),cAssunto,SU4->U4_ASSUNTO)
			cAttach     := If(!Empty(cAttach),cAttach,SU4->U4_ATTACH)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega o aCols com os itens do SU6³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| Tk062Itens(M->U4_LISTA,@cEntidade)},STR0014,,.T., nOpc)	 //"Operadores - Avaliação/Gravação automática"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao da rotina automatica que carrega o acols criado anteriormente com os dados 	 ³
		//³informados pelos arrays da rotina automatica. Esta funcao simula a inclusao dos dados ³
		//³no acols como se fosse executada pelo usuario.                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsAuto2Acols()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a validacao padrao para montagem do acols a partir do cabecalho.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 0 .OR. !SU6->(MsVldAcAuto(aValidGet,,,,nOpc,))   // consiste o campos do Acols
			nOpc := 0
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o retorno da funcao e gera log se necessario.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := Tk062Concluir(	nOpc		,cEntidade		,@cMensagem		,@cAssunto	,;		
								@aAttach	,@cAttach		,@cFiltro		,@cPergunte	,;
								@cText		,0				,@nChamadas		,0			,;
								nSaveSX8,@nTipo )
								
	Else
		lRet := .F.	
	Endif						
	
	If !lRet
		//"Nao ha nenhum contato valido para a regra informada. Verifique a seleção do tipo de contato e a coerência dos dados.Ex: Lista de Voz, contato:Fax, telefone de fax do contato informado não esta preenchido."
		//"Nao h  nenhum contato valido para a regra informada. Verifique a sele‡„o do tipo
		//de contato e a coerencia dos dados.Ex: Lista de Voz, contato:Fax, telefone de fax
		//do contato informado n„o esta preenchido."
		AutoGRLog(STR0015) 
		DbSelectArea("SU4")
		RollBackSX8()
	Endif
	Return(lRet)
Endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk062Bar  ³ Autor ³ Vendas Clientes       ³ Data ³30/06/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk062Bar(nOpc		,oDlg		,cFiltro	,cEntidade	,;
						 cMensagem	,cAssunto	,aAttach	,cAttach	,;
						 cPergunte	,nChamadas	,cNomEnt	,oSayEnt	,;
						 nSaveSX8,nTipo)
						 
						 
Local aArea	   := GetArea()     // Salva a area atual
Local aButtons := {}			// Botoes adicionais
Local cText    := CRLF 			// Variavel com os textos para help da Lista de Contatos
Local nHandle  := 0    			// CRIA ARQUIVO READ ONLY DE LOG PARA SU4
Local nPeriod  := 0				// Periodo de ligações

AAdd(aButtons,{ "FILTRO"	, {|| Tk062Filtro(nOpc,@cFiltro,cEntidade,cPergunte)			}, STR0016	, STR0113 })	// "Cria expressões de filtros para seleção dos dados", "Filtro"
AAdd(aButtons,{ "EDITABLE"	, {|| Tk062EMail(nOpc,@cMensagem,@cAssunto,@aAttach,@cAttach)	}, STR0112	, STR0114 })	// "Define e-mail para geração da lista", "E-mail"
AAdd(aButtons,{ "VERNOTA"	, {|| Tk062Visual()                               				}, STR0002	, STR0115 })	// "Visualizar a lista de cobrança", "Vizualiza"
AAdd(aButtons,{ "BMPORD"	, {|| Tk062LCob(@nChamadas,@cNomEnt,@oSayEnt,@nTipo)   				}, STR0017	, STR0116 })	// "Define detalhes da geração da lista de cobrança", "Detalhes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida o acesso a Lista de Periodicidade.  ³
//³U0_PERIODO = 2  - Lista por Ultimo Contato.³
//³Disponivel somente para inclusao de Listas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TkPosto(TkOperador(),"U0_PERIODO") == "2" .AND. nOpc == INCLUIR
	AAdd(aButtons, { "HISTORIC" , {|| Tk062Period(@nPeriod,nOpc) }, STR0018, STR0117 } )	  //"Lista de Periodicidade", "Período"
Endif	

EnchoiceBar(oDlg,{|| IIF(Tk062Concluir(	nOpc		,cEntidade	,@cMensagem		,@cAssunto	,;	// Botao de OK
										@aAttach	,@cAttach	,@cFiltro		,@cPergunte	,;
										@cText		,nPeriod	,@nChamadas		,nHandle	,;
										nSaveSX8,@nTipo)	,;
						oDlg:End(),Tk062Help(@cText,nHandle)) },;
				 {||Tk062Fim(nSaveSX8),oDlg:End()},,aButtons)		 								// Botao de CANCELA																										


RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK062PerioºAutor  ³ Vendas Clientes    º Data ³  31/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para definir a lista de periodicidade.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk062Period(nPeriod,nOpc)
Local oDlg				// Dialogo para a apresentacao da janela de periodicidade
Local oPanel			// Objeto panel onde estao as informacoes
Local oPeriod			// Objeto checkbox que define a selecao do periodo.
Local lOk		:= .F. // Controle para armazenamento de informacoes.

If nPeriod == 1 	// SIM
	lOk := .T.
Endif

DEFINE MSDIALOG oDlg TITLE STR0019 FROM 0,0 TO 182,400 PIXEL OF oMainWnd	 //"Configuração da lista de Periodicidade"

	EnchoiceBar(oDlg, {|| (oDlg:End()) }, {|| oDlg:End()},,,,,.F.,.F.,.F.,.T.,.F.)	

	@ 35,02 MSPANEL oPanel PROMPT "" SIZE 195,050 OF oDlg CENTERED LOWERED
	@ 03,05 SAY STR0020 OF oPanel PIXEL SIZE 150,20  //"Selecione se a lista será ou não pelo último registro de contato."
	@ 25,10 CHECKBOX oPeriod VAR lOk SIZE 150,10 PIXEL OF oPanel PROMPT STR0021 WHEN (nOpc == INCLUIR) //"Avalia a data do último atendimento para cada contato."

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc == INCLUIR
	If !lOk
		nPeriod := 2 // NAO
	Else
		nPeriod := 1
		M->U4_PERIOD := "1" // Campo onde será armazenado flag para lista de periodicidade. 
	Endif
Endif

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK062LCob ºAutor  ³ Vendas Clientes    º Data ³  31/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para definir os detalhes da lista de cobranca.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk062LCob(nChamadas,cNomEnt,oSayEnt,nTipo)
Local oTipo												// Objeto para o tipo de selecao
Local oChamadas											// Objeto para insersão do total de cahmadas
Local lChamadas			:= IIF(nChamadas==0,.F.,.T.)	// Controle de acesso ao campo.
Local aArea				:= GetArea()					// Salva area para seguranca do codigo.
Local oDlgTLC											// Dialogo principal

If nChamadas < 0
	nChamadas := 0
Endif

nTipo := IIF(nChamadas==0,1,2)		// Controle do objeto para selecao do tipo

DEFINE MSDIALOG oDlgTLC FROM 000,000 TO 230,540 TITLE STR0022 PIXEL OF oMainWnd		//  //"Tipo de lista de TELECOBRANÇA"

		TSay():New(10,10,{|| STR0023 },oDlgTLC,,,,,,.T.,CLR_BLUE,CLR_WHITE)		//  //"Selecione o tipo de lista de Telecobrança a ser gerada."
		@ 20,10 To 090,260 LABEL "" OF oDlgTLC PIXEL
		@ 30,20 RADIO oTipo VAR nTipo;
				ITEMS	STR0024 ,; //"Gerar lista padrão de telecobrança para inadimplentes (recomendado)"
						STR0025; //"Gerar lista de telecobrança considerando as ligações já realizadas aos inadimplentes"
				SIZE 220,15 PIXEL OF oDlgTLC;
				ON CLICK (	lChamadas := IIF(nTipo==2,.T.,.F.),;
							nChamadas := 0,;
							oChamadas:Refresh(),;
							oChamadas:SetFocus(),;
							oTipo:SetFocus() )
		
		@ 65,30 MSGET oChamadas VAR nChamadas SIZE 15,10 PICTURE '99' WHEN lChamadas OF oDlgTLC PIXEL
		TSay():New(67,55,{|| STR0026 },oDlgTLC,,,,,,.T.,CLR_BLACK,CLR_WHITE)		//  //"Número de chamada(s) a ser(em) considerada(s)."
		
		DEFINE SBUTTON FROM 095,230 TYPE 1 ENABLE OF oDlgTLC ACTION (nChamadas:=IIF(!lChamadas,-1,nChamadas), oDlgTLC:End())
		
	ACTIVATE MSDIALOG oDlgTLC CENTERED

	// " no(s) título(s) com atraso." 
	// " inadimplentes com " 
	// " cobrança(s)" 
	// " nenhuma cobrança" 
	cNomEnt := STR0009 + IIF(nChamadas>=0,STR0027+IIF(nChamadas>0,Str(nChamadas,2)+STR0028,STR0029) + STR0030,"") //"Clientes"###" inadimplentes com "###" cobrança(s)"###" nenhuma cobrança"###" no(s) título(s) com atraso."
    oSayEnt:Refresh()

RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk062Filtro³ Autor ³ Vendas Clientes       ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Filtro generico do AP6 para a entidade escolhida             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk062Filtro(nOpc,cFiltro,cEntidade,cPergunte)
Local oWnd		 := GetWndDefault()
Local cDesc 	 := "" 					// Descricao do SX5
Local lRet 		 := .F.					// Retorno da funcao
Local cDescFiltro:= ""					// Conteudo do filtro
Local oDlgFiltro						// Dialog para apresentacao do filtro
Local oDescFiltro						// Objeto com a selecao do filtro



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao existir alias definido nao permite a selecao do filtro ³
//³que e por entidade.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cEntidade)
	Help(" ",1,"TK061NOSEL")//"Informe a selecao dos clientes ou prospects !"
	Return(.F.)
Endif

cDescFiltro := IIF(!Empty(cFiltro),MontDescr(cEntidade,cFiltro),"")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual a forma de contatos sera feita  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (M->U4_FORMA == "1")//voz
		cLista:= STR0031 // //"Voz"
	Case (M->U4_FORMA == "2")//fax
		cLista:= STR0032 // //"Fax"
	Case (M->U4_FORMA == "3")//Cross Posting
		cLista:= STR0033 // //"Cross Posting"
	Case (M->U4_FORMA == "4")//Mala Direta
		cLista:= STR0034 // //"Mala Direta"
EndCase

DbSelectArea("SX5")
DbSetOrder(1)
If MSSeeK(xFilial("SX5") + "T5" + cEntidade)
	cDesc := X5Descri()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a descricao da selecao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgFiltro FROM  00,00 TO 200,310 TITLE STR0035 PIXEL  // //"Filtro"

	@02,02 TO 75,153 LABEL STR0036 OF oDlgFiltro PIXEL    //"Descricao do Filtro" //"Descrição do Filtro"
	@10,05 MSGET oDescFiltro VAR cDescFiltro PICTURE "@!" SIZE 145,60 OF oDlgFiltro PIXEL COLOR CLR_RED WHEN .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro para a selecao dos registros da entidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SBUTTON FROM 80,55  TYPE 17 ENABLE OF oDlgFiltro ACTION (lRet:=.T.,;
																	cFiltro  := BuildExpr("SE1",oWnd),;
																	cDescFiltro := MontDescr("SE1",cFiltro),;
																	oDescFiltro:Refresh()) WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR)//Monta o filtro
																	
	DEFINE SBUTTON FROM 80,90  TYPE 1 ENABLE OF oDlgFiltro ACTION oDlgFiltro:End() //Fecha a tela e mantem o filtro
	
	DEFINE SBUTTON FROM 80,125 TYPE 2 ENABLE OF oDlgFiltro ACTION (	lRet:=.F.,;
																	cDescFiltro:="",;
																	oDescFiltro:Refresh(),;
																	oDlgFiltro:End())// Cancela o filtro
																
ACTIVATE MSDIALOG oDlgFiltro CENTERED

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK062EMail   ³ Autor ³ Vendas Clientes    ³ Data ³05/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o e-mail para Cross-Posting                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk062Email(nOpc,cMensagem,cAssunto,aAttach,cAttach)

Local oDlgMens
Local oMens
Local oSubj
Local oAttach
Local cMens   := Space(400)
Local cSubj   := CriaVar("U4_ASSUNTO",.F.)
Local nOpcao  := 0
Local aArq    := {}
Local lRet    := .F.
Local cAux	  := ""
Local nX	  := 0

If M->U4_FORMA <> "3" //Cross Posting
	Help( " ", 1, "TK061EMAIL" )
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a tela para a digitar a mensagem que sera enviada   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMens   := cMensagem
cSubj   := cAssunto
aArq    := aAttach
aAttach	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o array que contem os arquivos anexados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 To Len(cAttach)
	If SubStr(cAttach,nX,1) <> Chr(10) .AND. SubStr(cAttach,nX,1) <> ";"
		cAux += SubStr(cAttach,nX,1)
	Else
        If !Empty(cAux)
        	Aadd(aAttach,cAux)
        	cAux := ""
        Endif	
	EndIf
Next nX	
aArq := aAttach

DEFINE MSDIALOG oDlgMens FROM 05,2 TO 350,530 TITLE STR0037 PIXEL  // //"Composicao de E-Mail"

	@ 02, 04 TO  25,260 OF oDlgMens PIXEL
	@ 09, 08 SAY STR0038	OF oDlgMens SIZE 40,8 PIXEL  //"Assunto"
	@ 09, 32 GET oSubj VAR cSubj	OF oDlgMens SIZE 225,8 PIXEL WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR)
	
	@ 27, 04 TO 120,260 LABEL STR0039 OF oDlgMens PIXEL  //"Mensagem"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for inclusão ou alteração o usuário pode editar o MEMO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpc == INCLUIR .OR. nOpc == ALTERAR)
		@ 33, 06 GET oMens VAR cMens OF oDlgMens MEMO SIZE 250,83 PIXEL WHEN .T.
	Else
		@ 33, 06 GET oMens VAR cMens OF oDlgMens MEMO SIZE 250,83 PIXEL READONLY
	Endif
		
	@ 122,04 TO 156,260 LABEL STR0040 OF oDlgMens PIXEL  //"Anexos"
	@ 128,06 GET oAttach VAR cAttach OF oDlgMens MEMO SIZE 250,25 PIXEL READONLY
	
	DEFINE SBUTTON FROM 160 ,170 TYPE 4 PIXEL ACTION (Tk062Anexo(@aArq,@oAttach,@cAttach)) ENABLE OF oDlgMens WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR)
	DEFINE SBUTTON FROM 160 ,202 TYPE 1 PIXEL ACTION (nOpcao:=1,IIF(Tk062ValEmail(cSubj,cMens), oDlgMens:End(),"")) ENABLE OF oDlgMens
	DEFINE SBUTTON FROM 160 ,234 TYPE 2 PIXEL ACTION (nOpcao:=2,oDlgMens:End()) ENABLE OF oDlgMens
	

ACTIVATE MSDIALOG oDlgMens CENTERED

If (nOpcao == 1)
	lRet     := .T.
	cMensagem:= cMens
	cAssunto := cSubj
	aAttach  := aArq
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk062Anexo   ³  Autor  ³ Vendas Clientes       ³ Data ³05/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o Anexo de arquivos para o email                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk062Anexo(aArq,oAttach,cAttach)

Local nPos   := 0
Local nCont  := 0

cAttach:= Tk062Arquivo(1)

//Adiciona no array o nome do arquivo a ser enviado como attach no email
nPos:= ASCAN(aArq,cAttach)
If (nPos > 0)
	aArq[nPos]:= cAttach
Else
	Aadd(aArq,cAttach)
Endif

cAttach:= ""
For nCont := 1 To Len(aArq)
	If !Empty(aArq[nCont])
		cAttach+= aArq[nCont] + Chr(10)
	EndIf
Next nCont

oAttach:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK062Arquivo ³ Autor ³ Vendas Clientes    ³ Data ³02/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abre uma janela do tipo "Open File" para selecao de arquivo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk062Arquivo(nTipo)

Local cRetAux := ""
Local cTipoArq:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe a tela para a selecao de arquivos de acordo com³
//³cada forma de contato.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nTipo == 1)
	Do Case
		Case M->U4_FORMA == "2" //Fax
			cTipoArq 	  := STR0041 // //"Arquivos Texto (*.TXT)     | *.TXT | "
			cTipoArq 	  += STR0042 // //"Arquivos Tif   (*.TIF)     | *.TIF | "
			cRetAux  	  := cGetFile(cTipoArq,STR0043,0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) // //"Escolha o arquivo de FAX"
			M->U4_MALADIR := cRetAux//SubStr(cRetAux,RAT("\",cRetAux) + 1,Len(cRetAux))
			
		Case M->U4_FORMA == "3" //Cross-Posting
			cTipoArq 	  := STR0044 // //"Todos os Arquivos (*.*)     | *.* | "
			cRetAux  	  := cGetFile(cTipoArq,STR0045,0,,.T.,GETF_ONLYSERVER) // //"Escolha os anexos do Email"
			M->U4_MALADIR := cRetAux//SubStr(cRetAux,RAT("\",cRetAux) + 1,Len(cRetAux))
			
		Case M->U4_FORMA == "4" //Mala Direta
			cTipoArq 	  := STR0046 // //"Modelo de Documento (*.DOT)     | *.DOT | "
			cRetAux  	  := cGetFile(cTipoArq,STR0047,0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) // //"Escolha o arquivo de Mala Direta"
			M->U4_MALADIR := cRetAux
	Endcase
	
Else
	
	If (M->U4_FORMA == "4") //Mala Direta
		cTipoArq 	  := STR0046 // //"Modelo de Documento (*.DOT)     | *.DOT | "
		cRetAux  	  := cGetFile(cTipoArq,STR0048,0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) // //"Escolha o arquivo de Etiquetas"
		M->U4_ETIQUET := cRetAux
	Endif
Endif

If M->U4_FORMA == "1"
	Help(" ",1,"TK061NOVOZ")		
Endif

Return(cRetAux)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk062ValEmail³Autor  ³ Vendas Clientes    ³ Data ³05/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o assunto e a mensagem do e-mail                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk062ValEmail(cSubj,cMens)
Local lRet:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se foi digitada o assunto.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cSubj)
	Help(" ",1,"SEMASSUNTO")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se foi digitada alguma mensagem.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cMens)
		Help(" ",1,"SEMMENSAGE")
	Else
		lRet := .T.	
	Endif
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk062Visual³ Autor ³ Vendas Clientes       ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe o arquivo de MALA-DIRETA e o de ETIQUETAS              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk062Visual()
Local oDlg
Local aOpcoes   := {STR0034,STR0049}	// Array com os tipos de arquivos   //"Mala Direta"###"Etiqueta"
Local nOpca     := 0										// Opcao do botao
Local nArquivo  := 1
Local oArquivo
Local lRet      := .F.

If M->U4_FORMA <> "4"// Mala direta
	Help(" ",1,"TK061TPMAL") //O tipo nao e mala direta. Selecione o tipo Mala direta.
	Return(lRet)
Endif


DEFINE MSDIALOG oDlg FROM  00,00 TO 100,260 TITLE STR0050  PIXEL OF oMainWnd //"Visualizacao de Arquivos" //"Visualização de Arquivos"

	@ 02,02 TO 50,85 LABEL "" OF oDlg PIXEL
	
	@ 06,04 RADIO oArquivo VAR nArquivo PROMPT aOpcoes[1],aOpcoes[2] OF oDlg SIZE 80,20 DESIGN 3D PIXEL
	
	DEFINE SBUTTON FROM 05,95 TYPE 1 ENABLE OF oDlg ACTION (nOpca:= 1, oDlg:End())
	
	DEFINE SBUTTON FROM 25,95 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
	

ACTIVATE MSDIALOG oDlg CENTERED

If (nOpca == 1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a escolha foi mala direta verifica se o arquivo foi selecionado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nArquivo == 1)
		If !Empty(M->U4_MALADIR)
			Tk062ExibeArquivo(M->U4_MALADIR)
		    lRet := .T.
		Else
			Help(" ",1,"TK061VISMA")//("Selecione o arquivo de mala direta para visualizacao")
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a escolha foi etiqueta verifica se o arquivo foi selecionado.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->U4_ETIQUET)
			Tk062ExibeArquivo(M->U4_ETIQUET)
			lRet := .T.
		Else
			Help(" ",1,"TK061VISET") //("Selecione o arquivo de etiqueta para visualizacao")
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK062ConcluirºAutor ³ Vendas Clientes     º Data ³ 09/08/01  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica qual rotina sera executada na confirmacao		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk062Concluir(	nOpc,		cEntidade,	cMensagem	,cAssunto	,;
								aAttach,	cAttach,	cFiltro		,cPergunte	,;
								cText		,nPeriod	,nChamadas	,nHandle	,;
								nSaveSX8,nTipo)								
Local lRet	:= .F.
Local bBlockList

Do Case
	Case (nOpc == VISUAL) //Visualizacao
		lRet:= .T.
		
	Case (nOpc == INCLUIR) .OR. (nOpc == ALTERAR) //Inclusao ou Alteracao
		
		// Chama a funcao padrao de geraca da lista
		bBlockList := "{||Tk062ExecRegua(nOpc,cEntidade,@cMensagem,@cAssunto,@aAttach,@cAttach,@cFiltro,@cPergunte,@cText,nPeriod,nChamadas,nHandle,nSaveSX8,nTipo)}"
		
		lRet := Eval(&bBlockList ) // Executa a funcao que ira gravar a lista
		
	Case (nOpc == EXCLUIR)
		lRet:= Tk062Excluir()
Endcase

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk062ExecRegua ³ Autor ³ Vendas Clientes       ³ Data ³ 10/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Permite a exibicao da barra de progresso na geracao da Lista.    ³±±
±±³          ³Esta funcao complementar foi criada devido a necessidade de uma  ³±±
±±³          ³barra de progressao e porque sua chamada e proveniente de um 	   ³±±
±±³          ³bloco. A funcao Tk062MontaLista recebe o parametro lRet pois a   ³±±
±±³          ³funcao processa nao possui retorno logico.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk062ExecRegua(	nOpc,		cEntidade,	cMensagem	,cAssunto	,;
							aAttach,	cAttach,	cFiltro		,cPergunte	,;
							cText,		nPeriod,   nChamadas	,nHandle	,;
							nSaveSX8,nTipo)
							   
Local lRet := .F. 	// Variavel de retorno da função monta Lista
Local lEnd := .F.	// Controle da interrupcao da geracao da lista de cobranca.

Processa({|lEnd|TK062MontaLista(nOpc,		cEntidade	,@cMensagem	,@cAssunto	,;
							@aAttach,	@cAttach	,@cFiltro	,@cPergunte	,;
							@cText,		@lRet		,nPeriod	,@lEnd		,;
							nChamadas,	nHandle		,nSaveSX8, nTipo)},;
			STR0022,,.T.)    
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk062Perg      ³ Autor ³ Vendas Clientes       ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa as perguntes para a selecao das entidades.	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk062Perg(cEntidade,cPergunte,lShow,nTpLista)

Default lShow  	:= .T.
Default nTpLista:= 0

If Empty(cEntidade)
	Help(" ",1,"TK061NOSEL")//"Informe a selecao dos clientes ou prospects !"
Else
			
	cPergunte := "TMK062"
	Pergunte(cPergunte,lShow) 

Endif
	
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk062MontaLista ³Autor  ³ Vendas Clientes ³ Data ³10/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta a selecao e faz a gravacao do SU4 e do SU6            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lista de Inadimplentes (TeleCobranca)		   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK062MontaLista(nOpc		,cEntidade	,cMensagem	,cAssunto	,;
								aAttach		,cAttach	,cFiltro	,cPergunte	,;
								cText		,lRet		,nPeriod	,lEnd		,;
								nChamadas	,nHandle	,nSaveSX8,nTipo)

Local aLista	:= {}									// Array com os registros do SU6
Local lGrava	:= .F.									// Flag para continuar a gravacao
Local cTel		:= ""  									// Telefone do Contato (Comercial, Residencial, Celular, etc....)
Local cTextAux  := ""   								// Auxilia na geracao das mensagens de help
Local cSelOper  := ""   								// Selecao automatica do operador.
Local nRecAtu	:= 0									// Variavel para contador do Meter - Numero do registro que esta sendo avaliado.
Local nRecTot	:= 0  									// Variavel para contador do Meter - Total de registros para avaliacao.
Local lQuery    := .F.									// Controle de query

//Pergunte do CONTATO
Local cMv_Par01   										//Nivel do Contato						
Local cMv_Par02                                    	    //Perfil do Contato
Local cMv_Par03                                         //Ligacoes Pendentes
Local cMv_Par04                                         //A partir de quando
Local cMv_Par05                                         //Ignora Dias Semana

//Pergunte da ENTIDADE
Local ceMv_Par01  										//Do Prefixo
Local ceMv_Par02										//Ate o Prefixo
Local ceMv_Par03										//Do Titulo
Local ceMv_Par04										//Ate o Titulo
Local ceMv_Par05										//Do Banco
Local ceMv_Par06										//Ate o Banco
Local ceMv_Par07										//Do Vencimento
Local ceMv_Par08										//Ate o Vencimento
Local ceMv_Par09										//Da Natureza	
Local ceMv_Par10										//Ate a Natureza
Local ceMv_Par11										//Da Emissao
Local ceMv_Par12										//Ate a Emissao
Local ceMv_Par13										//Situacao do titulo

Local lGrvCab  :=.F. 									//Flag que identifica se o cabecalho da lista ja foi gravado.
Local cU6HrIni := CriaVar("U6_HRINI",.T.)  
Local cU6HrFim := CriaVar("U6_HRFIM",.T.)

Local aAreaSx3	:= GetArea("SX3")
Local aAreaSK1	:= GetArea("SK1")
Local nErase	:= 1 									// Controla a delecao do arquivo
Local lLog		:= .F.									// Flag para utilização de log de base. Inibe o select em SQL.
Local cAntOper	:= ""									// Verifica  o opearador anterior para gravacao correta.
Local cCodCont	:= ""									// Codigo do contato de COBRANCA
Local cCodEnt	:= ""									// Codigo da Entidade no tratamento de contatos de COBRANCA
Local cTipo		:= UPPER(GetNewPar("MV_TMKCOBR","")) 	// Contem os tipos de titulos que devem ser utilizados para cobranca
Local cSep		:= ""     								// Separador dos tipos de titulo utilizado na select 
Local nAux			:= 0
Local aOldAC8		:= {}
Local aOldAreAtv	:= {}

Local cFieldSK1	 := ""	
Local cWhrInAC8	 := ""
Local cQAC8XSK1	 := ""
Local cQuery											// Query
Local cQryTot											// Query para totalizador
Local aStruct1	:= {}								// Array com a estrutura da tabela AC8 para execucao do TcSetField - Somente para SQL 
Local aStruct2	:= {}								// Array com a estrutura da tabela AC8 para execucao do TcSetField - Somente para SQL 
Local nI			:= 0								// Contador
Local nTipo3		:= 0								// Contador de contatos do tipo COBRANCA
Local cAbat		:= ""								// Contem os tipos de abatimento que nao sao considerados na selecao dos titulos vencidos
Local cQryWhr		:= ""								// clausula where da tabela SK1, SE1 e ACG (para o BEGINSQL)
Local cQryWhrTit	:= ""								// clausula where da tabela SK1, SE1 e ACG (para o BEGINSQL)
Local cAliasTmp	:= GetNextAlias()
Local cAliasAC8	:= GetNextAlias()
Local cDataBase := AllTrim(Upper(TcGetDb()))
Local lSQL 		:= !(Upper(TcSrvType())$"AS/400%ISERIES") .And. !(cDataBase $ "DB2|INFORMIX")
Local lSU5Valid	:= .F.

Local cAvalFirst	:= GetNewPar("MV_TMKALST","1")		// Determina se analisa primeiro os titulos inadimplentes do contato de acordo com os parametros da pergunte TMK062. 1-Contato 2-Titulos Inadimplentes, 3-Somente contatos inadimplentes.
Local lTmkConout  	:= GetNewPar("MV_TMKLOG" ,.F.)		// Ativa o log que sera realizado via conout no server	
Local lValido		:= .T.								// Indica se o contato atende aos filtros informados pelo usuários
Local cFiltroAux	:= ""								// Armazena o filtro original
Local lTmkList 		:= GetNewPar("MV_TMKLIST" ,.F.)		//Determina não utilização de contatos ja presente em lista de cobrança ativa/ em andamento
Local lTk062SU5		:= ExistBlock("TK062SU5")			//Ponto de entrada utilizado para filtrar os registros da tabela SU5
Local lTk062SE1		:= ExistBlock("TK062SE1")			//Ponto de entrada utilizado para filtrar os registros da tabela SE1
Local lTk062SA1		:= ExistBlock("TK062SA1")			//Ponto de entrada utilizado para filtrar os registros da tabela SA1
Local lTk062SK1		:= ExistBlock("TK062SK1")			//Ponto de entrada utilizado para filtrar os registros da tabela SK1
Local lSimultaneo		:= TkPosto(TkOperador(),"U0_VALCONT") == "2"

Local cFlt_SU5		:= ""
Local cFlt_SE1		:= ""
Local cFlt_SA1		:= "" 
Local cFlt_SK1		:= ""

Local cFiltroSE1		:= ""
Local cConcat			:= ""	

Local cFilSA1			:= xFilial("SA1")
Local cFilACG			:= xFilial("ACG")  
Local cFilAC8			:= xFilial("AC8")
Local cFilSK1			:= xFilial("SK1")
Local cFilSU4			:= xFilial("SU4")
Local cFilSU5			:= xFilial("SU5")
Local cFilSU6			:= xFilial("SU6")
Local cFilSE1			:= xFilial("SE1")
Local cFilSUC			:= xFilial("SUC")
Local cFilEntidade	:= xFilial(cEntidade)

Local nProgresso		:= 0
Local nTamNum			:= 0 // quantidade de digitos existentes no total de registros da AC8
Local cSQLPart			:= ""
Local nProcTempo 		:= 0 // variavel temporaria

Local oTmpTblSK1		:= NIL
Local oTmpTblSU6		:= NIL
Local oTmpTblSUC		:= NIL

Local aStrTblSK1		:= {}
Local aStrTblSU6		:= {}
Local aStrTblSUC		:= {}

Local cArqLog			:= "TMKSU4LISTA_" + AllTrim(cEmpAnt) + AllTrim(cFilAnt) + ".LOG"

// declaracao de variáveis private
private cTblSK1 := GetNextAlias()
private cTblSU6 := GetNextAlias()
private cTblSUC := GetNextAlias()

If ! lSQL
	cAliasAC8	:= "AC8"
EndIf

nProcTempo := Seconds()
If	lTmkConout
	TmkConout("TK062MontaLista() v04-" + STR0134 + ": " + AllTrim(Str(ThreadID())) + " - " + DTOC(DATE()) + " " + TIME(), "TkMontaLista()")	//"INÍCIO-TOTVS THREAD"
EndIf

//Retira as aspas do conteúdo do parâmetro.
cAvalFirst := AllTrim(Replace(cAvalFirst,'"',''))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso exista documento na base gerado pela execucao de³
//³lista anterior. Apaga arquivo. Esta validacao pode   ³
//³impedir a geracao de duas listas simultaneas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File(cArqLog)
	nHandle := FCREATE(cArqLog,1)
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a delecao do arquivo para geracao de novo log³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nErase := FERASE(cArqLog)   
	
	While nErase = -1 
		nErase := FERASE(cArqLog)
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria novo Log³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHandle := FCREATE(cArqLog,1)
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao para alterar a variavel lGrvCab
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If ExistBlock("TK062LGr")
	lGrvCab := ExecBlock("TK062LGr", .F., .F.,{lGrvCab})
	If ValType(lGrvCab) <> "L"
       lGrvCab := .F.
	EndIf
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica lista no arquivo de Log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(2)
MSSeeK("U4_LISTA")
cText += X3TITULO()+" : "+ M->U4_LISTA + "  "	+ CRLF

MSSeeK("U4_DESC")
cText += X3TITULO()+" : "+ M->U4_DESC + "  "+ CRLF

MSSeeK("U4_DATA")
cText += X3TITULO()+" : "+ DTOC(M->U4_DATA )+ "  "+ CRLF

RestArea(aAreaSx3)

cText += CRLF+CRLF + STR0051 + CRLF+CRLF //"Falhas encontradas no processo de seleção da Base de Dados."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para a utilizacao de log em  SQL.     ³
//³Caso seja definida a utilização de log a selecao ³
//³sera efetuada em Advpl.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lA062AUTO
	#IFDEF TOP
		lLog := TmkOk(STR0052+CRLF+STR0053) //"Habilita log de registros ?"###" A utilização do registro de log implicará em um processo de seleção mais lento."
		
		If !lLog
			cText += STR0054+CRLF //"Dados da base não condizem com os parâmetros informados. Não foi definida a geração de log pelo usuário. "
		Endif	
	#ENDIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se as informacoes necessarias estao preenchidas												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo <> 73//SIGACRM
	If Empty(M->U4_TIPO)
		Help(" ",1,"TK061SEL")  //"Informe o tipo de selecao !"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK062Write(@cText,nHandle)
		cText += STR0055 +  CRLF // //"O tipo de Seleção não foi informado.  Informar o Tipo de seleção em: Botão Entidades, Tipos: Marketing, Cobrança e Vendas. "
		TK062Write(@cText,nHandle,.T.)
		Return(lRet)
	Endif
	
	If Empty(M->U4_FORMA)
		Help(" ",1,"TK061NCONT")//"Informe o contato !"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK062Write(@cText,nHandle)
		cText += STR0056+  CRLF // //"O campo 'Tipo Contato' não foi informado. "
		TK062Write(@cText,nHandle,.T.)
		Return(lRet)
	Endif
	
	If Empty(cEntidade)
		Help(" ",1,"TK061NOSEL")//"Informe a selecao dos clientes ou prospects !"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK062Write(@cText,nHandle)
		cText += STR0057+  CRLF // //"A entidade não foi selecionada. Utilize o Botão Entidade. "
		TK062Write(@cText,nHandle,.T.)
		Return(lRet)
	Endif 
EndIf

If !lA062Auto
	If Empty(cPergunte)
		Help(" ",1,"TK061PERFI")  //Informe o perfil da entidade .
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TK062Write(@cText,nHandle)
		cText += STR0058+  CRLF // //"O perfil do contato não foi selecionado. Utilize o Botão Entidade. "
		TK062Write(@cText,nHandle,.T.)
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1- Verifica se é rotina automatica.                                                           ³
//³																							     ³
//³	Caso NAO seja rotina automatica verifica o parametro                                         ³
//³	e SE for selecao manual avalia o operador, Se For selecao automatica                         ³
//³	seleciona  o operador de acordo com o menor numero de tarefas.                               ³ 
//³                                                                                              ³
//³	Caso SEJA rotina automatica avalia se o operador esta vazio pois este é preenchido           ³
//³	em memoria. Caso vazio gera o operador de acordo com o menor numero de tarefas senao mantem  ³
//³	o operador informado.                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lA062Auto
	If Empty(M->U4_OPERAD)
	    If TmkOk(STR0059) //"Deseja efetuar a seleção automática do operador?"
			cSelOper := Tk062SelOper()
		Else
			Help(" ",1,"SEMOPERADO")  //Informe o operador para este tipo de contato .
			Return(lRet)
		Endif	

	ElseIf !Empty(M->U4_OPERAD)
		cSelOper := (M->U4_OPERAD) 
    Endif
Else
	If Empty(M->U4_OPERAD) 
		cSelOper := Tk062SelOper()
	Else
		cSelOper := (M->U4_OPERAD) 
	Endif
Endif	

If Empty(cSelOper) 
	Help(" ",1,"SEMOPERADO")  //Informe o operador para este tipo de contato .
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK062Write(@cText,nHandle)
	cText += STR0060 + STR0061 +  CRLF // // //"O Operador não foi informado. "###" Verifique se existem operadores para a Rotina informada. "
	TK062Write(@cText,nHandle,.T.)
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a forma de contato.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (M->U4_FORMA == "1")   //Voz
		If Empty(M->U4_TIPOTEL)
			Help(" ",1,"TK061TEL")	//"Informe o tipo do telefone !"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TK062Write(@cText,nHandle)
			cText += STR0062+  CRLF // //"Tipo do Telefone não informado."
			TK062Write(@cText,nHandle,.T.)
			Return(lRet)
		Endif
		
	Case (M->U4_FORMA == "2")   //Fax
		If Empty(M->U4_MALADIR)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        	TK062Write(@cText,nHandle)
        	cText += STR0063+  CRLF // //"Arquivo de Fax não informado."
			Help(" ",1,"TK061SFAX")//"Informe o arquivo de fax !"
			TK062Write(@cText,nHandle,.T.)
			Return(lRet)
		Endif
		
	Case (M->U4_FORMA == "3")  //Cross-Posting
		If Empty(cAssunto)
			Help(" ",1,"SEMASSUNTO")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TK062Write(@cText,nHandle)
			cText += STR0064+  CRLF // //"Assunto do e-mail não informado."
			TK062Write(@cText,nHandle,.T.)
			Return(lRet)
		ElseIf Empty(cMensagem)
			Help(" ",1,"SEMMENSAGE")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TK062Write(@cText,nHandle)
			cText += STR0065+  CRLF // //"Mensagem do e-mail não informada."
			TK062Write(@cText,nHandle,.T.)
			Return(lRet)
		Endif
		
	Case (M->U4_FORMA == "4")  //Mala-Direta
		
		If Empty(M->U4_MALADIR) .OR. (Upper(SubStr(M->U4_MALADIR,RAT(".",M->U4_MALADIR) + 1,Len(M->U4_MALADIR))) <> "DOT")
			Help(" ",1,"TK061SMALA")//"Informe o arquivo da mala direta !"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TK062Write(@cText,nHandle)
			cText += STR0066+  CRLF // //"Arquivo de mala direta não foi informado."
			TK062Write(@cText,nHandle,.T.)
			Return(lRet)
		Endif
		
		If M->U4_LABEL == "1" //Sim
			If Empty(M->U4_ETIQUET) .OR. (Upper(SubStr(M->U4_ETIQUET,RAT(".",M->U4_ETIQUET) + 1,Len(M->U4_ETIQUET))) <> "DOT")
				Help(" ",1,"TK061SETIQ") //"Informe o arquivo de etiqueta para mala direta !"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TK062Write(@cText,nHandle)
				cText += STR0067+  CRLF // //"Arquivo de etiquetas não informado."
				TK062Write(@cText,nHandle,.T.)
				Return(lRet)
			Endif
		Endif
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Em caso de alteração de Lista, os dados não serao regerados         ³
//³porque somente serao gravados campos que nao influenciam nesta      ³
//³selecao exceto o Operador. Apesar do Operador fazer parte da selecao³
//³este poderá ser alterado para que nao seja necessário cancelar      ³
//³uma lista e regera-la para outro atendente.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == ALTERAR
	
	cAntOper := SU4->U4_OPERAD
	
	lRet := Tk062Grava(	nOpc		,aLista		,@cAssunto	,@cMensagem,;
						@cAttach	,@aAttach	,@cFiltro	,cSelOper,;
						lGrvCab		,nChamadas	,nSaveSX8,nTipo)
						
	TK062Write(@cText,nHandle,.T.)
	
	If lRet
		If cAntOper <> cSelOper
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Subtrai um do operador anterior.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			Tk062GrvTarefa(cAntOper,2)		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Soma mais uma tarefa para o operador.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			Tk062GrvTarefa(cSelOper,1)
		Endif	
	Endif
	
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia o processo carregando os parametros da selecao de CONTATOS              						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lA062Auto
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso exista filtro executa o Setfilter no alias              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cFiltro)
		If cPergunte == "TMK062"
			Tk062SetFilt(cFiltro,"SE1")
		Endif
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os parametros da pergunte selecionada em memoria     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("TMK060",.F.) // "Perfil"
	
	//Mv_Par01  Nivel do Contato
	//Mv_Par02	Perfil do Contato
	//Mv_Par03	Ligacoes Pendentes
	//Mv_Par04	A partir de quando
	//Mv_Par05	Ignora Dias Semana
	
	cMv_Par01  := Mv_Par01
	cMv_Par02  := Mv_Par02
	cMv_Par03  := Mv_Par03
	cMv_Par04  := Mv_Par04
	cMv_Par05  := Mv_Par05
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os parametros da pergunte selecionada em memoria     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("TMK062",.F.) 	// Inadimplentes
			
	ceMv_Par01	:= Mv_Par01 //Do Prefixo
	ceMv_Par02	:= Mv_Par02 //Ate o Prefixo
	ceMv_Par03	:= Mv_Par03 //Do Titulo
	ceMv_Par04	:= Mv_Par04 //Ate o Titulo
	ceMv_Par05	:= Mv_Par05 //Do Banco
	ceMv_Par06	:= Mv_Par06 //Ate o Banco
	ceMv_Par07	:= Mv_Par07 //Do Vencimento
	ceMv_Par08	:= Mv_Par08 //Ate o Vencimento
	ceMv_Par09	:= Mv_Par09 //Da Natureza
	ceMv_Par10	:= Mv_Par10 //Ate a Natureza
	ceMv_Par11	:= Mv_Par11 //Da Emissao
	ceMv_Par12	:= Mv_Par12 //Ate a Emissao
	ceMv_Par13	:= Mv_Par13 //Situacao do titulo	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribui os separadores dos tipos de titulos a serem utilizados. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cTipo)
		cSep:=	If("/" $ cTipo,"/",",") 
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Primeiro verifica se existem os contatos relacionados por Entidade no AC8      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
	If lSQL // se for um banco de dados
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacao de ambiente. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuery := .T.

		aOldAreAtv	:= (Alias())->(GetArea())	//	 Salva a área ativa antes de abrir as temporárias...
		If	cEntidade == "SA1" .AND. cPergunte == "TMK062"		// Clientes para TLC

			// Monta a clausula WHERE entre tabela sk1, se1, ACG
			// que será utilizado tanto para processamento com/sem LOG no TOP
			cQryWhr		:= " SK1.K1_PREFIXO BETWEEN '" + ceMv_Par01       + "' AND '" + ceMv_Par02       + "' AND "
			cQryWhr		+= " SK1.K1_NUM     BETWEEN '" + ceMv_Par03       + "' AND '" + ceMv_Par04       + "' AND "
			cQryWhr		+= " SK1.K1_PORTADO BETWEEN '" + ceMv_Par05       + "' AND '" + ceMv_Par06       + "' AND "
			cQryWhr		+= " SK1.K1_VENCREA BETWEEN '" + DtoS(ceMv_Par07) + "' AND '" + DtoS(ceMv_Par08) + "' AND "
			cQryWhr		+= " SK1.K1_NATUREZ BETWEEN '" + ceMv_Par09       + "' AND '" + ceMv_Par10       + "' AND "
			cQryWhr		+= " SK1.K1_VENCREA < '"       + DtoS(M->U4_Data) + "' AND "

			// Se o cliente possui o parâmetro MV_TMKCOBR configurado,
			// filtra apenas os tipos de títulos existentes no parâmetro.
			If	! Empty(cTipo)
				cQryWhr	+= " SK1.K1_TIPO IN " + FormatIn(cTipo,cSep) + " AND "
			Else
				// Carrega em variavel os tipos de titulos que nao poderao ser considerados na selecao dos titulos vencidos
				nAux	:= Len(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM)
				For nI := 1 to nAux Step 4
					cAbat := cAbat + "'" + SubStr(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM,nI,3) + "', "
				Next nI
				cAbat := SubStr(cAbat,1,Len(cAbat)-2)

				cQryWhr	+= " SK1.K1_TIPO NOT IN (" + cAbat + ") AND "
			EndIf

			If lTk062SK1
				cFlt_SK1 := ExecBlock("TK062SK1",.F.,.F.,{cSelOper,lLog})
				If ValType(cFlt_SK1) == "C"
					cQryWhr	+= cFlt_SK1 + " AND "
				EndIf
			EndIf

			cQryWhr+= " SK1.D_E_L_E_T_ = ' ' AND " 

			cQryWhr		+= " 0 < (SELECT COUNT(*) "
			cQryWhr		+=        " FROM " + RetSqlName("SE1") + " SE1 "
			cQryWhr		+=        " WHERE SE1.E1_FILIAL  = SK1.K1_FILORIG AND "
			cQryWhr		+=              " SE1.E1_PREFIXO = SK1.K1_PREFIXO AND "
			cQryWhr		+=              " SE1.E1_NUM     = SK1.K1_NUM AND "
			cQryWhr		+=              " SE1.E1_PARCELA = SK1.K1_PARCELA AND "
			cQryWhr		+=              " SE1.E1_TIPO    = SK1.K1_TIPO AND "
			cQryWhr		+=              " SE1.E1_PORTADO BETWEEN '" + ceMv_Par05       + "' AND '" + ceMv_Par06       + "' AND "
			cQryWhr		+=              " SE1.E1_VENCREA BETWEEN '" + DtoS(ceMv_Par07) + "' AND '" + DtoS(ceMv_Par08) + "' AND "
			cQryWhr		+=              " SE1.E1_NATUREZ BETWEEN '" + ceMv_Par09       + "' AND '" + ceMv_Par10       + "' AND "
			cQryWhr		+=              " SE1.E1_EMISSAO BETWEEN '" + DtoS(ceMv_Par11) + "' AND '" + DtoS(ceMv_Par12) + "' AND "
			cQryWhr		+=              " SE1.E1_SALDO   > 0 AND "

			// Se a situação do título não for informada, todas as situações serão consideradas
			If	! Empty(ceMv_Par13)
				cQryWhr	+= " SE1.E1_SITUACA = '" + ceMv_Par13 + "' AND "
			EndIf

			If lTk062SE1
				cFlt_SE1 := ExecBlock("TK062SE1",.F.,.F.,{cSelOper,lLog})
				If ValType(cFlt_SE1) == "C"
					cQryWhr	+= cFlt_SE1 + " AND "
				EndIf
			EndIf

			cQryWhr		+= " SE1.D_E_L_E_T_ = ' ' "

			// TELECOBRANCA
			// Neste ponto da query esta sendo tratado se a lista de inadimplentes é diferenciada, onde
			// a quantidade de cobrancas feitas para cada titulo eh considerada, pois influencia no trata-
			// mento dado pelo operador que estah gerando a lista de inadimplencia. A variavel nChamadas
			// Esta no botao Detalhes da Toolbar da Lista de Cobranca.
			// Se nChamadas = 0, os t?ulos que j?possuem atendimento ficar? fora da lista. Pode ser
			// Utilizado para filtrar os t?ulos que foram reagendados para uma data futura.
			If	nTipo == 2
				cQryWhr	+= " AND " + AllTrim(Str(nChamadas)) + " = (SELECT COUNT(*) "
				cQryWhr	+=                                          " FROM " + RetSqlName("ACG") + " ACG "
				cQryWhr	+=                                         " WHERE ACG.ACG_FILIAL = '" + cFilACG + "' AND "
				cQryWhr	+=                                               " ACG.ACG_PREFIX = SE1.E1_PREFIXO AND "
				cQryWhr	+=                                               " ACG.ACG_TITULO = SE1.E1_NUM AND "
				cQryWhr	+=                                               " ACG.ACG_PARCEL = SE1.E1_PARCELA AND "
				cQryWhr	+=                                               " ACG.ACG_TIPO   = SE1.E1_TIPO AND "
				cQryWhr	+=                                               " ACG.D_E_L_E_T_ = ' ') "
			EndIf
			cQryWhr	+= ") "
			
			cQryWhrTit	:= AllTrim(cQryWhr) 

			//*************************************************//
			// Monta tabela temporária se o cliente tem títulos em
			// atraso que não estão em lista de cobrança
			//*************************************************//
			
			// Clientes para TLC
			//*************************************************//
			// Monta tabela temporario se o cliente tem titulos em 
			// atraso que não estão em lista de cobrança				
			//*************************************************//			
			//Recupera a query para filtrar AC8 somente contatos x clientes devedores. 
			If cAvalFirst == "3"	
				
				If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
					cConcat := "||"
				Else
					cConcat := "+"
				Endif

				cFieldSK1	:= "SK1.K1_CLIENTE " + cConcat +  " SK1.K1_LOJA "
				cQAC8XSK1 	:= " SELECT " + cFieldSK1
				cQAC8XSK1 	+= " FROM " + RetSQLName("SK1") + " SK1 "		// Clientes para TLC
				cQAC8XSK1 	+= " WHERE "
				cQAC8XSK1	+= " SK1.K1_FILIAL = '" + cFilSK1 + "' AND "
				cQAC8XSK1	+= cQryWhrTit
				cQAC8XSK1 	+= " GROUP BY " + cFieldSK1
				cQAC8XSK1 	:= ChangeQuery(cQAC8XSK1)		
					
			Else
				
				//*************************************************//
				// Monta tabela temporária se o cliente tem títulos em
				// atraso que não estão em lista de cobrança
				//*************************************************//
				// Clientes para TLC
				cWhrInAC8	:= "% SUBSTRING(AC8.AC8_CODENT,1," + AllTrim(Str(TkEntTam(cEntidade)[1])) + ") = SK1.K1_CLIENTE " +;
				         	   " AND SK1.K1_LOJA = SUBSTRING(AC8.AC8_CODENT," + AllTrim(Str(TkEntTam(cEntidade)[1] + 1)) + "," + AllTrim(Str(TkEntTam(cEntidade)[2])) + ") %"
				
				cQryWhrTit := "%" + cQryWhrTit + "%"
			
				BeginSQL alias cAliasTmp	//<<<<<<<<<<<<<<<<<<<<<<<<<<<cTblSK1
	
					COLUMN TOTALREG AS NUMERIC(16,0)
	
					SELECT AC8_CODENT, COUNT(*) TOTALREG
					  FROM %Table:SK1% SK1
					       INNER JOIN %Table:AC8% AC8 ON AC8.AC8_FILIAL = %xfilial:AC8%
					                                 AND AC8.AC8_ENTIDA = %exp:cEntidade%
					                                 AND AC8.AC8_FILENT = %exp:cFilEntidade%
					                                 AND %exp:cWhrInAC8%
					                                 AND AC8.%NotDel%
					 WHERE SK1.K1_FILIAL = %xfilial:SK1%
					   AND %exp:cQryWhrTit%
					   AND SK1.%NotDel%
					 GROUP BY AC8.AC8_CODENT
					 ORDER BY AC8.AC8_CODENT
	
				EndSQL
				
				aStrTblSK1		:= {}
				aAdd(aStrTblSK1, {"AC8_CODENT", "C", Len(AC8->AC8_CODENT), 0})
				aAdd(aStrTblSK1, {"TOTALREG",   "N", 16,                   0})
				
				oTmpTblSK1		:= FWTemporaryTable():New( cTblSK1 )	// Cria o objeto da tabela temporária
				oTmpTblSK1:SetFields(aStrTblSK1)						// Informa a estrutura da tabela temporária 
				oTmpTblSK1:AddIndex("1",{"AC8_CODENT"})				// Atribui o índice à tabela temporária
				oTmpTblSK1:Create()										// Cria a tabela temporária
				
				While (cAliasTmp)->(! Eof())
					(cTblSK1)->(RecLock(cTblSK1,.T.))
					(cTblSK1)->AC8_CODENT	:= (cAliasTmp)->AC8_CODENT
					(cTblSK1)->TOTALREG		:= (cAliasTmp)->TOTALREG
					(cTblSK1)->(MsUnLock())
					(cAliasTmp)->(DbSkip())
				EndDo
				
				(cAliasTmp)->(DbCloseArea())
				
			EndIf

		Endif

		//*************************************************//
		// Monta tabela temporária com os Itens das Listas de Contatos
		// se a interação for 1=Nao Enviado;2=Em Uso;3=Enviado
		//*************************************************//
		BeginSQL alias cAliasTmp	//<<<<<<<<<<<<<<<<<<<<<<<<<<<cTblSU6

			COLUMN TOTALREG AS NUMERIC(16,0)

			SELECT U6_CONTATO, COUNT(*) AS TOTALREG
			  FROM %Table:SU6% SU6
			 WHERE SU6.U6_FILIAL = %xfilial:SU6%
			   AND SU6.U6_DATA = %exp:DtoS(M->U4_DATA)%
			   AND SU6.U6_STATUS in ('1','2','3')	//Nao-Enviado,Em Uso ou Enviado - Este la? pode ser substituido por um lRet := .T.
			   AND SU6.%NotDel%
			 GROUP BY SU6.U6_CONTATO
			 ORDER BY SU6.U6_CONTATO

		EndSQL

		aStrTblSU6		:= {}
		aAdd(aStrTblSU6, {"U6_CONTATO", "C", Len(SU6->U6_CONTATO), 0})
		aAdd(aStrTblSU6, {"TOTALREG",   "N", 16,                   0})
			
		oTmpTblSU6		:= FWTemporaryTable():New( cTblSU6	 )	// Cria o objeto da tabela temporária
		oTmpTblSU6:SetFields(aStrTblSU6	)						// Informa a estrutura da tabela temporária 
		oTmpTblSU6:AddIndex("1",{"U6_CONTATO"})				// Atribui o índice à tabela temporária
		oTmpTblSU6:Create()										// Cria a tabela temporária
			
		While (cAliasTmp)->(! Eof())
			(cTblSU6)->(RecLock(cTblSU6,.T.))
			(cTblSU6)->U6_CONTATO	:= (cAliasTmp)->U6_CONTATO
			(cTblSU6)->TOTALREG		:= (cAliasTmp)->TOTALREG
			(cTblSU6)->(MsUnLock())
			(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(DbCloseArea())

		//*************************************************//
		// Monta tabela temporario validando ligacoes pendentes 
		// de TeleMarketing.
		//*************************************************//
		BeginSQL alias cAliasTmp	//<<<<<<<<<<<<<<<<<<<<<<<<<<<cTblSUC

			COLUMN TOTALREG AS NUMERIC(16,0)

			SELECT UC_CODCONT, COUNT(*) AS TOTALREG
			  FROM %Table:SUC% SUC
			 WHERE SUC.UC_FILIAL = %xfilial:SUC%
			   AND SUC.UC_STATUS = '2'
			   AND SUC.%NotDel%
			 GROUP BY SUC.UC_CODCONT
			 ORDER BY SUC.UC_CODCONT

		EndSQL

		aStrTblSUC		:= {}
		aAdd(aStrTblSUC, {"UC_CODCONT", "C", Len(SUC->UC_CODCONT), 0})
		aAdd(aStrTblSUC, {"TOTALREG",   "N", 16,                   0})
			
		oTmpTblSUC := FWTemporaryTable():New( cTblSUC )	// Cria o objeto da tabela temporária
		oTmpTblSUC:SetFields(aStrTblSUC	)						// Informa a estrutura da tabela temporária 
		oTmpTblSUC:AddIndex("1",{"UC_CODCONT"})				// Atribui o índice à tabela temporária
		oTmpTblSUC:Create()										// Cria a tabela temporária
			
		While (cAliasTmp)->(! Eof())
			(cTblSUC)->(RecLock(cTblSUC,.T.))
			(cTblSUC)->UC_CODCONT := (cAliasTmp)->UC_CODCONT
			(cTblSUC)->TOTALREG	  := (cAliasTmp)->TOTALREG
			(cTblSUC)->(MsUnLock())
			(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(DbCloseArea())

		If	lLog // gera Log do processamento da lista de cobranca

			If nPeriod == 1
				If cDataBase == "ORACLE"
					cSQLPart += " AND CASE "
					cSQLPart += " SU5.U5_ULTCONT WHEN '"+Space(8)+"' THEN to_date('19000101','YYYYMMDD') + SU5.U5_PERIOD "
					cSQLPart += " ELSE to_date(SU5.U5_ULTCONT,'YYYYMMDD') + SU5.U5_PERIOD "
					cSQLPart += " END <= to_date('"+DtoS(M->U4_Data)+"','YYYYMMDD') "
				ElseIf cDataBase == "POSTGRES"
					cSQLPart += " AND CASE "
					cSQLPart += " WHEN SU5.U5_ULTCONT = '"+Space(8)+"' THEN to_date('19000101','YYYYMMDD') + cast(SU5.U5_PERIOD AS INT) "
					cSQLPart += " ELSE to_date(SU5.U5_ULTCONT,'YYYYMMDD') + cast(SU5.U5_PERIOD AS INT) "
					cSQLPart += " END <= to_date('"+DtoS(M->U4_Data)+"','YYYYMMDD') "
				Else
					cSQLPart += " AND convert(datetime,SU5.U5_ULTCONT,112)+SU5.U5_PERIOD <= convert(datetime,'" + DtoS(M->U4_Data) + "',112) "
				EndIf
			Endif
			
			//Melhoria de Performance
			//Filtra os contatos associados ao clientes com pendencia, ignorado os demais contatos.
			//Desta forma não havera log para os contatos x clientes sem pendencia.
			If !Empty( cQAC8XSK1 )
				cSQLPart += " AND AC8.AC8_CODENT IN ( " + cQAC8XSK1 + " ) "
			EndIf
			
			If lTk062SU5
				cFlt_SU5 := ExecBlock("TK062SU5",.F.,.F.,{cEntidade,cSelOper,lLog})
				If ValType(cFlt_SU5) == "C"
					cSQLPart += " AND " + cFlt_SU5
				EndIf
			EndIf
			
			cSQLPart := "%" + cSQLPart + "%"
					
			// O filtro esta montado e o ORDER BY nao esta na query entao é hora de montar o contator da regua
			// Monto o SELECT que conta e aproveito o filtro da outra query
			BeginSQL alias cAliasTmp

				COLUMN TOTAL AS NUMERIC(16,0)

				SELECT COUNT(*) TOTAL
				  FROM %Table:AC8% AC8
				       INNER JOIN %Table:SU5% SU5 ON SU5.U5_FILIAL = %xfilial:SU5%
				                                 AND AC8.AC8_CODCON = SU5.U5_CODCONT
				                                 AND SU5.U5_ATIVO <> '2'
				                                 AND SU5.%NotDel%
				 WHERE AC8.AC8_FILIAL = %xfilial:AC8%
				   AND AC8.AC8_ENTIDA = %exp:AllTrim(cEntidade)%
				   AND AC8.AC8_FILENT = %exp:cFilEntidade%
				   AND AC8.%NotDel%
				   %exp:cSQLPart%

			EndSql
			nRecTot := (cAliasTmp)->TOTAL
			(cAliasTmp)->(DbCloseArea())

			aOldAC8	:= AC8->(GetArea())
			AC8->(DbSetOrder(2))	//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
			
			BeginSQL alias cAliasAC8

				SELECT AC8.AC8_FILIAL, AC8.AC8_FILENT, AC8.AC8_ENTIDA, AC8.AC8_CODENT, AC8.AC8_CODCON,
				       SU5.U5_CONTAT,  SU5.U5_FONE,    SU5.U5_CELULAR, SU5.U5_FAX,     SU5.U5_FCOM1,
				       SU5.U5_FCOM2,   SU5.U5_EMAIL,   SU5.U5_AUTORIZ, SU5.U5_END,     SU5.U5_DIALIG,
				       SU5.U5_NIVEL
				  FROM %Table:AC8% AC8
				       INNER JOIN %Table:SU5% SU5 ON SU5.U5_FILIAL = %xfilial:SU5%
				                                 AND AC8.AC8_CODCON = SU5.U5_CODCONT
				                                 AND SU5.U5_ATIVO <> '2'
				                                 AND SU5.%NotDel%
				 WHERE AC8.AC8_FILIAL = %xfilial:AC8%
				   AND AC8.AC8_ENTIDA = %exp:AllTrim(cEntidade)%
				   AND AC8.AC8_FILENT = %exp:cFilEntidade%
				   AND AC8.%NotDel%
				   %exp:cSQLPart%
				 ORDER BY %Order:AC8%

			EndSql
			RestArea(aOldAC8)
				
		Else
		 	
		 	// Somente processa lista de cobranca sem log
			If lTmkConout
				// Este texto nao precisa ser traduzido. Trata-se de um controle interno para medir
				// a performance do processamento da query.
				TmkConout(STR0122,"TkMontaLista()")		//"Inicio da query"
			Endif
			
			If lTk062SU5 
				cFlt_SU5 := ExecBlock("TK062SU5",.F.,.F.,{cEntidade,cSelOper,lLog})
				If ValType(cFlt_SU5) == "C"
					cFlt_SU5 := " AND " + Alltrim(cFlt_SU5)
				EndIf
			EndIf  

			cFlt_SU5 := "%" + cFlt_SU5 + "%"
					
			// Avalio se existem contatos de COBRANÇA.
			BeginSql alias cAliasTmp

				COLUMN TOT AS NUMERIC(16,0)

				SELECT COUNT(*) TOT
				  FROM %Table:AC8% AC8, %Table:SU5% SU5
				 WHERE AC8.AC8_FILIAL = %xfilial:AC8%
				   AND AC8.AC8_ENTIDA = %exp:AllTrim(cEntidade)%
				   AND SU5.U5_FILIAL = %xfilial:SU5%
				   AND SU5.U5_CODCONT = AC8.AC8_CODCON
				   AND SU5.U5_TIPO = '3'
				   AND SU5.U5_ATIVO <> '2'
				   AND SU5.%NotDel%
				   AND AC8.%NotDel%
				    %exp:cFlt_SU5%
			EndSql  
			
			nTipo3 := (cAliasTmp)->TOT	//Total de contatos de COBRANÇA
			(cAliasTmp)->(DbClosearea())

			cQuery		:= "SELECT AC8.*, SK1.* "
			cQuery		+=   "FROM " + RetSqlName("AC8") + " AC8, " + RetSqlName("SU5") + " SU5, " + RetSqlName("SK1") + " SK1 "		// Clientes para TLC

			If cEntidade == "SA1" .AND. cPergunte == "TMK062"		// Clientes para TLC
				cQuery += ", "+RetSqlName("SA1")+" SA1 "
			EndIf

			cQuery		+=  "WHERE AC8.AC8_FILIAL = '" + cFilAC8 + "' "
			cQuery		+=    "AND AC8.AC8_ENTIDA = '" + AllTrim(cEntidade) + "' "
			
			//Melhoria de Performance
			//Filtra os contatos associados ao clientes com pendencia, ignorado os demais contatos.
			//Desta forma não havera log para os contatos x clientes sem pendencia.
			If !Empty( cQAC8XSK1 )
				cQuery += " AND AC8.AC8_CODENT IN ( " + cQAC8XSK1 + " ) "
			EndIf
			
			cQuery		+=    "AND SU5.U5_FILIAL = '" + cFilSU5 + "' "
			cQuery		+=    "AND SU5.U5_CODCONT = AC8.AC8_CODCON "
			
			If	nTipo3 > 0		// Se existirem contatos de COBRANÇA
				cQuery +=    "AND SU5.U5_TIPO = '3' "
			Endif

			If !Empty(cMv_par01)
				cQuery +=	"AND SU5.U5_NIVEL = '" + cMv_par01 + "' "
			Endif

			If nPeriod == 1
				If cDataBase == "ORACLE"
					cQuery += " AND CASE "
					cQuery += " SU5.U5_ULTCONT WHEN '"+Space(8)+"' THEN to_date('19000101','YYYYMMDD') + SU5.U5_PERIOD "
					cQuery += " ELSE to_date(SU5.U5_ULTCONT,'YYYYMMDD') + SU5.U5_PERIOD "
					cQuery += " END <= to_date('"+DtoS(M->U4_Data)+"','YYYYMMDD') "
				ElseIf cDataBase == "POSTGRES"
					cQuery += " AND CASE "
					cQuery += " WHEN SU5.U5_ULTCONT = '"+Space(8)+"' THEN to_date('19000101','YYYYMMDD') + cast(SU5.U5_PERIOD AS INT) "
					cQuery += " ELSE to_date(SU5.U5_ULTCONT,'YYYYMMDD') + cast(SU5.U5_PERIOD AS INT) "
					cQuery += " END <= to_date('"+DtoS(M->U4_Data)+"','YYYYMMDD') "
				Else
					cQuery += " AND convert(datetime,SU5.U5_ULTCONT,112)+SU5.U5_PERIOD <= convert(datetime,'" + DtoS(M->U4_Data) + "',112) "
				EndIf
			Endif

			If M->U4_FORMA == "1" .AND. M->U4_TIPOTEL == "1"    // Voz e Residencial
				cQuery	+= "AND SU5.U5_FONE <> ' ' "
			Endif

			If M->U4_FORMA == "1" .AND. M->U4_TIPOTEL == "2" // Voz e Celular
				cQuery	+= "AND SU5.U5_CELULAR <> ' ' "
			Endif

			If M->U4_FORMA == "1" .AND. M->U4_TIPOTEL == "3" // Voz e Fax
				cQuery	+= "AND SU5.U5_FAX <> ' ' "
			Endif

			If M->U4_FORMA == "1" .AND. M->U4_TIPOTEL == "4" // Voz e Comercial 1
				cQuery	+= "AND SU5.U5_FCOM1 <> ' ' "
			Endif

			If M->U4_FORMA == "1" .AND. M->U4_TIPOTEL == "5" // Voz e Comercial 2
				cQuery	+= "AND SU5.U5_FCOM2 <> ' ' "
			Endif

			If M->U4_FORMA == "2"   //Fax
				cQuery	+= "AND SU5.U5_FAX <> ' ' "
			Endif

			If M->U4_FORMA == "3"  //Cross-Posting
				// Se o contato nao possuir e-mail passa para o proximo contato.
				// Ou se o contato n? autorizar a interação via e-mail.
				cQuery	+= "AND SU5.U5_EMAIL <> ' ' "
				cQuery	+= "AND SU5.U5_AUTORIZ = '1' "
			Endif

			If M->U4_FORMA == "4"  //Mala-Direta
				// Se o contato nao possuir endereco passa para o proximo contato.
				cQuery	+= "AND SU5.U5_END <> ' ' "
			Endif

			// Verifico se vai ser avaliado o perfil do contato
			If cMv_par02 == 2 //Avalia
				cQuery	+= "AND (U5_DIALIG LIKE '%" + Str(Dow(M->U4_Data),1) + "%' OR '" + cMv_par05 + "' LIKE '%" + Str(Dow(M->U4_Data),1) + "%') "
			Endif

			If lTk062SU5
				cFlt_SU5 := ExecBlock("TK062SU5",.F.,.F.,{cEntidade,cSelOper,lLog})
				If ValType(cFlt_SU5) == "C"
					cQuery	+= "AND " + cFlt_SU5 + " "
				EndIf
			EndIf

			If cEntidade == "SA1" .AND. cPergunte == "TMK062"		// Clientes para TLC

				cQuery	+= "AND SA1.A1_FILIAL = '" + cFilSA1 + "' "
				cQuery	+= "AND SA1.A1_COD = SUBSTRING(AC8_CODENT,1," + AllTrim(Str(TkEntTam(cEntidade)[1])) + ") "
				cQuery	+= "AND SA1.A1_LOJA = SUBSTRING(AC8_CODENT," + AllTrim(Str(TkEntTam(cEntidade)[1] + 1)) + "," + AllTrim(Str(TkEntTam(cEntidade)[2])) + ") "
				cQuery	+= "AND SA1.D_E_L_E_T_ = ' ' "

				If lTk062SA1
					cFlt_SA1 := ExecBlock("TK062SA1",.F.,.F.,{cSelOper,lLog})
					If ValType(cFlt_SA1) == "C"
						cQuery	+= "AND " + cFlt_SA1
					EndIf
				EndIf
				
				cQuery	+= "AND SK1.K1_FILIAL = '" + cFilSK1 + "' "
				cQuery	+= "AND SK1.K1_CLIENTE = SUBSTRING(AC8_CODENT,1," + AllTrim(Str(TkEntTam(cEntidade)[1])) + ") "
				cQuery	+= "AND SK1.K1_LOJA = SUBSTRING(AC8_CODENT," + AllTrim(Str(TkEntTam(cEntidade)[1] + 1)) + "," + AllTrim(Str(TkEntTam(cEntidade)[2])) + ") "
				If	! Empty(cQryWhr)
					cQuery	+= "AND " + AllTrim(cQryWhr) + " "
				EndIf
			EndIf

			// Valida as ligacoes pendentes de TeleMarketing.
			cQuery	+= "AND 0 = (SELECT COUNT(*) "
			cQuery	+=            "FROM " + RetSqlName("SUC") + " SUC "
			cQuery	+=           "WHERE SUC.UC_FILIAL = '" + cFilSUC + "' "
			cQuery	+=             "AND SUC.UC_CODCONT = AC8_CODCON "
			cQuery	+=             "AND SUC.UC_STATUS = '2' "
			cQuery	+=             "AND SUC.D_E_L_E_T_ = ' ') "

			// TELECOBRANCA
			// Verifica se o contato nao esta em outra lista.
			// No caso da lista ser de TELECOBRANCA entao o contato pode entrar na lista de
			// Outro tipo da existente na mesma data. Ex. Voz, Mala direta, etc...

			If M->U4_TIPO == "2"	// Para telecobranca a regra eh diferente
				cQuery	+= "AND 0 = (SELECT COUNT(*) "
				cQuery	+=            "FROM " + RetSqlName("SU6") + " SU6, " + RetSqlName("SU4") + " SU4 "
				cQuery	+=            "WHERE SU6.U6_FILIAL = '" + cFilSU6 + "' "
				cQuery	+=              "AND SU6.U6_DATA = '" + DtoS(M->U4_DATA) + "' "
				cQuery	+=              "AND SU6.U6_CONTATO = AC8_CODCON "
				cQuery	+=              "AND SU6.D_E_L_E_T_ = ' ' "
				cQuery	+=              "AND SU4.U4_FILIAL = '" + cFilSU4 + "' "
				cQuery	+=              "AND SU4.U4_LISTA = SU6.U6_LISTA "
				cQuery	+=              "AND SU4.U4_FORMA = '" + M->U4_FORMA + "' "
				cQuery	+=              "AND SU4.D_E_L_E_T_ = ' ') "
			Else
				cQuery	+= "AND 0 = (SELECT COUNT(*) "
				cQuery	+=            "FROM " + RetSqlName("SU6") + " SU6 "
				cQuery	+=           "WHERE SU6.U6_FILIAL = '" + cFilSU6 + "' "
				cQuery	+=             "AND SU6.U6_DATA = '" + DtoS(M->U4_DATA) + "' "
				cQuery	+=             "AND SU6.U6_CONTATO = AC8_CODCON "
				cQuery	+=             "AND SU6.D_E_L_E_T_ = ' ') "
			Endif

			cQuery	+= "AND SU5.D_E_L_E_T_ = ' ' "
			cQuery	+= "AND AC8.D_E_L_E_T_ = ' ' "

			// O filtro esta montado e o ORDER BY nao esta na query entao é hora de montar o contator da regua
			// Monto o SELECT que conta e aproveito o filtro da outra query
			cQryTot	:= "SELECT COUNT(*) TOTAL " + SubStr(cQuery, AT("FROM ",cQuery), Len(cQuery))

			cQryTot	:= ChangeQuery(cQryTot)

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTot), cAliasTmp, .F., .T.)
			nRecTot	:= (cAliasTmp)->TOTAL
			(cAliasTmp)->(DbCloseArea())

			cQuery	+= " ORDER BY " + SqlOrder(AC8->(IndexKey(2)))

			cQuery	:= ChangeQuery(cQuery)

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAC8, .F., .T.)

			aStruct1	:= AC8->(DbStruct())
			aStruct2	:= SK1->(DbStruct())

			nAux	:= Len(aStruct1)
			For	nI := 1 to nAux
				If	aStruct1[nI][2] $ ("N,D,L")		// Numerico, data ou logico
					TcSetField(cAliasAC8, aStruct1[nI][1], aStruct1[nI][2], aStruct1[nI][3], aStruct1[nI][4])
				Endif
			Next nI

			nAux	:= Len(aStruct2)
			For nI:= 1 To nAux
				If aStruct2[nI][2] $ ("N,D,L")		// Numerico, data ou logico
					TcSetField(cAliasAC8, aStruct2[nI][1], aStruct2[nI][2], aStruct2[nI][3], aStruct2[nI][4])
				Endif
			Next nI

			If lTmkConout
				// Este texto nao precisa ser traduzido. Trata-se de um controle interno para medir
				// a performance do processamento da query.
				TmkConout(STR0123,"TkMontaLista()")     	//"Final da query"
			Endif
		EndIf

		RestArea(aOldAreAtv)	// Restaura a área que estava ativa antes do processamento das temporárias

		DbSelectArea(cAliasAC8)

	Else // lSQL ==.F. -> Então é codebase

		DbSelectArea(cAliasAC8)
		DbSetOrder(2)
		nRecTot := RecCount()
		MSSeeK(cFilAC8 + cEntidade+ cFilEntidade)
		lQuery := .F.
			
	EndIf

	If lTmkConout	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Este texto nao precisa ser traduzido. Trata-se de um controle interno para medir³
		//³a performance do processamento no ambiente.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		If lSQL
			TmkConout(STR0124,"TkMontaLista()")     	//"Inicio Processamento em TOP"
		Else
			TmkConout(STR0125,"TkMontaLista()")  		//"Inicio Processamento em Codebase"
		Endif	   
	Endif
	
	ProcRegua( 100 )
	nProgresso := 0.01 // chega no maximo a 1(100%)
	nTamNum := len(Alltrim(str(nRecTot)))

	While	(cAliasAC8)->(! Eof())					.AND.;
			(cAliasAC8)->AC8_FILIAL == cFilAC8		.AND.;
			(cAliasAC8)->AC8_ENTIDA == cEntidade	.AND.;
			(cAliasAC8)->AC8_FILENT == cFilEntidade

		nRecAtu++
		If nRecAtu == Int(nRecTot*nProgresso)
			IncProc(STR0068 + StrZero(nRecAtu,nTamNum) + STR0069 + StrZero(nRecTot,nTamNum))		// , " ate " //"Lendo reg. "###" até "
			nProgresso += 0.01
		EndIf
		
		If lEnd
			If TmkOk(STR0070) // //"Confirma o cancelamento da geração da lista de contato"
			    
				cText += STR0071+STR0072 //"********************************"###"Cancelado pelo operador."
				TK062Write(@cText,nHandle,.T.)
				
				cFiltro := ""
				If 	cPergunte == "TMK062"
					Tk062SetFilt(cFiltro,"SE1")
				Else
					Tk062SetFilt(cFiltro,cEntidade)
				Endif

				// Fecha a tabela temporária
				// com a quantidade de ligacoes pendentes do de TeleMarketing.
				// que o contato está associado
				If ( Select( cTblSUC ) > 0 ) .AND. ValType(oTmpTblSUC) == "O"
					oTmpTblSUC:Delete()
					FreeObj(oTmpTblSUC)
					oTmpTblSUC := NIL
				EndIf

				// Fecha a tabela temporária
				// com a quantidade de lista de cobrança que o contato está associado
				If ( Select( cTblSU6 ) > 0 ) .AND. ValType(oTmpTblSU6) == "O"
					oTmpTblSU6:Delete()
					FreeObj(oTmpTblSU6)
					oTmpTblSU6 := NIL
				EndIf

				// Fecha a tabela temporária
				// com a quantidade de titulos a pagar em aberto por clietne
				If ( Select( cTblSK1 ) > 0 ) .AND. ValType(oTmpTblSK1) == "O"
					oTmpTblSK1:Delete()
					FreeObj(oTmpTblSK1)
					oTmpTblSK1 := NIL
				EndIf

				// fecha o alias somente se for em TOP, neste caso é uma query.
				If lSQL .AND. Select(cAliasAC8) > 0
					(cAliasAC8)->(DbCloseArea())
				EndIf

				DbSelectArea("AC8")
			    aLista:= {}
			    lRet := .F.
			    Return(lRet)
			Else
				lEnd := .F.
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa filtro pata TOP e DBF								³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cFiltro)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³As tabelas em ADS e DBF sao diferentes. Em Top eh uma unica entidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea(cEntidade)
			DbSetOrder(1)
			If MsSeek(cFilEntidade + (cAliasAC8)->AC8_CODENT)	// Posiciona no item correto do alias a ser filtrado
				lValido := .F.
				cFiltroAux := (cEntidade)->(DbFilter())
				cFiltroSE1 := SE1->(DbFilter())
				If Empty(cFiltroSE1)
					Tk062SetFilt(cFiltro,"SE1")
				EndIf
				SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO           														
				SK1->(DbSetOrder(4)) // K1_FILIAL + K1_CLIENTE + K1_LOJA
				SK1->(MsSeek(cFilSK1+RTRIM((cAliasAC8)->AC8_CODENT)))
				While SK1->(!EOF())				.AND.;
				      SK1->K1_FILIAL == cFilSK1	.AND.;
				      RTRIM(SK1->K1_CLIENTE+SK1->K1_LOJA) == RTRIM((cAliasAC8)->AC8_CODENT)
					If SE1->( MsSeek(SK1->K1_FILORIG + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO) )
						lValido := .T.
						Exit
					EndIf
					SK1->(DbSkip())
				EndDo
				DbSelectArea(cEntidade)
				SET FILTER TO &(cFiltroAux)
				If !lValido
					DbSelectArea(cAliasAC8)
					DbSkip()
					Loop
				EndIf
			Endif
			DbSelectArea(cAliasAC8)

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avalio se o cliente que esta sendo processado ja foi incluido na lista. Se ja estiver³
		//³vai para o proximo. A regra eh soh existir um contato por cliente na lista.          ³
		//³Estou avaliando aqui nesse ponto para melhorar a performance do sistema.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPergunte == "TMK062" //Clientes -"SA1" //Inadimplementes
			If Ascan(aLista, {|x| x[6] == (cAliasAC8)->AC8_CODENT} ) > 0
				DbSelectArea(cAliasAC8)
				DbSkip()
				Loop
			Endif
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A partir daqui realiza o processamento em codebase ou em TOP com geracao de log³
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lQuery .AND. lLog) .OR. !lQuery
            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se optar por realizar o processamento baseado primeiramente nos titulos inadimplentes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cAvalFirst == "2"

				lGrava := Tk062SA12(ceMv_par01, ceMv_par02,              ceMv_par03, ceMv_par04,;
				                    ceMv_par05, ceMv_par06,              ceMv_par07, ceMv_par08,;
				                    ceMv_par09, ceMv_par10,              ceMv_par11, ceMv_par12,;
				                    M->U4_DATA, nChamadas,               lLog,       ceMv_par13,;
				                    cTipo,      (cAliasAC8)->AC8_CODENT, cFilSK1,    cFilACG,;
				                    cFilSE1,    nTipo)

		        If !lGrava
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TK062Write(@cText,nHandle)
					cText += STR0082+ (cAliasAC8)->AC8_CODCON+" - "+Tk062ContDesc((cAliasAC8)->AC8_CODCON) + STR0093 + CRLF //### //"Contato "###": "Este contato näo possui titulos a serem cobrados." 
		        	DbSelectArea(cAliasAC8)
		        	Dbskip()
		        	Loop
		        Endif	
		        
		    EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o contato ja esta em alguma lista de contato   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Tk062OutraLista((cAliasAC8)->AC8_CODCON, lTmkList, lSimultaneo, cFilSU4, cFilSU6)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TK062Write(@cText,nHandle)
				If lTmkList 
					cText += STR0073 +(cAliasAC8)->AC8_CODCON+" - " +Tk062ContDesc((cAliasAC8)->AC8_CODCON) + STR0133+  CRLF //### //"O Contato "###" já pertence a outra Lista de Cobrança ativa/em andamento."
				Else 
					cText += STR0073 +(cAliasAC8)->AC8_CODCON+" - " +Tk062ContDesc((cAliasAC8)->AC8_CODCON) + STR0074+  CRLF //### //"O Contato "###" já pertence a outra Lista para hoje."
				EndIf
				DbSelectArea(cAliasAC8)
				DbSkip()
				Loop
			Endif
			
			lSU5Valid := .F.
			
			// se estiver trabalhando com query então
			// os dados do contato se encontram na query do alias cAliasAC8
			If lQuery 

				lSU5Valid := .T.
				cAliasSU5 := cAliasAC8
				   
			Else // se for CODEBASE, precisa posicionar em um contato
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida todos os contatos do cliente para verificar se algum e de³
				//³COBRANCA e retorna o codigo do contato.						   ³
				//³Verifica todos os contatos da entidade apenas uma vez.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("AC8")
				DbSetOrder(2)
				If cCodEnt <> (cAliasAC8)->AC8_CODENT 
					cCodCont := Tk062Contato((cAliasAC8)->AC8_ENTIDA, (cAliasAC8)->AC8_FILENT, (cAliasAC8)->AC8_CODENT, cFilAC8, cFilSU5)	//Alias , Filial, Codigo+Loja, Filial AC8, Filial SU5

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se existir Contato de COBRANCA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(cCodCont)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Posiciona no contato de COBRANCA  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("AC8")
						DbSetOrder(2)
						MsSeek(cFilAC8 + cEntidade + cFilEntidade + (cAliasAC8)->AC8_CODENT + cCodCont)
					Endif
					cCodEnt	:= (cAliasAC8)->AC8_CODENT
				Else
					If !Empty(cCodCont)
						If Posicione("SU5",1,cFilSU5+(cAliasAC8)->AC8_CODCONT,"U5_TIPO") <> "3"
							DbSelectArea(cAliasAC8)
							DbSkip()
							Loop
						EndIf
					EndIf
				Endif		    
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Percorre o cadastro de contatos :                    ³
				//³1) Se nao tiver o telefone selecionado gravado SKIP  ³
				//³2) Se nao tiver o endereco selecionado gravado SKIP  ³
				//³3) Se nao existir o contato pega os dados da empresa ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SU5")
				DbSetOrder(1)
				If MsSeek(cFilSU5+(cAliasAC8)->AC8_CODCON)

					If lTk062SU5
						cFlt_SU5 := ExecBlock("TK062SU5",.F.,.F.,{cEntidade,cSelOper,lLog})
						If ValType(cFlt_SU5) <> "C"
							cFlt_SU5 := ""
						EndIf
						If !Empty(cFlt_SU5) .And. !(&cFlt_SU5)
							(cAliasAC8)->(dbSkip())
							Loop
						EndIf
						 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se foi chamado pelo botao da lista de periodicidade e ³
						//³avalia se a data de execussao da lista e maior ou igual ao     ³
						//³ultimo contato mais os dias de intervalo.                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (nPeriod == 1) .AND. !Empty(SU5->U5_ULTCONT) .AND. ((SU5->U5_ULTCONT + SU5->U5_PERIOD) > M->U4_Data)
							DbSelectArea(cAliasAC8)
							DbSkip()
							Loop
						Endif
					
					EndIf
					lSU5Valid := .T.
					cAliasSU5 := "SU5"
				EndIf
			EndIf
	
			If lSU5Valid
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o NIVEL estiver vazio nao exclue da lista por nivel³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cMv_par01)
					If (cAliasSU5)->U5_NIVEL <> cMv_par01 //Nivel
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						TK062Write(@cText,nHandle)
						cText += STR0075+ (cAliasAC8)->AC8_CODCON + " - " + FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") + " " + STR0076 + CRLF	//### //"Nível do contato "###" diferente do nível selecionado no 'Perfil do Contato'."
						(cAliasAC8)->(Dbskip())
						Loop
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida o tipo de telefone para contato.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					Case (M->U4_FORMA == "1")   //Voz
						
						If M->U4_TIPOTEL == "1" // Residencial
							cTel	:= (cAliasSU5)->U5_FONE
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cTextAux := STR0077  // //"Residencial."
							
						ElseIf M->U4_TIPOTEL == "2" // Celular
							cTel	:= (cAliasSU5)->U5_CELULAR
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							cTextAux := STR0078  // //"Celular."
							
						ElseIf M->U4_TIPOTEL == "3" // Fax
							cTel	:= (cAliasSU5)->U5_FAX
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cTextAux := STR0079 // //"Fax."
							
						ElseIf M->U4_TIPOTEL == "4" // Comercial 1
							cTel	:= (cAliasSU5)->U5_FCOM1
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cTextAux := STR0080 // //"Comercial 1."
							
						ElseIf M->U4_TIPOTEL == "5" // Comercial 2
							cTel	:= (cAliasSU5)->U5_FCOM2         
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cTextAux := STR0081 // //"Comercial 2."
							
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o tipo de telefone para a geracao da lista nao³
						//³existir no contato, passa para o proximo contato.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cTel)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TK062Write(@cText,nHandle)
							cText += STR0082+ (cAliasAC8)->AC8_CODCON +" - "+ FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0083 + cTextAux + CRLF //### //"Contato "###": não possui telefone "
							(cAliasAC8)->(DbSkip())
							Loop 
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Limpa a variavel auxiliar de Help.               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cTextAux := ""
						
					Case (M->U4_FORMA == "2")   //Fax
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o contato nao possuir numero de fax passa para o proximo contato.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty((cAliasSU5)->U5_FAX)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TK062Write(@cText,nHandle)
							cText += STR0082+ (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0083 + M->U4_TIPOTEL + "." + CRLF //###### //"Contato "###": não possui telefone "
							(cAliasAC8)->(DbSkip())
							Loop
						Endif
						
						
					Case (M->U4_FORMA == "3")  //Cross-Posting
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o contato nao possuir e-mail passa para o proximo contato.       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty((cAliasSU5)->U5_EMAIL) .OR. ((cAliasSU5)->U5_AUTORIZ <> "1")
						
	    					If  Empty((cAliasSU5)->U5_EMAIL) .AND. ((cAliasSU5)->U5_AUTORIZ <> "1")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   					TK062Write(@cText,nHandle)
			   					cText += STR0073+ (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" "+ STR0084+ CRLF //### //"O Contato "###" não possui e-mail cadastrado e em seu cadastro não ha permissão para recebimento de e-mail. "
	    					Elseif Empty((cAliasSU5)->U5_EMAIL)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    						TK062Write(@cText,nHandle)
	    						cText += STR0073+ (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0085 + CRLF //### //"O Contato "###" não possui e-mail cadastrado."
	    					ElseIf ((cAliasSU5)->U5_AUTORIZ <> "1")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    					TK062Write(@cText,nHandle)
		    					cText += STR0086+ (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0087 + CRLF //### //"Contato: "###" Em seu cadastro não ha permissão para envio de E-mail ."
	    					Endif

							(cAliasAC8)->(DbSkip())
							Loop
	    				Endif
						
					Case (M->U4_FORMA == "4")  //Mala-Direta
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o contato nao possuir endereco passa para o proximo contato.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty((cAliasSU5)->U5_END)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TK062Write(@cText,nHandle)
							cText += STR0073+ (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0088 + CRLF //### //"O Contato "###" não possui endereço cadastrado."
							(cAliasAC8)->(DbSkip())
							Loop
						Endif
						
				Endcase
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifico se vai ser avaliado o perfil do contato     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMv_par02 == 2 //Avalia
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TK062Write(@cText,nHandle)
					cText += CRLF+STR0089 + CRLF // //"Avaliando o perfil dos contatos..."
					
					If !Empty((cAliasSU5)->U5_DIALIG)
						nDia	:= DOW(M->U4_DATA)	//Data de vigencia
						nAux	:= Len(Alltrim((cAliasSU5)->U5_DIALIG))
						For nI := 1 To nAux
							If Substr((cAliasSU5)->U5_DIALIG,nI,1) $ Str(nDia,1,0)
								lGrava := .T.
								Loop
							Endif
						Next nI
					    
						If !lGrava    
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    	cTextAux += STR0082+ (cAliasAC8)->AC8_CODCON+" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0090 + CRLF //###": não recebe interacao para a data informada nesta Lista." //"Contato "###": não recebe interação para a data informada nesta Lista."
					    Endif
					Endif
					
					If !Empty(cMv_par05) //Ignora dias da semana
						nAux	:= Len(Alltrim((cAliasSU5)->U5_DIALIG))
						For nI := 1 To nAux
							If Substr(cMv_PAR05,nI,1) $ Str(nDia,1,0)
								lGrava := .T.
							Endif
						Next nI
	
						If !lGrava    
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    	cTextAux += STR0082+ (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0091 + CRLF //###": não recebe interacao nos dias da Semana definidos nos parâmetros de Perfil (Botão Entidade)." //"Contato "###": não recebe interação nos dias da Semana definidos nos parâmetros de Perfil (Botão Entidade)."
					    Endif
					Endif
					
					If !lGrava
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cTextAux)
							TK062Write(@cText,nHandle)
							cText += STR0082 + (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " +STR0092 //### //"Contato "###": A data de vigência e os dias da semana para ligação estao em branco no cadastro do Contato. Folder Perfil."
						Else	
							TK062Write(@cText,nHandle)
							cText += cTextAux
							cTextAux := ""
						Endif
						
						(cAliasAC8)->(Dbskip())
						Loop
					Endif
					
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Depois de avaliado o contato verifico a PERGUNTE escolhida   ³
				//³e se a ENTIDADE corresponde as perguntes da selecao          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPergunte == "TMK062" //Clientes -"SA1" //Indadimplementes
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Avalia se os titulos que pertencem ao contato, correspondem com os dados informados ³
					//³no parametro apenas de ainda nao foi feita a verificacao                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cAvalFirst == "1"
					
						lGrava := Tk062SA12(ceMv_par01, ceMv_par02,              ceMv_par03, ceMv_par04,;
						                    ceMv_par05, ceMv_par06,              ceMv_par07, ceMv_par08,;
						                    ceMv_par09, ceMv_par10,              ceMv_par11, ceMv_par12,;
						                    M->U4_DATA, nChamadas,               lLog,       ceMv_par13,;
						                    cTipo,      (cAliasAC8)->AC8_CODENT, cFilSK1,    cFilACG,;
						                    cFilSE1,    nTipo)												
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TK062Write(@cText,nHandle)
							cText += STR0082+ (cAliasAC8)->AC8_CODCON+" - "+ FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0093 + CRLF //### //"Contato "###": O perfil da Entidade não se enquadra no Perfil de Entidade selecionado."
							(cAliasAC8)->(Dbskip())
							Loop
						Endif
					
					Endif
						
				Endif  
		
				If !Tk062ValSUC((cAliasAC8)->AC8_CODCON, cFilSUC)
					TK062Write(@cText,nHandle)
					cText+=STR0082+ (cAliasAC8)->AC8_CODCON +" - "+FATPDObfuscate(Alltrim((cAliasSU5)->U5_CONTAT),"U5_CONTAT") +" " + STR0094+CRLF // //". Este contato possui ligações pendentes."
					DbSelectArea(cAliasAC8)
					DbSkip()
					Loop
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
					//³Verifica se existe algum titulo, para o cliente do contato.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
					DbSelectArea("SK1")
					DbSetOrder(4)
					If MsSeek(cFilSK1 + RTRIM((cAliasAC8)->AC8_CODENT))
						lGrava := .T.
					EndIf
				Endif
	
				If lGrava
					DbSelectArea(cAliasAC8)

					AAdd(aLista,{cFilSU6,;							// Filial
					             M->U4_LISTA,;						// Lista
					             GetSxeNum("SU6","U6_CODIGO"),;	// Codigo
					             (cAliasAC8)->AC8_FILENT,;			// Chave da Entidade
					             (cAliasAC8)->AC8_ENTIDA,;			// Filial da Entidade
					             (cAliasAC8)->AC8_CODENT,;			// Codigo da Entidade
					             "1",;								// Origem da Interacao
					             (cAliasAC8)->AC8_CODCON,;			// Codigo do Contato
					             M->U4_DATA,;						// Data
					             cU6Hrini,;							// Hora Inicial
					             cU6HrFim,;							// Hora Final
					             "1"})								// Status da Interacao

					lGrava := .F.
				Endif
			Endif
	
		Else //lQuery
		
			DbSelectArea(cAliasAC8)
			If ! Tk062OutraLista((cAliasAC8)->AC8_CODCON, lTmkList, lSimultaneo, cFilSU4, cFilSU6)

				AAdd(aLista,{cFilSU6,;							// Filial
				             M->U4_LISTA,;						// Lista
				             GetSxeNum("SU6","U6_CODIGO"),;	// Codigo
				             (cAliasAC8)->AC8_FILENT,;			// Chave da Entidade
				             (cAliasAC8)->AC8_ENTIDA,;			// Filial da Entidade
				             (cAliasAC8)->AC8_CODENT,;			// Codigo da Entidade
				             "1",;								// Origem da Interacao
				             (cAliasAC8)->AC8_CODCON,;			// Codigo do Contato
				             M->U4_DATA,;						// Data
				             cU6Hrini,;							// Hora Inicial
				             cU6HrFim,;							// Hora Final
				             "1"})								// Status da Interacao

			EndIf
		Endif

		If Len(aLista) > 1024
			Tk062Grava(nOpc,     aLista,    @cAssunto, @cMensagem,;
			           @cAttach, @aAttach,  cFiltro,   @cSelOper,;
			           @lGrvCab, nChamadas, nSaveSX8,  nTipo)
			lRet := .T.
			aLista := {}
		Endif

		DbSelectArea(cAliasAC8)
		DbSkip()
		
	End

	// Fecha a tabela temporária
	// com a quantidade de ligacoes pendentes do de TeleMarketing.
	// que o contato está associado
	If ( Select( cTblSUC ) > 0 ) .AND. ValType(oTmpTblSUC) == "O"
		oTmpTblSUC:Delete()
		FreeObj(oTmpTblSUC)
		oTmpTblSUC := NIL
	EndIf

	// Fecha a tabela temporária
	// com a quantidade de lista de cobrança que o contato está associado
	If ( Select( cTblSU6 ) > 0 ) .AND. ValType(oTmpTblSU6) == "O"
		oTmpTblSU6:Delete()
		FreeObj(oTmpTblSU6) 
		oTmpTblSU6 := NIL
	EndIf

	// Fecha a tabela temporária
	// com a quantidade de titulos a pagar em aberto por clietne
	If ( Select( cTblSK1 ) > 0 ) .AND. ValType(oTmpTblSK1) == "O"
		oTmpTblSK1:Delete()
		FreeObj(oTmpTblSK1)
		oTmpTblSK1 := NIL
	EndIf

	// fecha o alias somente se for em TOP, neste caso é uma query.
	If lSQL .AND. Select(cAliasAC8) > 0
		(cAliasAC8)->(DbCloseArea())
	EndIf
	
	If Len(aLista) > 0
		Tk062Grava(nOpc,     aLista,    @cAssunto, @cMensagem,;
		           @cAttach, @aAttach,  @cFiltro,  @cSelOper,;
		           @lGrvCab, nChamadas, nSaveSX8,  nTipo)
		IncProc(STR0068 + StrZero(nRecAtu,nTamNum) + STR0069 + StrZero(nRecTot,nTamNum))
		lRet := .T.
		aLista := {}
	Endif

	If lTmkConout
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Este texto nao precisa ser traduzido. Trata-se de um controle interno para medir³
		//³a performance do processamento no ambiente.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		If lQuery
			TmkConout(STR0126,"TkMontaLista()")     //"Termino Processamento em TOP"
		Else
			TmkConout(STR0127,"TkMontaLista()")  	//"Termino Processamento em Codebase"
		Endif	   
	Endif

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que executara a validacao dos itens enviados pela rotina automatica.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := Tk062VldAuto(nOpc,       aLista,   cSelOper, @cAssunto,;
	                     @cMensagem, @cAttach, @aAttach, @cFiltro,;
	                     nSaveSX8,   nTipo)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cText) .AND. !lRet
	TK062Write(@cText,nHandle)
	cText := STR0095	 //"Não ha relacionamento de Contatos para a Entidade Selecionada." //"Não há relacionamento de Contatos para a Entidade Selecionada."
Else
	TK062Write(@cText,nHandle,.T.)
Endif

If lRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma mais uma tarefa para o operador.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Tk062GrvTarefa(cSelOper,1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a lista for de mala direta verifica se deseja realizar a impressao³
	//³da mala direta imediatamente.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (M->U4_FORMA == "4") //Mala direta
		If TmkOk(STR0096) // //"Deseja imprimir a mala direta ?"
			Tk062Mala(M->U4_LISTA,M->U4_MALADIR,M->U4_LABEL,M->U4_ETIQUET)  // imprimir a mala
		Else
			Help(" ",1,"TK061NOIMP") //"A selecao ficara armazenada como pendente e podera ser impressa posteriormente !"
		Endif
	Endif
Endif

aLista:= {}

CursorArrow()

cFiltro := ""
If cPergunte == "TMK062"
	Tk062SetFilt(cFiltro,"SE1")
Else
	Tk062SetFilt(cFiltro,cEntidade)
Endif

RestArea(aAreaSK1)

If	lTmkConout
	TmkConout("TK062MontaLista() v04-" + STR0135 + ": " + AllTrim(Str(ThreadID())) + " - " + DTOC(DATE()) + " " + TIME() + " " + AllTrim(Str(Seconds()-nProcTempo)))	//"FIM-TOTVS THREAD"
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK062Fim   ºAutor ³ Vendas Clientes    º Data ³  18/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o semaforo quando o usuario cancelar a rotina      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Lista de Inadimplentes (TeleCobranca)		   	          	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk062Fim(nSaveSX8)

While (GetSx8Len() > nSaveSx8)
	RollBackSX8()
End

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk062Contato ºAutor  ³ Vendas Clientes    º Data ³  14/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avalia se o tipo de contato e de COBRANCA   (U5_TIPO == 3)     º±±
±±º          ³                                                               º±±
±±º          ³ExpC1:Alias da Entidade do Contato                             º±±
±±º          ³ExpC1:Filial da Entidade do Contato                            º±±
±±º          ³ExpC1:Codigo e Loja da entidade do Contato                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 811                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk062Contato(cEntidade, cFilEnt, cCodEnt, cFilAC8, cFilSU5)

Local aArea		:= GetArea() 	// Guarda a area
Local cCodCont	:= ""       	// Codigo do contato

Default cFilAC8	:= xFilial("AC8")
Default cFilSU5	:= xFilial("SU5")

SU5->(DbSetOrder(1))
AC8->(DbSetOrder(2))
AC8->(MsSeek(cFilAC8 + cEntidade + cFilEnt + cCodEnt))
While	AC8->(! Eof())					.AND.;
		AC8->AC8_FILIAL == cFilAC8		.AND.;
		AC8->AC8_ENTIDA == cEntidade 	.AND.;
		AC8->AC8_FILENT == cFilEnt		.AND.;
		AC8->AC8_CODENT == cCodEnt

	If SU5->(MsSeek(cFilSU5 + AC8->AC8_CODCON))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o contato que tenha o campo U5_TIPO preenchido com ³
		//³3- COBRANCA, pois indica que o contato e de COBRANCA.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SU5->U5_TIPO == "3" //Cobranca
			cCodCont	:= SU5->U5_CODCONT
			Exit
		Endif
	Endif
	AC8->(DbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao existirem contatos para a entidade do tipo COBRANCA,   ³
//³retorna o codigo do contato em branco                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
Return(cCodCont)

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
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

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