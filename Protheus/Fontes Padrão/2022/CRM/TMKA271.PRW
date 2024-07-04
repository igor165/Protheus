#INCLUDE "TMKA271.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³																						 ³
³	ACOLS DA ROTINA DE TELEVENDAS														 ³
³                                                                                        ³ 
³	01 - Produto																		 ³
³	02 - Descricao																		 ³
³	03 - Situacao do Produto															 ³
³	04 - Quantidade																		 ³	
³	05 - Pre‡o Unitario																     ³	
³	06 - Valor do Item (Quantidade * Pre‡o Unitario)									 ³
³	07 - Local Padrao																	 ³
³	08 - Unidade																		 ³
³	09 - Desconto (%)																 	 ³
³	10 - Valor do Desconto																 ³
³	11 - Tipo E/S																		 ³
³	12 - Codigo Fiscal																	 ³
³	13 - Acrescimo (%)																	 ³	
³	14 - Valor do Acrescimo																 ³
³	15 - Preco de Tabela																 ³
³	16 - Data de entrega																 ³
³	17 - Lote																			 ³
³	18 - Sub-Lote																		 ³
³	19 - Data de validade do Lote														 ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³																						 ³
³	ACOLS DA ROTINA DE TELEMARKETING													 ³
³																						 ³
³	01 - Assunto																		 ³
³	02 - Descricao do assunto															 ³
³	03 - Produto																		 ³
³	04 - Descricao do produto															 ³
³	05 - Ocorrencia																		 ³	
³	06 - Descricao da ocorrencia														 ³
³	07 - Acao																			 ³
³	08 - Descricao da Acao																 ³
³	09 - Responsavel       																 ³
³	10 - Nome do Responsavel															 ³
³	11 - Data da Acao																	 ³
³	12 - Status    																		 ³
³	13 - Observacao      			   													 ³
³	14 - Data da Execucao			   													 ³
³	15 - Complemento 																	 ³
³																						 ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³	ACOLS DA ROTINA DE TELECOBRANCA														 ³
³																						 ³
³	01 - Titulo																			 ³
³	02 - Prefixo																		 ³
³	03 - Parcela																		 ³
³	04 - Tipo do Titulo																	 ³
³	05 - Descricao do Tipo																 ³
³	06 - Natureza																		 ³
³	07 - Descricao da Natureza															 ³
³	08 - Data de Vencimento																 ³
³	09 - Data de Vencimento Real														 ³
³	10 - Valor																			 ³
³	11 - Valor Acrescimo																 ³
³	12 - Valor Desconto																	 ³
³	13 - Status																			 ³
³	14 - Acao																			 ³
³	15 - Descricao da Acao																 ³
³																						 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   BOTOES DA SUPERIOR (aBtn)							aCfgBtn - Array	   			     ³
³																						 ³
³	01 - Copiar                                             01                           ³ 
³	02 - Colar                                              02                           ³ 
³	03 - Calculadora...                                     03                           ³ 
³	04 - Agenda...                                          04                           ³ 
³	05 - Gerenciador de Impressao...                        05                           ³ 
³	06 - Help de Programa...                                06                           ³ 
³   07 - Limpa o Atendimento                                07                           ³ 
³	08 - Cancela o Atendimento								08							 ³
³	09 - Marketing Ativo									09							 ³
³	10 - Envio de Tarefa									10							 ³
³	11 - Script da Campanha                                 11                           ³ 
³	12 - Alteracao de Entidades                             12                           ³ 
³	13 - Historico das ligacoes                             13                           ³ 
³	14 - Situacao Financeira                                14                           ³ 
³	15 - Cadastro de Contatos                               15                           ³ 
³	16 - Banco de Conhecimento                              16                           ³ 
³	17 - Tracker da Entidade                                17                           ³ 
³	18 - Visualiza Cadastro de Eventos                      18                           ³ 
³	19 - OK                                                 19                           ³ 
³	20 - CANCELA                                            20                           ³  
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³																						 ³
³   BOTOES DA LATERAL (oBtn)															 ³
³	   																		 			 ³
³	TMK																		 			 ³
³	01 - Encerramento										21							 ³
³	02 - Chamado Tecnico									22							 ³
³	03 - Ligacoes Pendentes									23							 ³	
³	04 - Cadastro do Produto                                24              	         ³ 
³	05-  Cadastro de Concorrentes                           25                           ³    
³	06 - Cadastro de Acessorios								26							 ³
³	07 - Listas de Contato        						   (nao esta no array)			 ³
³	08 - Historico da Entidade 							   (nao esta no array)			 ³
³   TLV																					 ³
³	20 - Cadastro do Produto                                24 - comum para TMK e TLV    ³ 
³	21-  Cadastro de Concorrentes                           25 - comum para TMK e TLV    ³    
³	22 - Cadastro de Acessorios								26 - comum para TMK e TLV    ³
³	23 - Condicoes de Pagamento								27					 		 ³
³	24 - Vendedor                                           28                           ³ 
³	25 - Pedido                                             29                           ³ 
³	26 - Rastreamento                                       30                           ³ 
³	27 - Lotes                                              31                           ³ 
³   28 - Sub-Lotes                                          32                           ³ 
³   29 - Vendas Lojas                                       33                           ³ 
³   30 - Bonus                                              34                           ³ 
³	31 - Consulta TEF                                       35                           ³ 
³	32 - Listas de Contato                                 (nao esta no array)           ³ 
³	33 - Historico da Entidade                             (nao esta no array)           ³ 
³   TLC																					 ³
³	40 - Encerramento                                       21- comum para TMK e TLV     ³ 
³	41 - Listas de Contato                                 (nao esta no array)           ³ 
³	42 - Historico da Entidade                             (nao esta no array)           ³ 
³																						 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA271   ºAutor  ³ Vendas Clientes     º Data ³  06/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este fonte possui somente as telas principais do Atendimentoº±±
±±º          ³ juntamente com a chamada de seus respectivos botoes.        º±±
±±º          ³ Browse da tela de atendimento com modelo 3                  º±±
±±º          ³ Os programas estao divididos da seguinte forma:			   º±±
±±º          ³ TMKA271 - Programa principal - TELA						   º±±
±±º          ³ TMKA272 - TELEMARKETING             						   º±±
±±º          ³ TMKA273 - TELEVENDAS               						   º±±
±±º          ³ TMKA274 - TELECOBRANCA              						   º±±
±±º          ³ TMKXFUN - Funcoes para todas as rotinas					   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 = Array com os campos do cabecalho do atendimento que  º±±
±±º			 ³        serao utilizados na rotina de entrada automatica.    º±±
±±º			 ³ExpA2 = Array com os campos dos itens do atendimento que     º±±
±±º			 ³        serao utilizados na rotina de entrada automatica.    º±±
±±º			 ³ExpN3 = nOpc da entrada automatica. Sera aceito apenas 	   º±±
±±º			 ³        3-Inclusao  ou  4- Alteracao.                        º±±
±±º			 ³ExpC4 = Rotina de Atendimento para entrada automatica.       º±±
±±º			 ³        "1" - Telemarketing "2" - Televendas				   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Call Center 						                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMKA271(xAutoCab,xAutoItens,nOpcAuto,cRotina)

Local aCores1    := {{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 2)" , "BR_VERMELHO" },;// Pendente
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 3)" , "BR_VERDE"    },;// Encerrado
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 1)" , "BR_AZUL"     },;// Planejada
   						{"(!EMPTY(SUC->UC_CODCANC))","BR_PRETO"		}} 								  // Cancelado

Local aCores2    := {{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. Empty(SUA->UA_DOC))" , "BR_VERDE"   },;// Faturamento - VERDE
						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. !Empty(SUA->UA_DOC))", "BR_VERMELHO"},;// Faturado - VERMELHO
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2)"	, "BR_AZUL"   },;						// Orcamento - AZUL
   						{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 3)"	, "BR_MARRON" },; 						// Atendimento - MARRON
   						{"(!EMPTY(SUA->UA_CODCANC))","BR_PRETO"		}} 														// Cancelado
   						

Local aCores3    := {	{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 1)",	"BR_AZUL"		},;		// Atendimento
   						{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 2)",	"BR_VERDE"		},;		// Cobranca
   						{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 3)",	"BR_VERMELHO"	},;		// Encerrado
   						{"(!EMPTY(ACF->ACF_CCANC))",								"BR_CINZA"		}} 		// Cancelado

Local aCoresAtu		:= {} 								//Array com expressoes das legendas
Local lTk271Cor		:= ExistBlock("TK271COR")		// P.E. Para substituir as cores utilizadas na mbrowse
Local aRetCor		:= {}							// Array de retorno do ponto de entrada TK271COR
Local bBlockCor		:= Nil							// Codeblock para atualizar o array de cores correto no P.E. TK271COR
Local aRotAdic		:= {}							// Retorno do P.E. TK271ROTM
Local lTk271RotM	:= ExistBlock("TK271ROTM")  	// P.E. para carregar ROTINAS PERSONALIZADAS para o Menu.
Local lRet			:= .F.							// Retorno da funcao	
Local lTk271Fil		:= ExistBlock("TK271FIL")		// Ponto de entrada para filtrar o Browse
Local cFiltra		:= " "							// Filtro de retorno do ponto de entrada
Local aIndex		:= {}							// Array com o indices utilizados
Local cTipoAte		:= AllTrim(TkGetTipoAte())		// Codigo do tipo de atendimento prestado
Local cFilSQL  		:= Nil							// Expressão SQL que será utilizado no filtro do browse
Local cAlias			:= ""							//Campos dos Itens utilizados nas rotinas
Local cDescri			:=	""							//Descricao da operacao
Local oMBrowse		:= Nil                      //Objeto FwMBrowse
Local nX				:= 0							//Variavel numerica para controle de loop

Private cCadastro 	:= STR0001  					//"Atendimento"
Private aRotina   	:= MenuDef()
Private lTk271Auto  := xAutoCab <> NIL  .AND. xAutoItens <> NIL
Private aAutoCab	:= {}							// Campos de Cabecalho utilizados na rotina automatica
Private aAutoItens  := {}							// Campos dos Itens utilizados na rotina automatica
Private cAliasAuto	:= ""							// Alias para identificar qual sera a rotina de atendimento para entrada automatica 

DEFAULT nOpcAuto 	:= 3							// nOpc para entrada automatica

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Protege rotina para que seja usada apenas no SIGATMK ou SIGACRM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !AmIIn(13,73)			// 13 = SIGATMK, 73 = SIGACRM
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui uma legenda para identificar chamados compartilhados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize(aCores1,Len(aCores1)+1)
aIns(aCores1,1)
aCores1[1] := {"!EMPTY(SUC->UC_CHAORIG)" , "BR_CINZA" } // Compartilhamento



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Combinações de entradas no atendimento call center,³
//³ e suas respectivas permissões de entrada.         ³
//³1. MDI                                             ³
//³1.1 Mesma máquina                                  ³
//³1.1.1 Mesmo usuário no mesmo processo: SIM         ³
//³1.1.2 Mesmo usuário em processos diferente: SIM    ³
//³1.2 Máquinas diferentes                            ³
//³1.2.1 Mesmo usuário em processos diferentes: SIM   ³
//³2. SDI                                             ³
//³2.1 Mesma máquina                                  ³
//³2.1.1 Mesmo usuário no mesmo processo: SIM         ³
//³2.1.2 Mesmo usuário em processos diferentes: SIM   ³
//³2.2 Máquinas diferentes                            ³
//³2.2.1 Mesmo usuário em processos diferentes: NÃO   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !SetMdiChild()
	If !ExcProcess( "TMK" + __cUserId )
		If ExcProcess( "TMK" + __cUserId + GetClientIP() )
			Help("  ",1,"TMKPROMDI")
			Return(lRet)
		EndIf
	Else
		ExcProcess( "TMK" + __cUserId + GetClientIP() )
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o tratamento para garantir a exclusividade na rotina de atualizacao do SK1³
//³somente se o operador tiver acessando TODAS as rotinas ou somente TELECOBRANCA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( cTipoAte == "3" ) .OR. ( cTipoAte == "4" )  		// Telecobranca ou Ambos
	ExcProcess("TMKSK1")
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o USUARIO nao estiver cadastrado em OPERADORES e nao tiver	³
//³um Posto de Venda associado nao entra na rotina					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !TMKOPERADOR()
	Help("  ",1,"OPERADOR")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o array com os precos da ultima tabela de preco usada - ³
//³Caso haja atualizacao da tabela de preco por outro Remote     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaReleTabPrc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTk271RotM
	aRotAdic := ExecBlock( "TK271ROTM", .F., .F. )
	If ValType(aRotAdic) <> "A"
		aRotAdic := {}
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para permitir a alteracao das cores de³
//³identificacao de linhas na mbrowse de acordo com o tipo³
//³de atendimento executado (1 a 3). Tipos 4 e 5 nao apre-³
//³sentam cores e legendas, dispensando a execucao do P.E.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lTk271Cor) .AND. (cTipoAte <= "3")
	aRetCor := U_TK271COR(cTipoAte)
	If (ValType(aRetCor) == "A") .AND. (Len(aRetCor) > 0)
		bBlockCor := &("{|aVet| aCores" + cTipoAte + " := aClone(aVet)}")
		Eval(bBlockCor,aRetCor)
	Endif
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz tratamento para chamada por entrada automatica  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
	Do Case
		Case VAL(cRotina) == TELEMARKETING
			If cTipoAte == "1" .OR. cTipoAte == "4" .OR. cTipoAte == "5"
				cAliasAuto:= "SUC"
			Endif
			
		Case VAL(cRotina) == TELEVENDAS
			If cTipoAte == "2" .OR. cTipoAte == "4".OR. cTipoAte == "5"
				cAliasAuto:= "SUA"
			Endif	

		Case VAL(cRotina) == TELECOBRANCA
			If cTipoAte == "3" .OR. cTipoAte == "4"
				cAliasAuto:= "ACF"
			Endif
			
		OtherWise
			cAliasAuto:= ""				
	Endcase

	If Empty(cAliasAuto)	
		Return(lRet)
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona rotinas recebidas pelo Ponto de Entrada ao aRotina  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTk271RotM
		// O limite de MENUS do usuario tem que ser menor que 3 porque o limite do Protheus sao 10
		If ValType(aRotAdic) == "A" .AND. ( Len(aRotAdic) < 3 ) 
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		Endif
	Endif
				
	aAutoCab 	:= xAutoCab
	aAutoItens 	:= xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),cAliasAuto)
	xAutoCab   := aAutoCab
	xAutoItens := aAutoItens	
    
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dependendo da opcao do Cadastro do Operador  exibe o browse do arquivo correspondente. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case (cTipoAte == "2") //Televendas
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona rotinas recebidas pelo Ponto de Entrada ao aRotina  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTk271RotM
				// O limite de MENUS do usuario tem que ser menor que 3 porque o limite do Protheus sao 10
				If ValType(aRotAdic) == "A" .AND. ( Len(aRotAdic) < 3 ) 
					AEval(aRotAdic,{|x| AAdd(aRotina,x)})
				Endif
			Endif
			
			cAlias		:= "SUA"
			cDescri	:= STR0249 //Televendas
			aCoresAtu	:= aCores2

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para filtrar a MBrowse ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTk271Fil
				TK271MFil( cAlias, @cFiltra, @aIndex )
			Endif
			
			If !lTk271Fil .AND. ExistBlock("TK271SQL")	// Filtro SQL na MBrowse
				cFilSQL := ExecBlock("TK271SQL",.F.,.F.,{cAlias})
			EndIf			

		Case (cTipoAte $ "13") //Se o tipo de atendimento do Operador estiver uma rotina ESPECIFICA - TMK ou TLC
							
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona rotinas recebidas pelo Ponto de Entrada ao aRotina  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTk271RotM
				// O limite de MENUS do usuario tem que ser menor que 3 porque o limite do Protheus sao 10
				If ValType(aRotAdic) == "A" .AND. ( Len(aRotAdic) < 3 ) 
					AEval(aRotAdic,{|x| AAdd(aRotina,x)})
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mostra o browse da rotina especifica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case (cTipoAte == "1") //Telemarketing        

					cAlias		:= "SUC"
					cDescri	:= STR0250 //Telemarketing
					aCoresAtu	:= aCores1
				
		   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de entrada para filtrar a MBrowse ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTk271Fil
						TK271MFil(cAlias, @cFiltra, @aIndex )
					Endif

					If !lTk271Fil .AND. ExistBlock("TK271SQL")	// Filtro SQL na MBrowse
						cFilSQL := ExecBlock("TK271SQL",.F.,.F.,{cAlias})
					EndIf			

				Case (cTipoAte == "3") //Telecobranca
				
					cAlias		:= "ACF"
					cDescri	:= STR0251 //Telecobranca
					aCoresAtu	:= aCores3			
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de entrada para filtrar a MBrowse ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTk271Fil
						TK271MFil(cAlias, @cFiltra, @aIndex )
					Endif

					If !lTk271Fil .AND. ExistBlock("TK271SQL")	// Filtro SQL na MBrowse
						cFilSQL := ExecBlock("TK271SQL",.F.,.F.,{cAlias})
					EndIf			
					
			EndCase
			
		Otherwise                                             
		
			If Empty(cTipoAte)
				Help(" ",1,"FALTA_OPER")
				Return(lRet)
			Endif	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a base for TOP e o usuário deletou o SXE a selecao dos alias e dos       ³
			//³indices e feita para garantir a sequencia correta dos numeros de atendimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SUC")
			DbSetOrder(1)
			DbSeek(xFilial("SUC"))
	
			DbSelectArea("SUA")
			DbSetOrder(1)
			DbSeek(xFilial("SUA"))
	
			DbSelectArea("ACF")
			DbSetOrder(1)
			DbSeek(xFilial("ACF"))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona rotinas recebidas pelo Ponto de Entrada ao aRotina  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTk271RotM
				// O limite de MENUS do usuario tem que ser menor que 3 porque o limite do Protheus sao 10
				If ValType(aRotAdic) == "A" .AND. ( Len(aRotAdic) < 3 ) 
					AEval(aRotAdic,{|x| AAdd(aRotina,x)})
				Endif
			Endif
			
			cAlias		:= "SU5"
			cDescri	:= STR0001
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para filtrar a MBrowse ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTk271Fil
				TK271MFil(cAlias, @cFiltra, @aIndex )
			Endif

			If !lTk271Fil .AND. ExistBlock("TK271SQL")	// Filtro SQL na MBrowse
				cFilSQL := ExecBlock("TK271SQL",.F.,.F.,{cAlias})
			EndIf			
			
	EndCase
Endif

If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Objeto FwMBrowse                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias(cAlias)
	oMBrowse:SetDescription(cDescri)  
	oMBrowse:SetAttach(.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona Legendas no Browse                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aCoresAtu)
		For nX := 1 To Len(aCoresAtu)
			oMBrowse:AddLegend(aCoresAtu[nX][1],aCoresAtu[nX][2]) 
		Next nX
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro Default do Browse                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cFilSQL )
		oMBrowse:SetFilterDefault( "@"+cFilSQL )
	EndIf
	
	//Se não for SIGACRM inibe a exibição do gráfico
	If nModulo <> 73
		oMBrowse:SetOpenChart( .F. )
	EndIf
	
	oMBrowse:Activate()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cFiltra ) .AND. Len( aIndex ) > 0
		EndFilBrw( cAlias, aIndex )
	Endif
EndIf

lRet := .T.
	
Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Cria array com rotinas do menu

@sample  MenuDef()

@param	  Nenhum

@return  aRotina - Array com rotinas do menu.  

@author  Jonatas Martins
@since   10/04/2015
@version 12.1.5
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local cRet := ""

If !Empty(FunName())  
	cRet := AllTrim(TkGetTipoAte())
EndIf

Do Case
	Case ( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
	
		aRotina	:= {{ STR0002  ,"AxPesqui"        ,0,1 },; 	//"Pesquisar"
						{ STR0007  ,"TK271CallCenter" ,0,2 },; 	//"Visualizar"
						{ STR0003  ,"TK271CallCenter" ,0,3 },; 	//"Incluir"
						{ STR0004  ,"TK271CallCenter" ,0,4 } } 	//"Alterar"
	
	Case cRet == "2"
	
		aRotina	:= {{ STR0002  ,"AxPesqui"        ,0,1 },; 	// "Pesquisar"
						{ STR0007  ,"TK271CallCenter" ,0,2 },; 	// "Visualizar"
						{ STR0003  ,"TK271CallCenter" ,0,3 },; 	// "Incluir"
						{ STR0004  ,"TK271CallCenter" ,0,4 },; 	// "Alterar"
						{ STR0064  ,"TK271Legenda"	  ,0,2 },; 	// "Legenda"
						{ STR0008  ,"TK271Copia"	  ,0,6 }    } 	// "Copiar"
						
	Case cRet $ "13"
	
		aRotina	:= {{ STR0002  ,"AxPesqui"        ,0,1 },; 	//"Pesquisar"
						{ STR0007  ,"TK271CallCenter" ,0,2 },; 	//Visualizar
						{ STR0003  ,"TK271CallCenter" ,0,3 },; 	//"Incluir"
						{ STR0004  ,"TK271CallCenter" ,0,4 },; 	//"Alterar"
						{ STR0064  ,"TK271Legenda"	  ,0,2 } }		//"Legenda" 

	OtherWise
		
		aRotina		:= {{ STR0002,"AxPesqui" 		,0,1 },; //"Pesquisar"
							{ STR0007,"AxVisual"   		,0,2 },; //Visualizar
							{ STR0049,"TK271CallCenter"	,0,3 } } //"Chamadas"
EndCase
	
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TK271CallCenter	  ³ Autor ³ Vendas Clientes       ³ Data ³ 11/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Telas principais dos Tres atendimento:                  				³±±
±±³          ³ 1 Folder = Telemarketing												³±±
±±³			 ³ 2 Folder = Televendas							    				³±±
±±³			 ³ 3 Folder = Telecobranca							    				³±±
±±³			 ³           										    				³±±
±±³			 ³ A tela precisa estar apta a trabalhar com 1 ou 3 folder simultaneos  ³±±
±±³			 ³ Ler os campos dos dicionarios de dados 								³±±
±±³			 ³ Manter a Tela compativel com a integracao de C.T.I.   				³±±
±±³			 ³ Nao ter vinculo com nenhuma rotina anterior ou posterior				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Call Center											  		    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Alias da tabela utilizada(SUA,SUC,ACF)                      ³±±
±±³          ³ ExpN02 - Numero do registro (RECNO) da tabela                        ³±±
±±³          ³ ExpN03 - Opcao selecionada de acordo com o vetor aRotina             ³±±
±±³          ³ ExpA04 - Campos da Enchoice                                          ³±±
±±³          ³ ExpC05 - Cliente informado pela CTI                                  ³±±
±±³          ³ ExpC06 - Loja informada pela CTI                                     ³±±
±±³          ³ ExpC07 - Contato informado pela CTI                                  ³±±
±±³          ³ ExpC08 - Entidade do contato informada pela CTI                      ³±±
±±³          ³ ExpA09 - Dados dos titulos de Telecobranca                           ³±±
±±³          ³ ExpC10 - Codigo da lista de cobranca                                 ³±±
±±³          ³ ExpL11 - Indicador de execucao remota (MsExecAuto)                   ³±±
±±³          ³ ExpC12 - Mensagem a Exibir na Observação                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK271CallCenter(	cAlias	,nReg		,nOpc		,aEnchoice	,;
							cCliCti ,cLojCti	,cContCti	,cEntCti	,;
							aTLC	,cAgenda	,lAuto, cMens)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Locais usadas no programa inteiro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea			:= GetArea()						// Salva a area atual
Local nCont			:= 0								// Contador	
Local nButton		:= 0								// Contador de botoes de usuario
Local aBtn			:= ARRAY(30)             			// Array para os botoes da CHOICEBAR - No padrao existem 19
Local oBtn			:= ARRAY(60)  						// Array com os botoes da barra Lateral - Considero 20 botoes para cada painel (TMK, TLV e TLC)
Local aAC			:= {STR0052,STR0053} 				// Usado nas Enchoices "Abandona","Confirma"
Local aBtnLat		:= {}								// Array para os botoes de usuario (P.E.)
Local aBtnSup		:= {}								// Array para os botoes de usuario (P.E.)
Local oBar			:= Nil			                    // Objeto para a toolbar
Local oMonoAs		:= TFont():New( "Courier New",6,0)	// Fonte para o campo Memo
Local oFnt1			:= TFont():New( "Times New Roman",13,26,,.T.)	// Fonte do cronometro
Local oDlg			:= Nil								// Objeto da tela principal
Local oFolderTMK	:= Nil								// Objeto que vai ser o casting do folder de TMK
Local oFolderTLV	:= Nil								// Objeto que vai ser o casting do folder de TLV
Local oFolderTLC	:= Nil 								// Objeto que vai ser o casting do folder de TLC
Local oFolder		:= Nil   							// Objeto que vai ser o casting do folder de TLV
Local oBarBmp		:= Nil								// Bitmap para a barra de botoes laterais
Local cCrono		:= "00:00"							// Cronometro da ligacao atual
Local oCrono		:= Nil		            			// Objeto da tela "00:00"
Local cTimeOut		:= "00:00"                        	// Time out do atendimento (Posto de venda)
Local nTimeSeg		:= 0                      			// Segundos do cronograma
Local nTimeMin		:= 0                      			// Minutos do cronograma
Local lKey			:= .T.								// Indica se as teclas de atalho F5..F10 pode ser executadas.
Local lHabilita		:= (nOpc <> 2)						// Habilita/desabilita o get dos objetos - VISUALIZACAO = FALSE
Local lTMKACTIVE	:= ExistBlock("TMKACTIVE")			// Ponto de Entrda apos o activate da tela                                 
Local lTMKCBPROT	:= FindFunction("T_TMKCBPRO")		// Ponto de entrada para a criacao de botoes de usuario na TOOLBAR SUPERIOR - Exclusivo uso para Templates
Local lTMKCBPRO		:= ExistBlock("TMKCBPRO")			// Ponto de entrada para a criacao de botoes de usuario na TOOLBAR SUPERIOR
Local lTMKBARLA		:= ExistBlock("TMKBARLA")			// Ponto de entrada para a criacao de botoes de usuario na TOOLBAR LATERAL
Local lTMKENTMK		:= FindFunction("P_TMKENTMK")		// Ponto de entrada para a manutenção da enchoice
Local lTk271Fil		:= ExistBlock("TK271FIL")			// Ponto de entrada para filtrar o Browse
Local aInfo			:= {}								// Informacoes para a divisao da area de trabalho
Local aObjects		:= {}								// Definicoes dos objetos
Local aPosObj1		:= {}								// Posicao dos Objetos oBarBmp e oFolder
Local aPosObj2		:= {}								// Posicao dos botoes da barra lateral
Local aPosObj3		:= {}								// Posicao dos Objetos oFolder e os objetos de historico
Local aPosObj4		:= {}								// Posicao dos Objetos de historico
Local aPosObj5		:= {}								// Array de posicoes da Enchoice Telemarketing, Televendas e Telecobranca
Local aPosObj6		:= {}								// Array de posicoes para exibicao permanente do nome do contato e da empresa
Local aPosGet		:= {}								// Array com as posicoes dos gets do rodape
Local aSize			:= MsAdvSize( .T., .F., 400)		// Size da Dialog
Local aSize2		:= {}								// Posicao com a area da barra lateral de botoes
Local aSize3		:= {}								// Area reservada para o folder e os objs de historico
Local aSize4		:= {}								// Area reservada para os objs de historico
Local aSize5		:= {}								// Area reservada para os objetos internos dos folders
Local aSize6		:= {}								// Area reservada para os objetos nome e contato do historico 
Local nSizeX		:= 0								// Tamanho da altura do folder
Local nSizeY		:= 0								// Tamanho da largura do folder
Local aColsTmk		:= {}								// CLONE do ACOLS utilizado na alteracao de atendimento TMK e na depois na gravacao
Local aColsTlv		:= {}								// CLONE do ACOLS utilizado na alteracao de atendimento TLV e na depois na gravacao
Local nAux			:= 0 								// Numero de BOTOES existentes no padrao para a barra LATERAL
Local lRet			:= .F.								// Retorno da funcao 	
Local aParScript	:= {}                             	// array com os dados do script executado para posterior gravacao
Local aCfgBtn		:= {}								// Array que define se o botao estara habilitado ou nao e contem tambem o numero do botao
Local aCfgBtnOri	:= {}								// Array com a situacao original de diponibilizacao dos botoes
Local nI			:= 0								// Utilizada em um laco
Local nBotao		:= 0								// Contem o numero do botao que sera inserido no array aCfgBtn
Local cTipo			:= ""								// Varivel auxilar para o tipo (Campo TIPO do SA1/SUS)
Local nBtnSoma		:= 0								// Incrementa a quantidade de botoes na lateral
Local cTitle		:= ""
Local cDlgTitle		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Locais usadas apenas no TELEMARKETING    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cEncerra   := ""                              //Descricao do motivo de encerramento - tabela
Local cMotivo    := ""		              			//Observao do motivo de encerramento - comentario	
Local oEnchTmk										//Enchoice para o telemarketing
Local cNumTmk    := IIF(nOpc == 3,"",SUC->UC_CODIGO)
Local aSx3SUC	 := {}								// Array com os campos do SUC para gravacao do Telemarkes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Locais usadas apenas no TELEVENDAS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nValorCC      := 0										// Total vendido em cartao de credito
Local aItens        := {}                     					// Array com as formas de pagamento - SX5 - TABELA 24
Local lMV_TMKFIS	:= IIf(Type("lTk271Auto") <> "U" .AND. lTk271Auto, .T., GetNewPar("MV_TMKFIS",.T.))				// (Não divulgar) Parametro que indica que a atualização da MATXFIS é feita de maneira on-line, no off-line a MATXFIS só é atualizada quando se entra na condição de pagamento.
Local aTitlesRodape	:= {If(lMV_TMKFIS,STR0005,STR0159),STR0006}	//"Totais" ou "Informações adicionais","Impostos"
Local aTitles	    := {}
Local aPages	    := {}
Local cCodPagto		:= CRIAVAR("E4_CODIGO",.F.),oCodPagto		// Codigo da condicao de pagamento
Local cDescPagto	:= "",oDescPagto								// Descricao da condicao de pagamento
Local nValNFat 		:= 0,oValNFat								// Valor dos itens que nao serao faturados
Local nLiquido 		:= 0,oLiquido								// Valor liquido do pedido inteiro
Local nEntrada 		:= 0,oEntrada								// Valor da entrada
Local aParcelas		:= {},oParcelas								// Array com os dados de cada parcela
Local nFinanciado	:= 0,oFinanciado								// Valor financiado de acordo com a condicao
Local nTxJuros		:= 0,oTxJuros 								// Valor percentual dos juros da condicao
Local nTxDescon		:= 0,oTxDescon      							// Valor percentual do desconto da condicao (financeiro)
Local nNumParcelas	:= 0,oNumParcelas							// Total de parcelas
Local nVlrPrazo     := 0,oVlrPrazo								// Valor do Total do pedido com a condicao
Local nVlJur  		:= 0										// Valor do Juro da condi‡ao de pagto. escolhida
Local cCodTransp	:= CRIAVAR("A4_COD",.F.),oCodTransp			// Codigo da transportadora
Local cTransp 		:= CRIAVAR("A4_NOME",.F.),oTransp			// Descricao da transportadora
Local cCob     		:= CRIAVAR("A1_ENDCOB",.F.),oCob        	// Endereco de Cobranca
Local cCidadeC 		:= CRIAVAR("A1_MUNC",.F.),oCidadeC      	// Cidade de Cobranca
Local cCepC    		:= CRIAVAR("A1_CEPC",.F.),oCepC				// Cep de Cobranca
Local cUfC     		:= SPACE(TamSxg("010")[1]),oUfC				// Estado de Cobranca
Local cBairroC 		:= CRIAVAR("A1_BAIRROC",.F.),oBairroC		// Bairro de Cobranca
Local cEnt     		:= CRIAVAR("A1_ENDENT",.F.),oEnt			// Endereco de Entrega
Local cCidadeE 		:= CRIAVAR("A1_MUNE",.F.),oCidadeE      	// Cidade de Entrega
Local cCepE    		:= CRIAVAR("A1_CEPE",.F.),oCepE 			// Cep de Entrega
Local cUfE     		:= SPACE(TamSxg("010")[1]),oUfE				// Estado de Entrega
Local cBairroE 		:= CRIAVAR("A1_BAIRROE",.F.),oBairroE		// Bairro de Entrega
Local oEnchTlv
Local cNumTlv   	:= IIF(nOpc == 3,"",SUA->UA_NUM)
Local cDesconto 	:= ""										// Variavel de auxilio para receber o tipo de desconto definido no posto de venda.
Local cCodAnt   	:= ""										// Flag para controle da alteracao da condicao de pagamento para nao apagar os detalhes da parcela.
Local cCliAnt		:= ""
Local lTipo9		:= .F.										// Flag para controle da venda tipo 9 - para alteracao das parcelas	
Local aSx3SUA		:= {}										// Array com os campos do SUA para gravacao do Televendas
Local cEstacao		:= ""										// Estacao indicada no cadastro de grupo de atendimento
Local lExibeHelp	:= .T.										// Flag que indica se o HELP de campo OBRIGATORIO sera exibido na limpeza de tela - para os campos obrigatorios nao preenchidos	
Local lTK271Abr		:= ExistBlock("TK271ABR")					// Controle de ponto de entrada
Local lMsg 			:= .T. 										// Flag para exibir ou nao a mensagem de confirmacao da tela 		
Local lCpCompart	:= SUC->(ColumnPos("UC_CHAORIG")) > 0		// Controla a exibicao do botao de chamados compartilhados
Local aAtalho		:= {}										// Teclas de atalho bara a enchoicebar (versao 11 e acima)
Local aRotxAtalho	:= {}
Local cLock      := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Locais usadas apenas no TELECOBRANCA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oEnchTlc													//Enchoice de Telecobranca
Local cNumTlc   := IIF(nOpc == 3,"",ACF->ACF_CODIGO)			//Numero do atendimento de cobranca
Local aCampACF	:= {}											// Valores totais do radape
Local aSX3ACF	:= {}											//Array com os campos do ACF para utilizar no envio de e-mail Telecobranca

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia se o Atendimento foi chamado a partir do Tmka380.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local l380 		:= (Upper(FUNNAME()) == "TMKA380")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para posicionamento do SU7-operador para a configuracao dos botoes de tela.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAliOld		:= ""										// Alias anterior para restaura-lo apos pesquisa.
Local lNotOper		:= .F.										// Identifica se o operador foi encontrado. True=Nao localizado. False=Localizado.
Local lBotao		:= .T.										// Flag para exibir os botoes de COPIAR/COLAR 
Local aUser			:= {}										//Retorno da busca do Responsavel (Usuario do SIGACFG)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag para indicar se exibira mensagem ao realizar a limpeza da tela. Utilizado no ponto de entrada TMKLIMPA.     ³
//³Essa variavel e criada nesse momento como False para passagem de parametro na funcao Tklimpa apos o cancelamento.³
//³Nas situacoes de Cancelamento e Gravacao o parametro e passado como False para nao exibir a mensagem.			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lExibeMsg	 	:= .F.							
Local lSigaCRD		:= .F.										// Indica se o operador utiliza o SIGACRD para realizar a analise de credito

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para controle dos paineis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oPanelTmk
Local oPanelTlv
Local oPanelTlc
Local aResol 		:= {}										// Array com a resolucao da tela do cliente
Local oEnchAux													// Enchoice auxiliar para casting da enchoice ativa	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis usadas em Integracoes                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lIntQLY := GetMv("MV_QLYXCAL",.F.,.F.)==.T.    			//Define a Integração entre os  ambientes  do Quality e CallCenter     
Local lPls	  := GetNewPar("MV_PLSATIV",.F.)					//Define se existe a integração com o Módulo de Planos de Saúde
Local lPriContato := .T.										// Se é o primeiro contato (Usado para desabilitar o cancelamento da tela quando o atendimento foi aberto pela agenda do operador, obrigando assim que o primeiro contato da agenda do operador seja efetuado. Após o primeiro contato ser atendido, esse variável é usada para voltar a habilitar o cancelamento)
Local lTK271TpCl	:= FindFunction("P_TK271TCL")				//Retorn tipo do cliente para simulação fiscal
Local lTKTipCli	:= ExistBlock("TKTIPCLI")				    	//Ponto de entrada que permita customizar gravação do tipo decliente no pedido de vendas.
Local aFieldsSUC := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acoes executadas pelos botoes superiores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bLimpa	:= Nil											// Limpa o chamado
Local bCancelCh	:= Nil											// Cancela o chamado
Local bMktAtv	:= Nil											// Marketing ativo
Local bEnvTar	:= Nil											// Enviar tarefa
Local bScrCamp	:= Nil											// Script de campanha
Local bAltEnt	:= Nil											// Altera entidade
Local bHistLig	:= Nil											// Historico de ligacoes
Local bSituFin	:= Nil											// Situacao financeira
Local bCadCont	:= Nil											// Cadastro de contatos
Local bBcoConh	:= Nil											// Banco de conhecimentos
Local bTracker	:= Nil											// Tracker
Local bVisEvent	:= Nil											// Visualiza eventos
Local bPerfil	:= Nil											// Perfil do contato
Local bOk		:= Nil											// Confirmacao do atendimento
Local bCancel	:= Nil											// Cancela atendimento
Local cFiltra	:= ""
Local aIndex	:= {}
Local cNaturez	:= ""
Local nPosSit	:= 0
Local lCliEntreg:= SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0
//Efetua carga de campos sensiveis/pessoais
Local aPDFields := {"A1_NOME","U5_CONTAT","U7_NOME"}
Local nX 		:= 0
Local lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1"

Default cMens := ""

Private aVldBlock 	:= {}										// Armazenar os blocos de codigo que serao executados para cada Get Fixo - utilizado na rotina automatica 
Private aValidGet 	:= {}										// Contem todos os Gets Fixos que devem ser atualizados na rotina de entrada automatica

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Private usadas no programa inteiro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oGetTmk									   				// MsGetdados do TELEMARKETING
Private oGetTLV							                   		// Usado na MsGetdados do TELEVENDAS
Private oGetTlc							                   		// Usado na MsGetdados do TELECOBRANCA
Private nFolder := 1						   					// Folder que esta ativo atualmente
Private aValores:= {0,0,0,0,0,0,0,0}         					// Array com os valores dos objetos utilizados no Folder do rodape
Private aObj[8]							  						// Array com os objetos utilizados no Folder do rodape
Private oTimerCro												// objeto cronometro
Private cTimeIni	:= ""						   				// Hora do inicio do atendimento
Private aCampos  	:= {}						        		// array com os campos do SUB/SUD usado na getdados para determinar a pos. relativa
Private aPosicoesV  := {}				    					// Usado no Valid SX3 para Televendas
Private aPosicoesM  := {}				    					// Usado no Valid SX3 para TeleMarketing
Private aPosicoesC  := {}				    					// Usado no Valid SX3 para TeleCobranca
Private lProspect	:= .F.										// Flag que indica se o contato e de um prospct ou se foi selecionado um prospect do SUS
Private oLigacao	
Private cLigacao	:=""										// Ultima ligacao do cliente selecionado
Private oOperador
Private cOperador	:=""                    					// Ultimo operador que falou com o cliente selecionado
Private oStatus
Private cStatus	    :=""										// Status da ultima ligacao do cliente
Private oOperacao
Private cOperacao	:=""										// Operacao do televendas.
Private oProximo
Private cProximo	:=""										// Data da proxima ligacao para esse cliente
Private oNomeHist
Private cNomeHist	:=""										// Nome completo da entidade selecionada no atendimento
Private oContHist
Private cContHist	:=""										// Nome completo do contato selecionado no atendimento


Private aPosicoes:= {}				    	   					// Usado no Valid SX3
Private aHeader := {},aCols := {}
Private oFoldRodape												// Folder do Rodape
Private aColsEdit := {}											// aCols que será utilizada quando for edição por linha na MsGetDados.

Private bDoRefresh		:= {|| NIL } 																									// Efetua o Refresh da Tela de Dados Financeiros
Private bFolderRefresh	:= {|| (IIf(!lTk271Auto,Tk273FRefresh(),""))}																	// Efetua o Refresh do Folder
Private bGDRefresh		:= {|| (IIf(!lTk271Auto,oGetTlv:oBrowse:Refresh(),"")) }														// Efetua o Refresh da GetDados
Private bRefresh		:= {|| (IIf(!lTk271Auto,((Tk273Refresh()),(Eval(bFolderRefresh)),Eval(bDoRefresh)),Tk273Refresh()))}	    	// Efetua o Refresh da NF
Private bListRefresh	:= {|| (MaFisToCols(aHeader,aCols,,"TMK271"),IIf(!lTk271Auto,(Eval(bRefresh),Eval(bGdRefresh)),""))}			// Carrega os valores da Funcao fiscal e executa o Refresh
Private aParcTef        := {} 									// Array com as parcelas para o TEF
Private aTefDados       := {} 									// Array com os dados retornados pelo TEF
Private cGaranCh        := ""								    // Garantia de Cheque Via Tef
Private lDesconto		:= .T.									// Flag para habilitar o preenchimento do desconto no rodape	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private usadas apenas no TELEVENDAS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private	nMoedaCor	:= 1                                		// Moeda da venda
Private oPgtosSint												// Contem as parcelas de pagamento sintetizadas
Private lVisuSint		:= .T.	 	//Indica se a interface utilizara a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Private aPgtosSint	:= { {Space(02),0,TransForm(0,PesqPict("SL4","L4_VALOR",,nMoedaCor)),Space(TamSX3("L4_FORMAID")[1]),Ctod(Space(8)),{}} } // Array para o objeto oPgtosSint
Private lCondBlq		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Private usadas apenas no TELECOBRANCA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRdpTlc		:= Array(12,2)

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields,"TMKA271")
//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//	³ Matriz aSvFolder 					³
//	³									³
//	³- Telemarketing        			³
//	³ [1][1] aHeader GetDados Tmk		³
//	³ [1][2] aCols GetDados Tmk			³
//	³ [1][3] n GetDados Tmk				³
//	³									³
//	³- Televendas           			³
//	³ [2][1] aHeader GetDados Tlv		³
//  ³ [2][2] aCols GetDados Tlv  	   	³
//	³ [2][3] n GetDados Tlv				³
//	³									³
//	³- Telecobranca           			³
//	³ [3][1] aHeader GetDados Tlc		³
//  ³ [3][2] aCols GetDados Tlc  	   	³
//	³ [3][3] n GetDados Tlc				³
//	³									³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aSvFolder:= {}
Private lAltTpOper 	:= .T.										//Na inicializacao o DEFAULT e sempre TRUE	
Private lTesTit	 	:= .F.										//Flag que indica se os TES escolhidos vao gera titulos ou NAO - inicializa com .F. para evitar conflitos com customizacoes externas

Private lTMKLIMPA	:= ExistBlock("TMKLIMPA")				// Flag Para validar se existe o P.E. TMKLIMPA
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Permite que o Sistema nao teste duas vezes o TEF na entrada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static lPrimAviso 	:= .F.

Private aButBar		:= {}								// Botoes da versao 11 em diante

Default lAuto 		:= .F.										// Se a flag de entrada automatica nao foi informada, assume .F.	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a chamada da tela de atendimento foi feita por qualquer outra rotina, que nao      ³
//³tenha sido pelo TMKA271 como por exemplo: Agenda do Operador, Atendimento Receptivo,  ³         
//³Pre-Atendimento ou ate o MATA410 (Pedidos) a variavel lTk271auto nao foi inicializada,³
//³por essa razao inicializo como .F. quando nao estiver utilizando entrada automatica.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto
	If Type("lTk271Auto") == "U"
		Private lTk271Auto := .F.
	Endif	
Endif	

// Se o operador estiver configurado somente para televendas e for alteração, verifica se não esta bloqueado
If cAlias == "SUA" .And. nOpc == 4
	If !LockByName("SUA"+xFilial("SUA")+cNumTlv,.T.,FWModeAccess("SUA",3) == "E",.T.)
		MsgAlert(OemToAnsi(STR0219))
		Return(.F.)
	Else
		cLock := "SUA"+xFilial("SUA")+cNumTlv
	EndIf
ElseIf cAlias == "SUC" .And. nOpc == 4
	If !LockByName("SUC"+xFilial("SUC")+cNumTmk,.T.,FWModeAccess("SUC",3) == "E",.T.)
		MsgAlert(OemToAnsi(STR0219))
		Return(.F.)
	Else
		cLock := "SUC"+xFilial("SUC")+cNumTmk
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sempre inicializa as variaveis aGets aTela para exibir os dados da enchoice.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]
Private aTELA1[0][0],aGETS1[0]
Private aTELA2[0][0],aGETS2[0]
Private aTELA3[0][0],aGETS3[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define os valores padroes para os parametros recebidos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default aTLC		:= {}                                      //Array que contem os dados dos titulos de Telecobranca para prenchimento na tela de atendimento
Default cAgenda		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Devolve o tamanho da tela (coordenadas)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aResol:= If(!lTk271Auto, GetScreenRes(), {} )	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 25 (ACS), verifica se o usu rio poder   ³
//³ ou n„o efetuar um Atendimento. 					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkPsw(25)
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para possibilitar alteracao/inclusao/exclusao de atendimento.|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK271Abr
	lTK271Abr := ExecBlock("TK271ABR",.F.,.F.,{nOpc} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Protecao para retorno do ponto de entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Valtype(lTK271Abr) == "L"
		If !lTK271Abr
			Return(.F.)
		EndIf
	Endif
		
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente se o OPERADOR estiver configurado para usar as rotinas de TELEVENDAS,TODOS E TMK x TLV³ 
//³verifica se ele existe no SA3 - Vendedores                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (TkGetTipoAte() $ "245") 
	If !TK273OperVend()
		Help(" ", 1, "VENDEDOR")
		Return(lRet)
	Endif
Endif

if lIntQLY
	If !QNCMSGERA(STR0101,1)  //"Verificar parametros referentes a integracao com o QNC (Controle de Nao Conformidades)"
		Return(lRet)   
	Endif
EndIf
	
CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificacao do parametro MV_OPFAT para vendas com Tef. Se a estacao utiizar TEF o parametro deve estar preenchido com "S" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaTef  .AND. !lPrimAviso
	If (Alltrim(SuperGetMv( "MV_OPFAT")) <> "S")
		Help(" ",1,"ERRO_OPFAT")
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Comando de abertura do TEF. Este verifica se o TEF esta ativo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Loja010T( "A" )
	lPrimAviso := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo de TELA (SDI/MDI) e a resolucao da tela para exibicao dos botoes da toolbar superior³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SetMDIChild() 
	If oMainWnd:nWidth < 1020
	   lBotao := .F.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa aSvFolder³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aSvFolder,{{},{},1})
Aadd(aSvFolder,{{},{},1})
Aadd(aSvFolder,{{},{},1})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega nomes dos Folders de acordo com o Posto de venda    					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TkGetTipoAte() == "1"  			// Telemarketing
	aTitles	:= 	{STR0029}
	aPages	:= {"HEADER"}
Elseif TkGetTipoAte() == "2" 		// Televendas
	aTitles	:= {STR0030}
	aPages	:= {"HEADER"}
Elseif TkGetTipoAte() == "3" 		//"Telecobranca"
	aTitles	:= {STR0050}
	aPages	:= {"HEADER"}
Elseif TkGetTipoAte() == "4" 		// Ambos
	aTitles	:= {STR0029,STR0030,STR0050}
	aPages	:= {"HEADER","HEADER","HEADER"}
Elseif TkGetTipoAte() == "5" 		// TMK x TLV
	aTitles	:= {STR0029,STR0030}
	aPages	:= {"HEADER","HEADER"}
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando for entrada automatica inicializa as configuracoes do atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTk271Auto
	If cAlias == "SUC"
		nFolder := 1
	Endif
	If cAlias == "SUA"
		nFolder := 2
	Endif
	If cAlias == "ACF"
		nFolder := 3
	Endif
Endif

If nFolder == 1 
	If (TkGetTipoAte() $ "1") //Telemarketing
		// Carrega os campos para gravacao do SUC
		aSx3SUC := Tk273Sx3("SUC")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Configura‡ao da GetDados - Folder 01 Telemarketing   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := TK271Config(	"SUD"	,"UD_CODIGO"	,nOpc	,cNumTmk	,;
								cNumTlv	,cNumTlc		)

	ElseIf (TkGetTipoAte() == "2") //Televendas
		
		// Carrega os campos para gravacao do SUA
		aSx3SUA := Tk273Sx3("SUA") 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Configura‡ao da GetDados - Folder 02 Televendas		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := Tk271Config(	"SUB"	,"UB_NUM"	,nOpc	,cNumTmk	,;
								cNumTlv	,cNumTlc	)
		
	ElseIf (TkGetTipoAte() == "3") //Telecobranca
		
		// Carrega os campos para utilizar no envio de e-mail Telecobranca
		aSx3ACF := Tk273Sx3("ACF") 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Configura‡ao da GetDados - Folder 03 Telecobranca    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := Tk271Config(	"ACG"	,"ACG_CODIGO"	,nOpc	,cNumTmk	,;
								cNumTlv	,cNumTlc		)
		                               
	ElseIf (TkGetTipoAte() == "4")  // Ambos

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando for entrada automatica inicializa as configuracoes do atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTk271Auto
			Do case
				case nFolder == 1
					// Carrega os campos para gravacao do SUC
					aSx3SUC := Tk273Sx3("SUC")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Configura‡ao da GetDados - Folder 01 Telemarketing   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := TK271Config(	"SUD"	,"UD_CODIGO"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc		)

				case nFolder == 2
					// Carrega os campos para gravacao do SUA
					aSx3SUA := Tk273Sx3("SUA")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Configura‡ao da GetDados - Folder 02 Televendas		 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := Tk271Config(	"SUB"	,"UB_NUM"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc	)

				case nFolder == 3
					// Carrega os campos para gravacao do ACF
					aSx3ACF := Tk273Sx3("ACF") 

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Configura‡ao da GetDados - Folder 03 Telecobranca	 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := Tk271Config(	"ACG"	,"ACG_CODIGO"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc		)
			EndCase
		Else
		
			// Carrega os campos para gravacao do SUC
			aSx3SUC := Tk273Sx3("SUC")
	
			// Carrega os campos para gravacao do SUA
			aSx3SUA := Tk273Sx3("SUA")
	
			// Carrega os campos para utilizar no envio de e-mail Telecobranca
			aSx3ACF := Tk273Sx3("ACF") 
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Configura‡ao da GetDados - Folder 01 Telemarketing   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (lRet := TK271Config(	"SUD"	,"UD_CODIGO"	,nOpc	,cNumTmk	,;
										cNumTlv	,cNumTlc		))
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Configura‡ao da GetDados - Folder 02 Televendas		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (lRet := Tk271Config(	"SUB"	,"UB_NUM"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc	))
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Configura‡ao da GetDados - Folder 03 Telecobranca    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := Tk271Config(	"ACG"	,"ACG_CODIGO"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc		)
				Endif

			Endif
		Endif	

	ElseIf (TkGetTipoAte() == "5")  // TMK x TLV

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando for entrada automatica inicializa as configuracoes do atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTk271Auto
			Do case
				case nFolder == 1
					// Carrega os campos para gravacao do SUC
					aSx3SUC := Tk273Sx3("SUC")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Configura‡ao da GetDados - Folder 01 Telemarketing   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := TK271Config(	"SUD"	,"UD_CODIGO"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc		)
		
				
				case nFolder == 2
					// Carrega os campos para gravacao do SUA
					aSx3SUA := Tk273Sx3("SUA")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Configura‡ao da GetDados - Folder 02 Televendas		 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := Tk271Config(	"SUB"	,"UB_NUM"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc	)

				case nFolder == 3
					// Carrega os campos para gravacao do ACF
					aSx3ACF := Tk273Sx3("ACF") 

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Configura‡ao da GetDados - Folder 03 Telecobranca	 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := Tk271Config(	"ACG"	,"ACG_CODIGO"	,nOpc	,cNumTmk	,;
											cNumTlv	,cNumTlc		)
			Endcase	

		Else
		
			// Carrega os campos para gravacao do SUC
			aSx3SUC := Tk273Sx3("SUC")
	
			// Carrega os campos para gravacao do SUA
			aSx3SUA := Tk273Sx3("SUA")
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Configura‡ao da GetDados - Folder 01 Telemarketing   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (lRet := TK271Config(	"SUD"	,"UD_CODIGO"	,nOpc	,cNumTmk	,;
										cNumTlv	,cNumTlc		))
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Configura‡ao da GetDados - Folder 02 Televendas		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lRet := Tk271Config(	"SUB"	,"UB_NUM"	,nOpc	,cNumTmk	,;
										cNumTlv	,cNumTlc	)
			Endif
		Endif
			
	Endif                           
	
ElseIf (nFolder == 2) //Televendas 

	// Carrega os campos para gravacao do SUA
	aSx3SUA := Tk273Sx3("SUA")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Na alteracao inicializa as funcoes fiscais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4 .OR. nOpc == 2 
		lProspect := SUA->UA_PROSPEC
		cNaturez  := Tk273DpNat(SUA->UA_CLIENTE,SUA->UA_LOJA)
		If lProspect
			cTipo := Posicione("SUS",1,xFilial("SUS") + SUA->UA_CLIENTE + SUA->UA_LOJA,"US_TIPO")
		Else		
			cTipo := Posicione("SA1",1,xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,"A1_TIPO")
		Endif	

		If lTK271TpCl
			cTipo := P_TK271TCL()
		ElseIf lTKTipCli 
 			cTipo := U_TKTIPCLI(cTipo)    
		Else
		   	cTipo := SUA->UA_TIPOCLI
		EndIf	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa os dados do cliente na FUNCAO FISCAL³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisIni(IIF(lCliEntreg .And. !lProspect,SUA->UA_CLIENT,SUA->UA_CLIENTE),;	// 1-Codigo Cliente/Fornecedor
				 IIF(lCliEntreg .And. !lProspect,SUA->UA_LOJAENT,SUA->UA_LOJA),;	// 2-Loja do Cliente/Fornecedor
				 "C",;											// 3-C:Cliente , F:Fornecedor
				 "N",;											// 4-Tipo da NF
				 cTipo,;										// 5-Tipo do Cliente/Fornecedor
				 Nil,;											// 6-Relacao de Impostos que suportados no arquivo
				 Nil,;											// 7-Tipo de complemento
				 Nil,;											// 8-Permite Incluir Impostos no Rodape .T./.F.
				 Nil,;											// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
				 "MATA461",;									// 10-Nome da rotina que esta utilizando a funcao
				 Nil,;											// 11-Tipo de documento
				 Nil,;  										// 12-Especie do documento 
			     IIF(lProspect,SUA->UA_CLIENTE+SUA->UA_LOJA,""))// 13- Codigo e Loja do Prospect
		
		If !Empty(cNaturez)
			MaFisAlt("NF_NATUREZA",cNaturez)
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡ao da GetDados - Folder 02 Televendas		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := Tk271Config(	"SUB"	,"UB_NUM"	,nOpc	,cNumTmk	,;
							cNumTlv	,cNumTlc	)
	
ElseIf (nFolder == 3) //Telecobranca 
	
	// Carrega os campos para utilizar no envio de e-mail Telecobranca
	aSx3ACF := Tk273Sx3("ACF") 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡ao da GetDados - Folder 03 Telecobranca    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := Tk271Config(	"ACG"	,"ACG_CODIGO"	,nOpc	,cNumTmk	,;
							cNumTlv	,cNumTlc		)
Endif

If !lRet
	// Indica que nao foi possivel criar a getdados da rotina de atendimento 
	If !lTk271Auto
		Help(" ",1,"TMKMODULO" )
	Endif	
	Return(lRet)
Endif 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ARRAY ASIZE - Tamanho da Dialog e Area de Trabalho										 ³
³	1 - Linha inicial area trabalho 													 ³
³	2 - Coluna inicial area trabalho													 ³
³	3 - Linha final area trabalho														 ³
³	4 - Coluna final area trabalho														 ³
³	5 - Coluna final dialog																 ³
³	6 - Linha final dialog																 ³
³	7 - Linha inicial dialog															 ³
³																						 ³
³ARRAY AOBJECTS - Tamanho "Default" dos Objetos para o calculo das posicoes				 ³
³	1 - Tamanho X																		 ³	
³	2 - Tamanho Y																		 ³
³	3 - Dimensiona X																	 ³
³	4 - Dimensiona Y																	 ³
³	5 - Retorna dimensoes X e Y (SIZE) ao inves de linha / coluna final					 ³
³																						 ³
³ARRAY AINFO - Tamanho da "Area" onde sera calculado as posicoes dos objetos			 ³
³	1 - Posicao Inicial X																 ³
³	2 - Posicao Inicial Y																 ³
³	3 - Posicao Final X																	 ³
³	4 - Posicao Final Y																	 ³
³	5 - Espaco lateralmente entre os objetos											 ³
³	6 - Espaco verticalmente entre os objetos											 ³
³																						 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

aObjects := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divide a tela lateralmente para o objetos oBarBmp         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aObjects, { 19,  225, .F., .F. , .T.} )  //19 Largura , 225 Comprimento , recalcula 1 area, recalcula 2 area, proporcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divide a tela lateralmente para o objetos oFolder         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aObjects, { 100, 100, .T., .T. } )	   //Folder 100 largura, 100 Comprimento	 	

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj1    := MsObjSize( aInfo, aObjects,  , .T. )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o operador e Carrega o array com as validacoes dos botoes da toolbar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Salva alias atual
cAliOld := Alias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o usuario no cadastro de operadores					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU7")
DbSetOrder(4)
If !DbSeek(xFilial("SU7") + __cUserId) // Nome completo
	lNotOper := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o operador realiza analise de credito atraves do SIGACRD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SU7->(ColumnPos("U7_ESTACAO")) > 0 .AND. !Empty(SU7->U7_ESTACAO)
	cEstacao:= TkPosto(SU7->U7_COD,"U7_ESTACAO")	//Pega o codigo da ESTACAO do OPERADOR
Else
	cEstacao:= TkPosto(SU7->U7_COD,"U0_ESTACAO") //Pega o codigo da ESTACAO do GRUPO DE ATENDIMENTO
EndIf

If !Empty(cEstacao)
	DbSelectArea("SLG")
	DbSetOrder(1)
	If DbSeek(xFilial("SLG")+cEstacao)
		If LG_CRDXINT == "1"	//Sim
			lSigaCrd:= .T.
			Tk273SetCred()
		Endif	
	Endif
Endif
	
If lSigaCRD .AND. nOpc == 4
   Tk273SetContra()
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega array com os acessos que o operador ja tem configurado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SU7->U7_CFGBTN) .AND. !lNotOper 
	For nI := 1 TO Len(SU7->U7_CFGBTN)+2	//tirar isso
		AAdd( aCfgBtn, {(SubStr(SU7->U7_CFGBTN,nI,1) == "1" .OR. Empty(SubStr(SU7->U7_CFGBTN,nI,1))),Nil} )
	Next nI
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Assume que todos os botoes estarao habilitados se ainda nao foram configurados no cadastro de operadores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 TO Len(SU7->U7_CFGBTN)+2
		AAdd(aCfgBtn,{.T.,Nil})
	Next nI
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o array com o numero dos Botoes Telemarketing ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:= 19 to 24
	nBotao++
	aCfgBtn[nI][2] :=nBotao
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o array com o numero dos Botoes Televendas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBotao:=0
For nI:= 25 to Len(SU7->U7_CFGBTN)+2
	nBotao++
	aCfgBtn[nI][2] :=nBotao
Next nI

aCfgBtnOri := aClone(aCfgBtn)

DbSelectArea(cAliOld)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver utilizando a rotina de entrada automatica monta a tela de atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !( Type("lTk271Auto") <> "U" .AND. lTk271Auto )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para a criacao de botoes de usuario na TOOLBAR LATERAL  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMKBARLA
		aBtnLat := U_TMKBARLA(@aBtnLat,@aTitles)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para a criacao de botoes de usuario na TOOLBAR SUPERIOR ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para uso em Templates									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMKCBPROT
		aBtnSup := T_TMKCBPRO(aBtnSup)
	Endif
	If lTMKCBPRO
		aBtnSup := U_TMKCBPRO(aBtnSup)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informa ao gerenciador de múltiplos grupos de atendimento³
	//³que a rotina call center está em execução.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
  	TK091Start( CALLCENTER )   		

	cCadastro := STR0001
	
	cDlgTitle := STR0001 + " - " + TK091Titulo(TkOperador()) 
	
	If (TkGetTipoAte() $ "123")
		If nOpc == 2
			cTitle := " - " + Upper(STR0007)	//"Visualizar"
		ElseIf nOpc == 3
			cTitle := " - " + Upper(STR0003)	//"Incluir"
		ElseIf nOpc == 4
			cTitle := " - " + Upper(STR0004)	//"Alterar"
		EndIf
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE cDlgTitle + cTitle FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Atendimento"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criando a divisao na tela da barra lateral para que nao utilizem esse espaco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		For nButton:= 1 To ( 30+Len(aBtnLat) )  			 //"20" Botoes do sistema + "n" Botoes do usuario
			Aadd( aObjects, { 26,  26, .F., .F., .T. } ) 	 //Tamanho do RESOURCE na AP6CONN.DLL
		Next nButton 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Divide a tela verticalmente para os botoes da barra lateral  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize2   := aPosObj1[1]
		aInfo    := { aSize2[ 2 ]+4, aSize2[ 1 ]+35 , aSize2[ 4 ], aSize2[ 3 ], 0, 0 } //(1,Inicio Linha,3,4,5)
		aPosObj2 := MsObjSize( aInfo, aObjects, .F. , .F. )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao dos tres paineis com coordenadas Zero e alinhamento no topo da tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@0,0 MSPANEL oPanelTmk SIZE aPosObj1[1,3],aPosObj1[2,3]-11 OF oDlg
		
		@0,0 MSPANEL oPanelTlv SIZE aPosObj1[1,3],aPosObj1[2,3]-11 OF oDlg

		@0,0 MSPANEL oPanelTlc SIZE aPosObj1[1,3],aPosObj1[2,3]-11 OF oDlg

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Botoes do Telemarketing                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@aPosObj2[1,1],aPosObj2[1,2] BTNBMP oBtn[1] RESOURCE "SALVAR" SIZE aPosObj2[1,3] ,aPosObj2[1,4] When aCfgBtn[19][1] OF oPanelTmk PIXEL MESSAGE STR0042 ;//"Encerramento"
		ACTION Tk272Encerra(.T.,M->UC_CODIGO,cEncerra,cMotivo,"1")  
	
		@aPosObj2[2,1],aPosObj2[2,2] BTNBMP oBtn[2] RESOURCE "ICONE"  SIZE aPosObj2[2,3] ,aPosObj2[2,4] When aCfgBtn[20][1] OF oPanelTmk PIXEL MESSAGE STR0058;	//"Chamado Tecnico"
		ACTION 	TkTransfer(		1				,@nOpc			,@oFolderTmk	,@oEnchTmk		,;
								@cEncerra		,@cMotivo		,@oFolderTlv	,@oEnchTlv		,;
								@cCodPagto		,@cDescPagto	,@cCodTransp	,@cTransp		,;
								@cCob			,@cEnt			,@cCidadeC		,@cCepC			,;
								@cUfC			,@cBairroE		,@cBairroC		,@cCidadeE		,;
								@cCepE			,@cUfE			,@nLiquido		,@nTxJuros		,;
								@nTxDescon		,@nVlJur		,@aParcelas		,@nEntrada		,;
								@nFinanciado	,@nNumParcelas	,@nValorCC		,@oCrono		,;
								@cCrono			,@nTimeSeg		,@nTimeMin      ,@lHabilita		,;
								@oFolderTlc		,@oEnchTlc		,aColsTmk       ,aColsTlv		,;
								@oDlg       	,NIL            ,aParScript		,l380			,;
								@lMsg			,aSx3SUA		,cAgenda		,nValNFat		,;
								aSx3SUC			,@aItens		,oCodPagto		,@oDescPagto	,;
								@oCodTransp		,@oTransp		,@oCob			,@oEnt			,;
								@oCidadeC		,@oUfC			,@oBairroE		,@oCepC			,;
								@oCidadeE		,@oBairroC		,@cCidadeE		,@oCepE			,;
								@oUfE			,@oLiquido		,@nTxJuros		,@oTxJuros		,;
								@oTxDescon		,@oParcelas		,@oEntrada		,@oFinanciado	,;
								@oNumParcelas	,@lTipo9		,@oValNFat		,lSigaCRD)
	
		@aPosObj2[3,1],aPosObj2[3,2] BTNBMP oBtn[3] RESOURCE "BMPEMERG" SIZE aPosObj2[3,3] ,aPosObj2[3,4] When aCfgBtn[21][1] OF oPanelTmk PIXEL MESSAGE STR0021 ;//"Ligacoes Pendentes"
		ACTION 	Tk272LigPend(@nOpc,@lHabilita,@oFolderTmk,@oEnchTmk,@cLock )
	
		@aPosObj2[4,1],aPosObj2[4,2] BTNBMP oBtn[4] RESOURCE "NOTE" SIZE aPosObj2[4,3],aPosObj2[4,4] When aCfgBtn[22][1] OF oPanelTmk PIXEL MESSAGE STR0026; //"Cadastro do Produto"
		ACTION TkProduto()
		
		@aPosObj2[5,1],aPosObj2[5,2] BTNBMP oBtn[5] RESOURCE "relatorio" SIZE aPosObj2[5,3],aPosObj2[5,4] When aCfgBtn[23][1] OF oPanelTmk PIXEL MESSAGE STR0027; //"Cadastro de Concorrentes"
		ACTION TkConcorrente()
		
		@aPosObj2[6,1],aPosObj2[6,2] BTNBMP oBtn[6] RESOURCE "PMSRELA" SIZE aPosObj2[6,3],aPosObj2[6,4] When aCfgBtn[24][1] OF oPanelTmk PIXEL MESSAGE STR0028; //"Cadastro de Acessorios"
		ACTION TkAcessorio()

		@aPosObj2[7,1],aPosObj2[7,2] BTNBMP oBtn[7] RESOURCE "sduprop" SIZE aPosObj2[7,3],aPosObj2[7,4] OF oPanelTmk PIXEL MESSAGE STR0097; //"Lista de Contatos"
		ACTION TkListas()

		@aPosObj2[8,1],aPosObj2[8,2] BTNBMP oBtn[8] RESOURCE "SDUIMPORT" SIZE aPosObj2[8,3],aPosObj2[8,4] OF oPanelTmk PIXEL MESSAGE STR0098; //"Historico da entidade"
		ACTION TkHistEntidade()

		nBtnSoma++
		@aPosObj2[9,1],aPosObj2[9,2] BTNBMP oBtn[9] RESOURCE "RESPONSA" SIZE aPosObj2[9,3],aPosObj2[9,4] OF oPanelTmk PIXEL MESSAGE STR0197; //"Chamados compartilhados"
		ACTION Tk272RlCmp() WHEN lCpCompart

		nBtnSoma++
		@aPosObj2[10,1],aPosObj2[10,2] BTNBMP oBtn[10] RESOURCE "MSGFORWD" SIZE aPosObj2[10,3],aPosObj2[10,4] OF oPanelTmk PIXEL MESSAGE STR0198; //"Transferir chamado"
		ACTION Tk272Trnsf()

		If SuperGetMV("MV_CRMTERR",.F.,.F.)
			nBtnSoma++
			@aPosObj2[11,1],aPosObj2[11,2] BTNBMP oBtn[11] RESOURCE "GLOBO" SIZE aPosObj2[11,3],aPosObj2[11,4] OF oPanelTmk PIXEL MESSAGE STR0261 ; //"Simular Território"
				ACTION Tk271VldTerr(M->UC_ENTIDAD,M->UC_CHAVE,"S")
		EndIf	

		If lPls
			@aPosObj2[11,1],aPosObj2[11,2] BTNBMP oBtn[11] RESOURCE "PLSIMG16" SIZE aPosObj2[11,3],aPosObj2[11,4] When aCfgBtn[34][1] OF oPanelTmk PIXEL MESSAGE STR0158 ; //"Plano de Saude"
			ACTION PlsCallCenter(	oGetTmk			,@nOpc			,@oFolderTmk	,@oEnchTmk		,;
									@cEncerra		,@cMotivo		,@oFolderTlv	,@oEnchTlv		,;
									@cCodPagto		,@cDescPagto	,@cCodTransp	,@cTransp		,;
									@cCob			,@cEnt			,@cCidadeC		,@cCepC			,;
									@cUfC			,@cBairroE		,@cBairroC		,@cCidadeE		,;
									@cCepE			,@cUfE			,@nLiquido		,@nTxJuros		,;
									@nTxDescon		,@nVlJur		,@aParcelas		,@nEntrada		,;
									@nFinanciado	,@nNumParcelas	,@nValorCC		,@oCrono		,;
									@cCrono			,@nTimeSeg		,@nTimeMin      ,@lHabilita		,;
									@oFolderTlc		,@oEnchTlc		,aColsTmk       ,aColsTlv		,;
									@oDlg       	,NIL            ,aParScript		,l380			,;
									@lMsg			,aSx3SUA		,cAgenda		,nValNFat		,;
									aSx3SUC			,@aItens		,oCodPagto		,@oDescPagto	,;
									@oCodTransp		,@oTransp		,@oCob			,@oEnt			,;
									@oCidadeC		,@oUfC			,@oBairroE		,@oCepC			,;
									@oCidadeE		,@oBairroC		,@cCidadeE		,@oCepE			,;
									@oUfE			,@oLiquido		,@nTxJuros		,@oTxJuros		,;
									@oTxDescon		,@oParcelas		,@oEntrada		,@oFinanciado	,;
									@oNumParcelas	,@lTipo9		,@oValNFat		,lSigaCRD)
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Botoes do Televendas                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@aPosObj2[1,1],aPosObj2[1,2] BTNBMP oBtn[20] RESOURCE "NOTE" SIZE aPosObj2[4,3],aPosObj2[4,4] When aCfgBtn[22][1] OF oPanelTlv PIXEL MESSAGE STR0026; //"Cadastro do Produto"
		ACTION TkProduto()
		
		@aPosObj2[2,1],aPosObj2[2,2] BTNBMP oBtn[21] RESOURCE "relatorio" SIZE aPosObj2[5,3],aPosObj2[5,4] When aCfgBtn[23][1] OF oPanelTlv PIXEL MESSAGE STR0027; //"Cadastro de Concorrentes"
		ACTION TkConcorrente()
		
		@aPosObj2[3,1],aPosObj2[3,2] BTNBMP oBtn[22] RESOURCE "PMSRELA" SIZE aPosObj2[6,3],aPosObj2[6,4] When aCfgBtn[24][1] OF oPanelTlv PIXEL MESSAGE STR0028; //"Cadastro de Acessorios"
		ACTION TkAcessorio()

		@aPosObj2[4,1],aPosObj2[4,2] BTNBMP oBtn[23] RESOURCE "PRECO" SIZE aPosObj2[7,3],aPosObj2[7,4] When aCfgBtn[25][1] OF oPanelTlv PIXEL MESSAGE STR0017 ;//"Condicoes de Pagamento"
		ACTION 	(SetKEY(15,		{ || AllWaysTrue() } ),;
				Tk273Pagamento(	nOpc			,lHabilita		,@aItens		,@cCodPagto		,;
								oCodPagto		,@cDescPagto	,@oDescPagto	,@cCodTransp	,;
								@oCodTransp		,@cTransp		,@oTransp		,@cCob			,;
								@oCob			,@cEnt			,@oEnt			,@cCidadeC		,;
								@oCidadeC		,@cCepC			,@oCepC			,@cUfC			,;
								@oUfC			,@cBairroE		,@oBairroE		,@cBairroC		,;
								@oBairroC		,@cCidadeE		,@oCidadeE		,@cCepE			,;
								@oCepE			,@cUfE			,@oUfE			,@nLiquido		,;
								@oLiquido		,@nTxJuros		,@oTxJuros		,@nTxDescon		,;
								@oTxDescon		,@aParcelas		,@oParcelas		,@nEntrada		,;
								@oEntrada		,@nFinanciado	,@oFinanciado	,@nNumParcelas	,;
								@oNumParcelas	,@nVlJur		,@cCodAnt 		,@lTipo9		,;
								@oValNFat		,@nValNFat		,@cCliAnt		,lSigaCRD),;
				SetKEY(15,{|| aBtn[20]:Click() } ),;
				oDlg:bSet15:= bOk )
								
		@aPosObj2[5,1], aPosObj2[5,2] BTNBMP oBtn[24]   RESOURCE "VENDEDOR" SIZE aPosObj2[8,3],aPosObj2[8,4]  When aCfgBtn[26][1] OF oPanelTlv PIXEL MESSAGE STR0040 ;//"Vendedor"
		ACTION Tk273VisVend()  				
	
		@aPosObj2[6,1], aPosObj2[6,2] BTNBMP oBtn[25]   RESOURCE "bmpord1"   SIZE aPosObj2[9,3],aPosObj2[9,4]  When aCfgBtn[27][1] OF oPanelTlv PIXEL MESSAGE STR0043; // "Tracker do Pedido"
		ACTION Tk273Pedido(nFolder)			
	
		@aPosObj2[7,1], aPosObj2[7,2] BTNBMP oBtn[26]   RESOURCE "pesquisa"  SIZE aPosObj2[10,3],aPosObj2[10,4]  When aCfgBtn[28][1] OF oPanelTlv PIXEL MESSAGE STR0044 ;//"Rastreamento"
		ACTION Matc040() 						
	
		@aPosObj2[8,1], aPosObj2[8,2] BTNBMP oBtn[27]   RESOURCE "CONTAINR"  SIZE aPosObj2[11,3],aPosObj2[11,4]  When aCfgBtn[29][1] OF oPanelTlv PIXEL MESSAGE STR0045 ;//"Lotes       "
		ACTION Matc060()  					
	
		@aPosObj2[9,1], aPosObj2[9,2] BTNBMP oBtn[28]  RESOURCE "S4WB007N"   SIZE aPosObj2[12,3],aPosObj2[12,4]  When aCfgBtn[30][1] OF oPanelTlv PIXEL MESSAGE STR0046 ;//"Sub-Lotes   "
		ACTION Mata245()  					
	
		@aPosObj2[10,1], aPosObj2[10,2] BTNBMP oBtn[29]  RESOURCE "HISTORIC"   SIZE aPosObj2[13,3],aPosObj2[13,4]  When aCfgBtn[31][1] OF oPanelTlv PIXEL MESSAGE STR0054 ;//"Vendas Lojas"
		ACTION Tk271ValidEnv()				
	
		@aPosObj2[11,1], aPosObj2[11,2] BTNBMP oBtn[30]  RESOURCE "BONUS" SIZE aPosObj2[14,3] ,aPosObj2[14,4]  When aCfgBtn[32][1] OF oPanelTlv PIXEL MESSAGE STR0056 ;//"Bonus"
		ACTION Tk273AvalBonus()		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esse botao sera usado somente para o TEF   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@aPosObj2[12,1],aPosObj2[12,2] BTNBMP oBtn[31] RESOURCE "BUDGET"  SIZE aPosObj2[15,3],aPosObj2[15,4] When aCfgBtn[33][1] OF oPanelTlv PIXEL MESSAGE STR0055 ;//"Consulta TEF"
		ACTION TK273ConTef() 
	
		@aPosObj2[13,1],aPosObj2[7,2] BTNBMP oBtn[32] RESOURCE "sduprop" SIZE aPosObj2[16,3],aPosObj2[16,4] OF oPanelTlv PIXEL MESSAGE STR0097; //"Lista de Contatos"
		ACTION TkListas()

		@aPosObj2[14,1],aPosObj2[8,2] BTNBMP oBtn[33] RESOURCE "SDUIMPORT" SIZE aPosObj2[17,3],aPosObj2[17,4] OF oPanelTlv PIXEL MESSAGE STR0098; //"Historico da entidade"
		ACTION TkHistEntidade()

		If	lSigaCRD
			@aPosObj2[15,1], aPosObj2[13,2] BTNBMP oBtn[34]  RESOURCE "SIMULACAO" SIZE aPosObj2[18,3] ,aPosObj2[18,4]  When .T. OF oPanelTlv PIXEL MESSAGE "Análise de Crédito";
			ACTION Tk273ConsCred(.F.,aParcelas,aValores[TOTAL],nVlJur)		
	    Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Botoes do Telecobranca                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		@aPosObj2[1,1],aPosObj2[1,2] BTNBMP oBtn[40] RESOURCE "SALVAR" SIZE aPosObj2[18,3] ,aPosObj2[18,4] When aCfgBtn[19][1] OF oPanelTlc PIXEL MESSAGE STR0042 ;//"Encerramento"
		ACTION Tk272Encerra(.T.,M->ACF_CODIGO,cEncerra,cMotivo,"3")  

		@aPosObj2[2,1],aPosObj2[2,2] BTNBMP oBtn[41] RESOURCE "sduprop" SIZE aPosObj2[19,3],aPosObj2[19,4] OF oPanelTlc PIXEL MESSAGE STR0097; //"Lista de Contatos"
		ACTION TkListas()

		@aPosObj2[3,1],aPosObj2[3,2] BTNBMP oBtn[42] RESOURCE "SDUIMPORT" SIZE aPosObj2[20,3],aPosObj2[20,4] OF oPanelTlc PIXEL MESSAGE STR0098; //"Historico da entidade"
		ACTION TkHistEntidade()

		@aPosObj2[4,1],aPosObj2[4,2] BTNBMP oBtn[43] RESOURCE "bmpvisual" SIZE aPosObj2[21,3],aPosObj2[21,4] OF oPanelTlc PIXEL MESSAGE STR0099; //"Simulação de Valores"
		ACTION Tk274Simul()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancelamento da liquidacao de um titulo negociado. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		@aPosObj2[5,1],aPosObj2[5,2] BTNBMP oBtn[44] RESOURCE "EXCLUIR" SIZE aPosObj2[21,3],aPosObj2[21,4] OF oPanelTlc PIXEL MESSAGE STR0234 ACTION Tk274CanLiq() //"Cancelamento da Liquidacao"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para a criacao de botoes de usuario na TOOLBAR LATERAL ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTMKBARLA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Foi usado o construtor do objeto para poder executar os botoes adicionais criados em campo³
			//³que serao criados separadamente para cada painel.                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acrescenta os botoes na barra lateral para TMK³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAux := 08 + IIF(lPls,1,0) + nBtnSoma //Numero de botoes existentes no painel TMK

			For nButton := 1 To Len(aBtnLat)
				nAux ++
				
				TBtnBmp2():New( aPosObj2[ nAux,1 ], aPosObj2[ nAux,2 ], aPosObj2[ nAux,3 ], aPosObj2[ nAux,4 ],;
								aBtnLat[nButton,1], NIL, NIL,NIL,;
								aBtnLat[nButton,2], oPanelTmk, aBtnLat[nButton,3], NIL, NIL,NIL )
	
			Next nButton
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acrescenta os botoes na barra lateral para TLV³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAux:= 14 //Numero de botoes existentes no painel TLV
			//Se o operador estiver habilitado para o SIGACRD acrescenta mais um botão
			If lSigaCRD
				nAux++
			Endif     

			For nButton := 1 To Len(aBtnLat)
				nAux ++                                                                                                 
				                            
				/*

				  [ <oBtn> := ] TBtnBmp2():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
											    <cResName1>, <cResName2>, <cBmpFile1>, <cBmpFile2>,;
											    [{|Self|<uAction>}], <oWnd>, <cMsg>, <{uWhen}>, <.adjust.>,;
											    <.lUpdate.> )
														
				
				*/

				TBtnBmp2():New( aPosObj2[ nAux,1 ], aPosObj2[ nAux,2 ],	aPosObj2[ nAux,3 ], aPosObj2[ nAux,4 ],;
								aBtnLat[nButton,1], NIL,NIL,NIL,;
								aBtnLat[nButton,2], oPanelTlv, aBtnLat[nButton,3], NIL, NIL,;
								NIL )
	
			Next nButton
            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acrescenta os botoes na barra lateral para TLC³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAux:= 5 //Numero de botoes existentes no painel TLC

			For nButton := 1 To Len(aBtnLat)
				nAux ++                                                                                                 
				
				TBtnBmp2():New( aPosObj2[ nAux,1 ], aPosObj2[ nAux,2 ], aPosObj2[ nAux,3 ], aPosObj2[ nAux,4 ],;
								aBtnLat[nButton,1], NIL, NIL,NIL,;
								aBtnLat[nButton,2], oPanelTlc, aBtnLat[nButton,3], NIL, NIL,NIL )
	
			Next nButton
			
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao da barra de BOTOES SUPERIOR ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCfgBtn[3][1]
			AAdd(aButBar,{"S4WB008N",{||Calculadora()},STR0011,STR0011,,})	//"Calculadora"
		EndIf
		If aCfgBtn[5][1]
			AAdd(aButBar,{"S4WB010N",{||OurSpool()},STR0013,STR0013,,})		//"Gerenciador de Impressao..."
		EndIf
		If aCfgBtn[6][1]
			AAdd(aButBar,{"S4WB016N",{||HelProg(.T.)},STR0014,STR0014,,})	//"Help"
		EndIf		

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa o chamado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bLimpa := {||TkLimpa(	@oCrono		,@cCrono		,@nTimeSeg		,@nTimeMin		,;
			   					@nOpc		,@oFolderTmk	,@oEnchTmk		,@lHabilita		,;
								@oFolderTlv	,@oEnchTlv		,@nLiquido		,@cCob			,;
								@cEnt		,@cCidadeC		,@cCepC			,@cUfC			,;
								@cBairroc	,@cCidadeE		,@cCepE			,@cUfE			,;
								@cBairroE	,@nEntrada		,@aParcelas		,@nFinanciado	,;
								@cTransp	,@cCodPagto		,@cDescPagto	,@nTxJuros		,;
								@nVlJur		,@nNumParcelas	,@cCodTransp	,@oFolderTlc	,;
								@oEnchTlc	,@cCodAnt		,aSx3SUA		,aSx3SUC		,;
								Nil			,@cCliAnt		,@lExibeHelp	,@cLock)}
		
		If aCfgBtn[7][1]
			If(Tk271CanHab( l380, lPriContato ))
				aAtalho := Tk271Atalho(1)
				AAdd(aRotxAtalho,{STR0015,aAtalho[2],aAtalho[1],"1"})
				AAdd(aButBar,{"S4WB004N",bLimpa,STR0015,STR0015,aAtalho[1],aAtalho[2]})
			EndIf
		EndIf                        	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cancela o chamado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		bCancelCh := {||IIF(Tk271Cancela(	@nOpc		,@oCrono		,@cCrono		,@nTimeSeg		,;
											@nTimeMin	,@oFolderTmk	,@oEnchTmk		,@oFolderTlv	,;
											@oEnchTlv	,@cCodPagto		,@cDescPagto	,@cCodTransp	,;
											@cTransp	,@cCob			,@cEnt			,@cCidadeC		,;
											@cCepC		,@cUfC			,@cBairroE		,@cBairroC		,;
											@cCidadeE	,@cCepE			,@cUfE			,@nLiquido		,;
											@nTxJuros	,@nTxDescon		,@nVlJur		,@aParcelas		,;
											@nEntrada	,@nFinanciado	,@nNumParcelas	,@nValorCC		,;
											@lHabilita	,@cMotivo		,@cEncerra		,@oFolderTlc	,;
											@oEnchTlc	,@cCodAnt		,@lMsg			,@lPriContato	),;
								TkLimpa(	@oCrono		,@cCrono		,@nTimeSeg		,@nTimeMin		,;
											@nOpc		,@oFolderTmk	,@oEnchTmk		,@lHabilita		,;
											@oFolderTlv	,@oEnchTlv		,@nLiquido		,@cCob			,;
											@cEnt		,@cCidadeC		,@cCepC			,@cUfC			,;
											@cBairroc	,@cCidadeE		,@cCepE			,@cUfE			,;
											@cBairroE	,@nEntrada		,@aParcelas		,@nFinanciado	,;
											@cTransp	,@cCodPagto		,@cDescPagto	,@nTxJuros		,;
											@nVlJur		,@nNumParcelas	,@cCodTransp	,@oFolderTlc	,;
											@oEnchTlc	,@cCodAnt		,aSx3SUA		,aSx3SUC		,;
											lExibeMsg	,@cCliAnt		,@lExibeHelp),"")}
		If aCfgBtn[8][1]
			If nOpc <> 2
				aAtalho := Tk271Atalho(2)
				AAdd(aRotxAtalho,{STR0016,aAtalho[2],aAtalho[1],"2"})
				AAdd(aButBar,{"EXCLUIR",bCancelCh,STR0016,STR0016,aAtalho[1],aAtalho[2]})
			EndIf
		EndIf    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Marketing ativo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		bMktAtv := {||Tk271SKey(1),Tk271Discagem(oDlg),Tk271SKey(2)}
		If aCfgBtn[9][1]
			aAtalho := Tk271Atalho(3)
			AAdd(aRotxAtalho,{STR0170,aAtalho[2],aAtalho[1],"3"})
			AAdd(aButBar,{"DISCAGEM",bMktAtv,STR0170,STR0170,aAtalho[1],aAtalho[2]})  //"Marketing Ativo"
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envio de tarefa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bEnvTar := {||	Tk271SKey(1), TkVisita(	@nOpc			,@oFolderTmk	,@oEnchTmk		,@cEncerra		,;
									@cMotivo		,@oFolderTlv	,@oEnchTlv		,@cCodPagto		,;
									@cDescPagto		,@cCodTransp	,@cTransp		,@cCob			,;
									@cEnt			,@cCidadeC		,@cCepC			,@cUfC			,;
									@cBairroE		,@cBairroC		,@cCidadeE		,@cCepE			,;
									@cUfE			,@nLiquido		,@nTxJuros		,@nTxDescon		,;
									@nVlJur			,@aParcelas		,@nEntrada		,@nFinanciado	,;
									@nNumParcelas	,@nValorCC		,@oCrono    	,@cCrono		,;
									@nTimeSeg		,@nTimeMin	    ,@lHabilita 	,@oFolderTlc	,;
									@oEnchTlc		,aColsTmk	    ,aColsTlv   	,@oDlg			,;
									NIL             ,aParScript		,l380			,@lMsg			,;
									aSx3SUA			,cAgenda		,nValNFat		,aSx3SUC		,;
									@aItens			,oCodPagto		,@oDescPagto	,@oCodTransp	,;
									@oTransp		,@oCob			,@oEnt			,@oCidadeC		,;
									@oUfC			,@oBairroE		,@oCepC			,@oCidadeE		,;
									@oBairroC		,@cCidadeE		,@oCepE			,@oUfE			,;
									@oLiquido		,@nTxJuros		,@oTxJuros		,@oTxDescon		,;
									@oParcelas		,@oEntrada		,@oFinanciado	,@oNumParcelas	,;
									@lTipo9			,@oValNFat		,aSX3ACF		,@cCliAnt		,;
									lSigaCRD), Tk271SKey(2)}
		If aCfgBtn[10][1]
			aAtalho := Tk271Atalho(12)
			AAdd(aRotxAtalho,{STR0019,aAtalho[2],aAtalho[1],"12"})	//"Envio de Tarefa (Faturamento)"
			AAdd(aButBar,	{"BMPGROUP",bEnvTar,STR0019,STR0019,aAtalho[1],aAtalho[2]})	//"Envio de Tarefa (Faturamento)"
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Script de campanha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bScrCamp := {||Tk271SKey(1),Tk271Script(nOpc,@aParScript,,.T.),Tk271SKey(2)}
		If aCfgBtn[11][1]
			aAtalho := Tk271Atalho(4)
			AAdd(aRotxAtalho,{STR0022,aAtalho[2],aAtalho[1],"4"})
			AAdd(aButBar,	{"PRODUTO",bScrCamp,STR0022,STR0022,aAtalho[1],aAtalho[2]})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alteracao de entidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bAltEnt	:= {||Tk271SKey(1),Tk271AltEnt(),Tk271SKey(2)}
		If aCfgBtn[12][1]
			aAtalho := Tk271Atalho(5)
			AAdd(aRotxAtalho,{STR0023,aAtalho[2],aAtalho[1],"5"})
			AAdd(aButBar,{"FOLDER6",bAltEnt,STR0023,STR0023,aAtalho[1],aAtalho[2]})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Historico de ligacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bHistLig := {||	Tk271SKey(1), Tk271Historico( @nOpc		,@lHabilita	,@oFolderTmk	,@oEnchTmk		,;
										@oFolderTlv	,@oEnchTlv	,@cCodPagto		,@cDescPagto	,;
										@cCodTransp	,@cTransp	,@cCob			,@cEnt			,;
										@cCidadeC	,@cCepC		,@cUfC			,@cBairroE		,;
										@cBairroC	,@cCidadeE	,@cCepE			,@cUfE			,;
										@nLiquido	,@nTxJuros	,@nTxDescon		,@nVlJur		,;
										@aParcelas	,@nEntrada	,@nFinanciado	,@nNumParcelas	,;
										@nValorCC	,@cMotivo	,@cEncerra		,@oFolderTlc	,;
										@oEnchTlc	,@aColsTlv	,@cCodAnt		,@cCliAnt      ,;
										@cLock ),Tk271SKey(2)}
		If aCfgBtn[13][1]
			aAtalho := Tk271Atalho(6)
			AAdd(aRotxAtalho,{STR0024,aAtalho[2],aAtalho[1],"6"})
			AAdd(aButBar,{"AUTOM",bHistLig,STR0024,STR0024,aAtalho[1],aAtalho[2]})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Situacao financeira³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bSituFin := {||Tk271SKey(1), Tk271SituaC(), Tk271SKey(2)}
		If aCfgBtn[14][1]
			aAtalho := Tk271Atalho(7)
			AAdd(aRotxAtalho,{STR0025,aAtalho[2],aAtalho[1],"7"})
			AAdd(aButBar,{"SIMULACAO",bSituFin,STR0025,STR0025,aAtalho[1],aAtalho[2]})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cadastro de contatos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bCadCont := { || Tk271SKey(1),Tk271AtuCont(),Tk271SKey(2) }	
		If aCfgBtn[15][1]
			aAtalho := Tk271Atalho(8)
			AAdd(aRotxAtalho,{STR0041,aAtalho[2],aAtalho[1],"8"})
			AAdd(aButBar,{"bmpuser",bCadCont,STR0041,STR0041,aAtalho[1],aAtalho[2]})
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Banco de conhecimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bBcoConh := {||Tk271SKey(1), TkConhecimento(), Tk271SKey(2)}
		If aCfgBtn[16][1]
			aAtalho := Tk271Atalho(9)
			AAdd(aRotxAtalho,{STR0092,aAtalho[2],aAtalho[1],"9"})
			AAdd(aButBar,{"WEB",bBcoConh,STR0092,STR0060,aAtalho[1],aAtalho[2]})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tracker da entidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bTracker := {||Tk271SKey(1), TK271Track(), Tk271SKey(2)}
		If aCfgBtn[17][1]
			aAtalho := Tk271Atalho(10)
			AAdd(aRotxAtalho,{STR0079,aAtalho[2],aAtalho[1],"10"})
			AAdd(aButBar,{"bmpvisual",bTracker,STR0079,STR0079,aAtalho[1],aAtalho[2]})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Visualiza eventos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bVisEvent := {||Tk271SKey(1), TK271Evento(), Tk271SKey(2)}
		If aCfgBtn[18][1]
			aAtalho := Tk271Atalho(11)
			AAdd(aRotxAtalho,{STR0080,aAtalho[2],aAtalho[1],"11"})
			AAdd(aButBar,{"POSCLI",bVisEvent,STR0080,STR0080,aAtalho[1],aAtalho[2]})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Perfil do Contato³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bPerfil := {||Tk271SKey(1), TK271Perfil(), Tk271SKey(2)}
		aAtalho := Tk271Atalho(13)
		AAdd(aRotxAtalho,{STR0224,aAtalho[2],aAtalho[1],"13"})//"Perfil do contato"
		AAdd(aButBar,{"GRAF2D",bPerfil,STR0224,STR0224,aAtalho[1],aAtalho[2]})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Agendamento da OS
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If l380 .OR. (!lNotOper .AND. Val(SU7->U7_TIPO) == SUPERVISOR) //Se Operador via lista ou Supervisor
			aAtalho := Tk271Atalho(14)
			AAdd(aRotxAtalho,{STR0240,aAtalho[2],aAtalho[1],"14"})//"Agenga O.S."		
			AAdd(aButBar,{"OFIOM110",{|| SaveInter(), TECA510(Iif(!(!lNotOper .AND. Val(SU7->U7_TIPO) == SUPERVISOR),SU6->U6_NUMOS,NIL)), RestInter()},STR0240,STR0240,aAtalho[1],aAtalho[2]})		
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Configuracao de teclas de atalho (apenas versao 11 e acima)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aButBar,{"ATALHO",{||TkCfgAtalho(@aRotxAtalho,Upper(FunName()))},STR0171,STR0171,,}) //"Configurar atalhos"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Botao OK - Confirmacao do atendimento                                ³
		//³ ---------------------------------------------------------------------³
		//³ Criado o ponto de entrada TK271BOK na chamada do OK da Toolbar da    ³
		//³ tela de atendimento. Se o retorno for negativo, nao chama a funcao   ³
		//³ de gravacao e nao sai da tela.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bOk := {||IIF(nOpc <> 2,;
					(SetKEY(15,		{ || AllWaysTrue() } ),;
					lRet := Tk271Grava(	@nOpc			,@oFolderTmk	,@nTimeSeg		,@nTimeMin		,;
										@oCrono			,@cCrono		,@oEnchTmk		,@cMotivo		,;
										@cEncerra		,@oFolderTlv	,@oEnchTlv		,@cCodPagto		,;
										@cDescPagto		,@cCodTransp	,@cTransp		,@cCob			,;
										@cEnt			,@cCidadeC		,@cCepC			,@cUfC			,;
										@cBairroE		,@cBairroC		,@cCidadeE		,@cCepE			,;
										@cUfE			,@nLiquido		,@nTxJuros		,@nTxDescon		,;
										@nVlJur			,@aParcelas		,@nEntrada		,@nFinanciado	,;
										@nNumParcelas	,@nValorCC		,@lHabilita 	,@oFolderTlc	,;
										@oEnchTlc		,aColsTmk	    ,aColsTlv   	,@oDlg			,;
										@cCodAnt    	,aParScript		,l380			,@lMsg			,;
										aSx3SUA			,cAgenda		,@nValNFat		,aSx3SUC		,;
										@aItens			,oCodPagto		,@oDescPagto	,@oCodTransp	,;
										@oTransp		,@oCob			,@oEnt			,@oCidadeC		,;
										@oUfC			,@oBairroE		,@oCepC			,@oCidadeE		,;
										@oBairroC		,@cCidadeE		,@oCepE			,@oUfE			,;
										@oLiquido		,@nTxJuros		,@oTxJuros		,@oTxDescon		,;
										@oParcelas		,@oEntrada		,@oFinanciado	,@oNumParcelas	,;
										@lTipo9			,@oValNFat		,aSX3ACF		,@cCliAnt		,;
										lSigaCRD		,@lPriContato	,@cLock			,cDlgTitle	   ),;
					SetKEY(15, bOk),;
				    oDlg:bSet15:= bOk),;
					oDlg:End())}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Botao Cancela - Confirmacao do atendimento                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bCancel := {||( IIF (Tk271VlCancel(l380,lPriContato),IIF(TK271Fim( nOpc  ,lMsg ),(Tk273AtuPen( lSigaCRD ,.T.  ,.F.  , .T. ),oDlg:End()),""),IIF(lTk271Fil,TK271MFil( cAlias, @cFiltra, @aIndex ),.T.)),.F.)}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para a criacao de botoes de usuario na TOOLBAR SUPERIOR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para uso em Templates									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTMKCBPROT
			nAux := 20 // 20 botoes ja existentes no padrao -1 desabilitado
			For nButton := 1 To Len(aBtnSup)
				nAux ++                                                                                                 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Foi usado o construtor do objeto para poder executar os botoes adicionais criados em campo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  /*
			  [ <oBtn> := ] TBtnBmp():NewBar( <cResName1>, <cResName2>,;
											    <cBmpFile1>, <cBmpFile2>, <cMsg>, [{|This|<uAction>}],;
											    <.group.>, <oBar>, <.adjust.>, <{WhenFunc}>,;
											    <cToolTip>, <.lPressed.>, [\{||<bDrop>\}], [\"<uAction>\"], <nPos>,;
											    <cPrompt>, <oFont>, [<cResName3>], [<cBmpFile3>], [!<.lNoBorder.>] )
			  */
				AAdd(aButBar,{aBtnSup[nButton,1],aBtnSup[nButton,2],aBtnSup[nButton,3],aBtnSup[nButton,3],,})
			Next nButton

		Endif

		If lTMKCBPRO                                                                
			nAux := 20 // 20 botoes ja existentes no padrao -1 desabilitado
			For nButton := 1 To Len(aBtnSup)
				nAux ++                                                                                                 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Foi usado o construtor do objeto para poder executar os botoes adicionais criados em campo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  /*
			  [ <oBtn> := ] TBtnBmp():NewBar( <cResName1>, <cResName2>,;
											    <cBmpFile1>, <cBmpFile2>, <cMsg>, [{|This|<uAction>}],;
											    <.group.>, <oBar>, <.adjust.>, <{WhenFunc}>,;
											    <cToolTip>, <.lPressed.>, [\{||<bDrop>\}], [\"<uAction>\"], <nPos>,;
											    <cPrompt>, <oFont>, [<cResName3>], [<cBmpFile3>], [!<.lNoBorder.>] )
			  */	
				AAdd(aButBar,{	aBtnSup[nButton,1],;														//BMP
								aBtnSup[nButton,2],;														//Bloco
								aBtnSup[nButton,3],;														//Desc/Tooltip
								Iif(len(aBtnSup[nButton])>=4,aBtnSup[nButton,4],aBtnSup[nButton,3]),;		//Desc
								Iif(len(aBtnSup[nButton])>=5,aBtnSup[nButton,5],Nil),;						//Num.Atalho
								Iif(len(aBtnSup[nButton])>=6,aBtnSup[nButton,6],Nil)})						//Texto atalho
			Next nButton
		Endif
				
		// Limpeza da tela
		If Tk271CanHab( l380, lPriContato )
			SetKey(VK_F5, { || IIF(lKey.AND.aCfgBtn[7][1],(	lKey:= .F.,TkLimpa( @oCrono		,@cCrono	,@nTimeSeg	,@nTimeMin		,;
																				@nOpc		,@oFolderTmk	,@oEnchTmk	,@lHabilita		,;
																				@oFolderTlv	,@oEnchTlv		,@nLiquido	,@cCob			,;
																				@cEnt		,@cCidadeC		,@cCepC		,@cUfC			,;
																				@cBairroc	,@cCidadeE		,@cCepE		,@cUfE			,;
																				@cBairroE	,@nEntrada		,@aParcelas	,@nFinanciado	,;
																				@cTransp	,@cCodPagto		,@cDescPagto,@nTxJuros		,;
																				@nVlJur		,@nNumParcelas	,@cCodTransp,@oFolderTlc	,;
																				@oEnchTlc	,@cCodAnt		,aSx3SUA	,aSx3SUC		,;
																				Nil			,@cCliAnt		,@lExibeHelp),;
															lKey:= .T.),"") })
		EndIf
																	
		// Condicao de Pagamento
		SetKey(VK_F6, { || IIF(lKey.AND.aCfgBtn[23][1],(	lKey:= .F.,Tk273Pagamento(	nOpc		,lHabilita		,@aItens		,@cCodPagto		,;
																					oCodPagto		,@cDescPagto	,@oDescPagto	,@cCodTransp	,;
																					@oCodTransp		,@cTransp		,@oTransp		,@cCob			,;
																					@oCob			,@cEnt			,@oEnt			,@cCidadeC		,;
																					@oCidadeC		,@cCepC			,@oCepC			,@cUfC			,;
																					@oUfC			,@cBairroE		,@oBairroE		,@cBairroC		,;
																					@oBairroC		,@cCidadeE		,@oCidadeE		,@cCepE			,;
																					@oCepE			,@cUfE			,@oUfE			,@nLiquido		,;
																					@oLiquido		,@nTxJuros		,@oTxJuros		,@nTxDescon		,;
																					@oTxDescon		,@aParcelas		,@oParcelas		,@nEntrada		,;
																					@oEntrada		,@nFinanciado	,@oFinanciado	,@nNumParcelas	,;
																					@oNumParcelas	,@nVlJur		,@cCodAnt		,@lTipo9 		,;
																					@oValNFat		,@nValNFat		,@cCliAnt		,lSigaCRD),;
																					lKey:= .T.),"") } )
																						
		// Marketing Ativo
		SetKey(VK_F7, { || IIF(lKey.AND.aCfgBtn[9][1],(	lKey:= .F.,	Tk271Discagem(oDlg),lKey:= .T.),"") })
		
		// Situacao Financeira
		SetKey(VK_F8, { || IIF(lKey.AND.aCfgBtn[14][1],(	lKey:= .F.,Tk271SituaC(),lKey:= .T.), "") })
		
		//Caracteristicas do Produto
		SetKey(VK_F9, { || IIF(lKey.AND.aCfgBtn[22][1],(	lKey:= .F.,TkProduto(),lKey:= .T.), "") })
		//Consulta do historico de ligacoes 
		SetKey(VK_F10, { || IIF(lKey.AND.aCfgBtn[13][1],(	lKey:= .F.,	Tk271Historico( @nOpc		,@lHabilita	,@oFolderTmk	,@oEnchTmk		,;
																						@oFolderTlv	,@oEnchTlv	,@cCodPagto		,@cDescPagto	,;
																						@cCodTransp	,@cTransp	,@cCob			,@cEnt			,;
																						@cCidadeC	,@cCepC		,@cUfC			,@cBairroE		,;
																						@cBairroC	,@cCidadeE	,@cCepE			,@cUfE			,;
																						@nLiquido	,@nTxJuros	,@nTxDescon		,@nVlJur		,;
																						@aParcelas	,@nEntrada	,@nFinanciado	,@nNumParcelas	,;
																						@nValorCC	,@cMotivo	,@cEncerra		,@oFolderTlc	,;
																						@oEnchTlc	,@aColsTlv	,@cCodAnt		,@cCliAnt      ,;
																						@cLock      ),lKey:= .T.), "") })
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Divide a tela verticalmente para os objetos oFolder e objetios do historico       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		
		Aadd( aObjects, { 100, 100, .T., .T. , .T.} )
		Aadd( aObjects, { 100, 20 , .T., .F. , .F.} )
		
		aSize3   :=	aPosObj1[ 2 ] //Area reservada para o folder + historico
		aInfo    := { aSize3[ 2 ], aSize3[ 1 ], aSize3[ 4 ], aSize3[ 3 ], 0, 0 }
		aPosObj3 := MsObjSize( aInfo, aObjects, .T. , .F. )
		
		oFolder := TFolder():New(aPosObj3[1,1], aPosObj3[1,2],aTitles, aPages,oDlg,,,,.T.,.F.,aPosObj3[1,3], aPosObj3[1,4],)
		oFolder:bSetOption:={|nAtu| Tk271ChangeFolder(	nAtu		,oFolder:nOption	,@oBtn		,@aBtn		,;
														@aCfgBtn	,aCfgBtnOri			,@nOpc		,oPanelTmk	,;
														oPanelTlv	,oPanelTlc			,@oEnchTlv	,@lHabilita	)}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega nomes dos Folders de acordo com o Posto de venda    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TkGetTipoAte() == "1"  // Telemarketing
			oFolderTMK := oFolder:aDialogs[1]    
			
		Elseif TkGetTipoAte() == "2" // Televendas
			oFolderTLV := oFolder:aDialogs[1]
	
		Elseif TkGetTipoAte() == "3" // Telecobrancas
			oFolderTLC := oFolder:aDialogs[1]
	
		Elseif TkGetTipoAte() == "4" // Ambos
			oFolderTMK := oFolder:aDialogs[1]
			oFolderTLV := oFolder:aDialogs[2]
			oFolderTLC := oFolder:aDialogs[3]
	
		Elseif TkGetTipoAte() == "5" // TMK x TLV
			oFolderTMK := oFolder:aDialogs[1]
			oFolderTLV := oFolder:aDialogs[2]
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Objetos do Folder 1 - TELEMARKETING³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TkGetTipoAte() $ "145" // Telemarketing, Ambos e TMK x TLV
			DbSelectArea("SX3")  
			DbSetOrder(1)
			DbGotop()  // Esse comando foi colocado para evitar desposicionamento no CRIAVAR - QNC - Qualidade 609 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria uma enchoice para os campos do Telemarketing.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegToMemory("SUC",(nOpc == 3))  
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o atendimento foi executado atraves da CTI  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cCliCti) .AND. !Empty(cLojCti)
				M->UC_ENTIDAD := cEntCti
				M->UC_CHAVE   := ALLTRIM(cCliCti + cLojCti)
				M->UC_DESCCHA := TkEntidade(M->UC_ENTIDAD,M->UC_CHAVE,1)
			Endif
			
			If !Empty(cContCti)			
				M->UC_CODCONT := cContCti
				M->UC_DESCNT  := TkDadosContato(cContCti,6)
				M->UC_DESCENT := Posicione("SX2",1,M->UC_ENTIDAD,"X2NOME()")
			Endif
			
			If !Empty(cMens) //Mensagem Padrao Observação
				M->UC_OBS	:= cMens
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Divide a tela verticalmente entre a enchoice e getdados de Telemarketing          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjects := {}
			
			Aadd( aObjects, { 95 , 300 , .T., .T. , .F.} )
			Aadd( aObjects, { 180, 300 , .T., .T. , .F.} )
			
			nSizeY   := aPosObj3[ 2,1 ] - 25
			nSizeX   := aPosObj3[ 2,4 ] - aPosObj3[ 2,2 ] - 2
			aSize5   :=	{0,0,nSizeX,nSizeY} 					//Area reservada para o os objetos internos do folder Telemarketing
			aInfo    := { aSize5[ 1 ], aSize5[ 2 ], aSize5[ 3 ], aSize5[ 4 ], 0, 0 }
			aPosObj5 := MsObjSize( aInfo, aObjects, .F. , .F. )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos de Protocolo ANS so podem ser apresentados quando ativado RN 395 (SIGAPLS) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If GetNewPar("MV_PLRN395","0") != "1" 
				aFieldsSUC := Tk271Field("SUC","UC_MOTPLS,UC_DESCPLS,UC_PROTANS") 
			Else
				aFieldsSUC := Tk271Field("SUC") 
			EndIf    
			
			Zero()
			oEnchTmk:= MsMGet():New("SUC", nReg, nOpc, aAC,"AC",STR0051,aFieldsSUC,aPosObj5[1],,,,,,oFolderTmk,,.T.,.F.,NIL,.T. ) 	//"Quanto a exclusao ?"
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para a manutenção da enchoice.³
			//³                                               ³			
			//³ Parâmetros:                                   ³			
			//³ nFolder   := Folder do atendimento.           ³			
			//³ aPosObj5  := Posição da enchoice no diálogo.  ³						
			//³ oFolderTmk:= Objeto Folder do telemarketing.  ³						
			//³                                               ³						
			//³ Retorno:                                      ³									
			//³ oFolderTmk:= Objeto Folder do telemarketing.  ³									
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTMKENTMK
				oFolderTmk:= P_TMKENTMK( nFolder,aPosObj5,oFolderTmk )
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta o aCols e aHeader para o Telemarketing³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aGets := AClone( aGets1 )
			aTela := AClone( aTela1 )  			
			aHeader  := {}
			aCols    := {}
			aHeader  := aClone(aSvFolder[1][1])
			aCols    := aClone(aSvFolder[1][2])
			n		 := aSvFolder[1][3]
			
			If AllTrim(SUC->UC_STATUS) == "3" .AND. nOpc <> 3
				nOpc := 2
			EndIf

			oGetTmk:= MSGetDados():New(aPosObj5[2,1],aPosObj5[2,2],aPosObj5[2,3] - 25,aPosObj5[2,4],nOpc,"Tk272EvaTmk","Tk272GetTmk","",.T.,,,.F.,99,,,,,oFolderTMK)
			oGetTmk:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],Tk272DelTmk(nOpc),oGetTmk:oBrowse:Refresh(.F.)}
			oGetTmk:oBrowse:bGotFocus	  := {||Tk271CabOk(oEnchTmk,lExibeHelp,lHabilita) }
			oGetTmk:oBrowse:lDisablePaint := .T.
			oGetTmk:oBrowse:Refresh(.T.) 
			oGetTmk:oBrowse:bChange := {||Tk272StSUD(.T.)}
			
			If AllTrim(SUC->UC_STATUS) == "3" .AND. nOpc <> 3
				oGetTmk:nOpc 			:= 2
				oGetTmk:oBrowse:nOpc	:= 2
				oEnchTmk:Disable()
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³armazena os dados originais do acols antes de qualquer alteracao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aColsTmk := aClone(aCols)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Objetos do Folder 2 - TELEVENDAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (TkGetTipoAte() $ "245") // Televendas, Ambos, TMK x TLV
	
		     // Se for inclusao inicializa com o lProspect com .F. 
			If nOpc == 3
				lProspect := .F.
			Else
				// Caso contrario alimenta da tabela
				lProspect := SUA->UA_PROSPEC	
			Endif
			
			DbSelectArea("SX3")
			DbSetOrder(1)
			DbGotop()  // Esse comando foi colocado para evitar desposicionamento no CRIAVAR - QNC - Qualidade 609 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria uma enchoice para os campos do Televendas    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegToMemory("SUA",(nOpc == 3))  
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o atendimento foi executado atraves da CTI  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cCliCti) .AND. !Empty(cLojCti)
				M->UA_CLIENTE := cCliCti
				M->UA_LOJA    := cLojCti
				M->UA_DESCCLI := TkEntidade(cEntCti,M->UA_CLIENTE + M->UA_LOJA,1)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra as operacoes fiscais  O parametro FALSE         ³
				//³nao faz a inicializacao do refresh do rodape de impostos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisEnd(.F.)
	
				DbSelectArea(cEntCti)
				DbSetOrder(1)
				If DbSeek(xFilial(cEntCti)+M->UA_CLIENTE+M->UA_LOJA)
					cNaturez := Tk273DpNat(M->UA_CLIENTE, M->UA_LOJA)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inicializa os dados do cliente na FUNCAO FISCAL³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTK271TpCl
						cTipo := P_TK271TCL()     
		   			ElseIf lTKTipCli 
						cTipo := U_TKTIPCLI(cTipo)
					Else 
					   	cTipo := SUA->UA_TIPOCLI
					EndIf	
								
					MaFisIni(IIF(lCliEntreg .And. !lProspect,M->UA_CLIENT,M->UA_CLIENTE),;	// 1-Codigo Cliente/Fornecedor
							 IIF(lCliEntreg .And. !lProspect,M->UA_LOJAENT,M->UA_LOJA),;	// 2-Loja do Cliente/Fornecedor					
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
						     IIF(lProspect,M->UA_CLIENTE+M->UA_LOJA,""))// 13- Codigo e Loja do Prospect 
					
					If !Empty(cNaturez)
						MaFisAlt("NF_NATUREZA",cNaturez)
					EndIf	
				Endif	
			Endif
			
			If !Empty(cContCti)
				M->UA_CODCONT := cContCti
				M->UA_DESCNT  := TkDadosContato(M->UA_CODCONT,6)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Divide a tela verticalmente entre a enchoice e getdados de Televendas             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjects := {}
			
			Aadd( aObjects, { 95 , 300 , .T., .T. , .F.} )
			Aadd( aObjects, { 180, 300 , .T., .T. , .F.} )
			Aadd( aObjects, {  66 , 65 , .T., .F. , .T.} )
		
			nSizeY   := aPosObj3[ 2,1 ] - 50
			nSizeX   := aPosObj3[ 2,4 ] - aPosObj3[ 2,2 ] - 2
			aSize5   :=	{0,0,nSizeX,nSizeY} 								//Area reservada para o os objetos internos do folder Telemarketing
			aInfo    := { aSize5[ 1 ], aSize5[ 2 ], aSize5[ 3 ], aSize5[ 4 ], 0, 0 }
			aPosObj5 := MsObjSize( aInfo, aObjects, .F. , .F. )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula a posicao dos campos do rodape do Televendas - SAY e MSGET para 3 colunas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aPosGet := MsObjGetPos( aSize5[3]-aSize5[1], 263,{{5,40,96,126,180,210},{260}} )		

			Zero()
			oEnchTlv:= MsMGet():New("SUA", nReg, nOpc, aAC,"AC",STR0051,,aPosObj5[1],, ,,,,oFolderTlv,,.T.,,NIL,.T. ) 	//"Quanto a exclusao ?"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta o aCols e aHeader para o Folder 2 - TeleVendas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aGets := AClone( aGets2 )
			aTela := AClone( aTela2 )      
			aHeader  := {}
			aCols    := {}
			aHeader:= aClone(aSvFolder[2][1])
			aCols  := aClone(aSvFolder[2][2])
			n	   := aSvFolder[2][3]
			
			oGetTlv:= MSGetDados():New(aPosObj5[2,1],aPosObj5[2,2],aPosObj5[2,3],aPosObj5[2,4],nOpc,"Tk273EvaLi","Tk273GetOk","+UB_ITEM",.T.,,,.F.,500,"Tk273TlvImp",,,,oFolderTLV)

			If lIntACD 
				For nX := 1  To Len(oGetTlv:AINFO)
					oGetTlv:AINFO[nX,4]:=IIF(Empty(oGetTlv:AINFO[nX,4]),"CBM410ACDL()",Trim(oGetTlv:AINFO[nX,4])+" .AND. CBM410ACDL()")
				Next nX
			EndIf 

			oGetTlv:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],TK273DelTlv(nVlJur, nOpc),oGetTlv:oBrowse:Refresh(.F.)}
			oGetTlv:oBrowse:bGotFocus	:= {||Tk271CabOk(oEnchTlv,lExibeHelp,lHabilita) }
			oGetTlv:bEditCancel := {|| Tk273EditLine(n) } 
			oGetTlv:oBrowse:lDisablePaint := .T.
			oGetTlv:oBrowse:Refresh(.T.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³armazena os dados originais do acols antes de qualquer alteracao		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aColsTlv := aClone(aCols)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for televendas off-line, não exibe a aba com os impostos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lMV_TMKFIS                  
				aTitlesRodape := {aTitlesRodape[1]}
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Sera criado um folder dentro do folder de televendas no rodape da GETTLV³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFoldRodape := TFolder():New(aPosObj5[3,1], aPosObj5[3,2],aTitlesRodape,aPages,oFolderTLV,,,, .T., .F.,aPosObj5[3,3], aPosObj5[3,4],)
			
			For nCont := 1 to Len(oFolder:aDialogs)
				DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nCont]
			Next nCont
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder de totalizadores³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFoldRodape:aDialogs[1]:oFont := oDlg:oFont			

			@ 5,aPosGet[1,1]  SAY If(lMV_TMKFIS,STR0034,"") OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,9 //"Valor Mercadoria"
			@ 4,aPosGet[1,2]  MSGET aObj[MERCADORIA] VAR aValores[MERCADORIA] Picture PesqPict('SUA','UA_VALMERC') OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
	
			If cPaisLoc == "BRA"
				 // Sera implementado no decorrer da versao 7.10 para localizacoes (o MATA468N nao trata o campo C5_DESCONT)
				 @ 5,aPosGet[1,If(lMV_TMKFIS,3,1)]  SAY STR0035 OF oFoldRodape:aDialogs[1] PIXEL SIZE 49,9 //"Descontos"
				 @ 4,aPosGet[1,If(lMV_TMKFIS,4,2)]  MSGET aObj[DESCONTO] VAR aValores[DESCONTO] Picture PesqPict('SUA','UA_DESCONT') OF oFoldRodape:aDialogs[1] PIXEL SIZE 70 ,9 VALID If(ExistBlock("TK271DESROD"),ExecBlock("TK271DESROD",.F.,.F.),.T.) .AND. Tk273Desconto("NF_DESCONTO",@aValores[DESCONTO]) .AND. Positivo(aValores[DESCONTO]) When lDesconto				 
			Else
				 // Em outro pais o desconto no total ficara sempre desabilitado.
				 @ 5,aPosGet[1,If(lMV_TMKFIS,3,1)]  SAY "" OF oFoldRodape:aDialogs[1] PIXEL SIZE 49,9 //"Descontos"
				 @ 4,aPosGet[1,If(lMV_TMKFIS,4,2)]  MSGET aObj[DESCONTO] VAR aValores[DESCONTO] OF oFoldRodape:aDialogs[1] PIXEL VALID Positivo(aValores[DESCONTO]) When .F.
			 	 aObj[DESCONTO]:Hide()
			Endif
		
			@ 19,aPosGet[1,1] SAY If(lMV_TMKFIS,STR0036,"") OF oFoldRodape:aDialogs[1] PIXEL SIZE 58,9 //"Acrescimo"
			@ 19,aPosGet[1,2] MSGET aObj[ACRESCIMO] VAR aValores[ACRESCIMO] Picture PesqPict('SUA','UA_ACRECND') OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9 VALID Positivo(aValores[ACRESCIMO])
	
			@ 19,aPosGet[1,If(lMV_TMKFIS,3,1)] SAY STR0037 OF oFoldRodape:aDialogs[1] PIXEL SIZE 45,9 //"Valor do Frete"
			@ 19,aPosGet[1,If(lMV_TMKFIS,4,2)] MSGET aObj[FRETE] VAR aValores[FRETE]  Picture PesqPict('SUA','UA_FRETE') OF oFoldRodape:aDialogs[1] PIXEL When lHabilita .AND. &(GetSx3Cache("UA_FRETE","X3_WHEN")) SIZE 70 ,9 VALID Tk273RodImposto("NF_FRETE",aValores[FRETE]) .AND. Positivo(aValores[FRETE])
			
			@ 33,aPosGet[1,1] SAY STR0038 OF oFoldRodape:aDialogs[1] PIXEL SIZE 50,9 //"Despesas"
			@ 33,aPosGet[1,2] MSGET aObj[DESPESA] VAR aValores[DESPESA] Picture PesqPict('SUA','UA_DESPESA') OF oFoldRodape:aDialogs[1] PIXEL When lHabilita SIZE 70 ,9 VALID Tk273RodImposto("NF_DESPESA",aValores[DESPESA]) .AND. Positivo(aValores[DESPESA])
			
			@ 33,aPosGet[1,3] SAY If(lMV_TMKFIS,STR0039,"") OF oFoldRodape:aDialogs[1] PIXEL SIZE 58,9 COLOR CLR_RED //"Total do Pedido"
			@ 33,aPosGet[1,4] MSGET aObj[TOTAL] VAR aValores[TOTAL] Picture PesqPict('SUA','UA_VLRLIQ') OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9 COLOR CLR_RED
	
			If cPaisLoc == "BRA"
				@ 5,aPosGet[1,5] SAY If(lMV_TMKFIS,STR0078,"") OF oFoldRodape:aDialogs[1] PIXEL   //"Suframa"
				@ 4,aPosGet[1,6] MSGET aObj[SUFRAMA] VAR aValores[SUFRAMA] Picture PesqPict('SUA','UA_VALMERC') OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
			Else
				@ 5,aPosGet[1,5] SAY "" OF oFoldRodape:aDialogs[1] PIXEL 
				@ 4,aPosGet[1,6] MSGET aObj[SUFRAMA] VAR aValores[SUFRAMA] OF oFoldRodape:aDialogs[1] PIXEL When .F. 
				aObj[SUFRAMA]:Hide()
			Endif
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Esconde os objetos que não devem aparecer quando ³
			//³o parâmetro MV_TMKFIS estiver como N (televendas ³
			//³off-line).                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lMV_TMKFIS				
				aObj[MERCADORIA]:Hide()
				aObj[ACRESCIMO]:Hide()
				aObj[TOTAL]:Hide()
				aObj[SUFRAMA]:Hide()
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o Tipo de desconto definido no posto de venda que o operador atual esta utilizando.                                    ³
			//³Caso o desconto seja diferente de Desconto no Total(2) ou Desconto em ambos (3) o campo de Total de Descontos sera desabilitado.³
			//³Obs.: A funcao TkPosto e executada neste local devido a criacao da enchoice.                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				//Sera implementado no decorrer da versao 7.10 para localizacoes (o MATA468N nao trata o campo C5_DESCONT)
				cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")
				If (Alltrim(cDesconto) <> "2") .AND. (Alltrim(cDesconto) <> "3")  //2-Desconto no total / 3-Desconto em Ambos
					aObj[DESCONTO]:Disable()  //campo Total de descontos rodape.
				Endif
			Endif	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for televendas off-line, não exibe a aba com os impostos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMV_TMKFIS
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder de impostos.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFoldRodape:aDialogs[2]:oFont := oDlg:oFont
				aObj[8] := MaFisRodape(1,oFoldRodape:aDialogs[2],,{0,1,aPosGet[2,1],52},bListRefresh,.T.)
			EndIf
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Objetos do Folder 3 - TELECOBRANCA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TkGetTipoAte() $ "34"  // Telecobranca ou Ambos
			
			DbSelectArea("SX3")
			DbSetOrder(1)
			DbGotop()  // Esse comando foi colocado para evitar desposicionamento no CRIAVAR - QNC - Qualidade 609 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria uma enchoice para os campos do Telecobranca. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegToMemory("ACF",(nOpc == 3))  
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o atendiomento foi executado atraves da CTI.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cCliCti) .AND. !Empty(cLojCti)
				M->ACF_CLIENT := cCliCti
				M->ACF_LOJA   := cLojCti
				M->ACF_DESC	  := TKEntidade(cEntCti,M->ACF_CLIENT + M->ACF_LOJA,1)
				
				M->ACF_CODCON := cContCti
				M->ACF_DESCNT := TkDadosContato(M->ACF_CODCON,6)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Divide a tela verticalmente entre a enchoice e getdados de Telecobranca           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjects := {}
			
			Aadd( aObjects, { 95 , 300 , .T., .T. , .F.} )
			Aadd( aObjects, { 180, 300 , .T., .T. , .F.} )
			Aadd( aObjects, {  66 , 65 , .T., .F. , .T.} )
			
			
			nSizeY   := aPosObj3[ 2,1 ] - 50	
			nSizeX   := aPosObj3[ 2,4 ] - aPosObj3[ 2,2 ] - 2
			aSize5   :=	{0,0,nSizeX,nSizeY} 					//Area reservada para os objetos internos do folder Telemarketing
			aInfo    := { aSize5[ 1 ], aSize5[ 2 ], aSize5[ 3 ], aSize5[ 4 ], 0, 0 }
			aPosObj5 := MsObjSize( aInfo, aObjects, .F. , .F. )
			
			aPosGet := MsObjGetPos(aSize5[3]-aSize5[1],263, {{5,60,140,185}, {260}})
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega os campos que ficarao habilitados na enchoice. O array aTlc contem os titulos que serao cobrados no atendimento.³
			//³Quando nao estiver vazio, significa que alguma das rotinas de atendimento ativo (Agenda do Operador ou Pre-Atendimento) ³
			//³alimentou esse array para preencher automaticamente a getdados do atendimento.                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aTLC) > 0
				// Se entrou aqui o atendimento sera ATIVO
				Tk274Atend("01", aTLC, @aCampACF, nOpc)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se trabalha com lista de cobranca executada pela agenda do operador o atendimento devera ser ATIVO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If l380 .AND. SK0->K0_ORDEM == "000001" .AND. SK0->K0_PRAZO == "999999"
					Tk274Atend("01", aTLC, @aCampACF, nOpc)
				Else
					Tk274Campos(@aCampACF, .F., nOpc)		// Considera todos os campos para RECEPTIVO
				Endif
			Endif
			
			Zero()
			oEnchTlc:=   MsMGet():New("ACF", nReg, nOpc, aAC,"AC",STR0051,,aPosObj5[1],aCampACF,,,,,oFolderTlc,,.T.,,NIL,.T.) 	//"Quanto a exclusao ?"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta o aCols e aHeader para a Telecobranca³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			aGets := AClone( aGets3 )
			aTela := AClone( aTela3 )  			 
			aHeader  := {}
			aCols    := {}
			aHeader  := aClone(aSvFolder[3][1])
			aCols    := aClone(aSvFolder[3][2])
			n		 := aSvFolder[3][3]

			
			oGetTlc:= MSGetDados():New(aPosObj5[2,1],aPosObj5[2,2],aPosObj5[2,3],aPosObj5[2][4],nOpc,"Tk274EvaTlc","Allwaystrue","",.F.,,,.F.,Len(aCols),,,,,oFolderTLC)
			
			nPosSit := aScan(aHeader, {|x| AllTrim(x[2]) == "ACG_DSITCB"}) 
			If nPosSit > 0
				nPosSit := aScan(aHeader, {|x| AllTrim(x[2]) == "ACG_SITUAC"}) 
				If nPosSit > 0	
					oGetTlc:aInfo[nPosSit][2] := " "
					oGetTlc:aInfo[nPosSit][6] := " "
					oGetTlc:oBrowse:aColumns[nPosSit]:bData := {|| Transform(aCols[n][nPosSit],TRIM(aHeader[nPosSit][3]))  }
				EndIf
			EndIf

			oGetTlc:oBrowse:bGotFocus	:= {||Tk271CabOk(oEnchTlc,lExibeHelp,lHabilita) }
			oGetTlc:oBrowse:lDisablePaint := .T.
			oGetTlc:oBrowse:Refresh(.T.)
 			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Sera criado um folder dentro do folder de televendas no rodape da GETTLV³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFoldRodape := TFolder():New(aPosObj5[3,1], aPosObj5[3,2],{STR0065,STR0066},{},oFolderTLC,,,, .T., .F.,aPosObj5[3,3], aPosObj5[3,4],) //"Variações"###"Saldos"
			
			oFoldRodape:aDialogs[1]:oFont := oDlg:oFont
			
			If nOpc <> 4 .AND. nOpc <> 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Limpa o rodape de Telecobranca³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Tk274LimpaRdp()
			Endif
					
			// [2] Abatimentos
			// [A] Correcao Monetaria
			// [8] Juros
			// [5] Acrescimo
			// [4] Decrescimo
			// [9] Desconto
			
			@ 5,aPosGet[1,1]  SAY STR0067 OF oFoldRodape:aDialogs[1] PIXEL //"Abatimentos"
			@ 5,aPosGet[1,2]  MSGET aRdpTlc[1][1] VAR aRdpTlc[1][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
			
			@ 19,aPosGet[1,1] SAY STR0068 OF oFoldRodape:aDialogs[1] PIXEL //"Correções Monetária"
			@ 19,aPosGet[1,2] MSGET aRdpTlc[2][1] VAR aRdpTlc[2][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
			
			@ 33,aPosGet[1,1] SAY STR0069 OF oFoldRodape:aDialogs[1] PIXEL //"Juros"
			@ 33,aPosGet[1,2] MSGET aRdpTlc[3][1] VAR aRdpTlc[3][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
			
			@ 5,aPosGet[1,3]  SAY STR0070 OF oFoldRodape:aDialogs[1] PIXEL //"Acréscimos"
			@ 5,aPosGet[1,4]  MSGET aRdpTlc[4][1] VAR aRdpTlc[4][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
			
			@ 19,aPosGet[1,3] SAY STR0071 OF oFoldRodape:aDialogs[1] PIXEL //"Decréscimos"
			@ 19,aPosGet[1,4] MSGET aRdpTlc[5][1] VAR aRdpTlc[5][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
			
			@ 33,aPosGet[1,3] SAY STR0035 OF oFoldRodape:aDialogs[1] PIXEL //"Descontos"
			@ 33,aPosGet[1,4] MSGET aRdpTlc[6][1] VAR aRdpTlc[6][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70 ,9
			
			
			// [1] Valor Original do Titulo
			// [6] Saldo do Titulo na Moeda do Titulo
			// [7] Saldo do Titulo na Moeda Corrente
			// [3] Pagto Parcial
			// [B] Valor a ser Recebido na moeda do titulo
			// [C] Valor a ser Recebido na moeda corrente
			
			@ 5,aPosGet[1,1]  SAY STR0072 OF oFoldRodape:aDialogs[2] PIXEL //"Valores Originais"
			@ 5,aPosGet[1,2]  MSGET aRdpTlc[7][1] VAR aRdpTlc[7][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[2] PIXEL When .F. SIZE 70 ,9
			
			@ 19,aPosGet[1,1] SAY STR0073 OF oFoldRodape:aDialogs[2] PIXEL //"Saldos Moeda Titulo"
			@ 19,aPosGet[1,2] MSGET aRdpTlc[8][1] VAR aRdpTlc[8][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[2] PIXEL When .F. SIZE 70 ,9
			
			@ 33,aPosGet[1,1] SAY STR0074 OF oFoldRodape:aDialogs[2] PIXEL //"Saldos Moeda Corrente"
			@ 33,aPosGet[1,2] MSGET aRdpTlc[9][1] VAR aRdpTlc[9][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[2] PIXEL When .F. SIZE 70 ,9
			
			@ 5,aPosGet[1,3]  SAY STR0075 OF oFoldRodape:aDialogs[2] PIXEL //"Pagamentos Parciais"
			@ 5,aPosGet[1,4]  MSGET aRdpTlc[10][1] VAR aRdpTlc[10][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[2] PIXEL When .F. SIZE 70 ,9
			
			@ 19,aPosGet[1,3] SAY STR0076 OF oFoldRodape:aDialogs[2] PIXEL COLOR CLR_RED //"Dívida Moeda Título"
			@ 19,aPosGet[1,4] MSGET aRdpTlc[11][1] VAR aRdpTlc[11][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[2] PIXEL When .F. SIZE 70 ,9 COLOR CLR_RED
			
			@ 33,aPosGet[1,3] SAY STR0077 OF oFoldRodape:aDialogs[2] PIXEL COLOR CLR_RED //"Dívida Moeda Corrente"
			@ 33,aPosGet[1,4] MSGET aRdpTlc[12][1] VAR aRdpTlc[12][2] Picture PesqPict("SE1","E1_VALOR") OF oFoldRodape:aDialogs[2] PIXEL When .F. SIZE 70 ,9 COLOR CLR_RED
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega os itens da tela de atendimento no caso de ser ATIVO e monta os valores do rodape³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Tk274Atend("02", aTLC, @aCampACF, nOpc)

		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Divide a tela lateralmente para os objetos do historico       	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		
		Aadd( aObjects, { 100, 7 , .T., .F. , .T.} )
		Aadd( aObjects, { 100, 7 , .T., .F. , .T.} )
		Aadd( aObjects, { 100, 7 , .T., .F. , .T.} )
		Aadd( aObjects, { 100, 7 , .T., .F. , .T.} )
		Aadd( aObjects, { 100, 7 , .T., .F. , .T.} )
		Aadd( aObjects, { 100, 7 , .T., .F. , .T.} )
		
		aSize4   :=	aPosObj3[ 2 ] //Area reservada para os objetos do historico
		aInfo    := { aSize4[ 2 ], aSize4[ 1 ], aSize4[ 4 ], aSize4[ 3 ], 0, 0 }
		aPosObj4 := MsObjSize( aInfo, aObjects, .T. , .T. )
		
		//Dados da ultima liga‡ao do cliente: Data, Operador, e a Pr¢xima liga‡ao (SU4)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para descobrir a posicao X dos says que exibirao os     ³
		//³dados da ultima ligacao foi somado a posicao X do label ³
		//³com o size X do label.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ aPosObj4[1,1], aPosObj4[1,2] SAY STR0031 OF oDlg PIXEL COLOR CLR_BLUE //"Ultima liga‡„o"
		@ aPosObj4[1,1]+aPosObj4[1,4], aPosObj4[1,2] SAY oLigacao VAR cLigacao SIZE aPosObj4[1,3],aPosObj4[1,4] OF oDlg PIXEL
		
		@ aPosObj4[2,1], aPosObj4[2,2]  SAY STR0047 OF oDlg PIXEL COLOR CLR_BLUE //"Operador"
		@ aPosObj4[2,1]+aPosObj4[2,4], aPosObj4[2,2] SAY oOperador VAR FATPDObfuscate(cOperador,"U7_NOME","TMKA271") SIZE aPosObj4[2,3],aPosObj4[2,4] OF oDlg PIXEL
		
		@ aPosObj4[3,1], aPosObj4[3,2] SAY STR0032 OF oDlg PIXEL COLOR CLR_BLUE //"Status"
		@ aPosObj4[3,1]+aPosObj4[3,4], aPosObj4[3,2] SAY oStatus VAR cStatus SIZE aPosObj4[3,3], aPosObj4[3,4] OF oDlg PIXEL
		
		@ aPosObj4[4,1], aPosObj4[4,2] SAY STR0048 OF oDlg PIXEL COLOR CLR_BLUE //"Operacao"
		@ aPosObj4[4,1]+aPosObj4[4,4], aPosObj4[4,2] SAY oOperacao VAR cOperacao SIZE aPosObj4[4,3], aPosObj4[4,4] OF oDlg PIXEL
		
		@ aPosObj4[5,1], aPosObj4[5,2] SAY STR0033 OF oDlg PIXEL COLOR CLR_BLUE //"Pr¢xima liga‡„o"
		@ aPosObj4[5,1]+aPosObj4[5,4], aPosObj4[5,2] SAY oProximo VAR FATPDObfuscate(cProximo,"U7_NOME","TMKA271") SIZE aPosObj4[5,3], aPosObj4[5,4] OF oDlg PIXEL
		// Cria o Cronometro para acompanhar o tempo da liga‡„o
		@ aPosObj4[6,1], aPosObj4[6,2] SAY oCrono VAR cCrono PIXEL FONT oFnt1 COLOR CLR_BLUE SIZE 55,15 PICTURE "99:99" OF oDlg
		DEFINE TIMER oTimerCro INTERVAL 10000 ACTION Tk271AtuCro(	@nTimeSeg	,@nTimeMin	,cTimeOut	,@cCrono	,;
																	@oCrono		) OF oDlg

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Divide a tela lateralmente para os objetos do historico       	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		
		Aadd( aObjects, { 50, 8 , .T., .F. , .T.} )
		Aadd( aObjects, { 50, 8 , .T., .F. , .T.} )

		aSize6   :=	aPosObj3[ 2 ] //Area reservada para os objetos do historico
		aInfo    := { aSize6[ 2 ], aSize6[ 1 ], aSize6[ 4 ], aSize6[ 3 ], 0, 0 }
		aPosObj6 := MsObjSize( aInfo, aObjects, .T. , .T. )

		// Insere os dados do contato e da entidade para ficarem sempre visiveis para o Operador
		@ aPosObj6[1,1]+12, aPosObj6[1,2] SAY STR0096 OF oDlg PIXEL COLOR CLR_BLUE	//Entidade
		@ aPosObj6[1,1]+12, aPosObj6[1,2]+22 SAY oNomeHist VAR FATPDObfuscate(cNomeHist,"A1_NOME","TMKA271") SIZE aPosObj6[1,3],aPosObj6[1,4] OF oDlg PIXEL COLOR CLR_RED
		
		@ aPosObj6[2,1]+12, aPosObj6[2,2] SAY STR0091 OF oDlg PIXEL COLOR CLR_BLUE	//Contato
		@ aPosObj6[2,1]+12, aPosObj6[2,2]+26 SAY oContHist VAR FATPDObfuscate(cContHist,"U5_CONTAT","TMKA271") SIZE aPosObj6[2,3],aPosObj6[2,4] OF oDlg PIXEL COLOR CLR_RED
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa o cronometro e as variaveis genericas do atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk274Atend("03", aTLC, @aCampACF, nOpc)
		
		Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a resolucao por de 800 x 600 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			Case aResol[1] == 800 .AND. aResol[2] == 600
				
				oDlg:lMaximized := .F.
				oDlg:setMinimumSize( 2000,2000 )
				oDlg:lCentered  := .F.
				
			Case aResol[1] > 800 .AND. aResol[2] > 600
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Maximiza a tela na abertura³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oDlg:lMaximized :=.T.
		Endcase
			
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bOk, bCancel, .F., aButBar,,,,,.F. ),;
									Tk271ChangeFolder(	1			,0			,@oBtn		,@aBtn		,;
														@aCfgBtn	,aCfgBtnOri	,@nOpc		,oPanelTmk	,;
														oPanelTlv	,oPanelTlc	,@oEnchTlv	,@lHabilita	),;
									Tk271Init(	@aItens		,nOpc			,@lHabilita		,oFolderTlv,;
												@oEnchTlv	,@cCodPagto		,@cDescPagto	,@cCodTransp,;
												@cTransp	,@cCob			,@cEnt			,@cCidadeC	,;
												@cCepC		,@cUfC			,@cBairroE		,@cBairroC	,;
												@cCidadeE	,@cCepE			,@cUfE			,@nLiquido	,;
												@nTxJuros	,@nTxDescon		,@nVlJur		,@aParcelas	,;
												@nEntrada	,@nFinanciado	,@nNumParcelas 	,@nValorCC	,;
												@aColsTlv	,@cCodAnt		,@cTimeOut		,cCliCti	,;
												cLojCti		,@oFolderTmk	,@oEnchTmk		,cEntCti	,;
												@cCliAnt	,cAlias			,@oEnchTlc		,l380	   ),;
									SetKEY(15,bOk),;			// OK - CTRL + O
	    							oDlg:bSet15:= bOk,;
									SetKEY(24,bCancel),;			// CANCEL - CTRL + X
									Iif(!Empty(cMens),(M->UC_OBS := cMens),""),;
	    							IIF(LTMKACTIVE,ExecBlock( "TMKACTIVE", .F., .F. ),""));
							VALID IF(Tk271CanHab( l380, lPriContato ),TK271Fim(nOpc,lMsg),.F.) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informa ao gerenciador de múltiplos grupos de atendimento³
	//³que a rotina call center não está mais em execução.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK091End( CALLCENTER )		

	oMonoAs:End()
	oFnt1:End()
	FATPDUnload("TMKA271")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas pela rotina de entrada  automatica     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando o operador estiver configurado para utilizar todas as ³
	//³rotinas de atendimento executo o RegToMemory para os 3 Alias ³
	//³SUA e SUC e ACF, pois algumas funcoes utilizam campos de     ³
	//³memoria nao somente do Alias ativo, mas tambem dos outros  	³
	//³Alias da rotina de atendimento.                             	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 	If TkGetTipoAte() == "4"  //Ambos                   
	 	RegToMemory("SUC",(nOpc == 3))  
		RegToMemory("SUA",(nOpc == 3))  
		RegToMemory("ACF",(nOpc == 3))  
 	ElseIf cAliasAuto == "SUC"
		RegToMemory("SUC",(nOpc == 3))   		 
	ElseIf cAliasAuto == "SUA"
		RegToMemory("SUA",(nOpc == 3))
	ElseIf cAliasAuto == "ACF"
		RegToMemory("ACF",(nOpc == 3))
 	Endif

	SU7->(DbSetOrder(1))
 		
 	Do Case
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara para rotina automatica Telemarketing³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cAliasAuto == "SUC" //Telemarketing
			aGets := AClone( aGets1 )
			aTela := AClone( aTela1 )  			
			aHeader := aClone(aSvFolder[1][1])
			aCols   := aClone(aSvFolder[1][2])
			
			If EnchAuto(cAliasAuto,aAutoCab,{|| Obrigatorio(aGets,aTela)})
				If MsGetDAuto(aAutoItens,"Tk272EvaTmk",{|| Tk272GetTmk()},aAutoCab,aRotina[nOpc][4])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa a rotina de gravacao do Telemarketing³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet:=	TK272GrvTmk(nOpc		,@oFolderTmk,@cMotivo	,@cEncerra,;
										@lHabilita	,aColsTmk	,l380		,aSx3SUC)
					
				Endif	
            Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara para rotina automatica Televendas   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cAliasAuto == "SUA" //Televendas
			aGets := AClone( aGets2 )
			aTela := AClone( aTela2 )      
			aHeader := aClone(aSvFolder[2][1])
			aCols   := aClone(aSvFolder[2][2])
            n		:= (aSvFolder[2][3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza a variavel Private lProspect antes de validar a enchoice³
			//³para validar o codigo do Cliente e Loja passado no array aAutoCab³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ProcTmk("UA_PROSPEC")  > 0
				lProspect:= aAutoCab[ProcTmk("UA_PROSPEC")][2]
			Endif	

			If EnchAuto(cAliasAuto,aAutoCab,{|| Obrigatorio(aGets,aTela)})
				
				aValidGet := {}
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa  a validacao dos gets fixos - funcoes que serao executadas para cada get fixo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aVldBlock := {}
                AAdd(aVldBlock,{||Tk273Desconto("NF_DESCONTO",@aValores[DESCONTO])}) //01
                AAdd(aVldBlock,{||Tk273RodImposto("NF_FRETE",aValores[FRETE])})//02
                AAdd(aVldBlock,{||Tk273RodImposto("NF_DESPESA",aValores[DESPESA])})//03
				AAdd(aVldBlock,{||Tk273InitPagto(	cNumTlv		,M->UA_CLIENTE	,M->UA_LOJA		,nOpc		,;
													@cCodPagto	,oCodPagto		,@cDescPagto	,oDescPagto	,;
													@cCodTransp	,oCodTransp		,@cTransp		,oTransp	,;
													@cCob		,oCob			,@cEnt			,oEnt		,;
													@cCidadeC	,oCidadeC		,@cCepC			,oCepC		,;
													@cUfC		,oUfC			,@cBairroE		,oBairroE	,;
													@cBairroC	,oBairroC		,@cCidadeE		,oCidadeE	,;
													@cCepE		,oCepE			,@cUfE			,oUfE		,;
													@cCliAnt),;
								  Tk273MontaParcela(nOpc			,cNumTlv	,@nLiquido		,oLiquido		,;
													@nTxJuros		,oTxJuros	,@nTxDescon		,oTxDescon		,;
													@aParcelas		,oParcelas	,@cCodPagto		,oCodPagto		,;
													@nEntrada		,oEntrada	,@nFinanciado	,oFinanciado	,;
													@cDescPagto		,oDescPagto	,@nNumParcelas	,oNumParcelas	,;
													@nVlrPrazo		,oVlrPrazo	,@nVlJur		,@cCodAnt		,;
													@lTipo9			,nValNFat	,oValNFat		,.F.			,;
													.F.				)})//04
				AAdd(aVldBlock,{||Tk273AtuTransp(cCodTransp,@cTransp,oTransp)})//05
				AAdd(aVldBlock,{||Tk273CidC(@oCidadeC,@cCidadeC)})//06
				AAdd(aVldBlock,{||Tk273CepC(@cCepC	,@oCepC	,@cCidadeC	,@oCidadeC,;
											@cUfC	,@oUfC	,@cBairroC	,@oBairroC)})//07
				AAdd(aVldBlock,{||Tk273Estado(cUfc)})//08
                AAdd(aVldBlock,{||Tk273CidE(@oCidadeE,@cCidadeE)})//09
                AAdd(aVldBlock,{||Tk273CepE(@cCepE	,@oCepE	,@cCidadeE	,@oCidadeE,;
                						  	@cUfE	,@oUfE	,@cBairroE	,@oBairroE)})//10
                AAdd(aVldBlock,{||Tk273Estado(cUfe)})//11
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega o array de validacao de gets - aValidGet - com os gets fixos e suas respectivas:³
				//³1 - variaveis de memoria                                                                ³
				//³2 - conteudo inicial                                                                    ³
				//³3 - validacao do get                                                                    ³
				//³4 - Flag logico default (.T.)                                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IIF(ProcTmk("UA_DESCONT") 	>0, AADD(aValidGet,{"aValores[2]"	,aAutoCab[ProcTmk("UA_DESCONT")	,2],"Eval(aVldBlock[1])",.T.}),"")//01
				IIF(ProcTmk("UA_FRETE")  	>0, AADD(aValidGet,{"aValores[4]"	,aAutoCab[ProcTmk("UA_FRETE")	,2],"Eval(aVldBlock[2])",.T.}),"")//02
				IIF(ProcTmk("UA_DESPESA") 	>0, AADD(aValidGet,{"aValores[5]"	,aAutoCab[ProcTmk("UA_DESPESA")	,2],"Eval(aVldBlock[3])",.T.}),"")//03
				IIF(ProcTmk("UA_CONDPG")	>0, AADD(aValidGet,{"cCodPagto"		,aAutoCab[ProcTmk("UA_CONDPG") 	,2],"Eval(aVldBlock[4])",.T.}),"")//04
				IIF(ProcTmk("UA_TRANSP")	>0, AADD(aValidGet,{"cCodTransp"	,aAutoCab[ProcTmk("UA_TRANSP") 	,2],"Eval(aVldBlock[5])",.T.}),"")//05
				IIF(ProcTmk("UA_ENDCOB")	>0, AADD(aValidGet,{"cCob"  		,aAutoCab[ProcTmk("UA_ENDCOB")	,2],,.T.}),"")                    //06
				IIF(ProcTmk("UA_BAIRROC")	>0, AADD(aValidGet,{"cBairroC"		,aAutoCab[ProcTmk("UA_BAIRROC")	,2],,.T.}),"")                    //07
				IIF(ProcTmk("UA_MUNC") 		>0, AADD(aValidGet,{"cCidadeC"		,aAutoCab[ProcTmk("UA_MUNC")	,2],"Eval(aVldBlock[6])",.T.}),"")//08
				IIF(ProcTmk("UA_CEPC")		>0, AADD(aValidGet,{"cCepC"  		,aAutoCab[ProcTmk("UA_CEPC")	,2],"Eval(aVldBlock[7])",.T.}),"")//09
				IIF(ProcTmk("UA_ESTC")		>0, AADD(aValidGet,{"cUfC"  		,aAutoCab[ProcTmk("UA_ESTC")	,2],"Eval(aVldBlock[8])",.T.}),"")//10
				IIF(ProcTmk("UA_ENDENT")	>0, AADD(aValidGet,{"cEnt"   		,aAutoCab[ProcTmk("UA_ENDENT")	,2],,.T.}),"")                    //11
				IIF(ProcTmk("UA_BAIRROE")	>0, AADD(aValidGet,{"cBairroE" 		,aAutoCab[ProcTmk("UA_BAIRROE")	,2],,.T.}),"")                    //12
				IIF(ProcTmk("UA_MUNE")		>0, AADD(aValidGet,{"cCidadeE" 		,aAutoCab[ProcTmk("UA_MUNE") 	,2],"Eval(aVldBlock[9])",.T.}),"")//13
				IIF(ProcTmk("UA_CEPE")		>0, AADD(aValidGet,{"cCepE"  		,aAutoCab[ProcTmk("UA_CEPE")	,2],"Eval(aVldBlock[10])",.T.}),"")//14
				IIF(ProcTmk("UA_ESTE")		>0, AADD(aValidGet,{"cUfE"   		,aAutoCab[ProcTmk("UA_ESTE")	,2],"Eval(aVldBlock[11])",.T.}),"")//15

				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza as variaveis dos gets fixos antes da execucao das validacoes - porque as variaveis sao "local"³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ProcTmk("UA_DESCONT") > 0
					nPos:=ProcTmkVld("aValores[2]") 
					IIF(nPos > 0,aValores[2]:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_FRETE")  > 0
					nPos:=ProcTmkVld("aValores[4]") 
					IIF(nPos > 0,aValores[4]:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_DESPESA") > 0
					nPos:=ProcTmkVld("aValores[5]") 
					IIF(nPos > 0,aValores[5]:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_CONDPG") > 0
					nPos:=ProcTmkVld("cCodPagto")
					IIF(nPos > 0,cCodPagto:=aValidGet[nPos,2],"")
				Endif	
					
				If ProcTmk("UA_TRANSP") > 0
					nPos:=ProcTmkVld("cCodTransp")
					IIF(nPos > 0,cCodTransp:=aValidGet[nPos,2],"")
				Endif	
				
				If ProcTmk("UA_ENDCOB") > 0
					nPos:=ProcTmkVld("cCob")
					IIF(nPos > 0,cCob:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_BAIRROC") > 0
					nPos:=ProcTmkVld("cBairroC")
					IIF(nPos > 0,cBairroC:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_MUNC") > 0
					nPos:=ProcTmkVld("cCidadeC")
					IIF(nPos > 0,cCidadeC:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_CEPC") > 0
					nPos:=ProcTmkVld("cCepC")
					IIF(nPos > 0,cCepC:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_ESTC") > 0
					nPos:=ProcTmkVld("cUfC")
					IIF(nPos > 0,cUfC:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_ENDENT") > 0
					nPos:=ProcTmkVld("cEnt")
					IIF(nPos > 0,cEnt:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_BAIRROE") > 0
					nPos:=ProcTmkVld("cBairroE") 
					IIF(nPos > 0,cBairroE:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_MUNE") > 0
					nPos:=ProcTmkVld("cCidadeE")
					IIF(nPos > 0,cCidadeE:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_CEPE") > 0
					nPos:=ProcTmkVld("cCepE")
					IIF(nPos > 0,cCepE:=aValidGet[nPos,2],"")
				Endif	

				If ProcTmk("UA_ESTE") > 0
					nPos:=ProcTmkVld("cUfE")
					IIF(nPos > 0,cUfE:=aValidGet[nPos,2],"")
				Endif	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Consiste a GetDados - SUB    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If MsGetDAuto(aAutoItens,"Tk273EvaLi",{|| Tk273GetOk()},aAutoCab,aRotina[nOpc][4])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Consiste somente os Gets Fixos (Condicao de Pagamento)            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SUA->(MsVldGAuto(aValidGet)) 
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza novamente as variaveis dos gets fixos porque elas podem ser sido ³
						//³alteradas nas suas validacoes de get. Exemplo Codigo de transportadora    ³
						//³quando nao e informado o sistema carrega do cadastro de clientes          ³
						//³                                                                          ³
						//³Essas variaveis serao utilizadas na gravacao da rotina de Televendas      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ProcTmk("UA_DESCONT") > 0
							nPos:=ProcTmkVld("aValores[2]") 
							IIF(nPos > 0,aValores[2]:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_FRETE")  > 0
							nPos:=ProcTmkVld("aValores[4]") 
							IIF(nPos > 0,aValores[4]:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_DESPESA") > 0
							nPos:=ProcTmkVld("aValores[5]") 
							IIF(nPos > 0,aValores[5]:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_CONDPG") > 0
							nPos:=ProcTmkVld("cCodPagto")
							IIF(nPos > 0,cCodPagto:=aValidGet[nPos,2],"")
						Endif	
							
						If ProcTmk("UA_TRANSP") > 0
							nPos:=ProcTmkVld("cCodTransp")
							IIF(nPos > 0,cCodTransp:=aValidGet[nPos,2],"")
						Endif	
						
						If ProcTmk("UA_ENDCOB") > 0
							nPos:=ProcTmkVld("cCob")
							IIF(nPos > 0,cCob:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_BAIRROC") > 0
							nPos:=ProcTmkVld("cBairroC")
							IIF(nPos > 0,cBairroC:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_MUNC") > 0
							nPos:=ProcTmkVld("cCidadeC")
							IIF(nPos > 0,cCidadeC:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_CEPC") > 0
							nPos:=ProcTmkVld("cCepC")
							IIF(nPos > 0,cCepC:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_ESTC") > 0
							nPos:=ProcTmkVld("cUfC")
							IIF(nPos > 0,cUfC:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_ENDENT") > 0
							nPos:=ProcTmkVld("cEnt")
							IIF(nPos > 0,cEnt:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_BAIRROE") > 0
							nPos:=ProcTmkVld("cBairroE") 
							IIF(nPos > 0,cBairroE:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_MUNE") > 0
							nPos:=ProcTmkVld("cCidadeE")
							IIF(nPos > 0,cCidadeE:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_CEPE") > 0
							nPos:=ProcTmkVld("cCepE")
							IIF(nPos > 0,cCepE:=aValidGet[nPos,2],"")
						Endif	
		
						If ProcTmk("UA_ESTE") > 0
							nPos:=ProcTmkVld("cUfE")
							IIF(nPos > 0,cUfE:=aValidGet[nPos,2],"")
						Endif							
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa a rotina de gravacao do Televendas³
						//³O processo de gravacao e o mesmo com ou   ³
						//³sem rotina automatica. 					 ³	
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lRet:=	(Tk273GrvTel(@nOpc		,@oFolderTlv	,@cCodPagto		,@cDescPagto,;
											@cCodTransp	,@cTransp		,@cCob			,@cEnt,;
											@cCidadeC	,@cCepC			,@cUfC			,@cBairroE,;
											@cBairroC	,@cCidadeE		,@cCepE			,@cUfE,;
											@nLiquido	,@nTxJuros		,@nTxDescon		,nVlJur,;
											@aParcelas	,@nEntrada		,@nFinanciado	,@nNumParcelas,;
											@nValorCC	,@lHabilita		,aColsTlv		,l380,;
											aSx3Sua		,@nValNFat		,cCliAnt		,lSigaCRD)) 
											
		            Endif
		            
		        Endif    
		    Endif                                                    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara para rotina automatica Telecobranca ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cAliasAuto == "ACF" //Telecobranca 
			aGets := AClone( aGets3 )
			aTela := AClone( aTela3 )  			
			aHeader  := aClone(aSvFolder[3][1])
			aCols    := aClone(aSvFolder[3][2])

			If EnchAuto(cAliasAuto,aAutoCab,{|| Obrigatorio(aGets,aTela)})
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa  a validacao dos gets fixos - funcoes que serao executadas para cada get fixo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aValidGet := {}
				aVldBlock := {}
				
				If ProcTmk("ACF_CODENC") > 0
					AADD(aValidGet,{"cEncerra"	,aAutoCab[ProcTmk("ACF_CODENC") ,2],,.T.})
				Endif
				If ProcTmk("ACF_OBSMOT") > 0
					AADD(aValidGet,{"cMotivo"	,aAutoCab[ProcTmk("ACF_OBSMOT") ,2],,.T.})
				Endif	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza as variaveis dos gets fixos antes da execucao das validacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ProcTmk("ACF_CODENC") > 0
					nPos:=ProcTmkVld("cEncerra")
					IIF(nPos > 0,cEncerra:=aValidGet[nPos,2],"")
				Endif	
								
				If ProcTmk("ACF_OBSMOT") > 0
					nPos:=ProcTmkVld("cMotivo")
					IIF(nPos > 0,cMotivo:=aValidGet[nPos,2],"")
				Endif	

				If MsGetDAuto(aAutoItens,"Tk274CalcJuros(@aValores,@aCols,aHeader)",{|| Tk274GetOK()},aAutoCab,aRotina[nOpc][4])
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Consiste somente os Gets Fixos (Encerramento)   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ACF->(MsVldGAuto(aValidGet)) 

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa a rotina de gravacao do Telecobranca ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lRet := TK274GrvTlc(nOpc	,@oFolderTlc,@lHabilita	,l380,;
					   						cAgenda	,aSX3ACF	,cEncerra	,cMotivo)
	
					Endif	
				
				Endif
					
            Endif

	EndCase
	
Endif

// Verifica se eh televenda e libera os atendimento bloqueados.
If ((TkGetTipoAte() == "2") .OR. (nFolder == 2)) .And. !Empty(cLock)
	UnLockByName(cLock,.T.,FWModeAccess("SUA",3) == "E",.T.)
	cLock := ""
ElseIf ((TkGetTipoAte() == "1") .OR. (nFolder == 1)) .And. !Empty(cLock)
	UnLockByName(cLock,.T.,FWModeAccess("SUC",3) == "E",.T.)
	cLock := ""
EndIf
	
//Encerra as operacoes fiscais
MaFisEnd()

//Devolucao da area anterior
RestArea(aArea)

MaReleTabPrc()//Limpa array da tabela de preço

Return(lRet)

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Init    ³ Autor ³ Vendas Clientes     ³ Data ³ 26/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³1) Carrega a tabela das formas em memoria 				   ³±±
±±³          ³2) Se o atendimento escolhido para alteracao/visualizacao for³±±
±±³          ³televendas carrega os dados da condicao de pagamento.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271Init(	aItens		,nOpc		,lHabilita		,oFolderTlv		,;
							oEnchTlv	,cCodPagto	,cDescPagto		,cCodTransp		,;
							cTransp		,cCob		,cEnt			,cCidadeC		,;
							cCepC		,cUfC		,cBairroE		,cBairroC		,;
							cCidadeE	,cCepE		,cUfE			,nLiquido		,;
							nTxJuros	,nTxDescon	,nVlJur			,aParcelas		,;
							nEntrada	,nFinanciado,nNumParcelas	,nValorCC		,;
							aColsTlv	,cCodAnt	,cTimeOut		,cCliCti		,;
							cLojCti		,oFolderTmk	,oEnchTmk		,cEntCti		,;
							cCliAnt,	cAlias		,oEnchTlc		,l380			)
							
Local nLinha	:= 0										// Contador auxiliar do FOR/NEXT
Local nPQtd     := aPosicoes[4][2]							// Posicao da Quantidade
Local nPVrUnit  := aPosicoes[5][2]							// Posicao do Valor Unitario
Local nPVlrItem := aPosicoes[6][2]							// Posicao do Valor do item 
Local cTipo		:= ""										// Varivel auxilar para o tipo (Campo TIPO do SA1/SUS)
Local lTK271TpCl	:= FindFunction("P_TK271TCL")				//Retorn tipo do cliente para simulação fiscal
Local nPTes 	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UB_TES"})
Local nPValDesc	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UB_VALDESC"})	
Local lTKTipCli	:= ExistBlock("TKTIPCLI")				    //Ponto de entrada que permita customizar gravação do tipo decliente no pedido de vendas.
Local aDadosSX3 := {}
Local nAcresRat	:= 0
Local cNaturez	:= ""
Local lCliEntreg:= SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0

If (TkGetTipoAte() == "1")  // Telemarketing

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tempo medio de atendimento desse operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeOut := TkPosto(M->UC_OPERADO,"U0_TEMPCRO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "TMK0")
	
Elseif (TkGetTipoAte() == "2" ) //Televendas 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega a lista  com formas de pagamentos (DINHEIRO,CHEQUE..)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aItens := {}
	DbSelectArea("SX5")
	DbSeek( xFilial("SX5")+"24" )
	While ! SX5->(Eof()) .AND. xFilial("SX5")==X5_FILIAL .AND. X5_TABELA == "24"
		Aadd(aItens,{X5DESCRI(),ALLTRIM(X5_CHAVE)})
		SX5->(DbSkip())
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tempo medio de atendimento desse operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeOut := TkPosto(M->UA_OPERADO,"U0_TEMPCRO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "TLV0")
			
Elseif (TkGetTipoAte() == "3" ) //Telecobranca
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tempo medio de atendimento desse operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeOut := TkPosto(M->ACF_OPERAD,"U0_TEMPCRO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "TLC0")

ElseIf (TkGetTipoAte() $ "45" ) //Ambos e TMK x TLV

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega a lista  com formas de pagamentos (DINHEIRO,CHEQUE..)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aItens := {}
	DbSelectArea("SX5")
	DbSeek( xFilial("SX5")+"24" )
	While ! SX5->(Eof()) .AND. xFilial("SX5")==X5_FILIAL .AND. X5_TABELA == "24"
		Aadd(aItens,{X5DESCRI(),ALLTRIM(X5_CHAVE)})
		SX5->(DbSkip())
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tempo medio de atendimento desse operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeOut := TkPosto(M->UC_OPERADO,"U0_TEMPCRO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGrvSUV(__cUserId, "TMK0")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do cliente / contato e atualiza tambem o rodape.                                               ³
//³Quando as variaveis cCliCti e cLojCti estiverem preenchidas, significa que a tela de atendimento foi chamada     ³
//³por uma das rotinas: Pre-Atendimento, Agenda do Operador ou pela Thread da CTI.	 								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCliCti) .AND. !Empty(cLojCti) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza apenas o primeiro folder porque a tela de atendimento eh aberta apenas para uma rotina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ( cAlias == "SUC" ) 		// Telemarketing
		
		TKCliente(cEntCti,cCliCti+cLojCti,nOpc,oEnchTmk, l380)
							
	ElseIf ( cAlias == "SUA" )	// TeleVendas 
		
		TKCliente(cEntCti,cCliCti+cLojCti,nOpc,oEnchTlv, l380)

	ElseIf ( cAlias == "ACF" )	// Telecobranca
		
		TKCliente(cEntCti,cCliCti+cLojCti,nOpc,oEnchTlc, l380)
	Endif

Endif

If (nOpc <> 3)  //Se a opcao nao for INCLUSAO

	If 	( nFolder == 1 .AND. TkGetTipoAte() == "2" ) .OR.;
		( nFolder == 2 .AND. TkGetTipoAte() == "2" ) .OR.;
		( nFolder == 2 .AND. TkGetTipoAte() $ "45" ) //Televendas 
                
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Na alteracao inicializa as funcoes fiscais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 4 .OR. nOpc == 2   
			lProspect := SUA->UA_PROSPEC

			If lProspect
				cTipo := Posicione("SUS",1,xFilial("SUS") + SUA->UA_CLIENTE + SUA->UA_LOJA,"US_TIPO")
			Else		
				cTipo := Posicione("SA1",1,xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,"A1_TIPO")
			Endif	            
			
			If lTK271TpCl
				cTipo := P_TK271TCL()
			ElseIf lTKTipCli 
				cTipo := U_TKTIPCLI(cTipo)
			Else 
			   	cTipo := SUA->UA_TIPOCLI
			EndIf

			cNaturez := Tk273DpNat(SUA->UA_CLIENTE, SUA->UA_LOJA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa os dados do cliente na FUNCAO FISCAL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisIni(IIF(lCliEntreg .And. !lProspect,SUA->UA_CLIENT,SUA->UA_CLIENTE),;	// 1-Codigo Cliente/Fornecedor
					 IIF(lCliEntreg .And. !lProspect,SUA->UA_LOJAENT,SUA->UA_LOJA),;	// 2-Loja do Cliente/Fornecedor
					 "C",;											// 3-C:Cliente , F:Fornecedor
					 "N",;											// 4-Tipo da NF
					 cTipo,;										// 5-Tipo do Cliente/Fornecedor
					 Nil,;											// 6-Relacao de Impostos que suportados no arquivo
					 Nil,;											// 7-Tipo de complemento
					 Nil,;											// 8-Permite Incluir Impostos no Rodape .T./.F.
					 Nil,;											// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
					 "MATA461",;									// 10-Nome da rotina que esta utilizando a funcao
					 Nil,;											// 11-Tipo de documento
					 Nil,;  										// 12-Especie do documento 
				     IIF(lProspect,SUA->UA_CLIENTE+SUA->UA_LOJA,""))// 13- Codigo e Loja do Prospect 
			
			If !Empty(cNaturez)
				MaFisAlt("NF_NATUREZA",cNaturez)
			EndIf
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega os dados do registro selecionado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk273NumTlv(nOpc		,M->UA_NUM		,@lHabilita		,oFolderTlv,;
					@oEnchTlv	,@cCodPagto		,@cDescPagto	,@cCodTransp,;
					@cTransp	,@cCob			,@cEnt			,@cCidadeC,;
					@cCepC		,@cUfC			,@cBairroE		,@cBairroC,;
					@cCidadeE	,@cCepE			,@cUfE			,@nLiquido,;
					@nTxJuros	,@nTxDescon		,@nVlJur		,@aParcelas,;
					@nEntrada	,@nFinanciado	,@nNumParcelas	,@nValorCC,;
					@aColsTlv	,@cCodAnt		,@cCliAnt)      
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o valor do suframa na mão, pois quando é Televendas³
		//³off-line, esse valor está desatualizado.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk273Refresh(.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula o item para garantir os impostos de acordo com a quantidade informada se houver desconto da SUFRAMA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaFisFound()
				                
			For nLinha := 1 To Len(aCols)
				nAcresRat := 0
				Tk273RecCpg(,,nLinha,@nAcresRat)

				MaFisAlt("IT_QUANT"		,aCols[nLinha][nPQtd]		,nLinha)
				MaFisAlt("IT_PRCUNI"	,aCols[nLinha][nPVrUnit]	,nLinha)
				MaFisAlt("IT_VALMERC",A410Arred(aCols[nLinha][nPQtd]*(aCols[nLinha][nPVrUnit])+nAcresRat,"UB_VLRITEM"),nLinha)
			
				If cPaisLoc == "BRA" .And. nPValDesc > 0 .And.	nPTes > 0		
					If aCols[nLinha][nPValDesc] > 0 .And. !Empty(aCols[nLinha][nPTes]) 
						SF4->(dbSetOrder(1))
						SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPTes]))
						If SF4->F4_IPI == "S" .And. SF4->F4_TPIPI == "B"
							MaFisAlt("IT_BASEIPI",MaFisRet(nLinha,"IT_BASEIPI") + aCols[nLinha][nPValDesc],nLinha)			
						EndIf
					EndIf
				EndIf
				
			Next nLinha                           
					
			Eval(bListRefresh)

		Endif
						
	ElseIf ( nFolder == 1 .AND. TkGetTipoAte() $ "145" ) //Telemarketing, Ambos e TMK x TLV
		
		Tk272NumTmk(@nOpc,M->UC_CODIGO,@lHabilita,@oFolderTmk,@oEnchTmk,NIL,NIL)
							
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ativa o cronometro da tela 10- 10 Segundos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeIni := Time()
	oTimerCro:Activate()
				
Endif
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271ChangeFolder³ Autor ³ Vendas Clientes       ³ Data ³ 28.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a mudanca do Folder                   				    	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Folder Destino                  				             ³±±
±±³			 ³ExpN2 = Folder Origem                    			 	         	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TMKA271	 - Todos os atendimentos                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271ChangeFolder(	nDestino	,nOrigem	,oBtn		,aBtn		,;
							aCfgBtn		,aCfgBtnOri	,nOpc  		,oPanelTmk	,;
							oPanelTlv	,oPanelTlc	,oEnchTlv	,lHabilita	)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as variáveis nOpc e INCLUI para restaurá-las depois.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static nTmkOpc		:= 3	// nOpc	durante a execução do folder Telemarketing
Static nTlvOpc		:= 3	// nOpc	durante a execução do folder Televendas
Static nTlcOpc		:= 3	// nOpc	durante a execução do folder Telecobranca
Static TmkINCLUI	:= .T.	// INCLUI durante a execução do folder Telemarketing
Static TlvINCLUI	:= .T.	// INCLUI durante a execução do folder Televendas
Static TlcINCLUI	:= .T.	// INCLUI durante a execução do folder Telecobranca
Static lTmkHabilita	:= .T.	// Se os controles estão habilitados ou não durante o Telemarketing
Static lTlvHabilita := .T.	// Se os controles estão habilitados ou não durante o Televendas
Static lTlcHabilita := .T.	// Se os controles estão habilitados ou não durante o Telecobranca


Do Case
	Case TkGetTipoAte() == "1"			//TeleMarketing
		oGetTmk:oBrowse:lDisablePaint := .F.
		oGetTmk:oBrowse:Refresh(.T.)
		aPosicoes:= aClone(aPosicoesM)
		nFolder := 1
		oPanelTmk:Show()
		oPanelTlv:Hide()
		oPanelTlc:Hide()
       	nTmkOpc		:= nOpc
       	TmkINCLUI	:= INCLUI
       	lTmkHabilita := lHabilita		

	Case TkGetTipoAte() == "2"			//Televendas
		oGetTlv:oBrowse:lDisablePaint := .F.
		oGetTlv:oBrowse:Refresh(.T.)
		aPosicoes:= aClone(aPosicoesV)
		nFolder := 2
		oPanelTmk:Hide()
		oPanelTlv:Show()
		oPanelTlc:Hide()
       	nTlvOpc		:= nOpc
       	TlvINCLUI	:= INCLUI
       	lTlvHabilita := lHabilita		
		
	Case TkGetTipoAte() == "3"			//Telecobranca
		oGetTlc:oBrowse:lDisablePaint := .F.
		oGetTlc:oBrowse:Refresh(.T.)
		aPosicoes:= aClone(aPosicoesC)                                 
		nFolder := 3
		oPanelTmk:Hide()
		oPanelTlv:Hide()
		oPanelTlc:Show()
       	nTlcOpc 	:= nOpc
       	TlcINCLUI	:= INCLUI
       	lTlcHabilita:= lHabilita		
				
	Case TkGetTipoAte() == "4"			//Ambos
		
		If ( nOrigem == 1 ) // Telemarketing
			aSvFolder[1][1] := AClone(aHeader)
			aSvFolder[1][2] := AClone(aCols)
			aSvFolder[1][3] := n
			oGetTmk:oBrowse:lDisablePaint := .T.
		
		ElseIf ( nOrigem == 2 ) // Televendas
			aSvFolder[2][1] := AClone(aHeader)
			aSvFolder[2][2] := AClone(aCols)
			aSvFolder[2][3] := n
			oGetTlv:oBrowse:lDisablePaint := .T.
		
		ElseIf ( nOrigem == 3 ) // Telecobranca
			aSvFolder[3][1] := AClone(aHeader)
			aSvFolder[3][2] := AClone(aCols)
			aSvFolder[3][3] := n
			oGetTlc:oBrowse:lDisablePaint := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz backup das variáveis nOpc e INCLUI para futura³
		//³restauração.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If ( nOrigem == 1 )
        	nTmkOpc		:= nOpc
        	TmkINCLUI	:= INCLUI
        	lTmkHabilita := lHabilita
        Elseif ( nOrigem == 2 )
        	nTlvOpc		:= nOpc
        	TlvINCLUI	:= INCLUI
        	lTlvHabilita := lHabilita
        Elseif ( nOrigem == 3 )
        	nTlcOpc 	:= nOpc
        	TlcINCLUI	:= INCLUI
        	lTlcHabilita:= lHabilita
        EndIf
		
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³ Restaura Configuracoes do Folder Selecionado					  ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nDestino == 1 ) // Telemarketing
			aHeader := AClone(aSvFolder[1][1])
			aCols	:= AClone(aSvFolder[1][2])
			n		:= aSvFolder[1][3]
			oGetTmk:oBrowse:lDisablePaint := .F.
			oGetTmk:oBrowse:Refresh(.T.)
			
			aPosicoes:= aClone(aPosicoesM)
			nFolder := 1
			oPanelTmk:Show()
			oPanelTlv:Hide()
			oPanelTlc:Hide()
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for entrada no atendimento ou se o campo estiver vazio³
			//³é inclusão, ao contrário restaura valores salvos.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOrigem == 0 .OR. Empty(M->UC_CODCONT)
				nOpc	:= 3
				INCLUI	:= .T.
			Else
				nOpc		:= nTmkOpc
				INCLUI		:= TmkINCLUI
				lHabilita	:= lTmkHabilita
			EndIf
			
		ElseIf ( nDestino == 2 ) // Televendas
			aHeader := AClone(aSvFolder[2][1])
			aCols	:= AClone(aSvFolder[2][2])
			n		:= aSvFolder[2][3]
			oGetTlv:oBrowse:lDisablePaint := .F.
			oGetTlv:oBrowse:Refresh(.T.)
			
			aPosicoes:= aClone(aPosicoesV)
			nFolder := 2
			oPanelTmk:Hide()
			oPanelTlv:Show()
			oPanelTlc:Hide()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for entrada no atendimento ou se o campo estiver vazio³
			//³é inclusão, ao contrário restaura valores salvos.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOrigem == 0 .OR. Empty(M->UA_CLIENTE)
				nOpc	:= 3
				INCLUI	:= .T.
			Else
				nOpc		:= nTlvOpc
				INCLUI		:= TlvINCLUI
				lHabilita	:= lTlvHabilita
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Essa funcao e para evitar o problema de digitacao do codigo do cliente sem validacao do SX3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(oEnchTlv:aEntryCtrls) > 0
				oEnchTlv:aEntryCtrls[1]:SetFocus()
			Endif
			
		ElseIf ( nDestino == 3 ) // Telecobranca
			aHeader := AClone(aSvFolder[3][1])
			aCols	:= AClone(aSvFolder[3][2])
			n		:= aSvFolder[3][3]
			oGetTlc:oBrowse:lDisablePaint := .F.
			oGetTlc:oBrowse:Refresh(.T.)
			
			aPosicoes:= aClone(aPosicoesC)
			nFolder := 3
			oPanelTmk:Hide()
			oPanelTlv:Hide()
			oPanelTlc:Show()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for entrada no atendimento ou se o campo estiver vazio³
			//³é inclusão, ao contrário restaura valores salvos.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOrigem == 0 .OR. Empty(M->ACF_CLIENT)
				nOpc	:= 3
				INCLUI	:= .T.
			Else
				nOpc		:= nTlcOpc
				INCLUI		:= TlcINCLUI
				lHabilita	:= lTlcHabilita
			EndIf	

		Endif

	Case TkGetTipoAte() == "5"			// TMK x TLV
		
		If ( nOrigem == 1 ) // Telemarketing
			aSvFolder[1][1] := AClone(aHeader)
			aSvFolder[1][2] := AClone(aCols)
			aSvFolder[1][3] := n
			oGetTmk:oBrowse:lDisablePaint := .T.
			nTmkOpc			:= nOpc
			TmkINCLUI		:= INCLUI
			lTmkHabilita	:= lHabilita
		
		ElseIf ( nOrigem == 2 ) // Televendas
			aSvFolder[2][1] := AClone(aHeader)
			aSvFolder[2][2] := AClone(aCols)
			aSvFolder[2][3] := n
			oGetTlv:oBrowse:lDisablePaint := .T.
			nTlvOpc			:= nOpc
			TlvINCLUI		:= INCLUI
			lTlvHabilita	:= lHabilita

		Endif
		
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³ Restaura Configuracoes do Folder Selecionado					  ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nDestino == 1 ) // Telemarketing
			aHeader := AClone(aSvFolder[1][1])
			aCols	:= AClone(aSvFolder[1][2])
			n		:= aSvFolder[1][3]
			oGetTmk:oBrowse:lDisablePaint := .F.
			oGetTmk:oBrowse:Refresh(.T.)
			
			aPosicoes:= aClone(aPosicoesM)
			nFolder := 1
			oPanelTmk:Show()
			oPanelTlv:Hide()
			oPanelTlc:Hide()
			                                    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for entrada no atendimento ou se o campo estiver vazio³
			//³é inclusão, ao contrário restaura valores salvos.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOrigem == 0 .OR. Empty(M->UC_CODCONT)
				nOpc	:= 3
				INCLUI	:= .T.
			Else
				nOpc		:= nTmkOpc
				INCLUI		:= TmkINCLUI
				lHabilita 	:= lTmkHabilita
			EndIf	
			
		ElseIf ( nDestino == 2 ) // Televendas
			aHeader := AClone(aSvFolder[2][1])
			aCols	:= AClone(aSvFolder[2][2])
			n		:= aSvFolder[2][3]
			oGetTlv:oBrowse:lDisablePaint := .F.
			oGetTlv:oBrowse:Refresh(.T.)
			
			aPosicoes:= aClone(aPosicoesV)
			nFolder := 2
			oPanelTmk:Hide()
			oPanelTlv:Show()
			oPanelTlc:Hide()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Essa funcao e para evitar o problema de digitacao do codigo do cliente sem validacao do SX3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(oEnchTlv:aEntryCtrls) > 0
				oEnchTlv:aEntryCtrls[1]:SetFocus()
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for entrada no atendimento ou se o campo estiver vazio³
			//³é inclusão, ao contrário restaura valores salvos.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOrigem == 0 .OR. Empty(M->UA_CLIENTE)
				nOpc	:= 3
				INCLUI	:= .T.
			Else
				nOpc		:= nTlvOpc
				INCLUI		:= TlvINCLUI
				lHabilita	:= lTlvHabilita
			EndIf	
			
		Endif
EndCase    

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Config³ Autor ³ Vendas Clientes      ³ Data ³ 29.03.00   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta ACOLS e AHEADER conforme o alias passado			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271Config(ExpC1,ExpN1,ExpC2,ExpF1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Alias selecionado								    ³±±
±±³          ³ ExpN1 := Numero do Folder								    ³±±
±±³          ³ ExpC2 := Campos que nao devem aparecer na Getdados		    ³±±
±±³          ³ ExpF1 := Flag que indica qual array sera selecionado		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMKA271   - Utilizada por todos os atendimentos. 		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                             

Function Tk271Config(	cAlias	,cString	,nOpc	,cNumTmk	,;
						cNumTlv	,cNumTlc	)
						
Local aArea		:= GetArea()
Local nUsado	:= 0														// Linhas do acols	
Local aTmpHeader:= {}														// aHeader Temporario
Local aTmpCols	:= {}  														// acols Temporario
Local lRet		:= .F.														// Retorno da funcao
Local aRet		:= {}  														// Retorno da funcao que calcula os juros do titulo baseado nos parametros do sigaloja
Local nX		:= 0 														// Contador
Local nI		:= 0   														// Contador
Local nPCFO		:= 0 														// Posicao do CFO
Local aCfop		:= {}														// Array auxiliar para armazenar os CFOS antes do recalculo de impostos
Local aTlcCols	:= {}														// Array auxiliar para tratamento do aCols na rotina de telecobrança 
Local cSeek		:= ""	//Armazena a string de busca
Local cWhile	:= ""	//Armazena a condição de parada
Local bCond            	//Armazena a condicao para validar os registros
Local bMontAcols		//Armazena o bloco de codigo que será utilizado para montar o Acols
Local lEmptyFalse   := .F.	//Indica se deve ou não exibir uma linha em branco
Local bAfterAcols			//Armazena o bloco de codigo que será executado apos adicionar uma linha no acols
Local nIndex        := 1   	//Indica o indice para abertura da tabela

If(nOpc == 4)
	Private ALTERA := .T.
EndIf

Default cNumTmk := ""
Default cNumTlv := ""
Default cNumTlc := ""

DbSelectArea(cAlias)
DbCloseArea()    
lEmptyFalse := .F. 

If (cAlias == "SUD")		//Itens do Telemarketing

	cSeek	:= xFilial("SUD") + cNumTmk
	cWhile	:= "SUD->UD_FILIAL + SUD->UD_CODIGO"	
	bCond	:= {||(SUD->UD_FILIAL+SUD->UD_CODIGO == xFilial("SUD")+cNumTmk)}
	nIndex := 1 
	bAfterAcols:= {||TkSUDAfterAcols(@aTmpHeader, @aCols, nOpc)} 
	lEmptyFalse:= .F.  
	
ElseIf (cAlias == "SUB")		//Itens do Televendas                                              

	cSeek	:= xFilial("SUB") + cNumTlv
	cWhile	:= "SUB->UB_FILIAL + SUB->UB_NUM"	
	bCond	:= {||(SUB->UB_FILIAL == xFilial("SUB") .AND. SUB->UB_NUM == cNumTlv)}
	nIndex := 1                                                                                       
	bAfterAcols:= {||TkSUBAfterAcols(aHeader, aCols, nOpc)} 
	lEmptyFalse:= .F.

ElseIf (cAlias == "ACG")		//Itens do Telecobranca
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o rodape de Telecobranca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk274LimpaRdp()  
	nIndex	:= 1
	cSeek	:= xFilial("ACG") + cNumTlc
	cWhile	:= "ACG->ACG_FILIAL + ACG->ACG_CODIGO"	
	bCond	:= {||(ACG->ACG_FILIAL + ACG->ACG_CODIGO == xFilial("ACG") + cNumTlc)}
	aTlcCols	:= {}
	bMontAcols := {||TkACGMontAcols(	aTmpHeader	, @aTlcCols	, cAlias	, cNumTlc	,;
										cString		)}                 
	lEmptyFalse := .F.	
EndIf  

DbSelectArea(cAlias)
DbCloseArea()	

aTmpHeader  := {}
aTmpCols	:= {}            
aHeader		:= {}
aCols		:= {}

If(nOpc <> 3) .AND. (nOpc <> 2)
	ALTERA := .T.
EndIf	

FillGetDados(	nOpc /*nOpcX*/, cAlias/*cAlias*/, nIndex/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, {cString}/*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, bMontAcols/*bMontAcols*/, IIf(nOpc == 3, .T.,lEmptyFalse)/*lEmpty*/,; 
				@aTmpHeader/*aHeaderAux*/, @aTmpCols/*aColsAux*/, bAfterAcols/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, cAlias/*cAliasQry*/)
				
If (cAlias == "ACG")	
	aTmpCols :=	aTlcCols	
EndIf				

lRet	:= .T. 

If (cAlias == "SUB")

	Aadd(aPosicoesV,{"UB_PRODUTO"	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_PRODUTO"})		})	//01
	Aadd(aPosicoesV,{"UB_DESCRI"   	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_DESCRI"})		})	//02
	Aadd(aPosicoesV,{"UB_SITPROD"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_SITPROD"})		})	//03
	Aadd(aPosicoesV,{"UB_QUANT"    	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_QUANT"})			})	//04
	Aadd(aPosicoesV,{"UB_VRUNIT"   	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_VRUNIT"})		})	//05
	Aadd(aPosicoesV,{"UB_VLRITEM"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_VLRITEM"})		})	//06
	Aadd(aPosicoesV,{"UB_LOCAL"    	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_LOCAL"})			})	//07
	Aadd(aPosicoesV,{"UB_UM"       	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_UM"})			})	//08
	Aadd(aPosicoesV,{"UB_DESC"    	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_DESC"})			}) 	//09
	Aadd(aPosicoesV,{"UB_VALDESC"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_VALDESC"})		})	//10
	Aadd(aPosicoesV,{"UB_TES"  	   	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_TES"})			})	//11
	Aadd(aPosicoesV,{"UB_CF"  		,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_CF"})			})	//12
	Aadd(aPosicoesV,{"UB_ACRE"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_ACRE"})			})	//13
	Aadd(aPosicoesV,{"UB_VALACRE"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_VALACRE"})		})	//14
	Aadd(aPosicoesV,{"UB_PRCTAB"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_PRCTAB"})		})	//15
	Aadd(aPosicoesV,{"UB_DTENTRE" 	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_DTENTRE"})		})	//16
	Aadd(aPosicoesV,{"UB_LOTE"     	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_LOTE"})			}) 	//17
	Aadd(aPosicoesV,{"UB_SUBLOTE"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_SUBLOTE"})		})	//18
	Aadd(aPosicoesV,{"UB_DTVALID"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_DTVALID"})		})	//19
	Aadd(aPosicoesV,{"UB_ITEM"     	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_ITEM"})			})	//20

ElseIf (cAlias == "SUD")

	Aadd(aPosicoesM,{"UD_ASSUNTO"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_ASSUNTO"})		})	//01
	Aadd(aPosicoesM,{"UD_DESCASS"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCASS"})		})	//02
	Aadd(aPosicoesM,{"UD_PRODUTO"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_PRODUTO"})		})	//03
	Aadd(aPosicoesM,{"UD_DESCPRO"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCPRO"})		})	//04
	Aadd(aPosicoesM,{"UD_OCORREN"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_OCORREN"})		})	//05
	Aadd(aPosicoesM,{"UD_DESCOCO"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCOCO"})		})	//06
	Aadd(aPosicoesM,{"UD_OPERADO"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_OPERADO"})		})	//07
	Aadd(aPosicoesM,{"UD_DESCOPE"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCOPE"})		})	//08
	Aadd(aPosicoesM,{"UD_DATA"     ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DATA"})			})	//09
	Aadd(aPosicoesM,{"UD_SOLUCAO"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_SOLUCAO"})		})	//10
	Aadd(aPosicoesM,{"UD_DESCSOL"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCSOL"})		})	//11
	Aadd(aPosicoesM,{"UD_OBS"      ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_OBS"})			})	//12
	Aadd(aPosicoesM,{"UD_STATUS"   ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_STATUS"})		})	//13
	Aadd(aPosicoesM,{"UD_DTEXEC"   ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DTEXEC"})		})	//14
	Aadd(aPosicoesM,{"UD_OBSEXEC"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_OBSEXEC"})		})	//15
	Aadd(aPosicoesM,{"UD_CODEXEC"  ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_CODEXEC"})		})	//16
	Aadd(aPosicoesM,{"UD_NSERIE"   ,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_NSERIE"})		})	//17

ElseIf (cAlias == "ACG")

	Aadd(aPosicoesC,{"ACG_TITULO"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_TITULO"})	})	//01
	Aadd(aPosicoesC,{"ACG_PREFIX"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_PREFIX"})	})	//02
	Aadd(aPosicoesC,{"ACG_PARCEL"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_PARCEL"})	})	//03
	Aadd(aPosicoesC,{"ACG_TIPO"    	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_TIPO"})		})	//04
	Aadd(aPosicoesC,{"ACG_DESCTP"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DESCTP"})	})	//05
	Aadd(aPosicoesC,{"ACG_NATURE"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_NATURE"})	})	//06
	Aadd(aPosicoesC,{"ACG_DESCNT"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DESCNT"})	})	//07
	Aadd(aPosicoesC,{"ACG_DTVENC"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DTVENC"})	})	//08
	Aadd(aPosicoesC,{"ACG_DTREAL"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DTREAL"})	}) 	//09
	Aadd(aPosicoesC,{"ACG_VALOR"   	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_VALOR"})	})	//10
	Aadd(aPosicoesC,{"ACG_RECEBE"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_RECEBE"})	})	//11
	Aadd(aPosicoesC,{"ACG_JUROS"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_JUROS"})	})	//12
	Aadd(aPosicoesC,{"ACG_DESCFI"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DESCFI"})	})	//13
	Aadd(aPosicoesC,{"ACG_ACRESC"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_ACRESC"})	})	//14
	Aadd(aPosicoesC,{"ACG_DECRES"	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DECRES"})	})	//15
	Aadd(aPosicoesC,{"ACG_PROMOC"	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_PROMOC"})	})	//16
	Aadd(aPosicoesC,{"ACG_OPERAD"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_OPERAD"})	})	//17
	Aadd(aPosicoesC,{"ACG_DESCOP"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DESCOP"})	})	//18
	Aadd(aPosicoesC,{"ACG_HIST"    	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_HIST"})		})	//19
	Aadd(aPosicoesC,{"ACG_VALJUR"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_VALJUR"})	})	//20
	Aadd(aPosicoesC,{"ACG_PORJUR"	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_PORJUR"})	})	//21
	Aadd(aPosicoesC,{"ACG_NUMBCO"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_NUMBCO"})	})	//22
	Aadd(aPosicoesC,{"ACG_IRRF"    	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_IRRF"})		})	//23
	Aadd(aPosicoesC,{"ACG_ISS"     	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_ISS"})		})	//24
	Aadd(aPosicoesC,{"ACG_CSLL"    	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_CSLL"})		})	//25
	Aadd(aPosicoesC,{"ACG_COFINS"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_COFINS"})	})	//26
	Aadd(aPosicoesC,{"ACG_PIS"     	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_PIS"})		})	//27
	Aadd(aPosicoesC,{"ACG_VALREF"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_VALREF"})	})	//28
	Aadd(aPosicoesC,{"ACG_BAIXA"   	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_BAIXA"})	})	//29
	Aadd(aPosicoesC,{"ACG_STATUS"  	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_STATUS"})	})	//30
	Aadd(aPosicoesC,{"ACG_FILORI" 	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_FILORI"})	})	//31
	Aadd(aPosicoesC,{"ACG_DESCJU" 	,Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "ACG_DESCJU"})	})	//32

Endif

If nFolder == 1
	If (TkGetTipoAte() $ "145")  //Telemarketing , Ambos ou TMK x TLV
		aPosicoes := Aclone(aPosicoesM)
		nPAssunto := aPosicoes[1][2]
		nPDescAss := aPosicoes[2][2]
		nPProd 	  := aPosicoes[3][2]
		nPDescPro := aPosicoes[4][2]
		nPOcorren := aPosicoes[5][2]
		nPDescOco := aPosicoes[6][2]
		nPCodOpe  := aPosicoes[7][2]
		nPDescOpe := aPosicoes[8][2]
		nPAcao    := aPosicoes[10][2]
		nPDescAca := aPosicoes[11][2]
		nPObsExec := aPosicoes[15][2]
		
	ElseIf (TkGetTipoAte() == "2") //Televendas
		aPosicoes := Aclone(aPosicoesV)
		nPProd 	  := aPosicoes[1][2]
		nPDescPro := aPosicoes[2][2]
		nPTes	  := aPosicoes[11][2]
		nPCFO	  := aPosicoes[12][2]			
					
	Else //Telecobranca
		aPosicoes:= Aclone(aPosicoesC)
	Endif
	
ElseIf (nFolder == 2) //Televendas
	aPosicoes := Aclone(aPosicoesV)
	nPProd 	  := aPosicoes[1][2]
	nPDescPro := aPosicoes[2][2]
	nPTes	  := aPosicoes[11][2]
	nPCFO	  := aPosicoes[12][2]			
	
ElseIf (nFolder == 3) //Telecobranca
	aPosicoes:= Aclone(aPosicoesC)
Endif			

DbSelectArea(cAlias)
DbCloseArea()	
	
If (cAlias == "SUB")
	aSvFolder[2][1] := aClone(aTmpHeader)
	aSvFolder[2][2] := aClone(aTmpCols)
	aSvFolder[2][3] := Len(aTmpCols)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta o aCols e aHeader para o Folder 2 - TeleVendas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:= aClone(aSvFolder[2][1])
	aCols  := aClone(aSvFolder[2][2])
	n	   := aSvFolder[2][3]
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Garante que o aCols é atualizado na MsGetDados.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(oGetTLV) == "O"
		oGetTLV:SetArray(aCols)
	EndIf	

	If MaFisFound()    
		nPCFO	  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_CF"})
	
		MaFisClear()

		// Recalcula os impostos dos produtos carregados
		For nX := 1 To Len(aCols)    		
			// Carrega o CFO original do ACOLS
			AAdd(aCfop,aCols[nX][nPCFO])
 	    		
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+aCols[nX][aPosicoes[1][2]]))     
	 
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+aCols[nX][aPosicoes[11][2]]))
			      
			
			MaFisIniLoad(nX, ;
						{aCols[nX][aPosicoes[1][2]],;	//IT_PRODUTO
						aCols[nX][aPosicoes[11][2]],; 		//IT_TES
						SB1->B1_CODISS,; 	//IT_CODISS
						aCols[nX][aPosicoes[4][2]],;		//IT_QUANT
						"",; 				//IT_NFORI
						"",; 				//IT_SERIORI
						0,;					//IT_RECNOSB1
						0,;					//IT_RECNOSF4
						0  }) 				//IT_RECORI
			
			MaFisLoad("IT_VALMERC"	,aCols[nX][aPosicoes[6][2]]	,nX) 
			MaFisLoad("IT_PRCUNI"	,aCols[nX][aPosicoes[15][2]]	,nX)        
			MaFisLoad("IT_DESCONTO"	,aCols[nX][aPosicoes[10][2]]	,nX)
			MaFisRecal("",nX)
		     	MaFisEndLoad(nX,2)				
		     	
			
		Next nX   										

	      // Carrega novamente os itens de CFO de cada produto
		// Atualiza o ACOLS corretamente
		For nX := 1 To Len(aCols)
		   	MaFisLoad("IT_CF",aCfop[nX],nX)      
		   	aCols[nX][nPCFO] := aCfop[nX]
		Next nX
		
	Endif
	
ElseIf (cAlias == "SUD")
	
	aSvFolder[1][1] := aClone(aTmpHeader)
	aSvFolder[1][2] := aClone(aTmpCols)
	aSvFolder[1][3] := Len(aTmpCols)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta o aCols e aHeader para o Folder 1 - TeleMarketing.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader  := aClone(aSvFolder[1][1])
	aCols    := aClone(aSvFolder[1][2])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Garante que o aCols é atualizado na MsGetDados.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(oGetTmk) == "O"
		oGetTmk:SetArray(aCols)
	EndIf

	If aSvFolder[1][3] > 1
		n := 1
		aSvFolder[1][3]:=n
	Else
		n := aSvFolder[1][3]
	Endif	
	
ElseIf (cAlias == "ACG")	//Telecobranca
	
	aSvFolder[3][1] := aClone(aTmpHeader)
	aSvFolder[3][2] := aClone(aTmpCols)
	aSvFolder[3][3] := Len(aTmpCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta o aCols e aHeader para o Folder 3 - Telecobranca.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader  := aClone(aSvFolder[3][1])
	aCols    := aClone(aSvFolder[3][2])
	n		 := aSvFolder[3][3]
				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Garante que o aCols é atualizado na MsGetDados.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(oGetTlc) == "O"
		oGetTlc:SetArray(aCols)
	EndIf

	If aSvFolder[3][3] > 1
		n := 1
		aSvFolder[3][3]:=n
	Else
		n := aSvFolder[3][3]
	Endif	

Endif
RestArea(aArea)
Return(lRet)


	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271AtuCro³ Autor ³ Vendas Clientes      ³ Data ³ 30/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Incrementa o Cronometro na Tela a cada 10 segundos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1:Segundos                                             ³±±
±±³          ³ ExpN2:Minutos                                              ³±±
±±³          ³ ExpC3:Time Out                                             ³±±
±±³          ³ ExpC4:Variavel do objeto de Cronometro                     ³±±
±±³          ³ ExpO5:Objeto Cronometro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMK                                         			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Tk271AtuCro(nTimeSeg, nTimeMin, cTimeOut, cCrono, oCrono)							

Local cTimeAtu	:= ""
Local cTipoAte	:= TkGetTipoAte()

If (cTipoAte $ "145")  // Telemarketing, Ambos e TMK x TLV
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tempo medio de atendimento desse operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeOut := TkPosto(M->UC_OPERADO,"U0_TEMPCRO")
	
Elseif (cTipoAte == "2" ) //Televendas
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tempo medio de atendimento desse operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeOut := TkPosto(M->UA_OPERADO,"U0_TEMPCRO")
	
Elseif (cTipoAte == "3" ) //Telecobranca
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual o tempo medio de atendimento desse operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeOut := TkPosto(M->ACF_OPERAD,"U0_TEMPCRO")
	
Endif

nTimeSeg += 10
	
If nTimeSeg > 59
	nTimeMin ++
	nTimeSeg := 0
	If nTimeMin > 60
		nTimeMin := 0
	Endif
Endif

cTimeAtu := STRZERO(nTimeMin,2,0)+":"+STRZERO(nTimeSeg,2,0)
	
If cTimeAtu > cTimeOut
	oCrono:nClrText := CLR_RED
	oCrono:Refresh()
Endif

cCrono := cTimeAtu
oCrono:Refresh()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk271TpOper   ºAutor  ³ Vendas Clientes    º Data ³  15/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui uma validacao no campo UA_OPER no SX3               	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP6 - Call Center       	                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271TpOper()
Local lRet := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se pode alterar o operador retorna TRUE                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAltTpOper 
	lRet := .T.
Endif	

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271HabObj ³ Autor ³ Vendas Clientes       ³ Data ³23/08/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Habilita ou Desabilita os Objetos da Tela      	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 = .T. = Habilita .F. = Desabilita                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP6 - Call Center       	                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk271HabObj(lTrue,lHabilita,oEnchoice)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilita os objetos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTrue
	lHabilita := .T.

	If (nFolder == 1)
		If (TkGetTipoAte() $ "145") //TeleMarketing ,Ambos ou TMK x TLV
			oGetTmk:Enable()
			lTmkHabilita := .T.
			If oEnchoice <> NIL
				oEnchoice:Enable()
			Endif

		ElseIf (TkGetTipoAte() == "2")	//Televendas
			oGetTlv:Enable()
			lTlvHabilita := .T.
			If oEnchoice <> NIL
				oEnchoice:Enable()
			Endif

		ElseIf	(TkGetTipoAte() == "3")	//Telecobranca
			oGetTlc:Enable()
			lTlcHabilita := .T.
			If oEnchoice <> NIL
				oEnchoice:Enable()
			Endif
		Endif

	ElseIf (nFolder == 2) 			//Televendas
		oGetTlv:Enable()
		lTlvHabilita := .T.
		If oEnchoice <> NIL
			oEnchoice:Enable()
		Endif

	ElseIf (nFolder == 3) 			//Telecobranca
		oGetTlc:Enable()
		lTlcHabilita := .T.
		If oEnchoice <> NIL
			oEnchoice:Enable()
		Endif
	Endif

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desabilita os objetos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lHabilita := .F.
	If (nFolder == 1)
		If (TkGetTipoAte() $ "145") //TeleMarketing ,Ambos ou TMK x TLV
			If AllTrim(SUC->UC_STATUS) <> "3"
				If oGetTmk:nOpc <> 2
					oGetTmk:Disable()
				Else
					oGetTmk:Enable()
				EndIf
			Else
				oGetTmk:Enable()
			EndIf
			lTmkHabilita := .F.
			If oEnchoice <> NIL
				oEnchoice:Disable()
			Endif

		ElseIf (TkGetTipoAte() == "2")	//Televendas
			oGetTlv:Disable()
			lTlvHabilita := .F.
			If oEnchoice <> NIL
				oEnchoice:Disable()
			Endif

		ElseIf	(TkGetTipoAte() == "3")	//Telecobranca
			oGetTlc:Disable()
			lTlcHabilita := .F.
			If oEnchoice <> NIL
				oEnchoice:Disable()
			Endif
		Endif

	ElseIf (nFolder == 2) 			//Televendas
		oGetTlv:Disable()
		lTlvHabilita := .F.
		If oEnchoice <> NIL
			oEnchoice:Disable()
			If (TkGetTipoAte() == "2")
				oEnchoice:SetFocus()
			Endif
		Endif

	ElseIf (nFolder == 3) 			//Telecobranca
		oGetTlc:Disable()
		lTlcHabilita := .F.
		If oEnchoice <> NIL
			oEnchoice:Disable()
		Endif
	Endif

Endif
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Fim   ³ Autor ³ Vendas Clientes       ³ Data ³19/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para validar o ambiente da tela de atendimento no     ³±±
±±³          ³momento de fechar a dialog principal                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExC1: Opcao da Rotina (inclusao,alteracao			       ³±±
±±³          ³ ExL1: Exibe uma mensagem de confirmacao de saida da tela    ³±±
±±³          ³       .T. - Exibe , .F. nao exibe         			       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³CALL CENTER             	                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK271Fim(nOpc,lMsg)

Local lRet 	 	:= .T.          				// Retorno da funcao
Local aArea		:= GetArea()					// Salva a area atual
Local lTMKOUT	:= ExistBlock("TMKOUT") 		// Ponto de Entrada na saida da tela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o P.E.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKOUT
	lRet := U_TMKOUT(@lMsg,nOpc)
	If !lRet
		Return(lRet)
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a rotina for diferente de VISUALIZACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o sistema vai exibir ou nao a mensagem de saida da tela e para o cronometro³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMsg
		If TMKOK(STR0059)   //"Abandona o atendimento ?"
			oTimerCro:End() 
        Else
        	lRet := .F.	    //Nao fecha a tela de atendimento
		Endif
	Endif 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for alteração,  pede para a função TkLibLoja liberar o ³
	//³orçamento no loja, claro, se ele for do loja.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpc == 4) .And.	( nFolder == 1 .AND. TkGetTipoAte() == "2" ) .OR.;
							( nFolder == 2 .AND. TkGetTipoAte() == "2" ) .OR.;
							( nFolder == 2 .AND. TkGetTipoAte() $ "45" )
		TkLibLoja("D", M->UA_NUM)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se vai fechar a tela atualiza os semaforos de todos os alias principais - SUA, SUC e ACF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet			
 		Do Case
 			Case TkGetTipoAte() == "5"// TMK x TLV
				DbSelectArea("SUA")
				RollBackSX8() // rollback do penultimo folder
				
				DbSelectArea("SUC")
				RollBackSX8() // rollback do primeiro folder.


 			Case TkGetTipoAte() == "4"// todos os atendimentos
				DbSelectArea("ACF")
				RollBackSX8() // rollback do ultimo folder
				
				DbSelectArea("SUA")
				RollBackSX8() // rollback do penultimo folder
				
				DbSelectArea("SUC")
				RollBackSX8() // rollback do primeiro folder.
		        
        	Case TkGetTipoAte() == "1"  //TMK
				DbSelectArea("SUC")
				RollBackSX8() 

			Case TkGetTipoAte() == "2" //TLV
				DbSelectArea("SUA")
				RollBackSX8() 
		
			Case TkGetTipoAte() == "3" //TLC
				DbSelectArea("ACF")
				RollBackSX8() 
		Endcase
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkGrvSUV(__cUserId, "")
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inibe o loop da dialog quando acessado um AxCadastro durante o processo de atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	MBRCHGLOOP(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se vai encerrar a tela : Limpa as teclas de atalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	SetKEY(15,		{ || AllWaysTrue() } )
	SetKEY(24,		{ || AllWaysTrue() } )
	SetKey(VK_F5,	{ || AllWaysTrue() } )
	SetKey(VK_F6,	{ || AllWaysTrue() } )
	SetKey(VK_F7,	{ || AllWaysTrue() } )
	SetKey(VK_F8,	{ || AllWaysTrue() } )
	SetKey(VK_F9,	{ || AllWaysTrue() } )
	SetKey(VK_F10,	{ || AllWaysTrue() } )
Endif

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271CabOk     ³Autor ³ Vendas Clientes        ³ Data ³ 04/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se foi preenchido os campos obrigatorios.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP6 - Call Center       	                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271CabOk(oEnchoice,lExibeHelp,lHabilita)

Local lRet := TkContEnt(!lTk271Auto)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Só verifica se os campos obrigatórios estão preenchidos,  ³
//³quando os objetos da tela estão habilitados, ou seja,     ³
//³quando não é visualização, exclusão, ou se o pedido já    ³
//³teve sua nota fiscal emitida e não poderá ser alterado por³
//³causa do MV_ALTPED.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. lHabilita
	lRet := Obrigatorio(oEnchoice:aGets,oEnchoice:aTela,NIL,lExibeHelp)
EndIf

If !lRet
   	oEnchoice:GoToCtrl(oEnchoice:Nctrl)
Endif

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMK271SELC
Define tipo de execução da consulta padrão de contatos 
.T. - Seleção de entidades
.F. - Padrão SU5

@sample 	TMK271SELC() 

@return	lret ,lógico , Se .F. carrega apenas a consulta padrão de contatos 'SU5'
se não abre a tela para vinculo do contato na entidade. 

@author		Serviços
@since		29/04/2015       
@version	12.1.7   
/*/         
//------------------------------------------------------------------------------
Function TMK271SELC()
Local lRet       := .F.
Local lSelEntF3  := SuperGetMv("MV_TMKF3",.F.)
Local lBkpINCLUI
Local lBkpALTERA

If ValType(INCLUI) == "L" 
	lBkpINCLUI	:= INCLUI
	INCLUI		:= .F.
EndIf
If	ValType(ALTERA) == "L"
	lBkpALTERA	:= ALTERA
	ALTERA		:= .F.
EndIf

If ( !IsInCallStack("LERDA") ) .AND. lSelEntF3
	lRet := Conpad1( Nil,Nil,Nil,"TMK001",Nil,Nil,.F.)
Else
	lRet := Conpad1( Nil,Nil,Nil,"SU5",Nil,Nil,.F.)
Endif

If lBkpINCLUI <> Nil
	INCLUI := lBkpINCLUI
EndIf
If lBkpALTERA <> Nil 
	ALTERA := lBkpALTERA
EndIf

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MyTmka271 ºAutor  ³ Vendas Clientes    º Data ³  21/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Programa de exemplo para testes para utilizacao da rotina   º±±
±±º          ³de entrada automatica.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
User Function MyTmkA271(cRotina)

Local aCabec 	:= {}
Local aItens 	:= {}
Local aLinha 	:= {}
Local nX     	:= 0
Local nY     	:= 0
Local lOk    	:= .T.
Local cEndc		:= ""
Local cEnde		:= ""
Local cBairroc	:= ""
Local cBairroe	:= ""
Local cMunc		:= ""
Local cMune		:= ""
Local cCepc		:= ""
Local cCepe		:= ""
Local cEstc		:= ""
Local cEste     := ""
Local cCod		:= ""
Local cLoja		:= ""
Local cAtend	:= ""
Local nDesconto	:= 0
Local nFrete	:= 0
Local nDespesa	:= 0
Local lAlterar	:= .T.

DEFAULT cRotina		:= "3" 	//Indica as rotinas de atendimento. 1-Telemarketing 2- Televendas 3-Telecobranca
PRIVATE lMsErroAuto := .F.                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ConOut(Repl("-",80))
ConOut(PadC(STR0138	,80))  //"Teste de Inclusao de Atendimento "

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" USER STR0139 PASSWORD "adm" MODULO "TMK" TABLES "SUA","SUB","SUC","SUD","SB1","SA1","SUS","SE4","AC8","SA4","SU7"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verificacao do ambiente para teste para Televendas           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cRotina == "2"
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SB1")+"PA001")
		lOk := .F.
		ConOut(STR0140)     //"Cadastrar produto: PA001"
	Endif
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	If !DbSeek(xFilial("SF4")+"501")
		lOk := .F.
		ConOut(STR0141)		//"Cadastrar TES: 501"
	Endif
	
	DbSelectArea("SE4")
	DbSetOrder(1)
	If !DbSeek(xFilial("SE4")+"001")
		lOk := .F.
		ConOut(STR0142)		//"Cadastrar condicao de pagamento: 001"
	Endif
	
	If !SB1->(DbSeek(xFilial("SB1")+"PA002"))
		lOk := .F.
		ConOut(STR0143)		//"Cadastrar produto: PA002"
	Endif
Endif
	
DbSelectArea("SA1")
DbSetOrder(1)
If !SA1->(DbSeek(xFilial("SA1")+"00000101"))
	lOk := .F.
	ConOut(STR0144)		//"Cadastrar cliente: 00000101"
Else 
    cCod		:=SA1->A1_COD
    cLoja		:=SA1->A1_LOJA
	cEndc		:=SA1->A1_ENDCOB
	cBairroc	:=SA1->A1_BAIRROC
	cMunc		:=SA1->A1_MUNC
	cCepc		:=SA1->A1_CEPC
	cEstc		:=SA1->A1_ESTC
	cEnde		:=SA1->A1_ENDENT
	cBairroe	:=SA1->A1_BAIRROE
	cMune		:=SA1->A1_MUNE
	cEste		:=SA1->A1_ESTE
	nDesconto	:=10 
	nFrete		:=20
	nDespesa	:=30
Endif

Do Case
	Case cRotina == "2"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluir atendimentos do televendas   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ConOut(STR0145 +Time())		//"Inicio: "
		For nY := 1 To 1
			aCabec := {}
			aItens := {}
			AADD(aCabec,{"UA_CLIENTE"	,cCod       	,Nil})
			AADD(aCabec,{"UA_LOJA"		,cLoja      	,Nil})
			AADD(aCabec,{"UA_OPERADO"	,"000001"		,Nil})	//Codigo do Operador
			AADD(aCabec,{"UA_OPER"		,"2"			,Nil})	//1-Faturamento 2-Orcamento 3-Atendimento
			AADD(aCabec,{"UA_TMK"		,"1"			,Nil})	//1-Ativo 2-Receptivo
			AADD(aCabec,{"UA_CONDPG"	,"001"			,Nil})	//Condicao de Pagamento
			AADD(aCabec,{"UA_TRANSP"	,"000001"		,Nil})	//Transportadora
			AADD(aCabec,{"UA_ENDCOB"  	,cEndc       	,Nil})
			AADD(aCabec,{"UA_BAIRROC"	,cBairroc      	,Nil})
			AADD(aCabec,{"UA_MUNC"		,cMunc       	,Nil})
			AADD(aCabec,{"UA_CEPC"  	,cCepc       	,Nil})
			AADD(aCabec,{"UA_ESTC"  	,cEstc       	,Nil})
			AADD(aCabec,{"UA_ENDENT"   	,cEnde         	,Nil})
			AADD(aCabec,{"UA_BAIRROE"	,cBairroe       ,Nil})
			AADD(aCabec,{"UA_MUNE"		,cMune       	,Nil})
			AADD(aCabec,{"UA_CEPE"  	,cCepe       	,Nil})
			AADD(aCabec,{"UA_ESTE"   	,cEste       	,Nil})
			AADD(aCabec,{"UA_PROSPEC"	,.F.	     	,Nil})
			AADD(aCabec,{"UA_DESCONT"  	,nDesconto     	,Nil})
			AADD(aCabec,{"UA_FRETE"   	,nFrete       	,Nil})
			AADD(aCabec,{"UA_DESPESA"  	,nDespesa       ,Nil})
		
			For nX := 1 To 5
				aLinha := {}
				aadd(aLinha,{"UB_ITEM"		,StrZero(nX,2)	,Nil})
				aadd(aLinha,{"UB_PRODUTO"	,SB1->B1_COD	,Nil})
				aadd(aLinha,{"UB_QUANT"		,2				,Nil})
				aadd(aLinha,{"UB_VRUNIT"	,50 			,Nil})
				aadd(aLinha,{"UB_VLRITEM"	,100			,Nil})
				aadd(aLinha,{"UB_TES"		,"501"			,Nil})
				aadd(aItens,aLinha)
			Next nX
		Next nY
	

	Case cRotina == "3"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluir atendimentos do telecobranca ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ConOut(STR0145 + Time())	//"Inicio: "
		For nY := 1 To 1
			aCabec := {}
			aItens := {}
			AADD(aCabec,{"ACF_CLIENT"	,cCod 		  	,Nil})	//Codigo do cliente
			AADD(aCabec,{"ACF_LOJA"		,cLoja      	,Nil})	//Codigo da loja
			AADD(aCabec,{"ACF_OPERAD"	,"000002"		,Nil})	//Codigo do Operador
			AADD(aCabec,{"ACF_OPERA"	,"2"			,Nil})	//Ligacao - 1-Receptivo 2-Ativo
			AADD(aCabec,{"ACF_CODCON"	,"000001"		,Nil})	//1-Ativo 2-Receptivo
			AADD(aCabec,{"ACF_STATUS"	,"2"			,Nil})	//Status do Atendimento 1-Atendimento 2-Cobranca 3-Encerrado
			AADD(aCabec,{"ACF_MOTIVO"	,"000001"		,Nil})	//Ocorrencia     
			AADD(aCabec,{"ACF_PENDEN"  	,dDatabase     	,Nil})	//Data de Retorno
			AADD(aCabec,{"ACF_HRPEND"	,"20:00"		,Nil})	//Hora de Retorno
			AADD(aCabec,{"ACF_OBS   "	,STR0146		,Nil})	//Observacao      /"Testes"
		
			DbSelectArea("SK1")
			DbSetOrder(4)
			If DbSeek(xFilial("SK1")+ cCod + cLoja)
			    While !SK1->(Eof()) .AND. xFilial("SK1")	== SK1->K1_FILIAL .AND. ;
			    				( cCod + cLoja ) 	== (SK1->K1_CLIENTE + K1_LOJA) 
											
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inserir o array de Itens obrigatoriamente na sequencia abaixo.    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aLinha := {}
					aadd(aLinha,{"ACG_PREFIX"	,SK1->K1_PREFIXO	,Nil})
					aadd(aLinha,{"ACG_PARCEL"	,SK1->K1_PARCELA	,Nil})
					aadd(aLinha,{"ACG_TIPO  "	,SK1->K1_TIPO		,Nil})
					aadd(aLinha,{"ACG_FILORI"	,SK1->K1_FILORIG	,Nil})
					aadd(aLinha,{"ACG_TITULO"	,SK1->K1_NUM 		,Nil})
					aadd(aLinha,{"ACG_STATUS"	,"2"		 		,Nil})//Negociado
					aadd(aItens,aLinha)

					SK1->(Dbskip())
				
				End
			Endif

		Next nY 
		
EndCase
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Executa a chamada da rotina de atendimento CALL CENTER       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMKA271(aCabec,aItens,3,cRotina)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe se foi feita a inclusao ou se retornou erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lMsErroAuto
	ConOut(STR0147)		//"Atendimento incluido com sucesso! "
Else
	ConOut(STR0148)		//"Erro na inclusao!"
	Mostraerro()
	DisarmTransaction()
	Break
Endif

ConOut("Fim  : "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alteracao de atendimentos          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAlterar

	Do Case
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alteracao de atendimentos televendas  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cRotina == "2"
			DbSelectArea("SUA")
			DbSetOrder(1)
			DbSeek(xFilial("SUA")+"000001")
			
			DbSelectArea("SUB") 
			DbSetOrder(1)
			DbSeek(xFilial("SUB")+"000001")
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+SUB->UB_PRODUTO)
							
			aCabec := {}
			aItens := {}
			AADD(aCabec,{"UA_NUM"		,SUA->UA_NUM	,Nil})
			AADD(aCabec,{"UA_CLIENTE"	,SUA->UA_CLIENTE,Nil})
			AADD(aCabec,{"UA_LOJA"		,SUA->UA_LOJA	,Nil})
			AADD(aCabec,{"UA_OPERADO"	,"000001"		,Nil})	//Codigo do Operador
			AADD(aCabec,{"UA_OPER"		,"2"			,Nil})	//1-Faturamento 2-Orcamento 3-Atendimento
			AADD(aCabec,{"UA_TMK"		,"1"			,Nil})	//1-Ativo 2-Receptivo
			AADD(aCabec,{"UA_CONDPG"	,"001" 			,Nil})	//Condicao de Pagamento
			AADD(aCabec,{"UA_TRANSP"	,"000001"		,Nil})	//Transportadora
			For nX := 1 To 1 
				aLinha := {}
				aadd(aLinha,{"LINPOS","UB_ITEM"		,"01"})
				aadd(aLinha,{"AUTDELETA","N"		,Nil})
				aadd(aLinha,{"UB_PRODUTO"			,SUB->UB_PRODUTO,Nil})
				aadd(aLinha,{"UB_QUANT"				,3				,Nil})
				aadd(aLinha,{"UB_VRUNIT"			,50				,Nil})
				aadd(aLinha,{"UB_VLRITEM"			,150			,Nil})
				aadd(aLinha,{"UB_TES"				,"501"			,Nil})
				aadd(aItens,aLinha)
			Next nX
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alteracao de atendimentos telecobranca³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cRotina == "3"
		    cAtend	:= "000023"
			DbSelectArea("ACF") 
			DbSetOrder(1)
			DbSeek(xFilial("ACF")+cAtend)
	
			aCabec := {}
			aItens := {}
			AADD(aCabec,{"ACF_CODIGO"	,cAtend       	,Nil})	//Codigo do Atendimento para alteracao
			AADD(aCabec,{"ACF_CLIENT"	,cCod       	,Nil})	//Codigo do cliente
			AADD(aCabec,{"ACF_LOJA"		,cLoja      	,Nil})	//Codigo da loja
			AADD(aCabec,{"ACF_OPERAD"	,"000002"		,Nil})	//Codigo do Operador
			AADD(aCabec,{"ACF_OPERA"	,"1"			,Nil})	//Ligacao - 1-Ativo 2-Receptivo
			AADD(aCabec,{"ACF_CODCON"	,"000001"		,Nil})	//1-Ativo 2-Receptivo
			AADD(aCabec,{"ACF_STATUS"	,"3"			,Nil})	//Status do Atendimento 1-Atendimento 2-Cobranca 3-Encerrado
			AADD(aCabec,{"ACF_MOTIVO"	,"000001"		,Nil})	//Ocorrencia     
			AADD(aCabec,{"ACF_PENDEN"  	,dDatabase     	,Nil})	//Data de Retorno
			AADD(aCabec,{"ACF_HRPEND"	,"20:00"		,Nil})	//Hora de Retorno
			AADD(aCabec,{"ACF_CODENC"	,"000001"		,Nil})	//Codigo do Encerramento 
			AADD(aCabec,{"ACF_OBSMOT"	,STR0149	,Nil})	//Observacao do Encerramento
			
			DbSelectArea("ACG")  
			DbSetOrder(1)
			DbSeek(xFilial("ACG")+cAtend)
			While !ACG->(Eof()) .AND. 	xFilial("ACG") 	== ACG->ACG_FILIAL .AND. ;
						  		ACG->ACG_CODIGO	== cAtend
				
				aLinha := {}
				aadd(aLinha,{"AUTDELETA","N"		,Nil})
				aadd(aLinha,{"ACG_PREFIX"			,ACG->ACG_PREFIX	,Nil}) 	//Prefixo do titulo
				aadd(aLinha,{"ACG_PARCEL"  			,ACG->ACG_PARCEL 	,Nil})	//Parcela do titulo
				aadd(aLinha,{"ACG_TIPO  "  			,ACG->ACG_TIPO		,Nil})	//Tipo do Titulo
				aadd(aLinha,{"ACG_FILORI"			,ACG->ACG_FILORI	,Nil}) 	//Filial de Origem
				aadd(aLinha,{"ACG_TITULO"			,ACG->ACG_TITULO	,Nil})	//Numero do Titulo
				aadd(aLinha,{"ACG_STATUS"  			,"1"				,Nil}) 	//Status do Titulo. 1-Pago 2-Negociado
				
				aadd(aItens,aLinha)
				
				ACG->(Dbskip())
				
			End    
	
	EndCase  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe se foi feita a alteracao ou se retornou erro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConOut(PadC(STR0150	,80)) 	//"Teste de alteracao"
	ConOut(STR0145 +Time())    //"Inicio: "
	
	TMKA271(aCabec,aItens,4,cRotina)
	
	If !lMsErroAuto
		ConOut(STR0151+cAtend)		//"Alterado com sucesso! "
	Else
		ConOut(STR0152)				//"Erro na alteracao!"
		Mostraerro()
		DisarmTransaction()
		Break
	Endif                          
	
	ConOut("Fim  : "+Time())
	ConOut(Repl("-",80))		

Endif
	
RESET ENVIRONMENT

Return(.T.)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271BOK  ºAutor  ³ Vendas Clientes    º Data ³  12/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama o ponto de entrada TK271BOK no botao Ok da toolbar da º±±
±±º          ³tela de atendimento e faz as validacoes de retorno do PE.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA271                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK271BOK( nOpc )
Local lRet		:= .T.								// Retorno da funcao 
Local lTK271BOK	:= ExistBlock("TK271BOK") 			// Ponto de Entrada no botao Ok da toolbar

If lTK271BOK
	lRet := U_TK271BOK( nOpc )
	If ValType( lRet ) <> "L"
		lRet := .T.
	Endif	
Endif	

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271MFil º Autor ³ Vendas Clientes    º Data ³  05/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama o ponto de entrada TK271Fil para filtrar o Browse de  º±±
±±º          ³acordo com o perfil do operador                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA271                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cExpC1 - Tabela que deve ser filtrada                      º±±
±±º          ³ cExpC2 - Filtro que será feito na tabela (Vem do PE)       º±±
±±º          ³ cExpA3 - Array com os índices utilizados                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nulo                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK271MFil( cAliasFil, cFiltra, aIndex )
Local bFiltraBrw	:= " "							// Bloco de codigo do filtro do ponto de entrada

cFiltra := U_TK271FIL( cAliasFil )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se existe algum retorno e se eh caracter ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Valtype( cFiltra ) == "C" .AND. !Empty( cFiltra )
	bFiltraBrw 	:= {|| FilBrowse( cAliasFil, @aIndex, @cFiltra )}
	Eval( bFiltraBrw )
	If ( Eof() )
		HELP(" ",1,"RECNO")
	Endif
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkSUDAfterAcols ³ Autor ³ Vendas Clientes ³ Data ³22/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o Acols da tela                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka271					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function TkSUDAfterAcols(aTmpHeader, aTmpCols, nOpc)

Local nPAssunto := 0	//Assunto
Local nPDescAss := 0	//Descricao do Assunto	
Local nPProd 	:= 0	//Produto
Local nPDescPro := 0	//Descricao do Produto
Local nPOcorren	:= 0	//Ocorrencia	
Local nPDescOco	:= 0	//Descricao da Ocorrencia
Local nPAcao   	:= 0	//Acao
Local nPDescAca	:= 0	//Descricao da Acao
Local nPCodOpe 	:= 0	//Codigo do Operador
Local nPDescOpe	:= 0	//Descricao do Operador
Local nPObsExec := 0	//Observercao
Local nPObsOri	:= 0	//Observacao original
Local nCnt := Len(aTmpCols)  
Local nX		:= 0
Local nY		:= 0
Local aHead2	:= {}
Local aCols2	:= {}
Local oVerde	:= LoaDbitmap(GetResources(),"BR_VERDE")	
Local oVerm		:= LoaDbitmap(GetResources(),"BR_VERMELHO")	
Local nPosStat	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere a legenda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                 
nPosStat := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_STATUS"})

If aScan(aTmpHeader,{|x| AllTrim(x[2]) == "CHECKBOX" }) == 0

	AAdd(aHead2,{"","CHECKBOX","@BMP",2,00,,,"C",,"V"})
	
	For nX := 1 to Len(aTmpHeader)
		AAdd(aHead2,aClone(aTmpHeader[nX]))
	Next nX    

	aTmpHeader := aClone(aHead2)
EndIf	

nPosStat := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_STATUS"})

For nX := 1 to nCnt
	If ValType(aTmpCols[nX][1]) <> "O"
		aCols2 := {}
		AAdd(aCols2,Nil)
		
		If !Empty(aTmpCols[nX][nPosStat-1]) .AND. aTmpCols[nX][nPosStat-1] == "2"
			aCols2[1] := oVerde
		Else
			aCols2[1] := oVerm
		EndIf         
		
		For nY := 1 to Len(aTmpCols[nX])
			AAdd(aCols2,aTmpCols[nX][nY])
		Next nY
		aTmpCols[nX] := aClone(aCols2)
	EndIf
Next nX

If nCnt > 0 .And. nOpc <> 3
	
	nPAssunto := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_ASSUNTO"})
	nPDescAss := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCASS"})
	nPProd 	  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_PRODUTO"})
	nPDescPro := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCPRO"})
	nPOcorren := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_OCORREN"})
	nPDescOco := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCOCO"})
	nPCodOpe  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_OPERADO"})
	nPDescOpe := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCOPE"})
	nPAcao    := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_SOLUCAO"})
	nPDescAca := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_DESCSOL"})
	nPObsExec := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_OBSEXEC"})		
	nPObsOri  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UD_COMPORI"})	
						
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a tabela de assunto esta atualizada no SX5³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aTmpCols[nCnt][nPAssunto])
		DbSelectArea("SX5")
		DbSetOrder(1)
		If !(DbSeek( xFilial("SX5")+"T1"+aTmpCols[nCnt][nPAssunto]))
			Help(" ",1,"ASSUNTO" )
		Endif
		
		aTmpCols[nCnt][nPDescAss] := X5DESCRI()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o produto esta atualizado no SB1          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aTmpCols[nCnt][nPProd])
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !(DbSeek( xFilial("SB1")+aTmpCols[nCnt][nPProd] ))
			Help(" ",1,"B1PROD" )
		Endif
		
		aTmpCols[nCnt][nPDescPro] :=SB1->B1_DESC
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a ocorrencia esta atualizada no SU9       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aTmpCols[nCnt][nPOcorren])
		DbSelectArea("SU9")
		DbSetOrder(2)
		If ! DbSeek( xFilial("SU9")+aTmpCols[nCnt][nPOcorren])
			Help(" ",1,"OCORRENCIA")
		Endif
		aTmpCols[nCnt][nPDescOco] := SU9->U9_DESC
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a acao esta atualizada na tabela SUQ      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aTmpCols[nCnt][nPAcao])
		DbSelectArea("SUQ")
		DbSetOrder(1)
		If !DbSeek( xFilial("SUQ")+aTmpCols[nCnt][nPAcao])
			Help(" ",1,"ACAO")
		Endif
		aTmpCols[nCnt][nPDescAca] := SUQ->UQ_DESC
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o responsavel pela acao esta no PSS       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aTmpCols[nCnt][nPCodOpe])
		PswOrder(1)
		If PswSeek(aTmpCols[nCnt][nPCodOpe])
			aUser := PswRet(1)
			If Len(aUser) > 0
				aTmpCols[nCnt][nPDescOpe] := aUser[1][2]
			Else
				aTmpCols[nCnt][nPDescOpe] := ""
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o conteudo do campo MEMO dos itens do SUD   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SUD->UD_CODEXEC)
		aTmpCols[nCnt][nPObsExec] := MSMM(SUD->UD_CODEXEC,60)
	Endif
	
	If nPObsOri > 0 .AND. !Empty(SUD->UD_CODCORI)
		aTmpCols[nCnt][nPObsOri] := MSMM(SUD->UD_CODCORI,60)
	Endif
	
EndIf	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkSUBAfterAcols ³ Autor ³ Vendas Clientes ³ Data ³22/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o Acols da tela                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka271					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Static Function TkSUBAfterAcols(aTmpHeader, aTmpCols, nOpc)
Local nPProd 	:= 0	//Produto
Local nPDescPro := 0	//Descricao do Produto
Local nPTes		:= 0	//TES
Local nPCFO		:= 0 	//Codigo Fiscal
Local nPItem	:= 0	//Item
Local nCnt := Len(aTmpCols)                                                                           
    
nPItem	  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_ITEM"})
If INCLUI
	If Len(aCols) = 1 .AND. nPItem > 0
		aCols[1][nPItem] := "01"	
	EndIf
EndIf

If nCnt > 0 .And. nOpc <> 3

	nPProd 	  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_PRODUTO"})		
	nPDescPro := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_DESCRI"})		
	nPTes	  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_TES"})		
	nPCFO	  := Ascan(aTmpHeader, {|x|AllTrim(x[2]) == "UB_CF"})		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o produto esta atualizado no SB1          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aTmpCols[nCnt][nPProd])
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !(DbSeek( xFilial("SB1")+aTmpCols[nCnt][nPProd] ))
			Help(" ",1,"B1PROD" )
		Endif	
		aTmpCols[nCnt][nPDescPro] := SB1->B1_DESC	
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a TES utilizada NAO vai gerar titulos - para evitar a obrigatoriedade da condicao de pagamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek(xFilial("SF4")+aTmpCols[nCnt][nPTes])
		If SF4->F4_DUPLIC == "S"
			lTesTit := .T.
		Else
			lTesTit := .F.
		Endif
	Endif
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |TkACGMontAcols  ³ Autor ³ Vendas Clientes ³ Data ³22/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o Acols da tela                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka271					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static Function TkACGMontAcols(	aTmpHeader	,aTlcCols	,cAlias	,cNumTlc	,;
								cString		)
Local nUsado	:= 0														// Linhas do acols	
Local nCnt		:= 0 														// Qtde. registros
Local nPAssunto := 0														// Assunto
Local nPDescAss := 0														// Descricao do Assunto	
Local nPProd 	:= 0														// Produto
Local nPDescPro := 0														// Descricao do Produto
Local nPOcorren	:= 0   														// Ocorrencia	
Local nPDescOco	:= 0														// Descricao da Ocorrencia
Local nPAcao   	:= 0														// Acao
Local nPDescAca	:= 0														// Descricao da Acao
Local nPCodOpe 	:= 0														// Codigo do Operador
Local nPDescOpe	:= 0   														// Descricao do Operador
Local aUser		:= {}														// Retorno da buscao do Responsavel (Usuario do SIGACFG)
Local nPObsExec	:= 0														// Complemento             
Local lRet		:= .F.														// Retorno da funcao
Local nUB_DESCRI:= 0														// Varivael auxiliar para controle da existencia do UB_DESCRI 	
Local nPTes		:= 0														// Posicao do TES
Local nPPrefix	:= 0														// Prefixo
Local nPTitulo	:= 0														// Titulo
Local nPParcel	:= 0														// Parcela
Local nPTipo	:= 0														// Tipo  
Local nPValRef  := 0 														// Valor de Referencia              
Local nPBaixa   := 0    													// Log de Baixa
Local nPStatus	:= 0														// Status do Titulo
Local nPFilOrig	:= 0														// Posicao da Filial de Origem do titulo	
Local nPDescFi	:= 0														// Desconto financeiro
Local nPDescJu	:= 0														// Desconto sobre juros
Local nPHist	:= 0														// Histórico do título
Local nPSituac	:= 0														// Situação do título
Local nPDSituac := 0														// Descrição da situação do título
Local nPPortad	:= 0														// Portador
Local nX		:= 0 														// Contador
Local nI		:= 0   														// Contador
Local cTmkJuros	:= GetNewPar("MV_TMKAJUR","1")								// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja
Local aBkRdpTlc	:= {}														// Armazena o Rodape para reprocessamento dos descontos
Local lTmk271ACG :=	IIF( ExistBlock("TMKA271ACG"), .T., .F. )
Local lRet271ACG := .F.

nPPrefix	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_PREFIX"} )
nPTitulo	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_TITULO"} )
nPParcel	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_PARCEL"} )
nPTipo		:= Ascan(aTmpHeader, {|x| x[2] == "ACG_TIPO  "} )
nPValRef	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_VALREF"} )
nPRecebe	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_RECEBE"} )
nPBaixa 	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_BAIXA "} )			
nPStatus	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_STATUS"} )			
nPVencto	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_DTVENC"} )
nPVencRea	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_DTREAL"} )
nPJuros  	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_JUROS "} )			
nPFilOrig	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_FILORI"} )			
nPDescFi	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_DESCFI"} )
nPHist		:= Ascan(aTmpHeader, {|x| x[2] == "ACG_HIST  "} )
nPSituac	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_SITUAC"} ) 
nPDSituac	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_DSITCB"} )
nPDescJu	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_DESCJU"} )
nPPortad	:= Ascan(aTmpHeader, {|x| x[2] == "ACG_PORTAD"} )

aTlcCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o rodape de Telecobranca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk274LimpaRdp()

DbSelectArea("ACG")
DbSetOrder(1)
DbSeek(xFilial("ACG")+ cNumTlc)
If !ACG->(EOF()) .AND. (ACG->ACG_FILIAL + ACG->ACG_CODIGO == xFilial("ACG") + cNumTlc)

	nUsado 		:= Len(aTmpHeader)
	aTlcCols 	:= {}

	DbSelectArea("ACF")
	DbSetOrder(1)
	DbSeek(xFilial("ACF")+ cNumTlc)
	DbSelectArea("ACG") 	
	While !ACF->(EOF()) .AND. (ACG->ACG_FILIAL + ACG->ACG_CODIGO == xFilial("ACG") + cNumTlc)
		
		If lTmk271ACG
			lRet271ACG := ExecBlock("TMKA271ACG",.F.,.F.)
			If !lRet271ACG
				DbSelectArea("ACG")
				ACG->(DbSkip())
				Loop  
			EndIf			
		EndIf  
		nCnt++
		Aadd(aTlcCols,Array(nUsado+1))
		
		For nX := 1 to Len(aTmpHeader)-2
			
			If (aTmpHeader[nX][10] <> "V" .AND. aTmpHeader[nX][08] <> "M")
				aTlcCols[Len(aTlcCols)][nX] := FieldGet(ColumnPos(aTmpHeader[nX][2]))
			Else
				If (aTmpHeader[nX][08] <> "M")
					aTlcCols[Len(aTlcCols)][nX] := CriaVar(aTmpHeader[nX][2],.T.)
				Else
					aTlcCols[Len(aTlcCols)][nX] := FieldGet(ColumnPos(aTmpHeader[nX][2]))
				Endif
			Endif
			aTlcCols[Len(aTlcCols)][nUsado+1] := .F.
			
		Next nX   
		
		aTlcCols[Len(aTlcCols)][nUsado-1] := cAlias
		aTlcCols[Len(aTlcCols)][nUsado] := (cAlias)->(Recno())		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valido a existencia do campo ACG_FILORI criado. Caso nao exista, assumo a filial corrente do SE1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPFilOrig > 0
			cFilOrig	:= aTlcCols[Len(aTlcCols)][nPFilOrig]
		Else
			cFilOrig	:= xFilial("SE1")
		Endif
		
		DbSelectArea("SE1")
		DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
		If DbSeek(cFilOrig + ACF->ACF_CLIENT + ACF->ACF_LOJA + aTlcCols[Len(aTlcCols)][nPPrefix] + aTlcCols[Len(aTlcCols)][nPTitulo] + aTlcCols[Len(aTlcCols)][nPParcel] + aTlcCols[Len(aTlcCols)][nPTipo])
		
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³   Retorno   ³ExpA1: Array com a seguinte estrutura                        ³
			//³             ³       [1] Valor Original do Titulo                          ³
			//³             ³       [2] Abatimentos                                       ³
			//³             ³       [3] Pagto Parcial                                     ³
			//³             ³       [4] Decrescimo                                        ³
			//³             ³       [5] Acrescimo                                         ³
			//³             ³       [6] Saldo do Titulo na Moeda do Titulo                ³
			//³             ³       [7] Saldo do Titulo na Moeda Corrente                 ³
			//³             ³       [8] Juros                                             ³
			//³             ³       [9] Desconto                                          ³
			//³             ³       [10] Correcao Monetaria                               ³
			//³             ³       [11] Valor a ser Recebido na moeda do titulo          ³
			//³             ³       [12] Valor a ser Recebido na moeda corrente           ³
			//³             ³       [13] Multa                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/ 
	
			aValores := FaVlAtuCr(	NIL		, NIL	, NIL	, NIL	,;
									cFilOrig, .T.	)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o calculo dos juros do titulo for baseado nos parametros MV_LJJUROS e MV_LJMULT ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTmkJuros == "2"
				Tk274CalcJuros( @aValores		, @aTlcCols		, aTmpHeader, Nil,;
								SE1->E1_CLIENTE	, SE1->E1_LOJA	, Nil		, SU7->U7_COD )
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o Valor de Referencia, Receber, Baixa e Status na Alteracao/ Visualizacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aTlcCols[Len(aTlcCols)][nPValRef]:= aValores[6] //Valor de Referencia
				aTlcCols[Len(aTlcCols)][nPJuros] := aValores[8] //Juros baseado no SE1
				aTlcCols[Len(aTlcCols)][nPRecebe]:= aValores[12]//Valor a Receber
			Endif
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Compatibiliza os campos com os dados do SE1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTlcCols[Len(aTlcCols)][nPVencto]	:= SE1->E1_VENCTO 	//Data de Vencto.
			aTlcCols[Len(aTlcCols)][nPVencRea]	:= SE1->E1_VENCREA 	//Vencto. Real

			If nPHist > 0
				aTlcCols[Len(aTlcCols)][nPHist]	:= SE1->E1_HIST		//Historico do título
			EndIf

			If nPSituac > 0
				aTlcCols[Len(aTlcCols)][nPSituac] := SE1->E1_SITUACA	//Situação do título
			EndIf

			If nPDSituac > 0
				aTlcCols[Len(aTlcCols)][nPDSituac] := Posicione("FRV",1,xFilial("FRV")+SE1->E1_SITUACA,"FRV_DESCRI")	//Descricao da situação do título
			EndIf

			If nPPortad > 0 
				aTlcCols[Len(aTlcCols)][nPPortad] := SE1->E1_PORTADO	//Portador
			EndIf
							
	        Do Case 
	        	Case !Empty(SE1->E1_BAIXA) // Se houve uma baixa verifica se foi TOTAL ou PARCIAL
	        		 If (SE1->E1_SALDO > 0)
						aTlcCols[Len(aTlcCols)][nPBaixa] := "1" //Baixa Parcial
						aTlcCols[Len(aTlcCols)][nPStatus]:= "4" //Baixa
					 Endif
					 
					 If (SE1->E1_SALDO == 0)
						aTlcCols[Len(aTlcCols)][nPBaixa] := "3" //Baixa Total
						aTlcCols[Len(aTlcCols)][nPStatus]:= "1" //Pago
					 Endif	
	
		        Case Empty(SE1->E1_BAIXA) // Nao houve nenhuma baixa 
					aTlcCols[Len(aTlcCols)][nPBaixa] := "2" //Sem Baixa            	
	
		  	EndCase	  	
	  					
			// [2] Abatimentos
			// [A] Correcao Monetaria
			// [8] Juros
			// [5] Acrescimo  - E1_SDACRES
			// [4] Decrescimo - E1_SDDECRE
			// [9] Desconto
			// [1] Valor Original do Titulo
			// [6] Saldo do Titulo na Moeda do Titulo
			// [7] Saldo do Titulo na Moeda Corrente
			// [3] Pagto Parcial
			// [B] Valor a ser Recebido na moeda do titulo
			// [C] Valor a ser Recebido na moeda corrente
			
			aRdpTlc[1][2]	:= aRdpTlc[1][2] + aValores[2]
			aRdpTlc[2][2]	:= aRdpTlc[2][2] + aValores[10]
			aRdpTlc[3][2]	:= aRdpTlc[3][2] + aValores[8]
			aRdpTlc[4][2]	:= aRdpTlc[4][2] + ACG->ACG_ACRESC
			aRdpTlc[5][2]	:= aRdpTlc[5][2] + ACG->ACG_DECRES
			aRdpTlc[6][2]	:= aRdpTlc[6][2]
			aRdpTlc[7][2]	:= aRdpTlc[7][2] + aValores[1]
			aRdpTlc[8][2]	:= aRdpTlc[8][2] + aValores[6]
			aRdpTlc[9][2]	:= aRdpTlc[9][2] + aValores[7]
			aRdpTlc[10][2]	:= aRdpTlc[10][2] + aValores[3]
			aRdpTlc[11][2]	:= aRdpTlc[11][2] + aValores[11] + aValores[9] - ACG->ACG_DECRES
			aRdpTlc[12][2]	:= aRdpTlc[12][2] + aValores[12] + aValores[9]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recalcula os descontos ja aplicados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aBkRdpTlc	:= aClone(aRdpTlc)
			
			Tk274DescFi(aTlcCols[Len(aTlcCols)][nPDescFi]	, @aTlcCols	, Len(aTlcCols)	, ACF->ACF_OPERAD	,;
						aTmpHeader							, @aBkRdpTlc, .T.)
			aRdpTlc		:= aClone(aBkRdpTlc)
								
            If (nPDescJu <> 0) 
	            aBkRdpTlc	:= aClone(aRdpTlc)
	            Tk274DescJu(aTlcCols[Len(aTlcCols)][nPDescJu]	, @aTlcCols	, Len(aTlcCols)	, ACF->ACF_OPERAD	,;
	            			aTmpHeader							, @aBkRdpTlc, .T.)
       			aRdpTlc		:= aClone(aBkRdpTlc)
	        EndIf				        

			
		Endif
		DbSelectArea("ACG")
		ACG->(DbSkip())
	End	
Else

	aTlcCols := Array(1, Len(aTmpHeader) + 1)	
	TkHeader(cAlias,cString,@aTlcCols,aTmpHeader)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 |Tk271CanHab     ³ Autor ³ Vendas Clientes ³ Data ³ 19/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Utilizado para se saber se o atendimento pode ser cancelado³±±
±±³          ³ ou se precisa obrigatóriamente ser confirmado.             ³±±
±±³          ³ Sua principal função é não permitir que um atendimento     ³±±
±±³          ³ executado através da agenda do operador seja cancelado.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka271					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271CanHab( l380, lPriContato)
	Local lRet := .T.
	Local lHabilita := .T. 
	
	Default l380 := .F.
	Default lPriContato := .F.

	If l380
   		Do Case
	 		Case nFolder == 1 
	 			If (TkGetTipoAte() == "3") //Telecobranca
	 				lHabilita := IIF(Type("M->ACF_CLIENT") == "C" .AND. Empty(M->ACF_CLIENT), .F., .T.)	
	 			ElseIf (TkGetTipoAte() == "1") //Telemarketing
	 				lHabilita := IIF(Type("M->UC_CODCONT") == "C" .AND. Empty(M->UC_CODCONT), .F., .T.) 
	 			EndIf	 			
	 		Case nFolder == 2
	 			lHabilita := IIF(Type("M->UA_CLIENTE") == "C" .AND. Empty(M->UA_CLIENTE), .F., .T.) 
	 		Case nFolder == 3
	 			lHabilita := IIF(Type("M->ACF_CLIENT") == "C" .AND. Empty(M->ACF_CLIENT), .F., .T.)	
   		End Case
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for executado através da agenda do operador e for  ³
	//³o primeiro contato a ser atendido na sessão (Desde que³
	//³a janela de atendimento foi aberta).                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l380 .AND. lPriContato .AND. lHabilita
		lRet :=	.F.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271AtalhoºAutor  ³Vendas CRM         º Data ³  04/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Configura os atalhos padrao para as acoes do call center,   º±±
±±º          ³considerando os atalhos definidos pelo usuario.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Numero da rotina executada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271Atalho(nBotao)

Local aRet	:= Array(2)
Local aAtUsr:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem a definicao do usuario, caso a tecla padrao tenha sido modificada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TkAtalUsr(nBotao,@aAtUsr,Upper(FunName()))
	Return aAtUsr
EndIf

Do Case

	//Limpar chamado
	Case nBotao == 1
		aRet[1] := K_CTRL_L
		aRet[2] := "CTRL+L"

	//Cancela o chamado
	Case nBotao == 2
		aRet[1] := K_CTRL_N
		aRet[2] := "CTRL+N"

	//Marketing Ativo
	Case nBotao == 3
		aRet[1] := K_CTRL_M
		aRet[2] := "CTRL+M"

	//Script de Campanha
	Case nBotao == 4
		aRet[1] := K_CTRL_I
		aRet[2] := "CTRL+I"

	//Alteracao de entidade
	Case nBotao == 5
		aRet[1] := K_CTRL_A
		aRet[2] := "CTRL+A"

	//Historico de entidade
	Case nBotao == 6
		aRet[1] := K_CTRL_H
		aRet[2] := "CTRL+H"
		
	//Situacao financeira
	Case nBotao == 7
		aRet[1] := K_CTRL_F
		aRet[2] := "CTRL+F"

	//Cadastro do contato
	Case nBotao == 8
		aRet[1] := K_CTRL_D
		aRet[2] := "CTRL+D"

	//Banco de conhecimento
	Case nBotao == 9
		aRet[1] := K_CTRL_B
		aRet[2] := "CTRL+B"
		
	//Tracker da entidade
	Case nBotao == 10
		aRet[1] := K_CTRL_T
		aRet[2] := "CTRL+T"

	//Visualisa eventos
	Case nBotao == 11
		aRet[1] := K_CTRL_G
		aRet[2] := "CTRL+G"
	
	//Envio de tarefa
	Case nBotao == 12
		aRet[1] := K_CTRL_R
		aRet[2] := "CTRL+R"
		                     
	//Perfil do contato
	Case nBotao == 13
		aRet[1] := K_CTRL_P
		aRet[2] := "CTRL+P"

	//Agendamento da O.S.
	Case nBotao == 14
		aRet[1] := K_CTRL_J
		aRet[2] := "CTRL+J"		
		
EndCase

aRet[2] := "("+aRet[2]+")"

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkCfgAtalhoºAutor  ³Vendas CRM         º Data ³  04/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para configuracao dos atalhos para que o usuario esco- º±±
±±º          ³lha suas teclas de preferencia.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Lista de rotinas e atalhos relacionados             º±±
±±º          ³ExpC2 - Nome do programa em execucao                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkCfgAtalho(aAtalhos,cRotina)

Local oDlg
Local oBtCanc
Local oBtOk
Local oGroup1
Local oLbx
Local oFonte := TFont():New("Tahoma",0,16,,.T.)

DEFINE MSDIALOG oDlg TITLE STR0172 FROM 000, 000  TO 320, 445 COLORS 0, 16777215 PIXEL //"Configuração de atalhos"

@ 002, 002 TO 023, 218 OF oDlg PIXEL
@ 141, 128 BUTTON oBtOk   PROMPT STR0173 SIZE 042, 015 OF oDlg PIXEL Action (Tk271DelAtalho(aAtalhos,cRotina),oDlg:End()) //"Padrão"
@ 141, 174 BUTTON oBtCanc PROMPT STR0174 SIZE 042, 015 OF oDlg PIXEL ACTION oDlg:End() //"Ok"
@ 025, 002 LISTBOX oLbx Fields HEADER STR0175,STR0176 SIZE 216, 112 OF oDlg PIXEL ON dblClick(Tk271AltAtalho(@aAtalhos,@oLbx,cRotina)) //"Ação"###"Atalho"
@ 008, 006 SAY STR0177 FONT oFonte SIZE 206, 010 OF oDlg  PIXEL //"Clique duas vezes sobre uma ação para alterar seu atalho"

oLbx:SetArray(aAtalhos)
oLbx:bLine:={||{aAtalhos[oLbx:nAt,1],aAtalhos[oLbx:nAt,2] }}

ACTIVATE MSDIALOG oDlg CENTERED

MsgInfo(STR0178) //"As alterações serão consideradas somente a partir do próximo acesso."

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271AltAtalhoºAutor  ³Vendas CRM      º Data ³  05/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera o atalho para uma rotina e salva no profile do usua- º±±
±±º          ³rio corrente.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParamtros ³ExpA1 - Lista de acoes e atalhos                            º±±
±±º          ³ExpO2 - Objeto da listbox para atualizacao                  º±±
±±º          ³ExpC3 - Nome do programa em execucao                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271AltAtalho(aAtalhos,oLbx,cRotina)

Local oDlg
Local oButOk
Local oCombo
Local nOpcCombo := 1
Local oSay1

Static aMapAtalho := {}

If Empty(aMapAtalho)
	TkCrgMpAt()
EndIf

//Pre seleciona a opcao de atalho atual
nOpcCombo := aScan(aMapAtalho[2],aAtalhos[oLbx:nAt,3])

If nOpcCombo == 0
	nOpcCombo := 1
EndIf

//Exibe interface
DEFINE MSDIALOG oDlg TITLE STR0179 FROM 000, 000  TO 100, 330 COLORS 0, 16777215 PIXEL //"Configurar atalho"

@ 004, 002 TO 034, 162 OF oDlg PIXEL
@ 016, 005 SAY oSay1 PROMPT STR0180 SIZE 074, 007 OF oDlg PIXEL //"Selecione a tecla de atalho:"
@ 014, 076 MSCOMBOBOX oCombo VAR nOpcCombo ITEMS aMapAtalho[1] SIZE 074, 010 OF oDlg  PIXEL
@ 035, 135 BUTTON oButOk PROMPT STR0174 SIZE 026, 012 OF oDlg ACTION (AtuArrAtalho(oCombo:nAt,aAtalhos,oLbx,cRotina),oDlg:End()) PIXEL //"Ok"

ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuArrAtalhoºAutor  ³Vendas CRM        º Data ³  05/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o array de atalhos e salva a configuracao para o   º±±
±±º          ³usuario atual                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Numero da opcao do combo selecionada                º±±
±±º          ³ExpA2 - Array de rotinas e atalhos                          º±±
±±º          ³ExpO3 - Objeto da Listbox                                   º±±
±±º          ³ExpC4 - Nome da rotina em execucao                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuArrAtalho(nOpcCombo,aAtalhos,oLbx,cRotina)

Local nPos 		:= 0
Local nOpcao	:= 1
Local lValido	:= .T.

//Se nao houve alteracao, ignora
If aAtalhos[oLbx:nAt][3] == aMapAtalho[2][nOpcCombo]
	Return Nil
EndIf

If (nPos := aScan(aAtalhos,{|x|x[3] == aMapAtalho[2][nOpcCombo]})) > 0
	nOpcao := 2
	//"Atenção"###"Este atalho já esta em uso por outra ação("###"). Deseja utilizar este atalho mesmo assim?"###
	nOpcao := Aviso(STR0104, STR0181 + aAtalhos[nPos][1]+; 
					STR0182+CRLF+STR0183, {STR0184,STR0185}, 2) //"Sim"###"Não"
	If nOpcao == 1
		aAtalhos[nPos][2] := ""
		aAtalhos[nPos][3] := 0
	EndIf
EndIf

If nOpcao == 1
	aAtalhos[oLbx:nAt][2] := "("+aMapAtalho[1][nOpcCombo]+")"
	aAtalhos[oLbx:nAt][3] := aMapAtalho[2][nOpcCombo]
	
	oLbx:SetArray(aAtalhos)
	oLbx:bLine:={||{aAtalhos[oLbx:nAt,1],aAtalhos[oLbx:nAt,2] }}
	oLbx:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva a configuração no profile do usuário.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[oLbx:nAt][4])
	WriteProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[oLbx:nAt][4], __cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[oLbx:nAt][4], cValToChar(aMapAtalho[2][nOpcCombo]))
Else
	WriteNewProf(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[oLbx:nAt][4], cValToChar(aMapAtalho[2][nOpcCombo]))	
EndIf

If nPos > 0
	If FindProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[nPos][4])
		WriteProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[nPos][4], __cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[nPos][4], "0")
	Else
		WriteNewProf(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[nPos][4], "0")	
	EndIf	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkAtalUsr ºAutor  ³Vendas CRM          º Data ³  05/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a tecla de atalho salva no perfil do usuario de     º±±
±±º          ³acordo com a acao selecionada e programa em execucao.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Numero da acao                                      º±±
±±º          ³ExpA2 - Array de retorno(referencia) com atalho do usuario  º±±
±±º          ³ExpC3 - Nome do programa em execucao                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkAtalUsr(nRotina,aRet,cRotina)

Local nCodAtalho:= 0
Local cAtalho	:= ""
Local lAchou	:= .F.

If Empty(aMapAtalho)
	TkCrgMpAt()
EndIf

If  FindProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", cValToChar(nRotina))
	nCodAtalho 	:= Val(RetProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", cValToChar(nRotina)))
	If nCodAtalho > 0
		cAtalho		:= "("+aMapAtalho[1][aScan(aMapAtalho[2], nCodAtalho )]+")"
	EndIf
	lAchou		:= .T.
EndIf

If nCodAtalho == 0
	aRet := {NIL,NIL}
Else
	aRet := {nCodAtalho,cAtalho}
EndIf

Return lAchou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkCrgMpAt ºAutor  ³Vendas CRM          º Data ³  05/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega a relacao de siglas e codigos de atalhos disponiveisº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkCrgMpAt()

aMapAtalho := {{},{}}

//Carrega lista de possiveis atalhos (Não utilizar o CTRL+S, pois é um atalho padrão do sistema)
AAdd(aMapAtalho[1],"F4"  )		;AAdd(aMapAtalho[2],VK_F4  )
AAdd(aMapAtalho[1],"F5"  )		;AAdd(aMapAtalho[2],VK_F5  )
AAdd(aMapAtalho[1],"F6"  )		;AAdd(aMapAtalho[2],VK_F6  )
AAdd(aMapAtalho[1],"F7"  )		;AAdd(aMapAtalho[2],VK_F7  )
AAdd(aMapAtalho[1],"F8"  )		;AAdd(aMapAtalho[2],VK_F8  )
AAdd(aMapAtalho[1],"F9"  )		;AAdd(aMapAtalho[2],VK_F9  )
AAdd(aMapAtalho[1],"F10" )		;AAdd(aMapAtalho[2],VK_F10 )
AAdd(aMapAtalho[1],"F11" )		;AAdd(aMapAtalho[2],VK_F11 )
AAdd(aMapAtalho[1],"F12" )		;AAdd(aMapAtalho[2],VK_F12 )
AAdd(aMapAtalho[1],"CTRL+A")	;AAdd(aMapAtalho[2],K_CTRL_A)
AAdd(aMapAtalho[1],"CTRL+B")	;AAdd(aMapAtalho[2],K_CTRL_B)
AAdd(aMapAtalho[1],"CTRL+D")	;AAdd(aMapAtalho[2],K_CTRL_D)
AAdd(aMapAtalho[1],"CTRL+E")	;AAdd(aMapAtalho[2],K_CTRL_E)
AAdd(aMapAtalho[1],"CTRL+F")	;AAdd(aMapAtalho[2],K_CTRL_F)
AAdd(aMapAtalho[1],"CTRL+G")	;AAdd(aMapAtalho[2],K_CTRL_G)
AAdd(aMapAtalho[1],"CTRL+H")	;AAdd(aMapAtalho[2],K_CTRL_H)
AAdd(aMapAtalho[1],"CTRL+I")	;AAdd(aMapAtalho[2],K_CTRL_I)
AAdd(aMapAtalho[1],"CTRL+J")	;AAdd(aMapAtalho[2],K_CTRL_J)
AAdd(aMapAtalho[1],"CTRL+K")	;AAdd(aMapAtalho[2],K_CTRL_K)
AAdd(aMapAtalho[1],"CTRL+L")	;AAdd(aMapAtalho[2],K_CTRL_L)
AAdd(aMapAtalho[1],"CTRL+M")	;AAdd(aMapAtalho[2],K_CTRL_M)
AAdd(aMapAtalho[1],"CTRL+N")	;AAdd(aMapAtalho[2],K_CTRL_N)
AAdd(aMapAtalho[1],"CTRL+P")	;AAdd(aMapAtalho[2],K_CTRL_P)
AAdd(aMapAtalho[1],"CTRL+Q")	;AAdd(aMapAtalho[2],K_CTRL_Q)
AAdd(aMapAtalho[1],"CTRL+R")	;AAdd(aMapAtalho[2],K_CTRL_R)
AAdd(aMapAtalho[1],"CTRL+T")	;AAdd(aMapAtalho[2],K_CTRL_T)
AAdd(aMapAtalho[1],"CTRL+U")	;AAdd(aMapAtalho[2],K_CTRL_U)
AAdd(aMapAtalho[1],"CTRL+V")	;AAdd(aMapAtalho[2],K_CTRL_V)
AAdd(aMapAtalho[1],"CTRL+W")	;AAdd(aMapAtalho[2],K_CTRL_W)
AAdd(aMapAtalho[1],"CTRL+Y")	;AAdd(aMapAtalho[2],K_CTRL_Y)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271DelAtalhoºAutor  ³Vendas CRM      º Data ³  08/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Remove as configuracoes do usuario para os atalhos          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Relacao de atalhos                                  º±±
±±º          ³ExpC2 - Nome da rotina relacionada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271DelAtalho(aAtalhos,cRotina)

Local nX 

If MsgNoYes(STR0186) //"Confirma a restauração dos atalhos padrão para esta rotina?"
	For nX := 1 to Len(aAtalhos)
		If FindProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[nX][4])
			EraseProfDef(__cUserID + cEmpAnt + cFilAnt, cRotina, "TKSHORTCUT", aAtalhos[nX][4])
		EndIf
	Next nX
EndIf   

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271PerfilºAutor ³Vendas CRM          º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aciona a consulta Perfil do Contato                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK271Perfil()

Local lRet		:= .T.
Local cCliente	:= ""
Local cLoja		:= ""
Local cContato	:= ""
Local cEntidade	:= "SA1"
Local aCpoMemo	:= {}		//Array para guardar o conteudo do campo Memo antes da Chamada para a função TK010Con

SaveInter()

Private aDados		:= Array(7)
Private cCadastro	:= STR0220 //"Informacoes gerenciais das entidades"
Private aRotina		:= {{STR0002,"AxPesqui", 0 , 1 , , .F.},;		//"Pesquisar"
						{STR0221,"TK010Con", 0 , 2 , , .T.} }		//"Consulta"
						
Private aTELA[0][0],aGETS[0]

INCLUI := .F.
ALTERA := .F.

If nFolder == 1
	If (TkGetTipoAte() $ "145")  //Telemarketing, Ambos ou TMK x TLV
		cContato	:= M->UC_CODCONT
		cEntidade	:= M->UC_ENTIDAD
		cCliente	:= M->UC_CHAVE
		cLoja		:= ""
		
	ElseIf TkGetTipoAte() == "2" // Televendas
		cCliente := M->UA_CLIENTE
		cLoja    := M->UA_LOJA
		cContato := M->UA_CODCONT

	ElseIf TkGetTipoAte() == "3" // Telecobranca
		cCliente := M->ACF_CLIENT
		cLoja    := M->ACF_LOJA
		cContato := M->ACF_CODCON
	Endif

ElseIf nFolder == 2  // Televendas
	cCliente := M->UA_CLIENTE
	cLoja    := M->UA_LOJA
	cContato := M->UA_CODCONT
	
	//Salvar os campos Memo que não estão sendo restaurados pelo SaveInter()
	aCpoMemo := Tk273SvMemo("SUA",1)
	
ElseIf nFolder == 3  // Telecobranca
	cCliente := M->ACF_CLIENT
	cLoja    := M->ACF_LOJA
	cContato := M->ACF_CODCON
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Operador executa as rotinas: TODAS e TMK x TLV e nao esta no 1 folder - O cliente e Obrigatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (TkGetTipoAte() $ "45") .AND. nFolder <> 1
	If Empty(cCliente) .AND. Empty(cLoja)
		Help(" ",1,"SEM CLIENT")
		lRet := .F.
	Endif	
Endif

If lRet .AND. Empty(cContato)
	lRet := .F.
	MsgInfo(STR0222) //"Selecione um contato antes de consultar seu perfil"
EndIf

If lRet .AND. Empty(cCliente)
	lRet := .F.
	MsgInfo(STR0223) //"Selecione uma entidade antes de consultar seu perfil"
EndIf

If lRet
	TK010Con(,,,,cContato,cEntidade,cCliente+cLoja)
EndIf

If nFolder == 2
	Tk273SvMemo(Nil,2,aCpoMemo)
EndIf

RestInter()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271VlCancelºAutor  ³Vendas CRM       º Data ³  16/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a validação do botão Fechar/Cancela do atendimento TLC.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Numero da rotina executada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271VlCancel(l380,lPriContato)

Local lRet    := .T.
Local aArea   := {}
Local cAltPed := SuperGetMV("MV_ALTPED")   	// Parametro que permite a edição de pedido já faturado
Local cChave	:= ""

If l380 .AND. lPriContato .AND. cAltPed == "N" .AND. (TkGetTipoAte()=="2") //Televendas
	//Se o pedido ja foi faturado e não permite alteração (MV_ALTPED=N), deixa o operador sair do atendimento da agenda.
	If SUA->UA_STATUS == "NF." .AND. !Empty(SUA->UA_NUMSC5)
		aArea := GetArea()
		DbSelectArea("SC5")
		DbSetOrder(1)
		If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
			If !Empty(SC5->C5_NOTA)
				RestArea(aArea)
				Return (lRet)
			EndIf
		EndIf
	EndIf	
EndIf

//Não permite que o usuário feche/cancele a janela do atendimento sem a confirmação dos dados do atendimento.
//Foi feita esta validação, pois nesta versão não tem como desabilitar o botão fechar/cancelar como era feita na versão anterior.
If !Tk271CanHab(l380,lPriContato)
	Aviso(STR0104,STR0235,{"OK"})	//"Este atendimento não pode ser fechado. É necessário a confirmação dos dados do atendimento."
	lRet := .F.
EndIf

//----------------------------------------------------------
// Controle de concorrência TMK
//----------------------------------------------------------
If ( TkGetTipoAte() $ "145" ) .And. nFolder == 1  //Telemarketing ou todos
	cChave := cEmpAnt + xFilial( "SUC" ) + M->UC_CODIGO
	Tk271UnLock( cChave )
EndIf

Return (lRet)

//----------------------------------------------------------------
/*/{Protheus.doc} Tk271SKey()
Função para habilitar e desabilitar as teclas de atalho
@author Serviços
@since 24/03/2014
/*/
//----------------------------------------------------------------
Static Function Tk271SKey(nAcao)
Local nI		:= 0

//nAcao == 1 Desabilita SetKey / nAcao == 2 Habilita SetKey	
Default nAcao := 0

If nAcao > 0 .And. nAcao == 1
	For nI := 1 To Len(aButBar)
		If aButBar[nI][5] <> Nil .And. aButBar[nI][6] <> Nil
			SetKey(aButBar[nI][5], {||})
		EndIf
	Next nI
ElseIf nAcao > 0 .And. nAcao == 2
	For nI := 1 To Len(aButBar)
		If aButBar[nI][5] <> Nil .And. aButBar[nI][6] <> Nil
			SetKey(aButBar[nI][5], aButBar[nI][2])
		EndIf
	Next nI
EndIf

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk271Lock

Cria arquivo para fazer lock do registro para controle de concorrência.

@param cChvAtend, caracter, chave do atendimento composto por (Empresa+Filial+Codigo do Atend.) 
@param cOperator, caracter, operador do atendimento
@param cAtendAt , caracter, número do atendimento ativo
@param cCodLig  , caracter, número do atendimento selecionado
 
@return lRet	  , lógico	 , .T. se conseguiu utilizar o registro ou .F. caso o atendimento	
										esteja em uso.

@author  Thamara Villa Jacomo
@version P12
@since   02/03/2016  

/*/
//------------------------------------------------------------------------------------------
Function Tk271Lock( cChvAtend, cAtendAt, cCodLig, cLock )
	
Local lRet 			:= .F.
Local cChave		:= ""
Local nHandle   	:= 0

Default cChvAtend	:= ""
Default cAtendAt	:= ""
Default cCodLig		:= ""
Default	cLock		:= ""
//--------------------------------------------------------------------------------------
// Verifica se há atendimento ativo, se sim, libera o registro para carregar um novo
//--------------------------------------------------------------------------------------
DbSelectarea( "SUC" )
DbSetorder( 1 )
If DbSeek( xFilial( "SUC" ) + cAtendAt )
	If Alltrim( cAtendAt ) <> Alltrim( cCodLig )
		//----------------------------------------------
		// Limpa o atendimento para carregar um novo
		//----------------------------------------------
		cChave := cEmpAnt + xFilial( "SUC" ) + cAtendAt
		UnLockByName(cChave,.T.,FWModeAccess("SUC",3) == "E",.T.)
	EndIf
EndIf
	
If !LockByName(cChvAtend,.T.,FWModeAccess("SUC",3) == "E",.T.)
	MsgAlert(OemToAnsi(STR0219))
Else
	cLock 	:= cChvAtend
	lRet	:= .T.
EndIf
Return( lRet )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk271UnLock

Apaga o arquivo para liberar o registro para utilização (Controle de concorrência)

@param cChvAtend, caracter, chave do atendimento composto por (Empresa+Filial+Codigo do Atend.) 
 
@return Nil

@author  Anderson José
@author  Thamara Villa

@version P12
@since   02/03/2016  

/*/
//------------------------------------------------------------------------------------------
Function Tk271UnLock( cChvAtend )

Local cArq	:= GetSrvProfString( "Startpath", "" ) + cChvAtend + ".log"
	
FErase( cArq )

Return( Nil ) 

//----------------------------------------------------------------
/*/{Protheus.doc} Tk271Field()
Indica campos que serao apresentados em uma MSMGet
@author Saude
@since 25/04/2016
/*/
//----------------------------------------------------------------
Static Function Tk271Field(cAlias,cNoFields)
Local aFields     := {}        
Local aAreaSx3	  := SX3->(GetArea())
Default cNoFields := ""

SX3->(DbSetOrder(1))
If SX3->(DbSeek(cAlias))  
	While SX3->X3_ARQUIVO == cAlias  .And. !SX3->(Eof())
		If !(Alltrim(SX3->X3_CAMPO) $ cNoFields) .And. X3Uso(SX3->X3_USADO)                               
			Aadd(aFields, SX3->X3_CAMPO)
		EndIf               
		
		SX3->(DbSkip())
	EndDo                 
EndIf
RestArea(aAreaSx3)

Return aFields

//-------------------------------------------------------------------
/*/{Protheus.doc} Tk271VldTerr
Valida distribuicao de territorio da entidade e realiza: S=Simulacao da distribuicao ou G=(Gravacao) Distribui a conta para o territorio e realiza rodizio   

@param cEntidade, character, Entidade
@param cChavePesq	, character, Chave para pesquisa (codigo+loja)
@param cTipoVld, character, Tipo de validacao S = Simulacao / G = Simulacao + Rodizio + Gravacao
@param lVldAcao, logico, Verifica se a acao escolhida aplica validacao de territorio (.T. = Sim / .F. = Nao)
@param cCodAcao, character, Codigo da acao  
 
@return aRet[1], Lógico, Array com a posição 1 Verdadeiro ou falso 
@author  Eduardo Gomes Junior 
@version P12
@since   23/09/2015  
/*/
//-------------------------------------------------------------------

Static Function Tk271VldTerr(cEntidade, cChavePesq, cTipoVld, lVldAcao, cCodAcao)

Local aArea			:= GetArea()								//Salva area
Local lRet			:= .F.
Local aTerritory	:= {}										//Array contendo dados da distruibuicao
Local cProcess		:= ""										//Rotina a ser considerada
Local lVldTerrit	:= .T.										//Indica se deve realizar validacao
Local aRet 			:= {.T.,""}								//Retorno das funcoes CRMA690EvalTerritory / CRMA690CasterTerritory
Local cCpoCODTER 	:= ""										//Codigo do Territorio
Local cCpoTPMEMB 	:= ""										//Tipo do Membro
Local cCpoCODMEMB	:= ""										//Codigo do Membro
Local cCpoCODVEND	:= ""										//Codigo do vendedor
Local cCodTer		:= ""										//Codigo do territorio	 
Local cNomeMTER		:= ""										//Nome do territorio
Local cCodMemb		:= ""										//Codigo do membro
Local cTipMemb		:= ""										//Tipo de membro / 1=Unidade de Negocio / 2=Usuario do CRM / 3=Equipe
Local cNomeMemb 	:= ""										//Nome do membro
Local cCodVenRes	:= ""										//Codigo do vendedor dono/responsavel
Local cNomVenRes	:= ""										//Nome do vendedor dono/responsavel
Local aExecAuto		:= {}

Default cEntidade	:= ""	//Alias da entidade 
Default cChavePesq 	:= ""	//Chave da entidade (codigo+loja)
Default cTipoVld	:= "S"	//Tipo de validacao S=Simulacao / G=Gravacao
Default lVldAcao	:= .T.	//Indica a validacao da acao
Default cCodAcao	:= ""	//Codigo da acao

Private lMsErroAuto	:= .F.

//Valida preenchimento da entidade
If	!Empty(cEntidade) .And. !Empty(cChavePesq)


	//Posiciona na entidade informada
	dbSelectArea(cEntidade)
	dbSetOrder(1)
	If	dbSeek(xFilial(cEntidade)+cChavePesq)

		Do Case
			Case	cEntidade == "SA1"

					cProcess	:= "MATA030"		//Rotina
					cCpoCODTER 	:= "A1_CODTER"	//Codigo do Territorio
					cCpoTPMEMB 	:= "A1_TPMEMB"	//Tipo do Membro
					cCpoCODMEMB	:= "A1_CODMEMB"	//Codigo do Membro
					cCpoCODVEND	:= "A1_VEND"		//Codigo do vendedor
					
			Case	cEntidade == "SUS"

					cProcess	:= "TMKA260"		//Rotina
					cCpoCODTER 	:= "US_CODTER"	//Codigo do Territorio
					cCpoTPMEMB 	:= "US_TPMEMB"	//Tipo do Membro
					cCpoCODMEMB	:= "US_CODMEMB"	//Codigo do Membro
					cCpoCODVEND	:= "US_VEND"		//Codigo do vendedor					
					
			Case	cEntidade == "ACH"

					cProcess	:= "TMKA341"		//Rotina 
					cCpoCODTER 	:= "ACH_CODTER"	//Codigo do Territorio
					cCpoTPMEMB 	:= "ACH_TPMEM"	//Tipo do Membro
					cCpoCODMEMB	:= "ACH_CODMEM"	//Codigo do Membro
					cCpoCODVEND	:= "ACH_VEND"		//Codigo do vendedor					
					
		EndCase
		
	Else
		MsgAlert(STR0254,STR0252)	//"Entidade não encontrada!"###"Validação de Território"
	Endif

	//Quando simulacao apresenta territorio da entidade 
	If	cTipoVld == "S" .AND. !Empty(&cCpoCODTER)

		cCodTer	:= &cCpoCODTER 
		cNomeMTER	:= Posicione("AOY",1,xFilial("AOY")+cCodTer,"AOY_NMTER")
		cCodMemb	:= &cCpoCODMEMB
		cTipMemb	:= RetX3Combo(cCpoTPMEMB, &cCpoTPMEMB)
		cNomeMemb	:= CRMA640Gat(&cCpoTPMEMB, cCodMemb)
		cCodVenRes	:= &cCpoCODVEND
		
		If	!Empty(cCodVenRes)	
			cNomVenRes := Alltrim(Posicione("SA3",1,xFilial("SA3")+cCodVenRes,"A3_NOME"))
		Endif

		MsgInfo(STR0255+cCodTer+CHR(13)+CHR(10)+STR0256+cNomeMTER+CHR(13)+CHR(10)+STR0257+cCodMemb+CHR(13)+CHR(10)+STR0258+cNomeMemb+CHR(13)+CHR(10)+STR0259+cTipMemb+CHR(13)+CHR(10)+STR0262+cCodVenRes+CHR(13)+CHR(10)+STR0263+cNomVenRes,STR0260)	//"Código do Território: "###"Nome do Território: "###"Código do Membro: "###"Nome do Membro:"###"Tipo do Membro: "###"Código do Vendedor:"###"Nome do Vendedor:"###"Entidade distribuía para:"
		
	Endif

	//Aplica validacao na acao para saber se ela valida distribuicao/rodizio	
	If	lVldAcao .AND. !Empty(cCodAcao) 
		lVldTerrit := TK271AplVt(cCodAcao)
	Endif

	//Realiza Simulacao do territorio (tanto na SIMULACAO / GRAVACAO)
	If lVldTerrit
		aRet := CRMA690EvalTerritory(cProcess,cEntidade,.T.,.F.)
		If ValType(aRet) != "A"
			aRet := {.F.}
		EndIf
	ENDIF

	//Distribui a conta para o territorio e realiza rodizio
	If	aRet[1] .AND. cTipoVld <> "S" .AND. lVldTerrit
			
		aTerritory 	:= CRMA690CasterTerritory()	
		aRet 			:= {aTerritory[1]}
			
		If aRet[1]
		
			If cEntidade == "ACH"
				aExecAuto := {	{"ACH_CODIGO",Left(cChavePesq, Len(ACH->ACH_CODIGO)),Nil},;
								{"ACH_LOJA"	,Subs(cChavePesq, Len(ACH->ACH_CODIGO) + 1, Len(ACH->ACH_LOJA)),Nil},;
								{"ACH_CODTER",aTerritory[2],Nil},;
								{"ACH_TPMEM",aTerritory[3],Nil},;
								{"ACH_CODMEM",aTerritory[4],Nil},;
								{"ACH_VEND",aTerritory[5],Nil} }

				TMKA341(aExecAuto,4)
				
			//Prospects
			ElseIf cEntidade == "SUS"
				aExecAuto := {	{"US_COD",Left(cChavePesq, Len(SUS->US_COD)),Nil},;
								{"US_LOJA",Subs(cChavePesq, Len(SUS->US_COD) + 1, Len(SUS->US_LOJA)),Nil},;
								{"US_CODTER",aTerritory[2],Nil},;
								{"US_TPMEMB",aTerritory[3],Nil},;
								{"US_CODMEMB",aTerritory[4],Nil},;
								{"US_VEND",aTerritory[5],Nil} }
				
				TMKA260(aExecAuto,4)
			//Clientes
			Else
				aExecAuto := { {"A1_COD",Left(cChavePesq, Len(SA1->A1_COD)),Nil},;
							{"A1_LOJA",Subs(cChavePesq, Len(SA1->A1_COD) + 1, Len(SA1->A1_LOJA)),Nil},;
							{"A1_CODTER",aTerritory[2]	,Nil},;
							{"A1_TPMEMB",aTerritory[3]	,Nil},;
							{"A1_CODMEMB",aTerritory[4]	,Nil},;
							{"A1_VEND",aTerritory[5]	,Nil} }
				
				MATA030(aExecAuto,4)
			EndIf
		
			If lMsErroAuto
				MostraErro()	
			EndIf
		
		EndIf
			
	Endif

	lRet := aRet[1] .And. !lMsErroAuto
	
Else
	MsgAlert(STR0253,STR0252)	//"Entidade não informada no atendimento!"###"Validação de Território"
EndIf

RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TK271AplVt
Verifica se a acao escolhida aplica validacao de territorio  

@param cAcao, character, Codigo da acao. 
@return lRetorno, logico, verdadeiro/falso, aplica ou não validacao 
@author  Eduardo Gomes Junior 
@version P12
@since   237/09/2015  
/*/
//-------------------------------------------------------------------
Function TK271AplVt(cAcao)

Local aArea		:=	GetArea()
Local lRetorno 	:= .F.
Local cAplVt 		:= ""

cAplVt := Posicione("SUQ",1,xFilial("SUQ") + cAcao, "UQ_AVLTER")

If	cAplVt == "1"
	lRetorno := .T.
EndIf

RestArea(aARea)
Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetX3Combo
Retorna descricao do X3_CBOX  

@param cCampo, character, Campo para ser pesquisado no SX3 
@param cConteudo, character, Conteudo do campo pesquisado
@return cCaption, character, Descricao conforme X3_CBOX 
@author  Eduardo Gomes Junior 
@version P12
@since   23/09/2015  
/*/
//-------------------------------------------------------------------
Static Function RetX3Combo(cCampo, cConteudo)

Local cCaption	:= ""
Local aSx3Box   	:= RetSx3Box(Posicione("SX3", 2, cCampo, "X3CBox()"),,, 1)
Local nPos			:= AScan(aSx3Box, {|aBox| aBox[2] == cConteudo})

If	nPos > 0
	cCaption := AllTrim(aSx3Box[nPos][3])
Endif

Return(cCaption)


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
