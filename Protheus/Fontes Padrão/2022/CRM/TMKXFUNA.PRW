#INCLUDE "TMKXFUNA.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TMKDEF.CH"

Static _cTipoAte		:= ""								// Controla qual a rotina de atendimento o Operador tem acesso
Static _lTMKCON		:= ExistBlock("TMKCON")		// P.E. para Televendas
Static _lTMKMCO		:= ExistBlock("TMKMCO")		// P.E. para Telemaketing	
Static _lTK271TpCl	:= FindFunction("P_TK271TCL")
Static _lTKTipCli		:= ExistBlock("TKTIPCLI")	//Ponto de entrada que permita customizar gravação do tipo decliente no pedido de vendas.
Static _lTkFilCont	:= ExistBlock("TKFILCONT")		//Ponto de entrada para filtrar os contatos
Static _lTmkMCA		:= ExistBlock("TMKMCA")		// P.E. TMK
Static _lTmkVCAT		:= FindFunction("T_TMKVCA")		// P.E. TLV - Para uso exclusivo de Templates
Static _lTmkVCA	  	:= ExistBlock("TMKVCA")		// P.E. TLV

/*/                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TmkOperador ³ Autor ³ Vendas Clientes    ³ Data ³ 28/07/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fun‡ao para verificar se o USUARIO:                        ³±±
±±³          ³ 1) Tem um OPERADOR identico no cadastro de Operadores e se ³±±
±±³          ³ ele e VALIDO - Check pelo Nome e depois pelo Codigo        ³±±
±±³          ³                                                            ³±±
±±³          ³ 2) Atualiza o tipo de atendimento que o Operador tem acesso³±±
±±³          ³ 1-Telemarketing,2-Televendas,3-Telecobranca,4-Todos,       ³±±
±±³          ³ 5-Tmk x Tlv                                                ³±±
±±³          ³                                                            ³±±
±±³          ³ 3) Veririca se o Operador associado tem um Grupo de        ³±±
±±³          ³ Atendimento valido                                         ³±±
±±³          ³                                                            ³±±
±±³          ³ 4) Verifica se ele e SUPERVISOR na solicitacao de parametro³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TmkOperador(lSuper,cCod,lVisFilDif)

Local aSavArea 	:= GetArea()		// Salva a area atual
Local lRet 		:= .F.				// Retorno da funcao
Local lFind 	:= .F.	            // Flag para Seek no SU7 com UPPER e sem UPPER
Local cGrupo 	:= ""				// Grupo de atendimento do Operador
Local lFilSU7	:= .F.				// Flag para verificar se a tabela SU7 está exclusisa
Local lFilSU0 	:= .F.				// Flag para verificar se a tabela SU0 está exclusisa
Local cFilLog	:= FWCodFil()		// Filial que o operador se logou
Local cFilSU7	:= xFilial("SU7")

DEFAULT lSuper	:= .F.				// Verifica se o operador e um SUPERVISOR ou nao
DEFAULT cCod  	:= __cUserId		// Codigo do usuario logado
DEFAULT lVisFilDif := .F.			// Visualiza chamamdos de filiais diferentes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validação para permitir o operador visualizar um chamado de outra filial.	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisFilDif
	If FWModeAccess("SU7",3) == "E" .AND. cFilSU7 <> cFilLog
		lFilSU7 := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o usuario no cadastro de operadores					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU7")
DbSetOrder(4)
If DbSeek( IIf(!lFilSU7, cFilSU7, cFilLog) + cCod ) // Nome completo
	lFind := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o codigo de usuario esta associado no SU7 para o respectivo Operador³
//³e se o operador e VALIDO.				              						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFind 
	If Empty(SU7->U7_CODUSU) .OR. VAL(SU7->U7_VALIDO) <> VALIDO 
		lFind	:= .F.
		lRet	:= .F.
	Endif
Endif			

If lFind 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A atualizacao da variavel _cTipoAte esta sendo feita nesse	  ³
	//³momento para ser utilizada na funcao TkGetTipoAte()            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cTipoAte := SU7->U7_TIPOATE
	cGrupo	  := SU7->U7_POSTO	

	If !Empty(_cTipoAte) .AND. !Empty(cGrupo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o grupo de atendimento esta cadastrado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cGrupo)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validação para permitir o operador visualizar um chamado de outra filial.	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVisFilDif
				If ( FWModeAccess("SU0",3) == "E" ) .And. ( xFilial("SU0") <> cFilLog )
					lFilSU0 := .T.
				EndIf			
			EndIf
			DbSelectArea("SU0")
			DbSetOrder(1)
			If DbSeek(IIf(!lFilSU0,xFilial("SU0"),cFilLog)+SU7->U7_POSTO)
		        lRet := .T.    

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se foi solicitado avaliar se o operador tambem e um SUPERVISOR³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lSuper
				   If VAL(SU7->U7_TIPO) == SUPERVISOR
				      lRet := .T.
				   Else
				      lRet := .F.
				   Endif
		        Endif
		    Endif
		Endif        
	Endif
Endif

RestArea(aSavArea)

Return(lRet)
      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkGetTipoAte³ Autor ³ Vendas Clientes    	³ Data ³ 29/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Devolve o tipo de rotina que o operador tem acesso          ³±±
±±³          ³ 1 - TeleMarketing                                          ³±±
±±³          ³ 2 - TeleVendas                                             ³±±
±±³          ³ 3 - TeleCobranca                                           ³±±
±±³          ³ 4 - Tmk x Tlv                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³cExp1 = Codigo de retorno da funcao						  ³±±
±±³          ³Exemplo: TkGetTipoAte("1") Retorno: 1 = Telemarketing  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CALL CENTER										          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkGetTipoAte(cTipo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o parametro cTipo contiver a rotina a ser executada, ignora  a atualizacao da variavel _cTipoAte ³
//³e assume a atendimento solicitado pela variavel.														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == NIL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando a variavel _cTipoAte esta vazia, executa a funcao TmkOperador() para atualizar o seu conteudo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(Trim(_cTipoAte))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao localizou o Operador no Cadastro (SU7) assume a rotina de TELEVENDAS como retorno³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !TmkOperador()	
			Return("2")
		Endif	
	Endif

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Devolve como retorno o proprio parametro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cTipoAte := cTipo
Endif

Return(_cTipoAte)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TmkOK 	³ Autor ³ Vendas Clientes    	³ Data ³ 08/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mensagem de confirma‡„o com retorno .T. ou .F.    	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TmkA010											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TmkOK(cMsg)

Return(MsgYesNo(cMsg,STR0002)) //"Aten‡„o"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkAtuCon   ³ Autor ³ Vendas Clientes     ³ Data ³ 08/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra a observa‡ao de cada produto concorrente            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³CALL CENTER   			 								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkAtuCon(cProduto, oCon, aCon, cObsCon, oObsCon)
Local nTamObs := GetSX3Cache("U2_OBS","X3_TAMANHO")		// Recebe o tamanho do campo cadastrado no SX3 (Dicionário de dados)

DbSelectArea("SU2")
DbSetOrder(1)
If DbSeek(xFilial("SU2")+cProduto+aCon[oCon:nAt][1])
	cObsCon := ""
	cObsCon := MSMM(SU2->U2_CODOBS,nTamObs)
	oObsCon:Refresh()
	DbSkip()
Endif
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkContatos    ³ Autor ³Vendas Clientes        ³ Data ³ 09/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra os Contatos do cliente selecinado 			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TkContatos(ExpN1, ExpL2, ExpL3)    		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = nFolder (Numero da pasta usada no CallCenter para utili³±±
±±³          ³         a rotina no loja o folder tem que ser 12)			  ³±±
±±³          ³ ExpL2 = .T. se a Entidade e um prospect ou .F. se dor Cliente  ³±±
±±³          ³ ExpL3 = .T. Considera o parametro MV_LJF3CNT para definir o    ³±±
±±³          ³ tipo de exibicao da consulta. ou .F. Nao considera o Parametro ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³Sigatmk - Com fun‡”es do TeleMarketing     				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkContatos(lModLoja, lProspLj, lMVTpCons)
Local oLbx							 					//Listbox com os nomes dos contatos
Local aCont			:= {}									//Array com os contatos
Local cDFuncao		:= CRIAVAR("U5_FUNCAO",.F.)				//Funcao do contato na empresa	
Local cCliente		:= ""									//Codigo do cliente
Local cLoja			:= ""									//Loja do cliente
Local cDesc			:= ""									//Decricao do cliente
Local cEntidade		:= ""									//Alias da entidade
Local nOpcao		:= 0									//Opcao 
Local nContato		:= 0									//Posicao do contato dentro do array na selecao
Local oDlg												//Tela
Local lRet			:= .F.									//Retorno da tela
Local cMVTpCons		:= SuperGetMv("MV_LJF3CNT", NIL, "1")	//Parametro que define o Tipo de consulta 1- Padrao Call Center 2- Por Endereco
Local nFoldLoc											//Folder 1-Telemarketing, Televendas ou Telecobranca, 2-Televendas, 3-Telecobranca, 12-Sigaloja
Local lProspLoc											//Determina se e Prospect
Local lFilSU5		:= .T.
Local cFilAC8		:= ''
Local cFilSU5 		:= ''
Local cFilSUM		:= ''
Local cTipoAte		:= ""
Local aPDCols 		:= {}
Local aPDFields		:= {"U5_CONTAT","U5_END","U5_FONE"}

//Seta defaults das variaveis passadas pela funcao
DEFAULT lModLoja	:= .F.
DEFAULT lProspLj	:= .F.
DEFAULT lMVTpCons	:= .F.

If lModLoja
	nFoldLoc	:= 12
	lProspLoc	:= lProspLj 
ElseIf (FunName() == "TMKA280")			//Rotina do Pré-Atendimento
	nFoldLoc	:= 3       				//Telecobranca
	lProspLoc	:= .F.
Else
	If Type("nFolder") <> "U"
		nFoldLoc	:= nFolder		//Variavel Private do Call Center
 		lProspLoc	:= lProspect	//Variavel Private do Call Center
	Else 
	   cEntidade := Substr(__ReadVar,1,3)
	   lProspect := .F.
		If cEntidade == "SUC"
			nFoldLoc := 1
		Endif
		If cEntidade == "SUA"
			nFoldLoc := 2 
			lProspect :=  M->UA_PROSPEC
		Endif
		If cEntidade == "ACF"
			nFoldLoc := 3
		Endif
	Endif
EndIf

If lProspLoc
	cEntidade := "SUS"
Else
	cEntidade := "SA1"
EndIf
		
If nFoldLoc == 1 // TeleMarketing, Televendas ou Telecobranca
	cTipoAte	:= TkGetTipoAte()
	If cTipoAte == "2" //Televendas
		cCliente := M->UA_CLIENTE
		cLoja    := M->UA_LOJA
		cDesc    := M->UA_DESCCLI
		
	Elseif cTipoAte == "3" //Telecobranca
		cCliente := M->ACF_CLIENT
		cLoja    := M->ACF_LOJA
		cDesc    := M->ACF_DESC
	Endif
	
ElseIf nFoldLoc == 2 // Televendas
		If cEntidade == "SUS"
			cCliente := M->UA_CLIENTE
			cLoja    := M->UA_LOJA
			cDesc    := Posicione("SUS",1,xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA,"US_NREDUZ")	
		Else
			cCliente := M->UA_CLIENTE
			cLoja    := M->UA_LOJA
			cDesc    := Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_NREDUZ")	
		EndIf	
ElseIf nFoldLoc == 3 // Telecobranca
	cCliente:= M->ACF_CLIENT
	cLoja   := M->ACF_LOJA
	cDesc   := Posicione("SA1",1,xFilial("SA1")+M->ACF_CLIENT+M->ACF_LOJA,"A1_NREDUZ")

ElseIf nFoldLoc == 12 // Para Uso da rotina na venda assistida (LOJA701)
	cCliente:= M->LQ_CLIENTE
	cLoja   := M->LQ_LOJA
	cDesc   := Posicione("SA1",1,xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA,"A1_NREDUZ")

Endif

If Empty(cCliente)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif

cFilSU5	:= xFilial("SU5")
cFilAC8	:= xFilial("AC8")
cFilSUM	:= xFilial("SUM")

DbSelectArea("AC8")
DbSetOrder(2)		//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON

If DbSeek(cFilAC8 + cEntidade + xFilial(cEntidade) + cCliente + cLoja) 

	While (!Eof())										.AND.;
		  (AC8->AC8_FILIAL == cFilAC8)		 			.AND.;
		  (AC8->AC8_ENTIDA == cEntidade)			 	.AND.;
		  (AC8->AC8_FILENT == xFilial(cEntidade)) 		.AND.;
		  (AllTrim(AC8->AC8_CODENT) == AllTrim(cCliente + cLoja))
		
		DbSelectArea("SU5")
		DbSetOrder(1)
		If DbSeek(cFilSU5 + AC8->AC8_CODCON)
			
			If _lTkFilCont
				lFilSU5 := ExecBlock("TKFILCONT",.F.,.F.)	
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se considerar o parametro, MV_LJF3CNT  ³
			//³e o tipo de consulta for por endereço  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMVTpCons .AND. cMVTpCons = "2" .AND. lFilSU5
				cDFuncao := Posicione("SUM",1,cFilSUM+SU5->U5_FUNCAO,"UM_DESC")
	
				Aadd(aCont, {	SU5->U5_CODCONT,;		//C¢digo
								SU5->U5_END,;			//Endereco
								SU5->U5_BAIRRO,;		//Bairro
								SU5->U5_MUN,;			//Municipio
								SU5->U5_EST,;			//Estado
								SU5->U5_CEP,;			//CEP
								SU5->U5_CONTAT;			//Nome 
								} )
   			//Padrao CallCenter
   			ElseIf lFilSU5
				cDFuncao := Posicione("SUM",1,cFilSUM+SU5->U5_FUNCAO,"UM_DESC")
	
				Aadd(aCont, {	SU5->U5_CODCONT,;		//C¢digo
								SU5->U5_CONTAT,;		//Nome 
								cDFuncao,;				//Fun‡„o
								SU5->U5_FONE,;			//Telefone
								SU5->U5_OBS;			//Observacao
								} )
            EndIf

		Else
			Aadd(aCont,{"","","","",""})
		Endif
		DbSelectArea("AC8")
		DbSkip()
	EndDo
Else
	If TkIncCt(@oLbx,@aCont,.T.,cEntidade,cCliente,cLoja,cDesc,nFoldLoc,lProspLoc,lMVTpCons ) == 3 // Cancelou a Inclusao
		Return(lRet)
	Else 
		lRet := .T.	
		Return(lRet)
	Endif
Endif

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
SaveInter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados dos Contatos 								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM  48,171 TO 230,800 TITLE STR0005 + " - " + cDesc PIXEL //"Cadastro de Contatos" 
	
	@  3,2 TO  73, 310 LABEL STR0005+":" OF oDlg  PIXEL //"Cadastro de Contatos" 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se considerar o parametro, MV_LJF3CNT  ³
	//³e o tipo de consulta for por endereço  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMVTpCons .AND. cMVTpCons = "2"

		@ 10,5	LISTBOX oLbx FIELDS ;
				HEADER ;
				STR0069,; //"C¢digo"
				STR0070,; //"Endereco" 
				STR0071,; //"Bairro"
				STR0072,; //"Municipio"
				STR0073,; //"Estado" 
				STR0074,; //"CEP"
				STR0007;  //"Nome"
				SIZE 303,60  NOSCROLL OF oDlg PIXEL ;
				ON DBLCLICK( nOpcao:= 1,nContato := oLbx:nAt,oDlg:End() )
		
				oLbx:SetArray(aCont)
				oLbx:bLine:={ || {	aCont[oLbx:nAt,1],;	//C¢digo
									aCont[oLbx:nAt,2],;	//Endereco
									aCont[oLbx:nAt,3],;	//Bairro
									aCont[oLbx:nAt,4],;	//Municipio
									aCont[oLbx:nAt,5],;	//Estado
									aCont[oLbx:nAt,6],;	//CEP
									aCont[oLbx:nAt,7];	//Nome
									}}

				aPDCols := {"","U5_END","","","","","U5_CONTAT "}

				If FATPDActive() .And. FTPDUse(.T.)
					oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
				EndIf

	//Padrao CallCenter	
	Else
		@ 10,5	LISTBOX oLbx FIELDS ;
				HEADER ;
				STR0006,; //"C¢digo"
				STR0007,; //"Nome", 
				STR0008,; //"Fun‡„o"
				STR0009,; //"Telefone" 
				STR0010;  //"Observa‡„o" 
				SIZE 303,60  NOSCROLL OF oDlg PIXEL ;
				ON DBLCLICK( nOpcao:= 1,nContato := oLbx:nAt,oDlg:End() )
		
				oLbx:SetArray(aCont)
				oLbx:bLine:={ || {	aCont[oLbx:nAt,1],;	//C¢digo
									aCont[oLbx:nAt,2],;	//Nome 
									aCont[oLbx:nAt,3],;	//Fun‡„o
									aCont[oLbx:nAt,4],;	//Telefone
									aCont[oLbx:nAt,5];	//Observacao
									}}

				aPDCols := {"","U5_CONTAT","","U5_FONE",""}

				If FATPDActive() .And. FTPDUse(.T.)
					oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
				EndIf
				
	EndIf
	
	DEFINE SBUTTON FROM 74,162 TYPE 4	ENABLE OF oDlg ACTION TkIncCt(	@oLbx	, @aCont	, .F.	, cEntidade	,;
																		cCliente, cLoja		, cDesc, nFoldLoc,;
																		lProspLoc, lMVTpCons )
	DEFINE SBUTTON FROM 74,192 TYPE 11	ENABLE OF oDlg ACTION TkAltCt(@oLbx,1,@aCont,cCliente,cLoja, lProspLoc)
	DEFINE SBUTTON FROM 74,222 TYPE 15	ENABLE OF oDlg ACTION TkVisCt(oLbx,1,@aCont,cCliente,cLoja)
	
	DEFINE SBUTTON FROM 74,252 TYPE 1	ENABLE OF oDlg ACTION (nOpcao:= 1,nContato:= oLbx:nAt,oDlg:End())
	DEFINE SBUTTON FROM 74,282 TYPE 2	ENABLE OF oDlg ACTION (nOpcao:= 0,oDlg:End())

	FATPDLogUser("TKCONTATOS")      
ACTIVATE MSDIALOG oDlg CENTERED 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no registro correto para ser atualizado o campo de codigo do contato.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU5")
DbSetOrder(1)
If (nOpcao == 1)
	lRet := .T.
	DbSeek(cFilSU5 + aCont[nContato,1])
Endif
RestInter()
FATPDUnload()
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkIncCt	³ Autor ³ Vendas Clientes  		³ Data ³11/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Inclusao de novos contatos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkIncCt(oLbx	, aCont	, lNovo	, cEntidade	,;
						cCliente, cLoja	, cDesc, nFolder,;
						lProspect, lMVTpCons	)

Local aArea   		:= GetArea()							// Salva a area atual
Local nOpca     	:= 0									// Opcao de OK ou CANCELA
Local cDFuncao  	:= CRIAVAR("U5_FUNCAO",.F.)		  		// Cargo da funcao do contato
Local cAlias    	:= IIf(lProspect,"SUS","SA1")			// Alias 
Local lIncluiAnt	:= INCLUI                          		// Guarda o conteudo da variavel para restaurar apos a inclusao do contato
Local lModLoja		:= nFolder == 12						// Verifica se foi chamado pela Venda Assistida
Local lFilSU5		:= .T.
Local cFilAC8		:= ''
Local cFilAlias		:= ''
Local cFilSU5		:= ''
Local cFilSUM		:= ''

DEFAULT lProspect := .F.
DEFAULT lMVTpCons := .F.

Private cCadastro 	:= STR0011			 					// "Inclus„o de Contatos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na Inclusao, a variavel INCLUI devera estar como .T.  para executar  o inicializador ³
//³padrao de alguns campos que sao preenchidos somente se a variavel estiver .T. 		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
INCLUI:= .T.

DbSelectArea("SU5")
nOpcA := A70INCLUI("SU5",0,3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restauva a variavel com o conteudo original³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
INCLUI	:= lIncluiAnt
cFilAC8 := xFilial("AC8")
If (nOpca == 1)
	DbSelectArea("AC8")
	RecLock("AC8",.T.)
	REPLACE AC8_FILIAL With cFilAC8
	REPLACE AC8_FILENT With xFilial(cEntidade)
	REPLACE AC8_ENTIDA With cEntidade
	REPLACE AC8_CODENT With cCliente + cLoja
	REPLACE AC8_CODCON With SU5->U5_CODCONT
	MsUnLock()
	DbCommit()
Endif

// Se houve inclusao do registro atualizo o listbox de contatos
If nOpcA == 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se esse ‚ o primeiro contato a ser cadastrado fecho a ³
	//³tela e abro novamente para a cria‡„o do objeto listbox³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNovo
		TkContatos(lModLoja, lProspect, lMVTpCons)
		Return(nOpcA)
	Endif
	
	aCont := {}
	
	cFilAlias	:= xFilial(cAlias)
	cFilSU5		:= xFilial("SU5")
	cFilSUM		:= xFilial("SUM")
	
	DbSelectArea("AC8")
	DbSetOrder(2)
	If DbSeek(xFilial("AC8") + cAlias + cFilAlias + cCliente + cLoja,.T.)

		While (!Eof()) 							.AND.;
			  (AC8->AC8_FILIAL == cFilAC8	)	.AND.;
			  (AC8->AC8_ENTIDA == cAlias	) 	.AND.;
			  (AC8->AC8_FILENT == cFilAlias	) 	.AND. ;
			  (AllTrim(AC8->AC8_CODENT) == AllTrim(cCliente + cLoja))
		
			DbSelectArea("SU5")
			DbSetOrder(1)
			If DbSeek( cFilSU5 + AC8->AC8_CODCON)
				If _lTkFilCont
					lFilSU5 := ExecBlock("TKFILCONT",.F.,.F.)	
				EndIf
                
				If lFilSU5
					cDFuncao := Posicione("SUM",1,cFilSUM+SU5->U5_FUNCAO,"UM_DESC")
	
					Aadd(aCont,{SU5->U5_CODCONT,;		//C¢digo
								SU5->U5_CONTAT,;		//Nome 
								cDFuncao,;				//Fun‡„o
								SU5->U5_FONE,;			//Telefone
								SU5->U5_OBS} )			//Observacao
				EndIf
			Else
				Aadd(aCont,{"","","","",""})
			Endif
		
			DbSelectArea("AC8")
			DbSkip()
		End
	Endif	
		
	oLbx:SetArray(aCont)
	oLbx:nAt:= Len(aCont)
	oLbx:bLine:={||{aCont[oLbx:nAt,1],;  //C¢digo
					aCont[oLbx:nAt,2],;  //Nome 
					aCont[oLbx:nAt,3],;	 //Fun‡„o
					aCont[oLbx:nAt,4],;	 //Telefone
					aCont[oLbx:nAt,5] }} //Observacao
	oLbx:Refresh()
Endif

RestArea(aArea)
Return(nOpcA)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkAltCt	³ Autor ³ Vendas Clientes  		³ Data ³12/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Altera‡ao de contatos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkAltCt(oLbx	, nPos	, aCont	, cCliente	,;
						cLoja, lProspect )

Local aArea		  := GetArea()						// Salva a area atual
Local cCod	      := ""								// Codigo do contato	
Local cDFuncao    := ""								// Cargo do contato
Local cAlias	  := If(lProspect,"SUS","SA1")		// Alias 
Local nOpcA       := 0								// Opcao de retorno OK ou CANCELA
Local aRots       := aClone(aRotina)                // Copia do array aRotina 
Local lRet		  := .T.							// Retorno da funcao
Local lFilSU5	  := .T.
Local cFilSU5	  := ''
Local cFilAC8	  := ''
Local cFilAlias	  := ''
	
DEFAULT lProspect := .F.

Private cCadastro := STR0012						// "Altera‡„o de Contatos" 	//Private para compatibilizacao com a funcao AXaltera
Private lRefresh  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 82 (ACS), verifica se o usu rio poder  ou n„o alterar cadastros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkPsw(82)
	HELP(" ",1,"TMKACECAD")
	lRet := .F.	
	Return(lRet)
Endif

cCod := Eval(oLbx:bLine)[nPos]

cFilSU5 := xFilial("SU5")

DbSelectArea("SU5")
DbSetOrder(1)
If DbSeek(cFilSU5+ cCod)

	BEGIN TRANSACTION

		aRotina:={}	
		aRotina		:= MenuDef()

		If lRet
			nOpcA:=A70ALTERA("SU5",RECNO(),4)
		Endif

		aRotina:= aClone(aRots)	

	END TRANSACTION

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houve altera‡ao do registro atualizo o listbox de contatos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1
		lRet  		:= .T.
		aCont 		:= {}
		cFilAC8		:= xFilial("AC8")
		cFilAlias	:= xFilial(cAlias)
		cFilSUM		:= xFilial("SUM")
		
		DbSelectArea("AC8")
		DbSetOrder(2)
		
		If DbSeek(cFilAC8 + cAlias + cFilAlias + cCliente + cLoja,.T.)
			While (!Eof()) 							  	.AND.;
				  (AC8->AC8_FILIAL == cFilAC8	) 		.AND.;
				  (AC8->AC8_ENTIDA == cAlias	) 		.AND.;
				  (AC8->AC8_FILENT == cFilAlias	)		.AND.;
				  (AllTrim(AC8->AC8_CODENT) == AllTrim(cCliente + cLoja))
		
				DbSelectArea("SU5")
				DbSetOrder(1)
				If DbSeek(cFilSU5 + AC8->AC8_CODCON)
					If _lTkFilCont
						lFilSU5 := ExecBlock("TKFILCONT",.F.,.F.)	
					EndIf
	                
					If lFilSU5
						cDFuncao := Posicione("SUM",1,cFilSUM+SU5->U5_FUNCAO,"UM_DESC")
						Aadd(aCont,{SU5->U5_CODCONT,;		//C¢digo
									SU5->U5_CONTAT,;		//Nome 
									cDFuncao,;				//Fun‡„o
									SU5->U5_FONE,;			//Telefone
									SU5->U5_OBS} )			//Observacao
					EndIf
				Else
					Aadd(aCont,{"","","","",""})
				Endif
		
				DbSelectArea("AC8")
				DbSkip()
			End
		Endif	
		
		oLbx:SetArray(aCont)
		oLbx:bLine:={||{aCont[oLbx:nAt,1],;  //C¢digo
						aCont[oLbx:nAt,2],;  //Nome 
						aCont[oLbx:nAt,3],;	 //Fun‡„o
						aCont[oLbx:nAt,4],;	 //Telefone
						aCont[oLbx:nAt,5] }} //Observacao
		oLbx:Refresh()

	Endif
Endif

RestArea(aArea)

Return(lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³14/12/06  ³±±
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

Local aRotina:= {		{ STR0013  ,"AxPesqui"        ,0 ,1 , , .F. },; //"Pesquisar" 
						{ STR0014  ,"TK271CallCenter" ,0 ,2 , , .T. },; //Visualizar 
						{ STR0015  ,"TK271CallCenter" ,0 ,3 , , .T. },; //"Incluir" 
						{ STR0016  ,"TK271CallCenter" ,0 ,4 , , .T. }}  //"Alterar" 

Return(ARotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkVisCt	³ Autor ³ Vendas Clientes  		³ Data ³09/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Visualizacao de contatos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkVisCt(oLbx	, nPos	, aCont	, cCliente	,;
						cLoja	)
						
Local cAliasOld   := Alias()
Local cCod		  := ""
Private cCadastro := STR0017 //"Visualiza‡„o de Contatos" 

cCod := Eval(oLbx:bLine)[nPos]
DbSelectArea("SU5")
DbSetOrder(1)

If DbSeek(xFilial("SU5")+ cCod)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A70Visual("SU5",RECNO(), 2)
Endif

DbSelectArea(cAliasOld)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkPosto 	 ³ Autor ³Vendas Clientes       ³ Data ³12/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o conteudo do campo solicitado                      ³±±
±±³          ³                                                            ³±±
±±³          ³Observacao:                                                 ³±±
±±³          ³- O campo U0_PRECOF esta fora de uso a partir da 8.11       ³±±
±±³          ³quando o campo estiver "vazio" sera considerado o valor     ³±±
±±³          ³Default "2 - Nao" ou seja o valor unitario sera sempre      ³±±
±±³          ³recalculado                                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER 										          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Function TKPosto(cCodOper,cCampo)

Local xRet
Local aArea	:= GetArea()
Local cPosto	:= Space(Len(SU7->U7_POSTO))

// Procura pelo Operador para saber qual o Posto
SU7->(DbSetOrder(1))
If SU7->(MsSeek(xFilial("SU7") + cCodOper))
	cPosto	:= SU7->U7_POSTO
Else	 		
	cPosto	:= If(Empty(cPosto), SuperGetMV("MV_POSTO"), cPosto)
Endif

// Pega o campo do Posto de Venda que foi solicitado
If cCampo == "U7_ESTACAO"
	xRet := SU7->&(cCampo)
Else
	SU0->(DbSetOrder(1))
	If SU0->(MsSeek(xFilial("SU0") + cPosto))
		xRet := SU0->( &(cCampo) )
	EndIf
EndIf
// Valida o retorno para U0_PRECOF = "vazio"
If Trim(cCampo) == "U0_PRECOF" .AND. Empty(xRet)
	SU0->(DbSetOrder(1))
	If SU0->(MsSeek(xFilial("SU0") + cPosto))
		xRet := "2"  // Preco fiscal bruto = NAO - recalcula o valor unitario para descontos
	EndIf  
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o ambiente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
Return(xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TKCliente	  ³ Autor ³ Vendas Clientes       ³ Data ³24/07/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida‡„o do codigo do Cliente informado no Televendas e 	  ³±±
±±³			 ³Telecobranca												  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TkCliente(ExpC1,ExpC2,ExpO3,ExpO4)		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Entidade                                 ³±±
±±³          ³ ExpC2 = Codigo dos itens do Tmk                            ³±±
±±³          ³ ExpO3 = Opcao selecionada no Folder de Atendimento         ³±±
±±³          ³ ExpO4 = Caixa de dialogo quando existir integracao CTI     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso		 ³CALL CENTER 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkCliente(cEntidade,cChave,nOpc,oEnchAux, l380)

Local aArea		:= GetArea()	// Salva a area atual
Local nItem		:= 0			// Contador
Local nPAssunto 	:= 0			// Posicao do campo UD_ASSUNTO no ACOLS
Local nPDescAss 	:= 0			// Descricao do ASSUNTO no ACOLS
Local nPProd    	:= 0			// Posicao do campo PRODUTO no ACOLS
Local nPDescPro 	:= 0			// Descricao do PRODUTO no ACOLS
Local nPOcorren 	:= 0			// Posicao do campo UD_OCORREN no ACOLS
Local nPDescOco 	:= 0			// Descricao da OCORRENCIA no ACOLS
Local nPAcao    	:= 0			// Posicao do campo UD_CODSOL no ACOLS
Local nPDescAca 	:= 0			// Descricao da ACAO no ACOLS
Local nPCodOpe  	:= 0		    // Codigo do Responsavel
Local nPDescOpe 	:= 0			// Descricao do Responsavel
Local nPStatus  	:= 0 			// Status da ocorrencia
Local nPObs		:= 0 			// Posicao do campo UD_OBS no ACOLS
Local nPData		:= 0 			// Posicao do campo UD_DATA no ACOLS
Local nPDtExec	:= 0 			// Posicao do campo UD_DTEXEC no ACOLS
Local cTipo     	:= "" 			// Tipo do Cliente/Prospect
Local cConfTmk  	:= ""			// Configuracao TMK
Local cAlias    	:= ""			// Alias do Cliente/Prospect
Local cPesqCli  	:= ""			// Monta uma chave de pesquisa utilizada no telecobranca
Local cCodVend  	:= ""			// Codigo do vendedor do Prospect ou do Cliente 
Local lRet			:= .F.			// Retorno da funcao
Local lAtuEnch 	:= .T.			// Flag para atualizar a enchoice quando houver integracao com CTI
Local lLimpaAcols	:= .T.   		// Indica se o acols com os titulos sera limpo quando o cliente for informado
Local cRegNeg   	:= ""			// Codigo da Regra de Negociacao
Local nAux			:= 0 			// Contador auxiliar para o FOR
local lAchou		:= .F.			// Verifica se a funcao tk380Ok, ou seja, se o atendimento veio da agenda do operador
Local cNaturez	:= "" 			//Natureza financeira do Prospect/Cliente
Local cTipoAte	:= TkGetTipoAte()

Local cFilSUA		:= xFilial("SUA")
Local cFilSUF		:= xFilial("SUF")
Local cFilSUC		:= xFilial("SUC")
Local cFilSUE		:= xFilial("SUE") 
Local cFilSUH		:= xFilial("SUH")
Local cFilSUL		:= xFilial("SUL")
Local cFilSX5		:= xFilial("SX5")
Local cFilSB1		:= xFilial("SB1")
Local cFilSU9		:= xFilial("SU9")
Local cFIlSUQ		:= xFilial("SUQ")
Local cFilSU7		:= xFilial("SU7")
Local cFilSA1		:= xFilial("SA1")
Local cFilSUS		:= xFilial("SUS")
Local cFilSUZ		:= xFilial("SUZ")
Local cFilDA0		:= xFilial("DA0")
Local cFilSE4		:= xFilial("SE4")
Local cFilSA3		:= xFilial("SA3")
Local cFilSK2		:= xFilial("SK2")
Local cFilACF		:= xFilial("ACF")
Local lCliEntreg	:= SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0
Local aPDFields		:= {"U7_NOME","A1_NOME","US_NOME","U5_CONTAT"}
Local lFirst		:= .T.
Local cCodCli		:= ""
Local cLojCli		:= ""
Local cContrib		:= ""
Local nX			:= 0

Default nOpc		:= 3                            
Default l380		:= .F.			// Se a rotina de telemarketing está sendo executada da agenda do operador

FATPDLoad(Nil, Nil, aPDFields)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o parametro foi passado - somente sera valido quando houver integracao com CTI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oEnchAux == NIL
	lAtuEnch := .F.
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o atendimento for TeleMarketing ou Ambos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFolder == 1 .AND. cTipoAte $ "145" // 1 Folder com Atendimento = Telemarketing ou Ambos ou TmkXTlv
	DEFAULT cEntidade		:= M->UC_ENTIDAD
	DEFAULT cChave		:= M->UC_CHAVE

	nPAssunto := aPosicoes[1][2]		// Posicao do campo UD_ASSUNTO no ACOLS
	nPDescAss := aPosicoes[2][2]		// Descricao do ASSUNTO no ACOLS
	nPProd    := aPosicoes[3][2]		// Posicao do campo UD_PRODUTO no ACOLS
	nPDescPro := aPosicoes[4][2]		// Descricao do PRODUTO no ACOLS
	nPOcorren := aPosicoes[5][2]		// Posicao do campo UD_OCORREN no ACOLS
	nPDescOco := aPosicoes[6][2]		// Descricao da OCORRENCIA no ACOLS
	nPCodOpe  := aPosicoes[7][2]		// Codigo do Operador   
	nPDescOpe := aPosicoes[8][2]		// Nome do Operador     		
	nPAcao    := aPosicoes[10][2]		// Posicao do campo UD_CODSOL no ACOLS
	nPDescAca := aPosicoes[11][2]		// Descricao da ACAO no ACOLS
	nPObs  	  := aPosicoes[12][2] 		// Posicao do campo UD_OBS no ACOLS   
	nPStatus  := aPosicoes[13][2]		// Status do item
	nPData	  := aPosicoes[9][2]		// Data da acao
	nPDtExec  := aPosicoes[14][2]		// Data de execucao	
Else
	nPProd    := aPosicoes[1][2]		// Posicao do campo UB_PRODUTO no ACOLS
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as variaveis do rodape sempre³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLigacao  := ""
cOperador := ""
cOperacao := ""
cStatus   := ""
cProximo  := ""
cContHist := ""
cNomeHist := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1 Folder e Atendimento = Telemarketing, Ambos ou TMK/TLV ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFolder == 1 .AND. cTipoAte $ "145"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obriga a execucao dos gatilhos para o campo "Cliente"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAtuEnch
		oEnchAux:EnchExecTrig("UC_CLIENT")
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se foi executada da agenda do operador.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l380
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica também se a campanha está preenchida, se estiver³
		//³carrega a campanha preenchida.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SU4")
		If !Empty(SU4->U4_CODCAMP)
			M->UC_CODCAMP	:= SU4->U4_CODCAMP
			M->UC_DESCCAM	:= Posicione("SUZ",1,cFilSUZ + SU4->U4_CODCAMP,"UZ_DESC")
		EndIf		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se estiver com a configuração de tmk informada, o atendimento,³
		//³será preenchido com a configuração TMK.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SU4->U4_CONFIG)
			cConfTmk := SU4->U4_CONFIG
		Else
			cConfTmk := TkPosto(M->UC_OPERADO,"U0_CONFTMK") // Configuracao TMK
		EndIf
	Else
		cConfTmk := TkPosto(M->UC_OPERADO,"U0_CONFTMK") // Configuracao TMK	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Primeiro: Atualiza o rodape da tela com o ultimo atendimento realizado para o mesmo contato/entidade         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUC")
	DbSetOrder(5)   //UC_FILIAL+UC_ENTIDAD+UC_CHAVE+STR(UC_DIASDAT,8,0)+STR(UC_HORADAT,8,0)
	If DbSeek(cFilSUC + cEntidade + cChave) 
		cLigacao	:= DTOC(CTOD("01/01/45")-UC_DIASDAT)+" - "+Substr(SUC->UC_INICIO,1,5) //Visualizacao no rodape
		cOperador	:= Posicione("SU7",1, cFilSU7 + SUC->UC_OPERADO,"U7_NOME")
		
		If !Empty(SUC->UC_PENDENT)
			cProximo:= DTOC(SUC->UC_PENDENT)+" - "+SUC->UC_HRPEND // Visualizacao do rodape
		Endif
		
		If VAL(SUC->UC_STATUS) == PLANEJADA
			cStatus := STR0018 //"Planejada" 
		ElseIf VAL(SUC->UC_STATUS) == PENDENTE
			cStatus := STR0019 //"Pendente" 
		Else
			cStatus := STR0020 //"Encerrada" 
		Endif
		
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Terceiro:Carrega os campos da configuracao de TMK do posto de venda do operador - Somente TMK	  ³
	//³e somente para as operacoes de INCLUSAO              											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cConfTmk) .AND. (nOpc == 3) .AND. (!Empty(cEntidade))
		DbSelectArea("SUE")
		DbSetOrder(1)
		If DbSeek(cFilSUE + cConfTmk)
			
			// Operacao
			M->UC_OPERACA	:= SUE->UE_OPERACA
			
			// Status
			M->UC_STATUS	:= SUE->UE_STATUS
			
			// Midia
			M->UC_MIDIA	:= SUE->UE_MIDIA
			M->UC_DESCMID	:= Posicione("SUH",1,cFilSUH + SUE->UE_MIDIA,"UH_DESC")
			
			//Tipo de comunicacao
			M->UC_TIPO		:= SUE->UE_TIPO
			M->UC_DESCTIP	:= Posicione("SUL",1,cFilSUL + SUE->UE_TIPO,"UL_DESC")
			
			//Campanha
			M->UC_CODCAMP	:= SUE->UE_CODCAMP
			M->UC_DESCCAM	:= Posicione("SUZ",1,xFilial("SUZ") + SUE->UE_CODCAMP,"UZ_DESC")
			
			//Observacao
			M->UC_OBS		:= MSMM(SUE->UE_CODOBS,60)

			DbSelectArea("SUF")
			DbSetOrder(1)
			If DbSeek(cFilSUF + SUE->UE_CODIGO)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa o aCols³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols := {}
				
				While	( !Eof() ) 							.AND.;
					 	(SUF->UF_FILIAL == cFilSUF )	.AND.;
					 	(SUF->UF_CODIGO == SUE->UE_CODIGO)
					nItem++
					
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Insere um nova linha no aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AAdd(aCols, Array( Len(aHeader) + 1) )
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inicializa os campos do aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nAux := Len(aCols) To Len(aHeader)
						If IsHeadRec(aHeader[nAux,2])      
							aCols[Len(aCols)][nAux] := 0			              	
						ElseIf IsHeadAlias(aHeader[nAux,2])																
							aCols[Len(aCols)][nAux] := "SUD"		
					   	ElseIf lFirst
						 	aCols[Len(aCols)][nAux] := aSvFolder[1][2][1][1]	
						Else
							aCols[Len(aCols)][nAux] := CriaVar(aHeader[nAux][2],.T.)
						Endif
						aCols[Len(aCols)][Len(aHeader) + 1] := .F.
 						lFirst:= .F.		
					Next nAux						
					
					aCols[nItem][nPData]		:= SUF->UF_DATA
					aCols[nItem][nPDtExec]		:= CtoD("//")					
					
					aCols[nItem][nPAssunto] := SUF->UF_ASSUNTO
					aCols[nItem][nPDescAss] := Posicione("SX5",1,cFilSX5 + "T1" + SUF->UF_ASSUNTO,"X5DESCRI()")

					aCols[nItem][nPProd]    := SUF->UF_PRODUTO
					aCols[nItem][nPDescPro] := Posicione("SB1",1,cFilSB1 + SUF->UF_PRODUTO,"B1_DESC")

					aCols[nItem][nPOcorren] := SUF->UF_OCORREN
					aCols[nItem][nPDescOco] := Posicione("SU9",1,cFilSU9 + SUF->UF_ASSUNTO + SUF->UF_OCORREN,"U9_DESC")

					aCols[nItem][nPAcao]    := SUF->UF_CODSOL
					aCols[nItem][nPDescAca] := Posicione("SUQ",1,cFIlSUQ + SUF->UF_CODSOL,"UQ_DESC")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Pega o codigo do responsavel no cadastros de senhas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCols[nItem][nPCodOpe] := SUF->UF_OPERADO
					PswOrder(1)
					If PswSeek( aCols[nItem][nPCodOpe] )
						aUser := PswRet(1)
						aCols[nItem][nPDescOpe]	:= aUser[1][2]
					Endif

					aCols[nItem][nPStatus]  := SUF->UF_STATUS   //"Pendente" "Encerrado"
					aCols[nItem][nPObs]     := SUF->UF_OBS
					
					SUF->( DbSkip() )
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao estiver usando a entrada automatica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
					oGetTmk:oBrowse:Refresh(.T.)
				Endif
				
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ativa o cronometro da tela 10- 10 Segundos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cEntidade)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados da entidade e do contato que serao exibidos no rodape³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cContHist	:= TkDadosContato(M->UC_CODCONT,0)
		cNomeHist	:= TkEntidade(cEntidade,cChave,1)

		cTimeIni := Time()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
			oTimerCro:Activate()
		Endif
    Endif
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "TMK1")

Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2 Folder e Atendimento = TELEVENDAS           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFolder == 2 .OR. cTipoAte == "2"

		If lAtuEnch
			oEnchAux:EnchExecTrig("UA_CLIENTE")
		Endif	
  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for uma alteracao nao permito alterar o codigo do cliente em um atendimento ja gravado para evitar que o historico seja alterado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !INCLUI 	
			If M->UA_CLIENTE + M->UA_LOJA <> SUA->UA_CLIENTE + SUA->UA_LOJA
				If !TmkOK(STR0068) //"Atencao", "Voce esta alterando o codigo de Cliente de um atendimento que ja foi executado, Deseja prosseguir ?"
					Return(lRet)
				Endif	
			Endif          
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Primeiro: Atualiza a descricao do nome e da Loja do cliente ou do prospect selecionado                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual tabela esta sendo usada, SA1 - Cliente ou SUS - Prospect³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !l380 .And. !lTk271Auto
			aSUSF3Data := TkF3SUSData()
			If !Empty(aSUSF3Data) .AND. lProspect
				SUS->( DBSetOrder(1) )
				If ReadVar() == "M->UA_LOJA"
					TkF3SUSClear()
				ElseIf SUS->( DBSeek(xFilial("SUS")+aSUSF3Data[1]+aSUSF3Data[2]) )
					cAlias := "SUS"
					M->UA_CLIENTE := SUS->US_COD
					M->UA_LOJA	  := SUS->US_LOJA
				EndIf
			Else
				lProspect := .F.
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for PROSPECT pego os dados do SUS                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lProspect
			//Se for execauto, posiciona no código do prospect pois não foi selecinado pelo F3 do campo do cliente	
			If lTk271Auto
				SUS->(DBSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA))
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o Operador escolheu um PROSPECT que ja esta relacionado com um CLIENTE     ³ 
			//³proveniente da Administracao de Vendas do SIGAFAT ou de conversao de cadastros³
			//³O atendimento dever ser feito para o CLIENTE e nao para o prospect            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SUS->US_CODCLI) .AND. !Empty(SUS->US_LOJACLI)
				lProspect := .F.	
				M->UA_CLIENTE := SUS->US_CODCLI
				M->UA_LOJA	  := SUS->US_LOJACLI
				Aviso(STR0061,STR0062,{"OK"}) //"Atencao","Esse prospect ja foi convertido em Cliente, portanto o atendimento dever ser feito pelo código de CLIENTE"
			Else
				If Val(M->UA_OPER) == ORCAMENTO .And. SuperGetMv("MV_TMKLOJ") == "S"
					Aviso(STR0061,STR0075,{"OK"})	//"Atenção"##"Foi verificado que a integração com o SIGALOJA (MV_TMKLOJ) está habilitada, portanto não poderá ser utilizado nenhum prospect na geração do orçamento."			
					M->UA_CLIENTE := Space(Len(M->UA_CLIENTE))
					M->UA_LOJA	  := Space(Len(M->UA_LOJA))
					lProspect := .F.								
					Return(.T.)
				EndIf
							
				M->UA_TIPOCLI := SUS->US_TIPO
					
				DbSelectArea("SUS")
				DbSetOrder(1)
				DbSeek(cFilSUS+M->UA_CLIENTE+M->UA_LOJA,.T.)
				If !Eof()
				    cAlias  := "SUS"
					cTipo   := SUS->US_TIPO
				    M->UA_DESCCLI := SUS->US_NOME
				 	If Empty(M->UA_LOJA)
				 		M->UA_LOJA := SUS->US_LOJA
				 	Endif	
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrega o vendedor do prospect³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(SUS->US_VEND)
						cCodVend := SUS->US_VEND
			   	   	Else 
			   			cCodVend:="" 
			   		  	M->UA_VEND:=CRIAVAR("US_VEND",.F.)	
					Endif	
				Endif
			Endif	
			If lCliEntreg .And. (!Empty(M->UA_CLIENT) .Or. !Empty(M->UA_LOJAENT))
				M->UA_CLIENT	:= Space(TamSX3("UA_CLIENTE")[1])
				M->UA_LOJAENT	:= Space(TamSX3("UA_LOJA")[1])
			Endif	
		Endif
		
		If !lProspect
			If lTk271Auto
				M->UA_CLIENTE := aAutoCab[aScan(aAutoCab,{|x| AllTrim(x[1])=="UA_CLIENTE"})][2]
				M->UA_LOJA    := aAutoCab[aScan(aAutoCab,{|x| AllTrim(x[1])=="UA_LOJA"})][2]
			EndIf
			cAlias  := "SA1"
			M->UA_TIPOCLI  := SA1->A1_TIPO		 
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			If ReadVar() == "M->UA_CLIENTE"  .Or. ReadVar() == "M->UA_LOJA"
				If !Empty(M->UA_LOJA)
					If DbSeek(cFilSA1 + M->UA_CLIENTE + M->UA_LOJA,.T.)
					 	M->UA_DESCCLI := SA1->A1_NOME
				 		M->UA_LOJA := SA1->A1_LOJA				 		
		   				M->UA_TIPOCLI  := SA1->A1_TIPO
						If lCliEntreg
							M->UA_CLIENT	:= M->UA_CLIENTE
							M->UA_LOJAENT	:= M->UA_LOJA
						Endif	
		   				If ALTERA
		   					MafisAlt("NF_TPCLIFOR",M->UA_TIPOCLI)
		   				EndIf
						IIF(TkAtuComis(), M->UA_COMIS := SA1->A1_COMIS,)
					ElseIf DbSeek(cFilSA1 + M->UA_CLIENTE,.T.)
					 	M->UA_DESCCLI := SA1->A1_NOME
				 		M->UA_LOJA := SA1->A1_LOJA
						 If lCliEntreg .And. Empty(M->UA_CLIENT)
							M->UA_CLIENT	:= M->UA_CLIENTE
							M->UA_LOJAENT	:= M->UA_LOJA
						Endif	
						IIF(TkAtuComis(), M->UA_COMIS := SA1->A1_COMIS,)
					EndIf
				ElseIf DbSeek(cFilSA1 + M->UA_CLIENTE,.T.)
				 	M->UA_DESCCLI := SA1->A1_NOME
			 		M->UA_LOJA := SA1->A1_LOJA
					If lCliEntreg .And. Empty(M->UA_CLIENT)
						M->UA_CLIENT	:= M->UA_CLIENTE
						M->UA_LOJAENT	:= M->UA_LOJA
					Endif	
					IIF(TkAtuComis(), M->UA_COMIS := SA1->A1_COMIS,)
				EndIf
			ElseIf ReadVar() == "M->UA_LOJA"
				DbSeek(cFilSA1 + M->UA_CLIENTE + M->UA_LOJA,.T.)
			EndIf
			If !Eof() .And. (ReadVar() == "M->UA_CLIENTE" .Or. ReadVar() == "M->UA_LOJA")
				cAlias  := "SA1"
				cTipo   := SA1->A1_TIPO
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega a tabela de preco³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 	If !Empty(SA1->A1_TABELA)
			 		DbSelectArea("DA0")
			 		DbSetOrder(1)
			 		If DbSeek(cFilDA0+SA1->A1_TABELA)	
					 	M->UA_TABELA := SA1->A1_TABELA
					Endif 	
			 	Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega o vendedor do cliente ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(SA1->A1_VEND)
					cCodVend := SA1->A1_VEND
		   	   	Else 
		   			cCodVend := "" 
		   		  	M->UA_VEND := CRIAVAR("UA_VEND",.F.)	
	  				M->UA_DESCVEN := ""
				Endif	
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega a condicao de pagamento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   	If ! Empty(SA1->A1_COND)
					DbSelectArea("SE4")
					DbSetOrder(1)
					If DbSeek(cFilSE4+SA1->A1_COND)
						M->UA_CONDPG := SA1->A1_COND
					Endif	
				Endif
			   	If ! Empty(SA1->A1_DESC)
					M->UA_DESC1 := SA1->A1_DESC
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe o cliente/prospect na base.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !ExistCpo(cAlias,M->UA_CLIENTE+M->UA_LOJA)
			M->UA_DESCCLI := CRIAVAR("UA_DESCCLI",.F.) 
			Return(lRet)
		Endif

		If lCliEntreg .And. !lProspect
			If !ExistCpo(cAlias,M->UA_CLIENT+M->UA_LOJAENT)
				Return(lRet)
			EndIf
			If ReadVar() == "M->UA_CLIENT" .Or. ReadVar() == "M->UA_LOJAENT"
				If !Empty(M->UA_CLIENT) .And. !Empty(M->UA_LOJAENT) .And. SA1->(DbSeek(cFilSA1 + M->UA_CLIENT + M->UA_LOJAENT,.T.))
					M->UA_TIPOCLI := SA1->A1_TIPO
					cTipo := M->UA_TIPOCLI 
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se veio da agenda do operador ou da função TK271CABOK,      ³
		//³pois na função TK271CABOK é executado o comando oEnchoice:SetFocus() ³
		//³e dentro desse SetFocus() o TKClient é chamado erroneamente,         ³
		//³limpando o código do contato sem necessidade.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAchou	:= IsInCallStack("TK380OK") .Or. IsInCallStack("TK271CABOK")
		If !lAchou
   			M->UA_CODCONT := CRIAVAR("UA_CODCONT",.F.)
  			M->UA_DESCNT  := CRIAVAR("UA_DESCNT",.F.)
		EndIf                                          
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados da entidade e do contato que serao exibidos no rodape³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cContHist	:= TkDadosContato(M->UA_CODCONT,0)
		cNomeHist	:= TkEntidade(cAlias,M->UA_CLIENTE+M->UA_LOJA,1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o vendedor  		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !Empty(cCodVend)
	   		DbSelectArea("SA3")
			DbSetOrder(1)
			If DbSeek(cFilSA3+cCodVend)
	  			M->UA_VEND 	 := SA3->A3_COD 
		   		M->UA_DESCVEN:= SA3->A3_NOME
				If TkAtuComis() .And. Empty(M->UA_COMIS)
					M->UA_COMIS := SA3->A3_COMIS
				EndIf
			Endif
		EndIf

		cCodCli  := IIF(lCliEntreg .And. !lProspect .And. !Empty(M->UA_CLIENT),M->UA_CLIENT,M->UA_CLIENTE)
		cLojCli  := IIF(lCliEntreg .And. !lProspect .And. !Empty(M->UA_LOJAENT),M->UA_LOJAENT,M->UA_LOJA)
		cContrib := Posicione("SA1",1,cFilSA1 + cCodCli + cLojCli,"A1_CONTRIB")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Segundo : Atualiza o rodape dos impostos e inicializa a funcao fiscal para o novo cliente / prospect         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aCols) > 0 
			If !Empty(aCols[1][nPProd])

				If !lProspect .And. !Empty(cContrib) .And. cContrib == "1" .And. MaFisRet(,"NF_LINSCR")
					//Se o clinte de entrega for inscrito (A1_CONTRIB) altera a MATXFIS para retornar o CFOP correto
					MaFisAlt("NF_LINSCR",.F.)
				EndIf

				MaFisAlt("NF_CODCLIFOR",cCodCli)
				MaFisAlt("NF_LOJA",cLojCli) 

				//Natureza da operação
				cNaturez := Tk273DpNat( M->UA_CLIENTE, M->UA_LOJA)
				If !Empty(cNaturez)
					MaFisAlt("NF_NATUREZA",cNaturez)
				EndIf 

				For nX := 1 To Len(aCols)
					//Ajusta o CFOP dos itens quando é alterado o cliente de entrega
					MaFisAlt("IT_CF",TK273Cfo(cCodCli,cLojCli,aCols[nX][aPosicoes[11][2]]),nX)
				Next nX

				MaFisToCols(aHeader,aCols,,"TK271")
				Tk273TlvImp()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao estiver usando a entrada automatica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
					oGetTlv:oBrowse:Refresh(.T.)
				Endif	
			Else
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra as operacoes fiscais  O parametro FALSE         ³
				//³nao faz a inicializacao do refresh do rodape de impostos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisEnd(.F.)
				
				If _lTK271TpCl
					cTipo := P_TK271TCL()
 	   			ElseIf _lTKTipCli 
 				       cTipo := U_TKTIPCLI(cTipo)
		   		EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa os dados do cliente na FUNCAO FISCAL³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisIni( cCodCli,;	// 1-Codigo Cliente/Fornecedor
						  cLojCli,;	// 2-Loja do Cliente/Fornecedor
						 "C",;				// 3-C:Cliente , F:Fornecedor
						 "N",;				// 4-Tipo da NF
						 cTipo,;			// 5-Tipo do Cliente/Fornecedor
						 Nil,;				// 6-Relacao de Impostos que suportados no arquivo
						 Nil,;				// 7-Tipo de complemento
						 Nil,;				// 8-Permite Incluir Impostos no Rodape .T./.F.
						 Nil,;				// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
						 "MATA461",;		// 10-Nome da rotina que esta utilizando a funcao
						 Nil,;				// 11-Tipo de documento
						 Nil,;  			// 12-Especie do documento 
					     If(lProspect,M->UA_CLIENTE+M->UA_LOJA,""))// 13- Codigo e Loja do Prospect 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for um PROSPECT atualiza o estado de DESTINO e valida o campo de inscricao estadual ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lProspect 
					DbSelectArea("SUS")
					DbSetOrder(1)
					If DbSeek(cFilSUS+M->UA_CLIENTE+M->UA_LOJA)
						MaFisAlt("NF_UFDEST",SUS->US_EST)
					Endif		
				Endif

				If !lProspect .And. !Empty(cContrib) .And. cContrib == "1" .And. MaFisRet(,"NF_LINSCR")
					//Se o clinte de entrega for inscrito (A1_CONTRIB) altera a MATXFIS para retornar o CFOP correto
					MaFisAlt("NF_LINSCR",.F.)
				EndIf

	        Endif

        Endif 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o campo da validade do orcamento.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->UA_OPERADO)
			M->UA_DTLIM:= dDataBase + TkPosto(M->UA_OPERADO,"U0_VALIDAD")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe os dados da ultima ligacao seja Prospect ou Cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SUA")
		DbSetOrder(7)  //UA_FILIAL+UA_CLIENTE+UA_LOJA+STR(UA_DIASDAT,8,0)+STR(UA_HORADAT,8,0)
		
		If DbSeek(cFilSUA + M->UA_CLIENTE + M->UA_LOJA)
			While !EOF() .And. cFilSUA ==  SUA->UA_FILIAL .And. M->UA_CLIENTE == SUA->UA_CLIENTE .And. M->UA_LOJA == SUA->UA_LOJA
				If lProspect == SUA->UA_PROSPEC
					cLigacao := DTOC(CTOD("01/01/45")-UA_DIASDAT)+" - "+Substr(SUA->UA_INICIO,1,5)
					cOperador:= FATPDObfuscate(Posicione("SU7",1,cFilSU7 + SUA->UA_OPERADO,"U7_NOME"),"U7_NOME")
					
					If !Empty(SUA->UA_PROXLIG)
						cProximo:= DTOC(SUA->UA_PROXLIG) + " - " + SUA->UA_HRPEND + " - " + cOperador
					Endif
					cOperacao:= Tk273Status(SUA->UA_STATUS)
					Exit
				EndIf
				SUA->(DbSkip())
			EndDo
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ativa o cronometro da tela 10- 10 Segundos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTimeIni := Time()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
			oTimerCro:Activate()
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkGrvSUV(__cUserId,"TLV1")

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³3 Folder TELECOBRANCA                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nFolder == 3 .OR. cTipoAte == "3"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a tela de atendimento for chamada pela Agenda do Operador ou pelo Pre-Atendimento     ³
			//³e se a regra de negociacao estiver configurada para Automatica o acols com os titulos ja ³
			//³estara preenchido, entao nao pode limpar o acols.                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRegNeg:= TkPosto(M->ACF_OPERAD,"U0_REGNEG") 
			DbSelectArea("SK2")
			DbSetOrder(1)
			If DbSeek(cFilSK2 + cRegNeg)
				If SK2->K2_SELTIT == "1" .OR. Alltrim(SK2->K2_SELTIT) == ""	// 1-Automatico 2-Manual
					lLimpaAcols:= .F.
				Endif
			Endif
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obriga a execucao dos gatilhos para o campo "Cliente"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAtuEnch
				oEnchAux:EnchExecTrig("ACF_CLIENT")
			Endif	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for uma ALTERACAO nao permite a alteracao dos dados do cliente , caso contrario o operador pode apagar todo o historico de um atendimento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !INCLUI
				If M->ACF_CLIENT + M->ACF_LOJA <> ACF->ACF_CLIENT + ACF->ACF_LOJA
					Aviso(STR0060,STR0002,{"OK"}) //"Na alteração de cobrança não é possível alterar o cliente", "Atenção"
					Return(lRet)
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Primeiro: Atualiza o nome do cliente a partir do código sem considerar a loja e no campo loja coloca a loja do registro posicionado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAlias := "SA1"
			DbSelectArea("SA1")
			DbSetOrder(1)
			If Empty(M->ACF_LOJA)
				cPesqCli := cFilSA1+M->ACF_CLIENT
			Else
				cPesqCli := cFilSA1+M->ACF_CLIENT+M->ACF_LOJA
			EndIf
			If DbSeek(cPesqCli)
			 	M->ACF_DESCCLI	:= SA1->A1_NOME
		 		M->ACF_LOJA		:= SA1->A1_LOJA
				cTipo			:= SA1->A1_TIPO
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se existe o cliente/prospect na base.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistCpo(cAlias)
				 	M->ACF_DESCCLI	:= ""
			 		M->ACF_LOJA		:= ""
					cTipo			:= ""
				Else
					Return(lRet)
				Endif
			Endif
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados da entidade e do contato que serao exibidos no rodape³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cContHist	:= TkDadosContato(M->ACF_CODCON,0)
			cNomeHist	:= TkEntidade("SA1",M->ACF_CLIENTE+M->ACF_LOJA,1)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Segundo: Atualiza o rodape da tela com o ultimo atendimento feito para o cliente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACF")
			DbSetOrder(3)//ACF_CLIENT+ACF+LOJA+STR(ACF_DIASDA,8,0)+STR(ACF_HORADA,8,0)
			If Dbseek(cFilACF + M->ACF_CLIENT + M->ACF_LOJA)
				cLigacao 	:= DTOC(CTOD("01/01/45")-ACF_DIASDA) + " - " + Substr(ACF->ACF_INICIO,1,5)
				cOperador	:= FATPDObfuscate(Posicione("SU7",1,cFilSU7 + ACF->ACF_OPERAD,"U7_NOME"),"U7_NOME")
			    
			    If VAL(ACF->ACF_OPERA) == ATIVO    
				    cOperacao	:= STR0066  //"Ativo"
			    ElseIf VAL(ACF->ACF_OPERA) == RECEPTIVO
				    cOperacao	:= STR0067  //"Receptivo"
			    Endif    
			    
				If VAL(ACF->ACF_STATUS) == PLANEJADA
					cStatus := STR0064 // "Atendimento" 
				ElseIf VAL(ACF->ACF_STATUS) == PENDENTE
					cStatus := STR0065 // "Cobranca"   
				Else
					cStatus := STR0064 // "Encerrado" 
				Endif
			    
				DbSelectArea("SU7")
				DbSetOrder(1)
				If DbSeek(cFilSU7 + ACF->ACF_OPERAD)
					If !Empty(ACF->ACF_PENDEN)
						cProximo := DTOC(ACF->ACF_PENDEN) + " - " + ACF->ACF_HRPEND + " - " + cOperador
					Endif
				Endif
			Endif             
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ativa o cronometro da tela 10- 10 Segundos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTimeIni := Time()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao estiver usando a entrada automatica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
				oTimerCro:Activate()
	        Endif
	        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TkGrvSUV(__cUserId,"TLC1")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa os itens de cobranca porque os titulos so podem ser informados depois da escolha do CLIENTE ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If INCLUI .AND. lLimpaAcols
				aCols := Array(1, Len(aHeader) + 1)
				TkHeader("ACF","ACG_CODIGO",@aCols,aHeader)
				oGetTlc:oBrowse:Refresh(.T.)
			Endif
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver usando a entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
	cNomeHist := FATPDObfuscate(cNomeHist,"A1_NOME")
	cContHist := FATPDObfuscate(cNomeHist,"U5_CONTAT")
	oLigacao:Refresh()
	oOperador:Refresh()
	oStatus:Refresh()
	oOperacao:Refresh()
	oProximo:Refresh()
	oNomeHist:Refresh()
	oContHist:Refresh()
Endif
lRet := .T.
RestArea(aArea)
FATPDUnload()

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkProduto	  ³ Autor ³Vendas Clientes        ³ Data ³ 04/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega Caracteristicas do produto para todas as telas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³ CALL CENTER    			 					  	     	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkProduto()

Local lRet		:= .F.							// Retorno da funcao	
Local aArea		:= GetArea()					// Salva a area atual
Local cProduto 	:= ""							// Codigo do Produto
Local cObs 		:= ""							// Observacao do Produto
Local oObs
Local oDlg            							// Tela 
Local nPProd 	:= 0							// Posicao do Produto no ACOLS
Local nTamObs	:= GetSX3Cache("B1_OBS","X3_TAMANHO")			// Recebe o tamanho do campo cadastrado no SX3 (Dicionário de dados)

Local cBitPro 	:= ""							// Bitmap do produto
Local oBitPro							
Local cLocal 	:= ""                   		// Local do produto
Local cPictSB2  := SPACE(12)					// Picture do SB2
Local cNomeAlter:= ""							// Produto Alternativo
Local cGrupo    := ""							// Grupo
Local nPLocal   := 0							// Local
Local cAtend    := ""							// Codigo do Atendimento
Local cCliente  := ""							// Codigo do Cliente
Local cLoja     := ""                           // Loja do Cliente
Local cCodCont  := ""                           // Codigo do Contato
Local cCodOper  := ""                           // Codigo do Operador
Local cEnt      := ""							// Alias da Entidade
Local cChave    := ""                           // Chave da Entidade
Local cTipoAte	:= ""

Local nAtu   	:= 0
Local nPedVen 	:= 0
Local nEmp    	:= 0
Local nSalPedi	:= 0
Local nReserva	:= 0
Local nSaldo  	:= 0

Local nPosAnt   := 0 
Local nNAux		:= n
Local aColsAux	:= aClone(aCols)
Local aHeadAux	:= aClone(aHeader)

DEFAULT nFolder := If(nFolder == NIL,1,nFolder)

If nFolder == 1  //TeleMarketing
	cTipoAte	:= TkGetTipoAte()
	If cTipoAte $ "145" // Telemarketing ou Televendas
		nPProd    := aPosicoes[3][2]
		cAtend    := M->UC_CODIGO
		cEnt      := M->UC_ENTIDAD
		cChave    := M->UC_CHAVE
		cCodCont  := M->UC_CODCONT
		cCodOper  := M->UC_OPERADO
		If _lTmkMCA
			U_TMKMCA(cAtend,cEnt,cChave,cCodCont,cCodOper)
			Return(lRet)
		Endif

	Elseif 	cTipoAte == "2"	// Televendas
		nPProd    := aPosicoes[1][2]
		nPLocal   := aPosicoes[7][2]
		cAtend    := M->UA_NUM
		cCliente  := M->UA_CLIENTE
		cLoja     := M->UA_LOJA
		cCodCont  := M->UA_CODCONT
		cCodOper  := M->UA_OPERADO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para uso em Templates									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _lTmkVCAT
			T_TMKVCA(	cAtend	, cCliente	, cLoja	, cCodCont	,;
						cCodOper)
			Return(lRet)
		Endif
		If _lTmkVCA
			U_TMKVCA(	cAtend	, cCliente	, cLoja	, cCodCont	,;
						cCodOper)
			Return(lRet)
		Endif

	Endif

ElseIf nFolder == 2  //Televendas
	nPProd    := aPosicoes[1][2]
	nPLocal   := aPosicoes[7][2]
	cAtend    := M->UA_NUM
	cCliente  := M->UA_CLIENTE
	cLoja     := M->UA_LOJA
	cCodCont  := M->UA_CODCONT
	cCodOper  := M->UA_OPERADO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para uso em Templates									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lTmkVCAT
		T_TMKVCA(cAtend, cCliente, cLoja, cCodCont, cCodOper)
		Return(lRet)
	Endif

	If _lTmkVCA
		U_TMKVCA(cAtend, cCliente, cLoja, cCodCont, cCodOper)
		Return(lRet)
	Endif

Elseif nFolder == 4  //Configuracao de TMK	
	nPProd  := Ascan(aHeader,{|x| AllTrim(x[2])=="UF_PRODUTO"})
Endif

cProduto := aCols[n][nPProd]
If nPLocal > 0
	cLocal := aCols[n][nPLocal]
Endif

If Empty(cProduto)
	Help(" ",1,"SEM PRODUT" )
	Return(lRet)
Endif

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1") + cProduto)
	cObs   := MSMM(SB1->B1_CODOBS,nTamObs)
	cGrupo := SB1->B1_GRUPO
	If Empty(cLocal)
		cLocal := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
	Endif
	nPosAnt:= Recno()
	
	If DbSeek(xFilial("SB1")+SB1->B1_ALTER)
		cNomeAlter := AllTrim(B1_COD + " - "+ AllTrim(B1_DESC))
	Endif
Endif

DbSelectArea("SB2")
DbSetOrder(1)
If DbSeek(xFilial("SB2") + cProduto + cLocal)
	nAtu   	:= B2_QATU
	nPedVen := B2_QPEDVEN
	nEmp    := B2_QEMP
	nSalPedi:= B2_SALPEDI
	nReserva:= B2_RESERVA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Compatibilizacao com o SIGAFAT - Tecla F4 Visualizacao do estoque³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.))
Endif

DbSelectArea("SB5")
DbSeek(xFilial("SB5") + cProduto)

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("B2_QATU")
	cPictSB2 := SX3->(X3_PICTURE)
Endif

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"03"+cGrupo)
	cGrupo := X5DESCRI()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.					                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM 002,010 TO 420,723 TITLE (STR0021) PIXEL //"Caracteristicas do produto" 370/410
	DbSelectArea("SB1")
	DbGoto(nPosAnt)              
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados das caracteristicas do produto                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@04,02 TO 43,350 LABEL (STR0022) OF oDlg PIXEL COLOR CLR_BLUE //Dados do Produto 

	@13,04  SAY (STR0023) SIZE  21,7 OF oDlg PIXEL //"C¢digo" 
	@13,29  SAY SB1->B1_COD SIZE  110,8 OF oDlg PIXEL COLOR CLR_BLUE
	
	@13,150  SAY (STR0024) SIZE  20,7 OF oDlg PIXEL //"Unidade" 
	@13,172 SAY SB1->B1_UM SIZE  10,8 OF oDlg PIXEL COLOR CLR_BLUE
	
	@13,185 SAY (STR0025) SIZE  18,7 OF oDlg PIXEL //"Grupo"
	@13,205 SAY cGrupo SIZE 60,8 OF oDlg PIXEL COLOR CLR_BLUE
	
	@13,260 SAY (STR0026) SIZE  70,7 OF oDlg PIXEL //"Qtd. Embalagem"
	@13,300 SAY Transform(RetFldProd(SB1->B1_COD,"B1_QE"),PesqPict("SB1","B1_QE")) SIZE  35,7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@23, 4  SAY (STR0027) SIZE  32, 7 OF oDlg PIXEL //"Descri‡„o" 
	@23,33  SAY SB1->B1_DESC SIZE 220, 8 OF oDlg PIXEL COLOR CLR_BLUE
	
	@23,260 SAY (STR0028) SIZE  60,7 OF oDlg PIXEL //"Peso Liquido" 
	@23,300 SAY Transform(SB1->B1_PESO,PesqPict("SB1","B1_PESO")) SIZE  35,7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@33, 4  SAY (STR0029) SIZE  80,7 OF oDlg PIXEL //"Produto Alternativo" 
	@33,90  SAY cNomeAlter SIZE 250, 8 OF oDlg PIXEL COLOR CLR_BLUE
	
	cBitPro := SB1->B1_BITMAP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega a imagem do produto                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@45,12 TO 152,115 LABEL (STR0038) OF oDlg PIXEL  //"Foto" 193/105
	If Empty(SB1->B1_BITMAP)
		@ 80,38 SAY (STR0039) SIZE 50,8 PIXEL COLOR CLR_BLUE OF oDlg //"Foto n„o disponivel" 
	Else
		@ 50,14 REPOSITORY oBitPro OF oDlg NOBORDER SIZE 100,100 PIXEL
		Showbitmap(oBitPro,SB1->B1_BITMAP,"")
	  	oBitPro:lStretch 	:= .T.
		oBitPro:nwidth		:= 199		
		oBitPro:Refresh()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as observa‡ao sobre o produto B1_OBS         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@45,190 TO 152,350 LABEL (STR0040) OF oDlg PIXEL  //"Observa‡oes" 
	@51,195 GET oObs VAR cObs OF oDlg MEMO Size 150,99 PIXEL READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saldo do estoque do produto                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@158,02 TO 195,155 LABEL (STR0030) OF oDlg PIXEL  // Estoque 
	
	@163, 04 SAY (STR0031) SIZE  33, 7 OF oDlg PIXEL //"Ped. Abertos" 
	@163, 42 SAY Transform(nPedVen,cPictSB2) SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@173, 04 SAY (STR0032) SIZE  33, 7 OF oDlg PIXEL //"a Entrar" 
	@173, 42 SAY Transform(nSalPedi,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@183, 04 SAY (STR0033) SIZE  33, 7 OF oDlg PIXEL //"Atual"
	@183, 42 SAY Transform(nAtu,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@163, 83 SAY (STR0034) SIZE  33, 7 OF oDlg PIXEL //"Empenho" 
	@163,110 SAY Transform(nEmp,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@173, 83 SAY (STR0035) SIZE  33, 7 OF oDlg PIXEL //"Reservado" 
	@173,110 SAY Transform(nReserva,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@183, 83 SAY (STR0036) SIZE  33, 7 OF oDlg PIXEL //"Dispon¡vel" 
	@183,110 SAY Transform(nSaldo,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE

	@159,190 BUTTON STR0057 SIZE 50,15 OF oDlg PIXEL ACTION TKDetalhes(nFolder) 		  		//"Complemento"

	@159,250 BUTTON STR0058 SIZE 50,15 OF oDlg PIXEL ACTION TKVisuProd(cProduto,cLocal)   		//"Produto"

	@180,190 BUTTON STR0059 SIZE 50,15 OF oDlg PIXEL ACTION TKTabela(cProduto) 					//"Tabela"

	@180,250 BUTTON "OK" SIZE 50,15 OF oDlg PIXEL ACTION (lRet := .T.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTER

Restarea(aArea)
n		:= nNAux
aCols	:= aClone(aColsAux)
aHeader	:= aClone(aHeadAux)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkVisuPro ³ Autor ³ Vendas Clientes 	    ³ Data ³ 08/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega o AXVISUAL do cadastro de produtos para o item sele.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ CALL CENTER  			 					  	     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TKVisuProd(cProduto,cLocal)
Private cCadastro := (STR0004) //"Visualiza‡„o de Produtos"

DbSelectArea("SB1")

AxVisual("SB1",SB1->(RECNO()), 2)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkDetalhes³ Autor ³ Vendas Clientes  		³ Data ³09/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Visualizacao do complemento de produto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkDetalhes(nFolder)
Local lRet		:= .F.					// Retorno da funcao
Local nPProd 	:= 0
Local aArea		:= GetArea()
Local cTipoAte	:= ""

//Private cCadastro := STR0063			 //"Visualiza‡„o de Complemento de Produtos"

If nFolder == 1
	cTipoAte	:= TkGetTipoAte()
	If cTipoAte $ "145"	// Telemarketing ou Televendas ou Ambos
		nPProd := aPosicoes[3][2]
	ElseIf cTipoAte == "2"	// Televendas
		nPProd := aPosicoes[1][2]
	Endif	
ElseIf nFolder == 2 // Televendas
	nPProd := aPosicoes[1][2]
Elseif nFolder == 4  //Configuracao de TMK	
	nPProd  := Ascan(aHeader,{|x| AllTrim(x[2])=="UF_PRODUTO"})
Endif

If Empty(aCols[n][nPProd])
	Help(" ",1,"SEM PRODUT" )
	Return(lRet)
Endif

DbSelectArea("SB5")
DbSetOrder(1)
If DbSeek( xFilial("SB5")+ aCols[n][nPProd] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=AxVisual("SB5",RECNO(),2)
	lRet := .T.
Else	
	Help(" ",1,"TMKSEMSB5" )
	Return(lRet)
Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkTabela         ³ Autor ³ Vendas Clientes    ³ Data ³ 04/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega as Tabelas de Preco da consulta de produto              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³CALL CENTER           									 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/           
Static Function TKTabela(cProduto)

Local aArea 	:= GetArea()
Local aCores    := {}
Local aRotAnt	:= aClone(aRotina)
Local cCadAnt	:= cCadastro
Local lIncAnt   := INCLUI
Local aAreaDA0 	:= {}
Local nLinBkp	:= IIf(Type("n")=="N",n,1)

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
Private aRotina := {{ STR0047,"AxPesqui",0,1},;	//"Pesquisar"
					{ STR0048,"Oms010Tab",0,2},;	//"Visualizar"
					{ STR0049,"Oms010Tab",0,3},;	//"Incluir"
					{ STR0050,"Oms010Tab",0,4},;	//"Alterar"
					{ STR0051,"Oms010Tab",0,5},;	//"Excluir"
					{ STR0052,"Oms010Tab",0,4},; //"Copiar"
					{ STR0053,"Oms010For",0,3},; //"Copiar"		
					{ STR0054,"Oms010Rej",0,5},; //"Reajuste"
					{ STR0055,"Oms010Leg",0,2} }	//"Legenda"

cCadastro := STR0056	//"Manutencao da Tabela de Precos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as cores da MBrowse                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCores,{"Dtos(DA0_DATATE) <= Dtos(dDataBase).AND. !Empty(Dtos(DA0_DATATE))","DISABLE"}) //inativa
Aadd(aCores,{"(Dtos(DA0_DATATE) > Dtos(dDataBase) .OR. Empty(Dtos(DA0_DATATE))).AND.DA0_ATIVO =='1'","ENABLE"})    //Ativa simples
Aadd(aCores,{"(Dtos(DA0_DATATE) > Dtos(dDataBase) .OR. Empty(Dtos(DA0_DATATE))) .AND.DA0_ATIVO =='2'","BR_LARANJA"}) //Ativa especial

INCLUI := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereca para a funcao MBrowse                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DA0")
aAreaDA0 := DA0->(GetArea())
DbSetOrder(1)
If DbSeek(xFilial("DA0"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as Tabelas de Preços que contenham o produto cadastrado.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("DA0")
	n := 1
	Oms010Tab("DA0",DA0->(Recno()),2,.T.,.F.,cProduto)
	n := nLinBkp
Else
	HELP(" ",1,"REGNOIS")
EndIf
	
DA0->(DbClearFilter())
RestArea(aAreaDA0)

RestArea(aArea)
cCadastro := cCadAnt
aRotina	:= aClone(aRotAnt)	 
INCLUI := lIncAnt
	
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkConcorrente    ³ Autor ³ Vendas Clientes    ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega Concorrentes   				       	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³CALL CENTER          										 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkConcorrente()

Local lRet	   := .F.
Local aArea	   := GetArea()								// Salva a area atual		
Local nPProd   := 0                						// Posicao do produto no acols		
Local aCon     :={}										// Array com os concorrentes
Local oCon     := NIL             							// Objeto Listbox
Local oDlg     := NIL										// Tela
Local cObsCon  := ""                             // Memo do SU2
Local oObsCon  := NIL										// Objeto MEMO
Local oMonoAs  := TFont():New( "Courier New", 6, 0 )    // Fonte do Memo
Local cAtend   := ""									// Codigo do Atendimento
Local cCliente := ""                                    // Codigo do Cliente
Local cLoja    := ""                                    // Codigo da Loja
Local cCodCont := ""									// Codigo do Contato
Local cCodOper := ""                                    // Codigo do Operador
Local cChave   := ""                                    // Chave da Entidade
Local cEnt     := ""	                                // Alias da Entidade
Local cProduto := ""									// Codigo do produto principal para busca no cadastro de concorrentes
Local cFilSU2  := xFilial("SU2")
Local cTipoAte := ""

Private aMemos := {{"U2_CODOBS","U2_OBS"}}              // Para compatibilizacao com o AXVISUAL do SU2
                   
nFolder	:= If(nFolder == NIL, 1, nFolder)

If nFolder == 1 // TeleMarketing ou Televendas
	cTipoAte := TkGetTipoAte()
	If cTipoAte $ "145" //Telemarketing - Televendas ou Ambos
		
		nPProd   := aPosicoes[3][2]
		cAtend   := M->UC_CODIGO
		cEnt     := M->UC_ENTIDAD
		cChave   := M->UC_CHAVE
		cCodCont := M->UC_CODCONT
		cCodOper := M->UC_OPERADO
		
		If _lTMKMCO
			U_TMKMCO(cAtend, cEnt, cChave, cCodCont, cCodOper)
			Return(lRet)
		Endif
		
	Elseif cTipoAte == "2" //Televendas
		
		nPProd   := aPosicoes[1][2]
		cAtend   := M->UA_NUM
		cCliente := M->UA_CLIENTE
		cLoja    := M->UA_LOJA
		cCodCont := M->UA_CODCONT
		cCodOper := M->UA_OPERADO
		
		If _lTMKCON
			U_TMKCON(cAtend, cCliente, cLoja, cCodCont, cCodOper)
			Return(lRet)
		Endif
		
	ElseIf (cTipoAte == "3")
		Help(" ",1,"SEM PRODUT" )
		Return(lRet)
	Endif
	
ElseIf nFolder == 2 // Televendas
	nPProd   := aPosicoes[1][2]
	cAtend   := M->UA_NUM
	cCliente := M->UA_CLIENTE
	cLoja    := M->UA_LOJA
	cCodCont := M->UA_CODCONT
	cCodOper := M->UA_OPERADO
	
	If _lTMKCON
		U_TMKCON(cAtend, cCliente, cLoja, cCodCont, cCodOper)
		Return(lRet)
	Endif

Elseif nFolder == 4  //Configuracao de TMK	
	nPProd  := Ascan(aHeader,{|x| AllTrim(x[2]) == "UF_PRODUTO"})
Endif

// Pega o codigo do Produto na linha atual do item
cProduto:=aCols[n][nPProd]

If Empty( cProduto )
	Help(" ",1,"SEM PRODUT" )
	Return(lRet)
Endif

DbSelectArea("SU2")
DbSetOrder(1)
DbSeek(cFilSU2 + cProduto)
While (!Eof()) .AND. (cFilSU2+cProduto == U2_FILIAL+U2_COD)
	Aadd(aCon,{	U2_CONCOR,;
				U2_PRECO,;
				U2_DTATUAL}	)
	SU2->( DbSkip() )
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o cadastro de concorrentes estiver vazio o sistema vai sugerir a inclusao do SU2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCon) == 0
	TkIncCon()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra dados do Produto.     							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg FROM 48,171 TO 343,652 TITLE STR0041 PIXEL //"Concorrentes" 

		@  3 ,1 TO 73,240 LABEL STR0042 OF oDlg PIXEL //"Produtos Concorrentes" 

		@  10,3 LISTBOX oCon FIELDS;
			 HEADER ;
			 	STR0043,; // "Produto"
			 	STR0044,; // "Pre‡o"
			 	STR0045;  // "Atualiza‡„o" 
				SIZE 235,60 OF oDlg PIXEL;
				ON CHANGE TKAtuCon(@cProduto,@oCon,@aCon,@cObsCon,@oObsCon);
	
		oCon:SetArray(aCon)
		oCon:bLine:={||{aCon[oCon:nAt,1],;
						Str(aCon[oCon:nAt,2],10,2),;
						DTOC(aCon[oCon:nAt,3])}}

		@ 75 ,1 TO 145,200 LABEL STR0046 OF oDlg PIXEL //"Observa‡”es" 
	
		@ 82,3 GET oObsCon VAR cObsCon OF oDlg MEMO SIZE 194,60 PIXEL WHEN .T. ReadOnly

		oObsCon:oFont := oMonoAs
		oObsCon:bRClicked := {|| AllwaysTrue()}
	
		DEFINE SBUTTON FROM 100,207 TYPE 4  ENABLE OF oDlg ACTION (TkIncCon(),oDlg:End())
		DEFINE SBUTTON FROM 115,207 TYPE 11 ENABLE OF oDlg ACTION (TkAltCon(cProduto,aCon[oCon:nAt,1]),oDlg:End())
		DEFINE SBUTTON FROM 130,207 TYPE 1  ENABLE OF oDlg ACTION (lRet := .T.,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT TKAtuCon(@cProduto,@oCon,@aCon,@cObsCon,@oObsCon)
Endif
	
oMonoAs:End()
aMemos := NIL
RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkIncCon  ³ Autor ³ Vendas Clientes       ³ Data ³08/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Inclusao de novos concorrentes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³TkIncCon()	    				              	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkIncCon()

Local aArea		:= GetArea()
Local nOpca 	:= 0
Local cCadAnt   := cCadastro
Local lAltera	:= ALTERA	// Variável de apoio para guardar o conteúdo atual da variável ALTERA
Local lInclui	:= INCLUI	// Variável de apoio para guardar o conteúdo atual da variável INCLUI

Private aMemos	:= {{"U2_CODOBS","U2_OBS"}}
Private aRotina := { { STR0004,"AXPESQUI"    , 0 , 1 , 0 , .F.},;    //"Pesquisar"
					 { STR0005,"TK020VISUAL" , 0 , 2 , 0 , .T.},;    //"Visualizar"
					 { STR0006,"TK020INCLUI" , 0 , 3 , 0 , .T.},;    //"Incluir"
					 { STR0007,"TK020ALTERA" , 0 , 4 , 82, .T.},;    //"Alterar"
					 { STR0008,"TK020DELETA" , 0 , 5 , 3, .T.},;     //"Excluir"  
					 { STR0012,"FtContato"	 , 0 , 4 , 0 , .T.} }    //"Contatos"

cCadastro := STR0001 //"Inclus„o de Concorrentes"
lRefresh  := .T. 

DbSelectArea("SU2")

BEGIN TRANSACTION
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alterado o conteúdo das variáveis INCLUI e ALTERA,    ³
	//³devido a função AxCadastro ter que carregar os campos ³
	//³virtuais                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	INCLUI := .T.
	ALTERA := .F.
			
	nOpcA:=AxInclui("SU2",RECNO(), 3)
	
END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volto o conteúdo inicial das variáveis INCLUI e ALTERA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
INCLUI := lInclui
ALTERA := lAltera

RestArea(aArea)
cCadatro := cCadAnt
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkAltCon  ³ Autor ³ Vendas Clientes       ³ Data ³28/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Alteracao de novos concorrentes         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³TkAltCon()	    				              	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Tmka010 - TeleVendas        						          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkAltCon(cProduto,cDescCon)

Local aArea		:= GetArea()
Local nOpca		:= 0                          
Local cCadAnt	:= cCadastro
Local lAltera	:= ALTERA	// Variável de apoio para guardar o conteúdo atual da variável ALTERA
Local lInclui	:= INCLUI	// Variável de apoio para guardar o conteúdo atual da variável INCLUI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³As variáveis private aMemos e aRotina, foram declaradas, ³
//³devido a função AxAltera as usam internamente.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aMemos	:= {{"U2_CODOBS","U2_OBS"}}
Private aRotina := { { STR0004,"AXPESQUI"    , 0 , 1 , 0 , .F.},;    //"Pesquisar"
					 { STR0005,"TK020VISUAL" , 0 , 2 , 0 , .T.},;    //"Visualizar"
					 { STR0006,"TK020INCLUI" , 0 , 3 , 0 , .T.},;    //"Incluir"
					 { STR0007,"TK020ALTERA" , 0 , 4 , 82, .T.},;    //"Alterar"
					 { STR0008,"TK020DELETA" , 0 , 5 , 3, .T.},;     //"Excluir"  
					 { STR0012,"FtContato"	 , 0 , 4 , 0 , .T.} }    //"Contatos"

cCadastro := STR0003 //"Altera‡„o de Concorrentes"
lRefresh  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 82 (ACS), verifica se o usu rio poder  ou n„o	 ³
//³ alterar cadastros.                   						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkPsw(82)
	HELP(" ",1,"TMKACECAD")
	Return(.F.)
Endif

DbSelectArea("SU2")                    
DbSetOrder(1)
If DbSeek(xFilial("SU2")+cProduto+cDescCon)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN TRANSACTION
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alterado o conteúdo das variáveis INCLUI e ALTERA,    ³
		//³devido a função AxCadastro ter que carregar os campos ³
		//³virtuais                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		INCLUI := .F.
		ALTERA := .T.
		
		nOpcA:=AxAltera("SU2",RECNO(), 4)
	
	END TRANSACTION                	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volto o conteúdo inicial das variáveis INCLUI e ALTERA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
INCLUI := lInclui
ALTERA := lAltera

RestArea(aArea)
cCadastro := cCadAnt
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkLoja    ºAutor  ³Vendas Clientes     º Data ³  08/07/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a loja digitada pelo usuario na tela de atendimento º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkLoja()

Local aArea		:= GetArea()			// Salva a area atual
Local cTipo     := "" 					// Tipo do Cliente/Prospect
Local cAlias    := ""					// Alias do Cliente/Prospect
Local lRet		:= .F.
Local cNaturez	:= ''					//Natureza da Televenda
Local cFilSUS	:= xFilial("SUS")
Local cFilSA1	:= xFilial("SA1")
Local cFilSUA	:= xFilial("SUA")
Local lCliEntreg	:= SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o atendimento for TeleVendas ou Telecobranca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFolder == 2) .AND. (TkGetTipoAte() == "2" .Or. TkGetTipoAte() == "4" .Or. TkGetTipoAte() == "5")  //1 Folder com Atendimento = TeleVendas ou Ambos
	nPProd := aPosicoes[1][2]		// Posicao do campo UB_PRODUTO no ACOLS
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as variaveis do rodape sempre³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLigacao := ""
cOperador:= ""
cOperacao:= ""
cStatus  := ""
cProximo := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³2 Folder e Atendimento = TELEVENDAS           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFolder == 2) .AND. (TkGetTipoAte() == "2" .Or. TkGetTipoAte() == "4" .Or. TkGetTipoAte() == "4")

	If (nFolder == 2) .OR. (TkGetTipoAte() == "2")

		If Empty(M->UA_CLIENTE)
			Help(" ",1,"SEM CLIENT")
			Return(lRet)
		Endif	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Primeiro: Atualiza a descricao do nome e da Loja do cliente ou do prospect selecionado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lProspect
			cAlias  := "SUS"
			cTipo   := SUS->US_TIPO
			DbSelectArea("SUS")
			DbSetOrder(1)
			DbSeek(cFilSUS+M->UA_CLIENTE+M->UA_LOJA,.T.)
			If !Eof()
			    M->UA_DESCCLI := SUS->US_NOME
			 	If Empty(M->UA_LOJA)
			 		M->UA_LOJA := SUS->US_LOJA
			 	Endif	
			Endif
		Else
			cAlias  := "SA1"
			cTipo   := SA1->A1_TIPO
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(cFilSA1+M->UA_CLIENTE+M->UA_LOJA,.T.)
			If !Eof()
			 	M->UA_DESCCLI := SA1->A1_NOME
			 	If Empty(M->UA_LOJA)
			 		M->UA_LOJA := SA1->A1_LOJA
			 	Endif	
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Segundo : Atualiza o rodape dos impostos e inicializa a funcao fiscal para o novo cliente / prospect         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aCols) > 0 
			If !Empty(aCols[1][nPProd])
				MaFisAlt("NF_CODCLIFOR",IIF(lCliEntreg .And. !lProspect,M->UA_CLIENT,M->UA_CLIENTE))
				MaFisAlt("NF_LOJA",IIF(lCliEntreg .And. !lProspect,M->UA_LOJAENT, M->UA_LOJA))              
				MaFisToCols(aHeader,aCols,,"TK271")
				Tk273TlvImp()
				oGetTlv:oBrowse:Refresh(.T.)
			Else
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra as operacoes fiscais  O parametro FALSE         ³
				//³nao faz a inicializacao do refresh do rodape de impostos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisEnd(.F.)
				
				If _lTK271TpCl
					cTipo := P_TK271TCL()
				ElseIf _lTKTipCli 
 						cTipo := U_TKTIPCLI(cTipo)
				EndIf	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa os dados do cliente na FUNCAO FISCAL³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisIni(IIF(lCliEntreg .And. !lProspect,M->UA_CLIENT,M->UA_CLIENTE),;	// 1-Codigo Cliente/Fornecedor
						 IIF(lCliEntreg .And. !lProspect,M->UA_LOJAENT, M->UA_LOJA),;	// 2-Loja do Cliente/Fornecedor
						 "C",;				// 3-C:Cliente , F:Fornecedor
						 "N",;				// 4-Tipo da NF
						 cTipo,;			// 5-Tipo do Cliente/Fornecedor
						 Nil,;				// 6-Relacao de Impostos que suportados no arquivo
						 Nil,;				// 7-Tipo de complemento
						 Nil,;				// 8-Permite Incluir Impostos no Rodape .T./.F.
						 Nil,;				// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
						 Nil,;				// 10-Nome da rotina que esta utilizando a funcao
						 Nil,;				// 11-Tipo de documento
						 Nil,;  			// 12-Especie do documento 
					     If(lProspect,M->UA_CLIENTE+M->UA_LOJA,""))// 13- Codigo e Loja do Prospect 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for um PROSPECT atualiza o estado de DESTINO e valida o campo de inscricao estadual ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lProspect 
					DbSelectArea("SUS")
					DbSetOrder(1)
					If DbSeek(cFilSUS+M->UA_CLIENTE+M->UA_LOJA)
						MaFisAlt("NF_UFDEST",SUS->US_EST)
	
					Endif		
				EndIf

				cNaturez := Tk273DpNat( M->UA_CLIENTE, M->UA_LOJA )
				If !Empty(cNaturez)
					MaFisAlt("NF_NATUREZA",cNaturez)
				EndIf
	        Endif
         
    	Endif
    	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o campo da validade do orcamento.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->UA_DTLIM:= dDataBase + TkPosto(M->UA_OPERADO,"U0_VALIDAD")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega o vendedor do cliente ou do prospect³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lProspect
			M->UA_VEND := Posicione("SUS",1,cFilSUS + M->UA_CLIENTE + M->UA_LOJA,"US_VEND")
		Else
			M->UA_VEND := Posicione("SA1",1,cFilSA1 + M->UA_CLIENTE + M->UA_LOJA,"A1_VEND")
		Endif
		M->UA_DESCVEN:= Posicione("SA3",1,xFilial("SA3") + M->UA_VEND,"A3_NOME")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe os dados da ultima ligacao seja Prospect ou Cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SUA")
		DbSetOrder(7)   //UA_FILIAL+UA_CLIENTE+UA_LOJA+STR(UA_DIASDAT,8,0)+STR(UA_HORADAT,8,0)
		
		If DbSeek(cFilSUA + M->UA_CLIENTE + M->UA_LOJA)
			While !EOF() .And. cFilSUA ==  SUA->UA_FILIAL .And. M->UA_CLIENTE == SUA->UA_CLIENTE .And. M->UA_LOJA == SUA->UA_LOJA
				If lProspect == SUA->UA_PROSPEC
			
					cLigacao := DTOC(CTOD("01/01/45")-UA_DIASDAT)+" - "+Substr(SUA->UA_INICIO,1,5)
					cOperador:= FATPDObfuscate(Posicione("SU7",1,xFilial("SU7") + SUA->UA_OPERADO,"U7_NOME"),"U7_NOME")
			
					If !Empty(SUA->UA_PROXLIG)
						cProximo:= DTOC(SUA->UA_PROXLIG) + " - " + SUA->UA_HRPEND + " - " + cOperador
					EndIf
			
					cOperacao:= Tk273Status(SUA->UA_STATUS)
					Exit
				EndIf
				SUA->( DbSkip() )
			EndDo
		EndIf	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³3 Folder TELECOBRANCA                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nFolder == 3)

			If Empty(M->ACF_CLIENTE)
				Help(" ",1,"SEM CLIENT")
				Return(lRet)
			Endif	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Primeiro: Atualiza a descricao do nome e da Loja do cliente ou do prospect selecionado                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAlias  := "SA1"
			cTipo   := SA1->A1_TIPO
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(cFilSA1+M->ACF_CLIENT+M->ACF_LOJA,.T.)
			If !Eof()
			 	M->ACF_DESCCLI := SA1->A1_NOME
			 	If Empty(M->ACF_LOJA)
			 		M->ACF_LOJA := SA1->A1_LOJA
			 	Endif	
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Primeiro: Atualiza o rodape da tela com o ultimo atendimento feito para o cliente                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACF")
			DbSetOrder(1)
			If DbSeek(xFilial("ACF") + M->ACF_CLIENT + M->ACF_LOJA)
				
				cLigacao := DTOC(CTOD("01/01/45")-ACF_DIASDA) + " - " + Substr(ACF->ACF_INICIO,1,5)				
				cOperador:= FATPDObfuscate(Posicione("SU7",1,xFilial("SU7") + ACF->ACF_OPERAD,"U7_NOME"),"U7_NOME")
				
				If !Empty(ACF->ACF_PENDEN)
					cProximo:= DTOC(ACF->ACF_PENDEN) + " - " + ACF->ACF_HRPEND + " - " + cOperador
				Endif
			Endif
				
		Endif
	Endif
	
	lRet := .T.
Endif

oLigacao :Refresh()
oOperador:Refresh()
oStatus	 :Refresh()
oOperacao:Refresh()
oProximo :Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa o cronometro da tela 10- 10 Segundos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTimeIni := Time()
oTimerCro:Activate()

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |TkAtuComis  ³ Autor ³ Vendas Clientes       ³ Data ³15/07/11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verfica se o campo UA_COMIS esta em uso para atualidar      ³±±
±±³			 ³comissao.											          ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso		 ³CALL CENTER 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkAtuComis()
Local lUsado := .F.

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("UA_COMIS")
If X3Uso( SX3->X3_USADO )
	lUsado := .T.
EndIf

Return lUsado




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
