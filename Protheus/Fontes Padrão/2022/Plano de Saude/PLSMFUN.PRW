#INCLUDE "plsmfun.ch"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "fileio.ch"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

STATIC aDadUsr   		:= {}
STATIC aDadRda   		:= {}
STATIC aDadGen   		:= {}
STATIC __aTipTab 		:= {}
STATIC cChaveTab 		:= "SAUDE"//chave das tabelas que serao geradas
STATIC cPath     		:= "\TabelasBanco\"//diretorio aonde as tabelas serao geradas
STATIC cSenhaGer 		:= "SAUDETAB201003"//senha de geracao do arquivo MZP
STATIC cDirRaiz  		:= "\TabelasBaseDemoSAUDE\"//caminho no servidor que serao descompactadas as tabelas
STATIC cArqMZIP  		:= "SAUDEPROTHEUS.MZP"//nome do arquivo MZP
STATIC aBuffer	 		:= {}

STATIC __MV_PLSCDCO		:= ''
STATIC __MV_PLSTPCO		:= ''
STATIC __PLSISCON		:= existBlock("PLSISCON")

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"

// variavel lgpd
Static objCENFUNLGP := CENFUNLGP():New()

#define __aCdCri032 {"540",STR0001} //"Erro controlado SIGAPLS."
#define __aCdCri095 {"541",STR0002} //"Operador do sistema nao habilitado a acessar o usuario."
#define __aCdCri180 {"09G",STR0207} //"Não existe Vigência Ativa para esta rede de atendimento para a operadora informada"
#define __aCdCri500 {"011",STR0255} //"O produto do beneficiario nao atende a esta cidade ou estado, verifique a area de abrangencia do plano."
#define __aCdCri09S {"09S",STR0241} //"Quantidade de dias permitido para execução da guia foi ultrapassado"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSPOSCONT ³ Autor ³ Tulio Cesar       Data ³ 08.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Posiciona tabelas default em relacao ao contratos.        ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     Advanced Protheus 5.08                                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cMatric    -> Matricula da Familia                        ±±
±±³         lHelp      -> Exibir help ou nao caso haja NC             ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPOSCont(cMatric,lHelp)
	DEFAULT lHelp   := .F.

	//Posiciona na Familia...
	BA3->(DbSetOrder(1))
	If ! BA3->(MsSeek(xFilial("BA3")+Subs(cMatric,1,14)))
		If lHelp
			Help("",1,"PLSPOSC01")
		Endif
		Return(.F.)
	Endif

	//Posiciona no produto da familia...

	BI3->(DbSetOrder(1))

	If ! BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODPLA+BA3_VERSAO)))

		If lHelp
			Help("",1,"PLSPOSC02")
		Endif

		Return(.F.)
	Endif

	//Posiciona na forma de pagamento da familia...

	BJ3->(DbSetOrder(1))

	If ! BJ3->(MsSeek(xFilial("BJ3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)+BA3->BA3_FORPAG))
		If lHelp
			Help("",1,"PLSPOSC03")
		Endif
		Return(.F.)
	Endif

	//Agora busco a forma de pagamento do contrato...

	BJ1->(DbSetOrder(1))

	If ! BJ1->(MsSeek(xFilial("BJ1")+BA3->BA3_FORPAG))
		If lHelp
			Help("",1,"PLSPOSC04")
		Endif
		Return(.F.)
	Endif

	//Todos os arquivos foram posicionados...

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSDIFANOS ³ Autor ³ Tulio Cesar       Data ³ 08.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Retorna a quantidades de meses ou anos entre dois meses/anos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     Advanced Protheus 5.08                                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cAnoIni    -> Ano Inicial                                 ±±
±±³         cMesIni    -> Mes Inicial                                 ±±
±±³         cAnoFin    -> Ano Final                                   ±±
±±³         cMesFin    -> Mes Final                                   ±±
±±³         cModelo    -> (M) retorna a quantidade de meses           ±±
±±³                       (A) retorna a quantidade de anos            ±±
±±ÀÄÄÄ ÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSDIFANOS(cAnoIni,cMesini,cAnoFim,cMesFim,cModelo)

	LOCAL nAnos   := Val(cAnoFim)-Val(cAnoIni)
	LOCAL nMeses  := Val(cMesFim)-Val(cMesIni)
	LOCAL nRes

	If     nMeses > 0
		nRes    := (nAnos*12)+nMeses
	ElseIf nMeses < 0
		nRes    := (nAnos*12)-ABS(nMeses)
	ElseIf nMeses == 0
		nRes    := nAnos*12
	Endif

Return(IF(cModelo=="M",nRes,nRes/12))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSSTRMES  ³ Autor ³ Tulio Cesar       Data ³ 08.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Retorna o Mes de uma expressao data.                      ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     Advanced Protheus 5.08                                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ dData      -> Data                                        ±±
±±ÀÄÄ ÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSSTRMES(dData)
Return(subs(dtos(dData),5,2))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSSTRANO  ³ Autor ³ Tulio Cesar       Data ³ 08.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Retorna a Ano de uma expressao data.                      ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     Advanced Protheus 5.08                                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ dData      -> Data                                        ±±
±±³         lAno2000   -> True -> 4 Digitos | False 2 Digitos         ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSSTRANO(dData,lAno2000)

	Default lAno2000 := .F.

	If ! lAno2000
		cRet := subs(dtos(dData),3,2)
	Else
		cRet := subs(dtos(dData),1,4)
	Endif

Return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSVALCOB  ³ Autor ³ Tulio Cesar       Data ³ 08.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Busca o Valor de Cobranca                                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     Advanced Protheus 5.08                                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cMatric    -> Matricula do Usuario                        ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVerCob()
	LOCAL cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
	LOCAL cAno
	LOCAL cMes
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Busca dados dos parametros pelo usuario...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Pergunte("PLSCOB",.T.)
		Return
	Endif

	cAno       := mv_par01
	cMes       := mv_par02
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Executa funcao de cobranca...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PLSVLRCOB(cMatric,cAno,cMes,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Fim da Rotina...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PlsCabItem³Autor  ³ Eduardo Motta            Data ³ 18.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Funcao para geracao de MODELO 3 com VIS/INC/ALT/EXC           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PlsCabItem(cAlias1,cTitulo,cAlias2,nOrdem2,cChav2,cCond2,aChavCab)³±±
±±³ cAlias1  ³Alias do cabecalho                                            ±±
±±³ cTitulo  ³Titulo da Janela                                              ±±
±±³ uAlias2  ³Alias dos itens do cabecalho                                  ±±
±±³ uOrdem2  ³Numero da ordem do arquivo de cabecalho                       ±±
±±³ cChav2   ³Chave com o conteudo do cabecalho a pesquisar nos itens       ±±
±±³ uCond2   ³String contendo as variaveis a comparar com o cChav2          ±±
±±³ aChavCab ³Array contendo os campos e variaveis do cabecalho a gravar no item³±±
±±³bLDblClick³Code block com evento a executar quando se der double click na GD ³±±
±±³bSaidaDlg ³Code block contendo funcao a executar na saida do dialogo     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
OBS: Quando for uma enchoice para varias getdados a estrutura de algumas variaveis mudam:
uAlias2 - array - [1]-Alias [2]-Descricao do Folder [3]-Code block com evento gotfocus [4]-code block evento lostfocus [5]-bFilter [6]-Menu
uOrdem2 - array - Ordem de cada alias referenciado no uAlias2
uCond2  - array - Condicao para cada alias referenciado no uAlias2s

Exemplo:
Ver Fonte: PLSA350.PRW (Exemplo com varias GetDados e controle de GOTFOCUS e LOSTFOCUS)
           PLSA380.PRW (Exemplo simples, com 1 enchoice e 1 getdados)


/*/
Function PlsCabItem(cAlias1,cTitulo,uAlias2,uOrdem2,uChav2,cCond2,aChavCab,bLDblClick,bSaidaDlg,xAutoCab,xAutoItens,xOpcAuto,nReg,bAfterUpt,bFunDel,aButtons,bInit,lForce,lReadOnly,lRotAux,aRotAux,lSemaforo)
	LOCAL  cFiltro   := ""
	Local nI			:= 1

	Private aRotina := {} //PLSMnDefY(lRotAux, cAlias1, aRotAux, lReadOnly)

	Private cCadastro  := cTitulo
	Private uAliasItem := uAlias2

	Private uOrdemItem := uOrdem2
	Private uKeyItem   := uChav2
	Private cCondItem  := cCond2
	Private aKeyCab    := aChavCab
	Private bDoubleCli := bLDblClick
	Private bExitDlg   := bSaidaDlg
	Private lFolder    := (Valtype(uAlias2)=="A")   // se o conteudo de uAlias2 for array e' porque tem varias itens para o mesmo cabecalho
	Private lRotAuto   := (xAutoCab<>Nil)
	Private aAutoCab   := xAutoCab
	Private aAutoItens := xAutoItens
	Private nOpcAuto   := xOpcAuto
	PRIVATE xAfterUpt  := bAfterUpt
	PRIVATE xbFunDel   := bFunDel
	PRIVATE xaButtons  := {}
	DEFAULT aButtons   := {}
	Private bInitDlg   := bInit
	Private lForceGRV  := lForce
	PRIVATE xSemaforo  := lSemaforo

	DEFAULT bFunDel := { || .T. }
	DEFAULT lForce  := .F.
	DEFAULT lSemaforo	:= .F.
	Default lRotAux := .F.
	DEFAULT lReadOnly := .F.
	DEFAULT aRotAux    := {}

	aRotina := PLSMnDefY(lRotAux, cAlias1, aRotAux, lReadOnly)
	xaButtons := aClone(aButtons)

	If ! lRotAuto
		If ExistBlock('PLSMFIL')
			cFiltro:= Execblock('PLSMFIL',.F.,.F.,{cAlias1})
		Endif
		If Val(GetVersao(.F.)) >= 12 //Valida versão 12
			mBrowse(026,001,022,075,cAlias1,,,,,,,,,,,,,,cFiltro)
		Else
			mBrowse(006,001,022,075,cAlias1,,,,,,,,,,,,,,cFiltro)
		Endif
	Else
		DbSelectArea(cAlias1)
		If nOpcAuto == K_Alterar .Or. nOpcAuto == K_Excluir
			DbGoTo(nReg)
		Endif

		MsRotAuto(nOpcAuto,aAutoCab,cAlias1)
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³ MntPlsCI ³Autor  ³ Eduardo Motta            Data ³ 18.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Funcao para manutencao da MODELO 3 gerada pela PlsCabItem     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³MntPlsCI(cAlias,nReg,nOpc)                                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MntCabItem                                                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MntPlsCI(cAlias,nReg,nOpc)
	LOCAL I__f := 0
	LOCAL aPosObj   := {}
	LOCAL aObjects  := {}
	LOCAL aSize     := {}
	LOCAL aInfo     := {}
	Local aDifSize:= {,,,,35,3,,}//array com dimenções para correção de telas na versão 12

	LOCAL aPages	:= {}, aTitles:= {}
	LOCAL nOpca	 	:= 0
	LOCAL oDlg
	LOCAL nFolder 	:= If(lFolder,len(uAliasItem),0)
	LOCAL nI 		:= 1
	LOCAL nJ      	:= 1
	LOCAL aAux
	LOCAL oFolder
	LOCAL bFilter
	LOCAL aBotao	:= {}
	LOCAL bOKAuto 	:= { || nOpca := 1 }
	LOCAL cVldLine
	LOCAL cVldDel
	LOCAL _nH			:= nil
	Local aArea	:= GetArea()
	LOCAL lIniPad := Type("nIniPad") <> "U"

	//Define Variaveis para GetDados...

	PRIVATE nOpcx    := nOpc
	PRIVATE aObjGD   := {}
	PRIVATE oGetDados
	PRIVATE aHeader  := {}
	PRIVATE aCols    := {}
	PRIVATE aChave   := {}
	PRIVATE aVetTrab := {}
	PRIVATE aHeadF   := {}
	PRIVATE aColsF   := {}
	PRIVATE aColsAut := {}

	//Define Variaveis para Enchoice...

	PRIVATE oEnchoice
	PRIVATE aTELA[0][0]
	PRIVATE aGETS[0]


	//Se for exclusao testa se pode excluir...

	If nOpc == K_Excluir
		If (!Empty(xbFunDel) .AND. !Eval(xbFunDel))
			Return
		Endif
	Endif

	//Monta aCols e aHeader...

	If ! lRotAuto
		If nOpc == K_Incluir
			Copy cAlias TO Memory Blank
		Else
			Copy cAlias TO MEMORY
		Endif
	Endif

	If lFolder
		aHeadF   := Array(nFolder)
		aColsF   := Array(nFolder)
		aVetTrab := Array(nFolder)
		For nI := 1 to nFolder
			aAux := {}
			Store Header uAliasItem[nI,1] TO aHeadF[nI] For .T.
			If nOpc == K_Incluir
				If lIniPad
					nIniPad := nI
				EndIf
				Store COLS Blank uAliasItem[nI,1] TO aColsF[nI] FROM aHeadF[nI]
			Else
				DbSelectArea(uAliasItem[nI,1])
				DbSetOrder(uOrdemItem[nI])
				If MsSeek(xFilial(uAliasItem[nI,1])+&(uKeyItem[nI]))
					Store COLS uAliasItem[nI,1] TO aColsF[nI] FROM aHeadF[nI] VETTRAB aAux While xFilial(uAliasItem[nI,1]) == &(uAliasItem[nI,1]+"->"+uAliasItem[nI,1]+"_FILIAL") .and. &(cCondItem[nI]) == &(uKeyItem[nI])
					aVetTrab[nI] := aClone(aAux)
				Else
					If lIniPad
						nIniPad := nI
					EndIf
					Store COLS Blank uAliasItem[nI,1] TO aColsF[nI] FROM aHeadF[nI]
				EndIf
			EndIf

			If lRotAuto
				aadd(aColsAut,{})
				If Len(aAutoItens[nI]) > 0
					DbSelectArea(uAliasItem[nI,1])
					For nJ := 1 To Len(aColsF[nI])
						aadd(aColsAut[nJ],MSARRAYXDB(aAutoItens[nI,nJ],nil,nOpcAuto,.T.))
					Next
					xAutoItens := aClone(aAutoItens)
					aAutoItens := aClone(aAutoItens[nI])
					aCols   := aClone(aColsF[nI])
					aHeader := aClone(aHeadF[nI])
					MsAuto2Acols()
					aColsF[nI] := aClone(aCols)
					aHeadF[nI] := aClone(aHeader)
					aAutoItens  := aClone(xAutoItens)
					aColsAut[nI]:= aClone(aCols)
				Else
					aColsAut[nI] := {}
					aColsF[nI]   := {}
				EndIf
			Endif
		Next
		If lRotAuto
			aColsAut := aClone(aColsF )
		Endif
	Else
		Store Header uAliasItem TO aHeadF For .T.
		If nOpc == K_Incluir
			Store COLS Blank uAliasItem TO aColsF FROM aHeadF
		Else
			DbSelectArea(uAliasItem)
			DbSetOrder(uOrdemItem)
			If MsSeek(xFilial(uAliasItem)+&uKeyItem)
				Store COLS uAliasItem TO aColsF FROM aHeadF VETTRAB aVetTrab While xFilial(uAliasItem) == &(uAliasItem+"->"+uAliasItem+"_FILIAL") .and. &cCondItem == &uKeyItem
			Else
				Store COLS Blank uAliasItem TO aColsF FROM aHeadF
			EndIf
		EndIf

		If lRotAuto
			aadd(aColsAut,{})
			If Len(aAutoItens[nI]) > 0
				DbSelectArea(uAliasItem)
				For nJ := 1 To Len(aColsF)
					aadd(aColsAut[1],MSARRAYXDB(aAutoItens[1,nJ],nil,nOpcAuto,.T.))
				Next
				xAutoItens := aClone(aAutoItens)
				aAutoItens := aClone(aAutoItens[1])
				aCols      := aClone(aColsF)
				aHeader    := aClone(aHeadF)
				MsAuto2Acols()
				aColsF     := aClone(aCols)
				aHeadF     := aClone(aHeader)
				aAutoItens := aClone(xAutoItens)
				aColsAut[1]:= aClone(aColsF)
			Else
				aColsAut[1]	:= {}
				aColsF   	:= {}
			EndIf

		Endif
	EndIf

	//Proteção apra caso ele desposicione durante a montagem dos Folders
	//Esse desposicionamento estava impactando a rotina de Usuários do Portal (PLSA226)
	RestArea(aArea)

	aCols   := {}
	aHeader := {}

	For nI := 1 to nFolder
		Aadd(aTitles,uAliasItem[nI,2])
		Aadd(aPages,"HEADER 1")
	Next


	//Define Dialogo...

	If ! lRotAuto

		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )

		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )

		If aArea[1] == "BSW" //O a Grid da tela de usuários do portal estava cortando a parte inferior da Grid
			aSize[6] := aSize[6] + 70
		EndIF

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

		//Monta Enchoice...

		Zero();oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,{aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]},,,,,,oDlg,,,.F.)

		//Monta GetDados...

		If lFolder

			If Val(GetVersao(.F.)) >= 12 //Valida versão 12

				oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,,.T.,.F.,aPosObj[2,4],aPosObj[2,3]/2.3,)
			Else

				oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,,.T.,.F.,aPosObj[2,4],aPosObj[2,3],)
			EndIf

			For nI := 1 to nFolder

				cVldLine 	:= If(ValType(uAliasItem[nI,3])=="C",uAliasItem[nI,3],NIL)
				cVldDel  	:= If(ValType(uAliasItem[nI,4])=="C",uAliasItem[nI,4],NIL)
				bFilter  	:= If(Len(uAliasItem[nI])>=5,uAliasItem[nI,5],NIL)

				aBotao  	:= If(Len(uAliasItem[nI])>=6,aClone(uAliasItem[nI,6]),{})

				if Val(GetVersao(.F.)) >= 12 //Valida versão 12
					oGetDados 	:= TPLSBrw():New(003,003,aPosObj[2][4]-5,(aPosObj[2,3]/2.3) - 20,nil,oFolder:aDialogs[nI],nil,bDoubleCli ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeadF[nI],aColsF[nI],.F.,uAliasItem[nI,1],nOpc,uAliasItem[nI,2],nil,nil,nil,aVetTrab[nI],cVldLine,cVldDel,bFilter,,aBotao,,,,,,,,aDifSize)
				Else
					oGetDados 	:= TPLSBrw():New(003,003,aPosObj[2][4]-5,aPosObj[2][3]/2,nil,oFolder:aDialogs[nI],nil,bDoubleCli ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeadF[nI],aColsF[nI],.F.,uAliasItem[nI,1],nOpc,uAliasItem[nI,2],nil,nil,nil,aVetTrab[nI],cVldLine,cVldDel,bFilter,,aBotao)
				Endif

				If ( Len( uAliasItem[nI] ) >= 7 )
					oGetDados:bGotFocus				:= If(ValType(uAliasItem[nI,7])#"B",{||.t.},uAliasItem[nI,7])
					oGetDados:bLostFocus			:= If( Len( uAliasItem[nI] ) >= 8,If(ValType(uAliasItem[nI,8]) # "B",{||.t.},uAliasItem[nI,8]),{||.t.})
				Else
					oGetDados:bGotFocus				:= If(ValType(uAliasItem[nI,3])#"B",{||.t.},uAliasItem[nI,3])
					oGetDados:bLostFocus			:= If(ValType(uAliasItem[nI,4])#"B",{||.t.},uAliasItem[nI,4])
				EndIf

				If ( Len( uAliasItem[nI] ) >= 9 )
					oGetDados:bBeforeEdit			:= If( ValType(uAliasItem[nI,9])#"B",{||.t.},uAliasItem[nI,9] )
				EndIf
				oGetDados:oBrowse:oBrowse:Cargo	:= AllTrim(Str(nI,10))

				aadd(aObjGD,oGetDados)
			Next
			oFolder:bChange := { |nFolder| nIniPad := nFolder }
		Else

			If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
				aDifSize:= {,,,,35,3,,}
				oGetDados := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil    , bDoubleCli ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeadF,aColsF,.F.,uAliasItem,nOpc,cCadastro,nil,nil,nil,aVetTrab,,,,,,,,,,,,,aDifSize)
			Else
				oGetDados := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil    , bDoubleCli ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeadF,aColsF,.F.,uAliasItem,nOpc,cCadastro,nil,nil,nil,aVetTrab)
			EndIf

			//oGetDados := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil    , bDoubleCli ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeadF,aColsF,.F.,uAliasItem,nOpc,cCadastro,nil,nil,nil,aVetTrab)
			oGetDados:oBrowse:oBrowse:Cargo := "1"
			oGetDados:bGotFocus := {||.t.}
			oGetDados:bLostFocus := {||.t.}
			aadd(aObjGD,oGetDados)
		EndIf

		//Ativa o Dialogo...

		If bInitDlg <> Nil
			Eval(bInitDlg, oDlg, nOpc)
		Endif
		ACTIVATE MSDIALOG oDlg ON INIT (Eval(aObjGD[1]:bGotFocus,aObjGD[1]:oBrowse:oBrowse),Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,PlsEndBrw(),If(oFolder#nil,/*Eval(aObjGd[oFolder:nOption]:bLostFocus,aObjGd[oFolder:nOption] )*/.t.,.t.),IIf(existblock("PLSMNCIVLD"),Execblock("PLSMNCIVLD",.F.,.F.),.T.),If(Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,xaButtons)  }))
	Else
		Eval(bOKAuto)
	Endif

	//Rotina de gravacao dos dados...

	If bExitDlg == NIL  // se nao existir executa procedimento padrao
		If nOpca == K_OK

			// Em alguns casos será necessário o controle de semaforo.
			If xSemaforo
				_nH := PLSAbreSem("PlsCabItem.SMF")
			Endif
			If ValType(xAfterUpt) == "B"
				Eval(xAfterUpt)
			Endif

			BEGIN TRANSACTION
				PLUPTENC(cAlias,nOpc)
				DbSelectArea(cAlias)

				If lFolder
					For nI := 1 to nFolder
						aChave := PlsSepKey(IndexKey(),"+",cAlias,uAliasItem[nI,1],If(aKeyCab#NIL,aKeyCab[nI],NIL))
						If !lRotAuto
							oGetDados := aObjGD[nI]
							oGetDados:Grava(aChave,lForceGRV)
						Else
							If Len(aColsAut[nI]) > 0
								PLUPTCOLS(uAliasItem[nI,1],aColsAut[nI],aHeadF[nI],aVetTrab[nI],nOpcAuto,aChave)
							EndIf
						Endif
					Next
				Else
					aChave := PlsSepKey(IndexKey(),"+",cAlias,uAliasItem,aKeyCab)
					If ! lRotAuto
						oGetDados:Grava(aChave,lForceGRV)
					Else
						If Len(aColsAut[nI]) > 0
							PLUPTCOLS(uAliasItem,aColsAut[1],aHeadF,aVetTrab,nOpcAuto,aChave)
						EndIf
					Endif
				EndIf
			END TRANSACTION
			// Em alguns casos será necessário o controle de semaforo.
			If xSemaforo
				PLSFechaSem(_nH,"PlsCabItem.SMF")
			Endif

			//Ponto de Entrada ao incluir, alterar, excluir e visualizar na rotina PLSA226
			//@author Vinicius Queiros
			//@since 12/09/2019
			//@version P12
			If IsInCallStack("PLSA226")
				If ExistBlock("PL226FIM") // Ponto de entrada
					ExecBlock("PL226FIM", .F., .F.,{nOpcx})
				EndIf
			EndIf

		EndIf
	Else
		// passa parametros para o COD BLOCK
		// 1=Opcao do aRotina
		// 2=Opcao selecionada na enchoice bar (confirmou=1,cancelou=0)
		// 3=array contendo todos os objetos GETDADOS do dialogo
		Eval(bExitDlg,nOpc,nOpca,aObjGD)
	EndIf

	//Fim da Rotina...

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PlsSepKey ³Autor  ³ Eduardo Motta            Data ³ 18.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Funcao que retorna array com as chaves do cabecalho a gravar no   ³±±
±±³      item                                                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PlsSepKey(cString,cSep,cAlias,uAliasItem,aKeyCab)             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PlsSepKey(cString,cSep,cAlias,uAliasItem,aKeyCab)
	LOCAL aRet	:= {}
	LOCAL nI	:= 0
	LOCAL cStr	:= ""
	LOCAL cCar	:= ""
	If aKeyCab == Nil
		cString := StrTran(cString,cAlias+"_",uAliasItem+"_")
		For nI := 1 to Len(cString)
			cCar := SubStr(cString,nI,1)
			cStr+=If(cCar#cSep,cCar,"")
			If cCar == cSep .or. nI == Len(cString)
				If "_FILIAL" $ cStr
					aadd(aRet,{cStr,xFilial(uAliasItem)})
				Else
					aadd(aRet,{cStr,&("M->"+cAlias+SubStr(cStr,4))})
				EndIf
				cStr := ""
			EndIf
		Next
	Else
		For nI := 1 to len(aKeyCab)
			aadd(aRet,{aKeyCab[nI,1],&(aKeyCab[nI,2])})
		Next
	EndIf
Return aRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PlsSeek   ³Autor  ³ Eduardo Motta            Data ³ 04.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Funcao que faz a pesquisa no arquivo verificando se existe, seme- ³±±
±±³      lhante o EXISTCPO, mas deixa posicionado e tambem iguala uma  ±±
±±³      variavel a um campo do arquivo.                               ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PlsSeek(cAlias,nOrd,cKey,cVarDest,cCpoOri)                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias  - Alias a pesquisar                                   ±±
±±³      nOrd    - Ordem a pesquisar, se for omitido se considera a atual  ³±±
±±³      cKey    - Conteudo a pesquisar, se omitido se considera o READVAR ³±±
±±³      cVarDest- Variavel a receber o conteudo do campo              ±±
±±³      cCpoOri- Nome do campo a enviar o seu conteudo a cVarDest     ±±
±±³      lHelp  - Informa se o Help sera mostrado caso o retorno seja .F.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
CODIGO SEMELHANTE AO EXISTCPO com a diferenca que deixa posicionado o arquivo e iguala
uma variavel a determinado campo, foi desenvolvido para facilitar o uso em casos que se precisa,
por exemplo, digitar o CODIGO DO CLIENTE e em outro campo aparecer o NOME, no caso se for feito
com gatilho sao feitos 2 MsSeeks no alias, pois como o ExistCpo nao deixa posicionado e o gatilho
tem que dar outro SEEK.
/*/
Function PlsSeek(cAlias,nOrd,cKey,cVarDest,cCpoOri,lHelp)
	LOCAL aAliasAnt := GetArea()
	LOCAL lRet := .T.
	LOCAL nI
	LOCAL aVarDest := {}
	LOCAL aCpoOri  := {}
	cKey := If(cKey==Nil,&(ReadVar()),cKey)
	lHelp := If(lHelp==NIL,.T.,lHelp)
	DbSelectArea(cAlias)
	If nOrd # Nil
		DbSetOrder(nOrd)
	EndIf
	If !MsSeek(xFilial(cAlias)+cKey)
		If lHelp
			HELP(" ",1,"REGNOIS")
		EndIf
		lRet := .F.
	EndIf
	If cVarDest # NIL .and. cCpoOri # NIL
		aVarDest := SepStr(cVarDest,",")
		aCpoOri  := SepStr(cCpoOri,",")
		For nI := 1 to Len(aVarDest)
			&(aVarDest[nI]) := &(aCpoOri[nI])
		Next
	EndIf

	RestArea(aAliasAnt)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³SepStrAutor  ³ Eduardo Motta            Data ³ 30.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³separa string retornando array de acordo com o delimitador    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³SepStr(cStr,cDelimi)                                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PlsSeek                                                      ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SepStr(cStr,cDelimi)
	LOCAL aRet := {}
	LOCAL nI
	LOCAL cCar
	LOCAL cCampo := ""

	For nI := 1 to Len(cStr)
		cCar := SubStr(cStr,nI,1)
		If cCar == ","
			aadd(aRet,cCampo)
			cCampo := ""
		Else
			cCampo+=cCar
		EndIf
	Next
	aadd(aRet,cCampo)

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PlsFaixaEt³Autor  ³ Eduardo Motta            Data ³ 13.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Retorna a faixa etaria pertencente a idade fornecida.         ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PlsFaixaEt(nIdade)                                            ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nIdade - Idade que se deseja obter a faixa etaria             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsFaixaEt(nIdade)
	LOCAL aArea := sGetArea()
	LOCAL cFaixa
	Private Inclui := .F.
	sGetArea(aArea,"BL9")
	BL9->(DbSetOrder(1))
	BL9->(MsSeek(xFilial()))
	While !BL9->(Eof()) .and. BL9->BL9_FILIAL == xFilial("BL9")
		M->BL9_IDADEI := CriaVar("BL9_IDADEI",.T.)
		If nIdade >= M->BL9_IDADEI .and. nIdade <= BL9->BL9_IDADEF
			cFaixa := BL9->BL9_SEQUEN
			Exit
		EndIf
		BL9->(DbSkip())
	EndDo
	sRestArea(aArea)
Return cFaixa
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PlsIncre  ³Autor  ³ Eduardo Motta            Data ³ 12.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Faz o incremento de um campo em uma GETDADOS                  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsIncre(_cCampo, _oObj , lConDel, cExpCond)
	LOCAL _nTam      := TamSX3(_cCampo)[1]
	LOCAL _cRet      := StrZero(1,_nTam)
	LOCAL _nInd      := 1
	LOCAL _nPos      := 0
	LOCAL _cMaior    := PadL('0', _nTam, '0')
	LOCAL _cAux
	LOCAL _aAux      := {}
	LOCAL _aHeader	 := {}
	LOCAL bCond

	Default lConDel  := .T.
	Default cExpCond := ""

	bCond := "{||" + cExpCond + "}"

	If Type('aCols') == "A"

		If Type('oObj') == "O" .And. ValType(_oObj) <> "O"
			_aAux	:= aClone(oObj:aCols)
			_aHeader := aClone(oObj:aHeader)

		ElseIf ValType(_oObj) <> "O"
			_aAux    := aClone(aCols)
			_aHeader := aClone(aHeader)

		Else
			_aAux	 := aClone(_oObj:aCols)
			_aHeader := aClone(_oObj:aHeader)

		Endif

		_nPos    := PLRETPOS(_cCampo,_aHeader,.F.)

	Endif

	If ( _nPos > 0 )
		For _nInd := 1 To Len(_aAux)
			If Len(_aAux[_nInd])< _nPos .or. ValType(_aAux[_nInd,_nPos])#"C"
				Loop
			EndIf

			// So considera linhas do acols que possuir a coluna a ser incrementada preenchida.
			// Acols com filtro geram linhas vazias e estas linhas estão quebrando a sequencia da forma como foi implementada.
			If Empty(_aAux[_nInd,_nPos])
				Loop
			Endif

			//Verifica se atende condicao passada como parametro
			If !Empty(cExpCond) .And. ! Eval(&bCond)
				Loop
			EndIf

			_cAux := _aAux[_nInd,_nPos]
			If _cAux > _cMaior .And. (Len(_aAux[_nInd])#Len(_aHeader)+1 .or. ! _aAux[_nInd,Len(_aHeader)+1] .or. !lConDel)
				_cMaior := _cAux
			EndIf
		Next
		_cRet   := PadL(Soma1(_cMaior), _nTam,'0')
	Endif

Return(_cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSSQLCOLS³Autor  ³ Tulio e Eduardo          Data ³ 24.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Monta expressao SQL para utilizacao da STORE COLS             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PLSMGER.CH COMANDO STORE COLS TOPCONN                        ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSSQLCols(aHeader,aCols,cAlias,cWhere,aVetTrab)
	LOCAL cSQL
	LOCAL nI
	LOCAL aArea        := GetArea()
	PRIVATE lPlsSQLCls := .T.
	PRIVATE Inclui     := .F.
	DEFAULT aVetTrab   := {}

	#IFDEF TOP

		aVetor := {}
		SX3->(DbSetOrder(2))
		cSQL := "SELECT "
		For nI := 1 To Len(aHeader)
			If aHeader[nI,10] <> "V"
				cSQL += aHeader[nI,2]+","
			Else
				SX3->(MsSeek(aHeader[nI,2]))
				If "PLSPOSIC" $ SX3->X3_RELACAO
					aadd(aVetor,&(AllTrim(SX3->X3_RELACAO)))

					cSQL += aVetor[Len(aVetor),4]+" "+aVetor[Len(aVetor),7]+","
				Endif
			Endif
		Next

		cSQL := Subs(cSQL,1,Len(cSQL)-1)

		cSQL += " FROM "+RetSQLName(cAlias)+" "+cAlias

		For nI := 1 To Len(aVetor)
			cSQL += ", "+RetSQLName(aVetor[nI,1])+" "+aVetor[nI,1]
		Next

		cSQL += " WHERE "+cWhere+" AND "+cAlias+".D_E_L_E_T_ = ' ' "

		For nI := 1 To Len(aVetor)
			cSQL += " AND "+aVetor[nI,3]+ " = "+aVetor[nI,5]+" AND "+aVetor[nI,1]+".D_E_L_E_T_ = ''"
		Next

		cSQL += " ORDER BY "+&(cAlias)->(IndexKey())

		cSQL := PLSAvaSQL(cSQL)
		TCQUERY cSQL New ALIAS "TrbCols"

		DbSelectArea("TrbCols")

		DBEval({|| AaDd(aCols,{}),aEval(aHeader,{|eH|;
			AaDd(aCols[len(aCols)],If(Empty(FieldPos(AllTrim(eH [2 ]))),CriaVar(AllTrim(eH [2 ])),FieldGet(FieldPos(AllTrim(eH [2])))))}),;
			AaDd(aCols[len(aCols)],.f.), If(ValType(aVetTrab)=="A",aadd(aVetTrab,Recno()),nil) },nil, nil,nil, nil, nil)

		TrbCols->(DbCloseArea())
		RestArea(aArea)

	#ELSE
		PLSRelTop()
	#ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSPOSIC  ºAutor  ³Tulio Cesar         º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Posicine do PLS                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSPOSIC(cAlias,nOrdem,cChavePes,cConteud,cChaveOri,cAliasPos,cCampo)
	LOCAL cRet
	LOCAL cSQLExp
	LOCAL cTypeRet

	If Type("lPlsSQLCls") = "L" .And. lPlsSQLCls
		cTypeRet := "A"
	Else
		cRet    := Posicione(cAlias,nOrdem,xFilial(cAlias)+&(cAliasPos+"->("+cChavePes+")"),cConteud)
		cTypeRet := "E"
	Endif

Return(IF(cTypeRet=="A",{cAlias,nOrdem,cChavePes,cConteud,cChaveOri,cAliasPos,cCampo},cRet))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSAbreSemºAutor  ³Tulio Cesar         º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Abre arquivo solicitado                                    º±±
±±º                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function PLSAbreSem(cFile,lTenta)
	local uRet 	:= 1
	local lOk 	:= .f.

	default lTenta 	:= .t.

	while !( lOk := lockByName(cFile,.t.,.f.) )

		if ! lTenta
			exit
		endIf

		// Espera < 1/4 de segundo
		sleep(200)

		// Se alguem derrubar a thread pelo Monitor do Protheus OU
		// mandar o serviço do protheus "baixar", a funcao retorna .T.
		// e a gente sai do looping com uma ocorrencia de erro
		if killApp()
			userException( "*** Processo Interrompido em PLSAbreSem : Semaforo [" + cFile + "] ***" )
		endIf

	endDo

	if lOk
		uRet := 1
	else
		uRet := 0
	endIf

return uRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSFechaSem ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Fecha arquivo                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function PLSFechaSem(nH,cFile)
	default cFile := ""

	if nH > 0
		// Libera Lock
		unLockByName(cFile)
	else

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Erro ao fechar semaforo! Semaforo nao foi aberto - ' + cFile , 0, 0, {})

	endIf

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSAltEnc   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Verifica estrutura de um determinado alias                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function PLSAltEnc(cAlias, aStruc, nPosFil, cVarErro)
	local aAltered	:= {}
	local nI		:= 0
	local lRet   	:= .t.
	local cField	:= ""
	local cType		:= ""
	Default aStruc:={}

	for nI := 1 to len(aStruc)

		if nI == nPosFil
			loop
		endIf

		cField 	:= allTrim( aStruc[nI,1] )
		cType	:= valType( M->&(cField) )

		if cType <> "U"

			if aStruc[nI,2] == 'M' .and. cType != 'C'
				cVarErro := "Nao conformidade PLSGRV Campo " + cField
			elseIf aStruc[nI,2] != 'M' .and. cType != aStruc[nI,2]
				cVarErro := "Nao conformidade PLSGRV Campo " + cField
			else

				if &( cField ) != M->&(cField)
					aadd(aAltered, aStruc[nI])
				endIf

			endIf

		else
			cVarErro := "Nao conformidade PLSGRV Campo " + cField
		endIf

		if ! empty(cVarErro)
			lRet := .f.
			exit
		endIf

	next

	if lRet

		if len(aAltered) == 0

			lRet := .f.

		elseIf len(aAltered) > 0

			aStruc 	 := aClone(aAltered)
			nPosFil  := aScan(aStruc,{ |x|  at('_FILIAL',upper(x[1]) ) > 0 } )

			aAltered := aSize(aAltered, 0)
			aAltered := nil

		endIf

	endIf

return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PlsProcTDE ³ Autor ³ Michele Tatagiba Data ³ 23.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Edita itens da TDE                                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsProcTDE(aHeadTDE,aColsTDE,aVetTDE,nOpc,bScan,bFilter,cAlias,aVet,cValida,cCodOpc,cCodTab)
	Local oDlg
	Local nPos        := 1
	Local nI,nJ,nInd
	Local nOpca       := 0
	Local oScroll
	Local oBtnBaca
	Local nTamCols
	Private oGet
	Private aHeader   := aClone(aHeadTDE)
	Private aCols     := aClone(aColsTDE)
	Private aVetConf  := aClone(aVet)
	Private lCarTDE   := .F.
	Private lConfirma := .F.
	//DEFAULT lValida   := .F.

	If Len(aVetConf) == 0
		aadd(aVetConf,{cCodOpc,cCodTab,lConfirma})
		nPos := 1
	Else
		nPos := ascan(aVetConf,{|x| x[1]==cCodOpc .and. x[2]==cCodTab } )
		If nPos == 0
			aadd(aVetConf,{cCodOpc,cCodTab,lConfirma})
			nPos := Len(aVetConf)
		Endif
	Endif

	If !aVetConf[nPos,3] .And. (nOpc == K_Incluir .Or. (nOpc == K_Alterar .And. aScan(aCols,bScan)==0))

		lCarTDE  := .T.
		nTamCols := Len(aCols)

		DbSelectArea("BD4")
		BD4->(DbSetOrder(2))
		If BD4->(MsSeek(xFilial("BD4")+cCodOpc+cCodInt+cCodTab))

			If Len(aCols) == 0
				nJ := 1
			Else
				nJ := Len(aCols)+1
			Endif

			While xFilial("BD4") == BD4->BD4_FILIAL .and. cCodInt+cCodTab == BD4->BD4_CODTAB .and. cCodOpc == BD4->BD4_CODPRO

				If nTamCols < nJ
					aadd(aCols,{})
					nTamCols := Len(aCols)
					nInd     := 1

					For nInd :=  1 To Len(aHeader)+1
						aadd(aCols[nTamCols],nInd)
						If nInd <= Len(aHeader)
							aCols[nTamCols,nInd] := CriaVar(aHeader[nInd,2])
							If Subs(aHeader[nInd,2],5,6) == "DESCRI"
								aCols[nJ,nInd] := Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_DESCRI")
							Endif
							If Subs(aHeader[nInd,2],5,6) == "UNIDAD"
								aCols[nJ,nInd] := Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_UNIDAD")
							Endif
						Else
							aCols[nTamCols,nInd] := .F.
						Endif
					Next
				Else
					aCols[nJ,1] := CriaVar(aHeader[1,2])
					aCols[nJ,2] := CriaVar(aHeader[2,2])
					For nI := 1 to Len(aHeader)
						If Subs(aHeader[nI,2],5,6) == "CODREC"
							aCols[nJ,nI] := BD4->BD4_CODIGO
						Endif
						If Subs(aHeader[nI,2],5,6) == "DESCRI"
							aCols[nJ,nI] := Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_DESCRI")
						Endif
						If Subs(aHeader[nI,2],5,6) == "VALREF"
							aCols[nJ,nI] := BD4->BD4_VALREF
						Endif
						If Subs(aHeader[nI,2],5,6) == "UNIDAD"
							aCols[nJ,nI] := Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_UNIDAD")
						Endif
						If Subs(aHeader[nI,2],5,6) == "VLMED "
							aCols[nJ,nI] := BD4->BD4_VLMED
						Endif
						If Subs(aHeader[nI,2],5,6) == "PERACI"
							aCols[nJ,nI] := BD4->BD4_PERACI
						Endif
					Next

					aCols[nJ,nI] := .F.
				Endif

				nJ++

				BD4->(DbSkip())
			EndDo

			aSize(aCols,nJ-1)
		Endif
	EndIf

	If Len(aCols) == 0
		aadd(aCols,{})
		nInd     := 1

		For nInd :=  1 To Len(aHeader)+1
			aadd(aCols[1],nInd)
			If nInd <= Len(aHeader)
				aCols[1,nInd] := CriaVar(aHeader[nInd,2])
				If Subs(aHeader[nInd,2],5,6) == "DESCRI"
					aCols[1,nInd] := Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_DESCRI")
				Endif
				If Subs(aHeader[nInd,2],5,6) == "UNIDAD"
					aCols[1,nInd] := Posicione("BD3",1,xFilial("BD3")+BD4->BD4_CODIGO,"BD3_UNIDAD")
				Endif
			Else
				aCols[1,nInd] := .F.
			Endif
		Next

	Endif

	DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 400,600 PIXEL //"Procedimentos"
	oDlg:lEscClose := .F.

	DEFINE SBUTTON oBtnBaca FROM 100000,100000 TYPE 1 ACTION (oDlg:GoNextCtrl(oDlg:hWnd)) OF oDlg ENABLE PIXEL
	oBtnBaca:bGotFocus := {||oDlg:GoNextCtrl(oBtnBaca:hWnd)}  // pula para o proximo controle - EDUARDO MOTTA - 04/07/2001
	oGet := TPLSBrw():New(15,0,300,200,nil  ,oDlg,nil    ,          ,nil    ,nil  ,nil , .T.   ,nil ,.T.   ,nil    ,aHeader   ,aCols   ,.F.     ,cAlias,nOpc,STR0003,nil    ,nil    ,nil,aVetTDE,,,bFilter) //"Procedimentos"

	ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1/*,PlsEndBrw()*/,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))
	If nOpca == 1
		aVetConf[nPos,3] := .T.
		aVet              := aClone(aVetConf)
		lConfirma         := .T.

		aColsTDE  := aClone(oGet:aCols)
		aVetTDE   := aClone(oGet:aVetTrab)

		If !Empty(cValida)
			&(cValida)
		Endif

	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XPrepareColsºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Prepara aCols                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function XPrepareCols(aHeader,aCols,cAlias,cWhile,cKey,bFor,aVet)
	LOCAL   cCondPes
	LOCAL   cSQL
	LOCAL   aVetor     := {}
	Local nI
	Local aArea      := GetArea()
	PRIVATE lSQLCls  := .T.
	DEFAULT aVet     := {}
	DEFAULT bFor     := { || .T. }

	IF (cAlias)->(Rddname()) != "TOPCONN"
		cCondPes := cAlias+"_FILIAL+"+cKey+" == '"+xFilial(cAlias)+cKey+"'"
		MsSeek(cCondPes,.T.)
		DBEval({|| AaDd(aCols,{}),aEval(aHeader,{|eH|;
			AaDd(aCols[len(aCols)],If(Empty(FieldPos(AllTrim(eH [2 ]))),CriaVar(AllTrim(eH [2 ])),FieldGet(FieldPos(AllTrim(eH [2])))))}),;
			AaDd(aCols[len(aCols)],.f.), If(ValType(aVet)=="A",aadd(aVet,Recno()),nil) },Eval(bfor), cwhile,nil, nil, nil)
	Else
		aVetor := {}
		SX3->(DbSetOrder(2))
		cSQL := "SELECT "
		For nI := 1 To Len(aHeader)
			If aHeader[nI,10] <> "V"
				cSQL += aHeader[nI,2]+","
			Else
				SX3->(MsSeek(aHeader[nI,2]))
				If "ESPPOSIC" $ SX3->X3_RELACAO
					aadd(aVetor,&(AllTrim(SX3->X3_RELACAO)))

					cSQL += aVetor[Len(aVetor),4]+" "+aVetor[Len(aVetor),7]+","
				Endif
			Endif
		Next

		cSQL := Subs(cSQL,1,Len(cSQL)-1)

		cSQL += " FROM "+RetSQLName(cAlias)+" "+cAlias

		For nI := 1 To Len(aVetor)
			cSQL += ", "+RetSQLName(aVetor[nI,1])+" "+aVetor[nI,1]
		Next

		cSQL += "WHERE "+XMontaWhere(cAlias,cKey,cWhile)

		For nI := 1 To Len(aVetor)
			cSQL += " AND "+aVetor[nI,3]+ " = "+aVetor[nI,5]+" AND "+aVetor[nI,1]+".D_E_L_E_T_ = ''"
		Next

		cSQL += " ORDER BY "+StrTran((&(cAlias)->(IndexKey())),"+",",")

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL New ALIAS "TrbCols"

		DbSelectArea("TrbCols")

		If ! TrbCols->(Eof())
			DBEval({|| AaDd(aCols,{}),aEval(aHeader,{|eH|;
				AaDd(aCols[len(aCols)],If(Empty(FieldPos(AllTrim(eH [2 ]))),CriaVar(AllTrim(eH [2 ])),FieldGet(FieldPos(AllTrim(eH [2])))))}),;
				AaDd(aCols[len(aCols)],.f.), If(ValType(aVet)=="A",aadd(aVet,Recno()),nil) },bfor, nil,nil, nil, nil)
		Else
			STORE COLS BLANK cALias TO aCols	FROM aHeader
		Endif

		TrbCols->(DbCloseArea())
		RestArea(aArea)
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XEspPosic   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Prepara aCols                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function XESPPOSIC(cAlias,nOrdem,cChavePes,cConteud,cChaveOri,cAliasPos,cCampo)
	LOCAL cRet
	LOCAL cSQLExp
	LOCAL cTypeRet

	If Type("lSQLCls") = "L" .And. lSQLCls
		cTypeRet := "A"
	Else
		cRet    := Posicione(cAlias,nOrdem,xFilial(cAlias)+&(cAliasPos+"->("+cChavePes+")"),cConteud)
		cTypeRet := "E"
	Endif

Return(IF(cTypeRet=="A",{cAlias,nOrdem,cChavePes,cConteud,cChaveOri,cAliasPos,cCampo},cRet))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMontaWhere ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Monta where                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function XMontaWhere(cAlias,cKey,cWhile)
	LOCAL cWhere
	LOCAL cField
	LOCAL aField
	LOCAL nI
	LOCAL nDe
	LOCAL uField
	LOCAL cDado

	cWhere := cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "
	cField := ""
	aField := {}
	For nI := 1 To Len(cKey)
		If Subs(cKey,nI,1) == "+"
			AADD(aField,cField)
			cField := ""
		Else
			cField += Subs(cKey,nI,1)
		Endif
	Next

	AADD(aField,cField)
	nDe := 1
	For Ni := 1 to Len(aField)
		cWhere += " AND " + aField[ni]+" = '"
		uField := &(cAlias+"->"+aField[ni])
		cDado  := Subs(cWhile,nDe,Len(uField))
		cWhere += cDado+"'"
		nDe    := Len(cDado)+1
	Next

	cWhere += " AND "+cAlias+".D_E_L_E_T_ = ' ' "

Return(cWhere)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsQuery    ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Monta query do PLS                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSQuery(cSQL,cAlias,lGerarLOG,cArqLog)
	LOCAL aStruc	:= {}
	LOCAL nInd		:= 0
	LOCAL nHorIni	:= 0

	DEFAULT lGerarLOG := .f.
	DEFAULT cArqLog   := "plslogqry.log"

	cSQL := PLSAvaSQL(cSQL)

	If lGerarLOG
		nHorIni := Seconds()
		PlsLogFil("",cArqLog)
		PlsLogFil(Space(10)+STR0004+ProcName(1)+" - "+ProcName(2)+" - "+ProcName(3)+" - "+ProcName(4)+" - "+ProcName(5),cArqLog) //"Log de Execucao de Query - Chamadas "
		PlsLogFil("",cArqLog)
		PlsLogFil(Space(10)+cSQL,cArqLog)
		PlsLogFil("",cArqLog)
	Endif

	if select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	endIf

	MPSysOpenQuery( changeQuery(cSql), cAlias )

	If lGerarLog
		PlsLogFil(Space(10)+STR0005+Str(PlsHorIni(),10,3),cArqLog) //"Tempo da query "
		PlsLogFil("",cArqLog)
	Endif

	plsTField(cAlias, .t.)

Return

/*/{Protheus.doc} plsTField
Seta TcSetField em campo especifico
@type function
@author PLSTEAM
@since 27/07/17
@version 1.0
/*/
function plsTField(cAlias, lStruct, aMat)
	local nI := 0

	SX3->(dbSetOrder(2))

	if !lStruct

		for nI := 1 to len(aMat)

			if SX3->( msSeek(aMat[nI]) ) .and. SX3->X3_TIPO <> "C"

				tcSetField(cAlias,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL)

			endIf

		next
	else

		aMat := (cAlias)->(dbStruct())

		for nI := 1 to len(aMat)

			if SX3->( msSeek(aMat[nI,1]) ) .and. SX3->X3_TIPO <> "C"

				tcSetField(cAlias,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL)

			endIf

		Next

	endIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsSomaHor  ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  soma horario                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsSomaHor(cHor1,cHor2)
	LOCAL cHora := Space(05)
	LOCAL nMin1 := 0
	LOCAL nMin2 := 0
	LOCAL nMin  := 0
	LOCAL nHor  := 0
	nMin1 := (Val(SubStr(cHor1,1,2))*60)+Val(SubStr(cHor1,4,2))
	nMin2 := (Val(SubStr(cHor2,1,2))*60)+Val(SubStr(cHor2,4,2))
	nHor  := Int((nMin1 + nMin2) / 60)
	nMin  := nMin1 + nMin2 - (nHor*60)
	cHora := StrZero(nHor,2)+":"+StrZero(nMin,2)
Return cHora
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsAtuAge   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Atualiza a agenda                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSAtuAge(aDados)
	LOCAL nH := PLSAbreSem("PLSATAGE.SMF")
	LOCAL nI
	LOCAL cCampo
	LOCAL cDado

	BBD->(RecLock("BBD",.T.))
	BBD->BBD_FILIAL := xFilial("BBD")

	For nI := 1 To Len(aDados)
		cCampo             := aDados[nI,1]
		cDado              := aDados[nI,2]
		&("BBD->"+cCampo) := cDado
	Next
	BBD->(MsUnLock())

	If ExistBlock("PLSATUAG")
		ExecBlock("PLSATUAG",.F.,.F.)
	Endif

	PLSFechaSem(nH,"PLSATAGE.SMF")

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsCanAge   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Cancela agenda                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCanAge(aDados)
	LOCAL nH := PLSAbreSem("PLSCANAGE.SMF")
	LOCAL nI
	LOCAL cCampo
	LOCAL cDado

	BHY->(RecLock("BHY",.T.))
	BHY->BHY_FILIAL := xFilial("BHY")

	For nI := 1 To Len(aDados)
		cCampo             := aDados[nI,1]
		cDado              := aDados[nI,2]
		&("BHY->"+cCampo) := cDado
	Next
	BHY->(MsUnLock())

	PLSFechaSem(nH,"PLSCANAGE.SMF")

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsAtuPro   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Atualizacao de regra de usu x produto                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSAtuPro(aDados)
	LOCAL nH := PLSAbreSem("PLSATUPRO.SMF")
	LOCAL nI
	LOCAL cCampo
	LOCAL cDado

	BJ7->(RecLock("BJ7",.T.))
	BJ7->BJ7_FILIAL := xFilial("BJ7")

	For nI := 1 To Len(aDados)
		cCampo             := aDados[nI,1]
		cDado              := aDados[nI,2]
		&("BJ7->"+cCampo) := cDado
	Next
	BJ7->(MsUnLock())

	PLSFechaSem(nH,"PLSATUPRO.SMF")

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSDADUSR³ Autor ³ Tulio Cesar        Data ³ 25.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna dados do usuario...                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
[01] Valido ou Invalido
[02] Matricula Microsiga
[03] Matricula Antiga
[04] Matricula Empresa
[05] Matricula Vida
[06] Nome
[07] Descricao da Empresa
[08] Tipo Empresa
[09] Contrato (Juridico)
[10] Data Contrato (Juridico)
[11] Codigo Produto
[12] Versao
[13] Forma Pagamento
[13] Descricao Produto
[14] Livre para uso
[15] Livre para uso
[16] Livre para uso
[17] Data Bloqueio Familia
[18] Motivo Bloqueio Familia
[19] livre
[20] livre
[21] Descricao da Operadora
[22] livre
[23] Produto Todos os Tipos de locais de atendimentos
[24] Sexo do usuario
[25] Data de Nascimento
[26] Idade
[27] Data Base Carencia
[28] Informacoes Usuario Nivel Cobertura
[29] Informacoes Usuario Nivel Grupo Cobertura
[30] Informacoes Usuario Pre-existencia
[31] Informacoes Familia Nivel Cobertura
[32] Informacoes Familia Nivel Grupo Cobertura
[33] Informacoes produto nivel cobertura
[34] Informacoes produto nivel grupo cobertura
[35] Informacoes produto nivel cobertura especifica usuario
[36] Operadora Usuario
[37] Matricula Usuario
[38] Versao do Grupo/Empresa
[39] Nome do Titular
[40] Sub-Contrato
[41] Versao do Sub-Contrato
[42] Tipo Usuario
                            "1" - Eventual
                            "2" - Repasse
                            "3" - Quando ele for um usuario da operadora padrao
[43] Operadora Intercambio
[44] Operadora Origem
[45] Operadora Destino
[46] Operadora Responsavel
[47] Todos os grupos de coberturas deste usuario no nivel PRODUTO
[48] Todos os grupos de coberturas deste usuario no nivel SUBCONTRATO

cMatrUsr - Matricula
cTipo    - "1" Matricula Microsiga
           "2" Matricula Antiga
           "3" Matricula Empresa
           "4" Matricula VidaBI3_CODACO

/*/
Function PLSDADUSR(cMatrUsr,cTipo,lHelp,dData,cCodPad,cCodPro,cViaCartao,aBD6,lLoadArray,lValCartao)
	LOCAL cCodInt	 := ""
	LOCAL cCodEmp	 := ""
	LOCAL cMatric	 := ""
	LOCAL cTipReg	 := ""
	LOCAL cDigito	 := ""
	LOCAL cSQL		 := ""
	LOCAL aRet    	 := {}
	LOCAL aAux    	 := { {"1",2},{"2",5},{"3",6},{"4",7} }
	LOCAL aCodCri 	 := {}
	LOCAL cSubCon 	 := space(len(BQC->BQC_SUBCON))
	LOCAL cVerSub 	 := space(len(BQC->BQC_VERSUB))
	LOCAL cNameBED 	 := iIf(IsInCallStack("Hs_Integr").AND. GetNewPar("MV_HSPPLS", .F.), "BED" + GetNewPar("MV_EMPRPLS", " ") + "0", RetSQLName("BED"))
	LOCAL lFlagUsr	 := .F.
	LOCAL lPerReem	 := .T.
	LOCAL cNomTit 	 := ""
	LOCAL cCC     	 := ""
	LOCAL cCodTit 	 := allTrim(GetNewPar("MV_PLCDTIT",""))
	LOCAL cInfCobBT6 := ""
	LOCAL cInfGrCBT6 := ""
	LOCAL dDatNas	 := ctod("")
	LOCAL cTratLim 	 := ""
	LOCAL nLimCH   	 := 0
	LOCAL nRegBI3Slv := 0
	LOCAL aRetCli	 := {}
	LOCAL cCodCLi  	 := ""
	LOCAL cLoja    	 := ""
	LOCAL cNomCli  	 := ""
	LOCAL cNivel   	 := ""
	LOCAL nRecCli  	 := 1
	local aAreaBA1	 := {}
	LOCAL nFor		 := 0
	LOCAL cCrGuiPOS	 := ''
	LOCAL aProdVinc	 := {}
	LOCAL cCodPla  	 := ""
	LOCAL cVersao  	 := ""
	LOCAL aCarRDA  	 := {}
	LOCAL aViasCart	 := {}
	LOCAL i		   	 := 0
	LOCAL cREGGOP  	 := ""
	LOCAL cGRUOPE  	 := ""
	LOCAL cTpAcom  	 := ""
	LOCAL cPadCon  	 := ""
	LOCAL cRetGui  	 := "0"
	LOCAL cSomInt  	 := ""
	LOCAL cGuiPOS  	 := ""
	LOCAL cTipFlag 	 := ""
	LOCAL cStrFil	 := ""
	LOCAL cCarSaud 	 := ""
	LOCAL cDig1    	 := ""
	LOCAL cDig2    	 := ""
	LOCAL lUnimeds 	 := IiF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
	LOCAL aRetPtoEnt := {}
	LOCAL cCodPlaBA1 := ""
	LOCAL cVersaoBA1 := ""
	LOCAL cUndPerUs	 := ""
	local cDesAcom	 := ""
	local cRegAte	 := ""
	LOCAL nQtdUS	 := 0
	LOCAL nQtdPerUs	 := 0
	LOCAL dDatCont   := ctod("")
	LOCAL lMatrAnt   := GetNewPar("MV_PLMATAP","0") == "1" //Mostra Matricula Antiga Portal
	LOCAL cMatGenSUS := GetNewPar('MV_MATGSUS',"99999999999999999") //Matrícula Generica - Ressarcimento SUS
	local cGrpEmpInt := getNewPar("MV_PLSGEIN","0050")
	LOCAL lStrTPLS	 := FindFunction("StrTPLS")

	DEFAULT cTipo      := "1"
	DEFAULT cCodPad    := ""
	DEFAULT cCodPro    := ""
	DEFAULT cViaCartao := ""
	DEFAULT aBD6       := {}
	DEFAULT lLoadArray := .T.
	DEFAULT lValCartao := .T.//Variavel criada pois na importacao PTU A500, nao realizo validacao de via de cartao no momento da criacao da guia

	If lUnimeds

		If ValType(cMatrUsr) <> "C" .Or. Empty(AllTrim(cMatrUsr)) .or. isAlpha(cMatrUsr)

			PLSPOSGLO(PLSINTPAD(),__aCdCri011[1],__aCdCri011[2])
			If Len(aBD6) == 0
				aadd(aCodCri,{__aCdCri011[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				aadd(aCodCri,{__aCdCri011[1],STR0008,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro}) //"Matricula com caracteres entre o numero ou em branco"
			Else
				For nFor := 1 To Len(aBD6)
					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]
					aadd(aCodCri,{__aCdCri011[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{__aCdCri011[1],STR0008,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro}) //"Matricula com caracteres entre o numero ou em branco"
				Next
			Endif

			Return({.F.,aCodCri})

		Endif

	EndIf

	cCodInt := Subs(cMatrUsr,atCodOpe[1],atCodOpe[2])
	cCodEmp := Subs(cMatrUsr,atCodEmp[1],atCodEmp[2])
	cMatric := Subs(cMatrUsr,atMatric[1],atMatric[2])
	cTipReg := Subs(cMatrUsr,atTipReg[1],atTipReg[2])
	cDigito := Subs(cMatrUsr,atDigito[1],atDigito[2])

	If !lStrTPLS
		If cTipo == "1"

			If !Empty(BA1->BA1_MATANT) .And. BA1->BA1_MATANT == cMatrUsr
				cCodInt := BA1->BA1_CODINT      //AO HABILITAR O PARAMETRO DE MATRICULA ANTIGA DO PORTAL... AQUI ESTA CHEGANDO A MATRICULA ANTIGA..POR ISSO AJUSTO
				cCodEmp := BA1->BA1_CODEMP
				cMatric := BA1->BA1_MATRIC
				cTipReg := BA1->BA1_TIPREG
				cDigito := BA1->BA1_DIGITO
			EndIf

			If Len( alltrim( str( val(cCodInt+cCodEmp+cMatric+cTipReg+cDigito)))) >= 13 //matricula completa e sem letars no meio

				If Empty(cDigito) .And. cTipo == "1"

					cDigito := Modulo11(cCodInt+cCodEmp+cMatric+cTipReg)

					If Len(cMatrUsr) == 16
						cMatrUsr := cMatrUsr + cDigito
					EndIf

				ElseIf ! Empty(cDigito) .And. cTipo == "1" .And. Modulo11(cCodInt+cCodEmp+cMatric+cTipReg) <> cDigito

					PLSPOSGLO(PLSINTPAD(),__aCdCri038[1],__aCdCri038[2])

					If Len(aBD6) == 0
						aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{""   ,STR0012,cDigito,"","",cCodPad,cCodPro}) //"Digito informado"
						aadd(aCodCri,{""   ,STR0013,Modulo11(cCodInt+cCodEmp+cMatric+cTipReg),"","",cCodPad,cCodPro}) //"Digito correto"
					Else
						For nFor := 1 To Len(aBD6)
							cCodPad := aBD6[nFor,3]
							cCodPro := aBD6[nFor,4]
							aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
							aadd(aCodCri,{""   ,STR0012,cDigito,"","",cCodPad,cCodPro}) //"Digito informado"
							aadd(aCodCri,{""   ,STR0013,Modulo11(cCodInt+cCodEmp+cMatric+cTipReg),"","",cCodPad,cCodPro}) //"Digito correto"
						Next
					Endif

					Return({.F.,aCodCri})
				Endif

			Else

				PLSPOSGLO(PLSINTPAD(),__aCdCri011[1],__aCdCri011[2])
				aadd(aCodCri,{__aCdCri011[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO})
				aadd(aCodCri,{__aCdCri011[1],STR0008,"",BCT->BCT_NIVEL,BCT->BCT_TIPO}) //"Matricula com caracteres entre o numero ou em branco"

				Return({.F.,aCodCri})

			Endif
		Endif
	Else
		If cTipo == "1"

			If !Empty(BA1->BA1_MATANT) .And. BA1->BA1_MATANT == cMatrUsr
				cCodInt := BA1->BA1_CODINT      //AO HABILITAR O PARAMETRO DE MATRICULA ANTIGA DO PORTAL... AQUI ESTA CHEGANDO A MATRICULA ANTIGA..POR ISSO AJUSTO
				cCodEmp := BA1->BA1_CODEMP
				cMatric := BA1->BA1_MATRIC
				cTipReg := BA1->BA1_TIPREG
				cDigito := BA1->BA1_DIGITO
			EndIf

			If Len( alltrim( str( val(StrTPLS(cCodInt+cCodEmp+cMatric+cTipReg+cDigito))))) >= 13 //matricula completa e sem letars no meio

				If Empty(cDigito) .And. cTipo == "1"

					cDigito := Modulo11(StrTPLS(cCodInt+cCodEmp+cMatric+cTipReg))

					If Len(cMatrUsr) == 16
						cMatrUsr := cMatrUsr + cDigito
					EndIf

				ElseIf ! Empty(cDigito) .And. cTipo == "1" .And. Modulo11(StrTPLS(cCodInt+cCodEmp+cMatric+cTipReg)) <> cDigito

					PLSPOSGLO(PLSINTPAD(),__aCdCri038[1],__aCdCri038[2])

					If Len(aBD6) == 0
						aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{""   ,STR0012,cDigito,"","",cCodPad,cCodPro}) //"Digito informado"
						aadd(aCodCri,{""   ,STR0013,Modulo11(StrTPLS(cCodInt+cCodEmp+cMatric+cTipReg)),"","",cCodPad,cCodPro}) //"Digito correto"
					Else
						For nFor := 1 To Len(aBD6)
							cCodPad := aBD6[nFor,3]
							cCodPro := aBD6[nFor,4]
							aadd(aCodCri,{__aCdCri038[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
							aadd(aCodCri,{""   ,STR0012,cDigito,"","",cCodPad,cCodPro}) //"Digito informado"
							aadd(aCodCri,{""   ,STR0013,Modulo11(StrTPLS(cCodInt+cCodEmp+cMatric+cTipReg)),"","",cCodPad,cCodPro}) //"Digito correto"
						Next
					Endif

					Return({.F.,aCodCri})
				Endif

			Else

				PLSPOSGLO(PLSINTPAD(),__aCdCri011[1],__aCdCri011[2])
				aadd(aCodCri,{__aCdCri011[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO})
				aadd(aCodCri,{__aCdCri011[1],STR0008,"",BCT->BCT_NIVEL,BCT->BCT_TIPO}) //"Matricula com caracteres entre o numero ou em branco"

				Return({.F.,aCodCri})

			Endif
		Endif
	EndIf

	//Posiciona na operadora...
	BA0->(dbSetOrder(1)) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(msSeek( xFilial("BA0") + cCodInt) )

	if lUnimeds

		if len( allTrim(cMatrUsr) ) == 17 .and. !BA0->(found())

			PLSPOSGLO(PLSINTPAD(),__aCdCri010[1],__aCdCri010[2])

			if len(aBD6) == 0

				aadd(aCodCri,{__aCdCri010[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				aadd(aCodCri,{"",STR0014,Subs(cMatrusr,1,ntCodOpe),"","",cCodPad,cCodPro}) //"Operadora do Usuario Informada incorretamente"

			else

				for nFor := 1 To Len(aBD6)
					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]
					aadd(aCodCri,{__aCdCri010[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{"",STR0014,Subs(cMatrusr,1,ntCodOpe),"","",cCodPad,cCodPro}) //"Operadora do Usuario Informada incorretamente"
				next

			endIf

			return({.F.,aCodCri})

		endIf

	elseIf !BA0->(found()) .and. cTipo <> "2" //Valida matricula antiga evitando o return

		PLSPOSGLO(PLSINTPAD(),__aCdCri010[1],__aCdCri010[2])

		aadd(aCodCri,{__aCdCri010[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
		aadd(aCodCri,{"",STR0014,Subs(cMatrusr,1,ntCodOpe),"","",cCodPad,cCodPro}) //"Operadora do Usuario Informada incorretamente"

		return({.f.,aCodCri})

	endIf

	//Posiciona no BA1...
	If cTipo == "1"

		BA1->(DbSetOrder(2))
		lFlagUsr := (cCodInt + cCodEmp + cMatric + cTipReg != cMatGenSUS .and. cCodInt + cCodEmp + cMatric + cTipReg + cDigito != cMatGenSUS) .and. BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg+cDigito)) .and. (allTrim( BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) == allTrim(cMatrUsr) .Or. BA1->BA1_MATANT == cMatrUsr)

		If ! lFlagUsr .And. lMatrAnt
			BA1->(DbSetOrder(5))
			lFlagUsr := IIF(BA1->(MsSeek(xFilial("BA1")+cMatrUsr)), alltrim(BA1->BA1_MATANT) == cMatrUsr, .F.) //Somente se a busca for exata dá .T., ficou assim pq o segundo parâmetro do MsSeek não estava funcionando
		Endif

	ElseIf cTipo == "2"
		BA1->(DbSetOrder(5))
		lFlagUsr := IIF(BA1->(MsSeek(xFilial("BA1")+cMatrUsr)), alltrim(BA1->BA1_MATANT) == cMatrUsr, .F.) //Somente se a busca for exata dá .T., ficou assim pq o segundo parâmetro do MsSeek não estava funcionando
	Endif

	If !lFlagUsr
		cTipFlag := STR0015 //"Nao localizado na busca ao arquivo de usuarios (BA1)"
	Endif

	cStrFil := PlsRestOp("U",.f.)   // retorna string com filtro para restricao do operador

	If ! Empty(cStrFil)

		If AT("||",cStrFil)> 0
			cStrFil := StrTran(cStrFil,'||'," + ")
		Endif

		lFlagUsr := BA1->(&cStrFil)

		If ! lFlagUsr
			cTipFlag := __aCdCri095[2]
		EndIf

	EndIf

	If lFlagUsr

		BA3->(DbSetOrder(1))
		lFlagUsr := BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

		If ExistBlock("PLSXRGCP")
			aRetPtoEnt := ExecBlock("PLSXRGCP",.F.,.F.,{BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA1->BA1_CODPLA,BA1->BA1_VERSAO,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)})
			cCodPla    := aRetPtoEnt[1]
			cVersao    := aRetPtoEnt[2]
			cCodPlaBA1 := aRetPtoEnt[3]
			cVersaoBA1 := aRetPtoEnt[4]
		Else
			cCodPla    := BA3->BA3_CODPLA
			cVersao    := BA3->BA3_VERSAO
			cCodPlaBA1 := BA1->BA1_CODPLA
			cVersaoBA1 := BA1->BA1_VERSAO

			If !Empty(cCodPlaBA1) .and. !Empty(cVersaoBA1) // Tem casos que o usuario possui produto direferente dos demais configurado no BA1
				cCodPla := BA1->BA1_CODPLA
				cVersao := BA1->BA1_VERSAO
			Endif

		Endif

		If lFlagUsr

			BI3->(DbSetOrder(1))
			lFlagUsr := BI3->(MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cCodPla))

			If lFlagUsr
				BG9->(DbSetOrder(1))
				lFlagUsr := BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))

				If ! lFlagUsr
					cTipFlag := STR0016 //"Nao localizado na busca ao arquivo de grupo empresa (BG9).Verifique os campos BA3_CODEMP/BA1_CODEMP."
				Endif
			Else
				cTipFlag := STR0017 //"Nao localizado na busca ao arquivo de produto (BI3).Verifique os campos BA3_CODPLA/BA1_CODPLA."
			Endif
		Else
			cTipFlag := STR0018 //"Nao localizado na busca ao arquivo de familia (BA3).Verifique os campos BA1_CODEMP+BA1_MATRIC."
		Endif
	Endif

	If ! lFlagUsr

		PLSPOSGLO(PLSINTPAD(),__aCdCri011[1],__aCdCri011[2])

		If Len(aBD6) == 0
			aadd(aCodCri,{__aCdCri011[1],PLSBCTDESC(),cCodInt+"."+cCodEmp+"."+cMatric+"-"+cTipReg,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			aadd(aCodCri,{__aCdCri011[1], cTipFlag  ,cCodInt+"."+cCodEmp+"."+cMatric+"-"+cTipReg,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
		Else
			For nFor := 1 To Len(aBD6)
				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]
				aadd(aCodCri,{__aCdCri011[1],PLSBCTDESC(),cCodInt+"."+cCodEmp+"."+cMatric+"-"+cTipReg,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				aadd(aCodCri,{__aCdCri011[1],cTipFlag,cCodInt+"."+cCodEmp+"."+cMatric+"-"+cTipReg,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			Next
		Endif

		Return({.F.,aCodCri})

	Else

		If BG9->BG9_TIPO == "2"

			BT5->(DbSetOrder(1))
			BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))

			BQC->(DbSetOrder(1))
			BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))

			cREGGOP  := BQC->BQC_REGGOP
			cGRUOPE  := BQC->BQC_GRUOPE

			cGuiPOS 	:= BQC->BQC_GUIPOS
			cCrGuiPOS 	:= BQC->BQC_CRGPOS

			nQtdUS		:= BQC->BQC_QTDUS
			nQtdPerUs	:= BQC->BQC_QTDPUS
			cUndPerUs	:= BQC->BQC_UNIPUS

			BT6->(DbSetOrder(1))
			BT6->(MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+cCodPla+cVersao)))

			cCC := BT6->BT6_CC

			cInfCobBT6 := BT6->BT6_INFCOB
			cInfGrCBT6 := BT6->BT6_INFGRC

			cSubCon  := BQC->BQC_SUBCON
			cVerSub  := BQC->BQC_VERSUB

			cRetGui  := BT6->BT6_RETGUI
			cSomInt  := BT6->BT6_SOMINT

			cTratLim := BQC->BQC_CONSLI
			nLimCH   := BQC->BQC_LIMCH

			//Se permite reembolso
			lPerReem := BA3->BA3_PODREM == '1' .Or. BQC->BQC_PODREM == '1' .Or. BT5->BT5_PODREM == '1' .Or. BG9->BG9_PODREM == '1' .Or. BI3->BI3_REEMB == '1'

			// Grava a Data do contrato
			dDatCont := BQC->BQC_DATCON

		Else

			// Pessoa Fisica
			cCC := BI3->BI3_CC

			// Regra de quantidade de US.
			nQtdUS		:= BI3->BI3_QTDUS
			nQtdPerUs	:= BI3->BI3_QTDPUS
			cUndPerUs	:= BI3->BI3_UNIPUS

			//Se permite reembolso
			lPerReem := BA3->BA3_PODREM == '1'

			// Grava a Data do contrato
			dDatCont := BA3->BA3_DATBAS

		Endif

		if BA1->BA1_TIPUSU == cCodTit
			cNomTit := BA1->BA1_NOMUSR
		else

			aAreaBA1 := BA1->(getArea())

			cNomTit  := Posicione("BA1",1,xFilial("BA1")+cCodInt+cCodEmp+cMatric+cCodTit,"BA1_NOMUSR")

			BA1->(restArea(aAreaBA1))

		endIf
	endIf

	If ! AllTrim(BA3->BA3_MODPAG) $ "1,2,9"

		PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2])

		If Len(aBD6) == 0
			aadd(aCodCri,{__aCdCri032[1],STR0019,cCodInt+"."+cCodEmp+"."+cMatric+"-"+cTipReg,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro}) //"Campo do cadastro da familia 'Mod.Cobr.' (BA3_MODPAG) Folder ANS invalido"
		Else
			For nFor := 1 To Len(aBD6)
				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]
				aadd(aCodCri,{__aCdCri032[1],STR0019,cCodInt+"."+cCodEmp+"."+cMatric+"-"+cTipReg,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})    //"Campo do cadastro da familia 'Mod.Cobr.' (BA3_MODPAG) Folder ANS invalido"
			Next
		Endif

		Return({.F.,aCodCri})

	Endif

	If ! PLSVldInt(BA1->BA1_CODINT,.T.)

		PLSPOSGLO(PLSINTPAD(),__aCdCri095[1],__aCdCri095[2])

		If Len(aBD6) == 0
			AaDd(aCodCri,{__aCdCri095[1],__aCdCri095[2],BA1->BA1_CODINT,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
		Else

			For nFor := 1 To Len(aBD6)
				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]
				aadd(aCodCri,{__aCdCri095[1],__aCdCri095[2],BA1->BA1_CODINT,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			Next

		Endif

		Return({.F.,aCodCri})
	Endif

	//Monta retorno...
	If Empty(BA1->BA1_DATNAS)
		dDatNas := dData-1
	Else
		dDatNas := BA1->BA1_DATNAS
	Endif

	//Busca os produtos relacionados e vinculados ao usuario...
	BF4->(DbSetOrder(1))
	If BF4->(MsSeek(xFilial("BF4")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))

		nRegBI3Slv := BI3->(Recno())

		BI3->(DbSetOrder(1))
		While ! BF4->(Eof()) .And. BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG) == xFilial("BF4")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

			If BI3->(MsSeek(xFilial("BI3")+BF4->(BF4_CODINT+BF4_CODPRO+BF4_VERSAO)))
				// Quando nao for Brasil, pegar o produto selecionado apenas cCodPlaBA1
				If cPaisLoc == "BRA" .Or. (!Empty(cCodPlaBA1) .And. cCodPlaBA1 == BF4->BF4_CODPRO)

					if (empty(BF4->BF4_DATBLO) .OR. BF4->BF4_DATBLO > dData) .and. BF4->BF4_DATBAS <= dData
						aadd(aProdVinc,{BF4->BF4_CODPRO,BF4->BF4_VERSAO,BI3->BI3_INFCOB,BI3->BI3_INFGCB,BI3->BI3_TODOS})
					endif

				Endif

			Endif

			BF4->(DbSkip())
		Enddo

		BI3->(DbGoTo(nRegBI3Slv))
	Endif

	BI3->(DbSetOrder(1))
	BI3->(MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cCodPla+cVersao))

	//Todo tipo de rede de atendimento quer dizer o plano que esta definido na RDA
	//e nao o produto do usuario. BI3_ALLRED=1
	If BI3->BI3_ALLRED <> "1"
		aCarRDA := PLSRDAREF('BB6',BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO))
	Endif

	aRetCli := PLSRETNCB(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,BA1->BA1_OPEORI)
	If aRetCli[1]
		cCodCli := aRetCli[2]
		cLoja   := aRetCli[3]
		cNomCli := aRetCli[4]
		cNivel  := aRetCli[5]
		nRecCli := aRetCli[6]
	Endif

	BTS->( DbSetOrder(1) ) //BTS_FILIAL + BTS_MATVID
	If BTS->( MsSeek(xFilial("BTS")+BA1->BA1_MATVID) )
		cCarSaud :=  BTS->BTS_NRCRNA
	EndIf

	//Verifica se o usuario tem dados biometricos
	BIO->( DbSetOrder(1) ) //BIO_FILIAL+BIO_ALIAS+BIO_ID+BIO_DIG

	If BIO->( MsSeek(xFilial("BIO") + "BTS" + BA1->BA1_MATVID) )

		While !BIO->( Eof() ) .And.  BIO->(BIO_FILIAL) + "BTS" + BIO->BIO_ID == xFilial("BIO") + "BTS" + BA1->BA1_MATVID

			cDig1 += AllTrim(BIO->BIO_DIG)+AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)+'@'

			BIO->( DbSkip() )
		EndDo

	EndIf

	//Retorna o tipo de acomodacao e o padrao de conforto
	cTpAcom	 := PLSACOMUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
	cDesAcom := allTrim( posicione("BI4",1,xFilial("BI4") + cTpAcom,"BI4_DESCRI") )
	cPadCon	 := PLSACOMUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"2")
	cRegAte  := iIf( PLSUSRINTE( BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), dData )[1] , '1', '2' )

	//Retorna dados do usuario
	aRet :=  {.T.,;//01
		BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO,;//02
		allTrim(BA1->BA1_MATANT),;//03
		BA1->BA1_MATEMP,;//04
		BA1->BA1_MATVID,;//05
		allTrim(BA1->BA1_NOMUSR),;//06
		allTrim(BG9->BG9_DESCRI),;//07
		BG9->BG9_TIPO,;//08
		If(BG9->BG9_TIPO == "1","",BT5->BT5_NUMCON),;//09
		BT5->BT5_DATCON,;//10
		cCodPla,;//11
		cVersao,;//12
		BA3->BA3_FORPAG,;//13
		BI3->BI3_DESCRI,;//14
		cTratLim,;//15
		nLimCH,;//16
		cTpAcom,;//17
		BA3->BA3_DATBLO,;//18
		BA3->BA3_MOTBLO,;//19
		cPadCon,;//20
		cDesAcom,;//21
		BA0->BA0_NOMINT,;//22
		"",;//23
		BI3->BI3_ALLRED,;//24
		BA1->BA1_SEXO,;//25
		BA1->BA1_DATNAS,;//26
		DateDiffYear(dData,dDatNas),;//27
		BA1->BA1_DATCAR,;//28
		BA1->BA1_INFCOB,;//29
		BA1->BA1_INFGCB,;//30
		BA1->BA1_INFPRE,;//31
		BA3->BA3_INFCOB,;//32
		BA3->BA3_INFGCB,;//33
		BI3->BI3_INFCOB,;//34
		BI3->BI3_INFGCB,;//35
		"",;//36
		BA1->BA1_CODINT,;//37
		BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),;//38
		BA3->BA3_VERCON,;//39
		cNomTit,;//40
		cSubCon,;//41
		cVerSub,;//42
		If(BG9->BG9_TIPO == "1","04",If(BT5->BT5_INTERC $ "0, ","04",allTrim(BT5->BT5_TIPOIN))),;//43
		BT5->BT5_OPEINT,;//44
		BA1->BA1_OPEORI,;//45
		BA1->BA1_OPEDES,;//46
		BA1->BA1_OPERES,;//47
		BA3->BA3_MODPAG,;//48
		BI3->BI3_TODOS,;//49
		cInfCobBT6,;//50
		cInfGrCBT6,;//51
		BA0->BA0_GRUOPE,;//52
		BA1->BA1_VIACAR,;//53
		cCC,;//54
		BI3->BI3_NATURE,;//55
		aProdVinc,;//56
		aCarRDA,;//57
		cCodCli,;//58
		cLoja,;//59
		cNomCli,;//60
		cNivel,;//61
		nRecCli,;//62
		cREGGOP,;//63
		cGRUOPE,;//64
		BI3->BI3_ABRANG,;	//65
		BA1->BA1_DATINC,;	//66
		cRetGui,;			//67
		cSomInt,;			//68
		cGuiPOS,;			//69
		cCrGuiPOS,;			//70
		Iif( BI3->( FieldPos("BI3_CODGRU") ) > 0 ,BI3->BI3_CODGRU,""),;//71
		BA0->BA0_BASCOP,;	//72
		allTrim(BI3->BI3_NREDUZ),;	//73
		BA1->BA1_DTVLCR,;	//74
		BA1->BA1_DATTRA,;	//75
		BA1->BA1_TRAORI,;	//76
		cCarSaud,;			//77
		BI3->BI3_REEMB,;	//78
		allTrim(BA1->BA1_TELEFO),;	//79
		cDig1,;		  		//80
		cDig2,;          	//81
		BA1->BA1_TIPUSU,; 	//82
		nQtdUS,; 			// 83
		nQtdPerUs,; 		// 84
		cUndPerUs,;			// 85
		BI3->BI3_TPCONT,;	// 86
		lPerReem,;          // 87
		BA1->BA1_DATBLO,;	// 88
		dDatCont,;			// 89
		iIf(BG9->BG9_TIPO == "1",BA3->BA3_TIPOUS, iIf(BQC->BQC_ENTFIL == "1","3",BA3->BA3_TIPOUS)),;    // 90
		iIf(BA1->BA1_CODEMP == cGrpEmpInt,"1","0"),; // 91
		cRegAte,;  			//92
		AllTrim(BA0->BA0_SUSEP),;	// 93
		BA1->BA1_RECNAS,;  		    // 94
		BA1->BA1_CPFUSR,;  		    // 95
		iIf(empty(BQC->BQC_QUACOB), '0', allTrim(BQC->BQC_QUACOB)),;	// 96
		BI3->BI3_CODIGO,;		    // 97
		allTrim(BQC->BQC_DESCRI),;	// 98
		allTrim(BA1->BA1_PESO),;	// 99
		allTrim(BA1->BA1_ALTURA),;	// 100
		Iif( !empty(BA1->BA1_LOCCOB), Iif(BA1->BA1_LOCCOB == "1", BA1->BA1_OPEORI, BA1->BA1_OPEDES ) , plsintpad() ),;	//101
		Iif( BA1->( FieldPos("BA1_NOMSOC") ) > 0 ,BA1->BA1_NOMSOC,"")}	// 102

	__cOpePad := BA1->BA1_CODINT

	If lLoadArray
		aDadUsr := aClone(aRet)
	Endif

	//Se não foi informado a via pega do ba1
	If Empty(cViaCartao)
		If cViaCartao == "NAO_VALIDAR_CARTAO"
			cViaCartao	:=	""
		Else
			cViaCartao := AllTrim( Str(BA1->BA1_VIACAR) )
		EndIf
	EndIf

	//Testo a via do cartao do usuario
	If ! Empty(cViaCartao) .And. Val(cViaCartao) <> 0 .And. BED->(FieldPos("BED_DATBLO")) > 0 .And. BA1->BA1_OPEORI == PlsIntPad() .And. lValCartao

		cSQL := "SELECT BED_CODINT, BED_CODEMP, BED_MATRIC, BED_TIPREG, BED_VIACAR, BED_DATVAL, BED_BLOIDE, BED_CODBLO, BED_DATBLO "
		cSQL += " FROM " + cNameBED + " Where "
		cSQL += " BED_FILIAL = '" + xFilial("BED")  + "' AND "
		cSQL += " BED_CODINT = '" + BA1->BA1_CODINT + "' AND "
		cSQL += " BED_CODEMP = '" + BA1->BA1_CODEMP + "' AND "
		cSQL += " BED_MATRIC = '" + BA1->BA1_MATRIC + "' AND "
		cSQL += " BED_TIPREG = '" + BA1->BA1_TIPREG + "' AND "
		cSQL += " D_E_L_E_T_ <> '*'"

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbIdent",.f.,.t.)
		TCSETFIELD("TrbIdent","BED_DATVAL","D")
		TCSETFIELD("TrbIdent","BED_DATBLO","D")
		If TrbIdent->( Eof() )

			//Via de cartao magnetico invalida.
			If PLSPOSGLO(PLSINTPAD(),__aCdCri079[1],__aCdCri079[2])
				If Len(aBD6) == 0
					aadd(aCodCri,{__aCdCri079[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{"",STR0020,"",,,cCodPad,cCodPro}) //"Nao foram encontradas vias de cartao geradas para este usuario."
				Else
					For nFor := 1 To Len(aBD6)
						cCodPad := aBD6[nFor,3]
						cCodPro := aBD6[nFor,4]
						aadd(aCodCri,{__aCdCri079[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{"",STR0020,"",,,cCodPad,cCodPro}) //"Nao foram encontradas vias de cartao geradas para este usuario."
					Next
				Endif
				TrbIdent->(DbCloseArea())

				Return({.F.,aCodCri})
			Else
				TrbIdent->(DbCloseArea())
			Endif

		Else

			While !TrbIdent->( Eof() )
				AaDd(aViasCart,{TrbIdent->BED_VIACAR,TrbIdent->BED_BLOIDE,TrbIdent->BED_DATVAL,TrbIdent->BED_CODBLO,TrbIdent->BED_DATBLO})
				TrbIdent->( DbSkip() )
			EndDo

			//Via de cartao magnetico nao existente..
			If PLSPOSGLO(PLSINTPAD(),__aCdCri076[1],__aCdCri076[2]) .And. ;
					aScan(aViasCart, {|x| x[1] == val(cViaCartao)}) == 0
				If Len(aBD6) == 0
					aadd(aCodCri,{__aCdCri076[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{"",STR0021,"",,,cCodPad,cCodPro}) //"Entre as vias geradas para este usuario, nao existe via com este numero."
					aadd(aCodCri,{"",STR0022,cViaCartao,,,cCodPad,cCodPro}) //"Numero da via do cartao do usuario: "
				Else
					For nFor := 1 To Len(aBD6)
						cCodPad := aBD6[nFor,3]
						cCodPro := aBD6[nFor,4]
						aadd(aCodCri,{__aCdCri076[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{"",STR0021,"",,,cCodPad,cCodPro}) //"Entre as vias geradas para este usuario, nao existe via com este numero."
						aadd(aCodCri,{"",STR0022,cViaCartao,,,cCodPad,cCodPro}) //"Numero da via do cartao do usuario: "
					Next
				Endif
				TrbIdent->(DbCloseArea())

				Return({.F.,aCodCri})

				//Via de cartao magnetico bloqueada.
			Elseif PLSPOSGLO(PLSINTPAD(),__aCdCri077[1],__aCdCri077[2]) .And. ;
					(i := aScan(aViasCart, {|x| x[1] == val(cViaCartao) .and. x[2] == "1" .and. x[5] <= dData })) <> 0

				If Len(aBD6) == 0
					aadd(aCodCri,{__aCdCri077[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{"",STR0023,cViaCartao,,,cCodPad,cCodPro}) //"Numero da via do cartao magnetico do usuario: "
					aadd(aCodCri,{"",STR0024,aViasCart[i][4],,,cCodPad,cCodPro})  //"Codigo do Bloqueio:  "
					aadd(aCodCri,{"",STR0025+ Posicione("SX5",1,xFilial("SX5")+"BG"+aViasCart[i][4],"X5_DESCRI"),,,,cCodPad,cCodPro}) //"Motivo do Bloqueio:  "
					aadd(aCodCri,{"",STR0026,dtoc(aViasCart[i][5]),,,cCodPad,cCodPro})  //"Data do Bloqueio: "
				Else
					For nFor := 1 To Len(aBD6)
						cCodPad := aBD6[nFor,3]
						cCodPro := aBD6[nFor,4]
						aadd(aCodCri,{__aCdCri077[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{"",STR0023,cViaCartao,,,cCodPad,cCodPro}) //"Numero da via do cartao magnetico do usuario: "
						aadd(aCodCri,{"",STR0024,aViasCart[i][4],,,cCodPad,cCodPro})  //"Codigo do Bloqueio:  "
						aadd(aCodCri,{"",STR0025+ Posicione("SX5",1,xFilial("SX5")+"BG"+aViasCart[i][4],"X5_DESCRI"),,,,cCodPad,cCodPro}) //"Motivo do Bloqueio:  "
						aadd(aCodCri,{"",STR0026,dtoc(aViasCart[i][5]),,,cCodPad,cCodPro})  //"Data do Bloqueio: "
					Next
				Endif

				TrbIdent->(DbCloseArea())

				Return({.F.,aCodCri})

				//Via de cartao magnetico vencida
			Elseif PLSPOSGLO(PLSINTPAD(),__aCdCri078[1],__aCdCri078[2]) .And. ;
					(i := aScan(aViasCart, {|x| x[1] == val(cViaCartao) .and. x[3] < dData})) <> 0

				If Len(aBD6) == 0
					aadd(aCodCri,{__aCdCri078[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aadd(aCodCri,{"",STR0023,cViaCartao,,,cCodPad,cCodPro}) //"Numero da via do cartao magnetico do usuario: "
					aadd(aCodCri,{"",STR0028,dtoc(aViasCart[i][3]),,,cCodPad,cCodPro}) 		 //"Data do Vencimento: "
				Else
					For nFor := 1 To Len(aBD6)
						cCodPad := aBD6[nFor,3]
						cCodPro := aBD6[nFor,4]
						aadd(aCodCri,{__aCdCri078[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{"",STR0023,cViaCartao,,,cCodPad,cCodPro}) //"Numero da via do cartao magnetico do usuario: "
						aadd(aCodCri,{"",STR0028,dtoc(aViasCart[i][3]),,,cCodPad,cCodPro}) 		 //"Data do Vencimento: "
					Next
				Endif

				TrbIdent->(DbCloseArea())

				Return({.F.,aCodCri})
			Else
				TrbIdent->(DbCloseArea())
			Endif
		Endif
	Endif

	dbSelectArea("BA1")

	If ExistBlock("PLSDDUSR")
		ExecBlock("PLSDDUSR",.F.,.F.,{BA1->BA1_CODINT})
	Endif

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSDADRDA³ Autor ³ Tulio Cesar        Data ³ 25.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna dados de uma rede de atendimento...            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
[01] Valido ou Invalido
[02] Codigo Microsiga
[03] Codigo Antigo
[04] Estado + Registro + Sigla
[05] Codigo Profissional Saude
[06] Nome Rede Atendimento
[07] Nome Reduzido Rede Atendimento
[08] Tipo Empresa
[09] Data Bloqueio
[10] Motivo Bloqueio
[11] Parametro obsoleto //RDA Externo (Sim/Nao)
[12] Codigo + Local do Local de Atendimento Selecionado
[13] Codigo da Especialidade Selecionada
[14] Operadora RDA
[15] Codigo da sub-especialidade (opcional)
[16] CPF/CGC da Rede de atendimento

cCodigo  - Codigo
cCodInt  - Cod Operadora
cTipo    - "1" Codigo Microsiga
           "2" Codigo Antigo
           "3" Estado + Registro + Sigla
           "4" Codigp Profissional Saude
lPosic   - Mantem posicionado os arquivos ou nao
/*/
Function PLSDADRDA(cCodInt,cCodigo,cTipo,dData,cCodLoc,cCodEsp,cCodPad,cCodPro,aBD6,lLoadRda,cEspSol,cEspExe,lDesEsp,lProrInt,lShallPass)
	LOCAL nFor     := 0
	LOCAL cTrtExe  := ""
	LOCAL aRet     := {}
	LOCAL aCodCri  := {}
	LOCAL aCarRDA  := {}
	LOCAL aRetFun  := {}
	LOCAL lRDAInt  := .F.
	LOCAL lRet     := .T.

	DEFAULT cTipo    := "1"
	DEFAULT cCodLoc  := ""
	DEFAULT cCodEsp  := ""
	DEFAULT cCodPad  := ""
	DEFAULT cCodPro  := ""
	DEFAULT aBD6     := {}
	DEFAULT lLoadRda := .F.
	DEFAULT cEspSol  := ""
	DEFAULT cEspExe  := ""
	DEFAULT lDesEsp	  := .F.
	DEFAULT lProrInt := .F. // Prorrogação de Internação
	Default lShallPass := .F. //Força carregar o aDadRDA
	//Posiciona na operadora...
	BA0->(DbSetOrder(1))
	If empty(cCodInt) .or. ! BA0->(MsSeek(xFilial("BA0") + subs(cCodInt,1,ntCodOpe)))

		PLSPOSGLO(PLSINTPAD(),__aCdCri012[1],__aCdCri012[2])

		If Len(aBD6) == 0

			aadd(aCodCri,{__aCdCri012[1],PLSBCTDESC(),Subs(cCodInt,1,ntCodOpe),BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})

		Else

			For nFor := 1 To Len(aBD6)

				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]

				aadd(aCodCri,{__aCdCri012[1],PLSBCTDESC(),Subs(cCodInt,1,ntCodOpe),BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})

			Next

		Endif

		If !lLoadRda
			Return({.F.,aCodCri})
		Else
			lRet 	:= .F.
			aRetFun 	:= {.F.,aCodCri}
		EndIf

	Endif

	//Seja qual for o metodo de pesquisa deve se posicionar no BAU...
	If cTipo == "1" .And. lRet

		BAU->(DbSetOrder(1))
		If ! BAU->(MsSeek(xFilial("BAU")+cCodigo))

			PLSPOSGLO(PLSINTPAD(),__aCdCri013[1],__aCdCri013[2])

			If Len(aBD6) == 0

				aadd(aCodCri,{__aCdCri013[1],PLSBCTDESC(),cCodigo,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})

			Else

				For nFor := 1 To Len(aBD6)

					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]

					aadd(aCodCri,{__aCdCri013[1],PLSBCTDESC(),cCodigo,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})

				Next

			Endif

			If !lLoadRda
				Return({.F.,aCodCri})
			Else
				lRet 	  := .F.
				aRetFun := {.F.,aCodCri}
			EndIf

		Endif

	Endif
	// Quando for uma prorrogação de Internação, verifica se a internação foi feita antes do bloqueio, caso seja permite o RDA
	If Empty(BAU->BAU_CODBLO) .OR. BAU->BAU_DATBLO > dDatabase .OR. IIF(lProrInt, IIF(dData <= BAU->BAU_DATBLO,.T.,.F.),.F.) .OR. lShallPass;
	.or. (!empty(BAU->BAU_DATBLO) .and. dData <= BAU->BAU_DATBLO)

		aRetBAW := PLSVldBAW(cCodInt,aBD6,aCodCri,cCodPad,cCodPro,lLoadRda,dData,cCodigo)

		If ! aRetBAW[1]
			Return(aRetBAW)
		Endif

		If lRet

			aRetFun := PLSVDLOCRD(BAU->BAU_CODIGO,cCodInt,dData,cCodLoc,cCodPad,cCodPro,aBD6)

			If !aRetFun[1]

				If !lLoadRda
					Return(aRetFun)
				Else
					lRet := .F.
				EndIf

			EndIf

		EndIf

		If lRet

			aRetFun := PLSVDESPRD(BAU->BAU_CODIGO,cCodInt,BB8->BB8_CODLOC,cCodEsp,dData,cCodPad,cCodPro,aBD6,cEspSol,cEspExe,lDesEsp)

			If !aRetFun[1]

				If !lLoadRda
					aDadRDA := {} //Quando era importação pelo Robô a static estava preenchida com os dados da RDA anterior e gravava o BD5_CODRDA errado
					Return(aRetFun)
				Else
					lRet := .F.
				EndIf

			EndIf

			//"1" Checar executante
			//"0" Nao checar executante e sim na especialidade da RDA da guia...
			cTrtExe := BB8->BB8_TRTEXE

			If Empty(cTrtExe)
				cTrtExe := "1"
			Endif

			//Monta caracterizacao desse local de atendimento para a rda...
			aCarRDA := PLSRDAREF('BBK',BAU->BAU_CODIGO+cCodInt+BB8->BB8_CODLOC+BAX->BAX_CODESP)

		EndIf

		//Verifica se e uma RDA de intercambio...
		lRDAInt := ( BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE") )

		//Monta retorno...
		aRet := {.T.,;				//01
			BAU->BAU_CODIGO,;	//02
			BAW->BAW_CODANT,;	//03
			BAU->(BAU->BAU_ESTCR+BAU->BAU_CONREG+BAU->BAU_SIGLCR),;//04
			BAU->BAU_CODBB0,;	//05
			BAU->BAU_NOME,;	//06
			BAU->BAU_NREDUZ,;	//07
			BAU->BAU_TIPPE,;	//08
			BAU->BAU_DATBLO,;	//09
			BAU->BAU_CODBLO,;	//10
			.F.,;				//11
			BB8->BB8_CODLOC,;	//12
			BB8->BB8_LOCAL,;	//13
			cCodInt,;			//14
			BAX->BAX_CODESP,;	//15
			BAU->BAU_CPFCGC,;	//16
			BAQ->BAQ_DESCRI,;	//17
			BB8->(BB8_CODLOC+BB8_LOCAL),;//18
			BB8->BB8_DESLOC,;	//19
			AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO),;//20
			BAX->BAX_CODSUB,;	//21
			BA0->BA0_GRUOPE,;	//22
			BB8->BB8_OBRCLI,;	//23
			cTrtExe,;			//24
			BAU->BAU_CATHOS,;	//25
			aCarRDA,;			//26
			BAU->BAU_TIPPRE,;	//27
			BAU->BAU_CODOPE,;	//28
			lRdaInt,;			//29
			BAU->BAU_ALTCUS,; //30
			BAU->BAU_SIGLCR,; //31
			BAU->BAU_CONREG,;//32
			Iif(BAU->(FieldPos("BAU_ACEPAR") ) > 0,BAU->BAU_ACEPAR,"0"),; //33
			Iif(BAU->(FieldPos("BAU_QTDUS")  ) > 0,BAU->BAU_QTDUS, 0 )}   //34

		aDadRda := aClone(aRet)

		If !lRet
			aRet := aClone(aRetFun)
		EndIf
	Else
		PLSPOSGLO(PLSINTPAD(),__aCdCri005[1],__aCdCri005[2])
		If Len(aBD6) == 0

			aadd(aCodCri,{__aCdCri005[1],PLSBCTDESC(),cCodigo,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
		Else
			For nFor := 1 To Len(aBD6)
				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]
				aadd(aCodCri,{__aCdCri005[1],PLSBCTDESC(),cCodigo,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			Next
		Endif
		If !lLoadRda
			Return({.F.,aCodCri})
		Else
			lRet 	  := .F.
			aRetFun := {.F.,aCodCri}
		EndIf

	EndIf

Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsRDAOpe   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Grava RDA da operadora                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRDAOpe(cOpeRda,cCodRda,cNomRda,cEstCr,cSigCr,cNumCr)

	BM3->(DbSetOrder(1))
	If ! BM3->(MsSeek(xFilial("BM3")+cOpeRda+cOpeRda))
		BM3->(RecLock("BM3",.T.))
		BM3->BM3_CODINT := cOpeRda
		BM3->BM3_MATRIC := cCodRda
		BM3->BM3_NOMCRE := cNomRda
		BM3->BM3_ESTCR  := cEstCr
		BM3->BM3_SIGCR  := cSigCr
		BM3->BM3_NUMCR  := cNumCr
		BM3->(MsUnLock())
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsRtCdUsr  ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRtCdUsr()

	//Para garantir que tem uma arae aberta
	If Select("BA0") = 0
		ChkFile("BA0")
	Else
		dbSelectArea("BA0")
	Endif
return( strZero( val(RetCodUsr()),6) )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsConCri   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSConCri(cDado)
	LOCAL nPos := AsCan(__aTipCri,{|x| x[1] == cDado})
Return(__aTipCri[nPos,2])
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSESPNIV³ Autor ³ Tulio Cesar        Data ³ 24.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Espelha os niveis de acordo com a Tabela de honorarios...  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSESPNIV(cCdTbPd)
	LOCAL aNivRet 	:= { 0, {} }, aNiveis := {}
	LOCAL nInd    	:= 0
	LOCAL nMax    	:= 0
	LOCAL nJ 	  	:= 0
	LOCAL nI 	  	:= 1
	LOCAL nPos    	:= 0
	LOCAL nCap 		:= 1
	LOCAL lTeDig  	:= .f.
	LOCAL aFunRet 	:= {}
	local cFilBR4 	:= xFilial("BR4")

	nPos := aScan(__aTipTab,{ |x| x[1] == cCdTbPd })

	if nPos == 0

		BR4->(DbSetOrder(1))
		BR4->(MsSeek(cFilBR4+cCdTbPd))

		while ! BR4->(eof()) .And. BR4->(BR4_FILIAL+BR4_CODPAD) == cFilBR4+cCdTbPd

			aadd(aNiveis,val(BR4->BR4_DIGITO))

			// tratamento para codigos que nao tenha digitos
			if BR4->BR4_DIGVER <> '0' .and. ! empty(BR4->BR4_DIGVER)
				lTeDig := .t.
			endIf

			BR4->( DbSkip() )
		endDo

		//TODO - 04/10/2018 - Deve ser alterado o tamanho dos campos para 8
		//Depois deste ajuste sera necessario realizar um ajuste na base para gravar corretamente o capitulo
		//esta rotina deve desconsiderar somente o digito e realizar sempre a gravacao dos niveis conforme o nivel
		//da BR8 para que nao seja mais necessario ficar acrescentando mais 1 na aNIVEIS.
		//nao esta gravando corretamente para CBHPM nem para AMB

		//CODPRO  - 10102019	- EVENTO
		//CDNIV01 - 1010201		- ITEM		- NIVEL 4 MASCARA 1.01.02.01 - 02
		//CDNIV02 - 10102		- SUBGRUPO	- NIVEL 3 MASCARA 1.01.02	 - 02
		//CDNIV03 - 101			- GRUPO		- NIVEL 2 MASCARA 1.01		 - 02
		//CDNIV04 - 1			- CAPITULO	- NIVEL 1 MASCARA 1			 - 01

		//AMB 	- 00.01.001-4  (GRUPO, SUBGRUPO, ITEM E DIGITO)
		//CBHPM - 1.01.02.01-9 (CAPITULO, GRUPO, SUBGRUPO, ITEM E DIGITO)

		//ajuste para retirar o capitulo pode ser retirado quando implementado o TODO
		nCap := iIf(lTeDig, 2, nCap)

		for nInd := len(aNiveis) - nCap to 1 step - 1

			nI := nInd
			while nI >= 1
				nJ += aNiveis[nI]
				nI--
			endDo

			aadd(aNivRet[2],{1, nJ, str(nInd, 1), "" })

			aNivRet[1] ++
			nJ := 0

		next

		nMax := len(aNivRet[2])
		nInd := 1

		while nMax >= nInd
			aNivRet[2,nInd,4] := "CDNV0" + strZero(nInd,1)
			nInd ++
		endDo

		aadd(__aTipTab,{cCdTbPd,aNivRet})

		aFunRet := aClone(aNivRet)

	else

		aFunRet := aClone(__aTipTab[nPos,2])

	endIf

return(aFunRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsGatNiv   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGatNiv(cCodTab,cCodPro,cAlias,lMemory,lNivel,nRecnoBd6,cStruct)
	LOCAL aRet    	:= PLSESPNIV(cCodTab)
	LOCAL cMacro  	:= ""
	LOCAL nInd    	:= 0
	LOCAL nOrdBR8 	:= 0
	LOCAL nPosBR8 	:= 0
	LOCAL nMVC		:= 1
	LOCAL aMVC	  	:= {}
	LOCAL oGatNiv

	DEFAULT lMemory   := .f.
	DEFAULT lNivel	  := .f.
	DEFAULT nRecnoBd6 := 0
	DEFAULT cStruct	  := ""

	If !Empty(cStruct)
		oGatNiv	:= FWModelActive()
	EndIf

	//Tratar Situacao Adversa x Regra no Contas Medicas
	If nRecnoBd6 > 0
		PLSSITADV(cCodTab,cCodPro,nRecnoBd6)
	Endif

	If !lMemory

		For nInd := 1 To aRet[1]

			cMacro     := "M->"+cAlias+"_CDNV0"+StrZero(nInd,1)
			&(cMacro)  := subs(cCodPro,aRet[2,nInd,1],aRet[2,nInd,2])

			If !Empty(cStruct)
				aadd(aMVC,{ cAlias+"_CDNV0"+StrZero(nInd,1), Subs(cCodPro,aRet[2,nInd,1],aRet[2,nInd,2]) } )
			EndIf

		Next

		If lNivel

			nOrdBR8 := BR8->(IndexOrd())
			nPosBR8 := BR8->(Recno())

			BR8->(DbSetOrder(1))
			BR8->(MsSeek(xFilial("BR8")+cCodTab+cCodPro))

			cMacro     := "M->"+cAlias+"_NIVEL"
			&(cMacro)  := BR8->BR8_NIVEL

			BR8->(DbSetOrder(nOrdBR8))
			BR8->(DbGoTo(nPosBR8))

		Endif

	Else

		For nInd := 1 To aRet[1]

			cMacro     := cAlias+"->"+cAlias+"_CDNV0"+StrZero(nInd,1)
			&(cMacro)  := Subs(cCodPro,aRet[2,nInd,1],aRet[2,nInd,2])

			If !Empty(cStruct)
				aadd(aMVC,{ cAlias+"_CDNV0"+StrZero(nInd,1), Subs(cCodPro,aRet[2,nInd,1],aRet[2,nInd,2]) } )
			EndIf

		Next

		If lNivel

			nOrdBR8 := BR8->(IndexOrd())
			nPosBR8 := BR8->(Recno())

			BR8->(DbSetOrder(1))
			BR8->(MsSeek(xFilial("BR8")+cCodTab+cCodPro))

			cMacro     := cAlias+"->"+cAlias+"_NIVEL"
			&(cMacro)  := BR8->BR8_NIVEL

			BR8->(DbSetOrder(nOrdBR8))
			BR8->(DbGoTo(nPosBR8))

		Endif

	Endif

	For nMVC := 1 To Len(aMVC)
		oGatNiv:LoadValue( cStruct, aMVC[nMVC][1], aMVC[nMVC][2] )
	Next

	lRefresh := .T.

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsUpCpoNv  ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSUpCpoNv(cCodTab,cCodPro,cAlias)
	LOCAL aRet    := PLSESPNIV(cCodTab)
	LOCAL nInd
	LOCAL cMacro
	LOCAL aRetFun    := {}

	For nInd := 1 To aRet[1]
		cMacro     := cAlias+"->"+cAlias+"_CDNV0"+StrZero(nInd,1)
		aadd(aRetFun,{cMacro,Subs(cCodPro,aRet[2,nInd,1],aRet[2,nInd,2])})
	Next

Return(aRetFun)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsPRNFld   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSPRNFld(aCampos)
	LOCAL aRet := {}
	LOCAL nInd

	For nInd := 1 To Len(aCampos)
		SX3->(DbSetOrder(2))
		If SX3->(MsSeek(aCampos[nInd,1]))

			If Empty(SX3->X3_CBOX)
				aadd(aRet,X3TITULO()+" : "+TransForm(aCampos[nInd,2],AllTrim(SX3->X3_PICTURE)))
			Else
				aadd(aRet,X3TITULO()+" : "+X3COMBO(aCampos[nInd,1],aCampos[nInd,2]))
			Endif
		Endif
	Next

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³PLSPARANA ³ Autor ³ J£lio Wittwer      Data ³ 17.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Realiza an lise estrutural de par?metros / delimitadores   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ParAnalise(cExpressao)                                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Vetor [1] cStack -> Se preenchido, indica qual caracter na ³±±
±±³       estrutura n?o est  coerente com a mesma.               ±±
±±³       Vetor [2] aParam -> Array com os textos correspondentes±±
±±³       dentro das estruturas.                                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   CTBA080                                                ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ expC1 = Texto a ser analisado.                         ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSParAna(cTexto)
	Local cStack:=""  , cAspas:=""
	Local aSepFunc:={"()","[]","{}"}, aParam:={}
	Local nPosAt:=1 , uLastPar:=1 , cPosAtual
	Local uAbre , uFecha , cSeparador:=","
	// Arranca os caracteres da esquerda se forem 'espa?o' ou 'TAB'
	While left(cTexto,1)==" " .or. left(cTexto,1)==chr(9)
		cTexto:=right(cTexto,len(cTexto)-1)
	EndDo
	While nPosAt<=len(cTexto)
		cPosAtual:=substr(cTexto,nPosAt,1)
		If cPosAtual==chr(34) .or. cPosAtual==chr(39)	// Achou "ASPAS"
			cAspas:=If(empty(cAspas),cPosAtual,If(cAspas == cPosAtual,"",cAspas))
		Endif
		If empty(cAspas)			// Apenas analiza a estrutura caso nao esteja entre aspas
			uAbre :=ascan(aSepFunc,{|_v|  left(_v,1) == cPosAtual})
			uFecha:=ascan(aSepFunc,{|_v| right(_v,1) == cPosAtual})
			If uAbre+uFecha>0		// Abriu ou Fechou uma estrutura
				If uAbre>0	// Abriu uma estrutura ! Acrescenta no STACK
					If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
						aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
					Endif
					uLastPar:=nPosAt+1	 ; cStack:=cStack+cPosAtual
				Else			// Fechou uma estrutura : Checa o STACK
					If right(cStack,1)==Left(aSepFunc[uFecha],1)	// Se fechou certo, tira do Stack
						cStack:=left(cStack,len(cStack)-1)
					Else	// Estrutura fechada incorretamente
						cStack:=right(aSepFunc[uFecha],1)
						EXIT
					Endif
					If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
						aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
					Endif
					uLastPar:=nPosAt+1
				Endif
			Else	// Verifica separador
				If cPosAtual==cSeparador
					aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
					uLastPar:=nPosAt+1
				Endif
			Endif
		Endif
		nPosAt++
	EndDo
	IF !empty(cTexto) .and. len(aParam) == 0
		aadd(aParam,alltrim(cTexto))
	Endif
	cStack+=if(empty(cAspas),"",cAspas)
Return {cStack,aParam}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSEXPIVL³ Autor ³ Tulio Cesar        Data ³ 24.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o valor de uma identificacao (Cartao Magnetico)±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSEXPIVL(	cCodInt,cCodEmp,cConEmp,cVerCon,cCodPla,cVerPla,cTipoGru,nViaTot,;
		cTipUsr,cGrauPar,cMatric,cTipReg,cSUBCON,cVERSUB,cMotivo)
	LOCAL cSQL, cArea := Alias()
	LOCAL cBJAName 	:= BJA->(RetSQLName("BJA"))
	LOCAL cFilBJA  	:= xFilial("BJA")
	LOCAL cBJBName 	:= BJB->(RetSQLName("BJB"))
	LOCAL cFilBJB  	:= xFilial("BJB")
	LOCAL cBJCName 	:= BJC->(RetSQLName("BJC"))
	LOCAL cFilBJC  	:= xFilial("BJC")
	LOCAL aValor   	:= { 0, "0", "", "", "", "", 0, .T., 0, "", cCodInt,cCodEmp,cMatric,cTipReg }
	LOCAL lFound   	:= .F., nVia := 0
	Local aVetor	:= {}, nOldMod
	Local aNumero	:= {}
	Local aArea     := GetArea()

	cSQL := "SELECT COUNT(*) CONTADOR FROM "+BED->(RetSQLName("BED"))+" WHERE "
	cSQL += "BED_FILIAL = '"+xFilial("BED")+"' AND "
	cSQL += "BED_CODINT = '"+cCodInt+"' AND "
	cSQL += "BED_CODEMP = '"+cCodEmp+"' AND "
	cSQL += "BED_MATRIC = '"+cMatric+"' AND "
	cSQL += "BED_TIPREG = '"+cTipReg+"' AND "
	cSQL += "BED_CONEMP = '"+cConEmp+"' AND "
	cSQL += "BED_VERCON = '"+cVerCon+"' AND "
	cSQL += "BED_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BED_VERSUB = '"+cVerSub+"' AND "
	cSQL += "BED_MOTIVO = '"+cMotivo+"' AND "
	cSQL += "BED_DTSOLI <= '"+Dtos(dDataBase)+"' AND D_E_L_E_T_ = ''"

	PLSQuery(cSQL,"TrbBED")
	nVia := TrbBED->CONTADOR + 1
	aValor[7] := nVia
	TrbBED->(DbCloseArea())
	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Se for do pessoa juridica procuro algo nos contratos...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoGru == "2" .And. ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Procura no Nivel Sub-Contrato - BJC
		//O sistema ira buscar a parametrizacao na seguinte ordem:  ³
		//                 |  Tipo Usuario  ³  Grau Parentesco
		//      Preechido  |       Sim            Sim
		//                 |       Nao            Sim
		//                 |       Sim            Nao
		//                 |       Nao            Nao
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Sub-Contrato - Tp Usuario Preenchido / Grau Parentesco Preenchido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJC_VALOR, BJC_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJCName+" WHERE "
		cSQL += "BJC_FILIAL = '"+cFilBJC+"' AND "
		cSQL += "BJC_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJC_CODEMP = '"+cCodEmp+"' AND "
		cSQL += "BJC_NUMCON = '"+cConEmp+"' AND "
		cSQL += "BJC_VERCON = '"+cVerCon+"' AND "
		cSQL += "BJC_SUBCON = '"+cSubCon+"' AND "
		cSQL += "BJC_VERSUB = '"+cVerSub+"' AND "
		cSQL += "BJC_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJC_TIPUSR = '"+cTipUsr+"' AND "
		cSQL += " BJC_GRAUPA = '"+cGrauPar+"') AND "
		cSQL += Str(nVia)+" >= BJC_EMIDE AND "+Str(nVia)+" <= BJC_EMIATE AND "
		cSQL += cBJCName+".D_E_L_E_T_ = ''"
		PLSQuery(cSQL,"TrbBJC")

		If !  TrbBJC->(Eof())
			aValor[1] 	:= TrbBJC->BJC_VALOR
			aValor[2] 	:= TrbBJC->BJC_COBRAR
			aValor[9]   := TrbBJC->REG
			aValor[10]  := "BJC"
			lFound 		:= .T.
		Endif
		TrbBJC->(DbCloseArea())
		RestArea(aArea)

		If ! lFound
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Nivel Sub-Contrato - Tp Usuario Vazio / Grau Parentesco Preenchido
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := "SELECT BJC_VALOR, BJC_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJCName+" WHERE "
			cSQL += "BJC_FILIAL = '"+cFilBJC+"' AND "
			cSQL += "BJC_CODINT = '"+cCodInt+"' AND "
			cSQL += "BJC_CODEMP = '"+cCodEmp+"' AND "
			cSQL += "BJC_NUMCON = '"+cConEmp+"' AND "
			cSQL += "BJC_VERCON = '"+cVerCon+"' AND "
			cSQL += "BJC_SUBCON = '"+cSubCon+"' AND "
			cSQL += "BJC_VERSUB = '"+cVerSub+"' AND "
			cSQL += "BJC_MOTIVO = '"+cMotivo+"' AND "
			cSQL += "(BJC_TIPUSR = '"+Space(Len(cTipUsr))+"' AND "
			cSQL += " BJC_GRAUPA = '"+cGrauPar+"') AND "
			cSQL += Str(nVia)+" >= BJC_EMIDE AND "+Str(nVia)+" <= BJC_EMIATE AND "
			cSQL += cBJCName+".D_E_L_E_T_ = ''"
			PLSQuery(cSQL,"TrbBJC")

			If !  TrbBJC->(Eof())
				aValor[1] 	:= TrbBJC->BJC_VALOR
				aValor[2] 	:= TrbBJC->BJC_COBRAR
				aValor[9]   := TrbBJC->REG
				aValor[10]  := "BJC"
				lFound 		:= .T.
			Endif
			TrbBJC->(DbCloseArea())
			RestArea(aArea)
		Endif

		If ! lFound
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Nivel Sub-Contrato - Tp Usuario Preenchido / Grau Parentesco Vazio
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := "SELECT BJC_VALOR, BJC_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJCName+" WHERE "
			cSQL += "BJC_FILIAL = '"+cFilBJC+"' AND "
			cSQL += "BJC_CODINT = '"+cCodInt+"' AND "
			cSQL += "BJC_CODEMP = '"+cCodEmp+"' AND "
			cSQL += "BJC_NUMCON = '"+cConEmp+"' AND "
			cSQL += "BJC_VERCON = '"+cVerCon+"' AND "
			cSQL += "BJC_SUBCON = '"+cSubCon+"' AND "
			cSQL += "BJC_VERSUB = '"+cVerSub+"' AND "
			cSQL += "BJC_MOTIVO = '"+cMotivo+"' AND "
			cSQL += "(BJC_TIPUSR = '"+cTipUsr+"' AND "
			cSQL += " BJC_GRAUPA = '"+Space(Len(cGrauPar))+"') AND "
			cSQL += Str(nVia)+" >= BJC_EMIDE AND "+Str(nVia)+" <= BJC_EMIATE AND "
			cSQL += cBJCName+".D_E_L_E_T_ = ''"
			PLSQuery(cSQL,"TrbBJC")

			If !  TrbBJC->(Eof())
				aValor[1] 	:= TrbBJC->BJC_VALOR
				aValor[2] 	:= TrbBJC->BJC_COBRAR
				aValor[9]   := TrbBJC->REG
				aValor[10]  := "BJC"
				lFound 		:= .T.
			Endif
			TrbBJC->(DbCloseArea())
			RestArea(aArea)
		Endif

		If ! lFound
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Nivel Sub-Contrato - Tp Usuario Vazio / Grau Parentesco Vazio
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := "SELECT BJC_VALOR, BJC_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJCName+" WHERE "
			cSQL += "BJC_FILIAL = '"+cFilBJC+"' AND "
			cSQL += "BJC_CODINT = '"+cCodInt+"' AND "
			cSQL += "BJC_CODEMP = '"+cCodEmp+"' AND "
			cSQL += "BJC_NUMCON = '"+cConEmp+"' AND "
			cSQL += "BJC_VERCON = '"+cVerCon+"' AND "
			cSQL += "BJC_MOTIVO = '"+cMotivo+"' AND "
			cSQL += "BJC_SUBCON = '"+cSubCon+"' AND "
			cSQL += "BJC_VERSUB = '"+cVerSub+"' AND "
			cSQL += "(BJC_TIPUSR = '"+Space(Len(cTipUsr))+"' AND "
			cSQL += " BJC_GRAUPA = '"+Space(Len(cGrauPar))+"') AND "
			cSQL += Str(nVia)+" >= BJC_EMIDE AND "+Str(nVia)+" <= BJC_EMIATE AND "
			cSQL += cBJCName+".D_E_L_E_T_ = ''"
			PLSQuery(cSQL,"TrbBJC")

			If !  TrbBJC->(Eof())
				aValor[1] 	:= TrbBJC->BJC_VALOR
				aValor[2] 	:= TrbBJC->BJC_COBRAR
				aValor[9]   := TrbBJC->REG
				aValor[10]  := "BJC"
				lFound 		:= .T.
			Endif
			TrbBJC->(DbCloseArea())
			RestArea(aArea)
		Endif

	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Procura no Nivel Produto - BJB
	//O sistema ira buscar a parametrizacao na seguinte ordem:  ³
	//                 |  Tipo Usuario  ³  Grau Parentesco
	//      Preechido  |       Sim            Sim
	//                 |       Nao            Sim
	//                 |       Sim            Nao
	//                 |       Nao            Nao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Produto - Tp Usuario Preenchido / Grau Parentesco Preenchido
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJB_VALOR, BJB_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJBName+" WHERE "
		cSQL += "BJB_FILIAL = '"+cFilBJB+"' AND "
		cSQL += "BJB_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJB_CODIGO = '"+cCodPla+"' AND "
		cSQL += "BJB_VERSAO = '"+cVerPla+"' AND "
		cSQL += "BJB_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJB_TIPUSR = '"+cTipUsr+"' AND "
		cSQL += " BJB_GRAUPA = '"+cGrauPar+"') AND "
		cSQL += Str(nVia)+" >= BJB_EMIDE AND "+Str(nVia)+" <= BJB_EMIATE AND "
		cSQL += cBJBName+".D_E_L_E_T_ = ''"
		PLSQuery(cSQL,"TrbBJB")

		If !  TrbBJB->(Eof())
			aValor[1] 	:= TrbBJB->BJB_VALOR
			aValor[2] 	:= TrbBJB->BJB_COBRAR
			aValor[9]   := TrbBJB->REG
			aValor[10]  := "BJB"
			lFound 		:= .T.
		Endif
		TrbBJB->(DbCloseArea())
		RestArea(aArea)
	Endif

	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Produto - Tp Usuario Vazio / Grau Parentesco Preenchido
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJB_VALOR, BJB_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJBName+" WHERE "
		cSQL += "BJB_FILIAL = '"+cFilBJB+"' AND "
		cSQL += "BJB_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJB_CODIGO = '"+cCodPla+"' AND "
		cSQL += "BJB_VERSAO = '"+cVerPla+"' AND "
		cSQL += "BJB_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJB_TIPUSR = '"+Space(Len(cTipUsr))+"' AND "
		cSQL += " BJB_GRAUPA = '"+cGrauPar+"') AND "
		cSQL += Str(nVia)+" >= BJB_EMIDE AND "+Str(nVia)+" <= BJB_EMIATE AND "
		cSQL += cBJBName+".D_E_L_E_T_ = ''"
		PLSQuery(cSQL,"TrbBJB")

		If !  TrbBJB->(Eof())
			aValor[1] 	:= TrbBJB->BJB_VALOR
			aValor[2] 	:= TrbBJB->BJB_COBRAR
			aValor[9]   := TrbBJB->REG
			aValor[10]  := "BJB"
			lFound 		:= .T.
		Endif
		TrbBJB->(DbCloseArea())
		RestArea(aArea)
	Endif

	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Produto - Tp Usuario Preenchido / Grau Parentesco Vazio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJB_VALOR, BJB_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJBName+" WHERE "
		cSQL += "BJB_FILIAL = '"+cFilBJB+"' AND "
		cSQL += "BJB_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJB_CODIGO = '"+cCodPla+"' AND "
		cSQL += "BJB_VERSAO = '"+cVerPla+"' AND "
		cSQL += "BJB_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJB_TIPUSR = '"+cTipUsr+"' AND "
		cSQL += " BJB_GRAUPA = '"+Space(Len(cGrauPar))+"') AND "
		cSQL += Str(nVia)+" >= BJB_EMIDE AND "+Str(nVia)+" <= BJB_EMIATE AND "
		cSQL += cBJBName+".D_E_L_E_T_ = ''"
		PLSQuery(cSQL,"TrbBJB")

		If !  TrbBJB->(Eof())
			aValor[1] 	:= TrbBJB->BJB_VALOR
			aValor[2] 	:= TrbBJB->BJB_COBRAR
			aValor[9]   := TrbBJB->REG
			aValor[10]  := "BJB"
			lFound 		:= .T.
		Endif
		TrbBJB->(DbCloseArea())
		RestArea(aArea)
	Endif

	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Produto - Tp Usuario Vazio / Grau Parentesco Vazio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJB_VALOR, BJB_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJBName+" WHERE "
		cSQL += "BJB_FILIAL = '"+cFilBJB+"' AND "
		cSQL += "BJB_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJB_CODIGO = '"+cCodPla+"' AND "
		cSQL += "BJB_VERSAO = '"+cVerPla+"' AND "
		cSQL += "BJB_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJB_TIPUSR = '"+Space(Len(cTipUsr))+"' AND "
		cSQL += " BJB_GRAUPA = '"+Space(Len(cGrauPar))+"') AND "
		cSQL += Str(nVia)+" >= BJB_EMIDE AND "+Str(nVia)+" <= BJB_EMIATE AND "
		cSQL += cBJBName+".D_E_L_E_T_ = ''"
		PLSQuery(cSQL,"TrbBJB")

		If !  TrbBJB->(Eof())
			aValor[1] 	:= TrbBJB->BJB_VALOR
			aValor[2] 	:= TrbBJB->BJB_COBRAR
			aValor[9]   := TrbBJB->REG
			aValor[10]  := "BJB"
			lFound 		:= .T.
		Endif
		TrbBJB->(DbCloseArea())
		RestArea(aArea)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Procura no Nivel Operadora - BJA
	//O sistema ira buscar a parametrizacao na seguinte ordem:  ³
	//                 |  Tipo Usuario  ³  Grau Parentesco
	//      Preechido  |       Sim            Sim
	//                 |       Nao            Sim
	//                 |       Sim            Nao
	//                 |       Nao            Nao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Operadora - Tp Usuario Preenchido / Grau Parentesco Preenchido   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJA_VALOR, BJA_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJAName+" WHERE "
		cSQL += "BJA_FILIAL = '"+cFilBJA+"' AND "
		cSQL += "BJA_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJA_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJA_TIPUSR = '"+cTipUsr+"' AND "
		cSQL += " BJA_GRAUPA = '"+cGrauPar+"') AND "
		cSQL += Str(nVia)+" >= BJA_EMIDE AND "+Str(nVia)+" <= BJA_EMIATE AND "
		cSQL += "  (BJA_VIGINI <= '"+DTOS(dDataBase)+"' OR BJA_VIGINI = ' ' ) AND "
		cSQL += "  (BJA_VIGFIN >= '"+DTOS(dDataBase)+"' OR BJA_VIGFIN = ' ') AND "
		cSQL += cBJAName+".D_E_L_E_T_ = ''"

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBJA",.F.,.T.)

		If !  TrbBJA->(Eof())
			aValor[1] 	:= TrbBJA->BJA_VALOR
			aValor[2] 	:= TrbBJA->BJA_COBRAR
			aValor[9]   := TrbBJA->REG
			aValor[10]  := "BJA"
			lFound 		:= .T.
		Endif
		TrbBJA->(DbCloseArea())
		RestArea(aArea)
	Endif

	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Operadora - Tp Usuario Vazio  / Grau Parentesco Preenchido
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJA_VALOR, BJA_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJAName+" WHERE "
		cSQL += "BJA_FILIAL = '"+cFilBJA+"' AND "
		cSQL += "BJA_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJA_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJA_TIPUSR = '"+Space(Len(cTipUsr))+"' AND "
		cSQL += " BJA_GRAUPA = '"+cGrauPar+"') AND "
		cSQL += Str(nVia)+" >= BJA_EMIDE AND "+Str(nVia)+" <= BJA_EMIATE AND "
		cSQL += "  (BJA_VIGINI <= '"+DTOS(dDataBase)+"' OR BJA_VIGINI = ' ' ) AND "
		cSQL += "  (BJA_VIGFIN >= '"+DTOS(dDataBase)+"' OR BJA_VIGFIN = ' ') AND "
		cSQL += cBJAName+".D_E_L_E_T_ = ''"

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBJA",.F.,.T.)

		If !  TrbBJA->(Eof())
			aValor[1] 	:= TrbBJA->BJA_VALOR
			aValor[2] 	:= TrbBJA->BJA_COBRAR
			aValor[9]   := TrbBJA->REG
			aValor[10]  := "BJA"
			lFound 		:= .T.
		Endif
		TrbBJA->(DbCloseArea())
		RestArea(aArea)
	Endif

	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Operadora - Tp Usuario Preenchido / Grau Parentesco Vazio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJA_VALOR, BJA_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJAName+" WHERE "
		cSQL += "BJA_FILIAL = '"+cFilBJA+"' AND "
		cSQL += "BJA_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJA_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJA_TIPUSR = '"+cTipUsr+"' AND "
		cSQL += " BJA_GRAUPA = '"+Space(Len(cGrauPar))+"') AND "
		cSQL += Str(nVia)+" >= BJA_EMIDE AND "+Str(nVia)+" <= BJA_EMIATE AND "
		cSQL += "  (BJA_VIGINI <= '"+DTOS(dDataBase)+"' OR BJA_VIGINI = ' ' ) AND "
		cSQL += "  (BJA_VIGFIN >= '"+DTOS(dDataBase)+"' OR BJA_VIGFIN = ' ') AND "
		cSQL += cBJAName+".D_E_L_E_T_ = ''"

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBJA",.F.,.T.)

		If !  TrbBJA->(Eof())
			aValor[1] 	:= TrbBJA->BJA_VALOR
			aValor[2] 	:= TrbBJA->BJA_COBRAR
			aValor[9]   := TrbBJA->REG
			aValor[10]  := "BJA"
			lFound 		:= .T.
		Endif
		TrbBJA->(DbCloseArea())
		RestArea(aArea)
	Endif

	If ! lFound
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Nivel Operadora - Tp Usuario Vazio / Grau Parentesco Vazio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BJA_VALOR, BJA_COBRAR, R_E_C_N_O_ AS REG FROM "+cBJAName+" WHERE "
		cSQL += "BJA_FILIAL = '"+cFilBJA+"' AND "
		cSQL += "BJA_CODINT = '"+cCodInt+"' AND "
		cSQL += "BJA_MOTIVO = '"+cMotivo+"' AND "
		cSQL += "(BJA_TIPUSR = '"+Space(Len(cTipUsr))+"' AND "
		cSQL += " BJA_GRAUPA = '"+Space(Len(cGrauPar))+"') AND "
		cSQL += Str(nVia)+" >= BJA_EMIDE AND "+Str(nVia)+" <= BJA_EMIATE AND "
		cSQL += "  (BJA_VIGINI <= '"+DTOS(dDataBase)+"' OR BJA_VIGINI = ' ' ) AND "
		cSQL += "  (BJA_VIGFIN >= '"+DTOS(dDataBase)+"' OR BJA_VIGFIN = ' ') AND "
		cSQL += cBJAName+".D_E_L_E_T_ = ''"
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBJA",.F.,.T.)

		If !  TrbBJA->(Eof())
			aValor[1] 	:= TrbBJA->BJA_VALOR
			aValor[2] 	:= TrbBJA->BJA_COBRAR
			aValor[9]   := TrbBJA->REG
			aValor[10]  := "BJA"
			lFound 		:= .T.
		Endif
		TrbBJA->(DbCloseArea())
		RestArea(aArea)
	Endif

	If ExistBlock("PLSCTVL")
		aValor := ExecBlock("PLSCTVL",.F.,.F.,{aValor,cCodInt,cCodEmp,cConEmp,cVerCon,cCodPla,cVerPla,cTipoGru,nViaTot,;
			cTipUsr,cGrauPar,cMatric,cTipReg,cSUBCON,cVERSUB,cMotivo})
	Endif

	If aValor[1] > 0 .And. aValor[2] = "2"		// Direto para o usuario

		aNumero 	:= PLSA625MDa(Str(Year(dDataBase), 4),StrZero(Month(dDataBase), 2),"1","6")
		BA3->(MsSeek(xFilial("BA3") + cCodInt + cCodEmp + cMatric))
		aCliente 	:= PLSAVERNIV(	cCodInt,cCodEmp,cMatric,BA3->BA3_TIPOUS,cConEmp,cVerCon,cSubCon,cVerSub,1,cTipReg)

		aVetor :={ 	{"E1_PREFIXO", aNumero[1],Nil},;
			{"E1_NUM", aNumero[2],Nil},;
			{"E1_PARCELA", Space(Len(SE1->E1_PARCELA)),Nil},;
			{"E1_TIPO", GetMv("MV_PLSTIP", .F., "DP "),Nil},;
			{"E1_CLIENTE", aCliente[1][1],Nil},;
			{"E1_LOJA", aCliente[1][2],Nil},;
			{"E1_VENCTO"   ,dDataBase,Nil},;
			{"E1_VENCREA"   ,DataValida(dDataBase),Nil},;
			{"E1_EMISSAO"  ,dDataBase,Nil},;
			{"E1_NATUREZ"  ,GetMv("MV_PLSNAT", .F., "PLS"),Nil},;
			{"E1_VALOR"    ,aValor[1],Nil},;
			{"E1_SALDO"    ,aValor[1],Nil},;
			{"E1_ANOBASE"  ,Str(Year(dDataBase), 4),Nil},;
			{"E1_MESBASE"  ,StrZero(Month(dDataBase), 2),Nil},;
			{"E1_CODINT"   ,cCodInt,Nil},;
			{"E1_CODEMP"   ,cCodEmp,Nil},;
			{"E1_MATRIC"   ,cMatric,Nil},;
			{"E1_TIPREG"   ,cTipReg,Nil},;
			{"E1_CONEMP"   ,cConEmp,Nil},;
			{"E1_VERCON"   ,cVerCon,Nil},;
			{"E1_SUBCON"   ,cSubCon,Nil},;
			{"E1_VERSUB"   ,cVerSub,Nil}}
		If SE1->( Fieldpos("E1_PLORIG") ) > 0
			Aadd( aVetor, {"E1_PLORIG",'6',Nil})
		Endif

		aValor[3] := aVetor[1][2]
		aValor[4] := aVetor[2][2]
		aValor[5] := aVetor[3][2]
		aValor[6] := aVetor[4][2]
		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		nOldMod := nModulo
		nModulo := 6
		MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)
		If ! lMsErroAuto

			__cCodigo := PLSA510Cd()
			BBT->(RecLock("BBT",.T.))
			BBT->BBT_FILIAL := xFilial("BBT")
			BBT->BBT_CODIGO := __cCodigo
			BBT->BBT_CODOPE := cCodInt
			BBT->BBT_CODEMP := cCodEmp
			BBT->BBT_CONEMP := cConEmp
			BBT->BBT_VERCON := cVerCon
			BBT->BBT_SUBCON := cSubCon
			BBT->BBT_VERSUB := cVerSub
			BBT->BBT_MATRIC := cMatric
			BBT->BBT_CLIFOR := aCliente[1][1]
			BBT->BBT_LOJA   := aCliente[1][2]
			BBT->BBT_VALOR  := aValor[1]
			BBT->BBT_NIVEL  := "4"
			BBT->BBT_ANOTIT := Str(Year(dDataBase), 4)
			BBT->BBT_MESTIT := StrZero(Month(dDataBase), 2)
			BBT->BBT_PREFIX := aNumero[1]
			BBT->BBT_NUMTIT := aNumero[2]
			BBT->BBT_TIPTIT := GetMv("MV_PLSTIP", .F., "DP ")
			BBT->BBT_RECPAG := "0"
			BBT->BBT_CODPLA := cCodPla
			BBT->BBT_VERSAO := cVerPla
			BBT->BBT_CODTIP := "107"	// Identificador de geracao direta ao usuario Cobranca
			BBT->(MsUnlock())          // Taxa de Adesao
		Else
			aValor[8] := .F.
		Endif

		nModulo := nOldMod
	Endif

	If ! Empty(cArea)
		DbSelectArea(cArea)
	Endif

	RestArea(aArea)

Return(aValor)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSTROOPE³ Autor ³ Tulio Cesar        Data ³ 24.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Troca a operadora...                                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSTROOPE()
	LOCAL oDlg      := nil
	LOCAL oBrw      := nil
	LOCAL aDados  	:= {}
	LOCAL bOK     	:= { || nReg := oBrw:nAt, nOpca := 1, oDlg:End() }
	LOCAL bCancel 	:= { || nOpca := 0, oDlg:End() }
	LOCAL oSay      := nil
	LOCAL nOpca   	:= 0
	LOCAL nReg		:= 0
	LOCAL cSQL		:= ""
	LOCAL cCodUsr 	:= PLSRtCdUsr()

	//busca todas as operadoras deste usuario...
	BX4->(DbSetOrder(1))
	If BX4->(MsSeek(xFilial("BX4")+cCodUsr))

		While ! BX4->(Eof()) .And. BX4->(BX4_FILIAL+BX4_CODOPE) == xFilial("BX4")+cCodUsr
			aadd(aDados,{TransForm(BX4->BX4_CODINT,__cPictOpe)+" - "+Posicione("BA0",1,xFilial("BA0")+BX4->BX4_CODINT,"BA0_NOMINT"),IF(BX4->BX4_PADRAO=="1","ENABLE","DISABLE"),BX4->(Recno())})
			BX4->(DbSkip())
		Enddo

	Else
		MsgInfo(STR0029) //"Nao existe operadoras vinculadas a este operador do sistema"
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Define dialogo...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE STR0030 FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault() //"Operadoras Disponiveis"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Monta dados do usuario...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 020,005 SAY oSay PROMPT STR0031  SIZE 220,010 OF oDlg PIXEL  //"Codigo Operador "
	@ 020,058 SAY oSay PROMPT cCodUsr SIZE 220,010 OF oDlg PIXEL

	@ 040,005 SAY oSay PROMPT STR0032  SIZE 220,010 OF oDlg PIXEL  //"Nome Operador "
	@ 040,058 SAY oSay PROMPT PLRETOPE() SIZE 220,010 OF oDlg PIXEL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Define objeto browse...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrw := TcBrowse():New( 060, 008, 340, 130,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	oBrw:AddColumn(TcColumn():New("",nil,;
		nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
	oBrw:ACOLUMNS[1]:BDATA     := { || aDados[oBrw:nAt,2] }
	oBrw:AddColumn(TcColumn():New(STR0033,nil,; //"Operadora"
		nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrw:ACOLUMNS[2]:BDATA     := { || aDados[oBrw:nAt,1] }

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BX4_CODINT+BA0_NOMINT",.F.}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrw:aObfuscatedCols := aBls
	endif

	oBrw:SetArray(aDados)
	oBrw:BLDBLCLICK := bOK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Ativa o dialogo...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlg ON INIT xEnChoiceBar(oDlg,bOK,bCancel)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Caso ele tenha confirmado a opcao grava na base de dados...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpca == 1

		cSQL := " UPDATE " + retSQLName("BX4")
		cSql += "    SET BX4_PADRAO = '0' "
		cSql += "  WHERE BX4_FILIAL = '" + xFilial("BX4") + "' "
		cSQL += "    AND BX4_CODOPE = '" + cCodUsr + "' "
		cSql += "    AND D_E_L_E_T_ = '' "
		cSql += "    AND R_E_C_N_O_ <> " + str(nReg)

		if TCSQLExec(cSql) < 0

			FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})

		elseIf allTrim( TCGetDB() ) == "ORACLE"

			TCSQLExec("COMMIT")

		endIf

		BX4->(dbGoTo(nReg))

		BX4->(recLock("BX4",.F.))
		BX4->BX4_PADRAO := "1"
		BX4->(MsUnLock())

		__cOpePad := BX4->BX4_CODINT

	Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSLISOPE³ Autor ³ Tulio Cesar        Data ³ 24.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista as operadoras...                                 ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLISOPE(cCodOpe)
	LOCAL cRet := ""
	DEFAULT cCodOpe := PLSRtCdUsr()

	BX4->(DbSetOrder(1))
	If BX4->(MsSeek(xFilial("BX4")+cCodOpe))
		While ! BX4->(Eof()) .And. BX4->(BX4_FILIAL+BX4_CODOPE) == xFilial("BX4")+cCodOpe
			cRet += BX4->BX4_CODINT
			BX4->(DbSkip())
		Enddo
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Fim da Rotina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSLOGUSR³ Autor ³ Tulio Cesar        Data ³ 24.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Loga o operador do sistema                             ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLOGUSR(cCodOpe)
	LOCAL cRet 	:= ""
	LOCAL nRecno:= 0

	DEFAULT cCodOpe := PLSRtCdUsr()

	nRecno := BX4->( recno() )

	BX4->( dbSetOrder(2) )//BX4_FILIAL + BX4_CODOPE + BX4_PADRAO
	If BX4->( msSeek( xFilial("BX4") + cCodOpe + "1" ) )
		cRet := BX4->BX4_CODINT
	Endif

	//quando eh rpc, ou seja, tissonlie, ptu online, o sistema pode nao retornar
	//corretamente o operador do sistema do pls dai o sistema se perde
	//gerando por exemplo um monte de bct com operadora vazia..
	If ("RPC" $ funName()) .and. empty(cRet)

		If BX4->( msSeek( xFilial("BX4") ) )

			While !BX4->(Eof())

				If BX4->BX4_PADRAO == '1'
					cRet := BX4->BX4_CODINT
					exit
				endIf

				BX4->(DbSkip())
			Enddo

		Endif

	Endif

	BX4->( dbGoto(nRecno) )

Return(cRet)

/*/{Protheus.doc} PLSINICIA
retorna a static da operadoa
@type function
@author TOTVS
@since 26/07/2017
@version 1.0
/*/
function PLSINICIA()

	PLSCLSOP()

	public __cOpePad := PLSLOGUSR()

return(__cOpePad)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsMCorCM   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSMCorCM(aCores,aCdCores,cAlias)
	LOCAL aArea		:= getArea()
	LOCAL aAreaBCL	:= BCL->(getArea())

	LOCAL lExibe 	:= .t.

	LOCAL cOpePad	:= PLSINTPAD()
	local cTipGui	:= getNewPar("MV_PLTPVIS","")

	DEFAULT aCores	:= {}

	aCdCores := {}

	BCL->(DbGoTop())

	BJX->(DbSetOrder(1))
	BCL->(dbSetOrder(1))
	BCL->( msSeek( xFilial("BCL") + cOpePad ) )

	while ! BCL->(eof()) .And. BCL->(BCL_FILIAL+BCL_CODOPE) == xFilial("BCL")+cOpePad

		if empty(cTipGui) .or. allTrim(BCL->BCL_TIPGUI) $ cTipGui

			if BJX->(MsSeek(xFilial("BJX")+BCL->(BCL_CODOPE+BCL_CODCOR)))

				aadd(aCdCores,{allTrim(BJX->BJX_IMGSIG),allTrim(BCL->BCL_DESCRI),BCL->BCL_TIPGUI})
				aadd(aCores,{cAlias+"->"+cAlias+'_CODCOR = "'+BCL->BCL_CODCOR+'"',AllTrim(BJX->BJX_IMGSIG)})

			endIf

		endIf

		BCL->( DbSkip() )
	EndDo

	BCL->(restArea(aAreaBCL))
	restArea(aArea)

Return

//Descontinuada, utilizada somente no PLSA660
Function PLSMONLEG(oBrw,aCdCores,cTipoPer)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDHOR
Valida um horario digitado
@author Tulio Cesar
@since  15.08.2002
/*/
//-------------------------------------------------------------------
Function PLSVLDHOR(cHora)
	local lRet := .F.

	if ExistBlock("PLSVLDHR")
		lRet := ExecBlock("PLSVLDHR",.F.,.F.,{cHora})
	elseif empty(cHora)
		lRet := .T.
	else
		if ( Subs(cHora,1,2) >= "00" .And. Subs(cHora,1,2) <= "23" ) .And. ( Subs(cHora,3,2) >= "00" .And. Subs(cHora,3,2) <= "60" )
			lRet := .T.
		else
			Help("",1,"PLSVLDHOR")
		endif
	endif

return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSNUMSE2  ³ Autor ³ Tulio Cesar    Data ³ 23.11.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o proximo numero do SE2->E2_NUM. MV_PLNUME2    ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSNUMSE2()
	LOCAL cSQL
	LOCAL cNum
	LOCAL cPrefixo
	Local aArea := GetArea()

	cPrefixo := GetNewPar("MV_PLPREE2","")
	cPrefixo := Eval({|| &cPrefixo })

	dbSelectArea("SE2") // a funcao xFilial() precisa do arquivo aberto
	cSQL := "SELECT MAX(E2_NUM) NUMERO "
	cSQL += "FROM "+RetSQLName("SE2")+" "
	cSQL += "WHERE E2_FILIAL = '"+xFilial("SE2")+"' AND "
	If 'MSSQL' $ AllTrim(TcGetDB())
		cSQL += "LEN(RTRIM(E2_NUM)) = " + Str(TamSX3("E2_NUM")[1]) +" AND "
	Else
		cSQL += "LENGTH(TRIM(E2_NUM)) = " + Str(TamSX3("E2_NUM")[1]) +" AND "
	EndIf
	cSQL += "E2_PREFIXO = '"+cPrefixo+"' "
	cSQL += "AND D_E_L_E_T_ = '' "

	If AllTrim(TcGetDb()) = 'DB2'
		cSQL := strtran(cSQL,"TRIM","RTRIM")
	EndIf

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbNumSE2",.F.,.T.)

	cNum :=  Soma1(TrbNumSE2->NUMERO,Len(SE2->E2_NUM))

	TrbNumSE2->(DbCloseArea())
	RestArea(aArea)

	//Veritica tambem no BMW, pois sao pagamentos enviados para calculo de
	//impostos na folha de pagamento e pode ainda nao haver retornado

	dbSelectArea("BMW") // a funcao xFilial() precisa do arquivo aberto
	cSQL := "SELECT MAX(BMW_NUM) NUMERO "
	cSQL += "FROM "+RetSQLName("BMW")+" "
	cSQL += "WHERE BMW_FILIAL = '"+xFilial("BMW")+"' AND "
	If 'MSSQL' $ AllTrim(TcGetDB())
		cSQL += "LEN(RTRIM(BMW_NUM)) = " + Str(TamSX3("BMW_NUM")[1]) +" AND "
	Else
		cSQL += "LENGTH(TRIM(BMW_NUM)) = " + Str(TamSX3("BMW_NUM")[1]) +" AND "
	EndIf
	cSQL += "BMW_PREFIX = '"+cPrefixo+"' "
	cSQL += "AND D_E_L_E_T_ = '' "

	If AllTrim(TcGetDb()) = 'DB2'
		cSQL := strtran(cSQL,"TRIM","RTRIM")
	EndIf

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbNumBMW",.F.,.T.)

	If  TrbNumBMW->NUMERO >= cNum
		cNum :=  Soma1(TrbNumBMW->NUMERO,Len(SE2->E2_NUM))
	Endif

	TrbNumBMW->(DbCloseArea())
	RestArea(aArea)

Return(cNum)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA600VI  ³ Autor ³ Tulio Cesar    Data ³ 16.01.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Funcao que valida os dados do intercambio no BT5       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA600VI()
	LOCAL cSQL
	LOCAL lRet := .T.
	Local aArea := GetArea()

	//Caso seja um contrato de intercambio analisa consistencia...

	If M->BT5_INTERC == "1"

		//Se for parametrizado um generico (todas as operadoras) verifica se
		//ja nao existe um assim...

		If M->BT5_ALLOPE == "1" .And. ! Empty(M->BT5_TIPOIN)
			cSQL := "SELECT BT5_FILIAL FROM "+RetSQLName("BT5")+" WHERE "
			cSQL += "BT5_FILIAL = '"+xFilial("BT5")+"' AND "
			cSQL += "BT5_CODINT = '"+BG9->BG9_CODINT+"' AND "
			cSQL += "BT5_INTERC = '1' AND "
			cSQL += "BT5_TIPOIN = '"+M->BT5_TIPOIN+"' AND "
			cSQL += "BT5_ALLOPE = '1' AND "
			cSQL += "D_E_L_E_T_ = ''"
			PLSQuery(cSQL,"PLSA600VI")

			If ! PLSA600VI->(Eof())
				lRet := .F.
				Help("",1,"PLS600VI01")
			Endif

			PLSA600VI->(DbCloseArea())
			RestArea(aArea)

			//Se NAO for parametrizado um generico (todas as operadoras) verifica se   ³
			//ja nao existe um assim para a operadora informada...

		ElseIf M->BT5_ALLOPE == "0" .And. ! Empty(M->BT5_OPEINT)
			cSQL := "SELECT BT5_FILIAL FROM "+RetSQLName("BT5")+" WHERE "
			cSQL += "BT5_FILIAL = '"+xFilial("BT5")+"' AND "
			cSQL += "BT5_CODINT = '"+BG9->BG9_CODINT+"' AND "
			cSQL += "BT5_INTERC = '1' AND "
			cSQL += "BT5_TIPOIN = '"+M->BT5_TIPOIN+"' AND "
			cSQL += "BT5_ALLOPE = '0' AND "
			cSQL += "BT5_OPEINT = '"+M->BT5_OPEINT+"' AND "
			cSQL += "D_E_L_E_T_ = ''"
			PLSQuery(cSQL,"PLSA600VI")

			If ! PLSA600VI->(Eof())
				lRet := .F.
				Help("",1,"PLS600VI02")
			Endif

			PLSA600VI->(DbCloseArea())
			RestArea(aArea)
		Endif
	Endif

	//Retorno da funcao...

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSUSRIEVE ³ Autor ³ Tulio Cesar      Data ³ 17.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca dados de um usuario eventual...                  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
[1] Status - "0" Usuario ja existe na base da operadora.
             "1" Usuario nao existe na base e pode ser incluido como intercambio eventual
             "2" nao existe paranetrizacao
[2] Tp Paramametrizacao - (.T. ou .F.) Foi um contrato generica a todas as operadoras ou especifico (Logico)
[3] Operadora do Contrato
[4] Codigo Grupo Empresa
[5] Contrato
[6] Versao Ocntrato
[7] SubContrato
[8] Versao SubContrato
[9] Tipo de Intercambio     "1" - Eventual
                            "2" - Repasse
                            "3" - Quando ele for um usuario da operadora padrao
/*/
Function PLSUSRIEVE(cMatrUsr,cTipo,dData)
	Local aArea      := GetArea()
	LOCAL cStatus    := "0"
	LOCAL aRetUsrGen
	LOCAL cSQL
	LOCAL cOpeUsr
	LOCAL lGeneric
	LOCAL cOpeCont
	LOCAL cCodEmp
	LOCAL cConEmp
	LOCAL cVerCon
	LOCAL cSubCon
	LOCAL cVerSub
	LOCAL cTipoUsr
	LOCAL cNReduz
	LOCAL cOpePad    := PLSINTPAD()
	LOCAL cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")
	LOCAL cCodInE    := GetNewPar("MV_PLSCDIE","1")

	//Define parametros default...

	DEFAULT dData := dDataBase

	//Se o usuario e da base da operadora padrao de um retorno...

	aRetUsrGen := PLSDADUSR(cMatrUsr,cTipo,.F.,dData)

	If aRetUsrGen[1]
		cTipoUsr := aRetUsrGen[43]
		Return({cStatus,lGeneric,cOpeCont,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,cTipoUsr})
	Endif

	//Monta a operadora do usuario eventual...

	If cTipo == "1"
		cOpeUsr := Subs(cMatrUsr,1,ntCodOpe)
	Else
		cOpeUsr := "0"+Subs(cMatrUsr,1,3)
	Endif

	//Busca o contrato de eventtual especifico para a operadora do usuario

	cSQL := "SELECT BT5_CODINT, BT5_CODIGO, BT5_NUMCON, BT5_VERSAO, BT5_INTERC,BT5_TIPOIN,BT5_ALLOPE,BT5_OPEINT "
	cSQL += "FROM "+BT5->(RetSQLName("BT5"))+" WHERE "
	cSQL += "BT5_FILIAL = '"+xFilial("BT5")+"' AND "
	cSQL += "BT5_CODINT = '"+cOpePad+"' AND "
	cSQL += "BT5_CODIGO = '"+cGrpEmpInt+"' AND "
	cSQL += "BT5_INTERC = '1' AND "
	cSQL += "BT5_TIPOIN = '"+cCodInE+"' AND "
	cSQL += "BT5_ALLOPE <> '1' AND "
	cSQL += "BT5_OPEINT = '"+cOpeUsr+"' AND "
	cSQL += "D_E_L_E_T_ = ''"
	PLSQuery(cSQL,"PLSUSRIEVE")

	If ! PLSUSRIEVE->(Eof())
		BQC->(DbSetOrder(1))
		BQC->(MsSeek(xFilial("BQC")+PLSUSRIEVE->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)))
		cStatus  := "1"
		lGeneric := .F.
		cOpeCont := PLSUSRIEVE->BT5_CODINT
		cCodEmp  := PLSUSRIEVE->BT5_CODIGO
		cConEmp  := PLSUSRIEVE->BT5_NUMCON
		cVerCon  := PLSUSRIEVE->BT5_VERSAO
		cSubCon  := BQC->BQC_SUBCON
		cVerSub  := BQC->BQC_VERSUB
		cNReduz	:= BQC->BQC_NREDUZ
		PLSUSRIEVE->(DbCloseArea())
		RestArea(aArea)
	Else
		PLSUSRIEVE->(DbCloseArea())
		RestArea(aArea)

		//Busca o contrato de eventtual generalizado...

		cSQL := "SELECT BT5_CODINT, BT5_CODIGO, BT5_NUMCON, BT5_VERSAO, BT5_INTERC,BT5_TIPOIN,BT5_ALLOPE,BT5_OPEINT "
		cSQL += "FROM "+BT5->(RetSQLName("BT5"))+" WHERE "
		cSQL += "BT5_FILIAL = '"+xFilial("BT5")+"' AND "
		cSQL += "BT5_CODINT = '"+cOpePad+"' AND "
		cSQL += "BT5_CODIGO = '"+cGrpEmpInt+"' AND "
		cSQL += "BT5_INTERC = '1' AND "
		cSQL += "BT5_TIPOIN = '"+Alltrim(cCodInE)+"' AND "
		cSQL += "BT5_ALLOPE = '1' AND "
		cSQL += "D_E_L_E_T_ = ''"
		PLSQuery(cSQL,"PLSUSRIEVE")

		If ! PLSUSRIEVE->(Eof())
			BQC->(DbSetOrder(1))
			BQC->(MsSeek(xFilial("BQC")+PLSUSRIEVE->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)))
			cStatus  := "1"
			lGeneric := .T.
			cOpeCont := PLSUSRIEVE->BT5_CODINT
			cCodEmp  := PLSUSRIEVE->BT5_CODIGO
			cConEmp  := PLSUSRIEVE->BT5_NUMCON
			cVerCon  := PLSUSRIEVE->BT5_VERSAO
			cSubCon  := BQC->BQC_SUBCON
			cVerSub  := BQC->BQC_VERSUB
			cNReduz  := BQC->BQC_NREDUZ
		Endif
		PLSUSRIEVE->(DbCloseArea())
		RestArea(aArea)
	Endif

	//Se eu nao achar a parametrizacao no sistema devo emitir uma msg...

	If cStatus == "0"
		cStatus := "2"
	Endif

Return({cStatus,lGeneric,cOpeCont,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,cTipoUsr,cNReduz})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSXCADUNC ³ Autor ³ Tulio Cesar      Data ³ 29.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclui um usuario nao cadastrado/exame admissional     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSXCADUNC()
	Local I__f := 0
	LOCAL oDlg
	LOCAL nOpca     := 0
	LOCAL aButtons  := {}
	LOCAL bOK       := {|| nOpca := 1,If(Obrigatorio(oEncInt:aGets,oEncInt:aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
	LOCAL bCancel   := {|| oDlg:End() }
	LOCAL oEncInt
	LOCAL cMatric
	LOCAL lIncluido := .F.
	LOCAL aOldTela  := aClone(aTela)
	LOCAL aOldGets  := aClone(aGets)
	Local cTipReg	:= GetNewPar("MV_PLTRTIT","00")

	PRIVATE aTELA[0][0]
	PRIVATE aGETS[0]
	PRIVATE cCadastro := STR0039 //"Inclusao de Usuarios - "
	PRIVATE aRotina := { { STR0040  ,'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar"
		{ STR0041 ,'naodisp' , 0 , K_Visualizar },; //"Visualizar"
		{ STR0042    ,'naodisp' , 0 , K_Incluir    } } //"Incluir"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Busca a parametrizacao...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BG9->(DbSetOrder(3))
	If ! BG9->(MsSeek(xFilial("BG9")+"2"))
		Help("",1,"PLSXCADUNC")
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Define dialogo...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Monta dados da enchoice...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Copy "BES" To Memory Blank

	M->BES_CODINT := BG9->BG9_CODINT
	M->BES_CODEMP := BG9->BG9_CODIGO

	lRefresh := .F.
	oEncInt  := BES->(MSMGET():New("BES",0,K_Incluir,,,,,{015,005,205,350},,,,,,oDlg,,,.F.))

	//Ativa Dialog...

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)

	//Inicia processo de gravacao

	If nOpca = K_OK

		//Inicia Transacao...

		Begin Transaction

			//Se nao existir inclui...

			cMatric := PLPROXMAT(BG9->BG9_CODINT,BG9->BG9_CODIGO)

			BA3->(RecLock("BA3",.T.))
			BA3->BA3_FILIAL := xFilial("BA3")
			BA3->BA3_CODINT := M->BES_CODINT
			BA3->BA3_CODEMP := M->BES_CODEMP
			BA3->BA3_ROTINA := "PLSPORFAI"
			BA3->BA3_CONEMP := ""
			BA3->BA3_VERCON := ""
			BA3->BA3_SUBCON := ""
			BA3->BA3_VERSUB := ""
			BA3->BA3_MATRIC := cMatric
			BA3->BA3_MATANT := ""
			BA3->BA3_HORACN := SubStr(Time(),1,5)
			BA3->BA3_COBNIV := "0"
			BA3->BA3_VENCTO := 0
			BA3->BA3_DATBAS := dDataBase
			BA3->BA3_DATCIV := dDataBase
			BA3->BA3_TIPOUS := "2"
			BA3->BA3_CODPLA := GetNewPar("MV_PLSPLPE","0001")
			BA3->BA3_VERSAO := GetNewPar("MV_PLSVRPE","001")
			BA3->BA3_FORPAG := GetNewPar("MV_PLSFCPE","101")
			BA3->BA3_DATCON := Date()
			BA3->BA3_HORCON := SubStr(Time(),1,5)
			BA3->(MsUnLock())

			//Agora inclui o usuario...

			BA1->(RecLock("BA1",.T.))
			BA1->BA1_FILIAL := xFilial("BA1")
			BA1->BA1_CODINT := M->BES_CODINT
			BA1->BA1_CODEMP := M->BES_CODEMP
			BA1->BA1_MATRIC := cMatric
			BA1->BA1_CONEMP := ""
			BA1->BA1_VERCON := ""
			BA1->BA1_SUBCON := ""
			BA1->BA1_VERSUB := ""
			BA1->BA1_IMAGE  := "ENABLE"
			BA1->BA1_TIPREG := cTipReg
			BA1->BA1_DIGITO := IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG)),Modulo11(BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG))
			BA1->BA1_NOMUSR := M->BES_NOME
			BA1->BA1_TIPUSU := GetNewPar("MV_PLCDTIT","T")
			BA1->BA1_GRAUPA := GetNewPar("MV_PLCDTGP","01")
			BA1->BA1_ENDCLI := "0"
			BA1->BA1_SEXO   := ""
			BA1->BA1_MATEMP := ""
			BA1->BA1_MATANT := ""
			BA1->BA1_TIPANT := ""
			BA1->BA1_ESTCIV := ""
			BA1->BA1_CPFUSR := ""
			BA1->BA1_DRGUSR := ""
			BA1->BA1_DATINC := dDataBase
			BA1->BA1_DATNAS := ctod("")
			BA1->BA1_DATCAR := dDataBase
			BA1->BA1_CBTXAD := "1"
			BA1->BA1_OPEORI := PLSINTPAD()
			BA1->BA1_OPEDES := PLSINTPAD()
			BA1->BA1_OPERES := PLSINTPAD()
			BA1->BA1_LOCATE := "1"
			BA1->BA1_LOCCOB := "1"
			BA1->BA1_LOCEMI := "1"
			BA1->BA1_LOCANS := "1"
			BA1->(MsUnLock())

			//Esta funcao analise a criacao de uma nova vida ou nao...

			PLSA766ANV()

			//Grava no usuario a vida criada ou a ja existente...

			BA1->(RecLock("BA1",.F.))
			BA1->BA1_MATVID := BTS->BTS_MATVID
			BA1->(MsUnLock())

			//Inclui no arquivo de movimento...

			BES->(PLUPTENC("BES",K_Incluir))

			//Exibe mensagem informativa...

			MsgInfo(STR0043+BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG+"-"+BA1_DIGITO)) //"O usuario foi criado na base sob a matricula temporaria : "

			//Finaliza Transacao...

		End Transaction
	Endif

	aTela := aClone(aOldTela)
	aGets := aClone(aOldGets)

	//Fim da Rotina...

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSXANAFAI ³ Autor ³ Tulio Cesar      Data ³ 09.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Analisa consistencias em faixas etarias                ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSXANAFAI(_aCampos, cCpoIni, cCpoFin, nLinha)
	LOCAL nFor
	LOCAL nUltInd
	LOCAL nPos
	LOCAL nForCpo
	LOCAL cMacro
	LOCAL aCposTrb   := {}
	LOCAL cIfDin
	LOCAL nPosFaiIni
	LOCAL nPosFaiFin
	LOCAL nVlFaiIni
	LOCAL nVlFaiFin
	//LOCAL nLinha   := n
	LOCAL nForAux
	LOCAL lFlag

	//Monta valor digitado na linha atual da faixa inicial e final...

	nPosFaiIni := PLRETPOS(cCpoIni,aHeader)
	nPosFaiFin := PLRETPOS(cCpoFin,aHeader)

	nVlFaiIni := &("M->"+aHeader[nPosFaiIni,2])
	nVlFaiFin := &("M->"+aHeader[nPosFaiFin,2])

	//O primeiro aCols deve ser igual a zero a faixa inicial...

	If Len(aCols) <= 1
		If     Type('nVlFaiIni') == "N" .And. nVlFaiIni <> 0
			Help("",1,"PLSANAFAI1")
			Return(.F.)
		ElseIf Type('nVlFaiIni') == "D" .And. !Empty(nVlFaiIni)
			Help("",1,"PLSANAFAI1")
			Return(.F.)
		Endif
	Endif

	//Se a faixa inicial for maior que a final critico...

	If nVlFaiIni > nVlFaiFin .And. ! Empty(nVlFaiFin)
		Help("",1,"PLSANAFAI2")
		Return(.F.)
	Endif

	//Monta vetor de apoio...

	For nForCpo := 1 To Len(_aCampos)
		aadd(aCposTrb,{_aCampos[nForCpo],&("M->"+_aCampos[nForCpo])})
	Next

	//Liga flags e contadores...

	lFlag   := .T.
	nUltInd := 0
	nQtdInd := 0

	//Naveja por toda a matriz...

	For nFor := 1 To Len(aCols)

		//Zera contador do if Dinamico para esta linha do for...

		cIfDin     := "{ || "

		//Se a linha for diferente...

		If nFor <> nLinha .And. ! aCols[nFor,Len(aHeader)+1]

			//Monta "If" dinamico...

			For nForCpo := 1 To Len(aCposTrb)
				nPos   := PLRETPOS(aCposTrb[nForCpo,1],aHeader)
				If      ValType(aCposTrb[nForCpo,2]) == "C"
					cIfDin += " ( M->"+aCposTrb[nForCpo,1]+" = '"+aCols[nFor,nPos]+"' ) .And. "
				ElseIf  ValType(aCposTrb[nForCpo,2]) == "D"
					cIfDin += " ( dtos(M->"+aCposTrb[nForCpo,1]+") = '"+dtos(aCols[nFor,nPos])+"' ) .And. "
				ElseIf  ValType(aCposTrb[nForCpo,2]) == "N"
					cIfDin += " ( M->"+aCposTrb[nForCpo,1]+" = "+Str(aCols[nFor,nPos])+" ) .And. "
				Endif
			Next
			If Len(aCposTrb) > 0
				cMacro := Subs(cIfDin,1,Len(cIfDin)-7)+" } "
			Else
				cMacro := "{ || .T. }"
			Endif

			//Se achou a mesma chave com um zero na faixa inicial liga flag...

			If Eval(&cMacro)

				if type('aCols[nFor,nPosFaiIni]') == "N" .And. aCols[nFor,nPosFaiIni] == 0
					lFlag := .T.
				elseIf type('aCols[nFor,nPosFaiIni]') == "D" .And. Empty(aCols[nFor,nPosFaiIni])
					lFlag := .T.
				endIf

			Endif

			//Acumula dados para a mesma chave...

			If Eval(&cMacro)
				nUltInd := nFor
				nQtdInd ++
			Endif

			//Analisa chave em duplicidade...

			If Eval(&cMacro) .And. (	( nVlFaiIni >= aCols[nFor,nPosFaiIni] .And. nVlFaiIni <= aCols[nFor,nPosFaiFin] ) .Or.;
					( nVlFaiIni <= aCols[nFor,nPosFaiIni] .And. nVlFaiFin >= aCols[nFor,nPosFaiIni] ) )
				lFlag := .F.
				Help("",1,"PLSANAFAI5")
				Exit
			Endif
		Endif
	Next

	If ! lFlag
		Return(.F.)
	Endif

	//Se nao achou a mesma chave com conteudo zero esta errado...

	If ! lFlag .And. nQtdInd > 0
		Help("",1,"PLSANAFAI3")
		Return(.F.)
	Endif

	//Se e a primeira chave e nao e zero sai...

	If nUltInd == 0
		If     Type('nVlFaiIni') == "N" .And. nVlFaiIni <> 0
			Help("",1,"PLSANAFAI5")
			Return(.F.)
		ElseIf Type('nVlFaiIni') == "D" .And. !Empty(nVlFaiIni)
			Help("",1,"PLSANAFAI5")
			Return(.F.)
		Endif
	Endif

	//Retorno da funcao...

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSVLDCID  ³ Autor ³ Tulio Cesar      Data ³ 09.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a obrigatorioedade do CID...                    ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDCID(cCodRDA,cCid)
	LOCAL nOrdBAU := BAU->(IndexOrd())
	LOCAL nRecBAU := BAU->(Recno())
	LOCAL lPosBAU := .F.

	//Se a rede de atendimento nao esta posicionada posiciono...

	If cCodRDA <> BAU->BAU_CODIGO
		lPosBAU := .T.
		BAU->(DbSetOrder(1))
		If ! BAU->(MsSeek(xFilial("BAU")+cCodRDA))
			Help("",1,"PLSVLDCID1")
			Return(.F.)
		Endif
	Endif

	//Busca o tipo de prestador...

	BAG->(DbSetOrder(1))
	If ! BAG->(MsSeek(xFilial("BAG")+BAU->BAU_TIPPRE))
		Help("",1,"PLSVLDCID2")
		Return(.F.)
	Endif

	//Caso tenha desposicionado posiciona no original (BAU)

	If lPosBAU
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
	Endif

	//Analisa a obrigatoriedade ou nao...

	If BAG->BAG_OBRCID == "1" .And. Empty(cCid)
		Help("",1,"PLSVLDCID0")
		Return(.F.)
	Endif

	//Fim da Funcao...

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSLOG  Autor ³ Tulio Cesar      Data ³ 09.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Loja alerta para o Log (console)                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLOG(cFuncao,cCodigo,cConteudo)

	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0044+" -> "+cFuncao+" ; "+STR0045+" -> "+cCodigo+" ; "+STR0046+" -> "+cConteudo , 0, 0, {})////"Alerta SIGAPLS: Funcao"###"Codigo"###"Conteudo"

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSEXTPRE  ³ Autor ³ Tulio Cesar      Data ³ 22.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna as msg de extrato para um prestador            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSEXTPRE(cCodCre,cCodOpe,cAno,cMes, cTpPrest)
	LOCAL cSQL := ""
	LOCAL aRetExt := {}
	Local aArea   := GetArea()

	cSQL := "SELECT BN4_MSG1, BN4_MSG2, BN4_MSG3 "

	If BN4->(FieldPos("BN4_COPCRE")) > 0
		cSQL += ", BN4_COPCRE "
	EndIf

	cSQL += " FROM "+RetSQLName("BN4")+" WHERE "
	cSQL += "BN4_FILIAL =  '"+xFilial("BN4")+"' AND "
	cSQL += "BN4_CODINT =  '"+cCodOpe+"' AND "
	cSQL +=  "'"+cAno+cMes+"' BETWEEN BN4_ANODE+BN4_MESDE  AND BN4_ANOATE+BN4_MESATE AND "
	cSQL += "'"+cCodCre+"' BETWEEN BN4_RDADE AND BN4_RDAATE AND "
	cSQL += "D_E_L_E_T_ = ''"

	PLSQuery(cSQL,"PLSEXTPRE")

	While ! PLSEXTPRE->(Eof())

		If (PLSEXTPRE->BN4_COPCRE == cTpPrest .OR. PLSEXTPRE->BN4_COPCRE $ " 4")
			If ! Empty(PLSEXTPRE->BN4_MSG1)
				aadd(aRetExt,PLSEXTPRE->BN4_MSG1)
			Endif

			If ! Empty(PLSEXTPRE->BN4_MSG2)
				aadd(aRetExt,PLSEXTPRE->BN4_MSG2)
			Endif

			If ! Empty(PLSEXTPRE->BN4_MSG3)
				aadd(aRetExt,PLSEXTPRE->BN4_MSG3)
			Endif

		EndIf

		PLSEXTPRE->(DbSkip())
	Enddo

	PLSEXTPRE->(DbCloseArea())
	RestArea(aArea)

Return(aRetExt)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FuncaoPLSA260GFC  ³ Autor ³ Tulio Cesar      Data ³ 05.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ BA3_CODPLA - Validacao de campo...                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA260GCF(lDireto)
	DEFAULT lDireto := .F.

	If Readvar() == "M->BA3_CODPLA"
		LDireto := .T.

		// Verifica se a versao selecionada esta ativa ou nao...
	ElseIf Readvar() == "M->BA3_VERSAO"
		BI3->( dbSetorder(01) )
		If BI3->( MsSeek(xFilial("BI3")+M->BA3_CODINT+M->BA3_CODPLA+M->BA3_VERSAO) ) .and. BI3->BI3_STATUS == '2'
			If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
				Help("",1,"PLSSITANS")
			Else
				Help("",1,"PLSA260003")
			Endif
			Return(.F.)
		Endif

	Elseif Readvar() == "M->BA1_VERSAO"
		BI3->( dbSetorder(01) )
		If BI3->( MsSeek(xFilial("BI3")+M->BA3_CODINT+M->BA1_CODPLA+M->BA1_VERSAO) ) .and. BI3->BI3_STATUS == '2'
			If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
				Help("",1,"PLSSITANS")
			Else
				Help("",1,"PLSA260003")
			Endif
			Return(.F.)
		Else
			Return(.T.)
		Endif

	Endif

	If  M->BA3_TIPOUS == "1".And. Empty(M->BA3_CODEMP)
		MsgInfo(STR0047) //"Informe o Grupo Empresa"
		Return(.F.)
	ElseIf M->BA3_TIPOUS == "2" .And. ( Empty(M->BA3_CODEMP) .Or. Empty(M->BA3_CONEMP) .Or. Empty(M->BA3_SUBCON) )
		MsgInfo(STR0048) //"Informe o Grupo Empresa/Contrato/Subcontrato"
		Return(.F.)
	Endif

	If M->BA3_TIPOUS == "1" //PF
		aRet := PLFORPAGPF(M->BA3_CODPLA,IIf(Empty(M->BA3_VERSAO) , '001', M->BA3_VERSAO), M->BA3_FORPAG, M->BA3_FORCTX, lDireto, M->BA3_CODINT)

		M->BA3_FORPAG := aRet[1]
		M->BA3_DESFOR := BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI"))
		M->BA3_ROTINA := aRet[2]
		M->BA3_FORCTX := aRet[3]
		M->BA3_DEFOTX := BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI"))
		M->BA3_MODPAG := aRet[4]
		M->BA3_RATSAI := aRet[5]

	Else //PJ
		//Forma de Cobranca Grp Empresa
		aRet := PLFORPAGPJ(M->BA3_CODPLA, IIf(Empty(M->BA3_VERSAO) , '001', M->BA3_VERSAO), M->BA3_FORPAG, M->BA3_FORCTX, lDireto, M->BA3_CODEMP, M->BA3_CONEMP, M->BA3_VERCON, M->BA3_SUBCON, M->BA3_VERSUB, M->BA3_CODINT)

		M->BA3_FORPAG := aRet[1]
		M->BA3_DESFOR := BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI"))
		M->BA3_ROTINA := aRet[2]
		M->BA3_FORCTX := aRet[3]
		M->BA3_DEFOTX := BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI"))
		M->BA3_MODPAG := aRet[4]
		M->BA3_RATSAI := aRet[5]
	Endif

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCOLSBL ºAutor  ³Microsiga           º Data ³  05/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCOLSBL(cAlias,aHeader,aCols)
	LOCAL nLin
	Local nInd

	aCols := {{}}

	nLin := Len(aHeader)+1
	For nInd :=  1 To nLin
		If nInd <= Len(aHeader)
			If     aHeader[nInd,8] == "C"
				aadd(aCols[Len(aCols)],Space(aHeader[nInd,4]))
			ElseIf aHeader[nInd,8] == "D"
				aadd(aCols[Len(aCols)],ctod(""))
			ElseIf aHeader[nInd,8] == "N"
				aadd(aCols[Len(aCols)],0)
			Else
				aadd(aCols[Len(aCols)],nInd)
			Endif
		Else
			aadd(aCols[Len(aCols)],.F.)
		Endif
	Next

	For nInd := 1 To Len(aHeader)
		If nInd <= Len(aHeader)
			aCols[Len(aCols),nInd] := Criavar(aHeader[nInd,2],.T.)
		Endif
	Next

Return(aCols)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsDiaSem   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSDIASEM(dData)

	LOCAL aDias := {STR0088,STR0089,STR0090,STR0091,STR0092,STR0093,STR0094} //"Domingo"###"Segunda"###"Terca"###"Quarta"###"Quinta"###"Sexta"###"Sabado"

	If Empty(dData)  //Tratamento para que não ocorra error.log
		dData := dDatabase
	Endif

Return(aDias[Dow(dData)])

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsRAND     ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRAND(cMax, cStr)
	// Este programa processará a string dividindo em 15 caracteres, pois a função Val
	// tem um problema de arredondamento para cima e para baixo a partir de 16 caracteres

	// Variáveis de Posicionamento
	LOCAL nOrdBE4	:= BE4->(IndexOrd())
	LOCAL nRecBE4	:= BE4->(Recno())
	LOCAL nOrdBEA	:= BEA->(IndexOrd())
	LOCAL nRecBEA	:= BEA->(Recno())
	LOCAL nOrdBD6	:= BD6->(IndexOrd())
	LOCAL nRecBD6	:= BD6->(Recno())
	LOCAL nOrdB44	:= B44->(IndexOrd())
	LOCAL nRecB44	:= B44->(Recno())
	LOCAL bRest		:= { || BE4->(DbSetorder(nOrdBE4)), BE4->(DbGoTo(nRecBE4)) ,;
		B44->(DbSetorder(nOrdB44)), B44->(DbGoTo(nRecB44)) ,;
		BEA->(DbSetorder(nOrdBEA)), BEA->(DbGoTo(nRecBEA)) ,;
		BD6->(DbSetorder(nOrdBD6)), BD6->(DbGoTo(nRecBD6)) }

	// Variáveis de Execução de CodeBlock
	LOCAL bRetN1a	:= { || Int( ABS(nMax1 * mod( Seconds()*b, IIf(m<=0, 1, m) ) ) ) }
	LOCAL bRetN1b	:= { || IIf( Len(cMax) > 15, Val(Subs(AllTrim(Str(ABS(nRet1))),1,15)), Val(Subs(AllTrim(Str(ABS(nRet1))),1,Len(AllTrim(cMax)))) ) }

	LOCAL bRetN2a	:= { || Int( ABS(nMax2 * mod( Seconds()*c, IIf(n<=0, 1, n) ) ) ) }
	LOCAL bRetN2b	:= { || IIf( Len(cMax) > 15, Val(Subs(AllTrim(Str(ABS(nRet2))),1,Len(AllTrim(cMax))-15)), 0 ) }

	// Variáveis
	Local nMax1
	Local nMax2
	LOCAL m
	LOCAL n
	LOCAL b
	LOCAL c
	LOCAL nRet1		:= 0
	LOCAL nRet2		:= 0
	LOCAL cRet		:= ''
	LOCAL lIndB44	:= .F.

	DEFAULT cStr	:= ''
	DEFAULT cMax	:= '9'

	// Preparação de conteúdos
	nMax1		:= Val(Subs(AllTrim(cMax),01,IIf(Len(AllTrim(cMax))<15, Len(AllTrim(cMax)),15)))
	nMax2		:= Val(Subs(AllTrim(cMax),16,IIf(Len(AllTrim(cMax))>15, Len(AllTrim(cMax))-15,0)))
	m			:= Val(Subs('900000000000000',1,IIf(Len(cMax)>15,15,Len(cMax))))
	n			:= Val(Subs('90000000000000000000',16,IIf(Len(cMax)>15,Len(cMax)-15,0)))
	b			:= Randomize( 1, IIf(nMax1>32766, 32766, IIf(nMax1<=0, 32766,nMax1) ) )
	c			:= IIf(nMax2<=0, 1, Randomize( 1, IIf(nMax2>32766, 32766, IIf(nMax2<=0,32766,nMax2) ) ) )


	// Tratamento para composição de senha A+B+C + Dia + NNNNNN
	If GetNewPar("MV_PLSMSEN","1") == "2" .and. Len(cMax) == 2
		Return( StrZero( Randomize( 1, IIf(Val(cMax)<=25, Val(cMax), 25) ), 2) )
	EndIf

	nRet1 := Eval(bRetN1a)
	nRet1 := Eval(bRetN1b)
	If Len(cMax) > 15
		nRet2 := Eval(bRetN2a)
		nRet2 := Eval(bRetN2b)
	EndIf

	While nRet1 <= 0
		nRet1 := Eval(bRetN1a)
		nRet2 := IIf(Len(cMax) > 15, Eval(bRetN2a), 0)
	EndDo

	nRet1 := Eval(bRetN1b)
	nRet2 := IIf(Len(cMax) > 15, Eval(bRetN2b), 0)

	cRet := cStr + AllTrim(StrZero(nRet1,IIf(Len(cMax)>15,15,Len(cMax)))+IIf(Len(cMax) > 15, StrZero(nRet2,Len(cMax)-15), ''))

	BE4->(DbSetOrder(7))  	//BE4_FILIAL + BE4_SENHA
	BEA->(DbSetOrder(14)) 	//BEA_FILIAL + BEA_SENHA
	BD6->(DbSetOrder(15)) 	//BD6_FILIAL + BD6_SENEVO
	If SIX->(dbSeek('B445',.F.))
		lIndB44	:= .T.
		B44->(dbSetOrder(5))	//B44_FILIAL + B44_SENHA
	EndIf

	While BE4->(MsSeek(xFilial("BE4")+cRet,.F.)) .or. BEA->(MsSeek(xFilial("BEA")+cRet,.F.)) .or. ;
			BD6->(MsSeek(xFilial("BD6")+cRet,.F.)) .or. (lIndB44 .and. B44->(MsSeek(xFilial("B44")+cRet,.F.)) )
		nRet1 := Eval(bRetN1a)
		nRet1 := Eval(bRetN1b)
		If Len(cMax) > 15
			nRet2 := Eval(bRetN2a)
			nRet2 := Eval(bRetN2b)
		EndIf
		cRet := cStr + AllTrim(StrZero(nRet1,IIf(Len(cMax)>15,15,Len(cMax)) )+IIf(Len(cMax) > 15, StrZero(nRet2,Len(cMax)-15), ''))
	Enddo

	Eval(bRest)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSWhPdr   ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 01.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Verifica se pode ser inativado o procedimento nos niveis de   ³±±
±±³       Usuario/Familia/Produto/Sub-Contrato de acordo c/tabela padrao³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSWhPdr(cAlias)

	Local lRet := .T.

	BR8->(DbSetOrder(1))
	BR8->(MsSeek(xFilial("BR8") + &("M->" + cAlias + "_CODPAD") + &("M->" + cAlias + "_CODPSA" )))

Return Empty(BR8->BR8_CODROL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSGUIAORI ³ Autor ³ Tulio Cesar       Data ³ 07.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Busca a guia original de uma movimentacao.                ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGUIAORI(cCodSol,dDatPro,cMatric,cQuery1,cQuery2)
	Local cSQL     := ""
	Local cGuiaOri := ""
	Local nRecBD6  := 0
	Local cOpeUsr  := Subs(cMatric,01,4)
	Local cCodEmp  := Subs(cMatric,05,4)
	Local cMatrUsr := Subs(cMatric,09,6)
	Local cTipReg  := Subs(cMatric,15,2)
	Local nOrdBAU  := BAU->(IndexOrd())
	Local nRecBAU  := BAU->(Recno())
	Local aArea    := GetArea()

	BAU->(DbSetOrder(5))
	If BAU->(MsSeek(xFilial("BAU")+cCodSol))

		cSQL := "SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, R_E_C_N_O_ AS BD6REC FROM "+RetSQLName("BD6")+" WHERE "
		cSQL += "BD6_FILIAL = '" + xFilial("BD6") + "' AND "
		cSQL += "BD6_OPEUSR = '" + cOpeUsr  + "' AND "
		cSQL += "BD6_CODEMP = '" + cCodEmp  + "' AND "
		cSQL += "BD6_MATRIC = '" + cMatrUsr + "' AND "
		cSQL += "BD6_TIPREG = '" + cTipReg  + "' AND "
		cSQL += "BD6_CODRDA = '" + BAU->BAU_CODIGO + "' AND "
		cSQL += "BD6_DATPRO <= '" + dtos(dDatPro) + "' AND "
		cSQL += "BD6_SITUAC = '1' AND "
		cSQL += cQuery1+" AND "
		cSQL += cQuery2+" AND "
		cSQL += "D_E_L_E_T_ = '' "
		cSQL += "ORDER BY BD6_DATPRO DESC"

		PLSQuery(cSQL,"PLSGUIAORI")

		cGuiaOri := PLSGUIAORI->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
		nRecBD6  := PLSGUIAORI->BD6REC

		PLSGUIAORI->(DbCloseArea())
		RestArea(aArea)

	Endif

	BAU->(DbGoTo(nRecBAU))
	BAU->(DbSetOrder(nOrdBAU))

Return({cGuiaOri, nRecBD6})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSEXISPAC ³ Autor ³ Tulio Cesar       Data ³ 07.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Verifica se existe pacote e seta como sim o Flag          ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSEXISPAC(cOpeRDA,cCodRDA,cCodPad,cCodPro,cCpoMac,cValor)
	LOCAL cSQL
	Local aArea := GetArea()
	LOCAL bErro
	Private bmfunErr := .T.
	DEFAULT cOpeRDA := ""
	DEFAULT cCodRDA := ""
	DEFAULT cCodPad := ""
	DEFAULT cCodPro := ""

	bErro := ErrorBlock( { |e| PLSErr(e) } )
	BEGIN SEQUENCE

		cSQL := "SELECT BLY_VALFIX FROM "+RetSQLName("BLY")+" WHERE "
		cSQL += "BLY_FILIAL = '"+xFilial("BLY")+"' AND "
		cSQL += "BLY_CODINT = '"+cOpeRDA+"' AND "
		cSQL += "BLY_CODRDA = '"+cCodRDA+"' AND "
		cSQL += "BLY_CODPRO = '"+cCodPro+"' AND "
		cSQL += "BLY_CODPAD = '"+cCodPad+"' AND "
		cSQL += "D_E_L_E_T_ = '' "
		cSQL += "ORDER BY BLY_FILIAL"

		PLSQuery(cSQL,"PLSEXISPAC")

		&(cCpoMac) := IF(PLSEXISPAC->(Eof()),"0","1")
		If ! PLSEXISPAC->(Eof())
			&(cValor) := PLSEXISPAC->BLY_VALFIX
		Endif

		PLSEXISPAC->(DbCloseArea())
		RestArea(aArea)

		lRefresh := .T.

	End Sequence

	Errorblock(bErro)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSACOMUSR ³ Autor ³ Tulio Cesar       Data ³ 20.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o padrao de acomodacao de um usuario.             ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSACOMUSR(cMatricUsr,cTipo)
	LOCAL cCodAco   := ""
	LOCAL cPadCon   := ""
	LOCAL cCodPla   := ""
	LOCAL lOKPadCon := .f.
	LOCAL aAreaBI3  := BI3->(getArea())
	LOCAL aAreaBG9  := BG9->(getArea())

	DEFAULT cTipo := "1"

	//"1" acomodacao
	//"2"

	//Posiciona no usuario familia e subcontrato...
	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+cMatricUsr))

	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

	if BA3->(FieldPos("BA3_PADSAU")) > 0

		cPadCon := BA3->BA3_PADSAU

		if !empty(cPadCon)

			lOKPadCon := .t.

		endIf

	endIf

	if cTipo == '1' .or. ( cTipo == '2' .and. !lOKPadCon )

		BI3->(DbSetOrder(1))
		BG9->(DbSetOrder(1))
		BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))

		//Verifica opcional do usuario...
		BF4->(DbSetOrder(1))
		if BF4->(MsSeek(xFilial("BF4")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))

			while ! BF4->(Eof()) .And. BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG) == xFilial("BF4")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

				if BI3->(MsSeek(xFilial("BI3")+BF4->(BF4_CODPRO+BF4_VERSAO)))

					if cTipo == "1"

						cCodAco := BI3->BI3_CODACO

						exit

					else

						if ! lOKPadCon

							cPadCon := BI3->BI3_PADSAU

							if !empty(cPadCon)

								lOKPadCon := .t.

								exit

							endIf

						endIf

					endIf

				endIf

				BF4->(dbSkip())
			endDo

		endIf

		if ( cTipo == '1' .and. empty(cCodAco) ) .or. ( cTipo == '2' .and. !lOKPadCon )

			//Verifica opcional do familia...
			BF1->(DbSetOrder(1))
			If BF1->(MsSeek(xFilial("BF1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

				While ! BF1->(Eof()) .And. BF1->(BF1_FILIAL+BF1_CODINT+BF1_CODEMP+BF1_MATRIC) == xFilial("BF1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

					if BI3->(MsSeek(xFilial("BI3")+BF1->(BF1_CODPRO+BF1_VERSAO)))

						if cTipo == "1"

							cCodAco := BI3->BI3_CODACO

							exit

						else

							if ! lOKPadCon

								cPadCon := BI3->BI3_PADSAU

								if !empty(cPadCon)

									lOKPadCon := .t.

									exit

								endIf

							endIf

						endIf

					endIf

					BF1->(DbSkip())
				endDo

			endIf

			if ( cTipo == '1' .and. empty(cCodAco) ) .or. ( cTipo == '2' .and. !lOKPadCon )

				if empty(BA1->BA1_CODPLA)
					cCodPla := BA3->(BA3_CODPLA+BA3_VERSAO)
				else
					cCodPla := BA1->(BA1_CODPLA+BA1_VERSAO)
				endIf

				//Analisa no Produto (PF) ou SubContrato (PJ)...
				if BG9->BG9_TIPO == "1"

					If BI3->(MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cCodPla))

						if cTipo == "1"

							cCodAco := BI3->BI3_CODACO

						else

							if ! lOKPadCon

								cPadCon := BI3->BI3_PADSAU

								if !empty(cPadCon)

									lOKPadCon := .T.

								endIf

							endIf

						endIf

					endIf

				else

					BT6->(DbSetOrder(1))
					if BT6->(MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+cCodPla)))

						if cTipo == "1"

							cCodAco := BT6->BT6_CODACO

						else

							if BI3->(MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cCodPla))

								if ! lOKPadCon

									cPadCon := BI3->BI3_PADSAU

									if ! Empty(cPadCon)

										lOKPadCon := .T.

									endIf

								endIf

							endIf

						endIf

					endIf

				endIf

			endIf

		endIf

	endIf

	BI3->(restArea(aAreaBI3))
	BG9->(restArea(aAreaBG9))

return( iIf(cTipo == "1", cCodAco , cPadCon ) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVERCAR  ³ Autor ³ PLS      Data ³ 27.12.2018				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Verifica se o usu. possui o proc. em um dos níveis de carência.±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
param aCarencia, array
[1] = Unidade de contagem da carencia
[2] = Quantidade de carencia da unidade acima
[3] = Nivel da Classe de Carencia
[4] = Classe da carencia informada
[5] = Codigo da Operadora
[6] = Data base de carencia
[7] = Existia regra sim ou nao (novo)
*/
Function PLSVERCAR(aCarencia,aDadUsr,cOpeUsr,cCodPla,cVersao, cNivCar)

	LOCAL lRet := .F.
	local cAlias	:= ''
	local cClascar  := aCarencia[4]
	local cTipoUsr  := aDadUsr[8]
	local cCodEmp   := Subs(aDadUsr[2],5,4)
	local cConEmp   := aDadUsr[9]
	local cVerCon   := aDadUsr[39]
	local cSubCon   := aDadUsr[41]
	local cVerSub   := aDadUsr[42]
	local cMatricU  := aDadUsr[2]
	local cMatric   := Subs(cMatricU,atMatric[1],atMatric[2])
	local cTipoReg  := Subs(cMatricU,atTipReg[1],atTipReg[2])
	local lCond		:= .t.

	default cCodPla   := aDadUsr[11]
	default cVersao   := aDadUsr[12]
	default cNivCar   := ""

	//Verifica usuario
	BFO->(dbSetOrder(1))
	if BFO->(msSeek(xFilial("BFO")+cOpeUsr+cCodEmp+cMatric+cTipoReg+cClascar)) .AND. IIF(!Empty(cNivCar),cNivCar == "usuario",.T.)
		lRet := .t.
	endIf

	//Verifica familia
	if ! lRet

		BFJ->(dbSetOrder(1))
		if BFJ->(msSeek(xFilial("BFJ")+cOpeUsr+cCodEmp+cMatric+cClascar)) .AND. IIF(!Empty(cNivCar),cNivCar == "familia",.T.)
			lRet := .t.
		endIf

	endIf

	if !lRet .and. cTipoUsr == "2"

		//Verifica no subcontrato
		BA6->(dbSetOrder(1))

		lCond := BA6->(msSeek(xFilial("BA6")+cOpeUsr+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVersao+cClascar))

		if lCond .AND. IIF(!Empty(cNivCar),cNivCar == "sub",.T.)
			lRet := .t.
		endIf
	EndIf
	//Verifica no produto
	If !lRet
		BAN->(dbSetOrder(1))
		If BAN->(msSeek(xFilial("BAN")+cOpeUsr+cCodPla+cVersao+cClascar)) .And. IIF(!Empty(cNivCar),cNivCar == "produto",.T.)
			lRet := .t.
		endIf
	endIf

return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCARNIV  ³ Autor ³ PLS      Data ³ 27.12.2018				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Verifica qual o nível possui classe de carência				 .±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCARNIV(aDadUsr,cOpeUsr)

	LOCAL cNivCar := ""
	local cTipoUsr  := aDadUsr[8]
	local cCodEmp   := Subs(aDadUsr[2],5,4)
	local cConEmp   := aDadUsr[9]
	local cVerCon   := aDadUsr[39]
	local cSubCon   := aDadUsr[41]
	local cVerSub   := aDadUsr[42]
	local cMatricU  := aDadUsr[2]
	local cMatric   := Subs(cMatricU,atMatric[1],atMatric[2])
	local cTipoReg  := Subs(cMatricU,atTipReg[1],atTipReg[2])
	local lCond		:= .t.
	local cCodPla   := aDadUsr[11]
	local cVersao   := aDadUsr[12]

	//Verifica usuário
	BFO->(dbSetOrder(1))
	If BFO->(msSeek(xFilial("BFO")+cOpeUsr+cCodEmp+cMatric+cTipoReg))
		If !Empty( BFO->BFO_CLACAR)
			cNivCar := "usuario"
		EndIf
	EndIf

	//se estiver vazio, é pq não tem no usuario, verifica na familia
	If Empty(cNivCar)
		BFJ->(dbSetOrder(1))
		if BFJ->(msSeek(xFilial("BFJ")+cOpeUsr+cCodEmp+cMatric))
			If !Empty( BFJ->BFJ_CLACAR)
				cNivCar := "familia"
			EndIf
		endIf
	EndIf

	//se ainda estiver vazio, verifica no subcontrato
	If Empty(cNivCar)
		//Verifica no subcontrato
		BA6->(dbSetOrder(1))
		lCond := BA6->(msSeek(xFilial("BA6")+cOpeUsr+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVersao))
		if lCond .AND. !Empty( BA6->BA6_CLACAR)
			cNivCar := "sub"
		endIf
	EndIf
	//se ainda estiver vazio, verifica no produto
	If Empty(cNivCar)
		//Verifica no produto
		BAN->(dbSetOrder(1))
		If BAN->(msSeek(xFilial("BAN")+cOpeUsr+cCodPla+cVersao))
			if !Empty(BAN->BAN_CLACAR)
				cNivCar := "produto"
			endIf
		endIf
	EndIf

return cNivCar


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCLACAR  ³ Autor ³ Tulio Cesar       Data ³ 29.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna a classe de carencia de um usuario.               ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCLACAR(cCodOpe,cMatricUsr,dDataCar,lPortal)
	LOCAL aRet     		:= {.F.,{}}
	LOCAL aClasses 		:= {}
	LOCAL aNivCar  		:= {}
	LOCAL aDadUsr  		:= PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),'1',.F.,dDatabase,,,"NAO_VALIDAR_CARTAO")
	LOCAL dDataCarAux
	Local lImpCls  		:= .F.
	Local lClaCarUsr 	:= GetNewPar("MV_CLCAUSR",.F.) // A classe de carencia será feita pelo usuario,senão todos os registros da BDL

	default lPortal 	:= .F.

	//Usuario criticado...

	If !aDadUsr[1]
		Return(aRet)
	Endif

	//Posiciona no usuario...

	BA1->(DbSetOrder(2))
	If ! BA1->(MsSeek(xFilial("BA1")+cMatricUsr))
		Return(aRet)
	Endif

	//Posiciona no familia...

	BA3->(DbSetOrder(1))
	If ! BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
		Return(aRet)
	Endif

	//Monta todas as classes de carencias...

	BDL->(DbSetOrder(1))
	If ! BDL->(MsSeek(xFilial("BDL")+cCodOpe))
		Return(aRet)
	Endif

	While ! BDL->(Eof()) .And. BDL->(BDL_FILIAL+BDL_CODINT) == xFilial("BDL")+cCodOpe

		//verificando se o usuário possui carência cadastrada em algum nível específico, se possuir, poderá ser exibido
		//do mais específico ao mais abrangente: usuário, família, subcontrato
		If lClaCarUsr
			If PLSVERCAR({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,dDataCar},;
					aDadUsr,BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

				aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,dDataCar},;
					aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

				If Len(aNivCar) >= 6 .And. ! Empty(aNivCar[6])
					dDataCarAux := aNivCar[6]
				Else
					dDataCarAux := BA1->BA1_DATCAR
				Endif

				If BDL->(FieldPos("BDL_IMPCLS")) > 0 .And. BDL->BDL_IMPCLS == "1"
					lImpCls := .T.
				Else
					lImpCls := .F.
				EndIf

				aadd(aClasses,{BDL->BDL_CODIGO,BDL->BDL_DESCRI,;
					dDataCarAux+PLSCarDias(aNivCar[2],aNivCar[1]),;
					If(dDataCarAux+PLSCarDias(aNivCar[2],aNivCar[1])<=dDataBase,STR0051,STR0052),; //"Carencia Cumprida"###"Em Carencia"
					If(dDataCarAux+PLSCarDias(aNivCar[2],aNivCar[1])<=dDataBase,.T.,.F.),;
					lImpCls,IIf(BDL->(FieldPos("BDL_DESMSG")) > 0,BDL->BDL_DESMSG,""),;
					IIf(BDL->(FieldPos("BDL_CODEDI")) > 0,BDL->BDL_CODEDI,"")})
			EndIf
		Else
			aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,dDataCar},;
				aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

			If Len(aNivCar) >= 6 .And. ! Empty(aNivCar[6])
				dDataCarAux := aNivCar[6]
			Else
				dDataCarAux := BA1->BA1_DATCAR
			Endif

			If BDL->(FieldPos("BDL_IMPCLS")) > 0 .And. BDL->BDL_IMPCLS == "1"
				lImpCls := .T.
			Else
				lImpCls := .F.
			EndIf

			aadd(aClasses,{BDL->BDL_CODIGO,BDL->BDL_DESCRI,;
				dDataCarAux+PLSCarDias(aNivCar[2],aNivCar[1]),;
				If(dDataCarAux+PLSCarDias(aNivCar[2],aNivCar[1])<=dDataBase,STR0051,STR0052),; //"Carencia Cumprida"###"Em Carencia"
				If(dDataCarAux+PLSCarDias(aNivCar[2],aNivCar[1])<=dDataBase,.T.,.F.),;
				lImpCls,IIf(BDL->(FieldPos("BDL_DESMSG")) > 0,BDL->BDL_DESMSG,""),;
				IIf(BDL->(FieldPos("BDL_CODEDI")) > 0,BDL->BDL_CODEDI,"")})
		EndIf
		BDL->(DbSkip())

	Enddo

	If ExistBlock("PLSCLACA")
		aClasses := ExecBlock("PLSCLACA",.F.,.F.,{aClasses,aDadUsr})
	Endif


	//monta retorno...

	aRet := {If(Len(aClasses)>0,.T.,.F.),aClasses}

	//Retorno da funcao...

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSDIAMES ºAutor  ³Geraldo Felix Juniorº Data ³  24-07-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Retorna a quantidade de dias no mes...                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    Futuramente vou tratar anos bi-sextos                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSDIAMES(nMes,cAno)
	LOCAL dLastDay  := cTod('')
	LOCAL nRet 		:= 0

	// Valida parametros informados...
	If nMes < 1 .or. nMes > 12
		nRet := 0
	Else

		// Obtem o ultimo dia do mes...
		dLastDay := LastDay(cTod('01/'+StrZero(nMes,2)+'/'+cAno))

		// Conver em numeros...
		nRet := Val( Substr(dToc(dLastDay),1,2) )
	Endif

Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSFiltP6  ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 07.08.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Funcao generica para filtro tipo 6 via SXB (baseado ReadVar())³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFilTp6(cAlias, cValOpe, cValEmp)
	Local lRet 		:= .T.
	Local cFunName	:= ""
	Local dBloqueio	:=	FsDateConv(dDataBase,"YYYYMMDD")

	Default cValOpe := ""
	Default cValEmp := ""

	If ReadVar() = "M->BJL_CODFOR"
		lRet := "2" $ BJ1->BJ1_USO .And. BJ1->BJ1_TIPO = "2"	// Filtra Familia e Taxa de Adesao
	ElseIf (cFunName := FunName()) = "PLSA627"

		If cAlias = "BG9"

			lRet := BT5->(MsSeek(xFilial("BT5") + BG9->BG9_CODINT + BG9->BG9_CODIGO))

		ElseIf cAlias = "BT5"

			If ReadVar() == "M->BDW_CONEMP"
				lRet := BT5->(BT5_FILIAL + BT5_CODINT + BT5_CODIGO) == xFilial("BDW") + M->(BDW_CODOPE + BDW_CODEMP)
			Else
				lRet := BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO) == xFilial("BT5")+BG9->(BG9_CODINT+BG9_CODIGO) .And. BT5->BT5_INTERC <> "1"
			EndIf

		ElseIf cAlias = "BQC"

			lRet := BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) == xFilial("BQC")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON)

		Endif

	ElseIf FunName() == "PLSA101"

		If cAlias == "BG9" .And. Type("M->BHW_CODINT") == "C" .And. !Empty(M->BHW_CODINT)

			lRet := BG9->BG9_CODINT == M->BHW_CODINT

		ElseIf cAlias == "BT5"

			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5_CODIGO >= MV_PAR02 .And. BT5_CODIGO <= MV_PAR03

		ElseIf cAlias == "BQC"

			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR02 .And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR03 .And. BQC->BQC_NUMCON >= MV_PAR04 .And. BQC->BQC_NUMCON <= MV_PAR05

		EndIf

	ElseIf FunName() == "PLSR038"
		If cAlias == "BG9"
			lRet := BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5_CODIGO >= MV_PAR04 .And. BT5_CODIGO <= MV_PAR05
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR04 .And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR05 ;
				.And. BQC->BQC_NUMCON >= MV_PAR06 .And. BQC->BQC_NUMCON <= MV_PAR07
		EndIf
	ElseIf FunName() == "PLSR039"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR03 .And. BG9->BG9_CODINT <=MV_PAR04
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR03 .And. BT5->BT5_CODINT <= MV_PAR04 .And. BT5_CODIGO >= MV_PAR05 .And. BT5_CODIGO <= MV_PAR06
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR03+MV_PAR05 .And. BQC->BQC_CODIGO <= MV_PAR04+MV_PAR06 ;
				.And. BQC->BQC_NUMCON >= MV_PAR07 .And. BQC->BQC_NUMCON <= MV_PAR08
		EndIf
	ElseIf FunName() == "PLSR096"
		If cAlias == "BIL"
			lRet := BIL->BIL_CODIGO >= MV_PAR01+MV_PAR02 .And. BIL->BIL_CODIGO <= MV_PAR01+MV_PAR03
		EndIf

	ElseIf FunName() = "PLSA262"
		If      ReadVar() $ "M->BDE_CONDE,M->BDE_CONATE"
			lRet := BT5->BT5_CODINT == M->BDE_CODINT .and. ;
				BT5->BT5_CODIGO >= M->BDE_EMPDE .and. ;
				BT5->BT5_CODIGO <= M->BDE_EMPATE
		ElseIf  ReadVar() $ "M->BDE_SUBDE,M->BDE_SUBATE"
			lRet := BQC->BQC_CODIGO+BQC->BQC_NUMCON >= M->BDE_CODINT+M->BDE_EMPDE+M->BDE_CONDE .and. ;
				BQC->BQC_CODIGO+BQC->BQC_NUMCON <= M->BDE_CODINT+M->BDE_EMPATE+M->BDE_CONATE
		ElseIf  ReadVar() $ "M->BDE_MATDE,M->BDE_MATATE"
			lRet := BA1->BA1_CODINT == M->BDE_CODINT .and. ;
				BA1->BA1_CODEMP >= M->BDE_EMPDE .and. BA1->BA1_CODEMP <= M->BDE_EMPATE .and. ;
				BA1->BA1_CONEMP >= M->BDE_CONDE .and. BA1->BA1_CONEMP <= M->BDE_CONATE .and. ;
				BA1->BA1_SUBCON >= M->BDE_SUBDE .and. BA1->BA1_SUBCON <= M->BDE_SUBATE
		Endif
	ElseIf FunName() = "PLSA067"
		If      ReadVar() $ "M->BH1_CONDE"
			lRet := "BT5_CODINT =  '"+M->BH1_CODINT+"' .And. BT5_CODIGO = '"+M->BH1_EMPDE+"'

		Elseif ReadVar() $ "M->BH1_CONATE"
			lRet := "BT5_CODINT =  '"+M->BH1_CODINT+"' .And. BT5_CODIGO = '"+M->BH1_EMPATE+"'

		ElseIf  ReadVar() $ "M->BH1_SUBDE"
			lRet := "BQC_CODIGO+BQC_NUMCON = '"+M->BH1_CODINT+M->BH1_EMPDE+M->BH1_CONDE+"' "

		Elseif 	ReadVar() $ "M->BH1_SUBATE"
			lRet := "BQC_CODIGO+BQC_NUMCON = '"+M->BH1_CODINT+M->BH1_EMPATE+M->BH1_CONATE+"' "

		ElseIf  ReadVar() $ "M->BH1_MATDE"
			lRet := "BA1_CODINT = '"+M->BH1_CODINT+"'	.and. BA1_CODEMP = '"+M->BH1_EMPDE+"' .and. "+;
				"BA1_CONEMP = '"+M->BH1_CONDE +"'	.and. BA1_SUBCON = '"+M->BH1_SUBDE+"' "

		Elseif 	ReadVar() $ "M->BH1_MATATE"
			lRet := "BA1_CODINT = '"+M->BH1_CODINT+"'	.and. BA1_CODEMP = '"+M->BH1_EMPDE+"' .and. "+;
				"BA1_CONEMP = '"+M->BH1_CONATE+"'	.and. BA1_SUBCON = '"+M->BH1_SUBATE+"' "
		Endif
	ElseIf FunName() == "PLSA772" .OR. FunName() == "PLSR407"
		If cAlias == "BG9"
			lRet := (BG9->BG9_TIPO == AllTrim(STR(MV_PAR01)) .OR. MV_PAR01 == 3) .AND. BG9->BG9_CODINT >= MV_PAR02 .And. BG9->BG9_CODINT <= MV_PAR03
		ElseIf cAlias == "BT5"
			lRet := (AllTrim(STR(MV_PAR01)) $ ("2/3")) .AND. BT5->BT5_CODINT >= MV_PAR02 .And. BT5->BT5_CODINT <= MV_PAR03 .And. BT5_CODIGO >= MV_PAR04 .And. BT5_CODIGO <= MV_PAR05
		ElseIf cAlias == "BQC"
			lRet := (AllTrim(STR(MV_PAR01)) $ ("2/3")) .AND. BQC->BQC_CODIGO >= MV_PAR02+MV_PAR04 .And. BQC->BQC_CODIGO <= MV_PAR03+MV_PAR05 ;
				.And. BQC->BQC_NUMCON >= MV_PAR06 .And. BQC->BQC_NUMCON <= MV_PAR07
		EndIf
	ElseIf FunName() $ "PLSM150,PLSM151"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR03
		ElseIf cAlias == "BT5"
			lRet := BT5->(BT5_FILIAL+BT5_CODINT) == xFILIAL("BT5")+MV_PAR03 .And.;
				BT5->BT5_CODIGO >= MV_PAR04 .And. BT5->BT5_CODIGO <= MV_PAR05
		ElseIf cAlias == "BQC"
			lRet := BQC->(BQC_FILIAL+BQC_CODINT) == xFILIAL("BQC")+MV_PAR03 .And.;
				Substr(BQC->(BQC_CODIGO),5,4)+BQC->BQC_NUMCON >= MV_PAR04+MV_PAR06 .and. ;
				Substr(BQC->(BQC_CODIGO),5,4)+BQC->BQC_NUMCON <= MV_PAR05+MV_PAR07
		EndIf
	ElseIf FunName() $ "PLSM135,PLSM132,PLSM130,PLSM180,PLSR251"
		lRet := .T.
	ElseIf FunName() == "PLSR026"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT ==MV_PAR01
		EndIf
	ElseIf FunName() == "PLSR163"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR01 .And. BG9->BG9_CODINT <=MV_PAR02
		ElseIf cAlias == "BAQ"
			lRet := BAQ_CODINT  >=MV_PAR01 .And. BAQ_CODINT  <=MV_PAR02
		EndIf
	ElseIf FunName() == "PLSR199"
		If cAlias == "BG9"
			lRet := BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5_CODIGO >= MV_PAR02 .And. BT5_CODIGO <= MV_PAR03
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR02 .And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR03 ;
				.And. BQC->BQC_NUMCON >= MV_PAR04 .And. BQC->BQC_NUMCON <= MV_PAR05
		EndIf
	ElseIf FunName() == "PLSR250"
		If cAlias == "BG9"
			lRet := BG9_CODINT == PLSINTPAD()
		ElseIf cAlias == "BA1"
			lRet := BA1->BA1_CODINT == PLSINTPAD() .And. BA1->BA1_CODEMP >= MV_PAR02 .And. BA1->BA1_CODEMP <= MV_PAR03
		EndIf
	ElseIf FunName() == "PLSR256"
		If cAlias == "BG9"
			Do Case
				Case MV_PAR05 < 3
					lRet := BG9->BG9_CODINT == MV_PAR04 .And. BG9->BG9_TIPO == AllTrim(Str(MV_PAR05))
				Case MV_PAR05 == 3
					lRet := BG9->BG9_CODINT == MV_PAR04
			EndCase
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR04 .And. BT5_CODIGO >= MV_PAR06 .And. BT5_CODIGO <= MV_PAR07
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR04+MV_PAR06 .And. BQC->BQC_CODIGO <= MV_PAR04+MV_PAR07 ;
				.And. BQC->BQC_NUMCON >= MV_PAR08 .And. BQC->BQC_NUMCON <= MV_PAR09
		ElseIf cAlias == "BA1"
			lRet := BA1->BA1_CODINT == MV_PAR04 .And. BA1->BA1_CODEMP >= MV_PAR06 .And. BA1->BA1_CODEMP <= MV_PAR07
		ElseIf cAlias == "BI3"
			lRet := BI3->BI3_CODINT == AllTrim(MV_PAR04)
		EndIf
	ElseIf FunName() == "PLSR266"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR05 .And. BG9->BG9_CODINT <=MV_PAR06	.And. BG9->BG9_TIPO == AllTrim(Str(MV_PAR01))
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR05 .And. BT5->BT5_CODINT <= MV_PAR06 .And. BT5_CODIGO >= MV_PAR07 .And. BT5_CODIGO <= MV_PAR08
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR05+MV_PAR07 .And. BQC->BQC_CODIGO <= MV_PAR06+MV_PAR08 ;
				.And. BQC->BQC_NUMCON >= MV_PAR09 .And. BQC->BQC_NUMCON <= MV_PAR10
		ElseIf cAlias == "BA1"
			lRet := BA1->BA1_CODINT >= MV_PAR05 .And. BA1->BA1_CODINT <= MV_PAR06 .And. BA1->BA1_CODEMP >= MV_PAR07 .And. BA1->BA1_CODEMP <= MV_PAR08
		EndIf
	ElseIf FunName() == "PLSR315"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR01 .And. BG9->BG9_CODINT <=MV_PAR02
		ElseIf cAlias == "BA1"
			lRet := BA1->BA1_CODINT >= MV_PAR01 .And. BA1->BA1_CODINT <= MV_PAR01 .And. BA1->BA1_CODEMP >= MV_PAR08 .And. BA1->BA1_CODEMP <= MV_PAR09
		EndIf
	ElseIf FunName() == "PLSR580"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR05 .And. BG9->BG9_CODINT <=MV_PAR06
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR05 .And. BT5->BT5_CODINT <= MV_PAR06 .And. BT5_CODIGO >= MV_PAR07 .And. BT5_CODIGO <= MV_PAR08
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR05+MV_PAR07 .And. BQC->BQC_CODIGO <= MV_PAR06+MV_PAR08 ;
				.And. BQC->BQC_NUMCON >= MV_PAR09 .And. BQC->BQC_NUMCON <= MV_PAR10
		ElseIf cAlias == "BA1"
			lRet := BA1->BA1_CODINT >= MV_PAR05 .And. BA1->BA1_CODINT <= MV_PAR06 .And. BA1->BA1_CODEMP >= MV_PAR07 .And. BA1->BA1_CODEMP <= MV_PAR08
		EndIf
	ElseIf FunName() == "PLSR595"
		If cAlias == "BG9" //Grupos empresas
			lRet := BG9->BG9_CODINT >=MV_PAR01 .And. BG9->BG9_CODINT <=MV_PAR02
		ElseIf cAlias == "BT5" //Grupo de empresa contrato
			lRet := BT5->BT5_CODINT >= MV_PAR01 .And. BT5->BT5_CODINT <= MV_PAR02 .And. BT5_CODIGO >= MV_PAR05 .And. BT5_CODIGO <= MV_PAR06
		ElseIf cAlias == "BQC" //Subcontrato
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR05 .And. BQC->BQC_CODIGO <= MV_PAR02+MV_PAR06 ;
				.And. BQC->BQC_NUMCON >= MV_PAR07 .And. BQC->BQC_NUMCON <= MV_PAR08
		ElseIf cAlias == "BA1" //Usuario
			lRet := BA1->BA1_CODINT >= MV_PAR01 .And. BA1->BA1_CODINT <= MV_PAR02 .And. BA1->BA1_CODEMP >= MV_PAR05 .And. BA1->BA1_CODEMP <= MV_PAR06
		ElseIf cAlias == "BDC" //Lotes de cobranca
			lRet := BDC->BDC_CODOPE >= MV_PAR01 .And. BDC->BDC_CODOPE <= MV_PAR02
		EndIf
	ElseIf FunName() == "PLSR614"
		If cAlias == "BG9"
			lRet := BG9_CODINT == MV_PAR08
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR08 .And. BT5_CODIGO >= MV_PAR09 .And. BT5_CODIGO <= +MV_PAR10
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR08+MV_PAR09 .And. BQC->BQC_CODIGO <= MV_PAR08+MV_PAR10 ;
				.And. BQC->BQC_NUMCON >= MV_PAR11 .And. BQC->BQC_NUMCON <= MV_PAR12
		EndIf
	ElseIf FunName() == "PLSR671"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR01 .And. BG9->BG9_CODINT <=MV_PAR02
		EndIf
	ElseIf FunName() == "PLSR761"
		If cAlias == "BG9"
			lRet := BG9_CODINT == PLSINTPAD()
		EndIf
	ElseIf FunName() == "PLSR198"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR02 .And. BG9->BG9_CODINT <=MV_PAR03
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR02 .And. BT5->BT5_CODINT <= MV_PAR03 .And. BT5_CODIGO >= MV_PAR04 .And. BT5_CODIGO <= MV_PAR05
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR02+MV_PAR04 .And. BQC->BQC_CODIGO <= MV_PAR03+MV_PAR05 ;
				.And. BQC->BQC_NUMCON >= MV_PAR06 .And. BQC->BQC_NUMCON <= MV_PAR07
		EndIf
	ElseIf FunName() == "PLSR101"
		If cAlias == "BG9"
			lRet := BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5_CODIGO >= MV_PAR02 .And. BT5_CODIGO <= MV_PAR03
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR02 .And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR03 ;
				.And. BQC->BQC_NUMCON >= MV_PAR06 .And. BQC->BQC_NUMCON <= MV_PAR07
		ElseIf cAlias == "BA3"
			lRet := .T.
		EndIf
	ElseIf FunName() == "PLSR161"
		If cAlias == "BG9"
			lRet := (BG9->BG9_TIPO == AllTrim(STR(MV_PAR01)) .OR. MV_PAR01 == 3) .AND. BG9->BG9_CODINT >=MV_PAR03 .And. BG9->BG9_CODINT <=MV_PAR04
		ElseIf cAlias == "BT5"
			lRet := (AllTrim(STR(MV_PAR01)) $ ("2/3")) .AND. BT5->BT5_CODINT >= MV_PAR03 .And. BT5->BT5_CODINT <= MV_PAR04 .And. BT5_CODIGO >= MV_PAR05 .And. BT5_CODIGO <= MV_PAR06
		ElseIf cAlias == "BQC"
			lRet := (AllTrim(STR(MV_PAR01)) $ ("2/3")) .AND. BQC->BQC_CODIGO >= MV_PAR03+MV_PAR05 .And. BQC->BQC_CODIGO <= MV_PAR04+MV_PAR06 ;
				.And. BQC->BQC_NUMCON >= MV_PAR07 .And. BQC->BQC_NUMCON <= MV_PAR08
		ElseIf cAlias == "BI3"
			lRet := BI3->BI3_CODINT >= MV_PAR03 .And. BI3->BI3_CODINT <= MV_PAR04
		EndIf
	ElseIf FunName() == "PLSR166"
		If cAlias == "BG9"
			lRet := (BG9->BG9_TIPO == AllTrim(STR(MV_PAR01)) .OR. MV_PAR01 == 3) .AND. BG9->BG9_CODINT >= MV_PAR03 .And. BG9->BG9_CODINT <= MV_PAR04
		ElseIf cAlias == "BT5"
			lRet := (AllTrim(STR(MV_PAR01)) $ ("2/3")) .AND. BT5->BT5_CODINT >= MV_PAR03 .And. BT5->BT5_CODINT <= MV_PAR04 .And. BT5_CODIGO >= MV_PAR05 .And. BT5_CODIGO <= MV_PAR06
		ElseIf cAlias == "BQC"
			lRet := (AllTrim(STR(MV_PAR01)) $ ("2/3")) .AND. BQC->BQC_CODIGO >= MV_PAR03+MV_PAR05 .And. BQC->BQC_CODIGO <= MV_PAR04+MV_PAR06 ;
				.And. BQC->BQC_NUMCON >= MV_PAR07 .And. BQC->BQC_NUMCON <= MV_PAR08
		ElseIf cAlias == "BI3"
			lRet := BI3->BI3_CODINT >= MV_PAR03 .And. BI3->BI3_CODINT <= MV_PAR04
		EndIf
	ElseIf FunName() == "PLSA771"
		If cAlias == "BG9"
			lRet :=  BG9->BG9_TIPO $ ("1/3") .And. BG9->BG9_CODINT >= MV_PAR02 .And. BG9->BG9_CODINT <= MV_PAR03
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR01 .And. BT5->BT5_CODINT <= MV_PAR02 .And. BT5_CODIGO >= MV_PAR03 .And. BT5_CODIGO <= MV_PAR04
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR03 .And. BQC->BQC_CODIGO <= MV_PAR02+MV_PAR04 ;
				.And. BQC->BQC_NUMCON >= MV_PAR05 .And. BQC->BQC_NUMCON <= MV_PAR06
		ElseIf cAlias == "BA1"
			lRet := BA1->BA1_CODINT >= MV_PAR01 .And. BA1->BA1_CODINT <= MV_PAR02 .And. BA1->BA1_CODEMP >= MV_PAR03 .And. BA1->BA1_CODEMP <= MV_PAR04
		EndIf
	ElseIf FunName() == "PLSR400"
		If cAlias == "BA8"
			lRet := BA8->BA8_CODPAD >=MV_PAR01 .And. BA8->BA8_CODPAD <=MV_PAR02 .And. Substr(BA8->BA8_CODTAB,1,4) == PLSINTPAD() .And. BA8->BA8_NIVEL == "3"
		EndIf
	ElseIf FunName() == "PLSR453"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR01 .And. BG9->BG9_CODINT <=MV_PAR02
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR01 .And. BT5->BT5_CODINT <= MV_PAR02 .And. BT5_CODIGO >= MV_PAR03 .And. BT5_CODIGO <= MV_PAR04
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR03 .And. BQC->BQC_CODIGO <= MV_PAR02+MV_PAR04 ;
				.And. BQC->BQC_NUMCON >= MV_PAR05 .And. BQC->BQC_NUMCON <= MV_PAR06
		EndIf
	ElseIf FunName() == "PLSR504"
		If cAlias == "BA8"
			If !Empty(MV_PAR02)
				lRet := BA8->BA8_CODTAB == MV_PAR02
			EndIf
		EndIf
	ElseIf FunName() == "PLSR615"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR05 .And. BG9->BG9_CODINT <=MV_PAR06
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR05 .And. BT5->BT5_CODINT <= MV_PAR06 .And. BT5_CODIGO >= MV_PAR07 .And. BT5_CODIGO <= MV_PAR08
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR05+MV_PAR07 .And. BQC->BQC_CODIGO <= MV_PAR06+MV_PAR08 ;
				.And. BQC->BQC_NUMCON >= MV_PAR09 .And. BQC->BQC_NUMCON <= MV_PAR10
		EndIf
	ElseIf FunName() == "PLSR022"
		If cAlias == "BT5"
			lRet := BT5->BT5_CODIGO == MV_PAR02
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_NUMCON == MV_PAR03 .AND. BQC->BQC_CODEMP == MV_PAR02 .AND. BQC->BQC_CODINT == MV_PAR01
		ElseIf cAlias == "BA1"
			lRet := BA1->BA1_SUBCON == MV_PAR04 .AND. BA1->BA1_CODEMP == MV_PAR02 .AND. BA1->BA1_CONEMP == MV_PAR03 .AND. BA1->BA1_CODINT == MV_PAR01
		EndIf
	ElseIf FunName() == "PLSR618"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR04 .And. BG9->BG9_CODINT <=MV_PAR05
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR04 .And. BT5->BT5_CODINT <= MV_PAR05 .And. BT5_CODIGO >= MV_PAR06 .And. BT5_CODIGO <= MV_PAR07
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR04+MV_PAR06 .And. BQC->BQC_CODIGO <= MV_PAR05+MV_PAR07 ;
				.And. BQC->BQC_NUMCON >= MV_PAR08 .And. BQC->BQC_NUMCON <= MV_PAR09
		EndIf
	ElseIf FunName() == "PLSR629"
		If cAlias == "BG7"
			lRet := BG7->BG7_CODINT >=MV_PAR01 .And. BG7->BG7_CODINT <=MV_PAR02
		EndIf
	ElseIf FunName() == "PLSR660"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == PLSINTPAD() .And. BG9->BG9_TIPO == "2"
		EndIf
	ElseIf FunName() == "PLSR816"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT >=MV_PAR01 .And. BG9->BG9_CODINT <=MV_PAR02
		EndIf
	ElseIf FunName() == "PLSR820"
		If cAlias == "BAQ"
			lRet := BAQ->BAQ_CODINT == PLSINTPAD()
		EndIf
	ElseIf FunName() == "PLSR097"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= MV_PAR02 .And. BT5->BT5_CODIGO <= MV_PAR03
		ElseIf cAlias == "BQC"
			lRet	:=	BQC->BQC_CODIGO >= MV_PAR01+MV_PAR02 	.And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR03 .And. ;
				BQC->BQC_NUMCON >= MV_PAR04 				.And. BQC->BQC_NUMCON <= MV_PAR05
		EndIf
	ElseIf FunName() == "PLSR510"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= MV_PAR06 .And. BT5->BT5_CODIGO <= MV_PAR07
		ElseIf cAlias == "BQC"
			lRet	:=	BQC->BQC_CODIGO >= MV_PAR01+MV_PAR06 	.And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR07 .And. ;
				BQC->BQC_NUMCON >= MV_PAR08 				.And. BQC->BQC_NUMCON <= MV_PAR09
		EndIf
	ElseIf FunName() == "PLSR511"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= MV_PAR04 .And. BT5->BT5_CODIGO <= MV_PAR05
		ElseIf cAlias == "BQC"
			lRet	:=	BQC->BQC_CODIGO >= MV_PAR01+MV_PAR04 	.And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR05 .And. ;
				BQC->BQC_NUMCON >= MV_PAR06 				.And. BQC->BQC_NUMCON <= MV_PAR07
		EndIf
	ElseIf FunName() == "PLSR415"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR02
		EndIf
	ElseIf FunName() == "PLSR987"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5_CODINT == MV_PAR01 .And. BT5_CODIGO >= MV_PAR02 .And. BT5_CODIGO <= MV_PAR03
		ElseIf cAlias == "BQC"
			lRet := BQC_CODIGO >= MV_PAR01 + MV_PAR02 .And. BQC_CODIGO <= MV_PAR01 + MV_PAR03 .And. BQC_NUMCON >= MV_PAR04 .And. BQC_NUMCON <= MV_PAR05
		EndIf
	ElseIf FunName() == "PLSR674"
		If cAlias == "BCI"
			lRet := AllTrim(BCI->BCI_CODOPE) == AllTrim(MV_PAR02) .And. BCI->BCI_ANO = MV_PAR04 .And. BCI->BCI_MES = MV_PAR05	.And. BCI->BCI_CODRDA == MV_PAR03
		EndIf
		If cAlias == "BAF"
			lRet := AllTrim(BAF->BAF_CODOPE) == AllTrim(MV_PAR02)
		EndIf
	ElseIf FunName() == "PLSR673"
		If cAlias == "BDC"
			lRet := AllTrim(BDC->BDC_CODOPE) == AllTrim(MV_PAR01)
		ElseIf cAlias == "BCI"
			lRet := AllTrim(BCI->BCI_CODOPE) == AllTrim(MV_PAR01) .And.;
				BCI->BCI_CODRDA >= MV_PAR02 .And. BCI->BCI_CODRDA <= MV_PAR03 .And.;
				BCI->BCI_ANO == MV_PAR04 .And. BCI->BCI_MES == MV_PAR05

		ElseIf cAlias == "BAQ"
			lRet := AllTrim(BAQ->BAQ_CODINT) == AllTrim(MV_PAR01)
		ElseIf cAlias == "BG9"
			lRet := AllTrim(BG9->BG9_CODINT) == AllTrim(MV_PAR01)
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= MV_PAR28 .And. BT5->BT5_CODIGO <= MV_PAR29
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR28 .And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR29 ;
				.And. BQC->BQC_NUMCON >= MV_PAR30 .And. BQC->BQC_NUMCON <= MV_PAR31
		ElseIf cAlias == "BI3"
			lRet := BI3->BI3_CODINT == AllTrim(MV_PAR01)
		ElseIf cAlias == "BD1"
			lRet := BD1->BD1_CODINT == AllTrim(MV_PAR01)
		EndIf
	ElseIf FunName() == "PLSR454"
		If cAlias == "BAQ"
			lRet := AllTrim(BAQ->BAQ_CODINT) >= AllTrim(MV_PAR01) .And. AllTrim(BAQ->BAQ_CODINT) <= AllTrim(MV_PAR02)
		ElseIf cAlias == "BG9"
			lRet := AllTrim(BG9->BG9_CODINT) >= AllTrim(MV_PAR01) .And. AllTrim(BG9->BG9_CODINT) <= AllTrim(MV_PAR02)
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT >= MV_PAR01 .And. BT5->BT5_CODINT <= MV_PAR02 .And. BT5->BT5_CODIGO >= MV_PAR11 .And. BT5->BT5_CODIGO <= MV_PAR12
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR11 .And. BQC->BQC_CODIGO <= MV_PAR02+MV_PAR12 ;
				.And. BQC->BQC_NUMCON >= MV_PAR13 .And. BQC->BQC_NUMCON <= MV_PAR14
		ElseIf cAlias == "BD1"
			lRet := BD1->BD1_CODINT >= MV_PAR01 .And. BD1->BD1_CODINT <= MV_PAR02
		EndIf
	ElseIf FunName() == "PLSR023"
		If cAlias == "BDC"
			lRet := BDC->BDC_CODOPE == MV_PAR01 .And.;
				BDC->BDC_ANOINI >= MV_PAR05 .And. BDC->BDC_ANOFIM <= MV_PAR06 .And.;
				BDC->BDC_MESINI >= MV_PAR07 .And. BDC->BDC_MESFIM <= MV_PAR08
		EndIf
	ElseIf FunName() == "PLSR760"
		If cAlias == "BDC"
			lRet := .T.
		EndIf
	ElseIf FunName() == "PLSR025"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= MV_PAR02 .And. BT5->BT5_CODIGO <= MV_PAR03
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+MV_PAR02 .And. BQC->BQC_CODIGO <= MV_PAR01+MV_PAR03 ;
				.And. BQC->BQC_NUMCON >= MV_PAR04 .And. BQC->BQC_NUMCON <= MV_PAR05
		ElseIf cAlias == "BA1"
			If Empty(MV_PAR04) .And. Empty(MV_PAR05)
				lRet := BA1->BA1_CODINT == MV_PAR01 .And. BA1->BA1_CODEMP >= MV_PAR02 .And. BA1->BA1_CODEMP <= MV_PAR03
			Else
				lRet := BA1->BA1_CODINT == MV_PAR01 .And. BA1->BA1_CODEMP >= MV_PAR02 .And. BA1->BA1_CODEMP <= MV_PAR03 .And.;
					BA1->BA1_CONEMP >= MV_PAR04 .And. BA1->BA1_CONEMP <= MV_PAR05 .And. BA1->BA1_SUBCON >= MV_PAR06 .And. BA1->BA1_SUBCON <= MV_PAR07
			EndIf
		ElseIf cAlias == "BR81"
			lRet := BR8->BR8_CODPAD == MV_PAR18
		ElseIf cAlias == "BR82"
			lRet := BR8->BR8_CODPAD == MV_PAR20
		EndIf
	ElseIf FunName() == "PLSR732" .Or. FunName() == "PLSR733"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= AllTrim(MV_PAR04) .And. BT5->BT5_CODIGO <= AllTrim(MV_PAR05)
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+AllTrim(MV_PAR04) .And. BQC->BQC_CODIGO <= MV_PAR01+AllTrim(MV_PAR05);
				.And. BQC->BQC_NUMCON >= MV_PAR06 .And. BQC->BQC_NUMCON <= MV_PAR07
		EndIf
	ElseIf FunName() == "PLSR734"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= AllTrim(MV_PAR02) .And. BT5->BT5_CODIGO <= AllTrim(MV_PAR03)
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+AllTrim(MV_PAR02) .And. BQC->BQC_CODIGO <= MV_PAR01+AllTrim(MV_PAR03);
				.And. BQC->BQC_NUMCON >= MV_PAR04 .And. BQC->BQC_NUMCON <= MV_PAR05
		ElseIf cAlias == "BA3"
			If Empty(MV_PAR04) .And. Empty(MV_PAR05)
				lRet := BA3->BA3_CODINT == MV_PAR01 .And. BA3->BA3_CODEMP >= MV_PAR02 .And. BA3->BA3_CODEMP <= MV_PAR03
			Else
				lRet := BA3->BA3_CODINT == MV_PAR01 .And. BA3->BA3_CODEMP >= MV_PAR02 .And. BA3->BA3_CODEMP <= MV_PAR03 .And.;
					BA3->BA3_CONEMP >= MV_PAR04 .And. BA3->BA3_CONEMP <= MV_PAR05 .And.;
					BA3->BA3_SUBCON >= MV_PAR06 .And. BA3->BA3_SUBCONEMP <= MV_PAR07
			EndIf
		EndIf
	ElseIf FunName() = "PLSA268"

		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == M->B52_CODINT
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == M->B52_CODINT .And. BT5->BT5_CODIGO >= AllTrim(M->B52_EMPDE) .And. BT5->BT5_CODIGO <= AllTrim(M->B52_EMPATE)
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= M->B52_CODINT+AllTrim(M->B52_EMPDE ) .And. BQC->BQC_CODIGO <= M->B52_CODINT+AllTrim(M->B52_EMPATE );
				.And. BQC->BQC_NUMCON >= M->B52_CONDE .And. BQC->BQC_NUMCON <= M->B52_CONATE
		Endif
	ElseIf FunName() = "PLSA101"
		If cAlias == "BG9" .And. Type("M->BHW_CODINT") == "C" .And. !Empty(M->BHW_CODINT)
			lRet := BG9->BG9_CODINT == M->BHW_CODINT
		Endif
	ElseIf FunName() = "PLSA226"

		If cAlias == "BT5"
			lRet := BT5->BT5_CODINT == cCodInt .And. BT5->BT5_CODIGO == cCodEmp

		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO == cCodInt+cCodEmp .And. BQC->(BQC_NUMCON+BQC_VERCON) == cCodConVer .And. (BQC->BQC_CODBLO == Space( TamSx3("BQC_CODBLO")[1] ) .Or. dBloqueio < DToS(BQC->BQC_DATBLO) )

		ElseIf cAlias == "BAU"
			lRet := BAU->BAU_CODBLO == Space( TamSx3("BAU_CODBLO")[1] ) .Or. dBloqueio < DToS(BAU->BAU_DATBLO)
		EndIf

	ElseIf FunName() == "PLSR446"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR05
		ElseIf cAlias == "BT5"    //CONTRATO
			lRet := BT5->BT5_CODINT == MV_PAR05 .And. BT5->BT5_CODIGO >= AllTrim(MV_PAR16) .And. BT5->BT5_CODIGO <= AllTrim(MV_PAR17)

		ElseIf cAlias == "BQC"      //SUBCONTRATO
			lRet := BQC->BQC_CODIGO >= MV_PAR05+AllTrim(MV_PAR16) .And. BQC->BQC_CODIGO <= MV_PAR05+AllTrim(MV_PAR17);
				.And. BQC->BQC_NUMCON >= MV_PAR18 .And. BQC->BQC_NUMCON <= MV_PAR19 ;
				.And. BQC->BQC_VERCON >= MV_PAR20 .And. BQC->BQC_VERCON <= MV_PAR21 ;

		ElseIf cAlias =="BT5VER"      //VERSAO CONTRATO

			lRet := BT5->BT5_CODINT == MV_PAR05 .And. BT5->BT5_CODIGO >= AllTrim(MV_PAR16) .And. BT5->BT5_CODIGO <= AllTrim(MV_PAR17);
				.And. BT5->BT5_NUMCON >= MV_PAR18 .And. BT5->BT5_NUMCON <= MV_PAR19
		Elseif cAlias=="BQCVER"
			lRet := BQC->BQC_CODIGO >= MV_PAR05+AllTrim(MV_PAR16) .And. BQC->BQC_CODIGO <= MV_PAR05+AllTrim(MV_PAR17);
				.And. BQC->BQC_NUMCON >= MV_PAR18 .And. BQC->BQC_NUMCON <= MV_PAR19 ;
				.And. BQC->BQC_VERCON >= MV_PAR20 .And. BQC->BQC_VERCON <= MV_PAR21 ;
				.And. BQC->BQC_SUBCON >= MV_PAR22 .And. BQC->BQC_SUBCON <= MV_PAR23 ;


		EndIf

	ElseIf FunName() == "PLSR994"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= AllTrim(MV_PAR03) .And. BT5->BT5_CODIGO <= AllTrim(MV_PAR04)
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+AllTrim(MV_PAR03) .And. BQC->BQC_CODIGO <= MV_PAR01+AllTrim(MV_PAR04);
				.And. BQC->BQC_NUMCON >= MV_PAR05 .And. BQC->BQC_NUMCON <= MV_PAR07
		EndIf

	ElseIf FunName() == "PLSR029"
		If cAlias == "BG9"
			lRet := BG9->BG9_CODINT == MV_PAR01
		ElseIf cAlias == "BT5"
			lRet := BT5->BT5_CODINT == MV_PAR01 .And. BT5->BT5_CODIGO >= AllTrim(MV_PAR02) .And. BT5->BT5_CODIGO <= AllTrim(MV_PAR03)
		ElseIf cAlias == "BQC"
			lRet := BQC->BQC_CODIGO >= MV_PAR01+AllTrim(MV_PAR02) .And. BQC->BQC_CODIGO <= MV_PAR01+AllTrim(MV_PAR03);
				.And. BQC->BQC_NUMCON >= MV_PAR04 .And. BQC->BQC_NUMCON <= MV_PAR05
		EndIf
	ElseIf (cFunName := FunName()) = "PLSAGECOB"

		// If cAlias = "BG9"
		// 	lRet := BT5->(MsSeek(xFilial("BT5") + BG9->BG9_CODINT + BG9->BG9_CODIGO))
		// Else
		If cAlias = "BT5"

			If ReadVar() == "M->B6K_NUMCON" .Or. ReadVar() == "M->B6K_CONFIN"
				If !Empty(cValOpe) .And. !Empty(cValEmp)
					lRet := BT5->(BT5_FILIAL + BT5_CODINT + BT5_CODIGO) == xFilial("B6K") + cValOpe + cValEmp
				Else
					Help("",1,"REGNOIS")
					lRet := .F.
				EndIf
			Else
				lRet := BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO) == xFilial("BT5")+BG9->(BG9_CODINT+BG9_CODIGO) .And. BT5->BT5_INTERC <> "1"
			EndIf
			// ElseIf cAlias = "BQC"
			// 	lRet := BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) == xFilial("BQC")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON)
		Endif
	Else
		If  cFunName = "PLSA980"
			lRet := .T.
		ElseIf FunName() = "PLSA756"
			If cAlias = "BG9"
				lRet := BG9->BG9_CODINT == M->BSQ_CODINT
			ElseiF cAlias = "BT5"
				lRet := BT5->BT5_CODINT == M->BSQ_CODINT .and. ;
					BT5->BT5_CODIGO == M->BSQ_CODEMP
			ElseiF cAlias = "BQC"
				lRet := BQC->BQC_CODIGO == M->BSQ_CODINT+M->BSQ_CODEMP .and. ;
					BQC->BQC_NUMCON == M->BSQ_CONEMP
			Endif
		Endif
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSRETIP   ³ Autor ³ Luciano Aparecido Data ³ 25.10.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna se e pessoa fisica ou Jurídica para ser usado no  ±±
±±³       retorno XB para tratar filtro pessoa Fisica(baseado ReadVar())³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETIP()
	Local cTipo:=""
	//tratar filtro do contrato e sub-contrato, para pessoa física não trazer conteudo
	// pois o filtro fica posicionado no primeiro registro.
	If IndexOrd() = 1 .And. ReadVar() = "M->BXR_CONEMP"
		If !Empty(M->BXR_CODEMP)
			cTipo:=	Posicione("BG9",1,xFilial("BG9")+M->(BX4_CODINT+BXR_CODEMP),"BG9_TIPO")
		Else
			cTipo:="1"//atribui pessoa fisica para não trazer nada no filtro
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BXR_SUBCON"
		If !Empty(M->BXR_CODEMP)
			cTipo:=	Posicione("BG9",1,xFilial("BG9")+M->(BX4_CODINT+BXR_CODEMP),"BG9_TIPO")
		Else
			cTipo:="1"//atribui pessoa fisica para não trazer nada no filtro
		Endif
	Endif

Return cTipo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSFilTp7  ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 01.08.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Funcao generica para filtro tipo 7 via SXB (baseado ReadVar())³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFilTp7(cAlias,cSeq, cValEmp, cNumCon, cVerCon)

	Local cFiltro := ""

	Default cValEmp := ""
	Default cNumCon := ""
	Default cVerCon := ""

	If IndexOrd() = 1 .And. ReadVar() = "M->BJA_MOTIVO"
		cFiltro := M->BA0_CODIDE + M->BA0_CODINT
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BJB_MOTIVO"
		cFiltro := M->BI3_CODINT
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BJC_MOTIVO"
		cFiltro := M->BQC_CODINT
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BHW_CODEMP"
		cFiltro := M->BHW_CODINT
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BHW_CONEMP"
		cFiltro := M->BHW_CODINT + M->BHW_CODEMP
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BHW_SUBCON"
		cFiltro := M->BHW_CODINT + M->BHW_CODEMP + M->BHW_CONEMP + M->BHW_VERCON
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BDW_CODEMP"
		cFiltro := cCodInt
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BDW_CONEMP"
		cFiltro := cCodInt + M->BDW_CODEMP
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BDW_SUBCON"
		cFiltro := cCodInt + M->BDW_CODEMP + M->BDW_CONEMP + M->BDW_VERCON
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BDW_CODEMF"
		cFiltro := cCodInt
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BDW_CONEMF"
		cFiltro := cCodInt + M->BDW_CODEMF
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BDW_SUBCOF"
		cFiltro := cCodInt + M->BDW_CODEMF + M->BDW_CONEMF + M->BDW_VERCOF
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BXR_CODEMP"
		cFiltro := M->BX4_CODINT
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BXR_CONEMP"
		BT5->(MsSeek(xFilial("BT5") + M->BX4_CODINT + M->BXR_CODEMP))
		cFiltro := M->BX4_CODINT + M->BXR_CODEMP
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BXR_SUBCON"
		BQC->(MsSeek(xFilial("BQC") + M->BX4_CODINT + M->BXR_CODEMP + M->BXR_CONEMP + M->BXR_VERCON))
		cFiltro := M->BX4_CODINT + M->BXR_CODEMP + M->BXR_CONEMP + M->BXR_VERCON
	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->BDE_CONDE,M->BDE_CONATE"
		If  cSeq == "1"
			cFiltro := M->BDE_CODINT + M->BDE_EMPDE
		Else
			cFiltro := M->BDE_CODINT + M->BDE_EMPATE
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->BDE_SUBDE,M->BDE_SUBATE"
		If  cSeq == "1"
			cFiltro := M->BDE_CODINT + M->BDE_EMPDE + M->BDE_CONDE
		Else
			cFiltro := M->BDE_CODINT + M->BDE_EMPATE + M->BDE_CONATE
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->BDE_MATDE,M->BDE_MATATE"
		If  cSeq == "1"
			cFiltro := M->BDE_CODINT + M->BDE_EMPDE
		Else
			cFiltro := M->BDE_CODINT + M->BDE_EMPATE
		Endif

	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->BH1_CONDE,M->BH1_CONATE"
		If  cSeq == "1"
			cFiltro := M->BH1_CODINT + M->BH1_EMPDE
		Else
			cFiltro := M->BH1_CODINT + M->BH1_EMPATE
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->BH1_SUBDE,M->BH1_SUBATE"
		If  cSeq == "1"
			cFiltro := M->BH1_CODINT + M->BH1_EMPDE + M->BH1_CONDE
		Else
			cFiltro := M->BH1_CODINT + M->BH1_EMPATE + M->BH1_CONATE
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->BH1_MATDE,M->BH1_MATATE"
		If  cSeq == "1"
			cFiltro := M->BH1_CODINT + M->BH1_EMPDE
		Else
			cFiltro := M->BH1_CODINT + M->BH1_EMPATE
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BSQ_CONEMP"
		BT5->(MsSeek(xFilial("BT5") +  M->BSQ_CODINT + M->BSQ_CODEMP))
		cFiltro := M->BSQ_CODINT + M->BSQ_CODEMP
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->BSQ_SUBCON"
		BQC->(MsSeek(xFilial("BQC") + M->BSQ_CODINT + M->BSQ_CODEMP + M->BSQ_CONEMP))
		cFiltro := M->BSQ_CODINT + M->BSQ_CODEMP+M->BSQ_CONEMP
	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->B52_CONDE,M->B52_CONATE"
		If cSeq == "1"
			cFiltro := M->B52_CODINT + M->B52_EMPDE
		Else
			cFiltro := M->B52_CODINT + M->B52_EMPATE
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() $ "M->B52_SUBDE,M->B52_SUBATE"
		If  cSeq == "1"
			cFiltro := M->B52_CODINT + M->B52_EMPDE + M->B52_CONDE
		Else
			cFiltro := M->B52_CODINT + M->B52_EMPATE + M->B52_CONATE
		Endif
	ElseIf IndexOrd() = 1 .And. ReadVar() == "M->B40_NUMCON"
		If Select('BT5') <= 0
			dbSelectArea('BT5')
			BT5->(dbSetOrder(1))
			BT5->( MsSeek( xFilial('BT5') + cCodInt + cCodEmp ) )
		EndIf

		cFiltro := cCodInt + cCodEmp

	ElseIf IndexOrd() = 1 .And. ReadVar() == "M->B40_SUBCON"
		If Select('BQC') <= 0
			dbSelectArea('BQC')
			BQC->(dbSetOrder(1))
			BQC->( MsSeek( xFilial('BQC') + cCodInt + cCodEmp + cCodConVer ) )
		EndIf

		cFiltro := cCodInt + cCodEmp + cCodConVer

	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->B6K_CODEMP"
		cFiltro := cCodInt
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->B6K_NUMCON"
		cFiltro := cCodInt + cValEmp
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->B6K_SUBCON"
		cFiltro := cCodInt + cValEmp + cNumCon + cVerCon
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->B6K_EMPFIN"
		cFiltro := cCodInt
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->B6K_CONFIN"
		cFiltro := cCodInt + cValEmp
	ElseIf IndexOrd() = 1 .And. ReadVar() = "M->B6K_SUBFIN"
		cFiltro := cCodInt + cValEmp + cNumCon + cVerCon
	EndIf

Return xFilial(cAlias) + cFiltro
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsLISESP   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSLISESP(cCodRda)
	LOCAL nRecBBF  := BBF->(Recno())
	LOCAL nOrdBBF  := BBF->(IndexOrd())
	LOCAL cListEsp := ""

	BBF->(DbSetOrder(1))
	If BBF->(MsSeek(xFilial("BBF")+cCodRDA))
		While ! BBF->(Eof()) .And. BBF->(BBF_FILIAL+BBF_CODIGO) == xFilial("BBF")+cCodRDA

			cListEsp += AllTrim(Posicione("BAQ",1,xFilial("BAQ")+BBF->(BBF_CODINT+BBF_CDESP),"BAQ_DESCRI"))+" | "

			BBF->(DbSkip())
		Enddo
		cListEsp := Subs(cListEsp,1,Len(cListEsp)-3)
	Endif

	BBF->(DbGoTo(nRecBBF))
	BBF->(DbSetOrder(nOrdBBF))

Return(cListEsp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVldCb   ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 25.08.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Funcao para verificar se forma de cobranca pode ser digitada  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVldCb(cTipo, cUso, cCpoDescri, uCampos)
	Local lRet := .T.
	Local cDesUsu := ""

	If ! BJ1->(MsSeek(xFilial("BJ1") + &(ReadVar())))
		lRet := .F.
		Help("",1,"REGNOIS")
	Else
		If BJ1->BJ1_TIPO <> cTipo
			ApMsgAlert(	STR0053 +; //"Codigo da Cobranca invalido. Somente podera ser informado "
				AllTrim(QA_CBOX("BJ1_TIPO",cTipo)) + ".")
			lRet := .F.
		Endif
		If ! cUso $ BJ1->BJ1_USO
			If cUso = "1"
				cDesUsu := STR0054 //"no Produto"
			ElseIf cUso = "2"
				cDesUsu := STR0055 //"no Grupo/Empresa"
			ElseIf cUso = "3"
				cDesUsu := STR0056 //"na Familia"
			ElseIf cUso = "4"
				cDesUsu := STR0057 //"no Usuario"
			Endif
			ApMsgAlert(	STR0058 +; //"Codigo da Cobranca invalido. Nao pode ser informado "
				cDesUsu)
			lRet := .F.
		Endif
	Endif

	If lRet
		lRet := PlsVldGd(If(uCampos = Nil, SubStr(ReadVar(),4), uCampos))
	Endif

	If lRet .And. cCpoDescri # Nil
		&("M->" + cCpoDescri) := BJ1->BJ1_DESCRI
	Endif

Return lRet

/*/{Protheus.doc} PLSRETPA
teste
@type function
@author PLS TEAM
@since 20.08.2003
@version 1.0
/*/
Function PLSRETPA(cCodInt,cAno,cMes,aRet,cCodEmp,cCodRDA,cCodLoc,cCdProduto,cVrProduto,cEspec,aVlBloq,paramixb)
	LOCAL nRet      := 0
	LOCAL nFor      := 0
	LOCAL aBloqAux  := {}

	DEFAULT aRet        := {}
	DEFAULT aVlBloq     := {}
	DEFAULT paramixb    := {}

	aBloqAux := aClone(aVlBloq)

	//Busca valor de US baseado no CH da unidade que acompanha o PA.
	//Caso o procedimento tenha somente o porte no cadastro (aRet vazio)  ³
	//e realizada a busca para encontrar o nivel da US.
	if len(aRet) == 0

		aRet := PLSRETUSNV(paramixb)

		if len(aRet) > 0 .and. Len(aRet[4]) > 0
			nRet := aRet[4,1,3]
		endIf

	else

		for nFor := 1 to len(aRet)

			if allTrim(aRet[nFor,1]) $ PLSCHMP() .and. len(aRet[nFor,5]) > 0

				nRet := aRet[nFor,5,1,3]
				exit

			endIf

		next

	endIf

	if nRet == 0 .And. len(aBloqAux) >= 1

		aBloqAux := aClone(aBloqAux)[1]

		for nFor := 1 to len(aBloqAux)

			if allTrim(aBloqAux[nFor,1]) $ PLSCHMP() .and. len(aBloqAux[nFor,5]) > 0

				nRet := aBloqAux[nFor,5,1,3]
				exit

			endIf

		next

	endIf

	iF nRet == 0

		BFM->(DBSetOrder(1))
		if BFM->( MsSeek( xFilial("BFM") + cCodInt + cAno + cMes ) )

			nRet := BFM->BFM_VALRDA

		endIf

	endIf

	if existBlock("PLSPAESP")
		nRet := ExecBlock("PLSPAESP",.F.,.F.,{nRet,cCodInt,cAno,cMes,aRet,cCodEmp,cCodRDA,cCodLoc,cCdProduto,cVrProduto,cEspec,aVlBloq})
	endIf

return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSIdeVld  ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 16.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Valida digitacao da cobranca de identificacao de usuario  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSIdeVld(cAlias)

Return PlsVldGd({ 	cAlias + "_MOTIVO", cAlias + "_EMIDE", cAlias + "_EMIATE",;
	cAlias + "_TIPUSR", cAlias + "_GRAUPA" })

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSChkChav ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 02.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Verifica se a chave ja exista na tabela / semaforo        ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cAlias     -> Alias a ser verificado                      ±±
±±³         cChave     -> Chave para verificacao                      ±±
±±³         nOrdem     -> Ordem para verificacao                      ±±
±±³         lChkSem    -> Define se deve verificar semaforo (Default True)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSChkChav(cAlias, cChave, nOrdem, lChkSem)
	Local lRet := .F.

	DEFAULT lChkSem := .T.

	If ValType(cChave) = "U"
		cChave := &(ReadVar())
	EndIf

	lRet := ExistChav(cAlias, cChave, nOrdem)

	If lRet .And. lChkSem
		lRet := FreeForUse(cAlias, cChave)
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ PLSCHKDEL  ³ Autor ³ Tulio Cesar       Data ³ 02.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ valida se existe movimentacao ou nao                      ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCHKDEL(aChaves,lHelp)
	LOCAL cName
	LOCAL cSQL
	LOCAL lRet  := .T.
	LOCAL lErro
	LOCAL lTem
	LOCAL cAlias
	LOCAL aCampo
	LOCAL aChave
	LOCAL i
	LOCAL aMsg  := {}
	Local nFor
	LOCAL aArea := GetArea()

	DEFAULT lHelp := .T.

	For nFor := 1 To Len(aChaves)

		cAlias := aChaves[nFor,1]
		cName  := RetSQLName(cAlias)
		aCampo := {}
		aChave := {}
		i := 1

		// Monta array com campos a serem pesquisados
		While .T.
			aadd(aCampo,aChaves[nFor,i+1])
			aadd(aChave,aChaves[nFor,i+2])
			i += 2
			If  len(aChaves[nFor]) > i
				loop
			Endif
			Exit
		End

		// Verifica se existe alguma chave com tipo de campo nao previsto
		lErro := .F.
		For i := 1 to len(aChave)
			If  ! ValType(aChave[i]) $ "C,D,N"
				lErro := .T.
			Endif
		Next
		If  lErro
			If  lHelp
				Help("",1,"PLSCHKDL1")
			Endif
			Return(.F.)
		Endif

		DbSelectArea(cAlias)
		cSQL := "SELECT "+FieldName(1)+" FROM "+cName+" WHERE "

		For i := 1 to len(aChave)
			If     ValType(aChave[i]) $ "C"
				cSQL += aCampo[i] + " = '" + aChave[i] + "' AND "
			Elseif ValType(aChave[i]) == "D"
				cSQL += aCampo[i] + " = '" + dtos(aChave[i]) + "' AND "
			Elseif ValType(aChave[i]) == "N"
				cSQL += aCampo[i] + " = " + Str(aChave[i]) + " AND "
			Endif
		Next

		cSQL += "D_E_L_E_T_ = ' '"

		PLSQuery(cSQL,"PLSCHKDEL")

		lTem := IF(PLSCHKDEL->(Eof()),.F.,.T.)
		lRet := IF(lTem,.F.,lRet)

		PLSCHKDEL->(DbCloseArea())
		RestArea(aArea)

		If lTem
			aadd(aMsg,{cAlias,PLSRETTIT(cAlias)})
		Endif
	Next

	If ! lRet .and. lHelp
		PLSCRIGEN(aMsg,{ {STR0059,"@C",24} , {STR0060,"@C",200 } },STR0061) //"Tabela"###"Descrição da tabela"###"Não é possível fazer a exclusão por existir movimentação na(s) tabelas(s) abaixo relacionadas:"
	Endif

	RestArea(aArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ImpCriGen  ³ Autor ³ Tulio Cesar      Data ³ 18.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime uma critica                                    ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpCriGen(aDados,aCabec,cTit,cTpRel,nTmRel)

	//Define variaveis padroes para todos os relatorios...

	LOCAL nFor
	LOCAL nFor2
	LOCAL nX
	LOCAL nY
	LOCAL cDado         := ""
	LOCAL cDadoAux      := ""
	LOCAL uDado
	LOCAL nTamanho := 0
	LOCAL nTotReg := 0
	PRIVATE nQtdLin     := 58       // Qtd de Linhas Por Pagina
	PRIVATE Limite      := 132       // Limite de Colunas
	PRIVATE Tamanho     := "M"       // P=Pequeno;M=Medio;G=Grande -> P=80;M=132;G=220 (colunas)
	PRIVATE cTitulo     := cTit // Titulo do Relatorio
	PRIVATE cDesc1      := cTitulo // Descritivo para o usuario
	PRIVATE cDesc2      := "" // Descritivo para o usuario
	PRIVATE cDesc3      := ""
	PRIVATE cAlias      := "BA1" // Alias
	PRIVATE cPerg       := nil // Pergunta padrao (SX1) dos parametros
	PRIVATE cRel        := "IMPCRIGEN" // Nome do Relatorio
	PRIVATE nLi         := 01   // Variavel padrao para controlar numero de linha
	PRIVATE nQtdini     := nLi  // Variavel para controlar numero de linha inicial
	PRIVATE m_pag       := 1    // Variavel padrao para contar numero da pagina
	PRIVATE lCompres    := .F. // nao mude e padrao
	PRIVATE lDicion     := .F. // nao mude e padrao
	PRIVATE lFiltro     := .F. // Habilitar o filtro ou nao
	PRIVATE lCrystal    := .F. // nao mudar controle do crystal reports
	PRIVATE aOrdens  	:= {}
	PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } // padrao nao mude
	PRIVATE lAbortPrint := .F. // Controle para abortar (sempre como esta aqui)
	PRIVATE cCabec1     := "" // Primeira linha do cabecalho ;
	PRIVATE cCabec2     := "" // utilizado pela funcao cabec...
	PRIVATE nColuna     := 00 // Numero da coluna que sera impresso as colunas

	DEFAULT cTpRel     := "M"
	DEFAULT nTmRel     := 132

	Limite     := nTmRel
	Tamanho    := cTpRel

	//Chama SetPrint (padrao)

	cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,Tamanho,{},lFiltro,lCrystal)

	//Verifica se foi cancelada a operacao (padrao)

	If nLastKey  == 27 // Verifica o cancelamento...
		Return
	Endif

	//Configura impressora (padrao)

	SetDefault(aReturn,cAlias)

	For nFor := 1 To Len(aCabec)
		If  Alltrim(aCabec[nFor,1])=="Filler"
			nTamanho:= 16
		ElseIf ValType(aCabec[nFor,3])=="C"
			nTamanho:= Val(Alltrim(aCabec[nFor,3]))
		Elseif	ValType(aCabec[nFor,3])=="N"
			nTamanho:= If(aCabec[nFor,3]==0,25,19)
		Endif
		cDado += aCabec[nFor,1]+Space(nTamanho-Len(aCabec[nFor,1]))
	Next

	nLi := Cabec(cTitulo,cDado,cCabec2,cRel,Tamanho,IIF(aReturn[4]==1,GetNewPar("MV_COMP","15"),GetNewPar("MV_NORM","18")))

	nTamanho:=0
	For nFor := 1 To Len(aDados)
		If Len(aDados[nFor])>1 .And. ValType(aDados[nFor,2]) <> "U"
			nTotReg+=1
		Endif
		cDado := ""
		For nFor2 := 1 To Len(aCabec)
			uDado := aDados[nFor,nFor2]

			If   Alltrim(aCabec[nFor2,1])=="Filler"
				nTamanho:=8
				If ValType(uDado)=="U"
					cDado += Space(nTamanho)
				Else
					cDado += str(uDado,8,2)+Space(01)
				Endif
			Elseif ValType(aCabec[nFor2,3])=="C"
				nTamanho:= Val(Alltrim(aCabec[nFor2,3]))

			Elseif	ValType(aCabec[nFor2,3])=="N"
				nTamanho:= 19//aCabec[nFor2,3]
			Endif

			If ValType(uDado) == "C"
				cDado += Alltrim(uDado)+Space(nTamanho-Len(Alltrim(uDado)))
			ElseIf ValType(uDado) == "D"
				cDado += dtoc(uDado) + Space( Len( Alltrim( dtoc( uDado ))))
			ElseIf ValType(uDado) == "N".and. Alltrim(aCabec[nFor2,1])<>"Filler"
				cDado += str(uDado,17,4)+Space(02)
			Elseif ValType(uDado)=="U"
				cDado += Space(nTamanho)
			Endif
		Next

		If Substr(cTitulo,38,5) <> "A1300"
			@ ++nLi, nColuna pSay cDado
		EndIf

		If Substr(cTitulo,38,5) == "A1300"

			For nY := 1 to len(cDado)
				If !empty(Substr(cDado,nY,120))
					For nX := ++nLi to len(cDado)
						If substr(cDado,nY,120) <> cDadoAux
							@ ++nX, nColuna pSay substr(cDado,nY,120)
							cDadoAux := substr(cDado,nY,120)
						EndIf
						If substr(cDado,nY,120) == cDadoAux
							Exit
						EndIf
					Next
				EndIf
				If empty(Substr(cDado,nY,120))
					Exit
				EndIf
				nY := nY + 119
			Next nY
		EndIf

		If nLi > nQtdLin
			nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,Tamanho,IIF(aReturn[4]==1,GetNewPar("MV_COMP","15"),GetNewPar("MV_NORM","18")))
		EndIf
	Next

	If nLi > nQtdLin
		nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,Tamanho,IIF(aReturn[4]==1,GetNewPar("MV_COMP","15"),GetNewPar("MV_NORM","18")))
	EndIf
	@ ++nLi, nColuna pSay Replicate("*",Limite-nColuna)
	@ ++nLi, nColuna pSay StrZero(nTotReg,2)+STR0062 //" Registro(s) Listado(s)"
	@ ++nLi, nColuna pSay Replicate("*",Limite-nColuna)

	If  aReturn[5] == 1
		Set Printer To
		Ourspool(cRel)
	End

	MS_FLUSH()


	//Fim da rotina

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSGRVTCP  ³ Autor ³ Tulio Cesar      Data ³ 18.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria um titulo a receber baseado numa guia comprada... ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGRVTCP(cPrefixo,cNumero,cCodCli,cLoja,cTipTit,dVencto,cCodInt,cCodEmp,cMatric,nOpc,nValor,cConEmp,cVerCon,;
		cSubCon,cVerSub)

	LOCAL cCodEve
	LOCAL __cCodigo
	LOCAL lHabMetric := IIf(GetNewPar('MV_PHBMETR', '1') == "0", .F., .T.)
	
	DEFAULT nValor := 0

	If nOpc == K_Incluir
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+cCodCli+cLoja))

		// Grava o arquivo BBT, complemento do SE1 com informacoes do Plano de Saude.
		__cCodigo := GetSx8Num("BBT","BBT_CODIGO")

		BBT->(RecLock("BBT",.T.))
		BBT->BBT_FILIAL := xFilial("BBT")
		BBT->BBT_CODIGO := __cCodigo
		BBT->BBT_CODOPE := cCodInt
		BBT->BBT_CODEMP := cCodEmp

		BBT->BBT_CONEMP := cConEmp
		BBT->BBT_VERCON := cVerCon
		BBT->BBT_SUBCON := cSubCon
		BBT->BBT_VERSUB := cVerSub
		BBT->BBT_MATRIC := cMatric
		BBT->BBT_TIPREG := BA1->BA1_TIPREG
		BBT->BBT_NIVEL  := "7"

		BBT->BBT_CLIFOR := cCodCli
		BBT->BBT_LOJA   := cLoja
		BBT->BBT_VALOR  := nValor

		BBT->BBT_ANOTIT := subs(dtos(dDataBase),1,4)
		BBT->BBT_MESTIT := subs(dtos(dDataBase),5,2)

		BBT->BBT_PREFIX := cPrefixo
		BBT->BBT_NUMTIT := cNumero
		BBT->BBT_TIPTIT := cTipTit
		BBT->BBT_RECPAG := "0"
		If !Empty(BA1->BA1_CODPLA)
			BBT->BBT_CODPLA := BA1->BA1_CODPLA
			BBT->BBT_VERSAO := BA1->BA1_VERSAO
		Else
			BBT->BBT_CODPLA := BA3->BA3_CODPLA
			BBT->BBT_VERSAO := BA3->BA3_VERSAO
		Endif
		BBT->BBT_INTERC := '0'
		If BBT->( FieldPos("BBT_MODPAG") ) > 0
			BBT->BBT_MODPAG := BA3->BA3_MODPAG
		Endif

		BBT->(MsUnlock())
		BBT->( ConfirmSx8() )

		// Grava o titulo a receber...
		SE1->(RecLock("SE1",.T.))
		SE1->E1_FILIAL   := xFilial("SE1")
		SE1->E1_TIPO     := cTipTit
		SE1->E1_CLIENTE  := cCodCli
		SE1->E1_LOJA     := cLoja
		SE1->E1_NATUREZ  := SA1->A1_NATUREZ
		SE1->E1_EMISSAO  := dDataBase
		SE1->E1_EMIS1    := dDataBase
		SE1->E1_SITUACA  := "0"
		SE1->E1_MOEDA    := 1
		SE1->E1_OCORREN  := "01"
		SE1->E1_FLUXO    := "S"
		SE1->E1_STATUS   := "A"
		SE1->E1_PROJPMS  := "2"
		SE1->E1_VENCORI  := dVencto
		SE1->E1_VENCTO   := dVencto
		SE1->E1_PREFIXO  := cPrefixo
		SE1->E1_NUM      := cNumero
		SE1->E1_VENCREA  := DataValida(dVencto)
		SE1->E1_VLCRUZ   := nValor
		SE1->E1_IRRF	    := 0
		SE1->E1_VALOR    := nValor
		SE1->E1_NOMCLI   := SA1->A1_NOME
		SE1->E1_SALDO    := SE1->E1_VALOR
		SE1->E1_DECRESC  := 0
		SE1->E1_SDDECRE  := 0
		SE1->E1_ACRESC   := 0
		SE1->E1_SDACRES  := 0
		SE1->E1_VALLIQ   := 0
		SE1->E1_NUMBCO   := ""
		SE1->E1_PLNUCOB  := ""
		SE1->E1_VALJUR   := 0
		SE1->E1_PORCJUR  := 0
		SE1->E1_CODINT   := cCodInt
		SE1->E1_CODEMP   := cCodEmp
		SE1->E1_MATRIC 	 := cMatric
		SE1->E1_CONEMP   := cConEmp
		SE1->E1_VERCON   := cVerCon
		SE1->E1_SUBCON   := cSubCon
		SE1->E1_VERSUB   := cVerSub
		SE1->E1_MESBASE  := subs(dtos(dDataBase),5,2)
		SE1->E1_ANOBASE  := subs(dtos(dDataBase),1,4)
		SE1->E1_MULTNAT  := "2"
		SE1->E1_NUMCON   := BA3->BA3_NUMCON
		SE1->E1_TIPREG   := BA1->BA1_TIPREG
		SE1->E1_ORIGEM   := "PLSA090"

		If SE1->( FieldPos("E1_PLORIG") ) > 0
			SE1->E1_PLORIG := '5'
		Endif

		SE1->(MsUnLock())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Ponto de entrada apos a geracao de uma guia comprada e paga no ato
		//Exemplos de Uso:
		//Alterar prefixo, conta contabil, natureza, etc...
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PLSGERTG")
			execblock("PLSGERTG",.F.,.F.)
		Endif

		BD5->(RecLock("BD5"),.F.)
		BD5->BD5_PREFIX := cPrefixo
		BD5->BD5_NUMTIT := cNumero
		BD5->BD5_TIPTIT := cTipTit

		BD5->(MsUnlock())

		BD6->(DbSetorder(1))
		If BD6->(DbSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))

			If BD6->BD6_TPPF == "1" //Co-Part
				cCodEve := "121"
			Else
				cCodEve := "120"
			Endif
			BD6->(RecLock("BD6",.F.))
			BD6->BD6_PREFIX := cPrefixo
			BD6->BD6_NUMTIT := cNumero
			BD6->BD6_TIPTIT := cTipTit
			BD6->(MsUnlock())
		Endif

		GravaBM1Esp(cCodEve,cCodInt,cCodEmp,cCodCli,cLoja,nValor,cPrefixo,cNumero,;
			BA1->BA1_TIPREG,BA1->BA1_DIGITO,;
			cTipTit,subs(dtos(dDataBase),5,2),subs(dtos(dDataBase),1,4))

		If BD6->BD6_VLRTAD > 0
			cCodEve := "122"
			nValor  := BD6->BD6_VLRTAD
			GravaBM1Esp(cCodEve,cCodInt,cCodEmp,cCodCli,cLoja,nValor,cPrefixo,cNumero,;
				BA1->BA1_TIPREG,BA1->BA1_DIGITO,;
				cTipTit,subs(dtos(dDataBase),5,2),subs(dtos(dDataBase),1,4))
		Endif

		//Métrica do PLS
		/*Atenção:
		1) Para a métrica funcionar com a classe FwMetrics, a lib deve estar na versão igual ou maior que 20200727;
		2) Além de verificar a versão da Lib, existe o parâmetro "secreto" MV_PHBMETR, que vai ficar ativo como default. Caso ocorra lentidão em 
		algum cliente em produção - visto que até 05/2021, nenhum cliente da base tem os requisitos para rodar a métrica e testar em produção - basta
		citar a criação deste parâmetro (Métrica PLS Ativa? 0 - Não / 1 - Sim) e colocar o valor como "0" (desligado).
		3) No futuro, vamos usar o FwCustomMetrics, mas demanda lib superior e outros requisitos...
		4) As variáveis estão declaradas como estáticas no fonte:*/
		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			
			FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_modelo-pagamento-de-reembolso_total", 1 }} )

		endif
		/* Fim das métricas */

	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaBM1Esp ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaBM1Esp(cCodTip,cCodInt,cCodEmp,cCodCli,cLoja,nValor,cPrefixo,cNumero,cTipReg,;
		cDigito,cTipTit,cMes,cAno)
	LOCAL cSeq := PLSA625Cd("BM1_SEQ","BM1",1,"BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES+BM1_TIPREG)",;
		cCodInt+cCodEmp+ba3->ba3_matric+Space(4)+Space(2)+cTipReg)

	BFQ->(DbSetOrder(1))
	BFQ->(MsSeek(xFilial("BGQ")+cCodInt+cCodTip))

	BM1->(RecLock("BM1",.T.))
	BM1->BM1_FILIAL := xFilial("BM1")
	BM1->BM1_CODINT := cCodInt
	BM1->BM1_CODEMP := cCodEmp
	BM1->BM1_MATRIC := BA3->BA3_MATRIC
	BM1->BM1_TIPREG := cTipReg
	BM1->BM1_DIGITO := cDigito
	BM1->BM1_NOMUSR := PLNOMUSR(BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG)
	BM1->BM1_SEQ    := cSeq
	BM1->BM1_CONEMP := BA1->BA1_CONEMP
	BM1->BM1_VERCON := BA1->BA1_VERCON
	BM1->BM1_SUBCON := BA1->BA1_SUBCON
	BM1->BM1_VERSUB := BA1->BA1_VERSUB
	BM1->BM1_ANO    := cAno
	BM1->BM1_MES    := cMes
	BM1->BM1_TIPO   := BFQ->BFQ_DEBCRE
	BM1->BM1_VALOR  := nValor
	BM1->BM1_CODTIP := BFQ->(BFQ_PROPRI+BFQ_CODLAN)
	BM1->BM1_DESTIP := BFQ->BFQ_DESCRI
	BM1->BM1_CODEVE := ""
	BM1->BM1_DESEVE := ""
	BM1->BM1_ALIAS  := ""
	BM1->BM1_ORIGEM := ""
	BM1->BM1_BASEIR := 0
	BM1->BM1_MATUSU := BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG
	BM1->BM1_PLNUCO := ""
	BM1->BM1_LTOTAL := "1"
	BM1->BM1_SEXO   := BA1->BA1_SEXO
	BM1->BM1_GRAUPA := BA1->BA1_GRAUPA
	BM1->BM1_CODFAI := ""
	BM1->BM1_NIVFAI := ""
	BM1->BM1_TIPUSU := BA3->BA3_TIPOUS
	BM1->BM1_CARGO  := STR0063 //"COMPRA DE PROCEDIMENTOS PAGO NO ATO"
	BM1->BM1_PREFIX := cPrefixo
	BM1->BM1_NUMTIT := cNumero
	BM1->BM1_TIPTIT := cTipTit
	BM1->BM1_NIVCOB := "7"
	BM1->BM1_INTERC := "0"
	BM1->BM1_NUMPAR := "001"
	BM1->(MsUnLock())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSTOTPEG  ³ Autor ³ Angelo/Tulio     Data ³ 22.11.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totaliza a Pegs os campos de valores de proced, mat, med et³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTOTPEG(nRecno)
	LOCAL nOrdBCI := BCI->(IndexOrd())
	LOCAL nRecBD7 := BD7->(Recno())
	LOCAL nOrdBD7 := BD7->(IndexOrd())

	LOCAL cCodOpe
	LOCAL cCodLDP
	LOCAL cCodPEG
	LOCAL lRest   := .F.
	LOCAL cFasePeg

	//Somente posiciona no PEG se nao estiver posicinado...

	If nRecno <> BCI->(Recno())
		BCI->(DbGoTo(nRecno))
		lRest := .T.
	Endif

	//Totaliza valores ...

	cCodOpe := BCI->BCI_CODOPE
	cCodLDP := BCI->BCI_CODLDP
	cCodPEG := BCI->BCI_CODPEG
	cFasePeg:= BCI->BCI_FASE

	//Nova implementacao... agora iremos mudar a fase da peg automaticamente   ³
	//de acordo com as suas respectivas guias ficarem prontas ou em digitacao. ³

	SIX->(DbSetOrder(1))
	If SIX->(MsSeek("BD73")) //indice criado apos versao de sxs, tratar existencia
		BD7->(DbSetOrder(3))
		If ! BD7->(MsSeek(xFilial("BD7")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+"1"))
			cFasePeg := "1"
		Else
			If BD7->(MsSeek(xFilial("BD7")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+"11")) .Or. ;
					BD7->(MsSeek(xFilial("BD7")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+"12"))
				cFasePeg := "1" //fase deve ser digitacao por existem guias em digitacao ou
				//em conferencia
			Else
				cFasePeg := "3" //fase deve estar pronto porque nao existem guias nem em dig.
				//nem como prontas
			Endif
		Endif
	Endif

	//Caso seja necessario restaura posicao...

	If lRest
		BCI->(DbSetOrder(nOrdBCI))
		BCI->(DbGoTo(nRecno))
	Endif

	BD7->(DbSetOrder(nOrdBD7))
	BD7->(DbGoTo(nRecBD7))

	//Fim da Rotina...

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSUSRCC   ³ Autor ³ Tulio Cesar      Data ³ 09.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o centro de custo do usuario...                ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSUSRCC(cMatricUsr)
	LOCAL cCC      := ""
	local aAreaBA1 := BA1->(getArea())
	local aAreaBA3 := {}
	local aAreaBI3 := {}
	local aAreaBT6 := {}

	//Posiciona no usuario e familia...
	BA1->(DbSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1")+cMatricUsr))

		aAreaBA3 := BA3->(getArea())

		BA3->(DbSetorder(1))
		If BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

			//Se for PF pega do produto e se for PJ pega do subcontrato x produto...
			If BA3->BA3_TIPOUS == "1"

				aAreaBI3 := BI3->(getArea())

				BI3->(DbSetOrder(1))
				If BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODPLA+BA3_VERSAO)))
					cCC := BI3->BI3_CC
				Endif

				BI3->(restArea(aAreaBI3))

			Else

				aAreaBT6 := BT6->(getArea())

				BT6->(DbSetOrder(1))
				If BT6->(MsSeek(xFilial("BT6")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)+BA3->(BA3_CODPLA+BA3_VERSAO)))
					cCC := BT6->BT6_CC
				Endif

				BT6->(restArea(aAreaBT6))

			Endif

		Endif

		BA3->(restArea(aAreaBA3))

	Endif

	BA1->(restArea(aAreaBA1))

Return(cCC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSALIASEX ³ Autor ³ Tulio Cesar      Data ³ 12.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna se um alias ja existe ou nao                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function PLSALIASEX(cAlias)
	local lRet		:= .f.

	//Verifica se existe o alias no sx3
	SX3->( dbSetOrder(1) )
	lRet := SX3->( msSeek(cAlias) )

return(lRet)

/*/{Protheus.doc} plSADTINT
retorna dados de uma internacao para tratamento de SADT internado
@type function
@author PLSTEAM
@since 20.02.06
@version 1.0
/*/
function plSADTINT(cMatricUsr, dData)
	local aArea   	:= getArea()
	local cSQL		:= ""
	local cCodOpe	:= subs(cMatricUsr,1,4)
	local cCodEmp 	:= subs(cMatricUsr,atCodEmp[1],atCodEmp[2])
	local cMatric 	:= subs(cMatricUsr,atMatric[1],atMatric[2])
	local cTipReg 	:= subs(cMatricUsr,atTipReg[1],atTipReg[2])

	cSQL := " SELECT BE4_NUMINT, BE4_OPEUSR, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO, BE4_DATPRO, BE4_GUIINT, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO, BE4_ORIMOV,  "
	cSQL += "    	 BE4_CODOPE,BE4_ANOINT,BE4_MESINT,BE4_NUMINT "
	cSQL += "   FROM " + retSQLName("BE4")
	cSQL += "  WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSQL += "    AND BE4_OPEUSR = '" + cCodOpe + "' "
	cSQL += "    AND BE4_CODEMP = '" + cCodEmp + "' "
	cSQL += "    AND BE4_MATRIC = '" + cMatric + "'"
	cSQL += "    AND BE4_TIPREG = '" + cTipReg + "' "
	cSQL += "    AND BE4_TIPGUI = '03' "
	cSQL += "    AND BE4_CANCEL <> '1' "
	cSQL += "    AND BE4_SITUAC <> '2' "
	cSQL += "    AND BE4_DATPRO <> '' "
	cSQL += "    AND BE4_DATPRO <= '" + dtos(dData) + "' "
	cSQL += "    AND D_E_L_E_T_ = '' "

	PLSQuery(cSQL,"plSADTINT")

	if !plSADTINT->(eof())

		aadd(aDadInt,{plSADTINT->BE4_OPEUSR, plSADTINT->BE4_CODEMP, plSADTINT->BE4_MATRIC,;
			plSADTINT->BE4_TIPREG, plSADTINT->BE4_DIGITO, CTOD(plSADTINT->BE4_DATPRO),;
			CTOD(plSADTINT->BE4_DTALTA), plSADTINT->BE4_HRALTA, plSADTINT->BE4_TIPALT,;
			plSADTINT->BE4_TIPGUI, plSADTINT->BE4_HORPRO})

	endIf

	plSADTINT->(dbCloseArea())

	restArea(aArea)

return(aDadInt)

/*/{Protheus.doc} PLSPACINT
somente para garantir a utilizacao da PLSPACINT
@type function
@author PLSTEAM
@since 20.02.06
@version 1.0
/*/
function PLSPACINT(cMatricUsr, dData)
return PLSUSRINTE(cMatricUsr, dData)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSVLDDAT  ³ Autor ³ Eduardo Motta    Data ³ 18.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna .F. caso a DATA/HORA final seja maior que a inicial³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSVLDDAT(dData1,cHora1,dData2,cHora2)
	Local lRet := .T.

	If dData2 < dData1 .and. !Empty(dData2)
		lRet := .F.
	ElseIf dData2 == dData1
		If cHora2 < cHora1
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSVLDMES  ³ Autor ³ Eduardo Motta    Data ³ 18.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se o mes digitado esta entre 01 e 12            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldMes()
	Local lRet := .T.
	Local xMes := &(ReadVar())

	If ValType(xMes) == "C"
		xMes := Val(xMes)
	EndIf

	If ValType(xMes) # "N"   // para o sistema nao cair
		Return .T.
	EndIf

	If ! (xMes >= 1 .and. xMes <= 12)
		lRet := .F.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSGETUSR  ³ Autor ³ Tulio Cesar      Data ³ 08.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o conteudo padrao do aDadUsr                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGETUsr()
Return(aDadUsr)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSGETRDA  ³ Autor ³ Tulio Cesar      Data ³ 08.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o conteudo padrao do aDadRda                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGETRDA()
Return(aDadRda)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSCLORDA  ³ Autor ³ Alexander        Data ³ 25.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a matriz apontar para outro enderece de memoria		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCLORDA(aRda)
	aDadRda := NIL
	aDadRda := aRda
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsPutRda   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSPUTRDA(nIndice,uDado)
	aDadRda[nIndice] := uDado
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsChkNiv   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCHKNIV(lFor)
	LOCAL bIF    := { || (cNivel >= SX3->X3_NIVEL) .And. (X3Uso(SX3->X3_USADO)) }
	LOCAL bBlock := { || ( lFor .And. Eval(bIF) ) .Or. ( SX3->X3_PROPRI == "U" .And. Eval(bIF) ) }
Return(Eval(bBlock))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsChkNi2   ºAutor  ³Fernando Separovicº Data ³  30/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCHKNI2(lFor)
	LOCAL bIF    := { || (cNivel >= SX3->X3_NIVEL) .And. (X3Uso(SX3->X3_USADO)) }
	LOCAL bBlock := { || ( lFor .And. Eval(bIF) ) }
Return(Eval(bBlock))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsFeriado  ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSFeriado(dData, lFerMun, cCodRDA, cCodLoc)
	LOCAL aFeriados := RetFeriados()
	LOCAL nPos
	LOCAL lRet
	DEFAULT lFerMun := .F.

	nPos := aScan(aFeriados,dtos(dData))
	lRet := (nPos > 0)

	IF (lFerMun .AND. !lRet )  //Se lret for falso, não encontrou feriado nacional e agora vai partir para o municipal)
		lRet := PlsDcLocl(cCodRDA, cCodLoc, dData)
	ENDIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsMGFL     ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSMGFL(lLogico)
	LOCAL I
	For I:=1 To FCount()
		M->&(Eval({|nCPO| Field(nCPO)},I)):=If(lLogico,CriaVar(Eval({|nCPO| Field(nCPO)},I),.T.),FieldGet(I))
	Next
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsBusInd   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSBUSIND(cCodInd,cAno,cMes)
	LOCAL nInd    := 0
	DEFAULT cAno  := ""
	DEFAULT cMes  := ""

	If Empty(cAno) .And. Empty(cMes)
		cAno  := subs(dtos(dDataBase),1,4)
		cMes := subs(dtos(dDataBase),5,2)
	Endif

	AAE->(DbSetOrder(1))
	If AAE->(MsSeek(xFilial("AAE")+cCodInd+AllTrim(cAno+cMes)))
		While ! AAE->(Eof()) .And. AAE->(AAE_FILIAL+AAE_CODIND+Subs(dtos(AAE_DATA),1,IIf(!Empty(cMes),6,4))) == xFilial("AAE")+cCodInd+AllTrim(cAno+cMes)
			AAE->(DbSkip())
		Enddo
		AAE->(DbSkip(-1))
		nInd := AAE->AAE_INDICE
		// Se o indice for Negativo, converto a variavel de rotorno.
		If AAE->AAE_SINAL == '2' .and. nInd > 0
			nInd := (nInd * -1)
		Endif
	Endif

Return(nInd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSBRWGEN  ³ Autor ³ Tulio Cesar      Data ³ 29.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe um browse generico dentro de uma oDlg generica...±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSBRWGEN(aDados,aCabec,oDlg,oCritica,nPosLI,nPosCI,nPosCF,nPosLF)
	LOCAL nFor
	LOCAL bBlock

	//Monta o browse...

	oCritica := TcBrowse():New( nPosLI,nPosCI,nPosCF,nPosLF,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	For nFor := 1 To Len(aCabec)

		bBlock := "{ || aDados[oCritica:nAt, "+Str(nFor,4)+"] }"
		bBlock := &bBlock
		oCritica:AddColumn(TcColumn():New(aCabec[nFor,1],bBlock,;
			aCabec[nFor,2],nil,nil,nil,aCabec[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))

	Next
	oCritica:SetArray(aDados)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º PlsVldPerg º Autor º Eduardo Motta      º Data º 20/05/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Verifica as perguntas, incluindo-as caso nao existam                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º PlsVldPerg( aRegs, aNewSx1Stru )                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±º         01 º  aRegs       - Array com cada linha contendo uma pergunta º±±
±±º         02 º  aNewSx1Stru - Caso MUDE O SX1 DEPOIS DA 6.09             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º pls                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º - O 2o  parametro, aNewSx1Stru, SOMENTE deve ser passado  º±±
±±º            º caso ocorra uma MUDANCA DE ESTRUTURA no SX1 DEPOIS DA 6.09º±±
±±º            º , pois o DEFAULT para este parametro JAH EH a Estrutura doº±±
±±º            º da versao 6.09.                                           º±±
±±º            º - Abaixo a Estrutra UTILIZADA, que EH O DA VERSAO 6.09 :  º±±
±±º            º                                                           º±±
±±º Posicao 01 º  cAlias     - Alias                                       º±±
±±º         02 º 	Sequencia da Pergunta,;	 // X1_ORDEM                   º±±
±±º         03 º 	Titulo Perg. Padrao	,;	 // X1_PERGUNT                 º±±
±±º         04 º 	Titulo Perg. Espanhol,;	 // X1_PERSPA                  º±±
±±º         05 º 	Titulo Perg. Ingles	,;	 // X1_PERENG                  º±±
±±º         06 º 	Variavel					,;	 // X1_VARIAVL         º±±
±±º         07 º 	Tipo						,;	 // X1_TIPO            º±±
±±º         08 º 	Tamanho					,;	 // X1_TAMANHO             º±±
±±º         09 º 	Decimais					,;	 // X1_DECIMAL         º±±
±±º         10 º 	Opcao Pre Selecionada,;	 // X1_PRESEL                  º±±
±±º         11 º 	Tipo da Pergunta		,;	 // X1_GSC                 º±±
±±º         12 º 	Validacao				,;	 // X1_VALID               º±±
±±º         13 º 	Nome Var  1	      	,;	 // X1_VAR01                   º±±
±±º         14 º 	Definicao 1	Padrao	,;	 // X1_DEF01                   º±±
±±º         15 º 	Definicao 1 Espanhol	,;	 // X1_DEFSPA1             º±±
±±º         16 º 	Definicao 1 Ingles 	,;	 // X1_DEFENG1                 º±±
±±º         17 º 	Conteudo  1				,;	 // X1_CNT01               º±±
±±º         18 º 	Nome Var  2       	,;	 // X1_VAR02                   º±±
±±º         19 º 	Definicao 2	Padrao	,;	 // X1_DEF02                   º±±
±±º         20 º 	Definicao 2 Espanhol	,;	 // X1_DEFSPA2             º±±
±±º         21 º 	Definicao 2 Ingles 	,;	 // X1_DEFENG2                 º±±
±±º         22 º 	Conteudo  2				,;	 // X1_CNT02               º±±
±±º         23 º 	Nome Var  3       	,;	 // X1_VAR03                   º±±
±±º         24 º 	Definicao 3	Padrao	,;	 // X1_DEF03                   º±±
±±º         25 º 	Definicao 3 Espanhol	,;	 // X1_DEFSPA3             º±±
±±º         26 º 	Definicao 3 Ingles 	,;	 // X1_DEFENG3                 º±±
±±º         27 º 	Conteudo  3				,;	 // X1_CNT03               º±±
±±º         28 º 	Nome Var  4       	,;	 // X1_VAR04                   º±±
±±º         29 º 	Definicao 4	Padrao	,;	 // X1_DEF04                   º±±
±±º         30 º	Definicao 4 Espanhol	,;	 // X1_DEFSPA4             º±±
±±º         31 º 	Definicao 4 Ingles 	,;	 // X1_DEFENG4                 º±±
±±º         32 º 	Conteudo  4				,;	 // X1_CNT05               º±±
±±º         33 º 	Nome Var  5       	,;	 // X1_VAR05                   º±±
±±º         34 º 	Definicao 5	Padrao	,;	 // X1_DEF05                   º±±
±±º         35 º 	Definicao 5 Espanhol	,;	 // X1_DEFSPA5             º±±
±±º         36 º 	Definicao 5 Ingles 	,;	 // X1_DEFENG5                 º±±
±±º         37 º 	Conteudo  5				,;	 // X1_CNT05               º±±
±±º         38 º 	Consulta F3				,;	 // X1_F3                  º±±
±±º         39 º 	Grupo SXG   			,;  // X1_GRPS                 º±±
±±º         40 º 	Pequena Y Media Empr. }  // X1_PYME                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Nava     º22/10/01ºxxxxxxº Clientes com SX1 em Ordem DIFERENTE       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION PlsVldPerg( aRegs, aNewSx1Stru )
	// funcao descontinuada - SGBD
RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSRETRC   ³ Autor ³ Tulio Cesar      Data ³ 29.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a receita e despesa...                         ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
cTipo    == "0" - Operadora
            "1" - Operadora + Grupo Empresa
            "2" - Operadora + Grupo Empresa + Numero do Contrato + Versao
            "3" - Operadora + Grupo Empresa + Numero do Contrato + Versao + SubContrato + Versao
            "4" - Operadora + Grupo Empresa + Familia
            "5" - Operadora + Grupo Empresa + Familia + Usuario
*/
Function PLSRETRC(cTipo,cMes,cAno,cCodOpe,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMatric,cTipReg)
	LOCAL nReceita := 0
	LOCAL nCusto   := 0
	LOCAL cMacro

	If     cTipo == "0"
		BX9->(DbSetOrder(1))
		BX9->(MsSeek(xFilial("BX9")+"0"+cAno+cCodOpe))
	ElseIf cTipo == "1"
		BX9->(DbSetOrder(2))
		BX9->(MsSeek(xFilial("BX9")+"1"+cAno+cCodOpe+cCodEmp))
	ElseIf cTipo == "2"
		BX9->(DbSetOrder(3))
		BX9->(MsSeek(xFilial("BX9")+"2"+cAno+cCodOpe+cCodEmp+cNumCon+cVerCon))
	ElseIf cTipo == "3"
		BX9->(DbSetOrder(4))
		BX9->(MsSeek(xFilial("BX9")+"3"+cAno+cCodOpe+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub))
	ElseIf cTipo == "4"
		BX9->(DbSetOrder(5))
		BX9->(MsSeek(xFilial("BX9")+"4"+cAno+cCodOpe+cCodEmp+cMatric))
	ElseIf cTipo == "5"
		BX9->(DbSetOrder(6))
		BX9->(MsSeek(xFilial("BX9")+"5"+cAno+cCodOpe+cCodEmp+cMatric+cTipReg))
	Endif

	If BX9->(Found())
		nCusto   := &("BX9->BX9_VRC"+PLSBusMeses(cMes))
		nReceita := &("BX9->BX9_VRR"+PLSBusMeses(cMes))
	Endif

Return({nCusto,nReceita})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³FuncaoPLSBusMeses ³ Autor ³ Tulio Cesar      Data ³ 29.05.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Devolve a descricao do mes de acordo com o mes(numero) ±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBusMeses(cMes)
	LOCAL aParseMeses := { {"JAN","01"},{"FEV","02"},{"MAR","03"},{"ABR","04"},{"MAI","05"},{"JUN","06"},;
		{"JUL","07"},{"AGO","08"},{"SET","09"},{"OUT","10"},{"NOV","11"},{"DEZ","12"} }
	LOCAL nPos
	LOCAL cRet := ""

	nPos := Ascan(aParseMeses,{ |x| x[2] == cMes})

	If nPos > 0
		cRet := aParseMeses[nPos,1]
	Endif

Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSAJUARQ ³ Autor ³ Alexander Santos   Data ³ 03/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Ajuste no arquivo de incluido database e a thread 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSAJUARQ(cName)
	LOCAL cFileLog := ""
	DEFAULT cName := "REGLOG"

	//Ajusta o arquivo com a database e a thread								 ³

	cFileLog := cName+DtoS(Date())+AllTrim(Str(THREADID()))+"_"+ALLTRIM(GetComputerName())+".log"

	//Fim da Rotina															 ³

Return cFileLog
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLsLogFil ³ Autor ³ Eduardo Motta      Data ³ 12/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Grava um log generico                             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsLogFil(cLogErro,cLog,lBuffer,lAjArq,lQLinha,cDirMod,lCDir)
	LOCAL nHdlLog	:= 0
	LOCAL nPos      := 0
	LOCAL nI        := 0
	LOCAL cStrGrv   := ""
	LOCAL cDesLog	:= ""
	LOCAL cArqlog 	:= PLSMUDSIS( cLog )
	LOCAL lMudDir   := Iif( At( PLSMUDSIS("\"),PLSMUDSIS(cLog) ) > 0 ,.F.,.T.)
	LOCAL cDate		:= DtoS(Date())+"\"
	DEFAULT lBuffer := .F.
	DEFAULT lAjArq 	:= .F.
	DEFAULT lQLinha := .T.
	DEFAULT cDirMod	:= PLSMUDSIS( "\logpls\" )
	DEFAULT lCDir	:= .T.

	//Se permitir incluir data no diretorio
	If !lCDir
		cDate := ""
	EndIf

	//Se nao existe o diretorio de log's do modulo cria
	If !ExistDir(cDirMod+cDate)
		If !ExistDir(cDirMod)
			If MakeDir( cDirMod ) <> 0
				cDirMod := ""
			EndIf
		EndIf
		If !Empty(cDirMod)
			cDirMod := PLSMUDSIS( cDirMod+cDate )
			If MakeDir( cDirMod ) <> 0
				cDirMod := ""
			EndIf
		EndIf
	else
		cDirMod := PLSMUDSIS( cDirMod+cDate )
	endIf

	//Ajusta nome do arquivo de log
	if lAjArq
		cArqlog := PLSMUDSIS( PLSAJUARQ( cArqlog ) )
	endIf

	//Nome do arquivo mais diretorio
	if lMudDir
		cArqlog := PLSMUDSIS( cDirMod+cLog )
	endIf

	//Gravacao
	nPos := aScan(aBuffer,{|x| allTrim(upper(x[1])) == allTrim(upper(cLog))})

	if lBuffer
		if nPos > 0
			if len(aBuffer[nPos,2]) > 1000
				lBuffer := .F.
			endIf
		endIf
	endIf

	if ! lBuffer

		if nPos > 0

			cDesLog := ""

			for nI := 1 to len(aBuffer[nPos,2])

				if lQLinha
					cDesLog += aBuffer[nPos,2,nI]+chr(13)+chr(10)
				else
					cDesLog += aBuffer[nPos,2,nI]
				endIf

				//verificar se a string esta maior que 1mb
				if len(cDesLog) > 1000000

					if ! file(cArqLog)
						if (nHdlLog := fCreate(cArqlog,0)) == -1
							return
						endIf
					else
						if (nHdlLog := fOpen(cArqlog,2)) == -1
							return
						endIf
					endIf

					fSeek(nHdlLog,0,2)

					fWrite(nHdlLog,cDesLog)

					fClose(nHdlLog)

					cDesLog := ''
				endIf

			next

			cLogErro 		  	:= cDesLog + cLogErro
			aBuffer[nPos,2]	:= {}
		endIf

		if !File(cArqLog)
			if (nHdlLog := fCreate(cArqlog,0)) == -1
				return
			endIf
		else
			if (nHdlLog := fOpen(cArqlog,2)) == -1
				return
			endIf
		endIf

		fSeek(nHdlLog,0,2)

		if lQLinha
			fWrite(nHdlLog, cLogErro + chr(13) + chr(10))
		else
			fWrite(nHdlLog,cLogErro)
		endIf

		fClose(nHdlLog)
	else
		if nPos > 0
			aadd(aBuffer[nPos,2],cLogErro)
		else
			aadd(aBuffer,{cLog,{cLogErro}})
		endIf
	endIf

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsMPre     ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSMPRE()
	Local lOk := .F.

	lOk := M->BAU_TIPPRE=GetNewPar("MV_PLSTPIN","OPE")
	If ! lOk
		M->BAU_CODOPE := Space(Len(M->BAU_CODOPE))
	Endif

Return(lOk)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A260PutGenºAutor  ³Geraldo Felix Juniorº Data ³  05/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Alimente array generico, utilizado para armazenar informa- º±±
±±º      coes de campos de alias em Getdados para utilizacoes futurasº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A260PutGen(cCampo, xConteudo)
	LOCAL nPosGen := 0

	If ( nPosGen := Ascan(aDadGen, {|x| x[1] == cCampo}) ) == 0
		Aadd( aDadGen, {cCampo, xConteudo} )
	Else
		aDadGen[nPosGen][2] := xConteudo
	Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A260GetGenºAutor  ³Geraldo Felix Juniorº Data ³  05/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Retorna dado do array generico de acondo com o campo       º±±
±±º      informado como parametro...                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A260GetGen(cCampo)
	LOCAL nPosGen := 0

	If ( nPosGen := Ascan(aDadGen, {|x| x[1] == cCampo}) ) == 0
		Final(STR0064) //"Uso incorreto da funcao A260GetGen"
	Else
		xReturn := aDadGen[nPosGen][2]
	Endif

Return(xReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsIsCon    ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function PLSISCON(cCodPad,cCodPro,lInterc)
	local aAreaBR8		:= BR8->(getArea())
	local aConsultas 	:= {}
	local aRet			:= {}
	local nFor			:= 0
	local nPos			:= 0
	local nTamCodPad	:= TamSX3("BR8_CODPAD")[1]

	default cCodPad	:=	""
	default cCodPro	:=	""
	default lInterc :=  .F.

	if empty(__MV_PLSCDCO)
		__MV_PLSCDCO := allTrim(getNewPar("MV_PLSCDCO",""))
	endIf

	if empty(__MV_PLSTPCO)
		__MV_PLSTPCO := getNewPar("MV_PLSTPCO","1,2")
	endIf

	aConsultas 	:= { __MV_PLSCDCO }

	if __PLSISCON

		aRet := execBlock("PLSISCON",.F.,.F.)
		
		for nFor := 1 to len(aRet)
			If !(Substr(Alltrim(aRet[nFor]), nTamCodPad+1) $ GetNewPar("MV_PTEVURG","10101039"))
				aadd(aConsultas,aRet[nFor])
			EndIf
		next nFor
		
	endIf

	if !empty(cCodPad) .and. !empty(cCodPro)

		BR8->(dbSetOrder(1))
		If	BR8->( msSeek( xFilial("BR8") + cCodPad + cCodPro ) ) .and. BR8->BR8_TPCONS $ __MV_PLSTPCO .And. !(AllTrim(cCodPro) $ GetNewPar("MV_PTEVURG","10101039")) .And. !(BR8->BR8_TPCONS $ "1|2")
			aadd(aConsultas,AllTrim(BR8->BR8_CODPAD+BR8->BR8_CODPSA))
		endIf

		//Segundo o manual de intercambio, para verificao de periodicidade na
		//solicitacao, sera considerado somente a consulta 10101012
		if !lInterc .or. (lInterc .and. alltrim(cCodPro) $ getNewPar("MV_PTCELET","10101012"))

			nPos := ascan(aConsultas,allTrim(cCodPad)+AllTrim(cCodPro))

		endIf

	endIf

	restArea(aAreaBR8)

return(nPos>0)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsRqCon    ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRQCon(cCodPad,cCodPro)
	LOCAL aConsultas := {}
	LOCAL cRet1      := cCodPad + " IN ("
	LOCAL cRet2      := cCodPro + " IN ("
	LOCAL nFor

	if empty(__MV_PLSCDCO)
		__MV_PLSCDCO := allTrim(getNewPar("MV_PLSCDCO",""))
	endIf

	aConsultas 	:= { __MV_PLSCDCO }

	if __PLSISCON

		aRet := execBlock("PLSISCON",.F.,.F.)

		For nFor := 1 To Len(aRet)
			aadd(aConsultas,aRet[nFor])
		Next

	Endif

	For nFor := 1 To Len(aConsultas)

		cRet1 += "'"+Subs(aConsultas[nFor],1,2)+"',"
		cRet2 += "'"+AllTrim(Subs(aConsultas[nFor],3,16))+"',"

	Next

	cRet1 := Subs(cRet1,1,Len(cRet1)-1)+")"
	cRet2 := Subs(cRet2,1,Len(cRet2)-1)+")"

Return({cRet1,cRet2})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsRtCdCed  ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRTCDCED(cCodOpe,cCodCri,nRet)
	LOCAL cRet
	DEFAULT nRet := 1

	If     nRet == 1
		BCT->(DbSetOrder(3))
		BCT->(MsSeek(xFilial()+cCodOpe+AllTrim(cCodCri)))
	ElseIf nRet == 2
		BCT->(DbSetOrder(1))
		BCT->(MsSeek(xFilial()+cCodOpe+AllTrim(cCodCri)))
	ElseIf nRet == 3 .Or. nRet == 4  .Or. nRet == 5
		SIX->(DbSetOrder(1))
		If SIX->(MsSeek("BCT4"))
			BCT->(DbSetOrder(4))
			BCT->(MsSeek(xFilial()+cCodOpe+AllTrim(cCodCri)))
		Else
			BCT->(DbSetOrder(3))
			BCT->(MsSeek(xFilial()+cCodOpe+AllTrim(cCodCri)))
		Endif
	Endif

	If     nRet == 1 .Or. nRet == 3
		cRet := IF(BCT->(Found()), BCT->BCT_DESCRI, cCodCri+" - "+PadR(STR0065,20) ) //"VERIFICAR TABELA EDI"
	ElseIf nRet == 2
		cRet := IF(BCT->(Found()), BCT->BCT_CODEDI,"000" )
	ElseIf nRet == 4
		cRet := IF(BCT->(Found()), BCT->(BCT_PROPRI+BCT_CODGLO),"000" )
	ElseIf nRet == 5

		cRet := IF(BCT->(Found()), Posicione("SX5",1,xFilial("SX5")+"CM"+BCT->BCT_CODED2,"X5_DESCRI"),"" )
	Endif

Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDNIV ºAutor  ³Geraldo Felix Juniorº Data ³  16/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Valida a troca do nivel de cobranca...                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSVLDNIV()
	LOCAL cVar  := ReadVar()
	LOCAL lRet	:= .T.
	LOCAL cSql	:= ''
	LOCAL cSql2	:= ''
	Local aArea := GetArea()
	// Somente para auteracao...
	If !Altera
		Return(.T.)
	Endif

	cSql := "Select Count(R_E_C_N_O_) NBSQ From "+RetSqlName("BSQ")+" Where "
	cSql2:= "Select BSQ_NUMCOB From "+RetSqlName("BSQ")+" Where "

	If cVar == "M->BG9_COBNIB"
		cWhere := "BSQ_CODINT = '"+BG9->BG9_CODINT+"' 	AND "
		cWhere += "BSQ_CODEMP = '"+BG9->BG9_CODIGO+"' 	AND "
		cWhere += "BSQ_COBNIV = '1' 					AND "
		cWhere += "D_E_L_E_T_ = '' "

	Elseif cVar == "M->BT5_COBNIV"
		If M->BT5_COBNIV <> '0'
			Return(.T.)
		Endif
		cWhere := "BSQ_CODINT = '"+BT5->BT5_CODINT+"' 	AND "
		cWhere += "BSQ_CODEMP = '"+BT5->BT5_CODIGO+"' 	AND "
		cWhere += "BSQ_CONEMP = '"+BT5->BT5_NUMCON+"'	AND "
		cWhere += "BSQ_VERCON = '"+BT5->BT5_VERSAO+"'	AND "
		cWhere += "BSQ_COBNIV = '2' 					AND "
		cWhere += "D_E_L_E_T_ = '' "

	Elseif cVar == "M->BQC_COBNIV"
		If M->BQC_COBNIV <> '0'
			Return(.T.)
		Endif
		cWhere := "BSQ_CODINT+BSQ_CODEMP = '"+BQC->BQC_CODIGO+"' 	AND "
		cWhere += "BSQ_CONEMP = '"+BQC->BQC_NUMCON+"'	AND "
		cWhere += "BSQ_VERCON = '"+BQC->BQC_VERCON+"'	AND "
		cWhere += "BSQ_SUBCON = '"+BQC->BQC_SUBCON+"'	AND "
		cWhere += "BSQ_VERSUB = '"+BQC->BQC_VERSUB+"'	AND "
		cWhere += "BSQ_COBNIV = '3' 					AND "
		cWhere += "D_E_L_E_T_ = '' "

	Elseif cVar == "M->BA3_COBNIV"
		If M->BA3_COBNIV <> '0'
			Return(.T.)
		Endif
		If lJuridico						// Variavel definida no cadastro de Familia/usuario.
			cWhere := "BSQ_CODINT = '"+BA3->BA3_CODINT+"'	AND "
			cWhere += "BSQ_CODEMP = '"+BA3->BA3_CODEMP+"' 	AND "
			cWhere += "BSQ_CONEMP = '"+BA3->BA3_NUMCON+"'	AND "
			cWhere += "BSQ_VERCON = '"+BA3->BA3_VERCON+"'	AND "
			cWhere += "BSQ_SUBCON = '"+BA3->BA3_SUBCON+"'	AND "
			cWhere += "BSQ_VERSUB = '"+BA3->Ba3_VERSUB+"'	AND "
			cWhere += "BSQ_MATRIC = '"+BA3->BA3_MATRIC+"'	AND "
			cWhere += "BSQ_COBNIV = '4' 					AND "
			cWhere += "D_E_L_E_T_ = '' "
		Endif
	Endif

	PlsQuery((cSql+cWhere),"TRBBSQ1")
	PlsQuery((cSql2+cWhere),"TRBBSQ2")

	If TRBBSQ1->NBSQ <> 0 .And. AllTrim(TRBBSQ2->BSQ_NUMCOB) == ''
		MsgStop(STR0066) //"Existe lancamento de Debito ou Credito em aberto para este nivel de cobranca... Verifique!"
		lRet := .F.
	Endif

	TRBBSQ1->( dbCloseArea() )
	TRBBSQ2->( dbCloseArea() )
	RestArea(aArea)

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSRETNCB  ³ Autor ³ Tulio Cesar       Data ³ 10.03.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Retorna o nivel de cobranca de uma familia.               ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETNCB(cCodOpe,cCodEmp,cMatric,cOpeOri,lChkFam)
	LOCAL aRet    := {.F.}
	LOCAL lOK     := .F.
	LOCAL cCodCli := ""
	LOCAL cLoja   := ""
	LOCAL cNivel  := ""
	LOCAL nOrdBA0 := BA0->(IndexOrd())
	LOCAL nRecBA0 := BA0->(Recno())
	LOCAL cAlias  := ""

	DEFAULT cOpeOri := PLSINTPAD()
	DEFAULT lChkFam := .T.

	If Type("M->BA3_TIPOUS") <> "U"
		cAlias := "M"
	Else
		cAlias := "BA3"
	EndIf

	If &(cAlias+"->BA3_TIPOUS") == "1" //PF

		If &(cAlias+"->BA3_COBNIV") == "1"

			lOK := .T.

			If ! Empty(&(cAlias+"->BA3_CODCLI"))

				cCodCli := &(cAlias+"->BA3_CODCLI")
				cLoja   := &(cAlias+"->BA3_LOJA")
				cNivel  := "4" //Familia

			EndIf

		Endif

	ElseIf &(cAlias+"->BA3_TIPOUS") == "2" //PJ

		BQC->(dbsetOrder(1))
		BT5->(dbsetOrder(1))

		If     lChkFam .And. &(cAlias+"->BA3_COBNIV") == "1" .And. ! Empty(&(cAlias+"->BA3_CODCLI"))
			cCodCli := &(cAlias+"->BA3_CODCLI")
			cLoja   := &(cAlias+"->BA3_LOJA")
			lOK     := .T.
			cNivel  := "4" //Familia

		ElseIf BQC->(msSeek(xFilial("BQC")+&(cAlias+"->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)"))) .and. BQC->BQC_COBNIV == "1" .and.  ! Empty(BQC->BQC_CODCLI)

			cCodCli := BQC->BQC_CODCLI
			cLoja   := BQC->BQC_LOJA
			lOK     := .T.
			cNivel  := "3" //SubContrato

		ElseIf BT5->(msSeek(xFilial("BT5")+&(cAlias+"->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)"))) .and. BT5->BT5_COBNIV == "1" .and.  ! Empty(BT5->BT5_CODCLI)

			If BT5->BT5_INTERC == "1" .And. AllTrim(BT5->BT5_TIPOIN) == GetNewPar("MV_PLSCDIE","1")// Eventual

				BA0->(DbSetOrder(1))
				If BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. ! Empty(BA0->BA0_CODCLI)

					cCodCli := BA0->BA0_CODCLI
					cLoja   := BA0->BA0_LOJA
					lOK     := .T.
					cNivel  := "5" //Operadora

					BA0->(DbSetOrder(nOrdBA0))
					BA0->(DbGoTo(nRecBA0))

				Endif

			Else

				cCodCli := BT5->BT5_CODCLI
				cLoja   := BT5->BT5_LOJA
				lOK     := .T.
				cNivel  := "2" //Contrato
			Endif

		ElseIf ! Empty(BG9->BG9_CODCLI)

			cCodCli := BG9->BG9_CODCLI
			cLoja   := BG9->BG9_LOJA
			lOK     := .T.
			cNivel  := "1" //Grupo Empresa

		ElseIf &(cAlias+"->BA3_COBNIV") == "1" .And. ! Empty(&(cAlias+"->BA3_CODCLI"))

			cCodCli := &(cAlias+"->BA3_CODCLI")
			cLoja   := &(cAlias+"->BA3_LOJA")
			lOK     := .T.
			cNivel  := "4" //Familia

		Endif

	Endif

	If  ! Empty(cCodCli)

		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+cCodCli+cLoja))

			aRet := {lOK,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,cNivel,SA1->(Recno()),;
				Iif(!EMPTY(SA1->A1_CEINSS),SA1->A1_CEINSS,SA1->A1_CGC),SA1->A1_INSCR,SA1->A1_END,SA1->A1_BAIRRO,SA1->A1_CEP,SA1->A1_MUN,;
				SA1->A1_EST,SA1->A1_DDD,SA1->A1_TEL,SA1->A1_FAX}
		Endif

	Else

		aRet := {lOK,Space(TamSx3("A1_COD")[1]),Space(TamSx3("A1_LOJA")[1]),Space(TamSx3("A1_NOME")[1]),cNivel,0,;
			Space(TamSx3("A1_CGC")[1]),Space(TamSx3("A1_INSCR")[1]),Space(TamSx3("A1_END")[1]),Space(TamSx3("A1_BAIRRO")[1]),Space(TamSx3("A1_CEP")[1]),Space(TamSx3("A1_MUN")[1]),;
			Space(TamSx3("A1_EST")[1]),Space(TamSx3("A1_DDD")[1]),Space(TamSx3("A1_TEL")[1]),Space(TamSx3("A1_FAX")[1])}
	Endif

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSPICPRO³ Autor ³ Tulio Cesar        Data ³ 31.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a picture de acordo com o tipo de tabela.        ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPICPRO(cCdTbPd,cCodPro)
	LOCAL cPicture := "@R "
	BR4->(DbSetOrder(1))
	BR4->(MsSeek(xFilial("BR4")+cCdTbPd))
	While ! BR4->(Eof()) .And. BR4->(BR4_FILIAL+BR4_CODPAD) == xFilial("BR4")+cCdTbPd
		cPicture += Replicate("9",Val(BR4->BR4_DIGITO))+BR4->BR4_SEPARA
		BR4->(DbSkip())
	Enddo

Return(TransForm(cCodPro,cPicture))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FuncaoPLSVDLOCRD³ Autor ³ Tulio Cesar        Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do local de atendimento...                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVDLOCRD(cCodRda,cOpeRda,dData,cCodLoc,cCodPad,cCodPro,aBD6,cCep, cCodPla, cVerPla)
	LOCAL aCodCri   := {}
	LOCAL lFlag     := .f.
	LOCAL lFound    := .f.
	LOCAL nFor		:= 0
	LOCAL cSQL		:= ""
	LOCAL cChavePes := ""
	local cCodInt	:= PLSINTPAD()

	DEFAULT dData   := dDataBase
	DEFAULT cCodLoc := ""
	DEFAULT cCep	:= ""
	DEFAULT cCodPla := ""
	DEFAULT cVerPla := ""
	DEFAULT aBD6    := {}

	if empty(dData)
		dData := dDataBase
	endIf

	BB8->(dbSetOrder(1))//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL

	//Tratamento de área de abrangência do plano do beneficiário
	if PLSPOSGLO(cCodInt,__aCdCri500[1],__aCdCri500[2],"1", "1")

		if ! empty(cCodPla) .and. ! empty(cVerPla)

			if BB8->( msSeek( xFilial("BB8") + cCodRda + cOpeRda + cCodLoc ) )

				cSQL := " SELECT BCZ_EST, BCZ_CODMUN  "
				cSQL += "   FROM " + retSQLName("BCZ")
				cSQL += "  WHERE BCZ_FILIAL = '" + xFilial("BCZ") + "' "
				cSQL += "    AND BCZ_CODIGO = '" + cCodInt + cCodPla + "' "
				cSQL += "    AND BCZ_VERSAO = '" + cVerPla + "' "
				cSQL += "    AND BCZ_EST    = '" + BB8->BB8_EST + "' "
				cSQL += "    AND ( BCZ_CODMUN = '" + BB8->BB8_CODMUN + "' OR BCZ_CODMUN = '' ) "
				cSQL += "    AND D_E_L_E_T_   = '' "

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"tmpMunEst",.F.,.T.)

				if tmpMunEst->(eof())

					BCZ->(dbSetOrder(1))//BCZ_FILIAL+BCZ_CODIGO+BCZ_VERSAO+BCZ_CODMUN
					if BCZ->( msSeek( xFilial("BCZ") + cCodInt + cCodPla + cVerPla ) )

						aadd(aCodCri,{__aCdCri500[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})

						tmpMunEst->(dbCloseArea())

						return({.F.,aCodCri})

					endIf

				endIf

				tmpMunEst->(dbCloseArea())

			endIf

		endIf

	endIf

	//Posiciona no primeiro local de atendimento...
	If Empty(cCodLoc)
		cChavePes := xFilial("BB8")+cCodRda+cOpeRda
	Else
		cChavePes := xFilial("BB8")+cCodRda+cOpeRda+cCodLoc
	Endif

	If ! BB8->(MsSeek(cChavePes))

		If Empty(cCodLoc)
			cChavePes := xFilial("BB8")+cCodRda+cCodInt
		Else
			cChavePes := xFilial("BB8")+cCodRda+cCodInt+cCodLoc
		Endif

		If ! BB8->(MsSeek(cChavePes))

			PLSPOSGLO(cCodInt,__aCdCri006[1],__aCdCri006[2])

			If Len(aBD6) == 0
				aadd(aCodCri,{__aCdCri006[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			Else

				For nFor := 1 To Len(aBD6)
					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]
					aadd(aCodCri,{__aCdCri006[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				Next

			Endif

			Return({.F.,aCodCri})

		Endif

	Endif

	// não posso bloquear vindo da importação da tiss esse item sera passado novamente na mudanaça de fase, ai irá criticar caso esteje bloqueado
	If ! IsInCallStack('PLSA974') .and. PLSPOSGLO(cCodInt,__aCdCri084[1],__aCdCri084[2]) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri084[1]} ) .And. ;
			! Empty(BB8->BB8_DATBLO) .And. dtos(dData) >= dtos(BB8->BB8_DATBLO)

		lFlag := .T.

		If ! Empty(cCodLoc)
			lFlag := .F.
		Else

			lFlag := .f.

			BB8->(DbSkip())

			While ! BB8->(Eof()) .And. BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+cCodRda+cCodInt

				If dtos(dData) < dtos(BB8->BB8_DATBLO) .Or. Empty(BB8->BB8_DATBLO)
					lFlag := .T.
					Exit
				Endif

				BB8->(DbSkip())
			Enddo

		Endif

		If ! lFlag

			If Len(aBD6) == 0
				aadd(aCodCri,{__aCdCri084[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			Else

				For nFor := 1 To Len(aBD6)
					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]
					aadd(aCodCri,{__aCdCri084[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				Next

			Endif

			Return({.F.,aCodCri})

		Endif

	Endif

	//Tratamento da pesquisa inteligente por CEP
	If ! Empty(cCep) .and. alltrim(BB8->BB8_CEP) <> alltrim(cCep)

		nRecBB8 := BB8->(Recno())

		If PLSPOSGLO(cCodInt,__aCdCri084[1],__aCdCri084[2]) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri084[1]} )

			If BB8->(MsSeek(xFilial("BB8")+cCodRda+cOpeRda))

				While ! BB8->(Eof()) .And. (BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+cCodRda+cOpeRDA .or.;
						BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+cCodRda+cCodInt)

					If (dtos(dData) < dtos(BB8->BB8_DATBLO) .Or. Empty(BB8->BB8_DATBLO)) .and. alltrim(BB8->BB8_CEP) == alltrim(cCep)
						lFound := .t.
						Exit
					Endif

					BB8->(DbSkip())
				Enddo

			Endif

		Else

			If BB8->(MsSeek(xFilial("BB8")+cCodRda+cOpeRda))

				While ! BB8->(Eof()) .And. (BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+cCodRda+cOpeRDA .or. ;
						BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+cCodRda+cCodInt)

					If alltrim(BB8->BB8_CEP) == alltrim(cCep)
						lFound := .T.
						Exit
					Endif

					BB8->(DbSkip())
				Enddo

			Endif

		Endif

		If !lFound
			BB8->(DbGoTo(nRecBB8))
		Endif

	Endif

return({.T.,{}})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FuncaoPLSVDESPRD³ Autor ³ Tulio Cesar        Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao especialidade                                ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVDESPRD(cCodRda,cOpeRda,cCodLoc,cCodEsp,dData,cCodPad,cCodPro,aBD6,cEspSol,cEspExe,lDesEsp)
	LOCAL cChavePes		:= ""
	LOCAL lFlag     	:= .f.
	LOCAL lBaxFlag  	:= .f.
	LOCAL aCodCri   	:= {}
	LOCAL nFor			:= 0
	LOCAL nRecBAX		:= 0
	LOCAL cMV_PLSREGE 	:= " "
	local cCodInt		:= plsintpad()

	DEFAULT dData 	:= dDataBase
	DEFAULT cCodEsp := ""
	DEFAULT aBD6    := {}
	DEFAULT cEspSol := ""
	DEFAULT cEspExe := ""
	DEFAULT lDesEsp := .F.

	If Empty(dData)
		dData := dDataBase
	Endif

	//Chave da Especialidade
	If empty(cCodEsp)
		cChavePes := xFilial("BAX")+cCodRda+cOpeRda+BB8->BB8_CODLOC
	Else
		cChavePes := xFilial("BAX")+cCodRda+cOpeRda+cCodLoc+cCodEsp
	Endif

	BAX->(DbSetOrder(1)) //BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
	If ! BAX->(MsSeek(cChavePes))

		If Empty(cCodEsp)
			cChavePes := xFilial("BAX")+cCodRda+cCodInt+BB8->BB8_CODLOC
		Else
			cChavePes := xFilial("BAX")+cCodRda+cCodInt+cCodLoc+cCodEsp
		Endif

		If ! BAX->(MsSeek(cChavePes))

			cChavePes := xFilial("BAX")+cCodRda+cCodInt+cCodLoc+cCodEsp

			If ! BAX->(MsSeek(cChavePes))

				//se nao encontou a especialidade na RDA principal e a rda do solicitante esta preenchida, significa que
				//basta eu selecionar a especialidade principal da RDA pq a do silicitante que eu vou usar para validacao
				lEntrou := .F.
				lFlag   := .F.
				lBaxFlag:= .F.

				//COMO ESTA ATIVO PRECISO PERCORRER ATE A PRINCIPAL PRINIPALMENTE  PARA BAU_TIPPRE ="LAB" quw não precisa enviar o executante no arquivo
				If (!empty(cEspSol) .or. !Empty(cEspExe) .or. lDesEsp) .and. (cCodEsp == cEspSol .or. cCodEsp == cEspExe .or. lDesEsp) .or. GetNewPar("MV_PLSCTES","0") == "1"

					cChavePes := xFilial("BAX")+cCodRda+cCodInt+cCodLoc

					If BAX->(MsSeek(cChavePes))

						While ! BAX->(Eof()) .And. BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC) == xFilial("BAX")+cCodRda+cCodInt+cCodLoc

							If (dtos(dData) < dtos(BAX->BAX_DATBLO) .Or. Empty(BAX->BAX_DATBLO)) .and. BAX->BAX_ESPPRI == '1'

								lFlag 		:= .T.
								lBaxFlag    := .F.
								lEntrou     := .T.

								exit

							Elseif (dtos(dData) < dtos(BAX->BAX_DATBLO) .Or. Empty(BAX->BAX_DATBLO)) .and. !lFlag

								lFlag 	:= .T.
								lBaxFlag:= .T.
								lEntrou := .T.
								nRecBAX := BAX->( Recno() )

								exit

							Endif

							BAX->(DbSkip())
						Enddo

						If lBaxFlag
							BAX->( dbGoto(nRecBAX) )
						Endif

					Endif

				Endif

				If !lEntrou

					PLSPOSGLO(cCodInt,__aCdCri016[1],__aCdCri016[2])

					If Len(aBD6) == 0

						aadd(aCodCri,{__aCdCri016[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						aadd(aCodCri,{""   ,STR0095,cCodRda,"","",cCodPad,cCodPro})  //"Codigo da Rda"
						aadd(aCodCri,{""   ,STR0096,cOpeRda,"","",cCodPad,cCodPro})  //"Operadora da Rda"
						aadd(aCodCri,{""   ,STR0097,cCodLoc,"","",cCodPad,cCodPro})  //"Local de Atendimento"
						aadd(aCodCri,{""   ,STR0098,cCodEsp,"","",cCodPad,cCodPro})  //"Codigo da Especialidade"
						aadd(aCodCri,{""   ,STR0099,"BAX","","",cCodPad,cCodPro})  //"Entidade"

					Else

						For nFor := 1 To Len(aBD6)

							cCodPad := aBD6[nFor,3]
							cCodPro := aBD6[nFor,4]

							aadd(aCodCri,{__aCdCri016[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
							aadd(aCodCri,{""   ,STR0095,cCodRda,"","",cCodPad,cCodPro})  //"Codigo da Rda"
							aadd(aCodCri,{""   ,STR0096,cOpeRda,"","",cCodPad,cCodPro})  //"Operadora da Rda"
							aadd(aCodCri,{""   ,STR0097,cCodLoc,"","",cCodPad,cCodPro})  //"Local de Atendimento"
							aadd(aCodCri,{""   ,STR0098,cCodEsp,"","",cCodPad,cCodPro})  //"Codigo da Especialidade"
							aadd(aCodCri,{""   ,STR0099,"BAX","","",cCodPad,cCodPro}) //"Entidade"

						Next

					Endif

					Return({.F.,aCodCri})

				Else

					if IsInCallStack('PLSA090MOV') // Foi digitado uma especialidade que nao existe no cadastro (BAX) somente posiciono na principal se chegou ate aqui e porque o que ele digitou nao existe.
						Return({.F.,{}})
					endIf

				Endif

			Endif

		Endif

	Else

		If PLSPOSGLO(cCodInt,__aCdCri083[1],__aCdCri083[2]) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri083[1]} ) .And. !Empty(BAX->BAX_DATBLO) .And. dtos(dData) >= dtos(BAX->BAX_DATBLO)

			lFlag := .T.

			If ! Empty(cCodEsp)

				lFlag := .F.

			Else

				lFlag 		:= .F.
				lBaxFlag	:= .F.

				BAX->(DbSkip())

				While ! BAX->(Eof()) .And. BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC) == xFilial("BAX")+cCodRda+cCodInt+BB8->BB8_CODLOC

					If (dtos(dData) < dtos(BAX->BAX_DATBLO) .Or. Empty(BAX->BAX_DATBLO)) .and. BAX->BAX_ESPPRI == '1'

						lFlag 		:= .T.
						lBaxFlag	:= .F.

						exit

					Elseif (dtos(dData) < dtos(BAX->BAX_DATBLO) .Or. Empty(BAX->BAX_DATBLO)) .and. !lFlag

						lFlag 	:= .T.
						lBaxFlag:= .T.
						nRecBAX := BAX->( Recno() )

					endIf

					BAX->(DbSkip())
				Enddo

				If lBaxFlag
					BAX->( dbGoto(nRecBAX) )
				Endif

			Endif

			If ! lFlag

				cMV_PLSREGE := GetNewPar("MV_PLSREGE","1")

				If cMV_PLSREGE == "0"

					If Len(aBD6) == 0
						aadd(aCodCri,{__aCdCri083[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					Else

						For nFor := 1 To Len(aBD6)
							cCodPad := aBD6[nFor,3]
							cCodPro := aBD6[nFor,4]
							aadd(aCodCri,{__aCdCri083[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
						Next

					Endif

					Return({.F.,aCodCri})

				EndIf

			Endif

		Else

			If Empty(cCodEsp)

				nRecBAX := BAX->( Recno() )
				lFlag := .F.

				While ! BAX->(Eof()) .And. BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC) == xFilial("BAW")+cCodRda+cCodInt+BB8->BB8_CODLOC

					If (dtos(dData) < dtos(BAX->BAX_DATBLO) .Or. Empty(BAX->BAX_DATBLO)) .and. BAX->BAX_ESPPRI == '1'
						lFlag := .T.
						Exit
					Endif

					BAX->(DbSkip())
				Enddo

				If !lFlag
					BAX->( dbGoto(nRecBAX) )
				Endif

			Endif

		Endif

	Endif

	//Posiciona na especialidade...
	BAQ->(DbSetOrder(1))
	If ! BAQ->(MsSeek(xFilial("BAQ")+BAX->BAX_CODINT+BAX->BAX_CODESP))

		PLSPOSGLO(cCodInt,__aCdCri016[1],__aCdCri016[2])

		If Len(aBD6) == 0

			aadd(aCodCri,{__aCdCri016[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			aadd(aCodCri,{""   ,STR0095,cCodRda,"","",cCodPad,cCodPro})  //"Codigo da Rda"
			aadd(aCodCri,{""   ,STR0096,cOpeRda,"","",cCodPad,cCodPro})  //"Operadora da Rda"
			aadd(aCodCri,{""   ,STR0097,cCodLoc,"","",cCodPad,cCodPro})  //"Local de Atendimento"
			aadd(aCodCri,{""   ,STR0098,cCodEsp,"","",cCodPad,cCodPro})  //"Codigo da Especialidade"
			aadd(aCodCri,{""   ,STR0099,"BAQ","","",cCodPad,cCodPro})  //"Entidade"

		Else

			For nFor := 1 To Len(aBD6)

				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]

				aadd(aCodCri,{__aCdCri016[1],PLSBCTDESC(),cOpeRda,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				aadd(aCodCri,{""   ,STR0095,cCodRda,"","",cCodPad,cCodPro})  //"Codigo da Rda"
				aadd(aCodCri,{""   ,STR0096,cOpeRda,"","",cCodPad,cCodPro})  //"Operadora da Rda"
				aadd(aCodCri,{""   ,STR0097,cCodLoc,"","",cCodPad,cCodPro})  //"Local de Atendimento"
				aadd(aCodCri,{""   ,STR0098,cCodEsp,"","",cCodPad,cCodPro})  //"Codigo da Especialidade"
				aadd(aCodCri,{""   ,STR0099,"BAQ","","",cCodPad,cCodPro})  //"Entidade"

			Next

		Endif

		Return({.F.,aCodCri})

	Endif

Return({.T.,{}})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsGatNic   ºAutor  ³Tulio Cesar       º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGatNiC(cCodTab,cCodPro,cAlias)
	LOCAL aRet    := {5}//temporario
	LOCAL aPos    := {1,2,3,4,5} // temporario
	LOCAL nInd
	LOCAL cMacro
	LOCAL nAux    := 0
	LOCAL cAnt    := ""

	For nInd := 1 To aRet[1]
		cMacro     := "M->"+cAlias+"_CDCD0"+StrZero(nInd,1)
		if alltrim(cAnt) == alltrim(Subs(cCodPro,1,aPos[nInd]))
			&(cMacro)  := ""
		else
			&(cMacro)  := Subs(cCodPro,1,aPos[nInd])
		endif
		cAnt       := Subs(cCodPro,1,aPos[nInd])
	Next
	lRefresh := .T.
Return(.T.)

// funcao descontinuada - SGBD
Function PLSX1DIFF(cPerg,aRegs)	
Return

// funcao descontinuada
Function PlsExiNiNa(cAlias,cNickName)
return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FuncaoPlsEspPad ³ Autor ³ Daher				 Data ³ 05/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Espelha um procedimento na tabela padrão					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsEspPad(cCodPad,cCodPro,cAtiBen)
	LOCAL cDado  := ""
	LOCAL cCampo := ""
	DEFAULT cAtiBen := "0"

	BR8->(DBSetOrder(1))
	If !BR8->(DBSeek(xFilial("BR8")+cCodPad+cCodPro))
		BR8->(RecLock("BR8",.T.))
		BR8->BR8_FILIAL := xFilial("BR8")
		BR7->(DBGoTop())
		While ! BR7->(Eof())
			If BR7->BR7_PROCES == "3"
				cDado  := &("BA8->"+AllTrim(BR7->BR7_FLDTDE))
				cCampo := "BR8->"+AllTrim(BR7->BR7_FLDPSA)
				&cCampo := cDado
			Else
				If BR7->BR7_PROCES == "1"
					cDado  := &("BA8->"+AllTrim(BR7->BR7_FLDTDE))
					cCampo := "BR8->"+AllTrim(BR7->BR7_FLDPSA)
					&cCampo := cDado
				Endif
			Endif
			BR7->(DbSkip())
		Enddo

		BR8->BR8_BENUTL := cAtiBen
		BR8->(MsUnLock())
	Endif
Return

// funcao descontinuada
Function PlsGetVersao()
Return 12

// funcao descontinuada
Function PlsDeReDel(aAlias)
return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSRgAtWeb³ Autor ³ Tulio Cesar       Data ³ 15.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna regime de atendimento para atendimento na web  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSRgAtWeb(dData,cHora,cTipPre)
	LOCAL cTipo   := "1"

	//³cTipo "1" Normal															 ³
	//³	     "2" Emergencia por ser um hospital									 ³

	If cTipPre == GetNewPar("MV_PLSTPHS","HOS")
		cTipo := "2"
	Else
		BAS->(DbSetOrder(1))
		If BAS->(MsSeek(xFilial("BAS")))
			While ! BAS->(Eof()) .And. BAS->BAS_FILIAL == xFilial("BAS")
				If ( Dow(dData) == Val(BAS->BAS_DIASEM) ) .Or. ( PLSFeriado(dData, .T., BB8->BB8_CODIGO, BB8->BB8_CODLOC ) .And. BAS->BAS_DIASEM == "8" ) //Registro na BB8 fica posicionado, logo, posso passar RDA e Local
				BAR->(DbSetOrder(1))
				If BAR->(MsSeek(xFilial("BAR")+BAS->BAS_CODIGO))
					If ( cHora >= BAR->BAR_HORINI .And. cHora <= BAR->BAR_HORFIN ) .And. ;
							( ( dtos(dData) >= dtos(BAR->BAR_VIGINI) ) .And. ( dtos(dData) <= dtos(BAR->BAR_VIGFIN) .Or. Empty(BAR->BAR_VIGFIN) ) )
						cTipo := "2" //Emergencia
						Exit
					Endif
				Endif
				Endif
				BAS->(DbSkip())
			Enddo
		Endif
	Endif

	//³Fim da Funcaoc															 ³

Return(cTipo)

/*/{Protheus.doc} PLSRETAULI
retorna dados de uma liberacao em aberto
@type function
@author PLSTEAM
@since 12/12/17
@version 1.0
/*/
Function PLSRETAULI(cMatricUsr,cNumAut,cTp,cRdaExec,cCodLoc,cCodEsp,cCodPRFExe,cLocalExec,lWeb,aRda,aUsr,cTipo,cEspSol,cEspExe,cAltera,cDatAtd)
	LOCAL nI		 := 0
	LOCAL nQtdUs	 := 0
	LOCAL nVlrCon	 := 0
	LOCAL nVlrTPF	 := 0
	LOCAL lFound   	 := .F.
	LOCAL lContinua  := .T.
	LOCAL lTrtExe	 := .F.
	LOCAL lChkExe	 := .T.
	LOCAL lHaveOne	 := .F.
	LOCAL cMsgCriEsp := ""
	LOCAL dDatPro    := dDataBase
	LOCAL cMsg	   	 := ""
	LOCAL cOpeSol	 := ""
	LOCAL cProSol	 := ""
	LOCAL cNomeSol 	 := ""
	LOCAL cCodSigSol := ""
	LOCAL cNumCrSol  := ""
	LOCAL cEstSigSol := ""
	LOCAL cOpeExe	 := ""
	LOCAL cProExe	 := ""
	LOCAL cNomeExe 	 := ""
	LOCAL cCodSigExe := ""
	LOCAL cNumCrExe  := ""
	LOCAL cEstSigExe := ""
	LOCAL cMacroIte  := ""
	LOCAL cBE2Valid  := "0"
	LOCAL cTipoU	 := "1"
	LOCAL cFilLog    := "PLSTREXE.LOG"
	LOCAL cMacro     := Iif(cTp=="L","BEA->BEA_TIPO " + Iif(cTipo<="2","<=","=") + "'"+cTipo+"' .And. BEA->BEA_STATUS <> '5' .And. BEA->BEA_ORIGEM == '2' .And. (BEA->BEA_STALIB == '1' .Or. (BEA->BEA_STALIB == '6' .And. PLIBAUD(@cNumAut))) .And. BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO) == '"+cMatricUsr+"'","1=1")
	LOCAL cMacroA    := IIF(cAltera == "Altcmp", "BEA->BEA_TIPO <='2' .AND. BEA->BEA_STATUS <> '5'", "") //Iif(cTp=="L","BEA->BEA_TIPO " + Iif(cTipo<="2","<=","=") + "'"+cTipo+"' .And. BEA->BEA_STATUS <> '5' .And. BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO) == '"+cMatricUsr+"'","1=1")
	LOCAL cTransNum  := "@R !!!!.!!!!.!!-!!!!!!!!"
	LOCAL cTransMat  := "@R !!!!.!!!!.!!!!!!-!!-!"
	LOCAL cTissVer	 := PLSTISSVER(cRdaExec)
	LOCAL aRetExec   := {}
	LOCAL aCabec   	 := {}
	LOCAL aItens   	 := {}
	LOCAL aCriticas	 := {}
	LOCAL aDadUsr    := {}
	LOCAL aDadRDA    := {}
	LOCAL aRetFun    := {}
	LOCAL aRetCri  	 := {}
	LOCAL aCriGer    	:= {}
	LOCAL lIntercambio 	:= .F.
	LOCAL cNomPla    	:= ""
	LOCAL dDtVldCar  	:= CTOD("")
	LOCAL cCarSaud   	:= ""
	local dDataVal		:= CTOD("")
	local nNumero		:= 0
	local lValCarg		:= GetNewPar("MV_PLVCGUI", .F.)
	local lNewAud       := GetNewPar("MV_PL790NE","0") == "1"
	local lTemSeriad    := .F.
	local lCri09S       := .F.
	Local lPERet09S     := .F.
	local aAreaBE2      := {}
	local aSeriado      := {}

	DEFAULT cTipo      := "1"
	DEFAULT cMatricUsr := ""
	DEFAULT cNumAut    := ""
	DEFAULT cRdaExec   := ""
	DEFAULT cCodLoc    := ""
	DEFAULT cCodEsp	   := ""
	DEFAULT cCodPRFExe := ""
	DEFAULT cLOCALExec := "1"
	DEFAULT lWeb	   := .T.
	DEFAULT aRda	   := {}
	DEFAULT aUsr	   := {}
	DEFAULT cEspSol   := ""
	DEFAULT cEspExe   := ""
	DEFAULT cDatAtd	:= ""

	//Primeira verificacao de matricula de usuario de intercambio (cMatricUsr preenchido)
	BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	If  !BA1->( MsSeek( xFilial("BA1")+AllTrim(cMatricUsr) ) )

		BA1->( DbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
		If !BA1->( MsSeek( xFilial("BA1")+AllTrim(cMatricUsr) ) )

			If  SubStr(cMatricUsr,1,4) <> PLSINTPAD()
				lIntercambio := .T.
			Endif

		Endif

	EndIf

	//Se na web ou nao
	If lWeb
		cMacroIte := Iif(cTp=="L","BE2->BE2_SALDO > 0 .And. BE2->BE2_STATUS == '1' .And. (!lTemSeriad .Or. (lTemSeriad .And. aScan(aSeriado,BE2->BE2_SEQUEN) > 0))","1=1")
	Else
		cMacroIte := Iif(cTp=="L","BE2->BE2_STATUS == '1'","1=1")
	EndIf

	IF ( cAltera == "Altcmp" )   //Alteração de alguns campos na guia
		cMacroIte := Iif(cTp=="L","BE2->BE2_STATUS == '1'","1=1")
	endIf

	//Monta a chave
	If ! Empty(cNumAut)
		nIndex := 1 //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT
		cChave := cNumAut
	else
		nIndex := 10 //BEA_FILIAL + BEA_OPEMOV+ BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO + BEA_ORIGEM
		cChave := plsIntPad() + cMatricUsr + "2"
	endIf

	//Se for liberacao
	If cTp = "L"

		//Dados do usuatio
		If Len(aUsr) == 0

			aRetFun := PLSDADUSR(cMatricUsr,cTipoU,.F.,dDatPro,nil,nil,nil)

			if aRetFun[1]
				aUsr := PLSGETUSR()
			else

				if lWeb

					for nI := 1 to len(aRetFun[2])
						cMsg += aRetFun[2,nI,1] + " - " + allTrim(aRetFun[2,nI,2]) + Iif(nI != 1," - " + allTrim(aRetFun[2,nI,3]),"") + Chr(13) + Chr(10)
					next

				else
					aCriticas := aRetFun[2]
				endIf

				lContinua := .f.
			endIf

		endIf

		if len(aRda) == 0

			if lContinua

				BB8->( MsSeek(xFilial("BB8")+cRdaExec+PlsIntPad()+cCodLoc) )

				lTrtExe := iIf(BB8->BB8_TRTEXE=='1',.T.,.F.)

				aRetFun := PLSDADRDA(PlsIntPad(),cRdaExec,"1",dDatPro,cCodLoc,cCodEsp,,,,lTrtExe)

				if aRetFun[1] .or. lTrtExe
					aRda := PLSGETRDA()
				else

					if lWeb

						for nI := 1 to len(aRetFun[2])
							cMsg += aRetFun[2,nI,1]+" - "+AllTrim(aRetFun[2,nI,2])+Iif(nI!=1," - "+AllTrim(aRetFun[2,nI,3]),"")+Chr(13)+Chr(10)
						next

					else
						aCriticas := aRetFun[2]
					endIf

					lContinua := .F.
				endIf

			endIf

		else
			lTrtExe := iIf( len(aRda) >= 24, iIf(aRda[24] == '1',.t.,.f.) ,.f.)
		endIf

	endIf

	//Verifica se o indice para pesquisa por matricula existe
	if lContinua

		//Posiciona no cabecalho
		BEA->( dbSetOrder(nIndex) )//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
		if BEA->( MsSeek( xFilial("BEA") + cChave ) ) .and. iIf( ! empty(cMacroA), &cMacroA, &cMacro )

			//Segunda verificacao de matricula de usuario de intercambio (cMatricUsr vazio)
			if ! lIntercambio

				BA1->( dbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
				If ! BA1->( MsSeek( xFilial("BA1") + allTrim(BEA->BEA_MATANT)))

					BA1->( dbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
					if BA1->( MsSeek( xFilial("BA1") + allTrim(BEA->BEA_MATANT)))

						if  subStr( allTrim(BEA->BEA_MATANT),1,4) <> PLSINTPAD()
							lIntercambio := .t.
						endIf

					endIf

				endIf

			endIf

			//Se na digitação off-line quero realziar uma execução (campo 2 da guia), devo validar pela data de atendimento digitada, não pela data atual, pois é retroativo
			if !Empty(cDatAtd)
				dDataVal := CtoD(cDatAtd)
			else
				dDataVal := dDataBase
			EndIf

			If ! empty(dtos(BEA->BEA_VALSEN)) .and. BEA->BEA_VALSEN < dDataVal .and. PLSPOSGLO(BEA->BEA_OPEMOV,__aCdCri09S[1],__aCdCri09S[2],,,) .and. getNewPar("MV_PLGSENW",".T.") == .T.

				//Critica 09S verifico se os eventos sao de tratamento seriado, caso sim, nao posso apresentar a critica:

				//"6.4.21. No tratamento seriado, a continuidade do atendimento poderá ser
				//prestada após a validade de 60 (sessenta) dias e enquanto o beneficiário
				//estiver de posse do cartão de identificação válido, considerando como
				//limite o número de sessões liberadas pela Unimed Origem, que efetuará o
				//pagamento total das sessões realizadas."

				lCri09S := .T.
				aAreaBE2 := BE2->(GetArea())
				BJE->(DbSetOrder(1)) //BJE_FILIAL+BJE_CODIGO
				BE2->(DbSetORder(1)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
				BR8->(DbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN

				lPERet09S := ExistBlock("PL09009S")

				if BE2->(MsSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
					while BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) .and. !BE2->(Eof())
						if lPERet09S
							aPERet09S := ExecBlock("PL09009S",.F.,.F.,{BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),BE2->BE2_SEQUEN,lWeb})
							if !aPERet09S[1] //Se um dos itens nao apresentar a critica, ignora a critica para a guia
								lCri09S := .F.
							endIf
							if aPERet09S[2]
								lTemSeriad := .T.
								aadd(aSeriado,BE2->BE2_SEQUEN)
							endIf

						elseIf BE2->BE2_SALDO > 0 .And. BR8->(MsSeek(xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO))) .And. !Empty(BR8->BR8_CLASSE)
							if BJE->(MsSeek(xFilial("BJE")+BR8->BR8_CLASSE)) .And. BJE->BJE_TIPO == "2"
								lTemSeriad := .T.
								lCri09S    := .F. //Se tiver item seriado, nao apresento a critica 09S
								aadd(aSeriado,BE2->BE2_SEQUEN)
							endIf
						endIf
						BE2->(DbSkip())
					endDo
				endIf

				if lCri09S

					lContinua := .f.
					cMsg := __aCdCri09S[1] +" - "+ __aCdCri09S[2] + chr(13) + chr(10) + chr(13) + chr(10)//"09P" - "Quantidade de dias permitido para execução da guia ultrapassado"
					cMsg += STR0238 + " - " + transform(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),cTransNum)  + chr(13) + chr(10)//Guia Liberacao
					cMsg += STR0239 + " - " + transform(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),cTransMat) + chr(13) + chr(10)//Matricula do Usuario
					cMsg += STR0240 + " - " + allTrim(BEA->BEA_NOMUSR) + chr(13) + chr(10)//Nome do Usuario
					cMsg += STR0028 + " - " + dtoc(BEA->BEA_VALSEN)

				endIf

				RestArea(aAreaBE2)
			EndIf

			If lContinua .and. lWeb

				BAU->( dbSetOrder(1) )//BAU_FILIAL + BAU_CODIGO
				BB0->( dbSetOrder(1) )//BB0_FILIAL + BB0_CODIGO

				If ! BAU->( MsSeek(xFilial("BAU")+BEA->BEA_CODRDA) )
					cMsg := STR0080+BEA->BEA_CODRDA //"Rda nao encontrada ->"
				else

					//Solicitante
					if ! BB0->( MsSeek(xFilial("BB0")+Iif(!Empty(BEA->BEA_CDPFSO),BEA->BEA_CDPFSO,BAU->BAU_CODBB0)) )

						if cTp == "L"
							cMsg := STR0081+" ->"+BEA->BEA_CDPFSO //"Solicitante nao encontrado"
						endIf

					else

						cOpeSol	 	:= BB0->BB0_CODOPE
						cProSol    	:= BB0->BB0_CODIGO
						cNomeSol	:= BB0->BB0_NOME
						cCodSigSol 	:= BB0->BB0_CODSIG
						cNumCrSol  	:= BB0->BB0_NUMCR
						cEstSigSol 	:= BB0->BB0_ESTADO

					endIf

					//Executante
					if BB0->( MsSeek(xFilial("BB0")+BEA->BEA_CDPFRE) )
						cOpeExe	 	:= BB0->BB0_CODOPE
						cProExe    	:= BB0->BB0_CODIGO
						cNomeExe	:= BB0->BB0_NOME
						cCodSigExe 	:= BB0->BB0_CODSIG
						cNumCrExe  	:= BB0->BB0_NUMCR
						cEstSigExe 	:= BB0->BB0_ESTADO
					endIf

					//Informacao da solicitacao
					BAQ->( dbSetOrder(1) )
					BAQ->( MsSeek( xFilial("BAQ")+BEA->(BEA_OPEMOV+BEA_CODESP) ) )

					BB8->( dbSetOrder(1) )
					BB8->( MsSeek( xFilial("BB8")+BEA->(BEA_CODRDA+BEA_OPEMOV+BEA_CODLOC) ) )
				endIf

			endIf

			//cabecalho
			if empty(cMsg)

				BA3->( dbSetOrder(1) ) //BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB

				If BA3->( msSeek( xFilial("BA3")+BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC) ) )

					BI3->( dbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
					BI3->( MsSeek( xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA) ) )

					cNomPla := BI3->BI3_NREDUZ

				endIf

				//Validade da Carteirinha
				BA1->( dbSetOrder(2) )//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
				if BA1->( MsSeek( xFilial("BA1")+BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG) ) )

					dDtVldCar := BA1->BA1_DTVLCR

					//Validade da Carteirinha
					BTS->( dbSetOrder(1) ) //BTS_FILIAL + BTS_MATVID
					If BTS->( MsSeek(xFilial("BTS")+BA1->BA1_MATVID) ) .And. BTS->(FieldPos("BTS_NRCRNA")) > 0
						cCarSaud :=  BTS->BTS_NRCRNA
					endIf

				endIf

				if lContinua .and. lWeb

					aCabec := {	BEA->BEA_CODRDA,;														//1-cRda
						Posicione("BA0",1,xFilial("BA0")+BEA->BEA_OPEMOV,"BA0_SUSEP"),; 		//2-cRegAns
						BAU->BAU_NOME,;   														//3-cNomeRda
						BAU->BAU_CPFCGC,;   													//4-cCnpfCpfSol
						BB8->BB8_CNES,;   														//5-cCnesSol
						IiF(BB8->(FieldPos("BB8_TIPLOG"))>0,AllTrim(BB8->BB8_TIPLOG),""),;	//6-Tipo de Logradouro
						AllTrim(BB8->BB8_END),;   												//7-Endereco
						IiF(BB8->(FieldPos("BB8_NR_END"))>0,AllTrim(BB8->BB8_NR_END),""),;	//8-Numero
						IiF(BB8->(FieldPos("BB8_COMEND"))>0,AllTrim(BB8->BB8_COMEND),""),;	//9-Complemento
						Posicione("BID",1,xFilial("BID")+BB8->BB8_CODMUN,"BID_DESCRI") ,;		//10-Municipio
						BB8->BB8_BAIRRO,;   													//11-Bairro
						BB8->BB8_EST,;   														//12-Estado
						BB8->BB8_CODMUN,;   													//13-IBGE
						BB8->BB8_CEP,;   														//14-Cep
						BB8->BB8_TEL,;   														//15-Tel
						BEA->BEA_DATPRO,;														//16-dDtAut
						BEA->BEA_HORPRO,;														//17-cHorAut
						BEA->BEA_SENHA,;  	   													//18-cSenha
						BEA->BEA_VALSEN,;														//19-dDtValid
						BEA->BEA_DATSOL,;														//20-dDtSolicit
						BEA->BEA_HORSOL,;														//21-cHrSolicit
						Iif(cTissVer>='3',AllTrim(BEA->BEA_TIPADM),IF(AllTrim(BEA->BEA_TIPADM) $ GetNewPar("MV_PLSCDIU","4,5"),"U","E")),;//22-cCarSolicit
						BEA->BEA_CID,;															//23-cCid
						cProSol,; 	   															//24-cProSol
						cOpeSol,; 		   														//25-Operadora solicitante
						cNomeSol,; 		   													//26-cNomeSol
						cCodSigSol,;  		   													//27-cCodSigSol
						cNumCrSol,; 		   													//28-cNumCrSol
						cEstSigSol,; 		   													//29-cEstSigSol
						BEA->BEA_CODESP+BAQ->BAQ_CBOS,;										//30-cCbosSol ESPECIALIDADE
						AllTrim(BAQ->BAQ_DESCBO),;												//31-Descricao da ESPECIALIDADE
						cProExe,; 	   															//32-cProExe
						cOpeExe,; 		   														//33-Operadora Executante
						cNomeExe,; 		   													//34-cNomeExe
						cCodSigExe,;  		   													//35-cCodSigExe
						cNumCrExe,; 		   													//36-cNumCrExe
						cEstSigExe,; 		   													//37-cEstSigExe
						AllTrim(BEA->BEA_MSG01+BEA->BEA_MSG02),;								//38-Observacao
						Iif(!Empty(BEA->BEA_MATANT).and. lIntercambio,AllTrim(BEA->BEA_MATANT),AllTrim(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)) ),;//39-Matricula
						BEA->BEA_NOMUSR,;                                                 		//40-Nome do usuario
						BEA->BEA_STATUS,;  										            //41-Status da autorizacao
						BEA->(BEA_INDCLI+BEA_INDCL2),;											//42-Indicacao de Cliente
						BEA->BEA_ORIGEM,;														//43-Se e uma liberacao ou
						BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV),;		//44-Chave BD6 Indice 6
						BEA->BEA_TIPATO,;														//45-Tipo atendimento odontologico
						BEA->BEA_TIPFAT,;														//46-Tipo de faturamento
						BEA->BEA_NUMIMP,;														//47-Numero Impresso
						'',;//48
						'',;//49
						0,;//50
						'',;//51
						'',;//52
						'',;//53
						'',;//54
						'',;//55
						'',;//56
						'',;//57
						CToD(""),;//58
						0,;//59
						'',;//60
						'',;//61
						'',;//62
						'',;//63
						'',;//64
						'',;//65
						'',;//66
						'',;//67
						'',;//68
						Date(),;//69
						CToD(""),;//70
						'',;//71
						'',;//72
						'',;//73
						'',;//74
						cNomPla,;//75
						dDtVldCar,;//76
						cCarSaud,;//77
						'',;//78
						'',;//79
						0,;//80
						'',;//81
						'',;//82
						'',;//83
						'',;//84
						'',;//85
						BEA->BEA_ATERNA,;//86
						ctod(''),;//87
						ctod(''),;//88
						BEA->BEA_DTRLZ,; //89
						BEA->BEA_DTRLZ2,;//90
						BEA->BEA_DTRLZ3,;//91
						BEA->BEA_DTRLZ4,;//92
						BEA->BEA_DTRLZ5,;//93
						BEA->BEA_DTRLZ6,;//94
						BEA->BEA_DTRLZ7,;//95
						BEA->BEA_DTRLZ8,;//96
						BEA->BEA_DTRLZ9,;//97
						BEA->BEA_DTRLZ1,;//98
						BAU->BAU_GRALAU,;//99
						BEA->BEA_TIPSAI,;//100
						BEA->BEA_TIPCON,;//101
						BEA->BEA_TIPATE,;//102
						BEA->BEA_ESTEXE,;//103
						BEA->BEA_REGEXE,;//104
						BEA->BEA_SIGEXE,;//105
						BEA->BEA_CODESP,;//106
						BEA->BEA_CDPFRE,;//107
						BEA->BEA_INDACI,;//108
						BEA->BEA_PROATE,;//109
						BEA->BEA_NRAOPE,;//110 - cGuiaOpe
						BEA->BEA_GUIPRI,;//111 - Nro. Guia Principal 
						Iif( BEA->( FieldPos("BEA_COBESP") ) > 0, BEA->BEA_COBESP,"")} //112 - Cobertura Especial
				EndIf

				//Itens
				BD7->( DbSetOrder(1) )//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
				BR8->( DbSetOrder(1) )//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
				BE2->( DbSetOrder(1) )//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN

				If BE2->( MsSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)) )

					While ! BE2->( Eof() ) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == ;
							xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

						//Matriz de itens
						//execucao, testa se a RDA e executante podem executar o procedimento....
						cBE2Valid := "1"
						cMsgCriEsp:= ""

						//Br8
						BR8->(MsSeek(xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO)))

						//Validacao
						If ((cTp == "L" .And. lValCarg) .Or. (cTp == "A" .And. !lValCarg)) .And. len(aRda) > 0

							PLLimpCCri(.T.)

							//Checa se o executante pode executar
							aRetExec := PLSTratExe(BE2->BE2_CODPAD,BE2->BE2_CODPRO,.T.,.T.,.F.,cLocalExec,cCodPRFExe,;
								NIL,aRda,aUsr,NIL,BE2->BE2_DATPRO,cCodEsp,cCodLoc,nil,;
								nil,nil,cEspSol,cEspExe)

							If ValType(aRetExec) == "A"

								If Len(aRetExec) >= 1 .And. ValType(aRetExec[1]) == "L"

									If ! aRetExec[1]

										BVX->(DbSetOrder(3))
										If !(FdCrifor(BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT),aRetExec[2],aRda[2],{},{},,.T.,Alltrim(BE2->BE2_CODPAD),Alltrim(BE2->BE2_CODPRO),lNewAud))
										cBE2Valid := "0"

										//Pega as criticas
										For nI := 1 To Len(aRetExec[2])

											If !Empty(aRetExec[2,nI,1])
												aRetCri := PLSRETCRI( AllTrim( aRetExec[2,nI,1] ) )
												AaDd(aCriGer,{ "["+allTrim(aRetExec[2,nI,7])+"] - "+aRetCri[1,1],PadR( AllTrim( aRetCri[1,2] ),75 ) } )
											EndIf

											AADD(aCriticas,aclone(aRetExec[2,nI]))

										Next
									EndIf
								EndIf
							Else
								cMsgCriEsp := STR0082 //"SIGAPLS -> Erro controlado PLSRETAULI chamada PLSTRATEXE. Confira informacoes geradas no PLSXMOV.LOG"
							EndIf

						Else
							cMsgCriEsp := STR0082 //"SIGAPLS -> Erro controlado PLSRETAULI chamada PLSTRATEXE. Confira informacoes geradas no PLSXMOV.LOG"
						EndIf

						EndIf

						//Validacao de itens
						If &cMacroIte

							//Valor do procedimento caso guia odontologica
							If cTipo == '4'

								cChkBD7 := xFilial("BD7")+BEA->( BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV ) + BE2->BE2_SEQUEN
								nQtdUs  := 0
								nVlrCon := 0
								nVlrTPF := 0

								If BD7->( MsSeek( cChkBD7 ) )

									While !BD7->( Eof() ) .And. cChkBD7 == xFilial("BD7")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

										nQtdUs	+= BD7->BD7_REFTDE
										nVlrCon	+= BD7->BD7_VLRMAN
										nVlrTPF	+= BD7->BD7_VLRTPF

										BD7->( DbSkip() )
									EndDo

								EndIf

							EndIf

							If cBE2Valid <> '0'
								lHaveOne := .T. //tem pelo mnos um procedimento liberado
							Endif

							AaDd(aItens,{	"S",;														//1  - Tipo de Servico (Servico ou OPM)
								BE2->BE2_SEQUEN,; 				   							//2  - Sequencia
								BE2->BE2_CODPAD,; 				   							//3  - Tabela
								AllTrim(BE2->BE2_CODPRO),;   	   							//4  - Procedimento
								AllTrim(BE2->BE2_DESPRO),; 									//5  - Descricao
								AllTrim(Str(Iif(BE2->BE2_QTDSOL==0,BE2->BE2_QTDPRO,BE2->BE2_QTDSOL))),;//6  - Qtd Solicitada
								AllTrim(Str(BE2->BE2_QTDPRO)),;								//7  - Qtd Autorizada
								BR8->BR8_FABRIC,; 											//8  - Fabricante...
								BE2->BE2_VLRAPR,;											//9  - Vlr Unitario
								cBE2Valid,;                                                 //10 - podera ser exibido sim ou nao
								BE2->BE2_NUMINT,;											//11 - Se e item de uma internacao
								BE2->(Recno()),;											//12 - Recno
								BE2->BE2_SALDO,;											//13 - Saldo
								aRetExec,;													//14 - Matriz de tratamento do executante
								BE2->BE2_NIVAUT,;											//15 - Nivel da Autorizacao
								BE2->BE2_NIVCRI,;											//16 - Nivel da Critica
								BE2->BE2_CHVNIV,;                                        	//17 - Chave do Nivel
								AllTrim(BE2->BE2_DENREG)+'-'+AllTrim(BE2->BE2_DESREG),;   	//18 - Dente - Descricao
								AllTrim(BE2->BE2_FADENT)+'-'+AllTrim(BE2->BE2_FACDES),;   	//19 - Face - Descricao
								nQtdUs,; 		                                       		//20 - Valor Us
								nVlrCon,; 													//21 - Valor Contratado
								nVlrTPF,;                                        			//22 - Valor Participacao
								Iif(BE2->BE2_STATUS=='1','S','N'),; 						//23 - Autorizado sim ou nao
								AllTrim(BE2->BE2_DENREG),;    								//24 - Dente
								AllTrim(BE2->BE2_FADENT),;    								//25 - Face
								BE2->BE2_DATPRO,; 											//26 - Data do Evento
								"",;    													//27
								"",;    													//28
								"",;														//29 - Grau de Participacao
								"",;														//30 - Hora Inicio
								"",;                                           				//31 - Hora Fim
								"",;                                           				//32 - Via
								"",;                                           				//33 - Tec
								0,;                                           				//34 - Red Acre
								Iif( BE2->BE2_QTDSOL==0,BE2->BE2_QTDPRO,BE2->BE2_QTDSOL )*BE2->BE2_VLRAPR} )//35 - Valor apr total

							//Criticas
							If lWeb
								BEG->( DbSetOrder(1) ) //BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
								If BEG->( MsSeek( xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) ) )

									While !BEG->(Eof()) .And. BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN)

										//Matriz de itens
										AaDd(aCriticas,{allTrim(BEG->BEG_SEQUEN),; //Sequencia
											allTrim(BEG->BEG_CODGLO),; //Codigo Glosa
											allTrim(BEG->BEG_DESGLO),; 	//Tabela
											allTrim(BEG->BEG_INFGLO)} )	//Procedimento

										BEG->( DbSkip() )
									EndDo

								EndIf

							EndIf

						EndIf

						BE2->( DbSkip() )
					Enddo

				EndIf

			EndIf

		EndIf

	EndIf

	lFound := Len(aItens) > 0 .and. lHaveOne

	If BEA->BEA_STALIB == "2"
		cMsg := STR0248 //Esta guia não possui procedimentos com saldo disponível
	EndIf

	//Limpo as mensagens e possiveis críticas existenes, pois queremos apenas os valores em tela, sem nenhuma validação,
	//pois somente alguns campos não críticos são passíveis de alteração.
	if cAltera == "Altcmp"
		cMsg 		:= ""
		aCriticas 	:= {}
		aCriGer		:= {}
	endIf

return( {lFound,cMsg,aCabec,aItens,aCriticas,aCriGer,BEA->(Recno()),BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) } )

/*/{Protheus.doc} PLSAUTP
Retorna dados de uma internacao
@type function
@author PLSTEAM
@since 20.04.00
@version 1.0
/*/
Function PLSDADINT(cNumAut,lCab,TipoAut, cTipo)
	LOCAL nQtdUs	 := 0
	LOCAL nVlrCon	 := 0
	LOCAL nVlrTPF	 := 0
	LOCAL lFound   	 := .F.
	LOCAL cCarSaud	 := ""
	LOCAL cNomPla	 := ""
	LOCAL cMsg	   	 := ""
	LOCAL cOpeSol	 := ""
	LOCAL cProSol	 := ""
	LOCAL cNomeSol 	 := ""
	LOCAL cCodSigSol := ""
	LOCAL cNumCrSol  := ""
	LOCAL cEstSigSol := ""
	LOCAL cOpeExe	 := ""
	LOCAL cProExe	 := ""
	LOCAL cNomeExe 	 := ""
	LOCAL cCodSigExe := ""
	LOCAL cNumCrExe  := ""
	LOCAL cEstSigExe := ""
	LOCAL cBEJValid  := "1"
	LOCAL cCGCSolT	 := ""
	LOCAL cNomeSolT	 := ""
	LOCAL cCnesSolT	 := ""
	LOCAL cRdaSolT	 := ""
	LOCAL cProfSolT  := ""
	LOCAL cOpeSolT   := ""
	LOCAL cDesStaAut := ""
	LOCAL dDtVldCar	 := CToD("")
	LOCAL aRetBox	 := {}
	LOCAL aRetExec   := {}
	LOCAL aCabec   	 := {}
	LOCAL aItens   	 := {}
	LOCAL aCriticas	 := {}
	local nRet			:= 0
	local nNumero		:= 0
	local cNumCor		:= ""

	DEFAULT cNumAut    	:= ""
	DEFAULT lCab		:= .F.
	DEFAULT TipoAut		:= 'L'
	DEFAULT cTipo 		:= "3"

	//Função para verificar a guia de internação e prorrogação, para identificar os procedimentos lançados e qual o de maior porte,
	//para carregar e deixar colocar apenas a quantidade
	if ( cTipo == "6" .or. cTipo == "3" )
		cNumCor := iif(Len(cNumAut) > 22, Substr(cNumAut, 1,18), cNumAut)
		nNumero := PlsVrIntPro(cNumCor)
	endif

	//Posiciona no cabecalho
	BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
	If BE4->( MsSeek(xFilial("BE4")+cNumAut) )

		//Posiciona no bea referente
		BEA->( DbSetOrder(6) )//BEA_FILIAL + BEA_OPEINT + BEA_ANOINT + BEA_MESINT + BEA_NUMINT + DTOS(BEA_DATPRO) + BEA_HORPRO
		BEA->( MsSeek( xFilial("BEA")+BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT) ) )

		//Verifica se ainda existe registro sem participacao
		cCGCSolT := BE4->BE4_CGCRDA

		If !Empty(cCGCSolT)

			BAU->( DbSetOrder(4) )//BAU_FILIAL + BAU_CPFCGC

			If !BAU->( MsSeek(xFilial("BAU")+cCGCSolT) )
				cMsg := STR0080+STR0139+cCGCSolT+"]" //"Rda nao encontrada ->"
			Else
				//Dados do solicitado = executante

				cRdaSolT  := BAU->BAU_CODIGO
				cCGCSolT  := BAU->BAU_CPFCGC
				cNomeSolT := BAU->BAU_NREDUZ

				if cTipo <> '6'
					cCnesSolT := BAU->BAU_CNES
				else
					BB8->( DbSetOrder(1) )
					BB8->( MsSeek( xFilial("BB8")+BAU->BAU_CODIGO+BE4->BE4_CODOPE+BE4->BE4_CODLOC ) )

					cCnesSolT := BB8->BB8_CNES
				endIf

				cProfSolT := BAU->BAU_CODBB0
				cOpeSolT  := Iif(Empty(BAU->BAU_CODOPE),PlsIntPad(),BAU->BAU_CODOPE)
			EndIf
		EndIf

		BAU->( DbSetOrder(1) )//BAU_FILIAL + BAU_CODIGO
		BB0->( DbSetOrder(1) )//BB0_FILIAL + BB0_CODIGO

		//Posiciona na rda
		If !BAU->( MsSeek(xFilial("BAU")+BE4->BE4_CODRDA) )
			cMsg := STR0080+BE4->BE4_CODRDA //"Rda nao encontrada ->"
		Else

			//Solicitante
			If !BB0->( MsSeek(xFilial("BB0")+Iif(!Empty(BE4->BE4_CDPFSO),BE4->BE4_CDPFSO,BAU->BAU_CODBB0)) )
				cMsg := STR0081+" ->"+BE4->BE4_CDPFSO //"Solicitante nao encontrado"
			Else
				cOpeSol	 := BB0->BB0_CODOPE
				cProSol    := BB0->BB0_CODIGO
				cNomeSol 	 := BB0->BB0_NOME
				cCodSigSol := BB0->BB0_CODSIG
				cNumCrSol  := BB0->BB0_NUMCR
				cEstSigSol := BB0->BB0_ESTADO
			EndIf

			//Executante
			If BB0->( MsSeek(xFilial("BB0")+BE4->BE4_CDPFRE) )
				cOpeExe	 := BB0->BB0_CODOPE
				cProExe    := BB0->BB0_CODIGO
				cNomeExe 	 := BB0->BB0_NOME
				cCodSigExe := BB0->BB0_CODSIG
				cNumCrExe  := BB0->BB0_NUMCR
				cEstSigExe := BB0->BB0_ESTADO
			EndIf

			//Informacao da solicitacao
			BAQ->( DbSetOrder(1) )
			BAQ->( MsSeek( xFilial("BAQ")+BE4->(BE4_CODOPE+BE4_CODESP) ) )

			BB8->( DbSetOrder(1) )
			BB8->( MsSeek( xFilial("BB8")+BE4->(BE4_CODRDA+BE4_CODOPE+BE4_CODLOC) ) )
		EndIf

		//Status da guia
		aRetBox := RetSx3Box(  Posicione('SX3',2,"BE4_STATUS",'X3_CBOX') ,,,Val(BE4->BE4_STATUS) )

		If (nPos := AsCan( aRetBox , {|x| AllTrim(x[2]) == BE4->BE4_STATUS} ))>0
			cDesStaAut:= aRetBox[nPos,3]
		EndIf

		//Plano do usuario
		BA3->( DbSetOrder(1) ) //BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
		If BA3->( MsSeek( xFilial("BA3")+BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC) ) )

			BI3->( DbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO;
			BI3->( MsSeek( xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA) ) )

			cNomPla := BI3->BI3_NREDUZ

		EndIf

		//Validade da Carteirinha
		BA1->( DbSetOrder(2) )//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
		If BA1->( MsSeek( xFilial("BA1")+BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO) ) )

			dDtVldCar := BA1->BA1_DTVLCR

			//Validade da Carteirinha
			BTS->( DbSetOrder(1) ) //BTS_FILIAL + BTS_MATVID
			If BTS->( MsSeek(xFilial("BTS")+BA1->BA1_MATVID) ) .And. BTS->(FieldPos("BTS_NRCRNA")) > 0
				cCarSaud :=  BTS->BTS_NRCRNA
			EndIf

		EndIf

		//Se ja existe evolucao
		lFindEvo := BQV->( MsSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)) )

		//cabecalho
		If Empty(cMsg)

			aCabec := {BE4->BE4_CODRDA,;															 //1-cRda
				Posicione("BA0",1,xFilial("BA0")+BE4->BE4_CODOPE,"BA0_SUSEP"),; 			 //2-cRegAns
				BAU->BAU_NOME,;   															 //3-cNomeRda
				BAU->BAU_CPFCGC,;   														 //4-cCnpfCpfSol
				BB8->BB8_CNES,;   															 //5-cCnesSol
				IiF(BB8->(FieldPos("BB8_TIPLOG"))>0,AllTrim(BB8->BB8_TIPLOG),""),;		 //6-Tipo de Logradouro
				AllTrim(BB8->BB8_END),;   													 //7-Endereco
				IiF(BB8->(FieldPos("BB8_NR_END"))>0,AllTrim(BB8->BB8_NR_END),""),;		 //8-Numero
				IiF(BB8->(FieldPos("BB8_COMEND"))>0,AllTrim(BB8->BB8_COMEND),""),;		 //9-Complemento
				Posicione("BID",1,xFilial("BID")+BB8->BB8_CODMUN,"BID_DESCRI") ,;			 //10-Municipio
				BB8->BB8_BAIRRO,;   														 //11-Bairro
				BB8->BB8_EST,;   															 //12-Estado
				BB8->BB8_CODMUN,;   														 //13-IBGE
				BB8->BB8_CEP,;   															 //14-Cep
				BB8->BB8_TEL,;   															 //15-Tel
				BE4->BE4_DTDIGI,;															 //16-dDtAut
				Iif(!Empty(BE4->BE4_HORPRO),Left(BE4->BE4_HORPRO,2)+":"+Right(Alltrim(BE4->BE4_HORPRO),2),Left(Time(),5)),;//17-cHorAut
				BE4->BE4_SENHA,;  	   														 //18-cSenha
				BEA->BEA_VALSEN,;															 //19-dDtValid
				BEA->BEA_DATSOL,;															 //20-dDtSolicit
				Iif(!Empty(BEA->BEA_HORSOL),Left(BEA->BEA_HORSOL,2)+":"+Right(BEA->BEA_HORSOL,2),''),;//21-cHrSolicit
				Iif(AllTrim(BE4->BE4_TIPADM) $ GetNewPar("MV_PLSCDIU","4,5"),"U","E"),;	 //22-cCarSolicit
				BE4->BE4_CID,;																 //23-cCid
				cProSol,; 	   																 //24-cProSol
				cOpeSol,; 		   															 //25-Operadora solicitante
				cNomeSol,; 		   														 //26-cNomeSol
				cCodSigSol,;  		   														 //27-cCodSigSol
				cNumCrSol,; 		   														 //28-cNumCrSol
				cEstSigSol,; 		   														 //29-cEstSigSol
				BE4->BE4_CODESP+BAQ->BAQ_CBOS,;											 //30-cCbosSol ESPECIALIDADE
				AllTrim(BAQ->BAQ_DESCBO),;													 //31-Descricao da ESPECIALIDADE
				cProExe,; 	   																 //32-cProExe
				cOpeExe,; 		   															 //33-Operadora Executante
				cNomeExe,; 		   														 //34-cNomeExe
				cCodSigExe,;  		   														 //35-cCodSigExe
				cNumCrExe,; 		   														 //36-cNumCrExe
				cEstSigExe,; 		   														 //37-cEstSigExe
				SubStr(AllTrim(BE4->BE4_MSG01)+alltrim(BE4->BE4_MSG02),1,253),;			 //38-Observacao
				AllTrim(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)),;  //39-Matricula
				BE4->BE4_NOMUSR,;                                                 			 //40-Nome do usuario
				BE4->BE4_STATUS,;  										            	 //41-Status da autorizacao
				BE4->(BE4_INDCLI+BE4_INDCL2),;												 //42-Indicacao de Cliente
				BEA->BEA_ORIGEM,;															 //43-Se e uma liberacao ou
				BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO),;	 					//44-Chave BD6 Indice 6
				BEA->BEA_TIPATO,;															 //45-Tipo atendimento odontologico
				BE4->BE4_TIPFAT,;															 //46-Tipo de faturamento
				BE4->BE4_NUMIMP,;															 //47-Numero Impresso
				BE4->BE4_TIPINT,;															 //48-Tipo de Internacao
				BE4->BE4_REGINT,;															 //49-Regime da Internacao
				BE4->BE4_DIASSO,;															 //50-Qtd Diarias Solicitadas
				BE4->BE4_TIPDOE,;															 //51-Tipo de Doenca
				AllTrim(Str(BE4->BE4_TPODOE)),;											 //52-Tempo Doenca
				BE4->BE4_UTPDOE,;															 //53-Unidade Doenca
				BE4->BE4_INDACI,;															 //54-Indicacao de Acidente
				BE4->BE4_CIDSEC,;															 //55-Cid2
				BE4->BE4_CID3,;															 //56-Cid3
				BE4->BE4_CID4,;															 //57-Cid4
				BE4->BE4_PRVINT,;															 //58-Data Prev Adm Hosp
				BE4->BE4_DIASIN,;															 //59-Diarias Autorizadas
				BE4->BE4_PADINT,;											 				 //60-Tipo de Acomodacao
				BE4->BE4_PADCON,;															 //61-Padrao de Conforto
				cCGCSolT,;																	 //62-Cgc Rda Solicitada
				cNomeSolT,;																 //63-Nome Rda Solicitada
				Iif(Empty(cCnesSolT),BB8->BB8_CNES,cCnesSolT),;					 		 //64-Cnes Rda Solicitada
				AllTrim( Posicione("BI4",1,xFilial("BI4")+BE4->BE4_PADINT,"BI4_DESCRI") ),;//65-Descricao de Tipo de Acomodacao
				cRdaSolt,;																	 //66-Codigo Rda Solicitada
				cProfSolT,;																 //67-Codigo do Profissional
				cOpeSolT,;																	 //68-Operadora do Profissinal
				Iif(!Empty(BE4->BE4_DATPRO),BE4->BE4_DATPRO,Iif(TipoAut=="A" .And. !lCab,ctod(' '),Date())),;//69-Data da Internacao
				BE4->BE4_DTALTA,;															 //70-Data da Alta
				Iif(!Empty(BE4->BE4_HRALTA),Left(BE4->BE4_HRALTA,2)+":"+Right(BE4->BE4_HRALTA,2),''),;//71-Hora da Alta
				Iif(BE4->BE4_CANCEL=="1","SIM","NÃO"),;									 //72-Cancelada
				cDesStaAut,;																 //73-Descricao do Status Guia
				Iif(lFindEvo,'1','0'),;                                        			 //74-Ja existe evolucao
				cNomPla,;																	 //75-Plano
				dDtVldCar,;														 		 //76-Validade da carteirinha
				cCarSaud,;																	 //77-Carteira nacional de saude
				BE4->BE4_CODOPE,;															 //78-Operadora
				"",;															 			 //79-Operadora
				BE4->BE4_DIASPR,;															 //80-Qtd dia prorrogada
				AllTrim( BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO) ),;//81-Matricula
				'',;//82
				'',;//83
				'',;//84
				'',;//85
				'',;//86
				cTod(''),;//87
				cTod(''),;//88
				Iif(BE4->(FieldPos('BE4_PREOPE'))>0,BE4->BE4_PREOPE,''),;//89-Previsao OPME
				Iif(BE4->(FieldPos('BE4_PREQUI'))>0,BE4->BE4_PREQUI,''),;//90-Previsao Quimio
				Iif(BE4->(FieldPos('BE4_ATERNA'))>0,BE4->BE4_ATERNA,''),;//91-Atend RN?
				BE4->BE4_TIPADM,;//92-Tipo de Admissao
				BE4->BE4_GRPINT,;//93-Grupo Internacao
				BAU->BAU_GRALAU,;//94-CodLoc
				BE4->BE4_CODLOC,;//95-CodLoc
				BE4->BE4_TIPALT,;//96-CodLoc
				iif( BA1->( fieldPos("BA1_NOMSOC")) > 0, BA1->BA1_NOMSOC, "") }//97 - nome social beneficiário 

			//Se carrega somente o cabecalho ou cab e item
			If !lCab

				//Itens
				BR8->( DbSetOrder(1) )//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
				BEJ->( DbSetOrder(1) )//BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN

				If BEJ->( MsSeek(xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)) )

					While ! BEJ->( Eof() ) .And. BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

						//Br8
						BR8->(MsSeek(xFilial("BR8")+BEJ->(BEJ_CODPAD+BEJ_CODPRO)))

						//Itens
						AaDd(aItens,{	If(BR8->BR8_TPPROC=="5","O","S"),;							//1  - Tipo de Servico (Servico ou OPM)
							BEJ->BEJ_SEQUEN,; 				   							//2  - Sequencia
							BEJ->BEJ_CODPAD,; 				   							//3  - Tabela
							AllTrim(BEJ->BEJ_CODPRO),;   	   							//4  - Procedimento
							AllTrim(BR8->BR8_DESCRI),; 									//5  - Descricao
							AllTrim(Str(Iif(BEJ->BEJ_QTDSOL==0,BEJ->BEJ_QTDPRO,BEJ->BEJ_QTDSOL))),;//6 - Qtd Solicitada
							Iif( BEJ->BEJ_STATUS == '1',AllTrim(Str(BEJ->BEJ_QTDPRO)),'0'),;	//7  - Qtd Autorizada
							IIf(BR8->(FieldPos("BR8_FABRIC"))>0,BR8->BR8_FABRIC,""),; 	//8  - Fabricante...
							0,;								   							//9  - Vlr Unitario
							cBEJValid,;                                                 //10 - Podera ser exibido sim ou nao
							"",;														//
							BEJ->(Recno()),;											//12 - Recno
							AllTrim(Str(Iif(BEJ->BEJ_QTDSOL==0,BEJ->BEJ_QTDPRO,BEJ->BEJ_QTDSOL))),;//13 - Saldo
							aRetExec,;													//14 - Matriz de tratamento do executante
							BEJ->BEJ_NIVAUT,;											//15 - Nivel da Autorizacao
							BEJ->BEJ_NIVCRI,;											//16 - Nivel da Critica
							BEJ->BEJ_CHVNIV,;                                        	//17 - Chave do Nivel
							"",;   														//18 -
							"",;   														//19 -
							nQtdUs,; 		                                       		//20 - Valor Us
							nVlrCon,; 													//21 - Valor Contratado
							nVlrTPF,;                                        			//22 - Valor Participacao
							Iif(BEJ->BEJ_STATUS=='1','S','N'),; 						//23 - Autorizado sim ou nao
							"",;    													//24 -
							"",;                                                        //25 -
							date(),; 						   							//26 - Data Execucao
							"",;														//27 - Senha
							"",;														//28 - Res. Autorizacao
							"",;														//29 - Grau de Participacao
							"",;														//30 - Hora Inicio
							"",;                                           				//31 - Hora Fim
							"",;                                           				//32 - Via
							"",;                                           				//33 - Tec
							0,;                                           				//34 - Red Acre
							0} )														//35 - Valor apr total

						//Criticas
						BEL->( DbSetOrder(1) ) //BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN + BEL_CODGLO
						If BEL->( MsSeek( xFilial("BEL")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ) )

							While !BEL->(Eof()) .And. BEL->(BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN) == BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN)

								//Matriz de itens
								AaDd(aCriticas,{	allTrim(BEL->BEL_SEQUEN),; //Sequencia
									allTrim(BEL->BEL_CODGLO),; //Codigo Glosa
									allTrim(BEL->BEL_DESGLO),; 	//Tabela
									allTrim(BEL->BEL_INFGLO)} )	//Procedimento
								BEL->( DbSkip() )
							Enddo

						EndIf

						BEJ->( DbSkip() )
					EndDo

				EndIf

				//Itens da prorrogacao
				BQV->( DbSetOrder(1) )//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
				If BQV->( MsSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)) )

					While ! BQV->( Eof() ) .And. BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

						BR8->(MsSeek(xFilial("BR8")+BQV->(BQV_CODPAD+BQV_CODPRO)))

						AaDd(aItens,{	iIf(BR8->BR8_TPPROC=="5","PO","PS"),;						//1  - Tipo de Servico (Servico ou OPM)
							BQV->BQV_SEQUEN,; 				   							//2  - Sequencia
							BQV->BQV_CODPAD,; 				   							//3  - Tabela
							AllTrim(BQV->BQV_CODPRO),;   	   							//4  - Procedimento
							AllTrim(BQV->BQV_DESPRO),; 									//5  - Descricao
							AllTrim(Str(Iif(BQV->BQV_QTDSOL==0,BQV->BQV_QTDPRO,BQV->BQV_QTDSOL))),;//6 - Qtd Solicitada
							Iif( BQV->BQV_STATUS == '1',AllTrim(Str(BQV->BQV_QTDPRO)),'0'),;	//7  - Qtd Autorizada
							IIf(BR8->(FieldPos("BR8_FABRIC"))>0,BR8->BR8_FABRIC,""),; 	//8  - Fabricante...
							0,;								   							//9  - Vlr Unitario
							"1",;		                                                 //10 - podera ser exibido sim ou nao
							"",;														//
							BQV->(Recno()),;											//12 - Recno
							AllTrim(Str(Iif(BQV->BQV_QTDSOL==0,BQV->BQV_QTDPRO,BQV->BQV_QTDSOL))),;//13 - Saldo
							aRetExec,;													//14 - Matriz de tratamento do executante
							BQV->BQV_NIVAUT,;											//15 - Nivel da Autorizacao
							BQV->BQV_NIVCRI,;											//16 - Nivel da Critica
							BQV->BQV_CHVNIV,;                                        	//17 - Chave do Nivel
							"",;   														//18 -
							"",;   														//19 -
							nQtdUs,; 		                                       		//20 - Valor Us
							nVlrCon,; 													//21 - Valor Contratado
							nVlrTPF,;                                        			//22 - Valor Participacao
							Iif(BQV->BQV_STATUS=='1','S','N'),; 						//23 - Autorizado Sim ou Nao
							"",;    													//24 -
							"",;                                                        //25 -
							BQV->BQV_DATPRO,; 						   					//26 - Data Execucao
							AllTrim(BQV->BQV_SENHA),;									//27 - Senha
							AllTrim(BQV->BQV_RESAUT),;									//28 - Res. Autorizacao
							"",;														//29 - Grau de Participacao
							"",;														//30 - Hora Inicio
							"",;                                           				//31 - Hora Fim
							"",;                                           				//32 - Via
							"",;                                           				//33 - Tec
							0,;                                           				//34 - Red Acre
							0,;																	//35 - Valor apr total
							BQV->BQV_DIAGNO} )											 	//36 - Diagnostico

						//Criticas																	   ³
						BQZ->( DbSetOrder(1) ) //BQZ_FILIAL + BQZ_CODOPE + BQZ_ANOINT + BQZ_MESINT + BQZ_NUMINT + BQZ_SEQUEN
						If BQZ->( MsSeek( xFilial("BQZ")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN) ) )

							While !BQZ->( Eof() ) .And. BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN) == BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN)

								AaDd(aCriticas,{allTrim(BQZ->BQZ_SEQUEN),; //Sequencia
									allTrim(BQZ->BQZ_CODGLO),; //Codigo Glosa
									allTrim(BQZ->BQZ_DESGLO),; 	//Tabela
									allTrim(BQZ->BQZ_INFGLO)} )	//Procedimento

								BQZ->( DbSkip() )
							EndDo

						EndIf

						BQV->( DbSkip() )
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf

	lFound := Len(aItens) > 0

Return( {lFound,cMsg,aCabec,aItens,aCriticas,{},nNumero} )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSRetEPro³ Autor ³ Tulio Cesar       Data ³ 15.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna estrutura de um procedimento                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSRetEPro(cCodPad,cCodPro,cCodRda,dData,cCodLoc,cTipPre)
	LOCAL aVetTab
	LOCAL cCodTab
	LOCAL aComEve := {}
	LOCAL aRet    := {}
	LOCAL aComp	  := {}
	LOCAL nFor
	LOCAL nPos

	AaDD(aComp,{"HM",STR0110}) 		//"Medico"
	AaDD(aComp,{"HMR",STR0110})	 	//"Medico"
	AaDD(aComp,{"PPM",STR0110}) 	//"Medico"
	AaDD(aComp,{"PA",STR0111}) 		//"Anestesista"
	AaDD(aComp,{"PAP",STR0111})		//"Anestesista"
	AaDD(aComp,{"PAR",STR0111})		//"Anestesista"
	AaDD(aComp,{"AUR",STR0112})		//"Auxiliar1"
	AaDD(aComp,{"AUX",STR0113})		//"Auxiliar2"
	AaDD(aComp,{"CIR",STR0114})		//"Cirurgiao"

	aVetTab := PLSRETTAB(cCodPad,cCodPro,dData,PLSINTPAD(),cCodRDA,"","",cCodLoc,dData,"1",nil,nil,nil,"2",nil,cTipPre)
	If aVetTab[1]
		cCodTab := aVetTab[3]

		aRet := {BR8->BR8_DESCRI,{}}

		aComEve := PLSCOMEVE(cCodTab,cCodPad,cCodPro,PLSINTPAD(),dData,"02",nil,.F.,cCodRDA,"","",cCodLoc,'1')
		For nFor := 1 To Len(aComEve)
			nPos := aScan(aComp,{|x| x[1] == aComEve[nFor,1]} )
			If nPos > 0
				AaDd(aRet[2],{ aComEve[nFor,1],aComp[nPos,2] } )
			EndIf
		Next
	EndIf

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSRetEPac³ Autor ³ Tulio Cesar       Data ³ 15.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna a estrutura de um pacote                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSRetEPac(cCodPad,cCodPro,cCodRda,dData,cCodLoc,cTipPre)
	LOCAL aRet 		:= {}
	LOCAL bQtd 		:= { || If(BLE->(FieldPos("BLE_QTD"))>0,BLE->BLE_QTD,1) }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//oRDER																		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BLD->(DbSetOrder(1))
	If BLD->(DbSeek(xFilial("BLD")+PLSINTPAD()))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//While																	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While ! BLD->(Eof()) .And. BLD->(BLD_FILIAL+BLD_CODINT) == xFilial("BLD")+PLSINTPAD()
			BLE->(DbSetOrder(1))
			If BLE->(DbSeek(xFilial("BLE")+BLD->(BLD_CODINT+BLD_CODPAD+BLD_CODPRO+BLD_CODPAC)))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Matriz principal
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AaDd(aRet,{ BLD->BLD_CODPAC,BLD->BLD_DESCRI , {} } )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Procedimentos																³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While ! BLE->(Eof()) .And. BLE->(BLE_FILIAL+BLE_CODINT+BLE_CODPAD+BLE_CODPRO+BLE_CODPAC) == ;
						xFilial("BLE")+BLD->(BLD_CODINT+BLD_CODPAD+BLD_CODPRO+BLD_CODPAC)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Procedimentos																  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AaDd(aRet[Len(aRet),3],{BLE->BLE_CODPAD,BLE->BLE_CODOPC,;
						BR8->(Posicione("BR8",1,xFilial("BR8")+BLE->(BLE_CODPAD+BLE_CODOPC),"BR8_DESCRI")),;
						Eval(bQtd)} )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Skip																		³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BLE->(DbSkip())
				Enddo
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Skip																		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BLD->(DbSkip())
		Enddo
	Endif

Return(aRet)

/*//-------------------------------------------------------------------
{Protheus.doc} PLSWREQ
Gravacao de requisitante.
@since    10/2020.				@author: Alexander.
//-------------------------------------------------------------------*/
Function PLSWREQ(cNome,cSigla,cNumero,cEstado)
lOCAL aRet 			:= {}
local aRetGrv		:= {}
local bBlocCdOri	:= {}

BB0->( DbSetOrder(2) )

If BB0->( MsSeek(xFilial("BB0")+cNome) )
	aAdD(aRet,{ BB0->BB0_CODOPE,BB0->BB0_CODIGO,Modulo11( BB0->(BB0_CODOPE+BB0_CODIGO) ) , {} } )
	aAdD(aRet[1,4], {"900",STR0083} ) //"Ja existe um requisitante com este nome"
Else
	//Inclusao.
	bBlocCdOri := {|| FwFldGet("BB0_CODOPE") + FwFldGet("BB0_CODIGO") + Modulo11( FwFldGet("BB0_CODOPE") + FwFldGet("BB0_NUMCR") ) }
	aRetGrv := PlSveProfAll(cNome, cSigla, cEstado, cNumero, PlsIntPaD(), '', '2', bBlocCdOri, {})

	aAdD(aRet,{ BB0->BB0_CODOPE, BB0->BB0_CODIGO, Modulo11( BB0->(BB0_CODOPE+BB0_NUMCR) ) , {} } )
EndIf

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSRtGAtd ³ Autor ³ Tulio Cesar                                           Data ³ 19.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna a partir de uma rda as guias que ele deve prestar atendimento a consulta ja autorizada ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSRtGAtd(cCodRda,dDataAtd)
	LOCAL cSQL := ""
	LOCAL aDados := {}
	LOCAL cCodOld
	LOCAL cOpeSol
	LOCAL cNumSol
	LOCAL cDigSol
	DEFAULT dDataAtd := dDataBase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Query																		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT "
	cSQL += "BEA_CODRDA , BEA_MATANT, BEA_OPEUSR, BEA_CODEMP, BEA_MATRIC, BEA_TIPREG, BEA_DIGITO, BEA_CODLOC, BEA_TIPPRE ,BEA_NOMUSR, BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT "
	cSQL += "FROM "+BEA->(RetSqlName("BEA"))+"  "
	cSQL += "WHERE "
	cSQL += "BEA_FILIAL = '"+xFilial("BEA")+"' AND "
	cSQL += "BEA_DATPRO >= '"+dtos(dDataAtd)+"' AND BEA_DATPRO <= '"+dtos(dDataAtd)+"' AND "
	cSQL += "BEA_CODRDA = '"+cCodRda+"' AND "
	cSQL += "BEA_TIPGUI = '"+GetNewPar("MV_PLSTPGC","01")+"' AND "
	cSQL += "BEA_CID = '"+Space(Len(BEA->BEA_CID))+"' AND "

	cSQL += "D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY BEA_FILIAL , BEA_DATPRO , BEA_HORPRO , BEA_OPEMOV , BEA_ANOAUT , BEA_MESAUT , BEA_NUMAUT "
	PLSQuery(cSQL,"TrbGuiAtd")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Ordem																		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAU->(DbSetOrder(1))
	BB0->(DbSetOrder(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//While monta matriz															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! TrbGuiAtd->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Posiciona na rda															  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TrbGuiAtd->BEA_CODRDA <> cCodOld
			cCodOld := TrbGuiAtd->BEA_CODRDA
			BAU->(MsSeek(xFilial("BAU")+cCodOld))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Pega o codori																 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BB0->(MsSeek(xFilial("BB0")+BAU->BAU_CODBB0))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Solicitante																 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cOpeSol := SubStr(BB0->BB0_CODORI,1,4)
			cNumSol := SubStr(BB0->BB0_CODORI,5,Len(AllTrim(BB0->BB0_CODORI))-5)
			cDigSol := SubStr(BB0->BB0_CODORI,Len(AllTrim(BB0->BB0_CODORI)),1)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//monta matriz																  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TrbGuiAtd->BEA_CODEMP<>GetNewPar("MV_PLSGEIN","0050")
			cOpeUsr := TrbGuiAtd->BEA_OPEUSR
			cCodEmp := TrbGuiAtd->BEA_CODEMP
			cMatric := TrbGuiAtd->BEA_MATRIC
			cTipReg := TrbGuiAtd->BEA_TIPREG
		Else
			cOpeUsr := Subs(TrbGuiAtd->BEA_MATANT,atCodOpe[1],atCodOpe[2])
			cCodEmp := Subs(TrbGuiAtd->BEA_MATANT,atCodEmp[1],atCodEmp[2])
			cMatric := Subs(TrbGuiAtd->BEA_MATANT,atMatric[1],atMatric[2])
			cTipReg := Subs(TrbGuiAtd->BEA_MATANT,atTipReg[1],atTipReg[2])
		Endif

		aadd(aDados,{cOpeUsr,;
			cCodEmp,;
			cMatric,;
			cTipReg,;
			TrbGuiAtd->BEA_NOMUSR,;
			TrbGuiAtd->BEA_OPEMOV,;
			TrbGuiAtd->BEA_ANOAUT,;
			TrbGuiAtd->BEA_MESAUT,;
			TrbGuiAtd->BEA_NUMAUT,;
			TrbGuiAtd->BEA_CODRDA,;
			TrbGuiAtd->BEA_DIGITO,;
			TrbGuiAtd->BEA_CODLOC,;
			TrbGuiAtd->BEA_TIPPRE,;
			cOpeSol,;
			cNumSol,;
			cDigSol,;
			Iif(TrbGuiAtd->BEA_CODEMP==GetNewPar("MV_PLSGEIN","0050"),'Sim','Nao')})
		TrbGuiAtd->(DbSkip())
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Fecha area																	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TrbGuiAtd->(DbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Fim da Rotina																³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aDados)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSHISTLOG³ Autor ³ Alexander            Data ³ 19.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna historio de acesso de um usuario web				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSHISTLOG(cCodLog,cDataDe,cDataAte,cHoraDe,cHoraAte)
	LOCAL aRet := {}
	DEFAULT cCodLog := ""
	DEFAULT cDataDe := ""
	DEFAULT cDataAte := ""
	DEFAULT cHoraDe := ""
	DEFAULT cHoraAte := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Select																		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT * "
	cSQL += " FROM " + RetSQLName("BX1")
	cSQL += " WHERE BX1_FILIAL = '" + xFilial("BX1") +"' "
	cSQL += "   AND BX1_USUARI = '" + cCodLog +"' "
	cSQL += "   AND BX1_DATA BETWEEN '" + DTOS(CTOD(cDataDe)) + "' AND '"+ DTOS(CTOD(cDataAte)) +"' "
	cSQL += "   AND SUBSTRING(BX1_HORA,1,5) BETWEEN '" + cHoraDe + "' AND '"+ cHoraAte +"' "
	cSQL += "   AND D_E_L_E_T_ <> '*'"
	PLSQuery(cSQL,"Trb")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Alimenta a matriz															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !Trb->(Eof())
		AaDd(aRet,{Trb->BX1_DATA,Trb->BX1_HORA,Iif(AllTrim(Trb->BX1_ESTTRB)=='THIS','MAQUINA LOCAL',Trb->BX1_ESTTRB)} )
		Trb->(DbSkip())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Fecha a area de trabalho													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Trb->(DbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Fim da Rotina																³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao PLSPORSEN  ³ Autor ³Alexander	 		³ Data ³ 08.02.07 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Senha de acesso ao portal								  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPORSEN(oObj,cCampo,lSempre, lGatilho)
	LOCAL oFont
	LOCAL oDlg
	LOCAL nLinha
	LOCAL cSenha 	 := Space(12)
	LOCAL cSenConf 	 := Space(12)
	LOCAL nOpca		 := 0
	LOCAL cCripto	 := ""
	LOCAL dDataB		:= DATE()
	DEFAULT lSempre  := .F.
	DEFAULT lGatilho := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Se gatilho, executar apenas quando chamado da rotina Rede de Atendimento	³
	//Se deve porque a rotina chama o AxCadastro pela pesquisa padrao (Incluir)	³
	//Nas demais rotinas, a função PLSPORSEN eh chamada pelo botao OK				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGatilho .AND. !IsInCallStack("PLSA360") .AND. cCampo == 'BSW_SENHA'
		Return(.T.)
	EndIf


	//Define fontes utilizadas somente nesta funcao...

	DEFINE FONT oFont NAME "Arial" SIZE 000,-012 BOLD

	//Cria Dialog...

	DEFINE MSDIALOG oDlg TITLE STR0084 FROM 008.2,003.3 TO 016,055 OF GetWndDefault() //"Senha de Acesso"

	@ 05,10 Say oSay PROMPT STR0085 SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Senha"
	@ 18,10 MSGET oGet1 VAR cSenha SIZE 070,10 OF oDlg FONT oFont PIXEL PASSWORD

	@ 05,110 Say oSay PROMPT STR0086 SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE //"Confirmar Senha"
	@ 18,110 MSGET oGet2 VAR cSenConf SIZE 070,10 OF oDlg FONT oFont PIXEL PASSWORD

	//Botoes																	 ³

	TButton():New(38,020,'Confirmar',,{||Iif(PLSVALSE(cSenha,cSenConf),Eval({||nOpca:=1,oDlg:End()}),.F.)},040,012,,,,.T.)
	TButton():New(38,140,'Fechar'   ,,{||Iif(PLSVALSE(cSenha,cSenConf),Eval({||nOpca:=2,oDlg:End()}), IiF(lSempre, Eval({||Iif( PLSVALSE(cSenha,cSenConf),Eval({||nOpca:=2,oDlg:End()}),.F.)}),Eval({||nOpca:=2,oDlg:End()}) ) )},040,012,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

	//Verifica e criptografa													 ³

	If nOpca == 1
		cCripto := PLSCRIDEC(1,AllTrim(cSenha))
		If Type("oObj") <> 'U'
			oObj:aCols[oObj:Linha(),oObj:PlRetPos(cCampo)] := cCripto
		EndIf
		If Type("M->"+cCampo) == "C"
			&("M->"+cCampo) := cCripto
		Else
			RecLock('BSW')
			BSW_SENHA := cCripto
			BSW_DTSEN := dDataB
			MsUnlock()
		EndIf

		If BSW->(FieldPos("BSW_DTSEN")) > 0 .And. Type("M->BSW_DTSEN") == "D"
			&("M->BSW_DTSEN") := dDataB
		EndIf
		If Type("oObj") <> 'U'
			nLinha := oObj:Linha()
			oObj:Atualiza()
			oObj:SetPos(nLinha)
		EndIf

		//Ponto de Entrada para enviar a senha aberta
		If ExistBlock("PL226SEN") // Ponto de entrada
			ExecBlock("PL226SEN", .F., .F.,{cSenha})
		EndIf

	ElseIf nOpca == 0 .And. lSempre
		PLSPORSEN(oObj,cCampo,lSempre)
	EndIf

	//Fim da rotina															 ³

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao PLSVALSE   ³ Autor ³Luciano Aparecido	³ Data ³ 27.08.14 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Validação Senha Portal									  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSVALSE(cSenha,cSenConf)
	Local lRet       := .T.
	Local nX         := 0
	Default cSenha 	 := ""
	Default cSenConf := ""

	If Empty(cSenha)
		MsgAlert('Senha em branco')
		lRet := .F.
	Else
		// Verifica Tamanho minimo Senha
		If Len(Alltrim(cSenha)) < 8
			lRet:= .F.
		Endif
		// Verifica se existe pelo menos 1 digito
		If lRet
			lRet:= .F.
			FOR nX := 1 TO Len(Alltrim(cSenha))
				IF ISDIGIT((SUBSTR(Alltrim(cSenha),nX,1))) .Or.;
						!LETTERORNUM(SUBSTR(Alltrim(cSenha),nX,1))
					lRet := .T.
					Exit
				ENDIF
			NEXT nX
		Endif
		If !lRet
			MsgAlert('Por segurança a senha deve ter 8 caracteres, sendo pelo menos 1 caractere não-alfabético (numérico ou caractere especial)')
		ElseIf cSenConf <> cSenha
			MsgAlert('Por favor, verifique a confirmação da senha. Senha não confere!')
			lRet := .F.
		Endif
	Endif

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao PLSCRIDEC  ³ Autor ³Alexander	 		³ Data ³ 08.02.07 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Criptografa e Descriptograva senha						  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCRIDEC(nTipo,cText)
	LOCAL oObj	 := nil
	LOCAL cTexto := ""
	Local I		 := 0

	If Select("SX3") > 0

		//Criptografa em HASH
		If nTipo == 1

			//Valida se foi executado o compatibilizador UPDPLSEN
			IF (BX1->(FieldPos("BX1_CODUSR")) > 0 .AND. BX1->(FieldPos("BX1_QTACES")) > 0 .AND. BSW->(FieldPos("BSW_DTSEN")) > 0)
				cTexto:= MD5(cText)
			ELSE
				For I := 1 To Len(cText)
					cCar := SubStr(cText, I, 1)
					cTexto += AllTrim( Str( ( ( Asc(cCar)+1)*3 ) ) )
				Next
			ENDIF

			//De-Cripta
		Else
			//Ja gravado com MD5, nao necessario descriptografar
			If len(cText) == 32 .OR. !(BX1->(FieldPos("BX1_CODUSR")) > 0 .AND. BX1->(FieldPos("BX1_QTACES")) > 0 .AND. BSW->(FieldPos("BSW_DTSEN")) > 0 )
				cTexto:= cText
			Else
				// Gravado SEM Formato MD5 - Descriptografar para calculo hash
				For I := 1 To Len(cText) Step 3
					cCar := SubStr(cText, I, 3)
					cTexto += ( Chr(  ( Val(cCar)/3 )-1 ) )
				Next
				// Apos Descriptografar gera Hash
				cTexto:= MD5(cTexto)
			Endif

		EndIf

	Else

		oObj := WSPLSXFUN():New()
		IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
		WsChgURL( @oObj, "PLSXFUN.APW" )

		//Parametros
		oObj:cUserCode	:= "MSALPHA"
		oObj:cTipoVld	:= Str(nTipo)
		oObj:cSenhaVld	:= cText

		If oObj:CriPsw()
			cTexto := oObj:cCriPswResult
		EndIf

		FreeObj(oObj)

	EndIf

Return(cTexto)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSRETCRI ³Autor  ³ Alexander Santos         Data ³ 31.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Retorna a critica do tiss											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETCRI(cCod,cTissVer,lAlerBenf)
	local cCodOpe := PlsIntPad()
	local lAudt   := .F.
	local aRet    := { {"9999 ("+ cCod + ")",STR0115,lAudt} } //"Codigo De/Para nao cadastrado"
	local cCdTerm := ""
	local cDesTer := ""

	default cTissVer 	:= ""//Via parametro deve vir a versao da tiss do prestador no portal
	default lAlerBenf 	:= .F. //a critica deve ser exibida para o beneficiário no portal

	//Se vazia retorna Testa
	If Empty(cCod)
		Return aRet
	EndIf

	//Pega o codigo no BCT
	If BCT->(FieldPos("BCT_GLTISS")) > 0 .And. BCT->(FieldPos("BCT_DESTIS")) > 0

		BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO

		If BCT->( MsSeek( xFilial('BCT')+cCodOpe+cCod ) ) .Or. Empty(BCT->BCT_GLTISS)

			aRet  := {}
			lAudt := Iif(BCT->BCT_AUDITO <> "1",.F.,.T.)

			If !lAudt
				lAudt :=  ( cCod == __aCdCri051[1] .Or. cCod == __aCdCri052[1] )
			EndIf

			If (PGETTISVER() >= "3") .And. (Empty(cTissVer) .Or. cTissVer >= "3")//Se o prestador esta na tiss 2, no portal vou retornar a critica da tiss 2

				//através da tabela de De/Para(BTU) seleciona os dados da Terminologia da TISS
				cCdTerm := PLSGETVINC("BTU_CDTERM", "BCT", .F.,"38")
				cDesTer := PLSGETVINC("BTQ_DESTER", "BCT", .F.,"38")
				
				if empty(cDesTer)
					cDesTer := alltrim(BCT->BCT_DESCRI)
				endif

				If (!Empty(AllTrim(cCdTerm)))
					AaDd(aRet,{ AllTrim(cCdTerm),AllTrim(cDesTer),lAudt } )
				Else
					AaDd(aRet,{ AllTrim(BCT->BCT_GLTISS),AllTrim(BCT->BCT_DESTIS),lAudt } )//se nao tiver preenchido eu mantendo o que tinha antes, na versao 2
				EndIf
			Else
				AaDd(aRet,{ AllTrim(BCT->BCT_GLTISS),AllTrim(BCT->BCT_DESTIS),lAudt } )
			EndIf

		EndIf

	EndIf

	//Se exibe informação ao beneficiário
	if (BCT->(FieldPos("BCT_EXBENF")) > 0)

		if ( (lAlerBenf .and. BCT->BCT_EXBENF == "0") .or. (lAlerBenf .and. Empty(BCT->BCT_EXBENF)) ) //verifico se devo avaliar se deve exibir ou não ao beneficiário
			aRet := { {"9999",STR0247,lAudt} } //"A crítica não está disponível para visualização no Portal do Beneficiário. Consulte a Operadora para maiores detalhes sobre a crítica."
		endif

	endIf

return aRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSVLDOBS ³Autor  ³ Alexander Santos         Data ³ 31.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Validacao da OBS													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDOBS()
	LOCAL cTipInt := ""

	If ExistBlock("PLS500EX")
		cTipInt := ExecBlock("PLS500EX",.F.,.F.,{ M->BE4_GRPINT, M->BE4_TIPINT })
	Else
		If BQR->(FieldPos("BQR_CODEDI")) > 0
			BQR->(dbSetOrder(1))
			If BQR->(MsSeek(xFilial("BQR")+M->(BE4_GRPINT+BE4_TIPINT)))
				cTipInt := AllTrim(BQR->BQR_CODEDI)
			Else
				cTipInt := " "
			EndIf
		Else
			Do Case
				Case M->BE4_GRPINT == "1" .And. M->BE4_TIPINT == "01"
					cTipInt := "1" //Internacao Clinica
				Case M->BE4_GRPINT == "1" .And. M->BE4_TIPINT == "02"
					cTipInt := "6" //Pediatrica
				Case M->BE4_GRPINT == "1" .And. M->BE4_TIPINT == "03"
					cTipInt := "7" //Psiquiatrica
				Case M->BE4_GRPINT == "1" .And. M->BE4_TIPINT == "05"
					cTipInt := "3" //Internacao Obstetrica
				Case M->BE4_GRPINT == "2" .And. M->BE4_TIPINT == "01"
					cTipInt := "2" //Internacao Cirurgica
				Case M->BE4_GRPINT == "2" .And. M->BE4_TIPINT == "03"
					cTipInt := "3" //Internacao Obstetrica
				Otherwise
					cTipInt := M->BE4_GRPINT + "." + M->BE4_TIPINT
			EndCase
		EndIf
	EndIf

	//Fim da Rotina															 ³

Return(cTipInt=="3")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSLastOX3³Autor  ³ Tulio Cesar              Data ³ 28.08.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Busca o ultimo X3_ORDEM para um determinado Alias do SX2       	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLastOX3(cAlias)
	LOCAL cOrdem := "01"

	DbSelectarea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(MsSeek(cAlias+"ZZ",.T.))
	SX3->(DbSkip(-1))
	If SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
		cOrdem := SX3->X3_ORDEM
	EndIf

Return(cOrdem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSBIOMET ³Autor  ³ David de Oliveira        Data ³ 07.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Função de Validação Bimétrica                                 ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBIOMET(cAlias,cId,lValidOpe,cTipo)
	/*
cTipo = 1 Verificação e Cadastro de Digitais Cadastradas
cTipo = 2 Validacao ou Cadastro de Digitais Cadastradas
	*/
	Local lRet			:= .T.
	Local cUsr			:= PLSRtCdUsr()
	Local aVldOper		:= {}
	Local nRecBX4
	LOCAL aArea         := GetArea()
	Local lValBio       := .T.
	Default lValidOpe 	:= .F.
	Default cTipo		:= "2"

	If ExistBlock("PLBiomet")
		lValBio:= ExecBlock('PLBiomet',.F.,.F.,{cAlias,cId,lValidOpe,cTipo, cUsr})
	EndIf

	If cTipo = "1" .And. lValBio
		DbSelectArea("BX4")
		BX4->(DbSetOrder(1))

		If BX4->(MsSeek(xFilial("BX4")+cUsr)) .and. BX4->(FieldPos("BX4_ALTBIO")) > 0 .and. BX4->BX4_ALTBIO = '0'

			nRecBx4  := BX4->(Recno())
			aVldOper := PlsVldOper(cUsr)
			If aVldOper[1] .and. BX4->(MsSeek(xFilial("BX4")+aVldOper[2])) .and. BX4->BX4_ALTBIO = '1'
				If GetNewPar("MV_BIONEW",.F.)
					BioGetAllFingersNew(cAlias,cId,nil,.T.)
				Else
					BioGetHandFingers(cAlias,cId,nil,.T.)
				EndIf
				lRet := .T.
			Else
				Aviso( STR0128, STR0129+UsrRetName(aVldOper[2])+STR0130 , {"Ok"} )
				If GetNewPar("MV_BIONEW",.F.)
					BioGetAllFingersNew(cAlias,cId,nil,.F.)
				Else
					BioGetHandFingers(cAlias,cId,nil,.F.)
				EndIf
				lRet := .T.
			EndIf
			BX4->(DbGoTo(nRecBx4))

		Else
			If GetNewPar("MV_BIONEW",.F.)
				BioGetAllFingersNew(cAlias,cId)
			Else
				BioGetHandFingers(cAlias,cId)
			EndIF
			lRet := .T.
		EndIf

	ElseIf cTipo = "2" .And. lValBio

		lRet := BioVorCFingers(cAlias,cId)

		// Para Tratar quando da Erro de DLL e retorno da funcao acima é NIL.
		If !GetNewPar("MV_BIONEW",.F.)
			If ValType(lRet) <> "L"
				MsgInfo(STR0187)//"Ocorreu uma Falha no cadastro de digitais!"
				lRet := .T.
			Endif

			If !lRet .and. lValidOpe

				DbSelectArea("BX4")
				BX4->(DbSetOrder(1))

				If BX4->(MsSeek(xFilial("BX4")+cUsr)) .and. BX4->(FieldPos("BX4_ALTBIO")) > 0  .and. BX4->(FieldPos("BX4_CANBIO")) > 0

					If MsgYesNo(STR0132)

						nRecBx4  := BX4->(Recno())
						aVldOper := PlsVldOper(cUsr)
						If aVldOper[1]
							If BX4->(MsSeek(xFilial("BX4")+aVldOper[2])) .and. BX4->BX4_CANBIO = '1'
								lRet := .T.
							Else
								Aviso( STR0128, STR0129+UsrRetName(aVldOper[2])+STR0131, {"Ok"} )
							EndIf
						EndIf
						BX4->(DbGoTo(nRecBx4))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSVLDOPER³Autor  ³ David de Oliveira        Data ³ 07.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Função de Validação de Usuário Para Biometria                 ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsVldOper(cUsuario)
	Local lRet			:= .F.
	Local cUsrAlc       := ""
	Local cNomeUsr		:= ""
	Local oDlgBio
	Local oMainPanel
	Local nOpc
	Local cPassw		:= Space(20)
	Default cUsuario 	:= "000001"

	If Existblock("PLSUSRBIO")
		aRetUsr:= Execblock("PLSUSRBIO",.F.,.F.)
		If Valtype(aRetUsr) =="A" .and. len(aRetUsr) == 2
			cUsrAlc := aRetUsr[1]
			cNomeUsr :=aRetUsr[2]
		Endif
	Endif

	DEFINE MSDIALOG oDlgBio TITLE STR0116   FROM 0,0 TO 100,300  PIXEL

	@00,00 MSPANEL oMainPanel SIZE 120,25 of oDlgBio
	oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT
	@ 06 , 10  	Say STR0117	PIXEL of oMainPanel
	@ 20 , 10  	Say STR0118	PIXEL of oMainPanel

	@ 06 , 40	MSGET oUsuario 	VAR cUsrAlc		SIZE 40,09	when .F. PIXEL of oMainPanel
	@ 06 , 80   BUTTON "..."                    SIZE 13,10           PIXEL OF oDlgBio ACTION (PLSUSRBIO(@cUsrAlc,@cNomeUsr))
	@ 06 , 94	MSGET oNomeUsr 	VAR cNomeUsr	SIZE 40,09	when .F. PIXEL of oMainPanel
	@ 20 , 40  	MSGET opassw	VAR cPassw		SIZE 40,09	PASSWORD VALID VldUser(cUsrAlc,cPassw) PIXEL of oMainPanel

	DEFINE SBUTTON FROM 35,26 TYPE 1 ACTION (nOpc := 1,oDlgBio:End()) when iiF(!Empty(cUsrAlc) .and. !Empty(cPassw),.T.,.F.)  OF oDlgBio PIXEL
	DEFINE SBUTTON FROM 35,56 TYPE 2 ACTION (nOpc := 2,oDlgBio:End()) ENABLE OF oDlgBio PIXEL

	ACTIVATE MSDIALOG oDlgBio CENTER

	If nOpc = 1
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return{lRet,cUsrAlc}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³VLDUSER   ³Autor  ³ David de Oliveira        Data ³ 07.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Função de Validação de Usuário Para Biometria                 ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldUser(cUsuario,cPassw)

	PswOrder(1)
	If PswSeek(cUsuario,.T.)

		If !PswName(cpassw)
			MsgAlert(STR0119)
			Return .F.
		EndIf

	Else

		MsgAlert(STR0117+cUsuario+STR0120)
		Return .F.

	EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSARRAYF ³Autor  ³ Alexander Santos         Data ³ 27.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Coloca dados de uma matriz em um arquivo em disco					³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSARRAYF(aMat,cDirFile)
	default cDirFile := "PLSARRAYF.DAT"

	//Grava o conteudo do array. Pasta default logpls
	if len(aMat)>0
		PLSLOGFIL( array2Str(aMat,.F.) ,cDirFile)
	endIf

return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSFARRAY ³Autor  ³ Alexander Santos         Data ³ 27.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Retorna dados de um arquivo em disco para uma matriz				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSFARRAY(cDirFile, nTotLNF, lDelete)
	local nTotLid	:= 0
	local cArray  	:= ""
	local aMatAux 	:= {}
	default nTotLNF := -1
	default lDelete	:= .t.

	//Verifica se o arquivo existe
	if file(cDirFile)

		//Abre o arquivo
		nHdl := fOpen( cDirFile, 2 )

		fseek(nHdl,0)
		nBuffer := (64 * 1024)

		//Le todo o arquivo
		while .T.
			cArray 	:= space(nBuffer)
			lRead 	:= FReadLn(nHdl, @cArray, nBuffer)

			if !lRead
				Exit
			endIf
			aadd(aMatAux , str2Array( cArray, .F. ) )
		endDo

		//Fecha arquivo
		fClose( nHdl )

		//Deleta arquivo
		if lDelete
			fErase(cDirFile)
		endIf

		//Verificacao
		nTotLid := len(aMatAux)

	endIf

return(aMatAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o PlsLoadAlias | Autor ³ Daher				 Data ³ 15.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³					     								      ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   Atualizacao PLS                                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlsLoadAlias(cAlias,aTrab)

	Local nY
	Local nX
	Local aArea := GetArea()

	dbSelectArea("SX2")
	dbSeek(cAlias)

	dbSelectArea(cAlias)
	(cAlias)->( dbSetorder(01) )


	RecLock(cAlias,.T.)
	For nX := 1 to Len(aTrab)
		If &(cAlias)->(FieldPos(aTrab[nX][1])) > 0
			If ValType(&(aTrab[nX][1])) == ValType(aTrab[nX][2])
				If !("_FILIAL" $ aTrab[nX][1])
					&(aTrab[nX][1]) := aTrab[nX][2]
				Else
					&(aTrab[nX][1]) := xFilial(cAlias)
				Endif
			Endif
		Endif
	Next nX
	MsUnlock()

	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSVLDVIG ³Autor  ³ Alexander Santos         Data ³ 22.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Validacao da vigencia												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDVIG(cAlias,nOpc,oObj,cCampoDe,cCampoAte,aChave,lHelp,aMat,cCampoCod,lDtvigI,lDtvigF,cTipp,cCampoTip,cCampoQtd)
	LOCAL nPos    	  := 0
	LOCAL nI      	  := 0
	LOCAL nX      	  := 0
	LOCAL nY      	  := 0
	LOCAL nC      	  := 0
	LOCAL lAltera 	  := .F.
	LOCAL nRecno  	  := 0
	LOCAL dVigDe  	  := CToD('')
	LOCAL dVigAte 	  := CToD('')
	LOCAL aCampos 	  := {}
	Local cCampos     := ""
	Local nColCD	  := 0
	Local nColDi	  := 0
	Local nColDv	  := 0
	Local nPos2		  := 0
	LOCAL nColTR 	  := 0
	LOCAL lBCP		  := .T.
	LOCAL nPos3		  := 0
	LOCAL lJaValid    :=.F.
	LOCAL cTipo		  := ""
	LOCAL nPos4       := 0
	LOCAL nQtdCo	  := 0
	LOCAL nPosArray   := 0

	DEFAULT oObj  	  := NIL
	DEFAULT nOpc      := 0
	DEFAULT cCampoDe  := ""
	DEFAULT cCampoAte := ""
	DEFAULT cCampoTip := ""
	DEFAULT aChave	  := {}
	DEFAULT lHelp 	  := .F.
	DEFAULT aMat 	  := {}
	DEFAULT cCampoCod := ""
	DEFAULT lDtvigI	  := .f.
	DEFAULT lDtvigF	  := .f.
	DEFAULT cTipp     := ""
	DEFAULT cCampoQtd := ""

	If nOpc == 0
		If inclui
			nOpc := 3		// Incluir
		Elseif Altera
			nOpc := 4		// Alterar
		Else
			nOpc := 5		// Excluir
		Endif
	Endif

	// Nao valida exclusao porque nao existe relacionamento.
	If nOpc == K_Excluir
		Return(.T.)
	Endif

	lAltera := (nOpc == K_Alterar)

	//Verifica fim e maior que o inicio
	If Type("M->"+cCampoDe) <> "U" .and. Type("M->"+cCampoAte) <> "U"

		If ! Empty( &("M->"+cCampoAte) ) .And. &("M->"+cCampoDe) > &("M->"+cCampoAte)

			If lHelp
				Help( ,, 'HELP',,STR0141, 1, 0)
			Else
				MsgAlert(STR0141)//'Vigência final menor que a inicial!'
			Endif
			Return .F.
		Else
			lJaValid := .T.
		EndIf

	Endif

	If !Empty(cAlias)
		nRecno := &(cAlias)->( Recno() )
	Endif

	//Verifica se a matriz foi passada por parametro
	If Len(aMat) == 0 .and. !Empty(cAlias)

		//Verifica se ja cadastrado
		If ValType(oObj) == "U"

			If Len(aChave) == 0

				&(cAlias)->( DbSetOrder(1) )
				&(cAlias)->( DbGoTop() )

				While !&(cAlias)->( Eof() )

					If ( lAltera .And. nRecno == &(cAlias)->( Recno() ) )
						&(cAlias)->( DbSkip() )
						loop
					EndIf

					AaDd( aMat,{ &(cAlias+"->"+cCampoDe),&(cAlias+"->"+cCampoAte) } )

					&(cAlias)->( DbSkip() )
				EndDo

			Else

				&(cAlias)->( DbSetOrder(aChave[1]) )
				If &(cAlias)->( DbSeek(aChave[2]) )

					While !(&(cAlias)->(Eof())) .and. &(cAlias)->(&(aChave[3])) == aChave[2]

						// Ignora o proprio registro.
						If ( lAltera .And. nRecno == &(cAlias)->(Recno()) )
							&(cAlias)->( dbSkip() )
							Loop
						EndIf

						AaDd( aMat,{ &(cAlias+"->"+cCampoDe),&(cAlias+"->"+cCampoAte) } )
						&(cAlias)->( DbSkip() )

					EndDo

				Endif

			Endif

		Else

			For nI := 1 To Len(oObj:oBrowse:aCols)

				cCampos := ""

				If ( ! empty(cCampoCod) .AND. AllTrim(oObj:oBrowse:aCols[nI,6]) != AllTrim(&("M->"+cCampoCod))) .OR. n == nI .OR. Len(oObj:oBrowse:aCols) == 1
					Loop
				EndIf

				// Chave seletiva - So considera os registros com a mesma chave.
				If Len(aChave) > 0

					aCampos:= {}
					nY := 1

					For nX := 1 To Len(aChave[3])+1
						If Substr(aChave[3],nX,1) == "+" .Or. Empty(Substr(aChave[3],nX,1))
							Aadd( aCampos, SubStr(aChave[3],nY,nX - nY))
							nY := nX + 1
						Endif
					Next nX

					For nC := 1 To Len(aCampos)
						nPos := PLRETPOS(aCampos[nC],oObj:aHeader,.F.)
						If nPos > 0
							If Valtype(oObj:oBrowse:aCols[nI,nPos]) == "N"
								cCampos += cValToChar(oObj:oBrowse:aCols[nI,nPos])
							Else
								cCampos += oObj:oBrowse:aCols[nI,nPos]
							EndIf
						EndIf
					Next nC


					If ! Empty(cCampos)

						If ValType(aChave[2]) == "N"

							If !(AllTrim(cCampos) == cValToChar(aChave[2]))
								Loop
							EndIf

						ElseIf !(AllTrim(cCampos) == AllTrim(aChave[2]))
							Loop
						Endif

					Endif

				Endif

				// Vigencia de
				If cAlias == "BCP"  // verificando doc obrigatorio registros vazios na grid

					nColCD := PLRETPOS("BCP_CODDOC",oObj:aHeader,.F.)

					If EMPTY(oObj:aCols[nI,nColCD])
						lBCP:=.F.
					Endif

				Endif

				if subStr(cCampoDe,1,3) == cAlias
					nPos 	:= PLRETPOS(cCampoDe,oObj:aHeader,.F.)
					nPos2 	:= PLRETPOS(cCampoAte,oObj:aHeader,.F.)
					If !Empty(cCampoTip)
						nPos3 	:= PLRETPOS(cCampoTip,oObj:aHeader,.F.)
					EndIf

					nPos4   := PLRETPOS(cCampoQtd,oObj:aHeader,.F.)
				Else
					nPos 	:= PLRETPOS(cAlias+cCampoDe,oObj:aHeader,.F.)
					nPos2 	:= PLRETPOS(cAlias+cCampoAte,oObj:aHeader,.F.)
					If !Empty(cCampoTip)
						nPos3 	:= PLRETPOS(cAlias+cCampoTip,oObj:aHeader,.F.)
					EndIf

					nPos4   := PLRETPOS(cCampoQtd,oObj:aHeader,.F.)
				Endif

				If nPos > 0
					dVigDe := oObj:oBrowse:aCols[nI,nPos]
				EndIf

				If nPos2 > 0
					dVigAte := oObj:oBrowse:aCols[nI,nPos2]
				EndIf

				If nPos3 > 0
					cTipo := oObj:oBrowse:aCols[nI,nPos3]
				EndIf

				If nPos4 > 0
					nQtdCo := oObj:oBrowse:aCols[nI,nPos4]
				EndIf

				If nPos2 > 0 .and. lBCP .And. !oObj:oBrowse:aCols[nI][Len(oObj:oBrowse:aCols[nI])]

					If !EMPTY(cCampoQtd) .AND. nQtdCo > 0

						AaDd( aMat,{ dVigDe,dVigAte,cTipo,nQtdCo } )
					Else
						AaDd( aMat,{ dVigDe,dVigAte,cTipo } )
					EndIf
				Endif

			Next

		EndIf

	Endif

	//Verifica se ja cadastrado
	nPos 	:= AsCan(aMat,{ |x| Empty(x[2])} )
	nPos2 	:= AsCan(aMat,{ |x| Empty(x[2]).AND. &("M->"+cCampoDe) >= x[2]  .AND. &("M->"+cCampoDe) >= x[1] } )

	//Se tem vigencia com data final em aberta verifica se a data final e menor que a inicial
	If cAlias == "BCP"

		nPos3 := AsCan(aMat,{ |x| Empty(x[2]) .AND.  &("M->"+cCampoAte) == x[2] .AND. &("M->"+cCampoDe) >= x[2]  } )

		If nPos3 > 0 .AND. lDtvigF

			If lHelp
				Help( ,, 'HELP',,STR0142, 1, 0)
			Else
				MsgAlert(STR0142)//'Já existe uma vigência em aberto'
			Endif

			Return .F.

		Endif

	Endif

	If nPos > 0

		//varre o array até encontrar uma condição que retorne false
		For nPosArray := 1 To LEN(aMat)

			If Len(aMat[nPosArray]) == 2 .OR. (Len(aMat[nPosArray]) >= 3 .AND. ( EmpTy(aMat[nPosArray,3]) .Or. &("M->" + cCampoTip) == "3" ;
					.Or. aMat[nPosArray,3] == "3" .Or. &("M->" + cCampoTip) == aMat[nPosArray,3]))

				//esta função é chamada de varios fontes que não passam o parametro na variável cCampoQtd, por isso é necessário o IIF
				//para não causar errorlog e sem um vamlor neste campo, a quantidade não é considerada
				If empty( &("M->" + cCampoAte) ) .AND. IIF(!EMPTY(cCampoQtd), &("M->" + cCampoQtd) == aMat[nPosArray,4],.T.)

					If Empty(aMat[nPosArray,2]) .Or. &("M->" + cCampoDe) <=  aMat[nPosArray,2]

						If lHelp
							Help( ,, 'HELP',,STR0142, 1, 0)
						Else
							MsgAlert(STR0142)//'Já existe uma vigência em aberto'
						Endif

						Return .F.
					EndIf
				EndIf

				nPos := AsCan(aMat,{ |x| &("M->"+cCampoDe) >= x[1] .And. &("M->"+cCampoDe) <= x[2] .Or. &("M->"+cCampoDe) < x[1] .And. &("M->"+cCampoAte) > x[1] } )

				If nPos > 0 .AND. IIF(!EMPTY(cCampoQtd), &("M->" + cCampoQtd) == aMat[nPosArray,4],.T.)

					If lHelp
						Help( ,, 'HELP',,STR0144, 1, 0)
					Else
						MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
					Endif

					Return .F.

				EndIf

				nPos := AsCan(aMat,{ |x| &("M->"+cCampoAte) >= x[1] .And. &("M->"+cCampoAte) <= x[2]  } )

				If nPos > 0 .AND. IIF(!EMPTY(cCampoQtd), &("M->" + cCampoQtd) == aMat[nPosArray,4],.T.)

					If lHelp
						Help( ,, 'HELP',,STR0144, 1, 0)
					Else
						MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
					Endif

					Return .F.

				EndIf

			EndIf
		Next

	Elseif ValType(oObj) == "O"

		//Se e valido o intervalo
		if (readVar() == "M->BCP_DATINC" .and.  AsCan(aMat,{ |x| &("M->"+cCampoDe) >= x[1] .and. &("M->"+cCampoDe) <= x[2]  } ) > 0) .or. (readVar() == "M->BCP_DATVAL" .and.  AsCan(aMat,{ |x| &("M->"+cCampoAte) <= x[2] .and. &("M->"+cCampoAte) >= x[1]  } ) > 0)

			If lHelp
				Help( ,, 'HELP',,STR0144, 1, 0)
			Else
				MsgAlert(STR0144)
			Endif

		elseif cAlias == "BCP" .and. !empty(&("M->"+cCampoDe)) .and. !empty(&("M->"+cCampoAte))

			nPos := AsCan(aMat,{ |x| (&("M->"+cCampoDe ) >= x[1] .and. &("M->"+cCampoDe)  <= x[2]) .or. ;
				(&("M->"+cCampoAte) <= x[2] .and. &("M->"+cCampoAte) >= x[1]) .or. ;
				(! empty(x[2]) .and. &("M->"+cCampoDe ) <  x[1] .and. &("M->"+cCampoAte)> x[2] ) } )

			If nPos > 0

				If lHelp
					Help( ,, 'HELP',,STR0144, 1, 0)
				Else
					MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
				Endif

				Return .F.
			EndIf

		elseif cAlias == "BCP" .and. (lDtvigI .and. lDtvigF) .and. ! empty(&("M->"+cCampoDe)) .and. empty(&("M->"+cCampoAte))

			nPos := AsCan(aMat,{ |x| &("M->"+cCampoDe ) < x[1] } )

			If nPos > 0

				If lHelp
					Help( ,, 'HELP',,STR0144, 1, 0)
				Else
					MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
				Endif

				Return .F.

			EndIf

		else

			If EMPTY(cCampoQtd)

				nPos  := AsCan(aMat,{ |x| &("M->"+cCampoDe) <= x[2] } ) //Validar a vigência do item, não intervalo.
			Else
				nPos  := AsCan(aMat,{ |x| &("M->"+cCampoDe) <= x[2] .and. &("M->"+cCampoQtd) == x[4]} ) //Validar a vigência do item, não intervalo.
			EndIf

			If ( nPos > 0 .And. ( aMat[nPos,3] == "" .Or. &("M->"+cCampoTip) == "3" .Or. aMat[nPos,3] == "3" .Or. &("M->"+cCampoTip) == aMat[nPos,3] ) );
				.Or. ( cAlias == "BCP" .and. lDtvigI .And. !lJaValid )

			If lHelp
				Help( ,, 'HELP',,STR0146, 1, 0)
			Else
				MsgAlert(STR0146)  //'A data incial da nova vigência precisa ser maior que a data final da ultima vigência!'
			Endif

			Return .F.

		EndIf

	endIf

	If lDtvigF

		aMat	:= {}
		nColCD 	:= PLRETPOS("BCP_CODDOC",oObj:aHeader,.F.)
		nColDi 	:= PLRETPOS("BCP_DATINC",oObj:aHeader,.F.)
		nColDv 	:= PLRETPOS("BCP_DATVAL",oObj:aHeader,.F.)
		nColTR 	:= PLRETPOS("BCP_ENTREG",oObj:aHeader,.F.)

		IF nColCD > 0

			For nI := 1 To Len(oObj:aCols)

				If ( lAltera .And. nRecno == (cAlias)->( Recno() )  )
					loop
				Endif

				If ! empty(oObj:aCols[nI,nColCD])
					AaDd( aMat,{oObj:aCols[nI,nColCD],oObj:aCols[nI,nColDi],oObj:aCols[nI,nColDv],oObj:aCols[nI,nColTR],(cAlias)->( Recno() )} )
				Endif

			NEXT

			if M->BCP_ENTREG == "1" .and. empty(M->BCP_DATINC)

				If lHelp
					Help( ,, 'HELP',,STR0144, 1, 0)
				Else
					MsgAlert(	STR0253 ) //'Informar a Data de Inclusão!'
				Endif

				Return .F.

			ENDIF

		ENDIF

		IF nColCD == 0 .or. M->BCP_ENTREG == "1" .or. ! empty(M->BCP_DATINC)

			nPos2 := AsCan(aMat,{ |x| &("M->"+"BCP_CODDOC")  == x[1]  } )
			nPos  := AsCan(aMat,{ |x| &("M->"+cCampode) == x[3]  .and. &("M->"+"BCP_CODDOC")  == x[1]   } )	//	.AND. M->BCP_ENTREG  == x[4]

			If nPos > 0 .and. nPos2 > 0

				If lHelp
					Help( ,, 'HELP',,STR0249, 1, 0)
				Else
					MsgAlert(STR0254) //"A data Final da nova vigência não pode ser vazia ou igual a data Inicial da ultima vigência!"
				Endif

				Return .F.

			endif

			nPos := AsCan(aMat,{ |x| &("M->"+cCampoAte) >= x[2] .and. &("M->"+cCampoAte) == x[3] .AND. &("M->"+"BCP_CODDOC")  == x[1]  } )//nPos := AsCan(aMat,{ |x| &("M->"+cCampoAte) >= x[2] .and. &("M->"+cCampoAte) <= x[3] .AND. M->BCP_ENTREG  == x[4] .AND. &("M->"+"BCP_CODDOC")  == x[1]  } )

			If nPos > 0 .AND. nPos <> nPos2

				If lHelp
					Help( ,, 'HELP',,STR0144, 1, 0)
				Else
					MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
				Endif

				Return .F.

			EndIf

			nPos := AsCan(aMat,{ |x| &("M->"+cCampode) == x[3] .And.  &("M->"+"BCP_CODDOC")  == x[1] .or.  &("M->"+cCampode) == x[2] .And. &("M->"+"BCP_CODDOC")  == x[1]   } )//.AND. M->BCP_ENTREG  == x[4]

			If nPos > 0 .and. nPos <> nPos2

				If lHelp
					Help( ,, 'HELP',,STR0144, 1, 0)
				Else
					MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
				Endif

				Return .F.

			EndIf

			nPos := AsCan(aMat,{ |x| &("M->"+cCampode) <= x[3] .AND.  &("M->"+cCampode) >= x[2]   .AND. &("M->"+"BCP_CODDOC")  == x[1]   } )//.AND. M->BCP_ENTREG  == x[4]

			If nPos > 0 .and. nPos <> nPos2

				If lHelp
					Help( ,, 'HELP',,STR0144, 1, 0)
				Else
					MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
				Endif

				Return .F.

			EndIf

			nPos := AsCan(aMat,{ |x| &("M->"+cCampoAte) == x[2] .AND. &("M->"+"BCP_CODDOC")  == x[1]   } )//.AND. M->BCP_ENTREG  == x[4]

			If nPos > 0 .and. nPos <> nPos2

				If lHelp
					Help( ,, 'HELP',,STR0144, 1, 0)
				Else
					MsgAlert(STR0144)//'Já existe um intervalo de data que compreende a data selecionada!'
				Endif

				Return .F.

			EndIf

		endIf

		aMat := {}
	Endif

	EndIf

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³PLSINTVAL ³Autor  ³ Alexander Santos         Data ³ 22.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Validacao de intervalo de datas									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSINTVAL(cAlias,cDatDe,cDatAte,dDatAnalise,dMDatDe,dMDatAte)
	local lRet 		:= .f.
	local dDatDe 	:= (cAlias)->&(cDatDe)
	local dDatAte 	:= (cAlias)->&(cDatAte)

	default dDatAnalise	:= iIf(GetNewPar("MV_PLSRADP","1")=="1",Date(),dDataBase)
	default dMDatDe 	:= nil
	default dMDatAte 	:= nil

	if dMDatDe <> nil .and. dMDatAte <> nil

		if empty( dDatDe )

			lRet := dtos(dDatAnalise) <= dtos(dDatAte) .and. dtos(dMDatDe) <= dtos(dDatAte)

		elseif empty(dDatAte) .and. empty(dMDatDe)

			lRet := dtos(dMDatAte) >= dtos(dDatDe)

		elseif empty(dDatAnalise)

			if empty(dMDatAte)
				lRet := dtos(dDatAte) >= dtos(dMDatDe) .or. empty(dDatAte)
			else
				lRet := dtos(dDatAte) <= dtos(dMDatAte)
			endIf

		else
			lRet := (dtos(dDatAnalise) >= dtos(dDatDe)) .and. (dtos(dDatAnalise) <= dtos(dDatAte) .or. empty(dDatAte))
		endIf

	else
		lRet := (dtos(dDatAnalise) >= dtos(dDatDe)) .and. (dtos(dDatAnalise) <= dtos(dDatAte) .or. empty(dDatAte))
	endIf

return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SeekB24   ºAutor  ³Geraldo Felix Jr.   º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Verifica se existe tabela de preço generica vinculada a RDA º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SeekB24(cCodRDA,cCodInt,cCodLoc,dDatAnalise)
	LOCAL aRet	:= {}

	If B24->(MsSeek(xFilial("B24")+cCodRDA+cCodInt+Subs(cCodLoc,1,3)))

		While !B24->( Eof() ) .and. B24->B24_CODINT == cCodInt .and. B24->B24_CODIGO == cCodRDA .and. B24->B24_CODLOC == Subs(cCodLoc,1,3)

			If PLSINTVAL("B24","B24_VIGINI","B24_VIGFIN",dDatAnalise)
				Aadd(aRet, B24->B24_TABPRE)
			Endif

			B24->( dbSkip() )
		Enddo

	Endif

Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSFORHIS ºAutor  ³Totvs				 º Data ³  03/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Gravacao do historico de autorizacao forcada			      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSFORHIS(nOpc,cOrigem,cAliasCab,aAutFor,aCopHCri)
	LOCAL nFor  	:= 1
	LOCAL nCri		:= 1
	LOCAL lInc  	:= .F.
	LOCAL cSequen 	:= ""
	LOCAL cCodPad 	:= ""
	LOCAL cCodPro 	:= ""
	LOCAL cCodCri 	:= ""
	LOCAL cDesCri 	:= ""
	LOCAL cInfCri	:= ""
	LOCAL aControl	:= {{},{}}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Numero da autorizacao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cOpeMov := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
	cAnoAut := &(cAliasCab+"->"+cAliasCab+"_ANOAUT")
	cMesAut := &(cAliasCab+"->"+cAliasCab+"_MESAUT")
	cNumAut := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")

	BDS->( DbSetOrder(1) ) //BDS_FILIAL + BDS_OPEMOV + BDS_ANOAUT+ BDS_MESAUT + BDS_NUMAUT + BDS_ORIGEM + BDS_CODPAD + BDS_CODPRO + BDS_SEQUEN
	B67->( DbSetOrder(1) ) //B67_FILIAL + B67_OPEMOV + B67_ANOAUT + B67_MESAUT + B67_NUMAUT + B67_ORIGEM + B67_SEQUEN + B67_CODPAD + B67_CODPRO + B67_CODCRI + B67_DESCRI + B67_INFORM

	//Cabecalho da autorizacao forcada

	If Len(aAutFor) > Len(aCopHCri)

		For nFor := 1 To Len(aAutFor) - Len(aCopHCri)

			If Len(aCopHCri) > 0
				AAdd(aCopHCri,aCopHCri[Len(aCopHCri)])
			Endif

		Next nFor

	ElseIf Len(aAutFor) < Len(aCopHCri)

		For nFor := 1 To Len(aCopHCri) - Len(aAutFor)

			If Len(aAutFor) > 0
				AAdd(aAutFor,aAutFor[Len(aAutFor)])
			EndIf

		Next nFor

	EndIf

	For nFor := 1 To Len(aAutFor)

		//Se ja existir posiciono
		If aAutFor[nFor,8] > 0
			BDS->( DbGoTo( aAutFor[nFor,8] ) )
		Else
			lInc := .T.
		EndIf

		If lInc
			lInc := !BDS->( MsSeek( xFilial("BDS") + cOpeMov + cAnoAut + cMesAut + cNumAut + cOrigem + aAutFor[nFor,2] + aAutFor[nFor,3] + Iif( Len(aAutFor[nFor])>=14,aAutFor[nFor,14],"") ) )
		Endif

		//Sequen
		cSequen := Iif( Len(aAutFor[nFor])>=14,aAutFor[nFor,14],"")
		cCodPad := aAutFor[nFor,2]
		cCodPro := aAutFor[nFor,3]

		//Se nao for exclusao
		If nOpc <> K_Excluir

			If lInc .And. AScan(aControl[1], {|x| x == xFilial("BDS")+cOpeMov+cAnoAut+cMesAut+cNumAut+cOrigem+cCodPad+cCodPro+DTOS(aAutFor[nFor,10])+Subs(StrTran(aAutFor[nFor,11],":",""),1,4) } ) == 0
				BDS->(RecLock("BDS",.T.) )
				BDS->BDS_FILIAL := xFilial("BDS")

				BDS->BDS_OPEMOV := cOpeMov
				BDS->BDS_ANOAUT := cAnoAut
				BDS->BDS_MESAUT := cMesAut
				BDS->BDS_NUMAUT := cNumAut

				If BDS->(FieldPos("BDS_SEQUEN")) > 0
					BDS->BDS_SEQUEN := cSequen
				EndIf

				BDS->BDS_CODPAD := cCodPad
				BDS->BDS_CODPRO := cCodPro
				BDS->BDS_OPESIS := PLSRtCdUsr()
				BDS->BDS_NOMOPE := PLRETOPE()
				BDS->BDS_DATA   := aAutFor[nFor,10]
				BDS->BDS_HORA   := Subs(StrTran(aAutFor[nFor,11],":",""),1,4)
				BDS->BDS_ORIGEM := cOrigem //1=Consulta;2=SADT;3=Internacao;4=Odontologico;5=Reembolso

				If BDS->(FieldPos("BDS_USUARI")) > 0
					BDS->BDS_USUARI	:= &(cAliasCab+"->"+cAliasCab+"_OPEUSR")+&(cAliasCab+"->"+cAliasCab+"_CODEMP")+&(cAliasCab+"->"+cAliasCab+"_MATRIC")+&(cAliasCab+"->"+cAliasCab+"_TIPREG")
				EndIf

				If BDS->(FieldPos("BDS_DESUSU")) > 0
					BDS->BDS_DESUSU	:= &(cAliasCab+"->"+cAliasCab+"_NOMUSR")
				EndIf

				If BDS->(FieldPos("BDS_CODRDA")) > 0

					If cAliasCab == "B4A"
						BDS->BDS_CODRDA	:= ""
					Else
						BDS->BDS_CODRDA	:= &(cAliasCab+"->"+cAliasCab+"_CODRDA")
					EndIf
				EndIf

				If BDS->(FieldPos("BDS_NOMRDA")) > 0

					If cAliasCab == "B4A"
						BDS->BDS_NOMRDA	:= ""
					Else
						BDS->BDS_NOMRDA	:= &(cAliasCab+"->"+cAliasCab+"_NOMRDA")
					EndIf
				EndIf

				If BDS->(FieldPos("BDS_CODMOT")) > 0
					BDS->BDS_CODMOT	:= If(Len(aAutFor[nFor])>=12,aAutFor[nFor,12],"")
				EndIf

				If BDS->(FieldPos("BDS_OBSMOT")) > 0
					BDS->BDS_OBSMOT	:= If(Len(aAutFor[nFor])>=13,aAutFor[nFor,13],"")
				EndIf

				BDS->( MsunLock() )

				AAdd(aControl[1],xFilial("BDS")+cOpeMov+cAnoAut+cMesAut+cNumAut+cOrigem+cCodPad+cCodPro+DTOS(aAutFor[nFor,10])+Subs(StrTran(aAutFor[nFor,11],":",""),1,4))

			EndIf

			//Itens
			If Empty(aAutFor[nFor,2])
				aAutFor[nFor,2] := space(TamSX3("B67_CODPAD")[1])
			Endif

			If Empty(aAutFor[nFor,3])
				aAutFor[nFor,3] := space(TamSX3("B67_CODPRO")[1])
			Endif

			If Len(aAutFor[nFor]) >= 14

				If Empty(aAutFor[nFor,14])
					aAutFor[nFor,14] := Space(TamSX3("B67_SEQUEN")[1])
				Endif

			Endif

			If len(aCopHCri) >= nFor
				For nCri := 1 To Len(aCopHCri[nFor])

					//³Codigo da Critica
					cCodCri := aCopHCri[nFor,nCri,1]
					cDesCri := Iif( !Empty(aCopHCri[nFor,nCri,2]), aCopHCri[nFor,nCri,2],BCT->( Posicione("BCT",1,xFilial("BCT") + &(cAliasCab+"->"+cAliasCab+"_OPEMOV") + aCopHCri[nFor,nCri,1],"BCT_DESCRI") ) )
					cInfCri	:= aCopHCri[nFor,nCri,3]

					// So grava o cabeçalho das criticas.
					If Empty(cCodCri) .Or. Empty(cDesCri)
						Loop
					Endif

					//³Verifica se nao existe
					If len(aControl[2]) == 0 .or. AScan(aControl[2], {|x| x == xFilial("B67")+cSequen+cCodPad+cCodPro+cOpeMov+cAnoAut+cMesAut+cNumAut+cOrigem+cCodCri+cDesCri+cInfCri}) == 0
						//B67_FILIAL+B67_OPEMOV+B67_ANOAUT+B67_MESAUT+B67_NUMAUT+B67_ORIGEM+B67_SEQUEN+B67_CODPAD+B67_CODPRO+B67_CODCRI+B67_DESCRI+B67_INFORM
						If !B67->(msSeek(xFilial("B67")+cOpeMov+cAnoAut+cMesAut+cNumAut+cOrigem+cSequen+cCodPad+cCodPro+cCodCri+cDesCri+cInfCri))
							if !empty(cNumAut)
								B67->( RecLock("B67",.T.) )
								B67->B67_FILIAL := xFilial("B67")
								B67->B67_SEQUEN := cSequen
								B67->B67_CODPAD := cCodPad
								B67->B67_CODPRO := cCodPro
								B67->B67_OPEMOV := cOpeMov
								B67->B67_ANOAUT := cAnoAut
								B67->B67_MESAUT := cMesAut
								B67->B67_NUMAUT := cNumAut
								B67->B67_ORIGEM := cOrigem
								B67->B67_CODCRI	:= cCodCri
								B67->B67_DESCRI	:= cDesCri
								B67->B67_INFORM	:= cInfCri
								B67->( MsunLock() )

								AAdd(aControl[2],xFilial("B67")+cSequen+cCodPad+cCodPro+cOpeMov+cAnoAut+cMesAut+cNumAut+cOrigem+cCodCri+cDesCri+cInfCri)
							endif


						EndIf

					EndIf

				Next
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Se for exclusao e o registro existir
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		ElseIf nOpc == K_Excluir .And. !lInc

			//Deleta o iten
			If B67->( MsSeek( xFilial("B67") + BDS->(BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM+BDS_SEQUEN+BDS_CODPAD+BDS_CODPRO) ) )

				While !B67->( Eof() ) .And. BDS->(BDS_FILIAL+BDS_OPEMOV+BDS_ANOAUT+BDS_MESAUT+BDS_NUMAUT+BDS_ORIGEM+BDS_SEQUEN+BDS_CODPAD+BDS_CODPRO) == B67->(B67_FILIAL+B67_OPEMOV+B67_ANOAUT+B67_MESAUT+B67_NUMAUT+B67_ORIGEM+B67_SEQUEN+B67_CODPAD+B67_CODPRO)

					B67->( RecLock("B67",.F.) )
					B67->( DbDelete() )
					B67->( MsUnLock() )

					B67->( DbSkip() )
				EndDo

			EndIf

			//Deleta o cabecalho
			BDS->( RecLock("BDS",.F.) )
			BDS->( DbDelete() )
			BDS->( MsUnLock() )
		EndIf

	Next

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o	 ³ PLSErr  Autor ³                  Data ³ 11/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Tratamento de Erro para QUERY            				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSErr(e)
	Help(" ",1,"ERR_FORM",,e:Description,3,1)
	BREAK
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSINFPRO ºAutor  ³Totvs				 º Data ³  03/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Retorna a informacao do procedimento					      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PLSINFPRO()

		LOCAL aArea  := GetArea()
		LOCAL cAlias
		LOCAL cRet := " "
		Local cTipGener := GETNEWPAR("MV_PLSTIPG","7,8,9")

		IF !(AllTrim(B53->B53_TIPO) $ cTipGener) // Rotina Genéricas - OUTROS
			If AllTrim(B53->B53_TIPO) $ "1,2,4"
				cAlias := "BE2"
			ElseIf AllTrim(B53->B53_TIPO) == "3"

				If Alias() $ "BQZ|B4A"
					cAlias := "BQV"
				Else
					cAlias := "BEJ"
				EndIf
			ElseIf AllTrim(B53->B53_TIPO) == "5"
				cAlias := "B45"
			ElseIf AllTrim(B53->B53_TIPO) == "6"
				cAlias := "B4C"
			ElseIf AllTrim(B53->B53_TIPO) == "11"
				cAlias := "BQV"
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Verifica se o campo existe
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If BR8->(FieldPos("BR8_INFPRO")) > 0
				BR8->(DbSetOrder(3))
				If BR8->(MsSeek(xFilial("BR8")+(cAlias)->&(cAlias+"_CODPRO")))
					cRet := BR8->BR8_INFPRO
				Endif
			EndIf
		EndIf
		RestArea(aArea)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Fim da Funcao
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Return cRet

	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | PlsCkInd ºAutor  ³ TOTVS              º Data ³  20/10/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Funcao verifica a existencia de um indice no SIX            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    SIGAPLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PlsCkInd(cIndex,cAviso,cTitulo)
		Default cAviso := ""
		Default cTitulo := ""

		SIX->(dbSetOrder(1))
		If !SIX->(dbSeek(cIndex))
			If !Empty(cAviso)
				MsgInfo(cAviso,cTitulo)
			EndIf
			Return .F.
		EndIf

	Return .T.

	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | PlsCkCon ºAutor  ³ TOTVS              º Data ³  20/10/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Valida se procedimento é Consulta                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    SIGAPLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PlsCkCon(cTipGui,cCodTab,cCodPro)

		PutHelp("PPLSCKCON",{STR0188},{},{},.f.) //"Procedimento Invalido."
		PutHelp("SPLSCKCON",{STR0189,STR0190},{},{},.f.) //"Para este tipo de guia, deve-se "###"informar procedimento de consulta."

		IF !PlsIsCon(cCodTab,cCodPro).and.cTipGui=="01"
			Help("",1,"PLSCKCON")
			Return .F.
		EndIf

	Return .T.
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³FuncaoPL790NMAUD³ Autor ³ Totvs		         Data ³ 26.09.11 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna Movimentacao da auditoria						  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PL790NMAUD(cAliMov,cRecMov,cSeqPro)
		LOCAL cChave  	:= ""
		LOCAL aMatDad 	:= {}
		LOCAL bOK       := {|| oDlg:End() }
		LOCAL bCancel	:= {|| oDlg:End() }
		LOCAL lExiDUT   := BRW->(FieldPos("BRW_TABDUT")) > 0 .And. BRW->(FieldPos("BRW_CODDUT")) > 0
		LOCAL nPosCodDut := 0
		LOCAL nPosCodSub := 0
		LOCAL aButtons   := {}
		LOCAL aCampos	 := {}
		DEFAULT cSeqPro := ""
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Posiciona no registro
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cChave := xFilial("B72") + cAliMov + cRecMov + Iif( Empty(cSeqPro),"",cSeqPro )

		oGEN := PLSREGIC():New()
		oGEN:GetDadReg("B72",1,cChave )

		If oGEN:lFound
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Monta lista de procedimentos
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			While !B72->( Eof() ) .And. cChave == B72->(B72_FILIAL + B72_ALIMOV + B72_RECMOV) + Iif( Empty(cSeqPro),"",B72->B72_SEQPRO )

				AaDd(aMatDad,{	B72->B72_DATMOV,;
					USRRETNAME(B72->B72_OPERAD),;
					RETCBOX("B72_PARECE",B72->B72_PARECE),;
					RETCBOX("B72_ACOTOD",B72->B72_ACOTOD),;
					AllTrim(B72->(B72_CODPAD + "-" + B72_CODPRO))+" - "+PadR(Posicione("BR8",1,xFilial("BR8")+B72->(B72_CODPAD+B72_CODPRO),"BR8_DESCRI"),80),;
					B72->B72_CODGLO + " - " + Posicione("BCT",1,xFilial("BCT")+B53->B53_CODOPE+B72->B72_CODGLO,"BCT_DESCRI"),;
					B72->B72_MOTIVO + " - " + Posicione("SX5",1, xFilial("SX5") + "BU" + B72->B72_MOTIVO,"X5DESCRI()"),;
					B72->B72_VLRAUT,;
					B72->B72_QTDAUT,;
					B72->B72_OBSANA} )

				//Adiciono colunas da DUT se houver os campos
				if lExiDUT

					nPosCodDut := len(aMatDad[len(aMatDad)]) + 1
					nPosCodSub := nPosCodDut + 1

					BRW->(DbSetOrder(1))//BRW_FILIAL+BRW_CODROL
					if BRW->(MsSeek(xFilial("BRW")+B72->B72_CODPRO)) .And. !Empty(BRW->BRW_TABDUT) .And. !Empty(BRW->BRW_CODDUT)
						Aadd(aMatDad[len(aMatDad)],BRW->BRW_CODDUT)
						Aadd(aMatDad[len(aMatDad)],BRW->BRW_DUTSUB)
					else
						Aadd(aMatDad[len(aMatDad)],"")
						Aadd(aMatDad[len(aMatDad)],"")
					endIf
				endIf

				B72->( DbSkip() )
			EndDo

		EndIf

		oGEN:Destroy()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Mostra os dados															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aMatDad) > 0

			nTam := Len( aMatDad[1] )

			DEFINE MSDIALOG oDlg TITLE "Histórico de auditoria" FROM  0,5 TO 503,959 of oMainWnd Pixel //"Criticas da autorizacao"

			oBrw := TcBrowse():New( 33,3,473,142,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)

			oBrw:AddColumn(TcColumn():New(FWX3Titulo("B72_DATMOV"), {|| aMatDad[oBrw:nAt,1] },"@D",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))
			oBrw:AddColumn(TcColumn():New(FWX3Titulo("B72_OPERAD"), {|| OemToAnsi(aMatDad[oBrw:nAt,2]) },"@!",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
			oBrw:AddColumn(TcColumn():New(FWX3Titulo("B72_PARECE"), {|| OemToAnsi(aMatDad[oBrw:nAt,3]) },"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
			oBrw:AddColumn(TcColumn():New(FWX3Titulo("B72_CODPRO"), {|| OemToAnsi(aMatDad[oBrw:nAt,5]) },"@!",nil,nil,nil,180,.F.,.F.,nil,nil,nil,.F.,nil))
			oBrw:AddColumn(TcColumn():New(FWX3Titulo("B72_DESGLO"), {|| OemToAnsi(aMatDad[oBrw:nAt,6]) },"@!",nil,nil,nil,180,.F.,.F.,nil,nil,nil,.F.,nil))
			oBrw:AddColumn(TcColumn():New(FWX3Titulo("B72_VLRAUT"), {|| aMatDad[oBrw:nAt,8] },"@E 999,999,999.9999",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
			oBrw:AddColumn(TcColumn():New(FWX3Titulo("B72_QTDAUT"), {|| aMatDad[oBrw:nAt,9] },"9999.99",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))

			Aadd(aCampos,"B72_DATMOV")
			Aadd(aCampos,"B72_OPERAD")
			Aadd(aCampos,"B72_PARECE")
			Aadd(aCampos,"B72_CODPAD + B72_CODPRO")
			Aadd(aCampos,"BR8_DESCRI")
			Aadd(aCampos,"B72_VLRAUT")
			Aadd(aCampos,"B72_QTDAUT")
			//Adiciono colunas da DUT se houver os campos
			if lExiDUT .And. nPosCodDut > 0 .And. nPosCodSub > 0
				oBrw:AddColumn(TcColumn():New(FWX3Titulo("BRW_CODDUT"), {|| OemToAnsi(aMatDad[oBrw:nAt,nPosCodDut]) },"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
				oBrw:AddColumn(TcColumn():New(FWX3Titulo("BRW_DUTSUB"), {|| OemToAnsi(aMatDad[oBrw:nAt,nPosCodSub]) },"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
				Aadd( aButtons, {"HISTORIC", {|| PL790DUTHI(oBrw,aMatDad)}, "DUT", "DUT" , {|| .T.}} )
				Aadd(aCampos,"BRW_CODDUT")
				Aadd(aCampos,"BRW_DUTSUB")
			endIf

			//-------------------------------------------------------------------
			//  LGPD
			//-------------------------------------------------------------------
			if objCENFUNLGP:isLGPDAt()
				aBls := objCENFUNLGP:getTcBrw(aCampos)

				oBrw:aObfuscatedCols := aBls
				objCENFUNLGP:useLogUser()
			endif

			oBrw:SetArray(aMatDad)
			oBrw:bChange    := {|| cMemo := aMatDad[oBrw:nAt,10], Eval(oMemo:bSetGet),oMemo:Refresh() }
			cMemo 			:= aMatDad[oBrw:nAt,10]

			@ 183 ,3 SAY "Motivo:" PIXEL SIZE 55,9 OF oDlg

			oMemo := TMultiGet():New(193,3,;
				{|u| If( PCount()>0, cMemo:=u, cMemo ) },oDlg,473,53,,,,,,.T.,,,,,,.T.)
			oMemo:lWordWrap := .T.

			if objCENFUNLGP:isLGPDAt()
				lObfs := objCENFUNLGP:getTGet("B72_OBSANA")
				oMemo:lObfuscate := lObfs
			endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Ativa o dialogo...
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons,,,,,,.F.) } )
		Else
			MsgAlert("Não existe movimentação")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Fim da Rotina															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Return
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETCBOX		ºAutor  ³Totvs           º Data ³  22/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Retorna o conteudo ou uma matriz do box do campo		 	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function RETCBOX(cCampo,cConteudo,lAutoma)
		LOCAL nI 	:= 0
		LOCAL aRet  := {}
		LOCAL cRet	:= ""
		Local nTamCpo	:= 1
		Default lAutoma	:= .F.

		If lAutoma
			nTamCpo := 2
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Monta matriz do box
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		aRet := RetSx3Box( X3CBox( Posicione('SX3',2,cCampo,'X3_CBOX') ),,,nTamCpo )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Verifica se o conteudo existe
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		nPos := aScan(aRet,{|x| x[2] = cConteudo})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Retorna o texto
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If nPos>0
			cRet := AllTrim(aRet[nPos,3])
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Fim da Rotina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Return(cRet)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLR997Fil ºAutor  ³Microsiga           º Data ³  01/16/12       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Função para montar Pagamentos efetuados para calculo do        º±±
±±º       Demonstrativo de imposto de Renda  Folha Pagam e Contas Receberº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

Function PLR997Fil(cOper,cEmpDe,cEmpAte,cConDe,cConAte,cSubDe,cSubAte,cMatDe,cMatAte,nAno,nTipo,nListar,lWeb,lReemb)
		Local 	cQuery	:=	""
		Local 	nValor	:=	0
		Local 	nValorJ	:=0
		local	nValorD	:=0
		local	nvalSald:=0
		Local 	nPos1	:=	0
		Local 	lFlag   := .F.
		Local 	aRecDes	:=	{}
		Local 	arecDes1:=	{}
		Local 	cSE5Pre := 	""
		Local 	cSE5Num :=	""
		Local 	cSE5Parc :=	""
		Local 	cSE5Tipo :=	""
		Local	aRecDesT :=	{}
		Local 	aRecDesR := {}
		Local 	aInfReem := {}
		Local 	aRecDes3:=	{}
		Local	cSrcNumCo:=	""
		Local 	nperc	:=0
		Local 	npercJ	:=1
		Local 	npercD	:=1
		Local 	npercM	:=0
		Local 	aRecSE5	:=	{}
		Local 	aRecDes2:=	{}
		Local   cTpDoc	 := GetNewPar('MV_PLDM001','VL') //Indica quais tipos de titulos o sistema deve considerar para somatoria do valor financeiro. Sem parâmetro considera o tipo 'VL' (E5_TIPODOC)
		Local 	cTpBaixa := GetNewPar('MV_PLDM002','DAC') //Indica motivos de baixa de títulos a receber que não serão considerados no valor financeiro. Sem o parâmetro considera o motivo DAC - E5_MOTBX
		Local 	cCodNEve := GetNewPar("MV_PLDM003","") //Indica códigos de lançamentos de cobrança que não serão considerados na composição do custo BM1_CODTIP
		Local 	cCodEve	 := GetNewPar("MV_PLDM004","") //Indica códigos de eventos de lançamentos da cobrança que não serão considerados na composição do custo BM1_CODEVE
		Local 	cTpLanc  := GetNewPar("MV_PLDM006","") //Verbas da gestão de pessoal que não deverão ser consideradas para geração da DMED
		Local 	lRetSe5	 :=.T.
		Local 	lRetBM1:= .T.
		Local	cDtBaixa :=Space(TamSx3("E1_BAIXA")[1])
		Local 	nSaldo:=0
		Local cSe5Ano	:=0
		Local cSe5Mes	:=""
		Local nDifer	:=1
		Local nValbm1:=0
		Local nItebm1:=0
		Local nI:=0
		local aRegSE5:={}
		lOCAL nSe5	:=0
		Local lJur	:=.f.
		Local aCliReemb := {}
		Local nLenSE5   := 0
		Local nMesPago := 0
		Local cMesCompetencia := ""
		Local cAnoCompetencia := ""
		Local cMesPagamento := ""
		Local cAnoPagamento := ""
		Local aCompetencia := {{},{},{},{},{},{},{},{},{},{},{},{}}
		Local cFamilia := ""
		Local cSubstringSql := IIf(AllTrim(TCGetDB()) $ "ORACLE|DB2|POSTGRES", "SUBSTR", "SUBSTRING")
		Local lRetReembSE2 := .T.
		Local nMesPosReemb := 0
		Local nPosReemb := 0
		Local nForArray := 0
		Local nForArrayAux := 0
		
		Default cOper	:=	""
		Default cEmpDe	:=	""
		Default cEmpAte	:=	""
		Default cConDe	:=	""
		Default cConAte	:=	""
		Default cSubDe	:=	""
		Default cSubAte	:=	""
		Default cMatDe	:=	""
		Default cMatAte	:=	""
		Default nAno	:=	""
		Default nTipo	:=	""
		Default nListar	:=	""
		Default lReemb	:= .T.

		cTpDoc   := IIf(!Empty(cTpDoc),"'" + Replace(AllTrim(cTpDoc),",","','") + "'","")
		cTpBaixa := IIf(!Empty(cTpBaixa),"'" + Replace(AllTrim(cTpBaixa),",","','") + "'","")
		cTpLanc  := IIf(!Empty(cTpLanc),"'" + Replace(AllTrim(cTpLanc),",","','") + "'","")
		cCodNeve := IIf(!Empty(cCodNeve),"'" + Replace(AllTrim(cCodNEve),",","','") + "'","")
		cCodEve  := IIf(!Empty(cCodEve),"'" + Replace(AllTrim(cCodEve),",","','") + "'","")

		//BUSCA INFORMAÇÕES REFERENTE A SE1- CONTAS A RECEBER

		cQuery += "SELECT     DISTINCT BBT.BBT_CODOPE, BBT.BBT_CODEMP, BBT.BBT_CONEMP, BBT.BBT_VERCON,BBT.BBT_SUBCON, BBT.BBT_VERSUB ,SE1.E1_CLIENTE,   "
		cQuery += "           SE1.E1_LOJA, SE1.E1_CODEMP, SE1.E1_MATRIC,SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_BAIXA, "
		cQuery += "			  SE1.E1_PREFIXO PREFIXO, SE1.E1_TIPO TIPO, SE1.E1_NUM NUMERO, SE5.E5_VALOR,SE5.E5_PARCELA PARC,SE1.E1_CLIENTE CLIENTE,SE1.E1_VALJUR ,SE5.E5_DTDIGIT E5DATA    "
		cQuery += "   FROM  "+ RetSqlName("BBT")+" BBT "
		cQuery += "   JOIN " + RetSqlName("SE1") + "  SE1 ON BBT.BBT_CLIFOR = SE1.E1_CLIENTE AND BBT.BBT_PREFIX=SE1.E1_PREFIXO  AND  BBT.BBT_NUMTIT = SE1.E1_NUM   "
		cQuery += "   AND E1_FILIAL='" + xFilial("SE1") +"' AND SE1.D_E_L_E_T_ = ''  "
		cQuery += "   JOIN "+ RetSqlName("SE5") +"  SE5 ON SE1.E1_CLIENTE = SE5.E5_CLIENTE AND SE1.E1_PREFIXO = SE5.E5_PREFIXO AND SE1.E1_PARCELA = SE5.E5_PARCELA AND SE1.E1_NUM = SE5.E5_NUMERO  "
		cQuery += "   AND  SE1.E1_LOJA = SE5.E5_LOJA AND SE1.E1_BAIXA <> '"+ cDtBaixa  +"' AND SE5.E5_FILIAL='" + xFilial("SE5") +"'  AND SE5.D_E_L_E_T_ = '' "
		If !Empty(cTpDoc)
			cQuery += "AND SE5.E5_TIPODOC IN ("+cTpDoc+") "
		EndIf

		If !Empty(cTpBaixa)
			cQuery += "AND SE5.E5_MOTBX NOT IN ("+cTpBaixa+") "
		EndIf
		cQuery += "   AND "+cSubstringSql+"(SE5.E5_DATA  ,1,4)    = '" + cvaltochar(nAno)   + "' "
		cQuery += "   WHERE BBT_FILIAL  = '" + xFilial("BBT") + "' "
		cQuery += "   AND BBT.BBT_CODOPE =  '" + cOper     + "' "
		cQuery += "   AND BBT.BBT_CODEMP >= '" + cEmpDe    + "' AND BBT.BBT_CODEMP <= '" + cEmpAte + "' "
		cQuery += "   AND BBT.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY SE1.E1_CLIENTE, SE1.E1_PREFIXO, SE1.E1_TIPO, SE1.E1_NUM, SE1.E1_BAIXA "

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB2",.F.,.T.)

		If TRB2->(Eof())
			lRetSe5	 :=.F.
		Endif

		TRB2->(DbCloseArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Levantamento da Composição
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nVlrBx  := 0
		nVlrBM1 := 0
		aRegSE5 := {}

		If lRetSe5

			cSQL := " SELECT E5_VALOR, E5_RECPAG, E5_DATA, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_TIPODOC, E5_CLIFOR, E5_LOJA, E5_DOCUMEN "
			cSQL += " FROM " + RetSQLName("SE5") + " SE5 "

			cSql += " INNER JOIN " + RetSQLName("SE1") + " SE1 "
			cSql += "   ON SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
        	cSql += "  AND SE1.E1_PREFIXO = SE5.E5_PREFIXO" 
            cSql += "  AND SE1.E1_NUM = SE5.E5_NUMERO"  
            cSql += "  AND SE1.E1_PARCELA = SE5.E5_PARCELA"  
            cSql += "  AND SE1.E1_TIPO = SE5.E5_TIPO"  
            cSql += "  AND SE1.E1_CLIENTE = SE5.E5_CLIENTE"
			cSql += "  AND SE1.E1_LOJA = SE5.E5_LOJA"
			cSQL += "  AND SE1.E1_BAIXA <> '"+cDtBaixa+"'"
			cSQL += "  AND SE1.D_E_L_E_T_ = ' ' "

			cSql += " INNER JOIN " + RetSQLName("BBT") + " BBT "
			cSql += "   ON BBT.BBT_FILIAL = '"+xFilial("BBT")+"'"
        	cSql += "  AND BBT.BBT_PREFIX = SE1.E1_PREFIXO"
            cSql += "  AND BBT.BBT_NUMTIT =  SE1.E1_NUM"  
            cSql += "  AND BBT.BBT_PARCEL = SE1.E1_PARCELA"  
            cSql += "  AND BBT.BBT_TIPTIT = SE1.E1_TIPO"  
			cSQL += "  AND BBT.BBT_CODOPE = '"+cOper+"' "
			cSQL += "  AND BBT.BBT_CODEMP BETWEEN '"+cEmpDe+ "' AND '"+cEmpAte+"' "
			cSQL += "  AND BBT.BBT_MATRIC BETWEEN '"+cMatDe+ "' AND '"+cMatAte+"' "
			cSQL += "  AND BBT.D_E_L_E_T_ = ' ' "

			cSQL += " WHERE E5_FILIAL = '" +xFilial("SE5")+ "' "

			cSQL += "  AND "+cSubstringSql+"(SE5.E5_DATA, 1, 4) = '"+cvaltochar(nAno)+"' "

			If !Empty(cTpDoc)
				cSQL += "AND SE5.E5_TIPODOC IN ("+cTpDoc+") "
			EndIf
			If !Empty(cTpBaixa)
				cSQL += "AND SE5.E5_MOTBX NOT IN ("+cTpBaixa+") "
			EndIf
			cSQL += " AND SE5.E5_SITUACA <> 'C'"
			
			cSQL += " AND NOT EXISTS"
			cSQL += " (SELECT ES.E5_NUMERO FROM " + RetSQLName("SE5") + " ES" 
			cSQL += "  	WHERE SE5.E5_FILIAL = ES.E5_FILIAL"
			cSQL += "     AND SE5.E5_PREFIXO = ES.E5_PREFIXO" 
			cSQL += "     AND SE5.E5_NUMERO = ES.E5_NUMERO" 
			cSQL += "     AND SE5.E5_PARCELA = ES.E5_PARCELA" 
			cSQL += "     AND SE5.E5_TIPO = ES.E5_TIPO" 
			cSQL += "     AND SE5.E5_CLIFOR = ES.E5_CLIFOR" 
			cSQL += "     AND SE5.E5_LOJA = ES.E5_LOJA" 
			cSQL += "     AND SE5.E5_SEQ = ES.E5_SEQ" 
			cSQL += "     AND ES.E5_TIPODOC = 'ES'" 
			cSQL += "     AND ES.E5_RECPAG <> SE5.E5_RECPAG" 
			cSQL += "     AND ES.D_E_L_E_T_ = ' '"
			cSQL += " )"

			cSQL += " AND SE5.E5_TIPODOC <> 'ES'" 
			cSQL += " AND SE5.D_E_L_E_T_ = ' '   "
			
			cSQL += " ORDER BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_VALOR"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBANA",.T.,.F.)

			While !TRBANA->(Eof())

				If AllTrim(TRBANA->E5_RECPAG) == "P"
					aAdd(aRegSE5,{0,TRBANA->E5_VALOR, TRBANA->E5_RECPAG,TRBANA->E5_DATA,TRBANA->E5_PREFIXO,TRBANA->E5_NUMERO,TRBANA->E5_PARCELA,TRBANA->E5_TIPO,TRBANA->E5_TIPODOC,TRBANA->E5_CLIFOR,TRBANA->E5_LOJA,TRBANA->E5_DOCUMEN})			
				Else
					aAdd(aRegSE5,{TRBANA->E5_VALOR,0, TRBANA->E5_RECPAG,TRBANA->E5_DATA,TRBANA->E5_PREFIXO,TRBANA->E5_NUMERO,TRBANA->E5_PARCELA,TRBANA->E5_TIPO,TRBANA->E5_TIPODOC,TRBANA->E5_CLIFOR,TRBANA->E5_LOJA,TRBANA->E5_DOCUMEN})
				EndIf

				nSe5 := Len(aRegSE5)

				nVlrBx += aRegSE5[nSe5,1]
				nVlrBx -= aRegSE5[nSe5,2]

				iF aRegSE5[nSe5][1] == 0
					TRBANA->(DbSkip())
					Loop
				Endif

				cSql := " SELECT BM1_SEQ,BM1_CODEMP, BM1_CONEMP,BM1_VERCON, BM1_SUBCON,BM1_VERSUB, BM1_MATRIC, BM1_TIPREG, BM1_ANO, BM1_MES, BM1_TIPO,BM1_CODTIP,BM1_DESTIP, BM1_VALOR VALOR,BM1_PREFIX,BM1_NUMTIT,BM1_PARCEL,BM1_TIPTIT "

				cSql += "FROM "+RetSqlName("BM1")+" BM1 "
				cSql += "WHERE BM1.BM1_FILIAL = '"+xFilial("BM1")+"' "
				cSql += "   AND BM1.BM1_CODINT =  '" + cOper + "' "
				cSql += "   AND BM1.BM1_PREFIX =  '" + aRegSE5[nSe5][5] + "' "
				cSql += "   AND BM1.BM1_NUMTIT =  '" + aRegSE5[nSe5][6] + "' "
				cSql += "   AND BM1.BM1_PARCEL =  '" + aRegSE5[nSe5][7] + "' "
				cSql += "   AND BM1.BM1_TIPTIT =  '" + aRegSE5[nSe5][8] + "' "
				
				If !Empty(AllTrim(cTpLanc))
					cSql += "AND BM1.BM1_CODTIP NOT IN (" + cTpLanc + ") " // MV_PLDM006 Verbas da gestão de pessoal que não deverão ser consideradas para geração do Relatorio
				EndIf

				If !Empty(AllTrim(cCodNEve))
					cSql += "AND BM1.BM1_CODEVE NOT IN (" + cCodNEve + ") " // MV_PLDM003 Indica códigos de lançamentos de cobrança que não serão considerados na composição do custo BM1_CODTIP
				EndIf

				If !Empty(AllTrim(cCodEve))
					cSql += "AND BM1.BM1_CODEVE IN (" + cCodEve + ") " //MV_PLDM004 Indica códigos de eventos de lançamentos da cobrança que não serão considerados na composição do custo BM1_CODEVE
				EndIf

				cSql += "   AND BM1.BM1_CODINT =  '" + cOper + "' "
				cSql += "   AND BM1.BM1_CODEMP >= '" + cEmpDe + "' AND BM1.BM1_CODEMP <= '" + cEmpAte + "' "
				cSql += "   AND BM1.BM1_CONEMP >= '" + cConDe + "' AND BM1.BM1_CONEMP <= '" + cConAte + "' "
				cSql += "   AND BM1.BM1_VERCON >= '   ' "
				cSql += "   AND BM1.BM1_SUBCON >= '" + cSubDe + "' AND BM1.BM1_SUBCON <= '" + cSubAte + "' "
				cSql += "   AND BM1.BM1_VERSUB >= '   ' "
				cSql += "   AND BM1.BM1_MATRIC >= '" + cMatDe + "' AND BM1.BM1_MATRIC <= '" + cMatAte + "' "
				cSql += "   AND BM1.D_E_L_E_T_ = ' ' "

				cSql += " ORDER BY BM1_NUMTIT,BM1_PREFIX,BM1_PARCEL,BM1_CODEMP, BM1_CONEMP,BM1_VERCON, BM1_SUBCON,BM1_VERSUB, BM1_MATRIC, BM1_TIPREG, BM1_ANO, BM1_MES, BM1_TIPO "

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB",.F.,.T.)

				If TRB->(!Eof())
					While ! TRB->(EOF())

						cMesCompetencia := TRB->BM1_MES
						cAnoCompetencia := TRB->BM1_ANO

						nValbm1+= iif(TRB->BM1_TIPO <> "1",(TRB->VALOR *-1),TRB->VALOR)
						nItebm1++

						TRB->(dbskip())
					Enddo


					TRB->( dbGotop() )
					While !TRB->(EOF())
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Verifica se eh debito ou credito
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aRegSE5[nSe5][1] < nValbm1
							nDifer := nValbm1 / aRegSE5[nSe5][1]
						Else
							nDifer := 1
						Endif
						

						If TRB->BM1_TIPO <> "1"
							nValor := TRB->VALOR * -1
						Else
							nValor := TRB->VALOR / nDifer
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Posiciona array
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Verifica se o Subcontrato Possui  Participação da Empresa
						//se Sim o Valor pago  é  Diferenciado com a Porcentagem da participacao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BQC->( DbSetorder(01) )//BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
						IF BQC->( MsSeek( xFilial("BQC")+cOper+TRB->BM1_CODEMP+TRB->BM1_CONEMP+TRB->BM1_VERCON + TRB->BM1_SUBCON + TRB->BM1_VERSUB) )
							If	BQC->(FieldPos("BQC_PERPAT")) > 0
								If  BQC->BQC_PATROC =='1'
									BFQ->(DbSetOrder(1))
									BFQ->(MsSeek(xFilial("BFQ")+cOper+TRB->BM1_CODTIP))
									If  BFQ->BFQ_PATROC =='1
										nperc:= (100 - BQC->BQC_PERPAT)/100
										nValor:=nValor*nperc
									Endif
								Endif
							Endif
						Endif

						// Compensação/NCC pega o mês do título baixado
						If aRegSE5[nSe5][9] == "CP" .Or. aRegSE5[nSe5][8] == "NCC"
							
							nMesPago := GetMesPagTitulo(aRegSE5[nSe5][5], aRegSE5[nSe5][6], aRegSE5[nSe5][7], aRegSE5[nSe5][8], aRegSE5[nSe5][12])

							If nMesPago == 0
								nMesPago := Val(Substr(aRegSE5[nSe5][4], 5, 2))
							EndIf
						Else
							nMesPago := Val(Substr(aRegSE5[nSe5][4], 5, 2))
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Posiciona o titulo para calculo da Taxa permanencia e Juros
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aRegSE5[nSe5,9]$'MT,JR,DC'
							lJur:=.T.
							nValorJ:=(aRegSE5[nSe5,1] / nItebm1 )
							IF aRegSE5[nSe5,9]='DC'
								nValorJ:=nValorJ * -1
							Endif

							If 	!Empty(nValorJ)
								nPos1 := aScan(aRecDesT,{|x| (x[1] == TRB->BM1_CODEMP .and. ;
									x[2] == TRB->BM1_CONEMP .and. ;
									x[3] == TRB->BM1_SUBCON .and. ;
									x[4] == TRB->BM1_MATRIC .and. ;
									x[5] == TRB->BM1_TIPREG .and. ;
									x[6] == IIF(aRegSE5[nSe5,9]='MT', "991",IIF(aRegSE5[nSe5,9]='JR' ,"992","993 ")) )})
								If  nPos1 == 0
									aadd(aRecDesT,{TRB->BM1_CODEMP,TRB->BM1_CONEMP,TRB->BM1_SUBCON,TRB->BM1_MATRIC,TRB->BM1_TIPREG,IIF(aRegSE5[nSe5,9]='MT', "991",IIF(aRegSE5[nSe5,9]='JR' ,"992","993 ")), IIF(aRegSE5[nSe5,9]='MT', "Multa Financeiro    ",IIF(aRegSE5[nSe5,9]='JR' ,"Juros Financeiro    ","Desconto Financeiro ")),lFlag,;
										0,0,0,0,0,0,0,0,0,0,0,0,;
										0,0,0,0,0,0,0,0,0,0,0,0,;
										0,0,0,0,0,0,0,0,0,0,0,0})
									nPos1 := len(aRecDesT)
									aRecDesT[nPos1,8+val(SUBSTR(aRegSE5[nSe5][4],5,2))] :=  nValorJ
								Else
									aRecDesT[nPos1,8+val(SUBSTR(aRegSE5[nSe5][4],5,2))] += nValorJ
								Endif
							Endif

						EndIf



						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Posiciona array para Incluir a soma total da Familia
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPos1 := aScan(aRecDes,{|x| (x[1] == TRB->BM1_CODEMP .and. ;
							x[2] == TRB->BM1_CONEMP .and. ;
							x[3] == TRB->BM1_SUBCON .and. ;
							x[4] == TRB->BM1_MATRIC .and. ;
							x[5] == "")})
						If  nPos1 == 0
							aadd(aRecDes,{TRB->BM1_CODEMP,TRB->BM1_CONEMP,TRB->BM1_SUBCON,TRB->BM1_MATRIC,"","","",lFlag,;
								0,0,0,0,0,0,0,0,0,0,0,0,;
								0,0,0,0,0,0,0,0,0,0,0,0,;
								0,0,0,0,0,0,0,0,0,0,0,0})
							nPos1 := len(aRecDes)
							If lJur
								aRecDes[nPos1,8+val(SUBSTR(aRegSE5[nSe5][4],5,2))] += nValorJ
							Else
								aRecDes[nPos1,8+nMesPago] += nValor
							Endif

						Else
							If lJur
								aRecDes[nPos1,8+val(SUBSTR(aRegSE5[nSe5][4],5,2))] += nValorJ
							Else
								aRecDes[nPos1,8+nMesPago] += nValor
							Endif
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Posiciona array para Incluir a soma total por Beneficiario
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If  nListar == 1
							lFlag := .T.
						Else
							lFlag := .F.
						Endif
						nPos1 := aScan(aRecDes,{|x| (x[1] == TRB->BM1_CODEMP .and. ;
							x[2] == TRB->BM1_CONEMP .and. ;
							x[3] == TRB->BM1_SUBCON .and. ;
							x[4] == TRB->BM1_MATRIC .and. ;
							x[5] == TRB->BM1_TIPREG)})
						If  nPos1 == 0
							aadd(aRecDes,{TRB->BM1_CODEMP,TRB->BM1_CONEMP,TRB->BM1_SUBCON,TRB->BM1_MATRIC,TRB->BM1_TIPREG,"","",lFlag,;
								0,0,0,0,0,0,0,0,0,0,0,0,;
								0,0,0,0,0,0,0,0,0,0,0,0,;
								0,0,0,0,0,0,0,0,0,0,0,0})
							nPos1 := len(aRecDes)
						Endif
						if lJur
							aRecDes[nPos1,8+val(SUBSTR(aRegSE5[nSe5][4],5,2))] += nValorJ
						Else
							aRecDes[nPos1,8+nMesPago] += nValor
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Posiciona array para Incluir Os itens de Registro Referente ao BM1 por  Beneficiario  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPos1 := aScan(aRecDesT,{|x| (x[1] == TRB->BM1_CODEMP .and. ;
							x[2] == TRB->BM1_CONEMP .and. ;
							x[3] == TRB->BM1_SUBCON .and. ;
							x[4] == TRB->BM1_MATRIC .and. ;
							x[5] == TRB->BM1_TIPREG .and. ;
							x[6] == TRB->BM1_CODTIP  )})


						If  nPos1 == 0
							aadd(aRecDesT,{TRB->BM1_CODEMP,TRB->BM1_CONEMP,TRB->BM1_SUBCON,TRB->BM1_MATRIC,TRB->BM1_TIPREG,TRB->BM1_CODTIP,TRB->BM1_DESTIP,lFlag,;
								0,0,0,0,0,0,0,0,0,0,0,0,;
								0,0,0,0,0,0,0,0,0,0,0,0,;
								0,0,0,0,0,0,0,0,0,0,0,0})
							nPos1 := len(aRecDesT)
							If  !lJur
								aRecDesT[nPos1,8+nMesPago] := nValor
							Else
								aRecDesT[nPos1,8+val(SUBSTR(aRegSE5[nSe5][4],5,2))] := nValorJ
							Endif

						Else
							If  !lJur
								aRecDesT[nPos1,8+nMesPago] += nValor
							Else
								aRecDesT[nPos1,8+val(SUBSTR(aRegSE5[nSe5][4],5,2))] += nValorj
							Endif
						Endif

						cMesPagamento := Substr(aRegSE5[nSe5][4], 5, 2)
						cAnoPagamento := Substr(aRegSE5[nSe5][4], 1, 4)
						cFamilia := TRB->(BM1_CODEMP + BM1_CONEMP + BM1_SUBCON + BM1_MATRIC)
						
						If (cMesPagamento + cAnoPagamento) <> (cMesCompetencia + cAnoCompetencia) .And. (!Empty(cMesCompetencia) .And. !Empty(cAnoCompetencia))

							If Len(aCompetencia[val(cMesPagamento)]) == 0 .Or. aScan(aCompetencia[Val(cMesPagamento)], {|x| (x[1] == cMesCompetencia .And. x[2] == cAnoCompetencia .And. x[3] == cFamilia)}) == 0

								aAdd(aCompetencia[Val(cMesPagamento)], {cMesCompetencia, cAnoCompetencia, cFamilia})

							EndIf
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//Acessa proximo registro
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						npercJ:=1
						npercD:=1
						nValorD:=0
						nValorJ:=0
						lJur	:=.f.
						
						cMesCompetencia := ""
						cAnoCompetencia := ""

						TRB->(dbSkip())
					EndDo
				EndIf

				TRB->(DbCloseArea())

				nValbm1:=0
				nItebm1:=0
				nItebm1:=0
				nDifer:=1
				nValor:=0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Posiciona array para Incluir o Reembolso por Beneficiario caso já 	³
				//³	não tenha incluso. Preenche-se o array aRecDesR para o Beneficiario	³
				//³	uma so vez com todos os reembolso durante o ano.	   				³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lReemb .AND. ( aScan(aCliReemb,{|x| (x[1] == aRegSE5[nSe5][10] .and. x[2] == aRegSE5[nSe5][11])}) = 0 )

					aAdd(aCliReemb,{aRegSE5[nSe5][10],aRegSE5[nSe5][11]})

					cQuery := "	SELECT	B44.B44_CODEMP,B44.B44_CONEMP,B44.B44_SUBCON,B44.B44_MATRIC,B44.B44_TIPREG, "
					cQuery += " 	B44.B44_VLRPAG,B44.B44_VLRGLO,B44.B44_VLRPAG+B44_VLRGLO+B44_VLABPF B44TOTAL,SE5.E5_DATA, "
					cQuery += " 	B44.B44_OPEEXE, B44_REGEXE, B44.B44_ESTEXE, B44.B44_SIGEXE, B44.B44_CDPFRE "
					cQuery += " FROM  "+ RetSqlName("SE5")+" SE5 "
					cQuery += " INNER JOIN " + RetSqlName("B44") + " B44 "
					cQuery += " 	ON B44.B44_FILIAL = '" + xFilial("B44") + "' "
					cQuery += " 	AND B44.B44_PREFIX = SE5.E5_PREFIXO AND B44.B44_NUM= SE5.E5_NUMERO AND B44.B44_PARCEL = SE5.E5_PARCELA "
					cQuery += " 	AND B44.B44_TIPO = SE5.E5_TIPO AND B44.B44_CODCLI = SE5.E5_CLIFOR AND B44.B44_LOJA = SE5.E5_LOJA "
					cQuery += " 	AND B44.B44_OPEUSR =  '" + cOper  + "' "
					cQuery += "		AND B44.B44_CODEMP >= '" + cEmpDe + "' AND B44.B44_CODEMP <= '" + cEmpAte + "' "
					cQuery += " 	AND B44.D_E_L_E_T_ = ' ' "
					cQuery += " WHERE SE5.E5_FILIAL = '" + xFilial("SE5") + "' "
					cQuery += " 	AND SE5.E5_TIPO = 'NCC' "
					cQuery += " 	AND SE5.E5_CLIFOR	= '"+ aRegSE5[nSe5][10] +"' "
					cQuery += " 	AND SE5.E5_LOJA		= '"+ aRegSE5[nSe5][11] +"' "
					cQuery += " 	AND SUBSTRING(SE5.E5_DATA ,1,4) = '" + cValToChar(nAno) + "' "
					cQuery += " 	AND SE5.D_E_L_E_T_ = ' ' "

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBREM",.F.,.T.)

					While !TRBREM->(Eof())
						nPos1 := aScan(aRecDesR,{|x| (x[1] == TRBREM->B44_CODEMP .and. ;
							x[2] == TRBREM->B44_CONEMP .and. ;
							x[3] == TRBREM->B44_SUBCON .and. ;
							x[4] == TRBREM->B44_MATRIC .and. ;
							x[5] == TRBREM->B44_TIPREG)})
						If  nPos1 == 0
							aadd(aRecDesR,{TRBREM->B44_CODEMP,TRBREM->B44_CONEMP,TRBREM->B44_SUBCON,TRBREM->B44_MATRIC,TRBREM->B44_TIPREG,"","",.F.,;
								{},{},{},{},{},{},{},{},{},{},{},{}})
							nPos1 := Len(aRecDesR)
						Endif
						IF !EMPTY(TRBREM->B44_CDPFRE)
							aInfReem := { 																		;
								Posicione("BB0",1,xFilial("BB0")+TRBREM->B44_CDPFRE,"BB0_NOME"),				;
								Posicione("BB0",1,xFilial("BB0")+TRBREM->B44_CDPFRE,"BB0_CGC"),				;
								TRBREM->B44TOTAL,																;
								TRBREM->B44_VLRPAG																;
								}
						Else
							aInfReem := { 																		;
								Posicione("BB0",4,xFilial("BB0")+TRBREM->(B44_ESTEXE+B44_REGEXE+B44_SIGEXE),"BB0_NOME"),				;
								Posicione("BB0",4,xFilial("BB0")+TRBREM->(B44_ESTEXE+B44_REGEXE+B44_SIGEXE),"BB0_CGC"),				;
								TRBREM->B44TOTAL,																;
								TRBREM->B44_VLRPAG																;
								}
						EndIF
						aAdd( aRecDesR[nPos1,8+val(SUBSTR(TRBREM->E5_DATA,5,2))], aInfReem)
						TRBREM->(dbSkip())
					EndDo

					TRBREM->(DbCloseArea())
				EndIf
			
				TRBANA->(dbSkip())
			EndDo

			TRBANA->(dbCloseArea())

		EndIf

		nLenSE5 := Len(aRegSE5)

		If nLenSE5 == 0
			//caso não encontre os titulos verifica se houve cobrança pela folha de pagamento
			cSql := "SELECT BM1_SEQ,BM1_CODEMP, BM1_CONEMP,BM1_VERCON, BM1_SUBCON,BM1_VERSUB, BM1_MATRIC, BM1_TIPREG, BM1_CODTIP, "
			cSql += "BM1_VALOR, BM1_TIPO, BM1_ANO, BM1_MES "
			cSql += "FROM "+RetSqlName("BM1")+" BM1 "
			cSql += "WHERE BM1.BM1_FILIAL = '"+xFilial("BM1")+"' "
			cSql += "AND BM1.BM1_CODINT =  '" + cOper + "' "
			cSql += "AND BM1.D_E_L_E_T_ = ' ' "
			cSql += "AND BM1.BM1_CODINT =  '" + cOper  + "' "
			cSql += "AND BM1.BM1_CODEMP >= '" + cEmpDe + "' AND BM1.BM1_CODEMP <= '" + cEmpAte + "' "
			cSql += "AND BM1.BM1_CONEMP >= '" + cConDe + "' AND BM1.BM1_CONEMP <= '" + cConAte + "' "
			cSql += "AND BM1.BM1_VERCON >= '   ' "
			cSql += "AND BM1.BM1_SUBCON >= '" + cSubDe + "' AND BM1.BM1_SUBCON <= '" + cSubAte + "' "
			cSql += "AND BM1.BM1_VERSUB >= '   ' "
			cSql += "AND BM1.BM1_MATRIC >= '" + cMatDe + "' AND BM1.BM1_MATRIC <= '" + cMatAte + "' "
			cSql += "AND BM1_ANO         = '" + nAno + "' "
			cSql += "ORDER BY BM1_NUMTIT,BM1_PREFIX,BM1_PARCEL,BM1_CODEMP, BM1_CONEMP,BM1_VERCON, BM1_SUBCON,BM1_VERSUB, BM1_MATRIC, "
			cSql += "BM1_TIPREG, BM1_ANO, BM1_MES, BM1_TIPO "

			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB",.F.,.T.)

			If TRB->(Eof())
				lRetBM1:= .F.
			EndIf
			
			While ! TRB->(EOF())


				//Não pode contabilizar reembolso nem a cobrança PATRONAL
				If TRB->BM1_CODTIP != "108" .And. TRB->BM1_CODTIP != "186"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Verifica se eh debito ou credito
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					If  TRB->BM1_TIPO <> "1"
						nValor := TRB->BM1_VALOR * -1
					Else
						nValor := TRB->BM1_VALOR
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Verifica se o Subcontrato Possui  Participação da Empresa
					//se Sim o Valor pago  é  Diferenciado com a Porcentagem da participacao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BQC->( DbSetorder(01) )//BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
					IF BQC->( MsSeek( xFilial("BQC")+cOper+TRB->BM1_CODEMP+TRB->BM1_CONEMP+TRB->BM1_VERCON + TRB->BM1_SUBCON + TRB->BM1_VERSUB) )
						If	BQC->(FieldPos("BQC_PERPAT")) > 0
							If  BQC->BQC_PATROC =='1'
								BFQ->(DbSetOrder(1))
								BFQ->(MsSeek(xFilial("BFQ")+cOper+TRB->BM1_CODTIP))
								If  BFQ->BFQ_PATROC =='1
									nperc:= (100 - BQC->BQC_PERPAT)/100
									nValor:=nValor*nperc
								Endif
							Endif
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Posiciona array para Incluir a soma total da Familia
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPos1 := aScan(aRecDes,{|x| (x[1] == TRB->BM1_CODEMP .and. ;
						x[2] == TRB->BM1_CONEMP .and. ;
						x[3] == TRB->BM1_SUBCON .and. ;
						x[4] == TRB->BM1_MATRIC .and. ;
						x[5] == "")})

					If  nPos1 == 0
						aadd(aRecDes,{TRB->BM1_CODEMP,TRB->BM1_CONEMP,TRB->BM1_SUBCON,TRB->BM1_MATRIC,"","","",lFlag,;
							0,0,0,0,0,0,0,0,0,0,0,0,;
							0,0,0,0,0,0,0,0,0,0,0,0,;
							0,0,0,0,0,0,0,0,0,0,0,0})
						nPos1 := len(aRecDes)
					Endif

					aRecDes[nPos1,8+val(TRB->BM1_MES)] += nValor

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Posiciona array para Incluir a soma total por Beneficiario
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPos1 := aScan(aRecDes,{|x| (x[1] == TRB->BM1_CODEMP .and. ;
						x[2] == TRB->BM1_CONEMP .and. ;
						x[3] == TRB->BM1_SUBCON .and. ;
						x[4] == TRB->BM1_MATRIC .and. ;
						x[5] == TRB->BM1_TIPREG)})

					If  nPos1 == 0
						aadd(aRecDes,{TRB->BM1_CODEMP,TRB->BM1_CONEMP,TRB->BM1_SUBCON,TRB->BM1_MATRIC,TRB->BM1_TIPREG,"","",lFlag,;
							0,0,0,0,0,0,0,0,0,0,0,0,;
							0,0,0,0,0,0,0,0,0,0,0,0,;
							0,0,0,0,0,0,0,0,0,0,0,0})
						nPos1 := len(aRecDes)
					Endif

					aRecDes[nPos1,8+val(TRB->BM1_MES)] += nValor

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Acessa proximo registro
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					npercJ:=1
					npercD:=1
					nValorD:=0
					nValorJ:=0
					lJur	:=.f.
				EndIf
				TRB->(dbSkip())
			EndDo

			TRB->(DbCloseArea())


			//Identifica e exibe as informações referente a reembolso
			cSql := "SELECT B44_CODEMP,B44_CONEMP,B44_SUBCON,B44_MATRIC,B44_TIPREG, "
			cSql += "B44_VLRPAG,B44_VLRGLO,B44_VLRPAG, B44_VLRGLO, B44_VLABPF, "
			cSql += "B44_OPEEXE, B44_REGEXE, B44_ESTEXE, B44_SIGEXE, B44_CDPFRE, B44_MESPAG, B44_PREFIX, B44_NUM, B44_PARCEL, B44_TIPO "
			cSql += "FROM " + RetSqlName("B44") + " B44 "

			cSql += "INNER JOIN " + RetSqlName("BM1") + " BM1 "
			cSql += "ON BM1_CODINT = B44_OPEUSR AND BM1_CODEMP = B44_CODEMP AND "
			cSql += "BM1_CONEMP = B44_CONEMP AND BM1_VERCON = B44_VERCON AND "
			cSql += "BM1_SUBCON = B44_SUBCON AND BM1_VERSUB = B44_VERSUB AND "
			cSql += "BM1_MATRIC = B44_MATRIC "

			cSql += "WHERE "
			cSql += "BM1_FILIAL = '" + xFilial("BM1") + "' AND "
			cSql += "B44_FILIAL = '" + xFilial("B44") + "' "
			cSql += "AND BM1_CODINT = '"  + cOper  + "' "
			cSql += "AND BM1_CODINT =  '" + cOper  + "' "
			cSql += "AND BM1_CODEMP >= '" + cEmpDe + "' AND BM1_CODEMP <= '" + cEmpAte + "' "
			cSql += "AND BM1_CONEMP >= '" + cConDe + "' AND BM1_CONEMP <= '" + cConAte + "' "
			cSql += "AND BM1_VERCON >= '   ' "
			cSql += "AND BM1_SUBCON >= '" + cSubDe + "' AND BM1_SUBCON <= '" + cSubAte + "' "
			cSql += "AND BM1_VERSUB >= '   ' "
			cSql += "AND BM1_MATRIC >= '" + cMatDe + "' AND BM1_MATRIC <= '" + cMatAte + "' "
			cSql += "AND BM1.D_E_L_E_T_ = ' ' AND B44.D_E_L_E_T_ = ' ' "
			cSql += "AND BM1_ANO         = '" + nAno + "' "
			cSql += "GROUP BY B44_CODEMP, B44_CONEMP, B44_SUBCON, B44_MATRIC, B44_TIPREG, B44_VLRPAG,  "
			cSql += "         B44_VLRGLO, B44_VLRPAG, B44_VLRGLO, B44_VLABPF, B44_OPEEXE, B44_REGEXE,  "
			cSql += "         B44_ESTEXE, B44_SIGEXE, B44_CDPFRE, B44_MESPAG, B44_PREFIX, B44_NUM, B44_PARCEL, B44_TIPO "

			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBREM",.F.,.T.)

			While !TRBREM->(Eof())

				nPos1 := aScan(aRecDesR,{|x| (x[1] == TRBREM->B44_CODEMP .and. ;
					x[2] == TRBREM->B44_CONEMP .and. ;
					x[3] == TRBREM->B44_SUBCON .and. ;
					x[4] == TRBREM->B44_MATRIC .and. ;
					x[5] == TRBREM->B44_TIPREG)})

				If  nPos1 == 0
					aadd(aRecDesR,{TRBREM->B44_CODEMP,TRBREM->B44_CONEMP,TRBREM->B44_SUBCON,TRBREM->B44_MATRIC,TRBREM->B44_TIPREG,"","",.F.,;
						{},{},{},{},{},{},{},{},{},{},{},{}})
					nPos1 := Len(aRecDesR)
				Endif

				IF !EMPTY(TRBREM->B44_CDPFRE)
					aInfReem := { 																				;
						Posicione("BB0",1,xFilial("BB0")+TRBREM->B44_CDPFRE,"BB0_NOME"),				        ;
						Posicione("BB0",1,xFilial("BB0")+TRBREM->B44_CDPFRE,"BB0_CGC"),				            ;
						TRBREM->(B44_VLRPAG + B44_VLRGLO + B44_VLABPF),											;
						TRBREM->B44_VLRPAG,																		;
						TRBREM->B44_PREFIX,																        ;
						TRBREM->B44_NUM,																        ;
						TRBREM->B44_PARCEL,																        ;
						TRBREM->B44_TIPO																        ;
						}
				Else
					aInfReem := { 																				;
						Posicione("BB0",4,xFilial("BB0")+TRBREM->(B44_ESTEXE+B44_REGEXE+B44_SIGEXE),"BB0_NOME"),;
						Posicione("BB0",4,xFilial("BB0")+TRBREM->(B44_ESTEXE+B44_REGEXE+B44_SIGEXE),"BB0_CGC"),	;
						TRBREM->(B44_VLRPAG + B44_VLRGLO + B44_VLABPF),											;
						TRBREM->B44_VLRPAG,																        ;
						TRBREM->B44_PREFIX,																        ;
						TRBREM->B44_NUM,																        ;
						TRBREM->B44_PARCEL,																        ;
						TRBREM->B44_TIPO																        ;
						}
				EndIf

				AADD( aRecDesR[nPos1,8+val(TRBREM->B44_MESPAG)], aInfReem)
				TRBREM->(dbSkip())
			EndDo

			TRBREM->(DbCloseArea())

			nValbm1 :=0
			nItebm1 :=0
			nItebm1 :=0
			nDifer  :=1
			nValor  :=0

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Ordena array  de Valores Somados
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRecDes1 := aSort(aRecDes,,, { |x, y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
		aRecDes  := {}
		aRecDes  := arecDes1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Ordena array de Itens
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRecDes2 := aSort(aRecDesT,,, { |x, y| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[1]+y[2]+y[3]+y[4]+y[5]+y[6]+y[7] })
		aRecDesT  := {}
		aRecDesT  := arecDes2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Ordena array de Reembolsos
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRecDes3 := aSort(aRecDesR,,, { |x, y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
		aRecDesR := {}
		aRecDesR := aRecDes3

		//===================================================================================================
		// Script para buscar reembolsos que estejam na SE2, caso o mesmo já tenha sido incluido através da
		// cobrança pela folha de pagamento, o registro não será incluído novamente
		//===================================================================================================

		if lReemb
			cQuery := " SELECT B44.B44_CODEMP, B44.B44_CONEMP, B44.B44_SUBCON, B44.B44_MATRIC, B44.B44_TIPREG, "
			cQuery += "		B44.B44_VLRPAG, B44.B44_VLRGLO, B44.B44_VLRPAG + B44_VLRGLO + B44_VLABPF B44TOTAL, SE5.E5_DATA, "
			cQuery += "		B44.B44_OPEEXE, B44_REGEXE, B44.B44_ESTEXE,	B44.B44_SIGEXE,	B44.B44_CDPFRE, B44.B44_PREFIX, B44.B44_NUM, B44.B44_PARCEL, B44.B44_TIPO "
			cQuery += " FROM   "+ RetSqlName("B44") + " B44 "
			cQuery += " INNER JOIN " + RetSqlName("BOW") + " BOW "
			cQuery += " 	ON BOW.BOW_PROTOC = B44.B44_PROTOC "
			cQuery += " 	AND BOW.D_E_L_E_T_ = ' ' "
			cQuery += "	INNER JOIN " + RetSqlName("SE5") + " SE5 "
			cQuery += " 	ON SE5.E5_FILIAL = '" + xFilial("SE5") + "' "
			cQuery += "		AND SE5.E5_PREFIXO = B44.B44_PREFIX AND SE5.E5_NUMERO = B44.B44_NUM AND SE5.E5_PARCELA = B44.B44_PARCEL "
			cQuery += "		AND SE5.E5_TIPO = B44.B44_TIPO AND SE5.E5_CLIFOR = BOW.BOW_FORNEC AND SE5.E5_LOJA = B44.B44_LOJA"
			cQuery += " 	AND SUBSTRING(SE5.E5_DATA ,1,4) = '" + cValToChar(nAno)   + "' "
			cQuery += " 	AND SE5.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE B44.B44_FILIAL = '" + xFilial("B44") + "' "
			cQuery += " 	AND B44.B44_OPEUSR =  '" + cOper  + "' "
			cQuery += "		AND B44.B44_CODEMP >= '" + cEmpDe + "' AND B44.B44_CODEMP <= '" + cEmpAte + "' "
			cQuery += "		AND B44.B44_MATRIC >= '" + cMatDe + "' AND B44.B44_MATRIC <= '" + cMatAte + "' "
			cQuery += " 	AND B44.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)

			
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBREM",.F.,.T.)

			If TRBREM->(Eof())
				lRetReembSE2 := .F.
			EndIf
		
			While !TRBREM->(Eof())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Posiciona array para Incluir a soma total da Familia
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos1 := aScan(aRecDes,{|x| (x[1] == TRBREM->B44_CODEMP .and. ;
					x[2] == TRBREM->B44_CONEMP .and. ;
					x[3] == TRBREM->B44_SUBCON .and. ;
					x[4] == TRBREM->B44_MATRIC .and. ;
					x[5] == "")})

				If  nPos1 == 0
					aadd(aRecDes,{TRBREM->B44_CODEMP,TRBREM->B44_CONEMP,TRBREM->B44_SUBCON,TRBREM->B44_MATRIC,"","","",lFlag,;
						0,0,0,0,0,0,0,0,0,0,0,0,;
						0,0,0,0,0,0,0,0,0,0,0,0,;
						0,0,0,0,0,0,0,0,0,0,0,0})
					nPos1 := len(aRecDes)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Posiciona array para Incluir a soma total por Beneficiario
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos1 := aScan(aRecDes,{|x| (x[1] == TRBREM->B44_CODEMP .and. ;
					x[3] == TRBREM->B44_SUBCON .and. ;
					x[2] == TRBREM->B44_CONEMP .and. ;
					x[4] == TRBREM->B44_MATRIC .and. ;
					x[5] == TRBREM->B44_TIPREG)})

				If  nPos1 == 0
					aadd(aRecDes,{TRBREM->B44_CODEMP,TRBREM->B44_CONEMP,TRBREM->B44_SUBCON,TRBREM->B44_MATRIC,TRBREM->B44_TIPREG,"","",lFlag,;
						0,0,0,0,0,0,0,0,0,0,0,0,;
						0,0,0,0,0,0,0,0,0,0,0,0,;
						0,0,0,0,0,0,0,0,0,0,0,0})
					nPos1 := len(aRecDes)
				Endif

				
					nPos1 := aScan(aRecDesR,{|x| (x[1] == TRBREM->B44_CODEMP .and. ;
						x[2] == TRBREM->B44_CONEMP .and. ;
						x[3] == TRBREM->B44_SUBCON .and. ;
						x[4] == TRBREM->B44_MATRIC .and. ;
						x[5] == TRBREM->B44_TIPREG)})
					If  nPos1 == 0
						aadd(aRecDesR,{TRBREM->B44_CODEMP,TRBREM->B44_CONEMP,TRBREM->B44_SUBCON,TRBREM->B44_MATRIC,TRBREM->B44_TIPREG,"","",.F.,;
							{},{},{},{},{},{},{},{},{},{},{},{}})
						nPos1 := Len(aRecDesR)
					Endif
					IF !EMPTY(TRBREM->B44_CDPFRE)
						aInfReem := { 																				;
							Posicione("BB0",1,xFilial("BB0")+TRBREM->B44_CDPFRE,"BB0_NOME"),						;
							Posicione("BB0",1,xFilial("BB0")+TRBREM->B44_CDPFRE,"BB0_CGC"),							;
							TRBREM->B44TOTAL,																		;
							TRBREM->B44_VLRPAG,																		;
							TRBREM->B44_PREFIX,																        ;
							TRBREM->B44_NUM,																        ;
							TRBREM->B44_PARCEL,																        ;
							TRBREM->B44_TIPO																        ;
							}
					Else
						aInfReem := { 																				;
							Posicione("BB0",4,xFilial("BB0")+TRBREM->(B44_ESTEXE+B44_REGEXE+B44_SIGEXE),"BB0_NOME"),;
							Posicione("BB0",4,xFilial("BB0")+TRBREM->(B44_ESTEXE+B44_REGEXE+B44_SIGEXE),"BB0_CGC"),	;
							TRBREM->B44TOTAL,																		;
							TRBREM->B44_VLRPAG,																		;
							TRBREM->B44_PREFIX,																        ;
							TRBREM->B44_NUM,																        ;
							TRBREM->B44_PARCEL,																        ;
							TRBREM->B44_TIPO																        ;
							}
					EndIF
					
					nMesPosReemb := 8+val(SUBSTR(TRBREM->E5_DATA,5,2))
					nPosReemb := 0

					If nLenSE5 == 0
						For nForArray := 1 To Len(aRecDesR)
							For nForArrayAux := 1 To Len(aRecDesR[nForArray][nMesPosReemb])
								
								If( aRecDesR[nForArray][nMesPosReemb][nForArrayAux][5] == aInfReem[5] .and. ;
									aRecDesR[nForArray][nMesPosReemb][nForArrayAux][6] == aInfReem[6] .and. ;
									aRecDesR[nForArray][nMesPosReemb][nForArrayAux][7] == aInfReem[7] .and. ;
									aRecDesR[nForArray][nMesPosReemb][nForArrayAux][8] == aInfReem[8])

									nPosReemb := 1
									Exit
								EndIf
							Next
						Next
					EndIf

					If nPosReemb == 0
						aAdd( aRecDesR[nPos1,nMesPosReemb], aInfReem)
					EndIf

					TRBREM->(dbSkip())
			EndDo

			TRBREM->(DbCloseArea())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Ordena array  de Valores Somados
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRecDes1 := aSort(aRecDes,,, { |x, y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
			aRecDes  := {}
			aRecDes  := arecDes1

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Ordena array de Reembolsos
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRecDes3 := aSort(aRecDesR,,, { |x, y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
			aRecDesR := {}
			aRecDesR := aRecDes3
		EndIf

		//===================================================================================================
		//===================================================================================================
		//===================================================================================================

		IF !lRetSe5 .and. !lRetBM1 .and. !lRetReembSE2
			if !lWeb
				MsgInfo(STR0206, STR0200)    //"Nenhuma informação foi encontrada para a seleção!"###"Atenção"
				Return({aRecDes,aRecDesT,aRecDesR})
			eLSE
				Return({aRecDes,aRecDesT,aRecDesR})
			eNDIF

		Endif


Return({aRecDes,aRecDesT,aRecDesR, aCompetencia})

	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pls_InSql ºAutor  ³Microsiga           º Data ³  01/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Funcao para substituição de Caracteres para Filtro de Dadosº±±
±±º       Em Query                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function Pls_InSql(cInSql, nLenCpo, cChrSep)
		Local cInRet := "", nForIn := 0

		Default nLenCpo := 1
		Default cChrSep := "/"


		If At(cChrSep, cInSql) == 0
			For nForIn := 1 To Len(cInSql) Step nLenCpo
				If Len(cInRet) > 0
					cInRet += ", "
				Endif

				cInRet += "'" + SubStr(cInSql, nForIn, nLenCpo) + "'"

			Next
		Else
			cInRet := "'" + StrTran(cInSql, cChrSep, "', '") + "'"
		EndIf
		cInRet:=SUBSTR(cInRet,1,len(cInRet)-4)

	Return(cInRet)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R97Memo   ºAutor  ³Microsiga           º Data ³  01/20/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Função criada para que seja gravada  a Informações referenteº±±
±±º      Ao Relatorio Informe de Rendimento PLSR997                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function R97Memo()
		Local cEnvServ := GetEnvServer()
		Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()))
		Local cdirweb	:= PLSMUDSIS( getWebDir() + getSkinPls() + "\relatorios\")
		Local cNomArq	:= ""
		Local cNomArqw	:= ""
		Local cArqNf    := ""

		Private cTxtLab := ""
		Private cTxtLabw := ""

		If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
			cNomArq := cDirRaiz + "OBSIMPRENDA.txt"
		Else
			cNomArq := cDirRaiz + "\OBSIMPRENDA.txt"
		EndIf

		If SubString (cdirweb,Len(cdirweb),Len(cdirweb)) == "\"
			cNomArqW := cdirweb + "obsimprenda.txt"
		Else
			cNomArqW := cdirweb + "\obsimprenda.txt"
		EndIf
		cTxtLab := MemoRead(cNomArq)
		FErase(cNomArq)
		cArqNf:=fCreate(cNomArq)
		FS_EMemo(STR0191,.T.,@cTxtLab) //"Complemento de Informe de Rendimento"
		FWrite(cArqNf,cTxtLab)
		FClose(cArqNf)
		__CopyFile(cNomArq, cNomArqW)
	Return(Nil)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_EMemo º Autor ³                    º Data ³  19/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Insere em Campo Memo campos pre-definidos para o Relatorio º±±
±±º       de Informe de Rendimento PLSR997                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function FS_EMemo( cLabel, lEdit, cTexto)
		Local nPos := 0, nPosCtrl := 0
		Private aUsers	:= {}
		Private oDlgM, oLbx, oTexto

		//Default cTexto := ""


		lEdit  := IIf(lEdit  == Nil,           .T., lEdit)
		cLabel := IIf(cLabel == Nil,            "", cLabel)

		DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,850 TITLE STR0191 PIXEL //"Complemeto de Informe de Rendimento" //"Complemento de Informe de Rendimento"

		@ 015, 004 TO 085, 200 Label cLabel OF oDlgM PIXEL
		@ 025, 010 GET oTexto VAR cTexto MEMO When lEdit  SIZE 178.64, 051 OF oDlgM PIXEL

		@ 5,220 LISTBOX oLbx FIELDS HEADER ;
			STR0192, STR0193; //"Titulo"###"Campo"
			SIZE 150,100 OF oDlgM PIXEL ON DblClick(FS_ADDMEMO(cTexto) )

		AADD(aUsers, {STR0194,"BA1->BA1_NOMUSR"}) //"Nome do Beneficiario"
		AADD(aUsers, {STR0195,"BA1->BA1_CPFUSR"}) //"CPF"
		AADD(aUsers, {STR0196,"BA1->BA1_CONEMP"}) //"Contrato"
		AADD(aUsers, {STR0197,"BA0->BA0_CODINT"}) //"Codigo da Operadora"
		AADD(aUsers, {STR0198,"BA0->BA0_NOMINT"}) //"Nome da Operadora"
		AADD(aUsers, {STR0205,"BA0->BA0_CGC   "}) //"CGC"

		oLbx:SetArray( aUsers )
		oLbx:bLine := {|| {		aUsers[oLbx:nAt,1],;
			aUsers[oLbx:nAt,2]}}

		oBtnAd := tButton():New(45,200," < "   ,oDlgM,{|| FS_ADDMEMO(@cTexto)}    ,020,012,,,,.T.)    //"Adicionar"

		DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (oDlgM:End()) ENABLE OF oDlgM

		ACTIVATE MSDIALOG oDlgM CENTERED VALID IIf(Empty(Alltrim(cTexto)).OR. !R97VldTxt(cTexto),.F.,.T.)

	Return(Nil)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ADDMEMO  ºAutor  ³Microsiga         º Data ³  01/26/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   Adiciona os Campos Selecionados no MEMo                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Static Function FS_ADDMEMO(cText)

		cText := cText + "[" +  aUsers[oLbx:nAt,2] + "]"

	Return()
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R97VldTxt ºAutor  ³Microsiga           º Data ³  01/26/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Realiza validação do Texto digitado                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Static Function R97VldTxt(cTexto)
		Local cStr:=""
		Local nPos1:=0
		Local nPos2:=0
		Local xValor
		Local cQryAux := ""
		local nLinhas   := 0
		local lRet      := .T.


		nLinhas := nLines := MLCount(cTexto)

		if nLinhas > 20
			HS_MSGINF(STR0202 + ; // //"A observação informada excede o número máximo de linhas que podem ser exibidas no relatório (20)."
				chr(13) + chr(10) + chr(13) + chr(10) + STR0203  ; // //"Ajuste o texto a ser impresso."
				,STR0200, STR0204)// , 			 //"Atenção"###"Validação Complemeto de Informe de Rendimento"
			lRet := .F.
		endif


		While (nPos1 := At("[", cTexto)) > 0
			If (nPos2 := At("]", cTexto)) > 0
				cStr   := Substr(cTexto, nPos1 + 1 , nPos2 - nPos1 - 1 )

				If !(substr(cStr,1,3) $ "BA1/BA0")
					HS_MsgInf(STR0199, STR0200,STR0201)
					lRet:=.F.
					Return(lRet)
				Endif
				xValor := &(cStr)
				cQryAux := "'" + xValor + "'"

				cTexto := StrTran(cTexto, "[" + cStr, cQryAux,,1)
				cTexto := StrTran(cTexto, "]", "",,1)
				skip
			EndIf
		End

	Return(lRet)

	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R97EXMMO  ºAutor  ³Microsiga        	 º Data ³  01/20/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Função para ler Informações de Campo Memo                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function R97EXMMO(cText)

		cText := R97INDQRY(cText)

	Return(cText)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R97INDQRY ºAutor  ³Microsiga           º Data ³  01/20/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Função que executa a Macro dentro de  um campo Memo         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Static Function R97INDQRY(cQuery)
		Local cStr := "", xValor, cQryAux := ""

		While (nPos1 := At("[", cQuery)) > 0
			If (nPos2 := At("]", cQuery)) > 0

				cStr   := Substr(cQuery, nPos1 + 1 , nPos2 - nPos1 - 1 )
				xValor := &(cStr)

				If ValType(xValor) == "C"
					cQryAux := xValor
				ElseIf ValType(xValor) == "N"
					cQryAux := Str(xValor)
				ElseIf ValType(xValor) == "D"
					cQryAux := "'" + DtoS(xValor) + "'"
				Else
					cQryAux := "'" + xValor + "'"
				EndIf

				cQuery := StrTran(cQuery, "[" + cStr, cQryAux,,1)
				cQuery := StrTran(cQuery, "]", "",,1)

				xValor := Nil
			Else
				HS_MsgInf(STR0199, STR0200,STR0201) //"Campo incorreto na Observação do Relatorio"###"Atenção"###"Análise"
				Exit
			EndIf
		End
	RETURN(cQuery)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVldBAW		ºAutor  ³Totvs           º Data ³  22/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Valida uma RDA de acordo com suas operadoras vinculadas	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PLSVldBAW(cCodInt,aBD6,aCodCri,cCodPad,cCodPro,lLoadRda,dData,cCodigo)
		LOCAL nFor		 := 0
		LOCAL aRetFun    := {.T.,{}}
		Local lCri       := .T.

		DEFAULT aBD6     := {}
		DEFAULT lLoadRda := .F.
		DEFAULT dData    := dDataBase
		DEFAULT aCodCri  := {}

		//Mesmo que a dData chegue com '  /  /   ' seja atribuido o dDataBase
		If Empty(DToS(dData))
			dData := dDataBase
		EndIf

		//Posiciona na Rede de Atendimento X Operadora...
		BAW->(DbSetOrder(1))//BAW_FILIAL+BAW_CODIGO+BAW_CODINT

		If !BAW->( MsSeek(xFilial("BAW") + BAU->BAU_CODIGO + cCodInt ) )

			if plsIntPad() <> cCodInt .and. !BAW->( MsSeek( xFilial("BAW") + BAU->BAU_CODIGO + plsIntPad() ) )

				PLSPOSGLO(PLSINTPAD(),__aCdCri014[1],__aCdCri014[2])

				If Len(aBD6) == 0
					aadd(aCodCri,{__aCdCri014[1],PLSBCTDESC(),cCodInt,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				Else

					For nFor := 1 To Len(aBD6)

						cCodPad := aBD6[nFor,3]
						cCodPro := aBD6[nFor,4]

						aadd(aCodCri,{__aCdCri014[1],PLSBCTDESC(),cCodInt,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					Next

				Endif

				If !lLoadRda
					Return({.F.,aCodCri})
				Else
					aRetFun := {.F.,aCodCri}
				EndIf

			Endif

		ElseIf PLSPOSGLO(PLSINTPAD(),__aCdCri180[1],__aCdCri180[2],nil,"0") .And. PLSCHKCRI( {'BAU',cCodigo,__aCdCri180[1]} )

			If BAW->( MsSeek( xFilial("BAW") + BAU->BAU_CODIGO + cCodInt ) )

				While BAW->BAW_CODIGO ==  BAU->BAU_CODIGO .And. BAW->BAW_CODINT == cCodInt

					If 	(BAW->BAW_VIGINI == CTOD(" / / ") .Or. BAW->BAW_VIGINI <= dData) .and.;
							(BAW->BAW_VIGFIN == CTOD(" / / ") .Or. BAW->BAW_VIGFIN >= dData)

						lCri := .f.
						exit
					EndIf

					BAW->(dbSkip())
				EndDo

				//Caso nao encontre vigencia ativa.
				If lCri
					aadd(aCodCri,{__aCdCri180[1],PLSBCTDESC(),cCodInt,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					aRetFun := {.F.,aCodCri}
				EndIf

			Endif

		Endif

	Return(aRetFun)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSPCBO Autor ³ Totvs           Data ³ 03.11.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de CBOS...                          ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Function PLSPCBO()
		LOCAL cChave     := Space(40)
		LOCAL oDlgPesCbo
		LOCAL oTipoPes
		LOCAL oSayCre
		LOCAL nOpca      := 0
		LOCAL aBrowCbo   := {}
		LOCAL aVetPad    := { {"","","","","",""} }
		LOCAL oBrowCbo
		LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPCRE(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowCbo,aVetPad,oBrowCbo,cCodInt),.T.), If( Empty(aBrowCbo[1,2]) .And. !Empty(cChave),.F.,.T. )  }
		LOCAL cValid     := "{|| Eval(bRefresh) }"
		LOCAL bOK        := { || IF(!Empty(cChave),(nLin := oBrowCbo:nAt, nOpca := 1,oDlgPesCbo:End()),Help("",1,"PLSMCON")) }
		LOCAL bCanc      := { || nOpca := 3,oDlgPesCbo:End() }
		LOCAL nReg
		LOCAL oGetChave
		LOCAL aTipoPes   := {}
		LOCAL nOrdem     := 1
		LOCAL cTipoPes   := ""
		LOCAL oChkChk
		LOCAL lChkChk    := .F.
		LOCAL nLin       := 1
		LOCAL cCodInt  := PLSINTPAD()
		LOCAL cFunAadd := ""
		PRIVATE aOpcoes  := {}

		aBrowCbo         := aClone(aVetPad)
		aTipoPes := {"1-Codigo","2-Descricao"} //"1-Codigo"###"2-Descricao"

		aadd(aOpcoes,{"B82_CODIGO"})
		aadd(aOpcoes,{"B82_DESCBO "})


		//Define dialogo...

		DEFINE MSDIALOG oDlgPesCbo TITLE "Pesquisa de CBO-S" FROM 008.2,000 TO 025,ndColFin OF GetWndDefault() //"Pesquisa de Rede de Atendimento"

		//Monta objeto que recebera o a chave de pesquisa  ...

		oGetChave := TGet():New(020,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesCbo,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

		//Monta Browse...


		oBrowCbo := TcBrowse():New( 043, 008, 378, 075,,,, oDlgPesCbo,,,,,,,,,,,, .F.,, .T.,, .F., )

		oBrowCbo:AddColumn(TcColumn():New("",nil,;
			nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
		oBrowCbo:ACOLUMNS[1]:BDATA     := { || IF(Empty(aBrowCbo[oBrowCbo:nAt,1]),LoadBitmap( GetResources(), "ENABLE" ),LoadBitmap( GetResources(), "DISABLE" )) }
		oBrowCbo:AddColumn(TcColumn():New("Versao TISS",nil,; //"Versao TISS"
			nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowCbo:ACOLUMNS[2]:BDATA     := { || aBrowCbo[oBrowCbo:nAt,1] }
		oBrowCbo:AddColumn(TcColumn():New("Codigo",nil,; //"Codigo"
			nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowCbo:ACOLUMNS[3]:BDATA     := { || aBrowCbo[oBrowCbo:nAt,2] }
		oBrowCbo:AddColumn(TcColumn():New("Descricao",nil,; //"Descricao"
			nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowCbo:ACOLUMNS[4]:BDATA     := { || aBrowCbo[oBrowCbo:nAt,3] }
		oBrowCbo:AddColumn(TcColumn():New("Data Inicial",nil,; //"Data Inicial"
			nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowCbo:ACOLUMNS[5]:BDATA     := { || aBrowCbo[oBrowCbo:nAt,4] }
		oBrowCbo:AddColumn(TcColumn():New("Data Final",nil,; //"Data Final"
			nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowCbo:ACOLUMNS[6]:BDATA     := { || aBrowCbo[oBrowCbo:nAt,5] }

		@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesCbo PIXEL COLOR CLR_HBLUE
		@ 020,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesCbo //"Pesquisar Palavra Chave"

		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		if objCENFUNLGP:isLGPDAt()
			aCampos := {.F.,"B82_VERSAO", "B82_CODIGO" ,"B82_DESCBO" ,"B82_DATDE" ,"B82_DATATE"}
			aBls := objCENFUNLGP:getTcBrw(aCampos)

			oBrowCbo:aObfuscatedCols := aBls
		endif

		oBrowCbo:SetArray(aBrowCbo)
		oBrowCbo:BLDBLCLICK := bOK
		oGetChave:SetFocus()

		//Ativa o Dialogo...

		ACTIVATE MSDIALOG oDlgPesCbo ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesCbo,bOK,bCanc,.F.) })

		If nOpca == K_OK
			If !Empty(aBrowCbo[nLin,1])
				B82->(DbGoTo(aBrowCbo[nLin,6]))
			Endif
		Endif

		//Retorno da Funcao...

	Return(nOpca==K_OK)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSA300PQ  ³ Autor ³ Tulio Cesar     Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a credenciados na base de dados...           ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Static Function PLSAPCre(cChave,cTipoPes,lChkChk,aBrowCbo,aVetPad,oBrowCbo,cCodInt)
		Local aArea      := GetArea()
		LOCAL cSQL  	 := ""
		LOCAL cRetB82	 := ""
		LOCAL lAdd       := .T.

		cRetB82 := B82->(RetSQLName("B82"))

		If '"' $ cChave .Or. ;
				"'" $ cChave
			Aviso( "Caracter Invalido", ;
				"Existem caracteres invalidos em sua pesquisa.",;
				{ "Ok" }, 2 )
			Return(.F.)
		Endif


		//Limpa resultado...

		aBrowCbo := {}

		//Efetua busca...

		cSQL := "SELECT  B82_FILIAL , B82_VERSAO , B82_CODIGO , B82_DESCBO , B82_DATDE  , B82_DATATE, "+cRetB82+".R_E_C_N_O_ AS B82REG "
		cSQL += " FROM "+cRetB82+" "
		cSQL += " WHERE B82_FILIAL = '"+xFilial("B82")+"'"
		cSQL += " AND B82_DATDE <= '"+DtoS(DdataBase)+"'"
		cSQL += " AND (B82_DATATE >='"+DtoS(DdataBase)+"'"+" OR B82_DATATE= ''"+")"
		cSQL += " AND "+cRetB82+".D_E_L_E_T_ = ' '"
		cSQL += " AND "

		If lChkChk
			cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '%"+AllTrim(cChave)+"%' "
		Else
			cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '"+AllTrim(cChave)+"%' "
		Endif

		cSQL += "GROUP BY B82_FILIAL , B82_VERSAO, B82_CODIGO , B82_DESCBO , B82_DATDE  , B82_DATATE, "+aOpcoes[Val(cTipoPes),1]+", "+cRetB82+".R_E_C_N_O_ "

		cSQL += "ORDER BY B82_FILIAL , B82_VERSAO, "+aOpcoes[Val(cTipoPes),1]

		PLSQuery(cSQL,"TrbPes")

		TrbPes->(DbGoTop())
		While ! TrbPes->(Eof())
			lAdd := .T.
			TrbPes->(aadd(aBrowCbo,{B82_VERSAO, B82_CODIGO ,Alltrim(B82_DESCBO) ,B82_DATDE ,B82_DATATE, B82REG}))
			TrbPes->(DbSkip())
		Enddo

		TrbPes->(DbCloseArea())
		RestArea(aArea)

		//Testa resultado da pesquisa...

		If Len(aBrowCbo) == 0
			aBrowCbo := aClone(aVetPad)
		Endif

		//Atualiza browse...

		oBrowCbo:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
		// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
		// Exemplo:
		// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
		// (via seta para cima ou clique na primeira linha)
		// 2a. Pesquisa: "AV" - Ocorria o erro
		oBrowCbo:SetArray(aBrowCbo)
		oBrowCbo:Refresh()
		oBrowCbo:SetFocus()

		//Fim da Rotina...

	Return(.T.)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSVLDCBO  ³ Autor ³ Tulio Cesar     Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida cbos												 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PLSVLDCBO()
		LOCAL lRet  := .T.
		LOCAL dData := StoD(" ")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Salva area anterior...
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		aAreaAnt := GetArea()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Processamento....
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		B82->(DbSetorder(2))

		If B82->(MsSeek(xFilial("B82")+M->B82_CODIGO))
			While !B82->(Eof()) .And. B82->B82_CODIGO = M->B82_CODIGO
				dData := B82->B82_DATATE
				B82->(DbSkip())
			EndDo
			If Empty(dData)
				MsgAlert("Existe Vigencia aberta para este CBOS "+ M->B82_CODIGO)
				lRet:=.F.
			ElseIf !Empty(M->B82_DATDE) .And. lRet
				If M->B82_DATDE <= dData
					MsgAlert("Data da Vigencia inicial nao pode ser menor que a data final da vigencia anterior para este CBOS "+ M->B82_CODIGO)
					lRet:=.F.
				EndIf
			ElseIf Empty(M->B82_DATDE)
				MsgAlert("Digite uma data valida para este CBOS "+ M->B82_CODIGO)
				lRet:=.F.
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Restaura area anterior...
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		RestArea(aAreaAnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Fim da Rotina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Return(lRet)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao PLLISPLA ³ Autor ³ Alexander				³ Data ³ 23.03.12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Devolve todos os planos									  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Function PLSLISPLA(cCodOpe)
		LOCAL aRetorno := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Todos os planos da operadora
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		BI3->( DbSetOrder(1) ) //BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
		If BI3->( MsSeek( xFilial("BI3") + cCodOpe ) )
			While ! BI3->( Eof() ) .And. BI3->(BI3_FILIAL+BI3_CODINT) == xFilial("BI3") + cCodOpe
				AaDd(aRetorno,{BI3->BI3_CODIGO,BI3->BI3_DESCRI})
				BI3->( DbSkip() )
			EndDo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Fim da Rotina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Return(aRetorno)
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PlsRelB45  ³ Autor ³ TOTVS           Data ³ 05.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do campo B45_VALAPT							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PlsRelB45()
		Local nVal := 0

		If Type("M->B45_QTDPRO") == "N" .And.;
				Type("M->B45_VLRAPR") == "N"
			nVal := M->B45_QTDPRO*M->B45_VLRAPR
		EndIf

	Return nVal
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSTrtMAILºAutor  ³ Microsiga          º Data ³  04/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   Prepara o envio do e-mail e chama a PLSEnvMail            º±±
±±º                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PLSTrtMAIL(cDestino,cArquivo)
		Local nTentativas := 0
		Local cSMTPServer := GetNewPar("MV_RELSERV","")
		Local cAccount    := GetNewPar("MV_RELFROM","")
		Local cPassword   := GetNewPar("MV_RELPSW" ,"")
		Local lEnviado    := .F.
		Local cSubject    := "No Subject (ENVMAIL)"

		DEFAULT	cDestino  := ""
		DEFAULT cArquivo  := ""

		Processa({||PLSEnvMail(cDestino,cSubject,cArquivo,@lEnviado,cSMTPServer,cAccount,cPassword)},"Enviando EMail...")

		If !lEnviado
			Aviso("Atenção","Erro no envio de EMail!!!",{"Ok"},1)
		EndIf

	Return lEnviado
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSEnvMailºAutor  ³Microsiga           º Data ³  04/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  Envia e-mail de acordo com os parametros recebidos         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Static Function PLSEnvMail(cDestino,cSubject,cArquivo,lEnviado,cSMTPServer,cAccount,cPassword)
		Local nTentMax := 50  // Tentativas máximas
		Local nSecMax  := 30  // Segundos máximos
		Local cTime    := (Val(Substr(Time(),1,2))*60*60)+(Val(Substr(Time(),4,2))*60)+Val(Substr(Time(),7,2))
		Local nTentat  := 0
		Local cBody	   := "Enviado por rotina automática SIGAPLS-PROTHEUS"
		DEFAULT cDestino	:= ""
		DEFAULT cSubject	:= ""
		DEFAULT cArquivo	:= ""
		DEFAULT cSMTPServer	:= ""
		DEFAULT cAccount	:= ""
		DEFAULT cPassword	:= ""

		cTime += nSecMax

		ProcRegua(nTentMax)

		For nTentat := 1 To nTentMax

			IncProc("Tentativa "+AllTrim(Str(nTentat)))

			CONNECT SMTP SERVER cSMTPServer ACCOUNT cAccount PASSWORD cPassword RESULT lEnviado

			If lEnviado
				SEND MAIL FROM cAccount TO cDestino SUBJECT cSubject BODY cBody ATTACHMENT cArquivo FORMAT TEXT RESULT lEnviado

				DISCONNECT SMTP SERVER
			EndIf

			If lEnviado .Or. cTime <= (Val(Substr(Time(),1,2))*60*60)+(Val(Substr(Time(),4,2))*60)+Val(Substr(Time(),7,2))
				nTentat := nTentMax
			EndIf
		Next

	Return
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSCLEAUSR ³ Autor ³ TOTVS    	     Data ³ 14.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa o conteudo do aDadUsr                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	function PLSCLEAUSR()
		aDadUsr:={}
	return()
	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSVDPEGU  ³ Autor ³ TOTVS    	     Data ³ 14.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se ainda tem guia a ser transferida				  ³±±
±±³       Utilizada quando nao exibe no portal as guias para selecao ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	function PLSVDPEGU(aMat)
		LOCAL nI		:= 0
		LOCAL cSql 	 	:= ""
		LOCAL cAlias 	:= "BD5"
		LOCAL lContinua	:= .t.
		LOCAL aWhere 	:= {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Query para retornar dados
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cSql := " SELECT BD5_CODRDA,BD5_TIPGUI,BD5_CODOPE,BD5_CODLDP,BD5_CODPEG,BD5_NUMERO, R_E_C_N_O_ IDENLINHA "
		cSql += "  FROM " + RetSQLName(cAlias)
		cSql += " WHERE BD5_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += "   AND D_E_L_E_T_ = ' ' "
		cSql += "   AND BD5_CODOPE = '" + PLSINTPAD() + "' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Where
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		for nI:=1 to len(aMat)

			aWhere := strToArray(aMat[nI],'=')

			do case
				case aWhere[1] == 'Field_CODRDA' .and. len(aWhere)>1
					cSql += " AND BD5_CODRDA = '" + aWhere[2] + "' "
					cSql += " AND BD5_CODLDP = '" + If(PLSOBRPRDA(aWhere[2]),PLSRETLDP(9),GetNewPar("MV_PLSPEGE","0000")) + "' "
				case aWhere[1] == 'Field_DTDE' .and. len(aWhere)>1
					cSql += " AND BD5_DATPRO BETWEEN '" + dtos(ctod(aWhere[2])) + "' "
				case aWhere[1] == 'Field_DTATE' .and. len(aWhere)>1
					cSql += " AND '" + dtos(ctod(aWhere[2])) + "' "
				case aWhere[1] == 'Field_TIPGUI' .and. len(aWhere)>1
					cSql += " AND BD5_TIPGUI = '" + aWhere[2] + "' "
			endCase

		next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Executa query
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		OPEN QUERY cSql ALIAS "PLSVDPEGU"

		lContinua := PLSVDPEGU->(!eof())

		CLOSE QUERY "PLSVDPEGU"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Fim da Rotina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	return(lContinua)

	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao PLSDELPAG  ³ Autor ³ Bruno Iserhardt  Data ³ 26.03.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se é possível excluir a PEG                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	function PLSDELPEG(aMat)
		LOCAL cSql 	 	:= ""
		LOCAL cAlias 	:= "BD5"
		LOCAL lExcluiPEG	:= .t.
		local nRecCanBCI := val(strToArray(aMat[1],'=')[2])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Query para retornar dados
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cSql := " SELECT BD5_FASE "
		cSql += "  FROM " + RetSQLName(cAlias)
		cSql += " WHERE BD5_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += "   AND D_E_L_E_T_ = ' ' "

		BCI->( dbGoTo(nRecCanBCI) )

		if !BCI->(eof())
			cSql += " AND BD5_CODOPE = '" + BCI->BCI_CODOPE + "' "
			cSql += " AND BD5_CODLDP = '" + BCI->BCI_CODLDP + "' "
			cSql += " AND BD5_CODPEG = '" + BCI->BCI_CODPEG + "' "
		endIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Executa query
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		OPEN QUERY cSql ALIAS "PLSDELPEG"

		While !PLSDELPEG->(eof()) .AND. lExcluiPEG

			//PEGs que tenham guias faturadas não podem ser excluidas
			If PLSDELPEG->BD5_FASE == "4"
				lExcluiPEG := .F.
			EndIf

			PLSDELPEG->(dbSkip())
		EndDo

		CLOSE QUERY "PLSDELPEG"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Fim da Rotina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	return lExcluiPEG

	/*/{Protheus.doc} PLSPEGGUI
Cria PEG de guias
@since  14.09.12
@version P12
@obs
	/*/
	function PLSPEGGUI(aMat,colsCk,colsUnCk,cSemaforo,lMosGui, cManP, lVlrApr, lPortal, cTipoGuia)
		default lPortal := .F.

		startJob("PLSTRANGU",getEnvServer(),.f.,cEmpAnt,cFilAnt,aMat,colsCk,colsUnCk,cSemaforo,lMosGui, cManP,lVlrApr, lPortal, cTipoGuia)

	return(nil)

	/*/{Protheus.doc} PLSTRANGU
Transfere guias in job de processamento
@since  14.09.12
@version P12
@obs
	/*/
	function PLSTRANGU(cEmpAnt,cFilAnt,aMat,colsCk,colsUnCk,cSemaforo,lMosGui, cManP,lVlrApr, lPortal, cTipoGuia)
		LOCAL nI		:= 0
		LOCAL nQtdTotEve:= 0
		LOCAL nQtdGui	:= 0
		LOCAL nVlrTotGui:= 0
		LOCAL nRecBCI	:= 0
		LOCAL nRecCanBCI:= 0
		LOCAL nInd1		:= 0
		LOCAL nH		:= 0
		LOCAL nQtdGuiT  := 0
		LOCAL cAlias	:= "BD5"
		LOCAL cLotGui	:= ""
		LOCAL cFase		:= "1"
		LOCAL cArqImp	:= ""
		LOCAL cSql		:= ""
		LOCAL cCodLDP	:= ""
		LOCAL cCodPeg	:= ""
		LOCAL cCodPegOri:= ""
		LOCAL cOrigem	:= "1" //0=Remote;1=Portal
		LOCAL cCodOpe	:= ""
		LOCAL lGerPeg	:= .t.
		LOCAL cMes		:= strZero(month(date()),2)
		LOCAL cAno		:= strZero(year(date()),4)
		LOCAL dDTRec	:= date()
		LOCAL aDatPag	:= {}
		LOCAL aWhere	:= {}
		Local aInfRed	:= {}
		LOCAL nIndUt	:= 0
		LOCAL cRda		:= ""
		LOCAL cOffLine	:= "0" //Se é off-Line - digitação de guias
		Local lRcMF		:= ""
		Local cRdaMf	:= ""
		Local cCodoff	:= ""
		Local aCodPeg	:= {}  //1ª posição: PEG padrão, 2ª PEG off-line
		Local aLocaisP	:= {}
		LOCAL cBkpStTiss:= ""

		default lVlrApr := .F.
		default lPortal := .F.

		//Necessário troca, pois temos agora Resumo de Internação
		if cTipoGuia == "05"
			cAlias := "BE4"
		endIf

		//job sem consumo de licenca
		rpcSetType(3)

		//empresa e filial (ambiente)
		rpcSetEnv(cEmpAnt,cFilAnt,,,cAlias)

		//Operadora
		lRcMF 	:= GetNewPar("MV_PLSRCMF",.F.) 	//Se Redutor de Custo deve ser aplicado na MF
		cCodoff	:= PLSRETLDP(4)  				//Local da Digitação de Guia Off-Line
		cCodOpe := PLSINTPAD()

		//Query para retornar dados
		cSql := " SELECT " + cAlias + "_CODRDA CODRDA," + cAlias + "_TIPGUI TIPGUI,"
		cSql +=              cAlias + "_CODOPE CODOPE," + cAlias + "_CODLDP CODLDP,"
		cSql +=              cAlias + "_CODPEG CODPEG," + cAlias + "_NUMERO NUMERO,"
		cSql +=              cAlias + "_ORIMOV ORIMOV, R_E_C_N_O_ IDENLINHA "
		cSql += "   FROM " + retSQLName(cAlias)
		cSql += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "

		Iif (cTipoGuia <> "05", cSql += "   AND " + cAlias + "_LIBERA <> '1' ", "")

		cSql += "   AND D_E_L_E_T_ = ' ' "

		for nI := 1 to len(aMat)

			aWhere := strToArray(aMat[nI],'=')

			do case

				//veio do cancelamento
				case aWhere[1] == 'Field_RECNO' .and. len(aWhere) > 1

					lGerPeg := .f.

					//posiciona na bci e pega os parametros para selecao das guaiss
					nRecCanBCI := val(aWhere[2])

					BCI->( dbGoTo(nRecCanBCI) )
					cOffLine := BCI->BCI_DIGOFF

					if !BCI->(eof())
						cSql += " AND " + cAlias + "_CODOPE = '" + BCI->BCI_CODOPE + "' "
						cSql += " AND " + cAlias + "_CODLDP = '" + BCI->BCI_CODLDP + "' "
						cSql += " AND " + cAlias + "_CODPEG = '" + BCI->BCI_CODPEG + "' "
						cRda := BCI->BCI_CODRDA
					endIf

				case aWhere[1] == 'Field_CODRDA' .and. len(aWhere) > 1

					cSql += " AND " + cAlias + "_CODOPE = '" + cCodOpe + "' "
					cSql += " AND " + cAlias + "_CODLDP IN ('" + If(PLSOBRPRDA(aWhere[2]),PLSRETLDP(9),GetNewPar("MV_PLSPEGE","0000")) + "', '" + cCodOff + "') "
					cSql += " AND " + cAlias + "_CODRDA = '" + aWhere[2] + "' "

				case aWhere[1] == 'Field_DTDE' .and. len(aWhere) > 1

					cSql += " AND " + cAlias + "_DATPRO BETWEEN '" + dtos(ctod(aWhere[2])) + "' "

				case aWhere[1] == 'Field_DTATE' .and. len(aWhere) > 1

					cSql += " AND '" + dtos(ctod(aWhere[2])) + "' "

				case aWhere[1] == 'Field_TIPGUI' .and. len(aWhere) > 1

					cSql += " AND " + cAlias + "_TIPGUI = '" + aWhere[2] + "' "

			endCase

		next

		//³itens marcados ou desmarcados no browse
		if lGerPeg .and. lMosGui

			if ! empty(colsCk)

				cSql += " AND R_E_C_N_O_ IN (" + colsCk + ") "

			elseIf ! empty(colsUnCk)

				cSql += " AND R_E_C_N_O_ NOT IN (" + colsUnCk + ") "

			endIf

		endIf

		//³controle de semaforo
		nH := PLSAbreSem(cSemaforo)

		//³Executa query
		OPEN QUERY cSql ALIAS "PLSTRANGU"

		//Total de guias
		if lGerPeg
			PLSTRANGU->( dbEval({|| nQtdGuiT++}) )
			PLSTRANGU->( dbGoTop() )
		endIf

		//³verifica se existe registro
		if !PLSTRANGU->(eof())

			//cria Peg
			if lGerPeg

				//local codldp INCLUSAO MANUAL
				cCodLDP	:= PLSRETLDP(1)

				//CRIA PEG
				PLSIPP(PLSTRANGU->CODOPE,cCodLDP,PLSTRANGU->CODOPE,PLSTRANGU->CODRDA,cMes,cAno,dDTRec,PLSTRANGU->TIPGUI,cLotGui,aDatPag,cFase,cArqImp,nQtdTotEve,nQtdGui,nVlrTotGui,cOrigem,NIL,NIL,cManP)

				//limpo o BCI_STTISS pq controlo por ele quando a PEG deve aparecer no portal para consultar, pois estávamos tendo problemas de a peg aparecer com 0 guias e estava gerando confusão com os prestadores dos clientes
				if lPortal

					cBkpStTiss := BCI->BCI_STTISS

					BCI->(RecLock("BCI", .F.))
					BCI->BCI_STTISS := ''
					BCI->(MsUnlock())

				endIf

			else

				//local codldp MOVIMENTACAO ELETRONICA
				cCodLDP	 := iIF(PLSOBRPRDA(cRda),PLSRETLDP(9),PLSRETLDP(5))
				aLocaisP := {cCodLDP, cCodOff}

				//POSICIONA NO PEG
				If nInd1 == 0
					nIndUt := PLSBUIND("BCI","BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_TIPGUI + BCI_CODRDA + BCI_ARQUIV") /// Busca da Ordem do indice pela descrição
					nInd1  := nIndUt
				Endif

				BCI->( DbSetOrder(nInd1) )//BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_TIPGUI + BCI_CODRDA + BCI_ARQUIV

				//se nao achei o peg por algum motivo .... eu crio o 9999 denovo
				//1ª posição: código PEG normal, 2ª código da PEG off-line
				For nI := 1 To Len(aLocaisP)

					If !BCI->( msSeek(xFilial("BCI") + PLSTRANGU->CODOPE + aLocaisP[nI] + PLSTRANGU->TIPGUI + PLSTRANGU->CODRDA) )

						PLSIPP(PLSTRANGU->CODOPE,cCodLDP,PLSTRANGU->CODOPE,PLSTRANGU->CODRDA,cMes,cAno,dDTRec,PLSTRANGU->TIPGUI,cLotGui,aDatPag,cFase,cArqImp,nQtdTotEve,nQtdGui,nVlrTotGui,cOrigem,NIL,NIL,cManP)

					Endif

					aAdd(aCodPeg, BCI->BCI_CODPEG)

				Next

			endIf

			//retorna o numero do peg
			cCodPeg := BCI->BCI_CODPEG
			cRdaMf	:= BCI->BCI_CODRDA

			if lGerPeg
				nRecBCI := BCI->(recno())
			endIf

			begin transaction

				//transferencia
				while !PLSTRANGU->(eof()) .and. !BCI->(eof())

					cCodLdpOri 	:= PLSTRANGU->CODLDP
					cCodPegOri 	:= PLSTRANGU->CODPEG
					cCodOpe		:= PLSTRANGU->CODOPE
					cCodLDP 	:= IIF(lGerPeg, cCodLDP, IIF(PLSTRANGU->ORIMOV == "5", aLocaisP[2], aLocaisP[1]))
					cCodPeg		:= IIF(lGerPeg, cCodPeg, IIF(PLSTRANGU->ORIMOV == "5", aCodPeg[2] , aCodPeg[1] ))

					PLSATUPEG(PLSTRANGU->CODOPE,PLSTRANGU->CODLDP,cCodPegOri,PLSTRANGU->NUMERO,PLSTRANGU->CODOPE,cCodLDP,cCodPeg,cAlias,.t.)

					PLSTRANGU->(dbSkip())
				endDo

				//atualiza status peg
				if !lGerPeg

					BCI->(dbGoto(nRecCanBCI))

					//³Deleta chave da peg
					if getNewPar("MV_PLSNNUM","1") == "1"
						PLSB0YDEL(cAlias + '_NUMERO', BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG))
					endIf

					//³Deleta o peg
					BCI->(recLock("BCI",.f.))
					BCI->(dbDelete())
					BCI->(msUnLock())

				endIf

			end transaction

			//atualiza totais do peg
			If lGerPeg

				PLSATUPP(,,nQtdGuiT,.t.,cCodOpe,cCodLDP,cCodPeg,(cCodOpe + cCodLdpOri + cCodPegOri),lVlrApr)

				aAdd(aInfRed, { cRdaMf  })
				aAdd(aInfRed, { cCodOpe })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { cCodPeg })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { cCodLDP })
				PLSM250Pro("PLSM250   ", .T., "2", aInfRed, .F.)

				BCI->(dbGoto(nRecBCI))

				if ! empty(cBkpStTiss)

					BCI->(recLock("BCI",.f.))
					BCI->BCI_STTISS = cBkpStTiss
					BCI->(msUnLock())

				endIf

				//Roda o processo para critica 063
				PLS063MFNOV(cCodPeg, CRdaMF, cCodOpe, cCodLdp, BCI->BCI_TIPGUI)

			endIf

		endIf

		CLOSE QUERY "PLSTRANGU"

		//DbCommit
		BD5->( DbCommit() )

		PLSFechaSem(nH,cSemaforo)

		//Ponto de entrada no após a realização da transferência de guias.
		If existBlock("PLTRANGU")
			execblock("PLTRANGU",.F.,.F.,{cCodOpe,cCodLDP,cCodPeg,BCI->BCI_TIPGUI})
		endIf

		//Totaliza o cabecalho da guia
		PLCABGTOT( BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_ORIMOV),  BD5->BD5_TIPGUI)

		//Totaliza o PEG
		PLPEGTOT()

	return

	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun?ao PLSDPExcel ³ Autor ³ Túlio Cesar	 Data ³ 28.01.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri?ao ³ De parao do prestador em planilha no FWMsExcel    		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	Function PLSDPExcel(cTipo,nDecimal)
		LOCAL nRet := 1
		If     cTipo == "C"
			nRet := 1
		ElseIf cTipo == "N" .And. nDecimal == 0
			nRet := 2
		ElseIf cTipo == "N" .And. nDecimal <> 0
			nRet := 3
		ElseIf cTipo == "D"
			nRet := 4
		Else
			nRet := 1
		Endif
	Return(nRet)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSB0YNUM  ³ Autor ³ Totvs		 Data ³ 26.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Controle de numeracao 										 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLSB0YNUM(cCampo,cChave,cAlias,cCodOpe,cCodLDP,cCodPEG)
		LOCAL aArea 	:= getArea()
		LOCAL nH		:= nil
		LOCAL nTam		:= SX3->(tamSX3(cCampo)[1])
		LOCAL nTamCHV	:= 50
		LOCAL cRet 		:= ''
		LOCAL cChvMvt   := xFilial(cAlias)+cCodOpe+cCodLDP+cCodPEG
		LOCAL cDataBase := AllTrim(TCGetDB())
		LOCAL lUp		:= .t.
		LOCAL cAnoMov 	:= ""
		LOCAL cMesMov 	:= ""
		LOCAL cBusDat 	:= ""
		LOCAL cAnoBas 	:= Subs(DTOS(dDataBase),1,4)
		LOCAL cMesBas 	:= Subs(DTOS(dDataBase),5,2)
		LOCAL nFilMov 	:= Len(xFilial(cAlias))

		DEFAULT cChave 	:= ''
		DEFAULT cAlias 	:= ''
		DEFAULT cCodOpe := ''
		DEFAULT cCodLDP := ''
		DEFAULT cCodPEG := ''

		nH := PLSAbreSem("PLSB0YNUM_" + cCampo + allTrim(cChave) + ".SMF")

		//³espacos na chave para busca
		//³OBS:Nao utilizar o tamsx3 para o tamanho da chave no B0Y (economia de recurso)
		cChave 		:= allTrim(cChave)
		cChave 		:= cChave + space( nTamCHV-len(cChave) )
		cSlvChave 	:= cChave

		//Forcando atualizacao da tabela realizando a reabertura...
		B0Y->(dbCloseArea())
		dbSelectArea("B0Y")

		//³Retorna o proximo numero
		B0Y->(dbSetOrder(1)) //B0Y_FILIAL + B0Y_CAMPO + B0Y_CHAVE
		if B0Y->( msSeek( xFilial("B0Y") + cCampo + cChave ) )

			cRet := B0Y->B0Y_PROXIM
			lUp	 := .F.

		else

			//Abre semaforo
			nH2 := PLSAbreSem("PLSA500N.SMF")

			If cDataBase <> "ORACLE"
				nOrd := Eval( { || DbSelectArea(cAlias), IndexOrd() } )
				nRec := Eval( { || DbSelectArea(cAlias), Recno() } )
				DbSelectarea(cAlias)
				DbSetOrder(1)
				MsSeek(cChvMvt+Replicate("9",nTam),.T.)
				DbSkip(-1)

				__cIndex := Eval( { || DbSelectArea(cAlias), IndexKey() } )
				cChave   := &(cAlias+"->("+__cIndex+")")
				cBusDat  := Subs(cChave,nFilMov,Len(cChave))
				cAnoMov  := Subs(cBusDat,28,4)
				cMesMov  := Subs(cBusDat,32,2)

				If Subs(cChave,1,Len(cChvMvt)) <> cChvMvt
					cRet := StrZero(1,nTam)
				Else
					cRet := StrZero(Val(&(cAlias+"_NUMERO"))+1,nTam)
					If cAnoBas <> cAnoMov .And. cMesBas <> cMesMov
						cRet := StrZero(1,nTam)
					EndIf
				Endif
				DbSetOrder(nOrd)
				DbGoTo(nRec)

			Else

				cSQL := "SELECT MAX("+cAlias+"_NUMERO) NUM FROM "+RetSQLName(cAlias)+" WHERE "
				cSQL += cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "
				cSQL += cAlias+"_CODOPE = '"+cCodOpe+"' AND "
				cSQL += cAlias+"_CODLDP = '"+cCodLDP+"' AND "
				cSQL += cAlias+"_CODPEG = '"+cCodPEG+"' AND "
				If cAlias == "BE4"
					cSQL += cAlias+"_MESINT = '"+cMesBas+"' AND "
					cSQL += cAlias+"_ANOINT = '"+cAnoBas+"' AND "
				Else
					cSQL += cAlias+"_MESAUT = '"+cMesBas+"' AND "
					cSQL += cAlias+"_ANOAUT = '"+cAnoBas+"' AND "
				EndIf

				cSQL += "D_E_L_E_T_ = ' ' "

				PLSQuery(cSQL,"Trb500Num")

				cRet := StrZero(Val(Trb500Num->NUM)+1,nTam)

				Trb500Num->(DbCloseArea())
			Endif

			PLSFechaSem(nH2,"PLSA500N.SMF")
		endIf

		//Grava o proximo
		B0Y->( recLock("B0Y",lUp) )

		//so atualiza estes campos quando for inclusao
		if lUp
			B0Y->B0Y_FILIAL := xFilial("B0Y")
			B0Y->B0Y_CAMPO  := cCampo
			B0Y->B0Y_CHAVE  := allTrim(cSlvChave)
		endIf

		//atualiza o proximo numero
		B0Y->B0Y_PROXIM := strZero(val(cRet) + 1,nTam)

		B0Y->( msUnLock() )

		PLSFechaSem(nH,"PLSB0YNUM_" + cCampo + allTrim(cChave) + ".SMF")

		restArea(aArea)

	return(cRet)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSB0YATU  ³ Autor ³ Totvs		 Data ³ 26.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Atualiza a numeracao no Controle de numeracao 				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLSB0YATU(cCampo,cChave,cNum)
		LOCAL aArea 	:= getArea()
		LOCAL nH		:= nil
		LOCAL nTam		:= SX3->(tamSX3(cCampo)[1])
		LOCAL nTamCHV	:= 50
		DEFAULT cChave 	:= ''

		//cria semaforo
		nH := PLSAbreSem("PLSB0YNUM_"+cCampo+allTrim(cChave)+".SMF")

		//espacos na chave para busca
		cChave := cChave + space( nTamCHV - len(cChave) )

		//Este seek somente por garantia mais nunca deve entrar aqui com chave duplicado
		//pois na transferencia e sempre para um peg novo
		DbSelectArea("B0Y")
		B0Y->(dbSetOrder(1)) //B0Y_FILIAL + B0Y_CAMPO + B0Y_CHAVE

		if !B0Y->( msSeek( xFilial("B0Y") + cCampo + cChave ) )

			//Grava o proximo
			B0Y->( recLock("B0Y",.t.) )
			B0Y->B0Y_FILIAL := xFilial("B0Y")
			B0Y->B0Y_CAMPO  := cCampo
			B0Y->B0Y_CHAVE  := allTrim(cChave)
			B0Y->B0Y_PROXIM := strZero(val(cNum) + 1,nTam)
			B0Y->( msUnLock() )

		endIf

		PLSFechaSem(nH,"PLSB0YNUM_"+cCampo+allTrim(cChave)+".SMF")

		restArea(aArea)

	return(nil)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSB0YDEL  ³ Autor ³ Totvs		 Data ³ 26.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Deleta chave nao mais utilizada								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLSB0YDEL(cCampo,cChave)
		LOCAL aArea 	:= getArea()
		LOCAL nH		:= nil
		LOCAL nTamCHV	:= 50
		DEFAULT cChave 	:= ''
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³cria semaforo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		nH := PLSAbreSem("PLSB0YNUM_"+cCampo+allTrim(cChave)+".SMF")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³espacos na chave para busca
		//³OBS:Nao utilizar o tamsx3 para o tamanho da chave no B0Y (economia de recurso)
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cChave := cChave + space( nTamCHV-len(cChave) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Este seek somente por garantia mais nunca deve entrar aqui com chave duplicado
		//³pois na transferencia e sempre para um peg novo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		B0Y->(dbSetOrder(1)) //B0Y_FILIAL + B0Y_CAMPO + B0Y_CHAVE
		if B0Y->( msSeek( xFilial("B0Y") + cCampo + cChave ) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Grava o proximo
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			B0Y->( recLock("B0Y",.f.) )
			B0Y->(dbDelete())
			B0Y->( msUnLock() )
		endIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Fecha SemaForo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		PLSFechaSem(nH,"PLSB0YNUM_"+cCampo+allTrim(cChave)+".SMF")

		restArea(aArea)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³fim da rotina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	return(nil)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSOBRPRDA  ³ Autor ³ Totvs		 Data ³ 26.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Deleta chave nao mais utilizada								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Function PLSOBRPRDA(cCodRda)
		LOCAL lObrPto   := .F.
		LOCAL nOrdBAU
		LOCAL nRecBAU
		LOCAL lContinua := .T.

		If GetNewPar("MV_PLSOBPT","0") == "1"
			lObrPto := .T.
		Else

			If BAU->(FieldPos("BAU_OBRPTO")) > 0

				If ! Empty(cCodRDA) .And. BAU->BAU_CODIGO <> cCodRDA

					nOrdBAU := BAU->(IndexOrd())
					nRecBAU := BAU->(Recno())

					BAU->(DbSetOrder(1))
					lContinua := BAU->(DbSeek(xFilial("BAU")+cCodRda))

					If lContinua .And. BAU->BAU_OBRPTO == "1"  //Validacao para quando a RDA for PJ. Ela nao tera BB0
						lObrPto := .T.
					Endif

					BAU->(DbSetOrder(nOrdBAU))
					BAU->(DbGoTo(nRecBAU))

				Endif

				If lContinua .And. BAU->BAU_OBRPTO == "1"
					lObrPto := .T.
				Endif

			Endif

		Endif

	Return(lObrPto)
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCHKRP   ³ Autor ³ Alexander	 Data ³ 29.05.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Checa se o arquivo PDF gerado esta valido para exibicao		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLSCHKRP(cDirFile,cArqName,nTimeSleep)
		LOCAL nJ 	:= 1
		LOCAL nHIn 	:= -1
		LOCAL nTam	:= 0
		DEFAULT cArqName := ''
		DEFAULT nTimeSleep := 2000

		//Aguardamos aqui pois o arquivo ainda pode estar sendo gerado
		//O valor nTimeSleep é calculado de acordo com a quantidade de procedimentos existentes no relatório.
		//Sugestão de cálculo: para até 20 procedimentos, manter 2segundos (2000ms), acima disso, para cada 10 procedimentos incluir 0.5s (500ms)
		//ex: o FWMSPrinteGera um .pd_ antes de gerar um .pdf, se conseguirmos abrir o arquivo .pdf antes do frame criar, o arquivo vai ser gerado vazio.
		Sleep(nTimeSleep)

		//Verifica se o arquivo existe
		while (nHIn := fopen(cDirFile+cArqName)) == -1 .and. nJ < 1000
			nJ++
			sleep(1000)
		endDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Verifica quando o arquivo tem conteudo.
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		if nHIn <> -1
			nJ := 1

			while ( nTam := fSeek(nHIn, 0, 2) ) == 0 .and. nJ < 1000
				sleep(1000)
				nJ++
			enddo

			sleep(1000)

			while fSeek(nHIn, 0, 2) <> nTam
				nTam := fSeek(nHIn, 0, 2)
				sleep(1000)
			endDo

			if nHIn <> -1
				fClose(nHIn)
			endIf
		endIf

	return()
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSRDAREF  ³ Autor ³ Alexander		     	 ³ Data ³ 13.06.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Rede referenciada de atendimento									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLSRDAREF(cAlias,cChave)
		LOCAL aCarRDA := {}

		if cAlias == 'BBK'

			BBK->(DbSetOrder(1)) //BBK_FILIAL+BBK_CODIGO+BBK_CODINT+BBK_CODLOC+BBK_CODESP+BBK_CODRED
			If BBK->(MsSeek(xFilial(cAlias)+cChave))

				BG2->(DbSetOrder(1))//BG2_FILIAL + BG2_CODRED
				While ! BBK->(Eof()) .And. BBK->(BBK_FILIAL+BBK_CODIGO+BBK_CODINT+BBK_CODLOC+BBK_CODESP) == xFilial(cAlias)+cChave

					aadd(aCarRDA,BBK->BBK_CODRED)

					If BG2->(MsSeek(xFilial("BG2")+BBK->BBK_CODRED))

						While ! BG2->(Eof()) .And. BG2->(BG2_FILIAL+BG2_CODRED) == xFilial("BG2")+BBK->BBK_CODRED

							aadd(aCarRDA,BG2->BG2_REDREL)

							BG2->(DbSkip())
						Enddo

					Endif

					BBK->(DbSkip())
				Enddo

			Endif

		elseIf cAlias == 'BB6'

			BB6->(DbSetOrder(1))//BB6_FILIAL + BB6_CODIGO + BB6_VERSAO
			If BB6->(MsSeek(xFilial(cAlias)+cChave))

				BG2->(DbSetOrder(1))//BG2_FILIAL + BG2_CODRED

				While ! BB6->(Eof()) .And. BB6->(BB6_FILIAL+BB6_CODIGO+BB6_VERSAO) == xFilial(cAlias)+cChave

					aadd(aCarRDA,{BB6->BB6_CODRED,BB6->BB6_ATIVO})

					If BG2->(MsSeek(xFilial("BG2")+BB6->BB6_CODRED))

						While ! BG2->(Eof()) .And. BG2->(BG2_FILIAL+BG2_CODRED) == xFilial("BG2")+BB6->BB6_CODRED

							aadd(aCarRDA,{BG2->BG2_REDREL,BB6->BB6_ATIVO})

							BG2->(DbSkip())
						Enddo

					Endif

					BB6->(DbSkip())
				Enddo

			Endif

		endif

	return(aCarRDA)

	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlvldMoG   ³ Autor ³ Daher		     	 ³ Data ³ 13.06.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Rede referenciada de atendimento									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PlvldMoG()
		LOCAL lRet := .T.

		If ReadVar() == 'M->BVX_MOTIVO'
			//se o cara digitou 3 caracteres eu procuro na chave principal senao eu pego a
			If len(alltrim(M->BVX_MOTIVO)) <= 3
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BVX_MOTIVO),1) )
				If lRet .and. !vazio()
					M->BVX_DESMOT := UPPER(Posicione("BCT",1,xFilial('BCT')+PLSINTPAD()+alltrim(M->BVX_MOTIVO),'BCT_DESCRI'))
				Elseif lRet .and. vazio()
					M->BVX_DESMOT := ''
				Endif
			Else
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BVX_MOTIVO),5) )
				If lRet .and. !vazio()
					M->BVX_DESMOT := UPPER(Posicione("BCT",5,xFilial('BCT')+PLSINTPAD()+alltrim(M->BVX_MOTIVO),'BCT_DESCRI'))
					M->BVX_MOTIVO := padr(BCT->BCT_PROPRI+BCT->BCT_CODGLO,4)
				Elseif lRet .and. vazio()
					M->BVX_DESMOT := ''
				Endif
			Endif
		Endif

		If ReadVar() == 'M->BD6_MOTBPG'
			//se o cara digitou 3 caracteres eu procuro na chave principal senao eu pego a
			If len(alltrim(M->BD6_MOTBPG)) <= 3
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD6_MOTBPG),1) ) .And. PLSA720BPG()
				If lRet .and. !vazio()
					M->BD6_DESBPG := UPPER(Posicione("BCT",1,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD6_MOTBPG),'BCT_DESCRI'))
				Elseif lRet .and. vazio()
					M->BD6_DESBPG := ''
				Endif
			Else
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD6_MOTBPG),5) ) .And. PLSA720BPG()
				If lRet .and. !vazio()
					M->BD6_DESBPG := UPPER(Posicione("BCT",5,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD6_MOTBPG),'BCT_DESCRI'))
					M->BD6_MOTBPG := padr(BCT->BCT_PROPRI+BCT->BCT_CODGLO,4)
				Elseif lRet .and. vazio()
					M->BD6_DESBPG := ''
				Endif
			Endif
		Endif

		If ReadVar() == 'M->BD7_MOTBLO'
			//se o cara digitou 3 caracteres eu procuro na chave principal senao eu pego a
			If len(alltrim(M->BD7_MOTBLO)) <= 3
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD7_MOTBLO),1) )
				If lRet .and. !vazio()
					M->BD7_DESBLO := UPPER(Posicione("BCT",1,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD7_MOTBLO),'BCT_DESCRI'))
				Elseif lRet .and. vazio()
					M->BD7_DESBLO := ''
				Endif
			Else
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD7_MOTBLO),5) )
				If lRet .and. !vazio()
					M->BD7_DESBLO := UPPER(Posicione("BCT",5,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD7_MOTBLO),'BCT_DESCRI'))
					M->BD7_MOTBLO := padr(BCT->BCT_PROPRI+BCT->BCT_CODGLO,4)
				Elseif lRet .and. vazio()
					M->BD7_DESBLO := ''
				Endif
			Endif
		Endif

		If ReadVar() == 'M->BD5_MOTBPG'
			//se o cara digitou 3 caracteres eu procuro na chave principal senao eu pego a
			If len(alltrim(M->BD5_MOTBPG)) <= 3
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD5_MOTBPG),1) )
				If lRet .and. !vazio()
					M->BD5_DESBPG := UPPER(Posicione("BCT",1,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD5_MOTBPG),'BCT_DESCRI'))
				Elseif lRet .and. vazio()
					M->BD5_DESBPG := ''
				Endif
			Else
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD5_MOTBPG),5) )
				If lRet .and. !vazio()
					M->BD5_DESBPG := UPPER(Posicione("BCT",5,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD5_MOTBPG),'BCT_DESCRI'))
					M->BD5_MOTBPG := padr(BCT->BCT_PROPRI+BCT->BCT_CODGLO,4)
				Elseif lRet .and. vazio()
					M->BD5_DESBPG := ''
				Endif
			Endif
		Endif

		If ReadVar() == 'M->BE4_MOTBPG'
			//se o cara digitou 3 caracteres eu procuro na chave principal senao eu pego a
			If len(alltrim(M->BE4_MOTBPG)) <= 3
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BE4_MOTBPG),1) )
				If lRet .and. !vazio()
					M->BE4_DESBPG := UPPER(Posicione("BCT",1,xFilial('BCT')+PLSINTPAD()+alltrim(M->BE4_MOTBPG),'BCT_DESCRI'))
				Elseif lRet .and. vazio()
					M->BE4_DESBPG := ''
				Endif
			Else
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BE4_MOTBPG),5) )
				If lRet .and. !vazio()
					M->BE4_DESBPG := UPPER(Posicione("BCT",5,xFilial('BCT')+PLSINTPAD()+alltrim(M->BE4_MOTBPG),'BCT_DESCRI'))
					M->BE4_MOTBPG := padr(BCT->BCT_PROPRI+BCT->BCT_CODGLO,4)
				Elseif lRet .and. vazio()
					M->BE4_DESBPG := ''
				Endif
			Endif
		Endif

		If ReadVar() == 'M->BD6_MOTBPF'
			//se o cara digitou 3 caracteres eu procuro na chave principal senao eu pego a
			If len(alltrim(M->BD6_MOTBPF)) <= 3
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD6_MOTBPF),1) )
				If lRet .and. !vazio()
					M->BD6_DESBPF := UPPER(Posicione("BCT",1,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD6_MOTBPF),'BCT_DESCRI'))
				Elseif lRet .and. vazio()
					M->BD6_DESBPF := ''
				Endif
			Else
				lRet := vazio() .or. BCT->( ExistCpo("BCT",PLSINTPAD()+alltrim(M->BD6_MOTBPF),5) )
				If lRet .and. !vazio()
					M->BD6_DESBPF := UPPER(Posicione("BCT",5,xFilial('BCT')+PLSINTPAD()+alltrim(M->BD6_MOTBPF),'BCT_DESCRI'))
					M->BD6_MOTBPF := padr(BCT->BCT_PROPRI+BCT->BCT_CODGLO,4)
				Elseif lRet .and. vazio()
					M->BD6_DESBPF := ''
				Endif
			Endif
		Endif

	return lRet
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLGTBE2SL  ³ Autor ³ Victor Ferreira   Data ³ 16.01.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Retorna a o saldo dos itens de uma liberacao              ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ PLSA097  - Confirm. Liberacao                             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cNumLib -> Numero da liberacao                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Function PLGTBE2SL(cNumLib,cSequen)
		Local aAreaBE2 	:= BE2->(GetArea())
		Local nSaldo	:= 0

		BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
		If BE2->(DbSeek(xFilial("BE2")+cNumLib))
			cChave := BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT)
			While !BE2->(EoF()) .And. BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT) == cChave

				If cSequen == BE2->BE2_SEQUEN
					nSaldo := BE2->BE2_SALDO
				Endif

				BE2->(DbSkip())
			EndDo
		Endif

		RestArea(aAreaBE2)

	Return nSaldo

	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSPRNB0Y  ³ Autor ³ Victor Ferreira   Data ³ 10.02.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³                                                           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                           ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLSPRNB0Y(cAliasPEG,cCodOpe,cCodLDP,cCodPEG)
		local cNumGui	:= ""
		local cCampo    := ""
		local lPlNumPr	:= .t.
		local nHP		:= 0

		if cAliasPEG == "BE4"
			cCampo := "BE4_NUMERO"
		else
			cCampo := "BD5_NUMERO"
		endIf

		nHP := PLSAbreSem("P500" + cCampo + cCodOpe + cCodLDP + cCodPEG + ".SMF")

		//Criacao e/ou Execucao da procedure de controle de numeracao de transacoes do contas medicas
		cNumGui := PlNPrB0Y(cAliasPEG, cCampo, cCodOpe, cCodLDP, cCodPEG)[1]

		PLSFechaSem(nHP,"P500" + cCampo + cCodOpe + cCodLDP + cCodPEG + ".SMF")

	return( { cNumGui, lPlNumPr } )
	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PlNPrB0Y   ³ Autor ³ Victor Ferreira   Data ³ 10.02.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³                                                           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                           ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PlNPrB0Y(cAliasPEG, cCampo, cCodOpe, cCodLDP, cCodPEG)
		local aArea 	:= {}
		local cProximo	:= ""
		local nSizeN  	:= 0
		local nTamCHV	:= SX3->(tamSX3('B0Y_CHAVE')[1])
		local cChave	:= cCampo + cCodOpe + cCodLDP + cCodPEG
		local cChave 	:= cChave + space( nTamCHV - len(cChave) )
		local lLoop 	:= .t.

		aArea := (cAliasPEG)->(getArea())

		dbSelectArea("B0Y")

		B0Y->(dbSetOrder(1))//B0Y_FILIAL+B0Y_CAMPO+B0Y_CHAVE
		(cAliasPEG)->(dbSetOrder(1))//???_FILIAL+???_CODOPE+???_CODLDP+???_CODPEG+???_NUMERO+???_SITUAC

		while lLoop

			if ! B0Y->( DbSeek( xFilial("B0Y") + cChave ) )

				nSizeN	 := SX3->(tamSX3(cCampo)[1])
				cProximo := strZero(1,nSizeN)

				B0Y->(recLock("B0Y",.t.))
				B0Y->B0Y_CAMPO  := cCampo
				B0Y->B0Y_CHAVE  := cCodOpe + cCodLDP + cCodPEG
				B0Y->B0Y_PROXIM := cProximo
				B0Y->(msUnLock())

			else

				cProximo := soma1(allTrim(B0Y->B0Y_PROXIM))

				B0Y->(recLock("B0Y",.f.))
				B0Y->B0Y_PROXIM := cProximo
				B0Y->(msUnLock())

			endIf

			lLoop := (cAliasPEG)->( msSeek( xFilial(cAliasPEG) + cCodOpe + cCodLDP + cCodPEG + cProximo ) )

		endDo

		(cAliasPEG)->(restArea(aArea))

	return( { cProximo } )

	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PlsSub1   ³ Autor ³ Rogerio Tabosa     Data ³ 10.02.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Substrai um valor (contrario do Soma1)                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                           ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Function PlsSub1(cValAtu, nTam)
		Local cValue := ""
		default nTam := len(cValAtu)
		If Val(cValAtu) > 0
			cValue := StrZero(Val(cValAtu) - 1, nTam)
		EndIf
	Return(cValue)


	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLVLNGUI   ³ Autor ³ TOTVS S/A         Data ³ 04/11/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Verifica se o numero da guia informado no portal existe   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Function PLVLNGUI(cChvGui,cTipGui, cNumCar, cDescricao)
		Local lRet := .T.
		Local aBkp := GetArea()

		Default cChvGui    := ""
		Default cTipGui    := ""
		Default cNumCar    := ""
		Default cDescricao := ""

		Do Case

			Case cTipGui $ '01,02'
				BE4->(dbSetOrder(2))
				dbSelectArea("BEA")
				BEA->(dbSetOrder(1))
				If !BEA->(msSeek(xFilial("BEA")+ALLTRIM(cChvGui)))
					lRet := .F.
				else
					if !Empty(cNumCar) .And. (BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO) != cNumCar .And. BEA->BEA_MATANT != cNumCar)
						cDescricao := "Guia pertence a outro beneficiário."
						lRet := .F.
					elseif BE4->( MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)) )
						if Empty(BE4->BE4_DATPRO)
							cDescricao := "Guia sem data de Internação."
							lRet := .F.
						endif
					else
						cDescricao:=""
					endif
				EndIf

		EndCase

		RestArea(aBkp)

	Return lRet


	/*/{Protheus.doc} PlsEstBC
retorna o codigo do estado

@author  PLS TEAM
@version P11
@since   15/07/2015
	/*/

	function PlsEstBC(cSigla)
		Local cEstado	:= ""
		local nPos		:= 0
		Local aUF		:=	{	{"RO","11"},;
			{"AC","12"},;
			{"AM","13"},;
			{"RR","14"},;
			{"PA","15"},;
			{"AP","16"},;
			{"TO","17"},;
			{"MA","21"},;
			{"PI","22"},;
			{"CE","23"},;
			{"RN","24"},;
			{"PB","25"},;
			{"PE","26"},;
			{"AL","27"},;
			{"MG","31"},;
			{"ES","32"},;
			{"RJ","33"},;
			{"SP","35"},;
			{"PR","41"},;
			{"SC","42"},;
			{"RS","43"},;
			{"MS","50"},;
			{"MT","51"},;
			{"GO","52"},;
			{"DF","53"},;
			{"SE","28"},;
			{"BA","29"},;
			{"EX","99"},;
			}

		nPos := aScan(aUF,{|x| x[1]==cSigla})

		if nPos>0
			cEstado := aUF[nPos,2]
		endIf

	Return cEstado


	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLFORPAGPF ³ Autor ³ Karine Riquena Limp  ³ Data ³ 04/12/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³Retorna a forma de pagamento para pessoa fisica            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLFORPAGPF(cCodPla, cCodVer, cForPag, cForCtx, lDireto, cCodInt)
		local aRet := {"","","","",""}
		Default cCodInt := PLSINTPAD()
		default lDireto := .F.
		default cForPag := ""
		default cForCtx := ""
		//Forma de Cobranca Produto
		BJ3->(DbSetOrder(1))
		If BJ3->(MsSeek(xFilial("BJ3")+cCodInt+cCodPla+cCodVer+Alltrim(cForPag)))
			aRet[1] := BJ3->BJ3_CODFOR
			aRet[2] := BJ0->(Posicione("BJ0",1,xFilial("BJ0")+BJ3->BJ3_CODFOR,"BJ0_ROTINA"))
		Else
			// Caso nao encontre a informada, busca pela forma de cobranca padrao.
			If !Empty(cCodPla) .AND. !Empty(cCodVer)
				If BJ3->(MsSeek(xFilial("BJ3")+cCodInt+cCodPla+cCodVer)) .and. lDireto
					aRet[1] := BJ3->BJ3_CODFOR
					aRet[2] := BJ0->(Posicione("BJ0",1,xFilial("BJ0")+BJ3->BJ3_CODFOR,"BJ0_ROTINA"))
				Else
					MsgStop(STR0049) //"Nao existe forma de cobranca para este produto."
				Endif
			Endif
		Endif

		//Taxa Adesao Produto
		BJ9->(DbSetOrder(1))
		If BJ9->(MsSeek(xFilial("BJ9")+cCodInt+cCodPla+cCodVer+alltrim(cForCtx)))
			aRet[3] := BJ9->BJ9_CODFOR
		Else
			// Caso nao encontre a informada, busca pela taxa de adesao padrao.
			If BJ9->(MsSeek(xFilial("BJ9")+cCodInt+cCodPla+cCodVer))
				aRet[3] := BJ9->BJ9_CODFOR
			Endif
		Endif

		// Modalidade de cobranca
		BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+cCodVer))
		aRet[4] := BI3->BI3_MODPAG

		// Pro rata na saida do usuario
		If BA3->BA3_RATSAI == "0"
			aRet[5] := BI3->BI3_RATSAI
		Else
			aRet[5] := BA3->BA3_RATSAI
		Endif
		//aRet
		//[1] Forma de pagamento
		//[2] Rotina
		//[3] Taxa de adesão do produto
		//[4] Modalidade de cobrança
		//[5] Pro rata na saida do usuario
	return aRet

	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLFORPAGPJ ³ Autor ³ Karine Riquena Limp  ³ Data ³ 07/12/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³Retorna a forma de pagamento para pessoa juridica          ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	function PLFORPAGPJ(cCodPla, cCodVer, cForPag, cForCtx, lDireto, cCodEmp, cConemp, cVerCon, cSubCon, cVerSub, cCodInt)
		local aRet := {}
		Default cCodInt := PLSINTPAD()
		default lDireto := .F.
		//Forma de Cobranca Produto
		//Forma de Cobranca Grp Empresa
		BT9->(DbSetOrder(1))
		If BT9->(MsSeek(xFilial("BT9")+cCodInt+cCodEmp+cConemp+;
				cVerCon+cSubCon+cVerSub+;
				cCodPla+cCodVer+Alltrim(cForPag)))
			aadd(aRet, BT9->BT9_CODFOR)
			aadd(aRet, BJ0->(Posicione("BJ0",1,xFilial("BJ0")+BT9->BT9_CODFOR,"BJ0_ROTINA")))
		Else
			// Caso nao encontre a informada, busca pela forma de cobranca padrao.
			If !Empty(cCodPla) .AND. !Empty(cCodVer)
				If BT9->(MsSeek(xFilial("BT9")+cCodInt+cCodEmp+cConemp+;
						cVerCon+cSubCon+cVerSub+;
						cCodPla+cCodVer)) .and. lDireto
					aadd(aRet, BT9->BT9_CODFOR)
					aadd(aRet, BJ0->(Posicione("BJ0",1,xFilial("BJ0")+BT9->BT9_CODFOR,"BJ0_ROTINA")))
				Else
					MsgStop(STR0050) //"Nao existe forma de cobranca para este produto do subcontrato."
					aadd(aRet, CriaVar('BA3_FORPAG'))
					aadd(aRet, CriaVar('BA3_ROTINA'))
				Endif
			Else
				MsgStop(STR0050) //"Nao existe forma de cobranca para este produto do subcontrato."
				aadd(aRet, CriaVar('BA3_FORPAG'))
				aadd(aRet, CriaVar('BA3_ROTINA'))
			Endif
		Endif

		//Taxa Adesao Grp Empresa
		BTK->(DbSetOrder(1))
		If BTK->(MsSeek(xFilial("BTK")+cCodInt+cCodEmp+cConemp+;
				cVerCon+cSubCon+cVerSub+;
				cCodPla+cCodVer+Alltrim(cForCtx)))
			aadd(aRet, BTK->BTK_CODFOR)
		Else
			// Caso nao encontre a informada, busca pela taxa de adesao padrao.
			If BTK->(MsSeek(xFilial("BTK")+cCodInt+cCodEmp+cConemp+;
					cVerCon+cSubCon+cVerSub+;
					cCodPla+cCodVer))
				aadd(aRet, BTK->BTK_CODFOR)
			Else
				aadd(aRet, CriaVar('BA3_FORCTX'))
			Endif
		Endif

		// Modalidade de cobranca...
		BT6->(MsSeek(	xFilial("BT6")+cCodInt+cCodEmp+cConemp+;
			cVerCon+cSubCon+cVerSub+cCodPla+cCodVer))
		aadd(aRet, BT6->BT6_MODPAG)

		// Pro rata na saida do usuario
		If	BA3->(FieldPos("BA3_RATSAI")) > 0 .and.;
				BT6->(FieldPos("BT6_RATSAI")) > 0
			aadd(aRet, BT6->BT6_RATSAI)
		Endif
		//aRet
		//[1] Forma de pagamento
		//[2] Rotina
		//[3] Taxa de adesão do produto
		//[4] Modalidade de cobrança
		//[5] Pro rata na saida do usuario
	return aRet

	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto  PLSRETOPC ³ Autor ³ Thiago Ribas  ³ Data ³ 05/04/2016 		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³Função utilizada na consulta padrão do campo BHS_CODPLA		   ³±±
				para retornar os opcionais que foram cadastrados no produto que³±±
				está vinculado ao subcontrato de onde está sendo chamada está  ³±±
				função             											   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	FUNCTION PLSRETOPC()

		LOCAL lRet 		:= .F.
		LOCAL lCadOpPrd := GetNewPar("MV_PLCDPRD", .F.)
		LOCAL cCodProd  := oBrwPro:aCols[oBrwPro:OBROWSE:nAt][GdFieldPos("BT6_CODPRO",oBrwPro:aHeader)]

		//com o parâmetro MV_PLCDPRD alterado para TRUE, a consulta padrão retorna apenas os opcionais que foram cadastrados no produto que
		//está vinculado ao subcontrato de onde está sendo chamada está função.
		If lCadOpPrd

			BT3->(dbSetOrder(1))
			If BT3->(DBSEEK(XFILIAL("BT3") + M->BQC_CODINT + cCodProd + M->BQC_VERSUB + BI3->BI3_CODIGO + BI3->BI3_VERSAO))
				lRet := .T.
			EndIf
		Else

			//Caso o parâmetro esteja com o valor FALSE, o sistema retorna o resultado de acordo com a função abaixo, está função retornará
			//os opcionais de acordo com a regra da função sem verificar o vinculo com o produto do subcontrato.

			lRet :=	PLSA800Agr()
		EndIf

	RETURN lRet


	/*/{Protheus.doc} PLSALERTA
Faz a separação das críticas e dos alertas. Esta função é utilizada
para exibir os alertas referente as rotinas de atendimento (remote e portal)

@author  PLS TEAM
@version P11
@since    04.04.16
	/*/

	Function PLSALERTA(aHisCri,aRetCri,aAlerta,aProcAut,aPrcoNeg,lConsPort,aCritMDF,lCritica)
		LOCAL aTmpCri     := {}
		LOCAL nI		  := 0
		LOCAL nCout		  := 0
		LOCAL nCtCri      := 0
		LOCAL nScan       := 0
		LOCAL lDigOff 	  := .F.

		DEFAULT aProcAut  := {}
		DEFAULT aPrcoNeg  := {}
		DEFAULT lCritica  := .F.
		DEFAULT lConsPort := .F.
		DEFAULT aCritMDF  := {}

		//se for chamado pela tela de consulta do portal do prestador, a tratativa é diferente
		//das demais rotinas. Se possuir críticas da mudança de fase da digitação off-line atribuímos essas críticas.
		if lConsPort

			if len(aCritMDF) > 0
				aTmpCri := aCritMDF
				lDigOff := .t.
			else
				aTmpCri := iIf( len(aRetCri) >= 4,aRetCri[4], {})
			endif

		else
			aTmpCri := iIf( len(aRetCri) >= 2, aRetCri[2], {} )
		endIf

		aHisCri := {}

		//Se o procedimento não possui críticas não irá fazer a separação entre alerta e critica.
		if valType(aTmpCri) == "A" .and. ! empty(aTmpCri)

			BCT->( dbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO

			for nI := 1 to len(aTmpCri)

				if ! empty(aTmpCri[nI,1])

					if BCT->( MsSeek( xFilial("BCT") + plsIntPad() + aTmpCri[nI,1] ) )

						nScan := aScan(aTmpCri,{|x| ! empty(x[1])  } ,nI + 1) - 1
						nCout := iIf( nScan <= 0, len(aTmpCri), nScan )

						if BCT->BCT_ALERTA == "1"

							for nCtCri := nI to nCout
								aadd(aAlerta, aTmpCri[nCtCri])
							next

							if lConsPort .and. ! lDigOff
								aadd(aProcAut, aClone(AretCri[6][aScan(AretCri[6],{|x|  x[1]  ==  aTmpCri[nI][1]} )]))
							endIf

						elseIf ! lDigOff

							for nCtCri := nI to nCout
								aadd(aHisCri, aTmpCri[nCtCri])
							next

							if lConsPort

								//Correção para evitar que adicione o mesmo procedimento duas vezes no array de não autorizados
								cPad := ( aRetCri[6][ aScan(aRetCri[6],{|x|  x[1]  ==  aTmpCri[nI][1]} )])[2]
								cPro := ( aRetCri[6][ aScan(aRetCri[6],{|x|  x[1]  ==  aTmpCri[nI][1]} )])[3]

								If ( aScan(aPrcoNeg,{|y| y[2] == cPad .and. y[3] == cPro } ) == 0 )
									aadd(aPrcoNeg, aClone(aRetCri[6][ aScan(aRetCri[6],{|x|  x[1]  ==  aTmpCri[nI][1]} )]))
								endIf

							endIf

							lCritica := .t.
						endIf

						nI := nCtCri - 1

					endIf

				endIf

			next

			if ! lCritica .and. ! lDigOff
				aRetCri[1] := .t.
			endIf

		endIf

		if valType(aTmpCri) != "A" .and. lConsPort .or. empty(aTmpCri) .and. lConsPort

			aHisCri   := aRetCri[4] //Critica
			aProcAut  := aRetCri[5] //Eventos autorizados
			aPrcoNeg  := aRetCri[6] //Eventos nao autorizados

		endIf

	Return


	/*/{Protheus.doc} PLSEXIBD6
Verifica se determinado procedimento existe na BD6 levando em consideração o
índice 5 da BD6 mais

@author  PLS TEAM
@version P11
@since    04.04.16
	/*/

	Function PLSEXIBD6(cMatric, dDatPro, cCodTab, cCodPro, cCodRDA, cChvBD6)

		LOCAL lRet := .F.
		Local nProc	:= 0
		Local aArea	:= BD6->(GetArea())

		Default cChvBD6 := ""

		//Se a quantidade é maior que um, já dá crítica direto, desde que não seja uma liberação
		If BD6->BD6_QTDPRO > 1 .AND. BD6->BD6_LIBERA <> "1"
			Return .T.
		EndIf

		BD6->(dbSetOrder(5))
		If BD6->(MsSeek(xFilial("BD6") + cMatric + DTOS(dDatPro) + cCodTab + cCodPro))

			While ALLTRIM(BD6->(BD6_FILIAL + BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO + DTOS(BD6_DATPRO) + BD6_CODPAD + BD6_CODPRO)) ==;
					ALLTRIM(xFilial("BD6") + cMatric + DTOS(dDatPro) + cCodTab + cCodPro)

				If BD6->BD6_CODRDA == cCodRDA .AND. BD6->BD6_SITUAC == "1" .AND. BD6->BD6_LIBERA == "0" .AND. IIF(EmpTy(cChvBD6), .T., BD6->(BD6_CODOPE + BD6_CODPEG + BD6_CODLDP + BD6_NUMERO) == cChvBD6)

					nProc++

					if nProc > 1
						lRet := .T.
						EXIT
					EndIf
				EndIf

				BD6->(dbSkip())
			EndDo
		EndIf

		restArea(aArea)

	Return lRet

	/*/{Protheus.doc} PLSCRIBNF

Exibir críticas no Portal do beneficiário para os procedimentos negados
@author Renan Martins
@since 03/06/2016
@version P12
@obs
	/*/

	Function PLSCRIBNF (cChave)
		LOCAL nRecBD5
		LOCAL aCrit 	:= {}
		LOCAL aPosic	:= {}
		LOCAL cCodPro	:= ""
		LOCAL cTipGui	:= ""
		LOCAL cAliasC	:= ""
		LOCAL cAliOpe	:= ""
		LOCAL cAliAno	:= ""
		LOCAL cAliMes	:= ""
		LOCAL cAliNum	:= ""
		LOCAL cAliSeq	:= "_SEQUEN"
		LOCAL cAliasGui := ""
		LOCAL cChaveBEG := ""
		LOCAL lParecNeg := .F.
		LOCAL cRecno    := ""
		LOCAL nLenRecno := 0

		aPosic := SEPARA(cChave,"~",.F.)

		IF ( aPosic[2] $ ("BE2,B4C") )
			cAliasC := "BEG"
		ELSE
			cAliasC := "BEL"
		ENDIF

		&(cAliasC)->(DbSetOrder(1))
		&(cAliasC)->(MsSeek(xFilial(cAliasC) + aPosic[1]))

		//Monta parte da chave com os dados da BEG
		cChaveBEG := (cAliasC)->&(cAliasC+"_SEQUEN") + AllTrim((cAliasC)->&(cAliasC+"_CODGLO"))

		If aPosic[2] == "BE2"

			cAliasGui := "BEA"
			&(cAliasGui)->(DbSetOrder(1))

		ElseIf aPosic[2] == "B4C"

			cAliasGui := "B4A"
			&(cAliasGui)->(DbSetOrder(1))

		Else
			cAliasGui := "BE4"
			&(cAliasGui)->(DbSetOrder(2))
		EndIf

		//faz o seek na tabela onde a guia foi criada para pegar o recno que será usado na B72.
		If &(cAliasGui)->(MsSeek(xFilial(cAliasGui) + substr(aPosic[1],1,18)))

			cRecno    := ALLTRIM(STR(&(cAliasGui)->(RECNO())))
			nLenRecno := LEN(cRecno)

			//o cRecno deve receber exatamente o tamanho do campo para o localizar o registro da B72.
			cRecno    += Space(TAMSX3("B72_RECMOV")[1] - nLenRecno)

			B72->(dbSetOrder(1))
			If B72->(MsSeek(xFilial("B72") + cAliasGui + cRecno + cChaveBEG ))

				// se o procedimento foi negado e possui motivo.
				If B72->B72_PARECE == "1" .AND. !EMPTY(B72->B72_MOTIVO)

					BCT->(dbSetOrder(1))
					If BCT->(MsSeek(xFilial("BCT") + PlsIntPad() + B72->B72_MOTIVO))

						aAdd( aCrit, {{{B72->B72_MOTIVO,BCT->BCT_DESCRI,.T.}}} )
					Else
						aAdd( aCrit, {{{STR0251,STR0252,.F.}}} ) //"ERRO"##"Não foi possível exibir o motivo da negativa, entre em contato com a operadora."
					EndIf

					lParecNeg := .T.
				EndIf
			EndIf

		EndIf

		//apenas será exibida as críticas do procedimento caso não tenha um parecer.
		If !lParecNeg

			cAliOpe	:= IIF( (aPosic[2] $ "BE2,B4C"), cAliasC+"_OPEMOV", cAliasC+ "_CODOPE" )
			cAliAno	:= IIF( (aPosic[2] $ "BE2,B4C"), cAliasC+"_ANOAUT", cAliasC+"_ANOINT" )
			cAliMes	:= IIF( (aPosic[2] $ "BE2,B4C"), cAliasC+"_MESAUT", cAliasC+"_MESINT" )
			cAliNum	:= IIF( (aPosic[2] $ "BE2,B4C"), cAliasC+"_NUMAUT", cAliasC+"_NUMINT" )
			cAliSeq	:= cAliasC+cAliSeq

			While !&(cAliasC)->(EOF()) .AND. (cAliasC)->&(cAliOpe) + (cAliasC)->&(cAliAno) + (cAliasC)->&(cAliMes) + (cAliasC)->&(cAliNum) + (cAliasC)->&(cAliSeq)  == aPosic[1]

				IF ( Alltrim((cAliasC)->&(cAliasC+"_CODGLO")) <> "" )

					aAdd( aCrit, {PLSRETCRI (AllTrim((cAliasC)->&(cAliasC+"_CODGLO")),,.T.)} )
				ENDIF

				&(cAliasC)->(DbSkip())
			ENDDO
		EndIf
	Return aCrit

	/*/{Protheus.doc} PLSADtAlt
Data de Alta

@author  Roberto
@version P11
@since   11/09/2017
	/*/
	Function PLSADtAlt(lRpc,dDatAlt,cHorAlt, cMotAlt, cCriTSISS)
		Local cMsg 			:= ""
		Local lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70"
		Local aRet700 		:= {}

		DEFAULT lRpc := .F.
		DEFAULT cCriTSISS := ""

		//Se foi cancelada
		If BE4->BE4_SITUAC == '2'
			If lRpc
				cMsg := STR0164//"A Guia selecionada foi cancelada."
				cCriTSISS := "1404"

				Return cMsg
			Else
				Help("",1,"PLSA092CAN")
				cCriTSISS := "1404"

				Return cMsg
			EndIf
		EndIf

		//Se nao foi autorizada
		If BE4->BE4_STATUS == "3" .OR. BE4->BE4_STATUS == "6"
			If !lRpc
				Aviso( STR0096, STR0100 , {  STR0099  }, 2 ) //"A guia nao foi autorizada."
			Else
				cMsg := STR0100 //"A guia nao foi autorizada."
			EndIf
			cCriTSISS := "1402"

			Return cMsg
		EndIf

		cMotAlt := alltrim(PLSVARVINC('39', nil, cMotAlt) )

		//Se for uma guia de intercambio na Versao 7.0, realizo a comunicacao 007
		If lPTUOn70 .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050") .And. (!Empty(BE4->BE4_NRTROL) .And. Val(BE4->BE4_NRTROL) != 0) .And. !Empty(dDatAlt)

			aRet700 := PLEnvPT750("A",dDatAlt,lRpc,cMotAlt)

			If aRet700[1] .And. !lRpc
				Aviso( STR0175,"Comunica?o de alta realizada com sucesso.",{ STR0099 }, 2 )
			ElseIf !aRet700[1]
	
				cMsg := aRet700[2]
				cCriTSISS := "1404"
				
				Return cMsg

			Endif

		Endif

		// Atualiza a data de internacao
		BE4->( RecLock("BE4", .F.) )
		BE4->BE4_DTALTA := dDatAlt
		BE4->BE4_HRALTA := cHorAlt
		BE4->BE4_TIPALT := cMotAlt
		BE4->( MsUnLock() )

		// Integração do Aviso de Internação (API)
		If FindFunction("PLMapIntAviso")
			PLMapIntAviso(BE4->BE4_CODOPE, BE4->BE4_ANOINT, BE4->BE4_MESINT, BE4->BE4_NUMINT)
		EndIf

		//Informa ao HAT a atualizacao dos dados
		if GetNewPar("MV_PLSHAT","0") == "1" .And. BE4->(FieldPos("BE4_COMAUT")) > 0
			P92ComGHat(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT))
		endIf

	Return cMsg

	/*/{Protheus.doc} PLSRETMAT

Retorna a matricula antiga ou nova do beneficiário
@author Thiago Guilherme
@since 31/01/2017
@version P12
	/*/

	Function PLSMATBEN(cMatric)

		LOCAL lCoMatAnt   := GetNewPar("MV_PLMANT",.F.)

		If lCoMatAnt

			BA1->(DbSetOrder(2))
			If BA1->(MsSeek(xFilial("BA1") + cMatric))

				If !EMPTY(BA1->BA1_MATANT)

					BED->(DbSetorder(5))
					If !BED->(MsSeek(xFilial("BED") + BA1->BA1_MATANT))
						cMatric := BA1->BA1_MATANT
					EndIf
				EndIf
			EndIf
		EndIf

	Return cMatric


	/*/{Protheus.doc} PLMFEMJOB - PLS MUDA FASE EM JOB
Prepara para Mudar a fase  em segundo plano após a execução de uma guia no portal
Essa opção foi criada para não haver necessidade de um prestador gravar uma autorizão e ter que esperar a mudança de fase
nesse momento
@author  Rogério Tabosa
@version P12
@since   01/2017
	/*/
	function PLMFEMJOB(nRecBCL, nRecAliCab,nRecBCI,cAliasCab,nRecBAU,aParMF,aParNov,aDadRda,cAliasIte,nRecIte)

		startJob("PLMFEXJOB", getEnvServer(), .f., cEmpAnt, cFilAnt, nRecBCL, nRecAliCab,nRecBCI, cAliasCab,nRecBAU, aParMF, aParNov,aDadRda,cAliasIte,nRecIte)

	return

	/*/{Protheus.doc} PLMFEXJOB - PLS MUDA FASE EM JOB
Efetivo a execução do JOB após preparar o enviroment
@author  Rogério Tabosa
@version P12
@since   01/2017
	/*/
	function PLMFEXJOB(cEmpAnt, cFilAnt, nRecBCL, nRecAliCab, nRecBCI, cAliasCab,nRecBAU, aParMF, aParNov,aDadRda,cAliasIte,nRecIte)

		rpcSetType(3)
		rpcSetEnv(cEmpAnt, cFilAnt,,,'PLS')

		lJob := .t.
		lWeb := .t.

		BCL->( dbSetOrder(1) )
		BCL->( dbGoTo( nRecBCL ) )

		(cAliasCab)->( dbSetOrder(1) )
		(cAliasCab)->( dbGoTo( nRecAliCab ) )

		//Internacao devo posicionar no BE4
		if cAliasCab == "BEA" .And. BEA->BEA_TIPGUI == "03"
			BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
			BE4->(MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
		endIf

		(cAliasIte)->( dbSetOrder(1) )
		(cAliasIte)->( dbGoTo( nRecIte ) )

		BCI->( dbSetOrder(1) )
		BCI->( dbGoTo( nRecBCI ) )

		BAU->( dbSetOrder(1) )
		BAU->( dbGoTo( nRecBAU ) )

		aParFas:= PLSA090MF(aParNov[1],aParNov[2],aParNov[3],aParNov[4],aParNov[ 5],aParNov[6],aParNov[7],aParNov[8],aParNov[9],aParNov[10],aParNov[11],aParNov[12],aParNov[13],aParNov[14],;
			aParNov[15],aParNov[16],aParNov[17],aParNov[18],aParNov[19],aParNov[20],aParNov[21],aParNov[22],aParNov[23],aParNov[24],aParNov[25],aParNov[26],aParNov[27],aParNov[28],;
			aParNov[29],aParNov[30],aParNov[31],aParNov[32],aParNov[33],aParNov[34],aParNov[35],aParNov[36],aParNov[37],aParNov[38],aParNov[39],aParNov[40],aParNov[41],aParNov[42])


		cAliasPri := aParFas[3]
		nRecAliPri:= aParFas[4]

		(cAliasPri)->( dbSetOrder(1) )
		(cAliasPri)->( dbGoTo( nRecAliPri ) )


		PLSXMUDFAS(cAliasPri,aParMF[2],aParMF[3],aParMF[4],aParMF[5],aParMF[6],aParMF[7],aParMF[8],aParMF[9],aParMF[10],aParMF[11],aParMF[12],aParMF[13],aParMF[14],;
			aParMF[15],aParMF[16],aParMF[17],aParMF[18],aParMF[19],aParMF[20],aParMF[21],aParMF[22],aParMF[23],aParMF[24],aParMF[25],aParMF[26],aParMF[27], aParMF[28],aParMF[29])

		rpcClearEnv()

	return

	//Função apra veficiar se o saldo de uma guia ainda existe quando o usuario finalizar ela
	//Se algum dia conseguirmos impedir o carinha de executar simultaneamente a mesma guia em
	//mais de um lugar (computador/aba/navegador), não precisaremos mais disso
	Function PLWebSaldo(cNumLib, lDigiGuia)

		Local lRet := .F.
		Local aArea := BE2->(GetArea())
		Default lDigiGuia := .F.

		If lDigiGuia
			lRet := .T.
		Else
			BE2->(DbsetOrder(1))
			If BE2->(MsSeek(xFilial("BE2") + cNumLib))
				If BE2->BE2_TIPGUI <> '02' //só vale pra SADT
					lRet := .T.
				else
					While( !(BE2->(EoF())) .AND. xFilial("BE2") == BE2->BE2_FILIAL .AND. cNumLib == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) )
						If BE2->BE2_SALDO > 0 .AND. BE2->BE2_STATUS == '1'
							lRet := .T.
							Exit
						EndIf
						BE2->(DbSkip())
					EndDo
				EndIf
				BE2->(Restarea(aArea))
			EndIf
		EndIf

	Return lRet


	/*/{Protheus.doc} PLCANPROG
Cancela as prorrogações vinculadas a uma internação que está sendo
cancelada
@author  Thiago Ribas
@version P12
@since   05/2017
	/*/

	Function PLCANPROG(cNunGuia)

		default cNunGuia := ""

		B4Q->(dbSetOrder(4))
		If B4Q->(MsSeek(xFilial("B4Q") + cNunGuia))

			While !B4Q->(EOF()) .AND. B4Q->(B4Q_FILIAL + B4Q_GUIREF) == xFilial("BE4") + cNunGuia

				//Verifica se a guia já está cancelada
				If B4A->B4A_CANCEL != '1'
					PLSA09PCAN(,,,,.T.,.T.)
				EndIf

				B4Q->(dbSkip())
			EndDo
		EndIf

	Return

	/*/{Protheus.doc} PLVALAUDT
Verifica se a guia está em auditoria e altera corretamente o status
se necessário.
@author  PLSTEAM
@version P12
@since   02/2017
	/*/
	Function PLVALAUDT(cAlicab, cNumGuia, cStatus, lInterna)
		LOCAL cSQL    	 := ""
		LOCAL nAut    	 := 0
		LOCAL nNeg       := 0

		DEFAULT lInterna := .F.

		If cStatus == "6"

			If lInterna
				cAlicab := "BE4"
			EndIf

			B53->(dbSetOrder(1))
			If !B53->(msSeek(xFilial("B53") + cNumGuia))

				If cAlicab == "BEA"

					cSQL := " SELECT BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT GUIA, CASE WHEN BE2_STATUS = '1' THEN '1' ELSE '' END APROVADO, "
					cSQL += " CASE WHEN BE2_STATUS = '0' THEN '1' ELSE '' END NEGADO "
					cSQL += " FROM " + RetSQLName("BEA") + " BEA "

					cSQL += " INNER JOIN " + RetSQLName("BE2") + " BE2 "
					cSQL += "    ON BE2_FILIAL = '" + xFilial("BE2") + "' "
					cSQL += "	AND BE2_OPEMOV = BEA_OPEMOV "
					cSQL += "	AND BE2_ANOAUT = BEA_ANOAUT "
					cSQL += "	AND BE2_MESAUT = BEA_MESAUT "
					cSQL += "	AND BE2_NUMAUT = BEA_NUMAUT "
					cSQL += "   AND BE2.D_E_L_E_T_  = ' ' "

					cSQL += " WHERE BEA_FILIAL = '"+xFilial("BEA")+"' "
					cSQL += "   AND BEA_OPEMOV = '" + Substr(cNumGuia,  1, 4) + "' "
					cSQL += "   AND BEA_ANOAUT = '" + Substr(cNumGuia,  5, 4) + "' "
					cSQL += "   AND BEA_MESAUT = '" + Substr(cNumGuia,  9, 2) + "' "
					cSQL += "   AND BEA_NUMAUT = '" + Substr(cNumGuia, 11, 8) + "' "
					cSQL += "   AND BEA.D_E_L_E_T_  = ' ' "

					cSQL += " GROUP BY BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT, BE2_STATUS"

				ElseIf cAlicab == "BE4"

					cSQL := " SELECT BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT GUIA, CASE WHEN BEJ_STATUS = '1' THEN '1' ELSE '' END APROVADO, "
					cSQL += " CASE WHEN BEJ_STATUS = '0' THEN '1' ELSE '' END NEGADO "
					cSQL += " FROM " + RetSQLName("BE4") + " BE4 "
					cSQL += " INNER JOIN " + RetSQLName("BEJ") + " BEJ "
					cSQL += "    ON BEJ_FILIAL = '" + xFilial("BEJ") + "' "
					cSQL += "	AND BEJ_CODOPE = BE4_CODOPE "
					cSQL += "	AND BEJ_ANOINT = BE4_ANOINT "
					cSQL += "	AND BEJ_MESINT = BE4_MESINT "
					cSQL += "	AND BEJ_NUMINT = BE4_NUMINT "
					cSQL += "   AND BEJ.D_E_L_E_T_  = ' ' "

					cSQL += " WHERE BE4_FILIAL = '"+xFilial("BE4")+"' "
					cSQL += "   AND BE4_CODOPE = '" + Substr(cNumGuia,  1, 4) + "' "
					cSQL += "   AND BE4_ANOINT = '" + Substr(cNumGuia,  5, 4) + "' "
					cSQL += "   AND BE4_MESINT = '" + Substr(cNumGuia,  9, 2) + "' "
					cSQL += "   AND BE4_NUMINT = '" + Substr(cNumGuia, 11, 8) + "' "
					cSQL += "   AND BE4.D_E_L_E_T_  = ' ' "

					cSQL += " GROUP BY BE4_CODOPE,BE4_ANOINT,BE4_MESINT,BE4_NUMINT,BEJ_STATUS"

				ElseIf cAlicab == "B4A"

					cSQL := " SELECT B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT GUIA, CASE WHEN B4C_STATUS = '1' THEN '1' ELSE '' END APROVADO, "
					cSQL += " CASE WHEN B4C_STATUS = '0' THEN '1' ELSE '' END NEGADO "
					cSQL += " FROM " + RetSQLName("B4A") + " B4A "
					cSQL += " INNER JOIN " + RetSQLName("B4C") + " B4C "
					cSQL += "    ON B4C_FILIAL = '" + xFilial("B4C") + "' "
					cSQL += "	AND B4C_OPEMOV = B4A_OPEMOV "
					cSQL += "	AND B4C_ANOAUT = B4A_ANOAUT "
					cSQL += "	AND B4C_MESAUT = B4A_MESAUT "
					cSQL += "	AND B4C_NUMAUT = B4A_NUMAUT "
					cSQL += "   AND B4C.D_E_L_E_T_  = ' ' "

					cSQL += " WHERE B4A_FILIAL = '"+xFilial("B4A")+"' "
					cSQL += "   AND B4A_OPEMOV = '" + Substr(cNumGuia,  1, 4) + "' "
					cSQL += "   AND B4A_ANOAUT = '" + Substr(cNumGuia,  5, 4) + "' "
					cSQL += "   AND B4A_MESAUT = '" + Substr(cNumGuia,  9, 2) + "' "
					cSQL += "   AND B4A_NUMAUT = '" + Substr(cNumGuia, 11, 8) + "' "
					cSQL += "   AND B4A.D_E_L_E_T_  = ' ' "

					cSQL += " GROUP BY B4A_OPEMOV,B4A_ANOAUT,B4A_MESAUT,B4A_NUMAUT,B4C_STATUS"

				EndIf

				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

				While !Trb->(EOF())

					If TRB->APROVADO == "1"

						nAut++

					ElseIf TRB->NEGADO == "1"

						nNeg++
					EndIf

					TRB->(dbSkip())
				EndDo

				Trb->(DbCloseArea())

				&(cAlicab+"->(RecLock('"+cAlicab+"',.F.))")

				If nAut > 0 .and. nNeg == 0

					&(cAlicab+"->"+cAlicab+"_STATUS") := "1"
					&(cAlicab+"->"+cAlicab+"_AUDITO") := "0"

					If cAlicab == "BEA"
						&(cAlicab+"->"+cAlicab+"_STALIB") := "1"
					EndIf

				ElseIf nAut > 0 .and. nNeg > 0

					&(cAlicab+"->"+cAlicab+"_STATUS") := "2"
					&(cAlicab+"->"+cAlicab+"_AUDITO") := "0"

					If cAlicab == "BEA"
						&(cAlicab+"->"+cAlicab+"_STALIB") := "1"
					EndIf

				ElseIf nAut == 0 .and. nNeg > 0

					&(cAlicab+"->"+cAlicab+"_STATUS") := "3"
					&(cAlicab+"->"+cAlicab+"_AUDITO") := "0"

					If cAlicab == "BEA"
						&(cAlicab+"->"+cAlicab+"_STALIB") := "2"
					EndIf

				EndIf

				&(cAlicab+"->(MsUnlock())")
			EndIf

		EndIf

	Return

	/*/{Protheus.doc} PLGERSEQE

Gera sequencial numérico a partir de um indice específico.

@cAlias Alias da tabela que será pesquisada
@cCampoSeq campo que será a base do sequencial
@aIndice indice usado na condição que determinara o registro da tabela que será usado como base.
Primeira posição é o campo da condição e a segunda posição é o valor da condição

@author  Thiago Ribas
@version P12
@since   09/2017
	/*/
	Function PLGERSEQE(cAlias, cCampoSeq, aIndice,nOpc)
		LOCAL cSQL   := ""
		LOCAL nInd   := LEN(aIndice)
		LOCAL cSquen := ""
		LOCAL nI     := 0

		cSQL := "SELECT MAX(" + cCampoSeq + ") " + cCampoSeq + " FROM " + RetSQLName(cAlias) + " WHERE "

		For nI := 1 To nInd
			cSQL += aIndice[nI][1] + " = '" + aIndice[nI][2] + "' AND "
		Next

		cSQL += " D_E_L_E_T_ = ' '"

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBSEQUEN",.T.,.F.)

		If ! TRBSEQUEN->(Eof()) .AND. !EMPTY(TRBSEQUEN->&(cCampoSeq))
			cSquen := Soma1( TRBSEQUEN->&(cCampoSeq) )
		Else
			cSquen := STRZERO(1,TamSX3(cCampoSeq)[1],0)
		EndIf

		TRBSEQUEN->(DbCloseArea())

	Return cSquen


	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLXmlAutom
Retorna o BODY de um XML

@author  Renan Sakai
@version P12
@since   10/09/2018
	/*/
	//-------------------------------------------------------------------
	Function PLXmlAutom(cXml, cResponse)
		Local nPos    := 0
		Local nX      := 0
		Local cXmlAux := ""
		Local oXml
		Local lRet    := .F.

		nPos := At(cResponse,Upper(cXml))
		cXmlAux := Substr(cXml,nPos+4,len(cXml))
		nPos := At(">",Upper(cXmlAux))
		cXmlAux := Substr(cXmlAux,nPos+1,len(cXmlAux))

		nPos := At(cResponse,Upper(cXmlAux))

		// Remove valores que não precisa para montar o body do XML
		For nX := 1 to nPos
			If Substr(cXmlAux,nPos-nX,1) == "<"
				cXmlAux := Substr(cXmlAux,1,nPos-(nX+1))
				Exit
			EndIf
		Next

		// Monta o XML em um objeto
		oXML := TXmlManager():New()

		If oXML:Parse(cXmlAux)
			lRet := .T.
		EndIf

	Return {lRet,oXml}

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLTagAutom
Retorna as tags do XML

@author  Renan Sakai
@version P12
@since   11/09/2018
	/*/
	//-------------------------------------------------------------------
	Function PLTagAutom(oXml,cTree,cTpDado)
		Local nX        := 0
		Local nY		  := 1
		Local cString   := ""
		Local aAux      := {}
		Local xRet      := ""
		Local aResult   := {}
		Local aItens 	  := {}
		Local aPontual  := {}

		Default cTree   := ""
		Default cTpDado := "C"

		aAux := StrTokArr( cTree,"\")
		cString := oXml:cPath

		For nX := 1 to len(aAux)
			cString += "/"+aAux[nX]
		Next

		// Retorna um array com as subtags de uma tag
		if cTpDado == "A"

			xRet := oXml:XPathGetChildArray(cString)

			// Busca os dados da tag principal
			for nX := 1 to len (xRet)

				aadd(aItens, oXml:XPathGetChildArray(xRet[nX][2]))

				// Retorna os valores da subtag
				aPontual := {}
				for nY := 1 to len (aItens[nX])

					aadd(aPontual, oXml:XPathGetNodeValue(aItens[nX][nY][2]))

				next

				aadd(aResult, aclone(aPontual))
			next
		else

			// Retorna a tag se o tipo de dado não for array
			xRet := oXml:XPathGetNodeValue(cString)

		EndIf

		// Trata valores em caso de uma tag do tipo DATA
		If cTpDado == "D"
			xRet := Replace(xRet,"-","")
		EndIf

		if cTpDado == "A"
			Return aResult

		else
			Return xRet
		EndIf

		//-------------------------------------------------------------------
		/*/{Protheus.doc} PLSMnDefY
retorna o arotina do PLSCABIte, função genérica de montar telas

@author  Oscar Zanin
@version P12
@since   08/04/2019
		/*/
		//-------------------------------------------------------------------
		function PLSMnDefY(lRotAux, cAlias1, aRotAux, lReadOnly)

			Local nTamRot := 0
			Local nI		:= 1
			Local aRotina := {	{ STR0133	, 'AxPesqui'	, 0 , K_Pesquisar  },;
				{ STR0134	, 'MntPlsCI'	, 0 , K_Visualizar },;
				{ STR0135	, 'MntPlsCI'	, 0 , K_Incluir    },;
				{ STR0136	, 'MntPlsCI'	, 0 , K_Alterar    },;
				{ STR0137	, 'MntPlsCI'	, 0 , K_Excluir    } }

			Default lRotAux    := .F.
			DEFAULT lReadOnly  := .F.
			DEFAULT aRotAux    := {}

			If lRotAux

				If cAlias1 == 'BSW'
					aadd(aRotina, {"Alterar Senha" , 'PLSPORSEN(Nil,"BSW_SENHA")', 0,6})
				else
					aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BAQ',BAQ->BAQ_CODESP, 1)})", 0 ,K_Visualizar})
					aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BAQ',BAQ->BAQ_CODESP, 0)})", 0 ,K_Visualizar})
				endIf

			EndIf

			nTamRot := Len(aRotAux)
			If nTamRot > 0
				For nI := 1 to nTamRot
					aadd(aRotina, aRotAux[nI])
				Next
			EndIf
			If lReadOnly
				aRotina   := { { STRPL01	, 'AxPesqui'	, 0 , K_Pesquisar  },;
					{ STRPL02	, 'MntPlsCI'	, 0 , K_Visualizar }}
			Endif

		return aclone(aRotina)

		/*/{Protheus.doc} plRCCre
Retorna o cBox do campo BAU_COPCRE e BBH_TPPRES

@author  PLS TEAM
@since   21.03.17
		/*/
		function plRCCre()
			local cRet := "0=Nulo;1=Proprio/Assalariado;2=Prestador;3=Nao Prestador;4=Rede Propria;5=Rede Conveniada;6=Intercambio"

		return cRet

		//-------------------------------------------------------------------
		/*/{Protheus.doc} StrTPLS
Substitui as letras de uma String pelo caracter passado por parametro
@author  Vinicius.Queiros
@version P12
@since   08/06/2020
@Param  cString  : String que sera realizada a alteração
	 	cReplace : Caracter que substituira as Letras
		/*/
		//-------------------------------------------------------------------

		Function StrTPLS(cString,cReplace)

			Local cNewString := ""
			Local nLenString := Len(cString)
			Local i

			Default cString  := ""
			Default cReplace := "0"

			For i := 1 to nLenString
				If !(Substr(cString,i,1)) $ "0/1/2/3/4/5/6/7/8/9"
					cNewString += cReplace
				Else
					cNewString += Substr(cString,i,1)
				EndIf
			Next i

		Return cNewString

/*/{Protheus.doc} PlsGtlEsp
	(long_description)
	@type  Function
	@author Thiago Rodrigues.
	@since 18/11/2020
	@param Codigo da RDA, Especialidade, Local, data do processamento
	@return Retorna a primeira especialidade valida considerando a principal
	/*/
Function PlsGtlEsp(cCodrda,cCodOpe,cCodLoc,dData)
local cCodEsp   := ""
local cChave    := ""
local cCodEspP  := ""
local lPassou   := .f.

if empty(dData)
	dData:= dDataBase
endif 

cChave:= (xFilial("BAX")+cCodrda+cCodOpe+cCodLoc) 
BAX->(DbSetOrder(1)) //BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC

if BAX->(MsSeek(cChave))

	While !BAX->(Eof()) .And. BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC) == cChave		
		
		If  (Empty(BAX->BAX_DATBLO) .Or. dtos(dData) < dtos(BAX->BAX_DATBLO) )

			if BAX->BAX_ESPPRI == '1'
				cCodEspP = BAX->BAX_CODESP
				exit
			Endif

			if !lPassou
				cCodEsp = BAX->BAX_CODESP
				lPassou := .t.
			endif	
		endif

		BAX->(DbSkip())
	Enddo
endif
cCodEsp := iif(empty(cCodEspP),cCodEsp,cCodEspP)

Return cCodEsp


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMesPagTitulo
Retorna o Mês de Pagamento do Título principal vinculado ao NCC ou
a Compensação

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 28/12/2021
/*/
//-------------------------------------------------------------------
Static Function GetMesPagTitulo(cPrefixo, cNumero, cParcela, cTipo, cDocumen)

	Local nMesPago := 0
	Local cQuery := ""
	Local cAliasTemp := ""
	Local nTamPrefixo := TamSX3("E5_PREFIXO")[1]
	Local nTamNumero := TamSX3("E5_NUMERO")[1]
	Local nTamParcela := TamSX3("E5_PARCELA")[1]

	Default cPrefixo := ""
	Default cNumero := ""
	Default cParcela := ""
	Default cTipo := ""
	Default cDocumen := ""

	If cTipo == "NCC" .And. !Empty(cDocumen)
		cPrefixo := Substr(cDocumen, 1, nTamPrefixo) 
		cNumero := Substr(cDocumen, (nTamPrefixo + 1), nTamNumero)
		cParcela := Substr(cDocumen, (nTamPrefixo + nTamNumero + 1), nTamParcela)
	EndIf

	cAliasTemp := GetNextAlias()
	cQuery := " SELECT SE5.E5_DATA FROM  "+RetSqlName("SE5")+" SE5 "
	cQuery += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery += "   AND SE5.E5_PREFIXO = '"+cPrefixo+"' "
	cQuery += "   AND SE5.E5_NUMERO = '"+cNumero+"' "
	cQuery += "   AND SE5.E5_PARCELA = '"+cParcela+"' "
	cQuery += "   AND SE5.E5_TIPO <> 'NCC' "
	cQuery += "   AND SE5.E5_TIPODOC <> 'CP' "
	cQuery += "   AND SE5.E5_RECPAG = 'R'"
	cQuery += "   AND SE5.D_E_L_E_T_ = ' '"

	dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)
	        
	If !(cAliasTemp)->(Eof())

		nMesPago := Val(Substr((cAliasTemp)->E5_DATA, 5, 2))	

	EndIf

	(cAliasTemp)->(DbCloseArea())

Return nMesPago

//Para compatibilizar chamadas de função do legado somente, não remover sem verificar o HSP
Function X3Descri()
return X3Descric()


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSGETCAMP
Retorno de função, pois está sendo utilizado no Vld.Usuário do campo
BR8_UNCAR, como o Vld.Usuário é um campo travado, com a sua remoção
estava gerando error log na rotina Tabela Padrão, na aba de carência.

@author Gabriela Cattin Gomes
@version Protheus 12
@since 07/06/2022
/*/
//-------------------------------------------------------------------
Function PLSGETCAMP()
Local lRet := .T.

return lRet
