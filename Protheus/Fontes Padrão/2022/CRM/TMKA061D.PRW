#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA061D.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA061D  ºAutor  ³ Vendas Clientes    º Data ³  07/24/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fonte com as funcoes de processo da Lista de Contato.       º±±
±±º          ³Tmka061                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MP8 - Listas de Contato.                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK061Altera³Autor ³ Vendas Clientes       ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela validacao da entrada da alteracao de³±±
±±³          ³lista.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Lista de Contatos                    	              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias: Alias da Rotina                  	              	  ³±±
±±³          ³nReg:   Registro posicionado          	              	  ³±±
±±³          ³nOpc:   Opcao selecionada             	              	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Altera(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A funcao ValAlt verifica se esta lista ja foi executada. ³
//³Em caso positivo a lista nao podera ser alterada.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk061ValAlt(cAlias,nReg,nOpc)
	Tk061Tela(cAlias,nReg,nOpc)
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK061Exclui³Autor ³ Vendas Clientes       ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela validacao da exclusao de listas     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Lista de Contatos                    	              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias: Alias da Rotina                  	              	  ³±±
±±³          ³nReg:   Registro posicionado          	              	  ³±±
±±³          ³nOpc:   Opcao selecionada             	              	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Exclui(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a lista nao foi executada pode ser feita a exclusao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk061ValAlt(cAlias,nReg,nOpc)
	Tk061Tela(cAlias,nReg,nOpc)
Else
	Help(" ",1,"TK061NCHG")	// Esta Lista ja foi executada e nao podera ser excluida.
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkValAlt  ºAutor  ³ Vendas Clientes    º Data ³  07/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a Lista ja foi executada, caso positivo o       º±±
±±º          ³cadastro  nao sera aberto para alteracao.                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias: Alias da Rotina                  	              	  ³±±
±±³          ³nReg:   Registro posicionado          	              	  ³±±
±±³          ³nOpc:   Opcao selecionada             	              	  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso       ³ Lista de Contatos                    	              	  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061ValAlt(cAlias,nReg,nOpc)

Local lRet   := .T.    			// Flag que define se pode alterar.
Local aArea  := GetArea("SU4")	// Salva a area atual
Local cLista := ""				// Nome da Lista

DbSelectArea(cAlias)  
DbSetOrder(1)
DbGoTo(nReg)

cLista := SU4->U4_LISTA

If VAL(SU4->U4_TIPO) <> COBRANCA

	DbSelectArea("SU6")
	DbSetOrder(1)

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra todas as atividades para o operador na database.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery:=	" SELECT *" +;
				" 	FROM " + RetSqlName("SU6") + " SU6 " 				+;
				" 	WHERE	U6_FILIAL = '" + xFilial("SU6") + "' AND "	+; 
				" 			U6_LISTA = '" + cLista + "' AND " 			+;
				" 			U6_STATUS <> '1' AND " 						+;
				" 			D_E_L_E_T_ <> '*'" 
	cQuery+=	" ORDER BY U6_FILIAL,U6_LISTA,U6_CODIGO"
	
	cQuery := ChangeQuery(cQuery)
	DbSelectArea("SU6")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SU6", .F., .T.)
	
	While (!Eof()) .AND. (SU6->U6_LISTA == cLista)
		If	SU6->U6_STATUS <> "1"  // Diferente de nao executado
			lRet := .F.
		    Exit
		Endif
		DbSkip()
	End

	
	DbSelectArea("SU6")
	DbCloseArea()
	ChkFile("SU6")
	

ElseIf VAL(SU4->U4_TIPO) == COBRANCA
	Help(" ",1,"TK061ISCOB")	// Essa lista nao e de Contato.
	lRet := .F.
Endif	

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061Incluir ºAutor ³ Vendas Clientes     º Data ³ 09/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de controle da inclusao de listas com selecao        º±±
±±º          ³ AUTOMATICA ou MANUAL                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nExp01:nOpc     - Opcao selecionada no Menu.                 º±±
±±º          ³cExp02:cEntidade- Entidade que sera trabalhada Ex: SA1.      º±±
±±º          ³aExp03:aEntidade- Array com as entidades do sistema.         º±±
±±º          ³cExp04:cMensagem- Mensagem do e-mail                         º±±
±±º          ³cExp05:cAssunto - Assunto do e-mail.                         º±±
±±º          ³aExp06:aAttach  - anexos para o e-mail.                      º±±
±±º          ³cExp07:cAttach  - descricao do anexo para e-mail             º±±
±±º          ³cExp08:cFiltro  - Filtro que sera utilizado na selecao.      º±±
±±º          ³cExp09:cPergunte- Grupo de Pergunte.                         º±±
±±º          ³cExp10:cText    - Texto para help de processo.               º±±
±±º          ³nExp11:nAniver  - controle da lista de aniversario.          º±±
±±º          ³nExp12:nPeriod  - Controle da lista de periodicidade.        º±±
±±º          ³nExp13:nDetCont - Verifica se o contato sera detalhado ou naoº±±
±±º          ³cExp14:cDir     - Diretorio para arquivo de OutBound.        º±±
±±º          ³cExp15:cFile - Arquivo que sera gerado para lista de OutBoundº±±
±±º          ³lExp16:lAgente - Flag q Avalia se o agente de OutBound sera  º±±
±±º          ³                identificado								   º±±
±±º          ³lExp17:lOutBound - Identifica se a Lista de OutBound sera    º±±
±±º          ³                	gerada.								       º±±
±±º          ³nExp18:lSaveSX8 - Identificacao para lista de aniversario    º±±
±±º          ³nExp19:lLstDiaria- Identificacao para lista de aniversario   º±±
±±º          ³lExp20:lGrupo    - Ident. para distribuicao de lst por grupo º±±
±±º          ³cExp21:cGrupo    - Grupo para distribuicao da Lista.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                    	              	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Incluir(	nOpc		,cEntidade	,aEntidade	,cMensagem	,;
						cAssunto	,aAttach	,cAttach	,cFiltro	,;
						cPergunte	,cText		,nAniver	,nPeriod	,;
						nDetCont	,cDir		,cFile		,lAgente	,;
						lOutBound	,nSaveSX8	,lLstDiaria ,lGrupo		,;
						cGrupo		,cFiltroU5	,cFiltU5SQL	,lOS		,;
						cOSIni		,cOSFim	,lEntMonOS )

Local aArea		:= GetArea()	// Salva a area atual	
Local lRet 		:= .F.			// Retorno da Funcao que recebe o retorno da funcao de selecao.
Local lEnd 		:= .F.			// Retorno para Processa
Local cSelOper 	:= "" 		  	// Armazena codigo do operador selecionado para gravacao. Variavel utilizada devido a sel. automatica
Local nI			:= 0			// Contador para gravacao da inclusao manual.
Local aLista		:= {}			// Array usado para gravacao da Lista Manual
Local aCampos		:= {}			// Array com os campos retornados do SX3 Alias SU6
Local lGrvCab		:= .F.			// Variavel de controle da gravacao do cabecalho do SU4. Utilizada exclusivamente na inc. manual.
Local nLenAux		:= 0			// Contador auxiliar para FOR
Local nPosEnt   	:= 0
Local nPosCont		:= 0

Default lOutBound		:= .F.
Default lGrupo		:= .F.
Default cFiltroU5		:= ""
Default cFiltU5SQL	:= ""
Default lEntMonOS		:= .F.

If Tk061IncVld(	nOpc		,cEntidade	,aEntidade	,@cMensagem	,@cAssunto,;
				@aAttach	,@cAttach	,@cFiltro	,@cPergunte	,@cText,;
				@cSelOper	)

	If nOpc == INCLUIAUTO

		Processa({|lEnd|Tk061Selecao(	nOpc,		cEntidade,	aEntidade,	@cMensagem	,;
										@cAssunto,	@aAttach,	@cAttach,	@cFiltro	,;
										@cPergunte,	@cText,		@lEnd		,@cSelOper	,;
										@lRet,		nAniver,	nPeriod		,nDetCont	,;
										nSaveSX8	,lLstDiaria	,lGrupo		,cGrupo		,;
										cFiltroU5	,cFiltU5SQL	,lOS		,cOSIni		,;
										cOSFim		,lEntMonOS) },STR0001,,.T.)    //"Selecionando Registros..."

	ElseIf nOpc == ASSISTENTE
		Processa({|lEnd|Tk061Selecao(	nOpc		, cEntidade	, aEntidade	, @cMensagem	,;
										@cAssunto	, @aAttach	, @cAttach	, @cFiltro		,;
										@cPergunte	, @cText	, @lEnd		, @cSelOper		,;
										@lRet		, nAniver	, nPeriod	, nDetCont		,;
										nSaveSX8	, lLstDiaria, lGrupo	, cGrupo		,;
										cFiltroU5	, cFiltU5SQL, lOS		, cOSIni		,;
										cOSFim		,lEntMonOS) },STR0001,,.T.)    //"Selecionando Registros..."

	ElseIf nOpc == INCLUIR  

		aCampos   := {}	// Array com os campos retornados do SX3 Alias SU6

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona campos do Sx3 neste ponto para performance	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX3")
		DbSetOrder(1)
		If DbSeek("SU6")
			While (!EOF()) .AND. (X3_ARQUIVO == "SU6")
				If X3USO(X3_USADO)
					Aadd(aCampos,ALLTRIM(X3_CAMPO))
				Endif
				SX3->(DbSkip())
			End
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona dados e efetua gravacao a partir do aCols³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLenAux := Len(aCols)

		For nI:= 1 To nLenAux
			If !aCols[nI][Len(aHeader)+1] // Valida item deletado.
				//--------------------------------------------------------------------------------
				//  Quando for Lista de Marketing do SIGACRM verifica se a Grid está sem dados, 
				//         se estiver não permite a gravação dos dados.
				//-------------------------------------------------------------------------------
		 		If nModulo == 73 .And. nLenAux == 1
		 		 	nPosEnt   	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CODENT"  } ) // Codigo Entidade
				 	nPosCont	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CONTATO" } ) // Codigo Contato 
					If Empty( aCols[ nI ][ nPosEnt ] ) // tratando individualmente o campo que possui o codigo das entidade que pode ser (cliente, suspect, prospect)
						If Empty( aCols[ nI ][ nPosCont ] ) // tratando individualmente o campo que possui o codigo da entidade  Contato. 
							// caso passe pelas duas validoções é porque não foi inserido nenhum registro no aCols.
							lRet := .F.   		
							Help( " ", 1, "TK61GDEMP" ) //Não foi adicionado membros à lista, sendo assim, não será possível gravar esta lista. ###Preencha os Membros da Lista através da opção existem no ícone de Outras Ações.
							Exit                   
						EndIf
					EndIf		
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta array aLista para funcao de gravacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Tk061aLista(@aLista,nI,aCampos)

				// Funcao de gravacao padrao.
				lRet := Tk061Grava(	nOpc		,aLista		,@cAssunto	,@cMensagem	,;
										@cAttach	,@aAttach	,@cFiltro	,@cSelOper	,;
										@lGrvCab	,nSaveSX8	,lOS		,cOSIni		,;
										cOSFim		,lEntMonOS		)
				aLista := {}
			Endif
		Next nI

		If lRet 
			While (GetSx8Len() > nSaveSx8)
				ConfirmSx8()
			End
		EndIf	

	Endif						

Endif

If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma mais uma tarefa para o operador.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !Empty(cSelOper)
		Tk061GrvTarefa(cSelOper,1)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a lista for de mala direta e nao estiver em entrada automatica    ³
	//³verifica se deseja realizar a impressao da mala direta imediatamente.³
	//³A impressao faz integracao com o Word, e por isso nao podera ser exe-³
	//³cutada via entrada automatica.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (M->U4_FORMA == "4")  .AND. !lA061Auto	//Mala direta 
		If TmkOk(STR0002) //"Deseja imprimir a mala direta ?"
			Tk061Mala(	M->U4_LISTA,	M->U4_MALADIR,	M->U4_LABEL,	M->U4_ETIQUET	)	  // imprimir a mala
		Else
			Help(" ",1,"TK061NOIMP") //"A selecao ficara armazenada como pendente e podera ser impressa posteriormente !"
		Endif
	Endif

	If nOpc == ASSISTENTE .AND. lOutBound
		Tk061ARQOUT(M->U4_LISTA,cDir,cFile,lAgente)
    Endif

Endif

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061IncVld  ºAutor ³ Vendas Clientes     º Data ³ 09/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de verificacao para inicio da selecao                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                    	              	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  Tk061IncVld(	nOpc		,cEntidade	,aEntidade	,cMensagem	,cAssunto	,;
						aAttach		,cAttach	,cFiltro	,cPergunte	,cText		,;
						cSelOper	)     

Local aArea		:= GetArea()				// Salva a area atual
Local lRet 		:= .F.						// Retorno da funcao.
Local nI		:= 0						// Contador do for
Local cAux		:= ""						// Variavel de auxilio para validacao de listas manuais
Local nPContat	:= 0                        // Contador de posicao
Local nSelOper	:= 0						// Variavel de auxilio para selecao do operador.
Local nLenAux 	:= 0						// Contador auxiliar para o FOR
Local aAreaAGB  := AGB->(GetArea())
Local aAreaAIK  := AIK->(GetArea())
Local nX		:= 0

If nModulo <> 73 //SIGACRM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida os campos obrigatorios.                                   									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc <> ASSISTENTE // Validado no 061B
		If !Obrigatorio(aGets,aTela)
			cText := "OBRIGAT_FALSE"
			Return(lRet)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se as informacoes necessarias estao preenchidas												   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->U4_TIPO)
		Help(" ",1,"TK061SEL")  //"Informe o tipo de selecao !"
		Return(lRet)
	Endif
	
	If nModulo <> 73 .And. Empty(M->U4_FORMA) //SIGACRM
		Help(" ",1,"TK061NCONT")//"Informe o contato !"
		Return(lRet)
	Endif
	
	If Empty(cEntidade)
		Help(" ",1,"TK061NOSEL")//"Informe a selecao dos clientes ou prospects !"
		Return(lRet)
	Endif
	
	If !lA061Auto
		If Empty(cPergunte)
			Help(" ",1,"TK061PERFI")  //Informe o perfil da entidade .
			Return(lRet)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida a forma de contato.								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case (M->U4_FORMA == "1")   //Voz
			If Empty(M->U4_TIPOTEL)
				Help(" ",1,"TK061TEL")	//"Informe o tipo do telefone !"
				Return(lRet)
			Endif
			
		Case (M->U4_FORMA == "2")   //Fax
			If Empty(M->U4_MALADIR)
				Help(" ",1,"TK061SFAX") //"Informe o arquivo de fax !"
				Return(lRet)
			Endif
			
		Case (M->U4_FORMA == "3")  //Cross-Posting
			If Empty(cAssunto)
				Help(" ",1,"SEMASSUNTO")
				Return(lRet)
			ElseIf Empty(cMensagem)
				Help(" ",1,"SEMMENSAGE")
				Return(lRet)
			Endif
			
		Case (M->U4_FORMA == "4")  //Mala-Direta
			If Empty(M->U4_MALADIR) .OR. (Upper(SubStr(M->U4_MALADIR,RAT(".",M->U4_MALADIR) + 1,Len(M->U4_MALADIR))) <> "DOT")
				Help(" ",1,"TK061SMALA")//"Informe o arquivo da mala direta !"
				Return(lRet)
			Endif
			
			If M->U4_LABEL == "1" //Sim
				If Empty(M->U4_ETIQUET) .OR. (Upper(SubStr(M->U4_ETIQUET,RAT(".",M->U4_ETIQUET) + 1,Len(M->U4_ETIQUET))) <> "DOT")
					Help(" ",1,"TK061SETIQ") //"Informe o arquivo de etiqueta para mala direta !"
					Return(lRet)
				Endif
			Endif
	EndCase
	
	If !lA061Auto
		If (M->U4_TIPO == "1") //Marketing
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o uso de CAMPANHAS e obrigatorio³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TkPosto(TkOperador(),"U0_VLDSCR") == "1"
				If Empty(M->U4_SCRIPT)
					Help(" ",1,"TK061VLITK")
					Return (lRet)
				Endif
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida os itens da inclusão manual³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!lA061Auto) .AND. (nOpc == INCLUIR) .And. nModulo <> 73 //SIGACRM
		nPContat := Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_CONTATO"})
		
		nLenAux := Len(aCols)
		For nI:= 1 To nLenAux
			cAux+= aCols[nI][nPContat]
		Next nI
		
		If Empty(cAux)
			Help(" ",1,"TK061SEMIT" )
			Return(lRet)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1- Verifica se e rotina automatica.                                                           ³
	//³																							     ³
	//³	Caso NAO seja rotina automatica verifica o parametro                                         ³
	//³	e SE for selecao manual avalia o operador, Se For selecao automatica                         ³
	//³	seleciona  o operador de acordo com o menor numero de tarefas.                               ³
	//³                                                                                              ³
	//³	Caso SEJA rotina automatica avalia se o operador esta vazio pois este e preenchido           ³
	//³	em memoria. Caso vazio gera o operador de acordo com o menor numero de tarefas senao mantem  ³
	//³	o operador informado.                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lA061Auto
		If Empty(M->U4_OPERAD) .AND. nOpc <> ASSISTENTE
			nSelOper := Tk061OperDef()
			If nSelOper == 1 // Retornar a digitacao
				Return(lRet)
				
			ElseIf nSelOper == 2 // Selecao automatica
				cSelOper := Tk061SelOper()
				
			ElseIf nSelOper == 3 // Lista generica
				cSelOper := ""
			Endif
			
		ElseIf !Empty(M->U4_OPERAD)
			cSelOper := (M->U4_OPERAD)
		Endif
	Else
		cSelOper := (M->U4_OPERAD) // Rotina automatica me envia o operador correto.
	Endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se passou por todas as validacoes o retorno deve ser .T.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := .T.
	
	// Validação feita no caso de o campo Ger.Cont.Blq estar igual a 2 no caso não gera bloqueado,
	// porem seu preenchimento for feito após selecionados os contatos na grid.
	
	If !lA061Auto .And. M->U4_BLQCONT == "2" .And. nOpc <> ASSISTENTE 
		nPContat := Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_CONTATO"})
		For nX := 1 To Len(aCols)
			If aCols[nX,Len(aCols[nX])] == .F.
				If Tk061HasBlock(aCols[nX,nPContat])
					MsgAlert(STR0065,STR0066)	//"Algum dos contatos selecionados estão bloqueados, por favor verifique.","Atenção"
					lRet := .F.
				EndIf
			EndIf
		Next nX
		
		RestArea(aAreaAGB)
		RestArea(aAreaAIK)
		
	EndIf 
Else 

lRet := .T.
          
EndIf

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061Selecao ºAutor ³ Vendas Clientes     º Data ³ 09/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de selecao das informacoes na base de dados.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                    	              	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Selecao(	nOpc		,cEntidade	,aEntidade	,cMensagem	,;
						cAssunto	,aAttach	,cAttach	,cFiltro	,;
						cPergunte	,cText		,lEnd		,cSelOper	,;
						lRet		,nAniver	,nPeriod	,nDetCont	,;
						nSaveSX8	,lLstDiaria ,lGrupo		,cGrupo		,;
						cFiltroU5	,cFiltU5SQL	,lOS		,cOSIni		,;
						cOSFim		,lEntMonOS		) 
						
						
Local aLista	:= {}									// Array com os registros para gravacao SU6

// Array com os campos para criacao do arquivo de trabalho.
Local aTrab   := {{"U6FILIAL"	, "C", FwSizeFilial(), 0},;  	// Filial
					{"U4LISTA"  	, "C", 06, 0},;	// Lista
					{"U6CODIGO"  	, "C", 06, 0},;   // Codigo
					{"AC8FILENT"  , "C", FwSizeFilial(), 0},;	// Filial da entidade 
					{"AC8ENTIDA"  , "C", 03, 0},;	// Entidade
					{"AC8CODENT"  , "C", 25, 0},;	// Codigo da entidade
					{"U6ORIGEM"  	, "C", 01, 0},;	// Origem da interacao // sempre 1
					{"U6CONTATO"  , "C", 06, 0},;	// Codigo do contato
					{"U6DATA"  	, "D", 08, 0},;	// Data
					{"U6HRINI"  	, "C", 05, 0},;	// Hora inicial
					{"U6HRFIM"  	, "C", 05, 0},;	// Hora final
					{"U6STATUS"  	, "C", 01, 0},;	// Status da interacao // sempre 1 
					{"U5NIVER"  	, "D", 08, 0},;	// Data de aniversario
					{"U4OPERADOR"	, "C", 06, 0},;	// Operador da lista de contatos
					{"U6NUMOS" 	, "C", 06, 0} }	// Numero da OS

Local aArea	:= GetArea()								// Salva a area atual
Local cArqTrab  := "TRB"								// Gera arquivo de trabalho para selecao dos dados.
Local cIndTemp1	:= "U4LISTA"							// Indice temporario do arquivo de trabalho

Local lGrava	:= .F.						   			// Flag para continuar a gravacao
Local cTel		:= ""  									// Telefone do Contato (Comercial, Residencial, Celular, etc....)
Local cTextAux  := ""   								// Auxilia na geracao das mensagens de help

Local nRecAtu	:= 0									// Controles para Regua de status da selecao.
Local nRecTot	:= 0  				   					// Controles para Regua de status da selecao.
Local nTotLista := 1									// Contador para identificar a quantidade total de registros por lista.

Local cMv_Par01   										//Pergunte do CONTATO
Local cMv_Par02
Local cMv_Par03
Local cMv_Par04
Local cMv_Par05

Local ceMv_Par01					  					//Pergunte da ENTIDADE
Local ceMv_Par02
Local ceMv_Par03
Local ceMv_Par04
Local ceMv_Par05
Local ceMv_Par06
Local ceMv_Par07
Local ceMv_Par08
Local ceMv_Par09
Local ceMv_Par10
Local ceMv_Par11
Local ceMv_Par12
Local ceMv_Par13
Local ceMv_Par14
Local ceMv_Par15

Local lGrvCab  :=.F. 									//Flag que identifica se o cabecalho da lista ja foi gravado. Este tratamento eh feito devido a gravacao item a item.
Local cU6HrIni := CriaVar("U6_HRINI",.T.)
Local cU6HrFim := CriaVar("U6_HRFIM",.T.)

Local aAreaSx3	:= GetArea("SX3")						// Utilizado para a busca de inf. no SX3 para a identificacao do arquivo de Log.
Local nErase	:= 1 			 						// Controla a delecao do arquivo de Log 
Local lLog		:= .F.			 						// Flag para utilização de log de base. Inibe o select em SQL.
Local lDados	:= .F.									// Flag que identifica a existencia de dados para selecao.

Local nHandle	:= 0									// Arquivo de Log do SU4
Local nC		:= 0 									// Contador

Local nCampo	:= 0									// Controle do For para laco nos campos do SU4

Local aOper		:= {}					  				// Array com os operadores para geracao da lista.
Local nCont		:= 0					 				// Contador para trabalho com os operadores de um grupo.

Local cNewlst	:= 	""									// Novo codigo de lista - M->U4_LISTA
Local dDtNiver	:= CTOD("//")							// Data de aniversario para gravacao da lista de contatos.
Local nLenAux	:= 0									// Contador auxiliar para o FOR

Local cDia		:= ""									// Controle do dia no aniversário
Local cMes		:= ""									// Controle do mes de aniversario
Local cAno		:= ""									// Controle do ano atual
Local cDtBirth	:= ""									// Variavel de apoio para montagem da data de aniversario no ano atual
Local dDtBirth	:= CTOD("//")							// Controle de data de aniversario, no ano atual

#IFDEF TOP
	Local cQuery          								// Variavel para Query TOP.
	Local aStruct1	:= AC8->(DbStruct())				// Array com a estrutura da tabela AC8 para execucao do TcSetField - Somente para SQL 
	Local aStruct2	:= {}								// Array com a estrutura da tabela SD2 para execucao do TcSetField - Somente para SQL 
	Local nI		:= 0								// Controle de Array
	Local lQuery    := .F.								// Flag para validacoes em TOP e AdvPl
	Local cQryTot										// Query para idêntificar o total de registros selecionados.
#ENDIF

Local lTk061Qry := ExistBlock("TK061QRY")           // Ponto de entrada para incluir filtros nas queries
Local cFilPE	:= ""	
Local lTk061SU5		:= ExistBlock("TK061SU5")			//Ponto de entrada utilizado para filtrar os registros da tabela SU5
Local cFilSU5		:= ""

Local cNumOS		:= ""									// Numero da O.S. do Field Service
Local lNoConvert	:= !(Trim(TcGetDb()) $ 'MSSQL')	
Local oTempTable	:= Nil
Local cArqLog		:= "TMKSU4LISTA_" + AllTrim(cEmpAnt) + AllTrim(cFilAnt) + ".LOG"

Local cFilAC8		:= xFilial("AC8")
Local nTamOper		:= GetSx3Cache("U5_OPERADO","X3_TAMANHO")

Default nDetCont	:= 1
Default cText		:= ""
Default lOS		:= .F.
Default cOSIni	:= Replicate( " ", TamSX3("AB7_NUMOS")[1] )
Default cOSFim	:= Replicate( " ", TamSX3("AB7_NUMOS")[1] )
Default lEntMonOS	:= .F.

//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------
oTempTable	:= FWTemporaryTable():New( cArqTrab )
//-------------------------------------------------------------------
// Atribui o  os índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aTrab )

oTempTable:AddIndex("1",{cIndTemp1})
//------------------
//Criação da tabela
//------------------
oTempTable:Create()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os horarios para inclusao ou lendo da base de dados (alteracao)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->U4_HORA1)
	cU6HrIni := M->U4_HORA1
Endif
	  
If !Empty(M->U4_HORA2)
	cU6HrFim := M->U4_HORA2  
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso exista documento na base gerado pela execucao de lista anterior, apaga o arquivo. Esta validacao pode ³
//³impedir a geracao de duas listas simultaneas porque o nome do arquivo nao ser dinamico         		      ³
//³A nomenclatura do arquivo nao e dinamica devido ao espaco ocupado pelo arquivo gerado. 				      ³
//³Varios arquivo gerados no servidor podem prejudicar o espaco disponivel em disco.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica lista no arquivo de Log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("U4_LISTA")
	cText += X3TITULO()+" : "+ M->U4_LISTA + "  " + CRLF
Endif

If DbSeek("U4_DESC")
	cText += X3TITULO()+" : "+ M->U4_DESC + "  " + CRLF
Endif

If DbSeek("U4_DATA")
	cText += X3TITULO()+" : "+ DTOC(M->U4_DATA )+ "  " + CRLF
Endif

RestArea(aAreaSx3)

cText += CRLF+CRLF + STR0004 + CRLF+CRLF //"Ocorrencias do processo de seleção."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para a utilizacao de log em SQL.      ³
//³Caso seja definida a utilizacao de log a selecao ³
//³sera efetuada em Advpl.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lA061AUTO
	#IFDEF TOP
		lLog:= TmkOk(STR0005 +CRLF+STR0006) //"Habilita log de registros ?" " A utilização do registro de log implicará em um processo de seleção mais lento."
		
		If !lLog
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Esta mensagem eh informada neste momento para que ao final da lista, caso esta nao seja gerada, o usuario  ³
			//³sera informado de sua falha e que nao foi selecionado o detalhamento do Log.                               ³
			//³                                                                                                           ³
			//³Para Top, a utilizacao do Log degrada a performance da rotina devido as validacoes porém no log gerado     ³
			//³todas as informacoes de falhas serao armazenadas possibilitando que a geracao de lista com log seja        ³
			//³efetuada somente uma vez.                                                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			//"Dados da base nao condizem com os parametros informados. Nao foi definida a geracao de log pelo usuario. "
			cText += STR0007 +CRLF 
		Endif	

	#ENDIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia o processo carregando os parametros da selecao de CONTATOS              						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lA061Auto
	
	If lTk061Qry .And. lLog
		cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
		If ValType(cFilPE) == "C"
			If !Empty(cFiltro)
				cFiltro	+= " .AND. " + cFilPE
			Else
				cFiltro	+= cFilPE
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso exista filtro executa o Setfilter no alias              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(cFiltro)
		if cPergunte == "TMK068"
			Tk061SetFilt(cFiltro, "SD2")
		Else
			Tk061SetFilt(cFiltro, cEntidade)
		Endif	
	Endif
	
	If ! Empty(cFiltroU5)
		Tk061SetFilt(cFiltroU5, "SU5")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os parametros da pergunte selecionada em memoria     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("TMK060",.F.) // "Perfil"

	/*
	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Mv_Par01      Nivel do Contato  ³
	  ³Mv_Par02      Perfil do Contato ³
	  ³Mv_Par03      Ligacoes Pendentes³
	  ³Mv_Par04      A partir de quando³  
	  ³Mv_Par05      Ignora Dias Semana³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
	If nDetCont == 1 // Detalha contato. 
		cMv_Par01  := Mv_Par01
		cMv_Par02  := Mv_Par02
		cMv_Par03  := Mv_Par03
		cMv_Par04  := Mv_Par04
		cMv_Par05  := Mv_Par05
	Else
		cMv_Par01  := ""
		cMv_Par02  := 1 // Nao avalia
		cMv_Par03  := 1	// Nao considera
		cMv_Par04  := CTOD("//")
		cMv_Par05  := ""
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os parametros da pergunte selecionada em memoria     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case cPergunte == "TMK066" 	//Concorrentes -"SU2"
			Pergunte("TMK066",.F.)
			ceMv_Par01 := Mv_Par01 	// Produto
			
		Case cPergunte == "TMK064" 	//Parceiros -"AC4"
			Pergunte("TMK064",.F.)
			ceMv_Par01 := Mv_Par01 	// Cidade
			ceMv_Par02 := Mv_Par02 	// Estado
			ceMv_Par03 := Mv_Par03 	// CEP
			
		Case cPergunte == "TMK064" 	//Suspects -"ACH"
			Pergunte("TMK064",.F.)
			ceMv_Par01 := Mv_Par01 	// Cidade
			ceMv_Par02 := Mv_Par02 	// Estado
			ceMv_Par03 := Mv_Par03 	// CEP
			
		Case cPergunte == "TMK061" 	// Clientes -"SA1"
			Pergunte("TMK061",.F.)  // Inativos + Segmento
			ceMv_Par01	:= Mv_Par01 // Maior Valor de Compra
			ceMv_Par02 	:= Mv_Par02	// Data Ultima Compra
			ceMv_Par03	:= Mv_Par03	// Data Ultima Visita
			ceMv_Par04	:= Mv_Par04 // Segmento Negocio 1
			ceMv_Par05	:= Mv_Par05 // Segmento Negocio 2
			ceMv_Par06	:= Mv_Par06 // Segmento Negocio 3
			ceMv_Par07	:= Mv_Par07 // Segmento Negocio 4
			ceMv_Par08	:= Mv_Par08 // Segmento Negocio 5
			ceMv_Par09	:= Mv_Par09 // Segmento Negocio 6
			ceMv_Par10	:= Mv_Par10 // Segmento Negocio 7
			ceMv_Par11	:= Mv_Par11 // Segmento Negocio 8
			ceMv_Par12	:= Mv_Par12 // Do Grupo?
			ceMv_Par13	:= Mv_Par13 // Até o Grupo?
			ceMv_Par14	:= Mv_Par14 // Do Produto?
			ceMv_Par15	:= Mv_Par15 // Até o Produto?
			
		Case cPergunte == "TMK065"  // Fornecedores -"SA2"
			Pergunte("TMK065",.F.)
			ceMv_Par01	:= Mv_Par01  // Natureza
			ceMv_Par02	:= Mv_Par02  // Condicao de Pagto
			ceMv_Par03	:= Mv_Par03  // Maior Saldo
			ceMv_Par04	:= Mv_Par04  // Data Ultima Compra
			
		Case cPergunte == "TMK067" 	// Transportadoras -"SA4"
			Pergunte("TMK067",.F.)
			ceMv_Par01  := Mv_Par01 // Transporte
			
		Case cPergunte == "TMK063" 	// Prospects -"SUS"
			Pergunte("TMK063",.F.)  // Prospect
			ceMv_Par01 := Mv_Par01  // Segmento Negocio 1
			ceMv_Par02 := Mv_Par02  // Segmento Negocio 2
			ceMv_Par03 := Mv_Par03  // Segmento Negocio 3
			ceMv_Par04 := Mv_Par04  // Segmento Negocio 4
			ceMv_Par05 := Mv_Par05  // Segmento Negocio 5
			ceMv_Par06 := Mv_Par06  // Segmento Negocio 6
			ceMv_Par07 := Mv_Par07  // Segmento Negocio 7
			ceMv_Par08 := Mv_Par08  // Segmento Negocio 8
			
		Case cPergunte == "TMK068" 	// Clientes SA1 - Cross Selling
			Pergunte("TMK068",.F.)  // Prospect
			ceMV_PAR01	:= MV_PAR01	// Do Cliente
			ceMV_PAR02	:= MV_PAR02	// Ate Cliente
			ceMV_PAR03	:= MV_PAR03	// Da Loja
			ceMV_PAR04	:= MV_PAR04	// Ate a Loja
			ceMV_PAR05	:= MV_PAR05	// Da Data
			ceMV_PAR06	:= MV_PAR06	// Ate a data
			ceMV_PAR07	:= MV_PAR07	// Do produto
			ceMV_PAR08	:= MV_PAR08	// Ate Produto
			ceMV_PAR09	:= MV_PAR09	// Do Grupo
			ceMV_PAR10	:= MV_PAR10	// Ate o Grupo  						

		Case cPergunte == "TMK070" 	// Prestador -"BAU"
			Pergunte("TMK070",.F.)  // Prestador
			ceMv_Par01 := Mv_Par01  // RDA de 
			ceMv_Par02 := Mv_Par02  // RDA ate 
			ceMv_Par03 := Mv_Par03  // Classe RDA de 
			ceMv_Par04 := Mv_Par04  // Classe RDA ate 
			ceMv_Par05 := Mv_Par05  // Data de 
			ceMv_Par06 := Mv_Par06  // Data ate  

	Endcase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Primeiro verifica se existem os contatos relacionados por Entidade no AC8      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AC8")
	DbSetOrder(2)
	DbGotop()
	nRecTot := RecCount()
    
	#IFDEF TOP
		// Caso nao utilize log.
		If !lLog
			If cEntidade == "SA1" .AND. cPergunte == "TMK068" // CROSS SELLING
				aStruct2	:= SD2->(DbStruct())
				cQuery :=	" SELECT AC8.* "+Iif(lOs .AND. lEntMonOS,",AB6.AB6_NUMOS,AB6.AB6_NUMLOJ ","")
				cQuery +=	" FROM " + RetSqlName("SU5") + " SU5, "+RetSqlName("AC8") + " AC8 " 
			Else	
				aStruct2	:= (cEntidade)->(DbStruct())
				cQuery :=	" SELECT AC8.*, "+cEntidade+".* "+Iif(lOs .AND. lEntMonOS,",AB6.AB6_NUMOS,AB6.AB6_NUMLOJ ","")+Iif(nPeriod == 1 .AND. lNoConvert,",SU5.U5_ULTCONT,SU5.U5_PERIOD"," ")
				cQuery +=	" FROM " + RetSqlName("SU5") + " SU5, " + RetSqlName(cEntidade) + " " + cEntidade + ","+ RetSqlName("AC8") + " AC8 " 
			Endif
			
			If lOs .AND. lEntMonOS //Pesquisa de Confirmação de Entrega/Montagem		
				cQuery +=	"		JOIN " + RetSqlName("AB7") + " AB7 ON ("
				cQuery	+=	"			AB7.AB7_CODCON = AC8.AC8_CODCON AND AB7.D_E_L_E_T_ = ' ' AND "
				If !Empty(cOSIni) .And. !Empty(cOSFim)
					cQuery	+=	"		AB7.AB7_NUMOS BETWEEN '" + cOSIni + "' AND '" + cOSFim + "' AND "
				EndIf						
				cQuery	+=	"			AB7.AB7_ITEM='" + PadL("1",TamSX3("AB7_ITEM")[1],"0") + "' AND "
				cQuery	+=	"			AB7.AB7_TMKLST = '"+Space(TamSX3("AB7_TMKLST")[1])+"' )"
								
				cQuery	+=	"		JOIN	" + RetSQLName("AB6") + " AB6 ON ("
				cQuery +=  "			AB6.AB6_FILIAL=AB7.AB7_FILIAL AND AB6.AB6_NUMOS=AB7.AB7_NUMOS AND AB6.D_E_L_E_T_ = ' ' AND"
				cQuery	+=	"			AB6.AB6_NUMLOJ != '"+Space(TamSX3("AB6_NUMLOJ")[1])+"') " //Possui Orçamento do Loja
				cQuery	+=	"		JOIN	" + RetSQLName("SL1") + " SL1 ON (SL1.L1_NUM=AB6.AB6_NUMLOJ AND SL1.D_E_L_E_T_ = ' ' ) "
												
			EndIf
				
			cQuery +=	" WHERE	AC8.AC8_FILIAL = '" + cFilAC8 + "' AND" +;
						"		AC8_ENTIDA = '" + AllTrim(cEntidade) + "' AND" +;
						"		SU5.U5_FILIAL = '" + xFilial("SU5") + "' AND"  +;
						"		SU5.U5_CODCONT = AC8.AC8_CODCON AND" 
			If !Empty(cMv_par01)		
				cQuery += "		SU5.U5_NIVEL = '" + cMv_par01 + "' AND"
			Endif			
			
			If lOs .AND. lEntMonOS // Confirmação de Entrega e Montagem
				cQuery += " SL1.L1_CLIENTE=SA1.A1_COD AND SL1.L1_LOJA=SA1.A1_LOJA AND"
			EndIf
				
			// As listas geradas nao poderao ser de periodicidade e aniversario ao mesmo tempo.
			If nAniver == 1 //LISTA DE ANIVERSARIO
				
				If !Empty(M->U4_CONTATO)
					If !Empty(M->U4_OCODISC)
						cQuery+= "		SU5.U5_NIVER = '" + DtoS(CTOD(SUBSTR(M->U4_CONTATO,1,5)+"/"+M->U4_OCODISC)) + "' AND"
					Else
						cQuery+= "		SubString(SU5.U5_NIVER,5,4) = '" + SUBSTR(DtoS(CtoD(SUBSTR(M->U4_CONTATO,1,5))),5,4) + "' AND"
					Endif
				Else
					cQuery+= "		SU5.U5_NIVER BETWEEN '" + DtoS(CTOD(SUBSTR(M->U4_NSTATUS,1,08))) +"' AND '"+ DtoS(CTOD(SUBSTR(M->U4_NSTATUS,09,08))) +"' AND"
				Endif
			Endif
			
			If nPeriod == 1 .AND. !lNoConvert//LISTA DE PERIODICIDADE
				cQuery+= "		convert(datetime,SU5.U5_ULTCONT,112) + SU5.U5_PERIOD <= convert(datetime,'" + DtoS(M->U4_Data) + "',112) AND"
			Endif

			If M->U4_FORMA == "1"
				cQuery+= "	 ("	
			Endif	
			
			If M->U4_FORMA == "1" .AND. Val(M->U4_TIPOTEL) == 1   // RESIDENCIAL -  Voz e Residencial
				cQuery+= "		SU5.U5_FONE <> '' "
			Endif
				
			If M->U4_FORMA == "1" .AND. Val(M->U4_TIPOTEL) == 2  // CELULAR - Voz e Celular
				cQuery+= "		SU5.U5_CELULAR <> '' "
			Endif
				
			If M->U4_FORMA == "1" .AND. Val(M->U4_TIPOTEL) == 3  //FAX - Voz e Fax
				cQuery+= "		SU5.U5_FAX <> '' "
			Endif
				
			If M->U4_FORMA == "1" .AND. Val(M->U4_TIPOTEL) == 4  // COMERCIAL1 - Voz e Comercial 1
				cQuery+= "		SU5.U5_FCOM1 <> '' "
			Endif
				
			If M->U4_FORMA == "1" .AND. Val(M->U4_TIPOTEL) == 5 // COMERCIAL2 - Voz e Comercial 2
				cQuery+= "		SU5.U5_FCOM2 <> '' "
			Endif
				
			If M->U4_FORMA == "1"
				cQuery+= "	 ) AND"	
			Endif	

			If M->U4_FORMA == "2"   //Fax
				cQuery+= "		SU5.U5_FAX <> '' AND"
			Endif
						
			If M->U4_FORMA == "3"  //Cross-Posting
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o contato nao possuir e-mail passa para o proximo contato.       ³
				//³Ou se o contato não autorizar a interação via e-mail.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery+= "		SU5.U5_EMAIL <> '' AND"
				cQuery+= "		SU5.U5_AUTORIZ = '1' AND"
			Endif
				
			If M->U4_FORMA == "4"  //Mala-Direta
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o contato nao possuir endereco passa para o proximo contato.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery+= "		SU5.U5_END <> '' AND"
			Endif
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se vai ser avaliado o perfil do contato     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMv_par02 == 2 //Avalia
				cQuery+= "		(U5_DIALIG LIKE '%" + Str(Dow(M->U4_Data),1) + "%' OR '" + cMv_par05 + "' LIKE '%" + Str(Dow(M->U4_Data),1) + "%') AND  "
			    cQuery+= "		SU5.U5_OPERADO IN ('','"+M->U4_OPERAD+" ')   AND  "
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente contatos atualizados serão aceitos.						  ³
		    //³Em caso de Suspects permite a selecao de contatos desatualizados   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cEntidade <> "ACH"
				cQuery+= "		SU5.U5_STATUS <> '1' AND" // 2 OU branco Atualizado.
			Endif
			
			If !Empty(cFiltU5SQL)
				cQuery+= " " + cFiltU5SQL + " AND "
			EndIf

			If lTk061SU5
				cFilSU5 := ExecBlock("TK061SU5",.F.,.F.,{cEntidade,cSelOper,lLog})
				If ValType(cFilSU5) == "C"
					cQuery	+= cFilSU5 + " AND "
				EndIf
			EndIf
						
			If cEntidade == "SA1" .AND. cPergunte == "TMK061"  // Clientes para TMK ou TLV 
				cQuery+= "		SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND"
				cQuery+= "		SA1.A1_COD = SUBSTRING(AC8_CODENT,1," + Alltrim(Str(TkEntTam(cEntidade)[1])) + ") AND"
				cQuery+= "		SA1.A1_LOJA = SUBSTRING(AC8_CODENT," + Alltrim(Str(TkEntTam(cEntidade)[1] + 1)) + "," + AllTrim(Str(TkEntTam(cEntidade)[2])) + ") AND"				
				cQuery+= "		SA1.D_E_L_E_T_ = ' ' AND"
				
				If !(lOs .AND. lEntMonOS) // Entrega + Montagem não filtra pergunte TMKA061
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida os parametros informados.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ceMv_Par01 > 0
						cQuery+= "		SA1.A1_MCOMPRA >= " + Str(ceMv_Par01) + " AND"
					Endif
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida a data da ultima compra.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(ceMv_Par02)
						cQuery+= "		(SA1.A1_ULTCOM <= '" + DtoS(ceMv_Par02) + "' OR  SA1.A1_ULTCOM = '        ')  AND"
					Endif
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida a data da ultima visita.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(ceMv_Par03)
						cQuery+= "		SA1.A1_ULTVIS <= '" + DtoS(ceMv_Par03) + "' AND"
					Endif
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida os segmentos de negocios ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(ceMv_par04)
						cQuery+= "		SA1.A1_SATIV1 = '" + ceMv_par04 + "' AND"
					Endif
	
					If !Empty(ceMv_par05)
						cQuery+= "		SA1.A1_SATIV2 = '" + ceMv_par05 + "' AND"
					Endif
	
					If !Empty(ceMv_par06)
						cQuery+= "		SA1.A1_SATIV3 = '" + ceMv_par06 + "' AND"
					Endif
	
					If !Empty(ceMv_par07)
						cQuery+= "		SA1.A1_SATIV4 = '" + ceMv_par07 + "' AND"
					Endif
	
					If !Empty(ceMv_par08)
						cQuery+= "		SA1.A1_SATIV5 = '" + ceMv_par08 + "' AND"
					Endif
	
					If !Empty(ceMv_par09)
						cQuery+= "		SA1.A1_SATIV6 = '" + ceMv_par09 + "' AND"
					Endif
	
					If !Empty(ceMv_par10)
						cQuery+= "		SA1.A1_SATIV7 = '" + ceMv_par10 + "' AND"
					Endif
	
					If !Empty(ceMv_par11)
						cQuery+= "		SA1.A1_SATIV8 = '" + ceMv_par11 + "' AND "
					Endif
	
					If lTk061Qry
						cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
						If ValType(cFilPE) == "C"
							cQuery	+= cFilPE + " AND "
						EndIf
					EndIf											  
	
					If !Empty(ceMv_par12) .OR. !Empty(ceMv_par13) .OR. !Empty(ceMv_par14) .OR. !Empty(ceMv_par15)								
						cQuery+= " 0 < (SELECT COUNT(*) FROM " + RetSqlName("SD2") + " SD2 WHERE " 
						If !Empty(ceMv_par12)
							cQuery+= "		SD2.D2_GRUPO >= '" + ceMv_par12 + "' AND"
						Endif				
		
						If !Empty(ceMv_par13)
							cQuery+= "		SD2.D2_GRUPO <= '" + ceMv_par13 + "' AND"
						Endif								
		
						If !Empty(ceMv_par14)
							cQuery+= "		SD2.D2_COD >= '" + ceMv_par14 + "' AND"
						Endif								
		
						If !Empty(ceMv_par15)
							cQuery+= "		SD2.D2_COD <= '" + ceMv_par15 + "' AND"
						Endif	                      
						
						cQuery+= "		SD2.D2_CLIENTE = SA1.A1_COD AND" 			 
						cQuery+= "		SD2.D_E_L_E_T_ = ' ' AND" 			  
						cQuery+= "		SD2.D2_FILIAL = '" + xFilial("SD2") + "') AND"										
					Endif
				
				EndIf
				
			Endif
			
			If 	cEntidade == "SA1" .AND. cPergunte == "TMK068" 	// Cross Selling  
				cQuery+= " 0 < (SELECT COUNT(*) FROM "+RetSqlName("SD2")+" SD2 WHERE "
				
				cQuery+= "		SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND"
				cQuery+= "		SD2.D2_CLIENTE BETWEEN '" + ceMv_Par01 + "' AND '" + ceMv_Par02 + "' AND "
				cQuery+= "		SD2.D2_LOJA BETWEEN '" + ceMv_Par03 + "' AND '" + ceMv_Par04 + "' AND "
				cQuery+= "		SD2.D2_EMISSAO BETWEEN '" + DTOS(ceMv_Par05) + "' AND '" + DTOS(ceMv_Par06) + "' AND "
				cQuery+= "		SD2.D2_COD 	BETWEEN '" + ceMv_Par08 + "' AND '" + ceMv_Par07 + "' AND "
				cQuery+= "		SD2.D2_GRUPO BETWEEN '" + ceMv_Par09 + "' AND '" + ceMv_Par10 + "' AND "				

				If lTk061Qry
					cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
					If ValType(cFilPE) == "C"
						cQuery	+= cFilPE + " AND "
					EndIf
				EndIf				
				
				cQuery+= "		SD2.D_E_L_E_T_ = ' ' AND"  
				cQuery+= "		SD2.D2_CLIENTE = SUBSTRING(AC8_CODENT,1," + Alltrim(Str(TkEntTam(cEntidade)[1])) + ")"
				
				cQuery+= ") AND"                           
				cQuery+= "		SU5.U5_CODCONT = AC8.AC8_CODCON AND"				
			Endif
			
			If cEntidade == "SU2"	// Concorrentes
				cQuery+= "		SU2.U2_FILIAL = '" + xFilial("SU2") + "' AND"
				cQuery+= "		SU2.U2_COD = SUBSTRING(AC8_CODENT,1," + Alltrim(Str(TkEntTam(cEntidade)[1])) + ") AND"
				If !Empty(ceMv_Par01)
					cQuery+= "		SU2.U2_COD = '" + ceMv_Par01 + "' AND "
				Endif

				If lTk061Qry
					cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
					If ValType(cFilPE) == "C"
						cQuery	+= cFilPE + " AND "
					EndIf
				EndIf
				
				cQuery+= "		SU2.D_E_L_E_T_ = ' ' AND"
			Endif
				
			If cEntidade == "AC4"	// Parceiros
				cQuery+= "		AC4.AC4_FILIAL = '" + xFilial("AC4") + "' AND"
				cQuery+= "		AC4.AC4_PARTNE = AC8_CODENT AND"
				If !Empty(ceMv_par01)
					cQuery+= "		AC4.AC4_MUN = '" + ceMv_par01 + "' AND"
				Endif
				If !Empty(ceMv_par02)
					cQuery+= "		AC4.AC4_EST = '" + ceMv_par02 + "' AND"
				Endif
				If !Empty(ceMv_par03)
					cQuery+= "		AC4.AC4_CEP = '" + ceMv_par03 + "' AND "
				Endif

				If lTk061Qry
					cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
					If ValType(cFilPE) == "C"
						cQuery	+= cFilPE + " AND " 
					EndIf
				EndIf
				
				cQuery+= "		AC4.D_E_L_E_T_ = ' ' AND"
			Endif
				
			If cEntidade == "ACH"	// Suspects
				cQuery+= "		ACH.ACH_FILIAL = '" + xFilial("ACH") + "' AND"
				cQuery+= "		ACH.ACH_CODIGO = SUBSTRING(AC8_CODENT,1," + Alltrim(Str(TkEntTam(cEntidade)[1])) + ") AND"
				cQuery+= "		ACH.ACH_LOJA = SUBSTRING(AC8_CODENT," + Alltrim(Str(TkEntTam(cEntidade)[1] + 1)) + "," + Alltrim(Str(TkEntTam(cEntidade)[2])) + ") AND"
				If !Empty(ceMv_par01)
					cQuery+= "		ACH.ACH_CIDADE = '" + ceMv_par01 + "' AND"
				Endif
				If !Empty(ceMv_par02)
					cQuery+= "		ACH.ACH_EST = '" + ceMv_par02 + "' AND"
				Endif
				If !Empty(ceMv_par02)
					cQuery+= "		ACH.ACH_CEP = '" + ceMv_par03 + "' AND "
				Endif

				If lTk061Qry
					cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
					If ValType(cFilPE) == "C"
						cQuery	+= cFilPE + " AND "
					EndIf
				EndIf

				cQuery+= "		ACH.D_E_L_E_T_ = ' ' AND"
			Endif
	            
			If cEntidade == "SA2"	// Fornecedores
				cQuery+= "		SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND"
				cQuery+= "		SA2.A2_COD = SUBSTRING(AC8_CODENT,1," + Alltrim(Str(TkEntTam(cEntidade)[1])) + ") AND"
				cQuery+= "		SA2.A2_LOJA = SUBSTRING(AC8_CODENT," + Alltrim(Str(TkEntTam(cEntidade)[1] + 1)) + "," + Alltrim(Str(TkEntTam(cEntidade)[2])) + ") AND"
				If !Empty(ceMv_par01)
					cQuery+= "		SA2.A2_NATUREZ = '" + ceMv_par01 + "' AND"
				Endif
				If !Empty(ceMv_par02)
					cQuery+= "		SA2.A2_COND = '" + ceMv_par02 + "' AND"
				Endif
				If !Empty(ceMv_par03)
					cQuery+= "		SA2.A2_MSALDO >= " + Str(ceMv_par03) + " AND"
				Endif
				If !Empty(ceMv_par04)
					cQuery+= "		SA2.A2_ULTCOM >= '" + DtoS(ceMv_par04) + "' AND "
				Endif

				If lTk061Qry
					cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
					If ValType(cFilPE) == "C"
						cQuery	+= cFilPE + " AND "
					EndIf
				EndIf
				
				cQuery+= "		SA2.D_E_L_E_T_ = ' ' AND"
			Endif
	            
			If cEntidade == "SA4"	// Transportadoras
				cQuery+= "		SA4.A4_FILIAL = '" + xFilial("SA4") + "' AND"
				cQuery+= "		SA4.A4_COD = AC8_CODENT AND"
				If !Empty(ceMv_Par01)
					cQuery+= "		SA4.A4_VIA = '" + ceMv_Par01 + "' AND "
				Endif

				If lTk061Qry
					cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
					If ValType(cFilPE) == "C"
						cQuery	+= cFilPE + " AND "
					EndIf
				EndIf
				
				cQuery+= "		SA4.D_E_L_E_T_ = ' ' AND"
			Endif
	            
			If cEntidade == "SUS"	// Prospects
				cQuery+= "		SUS.US_FILIAL = '" + xFilial("SUS") + "' AND"
				cQuery+= "		SUS.US_COD = SUBSTRING(AC8_CODENT,1," + Alltrim(Str(TkEntTam(cEntidade)[1])) + ") AND"
				cQuery+= "		SUS.US_LOJA = SUBSTRING(AC8_CODENT," + Alltrim(Str(TkEntTam(cEntidade)[1] + 1)) + "," + Alltrim(Str(TkEntTam(cEntidade)[2])) + ") AND"
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida os segmentos de negócios ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(ceMv_par01)
					cQuery+= "		SUS.US_SATIV = '" + ceMv_par01 + "' AND"
				Endif

				If !Empty(ceMv_par02)
					cQuery+= "		SUS.US_SATIV2 = '" + ceMv_par02 + "' AND"
				Endif

				If !Empty(ceMv_par03)
					cQuery+= "		SUS.US_SATIV3 = '" + ceMv_par03 + "' AND"
				Endif

				If !Empty(ceMv_par04)
					cQuery+= "		SUS.US_SATIV4 = '" + ceMv_par04 + "' AND"
				Endif

				If !Empty(ceMv_par05)
					cQuery+= "		SUS.US_SATIV5 = '" + ceMv_par05 + "' AND"
				Endif

				If !Empty(ceMv_par06)
					cQuery+= "		SUS.US_SATIV6 = '" + ceMv_par06 + "' AND"
				Endif

				If !Empty(ceMv_par07)
					cQuery+= "		SUS.US_SATIV7 = '" + ceMv_par07 + "' AND"
				Endif

				If !Empty(ceMv_par08)
					cQuery+= "		SUS.US_SATIV8 = '" + ceMv_par08 + "' AND "
				Endif

				If lTk061Qry
					cFilPE := ExecBlock("TK061QRY",.F.,.F.,{cEntidade,cPergunte,lLog})
					If ValType(cFilPE) == "C"
						cQuery	+= cFilPE + " AND "
					EndIf
				EndIf

				cQuery+= "		SUS.D_E_L_E_T_ = ' ' AND"
			Endif
	       
			If cEntidade == "BAU"	// Prestadores
				cQuery+= "		BAU.BAU_FILIAL = '" + xFilial("BAU") + "' AND"
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida os parametros ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If !Empty(ceMv_par01)
					cQuery+= "		BAU.BAU_CODIGO = '" + ceMv_par01 + "' AND"
				Endif

				If !Empty(ceMv_par02)
					cQuery+= "		BAU.BAU_CODIGO = '" + ceMv_par02 + "' AND"
				Endif

				If !Empty(ceMv_par03)
					cQuery+= "		BAU.BAU_TIPPRE = '" + ceMv_par03 + "' AND"
				Endif

				If !Empty(ceMv_par04)
					cQuery+= "		BAU.BAU_TIPPRE = '" + ceMv_par04 + "' AND"
				Endif

				If !Empty(ceMv_par05)
					cQuery+= "		BAU.BAU_DTINCL = '" + DtoS(ceMv_par05) + "' AND"
				Endif

				If !Empty(ceMv_par06)
					cQuery+= "		BAU.BAU_DTINCL = '" + DtoS(ceMv_par06) + "' AND"
				Endif

				cQuery+= "		BAU.D_E_L_E_T_ = ' ' AND"
			Endif
			If !lOS
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida as ligacoes pendentes de TeleMarketing.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery+= " 0 =	(SELECT COUNT(*) "
				cQuery+= "		FROM " + RetSqlName("SUC") + " SUC "
				cQuery+= "		WHERE	SUC.UC_FILIAL = '" + xFilial("SUC") + "' AND"
				cQuery+= "				SUC.UC_CODCONT = AC8_CODCON AND"
				cQuery+= "				SUC.UC_STATUS = '2' AND"
			 	cQuery+= "				SUC.D_E_L_E_T_ = ' ') AND "
			EndIf				
      
			If !Empty(M->U4_CODCAMP) .AND. !Empty(M->U4_SCRIPT)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o contato já respondeu o Script informado.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery+= " 0 =	(SELECT COUNT(*) "
				cQuery+= "		FROM " + RetSqlName("ACI") + " ACI "
				cQuery+= "		WHERE	ACI.ACI_FILIAL = '" + xFilial("ACI") + "' AND "
				cQuery+= "				ACI.ACI_CODCAM = '" + M->U4_CODCAMP  + "' AND "
				cQuery+= "				ACI.ACI_CODSCR = '" + M->U4_SCRIPT   + "' AND "
				cQuery+= "				ACI.ACI_CODCON  = AC8_CODCON AND "
			 	cQuery+= "				ACI.D_E_L_E_T_ = ' ') AND "
 			Endif
	
			cQuery+= " 0 =	(SELECT COUNT(*) "
			cQuery+= "		FROM " + RetSqlName("SU6") + " SU6 "
			cQuery+= "		WHERE	SU6.U6_FILIAL   = '" + xFilial("SU6")  + "' AND "
			cQuery+= "				SU6.U6_DATA     = '" + DtoS(M->U4_DATA) + "' AND "
			cQuery+= "				SU6.U6_CONTATO  = AC8_CODCON AND "
			cQuery+= "				SU6.D_E_L_E_T_ = ' ') AND "
			
			If lOs .AND. !lEntMonOS //Satisfação de Atendimento - SIGATEC
				cQuery	+=	" 0 <	(SELECT COUNT(*) "
				cQuery	+=	"		FROM	" + RetSQLName("AB7") + " AB7, "
				cQuery	+= 	"				" + RetSQLName("AB9") + " AB9 "
				cQuery	+=	"		WHERE "
				cQuery 	+=	"			SubString(AB9.AB9_NUMOS," + AllTrim(Str(TamSX3("AB7_NUMOS")[1] + 1)) + "," + AllTrim(Str(TamSX3("AB7_ITEM")[1])) + ") = AB7_ITEM AND "
				cQuery	+=	"			SubString(AB9.AB9_NUMOS,1," + AllTrim(Str(TamSX3("AB7_NUMOS")[1])) + ") = AB7.AB7_NUMOS AND "
				cQuery	+=	"			AB9.AB9_TIPO = '1' AND "
				cQuery	+=	"			AB9.AB9_TMKLST = '' AND " 
				If !Empty(cOSIni) .And. !Empty(cOSFim)
					cQuery	+=	"			AB9.AB9_NUMOS BETWEEN '" + cOSIni + "' AND '" + cOSFim + "' AND "
				EndIf
				cQuery	+=	"			AB7.AB7_CODCON = AC8_CODCON) AND "
			EndIf   
				
			cQuery+= "		SU5.D_E_L_E_T_ = ' ' AND"
			cQuery+= "		AC8.D_E_L_E_T_ = ' '"			
				
			// O filtro esta montado e o ORDER BY nao esta na query entao é hora de montar o contator da regua
			// Monto o SELECT que conta e aproveito o filtro da outra query
			cQryTot := "SELECT COUNT(*) U8TOTAL " + SubStr(cQuery,AT("FROM ",cQuery),Len(cQuery))
				
			cQuery+= "		ORDER BY " + SqlOrder(IndexKey())
				
			cQryTot := ChangeQuery(cQryTot)
			//MemoWrite("TMKA061_TOT.SQL", cQryTot)

			DbSelectArea("AC8")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTot), 'AC8', .F., .T.)
			nRecTot := AC8->U8TOTAL
				
			cQuery := ChangeQuery(cQuery)
	   		MemoWrite("TMKA061D_AC8.SQL", cQuery)

			DbSelectArea("AC8")
			DbCloseArea()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'AC8', .F., .T.)
				
			nLenAux := Len(aStruct1)
			For nI:= 1 To nLenAux
				If aStruct1[nI][2] $ ("N,D,L")		// Numerico, data ou logico
					TcSetField("AC8", aStruct1[nI][1], aStruct1[nI][2], aStruct1[nI][3], aStruct1[nI][4])
				Endif	
			Next nI
				
			nLenAux := Len(aStruct2)
			For nI:= 1 To nLenAux
				If aStruct2[nI][2] $ ("N,D,L")		// Numerico, data ou logico
					TcSetField("AC8", aStruct2[nI][1], aStruct2[nI][2], aStruct2[nI][3], aStruct2[nI][4])
				Endif	
			Next nI
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao de ambiente. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lQuery := .T.
		Else
			DbSeek(cFilAC8 + cEntidade + xFilial(cEntidade) )
		Endif
	#ELSE
		DbSeek(cFilAC8 + cEntidade + xFilial(cEntidade) )
	#ENDIF
	
	ProcRegua( nRecTot )
	
	DbSelectArea("AC8")
	While AC8->(! Eof()) 							.AND.;
			cFilAC8 == AC8->AC8_FILIAL		 		.AND.;
			AC8->AC8_ENTIDA == cEntidade 			.AND.;
			AC8->AC8_FILENT == xFilial(cEntidade)
		
		If (nPeriod == 1 .AND. lNoConvert .AND. !lLog) .AND. !Empty(AC8->U5_ULTCONT) .AND. ((STOD(AC8->U5_ULTCONT) + AC8->U5_PERIOD) > M->U4_DATA)
			DbSelectArea("AC8")
			DbSkip()
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao for TOP inicializa o flag de validacao - para CDX - para que as validacoes sejam feitas sempre ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lQuery
			lGrava := .F.
		Endif	
		    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Flag para help da Lista.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lDados := .T. 
			
		nRecAtu++
		IncProc( STR0008 + StrZero(nRecAtu,6) + STR0009 + StrZero(nRecTot,6) )		//"Lendo registro " " até "
		
		If lEnd
			If TmkOk(STR0010)//"Confirma o cancelamento da geracao da Lista de Contato?" 
				#IFDEF TOP
					If !lLog
						If TcSrvType() <> "AS/400"
							DbSelectArea("AC8")
							DbCloseArea()
							ChkFile("AC8")
						Endif
					Endif
				#ENDIF			    
				
			    cText += "********************************"+STR0011 //"Cancelado pelo operador."
				TK061Write(@cText,nHandle,.T.)
				
				cFiltro   := ""
				cFiltroU5 := ""
				
				If 	cPergunte == "TMK068"
					Tk061SetFilt(cFiltro,"SD2")
				Else
					Tk061SetFilt(cFiltro,cEntidade)
				Endif 
				
				Tk061SetFilt(cFiltroU5,"SU5")
						     
				DbSelectArea("AC8")
			    aLista:= {}
			    lRet := .F.
			    Return(lRet)
			Else
				lEnd := .F.
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico se a entidade de relacionamento atual esta disponivel na sua base de dados original ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cFiltro)
			
			DbSelectArea(cEntidade)                          
			If !DbSeek( xFilial(cEntidade) + Trim(AC8->AC8_CODENT) )
				DbSelectArea("AC8")
				DbSkip()
				Loop
            Endif                       
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Em caso de Query e  se estiver habilitado para avaliar o  ³
		//³perfil do contato o horário do perfil sera gravado no SU6.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQuery .AND. cMv_par02 == 2 // Avalia perfil do contato.
			If !Empty(SU5->U5_HORA1) .AND. !Empty(SU5->U5_HORA2)
				cU6HrIni := SU5->U5_HORA1
				cU6HrFim := SU5->U5_HORA2
			Endif	
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso a selecao seja em CDX efetua todas as validacoes   ³
		//³pertinentes a regra da Lista.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lQuery
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o contato ja esta em alguma lista de contato   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Tk061OutraLista(AC8->AC8_CODCON)
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//"O Contato "" ja pertence a outra Lista para hoje."
				cText += "02"+STR0012 +AC8->AC8_CODCON+" - " +Tk061ContDesc(AC8->AC8_CODCON) + STR0013 + CRLF
				TK061Write(@cText,nHandle,.T.) // Funcao utilizada para controle do tamanho da  variavel cText.
				
				DbSelectArea("AC8")
				DbSkip()
				Loop
			Endif
			
			//----------------------------------------------------------------------------
			// Avalia se o contato está bloqueado quando estiver configurado 
			// para nao enviar contatos bloqueados em listas de telefone ou email 
			// (M->U4_FORMA $ '123')			
			//----------------------------------------------------------------------------
			If M->U4_BLQCONT == "2" .AND. M->U4_FORMA $ '123'
				If Tk061HasBlock(AC8->AC8_CODCON, IF(M->U4_FORMA $ '12', 1, 2) )
					DbSelectArea("AC8")
					DbSkip()
					Loop
				EndIF
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Percorre o cadastro de contatos :                    ³
			//³1) Se nao tiver o telefone selecionado gravado SKIP  ³
			//³2) Se nao tiver o endereco selecionado gravado SKIP  ³
			//³3) Se nao existir o contato pega os dados da empresa ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SU5")
			DbSetOrder(1)
			If DbSeek(xFilial("SU5")+AC8->AC8_CODCON)  
			
				If lTk061SU5
					cFilSU5 := ExecBlock("TK061SU5",.F.,.F.,{cEntidade,cSelOper,lLog})
					If ValType(cFilSU5) <> "C"
						cFilSU5 := ""               					
					EndIf
					If !Empty(cFilSU5) .And. !(&cFilSU5)
						AC8->(dbSkip())
						Loop
					EndIf 
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente contatos atualizados serão aceitos.						  ³
			    //³Em caso de Suspects permite a selecao de contatos desatualizados   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SU5->U5_STATUS == "1" .AND. AC8->AC8_ENTIDA <> "ACH"  // Desatualizado 
					cText +="01"+ STR0012 +AC8->AC8_CODCON+" - " +Tk061ContDesc(AC8->AC8_CODCON) + STR0043 +  CRLF 
					TK061Write(@cText,nHandle)

					DbSelectArea("AC8")
					DbSkip()
					Loop
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se foi chamado pelo botao da lista de aniversario e se o dia³
				//³da execussao da lista e o dia do aniversario do contato.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nAniver == 1 
					If !Empty(M->U4_CONTATO)
						If !Empty(M->U4_OCODISC)
							If DtoS(SU5->U5_NIVER) <> DtoS(CTOD(SUBSTR(M->U4_CONTATO,1,5)+"/"+M->U4_OCODISC))
								//"O Contato " " não faz aniversario na data definida para a lista."
								cText +="02"+ STR0012 +AC8->AC8_CODCON+" - " +Tk061ContDesc(AC8->AC8_CODCON) + STR0014+  CRLF 
								TK061Write(@cText,nHandle)

								DbSelectArea("AC8")
								DbSkip()
								Loop
							Endif	
						Else
							If SubStr(DtoS(SU5->U5_NIVER),5,4) <> SubStr(DtoS(CTOD(SUBSTR(M->U4_CONTATO,1,5))),5,4)
								//"O Contato " " não faz aniversário na data definida para a lista."
								cText +="02"+ STR0012 +AC8->AC8_CODCON+" - " +Tk061ContDesc(AC8->AC8_CODCON) + STR0014 + CRLF 
								TK061Write(@cText,nHandle)
								
								DbSelectArea("AC8")
								DbSkip()
								Loop
							Endif
						Endif	
					Else
						If !lLstDiaria 
							If SU5->U5_NIVER < CTOD(SUBSTR(M->U4_NSTATUS,1,10)) .OR. SU5->U5_NIVER > CTOD(SUBSTR(M->U4_NSTATUS,11,10))
								//"O Contato " " nao faz aniversario na data definida para a lista."
								cText +="02"+ STR0012 +AC8->AC8_CODCON+" - " +Tk061ContDesc(AC8->AC8_CODCON) + STR0014+  CRLF
								TK061Write(@cText,nHandle)

								DbSelectArea("AC8")
								DbSkip()
								Loop
							Endif
						Endif	
					Endif	
				Endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se foi chamado pelo botao da lista de periodicidade e avalia se a data de execucao       ³
				//³da lista e maior ou igual ao ultimo contato mais os dias de intervalo.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nPeriod == 1) .AND. !Empty(SU5->U5_ULTCONT) .AND. ((SU5->U5_ULTCONT + SU5->U5_PERIOD) > M->U4_DATA)
					//" nao se enquadra no perfil de periodicidade."
					cText +="02"+ STR0012 +AC8->AC8_CODCON+" - " +Tk061ContDesc(AC8->AC8_CODCON) + STR0015+  CRLF 
					TK061Write(@cText,nHandle)

					DbSelectArea("AC8")
					DbSkip()
					Loop
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o NIVEL estiver vazio nao exclue da lista por nivel³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cMv_par01)
					If SU5->U5_NIVEL <> cMv_par01 //Nivel
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						//"Nivel do contato " " diferente do nivel selecionado no 'Perfil do Contato'."
						cText +="02"+ STR0016+ AC8->AC8_CODCON +" - "+ Tk061ContDesc(AC8->AC8_CODCON)+ STR0017+  CRLF 
						TK061Write(@cText,nHandle)
						
						DbSelectArea("AC8")
						DbSkip()
						Loop
					Endif
				Endif
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida o tipo de telefone para contato.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					Case (M->U4_FORMA == "1")   //Voz
						
						If Val(M->U4_TIPOTEL) == 1 // RESIDENCIAL - Residencial
							cTel:= SU5->U5_FONE
							cTextAux := STR0018//"Residencial."		//Texto que sera exibido no Resumo de falhas da geracao de Lista
							
						ElseIf Val(M->U4_TIPOTEL) == 2 // CELULAR - Celular
							cTel:= SU5->U5_CELULAR
							cTextAux := STR0019 //"Celular."
							
						ElseIf Val(M->U4_TIPOTEL) == 3 // FAX - Fax
							cTel:= SU5->U5_FAX
							cTextAux := STR0020 //"Fax"
							
						ElseIf Val(M->U4_TIPOTEL) == 4 // COMERCIAL1 - Comercial 1
							cTel:= SU5->U5_FCOM1
							cTextAux := STR0021 //"Comercial 1"
							
						ElseIf Val(M->U4_TIPOTEL) == 5 // COMERCIAL2 - Comercial 2
							cTel:= SU5->U5_FCOM2         
							cTextAux := STR0022 //"Comercial 2."
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o tipo de telefone para a geracao da lista nao existir no contato, passa para o proximo contato ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cTel)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						    //": não possui telefone "
							cText +="01"+ STR0023+ AC8->AC8_CODCON + " - "+Tk061ContDesc(AC8->AC8_CODCON)+STR0024 + cTextAux + CRLF
							TK061Write(@cText,nHandle)
							
							DbSelectArea("AC8")
							DbSkip()
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
						If Empty(SU5->U5_FAX)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TK061Write(@cText,nHandle)
							cText +="01"+ STR0023 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0024 + M->U4_TIPOTEL  + "." + CRLF 
							AC8->(DbSkip())
							Loop
						Endif
						
					Case (M->U4_FORMA == "3")  //Cross-Posting
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o contato nao possuir e-mail passa para o proximo contato.       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(SU5->U5_EMAIL) .OR. (SU5->U5_AUTORIZ <> "1")
						
	    					If  Empty(SU5->U5_EMAIL) .AND. (SU5->U5_AUTORIZ <> "1")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   					//" nao possui e-mail cadastrado e em seu cadastro nao ha permissao para recebimento de e-mail. "
			   					cText +="01"+ STR0012+ AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0025 + CRLF 
			   					TK061Write(@cText,nHandle)
			   					
	    					Elseif Empty(SU5->U5_EMAIL)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    						//" nao possui e-mail cadastrado."
	    						cText +="01"+ STR0012 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0026 + CRLF
	    						TK061Write(@cText,nHandle)
	    						
	    					ElseIf (SU5->U5_AUTORIZ <> "1")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    					//" Em seu cadastro não ha permissão para envio de E-mail ."
		    					cText +="01"+ STR0027+ AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0028 + CRLF
		    					TK061Write(@cText,nHandle)
	    					Endif
	
							DbSelectArea("AC8")
							DbSkip()
							Loop
	    				Endif
						
					Case (M->U4_FORMA == "4")  //Mala-Direta
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o contato nao possuir endereco passa para o proximo contato.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If M->U4_TIPOEND == "1" // Residencial 
							If Empty(SU5->U5_END)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								//" nao possui endereco residencial cadastrado."
								cText +="01"+ STR0012+ AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ " nao possui endereco residencial cadastrado."+ CRLF 
								TK061Write(@cText,nHandle)
								
								DbSelectArea("AC8")
								DbSkip()
								Loop
							Endif
						ElseIf M->U4_TIPOEND == "2" //Comercial		
                            DbSelectArea(cEntidade)
                            DbSetOrder(1)
                            If DbSeek(xFilial(cEntidade) + Substr(AC8->AC8_CODENT,1,TkEntTam(cEntidade)[1])+ Substr(AC8->AC8_CODENT,TkEntTam(cEntidade)[1]+1,TkEntTam(cEntidade)[2]))
                            	If Empty(TkEntidade(cEntidade,Substr(AC8->AC8_CODENT,1,TkEntTam(cEntidade)[1])+Substr(AC8->AC8_CODENT,TkEntTam(cEntidade)[1]+1,TkEntTam(cEntidade)[2]),2))
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									//" nao possui endereco comercial cadastrado."
									cText +="01"+ STR0012+ AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ " nao possui endereco comercial cadastrado."+ CRLF 
									TK061Write(@cText,nHandle)
									
									DbSelectArea("AC8")
									DbSkip()
									Loop
								Endif
							Endif	
						Endif	
				Endcase
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifico se vai ser avaliado o perfil do contato     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMv_par02 == 2 //Avalia
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//"Avaliando o perfil dos contatos..."
					cText += CRLF+ STR0030 + CRLF  
					TK061Write(@cText,nHandle)
					
					nDia := DOW(M->U4_DATA)	//Data de vigencia
						
					nLenAux := Len(TRIM(SU5->U5_DIALIG))
					For nC := 1 To nLenAux
							
						If Substr(SU5->U5_DIALIG,nC,1) $ Str(nDia,1,0)
							lGrava := .T.
							Loop
						Endif
							
					Next nC
					    
					If !lGrava    
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					   	//": nao recebe interacao para a data informada nesta Lista."
					   	cTextAux +="02"+ STR0023 + AC8->AC8_CODCON+" - "+Tk061ContDesc(AC8->AC8_CODCON) + STR0031 + CRLF
					Endif

					//Ignora dias da semana
                    nLenAux := Len(Alltrim(SU5->U5_DIALIG))
					For nC := 1 To nLenAux
						
						If Substr(cMv_par05,nC,1) $ Str(nDia,1,0)
							lGrava := .T.
						Endif
						
					Next nC
					
					If !lGrava    
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    	//": nao recebe interacao nos dias da Semana definidos nos parametros de Perfil (Botao Entidade)."
				    	cTextAux +="02"+ STR0023 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0032 + CRLF
				    Endif
					
					If !lGrava
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cTextAux)
							TK061Write(@cText,nHandle)
							cText +="01"+ STR0023 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0033 + CRLF //": A data de vigência e os dias da semana para ligação estao em branco no cadastro do Contato. Folder Perfil."
						Else	
							TK061Write(@cText,nHandle)
							cText += cTextAux
							cTextAux := ""
						Endif
						
						DbSelectArea("AC8")
						Dbskip()
						Loop
					
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Avalia o operador selecionado de acordo com o perfil do contato  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lGrupo
						If !Empty(SU5->U5_OPERADO) .AND. (SU5->U5_OPERADO <> IIf(Len(cSelOper) > 0,cSelOper,Space(nTamOper)))
							//"Contato ": "O operador informado no perfil deste contato é diferente do operador selecionado para a execução da Lista."
							cText += "02" + STR0023 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ ": " + STR0055 + CRLF
							TK061Write(@cText,nHandle)
							lGrava := .F. // Identifica que o registro nao deve ser gravado.
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						EndIf
					Else
						//Se a lista for gerada por grupo, verifica se o operador cadastrado no contato pertence ao mesmo grupo informado na lista
						If !Empty(SU5->U5_OPERADO) .AND. !Empty(cGrupo) .AND. Alltrim(cGrupo) <> AllTrim(TKPosto(SU5->U5_OPERADO,"U0_CODIGO"))
							//"Contato ": "O operador informado no perfil deste contato não pertence ao grupo que foi selecionado para a execução da Lista."
							cText += "02" + STR0023 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ ": " + STR0067 + CRLF
							TK061Write(@cText,nHandle)
							lGrava := .F. // Identifica que o registro nao deve ser gravado.
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se avalia perfil o horario gravado sera o do perfil do contato. ³
					//³Esta informacao pode ser armazenada neste ponto porque          ³
					//³caso o contato nao entre na lista o novo registro ira atualizar ³
					//³estas variaveis.                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(SU5->U5_HORA1) .AND. !Empty(SU5->U5_HORA2)
						cU6HrIni := SU5->U5_HORA1
						cU6HrFim := SU5->U5_HORA2
					Endif	
				
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Depois de avaliado o contato verifico a PERGUNTE escolhida   ³
				//³e se a ENTIDADE corresponde as perguntes da selecao          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					Case cPergunte == "TMK066" //Concorrentes -"SU2"
						
						lGrava := Tk061SU2(ceMv_par01)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						    //": O perfil da Entidade não se enquadra no Perfil de Entidade selecionado."
							cText +="02"+ STR0023+ AC8->AC8_CODCON+" - "+Tk061ContDesc(AC8->AC8_CODCON) + STR0034 + CRLF
							TK061Write(@cText,nHandle)
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
						
					Case cPergunte == "TMK064" .AND. cEntidade == "AC4"//Parceiros -"AC4"
						
						lGrava := Tk061AC4(ceMv_par01,ceMv_par02,ceMv_par03)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							// "Lista de Aniversario", "Aniver"
							
							cText +="02"+ STR0023 + AC8->AC8_CODCON+" - "+Tk061ContDesc(AC8->AC8_CODCON) + STR0034 + CRLF 
							TK061Write(@cText,nHandle)
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
						
					Case cPergunte == "TMK064" .AND. cEntidade == "ACH"//Suspects -"ACH"
						
						lGrava := Tk061ACH(ceMv_par01,ceMv_par02,ceMv_par03)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							//": O perfil da Entidade nao se enquadra no Perfil de Entidade selecionado."
							cText +="02"+ STR0023 + AC8->AC8_CODCON+" - "+Tk061ContDesc(AC8->AC8_CODCON) + STR0034 + CRLF
							TK061Write(@cText,nHandle)
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
						
						
					Case cPergunte == "TMK061" .AND. !(lOs .AND. lEntMonOS) //Clientes -"SA1"
						
						lGrava := Tk061SA11(ceMv_par01	,ceMv_par02	,ceMv_par03	,ceMv_par04,;
											ceMv_par05	,ceMv_par06	,ceMv_par07	,ceMv_par08,;
											ceMv_par09	,ceMv_par10	,ceMv_par11	,ceMv_par12,;
											ceMv_par13	,ceMv_par14 	,ceMv_par15)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							 //": O perfil da Entidade não se enquadra no Perfil de Entidade selecionado."
							cText +="02"+ STR0023 + AC8->AC8_CODCON+" - "+Tk061ContDesc(AC8->AC8_CODCON) + STR0034 + CRLF
							TK061Write(@cText,nHandle)
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
						
					Case cPergunte == "TMK065" //Fornecedores -"SA2"
						
						lGrava := Tk061SA2(ceMv_par01,ceMv_par02,ceMv_par03,ceMv_par04)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							//": O perfil da Entidade não se enquadra no Perfil de Entidade selecionado."
							cText +="02"+ STR0023 + AC8->AC8_CODCON+" - "+Tk061ContDesc(AC8->AC8_CODCON) + STR0034 + CRLF 
							TK061Write(@cText,nHandle)
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
						
					Case cPergunte == "TMK067" //Transportadoras -"SA4"
						
						lGrava := Tk061SA4(ceMv_par01)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							//": O perfil da Entidade não se enquadra no Perfil de Entidade selecionado."
							cText += "02"+STR0023 + AC8->AC8_CODCON+" - "+Tk061ContDesc(AC8->AC8_CODCON) + STR0034 + CRLF
							TK061Write(@cText,nHandle)

							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
						
					Case cPergunte == "TMK063" //Prospects -"SUS"
						
						lGrava := Tk061SUS(	ceMv_par01	,ceMv_par02	,ceMv_par03	,ceMv_par04,;
											ceMv_par05	,ceMv_par06	,ceMv_par07	,ceMv_par08)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							//": O perfil da Entidade nao se enquadra no Perfil de Entidade selecionado."
							cText +="02"+ STR0023+ AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0034 + CRLF
							TK061Write(@cText,nHandle)

							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
					
					Case cPergunte == "TMK068" //CROSS SELLING SD2
						
						lGrava := Tk061SA1D2(	ceMv_par01	,ceMv_par02	,ceMv_par03	,ceMv_par04,;
												ceMv_par05	,ceMv_par06	,ceMv_par07	,ceMv_par08,;
												ceMv_par09	,ceMv_par10)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							 //"nao se enquadra na selecao de cross selling ."
							cText +="02" + STR0023+ AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0042 + CRLF
							TK061Write(@cText,nHandle)
							
							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
					Case cPergunte == "TMK070" //Prestadores -"BAU"
						
						lGrava := Tk061BAU(ceMv_par01,ceMv_par02,ceMv_par03,ceMv_par04,ceMv_par05	,ceMv_par06)
						If !lGrava
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							//": O perfil da Entidade nao se enquadra no Perfil de Entidade selecionado."
							cText +="02"+ STR0023+ AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0034 + CRLF
							TK061Write(@cText,nHandle)

							DbSelectArea("AC8")
							DbSkip()
							Loop
						Endif
				Endcase
		
				If !lOS
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se existem ligacoes de TeleMarketing Pendentes para este contato.   ³
					//³Caso existam ligacoes pendentes o mesmo nao sera adicionado a Lista ate que  ³
					//³a pendencia seja solucionada.        										³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Tk061ValSUC(AC8->AC8_CODCON)
						
						 //". Este contato possui ligacoes pendentes."
						cText+="02"+ STR0023 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+ STR0035+CRLF
						TK061Write(@cText,nHandle)
						
						DbSelectArea("AC8")
						DbSkip()
						Loop
					Endif
				EndIf
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica com base no Grupo de Atendimento se a Lista            ³
				//³permitirá ou não que o mesmo contato esteja mais de uma         ³
				//³vez PARA DOIS CLIENTES DISTINTOS na lista que esta sendo gerada.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Tk061ValDupli(AC8->AC8_CODCON)
					
					 //" ja pertence a esta lista."
					cText +="02"+ STR0023 + AC8->AC8_CODCON + " - " + Tk061ContDesc(AC8->AC8_CODCON) + STR0036 + CRLF
					//"A validacao de duplicidade esta ativa. Para que o Contato seja inserido na lista mais de uma vez mude para NAO o campo Val.Contat no Grupo de Atendimento."
					cText +="02"+ STR0037 +CRLF 
					TK061Write(@cText,nHandle)
					
					DbSelectArea("AC8")
					DbSkip()
					Loop
				Endif    

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o contato ja respondeu o Script Informado. Se respondeu ele nao sera adicionado a esta lista  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Tk061ValScript(AC8->AC8_CODCON,M->U4_CODCAMP,M->U4_SCRIPT)
				 	// "ja respondeu o Script Informado nesta Lista. "
					cText +="02"+  STR0023 + AC8->AC8_CODCON +" - "+Tk061ContDesc(AC8->AC8_CODCON)+STR0041 + CRLF
					TK061Write(@cText,nHandle)
					
					DbSelectArea("AC8")
					DbSkip()
					Loop
				Endif 
				
				If lOS
					lSOPValid := .F.
					DbSelectArea( "AB7" )
					DbSetOrder(6)
					If AB7->(DBSeek( xFilial( "AB7" ) + AC8->AC8_CODCON, .T. ))
						While	xFilial( "AB7" ) + AC8->AC8_CODCON == AB7->AB7_FILIAL + AB7->AB7_CODCON	.And.	;
								AB7->(!EOF())		
														
							If !lEntMonOS // Quando não for entrega e montagem será satisfação de atendimento
								DbSelectArea( "AB9" )
								DbSetOrder( 1 )
								If AB9->(DbSeek( xFilial("AB9") + AB7->AB7_NUMOS + AB7->AB7_ITEM ))					
									While	xFilial("AB9") + AB7->AB7_NUMOS + AB7->AB7_ITEM == AB9->AB9_FILIAL + AB9_NUMOS	.And.	;
											AB9->(!EOF())
										If AB9->AB9_TIPO == '1' .And. Empty(AB9->AB9_TMKLST)
											If !Empty(cOSIni) .Or. !Empty(cOSFim)
												If !(AB9->AB9_NUMOS >= cOSIni .And. AB9->AB9_NUMOS <= cOSFim)
													lSOPValid := .T.
												EndIf
											Else
												lSOPValid := .T.
											EndIf 
										EndIf
										AB9->(DbSkip())
									End
								EndIf
							Else //Para Entrega e Montagem
								DbSelectArea( "AB6" )
								DbSetOrder(1)
								MsSeek(XFilial("AB6")+AB7->AB7_NUMOS)
								If Empty(AB7->AB7_TMKLST) .AND. !Empty(AB6->AB6_NUMLOJ)
									If !Empty(cOSIni) .Or. !Empty(cOSFim)
										If !(AB7->AB7_NUMOS >= cOSIni .And. AB7->AB7_NUMOS <= cOSFim)
											lSOPValid := .T.
										EndIf
									Else
										lSOPValid := .T.
									EndIf 
								EndIf																	
							EndIf        
							AB7->(DbSkip())					
						End
					EndIf
					
					If !lSOPValid
						If !lEntMonOS
							cText += "02. " + AC8->AC8_CODCON + " - " + Tk061ContDesc(AC8->AC8_CODCON) + " " + STR0060 + CRLF // "Não foi encontrado um apontamento de ordem de serviço encerrada e disponível para o contato."
						Else
							cText += "02. " + AC8->AC8_CODCON + " - " + Tk061ContDesc(AC8->AC8_CODCON) + " " + STR0064 + CRLF //"Não foi encontrado uma ordem de serviço de entrega e montagem gerada pelo controle de lojas disponível para o contato." 
						EndIf
						TK061Write(@cText,nHandle)						
						DBSelectArea("AC8")
						DBSkip()
						Loop			
					EndIf
				EndIf
			Else
				//Contato nao encontrado (clausula do filtro)
				DbSelectArea("AC8")
				DbSkip()
				Loop				
			Endif
	
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for aniversario trabalha a gravacao da data.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nAniver == 1
			If lQuery
				dDtNiver := Posicione("SU5",1,xFilial("SU5")+AC8->AC8_CODCON,"U5_NIVER")
			Else
				dDtNiver := SU5->U5_NIVER
			Endif	
		Endif					
		
		If lOs .AND. lEntMonOS
			cNumOS := ""
			If lQuery
				cNumOS := AC8->AB6_NUMOS				
			Else
				cNumOS := AB6->AB6_NUMOS
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ja passou pelas validacoes e sera feita a gravacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		Replace U6FILIAL  With xFilial("SU6")				// Filial
		Replace U4LISTA   With M->U4_LISTA					// Lista
		Replace U6CODIGO  With StrZero(nTotLista,6)		// Codigo
		Replace AC8FILENT With AC8->AC8_FILENT				// Chave da Entidade
		Replace AC8ENTIDA With AC8->AC8_ENTIDA				// Filial da Entidade
		Replace AC8CODENT With AC8->AC8_CODENT				// Codigo da Entidade
		Replace U6ORIGEM  With "1"							// Origem da Interacao
		Replace U6CONTATO With AC8->AC8_CODCON				// Codigo do Contato
		Replace U6DATA    With M->U4_DATA					// Data
		Replace U6HRINI   With cU6Hrini						// Hora Inicial
		Replace U6HRFIM   With cU6HrFim						// Hora Final
		Replace U6STATUS  With "1"							// Status da Interacao
		Replace U5NIVER   With dDtNiver		              // Data de aniversario
		If !Empty(cNumOS)
			Replace TRB->U6NUMOS With cNumOS
		EndIf
        Msunlock()
        DbCommit()
		
		nTotLista ++
		If !Empty(M->U4_NREDUZ)
			If (nTotLista-1) >= Val(M->U4_NREDUZ) // Reutilizado campo para armazenar a qtd. total de itens por lista.
				Exit
			Endif
		Endif	
		
		DbSelectArea("AC8")
		DbSkip()        
	End                 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua as alteracoes necessarias no arquivo de trabalho para a gravacao da lista de contatos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Lista por grupo e geracao de lista de aniversario diaria.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lGrupo) .AND. (nAniver == 1) .AND. (Empty(M->U4_CONTATO)) .AND. (lLstDiaria)
		
		cNewlst	:= M->U4_LISTA
		aOper 	:= Tk061AdOper(cGrupo)
				
		DbSelectArea("TRB")
		IndRegua("TRB",cArqTrab,"U5NIVER")
		
		While !EOF()
		    nCont+=1
		    If nCont > Len(aOper)
			    nCont := 1
			Endif
			
			RecLock("TRB",.F.)
			REPLACE U4OPERADOR WITH aOper[nCont]
	        MsUnlock()
		
			DbSelectArea("TRB")
			DbSkip()
		End 
		
		IndRegua("TRB",cIndTemp1,"U4OPERADOR+DTOS(U5NIVER)")
		DbSetIndex(cIndTemp1+OrdBagExt())		
		DbGoTop()
		
		cOperAnt  := TRB->U4OPERADOR
		cNiverAnt := TRB->U5NIVER
		
		M->U4_DATA 		:= TRB->U5NIVER
		M->U4_OPERAD 	:= TRB->U4OPERADOR
		cSelOper		:= TRB->U4OPERADOR
				
		While !EOF()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Em caso de quebra de operador ou de data. Será aberto           ³
			//³um novo SU4, ja que o anterior ja foi encerrado, para a criacao ³
			//³de uma nova lista de contatos.                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cOperAnt <> TRB->U4OPERADOR .OR. cNiverAnt <> TRB->U5NIVER
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Abre uma nova lista na memoria ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SU4")
				DbSetOrder(1)
				RegToMemory( "SU4", .T. )
				cNewlst	:= 	M->U4_LISTA
				
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Traz o mesmo cabecalho da Lista anterior     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                For nCampo:= 1 To FCount()
					If FieldName(nCampo) <> "U4_LISTA"
						M->&(FieldName(nCampo)) := SU4->&(FieldName(nCampo))
					Endif	
     			Next nCampo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza data da lista de contatos.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->U4_DATA 		:= TRB->U5NIVER
				M->U4_OPERAD 	:= TRB->U4OPERADOR
				cSelOper		:= TRB->U4OPERADOR	
				cOperAnt  		:= TRB->U4OPERADOR 
				cNiverAnt 		:= TRB->U5NIVER
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Flag para Efetuar a gravacao do novo cabecalho³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lGrvCab := .F.
				
				DbSelectArea("TRB")
			Endif                
			
			aLista := {}					
			
			AAdd(aLista, {	U6FILIAL				,;	// 01- Filial
							cNewLst					,;  // 02- Lista
							U6CODIGO				,;	// 03- Codigo
							AC8FILENT				,;	// 04- Chave da Entidade
							AC8ENTIDA				,;	// 05- Filial da Entidade
							AC8CODENT				,;	// 06- Codigo da Entidade
							U6ORIGEM				,;	// 07- Origem da Interacao
							U6CONTATO				,;	// 08- Codigo do Contato
							U5NIVER				,;	// 09- Data
							U6HRINI				,;	// 10- Hora Inicial
							U6HRFIM				,;	// 11- Hora Final
							U6STATUS				,;	// 12- Status da Interacao
							U6NUMOS				})	// 13- Numero da OS
			
			
			lRet := Tk061Grava(nOpc		,aLista	,@cAssunto	,@cMensagem	,;
								@cAttach	,@aAttach	,@cFiltro	,@cSelOper	,;
								@lGrvCab	,nSaveSX8	,lOS		,cOSIni		,;
								cOSFim		,lEntMonOS)
				
		    aLista := {}		
			
			DbSelectArea("TRB")
			DbSkip()
		End 
		
	ElseIf lGrupo  
	
		cNewlst	:= 	M->U4_LISTA

		aOper := Tk061AdOper(cGrupo)
				
		DbSelectArea("TRB")
		DbGoTop()
		
		While !EOF()
		    nCont+=1
		    If nCont > Len(aOper)
			    nCont := 1
			Endif
			
			RecLock("TRB",.F.)
				REPLACE U4OPERADOR WITH aOper[nCont]
	        MsUnlock()
		    
			DbSkip()
		End 
		
		IndRegua("TRB",cArqTrab,"U4OPERADOR")
		DbGoTop()
		
		cOperAnt := TRB->U4OPERADOR		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza operador do SU4.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->U4_OPERAD 	:= TRB->U4OPERADOR
		cSelOper		:= TRB->U4OPERADOR
		
		While !EOF()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Em caso de quebra de operador . Será aberto      		       ³
			//³um novo SU4, ja que o anterior ja foi encerrado, para a criacao ³
			//³de uma nova lista de contatos.                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cOperAnt <> TRB->U4OPERADOR 
						
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Abre uma nova lista na memoria ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SU4")
				DbSetOrder(1)
				RegToMemory("SU4", .T.)
				cNewlst	:= 	M->U4_LISTA
				
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Traz o mesmo cabecalho da Lista anterior     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                For nCampo:= 1 To FCount()
					If FieldName(nCampo) <> "U4_LISTA"
						M->&(FieldName(nCampo)) := SU4->&(FieldName(nCampo))
					Endif	
     			Next nCampo
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza operador do SU4.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->U4_OPERAD 	:= TRB->U4OPERADOR
				cSelOper		:= TRB->U4OPERADOR
							            
				cOperAnt := TRB->U4OPERADOR									
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Flag para Efetuar a gravacao do novo cabecalho³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lGrvCab := .F.
	
				DbSelectArea("TRB")
			
			Endif

			
			AAdd(aLista, {	U6FILIAL			,;	// 01- Filial
							cNewLst				,;  // 02- Lista
							U6CODIGO				,;	// 03- Codigo
							AC8FILENT				,;	// 04- Chave da Entidade
							AC8ENTIDA				,;	// 05- Filial da Entidade
							AC8CODENT				,;	// 06- Codigo da Entidade
							U6ORIGEM				,;	// 07- Origem da Interacao
							U6CONTATO				,;	// 08- Codigo do Contato
							U6DATA					,;	// 09- Data
							U6HRINI				,;	// 10- Hora Inicial
							U6HRFIM				,;	// 11- Hora Final
							U6STATUS				,;	// 12- Status da Interacao
							U6NUMOS				})	// 13- Numero da OS

			lRet := Tk061Grava(nOpc		,aLista	,@cAssunto	,@cMensagem	,;
								@cAttach	,@aAttach	,@cFiltro	,@cSelOper	,;
								@lGrvCab	,nSaveSX8	,lOS		,cOSIni		,;
								cOSFim		,lEntMonOS)
				
	     	aLista := {}		
			DbSelectArea("TRB")
			DbSkip()
		End 
	
	ElseIf (nAniver == 1 .AND. Empty(M->U4_CONTATO) .AND. lLstDiaria )
		
		cNewlst	:= 	M->U4_LISTA
		
		DbSelectArea("TRB")
		IndRegua("TRB",cArqTrab,"U5NIVER")
		DbGoTop()
	
		cDia 		:= StrZero(Day(TRB->U5NIVER),2)
		cMes 		:= StrZero(Month(TRB->U5NIVER),2)
		cAno 		:= Alltrim(Str(Year(dDataBase)))
		cDtBirth	:= cAno + cMes + cDia
		dDtBirth	:= STOD(cDtBirth)
	
		cNiverAnt := dDtBirth		
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza data da lista de contatos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->U4_DATA := dDtBirth

        While !EOF()
        	cDia 		:= StrZero(Day(TRB->U5NIVER),2)
			cMes 		:= StrZero(Month(TRB->U5NIVER),2)
			cAno 		:= Alltrim(Str(Year(dDataBase)))
			cDtBirth	:= cAno + cMes + cDia
			dDtBirth	:= STOD(cDtBirth)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Em caso de quebra de data, sera aberto un novo SU4 para a gera- ³
			//³cao de uma nova lista de aniversario.                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cNiverAnt <> dDtBirth
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Abre uma nova lista na memoria ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SU4")
				DbSetOrder(1)
				RegToMemory("SU4", .T.)
				cNewlst	:= 	M->U4_LISTA
						
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Traz o mesmo cabecalho da Lista anterior     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLenAux := FCount()
	            For nCampo:= 1 To nLenAux
					If FieldName(nCampo) <> "U4_LISTA"
						M->&(FieldName(nCampo)) := SU4->&(FieldName(nCampo))
					Endif	
	   			Next nCampo
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza data da lista de contatos.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->U4_DATA 	:= dDtBirth
				cNiverAnt 	:= dDtBirth
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Flag para Efetuar a gravacao do novo cabecalho³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lGrvCab := .F.

				DbSelectArea("TRB")
			Endif
				
			AAdd(aLista, {	U6FILIAL				,;	// 01- Filial
							cNewLst					,;  // 02- Lista
							U6CODIGO				,;	// 03- Codigo
							AC8FILENT				,;	// 04- Chave da Entidade
							AC8ENTIDA				,;	// 05- Filial da Entidade
							AC8CODENT				,;	// 06- Codigo da Entidade
							U6ORIGEM				,;	// 07- Origem da Interacao
							U6CONTATO				,;	// 08- Codigo do Contato
							dDtBirth				,;	// 09- Data
							U6HRINI				,;	// 10- Hora Inicial
							U6HRFIM				,;	// 11- Hora Final
							U6STATUS				,;	// 12- Status da Interacao
							U6NUMOS				})	// 13- Numero da OS

			lRet := Tk061Grava(	nOpc		,aLista		,@cAssunto	,@cMensagem	,;
								@cAttach	,@aAttach	,@cFiltro	,@cSelOper	,;
								@lGrvCab	,nSaveSX8	,lOS		,cOSIni		,; 
								cOSFim		,lEntMonOS)
								
		     aLista := {}
				
			DbSelectArea("TRB")		
			DbSkip()
		End 
	Else
		DbSelectArea("TRB")
		DbGoTop()
		If nAniver == 1
			cDia 		:= StrZero(Day(TRB->U5NIVER),2)
			cMes 		:= StrZero(Month(TRB->U5NIVER),2)
			cAno 		:= Alltrim(Str(Year(dDataBase)))
			cDtBirth	:= cAno + cMes + cDia
			dDtBirth	:= STOD(cDtBirth)
		EndIf
		While !EOF()
			If nAniver == 1
				cDia 		:= StrZero(Day(TRB->U5NIVER),2)
				cMes 		:= StrZero(Month(TRB->U5NIVER),2)
				cAno 		:= Alltrim(Str(Year(dDataBase)))
				cDtBirth	:= cAno + cMes + cDia
				dDtBirth	:= STOD(cDtBirth)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravacao normal da lista de contatos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd(aLista, {	U6FILIAL				,;	// 01-Filial
							M->U4_LISTA				,;  // 02-Lista
							U6CODIGO				,;	// 03-Codigo
							AC8FILENT				,;	// 04-Chave da Entidade
							AC8ENTIDA				,;	// 05-Filial da Entidade
							AC8CODENT				,;	// 06-Codigo da Entidade
							U6ORIGEM				,;	// 07-Origem da Interacao
							U6CONTATO				,;	// 08-Codigo do Contato
							IIf(nAniver == 1,dDtBirth,U6DATA),;	// 09-Data
							U6HRINI				,;	// 10-Hora Inicial
							U6HRFIM				,;	// 11-Hora Final
							U6STATUS				,;					// 12-Status da Interacao
							U6NUMOS				})	// 13- Numero da OS
							
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza data da lista de contatos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nAniver == 1 .And. !Empty(M->U4_CONTATO)
				M->U4_DATA 	:= dDtBirth
			EndIf

			lRet := Tk061Grava(	nOpc		,aLista		,@cAssunto	,@cMensagem	,;
								@cAttach	,@aAttach	,@cFiltro	,@cSelOper	,;
								@lGrvCab	,nSaveSX8	,lOS		,cOSIni		,;
								cOSFim		,lEntMonOS)
								
	        aLista := {}
			DbSelectArea("TRB")
			DbSkip()
		End						
	Endif

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que executara a validacao dos itens enviados pela rotina automatica.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := Tk061VldAuto(	nOpc		,aLista		,cSelOper	,@cAssunto,;
							@cMensagem	,@cAttach	,@aAttach	,@cFiltro) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Texto que sera exibido no Resumo de falhas da geracao de Lista.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	cText +="02"+ STR0056		//" Atencao, a lista não foi gerada!   "
	If !lDados
		cText +="01"+ STR0038	//"Nao ha relacionamento de Contatos para a Entidade Selecionada."
	Endif
	TK061Write(@cText,nHandle,.T.)
Else
	cText +="02"+ STR0057 		//" Lista gerada com Sucesso!   "
	TK061Write(@cText,nHandle,.T.)
	
	If (nOpc == INCLUIR) .OR. (nOpc == INCLUIAUTO) .OR. (nOpc == ASSISTENTE)
		While (GetSx8Len() > nSaveSx8)
			ConfirmSx8()
		End	
	Endif
Endif

aLista:= {}

#IFDEF TOP
	If !lLog
		If TcSrvType() <> "AS/400"
			DbSelectArea("AC8")
			DbCloseArea()
			ChkFile("AC8")
		Endif
	Endif
#ENDIF

CursorArrow()

If lRet
	// Só irá eliminar os filtros digitados pelo usuário se a lista foi gerada, pois se o usuário clicar 2x na geração da lista, quando
	// a primeira execução foi .F., ele perdia os filtros, acabando por gerar a lista com todos os clientes e contatos, não se importando
	// com o filtro de seleção configurado no Wizard. Se o usuário não quiser mais o filtro, ele precisará retornar à tela dos filtros e 
	// excluí-los para que a rotina não os considere mais.
	cFiltro := ""
	If cPergunte == "TMK068"
		Tk061SetFilt(cFiltro,"SD2")
	Else
		Tk061SetFilt(cFiltro,cEntidade)
	Endif

	cFiltroU5	:= ""
	Tk061SetFilt(cFiltroU5,"SU5")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga tabela temporária ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If( ValType(oTempTable) == "O")
	oTempTable:Delete()
	FreeObj(oTempTable)
	oTempTable := nil
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061WriteºAutor  ³ Vendas Clientes    º Data ³  27/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Avalia o tamanho do texto de log, armazena em disco e     º±±
±±º          ³limpa variáel para nao existir estouro de pilha.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 -Lista de Contatos                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK061Write(cText,nHandle,lFim)

DEFAULT lFim := .F.

//Se tamanho do texto for maior que 200 bytes grava no arquivo texto 
If ((Len(cText)>200) .OR. (lFim))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Escreve arquivo de Log.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FWrite(nHandle, cText) 
	cText := ""
Endif

If lFim
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecho arquivo para poder move-lo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)                          
Endif

Return NIL      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061Help ºAutor  ³ Vendas Clientes    º Data ³  21/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe todas as inconformidades de dados que nao permitiram aº±±
±±º          ³geracao da Lista.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Help(cText)

Local cPath			:= TRIM(GetTempPath())
Local nTentativa	:= 0
Local nErase		:= 1
Local cStartPath	:= GetSrvProfString("Startpath","")
Local aArea			:= {}
Local lHtml    		:= IsHTML()		// Indica se e remote HTML
Local cSeparador 	:= Iif( "LINUX" $  Upper(Alltrim(TCSrvType())), "/" , "\")
Local cArqLog		:= "TMKSU4LISTA_" + AllTrim(cEmpAnt) + AllTrim(cFilAnt) + ".LOG"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o SmartClient for HTML, bloqueia o log (poque nao consegue acessar diretorio local) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lHtml
	nOpc := Aviso(STR0061,STR0062,{STR0063},2)
	Return(NIL)
EndIf


If Alias() <> "TRB"      
	aArea := GetArea()
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe uma mensagem no NOTEPAD se o sistema detectou porque a Lista nao foi gerada        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ALLTRIM(cText)) <> "OBRIGAT_FALSE"  

	If Subs(cStartPath,Len(cStartPath),1) <> cSeparador
		cStartPath += cSeparador
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordena arquivo texto e apresenta em tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk061OrderFile(cStartPath+cArqLog)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apago arquivo antigo do temp³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File(cPath+cArqLog)
		nErase := FERASE(cPath+cArqLog)   
		
		While nErase = -1 
			nTentativa++
			nErase := FERASE(cPath+cArqLog)
			If nTentativa >100
				MsgStop(STR0058+cPath+cArqLog+STR0059)    //"Não foi possível apagar o arquivo: " /" O Log não pode ser armazenado no diretório temporário."
				Exit
			Endif		
		End
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o arquivo temp tenha sido deletado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nErase <> -1
		CpyS2T( cStartPath+cArqLog ,cPath, .T. ) // Salva em Txt o Log.
	Endif
	
	//Final do processo de selecao. "Ocorrencias encontradas no processo de selecao da Base de Dados."
	MsgInfo(STR0039+CRLF+STR0040)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se deletou o arquivo temporario abre do diretorio temp. Caso contrario abre do sigaadv³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nErase <> -1
		WinExec("NOTEPAD "+cPath+cArqLog,1)
	Else
		WinExec('NOTEPAD '+cArqLog,1)
	Endif	
	
	cText :=""
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif	
	
Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061ValDupliºAutor³ Vendas Clientes   º Data ³  07/18/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Caso definido no Grupo de Atendimento, Verifica se o conta-º±±
±±º          ³to sera ou nao incluso mais de uma vez na lista de contatos.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061ValDupli(cContato)

Local cValida 		:= TKPosto(TkOperador(),"U0_VALCONT")
Local aArea 		:= {}
Local lRet	 		:= .F.

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

If cValida == "1" // Sim
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se este contato ja esta nesta lista que esta sendo gerada .³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU6")
	DbSetOrder(1)
	If DbSeek(xFilial("SU6") + M->U4_LISTA)
		While	!Eof() .AND.;
				SU6->U6_FILIAL == xFilial("SU6") .AND.;
				SU6->U6_LISTA == M->U4_LISTA 

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Independente do Status, se o contato existir em outra Lista  ³
				//³para o mesmo dia ele nao sera incluido nesta geracao.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  (M->U4_LISTA==SU6->U6_LISTA) .AND. (cContato == SU6->U6_CONTATO)
					lRet:= .T.
					Exit
				Endif
		
			DbSkip()
		End
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061VALSUCºAutor  ³ Vendas Clientes   º Data ³  21/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se existem registros pendentes do Atend. TeleMarke- º±±
±±º          ³ting. Caso exista este contato não sera incluso na lista.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK061VALSUC(cContato)
Local lRet := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida as ligacoes com Status = 2 (pendencia).³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUC")
DbSetOrder(6)
IF 	DbSeek(xFilial("SUC")+cContato)
	While (!Eof() .AND. xFilial("SUC")==UC_FILIAL .AND. AC8->AC8_CODCON==UC_CODCONT)
		If  (Val(UC_STATUS) == PENDENTE)//2
			lRet  := .F.
			Exit          
		Endif 
		DbSkip()
    End
Endif


Return (lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061SA11  ³ Autor ³ Vendas Clientes       ³ Data ³ 21/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o SA1                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061SA11(	ceMv_par01	,ceMv_par02	,ceMv_par03	,ceMv_par04,;
							ceMv_par05	,ceMv_par06	,ceMv_par07	,ceMv_par08,;
							ceMv_par09	,ceMv_par10	,ceMv_par11	,ceMv_par12,;
							ceMv_par13	,ceMv_par14	,ceMv_par15)

Local lRet 	:= .F. 	// Se o retorno for TRUE grava, senao avanca o registro do AC8
Local aArea := {}   // Salva a area atual

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TMK061                         ³
  ³                               ³
  ³Mv_Par01  Maior Valor de Compra³
  ³Mv_Par02  Data Ultima Compra   ³
  ³Mv_Par03  Data Ultima Visita   ³
  ³Mv_Par04  Segmento Negocio 1   ³
  ³Mv_Par05  Segmento Negocio 2   ³
  ³Mv_Par06  Segmento Negocio 3   ³
  ³Mv_Par07  Segmento Negocio 4   ³
  ³Mv_Par08  Segmento Negocio 5   ³
  ³Mv_Par09  Segmento Negocio 6   ³
  ³Mv_Par10  Segmento Negocio 7   ³
  ³Mv_Par11  Segmento Negocio 8   ³
  ³Mv_Par12  Do grupo?            ³
  ³Mv_Par13  Até o grupo?         ³
  ³Mv_Par14  Do Produto?          ³
  ³Mv_Par15  Até o produto?       ³        
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ENTIDADE corresponde ao Conteudo dos Parametros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek( xFilial("SA1") + AllTrim(AC8->AC8_CODENT) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se todos os parametros estiverem em branco nao valida a entidade.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ceMv_Par01 == 0)  	.AND. Empty(ceMv_Par02) .AND. Empty(ceMv_Par03) .AND.;
		Empty(ceMv_Par04) 	.AND. Empty(ceMv_Par05) .AND. Empty(ceMv_Par06) .AND.;
		Empty(ceMv_Par07) 	.AND. Empty(ceMv_Par08) .AND. Empty(ceMv_Par09) .AND.;
		Empty(ceMv_Par10) 	.AND. Empty(ceMv_Par11) .AND. Empty(ceMv_Par12) .AND.; 
		Empty(ceMv_Par13) 	.AND. Empty(ceMv_Par14) .AND. Empty(ceMv_Par15)
		
		lRet:= .T.
	Else
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida os parametros informados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	(((SA1->A1_MCOMPRA >= ceMv_Par01) .AND. (ceMv_Par01 > 0)) .OR. Empty(ceMv_Par01)) .AND.;
			((Empty(SA1->A1_ULTCOM) .OR. SA1->A1_ULTCOM <= ceMv_Par02) .OR. Empty(ceMv_Par02)) .AND.; 
			((SA1->A1_ULTVIS <= ceMv_Par03)		.OR. Empty(ceMv_Par03)) 
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 1.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par04 == SA1->A1_SATIV1) .AND. !Empty(ceMv_par04)
				lRet := .T.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 2.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par05 == SA1->A1_SATIV2) .AND. !Empty(ceMv_par05)
				lRet := .T.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 3.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par06 == SA1->A1_SATIV3) .AND. !Empty(ceMv_par06)
				lRet := .T.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 4.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par07 == SA1->A1_SATIV4) .AND. !Empty(ceMv_par07)
				lRet := .T.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 5.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par08 == SA1->A1_SATIV5) .AND. !Empty(ceMv_par08)
				lRet := .T.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 6.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par09 == SA1->A1_SATIV6) .AND. !Empty(ceMv_par09)
				lRet := .T.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 7.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par10 == SA1->A1_SATIV7) .AND. !Empty(ceMv_par10)
				lRet := .T.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o segmento 8.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ceMv_par11 == SA1->A1_SATIV8) .AND. !Empty(ceMv_par11)
				lRet := .T.
			Endif		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida todos os segmentos vazios.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If Empty(ceMv_par04) .AND. Empty(ceMv_par05) .AND. Empty(ceMv_par06) .AND.;
				Empty(ceMv_par07) .AND. Empty(ceMv_par08) .AND. Empty(ceMv_par09) .AND.;
				Empty(ceMv_par10) .AND. Empty(ceMv_par11)
				lRet := .T.
			EndIf
													
		Endif  
		
		If lRet .AND. (!Empty(ceMv_par12) .OR. !Empty(ceMv_par13) .OR. !Empty(ceMv_par14) .OR. !Empty(ceMv_par15))
			lRet:= .F.
			DbSelectArea("SD2")
			DbSetOrder(9)
			If DbSeek(xFilial("SD2")+SA1->A1_COD)
				While !EOF() .AND. SD2->D2_CLIENTE == SA1->A1_COD

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida o Grupo de Produto³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					If 	((SD2->D2_GRUPO >= ceMv_par12)	.OR. Empty(ceMv_par12)) .AND.;
						((SD2->D2_GRUPO <= ceMv_par13) .OR. Empty(ceMv_par13)) .AND.;
						((SD2->D2_COD >= ceMv_par14) 	.OR. Empty(ceMv_par14)) .AND.;
						((SD2->D2_COD <= ceMv_par15) 	.OR. Empty(ceMv_par15)) 
						lRet:= .T. 
						Exit						
					Endif
					
					
					DbSelectArea("SD2")
					DbSkip()		
				End				
			Endif
		Endif
	
		
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061SUS   ³ Autor ³ Vendas Clientes       ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o SUS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061SUS(ceMv_par01,ceMv_par02,ceMv_par03,ceMv_par04,ceMv_par05,ceMv_par06,ceMv_par07,ceMv_par08)

Local lRet 	:= .F. 	// Se o retorno for TRUE grava, senao avanca o registro do AC8
Local aArea	:= {}   // Salva a area atual

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TMK063                         ³
  ³                               ³
  ³Mv_Par01  Segmento Negocio 1   ³
  ³Mv_Par02  Segmento Negocio 2   ³
  ³Mv_Par03  Segmento Negocio 3   ³
  ³Mv_Par04  Segmento Negocio 4   ³
  ³Mv_Par05  Segmento Negocio 5   ³
  ³Mv_Par06  Segmento Negocio 6   ³
  ³Mv_Par07  Segmento Negocio 7   ³
  ³Mv_Par08  Segmento Negocio 8   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ENTIDADE corresponde ao Conteudo dos Parametros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUS")
DbSetOrder(1)
If DbSeek( xFilial("SUS") + AC8->AC8_CODENT )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se todos os parametros estiverem em branco nao valida a entidade.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  Empty(ceMv_Par01) .AND. Empty(ceMv_Par02) .AND.;
		Empty(ceMv_Par03) .AND. Empty(ceMv_Par04) .AND.;
		Empty(ceMv_Par05) .AND. Empty(ceMv_Par06) .AND.;
		Empty(ceMv_Par07) .AND. Empty(ceMv_Par08)
		
		lRet:= .T.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 1.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par01 == SUS->US_SATIV) .AND. !Empty(ceMv_par01)
			lRet := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 2.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par02 == SUS->US_SATIV2) .AND. !Empty(ceMv_par02)
			lRet := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 3.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par03 == SUS->US_SATIV3) .AND. !Empty(ceMv_par03)
			lRet := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 4.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par04 == SUS->US_SATIV4) .AND. !Empty(ceMv_par04)
			lRet := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 5.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par05 == SUS->US_SATIV5) .AND. !Empty(ceMv_par05)
			lRet := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 6.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par06 == SUS->US_SATIV6) .AND. !Empty(ceMv_par06)
			lRet := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 7.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par07 == SUS->US_SATIV7) .AND. !Empty(ceMv_par07)
			lRet := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o segmento 8.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ceMv_par08 == SUS->US_SATIV8) .AND. !Empty(ceMv_par08)
			lRet := .T.
		Endif
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061SA2   ³ Autor ³ Vendas Clientes       ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o SA2                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061SA2(ceMv_par01,ceMv_par02,ceMv_par03,ceMv_par04)

Local lRet 	:= .F.	// Se o retorno for TRUE grava, senao avanca o registro do AC8
Local aArea := {}	// Salva a area atual	

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TMK065                      ³
  ³                            ³
  ³Mv_Par01  Natureza          ³
  ³Mv_Par02  Condicao de Pagto ³
  ³Mv_Par03  Maior Saldo       ³ 
  ³Mv_Par04  Data Ultima Compra³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ENTIDADE corresponde ao Conteudo dos Parametros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA2")
DbSetOrder(1)
If DbSeek( xFilial("SA2") + AC8->AC8_CODENT )
	If Empty(ceMv_par01) .AND. Empty(ceMv_par02) .AND. Empty(ceMv_par03) .AND. Empty(ceMv_par04) // Se estiverem todos vazios carrego todos
		lRet := .T.
	Else
		If (SA2->A2_NATUREZ == ceMv_par01) .OR. (SA2->A2_COND == ceMv_par02) .OR. (SA2->A2_MSALDO >= ceMv_par03) .OR. (SA2->A2_ULTCOM >= ceMv_par04)
			lRet   := .T.
		Endif
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061AC4   ³ Autor ³ Vendas Clientes       ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o AC4                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061AC4(ceMv_par01,ceMv_par02,ceMv_par03)

Local lRet 	:= .F. 	// Se o retorno for TRUE grava, senao avanca o registro do AC8
Local aArea := {}	// Salva a area atual	

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega na memoria as perguntes (Parametro FALSE)              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Pergunte("TMK064",.F.)

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  TMK064          ³
  ³  Mv_Par01  Cidade³
  ³  Mv_Par02  Estado³
  ³  Mv_Par03  CEP   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ENTIDADE corresponde ao Conteudo dos Parametros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("AC4")
DbSetOrder(1)
If DbSeek( xFilial("AC4") + AC8->AC8_CODENT )
	
	If Empty(ceMv_par01) .AND. Empty(ceMv_par02) .AND. Empty(ceMv_par03)
		lRet := .T.
	Else
		If (AC4->AC4_MUN == ceMv_par01) .OR. (AC4->AC4_EST == ceMv_par02) .OR. (AC4->AC4_CEP == ceMv_par03)
			lRet   := .T.
		Endif
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061ACH   ³ Autor ³ Vendas Clientes       ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o ACH                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061ACH(ceMv_par01,ceMv_par02,ceMv_par03)

Local lRet 	:= .F. 	// Se o retorno for TRUE grava, senao avanca o registro do ACH
Local aArea := {}	// Salva a area atual	

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  TMK064          ³
  ³                  ³
  ³  Mv_Par01  Cidade³
  ³  Mv_Par02  Estado³
  ³  Mv_Par03  CEP   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ENTIDADE corresponde ao Conteudo dos Parametros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ACH")
DbSetOrder(1)
If DbSeek(xFilial("ACH")+ SubStr(AC8->AC8_CODENT,1,TamSX3("ACH_CODIGO")[1]))
	
	If Empty(ceMv_par01) .AND. Empty(ceMv_par02) .AND. Empty(ceMv_par03) // Se estiverem vazios os parametros carrega todos
		lRet := .T.
	Else
		If (ACH->ACH_CIDADE == ceMv_par01) .OR. (ACH->ACH_EST == ceMv_par02) .OR. (ACH->ACH_CEP == ceMv_par03)
			lRet   := .T.
		Endif
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061SU2   ³ Autor ³ Vendas Clientes       ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o SU2                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061SU2(ceMv_par01)

Local lRet := .F. 	// Se o retorno for TRUE grava, senao avanca o registro do SU2
Local aArea := {}	// Salva a area atual	

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TMK066           ³
  ³                 ³
  ³Mv_Par01  Produto³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ENTIDADE corresponde ao Conteudo dos Parametros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU2")
DbSetOrder(1)
If DbSeek( xFilial("SU2") + AC8->AC8_CODENT )
	If Empty(ceMv_Par01)		//Se estiver vazio carrega todos
		lRet := .T.
	Else		// Se nao estiver vazio comparo o codigo com o parametro
		If (SU2->U2_COD == ceMv_Par01)
			lRet := .T.
		Endif
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061SA4   ³ Autor ³ Vendas Clientes       ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o SA4                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061SA4(ceMv_par01)

Local lRet 	:= .F. 	// Se o retorno for TRUE grava, senao avanca o registro do SA4
Local aArea := {}	// Salva a area atual	

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TMK067              ³
  ³Mv_Par01  Transporte³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ENTIDADE corresponde ao Conteudo dos Parametros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA4")
DbSetOrder(1)
If DbSeek( xFilial("SA4") + AC8->AC8_CODENT )
	If Empty(ceMv_Par01) // Se estiver vazio carrego todos
		lRet := .T.
	Else
		If (SA4->A4_VIA == ceMv_Par01)
			lRet   := .T.
		Endif
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061SA1D2 ³ Autor ³ Vendas Clientes       ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para o SD2                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061SA1D2(ceMv_par01,ceMv_par02,ceMv_par03,ceMv_par04,ceMv_par05,ceMv_par06,ceMv_par07,ceMv_par08,ceMv_par09,ceMv_par10)

Local lRet := .F. // Retorno da funcao
Local aArea := {}	// Salva a area atual	

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

DbSelectArea("SD2")
DbSetOrder(9) // FILIAL+CLIENTE+LOJA chave parcial
If DbSeek( xFilial("SD2") + AllTrim(AC8->AC8_CODENT) ) // codent = CLiente+Loja
	
	While 	(!Eof()) 							.AND.;
			xFilial("SD2") == SD2->D2_FILIAL    .AND.;
			SD2->D2_CLIENTE >= ceMv_Par01		.AND.;
			SD2->D2_CLIENTE <= ceMv_Par02		.AND.;	
			SD2->D2_LOJA >= ceMv_Par03			.AND.;
			SD2->D2_LOJA <= ceMv_Par04			
			 
		If  SD2->D2_EMISSAO >= ceMv_Par05		.AND.;
			SD2->D2_EMISSAO <= ceMv_Par06		.AND.;
			SD2->D2_COD >= ceMv_Par07			.AND.;
			SD2->D2_COD <= ceMv_Par08		    .AND.;
			SD2->D2_GRUPO >= ceMv_Par09			.AND.;
			SD2->D2_GRUPO <= ceMv_Par10		    
			
			
			// A entidade se enquadra nos parametros, ou seja, faz parte da selecao. 
			lRet := .T.
			Exit					
		Endif	 
   		SD2->(DbSkip())
	End
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061OutraLista ºAutor  ³ Vendas Cli.  º Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Verifica se o contato ja esta em alguma outra lista		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Lista de Contato                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061OutraLista(cContato)

Local aArea		:= GetArea()
Local aAreaSU4	:= SU4->(GetArea())
Local aAreaSU6	:= SU6->(GetArea())
Local lRet   	:= .F.		// Retorno da funcao
Local cQuery 	:= ""
Local cAlias 	:= ""

//Para o modulo TMK independente do status, se o contato existir em outra Lista para o mesmo dia ele nao sera incluido nesta geracao.
//Dessa forma adicionado o !Empty(U4_ENTIDA) para ignorar as listas criadas pelo CRM, pois as listas de marketing criadas pelo CRM 
//o contato poderá existir em diversas listas do mesmo dia.

#IFDEF TOP

	cAlias := GetNextAlias()
		
	cQuery := " SELECT U6_LISTA, COUNT(U6_LISTA) TOTALREG "
	cQuery += " FROM "+RetSqlName("SU6")+" SU6"
	cQuery += " INNER JOIN " +RetSqlName("SU4")+" SU4 ON U4_FILIAL = U6_FILIAL AND U4_LISTA = U6_LISTA AND SU4.D_E_L_E_T_ = '' "
	cQuery += " WHERE U6_FILIAL = '" + xFilial("SU6") + "' AND (U6_STATUS = '1' OR U6_STATUS = '2' OR U6_STATUS = '3') AND U6_DATA = '"+DTOS(M->U4_DATA)+"' "
	cQuery += " AND  U4_ENTIDA = '' AND U6_CONTATO = '"+cContato+"' AND U6_LISTA <> '"+M->U4_LISTA+"' "
	cQuery += " AND SU6.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY U6_LISTA "
		
	cQuery := ChangeQuery(cQuery)
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
		
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)		
		
	nQtdReg := 0

	If (cAlias)->TOTALREG > 0
		cLista := (cAlias)->U6_LISTA
	    nQtdReg := (cAlias)->TOTALREG
	EndIf
		
	(cAlias)->(DbCloseArea())
	
	If nQtdReg > 0
		lRet := .T.
	EndIf

#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Permite que o contato esteja em duas lista de formas de contato diferentes.³
	//³Se for selecionado sim(valida) a avaliacao abaixo não sera efetuada.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TkPosto(TkOperador(),"U0_VALCONT") == "2"  
		If lRet 
			DbSelectArea("SU4")
			DbSetOrder(1)
			If DbSeek(xFilial("SU4") + SU6->U6_LISTA)
				If SU4->U4_FORMA <> M->U4_FORMA
					lRet := .F.
				Endif
			Endif
		Endif
	Endif

RestArea(aAreaSU4)
RestArea(aAreaSU6)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061ContDescºAutor  ³ Vendas Clientes    º Data ³  30/07/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descricao do contato. Objetivo Salvar a area anteriorº±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061ContDesc(cContato)

Local aArea  := {}		// Salva a area atual
Local cDesc  := ""		// Retorno da funcao

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

DbSelectArea("SU5")
DbSetOrder(1)
If DbSeek(xFilial("SU5")+cContato)
	cDesc := TRIM(SU5->U5_CONTAT)+"" 
	FATPDLogUser('TK061CONTD')	// Log de Acesso LGPD
Endif
	
If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(cDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061SETFILTºAutor  ³ Vendas Clientes    º Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa o filtro selecionado.                                º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 - Lista de Contatos                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061SetFilt(cFiltro,cEntidade)
Local aArea := GetArea()

DbSelectArea(cEntidade)
DbCloseArea()
ChkFile(cEntidade)
If !Empty(cFiltro)
	DbSetfilter({||&cFiltro},cFiltro) 
Else
	DbClearFilter()
EndIf
DbGotop()

RestArea(aArea)
aSize(aArea, 0)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061aLista  ºAutor ³ Vendas Clientes    º Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega array com informacoes para gravacao                  º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aLista : Array para informacoes de gravacao do item          º±±
±±º          ³ nI     : Posicao do for no Acols                             º±±
±±º          ³ aCampos: Array com os campos para pesquisa de posicao        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - Lista de Contatos                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061aLista(aLista,nI,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis					             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aPosicoes := {}									// Array auxiliar onde serao armazenadas as posicoes dos campos.
Local nPCodigo  := 0									//-
Local nPCodEnt  := 0                                    //  -- Posicao dos campos no aCols.
Local nPCodCon  := 0                                    // |
Local nPHrIni   := 0                                    // |
Local nPHrFim   := 0                                    //-
Local nPEntida	:= 0
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica posicionamento dos campos (ordem)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aPosicoes,{"U6_CODIGO"  ,Ascan(aCampos,"U6_CODIGO"		)})	//1
Aadd(aPosicoes,{"U6_CONTATO" ,Ascan(aCampos,"U6_CONTATO"	)})	//2 
Aadd(aPosicoes,{"U6_NCONTAT" ,Ascan(aCampos,"U6_NCONTAT"	)})	//3
Aadd(aPosicoes,{"U6_CODENT"  ,Ascan(aCampos,"U6_CODENT"		)})	//4
Aadd(aPosicoes,{"U6_DESCENT" ,Ascan(aCampos,"U6_DESCENT"	)})	//5
Aadd(aPosicoes,{"U6_HRINI"   ,Ascan(aCampos,"U6_HRINI" 		)})	//6
Aadd(aPosicoes,{"U6_HRFIM"   ,Ascan(aCampos,"U6_HRFIM"		)})	//7
Aadd(aPosicoes,{"U6_ENTIDA"  ,Ascan(aCampos,"U6_ENTIDA"		)})	//8

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena posicionamento dos campos para selecao dos dados (ordem) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPCodigo  := aPosicoes[1][2]
nPCodEnt  := aPosicoes[4][2]
nPCodCon  := aPosicoes[2][2]
nPHrIni   := aPosicoes[6][2]
nPHrFim   := aPosicoes[7][2]
nPEntida  := aPosicoes[8][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega array com as informacoes dos itens para gravacao          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aLista,{	xFilial("SU6")		,;				// 01 - Filial
  				M->U4_LISTA			,;				// 02 - Lista
				aCols[nI][nPCodigo]	,;				// 03 - Codigo
				xFilial(aCols[nI][nPEntida]),;		// 04 - Filial da Entidade
				aCols[nI][nPEntida]	,;	  			// 05 - Alias da Entidade
				aCols[nI][nPCodEnt]	,;				// 06 - Codigo da entidade
				"1"					,;				// 07 - Origem da Interacao // Lista de Contato
				aCols[nI][nPCodCon]	,;				// 08 - Codigo do Contato
				M->U4_DATA			,;				// 09 - Data da Lista para execucao
				aCols[nI][nPHrIni]	,;				// 10 - Hora de Inicio para Interacao.
				aCols[nI][nPHrFim]	,;				// 11 - Hora de Termino para Interacao.
				"1"})						  		// 12 - Status da Interacao - Nao Enviado
ConfirmSx8()

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061ValContMºAutor ³ Vendas Clientes    º Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a inclusao do contato manual. Funcao chamada do Valid º±±
±±º          ³do campo.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cContato: Codigo do contato para verificacao.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - Lista de Contatos                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061ValContM( cContato )

Local lRet		:= .T.													// Retorno da funcao de validacao
Local cTel		:= ""													// Variavel auxiliar
Local aArea		:= {}													// Salva alias padrao
Local aAreaSU5  := GetArea("SU5")
Local lRetEnd	:= .F.													// Retorno se encontrou o endereco na entidade
Local cEntidade	:= Tk061PegEnt()										// Variavel com a entidade escolhida pelo usuario na tela da lista de contato
Local cEntCli	:= ""													// Entidade em analise

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o contato ja existe em outra lista para o mesmo dia.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk061OutraLista( cContato )
	Help(" ",1,"TK061OUTRA")
	lRet := .F.
Endif

If lRet

	DbSelectArea("SU5")
	DbSetOrder(1)
	If DbSeek(xFilial("SU5")+cContato)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o tipo de telefone para contato.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case (M->U4_FORMA == "1")   //Voz
			
				If Val(M->U4_TIPOTEL) == 1 // RESIDENCIAL - Residencial
					cTel:= SU5->U5_FONE	
				ElseIf Val(M->U4_TIPOTEL) == 2 // CELULAR - Celular
					cTel:= SU5->U5_CELULAR	
				ElseIf Val(M->U4_TIPOTEL) == 3 // FAX - Fax
					cTel:= SU5->U5_FAX	
				ElseIf Val(M->U4_TIPOTEL) == 4 // COMERCIAL1 - Comercial 1
					cTel:= SU5->U5_FCOM1	
				ElseIf Val(M->U4_TIPOTEL) == 5 // COMERCIAL2 - Comercial 2
					cTel:= SU5->U5_FCOM2
				Endif
	
				If Empty(cTel)
			   		lRet := .F.      
	   				Help(" ",1,"TK061NTPFO")
				Endif
			
			Case (M->U4_FORMA == "2")   //Fax
				If Empty(SU5->U5_FAX)
	   				Help(" ",1,"TK061NTPFO")
	   				lRet := .F.
				Endif
			
			Case (M->U4_FORMA == "3")  //Cross-Posting
				If Empty(SU5->U5_EMAIL) .OR. ((SU5->U5_AUTORIZ) <> "1")
					If  Empty(SU5->U5_EMAIL) .AND. ((SU5->U5_AUTORIZ) <> "1")
		   				Help(" ",1,"TK061NAUEM")
		   				lRet := .F.
		
					Elseif Empty(SU5->U5_EMAIL)
		   				Help(" ",1,"TK061NMAIL")
		   				lRet := .F.
		
					ElseIf (SU5->U5_AUTORIZ <> "1")
		   				Help(" ",1,"TK061NAUT")
		   				lRet := .F.
					Endif

				Endif
			
			Case (M->U4_FORMA == "4")  //Mala-Direta
				If M->U4_TIPOEND == "1" // Residencial 
					If Empty(SU5->U5_END)
		   				Help(" ",1,"TK061NEND")
		   				lRet := .F.
					Endif
	
				ElseIf M->U4_TIPOEND == "2" //Comercial
	
					DbSelectArea( "AC8" )
					DbSetOrder( 1 )
					If DbSeek( xFilial( "AC8" ) + cContato + cEntidade + xFilial( cEntidade ) )
	
						While AC8->( !Eof() )					.AND.;
							xFilial("AC8") == AC8->AC8_FILIAL 	.AND.;
							AC8->AC8_CODCON == cContato 		.AND.;
							AC8->AC8_ENTIDA == cEntidade 		.AND.;
							AC8->AC8_FILENT == xFilial( cEntidade )
				                                                   
							DbSelectArea( cEntidade )
							DbSetOrder(1)
							If DbSeek(xFilial(cEntidade) + Substr(AC8->AC8_CODENT,1,TkEntTam(cEntidade)[1])+ Substr(AC8->AC8_CODENT,TkEntTam(cEntidade)[1] + 1,TkEntTam(cEntidade)[2]))
									If !Empty(TkEntidade(cEntidade,Substr(AC8->AC8_CODENT,1,TkEntTam(cEntidade)[1])+Substr(AC8->AC8_CODENT,TkEntTam(cEntidade)[1] + 1,TkEntTam(cEntidade)[2]),2))
		   							lRetEnd	:= .T.
		   							Exit
								Endif
							Endif
							
							DbSelectArea("AC8")
							AC8->( DbSkip() )
							Loop
						End
						If !lRetEnd
							Help(" ",1,"TK061NEND")
							lRet := .F.
						Endif








					Endif
				Endif
		Endcase
	EndIF
Endif

If lRet
	If !Tk061ValSUC(cContato)
		Help(" ",1,"TK061PENTK")
		lRet := .F.
	Endif
Endif

If lRet
	cEntCli	:= Tk061Enti()
	If cEntCli == NIL 
		cEntCli:= cEntidade
	Endif

	DbSelectArea("AC8")
	DbSetOrder(1) //FILIAL+CONTATO+ENTIDADE
	If DbSeek(xFilial("AC8")+cContato+cEntCli)
		If !Empty(cEntCli)
			If cEntCli <> AC8->AC8_ENTIDA
       			Help(" ",1,"TK061NREL",,Posicione("SX2",1,cEntCli,"X2NOME()"),3,5)
       			lRet := .F.
        	Endif
        Else
        	Help(" ",1,"TK061SRAC8")
        	lRet := .F.
        Endif
	Else
		Help(" ",1,"TK061NAC8")
		lRet := .F.
	Endif
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif
      
If Len(aAreaSU5) > 0
	RestArea(aAreaSU5)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061ValScripºAutor ³ Vendas Clientes    º Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a inclusao do contato. Caso ja tenha respondido o     º±±
±±º          ³script informado na Lista, este nao precisa ser adicionado.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cContato: Codigo do contato para verificacao.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - Lista de Contatos                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061ValScript(cContato,cCampanha,cScript)

Local lRet := .F.				// Retorno da funcao
Local aArea := GetArea()		// Salva a area atual

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

DbSelectArea("ACI")
DbSetOrder(3) // Filial - Campanha - Script 
If DbSeek(xFilial("ACI")+cCampanha+cScript)
	While(	(!EOF()) 							.AND.;
			(xFilial("ACI") == ACI->ACI_FILIAL)	.AND.;
			(cCampanha == ACI->ACI_CODCAM)		.AND.;
			(cScript ==	ACI->ACI_CODSCR))

			If ACI->ACI_CODCON == cContato
				lRet := .T. // Contato ja respondeu este Script
				Exit			
			Endif

		DbSkip()
	End
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061OrderFilºAutor ³ Vendas Clientes    º Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ordena arquivo texto de acordo com o tipo de ocorrenia.      º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cFile: Diretorio mais arquivo para ordenacao                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 - Lista de Contatos                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061OrderFile(cFile)

Local aStruct  		:= {}
Local cAliasTrab 	:= GetnextAlias()
Local cLine 		:= ""							// Variavel de auxilio para linha
Local nErase		:= 1							// Flag que indica se houve delecao fisica do arquivo
Local nHandle		:= 0 							// Arquivo texto
Local lPrim01		:= .T.							// Controla a identificacao das falhas
Local lPrim02		:= .T.							// Controla a identificacao das falhas
Local oTempTable	:= Nil
Local cArqLog		:= "TMKSU4LISTA_" + AllTrim(cEmpAnt) + AllTrim(cFilAnt)

aadd( aStruct, {"COD" 	, "C"	,2		,0 	}  )
aadd( aStruct, {"DESCR"	, "C"	,1024	,0 	}  )

//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------
oTempTable	:= FWTemporaryTable():New( cAliasTrab )

//-------------------------------------------------------------------
// Atribui o  os índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aStruct )

oTempTable:AddIndex("1",{"COD"})
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

FT_FUSE(cFile)
FT_FGOTOP()

While !FT_FEOF()
    cLine := FT_FREADLN()
	Reclock( cAliasTrab ,.T.)
	If SubStr(cLine,1,2) <> "01" .AND. SubStr(cLine,1,2) <> "02"
		Replace (cAliasTrab)->COD  	With ""
		Replace (cAliasTrab)->DESCR With cLine
	Else
		Replace (cAliasTrab)->COD   With SubStr(cLine,1,2)
		Replace (cAliasTrab)->DESCR With SubStr(cLine,3,Len(Alltrim(cLine)))
	Endif
	MsUnlock()
	FT_FSKIP()
End

FT_FUSE()                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Renomeio arquivo de log.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cFile)
	FRENAME(cArqLog+".LOG",cArqLog+".ALT")
Endif

(cAliasTrab)->(dBGoTop())
(cAliasTrab)->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria novo Log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := FCREATE(cArqLog+".LOG",1)

While (cAliasTrab)->(! EOF())
	
	If Empty( (cAliasTrab)->COD )
		FWrite(nHandle, ALLTRIM( (cAliasTrab)->DESCR )+CRLF) 
	
	ElseIf (cAliasTrab)->COD == "01"
		If lPrim01                 
			FWrite(nHandle, CRLF+CRLF) 
			lPrim01 := .F.
			FWrite(nHandle, STR0044+CRLF+CRLF) //"Falhas encontradas no cadastro do sistema:"
		Endif

		FWrite(nHandle, ALLTRIM( (cAliasTrab)->DESCR )+CRLF)  	

	ElseIf (cAliasTrab)->COD == "02"
		If lPrim02 
			FWrite(nHandle, CRLF+CRLF) 
			lPrim02 := .F.
			FWrite(nHandle, STR0045+CRLF+CRLF) //"Falhas encontradas no processo de seleção:"
		Endif

		FWrite(nHandle, ALLTRIM( (cAliasTrab)->DESCR )+CRLF)  	

	Endif
	
	(cAliasTrab)->( DbSkip() )
End

FClose(nHandle)                          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apaga arquivo de bkp ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nErase := FERASE(cArqLog+".ALT")   
	
While nErase = -1 
	nErase := FERASE(cArqLog+".ALT")
End

If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061OperDef ºAutor ³ Vendas Clientes    º Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define o tipo de selecao do Operador.                        º±±
±±º          ³ Retornar: Volta na tela para o usuario informar um Operador  º±±
±±º          ³ Automatica: O sistema procura o Operador com menos Listas e  º±±
±±º          ³ passa para ele essa nova lista                               º±±
±±º          ³ Aberta: A lista podera ser executada por varios operadores   º±±
±±º          ³ na Agenda do Operador                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                     		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061OperDef()

Local nRet := 1	// Valor DEFAULT - Manual
Local oDlg

DEFINE MSDIALOG oDlg TITLE STR0046 FROM 00,00 TO 200,431 PIXEL OF oMainWnd //"Modo de seleção do Operador."
		
	@ 02,02 TO 90,210 LABEL "" PIXEL OF oDlg
	@ 08,10 SAY STR0047 OF oDlg PIXEL SIZE 190,20  //"O Operador não foi informado. Selecione uma das opções abaixo para prosseguir com a Lista."
			
	@ 30,10  BUTTON STR0048 SIZE 040,012 ACTION (nRet := 1,oDlg:End()) OF oDlg  PIXEL //"Manual"
	@ 31,60  SAY STR0049 OF oDlg PIXEL COLOR CLR_HRED //"Retorna para que seja selecionado um Operador"
	
	@ 45,10  BUTTON STR0050 SIZE 040,012 ACTION (nRet := 2,oDlg:End()) OF oDlg  PIXEL //"Automatica"
	@ 46,60  SAY STR0003 OF oDlg PIXEL COLOR CLR_HRED //"Selecao automatica pelo sistema."
	
	@ 60,10  BUTTON STR0051   SIZE 040,012 ACTION (nRet := 3,oDlg:End()) OF oDlg  PIXEL //"Aberta"
	@ 61,60  SAY STR0052 OF oDlg PIXEL COLOR CLR_HRED	//"Essa lista poderá ser executada por mais de um Operador"

ACTIVATE MSDIALOG oDlg CENTERED

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061AdOperºAutor ³ Vendas Clientes    º Data ³  04/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Armazena os operadores relacionados a um grupo.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061AdOper( cGrupo )

Local cAntAlias		:= Alias()		// Salva o Alias que esta sendo utilizado
Local aReturn		:= {} 			// Retorno da funcao Array com operadores.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os operadores para a selecao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SU7" )
DbSetOrder( 1 )
DbSeek( xFilial( "SU7" ) )
While ( !Eof() )
   	If Alltrim( cGrupo ) == SU7->U7_POSTO .AND. SU7->U7_VALIDO == "1"
  		Aadd(aReturn,SU7->U7_COD) 
	Endif	
	DbSkip()
End

DbSelectArea( cAntAlias )
Return( aReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061VldAuto  º Vendas Clientes            º Data ³ 30/03/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica o acols informado pela rotina automatica    	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                          	               	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061VldAuto(	nOpc		,aLista		,cSelOper	,cAssunto,;
								cMensagem	,cAttach	,aAttach	,cFiltro) 

Local lRet 	   := .F.
Local nFor 	   := 0
Local cContato := ""
Local cFilEnt  := ""
Local cEntida  := ""
Local cCodEnt  := ""
Local lGrvCab  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o contato ja esta em alguma lista de pendencia.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nFor :=1 TO Len(aAutoItens)
	
	cContato := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] == "U6_CONTATO"}  )][2])
	cFilEnt  := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] == "U6_FILENT "}  )][2])
	cEntida  := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] == "U6_ENTIDA "}  )][2])
	cCodEnt  := (aAutoItens[nFor][ASCAN(aAutoItens[nFor],{|z| z[1] == "U6_CODENT "}  )][2])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida Codigo do Contato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Tk061OutraLista(cContato)
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Percorre o cadastro de contatos :                    ³
	//³1) Se nao tiver o telefone selecionado gravado SKIP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU5")
	DbSetOrder(1)
	If DbSeek(xFilial("SU5")+cContato)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o tipo de telefone para contato.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case (M->U4_FORMA == "1")   	//Voz
				
				If M->U4_TIPOTEL == "1" 	// Residencial
					cTel := SU5->U5_FONE
					
				ElseIf M->U4_TIPOTEL == "2" // Celular
					cTel := SU5->U5_CELULAR
					
				ElseIf M->U4_TIPOTEL == "3" // Fax
					cTel := SU5->U5_FAX
					
				ElseIf M->U4_TIPOTEL == "4" // Comercial 1
					cTel := SU5->U5_FCOM1
					
				ElseIf M->U4_TIPOTEL == "5" // Comercial 2
					cTel := SU5->U5_FCOM2
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o tipo de telefone para a geracao da lista nao³
				//³existir no contato, passa para o proximo contato.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cTel)
					Loop
				Endif
				
			Case (M->U4_FORMA == "2")   //Fax
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o contato nao possuir numero de fax passa para o proximo contato.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(SU5->U5_FAX)
					Loop
				Endif
				
				
			Case (M->U4_FORMA == "3")  //Cross-Posting
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o contato nao possuir e-mail passa para o proximo contato.       ³
				//³Ou se o contato não autorizar a interação via e-mail.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If Empty(SU5->U5_EMAIL) .OR. (SU5->U5_AUTORIZ <> "1")// SIM
					Loop
				Endif
				
			Case (M->U4_FORMA == "4")  //Mala-Direta

				If M->U4_TIPOEND == "1" // Residencial 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o contato nao possuir endereco passa para o proximo contato.     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(SU5->U5_END)
						Loop
					Endif

				ElseIf M->U4_TIPOEND == "2" //Comercial
					DbSelectArea( cEntida )
					DbSetOrder(1)
					If DbSeek(xFilial(cEntida) + Alltrim(cCodEnt))
						If Empty( TkEntidade(cEntida,Alltrim(cCodEnt),2) )
							Loop
						Endif
					Endif
				Endif

		Endcase
	Endif
	
	
	AAdd(aLista,{	xFilial("SU6"),;			    // Filial
					M->U4_LISTA,;       			// Lista
					GetSxeNum("SU6","U6_CODIGO"),;  // Codigo
					cFilEnt,;  						// Filial da Entidade
					cEntida,;  						// Chave da entidade
					cCodEnt,;						// Codigo da Entidade
					"1",;							// Origem da Interacao
					cContato,;  					// Codigo do Contato
					M->U4_DATA,;					// Data
					CriaVar("U6_HRINI",.T.),; 		// Hora Inicial
					CriaVar("U6_HRFIM",.T.),; 		// Hora Final
					"1"})					  		// Status da Interacao
					
	ConfirmSx8()
	lRet:= Tk061Grava(	nOpc		,aLista		,@cAssunto	,@cMensagem	,;
						@cAttach	,@aAttach	,@cFiltro	,cSelOper	,;
						@lGrvCab	,-1			)
Next nFor

CursorArrow()

Return (lRet)




//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk061HasBlock()
Avalia se um contato possui telefone bloqueado
@param cCodCont	código do contato a ser avaliado
@param cType	1 = Telefone / 2 = email
@return lRet .T. -> possui bloqueio / .F. -> não possui bloqueio
@author Vendas CRM
@since 29/12/2013
/*/
//------------------------------------------------------------------------------------------------
Function Tk061HasBlock(cCodCont, cType)

	Local lRet := .F.
	Local aArea := GetArea()
	Local aAreaAGB := AGB->(GetArea())
	Local aAreaAIK := AIK->(GetArea())
	Local nX := 0
	Local aTelefone := {}

	Default cType := 1
	//-----------------------------------------------------
	// Procura telefones do contato e monta uma lista
	//-----------------------------------------------------
	If cType == 1 //Telefone
		
		DbSelectArea("AGB")
		AGB->(DbSetOrder(4))	//AGB_FILIAL, AGB_ENTIDA, AGB_CODENT, AGB_DDD, AGB_TELEFO 
		If AGB->(DbSeek(xFilial("AGB")+"SU5"+PadR(cCodCont,Len(AGB->AGB_CODENT))))
			While AGB->(!EOF()) .AND. AGB->AGB_FILIAL == xFilial("AGB") .AND. AGB->AGB_ENTIDA == "SU5" .AND. AllTrim(AGB->AGB_CODENT) == cCodCont
				Aadd(aTelefone,{AllTrim(AGB->AGB_DDD)+AllTrim(AGB->AGB_TELEFO)})
				AGB->(DbSkip())
			EndDo
		EndIf
		
		//-------------------------------------------------------
		// Verifica se algum telefone do contato está bloqueado
		//-------------------------------------------------------
		DbSelectArea("AIK")
		AIK->(DbSetOrder(2))	//AIK_FILIAL, AIK_TEL, AIK_STATUS, AIK_ENTIDA, AIK_CODENT
		For nX := 1 To Len(aTelefone)
				If AIK->(DbSeek(xFilial("AIK")+PadR(aTelefone[nX,1],Len(AIK->AIK_TEL))+"1"))
					lRet := .T. //define que existe bloqueio para o contato
					Exit
				EndIf
		Next nX
	
	ElseIf cType == 2 //Email
		
		DbSelectArea("AIK")
		AIK->(DbSetOrder(3))	//AIK_FILIAL, AIK_EMAIL, AIK_STATUS
		If AIK->(DbSeek(xFilial("AIK")+PadR( Posicione("SU5",1,xFilial("SU5")+cCodCont,"U5_EMAIL") , Len(AIK->AIK_EMAIL) )+"1"))
			lRet := .T. //define que existe bloqueio para o contato
		EndIf		

	EndIf	
		
		
		
	AIK->(RestArea(aAreaAIK))
	AGB->(RestArea(aAreaAGB))
	RestArea(aArea)		
Return lRet	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk061BAU   ³ Autor ³ Plano de Saude        ³ Data ³ 05/02/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a selecao dos parametros para a BAU                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Lista de Contato                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061BAU(ceMv_par01,ceMv_par02,ceMv_par03,ceMv_par04,ceMv_par05,ceMv_par06)

Local lRet 	:= .F. 	// Se o retorno for TRUE grava, senao avanca o registro do AC8
Local aArea	:= {}   // Salva a area atual

If (Alias() <> "TRB")
	aArea:= GetArea()
Endif

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TMK063                         ³
  ³                               ³
  ³Mv_Par01  RDA de    			1 ³
  ³Mv_Par02  RDA ate   			2 ³
  ³Mv_Par03  Classe RDA de   	3 ³
  ³Mv_Par04  Classe RDA ate   	4 ³
  ³Mv_Par05  Data de           	5 ³
  ³Mv_Par06  Data ate           6³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/  

DbSelectArea("BAU")
DbSetOrder(1) 
If DbSeek( xFilial("BAU") + AllTrim(AC8->AC8_CODENT) ) 
	
	While 	BAU->((!Eof()).AND. xFilial("BAU") == BAU->BAU_FILIAL) 
   		
   		If 	((BAU->BAU_CODIGO >= ceMv_Par01)	.OR. Empty(ceMv_Par01)) .AND.;
			((BAU->BAU_CODIGO <= ceMv_Par02) .OR. Empty(ceMv_Par02)) .AND.;
			((BAU->BAU_TIPPRE >= ceMv_Par03) 	.OR. Empty(ceMv_Par03)) .AND.;
			((BAU->BAU_TIPPRE <= ceMv_Par04) 	.OR. Empty(ceMv_Par04)) .AND.;
			((BAU->BAU_DTINCL <= ceMv_Par05) 	.OR. Empty(ceMv_Par05)) .AND.;
			((BAU->BAU_DTINCL <= ceMv_Par06) 	.OR. Empty(ceMv_Par06))
				lRet:= .T. 
				Exit						
		Endif
   		BAU->(DbSkip())
	End
Endif

If Len(aArea) > 0
	RestArea(aArea)
Endif

Return(lRet)

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
