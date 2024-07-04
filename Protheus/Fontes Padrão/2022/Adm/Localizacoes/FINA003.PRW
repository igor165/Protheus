#INCLUDE "FINA003.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA003  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao do cadastro de gestores financeiros.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA003()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA003()

Private aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0001	//"Cadastro de Gestores Financeiros"

dbSelectArea("FRP")
mBrowse( 6, 1,22,75,"FRP")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina	:= {	{ STR0002,"AxPesqui"				, 0 , 1, 0, .F.},;	//"Pesquisar"
						{ STR0003,"FA003MAN"				, 0 , 2, 0, nil},;	//"Visualizar"
						{ STR0004,"FA003MAN"				, 0 , 3, 0, nil},;	//"Incluir"
						{ STR0005,"FA003MAN"				, 0 , 4, 0, nil},;	//"Alterar"
						{ STR0006,"FA003MAN"				, 0 , 5, 3, nil},;	//"Excluir"
						{ STR0007,"FA003CONSULTA"			, 0 , 6, 3, nil} }	//"Consulta Lim."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FA003MNU")
	ExecBlock("FA003MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003MAN  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada pelo aRotina, opcoes Visualizar, Incluir,  ³±±
±±³			 ³Alterar e Excluir.  										  ³±±
±±³			 ³Responsavel pela manutencao de cadastro, atraves da montagem³±±
±±³			 ³da tela, das chamadas as funcoes de validacoes dos dados    ³±±
±±³			 ³e da chamada da funcao que grava, altera e exclui registros ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003MAN(cAlias,nReg,nOpc)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- String: Alias da Tabela corrente ("FRP")		  ³±±
±±³			 ³nReg		- Numeric: Nro do registro posicionado.			  ³±±
±±³			 ³nOpc		- Numeric: Opcao de manipulacao de dados 		  ³±±
±±³			 ³			2 - Visualizar 		  							  ³±±
±±³			 ³			3 - Incluir 		  							  ³±±
±±³			 ³			4 - Alterar 		  							  ³±±
±±³			 ³			5 - Excluir 		  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA003MAN( cAlias, nReg, nOpc, lAutomato )

Local cNoEditFLD	:= "FRP_COD|FRP_NOME|FRP_USER|FRP_MOEDA"
Local lEnchBar		:= .t.
Local lPreVld		:= .t.
Local nOpcA			:= 0
Local oDlg
Local oEnch
Local aSizeAut 		:= {}
Local aPosEnch		:= {}
Local aFields		:= FA003GetFields(cAlias)
Local aEditFld		:= Iif(nOpc == 3, aClone(aFields),{})
Local aButtons		:= {}
Local aUsButtons    := {}
Local aAreaFRP		:= {}
Local bTudoOk 		:= {|| Iif(Obrigatorio(oEnch:aGets,oEnch:aTela), nOpcA := 1 ,nOpcA := 0), if(nOpcA==1,odlg:End(),nOpcA) }

Local nLimOrig		:= 0
Default lAutomato	:= .F.  //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.
aAreaFRP := FRP->(GetArea())

lPreVld := fa003PreValid(nOpc)

If lPreVld
	If ExistBlock("FA003PVD")
		lPreVld := ExecBlock("FA003PVD",.f.,.f.,{nOpc})
	Endif
Endif

If !lPreVld
	Return()
Endif

If ExistBlock("FA003BTN")
	If ValType( aUsButtons := ExecBlock( "FA003BTN", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
Endif

If nOpc == 4
	aEval(aFields,{|x| Iif(!(alltrim(x)$cNoEditFLD),aAdd(aEditFld,x),nil)})
Endif

RegToMemory( cAlias, ( nOpc == 3 ), .T., .T. )

nLimOrig := M->FRP_LIMITE
aSizeAut := MsAdvSize(lEnchBar)

DEFINE MSDIALOG oDlg TITLE STR0001 FROM aSizeAut[7],aSizeAut[2] TO aSizeAut[6],aSizeAut[5] PIXEL OF oMainWnd //"Cadastro de Gestores Financeiros"

	oEnch := MsMGet():New(cAlias,nReg,nOpc,,,STR0001,aFields,,aEditFld,,,,,oDlg,,,.F.) //"Cadastro de Gestores Financeiros"
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
IF !lAutomato // Tratamiento para scripts automatizados
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bTudoOk) },{||oDlg:End(), nOpcA := 0},,aButtons) CENTERED
Else
      nOpcA  := 1
Endif
If nOpcA == 1
	RestArea(aAreaFRP)
	Begin Transaction
		FA003GRV(nOpc,nLimOrig,lAutomato)
		ConfirmSx8()
	End Transaction
Else
	RestArea(aAreaFRP)
	RollbackSX8()
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003CONSULTA³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta as movimentacoes de fundo fixo para o gestor 		 ³±±
±±³			 ³posicionado de acordo com a moeda. E exigida a parametrizacao  ³±±
±±³			 ³para data de referencia de consulta.						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003CONSULTA()											     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                       	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									    				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN													     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA003CONSULTA()

Local aList		:= {}

If Pergunte("FA003SLD",.t.)

	aList := fXAlcSld(FRP->FRP_MOEDA,mv_par01,FRP->FRP_COD,.t.)

	If aList <> nil
		FA003SetScreen(aList)
	Endif

Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003SetScreen³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela de consulta as movimentacoes do saldo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003SetScreen(aDados)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aDados	- Array: Array com as movimentacoes      	          ³±±
±±³			 ³	aDados[n,1]-> Char: Sequencia de lancamento do saldo	      ³±±
±±³			 ³	aDados[n,2]-> Char: Tipo de Movimentacao        		      ³±±
±±³			 ³				1) Saldo Inicial         			              ³±±
±±³          ³				2) Aprovacao 		    			              ³±±
±±³          ³				3) Estorno de Aprovacao				              ³±±
±±³          ³				4) Aporte	 		   				              ³±±
±±³          ³				5) Estorno de Aporte 		    			      ³±±
±±³			 ³	aDados[n,3]-> Date: Data de Movimentacao       			      ³±±
±±³			 ³	aDados[n,4]-> Numeric: Saldo da movimentacao	  		   	  ³±±															      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil.									    				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA003SetScreen(aDados)

Local oDlg
Local oGrpHeader
Local oGrpList
Local oList
Local oSayGestor
Local oSayNome
Local oSaySaldo
Local oSayMoeda
Local oGetGestor
Local oGetNome
Local oGetSaldo

Local cGetGestor:= FRP->FRP_COD
Local cGetNome	:= Eval({||DbselectArea("FRP"),UsrFullName(FRP->FRP_USER)})
Local cSimbMoeda 	:= FA003RetSimb(FRP->FRP_MOEDA)
Local cMoeda		:= FA003RetMoeda(FRP->FRP_MOEDA)
Local cPromptM	:= STR0008 + PadL(FRP->FRP_MOEDA,2) + " - " + Alltrim(cSimbMoeda) + " " + Alltrim(cMoeda) //"Moeda "

Local nGetSaldo	:= fxAlcSldFim(aDados)


DEFINE MSDIALOG oDlg TITLE STR0009 FROM 000, 000  TO 475, 500 COLORS 0, 16777215 PIXEL //"Consulta ao Saldo do Fundo Fixo"

@ 011, 001 GROUP oGrpHeader TO 067, 245 OF oDlg COLOR 0, 16777215 PIXEL

@ 017, 010 SAY oSayGestor PROMPT STR0010 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL //"Gestor"
@ 017, 039 MSGET oGetGestor VAR cGetGestor WHEN .F. SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 017, 110 SAY oSayNome PROMPT STR0011 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL //"Nome"
@ 017, 130 MSGET oGetNome VAR cGetNome WHEN .F. SIZE 110, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 035, 010 SAY oSaySaldo PROMPT STR0012 + dtoc(mv_par01) SIZE 065, 007 OF oDlg COLORS 0, 16777215 PIXEL //"Saldo na data "
@ 035, 110 SAY oSayMoeda PROMPT  cPromptM SIZE 130, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 050, 010 MSGET oGetSaldo VAR nGetSaldo WHEN .f. Picture PesqPict("FRT","FRT_SALDO") SIZE 090, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 069, 001 GROUP oGrpList TO 232, 245 OF oDlg COLOR 0, 16777215 PIXEL

@ 074, 003 ListBox oList Fields  HEADER STR0013,STR0014,STR0015,STR0016 SIZE 240, 152 OF oDlg COLORS 0, 16777215 PIXEL //"Sequencia","Tipo de Movimento","Data","Saldo"

	oList:SetArray(aDados)
	oList:bLine := {|| {	aDados[oList:nAT,01],;
							fa003TipoMov(aDados[oList:nAT,02]),;
							aDados[oList:nAT,03],;
							Transform(aDados[oList:nAT,04],PesqPict("FRT","FRT_SALDO")) }}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()}) CENTERED

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fa003TipoMov  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para a captacao da descricao do tipo de movimento do     ³±±
±±³			 ³fundo fixo    												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fa003TipoMov(cTipoMov)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipoMov	- String: Cod. Tipo de movimentacao				      ³±±
±±³          ³				1 - Saldo Inicial							      ³±±
±±³          ³				2 - Aprovacao							      	  ³±±
±±³          ³				3 - Estorno da Aprovacao						  ³±±
±±³          ³				4 - Aporte									      ³±±
±±³          ³				1 - estorno do aporte						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cMovimento	- String: Descricao do tipo de movimento.	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa003TipoMov(cTipoMov)

Local cMovimento := ""

Do Case
	Case Alltrim(cTipoMov) == "1"
		cMovimento := STR0017	//"Saldo Inicial"
	Case Alltrim(cTipoMov) == "2"
		cMovimento := STR0018	//"Aprovação"
	Case Alltrim(cTipoMov) == "3"
		cMovimento := STR0019	//"Estorno de Aprovação"
	Case Alltrim(cTipoMov) == "4"
		cMovimento := STR0020	//"Aporte"
	Case Alltrim(cTipoMov) == "5"
		cMovimento := STR0021	//"Estorno de Aporte"
End Case

Return(cMovimento)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003GetFields³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Campos que sao utilizados na enchoice.					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003GetFields(cAlias)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- String: Alias da tabela						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aFields	- Array: Campos da tabela FRP.    				      ³±±
±±³			 ³	aFields[n]	- String: Nome do campo						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA003GetFields(cAlias)

Local aFields	:= {}
Local aAreaSX3	:= SX3->(Getarea())

SX3->(dbSetOrder(1))

If SX3->(DbSeek(cAlias))
	While SX3->(!EOF()) .and. Alltrim(cAlias) == alltrim(SX3->X3_ARQUIVO)

		If !(SX3->X3_CAMPO $ "FRP_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
			aAdd(aFields,SX3->X3_CAMPO)
		Endif

		SX3->(DbSkip())
	EndDo
Endif

RestArea(aAreaSX3)

Return(aFields)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fa003PreValid	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se o registro podera ser excluido.					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fa003PreValid(nOpcao)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao	- Numeric: Opcao de manipulacao de dados de aRotina   ³±±
±±³          ³				3 - Inclusao    								  ³±±
±±³          ³				4 - Alteracao    								  ³±±
±±³          ³				5 - Exclusao    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna se a opcao e valida ou nao.		      ³±±
±±³			 ³					.t. - opcao valida						      ³±±
±±³			 ³					.f. - opcao nao valida					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa003PreValid(nOpcao)

Local cChave2	:= ""
Local cNomeApr  := ""

Local lRet 		:= .t.
Local lSeek		:= .f.

Local aSaldo	:= {}
Local aAreaFRR	:= FRR->(GetArea())

If nOpcao == 5

    cChave2 := xFilial("FRR") + Padr(FRP->FRP_USER,TamSX3("FRR_USER")[1]) + PadR(FRP->FRP_MOEDA,TamSX3("FRR_MOEDA")[1])

	FRR->(DbSetOrder(2))

	lSeek := FRR->(DbSeek(cChave2))

	If !lSeek

	    //Para se retornar as movimentacoes de todo o periodo ate a data atual, nao deve informar a data no parametro 2 da funcao abaixo.
	    //Como ha uma necessidade de checar se ha movimentacoes para este aprovador, diferente de saldo inicial, omiti o parametro data.
		aSaldo := fXAlcSld(FRP->FRP_MOEDA,,FRP->FRP_COD)
		cNomeApr := FWGetUserName(FRP->FRP_USER)

		If FXALCCHKTP(aSaldo,"2|3|4|5")	//CHECA SE EXISTE MOVIMENTACAO PARA OS TIPOS DE SALDO PARAMETRIZADOS
			lRet := .f.
			Help(" ",1,"fa003PreValidA",,STR0022 + cNomeApr + STR0023,1,0) //"O Aprovador "#" possui movimentações além do SALDO INICIAL. Efetue o bloqueio deste aprovador."
		Endif
	Else
		Help(" ",1,"fa003PreValidB",,STR0024 + Alltrim(FRR->FRR_COD) + " - " + Alltrim(FRR->FRR_DESC) + STR0025,1,0) //"Este gestor esta associado ao grupo de gestores "#". Altere o vínculo no cadastro de grupo de gestores."
		lRet := .f.
	Endif
Endif

RestArea(aAreaFRR)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003TUDOK	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida todo o formulario.									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003TUDOK(nOpcao)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao	- Numeric: Opcao de manipulacao de dados de aRotina   ³±±
±±³          ³				3 - Inclusao    								  ³±±
±±³          ³				4 - Alteracao    								  ³±±
±±³          ³				5 - Exclusao    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna se a opcao e valida ou nao.		      ³±±
±±³			 ³					.t. - opcao valida						      ³±±
±±³			 ³					.f. - opcao nao valida					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA003TUDOK(nOpcao)

Local lRet	:= .t.

Local nI	:= 0

Local aAreaSX3	:= SX3->(GetArea())
Local aAreaFRP	:= FRP->(GetArea())

If nOpcao == 3 .or. nOpcao == 4
	For nI := 1 to FRP->(FCOUNT())
		SX3->(DBsetOrder(2))
		If SX3->(dbSeek(FRP->(FieldName(nI))))

			If !Empty(SX3->X3_VALID)
				lRet := &(SX3->X3_VALID)
			Endif

			If lRet
				If !Empty(SX3->X3_VLDUSER)
					lRet := &(SX3->X3_VLDUSER)
					If !lRet
						Exit
					Endif
				Endif
			Else
				Exit
			Endif
		Endif
	Next nI

	If lRet
		If ExistBlock("FA003VOK")
			lRet := ExecBlock("FA003VOK",.f.,.f.,{nOpcao})
		EndIf
	Endif
Endif

RestArea(aAreaSx3)
RestArea(aAreaFRP)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003GRV		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de atualizacao do arquivo FRP.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003GRV(nOpcao,nLimOrig)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao	- Numeric: Opcao de manipulacao de dados de aRotina   ³±±
±±³          ³				3 - Inclusao    								  ³±±
±±³          ³				4 - Alteracao    								  ³±±
±±³          ³				5 - Exclusao    								  ³±±
±±³          ³nLimOrig	- Numeric: Valor do Limite Original, antes de qualquer³±±
±±³          ³				alteracao (somente nOpcao == 4) 			 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil.														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA003GRV(nOpcao,nLimOrig, lAutomato)

Local nI 		:= 0

Local lExcFRT	:= .f.
Local lGRavou	:= .f.

Default nLimOrig	:= 0
Default lAutomato	:= .F.  //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.

M->FRP_FILIAL := xFilial("FRP")

   If lAutomato
      If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
         aRetAuto  := GetParAuto("FINA003TESTCASE")
         M->FRP_USER 	:= aRetAuto[1]
        If nOpcao == 3 
         IF UsrExist(M->FRP_USER) .AND. F003ExistUsr( M->FRP_USER, M->FRP_MOEDA )
         	M->FRP_NOME    := UsrFullName(M->FRP_USER)
         Endif
        Endif
         M->FRP_MOEDA 	:= aRetAuto[2]
         M->FRP_LIMITE 	:= aRetAuto[3]        
     Endif
   Endif

If nOpcao == 3 .or. nOpcao == 4
   
	Reclock("FRP",nOpcao == 3)

		For nI := 1 to FRP->(FCOUNT())
			FRP->&(FRP->(FIELDNAME(nI))) := M->&(FRP->(FIELDNAME(nI)))
		Next nI

	FRP->(MsUnlock())

	lGravou := .t.

	If nOpcao == 3 .or. (nOpcao == 4 .and. nLimOrig <> M->FRP_LIMITE)
		lGravou := FXALCGrava(M->FRP_USER,M->FRP_COD,FRP->FRP_MOEDA,"1",dDatabase,M->FRP_LIMITE)
	Endif
Elseif nOpcao == 5

	If ExistBlock("FA003DEL")
		lGravou := ExecBlock("FA003DEL",.f.,.f.)
	Else
		lGravou := .t.
	Endif

	If lGravou

		lExcFRT := FXALCExclui(M->FRP_USER,M->FRP_COD,FRP->FRP_MOEDA,{"1"},dDataBase)

		If lExcFRT
			Reclock("FRP",.F.)
				FRP->(DbDelete())
			FRP->(MsUnlock())
		Else
			lGravou := .f.
		Endif

	Endif
Endif

If lGravou
	If nOpcao == 3 .or. nOpcao == 4
		If ExistBlock("FA3GRVIA")
			ExecBlock("FA3GRVIA",.f.,.f.,{nOpcao})
		Endif
	Endif
Endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003RetSimb	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para a captacao do simbolo da moeda selecionada.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003RetSimb(cMoeda)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMoeda	- String: Codigo da moeda.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRetMoeda	- String: Simbolo da Moeda.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA003RetSimb(cMoeda)

Local cRetMoeda	:= ""

Local aAreaSX6	:= SX6->(Getarea())

SX6->(dbSetOrder(1))

If SX6->(dbSeek(xFilial("SX6") + "MV_SIMB" + alltrim(cMoeda)))
	cRetMoeda := SX6->&("MV_SIMB" + alltrim(cMoeda))
Else
	If Len(cMoeda)	> 1 .and. "0" $ cMoeda
		If SX6->(DbSeek(xFilial("SX6") + "MV_SIMB" + Substr(cMoeda,2)))
			cRetMoeda := SX6->&("MV_SIMB" + Substr(cMoeda,2))
		Endif
	Endif
Endif

RestArea(aAreaSX6)

Return(cRetMoeda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003RetMoeda	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para a captacao da descricao da moeda selecionada.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003RetMoeda(cMoeda)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMoeda	- String: Codigo da moeda.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRetMoeda	- String: Descricao da Moeda.					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA003RetMoeda(cMoeda)

Local cRetMoeda	:= ""

Local aAreaSX6	:= SX6->(Getarea())

SX6->(dbSetOrder(1))

If SX6->(dbSeek(xFilial("SX6") + "MV_MOEDA" + alltrim(cMoeda)))
	cRetMoeda := SX6->&("MV_MOEDA" + alltrim(cMoeda))
Else
	If Len(cMoeda)	> 1 .and. "0" $ cMoeda
		If SX6->(DbSeek(xFilial("SX6") + "MV_MOEDA" + Substr(cMoeda,2)))
			cRetMoeda := SX6->&("MV_MOEDA" + Substr(cMoeda,2))
		Endif
	Endif
Endif

RestArea(aAreaSX6)
Return(cRetMoeda)

/*
==============================================
FUNCOES DE VALIDACOES DOS CAMPOS DA TABELA FRP
==============================================
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F003ExistUsr	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se o usuario e moeda ja nao foram cadastrados.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³F003ExistUsr(cCodUsr,cMoeda)								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodUsr	- String: Codigo do Usuario						   	  ³±±
±±³          ³cMoeda	- String: Codigo da Moeda							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna se existe, invalidando o usuario e.	  ³±±
±±³			 ³					moeda.										  ³±±
±±³			 ³					.t. - usuario e moeda validos			      ³±±
±±³			 ³					.f. - usuario e moeda invalidos			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Tabela FRP, validacoes de campos (X3_VALID)		              ³±±
±±³			 ³	- FRP_USER 													  ³±±
±±³			 ³	- FRP_MOEDA													  ³±±
±±³			 ³	- FRP_LIMITE    	          			  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F003ExistUsr(cCodUsr,cMoeda)

Local lRet	:= .t.

Local aFRP	:= {}

Local cChave2 := Padr(xFilial("FRP"),TamSx3("FRP_FILIAL")[1])+;
					PadR(cCodUsr,TamSx3("FRP_USER")[1])+;
					PadR(cMoeda,TamSX3("FRP_MOEDA")[1])

aFRP := GetAdvfVal("FRP",{"FRP_USER","FRP_MOEDA"},cChave2,2,{"",""})

If !Empty(aFRP[1]) .and. !Empty(aFRP[2])
	Help(" ",1,"F003ExistUsr",,STR0026,1,0) //"O Usuário e a moeda selecionados já estão cadastrados."
	lRet := .f.
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA003VLGES	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacoes para o codigo do gestor digitado.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA003VLGES(cAlias,cMoeda)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- String: Alias da tabela (FRP ou FRR)			   	  ³±±
±±³          ³cMoeda	- String: Codigo da Moeda							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna a validacao.	  						  ³±±
±±³			 ³					moeda.										  ³±±
±±³			 ³					.t. - codigo de gestor validado			      ³±±
±±³			 ³					.f. - codigo de gestor invalidado		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Tabela FRP, validacoes de campos (X3_VALID)		              ³±±
±±³			 ³	- FRP_CODSUP												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FA003VLGES(cAlias,cMoedaPar)

Local lRet	:= .t.

Local aFRP	:= {}

Local cChave1	:= ""
Local cReadVar	:= ""
Local cMoeda	:= ""

Default cAlias := "FRP"
Default cMoedaPar := "01"

If Valtype(cMoedaPar) == "C"
	If len(alltrim(cMoedaPar)) < 2
		cMoeda := StrZero(Val(cMoedaPar),TamSx3("FRP_MOEDA")[1])
	Else
		cMoeda := cMoedaPar
	Endif
Else
	cMoeda := StrZero(cMoedaPar,TamSX3("FRP_MOEDA")[1])
Endif
//cMoeda := Strzero(cValtoChar(cMoedaPar),TamSX3("FRP_MOEDA")[1])

Do Case
	Case Alltrim(Upper(cAlias)) == "FRP"
		cReadVar := "M->FRP_CODSUP"
	Case Alltrim(Upper(cAlias)) == "FRR"
		cReadVar := "M->FRR_CODGES"
End Case

If !Empty(&(cReadVar)) .AND. !Empty(cMoeda)
	cChave1 := xFilial(cAlias) + PadR(&(cReadVar),TamSX3(substr(cReadVar,4))[1]) + PadR(cMoeda,TAMSX3(subStr(cReadVar,4))[1])

	aFRP := FRP->( GetAdvfVal( "FRP", {"FRP_COD","FRP_MOEDA","FRP_USER"}, cChave1, 1, {"","",""} ) )

	If Empty(aFRP[1]) .OR. Empty(aFRP[2]) .OR. Empty(aFRP[3])
		Help(" ",1,"FA003VLGESA",,STR0027,1,0)	//"O gestor financeiro e a moeda selecionada não condizem um com o outro."
		lRet := .f.
	Endif

	If lRet .AND. Alltrim(Upper(cAlias)) == "FRP"
		If Alltrim(M->FRP_USER) == Alltrim(aFRP[3])
			Help(" ",1,"FA003VLGESB",,STR0028 + Alltrim(M->FRP_NOME),1,0) //"O Gestor superior não pode ser o mesmo que o usuário selecionado: "
			lRet := .f.
		Endif

		If lRet

			lRet := Fa003InGrp(aFRP[3],M->FRP_USER,M->FRP_MOEDA)

			If !lRet
				Help(" ",1,"FA003VLGESC",,STR0029,1,0)	//"O Gestor Superior precisa estar vinculado ao mesmo grupo de gestores."
			Endif

		Endif
	Elseif lRet .and. Alltrim(Upper(cAlias)) == "FRR"
		If Alltrim(M->FRR_MOEDA) <> Alltrim(aFRP[2])
			Help(" ",1,"FA003VLGESD",,STR0030 + alltrim(M->FRR_MOEDA),1,0)	//"Escolha somente gestores que foram cadastrados para a moeda definida "
			lRet := .f.
		Endif
	Endif

Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa003InGrp	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao .		   								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Fa003InGrp(cGesSupUsr,cGesUsr,cMoeda)						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao	- Numeric: Opcao de manipulacao de dados de aRotina   ³±±
±±³          ³				3 - Inclusao    								  ³±±
±±³          ³				4 - Alteracao    								  ³±±
±±³          ³				5 - Exclusao    								  ³±±
±±³          ³oGetDados	- Objeto: Instancia de MsNewGetDados				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil.														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FA003VLGES(cAlias,cMoeda)						                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa003InGrp(cGesSupUsr,cGesUsr,cMoeda)

Local lRet			:= .t.

Local cQry			:= ""


#IFNDEF TOP
	Help(" ",1,"Fa003InGrpTOP",,STR0031,1,0)	//"Não foi possível validar se o superior pertence ao mesmo grupo de gestores. É necessário possuir DBACCESS. Contacte o administrador."
	Return(.t.)
#ENDIF

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	FRR.FRR_COD  " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	"+RetSQLName("FRR") + " FRR " + chr(13) + chr(10)
cQry += "INNER JOIN  " + chr(13) + chr(10)
cQry += "	(	SELECT " + chr(13) + chr(10)
cQry += "			FRR2.FRR_COD " + chr(13) + chr(10)
cQry += "		FROM " + chr(13) + chr(10)
cQry += "			" + RetSQLName("FRR") + " FRR2 " + chr(13) + chr(10)
cQry += "		WHERE " + chr(13) + chr(10)
cQry += "			FRR2.FRR_FILIAL = '"+xfilial("FRR")+"' " + chr(13) + chr(10)
cQry += "			AND " + chr(13) + chr(10)
cQry += "			FRR2.FRR_USER = '"+cGesSupUsr+"' " + chr(13) + chr(10)
cQry += "			AND " + chr(13) + chr(10)
cQry += "			FRR2.FRR_MOEDA = '"+cMoeda+"' " + chr(13) + chr(10)
cQry += "			AND " + chr(13) + chr(10)
cQry += "			FRR2.D_E_L_E_T_ = ' ') OTHER_FRR " + chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)
cQry += "	OTHER_FRR.FRR_COD = FRR.FRR_COD " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	FRR.FRR_FILIAL =  '"+xfilial("FRR")+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRR.FRR_USER = '"+cGesUsr+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRR.FRR_MOEDA = '"+cMoeda+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	FRR.D_E_L_E_T_ = ' ' "

If Select("TRBFRR") > 0
	TRBFRR->(DbCloseArea())
Endif

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBFRR", .T., .F.)

TRBFRR->(DbGoTop())

If TRBFRR->(Eof())
	lRet := .f.
Endif

TRBFRR->(DbCloseArea())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f003ChkVal³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacoes dos campos de limites (FRP_LIMMIN, FRR_LIMMAX e  ³±±
±±³			 ³FRP_LIMITE)		  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³f003ChkVal()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna se moeda existe.    				  ³±±
±±³			 ³		.t. - existe										  ³±±
±±³			 ³		.f. - nao existe									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Tabela FRP, validacoes de campos (X3_VALID)	              ³±±
±±³			 ³	- FRP_LIMMAX 											  ³±±
±±³			 ³	- FRP_LIMMIN											  ³±±
±±³			 ³	- FRP_LIMITE              			  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f003ChkVal()

Local lRet      := .T.

If Alltrim(Upper(ReadVar())) == "M->FRP_LIMITE"
	If M->FRP_LIMITE <= 0
		lRet := .f.
		Help(" ",1,"f003ChkValA",,STR0032,1,0) //"O valor de Limite definido deve ser superior a 0."
	Endif
Endif

If Alltrim(Upper(ReadVar())) == "M->FRP_LIMMIN"
	If M->FRP_LIMMIN < 0
		lRet := .f.
		Help(" ",1,"f003ChkValB",,STR0033,1,0) //"Limite mínimo não pode ser negativo."
	Endif
Elseif Alltrim(Upper(ReadVar())) == "M->FRP_LIMMAX"
	If M->FRP_LIMMAX < 0
		lRet := .f.
		Help(" ",1,"f003ChkValC",,STR0034,1,0)	//"Limite máximo não pode ser negativo."
	Endif
Endif

If lRet
	If ( !Empty( M->FRP_LIMMIN ) .And. !Empty( M->FRP_LIMMAX ) .And. ( M->FRP_LIMMIN > M->FRP_LIMMAX ) )
		Help(" ",1,"f003ChkValD",,STR0035,1,0)	//"O valor máximo não pode ser menor que o valor mínimo."
		lRet := .F.
	Endif
Endif

Return(lRet)
