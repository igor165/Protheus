#INCLUDE "TMSA640.ch"
#INCLUDE "PROTHEUS.CH"

Static lTM640LIB := ExistBlock("TM640LIB")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA640  ³ Autor ³ Robson Alves          ³ Data ³21.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Liberacao de Transporte.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA640()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Transporte                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA640()

Local cCondicao := ""
Local aCores := {	{"C9_BLTMS <>'  '"                     ,'BR_LARANJA'},; //Item Bloqueado pelo Transporte.
					{"C9_BLCRED=='  '"                     ,'ENABLE'    },; //Item Liberado.
					{"C9_BLCRED=='10'.And.C9_BLEST =='10'" ,'DISABLE'   },; //Item Faturado.
					{"C9_BLCRED<>'  '.And.C9_BLCRED<>'10'" ,'BR_AZUL'   },; //Item Bloqueado - Credito.
					{"C9_BLEST <>'  '.And.C9_BLEST <>'10'" ,'BR_PRETO'  },; //Item Bloqueado - Estoque.
					{"C9_BLWMS <='05'.And.!C9_BLWMS=='  '" ,'BR_AMARELO'} } //Item Bloqueado - WMS.

Private bFiltraBrw := {|| Nil}
Private cCadastro  := STR0001 //"Liberacao de Transporte"
Private aRotina    := MenuDef()

If Pergunte("TMA640", .T.)
	If mv_par01 == 1 // Somente pedidos Bloqueados.
		cCondicao := "C9_FILIAL = '" + xFilial("SC9") + "' AND C9_BLTMS <> '  '"
	EndIf
	DbSelectArea("SC9")
	DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	MBrowse( 7, 4,20,74,"SC9",,,,,,aCores,,,,,,,,cCondicao)
	/* Restaura a integridade do SC9. */
	dbSelectArea("SC9")
	RetIndex("SC9")
EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA640Lib³ Autor ³ Robson Alves          ³ Data ³21.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Libera Pedido.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA640Lib(ExpC1, ExpN1, ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias principal.                                   ³±±
±±³          ³ ExpN1 = Registro posicionado.                              ³±±
±±³          ³ ExpN2 = Opcao do aRotina.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA640Lib(cAlias, nReg, nOpcx)

Local cPedido   := SC9->C9_PEDIDO
Local cCodCli   := SC9->C9_CLIENTE
Local cNomCli   := Posicione("SA1",1,xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA,"A1_NOME")
Local dDtaEmis  := SC9->C9_DATALIB
Local cBloqueio := ""
Local cDescBloq := ""
Local cMemoBloq := ""
Local nOpcA     := 0
Local aAreaSC9  := {}
Local aButtons  := {}
Local cCliGen   := GetMv("MV_CLIGEN")
Local oPanel, oDlg, oPedido, oCodCli, oNomCli, oDtaEmis, oBloqueio, oDescBlq, oMemo

If ValType(cCliGen) <> "C"
	cCliGen := Space(Len(SA1->A1_COD) + Len(SA1->A1_LOJA))
EndIf
If !Empty(SC9->C9_BLTMS) .Or. nOpcx == 2

	/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
	SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
	If SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO)) .And. nOpcx <> 2
		If !SoftLock("SC5")
			Return Nil
		EndIf
	EndIf

	Aadd(aButtons, {"DEVOLNF",{|| A640VisDoc()}, STR0013 , STR0012 }) //Visualiza Documento

	/* Obtem os detalhes do bloqueio. */
	If SC9->(FieldPos("C9_BLINF")) > 0 .And. !Empty(SC9->C9_BLINF)
		cMemoBloq := SC9->C9_BLINF
	Else
		DV5->(dbSetOrder(1)) //DV5_FILIAL+DV5_CODCLI+DV5_LOJCLI+DV5_CODBLQ
		If	DV5->(MsSeek(xFilial("DV5") + SC9->C9_CLIENTE + SC9->C9_LOJA)) .Or.;
			DV5->(MsSeek(xFilial("DV5") + cCliGen))
			cBloqueio := DV5->DV5_CODBLQ
			cDescBloq := Tabela('M2',DV5->DV5_CODBLQ,.F.)
			cMemoBloq := MSMM(DV5->DV5_CODMOT)
		EndIf
	EndIf

	DEFINE MSDIALOG oDlg FROM  125,3 TO 430,608 TITLE cCadastro PIXEL
		oPanel := TPanel():New(15,05,"",oDlg,,,,,CLR_WHITE,272, 120)

		/* Numero do Pedido. */
		@ 020, 010 SAY Posicione("SX3",2,"C9_PEDIDO","X3Titulo()") SIZE 030,007 OF oPanel PIXEL
		@ 020, 050 MSGET oPedido VAR cPedido  SIZE 30, 07 OF oPanel PIXEL WHEN( .F. )

		/* Codigo do Cliente. */
		@ 020, 170 SAY Posicione("SX3",2,"A1_COD","X3Titulo()") SIZE 030,007 OF oPanel PIXEL
		@ 020, 210 MSGET oCodCli VAR cCodCli  SIZE 30, 07 OF oPanel PIXEL WHEN( .F. )

		/* Nome do Cliente. */
		@ 032, 010 SAY Posicione("SX3",2,"A1_NOME","X3Titulo()") SIZE 030,007 OF oPanel PIXEL
		@ 032, 050 MSGET oNomCli VAR cNomcli SIZE 200, 07 OF oPanel PIXEL WHEN( .F. )

		/* Data de Liberacao. */
		@ 044, 010 SAY Posicione("SX3",2,"C9_DATALIB","X3Titulo()") SIZE 050,007 OF oPanel PIXEL
		@ 044, 050 MSGET oDtaEmis VAR dDtaEmis SIZE 60, 07 OF oPanel PIXEL WHEN( .F. )

		/* Codigo do Bloqeio. */
		@ 044, 170 SAY Posicione("SX3",2,"DV5_CODBLQ","X3Titulo()") SIZE 050,007 OF oPanel PIXEL
		@ 044, 210 MSGET oBloqueio VAR cBloqueio SIZE 15, 07 OF oPanel PIXEL WHEN( .F. )

		/* Descricao do Bloqueio. */
		@ 056, 010 SAY Posicione("SX3",2,"DV5_DESBLQ","X3Titulo()") SIZE 050,007 OF oPanel PIXEL
		@ 056, 050 MSGET oDescBlq VAR cDescBloq SIZE 60, 07 OF oPanel PIXEL WHEN( .F. )

		/* Motivo do Bloqueio. */
		@ 068, 010 SAY Posicione("SX3",2,"DV5_MOTIVO","X3Titulo()") SIZE 050,007 OF oPanel PIXEL
		@ 068, 050 GET oMemo  VAR cMemoBloq MEMO SIZE 200,50 OF oPanel PIXEL WHEN( .F. )
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA := 1, oDlg:End()},{||oDlg:End()},, aButtons)

	If nOpcA == 1 .And. nOpcx <> 2
		/* Libera todos os itens do Pedido. */
		dbSelectArea("SC9")
		SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		aAreaSC9 := GetArea()
		SC9->(MsSeek(xFilial("SC9")+cPedido))
		While SC9->(!Eof() .And. C9_FILIAL == xFilial("SC9") .And. C9_PEDIDO == cPedido)
			If !Empty(SC9->C9_BLTMS)
				RecLock("SC9", .F.)
				SC9->C9_BLTMS := Space(Len(SC9->C9_BLTMS))
				MsUnLock()
				//-- Gravacao adicional na liberacao
				If	lTM640LIB
					ExecBlock("TM640LIB",.F.,.F.)
				EndIf
			EndIf
			SC9->(dbSkip())
		EndDo
		RestArea(aAreaSC9)
	EndIf
	/* Este Unlock libera o Softlock acima.*/
	SC5->(MSUnlock())
Else
	Help("",1,"TMSA64001") // "Este pedido nao esta Bloqueado pelo Transporte"
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A640VisDoc³ Autor ³ Patricia A. Salomao   ³ Data ³13.07.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza os Documentos do Pedido Bloqueado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A640VisDoc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A640VisDoc()

Local aArea := GetArea()

DT6->(dbSetOrder(1))
If DT6->(MsSeek(xFilial('DT6')+cFilAnt + Padr(SC9->C9_PEDIDO, Len(DT6->DT6_DOC)) + 'PED'))
	TMSA500Mnt( 'DT6', DT6->(Recno()), 2 )
EndIf

RestArea(aArea)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA640PNF³ Autor ³ Eduardo de Souza      ³ Data ³ 19/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa o pedido atraves da nota fiscal                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA640PNF()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA640                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA640PNF()

Local cTCliRem := RetTitle("DTC_CLIREM")
Local cTLojRem := RetTitle("DTC_LOJREM")
Local cTNomRem := RetTitle("DTC_NOMREM")
Local cTNumNfc := RetTitle("DTC_NUMNFC")
Local cTSerNfc := RetTitle("DTC_SERNFC")
Local cNomRem  := CriaVar("DTC_NOMREM",.F.)
Local cNumNfc  := CriaVar("DTC_NUMNFC",.F.)
Local cSerNfc  := CriaVar("DTC_SERNFC",.F.)
Local nOpcao   := 0
Local oDlg

Private cCliRem  := CriaVar("DTC_CLIREM",.F.)
Private cLojRem  := CriaVar("DTC_LOJREM",.F.)

DEFINE MSDIALOG oDlg FROM 00,00 TO 110,490 PIXEL TITLE STR0011 //-- 'Pesquisa Nota Fiscal'

@ 06,05 SAY cTCliRem PIXEL
@ 05,40 MSGET cCliRem F3 'SA1' SIZE 25, 10 OF oDlg PIXEL ;
			VALID Vazio() .Or. ExistCpo('SA1',cCliRem+AllTrim(cLojRem),1) .And. ;
					AllwaysTrue(cNomRem := Posicione("SA1",1,xFilial("SA1")+cCliRem+AllTrim(cLojRem),"A1_NOME"))

@ 06,80 SAY cTLojRem PIXEL
@ 05,120 MSGET cLojRem SIZE 20, 10 OF oDlg PIXEL ;
			VALID Vazio() .Or. ExistCpo('SA1',cCliRem+AllTrim(cLojRem),1) .And. ;
					AllwaysTrue(cNomRem := Posicione("SA1",1,xFilial("SA1")+cCliRem+AllTrim(cLojRem),"A1_NOME"))

@ 21,05 SAY cTNomRem PIXEL
@ 20,40 MSGET cNomRem SIZE 100, 10 OF oDlg PIXEL WHEN .F.

@ 36,05 SAY cTNumNfc PIXEL
@ 35,40 MSGET cNumNfc SIZE 20, 10 OF oDlg PIXEL

@ 36,80 SAY cTSerNfc PIXEL
@ 35,120 MSGET cSerNfc SIZE 20, 10 OF oDlg PIXEL PICTURE "@!"

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	DTC->(DbSetOrder(2))
	If DTC->(MsSeek(xFilial("DTC")+cNumNfc+cSerNfc+cCliRem+cLojRem))
		If DTC->DTC_SERIE == "PED"
			SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			SC9->(MsSeek(xFilial("SC9")+DTC->DTC_DOC))
		Else
			Help("",1,"TMSA64003",,STR0013,1) //-- Nota Fiscal nao e pedido
		EndIf
	Else
		Help("",1,"TMSA64002",,STR0012,1) //-- Nota fiscal nao encontrada
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
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

Private aRotina := {	{STR0002, "PesqBrw"	  , 0 , 1,0,.F.},; //"Pesquisar"
						{STR0009, "TMSA640Lib", 0 , 2,0,NIL},; //"Visualizar"
						{STR0003, "TMSA640Lib", 0 , 5,0,NIL},; //"Liberar"
						{STR0010, "TMSA640PNF", 0 , 2,0,NIL},; //"Pesquisa NF"
						{STR0004, "A450Legend", 0 , 5,0,.F.} } //"Legenda"

If ExistBlock("TM640MNU")
	ExecBlock("TM640MNU",.F.,.F.)
EndIf

Return(aRotina)
