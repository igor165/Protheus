#INCLUDE "PCOA170.ch"
#INCLUDE "PROTHEUS.CH"
#include "pcoicons.ch"
/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA170  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de manutecao da consulta gerencial do PCO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA170                                                      ³±±
±±³_DESCRI_  ³ Programa de manutecao da consulta gerencial                  ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo : PCOA170(2) - Executa a chamada da funcao de visua- ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA170(nCallOpcx)

PRIVATE cCadastro	:= STR0001 //"Visao Gerencial Orcamentaria"
Private aRotina := MenuDef()						
Private nRecAKN
Private M->AKR_ORCAME := Padr(" ", Len(AKR->AKR_ORCAME))

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		PCO170DLG("AKN",AKN->(RecNo()),nCallOpcx,,,)
	Else
		mBrowse(6,1,22,75,"AKN")
	EndIf
EndIf

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO170DLG³ Autor ³ Paulo Carnelossi       ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da DIALOG de manutencao da consulta     ³±±
±±³          ³ gerencial.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO170DLG(cAlias,nReg,nOpcx)

Local oDlg

Local cArquivo		:= CriaTrab(,.F.)
Local cFiltro 		:= ".T."

Local lOk
Local l170Inclui	:= .F.
Local l170Visual	:= .F.
Local l170Altera	:= .F.
Local l170Exclui	:= .F.
Local lContinua		:= .T.

Local aButtons		:= {}
Local aUsrButons	:= {}
Local aMenu			:= {}

Local nX			:= 0
Local nDirAcesso 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l170Visual := .T.
	Case (aRotina[nOpcx][4] == 3)
		l170Inclui	:= .T.
	Case (aRotina[nOpcx][4] == 4)
		l170Altera	:= .T.
	Case (aRotina[nOpcx][4] == 5)
		lOk			:= .F.
		l170Exclui	:= .T.
		l170Visual	:= .T.
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza a funcao axInclui para incluir a visao gerencial  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l170Inclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario na EnchoiceBar                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1702" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios na      ³
		//P_E³ enchoicebar da telade cadastro de orcamentos                           ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo os botoes a serem adicionados na enchoice  ³
		//P_E³               Ex. :  User Function PCOA1702                            ³
		//P_E³                      Return {{PEDIDO",{||U_TESTE()},"Teste"}}          ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsButtons := ExecBlock( "PCOA1702", .F., .F. ) ) == "A"
			AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
		EndIf
	EndIf
	
	If AxInclui(cAlias,nReg,nOpcx,,,,"A170ChkCfg()",,"PCO170Atu()",aButtons) <> 1
		lContinua := .F.
	Else
	   //se incluiu registro normalmente
	   dbSelectArea("AKN")
	   dbGoto(nRecAKN)  //variavel nRecAKN foi atribuida na function PCO170Atu()

	   //Posicionar tb em AKO - contas orcamentarias da planilha
	   dbSelectArea("AKO")
	   dbSetOrder(1)
	   //conta orcamentaria raiz recebe o mesmo codigo do orcamento
	   dbSeek(xFilial("AKO")+AKN->AKN_CODIGO+AKN->AKN_CODIGO)
	   
	   dbSelectArea("AKN")
	   
	EndIf
EndIf

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lContinua := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0011,STR0013,{STR0014},2)//"Atencao"###"Usuario sem acesso a esta configuração de visao gerencial. "###"Fechar"
		lContinua := .F.
	ElseIf nDirAcesso  == 1 //somente visualizacao
		If nOpcx == 4 .OR. nOpcx == 5  //se for opcao exclusao da planilha bloqueia o acesso
			Aviso(STR0011,STR0013,{STR0014},2)//"Atencao"###"Usuario sem acesso a esta configuração de visao gerencial. "###"Fechar"
			lContinua := .F.
		EndIf
	Else
	    lContinua := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ExecBlock para inclusao de botoes customizados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PCOA1703")
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ³
	//P_E³ tela da planilha orcamentaria                                          ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na planilha ³
	//P_E³              [1] : Titulo                                              ³
	//P_E³              [2] : Codeblock contendo a funcao do usuario              ³
	//P_E³              [3] : Resource utilizado no bitmap                        ³
	//P_E³              [4] : Tooltip do bitmap                                   ³
	//P_E³              Exemplo :                                                 ³
	//P_E³              User Function PCOXFUN1                                    ³
	//P_E³              Return {{"Titulo", {|| U_Botao() }, "BPMSDOC","Titulo" }} ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aUsrButons := ExecBlock("PCOA1703",.F.,.F.)
	For nx := 1 to Len(aUsrButons)
		aAdd(aMenu,{aUsrButons[nx,1],aUsrButons[nx,2],aUsrButons[nx,3],aUsrButons[nx,4]})
	Next
EndIf

If lContinua
	If !l170Visual
		MENU oMenu POPUP
			MENUITEM STR0007 ACTION (Pco170to171(2,cArquivo),Eval(bRefresh)) //"Visualizar C.O.G."
			MENUITEM STR0008 ACTION (Pco170to171(3,cArquivo),Eval(bRefresh)) //"Incluir C.O.G."
			MENUITEM STR0009 ACTION (Pco170to171(4,cArquivo),Eval(bRefresh)) //"Alterar C.O.G."
			MENUITEM STR0010 ACTION (Pco170to171(5,cArquivo),Eval(bRefresh)) //"Excluir C.O.G."
		ENDMENU
	Else
		MENU oMenu POPUP
			MENUITEM STR0007 ACTION (Pco170to171(2,cArquivo),Eval(bRefresh)) //"Visualizar C.O.G."
		ENDMENU
	EndIf
	aMenu := {	{TIP_PESQUISAR,		{|| PcoAKNPesq(cArquivo) }, BMP_PESQUISAR, TOOL_PESQUISAR},;
				{TIP_ORC_ESTRUTURA,	{|| PCO170Menu(@oMenu,l170Visual,cArquivo),oMenu:Activate(140,45,oDlg) },BMP_ORC_ESTRUTURA,TOOL_ORC_ESTRUTURA}}

	PCOAKNPLAN(STR0001,,cArquivo,@lOk,aMenu,@oDlg,,,l170Visual,cFiltro) //"Visao Gerencial Orcamentaria"
	
	If lOk <> Nil .And. lOk .And. l170Exclui
		A170Exclui()
	EndIf

EndIf

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO170ATU³ Autor ³Paulo Carnelossi        ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de chamada da rotina de atualiacao das tabelas relacio³±±
±±³          ³ nadas a consulta gerencial orcamentaria.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO170ATU()

nRecAKN := Recno()
PcoAvalAKN("AKN",1)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO170Menu³ Autor ³ Paulo Carnelossi      ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de controle do menu de atualizacoes.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO170Menu(oMenu,lVisual,cArquivo)
Local aArea		:= GetArea()
Local cAlias	
Local nRecView	

cAlias	:= (cArquivo)->ALIAS
nRecView	:= (cArquivo)->RECNO
dbSelectArea(cAlias)
dbGoto(nRecView)

If !lVisual
	Do Case 
		Case cAlias == "AKO" .And. AKO->AKO_NIVEL == "001"
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Disable()
		Case cAlias == "AKO" 
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
		Otherwise
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
	EndCase
   
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO170to171³ Autor ³ Paulo Carnelossi     ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de chamada do PCOA171 para atualizacao do Conta Orc Ger³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA170                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO170to171(nOpc,cArquivo)

Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ExecBlock para inclusao de botoes customizados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PCOA1704")
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para validacao da rotina chamada no menu    ³
	//P_E³ Estrutura no programa de atualizacao da planilha orcamentaria.         ³
	//P_E³ Parametros : [1] - Numerico - Opcao selecionada                        ³
	//P_E³ Retorno    : Logico - Permite ou na a utilizacao da opcao selecionada. ³
	//P_E³              Exemplo :                                                 ³
	//P_E³              User Function PCOA1704                                    ³
	//P_E³              Local lRet := .F.                                         ³
	//P_E³              If ParamIXB[1] == 1                                       ³	
	//P_E³                 lRet := .T.                                            ³	
	//P_E³              EndIf                                                     ³	
	//P_E³              Return lRet                                               ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExecBlock("PCOA1704", .F., .F., {nOpc})
		RestArea(aArea)
		Return
	EndIf
EndIf

cAlias := (cArquivo)->ALIAS
nRecAlias := (cArquivo)->RECNO

dbSelectArea(cAlias)
dbGoto(nRecAlias)
Do Case
	Case nOpc == 2
		PCOA171(2,,"000")
	Case nOpc == 3
		aGetCpos := {	{"AKO_CODIGO",AKO->AKO_CODIGO,.F.},;
						{"AKO_COPAI",AKO->AKO_CO,.F.}}

		nRecAKO	:= PCOA171(3,aGetCpos,AKO->AKO_NIVEL)
	Case nOpc == 4 
		PCOA171(4,,"000")
	Case nOpc == 5
	    If PadR(AKO_CODIGO, Len(AKO_CO))!=PadR(AKO_CO, Len(AKO_CO))
			PCOA171(5,,"000")
		EndIf	
EndCase

RestArea(aArea)
Return	

Static Function A170Exclui()
Local cVisGer := AKN->AKN_CODIGO
Local aArea   := GetArea()

//exclui a ITENS da conta orcamentaria
dbSelectArea("AKP")
dbSetOrder(1)

Begin Transaction

While dbSeek(xFilial("AKP")+cVisGer)
	RecLock("AKP",.F.,.T.)
	dbDelete()
	MsUnlock()
End

//exclui contas orcamentaria da planilha
dbSelectArea("AKO")
dbSetOrder(1)

While dbSeek(xFilial("AKO")+cVisGer)
	RecLock("AKO",.F.,.T.)
	dbDelete()
	MsUnlock()
End

//exclui contas orcamentaria da planilha
dbSelectArea("AKN")
dbSetOrder(1)

While dbSeek(xFilial("AKN")+cVisGer)
	RecLock("AKN",.F.,.T.)
	dbDelete()
	MsUnlock()
End

End Transaction

RestArea( aArea )

Return

Function A170ChkCfg()
Local lRet := .T.
If Alltrim(M->AKN_CONFIG) == "002"
	Aviso(STR0011, STR0012, {"Ok"}) //"Atencao"###"Configuracao de parametros reservado para simulacoes por inclusao/movimento !"
	lRet := .F.
EndIf
Return(lRet)		


Static Function MenuDef()
PRIVATE aRotina 	:= {	{ STR0002,		"AxPesqui"  , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"PCO170DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"PCO170DLG" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"PCO170DLG" , 0 , 4},; //"Alterar"
							{ STR0006, 		"PCO170DLG" , 0 , 5}} //"Excluir"
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no Browse                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1701" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de orcamentos                                           ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOPE001                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1701", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)