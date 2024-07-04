#INCLUDE "QIEA160.CH"
#include "PROTHEUS.CH"
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё QIEA160  Ё Autor Ё Vera Lucia S. Simoes  Ё Data Ё 06/11/97 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Programa Atualizacao de Classes de NC                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A160ICNC"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A160ICNC"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A160DCNC"  , 0 , 5, 3} }  // "Excluir"
                     
Return aRotina

// Function QIEA160(uFator)
Function QIEA160()

// uFator .t.: Fatores IQP
// uFator .f.: Classes de NC

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define o cabecalho da tela de atualizacoes                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cCadastro := OemToAnsi(STR0006)	// "Classes de NC"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Array contendo as Rotinas a executar do programa      Ё
//Ё ----------- Elementos contidos por dimensao ------------     Ё
//Ё 1. Nome a aparecer no cabecalho                              Ё
//Ё 2. Nome da Rotina associada                                  Ё
//Ё 3. Usado pela rotina                                         Ё
//Ё 4. Tipo de Transa┤└o a ser efetuada                          Ё
//Ё    1 - Pesquisa e Posiciona em um Banco de Dados             Ё
//Ё    2 - Simplesmente Mostra os Campos                         Ё
//Ё    3 - Inclui registros no Bancos de Dados                   Ё
//Ё    4 - Altera o registro corrente                            Ё
//Ё    5 - Remove o registro corrente do Banco de Dados          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aRotina := MenuDef()

dbSelectArea("QEE")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Endereca a funcao de BROWSE                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
mBrowse( 6, 1,22,75,"QEE")

Return .T.

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё A160DCNC Ё Autor Ё Vera Lucia S. Simoes  Ё Data Ё 06/11/97 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Programa Atualizacao Classes NC - Delecao                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё A160DCNC(ExpC1,ExpN1,ExpN2)                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 = Alias do arquivo                                   Ё╠╠
╠╠Ё          Ё ExpN1 = Numero do registro                                 Ё╠╠
╠╠Ё          Ё ExpN2 = Opcao selecionada                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё QIEA160                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
FUNCTION A160DCNC(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg, lAchou

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a entrada de dados do arquivo                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//здддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia para processamento dos Gets          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддды
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto ┘ exclus└o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2

		cCod := QEE->QEE_CLASSE

		If nModulo == 21	// SIGAQIE
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Antes de deletar verif. se e' util. em NCs dos Ensaios Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea('QE2')
			dbSetOrder(1)
			dbSeek(xFilial("QE2"))
			lAchou := .f.
			While QE2_FILIAL == xFilial("QE2") .and. ! eof()
				if QE2_CLASSE == cCod
					lAchou := .t.
					Exit
				endif
				dbSkip()
			Enddo
			if lAchou
				HELP(" ",1,"A160DCLENS",,QE2->QE2_ENSAIO,3,1)
				dbSelectArea(cAlias)
				Exit
			EndIf

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Antes de deletar verif. se e' util. em NCs dos Produtos Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea('QE9') 
			dbSetOrder(1)
			dbSeek(xFilial("QE9"))
			lAchou := .f.
			While QE9_FILIAL == xFilial("QE9") .and. ! eof()
				if QE9_CLASSE == cCod
					lAchou := .t.
					Exit
				endif
				dbSkip()
			Enddo
			if lAchou
				HELP(" ",1,"A160DCLPRO",,QE9->QE9_PRODUT+'-'+;
					QE9->QE9_REVI+'-'+QE9->QE9_ENSAIO,3,1)
				dbSelectArea(cAlias)
				Exit
			EndIf
	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Antes de deletar verif. se e' util. em NCs dos Resultados Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea('QEU') 
			dbSetOrder(1)
			dbSeek(xFilial("QEU"))
			lAchou := .f.
			While QEU_FILIAL == xFilial("QEU") .and. ! eof()
				if QEU_CLASSE == cCod
					lAchou := .t.
					Exit
				endif
				dbSkip()
			Enddo
			if lAchou
				HELP(" ",1,"A160DCLRES")
				dbSelectArea(cAlias)
				Exit
			EndIf
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Antes de deletar verif. se e' util. em cadastro de NCs Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea('SAG') 
		dbSetOrder(1)
		dbSeek(xFilial("SAG"))
		lAchou := .f.
		While AG_FILIAL == xFilial("SAG") .and. ! eof()
			if AG_CLASSE == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo
		if lAchou
			HELP(" ",1,"A160DCLNCS",,SAG->AG_NAOCON,3,1)
			dbSelectArea(cAlias)
			Exit
		EndIf

		Begin Transaction

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Apos passar por todas as verificacoes , deleta o registro    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
	
		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
//dbSeek(uCodTab)
return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё A160ICNC Ё Autor Ё Vera Lucia S. Simoes  Ё Data Ё 06/11/97 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Programa Atualizacao Classes NC - Inclusao/Alteracao       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё A160ICNC(ExpC1,ExpN1,ExpN2)                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 = Alias do arquivo                                   Ё╠╠
╠╠Ё          Ё ExpN1 = Numero do registro                                 Ё╠╠
╠╠Ё          Ё ExpN2 = Opcao selecionada                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё QIEA160                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
FUNCTION A160ICNC(cAlias,nReg,nOpc)
LOCAL nOpcA:=0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a entrada de dados do arquivo                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0],aGETS[0]

While .T.

	//здддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia para processamento dos Gets          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддды
	nOpcA:=0

	Begin Transaction

		if nOpc == 3  // Inclusao
			nOpcA:=AxInclui( cAlias, nReg, nOpc)

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif
	
	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
return
