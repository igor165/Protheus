#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA106.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CLRF CHR(13)+CHR(10)

Static saTabelas	:= {}
Static saGrpEmps	:= {}
Static saSM0Emp		:= {}
Static saTabCheck	:= {}
Static snThread		:= 0
Static slError		:= .F.
Static scMsg		:= ""
Static cEmpPai

//------------------------------------------------------------
//Cadastro de Empresas Centralizadoras
//------------------------------------------------------------
Function PCPA106()
	Local oBrowse

	Private oBRVerd   	:= LoadBitmap(GetResources(),'BR_VERDE')
	Private oBRVerm   	:= LoadBitmap(GetResources(),'BR_VERMELHO')
	Private oBRAmar   	:= LoadBitmap(GetResources(),'BR_AMARELO')
	Private aCoors		:= FWGetDialogSize( oMainWnd )
	Private aTempDisp	:= { }
	Private aTempSelec	:= { }
	Private oBrowseTmp
	Private oBrwTmpSel
	Private oSayEsq
	Private oSayDir
	Private lGestEmp 	:= fIsCorpManage(cEmpAnt)
	Default lAutoMacao  := .F.

	cEmpPai		:= Iif(cEmpPai == Nil, cEmpAnt, cEmpPai)
	snThread	:= ThreadId()

	If Empty(saSM0Emp)
		TravaThrd(.T., .F.)
		saSM0Emp := PCPA106GEM(@slError, .F., .F., cEmpPai)
	EndIf

	IF !lAutoMacao
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('SOO')
		oBrowse:SetMenuDef( 'PCPA106' )
		oBrowse:SetDescription( STR0001 )//Cadastro de Empresas Centralizadoras
		oBrowse:SetOnlyFields(PCP106CMPS())
		oBrowse:Activate()
	ENDIF
Return Nil

//------------------------------------------------------------
//Declaracao da MENUDEF
//------------------------------------------------------------
Static Function MenuDef()
	Private aRotina := {}
	aAdd( aRotina, { STR0002, 'PCPA106CTL(2)', 0, 2, 0, Nil } ) //'Visualizar'
	aAdd( aRotina, { STR0003, 'PCPA106CTL(3)', 0, 3, 0, Nil } ) //'Incluir'
	aAdd( aRotina, { STR0004, 'PCPA106CTL(4)', 0, 4, 0, Nil } ) //'Alterar'
	aAdd( aRotina, { STR0005, 'PCPA106CTL(5)', 0, 5, 0, Nil } ) //'Excluir'
	aAdd( aRotina, { STR0059, 'PCPA106TES(2)', 0, 2, 0, Nil } ) //'TES'
	aAdd( aRotina, { STR0067, 'PCP106DMRP()' , 0, 2, 0, Nil } ) //'Limpar tabelas MRP'
Return aRotina

//------------------------------------------------------------
//Formul�rio Principal da PCPA106
//------------------------------------------------------------
Function PCPA106CTL(nOp)
	Local nWidth    := 0
	Local nHeight   := 0
	Local nLinIni   := 0
	Local nColIni   := 0
	Local aTam      := {}
	Local aCampos   := {}
	Local aButtons  := {}
	Local nRecNo    := 0
	Local oPnlMst, oPnlDetE, oPnlDetC, oPnlDetD
	Local nOpca
	Local cLayout  := FWSM0Layout(SOP->OP_CDEPGR)
	Local nTamEmp  := 0
	Local nTamUnid := 0
	Local nTamFil  := 0
	Local nX
	local oScr
	Local alt
	Local larg
	Local oPnlNew

	Private cFilialPai
	Private nOpcao     := nOp
	Private oEnch
	Private oBtn
	Private cFilePai   := ""
	Default lAutoMacao := .F.

	For nX := 1 To Len(cLayout)
		If SubStr(cLayout,nX,1) == "E"
			nTamEmp++
		ElseIf SubStr(cLayout,nX,1) == "U"
			nTamUnid++
		ElseIf SubStr(cLayout,nX,1) == "F"
			nTamFil++
		EndIf
	Next nX

	IF !lAutoMacao
		MsgRun(STR0089,STR0090,{|| WaitSM0() })	//"Aguarde . . . Processando carga de dados das empresas." - "Aguarde!"


		nLinIni := 0
		nColIni := 5
		nHeight := aCoors[3]
		nWidth  := aCoors[4]

		DEFINE MSDIALOG oDlg FROM nLinIni, 0 TO nHeight, nWidth TITLE STR0001 PIXEL//Dialog de aloca��o

		nWidth  := nWidth*0.50

		//Cria o painel superior (campos mestre)
		oPnlMst := tPanel():Create(oDlg, nLinIni, nColIni,,,,,,/*CLR_RED*/,nWidth,/*nHeight*/)
		oPnlMst:Align := CONTROL_ALIGN_ALLCLIENT

		If nOp == 3
			nRecNo := Nil
		Else
			nRecNo := SOO->(RecNo())
		EndIf

		nCalcHeight := Round((nHeight*0.1)/2, 0)
		nCalcWidth  := Round(nWidth * 0.15, 0)

		aAdd(aTam, nLinIni)
		aAdd(aTam, nColIni)
		aAdd(aTam, nCalcWidth)
		aAdd(aTam, nCalcHeight)

		aCampos := PCP106CMPS()

		//Joga os campos da tabela pra mem�ria
		If nOp == 3
			RegtoMemory("SOO",.T.)
			//Cria o enchoice dos campos superiores.
			oEnch := MsMGet():New("SOO",nRecNo,nOp,,,,aCampos,aTam,,,,,,oPnlMst,,,.F.)
			oEnch:oBox:Align := CONTROL_ALIGN_TOP
		Else
			RegtoMemory("SOO",.F.)
			//Cria o enchoice dos campos superiores.
			oEnch := MsMGet():New("SOO",nRecNo,nOp,,,,aCampos,aTam,,,,,,oPnlMst,,,.F.)
			oEnch:oBox:Align := CONTROL_ALIGN_TOP
			oEnch:Disable()
		EndIf

		carregaDado()

		If nOpcao != 3 .AND. Alltrim(cEmpPai) != AllTrim(SOO->OO_CDEPCZ)
			cEmpPai	:= SOO->OO_CDEPCZ
			cFilialPai	:= PadR(SOO->OO_EMPRCZ,nTamEmp)+PadR(SOO->OO_UNIDCZ,nTamUnid)+PadR(SOO->OO_CDESCZ,nTamFil)
			MsgRun(STR0091,STR0090,{|| UpdLegenda(aTempDisp, aTempSelec) }) //"Aguarde . . . Processando regras de compartilhamento.." - "Aguarde!"

		EndIf

		alt := nHeight*0.4
		larg := nWidth
		oScr := TScrollBox():Create(oPnlMst,(nCalcHeight+55),00,alt,larg,.T.,.T.,.T.)
		oScr:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlNew := tPanel():Create(oScr, nLinIni, nColIni,,,,,,/*CLR_RED*/,nWidth,/*nHeight*/)
		oPnlNew:Align := CONTROL_ALIGN_ALLCLIENT

		nCalcLinIni := nLinIni + 5
		nCalcColIni := nColIni
		nCalcHeight := Round(alt * 0.95, 0)
		nCalcWidth  := Round(nWidth * 0.43, 0)
		//cria o grupo de campos para os templates dispon�veis
		oGroupD := TGroup():New(nCalcLinIni, nCalcColIni, nCalcHeight, nCalcWidth, STR0008, oPnlNew,,,.T.)//"Empresas Dispon�veis"

		nCalcLinIni := nCalcLinIni + 10
		nCalcColIni := nCalcColIni + 5
		nCalcHeight := Round(nHeight * 0.27, 0)
		nCalcWidth  := Round(nWidth * 0.40, 0)
		//cria o painel para os templates dispon�veis
		oPnlDetE := tPanel():Create(oPnlNew, nCalcLinIni, nCalcColIni,,,,,,/*CLR_BLUE*/, nCalcWidth, nCalcHeight)

		//cria as grids do template dispon�vel
		nCalcHeight := Round(nHeight * 0.28, 0)
		criaGridD(oPnlDetE, nCalcLinIni, nCalcColIni, nCalcWidth, nCalcHeight)

		//cria o painel para os bot�es de controle.
		nCalcColIni := nCalcColIni+nCalcWidth + 15
		nCalcWidth  := Round(nWidth  * 0.10, 0)
		nCalcHeight := Round(nHeight * 0.15, 0)
		If(nCalcHeight < 160, nCalcHeight := 160, Nil)
		oPnlDetC := tPanel():Create(oPnlNew, nCalcLinIni, nCalcColIni,,,,,,/*CLR_YELLOW*/, nCalcWidth, nCalcHeight)
		//cria os bot�es de controle
		criaBotoes(oPnlDetC)

		nCalcLinIni := nLinIni + 5
		nCalcColIni := nCalcColIni+nCalcWidth + 5
		nCalcHeight := Round(alt * 0.95, 0)
		nCalcWidth  := Round(nWidth  * retVersion(0.98, 0.98, 0.98), 0)
		//cria o grupo de campos para os templates selecionados
		oGroupS := TGroup():New(nCalcLinIni, nCalcColIni, nCalcHeight, nCalcWidth, STR0009,oPnlNew,,,.T.)

		nCalcLinIni := nCalcLinIni + 10
		nCalcColIni := nCalcColIni + 5
		nCalcHeight := Round(nHeight * 0.27, 0)
		nCalcWidth  := Round(nWidth  * 0.40, 0)
		oPnlDetD := tPanel():Create(oPnlNew, nCalcLinIni, nCalcColIni,,,,,, /*CLR_BLUE*/, nCalcWidth, nCalcHeight)

		//cria as grids dos templates selecioados
		nCalcHeight := Round(nHeight * 0.28, 0)
		criaGridS(oPnlDetD,nCalcLinIni,nCalcColIni,nCalcWidth,nCalcHeight)

		bConfClk := {|| nOpca := 1, If(PCPA106CFR(oDlg, nOp),oDlg:End(),Nil)}
		bCancClk := {|| nOpca := 2,oDlg:End()}

		aAdd(aButtons,{'PROJETPMS',{|| PCPA106TES(nOpcao)},STR0059}) // TES
		aAdd(aButtons,{'PROJETPMS',{|| a106Legend()      },STR0078}) // "Legenda"

		ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bConfClk,bCancClk,,aButtons) CENTERED
	ENDIF

Return .T.
//---------------------------------------------------------------------------------------------
//Corrige o valor pelo tamanho do field
//---------------------------------------------------------------------------------------------
Static Function CorValFld(cValue,cField)
Return AllTrim(cValue) + Space(TamSX3(cField)[1] - Len(AllTrim(cValue)))

//---------------------------------------------------------------------------------------------
//Preenche os grids conforme o cadastro
//---------------------------------------------------------------------------------------------
Static Function carregaDado()
	Local nI, nX
	Local aInfFilial := {}
	Local nTamEmp    := Len(FWSM0Layout(cEmpAnt,1))
	Local nTamUNeg   := Len(FWSM0Layout(cEmpAnt,2))
	Local nTamFil    := Len(FWSM0Layout(cEmpAnt,3))
	Local nTamSM0    := FWSizeFilial(cEmpAnt)

	aTempDisp := {}

	If lGestEmp
		For nI := 1 To Len(saSM0Emp)
			aInfFilial := FwArrFilAtu(saSM0Emp[nI,2],saSM0Emp[nI,3])
			If Len(aInfFilial) > 0
				aAdd(aTempDisp,{'',;
								saSM0Emp[nI,2],;
								aInfFilial[SM0_DESCGRP],;
								aInfFilial[SM0_EMPRESA],;
								aInfFilial[SM0_DESCEMP],;
								aInfFilial[SM0_UNIDNEG],;
								aInfFilial[SM0_DESCUN],;
								aInfFilial[SM0_FILIAL],;
								aInfFilial[SM0_NOMRED],;
								0,;
								saSM0Emp[nI,7]})
			EndIf
		Next nI
	Else
		aTempDisp := aClone(saSM0Emp)
	EndIf

	If lGestEmp
		aTempSelec  := {{'','','','','','','','','',0,oBRVerd}}
	Else
		aTempSelec  := {{'','','','','',0,oBRVerd}}
	EndIf

	dbSelectArea("SOP")
	If lGestEmp
		SOP->(dbSetOrder(3))
		If SOP->(dbSeek(xFilial("SOP")+CorValFld(M->OO_CDEPCZ,"OP_CDEPCZ")+CorValFld(M->OO_EMPRCZ,"OP_EMPRCZ")+CorValFld(M->OO_UNIDCZ,"OP_UNIDCZ")+CorValFld(M->OO_CDESCZ,"OP_CDESCZ")))
			aDel(aTempSelec,1)
			aSize(aTempSelec, Len(aTempSelec)-1)
		EndIf

		While !SOP->(Eof()) .And. Padr(SOP->OP_FILIAL,nTamSM0)+AllTrim(SOP->OP_CDEPCZ)+Padr(SOP->OP_EMPRCZ,nTamEmp)+Padr(SOP->OP_UNIDCZ,nTamUneg)+Padr(SOP->OP_CDESCZ,nTamFil) == ;
		Padr(xFilial("SOP"), nTamSM0)+AllTrim(M->OO_CDEPCZ)+Padr(M->OO_EMPRCZ,nTamEmp)+Padr(M->OO_UNIDCZ,nTamUneg)+Padr(M->OO_CDESCZ,nTamFil)

			aInfFilial := FwArrFilAtu(SOP->OP_CDEPGR, PadR(SOP->OP_EMPRGR,nTamEmp) + PadR(SOP->OP_UNIDGR,nTamUNeg) + PadR(SOP->OP_CDESGR,nTamFil) )

			If Len(aInfFilial) > 0
				aAdd(aTempSelec,{'',;
									SOP->OP_CDEPGR,;
									aInfFilial[SM0_DESCGRP], ;
									aInfFilial[SM0_EMPRESA],;
									aInfFilial[SM0_DESCEMP],;
									aInfFilial[SM0_UNIDNEG],;
									aInfFilial[SM0_DESCUN],;
									aInfFilial[SM0_FILIAL],;
									aInfFilial[SM0_NOMRED],;
									SOP->OP_NRPYGR,;
									Iif( saGrpEmps[aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(SOP->OP_CDEPGR)})][2] , oBRVerd, oBrVerm) })
				nI := 1
				While nI <= Len(aTempDisp)
					If AllTrim(aTempDisp[nI][2]) == AllTrim(SOP->OP_CDEPGR) .And. AllTrim(aTempDisp[nI][4]) == AllTrim(SOP->OP_EMPRGR) .And. ;
					AllTrim(aTempDisp[nI][6]) == AllTrim(SOP->OP_UNIDGR) .And. AllTrim(aTempDisp[nI][8]) == AllTrim(SOP->OP_CDESGR)
						nX := Len(aTempSelec)
						aTempSelec[nX][1] := aTempDisp[nI][1]
						aDel(aTempDisp,nI)
						aSize(aTempDisp, Len(aTempDisp)-1)
						Exit
					EndIf
					nI++
				End
			EndIf

			SOP->(dbSkip())
		End
	Else
		SOP->(dbSetOrder(1))
		If SOP->(dbSeek(xFilial("SOP")+CorValFld(M->OO_CDEPCZ,"OP_CDEPCZ")+CorValFld(M->OO_CDESCZ,"OP_CDESCZ")))
			aDel(aTempSelec,1)
			aSize(aTempSelec, Len(aTempSelec)-1)
		EndIf

		While !SOP->(Eof()) .And. Padr(SOP->OP_FILIAL, nTamSM0)+AllTrim(SOP->OP_CDEPCZ)+Padr(SOP->OP_CDESCZ,nTamFil) == Padr(xFilial("SOP"),nTamSM0)+AllTrim(M->OO_CDEPCZ)+Padr(M->OO_CDESCZ,nTamFil)

			aAdd(aTempSelec,{'',;
							SOP->OP_CDEPGR,;
							SOP->OP_CDESGR,;
							'',;
							'',;
							SOP->OP_NRPYGR,;
							Iif( saGrpEmps[aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(SOP->OP_CDEPGR)})][2] , oBRVerd, oBrVerm) })
			nI := 1
			While nI <= Len(aTempDisp)
				If AllTrim(aTempDisp[nI][2]) == AllTrim(SOP->OP_CDEPGR) .And. AllTrim(aTempDisp[nI][3]) == AllTrim(SOP->OP_CDESGR)
					nX := Len(aTempSelec)
					aTempSelec[nX][1] := aTempDisp[nI][1]
					aTempSelec[nX][4] := aTempDisp[nI][4]
					aTempSelec[nX][5] := aTempDisp[nI][5]
					aDel(aTempDisp,nI)
					aSize(aTempDisp, Len(aTempDisp)-1)
					Exit
				EndIf
				nI++
			End

			SOP->(dbSkip())
		End
	EndIf

	If Len(aTempDisp) == 0
		If lGestEmp
			aTempDisp := {{'','','','','','','','','',0,oBRVerd}}
		Else
			aTempDisp := {{'','','','','',0,oBRVerd}}
		EndIf
	EndIf

	If lGestEmp
		aSort(aTempSelec, , , { | x,y | x[10] < y[10] } )
		aSort(aTempDisp, , , { | x,y | x[2]+x[4]+x[6]+x[8] < y[2]+y[4]+y[6]+y[8] } )
	Else
		aSort(aTempSelec, , , { | x,y | x[6] < y[6] } )
		aSort(aTempDisp, , , { | x,y | x[2]+x[3] < y[2]+y[3] } )
	EndIf

Return Nil

//---------------------------------------------------------------------------------------------
//Valida��o do formul�rio principal
//---------------------------------------------------------------------------------------------
Function PCPA106CFR(oDlg, nOp)
	Local nI
	Local nX           := 0
	Local aEmp		   := aClone(saSM0Emp)
	Local cGrupBkp     := ""
	Local lDifGrup     := .F.
	Local lAchou	   := .F.
	Local cLayout      := ""
	Local nTamEmp      := Len(FWSM0Layout(cEmpAnt,1))
	Local nTamUNeg     := Len(FWSM0Layout(cEmpAnt,2))
	Local nTamFil      := Len(FWSM0Layout(cEmpAnt,3))

	Default lAutoMacao := .F.

	dbSelectArea("SOP")

	IF !lAutoMacao
		For nI := 1 To oBrwTmpSel:nLen
			If nOp != 5 .And. lGestEmp
				If !lDifGrup .And. (AllTrim(cGrupBkp) != AllTrim(aTempSelec[nI][2]) .Or. AllTrim(aTempSelec[nI][2]) != AllTrim(M->OO_CDEPCZ) )
					If nI == 1 .And. AllTrim(aTempSelec[nI][2]) == AllTrim(M->OO_CDEPCZ)
						cGrupBkp := aTempSelec[nI][2]
					Else
						lDifGrup := .T.
					EndIf
				EndIf
				If AllTrim(M->OO_CDEPCZ) == AllTrim(aTempSelec[nI][2]) .And. AllTrim(M->OO_EMPRCZ) == AllTrim(aTempSelec[nI][4]) .And.;
				AllTrim(M->OO_UNIDCZ) == AllTrim(aTempSelec[nI][6]) .And. AllTrim(M->OO_CDESCZ) == AllTrim(aTempSelec[nI][8])
					//STR0072 - Opera��o n�o permitida! | STR0030 - N�o � permitido informar como empresa centralizada o mesmo conte�do da empresa centralizadora.
					Help(NIL, NIL, STR0072, NIL, STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL)
					Return .F.
				EndIf

				SOP->(dbSetOrder(4))
				If SOP->(dbSeek(xFilial("SOP")+CorValFld(aTempSelec[nI][2],"OP_CDEPGR")+CorValFld(aTempSelec[nI][4],"OP_EMPRGR")+CorValFld(aTempSelec[nI][6],"OP_UNIDGR")+CorValFld(aTempSelec[nI][8],"OP_CDESGR")))
					If AllTrim(M->OO_CDEPCZ)+AllTrim(M->OO_EMPRCZ)+AllTrim(M->OO_UNIDCZ)+AllTrim(M->OO_CDESCZ) != ;
					AllTrim(SOP->OP_CDEPCZ)+AllTrim(SOP->OP_EMPRCZ)+AllTrim(SOP->OP_UNIDCZ)+AllTrim(SOP->OP_CDESCZ)
						//STR0072 - Opera��o n�o permitida!  | A empresa" x "filial" y "j� est� contida por outra empresa.
						Help(NIL, NIL, STR0072, NIL, STR0031 + " " + AllTrim(aTempSelec[nI][3]) + " " + STR0032 + " " + AllTrim(aTempSelec[nI][9]) + " " + STR0033, 1, 0, NIL, NIL, NIL, NIL, NIL)
						Return .F.
					EndIf
				EndIf

				SOP->(dbSetOrder(3))
				If SOP->(dbSeek(xFilial("SOP")+CorValFld(aTempSelec[nI][2],"OP_CDEPCZ")+CorValFld(aTempSelec[nI][4],"OP_EMPRCZ")+CorValFld(aTempSelec[nI][6],"OP_UNIDCZ")+CorValFld(aTempSelec[nI][8],"OP_CDESCZ")))
					//STR0072 - Opera��o n�o permitida! | "A empresa" x "filial" y "esta cadastrada como empresa centralizadora."
					Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempSelec[nI][3])+" "+STR0032+" " + AllTrim(aTempSelec[nI][9]) + " " + STR0034, 1, 0, NIL, NIL, NIL, NIL, NIL)
					Return .F.
				EndIf

				nX	:= aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(aTempSelec[nI][2])})
				If nX > 0 .AND. !saGrpEmps[nX][2]
					//STR0072 - Opera��o n�o permitida! | STR0079 - "Falha no compartilhamento das tabelas 'cTabelas' do Grupo de Empresa 'cGrpEmp'."
					//STR0080 - Acesse o configurador do Protheus, corrija o compartilhamento, ajuste os dados de filiais no banco e tente novamente
					Help(NIL, NIL, STR0072, NIL, StrTran(Strtran(STR0079,"cGrpEmp",saGrpEmps[nX][1]),"cTabelas",fTabCheck(.F.)), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0080})
					Return .F.
				EndIf

			ElseIf nOp != 5
				If !lDifGrup .And. AllTrim(aTempSelec[nI][2]) != AllTrim(M->OO_CDEPCZ)
					lDifGrup := .T.
				EndIf

				If AllTrim(M->OO_CDEPCZ) == AllTrim(aTempSelec[nI][2]) .And. AllTrim(M->OO_CDESCZ) == AllTrim(aTempSelec[nI][3])
					//STR0072 - Opera��o n�o permitida! | STR0030 - N�o � permitido informar como empresa centralizada o mesmo conte�do da empresa centralizadora.
					Help(NIL, NIL, STR0072, NIL, STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL)
					Return .F.
				EndIf

				SOP->(dbSetOrder(2))
				If SOP->(dbSeek(xFilial("SOP")+CorValFld(aTempSelec[nI][2],"OP_CDEPGR")+CorValFld(aTempSelec[nI][3],"OP_CDESGR")))
					If AllTrim(M->OO_CDEPCZ)+AllTrim(M->OO_CDESCZ) != AllTrim(SOP->OP_CDEPCZ)+AllTrim(SOP->OP_CDESCZ)
						//STR0072 - Opera��o n�o permitida! | "A empresa" x "filial" y "j� est� contida por outra empresa."
						Help(NIL, NIL, STR0072, NIL, STR0031 + " " + AllTrim(aTempSelec[nI][4]) + " " + STR0032 + " " + AllTrim(aTempSelec[nI][5]) + " " + STR0033, 1, 0, NIL, NIL, NIL, NIL, NIL)
						Return .F.
					EndIf
				EndIf

				SOP->(dbSetOrder(1))
				If SOP->(dbSeek(xFilial("SOP")+CorValFld(aTempSelec[nI][2],"OP_CDEPCZ")+CorValFld(aTempSelec[nI][3],"OP_CDESCZ")))
					//STR0072 - Opera��o n�o permitida! | "A empresa" x "filial" y "esta cadastrada como empresa centralizadora."
					Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempSelec[nI][4])+" "+STR0032+" " + AllTrim(aTempSelec[nI][5]) + " " + STR0034, 1, 0, NIL, NIL, NIL, NIL, NIL)
					Return .F.
				EndIf

				nX	:= aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(aTempSelec[nI][2])})
				If nX > 0 .AND. !saGrpEmps[nX][2]
					//STR0072 - Opera��o n�o permitida! | STR0079 - "Falha no compartilhamento das tabelas 'cTabelas' do Grupo de Empresa 'cGrpEmp'."
					//STR0080 - Acesse o configurador do Protheus, corrija o compartilhamento, ajuste os dados de filiais no banco e tente novamente
					Help(NIL, NIL, STR0072, NIL, StrTran(Strtran(STR0079,"cGrpEmp",saGrpEmps[nX][1]),"cTabelas",fTabCheck(.F.)), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0080})
					Return .F.
				EndIf
			EndIf
		Next
	ENDIF

	For nI := 1 To Len(aEmp)
		If lGestEmp
			If AllTrim(aEmp[nI][2])+PadR(aEmp[nI][3],nTamEmp+nTamUNeg+nTamFil) == ;
			AllTrim(M->OO_CDEPCZ)+PadR(M->OO_EMPRCZ,nTamEmp)+PadR(M->OO_UNIDCZ,nTamUNeg)+PadR(M->OO_CDESCZ,nTamFil)
				lAchou := .T.
				Exit
			EndIf
		Else
			If AllTrim(aEmp[nI][2]) == AllTrim(M->OO_CDEPCZ) .And. AllTrim(aEmp[nI][3]) == AllTrim(M->OO_CDESCZ)
				lAchou := .T.
				Exit
			EndIf
		EndIf
	Next

	If nOp != 5 .And. !lAchou .And. !lAutoMacao
		//STR0072 - Opera��o n�o permitida! | STR0010 - C�digo informado n�o corresponde a nenhuma empresa
		Help(NIL, NIL, STR0072, NIL, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL)
		Return .F.
	EndIf

	If nOp == 2
		Return .T.
	EndIf

	If nOp != 5 .And. lGestEmp
		If Empty(M->OO_CDEPCZ)
			//STR0072 - Opera��o n�o permitida! | STR0081 - Campo obrigat�rio 'cCampo' em branco. | STR0011 - Informe os campos obrigat�rios
			Help(NIL, NIL, STR0072, NIL, Strtran(STR0081,"cCampo",X3Titulo("OO_CDEPCZ")), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
			Return .F.
		EndIf
		cLayout := FWSM0Layout(M->OO_CDEPCZ)
		If AT("U",cLayout) > 0 .And. Empty(M->OO_UNIDCZ)
			//STR0072 - Opera��o n�o permitida! | STR0081 - Campo obrigat�rio 'cCampo' em branco. | STR0011 - Informe os campos obrigat�rios
			Help(NIL, NIL, STR0072, NIL, Strtran(STR0081,"cCampo",X3Titulo("OO_UNIDCZ")), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
			Return .F.
		EndIf
		If AT("E",cLayout) > 0 .And. Empty(M->OO_EMPRCZ)
			//STR0072 - Opera��o n�o permitida! | STR0081 - Campo obrigat�rio 'cCampo' em branco. | STR0011 - Informe os campos obrigat�rios
			Help(NIL, NIL, STR0072, NIL, Strtran(STR0081,"cCampo",X3Titulo("OO_EMPRCZ")), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
			Return .F.
		EndIf
		If AT("F",cLayout) > 0 .And. Empty(M->OO_CDESCZ)
			//STR0072 - Opera��o n�o permitida! | STR0081 - Campo obrigat�rio 'cCampo' em branco. | STR0011 - Informe os campos obrigat�rios
			Help(NIL, NIL, STR0072, NIL, Strtran(STR0081,"cCampo",X3Titulo("OO_CDESCZ")), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
			Return .F.
		EndIf
	ElseIf nOp != 5
		If Empty(M->OO_CDEPCZ)
			//STR0072 - Opera��o n�o permitida! | STR0081 - Campo obrigat�rio 'cCampo' em branco. | STR0011 - Informe os campos obrigat�rios
			Help(NIL, NIL, STR0072, NIL, Strtran(STR0081,"cCampo",X3Titulo("OO_CDEPCZ")), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
		ElseIf Empty(M->OO_CDESCZ)
			//STR0072 - Opera��o n�o permitida! | STR0081 - Campo obrigat�rio 'cCampo' em branco. | STR0011 - Informe os campos obrigat�rios
			Help(NIL, NIL, STR0072, NIL, Strtran(STR0081,"cCampo",X3Titulo("OO_CDESCZ")), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
			Return .F.
		EndIf
	EndIf

	If nOp != 5 .And. nOp != 4 //diferente de altera��o e exclus�o
		If FindEmp(,,.T.)
			//STR0072 - Opera��o n�o permitida! | STR0012 - J� existe um registro para esta empresa e filial'
			Help(NIL, NIL, STR0072, NIL, STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL)
			Return .F.
		ElseIf FindEmpCen(,,.T.)
			//STR0072 - Opera��o n�o permitida! | STR0042 - Empresa j� cadastrada como empresa centralizada"
			Help(NIL, NIL, STR0072, NIL, STR0042, 1, 0, NIL, NIL, NIL, NIL, NIL)
			Return .F.
		EndIf
	EndIf

	If nOp != 5 .And. !lDifGrup .And. (!Empty(M->OO_TE) .Or. !Empty(M->OO_TS))
		If !validTes()
			//STR0072 - Opera��o n�o permitida! | STR0063 - Aten��o! Existem inconsist�ncias com o TES informado, favor verificar.
			Help(NIL, NIL, STR0072, NIL, STR0063, 1, 0, NIL, NIL, NIL, NIL, NIL)
			Return .F.
		EndIf
	EndIf

	If Empty(aTempSelec[1][2])
		//STR0072 - Opera��o n�o permitida! | STR0063 - � necess�rio selecionar ao menos uma empresa centralizada.
		Help(NIL, NIL, STR0072, NIL, STR0096, 1, 0, NIL, NIL, NIL, NIL, NIL)
		Return .F.
	EndIf

	If nOp != 5 .And. lDifGrup
		//STR0066 - Aten��o
		//STR0099 - Esse cadastro n�o ser� v�lido para o novo MRP Mem�ria (PCPA712).
		//STR0100 - O MRP Mem�ria s� pode ser executado por empresas do mesmo Grupo.
		Help(NIL, NIL, STR0066, NIL, STR0099, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0100})
	EndIf

	If nOp == 3 //Inclus�o
		inserir()
	EndIf

	If nOp == 4 //Altera��o
		alterar()
	EndIf

	If nOp == 5 //Exclus�o
		excluir()
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------
//Verifica se o TES de entrada ou saida est� cadastrado em todas as filiais centralizadas.
//---------------------------------------------------------------------------------------------
Static Function validTes(cTipo)
	Local aDocTE     := {}
	Local aDocTS     := {}
	Local cFilAux    := ""
	Local lRet       := .T.
	Local nI         := 0
	Local nTamEmp    := Len(FWSM0Layout(cEmpAnt,1))
	Local nTamUNeg   := Len(FWSM0Layout(cEmpAnt,2))
	Local nTamFil    := Len(FWSM0Layout(cEmpAnt,3))

	Default cTipo := "ALL"
	Default lAutoMacao := .F.

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	cFilAux := Padr(M->OO_EMPRCZ,nTamEmp) + Padr(M->OO_UNIDCZ,nTamUneg) + Padr(M->OO_CDESCZ,nTamFil)

	//Verifica se os campos OO_TE e OO_TS existem na empresa centralizadora
	If cTipo == "ALL" .Or. cTipo == "E"
		If !Empty(M->OO_TE)
			If !SF4->(dbSeek(xFilial("SF4", cFilAux)+M->OO_TE))
				aAdd(aDocTE,{M->OO_CDEPCZ, cFilAux})
			EndIf
		EndIf
	EndIf
	If cTipo == "ALL" .Or. cTipo == "S"
		If !Empty(M->OO_TS)
			If !SF4->(dbSeek(xFilial("SF4", cFilAux)+M->OO_TS))
				aAdd(aDocTS,{M->OO_CDEPCZ, cFilAux})
			EndIf
		EndIf
	EndIf

	If !lAutoMacao
		//Verifica se os campos OO_TE e OO_TS existem nas empresas centralizadas
		For nI := 1 To oBrwTmpSel:nLen
			If lGestEmp
				cFilAux := Padr(aTempSelec[nI][4],nTamEmp) + Padr(aTempSelec[nI][6],nTamUneg) + Padr(aTempSelec[nI][8],nTamFil)
			Else
				cFilAux := Padr(aTempSelec[nI][3],nTamFil)
			EndIf
			If cTipo == "ALL" .Or. cTipo == "E"
				If !Empty(M->OO_TE)
					If !SF4->(dbSeek(xFilial("SF4", cFilAux)+M->OO_TE))
						aAdd(aDocTE,{aTempSelec[nI][2], cFilAux})
					EndIf
				EndIf
			EndIf
			If cTipo == "ALL" .Or. cTipo == "S"
				If !Empty(M->OO_TS)
					If !SF4->(dbSeek(xFilial("SF4", cFilAux)+M->OO_TS))
						aAdd(aDocTS,{aTempSelec[nI][2], cFilAux})
					EndIf
				EndIf
			EndIf
		Next nI
	EndIf

	If Len(aDocTS) > 0 .Or. Len(aDocTE) > 0
		lRet := .F.
		If cTipo == "S"
			If Len(aDocTS) > 1
				cMsg := STR0061 + CHR(10) //"TES n�o cadastrado para as filiais: "
			Else
				cMsg := STR0062 + CHR(10) //"TES n�o cadastrado para a filial: "
			EndIf
			For nI := 1 To Len(aDocTS)
				cNomFil := FWFilialName(cEmpAnt,aDocTS[nI,2])
				If nI == Len(aDocTS)
					cMsg += aDocTS[nI,2] + " - " + AllTrim(cNomFil) + "." + CHR(10)
				Else
					cMsg += aDocTS[nI,2] + " - " + AllTrim(cNomFil) + ";" + CHR(10)
				EndIf
			Next nI
		EndIf

		If cTipo == "E"
			If Len(aDocTE) > 1
				cMsg := STR0061 + CHR(10) //"TES n�o cadastrado para as filiais: "
			Else
				cMsg := STR0062 + CHR(10) //"TES n�o cadastrado para a filial: "
			EndIf
			For nI := 1 To Len(aDocTE)
				cNomFil := FWFilialName(cEmpAnt,aDocTE[nI,2])
				If nI == Len(aDocTE)
					cMsg += aDocTE[nI,2] + " - " + AllTrim(cNomFil) + "." + CHR(10)
				Else
					cMsg += aDocTE[nI,2] + " - " + AllTrim(cNomFil) + ";" + CHR(10)
				EndIf
			Next nI
		EndIf
		If cTipo != "ALL"
			Aviso(STR0059,cMsg,{"OK"},3)
		EndIf
		aSize(aDocTE, 0)
		aSize(aDocTS, 0)
	Else
		If cTipo != "ALL"
			Aviso(STR0059,STR0060,{"OK"},1) //
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------
//Verifica se a empresa e filial informada s�o centralizadoras.
//---------------------------------------------------------------------------------------------
Static Function FindEmp(cEmpPar,cFilPar,lDefault)
	Local lRet        := .F.
	Local aFilial     := {}
	Local cLayout     := ""
	Local nI          := 0
	Local nTamEmp     := 0
	Local nTamUnid    := 0
	Local nTamFil     := 0
	Default cEmpPar   := M->OO_CDEPCZ
	Default cFilPar   := M->OO_CDESCZ
	Default lDefault  := .F.

	cLayout := FWSM0Layout(cEmpPar)

	For nI := 1 To Len(cLayout)
		If SubStr(cLayout,nI,1) == "E"
			nTamEmp++
		ElseIf SubStr(cLayout,nI,1) == "U"
			nTamUnid++
		ElseIf SubStr(cLayout,nI,1) == "F"
			nTamFil++
		EndIf
	Next nI

	If cFilPar == M->OO_CDESCZ
		cFilPar := Padr(cFilPar,nTamFil+nTamUnid+nTamEmp)
	EndIf

	If lDefault .And. lGestEmp
		cFilPar := PadR(M->OO_EMPRCZ,nTamEmp)+Padr(M->OO_UNIDCZ,nTamUnid)+Padr(M->OO_CDESCZ,nTamFil)
	EndIf

	dbSelectArea("SOO")
	If lGestEmp
		aFilial := FwArrFilAtu(cEmpPar,cFilPar)
		If Len(aFilial) > 0
			SOO->(dbSetOrder(2))
			If SOO->( dbSeek(xFilial("SOO")+CorValFld(cEmpPar,"OO_CDEPCZ")+CorValFld(aFilial[SM0_EMPRESA],"OO_EMPRCZ")+CorValFld(aFilial[SM0_UNIDNEG],"OO_UNIDCZ")+CorValFld(aFilial[SM0_FILIAL],"OO_CDESCZ")) )
				lRet := .T.
			EndIf
		EndIf
	Else
		SOO->(dbSetOrder(1))
		If SOO->( dbSeek(xFilial("SOO")+CorValFld(cEmpPar,"OO_CDEPCZ")+CorValFld(cFilPar,"OO_CDESCZ")) )
			lRet := .T.
		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------
//Verifica se a empresa e filial informada s�o centralizadas.
//---------------------------------------------------------------------------------------------
Static Function FindEmpCen(cEmpPar,cFilPar,lDefault)
	Local lRet        := .F.
	Local aFilial     := {}
	Local cLayout     := ""
	Local nI          := 0
	Local nTamEmp     := 0
	Local nTamUnid    := 0
	Local nTamFil     := 0
	Default cEmpPar   := M->OO_CDEPCZ
	Default cFilPar   := M->OO_CDESCZ
	Default lDefault  := .F.

	cLayout := FWSM0Layout(cEmpPar)

	For nI := 1 To Len(cLayout)
		If SubStr(cLayout,nI,1) == "E"
			nTamEmp++
		ElseIf SubStr(cLayout,nI,1) == "U"
			nTamUnid++
		ElseIf SubStr(cLayout,nI,1) == "F"
			nTamFil++
		EndIf
	Next nI

	If cFilPar == M->OO_CDESCZ
		cFilPar := Padr(cFilPar,nTamFil+nTamUnid+nTamEmp)
	EndIf

	If lDefault .And. lGestEmp
		cFilPar := PadR(M->OO_EMPRCZ,nTamEmp)+Padr(M->OO_UNIDCZ,nTamUnid)+Padr(M->OO_CDESCZ,nTamFil)
	EndIf

	If lGestEmp
		aFilial := FwArrFilAtu(cEmpPar,cFilPar)
		If Len(aFilial) > 0
			dbSelectArea("SOP")
			SOP->(dbSetOrder(4))
			If SOP->( dbSeek(xFilial("SOP")+CorValFld(cEmpPar,"OP_CDEPGR")+CorValFld(aFilial[SM0_EMPRESA],"OP_EMPRGR")+CorValFld(aFilial[SM0_UNIDNEG],"OP_UNIDGR")+CorValFld(aFilial[SM0_FILIAL],"OP_CDESGR")) )

				If Alltrim(M->OO_CDEPCZ)+Alltrim(M->OO_EMPRCZ)+Alltrim(M->OO_UNIDCZ)+Alltrim(M->OO_CDESCZ) != Alltrim(SOP->OP_CDEPCZ)+Alltrim(SOP->OP_EMPRCZ)+Alltrim(SOP->OP_UNIDCZ)+Alltrim(SOP->OP_CDESCZ)
					lRet := .T.
				EndIf

			EndIf
		EndIf
	Else
		dbSelectArea("SOP")
		SOP->(dbSetOrder(2))
		If SOP->( dbSeek(xFilial("SOP")+CorValFld(cEmpPar,"OP_CDEPGR")+CorValFld(cFilPar,"OP_CDESGR")) )

			If Alltrim(M->OO_CDEPCZ)+Alltrim(M->OO_CDESCZ) != Alltrim(SOP->OP_CDEPCZ)+Alltrim(SOP->OP_CDESCZ)
				lRet := .T.
			EndIf

		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------
//Insere as informa��es de empresa centralizadora.
//---------------------------------------------------------------------------------------------
Static Function inserir()

	RecLock("SOO",.T.)
	SOO->OO_FILIAL := xFilial("SOO")
	SOO->OO_CDEPCZ := M->OO_CDEPCZ
	SOO->OO_CDESCZ := M->OO_CDESCZ
	SOO->OO_TS     := M->OO_TS
	SOO->OO_TE     := M->OO_TE
	If lGestEmp
		SOO->OO_EMPRCZ := M->OO_EMPRCZ
		SOO->OO_UNIDCZ := M->OO_UNIDCZ
	EndIf
	SOO->(dbUnlock())

	execInsere()
Return Nil

//---------------------------------------------------------------------------------------------
//Insere as informa��es das empresas centralizadas.
//---------------------------------------------------------------------------------------------
Static Function execInsere()
	Local nI
	Default lAutoMacao := .F.

	IF !lAutoMacao
		For nI := 1 To oBrwTmpSel:nLen
			If !Empty(aTempSelec[nI][2])
				RecLock("SOP",.T.)
				SOP->OP_FILIAL  := xFilial("SOP")
				SOP->OP_CDEPCZ  := M->OO_CDEPCZ
				SOP->OP_CDESCZ  := M->OO_CDESCZ
				If lGestEmp
					SOP->OP_EMPRCZ  := M->OO_EMPRCZ
					SOP->OP_UNIDCZ  := M->OO_UNIDCZ
					SOP->OP_CDEPGR  := aTempSelec[nI][2]
					SOP->OP_EMPRGR  := aTempSelec[nI][4]
					SOP->OP_UNIDGR  := aTempSelec[nI][6]
					SOP->OP_CDESGR  := aTempSelec[nI][8]
				Else
					SOP->OP_CDEPGR  := aTempSelec[nI][2]
					SOP->OP_CDESGR  := aTempSelec[nI][3]
				EndIf
				If nI > 99
					SOP->OP_NRPYGR := 99
				Else
					SOP->OP_NRPYGR := nI
				EndIf
				SOP->(dbUnlock())
			EndIf
		Next
	ENDIF
Return Nil

//---------------------------------------------------------------------------------------------
//Altera as empresas centralizadas.
//---------------------------------------------------------------------------------------------
Static Function alterar()

	SOO->(dbSetOrder(2))
	If SOO->( dbSeek( xFilial("SOO")                      +;
	                  CorValFld(M->OO_CDEPCZ,"OO_CDEPCZ") +;
	                  CorValFld(M->OO_EMPRCZ,"OO_EMPRCZ") +;
	                  CorValFld(M->OO_UNIDCZ,"OO_UNIDCZ") +;
	                  CorValFld(M->OO_CDESCZ,"OO_CDESCZ")) )
		If SOO->OO_TE != M->OO_TE .Or. SOO->OO_TS != M->OO_TS
			RecLock("SOO",.F.)
				SOO->OO_TE := M->OO_TE
				SOO->OO_TS := M->OO_TS
			MsUnLock()
		EndIf
	EndIf

	execExclui()
	execInsere()

Return Nil

//---------------------------------------------------------------------------------------------
//Exclui as empresas centralizadas.
//---------------------------------------------------------------------------------------------
Static Function execExclui()

	dbSelectArea("SOP")
	If lGestEmp
		SOP->(dbSetOrder(3))

		If SOP->(dbSeek(xFilial("SOP")+CorValFld(M->OO_CDEPCZ,"OP_CDEPCZ")+CorValFld(M->OO_EMPRCZ,"OP_EMPRCZ")+CorValFld(M->OO_UNIDCZ,"OP_UNIDCZ")+CorValFld(M->OO_CDESCZ,"OP_CDESCZ")))
			While AllTrim(SOP->OP_FILIAL)+AllTrim(OP_CDEPCZ)+AllTrim(OO_EMPRCZ)+AllTrim(OO_UNIDCZ)+AllTrim(OO_CDESCZ) == ;
			AllTrim(xFilial("SOP"))+AllTrim(M->OO_CDEPCZ)+AllTrim(M->OO_EMPRCZ)+AllTrim(M->OO_UNIDCZ)+AllTrim(M->OO_CDESCZ)
				RecLock("SOP",.F.)
				SOP->(dbDelete())
				SOP->(dbUnlock())
				SOP->(dbSkip())
			End
		EndIf
	Else
		SOP->(dbSetOrder(1))

		If SOP->(dbSeek(xFilial("SOP")+CorValFld(M->OO_CDEPCZ,"OP_CDEPCZ")+CorValFld(M->OO_CDESCZ,"OP_CDESCZ")))
			While AllTrim(SOP->OP_FILIAL)+AllTrim(OP_CDEPCZ)+AllTrim(OO_CDESCZ) == AllTrim(xFilial("SOP"))+AllTrim(M->OO_CDEPCZ)+AllTrim(M->OO_CDESCZ)
				RecLock("SOP",.F.)
				SOP->(dbDelete())
				SOP->(dbUnlock())
				SOP->(dbSkip())
			End
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------------------------------
//Exclui a empresa centralizadora.
//---------------------------------------------------------------------------------------------
Static Function excluir()

	If lGestEmp
		dbSelectArea("SOO")
		SOO->(dbSetOrder(2))
		If SOO->( dbSeek(xFilial("SOO")+CorValFld(M->OO_CDEPCZ,"OO_CDEPCZ")+CorValFld(M->OO_EMPRCZ,"OO_EMPRCZ")+CorValFld(M->OO_UNIDCZ,"OO_UNIDCZ")+CorValFld(M->OO_CDESCZ,"OO_CDESCZ")) )
			RecLock("SOO",.F.)
			SOO->(dbDelete())
			SOO->(dbUnlock())

			execExclui()
		EndIf
	Else
		dbSelectArea("SOO")
		SOO->(dbSetOrder(1))
		If SOO->( dbSeek(xFilial("SOO")+CorValFld(M->OO_CDEPCZ,"OO_CDEPCZ")+CorValFld(M->OO_CDESCZ,"OO_CDESCZ")) )
			RecLock("SOO",.F.)
			SOO->(dbDelete())
			SOO->(dbUnlock())

			execExclui()
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------------------------------
//Apresenta mensagem em uma Dialog
//---------------------------------------------------------------------------------------------
Static Function DlgAlert(cMsg)
	DEFINE MSDIALOG oDlgAlert TITLE "PCPA106" FROM 0,0 TO 150,350 PIXEL

	@ 015,005 SAY oMsg VAR cMsg OF oDlgAlert SIZE 165,70 FONT (TFont():New('Arial', nil, -12, .T.,)) PIXEL

	@ 60,73 BUTTON oBtn PROMPT "OK"  SIZE 30,11 ACTION {||oDlgAlert:End()} OF oDlgAlert PIXEL

	ACTIVATE MSDIALOG oDlgAlert CENTER
Return Nil

//---------------------------------------------------------------------------------------------
//Cria o grid com as empresas dispon�veis no arquivo SM0.
//---------------------------------------------------------------------------------------------
Static Function criaGridD(oPanel,nLinIni,nColIni,nWidth,nHeight)

	Local aHeaders  := {}
	Local aColSizes := {}
	Local oFont
	Local oPnlDscE

	DEFINE FONT oFont NAME "Arial" SIZE 0, -10
	If lGestEmp
		oPnlDscE := tPanel():Create(oPanel, nLinIni, nColIni,,,,,,/*CLR_RED*/,nWidth,10)
		oPnlDscE:Align := CONTROL_ALIGN_BOTTOM

		oSayEsq := TSay():New(01,01,{||' a'},oPnlDscE,,oFont,,,,.T.,,,200,20)
	EndIf

	//array carregado antes da chamada desta fun��o. (fun��o cargaDados() )
	If Len(aTempDisp) < 1
		If lGestEmp
			aTempDisp := {{'','','','','','','','','',0,oBRVerd}}
		Else
			aTempDisp := {{'','','','','',0,oBRVerd}}
		EndIf
	EndIf

	If lGestEmp
		aHeaders  := {" ",STR0053,STR0054,STR0013,STR0015,STR0058,STR0056,STR0014,STR0016}
		//"Grupo","Desc Grupo","Empresa","Desc Empresa","Unid. Neg�cio","Desc Unid. Neg�cio","Filial","Desc Filial"
		aColSizes := {60,30}
	Else
		aHeaders  := {" ",STR0013,STR0014,STR0015,STR0016}
		//"Empresa","Filial","Desc Empresa","Desc Filial"
		aColSizes := {60,100}
	EndIf

	//Browse dos templates dispon�veis
	oBrowseTmp := TWBrowse():New(0,0,nWidth,nHeight,,aHeaders,aColSizes,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.F.)
	oBrowseTmp:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseTmp:SetArray(aTempDisp)
	If lGestEmp
		oBrowseTmp:bChange      := {|| setText(oSayEsq,oBrowseTmp:nAt,aTempDisp,.F.)}
	EndIf
	//"Esta empresa/filial n�o est� registrada como grupo de empresas do MRP, por�m ainda esta integrada com a empresa centralizadora."
	//"Esta empresa/filial n�o est� registrada no grupo MRP e n�o est� integrada com a empresa centralizadora."
	//oBrowseTmp:bLDblClick   := {|| If (AllTrim(aTempDisp[oBrowseTmp:nAT,1]) == AllTrim(cFilePai), DlgAlert(STR0017), DlgAlert(STR0018) ) }
	oBrowseTmp:bLDblClick   := {|| a106Legend() }

	If lGestEmp
		oBrowseTmp:bLine        := {||{ GetObjLeg(1, aTempDisp, oBrowseTmp:nAt) ,;
		aTempDisp[oBrowseTmp:nAt,2],;
		aTempDisp[oBrowseTmp:nAt,3],;
		aTempDisp[oBrowseTmp:nAt,4],;
		aTempDisp[oBrowseTmp:nAt,5],;
		aTempDisp[oBrowseTmp:nAt,6],;
		aTempDisp[oBrowseTmp:nAt,7],;
		aTempDisp[oBrowseTmp:nAt,8],;
		aTempDisp[oBrowseTmp:nAt,9]}}
	Else
		oBrowseTmp:bLine        := {||{  GetObjLeg(2, aTempDisp, oBrowseTmp:nAt) ,;
		aTempDisp[oBrowseTmp:nAt,2],;
		aTempDisp[oBrowseTmp:nAt,3],;
		aTempDisp[oBrowseTmp:nAt,4],;
		aTempDisp[oBrowseTmp:nAt,5]}}
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------
//Seta o texto para o Label com os c�digos do Grupo/Empresa/Unidade/Filial
//---------------------------------------------------------------------------------------------
Static Function setText(oSay,nLinha,aDados,lPrioridad)
	Local cTexto := ""
	Default lAutoMacao := .F.

	cTexto := STR0053+": " + AllTrim(aDados[nLinha,2]) + ;
	" "+STR0013+": " + AllTrim(aDados[nLinha,4]) + ;
	STR0057 + AllTrim(aDados[nLinha,6]) + ;
	" "+STR0014+": " + AllTrim(aDados[nLinha,8])
	If lPrioridad
		cTexto += " "+AllTrim(STR0019)+": " + AllTrim(Str(nLinha))
	EndIf

	IF !lAutoMacao
		oSay:SetText(cTexto)
		oSay:CtrlRefresh()
	ENDIF
Return .T.

//---------------------------------------------------------------------------------------------
//Cria o grid para as empresas selecionadas para serem gravadas na tabela SOP.
//---------------------------------------------------------------------------------------------
Static Function criaGridS(oPanel,nLinIni,nColIni,nWidth,nHeight)
	Local oFont
	Local aHeaders  := {}
	Local aColSizes := {}

	If lGestEmp
		aHeaders  := aHeaders  := {" ",STR0053,STR0054,STR0013,STR0015,STR0055,STR0056,STR0014,STR0016,STR0019}
		//"Grupo","Desc Grupo","Empresa","Desc Empresa","Unid. Neg�cio","Desc Unid. Neg�cio","Filial","Desc Filial","Prioridade"
		aColSizes := {40,30}
	Else
		aHeaders  := {" ",STR0013,STR0014,STR0015,STR0016, STR0019}
		aColSizes := {40,40,40,40,40,40}
	EndIf

	DEFINE FONT oFont NAME "Arial" SIZE 0, -10
	If lGestEmp
		oPnlDscD := tPanel():Create(oPanel, nLinIni, nColIni,,,,,,/*CLR_RED*/,nWidth,10)
		oPnlDscD:Align := CONTROL_ALIGN_BOTTOM

		oSayDir := TSay():New(01,01,{||' a'},oPnlDscD,,oFont,,,,.T.,,,200,20)
	EndIf

	//array carregado antes da chamada desta fun��o. (fun��o cargaDados() )
	If Len(aTempSelec) < 1
		If lGestEmp
			aTempSelec:={{'','','','','','','','','',0,oBRVerd}}
		Else
			aTempSelec:={{'','','','','',0,oBRVerd}}
		EndIf
	EndIf

	//Browse dos templates selecionados
	oBrwTmpSel := TWBrowse():New(0,0,nWidth,(nHeight),,aHeaders,aColSizes,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.F.)//"Empresa" - "Filial" - "Desc Empresa" - "Desc Filial" - "Prioridade"
	oBrwTmpSel:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwTmpSel:SetArray(aTempSelec)
	//"Esta empresa/filial esta integrada e pronta para utiliza��o do MRP."
	//"Esta empresa/filial esta registrada por�m ainda n�o foi integrada com a empresa/filial centralizadora."
	//oBrwTmpSel:bLDblClick   := {|| If (AllTrim(aTempSelec[oBrwTmpSel:nAt,1]) == AllTrim(cFilePai),DlgAlert(STR0020),DlgAlert(STR0021)) }
	oBrwTmpSel:bLDblClick   := {|| a106Legend() }

	If lGestEmp
		oBrwTmpSel:bChange      := {|| setText(oSayDir,oBrwTmpSel:nAt,aTempSelec,.T.)}
		oBrwTmpSel:bLine := {||{  GetObjLeg(3, aTempSelec, oBrwTmpSel:nAt) ,;
		aTempSelec[oBrwTmpSel:nAt][2],;
		aTempSelec[oBrwTmpSel:nAt][3],;
		aTempSelec[oBrwTmpSel:nAt][4],;
		aTempSelec[oBrwTmpSel:nAt][5],;
		aTempSelec[oBrwTmpSel:nAt][6],;
		aTempSelec[oBrwTmpSel:nAt][7],;
		aTempSelec[oBrwTmpSel:nAt][8],;
		aTempSelec[oBrwTmpSel:nAt][9],;
		oBrwTmpSel:nAt }}
	Else
		oBrwTmpSel:bLine := {||{ GetObjLeg(4, aTempSelec, oBrwTmpSel:nAt) ,;
		aTempSelec[oBrwTmpSel:nAt][2],;
		aTempSelec[oBrwTmpSel:nAt][3],;
		aTempSelec[oBrwTmpSel:nAt][4],;
		aTempSelec[oBrwTmpSel:nAt][5],;
		oBrwTmpSel:nAt }}
	EndIf
Return .T.

//---------------------------------------------------------------------------------------------
//Cria os bot�es centrais que definem os itens selecionados.
//---------------------------------------------------------------------------------------------
Static Function criaBotoes(oPanel)
	Local nColuna := ((aCoors[4]*0.07)/2)

	@ 45, nColuna BTNBMP oBtUp01 Resource "RIGHT"  Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('ADD',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp01:cToolTip := STR0022 // "Adicionar selecionado"
	@ 80, nColuna BTNBMP oBtUp02 Resource "LEFT"   Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('RMV',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp02:cToolTip := STR0023 //"Remover selecionado"
	@ 115,nColuna BTNBMP oBtUp03 Resource "PGNEXT" Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('ADDALL',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp03:cToolTip := STR0024 //"Adicionar todos"
	@ 150,nColuna BTNBMP oBtUp04 Resource "PGPREV" Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('RMVALL',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp04:cToolTip := STR0025 //"Remover todos"


	//Prioridade
	oGroupPrio:= TGroup():New(100,10,145,47,STR0019,oPanel,,,.T.)

	@ 215,nColuna BTNBMP oBtUp05 Resource "UP" Size 29,29 Pixel Of oGroupPrio Noborder Pixel Action trocaNivel(-1) When {|| nOpcao == 3 .Or. nOpcao == 4}
	oBtUp05:cToolTip := STR0026 //"Sobe Prioridade"
	@ 250,nColuna BTNBMP oBtUp06 Resource "DOWN" Size 29,29 Pixel Of oGroupPrio Noborder Pixel Action trocaNivel(1) When {|| nOpcao == 3 .Or. nOpcao == 4}
	oBtUp06:cToolTip := STR0027 //"Desce Prioridade"
Return .T.

//---------------------------------------------------------------------------------------------
Static Function trocaNivel(nPos)
	Local nX := oBrwTmpSel:nAt
	Local nY := oBrwTmpSel:nAt + nPos
	Local aTemp := aClone(aTempSelec[nX])

	If nY == 0 .Or. nY > oBrwTmpSel:nLen
		Return Nil
	EndIf

	aTempSelec[nX] := aTempSelec[nY]
	aTempSelec[nY] := aTemp

	oBrwTmpSel:Refresh()
	If lGestEmp
		setText(oSayDir,oBrwTmpSel:nAt,aTempSelec,.T.)
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------
Static Function moveSel(cMove,aTempSelec, aTempDisp, oBrowseTmp, oBrwTmpSel)
	Local cLayout  		:= ""
	Local nI       		:= 1
	Local nY       		:= 0
	Local nTamEmp  		:= 0
	Local nTamUnid 		:= 0
	Local nTamFil  		:= 0
	Local lFailCmpTAB	:= .F.
	Local nIndAtual		:= 0
	Local cAux
	Local nAux
	Local nPosEmp		:= 0
	Default lAutoMacao  := .F.

	If nOpcao != 3 .AND. nOpcao != 4
		Return .T.
	EndIf

	If cMove == 'RMVALL' .OR. cMove == 'RMV'
		If Len(aTempSelec) < 1
			Return .T.
		EndIf
	Else
		If Len(aTempDisp) < 1
			Return .T.
		EndIf
	EndIf

	Do Case

		Case cMove == 'RMVALL'
		nIndAtual	:= 1
		While( Len(aTempSelec) >= nIndAtual )
			If aTempSelec[nIndAtual][2] != ""
				aAdd(aTempDisp,aTempSelec[nIndAtual])
				aDel(aTempSelec,nIndAtual)
				aSize(aTempSelec, Len(aTempSelec)-1)
			Else
				nIndAtual++
			EndIf
		End

		Case cMove == 'ADDALL'
		nLenArray := Len(aTempDisp)
		While nI <= nLenArray
			If aTempDisp[nI][2] != ""
				cLayout  := FWSM0Layout(aTempDisp[nI][2])
				nTamEmp  := 0
				nTamUnid := 0
				nTamFil  := 0
				For nY := 1 To Len(cLayout)
					If SubStr(cLayout,nY,1) == "E"
						nTamEmp++
					ElseIf SubStr(cLayout,nY,1) == "U"
						nTamUnid++
					ElseIf SubStr(cLayout,nY,1) == "F"
						nTamFil++
					EndIf
				Next nY
				If lGestEmp
					nPosEmp	:= aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(aTempDisp[nI][2])})
					If FindEmp(aTempDisp[nI][2],;
					PadR(aTempDisp[nI][4],nTamEmp)+;
					PadR(aTempDisp[nI][6],nTamUnid)+;
					PadR(aTempDisp[nI][8],nTamFil))
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizadora."
						//Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[nI][2])+" "+STR0032+" "+AllTrim(aTempDisp[nI][8])+" "+STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL)
						nI++
					ElseIf FindEmpCen(aTempDisp[nI][2],;
					PadR(aTempDisp[nI][4],nTamEmp)+;
					PadR(aTempDisp[nI][6],nTamUnid)+;
					PadR(aTempDisp[nI][8],nTamFil))
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizada.
						Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[nI][2])+" "+STR0032+" "+AllTrim(aTempDisp[nI][8])+" "+STR0044, 1, 0, NIL, NIL, NIL, NIL, NIL)
						nI++
					ElseIf	nPosEmp > 0 .AND. !saGrpEmps[nPosEmp][2]
						lFailCmpTAB	:= .T.
						nI++
					ElseIf AllTrim(aTempDisp[nI][2]) != AllTrim(M->OO_CDEPCZ) .Or. AllTrim(aTempDisp[nI][4]) != AllTrim(M->OO_EMPRCZ) .Or.;
					AllTrim(aTempDisp[nI][6]) != AllTrim(M->OO_UNIDCZ) .Or. AllTrim(aTempDisp[nI][8]) != AllTrim(M->OO_CDESCZ)
						aAdd(aTempSelec,aTempDisp[nI])
						aDel(aTempDisp,nI)
						aSize(aTempDisp, Len(aTempDisp)-1)
						nLenArray--
					Else
						nI++
					EndIf
				Else
					nPosEmp	:= aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(aTempDisp[nI][2])})
					If FindEmp(aTempDisp[nI][2],aTempDisp[nI][3])
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizadora."
						//Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[nI][2])+" "+STR0032+" "+AllTrim(aTempDisp[nI][3])+" "+STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL)
						nI++
					ElseIf FindEmpCen(aTempDisp[nI][2],aTempDisp[nI][3])
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizada."
						Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[nI][2])+" "+STR0032+" "+AllTrim(aTempDisp[nI][3])+" "+STR0044, 1, 0, NIL, NIL, NIL, NIL, NIL)
						nI++
					ElseIf	nPosEmp > 0 .and. !saGrpEmps[nPosEmp][2]
						lFailCmpTAB	:= .T.
						nI++
					ElseIf AllTrim(aTempDisp[nI][2]) != AllTrim(M->OO_CDEPCZ) .Or. AllTrim(aTempDisp[nI][3]) != AllTrim(M->OO_CDESCZ)
						aAdd(aTempSelec,aTempDisp[nI])
						aDel(aTempDisp,nI)
						aSize(aTempDisp, Len(aTempDisp)-1)
						nLenArray--
					Else
						nI++
					EndIf
				EndIf
			Else
				If Len(aTempDisp) == 1
					Exit
				EndIf
			EndIf
		End
	
		If lFailCmpTAB
			//STR0072 - Opera��o n�o permitida! | STR0087 - Uma ou mais empresas est�o com falha no modo de compartilhamento das tabelas 'cTabelas'.
			//STR0080 - Acesse o configurador do Protheus, corrija o compartilhamento, ajuste os dados de filiais no banco e tente novamente
			Help(NIL, NIL, STR0072, NIL, StrTran(STR0087,"cTabelas",fTabCheck(.F.)), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0080})
		EndIf

		Case cMove == 'ADD'
			If !Empty(aTempDisp[oBrowseTmp:nAt][2])
				cLayout  := FWSM0Layout(aTempDisp[nI][2])
				nTamEmp  := 0
				nTamUnid := 0
				nTamFil  := 0
				For nY := 1 To Len(cLayout)
					If SubStr(cLayout,nY,1) == "E"
						nTamEmp++
					ElseIf SubStr(cLayout,nY,1) == "U"
						nTamUnid++
					ElseIf SubStr(cLayout,nY,1) == "F"
						nTamFil++
					EndIf
				Next nY
				If lGestEmp
					If AllTrim(M->OO_CDEPCZ) == AllTrim(aTempDisp[oBrowseTmp:nAt][2]) .And. AllTrim(M->OO_EMPRCZ) == AllTrim(aTempDisp[oBrowseTmp:nAt][4]) .And.;
						AllTrim(M->OO_UNIDCZ) == AllTrim(aTempDisp[oBrowseTmp:nAt][6]) .And. AllTrim(M->OO_CDESCZ) == AllTrim(aTempDisp[oBrowseTmp:nAt][8])
						//STR0072 - Opera��o n�o permitida! | STR0030 - "N�o � permitido informar como empresa centralizada o mesmo conte�do da empresa centralizadora."
						Help(NIL, NIL, STR0072, NIL, STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL)

					ElseIf FindEmp(aTempDisp[oBrowseTmp:nAt][2], ;
					PadR(aTempDisp[oBrowseTmp:nAt][4],nTamEmp)+;
					PadR(aTempDisp[oBrowseTmp:nAt][6],nTamUnid)+;
					PadR(aTempDisp[oBrowseTmp:nAt][8],nTamFil))
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizadora."
						Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][2])+" "+STR0032+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][8])+" "+STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL)

					ElseIf FindEmpCen(aTempDisp[oBrowseTmp:nAt][2],;
					PadR(aTempDisp[oBrowseTmp:nAt][4],nTamEmp)+;
					PadR(aTempDisp[oBrowseTmp:nAt][6],nTamUnid)+;
					PadR(aTempDisp[oBrowseTmp:nAt][8],nTamFil))
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizada."
						Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][2])+" "+STR0032+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][8])+" "+STR0044, 1, 0, NIL, NIL, NIL, NIL, NIL)

					ElseIf !saGrpEmps[aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(aTempDisp[oBrowseTmp:nAt][2])})][2]
						//STR0072 - Opera��o n�o permitida! | STR0079 - "Falha no compartilhamento das tabelas 'cTabelas' do Grupo de Empresa 'cGrpEmp'."
						//STR0080 - Acesse o configurador do Protheus, corrija o compartilhamento, ajuste os dados de filiais no banco e tente novamente
						nAux	:= aScan(saTabelas,{|x| AllTrim(x[1]) == AllTrim(aTempDisp[oBrowseTmp:nAt][2]) .AND. !x[4] })
						cAux 	:= saTabelas[nAux][2] + " -> " + saTabelas[nAux][3] + "."
						Help(NIL, NIL, STR0072, NIL, StrTran(Strtran(STR0079,"cGrpEmp",aTempDisp[oBrowseTmp:nAt][2]),"cTabelas",fTabCheck(.F.)), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0080 + " " + STR0088 + cAux })//" Avalie: "

					Else
						aAdd(aTempSelec,aTempDisp[oBrowseTmp:nAt])
						aDel(aTempDisp, oBrowseTmp:nAt)
						aSize(aTempDisp, Len(aTempDisp)-1)
					EndIf
				Else
					If AllTrim(M->OO_CDEPCZ) == AllTrim(aTempDisp[oBrowseTmp:nAt][2]) .And.AllTrim(M->OO_CDESCZ) == AllTrim(aTempDisp[oBrowseTmp:nAt][3])
						//STR0072 - Opera��o n�o permitida! | STR0030 - "N�o � permitido informar como empresa centralizada o mesmo conte�do da empresa centralizadora."
						Help(NIL, NIL, STR0072, NIL, STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL)

					ElseIf FindEmp(aTempDisp[oBrowseTmp:nAt][2],aTempDisp[oBrowseTmp:nAt][3])
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizadora."
						Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][2])+" "+STR0032+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][3])+" "+STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL)

					ElseIf FindEmpCen(aTempDisp[oBrowseTmp:nAt][2],aTempDisp[oBrowseTmp:nAt][3])
						//STR0072 - Opera��o n�o permitida! | A empresa x filial y j� est� cadastrada como empresa centralizada."
						Help(NIL, NIL, STR0072, NIL, STR0031+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][2])+" "+STR0032+" "+AllTrim(aTempDisp[oBrowseTmp:nAt][3])+" "+STR0044, 1, 0, NIL, NIL, NIL, NIL, NIL)

					ElseIf !saGrpEmps[aScan(saGrpEmps,{|x| AllTrim(x[1]) == AllTrim(aTempDisp[oBrowseTmp:nAt][2])})][2]
						//STR0072 - Opera��o n�o permitida! | STR0079 - "Falha no compartilhamento das tabelas 'cTabelas' do Grupo de Empresa 'cGrpEmp'."
						//STR0080 - Acesse o configurador do Protheus, corrija o compartilhamento, ajuste os dados de filiais no banco e tente novamente
						nAux	:= aScan(saTabelas,{|x| AllTrim(x[1]) == AllTrim(aTempDisp[oBrowseTmp:nAt][2]) .AND. !x[4] })
						cAux 	:= saTabelas[nAux][2] + " -> " + saTabelas[nAux][3] + "."
						Help(NIL, NIL, STR0072, NIL, StrTran(Strtran(STR0079,"cGrpEmp",aTempDisp[oBrowseTmp:nAt][2]),"cTabelas",fTabCheck(.F.)), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0080 + " " +  STR0088 + cAux })//" Avalie: "

					Else
						aAdd(aTempSelec,aTempDisp[oBrowseTmp:nAt])
						aDel(aTempDisp, oBrowseTmp:nAt)
						aSize(aTempDisp, Len(aTempDisp)-1)
					EndIf
				EndIf
			EndIf

		Case cMove == 'RMV'
			If aTempSelec[oBrwTmpSel:nAt][2] != ""
				aAdd(aTempDisp,aTempSelec[oBrwTmpSel:nAt])
				aDel(aTempSelec, oBrwTmpSel:nAt)
				aSize(aTempSelec, Len(aTempSelec)-1)
			EndIf
	End Case

	If Len(aTempSelec) > 0
		If aTempSelec[1,2] == ''
			aDel(aTempSelec,1)
			aSize(aTempSelec, Len(aTempSelec)-1)
		EndIf
	EndIf
	If Len(aTempDisp) > 0
		If aTempDisp[1,2] == ''
			aDel(aTempDisp,1)
			aSize(aTempDisp, Len(aTempDisp)-1)
		EndIf
	EndIf

	If Len(aTempSelec) == 0
		If lGestEmp
			aAdd(aTempSelec,{'','','','','','','','','',0,oBRVerd})
		Else
			aAdd(aTempSelec,{'','','','','',0,oBRVerd})
		EndIf
	EndIf
	If Len(aTempDisp) == 0
		If lGestEmp
			aAdd(aTempDisp,{'','','','','','','','','',oBRVerd})
		Else
			aAdd(aTempDisp,{'','','','','',0,oBRVerd})
		EndIf
	EndIf

	IF !lAutoMacao
		oBrowseTmp:Refresh()
		If lGestEmp
			setText(oSayEsq,oBrowseTmp:nAt,aTempDisp,.F.)
		EndIf

		oBrwTmpSel:Refresh()
		If lGestEmp
			setText(oSayDir,oBrwTmpSel:nAt,aTempSelec,.T.)
		EndIf
	ENDIF

	If lGestEmp
		aSort(aTempDisp, , , { | x,y | x[2]+x[4]+x[6]+x[8] < y[2]+y[4]+y[6]+y[8] } )
	Else
		aSort(aTempDisp, , , { | x,y | x[2]+x[3] < y[2]+y[3] } )
	EndIf

Return .T.

//------------------------------------------------------------
//Preenche as informa��es de cabe�alho atrav�s da Array
//------------------------------------------------------------
Static Function PreencheCab(aInfo)
Default lAutoMacao := .F.

	cFilePai          := aInfo[1]
	M->OO_CDEPCZ      := aInfo[2]
	M->OO_CDESCZ      := aInfo[3]
	M->OO_DSEPCZ      := aInfo[4]
	M->OO_DSESCZ      := aInfo[5]
	If lGestEmp
		M->OO_EMPRCZ := aInfo[6]
		M->OO_UNIDCZ := aInfo[7]
		M->OO_DSEMPR := aInfo[8]
		M->OO_DSUNID := aInfo[9]
	EndIf
	IF !lAutoMacao
		oEnch:Refresh()
		oBrowseTmp:Refresh()
		oBrwTmpSel:Refresh()
	ENDIF
Return Nil

//------------------------------------------------------------
//
//------------------------------------------------------------
Static Function DlgEmpOK(oDlg,oLbx,aCpos)
	Local cLayout  := ""
	Local nTamEmp  := 0
	Local nTamUnid := 0
	Local nTamFil  := 0
	Local nI       := 0
	Local aRet := {}

	If lGestEmp
		aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,5],;
		aCpos[oLbx:nAt,6], aCpos[oLbx:nAt,7], aCpos[oLbx:nAt,8], aCpos[oLbx:nAt,9]}
	Else
		aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,5]}
	EndIf

	oDlg:End()

	If lGestEmp
		cLayout := FWSM0Layout(oLbx:aArray[oLbx:nAt,2])

		For nI := 1 To Len(cLayout)
			If SubStr(cLayout,nI,1) == "E"
				nTamEmp++
			ElseIf SubStr(cLayout,nI,1) == "U"
				nTamUnid++
			ElseIf SubStr(cLayout,nI,1) == "F"
				nTamFil++
			EndIf
		Next nI

		If FindEmp(oLbx:aArray[oLbx:nAt,2],;
		PadR(oLbx:aArray[oLbx:nAt,6],nTamEmp)+;
		PadR(oLbx:aArray[oLbx:nAt,7],nTamUnid)+;
		PadR(oLbx:aArray[oLbx:nAt,3],nTamFil))
			lRet[1] := .F.
		ElseIf FindEmpCen(oLbx:aArray[oLbx:nAt,2],;
		PadR(oLbx:aArray[oLbx:nAt,6],nTamEmp)+;
		PadR(oLbx:aArray[oLbx:nAt,7],nTamUnid)+;
		PadR(oLbx:aArray[oLbx:nAt,3],nTamFil))
			lRet[2] := .F.
		Else
			PreencheCab(aRet)
		EndIf
	Else
		If FindEmp(oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3])
			lRet[1] := .F.
		ElseIf FindEmpCen(oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3])
			lRet[2] := .F.
		Else
			PreencheCab(aRet)
		EndIf
	EndIf


Return Nil

//------------------------------------------------------------
/*Apresenta Dialog com todas empresas do arquivo SM0 para
sele��o no cabe�alho*/
//------------------------------------------------------------
Static Function DialogEmp()
	//Local aRet        := {}
	Local aCpos      := aClone(saSM0Emp)
	Local aGroups    := FWAllGrpCompany()
	Local aFiliais   := {}
	Local aInfFilial := {}
	Local nI         := 0
	Local nZ         := 0
	Local nPos       := 0
	Local nTamanho   := 0
	Local oDlg
	Local oLbx

	Private lRet := {.T.,.T.}

	If lGestEmp
		nTamanho := 900
	Else
		nTamanho := 500
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0028 FROM 0,0 TO 240,nTamanho PIXEL//"Empresas"

	If lGestEmp
		@ 10,10 LISTBOX oLbx FIELDS HEADER STR0053,STR0054,STR0013,STR0015,STR0055,STR0056,STR0014,STR0016  SIZE 440,95 OF oDlg PIXEL
		//"Grupo","Desc grupo","Empresa","Desc empresa","Unidade neg�cio","Desc unidade neg�cio","Filial","Desc filial"
		aCpos := {}
		For nI := 1 To Len(aGroups)
			aFiliais := FWAllFilial(,,aGroups[nI],.F.)

			For nZ := 1 To Len(aFiliais)
				nPos := aScan(saSM0Emp,{|x| x[2] == aGroups[nI] .And. x[3] == aFiliais[nZ] })
				If nPos > 0
					cArquivo := saSM0Emp[nPos,1]
				Else
					cArquivo := ""
				EndIf
				aInfFilial := FwArrFilAtu(aGroups[nI],aFiliais[nZ])
				If Len(aInfFilial) > 0
					aAdd(aCpos,{cArquivo,aGroups[nI],aInfFilial[SM0_FILIAL],aInfFilial[SM0_DESCGRP],aInfFilial[SM0_NOMRED],;
					aInfFilial[SM0_EMPRESA],aInfFilial[SM0_UNIDNEG],aInfFilial[SM0_DESCEMP],aInfFilial[SM0_DESCUN]})
				EndIf
			Next nZ
		Next nI

	Else
		@ 10,10 LISTBOX oLbx FIELDS HEADER STR0013,STR0014,STR0015,STR0016  SIZE 230,95 OF oDlg PIXEL//"Empresa", "Filial", "Desc Empresa", "Desc Filial"
	EndIf

	oLbx:SetArray( aCpos )
	If lGestEmp
		oLbx:bLine     := {|| {aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,6], aCpos[oLbx:nAt,8],;
		aCpos[oLbx:nAt,7], aCpos[oLbx:nAt,9], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,5] }}
	Else
		oLbx:bLine     := {|| {aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,5]}}
	EndIf
	oLbx:bLDblClick := {|| DlgEmpOK(oDlg,oLbx,aCpos)  }

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION ( DlgEmpOK(oDlg,oLbx,aCpos) )  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
Return lRet

//------------------------------------------------------------
//PCPA106VHF - Valida Fields do Header
//------------------------------------------------------------
Function PCPA106VHF()
	Local lFind := .F.
	Local lRet  := .T.
	Local aInfo := {}
	Local nI
	Local nTamEmp  := 0
	Local nTamUnid := 0
	Local nTamFil  := 0
	Local nX       := 0
	Local cLayout  := ""
	Default lAutoMacao := .F.

	Private cFilialPai

	If lGestEmp .And. !Empty(M->OO_CDEPCZ)
		cLayout := FWSM0Layout(M->OO_CDEPCZ)
	EndIf

	IF Empty(M->OO_CDEPCZ)
		M->OO_DSEPCZ := CriaVar("OO_DSEPCZ",.F.)
		M->OO_EMPRCZ := CriaVar("OO_EMPRCZ",.F.)
		M->OO_DSEMPR := CriaVar("OO_DSEMPR",.F.)
		M->OO_UNIDCZ := CriaVar("OO_UNIDCZ",.F.)
		M->OO_DSUNID := CriaVar("OO_DSUNID",.F.)
		M->OO_CDESCZ := CriaVar("OO_CDESCZ",.F.)
		M->OO_DSESCZ := CriaVar("OO_DSESCZ",.F.)
	Else

		If Empty(M->OO_EMPRCZ) .And. lGestEmp .And. AT("E",cLayout) > 0
			M->OO_DSEMPR := CriaVar("OO_DSEMPR",.F.)
			M->OO_UNIDCZ := CriaVar("OO_UNIDCZ",.F.)
			M->OO_DSUNID := CriaVar("OO_DSUNID",.F.)
			M->OO_CDESCZ := CriaVar("OO_CDESCZ",.F.)
			M->OO_DSESCZ := CriaVar("OO_DSESCZ",.F.)
		Else
			If Empty(M->OO_UNIDCZ) .And. lGestEmp .And. AT("U",cLayout) > 0
				M->OO_DSUNID := CriaVar("OO_DSUNID",.F.)
				M->OO_CDESCZ := CriaVar("OO_CDESCZ",.F.)
				M->OO_DSESCZ := CriaVar("OO_DSESCZ",.F.)
			Else
				If Empty(M->OO_CDESCZ)
					M->OO_DSESCZ := CriaVar("OO_DSESCZ",.F.)
				EndIf
			EndIf
		EndIf
	EndIf

	cLayout := FWSM0Layout(M->OO_CDEPCZ)

	nTamEmp  := 0
	nTamUnid := 0
	nTamFil  := 0

	For nX := 1 To Len(cLayout)
		If SubStr(cLayout,nX,1) == "E"
			nTamEmp++
		ElseIf SubStr(cLayout,nX,1) == "U"
			nTamUnid++
		ElseIf SubStr(cLayout,nX,1) == "F"
			nTamFil++
		EndIf
	Next nX

	aInfo := GetInfoEmp(M->OO_CDEPCZ,PadR(M->OO_EMPRCZ,nTamEmp),PadR(M->OO_UNIDCZ,nTamUnid),PadR(M->OO_CDESCZ,nTamFil))

	For nI := 1 To Len(saSM0Emp)
		If lGestEmp
			If AllTrim(M->OO_CDEPCZ) == AllTrim(saSM0Emp[nI][2]) .And. ;
			Padr(M->OO_EMPRCZ,nTamEmp)+PadR(M->OO_UNIDCZ,nTamUnid)+PadR(M->OO_CDESCZ,nTamFil) == PadR(saSM0Emp[nI][3],nTamEmp+nTamUnid+nTamFil)
				cFilePai := saSM0Emp[nI][1]
				lFind := .T.
			EndIf
		Else
			If AllTrim(M->OO_CDEPCZ) == AllTrim(saSM0Emp[nI][2]) .And. AllTrim(M->OO_CDESCZ) == AllTrim(saSM0Emp[nI][3])
				cFilePai := saSM0Emp[nI][1]
				lFind := .T.
			EndIf
		EndIf
	Next

	If !lFind
		cFilePai := ''
	EndIf

	IF !lAutoMacao
		oBrowseTmp:Refresh()
		oBrwTmpSel:Refresh()
	ENDIF

	//Grupo
	If !Empty(aInfo[1])
		M->OO_CDEPCZ  := aInfo[1]
	Else
		If !Empty(M->OO_CDEPCZ)
			DlgAlert(STR0052) //"Grupo de empresas inv�lido."
			lRet := .F.
		EndIf
	EndIf
	M->OO_DSEPCZ := aInfo[2]

	If lGestEmp .And. lRet
		//Empresa
		If AT("E",cLayout) > 0 .And. !Empty(M->OO_CDEPCZ)
			If !Empty(aInfo[3])
				M->OO_EMPRCZ := aInfo[3]
			Else
				If !Empty(M->OO_EMPRCZ)
					DlgAlert(STR0051) //"Empresa inv�lida."
					lRet := .F.
				EndIf
			EndIf
			M->OO_DSEMPR := aInfo[4]
		EndIf

		//Unidade de neg�cio
		If lRet .And. AT("U",cLayout) > 0 .And. !Empty(M->OO_CDEPCZ) .And. !Empty(M->OO_EMPRCZ)
			If !Empty(aInfo[5])
				M->OO_UNIDCZ := aInfo[5]
			Else
				If !Empty(M->OO_UNIDCZ)
					DlgAlert(STR0050) //"Unidade de neg�cio inv�lida."
					lRet := .F.
				EndIf
			EndIf
			M->OO_DSUNID := aInfo[6]
		EndIf
	EndIf

	//Filial
	If lRet
		If (lGestEmp .And. !Empty(M->OO_CDEPCZ) .And. ;
		( AT("E",cLayout) == 0 .Or. ( AT("E",cLayout) > 0 .And. !Empty(M->OO_EMPRCZ) ) ) .And. ;
		( AT("U",cLayout) == 0 .Or. ( AT("U",cLayout) > 0 .And. !Empty(M->OO_UNIDCZ) ) ) )  .Or. ;
		( !lGestEmp .And. !Empty(M->OO_CDEPCZ) )
			If !Empty(aInfo[7])
				M->OO_CDESCZ  := aInfo[7]
			Else
				If !Empty(M->OO_CDESCZ)
					DlgAlert(STR0049) //"Filial inv�lida."
					lRet := .F.
				EndIf
			EndIf
			M->OO_DSESCZ := aInfo[8]
		EndIf
	EndIf

	If lRet
		If !Empty(M->OO_CDEPCZ) .And. !Empty(M->OO_CDESCZ) .And. ;
		((lGestEmp .And. (AT("E",cLayout) == 0 .Or. (AT("E",cLayout) > 0 .And. !Empty(M->OO_EMPRCZ))) .And. ;
		(AT("U",cLayout) == 0 .Or. (AT("U",cLayout) > 0 .And. !Empty(M->OO_UNIDCZ)))) .Or. !lGestEmp)
			If lGestEmp
				cLayout := FWSM0Layout(M->OO_CDEPCZ)

				nTamEmp  := 0
				nTamUnid := 0
				nTamFil  := 0

				For nX := 1 To Len(cLayout)
					If SubStr(cLayout,nX,1) == "E"
						nTamEmp++
					ElseIf SubStr(cLayout,nX,1) == "U"
						nTamUnid++
					ElseIf SubStr(cLayout,nX,1) == "F"
						nTamFil++
					EndIf
				Next nX

				If FindEmp(M->OO_CDEPCZ,;
				PadR(M->OO_EMPRCZ,nTamEmp)+;
				PadR(M->OO_UNIDCZ,nTamUnid)+;
				PadR(M->OO_CDESCZ,nTamFil))
					//STR0072 - Opera��o n�o permitida! | STR0007 - J� existe um registro com essa empresa/filial.
					Help(NIL, NIL, STR0072, NIL, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL)
					lRet := .F.
				ElseIf FindEmpCen(M->OO_CDEPCZ,;
				PadR(M->OO_EMPRCZ,nTamEmp)+;
				PadR(M->OO_UNIDCZ,nTamUnid)+;
				PadR(M->OO_CDESCZ,nTamFil))
					//STR0072 - Opera��o n�o permitida! | STR0042 - Empresa j� cadastrada como empresa centralizada"
					Help(NIL, NIL, STR0072, NIL, STR0042, 1, 0, NIL, NIL, NIL, NIL, NIL)
					lRet := .F.
				EndIf
			Else
				If FindEmp(M->OO_CDEPCZ,M->OO_CDESCZ)
					//STR0072 - Opera��o n�o permitida! | STR0007 - J� existe um registro com essa empresa/filial.
					Help(NIL, NIL, STR0072, NIL, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL)
					lRet := .F.
				ElseIf FindEmpCen(M->OO_CDEPCZ,M->OO_CDESCZ)
					//STR0072 - Opera��o n�o permitida! | STR0042 - Empresa j� cadastrada como empresa centralizada"
					Help(NIL, NIL, STR0072, NIL, STR0042, 1, 0, NIL, NIL, NIL, NIL, NIL)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .and. AllTriM(ReadVar()) $ "M->OO_CDEPCZ|M->OO_CDESCZ"  .and. !Empty(M->OO_CDEPCZ) .and. !Empty(M->OO_CDESCZ) .and. cEmpPai	!= M->OO_CDEPCZ
		cFilialPai	:= PadR(M->OO_EMPRCZ,nTamEmp)+PadR(M->OO_UNIDCZ,nTamUnid)+PadR(M->OO_CDESCZ,nTamFil)
		cEmpPai		:= M->OO_CDEPCZ
		MsgRun(STR0091,STR0090,{|| UpdLegenda(aTempDisp, aTempSelec) })	//"Aguarde . . . Processando regras de compartilhamento.." - "Aguarde!"
		oBrwTmpSel:Refresh()
		oBrowseTmp:Refresh()
	EndIf

Return lRet

//------------------------------------------------------------
//Retorna todas empresas disponiveis no SM0
//------------------------------------------------------------
/*
Retorno: aEmpresas[1] - C�digo do grupo de empresas
aEmpresas[2] - Descri��o do grupo de empresas
aEmpresas[3] - C�digo da empresa
aEmpresas[4] - Descri��o da empresa
aEmpresas[5] - C�digo da unidade de neg�cio
aEmpresas[6] - Descri��o da unidade de neg�cio
aEmpresas[7] - C�digo da filial
aEmpresas[8] - Descri��o da filial
*/
Static Function GetInfoEmp(cGrupo,cEmpresa,cUnid,cFil)
	Local aEmpresas   := {}
	Local aAllCompany := {}
	Local aAllUnit    := {}
	Local aInfFilial  := {}
	Local lFind       := .F.
	Local nI          := 0
	Local cLayout     := ""
	Local cLayoutGrp  := ""
	Local nY          := 0
	Local nX          := 0
	Local nTamEmp     := 0
	Local nTamUnid    := 0
	Local nTamFil     := 0

	//Verifica o grupo de empresas
	SM0->(dbGotop())
	While !SM0->(EOF())
		If !SM0->(Deleted())
			If AllTrim(SM0->M0_CODIGO) == AllTrim(cGrupo)
				aAdd(aEmpresas, AllTrim(SM0->M0_CODIGO))
				aAdd(aEmpresas, AllTrim(SM0->M0_NOME))
				lFind := .T.
				Exit
			EndIf
		EndIf
		SM0->(dbSkip())
	End
	If !lFind
		aAdd(aEmpresas,"")
		aAdd(aEmpresas,"")
	EndIf
	//Se estiver com gest�o de empresas, verifica a Empresa e Unidade de neg�cio
	If lGestEmp
		cLayout := FWSM0Layout(cGrupo)
		//Verifica a Empresa
		If lFind
			If AT("E",cLayout) > 0
				lFind := .F.
				aAllCompany := FWAllCompany(cGrupo)
				For nI := 1 To Len(aAllCompany)
					If AllTrim(aAllCompany[nI]) == AllTrim(cEmpresa)
						lFind := .T.
						aAdd(aEmpresas, AllTrim(aAllCompany[nI]))
						aAdd(aEmpresas, AllTrim(FWCompanyName(cGrupo,aAllCompany[nI])))
						Exit
					EndIf
				Next nI
			Else
				aAdd(aEmpresas,"")
				aAdd(aEmpresas,"")
			EndIf
		EndIf
		If !lFind
			aAdd(aEmpresas,"")
			aAdd(aEmpresas,"")
		EndIf
		//Verifica a Unidade de neg�cio
		If lFind
			If AT("U",cLayout) > 0
				lFind := .F.
				aAllUnit := FWAllUnitBusiness(cEmpresa,cGrupo)
				cLayoutGrp := FWSM0Layout(cGrupo)

				nTamEmp  := 0
				nTamUnid := 0
				nTamFil  := 0

				For nY := 1 To Len(cLayoutGrp)
					If SubStr(cLayoutGrp,nY,1) == "E"
						nTamEmp++
					ElseIf SubStr(cLayoutGrp,nY,1) == "U"
						nTamUnid++
					ElseIf SubStr(cLayoutGrp,nY,1) == "F"
						nTamFil++
					EndIf
				Next nY
				For nI := 1 To Len(aAllUnit)
					If AllTrim(aAllUnit[nI]) == AllTrim(cUnid)
						lFind := .T.
						aAdd(aEmpresas, AllTrim(aAllUnit[nI]))
						aAdd(aEmpresas, AllTrim(FWUnitName(cGrupo,PadR(cEmpresa,nTamEmp)+PadR(aAllUnit[nI],nTamUnid))))
						Exit
					EndIf
				Next nI
			Else
				aAdd(aEmpresas,"")
				aAdd(aEmpresas,"")
			EndIf
		EndIf
		If !lFind
			aAdd(aEmpresas,"")
			aAdd(aEmpresas,"")
		EndIf
	Else
		aAdd(aEmpresas,"")
		aAdd(aEmpresas,"")
		aAdd(aEmpresas,"")
		aAdd(aEmpresas,"")
	EndIf

	//Verifica a Filial
	If lFind
		lFind := .F.
		If lGestEmp
			cLayout := FWSM0Layout(cGrupo)

			nTamEmp  := 0
			nTamUnid := 0
			nTamFil  := 0

			For nX := 1 To Len(cLayout)
				If SubStr(cLayout,nX,1) == "E"
					nTamEmp++
				ElseIf SubStr(cLayout,nX,1) == "U"
					nTamUnid++
				ElseIf SubStr(cLayout,nX,1) == "F"
					nTamFil++
				EndIf
			Next nX

			cFil := PadR(cEmpresa,nTamEmp)+PadR(cUnid,nTamUnid)+PadR(cFil,nTamFil)
		EndIf
		SM0->(dbGotop())
		While !SM0->(EOF())
			If !SM0->(Deleted())
				If AllTrim(SM0->M0_CODIGO) == AllTrim(cGrupo) .And. AllTrim(SM0->M0_CODFIL) == AllTrim(cFil)
					aInfFilial := FwArrFilAtu(cGrupo,cFil)
					If Len(aInfFilial) > 0
						aAdd(aEmpresas, AllTrim(aInfFilial[SM0_FILIAL]))
						aAdd(aEmpresas, AllTrim(SM0->M0_FILIAL))
						lFind := .T.
						Exit
					EndIf
				EndIf
			EndIf
			SM0->(dbSkip())
		End

		If !lFind
			aAdd(aEmpresas,"")
			aAdd(aEmpresas,"")
		EndIf
	Else
		aAdd(aEmpresas,"")
		aAdd(aEmpresas,"")
	EndIf
Return aEmpresas

//-------------------------------------------------------------------------
//Coleta todas informa��es de todas empresas
// lError - Enviada por refer�ncia. Retorna se houve erro durante processo
// lMrp - Indica se o processo vai ser iniciado pelo MRP.
//-------------------------------------------------------------------------
Function PCPA106GEM(lError, lMrp, lWait, cEmpPai)
	Local aSM0Emp	:= {}

	Default lWait	:= .T.
	Default cEmpPai	:= cEmpAnt

	//O processamento desta fun��o foi alterado para Job, pois
	//quando o ambiente possuia mais de um grupo de empresas,
	//estava apresentando erros na abertura do programa PCPA106;
	StartJob("a106JOBGEM",GetEnvServer(),lWait,cEmpAnt,cFilAnt,lError,lMrp,saTabelas,saGrpEmps,snThread,cEmpPai)
	If lWait
		GetGlbVars("JOBGEM",@aSM0Emp,@lError,@scMsg,@saTabelas,@saGrpEmps,@snThread)
		If !lError .AND. Empty(aSM0Emp)
			Sleep(2000)
			aSM0Emp := PCPA106GEM(@lError, lMrp, lWait, cEmpPai)
		ElseIf lError .And. !Empty(scMsg)
			Help( , , 'PCPA106', , scMsg, 1, 0 )
		ElseIf lError .And. Empty(scMsg)
			Help( , , 'PCPA106', , STR0098, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0097}) //"Problema com o cadastro de empresas centralizadas.". - Contate o suporte da Totvs.
		EndIf
		ClearGlbValue("JOBGEM")
	EndIf

Return aSM0Emp

//-------------------------------------------------------------------------
//Processamento em JOB para retorno da array aSM0Emp
//-------------------------------------------------------------------------
Function a106JOBGEM(cEmp,cFil,lError,lMrp,aTabelas,aGrpEmps,nThread,cEmpPaiX)
	Local aSM0Emp 	:= {}
	Local aSM0Aux	:= {}
	Local cMsg		:= ""
	Local aAreaSM0

	Private bErrorBlock := ErrorBlock({|e| a106errblk(e)})
	Private cMsgErr := ""
	Private oBRVerd   	:= LoadBitmap(GetResources(),'BR_VERDE')
	Private oBRVerm   	:= LoadBitmap(GetResources(),'BR_VERMELHO')
	Private oBRAmar   	:= LoadBitmap(GetResources(),'BR_AMARELO')

	cEmpPai		:= Iif(cEmpPai == Nil, cEmpPaiX, cEmpPai)

	//Conout("PCPA106 - PREPARE ENVIRONMENT - EMPRESA " + cEmp + " FILIAL " + cFil + " - THREAD ID: " + cValToChar(ThreadId()))
	//PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "PCP"
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil)

	BEGIN SEQUENCE
		saTabelas	:= Iif(Empty(aTabelas),{},aTabelas)
		saGrpEmps	:= Iif(Empty(aGrpEmps),{},aGrpEmps)
		snThread	:= nThread

		//Add Array's Referente cEmpAnt
		VerfAllTab({'', cEmpAnt, cFilAnt}, .F., @cMsg)

		SM0->(dbGotop())
		While !SM0->(EOF())
			aAreaSM0	:= SM0->(GetArea())
			If !SM0->(Deleted())

				If !Empty(aSM0Aux)
					aSize(aSM0Aux,0)
				EndIf

				aAdd(aSM0Aux , 	{'',;
								SM0->M0_CODIGO,;
								SM0->M0_CODFIL,;
								AllTrim(SM0->M0_NOME),;
								AllTrim(SM0->M0_FILIAL),;
								0,;
								"BR_VERDE"})

				If lMrp
					aSM0Aux[1][7]	:= "BR_VERDE"
					aAdd(aSM0Emp, aClone(aSM0Aux[1]))
				Else
					If !VerfAllTab(@aSM0Aux[1], lMrp, @cMsg)
						lError	:= .T.
						aSM0Aux[1][7]	:= "BR_VERMELHO"
						aAdd(aSM0Emp, aClone(aSM0Aux[1]))
					Else
						aSM0Aux[1][7]	:= "BR_VERDE"
						aAdd(aSM0Emp, aClone(aSM0Aux[1]))
					EndIf
				EndIf
			EndIf
			RestArea(aAreaSM0)
			SM0->(dbSkip())
		End

		If !VerificaInteg(@aSM0Emp, lMrp, @cMsg, .F.)
			lError	:= .T.
		EndIf

		//Revovery de Erro da Transa��o
		RECOVER

		lError := .T.
		cMsg := cMsgErr
		//Conout("PCPA106 - Erro: " + cMsg)

	END SEQUENCE

	RESET ENVIRONMENT

	PutGlbVars("JOBGEM",aSM0Emp,lError,cMsg,saTabelas,saGrpEmps,snThread)

	TravaThrd(.F.,.T.)

Return

//-------------------------------------------------------------------------
//
//-------------------------------------------------------------------------
Function a106errblk(e)
	cMsgErr := STR0069 + cEmpAnt + ". " + STR0070 + CHR(10) + STR0071 + AllTrim(e:description) + CLRF + e:errorstack
	Break
Return

//------------------------------------------------------------
/*Filtra a array de empresas utilizando somente as empresas do
grupo de empresas MRP*/
//------------------------------------------------------------
Static Function RegeraEmp(aMrp,aEmpresas)
	Local nI := 1
	Local nJ
	Local cGrupoEMP := ""
	Local cGrupoMRP := ""
	Local lAchou := .F.

	While nI <= Len(aEmpresas)
		lAchou := .F.
		cGrupoEMP := AllTrim(aEmpresas[nI][2])+AllTrim(aEmpresas[nI][3])
		For nJ := 1 To Len(aMrp)
			cGrupoMRP := AllTrim(aMrp[nJ][3])+AllTrim(aMrp[nJ][4])
			If cGrupoEMP == cGrupoMRP
					lAchou := .T.
					Exit
				EndIf
			Next

		If cGrupoEMP == AllTrim(aMrp[1][1])+AllTrim(aMrp[1][2])
			lAchou := .T.
		EndIf

			If !lAchou
			aDel(aEmpresas,nI)
			aSize(aEmpresas,Len(aEmpresas)-1)
		Else
			nI++
			EndIf

	End

Return Nil

//------------------------------------------------------------
/*Coleta informa��es das empresas para posteriormente verificar
se est�o integradas entre si*/
//------------------------------------------------------------
Static Function VerificaInteg(aEmpresas, lMrp, cMsg, lVerifTabs)
	Local nI
	Local lRet  := .T.
	Local cEmpAtual   := cEmpAnt
	Local cFilAtual   := cFilAnt
	Local aDistEmp, aMrp

	Default lVerifTabs := .T.

	If lMrp
		If GetGEMRP(cEmpAtual,cFilAtual,@aMrp)
			Return .T.
		Else
			RegeraEmp(aMrp,@aEmpresas)
		EndIf
	EndIf

	If lVerifTabs .Or. lMrp
		aDistEmp := GetDistEmp(aEmpresas)
		For nI := 1 To Len(aDistEmp)
			If !VerfAllTab(aDistEmp[nI], lMrp, @cMsg)
				lRet := .F.
				Exit
			EndIf
		Next
	/*Else
		UpdLegenda(aTempDisp, aTempSelec, lVerifTabs)*/
	EndIf

	//Realiza a troca da empresa logada - N�o funcionando com RetSqlName
	//A107AltEmp(cEmpAtual, cFilAtual)

Return lRet

//------------------------------------------------------------
/*Coleta somente as empresas referentes ao grupo do MRP. Se
n�o possuir grupo, retorna true e continua o processo normal*/
//------------------------------------------------------------
Static Function GetGEMRP(cEmpresaX,cFilialX,aGEMrp)

	Local aFilInf  := {}
	Local nTamEmp  := Len(FWSM0Layout(cEmpAnt,1))
	Local nTamUNeg := Len(FWSM0Layout(cEmpAnt,2))
	Local nTamFil  := Len(FWSM0Layout(cEmpAnt,3))
    Local nTamSM0  := FWSizeFilial(cEmpAnt)

	aGEMrp	:= {}
	cSeek	:= ""

	If FwAliasInDic("SOP")
		If fIsCorpManage()
			aFilInf := FwArrFilAtu(cEmpresaX,cFilialX)
			If Len(aFilInf) < 1
				Return .F.
			EndIf
			SOP->(dbSetOrder(3))
			If SOP->(dbSeek(xFilial("SOP")+CorValFld(cEmpresaX,"OP_CDEPCZ")+CorValFld(aFilInf[SM0_EMPRESA],"OP_EMPRCZ")+CorValFld(aFilInf[SM0_UNIDNEG],"OP_UNIDCZ")+CorValFld(aFilInf[SM0_FILIAL],"OP_CDESCZ")))
				cSeek := Padr(xFilial("SOP"),nTamSM0) + AllTrim(cEmpresaX) + Padr(aFilInf[SM0_EMPRESA],nTamEmp) + Padr(aFilInf[SM0_UNIDNEG],nTamUneg) + Padr(aFilInf[SM0_FILIAL],nTamFil)

				While Padr(SOP->OP_FILIAL,nTamSM0) + AllTrim(SOP->OP_CDEPCZ) + Padr(SOP->OP_EMPRCZ,nTamEmp) + Padr(SOP->OP_UNIDCZ,nTamUneg) + Padr(SOP->OP_CDESCZ,nTamFil) == cSeek
					aAdd(aGEMrp,{SOP->OP_CDEPCZ,Padr(SOP->OP_EMPRCZ,nTamEmp) + Padr(SOP->OP_UNIDCZ,nTamUneg) + Padr(SOP->OP_CDESCZ,nTamFil),SOP->OP_CDEPGR,Padr(SOP->OP_EMPRGR,nTamEmp) + Padr(SOP->OP_UNIDGR,nTamUneg) + Padr(SOP->OP_CDESGR,nTamFil)})
					SOP->(dbSkip())
				End
				Return .F.
			Else
				SOP->(dbSetOrder(4))
				If SOP->(dbSeek(xFilial("SOP")+CorValFld(cEmpresaX,"OP_CDEPGR")+CorValFld(aFilInf[SM0_EMPRESA],"OP_CDESGR")+CorValFld(aFilInf[SM0_UNIDNEG],"OP_UNIDGR")+CorValFld(aFilInf[SM0_FILIAL],"OP_CDESGR")))

					cSeek := SOP->OP_FILIAL+OP_CDEPCZ+OP_EMPRCZ+OP_UNIDCZ+OP_CDESCZ

					SOP->(dbSetOrder(3))
					SOP->(dbSeek(cSeek))

					While SOP->OP_FILIAL+OP_CDEPCZ+OP_EMPRCZ+OP_UNIDCZ+OP_CDESCZ == cSeek
						aAdd(aGEMrp,{SOP->OP_CDEPCZ,Padr(SOP->OP_EMPRCZ, nTamEmp)+Padr(SOP->OP_UNIDCZ, nTamUneg)+Padr(SOP->OP_CDESCZ,nTamFil),SOP->OP_CDEPGR,AllTrim(SOP->OP_EMPRGR)+AllTrim(SOP->OP_UNIDGR)+AllTrim(SOP->OP_CDESGR)})
						SOP->(dbSkip())
					End
					Return .F.
				Else
					Return .T.
				EndIf
			EndIf
		Else
			SOP->(dbSetOrder(1))
			If SOP->(dbSeek(xFilial("SOP")+CorValFld(cEmpresaX,"OP_CDEPCZ")+CorValFld(cFilialX,"OP_CDESCZ")))
				cSeek := Padr(xFilial("SOP"),nTamSM0) + AllTrim(cEmpresaX) + Padr(cFilialX,nTamFil)

				While Padr(SOP->OP_FILIAL,nTamSM0) + AllTrim(SOP->OP_CDEPCZ) + Padr(SOP->OP_CDESCZ,nTamFil) == cSeek
					aAdd(aGEMrp,{SOP->OP_CDEPCZ,SOP->OP_CDESCZ,SOP->OP_CDEPGR,SOP->OP_CDESGR})
					SOP->(dbSkip())
				End
				Return .F.
			Else
				SOP->(dbSetOrder(2))
				If SOP->(dbSeek(xFilial("SOP")+CorValFld(cEmpresaX,"OP_CDEPGR")+CorValFld(cFilialX,"OP_CDESGR")))

					cSeek := SOP->(OP_FILIAL+OP_CDEPCZ+OP_CDESCZ)

					SOP->(dbSetOrder(1))
					SOP->(dbSeek(cSeek))

					While SOP->(OP_FILIAL+OP_CDEPCZ+OP_CDESCZ) == cSeek
						aAdd(aGEMrp,{SOP->OP_CDEPCZ,SOP->OP_CDESCZ,SOP->OP_CDEPGR,SOP->OP_CDESGR})
						SOP->(dbSkip())
					End
					Return .F.
				Else
					Return .T.
				EndIf
			EndIf
		EndIf
	Else
		Return .T.
	EndIf

Return .F.

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} VerfAllTab
Chamadas isoladas da fun��o VerfAllTab() para todas as tabelas da empresa:
-> VerfAllTab(): Verifica se a tabela existe e esta compartilhada
@author brunno.costa
@since 23/10/2018
@version P12
/*/
/*-------------------------------------------------------------------*/

Static Function VerfAllTab(aEmpresa, lMrp, cMsg)

	Local lRet		:= .T.

	//Cria saTabCheck
	fTabCheck(.T.)

	//Realiza a troca da empresa logada - N�o funcionando com RetSqlName
	//A107AltEmp(aEmpresa[2], aEmpresa[3])

	If !VerifTabl(aEmpresa[2], aEmpresa[3], @saTabelas, @saGrpEmps, @cMsg)
		lRet := .F.
	EndIf
	
Return lRet

//------------------------------------------------------------
/*Verifica se a tabela existe e esta compartilhada*/
//------------------------------------------------------------
Static Function VerifTabl(cEmpX, cFilX, aTabelas, aGrpEmps, cMsg)
	Local lRet			:= .T.
	Local nIndTabPai	:= 0
	Local nIndTabAtu	:= 0
	Local aTabCheck		:= saTabCheck

	cFilX		:= PadR(cFilX, Len(SM0->M0_CODFIL))
	nIndTabAtu	:= aScan(aGrpEmps,{|x| AllTrim(x[1]) == AllTrim(cEmpX) .AND. !x[2]})

	//Se j� processou e identificou falha
	If nIndTabAtu > 0
			lRet := .F.
	Else
		nIndTabAtu	:= aScan(aGrpEmps,{|x| AllTrim(x[1]) == AllTrim(cEmpX)})
		EndIf

	//Se n�o processou
	If nIndTabAtu == 0
		IF cEmpX != cEmpAnt
			StartJob("a106JobTab",GetEnvServer(),.T., .T., cEmpX, cFilX, aTabCheck, aTabelas, aGrpEmps, cMsg, cEmpPai)
			GetGlbVars("JOBTAB",@aTabelas, @aGrpEmps, @lRet, @cMsg)
			ClearGlbValue("JOBTAB")
		Else
			lRet	:= a106JobTab(.F., cEmpX, cFilX, aTabCheck, @aTabelas, @aGrpEmps, @cMsg, cEmpPai)
		EndIf

		nIndTabAtu	:= aScan(aGrpEmps,{|x| x[1] == cEmpX })
		nIndTabPai	:= aScan(aGrpEmps,{|x| x[1] == cEmpPai })

		If lRet .and. ((nIndTabPai == 0 .OR. nIndTabAtu == 0) .AND. cEmpX != cEmpPai)
			lRet	:= .F.
			If Empty(cMsg)
				cMsg	:= STR0082			//"Falha no JOB a106JobTab"
		Else
				cMsg	:= CLRF + STR0082	//"Falha no JOB a106JobTab"
			EndIf
		EndIf
	Else//Se j� processou
		lRet	:= aGrpEmps[nIndTabAtu][2]
	EndIf

Return lRet

//------------------------------------------------------------
/*Verifica se a tabela existe e esta compartilhada*/
//------------------------------------------------------------
Function a106JobTab(lPrepAmb, cEmpX, cFilX, aTabCheck, aTabelas, aGrpEmps, cMsg, cEmpPaiX)
	Local lRet		:= .T.
	Local cTab		:= fTabCheck(.F., aTabCheck)
	Local nIndAtual	:= 0
	Local nIndTabPai

	cEmpPai		:= Iif(cEmpPai == Nil, cEmpPaiX, cEmpPai)

	If lPrepAmb
		//Conout("PCPA106 - PREPARE ENVIRONMENT EMPRESA " + cEmpX + " FILIAL " + cFilX + " MODULO PCP TABLES " + cTab + " - THREAD ID: " + cValToChar(ThreadId()))
		//PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX MODULO "PCP" TABLES cTab
		RpcSetType(3)
		RpcSetEnv(cEmpX,cFilX)
	EndIf

	For nIndAtual	:= 1 to Len(aTabCheck)
		lRetLoop	:= .T.
		cTab		:= aTabCheck[nIndAtual]
		If FwAliasInDic(cTab)
			If AllTrim(FwModeAccess(cTab,3)) == "E" .Or. AllTrim(FwModeAccess(cTab,2)) == "E" .Or. AllTrim(FwModeAccess(cTab,1)) == "E"
				//"A empresa" x "n�o esta usando a tabela" x "compartilhada."
				cMsg := STR0031 + " " + cEmpX + " " + STR0035 + " " + cTab +  " " + STR0036
				If Empty(cMsg)
					//"A empresa" x "n�o esta usando a tabela" x "compartilhada."
					cMsg := STR0031 + " " + cEmpX + " " + STR0035 + " " + cTab +  " " + STR0036
				Else
					//"A empresa" x "n�o esta usando a tabela" x "compartilhada."
					cMsg := CLRF + STR0031 + " " + cEmpX + " " + STR0035 + " " + cTab +  " " + STR0036
				EndIf
				lRet 		:= .F.
				lRetLoop	:= .F.
				aAdd(aTabelas,{cEmpX, cTab, RetSqlName(cTab), .F.})
				aAdd(aGrpEmps,{cEmpX, .F.})
			EndIf
		Else
			If Empty(cMsg)
				//"A empresa" x "n�o possui tabela" x ". Atualize o dicion�rio."
				cMsg := STR0031 + " " + cEmpX + " " + STR0037 + " " + cTab +  ". " + STR0038
			Else
				//"A empresa" x "n�o possui tabela" x ". Atualize o dicion�rio."
				cMsg := CLRF + STR0031 + " " + cEmpX + " " + STR0037 + " " + cTab +  ". " + STR0038
			EndIf
			lRet 		:= .F.
			lRetLoop	:= .F.
			aAdd(aTabelas,{cEmpX, cTab, RetSqlName(cTab), .F.})
			aAdd(aGrpEmps,{cEmpX, .F.})
		EndIf

		If lRetLoop .AND. cEmpPai != cEmpX
			nIndTabPai	:= aScan(aTabelas,{|x| x[1] == cEmpPai	.AND. x[2] == cTab})
			If nIndTabPai == 0
				lRet 		:= .F.
				lRetLoop	:= .F.
				If !Empty(cMsg)
					cMsg 	+= " " + CLRF + ""
				ElseIf cMsg == Nil
					cMsg	:= ""
				EndIf

				//"Falha no modo de compartilhamento de tabelas entre a Empresa Centralizada 'cEmp1' e a Centralizadora 'cEmp2'. "
				cMsg 	+= StrTran(StrTran(STR0083	, "cEmp1", cEmpX), "cEmp2", cEmpPai)

				aAdd(aTabelas,{cEmpX, cTab, RetSqlName(cTab), .F.})
				aAdd(aGrpEmps,{cEmpX, .F.})

			ElseIf aTabelas[nIndTabPai][3] != RetSqlName(cTab)
				lRet 		:= .F.
				lRetLoop	:= .F.
				If !Empty(cMsg)
					cMsg 	+= " " + CLRF + ""
				ElseIf cMsg == Nil
					cMsg	:= ""
				EndIf

				//"Falha no modo de compartilhamento de tabelas entre a Empresa Centralizada 'cEmp1' e a Centralizadora 'cEmp2'. "
				cMsg 	+= StrTran(StrTran(STR0083	, "cEmp1", cEmpX), "cEmp2", cEmpPai)
				cMsg	+=  + "': " + RetSqlName(cTab) + " | " + aTabelas[nIndTabPai][3]

				aAdd(aTabelas,{cEmpX, cTab, RetSqlName(cTab), .F.})
				aAdd(aGrpEmps,{cEmpX, .F.})
			EndIf
		EndIf

		If !lRetLoop
			Exit
		Else
			aAdd(aTabelas,{cEmpX, cTab, RetSqlName(cTab), .T.})
		EndIf

	Next nIndAtual

	If lRet
		aAdd(aGrpEmps,{cEmpX, .T.})
	EndIf

	If lPrepAmb
		PutGlbVars("JOBTAB", aTabelas, aGrpEmps, lRet, cMsg)
		RESET ENVIRONMENT
	EndIf

Return lRet

//------------------------------------------------------------
//Monta array com informa��o de empresa removendo as repetidas
//------------------------------------------------------------
Static Function GetDistEmp(aEmpresas)
	Local nI, nJ
	Local lAchou
	Local aEmp := {}

	For nI := 1 To Len(aEmpresas)
		lAchou := .F.
		If !Empty(aEmpresas[nI][2])
			For nJ := 1 To Len(aEmp)
				If AllTrim(aEmp[nJ][1]) == AllTrim(aEmpresas[nI][2])
					lAchou := .T.
					Exit
				EndIf
			Next

			If !lAchou
				aAdd(aEmp,{"",aEmpresas[nI][2],aEmpresas[nI][3]})
			EndIf
		EndIf
	Next
Return aEmp

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} PCPA106ZOM
Fun��o de zoom (F3) para o campo Empresa deste programa.

@author Lucas Konrad Fran�a
@since 09/07/2015
@version P12
/*/
/*-------------------------------------------------------------------*/
Function PCPA106ZOM()
	Local aReturn := {}

	If type('nOpcao') == "U"
		MSGINFO(STR0068,"") //Consulta indispon�vel.
		Return .F.
	EndIf

	If nOpcao == 3
		aReturn := DialogEmp()
		If aReturn[1]
			If !aReturn[2]
				//STR0072 - Opera��o n�o permitida! | STR0042 - Empresa j� cadastrada como empresa centralizada"
				Help(NIL, NIL, STR0072, NIL, STR0042, 1, 0, NIL, NIL, NIL, NIL, NIL)
			EndIf
		Else
			//STR0072 - Opera��o n�o permitida! | STR0007 - J� existe um registro com essa empresa/filial.
			Help(NIL, NIL, STR0072, NIL, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL)
		EndIf
	EndIf
Return .T.

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} PCPA106DEN
Retorna a descri��o dos campos para exibi��o em tela.

@param cCampo -> Campo que ir� receber a descri��o

@author Lucas Konrad Fran�a
@since 13/07/2015
@version P12
/*/
/*-------------------------------------------------------------------*/
Function PCPA106DEN(cCampo)
	Local cDescricao := ""
	Local nTamEmp  := 0
	Local nTamUnid := 0
	Local nTamFil  := 0
	Local nX       := 0
	Local cLayout  := ""

	If !Empty(SOO->OO_CDEPCZ)
		cLayout := FWSM0Layout(SOO->OO_CDEPCZ)
	EndIf

	nTamEmp  := 0
	nTamUnid := 0
	nTamFil  := 0
	For nX := 1 To Len(cLayout)
		If SubStr(cLayout,nX,1) == "E"
			nTamEmp++
		ElseIf SubStr(cLayout,nX,1) == "U"
			nTamUnid++
		ElseIf SubStr(cLayout,nX,1) == "F"
			nTamFil++
		EndIf
	Next nX

	Do Case
		Case AllTrim(cCampo) == "OO_DSEPCZ"
		If !Empty(SOO->OO_CDEPCZ)
			cDescricao := FWGrpName(SOO->OO_CDEPCZ)
		EndIf
		Case AllTrim(cCampo) == "OO_DSEMPR"
		If !Empty(SOO->OO_CDEPCZ) .And. !Empty(SOO->OO_EMPRCZ)
			cDescricao := FWCompanyName(SOO->OO_CDEPCZ,PadR(SOO->OO_EMPRCZ,nTamEmp))
		EndIf
		Case AllTrim(cCampo) == "OO_DSUNID"
		If !Empty(SOO->OO_CDEPCZ) .And. !Empty(SOO->OO_EMPRCZ) .And. !Empty(SOO->OO_UNIDCZ)
			cDescricao := FWUnitName(SOO->OO_CDEPCZ,;
			PadR(SOO->OO_EMPRCZ,nTamEmp)+;
			PadR(SOO->OO_UNIDCZ,nTamUnid))
		EndIf
		Case AllTrim(cCampo) == "OO_DSESCZ"
		If (lGestEmp .And. !Empty(SOO->OO_CDEPCZ) .And. !Empty(SOO->OO_EMPRCZ) .And. !Empty(SOO->OO_UNIDCZ) .And. !Empty(SOO->OO_CDESCZ)) .Or. ;
		(!lGestEmp .And. !Empty(SOO->OO_CDEPCZ) .And. !Empty(SOO->OO_CDESCZ))
			IF lGestEmp
				cDescricao := FWFilialName(SOO->OO_CDEPCZ,;
				PadR(SOO->OO_EMPRCZ,nTamEmp)+;
				PadR(SOO->OO_UNIDCZ,nTamUnid)+;
				PadR(SOO->OO_CDESCZ,nTamFil))
			Else
				cDescricao := FWFilialName(SOO->OO_CDEPCZ,SOO->OO_CDESCZ)
			EndIf
		EndIf
	End Case

Return cDescricao

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} PCPA106TES
Exibe tela de manuten��o dos campos OO_TS e OO_TE

@param nOpc -> A��o que est� sendo realizada.

@author Lucas Konrad Fran�a
@since 13/07/2015
@version P12
/*/
/*-------------------------------------------------------------------*/
Function PCPA106TES(nOpc)
	Local oDlgTes, oTesEntr, oTesSaid
	Local nI         := 0
	Local lDifGrup   := .F.
	Local cGrupBkp   := ""
	Local nWidthTela := 0
	Local nPosBtnCnl := 0
	Local nPosBtnOk  := 0

	Private cTesSaid := ""
	Private cTesEntr := ""

	Default lAutoMacao := .F.

	If nOpc == 2
		cTesSaid := SOO->OO_TS
		cTesEntr := SOO->OO_TE
	Else
		cTesSaid := M->OO_TS
		cTesEntr := M->OO_TE
	EndIf

	For nI := 1 To Len(aTempSelec)
		If !lDifGrup .And. (AllTrim(cGrupBkp) != AllTrim(aTempSelec[nI][2]) .Or. AllTrim(aTempSelec[nI][2]) != AllTrim(M->OO_CDEPCZ) )
			If nI == 1 .And. AllTrim(aTempSelec[nI][2]) == AllTrim(M->OO_CDEPCZ)
				cGrupBkp := aTempSelec[nI][2]
			Else
				lDifGrup := .T.
			EndIf
		EndIf
	Next nI

	If nOpc != 3 .And. nOpc != 4
		lDifGrup := .T.
	EndIf

	If lDifGrup
		nWidthTela := 180
		nPosBtnOk  := 24
		nPosBtnCnl := 54
	Else
		nWidthTela := 250
		nPosBtnOk  := 66
		nPosBtnCnl := 96
	EndIf

	IF !lAutoMacao
		DEFINE MSDIALOG oDlgTes TITLE STR0048 FROM 0,0 TO 95,nWidthTela PIXEL //"TES Entrada/Sa�da"

		@ 05,05 Say STR0047 Of oDlgTes Pixel //"TES Entrada:"
		@ 03,41 MSGET oTesEntr VAR cTesEntr SIZE 40,8 OF oDlgTes PIXEL NO BORDER F3 "SF4" VALID valTes(cTesEntr,"E") WHEN (nOpc == 3 .Or. nOpc == 4) PICTURE "@!"
		If !lDifGrup
			@ 03,85 BUTTON STR0045/*"Validar"*/ SIZE 37,10 PIXEL OF oDlgTes ACTION validTes("E")
		EndIf

		@ 18,05 Say STR0046 Of oDlgTes Pixel //"TES Saida:"
		@ 16,41 MSGET oTesSaid VAR cTesSaid SIZE 40,8 OF oDlgTes PIXEL NO BORDER F3 "SF4" VALID valTes(cTesSaid,"S") WHEN (nOpc == 3 .Or. nOpc == 4) PICTURE "@!"
		If !lDifGrup
			@ 16,85 BUTTON STR0045/*"Validar"*/ SIZE 37,10 PIXEL OF oDlgTes ACTION validTes("S")
		EndIf

		DEFINE SBUTTON FROM 30,nPosBtnOk  TYPE 1 ACTION (confirmTes(cTesEntr,cTesSaid,oDlgTes,nOpc)) ENABLE OF oDlgTes
		DEFINE SBUTTON FROM 30,nPosBtnCnl TYPE 2 ACTION (oDlgTes:End()) ENABLE OF oDlgTes

		ACTIVATE DIALOG oDlgTes CENTERED
	ENDIF

Return Nil

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} valTes
Faz a valida��o do campo TES

@param cTes -> C�digo do TES
@param cOperacao -> TES 'E'ntrada ou 'S'aida

@author Lucas Konrad Fran�a
@since 13/07/2015
@version P12
/*/
/*-------------------------------------------------------------------*/
Static Function valTes(cTes,cOperacao)
	Local lRet := .T.
	If !Empty(cTes)
		If !ExistCPO("SF4",cTes)
			lRet := .F.
		EndIf
		If lRet
			If !MaAvalTes(cOperacao,cTes)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		If cOperacao == "E"
			M->OO_TE := cTes
		Else
			M->OO_TS := cTes
		EndIf
	EndIf
Return lRet

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} confirmTes
Faz a confirma��o do campo TES

@param cTes -> C�digo do TES
@param cOperacao -> TES 'E'ntrada ou 'S'aida

@author Lucas Konrad Fran�a
@since 13/07/2015
@version P12
/*/
/*-------------------------------------------------------------------*/
Static Function confirmTes(cTesE,cTesS,oDlgTes,nOpc)
Default lAutoMacao := .F.

	If nOpc == 3 .Or. nOpc == 4
		If !valTes(cTesE,"E")
			Return .F.
		EndIf
		If !valTes(cTesS,"S")
			Return .F.
		EndIf
		M->OO_TS := cTesS
		M->OO_TE := cTesE
	EndIf
	IF !lAutoMacao
		oDlgTes:End()
	ENDIF
Return .T.

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} delTabMrp
Limpa as tabelas de processamento do MRP

@author Lucas Konrad Fran�a
@since 27/07/2016
@version P12
/*/
/*-------------------------------------------------------------------*/
Function PCP106DMRP()
	Local cDelete := ""

	If MSGYESNO(STR0065, STR0066) //"Deseja excluir todos os registros do processamento do MRP?" # "Aten��o"
		cDelete := " DELETE FROM "+RetSqlName("SOQ")
		cDelete += " WHERE OQ_FILIAL = '"+xFilial("SOQ")+"' "
		TCSQLExec(cDelete)

		cDelete := " DELETE FROM "+RetSqlName("SOR")
		cDelete += " WHERE OR_FILIAL = '"+xFilial("SOR")+"' "
		TCSQLExec(cDelete)

		cDelete := " DELETE FROM "+RetSqlName("SOS")
		cDelete += " WHERE OS_FILIAL = '"+xFilial("SOS")+"' "
		TCSQLExec(cDelete)

		cDelete := " DELETE FROM "+RetSqlName("SOT")
		cDelete += " WHERE OT_FILIAL = '"+xFilial("SOT")+"' "
		TCSQLExec(cDelete)

		cDelete := " DELETE FROM "+RetSqlName("SOV")
		cDelete += " WHERE OV_FILIAL = '"+xFilial("SOV")+"' "
		TCSQLExec(cDelete)

		MSGINFO(STR0064,"") //"Exclus�o efetuada com sucesso"
	EndIf

Return .T.

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} PCP106CMPS
Retorna os campos que dever�o ser exibidos

@author Samantha Preima
@since 17/01/2017
@version P12
/*/
/*-------------------------------------------------------------------*/
Static Function PCP106CMPS()
	Local aCampos := {}
	Local StructSOO := FWFormStruct(3,'SOO')
	Local nCount := 0
	Local cCampo

	For nCount := 1 to Len(StructSOO[3])

		cCampo := StructSOO[3,nCount,1]

		If (!lGestEmp .And. !AllTrim(cCampo) $ "OO_EMPRCZ|OO_UNIDCZ|OO_TS|OO_TE|OO_DSEMPR|OO_DSUNID") .Or. (lGestEmp .And. !AllTrim(cCampo) $ "OO_TS|OO_TE")
			aAdd(aCampos,ALLTRIM(cCampo))
		EndIf

	Next nCount

Return aCampos

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} GetObjLeg
Retorna objeto de legenda
@author brunno.costa
@since 23/10/2018
@version P12
/*/
/*-------------------------------------------------------------------*/
Static Function GetObjLeg(nOpc, aArray, nItem)

	Local oReturn

	If 	nOpc == 1 		//Array Dispon�veis - COM Gest�o de Empresas
		oReturn	:= aArray[nItem,11]

	ElseIf nOpc == 2 	//Array Dispon�veis - SEM Gest�o de Empresas
		oReturn	:= aArray[nItem,7]

	ElseIf nOpc == 3 	//Array Selecionados - COM Gest�o de Empresas
		oReturn	:= aArray[nItem,11]

	Else				//Array Selecionados - COM Gest�o de Empresas
		oReturn	:= aArray[nItem,7]
	EndIf

	If ValType(oReturn) == "C"
		If AllTrim(oReturn) == "BR_VERDE"
			oReturn := oBRVerd
		Else
			oReturn := oBRVerm
		EndIf
	End

	//Valida se � a Empresa Centralizadora
	If lGestEmp .AND. AllTrim(M->OO_CDEPCZ)+AllTrim(M->OO_EMPRCZ)+AllTrim(M->OO_UNIDCZ)+AllTrim(M->OO_CDESCZ)	== AllTrim(aArray[nItem][2])+AllTrim(aArray[nItem][4])+AllTrim(aArray[nItem][6])+AllTrim(aArray[nItem][8])
		oReturn	:= oBRAmar

	ElseIf !lGestEmp .AND. AllTrim(M->OO_CDEPCZ)+AllTrim(M->OO_CDESCZ) == AllTrim(aArray[nItem][2])+AllTrim(aArray[nItem][3])
		oReturn	:= oBRAmar
	EndIf

Return oReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} TravaThrd
Cria Registro de Trava para Impedir Reiniciar a cria��o da saSM0Emp
enquanto o processo inicial n�o finalizar
@author brunno.costa
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TravaThrd(lReserva, lLimpa)

	Local lRet	:=	TravaThrdG(lReserva, lLimpa)
	//Local lRet	:=	TravaThrdP(lReserva, lLimpa)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TravaThrdG
Cria Registro de Trava para Impedir Reiniciar a cria��o da saSM0Emp
enquanto o processo inicial n�o finalizar (Lock vari�vel global)
@author brunno.costa
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TravaThrdG(lReserva, lLimpa)

	Local lRet			:=	.T.
	Local lCheca		:= 	.T.
	Local lReservado

	DEFAULT lReserva	:= .F.
	DEFAULT lLimpa	:= .F.

	lCheca	:= !lReserva .AND. !lLimpa

	If lCheca

		GetGlbVars("PCPA106"+cValToChar(snThread),@lReservado)
		lRet	:= Iif(ValType(lReservado)=="L",lReservado,.F.)

	ElseIf lReserva

		PutGlbVars("PCPA106"+cValToChar(snThread),.T.)

	ElseIf lLimpa

		PutGlbVars("PCPA106"+cValToChar(snThread),.F.)

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TravaThrdG
Cria Registro de Trava para Impedir Reiniciar a cria��o da saSM0Emp
enquanto o processo inicial n�o finalizar (Lock arquivo profile)
-> Mantida no fonte para facilitar testes
@author brunno.costa
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function TravaThrdP(lReserva, lLimpa)

	Local cWrite		:= 	""
	Local cBarra		:= 	If ( IsSrvUnix () , "/" , "\" )
	Local lRet			:=	.T.
	Local lCheca		:= 	.T.

	DEFAULT lReserva	:= .F.
	DEFAULT lLimpa	:= .F.

	lCheca	:= !lReserva .AND. !lLimpa

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf

	If lCheca
		lRet	:= File ( cBarra + "PROFILE" + cBarra + "PCPA106_"+cValToChar(snThread)+".PRB" )

	ElseIf lReserva

		If !File ( cBarra + "PROFILE" + cBarra + "PCPA106_"+cValToChar(snThread)+".PRB" )
			cWrite 	:= "D"+DtoC(Date())
			lRet	:= MemoWrit( cBarra + "PROFILE" + cBarra + "PCPA106_"+cValToChar(snThread)+".PRB" , cWrite )
		EndIf

	ElseIf lLimpa

		If File ( cBarra + "PROFILE" + cBarra + "PCPA106_"+cValToChar(snThread)+".PRB" )
			lRet	:= FERASE(cBarra + "PROFILE" + cBarra + "PCPA106_"+cValToChar(snThread)+".PRB") == 0
		EndIf

	EndIf

Return lRet
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} a106Legend
Apresenta janela de legendas
@author brunno.costa
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function a106Legend()
	Local aCores	:= {}
	Aadd( aCores , { "BR_VERDE"		, STR0084 } )	//"Permite v�nculo com a Empresa Centralizadora"
	Aadd( aCores , { "BR_VERMELHO"	, STR0085 } )	//"N�o permite v�nculo com a Empresa Centralizadora"
	Aadd( aCores , { "BR_AMARELO"	, STR0086 } )	//"Empresa Centralizadora"
	BrwLegenda(STR0001, STR0031, aCores)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a106Legend
Retorna as tabelas relacionadas a checagem de compartilhamento
@author brunno.costa
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function fTabCheck(lArray, aTabCheck)
	Local lIntNewMRP := .F.
	Local oReturn

	DEFAULT lArray:= .T.

	If aTabCheck == Nil .OR. Empty(aTabCheck)
		aTabCheck := {"SB1","SGI","SOO","SOP"}
		If Empty(saTabCheck)
			If FindFunction("IntNewMRP")
				lIntNewMRP := IntNewMRP("MRPDEMANDS")
			EndIf

			If !lIntNewMRP
				aAdd(aTabCheck,"SOQ")
				aAdd(aTabCheck,"SOR")
				aAdd(aTabCheck,"SOS")
				aAdd(aTabCheck,"SOT")
				aAdd(aTabCheck,"SOU")
				aAdd(aTabCheck,"SOV")
			EndIf

			saTabCheck	:= aTabCheck
		Else
			aTabCheck	:= saTabCheck
		EndIf
	EndIf

	If lArray
		oReturn	:= aTabCheck
	Else
		oReturn	:= ArrTokStr(aTabCheck,", ",0)
	EndIf

Return oReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} a106Legend
Atualiza os Array's com Legenda Correspondente a Empresa Centralizadora Atual
@author brunno.costa
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function UpdLegenda(aTempDisp, aTempSelec, lVerifTabs)

	Local nIndAux	:= 0
	Local nIndScan	:= 0
	Local cMsg		:= ""

	DEFAULT lVerifTabs	:= .T.

	If lVerifTabs
		If !Empty(saTabelas)
			aSize(saTabelas,0)
		EndIf

		If !Empty(saGrpEmps)
			aSize(saGrpEmps,0)
		EndIf

		//Add Array's Referente cEmpPai
		VerfAllTab({'', cEmpPai, cFilialPai}, .F., @cMsg)

		For nIndAux	:= 1 to Len(saSM0Emp)
			If !VerfAllTab(@saSM0Emp[nIndAux], .F., @cMsg)
				lError	:= .T.
				saSM0Emp[nIndAux][7]	:= "BR_VERMELHO"
			Else
				saSM0Emp[nIndAux][7]	:= "BR_VERDE"
			EndIf
		Next nIndAux
	EndIf

	For nIndAux	:= 1 to Len(aTempDisp)
		nIndScan	:= aScan(saSM0Emp,{|x| x[2] == aTempDisp[nIndAux][2] })
		If lGestEmp
			If nIndScan > 0
				aTempDisp[nIndAux][11]	:= saSM0Emp[nIndScan][7]
			Else
				aTempDisp[nIndAux][11]	:= "BR_VERMELHO"
			EndIf
		Else
			If nIndScan > 0
				aTempDisp[nIndAux][7]	:= saSM0Emp[nIndScan][7]
			Else
				aTempDisp[nIndAux][7]	:= "BR_VERMELHO"
			EndIf
		EndIf
	Next nIndAux

	For nIndAux	:= 1 to Len(aTempSelec)
		nIndScan	:= aScan(saSM0Emp,{|x| x[2] == aTempSelec[nIndAux][2] })
		If lGestEmp
			If nIndScan > 0
				aTempSelec[nIndAux][11]	:= saSM0Emp[nIndScan][7]
			Else
				aTempSelec[nIndAux][11]	:= "BR_VERMELHO"
			EndIf
		Else
			If nIndScan > 0
				aTempSelec[nIndAux][7]	:= saSM0Emp[nIndScan][7]
			Else
				aTempSelec[nIndAux][7]	:= "BR_VERMELHO"
			EndIf
		EndIf
	Next nIndAux

	cTeste := ""

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a106Legend
Reprocessa SM0 ou aguarda finaliza��o de Thread
@author brunno.costa
@since 25/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function WaitSM0()

	GetGlbVars("JOBGEM",@saSM0Emp,@slError,@scMsg,@saTabelas,@saGrpEmps,@snThread)
	If !TravaThrd(.F., .F.)
		If Empty(saSM0Emp)
			TravaThrd(.T., .F.)
			saSM0Emp := PCPA106GEM(@slError, .F., .T., cEmpPai)
			GetGlbVars("JOBGEM",@saSM0Emp,@slError,@scMsg,@saTabelas,@saGrpEmps,@snThread)
		EndIf
	Else
		//Enquanto Existir Lock
		While TravaThrd(.F., .F.) .OR. Empty(saSM0Emp)
			Sleep(1000)
			If !TravaThrd(.F., .F.)
				GetGlbVars("JOBGEM",@saSM0Emp,@slError,@scMsg,@saTabelas,@saGrpEmps,@snThread)
			EndIf
		EndDo
	EndIf
	ClearGlbValue("JOBGEM")

Return

