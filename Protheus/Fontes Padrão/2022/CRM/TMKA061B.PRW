#INCLUDE "TMKA061B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMKDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA061B  ºAutor  ³Rafael M Quadrotti  º Data ³  07/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fonte com as funcoes de TELA da Lista de Contato.           º±±
±±º          ³Tmka061                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - Lista de Contato.                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061WizardºAutor ³Rafael M Quadrotti  º Data ³  07/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Wizard de inclusão padrao da lista de contato               º±±
±±º          ³Tmka061                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - Lista de Contato.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                     	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³03/07/05³8.11  ³FNC 002408/2005 - Utilizar Filtro da tabela º±±
±±º          ³        ³      ³SD2 quando lista for do tipo CROSS-SELLING. º±±
±±ºMichel W. ³02/10/06³104074³Incluida funcao para criacao de perguntes emº±±
±±º          ³        ³      ³SX1 (Tk061BAjustSX1).                       º±±
±±ºConrado Q.³22/02/07³119542³Retirada função de ajuste do dicionário.    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK061WIZARD(cAlias,nReg,nOpc)

Local lRet			:= .F.									// Retorno da Funcao.
Local oWizard 												// Objeto principal do Wizard
Local oRadP1												// Objeto Radio do Panel 1 onde e definido o tipo de Lista. Padrao/CrossSelling
Local nRadP1		:= 1									// Controle do Radio do Panel 1
Local cMemo1 		:= ""									// Objetos Memo e variaveis para Memo de auxilio. Um para cada Panel.
Local oMemo1
Local cMemo2 		:= ""
Local oMemo2
Local cMemo3 		:= ""
Local oMemo3
Local cMemo4 		:= ""
Local oMemo4
Local cMemo5 		:= ""
Local oMemo5
Local cMemo6 		:= ""
Local oMemo6
Local cMemo7 		:= ""
Local oMemo7
//painel 8 nao possui memo de informacao.
Local cMemo9 		:= ""
Local oMemo9
Local cMemo10 		:= ""
Local oMemo10
Local cMemo11 		:= ""
Local oMemo11
Local cMemo12 		:= ""
Local oMemo12
Local cMemo13 		:= ""
Local oMemo13
Local cMemo14 		:= ""
Local oMemo14
Local cMemo15 		:= ""
Local oMemo15
Local cMemo16 		:= ""
Local oMemo16
Local cMemo17		:= ""
Local oMemo17
Local cMemoA		:= ""									// Variaveis para troca inteligente de help.
Local cMemoB		:= ""									// Variaveis para troca inteligente de help.
Local cMemoC		:= ""									// Variaveis para troca inteligente de help.
Local cMemoD		:= ""									// Variaveis para troca inteligente de help.
Local cMemoE		:= ""									// Variaveis para troca inteligente de help.
Local cMemoF		:= ""									// Variaveis para troca inteligente de help.
Local oTpLista												// Objeto do Tipo de Lista. Marketing/Vendas 
Local nTpLista		:= 1									// Controle do Radi do tipo de lista.
Local oEntidade												// Objeto para selecao da Entidade. Ex.Clientes,Fornecedores Etc.
Local nEntidade		:= 1									// Controle do objeto de selecao da Entidade.
Local aEntidades    := {}									// Array com as entidades disponiveis para selecao em caso de listas do Tipo Marketing
Local oScroll 												// Objeto Scroll para Entidades.
Local oEntVendas											// Objeto onde estão as entidades para Listas do tipo Vendas.
Local nEntVendas	:= 1									// Controle do objeto oEntVendas. 
Local nI			:= 0 							        // Variavel utilizada no comando For para preenchimento do array aEntidades.                    
Local nDetCont		:= 1									// Variavel de controle do objeto oDetCont
Local oDetCont												// Objeto onde será informado se a selecao do operador sera ou não detalhada.
Local aEntAux												// Array auxiliar para Entidades.
Local oForma												// Objeto onde estao informadas as formas de contato.
Local nForma		:= 1									// Variavel de controle da forma de contato.
Local oRadFone												// Objeto para selecao do telefone de contato.
Local nRadFone		:= 1 									// Radio do telefone para contato.
Local nTpFax		:= 1									// Controle da Selecao do tipo de endereço de fax.
Local oTpFax												// Controle da Selecao do tipo de endereço de fax.
Local oTpEnd												// Objeto do tipo de endereco de mala direta
Local nTpEnd		:= 1									// Tipo de endereco de mala
Local oArqMala												// Objeto para informacao do arquivo de mala direta.
Local cArqMala		:= Criavar("U4_MALADIR",.F.)			// Variavel para objeto do arquivo de mala direta.
Local oEtiq													// Objeto para flag do arquivo de etiqueta.
Local lEtiq			:= .T. 									// Variavel de controle da Flag de Etiqueta. 
Local oArqEtiq												// Objeto para informacao do arquivo de Etiqueta.
Local cArqEtiq		:= Criavar("U4_ETIQUET",.F.) 			// Variavel para objeto do arquivo de Etiqueta.
Local oMens													// Objeto para mensagem de e-mail.
Local oSubj													// Objeto para assunto de e-mail.
Local oAttach												// Objeto para attach de e-mail.
Local cMens   		:= Space(400)							// Variavel para mensagem do e-mail.
Local cSubj   		:= CriaVar("U4_ASSUNTO",.F.) 			// Variavel para assunto do e-mail.
Local aArq    		:= {}									// Array com arquivos attached. 
Local cAttach 		:= ""									// String - Vetor - para arquivos anexados.
Local nAttach		:= 	0									// Variavel para ListBox
Local nTipo	  		:= 1 									// Controle do Objeto TIPO DE LISTA (1-Marketing, 2 - Vendas)
Local oSayP13												// Objeto Say para descricao na tela do Operador
Local cSayP13												// Variavel do objeto Say de descricao.
Local cSayGrupo1 	:= ""									// Descricao  dos dados que devem ser informados (Painel 13)
Local oSayGrupo1 											// Objeto para descricao. (Painel 13)
Local cSayGrupo2 	:= ""									// Descricao  dos dados que devem ser informados (Painel 13)
Local oSayGrupo2 											// Objeto para descricao. (Painel 13)
Local cSayGrupo3 	:= ""									// Descricao  dos dados que devem ser informados (Painel 13)
Local oSayGrupo3 											// Objeto para descricao. (Painel 13)
Local oGrupo 												// Objeto do Grupo de operadores para selecao. (Painel 13)
Local cGrupo 		:= CriaVar("U0_CODIGO",.F.)				// Conteudo do get para grupo de operadores (Painel 13)
Local lGrupo		:= .F.									// Flag para identificacao se a lista sera ou nao por grupo.
Local oSayGDes 												// Descricao do grupo selecionado. (Painel 13)
Local cSayGDes 		:= CriaVar("U0_NOME",.F.)				// Descricao do grupo selecionado. (Painel 13)
Local oSayP13B												// Objeto say para impressao de texto do oeprador (Painel 13)
Local cSayP13B		:= ""									// Say para destaque do operador (painel 13)
Local oSayP13C												// Objeto say para impressao de texto do oeprador (Painel 13)
Local cSayP13C 		:= ""									// Say para destaque do operador (painel 13)
Local cSayP14A		:= ""									// Say da Hora Inicial.
Local cSayP14B		:= ""									// Say da Hora final.
Local oSayP14A												// Say da Hora Inicial.
Local oSayP14B												// Say da Hora Final.
Local oRadOper 												// Objeto para o tipo de selecao do operador.
Local nRadOper		:= 1									// Define o tipo de selecao do operador
Local oOperad												// Objeto para operador.
Local cOperad		:= Criavar("U4_OPERAD",.F.)			// Variavel do get do operador.
Local aOper 		:= {}									// Array com operadores
Local nOper 		:= 1									// Controle para operador 
Local oOpers    											// Objeto contendo os operadores.
Local oOk       	:= LoaDbitmap(GetResources(),"LBOK") 	// Objeto para selecao do operador.
Local oNo        	:= LoaDbitmap(GetResources(),"LBNO") 	// Objeto para selecao do operador.
Local cSayP13A		:= STR0001      						// Operador
Local oSayP13A												// Objeto para operador.
Local oEnchoice												// Enchoice de campos complementares.
Local aFields		:= {}									// Campos do SU4 adicionais ao Wizard. 
Local oHrIni												// Objeto para Hora Inicial
Local cHrIni        := Criavar("U6_HRINI",.F.)             // Variavel do objeto HrIni.
Local oHrFim												// Objeto para Hora final
Local cHrFim        := Criavar("U6_HRFIM",.F.)				// Variavel do objeto HrFim.
Local oTotLista												// Objeto para quantidade total de itens por lista.
Local cTotLista     := Space(6)								// Variavel do objeto oTotLista
Local cFiltro		:= ""									// Filtro
Local cFiltroU5		:= ""									// Filtro de contatos
Local cFiltU5SQL	:= ""									// Filtro de contatos (em SQL)
Local aSizeAut 		:= MsAdvSize( .F., .F. )                          // Array com a dimensao de tela  
Local aObjects      := {}                                  	// Array do objeto
Local aInfo         := {}                                  // Array com as coordenadas 
Local aPosObj		:= {}                                  // Posicao da Tela
Local cLinMemo		:= 097									// Coordenada do memo para apresentacao em todos os paineis. 
Local cColMemo      := 000 									// Coordenada do memo para apresentacao em todos os paineis. 
Local aPFilt		:= {}									// Array de paineis da build exp.
Local aResumo		:= {}									// Variavel para observacao da finalizacao do wizard.
Local oResumo												// Objeto onde estao os dados do resumo de selecao.
Local cEntidade		:= ""									// Variavel utilizada pela funcao de selecao para definir o alias utilizado.
Local nAniver 		:= 0								    // Identifica se será lista de Aniversario.
Local nPeriod  		:= 2								    // Identifica se será lista de Periodicidade. 2= NAO
Local lLstDiaria	:= .F.									// Identifica se a lista de aniversario sera diária ou por intervalo de data.
Local cPergunte		:= ""									// Variável onde eh armazenada a pergunte executada.
Local cText    		:= CRLF 								// Variavel com os textos para help da Lista de Contatos
Local nPosSA1		:= 0									// Posicao do Alias Cliente no Radio
Local sMV_PAR01		:= ""									// Perguntas de Cross Selling.
Local sMV_PAR02		:= ""									// Perguntas de Cross Selling.
Local sMV_PAR03		:= ""									// Perguntas de Cross Selling.
Local sMV_PAR04		:= ""									// Perguntas de Cross Selling.
Local sMV_PAR05		:= CTOD("//")							// Perguntas de Cross Selling.
Local sMV_PAR06		:= CTOD("//")							// Perguntas de Cross Selling.
Local sMV_PAR07		:= ""									// Perguntas de Cross Selling.
Local sMV_PAR08		:= ""									// Perguntas de Cross Selling.
Local cMemAux		:= ""									// Variavel de auxilio para preenchimento do memo.
Local nLinhas		:= 0									// Contador de linhas do memo
Local nCntFor		:= 0 									// Contador do for.
Local oOutBound												// Objeto da Flag abaixo.
Local lOutBound		:= .F.									// Flag para identificar se sera ou nao gerada lista de OutBound.
Local oArqOut												// Get para arquiivo de comunicacao
Local cArqOut		:= SPACE(20)							// Arquivo de comunicacao
Local oDirOut												// Diretorio para gravacao do arquivo de OutBound
Local cDirOut		:= SPACE(60)							// Variavel com o endereco para gravacao do arquiivo de OutBound.
Local oIdenOut												// Flag para identificacao do Agente na Lista de OutBound.
Local cIdenOut		:= "   "								// Flag para identificacao do Agente na Lista de OutBound.
Local lAgente		:= .F.									// identificacao do agente. Flag para passagem de parametro.
Local nSaveSX8		:= GetSX8Len()							// Controle de numeracao da 8.11
Local oArqFax												// Arquivo de fax.
Local cArqFax		:= Criavar("U4_MALADIR",.F.) 			// Arquivo de fax.
Local oFont													// Objeto para controle da fonte
Local lOS			:= .F.									// Se é seleçao de contado pelo apontamento da OS
Local cOSIni		:= ""									// Ordem de serviço de análise inicial
Local cOSFim		:= ""									// Ordem de serviço de análise final
Local lEntMonOS		:= .F.									// Define se a pesquisa do field é por confirmação de data de entrega/montagem O.S.
Local aPDCols		:= {}
Local aGetX5T5		:= FWGetSX5("T5")						// Carrega as informações da Tabela Genérica T5

#IFDEF TOP
	Local lTop	:= .T.
#ELSE
	Local lTop	:= .F.
#ENDIF

Private INCLUI := .T.

DEFINE FONT oFont   NAME "Arial" SIZE 0,16 BOLD

aFields		:= Tk061RetField()	// Campos do SU4 adicionais ao Wizard.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa desta forma para criar uma nova instancia de variaveis private ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( "SU4", .T. )

// Inicializa variavel
Aadd(aOper,{.F.,,,})
Aadd(aResumo,{,})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona as entidades para informação da tela de entidades.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aGetX5T5)

	Aadd(aEntidades, {AllTrim(aGetX5T5[nI,03]),AllTrim(aGetX5T5[nI,04]),"T5",""})

	// Armazena os Perguntes para apresentação no WIZARD
	Do Case
		Case aEntidades[nI][1]  == "SU2"	//Concorrentes
			aEntidades[nI][4] := "TMK066"

		Case aEntidades[nI][1]  == "AC4"	//Parceiros
			aEntidades[nI][4] := "TMK064"

		Case aEntidades[nI][1]  == "ACH"	//Suspects
			aEntidades[nI][4] := "TMK064"

		Case aEntidades[nI][1]  == "SA1"	//Clientes
			aEntidades[nI][4]	:= "TMK061"

		Case aEntidades[nI][1]  == "SA2"	//Fornecedores
			aEntidades[nI][4] := "TMK065"

		Case aEntidades[nI][1]  == "SA4"	//Transportadoras
			aEntidades[nI][4] := "TMK067"

		Case aEntidades[nI][1]  == "SUS"	//Prospects
			aEntidades[nI][4] := "TMK063"

		Case aEntidades[nI][1]  == "BAU"	//Prestadores
			aEntidades[nI][4] := "TMK070"
	Endcase

Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena o array pela descricao dos arquivos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEntidades:= ASort(aEntidades,,,{|x,y| x[2] < y[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena array de paineis para a build Exp					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aEntidades)
	Aadd(aPFilt,"oPFilt"+Alltrim(Str(nI)))
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna a posicao do Alias SA1 para Cross Selling.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosSA1 := Ascan(aEntidades,{|aVal|aVal[1]=="SA1"})
If nPosSA1 > 0
	 nEntidade := nPosSA1
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa funcao que verifica se existe contatos a serem        ³
//³trabalhados pelo conceito de Periodicidade por Ultimo Contato.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TkPosto(TkOperador(),"U0_PERIODO") == "2"
	Tk061AvalUlt()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do Wizard principal.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//"Assistente para Lista de Contatos" "Selecione o tipo de Lista desejado " , "Que tipo de lista será gerado ? "
DEFINE WIZARD oWizard 												;
	TITLE STR0002 HEADER STR0003 MESSAGE STR0004 					;
	TEXT " " 														;
	NEXT {||	If(nRadP1 == 5 .OR. nRadP1 == 6,;
				 ( oWizard:nPanel+=3,TK061OSConfig( @cOSIni, @cOSFim, @nEntidade, nPosSA1, @lOS, aEntidades, @cPergunte , nRadP1, @lEntMonOS),.T. ),;
				 	(	lOS:=.F.,;				 		
				 		TK061P1(@nRadP1,@nAniver,@nPeriod,nOpc,@lLstDiaria);
				 	);
				);
			} 	;
	FINISH {||.F.} PANEL NOFIRSTPANEL 

	oWizard:GETPANEL(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 1.					   ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(1) PIXEL
	@ 15,20 RADIO oRadP1 VAR nRadP1 ITEMS	STR0005,STR0006,STR0007,STR0008,STR0165,STR0167 SIZE 160,10 PIXEL OF oWizard:GETPANEL(1); //"Confirmação Entrega e Montagem (Sigaloja/Sigatec)"
	ON CHANGE Tk061nRadP1(nRadP1,@oMemo1,@cMemo1,@cMemoA,@cMemoB,@cMemoC,@cMemoD, @cMemoE, @cMemoF)	 
	
	If TkPosto(TkOperador(),"U0_ANIVERS") == "2" 
		oRadP1:EnableItem( 3, .F. )
	Endif
	If TkPosto(TkOperador(),"U0_PERIODO") == "1" // Nao trabalha periodicidade.
		oRadP1:EnableItem( 4, .F. )
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo1 	:=""
	cMemAux := STR0010//"A opção Lista de Contato permitirá a geração padrão de Listas de acordo com os dados informados neste assistente."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo1 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	cMemAux	:= STR0010
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemoA += MemoLine( cMemAux, 100, nCntFor ) + CRLF //"A opção Lista de Contato permitirá a geração padrão de Listas de acordo com os dados informados neste assistente." 		
	Next nCntFor 

	cMemAux := STR0011//"A opção Lista de CrossSeling efetuará a geração de lista baseada no perfil de compra dos contatos."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemoB += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	cMemAux := STR0012//"A opção Lista de Aniversário permitirá a seleção de contatos com base no campo Data de Aniversário do cadastro de contatos."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemoC += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 
 
	cMemAux := STR0013//"A opção Lista de Periodicidade permite a seleção baseada no campo Periodo do Cadastro de contatos. O objetivo da periodicidade é trabalhar contatos em um determinado intervalo de tempo."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemoD += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 
	
	cMemAux := STR0166 // "A opção Pesquisa de Satisfação - Field Service, considera todos os atendimentos das Ordens de Serviço (do Field Service) permitindo a geração da lista de contatos."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemoE += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 	
	
	cMemAux := STR0168 //"A opção Confirmação de Data de Entega/Montagem considera todas as Ordens de serviços (da Gestão de Serviços, SIGATEC) de Entrega ou Montagem que estejam abertas e sejam provenientes do Controle de Lojas (SIGALOJA)." 
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas
		cMemoF += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 		
	
	@ cLinMemo,cColMemo GET oMemo1 VAR cMemo1 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(1) PIXEL WHEN .T. READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 2.					   ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0014 MESSAGE STR0015 ;//"Objetivo da Lista." " Esta lista será trabalhada como Marketing ou Vendas?"
			 BACK {||.T.};
			 NEXT {|| (Tk061PSell(	@oWizard	,@oEntidade		,Len(aEntidades)	,nPosSA1	,;
			 						nRadP1		,oEntVendas	),;
			 			Tk061VldCross(	nRadP1		,@sMV_PAR01		,@sMV_PAR02		,@sMV_PAR03	,;
				 						@sMV_PAR04	,@sMV_PAR05		,@sMV_PAR06		,@sMV_PAR07	,;
				 						@sMV_PAR08 	,oWizard		,nTpLista		,@cPergunte)),; 
			 			Tk061AtuFiltro(@oWizard,nEntVendas,@cFiltro,@nEntidade,aEntidades,cPergunte),;
			 			nTipo:=nTpLista,;
			 			M->U4_TIPO:=Iif(nTpLista==1,ALLTRIM(STR(nTpLista)),IIF(nTpLista == 2,"3","4")),;
			 			M->U4_TELE := IIF(nTpLista == 3,"5",ALLTRIM(STR(nTpLista))),;
			 			Tk061PosTipo(nTipo,aOper,oOpers,oOk,oNo),.T.};
			 FINISH {||.F.} PANEL
	oWizard:GETPANEL(2)

	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(2) PIXEL
	If FindFunction("_ISTMKTS") .AND. _ISTMKTS()
		@ 15,20 RADIO oTpLista VAR nTpLista ITEMS STR0016,STR0017, STR0159  SIZE 120,10 PIXEL OF 	oWizard:GETPANEL(2) //U4_TIPO //"Marketing " "Vendas" "TeleAtendimento"
	Else
		@ 15,20 RADIO oTpLista VAR nTpLista ITEMS STR0016,STR0017  SIZE 120,10 PIXEL OF 	oWizard:GETPANEL(2) //U4_TIPO //"Marketing " "Vendas" 
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cMemAux := STR0018+CRLF+STR0019+IIf(FindFunction("_ISTMKTS").AND._ISTMKTS(),CRLF+STR0160,"") //"As Listas de Marketing poderão ser utilizadas para todas as entidades. Exemplo: Campanhas de Satisfação para Fornecedores."//"As Listas de Vendas serão utilizadas somente para Clientes ou Prospects." //"As Listas de Teleatendimento poderão ser utilizadas para todas as entidades"
	nLinhas  := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo2 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	@ cLinMemo,cColMemo GET oMemo2 VAR cMemo2 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(2) PIXEL WHEN .T.  READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 3.					   ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard HEADER STR0020 MESSAGE STR0021 BACK {||.T.}; //"Lista de Marketing" " Qual Entidade será trabalhada? "
					  NEXT {||(	Tk061P3			(@oWizard,	nRadP1,		@cPergunte,	aEntidades,;
												 nEntidade)),;
								Tk061AtuFiltro	(@oWizard,	nEntVendas,	@cFiltro,	@nEntidade,;
												aEntidades,	cPergunte)};
					  FINISH {||.F.} PANEL
	
	oWizard:GETPANEL(3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega vetor com as entidades para selecao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEntAux := {}
    For nI := 1 To Len(aEntidades)
    	Aadd( aEntAux, aEntidades[nI][2] )
    Next nI 		
    
	 	
  	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(3) PIXEL	
	@ 08,02 SCROLLBOX oScroll SIZE 79,277 OF oWizard:GETPANEL(3)
	oEntidade := TRadMenu():New( 05,20, aEntAux, bSETGET(nEntidade), OSCROLL,,,,,,,,100,15,,,,.T. )
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo3 := STR0022 + CRLF //"Selecione a entidade para a interação de marketing."
	@ cLinMemo,cColMemo GET oMemo3 VAR cMemo3 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(3) PIXEL WHEN .T.  READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 4.					   ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0017 MESSAGE STR0021 ; //"Vendas" "Qual entidade será trabalhada? "
						  BACK {|| IIF(nTpLista == 2,oWizard:nPanel-=1,),.T.};
						  NEXT {|| cPergunte :=IIF(nEntVendas==1,"TMK061","TMK063") ,Pergunte(IIF(nEntVendas==1,"TMK061","TMK063"),.T.),;
						  Tk061AtuFiltro(@oWizard,nEntVendas,@cFiltro,@nEntidade,aEntidades,cPergunte)};
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(4)

  	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(4) PIXEL	
  	@ 15,20 RADIO oEntVendas VAR nEntVendas ITEMS STR0023,STR0024  SIZE 120,15 PIXEL OF oWizard:GETPANEL(4) //"Cliente" "Prospect"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo4 := STR0025+CRLF //"Selecione a entidade para a interação de vendas."
	@ cLinMemo,cColMemo GET oMemo4 VAR cMemo4 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(4) PIXEL WHEN .T.  READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 5.Detalhada / Genérica³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0026 MESSAGE STR0027 ;
						  BACK {||IIF( (nRadP1 == 5 .OR. nRadP1 == 6), oWizard:nPanel-=3 , Iif (nRadP1 <> 2,IIF(nTpLista == 1,oWizard:nPanel-=1,),oWizard:nPanel-=2 )),.T.};
						  NEXT {|| ,Tk061Det(nDetCont,@oHrIni,@oHrFim,@oSayP14A,@oSayP14B),IIF(nDetCont==1,PERGUNTE("TMK060",.T.),.T.)}; // PERGUNTE DE CONTATO
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(5)
	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(5) PIXEL	
	@ 15,20 RADIO oDetCont VAR nDetCont ITEMS STR0028,STR0029  SIZE 135,15 PIXEL OF oWizard:GETPANEL(5)//"Detalhada" "Padrão (Considera parâmetros em branco.)"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemAux :=STR0030 //"A opção Detalhada apresenta um grupo de parâmetros referentes ao Perfil do Contato."
	nLinhas  := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo5 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	@ cLinMemo,cColMemo GET oMemo5 VAR cMemo5 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(5) PIXEL WHEN .T.  READONLY


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 6.Meio de interacao   ³	// U4_FORMA
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0031 MESSAGE STR0032 ; //"Meio de Interação" " Qual será o meio de comunicação com o contato? "
						  BACK {||.T.};
						  NEXT {|| IIF(nForma <> 1, IIF(nForma == 2,oWizard:nPanel+=1,Iif(nForma==3,oWizard:nPanel+=2,oWizard:nPanel+=4)),),;
						  				Tk061AjusForma(@nForma) ,.T.};  //VALIDAR PROXIMOS PAINEIS
						  FINISH {||.F.} PANEL

	oWizard:GETPANEL(6)
	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(6) PIXEL	
	@ 15,20 RADIO oForma VAR nForma ITEMS STR0033,STR0034,STR0035,STR0043  SIZE 120,15 PIXEL OF oWizard:GETPANEL(6) //"Voz" "Cross Posting""Mala Direta" //"Fax"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo6 := " "
	cMemo6 := STR0036 +CRLF //"Voz - Interação via telefone."
	cMemo6 += STR0037+CRLF //"Mala Direta - Interação via correspondência."
	cMemo6 += STR0038+CRLF //"Cross Posting - Interação via e-mail."
	cMemo6 += STR0126 //"Fax - Contato via Fax."
	@ cLinMemo,cColMemo GET oMemo6 VAR cMemo6 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(6) PIXEL WHEN .T.  READONLY


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 7.Voz  			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0039 MESSAGE STR0040; //"Telefones para contato:" "Em quais telefones deseja encontrar o contato? "
						  BACK {||.T.};
						  NEXT {|| 	oWizard:nPanel+=4,.T.};  
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(7)
	
	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(7) PIXEL	
	
	@ 10,20 RADIO oRadFone VAR nRadFone ITEMS STR0041,STR0042,STR0043,STR0044,STR0045  SIZE 120,15 PIXEL OF oWizard:GETPANEL(7) // Residencial, celular, fax , comercial 1 e Comercial 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo7 := STR0046 + CRLF //"Selecione o telefone que será utilizado para o contato."
	@ cLinMemo,cColMemo GET oMemo7 VAR cMemo7 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(7) PIXEL WHEN .T.  READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 8. Cross Posting       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0047 MESSAGE " "  BACK {||OWIZARD:nPanel-=1,.T.};
						  NEXT {|| IIF(Tk061ValEmail(cSubj,cMens),(oWizard:nPanel+=3,.T.),.F.)};  
						  FINISH {||.F.};
						  EXEC{||Tk061AtuAnexo(@oAttach,@cAttach,aArq)} PANEL
	oWizard:GETPANEL(8)

	
	@ 02, 04 TO  25,260 OF oWizard:GETPANEL(8) PIXEL
	@ 09, 08 SAY STR0048	OF oWizard:GETPANEL(8) SIZE 40,8 PIXEL  //"Assunto"
	@ 09, 32 GET oSubj VAR cSubj OF oWizard:GETPANEL(8) SIZE 225,8 PIXEL 
		
	@ 27, 04 TO 86,260 LABEL STR0049 OF oWizard:GETPANEL(8) PIXEL //"Mensagem"
	@ 33, 06 GET oMens VAR cMens OF oWizard:GETPANEL(8) MEMO SIZE 250,50 PIXEL 
		
	@ 088,04 TO 135,260 LABEL "" OF oWizard:GETPANEL(8) PIXEL 
	If Len(aArq) = 0 
		Aadd(aArq,"")
	Endif
	
	@ 92,06 LISTBOX oAttach VAR nAttach FIELDS HEADER STR0113 SIZE 250,42 OF oWizard:GETPANEL(8) PIXEL NOSCROLL
		oAttach:SetArray(aArq)
		oAttach:Refresh()
	
	DEFINE SBUTTON FROM 092 ,262 TYPE 4 PIXEL ACTION (Tk061Anexo(@aArq,@oAttach,@cAttach)) ENABLE OF oWizard:GETPANEL(8) 
	DEFINE SBUTTON FROM 107 ,262 TYPE 2 PIXEL ACTION (Tk061RemAne(@aArq,@oAttach,@cAttach)) ENABLE OF oWizard:GETPANEL(8) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 9.Mala Direta		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0051 MESSAGE STR0052; //"Endereços para envio de Mala Direta:" "Quais endereços deverão ser pesquisados para seleção? "
						  BACK {||OWIZARD:nPanel-=2,.T.};
						  NEXT {|| .T.};  
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(9)
	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(9) PIXEL	
	
	@ 10,20 RADIO oTpEnd VAR nTpEnd ITEMS STR0041,STR0053 SIZE 120,15 PIXEL OF oWizard:GETPANEL(9)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo9 := " "
	cMemAux :=STR0054 + CRLF+STR0055 + CRLF	+ STR0056 + CRLF//"Informe onde serão pesquisados os endereços para envio de Mala Direta."//"Residencial - Cadastro de Contatos." "Comercial - Cadastro de Entidades. "
	nLinhas  := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo9 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	@ cLinMemo,cColMemo GET oMemo9 VAR cMemo9 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(9) PIXEL WHEN .T.  READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 10.Detalhes Mala Direta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0057 MESSAGE " "  BACK {||.T.}; //"Detalhes para envio de Mala Direta:"
						  NEXT {||OWIZARD:nPanel+=1,.T.};  
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(10)
	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(10) PIXEL	
	@ 15,20 SAY STR0058 OF oWizard:GETPANEL(10) PIXEL SIZE 150,9  //"Informe o Modelo de Mala Direta:"
	@ 25,20 MSGET oArqMala VAR cArqMala SIZE 150,10 F3 "ARQ" VALID (cArqMala := M->U4_MALADIR) OF oWizard:GETPANEL(10) PIXEL WHEN .T.

	@ 40,20 CHECKBOX oEtiq  VAR lEtiq  PROMPT STR0059 OF oWizard:GETPANEL(10) SIZE 100,10 ; //"Gera Etiquetas."
							 ON CHANGE IIF(lEtiq,oArqEtiq:Enable(),oArqEtiq:Disable())PIXEL 
		
	@ 55,20 SAY STR0060 OF oWizard:GETPANEL(10) PIXEL SIZE 150,9  //"Modelo de Etiquetas:"
	@ 65,20 MSGET oArqEtiq VAR cArqEtiq SIZE 150, 10 F3 "AR1" VALID (IIF(lEtiq .AND. EMPTY(cArqEtiq),.F.,.T.),(cArqEtiq := M->U4_ETIQUET)) OF oWizard:GETPANEL(10) PIXEL WHEN .T.   

	M->U4_MALADIR := cArqMala // Arquivo de Mala
	M->U4_ETIQUET := cArqEtiq // Arquivo de Etiquetas

	DEFINE SBUTTON FROM 65,200 TYPE 15 ENABLE OF oWizard:GETPANEL(10) ACTION Tk061Visual()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemAux :=STR0061 //"Selecione nesta tela os arquivos modelos para Mala Direta e Etiqueta. "
	nLinhas  := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo10 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	@ cLinMemo,cColMemo GET oMemo10 VAR cMemo10 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(10) PIXEL WHEN .T. READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 11.Fax     		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0127 MESSAGE STR0128;  //"Telefone e arquivo para envio de fax."###"Qual endereço deve ser pesquisado para seleção e qual sera o arquivo?"
						  BACK {||OWIZARD:nPanel-=4,.T.};
						  NEXT {|| .T.};  
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(11)
	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(11) PIXEL	
	
	@ 10,20 RADIO oTpFax VAR nTpFax ITEMS STR0041,STR0053 SIZE 120,15 PIXEL OF oWizard:GETPANEL(11)

	@ 55,20 SAY STR0129 OF oWizard:GETPANEL(11) PIXEL SIZE 150,9   //"Arquivo de fax:"
	@ 65,20 MSGET oArqFax VAR cArqFax SIZE 150,10 F3 "ARQ" VALID (M->U4_MALADIR:=cArqFax) OF oWizard:GETPANEL(11) PIXEL WHEN .T.

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodape para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo11 := " "
	cMemAux :=STR0130 + CRLF+STR0131 + CRLF	+ STR0132 + CRLF  //"Informe onde serão pesquisados os endereços para envio de Fax."###"Residencial - Cadastro de Contatos."###"Comercial - Cadastro de Entidades. "
	nLinhas  := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo11 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	@ cLinMemo,cColMemo GET oMemo11 VAR cMemo11 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(11) PIXEL WHEN .T.  READONLY


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 12 Tipo de selecao do Operador ³ // U4_OPERAD
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	CREATE PANEL oWizard  HEADER STR0068 MESSAGE STR0135  ;
					BACK {|| IIF(nForma <> 4, IIF(nForma == 3,oWizard:nPanel-=1,Iif(nForma == 2,oWizard:nPanel-=3,oWizard:nPanel-=4)),),.T.}; //"Operadores."
					NEXT {|| Iif(nRadOper==1,(oWizard:nPanel+=1),Tk061P13Show(nRadOper		,oSayP13	,oSayP13A	,oOperad,;
																				oOpers		,aOper		,oSayGrupo1	,oGrupo	,;
																				oSayGDes	,oSayP13B	,oSayP13C	,oSayGrupo2,;
																				oSayGrupo3	,@lGrupo	)),.T.};
					FINISH {||.F.} PANEL
	oWizard:GETPANEL(12)

	@ 05,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(12) PIXEL
	@ 15,20 RADIO oRadOper VAR nRadOper ITEMS STR0134,STR0136,STR0074,STR0137  SIZE 120,10 PIXEL OF oWizard:GETPANEL(12);
   	   	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemAux :=STR0138+CRLF//"Informe o modelo de seleção do operador desejado."
	cMemAux +=STR0139+CRLF//"Tipos de seleção: "
	cMemAux +=STR0140+CRLF//"Aberta: O sistema não definirá um operador para a Lista de Contatos e esta poderá ser executada por qualquer operador."
	cMemAux +=STR0141+CRLF//"Seleção Manual: O sistema apresentará uma nova tela para a informação do operador."
	cMemAux +=STR0075+CRLF//"Seleção Automática: O sistema apresentará uma tela para seleção de operadores. Estes operadores serão avaliados de acordo com a quantidade de tarefas. Aquele que tiver a menor quantidade de tarefas será selecionado para a Lista de Contatos."
	cMemAux +=STR0142+CRLF//"Seleção por Grupo: Nesta opção o sistema irá dividir os contatos selecionados igualmente entre todos os integrantes de um grupo."

	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo12 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	@ cLinMemo,cColMemo GET oMemo12 VAR cMemo12 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(12) PIXEL WHEN .T. READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 13 Selecao do Operador³      	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0143 MESSAGE STR0144  ;
					BACK {|| .T.}; 
					NEXT {|| IIF(nRadOper==3,cOperad:=Tk061ChkOp(aOper),""),Tk061P13Vld(nRadOper,cOperad,cGrupo)};
					FINISH {||.F.} PANEL
	oWizard:GETPANEL(13)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Label do painel³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	@ 10,00 TO 90,280 LABEL "" OF oWizard:GETPANEL(13) PIXEL	              
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a selecao seja manual apresenta get para definicao do³
	//³operador.                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSayP13  := STR0145 //"Selecione o "
	cSayP13B := STR0146 //" para esta lista.               (Seleção Manual) "
	cSayP13C := STR0001 // Operador
	@ 20,19 SAY oSayP13  Var cSayP13  OF oWizard:GETPANEL(13) PIXEL SIZE 210,9 
	@ 20,53 SAY oSayP13C Var cSayP13C OF oWizard:GETPANEL(13) PIXEL SIZE 210,9 FONT oFont COLOR CLR_BLUE 
	@ 20,80 SAY oSayP13B Var cSayP13B OF oWizard:GETPANEL(13) PIXEL SIZE 210,9 
	@ 50,20 MSGET oOperad VAR cOperad SIZE 35, 10 F3 "FU7" OF oWizard:GETPANEL(13) VALID(cSayP13A := Posicione("SU7",1,xFilial("SU7")+cOperad,"U7_NOME"),oSayP13A:Refresh()) PIXEL WHEN .T.

	@ 52,60 SAY oSayP13A Var FATPDObfuscate(cSayP13A,"U7_NOME")  OF oWizard:GETPANEL(13) PIXEL SIZE 210,9   


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a selecao seja AUTOMATICA apresenta listbox para a       ³
	//³definicao do operador.                                  		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Esta tela permite a selecao dos operadores que participarao da avaliacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 15,02 LISTBOX oOpers FIELDS ;
		HEADER ;
			"",;
			STR0071,;//"Código"
			STR0072,;//"Nome                  "
			STR0073; //"Tarefas"
		ON DbLCLICK (aOper[oOpers:nAt,1]:= !aOper[oOpers:nAt,1], oOpers:Refresh());
		ON CHANGE (nOper:= oOpers:nAt) SIZE 276,72 OF oWizard:GETPANEL(13) PIXEL NOSCROLL 
		
	oOpers:SetArray(aOper)
	oOpers:bLine:={||{IIF(aOper[oOpers:nAt,1],oOk,oNo),;		
						   aOper[oOpers:nAt,2],;		
					 	   aOper[oOpers:nAt,3],;		
					 	   aOper[oOpers:nAt,4]}}              		
		
	If FATPDActive() .And. FTPDUse(.T.)
		aPDCols := {"","","U7_NOME",""} 
		oOpers:aObfuscatedCols := FATPDColObfuscate(aPDCols)    
	Endif

	oOpers:Refresh()
	oOpers:Hide()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a selecao seja Por GRUPO  apresenta GET para definicao   ³
	//³do grupo que sera trabalhado.                           		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cSayGrupo1 := STR0145//"Selecione o "
	cSayGrupo2 := STR0147//"Grupo" 
	cSayGrupo3 := STR0148//" para a distribuição das ligações desta Lista."
	
	@ 20,19 SAY oSayGrupo1 Var cSayGrupo1 OF oWizard:GETPANEL(13) PIXEL SIZE 210,9 
	@ 20,53 SAY oSayGrupo2 Var cSayGrupo2 OF oWizard:GETPANEL(13) PIXEL SIZE 210,9 FONT oFont COLOR CLR_BLUE 
	@ 20,70 SAY oSayGrupo3 Var cSayGrupo3 OF oWizard:GETPANEL(13) PIXEL SIZE 210,9 
	
	@ 50,20 MSGET oGrupo VAR cGrupo SIZE 35, 10 F3 "SU0" OF oWizard:GETPANEL(13) VALID(cSayGDes := Posicione("SU0",1,xFilial("SU0")+cGrupo,"U0_NOME"),oSayGDes:Refresh()) PIXEL WHEN .T.

	@ 52,60 SAY oSayGDes Var cSayGDes OF oWizard:GETPANEL(13) PIXEL SIZE 210,9 

	oSayGrupo1:Hide()	
	oSayGrupo2:Hide()	
	oSayGrupo3:Hide()	
	oGrupo:Hide()	 
	oSayGDes:Hide()	
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemAux := STR0149 //"Informe os dados para a seleção do Operador."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo13 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 

	@ cLinMemo,cColMemo GET oMemo13 VAR cMemo13 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(13) PIXEL WHEN .T. READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 14 Restante dos campos³      	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0078 MESSAGE " "  BACK {||Iif(nRadOper==1,oWizard:nPanel-=1,"") ,.T.}; //"Informações adicionais."
						  NEXT {||oWizard:nPanel+=Iif(lOS,1,0),aPFilt[nEntidade]:Show(), IIF( cPergunte == "TMK068", Dbselectarea("SD2"),DbSelectArea(aEntidades[nEntidade][1]) ),Obrigatorio(oEnchoice:aGets,oEnchoice:aTela)};
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(14)
      
	//Enchoice     
	
	AAdd(aObjects,{277,009,.F.,.F.})
	AAdd(aObjects,{277,069,.F.,.F.})
	aInfo := {aSizeAut[1],aSizeAut[2]-12,aSizeAut[3],aSizeAut[4],3,3} 
	aPosObj := MsObjSize(aInfo,aObjects,.T.)
	oEnchoice := MSMGet():New( "SU4", nReg, nOpc, , , , ,aPosObj[2],,3,,,,oWizard:GETPANEL(14),,,,,,,aFields)
                                                                   
	cSayP14A := STR0079 //"Hora Inicial:"
	@ 79,005 SAY oSayP14A VAR cSayP14A OF oWizard:GETPANEL(14) PIXEL SIZE 100,9 
	@ 77,040 MSGET oHrIni VAR cHrIni SIZE 30, 10  PICTURE "99:99" VALID !EMPTY(cHrIni) OF oWizard:GETPANEL(14) PIXEL 
	
	cSayP14B := STR0080 //"Hora Final:"
	@ 79,075 SAY oSayP14B VAR cSayP14B  OF oWizard:GETPANEL(14) PIXEL SIZE 100,9 
	@ 77,107 MSGET oHrFim VAR cHrFim SIZE 30, 10 PICTURE "99:99" VALID !EMPTY(cHrFim) OF oWizard:GETPANEL(14) PIXEL 
   		
	// Inicializa objetos escondidos e somente se necessario apresenta para inclusao dos dados.
	oSayP14A:Hide()
	oHrIni:Hide()
	oSayP14B:Hide()
	oHrFim:Hide()	
	
	@ 79,144 SAY OemToAnsi(STR0081) OF oWizard:GETPANEL(14) PIXEL SIZE 150,9  //"Número máximo de Itens por Lista:"
	@ 77,246 MSGET oTotLista VAR cTotLista SIZE 35, 10 PICTURE "999999" OF oWizard:GETPANEL(14) PIXEL ;
			VALID (cTotLista := StrZero(Val(cTotLista),6),oTotLista:Refresh() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemAux :=STR0082+CRLF+STR0083+CRLF//"Informacao dos demais campos da Lista."//"Se a seleção do contato não for detalhada serão apresentados os campos de horário inicial e final para a Interação."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo14 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 
	@ cLinMemo,cColMemo GET oMemo14 VAR cMemo14 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(14) PIXEL WHEN .T. READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 15 Filtro             ³      	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0078 MESSAGE STR0164 BACK {|| .T.}; //"Filtro da entidade selecionada" 
						  NEXT {|| .T.};
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(15)

    // Cria paineis de acordo com a quantidade de entidades.
   	@ 01,38 TO 96,245 LABEL "" OF oWizard:GETPANEL(15) PIXEL
    For nI := 1 To Len(aPFilt)                                                                     
	    @ 05,40 MSPANEL aPFilt[nI] VAR "" OF oWizard:GETPANEL(15) CENTERED SIZE 199,89  
 		BuildExpr(aEntidades[nI][1]  ,,@cFiltro,, {||oWizard:oNext:Click()}, aPFilt[nI])
 		aPFilt[nI]:Hide()
    Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodape para auxilio ao usuario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo15 := STR0084 + CRLF //"Informe o Filtro para selecao da base."
	@ cLinMemo,cColMemo GET oMemo15 VAR cMemo15 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(15) PIXEL WHEN .T. READONLY


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 16 Filtro             ³      	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0162 MESSAGE STR0163  BACK {|| oWizard:nPanel-=Iif(lOS,1,0),.T.}; //"Filtro de contatos"###"Filtro adicional para seleção de contatos"
						  NEXT {|| IIF ((TkPosto(TkOperador(),"U0_TIPOCTI")  == "2") .AND.;
									     (TkPosto(TkOperador(),"U0_TIPOATE") == "1")  .AND.;
									     (nForma == 1),,(Tk061Res(	@oResumo	,@aResumo	,nRadP1		,nTpLista	,;
																	nEntVendas	,nDetCont	,nForma		,nTpFax		,;
																	cArqFax		,cSubj		,cMens		,cAttach	,;
																	cArqMala	,cArqEtiq	,nTipo		,cOperad	,;
																	cSayP13A	,cFiltro	,aEntidades	,nEntidade	,;
																	@cEntidade	,nRadFone	,nTpEnd		,cTotLista	,;
																	cHrINI		,cHrFim		,sMV_PAR01	,sMV_PAR02	,;
																	sMV_PAR03	,sMV_PAR04	,sMV_PAR05	,sMV_PAR06 	,;
																	sMV_PAR07   ,sMV_PAR08	,.F.		,NIL		,;
																	NIL			,NIL		,nRadOper	,cGrupo) ,oWizard:nPanel+=1)),; //CTI e Lista de OutBound e Contato por Voz,;
											.T.};
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(16)

    // Cria paineis de acordo com a quantidade de entidades.
   	@ 01,38 TO 96,245 LABEL "" OF oWizard:GETPANEL(16) PIXEL
    For nI := 1 To Len(aPFilt)
	    @ 05,40 MSPANEL aPFilt[nI] VAR "" OF oWizard:GETPANEL(16) CENTERED SIZE 199,89  
		BuildExpr("SU5" ,,@cFiltroU5,/*lTop*/, {||oWizard:oNext:Click()}, aPFilt[nI],,,,,,,,@cFiltU5SQL)
		aPFilt[nI]:Hide()
    Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodape para auxilio ao usuario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemo15 := STR0161 + CRLF //"Informe o filtro para selecao dos contatos."
	@ cLinMemo,cColMemo GET oMemo15 VAR cMemo15 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(16) PIXEL WHEN .T. READONLY

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 17 Lista de OutBoud      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    CREATE PANEL oWizard  HEADER STR0114 MESSAGE STR0115  BACK {|| .T.}; //"Lista de OutBound"##"Gera lista OutBound?"
						  NEXT {||Tk061Res(	@oResumo	,@aResumo	,nRadP1		,nTpLista	,;
											nEntVendas	,nDetCont	,nForma		,nTpFax		,;
											cArqFax		,cSubj		,cMens		,cAttach	,;
											cArqMala	,cArqEtiq	,nTipo		,cOperad	,;
											cSayP13A	,cFiltro	,aEntidades	,nEntidade	,;
											@cEntidade	,nRadFone	,nTpEnd		,cTotLista	,;
											cHrINI		,cHrFim		,sMV_PAR01	,sMV_PAR02	,;
											sMV_PAR03	,sMV_PAR04	,sMV_PAR05	,sMV_PAR06 	,;
											sMV_PAR07   ,sMV_PAR08	,lOutBound	,cArqOut	,;
											cDirOut		,cIdenOut	,nRadOper	,cGrupo) ,Tk061VP16(cArqOut,cDirOut)};
						  FINISH {||.F.} PANEL
	oWizard:GETPANEL(17)
    
  	//Label
  	@ 005,000 TO 90,280 LABEL "" OF oWizard:GETPANEL(17) PIXEL	

	// CheckBox para geracao do OutBound.
	@ 010,005 CHECKBOX oOutBound  VAR lOutBound  PROMPT STR0116  OF oWizard:GETPANEL(17) SIZE 100,10 ON CHANGE Tk061P16Show(lOutBound,@oDirOut,@oArqOut,@oIdenOut) PIXEL //"Gera Lista de OutBound."

	// arquivo
	@ 22,005 SAY STR0117 OF oWizard:GETPANEL(17) PIXEL SIZE 50,9 //"Nome do Arquivo: "
	@ 20,065 MSGET oArqOut VAR cArqOut SIZE 100, 10  PICTURE "@!" OF oWizard:GETPANEL(17) PIXEL 
	
	// Diretorio
	@ 37,005 SAY STR0118 OF oWizard:GETPANEL(17) PIXEL SIZE 60,9 //"Local para o Arquivo: "
	@ 35,065 MSGET oDirOut VAR cDirOut SIZE 100, 10  PICTURE "@!" OF oWizard:GETPANEL(17) PIXEL 

	DEFINE SBUTTON FROM 35,175 TYPE 3 ENABLE OF oWizard:GETPANEL(17) ;
	ACTION cDirOut := cGetFile(STR0119,OemToAnsi(STR0120),0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE+128)//"Arquivos Texto|*.TXT|Todos os Arquivos|*.*""Salvar Arquivo Como..."
	
	// Identifica agente S/N
	@ 52,005 SAY STR0121 OF oWizard:GETPANEL(17) PIXEL SIZE 50,9 //"Identifica Agente? "
	@ 50,065 COMBOBOX oIdenOut VAR cIdenOut ITEMS {STR0122,STR0123} VALID lAgente:= IIF(SUBSTR(cIdenOut,1,1)=="1",.T.,.F.) OF oWizard:GETPANEL(17) SIZE 50,10 PIXEL //"Sim""Não"

    oDirOut:Disable()
    oArqOut:Disable()
    oIdenOut:Disable()
    oDirOut:Refresh()
    oArqOut:Refresh()
    oIdenOut:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemAux := STR0124 + CRLF //"As listas de Outbound são arquivos de comunicação com CTI´s gerados após a seleção da lista que contém os dados do contato para efetuar o atendimento."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo16 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 
	@ cLinMemo,cColMemo GET oMemo16 VAR cMemo16 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(17) PIXEL WHEN .T. READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel 18 Resumo das Informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard  HEADER STR0085 MESSAGE STR0086 ;	 //"Resumo da Seleção." "Os dados informados para a geração foram: "
						 BACK {|| IIF ((TkPosto(TkOperador(),"U0_TIPOCTI")  == "2") 			.AND.;
											    (TkPosto(TkOperador(),"U0_TIPOATE") == "1")  	.AND.;
											    (nForma == 1),,oWizard:nPanel-=1),; //CTI e Lista de OutBound e Contato por Voz,;
											     ,.T.}; 
						  NEXT {||.T.};
						  FINISH {|| IIF( Tk061Concluir(nOpc		,cEntidade	,aEntidades	,@cMens		,;
									 					@cSubj		,@aArq		,@cAttach	,@cFiltro	,;
														@cPergunte	,nEntidade	,@cText		,nAniver 	,;
														nPeriod		,nDetCont	,cDirOut	,cArqOut	,;
														lAgente		,lOutBound	,nSaveSX8	,lLstDiaria	,;
														lGrupo		,cGrupo		,cFiltroU5	,cFiltU5SQL	,;
														lOS			,cOSIni		,cOSFim	,lEntMonOS),;
										(Tk061Help(@cText),lRet := .T.),;
										(Tk061Help(@cText),lRet := .F.) )} PANEL
	oWizard:GETPANEL(18)

   	aResumo := {{"",""}}

	@ 05,00 TO 90,280 LABEL '' OF oWizard:GETPANEL(18)  PIXEL
	@ 10,02 LISTBOX oResumo FIELDS ;
		HEADER ;
			STR0111,; // "Item                   ",;
			STR0112;  //"Informação             ";
		SIZE 277,77 OF oWizard:GETPANEL(18) PIXEL NOSCROLL 
		oResumo:nFreeze :=1
		oResumo:SetArray(aResumo)
		oResumo:bLine:={||{   aResumo[oResumo:nAt,1],;		
						 	   aResumo[oResumo:nAt,2]}}              		

		oResumo:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Observação de Rodapé para auxilio ao usuário.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMemAux := STR0087 + CRLF //"Verifique se as informações estão corretas para o início do processo de seleção."
	nLinhas := MlCount( cMemAux,100) 
	For nCntFor := 1 to nLinhas 
		cMemo17 += MemoLine( cMemAux, 100, nCntFor ) + CRLF 
	Next nCntFor 
	@ cLinMemo,cColMemo GET oMemo17 VAR cMemo17 MULTILINE SIZE 280, 40 OF oWizard:GETPANEL(18) PIXEL WHEN .T. READONLY

FATPDLogUser('TK061WIZAR')	// Log de Acesso LGPD

ACTIVATE WIZARD oWizard CENTERED WHEN {||.T.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o usuário cancelou o processo em algum momento ou o Wizard não processou com sucesso - atualiza a numeração do SX8    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet

	If ! Empty(cFiltro)
		cFiltro		:= ""
		If cPergunte == "TMK068"
			Tk061SetFilt(cFiltro, "SD2")
		Else
			Tk061SetFilt(cFiltro, cEntidade)
		Endif
	EndIf

	If ! Empty(cFiltroU5)
		cFiltroU5	:= ""
		Tk061SetFilt(cFiltroU5, "SU5")
	EndIf

	Tk061Fim(nSaveSX8)
Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061nRadP1ºAutor  ³Rafael M. Quadrottiº Data ³  12/19/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de validacao para atualizacao dos MEMOS do Wizard    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061nRadP1(nRadP1,oMemo1,cMemo1,cMemoA,cMemoB,cMemoC,cMemoD, cMemoE, cMemoF) 

Default cMemoF := ""

Do Case
	Case nRadP1 == 1
		cMemo1:=cMemoA
	Case nRadP1 == 2
		cMemo1:=cMemoB
	Case nRadP1 == 3
		cMemo1:=cMemoC
	Case nRadP1 == 4
		cMemo1:=cMemoD
	Case nRadP1 == 5
		cMemo1:=cMemoE
	Case nRadP1 == 6
		cMemo1:=cMemoF		
Endcase
oMemo1:Refresh()

Return(NIL)			

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061P1   ºAutor  ³Rafael M Quadrotti  º Data ³  08/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avalia os dados do panel 01 e permite ou nao a troca de     º±±
±±º          ³painel.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK061P1(nRadP1,nAniver,nPeriod,nOpc,lLstDiaria, lOS)
Local lRet := .F.	
	
If nRadP1 == 3 // Lista de Aniversário
	nAniver := 1
	nPeriod := 2
	lRet	:= Tk061Niver(nAniVer,nPeriod,nOpc,@lLstDiaria)
ElseIf nRadP1 == 4 // Lista de Periodicidade
	nAniver := 0
	nPeriod := 1
	lRet	:= .T.
ElseIf nRadP1 == 5 .OR. nRadP1 == 6
	lOS		:= .T.
Else                                 
	nAniver := 0
	nPeriod := 2
	lRet := .T.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061ChkOpºAutor  ³Rafael M Quadrotti  º Data ³  08/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o resultado da selecao automatica do operador.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061ChkOp(aOper)
Local nForOp		:= 0
Local aSortOper 	:= {}   // Ordena operadores por ordem crescente de tarefas.
Local aOper2		:= {}       // Operadores selecionados                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Array com os operadores selecionados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nForOp := 1 To Len(aOper)
	IF aOper[nForOp][1]   // Avalia se foi selecionado 
		Aadd(aOper2,aOper[nForOp]) 
	Endif
Next
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nenhum operador for selecionado todos serao considerados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aOper2) == 0
	aOper2 := aClone(aOper)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena array.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aOper2)>0
	aSortOper := ASORT(aOper2,,, { |x, y| x[4] < y[4] }) //CRESCENTE
Else
	Aadd(aSortOper,{"",""})
Endif


Return (aSortOper[1][2])

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061P13ShowºAutor³Rafael M Quadrotti  º Data ³  08/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita e desabilita objetos do Painel 13                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061P13Show(	nRadOper	,oSayP13	,oSayP13A	,oOperad	,;
								oOpers		,aOper		,oSayGrupo1	,oGrupo		,;
								oSayGDes	,oSayP13B	,oSayP13C	,oSayGrupo2	,;
								oSayGrupo3	,lGrupo)

// Se for selecao automatica e existir dados para exibição de List.
If nRadOper == 3 .AND. Len(aOper)> 0
	
	oSayP13:Hide()
	oSayP13A:Hide()
	oOperad:Hide()
	oSayP13B:Hide()
	oSayP13C:Hide()
	
	oOpers:Show()
	
	oSayGrupo1:Hide()
	oSayGrupo2:Hide()
	oSayGrupo3:Hide()
	oGrupo:Hide()
	oSayGDes:Hide()

	lGrupo := .F.
	
ElseIf nRadOper == 2
	oSayP13:Show()
	oOperad:Show() 
	oSayP13A:Show()
	oSayP13B:Show()
	oSayP13C:Show()


	oOpers:Hide()
	
	oSayGrupo1:Hide()
	oSayGrupo2:Hide()
	oSayGrupo3:Hide()	
	oGrupo:Hide()
	oSayGDes:Hide()

	lGrupo := .F.

ElseIf nRadOper == 4
 	oSayP13:Hide()
	oOperad:Hide()
	oSayP13A:Hide()
	oSayP13B:Hide()
	oSayP13C:Hide()


	oOpers:Hide()
	
	oSayGrupo1:Show()
	oSayGrupo2:Show()
	oSayGrupo3:Show()
	oGrupo:Show()
	oSayGDes:Show()

	lGrupo := .T.

Endif

oSayP13:Refresh() 
oSayP13A:Refresh()
oOperad:Refresh()

oOpers:Refresh()   

oSayGrupo1:Refresh()   
oSayGrupo2:Refresh()   
oSayGrupo3:Refresh()
oGrupo:Refresh()   
oSayGDes:Refresh()   

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061PosTipoºAutor³Rafael M Quadrotti  º Data ³  08/09/03     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega array de operadores apos a selecao do tipo de Lista   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºHanna C.  ³22/02/07³119893³Efetua a validacao do operador (se esta vali- º±±
±±º          ³        ³      ³do no cadastro de operadores = "1"            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061PosTipo(	nTipo,	aOper,	oOpers,	oOk,;
								oNo	)
Local cAntAlias		:= ""		//Variavel para carregar o Alias que esta aberto 
Local nAuxTipo		:= nTipo
Local aPDCols 		:= {"","","U7_NOME",""} 

// Limpa array para novos dados e para retirar a linha em branco.
aOper := {}
                                 
//Verifica quando o tipo e teleatendimento
If nAuxTipo == 3
	nAuxTipo := 6
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os operadores para a selecao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAntAlias := Alias()
DbSelectArea( "SU7" )
DbSetOrder( 1 )
DbSeek( xFilial( "SU7" ) )
While ( !Eof() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente os operadores que atuam na rotina selecionada ³
	//³do SU4 (Tmk,Tlv,Tlc,Ambos) serao carregados.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If ( (	( Val( SU7->U7_TIPOATE ) == nAuxTipo )	.OR.  ( Val( SU7->U7_TIPOATE ) == 4 ) .OR.;
    		( Val( SU7->U7_TIPOATE ) == 5 ) )		.AND. SU7->U7_VALIDO == "1" )
  		 	Aadd( aOper,{ .F.,	SU7->U7_COD,	SU7->U7_NOME,	SU7->U7_TAREFA } ) //LOGO,codigo,Nome,Qtd de Tarefas
	Endif	
	DbSkip()
End
DbSelectArea( cAntAlias ) 

oOpers:SetArray( aOper )
oOpers:bLine:={||{IIF( aOper[oOpers:nAt,1],oOk,oNo),;		
								aOper[oOpers:nAt,2],;		
						 		aOper[oOpers:nAt,3],;		
								aOper[oOpers:nAt,4]}}

If FATPDActive() .And. FTPDUse(.T.)								
	oOpers:aObfuscatedCols := FATPDColObfuscate(aPDCols)     
Endif

oOpers:Refresh() 

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061RetFielºAutor³Rafael M Quadrotti  º Data ³  08/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega array com os campos restantes para a geracaoda listaº±±
±±º          ³ via Wizard.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk061RetField() // Campos do SU4 adicionais ao Wizard. 
Local aCampos 	:= {} // Array com os campos para retorno da funcao.
Local aSArea	:= GetArea()
Local cCampos	:= "U4_FILIAL;U4_TIPO;U4_FORMA;U4_OPERAD;U4_NOPERAD;U4_TIPOTEL;U4_MALADIR;U4_TIPOEND;U4_LABEL;U4_ETIQUET;U4_HORA1"

DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("SU4") 
	While !Eof() .AND. SX3->X3_ARQUIVO == "SU4"
		If X3USO(SX3->X3_USADO)                            
	  		//Carrega todos os campos restantes
			If !(Alltrim(Upper(SX3->X3_CAMPO)) $ cCampos)
			   	Aadd( aCampos, {SX3->X3_TITULO,;
								SX3->X3_CAMPO,;
								SX3->X3_TIPO,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_PICTURE,;
								IIF(SX3->X3_CAMPO<>"U4_DATA",&("{||" + SX3->X3_VALID+ "}"),{||.T.}),;
								X3Obrigat(SX3->X3_CAMPO),;
								SX3->X3_NIVEL,;
								SX3->X3_RELACAO,;
								SX3->X3_F3,;
								&("{||" + SX3->X3_WHEN + "}"),;
								SX3->X3_VISUAL=="V",;
								.F.,; //lChave
								SX3->X3_CBOX,; // tem que validar paises.
								VAL(SX3->X3_FOLDER),; // nFolder
								.F.,;//lNAltera
								""} )//lPictVar  
			Endif
		Endif	
		DbSkip()
	End
Endif

RestArea(aSArea)
Return aCampos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061Det  ºAutor  ³Rafael M. Quadrotti º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Detalhes do painel 14									  º±±
±±º          ³ Habilita detalhes de acordo com o tipo de selecao Panel 05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061Det(nDetCont,oHrIni,oHrFim,oSayP14A,oSayP14B)

If nDetCont == 1 
	oHrIni:Hide()
	oHrFim:Hide()
	oSayP14A:Hide()
	oSayP14B:Hide()
Else
	oHrIni:Show()
	oHrFim:Show()
	oSayP14A:Show()
	oSayP14B:Show()
Endif
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061PSellºAutor  ³Rafael M. Quadrotti º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera texto para apresentacao de panel somente com a des- º±±
±±º          ³ cricao de clientes e o titulo e mensagens corretas.    	  º±±
±±º          ³                              					          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061PSell(	oWizard		,oEntidade	,nTotal		,nPosSA1	,;
							nRadP1		,oEntVendas)
Local nI	:= 0 //  Contador do for.

oEntidade:SetOption( nPosSA1 )
If nRadP1 == 2
	For nI := 1 To nTotal
		If nI == nPosSA1
			oEntidade:EnableItem( nI, .T. )
	    Else
			oEntidade:EnableItem( nI, .F. )
		Endif
	Next nI
	oEntVendas:EnableItem( 2, .F. )
Else // Habilita todas as entidades caso seja diferente de Lista de Cross Selling
	For nI := 1 To nTotal
		oEntidade:EnableItem( nI, .T. )
	Next nI
	oEntVendas:EnableItem( 2, .T. )
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061P3   ºAutor  ³Rafael M. Quadrotti º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Painel 3 Validacao para listas                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061P3(	oWizard		,nRadP1		,cPergunte	,aEntidades	,;
							nEntidade)
Local lRet := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for diferente de Lista de Cross Selling.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cPergunte:=aEntidades[nEntidade][4]
If Pergunte(aEntidades[nEntidade][4],.T.)
	lRet := .T.
Endif

If lRet
	oWizard:nPanel+=1
Endif

Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061AjusForma  ºAutor³Rafael M. Quadrotti ºData³12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajuste da forma de lista para que a opcao de fax seja      º±±
±±º          ³ iginorada.                                             	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061AjusForma(nForma)
Do Case
	Case nForma == 2 
		M->U4_FORMA := "3" 
	Case nForma == 3
		M->U4_FORMA := "4" 
	Case nForma == 4
		M->U4_FORMA := "2" 
	OtherWise
		M->U4_FORMA := Transform(nForma,"9")
EndCase	
Return nForma	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061P13Vld	  ºAutor³Rafael M. Quadrotti ºData³12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a validacao dos dados informados no painel 13. Ope- º±±
±±º          ³ rador ou grupo devem ser informados obrigatoriamente.  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061P13Vld(nRadOper,cOperad,cGrupo)
Local lRet := .T.
If nRadOper == 2
	If Empty(cOperad)
		Help(" ",1,"TK061NOPER")
		lRet := .F.
	EndIf
ElseIf nRadOper == 4
	If Empty(cGrupo)
		Help(" ",1,"TK061NGRUP")
		lRet := .F.
	EndIf
Endif		

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061VldCrossºAutor³Rafael M. Quadrotti º Data³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do painel para a apresentacao do pergunte com os º±±
±±º          ³ detalhes do cross Selling caso seja uma lista de Cross. 	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061VldCross(	nRadP1 		,sMV_PAR01	,sMV_PAR02	,sMV_PAR03	,;
								sMV_PAR04	,sMV_PAR05	,sMV_PAR06	,sMV_PAR07	,;
								sMV_PAR08 	,oWizard	,nTpLista	,cPergunte)
Local lRet := .F.

If nRadP1 <> 2 
	If nTpLista == 2
		oWizard:nPanel+=1
		lRet := .T.
	Endif
Else		

	cPergunte:="TMK068"
	If Pergunte("TMK068",.T.)
		sMV_PAR01	:= MV_PAR01
		sMV_PAR02	:= MV_PAR02
		sMV_PAR03	:= MV_PAR03
		sMV_PAR04	:= MV_PAR04
		sMV_PAR05	:= MV_PAR05
		sMV_PAR06	:= MV_PAR06
		sMV_PAR07	:= MV_PAR07
		sMV_PAR08	:= MV_PAR08
		lRet := .T.
	Endif
	
	// Pula a selecao da entidade pois sempre sera Cliente para a selecao de Cross Selling.
	If lRet
		oWizard:nPanel+= 2
	Endif	
Endif	

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061P16ShowºAutor³Rafael M. Quadrotti º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Detalhes do painel 16									  º±±
±±º          ³ Habilita e desabilita os objetos da tela de acordo com a   º±±
±±º          ³ o flag de ientificacao.      					          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061P16Show(lOutBound,oDirOut,oArqOut,oIdenOut)
If lOutBound
    oDirOut:Enable()
    oArqOut:Enable()
    oIdenOut:Enable()
    oDirOut:Refresh()
    oArqOut:Refresh()
    oIdenOut:Refresh()
Else
    oDirOut:Disable()
    oArqOut:Disable()
    oIdenOut:Disable()
    oDirOut:Refresh()
    oArqOut:Refresh()
    oIdenOut:Refresh()
Endif

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061P16VLD ºAutor³Rafael M. Quadrotti º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao das informacoes do painel 16                 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061VP16(cArqOut,cDirOut)
Local lRet := .F.

If File(Alltrim(cDirOut)+Alltrim(cArqOut))
	Help(" ",1,"TK061ARQEX",,cDirOut + cArqOut,3,5)//MsgStop("Este arquivo já existe no diretório informado.  "+ cDir + cFile)
	lRet:= .F.
Else
	lRet := .T.
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061Res  ºAutor  ³Rafael M. Quadrotti º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Detalhes do painel 16									  º±±
±±º          ³ Preenche  os dados do resumo de tela e informacoes dos 	  º±±
±±º          ³ campos de memoria restantes.						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061Res(	oResumo		,aResumo	,nRadP1		,nTpLista	,;
							nEntVendas	,nDetCont	,nForma		,nTpFax		,;
							cArqFax		,cSubj		,cMens		,cAttach	,;
							cArqMala	,cArqEtiq	,nTipo		,cOperad	,;
							cSayP13A	,cFiltro	,aEntidades	,nEntidade	,;
							cEntidade	,nRadFone	,nTpEnd		,cTotLista	,;
							cHrINI		,cHrFim		,sMV_PAR01	,sMV_PAR02	,;
							sMV_PAR03	,sMV_PAR04	,sMV_PAR05	,sMV_PAR06	,;
							sMV_PAR07	,sMV_PAR08	,lOutBound	,cArqOut	,;
							cDirOut		,cIdenOut	,nRadOper	,cGrupo) 

aResumo := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Detalhes do Resumo. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRadP1 = 1
	Aadd(aResumo,{STR0088,STR0005})  //"Lista selecionada: " "Lista de Contato   (Padrão)"
	M->U4_CONTATO := SPACE(5)
	M->U4_PROSPEC := "2"
Elseif nRadP1 = 2
	Aadd(aResumo,{STR0088,STR0006})
	M->U4_CONTATO := SPACE(5)
	M->U4_PROSPEC := "2"
Elseif nRadP1 = 3
	Aadd(aResumo,{STR0088,STR0007})
	M->U4_PROSPEC := "2"
	Aadd(aResumo,{STR0009,SUBSTR(M->U4_CONTATO,1,5) +" "+IIF(!Empty(M->U4_OCODISC),STR0110+M->U4_OCODISC,"")})
Elseif nRadP1 = 4
	Aadd(aResumo,{STR0088,STR0008})	
	M->U4_PROSPEC := "1"
	M->U4_CONTATO := SPACE(5)
Endif

Aadd(aResumo,{STR0089,M->U4_DESC})
Aadd(aResumo,{STR0090,DTOC(M->U4_DATA)})
Aadd(aResumo,{STR0091,M->U4_CODCAMP+"-"+ IIF(!Empty(M->U4_CODCAMP),POSICIONE("SUO",1,XFILIAL("SUO")+M->U4_CODCAMP,"UO_DESC" ),"")})
Aadd(aResumo,{STR0092,M->U4_SCRIPT +"-"+ IIF(!Empty(M->U4_SCRIPT) ,POSICIONE("SUZ",1,XFILIAL("SUZ")+M->U4_SCRIPT ,"UZ_DESC" ),"")})
Aadd(aResumo,{STR0093,M->U4_EVENTO +"-"+ IIF(!Empty(M->U4_EVENTO) ,POSICIONE("ACD",1,XFILIAL("ACD")+M->U4_EVENTO ,"ACD_DESC"),"")})


If nTpLista = 1
	Aadd(aResumo,{STR0094,STR0016})
	M->U4_TIPO := "1" // Marketing
ElseIf nTpLista = 2
	Aadd(aResumo,{STR0094,STR0017})
	M->U4_TIPO := "3" // Vendas 
ElseIf nTpLista = 3
	Aadd(aResumo,{STR0094,STR0159}) 
	M->U4_TIPO := "4" // TeleAtendimento 
Endif

If nTpLista = 1
	Aadd(aResumo,{STR0095,aEntidades[nEntidade][2]})
	cEntidade := aEntidades[nEntidade][1]
ElseIf nTpLista = 2
	If nEntVendas == 1 
		Aadd(aResumo,{STR0095,STR0023})
		cEntidade := "SA1"
	ElseIf nEntVendas == 2
		Aadd(aResumo,{STR0095,STR0024})
		cEntidade := "SUS"
	Endif
ElseIf nTpLista = 3
	Aadd(aResumo,{STR0095,aEntidades[nEntidade][2]})
	cEntidade := aEntidades[nEntidade][1]
Endif

If nRadP1 == 2 // Cross Selling        
	Aadd(aResumo,{STR0096,""}) //"Dados Cross Selling"
	Aadd(aResumo,{STR0097,sMV_PAR01 +"-"+ sMV_PAR03})//"  Do Cliente  : "
	Aadd(aResumo,{STR0098,sMV_PAR02 +"-"+ sMV_PAR04})//"  Ate Cliente : "
	Aadd(aResumo,{STR0099,DtoC(sMV_PAR05)})//"  Da data     : "
	Aadd(aResumo,{STR0100,DtoC(sMV_PAR06)})//"  Ate a data     : "
	Aadd(aResumo,{STR0101,sMV_PAR07}) //"  Do Produto  : "
	Aadd(aResumo,{STR0102,sMV_PAR08}) //"  Ate Produto  : "
Endif

If nDetCont == 1
	Aadd(aResumo,{STR0026,STR0028}) //"Seleção do contato." //"Detalhada"
ElseIf nDetCont == 2
	Aadd(aResumo,{STR0026,STR0029}) //"Padrão (Considera parâmetros em branco.)"
	M->U4_HORA1 := cHrINI
	M->U4_HORA2 := cHrFim
Endif

If nForma == 1
	Aadd(aResumo,{STR0031,STR0033})
	M->U4_FORMA := "1"
ElseIf nForma == 2
	Aadd(aResumo,{STR0031,STR0034})
	M->U4_FORMA := "3"
ElseIf nForma == 3
	Aadd(aResumo,{STR0031,STR0035})
	M->U4_FORMA := "4"
ElseIf nForma == 4 // O Contato por fax foi adicionado posteriormente ao wizard.
	Aadd(aResumo,{STR0031,STR0043}) //"Fax"
	M->U4_FORMA := "2"
Endif

If nForma == 1 // Voz
	M->U4_TIPOTEL := ALLTRIM(STR(nRadFone))
	Do Case
		Case nRadFone == RESIDENCIAL 
			Aadd(aResumo,{STR0039+" :",STR0041})
		Case nRadFone == CELULAR 
			Aadd(aResumo,{STR0039+" :",STR0042})
		Case nRadFone == FAX 
			Aadd(aResumo,{STR0039+" :",STR0043})
		Case nRadFone == COMERCIAL1 
			Aadd(aResumo,{STR0039+" :",STR0044})
		Case nRadFone == COMERCIAL2
			Aadd(aResumo,{STR0039+" :",STR0045})
	EndCase
Endif

If nForma == 2
	Aadd(aResumo,{STR0103,""})//"Lista Cross Posting"	
	Aadd(aResumo,{STR0048+" :",cSubj})
	Aadd(aResumo,{STR0049+" :",PadR(cMens,200)})
	Aadd(aResumo,{STR0050+" :",PadR(cAttach,200)})
Endif

If nForma == 3
	Do Case
		Case nTpEnd == 1 
				Aadd(aResumo,{STR0051,STR0041})
			M->U4_TIPOEND := "1"
		Case nTpEnd == 2 
				Aadd(aResumo,{STR0051,STR0053})
			M->U4_TIPOEND := "2"
	EndCase

	Aadd(aResumo,{STR0057,""})
	Aadd(aResumo,{STR0104,cArqMala})	//	"Mala direta :" 
	Aadd(aResumo,{STR0105,cArqEtiq})	//	"Etiqueta :"

Endif

If nForma == 4 // Fax
	M->U4_TIPOTEL := "3" //FAX
	
	If nTpFax == RESIDENCIAL 
		Aadd(aResumo,{STR0039,STR0041})// Cadastro de contatos.
	Else
		Aadd(aResumo,{STR0039,STR0133}) //Entidade. //"Comercial"
	EndIf
	Aadd(aResumo,{STR0043,cArqFax}) 	 //"Fax"
Endif

If nTipo == 1
	M->U4_TELE := "1" // TeleMarketing
	Aadd(aResumo,{STR0106,STR0064})	 //"Rotina :"  "TeleMarketing"
ElseIf nTipo == 2
	M->U4_TELE := "2" // TeleVendas
	Aadd(aResumo,{STR0106,STR0065})	//"Rotina :" "TeleVendas"
ElseIf nTipo == 3
	M->U4_TELE := "5" // TeleAtendimento
	Aadd(aResumo,{STR0106,STR0159})	//"Rotina :" "TeleAtendimento"	
Endif
If nRadOper ==4
	Aadd(aResumo,{STR0107,STR0137 + cGrupo})		//"Seleção por grupo - "
Else	
	Aadd(aResumo,{STR0107,Alltrim(cOperad) + Iif(!Empty(cOperad),("-" + FATPDObfuscate(cSayP13A,"U7_NOME") ),STR0134) })//"Operador : " //"Lista Aberta"  
	M->U4_OPERAD := cOperad
EndIf	

Aadd(aResumo,{STR0108,cFiltro }) //"Filtro: "

// Lista de OutBound
If lOutBound
	Aadd(aResumo,{STR0116,"" })//"Gera Lista de OutBound."
	Aadd(aResumo,{STR0117,cArqOut })//"Nome do Arquivo: "
	Aadd(aResumo,{STR0118,cDirOut })//"Local para o Arquivo: "
	Aadd(aResumo,{STR0125,cIdenOut })//"Identificação do Agente "
Endif

Aadd(aResumo,{STR0109,cTotLista }) //"Total de Itens para esta lista : "
M->U4_NREDUZ := cTotLista

oResumo:nFreeze := 1
oResumo:SetArray(aResumo)
oResumo:bLine:={||{   aResumo[oResumo:nAt,1],;		
				 	   aResumo[oResumo:nAt,2]}}              		


oResumo:GoBottom()
oResumo:GoTop()
oResumo:Refresh()

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061AtuFiltroºAutor ³Cleber Martinez  º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o painel do filtro    							  º±±
±±º          ³ conforme a Entidade selecionada no panel 4            	  º±±
±±º          ³ (Cliente ou Prospect)       						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                     	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³03/07/05³8.11  ³FNC 002408/2005 - Utilizar Filtro da tabela º±±
±±º          ³        ³      ³SD2 quando lista for do tipo CROSS-SELLING. º±±
±±ºAndrea F. ³03/07/05³8.11  ³BOPS 86671 - Atualizar a variavel cEntidade º±±
±±º          ³        ³      ³para que o filtro seja exibido com os       º±±
±±º          ³        ³      ³campos da entidade informada.               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061AtuFiltro(	oWizard		,nEntVendas, cFiltro, nEntidade,;
								aEntidades	,cPergunte)
                
Local oPanelFilt                           
Local cEntidade := ""
Local lRet 		:= .T.
Local nI		:= 1               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizar a variavel cEntidade de acordo com o tipo de lista para utilizacao no filtro.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nEntVendas == 1 //Lista de Marketing
	If cPergunte == "TMK068"
		cEntidade := "SD2"
	Else
		If !Empty(nEntidade) .AND. nEntidade == 1
			cEntidade := "SA1" 	
		Else
			cEntidade:= aEntidades[nEntidade][1]
		Endif	
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de Vendas para a entidade Prospect. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nEntVendas == 2
	cEntidade := "SUS"
Endif

For nI:=1 to Len(aEntidades)
	If cEntidade == aEntidades[nI][1]
		//Retorna a entidade escolhida para montar o filtro 
		//a nEntidade sera usada para fazer o refresh do filtro no panel 14
		nEntidade := nI
	Endif
Next nI

//Atualiza o Painel do Filtro
@ 05,40 MSPANEL oPanelFilt VAR "" OF oWizard:GETPANEL(15) CENTERED SIZE 199,89  
BuildExpr(cEntidade ,,@cFiltro,, {||oWizard:oNext:Click()}, oPanelFilt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061OSConfig ºAutor ³ Vendas e CRM    º Data ³  16/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua as configurações da geração da lista para o Field	  º±±
±±º          ³ Service.                                              	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK061OSConfig( cOSIni, cOSFim, nEntidade, nPosSA1, lOS, aEntidades, cPergunte , nRad, lEntMonOS)

Default nRad		:= 5
Default lEntMonOS	:= .F.

Pergunte( "TMK069", .T. )
cOsIni		:= MV_PAR01
cOSFim		:= MV_PAR01
lOS			:= .T.	
nEntidade	:= nPosSA1
cPergunte	:= aEntidades[nPosSA1][4]

lEntMonOS	:= (nRad == 6)	//Entrega e Montagem

If !lEntMonOS
	Pergunte( "TMK061" , .T. )
EndIf
Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

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