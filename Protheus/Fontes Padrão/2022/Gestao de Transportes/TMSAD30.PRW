#Include 'TMSAD30.ch'
#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSAD30  ³ Autor ³Vitor Raspa            ³ Data ³ 28.Ago.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Documentos Exigidos X Motoristas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD30()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD30(xAutoCab,xAutoItens,nOpcAuto)

Private cCadastro := STR0001 //-- 'Documentos Exigidos X Motoristas'
Private aRotina	  := MenuDef()
Private l030dAuto  := xAutoCab <> NIL  .And. xAutoItens <> NIL
Private aAutoCab   := {}  // Detalhe dos Documentos (Rotina Automatica)
Private aAutoItens := {}  // Itens dos documentrs (Rotina Automatica)

Default xAutoCab   := {}
Default xAutoItens := {}
Default nOpcAuto   := 0

If !l030dAuto
	MBrowse( ,,,,'DD2')
Else
	If Type("n") == "U"
		n := 1
	EndIf

	lMsHelpAuto := .T.

	aAutoCab   := xAutoCab 	
	aAutoItens := xAutoItens

	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"DD2")
EndIf
RetIndex('DD2')
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD30Mnt³ Autor ³ Vitor Raspa           ³ Data ³ 28.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Documentos Exigidos X Motoristas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD30Mnt(cExpC1, nExpN1, nExpN2, aExpA1, lExpL1, lExpL2) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 = Alias do arquivo                                   ³±±
±±³          ³nExpN1 = Numero do registro                                 ³±±
±±³          ³nExpN2 = Opcao selecionada                                  ³±±
±±³          ³aExpA2 = Array com a Estrutura de cAlias (cExpC1)           ³±±
±±³          ³lExpL1 = Processo para realizar a Liberacao Temporaria?     ³±±
±±³          ³lExpL2 = Exibe o botao 'Mais Detalhes' na Enchoice?         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD30Mnt( cAlias, nReg, nOpc, aStruct, lLibTemp, lDetail )
Local oEnchoice    := Nil
Local lOk          := .F.
Local oDlg         := Nil
Local aObjects     := {}
Local aInfo        := {}
Local aNoFields    := {'DD4_CODFOR', 'DD4_LOJFOR', 'DD4_CODMOT', 'DD4_OK'}  //Campos a serem excluidos
Local aYesFields   := {}	//Campos a serem incluidos
Local aRetPE       := {}
Local aAltCposEnch := Nil
Local aAltCposGetD := Nil
Local aButtons     := Nil
Local nMaxLin      := 99
Local cQuery       := ''
Local cAliasQry    := ''
Local nAux         := 0
Local lContinua    := .T.

Private aTela[0][0]
Private aGets[0]
Private oGetDados  := Nil
Private aHeader    := {}
Private aCols      := {}
Private aPosObj    := {}

l030dAuto := If (Type("l030dAuto") == "U",.F.,l030dAuto)

Default cAlias     := 'DD2'
Default nReg       := 1
Default nOpc       := 2
Default lLibTemp   := .F.
Default lDetail    := .F.

/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
If nOpc == 4 .Or. nOpc == 5 //-- 4=Alteracao ; 5=Exclusao
	If !SoftLock("DD2")
		Return Nil
	EndIf
EndIf

If !lLibTemp .And. !lDetail
	AAdd( aNoFields, 'DD4_TOLERA' )
ElseIf lLibTemp
	aAltCposEnch := {}
	aAltCposGetD := {'DD4_TOLERA'}
EndIf
If lDetail
	aButtons := {{'DESTINOS',{|| TMSAD30Det() } , STR0007, STR0008 }} //-- 'Mais Detalhes...' # 'Mais Det.'
EndIf

//-- Ponto de entrada para permitir incluir e excluir campos do GetDados.
If ExistBlock("TMAD30GET")
	aRetPE := ExecBlock("TMAD30GET",.F.,.F.,{aNoFields,aYesFields})
	If	ValType(aRetPE) == "A"
		aNoFields  := aClone(aRetPE[1])
		aYesFields := aClone(aRetPE[2])
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura variaveis da Enchoice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( cAlias, nOpc==3 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura variaveis da GetDados Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSFillGetDados(	nOpc, 'DD4', 1, xFilial( 'DD4' ) + M->DD2_CODMOT ,; 
					{ ||  DD4->(DD4_FILIAL + DD4_CODMOT) },;
					{ || .T. }, aNoFields,	aYesFields )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se pode prosseguir com a Exclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5 //-- Exclusao
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DUC.DUC_CODDOC, DUC.DUC_CODMOT"
	cQuery += " FROM " + RetSQLName('DUC') + " DUC"
	cQuery += " WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND"
	cQuery += " DUC.DUC_CODMOT = '" + DD2->DD2_CODMOT + "' AND"
	cQuery += " (
	For nAux := 1 To Len(aCols)
		cQuery += " DUC.DUC_CODDOC = '" + GDFieldGet('DD4_CODDOC',nAux) + "'"
		If nAux < Len(aCols)
			cQuery += " OR "
		EndIf
	Next nAux
	cQuery += " ) AND"
	cQuery += " DUC.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	lContinua := (cAliasQry)->(EoF())
	(cAliasQry)->(DbCloseArea())
	If !lContinua
		Help('',1,'TMSAD3005') //-- 'Existem bloqueios de viagem referente a este Motorista. Exclusao nao permitida.'
		DD2->( MsUnLock() )
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BLOQUEIO DE EXCLUSAO CASO REALIZADA ALGUMA MANUTENCAO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DD6_CODDOC, DD6_CODMOT "
	cQuery += "FROM " + RetSQLName('DD6') + " DD6 "
	cQuery += "JOIN " + RetSQLName('DD4') + " DD4 "
	cQuery += "ON DD6_CODDOC = DD4_CODDOC "
	cQuery += "AND DD4.D_E_L_E_T_ = '' "
	cQuery += "WHERE DD6_CODMOT = '" + DD2->DD2_CODMOT + "' "
	cQuery += "AND DD6.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY DD6_CODMOT,DD6_CODDOC "
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	lContinua := (cAliasQry)->(EoF())
	(cAliasQry)->(DbCloseArea())
	If !lContinua
		Help('',1,'TMSAD3008')//Exclusão não permitida. Ja foi realizada a manutenção deste documento"
		DD2->( MsUnLock() )
		Return
	EndIf
EndIf

If lLibTemp
	nMaxLin := Len(aCols)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche o Numero do Item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(GDFieldGet("DD4_ITEM",1))
	GDFieldPut("DD4_ITEM",StrZero(1,Len(DD4->DD4_ITEM)),1)
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 65, 100, .T., .T. } )
AAdd( aObjects, { 235, 235, .T., .T. } )
aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj	:= MsObjSize( aInfo, aObjects,.T.)

//-- Ajuste do Ponteiro da tabela da GetDados para nao 
//-- Trazer sujeira na adicao de novas linhas, quando a operacao for
//-- de alteracao de registro.
DD4->(DbGoTo(0))
If !l030dAuto
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	oEnchoice := MsMGet():New( cAlias, nReg, nOpc,,,,, aPosObj[1],aAltCposEnch,3,,,,,,.T. )

	oGetDados := MSGetDados():New(	aPosObj[2,1], aPosObj[2,2],aPosObj[2,3], aPosObj[2,4],; 
												nOpc, 'TMSAD30LOk','TMSAD30TOk','+DD4_ITEM',;
												IIf((nOpc==3 .Or. nOpc==4) .And. !lLibTemp,.T.,Nil),;
												aAltCposGetD,,,nMaxLin)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| If(TMSAD30TOk(), ( lOk := .T.,oDlg:End()), lOk := .F. )} ,;
														{|| lOk := .F., oDlg:End()},,aButtons)
Else
	If EnchAuto(cAlias,aAutoCab,,nOpc,,{|| Obrigatorio(aGets,aTela)}) .And. MsGetDAuto(aAutoItens,,{|| TMSAD30TOk()},aAutoCab,nOpc)
		lOk := .T.
	EndIf
EndIf	

If nOpc != 2 .And. lOk
	TMSAD30Grv( M->DD2_CODMOT, nOpc, lLibTemp )
EndIf

DD2->( MsUnLock() )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD30LOk³ Autor ³ Vitor Raspa           ³ Data ³ 28.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD30LOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD30LOk()
Local lRet      := .T.
Local aCpoCheck := {'DD4_CODDOC'}

If !GDDeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey(aCpoCheck,4)
EndIf 

If lRet .And. !GDDeleted(n)
	If GDFieldGet('DD4_PRXAPR',n) < dDataBase .And. (Empty(GDFieldGet('DD4_TOLERA',n)) .Or. GDFieldGet('DD4_TOLERA',n) < dDataBase )
		Help('',1,'TMSAD3004') //-- "Data para apresentacao do documento invalida!"
		lRet := .F.
	EndIf
EndIf

if lRet .and. ExistBlock("TMAD30LOK")
	lRet:=ExecBlock("TMAD30LOK",.F.,.F.,{aCols[n]})
	If ValType(lRet) != "L"
		lRet:=.T.
	EndIf
endif 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD30TOk³ Autor ³ Vitor Raspa           ³ Data ³ 17.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD30TOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD30TOk()
Local lRet := .T.
Local nAux := 0
Local nDel := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a Enchoice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := Obrigatorio( aGets, aTela )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a GetDados Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := TMSAD30LOk()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as linhas estao Ativas³
//³GetDados Principal                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	nDel := 0	
	For nAux := 1 To Len(aCols)
		If aCols[nAux,Len(aHeader)+1]
			nDel++
		EndIf
	Next
	If Len(aCols) == nDel
		Help('',1,'TMSAD3001') //--'Informe pelo menos um Documento para o Motorista'
		lRet := .F.
	EndIf
EndIf 

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD30Grv ³ Autor ³ Vitor Raspa          ³ Data ³ 28.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD30Grv( cExpC1, nExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1: Codigo do Motorista                                ³±±
±±³          ³ nExpN1: Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAD30Grv( cCodMot, nOpc, lLibTemp )
Local nAux       := 0
Local nAux2      := 0
Local cQuery     := ''
Local cAliasQry  := ''
Local aAvaliaBlq := {}
Local aArea      := GetArea()
Local aAreaDD2   := DD2->(Getarea())
Local aAreaDD4   := DD4->(Getarea())
Local aRetUsr    := PswRet()
Local lTMAD30GRV := ExistBlock("TMAD30GRV")

Begin Transaction
	If	nOpc == 5
		//ÚÄÄÄÄÄÄÄÄÄÄ¿
		//³ EXCLUSAO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³CABECALHO³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		RecLock('DD2', .F.)
		DbDelete()
		MsUnLock()
		//ÚÄÄÄÄÄ¿
		//³ITENS³
		//ÀÄÄÄÄÄÙ
		DD4->(DbSetOrder(1))
		While DD4->( MsSeek( xFilial('DD2') + cCodMot, .F. ) )
			RecLock('DD4', .F.)
			DbDelete()
			MsUnLock()
			//-- Excluindo Observacao para cada Tipo de documento
			MSMM(DD4->DD4_CODOBS,,,,2)
			If nOpc == 5
				If lTMAD30GRV
					ExecBlock("TMAD30GRV",.F.,.F.,{ nOpc })
				EndIf
			EndIf

		EndDo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ INCLUSAO/ALTERACAO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³CABECALHO³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		RecLock("DD2",(nOpc == 3))
		Aeval( dbStruct(),{|aFieldName,nI| FieldPut( nI, If('FILIAL' $ aFieldName[1],;
													   xFilial( "DD2" ), M->&(aFieldName[1]) ) ) } )
		MsUnLock()

		//ÚÄÄÄÄÄ¿
		//³ITENS³
		//ÀÄÄÄÄÄÙ
		For nAux := 1 To Len( aCols )
			DD4->(dbSetOrder(1))
			If	!GDDeleted( nAux ) 
				If	DD4->( MsSeek( xFilial('DD4') + cCodMot + GDFieldGet( 'DD4_ITEM', nAux ), .F. ) )
					RecLock('DD4', .F.)
				Else
					RecLock('DD4', .T.)
					DD4->DD4_FILIAL := xFilial('DD4')
					DD4->DD4_CODMOT  := cCodMot
				EndIf
				For nAux2 := 1 To Len(aHeader)
					If	aHeader[nAux2,10] != 'V'
						FieldPut(FieldPos(aHeader[nAux2,2]), aCols[nAux,nAux2])
					EndIf
				Next
				//-- Incluindo Observacao para cada Tipo de documento caso exista
				If DD4->(FieldPos("DD4_CODOBS")) <> 0
					MSMM(DD4->DD4_CODOBS,,,GDFieldGet( 'DD4_OBS', nAux ),1,,,'DD4','DD4_CODOBS') 
				Endif

				MsUnLock()

				If nOpc == 3 .Or. nOpc == 4
					If lTMAD30GRV
						ExecBlock("TMAD30GRV",.F.,.F.,{ nOpc })
					EndIf
				EndIf

				If lLibTemp .And. !Empty(GDFieldGet('DD4_TOLERA',nAux))
					cAliasQry := GetNextAlias()
					//-- Verifica se Existem Bloqueios relacionado ao Documento
					//-- que esta sendo lancada a data de Tolerancia. Caso afirmativo, elimina o bloqueio
					cQuery := "SELECT DUC.DUC_CODBLQ,DUC.DUC_CODDOC,DUC.DUC_CODFOR,DUC.DUC_LOJFOR, DUC.R_E_C_N_O_ DUCRecNo "
					cQuery += "FROM " + RetSQLName('DUC') + " DUC, " + RetSQLName('DTQ') + " DTQ "
					cQuery += "WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND "
					cQuery += "DUC.DUC_CODMOT = '" + cCodMot + "' AND "
					cQuery += "DUC.DUC_CODDOC = '" + GDFieldGet('DD4_CODDOC',nAux) + "' AND "
					cQuery += "DUC.DUC_STATUS = '1' AND "
					cQuery += "DUC.DUC_FILORI = DTQ.DTQ_FILORI AND "
					cQuery += "DUC.DUC_VIAGEM = DTQ.DTQ_VIAGEM AND "
					cQuery += "DTQ.DTQ_DATGER <= '" + DtoS(GDFieldGet('DD4_TOLERA',nAux)) + "' AND "
					cQuery += "DUC.D_E_L_E_T_ = '' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
					While !(cAliasQry)->(EoF())
						DUC->(DbGoTo( (cAliasQry)->DUCRecNo ))
						//-- Monta Array para reavaliacao dos status
						AAdd( aAvaliaBlq, {	DUC->DUC_CODBLQ, DUC->DUC_CODFOR, DUC->DUC_LOJFOR,;
											DUC->DUC_CODMOT, DUC->DUC_DTAAPR, DUC->DUC_DTAAFA,;
											DUC->DUC_DTARET, .F. } )

						//-- Exclui o registro de Bloqueio
						RecLock('DUC', .F.)
						DbDelete()
						MsUnLock()
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())

					//-- Gravar o Historico na Liberacao Temporaria
					RecLock('DD6',.T.)
					DD6->DD6_FILIAL := xFilial('DD6')
					DD6->DD6_CODMOT := cCodMot
					DD6->DD6_CODDOC := GDFieldGet('DD4_CODDOC',nAux)
					DD6->DD6_DTAAPR := dDataBase
					DD6->DD6_RESPON := aRetUsr[1][2]
					DD6->DD6_TIPO := "2" //--Liberacao por Tolerancia
					DD6->(MsUnLock())
				EndIf
			Else
				If	DD4->( MsSeek( xFilial('DD4') + cCodMot + GDFieldGet( 'DD4_ITEM', nAux ), .F. ) )
					RecLock('DD4',.F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		Next
		TMSAvlBlqDoc( aAvaliaBlq )
	EndIf
End Transaction

RestArea(aAreaDD2)
RestArea(aAreaDD4)
RestArea(aArea)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD30Det ³ Autor ³ Vitor Raspa          ³ Data ³ 30.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe detalhes do Documento selecionado na GetDados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD30Det()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAD30Det()
Local aArea     := GetArea()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local oDlg      := NIL
Local oLstBox   := NIL
Local aDados    := {}
Local cCodDoc   := CriaVar('DD0_CODDOC')
Local cDesDoc   := CriaVar('DD0_DESDOC')
Local cDesc     := ""
Local nSeek     := 0
Local aSx3Box   := RetSx3Box( Posicione('SX3', 2, 'DD6_TIPO', 'X3CBox()' ),,, 1 )
Local lLGPD		:= FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. FindFunction('TMLGPDCpPr')
Local cNomMot   := ""
Local lOfusca   := .F.

cQuery := "SELECT DD6.DD6_CODMOT, DD6.DD6_CODDOC, DD6.DD6_DTAAPR, DD6.DD6_RESPON, DD6.DD6_TIPO "
cQuery += "FROM " + RetSQLName('DD6') + " DD6 "
cQuery += "WHERE DD6.DD6_FILIAL = '" + xFilial('DD6') + "' AND "
cQuery += "DD6.DD6_CODDOC = '" + GDFieldGet('DD4_CODDOC') + "' AND "
cQuery += "DD6.DD6_CODMOT = '" + DD2->DD2_CODMOT + "' AND "
cQuery += "DD6.D_E_L_E_T_ = '' "
cQuery += "ORDER BY DD6.DD6_FILIAL, DD6.DD6_DTAAPR"
cQuery := ChangeQuery(cQuery)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
TcSetField(cAliasQry,"DD6_DTAAPR","D",8,0)
If !(cAliasQry)->(EoF())
	While !(cAliasQry)->(EoF())
		If	( nSeek := Ascan( aSx3Box, { |x| x[ 2 ] == (cAliasQry)->DD6_TIPO } ) ) > 0
			cDesc :=  aSx3Box[ nSeek, 3 ]
		EndIf
		AAdd( aDados, {DD6->DD6_DTAAPR, (cAliasQry)->DD6_RESPON, cDesc } )
		(cAliasQry)->(DbSkip())
	EndDo

	cCodDoc := AllTrim(GDFieldGet('DD4_CODDOC'))
	cDesDoc := GDFieldGet('DD4_DESDOC')
	
	If lLGPD
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DA4_NOME"} )) == 0		
			cNomMot := Replicate('*',TamSX3('DA4_NOME')[1])
			lOfusca:= .T.
		EndIf
	EndIf
	If !lOfusca
		cNomMot := Posicione("DA4",1,xFilial("DA4")+M->DD2_CODMOT,"DA4_COD")
	EndIf

	DEFINE MSDIALOG oDlg FROM 100 ,154 TO 540,750 TITLE STR0008 Of oMainWnd PIXEL //'Mais Detalhes...'
	@ 030,010 SAY RetTitle('DD2_CODMOT') OF oDlg PIXEL
	@ 038,010 MSGET M->DD2_CODMOT When .F. OF oDlg PIXEL

	@ 030,055 SAY RetTitle('DD2_NOMMOT') OF oDlg PIXEL
	@ 038,055 MSGET cNomMot When .F. SIZE 150,010 OF oDlg PIXEL

	@ 055,010 SAY RetTitle('DD4_CODDOC') OF oDlg PIXEL
	@ 063,010 MSGET cCodDoc When .F. OF oDlg PIXEL

	@ 055,055 SAY RetTitle('DD4_DESDOC') OF oDlg PIXEL
	@ 063,055 MSGET cDesDoc When .F. OF oDlg PIXEL

	@ 080,002 LISTBOX oLstBox FIELDS HEADER	RetTitle('DD6_DTAAPR')+"/"+RetTitle('DD4_TOLERA'),;
											RetTitle('DD6_RESPON'), RetTitle('DD6_TIPO');
											OF oDlg SIZE 292,140 PIXEL

	oLstBox:SetArray(aDados)
	oLstBox:bLine := {|| {	aDados[ oLstBox:nAT, 1 ],;
							aDados[ oLstBox:nAT, 2 ],aDados[ oLstBox:nAT, 3 ]} }

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| oDlg:End() } ,;
														{|| oDlg:End()}) CENTERED
	(cAliasQry)->(DbCloseArea())
Else
	Help('',1,'TMSAD3002') //-- 'Nao existe historio de Apresentacao para este Documento/Motorista'
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAD30Vld³ Autor ³ Vitor Raspa          ³ Data ³ 28.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD30Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD30Vld()
Local lRet     := .T.
Local cCampo   := ReadVar()
Local nFator   := 0
Local aAreaDD0 := DD0->(GetArea())

If cCampo == 'M->DD4_CODDOC'
	DD0->(DbSetOrder(1))
	If DD0->(MsSeek(xFilial('DD0') + M->DD4_CODDOC))

		If DD0->DD0_OBRIGA == '2' .Or. DD0->DD0_OBRIGA == '3'
			lRet := .T.
		Else
			Help('',1,'TMSAD1001') //-- Documento Invalido para esta amarracao
			lRet := .F.
		EndIf
		
		If lRet .And. !Empty(DD0->DD0_PERAPR) .And. !Empty(DD0->DD0_TIPPER)
			If DD0->DD0_TIPPER == '1' //-- Diario
				nFator := 1
			ElseIf DD0->DD0_TIPPER == '2' //-- Mensal
				nFator := 30
			ElseIf DD0->DD0_TIPPER == '3' //-- Diario
				nFator := 365
			EndIf
			GDFieldPut('DD4_PRXAPR', (dDataBase + (DD0->DD0_PERAPR * nFator)), n)
		EndIf
	EndIf

ElseIf cCampo == 'M->DD4_PERAPR' 
	If !Empty(M->DD4_PERAPR) .And. !Empty(GDFieldGet('DD4_TIPPER',n))
		If GDFieldGet('DD4_TIPPER',n) == '1' //-- Diario
			nFator := 1
		ElseIf GDFieldGet('DD4_TIPPER',n) == '2' //-- Mensal
			nFator := 30
		ElseIf GDFieldGet('DD4_TIPPER',n) == '3' //-- Diario
			nFator := 365
		EndIf
		GDFieldPut('DD4_PRXAPR', (dDataBase + (M->DD4_PERAPR * nFator)), n)
	EndIf

ElseIf cCampo == 'M->DD4_TIPPER' 
	If !Empty(GDFieldGet('DD4_PERAPR',n)) .And. !Empty(M->DD4_TIPPER)
		If M->DD4_TIPPER == '1' //-- Diario
			nFator := 1
		ElseIf M->DD4_TIPPER == '2' //-- Mensal
			nFator := 30
		ElseIf M->DD4_TIPPER == '3' //-- Diario
			nFator := 365
		EndIf
		GDFieldPut('DD4_PRXAPR', (dDataBase + (GDFieldGet('DD4_PERAPR',n) * nFator)), n)
	EndIf

ElseIf cCampo == 'M->DD4_TOLERA'
	If !Empty(M->DD4_TOLERA)
		If GDFieldGet('DD4_PRXAPR',n) > M->DD4_TOLERA
			Help('',1,'TMSAD3003') //-- 'Data invalida!
			lRet := .F.
		ElseIf M->DD4_TOLERA <= GDFieldGet('DD4_PRXAPR',n)
			Help('',1,'TMSAD3007') //--Tolerancia tem que ser maior que a data da proxima apresentacao
			lRet := .F.
		EndIf
	Else
		DD4->(DbSetOrder(2))
		If DD4->(MsSeek(xFilial("DD4")+M->DD2_CODMOT+GDFieldGet('DD4_CODDOC',n)))
			If !Empty(DD4->DD4_TOLERA)
				Help('',1,'TMSAD3006') //--Ja existe tolerancia registrada para este documento
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDD0)
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³01/04/2007³±±
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

Private aRotina	  := {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
						{ STR0003,'TMSAD30Mnt',0,2,0,.T.},; //'Visualizar'
						{ STR0004,'TMSAD30Mnt',0,3,0,.T.},; //'Incluir'
						{ STR0005,'TMSAD30Mnt',0,4,0,.T.},; //'Alterar'
						{ STR0006,'TMSAD30Mnt',0,5,0,.T.} } //'Excluir'

If ExistBlock("TMAD30MNU")
	ExecBlock("TMAD30MNU",.F.,.F.)
EndIf

Return(aRotina)

