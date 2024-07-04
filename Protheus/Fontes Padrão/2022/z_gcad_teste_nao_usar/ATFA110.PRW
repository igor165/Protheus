#INCLUDE "protheus.ch"
#INCLUDE "atfa110.ch"

#DEFINE APTO_SIMP	31		//Apontamentos simples
#DEFINE APTO_MULTI	32		//Apontamentos multiplos
#DEFINE EST_MULTI	41		//Estornos multiplos
#DEFINE HIST_APTO	90		//Histórico

Static lFWCodFil := .T.
Static lMultMoed := .T.
Static _oATFA1101

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA110   ºAutor  ³Renan Guedes        º Data ³  05/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºDesc.     ³Depreciação por exaustão (agotamiento)                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Local cTypes10	:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - main models
Local cTypesNM	:= IIF(lIsRussia,"|" + AtfNValMod({3,4}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - 17 and 16 models
Local lAtfctap	:= IIF(GetNewPar("MV_ATFCTAP","0")=="0",.F.,.T.)
Local cFiltra		:= ""
Local aCposRot	:= {}

Private aRotina		:= MenuDef("SN3")
Private cCadastro	:= STR0007		//"Apontamentos de produção"
Private aIndexSN3 	:= {}
Private bFiltraBrw	:= {|| Nil}
Private lMostra
Private lAglutina
Private cMoedaAtf	:= GetMV("MV_ATFMOEDA")

Default lAutomato := .F.
Default nPosRot   := 0

//Ativa tecla F12 de parâmetros de lançamento contábil
SetKey( VK_F12, { || Pergunte("AFA110CONT",.T.) } )

Pergunte("AFA110CONT",.F.)
lMostra := IIF(MV_PAR01 == 1, .T., .F.)
lAglutina := IIF(MV_PAR02 == 1, .T., .F.)

If lIsRussia
	cFiltra := "N3_FILIAL == '"+xFilial('SN3')+"' .And. N3_TIPO $ ('01|10|16|17'+cTypes10+cTypesNM) .And. N3_BAIXA == '0' .And. N3_TPDEPR $ '4|5|8|9|'"
Else
	cFiltra := "N3_FILIAL == '"+xFilial('SN3')+"' .And. N3_TIPO $ '01|10|16|17' .And. N3_BAIXA == '0' .And. N3_TPDEPR $ '4|5|8|9|'"
EndIf

bFiltraBrw := { || FilBrowse("SN3",@aIndexSN3,@cFiltra) }

//Verifica se a rotina está parametrizada para ser utilizada
If !lAtfctap
	Help("",1,"AF110CTAP")		//"Esta rotina não poderá ser utilizada, pois o sistema está parametrizado para não controlar apontamentos de produção."##"Configure o parâmetro MV_ATFCTAP."
	Return
EndIf

//Inclui os novos lançamentos padrões da depreciação por exaustão
ChkCVA()

If Select("TRB") != 0
	dbSelectArea("TRB")
	dbCloseArea()
EndIf

dbSelectArea("SN3")
dbSetOrder(1)		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

//Aplica o filtro no alias SN3
Eval(bFiltraBrw)
//Ativa o filtro
SN3->(dbGoTop())

If !lAutomato
	mBrowse(6, 1, 22, 75, "SN3")
Endif

EndFilBrw("SN3",aIndexSN3)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Renan Guedes        º Data ³  05/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utilização de menu funcional.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef(cAlias)

Local aRotina	:= {}

Default cAlias	:= "SN3"

//Botões da rotina de apontamentos
If cAlias == "SN3"
	aRotina	:= {{STR0001	, "AxPesqui"	,0 , 1, 			,.F.},;		//"Pesquisar"
				{STR0002	, "AxVisual"	,0 , 2					},;		//"Visualizar"
				{STR0003	, "AFA110Apt"	,0 , 3, APTO_SIMP		},;		//"Apontamento"
				{STR0005	, "AFA110Apt"	,0 , 3, APTO_MULTI		},;		//"Apt. multiplos"
				{STR0016	, "AFA110Hist"	,0 , 2, HIST_APTO		}}		//"Histórico"
EndIf

//Botões da rotina de histórico de apontamentos
If cAlias == "FNA"
	aRotina	:= {{STR0001	, "AxPesqui"	,0 , 1, 			,.F.},;		//"Pesquisar"
				{STR0002	, "AxVisual"	,0 , 2					},;		//"Visualizar"
				{STR0017	, "AF110Leg"	,0 , 5					}}		//"Legenda"
EndIf

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA110Apt ºAutor  ³Renan Guedes        º Data ³  05/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apontamentos de produção                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA110Apt(cAlias,nReg,nOpc)

Local nOpcX 		:= aRotina[nOpc,5]
Local dDataBloq 	:= GetNewPar("MV_ATFBLQM", CTOD(""))
Local dUltDepr		:= GetNewPar("MV_ULTDEPR", STOD("19800101"))
Local nOpcA			:= 0
Local nOpcB			:= 0
Local nRecno		:= 1
Local cN3Ok			:= "N3_OK"
Local cMarca		:= ""
Local aCpos			:= {}
Local lRet			:= .T.
Local lGravou		:= .F.
Local aAcho			:= {}
Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= MsAdvSize()
Local cOcor			:= ""
Local lEstorno		:= .F.
Local aRetP1		:= {}
Local lDefTop		:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local oEncSimp		:= Nil
Local oEncMult		:= Nil

Private oDlgApt
Private nQtdMark	:= 0

If SN3->(EoF()) .And. SN3->(BoF())
	Help("",1,"AF110NOREC")		//"Não há registros na tabela de dados."##"Os apontamentos só podem ser realizados para bens cadastrados."
	Return
EndIf

//Apontamento simples
If nOpcX == APTO_SIMP
	aObjects := {}
	AADD(aObjects, {100,100, .T., .T.})
	AADD(aObjects, {100,100, .T., .T.})

	aInfo := {aSize[1], aSize[2], aSize[3]*2, aSize[4]*2, 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects)

	//Monta o array com os campos a serem exibidos no apontamento simples
	aAcho := {"FNA_IDMOV","FNA_ITMOV","FNA_CBASE","FNA_ITEM","FNA_DESCRI","FNA_DATA","FNA_OCORR","FNA_DTPERI","FNA_DTPERF","FNA_QUANTD"}

	//Montagem da tela de apontamentos simples
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[1],aSize[1] To aSize[6],aSize[5] of oMainWnd PIXEL
		oDlg:lMaximized := .T.

		RegToMemory("FNA", .T., .T., .T.)

		//Inicializa os campos do cadastro
		AF110IniBrw()

		//Enchoice("FNA", nReg, nOpc,,,, aAcho, aPosObj[1], aAcho, 3,,, /*cTudoOk*/, oDlg)
		oEncSimp:= MsMGet():New("FNA",nReg,nOpc,,,,aAcho,{0,0,0,0},,,,,,oDlg)
		oEncSimp:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(AF110TudOk(.F.),(nOpcA := 1, oDlg:End()),) },{|| nOpcA := 2,oDlg:End() }) CENTERED

	If nOpcA == 1
		ConfirmSX8()
		AF110Grv(,,,.F.)
	Else
		RollBackSX8()
	EndIf

//Apontamentos multiplos
ElseIf nOpcX == APTO_MULTI
	If !lDefTop
		Help("",1,"AF110NOTOP")		//"Rotina disponível apenas para ambientes TopConnect / byYou DBAccess."
		Return
	EndIf

	aObjects := {}
	AADD(aObjects, {100,100, .T., .T.})
	AADD(aObjects, {100,100, .T., .T.})

	aInfo := {aSize[1], aSize[2], aSize[3]*2, aSize[4]*2, 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects)

	//Monta o array com os campos a serem exibidos no apontamento multiplos
	aAcho := {"FNA_DATA","FNA_OCORR","FNA_DTPERI","FNA_DTPERF","FNA_QUANTD"}

	//Montagem da tela de apontamentos multiplos
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[1],aSize[1] To aSize[6],aSize[5] of oMainWnd PIXEL
		oDlg:lMaximized := .T.

		RegToMemory("FNA", .T., .T., .T.)

		//Enchoice("FNA", nReg, nOpc,,,, aAcho, aPosObj[1], aAcho, 3,,, /*cTudoOk*/, oDlg)
		oEncMult := MsMGet():New("FNA",nReg,nOpc,,,,aAcho,{0,0,0,0},,,,,,oDlg)
		oEncMult:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(AF110TudOk(.T.),(nOpcA := 1, oDlg:End()),) },{|| nOpcA := 2,oDlg:End() }) CENTERED

	If nOpcA == 1
		cOcor := M->FNA_OCORR
		aRetP1 := {}

		If cOcor $ "P8|P9|"
			lRetPar := AFA110ParBox(@aRetP1,DTOS(M->FNA_DATA))
			If !lRetPar
				Return
			EndIf
			lEstorno := .T.
		Else
			Pergunte("AFA110", .T.)
			lEstorno := .F.
		EndIf

		//Cria arquivo temporário com os registros a partir do range dos parâmetros
		aCpos := AF110Trb(cOcor,lEstorno,aRetP1)

		If Select("TRB") > 0
			dbSelectArea("TRB")
			dbGoTop()
		Else
			Help("",1,"AF110NOTRB")		//"Não foram encontrados bens de acordo com os parâmetros informados."##"Preencha corretamente as perguntas para filtrar os bens desejados."
			Return
		EndIf

		//Captura a marca corrente
		cMarca := GetMark( , "TRB", cN3Ok)

		//Browse de marcação para inclusão dos apontamentos multiplos
		DEFINE MSDIALOG oDlgApt TITLE cCadastro From aSize[1],aSize[1] To aSize[6],aSize[5] OF oMainWnd PIXEL
			oDlgApt:lMaximized := .T.

			oMark := MsSelect():New("TRB",cN3Ok,, aCpos,.F.,@cMarca,{50,oDlgApt:nLeft,oDlgApt:nBottom,oDlgApt:nRight})
			oMark:bMark := {|| AF110Inv(cMarca,.F.,oMark)}
			oMark:bAval	:= {|| AF110Inv(cMarca,.F.,oMark)}
			oMark:oBrowse:lHasMark := .T.
			//oMark:oBrowse:lCanAllmark := .T.
			oMark:oBrowse:bAllMark := {|| AF110Inv(cMarca,.T.,oMark)}
			oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		ACTIVATE MSDIALOG oDlgApt ON INIT EnchoiceBar( oDlgApt, {|| IIF(nQtdMark > 0, (nOpcB := 1, oDlgApt:End()), Help(" ",1,"RECNO"))}, {|| nOpcB := 2, oDlgApt:End()}, .F., /*aButtons*/, /*nRecno*/, /*cAlias*/)

		If nOpcB == 1
			nRecno := FNA->(Recno())

			Begin Transaction

			AF110Grv(nRecno,cMarca,cN3Ok,.T.)
			ConfirmSX8()

			End Transaction
		Else
			RollBackSX8()
		EndIf

	Else
		RollBackSX8()
	EndIf

	If Select("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	
	If _oATFA1101 <> Nil
		_oATFA1101:Delete()
		_oATFA1101 := Nil
	Endif
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110TudOk   ºAutor  ³Renan Guedes     º Data ³  05/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação Tudo Ok da tela de apontamentos de produção       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF110TudOk(lMulti)

Local lRet		:= .T.
Local aArea		:= {}
Local aAreaSN1	:= {}
Local aAreaSN3	:= {}
Local aAreaFNA	:= {}
Local dDataBloq	:= GetNewPar("MV_ATFBLQM", CTOD(""))
Local dUltDepr	:= GetNewPar("MV_ULTDEPR", STOD("19800101"))
Local lTemRev	:= .F.
Local lTemApto	:= .F.
Local cCpobco	:= ""

Default lMulti	:= .F.

aArea := GetArea()

dbSelectArea("SX3")
dbSetOrder(2)		//X3_CAMPO
dbGoTop()

dbSelectArea("SN1")
aAreaSN1 := SN1->(GetArea())
dbSetOrder(1)		//N1_FILIAL+N1_CBASE+N1_ITEM
dbGoTop()

dbSelectArea("SN3")
aAreaSN3 := SN3->(GetArea())
dbSetOrder(1)		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
dbGoTop()

dbSelectArea("FNA")
aAreaFNA := FNA->(GetArea())
dbSetOrder(2)		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
dbGoTop()

If !Empty(M->FNA_DATA) .And. (M->FNA_DATA <= dDataBloq)
	HELP(" ",1,"AF110BLQM",,STR0029 + DTOC(dDataBloq) ,1,0)		//"A data de movimentação do apontamento é menor do que a data de bloqueio de movimentações:" ## "A data de registro de apontamentos deve ser maior do que a data de bloqueio de movimentações."
	lRet := .F.
EndIf

//Validacao para o bloquei do proceco
If lRet .And. !CtbValiDt(,M->FNA_DATA  ,,,,{"ATF001"},)
	lRet := .F.
EndIf  

If lRet .and. !Empty(M->FNA_DATA)
	If M->FNA_DATA <= dUltDepr
		Help(" ",1,"A110DEPR1",,STR0030 + DTOC(dUltDepr),1,0)		//"A data de movimentação do apontamento é menor do que a data do último cálculo de depreciação:" ##
		lRet := .F.
	ElseIf M->FNA_DATA > LastDay(dUltDepr+1)
		Help(" ",1,"A110DEPR1",,STR0034 + CRLF + STR0035 + DTOC(LastDay(dUltDepr+1)),1,0)		//"O apontamento somente poderá ser realizado no mês imediatamente posterior ao último cálculo de depreciação."###"Data limite: "
		lRet := .F.
	Endif
EndIf

If lRet .And. !lMulti
	If SN1->(MsSeek(xFilial("SN1")+M->FNA_CBASE+M->FNA_ITEM))
		If SN1->N1_STATUS != "1"
			lRet := .F.
			Help("",1,"AF110ATFBL")		//"Este bem está bloqueado."##"Somente bens desbloqueados podem ser movimentados."
		EndIf
	EndIf
EndIf

If lRet .And. !lMulti .And. !(M->FNA_OCORR $ "P8|P9|")
	If FNA->(MsSeek( xFilial("FNA") + M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)) ))
		While FNA->(!EoF()) .And. (FNA->FNA_FILIAL == xFilial("FNA"))	;
			.And. FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA))	;
			== M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA))
			If !(FNA->FNA_OCORR $ "P0|P5|P8|P9|") .And. (FNA->FNA_ESTORN != "1")
				lRet := .F.
				Help("",1,"AF110EXAPT")		//"Existe um apontamento gravado para a mesma data."##"Não é possível realizar mais de um apontamento para uma mesma data."
				Exit
			EndIf
			FNA->(dbSkip())
		EndDo
	EndIf
EndIf

If lRet .And. lMulti
	If Empty(M->FNA_DATA)
		lRet := .F.
		If SX3->(MsSeek("FNA_DATA"))
			cCpobco += X3Titulo() + "(FNA_DATA)" + CRLF
		EndIf
	EndIf
	If Empty(AllTrim(M->FNA_OCORR))
		lRet := .F.
		If SX3->(MsSeek("FNA_OCORR"))
			cCpobco += X3Titulo() + "(FNA_OCORR)" + CRLF
		EndIf
	EndIf
	If !lRet
		Help("",1,"AF110CPBCO",,STR0028 + cCpobco,1,0)		//"Campo não preenchido."##"Preencha o campo informado."
	EndIf
EndIf

If lRet .And. M->FNA_OCORR == "P0"
	lRet := .F.
	Help("",1,"AF110NOP0")		//"A estimativa de produção não pode ser apontada manualmente."##"Para alterar a estimativa de produção, selecione a ocorrência de revisão de estimativa de produção."
EndIf

If lRet .And. M->FNA_OCORR == "P5"
	lRet := .F.
	Help("",1,"AF110NOP5")		//"A produção acumulada não pode ser apontada manualmente."##"Produções acumuladas são apontadas automaticamente na inclusão de bens."
EndIf

If lRet .And. M->FNA_OCORR $ "P1|P2|"
	If M->FNA_QUANTD == 0
		lRet := .F.
		Help("",1,"AF110QTD0")		//"A quantidade apontada não pode ser igual a 0 (zero)."##"Informe a quantidade do apontamento."
	EndIf
EndIf

If lRet .And. M->FNA_OCORR $ "P2|P3|"
	If Empty(M->FNA_DTPERI) .Or. Empty(M->FNA_DTPERF)
		lRet := .F.
		Help("",1,"AF110NOPER")		//"O período inicial e/ou o período final não foi informado."##"Informe os períodos inicial e final do apontamento."
	Else
		If (M->FNA_DTPERF > LastDay(M->FNA_DTPERI)) .Or. (M->FNA_DTPERF < M->FNA_DTPERI)
			lRet := .F.
			Help("",1,"AF110PERF")		//"Os períodos inicial e final do apontamento devem compreender ao mesmo mês."##"Informe um período final maior ou igual ao inicial e menor ou igual ao último dia do mesmo mês."
		EndIf
	EndIf
EndIf

If lRet .And. !lMulti .And. M->FNA_OCORR $ "P2|P3|"
	If FNA->(MsSeek( xFilial("FNA") + M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) ))
		While FNA->(!EoF()) .And. (FNA->FNA_FILIAL == xFilial("FNA")) .And. (FNA->FNA_CBASE == M->FNA_CBASE) .And.;
				(FNA->FNA_ITEM == M->FNA_ITEM) .And. (FNA->FNA_TIPO == M->FNA_TIPO)
			If ((M->FNA_DTPERI >= FNA->FNA_DTPERI .And. M->FNA_DTPERI <= FNA->FNA_DTPERF)		;
				.Or. (M->FNA_DTPERF >= FNA->FNA_DTPERI .And. M->FNA_DTPERF <= FNA->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERI >= M->FNA_DTPERI .And. FNA->FNA_DTPERI <= M->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERF >= M->FNA_DTPERI .And. FNA->FNA_DTPERF <= M->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERI >= M->FNA_DTPERI .And. FNA->FNA_DTPERI <= M->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERF >= M->FNA_DTPERI .And. FNA->FNA_DTPERF <= M->FNA_DTPERF))	;
				.And. !(FNA->FNA_OCORR $ "P0|P1|P5|P8|P9") .And. (FNA->FNA_ESTORN != "1")
				lRet := .F.
				Help("",1,"AF110PEREX")		//"Existe um apontamento gravado para um período igual ou correspondente."##"Informe outro período de apontamento ou estorne o apontamento existente."
				Exit
			EndIf
			FNA->(dbSkip())
		EndDo
	EndIf
EndIf

If lRet
	If !(M->FNA_OCORR $ "P4|P9|") .And. !lMulti
		If SN3->(MsSeek(xFilial("SN3")+M->FNA_CBASE+M->FNA_ITEM+M->FNA_TIPO+"0"+M->FNA_SEQ))
			If !Empty(SN3->N3_DEXAUST) .Or. !Empty(SN3->N3_FIMDEPR)
				lRet := .F.
				Help("",1,"AF110EX")		//"Este bem já foi exaurido."##"Bens exauridos não podem ser movimentados."
			ElseIf M->FNA_OCORR == "P2" .And. M->FNA_QUANTD + SN3->N3_PRODACM > SN3->N3_PRODANO
				lRet := .F.
				Help("",1,"AF110P2QT") //"A quantidade apontada, somada à produção acumulada do bem, é maior que o valor de produção estimada." ## "Informe uma quantidade menor para este apontamento de produção."
			EndIf
		EndIf
	ElseIf M->FNA_OCORR == "P4" .And. !lMulti
		If SN3->(MsSeek(xFilial("SN3")+M->FNA_CBASE+M->FNA_ITEM+M->FNA_TIPO+"0"+M->FNA_SEQ))
			If Empty(SN3->N3_DEXAUST) .Or. Empty(SN3->N3_FIMDEPR)
				lRet := .F.
				Help("",1,"AF110NOEX")		//"Este bem não foi exaurido."##"Apontamentos complementares somente podem ser realizados para bens já exauridos."
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. !lMulti .And. M->FNA_OCORR == "P8"
	If FNA->(MsSeek( xFilial("FNA") + M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) ))
		While FNA->(!EoF()) .And. FNA->FNA_FILIAL == xFilial("FNA")	;
			.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD))
			//Verifica se há apontamentos de produção para o bem
			If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. !(FNA->FNA_OCORR $ "P0|P1|P5|P8|P9|") .And. (FNA->FNA_ESTORN != "1")
				lRet := .F.
				Help("",1,"AF110NOP8")		//"Não é possível estornar a revisão de estimativa de produção de bens apontados."##"Para alterar a estimativa de produção é necessário realizar um apontamento de revisão de estimativa de produção."
				Exit
			EndIf
			//Verifica se há revisão de estimativa para o bem
			If (FNA->FNA_DATA == M->FNA_DATA) .And. (FNA->FNA_OCORR == "P1") .And. (FNA->FNA_ESTORN != "1")
				lTemRev := .T.
			EndIf
			FNA->(dbSkip())
		EndDo
		//Check e help do estorno da revisão de estimativa
		If lRet .And. !lTemRev
			lRet := .F.
			Help("",1,"AF110NOREV")		//"Não existe revisão de estimativa de produção a ser estornada para o bem."##"Somente é possível estornar a revisão de estimativa de produção para bens que tiveram a estimativa revisada."
		EndIf
		If lRet
			If FNA->(MsSeek( xFilial("FNA") + M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD)+DTOS(M->FNA_DATA) ))
				While FNA->(!EoF()) .And. FNA->FNA_FILIAL == xFilial("FNA")	;
				.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD))
				If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_DATA > M->FNA_DATA) .And. (FNA->FNA_ESTORN != "1")
					lRet := .F.
					Help("",1,"AF110APPOS")		//"Existe apontamento posterior a data informada."##"É necessário estornar os apontamentos posteriores a data informada."
					Exit
				EndIf
				FNA->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. !lMulti .And. M->FNA_OCORR == "P9"
	If FNA->(MsSeek( xFilial("FNA") + M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)) ))
		While FNA->(!EoF()) .And. FNA->FNA_FILIAL == xFilial("FNA")	;
			.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)) == M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)))
			If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_OCORR $ "P2|P3|P4|") .And. (FNA->FNA_ESTORN != "1")
				lTemApto := .T.
				Exit
			EndIf
			FNA->(dbSkip())
		EndDo
		If !lTemApto
			lRet := .F.
			Help("",1,"AF110NOAPT")		//"Não existe apontamento a ser estornado para o bem."##"Somente é possível estornar apontamentos existentes e no mês/ano do cálculo de depreciação."
		Else
			If FNA->(MsSeek( xFilial("FNA") + M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)) ))
				While FNA->(!EoF()) .And. FNA->FNA_FILIAL == xFilial("FNA")	;
				.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD))
				If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_DATA > M->FNA_DATA) .And. (FNA->FNA_OCORR == "P3") .And. (FNA->FNA_ESTORN != "1")
					lRet := .F.
					Help("",1,"AF110EXENC")		//"Não é possível estornar apontamentos anteriores ao encerramento de produção para bens cuja produção foi encerrada."##"É necessário, primeiramente, estornar o encerramento de produção na data em que tenha ocorrido, para então estornar os apontamentos anteriores."
					Exit
				EndIf
				FNA->(dbSkip())
				EndDo
			EndIf
			If lRet
				If FNA->(MsSeek( xFilial("FNA") + M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)) ))
					While FNA->(!EoF()) .And. FNA->FNA_FILIAL == xFilial("FNA")	;
					.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD))
					If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_DATA > M->FNA_DATA) .And. (FNA->FNA_OCORR $ "P2|P4|") .And. (FNA->FNA_ESTORN != "1")
						lRet := .F.
						Help("",1,"AF110APPOS")		//"Existe apontamento posterior a data informada."##"É necessário estornar os apontamentos posteriores a data informada."
						Exit
					EndIf
					FNA->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaFNA)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110IniBrw   ºAutor  ³Renan Guedes    º Data ³  05/24/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao executada antes de iniciar o browse, para atualizar  º±±
±±º          ³os campos com os dados do registro SN3 posicionado.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF110IniBrw()

Local aArea		:= {}

aArea := GetArea()
M->FNA_IDMOV	:= GetSXENum("FNA", "FNA_IDMOV")
M->FNA_ITMOV	:= StrZero(1,TamSX3("FNA_ITMOV")[1])
M->FNA_CBASE 	:= SN3->N3_CBASE
M->FNA_ITEM		:= SN3->N3_ITEM
M->FNA_TIPO		:= SN3->N3_TIPO
M->FNA_SEQ		:= SN3->N3_SEQ
M->FNA_SEQREA	:= SN3->N3_SEQREAV
M->FNA_TPSALD	:= SN3->N3_TPSALDO
M->FNA_TPDEPR	:= SN3->N3_TPDEPR
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110Trb   ºAutor  ³Renan Guedes       º Data ³  05/25/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montagem do arquivo de trabalho para a função de 			  º±±
±±º          ³apontamentos multiplos                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF110Trb(cOcor,lEstorno,aRetP1)

Local cTrb
Local cIndex
Local cChave		:= "N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ"
Local aArea			:= {}
Local aStru			:= {}
Local aCampos		:= {}
Local cCampos		:= ""
Local cQuery		:= ""
Local nX			:= 0
Local nTamMoeda		:= TamSX3("FNA_MOEDA")[1]
Local cTypes10		:= IIF(lIsRussia,AtfNValMod({1}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10		:= {}
Local nTypes10		:= 0
Local cTypesNM		:= IIF(lIsRussia,AtfNValMod({3,4}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - 17 and 16 models
Local aTypesNM		:= {}
Local nTypesNM		:= 0

Default cOcor		:= ""
Default lEstorno	:= .F.
Default aRetP1		:= {{""},{""}}

aArea := GetArea()

dbSelectArea("SX3")
dbSetOrder(2)		//X3_CAMPO
dbGoTop()
If SX3->(dbSeek("N3_OK"))
	AADD(aStru, {AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
	AADD(aCampos, {AllTrim(SX3->X3_CAMPO),, "", AllTrim(SX3->X3_PICTURE)})
EndIf

dbSetOrder(1)		//X3_ARQUIVO+X3_ORDEM
dbGoTop()
If SX3->(dbSeek("SN3"))
	While SX3->(!EoF()) .And. (SX3->X3_ARQUIVO == "SN3")
		If (AllTrim(SX3->X3_CAMPO) $ "N3_FILIAL|N3_CBASE|N3_ITEM|N3_TIPO|N3_BAIXA|N3_SEQ|N3_SEQREAV|N3_FIMDEPR") .Or. (X3Uso(SX3->X3_USADO) .And. (SX3->X3_NIVEL <= cNivel) .And. (X3_TIPO <> "M"))
			AADD(aStru, {AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
			AADD(aCampos, {AllTrim(SX3->X3_CAMPO),, X3Titulo(), AllTrim(SX3->X3_PICTURE)})
		EndIf
		SX3->(dbSkip())
	EndDo
EndIf

dbSelectArea("FNA")
dbSetOrder(1)		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR
dbGoTop()

RestArea(aArea)

aEval(aStru,{|aCpoSQL| nX++, cCampos += aCpoSQL[1]+IIF(nX == Len(aStru)," ",", ")})

cQuery += " SELECT "+cCampos+" FROM "+RetSqlName("SN3")+" SN3 "
cQuery += "		INNER JOIN "+RetSqlName("SN1")+" SN1 "
cQuery += "			ON "
cQuery += "				SN1.N1_FILIAL = SN3.N3_FILIAL AND "
cQuery += "				SN1.N1_CBASE = SN3.N3_CBASE AND "
cQuery += "				SN1.N1_ITEM = SN3.N3_ITEM "

If lEstorno
	cQuery += "		INNER JOIN "+RetSqlName("FNA")+" FNA "
	cQuery += "			ON "
	cQuery += "				FNA.FNA_FILIAL = SN3.N3_FILIAL AND "
	cQuery += "				FNA.FNA_CBASE = SN3.N3_CBASE AND "
	cQuery += "				FNA.FNA_ITEM = SN3.N3_ITEM AND "
	cQuery += "				FNA.FNA_TIPO = SN3.N3_TIPO AND "
	cQuery += "				FNA.FNA_SEQ = SN3.N3_SEQ AND "
	cQuery += "				FNA.FNA_SEQREA = SN3.N3_SEQREAV AND "
	cQuery += "				FNA.FNA_TPSALD = SN3.N3_TPSALDO AND "
	cQuery += "				FNA.FNA_TPDEPR = SN3.N3_TPDEPR "
	cQuery += "		WHERE "
	cQuery += "			SN3.D_E_L_E_T_ = ' ' AND "
	cQuery += "			SN1.D_E_L_E_T_ = ' ' AND "
	cQuery += "			FNA.D_E_L_E_T_ = ' ' AND "
	cQuery += "			FNA.FNA_FILIAL = '"+xFilial("FNA",aRetP1[1])+"' AND "
	cQuery += "			FNA.FNA_IDMOV = '"+aRetP1[2]+"' AND "

	If cOcor != 'P8'
		cQuery += "			FNA.FNA_MOEDA = '1 ' AND "
	Endif

	cQuery += "			FNA.FNA_ESTORN = '2' "
Else
	cQuery += "		WHERE "
	cQuery += "			SN3.D_E_L_E_T_ = ' ' AND "
	cQuery += "			SN1.D_E_L_E_T_ = ' ' AND "
	cQuery += "			SN3.N3_FILIAL = '"+xFilial("SN3",mv_par01)+"' AND "
	If !lIsRussia // CAZARINI - Flag to indicate if is Russia location
		cQuery += "			SN3.N3_TIPO IN ('01','10','16','17') AND "
	Else
		aTypes10 := Separa(cTypes10, '|', .f.)
		aTypesNM := Separa(cTypesNM, '|', .f.)
		
		If len(aTypes10) = 0 .AND. len(aTypesNM) = 0
			cQuery += "			SN3.N3_TIPO IN ('01','10','16','17') AND "
		Else
			cQuery += "			SN3.N3_TIPO IN ('01','10','16','17'"
			
			For nTypes10 := 1 to len(aTypes10)
				cQuery += ",'" + aTypes10[nTypes10] + "')"
			Next nTypes10
			
			For nTypesNM := 1 to len(aTypesNM)
				cQuery += ",'" + aTypesNM[nTypesNM] + "')"
			Next nTypesNM
			
			cQuery += "			) AND "
		Endif
	EndIf
	cQuery += "			SN3.N3_BAIXA = '0' AND "
	cQuery += "			SN3.N3_TPDEPR IN ('4','5','8','9') AND "
	cQuery += " 		(SN3.N3_CBASE >= '"+MV_PAR02+"' AND "
	cQuery += " 		SN3.N3_CBASE <= '"+MV_PAR03+"') AND "
	cQuery += "			(SN3.N3_ITEM >= '"+MV_PAR04+"' AND "
	cQuery += "			SN3.N3_ITEM <= '"+MV_PAR05+"') AND "
	cQuery += " 		(SN3.N3_CCONTAB >= '"+MV_PAR06+"' AND "
	cQuery += " 		SN3.N3_CCONTAB <= '"+MV_PAR07+"') AND "
	If cOcor == "P4"
		cQuery += "		SN3.N3_FIMDEPR != '        ' AND "
	Else
		cQuery += "		SN3.N3_FIMDEPR = '        ' AND "
	EndIf
	cQuery += " 		(SN1.N1_GRUPO >= '"+MV_PAR08+"' AND "
	cQuery += " 		SN1.N1_GRUPO <= '"+MV_PAR09+"') "
EndIf
cQuery += "		ORDER BY N3_FILIAL,N3_CBASE,N3_ITEM,N3_TIPO,N3_BAIXA,N3_SEQ"
cQuery := ChangeQuery(cQuery)

If Select("SQL") != 0
	dbSelectArea("SQL")
	dbCloseArea()
EndIf

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "SQL", .F.)
dbGoTop()

If SQL->(EoF())
	dbCloseArea()
	Return
EndIf

For nX := 1 to Len(aStru)
	If !(aStru[nX][2] $ "C/M")
		TCSetField("SQL",aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
	EndIf
   		Next nX

If Select("TRB") != 0
	dbSelectArea("TRB")
	dbCloseArea()
EndIf

If _oATFA1101 <> Nil
	_oATFA1101:Delete()
	_oATFA1101 := Nil
Endif

_oATFA1101 := FWTemporaryTable():New( "TRB" )  
_oATFA1101:SetFields(aStru) 
_oATFA1101:AddIndex("1", {"N3_FILIAL","N3_CBASE","N3_ITEM","N3_TIPO","N3_BAIXA","N3_SEQ"})

//------------------
//Criação da tabela temporaria
//------------------
_oATFA1101:Create()  

dbSelectArea("SQL")
dbGoTop()
While SQL->(!EoF())
	RecLock("TRB",.T.)
	For nX := 1 To Len(aStru)
		TRB->&(aStru[nX,1]) := SQL->&(aStru[nX,1])
	Next nX
	MsUnlock()
	SQL->(dbSkip())
EndDo

dbSelectArea("SQL")
dbCloseArea()

dbSelectArea("TRB")
dbGoTop()

Return(aCampos)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110Inv   ºAutor  ³Renan Guedes       º Data ³  05/25/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca/desmarca os registros dos bens (SN3) na tabela 		  º±±
±±º          ³temporária.                                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF110Inv(cMarca,lTodos,oMark)

Local nRecno	:= TRB->(Recno())
Local nTamOk	:= TamSX3("N3_OK")[1]
Local aArea		:= {}
Local aAreaSN1	:= {}
Local aAreaSN3	:= {}
Local aAreaFNA	:= {}

Default lTodos	:= .F.

aArea := GetArea()

dbSelectArea("SN1")
aAreaSN1 := SN1->(GetArea())
dbSetOrder(1)		//N1_FILIAL+N1_CBASE+N1_ITEM
dbGoTop()

dbSelectArea("SN3")
aAreaSN3 := SN3->(GetArea())
dbSetOrder(1)		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
dbGoTop()

dbSelectArea("FNA")
aAreaFNA := FNA->(GetArea())
dbSetOrder(2)		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
dbGoTop()

dbSelectArea("TRB")
If lTodos
	dbGoTop()
EndIf

While !lTodos .Or. TRB->(!EoF())
	//Se estiver marcado, apenas desmarca
	If TRB->N3_OK == cMarca
		RecLock("TRB",.F.)
		TRB->N3_OK := Space(nTamOk)
		TRB->(MsUnlock())
		nQtdMark--
	Else
		If AF110ValMrk(oMark,lTodos)		//Valida a marcação do registro
			//Marca o registro
			RecLock("TRB",.F.)
			TRB->N3_OK := cMarca
			TRB->(MsUnlock())
			nQtdMark++
		EndIf
	EndIf

	If lTodos
		TRB->(dbSkip())
	Else
		Exit
	EndIf
EndDo

RestArea(aAreaFNA)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

TRB->(dbGoTo(nRecno))

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110Grv   ºAutor  ³Renan Guedes       º Data ³  05/26/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravação dos registros                                      º±±
±±º          ³Se o apontamento for simples, apenas atualiza alguns dados  º±±
±±º          ³na tabela FNA.											  º±±
±±º          ³															  º±±
±±º          ³Se o apontamento for multiplo, grava todos os registros na  º±±
±±º          ³tabela FNA.												  º±±
±±º          ³															  º±±
±±º          ³Grava os registros na tabela SN4.							  º±±
±±º          ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF110Grv(nRecno,cMarca,cN3Ok,lMulti)

Local aTxDepr		:= {}
Local cTabela		:= ""
Local aMemFNA		:= {}
Local nX			:= 0
Local nHdlPrv		:= 0
Local nTotal		:= 0
Local cArquivo		:= ""
Local cLoteAtf		:= LoteCont("ATF")

Private nDecQtd, nDecCoef, nDecMes, nDecAno, nDecAcm

Default nRecno		:= 1
Default cN3Ok		:= "N3_OK"
Default lMulti		:= .F.
Default cMarca		:= ""

nDecQtd := nDecCoef := nDecMes := nDecAno := nDecAcm := 0

//Monta matriz das moedas utilizadas para o cálculo de exaustão
aTxDepr := IIF(lMultMoed, AtfMultMoe(,,{|xMoeda| 0 }) , {0,0,0,0,0} )

//Captura os decimais dos campos numéricos para os apontamentos multiplos
dbSelectArea("SX3")
dbSetOrder(2)		//X3_CAMPO
dbGoTop()
If SX3->(MsSeek("FNA_QUANTD"))
	nDecQtd := SX3->X3_DECIMAL
EndIf
If SX3->(MsSeek("FNA_COEFIC"))
	nDecCoef := SX3->X3_DECIMAL
EndIf
If SX3->(MsSeek("N3_PRODMES"))
	nDecMes := SX3->X3_DECIMAL
EndIf
If SX3->(MsSeek("N3_PRODANO"))
	nDecAno := SX3->X3_DECIMAL
EndIf
If SX3->(MsSeek("N3_PRODACM"))
	nDecAcm := SX3->X3_DECIMAL
EndIf

If lMulti
	//Abre a tabela temporária
	dbSelectArea("TRB")
	dbGoTop()

	cTabela	:= "TRB"
	AADD(aMemFNA, GetSXENum("FNA", "FNA_IDMOV"))
	AADD(aMemFNA, StrZero(1,TamSX3("FNA_ITMOV")[1]))
Else
	dbSelectArea("SN3")
	dbSetOrder(1)		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	dbGoTop()

	cTabela	:= "SN3"
	AADD(aMemFNA, M->FNA_IDMOV)
	AADD(aMemFNA, M->FNA_ITMOV)
EndIf

AADD(aMemFNA, M->FNA_DATA)
AADD(aMemFNA, M->FNA_OCORR)
AADD(aMemFNA, M->FNA_DTPERI)
AADD(aMemFNA, M->FNA_DTPERF)
AADD(aMemFNA, M->FNA_QUANTD)

//Abre a contabilização
nHdlPrv := HeadProva(cLoteAtf,"ATFA110",Substr(cUsername,1,6),@cArquivo)

If lMulti
	While TRB->(!EoF())
		If TRB->&(cN3Ok) == cMarca
			//Grava o apontamento em todas as moedas utilizadas
			AF110GrvMoeda(cTabela,aTxDepr,aMemFNA,lMulti,@nHdlPrv,@nTotal,@cArquivo)
		EndIf
		TRB->(dbSkip())
	EndDo
Else
	If SN3->(MsSeek(xFilial("SN3")+M->(FNA_CBASE+FNA_ITEM+FNA_TIPO+"0"+FNA_SEQ)))
		//Grava o apontamento em todas as moedas utilizadas
		AF110GrvMoeda(cTabela,aTxDepr,aMemFNA,lMulti,@nHdlPrv,@nTotal,@cArquivo)
	EndIf
EndIf

Pergunte("AFA110CONT",.F.)
lMostra := IIF(MV_PAR01 == 1, .T., .F.)
lAglutina := IIF(MV_PAR02 == 1, .T., .F.)

If (nHdlPrv > 0) .And. (nTotal > 0)
	RodaProva(nHdlPrv, nTotal)
	cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lMostra,lAglutina)
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110ValMrk   ºAutor  ³Renan Guedes    º Data ³  06/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a marcação do item do ativo (SN3) nos apontamentos   º±±
±±º          ³multiplos                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF110ValMrk(oMark,lTodos)

Local lRet		:= .T.
Local lTemRev	:= .F.
Local dUltDepr	:= GetNewPar("MV_ULTDEPR", STOD("19800101"))
Local lTemApto	:= .T.

Default lTodos	:= .F.

If lRet
	If SN1->(MsSeek(xFilial("SN1")+TRB->(N3_CBASE+N3_ITEM)))
		If SN1->N1_STATUS != "1"
			lRet := .F.
			If !lTodos
				Help("",1,"AF110ATFBL")		//"Este bem está bloqueado."##"Somente bens desbloqueados podem ser movimentados."
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. !(M->FNA_OCORR $ "P8|P9|")
	If FNA->(MsSeek( xFilial("FNA") + TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)+DTOS(M->FNA_DATA) ))
		While FNA->(!EoF()) .And. (FNA->FNA_FILIAL == TRB->N3_FILIAL)	;
			.And. FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA))	;
			== TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)+DTOS(M->FNA_DATA)
			If !(FNA->FNA_OCORR $ "P0|P5|P8|P9|") .And. (FNA->FNA_ESTORN != "1")
				lRet := .F.
				If !lTodos
					Help("",1,"AF110EXAPT")		//"Existe um apontamento gravado para a mesma data."##"Não é possível realizar mais de um apontamento para uma mesma data."
				EndIf
				Exit
			EndIf
			FNA->(dbSkip())
		EndDo
	EndIf
EndIf

If lRet .And. M->FNA_OCORR $ "P2|P3|"
	If FNA->(MsSeek( xFilial("FNA") + TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO) ))
		While FNA->(!EoF()) .And. (FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO) == TRB->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO))
			If ((M->FNA_DTPERI >= FNA->FNA_DTPERI .And. M->FNA_DTPERI <= FNA->FNA_DTPERF)		;
				.Or. (M->FNA_DTPERF >= FNA->FNA_DTPERI .And. M->FNA_DTPERF <= FNA->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERI >= M->FNA_DTPERI .And. FNA->FNA_DTPERI <= M->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERF >= M->FNA_DTPERI .And. FNA->FNA_DTPERF <= M->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERI >= M->FNA_DTPERI .And. FNA->FNA_DTPERI <= M->FNA_DTPERF)	;
				.Or. (FNA->FNA_DTPERF >= M->FNA_DTPERI .And. FNA->FNA_DTPERF <= M->FNA_DTPERF))	;
				.And. !(FNA->FNA_OCORR $ "P0|P1|P5|P8|P9") .And. (FNA->FNA_ESTORN != "1")
				lRet := .F.
				If !lTodos
					Help("",1,"AF110PEREX")		//"Existe um apontamento gravado para um período igual ou correspondente."##"Informe outro período de apontamento ou estorne o apontamento existente."
				EndIf
				Exit
			EndIf
			FNA->(dbSkip())
		EndDo
	EndIf
EndIf

If lRet
	If !(M->FNA_OCORR $ "P4|P9|")
		If SN3->(MsSeek(xFilial("SN3")+TRB->(N3_CBASE+N3_ITEM+N3_TIPO)+"0"+TRB->N3_SEQ))
			If !Empty(SN3->N3_DEXAUST) .Or. !Empty(SN3->N3_FIMDEPR)
				lRet := .F.
				If !lTodos
					Help("",1,"AF110EX")		//"Este bem já foi exaurido."##"Bens exauridos não podem ser movimentados."
				EndIf
			EndIf
		EndIf
	ElseIf M->FNA_OCORR == "P4"
		If SN3->(MsSeek(xFilial("SN3")+TRB->(N3_CBASE+N3_ITEM+N3_TIPO)+"0"+TRB->N3_SEQ))
			If Empty(SN3->N3_DEXAUST) .Or. Empty(SN3->N3_FIMDEPR)
				lRet := .F.
				If !lTodos
					Help("",1,"AF110NOEX")		//"Este bem não foi exaurido."##"Apontamentos complementares somente podem ser realizados para bens já exauridos."
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. M->FNA_OCORR == "P8"
	If FNA->(MsSeek( xFilial("FNA")+TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO) ))
		While FNA->(!EoF()) .And. FNA->FNA_FILIAL == TRB->N3_FILIAL	;
			.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO))
			//Verifica se há apontamentos de produção para o bem
			If (FNA->FNA_DATA == M->FNA_DATA) .And. !(FNA->FNA_OCORR $ "P0|P1|P5|P8|P9|") .And. (FNA->FNA_ESTORN != "1")
				lRet := .F.
				If !lTodos
					Help("",1,"AF110NOP8")		//"Não é possível estornar a revisão de estimativa de produção de bens apontados."##"Para alterar a estimativa de produção é necessário realizar um apontamento de revisão de estimativa de produção."
				EndIf
				Exit
			EndIf
			//Verifica se há revisão de estimativa para o bem
			If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_OCORR == "P1") .And. (FNA->FNA_ESTORN != "1")
				lTemRev := .T.
			EndIf
			FNA->(dbSkip())
		EndDo
		//Check e help do estorno da revisão de estimativa
		If lRet .And. !lTemRev
			lRet := .F.
			If !lTodos
				Help("",1,"AF110NOREV")		//"Não existe revisão de estimativa de produção a ser estornada para o bem."##"Somente é possível estornar a revisão de estimativa de produção para bens que tiveram a estimativa revisada."
			EndIf
		EndIf
		If lRet
			If FNA->(MsSeek( xFilial("FNA") + TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)+DTOS(M->FNA_DATA) ))
				While FNA->(!EoF()) .And. FNA->FNA_FILIAL == xFilial("FNA")	;
				.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO))
				If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_DATA > M->FNA_DATA) .And. (FNA->FNA_ESTORN != "1")
					lRet := .F.
					Help("",1,"AF110APPOS")		//"Existe apontamento posterior a data informada."##"É necessário estornar os apontamentos posteriores a data informada."
					Exit
				EndIf
				FNA->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. M->FNA_OCORR == "P9"
	If FNA->(MsSeek( xFilial("FNA") + TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)+DTOS(M->FNA_DATA) ))
		While FNA->(!EoF()) .And. FNA->FNA_FILIAL == TRB->N3_FILIAL	;
			.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)) == TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)+DTOS(M->FNA_DATA))
			If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_OCORR $ "P2|P3|P4|") .And. (FNA->FNA_ESTORN != "1")
				lTemApto := .T.
				Exit
			EndIf
			FNA->(dbSkip())
		EndDo
		If !lTemApto
			lRet := .F.
			If !lTodos
				Help("",1,"AF110NOAPT")		//"Não existe apontamento a ser estornado para o bem."##"Somente é possível estornar apontamentos existentes e no mês/ano do cálculo de depreciação."
			EndIf
		Else
			If FNA->(MsSeek( xFilial("FNA") + TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)+DTOS(M->FNA_DATA) ))
				While FNA->(!EoF()) .And. FNA->FNA_FILIAL == TRB->N3_FILIAL	;
				.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO))
				If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_DATA > M->FNA_DATA) .And. (FNA->FNA_OCORR == "P3") .And. (FNA->FNA_ESTORN != "1")
					lRet := .F.
					If !lTodos
						Help("",1,"AF110EXENC")		//"Não é possível estornar apontamentos anteriores ao encerramento de produção para bens cuja produção foi encerrada."##"É necessário, primeiramente, estornar o encerramento de produção na data em que tenha ocorrido, para então estornar os apontamentos anteriores."
					EndIf
					Exit
				EndIf
				FNA->(dbSkip())
				EndDo
			EndIf
			If lRet
				If FNA->(MsSeek( xFilial("FNA") + TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)+DTOS(M->FNA_DATA) ))
					While FNA->(!EoF()) .And. FNA->FNA_FILIAL == TRB->N3_FILIAL	;
					.And. (FNA->(FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == TRB->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO))
					If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_DATA > M->FNA_DATA) .And. (FNA->FNA_OCORR $ "P2|P4|") .And. (FNA->FNA_ESTORN != "1")
						lRet := .F.
						If !lTodos
							Help("",1,"AF110APPOS")		//"Existe apontamento posterior a data informada."##"É necessário estornar os apontamentos posteriores a data informada."
						EndIf
						Exit
					EndIf
					FNA->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110GrvP0   ºAutor  ³Renan Guedes     º Data ³  06/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravação da estimativa inicial de produção e/ou produção	  º±±
±±º          ³acumulada, chamada através da integração com a rotina de 	  º±±
±±º          ³inclusão de Ativo Imobilizado ATFA010                       º±±
±±º          ³		                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF110GrvAp(nRecno,cOcor)

Local nDecCoef		:= 0
Local nDecAcm		:= 0
Local aTxDepr		:= {}
Local aFatorDep		:= {}
Local aParam		:= {}
Local dDtMov

dbSelectArea("FNA")

If nRecno > 0
	//Captura os decimais dos campos numéricos para os apontamentos multiplos
	dbSelectArea("SX3")
	dbSetOrder(2)		//X3_CAMPO
	dbGoTop()
	If SX3->(MsSeek("FNA_COEFIC"))
		nDecCoef := SX3->X3_DECIMAL
	EndIf
	If SX3->(MsSeek("N3_PRODACM"))
		nDecAno := SX3->X3_DECIMAL
	EndIf

	SN3->(dbGoTo(nRecno))

	dDtMov := SN3->N3_DINDEPR

	RecLock("FNA",.T.)
	FNA->FNA_FILIAL	:= SN3->N3_FILIAL
	FNA->FNA_IDMOV	:= GetSXENum("FNA", "FNA_IDMOV")
	FNA->FNA_ITMOV	:= StrZero(1,TamSX3("FNA_ITMOV")[1])
	FNA->FNA_CBASE	:= SN3->N3_CBASE
	FNA->FNA_ITEM	:= SN3->N3_ITEM
	FNA->FNA_TIPO	:= SN3->N3_TIPO
	FNA->FNA_SEQ	:= SN3->N3_SEQ
	FNA->FNA_SEQREA	:= SN3->N3_SEQREAV
	FNA->FNA_TPSALD	:= SN3->N3_TPSALDO
	FNA->FNA_TPDEPR	:= SN3->N3_TPDEPR
	FNA->FNA_DATA	:= SN3->N3_DINDEPR
	FNA->FNA_ESTORN	:= '2'
	Do Case
		Case cOcor == "P0"
			FNA->FNA_QUANTD	:= SN3->N3_PRODANO
			lGeraMov		:= .F.
		Case cOcor == "P5"
			FNA->FNA_QUANTD	:= SN3->N3_PRODACM

			//Calcula o coeficiente de exaustão
			aTxDepr := IIF(lMultMoed, AtfMultMoe(,,{|xMoeda| 0 }) , {0,0,0,0,0} )
			aFatorDep := {}

			aParam := Array(9)
			aParam[1] := SN3->N3_VORIG1
			aParam[2] := SN3->N3_VRDACM1
			aParam[3] := SN3->N3_TPDEPR
			aParam[4] := SN3->N3_VMXDEPR
			aParam[5] := SN3->N3_PERDEPR
			aParam[6] := SN3->N3_VLSALV1
			aParam[7] := SN3->N3_PRODACM
			aParam[8] := SN3->N3_PRODANO
			aParam[9] := SN3->N3_FIMDEPR

			aFatorDep := AFatorCalc(aTxDepr, SN3->N3_DINDEPR, dDtMov, SN3->N3_TPDEPR, , , aParam)

			FNA->FNA_COEFIC	:= Round( NoRound( aFatorDep[1], nDecAcm+1 ) , nDecCoef )
	EndCase
	FNA->FNA_OCORR	:= cOcor
	FNA->FNA_DTPERI	:= SN3->N3_DINDEPR
	FNA->FNA_DTPERF	:= SN3->N3_FIMDEPR
	MsUnlock()

	ConfirmSX8()

	dbSelectArea("SN3")
	SN3->(dbGoTo(nRecno))
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110ValCp   ºAutor  ³Renan Guedes     º Data ³  06/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação dos campos do apontamento de produção             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCampo = Campo a ser validado (string)                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF110ValCp(cCampo)

Local lRet		:= .T.

Default cCampo	:= ""

Do Case
	Case Upper(AllTrim(cCampo)) == "FNA_OCORR"
		If M->FNA_OCORR $ "P0|P5|"
			lRet := .F.
			Help("",1,"AF110NOOCR")		//"As ocorrências de estimativa de produção e produção complementar não podem ser apontadas manualmente."##"Informe outra ocorrência de apontamento."
		EndIf
EndCase

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA110Hist   ºAutor  ³Renan Guedes     º Data ³  06/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Browse do histórico de apontamentos                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA110Hist()

Local aCores		:= {}

Private aRotina		:= MenuDef("FNA")
Private cCadastro	:= STR0026

//Cores da legenda das ocorrências de apontamento
AADD(aCores,{"FNA_OCORR == 'P0'"	,"BR_BRANCO"	})
AADD(aCores,{"FNA_OCORR == 'P1'"	,"BR_CINZA"		})
AADD(aCores,{"FNA_OCORR == 'P2'"	,"BR_VERDE"		})
AADD(aCores,{"FNA_OCORR == 'P3'"	,"BR_AMARELO"	})
AADD(aCores,{"FNA_OCORR == 'P4'"	,"BR_AZUL"		})
AADD(aCores,{"FNA_OCORR == 'P5'"	,"BR_MARROM"	})
AADD(aCores,{"FNA_OCORR == 'P8'"	,"BR_PINK"		})
AADD(aCores,{"FNA_OCORR == 'P9'"	,"BR_VERMELHO"	})

dbSelectArea("FNA")
dbSetOrder(1)

mBrowse(6, 1, 22, 75, "FNA", , , , , , aCores)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110Leg   ºAutor  ³Renan Guedes       º Data ³  06/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legenda das ocorrências do histórico de apontamentos        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF110Leg()

Local aLegenda := {}

//Montagem da legenda das ocorrências de apontamento
AADD(aLegenda,{"BR_BRANCO" 	,STR0018 })		//"Estimativa de produção inicial"
AADD(aLegenda,{"BR_CINZA" 	,STR0019 })		//"Revisão de estimativa"
AADD(aLegenda,{"BR_VERDE" 	,STR0020 })		//"Produção"
AADD(aLegenda,{"BR_AMARELO" ,STR0021 })		//"Encerramento de produção"
AADD(aLegenda,{"BR_AZUL" 	,STR0022 })		//"Produção complementar"
AADD(aLegenda,{"BR_MARROM" 	,STR0023 })		//"Produção acumulada"
AADD(aLegenda,{"BR_PINK" 	,STR0024 })		//"Estorno de revisão de estimativa"
AADD(aLegenda,{"BR_VERMELHO",STR0025 })		//"Estorno de produção"

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA110ParBox   ºAutor  ³Renan Guedes   º Data ³  06/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Parambox das perguntas do estorno multiplo                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFA110ParBox(aRetP1, cDataMov)

Local lRet			:= .F.
Local aParamBox		:= {}
Local cParTit		:= STR0027		//"Estornos múltiplos"
Local bParOk		:= {|| AF110ValP1(cDataMov)}
Local aParamRet		:= {}
Local nTamFil		:= IIF(lFWCodFil, FWGETTAMFILIAL, 2)
Local nTamId		:= TamSX3("FNA_IDMOV")[1]
Local nX			:= 0
Local cTitFil		:= ""
Local cTitId		:= ""

aRetP1 := {}

dbSelectArea("SX3")
dbSetOrder(2)		//X3_CAMPO
dbGoTop()
If SX3->(MsSeek("FNA_FILIAL"))
	cTitFil := X3Titulo()
EndIf
If SX3->(MsSeek("FNA_IDMOV"))
	cTitId := X3Titulo()
EndIf

dbSelectArea("FNA")
dbSetOrder(1)		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR
dbGoTop()

AADD(aParamBox,{1,cTitFil	,Space(nTamFil)	,"@!","AllwaysTrue()"	,"XM0"	,".T.",025,.T.})
AADD(aParamBox,{1,cTitId	,Space(nTamId)	,"@!","AllwaysTrue()"	,""		,".T.",045,.T.})

aParamRet := Array(Len(aParamBox))
For nX := 1 To Len(aParamBox)
	aParamRet[nX] := aParamBox[nX][3]
Next nX

lRet := ParamBox(aParamBox,@cParTit,@aParamRet,bParOk,,.T.,,,,"AF110P1",.T.,.T.)

If lRet
	aRetP1 := AjRetParam(aParamRet,aParamBox)

	Pergunte("AFA110CONT",.F.)
	lMostra := IIF(MV_PAR01 == 1, .T., .F.)
	lAglutina := IIF(MV_PAR02 == 1, .T., .F.)
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjRetParamºAutor  ³Alvaro Camillo Neto º Data ³  17/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta as repostas do aParambox                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 		                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjRetParam(aRet,aParamBox)

Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif
	Next nX
EndIf

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110ValP1   ºAutor  ³Renan Guedes     º Data ³  06/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as respostas da parambox da função de estornos	      º±±
±±º          ³multiplos                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF110ValP1(cDataMov)

Local lRet	:= .T.
Local aArea := GetArea()

FNA->(dbSetOrder(3))
If !MsSeek(xFilial("FNA",MV_PAR01)+MV_PAR02+cDataMov)
	HELP(" ",1,"A110DTPRC",,STR0031 + MV_PAR02 + STR0032 + DTOC(STOD(cDataMov)) + CRLF + STR0033,1,0) //"Não existe o processo "###" para o dia "###"Para que o apontamento de estorno seja feito corretamente, é necessário que o mesmo seja feito na mesma data do processo de apontamento original"
	lRet := .F.
EndIf

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110Coefic  ºAutor  ³Renan Guedes     º Data ³  06/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o coeficiente de exaustão do item do ativo, ou seja,º±±
±±º          ³a taxa de depreciação baseada no apontamento realizado      º±±
±±º          ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF110Coefic(aTxDepr,cTabela,nQuant,dDtMov,lEncerra)

Local aParam		:= Array(9)
Local aCoefic		:= {}

Default aTxDepr 	:= IIF(lMultMoed, AtfMultMoe(,,{|xMoeda| 0 }) , {0,0,0,0,0} )
Default cTabela		:= "SN3"
Default nQuant		:= 0
Default dDtMov		:= dDataBase	//Temp
Default lEncerra	:= .F.

aParam[1] := (cTabela)->N3_VORIG1
aParam[2] := (cTabela)->N3_VRDACM1
aParam[3] := (cTabela)->N3_TPDEPR
aParam[4] := (cTabela)->N3_VMXDEPR
aParam[5] := (cTabela)->N3_PERDEPR
aParam[6] := (cTabela)->N3_VLSALV1
aParam[7] := IIF(lEncerra, ((cTabela)->N3_PRODANO - (cTabela)->N3_PRODACM) , nQuant )
aParam[8] := (cTabela)->N3_PRODANO
aParam[9] := (cTabela)->N3_FIMDEPR

aCoefic := AFatorCalc(aTxDepr, (cTabela)->N3_DINDEPR, dDtMov, (cTabela)->N3_TPDEPR, , , aParam)

Return(aCoefic)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF110GrvMoeda   ºAutor  ³Renan Guedes  º Data ³  06/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a gravação do apontamento, inclusive para todas as      º±±
±±º          ³moedas utilizadas                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF110GrvMoeda(cTabela,aTxDepr,aMemFNA,lMulti,nHdlPrv,nTotal,cArquivo)

Local nX			:= 0
Local nY			:= 0
Local cIDMov  		:= ""
Local aFatorDep		:= {}
Local nTamMoeda		:= TamSX3("FNA_MOEDA")[1]
Local nRecFNA		:= 0
Local aRecFNA		:= {}
Local dUltDepr		:= GetNewPar("MV_ULTDEPR", STOD("19800101"))
Local nProdMes		:= 0
Local cPadrao		:= ""
Local lPadrao
Local cTipoFiscal	:= ATFXTpBem(1)
Local cTipoGerenc	:= ATFXTpBem(2)
Local aValDepr		:= {}
Local aDadosComp	:= {}
Local nTaxaMedia	:= 0
Local cN5_TIPO		:= ""
Local lGerouMov		:= .F.
Local cLoteAtf		:= LoteCont("ATF")
Local aAptoEst		:= {}
Local lGerouEst		:= .F.
Local nMoedaEst		:= 1
Local aAptos		:= {}
Local nUltApto		:= 0
Local nQtdEst		:= 0
Local nRecEst		:= 0
Local lEstExaust	:= .F.
Local nProdAcm		:= 0
Local aVrdMes		:= {}
Local aVrdAcm		:= {}
Local lOnOff		:= .T.
Local cTipDepr		:= "" 

Default cTabela		:= "SN3"
Default aTxDepr		:= IIF(lMultMoed, AtfMultMoe(,,{|xMoeda| 0 }) , {0,0,0,0,0} )
Default lMulti		:= .F.

Pergunte("AFA110CONT",.F.)
lOnOff := MV_PAR03 == 1


//Calcula a taxa de depreciação
If aMemFNA[4] $ "P2|P3|P4|"
	aFatorDep := {}
	aFatorDep := AF110Coefic( @aTxDepr,cTabela,aMemFNA[7],aMemFNA[3],IIF(aMemFNA[4] == "P3", .T., .F.) )
EndIf

//Verifica se existe
dbSelectArea("FNA")
dbSetOrder(1)		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR

//Grava o apontamento para todas as moedas utilizadas
For nX := 1 To Len(aTxDepr)
	RecLock("FNA", .T.)
	FNA->FNA_FILIAL	:= (cTabela)->N3_FILIAL
	FNA->FNA_IDMOV	:= aMemFNA[1]
	FNA->FNA_ITMOV	:= aMemFNA[2]
	FNA->FNA_CBASE	:= (cTabela)->N3_CBASE
	FNA->FNA_ITEM	:= (cTabela)->N3_ITEM
	FNA->FNA_TIPO	:= (cTabela)->N3_TIPO
	FNA->FNA_SEQ	:= (cTabela)->N3_SEQ
	FNA->FNA_SEQREA	:= (cTabela)->N3_SEQREAV
	FNA->FNA_TPSALD	:= (cTabela)->N3_TPSALDO
	FNA->FNA_TPDEPR	:= (cTabela)->N3_TPDEPR
	FNA->FNA_DATA	:= aMemFNA[3]
	FNA->FNA_OCORR	:= aMemFNA[4]
	FNA->FNA_DTPERI	:= aMemFNA[5]
	FNA->FNA_DTPERF	:= aMemFNA[6]
	FNA->FNA_QUANTD	:= aMemFNA[7]
	FNA->FNA_ESTORN	:= '2'

	If aMemFNA[4] $ "P2|P3|P4|"
		FNA->FNA_COEFIC	:= Round( NoRound( aFatorDep[nX] , nDecCoef+1 ) , nDecCoef )
	EndIf
	If !(aMemFNA[4] $ "P1|P8|")
		FNA->FNA_MOEDA	:= cValToChar(nX) + Space(nTamMoeda - nX) //Temp
	EndIf
	MsUnlock()

	If nX == 1
		//Salva o registro atual
		nRecFNA := FNA->(Recno())

		//Salva os dados do bem
		aRecFNA := Array(9)
		aRecFNA[1] := FNA->FNA_FILIAL
		aRecFNA[2] := FNA->FNA_CBASE
		aRecFNA[3] := FNA->FNA_ITEM
		aRecFNA[4] := FNA->FNA_TIPO
		aRecFNA[5] := FNA->FNA_SEQ
		aRecFNA[6] := FNA->FNA_SEQREA
		aRecFNA[7] := FNA->FNA_TPSALD
		aRecFNA[8] := FNA->FNA_MOEDA
		aRecFNA[9] := FNA->FNA_DATA

		//Produção
		nProdMes := 0
		aVrdMes := IIF(lMultMoed, AtfMultMoe(,,{|xMoeda| 0 }) , {0,0,0,0,0} )
		nProdAcm := 0
		aVrdAcm := IIF(lMultMoed, AtfMultMoe(,,{|xMoeda| 0 }) , {0,0,0,0,0} )

		//Apontamento estornado
		aAptoEst := {}

		//Quantidade estornada
		nQtdEst := 0

		dbSelectArea("SN3")
		dbSetOrder(1)		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
		dbGoTop()

		dbSelectArea("SN4")
		dbSetOrder(1)		//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
		dbGoTop()

		//Atualiza os registros da tabela SN3
		dbSelectArea("FNA")
		dbSetOrder(1)		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR
		dbGoTop()

		Do Case
			Case aMemFNA[4] == "P1"		//Apont. de revisão de estimativa de produção
				//Restaura o índice e registro atual
				FNA->(dbSetOrder(1))		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR
				FNA->(dbGoTo(nRecFNA))

				If SN3->(MsSeek(FNA->FNA_FILIAL+FNA->FNA_CBASE+FNA->FNA_ITEM+FNA->FNA_TIPO+"0"+FNA->FNA_SEQ))
					RecLock("SN3",.F.)
					SN3->N3_PRODANO	:= NoRound( FNA->FNA_QUANTD , nDecAno+1 )
					MsUnlock()
					//Lançamento padrão
					cPadrao := "871"		//Apontamento de revisão da estimativa de produção

					//Verifica se o lançamento padrão está configurado
					lPadrao := VerPadrao(cPadrao)

					IF lPadrao .And. lOnOff
						nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
					EndIf

					//Altera a varíavel de controle do laço, para não gravar apontamentos para todas as moedas
					nX := Len(aTxDepr)
				EndIf
			Case aMemFNA[4] $ "P2|P3|P4|"		//Apont. de produção e estorno
				//Verifica todos os apontamentos realizados no mês
				FNA->(dbSetOrder(2))		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
				If FNA->(MsSeek(aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7]))
					While FNA->(!EoF())	.And. (FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD)) == aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7]
						If FNA->FNA_OCORR $ "P2|P3|P4|" .And. FNA->FNA_ESTORN != "1"
							//Atualiza a variável que acumula a depreciação total
							aVrdAcm[Val(FNA->FNA_MOEDA)] += FNA->FNA_VALOR
							//Verifica a moeda do apontamento
							If FNA->FNA_MOEDA == aRecFNA[8]
								//Atualiza a variável que acumula a produção total
								nProdAcm += FNA->FNA_QUANTD
							EndIf
							If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1))
								//Atualiza a variável que acumula a depreciação total
								aVrdMes[Val(FNA->FNA_MOEDA)] += FNA->FNA_VALOR
								//Verifica a moeda do apontamento
								If FNA->FNA_MOEDA == aRecFNA[8]
									//Atualiza a variável que acumula a produção mensal
									nProdMes += FNA->FNA_QUANTD
								EndIf
							EndIf
						EndIf
						FNA->(dbSkip())
					EndDo
				EndIf

				//Restaura o índice e registro atual
				FNA->(dbSetOrder(1))		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR
				FNA->(dbGoTo(nRecFNA))

				//Atualiza os campos do bem
				If SN3->(MsSeek(FNA->FNA_FILIAL+FNA->FNA_CBASE+FNA->FNA_ITEM+FNA->FNA_TIPO+"0"+FNA->FNA_SEQ))
					//Gera as movimentações na tabela SN4 e SN5
					If aMemFNA[4] $ "P2|P3" .And. cPaisLoc <> "BOL"
						Do Case
							Case SN3->N3_TPDEPR $ "4|5|8|"		//Exaustão linear
								If lMultMoed
									aValDepr := AtfMultMoe(,,{|xMoeda| IIF( SN3->&("N3_VORIG"+cValToChar(xMoeda)) > 0, (SN3->&("N3_VORIG"+cValToChar(xMoeda)) + SN3->&("N3_AMPLIA"+cValToChar(xMoeda))) * FNA->FNA_COEFIC, 0 ) })
								Else
									aValDepr := {0,0,0,0,0}
									For nY := 1 To 5
										aValDepr[nY] := IIF(SN3->&("N3_VORIG"+cValToChar(nY)) > 0, (SN3->&("N3_VORIG"+cValToChar(nY)) + SN3->&("N3_AMPLIA"+cValToChar(nY))) * FNA->FNA_COEFIC, 0 )
									Next nY
								EndIf
							Case SN3->N3_TPDEPR == "9"		//Exaustão por saldo residual
								If lMultMoed
									//aValDepr := AtfMultMoe(,,{|xMoeda| IIF( SN3->&("N3_VORIG"+cValToChar(xMoeda)) > 0, (((SN3->&("N3_VORIG"+cValToChar(xMoeda)) + SN3->&("N3_AMPLIA"+cValToChar(xMoeda))) - SN3->N3_PRODACM) * FNA->FNA_COEFIC), 0 ) })
									aValDepr := AtfMultMoe(,,{|xMoeda| IIF( SN3->&("N3_VORIG"+cValToChar(xMoeda)) > 0, (((SN3->&("N3_VORIG"+cValToChar(xMoeda)) + SN3->&("N3_AMPLIA"+cValToChar(xMoeda))) - SN3->&("N3_VRDACM"+cValToChar(xMoeda))) * FNA->FNA_COEFIC), 0 ) })
								Else
									aValDepr := {0,0,0,0,0}
									For nY := 1 To 5
										//aValDepr[nY] := IIF( SN3->&("N3_VORIG"+cValToChar(nY)) > 0, (((SN3->&("N3_VORIG"+cValToChar(nY)) + SN3->&("N3_AMPLIA"+cValToChar(nY))) - SN3->N3_PRODACM) * FNA->FNA_COEFIC), 0 )
										aValDepr[nY] := IIF( SN3->&("N3_VORIG"+cValToChar(nY)) > 0, (((SN3->&("N3_VORIG"+cValToChar(nY)) + SN3->&("N3_AMPLIA"+cValToChar(nY))) - SN3->&("N3_VRDACM"+cValToChar(nY))) * FNA->FNA_COEFIC), 0 )
									Next nY
								EndIf
						EndCase

						//Atualiza os arrays de valor da depreciação mensal e acumulada
						For nY := 1 To Len(aValDepr)
							aVrdAcm[nY] += aValDepr[nY]
							aVrdMes[nY] += aValDepr[nY]
						Next nY

						//Atualiza depreciacao acumulada
						RecLock("SN3",.F.)
						If cPaisLoc <> "BOL"
							For nY := 1 To Len(aValDepr)
	 							If SN3->(FieldPos("N3_VRDMES"+cValToChar(nY)) > 0)
									SN3->&("N3_VRDMES"+cValToChar(nY)) := aVrdMes[nY]
								EndIf
	
								If SN3->(FieldPos("N3_VRDACM"+cValToChar(nY)) > 0)
									SN3->&("N3_VRDACM"+cValToChar(nY)) := aVrdAcm[nY]
								EndIf
							Next nY
						Endif

						//Atualiza Producao acumulada
						SN3->N3_PRODMES	:= Round( NoRound( nProdMes , nDecQtd+1 ) , nDecMes )
						SN3->N3_PRODACM	:= Round( NoRound( (SN3->N3_PRODACM + aMemFNA[7]) , nDecQtd+1 ) , nDecAcm )

						//Caso a produção acumulada seja igual a prevista, o bem tem depreciacao finalizada.
						If STR(SN3->N3_PRODACM,17,2) == STR(SN3->N3_PRODANO,17,2) .and. cPaisLoc <> "BOL"
							For nY := 1 To Len(aValDepr)
								If  SN3->(FieldPos("N3_VRDMES"+cValToChar(nY)) > 0) .and. SN3->(FieldPos("N3_VRDACM"+cValToChar(nY)) > 0)
									nDifDepr := (SN3->&("N3_VORIG"+cValToChar(nY)) - SN3->&("N3_VRDMES"+cValToChar(nY)))
									SN3->&("N3_VRDMES"+cValToChar(nY)) += nDifDepr
									SN3->&("N3_VRDACM"+cValToChar(nY)) += nDifDepr
								EndIf
							Next nY
						EndIf
						If aMemFNA[4] == "P3"
							SN3->N3_DEXAUST	:= aRecFNA[9]
							SN3->N3_FIMDEPR	:= aRecFNA[9]
						EndIf
						MsUnlock()

						//Dados complementares a movimentação
						aDadosComp := ATFXCompl(nTaxaMedia, FNA->FNA_COEFIC,/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )

						//-----------------------------------------------------------------
						// Avalia o tipo de depreciação que ocorrerá (Fiscal ou Gerencial)
						//-----------------------------------------------------------------
						If SN3->N3_TIPO $ cTipoFiscal
							cTipDepr := "06" //Depreciação fiscal
						ElseIf SN3->N3_TIPO $ cTipoGerenc
							cTipDepr := "20" //Depreciação gerencial
						EndIf 

						If cPaisLoc <> "BOL"
							//Gravação na tabela SN4 da conta Depreciação Acumulada
							ATFXMOV(SN3->N3_FILIAL,@cIDMOV,FNA->FNA_DATA,cTipDepr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"4",0,SN3->N3_TPSALDO,/*aEntidades*/,aValDepr,aDadosComp,,,,,lOnOff,cPadrao)
	
							//Lançamento padrão
							Do Case
								Case aMemFNA[4] == "P2"
									cPadrao := "872"		//Apontamento de produção
						   		Case aMemFNA[4] == "P3"
									cPadrao := "873"
							EndCase
						EndIf

						//Verifica se o lançamento padrão está configurado
						lPadrao := VerPadrao(cPadrao)

						If lPadrao .And. lOnOff
							nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
						EndIf
						
						If cPaisLoc <> "BOL"
							//Gravação na tabela SN4 da conta Despesa de Depreciação
							ATFXMOV(SN3->N3_FILIAL,@cIDMOV,FNA->FNA_DATA,cTipDepr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"3",0,SN3->N3_TPSALDO,/*aEntidades*/,aValDepr,aDadosComp,,,,,lOnOff,cPadrao)
	
							//Lançamento padrão
							Do Case
								Case aMemFNA[4] == "P2"
									If (SN3->N3_RATEIO == "1")
										//Contabiliza o rateio da despesa de depreciação
										cPadrao := "87A"
										ATFRTMOV(	SN3->N3_FILIAL,;
													SN3->N3_CBASE,;
													SN3->N3_ITEM,;
													SN3->N3_TIPO,;
													SN3->N3_SEQ,;
													SN4->N4_DATA,;
													SN4->N4_IDMOV,;
													aValDepr,;
													.T.,;
													"1",;
													nHdlPrv,;
													cLoteATF,;
													@nTotal,;
													"0",;
													"ATFA110",;
													cPadrao,lOnOff				)
									Else
										cPadrao := "872"
									EndIf
	
									If cPadrao == "872"
										//Verifica se o lançamento padrão está configurado
										lPadrao := VerPadrao(cPadrao)
	
										If lPadrao .And. lOnOff
											nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
										EndIf
									EndIf
	
						   		Case aMemFNA[4] == "P3"
									cPadrao := "873"
	
									//Verifica se o lançamento padrão está configurado
									lPadrao := VerPadrao(cPadrao)
	
									If lPadrao .And. lOnOff
										nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
									EndIf
							EndCase
	
							//Verifica o tipo de saldo a ser atualizado
							Do case
				                Case SN3->N3_TIPO $ cTipoFiscal
									cN5_TIPO := "4"
								Case SN3->N3_TIPO $ cTipoGerenc
									cN5_TIPO := "Y"
								Case SN3->N3_TIPO == "08"
									cN5_TIPO := "K"
								Case SN3->N3_TIPO == "09"
									cN5_TIPO := "L"
								OtherWise
									cN5_TIPO := "4"
				     		EndCase
	
				     		//Gravação na tabela SN5 da conta Despesa de Depreciação
							AtfSaldo(SN3->N3_CDEPREC,FNA->FNA_DATA,cN5_TIPO,aValDepr[1],aValDepr[2],aValDepr[3],aValDepr[4],aValDepr[5],"+",FNA->FNA_COEFIC,SN3->N3_SUBCDEP,,SN3->N3_CLVLDEP,SN3->N3_CCDESP,"3",aValDepr)
	
							//Gravação na tabela SN5 da conta Depreciação Acumulada
							AtfSaldo(SN3->N3_CCDEPR,FNA->FNA_DATA,cN5_TIPO,aValDepr[1],aValDepr[2],aValDepr[3],aValDepr[4],aValDepr[5],"+",FNA->FNA_COEFIC,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4",aValDepr)
						EndIf

						//Controla a gravação dos valores dos movimentos para atualizar o apontamento
						lGerouMov := .T.
					Else
						//Lançamento padrao
						cPadrao := "874"		//Apontamento de complemento de produção

						//Atualizo a producao mensal e acumulada
						RecLock("SN3",.F.)
						SN3->N3_PRODMES	:= Round( NoRound( nProdMes , nDecQtd+1 ) , nDecMes )
						SN3->N3_PRODACM	:= Round( NoRound( (SN3->N3_PRODACM + aMemFNA[7]) , nDecQtd+1 ) , nDecAcm )
						MsUnlock()


						//Verifica se o lançamento padrão está configurado
						lPadrao := VerPadrao(cPadrao)

						If lPadrao .And. lOnOff
							nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
						EndIf
					EndIf
				EndIf
			Case aMemFNA[4] == "P8"		//Estorno de revisão de estim. de produção
				//Array utilizado para salvar todos os apontamentos de estimativa e revisão de estimativa de produção
				aAptos := {}

				FNA->(dbSetOrder(2))		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
				If FNA->(MsSeek( aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7] ))
					While FNA->(!EoF())	.And. (FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD)) == aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7]
						If (FNA->FNA_DATA <= LastDay(dUltDepr+1)) .And. (FNA->FNA_OCORR $ "P0|P1|") .And. (FNA->FNA_ESTORN != "1")
							AADD(aAptos, { FNA->FNA_FILIAL, FNA->FNA_IDMOV, FNA->FNA_ITMOV, FNA->FNA_CBASE, FNA->FNA_ITEM, FNA->FNA_TIPO, FNA->FNA_SEQ, FNA->FNA_SEQREA, FNA->FNA_TPSALD, DTOS(FNA->FNA_DATA) })
						EndIf
						FNA->(dbSkip())
					EndDo

					//Verifica o último apontamento de revisão de estimativa de produção
					nUltApto := Len(aAptos)

					//Altera o campo de controle de estorno
					If FNA->(MsSeek(aAptos[nUltApto,1]+aAptos[nUltApto,4]+aAptos[nUltApto,5]+aAptos[nUltApto,6]+aAptos[nUltApto,7]+aAptos[nUltApto,8]+aAptos[nUltApto,9]+aAptos[nUltApto,10]))
						RecLock("FNA",.F.)
						FNA->FNA_ESTORN := "1"
						MsUnlock()

						cPadrao := "876"		//Estorno de apontamento de revisão de estimativa de produção

						//Verifica se o lançamento padrão está configurado
						lPadrao := VerPadrao(cPadrao)

						If lPadrao .And. lOnOff
							nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
						EndIf

						//Quantidade estornada
						nQtdEst := FNA->FNA_QUANTD
					EndIf

					//Verifica o apontamento de revisão de estimativa de produção que será posto em vigor
					nUltApto := Len(aAptos)-1

					//Altera o campo de controle de estorno
					If nUltApto > 0 .and. FNA->(MsSeek(aAptos[nUltApto,1]+aAptos[nUltApto,4]+aAptos[nUltApto,5]+aAptos[nUltApto,6]+aAptos[nUltApto,7]+aAptos[nUltApto,8]+aAptos[nUltApto,9]+aAptos[nUltApto,10]))
					    //Atualiza os campos do bem
						If SN3->(MsSeek(FNA->FNA_FILIAL+FNA->FNA_CBASE+FNA->FNA_ITEM+FNA->FNA_TIPO+"0"+FNA->FNA_SEQ))
					    	RecLock("SN3",.F.)
					    	SN3->N3_PRODANO	:= Round( NoRound( FNA->FNA_QUANTD , nDecQtd+1 ) , nDecAcm )
					    	MsUnlock()
					    EndIf
					EndIf

					//Restaura o índice e registro atual
					FNA->(dbSetOrder(1))		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR
					FNA->(dbGoTo(nRecFNA))

					RecLock("FNA",.F.)
					FNA->FNA_QUANTD := nQtdEst
					MsUnlock()
				EndIf

				//Altera a varíavel de controle do laço, para não gravar apontamentos para todas as moedas
				nX := Len(aTxDepr)

			Case aMemFNA[4] == "P9" //Estorno de apontamentos de produção
				//Array utilizado para salvar os dados do apontamento estornado
				aAptoEst := Array(Len(aTxDepr),6)

				//Array utilizado para salvar os valores do apontamento estornado
				aValDepr := Array(Len(aTxDepr))

				FNA->(dbSetOrder(2))		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
				If FNA->(MsSeek( aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7]+DTOS(aRecFNA[9]) ))
					While FNA->(!EoF())	.And. (FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD)+DTOS(FNA->FNA_DATA)) == aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7]+DTOS(aRecFNA[9])
						If FNA->FNA_OCORR $ "P2|P3|P4|"
							RecLock("FNA",.F.)
							FNA->FNA_ESTORN := "1"
							MsUnlock()

							//Moeda do apontamento estornado
							nMoedaEst := Val(FNA->FNA_MOEDA)

							If nMoedaEst == 1
								nRecEst := FNA->(Recno())
							EndIf

							//Salva os dados do apontamento estornado
							aAptoEst[nMoedaEst,1] := FNA->FNA_DTPERI
							aAptoEst[nMoedaEst,2] := FNA->FNA_DTPERF
							aAptoEst[nMoedaEst,3] := FNA->FNA_QUANTD
							aAptoEst[nMoedaEst,4] := FNA->FNA_COEFIC
							aAptoEst[nMoedaEst,5] := FNA->FNA_VALOR
							aAptoEst[nMoedaEst,6] := FNA->FNA_MOEDA

							lGerouEst := .T.

							//Salva os valores a subtrair do saldo das contas
							aValDepr[nMoedaEst] := FNA->FNA_VALOR
						EndIf
						FNA->(dbSkip())
					EndDo

					//Contabiliza o apontamento estornado
					FNA->(dbGoTo(nRecEst))

					If FNA->FNA_OCORR $ "P2|P3|" .and. cPaisLoc <> "BOL"
						If SN3->(MsSeek(FNA->FNA_FILIAL+FNA->FNA_CBASE+FNA->FNA_ITEM+FNA->FNA_TIPO+"0"+FNA->FNA_SEQ))
							If  SN3->N3_TIPO $ cTipoFiscal
								nOcorr := "06"
							Elseif SN3->N3_TIPO $ cTipoGerenc
								nOcorr := "20"
							Endif						
							If SN4->(MsSeek( FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+DTOS(FNA_DATA))+nOcorr+FNA->FNA_SEQ ))
								While SN4->(!EoF())	;
									.And. SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ)	;
									== FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+DTOS(FNA_DATA))+nOcorr+FNA->FNA_SEQ
									Do Case
										Case FNA->FNA_OCORR == "P2"
											If SN4->N4_TIPOCNT == "3"
												If (SN3->N3_RATEIO == "1")
													//Contabiliza o rateio da despesa de depreciação
													cPadrao := "87B"
													ATFRTMOV(	SN3->N3_FILIAL,;
																SN3->N3_CBASE,;
																SN3->N3_ITEM,;
																SN3->N3_TIPO,;
																SN3->N3_SEQ,;
																SN4->N4_DATA,;
																SN4->N4_IDMOV,;
																,;
																.T.,;
																"2",;
																nHdlPrv,;
																cLoteATF,;
																@nTotal,;
																"0",;
																"ATFA110",;
																cPadrao,lOnOff				)
												Else
													cPadrao := "877"		//Estorno de apontamento de produção

													//Verifica se o lançamento padrão está configurado
													lPadrao := VerPadrao(cPadrao)

													If lPadrao .And. lOnOff
														nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
													EndIf
												EndIf

											Else
												cPadrao := "877"		//Estorno de apontamento de produção

												//Verifica se o lançamento padrão está configurado
												lPadrao := VerPadrao(cPadrao)

												If lPadrao .And. lOnOff
													nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
												EndIf
											EndIf
										Case FNA->FNA_OCORR == "P3"
											//Controla se irá apagar as datas de exaustão
											lEstExaust := .T.

											cPadrao := "878"		//Estorno de apontamento de encerramento de produção

											//Verifica se o lançamento padrão está configurado
											lPadrao := VerPadrao(cPadrao)

											If lPadrao .And. lOnOff
												nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
											EndIf
									EndCase

									//Apaga os registros das movimentações
									RecLock("SN4",.F.)
									dbDelete()
									MsUnlock()
									SN4->(dbSkip())

								EndDo
							EndIf

							//Verifica o tipo de saldo a ser atualizado
							Do case
				                Case SN3->N3_TIPO $ cTipoFiscal
									cN5_TIPO := "4"
								Case SN3->N3_TIPO $ cTipoGerenc
									cN5_TIPO := "Y"
								Case SN3->N3_TIPO == "08"
									cN5_TIPO := "K"
								Case SN3->N3_TIPO == "09"
									cN5_TIPO := "L"
								OtherWise
									cN5_TIPO := "4"
				     		EndCase

							//Gravação na tabela SN5 da conta Despesa de Depreciação
							AtfSaldo(SN3->N3_CDEPREC,FNA->FNA_DATA,cN5_TIPO,aValDepr[1],aValDepr[2],aValDepr[3],aValDepr[4],aValDepr[5],"-",FNA->FNA_COEFIC,SN3->N3_SUBCDEP,,SN3->N3_CLVLDEP,SN3->N3_CCDESP,"3",aValDepr)

							//Gravação na tabela SN5 da conta Depreciação Acumulada
							AtfSaldo(SN3->N3_CCDEPR,FNA->FNA_DATA,cN5_TIPO,aValDepr[1],aValDepr[2],aValDepr[3],aValDepr[4],aValDepr[5],"-",FNA->FNA_COEFIC,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4",aValDepr)
						EndIf
					ElseIf cPaisLoc <> "BOL"
						cPadrao := "879"		//Estorno de apontamento de complemento de produção

						//Verifica se o lançamento padrão está configurado
						lPadrao := VerPadrao(cPadrao)

						If lPadrao .and. lOnOff
							nTotal += DetProva(nHdlPrv,cPadrao,"ATFA110",cLoteAtf)
						EndIf
					EndIf
				EndIf

				If FNA->(MsSeek( aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7] ))
					While FNA->(!EoF())	.And. (FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD)) == aRecFNA[1]+aRecFNA[2]+aRecFNA[3]+aRecFNA[4]+aRecFNA[5]+aRecFNA[6]+aRecFNA[7]
						If FNA->FNA_OCORR $ "P2|P3|P4|" .And. FNA->FNA_ESTORN != "1"
							//Atualiza a variável que acumula a depreciação total
							aVrdAcm[Val(FNA->FNA_MOEDA)] += FNA->FNA_VALOR
							//Verifica a moeda do apontamento
							If FNA->FNA_MOEDA == aRecFNA[8]
								//Atualiza a variável que acumula a produção total
								nProdAcm += FNA->FNA_QUANTD
							EndIf
							If (FNA->FNA_DATA > dUltDepr .And. FNA->FNA_DATA <= LastDay(dUltDepr+1))
								//Atualiza a variável que acumula a depreciação total
								aVrdMes[Val(FNA->FNA_MOEDA)] += FNA->FNA_VALOR
								//Verifica a moeda do apontamento
								If FNA->FNA_MOEDA == aRecFNA[8]
									//Atualiza a variável que acumula a produção mensal
									nProdMes += FNA->FNA_QUANTD
								EndIf
							EndIf
						EndIf
						FNA->(dbSkip())
					EndDo

					//Restaura o índice e registro atual
					FNA->(dbSetOrder(1))		//FNA_FILIAL+FNA_IDMOV+FNA_ITMOV+FNA_MOEDA+FNA_OCORR
					FNA->(dbGoTo(nRecFNA))

					If SN3->(MsSeek(FNA->FNA_FILIAL+FNA->FNA_CBASE+FNA->FNA_ITEM+FNA->FNA_TIPO+"0"+FNA->FNA_SEQ))
						RecLock("SN3",.F.)
						If cPaisLoc <> "BOL"
							For nY := 1 To Len(aVrdMes)
								If SN3->(FieldPos("N3_VRDMES"+cValToChar(nY)) > 0)
									SN3->&("N3_VRDMES"+cValToChar(nY)) := aVrdMes[nY]
								EndIf
							Next nY
	
							For nY := 1 To Len(aVrdAcm)
								If SN3->(FieldPos("N3_VRDACM"+cValToChar(nY)) > 0)
									SN3->&("N3_VRDACM"+cValToChar(nY)) := aVrdAcm[nY]
								EndIf
							Next nY
					    	
					    	If lEstExaust
								SN3->N3_DEXAUST := CtoD("//")
								SN3->N3_FIMDEPR := CtoD("//")
							EndIf
						EndIf
						SN3->N3_PRODMES	:= Round( NoRound( nProdMes , nDecQtd+1 ) , nDecMes )
					   	SN3->N3_PRODACM	:= Round( NoRound( nProdAcm , nDecQtd+1 ) , nDecAcm )
				    	MsUnlock()
					EndIf
				EndIf
		EndCase
	EndIf

	If lGerouMov
		RecLock("FNA",.F.)
		FNA->FNA_VALOR := SN4->&("N4_VLROC"+cValToChar(nX))
		Msunlock()
	EndIf

	If lGerouEst
		RecLock("FNA",.F.)
		FNA->FNA_DTPERI := aAptoEst[nX,1]
		FNA->FNA_DTPERF := aAptoEst[nX,2]
		FNA->FNA_QUANTD := aAptoEst[nX,3]
		FNA->FNA_COEFIC := aAptoEst[nX,4]
		FNA->FNA_VALOR  := aAptoEst[nX,5]
		Msunlock()
	EndIf

Next nX

//Incrementa o IT. Mov. do apontamento
aMemFNA[2] := Soma1(aMemFNA[2])

Return
