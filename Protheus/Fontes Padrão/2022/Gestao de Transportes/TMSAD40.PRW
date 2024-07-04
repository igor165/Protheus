#Include 'TMSAD40.ch'
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSAD40  ³ Autor ³Vitor Raspa            ³ Data ³ 28.Ago.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de Documentos Exigidos X Fornecedores / Motoristas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD40()                                                    ³±±
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
Function TMSAD40()
Local aCores      := {}
Local aRet        := {}
Local lRet        := .F.
Local cAlias      := ""
Local cCondicao   := ""
Local bFiltraBrw  := {|| }
Local aIndex      := {}

Private cCadastro := STR0001
Private aRotina	  := {	{ STR0002, "AxPesqui"	,0,1},; //"Pesquisar"
						{ STR0003, "TMSAD40Mnt"	,0,2},; //"Consultar"
						{ STR0004, "TMSAD40Mnt"	,0,3},; //"Baixar"
						{ STR0005, "TMSAD40Mnt"	,0,4},; //"Lib. Temporaria"
						{ STR0006, "TMSAD40Leg"	,0,5} } //"Legenda"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ MV_PAR01: Verificar Documentos                               ³
//³           1-Fornecedor / 2-Motoristas                        ³
//³                                                              ³
//³ MV_PAR02: Filtrar Status                                     ³
//³           1-Sem Filtro / 2-Doctos. Pendentes                 ³
//³           3-Periodo Expirado / 4-Ambos                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte('TMD40A',.T.)
	If MV_PAR01 == 1
		cAlias := "DD1" //-- Fornecedores
	ElseIf MV_PAR01 == 2
		cAlias := "DD2" //-- Motoristas
	EndIf

	If MV_PAR02 <> 1 //-- Sem Filtro
		cCondicao := cAlias+'->'+cAlias+'_FILIAL == "' + xFilial(cAlias) + '" .And. '
		cCondicao += cAlias+'->'+cAlias+'_STATUS == "' + Str(MV_PAR02,1) + '"'
		//-- Realiza o filtro
		bFiltraBrw := {|| FilBrowse(cAlias, @aIndex, cCondicao)}
		Eval(bFiltraBrw)
	EndIf

	Aadd(aCores,{cAlias+"_STATUS=='1'",'BR_VERDE'})		// Sem Restricoes/Pendencias
	Aadd(aCores,{cAlias+"_STATUS=='2'",'BR_VERMELHO'})	// Documentacao Pendente
	Aadd(aCores,{cAlias+"_STATUS=='3'",'BR_AMARELO'})	// Periodo de Prestacao de Serv. Expirado
	Aadd(aCores,{cAlias+"_STATUS=='4'",'BR_LARANJA'})	// Documentacao/Per. Prest. Serv. Pendente
	MBrowse( ,,,,cAlias,,,,,,aCores)

	//-- Restaura a integridade
	DbSelectArea(cAlias)
	RetIndex(cAlias)
	If MV_PAR02 <> 1 //-- Sem Filtro
		dbClearFilter()
		aEval(aIndex,{|x| Ferase(x[1]+OrdBagExt())})
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD40Mnt³ Autor ³ Vitor Raspa           ³ Data ³ 28.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manut. de Documentos Exigidos X Fornecedores / Motoristas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD40Mnt( cExpC1, nExpN1, nExpN2 )                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 = Alias do arquivo                                   ³±±
±±³          ³nExpN1 = Numero do registro                                 ³±±
±±³          ³nExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD40Mnt( cAlias, nRecno, nOpc )
Local aArea      := GetArea()
Local lBaixa     := .F.
Local oDlg       := Nil
Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local oEnchoice  := Nil
Local cQuery     := ''
Local cAliasQry  := GetNextAlias()
Local aTitulo    := {}
Local aList      := {}
Local oTWBrowse  := Nil
Local nAux       := 0
Local nCpos      := 0
Local nFator     := 0
Local oOk        := LoadBitMap(GetResources(),"LBOK")
Local oNo        := LoadBitMap(GetResources(),"LBNO")
Local aAvaliaBlq := {}
Local bCampo     := { |nCpo| FieldName(nCpo) }
Local lTMD40GRV  := ExistBlock("TMD40GRV")
Local oMainModel := NIL

If nOpc <> 3
	If cAlias == 'DD1'
		If ExistFunc("TMSAD20STC") //--- Rotina MVC
			TMSAD20STC(( nOpc == 4 ), (nOpc == 2 ))

			oMainModel:= FWLoadModel("TMSAD20")
			oMainModel:SetOperation( Iif(nOpc==2,1,nOpc) )
			oMainModel:Activate()

			FWExecView (, "TMSAD20" , Iif(nOpc==2,1,nOpc) , ,{|| .T. }, , , , , , , oMainModel ) 	

			TMSAD20STC(.F., .F.)
		EndIf
	ElseIf cAlias == 'DD2'
		TMSAD30Mnt( 'DD2', DD2->(RecNo()), nOpc,, ( nOpc == 4 ), (nOpc == 2 ) )
	EndIf
Else
	INCLUI := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PROCESSO DE BAIXA (APRESENTACAO) DO DOCUMENTO EXIGIDO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ MV_PAR01: Somente Documentos Vencidos?                       ³
	//³           1-Sim / 2-Nao                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Pergunte('TMD40B',.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Configura variaveis da Enchoice³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RegToMemory( cAlias,.F. )

		If cAlias == 'DD1'
			Aadd(aTitulo, ' ')
			AAdd(aTitulo, RetTitle('DD3_CODDOC'))
			AAdd(aTitulo, RetTitle('DD3_DESDOC'))
			AAdd(aTitulo, RetTitle('DD3_PRXAPR'))

			cQuery := "SELECT DD3.DD3_OK OK, DD3.DD3_CODDOC CODDOC, DD0.DD0_DESDOC DESCRI, " 
			cQuery += "DD3.DD3_PRXAPR PRXAPR, DD3.R_E_C_N_O_ ItRecNo "
			cQuery += "FROM " + RetSQLName('DD3') + " DD3, " + RetSQLName('DD0') + " DD0 "
			cQuery += "WHERE DD3.DD3_FILIAL = '" + xFilial('DD3') + "' AND "
			cQuery += "DD0.DD0_FILIAL = '" + xFilial('DD0') + "' AND "
			cQuery += "DD3.DD3_CODDOC = DD0.DD0_CODDOC AND "
			cQuery += "DD3.DD3_CODFOR = '" + DD1->DD1_CODFOR + "' AND "
			cQuery += "DD3.DD3_LOJFOR = '" + DD1->DD1_LOJFOR + "' AND "
			If MV_PAR01 == 1
				cQuery += "DD3.DD3_PRXAPR <= '" + DtoS(dDataBase) + "' AND "
			EndIf
			cQuery += "DD3.D_E_L_E_T_ = '' AND DD0.D_E_L_E_T_ = ''"

		ElseIf cAlias == 'DD2'
			Aadd(aTitulo, ' ')
			AAdd(aTitulo, RetTitle('DD4_CODDOC'))
			AAdd(aTitulo, RetTitle('DD4_DESDOC'))
			AAdd(aTitulo, RetTitle('DD4_PRXAPR'))

			cQuery := "SELECT DD4.DD4_OK OK, DD4.DD4_CODDOC CODDOC, DD0.DD0_DESDOC DESCRI, "
			cQuery += "DD4.DD4_PRXAPR PRXAPR, DD4.R_E_C_N_O_ ItRecNo "
			cQuery += "FROM " + RetSQLName('DD4') + " DD4, " + RetSQLName('DD0') + " DD0 "
			cQuery += "WHERE DD4.DD4_FILIAL = '" + xFilial('DD4') + "' AND "
			cQuery += "DD0.DD0_FILIAL = '" + xFilial('DD0') + "' AND "
			cQuery += "DD4.DD4_CODDOC = DD0.DD0_CODDOC AND "
			cQuery += "DD4.DD4_CODMOT = '" + DD2->DD2_CODMOT + "' AND "
			If MV_PAR01 == 1
				cQuery += "DD4.DD4_PRXAPR <= '" + DtoS(dDataBase) + "' AND "
			EndIf
			cQuery += "DD4.D_E_L_E_T_ = '' AND DD0.D_E_L_E_T_ = ''"
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TcSetField(cAliasQry,"PRXAPR","D",8,0)	

		If !(cAliasQry)->(EoF())
			While !(cAliasQry)->(EoF())
				AAdd( aList, {	.F.,;
								(cAliasQry)->CODDOC,;
								(cAliasQry)->DESCRI,;
								(cAliasQry)->PRXAPR,;
								(cAliasQry)->ItRecNo } )

				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())

			//-- Dimensoes padroes
			aSize := MsAdvSize()
			AAdd( aObjects, { 65, 100, .T., .T. } )
			AAdd( aObjects, { 235, 235, .T., .T. } )
			aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
			aPosObj	:= MsObjSize( aInfo, aObjects,.T.)

			DEFINE MSDIALOG oDlg TITLE STR0007 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //-- 'Baixa de Documentos Exigidos'
			oEnchoice := MsMGet():New(cAlias,(cAlias)->(RecNo()),2,,,,,aPosObj[1],{},3,,,,,,.T.)
			oTWBrowse := TWBrowse():New( 	aPosObj[2,1],;
											aPosObj[2,2],;
											aPosObj[2,4]-5,;
											aPosObj[2,3]-100,; 
											NIL,;
											aTitulo,;
											NIL,;
											oDlg,NIL,NIL,NIL,,,,,,,,,,"ARRAY", .T. )
			oTWBrowse:bLDblClick  := {|| aList[oTWBrowse:nAt,1] := !aList[oTWBrowse:nAt,1], oTWBrowse:Refresh()}
			oTWBrowse:SetArray( aList )
			oTWBrowse:bLine := {||	{If(aList[oTWBrowse:nAt,1], oOk, oNo),;
									aList[ oTWBrowse:nAT, 2 ],;
									aList[ oTWBrowse:nAT, 3 ],;
									aList[ oTWBrowse:nAT, 4 ]} }

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| lBaixa := .T., oDlg:End() } ,;
																{|| lBaixa := .F., oDlg:End()})
			If lBaixa
				For nAux := 1 To Len(aList)
					If aList[nAux,1]
						Begin Transaction
							If cAlias == 'DD1'
								DD3->(DbGoTo(aList[nAux,5]))
								RecLock('DD3',.F.)
								DD3->DD3_ULTAPR := dDataBase
								If DD3->DD3_TIPPER == '1' //-- Diario
									nFator := 1
								ElseIf DD3->DD3_TIPPER == '2' //-- Mensal
									nFator := 30
								ElseIf DD3->DD3_TIPPER == '3' //-- Anual
									nFator := 365
								EndIf
								DD3->DD3_PRXAPR := (dDataBase + (DD3->DD3_PERAPR * nFator))
								DD3->DD3_TOLERA := Ctod(Space(8))
								MsUnLock()

								RegToMemory('DD5', .T.)
								M->DD5_FILIAL := xFilial('DD5')
								M->DD5_CODFOR := DD1->DD1_CODFOR
								M->DD5_LOJFOR := DD1->DD1_LOJFOR
								M->DD5_CODDOC := DD3->DD3_CODDOC
								M->DD5_DTAAPR := dDataBase
								M->DD5_RESPON := cUserName 
								M->DD5_TIPO   := "1" //--Liberacao por Baixa

								RecLock('DD5',.T.)
								For nCpos := 1 TO FCount()
									If DD5->(FieldName(nCpos)) == 'DD5_FILIAL'
										DD5->(FieldPut(nCpos,xFilial("DD5")))
									Else
										If Type('M->'+DD5->(FieldName(nCpos))) <> 'U'
											DD5->(FieldPut(nCpos,M->&(Eval(bCampo,nCpos))))
										EndIf
									EndIf
								Next
								MsUnLock()

								//-- Verifica se Existem Bloqueios relacionado ao Documento
								//-- que esta sendo baixado. Caso afirmativo, elimina o bloqueio
								cQuery := "SELECT DUC.DUC_CODBLQ,DUC.DUC_CODDOC,DUC.DUC_CODFOR,DUC.DUC_LOJFOR, DUC.R_E_C_N_O_ DUCRecNo "
								cQuery += "FROM " + RetSQLName('DUC') + " DUC "
								cQuery += "WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND "
								cQuery += "DUC.DUC_CODFOR = '" + DD3->DD3_CODFOR + "' AND "
								cQuery += "DUC.DUC_LOJFOR = '" + DD3->DD3_LOJFOR + "' AND "
								cQuery += "DUC.DUC_CODDOC = '" + DD3->DD3_CODDOC + "' AND "
								cQuery += "DUC.DUC_STATUS = '1' AND "
								cQuery += "DUC.D_E_L_E_T_ = '' "

								cQuery := ChangeQuery(cQuery)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

								If !(cAliasQry)->(EoF())
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
								Else
									RecLock('DD1',.F.)
									DD1->DD1_STATUS := '1' // Sem Restricoes/Pendencias
									MsUnLock()
								EndIf
								(cAliasQry)->(DbCloseArea())

							ElseIf cAlias == 'DD2'
								DD4->(DbGoTo(aList[nAux,5]))
								RecLock('DD4',.F.)
								DD4->DD4_ULTAPR := dDataBase
								If DD4->DD4_TIPPER == '1' 	  //-- Diario
									nFator := 1
								ElseIf DD4->DD4_TIPPER == '2' //-- Mensal
									nFator := 30
								ElseIf DD4->DD4_TIPPER == '3' //-- Anual
									nFator := 365
								EndIf
								DD4->DD4_PRXAPR := (dDataBase + (DD4->DD4_PERAPR * nFator))
								DD4->DD4_TOLERA := Ctod(Space(8))
								MsUnLock()

								RegToMemory('DD6',.T.)
								M->DD6_FILIAL := xFilial('DD6')
								M->DD6_CODMOT := DD2->DD2_CODMOT
								M->DD6_CODDOC := DD4->DD4_CODDOC
								M->DD6_DTAAPR := dDataBase
								M->DD6_RESPON := cUserName
								M->DD6_TIPO   := "1" //--Liberacao por Baixa

								RecLock('DD6',.T.)
								For nCpos := 1 TO FCount()
									If DD6->(FieldName(nCpos)) == 'DD6_FILIAL'
										DD6->(FieldPut(nCpos,xFilial("DD6")))
									Else
										If Type('M->'+DD6->(FieldName(nCpos))) <> 'U'
											DD6->(FieldPut(nCpos,M->&(Eval(bCampo,nCpos))))
										EndIf
									EndIf
								Next
								MsUnLock()

								//-- Verifica se Existem Bloqueios relacionado ao Documento
								//-- que esta sendo baixado. Caso afirmativo, elimina o bloqueio
								cQuery := "SELECT DUC.DUC_CODBLQ,DUC.DUC_CODDOC,DUC.DUC_CODMOT,DUC.R_E_C_N_O_ DUCRecNo "
								cQuery += "FROM " + RetSQLName('DUC') + " DUC "
								cQuery += "WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND "
								cQuery += "DUC.DUC_CODMOT = '" + DD4->DD4_CODMOT + "' AND "
								cQuery += "DUC.DUC_CODDOC = '" + DD4->DD4_CODDOC + "' AND "
								cQuery += "DUC.DUC_STATUS = '1' AND "
								cQuery += "DUC.D_E_L_E_T_ = '' "

								cQuery := ChangeQuery(cQuery)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
								If !(cAliasQry)->(EoF())
									While !(cAliasQry)->(EoF())
										DUC->(DbGoTo( (cAliasQry)->DUCRecNo ))

										//-- Monta Array para reavaliacao dos Status
										AAdd( aAvaliaBlq, {	DUC->DUC_CODBLQ, DUC->DUC_CODFOR, DUC->DUC_LOJFOR,;
															DUC->DUC_CODMOT, DUC->DUC_DTAAPR, DUC->DUC_DTAAFA,;
															DUC->DUC_DTARET, .F. } )

										//-- Exclui o Bloqueio
										RecLock('DUC', .F.)
										DbDelete()
										MsUnLock()

										(cAliasQry)->(DbSkip())
									EndDo
								Else
									RecLock('DD2',.F.)
									DD2->DD2_STATUS := '1' // Sem Restricoes/Pendencias
									MsUnLock()
								EndIf
								(cAliasQry)->(DbCloseArea())
							EndIf 
							//-- Gravacao adicional após a confirmação da baixa dos documentos exigidos
							If lTMD40GRV
								ExecBlock("TMD40GRV",.F.,.F.)
							EndIf
						End Transaction
					EndIf
				Next
				TMSAvlBlqDoc( aAvaliaBlq )
			EndIf
		Else
			Help('',1,'TMSAD4001') //-- 'Nao existem documentos a serem apresentados'
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD40Leg³ Autor ³Vitor Raspa            ³ Data ³ 29.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD40Leg()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD40Leg()
BrwLegenda( cCadastro, STR0008  ,; //"Status"
			{{ "BR_VERDE"		, STR0009},;	//'Sem Restricoes'
			 { "BR_VERMELHO"	, STR0010},;	//'Documentacao Pendente'
			 { "BR_AMARELO"		, STR0011},;	//'Per. de Prestacao de Serv. Expirado'
			 { "BR_LARANJA"		, STR0012}})	//'Doc. Pend. / Per. Prest. Serv. Expirado'

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSD40VlSX1³ Autor ³Vitor Raspa         ³ Data ³ 06.Set.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao para validar a Escolha dos Parametros (Pergunte)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSD40VlSX1()
Local lRet := .T.
If MV_PAR01 == 2 .And. (MV_PAR02 <> 1 .And. MV_PAR02 <> 2)
	Help('',1,'TMSAD4002') //-- 'Quando os documentos a serem checados forem de Motoristas, somente os Status "Sem Filtro" e "Doc. Pendentes" estao disponiveis.
	MV_PAR02 := 1
	lRet := .F.
EndIf
Return(lRet)

