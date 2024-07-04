#INCLUDE "TMKA350.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TMKDEF.CH"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³																						 ³
³   BOTOES DA SUPERIOR     								aCfgBtn - Array	   			     ³
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
³	17 - OK                                                 17                           ³ 
³	18 - CANCELA                                            18                           ³  
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³																						 ³
³   BOTOES DA LATERAL 																	 ³
³																						 ³
³	01 - Encerramento										19							 ³
³	02 - Chamado Tecnico									20							 ³
³	03 - Ligacoes Pendentes									21							 ³	
³	04 - Cadastro do Produto                                22              	         ³ 
³	05-  Cadastro de Concorrentes                           23                           ³    
³	06 - Cadastro de Acessorios								24							 ³
³	07 - Condicoes de Pagamento								25					 		 ³
³	08 - Vendedor                                           26                           ³ 
³	09 - Pedido                                             27                           ³ 
³	10 - Rastreamento                                       28                           ³ 
³	11 - Lotes                                              29                           ³ 
³   12 - Sub-Lotes                                          30                           ³ 
³   13 - Vendas Lojas                                       31                           ³ 
³   14 - Bonus                                              32                           ³ 
³	15 - Consulta TEF                                       33                           ³ 
³																						 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA350   ºAutor  ³Armando M. Tessaroliº Data ³  14/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a tela do atendimento de Telecobranca               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Fernando  |14/12/06| 9.12 ³Bops 115431 Alterado a array aRotina  para  ³±±
±±³        	 ³        |      ³criação do menu funcional            	      ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA350()

Local cTipoAte	:= TkGetTipoAte()		// Folders do atendimento
Local lRet		:= .F.					// Variavel de retorno logico

Local aCores3    := {	{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 1)",	"BR_AZUL"		},;		// Atendimento
   						{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 2)",	"BR_VERDE"		},;		// Cobranca
   						{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 3)",	"BR_VERMELHO"	},;		// Encerrado
   						{"(!EMPTY(ACF->ACF_CCANC))",								"BR_CINZA"		}} 		// Cancelado

Private cCadastro := STR0001 //"Atendimento"
Private aRotina   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite a abertura simultanea para o modelo MDI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExcProcess("TMK" + __cUserId)
	Help("  ",1,"TMKPROMDI")
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o tratamento para garantir a exclusividade na rotina de atualizacao do SK1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExcProcess("TMKSK1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o USUARIO nao estiver cadastrado em OPERADORES e nao tiver    ³
//³um Grupo de Atendimento (SU0) associado ou se o Operador nao 	³
//³tiver acesso a rotina de Telecobranca ou Todas - nao entra nessa ³
//³rotina                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !TMKOPERADOR()
	Help("  ",1,"OPERADOR")
	Return(lRet)
Else     
	If	VAL(TkGetTipoAte()) == TELEVENDAS		.OR.;
		VAL(TkGetTipoAte()) == TELEMARKETING	.OR.;
		VAL(TkGetTipoAte()) == TMKTLV
		Help("  ",1,"TK280ACTLC")
		Return(lRet)
	Endif
EndIf	

// Verifica se o Operador possui regra de selecao e de negociacao.
If Empty(TkPosto(TkOperador(),"U0_REGSEL")) .OR. Empty(TkPosto(TkOperador(),"U0_REGNEG"))
	Help("  ",1,"TK280REGRA")
	Return(lRet)
Endif

// Verifica se o Operador realiza atendimento RECEPTIVO
If TkPosto(TkOperador(),"U0_BOUND") == "2"		// Ativa
	Help("  ",1,"TK280ATEND")
	Return(lRet)
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o array com os precos da ultima tabela de preco usada - ³
//³Caso haja atualizacao da tabela de preco por outro Remote     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaReleTabPrc()


// Abre somente o atendimento de Telecobranca
TkGetTipoAte("3")

aRotina	:= MenuDef()
MBrowse(,,,,"ACF",,,,,,aCores3)

// Restaura as condicoes normais
TkGetTipoAte(cTipoAte)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³11/12/06  ³±±
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

Local aRotina:= {	{ STR0002  ,"AxPesqui"        ,0 ,1 , , .F. },;		//"Pesquisar"
					{ STR0003  ,"TK271CallCenter" ,0 ,2 , , .T. },;		//"Visualizar"
					{ STR0004  ,"TK271CallCenter" ,0 ,3 , , .T. },;		//"Incluir"
			   		{ STR0005  ,"TK271CallCenter" ,0 ,4 , , .T. },;		//"Alterar"
					{ STR0006  ,"TK271Legenda"	  ,0 ,2 , , .T. } }		//"Legenda"

				

							                                                     				
Return(ARotina)



