#INCLUDE "PCOA101.ch"
#INCLUDE "PROTHEUS.CH"

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±?
±±³FUNCAO    ?PCOA101  ?AUTOR ?Edson Maricate        ?DATA ?10-12-2003 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³DESCRICAO ?Programa de manutecao dos CO da planilha orcamentaria        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?USO      ?SIGAPCO                                                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³_DOCUMEN_ ?PCOA101                                                      ³±?
±±³_DESCRI_  ?Programa de manutecao dos CO da planilha orcamentaria        ³±?
±±³_FUNC_    ?Esta funcao podera ser utilizada com a sua chamada normal a  ³±?
±±?         ?partir do Menu ou a partir de uma funcao pulando assim o     ³±?
±±?         ?browse principal e executando a chamada direta da rotina     ³±?
±±?         ?selecionada.                                                 ³±?
±±?         ?Exemplos: PCOA101(2) - Executa a chamada da funcao de visua- ³±?
±±?         ?                       zacao da rotina.                      ³±?
±±?         ?          PCOA101()  - Executa a chamada da funcao pela      ³±?
±±?         ?                       mBrowse.                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³_PARAMETR_?ExpN1 : Chamada direta sem passar pela mBrowse               ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function PCOA101(nCallOpcx,aGetCpos,cNivelCO, l101Auto)
Local nRecAK3

Default l101Auto := .F. //Rotina Automática ?

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Salva a interface.                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
SaveInter()

PRIVATE cCadastro	:= STR0001 //"Planilha Orcamentaria - Contas Orcamentarias"
Private aRotina := MenuDef()
PRIVATE aMemos := {{"AK3_CODMEM","AK3_OBS"}}

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If (l101Auto)
		cNivelCO	:= Soma1(cNivelCO)
		nRecAK3		:= Pco101Dlg("AK3",AK3->(RecNo()),nCallOpcx,,,aGetCpos,cNivelCO, l101Auto)
	Else
		If nCallOpcx == Nil
			mBrowse(6,1,22,75,"AK3")
		Else
			cNivelCO	:= Soma1(cNivelCO)
			nRecAK3		:= Pco101Dlg("AK3",AK3->(RecNo()),nCallOpcx,,,aGetCpos,cNivelCO)
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Restaura a interface.                                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
RestInter()
Return nRecAK3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ³Pco101Dlg?Autor ?Edson Maricate         ?Data ?09-02-2001 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±?
±±?         ?de Tarefas de Projetos                                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?Generico                                                     ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function Pco101Dlg(cAlias,nReg,nOpcx,xReserv,yReserv,aGetCpos,cNivelCO, l101Auto)

Local l101Inclui	:= .F.
Local l101Visual	:= .F.
Local l101Altera	:= .F.
Local l101Exclui	:= .F.
Local lContinua		:= .T.

Local oDlg

Local nRecAK3
Local nOpc			:= 0
Local nX			:= 0

Local aCampos		:= {}
Local aSize			:= {}
Local aObjects		:= {}
Local aButtons      := {}
Local aEnchAuto     := {} //Array de Campos da Enchoice Automática

Default l101Auto := .F. //Rotina Automática ?

PRIVATE oEnch

DEFAULT cNivelCO := "001"

If nOpcx == 6  //Inclusao C.O./lOTE
	Pco101Lote( aGetCpos, cNivelCO )  //Rotina para inclusao em lote de todas as contas orçamentarias informadas
	nRecAK3 := AK3->( Recno() )
	lContinua := .F.  //para nao entrar em Incluir/Alterar/Excluir
EndIf

If lContinua

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	Do Case
		Case aRotina[nOpcx][4] == 2
			l101Visual := .T.
			Inclui := .F.
			Altera := .F.
		Case aRotina[nOpcx][4] == 3
			l101Inclui	:= .T.
			Inclui := .T.
			Altera := .F.
		Case aRotina[nOpcx][4] == 4
			l101Altera	:= .T.
			Inclui := .F.
			Altera := .T.
		Case aRotina[nOpcx][4] == 5
			l101Exclui	:= .T.
			l101Visual	:= .F.
	EndCase


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Trava o registro do AK3 - Alteracao,Visualizacao       ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l101Altera.Or.l101Exclui
		If !SoftLock("AK3")
			lContinua := .F.
		Else
			nRecAK3 := AK3->(RecNo())
		Endif
	EndIf

EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Carrega as variaveis de memoria AK3                          ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("AK3",l101Inclui)
	If l101Inclui
		M->AK3_NIVEL := cNivelCO
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Tratamento do array aGetCpos com os campos Inicializados do AK3    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aGetCpos <> Nil
		aCampos	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AK3")
		While !Eof() .and. SX3->X3_ARQUIVO == "AK3"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If nPosCpo > 0
					If aGetCpos[nPosCpo][3]
						aAdd(aCampos,AllTrim(X3_CAMPO))
					EndIf
				Else
					aAdd(aCampos,AllTrim(X3_CAMPO))
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf

	If (l101Auto)
		nOpc := 01
		//Compondo Array de EnchAuto
		For nX := 1 To Len(aGetCpos)
			AAdd(aEnchAuto, {aGetCpos[nX, 01], aGetCpos[nX, 02], Nil})
		Next nX
		lContinua := EnchAuto("AK3", aEnchAuto, "AllwaysTrue()", IIf(l101Inclui, 03, IIf(l101Altera, 04, 05)))
		nOpc := IIf(lContinua, 01, 0)
	Else
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd

		oEnch := MsMGet():New("AK3",AK3->(RecNo()),nOpcx,,,,,{,,(oDlg:nClientHeight - 4)/2,},If(Empty(aCampos),NIL,aCampos),3,,,,oDlg)
		oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Adiciona botoes do usuario no Browse                                   ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "PCOA1012" )
			//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//P_E?Ponto de entrada utilizado para inclusao de botoes de usuario na toolbar?
			//P_E?da tela de itens do orcamento.                                          ?
			//P_E?Parametros : Nenhum                                                     ?
			//P_E?Retorno    : Array contendo as rotinas a serem adicionados na toolbar   ?
			//P_E?              Ex. :  User Function PCOA1012                             ?
			//P_E?                     Return {{"Titulo", {|| U_Teste() } }}              ?
			//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			aButtons:= ExecBlock("PCOA1012",.F.,.F.)
		EndIf

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(l101Visual, oDlg:End(),If(A101Conf(nOpcx).And.Obrigatorio(oEnch:aGets,oEnch:aTela).And.oGD[1]:TudoOk(),(nOpc:=1,oDlg:End()),Nil))},{||oDlg:End()},,aButtons)
	EndIf
EndIf

If lContinua

	If (nOpc == 1) .And. (l101Inclui .Or. l101Altera .Or. l101Exclui)

		PcoIniLan('000252')

		Begin Transaction
			PCO101Grava(l101Altera,l101Exclui,@nRecAK3)
		End Transaction

		PcoFinLan('000252')

	EndIf

EndIf

Return nRecAK3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ³PCO101Grava?Autor ?Edson Maricate       ?Data ?15-12-2003 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³Faz a gravacao da C.O.                                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ³PCOA101                                                       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function PCO101Grava(lAltera,lDeleta,nRecAK3)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0

If !lDeleta
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Grava o arquivo AK3                                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAltera
		AK3->(dbGoto(nRecAK3))
		RecLock("AK3",.F.)
	Else
		RecLock("AK3",.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	AK3->AK3_FILIAL := xFilial("AK3")
	MsUnlock()
	nRecAK3	:= AK3->(RecNo())

Else
	AK3->(dbGoto(nRecAK3))

	A101ExclDepend(AK3->AK3_ORCAME, AK3->AK3_VERSAO, AK3->AK3_CO)

EndIf

Return


Static Function A101ExclDepend(cPlanilha, cVersao, cContaOrc)
Local nRecAK3 := AK3->(Recno())

	//Excluir primeiro os itens orcamentarios
	//exclui a ITENS da conta orcamentaria
	dbSelectArea("AK2")
	dbSetOrder(1)

	If dbSeek(xFilial("AK2")+cPlanilha+cVersao+cContaOrc)

		While AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == ;
										xFilial("AK2")+cPlanilha+cVersao+cContaOrc)

			PcoDetLan("000252","01","PCOA100", .T. )

		    If ExistBlock("PCOA1013")
			 ExecBlock("PCOA1013",.F.,.F.)
			EndIf

			RecLock("AK2",.F.,.T.)
			dbDelete()
			MsUnlock()
			AK2->(dbSkip())
		End

   EndIf

 	//procura proximo registro cujo pai eh o q acabou de ser pesquisado
 	dbSelectArea("AK3")
 	dbSetOrder(2) //ORDEM: AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI
 	dbGoto(nRecAK3)
 	While dbSeek(xFilial("AK3")+cPlanilha+cVersao+AK3->AK3_CO)
 		A101ExclDepend(AK3->AK3_ORCAME, AK3->AK3_VERSAO, AK3->AK3_CO)
	 	dbGoto(nRecAK3)
	End

	AK3->(dbGoto(nRecAK3))
	RecLock("AK3",.F.,.T.)
	dbDelete()
	MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³A101Conf  ºAutor  ³Paulo Carnelossi    ?Data ? 12/05/06   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Aviso de confirmacao da exclusao                            º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?AP                                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/

Static Function A101Conf(nOpcx)
Local lRet := .T.
If nOpcx == 5   //Exclusao - Solicita Confirmacao com Aviso que vai excluir os itens orcamentarios
	If Aviso(STR0008,STR0009, {STR0006, STR0010},2)==2 //"Atencao"##"Ao excluir a conta orcamentaria os itens e os movimentos gerados serao excluidos. Confirma exclusão da conta orcamentaria ?"##"Excluir"##"Cancelar"
		lRet := .F.
	EndIf
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Programa  ³MenuDef   ?Autor ?Ana Paula N. Silva     ?Data ?7/11/06 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Utilizacao de menu Funcional                               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Retorno   ³Array com opcoes da rotina.                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros³Parametros do array a Rotina:                               ³±?
±±?         ?. Nome a aparecer no cabecalho                             ³±?
±±?         ?. Nome da Rotina associada                                 ³±?
±±?         ?. Reservado                                                ³±?
±±?         ?. Tipo de Transa‡„o a ser efetuada:                        ³±?
±±?         ?	1 - Pesquisa e Posiciona em um Banco de Dados         ³±?
±±?         ?   2 - Simplesmente Mostra os Campos                       ³±?
±±?         ?   3 - Inclui registros no Bancos de Dados                 ³±?
±±?         ?   4 - Altera o registro corrente                          ³±?
±±?         ?   5 - Remove o registro corrente do Banco de Dados        ³±?
±±?         ?. Nivel de acesso                                          ³±?
±±?         ?. Habilita Menu Funcional                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?  DATA   ?Programador   ³Manutencao efetuada                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?         ?              ?                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1},;  //"Pesquisar"
							{ STR0003, "PCO101Dlg", 0 , 2},;  //"Visualizar"
							{ STR0004, "PCO101Dlg", 0 , 3 },;  //"Incluir"
							{ STR0005, "PCO101Dlg", 0 , 4 },;  //"Alterar"
							{ STR0006, "PCO101Dlg", 0 , 5 },;  //"Excluir"
							{ STR0007, "MSDOCUMENT",0,4 }}  //"Conhecimento"
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Adiciona botoes do usuario no Browse                                   ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1011" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E?Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ?
		//P_E?browse da tela de orcamentos                                           ?
		//P_E?Parametros : Nenhum                                                    ?
		//P_E?Retorno    : Array contendo as rotinas a serem adicionados na enchoice ?
		//P_E?              Ex. :  User Function PCOA1011                            ?
		//P_E?                     Return {{"Titulo", {|| U_Teste() } }}             ?
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1011", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³Ver_CtaSupºAutor  ³Paulo Carnelossi    ?Data ? 04/03/05   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Valida Conta digitada para compatiblizar com plano de Ctas º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?AP                                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function _VerCtaSup(cNivel, cContaOrc, cContaSup)
Local cAliasAnt := Alias()
Local aArea := GetArea()
Local aAreaAK5 := AK5->(GetArea())
Local lRet := .F.
Local nNivel
Local bValNivel
Local lTreeConta := .F.
Local cVar := ReadVar()

nNivel := Val(cNivel)

If nNivel == 2
	bValNivel := {||Empty(AK5->AK5_COSUP) }
ElseIf nNivel > 2
	bValNivel := {||!Empty(AK5->AK5_COSUP) .And. AK5->AK5_COSUP == cContaSup}
EndIf

//somente valida quando cNivel for maior que o primeiro nivel
//pois o primeiro e a propria cabeca da planilha
//o segundo nivel recebe sempre como conta superior a propria cabeca da pln

If nNivel > 1
	dbSelectArea("AK5")
	dbSetOrder(1)
	If dbSeek(xFilial("AK5")+cContaOrc)
		If Eval(bValNivel)
			lRet := .T.
		Else
			If Aviso(STR0011,STR0012, {STR0013, STR0014} ) == 1  //"Conta Superior Invalida."###"Atencao. Exibe Arvore para cadastrar o conjunto de contas ?"##"Sim"##"Nao"
				lTreeConta := .T.
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

If lTreeConta
	If PcoAssistCtaOrc(cContaOrc, .T.)
		Aviso(STR0008, STR0015, {"Ok"}) //"Atencao"###"Conta Orcamentaria incluida na planilha. "##
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaAK5)
dbSelectArea(cAliasAnt)

__READVAR := cVar

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³VPLANCTO  ºAutor  ³Alexandre Circenis  ?Data ? 04/09/14   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Valida  se o codigo da Planilha est?cadastro com  conta   º±?
±±?         ?Orcamentaria                                               º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?AP                                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function VPLANCTO()
Local aArea := GetArea()
Local cVar := ReadVar()
Local lRet := .T.

dbSelectArea("AK5")
dbSetOrder(1)
if dbSeek(xFilial("AK5")+&cVar)
	Help("  ",1,"VPLANCTO",,STR0016,1,0)
	lRet := .F.
endif

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³VAK3_CO   ºAutor  ³Alexandre Circenis  ?Data ? 04/09/14   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Valida  se o codigo da Conta Orcamentaria                  º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?AP                                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/


Function VAK3_CO()
Local lRet := .T.
Local aArea := GetArea()
Local cVar	:= ReadVar()

if dbSeek(xFilial("AK1")+&cVar)
	Help("  ",1,"VAK3AK1",,STR0017,1,0)
	lRet := .F.
else
	lRet := Existchav("AK3",M->AK3_ORCAME+M->AK3_VERSAO+M->AK3_CO)
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Pco101Lote
Incluir conta orçamentaria na estrutura de todas as contas informadas no parametro

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------

Function Pco101Lote( aGetCpos, cNivelCO )
Local cAliasTrb := ""
Local lRet  := .T.
Local aStructCta := {}
Local cCtOrcDe := Space(Len(AK5->AK5_CODIGO))
Local cCtOrcAte := Repl( 'z', Len(AK5->AK5_CODIGO))
Local nCsdBloq := 1

If Pco101X1( "PCO101", @cCtOrcDe, @cCtOrcAte, @nCsdBloq )  //Pergunte( "PCO101", .T. ) 

	//query para levantar todas as contas informadas no pergunte
	cAliasTrb := CriaTrab(,.F.)
	Pco101Qry( cAliasTrb, cCtOrcDe, cCtOrcAte, nCsdBloq == 1 )

	//laço para montar arvore de acordo com retorno da query
	If Pco101Tree(cAliasTrb, aStructCta)  //caso confirma a tela retorna .T. senao retorna .F.
		Pco101Proc(cAliasTrb, aStructCta)
	Else
		lRet := .F.
	EndIf

Else

	lRet := .F.

EndIf

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} Pco101Qry
Query para listar todos as contas orçamentarias analiticas
Recebe o nome do alias 

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Pco101Qry(cAliasTrb, cContaIni, cContaFim, lCOBloq)
Local cQuery := ""

cQuery	:=	" SELECT AK5_CODIGO, AK5_COSUP, AK5_DESCRI, R_E_C_N_O_ RECAK5 FROM "+RetSqlName('AK5')+" AK5 "
cQuery	+=	" WHERE AK5_FILIAL='"+xFilial('AK5')+"' "
cQuery	+=	" AND AK5_CODIGO BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' "
cQuery	+=	" AND AK5_TIPO = '2' " //ANALITICAS

If !lCOBloq
	cQuery	+=	" AND AK5_MSBLQL = '2' " //SOMENTE NAO BLOQUEADAS
EndIf

cQuery	+=	" AND D_E_L_E_T_= ' ' "
cQuery	+=	" ORDER BY AK5_COSUP, AK5_CODIGO "

cQuery	:=	ChangeQuery(cQuery)

dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),cAliasTrb, .F., .F. )

Return(cQuery)

//-------------------------------------------------------------------
/*/{Protheus.doc} Pco101Tree
Monta Arvore e exibe na tela com botao para confirmar processaento
Recebe o alias da query 
@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Pco101Tree(cAliasTrb, aStructCta)
Local oDlg
Local oFont

Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10
Local aButtons := {}

Local aArea:=GetArea()
Local aAreaAK5:=AK5->(GetArea())

Local oTree
Local oPanel

Local lRet := .F.


Local nNivAtu := 2
Local aNivAtu := {}

Local nX := 0
Local cOldCtaSup := ""
Local aNosAbertos
Local nPos_Niv

Local aProxNos := {}
Local lFechaNos := .F.

Default aStructCta := {}


DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE STR0021 OF oMainWnd PIXEL FROM nTop, nLeft TO nBottom, nRight  

oPanel := TScrollBox():New( oDlg, 005, 005, oDlg:nClientHeight,oDlg:nClientWidth,.T.,.T.,.T.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

//------------------------------------------------------------------------------------------//
//CRIACAO DA ARVORE
//------------------------------------------------------------------------------------------//
oTree:= Xtree():New(005,005,oPanel:nClientHeight/3+200,oPanel:nClientWidth/2-10,oPanel)

oTree:BeginUpdate()
oTree:Reset()

//adiciona primeiro node com AK3
Pco101AddTree( oTree, Alltrim(AK3->AK3_CO)+"-"+Alltrim(AK3->AK3_DESCRI), "AK3ROOT", .T.)
aAdd(aStructCta, { AK3->AK3_CO, AK3->AK3_DESCRI, "AK3ROOT", AK3->AK3_CO, 2 })

aNosAbertos := {}
//laco para pendurar todas as contas no tree
While (cAliasTrb)->(! Eof() )

	nNivAtu := 2
	
	cOldCtaSup := (cAliasTrb)->AK5_COSUP
	While (cAliasTrb)->(! Eof() .And. AK5_COSUP == cOldCtaSup )

		PcoCtaOrcAdd( oTree, (cAliasTrb)->AK5_CODIGO, (cAliasTrb)->AK5_COSUP, @nNivAtu, aNivAtu, (cAliasTrb)->AK5_DESCRI, aStructCta, aNosAbertos )

		(cAliasTrb)->( dbSkip() )
	
	EndDo

	aProxNos := {}
	PCOA101Sup((cAliasTrb)->AK5_CODIGO, (cAliasTrb)->AK5_COSUP, aProxNos)

	lFechaNos := PCOA101CMP( aProxNos, aNosAbertos, aNivAtu, oTree)

	If lFechaNos .OR. (cAliasTrb)->( Eof() )
		For nX := 1 TO Len(aNosAbertos)
			nPos_Niv := aScan( aNivAtu, {|x| x[1] == aNosAbertos[nX] } )
			If nPos_Niv > 0 .And. ! aNivAtu[nPos_Niv, 3]
				oTree:EndTree()
				aNivAtu[nPos_Niv, 3] := .T.
			EndIf
		Next
		aNosAbertos := {}
	EndIf

EndDo

oTree:EndTree()

oTree:EndUpdate()
oTree:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lRet := .T.,oDlg:End()},{||lRet := .F., oDlg:End()},, aButtons )
 
RestArea(aAreaAK5)
RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Pco101Proc
Processamento para Incluir conta orçamentaria na estrutura (AK3) de todas as contas informadas no parametro
Recebe o alias da query 

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function Pco101Proc(cAliasTrb, aStructCta)

PCOGrvStru(aStructCta)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA101Sup
Adiciona ao array aProxNos as contas superioress   

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PCOA101Sup( cCtaOrc, cCtaSup, aProxNos )
Local aArea := GetArea()
Local aAreaAK5 := AK5->( GetArea() )

If !Empty(cCtaSup)

	dbSelectArea("AK5")
	dbSetOrder(1)
	MsSeek(xFilial()+cCtaSup)

	While AK5->( !Eof() .And. AK5_FILIAL+AK5->AK5_CODIGO==xFilial("AK5")+cCtaSup )

		PCOA101Sup( AK5->AK5_CODIGO, AK5->AK5_COSUP, aProxNos )

		If !Empty( AK5->AK5_CODIGO )
			aAdd( aProxNos, "AK5"+AK5->AK5_CODIGO )
		EndIf

		AK5->( dbSkip() )

	EndDo

EndIf

RestArea( aAreaAK5 )
RestArea( aArea )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA101Cmp
Verifica se nivel superior esta contido no array aNosAbertos   
Comparando aProxNos com aNosAbertos

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PCOA101CMP( aProxNos, aNosAbertos, aNivAtu, oTree)
	Local lRet := .T.
	Local nX := 0
	Local nY := 0
	Local nPosElem := 0
	Local nPos_Niv := 0
	Local nLenAberto := 0

	If Len(aProxNos)!=0

		If Len(aNosAbertos)!=0

			For nX := 1 TO Len(aProxNos)

				nPosElem := aScan( aNosAbertos, aProxNos[nX] )

				If nPosElem > 0 //primeiro node comum que encontrar sai fora do laco
					lRet := .F.
					Exit
				EndIf
			Next

			If !lRet
				//se entrou aqui eh pq algum node foi encontrado
				If Len(aProxNos) <= Len(aNosAbertos)  //se tamanho do array aProxNos menor ou igual a array aNosAbertos

					For nX := 1 TO Len(aProxNos)

						If aProxNos[nX] != aNosAbertos[nX]  //se for diferente dai em diante tem que fechar o tree

							nLenAberto := Len(aNosAbertos)
							For nY := nLenAberto TO nX STEP -1

								nPos_Niv := aScan( aNivAtu, {|x| x[1] == aNosAbertos[nY] } )
								If nPos_Niv > 0 .And. ! aNivAtu[nPos_Niv, 3]
									oTree:EndTree()
									aNivAtu[nPos_Niv, 3] := .T.
								EndIf

							Next
							aSize( aNosAbertos, nX-1 )
							Exit

						EndIf

					Next

				Else

					For nX := 1 TO Len(aProxNos)

						If nX <= Len(aNosAbertos) .And. aProxNos[nX] != aNosAbertos[nX]  //se for diferente dai em diante tem que fechar o tree

							nLenAberto := Len(aNosAbertos)
							For nY := nLenAberto TO nX STEP -1

								nPos_Niv := aScan( aNivAtu, {|x| x[1] == aNosAbertos[nY] } )
								If nPos_Niv > 0 .And. ! aNivAtu[nPos_Niv, 3]
									oTree:EndTree()
									aNivAtu[nPos_Niv, 3] := .T.
								EndIf

							Next
							aSize( aNosAbertos, nX-1 )
							Exit

						EndIf

					Next


				EndIf

			EndIf
		
		Else

			lRet := .F.

		EndIf
	
	Else
	
		lRet := .F.
	
	EndIf

	Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Pco101AddTree
Adiciona item a Arvore 
se superior com AddTree
se analitica com AddTreeItem  

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function Pco101AddTree( oTree, cDescNode, cIdCargo, lNoPrincipal )
default lNoPrincipal := .F.

If lNoPrincipal
	oTree:AddTree(cDescNode,"folder5.png","folder6.png",cIdCargo,/*bAction*/,/*bRClick*/,/*bDblClick*/)
Else
	oTree:AddTreeItem(cDescNode,"folder5.png",cIdCargo,/*bAction*/,/*bRClick*/,/*bDblClick*/)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PcoCtaOrcAdd
sobe todos os niveis da conta passada para adicionar item a Arvore   

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PcoCtaOrcAdd( oTree, cCtaOrc, cCtaSup, nNivAtu, aNivAtu, cDescri, aStructCta, aNosAbertos)
Local cCtaTree := ""
Local cCargoAux := ""


//SOBE DA ANALITICA ATE A PRIMEIRA SINTETICA(raiz)
cCtaTree := PcoCtaAuxOrc( oTree, cCtaOrc, cCtaSup, @nNivAtu, aNivAtu, aStructCta, aNosAbertos)

//pendura no nivel superior
If Empty(cCtaTree)  //se retorno nao posicionou em superior pendura no node principal
	oTree:TreeSeek("AK3ROOT")
	cCargoAux := oTree:GetCargo()
Else
	oTree:TreeSeek("AK5"+cCtaTree)  //se encontrou pendura no node imediatamente superior
	cCargoAux := oTree:GetCargo()
EndIf

//Adiciona o no filtrado na query - Contas analiticas 
Pco101AddTree( oTree, Alltrim( cCtaOrc) + " - " + Alltrim( cDescri), "AK5"+ cCtaOrc, .F. )
aAdd(aStructCta, { cCtaOrc, cDescri, "AK5"+ cCtaOrc, cCargoAux, nNivAtu })

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} PcoCtaAuxOrc
Adiciona item a Arvore - NOS SUPERIORES  
retorna a conta superior posicionada

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PcoCtaAuxOrc( oTree, cCtaOrc, cCtaSup, nNivAtu, aNivAtu, aStructCta, aNosAbertos)
Local aAreaAK5 := AK5->(GetArea())
Local cCtaTree := ""
Local lAdItem := .F.
Local cCargoAux := ""
Local nPosNiv := 0

dbSelectArea("AK5")
dbSetOrder(1)
MsSeek(xFilial()+cCtaSup)

While AK5->( !Eof() .And. AK5_FILIAL+AK5->AK5_CODIGO==xFilial("AK5")+cCtaSup )

	lAdItem := .T.
	cCtaTree := AK5->AK5_CODIGO

	If oTree:TreeSeek("AK5"+AK5->AK5_CODIGO)
		nPosNiv := aScan( aNivAtu, {|x| x[1] == "AK5"+AK5->AK5_CODIGO } )
		nNivAtu := aNivAtu[ nPosNiv,2 ]
		nNivAtu++
		lAdItem := .F.
		Exit
	EndIf 
		
	If !Empty(AK5->AK5_COSUP)

		PcoCtaAuxOrc( oTree, AK5->AK5_CODIGO, AK5->AK5_COSUP, @nNivAtu, aNivAtu, aStructCta, aNosAbertos)
		//POSICIONA PARA PENDURAR NO NIVEL SUPERIOR
		oTree:TreeSeek("AK5"+AK5->AK5_COSUP)
		cCargoAux := oTree:GetCargo()
		Pco101AddTree( oTree, Alltrim(AK5->AK5_CODIGO) + " - " + Alltrim(AK5->AK5_DESCRI), "AK5"+AK5->AK5_CODIGO, .T. )
		
		aAdd(aStructCta, { AK5->AK5_CODIGO, AK5->AK5_DESCRI, "AK5"+AK5->AK5_CODIGO,cCargoAux, nNivAtu })
		aAdd( aNivAtu, { "AK5"+AK5->AK5_CODIGO, nNivAtu, .F.})
		aAdd( aNosAbertos, "AK5"+AK5->AK5_CODIGO)

	Else		//POSICIONA PARA PENDURAR NO NIVEL SUPERIOR

		oTree:TreeSeek("AK3ROOT")
		cCargoAux := oTree:GetCargo()

		Pco101AddTree( oTree, Alltrim(AK5->AK5_CODIGO) + " - " + Alltrim(AK5->AK5_DESCRI), "AK5"+AK5->AK5_CODIGO, .T. )
		
		aAdd(aStructCta, { AK5->AK5_CODIGO, AK5->AK5_DESCRI, "AK5"+AK5->AK5_CODIGO,cCargoAux, nNivAtu })
		aAdd( aNivAtu, { "AK5"+AK5->AK5_CODIGO, nNivAtu, .F.})
		aAdd( aNosAbertos, "AK5"+AK5->AK5_CODIGO)

		Exit

	EndIf

	AK5->( dbSkip() )

EndDo

If lAdItem
	nNivAtu++
EndIf

RestArea(aAreaAK5)

Return cCtaTree


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOGrvStru
Grava estrutura da planilha (AK3)   

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PCOGrvStru(aStructCta)
Local nX
Local lRet	:= .T.

	If (lRet := Aviso(STR0022, STR0023,{STR0013, STR0014},2) == 1) //"Confirma inclusão ?"###"Confirma a inclusao das contas selecionadas na planilha orçamentaria ?"###"Sim"###"Nao"

		dbSelectArea("AK3")
		dbSetOrder(1)
		For nX := 2 TO Len(aStructCta)
			If ! dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+aStructCta[nX][1])
				RecLock("AK3", .T.)
				AK3_FILIAL := xFilial("AK3")
				AK3_ORCAME := AK1->AK1_CODIGO
				AK3_VERSAO := cRevisa
				AK3_CO := aStructCta[nX][1]
				If aStructCta[nX][4] == "AK3ROOT"
					AK3_PAI := AK1->AK1_CODIGO 
				Else
					AK3_PAI := Subs( aStructCta[nX][4], 4 )  //primeiro 3 posicoes AK3 OU AK5
				EndIf
		  		AK5->( dbSeek( xFilial("AK5")+aStructCta[nX][1] ) )
				AK3_TIPO := AK5->AK5_TIPO
				AK3_NIVEL := StrZero( aStructCta[nX][5], Len(AK3->AK3_NIVEL))
				AK3_DESCRI := AK5->AK5_DESCRI
				MsUnLock()
			EndIf
		Next

	EndIf


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Pco101X1
Pco101X1 - Pergunte da rotina para inclusao contas orcamentarias em lote  

@author TOTVS
@since 24/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Pco101X1(cPerg, cCtOrcDe, cCtOrcAte, nCsdBloq)

Local lRet := .F.

Local aParamPerg := {}
Local aParamResp := {}

Local oObjPerg
Local aPergunte

oObjPerg := FWSX1Util():New()
oObjPerg:AddGroup(cPerg)

oObjPerg:SearchGroup()
aPergunte := oObjPerg:GetGroup(cPerg)

If Empty(aPergunte[2])  //pq nao existe pergunte e tem que fazer via parambox

	aAdd(aParamPerg,{ 1,    "Conta Orc. de ", Space(Len(AK5->AK5_CODIGO)), "@!","","AK5","",50,.T.})
	aAdd(aParamPerg,{ 1,    "Conta Orc. ate ", Space(Len(AK5->AK5_CODIGO)), "@!","","AK5","",50,.T.})
	aAdd(aParamPerg,{ 3,    "Cons.Contas Bloqueadas ",1, {"Sim","Nao" } ,65,"",.T.,""}) 

	aParamResp := { Space(Len(AK5->AK5_CODIGO)), Repl("z",Len(AK5->AK5_CODIGO)), 1 }

	If ParamBox(aParamPerg,"Preencha Parametros", aParamResp,,,,,,)
			lRet := .T.
			cCtOrcDe := aParamResp[1]
			cCtOrcAte := aParamResp[2]
			nCsdBloq := aParamResp[3]
	EndIf
		
Else

	If Pergunte(cPerg, .T.)
		lRet := .T.
		cCtOrcDe := MV_PAR01
		cCtOrcAte := MV_PAR02
		nCsdBloq := MV_PAR03
	EndIf
		
EndIf

Return( lRet )