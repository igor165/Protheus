#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MAPAS    ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 22.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mapas de Controle de Produtos Quimicos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mapas(aTRBs)

Local cPerg		:= "MAPAS"
Local cGrpDe	:= ""
Local cGrpAte	:= ""
Local cProdDe	:= ""
Local cProdAte	:= ""
Local lMvAglut	:= GetNewPar ("MV_AGLUTPR", .F.)
Local cChv		:= ""

Local dDtIni	:= mv_par01
Local dDtFim	:= mv_par02
Local cUn		:= ""
Local cMVUNMAPA	:= GetNewPar ("MV_UNMAPA",	"")
Local cMVDESCPR	:= GetNewPar ("MV_DESCPR",	"")
Local cMVCPOMAPA:= GetNewPar ("MV_CPOMAPA",	"")
Local cDescPR	:= ""
Local cCpoUn	:= ""
Local cCpoFator	:= ""
Local cCpoTpFator:= ""
Local aArea		:= {}
Local nPos		:= 0
Local nPosFinal	:= 0

Default aTRBs := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                   ³
//³ mv_par01    // Do Grupo                                                ³
//³ mv_par02    // Ate o Grupo                                             ³
//³ mv_par03    // CLF                                                     ³
//³ mv_par04    // Grupo Principal                                         ³
//³ mv_par05    // Grupos I-II-III-IV-V-VI-VII-VIII-IX                     ³
//³ mv_par06    // Descricao Grupo IX                                      ³
//³ mv_par07    // Nome do Responsavel                                     ³
//³ mv_par08    // CPF do Responsavel                                      ³
//³ mv_par09    // RG do Responsavel                                       ³
//³ mv_par10    // Orgao Expedidor                                         ³
//³ mv_par11    // UF do Responsavel                                       ³
//³ mv_par12    // DDD                                                     ³
//³ mv_par13    // Telefone                                                ³
//³ mv_par14    // Fax                                                     ³
//³ mv_par15    // E-mail                                                  ³
//³ mv_par16    // Do Produto                                              ³
//³ mv_par17    // Até o Produto                                           ³
//³ mv_par18    // Fechamento anterior                                     ³
//³ mv_par19    // Fechamento Atual                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !(Pergunte(cPerg,.T.))
	Return (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe os valores dos Parametros                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cGrpDe		:= mv_par01
cGrpAte		:= mv_par02
cProdDe		:= mv_par16
cProdAte	:= mv_par17

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando todos os campos do parametro MV_CPOMAPA para compor
//³a unidade de medida que será levada para o arquivo Mapas.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMVCPOMAPA)
	nPos := 01
	nPosFinal := AT('/',Alltrim(cMVCPOMAPA))
	cCpoUn    := Substr(cMVCPOMAPA,nPos,nPosFinal - 1)
	nPos      := nPos + nPosFinal
	nPosFinal := AT('/',Alltrim(Substr(cMVCPOMAPA,nPos,Len(Alltrim(cMVCPOMAPA)))))
	cCpoFator := Substr(cMVCPOMAPA,nPos,nPosFinal - 1)
	nPos      := nPos + nPosFinal
	nPosFinal := AT('/',Alltrim(Substr(cMVCPOMAPA,nPos,Len(Alltrim(cMVCPOMAPA)))))
	If nPosFinal == 0
		cCpoTpFator := Substr(cMVCPOMAPA,nPos,Len(Alltrim(cMVCPOMAPA)))
	Else
		cCpoTpFator := Substr(cMVCPOMAPA,nPos,nPosFinal - 1)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes dos parametros da rotina que serao utilizadas no arquivo .INI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aTotal[01] := dDtIni
_aTotal[02] := dDtFim
_aTotal[03] := mv_par03			//CLF
_aTotal[04] := Upper(mv_par04)	//Grupo Principal
_aTotal[05] := mv_par05			//Grupos 123456789
_aTotal[06] := Upper(mv_par06)	//Descricao do Grupo IX
_aTotal[07] := Upper(mv_par07)	//Nome do Responsavel
_aTotal[08] := mv_par08			//CFP do Responsavel
_aTotal[09] := mv_par09			//RG do Responsavel
_aTotal[10] := Upper(mv_par10)	//Orgao Expedidor
_aTotal[11] := Upper(mv_par11)	//UF do Responsavel
_aTotal[12] := mv_par12			//DDD
_aTotal[13] := mv_par13			//Telefone
_aTotal[14] := mv_par14			//Fax
_aTotal[15] := mv_par15			//E-mail
_aTotal[16] := mv_par16			//Do Produto
_aTotal[17] := mv_par17			//Ateh o Produto
_aTotal[90] := Mes(dDtIni)		//Retorna o mes de referencia com 3 caracteres ex: JAN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTRBs := MapasArqs(dDtIni,dDtFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos de estoque                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasEst(1,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entradas                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasMov("E",.F.,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Saidas                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasMov("S",.F.,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Outras Informacoes                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasMov("O",.F.,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere os produtos que nao tiverem movimentacao mas que possuem³
//³estoque no Anexo XI-A - saldo anterior                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ANT->(dbGoTop())
Do While !ANT->(Eof())

	SB5->(dbSetOrder(1))
	SB5->(MsSeek(xFilial("SB5")+ANT->CODIGO))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Concentracao e densidade do produto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nConcent := SB5->B5_CONCENT
	nDensid  := SB5->B5_DENSID

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descrição MV_DESCPR do produto     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMVDESCPR) .And. SB5->(FieldPos(cMVDESCPR)) > 0
		cDescPR := Alltrim(SB5->(FieldGet(FieldPos(cMVDESCPR))))
	EndIf

	//Se encontrar SB1 correspondente continuo
	SB1->(DbSetOrder (1))
	If (SB1->(MsSeek(xFilial("SB1")+ANT->CODIGO)))
		aArea := GetArea()
		SB5->(DbSetOrder (1))
		If (SB5->(MsSeek(xFilial("SB5")+ANT->CODIGO))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim(SB5->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty(SB5->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim(SB5->(FieldGet(FieldPos(cCpoTPFator))))))
			//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
			cUn	:= Alltrim(SB5->(FieldGet(FieldPos(cCpoUn))))
			nNewQtd := ConvUN(ANT->QUANT,cCpoFator,cCpoTpFator)
		ElseIf !Empty(cMVUNMAPA)
			//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA
			nPos := at(Alltrim(ANT->UM)+"=",cMVUNMAPA)
			If nPos > 0
				cUn := Substr(cMVUNMAPA,nPos+2,Len(cMVUNMAPA))
				If at("/",cUn) > 0
					nPos := at("/",cUn)-1
					cUn := Substr( cUn,1 , nPos )
				EndIf
				cUn := Substr( cUn,at("=",cUn)+1,Len(cUn))
				nNewQtd := ConvUN(ANT->QUANT)
			Else
				cUn := ANT->UM
			Endif
		Else
			cUn := ANT->UM
		Endif
	Endif
	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a chave para aglutinacao por descricao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lMvAglut
		cChv := ANT->CODIGO
	Else
		If !Empty(cDescPR) .And. lMvAglut
			cChv := PadR(cDescPR,Len(TPR->DESCR_PROD))+Padr(Alltrim(ANT->NCM),TamSX3("B1_POSIPI")[01])+PadR(ANT->UM,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
		Else
			cChv := PadR(ANT->DESC_PRD,Len(TPR->DESCR_PROD))+Padr(Alltrim(ANT->NCM),TamSX3("B1_POSIPI")[01])+PadR(ANT->UM,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
		EndIf
	EndIf

	If !TPR->(MsSeek(cChv))

		SB1->(MsSeek(xFilial("SB1")+ANT->CODIGO))

		// Faixa de grupos
		If !(SB1->B1_GRUPO>=cGrpDe .And. SB1->B1_GRUPO<=cGrpAte)
			ANT->(DbSkip())
			Loop
		EndIf

		RecLock("TPR",.T.)
		TPR->COD_PROD	:= Left(ANT->CODIGO,15)
		TPR->CODPESQ	:= ANT->CODIGO
		TPR->CONCENT	:= nConcent
		TPR->DENSID		:= nDensid
		TPR->UN			:= cUn
		TPR->NCM		:= ANT->NCM
		TPR->GRUPO		:= SB1->B1_GRUPO
		TPR->EMISS		:= dDtIni
		TPR->QT_EST_ANT	:= ANT->QUANT
		If !Empty(cDescPR) .And. lMvAglut
			TPR->DESCR_PROD	:= cDescPR
		Else
			TPR->DESCR_PROD	:= ANT->DESC_PRD
		EndIf
	Else
		RecLock("TPR",.F.)
		If lMvAglut
			TPR->QT_EST_ANT	+= ANT->QUANT
		EndIf
	Endif

	MsUnLock()

	ANT->(dbSkip())
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere os produtos que nao tiverem movimentacao mas que possuem³
//³estoque no Anexo XI-A - saldo atual                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ATU->(dbGoTop())
Do While !ATU->(Eof())

	SB5->(dbSetOrder(1))
	SB5->(MsSeek(xFilial("SB5")+ATU->CODIGO))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Concentracao e densidade do produto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nConcent := SB5->B5_CONCENT
	nDensid  := SB5->B5_DENSID

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descrição MV_DESCPR do produto     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMVDESCPR) .And. SB5->(FieldPos(cMVDESCPR)) > 0
		cDescPR := Alltrim(SB5->(FieldGet(FieldPos(cMVDESCPR))))
	EndIf

	//Se encontrar SB1 correspondente continuo
	SB1->(DbSetOrder (1))
	If (SB1->(MsSeek(xFilial("SB1")+ATU->CODIGO)))
		aArea := GetArea()
		SB5->(DbSetOrder (1))
		If (SB5->(MsSeek(xFilial("SB5")+ATU->CODIGO))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim(SB5->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty(SB5->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim(SB5->(FieldGet(FieldPos(cCpoTPFator))))))
			//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
			cUn	:= Alltrim(SB5->(FieldGet(FieldPos(cCpoUn))))
			nNewQtd := ConvUN(ATU->QUANT,cCpoFator,cCpoTpFator)
		ElseIf !Empty(cMVUNMAPA)
			//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA
			nPos := at(Alltrim(ATU->UM)+"=",cMVUNMAPA)
			If nPos > 0
				cUn := Substr(cMVUNMAPA,nPos+2,Len(cMVUNMAPA))
				If at("/",cUn) > 0
					nPos := at("/",cUn)-1
					cUn := Substr( cUn,1 , nPos )
				EndIf
				cUn := Substr( cUn,at("=",cUn)+1,Len(cUn))
				nNewQtd := ConvUN(ATU->QUANT)
			Else
				cUn := ATU->UM
			Endif
		Else
			cUn := ATU->UM
		Endif
	Endif
	RestArea(aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a chave para aglutinacao por descricao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lMvAglut
		cChv := ATU->CODIGO
	Else
		If !Empty(cDescPR) .And. lMvAglut
			cChv := PadR(cDescPR,Len(TPR->DESCR_PROD))+Padr(Alltrim(ATU->NCM),TamSX3("B1_POSIPI")[01])+PadR(ATU->UM,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
		Else
			cChv := PadR(ATU->DESC_PRD,Len(TPR->DESCR_PROD))+Padr(Alltrim(ATU->NCM),TamSX3("B1_POSIPI")[01])+PadR(ATU->UM,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
		EndIf
	EndIf

	If !TPR->(MsSeek(cChv))

		SB1->(MsSeek(xFilial("SB1")+ATU->CODIGO))

		// Faixa de grupos
		If !(SB1->B1_GRUPO>=cGrpDe .And. SB1->B1_GRUPO<=cGrpAte)
			ATU->(DbSkip())
			Loop
		EndIf

		RecLock("TPR",.T.)
		TPR->COD_PROD	:= Left(ATU->CODIGO,15)
		TPR->CODPESQ	:= ATU->CODIGO
		TPR->CONCENT	:= nConcent
		TPR->DENSID		:= nDensid
		TPR->UN			:= cUn
		TPR->NCM		:= ATU->NCM
		TPR->GRUPO		:= SB1->B1_GRUPO
		TPR->EMISS		:= dDtIni
		TPR->QT_EST_ATU	:= ATU->QUANT
		If !Empty(cDescPR) .And. lMvAglut
			TPR->DESCR_PROD	:= cDescPR
		Else
			TPR->DESCR_PROD	:= ATU->DESC_PRD
		EndIf
	Else
		RecLock("TPR",.F.)
		If lMvAglut
			TPR->QT_EST_ATU	+= ATU->QUANT
		EndIf
	Endif

	MsUnLock()

	ATU->(dbSkip())
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui arquivos de estoque gerados                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MapasEst(2,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MapasArqs ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 22.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MapasArqs(dDtIni,dDtFim)

Local aStru		:= {}
Local aTRBs		:= {}
Local lMvAglut	:= GetNewPar("MV_AGLUTPR", .F.)
Local oTmpTblTPR
Local oTmpTblTSP
Local oTmpTblTPF
Local oTmpTblTMV
Local oTmpTblTIE
Local oTmpTblTAM
Local oTmpTblTRE
Local oTmpTblTTP
Local oTmpTblTMA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPR - Tabela de Produtos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"COD_PROD"		,"C",15,0})							//Codigo do Produto a ser apresentado no meio magnetico
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})
AADD(aStru,{"DESCR_PROD"	,"C",70,0})
AADD(aStru,{"CONCENT"		,"N",06,2})
AADD(aStru,{"DENSID"		,"N",06,2})
AADD(aStru,{"QT_EST_ANT"	,"N",20,3})
AADD(aStru,{"QT_PRODUZ"		,"N",20,3})
AADD(aStru,{"QT_TRANSF"		,"N",20,3})
AADD(aStru,{"QT_UTILIZ"		,"N",20,3})
AADD(aStru,{"QT_COMPRAS"	,"N",20,3})
AADD(aStru,{"QT_VENDAS"		,"N",20,3})
AADD(aStru,{"QT_RECICLA"	,"N",20,3})
AADD(aStru,{"QT_REAPROV"	,"N",20,3})
AADD(aStru,{"QT_IMPORT"		,"N",20,3})
AADD(aStru,{"QT_EXPORT"		,"N",20,3})
AADD(aStru,{"QT_PERDAS"		,"N",20,3})
AADD(aStru,{"QT_EVAPORA"	,"N",20,3})
AADD(aStru,{"QT_ENT_DIV"	,"N",20,3})
AADD(aStru,{"QT_SAI_DIV"	,"N",20,3})
AADD(aStru,{"QT_EST_ATU"	,"N",20,3})
AADD(aStru,{"UN"			,"C",06,0})
AADD(aStru,{"GRUPO"			,"C",06,0})
AADD(aStru,{"EMISS"			,"D",08,0})

oTmpTblTPR := FWTemporaryTable():New( "TPR" )
oTmpTblTPR:SetFields( aStru )
If lMvAglut
	oTmpTblTPR:AddIndex('I1', {"DESCR_PROD" ,"NCM" ,"UN" ,"CONCENT" ,"DENSID"})
Else
	oTmpTblTPR:AddIndex('I1', {"CODPESQ"})
EndIf
oTmpTblTPR:Create()

aAdd(aTrbs ,{oTmpTblTPR:GetRealName() ,oTmpTblTPR:GetAlias() ,oTmpTblTPR})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TMV - Tabela de Movimentacao de Produtos Quimicos            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"COD_PROD"		,"C",15,0})							//Codigo do Produto a ser apresentado no meio magnetico
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"DIA"			,"C",02,0})
AADD(aStru,{"CFOP"			,"C",05,0})
AADD(aStru,{"CONCENT"		,"N",06,2})
AADD(aStru,{"QTDE"			,"N",20,3})
AADD(aStru,{"UN"			,"C",06,0})
AADD(aStru,{"NFISCAL"		,"C",10,0})
AADD(aStru,{"CNPJ_CF"		,"C",14,0})		//CNPJ Cliente/Forcedor
AADD(aStru,{"CNPJ_T"		,"C",14,0})		//CNPJ Transportadora
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})		//Com mascara (Ex: 2915.90.90)
AADD(aStru,{"DESCR_PROD"	,"C",70,0})
AADD(aStru,{"GRUPO"			,"C",06,0})
AADD(aStru,{"EMISS"			,"D",08,0})
AADD(aStru,{"CLIEFOR"		,"C",40,0})

oTmpTblTMV := FWTemporaryTable():New( "TMV" )
oTmpTblTMV:SetFields( aStru )
If lMvAglut
	oTmpTblTMV:AddIndex('I1', {"NFISCAL" ,"DESCR_PROD" ,"NCM" ,"UN" ,"CONCENT" ,"CFOP"})
Else
	oTmpTblTMV:AddIndex('I1', {"NFISCAL"})
EndIf
oTmpTblTMV:Create()

aAdd(aTrbs ,{oTmpTblTMV:GetRealName() ,oTmpTblTMV:GetAlias() ,oTmpTblTMV})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TSP - Tabela de Substancia Presente                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"CODIGO"		,"C",TamSx3("B1_COD")[01],0})
AADD(aStru,{"CONCENT"		,"N",06,2})
AADD(aStru,{"CNPJ_CF"		,"C",14,0})		//CNPJ Cliente/Forcedor
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})		//Com mascara (Ex: 2915.90.90)
AADD(aStru,{"DESCR_PROD"	,"C",70,0})
AADD(aStru,{"ORDEM"			,"C",03,0})
AADD(aStru,{"QUANT"			,"N",020,3})

oTmpTblTSP := FWTemporaryTable():New( "TSP" )
oTmpTblTSP:SetFields( aStru )
oTmpTblTSP:AddIndex('I1', {"CODPESQ"})
oTmpTblTSP:AddIndex('I2', {"CODIGO"})
oTmpTblTSP:Create()

aAdd(aTrbs ,{oTmpTblTSP:GetRealName() ,oTmpTblTSP:GetAlias() ,oTmpTblTSP})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPF - Tabela de Produto Final                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"CODIGO"		,"C",TamSx3("B1_COD")[01],0})
AADD(aStru,{"CONCENT"		,"N",06,2})
AADD(aStru,{"CNPJ_CF"		,"C",14,0})		//CNPJ Cliente/Forcedor
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})		//Com mascara (Ex: 2915.90.90)
AADD(aStru,{"DESCR_PROD"	,"C",70,0})
AADD(aStru,{"QTDE"			,"N",020,3})
AADD(aStru,{"UN"			,"C",006,0})
AADD(aStru,{"DENSID"		,"N",06,2})

oTmpTblTPF := FWTemporaryTable():New( "TPF" )
oTmpTblTPF:SetFields( aStru )
If lMvAglut
	oTmpTblTPF:AddIndex('I1', {"DESCR_PROD" ,"NCM" ,"UN" ,"CONCENT" ,"DENSID"})
Else
	oTmpTblTPF:AddIndex('I1', {"CODPESQ"})
EndIf
oTmpTblTPF:AddIndex('I2', {"CODIGO"})
oTmpTblTPF:Create()
aAdd(aTrbs ,{oTmpTblTPF:GetRealName() ,oTmpTblTPF:GetAlias() ,oTmpTblTPF})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TIE - Tabela Importacao e Exportacao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"COD_PROD"		,"C",15,0})							//Codigo do Produto a ser apresentado no meio magnetico
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"CONCENT"		,"N",006,2})
AADD(aStru,{"QTDE"			,"N",020,3})
AADD(aStru,{"UN"			,"C",006,0})
AADD(aStru,{"LI_RE"			,"C",020,0})	//Licenca de Importacao ou Registro de Exportacao
AADD(aStru,{"NFISCAL"		,"C",010,0})
AADD(aStru,{"CNPJ_T"		,"C",014,0})	//CNPJ Transportadora
AADD(aStru,{"NOME_IE"		,"C",100,0})	//Nome do Importador / Exportador
AADD(aStru,{"PAIS"			,"C",003,0})
AADD(aStru,{"IMP_EXP"		,"C",001,0})	//I-Importacao ou E-Exportacao
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})	//Com mascara (Ex: 2915.90.90)
AADD(aStru,{"DESCR_PROD"	,"C",070,0})
AADD(aStru,{"EMISS"			,"D",008,0})

oTmpTblTIE := FWTemporaryTable():New( "TIE" )
oTmpTblTIE:SetFields( aStru )
oTmpTblTIE:AddIndex('I1', {"CODPESQ"})
oTmpTblTIE:Create()
aAdd(aTrbs ,{oTmpTblTIE:GetRealName() ,oTmpTblTIE:GetAlias() ,oTmpTblTIE})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ANEXO XI-D: TAM - Tabela de Armazenagem de Produtos Quimicos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"COD_PROD"		,"C",15,0})							//Codigo do Produto a ser apresentado no meio magnetico
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})
AADD(aStru,{"DESCR_PROD"	,"C",70,0})
AADD(aStru,{"CONCENT"		,"N",06,2})
AADD(aStru,{"QT_EST_ANT"	,"N",20,3})
AADD(aStru,{"QT_EST_ATU"	,"N",20,3})
AADD(aStru,{"UN"			,"C",06,0})
AADD(aStru,{"CNPJ"			,"C",14,0})
AADD(aStru,{"EMISS"			,"D",08,0})

oTmpTblTAM := FWTemporaryTable():New( "TAM" )
oTmpTblTAM:SetFields( aStru )
oTmpTblTAM:AddIndex('I1', {"DESCR_PROD","CNPJ"})
oTmpTblTAM:AddIndex('I2', {"CODPESQ","CNPJ"})
oTmpTblTAM:Create()
aAdd(aTrbs ,{oTmpTblTAM:GetRealName() ,oTmpTblTAM:GetAlias() ,oTmpTblTAM})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ANEXO XI-F: TTP - Tabela Transporte                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"COD_TP"		,"C",2,0})
AADD(aStru,{"CNPJ"			,"C",14,0})
AADD(aStru,{"ANO"			,"C",04,0})
AADD(aStru,{"MES"			,"C",03,0})
AADD(aStru,{"DIA"			,"C",02,0})
AADD(aStru,{"CONCENT"		,"N",06,3})
AADD(aStru,{"QTD"			,"N",20,3})
AADD(aStru,{"UN"			,"C",06,0})
AADD(aStru,{"NFISCAL"		,"C",TamSx3("F3_NFISCAL")[01],0}) //Retorna quantidade de caractere do campos F3_NFISCAL da SX3
AADD(aStru,{"COD_EMB"		,"C",14,0})
AADD(aStru,{"UF_EMB"		,"C",2,0})
AADD(aStru,{"COD_DEST"		,"C",14,0})
AADD(aStru,{"UF_DEST"		,"C",2,0})
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})		//Com mascara (Ex: 2915.90.90)
AADD(aStru,{"DESCR_PROD"	,"C",70,0})

oTmpTblTTP := FWTemporaryTable():New( "TTP" )
oTmpTblTTP:SetFields( aStru )
oTmpTblTTP:AddIndex('I1', {"NFISCAL","DESCR_PROD","CNPJ"})
oTmpTblTTP:Create()
aAdd(aTrbs ,{oTmpTblTTP:GetRealName() ,oTmpTblTTP:GetAlias() ,oTmpTblTTP})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TMA - Tabela Movimento de Armazenagem de Prods. Quimicos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"COD_PROD"		,"C",15,0})							//Codigo do Produto a ser apresentado no meio magnetico
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"DIA"			,"C",02,0})
AADD(aStru,{"E_S"			,"C",01,0})		//E-Entrada/S-Saida
AADD(aStru,{"QTDE"			,"N",20,3})
AADD(aStru,{"UN"			,"C",06,0})
AADD(aStru,{"NFISCAL"		,"C",10,0})
AADD(aStru,{"CNPJ"			,"C",14,0})
AADD(aStru,{"CNPJ_T"		,"C",14,0})		//CNPJ Transportadora
AADD(aStru,{"CONCENT"		,"N",06,2})
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})
AADD(aStru,{"RAZSOC"		,"C",70,0})		//Razao Social do Proprietario
AADD(aStru,{"EMISS"			,"D",08,0})
AADD(aStru,{"CLIEFOR"		,"C",40,0})

oTmpTblTMA := FWTemporaryTable():New( "TMA" )
oTmpTblTMA:SetFields( aStru )
oTmpTblTMA:AddIndex('I1', {"NFISCAL","RAZSOC"})
oTmpTblTMA:Create()
aAdd(aTrbs ,{oTmpTblTMA:GetRealName() ,oTmpTblTMA:GetAlias() ,oTmpTblTMA})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TRE - Tabela Residuo                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD(aStru,{"CODPRPRS"		,"C",006,0})
AADD(aStru,{"CONCENT"		,"N",006,2})
AADD(aStru,{"QTDE"			,"N",020,3})
AADD(aStru,{"UN"			,"C",006,0})
AADD(aStru,{"DESTINA"		,"C",025,0})
AADD(aStru,{"NCM"			,"C",TamSx3("B1_POSIPI")[01],0})
AADD(aStru,{"DESCR_PROD"	,"C",070,0})
AADD(aStru,{"COD_PROD"		,"C",15,0})							//Codigo do Produto a ser apresentado no meio magnetico
AADD(aStru,{"CODPESQ"		,"C",TamSx3("B1_COD")[01],0})		//Codigo do Produto para pesquisa
AADD(aStru,{"EMISS"			,"D",008,0})
AADD(aStru,{"CLIEFOR"		,"C",040,0})
AADD(aStru,{"CNPJ_CF"		,"C",014,0})
AADD(aStru,{"E_S"			,"C",001,0})

oTmpTblTRE := FWTemporaryTable():New( "TRE" )
oTmpTblTRE:SetFields( aStru )
oTmpTblTRE:AddIndex('I1', {"CODPESQ"})
oTmpTblTRE:Create()
aAdd(aTrbs ,{oTmpTblTRE:GetRealName() ,oTmpTblTRE:GetAlias() ,oTmpTblTRE})

Return(aTRBs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mes       ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 22.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o mes com 3 caracteres                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mes(dDtIni)

Local cMes := ""

cMes := left(MesExtenso(dDtIni),3)

Return(cMes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MapasMov  ³ Autor ³ Mary C. Hergert       ³ Data ³09/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao ira retornar os movimentos do periodo,          ³±±
±±³          ³com as consideracoes para a geracao do arquivo magnetico e  ³±±
±±³          ³relatorio do Mapas de Produtos Quimicos Controlados.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Tipo (E=Entradas/S=Saidas/O=Outros (Producao)       ³±±
±±³          ³ExpL2 = Gera relatotio (T=relatorio/F=arquivo magnetico)    ³±±
±±³          ³ExpD3 = Data inicial de geracao das informacoes             ³±±
±±³          ³ExpD4 = Data final de geracao das informacoes               ³±±
±±³          ³ExpC5 = Grupo de produtos inicial para processamento        ³±±
±±³          ³ExpC6 = Grupo de produtos final para processamento          ³±±
±±³          ³ExpC7 = Codigo de produto inicial para processamento        ³±±
±±³          ³ExpC8 = Codigo de produto final para processamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Mapas e Matr913                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MapasMov(cTipo,lRelat,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

Local cAliasSD2	:= "SD2"
Local cAliasSB1	:= "SB1"
Local cAliasSF4	:= "SF4"
Local cAliasSF2	:= "SF2"
Local cAliasSB5	:= "SB5"
Local cAliasSD1	:= "SD1"
Local cAliasSF1	:= "SF1"
Local cAliasSD3	:= "SD3"
Local cAliasSC2	:= "SC2"
Local cAliasPF	:= "SD3"
Local cCpoB5	:= SuperGetMv("MV_PRODPF",.F.,"")
Local cCpoB5Emb	:= SuperGetMv("MV_PRODEM",.F.,"")
Local cMVGRP2PRO:= SuperGetMv("MV_GRP2PRO",.F.,"")
//Grupo de Produtos de Residuo
Local cGrupRes	:= SuperGetMv("MV_GRUPRES",.F.,"")
Local cCNPJ		:= Space(14)
Local cCNPJT	:= Space(14)
Local cUFT		:= ""
Local cRazSoc	:= ""
Local cCodPais	:= ""
Local cUn		:= ""
Local cRe		:= ""
Local cCFOVenda	:= "101/102/103/104/105/106/107/108/109/110/111/112/113/114/115/116/117/118/119/120/122/123/251/252/253/254/255/256/257/258/401/402/403/404/405/551/"
Local cCFOCompra:= "101/102/111/113/116/117/118/120/121/122/126/251/252/253/254/255/259/257/401/403/406/407/551/556/"
//Campo D2 - Exportacao (Sem Integracao EEC)
Local cD2_Re	:= SuperGetMv("MV_EX",.F.,"")
//Campo D1 - Importacao (Sem Integracao EIC)
Local cD1_Li	:= SuperGetMv("MV_LI",.F.,"")
//Licenca de Importacao
Local cLi		:= ""
//Produto da Lista IV que so devera ser controlado em exportacao e importacao
Local cMapIV	:= GetNewPar("MV_MAPIV","")
//CFOPs que deverao ser desconsiderados no processamento
Local cMapCfop	:= GetNewPar("MV_MAPCFO","")
//Tabela para busca do cadastro da transportadora
Local cMapTrans	:= GetNewPar("MV_MAPTRAN","1")

Local nCodPCli	:= SA1->(FieldPos(GetNewPar("MV_MAPPC","")))
Local nCodPFor	:= SA2->(FieldPos(GetNewPar("MV_MAPPF","")))

Local lQuery	:= .F.
Local lMv_Easy	:= SuperGetMv("MV_EASY") == "S"
Local lMv_EEC	:= SuperGetMv("MV_EECFAT",.F.,.F.)
Local lRe		:= !Empty(cD2_RE) .And. SD2->(FieldPos(cD2_RE)) > 0
Local lD1_Li	:= !Empty(cD1_Li) .And. SD1->(FieldPos(cD1_Li)) > 0
Local lMapIV	:= !Empty(cMapIV) .And. SB5->(FieldPos(cMapIV)) > 0
Local lGerRegs	:= .F.
Local aOP		:= {}

Local nDensPF	:= 0
Local nConcPF	:= 0
Local nConcSP	:= 0

Local nEstqAnt	:= 0
Local nEstqAtu	:= 0
Local nVendas	:= 0
Local nExporta	:= 0
Local nSdiver	:= 0
Local nConcent	:= 0
Local nDensid	:= 0
Local nCompras	:= 0
Local nImporta	:= 0
Local nEdiver	:= 0
Local nProduz	:= 0
Local nUtiliza	:= 0
Local nTotPrd	:= 0
Local cGrupo	:= ""
Local cChv		:= ""
Local lMvAglut	:= GetNewPar ("MV_AGLUTPR",.F.)
Local lConsDup	:= GetNewPar ("MV_CONSDUP",.F.)
Local cMVUNMAPA	:= GetNewPar ("MV_UNMAPA" ,"" )
Local lEmptran	:= GetNewPar ("MV_EMPTRAN",.F.)
Local lIntTms	:= GetNewPar ("MV_INTTMS" ,.F.)
Local cMVDESCPR	:= GetNewPar ("MV_DESCPR" ,"" )
Local cMVCPOMAPA:= GetNewPar ("MV_CPOMAPA","" )
Local cCondic	:= ""
Local cDescPR	:= ""
Local cCpoUn	:= ""
Local cCpoFator	:= ""
Local cCpoTpFator:= ""
Local aArea		:= {}
Local nNewQtd	:= 0
Local nNewQtdAtu:= 0
Local lBuscaG1	:= .T.
Local nPos		:= 0
Local nPosFinal	:= 0
Local cQuery	:= Nil
Local cConcat	:= MatiConcat()
Local cCoalesce	:= MatIsNull()
Local aValArea := {}

#IFDEF TOP
	Local cCampos	:= ""
#ELSE
	Local cArqInd	:= ""
	Local cChave	:= ""
#ENDIF

Local aRecord

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando todas as ocorrencias do parametro MV_MAPCFO no SX6³
//³para compor os CFOPs a serem desconsiderados no processamento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX6->(dbGoTop())
SX6->(MsSeek(xFilial("SX6")+"MV_MAPCFO"))
Do While !SX6->(Eof()) .And. xFilial("SX6") == SX6->X6_FIL .And. "MV_MAPCFO" $ SX6->X6_VAR
	cMapCfop += "/" + SX6->X6_CONTEUD
	SX6->(dbSkip())
Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando todos os campos do parametro MV_CPOMAPA para compor
//³a unidade de medida que será levada para o arquivo Mapas.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMVCPOMAPA)
	nPos := 01
	nPosFinal := AT('/',Alltrim(cMVCPOMAPA))
	cCpoUn    := Substr(cMVCPOMAPA,nPos,nPosFinal - 1)
	nPos      := nPos + nPosFinal
	nPosFinal := AT('/',Alltrim(Substr(cMVCPOMAPA,nPos,Len(Alltrim(cMVCPOMAPA)))))
	cCpoFator := Substr(cMVCPOMAPA,nPos,nPosFinal - 1)
	nPos      := nPos + nPosFinal
	nPosFinal := AT('/',Alltrim(Substr(cMVCPOMAPA,nPos,Len(Alltrim(cMVCPOMAPA)))))
	If nPosFinal == 0
		cCpoTpFator := Substr(cMVCPOMAPA,nPos,Len(Alltrim(cMVCPOMAPA)))
	Else
		cCpoTpFator := Substr(cMVCPOMAPA,nPos,nPosFinal - 1)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos e consideracoes que deverao ser analisadas referentes ao SB5 de acordo com os parametros da rotina - TOP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
// Indicacao de produto controlado ou nao
If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
	cCondic += " AND SB5." + Alltrim(cCpoB5) + " = 'S' "
Endif
// Grupo Auxiliar
If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
	cCondic += " AND SB5." + Alltrim(cMVGRP2PRO) + " >= '" + cGrpDe + "' "
	cCondic += " AND SB5." + Alltrim(cMVGRP2PRO) + " <= '" + cGrpAte + "' "
Endif
// Concentracao do produto
cCampos += " ,SB5.B5_CONCENT "
// Densidade do produto
cCampos += " ,SB5.B5_DENSID "

// Descrição utilizada no parametro MV_DESCPR
If !Empty(cMVDESCPR) .And. SB5->(FieldPos(cMVDESCPR)) > 0
	cCampos += " ,SB5." + Alltrim(cMVDESCPR)
EndIf

If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
	cCampos += " ,SB5." + Alltrim( cMVGRP2PRO )
EndIf

If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
	cCampos += " ,SB5." + Alltrim( cCpoB5 )
EndIf


// Produto constante na Lista IV da Portaria 1274/2003
If lMapIV
	cCampos += " ,SB5." + Alltrim(cMapIV)
Endif
// Indicação de unidade de medida especifica para o Mapas
If    !Empty(cCpoUN)      .And. SB5->(FieldPos(cCpoUN))>0 ;
.And. !Empty(cCpoFator)   .And. SB5->(FieldPos(cCpoFator))>0 ;
.And. !Empty(cCpoTpFator) .And. SB5->(FieldPos(cCpoTpFator))>0
	cCampos += " ,SB5." + Alltrim(cCpoUN)
	cCampos += " ,SB5." + Alltrim(cCpoFator)
	cCampos += " ,SB5." + Alltrim(cCpoTpFator)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que serao adicionados a query somente se existirem na base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Nas saidas
If cTipo == "S"
	If lIntTms
		cCampos += " ,'' AS D2_PREEMB"
		If lRe
			cCampos += ",'' AS " + cD2_Re
		EndIf
	Else
		cCampos += " ,SD2.D2_PREEMB"
		If lRe
			cCampos += " ,SD2." + cD2_Re
		EndIf
	Endif
Endif
// Nas entradas
If cTipo == "E"
	cCampos += " ,SD1.D1_CONHEC"
	If lD1_Li
		cCampos += " ,SD1." + cD1_Li
	Endif
Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processando os movimentos de saida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "S"

	#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cCampos		:= "%" + cCampos + "%"
		cCondic		:= "%" + cCondic + "%"
		lQuery		:= .T.
		cAliasSD2	:= GetNextAlias()
		cAliasSB1	:= cAliasSD2
		cAliasSF4	:= cAliasSD2
		cAliasSF2	:= cAliasSD2
		cAliasSB5	:= cAliasSD2
		If lIntTms
			BeginSql Alias cAliasSD2
				COLUMN F2_EMISSAO AS DATE
				SELECT
					DTC.DTC_PESO AS D2_QUANT, DTC.DTC_CF AS D2_CF,'S' AS F4_DUPLIC, DTC.DTC_NUMNFC AS NUMDOC,
					REM.A1_CGC AS CGCREM, REM.A1_EST AS ESTREM,
					DES.A1_CGC AS CGCDES, DES.A1_EST AS ESTDES,
					SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_GRUPO,
					SF2.F2_DOC, SF2.F2_TIPO, SF2.F2_TRANSP, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPO, SF2.F2_EMISSAO
					%Exp:cCampos%
				FROM
					%table:DT6% DT6,
					%table:DTC% DTC,
					%table:SF2% SF2,
					%table:SA1% REM,
					%table:SA1% DES,
					%table:SB1% SB1,
					%table:SB5% SB5
				WHERE
					DT6_FILIAL = %xFilial:DT6% AND
					DT6.DT6_FILDOC = DTC.DTC_FILDOC AND
					DT6.DT6_DOC = DTC.DTC_DOC AND
					DT6.DT6_SERIE = DTC.DTC_SERIE AND
					DT6.DT6_DATEMI >= %Exp:dDtIni% AND DT6.DT6_DATEMI <= %Exp:dDtFim% AND
					DTC_FILIAL = %xFilial:DTC% AND
					DTC.DTC_CODPRO >= %Exp:cProdDe% AND DTC.DTC_CODPRO <= %Exp:cProdAte% AND
					DTC.%NotDel% AND
					DT6.DT6_FILDOC = SF2.F2_FILIAL AND
					DT6.DT6_DOC = SF2.F2_DOC AND
					DT6.DT6_SERIE = SF2.F2_SERIE AND
					DT6.DT6_CLIDEV = SF2.F2_CLIENTE AND
					DT6.DT6_LOJDEV = SF2.F2_LOJA AND
					DT6.D_E_L_E_T_ = ' ' AND
					SF2.%NotDel% AND
					REM.A1_FILIAL = %xFilial:SA1% AND
					REM.A1_COD = DT6.DT6_CLIREM AND
					REM.A1_LOJA = DT6.DT6_LOJREM AND
					REM.%NotDel% AND
					DES.A1_FILIAL = %xFilial:SA1% AND
					DES.A1_COD = DT6.DT6_CLIDES AND
					DES.A1_LOJA = DT6.DT6_LOJDES AND
					DES.%NotDel% AND
					SB1.B1_FILIAL = %xFilial:SB1% AND
					SB1.B1_COD = DTC.DTC_CODPRO AND
					SB1.B1_GRUPO BETWEEN %Exp:cGrpDe% AND %Exp:cGrpAte% AND
					SB1.%NotDel% AND
					SB5.B5_FILIAL = %xFilial:SB5% AND
					SB5.B5_COD = SB1.B1_COD
					%Exp:cCondic%
					AND SB5.%NotDel%
				ORDER BY DT6.DT6_FILIAL,DT6.DT6_DATEMI
			EndSql
		Else
			BeginSql Alias cAliasSD2
				COLUMN F2_EMISSAO AS DATE
				SELECT
					SD2.D2_FILIAL,SD2.D2_COD,SD2.D2_TES,SD2.D2_LOCAL,SD2.D2_CF,SD2.D2_QUANT,
					SF4.F4_DUPLIC,SF4.F4_ESTOQUE,SB1.B1_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_POSIPI,SB1.B1_GRUPO,
					SF2.F2_DOC,SF2.F2_TIPO,SF2.F2_TRANSP,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_TIPO,SF2.F2_EMISSAO,SF2.F2_DOC AS NUMDOC
					%Exp:cCampos%
				FROM
					%table:SD2% SD2,
					%table:SB1% SB1,
					%table:SF4% SF4,
					%table:SF2% SF2,
					%table:SB5% SB5
				WHERE
					SD2.D2_FILIAL = %xFilial:SD2% AND
					SD2.D2_EMISSAO >= %Exp:dDtIni% AND SD2.D2_EMISSAO <= %Exp:dDtFim% AND
					SD2.D2_COD >= %Exp:cProdDe% AND	SD2.D2_COD <= %Exp:cProdAte% AND
					SD2.%NotDel% AND
					SF2.F2_FILIAL = %xFilial:SF2% AND
					SF2.F2_DOC = SD2.D2_DOC AND
					SF2.F2_SERIE = SD2.D2_SERIE AND
					SF2.F2_CLIENTE = SD2.D2_CLIENTE AND
					SF2.F2_LOJA = SD2.D2_LOJA AND
					SF2.%NotDel% AND
					SB1.B1_FILIAL = %xFilial:SB1% AND
					SB1.B1_COD = SD2.D2_COD AND
					SB1.B1_GRUPO >= %Exp:cGrpDe% AND SB1.B1_GRUPO <= %Exp:cGrpAte% AND
					SB1.%NotDel% AND
					SB5.B5_FILIAL = %xFilial:SB5% AND
					SB5.B5_COD = SB1.B1_COD
					%Exp:cCondic%
					AND SB5.%NotDel% AND
					SD2.D2_TES = SF4.F4_CODIGO AND
					SF4.F4_ESTOQUE = 'S' AND
					SF4.F4_FILIAL = %xFilial:SF4% AND
					SF4.%NotDel%
				ORDER BY SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_NUMSEQ
			EndSql
		EndIf
		dbSelectArea(cAliasSD2)
	Else
	#ENDIF
		cArqInd	:= CriaTrab(Nil,.F.)
		cChave	:= "DTOS(D2_EMISSAO)+D2_NUMSEQ"
		cCondic	:= 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
		cCondic	+= 'Dtos(D2_EMISSAO) >= "' + Dtos(dDtIni) + '" .And. Dtos(D2_EMISSAO) <= "' + Dtos(dDtFim) + '" .And. '
		cCondic	+= 'D2_COD >= "' + cProdDe + '" .And. D2_COD <= "' + cProdAte + '"'
		IndRegua(cAliasSD2,cArqInd,cChave,,cCondic,"Selecionando Registros")
		#IFNDEF TOP
		DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		(cAliasSD2)->(dbGotop())
		If !lRelat
			ProcRegua(LastRec())
		Else
			SetRegua(LastRec())
		Endif
	#IFDEF TOP
	Endif
	#ENDIF

	Do While !((cAliasSD2)->(Eof()))

		nEstqAnt	:= 0
		nEstqAtu	:= 0
		nVendas		:= 0
		nExporta	:= 0
		nSdiver		:= 0
		nNewQtd		:= 0
		cCNPJ		:= Space(14)
		cCNPJT		:= Space(14)
		cRazSoc		:= ""
		cCodPais	:= ""
		cUn			:= ""
		cRe			:= ""
		cGrupo		:= ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os CFOPs que nao devem ser processados na rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim((cAliasSD2)->D2_CF) $ cMapCfop
			(cAliasSD2)->(DbSkip())
			Loop
		Endif
		If !lQuery
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Checa o grupo do produto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(dbSetOrder(1))
			If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)))
				(cAliasSD2)->(DbSkip())
				Loop
			Endif
			// Faixa de codigos
			If !(SB1->B1_COD >= cProdDe .And. SB1->B1_COD <= cProdAte)
				(cAliasSD2)->(DbSkip())
				Loop
			EndIf
			// Faixa de grupos
			If !(SB1->B1_GRUPO>=cGrpDe .And. SB1->B1_GRUPO<=cGrpAte)
				(cAliasSD2)->(DbSkip())
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos e consideracoes que deverao ser analisadas referentes ao SB5 de acordo com os parametros da rotina - CODEBASE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Verifica a existencia do SB5
			SB5->(dbSetOrder(1))
			If !SB5->(MsSeek(xFilial("SB5")+(cAliasSD2)->D2_COD))
				(cAliasSD2)->(DbSkip())
				Loop
			Endif
			// Indicacao de produto controlado ou nao
			If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
				If SB5->&cCpoB5 <> "S"
					(cAliasSD2)->(DbSkip())
					Loop
				Endif
			Endif
			// Grupo Auxiliar
			If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
				If !((SB5->(FieldGet(FieldPos(cMVGRP2PRO))) >= cGrpde) .And. (SB5->(FieldGet(FieldPos(cMVGRP2PRO))) <= cGrpate))
					(cAliasSD2)->(DbSkip())
					Loop
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o TES do movimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(dbSetOrder(1))
			If !(SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)))
				(cAliasSD2)->(DbSkip())
				Loop
			Endif
			If SF4->F4_ESTOQUE <> "S"
				(cAliasSD2)->(DbSkip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o cabecalho do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF2->(dbSetOrder(1))
			If !(SF2->(MsSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)))
				(cAliasSD2)->(DbSkip())
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Concentracao e densidade do produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nConcent := (cAliasSB5)->B5_CONCENT
		nDensid  := (cAliasSB5)->B5_DENSID

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descrição MV_DESCPR do produto     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVDESCPR) .And. (cAliasSB5)->(FieldPos(cMVDESCPR)) > 0
			cDescPR := Alltrim((cAliasSB5)->(FieldGet(FieldPos(cMVDESCPR))))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grupo - utilizado na impressao do relatorio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
			cGrupo := (cAliasSB5)->(FieldGet(FieldPos(cMVGRP2PRO)))
		Else
			cGrupo := (cAliasSB1)->B1_GRUPO
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificando as informacoes do cliente/fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD2)->F2_TIPO$"DB"
			SA2->(dbSetOrder(1))
			If !(SA2->(MsSeek(xFilial("SA2")+(cAliasSD2)->F2_CLIENTE+(cAliasSD2)->F2_LOJA)))
				(cAliasSD2)->(DbSkip())
				Loop
			Endif
			cCNPJ    := IIf(!Empty(SA2->A2_CGC),aRetDig(SA2->A2_CGC,.F.),Space(14))
			cRazSoc  := SA2->A2_NOME
			cCodPais := Iif(nCodPFor >0,SA2->&(GetNewPar("MV_MAPPF")),Space(03))
		Else
			SA1->(dbSetOrder(1))
			If !(SA1->(MsSeek(xFilial("SA1")+(cAliasSD2)->F2_CLIENTE+(cAliasSD2)->F2_LOJA)))
				(cAliasSD2)->(DbSkip())
				Loop
			Endif
			cCNPJ    := Iif(!Empty(SA1->A1_CGC),aRetDig(SA1->A1_CGC,.F.),Space(14))
			cRazSoc  := SA1->A1_NOME
			cCodPais := Iif(nCodPCli >0,SA1->&(GetNewPar("MV_MAPPC")),Space(03))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-A: TPR - Tabela de Produtos Quimicos                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Estoque Anterior
		If ANT->(MsSeek((cAliasSD2)->B1_COD))
			nEstqAnt := ANT->QUANT
		EndIf

		//Estoque Atual
		If ATU->(MsSeek((cAliasSD2)->B1_COD))
			nEstqAtu := ATU->QUANT
		EndIf

		Do Case
			//Vendas
			Case (cAliasSF2)->F2_TIPO <> "D" .And. Left((cAliasSD2)->D2_CF,1) $ "56" .And. Substr((cAliasSD2)->D2_CF,2,3) $ cCFOVenda
				nVendas := (cAliasSD2)->D2_QUANT

			//Exportacao
			Case (cAliasSF2)->F2_TIPO <> "D" .And. (cAliasSF4)->F4_DUPLIC == "S" .And. Left((cAliasSD2)->D2_CF,1) == "7"
				nExporta := (cAliasSD2)->D2_QUANT

			//Saidas Diversas
			Otherwise
				nSdiver := (cAliasSD2)->D2_QUANT
		EndCase

		//Conversao da Unidade de Medida
		//cUn := IIf(Alltrim(Upper((cAliasSB1)->B1_UM))=="L","LITRO",Upper((cAliasSB1)->B1_UM))

		//Se encontrar SB1 correspondente continuo ou aborta o processamento
		SB1->(DbSetOrder (1))
		If (SB1->(MsSeek(xFilial("SB1")+(cAliasSD2)->B1_COD)))
			aArea := GetArea()
			SB5->(DbSetOrder (1))
			If (SB5->(MsSeek(xFilial("SB5")+(cAliasSD2)->B1_COD))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty((cAliasSB5)->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoTPFator))))))
				//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
				cUn	:= Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn))))
				nNewQtd	:= ConvUN(nEstqAnt,cCpoFator,cCpoTpFator)
				nNewQtdAtu := ConvUN(nEstqAtu,cCpoFator,cCpoTpFator)
				nVendas  := ConvUN(nVendas, cCpoFator,cCpoTpFator)
				nExporta := ConvUN(nExporta,cCpoFator,cCpoTpFator)
				nSdiver  := ConvUN(nSdiver, cCpoFator,cCpoTpFator)
			ElseIf !Empty(cMVUNMAPA)
				//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA
				nPos := at(Alltrim((cAliasSB1)->B1_UM)+"=",cMVUNMAPA)
				If nPos > 0
					cUn := Substr(cMVUNMAPA,nPos+2,Len(cMVUNMAPA))
					If at("/",cUn) > 0
						nPos := at("/",cUn)-1
						cUn := Substr( cUn,1 , nPos )
					EndIf
					cUn := Substr( cUn,at("=",cUn)+1,Len(cUn))
					nNewQtd	:= ConvUN(nEstqAnt)
					nNewQtdAtu := ConvUN(nEstqAtu)
					nVendas  := ConvUN(nVendas)
					nExporta := ConvUN(nExporta)
					nSdiver  := ConvUN(nSdiver)
				Else
					cUn := (cAliasSB1)->B1_UM
				Endif
			Else
				cUn := (cAliasSB1)->B1_UM
			Endif
		Endif
		RestArea(aArea)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Os produtos constantes na lista IV da Portaria 1274/2003 somente devem gerar³
		//³os registros de exportacao ou reexportacao.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lGerRegs := (!lMapIV) .Or. (lMapIV .And. (cAliasSB5)->(&(cMapIV)) $ " 2")

		If !lMvAglut
			cChv	:=	(cAliasSB1)->B1_COD
		Else
			If !Empty(cDescPR) .And. lMvAglut
				cChv	:=	PadR(cDescPR,Len(TPR->DESCR_PROD))+(cAliasSB1)->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
			Else
				cChv	:=	PadR((cAliasSB1)->B1_DESC,Len(TPR->DESCR_PROD))+(cAliasSB1)->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
			EndIf
		EndIf
		dbSelectArea("TPR")
		If !MsSeek(cChv)
			RecLock("TPR",.T.)
			TPR->COD_PROD	:= Left((cAliasSB1)->B1_COD,15)
			TPR->CODPESQ	:= (cAliasSB1)->B1_COD
			TPR->CONCENT	:= nConcent
			TPR->DENSID		:= nDensid
			TPR->QT_VENDAS	:= Iif(lGerRegs,nVendas,0)
			TPR->QT_EXPORT	:= nExporta
			TPR->QT_SAI_DIV	:= Iif(lGerRegs,nSdiver,0)
			TPR->UN			:= cUn
			TPR->NCM		:= (cAliasSB1)->B1_POSIPI
			TPR->GRUPO		:= cGrupo
			TPR->EMISS		:= (cAliasSD2)->F2_EMISSAO
			If !lMvAglut
				TPR->QT_EST_ANT	:= IIF(nNewQtd==0,nEstqAnt,nNewQtd)
				TPR->QT_EST_ATU	:= IIF(nNewQtdAtu==0,ATU->QUANT,nNewQtdAtu)
			Endif
			If !Empty(cDescPR) .And. lMvAglut
				TPR->DESCR_PROD	:= cDescPR
			Else
				TPR->DESCR_PROD	:= (cAliasSB1)->B1_DESC
			EndIf
		Else
			RecLock("TPR",.F.)
			TPR->QT_VENDAS		+= Iif(lGerRegs,nVendas,0)
			TPR->QT_EXPORT		+= nExporta
			TPR->QT_SAI_DIV		+= Iif(lGerRegs,nSdiver,0)
		EndIf
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-G: TRE - Tabela de Residuo                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs
			If !Empty(cGrupRes) .And. Alltrim((cAliasSB1)->B1_GRUPO) $ cGrupRes
				dbSelectArea("TRE")
				If !MsSeek((cAliasSB1)->B1_COD)
					RecLock("TRE",.T.)
					TRE->COD_PROD	:= Left((cAliasSB1)->B1_COD,15)
					TRE->CODPESQ	:= (cAliasSB1)->B1_COD
					TRE->CODPRPRS	:= "000000"
					TRE->CONCENT	:= nConcent
					TRE->QTDE		:= IIF(nNewQtdAtu==0,nEstqAtu,nNewQtdAtu)
					TRE->UN			:= cUn
					TRE->DESTINA	:= Space(25)
					TRE->NCM		:= (cAliasSB1)->B1_POSIPI
					If !Empty(cDescPR) .And. lMvAglut
						TRE->DESCR_PROD	:= cDescPR
					Else
						TRE->DESCR_PROD	:= (cAliasSB1)->B1_DESC
					EndIf
					TRE->E_S		:= "S"
					TRE->EMISS		:= (cAliasSD2)->F2_EMISSAO
					TRE->CLIEFOR	:= cRazSoc
					TRE->CNPJ_CF	:= cCNPJ
					MsUnlock()
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-B: TMV - Tabela de Movimentacao de Produtos Quimicos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs .And. !lEmptran
			SA4->(dbSetOrder(1))
			If SA4->(MsSeek(xFilial("SA4")+(cAliasSF2)->F2_TRANSP))
				cCNPJT := aRetDig(SA4->A4_CGC,.F.)
				cUFT   := SA4->A4_EST
			EndIf
			If Left((cAliasSD2)->D2_CF,1) $ "56"
				aRecord := Array(15)
				aRecord[01] := Left((cAliasSB1)->B1_COD,15)
				aRecord[02]	:= (cAliasSB1)->B1_COD
				aRecord[03]	:= StrZero(Day((cAliasSD2)->F2_EMISSAO),2)
				aRecord[04] := (cAliasSD2)->D2_CF
				aRecord[05]	:= nConcent

				aValArea := GetArea()
				SB1->(DbSetOrder (1))
				If (SB1->(MsSeek(xFilial("SB1")+(cAliasSB1)->B1_COD)))			
					SB5->(DbSetOrder (1))
					If (SB5->(MsSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty((cAliasSB5)->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoTPFator))))))
						//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
						aRecord[06]		:= IIF(nNewQtd==0,ConvUN((cAliasSD2)->D2_QUANT,cCpoFator,cCpoTpFator),nNewQtd)
						If !Empty(cMVUNMAPA)
							//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA	
							aRecord[06]	:= IIF(nNewQtd==0,ConvUN((cAliasSD2)->D2_QUANT),nNewQtd)
						End if
					Else
						aRecord[06]	:= IIF(nNewQtd==0,(cAliasSD2)->D2_QUANT,nNewQtd)
					End if
				End if	
				RestArea(aValArea)	
				aRecord[07] := cUn
				aRecord[08]	:= (cAliasSD2)->NUMDOC
				aRecord[09]	:= cCNPJ	//CNPJ Cliente/Fornecedor
				aRecord[10]	:= cCNPJT	//CNPJ Transportadora
				aRecord[11]	:= (cAliasSB1)->B1_POSIPI
				If !Empty(cDescPR) .And. lMvAglut
					aRecord[12] := cDescPR
				Else
					aRecord[12] := (cAliasSB1)->B1_DESC
				EndIf
				aRecord[13] := cGrupo
				aRecord[14] := (cAliasSF2)->F2_EMISSAO
				aRecord[15] := cRazSoc

				GravaTMV(aRecord, lMvAglut)

			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-C: TIE - Tabela de Importacao / Exportacao                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Left((cAliasSD2)->D2_CF,1) == "7"
			If !(lMv_EEC)	//Integracao
				If lRE
					cRe := (cAliasSD2)->&(cD2_Re)
				Else
					cRe := (cAliasSD2)->D2_PREEMB
				Endif
			Else
				EE9->(dbSetOrder(3))
				If EE9->(MsSeek(xFilial("EE9")+(cAliasSD2)->D2_PREEMB))
					If lRE
						cRe := (cAliasSD2)->&(cD2_Re)
					Else
						cRe := EE9->EE9_RE
					Endif
				Endif
			EndIf

			aRecord := Array(14)
			aRecord[01] := Left((cAliasSB1)->B1_COD,15)
			aRecord[02] := (cAliasSB1)->B1_COD
			aRecord[03] := nConcent
			aRecord[04] := IIF(nNewQtd==0,(cAliasSD2)->D2_QUANT,nNewQtd)
			aRecord[05] := cUn
			aRecord[06] := cRe
			aRecord[07] := (cAliasSD2)->NUMDOC
			aRecord[08] := cCNPJT	//CNPJ Transportadora
			aRecord[09] := cRazSoc	//Razao Social
			aRecord[10] := cCodPais	//Codigo do Pais
			aRecord[11] := "E"		//I-Importacao ou E-Exportacao
			aRecord[12] := (cAliasSB1)->B1_POSIPI
			If !Empty(cDescPR) .And. lMvAglut
				aRecord[13] :=cDescPR
			Else
				aRecord[13] :=(cAliasSB1)->B1_DESC
			EndIf
			aRecord[14] := (cAliasSD2)->F2_EMISSAO

			GravaTIE(aRecord)

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-D: TAM - Tabela de Armazenagem de Produtos Quimicos           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs
			If !lMvAglut
				cChv	:=	(cAliasSD2)->NUMDOC+cCNPJ
			Else
				If !Empty(cDescPR) .And. lMvAglut
					cChv	:=	PadR(cDescPR,Len(TAM->DESCR_PROD)) + PadR(cCNPJ,Len(TAM->CNPJ))
				Else
					cChv	:=	PadR(SB1->B1_DESC,Len(TAM->DESCR_PROD)) + PadR(cCNPJ,Len(TAM->CNPJ))
				EndIf
			EndIf
			dbSelectArea("TAM")
			If !TAM->(MsSeek(cChv))
				RecLock("TAM",.T.)
				TAM->COD_PROD	:= Left((cAliasSB1)->B1_COD,15)
				TAM->CODPESQ	:= (cAliasSB1)->B1_COD
				TAM->NCM		:= (cAliasSB1)->B1_POSIPI
				If !Empty(cDescPR) .And. lMvAglut
					TAM->DESCR_PROD	:= cDescPR
				Else
					TAM->DESCR_PROD	:= (cAliasSB1)->B1_DESC
				EndIf
				TAM->CONCENT	:= nConcent
				TAM->QT_EST_ANT	:= IIF(nNewQtd==0,nEstqAnt,nNewQtd)
				TAM->QT_EST_ATU	:= IIF(nNewQtdAtu==0,nEstqAtu,nNewQtdAtu)
				TAM->UN			:= cUn
				TAM->CNPJ		:= cCNPJ
				TAM->EMISS		:= (cAliasSD2)->F2_EMISSAO
				MsUnlock()
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-F: TTP - MAPA DE TRANSPORTE DE PRODUTOS QUÍMICOS              ³
		//| Se tiver Transportadora preenchida,  se o o CNPJ da transportadora é   |
		//| o mesmo do emitente do documento fiscal, e se o MV_EMPTRAN for .T.     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs .And. lEmptran .And. (lIntTms .Or. ((aFisFill(Num2Chr(Val(aRetDig(SM0->M0_CGC,.F.)),14,0),14) == cCNPJT)))
			If !lMvAglut
				cChv	:=	PadR((cAliasSD2)->NUMDOC,Len(TTP->NFISCAL))
			Else
				If !Empty(cDescPR) .And. lMvAglut
					cChv	:=	PadR((cAliasSD2)->NUMDOC,Len(TTP->NFISCAL)) + PadR(cDescPR,Len(TTP->DESCR_PROD))
				Else
					cChv	:=	PadR((cAliasSD2)->NUMDOC,Len(TTP->NFISCAL)) + PadR(SB1->B1_DESC,Len(TTP->DESCR_PROD))
				EndIf
			EndIf
			dbSelectArea("TTP")
			If !TTP->(MsSeek(cChv))
				RecLock("TTP",.T.)
				TTP->COD_TP   := "TP"
				TTP->CNPJ     := aFisFill(Num2Chr(Val(aRetDig(SM0->M0_CGC,.F.)),14,0),14)
				TTP->ANO      := CValToChar(Year((cAliasSD2)->F2_EMISSAO))
				TTP->MES      := Mes((cAliasSD2)->F2_EMISSAO)
				TTP->DIA      := StrZero(Day((cAliasSD2)->F2_EMISSAO),2)
				TTP->CONCENT  := nConcent
				TTP->QTD      := IIF(nNewQtd==0,(cAliasSD2)->D2_QUANT,nNewQtd)
				TTP->UN       := cUn  // **//
				TTP->NFISCAL  := (cAliasSD2)->NUMDOC
				TTP->COD_EMB  := Iif(lIntTMS,(cAliasSD2)->CGCREM,cCNPJT)
				TTP->UF_EMB   := Iif(lIntTMS,(cAliasSD2)->ESTREM,cUFT)
				TTP->COD_DEST := Iif(lIntTMS,(cAliasSD2)->CGCDES,SA1->A1_CGC)
				TTP->UF_DEST  := Iif(lIntTMS,(cAliasSD2)->ESTDES,SA1->A1_EST)
				TTP->NCM      := Transform((cAliasSB1)->B1_POSIPI,"@R 9999.99.99")
				If !Empty(cDescPR) .And. lMvAglut
					TTP->DESCR_PROD := cDescPR
				Else
					TTP->DESCR_PROD := (cAliasSB1)->B1_DESC
				EndIf
			Else
				RecLock("TTP",.F.)
				TTP->QTD      += IIF(nNewQtd==0,(cAliasSD2)->D2_QUANT,nNewQtd)
			EndIf
			MsUnlock()
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-E: TMA - Tabela de Movimento de Armazenagem Prods. Quimicos   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs .Or. (!lGerRegs .And. SubStr((cAliasSD2)->D2_CF,1,1) == "7")
			If !lMvAglut
				cChv	:=	PadR((cAliasSD2)->NUMDOC,Len(TMA->NFISCAL))
			Else
				If !Empty(cDescPR) .And. lMvAglut
					cChv	:=	PadR((cAliasSD2)->NUMDOC,Len(TMA->NFISCAL)) + PadR(cDescPR,Len(TMA->RAZSOC))
				Else
					cChv	:=	PadR((cAliasSD2)->NUMDOC,Len(TMA->NFISCAL)) + PadR(SB1->B1_DESC,Len(TMA->RAZSOC))
				EndIf
			EndIf
			dbSelectArea("TMA")
			If !TMA->(MsSeek(cChv))
				RecLock("TMA",.T.)
				TMA->DIA		:= StrZero(Day((cAliasSD2)->F2_EMISSAO),2)
				TMA->E_S		:= "S"	//E-Entrada / S-Saida

				aValArea := GetArea()
				SB1->(DbSetOrder (1))
				If (SB1->(MsSeek(xFilial("SB1")+(cAliasSB1)->B1_COD)))			
					SB5->(DbSetOrder (1))
					If (SB5->(MsSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty((cAliasSB5)->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoTPFator))))))
						//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
						TMA->QTDE		:= IIF(nNewQtd==0,ConvUN((cAliasSD2)->D2_QUANT,cCpoFator,cCpoTpFator),nNewQtd)
						If !Empty(cMVUNMAPA)
							//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA	
							TMA->QTDE		:= IIF(nNewQtd==0,ConvUN((cAliasSD2)->D2_QUANT),nNewQtd)
						End if
					Else
						TMA->QTDE		:= IIF(nNewQtd==0,(cAliasSD2)->D2_QUANT,nNewQtd)
					End if
				End if	
				RestArea(aValArea)	
				TMA->UN			:= cUn
				TMA->NFISCAL	:= (cAliasSD2)->NUMDOC
				TMA->CNPJ		:= cCNPJ
				TMA->CNPJ_T		:= cCNPJT
				TMA->CONCENT	:= nConcent
				TMA->NCM		:= (cAliasSB1)->B1_POSIPI
				If !Empty(cDescPR) .And. lMvAglut
					TMA->RAZSOC	:= cDescPR
				Else
					TMA->RAZSOC		:= (cAliasSB1)->B1_DESC
				EndIf
				TMA->EMISS		:= (cAliasSD2)->F2_EMISSAO
				TMA->COD_PROD	:= Left((cAliasSB1)->B1_COD,15)
				TMA->CODPESQ	:= (cAliasSB1)->B1_COD
			Else
				RecLock("TMA",.F.)
				TMA->QTDE		+= IIF(nNewQtd==0,(cAliasSD2)->D2_QUANT,nNewQtd)
			EndIf
			MsUnlock()
		Endif
		(cAliasSD2)->(dbSkip())
	EndDo

	If !lQuery
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processando os movimentos de entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "E"

	#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cCampos		:= "%" + cCampos + "%"
		cCondic		:= "%" + cCondic + "%"
		lQuery		:= .T.
		cAliasSD1	:= GetNextAlias()
		cAliasSB1	:= cAliasSD1
		cAliasSF4	:= cAliasSD1
		cAliasSF1	:= cAliasSD1
		cAliasSB5	:= cAliasSD1
		BeginSql Alias cAliasSD1
			COLUMN D1_EMISSAO AS DATE
			SELECT
				SD1.D1_FILIAL,SD1.D1_EMISSAO,SD1.D1_COD,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,
				SD1.D1_TES,SD1.D1_TIPO,SD1.D1_LOCAL,SD1.D1_CF,SD1.D1_QUANT,
				SB1.B1_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_POSIPI,SB1.B1_GRUPO,
				SF4.F4_DUPLIC,SF4.F4_ESTOQUE,
				SF1.F1_TIPO,SF1.F1_ESPECIE,SF1.F1_ORIGLAN,SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA,F1_TRANSP
				%Exp:cCampos%
			FROM
				%table:SD1% SD1,
				%table:SB1% SB1,
				%table:SF4% SF4,
				%table:SF1% SF1,
				%table:SB5% SB5
			WHERE
				SD1.D1_FILIAL = %xFilial:SD1% AND
				SD1.D1_EMISSAO >= %Exp:dDtIni% AND SD1.D1_EMISSAO <= %Exp:dDtFim% AND
				SD1.D1_COD >= %Exp:cProdDe% AND SD1.D1_COD <= %Exp:cProdAte% AND
				SD1.%NotDel% AND
				SF1.F1_FILIAL = %xFilial:SF1% AND
				SF1.F1_DOC = SD1.D1_DOC AND
				SF1.F1_SERIE = SD1.D1_SERIE AND
				SF1.F1_FORNECE = SD1.D1_FORNECE AND
				SF1.F1_LOJA = SD1.D1_LOJA AND
				SF1.%NotDel% AND
				SB1.B1_FILIAL = %xFilial:SB1% AND
				SD1.D1_COD = SB1.B1_COD AND
				SB1.B1_GRUPO >= %Exp:cGrpDe% AND SB1.B1_GRUPO <= %Exp:cGrpAte% AND
				SB1.%NotDel% AND
				SB5.B5_FILIAL = %xFilial:SB5% AND
				SB5.B5_COD = SB1.B1_COD
				%Exp:cCondic%
				AND SB5.%NotDel% AND
				SD1.D1_TES = SF4.F4_CODIGO AND
				SF4.F4_FILIAL = %xFilial:SF4% AND
				SF4.F4_ESTOQUE = 'S' AND
				SF4.%NotDel%
			ORDER BY SD1.D1_FILIAL,SD1.D1_EMISSAO,SD1.D1_NUMSEQ
		EndSql
		dbSelectArea(cAliasSD1)
	Else
	#ENDIF
		cArqInd	:= CriaTrab(Nil,.F.)
		cChave	:= "DTOS(D1_EMISSAO)+D1_NUMSEQ"
		cCondic	:= 'D1_FILIAL == "' + xFilial("SD1") + '" .And. '
		cCondic	+= 'Dtos(D1_EMISSAO) >= "' + Dtos(dDtIni) + '" .And. Dtos(D1_EMISSAO) <= "' + Dtos(dDtFim) + '" .And. '
		cCondic	+= 'D1_COD >= "' + cProdDe + '" .And. D1_COD <= "' + cProdAte + '"'
		IndRegua(cAliasSD1,cArqInd,cChave,,cCondic,"Selecionando Registros")
		#IFNDEF TOP
		DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		(cAliasSD1)->(dbGotop())
		If !lRelat
			ProcRegua(LastRec())
		Else
			SetRegua(LastRec())
		Endif
	#IFDEF TOP
	Endif
	#ENDIF

	Do While !((cAliasSD1)->(Eof()))

		nEstqAnt	:= 0
		nEstqAtu	:= 0
		nCompras	:= 0
		nImporta	:= 0
		nEdiver		:= 0
		nNewQtd		:= 0
		nNewQtdAtu	:= 0
		cCNPJ		:= Space(14)
		cCNPJT		:= Space(14)
		cRazSoc		:= ""
		cCodPais	:= ""
		cUn			:= ""
		cLi			:= ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os CFOPs que nao devem ser processados na rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim((cAliasSD1)->D1_CF) $ cMapCfop
			(cAliasSD1)->(DbSkip())
			Loop
		Endif
		If !lQuery
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Checa o grupo do produto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(dbSetOrder(1))
			If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD)))
				(cAliasSD1)->(DbSkip())
				Loop
			EndIf
			// Faixa de codigos
			If !(SB1->B1_COD >= cProdDe .And. SB1->B1_COD <= cProdAte)
				(cAliasSD1)->(DbSkip())
				Loop
			EndIf
			// Faixa de grupos
			If !(SB1->B1_GRUPO>=cGrpDe .And. SB1->B1_GRUPO<=cGrpAte)
				(cAliasSD1)->(DbSkip())
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos e consideracoes que deverao ser analisadas referentes ao SB5 de acordo com os parametros da rotina - CODEBASE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Verifica a existencia do SB5
			SB5->(dbSetOrder(1))
			If !SB5->(MsSeek(xFilial("SB5")+(cAliasSD1)->D1_COD))
				(cAliasSD1)->(DbSkip())
				Loop
			Endif
			// Indicacao de produto controlado ou nao
			If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
				If SB5->&cCpoB5 <> "S"
					(cAliasSD1)->(DbSkip())
					Loop
				Endif
			Endif
			// Grupo Auxiliar
			If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
				If !((SB5->(FieldGet(FieldPos(cMVGRP2PRO))) >= cGrpde) .And. (SB5->(FieldGet(FieldPos(cMVGRP2PRO))) <= cGrpate))
					(cAliasSD1)->(DbSkip())
					Loop
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o TES do movimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(dbSetOrder(1))
			If !(SF4->(MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES)))
				(cAliasSD1)->(DbSkip())
				Loop
			Endif
			If SF4->F4_ESTOQUE <> "S"
				(cAliasSD1)->(DbSkip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o cabecalho do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF1->(dbSetOrder(1))
			If !(SF1->(MsSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)))
				(cAliasSD1)->(DbSkip())
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Concentracao e densidade do produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nConcent := (cAliasSB5)->B5_CONCENT
		nDensid  := (cAliasSB5)->B5_DENSID

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descrição MV_DESCPR do produto     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVDESCPR) .And. (cAliasSB5)->(FieldPos(cMVDESCPR)) > 0
			cDescPR := Alltrim((cAliasSB5)->(FieldGet(FieldPos(cMVDESCPR))))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grupo - utilizado na impressao do relatorio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
			cGrupo := (cAliasSB5)->(FieldGet(FieldPos(cMVGRP2PRO)))
		Else
			cGrupo := (cAliasSB1)->B1_GRUPO
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificando as informacoes do cliente/fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD1)->D1_TIPO$"DB"
			SA1->(dbSetOrder(1))
			If !(SA1->(MsSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)))
				(cAliasSD1)->(DbSkip())
				Loop
			Endif
			cCNPJ    := IIf(!Empty(SA1->A1_CGC),aRetDig(SA1->A1_CGC,.F.),Space(14))
			cRazSoc  := SA1->A1_NOME
			cCodPais := Iif(nCodPCli >0,SA1->&(GetNewPar("MV_MAPPC")),Space(03))
		Else
			SA2->(dbSetOrder(1))
			If !(SA2->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)))
				(cAliasSD1)->(DbSkip())
				Loop
			Endif
			cCNPJ    := IIf(!Empty(SA2->A2_CGC),aRetDig(SA2->A2_CGC,.F.),Space(14))
			cRazSoc  := SA2->A2_NOME
			cCodPais := Iif(nCodPFor >0,SA2->&(GetNewPar("MV_MAPPF")),Space(03))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-A: TPR - Tabela de Produtos Quimicos                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Estoque Anterior
		If ANT->(MsSeek((cAliasSD1)->D1_COD))
			nEstqAnt := ANT->QUANT
		EndIf

		//Estoque Atual
		If ATU->(MsSeek((cAliasSD1)->D1_COD))
			nEstqAtu := ATU->QUANT
		EndIf

		Do Case
			//Compras
			Case (cAliasSF1)->F1_TIPO <> "D" .And. Left((cAliasSD1)->D1_CF,1) < "3" .And. Substr((cAliasSD1)->D1_CF,2,3) $ cCFOCompra
				nCompras := (cAliasSD1)->D1_QUANT

			//Importacao
			Case ((cAliasSF1)->F1_TIPO <> "D" .And. (cAliasSF4)->F4_DUPLIC == "S" .And. Left((cAliasSD1)->D1_CF,1) == "3") .Or. ((cAliasSF1)->F1_TIPO <> "D" .And. lConsDup .And. Left((cAliasSD1)->D1_CF,1) == "3")
				nImporta := (cAliasSD1)->D1_QUANT

			//Entradas Diversas
			Otherwise
				nEdiver := (cAliasSD1)->D1_QUANT
		EndCase

		//Conversao da Unidade de Medida
		//cUn := IIf(Alltrim(Upper((cAliasSB1)->B1_UM))=="L","LITRO",Upper((cAliasSB1)->B1_UM))

		//Se encontrar SB1 correspondente continuo ou aborta o processamento
		SB1->(DbSetOrder (1))
		If (SB1->(MsSeek(xFilial("SB1")+(cAliasSB1)->B1_COD)))
			aArea := GetArea()
			SB5->(DbSetOrder (1))
			If (SB5->(MsSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty((cAliasSB5)->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoTPFator))))))
				//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
				cUn	:= Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn))))
				nNewQtd	:= ConvUN(nEstqAnt,cCpoFator,cCpoTpFator)
				nNewQtdAtu := ConvUN(nEstqAtu,cCpoFator,cCpoTpFator)
				nCompras := ConvUN(nCompras,cCpoFator,cCpoTpFator)
				nImporta := ConvUN(nImporta,cCpoFator,cCpoTpFator)
				nEdiver  := ConvUN(nEdiver, cCpoFator,cCpoTpFator)
			ElseIf !Empty(cMVUNMAPA)
				//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA
				nPos := at(Alltrim((cAliasSB1)->B1_UM)+"=",cMVUNMAPA)
				If nPos > 0
					cUn := Substr(cMVUNMAPA,nPos+2,Len(cMVUNMAPA))
					If at("/",cUn) > 0
						nPos := at("/",cUn)-1
						cUn := Substr( cUn,1 , nPos )
					EndIf
					cUn := Substr( cUn,at("=",cUn)+1,Len(cUn))
					nNewQtd	:= ConvUN(nEstqAnt)
					nNewQtdAtu := ConvUN(nEstqAtu)
					nCompras := ConvUN(nCompras)
					nImporta := ConvUN(nImporta)
					nEdiver  := ConvUN(nEdiver)
				Else
					cUn := (cAliasSB1)->B1_UM
				Endif
			Else
				cUn := (cAliasSB1)->B1_UM
			Endif
		Endif
		RestArea(aArea)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Os produtos constantes na lista IV da Portaria 1274/2003 somente devem gerar³
		//³os registros de exportacao ou reexportacao.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lGerRegs := (!lMapIV) .Or. (lMapIV .And. (cAliasSB5)->(&(cMapIV)) $ " 2")
		If lGerRegs
			If !lMvAglut
				cChv	:=	(cAliasSB1)->B1_COD
			Else
				If !Empty(cDescPR) .And. lMvAglut
					cChv	:=	PadR(cDescPR,Len(TPR->DESCR_PROD))+(cAliasSB1)->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
				Else
					cChv	:=	PadR((cAliasSB1)->B1_DESC,Len(TPR->DESCR_PROD))+(cAliasSB1)->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
				EndIf
			EndIf
			dbSelectArea("TPR")
			If !MsSeek(cChv)
				RecLock("TPR",.T.)
				TPR->COD_PROD	:= Left((cAliasSB1)->B1_COD,15)
				TPR->CODPESQ	:= (cAliasSB1)->B1_COD
				TPR->CONCENT	:= nConcent
				TPR->DENSID		:= nDensid
				TPR->QT_COMPRAS	:= nCompras
				TPR->QT_IMPORT	:= nImporta
				TPR->QT_ENT_DIV	:= nEdiver
				TPR->UN			:= cUn
				TPR->NCM		:= (cAliasSB1)->B1_POSIPI
				TPR->GRUPO		:= cGrupo
				TPR->EMISS		:= (cAliasSD1)->D1_EMISSAO
				If !lMvAglut
					TPR->QT_EST_ANT	:= IIF(nNewQtd==0,nEstqAnt,nNewQtd)
					TPR->QT_EST_ATU	:= IIF(nNewQtdAtu==0,nEstqAtu,nNewQtdAtu)
				Endif
				If !Empty(cDescPR) .And. lMvAglut
					TPR->DESCR_PROD	:= cDescPR
				Else
					TPR->DESCR_PROD	:= (cAliasSB1)->B1_DESC
				EndIf
			Else
				RecLock("TPR",.F.)
				TPR->QT_COMPRAS		+= nCompras
				TPR->QT_IMPORT		+= nImporta
				TPR->QT_ENT_DIV		+= nEdiver
			EndIf
			MsUnlock()
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-G: TRE - Tabela de Residuo                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs
			If !Empty(cGrupRes) .And. Alltrim((cAliasSB1)->B1_GRUPO) $ cGrupRes
				dbSelectArea("TRE")
				If !MsSeek((cAliasSB1)->B1_COD)
					RecLock("TRE",.T.)
					TRE->COD_PROD   := Left((cAliasSB1)->B1_COD,15)
					TRE->CODPESQ    := (cAliasSB1)->B1_COD
					TRE->CODPRPRS   := "000000"
					TRE->CONCENT    := nConcent
					TRE->QTDE       := IIF(nNewQtdAtu==0,nEstqAtu,nNewQtdAtu)
					TRE->UN         := cUn
					TRE->DESTINA    := Space(25)
					TRE->NCM        := (cAliasSB1)->B1_POSIPI
					If !Empty(cDescPR) .And. lMvAglut
						TRE->DESCR_PROD	:= cDescPR
					Else
						TRE->DESCR_PROD := (cAliasSB1)->B1_DESC
					EndIf
					TRE->EMISS		:= (cAliasSD1)->D1_EMISSAO
					TRE->CLIEFOR	:= cRazSoc
					TRE->CNPJ_CF	:= cCNPJ
					MsUnlock()
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-B: TMV - Tabela de Movimentacao de Produtos Quimicos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs
			cCNPJT := ""
			SF8->(dbSetOrder(2))
			If SF8->(MsSeek(xFilial("SF8")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual a origem das informacoes da transportadora - SA4 ou SA2³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMapTrans == "1"
					SA4->(dbSetOrder(1))
					If SA4->(MsSeek(xFilial("SA4")+SF8->F8_TRANSP))
						cCNPJT := aRetDig(SA4->A4_CGC,.F.)
					Endif
				Else
					SA2->(dbSetOrder(1))
					If SA2->(MsSeek(xFilial("SA2")+SF8->F8_TRANSP+SF8->F8_LOJTRAN))
						cCNPJT := aRetDig(SA2->A2_CGC,.F.)
					EndIf
				Endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual a origem das informacoes da transportadora - SA4 ou SA1 ou SA2³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMapTrans == "1"
					SA4->(dbSetOrder(1))
					If SA4->(MsSeek(xFilial("SA4")+(cAliasSF1)->F1_TRANSP))
						cCNPJT := aRetDig(SA4->A4_CGC,.F.)
					Endif
				Else
					If !(cAliasSF1)->F1_TIPO $ "D/B"
						SA2->(MsSeek(xFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
						cCNPJT := aRetDig(SA2->A2_CGC,.F.)
					Else
						SA1->(MsSeek(xFilial("SA1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
						cCNPJT := aRetDig(SA1->A1_CGC,.F.)
					Endif
				EndIf
			Endif
			If Left((cAliasSD1)->D1_CF,1) < "3"

				aRecord := Array(15)
				aRecord[01] := Left((cAliasSB1)->B1_COD,15)
				aRecord[02]	:= (cAliasSB1)->B1_COD
				aRecord[03]	:= StrZero(Day((cAliasSD1)->D1_EMISSAO),2)
				aRecord[04] := (cAliasSD1)->D1_CF
				aRecord[05]	:= nConcent

				aValArea := GetArea()
				SB1->(DbSetOrder (1))
				If (SB1->(MsSeek(xFilial("SB1")+(cAliasSB1)->B1_COD)))			
					SB5->(DbSetOrder (1))
					If (SB5->(MsSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty((cAliasSB5)->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoTPFator))))))
						//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
						aRecord[06]		:= IIF(nNewQtd==0,ConvUN((cAliasSD1)->D1_QUANT,cCpoFator,cCpoTpFator),nNewQtd)
						If !Empty(cMVUNMAPA)
							//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA	
							aRecord[06]	:= IIF(nNewQtd==0,CONVUN((cAliasSD1)->D1_QUANT),nNewQtd)
						End if
					Else
						aRecord[06]	:= IIF(nNewQtd==0,(cAliasSD1)->D1_QUANT,nNewQtd)
					End if
				End if	
				RestArea(aValArea)
				
				aRecord[07] := cUn
				aRecord[08]	:= (cAliasSD1)->D1_DOC
				aRecord[09]	:= cCNPJ	//CNPJ Cliente/Fornecedor
				aRecord[10]	:= cCNPJT	//CNPJ Transportadora
				aRecord[11]	:= (cAliasSB1)->B1_POSIPI
				If !Empty(cDescPR) .And. lMvAglut
					aRecord[12] := cDescPR
				Else
					aRecord[12] := (cAliasSB1)->B1_DESC
				EndIf
				aRecord[13] := cGrupo
				aRecord[14] := (cAliasSD1)->D1_EMISSAO
				aRecord[15] := cRazSoc

				GravaTMV(aRecord, lMvAglut)

			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-C: TIE - Tabela de Importacao / Exportacao                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs
			If Left((cAliasSD1)->D1_CF,1) == "3"
				If !(lMv_Easy)	//Integracao EIC
					If lD1_Li
						cLi := (cAliasSD1)->&(cD1_Li)
					Else
						cLi := (cAliasSD1)->D1_CONHEC
					Endif
				Else
					SWP->(dbSetOrder(2))	//Capa da L.I.
					If SWP->(MsSeek(xFilial("SWP")+Dtos(dDtIni)))
						If lD1_Li
							cLi := (cAliasSD1)->&(cD1_Li)
						Else
							cLi := SWP->WP_NR_ALI
						Endif
					Endif
				Endif

				aRecord := Array(14)
				aRecord[01] := Left((cAliasSB1)->B1_COD,15)
				aRecord[02] := (cAliasSB1)->B1_COD
				aRecord[03] := nConcent
				aRecord[04] := IIF(nNewQtd==0,(cAliasSD1)->D1_QUANT,nNewQtd)
				aRecord[05] := cUn
				aRecord[06] := cLi
				aRecord[07] := (cAliasSD1)->D1_DOC
				aRecord[08] := cCNPJT	//CNPJ Transportadora
				aRecord[09] := cRazSoc	//Razao Social
				aRecord[10] := cCodPais	//Codigo do Pais
				aRecord[11] := "I"		//I-Importacao ou E-Exportacao
				aRecord[12] := (cAliasSB1)->B1_POSIPI
				If !Empty(cDescPR) .And. lMvAglut
					aRecord[13] :=cDescPR
				Else
					aRecord[13] :=(cAliasSB1)->B1_DESC
				EndIf
				aRecord[14] := (cAliasSD1)->D1_EMISSAO

				GravaTIE(aRecord)

			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-D: TAM - Tabela de Armazenagem de Produtos Quimicos           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs
			If !lMvAglut
				cChv	:=	(cAliasSD1)->B1_COD + PadR(cCNPJ,Len(TAM->CNPJ))
			Else
				If !Empty(cDescPR) .And. lMvAglut
					cChv	:=	PadR(cDescPR,Len(TAM->DESCR_PROD)) + PadR(cCNPJ,Len(TAM->CNPJ))
				Else
					cChv	:=	PadR(SB1->B1_DESC,Len(TAM->DESCR_PROD)) + PadR(cCNPJ,Len(TAM->CNPJ))
				EndIf
			EndIf
			dbSelectArea("TAM")
			If !TAM->(MsSeek(cChv))
				RecLock("TAM",.T.)
				TAM->COD_PROD	:= Left((cAliasSB1)->B1_COD,15)
				TAM->CODPESQ	:= (cAliasSB1)->B1_COD
				TAM->NCM		:= (cAliasSB1)->B1_POSIPI
				If !Empty(cDescPR) .And. lMvAglut
					TAM->DESCR_PROD	:= cDescPR
				Else
					TAM->DESCR_PROD	:= (cAliasSB1)->B1_DESC
				EndIf
				TAM->CONCENT	:= nConcent
				TAM->QT_EST_ANT	:= IIF(nNewQtd==0,nEstqAnt,nNewQtd)
				TAM->QT_EST_ATU	:= IIF(nNewQtdAtu==0,nEstqAtu,nNewQtdAtu)
				TAM->UN			:= cUn
				TAM->CNPJ		:= cCNPJ
				TAM->EMISS		:= (cAliasSD1)->D1_EMISSAO
				MsUnlock()
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Anexo XI-E: TMA - Tabela de Movimento de Armazenagem Prods. Quimicos   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGerRegs
			If !lMvAglut
				cChv	:=	PadR((cAliasSD1)->D1_DOC,Len(TMA->NFISCAL))
			Else
				If !Empty(cDescPR) .And. lMvAglut
					cChv	:=	PadR((cAliasSD1)->D1_DOC,Len(TMA->NFISCAL)) + PadR(cDescPR,Len(TMA->RAZSOC))
				Else
					cChv	:=	PadR((cAliasSD1)->D1_DOC,Len(TMA->NFISCAL)) + PadR(SB1->B1_DESC,Len(TMA->RAZSOC))
				EndIf
			EndIf
			dbSelectArea("TMA")
			RecLock("TMA",.T.)
			TMA->DIA		:= StrZero(Day((cAliasSD1)->D1_EMISSAO),2)
			TMA->E_S		:= "E"		//E-Entrada / S-Saida
			aValArea := GetArea()
			SB1->(DbSetOrder (1))
			If (SB1->(MsSeek(xFilial("SB1")+(cAliasSB1)->B1_COD)))			
				SB5->(DbSetOrder (1))
				If (SB5->(MsSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty((cAliasSB5)->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoTPFator))))))
					//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
					TMA->QTDE		:= IIF(nNewQtd==0,ConvUN((cAliasSD1)->D1_QUANT,cCpoFator,cCpoTpFator),nNewQtd)
					If !Empty(cMVUNMAPA)
						//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA	
						TMA->QTDE		:= IIF(nNewQtd==0,ConvUN((cAliasSD1)->D1_QUANT),nNewQtd)
					End if
				Else
					TMA->QTDE		:= IIF(nNewQtd==0,(cAliasSD1)->D1_QUANT,nNewQtd)
				End if
			End if	
			RestArea(aValArea)		
			TMA->UN			:= cUn
			TMA->NFISCAL	:= (cAliasSD1)->D1_DOC
			TMA->CNPJ		:= cCNPJ
			TMA->CNPJ_T		:= cCNPJT
			TMA->CONCENT	:= nConcent
			TMA->NCM		:= (cAliasSB1)->B1_POSIPI
			If !Empty(cDescPR) .And. lMvAglut
				TMA->RAZSOC	:= cDescPR
			Else
				TMA->RAZSOC	:= (cAliasSB1)->B1_DESC
			EndIf
			TMA->EMISS		:= (cAliasSD1)->D1_EMISSAO
			TMA->CLIEFOR	:= cRazSoc
			TMA->COD_PROD	:= Left((cAliasSB1)->B1_COD,15)
			TMA->CODPESQ	:= (cAliasSB1)->B1_COD
			MsUnlock()
		Endif
		(cAliasSD1)->(dbSkip())
	EndDo

	If !lQuery
		RetIndex("SD1")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processando outros movimentos - producao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "O"

	//-- 1. PR - movimentação deste componente (produto controlado).

	#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery		:= .T.
		cAliasSD3	:= GetNextAlias()
		cAliasSC2	:= cAliasSD3
		cAliasSB1	:= cAliasSD3
		cAliasSB5	:= cAliasSD3

		cQuery := " SELECT SD3.D3_FILIAL, SD3.D3_EMISSAO, SD3.D3_COD, SD3.D3_LOCAL, SD3.D3_UM, "+CRLF
		cQuery += " 	SD3.D3_CF, SD3.D3_ESTORNO, SD3.D3_OP, SD3.D3_QUANT, "+ cCoalesce+" ( SC2.C2_PRODUTO, '"+ CriaVar( 'C2_PRODUTO', .F. ) +"' ) C2_PRODUTO, "+CRLF
		cQuery += " 	"+ cCoalesce +" ( SC2.C2_QUANT, 0 ) C2_QUANT, SB1.B1_DESC, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_GRUPO "+CRLF
		cQuery += " 	"+ cCampos +" "+CRLF

		cQuery += " FROM "+ RetSQLName( 'SD3' ) +" SD3 "+CRLF
		cQuery += " 	INNER JOIN "+ RetSQLName( 'SB1' ) +" SB1 ON ( SD3.D3_FILIAL = '"+ xFilial( 'SD3' ) +"' AND SB1.B1_FILIAL = '"+ xFilial( 'SB1' ) +"' AND SB1.B1_COD = SD3.D3_COD ) "+CRLF
		cQuery += " 	INNER JOIN "+ RetSQLName( 'SB5' ) +" SB5 ON ( SB1.B1_FILIAL = '"+ xFilial( 'SB1' ) +"' AND SB5.B5_FILIAL = '"+ xFilial( 'SB5' ) +"' AND SB5.B5_COD = SB1.B1_COD "+ cCondic +" ) "+CRLF
		cQuery += " 	LEFT OUTER JOIN "+ RetSQLName( 'SC2' ) +" SC2 ON ( SD3.D3_FILIAL = '"+ xFilial( 'SD3' ) +"' AND SC2.C2_FILIAL = '"+ xFilial( 'SC2' ) +"' "+CRLF 
		cQuery += " 														AND  "+ cCoalesce+" (  SC2.C2_NUM "+ cConcat +" SC2.C2_ITEM "+ cConcat +" SC2.C2_SEQUEN "+ cConcat +" SC2.C2_ITEMGRD , '"+ CriaVar( 'D3_OP', .F. ) +"' ) = SD3.D3_OP  "+CRLF
		cQuery += " 														AND SC2.D_E_L_E_T_ = ' ' ) "+CRLF
		
		cQuery += " WHERE SD3.D3_EMISSAO >= '"+ Dtos( dDtIni ) +"' AND SD3.D3_EMISSAO <= '"+ Dtos( dDtFim ) +"' AND "+CRLF
		cQuery += " 	SD3.D3_COD >= '"+ cProdDe +"' AND SD3.D3_COD <= '"+ cProdAte +"' AND "+CRLF
		cQuery += " 	SD3.D3_GRUPO >= '"+ cGrpDe +"' AND SD3.D3_GRUPO <= '"+ cGrpAte +"' AND "+CRLF
		cQuery += " 	SD3.D3_ESTORNO <> 'S' AND "+CRLF
		cQuery += " 	SD3.D3_CF IN('PR0','PR1','ER0','ER1','DE0','DE1','DE2','DE3','DE4','DE5','DE6','DE7','DE9','RE0','RE1','RE2','RE3','RE4','RE5','RE6','RE7','RE9') AND "+CRLF
		cQuery += " 	SD3.D_E_L_E_T_ = ' ' AND "+CRLF
		cQuery += " 	SB1.D_E_L_E_T_ = ' ' AND "+CRLF
		cQuery += " 	SB5.D_E_L_E_T_ = ' ' "+CRLF
		
		cQuery += " ORDER BY SD3.D3_FILIAL,SD3.D3_OP,SD3.D3_COD,SD3.D3_LOCAL "

		cQuery := ChangeQuery( cQuery )
		
		dbUseArea( .T., __cRdd, TcGenQry( ,, cQuery ), cAliasSD3, .F., .T. )
		dbSelectArea( cAliasSD3 )
		TcSetField( cAliasSD3, 'C2_QUANT', TamSx3( 'C2_QUANT' )[ 3 ], TamSx3( 'C2_QUANT' )[ 1 ], TamSx3( 'C2_QUANT' )[ 2 ]  )
		TcSetField( cAliasSD3, 'D3_QUANT', TamSx3( 'D3_QUANT' )[ 3 ], TamSx3( 'D3_QUANT' )[ 1 ], TamSx3( 'D3_QUANT' )[ 2 ]  )
		TcSetField( cAliasSD3, 'D3_EMISSAO', TamSx3( 'D3_EMISSAO' )[ 3 ], TamSx3( 'D3_EMISSAO' )[ 1 ], TamSx3( 'D3_EMISSAO' )[ 2 ]  )
	Else
	#ENDIF
		cArqInd := CriaTrab(Nil,.F.)
		cChave  := "D3_OP+D3_COD+D3_LOCAL"
		cCondic := 'D3_FILIAL == "' + xFilial("SD3") + '" .And. '
		cCondic += 'Dtos(D3_EMISSAO) >= "' + Dtos(dDtIni) + '" .And. Dtos(D3_EMISSAO) <= "' + Dtos(dDtFim) + '" .And. '
		cCondic += 'D3_COD >= "' + cProdDe + '" .And. D3_COD <= "' + cProdAte + '" .And. '
		cCondic += 'D3_GRUPO >= "' + cGrpDe + '" .And. '
		cCondic += 'D3_GRUPO <= "' + cGrpAte + '" .And. '
		cCondic += 'D3_ESTORNO <> "S" .And. '
		cCondic += 'D3_CF $ "PR0/PR1/ER0/ER1/DE0/DE1/DE2/DE3/DE4/DE5/DE6/DE7/DE9/RE0/RE1/RE2/RE3/RE4/RE5/RE6/RE7/RE9"'
		IndRegua(cAliasSD3,cArqInd,cChave,,cCondic,"Selecionando Registros")
		#IFNDEF TOP
		DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		(cAliasSD3)->(dbGotop())
		If !lRelat
			ProcRegua(LastRec())
		Else
			SetRegua(LastRec())
		Endif
	#IFDEF TOP
	Endif
	#ENDIF

	Do While !((cAliasSD3)->(Eof()))
		lBuscaG1	:= .T.
		nEstqAnt	:= 0
		nEstqAtu	:= 0
		nProduz		:= 0
		nUtiliza	:= 0

		If !lQuery
			SC2->(dbSetOrder(1))
			If !(SC2->(MsSeek(xFilial("SC2")+(cAliasSD3)->D3_OP)))
				(cAliasSD3)->(DbSkip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Checa o grupo do produto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(dbSetOrder(1))
			If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSD3)->D3_COD)))
				(cAliasSD3)->(DbSkip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos e consideracoes que deverao ser analisadas referentes ao SB5 de acordo com os parametros da rotina - CODEBASE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Verifica a existencia do SB5
			SB5->(dbSetOrder(1))
			If !SB5->(MsSeek(xFilial("SB5")+(cAliasSD3)->D3_COD))
				(cAliasSD3)->(DbSkip())
				Loop
			Endif
			// Indicacao de produto controlado ou nao
			If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
				If SB5->&cCpoB5 <> "S"
					(cAliasSD3)->(DbSkip())
					Loop
				Endif
			Endif
			// Grupo Auxiliar
			If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
				If !((SB5->(FieldGet(FieldPos(cMVGRP2PRO))) >= cGrpde) .And. (SB5->(FieldGet(FieldPos(cMVGRP2PRO))) <= cGrpate))
					(cAliasSD3)->(DbSkip())
					Loop
				EndIf
			Endif
		Endif

		SB5->(dbSetOrder(1))
		If SB5->(MsSeek(xFilial("SB5")+(cAliasSC2)->C2_PRODUTO))
			//-- Desconsidera se produto somente processo de envase
			If !Empty(cCpoB5Emb) .And. SB5->(FieldPos(cCpoB5Emb)) > 0
				If SB5->&cCpoB5Emb == "S"
					(cAliasSD3)->(DbSkip())
					Loop
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Concentracao e densidade do produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nConcent := (cAliasSB5)->B5_CONCENT
		nDensid  := (cAliasSB5)->B5_DENSID

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descrição MV_DESCPR do produto     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVDESCPR) .And. (cAliasSB5)->(FieldPos(cMVDESCPR)) > 0
			cDescPR := Alltrim((cAliasSB5)->(FieldGet(FieldPos(cMVDESCPR))))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grupo - utilizado na impressao do relatorio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
			cGrupo := (cAliasSB5)->(FieldGet(FieldPos(cMVGRP2PRO)))
		Else
			cGrupo := (cAliasSB1)->B1_GRUPO
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Os produtos constantes na lista IV da Portaria 1274/2003 somente devem gerar³
		//³os registros de exportacao ou reexportacao.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMapIV
			If !(cAliasSB5)->(&(cMapIV)) $ " 2"
				(cAliasSD3)->(DbSkip())
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estoque Anterior              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ANT->(MsSeek((cAliasSD3)->D3_COD))
			nEstqAnt := ANT->QUANT
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estoque Atual                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ATU->(MsSeek((cAliasSD3)->D3_COD))
			nEstqAtu := ATU->QUANT
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Producao Manual e Automatica  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD3)->D3_CF == "PR0" .Or. (cAliasSD3)->D3_CF == "PR1"
			nProduz := (cAliasSD3)->D3_QUANT
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estorno de producao Manual e Automatico³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD3)->D3_CF == "ER0" .Or. (cAliasSD3)->D3_CF == "ER1"
			nProduz -= (cAliasSD3)->D3_QUANT
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Requisicao Manual e Automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD3)->D3_CF $ "RE0/RE1/RE2/RE3/RE4/RE5/RE6/RE7/RE9"
			nUtiliza := (cAliasSD3)->D3_QUANT
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Devolucao Manual e Automatica ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD3)->D3_CF $ "DE0/DE1/DE2/DE3/DE4/DE5/DE6/DE7/DE9"
			nUtiliza -= (cAliasSD3)->D3_QUANT
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conversao da Unidade de Medida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//Se encontrar SB1 correspondente continuo
		SB1->(DbSetOrder (1))
		If (SB1->(MsSeek(xFilial("SB1")+(cAliasSD3)->D3_COD)))
			aArea := GetArea()
			SB5->(DbSetOrder (1))
			If (SB5->(MsSeek(xFilial("SB5")+(cAliasSD3)->D3_COD))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty((cAliasSB5)->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoTPFator))))))
				//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
				cUn	:= Alltrim((cAliasSB5)->(FieldGet(FieldPos(cCpoUn))))
				nNewQtd	:= ConvUN((cAliasSD3)->D3_QUANT,cCpoFator,cCpoTpFator)
				nNewQtdAtu := ConvUN(nEstqAtu,cCpoFator,cCpoTpFator)
				nProduz	:= ConvUN(nProduz,cCpoFator,cCpoTpFator)
				nUtiliza := ConvUN(nUtiliza,cCpoFator,cCpoTpFator)
			ElseIf !Empty(cMVUNMAPA)
				//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA
				nPos := at(Alltrim((cAliasSB1)->B1_UM)+"=",cMVUNMAPA)
				If nPos > 0
					cUn := Substr(cMVUNMAPA,nPos+2,Len(cMVUNMAPA))
					If at("/",cUn) > 0
						nPos := at("/",cUn)-1
						cUn := Substr( cUn,1 , nPos )
					EndIf
					cUn := Substr( cUn,at("=",cUn)+1,Len(cUn))
					nNewQtd	:= ConvUN((cAliasSD3)->D3_QUANT)
					nNewQtdAtu := ConvUN(nEstqAtu)
					nProduz	:= ConvUN(nProduz)
					nUtiliza := ConvUN(nUtiliza)
				Else
					cUn := (cAliasSB1)->B1_UM
				Endif
			Else
				cUn := (cAliasSB1)->B1_UM
			Endif
		Endif
		RestArea(aArea)

		If !lMvAglut
			cChv	:=	(cAliasSD3)->D3_COD
		Else
			If !Empty(cDescPR) .And. lMvAglut
				cChv	:=	PadR(cDescPR,Len(TPR->DESCR_PROD))+(cAliasSB1)->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
			Else
				cChv	:=	PadR((cAliasSB1)->B1_DESC,Len(TPR->DESCR_PROD))+(cAliasSB1)->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
			EndIf
		EndIf
		dbSelectArea("TPR")
		If !TPR->(MsSeek(cChv))
			RecLock("TPR",.T.)
			TPR->COD_PROD	:= Left((cAliasSD3)->D3_COD,15)
			TPR->CODPESQ	:= (cAliasSD3)->D3_COD
			TPR->CONCENT	:= nConcent
			TPR->DENSID		:= nDensid
			TPR->UN			:= cUn
			TPR->NCM		:= (cAliasSB1)->B1_POSIPI
			TPR->GRUPO		:= cGrupo
			TPR->EMISS		:= (cAliasSD3)->D3_EMISSAO
			TPR->QT_UTILIZ	:= nUtiliza
			TPR->QT_PRODUZ	:= nProduz
			If !lMvAglut
				TPR->QT_EST_ANT	:= IIF(nNewQtd==0,nEstqAnt,nNewQtd)
				TPR->QT_EST_ATU	:= IIF(nNewQtdAtu==0,nEstqAtu,nNewQtdAtu)
			Endif
			If !Empty(cDescPR) .And. lMvAglut
				TPR->DESCR_PROD	:= cDescPR
			Else
				TPR->DESCR_PROD	:= (cAliasSB1)->B1_DESC
			EndIf
		Else
			lBuscaG1	:= .F.
			RecLock("TPR",.F.)
			TPR->QT_UTILIZ	+= nUtiliza
			TPR->QT_PRODUZ	+= nProduz
		Endif
		MsUnlock()

		//-- 2. PF - produtos deste componente.

		nTotPrd := 0
		#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasPF := GetNextAlias()
			BeginSql Alias cAliasPF
				SELECT
					SUM (CASE WHEN SD3.D3_CF LIKE ('PR%') THEN SD3.D3_QUANT ELSE 0 END) AS TOTPRD,
					SUM (CASE WHEN SD3.D3_CF LIKE ('ER%') THEN SD3.D3_QUANT ELSE 0 END) AS ESTPRD
				FROM
					%table:SD3% SD3
				WHERE
					SD3.D3_FILIAL = %xFilial:SD3% AND
					SD3.D3_COD = %Exp:(cAliasSC2)->C2_PRODUTO% AND
					SD3.D3_OP  = %Exp:(cAliasSD3)->D3_OP% AND
					(SD3.D3_CF LIKE ('PR%') OR SD3.D3_CF LIKE ('ER%')) AND
					SD3.D3_ESTORNO <> 'S' AND
					SD3.%NotDel%
			EndSql
			dbSelectArea(cAliasPF)
			If !EOF()
				nTotPrd := (cAliasPF)->(TOTPRD-ESTPRD)
			EndIf
			dbCloseArea()
		EndIf
		#ENDIF

		SB1->(dbSetOrder(1))
		If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSC2)->C2_PRODUTO)))
			(cAliasSD3)->(DbSkip())
			Loop
		EndIf

		If SB5->(MsSeek(xFilial("SB5")+(cAliasSC2)->C2_PRODUTO))
			nDensPF := SB5->B5_DENSID
			nConcPF := SB5->B5_CONCENT
		Else
			nDensPF := 0
			nConcPF := 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descrição MV_DESCPR do produto     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVDESCPR) .And. SB5->(FieldPos(cMVDESCPR)) > 0
			cDescPR := Alltrim(SB5->(FieldGet(FieldPos(cMVDESCPR))))
		EndIf

		If aScan(aOP,{|x|x==(cAliasSD3)->D3_OP}) == 0
			aAdd(aOP,(cAliasSD3)->D3_OP)
			If !lMvAglut
				cChv	:= (cAliasSC2)->C2_PRODUTO
			Else
				If !Empty(cDescPR) .And. lMvAglut
					cChv	:=	PadR(cDescPR,     Len(TPF->DESCR_PROD))+SB1->B1_POSIPI+PadR(SB1->B1_UM,Len(TPR->UN))+Str(nConcPF,6,2)+Str(nDensPF,6,2)
				Else
					cChv	:=	PadR(SB1->B1_DESC,Len(TPF->DESCR_PROD))+SB1->B1_POSIPI+PadR(SB1->B1_UM,Len(TPR->UN))+Str(nConcPF,6,2)+Str(nDensPF,6,2)
				EndIf
			EndIf
			If TPF->(MsSeek(cChv))
				RecLock("TPF",.F.)
				TPF->QTDE += (cAliasSC2)->C2_QUANT
				MsUnlock()
			Else
				RecLock("TPF",.T.)
				TPF->CODPESQ	:= (cAliasSC2)->C2_PRODUTO
				TPF->CODIGO		:= (cAliasSD3)->D3_COD
				TPF->DENSID		:= nDensPF
				TPF->CONCENT	:= nConcPF
				TPF->UN			:= SB1->B1_UM
				TPF->NCM		:= SB1->B1_POSIPI
				TPF->QTDE		:= Iif(nTotPrd>0,nTotPrd,(cAliasSC2)->C2_QUANT)
				If !Empty(cDescPR) .And. lMvAglut
					TPF->DESCR_PROD	:= cDescPR
				Else
					TPF->DESCR_PROD	:= SB1->B1_DESC
				EndIf
				MsUnlock()
			EndIf
		EndIf

		If (cAliasSC2)->C2_PRODUTO==(cAliasSD3)->D3_COD
			(cAliasSD3)->(DbSkip())
			Loop
		EndIf

		//-- 3. SP - componentes deste produto

		SB1->(dbSetOrder(1))
		If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSD3)->D3_COD)))
			(cAliasSD3)->(DbSkip())
			Loop
		EndIf

		SB5->(dbSetOrder(1))
		If SB5->(MsSeek(xFilial("SB5")+(cAliasSD3)->D3_COD))
			nConcSP := SB5->B5_CONCENT
		Else
			nConcSP := 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descrição MV_DESCPR do produto     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVDESCPR) .And. SB5->(FieldPos(cMVDESCPR)) > 0
			cDescPR := Alltrim(SB5->(FieldGet(FieldPos(cMVDESCPR))))
		EndIf

		RecLock("TSP",.T.)
		TSP->CODPESQ	:= (cAliasSC2)->C2_PRODUTO
		TSP->CODIGO		:= (cAliasSD3)->D3_COD
		TSP->CONCENT	:= nConcSP
		TSP->NCM		:= SB1->B1_POSIPI
		If !Empty(cDescPR) .And. lMvAglut
			TSP->DESCR_PROD	:= cDescPR
		Else
			TSP->DESCR_PROD	:= SB1->B1_DESC
		EndIf
		MsUnlock()

		(cAliasSD3)->(dbSkip())
	EndDo

	If !lQuery
		RetIndex("SD3")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD3)
		dbCloseArea()
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere os produtos que nao tiverem movimentacao mas que possuem³
//³estoque no Anexo XI-A.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ATU->(dbGoTop())
Do While !ATU->(Eof())

	If !TPR->(MsSeek(ATU->CODIGO))

		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+ATU->CODIGO))
		// Faixa de grupos
		If !(SB1->B1_GRUPO>=cGrpDe .And. SB1->B1_GRUPO<=cGrpAte)
			ATU->(DbSkip())
			Loop
		EndIf

		SB5->(dbSetOrder(1))
		SB5->(MsSeek(xFilial("SB5")+ATU->CODIGO))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Concentracao e densidade do produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nConcent := SB5->B5_CONCENT
		nDensid  := SB5->B5_DENSID

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descrição MV_DESCPR do produto     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMVDESCPR) .And. SB5->(FieldPos(cMVDESCPR)) > 0
			cDescPR := Alltrim(SB5->(FieldGet(FieldPos(cMVDESCPR))))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura o saldo anterior³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nEstqAnt := 0
		If ANT->(MsSeek(ATU->CODIGO))
			nEstqAnt := ANT->QUANT
		Endif

		//Se encontrar SB1 correspondente continuo
		SB1->(DbSetOrder (1))
		If (SB1->(MsSeek(xFilial("SB1")+ATU->CODIGO)))
			aArea := GetArea()
			SB5->(DbSetOrder (1))
			If (SB5->(MsSeek(xFilial("SB5")+ATU->CODIGO))) .And. (!Empty(cCpoUn) .And. !Empty(Alltrim(SB5->(FieldGet(FieldPos(cCpoUn)))))) .And. (!Empty(cCpoFator) .And. !Empty(SB5->(FieldGet(FieldPos(cCpoFator))))) .And. (!Empty(cCpoTpFator) .And. !Empty(Alltrim(SB5->(FieldGet(FieldPos(cCpoTPFator))))))
				//Conversao da Unidade de Medida atraves do parametro MV_CPOMAPA
				cUn	:= Alltrim(SB5->(FieldGet(FieldPos(cCpoUn))))
				nNewQtd	:= ConvUN(nEstqAnt,cCpoFator,cCpoTpFator)
				nNewQtdAtu := ConvUN(ATU->QUANT,cCpoFator,cCpoTpFator)
			ElseIf !Empty(cMVUNMAPA)
				//Conversao da Unidade de Medida atraves do parametro MV_UNMAPA
				nPos := at(Alltrim(ATU->UM)+"=",cMVUNMAPA)
				If nPos > 0
					cUn := Substr(cMVUNMAPA,nPos+2,Len(cMVUNMAPA))
					If at("/",cUn) > 0
						nPos := at("/",cUn)-1
						cUn := Substr( cUn,1 , nPos )
					EndIf
					cUn	:= Substr( cUn,at("=",cUn)+1,Len(cUn))
					nNewQtd	:= ConvUN(nEstqAnt)
					nNewQtdAtu := ConvUN(ATU->QUANT)
				Else
					cUn := ATU->UM
				Endif
			Else
				cUn := ATU->UM
			Endif
		Endif
		RestArea(aArea)

		If !lMvAglut
			cChv	:=	SB1->B1_COD
		Else
			If !Empty(cDescPR) .And. lMvAglut
				cChv	:=	PadR(cDescPR,Len(TPR->DESCR_PROD))+SB1->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
			Else
				cChv	:=	PadR(SB1->B1_DESC,Len(TPR->DESCR_PROD))+SB1->B1_POSIPI+PadR(cUn,Len(TPR->UN))+Str(nConcent,6,2)+Str(nDensid,6,2)
			EndIf
		EndIf

		dbSelectArea("TPR")
		If !MsSeek(cChv)
			RecLock("TPR",.T.)
			TPR->COD_PROD	:= Left(ATU->CODIGO,15)
			TPR->CODPESQ	:= ATU->CODIGO
			TPR->CONCENT	:= nConcent
			TPR->DENSID		:= nDensid
			TPR->UN			:= cUn
			TPR->NCM		:= ATU->NCM
			TPR->GRUPO		:= SB1->B1_GRUPO
			TPR->EMISS		:= dDtIni
			If !lMvAglut
				TPR->QT_EST_ANT	:= IIF(nNewQtd==0,nEstqAnt,nNewQtd)
				TPR->QT_EST_ATU	:= IIF(nNewQtdAtu==0,ATU->QUANT,nNewQtdAtu)
			Endif
			If !Empty(cDescPR) .And. lMvAglut
				TPR->DESCR_PROD	:= cDescPR
			Else
				TPR->DESCR_PROD	:= ATU->DESC_PRD
			EndIf
			MsUnLock()
		EndIf
	Endif

	ATU->(dbSkip())
Enddo

Return .T.

/*/{Protheus.doc} GravaTIE
Efetua a gravacao na tabela de trabalho TIE utilizado para o Anexo XI-C
@author reynaldo
@since 01/11/2017
@version 1.0
@return Logic, Sempre verdadeiro
@param aRecord, array, Vetor com 14 posicoes com os valores a serem gravados na tabela TIE
@type function
/*/
Static Function GravaTIE(aRecord)
Local aArea := GetArea()

RecLock("TIE",.T.)
TIE->COD_PROD	:= aRecord[01]
TIE->CODPESQ	:= aRecord[02]
TIE->CONCENT	:= aRecord[03]
TIE->QTDE		:= aRecord[04]
TIE->UN			:= aRecord[05]
TIE->LI_RE		:= aRecord[06]
TIE->NFISCAL	:= aRecord[07]
TIE->CNPJ_T		:= aRecord[08]
TIE->NOME_IE	:= aRecord[09]
TIE->PAIS		:= aRecord[10]
TIE->IMP_EXP	:= aRecord[11]
TIE->NCM		:= aRecord[12]
TIE->DESCR_PROD	:= aRecord[13]
TIE->EMISS		:= aRecord[14]
MsUnlock()

RestArea(aArea)
Return .T.

/*/{Protheus.doc} GravaTMV
Efetua a gravacao na tabela de trabalho TMV utilizado para o Anexo XI-B
@author reynaldo
@since 31/10/2017
@version 1.0
@return Logic, Sempre verdadeiro
@param aRecord, array, Vetor com 15 posicoes com os valores a serem gravados na tabela TMV
@param lMvAglut, logical, Se aglutina os registros baseado no numero do documento e descricao do produto
@type function
/*/
Static Function GravaTMV(aRecord, lMvAglut)
Local aArea := GetArea()
Local lNew	:= .F.

DEFAULT lMvAglut := GetNewPar("MV_AGLUTPR",.F.)

If lMvAglut
	dbSelectArea("TMV")
	// chave de busca
	// Quando o parametro de sistema "MV_AGLUTPR" estiver ativo
	// "NFISCAL+DESCR_PROD+NCM+UN+STR(CONCENT,6,2)+CFOP"
	lNew := !MsSeek( padr(aRecord[08],len(TMV->NFISCAL))+padr(aRecord[12],len(TMV->DESCR_PROD)) ;
	+padr(aRecord[11],len(TMV->NCM))+padr(aRecord[07],len(TMV->UN))+Str(aRecord[05],6,2) ;
	+padr(aRecord[04],len(TMV->CFOP)))
Else
	lNew := .T.
EndIf


RecLock("TMV",lNew)
TMV->COD_PROD	:= aRecord[01]
TMV->CODPESQ	:= aRecord[02]
TMV->DIA		:= aRecord[03]
TMV->CFOP		:= aRecord[04]
TMV->CONCENT	:= aRecord[05]
TMV->QTDE		+= aRecord[06]
TMV->UN			:= aRecord[07]
TMV->NFISCAL	:= aRecord[08]
TMV->CNPJ_CF	:= aRecord[09]
TMV->CNPJ_T		:= aRecord[10]
TMV->NCM		:= aRecord[11]
TMV->DESCR_PROD	:= aRecord[12]
TMV->GRUPO		:= aRecord[13]
TMV->EMISS		:= aRecord[14]
TMV->CLIEFOR	:= aRecord[15]
MsUnlock()

RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MapasEst  ³ Autor ³ Mary C. Hergert       ³ Data ³09/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera os arquivos temporarios com os movimentos de estoque   ³±±
±±³          ³no inicio e no final do periodo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Tipo (1 - gera arquivos / 2 - deleta gerados)       ³±±
±±³          ³ExpD2 = Data inicial de geracao das informacoes             ³±±
±±³          ³ExpD3 = Data final de geracao das informacoes               ³±±
±±³          ³ExpC4 = Grupo de produtos inicial para processamento        ³±±
±±³          ³ExpC5 = Grupo de produtos final para processamento          ³±±
±±³          ³ExpC6 = Codigo de produto inicial para processamento        ³±±
±±³          ³ExpC7 = Codigo de produto final para processamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Mapas e Matr913                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MapasEst(nTipo,dDtIni,dDtFim,cGrpDe,cGrpAte,cProdDe,cProdAte)

Local cArqAnt	:= ""
Local cArqAtu	:= ""
Local cFiltraB5	:= ""
Local cCpoB5	:= SuperGetMv("MV_PRODPF",.F.,"")
Local cMVGRP2PRO:= SuperGetMv("MV_GRP2PRO",.F.,"")
Local aProd		:= Array(8)

#IFNDEF TOP
Local aFiltraB5	:= {}
Local nX		:= 0
#ENDIF

aProd[1] := Replicate("",TamSx3("B1_COD")[1])
aProd[2] := Replicate("Z",TamSx3("B1_COD")[1])
aProd[3] := Replicate("",TamSx3("B1_LOCPAD")[1])
aProd[4] := Replicate("Z",TamSx3("B1_LOCPAD")[1])
aProd[5] := 2
aProd[6] := 1
aProd[7] := 2
aProd[8] := 2

#IFDEF TOP
// Indicacao de produto controlado ou nao
If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
	cFiltraB5 += " AND SB5." + Alltrim(cCpoB5) + " = 'S'"
Endif
// Grupo Auxiliar
If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
	cFiltraB5 += " AND SB5." + Alltrim(cMVGRP2PRO) + " >= '" + cGrpDe + "'"
	cFiltraB5 += " AND SB5." + Alltrim(cMVGRP2PRO) + " <= '" + cGrpAte + "'"
Endif
// Produto de/ate
cFiltraB5 += " AND SB5.B5_COD >= '" + cProdDe + "'"
cFiltraB5 += " AND SB5.B5_COD <= '" + cProdAte + "'"
#ELSE
// Indicacao de produto controlado ou nao
If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
	aAdd(aFiltraB5,"SB5->" + Alltrim(cCpoB5) + " == 'S'")
Endif
// Grupo Auxiliar
If !Empty(cMVGRP2PRO) .And. SB5->(FieldPos(cMVGRP2PRO)) > 0
	aAdd(aFiltraB5,"SB5->" + Alltrim(cMVGRP2PRO) + " >= '" + cGrpDe + "'")
	aAdd(aFiltraB5,"SB5->" + Alltrim(cMVGRP2PRO) + " <= '" + cGrpAte + "'")
Endif
// Produto de/ate
aAdd(aFiltraB5,"SB5->B5_COD >= '" + cProdDe + "'")
aAdd(aFiltraB5,"SB5->B5_COD <= '" + cProdAte + "'")
For nX := 1 to Len(aFiltraB5)
	If nX == 1
		cFiltraB5 := aFiltraB5[nX]
	Else
		cFiltraB5 := cFiltraB5 + " .And. " + aFiltraB5[nX]
	Endif
Next
#ENDIF

If nTipo == 1 // Gera os temporarios com o estoque inicial/final

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ANT - Estoque Anterior                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FsEstInv({"ANT",""},1,.T.,.F.,mv_par18,.F.,,.T.,cFiltraB5,,,,aProd,,,,,,.F.)
	dbSelectArea("ANT")
	cArqAnt := CriaTrab(NIL,.F.)
	IndRegua("ANT",cArqAnt,"CODIGO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ATU - Estoque Atual                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FsEstInv({"ATU",""},1,.T.,.F.,mv_par19,.F.,,.T.,cFiltraB5,,,,aProd,,,,,,.F.)
	dbSelectArea("ATU")
	cArqAtu := CriaTrab(NIL,.F.)
	IndRegua("ATU",cArqAtu,"CODIGO")

	//Se for aglutinado, deve unir os produtos de mesma chave
Else // Deleta os temporarios criados

	FsEstInv({"ANT",""},2,,,mv_par18,.F.,,.T.,cFiltraB5,,,,aProd,,,,,,.F.)	//Estoque Anterior
	FsEstInv({"ATU",""},2,,,mv_par19,.F.,,.T.,cFiltraB5,,,,aProd,,,,,,.F.)	//Estoque Atual

Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³MapasDel   ºAutor  ³ Mary C. Hergert    º Data ³ 08/01/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Apaga os arquivos temporarios criados para a rotina.         º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³Mapas e Matr913                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MapasDel(aDelArqs)

Local aAreaDel := GetArea()
Local nI := 0

For nI:= 1 To Len(aDelArqs)
	aDelArqs[nI,3]:Delete()
	aDelArqs[nI,3] := NIL
	aDelArqs[nI] := NIL
Next nI

RestArea(aAreaDel)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvUN    ºAutor  ³Camila Januário     º Data ³  03/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza conversão da unidade de medida, baseado            º±±
±±º          ³ na configuraçao de fator de conversão do SB1               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Quando utilizado o MV_UNMAPA ou MV_CPOMAPA                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvUN(nValor, cFatConv, cTpFatorConv)
Local nRet := 0

Default cFatConv     := ""
Default cTpFatorConv := ""

If (ValType(SB5->(FieldGet(FieldPos(cTpFatorConv)))) == 'C' .And. !Empty(SB5->(FieldGet(FieldPos(cTpFatorConv)))) ;
.And. ValType(SB5->(FieldGet(FieldPos(cFatConv))))   == 'N' .And. !Empty(SB5->(FieldGet(FieldPos(cFatConv)))))
	If SB5->(FieldGet(FieldPos(cTpFatorConv))) == "M"
		nRet := (nValor*SB5->(FieldGet(FieldPos(cFatConv))))
	Else
		nRet := (nValor/SB5->(FieldGet(FieldPos(cFatConv))))
	EndIf
ElseIf !Empty(SB1->B1_CONV) .And. !Empty(SB1->B1_TIPCONV)
	If SB1->B1_TIPCONV == "M"
		nRet := (nValor*SB1->B1_CONV)
	Else
		nRet := (nValor/SB1->B1_CONV)
	EndIf
Else
	nRet := nValor
EndIf

Return nRet
