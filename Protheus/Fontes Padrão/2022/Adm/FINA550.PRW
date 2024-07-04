#INCLUDE "FINA550.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lPmsInt:= IsIntegTop(,.T.)
//Permite reposição manual do caixinha com valores acima do limite: 1 - Permite; 2 - Não permite.
STATIC lRpMnAcLim	:= SuperGetMV("MV_RPCXMN",.T.,"1") == "1"
//Permite que sejam realizadas reposições acima do valor do caixinha: T - Permite; F - Não Permite
STATIC lRpAcVlCx	:= SuperGetMV("MV_RPVLMA",.T.,.F.)
STATIC __lArgTal	:= nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA550  ³ Autor ³ Leonardo Ruben        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao de Caixinhas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA550()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³                              ATUAIZACOES SOFRIDAS                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador        ³ Data   ³ BOPS ³           Motivo da Alteracao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºWagner    ³08/06/10³        ³      *Implementação do ITF sem incidênciaº±±
±±ºMontenegro         ³        ³      ³quando Banco origem  $não pertença º±±
±±³                                   *aos parametros MV_CXFIN/MV_CARTEIR º±±
±±³                                   * e IsCaixaLOJA().                  º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINA550(nPosArotina,lAutomato)

LOCAL cFilSET  			//Expressao de filtro da mBrowse

DEFAULT lAutomato := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra/Altera lancamentos contabeis mv_par01 Sim/Nao         ³
//³ Aglutina lancamentos contabeis      mv_par02 Sim/Nao         ³
//³ Lancamento contabil On-Line         mv_par03 Sim/Nao         ³
//³ Considera Limite Bancario           mv_par04 Sim/Nao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Considera Integracao com PMS        mv_par05 Sim/Nao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega funcao Pergunte									         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg("FIA550",.T.)})

Pergunte("FIA550",.F.)

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
PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro :=OemtoAnsi(STR0008 )  //"Manutencao de Caixinhas"

F550IniArg()

dbSelectArea("SET")
dbSetOrder(1)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de Filtros na mBrowse                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FT550FIL")
	cFilSET := ExecBlock("FT550FIL",.f.,.f.)
	If !Empty(cFilSET)
		dbSetFilter( { || &cFilSET}, cFilSET )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFAULT nPosArotina := 0
If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
	dbSelectArea("SET")
	bBlock := &( "{ |a,b,c,d,e,f| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e,f) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lAutomato)
Else
	mBrowse( 6, 1,22,75,"SET",,,,,,FA550Legend())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cFilSET)
	dbClearFilter()
	RetIndex("SET")
EndIf

Set Key VK_F12 To
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Inclui³ Autor³ Leonardo Ruben        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao no Cadastro de Caixinhas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fA550Inclui()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo										 ³±±
±±³			 ³ ExpN1 = N£mero do registro 										³±±
±±³			 ³ ExpN2 = N£mero da op‡„o selecionada 							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Inclui(cAlias,nReg,nOpc,lAutomato)
Local lPanelFin := IsPanelFin()
Local lRepos    := .T.
Local aButtons := {}
Local aUsButtons
LOCAL nOpcA
Local aArea	:=	GetArea()
Local lRet	:= .T.
Local lAtuSldNat := .T.
Local aDim := {}
Local nRecno
Local aAreaSET := {}
nMoedaBco := IIf( Type('nMoedaBco') == 'U',0,nMoedaBco )

DEFAULT lAutomato := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

If !CtbValiDt(,dDatabase,,,,{"FIN001"},)
	Return
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia lancamento no PCO                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000359")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se permite inclusao                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F550INCL")
	lRet := ExecBlock("F550INCL",.F.,.F.)
	If !lRet
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "FT550BUT" )
	aUsButtons := ExecBlock( "FT550BUT", .F., .F. )
	AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
EndIf

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	If lPanelFin
		dbSelectArea("SET")
		RegToMemory("SET",.T.,,,FunName())
		oPanelDados := FinWindow:GetVisPanel()
		oPanelDados:FreeChildren()
		aDim := DLGinPANEL(oPanelDados)
		Inclui := .T.
		nOpca := AxInclui(cAlias,nReg,nOpc,,,,"PcoVldLan('000359','01','FINA550') .AND. FA550TOK()",,,,,,,,,.T.,oPanelDados,aDim,FinWindow)
 	Else
 		If !lAutomato
			nOpcA := AxInclui(cAlias,nReg,nOpc,,,,"PcoVldLan('000359','01','FINA550') .AND. FA550TOK()",,,aButtons)
		Else
			If FindFunction("GetParAuto")
				aRetAuto := GetParAuto("FINA550TESTCASE")
				nOpcA := AxInclui(cAlias,nReg,nOpc,,,,"PcoVldLan('000359','01','FINA550') .AND. FA550TOK()",,,aButtons,,aRetAuto[1])
			EndIf
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunta se deseja fazer reposicao neste instante, se estiver aberto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA==1
		Reclock("SET",.F.)
		Replace ET_SEQCXA	With "000001"
		MsUnlock()
		PcoDetLan("000359","01","FINA550")

		// Atualiza o saldo da natureza na criacao do caixinha (como realizado)
		If lAtuSldNat
			aAreaSET := SET->(GetArea())
			dbSelectArea("SA6")
			If SA6->A6_COD == SET->ET_BANCO
				nMoedaBco := SA6->A6_MOEDA
			Else
				dbSetOrder(1)
				If dbSeek(xFilial("SA6")+SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO)
					nMoedaBco := SA6->A6_MOEDA
				EndIf
			EndIf

			//Grava corretamente a moeda do Banco no caixinha
			If cPaisLoc == "BRA"
				Reclock("SET",.F.)
				SET->ET_MOEDA := nMoedaBco
				Msunlock()
			Endif
			RestArea(aAreaSET)

			AtuSldNat(SET->ET_NATUREZ, SET->ET_DTCRIA, nMoedaBco, "2", "P", SET->ET_LIMREP,xMoeda(SET->ET_LIMREP, nMoedaBco, 1,SET->ET_DTCRIA,3,RecMoeda(dDataBase, nMoedaBco)), "+",,FunName(),"SET", SET->(Recno()),0)
		Endif


		// Atualiza o saldo da natureza na criacao do caixinha (como realizado)
		If lAtuSldNat
			AtuSldNat(SET->ET_NATUREZ, SET->ET_DTCRIA, "01", "3", "P", SET->ET_VALOR,, "+",,FunName(),"SET", SET->(Recno()),0)
		Endif
		
		If !lAutomato
			lRepos := MsgYesNo(OemToAnsi(STR0014),OemToAnsi(STR0015))
		Else
			If FindFunction("GetParAuto")
				aRetAuto := GetParAuto("FINA550TestCase")
				lRepos := aRetAuto[2]
			EndIf
		EndIf

		If (SET->ET_SITUAC == "0") .And. lRet .And. lRepos
			// "Deseja fazer reposicao agora? ","Inclusao de Caixinha - aberto"
			Fa550RepAut( SET->ET_CODIGO,lAutomato)
		Endif
	EndIf
	Exit
EndDo
nRecno := SET->(Recno())
PcoFinLan("000359")
PcoFreeBlq("000359")
RestArea(aArea)
dbSelectArea(cAlias)
If cAlias=="SET"
	SET->(DbGoTo(nRecno))
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Altera³ Autor³ Leonardo Ruben        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alteracao no Cadastro de Caixinhas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA050Altera(ExpC1,ExpN1,ExpN2) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³			 ³ ExpN1 = N£mero do registro 										  ³±±
±±³			 ³ ExpN2 = N£mero da op‡„o selecionada 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Altera(cAlias,nReg,nOpc,lAutomato)
Local lPanelFin := IsPanelFin()
Local aButtons := {}
Local aUsButtons
LOCAL nOpcA
Local cSitAnt := SET->ET_SITUAC
Local cBcoAnt := SET->ET_BANCO
Local cAgeAnt := SET->ET_AGEBCO
Local cCtaAnt := SET->ET_CTABCO
Local lRet    := .T.
Local lAtuSldNat := .T.
Local aAreaSET   := {}
nMoedaBco := IIf( Type('nMoedaBco') == 'U',0,nMoedaBco )


DEFAULT lAutomato := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE cOldNaturez := SET->ET_NATUREZ


If !CtbValiDt(,dDatabase,,,,{"FIN001"},)
	Return
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se permite alteracao                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F550ALTE")
	lRet := ExecBlock("F550ALTE",.F.,.F.)
	If !lRet
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "FT550BUT" )
	aUsButtons := ExecBlock( "FT550BUT", .F., .F. )
	AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se caixinha aberto nao permite alterar     ³
//³ Deve-se fechar o caixinha primeiro         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSitAnt == "0"
	Alert(STR0034) //"ATENÇÃO, Caixinha Aberto..."
EndIf

PcoIniLan("000359")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0
If lPanelFin
	dbSelectArea("SET")
	RegToMemory("SET",.T.,,,FunName())
	oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()
	aDim := DLGinPANEL(oPanelDados)
	Altera := .T.
	nOpca := AxAltera(cAlias,nReg,nOpc,,,,"PcoVldLan('000359','01','FINA550') .AND. FA550TOK()",,,aButtons,,,,,,,.T.,oPanelDados,aDim,FinWindow)
Else
	
 	If !lAutomato
		nOpcA := AxAltera(cAlias,nReg,nOpc,,,,,"PcoVldLan('000359','01','FINA550') .AND. FA550TOK()",,,aButtons)
	Else
		If FindFunction("GetParAuto")
			aRetAuto := GetParAuto("FINA550TESTCASE")
			nOpcA := AxAltera(cAlias,nReg,nOpc,,,,,"PcoVldLan('000359','01','FINA550') .AND. FA550TOK()",,,aButtons,,aRetAuto[1])
		EndIf
	EndIf
	
Endif
dbSelectArea(cAlias)
If nOpcA==1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	If cBcoAnt+cAgeAnt+cCtaAnt <> SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO
		If !lAutomato
			If (MsgYesNo(OemToAnsi(STR0031),OemToAnsi(STR0032) )) // "Confirma mudanca?"###"Mudanca de banco/agencia/conta"
				If SET->ET_SITUAC = "0"  // aberto, faz reposicao
			   		FA550Repos()
				EndIf
			Else 
				If SET->ET_SITUAC = "0"  // aberto, faz reposicao
			   		FA550Repos()
				EndIf
			Endif	
			
		Else
			Reclock("SET",.F.)
			Replace ET_SITUAC	With cSitAnt
			Replace ET_BANCO	With cBcoAnt
			Replace ET_AGEBCO	With cAgeAnt
			Replace ET_CTABCO	With cCtaAnt
			MsUnlock()
			PcoDetLan("000359","01","FINA550")
  	EndIf
  	If lAtuSldNat .And. cOldNaturez <> SET->ET_NATUREZ

  		aAreaSET := SET->(GetArea())
		dbSelectArea("SA6")
		If SA6->A6_COD == SET->ET_BANCO
			nMoedaBco := SA6->A6_MOEDA
		Else
			dbSetOrder(1)
			If dbSeek(xFilial("SA6")+SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO)
				nMoedaBco := SA6->A6_MOEDA
			EndIf
		EndIf
		RestArea(aAreaSET)


  		// Tiro o valor da natureza antiga
		AtuSldNat(cOldNaturez, SET->ET_DTCRIA, nMoedaBco, "2", "P", SET->ET_VALOR,xMoeda(SET->ET_VALOR, nMoedaBco, 1,SET->ET_DTCRIA,3,RecMoeda(SET->ET_DTCRIA, nMoedaBco)), "-",,FunName(),"SET", SET->(Recno()),0)
		// Somo o valor na nova natureza
		AtuSldNat(SET->ET_NATUREZ, SET->ET_DTCRIA, nMoedaBco, "2", "P", SET->ET_VALOR,xMoeda(SET->ET_VALOR, nMoedaBco, 1,SET->ET_DTCRIA,3,RecMoeda(SET->ET_DTCRIA, nMoedaBco)), "+",,FunName(),"SET", SET->(Recno()),0)

  	Endif
EndIf
EndIf

PcoFinLan("000359")
PcoFreeBlq("000359")

dbSelectArea(cAlias)
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Deleta³ Autor³ Leonardo Ruben        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para exclusao de Caixinhas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA050Deleta(ExpC1,ExpN1,ExpN2) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³			 ³ ExpN1 = N£mero do registro 										  ³±±
±±³			 ³ ExpN2 = N£mero da op‡„o selecionada 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION FA550Deleta(cAlias,nReg,nOpc)
Local aButtons := {}
Local aUsButtons
LOCAL bCampo,nOpcA
LOCAL lOk   := .T.
Local cArq :=""
Local lRet := .T.
Local lPanelFin := IsPanelFin()
Local lAtuSldNat := .T.
Local aAreaSET := {}
nMoedaBco := IIf( Type('nMoedaBco') == 'U',0,nMoedaBco )

If !CtbValiDt(,dDatabase,,,,{"FIN001"},)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "FT550BUT" )
	aUsButtons := ExecBlock( "FT550BUT", .F., .F. )
	AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se permite exclusao                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F550EXCL")
	lRet := ExecBlock("F550EXCL",.F.,.F.)
	If !lRet
		Return
	Endif
Endif

bCampo := {|nCPO| Field(nCPO) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite a exclusao somente dos caixinhas fechados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArq= GetArea()
SEU->(DbSetOrder(2))
SEU->(DbSeek(xFilial()+SET->ET_CODIGO))
If !SEU->(EOF())
	MsgStop(OemToAnsi(STR0033))
	RestArea(cArq)
	Return
EndIf
RestArea(cArq)
lOk := (SET->ET_SITUAC =="1")

If lOk
	PcoIniLan("000359")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	SoftLock(cAlias)

	If lPanelFin  //Chamado pelo Painel Financeiro
		RegToMemory(cAlias,.T.,,,FunName())
	   oPanelDados := FinWindow:GetVisPanel()
		oPanelDados:FreeChildren()
	   aDim := DLGinPANEL(oPanelDados)
	   nOpca := AxVisual(cAlias,nReg,nOpc,,,,,aButtons,.T.,,.T.,,.T.,.T.,aDim)
   Else
	   nOpca := AxVisual(cAlias,nReg,nOpc,,,,,aButtons)
   Endif

	DbSelectArea(cAlias)

	If lOk .And. nOpcA == 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto antes da exclusao e apos as validacoes                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("F550AEXC")
			lRet := ExecBlock("F550AEXC",.F.,.F.)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ apos passar por todas as verificacoes , deleta o registro    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			Begin Transaction
			If lAtuSldNat
			
				aAreaSET := SET->(GetArea())
				dbSelectArea("SA6")
				If SA6->A6_COD == SET->ET_BANCO
					nMoedaBco := SA6->A6_MOEDA
				Else
					dbSetOrder(1)
					If dbSeek(xFilial("SA6")+SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO)
						nMoedaBco := SA6->A6_MOEDA
					EndIf
				EndIf
				RestArea(aAreaSET)
						
				// Somo o valor na nova natureza
				//AtuSldNat(SET->ET_NATUREZ, SET->ET_DTCRIA, "01", "3", "P", SET->ET_VALOR,, "-",,FunName(),"SET", SET->(Recno()),0)
				AtuSldNat(SET->ET_NATUREZ, SET->ET_DTCRIA, nMoedaBco, "2", "R", SET->ET_VALOR,xMoeda(SET->ET_VALOR, nMoedaBco, 1,SET->ET_DTCRIA,3,RecMoeda(SET->ET_DTCRIA, nMoedaBco)), "-",,FunName(),"SET", SET->(Recno()),0)
		  	Endif
			DbSelectArea(cAlias)
			RecLock(cAlias,.F.,.t.)
			dbDelete()
			PcoDetLan("000359","01","FINA550", .T.)
			End Transaction
		EndIf
	Else
		MsUnLock()
	ENDIF

	PcoFinLan("000359")
	PcoFreeBlq("000359")
Else
	Help(" ",1,"FA550ABER")
EndIf
dbSelectArea(cAlias)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Repos³ Autor ³ Leonardo Ruben        ³ Data ³ 26.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reposicao manual dos comprovantes do caixinha              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550Repos()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentar. ³ A reposicao manual pode ocorer em duas situacoes:          ³±±
±±³          ³ 1.Caso se deseje baixar os comprovantes em aberto e repor  ³±±
±±³          ³   o saldo do caixinha.                                     ³±±
±±³          ³ 2.Caso o caixa esteja aberto, sem comprovantes para serem  ³±±
±±³          ³   baixados e o saldo eh inferior ao valor do caixa         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Repos(cAlias,nReg,nOpc,lAutomato)

Local aAreaAnt		:= GetArea()
Local cCaixa   		:= SET->ET_CODIGO
Local lAbertos 		:= .F.
Local nVlrRep  		:= 0
Local lPanelFin 	   := IsPanelFin()
Local lRet     		:= .T.
DEFAULT lAutomato    := .F.

Private lEsModII    := Iif(SuperGetMV( "MV_FINCTMD", .T., 1 )==1,.F.,.T.) //Solo aplica para modelo II

F550IniArg()
If  __lArgTal      
	__lArgTal := lEsModII
Endif

If !CtbValiDt(,dDatabase,,,,{"FIN001"},)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se permite repósicao                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F550REPOS")
	lRet := ExecBlock("F550REPOS",.F.,.F.,{cCaixa})
	If !lRet
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A reposicao manual pode ocorrer em duas situacoes:                ³
//³ 1.Caso se deseje baixar os comprovantes em aberto e repor o saldo ³
//³ 2.Caso o caixa esteja aberto, sem comprovantes para serem baixados³
//³   e o saldo seja inferior ao valor do caixa.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Fa550ConfDT(cCaixa)
	Help(" ",1,"FA550DATA")
	Return .F.
Endif


PcoIniLan("000359")

lAbertos := Fa550ComAbe(cCaixa)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa se existem comprovantes nao baixados para o caixinha   ³
//³ caso o parametro esteja ativado                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAbertos
	If Fa550Verif()
		nVlrRep := Fa550Rep20(cCaixa,.F.,.T.,,,,lAutomato)  // repoe sem baixar //Bruno
	Else
		nVlrRep := Fa550Repor( cCaixa,.F.,.T.,,,lAutomato)  // repoe sem baixar //Bruno
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Existem comprovantes nao baixados, portanto eh possivel fazer a ³
	//³ reposicao manual.                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Fa550Verif()
		nVlrRep := Fa550Rep20(cCaixa,.T.,.T.,,,,lAutomato)  // Baixa e repoe
	Else
		nVlrRep := Fa550Repor( cCaixa,.T.,.T.,,,lAutomato)  // Baixa e repoe
	Endif
EndIf

RestArea(aAreaAnt)

PcoFinLan("000359")

If lPanelFin  //Chamado pelo Painel Financeiro
	cAlias := FinWindow:cAliasFile
	dbSelectArea(cAlias)
	FinVisual(cAlias,FinWindow,(cAlias)->(Recno()),.T.)
Endif
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Baixa³ Autor ³ Leonardo Ruben        ³ Data ³ 26.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa/Rendicao manual dos comprovantes do caixinha         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Fa550Baixa()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Baixa(cAlias,nReg,nOpc,lAutomato)
Local aAreaAnt  := GetArea()
Local cCaixa    := SET->ET_CODIGO
Local nVlrRep   := 0
Local lAbertos  := .F.
Local lRet      := .T.
Local lPanelFin := IsPanelFin()
Local cTipoLib  := SuperGetMV( "MV_FINCTAL", .T., "1" )

Default lAutomato := .F.

If !CtbValiDt(,dDatabase,,,,{"FIN001"},)
	Return
EndIf

If ExistBlock("F550FECH")
	lRet:= ExecBlock("F550FECH",.F.,.F.)
Endif

//Se configurado para aprovação de alçadas, verifica se há despesas pendentes de aprovação
If lRet .and. cTipoLib == "2" .and. cPaisLoc $ 'ARG|BRA'
	dbSelectArea("SEU")
	dbSetOrder(2)  // filial + caixa
	SEU->(MSSeek(xFilial()+cCaixa,.T.))
	While !SEU->(Eof()) .and. SEU->EU_FILIAL + SEU->EU_CAIXA == xFilial()+cCaixa
		If !Empty(SEU->EU_CODAPRO) .And. SEU->EU_STATUS $ "01|02"
			Aviso(STR0037,STR0129,{"Ok"}) //"Existem movimentos pendentes de aprovação. O fechamento de caixa não pode ser realizado."
			lRet := .F.
			Exit			
		Endif
		SEU->(DbSkip())
	EndDo
Endif

If !lRet
	Return
Endif

If SET->ET_SITUAC == "1"
	Help(" ",1,"FA550FECH")
	Return
Endif

If !lAutomato
	If !MsgYesNo(STR0036,OemToAnsi(STR0006)) //"Confirma fechamento do Caixinha ?"
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A baixa manual pode ocorrer quando:                               ³
//³ 1.Deseja-se deixar um caixinha com saldo zero para poder fecha-lo.³
//³ 2.Deseja-se baixar os comprovantes de um caixinha e repor automa- ³
//³   ticamente seu saldo.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cPaisLoc<>"BRA"
	If Fa550Verif()
		dbSelectArea("SEU")
		dbSetOrder(6)  // filial + caixa + tipomov
		MSSeek( xFilial()+cCaixa+'91',.T.)
		While !Eof() .and.  EU_FILIAL+EU_CAIXA+EU_TIPO <=xFilial()+cCaixa+'92';
			.And. !lAbertos
			lAbertos := .T.  // achou
			dbSkip()
		EndDo
   Endif

   IF !lAbertos
		nVlrRep := Fa550Rep20( cCaixa,.T.,.F.,,.T.)
   Else
   		Aviso(STR0037,STR0058,{"Ok"}) //"Existen movimientos de reposicion pendientes de aprobacion o debito. La caja no puede ser cerrada"
   		Return
   Endif
Else
	nVlrRep := Fa550Repor( cCaixa,.T.,.F.,,.T.)
Endif

RestArea(aAreaAnt)

If lPanelFin  //Chamado pelo Painel Financeiro
	cAlias := FinWindow:cAliasFile
	dbSelectArea(cAlias)
	FinVisual(cAlias,FinWindow,(cAlias)->(Recno()),.T.)
Endif
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Repor³ Autor ³ Leonardo Ruben        ³ Data ³ 26.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a reposicao do caixinha                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550Repor(ExpC1,ExpL1,ExpL2,ExpL3,ExpL4)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Caixinha											  ³±±
±±³          ³ ExpL1 = Baixa de Movimentos										  ³±±
±±³          ³ ExpL2 = Reposicao de saldo do caixinha							  ³±±
±±³          ³ ExpL3 = Reposicao Originada pela Inclusao do Caixinha 	  ³±±
±±³          ³ ExpL4 = Baixa de Movimentos no Fechamento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550/FINA560                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Repor(cCaixa,lBaixa,lRepor,lOriMv,lFecha,lAutomato)

Local aAreaAnt		:= GetArea()
Local aRegBaix 		:= {}
Local nx 			:= 0
Local nVlrBaix 		:= 0
Local nVlrRep 		:= 0
Local cSeqCxa
Local lFirstRep 	:= .T.
Local nHdlPrv 		:= 0
Local aSEUCont		:=	{}
Local lDigita   	:= IIF(mv_par01==1,.T.,.F.)
Local lAglutina 	:= IIf(mv_par02==1,.T.,.F.)
Local lGeraLanc 	:= IIf(mv_par03==1,.T.,.F.)
Local cArquivo
Local nTotal 		:= 0
Local lPadrao572
Local lPadrao573
Local lLimite 		:= IIf(mv_par04==1,.T.,.F.)	// Considerar ou nao o Limite de conta
Local nSaldoAnt 	:= 0
Local lSai 			:= .F.
Local lAbriu 		:= .F.
Local lF550SBCO 	:= ExistBlock("F550SBCO")
Local lRegMovBco 	:= .T.
Local lVerSaldo 	:= .T.
Local aAlias 		:= {}
Local cNumAd		:= " "
Local aFlagCTB 		:= {}
Local lUsaFlag		:= SuperGetMV("MV_CTBFLAG", .T. /*lHelp*/, .F. /*cPadrao*/)
Local lFindITF 		:= .T.
Local lFA550REP		:= Existblock("FA550REP")
Local cTipoLib      := SuperGetMV( "MV_FINCTAL", .T., "1" )
Local nOpcLib       := 0
Local lTemBaixa := .T.
Local nVlPend   := 0
Local lAtuSldNat := FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")
Local aAreaSET   := {}
Local nValLim		:= 0
Local lMsg			:= .T. 

Default lAutomato := .F.

Private cLote
Private aReposi:={}
Private aBcoRep := {}
lBaixa := If( lBaixa = nil, .F., lBaixa)  // Baixa movimentos
lRepor := If( lRepor = nil, .F., lRepor)  // Repoe
lOriMv := If( lOriMv = nil, .F., lOriMv)  // Reposicao originada pela entrada de movimento (atingiu limite)
lFecha := If( lFecha = nil, .F., lFecha)  // Baixa movimentos

nMoedaBco := IIf( Type('nMoedaBco') == 'U',0,nMoedaBco )

If lRepor .and. cPaisLoc $'ARG|BRA' .and. lRpMnAcLim
	If !Fa550BcRep(cCaixa,@aBcoRep,@aReposi,0,,lLimite)
		Return(0) /*Function Fa550Rep20*/
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Solicita aprovação para reposição de saldo do caixinha.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Se configurado para aprovação de alçadas
	If ( cTipoLib == "2" )
		nOpcLib := Fa550Libera(aReposi)

		//Se não foi aprovado termina
		If nOpcLib == 0
			Return 0
		EndIf

	EndIf
Endif

LoteCont("FIN")



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se gera movimentacao bancaria.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F55CMBCO")
	lRegMovBco := ExecBlock("F55CMBCO",.F.,.F.)
	If ValType(lRegMovBco) <> 'L'
		lRegMovBco := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de lanc. Padronizados                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPadrao572:=If( lGeraLanc , VerPadrao("572"), .F.)
lPadrao573:=If( lGeraLanc , VerPadrao("573"), .F.)

If !lFecha
	If !lAutomato
		If  !MsgYesNo(STR0035,OemToAnsi(STR0006)) //"Confirma Reposição do Caixinha ?"
			Return 0 /*Function Fa550Repor*/
		Endif
	EndIf
Endif

If !DtMovFin(,,"1")
	Return 0 /*Function Fa550Repor*/
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controlo se existe saldo no banco para repor.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SET")
dbSetOrder(1)  // filial + caixa
dbSeek( xFilial()+cCaixa)

If lF550SBCO
	lVerSaldo := ExecBlock("F550SBCO",.F.,.F.,{SET->ET_CODIGO,SET->ET_BANCO,SET->ET_AGEBCO,SET->ET_CTABCO})
Endif

If !GetNewPar("MV_CXSLBCO",.F.)
	If lVerSaldo .and. lRepor .And. SldBco(SET->ET_BANCO,SET->ET_AGEBCO,SET->ET_CTABCO,,,lLimite) <= 0
		Help(" ",1,"SldBco")
		Return  0 /*Function Fa550Repor*/
	Endif
Endif

//VERIFICA BLOQUEIO DE CONTA CORRENTE
If lRepor .and. CCBLOCKED(SET->ET_BANCO,SET->ET_AGEBCO,SET->ET_CTABCO)
	Return  0 /*Function Fa550Repor*/
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controlo se o saldo do caixinha ja esta reposto, ou  ³
//³ seja, eh igual ao valor do mesmo.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SEU")
dbSetOrder(5)  // filial + caixa + sequencia + num
dbSeek( xFilial()+ cCaixa )
While !Eof() .And. xFilial()+cCaixa == EU_FILIAL+EU_CAIXA
	If (EU_TIPO == "01") .And. Empty(EU_BAIXA)
			nVlPend += EU_SLDADIA	// Saldo do adiantamento
			cNumAd  += IIF(!Empty(cNumAd),"/","") + Alltrim(EU_NUM)
	EndIf
	SEU->(DbSkip())
End

IF SET->ET_TPREP = "0"	// Tipo de reposição: 0=Por Valor Limite;1=Por Porcentagem
	nValLim := SET->ET_LIMREP	// Valor/Percentual de reposição
Else
	nValLim := SET->ET_LIMREP/100 * SET->ET_VALOR
EndIf

If !lOriMv .And. lRepor .And. (nValLim <= (SET->ET_SALDO+nVlPend) .AND. !lRpAcVlCx)
	If nVlPend > 0	// Saldo do adiantamento
		Aviso(STR0067,STR0068 + Alltrim(cNumAd) + STR0069,{STR0070})
		cNumAd := ""
	Else
		HELP(' ',1, "F550NOREP",, STR0127 ,2,0,,,,,,{STR0128})  //"Caixinha possui saldo superior ao limite estabelecido para reposição. Não é necessário reposição."###"Verifique se o caixinha selecionado é o que necessita de reposição, ou se a operação do menu é a desejada."
	EndIf
	Return  0 /*Function Fa550Repor*/
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona-se no cadastro de caixinhas                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SET")
dbSetOrder(1)  // filial + caixa
dbSeek( xFilial()+cCaixa)
If SET->ET_SITUAC == "1"
	If !lAutomato
		If !MsgYesNo(OemToAnsi(STR0018),OemToAnsi(STR0017)) //"Deseja abrir o Caixinha?"###"Caixinha Fechado"
			Return  0 /*Function Fa550Repor*/
		Else
			lAbriu := .T.
			RecLock("SET",.F.)
			Replace ET_SITUAC With "0"
			Replace ET_SEQCXA With SOMA1(ET_SEQCXA)
			Replace ET_SALANT With ET_SALDO
			MsUnLock()
			PcoDetLan("000359","01","FINA550")
		Endif
	Else 
			lAbriu := .T.
			RecLock("SET",.F.)
			Replace ET_SITUAC With "0"
			Replace ET_SEQCXA With SOMA1(ET_SEQCXA)
			Replace ET_SALANT With ET_SALDO
			MsUnLock()
			PcoDetLan("000359","01","FINA550")
	EndIf
Else
	lAbriu := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checar se existem os lancamentos padrao e se nao foi       ³
//³inicializado e inicializar o HeadProva caso for necesario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHdlPrv <= 0 .And. (lPadrao572.Or.lPadrao573)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa Lancamento Contabil                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHdlPrv := HeadProva( cLote,;
		                      "FINA550" /*cPrograma*/,;
		                      Substr( cUsuario, 7, 6 ),;
		                      @cArquivo )
Endif

Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna a sequencia atual do caixinha                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeqCxa := Fa570SeqAtu( cCaixa)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa comprovantes                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SEU")
	dbSetOrder(5)  // filial + caixa + sequencia + num
	dbSeek( xFilial()+ cCaixa + cSeqCxa)
	While !Eof() .And. xFilial()+cCaixa+cSeqCxa == EU_FILIAL+EU_CAIXA+EU_SEQCXA
		lFirstRep := .F.  // nao eh primeira reposicao do caixinha
		If !( SEU->EU_TIPO $ "10/11")
			AAdd(aSEUCont,SEU->(RECNO()))
		Endif
		If EU_TIPO == "10"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reposicao incial da ultima sequencia (abertura)   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotRep := SET->ET_VALOR - SET->ET_SALDO
			dbSkip()
			Loop
		ElseIf EU_TIPO == "11" .And. SET->ET_SALDO == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³fechou-se a sequencia (caixa fechado, pois esta   ³
			//³eh a ultimia sequencia). Saldo zero.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotRep  := 0
			nVlrBaix := 0
			Exit
		ElseIf (EU_TIPO == "00" .And. !Empty(EU_BAIXA))
		     aAlias:= GetArea()
		     cNumAd:= EU_NUM
		     cNroAd:= EU_NROADIA

		     SEU->(DbSetOrder(1))
		   	 If DbSeek(xFilial("SEU")+cNroAd+cCaixa+"01")
		     	If EU_SEQCXA < cSeqCxa
		   	 		RestArea(aAlias)
				  	nVlrBaix += EU_VALOR
					dbSkip()
					Loop
		   		EndIf
             EndIf

		     SEU->(DbSetOrder(6))
		     If !(Dbseek(xFilial("SEU")+cCaixa+"02"+ cNumAd)) // Verifica se se a depesa nao foi cancelada
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gastos/despesas baixados nao sao somados          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RestArea(aAlias)
				dbSkip()
				Loop
			Else
				RestArea(aAlias)
			EndIf
		//ElseIf (EU_TIPO == "00" .And. !Empty(EU_NROADIA))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gastos/despesas de adiantamentos nao sao somados  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//dbSkip()
			//Loop
		ElseIf (EU_TIPO == "01")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiantamentos: Tendo ou nao saldo, considero o valor   ³
			//³total como despesa/gasto. Porem nao armanzeno no vetor ³
			//³de registros a serem baixados (aRegBaix)               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  		If Empty(EU_BAIXA)
		   		Aviso(STR0067,STR0068 + aLLTRIM(SEU->EU_NUM) + STR0069,{STR0070})//"Atenção"##"O movimento de adiantamento "##" esta pendênte de prestação de contas e não será baixado, com esta pendência o caixinha não será finalizado."##"Ok"
				lMsg := .F. 
				lTemBaixa:= .F.
				dbSkip()
				Loop
			Else
				nVlrBaix += EU_VALOR
			EndIf

			dbSkip()
			Loop
		ElseIf EU_TIPO == "02"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o tipo for devolucao de adiantamento, o mesmo foi   ³
			//³rendido/baixado, logo considero o quanto foi devolvido ³
			//³como reposicao para o caixinha. Desconto do total de   ³
			//³comprovantes (pois considerei o adiantamento inicial)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrBaix -= EU_VALOR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Este bloco testa se a devolução é referente a um adiantamento ³
			//³em aberto, feito antes da última reposição, pois este é ³
			//³desconsiderado.                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAlias:= GetArea()
			cNroAd:= EU_NROADIA
			SEU->(DbSetOrder(1))
			If DbSeek(xFilial("SEU")+cNroAd+cCaixa+"01")
		     	If EU_SEQCXA < cSeqCxa
		   			RestArea(aAlias)
				  	nVlrBaix += EU_VALOR
					dbSkip()
					Loop
			   	Else
				   	RestArea(aAlias)
			   		dbSkip()
					Loop
			   	EndIf
		   Else
		   		RestArea(aAlias)
		   		dbSkip()
				Loop
		   EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aqui estao sendo somados   :                           ³
		//³- Gastos/despesas em aberto (tipo 00)                  ³
		//³- Adiantamentos fechados/rendidos (tipo 01)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(SEU->EU_BAIXA) // verificação implementada para não alterar a data de baixa.
			AADD(aRegBaix, Recno())
		EndIf

		nVlrBaix += EU_VALOR
		dbSkip()
	EndDo

	If lBaixa .and. Len(aRegBaix) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pediu-se para baixar e existem comprovantes para tal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nx := 1 to Len( aRegBaix)
			dbGoto( aRegBaix[nx])
			RecLock("SEU",.F.)
			REPLACE EU_BAIXA WITH dDataBase
			MsUnlock()
			PcoDetLan("000359","02","FINA550")
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valor reposto eh exatamente o montante que foi baixado/rendido     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRpMnAcLim .and. LEN(aReposi) > 0
			If aReposi[7] > SET->ET_SALDO
				nVlrRep := aReposi[7] - SET->ET_SALDO
			Else
				nVlrRep := aReposi[7]	
			EndIF	
		Else
			If 	nValLim > SET->ET_SALDO
				nVlrRep := nValLim - SET->ET_SALDO
			Else
				nVlrRep := nValLim
			EndIf
		EndIf
		
	ElseIf nVlrBaix > 0 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valor reposto eh exatamente o montante que foi baixado/rendido     ³
		//³ Se aRegBaix for nulo, eh porque esta sequencia do caixinha compoe- ³
		//³ se estritamente de adiantamentos.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrRep := nVlrBaix
	ElseIf nVlrBaix = 0 .And. lTemBaixa
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valor reposto eh exatamente o total do caixinha                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF	FWIsInCallStack('FA550REPAUT')
			// Criação do Caixinha
			nVlrRep := SET->ET_VALOR
		Else
			nVlrRep := nValLim - SET->ET_SALDO
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para validar ou não o saldo do banco vinculado    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lF550SBCO
		lVerSaldo := ExecBlock("F550SBCO",.F.,.F.,{SET->ET_CODIGO,SET->ET_BANCO,SET->ET_AGEBCO,SET->ET_CTABCO})
	Endif

	//Verifico se o banco tem saldo para repor ao caixinha
	If !GetNewPar("MV_CXSLBCO",.F.)
		If lVerSaldo .and. lRepor .And. SldBco(SET->ET_BANCO,SET->ET_AGEBCO,SET->ET_CTABCO,,,lLimite) < nVlrRep
			Help(" ",1,"SldBco")
			nVlrRep := 0
			lSai := .T.
			DisarmTransaction()
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para validar se continua a reposicao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("F550VRPS")
		lSai := ExecBlock("F550VRPS",.F.,.F.,{nVlrRep})
		If ValType(lSai) <> 'L'
			lSai := .F.
		Else // Se o PE retornar falso não deve continuar
			lSai := !lSai
		EndIf
	Endif

	//Contabilizar
	If !lSai
		For nX	:= 1	To Len(aSEUCont)
			SEU->(DbGoTo(aSEUCont[nX]))
			If lPadrao572 .and.  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
					Endif
					nTotal += DetProva( nHdlPrv,;
					                    "572" /*cPadrao*/,;
					                    "FINA550" /*cPrograma*/,;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
			Endif
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a reposicao do caixinha                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRepor
			nSaldoAnt := SET->ET_SALDO

			If ExistBlock("F550VREP")
				nVlrRep := ExecBlock("F550VREP",.F.,.F.,{nVlrRep,nSaldoAnt})
				While ((SET->ET_SALDO+nVlrRep)>SET->ET_VALOR) .and. !lRpMnAcLim
					Help(" ",1,"VLRMAIOR",,STR0044 +' [F550VREP]',1,0) //"Valor maior que o permitido."
				EndDo
			Endif

			RecLock("SET",.F.)

			If cPaisLoc <> "BRA"
				REPLACE SET->ET_SALANT with nSaldoAnt
			EndIf
			
			If nSaldoAnt > 0
				REPLACE ET_SALANT 	WITH  ET_SALDO	
			EndIf			

			REPLACE ET_SALDO 	WITH   nSaldoAnt+ nVlrRep
			If !lAbriu
				REPLACE ET_SEQCXA WITH SOMA1(ET_SEQCXA)
			Endif
			REPLACE ET_ULTREP WITH dDataBase
			MsUnlock()
			PcoDetLan("000359","01","FINA550")

		EndIf

		If lAtuSldNat .And. !lFirstRep
		
			aAreaSET := SET->(GetArea())
			dbSelectArea("SA6")
			If SA6->A6_COD == SET->ET_BANCO
				nMoedaBco := SA6->A6_MOEDA
			Else
				dbSetOrder(1)
				If dbSeek(xFilial("SA6")+SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO)
					nMoedaBco := SA6->A6_MOEDA
				EndIf
			EndIf
			RestArea(aAreaSET)
		
			AtuSldNat(SET->ET_NATUREZ, dDataBase, nMoedaBco, "3", "P", nVlrRep,xMoeda(nVlrRep, nMoedaBco, 1,dDataBase,3,RecMoeda(dDataBase, nMoedaBco)), "+",,FunName(),"SET", SET->(Recno()),0)
		EndIf
		
		dbSelectArea("SET")
		dbSetOrder(1)
		dbSeek( xFilial("SET")+cCaixa)
		If lRepor
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³ Registra movimento de reposicao (tipo 10)                      ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Fa550Mov( ET_CODIGO, "10", nVlrRep,STR0019+SET->ET_BANCO,@aBcoRep,@aReposi)  //"Reposicion de banco "
			// SAIDA EM BANCO
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³ Registra movimento no banco				                       ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRegMovBco // Por movimentação financeira

				If Len(aReposi) > 0 .and. aReposi[3] == "CH"
					Fa550ChRep( SET->ET_CODIGO,aBcoRep,aReposi,{ nHdlPrv, "573", "", "FINA550", cLote } , @aFlagCTB,aReposi[8])
					AtuSalCxa( SET->ET_CODIGO, dDataBase, nVlrRep ) // Atuliza saldo quando foi gerado titulo para fornecedor
				Else
					Fa550MvBco("S", nVlrRep, STR0020) //"REPOSICAO DE CAIXA"
				Endif	
				If cPaisLoc <> "BRA"
					If lFindITF .And. FinProcITF( SE5->( Recno() ),1 ) .AND. lRetCkPG(3,,SET->ET_BANCO)
						FinProcITF( SE5->( Recno() ),3,, .F.,{ nHdlPrv, "573", "", "FINA550", cLote } , @aFlagCTB )
					EndIf
				EndIf
			EndIf

			If lPadrao573 .and.  nHdlPrv > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
					Endif
					nTotal += DetProva( nHdlPrv,;
					                    "573" /*cPadrao*/,;
					                    "FINA550" /*cPrograma*/,;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
				AAdd(aSEUCont,SEU->(RECNO()))
			Endif
		EndIf

		If lFecha
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fechar caixinha caso solicitado                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrMov := Fa550Fecha( cCaixa, lMsg )
			If lPadrao573 .and. nHdlPrv > 0 .And. nVlrMov > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
					Endif
					nTotal += DetProva( nHdlPrv,;
					                    "573" /*cPadrao*/,;
					                    "FINA550" /*cPrograma*/,;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
				AAdd(aSEUCont,SEU->(RECNO()))
			Endif
		Endif

		If nHdlPrv > 0 .and. (lPadrao572.or.lPadrao573)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetiva Lan‡amento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If UsaSeqCor()
					aDiario := {}
					AADD(aDiario,{"SEU",SEU->(recno()),SEU->EU_DIACTB,"EU_NODIA","EU_DIACTB"})
				Else
					aDiario := {}
				Endif
				RodaProva( nHdlPrv,;
				           nTotal )

				If cA100Incl( cArquivo,;
					           nHdlPrv,;
					           3 /*nOpcx*/,;
					           cLote,;
					           lDigita,;
					           lAglutina /*lAglut*/,;
					           /*cOnLine*/,;
					           /*dData*/,;
					           /*dReproc*/,;
					           @aFlagCTB,;
					           /*aDadosProva*/,;
					           aDiario )

					For nX := 1	To Len(aSEUCont)
						SEU->(DbGoTo(aSEUCont[nX]))
						If !lUsaflag
							Reclock("SEU",.F.)
							Replace EU_LA	With "S"
							MsUnLock()
						Endif
						PcoDetLan("000359","02","FINA550")
					Next
				Endif

				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

		Endif
	Endif
	dbCommitAll()
End Transaction

IF lFA550REP // gravação de dados complementares.
	ExecBlock("FA550REP",.F.,.F.)
ENDIF
RestArea(aAreaAnt)
Return nVlrRep /*Function Fa550Repor*/


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Rep20³ Autor ³ Marcello              ³ Data ³ 26.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a reposicao do caixinha                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550Repor(ExpC1,ExpL1,ExpL2,ExpL3,ExpL4,ExpN5)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Caixinha								  ³±±
±±³          ³ ExpL1 = Baixa de Movimentos								  ³±±
±±³          ³ ExpL2 = Reposicao de saldo do caixinha					  ³±±
±±³          ³ ExpL3 = Reposicao Originada pela Inclusao do Caixinha 	  ³±±
±±³          ³ ExpL4 = Baixa de Movimentos no Fechamento				  ³±±
±±³          ³ ExpN5 = Numero do recno no arquivo de movimentos 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550/FINA560                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Rep20(cCaixa,lBaixa,lRepor,lOriMv,lFecha,nRegSEU,lAutomato)
Local aAreaAnt := GetArea()
Local aRegBaix := {}
Local nx := 0, nVlrBaix := 0
Local nVlrRep := 0
Local cSeqCxa
Local lFirstRep := .T.
Local nHdlPrv := 0
Local aSEUCont	:=	{}
Local lDigita   := IIF(mv_par01==1,.T.,.F.)
Local lAglutina := IIf(mv_par02==1,.T.,.F.)
Local lGeraLanc := IIf(mv_par03==1,.T.,.F.)
Local cArquivo
Local nTotal := 0
Local lPadrao572
Local lPadrao573
Local lPadrao579
Local lLimite := IIf(mv_par04==1,.T.,.F.)	// Considerar ou nao o Limite de conta
Local nSaldoAnt := 0
Local lAbriu := .F.
Local lExisteTit := .F.
Local aSE5 := {}, aSE2 := {}
Local lF550SBCO := ExistBlock("F550SBCO")
Local lVerSaldo := .T.
Local aFlagCTB := {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lFindITF := .T.
Local lFA550REP	:= Existblock("FA550REP")
Local cTipoLib  := SuperGetMV( "MV_FINCTAL", .T., "1" )
Local nOpcLib   := 0
Local lF550BAIX	:= ExistBlock("F550BAIX")

Private lTpDeb := .T.
Private cTipoDeb := "2"
Private aBcoRep:={}, aReposi:={}
Private nValor := 0
Private cBcoRep := " "
Private cAgeRep := " "
Private cCtaRep := " "
Private cTipo := " "
Private lMovBco:=.F.

Private cLote
LoteCont("FIN")

DEFAULT nRegSEU := 0
DEFAULT lAutomato := .F.

lBaixa := If( lBaixa = nil, .F., lBaixa)  // Baixa movimentos
lRepor := If( lRepor = nil, .F., lRepor)  // Repoe
lOriMv := If( lOriMv = nil, .F., lOriMv)  // Reposicao originada pela entrada de movimento (atingiu limite)
lFecha := If( lFecha = nil, .F., lFecha)  // Baixa movimentos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona-se no cadastro de caixinhas                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SET")
dbSetOrder(1)  // filial + caixa
dbSeek( xFilial("SET")+cCaixa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controlo se o saldo do caixinha ja esta reposto, ou  ³
//³ seja, eh igual ao valor do mesmo.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lOriMv .And. lRepor .And. SET->ET_SALDO > 0 .And. (SET->ET_VALOR <= SET->ET_SALDO .AND. !lRpAcVlCx)
	Help(" ",1,"FA550JAREP")  // Saldo ja esta reposto
	Return  0 /*Function Fa550Rep20*/
Endif

If !DtMovFin(,,"1")	
	Return 0 /*Function Fa550Rep20*/
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de lanc. Padronizados                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPadrao572:=If( lGeraLanc , VerPadrao("572"), .F.)
lPadrao573:=If( lGeraLanc , VerPadrao("573"), .F.)
lPadrao579:=If( lGeraLanc , VerPadrao("579"), .F.)

If SET->ET_SITUAC == "1"
	If !MsgYesNo(OemToAnsi(STR0018),OemToAnsi(STR0017)) //"Deseja abrir o Caixinha?"###"Caixinha Fechado"
		Return  0 /*Function Fa550Rep20*/
	Else
		RecLock("SET",.F.)
		Replace ET_SITUAC With "0"
		REPLACE ET_SEQCXA With SOMA1(ET_SEQCXA)
		MsUnLock()
		PcoDetLan("000359","01","FINA550")
		lAbriu:=.T.
	Endif
Else
	lAbriu:=.F.
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna a sequencia atual do caixinha                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeqCxa := Fa570SeqAtu( cCaixa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecao do banco para reposicao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBcoRep:={}
aReposi:={}
If lRepor
	If !Fa550BcRep(cCaixa,@aBcoRep,@aReposi,0,nRegSEU,lLimite,lAutomato)
		Return(0) /*Function Fa550Rep20*/
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Solicita aprovação para reposição de saldo do caixinha.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Se configurado para aprovação de alçadas
	If ( cTipoLib == "2" ) .and. cPaisLoc $ 'ARG|BRA'
		nOpcLib := Fa550Libera( aReposi )

		//Se não foi aprovado termina
		If nOpcLib == 0
			Return 0
		EndIf
	EndIf

	cBcoRep :=aBcoRep[1]
	cAgeRep :=aBcoRep[2]
	cCtaRep :=aBcoRep[3]
	nValor  :=aReposi[7]
	nVlrRep :=aReposi[7]
	cTipo   :=aReposi[1]
	cTipoDeb:=aReposi[2]
	cTpTit  :=aReposi[3]
	lTpDeb := aReposi[8]
Else
	cBcoRep :=SET->ET_BANCO
	cAgeRep :=SET->ET_AGEBCO
	cCtaRep :=SET->ET_CTABCO
	nValor  :=SET->ET_VALOR
	nVlrRep :=nVlrBaix
	cTipo   :="10"
	cTipoDeb:="2"
	If !lBaixa
		If !MsgYesNo(STR0035,OemToAnsi(STR0006)) //"Confirma Reposição do Caixinha ?"
			Return 0 /*Function Fa550Rep20*/
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controlo se existe saldo no banco para repor.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SET")
dbSetOrder(1)  // filial + caixa
dbSeek( xFilial()+cCaixa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para validar ou não o saldo do banco vinculado    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lF550SBCO
	lVerSaldo := ExecBlock("F550SBCO",.F.,.F.,{SET->ET_CODIGO,SET->ET_BANCO,SET->ET_AGEBCO,SET->ET_CTABCO})
Endif

If !GetNewPar("MV_CXSLBCO",.F.)
	If lVerSaldo .and. lRepor .And. SldBco(cBcoRep,cAgeRep,cCtaRep,,,lLimite) <= 0
		Help(" ",1,"SldBco")
		Return  0 /*Function Fa550Rep20*/
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa comprovantes                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lBaixa .And. !(cTipo$"90|91")
	dbSelectArea("SEU")
	dbSetOrder(5)  // filial + caixa + sequencia + num
	dbSeek( xFilial()+ cCaixa + cSeqCxa)
	While !Eof() .And. xFilial()+cCaixa+cSeqCxa == EU_FILIAL+EU_CAIXA+EU_SEQCXA
		lFirstRep := .F.  // nao eh primeira reposicao do caixinha
		If !( SEU->EU_TIPO $ "10/11")
			AAdd(aSEUCont,SEU->(RECNO()))
		Endif
		If EU_TIPO == "10"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reposicao incial da ultima sequencia (abertura)   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotRep := SET->ET_VALOR - SET->ET_SALDO
			dbSkip()
			Loop
		ElseIf EU_TIPO == "11"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³fechou-se a sequencia (caixa fechado, pois esta   ³
			//³eh a ultimia sequencia). Saldo zero.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotRep  := 0
			nVlrBaix := 0
			Exit
		ElseIf (EU_TIPO == "00" .And. !Empty(EU_BAIXA))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gastos/despesas baixados nao sao somados          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSkip()
			Loop
		ElseIf (EU_TIPO == "00" .And. !Empty(EU_NROADIA))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gastos/despesas de adiantamentos nao sao somados  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSkip()
			Loop
		ElseIf (EU_TIPO == "01")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiantamentos: Tendo ou nao saldo, considero o valor   ³
			//³total como despesa/gasto. Porem nao armanzeno no vetor ³
			//³de registros a serem baixados (aRegBaix)               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrBaix += EU_VALOR
			dbSkip()
			Loop
		ElseIf EU_TIPO == "02"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o tipo for devolucao de adiantamento, o mesmo foi   ³
			//³rendido/baixado, logo considero o quanto foi devolvido ³
			//³como reposicao para o caixinha. Desconto do total de   ³
			//³comprovantes (pois considerei o adiantamento inicial)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrBaix -= EU_VALOR
			dbSkip()
			Loop
		ElseIf EU_TIPO>="90"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reposicoes canceladas, aguardando autorizacao, cheques ³
			//³aguardando compensacao etc.                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			DbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aqui estao sendo somados   :                           ³
		//³- Gastos/despesas em aberto (tipo 00)                  ³
		//³- Adiantamentos fechados/rendidos (tipo 01)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD( aRegBaix, Recno())
		nVlrBaix += EU_VALOR
		dbSkip()
	EndDo
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checar se existem os lancamentos padrao e se nao foi       ³
//³inicializado e inicializar o HeadProva caso for necesario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHdlPrv <= 0 .And. (lPadrao572.Or.lPadrao573)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa Lancamento Contabil                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHdlPrv := HeadProva( cLote,;
		                      "FINA550" /*cPrograma*/,;
		                      Substr( cUsuario, 7, 6 ),;
		                      @cArquivo )
Endif

Begin Transaction
	DbSelectArea("SEU")
	If cTipo<>"90"
		If lBaixa .And. Len( aRegBaix)>0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pediu-se para baixar e existem comprovantes para tal  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nx := 1 to Len( aRegBaix)
				dbGoto( aRegBaix[nx])
				RecLock("SEU",.F.)
				REPLACE EU_BAIXA WITH dDataBase
				MsUnlock()
				PcoDetLan("000359","02","FINA550")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada F550BAIX             							     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lF550BAIX
					ExecBlock("F550BAIX",.F.,.F.)
				Endif
			Next
	    Endif
		//Contabilizar
		For nX	:= 1	To Len(aSEUCont)
			SEU->(DbGoTo(aSEUCont[nX]))
			If lPadrao572 .and.  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
					Endif
					nTotal += DetProva( nHdlPrv,;
					                    "572" /*cPadrao*/,;
					                    "FINA550" /*cPrograma*/,;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )

			Endif
		Next
	Endif

	dbSelectArea("SET")
	dbSetOrder(1)
	dbSeek( xFilial()+cCaixa)
	If lRepor
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a reposicao do caixinha                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSaldoAnt := SET->ET_SALDO
		cProxRep	:=	''
	   If cPaisLoc <> "BRA"
			DbSelectArea("SEU")
			aAreaSEU	:=	GetArea()
			DbSetOrder(8)
			DbSeek(xFilial()+SET->ET_CODIGO+"zzzzzzzzzz",.T.)
			DbSkip(-1)
			While xFilial()+SET->ET_CODIGO == EU_FILIAL+EU_CAIXA .And. Empty(cProxRep)
				If !(EU_TIPO $ '90/91/92')
					cProxRep	:=	EU_NRREND
				Endif
				DbSkip()
			Enddo
			RestArea(aAreaSEU)
			DbSelectArea('SET')
		Endif
		IF Empty(cProxRep)
			cProxRep	:=	SET->ET_NRREND
	   Endif
		RecLock("SET",.F.)
		If cTipo<"90" .Or. cTipo == "92"
			REPLACE ET_NRREND	WITH SOMA1(cProxRep)

			Replace SET->ET_SALANT with SET->ET_SALDO

			If lTpDeb .Or. cPaisLoc == "BRA"
				REPLACE ET_SALDO	WITH ET_SALDO+nVlrRep
				REPLACE ET_ULTREP	WITH dDataBase
			EndIf
			If !lAbriu
				REPLACE ET_SEQCXA	WITH SOMA1(ET_SEQCXA)
			Endif
		Else
			REPLACE ET_NRREND	WITH SOMA1(cProxRep)
			If !lAbriu
				REPLACE ET_SEQCXA	WITH SOMA1(ET_SEQCXA)
			Endif
		Endif
		MsUnlock()
		PcoDetLan("000359","01","FINA550")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica/Busca o proximo numero para o titulo                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(aReposi[4],1,1)=='*'
			cCampo	:=	"A6_NUM"+Alltrim(aReposi[3])
			If SA6->(FieldPos(cCampo)) > 0
				SA6->(DbSetOrder(1))
				SA6->(MsSeek(xFilial("SA6")+cBcoRep+cAgeRep+cCtaRep))
				Reclock("SA6",.F.)
				nSize		:=	Len(Alltrim(SA6->(&cCampo)))
				nSize		:=	If(nSize == 0,TamSX3("E2_NUM")[1],nSize)
				aReposi[4]	:=	SA6->(&cCampo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Muda o numero se existir um titulo com o mesmo numero          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SE2")
				aSE2:=GetArea()
				DbSetOrder(6)
				DbSelectArea("SE5")
				aSE5:=GetArea()
				DbSetOrder(3)
				lExisteTit:=.T.
				While lExisteTit
					If aReposi[2]=="1"
						DbSelectArea("SE2")
						lExisteTit:=(DbSeek(xFilial("SE2")+SET->ET_FORNECE+SET->ET_LOJA+Space(TamSX3("E2_PREFIXO")[1])+aReposi[4]))
					Else
						DbSelectArea("SE5")
						lExisteTit:=(DbSeek(xFilial("SE5")+cBcoRep+cAgeRep+cCtaRep+Space(TamSX3("E5_PREFIXO")[1])+aReposi[4]))
					Endif
					If lExisteTit
						aReposi[4]:=Soma1(aReposi[4])
					Endif
				Enddo
				Replace SA6->(&cCampo)	With Soma1(aReposi[4])
				SA6->(MsUnLock())
				SE2->(RestArea(aSE2))
				SE5->(RestArea(aSE5))
			Endif
			DbSelectArea("SET")
		Else
			SA6->(DbSetOrder(1))
			SA6->(MsSeek(xFilial("SA6")+cBcoRep+cAgeRep+cCtaRep))
		Endif
		/**/
		If ExistBlock("F550VREP")
			nVlrRep := ExecBlock("F550VREP",.F.,.F.,{nVlrRep,nSaldoAnt})
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registra movimento de reposicao                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Fa550Mov( ET_CODIGO, cTipo, nVlrRep,IIF( lMovBco,STR0019+cBcoRep,STR0023),@aBcoRep,@aReposi,nRegSEU)  //"Reposicion de banco "
		nRSeu:=SEU->(Recno())
		If !(cTipo$"90|91")
			// SAIDA EM BANCO
			If cTipoDeb=="1"  //debito diferido
			   	If cPaisLoc != "BRA"
					Fa550ChRep(ET_CODIGO,aBcoRep,aReposi,{ nHdlPrv, "573", "", "FINA550", cLote } , @aFlagCTB)
			   	Else
					If lMovBco
						If cTpTit == "CH"
							Fa550ChRep(ET_CODIGO,aBcoRep,aReposi,{ nHdlPrv, "573", "", "FINA550", cLote } , @aFlagCTB,lTpDeb)
							AtuSalCxa( SET->ET_CODIGO, dDataBase, nVlrRep ) // Atuliza saldo quando foi gerado titulo para fornecedor
						Else
							Fa550MvBc2("S", nVlrRep, STR0020, cBcoRep, cAgeRep, cCtaRep, aReposi) //"REPOSICAO DE CAIXA"
						EndIf
					Else
						AtuSalCxa( SET->ET_CODIGO, dDataBase, nVlrRep ) // Atuliza saldo quando foi gerado titulo para fornecedor
					Endif
				Endif


			Else //debito imediato
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Registra movimento no banco				                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If lMovBco

					//chamo rotina que verifica a necessidade de gravaca do imposto ITF na movimentacao bancaria e sua contabilizacao
					Fa550MvBc2("S", nVlrRep, STR0020, cBcoRep, cAgeRep, cCtaRep, aReposi) //"REPOSICAO DE CAIXA"
					If cPaisLoc <> "BRA"
						If lFindITF .And. FinProcITF( SE5->( Recno() ),1 )  .AND. lRetCkPG(3,,aBcoRep[1])
							FinProcITF( SE5->( Recno() ),3,, .F.,{ nHdlPrv, "573", "", "FINA550", cLote } , @aFlagCTB )
						EndIf
					EndIf
				Else
					//**********************************************************
					// Atuliza saldo quando o sistema não realiza movimentaçao *
					// bancaria. (Possivel problema nna rotina)                *
					//**********************************************************
					If FXMultSld()
				    	AtuSalCxa( SET->ET_CODIGO, dDataBase, nVlrRep )
					Endif

			    EndIf
			Endif
			If lPadrao573 .and.  nHdlPrv > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
					Endif
					nTotal += DetProva( nHdlPrv,;
					                    "573" /*cPadrao*/,;
					                    "FINA550" /*cPrograma*/,;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )

				AAdd(aSEUCont,SEU->(RECNO()))
			Endif
		Elseif (cTipo$"90")
			If lPadrao579 .and. nHdlPrv > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara Lancamento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
						Endif
						nTotal += DetProva( nHdlPrv,;
						                    "579" /*cPadrao*/,;
						                    "FINA550" /*cPrograma*/,;
						                    cLote,;
						                    /*nLinha*/,;
						                    /*lExecuta*/,;
						                    /*cCriterio*/,;
						                    /*lRateio*/,;
						                    /*cChaveBusca*/,;
						                    /*aCT5*/,;
						                    /*lPosiciona*/,;
						                    @aFlagCTB,;
						                    /*aTabRecOri*/,;
						                    /*aDadosProva*/ )
				AAdd(aSEUCont,SEU->(RECNO()))
			Endif

		Endif
	EndIf

	If lFecha
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fechar caixinha caso solicitado                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrMov := Fa550Fecha( cCaixa)
		If lPadrao573 .and. nHdlPrv > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Prepara Lancamento Contabil                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
				Endif
				nTotal += DetProva( nHdlPrv,;
				                    "573" /*cPadrao*/,;
				                    "FINA550" /*cPrograma*/,;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    /*lPosiciona*/,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )
			AAdd(aSEUCont,SEU->(RECNO()))
		Endif
	Endif

	If nHdlPrv > 0 .and. (lPadrao572.or.lPadrao573)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetiva Lan‡amento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RodaProva( nHdlPrv,;
			           nTotal )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetiva Lan‡amento Contabil                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If UsaSeqCor()
				cCodDiario:= SEU->EU_DIACTB
				aDiario := {}
				AADD(aDiario,{"SEU",SEU->(recno()),cCodDiario,"EU_NODIA","EU_DIACTB"})
			Else
				aDiario := {}
			Endif

			If cA100Incl( cArquivo,;
				           nHdlPrv,;
				           3 /*nOpcx*/,;
				           cLote,;
				           lDigita,;
				           lAglutina /*lAglut*/,;
				           /*cOnLine*/,;
				           /*dData*/,;
				           /*dReproc*/,;
				           @aFlagCTB,;
				           /*aDadosProva*/,;
				           aDiario )

				For nX := 1	To Len(aSEUCont)
					SEU->(DbGoTo(aSEUCont[nX]))
					If !lUsaFlag
						Reclock("SEU",.F.)
						Replace EU_LA	With "S"
						MsUnLock()
					Endif
					PcoDetLan("000359","02","FINA550")
				Next
			Endif

			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

	Endif
	dbCommitAll()
End Transaction

IF lFA550REP // gravação de dados complementares.
	ExecBlock("FA550REP",.F.,.F.)
ENDIF
If cTipo$"91|92"
	If ExistBlock("FA550CORP")
		If MsgYesNo(OemToAnsi(STR0046),OemToAnsi(""))
			ExecBlock("FA550CORP",.F.,.F.,{nRSeu})
		Endif
	Endif
Endif

RestArea(aAreaAnt)
Return nVlrRep /*Function Fa550Rep20*/

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550RepAut³ Autor³ Leonardo Ruben        ³ Data ³ 16.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reposicao automatica - alteracao situacao para aberto      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550RepAut(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Caixinha								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550		                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550RepAut( cCaixa,lAutomato)
Local nVlrRep := 0
Default lAutomato := .F.
If Fa550Verif()
	nVlrRep := Fa550Rep20(cCaixa,.F.,.T.,,,,lAutomato)
Else
	nVlrRep := Fa550Repor( cCaixa,.F.,.T.) // Baixa e repoe
Endif
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Fecha³ Autor ³ Leonardo Ruben        ³ Data ³ 26.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fecha o caixinha                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550Fecha(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Caixinha											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observac. ³ Sempre que eh utilizada esta funcao, nao existem comprovan-³±±
±±³          ³ tes nao baixados para o(s) caixinha(s)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Fecha(cCaixa, lMsg)
Local aAreaAnt 		:= GetArea()
Local nVlrMov  	:= 0
Local lResp 		:= .F.
Local lRegMovBco 	:= .T.

Default lMsg := .T. 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se gera movimentacao bancaria.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F55CMBCO")
	lRegMovBco := ExecBlock("F55CMBCO",.F.,.F.)
	If ValType(lRegMovBco) <> 'L'
		lRegMovBco := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona-se no cadastro de caixinhas                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SET")
dbSetOrder(1)  // filial + caixa
dbSeek( xFilial()+cCaixa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa se existem comprovantes nao baixados para o caixinha   ³
//³ caso o parametro esteja ativado         								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAbertos := Fa550ComAbe(cCaixa)

lResp := .F.
If ExistBlock("F560FCAD")
   lResp := ExecBlock("F560FCAD",.F.,.F.)
   // se retornar verdadeiro o caixinha sera fechado mesmo que hajam movimentos por adiantamento

endif

If lResp
   lAbertos := .F.
endif

If !lAbertos  // nao ha comprovantes para serem baixados
	nVlrMov := ET_SALDO
	RecLock("SET",.F.)
	REPLACE ET_SALANT WITH nVlrMov 
	REPLACE ET_SALDO WITH 0
	REPLACE ET_SITUAC WITH "1"
	MsUnlock()
	PcoDetLan("000359","01","FINA550")
ElseIf lMsg
   	Aviso(STR0037,STR0058,{"Ok"}) //"Existen movimientos de reposicion pendientes de aprobacion o debito. La caja no puede ser cerrada"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao eh necessario reposicionar-se no SET, pois o Fa550Repor restaura a area anterior ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// ENTRADA NO BANCO
If cPaisLoc<>"BRA"
	Fa550MvBc2("E", nVlrMov, STR0021, SET->ET_BANCO, SET->ET_AGEBCO, SET->ET_CTABCO) //"DEVOLUCION DE CAJA"
Else
	//Posiciona no Movimento de Reposicao Inicial
	DbSelectArea("SEU")
	DbSetOrder(5)		//EU_FILIAL, EU_CAIXA, EU_SEQCXA, EU_NUM
	
	If SEU->(DbSeek(FWxFilial("SEU") + SET->ET_CODIGO + SET->ET_SEQCXA))
		While !SEU->(Eof()) .AND. FWxFilial("SEU") + SET->ET_CODIGO + SET->ET_SEQCXA == SEU->EU_FILIAL + SEU->EU_CAIXA + SEU->EU_SEQCXA
			If SEU->EU_TIPO == "10"
			    DbSelectArea("SE5")
			    DbSetOrder(10)		//E5_FILIAL, E5_DOCUMEN

			    If !SE5->(DbSeek(xFilial("SE5") + SEU->EU_NUM))
					//Nao gerou Movimento Bancario na Reposicao
			    	lRegMovBco := .F.
			    EndIf

				Exit
			EndIf
		
			SEU->(DbSkip())
		EndDo
	EndIf

	If lRegMovBco
		If SET->ET_VALOR == nVlrMov .and. !FWIsInCallStack("FA550BAIXA")	// Se for fechamento, nao eh estorno
			Fa550MvBco("E", nVlrMov, STR0021) //"DEVOLUCION DE CAJA"
		Else
			//Saldo diferente do Original gera movimento de Devolucao e não de estorno
			Fa550MvBco("F", nVlrMov, STR0021) //"DEVOLUCION DE CAJA"
		EndIf
	Else
		// A função Fa550MvBco() contém chamada para atualizar o caixa FIJ
		// Como não há movimento bancário precisamos chamar aqui
		If FXMultSld()
			AtuSalCxa( SET->ET_CODIGO, dDataBase, nVlrMov * -1, .F. )
		EndIf
	EndIf
Endif
// SAIDA DO CAIXA
Fa550Mov( cCaixa   , "11", nVlrMov,STR0022+SET->ET_BANCO )  //"Devolucion al banco "

RestArea(aAreaAnt)
Return nVlrMov


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Valor³ Autor ³ Leonardo Ruben        ³ Data ³ 16.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo ET_VALOR - Valor do caixinha            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Fa550Valor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Valor()
Local aAreaAnt := GetArea()
Local lRet     := .T.

If M->ET_VALOR <= 0
	Help(" ",1,"FA550VAZIO")
	lRet := .F.
EndIf

RestArea(aAreaAnt)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Limit³ Autor ³ Leonardo Ruben        ³ Data ³ 16.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo ET_LIMREP - Limite para reposicao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550Limit()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Limit()
Local aAreaAnt := GetArea()
Local lRet := .T.

If Empty(M->ET_TPREP)
	Help(" ",1,"FA550TPREP")
	lRet := .F.
ElseIf M->ET_LIMREP < 0
	Help(" ",1,"FA550LMNEG")
	lRet := .F.
ElseIf M->ET_TPREP == "0"  //reposicao por valor
	If M->ET_LIMREP > M->ET_VALOR
		Help(" ",1,"FA550LMSUP")
		lRet := .F.
	EndIf
Else                        //reposicao por porcentagem
	If M->ET_LIMREP > 100
		Help(" ",1,"FA550LMSUP")
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaAnt)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550VlrInd³ Autor³ Leonardo Ruben        ³ Data ³ 16.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor e  o saldo individual do caixinha          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550VlrInd(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Caixinha					                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aVlrSld[1] - Valor e aVlrSld[2] - Saldo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550VlrInd(cCodigo)
Local aAreaAnt := GetArea()
Local aVlrSld := {0,0}

dbSelectArea("SET")
dbSetOrder(1)  // filial + codigo
If dbSeek( xFilial() + cCodigo)
	aVlrSld := {SET->ET_VALOR,SET->ET_SALDO}
EndIf

RestArea(aAreaAnt)
Return aVlrSld


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550ComAbe³ Autor³ Leonardo Ruben        ³ Data ³ 26.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existem comprovantes nao baixados para o caixi-³±±
±±³          ³ nha						                                		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550ComAbe(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Caixinha					                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet := .T. se existem comprovantes nao baixados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550ComAbe(cCodigo)
Local aAreaAnt := GetArea()
Local lRet     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para verificacao de comprovantes nao baixados para o caixinha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F550VCBC")
	ExecBlock("F550VCBC",.F.,.F.)
Endif

dbSelectArea("SEU")
dbSetOrder(2)  // filial + caixa + dtbaixa + num
dbSeek( xFilial()+cCodigo)
While !Eof() .and. xFilial()+cCodigo == EU_FILIAL+EU_CAIXA ;
	.and. Empty(EU_BAIXA) .and. !lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desconsidera Devolucao de adiantamento e adiantamentos fechados.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If EU_TIPO = "90" .OR. EU_TIPO == "02" .Or. (EU_TIPO == '01' .And. EU_SLDADIA	==	0)
		dbSkip()
		Loop
	EndIf
	lRet := .T.  // achou
	dbSkip()
EndDo

RestArea(aAreaAnt)
Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550ConfDt³ Autor³ Bruno Sobieski        ³ Data ³ 28.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existem comprovantes com data de digitacao     ³±±
±±³          ³ maior que a data atual.                            		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550ConfDt(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Caixinha					                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet := .T. se existem comprovantes com data posterios     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550ConfDt(cCodigo)
Local aAreaAnt := GetArea()
Local lRet     := .F.


dbSelectArea("SEU")
dbSetOrder(2)  // filial + caixa + dtbaixa + num
dbSeek( xFilial()+cCodigo)
While !Eof() .and. xFilial()+cCodigo == EU_FILIAL+EU_CAIXA ;
	.And. Empty(EU_BAIXA) .and. !lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desconsidera Devolucao de adiantamento e adiantamentos fechados.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If EU_DTDIGIT > dDataBase
		lRet	:=	.T.
	Endif
	dbSkip()
EndDo

RestArea(aAreaAnt)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Mov  ³ Autor ³ Leonardo Ruben        ³ Data ³ 28.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registra movimentos de baixa, reposicao e devolucao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550Mov(ExpC1,ExpC2,ExpN1,ExpC3)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Caixinha											  ³±±
±±³          ³ ExpC2 = Tipo do Movimento             							  ³±±
±±³          ³ ExpN1 = Valor do movimento                            	  ³±±
±±³          ³ ExpC3 = Historico do Movimento           						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Mov( cCaixa, cTipo, nValor, cHistor, aBco, aRep, nRegSEU, nRegEst)
Local aAreaAnt := GetArea()
Local bNumRel
Local cNumRel
Local aSE2 := {}
Local cChave := {}
Local cAliasAux := GetNextAlias()

DEFAULT cHistor	:=	""
DEFAULT aBco := {}
DEFAULT aRep := {}
DEFAULT nRegSEU := 0
DEFAULT nRegEst := 0
If nValor == 0
	Return
Endif

F550IniArg()

If nRegSEU==0
	dbSelectArea("SX3")
	dbSetOrder(2)  // campo
	dbSeek("EU_NUM")
	bNumRel := SX3->X3_RELACAO
	cNumRel := &bNumRel

	dbSelectArea("SEU")
	dbSetOrder(1)
	While SEU->(dbSeek(xFilial("SEU")+cNumRel))
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
		cNumRel := &bNumRel
	EndDo

	dbSelectArea("SET")
	dbSetOrder(1)  // filial + codigo
	dbSeek( xFilial() + cCaixa)

  	dbSelectArea("SEU")

	If cTipo == "11"
		dbSelectArea("SEU")
		BeginSQL ALIAS cAliasAux
			SELECT SEU1.EU_HISTOR
			FROM %TABLE:SEU% SEU1
			WHERE 	SEU1.EU_CAIXA = %EXP:SET->ET_CODIGO%
				AND	SEU1.EU_FILIAL = %EXP:xFilial("SEU")%
				AND SEU1.EU_TIPO IN (%EXP:'90'%,%EXP:'91'%,%EXP:'92'%,%EXP:'10'%)
				AND	SEU1.%NotDel%
                AND SEU1.EU_DTDIGIT = (
                    SELECT MAX(SEU2.EU_DTDIGIT)
                    FROM %TABLE:SEU% SEU2
                    WHERE 	SEU2.EU_FILIAL = %EXP:xFilial("SEU")%
                        AND SEU2.EU_CAIXA = %EXP:SET->ET_CODIGO%
                        AND SEU2.EU_TIPO  IN (%EXP:'90'%,%EXP:'91'%,%EXP:'92'%,%EXP:'10'%))
				AND SEU1.EU_NUM = (
					SELECT MAX(SEU3.EU_NUM)
					FROM %TABLE:SEU% SEU3
	    			WHERE 	SEU3.EU_FILIAL = %EXP:xFilial("SEU")%
					    AND SEU3.EU_CAIXA = %EXP:SET->ET_CODIGO%
					    AND SEU3.EU_TIPO  IN (%EXP:'90'%,%EXP:'91'%,%EXP:'92'%,%EXP:'10'%))
		EndSQL

        // Se o histórico não contém a palavra (BAN)CO/(BAN)K (considerando a localidade),
        // altera o histórico do estorno de reposição STR0021 ("CAJA","CAIXA","CASH")
        IF !"BAN" $ UPPER((cAliasAux)->EU_HISTOR)
			cHistor := STR0021
		ENDIF

		(cAliasAux)->(dbCloseArea())
	EndIf

	RecLock("SEU",.T.)
	Replace EU_FILIAL  	With xFilial("SEU")
	Replace EU_NUM     	With cNumRel    // Numero sequencial/semaforo (x3_relacao)
	Replace EU_CAIXA   	With cCaixa
	Replace EU_DTDIGIT 	With dDataBase
	Replace EU_TIPO    	With cTipo
	Replace EU_FILORI   With EU_FILIAL
	If cTipo<"90" .Or. cPaisLoc=="BRA"
		Replace EU_BAIXA   	With dDataBase
		Replace EU_SEQCXA  	With SET->ET_SEQCXA
		Replace EU_NRREND With SET->ET_NRREND
	Endif
	Replace EU_VALOR   	With nValor
	Replace EU_HISTOR		With cHistor
	If cPaisLoc == "BRA"
		Replace EU_MOEDA With SET->ET_MOEDA
	EndIf
	
	If ColumnPos( 'EU_AGENCI' ) > 0 // Os campos EU_BANCO,EU_AGENCI_EU_CONTARE foram criados juntos pacote Relase Agosto 2016 //
		If Len(aBco) > 0
			Replace EU_BANCO		With aBco[1]
			Replace EU_AGENCI		With aBco[2]
			Replace EU_CONTARE	With aBco[3]
		Else
			Replace EU_BANCO		With SET->ET_BANCO
			Replace EU_AGENCI		With SET->ET_AGEBCO
			Replace EU_CONTARE	With SET->ET_CTABCO	
		Endif	
	EndIf
	
	If !Empty(aBco) .And. !Empty(aRep)
		If cPaisLoc <> "BRA"
			Replace EU_BCOREP With aBco[1]
			Replace EU_AGEREP With aBco[2]
			Replace EU_CTAREP With aBco[3]
			Replace EU_TIPDEB With aRep[2]+aRep[3]
			Replace EU_EMISTIT With aRep[5]
			Replace EU_VCTOTIT With aRep[6]
		Endif
		Replace EU_TITULO With aRep[4]
		If Len(aRep) >= 11 .And. ValType(aRep[11])=="C"
			Replace EU_NRREND With aRep[11]
		Endif
		If Len(aRep) >= 12 .And. ValType(aRep[12])=="N"
			Replace EU_MOEDA With aRep[12]
		Endif
 		aRep[10]+=cNumRel
 		If __lArgTal
			If 	Len(aBco) >= 5 .And. ValType(aBco[5])=="C"
				Replace EU_TALAO With aBco[5]  
			Endif
		Endif
 		
	Endif
	MsUnlock()

	nRegEst := SEU->(Recno())
	PcoDetLan("000359","02","FINA550")

	// Chamado da sequencia 03 do PCO referente à reposição do caixinha
	If cTipo == '10'
		PcoDetLan("000359","03","FINA550")
	Endif

	If cPaisLoc <> "BRA" .And. !Empty(aBco) .And. !Empty(aRep) .And. Len(aRep) >= 11 .And. ValType(aRep[11])=="C"
		PutMV('MV_SEQREP',Soma1(aRep[11]))
		FreeUsedCode()
	Endif

	dbClearFil()
	If __lSX8
		ConfirmSX8()
	EndIf
Else
	SEU->(DbGoTo(nRegSEU))
	RecLock("SEU",.F.)
	Replace SEU->EU_TIPO WITH cTipo
	If ValType(aRep)=="A"
		aRep[10]+=SEU->EU_NUM
	Endif
	If cTipo<"90"
		Replace EU_BAIXA   	With dDataBase
		Replace EU_SEQCXA  	With SET->ET_SEQCXA
	Endif
	SEU->(MsUnLock())
	
	PcoDetLan("000359","02","FINA550")
	If cTipo=="90"  //cancelamento da reposicao
		If Left(SEU->EU_TIPDEB,1)=="1"  //debito deferido apagar registro do SE2
			DbSelectArea("SE2")
			aSE2:=GetArea()
			DbSetOrder(1)
			cChave:=xFilial("SE2")+Space(Len(E2_PREFIXO))+SEU->EU_TITULO+Space(Len(E2_PARCELA))
			cChave+=Substr(SEU->EU_TIPDEB,2)+SET->ET_FORNECE+SET->ET_LOJA
			If DbSeek(cChave)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoIniLan("000002")
				FINDELFKs(xFilial("SE2")+ "|" + SE2->E2_PREFIXO+ "|" + SE2->E2_NUM+ "|" + SE2->E2_PARCELA+ "|" + SE2->E2_TIPO+ "|" + SE2->E2_FORNECE+ "|" + SE2->E2_LOJA, "SE2")
				RecLock("SE2",.F.)
				DbDelete()
				MsUnLock()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SE2->E2_TIPO $ MVPAGANT
					PcoDetLan("000002","02","FINA550", .T.)
				Else
					PcoDetLan("000002","01","FINA550", .T.)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoFinLan("000002")
			Endif
			RestArea(aSE2)
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada F550MOV          							    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("F550MOV")
	ExecBlock("F550MOV",.F.,.F.)
Endif

RestArea( aAreaAnt)
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550ComAnt³ Autor³ Leonardo Ruben        ³ Data ³ 28.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registra movimentos de baixa, reposicao e devolucao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550ComAnt( ExpN1, ExpA1)			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero controle do adiantamento                    ³±±
±±³          ³ ExpA1 = Array do registro de Baixa                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550ComAnt( cNroAdia, aRegBaix)
Local aAreaAnt := GetArea()

dbSelectArea("SEU")
dbSetOrder(3) // Filial + nradiant + num
dbSeek( xFilial() + cNroAdia)
While !Eof() .and. EU_FILIAL+EU_NROADIA == xFilial()+cNroAdia
    If Empty(EU_BAIXA)
       Aadd( aRegBaix, Recno())
    EndIf
    dbSkip()
EndDo

RestArea( aAreaAnt)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550MvBco³ Autor ³ Leonardo Ruben        ³ Data ³ 28.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registra movimento no SE5                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550MvBco(ExpC1,ExpN1,ExpC2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Define se movimento de Entrada ou Saida 			  ³±±
±±³			 ³ ExpN1 = Valor do Movimento 										  ³±±
±±³			 ³ ExpN2 = Historico do Movimento      							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550MvBco(cTipoES, nValor, cHistor, cCheque, cNumero, aBanco)
Local aAreaAnt 		:= GetArea()
Local lPosTit 		:= SEU->(FieldPos("EU_TITULO")) > 0 
Local lAtuSldNat 	:= FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")   
Local oModelMov 	:= Nil
Local oSubFK5
Local oSubFKA
Local cLog 			:= ""
Local lRet 			:= .T.
Local cTpDoc 		:= ""
Local cCamposE5 	:= ""
Local cBcoEst 		:= ""
Local cAgEst 		:= ""
Local cCtaEst 		:= ""
Local cModelo       := "FINM030"
Local lMovBco		:= .F. //Define se houve movimento bancário

Default cCheque := ""
Default cNumero := ""
Default aBanco := {}

nMoedaBco := IIf( Type('nMoedaBco') == 'U',0,nMoedaBco )

If nValor == 0
   Return
Endif
Private aRatAJE := {}

If !FWIsInCallStack('FA550RCan')
	If lPosTit
	    dbSelectArea("SE5")
	    dbSetOrder(17)
	    dbSeek( xFilial("SE5")+SET->(ET_BANCO+ET_AGEBCO+ET_CTABCO)+SEU->(EU_TITULO) )
	EndIf
EndIf

If (lPosTit .AND. ( Alltrim(SEU->EU_TITULO) <> Alltrim(SE5->E5_NUMCHEQ) .Or. ( Alltrim(SEU->EU_TITULO) == "" .And. Alltrim(SE5->E5_NUMCHEQ) == "" ))) .or. SE5->E5_SITUACA <> "C"

  	dbSelectArea("SA6")

	dbSetOrder(1)
	dbSeek( xFilial()+SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO )
	nMoedaBco := SA6->A6_MOEDA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia lancamento no PCO                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoIniLan('000007')	
	
	If cTipoES == "E"
		
		//Se for estorno da reposição, então verifica se consegue posicionar na SE5 correspondente a reposição que será estornada
		If PosRecSE5(@cModelo)			
			oModelMov := FWLoadModel(cModelo)
			oModelMov:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
			oModelMov:Activate()
			
			//Posiciona a FKA com base no IDORIG da SE5 posicionada
			oSubFKA := oModelMov:GetModel( "FKADETAIL" )
			oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
			
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
			oModelMov:SetValue( "MASTER", "E5_OPERACAO", 2 ) //E5_OPERACAO 2 = Gera o registro de estorno ES na SE5
			oModelMov:SetValue( "MASTER", "HISTMOV", STR0125 ) //"Estorno de reposição"
			
			If oModelMov:VldData()
				oModelMov:CommitData()
				lMovBco := .T.
			Else
				lRet := .F.
				cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
		    	cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
		    	cLog += cValToChar(oModelMov:GetErrorMessage()[6])
		
				Help( ,,"MF550MVBCO",,cLog, 1, 0 )	   		
			Endif
			
			oModelMov:DeActivate()
			oModelMov:Destroy()
			oModelMov:= Nil
			
		Endif
	
	Else
	
		oModelMov := FWLoadModel("FINM030")
		
		//Define os campos que não existem na FK5 e que serão gravados apenas na E5, para que a gravação da E5 continue igual
		cCamposE5 := "{"
		cCamposE5 += "{'E5_TIPO', Space(3) }"
		cCamposE5 += ",{'E5_VENCTO', dDataBase}"
		cCamposE5 += ",{'E5_DTDIGIT', dDataBase}"
		cCamposE5 += ",{'E5_MOVCX', 'S'}"
		cCamposE5 += "}"
	
		oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
		oModelMov:Activate()
		oModelMov:SetValue( "MASTER", "E5_GRV", .T. )
		oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )
		oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo
		
		//Pega o tipo do documento
		If Type('aReposi') == 'A'
			If Len ( aReposi ) >= 3
				If !Empty( AllTrim( aReposi[3] ) )
					cTpDoc := AllTrim(aReposi[3])
				Else
					cTpDoc := "DH"
				Endif			
			Else
				cTpDoc := "DH"
			Endif
		Else
			cTpDoc := IIF(Empty(SE5->E5_TIPODOC), FK5->FK5_TPDOC, SE5->E5_TIPODOC)
		EndIf
		
		//Se for estorno de reposição manual, então verifica o banco informado na reposição do caixinha (pois pode ser um banco diferente do informado no cadastro do caixinha em si)
		If Len( aBanco ) == 3 //[1] = banco, [2] = agencia, [3] = conta
			cBcoEst := aBanco[1]
			cAgEst := aBanco[2]
			cCtaEst := aBanco[3]
		Else
			cBcoEst := SET->ET_BANCO
			cAgEst := SET->ET_AGEBCO
			cCtaEst := SET->ET_CTABCO
		Endif
		
		//Dados do Processo
		oSubFKA := oModelMov:GetModel("FKADETAIL")
		oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
		oSubFKA:SetValue( "FKA_TABORI", "FK5" )
	
		//Informacoes do movimento
		oSubFK5 := oModelMov:GetModel( "FK5DETAIL" )
		oSubFK5:SetValue( "FK5_DATA", dDataBase )
		oSubFK5:SetValue( "FK5_MOEDA", StrZero(nMoedaBco,2) )
		oSubFK5:SetValue( "FK5_VALOR", nValor )
		oSubFK5:SetValue( "FK5_NATURE", SET->ET_NATUREZ )
		oSubFK5:SetValue( "FK5_TPDOC", cTpDoc )
		oSubFK5:SetValue( "FK5_BANCO", cBcoEst )
		oSubFK5:SetValue( "FK5_AGENCI", cAgEst )
		oSubFK5:SetValue( "FK5_CONTA", cCtaEst )
		oSubFK5:SetValue( "FK5_RECPAG", If(cTipoES == "F", "R", "P") )
		oSubFK5:SetValue( "FK5_HISTOR", cHistor )
		oSubFK5:SetValue( "FK5_DTDISP", dDataBase )
		oSubFK5:SetValue( "FK5_LA", "S" )
		oSubFK5:SetValue( "FK5_FILORI", SEU->EU_FILORI )
		oSubFK5:SetValue( "FK5_ORIGEM", FunName() )
		oSubFK5:SetValue( "FK5_DOC", SEU->EU_NUM )
		
		IF !Empty(cCheque) //Para gravação de Movimento de Estorno de Cheque
			oSubFK5:SetValue( "FK5_NUMCH", cCheque )
		Endif	
		IF !Empty(cNumero)
			oSubFK5:SetValue( "FK5_DOC", cNumero )
		Endif
	
		//Ponto de entrada para gravacoes complementares do SE5
		IF ExistBlock("F550BCO")
			ExecBlock("F550BCO",.f.,.f.)
		Endif
	
		If oModelMov:VldData()
			oModelMov:CommitData()
	    	oModelMov:DeActivate()
			lMovBco := .T.
		Else
			lRet := .F.
			cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
	    	cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
	    	cLog += cValToChar(oModelMov:GetErrorMessage()[6])
	
			Help( ,,"MF550MVBCO",,cLog, 1, 0 )
		Endif
	Endif

	If lRet
		If lMovBco
			If SE5->E5_RECPAG == "P"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Lacncamento orcamentario                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoDetLan("000007","03","FINA550")

			ElseIf SE5->E5_RECPAG == "R"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Lacncamento orcamentario                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoDetLan("000007","04","FINA550")

			EndIf
			
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dDataBase,SE5->E5_VALOR,If(cTipoES $ "E;F","+","-"))
		EndIf	
		If lAtuSldNat
			AtuSldNat(SET->ET_NATUREZ, dDataBase, nMoedaBco, "3", "P", nValor,xMoeda(nValor, nMoedaBco, 1,dDataBase,3,RecMoeda(dDataBase, nMoedaBco)), "+",,FunName(),"SE5", SE5->(Recno()),0)
		EndIf
	Endif
Endif

If lRet
	If FXMultSld() .and. cTipoES <> "E"
		AtuSalCxa( SET->ET_CODIGO, dDataBase, SE5->E5_VALOR * If(cTipoES="F",-1,1), .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apontamento no SIGAPMS                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IntePms().AND. !lPmsInt .And. mv_par05==1
		RegToMemory("SE5",.F.,.F.)
		PmsDlgMB(3,M->E5_PROJPMS,Alltrim(M->E5_HISTOR)+" ("+Alltrim(Transform(M->E5_VALOR,"@E 999,999,999.99"))+")","P")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao dos dados do Modulo SIGAPMS    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PmsWriteMB(1,"SE5")
	EndIf

	If lMovBco
		PcoFinLan('000007')
		PcoFreeBlq('000007')
	EndIf
Endif

RestArea( aAreaAnt)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Legend³ Autor ³ Leonardo Ruben       ³ Data ³ 30.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA550Legend(nReg)
Local uRetorno := .T.
Local aLegenda := {	{"ENABLE"	, 	STR0028	},;	//"Caixinha Aberto"
				   	{"DISABLE"	, 	STR0029	},;	//"Caixinha Fechado"
				   	{"BR_AZUL"	,  	STR0030	} }	//"Caixinha Aberto sem saldo disponivel"


If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, {'ET_SITUAC="0" .AND. ET_SALDO>0' , aLegenda[1][1]}) // Caixa Aberto
	Aadd(uRetorno, {'ET_SITUAC!="0"' 				 , aLegenda[2][1]})	// Caixa Fechado
	Aadd(uRetorno, {'ET_SITUAC="0" .AND. ET_SALDO=0' , aLegenda[3][1]}) // Caixa Aberto sem saldo disponivel
Else
	BrwLegenda(cCadastro,STR0027,aLegenda)
Endif

Return uRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F550VldCta ³ Autor ³ Mauricio Pequim Jr   ³ Data ³ 30.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida conta de banco na inclusao do caixinha              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F550VldCta(cBanco,cAgencia,cConta)
Local lRet := .T.

If Empty(cBanco) .Or. Empty(cAgencia) .Or. !(ExistCpo("SA6",cBanco+cAgencia+cConta))
	lRet := .F.
ElseIf CCBLOCKED(cBanco,cAgencia,cConta)
	lRet := .F.
Endif

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550BcRep ³ Autor ³ Marcello             ³ Data ³16/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecao do banco para reposicao da caja chica               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550BcRep(cCaixa,aBco,aRep,nMin,nRegSEU,lLimite,lAutomato)

Local oDlgBco
Local oDlgAux
Local oBtnCan
Local oBtnOk
Local oBtnSai
Local oBtnImp
Local aArea			:= GetArea()
Local aSA6			:= {}
Local lRet 			:= .F.
Local cTmp 			:= ""
Local nOpc 			:= 0
Local lNaoAprov		:=	.F.
Local cTxtSald  	:= ""
Local lFA550VldRp	:= ExistBlock( "FA550VldRp" )
Local lFA550CkBc  := ExistBlock("FA550CKBCO")

Private lUsrAutor	:= .T.
Private cBanco 	:= Criavar("A6_COD"), oBanco
Private cAgencia 	:= Criavar("A6_AGENCIA"), oAgencia
Private cConta 	:= Criavar("A6_NUMCON"), oConta
Private lLimBco 	:= .F.
Private nARepor 	:= 0
Private nMoedaCx 	:= 0
Private nSldBco 	:= 0
Private oSldBco
Private nMoedaBco 	:= 1
Private oMoedaBco
Private cNumInt 	:= ''
Private oNumInt
Private nVlrRep 	:= 0
Private oVlrRep
Private nTxRep 	:= 0
Private oTxRep
Private nVlrMin 	:= 0
Private oCbAutoriz
Private lAutoriz 	:= .F.
Private oCbDebitar
Private oCbMovBco
Private lDebitar 	:= .F.
Private aTipoRep 	:= {}
Private oCbTipoRep
Private cTipoRep 	:= ""
Private aTipoTit 	:= {}
Private oCbTipoTit
Private cTipoTit 	:= ""
Private cNumero 	:= ""
Private cNumTalao := ""
Private cTipTalao := ""
Private oTalao
Private oTipTalao
Private oNumero
Private oLbNumero
Private dDtEmis 	:= dDataBase
Private oDtEmis
Private dDtVcto 	:= dDataBase
Private oDtVcto
Private cNumCHQ   := ""     
Private nTalCHQ   := 0
Private cPreCHQ   := "" 

Default nRegSEU 	:= 0
Default nMin 		:= -1
Default lLimite	:= .F.
Default lAutomato := .F.

F550IniArg()

If cPaisLoc == "ARG"
	cNumTalao := Criavar("EK_TALAO")
	cTipTalao := Criavar("FRE_TIPO")
EndIf

lLimBco := lLimite

If Type("lMovBco")=="U"
	lMovBco :=.F.
Endif

If lLimBco
	cTxtSald:="  ("+Alltrim(RetTitle("A6_SALATU"))+" = "+Alltrim(RetTitle("A6_SALATU"))+" + "+Alltrim(RetTitle("A6_LIMCRED"))+")"
Else
	cTxtSald:=""
Endif
lUsrAutor := Fa550VlUsr(cCaixa,__CUSERID)
If nRegSEU > 0
	SEU->(dbGoto(nRegSEU))
Endif
nVlrMin := Max(0,nMin)
dbSelectArea("SA6")
aSA6:=GetArea()
dbSetOrder(1)
dbSelectArea("SET")
dbSeek(xFilial("SET")+cCaixa)
lNaoAprov	:=	( cPaisLoc <> "BRA" .And. Empty(SET->ET_CODUSR+SET->ET_GRPUSR))
oFntAr8	:=	TFont():New ("Arial",,,,,,,8,,,,,,,,)
oFntAr8B	:=	TFont():New("Arial",,,,.T.,,,8,,,,,,,,)
oFntAr10B:=	TFont():New("Arial",10,12,,.T.,,,,,,,,,,,)
If cPaisLOC <> "BRA"
	If nRegSEU <> 0
		cNumInt	:=	SEU->EU_NRREND
		lNaoAprov	:=	lNaoAprov .Or. SEU->EU_TIPO <> '91'
	Else
		cNumInt	:=	GetMV('MV_SEQREP')
		If Type("cNumInt") == "C"
			If !FreeForUse('SEU',cNumInt)
				Aviso(STR0037,STR0059,{"Ok"}) //"Ya existe un usuario haciendo reposicion. Por favor intente nuevamente en unos instantes"
				Return .F.
			Endif
		Else
			MsgStop(STR0060,STR0037) //"Configure el parametro MV_SEQREP"
			Return .F.
		Endif
	Endif
EndIf
nARepor	:=	SET->ET_VALOR-SET->ET_SALDO
nARepor	:=	Max(0,nARepor)
cBanco	:=	If(nRegSEU==0,SET->ET_BANCO,SEU->EU_BCOREP)
cAgencia	:=	If(nRegSEU==0,SET->ET_AGEBCO,SEU->EU_AGEREP)
cConta	:=	If(nRegSEU==0,SET->ET_CTABCO,SEU->EU_CTAREP)
cNumero	:=	If(nRegSEU==0,CriaVar("E2_NUM"),SEU->EU_TITULO)
If cPaisLoc <> "BRA"
	dDtEmis 	:= If(nRegSEU==0,dDtEmis,SEU->EU_EMISTIT)
	dDtVcto 	:= If(nRegSEU==0,dDtVcto,SEU->EU_VCTOTIT)
Endif
nVlrRep	:=	If(nRegSEU==0,nARepor,SEU->EU_VALOR)
SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
nMoedaCx	:=	Max(1,SA6->A6_MOEDA)

If cPaisLoc <> "BRA"
	If !EMPTY(SET->ET_FORNECE)
		aTipoTit:={STR0053,STR0054} //"1=Diferido"###"2=Imediato"
	Else
		aTipoTit:={STR0054} //"2=Imediato"
	Endif
	cTipoTit	:=	If(nRegSEU==0,Left(aTipoTit[1],1),Left(SEU->EU_TIPDEB,1))
Else
	cTipoTit := "1"
EndIf
/**/
aTipoRep:={}

If cPaisLoc <>"BRA"
	cTmp:=GetSESTipos({|| ES_RCOPGER == Left(cTipoTit,1)},"2")
EndIf

While !Empty(cTmp)
	AAdd(aTipoRep,Substr(cTmp,1,tamSx3("E2_TIPO")[1]))
	cTmp:=Substr(cTmp,tamSx3("E2_TIPO")[1]+2)
Enddo
If Len(aTipoRep)==0
	If cTipoTit=="1"
		Aadd(aTipoRep, "DH" )
		Aadd(aTipoRep, "CH" )
	Else
		AAdd(aTipoRep,"EF")
		AAdd(aTipoRep,"TF")
	Endif
Endif

// Obtem a taxa da moeda para reposicao
nTxRep := RecMoeda( dDatabase, nMoedaCx )

cTipoRep:=If(nRegSEU==0,aTipoRep[1],Alltrim(Substr(SEU->EU_TIPDEB,2)))
/**/
lDebitar:=If(nRegSEU==0,.F.,Left(cTipoTit,1)=="2")
lAutoriz:=If(nRegSEU==0,!lUsrAutor,SEU->EU_TIPO=="91")
/**/
nOpc:=0

If !lAutomato

	DEFINE MSDIALOG oDlgBco TITLE STR0020 FROM 0,0 TO Iif(__lArgTal,420,390),510 PIXEL OF oMainWnd     

	@002,002 TO 040,254 PIXEL OF oDlgBco LABEL "" COLOR CLR_BLUE,CLR_WHITE
	@006,005 SAY SET->ET_CODIGO+"  "+SET->ET_NOME SIZE 215,10 PIXEL FONT oFntAr10B COLOR CLR_BLUE,CLR_WHITE
	@016,005 SAY Alltrim(RetTitle("ET_VALOR")) SIZE 100,10 PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
	@024,005 MSGET SET->ET_VALOR PICTURE PesqPict("SET","ET_VALOR") SIZE 60,10 PIXEL FONT oFntAr8B COLOR CLR_BLUE,CLR_WHITE WHEN .F.
	@016,077 SAY Alltrim(RetTitle("ET_SALDO")) SIZE 100,10 PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
	@024,077 MSGET SET->ET_SALDO PICTURE PesqPict("SET","ET_SALDO") SIZE 60,10 PIXEL FONT oFntAr8B COLOR CLR_BLUE,CLR_WHITE WHEN .F.
	@016,151 SAY STR0055 SIZE 100,10 PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE  //"A Repor"
	@024,151 MSGET nARepor PICTURE PesqPict("SET","ET_SALDO") SIZE 60,10 PIXEL FONT oFntAr8B COLOR CLR_BLUE,CLR_WHITE WHEN .F.
	@016,222 SAY Alltrim(RetTitle("A6_MOEDA")) SIZE 100,10 PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
	@024,222 MSGET nMoedaCx PICTURE PesqPict("SA6","A6_MOEDA") SIZE 15,10 PIXEL FONT oFntAr8B COLOR CLR_BLUE,CLR_WHITE WHEN .F.
	/**/
	@048,002 TO Iif(__lArgTal,190,175),254 PIXEL OF oDlgBco LABEL "" COLOR CLR_BLUE,CLR_WHITE   
	If cPaisLoc <> "BRA"
		@044,005 MSGET cNumInt SIZE 80,10 OF oDlgBco PIXEL WHEN .F. FONT oFntAr10B
	EndIf
	/**/
	@063,005 TO 095,251 PIXEL OF oDLGBco LABEL STR0038+cTxtSald COLOR CLR_BLUE,CLR_WHITE //"Banco para reposicao"
	@072,008 SAY RetTitle("A6_COD") SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Banco"
	@080,008 MSGET oBanco var cBanco F3 "SA6" PICTURE PesqPict("SA6","A6_COD") SIZE 10, 10 OF oDlgBco Valid Vermoeda(nMoedaCx, SA6->A6_MOEDA) PIXEL FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("BCO") hasbutton WHEN (nRegSEU==0 .AND. !RetGlbLGPD('A6_COD')) OBFUSCATED RetGlbLGPD('A6_COD')
	@072,048 SAY RetTitle("A6_AGENCIA") SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Agencia"
	@080,048 MSGET oAgencia VAR cAgencia PICTURE PesqPict("SA6","A6_AGENCIA") SIZE 20, 10 OF odlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("AGE") WHEN (nRegSEU==0 .AND. !RetGlbLGPD('A6_AGENCIA')) OBFUSCATED RetGlbLGPD('A6_AGENCIA')
	@072,102 SAY RetTitle("A6_NUMCON")SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Conta"
	@080,102 MSGET oConta VAR cConta PICTURE PesqPict("SA6","A6_NUMCON")  SIZE 45, 10 OF oDlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("CTA") WHEN (nRegSEU==0 .AND. !RetGlbLGPD('A6_NUMCON')) OBFUSCATED RetGlbLGPD('A6_NUMCON')
	@072,163 SAY RetTitle("A6_SALATU") SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Saldo"
	@080,163 MSGET oSldBco VAR nSldBco PICTURE PesqPict("SA6","A6_SALATU") SIZE 60, 10 OF oDlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE WHEN .F.
	@072,225 SAY RetTitle("A6_MOEDA")SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Moeda"
	@080,225 MSGET oMoedaBco VAR nMoedaBco PICTURE PesqPict("SA6","A6_MOEDA") SIZE 15, 10 OF oDlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE WHEN .F.
	/**/

    If cPaisLoc <> "BRA"
    	If  __lArgTal
	 		@101,005 TO 175,251 PIXEL OF oDLGBco LABEL STR0006 COLOR CLR_BLUE,CLR_WHITE
			@109,008 SAY STR0039 SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Debito"
			@117,008 COMBOBOX oCbTipoTit VAR cTipoTit ITEMS aTipoTit SIZE 50,12 PIXEL OF oDlgBCO FONT oFntAr8B COLOR CLR_BLUE ON CHANGE Fa550Val("TTIT",.T.) WHEN (nRegSEU==0)
			@109,065 SAY STR0040 SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Tipo Titulo"
			@117,065 COMBOBOX oCbTipoRep VAR cTipoRep ITEMS aTipoRep SIZE 30,12 PIXEL OF oDlgBCO FONT oFntAr8B COLOR CLR_BLUE ON CHANGE Fa550Val("TIP",.T.) WHEN (nRegSEU==0)
			
			@109,102 SAY RetTitle("EU_TALAO") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@117,102 MSGET oTalao VAR cNumTalao F3 "FRE550" PICTURE PesqPict("SEU","EU_TALAO") SIZE 60,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE VALID fA500Talao() WHEN (nRegSEU==0) .And. (Left(cTipoRep,2) $ "CH|DH")
			
			@109,180 SAY STR0099 SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@117,180 MSGET oTipTalao VAR cTipTalao PICTURE PesqPict("FRE","FRE_TIPO") SIZE 60,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE  WHEN .F.
			
			@133,008 SAY oLbNumero PROMPT RetTitle("E2_NUM") SIZE 53,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@141,008 MSGET oNumero VAR cNumero PICTURE PesqPict("SE2","E2_NUM") SIZE 53,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("CHQ") WHEN (nRegSEU==0) .and.  Left(cTipoTit,1) == "2"
			@133,068 SAY RetTitle("E2_EMISSAO") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@141,068 MSGET oDtEmis VAR dDtEmis PICTURE "@D " SIZE 45,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0)
			@133,115 SAY RetTitle("E2_VENCTO") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@141,115 MSGET oDtVcto VAR Iif(Left(cTipoTit,1) == "1",dDtVcto,dDataBase) PICTURE "@D " SIZE 45,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0) .and.  Left(cTipoTit,1) == "1"
			@133,168 SAY AllTrim(RetTitle("EU_VALOR"))+STR0056+StrZero(nMoedaCx,2)+")" SIZE 150,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Valor" //" (Moeda "
			@141,168 MSGET oVlrRep VAR nVlrRep PICTURE PesqPict("SET","ET_VALOR") SIZE 74,10 OF oDlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("VLR") WHEN ((.F. .And. nRegSEU==0).or.  (lRpMnAcLim .and. SET->(FieldPos('ET_SALANT')) > 0))
			@162,008 CHECKBOX oCbDebitar VAR lDebitar PROMPT STR0041 OF oDlgBco SIZE 100,10 FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0 .or. lUsrAutor) .And. !(Left(cTipoRep,2) $ "CH|DH")//"Debitar titulo."
							oCbDebitar:lReadOnly:=!lUsrAutor
			
			If lFA550CkBc
			  lMovBco := ExecBlock("FA550CKBCO",.F.,.F.)
			Endif
			
			@162,130 CHECKBOX oCbMovBco VAR lMovBco PROMPT STR0063 OF oDlgBco SIZE 80,10 FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0 .or. lUsrAutor)	.And. !(Left(cTipoRep,2) $ "CH|DH") //"Gera Mov. Bancaria"
							oCbMovBco:lReadOnly:=!lUsrAutor
			@180,005 CHECKBOX oCbAutoriz VAR lAutoriz PROMPT STR0042 OF oDlgBco SIZE 150,10 FONT oFntAr8B COLOR CLR_BLUE WHEN .F. //(nRegSEU==0) //"Aguardar autorizacao para reposicao."
		Else
			@101,005 TO 158,251 PIXEL OF oDLGBco LABEL STR0006 COLOR CLR_BLUE,CLR_WHITE
			@109,008 SAY STR0039 SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Debito"
			@117,008 COMBOBOX oCbTipoTit VAR cTipoTit ITEMS aTipoTit SIZE 50,12 PIXEL OF oDlgBCO FONT oFntAr8B COLOR CLR_BLUE ON CHANGE Fa550Val("TTIT",.T.) WHEN (nRegSEU==0)
			@109,065 SAY STR0040 SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Tipo Titulo"
			@117,065 COMBOBOX oCbTipoRep VAR cTipoRep ITEMS aTipoRep SIZE 30,12 PIXEL OF oDlgBCO FONT oFntAr8B COLOR CLR_BLUE ON CHANGE Fa550Val("TIP",.T.) WHEN (nRegSEU==0)
			@109,102 SAY oLbNumero PROMPT RetTitle("E2_NUM") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@117,102 MSGET oNumero VAR cNumero PICTURE PesqPict("SE2","E2_NUM") SIZE 43,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("CHQ") WHEN (nRegSEU==0)
			@109,152 SAY RetTitle("E2_EMISSAO") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@117,152 MSGET oDtEmis VAR dDtEmis PICTURE "@D " SIZE 45,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0)
			@109,204 SAY RetTitle("E2_VENCTO") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
			@117,204 MSGET oDtVcto VAR Iif(Left(cTipoTit,1) == "1",dDtVcto,dDataBase) PICTURE "@D " SIZE 45,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0) .and.  Left(cTipoTit,1) == "1"
			@133,008 SAY AllTrim(RetTitle("EU_VALOR"))+STR0056+StrZero(nMoedaCx,2)+")" SIZE 150,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Valor" //" (Moeda "
			@141,008 MSGET oVlrRep VAR nVlrRep PICTURE PesqPict("SET","ET_VALOR") SIZE 74,10 OF oDlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("VLR") WHEN ((.F. .And. nRegSEU==0).or.  (lRpMnAcLim .and. SET->(FieldPos('ET_SALANT')) > 0))
			@142,102 CHECKBOX oCbDebitar VAR lDebitar PROMPT STR0041 OF oDlgBco SIZE 100,10 FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0 .or. lUsrAutor) //"Debitar titulo."
							oCbDebitar:lReadOnly:=!lUsrAutor
			
			If lFA550CkBc
			  lMovBco := ExecBlock("FA550CKBCO",.F.,.F.)
			Endif
			
			@142,160 CHECKBOX oCbMovBco VAR lMovBco PROMPT STR0063 OF oDlgBco SIZE 80,10 FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0 .or. lUsrAutor)	 //"Gera Mov. Bancaria"
							oCbMovBco:lReadOnly:=!lUsrAutor
			@163,005 CHECKBOX oCbAutoriz VAR lAutoriz PROMPT STR0042 OF oDlgBco SIZE 180,10 FONT oFntAr8B COLOR CLR_BLUE WHEN .F. //(nRegSEU==0) //"Aguardar autorizacao para reposicao."
		EndIf
	Else
		@101,005 TO 170,251 PIXEL OF oDLGBco LABEL STR0006 COLOR CLR_BLUE,CLR_WHITE
		If lFA550CkBc
			lMovBco := ExecBlock("FA550CKBCO",.F.,.F.)
		Endif
		@109,008 CHECKBOX oCbMovBco VAR lMovBco PROMPT STR0063 OF oDlgBco SIZE 80,10 FONT oFntAr8B COLOR CLR_BLUE ON CLICK AtuTpRep()  WHEN (nRegSEU==0) //"Gera Mov. Bancaria"
								oCbMovBco:lReadOnly:=!lUsrAutor

		@122,008 SAY SubStr(STR0040,1,4) SIZE 50,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Tipo Titulo"
		@130,008 COMBOBOX oCbTipoRep VAR cTipoRep ITEMS aTipoRep SIZE 30,12 PIXEL OF oDlgBCO FONT oFntAr8B COLOR CLR_BLUE ON CHANGE Fa550Val("TIP",.T.) WHEN (nRegSEU==0 .And. lMovBco .And. CxDigiChq(cBanco,cAgencia,cConta) )

  	 	@122,100 SAY oLbNumero PROMPT RetTitle("E5_NUMCHEQ") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
		@130,100 MSGET oNumero VAR cNumero PICTURE PesqPict("SE5","E5_NUMCHEQ") SIZE 43,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("CHQ") WHEN (nRegSEU==0 .And. cTipoRep == "CH" )

		@122,172 SAY RetTitle("E2_EMISSAO") SIZE 70,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE
		@130,172 MSGET oDtEmis VAR dDtEmis PICTURE "@D " SIZE 45,10 PIXEL OF oDlgBco FONT oFntAr8B COLOR CLR_BLUE WHEN (nRegSEU==0 .And. cTipoRep == "CH" )


		@146,008 SAY AllTrim(RetTitle("EU_VALOR"))+STR0056+StrZero(nMoedaCx,2)+")" SIZE 150,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Valor" //" (Moeda "
		@154,008 MSGET oVlrRep VAR nVlrRep PICTURE PesqPict("SET","ET_VALOR") SIZE 74,10 OF oDlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE VALID Fa550Val("VLR") WHEN ((.F. .And. nRegSEU==0).or. lRpMnAcLim ) hasbutton

		If FXMultSld()
			@146,102 SAY STR0065 + STR0056+StrZero(nMoedaCx,2)+")" SIZE 150,10 OF oDlgBco PIXEL FONT oFntAr8 COLOR CLR_BLUE,CLR_WHITE //"Tx.F" //" (Moeda "
			@154,102 MSGET oTxRep VAR nTxRep PICTURE PesqPict("SM2","M2_MOEDA"+ StrZero(nMoedaCx,1) ) SIZE 44,10 OF oDlgBco PIXEL FONT oFntAr8B COLOR CLR_BLUE hasbutton
		EndIf
	EndIf
	/**/
	If nRegSEU>0
		DEFINE SBUTTON oBtnImp FROM 180,130 PIXEL TYPE 6 ACTION (Iif(ExistBlock("FA550CoRp"),ExecBlock("Fa550CoRp",.F.,.F.,{nRegSEU}),iif(!lAutomato, MsgAlert(STR0064,STR0067),.T.))) ENABLE OF oDlgBco 
				oBtnImp:cToolTip:=STR0046 //"Imprimir comprovante para autorizacao de reposicao"
		DEFINE SBUTTON oBtnCan FROM 180,160 PIXEL TYPE 3 ACTION (oDlgBco:End(),nOpc:=2,lRet:=.T.) ENABLE OF oDlgBco
			oBtnCan:cToolTip:=STR0043 //"Cancelar a reposicao"
			If !lUsrAutor
				oBtnCan:Disable()
			Endif

			ObtnCan:lActive:=lUsrAutor
			ObtnCan:lReadOnly:=!ObtnCan:lActive
	Endif

	DEFINE	SBUTTON oBtnOk FROM Iif(__lArgTal,194,180), 190 PIXEL TYPE 1 ;  
			ACTION	( Iif( ( nRegSEU <> 0 .Or. IIf( __lArgTal, Fa550Val("CTA|CHQ|VLR|FCH|TAL",,.T.) , Fa550Val("CTA|CHQ|VLR",,.T.) )) .And.;
					IIF( cTipoRep == "CH" .And. Empty(cNumero),.F.,.T.) .And. ;
					IIf( lFA550VldRp, ExecBlock( "FA550VldRp", .F., .F., { nRegSEU, nVlrRep } ), .T. ),;  
					( oDlgBco:End(), nOpc:=1, lRet:=.T. ), ) ) ;
			ENABLE OF oDlgBco

		If !(lUsrAutor .Or. nRegSEU==0) .Or.(nRegSEU <> 0 .And.lNaoAprov)
			oBtnOk:Disable()
		Endif
		oBtnOk:lActive		:=nRegSEU==0 .Or. (!lNaoAprov .and. lUsrAutor .and. SEU->EU_TIPO=="91")
		oBtnOk:lReadOnly	:=!oBtnOk:lActive

		DEFINE SBUTTON oBtnSai FROM Iif(__lArgTal,194,180) ,220 PIXEL TYPE 2 ACTION (oDlgBco:End(),nOpc:=0,lRet:=.F.) ENABLE OF oDlgBco     

	// Ponto de entrada para manipilar o objeto oDlgBco
	If ExistBlock( "FA550DLG" )
		oDlgAux := ExecBlock( "FA550DLG", .F., .F., { oDlgBco } )
		If ValType( oDlgAux ) == "O"
			oDlgBco := oDlgAux
		EndIf
	EndIf

	ACTIVATE MSDIALOG oDlgBco CENTERED ON INIT Fa550Val("CTA|TTIT")
Else
	If FindFunction("GetParAuto")
		aRetAuto := GetParAuto("FINA550TESTCASE")

		If (nPos := Ascan(aRetAuto[3],{|x| x[1]=="cBanco"})) > 0
			cBanco := aRetAuto[3][nPos][2]
		EndIf

		If (nPos := Ascan(aRetAuto[3],{|x| x[1]=="cAgencia"})) > 0
			cAgencia := aRetAuto[3][nPos][2]
		EndIf
		
		If (nPos := Ascan(aRetAuto[3],{|x| x[1]=="cConta"})) > 0
			cConta := aRetAuto[3][nPos][2]
		EndIf
		 
		If (nPos := Ascan(aRetAuto[3],{|x| x[1]=="lMovBco"})) > 0
			lMovBco := aRetAuto[3][nPos][2]
		EndIf
		
		If (nPos := Ascan(aRetAuto[3],{|x| x[1]=="nVlrRep"})) > 0
			nVlrRep := aRetAuto[3][nPos][2]
		EndIf

		If (nPos := Ascan(aRetAuto[3],{|x| x[1]=="nTxRep"})) > 0
			nTxRep := aRetAuto[3][nPos][2]
		EndIf
	EndIf
	
	lRet := Fa550Val("CTA|TTIT",,,lAutomato)
EndIf

If lRet
	If  __lArgTal      
		aBco:=Array(5)
		aBco[1]:=cBanco
		aBco[2]:=cAgencia
		aBco[3]:=cConta 
		aBco[4]:=nMoedaBco 
		aBco[5]:=Iif(Left(cTipoTit,1)=="1",cNumTalao,Space(TamSX3("EU_TALAO")[1]) )
	Else 
		aBco:=Array(4)
		aBco[1]:=cBanco
		aBco[2]:=cAgencia
		aBco[3]:=cConta 
		aBco[4]:=nMoedaBco 
	Endif	

	/**/
	If  __lArgTal
		aRep:=Array(15) 
		aRep[13]:=Iif(Left(cTipoTit,1)=="1",cPreCHQ,Space(TamSX3("E2_PREFIXO")[1]) )  
		aRep[14]:=Left(cTipoTit,1)=="1"
		aRep[15]:=nTalCHQ
	Else   
		aRep:=Array(12) 
	Endif
	If nRegSEU==0
		If lAutoriz
			aRep[1]:="91"
		Else
			If cPaisLoc <>"BRA"
				aRep[1]:=If(lDebitar.Or.Left(cTipoTit,1)=='2'.Or.lMovBco,"10","92")
			Else
				aRep[1]:="10"
			EndIf
		Endif
	Else
		If nOpc==2
			aRep[1]:="90"
		Else
			aRep[1]:=If(lDebitar.Or.Left(cTipoTit,1)=='2',"10","92")
		Endif
	Endif
	aRep[2]:=Left(cTipoTit,1)
	aRep[3]:=cTipoRep
	aRep[4]:=cNumero
	aRep[5]:=dDtEmis
	aRep[6]:=dDtVcto
	aRep[7]:=nVlrRep
	aRep[8]:=lDebitar
	aRep[9]:=lAutoriz
	aRep[10]:="CJCC_"
	aRep[11]:=cNumInt
	aRep[12]:=nMoedaCx
Else
	aRep:={}
	aBco:={}
Endif
DbSelectArea("SA6")
RestArea(aSA6)
RestArea(aArea)
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550Val   ³ Autor ³ Marcello             ³ Data ³17/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecao do banco para reposicao da caja chica               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550Val(cVarVal,xVal,lVldFinal,lAutomato)

Local aArea 		:= GetArea()
Local cCpo 			:= ""
Local cTmp 			:= ""
Local cChave 		:= ""
Local lRet 			:= .T.
Local nVal 			:= 0
Local aSE2 			:= {}
Local aSEF          := {}
Local nPos 			:= 0
Local nValorPend	:= 0
Local lF550SBCO 	:= ExistBlock("F550SBCO")
Local lVerSaldo 	:= .T.
Local lVldUser		:= .T.
Local aCmpVldU		:= {}
Local ni			:= 0

Default lVldFinal	:= .F.
Default lAutomato   := .F.

F550IniArg()

cVarVal:=Alltrim(Upper(cVarVal))
nPos:=At("|",cVarVal)
If nPos==0
	cVar:=cVarVal
	cVarVal:=""
Else
	cVar:=Alltrim(Substr(cVarVal,1,nPos-1))
	cVarVal:=Substr(cVarVal,nPos+1)
Endif
While !Empty(cVar)
	Do Case
		Case cVar$"BCO|AGE|CTA" //banco
			DbSelectArea("SA6")
			DbSetOrder(1)
			cChave:=cBanco
			If cVar$"AGE|CTA"
				cChave+=cAgencia
				If cVar=="CTA"
					cChave+=cConta
				Endif
			Endif
			cChave:=Alltrim(cChave)
			If DbSeek(xFilial("SA6")+cChave)
				nSldBco:=SldBco(cBanco,cAgencia,cConta,,,lLimBco)
				nMoedaBco:=Max(1,A6_MOEDA)
				If !lAutomato
					oAgencia:Refresh()
					oConta:Refresh()
					oSldBco:Refresh()
					oMoedaBco:Refresh()
					oVlrRep:Refresh()
				Endif
			Else
				Help(" ",1,"BCONOEXIST")
				lRet:=.F.
			Endif
		Case cVar=="VLR"
			nVal:=xMoeda(nVlrRep,nMoedaCx,nMoedaBco,,2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada para validar ou não o saldo do banco vinculado    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lF550SBCO
				lVerSaldo := ExecBlock("F550SBCO",.F.,.F.,{SET->ET_CODIGO,SET->ET_BANCO,SET->ET_AGEBCO,SET->ET_CTABCO})
			Endif

			If If( !GetNewPar("MV_CXSLBCO",.F.), nVal>nSldBco, .F. )
				If lVerSaldo
					Help(" ",1,"SLDBCO")
					lRet:=.F.
				EndIF
			Else
				dbSelectArea('SEU')
				DbSetOrder(6)
				DbSeek(xFilial()+SET->ET_CODIGO+'91',.T.)
				If cPaisLoc <> "BRA"
					While !Eof() .And. EU_FILIAL+EU_CAIXA+EU_TIPO <= xFilial()+SET->ET_CODIGO+'92'
						nValorPend	+=	EU_VALOR
						DbSkip()
					Enddo
				EndIf
			If ((SET->ET_SALDO+nVlrRep)>SET->ET_VALOR.and.(lRpMnAcLim)) .And. !lRpAcVlCx
					Help(" ",1,"VLRMAIOR",,STR0044,1,0) //"Valor maior que o permitido."
					lRet:=.F.
				ElseIf (SET->ET_SALDO+nVlrRep+nValorPend)>(SET->ET_VALOR + Iif((lRpMnAcLim ),nVlrRep,0))
					Help(" ",1,"VLRPEND",,STR0057,1,0)
					lRet:=.F.
				Else
					If nVlrMin>=0 .and. nVlrRep<nVlrMin
						Help(" ",1,"VLRMENOR",,STR0045,1,0) //"Valor menor que o permitido."
						lRet:=.F.
					Endif
				Endif
			Endif
		Case cVar=="TIP"
			If cTipoRep == "DH" .AND. !Empty(cNumero)
				cNumero := CriaVar("E2_NUM")
			EndIf
		Case cVar=="CHQ" .and. cPaisLoc <> "BRA"
			If Empty(cNumero)
				If  __lArgTal    
					If  !(Left(cTipoTit,1)=="1") //1-Diferido (CH)
						lRet:=.F.
						MsgAlert(STR0047)
					Endif
				Else
					lRet:=.F.
					MsgAlert(STR0047)
				Endif
			ElseIf Substr(cNumero,1,1)=="*"
				cCpo:="A6_NUM"+cTipoRep
			    If (SA6->(FieldPos(cCpo)))==0
					MsgAlert(STR0061+STR0062)
					lRet:=.F.
				Endif
			Else
				If Left(cTipoTit,1)=="1"
					DbSelectArea("SE2")
					aSE2:=GetArea()
					DbSetOrder(6)
					If  DbSeek(xFilial("SE2")+SET->ET_FORNECE+SET->ET_LOJA+Iif(__lArgTal,cPreCHQ,Space(TamSX3("E2_PREFIXO")[1]))+cNumero)
						MsgAlert(STR0048+Alltrim(cNumero)+STR0049) //"Verifique o numero do titulo: "###" ja existe."
						lRet:=.F.
					Endif
					RestArea(aSE2)
					If  __lArgTal				
						aSEF:=GetArea()
						DbSelectArea("SEF")
						IF  !ObtTalCHQ(cBanco,cAgencia,cConta,cNumTalao,2,cNumero)
							MsgAlert(STR0104+Alltrim(cNumero)+" "+STR0105) //"Verifique el numero del cheque: "###"no existe para este Talonario o ya no esta disponible. "
							lRet:=.F.
						Endif
						RestArea(aSEF)    
					Endif
					
				Else
					DbSelectArea("SE5")
					aSE2:=GetArea()
					DbSetOrder(3)
					If DbSeek(xFilial("SE5")+cBanco+cAgencia+cConta+Space(TamSX3("E5_PREFIXO")[1])+cNumero)
						MsgAlert(STR0048+Alltrim(cNumero)+STR0049) //"Verifique o numero do titulo: "###" ja existe."
						lRet:=.F.
					Endif
					RestArea(aSE2)
				Endif
			Endif
		Case cVar=="CHQ" .and. cPaisLoc == "BRA"
			If cTipoRep == "CH" .AND. !Empty(cNumero)
				aSEF := GetArea()			//cTipoRep
				dbSelectArea("SEF")
				dbSetOrder(1)
				If SEF->( dbSeek(xfilial("SEF")+cBanco+cAgencia+cConta+cNumero) )
					MsgAlert(STR0126+Alltrim(cNumero))
					lRet := .F.
				EndIf
				RestArea(aSEF)
			EndIf 	
		Case cVar=="TTIT"
			aTipoRep:={}
			If cPaisLoc<>"BRA"
				If Left(cTipoTit,1)=="1"
					cTmp:=GetSESTipos({|| ES_RCOPGER == "1"},"2")
				Else
					cTmp:=GetSESTipos({|| ES_RCOPGER == "2"},"2")
				Endif
			EndIf
			If cPaisLoc <> "BRA"
				lDebitar:=(Left(cTipoTit,1)=="2")
				If !lAutomato
					oCbDebitar:lReadOnly:= !lUsrAutor .Or. lDebitar
					oCbDebitar:Refresh()
				Endif
				If __lArgTal
				  	If  (Left(cTipoTit,1)=="1")
						lMovBco := .F. 
						cNumero := CriaVar("E2_NUM")
						If !lAutomato
							oCbMovBco:Refresh()
							oNumero:Refresh()
						Endif
					Endif
				Endif   				
			EndIf
			If !lAutomato
				oCbMovBco:lReadOnly:= !lUsrAutor
				oCbMovBco:Refresh()
			Endif
			While !Empty(cTmp)
				AAdd(aTipoRep,Substr(cTmp,1,tamSx3("E2_TIPO")[1]))
				cTmp:=Substr(cTmp,tamSx3("E2_TIPO")[1]+2)
			Enddo
			If Len(aTipoRep)==0
				If Left(cTipoTit,1)=="1"
					aTipoRep:={MVCHEQUE}
				Else
					AAdd(aTipoRep,"EF")
					AAdd(aTipoRep,"TF")
				Endif
			Endif
			If cPaisLoc <> "BRA"
				cTipoRep:=aTipoRep[1]
				If !lAutomato
					oCbTipoRep:aItems:=aTipoRep
					oCbTipoRep:Refresh()
				Endif
			EndIf
		Case cVar=="TAL"  //Talonario
			If  (Left(cTipoTit,1)=="1") .And. Empty(cNumTalao)//Solo aplica cuando es Diferido     
				lRet:=.F.
				MsgAlert(STR0106) //"Informe el Talonario"
			Endif
		Case cVar=="FCH"  //Vld Fch vs Vcto 
			If  (Left(cTipoTit,1)=="1") .And. !(dDtVcto > dDtEmis)//Solo aplica cuando es Diferido     
				lRet:=.F.
				MsgAlert(STR0100)
		Endif   
			
	EndCase
	nPos:=At("|",cVarVal)
	If nPos==0
		cVar:=cVarVal
		cVarVal:=""
	Else
		cVar:=Alltrim(Substr(cVarVal,1,nPos-1))
		cVarVal:=Substr(cVarVal,nPos+1)
	Endif
Enddo
//Ponto de entrada que permite que o usuario valide as informacoes digitadas em tela
If ExistBlock("F550VLD") .AND. lVldFinal
	If cPaisLoc # "BRA"
		aCmpVldU := {{"cBanco" /*codigo do banco*/,Nil},;
						{"cAgencia" /*agencia*/,Nil},;
						{"cConta" /*conta*/,Nil},;
						{"nSldBco" /*saldo atual*/,Nil},;
						{"nMoedaBco" /*moeda*/,Nil},;
						{"cTipoTit" /*debito*/,Nil},;
						{"cTipoRep" /*tipo titulo*/,Nil},;
						{"cNumero" /*num titulo*/,Nil},;
						{"dDtEmis" /*data emissao*/,Nil},;
						{"dDtVcto" /*vencimento*/,Nil},;
						{"nVlrRep" /*valor moeda 1*/,Nil},;
						{"lDebitar" /*debitar titulo*/,Nil},;
						{"lMovBco" /*gerar mov bancario*/,Nil},;
						{"lAutoriz" /*aguardar autorizacao*/,Nil}}
	Else
		aCmpVldU := {{"cBanco" /*codigo do banco*/,Nil},;
						{"cAgencia" /*agencia*/,Nil},;
						{"cConta" /*conta*/,Nil},;
						{"nSldBco" /*saldo atual*/,Nil},;
						{"nMoedaBco" /*moeda*/,Nil},;
						{"lMovBco" /*gerar mov bancario*/,Nil},;
						{"nVlrRep" /*valor moeda 1*/,Nil},;
						{"nTxRep" /*taxa da moeda*/,Nil}}
	Endif
	//Definindo os valores da variaveis, caso elas estejam declaradas, senao manter nulo
	For ni := 1 to Len(aCmpVldU)
		If Type(aCmpVldU[ni][1]) # "U"
			aCmpVldU[ni][2] := &(aCmpVldU[ni][1])
		Endif
	Next ni
	lVldUser := ExecBlock("F550VLD",.F.,.F.,{aCmpVldU})
	If ValType(lVldUser) == "L"
		If lVldUser # lRet
			lRet := lVldUser
		Endif
	Endif
Endif

RestArea(aArea)
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550ChRep ³ Autor ³ Marcello             ³ Data ³28/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Insercao do cheque para reposicao no arquivo SE2            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550ChRep(cCaixa,aBco,aRep,aHdlPrv,aFlagCTB,lTpDeb)
Local lRet := .T.
Local aArea:=GetArea()
Local nMoedaCx := 1
Local lFindITF := .T.
Local cLiberado := GetMV("MV_LIBCHEQ")
Local cSequen	:= ""
Local nTamSeq	:= TamSX3("E5_SEQ")[1]
Local oModelMov := FWLoadModel("FINM030")
Local oModelBxP := FWLoadModel("FINM020")
Local oSubFK2
Local oSubFK5
Local oSubFKA
Local cLog := ""
Local cChaveTit := ""
Local cCamposE5 := ""
Local cChaveCH  := ""
Local cIdDoc := ""
Local cMoedaBco := "" 

Private aRatAJE	:= {}
DEFAULT lTpDeb	:= .F.

F550IniArg()

SET->(MsSeek(xFilial("SET")+cCaixa))
DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2")+SET->ET_FORNECE+SET->ET_LOJA)
dbSelectArea("SA6")
dbSetOrder(1)
dbSeek( xFilial()+SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO)
nMoedaCx:=Max(nMoedaCx,SA6->A6_MOEDA)

If cPaisLoc <> "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Para não ocorrer de gravar o título com código em branco  ³
	//³ e geração de chave duplicada, criar um código quando vazio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lExisteTit:=.T.
	While lExisteTit
		DbSelectArea("SE2")
		dbSetOrder(6)
		If __lArgTal  
			lExisteTit:=(DbSeek(xFilial("SE2")+SET->ET_FORNECE+SET->ET_LOJA+Iif(aRep[14],aRep[13],Space(TamSX3("E2_PREFIXO")[1])) +aRep[4]+Space(TamSX3("E2_PARCELA")[1])+aRep[3]))
		Else       
			lExisteTit:=(DbSeek(xFilial("SE2")+SET->ET_FORNECE+SET->ET_LOJA+Space(TamSX3("E2_PREFIXO")[1]) +aRep[4]+Space(TamSX3("E2_PARCELA")[1])+aRep[3]))
		Endif

		If lExisteTit .Or. Empty(aRep[4])
			aRep[4]:=Soma1(aRep[4])
			lExisteTit:=.T.
			Loop
		Endif
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoIniLan("000002")
	DbSelectArea("SE2")
	RecLock("SE2",.T.)
	SE2->E2_FILIAL	:= xFilial("SE2")
	SE2->E2_NUMLIQ	:= Soma1(GetMv("MV_NUMLIQ"),6)
	SE2->E2_NUM   	:= aRep[4]
	SE2->E2_TIPO 	:= aRep[3]
	SE2->E2_NATUREZ := SET->ET_NATUREZ
	SE2->E2_FORNECE	:= SA2->A2_COD
	SE2->E2_LOJA  	:= SA2->A2_LOJA
	SE2->E2_NOMFOR 	:= SA2->A2_NOME
	SE2->E2_EMISSAO	:= aRep[5]
	SE2->E2_EMIS1 	:= aRep[5]
	SE2->E2_VENCTO	:= aRep[6]
	SE2->E2_VENCREA	:= DataValida(aRep[6],.T.)
	SE2->E2_VALOR   := xMoeda(aRep[7],nMoedaCx,aBco[4])
	SE2->E2_NUMBCO	:= aRep[10]
	SE2->E2_VENCORI	:= DataValida(aRep[6],.T.)
	SE2->E2_DATALIB   := Iif( ALLTRIM(aRep[3]) == "CH",aRep[5],Ctod("//"))
	If aRep[8]
		SE2->E2_VALLIQ   := SE2->E2_VALOR
		SE2->E2_SALDO    := 0
		SE2->E2_BAIXA    := dDataBase
		SE2->E2_MOVIMEN  := dDataBase
		SE2->E2_BCOPAG   := aBco[1]
	Else
		SE2->E2_SALDO    := SE2->E2_VALOR
	Endif
	SE2->E2_HIST := STR0020
	SE2->E2_VLCRUZ 	:= xMoeda(aRep[7],nMoedaCx,1)
	SE2->E2_MOEDA   := aBco[4]
	SE2->E2_TXMOEDA := RecMoeda(dDataBase,aBco[4])

	If CpAISlOC <> "BRA"
		SE2->E2_SITUACA  := "0"
	Endif

	SE2->E2_PORTADO  := aBco[1]
	SE2->E2_BCOCHQ   := aBco[1]
	SE2->E2_AGECHQ   := aBco[2]
	SE2->E2_CTACHQ   := aBco[3]
	SE2->E2_ORIGEM   := "FINA550"
	SE2->E2_LA        :=  "S"
	If cPaisLoc == "CHI"
		SE2->E2_CGC		 := SA2->A2_CGC
	EndIf
	If __lArgTal      
		SE2->E2_PREFIXO	:= aRep[13]
	Endif
	SE2->(MsUnlock())
	/**/

	//ponto de entrada para incluir informacoes adicionais apos gravacao do SE2
	If ExistBlock("F550ALDT")
		ExecBlock("F550ALDT",.F.,.F.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE2->E2_TIPO $ MVPAGANT
		PcoDetLan("000002","02","FINA550")
	Else
		PcoDetLan("000002","01","FINA550")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoFinLan("000002")

EndIF

If cPaisLoc $ 'BRA|BOL|ARG'
	cChaveCH := FWUUIDV4()

    If cPaisLoc $ 'BOL|ARG'
   	 If Alltrim(aRep[3]) $ Trim(MVCHEQUE) 
   	 		IF __lArgTal .And. aRep[14]  
   	 			dbselectarea("SEF")
   	 			SEF->(DbGoTo(aRep[15]))
	   	 		RecLock( "SEF", .F.) 
	   	 		SEF->EF_VALOR  	:= xMoeda(aRep[7],nMoedaCx,aBco[4])   
	   	 		SEF->EF_TITULO  := aRep[4]
	   	 		SEF->EF_DATA	:= aRep[5]  
	   	 		SEF->EF_VENCTO	:= aRep[6] 
	   	 		SEF->EF_HIST	:= STR0020
				SEF->EF_STATUS	:= '02'   
				SEF->EF_LA      := 'S'
				SEF->(MsUnlock())
   	 		Else
				RecLock( "SEF", .T.)
				SEF->EF_FILIAL		:= xFilial("SEF")
				SEF->EF_VALOR  	:= xMoeda(aRep[7],nMoedaCx,aBco[4])
				SEF->EF_NUM			:= aRep[4]
				SEF->EF_BANCO		:= aBco[1]
				SEF->EF_AGENCIA	:= aBco[2]
				SEF->EF_CONTA		:= aBco[3]
				SEF->EF_BENEF		:= SA2->A2_NOME
				SEF->EF_VENCTO		:= aRep[6]  
				SEF->EF_DATA	:= aRep[6] 
				SEF->EF_HIST		:= STR0020
				SEF->EF_CART		:= "P"
				SEF->EF_LIBER		:= cLiberado
				SEF->EF_ORIGEM 	:= "FINA550"
				SEF->EF_FORNECE	:= SA2->A2_COD
				SEF->EF_LOJA		:= SA2->A2_LOJA
				SEF->EF_LA     	:= "S"
				SEF->EF_SEQUENC	:= "01"
				SEF->EF_TITULO  	:= aRep[4]
				SEF->EF_TIPO		:= aRep[3]
				MsUnlock() 
			Endif
		EndIf
    Else
		Reclock( "SEF", .T. )
		SEF->EF_FILIAL	:= xFilial("SEF")
		SEF->EF_NUM		:= aRep[4]
		SEF->EF_BANCO		:= aBco[1]
		SEF->EF_AGENCIA	:= aBco[2]
		SEF->EF_CONTA		:= aBco[3]
		SEF->EF_DATA 		:= aRep[5]
		SEF->EF_VALOR		:= xMoeda(aRep[7],nMoedaCx,aBco[4])
		SEF->EF_BENEF		:= SA2->A2_NOME
		SEF->EF_HIST 		:= STR0020
		SEF->EF_LIBER		:= cLiberado
		SEF->EF_ORIGEM 	:= "FINA550"
		SEF->EF_IDSEF		:= cChaveCH
		MsUnlock()
	EndIf

	If (SEF->EF_VALOR>0) .and. cLiberado == "S"
		dbSelectArea("SE5")
		dbSetOrder(11)
		cStringSE5 := xFilial("SE5")+ aBco[1] + aBco[2] + aBco[3] + SEF->EF_NUM
		If dbSeek(cStringSE5)  // E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+DTOS(E5_DATA)
			While cStringSE5 == SE5->(E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ) .and. !eof()
				If ( SE5->E5_TIPODOC $ "CH³CA³CD" .And. SE5->E5_SITUACA != "C" )
					If PadL(AllTrim(cSequen),nTamSeq,"0") < PadL(AllTrim(SE5->E5_SEQ),nTamSeq,"0")
						cSequen := SE5->E5_SEQ
					Endif
				Endif
				DbSkip()
			Enddo
		Endif

		If Len(AllTrim(cSequen)) < nTamSeq
			cSequen := PadL(AllTrim(cSequen),nTamSeq,"0")
		Endif
		cSequen := Soma1(cSequen,nTamSeq)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava registro referente a movimentação Bancária ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		If lTpDeb .or. cPaisLoc == "BRA"
	  		
	  		nOrdSA6:=SA6->( IndexOrd() )
			DbSetOrder( 1 )
			SA6->( msSeek( xFilial("SA6")+aBco[1]+aBco[2]+aBco[3] ) )
			cMoedaBco := STRZERO( Max( SA6->A6_MOEDA, 1 ), 2 ) 
			SA6->( DbSetOrder( nOrdSA6 ) )
	  		
	  		//Define os campos que não existem na FK5 e que serão gravados apenas na E5, para que a gravação da E5 continue igual
			cCamposE5 := "{"
			cCamposE5 += "{'E5_BENEF', SA2->A2_NOME}"
			cCamposE5 += ",{'E5_DTDIGIT', dDataBase}"
			cCamposE5 += ",{'E5_CLIFOR', SA2->A2_COD}"
	  		cCamposE5 += "}"

	  		oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. )
	  		oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )
			oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo
			
			//Dados do Processo
			oSubFKA := oModelMov:GetModel("FKADETAIL")
			oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
			oSubFKA:SetValue( "FKA_TABORI", "FK5" )
			
			//Informacoes do movimento
			oSubFK5 := oModelMov:GetModel("FK5DETAIL")
			oSubFK5:SetValue( "FK5_VALOR", SEF->EF_VALOR )
			oSubFK5:SetValue( "FK5_DATA", dDataBase )
			oSubFK5:SetValue( "FK5_MOEDA", cMoedaBco )
			oSubFK5:SetValue( "FK5_NATURE", SET->ET_NATUREZ )
			oSubFK5:SetValue( "FK5_RECPAG", "P" )
			oSubFK5:SetValue( "FK5_TPDOC", "CH" )
			oSubFK5:SetValue( "FK5_BANCO", aBco[1] )
			oSubFK5:SetValue( "FK5_AGENCI", aBco[2] )
			oSubFK5:SetValue( "FK5_CONTA", aBco[3] )
			oSubFK5:SetValue( "FK5_NUMCH", aRep[4] )
			oSubFK5:SetValue( "FK5_DTDISP", dDataBase )
			oSubFK5:SetValue( "FK5_SEQ", cSequen )
			oSubFK5:SetValue( "FK5_FILORI", SEU->EU_FILORI )
			oSubFK5:SetValue( "FK5_HISTOR", OemToAnsi(STR0020) )
			oSubFK5:SetValue( "FK5_ORIGEM", FunName() )
			oSubFK5:SetValue( "FK5_DOC", SEU->EU_NUM )
			
			If SpbInUse()
				oSubFK5:SetValue( "FK5_MODSPB", "3" )
			Endif
			
			//Dados do Cheque
			If !oSubFKA:IsEmpty()
				oSubFKA:AddLine()
			Endif
			oSubFKA:SetValue( "FKA_IDORIG", cChaveCH )
			oSubFKA:SetValue( "FKA_TABORI", "SEF" )
		EndIf


		If lTpDeb .or. cPaisLoc == "BRA"
			If oModelMov:VldData()
		    	oModelMov:CommitData()
				oModelMov:DeActivate()
			Else
			    lRet := .F.
			    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
	    		cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
	    		cLog += cValToChar(oModelMov:GetErrorMessage()[6])
	
	    		Help( ,,"MF550CHREP1",,cLog, 1, 0 )	  		    		
			Endif
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza saldo bancario.								  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AtuSalBco(aBco[1],aBco[2],aBco[3],SE5->E5_DATA,SE5->E5_VALOR,"-")
	Endif

Endif
If aRep[8] .AND. (If( Alltrim(aRep[3]) $ Trim(MVCHEQUE),cLiberado == "S",.T.)) .AND. lRet
	//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
	cCamposE5 := "{"
	cCamposE5 += "{'E5_DTDIGIT', dDataBase}"
	cCamposE5 += ",{'E5_PREFIXO', SE2->E2_PREFIXO}"
	cCamposE5 += ",{'E5_NUMERO', SE2->E2_NUM}"
	cCamposE5 += ",{'E5_PARCELA', SE2->E2_PARCELA}"
	cCamposE5 += ",{'E5_CLIFOR', SA2->A2_COD}"
	cCamposE5 += ",{'E5_LOJA', SA2->A2_LOJA}"
	cCamposE5 += ",{'E5_BENEF', SA2->A2_NOME}"
	cCamposE5 += ",{'E5_TIPO', SE2->E2_TIPO}"
	cCamposE5 += ",{'E5_MOVCX', 'S'}"
	cCamposE5 += "}"

	oModelBxP:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
	oModelBxP:Activate()
	oModelBxP:SetValue( "MASTER", "E5_GRV", .T. )
	oModelBxP:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
	oModelBxP:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo
	
	oSubFK2 := oModelBxP:GetModel("FK2DETAIL")
	oSubFK5 := oModelBxP:GetModel("FK5DETAIL")
	oSubFKA := oModelBxP:GetModel("FKADETAIL")

	//Dados da tabela auxiliar com o código do título a pagar
	cChaveTit := xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SA2->A2_COD+"|"+SA2->A2_LOJA	              	
	cIdDoc := FINGRVFK7( "SE2", cChaveTit )
	
	oSubFKA:SetValue( 'FKA_IDORIG', FWUUIDV4() )
	oSubFKA:SetValue( 'FKA_TABORI', 'FK2' )

	//Dados da baixa a pagar
	oSubFK2:SetValue( "FK2_DATA", dDataBase )
	oSubFK2:SetValue( "FK2_VALOR", SE2->E2_VALOR )
	oSubFK2:SetValue( "FK2_MOEDA", StrZero(SE2->E2_MOEDA,2) )
	oSubFK2:SetValue( "FK2_NATURE", SET->ET_NATUREZ )
	oSubFK2:SetValue( "FK2_RECPAG", "P" )
	oSubFK2:SetValue( "FK2_TPDOC", "VL" )
	oSubFK2:SetValue( "FK2_HISTOR", OemToAnsi(STR0020) )
	oSubFK2:SetValue( "FK2_VLMOE2", SE2->E2_VALOR )
	oSubFK2:SetValue( "FK2_MOTBX", "DEB" )
	oSubFK2:SetValue( "FK2_TXMOED", RecMoeda(dDataBase,aBco[4]) )
	oSubFK2:SetValue( "FK2_ORIGEM", FunName() )
	oSubFK2:SetValue( "FK2_SEQ", PadL("1",TamSX3("E5_SEQ")[1],"0") )
	oSubFK2:SetValue( "FK2_IDDOC", cIdDoc )
	              
	oSubFKA:AddLine()
	oSubFKA:SetValue( 'FKA_IDORIG', FWUUIDV4() )
	oSubFKA:SetValue( 'FKA_TABORI', 'FK5' )
	
	//Dados do Movimento
	oSubFK5:SetValue( "FK5_VALOR", SE2->E2_VALOR )
	oSubFK5:SetValue( "FK5_RECPAG", "P" )
	oSubFK5:SetValue( "FK5_HISTOR", OemToAnsi(STR0020) )
	oSubFK5:SetValue( "FK5_DATA", dDataBase )
	oSubFK5:SetValue( "FK5_TPDOC", "VL" )
	oSubFK5:SetValue( "FK5_NATURE", SET->ET_NATUREZ )
	oSubFK5:SetValue( "FK5_BANCO", aBco[1] )
	oSubFK5:SetValue( "FK5_AGENCI", aBco[2] )
	oSubFK5:SetValue( "FK5_CONTA", aBco[3] )
	oSubFK5:SetValue( "FK5_DTDISP", aRep[6] )
	oSubFK5:SetValue( "FK5_SEQ", PadL( "1", TamSX3("E5_SEQ")[1], "0" ) )
   	oSubFK5:SetValue( "FK5_MOEDA", StrZero(SE2->E2_MOEDA,2) )
   	oSubFK5:SetValue( "FK5_VLMOE2", SE2->E2_VALOR )
   	oSubFK5:SetValue( "FK5_TXMOED", RecMoeda(dDataBase,aBco[4]) )
   	oSubFK5:SetValue( "FK5_ORIGEM", FunName() )
   	oSubFK5:SetValue( "FK5_DOC", SEU->EU_NUM)

	If oModelBxP:VldData()
    	oModelBxP:CommitData()
		oModelBxP:DeActivate()
	Else
		lRet := .F.
	    cLog := cValToChar(oModelBxP:GetErrorMessage()[4]) + ' - '
    	cLog += cValToChar(oModelBxP:GetErrorMessage()[5]) + ' - '
    	cLog += cValToChar(oModelBxP:GetErrorMessage()[6])

    	Help( ,,"MF550CHREP2",,cLog, 1, 0 )	             
	Endif

	If lRet
		If SE5->E5_RECPAG == "P"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lacncamento orcamentario                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000007","03","FINA550")

		ElseIf SE5->E5_RECPAG == "R"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lacncamento orcamentario                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000007","04","FINA550")

		EndIf

		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")
		If FXMultSld()
			AtuSalCxa( SET->ET_CODIGO, dDataBase, SE5->E5_VALOR * (-1) )
		EndIf
		If cPaisLoc <> "BRA"
			If lFindITF .And. FinProcITF( SE5->( Recno() ),1 ) .AND. lRetCkPG(3,,aBco[1])
				FinProcITF( SE5->( Recno() ),3,, .F., aHdlPrv, @aFlagCTB )
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apontamento no SIGAPMS                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntePms().AND. !lPmsInt .And. mv_par05==1
			RegToMemory("SE5",.F.,.F.)
			PmsDlgMB(3,M->E5_PROJPMS,Alltrim(M->E5_HISTOR)+" ("+Alltrim(Transform(M->E5_VALOR,"@E 999,999,999.99"))+")","P")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao dos dados do Modulo SIGAPMS    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PmsWriteMB(1,"SE5")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoFinLan('000007')
		PcoFreeBlq('000007')
	Endif
EndIf
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa550CJCC ºAutor  ³Marcello            ºFecha ³ 28/07/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o saldo de um "caixinha" a partir de um movimento  º±±
±±º          ³de reposicao.                                               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do movimento                      		  ³±±
±±³          ³ ExpC2 = Acao a ser realizada                      		  ³±±
±±³          ³         A = atualizar o caixinha                  		  ³±±
±±³          ³         C = cancelar o movimento                  		  ³±±
±±³          ³         S = compara saldo do caixinha com o do movimento   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA550/FINA560                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550CJCC(cMovimento,cAcao)
Local lRet:= .F.
Local aArea := GetArea()
Local aSEU := {}, aSET := {}

cAcao:=Upper(Alltrim(cAcao))
DbSelectArea("SEU")
aSEU:=GetArea()
DbSetOrder(1)
If DbSeek(xFilial("SEU")+cMovimento)
	Do Case
		Case cAcao$"A|C"  //atualizar o caixinha
			RecLock("SEU",.F.)
			DbSelectArea("SET")
			aSET:=GetArea()
			DbSetOrder(1)
			If DbSeek(xFilial("SET")+SEU->EU_CAIXA)
				RecLock("SET",.F.)
				If cAcao=="A"
					Replace ET_SALDO With ET_SALDO+SEU->EU_VALOR
					Replace ET_ULTREP With dDataBase
					If ET_SITUAC!="0"
						Replace ET_SEQCXA With Soma1(ET_SEQCXA)
					Endif
					MsUnlock()
					PcoDetLan("000359","01","FINA550")
					Replace SEU->EU_BAIXA With dDataBase
					Replace SEU->EU_TIPO With "10"
					Replace SEU->EU_SEQCXA With SET->ET_SEQCXA
					lRet:=.T.
				Else
					Replace ET_SALDO With ET_SALDO-SEU->EU_VALOR
					Replace ET_ULTREP With Ctod("//")
					MsUnlock()
					PcoDetLan("000359","01","FINA550")
					Replace SEU->EU_BAIXA With Ctod("//")
					Replace SEU->EU_TIPO With "92"
					Replace SEU->EU_SEQCXA With ""
					lRet:=.T.
				Endif
			Endif
			SEU->(MsUnLock())
			PcoDetLan("000359","02","FINA550")
			RestArea(aSET)
		Case cAcao=="S"
			DbSelectArea("SET")
			aSET:=GetArea()
			DbSetOrder(1)
			If DbSeek(xFilial("SET")+SEU->EU_CAIXA)
				lRet:=(SEU->EU_VALOR<=SET->ET_SALDO)
			Endif
			RestArea(aSET)
	EndCase
	DbSelectArea("SEU")
Endif
DbSelectArea("SEU")
RestArea(aSEU)
RestArea(aArea)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA550MvBc2³ Autor ³ Leonardo Ruben        ³ Data ³ 28.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registra movimento no SE5                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa550MvBc2(ExpC1,ExpN1,ExpC2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Define se movimento de Entrada ou Saida 			  ³±±
±±³			 ³ ExpN1 = Valor do Movimento 								  ³±±
±±³			 ³ ExpN2 = Historico do Movimento      						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550MvBc2(cTipoES, nValor, cHistor, cBco, cAge, cCta, aRep, nTaxaCtr )
Local aAreaAnt := GetArea()
Local nMoedaCx := 1
Local oModelMov := FWLoadModel("FINM030")
Local oSubFK5
Local oSubFKA
Local cLog := ""
Local lRet := .T.
local cCamposE5 := ""
Local cChaveCH := ""
Local nTamBco := TamSX3("EF_BANCO")[1]
Local nTamAge := TamSX3("EF_AGENCIA")[1]
Local nTamCta := TamSX3("EF_CONTA")[1]
Local nTamCod := TamSX3("EF_NUM")[1]
Local lAtuSldNat	:= FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")   

DEFAULT aRep		:= {"","","","",dDataBase,dDataBase,nValor,.T.,.T.,"",""}

Private aRatAJE		:= {}

If nValor == 0
	Return
Endif
DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2")+SET->ET_FORNECE+SET->ET_LOJA)

dbSelectArea("SA6")
dbSetOrder(1)
dbSeek( xFilial()+SET->ET_BANCO+SET->ET_AGEBCO+SET->ET_CTABCO )
nMoedaCx:=Max(nMoedaCx,SA6->A6_MOEDA)

dbSelectArea("SA6")
dbSeek( xFilial()+cBco+cAge+cCta)

DbSelectArea("SE5")

//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
cCamposE5 := "{"
cCamposE5 += "{'E5_DTDIGIT', dDataBase}"
cCamposE5 += ",{'E5_PREFIXO', ''}"
cCamposE5 += ",{'E5_NUMERO', '" + aRep[4] + "'}"
cCamposE5 += ",{'E5_PARCELA', ''}"
cCamposE5 += ",{'E5_CLIFOR', SET->ET_FORNECE}"
cCamposE5 += ",{'E5_LOJA', SET->ET_LOJA}"
cCamposE5 += ",{'E5_VENCTO', STOD('" + DTOS(aRep[6]) + "')}"  
cCamposE5 += ",{'E5_MOVCX', 'S'}"

oModelMov:SetOperation( MODEL_OPERATION_INSERT ) // Inclusao
oModelMov:Activate()
oModelMov:SetValue( "MASTER", "E5_GRV", .T. )
oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo

//Dados do Processo
oSubFKA := oModelMov:GetModel("FKADETAIL")
oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
oSubFKA:SetValue( "FKA_TABORI", "FK5" )

//Dados do movimento
oSubFK5 := oModelMov:GetModel("FK5DETAIL")
oSubFK5:SetValue( "FK5_VALOR", xMoeda(nValor,nMoedaCx,SA6->A6_MOEDA) )
oSubFK5:SetValue( "FK5_RECPAG", If(cTipoES ="E", "R", "P") )
oSubFK5:SetValue( "FK5_HISTOR", cHistor )
oSubFK5:SetValue( "FK5_DATA", dDataBase )
oSubFK5:SetValue( "FK5_FILORI", SEU->EU_FILORI )
oSubFK5:SetValue( "FK5_TPDOC", "DH" )
If cPaisLoc <> "BRA"
	cCamposE5 += ",{'E5_MOTBX', 'NOR'}"
	cCamposE5 += ",{'E5_TIPO', '" + aRep[3] + "'}"
	cCamposE5 += ",{'E5_BENEF', SA2->A2_NOME}"
	
	oSubFK5:SetValue( "FK5_TPDOC", "VL" )
	//Gravar a moeda2 em moeda 1 para facilitar a contabilizacao
	oSubFK5:SetValue( "FK5_VLMOE2", xMoeda(nValor,nMoedaCx,1) )
	oSubFK5:SetValue( "FK5_TXMOED", RecMoeda(dDataBase,SA6->A6_MOEDA) )
Else	
	/*
	Conforme documentação disponível no tdn: padrão de gravação dos movimentos em moeda estrangeira.
	A reposição de caixinha, grava os campos E5_MOEDA, E5_VALOR, E5_VLMOED2 e E5_TXMOEDA da seguinte forma:
	E5_MOEDA, grava a moeda do banco.
	E5_VALOR, grava o valor do movimento na moeda do banco.
	E5_VLMOED2, grava o valor do movimento convertido para moeda corrente.
	E5_TXMOEDA, grava a cotação da moeda do banco, ou a cotação informada pelo usuário na tela reposição de caixinha. 	
	
	Obs:Embora esse não seja o padrão de gravação definida pela moeda do banco, não deve ser alterado pois o relatório
	de extrato bancário está preparado para interpretar esse movimento conforme essa gravação. Qualquer mudança feita 
	na gravação desses campos, deve ser testado o rel. de extrato bancário e ajustada a documentação no tdn. 
	*/	
	If nTaxaCtr == NIL
		nTaxaCtr := RecMoeda( dDataBase, SA6->A6_MOEDA )
	EndIf

	If FXMultSld()
		oSubFK5:SetValue( "FK5_VALOR", xMoeda( nValor, nMoedaCx, SA6->A6_MOEDA,,,, nTaxaCtr ) )
	Else
		oSubFK5:SetValue( "FK5_VALOR", xMoeda(nValor,nMoedaCx,SA6->A6_MOEDA) )
	Endif
	oSubFK5:SetValue( "FK5_VLMOE2", xMoeda(nValor,nMoedaCx,1) )
	oSubFK5:SetValue( "FK5_TXMOED", nTaxaCtr )
Endif
oSubFK5:SetValue( "FK5_MOEDA", StrZero(Max(1,SA6->A6_MOEDA),2) )
oSubFK5:SetValue( "FK5_NATURE", SET->ET_NATUREZ )
oSubFK5:SetValue( "FK5_BANCO", cBco )
oSubFK5:SetValue( "FK5_AGENCI", cAge )
oSubFK5:SetValue( "FK5_CONTA", cCta )
oSubFK5:SetValue( "FK5_DTDISP", aRep[6] )
oSubFK5:SetValue( "FK5_LA", "S" )
oSubFK5:SetValue( "FK5_NUMCH", aRep[4] )
oSubFK5:SetValue( "FK5_ORIGEM", FunName() )
oSubFK5:SetValue( "FK5_DOC", SEU->EU_NUM )

//Dados do Cheque
aAreaAnt := GetArea()
dbSelectArea( "SEF" )
SEF->( DbSetOrder( 1 ) )
If MsSeek( xFilial("SEF") + PadR(cBco, nTamBco) + PadR(cAge, nTamAge) + PadR(cCta, nTamCta) + PadR(aRep[4], nTamCod) )
	cChaveCH := SEF->EF_IDSEF

	//Se o cheque não possuir ID, salva um novo ID para vincular à FKA
	If Empty(cChaveCH)
		cChaveCH := FWUUIDV4()
		RecLock("SEF", .F.)
		SEF->EF_IDSEF	:= cChaveCH
		MsUnlock()
	Endif

	oSubFKA:AddLine()
	oSubFKA:SetValue( 'FKA_IDORIG', cChaveCH )
	oSubFKA:SetValue( 'FKA_TABORI', 'SEF' )
Endif
RestArea(aAreaAnt)

//Ponto de entrada para gravacoes complementares do SE5
IF ExistBlock("F550BCO")
	ExecBlock("F550BCO",.f.,.f.)
Endif

cCamposE5 += "}"
oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5

If oModelMov:VldData()
	oModelMov:CommitData()
	oModelMov:DeActivate()
Else
	lRet := .F.
    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
    cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
    cLog += cValToChar(oModelMov:GetErrorMessage()[6])

    Help( ,,"MF550MVBC2",,cLog, 1, 0 )
Endif

If lRet
	AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dDataBase,SE5->E5_VALOR,If(cTipoES="E","+","-"))

	If lAtuSldNat
		AtuSldNat(SET->ET_NATUREZ, dDataBase, nMoedaCx, "3", "P", SE5->E5_VALOR,SE5->E5_VLMOED2, "+",,FunName(),"SE5", SE5->(Recno()),0)
	EndIf

	If FXMultSld()
		AtuSalCxa( SET->ET_CODIGO, dDataBase, SE5->E5_VALOR * If(cTipoES="S", 1 ,-1 ) )
	Else
		AtuSalCxa( SET->ET_CODIGO, dDataBase,  nValor )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apontamento no SIGAPMS                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IntePms().AND. !lPmsInt .And. mv_par05==1
		RegToMemory("SE5",.F.,.F.)
		PmsDlgMB(3,M->E5_PROJPMS,Alltrim(M->E5_HISTOR)+" ("+Alltrim(Transform(M->E5_VALOR,"@E 999,999,999.99"))+")","P")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao dos dados do Modulo SIGAPMS    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PmsWriteMB(1,"SE5")
	EndIf
Endif

RestArea( aAreaAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA550   ºAutor  ³Microsiga           ºFecha ³  07/29/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550Verif()
Local aArea := {}
Local lRet :=.F.
Local aCpos := {}
Local nC := 0
Local nNrCpos := 0
Local aSEU:= {}
Local aSET:= {}

If cPaisLoc<>"BRA"
	aArea:=GetArea()
	aSEU:=SEU->(GetArea())
	aSET:=SET->(GetArea())
	aCpos:=	{;
	{"SET","ET_FORNECE"},;
	{"SET","ET_LOJA"},;
	{"SET","ET_CODUSR"},;
	{"SET","ET_NRREND"},;
	{"SEU","EU_BCOREP"},;
	{"SEU","EU_AGEREP"},;
	{"SEU","EU_CTAREP"},;
	{"SEU","EU_TITULO"},;
	{"SEU","EU_TIPDEB"},;
	{"SEU","EU_NRREND"},;
	{"SEU","EU_SERCOMP"};
	}
	nNrCpos:=Len(aCpos)
	nC:=0
	lRet:=.T.
	While nC<nNrCpos .And. lRet
		nC++
		DbSelectArea(aCpos[nC][1])
		lRet:=(FieldPos(aCpos[nC][2])>0)
	Enddo
	If lRet
		DbSelectArea("SIX")
		lRet:=DbSeek("SEU7")
		If lRet
			lRet:=DbSeek("SEU8")
		Endif
	Endif
	SEU->(RestArea(aSEU))
	SET->(RestArea(aSET))
	RestArea(aArea)
ElseIf cPaisLoc== "BRA" .And. (lRpMnAcLim)
	lRet := .T.
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa550GrUsrºAutor  ³Marcello            ºFecha ³ 06/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar o codigo do usuario / grupo de usuario              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA550                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550GrUsr(cChv,lUsr)
Local lRet:=.T.

Default lUsr:=.T.

If !Empty(cChv)
	PswOrder(1)
	lRet:=PswSeek(cChv,lUsr)
	If !lRet
		If lUsr
			MsgAlert(STR0050+cChv+STR0051) //"Usuario "###" nao encontrado."
			If Type("M->ET_USUARIO")!="U"
				M->ET_USUARIO:=Space(TamSX3("ET_USUARIO")[1])
			Endif
		Else
			MsgAlert(STR0052+cChv+STR0051) //"Grupo "###" nao encontrado."
			If Type("M->ET_GRPDESC")!="U"
				M->ET_GRPDESC:=Space(TamSX3("ET_GRPDESC")[1])
			Endif
		Endif
	Else
		If lUsr
			If Type("M->ET_USUARIO")!="U"
				M->ET_USUARIO:=PswRet()[1][2]
			Endif
		Else
			If Type("M->ET_GRPDESC")!="U"
				M->ET_GRPDESC:=PswRet()[1][2]
			Endif
			If Type("M->ET_CODUSR")!="U"
				M->ET_CODUSR:=Space(Len(SET->ET_CODUSR))
			Endif
			If Type("M->ET_USUARIO")!="U"
				M->ET_USUARIO:=Space(TamSX3("ET_USUARIO")[1])
			Endif
		Endif
	Endif
Else
	If lUsr
		If Type("M->ET_USUARIO")!="U"
			M->ET_USUARIO:=Space(TamSX3("ET_USUARIO")[1])
		Endif
	Else
		If Type("M->ET_GRPDESC")!="U"
			M->ET_GRPDESC:=Space(TamSX3("ET_GRPDESC")[1])
		Endif
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa550Usr  ºAutor  ³Marcello            ºFecha ³ 06/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recuperar o nome do usuario / grupo                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA550                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550Usr(cUsr,lUsr)
Local cRet:=""
Local aUsr:={}

Default cUsr:=""
Default lUsr:=.T.

PswOrder(1)
If PswSeek(cUsr,lUsr)
	aUsr:=PswRet()
    cRet:=aUsr[1][2]
Endif
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa550VlUsrºAutor  ³Marcello            ºFecha ³ 06/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a permissao de um usuario para reposicao de uma      º±±
±±º          ³caixinha                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA550                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550VlUsr(cCaixa,cUsr)
Local lRet := .T.
Local aUsr := {}
Local aSET := {}
Local aArea := GetArea()

Default cUsr:=__CUSERID

DbSelectArea("SET")
aSET:=GetArea()
If cPaisLoc <> "BRA"
	If DbSeek(xFilial("SET")+cCaixa)
		If !Empty(ET_CODUSR)
			lRet:=(Alltrim(ET_CODUSR)==Alltrim(cUsr))
		Else
			If !Empty(ET_GRPUSR)
				PswOrder(1)
				If PswSeek(cUsr)
					aUsr:=PswRet(1)
					lRet:=(Ascan(aUsr[1][10],ET_GRPUSR)>0)
				Endif
			Endif
		Endif
	Else
		lRet:=.F.
	Endif
Endif
SET->(RestArea(aSET))
RestArea(aArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa550When ºAutor  ³Cristiano Denardi   ºFecha ³ 25.05.2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Definicao de permissao p/ alterecao de campos do Caixinha   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA550                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550When(cCampo)

Local 	aAr		:= GetArea()
Local 	lWhen 	:= .F.
Default cCampo	:= ""

If !Empty(cCampo)
	If cCampo == "ET_VALOR"
		Do Case
			Case Inclui
				lWhen := .T.
			Case ET_SITUAC == "1"
				lWhen := .T.
		End Case
	Endif
Endif

RestArea( aAr )
Return(lWhen)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³27/11/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
Local aRotina := { {STR0001, "AxPesqui",  0,1,,.F.},;   // "Pesquisar"
								{STR0002, "AxVisual",  0,2},;   // "Visualizar"
								{STR0003, "FA550Inclui",0,3},;   // "Incluir"
								{STR0004, "FA550Altera",0,4},;   // "Alterar"
								{STR0005, "FA550Deleta",0,5},;   // "Excluir"
								{STR0006, "FA550Repos" ,0,4},;   // "Reposicao"
								{STR0107,	"FA550RCan",0,5},; // "Cancela Reposição" 	
								{STR0007, "FA550Baixa" ,0,4},;  // "Baixa/Rendicao"
								{STR0097, "CTBC662" ,0,7},;  // "Tracker Contábil"
								{STR0027, "FA550Legend",0,2, ,.F.} }  //"Legenda"
							
//Ponto de entrada para incluir botao no arotina
If ExistBlock("FA550BUT")
	aRotina := Execblock("FA550BUT",.F.,.F.,{aRotina})
Endif

Return(aRotina)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA550T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 04.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA550T(aParam)
	cRotinaExec := "FINA550"
	ReCreateBrow("SET",FinWindow)
	FinA550(aParam[1])
	ReCreateBrow("SET",FinWindow)
	dbSelectArea("SET")

	INCLUI := .F.
	ALTERA := .F.

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA550TOK  ³ Autor ³ Totvs                ³ Data ³ 09/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao para inclusao/alteracao do caixinha.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA550TOK()
	Local lRet		:= .T.
	Local nMoedBco	:= 0
	Local lNat		:= .F.

	DbSelectArea( "SED" )
	SED->(DbSetOrder(1))
	lNat := SED->(dbSeek(xFilial("SED")+M->ET_NATUREZ))
	If lNat .And. SED->ED_MSBLQL == "1"
		Help(" ", 1, "REGBLOQ")
		lRet := .F.
	EndIf

	// Valida a moeda da conta corrente com a moeda do caixiha
	If FXMultSld() .And. lRet
  		DbSelectArea( "SA6" )
  		SA6->( DbSetOrder( 1 ) )
  		If SA6->( DbSeek( xFilial( "SA6" ) + M->( ET_BANCO + ET_AGEBCO + ET_CTABCO ) ) )
			nMoedBco	:= SA6->A6_MOEDA
		EndIf
		If cPaisLoc == "BRA"
			If M->ET_MOEDA > 1					// Permitir Moeda corrente
				If nMoedBco <> M->ET_MOEDA		// Permitir Moeda igual ao do caixinha
					lRet := .F.
					Help( " ", 1, "FA550TOK",, STR0066, 1, 0 ) //"A moeda informada difere da moeda da C/C"
				EndIf
			EndIf
		Endif
	EndIf

	If (!Empty(M->ET_FORNECE) .Or. !Empty(M->ET_LOJA)) .And. lRet
		lRet := Fa550Forn()
	Endif

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ lRetCkPG  ³ Autor ³ Totvs                ³ Data ³ 09/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function lRetCkPG(n,cDebInm,cBanco,nPagar)
Local lRetCx:=.T.
If cPaisLoc$"PER|DOM"
   If n==3
      If cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
         lRetCx:=.F.
      Endif
   Endif
Endif
Return(lRetCx)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa550Forn ³ Autor ³ Marcos Berto         ³ Data ³ 15/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao um dado fornecedor e loja para o caixinha        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa550Forn(cCampo)

Local lReturn := .T.

DEFAULT cCampo  := ""

If !Empty(M->ET_FORNECE) .And.  cCampo == "ET_FORNECE"

	If Empty(M->ET_LOJA)
		If !ExistCpo("SA2",M->ET_FORNECE)
			lReturn := .F.
		Endif
	Endif

	If M->ET_FORNECE == SA2->A2_COD
		M->ET_LOJA := SA2->A2_LOJA
	Else
		//Preencho a loja com a 1a. loja disponível, em caso do usuario editar manualmente os campos
		dbSelectArea("SA2")
		aAreaSA2 := SA2->(GetArea())
		SA1->(dbSetOrder(1))

		If dbSeek(xFilial("SA2")+M->ET_FORNECE)
			M->ET_LOJA := SA2->A2_LOJA
		Endif
	Endif

	If !ExistCpo("SA2",M->ET_FORNECE+M->ET_LOJA)
		lReturn := .F.
	Endif
ElseIf !Empty(M->ET_FORNECE) .And. !Empty(M->ET_LOJA) .And. cCampo == "ET_LOJA"
	If !ExistCpo("SA2",M->ET_FORNECE+M->ET_LOJA)
		lReturn := .F.
	Endif
ElseIf ((Empty(M->ET_FORNECE) .And. !Empty(M->ET_LOJA)) .Or. (!Empty(M->ET_FORNECE) .And. Empty(M->ET_LOJA)))
	Help("",1,"RECNO")
	lReturn := .F.
Endif

Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA550   ºAutor  ³Danilo Dias         º Data ³  04/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aprova a reposição no caixinha de acordo com o cadastro    º±±
±±º          ³ de Gestores Financeiros.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA550                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa550Libera( aRep )

Local lRet       := .T.
Local lValSaldo  := .T.
Local aArea      := GetArea()
Local nOpc       := 0	//Opção de não aprovado
Local oDlg       := Nil
Local oBtnAprov, oBtnCanc
Local cNumTit    := aRep[4]	//Número do título da reposição
Local cEmissao   := aRep[5]	//Data de emissão da reposição
Local cUsrAprov  := ""  //Código de usuário do aprovador
Local cCodAprov  := ""	//Código do aprovador
Local cNomAprov  := ""	//Nome do aprovador
Local cMoeda     := Strzero(aRep[12],TamSx3("FRP_MOEDA")[1]) //CValToChar(aRep[12])
Local dDtRef     := dDataBase	//Data de referência da aprovação
Local nLimMin    := 0	//Valor mínimo para aprovação do usuário
Local nLimMax    := 0	//Valor máximo para aprovação do usuário
Local nSldAprov  := 0	//Saldo do aprovador
Local cTipoLim   := ""	//Tipo de limite para o aprovador
Local nSaldo     := SET->ET_SALDO	//Saldo do caixinha
Local nTotal     := aRep[7]			//Valor total do movimento
Local nSaldoF    := nSaldo + nTotal	//Saldo do caixinha após a aprovação
Local aTipoLim   := {}				//Tipos de limite do aprovador no SX3, campo FRP_TIPO
Local lGravou    := .T.	//Indica se gravou a movimentação na tabela de saldos
Local lValMaxMin := .T.

Local bAcaoAprov := { || IIf( FXALCGrava( cUsrAprov, cCodAprov, cMoeda, "4", dDtRef, nTotal ),;	//Grava movimentação na tabela FRT (FINXALC.PRW)
							( oDlg:End(), nOpc := 1 ),;			//Tratamento se atualizou o saldo do gestor corretamente
							( nOpc := 0, lGravou := .F. ) ) }	//Tratamento se houve erro na gravação

//Inicializa campos da tabela FRP
dbSelectArea("FRP")
FRP->(dbSetOrder(2))
FRP->(dbGoTop())

If !( FRP->(dbSeek( xFilial() + __cUserId ) ) )
	Help( " ", 1, "Fa550Libera", , STR0072, 1, 0 ) //"Usuário não encontrado no cadastro de Gestores Financeiros!"
	lRet := .F.
Else
	cNomAprov := cUserName
	cUsrAprov := FRP->FRP_USER
	cCodAprov := FRP->FRP_COD
	nLimMin   := FRP->FRP_LIMMIN
    nLimMax   := FRP->FRP_LIMMAX
    cTipoLim  := FRP->FRP_TIPO

    //Verifica se Gestor pode aprovar o título de acordo com o limite máximo definido
   	dbSelectArea("FRR")
	FRR->(dbSetOrder(2))
    If (dbSeek( xFilial("FRR") + cUsrAprov + cMoeda ))
    	lValMaxMin := Iif(FRR->FRR_AUTLIM == '1', .T., .F.)
	EndIf
	dbSelectArea("FRP")

    If ( nLimMax < nTotal ) .AND. lValMaxMin
    	Help( " ", 1, "Fa550Libera", , STR0073, 1, 0 )  //"Valor ultrapassa limite máximo estipulado para o Gestor."
    	lRet := .F.
    EndIf

    //Valor abaixo do minimo.
    If ( nLimMin > nTotal ) .AND. lValMaxMin
    	Help('', 1, "Fa550Libera", , STR0096, 1, 0)	//"Valor está abaixo do limite mínimo estipulado para o gestor."
    	lRet := .F.
    EndIf

EndIf

If lRet

	//Valida o saldo do aprovador na data de referência.
    lValSaldo  := Fa550ValSld( cUsrAprov, cCodAprov, cMoeda, dDtRef, nTotal, @nSldAprov )

	//Carrega tipos de limite do campo combo pelo X3_CBOX
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek("FRP_TIPO"))
		aTipoLim := StrToKarr( X3CBox(), ";" )
	EndIf

	//Cria Dialog de aprovação da reposição
	oDlg := MSDialog():New( 0, 0, 400, 600, STR0074, , , , , , , , oMainWnd, .T., , , , )	//"Aprovação de Reposição"

		oGroup1 := TGroup():New( 002, 005, 042, 295, STR0075, oDlg,,,.T., )	//"Movimento"

			oSay     := TSay():New( 012, 010, { || STR0076 }, oGroup1,,,,,,.T.,,, 60, 10 )	//"Número Int."
		    oNumTit  := TGet():New( 010, 070, { |u| If( PCount() > 0, cNumTit := u, cNumTit ) }, oGroup1, 060, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"cNumTit" )
		    oSay     := TSay():New( 012, 170, { || STR0077 }, oGroup1,,,,,,.T.,,, 60, 10 )	//"Emissão"
		    oEmissao := TGet():New( 010, 230, { |u| If( PCount() > 0, cEmissao := u, cEmissao ) }, oGroup1, 060, 010, X3Picture("EU_EMISTIT"),,,,,,,.T.,,,{|| .F.},,,,,,,"cEmissao" )
		    oSay     := TSay():New( 026, 170, { || STR0078 }, oGroup1,,,,,,.T.,,, 60, 10 )	//"Data de Ref."
		    oDtRef   := TGet():New( 024, 230, { |u| If( PCount() > 0, dDtRef := u, dDtRef ) }, oGroup1, 060, 010,,,,,,,,.T.,,,/*{|| .F.}*/,,, { || lValSaldo  := Fa550ValSld( cUsrAprov, cCodAprov, cMoeda, dDtRef, nTotal, @nSldAprov ), oDlg:Refresh() },,,, "dDtRef" )

		oGroup2 := TGroup():New( 050, 005, 105, 295, STR0079, oDlg,,,.T., )	//"Aprovador"

		    oSay     := TSay():New( 060, 010, { || STR0079 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Aprovador"
		    oAprov   := TGet():New( 058, 070, { |u| If( PCount() > 0, cNomAprov := u, cNomAprov ) }, oGroup2, 220, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"cNomAprov" )
		    oSay     := TSay():New( 076, 010, { || STR0080 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Limite Mín."
		    oLimMin  := TGet():New( 074, 070, { |u| If( PCount() > 0, nLimMin := u, nLimMin ) }, oGroup2, 060, 010, X3Picture("FRP_LIMMIN"),,,,,,,.T.,,,{|| .F.},,,,,,,"nLimMin" )
		    oSay     := TSay():New( 076, 170, { || STR0081 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Limite Máx."
		    oLimMax  := TGet():New( 074, 230, { |u| If( PCount() > 0, nLimMax := u, nLimMax ) }, oGroup2, 060, 010, X3Picture("FRP_LIMMAX"),,,,,,,.T.,,,{|| .F.},,,,,,,"nLimMax" )
		    oSay     := TSay():New( 090, 010, { || STR0082 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Saldo"
		    oLimite  := TGet():New( 088, 070, { |u| If( PCount() > 0, nSldAprov := u, nSldAprov ) }, oGroup2, 060, 010, X3Picture("FRP_LIMITE"),,,,,,,.T.,,,{|| .F.},,,,,,,"nSldAprov" )
		    oSay     := TSay():New( 090, 170, { || STR0083 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Tipo Lim."
		    oTipoLim := TComboBox():New( 088, 230, { |u| If( PCount() > 0, cTipoLim := u, cTipoLim ) }, aTipoLim, 060, 010, oGroup2,,,,,,.T.,,,,{|| .F.},,,,, "cTipoLim" )

		oGroup3 := TGroup():New( 114, 005, 170, 295, STR0084, oDlg,,,.T., )	//"Saldos"

		    oSay     := TSay():New( 124, 010, { || STR0085 }, oGroup3,,,,,,.T.,,, 080, 10 )	//"Saldo na Data"
		    oSaldo   := TGet():New( 122, 100, { |u| If( PCount() > 0, nSaldo := u, nSaldo ) }, oGroup3, 060, 010, X3Picture("ET_SALDO"),,,,,,,.T.,,,{|| .F.},,,,,,,"nSaldo" )
		    oSay     := TSay():New( 138, 010, { || STR0086 }, oGroup3,,,,,,.T.,,, 80, 10 )	//"Total Título"
		    oTotal   := TGet():New( 136, 100, { |u| If( PCount() > 0, nTotal := u, nTotal ) }, oGroup3, 060, 010, X3Picture("EU_VALOR"),,,,,,,.T.,,,{|| .F.},,,,,,,"nTotal" )
		    oSay     := TSay():New( 152, 010, { || STR0087 }, oGroup3,,,,,,.T.,,, 80, 10 )	//"Saldo após aprovação"
		    oSaldoF  := TGet():New( 150, 100, { |u| If( PCount() > 0, nSaldoF := u, nSaldoF ) }, oGroup3, 060, 010, X3Picture("ET_SALDO"),,,,,,,.T.,,,{|| .F.},,,,,,,"nSaldoF" )

		oBtnAprov := tButton():New( 180, 090, STR0088, oDlg, bAcaoAprov, 050,,,,,.T.,,,, { || lValSaldo },,, )	//"Aprovar"
		oBtnCanc := tButton():New( 180, 160, STR0089, oDlg, { || oDlg:End(), nOpc := 0 }, 050,,,,,.T.,,,,,,, )	//"Cancelar"

    oDlg:Activate( ,,,.T.,,,,, )

EndIf

//Se houve erro na gravação do movimento alerta usuário
If !lGravou
	Help( " ", 1, "Fa550Libera", , STR0090, 1, 0 )	//"Erro na atualização do saldo do gestor!"
EndIf

RestArea(aArea)

Return nOpc


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa550ValSld ºAutor  ³ Danilo Dias      º Data ³ 28/04/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o saldo do Gestor Financeiro para realizar a        º±±
±±º          ³ aprovação de movimento.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa550ValSld( cUsrAprov, cCodAprov, cMoeda, dDtRef, nTotal, nSldAprov )

Local aMovAprov
Local lRet := .T.

//Valida se o gestor possui limite
lRet := FXALCValLi( cUsrAprov, cCodAprov, cMoeda, DtoS(dDtRef), nTotal )

aMovAprov := FXAlcSld( cMoeda, dDtRef, cCodAprov, .F. ) 	//Monta array com os movimentos do Gestor
nSldAprov := FXAlcSldFim( aMovAprov )	//Retorna o saldo atual do Gestor

//Caso o Gestor não possua limite informa ao usuário.
If !lRet
	Help( " ", 1, "Fa550Libera", , STR0091 + cMoeda + "." + CRLF +;	//"Gestor não possui saldo disponível na data de referência para a moeda "
		                           STR0092 +;	//"Disponível: "
		                           alltrim( cValToChar( Transform( nSldAprov, PesqPict( "FRP", "FRP_LIMITE" ) ) ) ), 1, 0 )
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtuTpRep ³ Autor ³ Ramon Teodoro         ³ Data ³ 30/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualização do campo tipo de Título                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA550                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AtuTpRep

If !lMovBco
	cTipoRep:="DH"
   oCbTipoRep:Refresh()
	oCbTipoRep:Disable()
Else
  	oCbTipoRep:Refresh()
	oCbTipoRep:Enable()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CxDigiChq ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 04/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que abre ou n„o o get do n§ de cheque na baixa 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CxDigiChq(cBanco,cAgencia,cConta)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Caixinha														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CxDigiChq(cBanco,cAgencia,cConta)
Local lRet := .T.
// Nao habilita o numero de cheque para :
// - Adiantamento, Banco Caixa, Carteira ou Motivo igual a D‚bito em C/C
If SubStr(cBanco,1,2) == "CX"       .or. ;
	cBanco $ GetMv("MV_CARTEIR")     .or. ;
	IsCaixaLoja(cBanco) 					.or. ;
	IsCxFin(cBanco,cAgencia,cConta)
	lRet := .F.
Endif
Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±                                                                         ±±
±±            Funcoes retiradas do arquivo MATXATU.PRX                     ±±
±±                                                                         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//----------------------------------------------------------------------
/*/{Protheus.doc} ºFA550RCan()
Realiza o Estorno da Reposição e retorna o saldo ao banco.

@author Daniel Ferraz Lacerda
@since 27/12/2016
@version 11
@param cAlias, Alias ativo
@param nReg, Registro
@param nOpc, Chamada do Menudef
@param lAutomato. T. ou .F. Automatico ou não.
@return Nill
/*/
//----------------------------------------------------------------------
Function FA550RCan(cAlias,nReg,nOpc,lAutomato)
	Local aAreaAnt := GetArea()
	Local cCaixa := SET->ET_CODIGO
	Local lRet := .T.
	Local Cquery := ""
	Local aEstor := {}
	Local cAliasQry := ""
	Local oDlg := Nil
	Local aTel :={}
	Local nTN := TAMSX3("EU_NUM")[1]
	Local aBco := {}
	Local nCanRep := 0
	Local aAreaSEU := {}
	Local aAreaSEF := {}
	Local cLiberado := GetMV("MV_LIBCHEQ")
	Local lPadrao57E := VerPadrao("57E")
	Local lGeraLanc := IIf(mv_par03==1,.T.,.F.)
	Local nHdlPrv := 0
	Local lUsaFlag := SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local aFlagCTB := {}
	Local cArquivo := ""
	Local nTotal := 0
	Local lDigita := Iif(mv_par01 ==1,.T.,.F.)
	Local lAglutina := Iif(mv_par02 ==1,.T.,.F.)
	Local cBanco := ""
	Local nValor := 0
	Local cNumero := "" 
	Local cAgen := ""
	Local cConta := ""
	Local cCheque := ""
	Local dDtDigit := CTOD("//")
	Local cText := ""
	Local lAchouSEF := .F.
	Local nRecSEF	:= 0 
	Local nRegEst	:= 0
	Local dDtUltRep:= CTOD("//")
	
	#DEFINE CRLF CHR(13)+CHR(10) //FINAL DE LINHA
	Private aDiario := {}
	Private cLote := ""
	Private lEsModII := Iif( SuperGetMV( "MV_FINCTMD", .T., 1 ) == 1, .F., .T. ) //Solo aplica para modelo II
	DEFAULT lAutomato := .F.
	
	cAliasQry := GetNextAlias()
	
	cQuery := "SELECT EU_FILIAL, EU_TIPO, EU_CAIXA, EU_NUM,EU_VALOR,EU_TITULO,"
	cQuery += "EU_HISTOR,EU_BANCO,EU_AGENCI,EU_DTDIGIT, EU_CONTARE,D_E_L_E_T_"
	cQuery += " FROM " + RetSQLTAB('SEU')
	cQuery += " WHERE"  
	cQuery += " EU_FILIAL = '" + FWxFilial('SEU') + "' AND"
	cQuery += " EU_TIPO = '10' AND EU_CAIXA ='" + cCaixa
	cQuery += "' AND EU_SLDADIA = '0' AND D_E_L_E_T_ = ''"
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	If !(cAliasQry)->(Eof())
		
		While !(cAliasQry)->(Eof())
			AADD( aEstor,{(cAliasQry)->EU_NUM,(cAliasQry)->(EU_VALOR),(cAliasQry)->(EU_HISTOR),(cAliasQry)->(EU_DTDIGIT),;
			              (cAliasQry)->(EU_BANCO),(cAliasQry)->(EU_AGENCI),(cAliasQry)->(EU_CONTARE),(cAliasQry)->(EU_TITULO)} )
			
			cTel := CVALTOCHAR((cAliasQry)->EU_NUM) + "   " + CVALTOCHAR((cAliasQry)->EU_VALOR) + "      " + dtoc(stod((cAliasQry)->EU_DTDIGIT))
			
			AADD(aTel,cTel)
			(cAliasQry)->(DbSkip())
		EndDo
	
	Else
		 Alert(STR0108)
		 lRet := .F.
	Endif
	(cAliasQry)->(dbCloseArea())
	
	If lRet
		If Len(aTel) > 1 //Mais de uma reposição, o usuário escolhe
			cListBox := aTel[Len(aTel)]
			nOpbaixa := 0
			
			DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 56 TITLE STR0109 //"Escolha A Baixa"
					
			@  .5, 2 LISTBOX cListBox ITEMS aTel SIZE 171 , 40 Font oDlg:oFont
			DEFINE SBUTTON FROM 055,137 TYPE 1 ACTION (nOpbaixa := 1,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 055,164 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
			
			ACTIVATE MSDIALOG oDlg CENTERED
			If nOpBaixa == 1
				nCanRep := Ascan(aTel,PADR(cListBox,nTN))
			Endif
			
			If nOpBaixa == 0
				lRet := .F.
			Endif
		Endif
		
		If lRet
			DbSelectArea("SEU")
			If lPadrao57E .And. lGeraLanc
				If nHdlPrv <= 0
					LoteCont("FIN")
					//Inicializa Lancamento Contabil
					nHdlPrv := HeadProva( cLote,"FINA550" /*cPrograma*/,Substr( cUsuario, 7, 6 ),@cArquivo )
				Endif
			EndIf
	
			If Len(aTel) > 0 //Se for somente uma Reposição, apresenta tela para ser cancelada.
			 	if Empty(nCanRep)
			 		cNumero := aEstor[1][1]	
			 		nValor := aEstor[1][2]
			 		cBanco := aEstor[1][5]
			 		cAgen := aEstor[1][6]
			 		cConta := aEstor[1][7]
			 		cCheque := aEstor[1][8]
			 		dDtDigit := aEstor[1][4]
			 	Else	
			 		cNumero := aEstor[nCanRep][1]	
			 		nValor := aEstor[nCanRep][2]
			 		cBanco := aEstor[nCanRep][5]
			 		cAgen := aEstor[nCanRep][6]
			 		cConta := aEstor[nCanRep][7]
			 		cCheque := aEstor[nCanRep][8]
			 		dDtDigit := aEstor[nCanRep][4]
					If nCanRep > 1
						dDtUltRep	:= STOD(aEstor[nCanRep-1][4])
					EndIf 
			 	Endif	

				aAreaSEF := SEF->( GetArea() )
				If !Empty(cCheque)
					SEF->( DbSetOrder(1) )
					If SEF-> (!DbSeek(FWxFilial("SEF")+ cBanco + cAgen + cConta + cCheque ) )
						cCheque	:= ""
						lAchouSEF := .F.
					Else 
						lAchouSEF := .T.
						nRecSEF	:= SEF->(Recno())
					EndIf 					
				EndIf 

			 	cText := STR0110 + CRLF + CRLF
			 	cText += STR0111 + cNumero + CRLF
			 	cText += STR0112 + CVALTOCHAR(nValor) + CRLF
			 	if !Empty(cBanco)
			 		cText += STR0113 + cBanco + CRLF
			 		cText += STR0114 + cAgen + CRLF
			 		cText += STR0115 + cConta + CRLF
			 	Endif
			 	if !Empty(cCheque)
			 		cText+= STR0116 + cCheque + CRLF
			 	Endif	
			 	
				If lAutomato .OR. MSGYESNO(ctext,STR0117)
					IF STOD(dDtDigit) == dDataBase
						
						If lAchouSEF .and. cLiberado == "N"  .And.  SEF->EF_LIBER = "S" //Verifica se o Cheque já foi liberado
							lRet := .F.							
						Endif						
					
						IF SET->ET_SALDO >= nValor .and. lRet
						
							Begin Transaction
														
								//Criar o movimento de Estorno
								If!Empty(cBanco)
									aadd(aBco,cBanco)
									aadd(aBco,cAgen)
									aadd(aBco,cConta)
								Endif
								
								//Retorna o Saldo da Reposição para diferenciar
								DbSelectArea("SEU")
								aAreaSEU := SEU->( GetArea() )
								SEU->( DbSetOrder(1) )
								If SEU->( DbSeek(xFilial("SEU") + cNumero) )
									RecLock("SEU",.F.)
									Replace EU_SLDADIA With nValor
									SEU->( MsUnlock() )
								Endif								
									 					
								Fa550Mov(cCaixa,"11",nValor,"Est. Reposicao" + CVALTOCHAR(cNumero),aBco,,,@nRegEst)
								
								//Alterar o saldo do caixinha
								AtuSalCxa(cCaixa, dDataBase , (nValor * -1) )
								Fa550SLCR(cCaixa,.T.,nValor,dDtUltRep)
																			
								If Empty(cCheque)
									//Alterar o saldo do Banco e cria registro na SE5
									FA550MvBco("E",nValor,STR0118,,cNumero,aBco)
								Else //Cancelar o Cheque
									If lAchouSEF
										SEF->(dbGoto(nRecSEF))
					 					RecLock("SEF",.F.)
										SEF->( dbDelete() )
										SEF->( MsUnlock() )
										If 	cLiberado == "S"
											FA550MvBco("E",nValor,STR0119,cCheque,cNumero,aBco)
										Endif
									Endif									
					 			Endif			 			
					 		End Transaction
				 			
							If nHdlPrv > 0 .and. lPadrao57E  .And. lGeraLanc 
							
								If nRegEst > 0
									SEU->(DbGoto(nRegEst))
								EndIf
								
								If lUsaFlag .And. !EMPTY(SEU->EU_NUM)  //Armazena em aFlagCTB para atualizar no modulo Contabil 
										aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
								Endif
								nTotal += DetProva( nHdlPrv, "57E" /*cPadrao*/,"FINA550" /*cPrograma*/,cLote,/*nLinha*/,/*lExecuta*/,/*cCriterio*/,/*lRateio*/,/*cChaveBusca*/,/*aCT5*/,/*lPosiciona*/,@aFlagCTB,/*aTabRecOri*/,/*aDadosProva*/ )				 

								If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
									cCodDiario := CTBAVerDia()
									AADD(aDiario,{"SEU",SEU->(recno()),cCodDiario,"EU_NODIA","EU_DIACTB"})
								Endif
								
								cA100Incl( cArquivo,nHdlPrv,3 /*nOpcx*/,cLote,lDigita,lAglutina /*lAglut*/,/*cOnLine*/,/*dData*/,/*dReproc*/,@aFlagCTB,/*aDadosProva*/,aDiario )
								aFlagCTB := {}  //Limpa o coteudo apos a efetivacao do lancamento
							
								If !lUsaflag .And. !Empty(SEU->EU_NUM)
									Reclock("SEU",.F.)
									Replace EU_LA	With "S"
									MsUnLock()
								EndIf
							EndIf
				 			
				 			MSGINFO(STR0120)
				 			RestArea( aAreaSEU )
				 			
						ELSE
							
							If lRet
								Alert(STR0121 +  CVALTOCHAR(aEstor[1][1]))
							Else
								Alert(STR0122 + CRLF + STR0111 + cCheque + CRLF + STR0123)
							Endif
							
						Endif
					Else
						Alert(STR0124)
					Endif
				Endif			
				RestArea(aAreaSEF)					 			
			EndIF
		Endif
	Endif

	RestArea( aAreaAnt )
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AtuSalCxa³ Autor ³ Totvs          	    ³ Data ³ 13/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Func„o para atualiza‡„o do saldo do caixinha				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtuSalCxa() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AtuSalCxa( cCaixa, dData, nValor, lIni, cFilFIJ ) 
Local aAreaFIJ	:= FIJ->( GetArea() )
Local lAppend	:= .T.
Local nSalIni	:= 0
Local cQuery	:= ""
Local cAliasQry	:= "" 
Default lIni 	:= .F. // Utilizado para forcar a gravação do valor no saldo.
Default cFilFIJ	:= xFilial( "FIJ" )

If Empty( cCaixa )
	Return
EndIf

DbSelectArea( "FIJ" )
FIJ->( DbSetOrder( 1 ) )	// "FIJ_FILIAL+DTOS(FIJ_DATA)+FIJ_CODCX"
// Consulte o saldo deste caixinha na data solicitada
If FIJ->( DbSeek( cFilFIJ + DtoS( dData ) + cCaixa ) )
	nSalIni	:= FIJ->FIJ_SALDO
	lAppend	:= .F.
ElseIf !lIni

	// Consulte o saldo deste caixinha anterior à data solicitada 
	cAliasQry := GetNextAlias()
	cQuery := " SELECT FIJ_FILIAL, FIJ_CODCX, FIJ_SALDO "
	cQuery += " FROM " + RetSqlName("FIJ") 
	cQuery += " WHERE FIJ_FILIAL = '" + cFilFIJ + "' AND FIJ_CODCX = '" + cCaixa + "' "
	cQuery += " AND FIJ_DATA = ( SELECT MAX(FIJ_DATA) FROM " + RetSqlName("FIJ") + " WHERE FIJ_FILIAL = '" + cFilFIJ +"' AND FIJ_CODCX = '" + cCaixa + "' "
	cQuery += " AND FIJ_DATA < '" + DtoS( dData ) + "' AND D_E_L_E_T_ = '' ) "
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry )
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If !(cAliasQry)->(EOF())
		nSalIni	:= (cAliasQry)->FIJ_SALDO
	EndIf
	(cAliasQry)->(dbCloseArea())
	FErase( ( cAliasQry ) + GetDBExtension() )
EndIf

// Atualize o saldo na data solicitada
RecLock( "FIJ", lAppend )
FIJ->FIJ_FILIAL := cFilFIJ
FIJ->FIJ_CODCX	:= cCaixa
FIJ->FIJ_DATA	:= dData
FIJ->FIJ_SALDO	:= ( nSalIni + nValor )
MsUnlock()

// Atualize o saldo do caixinha nas datas posteriores à data solicitada.
cQuery := " UPDATE "+ RetSQLName( "FIJ" )
If !lIni
	cQuery += " SET FIJ_SALDO = FIJ_SALDO + " + AllTrim(Str(nValor)) 
Else
	cQuery += " SET FIJ_SALDO = " + AllTrim(Str(nValor))
EndIf
cQuery += " WHERE "
cQuery += "FIJ_FILIAL = '" + cFilFIJ + "' AND "
cQuery += "FIJ_CODCX = '"  + cCaixa  + "' AND "
cQuery += "FIJ_DATA > '"   + DtoS( dData ) + "' AND "
cQuery += "D_E_L_E_T_ = ' ' "
TCSQLExec( cQuery )

RestArea( aAreaFIJ )     

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ºfA500TalaoºAutor  º Laura Medina       º Data º  04/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     º Validar a digitação do número do Talonário quando CH chequeº±±
±±º          º for próprio.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   º ExpL := fA500Talao()  				                      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametrosº 														      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       º FINA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA500Talao()
Local aSavArea 	:= GetArea()
//Local cNumTalao := &(ReadVar())
Local lRet      := .T.

cNumTalao	    := &(ReadVar())


dbselectArea("FRE")
FRE->(dbSetOrder(3)) // Filial + Banco + Agência + Conta + Talão                                       
If  !FRE->(dbSeek(xFilial("FRE")+cBanco+cAgencia+cConta+cNumTalao))		
		MsgAlert(STR0101 , STR0037 ) //"Talão de cheques não cadastrado."###"Atención" // 
		lRet := .F.
ElseIf (FRE->FRE_TIPO $ "1|2|4")   //1-Cheque comun; 2-Cheque Electronico; 4-Cheque diferido Electrónico
		MsgAlert( STR0102 , STR0037 ) // "Chequera no disponible"
		lRet := .F.		
Else
	If  FRE->FRE_STATUS = "2" .And. FRE->FRE_TIPO = "3"  //Cheque diferido
		If  ObtTalCHQ(cBanco,cAgencia,cConta,cNumTalao)
			cNumero := cNumCHQ
			cTipTalao := Lower(X3COMBO("FRE_TIPO",FRE->FRE_TIPO)) 
			lRet := .T.
		Else 
			MsgAlert( STR0102 , STR0037 ) // "Chequera no disponible"
			lRet := .F.	
		Endif
	Else
		MsgAlert( STR0102 , STR0037 ) // "Chequera no disponible"
		lRet := .F.	
	Endif
EndIf
         
RestArea(aSavArea)   
Return(lRet)     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ºfA500TalaoºAutor  º Laura Medina       º Data º  04/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     º Validar a digitação do número do Talonário quando CH chequeº±±
±±º          º for próprio.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Sintaxe   º ExpL := fA500Talao()  				                      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametrosº 														      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       º FINA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtTalCHQ(cBanco,cAgencia,cConta,cNumTalao,nOpc,nNCheque)

Local cQrySEF	:= ""
Local cTmpSEF	:= ""
Local nX        := 0
Local lRet      := .T. 
Default nOpc    := 1    
Default nNCheque:= 0

cTmpSEF := GetNextAlias()
cQrySEF	:= "Select EF_BANCO,EF_CONTA,EF_AGENCIA,EF_TALAO,EF_PREFIXO,EF_NUM,R_E_C_N_O_"
cQrySEF	+= " from " + RetSqlName("SEF") + " SEF"
cQrySEF += " where EF_FILIAL = '" + xFilial("SEF") + "'"
cQrySEF += " and EF_CART	= 'P'"
cQrySEF	+= " and EF_BANCO	= '" + cBanco + "'"
cQrySEF += " and EF_AGENCIA	= '" + cAgencia + "'"
cQrySEF += " and EF_CONTA 	= '" + cConta + "'"
cQrySEF += " and EF_TALAO 	= '" + cNumTalao + "'"
cQrySEF += " and EF_STATUS 	= '00' AND EF_LIBER = 'S'"
cQrySEF	+= " and D_E_L_E_T_ = ''" 
If  nOpc==2 //Buscar el cheque si esta disponible   
	cQrySEF	+= " and EF_NUM	= '" + nNCheque + "'"
Endif
cQrySEF += " order by EF_BANCO,EF_AGENCIA,EF_CONTA,EF_TALAO,EF_PREFIXO,EF_NUM"
cQrySEF	:= ChangeQuery(cQrySEF)
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQrySEF),cTmpSEF,.F.,.T.)
(cTmpSEF)->(dbGoTop())

nX := 0 
While !((cTmpSEF)->(EOF()))
	nX++
	If  !(nOpc==2)
		cNumCHQ := (cTmpSEF)->EF_NUM   
		cPreCHQ := (cTmpSEF)->EF_PREFIXO 
		nTalCHQ := (cTmpSEF)->R_E_C_N_O_    
		Exit
	Endif
	(cTmpSEF)->(dbSkip())
Enddo
dbSelectArea(cTmpSEF)
DbCloseArea()
If  nX==0 
	If  !(nOpc==2)
		MsgAlert(STR0103)  //"Não foi encontrado cheque disponivel para este pagamento!"
	Endif
	lRet:=.F.
Endif	

Return(lRet)


//Funcao para verifica se a moeda do Caixinha de Reposicao
//e a mesma do caixinha de abertura.
Static Function Vermoeda(nMoedacx, nMoedaRep)
Local lRet := .F.

If nMoedacx == nMoedaRep
	lRet := .T.
Else
	Alert("A moeda do caixa de reposicao, deve ser igual ao caixinha")
Endif

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Fa550SLCR()
Atualiza saldo da SET após o Estorno da reposição

@author Daniel Ferraz Lacerda
@since 27/12/2016
@version 11
@param nCaixa, Número do Caixinha a ser atualizado
@param lAtu, se o Saldo deve ou não ser atualizado
@param nValor, valor a ser reduzido do Saldo do Caixinha
@return lRet Boolean
/*/
//----------------------------------------------------------------------
Function Fa550SLCR(cCaixa,lAtu,nValor,dDtUltRep)
	Local aAreaSET := {}
	Local lOk := .F.

	DEFAULT dDtUltRep := CTOD("//")

	If lAtu
		DbSelectArea("SET")
		aAreaSET := SET->( GetArea() )
		SET->( DbSetOrder( 1 ) )
		If SET->( DbSeek( FWxFilial("SET") + cCaixa ) )
			RecLock( "SET", .F. )
			Replace ET_SALDO With ET_SALDO - nValor
			Replace ET_ULTREP	With dDtUltRep
			SET->( MsUnlock() )
			lOk := .T.
		Endif
		RestArea( aAreaSET )
	Endif
Return lOk

/*/{Protheus.doc} PosRecSE5
Função para posicionar a SE5 correspondente à reposição que será estornada,
com base na SEU posicionada

@param cModelo, modelo de dados que será carregado. 
FINM020  - Baixa a Pagar, FINM30 - Movimentação Bancária

@return lRet, Indica se conseguiu posicionar em algum registro de SE5

@author Pedro Alencar
@since 24/07/2017
@version P12.1.14
/*/
Static Function PosRecSE5(cModelo)
	Local lRet     := .F.
	Local cTmpFK5  := ""
	Local cTmpFKA  := ""
	Local cQuery   := ""
	Local cProcFKA := ""
	Local oObjMov  := Nil
	
	Default := "FINM030"
	
	cQuery := "SELECT FK5_IDMOV FROM " + RetSqlName("FK5") + " "
	cQuery += "WHERE FK5_FILIAL = '" + FWxFilial("FK5") + "' AND "
	cQuery += "FK5_DOC = '" + SEU->EU_NUM + "' AND "
	cQuery += "FK5_BANCO = '" + SEU->EU_BANCO + "' AND "
	cQuery += "FK5_AGENCI = '" + SEU->EU_AGENCI + "' AND "
	cQuery += "FK5_CONTA = '" + SEU->EU_CONTARE + "' AND "
	cQuery += "FK5_DATA = '" + DTOS(SEU->EU_DTDIGIT) + "' AND "
	cQuery += "FK5_TPDOC <> 'ES' AND D_E_L_E_T_ = ' ' "	
	
	cQuery  := ChangeQuery(cQuery)
	oObjMov := FWPreparedStatement():New(cQuery)
	cQuery  := oObjMov:GetFixQuery()
	cTmpFK5 := MpSysOpenQuery(cQuery)
	oObjMov := Nil	
	
	If (cTmpFK5)->(!Eof())
		SE5->( DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
		If !(lRet := SE5->(MsSeek(FWxFilial("SE5")+(cTmpFK5)->FK5_IDMOV)))
			cQuery := "SELECT FKA_IDPROC FROM " + RetSqlName("FKA") + " "
			cQuery += "WHERE FKA_IDORIG = '" + (cTmpFK5)->FK5_IDMOV + "' AND D_E_L_E_T_ = ' ' "
			
			cQuery  := ChangeQuery(cQuery)
			oObjMov := FWPreparedStatement():New(cQuery)
			cQuery  := oObjMov:GetFixQuery()
			cTmpFKA := MpSysOpenQuery(cQuery)
			oObjMov := Nil			
			
			If (cTmpFKA)->(!Eof())
				cProcFKA := (cTmpFKA)->FKA_IDPROC 
				(cTmpFKA)->(DbCloseArea())
				cTmpFKA := ""
				
				cQuery := "SELECT FKA_IDORIG FROM " + RetSqlName("FKA") + " "
				cQuery += "WHERE FKA_FILIAL = '" + FWxFilial("FKA") + "' AND "				
				cQuery += "FKA_IDPROC = '" + cProcFKA + "' AND "
				cQuery += "FKA_IDORIG <> '" + (cTmpFK5)->FK5_IDMOV + "' AND "
				cQuery += "D_E_L_E_T_ = ' '"
				
				cQuery  := ChangeQuery(cQuery)
				oObjMov := FWPreparedStatement():New(cQuery)
				cQuery  := oObjMov:GetFixQuery()
				cTmpFKA := MpSysOpenQuery(cQuery)
				oObjMov := Nil				
				
				While (cTmpFKA)->(!Eof())
					If (lRet := SE5->(MsSeek(FWxFilial("SE5")+(cTmpFKA)->FKA_IDORIG)))
						exit
					EndIf
					(cTmpFKA)->(DbSkip())
				EndDo
				
				(cTmpFKA)->(DbCloseArea())
				cTmpFKA := ""
			EndIf
			
			If !Empty(cTmpFKA)
				(cTmpFKA)->(DbCloseArea())
			EndIf
			
			If lRet .And. SE5->E5_TABORI == "FK2"
				cModelo := "FINM020"
			EndIf		
		EndIf
	Endif	
	
	(cTmpFK5)->(DbCloseArea())
Return lRet

//-------------------------------------------------------
/*/{Protheus.doc} F550IniArg
Inicializa a variavel de verificação de talão para ambientes Argentina
@author Karen Honda

@since 15/06/2020
@version P12
/*/
//-------------------------------------------------------
Static Function F550IniArg()
	If ValType(__lArgTal) == "U"
		__lArgTal := cPaisLoc == "ARG" .And. SEU->(FieldPos("EU_TALAO"))>0 
	EndIf
Return
