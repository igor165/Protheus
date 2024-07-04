#INCLUDE "mnta295.ch"
#Include "Protheus.ch"

Static lFrotas := IIf( FindFunction('MNTFrotas'), MNTFrotas(), GetNewPar('MV_NGMNTFR','N') == 'S' )

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295
Programa de Distribuicao de Solicitacao de Servico e geracao de Ordem de Servico.

@author  Ricardo Dal Ponte
@since   06/12/2006
@version p12
@param cTipoSS, Caractere, Tipo de Solicita��o de Servi�o.
@param cCodBem, Caractere, C�digo do Bem.
/*/
//-------------------------------------------------------------------
Function MNTA295(cTipoSS,cCodBem)

	Local aNGBEGINPRM := {}
	Local _cTRBC295
	Local _cTRBB295

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBEGINPRM := NGBEGINPRM()

		IIf(Type("cTRBC295") == "C",_cTRBC295 := cTRBC295,)
		IIf(Type("cTRBB295") == "C",_cTRBB295 := cTRBB295,)

		//Verifica se o update de facilities foi aplicado
		If FindFunction("MNTUPDFAC") .And. MNTUPDFAC(.F.)
			ShowHelpDlg(STR0143, {STR0145},1,{STR0146}) //"ATEN��O" ## "O sistema est� utilizando o M�dulo Facilities." ## "Ser� redirecionado para a nova rotina de Distribui��o."
			NGRETURNPRM(aNGBEGINPRM)
			MNTA296()
			Return .F.
		EndIf

		Private aRotina := MenuDef()
		Private cCadastro := Oemtoansi(STR0001) // "Distribui��o e Geracao O.S. da Solicitacao Servico"
		Private lCervPetro := .F.
		Private lEnercan   := .F.
		Private aHeader   := {}
		Private cARQUISAI := "XXX"
		Private cPROGRAMA := "MNTA295"
		Private lCORRET  := .T.
		Private TI_PLANO := "000000"
		Private cRetPar  := ''
		Private lSITUACA   := .T.
		Private TIPOACOM := .F.
		Private TIPOACOM2:= .F.
		Private nTAREFA, nETAPA
		Private cTRBB295 := GetNextAlias()
		Private cTRBC295 := GetNextAlias()
		Private cGEROSPR := AllTrim(GETMv("MV_NGGERPR")) // Gera O.S preventivas automaticamente

		If ExistBlock("MNTA2958")
			Private aVarsPE := {}
		EndIf

		If lEnercan
			Private dDatapro := dDataBase
			Private cHora    := Time()
			Private cAprova  := If(Len(TQB->TQB_APROVA) > 15,cUsername,Substr(cUsuario,7,15))
			Private cOBS
			Private cCondicao := ''
		EndIf

		dbSelectArea("TQB")
		dbSetOrder(1)
		//--inicio--SS 027048 #
		// Ponto de Entrada para alterar filtro da filial.
		If ExistBlock("MNTA295C")
			cFilMbrTQB := ExecBlock("MNTA295C",.F.,.F.)
		Else
			cFilMbrTQB := " TQB_FILIAL = '"+xFilial('TQB')+"' And"
		EndIf
		//---fim----SS 027048 #

		cFilMbrTQB += " (TQB_SOLUCA = 'A' Or TQB_SOLUCA = 'D')"

		If ValType(cCodBem) == "C" .And. ValType(cTipoSS) == "C"
			cFilMbrTQB += " And TQB_TIPOSS = "+ValToSql(cTipoSS)
			cFilMbrTQB += " And TQB_CODBEM = "+ValToSql(cCodBem)

			// N�o apresentar a tela para informar a filial
			SetBrwCHGAll(.F.)
		EndIf

		If ExistBlock("MNTA2951")
			cFilMbrTQB += ExecBlock("MNTA2951",.F.,.F.)
		EndIf

		mBrowse(6,1,22,75,"TQB",,,,,,MNTA295COR(),,,,,,,,cFilMbrTQB)

		dbSelectArea("TQB")
		Set Filter To
		dbSetOrder(1)
		dbSeek(xFilial("TQB"))

		// Devolve variaveis das Tabelas Temporarias
		cTRBC295 := _cTRBC295
		cTRBB295 := _cTRBB295

		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295LEG
Filtra para a legenda
@author  Inacio Luiz Kolling
@since   24/11/2003
@version p12
/*/
//-------------------------------------------------------------------
Function MNTA295LEG()
	Local aLegenda := { {"BR_PRETO",STR0155},; // "Prioridade Indefinida"
						{"BR_VERMELHO",STR0004},; // "Prioridade Alta"
						{"BR_AMARELO",STR0005},; // "Prioridade Media"
						{"BR_AZUL",STR0006}} // "Prioridade Baixa"

	If ExistBlock("MNTA2959")
		aLegenPE := aCLONE(aLegenda)
		aLegenPE := ExecBlock("MNTA2959",.F.,.F.)
		aLegenda := aCLONE(aLegenPE)
	EndIf

	BrwLegenda(cCadastro,STR0002,aLegenda) // "Legenda"
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} �MNTA29LEG
Defini��o das cores do sem�faro
@author  Inacio Luiz Kolling
@since   24/11/2003
@version p12
/*/
//-------------------------------------------------------------------
Function MNTA295COR()
	Local aCores := {	{"NGSEMAFARO('Empty(TQB->TQB_PRIORI)')",'BR_PRETO'},;
						{"NGSEMAFARO('TQB->TQB_PRIORI = "+'"1"'+"')",'BR_VERMELHO'},;
						{"NGSEMAFARO('TQB->TQB_PRIORI = "+'"2"'+"')",'BR_AMARELO'},;
						{"NGSEMAFARO('TQB->TQB_PRIORI = "+'"3"'+"')",'BR_AZUL'}}

	If ExistBlock("MNTA2958")
		aVarsPE := {}
		aCoresPE := aClone(aCores)
		aCoresPE := ExecBlock("MNTA2958",.F.,.F.)
		aCores := aClone(aCoresPE)
	EndIf

Return aCores

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295CLA
Distribui��o  da solicita��o de servi�o.
@author  Ricardo Dal Ponte
@since   06/12/2006
@version p12
@param nOpcx, Num�rico, Opera��o:
							2 - Visualiza��o
							3 - Inclus�o
			 				4 - Altera��o
			 				5 - Exclus�o
@param cTitulo, Caractere, Titulo da Solicita��o de Servi�o.
/*/
//-------------------------------------------------------------------
Function MNTA295CLA(nOpcx,cTitulo)

	dbSelectArea("TQB")
	MNTA280IN(nOpcx,2,cTitulo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295GOS
Gera��o de ordem de servi�o para a solicita��o de servi�o

@author  Inacio Luiz Kolling
@since   24/11/2003
@version p12
@param lArvLog, L�gico, define se � da �rvore l�gica.
/*/
//-------------------------------------------------------------------
Function MNTA295GOS(lArvLog)

	Local i, ny, nRECSTJ, nINDSTJ
	Local oQtdItens
	Local oMenu
	Local oDLGA
	Local cSXBCT     	:= ""
	Local cCADAOLD   	:= cCadastro
	Local nQtdItens  	:= 0
	Local aRotinaold 	:= aClone(aRotina)
	Local nX 			:= 0
	Local lMNTA2955 	:= ExistBlock("MNTA2955")
	Local lRPORel17     := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17
	Local oTQB

	Private oSrc
	Private oBEMSOLI
	Private oSERVICO
	Private ocCCUSTOQ
	Private oSTATUS
	Private oEstado
	Private ocCentrab
	Private oCont1
	Private oCont2
	Private oHrCont1
	Private oHrCont2
	Private oHrPar
	Private oDTORIGI
	Private oHORAPRE
	Private oCombSit
	Private oDataPar
	Private oPriorid
	Private oSequen
	Private oNombCus
	Private oNomcTra
	Private oNOMBEMS
	Private oNOMSERV
	Private aGETS[0]
	Private aHeader[0]
	Private dINI, hINI, dDataPar
	Private oScrollBox
	Private cCentra, cNomctra, nCont1, nCont2, cHrCont1, cHrCont2, cHrPar
	Private cF3CTTSI3  := If(CtbInUse(), "CTT", "SI3")
	Private aCHKDEL    := {}
	Private bCampo     := {|nCPO| Field(nCPO) }
	Private cINSPREV   := "P"
	Private cUsaIntPc  := AllTrim(GetMV("MV_NGMNTPC"))
	Private cUsaIntCm  := AllTrim(GetMV("MV_NGMNTCM"))
	Private cUsaIntEs  := AllTrim(GetMV("MV_NGMNTES"))
	Private nCODINS    := 0
	Private nUSACAL    := 0
	Private nDATAIN    := 0
	Private nHORAIN    := 0
	Private lRETORNO   := .F.
	Private nQTDHEA    := 0
	Private nTIPHEA    := 0
	Private aSITUA     := {STR0086,STR0087}
	Private cSITUA     := STR0086  //"Liberada"#"Pendente"
	Private cTpServico := "C"
	Private cSequen    := "0"
	Private lPRIACET   := .T.
	Private cSERVIPRI  := ""
	Private cBEMPRI    := ""
	Private cSEQPRI    := "0"
	Private cTPSERPRI  := "C"
	Private lStop      := .F.
	Private lWhenCC    := .T.//Vari�vel para controle do when do centro de custo (Pode ser alterada a partir do P.E. MNTA2955)
	Private cPriorid   := Space(TamSx3("TJ_PRIORID")[1])  // NAO RETIRAR - Variavel alterada pra private devido a necessidade de utilizacao em P.E.

	//Variaveis utilizadas no NGGERASA
	Private lUSATARG   := If(FindFunction("NGUSATARPAD"),NGUSATARPAD(),.F.)
	Private cPxSeq     := Space(3),cPxQSeq := cPxSeq
	Private nQTETA     := 0,nQTARE := 0

	Private aTrocaF3   := {}

	Private lWhenPrio  := If(TQB->TQB_TIPOSS == "B",.F.,.T.) // When do Campo prioridade. Ser for bem fica desativado.
	Private lBem       := If(TQB->TQB_TIPOSS == "B",.T.,.F.) // Campo que indica se o registro � um bem.

	If !lRPORel17
		// Classe de S.S.
		oTQB := MntSR():New()

		// Determina que a op��o selecionada ser� Altera��o
		oTQB:setOperation(4)

		//N�o apresenta mensagens condicionais
		oTQB:setAsk(.F.)

		// Busca a chave da tabela de S.S.
		oTQB:Load( { xFilial("TQB") + TQB->TQB_SOLICI } )
	EndIf

	If Type("lCervPetro") <> "L"
		lCervPetro := .F.
		lEnercan   := .F.
	EndIf

	dbSelectArea( "SXB" )
	dbSetOrder( 01 )
	If dbSeek( Padr("SHBA",Len(SXB->XB_ALIAS)) )
		cSXBCT := 'SHBA'
	Else
		cSXBCT := 'SHB'
	EndIf

	lArvLog := If(ValType(lArvLog)=="L",lArvLog,.F.)

	M->TQB_CODBEM := TQB->TQB_CODBEM
	NG280BEMLOC(TQB->TQB_TIPOSS)

	If TQB->TQB_TIPOSS == "B" .And. !NGIFDBSEEK("SH7",NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CALENDA"),1)
		Help(" ",1,"NGCALENBEM",,CHR(13) + OemToAnsi(STR0123) + NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CALENDA") ,3,0)  //"Calend�rio: "
		Return .F.
	EndIf

	If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S"
		aRotina := {{STR0041,""          ,0,1,0},; //"Pesquisar"
					{STR0042,"MNA295VOS" ,0,2,0},; //"Visualizar"
					{STR0109,"MNTA295GOS",0,3,0},; //"Incluir"
					{STR0068,""          ,0,4,0},; //"Alterar"
					{STR0110," "         ,0,5,0}}  //"Excluir"
	EndIf

	cSERVICO := Space(Len(st4->t4_servico))
	cNOMSERV := Space(40)
	dDTORIGI := dDataBase
	cHORAPRE := Substr(time(),1,5)
	nCont1	 := 0
	nCont2	 := 0
	cHrCont1 := Space( 5 )
	cHrCont2 := Space( 5 )
	cHrPar	 := Space( 5 )
	dDataPar := Ctod("  /  /  ")

	If lEnercan
		Private cESTADO  := Space(02)
		Private cNOMESTADO := Space(40)
	EndIf

	If TQB->TQB_SOLUCA <> "D"
		MsgInfo(STR0007, STR0008) //"A Solicita��o de Servi�o n�o est� distribu�da!"###"NAO CONFORMIDADE"
		Return
	EndIf

	If Empty(TQB->TQB_SOLICI)
		Help(" ",1,"ARQVAZIO")
		Return
	EndIf

	If AllTrim(GetNewPar("MV_NGMULOS","N")) <> "S"
		If !Empty(TQB->TQB_ORDEM)
			MsgInfo(STR0009+".."+chr(13)+chr(10)+chr(13)+chr(10);        //"Ja foi gerada ordem de servico para a solicitacao"
			+STR0010+"...: "+tqb->tqb_solici+chr(13)+chr(10); //"Solicitacao de Servico"
			+STR0011+"..........: "+tqb->tqb_ordem,STR0008) //"Ordem de Servico"###"NAO CONFORMIDADE"
			Return
		EndIf
	EndIf

	//Ponto de entrada para permitir o usuario carregar
	// servico automaticamente
	If ExistBlock( 'MNTA2954' )
		ExecBlock( 'MNTA2954', .F., .F. )
	EndIf

	SetKey(VK_F11,{||NGTAFMNT3()})

	dbSelectArea("STL")
	For i := 1 To FCount()
		M->&(EVAL(bCampo,i)) := &(EVAL(bCampo,i))
		If ValType(M->&(EVAL(bCampo,i))) == "C"
			M->&(EVAL(bCampo,i)) := Space(Len(M->&(EVAL(bCampo,i))))
		ElseIf ValType(M->&(EVAL(bCampo,i))) == "N"
			M->&(EVAL(bCampo,i)) := 0
		ElseIf ValType(M->&(EVAL(bCampo,i))) == "D"
			M->&(EVAL(bCampo,i)) := cTod("  /  /  ")
		ElseIf ValType(M->&(EVAL(bCampo,i))) == "L"
			M->&(EVAL(bCampo,i)) := .F.
		EndIf
	Next i

	dbSelectArea("STQ")
	dbSetOrder(3)
	For i := 1 To FCount()
		M->&(EVAL(bCampo,i)) := &(EVAL(bCampo,i))
		If ValType(M->&(EVAL(bCampo,i))) == "C"
			M->&(EVAL(bCampo,i)) := Space(Len(M->&(EVAL(bCampo,i))))
		ElseIf ValType(M->&(EVAL(bCampo,i))) == "N"
			M->&(EVAL(bCampo,i)) := 0
		ElseIf ValType(M->&(EVAL(bCampo,i))) == "D"
			M->&(EVAL(bCampo,i)) := cTod("  /  /  ")
		ElseIf ValType(M->&(EVAL(bCampo,i))) == "L"
			M->&(EVAL(bCampo,i)) := .F.
		EndIf
	Next i

	M->TJ_ORDEM   := CriaVar("TJ_ORDEM")

	//Tratamento para evitar duplica��o de n�mero de O.S. em base
	dbSelectArea("STJ")
	dbSetOrder(1)

	If dbSeek(xFilial("STJ") + M->TJ_ORDEM)
		ConfirmSx8()
		M->TJ_ORDEM := GETSXENUM("STJ","TJ_ORDEM")
	EndIf

	M->TJ_PLANO   := CriaVar("TJ_PLANO")
	M->TL_SEQRELA := "0  "
	M->TL_TAREFA  := "0     "
	nSEQUENC      := "0  "

	aHEAINS := {}
	aHEAETA := {}
	aGETINS := {}
	aGETETA := {}
	aDATINS := {}

	NG295ININS()
	NG295INETA()

	dINI := dDataBase
	hINI := SubStr( Time(),1,5)

	dbSelectArea("TQB")
	cSOLICIT := TQB->TQB_SOLICI
	dSOLIDAB := TQB->TQB_DTABER
	cSOLIHOR := TQB->TQB_HOABER
	cBEMSOLI := TQB->TQB_CODBEM
	cCCUSTOQ := Space(Len(TQB->TQB_CCUSTO))
	cTIPOSS  := TQB->TQB_TIPOSS
	cCentra  := Space(TAMSX3('TQB_CENTRA' )[1] )
	cNomctra := Space(TAMSX3("HB_NOME")[1])

	If lCervPetro
		cStatus    := Space(02)
		cDesStatus := Space(40)
		cNomeManut := TQB->TQB_NOMEMA
	EndIf

	cNOMBEMS := If(cTIPOSS = "B",NGSEEK("ST9",cBEMSOLI,1,"T9_NOME"),NGSEEK("TAF","X2"+Substr(cBEMSOLI,1,3),7,"TAF_NOMNIV"))
	cNOMBCUS := NGSEEK("CTT",cCCUSTOQ,1,"CTT_DESC01")
	cBEMPRI  := cBEMSOLI

	dbSelectArea("TQB")
	cOBSTQB  := MSMM(TQB->TQB_CODMSS,80)
	cTIPOSSM := If(cTIPOSS = "B",STR0012,STR0013) //"Bem"###"Localizacao"

	vVetMvP  := NGSALVAMVPA()

	nOPCA := 0
	DEFINE MSDIALOG oDLGA TITLE OemToAnsi(STR0014) From 00,00 To 30,79 OF oMainWnd COLOR CLR_BLACK,CLR_WHITE //"Geracao de Ordem de Servico"

		oPnl11 := TPanel():New(0,0,,oDLGA,,,,,,0,0,.F.,.F.)
		oPnl11:Align := CONTROL_ALIGN_ALLCLIENT

			oScrollBox := TScrollBox():new(oPnl11,00,00,0,0,.T.,.F.,.T.)
			oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

		oPnl01 := TPanel():New(0,0,,oScrollBox,,,,,,,,.F.,.F.)
		oPnl01:Align := CONTROL_ALIGN_ALLCLIENT

			@ 0.4,1  SAY OemToAnsi(STR0015) Of oPnl01 //"Solicitacao"
			@ 0.4,6  MSGET cSOLICIT Picture '@!' SIZE 20,7 When .F. Of oPnl01

			@ 0.4,10 SAY OemToAnsi(STR0016) Of oPnl01 //"Dt. Abertura"
			@ 0.4,15 MSGET dSOLIDAB Picture '99/99/99' SIZE 43,7 When .F. Of oPnl01 HASBUTTON

			@ 0.4,22 SAY OemToAnsi(STR0017) Of oPnl01 //"Hor. Abertura"
			@ 0.4,27 MSGET cSOLIHOR Picture '99:99' SIZE 20,7 When .F. Of oPnl01

			@ 1.4,1  SAY OemToAnsi(STR0018) Of oPnl01 //"Tipo S.S."
			@ 1.4,6  MSGET cTIPOSSM Picture '@!' SIZE 45,7 When .F. Of oPnl01

		If lMNTA2955
			oPnl02 := TPanel():New(200,0,,oScrollBox,,,,,,,,.F.,.F.)
			ExecBlock("MNTA2955",.F.,.F.,{@oPnl02})
			oPnl02:Refresh()
		EndIf

		@ 2.4,1  SAY OemToAnsi(STR0045) COLOR CLR_HBLUE Of oPnl01 //"Bem/Localiz."
		@ 2.4,6  MSGET oBEMSOLI VAR cBEMSOLI Picture '@!' SIZE 80,7  F3 "ST9" Valid NG295BEMLOC(cTIPOSS,oDLGA) Of oPnl01 HASBUTTON
		@ 2.4,18 MSGET oNOMBEMS VAR cNOMBEMS Picture '@!' SIZE 150,7 When .F. Of oPnl01

		@ 3.4,1  SAY OemToAnsi(STR0019) COLOR CLR_HBLUE Of oPnl01 //"Centro Custo"
		@ 3.4,6  MSGET ocCCUSTOQ VAR cCCUSTOQ Picture '@!' SIZE  80,7 Picture "!@" F3 cF3CTTSI3 ;
		Valid (NaoVazio() .And. ExistCpo(cF3CTTSI3,cCCUSTOQ) .And. MNTA295CC() .And. CTB105CC()) When MNT295WHEN() Of oPnl01 HASBUTTON
		@ 3.4,18 MSGET oNombCus var cNOMBCUS Picture '@!' SIZE 150,7 When .F. Of oPnl01

		@ 4.4,1  SAY OemToAnsi(STR0131) Of oPnl01 //"Centro de Trabalho"
		@ 4.4,6  MSGET ocCentrab VAR cCentra Picture '@!' SIZE 80,7 F3 cSXBCT Valid MNTA295CT() Of oPnl01 HASBUTTON
		@ 4.4,18 MSGET oNomcTra var cNomctra When .F. SIZE 150,7 Of oPnl01

		@ 5.4,1  SAY OemToAnsi(STR0020) COLOR CLR_HBLUE Of oPnl01 //"Servico"
		@ 5.4,6  MSGET oSERVICO VAR cSERVICO Picture '@!' SIZE 80,7 F3 "ST4" Valid MNTA295SER() Of oPnl01 HASBUTTON
		@ 5.4,18 MSGET oNOMSERV VAR cNOMSERV When .F. SIZE 150,7 Of oPnl01

		@ 6.4,1  SAY OemToAnsi(STR0090) COLOR CLR_HBLUE Of oPnl01  //"Sequencia"
		@ 6.4,6  MSGET oSequen Var cSequen When .F. Size 10,7 Of oPnl01

		@ 6.4,8.5  SAY OemToAnsi(STR0021) COLOR CLR_HBLUE Of oPnl01  //"Data Orig."
		@ 6.4,12 MSGET oDTORIGI Var dDTORIGI Picture '99/99/99' SIZE 43,7 Valid MNTA295DTO() Of oPnl01 HASBUTTON

		@ 6.4,18 SAY OemToAnsi( STR0022 ) COLOR CLR_HBLUE Of oPnl01  // Hr Prev.
		@ 6.4,23 MSGET oHORAPRE Var cHORAPRE Picture "99:99" SIZE 7,7 Valid MNTA295HOS() Of oPnl01

		@ 6.4,27.5 SAY OemToAnsi( STR0085 ) COLOR CLR_HBLUE Of oPnl01  // Situa��o
		@ 6.4,31.5 COMBOBOX oCombSit Var cSITUA ITEMS aSITUA Of oPnl01

		@ 7.4,1 Say OemToAnsi(STR0133) Of oPnl01 //"Contador"
		@ 7.4,6 MsGet oCont1 Var nCont1 Picture '@E 999999999' Size 80,7 When MntWhenCont( 1 ) Valid MntaValCont() Of oPnl01

		@ 7.4,18 Say OemToAnsi(STR0134) Of oPnl01 //"Hora cont. 1"
		@ 7.4,23 MsGet oHrCont1 Var cHrCont1 Picture '99:99' Size 7,7  When MntWhenCont( 1 ) Valid NGVALHORA(cHrCont1,.T.) Of oPnl01

		@ 8.4,1 Say OemToAnsi(STR0135) Of oPnl01 //"2. Contador"
		@ 8.4,6 MsGet oCont2 Var nCont2 Picture '@E 999999999' Size 80,7  When MntWhenCont( 2 ) Valid MntaValCont() Of oPnl01

		@ 8.4,18 Say OemToAnsi(STR0136) Of oPnl01 //"Hora cont. 2"
		@ 8.4,23 MsGet oHrCont2 Var cHrCont2 Picture '99:99' Size 7,7 When MntWhenCont( 2 ) Valid NGVALHORA(cHrCont2,.T.) Of oPnl01

		@ 9.4,1  SAY OemToAnsi(STR0111) Of oPnl01 //"Prioridade"

		@ 9.4,18 Say OemToAnsi(STR0137) Of oPnl01 //"Dt.Par.Re.I"
		@ 9.4,23 MsGet oDataPar Var dDataPar Picture '99/99/99' Size 43,7  When Mnta295Wpar() Valid Mnta295HoDt() Of oPnl01 HASBUTTON

		@ 9.4,29 Say OemToAnsi( STR0138 ) Of oPnl01 // Ho.Par.Re.I
		@ 9.4,33 MsGet oHrPar Var cHrPar Picture '99:99' Size 6,7 When Mnta295Wpar() Valid Mnta295HoDt() .And. NGVALHORA(cHrPar,.T.) Of oPnl01

		If EMPTY(cItems := NGRETSX3BOX("TJ_PRIORID"))
			@ 9.4,6  MSGET oPriorid VAR cPriorid Picture '@!' SIZE 20,7 When lWhenPrio Of oPnl01
		Else
			aItens := StrTokArr(cItems,";")
			aAdd(aItens," ")
			@ 9.4,6 COMBOBOX oPriorid Var cPriorid ITEMS aItens SIZE 40,7 When lWhenPrio Of oPnl01
		EndIf

		dbSelectArea("STJ")
		If FieldPos("TJ_QTDITEM") > 0
			@ 9.4,11  SAY OemToAnsi(STR0112) Of oPnl01 //"Qtde Itens"
			@ 9.4,15  MSGET oQtdItens VAR nQtdItens Picture '@E 999,999' SIZE 40,7 Of oPnl01
		EndIf

		oPnlBotoes := TPanel():New(0,0,,oPnl11,,,,,,0,20,.F.,.F.)
		oPnlBotoes:align := CONTROL_ALIGN_BOTTOM

			If lCervPetro
				@ 9.4,1  SAY OemToAnsi(STR0063) COLOR CLR_HBLUE Of oPnl01 //"Status
				@ 9.4,6  MSGET oSTATUS VAR cStatus Picture '@!' SIZE 30,7  F3 "TRD" Valid ExistCpo('TRD',cStatus) .AND. MNTA295STS() Of oPnl01 HASBUTTON
				@ 9.4,14 MSGET cDesStatus Picture '@!' SIZE 150,7 When .F. Of oPnl01

				@ 10.4,1  SAY OemToAnsi(STR0020+" /") Of oPnl01 //"Servico"
				@ 10.9,1  SAY OemToAnsi(STR0023) Of oPnl01 //"Observacao"
				@ 128,48 GET oOBSTQB VAR cOBSTQB MULTILINE SIZE 212,33 PIXEL Of oPnl01

				@ 3.5,220 Button STR0046 Size 38,12 Pixel Action NG295INSU() Of oPnlBotoes  //"&Insumos"
				lStop := .F.
				@ 3.5,262 Button STR0047 Size 38,12 Pixel Action NG295ETAPA() Of oPnlBotoes //"&Etapas"

			Elseif lEnercan
				@ 9.4,1  SAY OemToAnsi(STR0064) Of oPnl01 //"Estado Oper."
				@ 9.4,6  MSGET oEstado VAR cESTADO Picture '@!' SIZE  35,7 F3 "ZZJ" Valid ExistCpo("ZZJ",cESTADO) .AND. U_MNT295DE() Of oPnl01 HASBUTTON
				@ 9.4,14 MSGET cNOMESTADO Picture '@!' SIZE 150,7 When .F. Of oPnl01

				@ 10.4,1  SAY OemToAnsi(STR0020+" /") Of oPnl01 //"Servico"
				@ 10.9,1  SAY OemToAnsi(STR0023) Of oPnl01 //"Observacao"
				@ 139,40 GET oOBSTQB VAR cOBSTQB MULTILINE SIZE 200,33 PIXEL Of oPnl01
			Else
				@ 11.4,1  SAY OemToAnsi(STR0020+" /") Of oPnl01 //"Servico"
				@ 11.9,1  SAY OemToAnsi(STR0023) Of oPnl01 //"Observacao"
				@ 139,48 GET oOBSTQB VAR cOBSTQB MULTILINE SIZE 212,33 PIXEL Of oPnl01

				@ 3.4,224 Button STR0046 Size 38,12 Pixel Action NG295INSU() Of oPnlBotoes  //"&Insumos"
				lStop := .F.
				@ 3.4,266 Button STR0047 Size 38,12 Pixel Action NG295ETAPA() Of oPnlBotoes //"&Etapas"
			EndIf

	If ExistBlock( 'MNTA295E' )
		// Adiciona objetos no array para possibilitar o cliente a realizar manipula��o dos campos.
		aMNTA295E := { oBEMSOLI, oNOMBEMS, ocCCUSTOQ, ocCentrab, oSERVICO, oNOMSERV, oSequen, oDTORIGI, oHORAPRE, oCombSit, oCont1, oHrCont1, oCont2, oHrCont2, oDataPar, oHrPar, oPriorid, oOBSTQB, oNombCus, oNomcTra }
		ExecBlock( 'MNTA295E', .F., .F., aMNTA295E )
	EndIf

	NgPopUp(@AsMenu,@oMenu)
	oDlgA:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlgA)}
	ACTIVATE MSDIALOG oDLGA ON INIT EnchoiceBar(oDLGA,{||nOPCA:=1,If(!MNTA295OK(@oTQB),nOPCA:= 0,(ConfirmSx8(),oDLGA:End()))},{||oDLGA:End()}) CENTERED

	If nOPCA != 1
		RollbackSx8()
		Return .T.
	EndIf

	If !lRPORel17

		If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S" .And. !lArvLog
			aRotina := aClone(aRotinaOld)
			dbSelectArea(cTRBC295)
			ZAP
			Processa({ |lEnd| MNA295TRBC() },STR0113) //"Aguarde... Carregando."
		EndIf
		cCadastro := STR0014 //"Geracao de Ordem de Servico"
		cCadastro := cCADAOLD

		Set Key VK_F12 To
		dbSelectArea('TQB')
		nOPCA := 0

	Else
		dINI := dDTORIGI
		hINI := cHORAPRE
		dFIM := dDTORIGI
		hFIM := cHORAPRE
		dMAX := dDTORIGI
		hMAX := cHORAPRE
		dMIN := dDTORIGI
		hMIN := cHORAPRE

		If Inclui .Or. AllTrim(GetNewPar( "MV_NGMULOS","N" )) == "N" //Se for inclus�o ou o par�metro MV_NGMULOS n�o estiver habilitado.
			If !NGOSABRVEN( cBEMSOLI,cSERVICO,.T.,.T.,.T.,, ) //Fun��o que alerta a exist�ncia de O.S. vencidas.
				Return .F.
			EndIf
		EndIf

		NG420CALDF()

		lPRI295 := .T.
		For ny := 1 To Len(aDATINS)

			If lPRI295 .AND. !Empty(aDATINS[ny][2]) .AND. !Empty(aDATINS[ny][4])
				lPRI295 := .F.
				dMIN := aDATINS[ny][2]
				hMIN := aDATINS[ny][3]
				dMAX := aDATINS[ny][4]
				hMAX := aDATINS[ny][5]
			Else
				If !Empty(aDATINS[ny][2])
					If aDATINS[ny][2] < dMIN
						dMIN := aDATINS[ny][2]
						hMIN := aDATINS[ny][3]
					Else
						If aDATINS[ny][3] < hMIN
							hMIN := aDATINS[ny][3]
						EndIf
					EndIf
				EndIf

				If !Empty(aDATINS[ny][4])
					If aDATINS[ny][4] > dMAX
						dMAX := aDATINS[ny][4]
						hMAX := aDATINS[ny][5]
					Else
						If aDATINS[ny][5] > hMAX
							hMAX := aDATINS[ny][5]
						EndIf
					EndIf
				EndIf
			EndIf
		Next

		l295Grava := .T.

		lGera := .T.
		If lEnercan
			If Empty(TQB->TQB_DTAPRO) .AND. Empty(TQB->TQB_HRAPRO) .AND. Empty(TQB->TQB_APROVA)
				lGera := .F.
			EndIf
		EndIf

		If l295Grava .AND. lGera
			// Mensagem Unica
			If (cSITUA == STR0086) .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
				M->TJ_CODBEM  := cBEMSOLI
				M->TJ_OBSERVA := cOBSTQB
				M->TJ_SITUACA := If(cSITUA == STR0086,"L","P")  //somente liberadas
				M->TJ_TERMINO := "N"
				M->TJ_POSCONT := ST9->T9_POSCONT
				M->TJ_POSCON2 := 0
				M->TJ_USUARIO := If(Len(STJ->TJ_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
				M->TJ_DTORIGI := dDTORIGI
				M->TJ_SERVICO := cSERVICO
				M->TJ_INTPRJ  := If(NGCADICBASE("TJ_INTPRJ","A","STJ",.F.),TQB->TQB_INTPRJ,'')
				M->TJ_INTTSK  := If(NGCADICBASE("TJ_INTTSK","A","STJ",.F.),TQB->TQB_INTTSK,'')
				l295Grava := If(cSITUA == STR0086,NGMUMntOrd(STJ->(RecNo()),3,.T.),.T.)
			EndIf
		EndIf

		If l295Grava .And. cSITUA == STR0086

			If cUsaIntPc == "S"

				cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMV("MV_PRODMNT")) //Ira verificar apenas o primeiro Produto Manutencao do parametro
				dDataIni := MNT420DTOP(dDTORIGI)
				dDataFim := MNT420DTOP(dDTORIGI)
				cCusto := NgFilTPN(cBEMSOLI,dDTORIGI,SubStr(Time(),1,5))[2] //Buscar o C.C. do bem na TPN
				l295Grava := GERAOPNEW(cCODPRO,1,M->TJ_ORDEM,dDataIni,dDataFim,,,cCusto,STR0060)

			EndIf

		EndIf

		//Ponto de Entrada para inser��o de campos de usuario da TQB na STJ
		If ExistBlock("MNTA2956")
			xRet := ExecBlock("MNTA2956",.F.,.F.)
			If ValType(xRet) == "A"
				aCampoUs := xRet
				For nX:= 1 to Len(aCampoUs)
					cOBSTQB := cOBSTQB + " " + aCampoUs[nX]
				Next nX
			EndIf
		EndIf

		If l295Grava .AND. lGera
			//Atualiza o Centro de Custo/Trabalho do Bem
			dbSelectArea( "ST9" )
			dbSetOrder( 01 ) //T9_FILIAL+T9_CODBEM
			dbSeek( xFilial( "ST9" ) + TQB->TQB_CODBEM )

			dbSelectArea("ST4")
			dbSetOrder(1)
			dbSeek(xFilial("ST4")+cSERVICO)

			ConfirmSX8()

			dbSelectArea("STJ")
			dbSetOrder(1)
			RecLock("STJ",.T.)
			STJ->TJ_FILIAL   := xFILIAL("STJ")
			STJ->TJ_ORDEM    := M->TJ_ORDEM
			STJ->TJ_PLANO    := IIF(cTpServico='P',"000001","000000")
			STJ->TJ_CODBEM   := cBEMSOLI
			STJ->TJ_TIPOOS   := cTIPOSS
			STJ->TJ_SERVICO  := cSERVICO
			STJ->TJ_SEQRELA  := IIF(cTpServico='P',cSequen,"0")
			STJ->TJ_DTORIGI  := dDTORIGI
			STJ->TJ_TIPO     := ST4->T4_TIPOMAN
			STJ->TJ_SITUACA  := If(cSITUA == STR0086,"L","P")  //"Liberada"
			STJ->TJ_TERMINO  := "N"
			STJ->TJ_POSCONT  := nCont1
			STJ->TJ_POSCON2  := nCont2
			STJ->TJ_HORACO1  := cHrCont1
			STJ->TJ_HORACO2  := cHrCont2
			STJ->TJ_CODAREA  := ST4->T4_CODAREA
			STJ->TJ_CCUSTO   := cCCUSTOQ
			STJ->TJ_CENTRAB  := cCentra
			STJ->TJ_DTMPINI  := dMIN
			STJ->TJ_HOMPINI  := hMIN
			STJ->TJ_DTMPFIM  := dMAX
			STJ->TJ_HOMPFIM  := hMAX
			STJ->TJ_DTPRINI  := dDataPar
			STJ->TJ_HOPRINI  := cHrPar
			STJ->TJ_USUARIO  := If(Len(STJ->TJ_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
			STJ->TJ_PRIORID  := If(!Empty(cPriorid),cPriorid,If(cTIPOSS = "B",ST9->T9_PRIORID,;
			Replicate("Z",Len(stj->tj_priorid))))
			STJ->TJ_USUAINI := If(Len(STJ->TJ_USUAINI) > 15,cUsername,Substr(cUsuario,7,15))
			STJ->TJ_LUBRIFI  := "N"
			STJ->TJ_SOLICI   := TQB->TQB_SOLICI

			If FieldPos("TJ_QTDITEM") > 0
				STJ->TJ_QTDITEM  := nQtdItens
			EndIf


			STJ->TJ_TERCEIR := "N"

			If lCervPetro
				STJ->TJ_NOMEMAN  := cNomeManut
				STJ->TJ_STATUS   := cStatus
			Elseif lEnercan
				STJ->TJ_STATUS   := "10"
				STJ->TJ_ESTADO   := cESTADO
			EndIf

			dbSelectArea("ST4")
			If ST4->T4_FOLLOWU == "S" .And. STJ->TJ_SITUACA == "P"
				dbSelectArea("TQW")
				dbSetOrder(03)
				If dbSeek(xFILIAL("TQW")+"6 ")
					STJ->TJ_STFOLUP := TQW->TQW_STATUS
				EndIf
			EndIf

			dbSelectarea("STJ")
			If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
				MsMM(,80,,cOBSTQB,1,,,"STJ","TJ_MMSYP")
			Else
				STJ->TJ_OBSERVA  := cOBSTQB
			EndIf

			If AllTrim(GetNewPar("MV_NGINTER","N")) == "M" .And.;
			NGCADICBASE("TJ_INTPRJ","A","STJ",.F.) .And. NGCADICBASE("TJ_INTTSK","A","STJ",.F.)
				STJ->TJ_INTPRJ := TQB->TQB_INTPRJ
				STJ->TJ_INTTSK := TQB->TQB_INTTSK
			EndIf

			STJ->(MsUnLock())

			//gera nao-conformidade
			If Val(STJ->TJ_PLANO) == 0 .And. FindFunction("NGGERAFNC")
				NGGERAFNC(STJ->TJ_ORDEM,STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_DTORIGI)
			EndIf
			If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S"
				dbSelectArea("TT7")
				dbSetOrder(1)
				If !dbSeek(xFilial("TT7")+TQB->TQB_SOLICI+STJ->TJ_ORDEM+STJ->TJ_PLANO)
					Reclock("TT7",.T.)
					TT7->TT7_FILIAL := xFilial("TT7")
					TT7->TT7_SOLICI := TQB->TQB_SOLICI
					TT7->TT7_ORDEM  := STJ->TJ_ORDEM
					TT7->TT7_PLANO  := STJ->TJ_PLANO
					TT7->TT7_SITUAC := STJ->TJ_SITUACA
					TT7->TT7_TERMIN := STJ->TJ_TERMINO
					MsUnLock("TT7")
				EndIf
			EndIf

			If ExistBlock("ENE1W003")
				If TQB->TQB_PRIORI = '2' .OR. TQB->TQB_PRIORI = '3'
					ExecBlock("ENE1W003",.F.,.F.)
				EndIf
			EndIf

			dbSelectArea("TQB")
			RecLock("TQB",.F.)
			TQB->TQB_ORDEM  := M->TJ_ORDEM
			TQB->(MsUnLock())

			M->TJ_DTORIGI := STJ->TJ_DTORIGI
			M->TJ_SITUACA := STJ->TJ_SITUACA
			M->TJ_ORDEM   := STJ->TJ_ORDEM
			M->TJ_PLANO   := STJ->TJ_PLANO
			M->TJ_CODBEM  := STJ->TJ_CODBEM
			M->TJ_SERVICO := STJ->TJ_SERVICO
			M->TJ_SEQUENC := STJ->TJ_SEQUENC
			M->TJ_SEQRELA := STJ->TJ_SEQRELA
			M->TI_TIPOMDO := "E"
			M->TJ_USUAINI := If(Len(STJ->TJ_USUAINI) > 15,cUsername,Substr(cUsuario,7,15))

			If cTpServico == "P" //Grava os bloqueios, etapas e inusmos da OS Preventiva

				If Len(aGETETA) > 0
					Processa({ |lEnd| NG295GRVE()},STR0049) //"Aguarde ..Gravando as Etapas.."
				EndIf

				NGIFDBSEEK("STF",cBEMSOLI+cSERVICO+cSequen,1)

				M->TJ_SITUACA := STJ->TJ_SITUACA
				M->TJ_ORDEM   := STJ->TJ_ORDEM
				M->TJ_PLANO   := STJ->TJ_PLANO
				M->TJ_CODBEM  := STJ->TJ_CODBEM
				M->TJ_SERVICO := STJ->TJ_SERVICO
				M->TJ_SEQUENC := STJ->TJ_SEQUENC
				M->TJ_SEQRELA := STJ->TJ_SEQRELA
				M->TI_TIPOMDO := "E"

				dbSelectArea("STJ")
				nINDSTJ := IndexOrd()
				nRECSTJ := Recno()

				NG410GRAVA( , ,cHORAPRE)//Grava os insumos da manutencao e bloqueios

				dbSelectArea("STJ")
				dbSetOrder(nINDSTJ)
				dbGoto(nRECSTJ)

			Else  //Grava os insumos da OS Corretiva

				If Len(aGETETA) > 0
					Processa({ |lEnd| NG420ATETA() },STR0049) //"Aguarde ..Gravando as Etapas.."
				EndIf
				l295Grava := NG295GRAVA(cBEMSOLI,cSERVICO,M->TJ_ORDEM,dDTORIGI,cCCUSTOQ,cTIPOSS,cSITUA) //Grava os bloqueios dos insumos da OS Corretiva
				//Ponto de Entrada que possibilita realizar o bloqueio de insumos do tipo ferramenta relacionado � um Bem
				If ExistBlock("MNTA295D")
					ExecBlock("MNTA295D",.F.,.F.)
				EndIf
			EndIf

			//�������������������������������������������������������������������Ŀ
			//�Ponto de entrada para permitir gravar dados de usuario no STJ, TQB �
			//���������������������������������������������������������������������
			If ExistBlock("MNTA2952")
				ExecBlock("MNTA2952",.F.,.F.)
			EndIf

			If !lEnercan .OR. (lEnercan .AND. STJ->TJ_SITUACA = 'L')
				If cTpServico != "P"
					If ExistBlock("NGIMPOS")
						If !ExecBlock("NGIMPOS",.F.,.F.,{stj->tj_plano,stj->tj_ordem,stj->tj_dtmpini})
							Return
						EndIf
					EndIf
				EndIf
			EndIf

			If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S" .And. AllTrim(GetNewPar("MV_NGSSWRK","N")) == "S"
				MNW29501(TQB->TQB_CDSOLI)
			EndIf

			If FindFunction("MNTW215") .AND. STJ->TJ_SITUACA == 'L'
				dbSelectArea("STJ")
				MNTW215(,{STJ->TJ_ORDEM})
			EndIf

		Else
			If lEnercan .AND. !lGera
				Help(" ",1,STR0035,,STR0065,3,1)//"ATENCAO"###"OS n�o poder� ser gerada pois a Solicita��o n�o se encontra aprovada."
			EndIf
			RollBackSX8()
		EndIf

		If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S" .And. !lArvLog
			aRotina := aClone(aRotinaOld)
			dbSelectArea(cTRBC295)
			ZAP
			Processa({ |lEnd| MNA295TRBC() },STR0113) //"Aguarde... Carregando."
		EndIf
		cCadastro := STR0014 //"Geracao de Ordem de Servico"
		cCadastro := cCADAOLD

		Set Key VK_F12 To
		dbSelectArea('TQB')
		nOPCA := 0
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295OK
Consist�ncia final

@author  Inacio Luiz Kolling
@since   24/11/2003
@version p12
@param oTQB, objeto, objeto da Classe de S.S.
/*/
//-------------------------------------------------------------------
Static Function MNTA295OK(oTQB)

	Local lRet   := .T.
	Local lRetC2 := .T.

	// Vari�veis de memoria
	Local dINI     := dDTORIGI
	Local hINI     := cHORAPRE
	Local dFIM     := dDTORIGI
	Local hFIM     := cHORAPRE
	Local dMAX     := dDTORIGI
	Local hMAX     := cHORAPRE
	Local dMIN     := dDTORIGI
	Local hMIN     := cHORAPRE
	Local ny       := 0
	Local nTarSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_TAREFA"  })
	Local nTipSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })
	Local nCodSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO"  })
	Local nQtdrSTL := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_QUANREC" })
	Local nTqdSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_QUANTID" })
	Local nUniSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_UNIDADE" })
	Local nDesSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_DESTINO" })
	Local nLocSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_LOCAL"   })
	Local nUsaSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_USACALE" })
	Local nSeqSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_SEQTARE" })
	Local nDtiSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_DTINICI" })
	Local nHoiSTL  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_HOINICI" })
	Local nFornec  := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_FORNEC" })
	Local nLoja    := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_LOJA" })
	Local nTarSTQ  := aSCAN(aHeaEta, {|x| AllTrim(Upper(X[2])) == "TQ_TAREFA"  })
	Local nEtaSTQ  := aSCAN(aHeaEta, {|x| AllTrim(Upper(X[2])) == "TQ_ETAPA"   })
	Local nSeqSTQ  := aSCAN(aHeaEta, {|x| AllTrim(Upper(X[2])) == "TQ_SEQETA"  })
	Local lTarSTL  := nTarSTL <> 0
	Local lTarSTQ  := nTarSTQ <> 0

	// Vari�veis para a Classe
	Local aOrdem    := {}
	Local aEtapa    := {}
	Local aInsum    := {}
	Local aCampos   := {}
	Local nTamTot   := 0
	Local nInd      := 0
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17

	Private cGEROSPR := AllTrim(GETMv("MV_NGGERPR")) //Gera O.S preventivas automaticamente

	If !lRPORel17

		NG420CALDF()

		lPRI295 := .T.
		For ny := 1 To Len(aDATINS)

			If lPRI295 .AND. !Empty(aDATINS[ny][2]) .AND. !Empty(aDATINS[ny][4])
				lPRI295 := .F.
				dMIN := aDATINS[ny][2]
				hMIN := aDATINS[ny][3]
				dMAX := aDATINS[ny][4]
				hMAX := aDATINS[ny][5]
			Else
				If !Empty(aDATINS[ny][2])
					If aDATINS[ny][2] < dMIN
						dMIN := aDATINS[ny][2]
						hMIN := aDATINS[ny][3]
					Else
						If aDATINS[ny][3] < hMIN
							hMIN := aDATINS[ny][3]
						EndIf
					EndIf
				EndIf

				If !Empty(aDATINS[ny][4])
					If aDATINS[ny][4] > dMAX
						dMAX := aDATINS[ny][4]
						hMAX := aDATINS[ny][5]
					Else
						If aDATINS[ny][5] > hMAX
							hMAX := aDATINS[ny][5]
						EndIf
					EndIf
				EndIf
			EndIf
		Next

		// Adiciona a Ordem de Servi�o no array para a Classe
		aOrdem := { {"TJ_CODBEM" , cBEMSOLI},;
					{"TJ_CCUSTO" , cCCUSTOQ},;
					{"TJ_SERVICO", cSERVICO},;
					{"TJ_SEQRELA", IIF(cTpServico='P',cSequen,"0") },;
					{"TJ_DTORIGI", dDTORIGI },;
					{"TJ_HOMPINI", hMIN     },;
					{"TJ_TIPOOS" , cTipoSS  },;
					{"TJ_DTMPINI", dMIN     },;
					{"TJ_OBSERVA", cOBSTQB  },;
					{"TJ_SITUACA", If(cSITUA == STR0086,"L","P")},;
					{"TJ_TERCEIR", "N"},;
					{"TJ_POSCONT", nCont1  },;
					{"TJ_POSCON2", nCont2  },;
					{"TJ_PLANO"  , IIF(cTpServico='P',"000001","000000")},;
					{'TJ_HORACO1', cHrCont1 },;
					{'TJ_HORACO2', cHrCont2 } }

		// Quando o servi�o possuir o campo T4_FOLLOWU igual a S=Sim e a situa��o da O.S. for igual P=Pendente
		// Alimenta o campo TJ_STFOLUP referente ao processo de Follow-Up de O.S.
		If aOrdem[ 10, 2 ] == 'P' .And. Posicione( 'ST4', 1, xFilial( 'ST4' ) + cSERVICO, 'T4_FOLLOWU' ) == 'S'
			aAdd( aOrdem, { 'TJ_STFOLUP', Posicione( 'TQW', 3, xFilial( 'TQW' ) + '6', 'TQW_STATUS' ) } )
		EndIf

		// Adiciona os Insumos no array para a Classe
		If !Empty(aGetIns[1][1])
			nTamTot := Len(aGetIns)
			For nInd := 1 To nTamTot

				aAdd( aInsum, { { 'TL_TAREFA' , Iif(lTarSTL, aGetIns[nInd,nTarSTL],"0") },;
								{ 'TL_TIPOREG', aGetIns[nInd,nTipSTL]  },;
								{ 'TL_CODIGO' , aGetIns[nInd,nCodSTL]  },;
								{ 'TL_QUANREC', aGetIns[nInd,nQtdrSTL] },;
								{ 'TL_QUANTID', aGetIns[nInd,nTqdSTL]  },;
								{ 'TL_UNIDADE', aGetIns[nInd,nUniSTL]  },;
								{ 'TL_DESTINO', aGetIns[nInd,nDesSTL]  },;
								{ 'TL_LOCAL'  , aGetIns[nInd,nLocSTL]  },;
								{ 'TL_USACALE', aGetIns[nInd,nUsaSTL]  },;
								{ 'TL_FORNEC' , aGetIns[nInd,nFornec]  },;
								{ 'TL_LOJA'   , aGetIns[nInd,nLoja]    },;
								{ 'TL_SEQTARE', aGetIns[nInd,nSeqSTL]  },;
								{ 'TL_DTINICI', IIf( aGetIns[nInd,nUsaSTL] == 'N', Date(), aGetIns[ nInd, nDtiSTL ] )},;
								{ 'TL_HOINICI', IIf( aGetIns[nInd,nUsaSTL] == 'N', SubStr( Time(), 1, 5 ), aGetIns[ nInd, nHoiSTL ] ) } } )

			Next nInd
		Else
			aAdd( aInsum, {  } )
		EndIf
		If !Empty(aGETETA[1][1])
			// Adiciona as Etapas no array para a Classe
			nTamTot := Len(aGETETA)
			For nInd := 1 To nTamTot
				aAdd( aEtapa, { {"TQ_TAREFA" , Iif(lTarSTQ, aGETETA[nInd,nTarSTQ],"0") },;
								{"TQ_ETAPA"  , aGETETA[nInd,nEtaSTQ] },;
								{"TQ_SEQETA" , aGETETA[nInd,nSeqSTQ] } } )
			Next nInd
		Else
			aAdd( aEtapa, {  } )
		EndIf

		aAdd( aCampos, { aOrdem, aInsum, aEtapa })

		// Define se a O.S. ser� para Bem ou Localiza��o
		oTQB:setValue("TQB_TIPOSS", cTipoSS)

		oTQB:setValueSO(aCampos)

		// Realiza a cria��o da OS.
		Processa({ || aOrdem := oTQB:createSO(@oTQB) },STR0113) //"Aguarde... Carregando."

		If !Empty(oTQB:getErrorList())
			oTQB:showHelp() // Apresenta o erro em tela.
			oTQB:clearErrorList() // Limpa a lista de erros.
			oTQB:Free() // Fecha objeto utilizado.
			lRet := .F.
		Else
			//--------------------------------------------------------------------------
			// Ponto de entrada NGIMPOS para imprimir a O.s. gravada.
			//--------------------------------------------------------------------------
			If Len(aOrdem) > 0 .And. ExistBlock( 'NGIMPOS' ) .And. NGIFDBSEEK("STJ", aOrdem[1], 1) .And. STJ->TJ_SITUACA == 'L'
				ExecBlock("NGIMPOS",.F.,.F.,{STJ->TJ_PLANO,STJ->TJ_ORDEM,STJ->TJ_DTMPINI})
			EndIf
		EndIf

	Else
		If lCervPetro
			If Empty(cBEMSOLI) .Or. Empty(cCCUSTOQ) .Or. Empty(cSERVICO);
			.Or. Empty( dDTORIGI) .Or. Empty( cHORAPRE) .Or. Empty( cStatus)
				MsgInfo(STR0024,STR0008) //"Campos obrigatorios nao informados"###"NAO CONFORMIDADE"
				lRet := .F.
			EndIf
		Else
			If Empty(cBEMSOLI) .Or. Empty(cCCUSTOQ) .Or. Empty( cSERVICO);
				.Or. Empty( dDTORIGI) .Or. Empty( cHORAPRE)
				MsgInfo(STR0024,STR0008) //"Campos obrigatorios nao informados"###"NAO CONFORMIDADE"
				lRet := .F.
			EndIf
		EndIf

		// Valida Centro de Trabalho.
		If !MNTA295CT()
			Return .F.
		EndIf

		//Verifica se a hora do primeiro contador foi informada.
		If !Empty(nCont1)
			If !NGCHKHISTO(cBEMSOLI,dDTORIGI,nCont1,cHrCont1,1,,.T.,)
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		EndIf

		//Verifica se a hora do segundo contador foi informada.
		If !Empty(nCont2)
			If !NGCHKHISTO(cBEMSOLI,dDTORIGI,nCont2,cHrCont2,2,,.T.,)
				lRetC2 := .F.
			Else
				lRetC2 := .T.
			EndIf
		EndIf

		//Processa Hist�rico de contadores.
		If lRet .And. lRetC2 .And. cTIPOSS == "B"
			//Grava primeiro contador
			If nCont1 > 0
				NGTRETCON(cBEMSOLI,dDTORIGI,nCont1,cHrCont1,1,,,,,) //Verifica se o bem tem contador 1.
			EndIf
			//Grava segundo contador
			If nCont2 > 0
				NGTRETCON(cBEMSOLI,dDTORIGI,nCont2,cHrCont2,2,,,,,) //Verifica se o bem tem 2 contador.
			EndIf
		EndIf

		//Valida tipo do servico,para manter a integridade caso
		//for carregado automaticametne por ponto de entrada
		If AllTrim(GetNewPar("MV_NGSSPRE","N")) == "N"
			If !NGTIPSER(cSERVICO,"C")
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. lRetC2 .And. cTIPOSS == "B"
			//GERA O.S AUTOMATICA POR CONTADOR
			dbSelectArea( "ST9" )
			dbSetOrder( 16 ) //T9_CODBEM+T9_SITBEM
			If dbSeek( cBEMSOLI )
				cFilBem := ST9->T9_FILIAL
			Else
				cFilBem := Space(ST9->T9_FILIAL)
			EndIf
			If (cGEROSPR = "S" .Or. cGEROSPR = "C") .And. (!Empty(nCont1) .Or. !Empty(nCont2))
				If cGEROSPR = "C"
					If MsgYesNo(STR0141+chr(13)+chr(13)+STR0142,STR0143)//"Deseja que seja verificado a exist�ncia de o.s autom�tica por contador?" //"Confirma (Sim/N�o)"#"ATEN��O"
						NGGEROSAUT(cBEMSOLI,If(!Empty(nCont1),nCont1,nCont2),cFilBem)
					EndIf
				Else
					NGGEROSAUT(cBEMSOLI,If(!Empty(nCont1),nCont1,nCont2),cFilBem)
				EndIf
			EndIf

			If cTpServico == "P"  //Valida se a data informada e um dia util ou tem exececao de calendario para OS preventiva

				If !NGMNTOSCO(cTIPOSS,cBEMSOLI,cSERVICO,dDTORIGI,'Val(STJ->TJ_PLANO) = 0')
					Return .F.
				EndIf
				If !NGPREVBSS(cTIPOSS,cBEMSOLI,cSERVICO,dDTORIGI,cSequen,.T.)
					Return .F.
				EndIf

				If NGIFDBSEEK("STF",cBEMSOLI+cSERVICO+cSequen,1)

					If !NGIFDBSEEK("SH7",STF->TF_CALENDA,1)
						Help(" ",1,"CALENDINEX",,CHR(13) + OemToAnsi(STR0123) + STF->TF_CALENDA ,3,0)  //"Calend�rio: "
						Return .F.
					ElseIf !NGIFDBSEEK("SH7",NGSEEK("ST9",STF->TF_CODBEM,1,"T9_CALENDA"),1)
						Help(" ",1,"NGCALENBEM",,CHR(13) + OemToAnsi(STR0123) + NGSEEK("ST9",STF->TF_CODBEM,1,"T9_CALENDA") ,3,0)  //"Calend�rio: "
						Return .F.
					EndIf

					If !NGVALEXCAL(dDTORIGI,STF->TF_CALENDA)
						Return .F.
					EndIf
				EndIf

			EndIf
		EndIf
		If ExistBlock("MNTA2953")
			lRet := ExecBlock("MNTA2953",.F.,.F.)
		EndIf
	EndIf

Return  IIf(!lRPORel17, lRet, lRet .And. lRetC2)

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295CC
Carrega o nome do centro de custo.
@author Ricardo Dal Ponte
@since 15/02/2007
@version p12
/*/
//-------------------------------------------------------------------
Static Function MNTA295CC()

	//���������������������������������������������������Ŀ
	//�Valida permissao do usuario ao preencher Servico   �
	//�de acordo com restricao de acesso na Arvore Logica �
	//�����������������������������������������������������
	If (IsInCallStack("MNTA902") .Or. IsInCallStack("MNTA907"))
		If !NGValidTUA(Nil,{|cTipo,cGrpUsr| NGVerifTUB(cTipo,cGrpUsr,'1',cCCUSTOQ)})
			MsgStop(STR0128,STR0035) //"Usu�rio sem permiss�o para informar este registro."
			Return .F.
		EndIf
	EndIf

	cNOMBCUS := ""

	If cF3CTTSI3 = "CTT"
		cNOMBCUS  := NGSEEK("CTT",cCCUSTOQ,1,"CTT_DESC01")
	Else
		cNOMBCUS  := NGSEEK("SI3",cCCUSTOQ,1,"I3_DESC")
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295SER
Consistencia do servico da ordem de servico

@author  Inacio Luiz Kolling
@since   24/11/2003
@version P12
/*/
//-------------------------------------------------------------------
Static Function MNTA295SER()

	Local aOldArea	 := GetArea()
	Local nINDSTH  	 := 1, nI
	Local nContAcols := 1

	Local cSerefor	:= GetNewPar( "MV_NGSEREF" )
	Local cSercons	:= GetNewPar( "MV_NGSECON" )

	Local nTamTot	:= 0
	Local nInd		:= 0
	Local cCampo	:= ""
	Local cRelacao	:= ""
	Local cUsado	:= ""
	Local cNivelSX3	:= ""

	Local aHeadSTQ	:= {}
	Local aNoFields := {}

	cSequen := "0"

	If lFrotas // Efetua a valida��o somente se for Frota
		If (!Empty( cSERVICO ) .And. !Empty( cSerefor ) .And. Alltrim( cSERVICO ) == Alltrim( cSerefor )) .Or.;
		(!Empty( cSERVICO ) .And. !Empty( cSercons ) .And. Alltrim( cSERVICO ) == Alltrim( cSercons ))
			MsgStop(STR0130)
			Return .F.
		EndIf
	EndIf

	If FindFunction("NGSEQETA")
		nINDSTH := NGSEQETA("STH",nINDSTH)
	EndIf

	dbSelectArea('ST4')
	dbSetOrder(1)
	If !dbSeek(xFilial('ST4')+cSERVICO)
		Help(" ",1,"SERVNAOEXI")
		RestArea( aOldArea )
		Return .F.
	Else
		If NGFUNCRPO("NGSERVBLOQ",.F.)  .And.  !NGSERVBLOQ(cSERVICO)
			RestArea( aOldArea )
			Return .F.
		EndIf
		dbSelectArea('STE')
		dbSetOrder(01)
		If dbSeek(xFilial('STE')+ST4->T4_TIPOMAN)
			cTpServico := STE->TE_CARACTE
			If cTpServico == 'P'
				If AllTrim( GetNewPar( 'MV_NGSSPRE', 'N' ) ) != 'N'
					If cTIPOSS == "L"
						MsgStop(STR0088,STR0035) //"N�o existe manuten��o cadastrada para esse Bem/Servico!"###"ATENCAO"
						RestArea( aOldArea )
						Return .F.
					Else
						If !MNTA295STF()
							lStop := .T.
							MsgStop(STR0088,STR0035) //"N�o existe manuten��o cadastrada para esse Bem/Servico!"###"ATENCAO"
							RestArea( aOldArea )
							Return .F.
						EndIf
					EndIf
				Else
					// Devido a configura��o do parametro MV_NGSSPRE o servi�o informado dever� ser corretivo.
					Help( '', 1, 'SERVNAOCOR')
					RestArea( aOldArea )
					Return .F.
				EndIf
			EndIf
			If cTIPOSS == 'L' .And. cTpServico == 'O'
				//"O servi�o informado pertence ao tipo de servi�o 'Outros', portanto n�o poder� ser utilizado neste processo." # "Aten��o"
				MsgStop( STR0156, STR0035 )
				RestArea( aOldArea )
				Return .F.
			EndIf
		EndIf
	EndIf
	RestArea(aOldArea)

	// Valida permissao do usuario ao preencher Servico
	// de acordo com restricao de acesso na Arvore Logica
	If (IsInCallStack("MNTA902") .Or. IsInCallStack("MNTA907"))
		If !NGValidTUA(Nil,{|cTipo,cGrpUsr| NGVerifTUB(cTipo,cGrpUsr,'7',cSERVICO)})
			MsgStop(STR0129,STR0035) //"Usu�rio sem permiss�o para incluir O.S com este servi�o."
			Return .F.
		EndIf
	EndIf

	cNOMSERV := NGSEEK("ST4",cSERVICO,1,"T4_NOME")

	If cTpServico == "P"
		lCORRET := .F.
	Else
		lCORRET := .T.
		IIf(lBem,cPriorid := ST9->T9_PRIORID,) //027355:Se for um bem e a OS for corretiva, assume a prioridade do Bem.
	EndIf

	NGIFDBSEEK("STF",cBEMSOLI+cSERVICO+cSequen,1) // NAO RETIRAR ESTA LINHA
	// USADO NO F3 -> ST5

	/*Carrega as etapas da manuten��o caso for preventiva*/

	If cTpServico == "P" .And. Alltrim(cSequen) <> "0"

		If lPRIACET .Or. cSERVIPRI <> cSERVICO .Or. cBEMPRI <> cBEMSOLI .Or. cSEQPRI <> cSequen
			lPRIACET := .F.

			nUsoSTQ := 0

			aHeadSTQ := NGHeader("STQ")
			nTamTot := Len(aHeadSTQ)

			For nInd := 1 to nTamTot
				cCampo 		:= aHeadSTQ[nInd,2]
				cRelacao	:= Posicione("SX3",2,cCampo,"X3_RELACAO")
				cUsado		:= aHeadSTQ[nInd,7]
				cNivelSX3		:= Posicione("SX3",2,cCampo,"X3_NIVEL")

				If X3USO(cUsado) .And. cNivel >= cNivelSX3 .And. Trim(cCampo) != "TQ_ORDEM" .And.;
					Trim(cCampo) != "TQ_PLANO"   .And. Trim(cCampo) != "TQ_NOMTARE" .And.;
					Trim(cCampo) != "TQ_TIPRES"  .And. Trim(cCampo) != "TQ_OPCAO"   .And.;
					Trim(cCampo) != "TQ_NOMSITU" .And. Trim(cCampo) != "TQ_OK"
					nUsoSTQ++
				EndIf
			Next nInd

			nCntSTH := 0
			dbselectarea("STH")
			dbSetOrder(nINDSTH)
			If dbseek(xFILIAL("STH")+cBEMSOLI+cSERVICO+cSequen)

				While !Eof() .And. STH->TH_FILIAL == xFILIAL("STH") .And. STH->TH_CODBEM == cBEMSOLI;
				.And. STH->TH_SERVICO == cSERVICO .And. STH->TH_SEQRELA == cSequen

					nCntSTH++
					dbskip()
				End
			EndIf

			If nCntSTH > 0
				aGETETA := {}
				Private aGETPREV[nCntSTH][nUsoSTQ+1]

				dbselectarea("STH")
				dbSetOrder(nINDSTH)
				If dbseek(xFILIAL("STH")+cBEMSOLI+cSERVICO+cSequen)

					While !Eof() .And. STH->TH_FILIAL == xFILIAL("STH") .And. STH->TH_CODBEM == cBEMSOLI;
					.And. STH->TH_SERVICO == cSERVICO .And. STH->TH_SEQRELA == cSequen

						dbselectarea("TPA")
						dbseek(xFILIAL("TPA")+STH->TH_ETAPA)
						dbselectarea("STH")

						For nI := 1 To Len(aHEAETA)
							If Alltrim(aHEAETA[nI][2]) <> "TQ_NOMETAP"
								nONDERL := At("_",Alltrim(aHEAETA[nI][2]))
								If nONDERL > 0
									cCAMIGUA := Alltrim(Substr(Alltrim(aHEAETA[nI][2]),nONDERL+1,Len(Alltrim(aHEAETA[nI][2]))))
									cFILPOS3 := "TH_"+cCAMIGUA
									cCAMPSTH := "STH->TH_"+cCAMIGUA
									If FieldPos(cFILPOS3) > 0
										aGETPREV[nContAcols][nI] := &(cCAMPSTH)
									Else
										aGETPREV[nContAcols][nI] := CriaVar(Alltrim(aHEAETA[nI][2]))
									EndIf
								EndIf
							Else
								aGETPREV[nContAcols][nI] := TPA->TPA_DESCRI
							EndIf
						Next
						aGETPREV[nContAcols][Len(aGETPREV[nContAcols])] := .F.
						nContAcols += 1

						dbselectarea("STH")
						dbskip()
					End
				EndIf
				aGETETA := aCLONE(aGETPREV)
			EndIf
		EndIf
	Else
		If cTPSERPRI <> cTpServico
			// Campos que n�o ser�o considerados
			aNoFields := { 'TQ_ORDEM', 'TQ_PLANO', 'TQ_NOMTARE', 'TQ_TIPRES', 'TQ_OPCAO',;
				'TQ_NOMSITU', 'TQ_OK', 'TQ_TIPORES', 'TQ_OPCAO' }

			If !lUSATARG .And. AllTrim( GetNewPar( 'MV_NGSSPRE', 'N' ) ) == 'N'
				aAdd( aNoFields, 'TQ_TAREFA' )
			EndIf
			aHeadSTQ := CABECGETD( 'STQ', aNoFields )
			aGETETA  := BLANKGETD( aHeadSTQ )
		EndIf
	EndIf

	cSERVIPRI := cSERVICO
	cBEMPRI   := cBEMSOLI
	cSEQPRI   := cSequen
	cTPSERPRI := cTpServico

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295DTO
Consistencia da data original da ordem de servico

@author  Inacio Luiz Kolling
@since   24/11/2003
@version P12
/*/
//-------------------------------------------------------------------
Static Function MNTA295DTO()
	If VAZIO(dDTORIGI)
		Return .F.
	EndIf
	If dDTORIGI < tqb->tqb_dtaber
		MsgInfo(STR0025+chr(13)+chr(10)+chr(13)+chr(10); //"Data original devera ser maior ou igual a data de abertura"
		+STR0026+"...: "+Dtoc(tqb->tqb_dtaber)+chr(13)+chr(10); //"Data abertura"
		+STR0027+".: "+Dtoc(dDTORIGI),STR0008)         //"Data Informada"###"NAO CONFORMIDADE"
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295HOS
Consistencia da hora original da ordem de servico

@author  Inacio Luiz Kolling
@since   24/11/2003
@version P12
/*/
//-------------------------------------------------------------------
Static Function MNTA295HOS()

	Local cMENSA := Space(10)

	If !NGVALHORA(cHORAPRE,.T.)
		Return .F.
	EndIf

	If Empty(cMENSA)
		If dDTORIGI = TQB->TQB_DTABER .And. cHORAPRE < TQB->TQB_HOABER
			cMENSA := STR0031+chr(13)+chr(10)+chr(13)+chr(10); //"Hora original do ordem de servico devera ser maior ou igual a hora de abertura"
			+STR0032+"...: "+tqb->tqb_hoaber+chr(13)+chr(10); //"Hora Abertura"
			+STR0030+".: "+cHORAPRE  //"Hora Informada"
		EndIf
	EndIf
	If !Empty(cMENSA)
		MsgInfo(cMENSA,STR0008) //"NAO CONFORMIDADE"
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} NG295BEMLOC
Consistencia do bem/localizacao

@author  Inacio Luiz Kolling
@since   17/02/2004
@version P12
/*/
//-------------------------------------------------------------------
Function NG295BEMLOC(cTIPOS,oDLGA)

	Local nINDSTH   	:= 1
	Local nI
	Local nContAcols 	:= 1
	Local nTamTot		:= 0
	Local nInd			:= 0
	Local cCampo		:= ""
	Local cRelacao		:= ""
	Local cUsado		:= ""
	Local cNivelSX3		:= ""
	Local aHeadSTQ		:= {}
	Local aNoFields     := {}

	If FindFunction("NGSEQETA")
		nINDSTH := NGSEQETA("STH",nINDSTH)
	EndIf

	oDLGA:REFRESH()

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(xFILIAL("ST9")+cBEMSOLI)
		cTIPOSS	:= "B"	// Variavel que controla o campo "Tipo	OS" de oDlga
		cTIPOS	:= "B"	// Parametro recebido
		cTIPOSSM	:= STR0012
		cNOMBEMS	:= ST9->T9_NOME
		cCCUSTOQ	:= ST9->T9_CCUSTO
		cCentra		:= ST9->T9_CENTRAB
		cNOMBCUS 	:= NGSEEK("CTT",cCCUSTOQ,1,"CTT_DESC01")
		cNomctra 	:= NGSEEK("SHB",cCentra ,1, "HB_NOME"  )
		nCont1		:= 0
		nCont2	 	:= 0
		cHrCont1 	:= Space( 5 )
		cHrCont2 	:= Space( 5 )
	Else
		nORDTAF := 7
		cCODBEM := "X2"+Substr(cBEMSOLI,1,3)
		dbSelectArea("TAF")
		dbSetOrder(nORDTAF)
		If dbSeek(xFILIAL("TAF")+cCODBEM)
			cTIPOSS		:= "L"	// Variavel que controla o campo "Tipo	OS" de oDlga
			cTIPOS		:= "L"	// Parametro recebido
			cTIPOSSM	:= STR0013
			cNOMBEMS 	:= taf->taf_nomniv
			cCCUSTOQ 	:= taf->taf_ccusto
			cCentra  	:= TAF->TAF_CENTRA
			cNOMBCUS 	:= NGSEEK("CTT",cCCUSTOQ,1,"CTT_DESC01")
			cNomctra 	:= NGSEEK("SHB",cCentra ,1, "HB_NOME"  )
			nCont1		:= 0
			nCont2	 	:= 0
			cHrCont1 	:= Space( 5 )
			cHrCont2 	:= Space( 5 )
		Else
			Help(" ",1,"REGNOIS")
			Return .F.
		EndIf
	EndIf

	If !Empty(cSERVICO)
		/*Carrega as etapas da manuten��o caso for preventiva*/
		If cTpServico == "P" .And. Alltrim(cSequen) <> "0"

			If cBEMSOLI <> cBEMPRI

				nUsoSTQ := 0

				aHeadSTQ := NGHeader("STQ")
				nTamTot := Len(aHeadSTQ)

				For nInd := 1 to nTamTot
					cCampo 		:= aHeadSTQ[nInd,2]
					cRelacao	:= Posicione("SX3",2,cCampo,"X3_RELACAO")
					cUsado		:= aHeadSTQ[nInd,7]
					cNivelSX3		:= Posicione("SX3",2,cCampo,"X3_NIVEL")

					If X3USO(cUsado) .And. cNivel >= cNivelSX3 .And. Trim(cCampo) != "TQ_ORDEM" .And.;
						Trim(cCampo) != "TQ_PLANO"   .And. Trim(cCampo) != "TQ_NOMTARE" .And.;
						Trim(cCampo) != "TQ_TIPRES"  .And. Trim(cCampo) != "TQ_OPCAO"   .And.;
						Trim(cCampo) != "TQ_NOMSITU" .And. Trim(cCampo) != "TQ_OK"
						nUsoSTQ++
					EndIf
				Next nInd

				nCntSTH := 0
				dbselectarea("STH")
				dbSetOrder(nINDSTH)
				If dbseek(xFILIAL("STH")+cBEMSOLI+cSERVICO+cSequen)

					While !Eof() .And. STH->TH_FILIAL == xFILIAL("STH") .And. STH->TH_CODBEM == cBEMSOLI;
					.And. STH->TH_SERVICO == cSERVICO .And. STH->TH_SEQRELA == cSequen

						nCntSTH++
						dbskip()
					End
				EndIf

				If nCntSTH > 0
					aGETETA := {}
					Private aGETPREV[nCntSTH][nUsoSTQ+1]

					dbselectarea("STH")
					dbSetOrder(nINDSTH)
					If dbseek(xFILIAL("STH")+cBEMSOLI+cSERVICO+cSequen)

						While !Eof() .And. STH->TH_FILIAL == xFILIAL("STH") .And. STH->TH_CODBEM == cBEMSOLI;
						.And. STH->TH_SERVICO == cSERVICO .And. STH->TH_SEQRELA == cSequen

							dbselectarea("TPA")
							dbseek(xFILIAL("TPA")+STH->TH_ETAPA)
							dbselectarea("STH")

							For nI := 1 To Len(aHEAETA)
								If Alltrim(aHEAETA[nI][2]) <> "TQ_NOMETAP"
									nONDERL := At("_",Alltrim(aHEAETA[nI][2]))
									If nONDERL > 0
										cCAMIGUA := Alltrim(Substr(Alltrim(aHEAETA[nI][2]),nONDERL+1,Len(Alltrim(aHEAETA[nI][2]))))
										cFILPOS3 := "TH_"+cCAMIGUA
										cCAMPSTH := "STH->TH_"+cCAMIGUA
										If FieldPos(cFILPOS3) > 0
											aGETPREV[nContAcols][nI] := &(cCAMPSTH)
										Else
											aGETPREV[nContAcols][nI] := CriaVar(Alltrim(aHEAETA[nI][2]))
										EndIf
									EndIf
								Else
									aGETPREV[nContAcols][nI] := TPA->TPA_DESCRI
								EndIf
							Next
							aGETPREV[nContAcols][Len(aGETPREV[nContAcols])] := .F.
							nContAcols += 1

							dbselectarea("STH")
							dbskip()
						End
					EndIf
					aGETETA := aCLONE(aGETPREV)
				Else
					aGETETA := {}
				EndIf
			EndIf
		Else
			If cTPSERPRI <> cTpServico
				// Campos que n�o ser�o considerados
				aNoFields := { 'TQ_ORDEM', 'TQ_PLANO', 'TQ_NOMTARE', 'TQ_TIPRES', 'TQ_OPCAO',;
					'TQ_NOMSITU', 'TQ_OK', 'TQ_TIPORES', 'TQ_OPCAO' }

				If !lUSATARG .And. AllTrim( GetNewPar( 'MV_NGSSPRE', 'N' ) ) == 'N'
					aAdd( aNoFields, 'TQ_TAREFA' )
				EndIf
				aHeadSTQ := CABECGETD( 'STQ', aNoFields )
				aGETETA  := BLANKGETD( aHeadSTQ )
			EndIf
		EndIf
	EndIf

	cBEMPRI := cBEMSOLI

Return .T.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295SERV  � Autor � Ricardo Dal Ponte     � Data �15/12/2006���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Consistencia do servico                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function NG295SERV()
	Local nRegTQB := TQB->(RecNo())
	Local cCodBem := TQB->TQB_CODBEM
	Local cCdServ := M->TQB_CDSERV
	Local cSolici := TQB->TQB_SOLICI
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17

	If Empty(M->TQB_CDSERV)
		Help(1," ","OBRIGAT2",,RetTitle("TQB_CDSERV"),3,0)
		Return .F.
	EndIf

	//Ponto de Entrada para validar campos preenchidos ou n�o ap�s distribui��o da SS.
	If ExistBlock("MNTA295A")
		If !ExecBlock( "MNTA295A", .F., .F. ) //Se o Retorno do PE for falso.
			Return .F.
		EndIf
	EndIf

	//ALERTA DUPLICIDADE DE SS (CODBEM+CDSERV)
	dbSelectArea("TQB")
	dbSetOrder(05)
	dbSeek(xFilial("TQB")+cCodBem,.T.)
	While !Eof() .And. TQB->TQB_FILIAL == xFilial("TQB") .And. TQB->TQB_CODBEM == cCodBem
		If TQB->TQB_CDSERV == cCdServ .And. TQB->TQB_SOLICI != cSolici .And. TQB->TQB_SOLUCA == "D" //somente distribuidas
			If !APMSGYESNO(STR0124+CHR(13)+;  //"Existe pelo menos uma Solicita��o de Servi�o distribu�da"
			STR0125+CHR(13)+;  //"para o mesmo bem/localiza��o e servi�o desta S.S."
			STR0126,STR0127)  //"Deseja confirmar a distribui��o?"##"Duplicidade de S.S."
				dbGoTo(nRegTQB)
				Return .F.
			Else
				Exit
			EndIf
		EndIf
		dbSkip()
	End

	If lRPORel17
		If Empty(M->TQB_CDEXEC)
			Help( " ",1, STR0152,, STR0153 + Alltrim(Posicione("SX3",2,"TQB_CDEXEC","X3Titulo()")) + "(TQB_CDEXEC)" + STR0154,3,1 )
			Return .F.
		//Adicionada condi��o para validar somente se obrigat�rio no dicion�rio (SIGACFG)
		ElseIf X3Obrigat('TQB_PRIORI') .And. Empty(M->TQB_PRIORI)
			Help( " ",1, STR0152,, STR0153 + Alltrim(Posicione("SX3",2,"TQB_PRIORI","X3Titulo()")) + " (TQB_PRIORI)" + STR0154,3,1 )
			Return .F.
		EndIf
	EndIf
	dbGoTo(nRegTQB)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ricardo Dal Ponte     � Data �29/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local nX := 0
	Local aRotina := {}

	If AllTrim(GetNewPar("MV_NGMULOS","N")) <> "S"
		aRotina := {{STR0041,"PesqBrw"       , 0, 1},; //"Pesquisar"
					{STR0042,"MNTA295CLA(2)" , 0, 2},;  //"Visualizar"
					{STR0043,"MNTA295CLA(4)" , 0, 4},; //"Distribuir"
					{STR0044,"MNTA295GOS"    , 0, 4},; //"Gera OS"
					{STR0002,"MNTA295LEG"    , 0, 4,,.F.}}  //"Legenda"
	Else
		aRotina := {{STR0041,"PesqBrw"       , 0, 1},; //"Pesquisar"
					{STR0042,"MNTA295CLA(2)" , 0, 2},;  //"Visualizar"
					{STR0043,"MNTA295CLA(4)" , 0, 4},; //"Distribuir"
					{STR0044,"MNTA295MOS"    , 0, 4},; //"Gera OS"
					{STR0002,"MNTA295LEG"    , 0, 4,,.F.}}  //"Legenda"
	EndIf
	aAdd(aRotina, {STR0144, "MsDocument"  ,0, 4}) //"Conhecimento"

	If ExistBlock("MNTA295B")
		aRetBt := ExecBlock( 'MNTA295B', .F., .F. )
		If Valtype(aRetBt) <> "A"
			MSGSTOP (STR0122)
		Else
			For nX := 1 to Len(aRetBt)
				aAdd( aRotina , aClone(aRetBt[nX]) )
			Next nX
		EndIf
	EndIf

Return(aRotina)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295ININS� Autor � Elisangela Costa      � Data � 11/05/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa a acols de insumos                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function NG295ININS()

	Local aNAO := {},NG

	aNAO := {"TL_DTFIM","TL_HOFIM","TL_ORDEM","TL_PLANO",;
	"TL_SEQUENC","TL_SEQRELA","TL_NOMSEQ","TL_NOMTREG",;
	"TL_CUSTO","TL_CUSTO2","TL_CUSTO3","TL_CUSTO4","TL_CUSTO5","TL_CUSENT1",;
	"TL_CUSENT2","TL_CUSENT3","TL_CUSENT4","TL_CUSENT5","TL_OCORREN",;
	"TL_REPFIM","TL_NUMSEQ","TL_CODOBS",If(NGCADICBASE('TL_PCTHREX','A','STL',.F.), "TL_PCTHREX", "TL_HREXTRA"),;
	"TL_CONTROL","TL_ETAPA","TL_GARANTI","TL_NOMETAP","TL_NOMLOCA",;
	"TL_NUMLOTE","TL_LOTECTL","TL_LOCALIZ","TL_DTVALID","TL_NUMSERI"}

	If !lUSATARG
		aAdd(aNAO,"TL_TAREFA")
		aAdd(aNAO,"TL_NOMTAR")
	EndIf

	dbSelectArea("STL")
	dbSetOrder(3)
	dbGobottom()
	dbskip()

	aHEAINS := CABECGETD("STL", aNAO, 2)
	If Len(aGETINS) == 0
		aGETINS := BLANKGETD(aHeaIns)
	EndIf

	For NG := 1 To Len(aGETINS)
		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
		M->TL_TIPOREG := If(xx > 0, aGETINS[nG][xx], " ")

		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
		M->TL_CODIGO := If(xx > 0, aGETINS[nG][xx], Space(15))

		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_NOMCODI"})
		If xx > 0
			aGetIns[nG][xx] := VirtInsumo(M->TL_TIPOREG, M->TL_CODIGO)
		EndIf
	Next

	nQTDHEA := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_QUANTID" })
	nTIPHEA := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })

	If nQTDHEA > 0
		aHEAINS[nQTDHEA,6]  := "NAOVAZIO() .And. NG420QUANT(aCOLS[n,nTIPHEA],M->TL_QUANTID)"
	EndIf

	nUSACAL := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_USACALE" })
	nCODINS := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO" })
	nDATAIN := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_DTINICI" })
	nHORAIN := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_HOINICI" })

	If nUSACAL > 0
		aHEAINS[nUSACAL,6]  := "Pertence('SN') .And. NGCHKCALEN(aCOLS[n,nCODINS],6,'ST1','T1_TURNO') .And. MNT420ACHO()"
	EndIf

	If nDATAIN > 0  .And. nHORAIN > 0
		aHEAINS[nDATAIN,6] := "NAOVAZIO() .And. NGDTAINSUIN(M->TL_DTINICI) .And. NGVDTIN295()"
		aHEAINS[nHORAIN,6] := "NG295HOINI()"
	EndIf

	If nTIPHEA > 0
		aHEAINS[nTIPHEA,6] := "If(!Empty(M->TL_TIPOREG),PERTENCE('MPFTE'),NaoVazio()) .And. NGVALTERC(M->TL_TIPOREG) .And. NGRETNOREG(M->TL_TIPOREG) .And. MNT420ACHO() .And. NGCLEARSTL()"
	EndIf

	dbSelectArea("STL")
	dbSetOrder(1)

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NGVDTIN295� Autor � Elisangela Costa      � Data � 11/05/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o campo data inicio de aplicacao do insumo           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NGVDTIN295()
	Local dDATA := dDTORIGI
	If M->TL_DTINICI < dDATA
		MSGINFO(STR0050+" "+DTOC(dDATA),STR0008)  //"Data de inicio informada e menor do que a data prevista para inicio da OS." #"NAO CONFORMIDADE"
		Return .F.
	EndIf
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295INETA� Autor � Elisangela Costa      � Data � 11/05/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa a acols das etapas                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function NG295INETA()
	Local lCheckList := NGCADICBASE("TTG_CHECK","D","TTG",.F.)
	Local aNAO := {}
	Local nNOME, nT, x
	Local cEta
	Local aETAPA

	aNAO := {"TQ_ORDEM","TQ_PLANO","TQ_NOMTARE","TQ_TIPRES","TQ_OPCAO",;
	"TQ_NOMSITU","TQ_OK","TQ_TIPORES","TQ_OPCAO"}

	If !lUSATARG .And. AllTrim(GetNewPar("MV_NGSSPRE","N")) == "N"
		aAdd(aNAO,"TQ_TAREFA")
	EndIf


	aHEAETA := CABECGETD("STQ", aNAO)
	aGETETA := BLANKGETD(aHeaEta)
	aETAPA  := aCLONE(aGETETA[1])

	nTAREFA := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_TAREFA" })
	nETAPA  := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_ETAPA" })
	nNOME   := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_NOMETAP" })

	If !lUSATARG
		If nTAREFA > 0
			aHEAETA[nTAREFA,6]  := "IF(Alltrim(M->TQ_TAREFA)=='0',.T.,EXISTCPO('ST5',MV_PAR01+MV_PAR02+MV_PAR05+M->TQ_TAREFA))"
		EndIf
	EndIf

	If nETAPA > 0
		aHEAETA[nETAPA,6] := "MNT295ETA(M->TQ_ETAPA)"
	EndIf

	If lCheckList
		dbSelectArea("TTG")
		dbSetOrder(2)
		If dbSeek(xFilial("TTG")+TQB->TQB_SOLICI)
			While !Eof() .And. xFilial("TTG") == TTG->TTG_FILIAL .And. TTG->TTG_NUMERO == TQB->TQB_SOLICI
				nT := Len(aGETETA)
				If (nT > 1) .Or. !Empty(aGETETA[nT][nETAPA])
					aAdd(aGETETA,{})
					For x := 1 to Len(aETAPA)
						cEta := aETAPA[x]
						aAdd(aGETETA[nT+1],cEta)
					Next
					nT++
				EndIf
				If nTAREFA > 0
					aGETETA[nT][nTAREFA] := '0'
				EndIf
				aGETETA[nT][nETAPA]  := TTG->TTG_ETAPA
				aGETETA[nT][nNOME]    := NGSEEK("TPA",TTG->TTG_ETAPA,1,"TPA_DESCRI")
				TTG->(dbSkip())
			End
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} NG295INSU
Monta a tela de inclusao de insumos

@author Alexandre Santos
@since 15/06/18
@version 2.0

@param

@sample MNT280AJU()

@return lRet, L�gico, Se processo foi concluido com sucesso.
/*/
//---------------------------------------------------------------------
Function NG295INSU()

	Local cTdOk    := "NG420TUDOK(oGet:aCols)"
	Local cLinOk   := "NG420LINOK(oGet:aCols, oGet:nAt)"
	Local cDelOk   := "NG420DELI( oGet:aCols, oGet:nAt)"
	Local cWhenQ   := Posicione("SX3",2,"TL_QUANTID","X3_WHEN")
	Local nPosIns  := 0
	Local nPosQtd  := 0
	Local oDlgIns  := Nil
	Local oMenu    := Nil
	Local lRet     := .T.
	Local lVld     := .F.
	Local bKeyF4 := SetKey(VK_F4)
	Local nPosCodI := 0

	Private oGet   := Nil

	If !NG295SERV2()
		lRet := .F.
	EndIf

	// USADO NA ALTERACAO (MNTA420)
	aHeaInsAl := aClone(aHeaIns)
	aGetInsAl := aClone(aGetIns)

	If lRet .And. cTpServico <> "P"
		aHeader := aClone(aHeaIns)
		aCols   := aClone(aGetIns)
		nPosIns := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })
		nPosQtd := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "TL_QUANTID" })
		nPosCodI:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO" })

		SetKey(VK_F12, {||NGINSUF12("M->TL_CODIGO",cBEMSOLI,oGet:aCols[oGet:nAt,nPosIns],.T.,,"TL_NOMCODI")})
		SetKey(VK_F4,{|| MntViewSB2(oGet:aCOLS[oGet:nAt,nPOSINS],oGet:aCOLS[oGet:nAt,nPosCodI]) })

		//Insumos - Solicita��o de Servi�o
		Define MsDialog oDlgIns Title STR0051 From 163,0 To 463,If(GetScreenRes()[1] <= 800,740,GetScreenRes()[1]*0.73) Pixel Of oMainWnd

			oGet := MsNewGetDados():New(13, 01, 140, 315, GD_INSERT + GD_UPDATE + GD_DELETE, cLinOk, cTdOk,,,, 9999,,, cDelOk, oDlgIns, aHeader, aCols)

			NgPopUp(@AsMenu,@oMenu)
			oDlgIns:bRClicked         := { |o,x,y| oMenu:Activate(x,y,oDlgIns)}
			oGet:aHeader[nPosQtd][13] := Space(Len(cWhenQ)) //Garante que o conteudo when do campo TL_QUANTID esteja vazio.

		Activate MsDialog oDlgIns On Init (EnchoiceBar(oDlgIns,{||IIf(oGet:TudoOk(),(oDlgIns:End(),lVld := .T.), .F.)}, {||oDlgIns:End()}), AlignObject(oDlgIns,{oGet:oBrowse},1)) CENTERED

		If lVld
			aHeaIns := aClone(oGet:aHeader)
			aGetIns := aClone(oGet:aCols)
		EndIf

		Set Key VK_F12 To
	ElseIf lRet .And. !lStop
		MsgInfo(STR0105,STR0035)//Quando o servi�o � preventivo os insumos s�o buscados da manuten��o relacionada!#ATEN��O
		lRet := .T.
	EndIf

	SetKey(VK_F4,bKeyF4)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295HOINI� Autor � Elisangela Costa      � Data � 11/05/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se a Data/hora esta dentro do calendario da M-D-O    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NG295HOINI()

	If !NGVALHORA(M->TL_HOINICI,.T.)
		Return .F.
	EndIf

	If aCols[n][nDATAIN] =  dDTORIGI .And. M->TL_HOINICI < cHORAPRE
		MsgInfo(STR0052+cHORAPRE+".",STR0008) //"Hora inicio menor que a hora prevista inicio da ordem de servico: " #"NAO CONFORMIDADE"
		Return .F.
	EndIf

	M->TL_USACALE := aCols[n][nUSACAL]
	If !NGSTLHORIN()
		Return .T.
	EndIf
Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295ETAPA� Autor � Elisangela Costa      � Data � 11/05/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta a tela do botao de etapas                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NG295ETAPA()
	Local oMenu
	Local oDlg2
	Local oGet

	If !lStop
		If !NG295SERV2()
			Return
		EndIf


		aHEADER := aCLONE(aHEAETA)
		aCOLS   := aCLONE(aGETETA)
		cTUDOOK := "AllwaysTrue()"
		cLINOK  := "MNT295VALE(1)"
		nOpcae  := 0

		NGIFDBSEEK("STF",cBEMSOLI+cSERVICO+cSequen,1)
		NGSETIFARQUI("STQ","F",1)
		M->TF_CODBEM  := cBEMSOLI
		M->TF_SERVICO := cSERVICO
		M->TF_SEQRELA := cSequen

		MV_PAR01 := cBEMSOLI
		MV_PAR02 := cSERVICO
		MV_PAR05 := cSequen

		Define MsDialog oDlg2 Title STR0053 From 163,0 To 463,If(GetScreenRes()[1] <= 800,740,GetScreenRes()[1]*0.73) Pixel Of oMainWnd   // "Etapas - Solicita��o de Servi�o"
		oGet := MSGetDados():New(13,1,140,315,3,cLINOK,cTUDOOK,"",.T.,,,,300)

		NgPopUp(@AsMenu,@oMenu)
		oDlg2:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg2)}
		Activate MsDialog oDLG2 On Init (EnchoiceBar(oDLG2,{||nOpcae:=1,If(!MNT295VALE(2),nOpcae:=1,oDLG2:End())},{||oDLG2:End()}),AlignObject(oDLG2,{oGet:oBrowse},1)) CENTERED

		If nOpcae == 1
			aHEAETA := aCLONE(aHeader)
			aGETETA := aCLONE(aCOLS)
		EndIf
	EndIf
	lStop := .F.
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295GRAVA� Autor � Elisangela Costa      � Data � 11/05/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava o registro                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NG295GRAVA(cBEMSOLI,cSERVICO,cORDEMTJ,dDTORIGI,cCCUSTOQ,cTIPOSS,cSITUA)
	Private cLOCAL    := Space(Len(SB1->B1_LOCPAD))
	Private cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
	Private cUsaIntCm := AllTrim(GetMV("MV_NGMNTCM"))
	Private cUsaIntEs := AllTrim(GetMV("MV_NGMNTES"))

	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek(xFilial("ST9")+cBEMSOLI)

	aBLO := { {},{},{},{},{}}

	nPOSINS := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })
	nPOSCOD := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO" })
	nPOSQTD := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_QUANTID"})
	nPOSREC := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_QUANREC"})
	nUNIDAD := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_UNIDADE"})
	nUSACAL := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_USACALE" })
	nDATAIN := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_DTINICI" })
	nHORAIN := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_HOINICI" })
	ndDTFIM := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_DTFIM"})
	nhHORAF := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_HOFIM"})

	If GETMV("MV_NGCORPR") == "S" .and. nPOSINS > 0 .and. ;
	nPOSCOD > 0 .and. nPOSQTD > 0 .and. nPOSREC > 0

		cOP  := cORDEMTJ + "OS001"
		aBLO := { {},{},{},{},{}}
		M->TJ_ORDEM  := cORDEMTJ
		M->TJ_CCUSTO := cCCUSTOQ
		Processa({ |lEnd| MNTA420IN() },STR0054) //"Aguarde ..Preparando Para Gerar Insumos..."

	EndIf

	Processa({ |lEnd| NG420ATINS() },STR0048) //"Aguarde ..Gravando os Insumos.."

	//�����������������������������������������������������������Ŀ
	//�Gera ordem de Producao para a OS                           �
	//�������������������������������������������������������������
	If cSITUA == STR0086 //"Liberada"

		M->TJ_SITUACA := "L"
		M->TJ_CODBEM  := cBEMSOLI

		//�����������������������������������������������������������Ŀ
		//�Efetua o bloqueio de Ferramentas                           �
		//�������������������������������������������������������������
		Processa({ |lEnd| MNTA420FE() },STR0055) //"Aguarde ..Bloqueando Ferramentas..."

		//�����������������������������������������������������������Ŀ
		//�Efetua o bloqueio de Mao de Obras (FUNCIONARIO)            �
		//�������������������������������������������������������������
		Processa({ |lEnd| MNTA420FU() },STR0056) //"Aguarde ..Bloqueando Mao-de-Obra..."

		//�����������������������������������������������������������Ŀ
		//�Efetua o bloqueio de Especialistas (FUNCIONARIO)           �
		//�������������������������������������������������������������
		Processa({ |lEnd| MNTA420ES() },STR0057) //"Aguarde ..Bloqueando Especialidade.."

		//�����������������������������������������������������������Ŀ
		//�Efetua o bloqueio de Produtos                              �
		//�������������������������������������������������������������
		Processa({ |lEnd| MNTA420PR() },STR0058)  //"Aguarde ..Bloqueando Produto e Integra��o.."

		//�����������������������������������������������������������Ŀ
		//�Gera Solicitacao de compra para terceiros                  �
		//�������������������������������������������������������������
		Processa({ |lEnd| MNTA420TE() },STR0059) //"Aguarde ..Bloqueando Terceiros.."
	EndIf

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �NGTAFMNT3   � Autor � Elisangela Costa      � Data �13/06/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta a visualizacao da estrutura orgnanizacional             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAMNT                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function NGTAFMNT3()
	Local lTEMFACI  := NGINTESTORG()

	If Readvar() == "CBEMSOLI"

		If !lTEMFACI
			MsgInfo(STR0061,STR0008) //"O SIGAMNT n�o possui estrutura organizacional."#"NAO CONFORMIDADE"
			Return .F.
		EndIf

		aINTESOG := SGESTMOD(4) //Monta a estrutura organizacional do SIGAMNT

		If Len(aINTESOG) = 0
			Return .F.
		EndIf

		If aINTESOG[1,1]
			If INCLUI .Or. ALTERA
				If !NGCHKCODORG(aINTESOG[1,2])
					Return .F.
				EndIf
			EndIf

			dbSelectArea("TAF")
			dbSetOrder(2)
			dbSeek(xFilial("TAF")+'001'+SubStr(aIntEsOg[1,2],4,6))
			If TAF->TAF_INDCON == "1"
				cBEMSOLI := TAF->TAF_CODCON
			Else
				cBEMSOLI := TAF->TAF_CODNIV+Space(Len(TQB->TQB_CODBEM)-Len(TAF->TAF_CODNIV))
			EndIf
			oBEMSOLI:REFRESH()
		EndIf
	Else
		Return .T.
	EndIf

Return aIntEsOg[1][1]

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA295STS� Autor � Marcos Wagner Junior  � Data �02/04/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Busca a descricao do Status						                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MNTA295STS()

	cDesStatus := NGSEEK("TRD",cStatus,1,"TRD_NOME")

Return .T.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295AP    � Autor � Marcos Wagner Junior  � Data �18/01/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para aprovacao da Solicitacao de Servico               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
User Function MNT295AP()
	Local oDlgPro
	Local cCadastro := STR0070 //"Aprova��o da Solicita��o de Servi�o"
	Local oMenu
	Private lOk := .F.

	If !Empty(TQB->TQB_DTAPRO)
		dDatapro := TQB->TQB_DTAPRO
	Else
		dDatapro := dDataBase
	EndIf
	If !Empty(TQB->TQB_HRAPRO)
		cHora := TQB->TQB_HRAPRO
	Else
		cHora := Time()
	EndIf
	If !Empty(TQB->TQB_APROVA)
		cAprova := TQB->TQB_APROVA
	Else
		cAprova := If(Len(TQB->TQB_APROVA) > 15,cUsername,Substr(cUsuario,7,15))
	EndIf

	Define MsDialog oDlgPro Title cCadastro From 03.5,6 To 105,600 Pixel

	@ 020,010 Say OemToAnsi(RetTitSX3("TQB_DTAPRO")) Of oDlgPro Pixel COLOR CLR_HBLUE
	@ 018,049 Msget dDatapro  Picture '99/99/9999' SIZE 48,08 Of oDlgPro Pixel Valid VALDT(dDatapro) .and. MNTA295ATU() .and. Naovazio() HASBUTTON
	@ 020,150 Say OemToAnsi(RetTitSX3("TQB_HRAPRO")) Of oDlgPro Pixel COLOR CLR_HBLUE
	@ 018,187 Msget cHora    Picture '99:99'       SIZE 38,08 Of oDlgPro Pixel Valid (If(!Empty(cHora),NgValHora(cHora,.T.),.T.) .and. MNTA295ATU())

	@ 033,010 Say OemToAnsi(RetTitSX3("TQB_APROVA")) Of oDlgPro Pixel COLOR CLR_HBLUE
	@ 031,049 Msget cAprova  Picture '@!'          SIZE 48,08 Of oDlgPro Pixel When .F.

	NgPopUp(@AsMenu,@oMenu)
	oDlgPro:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlgPro)}
	Activate Dialog oDlgPro On Init(EnchoiceBar(oDlgPro,{|| If(MNT295OK(),oDlgPro:End(),lOk := .F.)},{|| oDlgPro:End()})) Centered

	If lOk
		MNTA295GOS()
	EndIf

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA295ATU  � Autor � Marcos Wagner Junior  � Data �18/01/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se Data/Hora digitados sao maiores que do sistema    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MNTA295ATU()

	If !Empty(dDatapro) .And. !Empty(cHora)
		If dDatapro = dDATABASE
			If cHora > TIME()
				Help(" ",1,STR0035,,STR0071,3,1) //"ATENCAO"###"Data/Hora digitados n�o podem ser maiores que Data/Hora atuais."
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295OK    � Autor � Marcos Wagner Junior  � Data �18/01/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se todos campos foram digitados                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MNT295OK()

	If Empty(dDatapro)
		Help(" ",1,STR0035,,STR0072,3,1)  //"ATENCAO"###"Data Aprova��o n�o pode ser vazia."
		Return .F.
	EndIf
	If Empty(cHora)
		Help(" ",1,STR0035,,STR0073,3,1)  //"ATENCAO"###"Hora Aprova��o n�o pode ser vazio."
		Return .F.
	EndIf

	dbSelectArea("TQB")
	dbSetOrder(01)
	dbSeek(TQB->TQB_FILIAL+TQB->TQB_SOLICI)
	RecLock("TQB",.F.)
	TQB->TQB_DTAPRO := dDatapro
	TQB->TQB_HRAPRO := cHora
	TQB->TQB_APROVA := cAprova
	TQB->TQB_SOLUCA := 'L'
	MsUnLock("TQB")
	lOk := .T.

Return .T.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295CA    � Autor � Marcos Wagner Junior  � Data �25/05/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Cancela a SS									                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
User Function MNT295CA()
	Local nOpcac := 0
	Local oMenu
	Local oDlgC
	cOBS := ''

	If Empty(TQB->TQB_ORDEM)
		Define MsDialog oDlgC Title STR0074 From 03.5,6 To 134,563 Pixel //"Cancelamento da Solicita��o de Servi�o"

		@ 007,010 Say OemToAnsi(STR0075) Of oDlgC Pixel COLOR CLR_HBLUE  //"Motivo Cancelamento:"
		@ 005,067 Get oOBS Var cOBS Of oDlgC Multiline Size 200,40 Pixel Valid !Empty(cOBS)

		Define sButton oBtOk  from 050,200 type 1 action (nOpcac := 1, oDlgC:End()) enable of oDlgC pixel
		Define sButton oBtCan from 050,235 type 2 action (nOpcac := 0, oDlgC:End()) enable of oDlgC pixel

		NgPopUp(@AsMenu,@oMenu)
		oDlgC:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlgC)}
		Activate MsDialog oDlgC Centered

		If nOpcac = 1
			dbSelectArea("TQB")
			MSMM(,,,cOBS,1,,,"TQB","TQB_CODMSS")
			RecLock("TQB",.F.)
			TQB->TQB_SOLUCA := 'C'
			MsUnLock("TQB")
		EndIf
		EvalTrigger()
	Else
		MsgStop(STR0033,STR0035)//"Existe ordem de servico para a solicitacao.."##"Aten��o"
	EndIf

Return .T.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295PA    � Autor � Marcos Wagner Junior  � Data �26/06/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta tela de Parametros					                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
User Function MNT295PA()
	Local cPerg := 'MNT29A'

	dbSelectArea("SX1")
	dbSetOrder(01)
	If !dbSeek(cPerg+"01")
		aPerg := {}
		AAdd(aPerg, {STR0076,"N",01,0,"NaoVazio()","","C",STR0077,STR0078,STR0079,STR0080})//"Prioridade     ?"###"Program�vel"###"Urg�ncia"###"Emerg�ncia"###"Todas"
		AAdd(aPerg, {STR0081,"N",01,0,"NaoVazio()","","C",STR0082,STR0083,STR0084})//"Situa��o       ?"###"Aguard. An�lise"###"Em Andamento"###"Lib./Aprovada"
		NgChkSx1(cPerg,aPerg)
	EndIf

	Pergunte(cPerg,.T.)

	ccondicao := 'TQB->TQB_FILIAL = "'+ xFilial("TQB")+'"'+'.And. '
	If MV_PAR02 = 1
		cPar02 := 'A'
	ElseIf MV_PAR02 = 2
		cPar02 := 'D'
	ElseIf MV_PAR02 = 3
		cPar02 := 'E'
	ElseIf MV_PAR02 = 4
		cPar02 := 'C'
	ElseIf MV_PAR02 = 5
		cPar02 := 'L'
	EndIf
	cCondicao += 'TQB->TQB_SOLUCA = "'+cPar02+'"'
	If MV_PAR01 <> 4
		cCondicao += ' .And. TQB->TQB_PRIORI = "'+AllTrim(Str(MV_PAR01))+'"'
	EndIf

	dbSelectArea("TQB")
Return .T.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295ESP   � Autor � Marcos Wagner Junior  � Data �16/07/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Filtra apenas servicos do tipo Corretivos                     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
User Function MNT295ESP()
	Local aOldArea := GetArea()

	If FunName() = 'MNTA295'
		dbSelectArea('STE')
		dbSetOrder(1)
		If dbSeek(xFilial('STE')+ST4->T4_TIPOMAN)
			If STE->TE_CARACTE = 'C'
				RestArea(aOldArea)
				Return .T.
			Else
				RestArea(aOldArea)
				Return .F.
			EndIf
		Else
			RestArea(aOldArea)
			Return .F.
		EndIf
	EndIf

Return .T.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295DE    � Autor � Marcos Wagner Junior  � Data �05/10/2007���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Faz o 'gatilho' do Estado Operacional	                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
User Function MNT295DE()

	If !Empty(cESTADO)
		cNOMESTADO := NGSEEK("ZZJ",cESTADO,1,"ZZJ_DESTAD")
	EndIf

Return .T.
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA295STF  � Autor � Marcos Wagner Junior  � Data �18/01/2008���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Procura se ha uma Manutencao para o Bem com o Servico inform. ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MNTA295STF()

	Local oDlgP, oMenu
	Local aCpoBrw  := {}
	Local aOldArea := GetArea()
	Local nQtde    := 0
	Local lRet     := .T.
	Local oTmpTbl1

	Private cTRBB295 	 := IIf(Type("cTRBB295") == "U", GetNextAlias(), cTRBB295)
	Private lInverte     := .F.
	Private cMarca       := GetMark()
	Private lSelecionado := .F.

	aDBF :=	{{"OK"    ,"C",02,0},;
			 {"SEQREL","C",03,0},;
			 {"MANUTE","C",40,0},;
			 {"TIPO"  ,"C",20,0},;
			 {"TEMPO" ,"N",03,0},;
			 {"UNIDAD","C",10,0},;
			 {"CONTAD","N",06,0}}

	//Intancia classe FWTemporaryTable
	oTmpTbl1:= FWTemporaryTable():New( cTRBB295, aDBF )
	//Adiciona os Indices
	oTmpTbl1:AddIndex( "Ind01" , {"SEQREL"} )
	//Cria a tabela temporaria
	oTmpTbl1:Create()

	aAdd(aCpoBrw,{"OK"    ,," "    ,"@!" })
	aAdd(aCpoBrw,{"SEQREL",,STR0090,"@!" })         //"Sequencia"
	aAdd(aCpoBrw,{"MANUTE",,STR0091,"@!" })         //"Manuten��o"
	aAdd(aCpoBrw,{"TIPO"  ,,STR0092,"@!" })         //"Tipo"
	aAdd(aCpoBrw,{"TEMPO" ,,STR0093,"999"})         //"Tempo"
	aAdd(aCpoBrw,{"UNIDAD",,STR0094,"@!" })         //"Unidade"
	aAdd(aCpoBrw,{"CONTAD",,STR0095,"@E 999,999"} ) //"Contador"

	dbSelectArea("STF")
	dbSetOrder(01)
	If dbSeek(xFilial("STF")+cBEMSOLI+cSERVICO)
		While !Eof() .And. cBEMSOLI == STF->TF_CODBEM .And. cSERVICO == STF->TF_SERVICO
			dbSelectArea(cTRBB295)
			RecLock(cTRBB295,.T.)
			(cTRBB295)->SEQREL := STF->TF_SEQRELA
			(cTRBB295)->MANUTE := STF->TF_NOMEMAN
			If STF->TF_TIPACOM = 'T'
				(cTRBB295)->TIPO := STR0093 //"Tempo"
			ElseIf STF->TF_TIPACOM = 'C'
				(cTRBB295)->TIPO := STR0095 //"Contador"
			ElseIf STF->TF_TIPACOM = 'A'
				(cTRBB295)->TIPO := STR0096 //"Tempo/Contador"
			ElseIf STF->TF_TIPACOM = 'P'
				(cTRBB295)->TIPO := STR0097 //"Producao"
			ElseIf STF->TF_TIPACOM = 'F'
				(cTRBB295)->TIPO := STR0098 //"Contador Fixo"
			ElseIf STF->TF_TIPACOM = 'S'
				(cTRBB295)->TIPO := STR0099 //"Segundo Contador"
			EndIf
			(cTRBB295)->TEMPO  := STF->TF_TEENMAN
			If STF->TF_UNENMAN = 'D'
				(cTRBB295)->UNIDAD := STR0100 //"D=Dia(s)"
			ElseIf STF->TF_UNENMAN = 'S'
				(cTRBB295)->UNIDAD := STR0101 //"S=Semana(s)"
			ElseIf STF->TF_UNENMAN = 'M'
				(cTRBB295)->UNIDAD := STR0102 //"M=Mes(es)"
			EndIf
			(cTRBB295)->CONTAD := STF->TF_INENMAN
			nQtde++
			cSequen := (cTRBB295)->SEQREL
			If(lBem,cPriorid := STF->TF_PRIORID,) // 027355: Se for um bem, assume a prioridade da Manuten��o.
			MsUnLock(cTRBB295)
			dbSelectArea("STF")
			dbSkip()
		End
	Else
		cSequen := "0"
		lRet := .F.
	EndIf

	nOpcax := 0
	If nQtde > 1
		dbSelectArea(cTRBB295)
		dbGoTop()
		DEFINE MsDialog oDlgP TITLE STR0103+AllTrim(cBEMSOLI)+" - "+SubStr(cNOMBEMS,1,20)+STR0104+cSERVICO FROM 000,000 To 439,750 PIXEL //"Manuten��es do Bem: "###" / Servi�o: "

		oMark                     := MsSelect():New(cTRBB295,"OK",,aCpoBrw,@lInverte,@cMarca,{030,000,220,376})
		oMark:oBrowse:lHasMark    := .T.
		oMark:oBrowse:lCanAllMark := .F.
		oMark:bMark               := { || MNA295MA(cMarca) }

		NgPopUp(@AsMenu,@oMenu)
		oMark:oBrowse:bRClicked := {|o,x,y| oMenu:Activate(x,y,oDlgP)}
		oDlgP:bRClicked         := { |o,x,y| oMenu:Activate(x,y,oDlgP)}
		Activate MsDialog oDlgP ON INIT EnchoiceBar(oDlgP,{|| IIf(lSelecionado,(nOpcax:=1,oDlgP:End()),)},{||nOpcax:=0,oDlgP:End()}) Center
		If nOpcax = 0
			cSERVICO := Space(06)
		EndIf
	EndIf

	oTmpTbl1:Delete()
	RestArea(aOldArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    | MNA295MA | Autor � Marcos Wagner Junior  � Data �18/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para marcar o item selecionado e atualizar os dados  ���
���          �no rodape.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNA295MA(cMarca)

	Local cFieldMarca := "OK"

	If IsMark(cFieldMarca,cMarca,lInverte)
		cSequen := (cTRBB295)->SEQREL
		nRecno := Recno()
		nCont := 0
		dbSelectArea(cTRBB295)
		DbGotop()
		Do While !Eof()
			If !Empty((cTRBB295)->OK)
				nCont++
				If cSequen != (cTRBB295)->SEQREL
					cSequenNew := (cTRBB295)->SEQREL
				EndIf
			EndIf
			Dbskip()
		EndDo
		If nCont > 1
			dbSelectArea(cTRBB295)
			dbSetOrder(01)
			If dbSeek(cSequenNew)
				RecLock(cTRBB295,.F.)
				(cTRBB295)->OK := Space(02)
				MsUnLock(cTRBB295)
			EndIf
		EndIf
		lSelecionado := .T.
		DbGoTo(nRecno)
		oMark:oBrowse:Refresh()
	Else
		lSelecionado := .F.
		cSequen := Space(03)
		oMark:oBrowse:Refresh()
	EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295ETA � Autor � Elisangela Costa      � Data � 19-06-08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Consiste o codigo da etapa                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT295ETA(cETAPA)

	Local lRet := .T., OldAli := Alias()
	Local QTD := 0
	Local nDESCR  := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_NOMETAP" })

	dbSelectArea("TPA")
	If !dbSeek(xFILIAL("TPA")+ cETAPA)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf

	nTAREFA := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_TAREFA" })
	nETAPA  := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_ETAPA" })
	If Len(aCOLS) > 0 .And. lRET
		If nTAREFA == 0
			aEVAL(aCOLS,{|x| If(x[nETAPA] == M->TQ_ETAPA,QTD++,NIL)})
		Else
			aEVAL(aCOLS,{|x| If(x[nTAREFA] == aCols[n][nTAREFA] .And. x[nETAPA] == M->TQ_ETAPA,QTD++,NIL)})
		EndIf
		If QTD > 0
			Help(" ",1,"JAGRAVADO")
			lRet := .F.
		EndIf
	EndIf

	aCols[n][nDESCR] := TPA->TPA_DESCRI

Return lRET

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295GRVE � Autor � Elisangela Costa      � Data �19/06/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava as etapas da manutencao preventiva manual             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NG295GRVE()

	Local nCOL
	Local nHEA
	Local nULT := Len(aGETETA[1])
	Local cCondGRVE
	Private nColGRVE

	nTAREFA := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_TAREFA" })
	nETAPA  := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_ETAPA" })

	M->TQ_PLANO := "000001"

	If nTAREFA == 0
		cCondGRVE := "Empty(aGETETA[nColGRVE][nETAPA])"
	Else
		cCondGRVE := "Empty(aGETETA[nColGRVE][nTAREFA]) .Or. Empty(aGETETA[nColGRVE][nETAPA])"
	EndIf

	dbSelectArea("STQ")
	dbSetOrder(01)
	ProcRegua(Len(aGETETA))
	For nCOL := 1 to Len(aGETETA)
		IncProc()

		If nTAREFA > 0
			//checa se tarefa esta ativa
			If !f330TRFAT(M->TJ_CODBEM,M->TJ_SERVICO,M->TJ_SEQRELA,aGETETA[nCOL][nTAREFA])
				Loop
			EndIf

			M->TQ_TAREFA := aGETETA[nCOL][nTAREFA]
		Else
			M->TQ_TAREFA := "0     "
		EndIf

		M->TQ_ETAPA := aGETETA[nCOL][nETAPA]

		nColGRVE := nCOL

		If &(cCondGRVE)
			Loop
		EndIf

		If aGETETA[nCOL][nULT]
			If dbSeek( xFilial("STQ") + m->TJ_ORDEM + m->TQ_PLANO + m->TQ_TAREFA + m->TQ_ETAPA )
				RecLock("STQ", .F.)
				DbDelete()
				MsUnLock("STQ")
			EndIf
			Loop
		EndIf

		If !dbSeek( xFilial("STQ") + m->TJ_ORDEM + m->TQ_PLANO + m->TQ_TAREFA + m->TQ_ETAPA )
			RecLock("STQ",.T.)
			STQ->TQ_FILIAL  := xFilial("STQ")
			STQ->TQ_ORDEM   := M->TJ_ORDEM
			STQ->TQ_PLANO   := M->TQ_PLANO
			If nTAREFA == 0
				STQ->TQ_TAREFA  := M->TQ_TAREFA
			EndIf
		Else
			RecLock("STQ",.F.)
		EndIf
		For nHEA := 1 to Len(aHEAETA)
			If aHEAETA[nHEA][10] != "V"
				xx := "STQ->" + aHEAETA[nHEA][2]
				yy := "M->" + aHEAETA[nHEA][2]
				yy := aGETETA[nCOL][nHEA]
				&xx. := yy
			EndIf
		Next nHEA
		MsUnLock("STQ")
	Next nCOL
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNT295VALE� Autor � Elisangela Costa      � Data �19/06/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao dos itens da acols de etapas                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNT295VALE(nTIPVA)

	Local nCOL
	Local cCondEta1
	Local cCondEta2
	Private nCOLAux := n

	nTAREFA := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_TAREFA" })
	nETAPA  := aSCAN(aHEAETA, {|x| AllTrim(Upper(X[2])) == "TQ_ETAPA" })
	If nTAREFA == 0
		cCondEta1 := "Empty(aCols[nCOLAux][nETAPA]) .Or. Empty(aCols[nCOLAux][nETAPA])"
		cCondEta2 := "Empty(aCols[nCOLAux][nETAPA]) .Or. Empty(aCols[nCOLAux][nETAPA])"
	Else
		cCondEta1 := "Empty(aCols[nCOLAux][nTAREFA]) .Or. Empty(aCols[nCOLAux][nETAPA]) .Or. (Empty(aCols[nCOLAux][nTAREFA]) .And. Empty(aCols[nCOLAux][nETAPA]))"
		cCondEta2 := "Empty(aCols[nCOLAux][nTAREFA]) .Or. Empty(aCols[nCOLAux][nETAPA]) .Or. (Empty(aCols[nCOLAux][nTAREFA]) .And. Empty(aCols[nCOLAux][nETAPA]))"
	EndIf

	If nTIPVA == 1
		If !aCols[n][Len(aCols[n])]
			If &(cCondEta1)
				MsgStop(STR0106,STR0035)  //"C�digo da tarefa ou etapa n�o foi informado!" #"ATEN��O"
				Return .F.
			EndIf
		EndIf
	Else
		For nCOL := 1 To Len(aCols)
			nCOLAux := nCOL
			If !aCols[nCOL][Len(aCols[nCOL])]
				If &(cCondEta2)
					MsgStop(STR0107+" "+Alltrim(Str(nCOL,3)),STR0035)  //"C�digo da tarefa ou etapa n�o foi informado! Item" #"ATEN��O"
					Return .F.
				EndIf
			EndIf
		Next nCOL
	EndIf

	NGSETIFARQUI("STQ","F",1)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA295MOS� Autor � Rafael Diogo Richter  � Data �26/06/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Browse para cadastro de multiplas OS's                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA295MOS()

	Local aRotinaOld := aClone(aRotina)
	Local aDBFC 	 := {}
	Local oTmpTbl2

	M->TQB_CODBEM := TQB->TQB_CODBEM
	NG280BEMLOC(TQB->TQB_TIPOSS)

	If TQB->TQB_TIPOSS == "B" .And. !NGIFDBSEEK("SH7",NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CALENDA"),1)
		Help(" ",1,"NGCALENBEM",,CHR(13) + OemToAnsi(STR0123) + NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CALENDA") ,3,0)  //"Calend�rio: "
		Return .F.
	EndIf

	If TQB->TQB_SOLUCA <> "D"
		MsgInfo(STR0007, STR0008) //"A Solicita��o de Servi�o n�o est� distribu�da!"###"NAO CONFORMIDADE"
		Return
	EndIf

	aRotina := {{STR0042,"MNA295VOS" , 0, 2, 0},; //"Visualizar"
				{STR0109,"MNTA295GOS", 0, 3, 0} } //"Incluir"

	cCadastro := OemtoAnsi(STR0114) //"Gera��o das OS's da Solicita��o de Servi�o"

	aAdd(aDBFC,{"SOLICI"  ,"C", 06,0})
	aAdd(aDBFC,{"ORDEM"   ,"C", 06,0})
	aAdd(aDBFC,{"PLANO"   ,"C", 06,0})
	aAdd(aDBFC,{"TIPOOS"  ,"C", 15,0})
	aAdd(aDBFC,{"CODBEM"  ,"C", 16,0})
	aAdd(aDBFC,{"NOMBEM"  ,"C", 20,0})
	aAdd(aDBFC,{"SERVICO" ,"C", 06,0})
	aAdd(aDBFC,{"NOMSERV" ,"C", 20,0})
	aAdd(aDBFC,{"CCUSTO"  ,"C", 09,0})
	aAdd(aDBFC,{"NOMCUST" ,"C", 20,0})
	aAdd(aDBFC,{"SEQRELA" ,"C", 03,0})
	aAdd(aDBFC,{"PRIORID" ,"C", 03,0})
	aAdd(aDBFC,{"TERMINO" ,"C", 01,0})

	//Intancia classe FWTemporaryTable
	oTmpTbl2:= FWTemporaryTable():New( cTRBC295, aDBFC )
	//Adiciona os Indices
	oTmpTbl2:AddIndex( "Ind01" , {"ORDEM","PLANO"} )
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	aTRBC := {{STR0115,"SOLICI" ,"C"	,06,0,"@!" },; //"Sol.Servico"
	{STR0116,"ORDEM"  ,"C"	,06,0,"@!" },; //"Ordem Serv."
	{STR0117,"PLANO"  ,"C"	,06,0,"@!" },; //"Plano Manut."
	{STR0118,"TIPOOS" ,"C"	,15,0,"@!" },; //"Tipo OS"
	{STR0012,"CODBEM" ,"C"	,16,0,"@!" },; //"Bem"
	{STR0119,"NOMBEM" ,"C"	,20,0,"@!" },; //"Nome do Bem"
	{STR0020,"SERVICO","C"	,06,0,"@!" },; //"Servico"
	{STR0120,"NOMSERV","C"	,20,0,"@!" },; //"Nome Servi�o"
	{STR0019,"CCUSTO" ,"C"	,09,0,"@!" },; //"Centro Custo"
	{STR0121,"NOMCUST","C"	,20,0,"@!" },; //"Nome C.Custo"
	{STR0090,"SEQRELA","C"	,03,0,"@!" },; //"Sequencia"
	{STR0111,"PRIORID","C"	,03,0,"@!" }} //"Prioridade"

	Processa({ |lEnd| MNA295TRBC() },STR0113) //"Aguarde... Carregando."

	DbSelectarea(cTRBC295)
	DbGotop()
	mBrowse(6,1,22,75,cTRBC295,aTRBC)

	oTmpTbl2:Delete()

	aRotina := aClone(aRotinaOld)
	cCadastro := OemtoAnsi(STR0001) //"Distribui��o e Geracao O.S. da Solicitacao Servico"

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNA295TRBC� Autor � Rafael Diogo Richter  � Data �26/06/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Processa e carrega o arquivo temporario.                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNA295TRBC()

	dbSelectArea("TT7")
	dbSetOrder(1)
	dbSeek(xFilial("TT7")+TQB->TQB_SOLICI)
	ProcRegua(RecCount())
	While !Eof() .And. TT7->TT7_FILIAL == xFilial("TT7") .And. TT7->TT7_SOLICI == TQB->TQB_SOLICI
		IncProc()
		If TT7->TT7_SITUAC == "C" .Or. TT7->TT7_TERMIN == "S"
			dbSelectArea("TT7")
			dbSkip()
			Loop
		EndIf

		dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek(xFilial("STJ")+TT7->TT7_ORDEM+TT7->TT7_PLANO)
			dbSelectArea(cTRBC295)
			Reclock(cTRBC295,.T.)
			(cTRBC295)->SOLICI  := TT7->TT7_SOLICI
			(cTRBC295)->ORDEM   := TT7->TT7_ORDEM
			(cTRBC295)->PLANO   := TT7->TT7_PLANO
			If STJ->TJ_TIPOOS == "B"
				(cTRBC295)->TIPOOS  := STR0012 //"Bem"
			Else
				(cTRBC295)->TIPOOS  := STR0013 //"Localizacao"
			EndIf
			(cTRBC295)->CODBEM  := STJ->TJ_CODBEM

			If STJ->TJ_TIPOOS == "B"
				dbSelectArea("ST9")
				dbSetorder(1)
				dbSeek(xFilial("ST9")+STJ->TJ_CODBEM)
				(cTRBC295)->NOMBEM  := SubStr(ST9->T9_NOME,1,20)
			Else
				dbSelectArea("TAF")
				dbSetorder(7)
				dbSeek(xFilial("TAF")+"X2"+STJ->TJ_CODBEM)
				(cTRBC295)->NOMBEM  := SubStr(TAF->TAF_NOMNIV,1,20)
			EndIf
			(cTRBC295)->SERVICO := STJ->TJ_SERVICO
			dbSelectArea("ST4")
			dbSetOrder(1)
			dbSeek(xFilial("ST4")+STJ->TJ_SERVICO)
			(cTRBC295)->NOMSERV := ST4->T4_NOME
			(cTRBC295)->CCUSTO  := STJ->TJ_CCUSTO
			dbSelectArea("CTT")
			dbSetOrder(1)
			dbSeek(xFilial("CTT")+STJ->TJ_CCUSTO)
			(cTRBC295)->NOMCUST  := CTT->CTT_DESC01
			(cTRBC295)->SEQRELA  := STJ->TJ_SEQRELA
			(cTRBC295)->PRIORID  := STJ->TJ_PRIORID
			(cTRBC295)->TERMINO  := STJ->TJ_TERMINO
			MsUnLock(cTRBC295)
		EndIf

		dbSelectArea("TT7")
		dbSkip()
	End

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNA295VOS � Autor � Rafael Diogo Richter  � Data �26/06/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Visualiza a Ordem de Servico.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNA295VOS()
	Local aOldRotina := aRotina

	aRotina := {{STR0041,"" 		 , 0, 1},; //"Pesquisar"
				{STR0042,"MNA295VOS" , 0, 2},; //"Visualizar"
				{STR0109,"MNTA295GOS", 0, 3},; //"Incluir"
				{STR0068,""          , 0, 4},; //"Alterar"
				{STR0110," "         , 0, 5}}  //"Excluir"

	dbSelectArea("STJ")
	dbSetOrder(01)
	dbSeek(xFilial("STJ")+(cTRBC295)->ORDEM+(cTRBC295)->PLANO)

	NGCAD01("STJ",Recno(),2)

	aRotina := aOldRotina
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �NG295SERV2� Autor � Inacio Luiz Kolling   � Data �10/02/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se informou o servico ao selecionar insumos/etapas ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NG295SERV2()
	If Empty(cSERVICO)
		Help(" ",1,STR0035,,STR0024+CRLF+CRLF+STR0020,3,1)
		Return .F.
	EndIf
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MNT295WHEN| Autor � Pedro Cardoso Furst   � Data �27/09/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se existe localizacao sem Centro de Custo			  |��
���          |Se tiver libera campo Centro de custo. se nao bloqueia      |��
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA295                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MNT295WHEN()
	Local lRet := lWhenCC
	If !lWhenCC
		dbSelectArea("TAF")
		dbSetOrder(8)
		If dbSeek(xFilial("TAF")+cBEMSOLI) .and. Empty(TAF->TAF_CCUSTO)
			lRet := .T.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA295CT()
Fun��o que carrega o nome do centro de trabalho e realiza as devidas
valida��es em rela��o ao Centro de Custo com Centro de Trabalho.
-> Se o Centro de Trabalho n�o estiver relacionado ao C.C � uma n�o
conformidade e sera exibida uma mensagem para o usu�rio.
-> Na consulta padr�o, foi criado um filtro para apenas filtar o(s)
Centro(s) de trabalho(s) relacionado(s).

@author Elynton Fellipe Bazzo
@since 18/03/2013
@version P10/P11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function MNTA295CT()

	Local aArea	:= GetArea()
	Local lRet	:= .T.
	cNomctra := NGSEEK( "SHB",cCentra,1,"SHB->HB_NOME" )

	If !Empty( cCentra )
		lRet := ExistCpo( "SHB", cCentra )
	Else
		lRet := .T.
	EndIf

	dbSelectArea( "SHB" )
	dbSetOrder( 01 ) //HB_FILIAL+HB_COD
	If dbSeek( xFilial("SHB") + cCentra )
		If AllTrim( SHB->HB_CC ) <> AllTrim( cCCUSTOQ ) // se o C.C for diferente do C.T
			MsgInfo( STR0132 ) //"O Centro de Trabalho informado n�o est� relacionado ao Centro de Custo."
			lRet := .F.
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MntWhenCont()
Fun��o que habilita os campos apenas quando o bem tiver contador,
Exemplo: Se o bem tiver apenas contador 1, somente os campos referente
a contador 1 ser� habilitado (Contador e Hora Cont. 1).

@author  Elynton Fellipe Bazzo
@since   29/04/2013
@version P11
@return  lRet
/*/
//---------------------------------------------------------------------
Static Function MntWhenCont( nTipo )

	Local lRet := .F.

	If nTipo == 1 // When contador 1
		lRet := If( NGSEEK( "ST9",cBEMSOLI,01,"ST9->T9_TEMCONT" ) == "S",.T.,.F. )
	ElseIf nTipo == 2 // When Contador 2
		lRet := NGIFDBSEEK( "TPE",cBEMSOLI,01,.F. )
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} Mnta295Wpar()
Fun��o que habilita os campos Dt.Par.Re.I. e Ho.Par.Re.I. apenas em ordem
de servi�o com o tipo de manuten��o Corretiva.

@author  Elynton Fellipe Bazzo
@since   30/04/2013
@version P11
@return  lRet
/*/
//---------------------------------------------------------------------
Static Function Mnta295Wpar()

	Local lRet := .F.

	dbSelectArea( "ST4" )
	dbSetOrder( 01 ) // T4_FILIAL+T4_SERVICO
	If dbSeek( xFilial( "ST4" )+cSERVICO )
		dbSelectArea("STE")
		dbSetOrder( 01 ) // TE_FILIAL+TE_TIPOMAN
		dbSeek( xFilial( "STE" )+ST4->T4_TIPOMAN )
		If STE->TE_CARACTE == "C"
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MntaValCont()
Fun��o que valida a consist�ncia da posi��o do contador com o limite.

@author  Elynton Fellipe Bazzo
@since   30/04/2013
@version P11
@return  lRet
/*/
//---------------------------------------------------------------------
Static Function MntaValCont()

	Local aArea		:= GetArea()
	Local lRet 		:= .F.
	Local cVar420 	:= ReadVar()

	If "NCONT1" $ cVar420
		lRet := If(NCONT1 > 0,CHKPOSLIM(cBEMSOLI,NCONT1,1),If(POSITIVO(),.T.,.F.))
	ElseIf "NCONT2" $ cVar420
		lRet := If( NCONT2 > 0,CHKPOSLIM(cBEMSOLI,NCONT2,2),If(POSITIVO(),.T.,.F.))
	EndIf


	RestArea( aArea )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} Mnta295HoDt()
Fun��o que valida a hora Ho.Par.Re.I e data Dt.Par.Re.I.

@author  Elynton Fellipe Bazzo
@since   30/04/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function Mnta295HoDt()

	If dDataPar == dDataBase
		If cHrPar > SubStr(Time(),1,5)
			MsgStop(STR0139) //"A "Ho.Par.Re.I" � maior que a hora atual."
			Return .F.
		EndIf
	ElseIf dDataPar > dDataBase
		MsgStop(STR0140)//"A "Dt.Par.Re.I." n�o pode ser maior que a data atual."
		Return .F.
	EndIf

Return .T.
