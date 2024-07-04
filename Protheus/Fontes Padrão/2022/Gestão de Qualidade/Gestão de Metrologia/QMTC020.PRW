#INCLUDE "PROTHEUS.CH"
#INCLUDE "FOLDER.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "QPAGES.CH"
#INCLUDE "QMTC020.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMTC020	³ Autor ³ Fernando Godoy		³ Data ³ 3/8/1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta a Situaçao de um Instrumento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nil 														  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Modulo de Metrologia										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³String	 ³ Ultimo utilizado -> 00									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Antonio A.    ³04/08/99³  --	 ³ Inclusao do campo Precisao nas Medicoes³±±
±±³              ³        ³      ³ e retirada do campo Precisao na Pag. 3 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Antonio A.    ³30/09/99³  --	 ³ Inclusao do campo No. do Certificado   ³±±
±±³              ³        ³      ³ e da SetaPilha().                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTC020()
Local oDlgIns
Local oBmp
Local oGrp
Local oGrp1
Local oFolder
Local oTree
Local oQPages
Local oQPages2
Local oMtInstr
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oSay11
Local oSay17
Local oBmp1
Local oBmp2
Local oBmp3
Local oBmp4
Local oBmp5
Local oBmp6
Local oBmp7
Local oBmp8
Local oBmp9
Local oBmp10
Local oBmp11
Local oBmp12
Local oBmp13
Local oIcon
Local oMtRevi
Local oSay12
Local oSay13
Local oSay14
Local oSay15
Local oSay16
Local oSay18
Local oSay19
Local oSay20
Local oBtn1
Local oBtn2
Local oBtn3
Local oLbx
Local aArea 		:= GetArea()
Local nOpt			:= 1
Local cMtInstr 	:= CriaVar("QM2_INSTR")
Local cMtStatus	:= ""
Local dMtProxDtC	:= ""
Local cMtRR 		:= ""
Local cMtIncEnc	:= ""
Local cMtErrSis	:= ""
Local dMtStatus	:= Ctod("  /  /  ","DDMMYY")
Local dMtProxCal	:= Ctod("  /  /  ","DDMMYY")
Local dMtRR 		:= Ctod("  /  /  ","DDMMYY")
Local dMtIncEnc
Local dMtErrSis
Local odMtStatus
Local odMtProxCal
Local odMtRR
Local odMtIncEnc
Local odMtErrSis
Local cMtRevi		:= CriaVar("QM2_REVINS",.F.)
Local aDatas		:= {}
Local cLbx			:= ""
Local cMtFabr		:= ""
Local cMtProCal	:= ""
Local cMtFam		:= ""
Local cMtFreq		:= ""
Local cMtLocal 	:= ""
Local cMtResp		:= ""
Local cMtCCusto   := ""
Local cMtStatus2  := ""
Local oMtFabr
Local oMtProCal
Local oMtFam
Local oMtFreq
Local oMtLocal
Local oMtStatus2
Local oMtCCusto
Local oMtResp
Local cBmp1 		:= "LBNO"
Local cBmp2 		:= "LBNO"
Local cBmp3 		:= "LBNO"
Local cBmp4 		:= "LBNO"
Local cBmp5 		:= "LBNO"
Local cBmp6 		:= "LBNO"
Local cBmp7 		:= "LBNO"
Local cBmp8 		:= "LBNO"
Local cBmp9 		:= "LBNO"
Local cBmp10		:= "LBNO"
Local cBmp11		:= "LBNO"
Local cBmp12		:= "LBNO"
Local cBmp13		:= "LBNO"
Local cMtDepto 	:= ""
Local cMtUsuario	:= ""
Local dMtData		:= Ctod("  /  /  ","DDMMYY")
Local oMtStatus
Local oMtProxDtC
Local oMtRR
Local oMtIncEnc
Local oMtErrSis
Local oBrw
Local oBrw1
Local oBrw2
Local aMedicoes	:= Array(2,4)
Local aTree 		:= {}
Local oMtCodEsc
Local oMtRevEsc
Local oMtEscInc
Local oMtEscErr
Local oMtEscTol
Local oMtEscPro
Local oMtEscExa
Local oMtEscAce
Local oMtEscAde
Local oMtEscSta
Local oMtEscRed
Local oMtEscCer
Local cMtCodEsc	:= ""
Local cMtRevEsc	:= ""
Local cMtEscInc	:= ""
Local cMtEscErr	:= ""
Local cMtEscTol	:= ""
Local cMtEscPre   := ""
Local cMtEscExa	:= ""
Local cMtEscAce	:= ""
Local cMtEscAde	:= ""
Local cMtEscSta	:= ""
Local cMtEscRed	:= ""
Local cMtEscCer   := ""
Local cMtCodPad	:= ""
Local cMtRevPad	:= ""
Local cMtPadInc	:= ""
Local cMtPadErr	:= ""
Local cMtPadExa	:= ""
Local cMtPadAce	:= ""
Local cMtPadAde	:= ""
Local cMtPadSta	:= ""
Local oMtCodPad
Local oMtRevPad
Local oMtPadInc
Local oMtPadErr
Local oMtPadExa
Local oMtPadAce
Local oMtPadAde
Local oMtPadSta
Local nPosDEsc := 1
Local nPosDPad := 2
Local nPosEsc	:= 3
Local nPosPad	:= 4
Local nPosMed	:= 5
Local nPosCar	:= 6
Local nPosLau  := 7
Local oIcon2
Local oIcon3
Local oQPages3
Local oSyCodEsc
Local oSyRevEsc
Local oSyEscInc
Local oSyEscErr
Local oSyEscTol
Local oSyEscPre
Local oSyEscExa
Local oSyEscAce
Local oSyEscAde
Local oSyEscSta
Local oSyEscRed
Local oSyEscCer
Local oSyCodPad
Local oSyRevPad
Local oSyPadInc
Local oSyPadErr
Local oSyPadExa
Local oSyPadAce
Local oSyPadAde
Local oSyPadSta
Local nPosSec	:= 8
Private cSeql := "00"
Private lDtQt := .F.

SetaPilha()

DEFINE MSDIALOG oDlgIns FROM 63,0 TO 460,635 PIXEL TITLE STR0001 OF oMainWnd //"Consulta a Instrumentos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do metodo folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 14, 1 FOLDER oFolder OF oDlgIns PROMPTS STR0002,STR0003,STR0004; //"&Dados Operacionais"###"&Características"###"&Situação Atual"
		PIXEL OPTION 1 SIZE 316,165

	oFolder:align:= CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³			 ³
	//³ PAGINA 1 ³
	//³			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	@ 009,010 SAY STR0005 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont //"Código do Instrumento:"
	@ 009,148 SAY STR0006 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 25,8 //"Revisão:"

	@ 009,070 MSGET oMtInstr VAR cMtInstr PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont;
		SIZE 75,8 F3 "QM2" PICTURE "@!" ;
		VALID C020Valid( "1",@cMtInstr,@cMtRevi,oFolder,oTree,oLbx,;
			  oBtn1,oQPages2,oSay17,@cLbx,aDatas,oMtInstr,oMtRevi,oBtn3,@dMtData)

	@ 009,173 MSGET oMtRevi VAR cMtRevi PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont PICTURE "@!" SIZE 20,8;
		VALID C020Valid( "2",@cMtInstr,@cMtRevi,oFolder,oTree,oLbx,;
			  oBtn1,oQPages2,oSay17,@cLbx,aDatas,oMtInstr,oMtRevi,oBtn3,@dMtData)

	@ 008,197 BUTTON oBtn3 PROMPT ">>" PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 15,9;
		ACTION C020ActBut( @cMtInstr,@cMtRevi,oFolder,oTree,oLbx,;
		oBtn1,oQPages2,oSay17,@cLbx,aDatas,oMtInstr,oMtRevi,oBtn3,;
		@cMtFabr,@cMtProCal,@cMtFam,@cMtFreq,@cMtLocal,@cMtResp,@cMtCCusto,@cMtStatus2,;
		oMtFabr,oMtProCal,oMtFam,oMtFreq,oMtLocal,oMtStatus2,oMtResp,oMtCCusto,oBmp,;
		@cBmp1,@cBmp2,@cBmp3,@cBmp4,@cBmp5,@cBmp6,@cBmp7,@cBmp8,;
		@cBmp9,@cBmp10,@cBmp11,@cBmp12,@cBmp13,oBmp1,oBmp2,oBmp3,;
		oBmp4,oBmp5,oBmp6,oBmp7,oBmp8,oBmp9,oBmp10,oBmp11,oBmp12,;
		oBmp13,@cMtDepto,@cMtUsuario,oSay13,oSay14,dMtData,oSay18,;
		oSay19,oMtStatus,oMtProxDtC,oMtRR,oMtIncEnc,oMtErrSis,;
		@cMtStatus,@dMtProxDtC,@cMtRR,@cMtIncEnc,@cMtErrSis,;
		odMtStatus,odMtProxCal,odMtRR,odMtIncEnc,odMtErrSis,;
		@dMtStatus,@dMtProxCal,@dMtRR,@dMtIncEnc,@dMtErrSis,;
		oQPages)

	@ 021,010 SAY STR0007 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 30,8  //"Fabricante:"
	@ 021,110 SAY STR0008 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 42,8  //"Proc.Calibraci¢n:"
	@ 032,010 SAY STR0009 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 20,8  //"Familia:"
	@ 032,110 SAY STR0010 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 42,8  //"Freq. Calibração:"
	@ 043,010 SAY STR0011 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 32,8  //"Localização/Depto:"
	@ 043,110 SAY STR0012 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 36,8  //"Responsável:"
	@ 054,010 SAY STR0065 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 42,8  // "Centro de Custo:"
	@ 054,110 SAY STR0025 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 20,8  // "Status:"

	@ 021,042 SAY oMtFabr	 PROMPT cMtFabr    PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 68,8 COLOR CLR_BLUE
	@ 021,154 SAY oMtProCal  PROMPT cMtProCal  PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 70,8 COLOR CLR_BLUE
	@ 032,032 SAY oMtFam 	 PROMPT cMtFam	    PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 73,8 COLOR CLR_BLUE
	@ 032,154 SAY oMtFreq	 PROMPT cMtFreq    PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 70,8 COLOR CLR_BLUE
	@ 043,044 SAY oMtLocal	 PROMPT cMtLocal   PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 65,8 COLOR CLR_BLUE
	@ 043,148 SAY oMtResp	 PROMPT cMtResp    PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 68,8 COLOR CLR_BLUE
	@ 054,054 SAY oMtCCusto  PROMPT cMtCCusto  PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 55,8 COLOR CLR_BLUE
	@ 054,132 SAY oMtStatus2 PROMPT cMtStatus2 PIXEL OF oFolder:aDialogs[1] FONT oDlgIns:oFont SIZE 70,8 COLOR CLR_BLUE

	@ 003,236 REPOSITORY oBmp SIZE 73,64 OF oFolder:aDialogs[1] PIXEL NOBORDER WHEN .F.

	ShowBitmap(oBmp,"NADA","INSPAD")
	oBmp:SetColor(GetSysColor(15),GetSysColor(15))
	oBmp:lStretch	:= .T.
	oBmp:lVisible	:= .T.

//	BsBevel(005/2,470/2,135/2,618/2,oFolder:aDialogs[1])
	@ 002,002 TO 070,230 OF oFolder:aDialogs[1] PIXEL

	@ 072/2,005/2 QPages oQPages2 DIALOGS "1","2" SIZE 308/2,78/2 OF oFolder:aDialogs[1] OPTION nOpt ACTIVE {.T.,.T.,.T.} FONT oDlgIns:oFont

	@ 001,002 SAY oSay17 PROMPT STR0013 SIZE 140,15 PIXEL OF oQPages2:aDialogs[1] FONT oDlgIns:oFont //"Escolha abaixo a Data da Calibração"
	If Empty(cMtRevi)
		oSay17:Disable()
	Endif

	@ 010,002 LISTBOX oLbx VAR cLbx ITEMS aDatas PIXEL SIZE 090,055;
		OF oQPages2:aDialogs[1] FONT oDlgIns:oFont ;
		WHEN !Empty(cMtRevi) ON CHANGE (C020Pag2(@cBmp1,@cBmp2,@cBmp3,@cBmp4,@cBmp5,;
		@cBmp6,@cBmp7,@cBmp8,@cBmp9,@cBmp10,@cBmp11,@cBmp12,@cBmp13,;
		@cMtInstr,@cMtRevi,oBmp1,oBmp2,oBmp3,oBmp4,oBmp5,oBmp6,oBmp7,;
		oBmp8,oBmp9,oBmp10,oBmp11,oBmp12,oBmp13,@cMtDepto,@cMtUsuario,;
		oSay13,oSay14,dMtData,oSay18,oSay19,cMtFam,@cLbx),C020Pag3(oMtStatus,oMtProxDtC,oMtRR,oMtIncEnc,oMtErrSis,;
		@cMtStatus,@dMtProxDtC,@cMtRR,@cMtIncEnc,@cMtErrSis,;
		odMtStatus,odMtProxCal,odMtRR,odMtIncEnc,odMtErrSis,;
		@dMtStatus,@dMtProxCal,@dMtRR,@dMtIncEnc,@dMtErrSis,@cMtInstr,;
		@cMtRevi,dMtData,cSeql,@cLbx)) ON DBLCLICK Eval(oBtn1:bAction)

	@ 001,002 SAY oSay20 PROMPT STR0014+" "+Alltrim(cLbx) SIZE 90,15 PIXEL OF oQPages2:aDialogs[2] FONT oDlgIns:oFont //"Medicoes de: "

	DEFINE DBTREE oTree FROM 012, 002 TO 060, 090 CARGO OF oQPages2:aDialogs[2];
		ON CHANGE C020ChgTree(cMtInstr,cMtRevi,oMtCodEsc,oMtRevEsc,oMtEscInc,;
		oMtEscErr,oMtEscTol,oMtEscPre,oMtEscExa,oMtEscAce,oMtEscAde,oMtEscSta,oMtEscRed,oMtEscCer,;
		@cMtCodEsc,@cMtRevEsc,@cMtEscInc,@cMtEscErr,@cMtEscTol,@cMtEscPre,@cMtEscExa,@cMtEscAce,;
		@cMtEscAde,@cMtEscSta,@cMtEscRed,@cMtEscCer,@cMtCodPad,@cMtRevPad,@cMtPadInc,@cMtPadErr,;
		@cMtPadExa,@cMtPadAce,@cMtPadAde,@cMtPadSta,oMtCodPad,oMtRevPad,oMtPadInc,;
		oMtPadErr,oMtPadExa,oMtPadAce,oMtPadAde,oMtPadSta,@cLbx,@aMedicoes,;
		@aTree,oBrw,oTree,oQPages,nPosCar,nPosMed,nPosPad,nPosEsc,oLbx,nPosLau,;
		oSyCodEsc,oSyRevEsc,oSyEscInc,oSyEscErr,oSyEscTol,oSyEscPre,oSyEscExa,oSyEscAce,;
		oSyEscAde,oSyEscSta,oSyEscRed,oSyEscCer,oSyCodPad,oSyRevPad,oSyPadInc,oSyPadErr,;
		oSyPadExa,oSyPadAce,oSyPadAde,oSyPadSta,oBrw1,oBrw2,oBrw3,nPosSec)

	@ 065,002 BUTTON oBtn1 PROMPT STR0015 SIZE 90,10 PIXEL ; //"Mostrar Medições >>"
		OF oQPages2:aDialogs[1] FONT oDlgIns:oFont ;
		ACTION (oSay20:Refresh(),C020CarMed(@aTree,@cLbx,cMtInstr,cMtRevi),;
		C020MoTree(oTree,@aTree,nPosCar,nPosDEsc,nPosDPad,oQPages,oQPages2,cMtInstr),oQPages2:SetOption(2))

	oBtn1:Disable()

	@ 065,002 BUTTON oBtn2 PROMPT STR0016 SIZE 90,10 PIXEL OF oQPages2:aDialogs[2] FONT oDlgIns:oFont ACTION oQPages2:SetOption(1) //"<< Escolher Datas"

	@ 000,095 QPages oQPages	DIALOGS "1","2","3","4","5","6","7" SIZE 213/2,78/2 OF oQPages2:aDialogs[2] OPTION nOpt ACTIVE {.T.,.T.,.T.,.T.,.T.,.T.} FONT oDlgIns:oFont

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³ Escalas ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	@ 001,001 SAY "" SIZE 210,076 PIXEL SHADOW OF oQPages:aDialogs[1]
	@ 005,005 SAY oSyCodEsc PROMPT STR0017 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont //"Código da Escala:"
	@ 016,005 SAY oSyRevEsc PROMPT STR0006 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont //"Revisão:"
	@ 027,005 SAY oSyEscInc PROMPT STR0019 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"Incerteza total:"
	@ 038,005 SAY oSyEscErr PROMPT STR0020 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"Erro Sistemático:"
	@ 049,005 SAY oSyEscTol PROMPT STR0021 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"Toler.de processo:"
	@ 060,005 SAY oSyEscPre PROMPT STR0056 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 29,8 //"Precisao:"

	@ 005,100 SAY oSyEscExa PROMPT STR0022 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 //"Exatidão:"
	@ 016,100 SAY oSyEscAce PROMPT STR0023 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"Aceitabilidade:"
	@ 027,100 SAY oSyEscAde PROMPT STR0024 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"Adequação ao uso:"
	@ 038,100 SAY oSyEscSta PROMPT STR0051+":" PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"Laudo"
	@ 049,100 SAY oSyEscRed PROMPT STR0026 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"Redutor:"
	@ 060,100 SAY oSyEscCer PROMPT STR0066 PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 60,8 //"No. do Certificado:"

	@ 005,050 SAY oMtCodEsc PROMPT cMtCodEsc PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 016,029 SAY oMtRevEsc PROMPT cMtRevEsc PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 027,045 SAY oMtEscInc PROMPT cMtEscInc PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 038,050 SAY oMtEscErr PROMPT cMtEscErr PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 049,050 SAY oMtEscTol PROMPT cMtEscTol PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 060,029 SAY oMtEscPre PROMPT cMtEscPre PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE

	@ 005,126 SAY oMtEscExa PROMPT cMtEscExa PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 016,138 SAY oMtEscAce PROMPT cMtEscAce PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 027,150 SAY oMtEscAde PROMPT cMtEscAde PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 038,120 SAY oMtEscSta PROMPT cMtEscSta PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 70,8 COLOR CLR_BLUE
	@ 049,125 SAY oMtEscRed PROMPT cMtEscRed PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 060,145 SAY oMtEscCer PROMPT cMtEscCer PIXEL OF oQPages:aDialogs[1] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE

	//ÚÄÄÄÄÄÄÄÄ¿
	//³ Pontos ³
	//ÀÄÄÄÄÄÄÄÄÙ
	@ 001,001 SAY "" SIZE 210,076 PIXEL SHADOW OF oQPages:aDialogs[2]
	@ 005,005 SAY oSyCodPad PROMPT STR0027 PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont //"Código do Ponto:"
	@ 020,005 SAY oSyRevPad PROMPT STR0018 PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont //"Revisão:"
	@ 035,005 SAY oSyPadInc PROMPT STR0019 PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont //"Incerteza total:"
	@ 050,005 SAY oSyPadErr PROMPT STR0020 PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont //"Erro Sistemático:"

	@ 005,100 SAY oSyPadExa PROMPT STR0022 PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,08 //"Exatidão:"
	@ 020,100 SAY oSyPadAce PROMPT STR0023 PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,08 //"Aceitabilidade:"
	@ 035,100 SAY oSyPadAde PROMPT STR0024 PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,08 //"Adequação ao Uso:"
	@ 050,100 SAY oSyPadSta PROMPT STR0051+":" PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,08 //"Laudo"

	@ 005,050 SAY oMtCodPad PROMPT cMtCodPad PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 020,029 SAY oMtRevPad PROMPT cMtRevPad PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 035,045 SAY oMtPadInc PROMPT cMtPadInc PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 050,050 SAY oMtPadErr PROMPT cMtPadErr PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE

	@ 005,126 SAY oMtPadExa PROMPT cMtPadExa PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 020,138 SAY oMtPadAce PROMPT cMtPadAce PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 035,150 SAY oMtPadAde PROMPT cMtPadAde PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 050,120 SAY oMtPadSta PROMPT cMtPadSta PIXEL OF oQPages:aDialogs[2] FONT oDlgIns:oFont SIZE 70,8 COLOR CLR_BLUE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Medicoes                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//³ Foram criados 3 QPages, um para cada quantidade de colunas de medi-  ³
	//³ ções possíveis na calibração, que são 3 (1, 2 ou 4 colunas).         ³
	//³ Foi detectado que o TWBrowse não aceita aumentar ou diminuir a qtde  ³
	//³ de colunas através de suas propriedades no Protheus, como na versão  ³
	//³ anterior. Por isso foram criadas QPages para cada quantidade de co-  ³
	//³ lunas possíveis e somente será mostrado o QPage da qtde de colunas   ³
	//³ correspondente a calibração que está sendo apresentada.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Medicoes - QPage:aDialogs[3] - para 2 colunas                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 001,001 SAY "" SIZE 210,076 PIXEL SHADOW OF oQPages:aDialogs[3]

	oBrw := TWBrowse():New( 5, 5, 200, 65,{|| { " "," " }},;
		{STR0064,STR0063},{65,60} ,oQPages:aDialogs[3], , , , , , ,; // "Inicial"###"Final"
		oDlgIns:oFont , ,, , , , , .T., , , , , )

	oBrw:lMChange := .F. // Nao deixar mudar tamanho das colunas.
	oBrw:nClrBackFocus := GetSysColor( 13 )
	oBrw:nClrForeFocus := GetSysColor( 14 )
	oBrw:SetArray( aMedicoes )
	oBrw:bLine	:= { || { aMedicoes[oBrw:nAt,1],aMedicoes[oBrw:nAt,2] } }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Medicoes - QPage:aDialogs[5] - para 1 coluna                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	@ 001,001 SAY "" SIZE 210,076 PIXEL SHADOW OF oQPages:aDialogs[5]

	oBrw1 := TWBrowse():New( 5, 5, 200, 65,{|| { " " }},;
		{STR0063},{60} ,oQPages:aDialogs[5], , , , , , ,; // "Inicial"###"Final"
		oDlgIns:oFont , ,, , , , , .T., , , , , )

	oBrw1:lMChange := .F. // Nao deixar mudar tamanho das colunas.
	oBrw1:nClrBackFocus := GetSysColor( 13 )
	oBrw1:nClrForeFocus := GetSysColor( 14 )
	oBrw1:SetArray( aMedicoes )
	oBrw1:bLine	:= { || { aMedicoes[oBrw1:nAt,1] } }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Medicoes - QPage:aDialogs[6] - para 4 colunas                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 001,001 SAY "" SIZE 210,076 PIXEL SHADOW OF oQPages:aDialogs[6]

	oBrw2 := TWBrowse():New( 5, 5, 200, 65,{|| { " "," "," "," " }},;
		{STR0064,STR0063,STR0064,STR0063},{65,60,65,60} ,oQPages:aDialogs[6], , , , , , ,; // "Inicial"###"Final"
		oDlgIns:oFont , ,, , , , , .T., , , , , )

	oBrw2:lMChange := .F. // Nao deixar mudar tamanho das colunas.
	oBrw2:nClrBackFocus := GetSysColor( 13 )
	oBrw2:nClrForeFocus := GetSysColor( 14 )
	oBrw2:SetArray( aMedicoes )
	oBrw2:bLine	:= { || { aMedicoes[oBrw2:nAt,1],aMedicoes[oBrw2:nAt,2],aMedicoes[oBrw2:nAt,3],aMedicoes[oBrw2:nAt,4] } }

	//Tree Padroes Secundarios
	@ 001,001 SAY "" SIZE 210,076 PIXEL SHADOW OF oQPages:aDialogs[7]

	oBrw3 := TWBrowse():New( 5, 5, 200, 65,{|| { " "," "," "," " }},;
		{STR0069,STR0070,STR0071},{60,60,65} ,oQPages:aDialogs[7], , , , , , ,; // "Pad.Sec"###"Escala"###"Incerteza"##
		oDlgIns:oFont , ,, , , , , .T., , , , , )

	oBrw3:lMChange := .F. // Nao deixar mudar tamanho das colunas.
	oBrw3:nClrBackFocus := GetSysColor( 13 )
	oBrw3:nClrForeFocus := GetSysColor( 14 )
	oBrw3:SetArray( aMedicoes )
	oBrw3:bLine	:= { || { aMedicoes[oBrw3:nAt,1],aMedicoes[oBrw3:nAt,2],aMedicoes[oBrw3:nAt,3] } }
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³			 ³
	//³ PAGINA 2 ³
	//³			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao oculto apenas para controle de Foco nos Folders ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SBUTTON FROM 5000,5000 TYPE 1 ENABLE OF oFolder:aDialogs[2] ACTION .T.

	@ 0.2,1 ICON oIcon RESOURCE "CARCINSTR" OF oFolder:aDialogs[2]
	oIcon:nBottom := 30

	@ 005,030 SAY STR0029 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 280,20 //"Abaixo podem ser visualizadas as características do instrumento Escolhido. Quando o Check Box estiver marcado o Instrumento utiliza os dados do mesmo"

	@ 024,005 TO 145,090 OF oFolder:aDialogs[2] PIXEL

	@ 030,010 BITMAP oBmp1 RESOURCE cBmp1 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 045,010 BITMAP oBmp2 RESOURCE cBmp2 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 060,010 BITMAP oBmp3 RESOURCE cBmp3 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 075,010 BITMAP oBmp4 RESOURCE cBmp4 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 090,010 BITMAP oBmp5 RESOURCE cBmp5 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 105,010 BITMAP oBmp6 RESOURCE cBmp6 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 120,010 BITMAP oBmp7 RESOURCE cBmp7 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 135,010 BITMAP oBmp8 RESOURCE cBmp8 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7

	@ 030,020 SAY oSay1 PROMPT STR0030 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Cálculo de Incerteza"
	@ 045,020 SAY oSay2 PROMPT STR0031 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 60,8 //"Confirmação. Metrológica"
	@ 060,020 SAY oSay3 PROMPT STR0032 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 40,8 //"R / R"
	@ 075,020 SAY oSay4 PROMPT STR0033 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Tendência"
	@ 090,020 SAY oSay5 PROMPT STR0034 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Linearidade"
	@ 105,020 SAY oSay6 PROMPT STR0035 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Estabilidade"
	@ 120,020 SAY oSay7 PROMPT STR0036 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Incerteza tipo B"
	@ 135,020 SAY oSay8 PROMPT STR0037 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 60,8 //"Registro de Manutenção"

	//Barras estilo Group para que os bitmaps possam aparecer
	@ 024,095 TO 075,310 LABEL STR0038 OF oFolder:aDialogs[2] PIXEL //"Salva Guarda"
	@ 032,100 BITMAP oBmp9	RESOURCE cBmp9  PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 047,100 BITMAP oBmp10 RESOURCE cBmp10 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 062,100 BITMAP oBmp11 RESOURCE cBmp11 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7

	@ 032,110 SAY oSay9	PROMPT STR0039 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Lacre"
	@ 047,110 SAY oSay10 PROMPT STR0040 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Construção"
	@ 062,110 SAY oSay11 PROMPT STR0041 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 //"Treinamento"

	//Barras estilo Group para que os bitmaps possam aparecer
	@ 079,095 TO 145,310 LABEL STR0042 OF oFolder:aDialogs[2] PIXEL //"Movimentação"
	@ 090,100 SAY oSay15 PROMPT STR0043 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 70,8 //"Depto.responsável:"
	@ 105,100 SAY oSay16 PROMPT STR0044 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 70,8 //"Usuário responsável:"

	@ 090,160 SAY oSay18 PROMPT cMtDepto	PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE
	@ 105,160 SAY oSay19 PROMPT cMtUsuario PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 50,8 COLOR CLR_BLUE

	//Barra estilo Group para envoulver textos e bitmaps
	@ 089,210 TO 135,300 LABEL STR0045 OF oFolder:aDialogs[2] PIXEL //"Controla Validade"
	@ 100,220 BITMAP oBmp12 RESOURCE cBmp12 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7
	@ 115,220 BITMAP oBmp13 RESOURCE cBmp13 PIXEL OF oFolder:aDialogs[2] NOBORDER WHEN .F. SIZE 7,7

	@ 100,230 SAY oSay13 PROMPT STR0046 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 60,8 //"Acumula Dias"
	@ 115,230 SAY oSay14 PROMPT STR0047 PIXEL OF oFolder:aDialogs[2] FONT oDlgIns:oFont SIZE 60,8 //"Reinicializa"

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³			 ³
	//³ PAGINA 3 ³
	//³			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao oculto apenas para controle de Foco nos Folders ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SBUTTON FROM 5000,5000 TYPE 1 ENABLE OF oFolder:aDialogs[3] ACTION .T.
	@ 030,010 TO 120,300 OF oFolder:aDialogs[3] PIXEL

	@ 0.3,1 ICON oIcon2 RESOURCE "SITUATU" OF oFolder:aDialogs[3]

	@ 005,030 SAY STR0048 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 250,15 //"A Situação Atual do Instrumento é calculada com base na última medição realizada para o mesmo."

	//Barras horizontais
	@ 045,010 TO 046,300 OF oFolder:aDialogs[3] PIXEL
	@ 060,010 TO 061,300 OF oFolder:aDialogs[3] PIXEL
	@ 075,010 TO 076,300 OF oFolder:aDialogs[3] PIXEL
	@ 090,010 TO 091,300 OF oFolder:aDialogs[3] PIXEL
	@ 105,010 TO 106,300 OF oFolder:aDialogs[3] PIXEL
	//Barras verticais
	@ 030,110 TO 120,111 OF oFolder:aDialogs[3] PIXEL
	@ 030,190 TO 120,191 OF oFolder:aDialogs[3] PIXEL

	//Labels
	@ 035,133 SAY STR0049 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 50,8 //"Situação Atual"
	@ 035,230 SAY STR0050 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 50,8 //"Data"
	@ 050,015 SAY STR0051 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 50,8 //"Laudo"
	@ 065,015 SAY STR0052 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 //"Próxima calibração"
	@ 080,015 SAY STR0032 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 40,8 //"R / R"
	@ 095,015 SAY STR0054 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 80,8 //"Incerteza Encontrada."
	@ 110,015 SAY STR0055 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 50,8 //"Erro Sistemático"

	//Valores
	@ 050,120 SAY oMtStatus  PROMPT cMtStatus  PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE CENTER
	@ 065,120 SAY oMtProxDtC PROMPT dMtProxDtC PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE CENTER
	@ 080,120 SAY oMtRR		 PROMPT cMtRR		 PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE RIGHT
	@ 095,120 SAY oMtIncEnc  PROMPT cMtIncEnc  PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE RIGHT
	@ 110,120 SAY oMtErrSis  PROMPT cMtErrSis  PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE RIGHT

	//Datas Encontradas
	@ 050,230 SAY odMtStatus  PROMPT dMtStatus  PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE
	@ 065,230 SAY odMtProxCal PROMPT dMtProxCal PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE
	@ 080,230 SAY odMtRR 	  PROMPT dMtRR 	  PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE
	@ 095,230 SAY odMtIncEnc  PROMPT dMtIncEnc  PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE
	@ 110,230 SAY odMtErrSis  PROMPT dMtErrSis  PIXEL OF oFolder:aDialogs[3] FONT oDlgIns:oFont SIZE 60,8 COLOR CLR_BLUE

ACTIVATE MSDIALOG oDlgIns ON INIT EnchoiceBar(oDlgIns,{|| oDlgIns:End()},{|| oDlgIns:End()}) CENTERED

SetaPilha()

Release Objects oBmp1
Release Objects oBmp2
Release Objects oBmp3
Release Objects oBmp4
Release Objects oBmp5
Release Objects oBmp6
Release Objects oBmp7
Release Objects oBmp8
Release Objects oBmp9
Release Objects oBmp10
Release Objects oBmp11
Release Objects oBmp12
Release Objects oBmp13
Release Objects oIcon
Release Objects oIcon2
Release Objects oIcon3
Release Objects oDlgIns
Release Objects oBmp
Release Objects oGrp
Release Objects oGrp1
Release Objects oFolder
Release Objects oTree
Release Objects oQPages
Release Objects oQPages2
Release Objects oMtInstr
Release Objects oSay1
Release Objects oSay2
Release Objects oSay3
Release Objects oSay4
Release Objects oSay5
Release Objects oSay6
Release Objects oSay7
Release Objects oSay8
Release Objects oSay9
Release Objects oSay10
Release Objects oSay11
Release Objects oSay17
Release Objects oMtRevi
Release Objects oSay12
Release Objects oSay13
Release Objects oSay14
Release Objects oSay15
Release Objects oSay16
Release Objects oSay18
Release Objects oSay19
Release Objects oSay20
Release Objects oBtn1
Release Objects oBtn2
Release Objects oBtn3
Release Objects oLbx
Release Objects odMtStatus
Release Objects odMtProxCal
Release Objects odMtRR
Release Objects odMtIncEnc
Release Objects odMtErrSis
Release Objects oMtFabr
Release Objects oMtProCal
Release Objects oMtFam
Release Objects oMtFreq
Release Objects oMtLocal
Release Objects oMtStatus2
Release Objects oMtCCusto
Release Objects oMtResp
Release Objects oMtStatus
Release Objects oMtProxDtC
Release Objects oMtRR
Release Objects oMtIncEnc
Release Objects oMtErrSis
Release Objects oBrw
Release Objects oBrw1
Release Objects oBrw2
Release Objects oBrw3
Release Objects oMtCodEsc
Release Objects oMtRevEsc
Release Objects oMtEscInc
Release Objects oMtEscErr
Release Objects oMtEscTol
Release Objects oMtEscPro
Release Objects oMtEscExa
Release Objects oMtEscAce
Release Objects oMtEscAde
Release Objects oMtEscSta
Release Objects oMtEscRed
Release Objects oMtEscCer
Release Objects oMtCodPad
Release Objects oMtRevPad
Release Objects oMtPadInc
Release Objects oMtPadErr
Release Objects oMtPadExa
Release Objects oMtPadAce
Release Objects oMtPadAde
Release Objects oMtPadSta
Release Objects oQPages3
Release Objects oSyCodEsc
Release Objects oSyRevEsc
Release Objects oSyEscInc
Release Objects oSyEscErr
Release Objects oSyEscTol
Release Objects oSyEscPre
Release Objects oSyEscExa
Release Objects oSyEscAce
Release Objects oSyEscAde
Release Objects oSyEscSta
Release Objects oSyEscRed
Release Objects oSyEscCer
Release Objects oSyCodPad
Release Objects oSyRevPad
Release Objects oSyPadInc
Release Objects oSyPadErr
Release Objects oSyPadExa
Release Objects oSyPadAce
Release Objects oSyPadAde
Release Objects oSyPadSta

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020ChgTre³ Autor ³ Fernando Godoy		³ Data ³ 3/10/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Muda a pagina do dbtree									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle do dbtree 									  ³±±
±±³			 ³ExpO2 - Handle do Objeto QPages 							  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020ChgTree(cMtInstr,cMtRevi,oMtCodEsc,oMtRevEsc,oMtEscInc,;
		oMtEscErr,oMtEscTol,oMtEscPre,oMtEscExa,oMtEscAce,oMtEscAde,oMtEscSta,oMtEscRed,oMtEscCer,;
		cMtCodEsc,cMtRevEsc,cMtEscInc,cMtEscErr,cMtEscTol,cMtEscPre,cMtEscExa,cMtEscAce,;
		cMtEscAde,cMtEscSta,cMtEscRed,cMtEscCer,cMtCodPad,cMtRevPad,cMtPadInc,cMtPadErr,;
		cMtPadExa,cMtPadAce,cMtPadAde,cMtPadSta,oMtCodPad,oMtRevPad,oMtPadInc,;
		oMtPadErr,oMtPadExa,oMtPadAce,oMtPadAde,oMtPadSta,cLbx,aMedicoes,;
		aTree,oBrw,oTree,oQPages,nPosCar,nPosMed,nPosPad,nPosEsc,oLbx,nPosLau,;
		oSyCodEsc,oSyRevEsc,oSyEscInc,oSyEscErr,oSyEscTol,oSyEscPre,oSyEscExa,oSyEscAce,;
		oSyEscAde,oSyEscSta,oSyEscRed,oSyEscCer,oSyCodPad,oSyRevPad,oSyPadInc,oSyPadErr,;
		oSyPadExa,oSyPadAce,oSyPadAde,oSyPadSta,oBrw1,oBrw2,oBrw3,nPosSec)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra a tela de Escalas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTree) > 0
	If Right(oTree:GetCargo(),1) == "1"
		oQPages:SetOption(1)
		C020MoEsc(@cMtCodEsc,@cMtRevEsc,@cMtEscInc,@cMtEscErr,@cMtEscTol,@cMtEscPre,;
			@cMtEscExa,@cMtEscAce,@cMtEscAde,@cMtEscSta,@cMtEscRed,@cMtEscCer,;
			oMtCodEsc,oMtRevEsc,oMtEscInc,oMtEscErr,oMtEscTol,oMtEscPre,oMtEscExa,;
			oMtEscAce,oMtEscAde,oMtEscSta,oMtEscRed,oMtEscCer,nPosCar,nPosEsc,aTree,;
			oTree,nPosLau,oSyCodEsc,oSyRevEsc,oSyEscInc,oSyEscErr,oSyEscTol,oSyEscPre,;
			oSyEscExa,oSyEscAce,oSyEscAde,oSyEscSta,oSyEscRed)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra a tela de pontos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Elseif Right(oTree:GetCargo(),1) == "2"
		C020MoPad(@cMtCodPad,@cMtRevPad,@cMtPadInc,@cMtPadErr,@cMtPadExa,@cMtPadAce,;
			@cMtPadAde,@cMtPadSta,oMtCodPad,oMtRevPad,oMtPadInc,oMtPadErr,;
			oMtPadExa,oMtPadAce,oMtPadAde,oMtPadSta,nPosCar,nPosPad,aTree,;
			oTree,nPosLau,oSyCodPad,oSyRevPad,oSyPadInc,oSyPadErr,oSyPadExa,;
			oSyPadAce,oSyPadAde,oSyPadSta)

		oQPages:SetOption(2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra a tela de medicoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Elseif Right(oTree:GetCargo(),1) == "3"
		If C020MoMed(oLbx,aTree,oTree,nPosCar,nPosMed,@aMedicoes,oBrw,oBrw1,oBrw2)
			Do Case
				Case Len(aMedicoes[1]) == 1
						oQPages:SetOption(5)
				Case Len(aMedicoes[1]) == 2
						oQPages:SetOption(3)
				Case Len(aMedicoes[1]) == 4
						oQPages:SetOption(6)
			EndCase
		Else
			oQPages:SetOption(4)
		Endif
	Else //Tree Padroes Secundarios
		oQPages:SetOption(7)
		C020MoPdSec(aTree,nPosCar,oTree,nPosSec,oBrw3,@aMedicoes)
	EndIf

	oTree:SetFocus()

	oQPages:Set3dLook()
	oQPages:Refresh()

	SysRefresh()

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020MoTree³ Autor ³ Fernando Godoy		³ Data ³ 3/10/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o dbtree. 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle do dbtree 									  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020MoTree(oTree,aTree,nPosCar,nPosDEsc,nPosDPad,oQPages,oQPages2,cMtInstr)
Local nLoop 		:= 1
Local cEscala		:= ""
Local cEscalaAtu	:= ""
Local nNivEsc		:= 1
Local nNivPad		:= 1

oQPages2:SetOption(2)
oTree:ReSet()	// Reseta os dados do dbTree

If Len(aTree) > 0

	oTree:SetEnable()

	While nLoop <= Len(aTree)

		cEscala := aTree[nLoop,nPosDEsc] + Space(16-Len(aTree[nLoop,1]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se e instrumento Malha e retorna o codigo do       ³
		//³	instrumento que se refere a escalha passada como parâmetro. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cInsEsc := C020InsEsc(cMtInstr,aTree[nLoop,nPosDEsc])

		nNivPad := 1

		oTree:AddItem(cInsEsc ,StrZero(nNivEsc,3)+"/"+"001"+"/"+"00"+"-"+"1", "Folder5", "Folder6", , , 1)

		cEscalaAtu := cEscala

		oTree:TreeSeek(StrZero(nNivEsc,3)+"/"+"001"+"/"+"00"+"-"+"1")

		While nLoop <= Len(aTree) .And. aTree[nLoop,nPosDEsc] == cEscalaAtu

			oTree:AddItem(aTree[nLoop,nPosDPad],StrZero(nNivEsc,3)+"/"+StrZero(nNivPad,3)+"/"+"01"+"-" + "2" , "Folder5", "Folder6", , , 2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Guarda cargo no array aTree ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTree[nLoop,nPosCar] := StrZero(nNivEsc,3)+"/"+StrZero(nNivPad,3)+"/"

			oTree:TreeSeek(StrZero(nNivEsc,3)+"/"+StrZero(nNivPad,3)+"/"+"01"+"-" + "2")

			oTree:AddItem( STR0057, StrZero(nNivEsc,3)+"/"+StrZero(nNivPad,3)+"/"+"01"+"-" + "3" ,  "Folder5", "Folder6", , , 2) //"Medições"
			oTree:AddItem( STR0072, StrZero(nNivEsc,3)+"/"+StrZero(nNivPad,3)+"/"+"01"+"-" + "4" ,  "Folder5", "Folder6", , , 2) //Pad.Secund.

			oTree:TreeSeek(StrZero(nNivEsc,3)+"/"+"001"+"/"+"00"+"-"+"1")

			nNivPad++

			cEscalaAtu := aTree[nLoop,nPosDEsc]

			nLoop++

		EndDo

		nNivEsc++

	EndDo
Else
	oTree:SetDisable()
	oQPages:SetOption(4)
EndIf

oTree:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020CarMed³ Autor ³ Fernando Godoy        ³ Data ³ 3/11/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega as Escalas/Pontos e Medicoes do instrumento 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nil 														  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 - Array com os dados								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020								     				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto     ³26/06/00³  --  ³ Inclusao do Tipo de Calibracao Relogio.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020CarMed( aTree,cLbx,cMtInstr,cMtRevi )
Local dMtData		:= Ctod("  /  /  ","DDMMYY")
Local aEscala		:= {}
Local aPontos		:= {}
Local aMedi 		:= {}
Local cTolPro		:= ""
Local cRedut		:= ""
Local cPrec       := ""
Local lExatEsc 	:= .F.
Local lAceiEsc 	:= .F.
Local lAdeqEsc 	:= .F.
Local nIncTotEsc	:= 0
Local nErrSisEsc	:= 0
Local nRecno		:= 0
Local cTipoLaudo  := ""
Local aSecs		:= {}
Local cEscas	:= ""
Local cPdas		:= ""

If lDtQt
	dMtData		:= Ctod(SubStr(Alltrim(cLbx),1,10),"DDMMYYYY")
Else
	dMtData		:= Ctod(SubStr(Alltrim(cLbx),1,8),"DDMMYY")
Endif
aTree := {} // Zera array para dbtree

dbSelectArea("QM6")
dbSetOrder(2)
If dbSeek(xFilial("QM6")+cMtInstr+cMtRevi+Inverte(Dtos(dMtData)))

	dbSelectArea("QM7")
	dbSetOrder(1)
	If DbSeek(xFilial("QM7")+cMtInstr+cMtRevi+DtoS(dMtData)+cSeql)

		While QM7->QM7_FILIAL + QM7->QM7_INSTR + QM7->QM7_REVINS +;
			DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ == xFilial("QM7")+cMtInstr+cMtRevi+;
			DtoS(dMtData)+cSeql .And. !Eof()

			nRecno := Recno()

			dbSelectArea("QM9")
			dbSetOrder(1)
			If dbSeek(xFilial("QM9")+QM7->QM7_ESCALA+Inverte(QM7->QM7_REVESC))

				If Alltrim(QM9->QM9_LAUDO) == '1'  // Se tipo de laudo = Incerteza c/ Conf.Metrol.
					lExatEsc := Iif(QM7->QM7_EXAT  == "A",.T.,.F.) // Exatid„o do Primeiro Ponto
					lAceiEsc := Iif(QM7->QM7_ACEIT == "A",.T.,.F.) // Aceita‡„o do Primeiro Ponto
					lAdeqEsc := Iif(QM7->QM7_ADEQ  == "A",.T.,.F.) // Adequa‡„o ao Uso do Primeiro Ponto
				EndIf

				cTipoLaudo := QM9->QM9_LAUDO

				nIncTotEsc := QM7->QM7_INCERT
				nErrSisEsc := QM7->QM7_ERSIST

				While QM7->QM7_FILIAL + QM7->QM7_INSTR + QM7->QM7_REVINS +;
					DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ == xFilial("QM7")+cMtInstr+cMtRevi+;
					DtoS(dMtData)+cSeql .And. !Eof()

					nIncTotEsc := Iif(QM7->QM7_INCERT > nIncTotEsc, QM7->QM7_INCERT, nIncTotEsc)
					nErrSisEsc := Iif(QM7->QM7_ERSIST > nErrSisEsc, QM7->QM7_ERSIST, nErrSisEsc)
					If Alltrim(QM9->QM9_LAUDO) == '1'  // Se tipo de laudo = Incerteza c/ Conf.Metrol.
						lExatEsc := Iif(lExatEsc,Iif(QM7->QM7_EXAT  == "A",.T.,.F.),.F.)
						lAceiEsc := Iif(lAceiEsc,Iif(QM7->QM7_ACEIT == "A",.T.,.F.),.F.)
						lAdeqEsc := Iif(lAdeqEsc,Iif(QM7->QM7_ADEQ  == "A",.T.,.F.),.F.)
					EndIf

					dbSelectArea("QM7")
					dbSkip()

				EndDo

				dbGoto(nRecno)

			Endif

			aEscala	:= {} // Zera array de escalas
			aPontos	:= {} // Zera array de pontos
			aMedi 	:= {} // Zera array de medicoes
			aSecs 	:= {} // Zera array de medicoes
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caracteristicas da Escala ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QMR")
			dbSetOrder(1)
			If dbSeek(xFilial("QMR")+cMtInstr+cMtRevi+QM7->QM7_ESCALA)
				cTolPro	:= QMR->QMR_TOLPRO
				cRedut	:= QMR->QMR_REDUT
				cPrec    := QMR->QMR_PREC
			EndIf

			Aadd( aEscala , {QM7->QM7_ESCALA,QM7->QM7_REVESC,nIncTotEsc,;
				nErrSisEsc,cTolPro,lExatEsc,lAceiEsc,lAdeqEsc,;
				QM7->QM7_RESULT,cRedut,cPrec,QM7->QM7_NRCERT } )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caracteristicas do Ponto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd( aPontos, { QM7->QM7_PONTO,QM7->QM7_REVPAD,QM7->QM7_INCERT,;
				QM7->QM7_ERSIST, QM7->QM7_EXAT,QM7->QM7_ACEIT,;
				QM7->QM7_ADEQ,QM7->QM7_RESULT } )

			dbSelectArea("QMS")
			dbSetOrder(1)
			If dbSeek(xFilial()+cMtInstr+cMtRevi+DtoS(dMtData)+QM7->QM7_ESCALA+QM7->QM7_PONTO)
				cEscas	:= QMS->QMS_ESCALA
				cPdas	:= QMS->QMS_PONTO
				While !Eof() .and. QMS->QMS_FILIAL+QMS->QMS_INSTR+QMS->QMS_REVINS+DtoS(QMS->QMS_DATA)+QMS->QMS_ESCALA+QMS->QMS_PONTO ==;
					xFilial()+cMtInstr+cMtRevi+DtoS(dMtData)+cEscas+cPdas
						Aadd(aSecs,{QMS->QMS_PADSEC,QMS->QMS_ESCPAD,QMS->QMS_INCERT})
					dbSelectArea("QMS")
					dbSkip()
				Enddo
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem as medicoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QM8")
			dbSetOrder(1)
			If dbSeek(xFilial("QM8")+cMtInstr+cMtRevi+Dtos(dMtData)+cSeql+;
				QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO+;
				QM7->QM7_REVPAD)

				While !Eof() .And. QM8->QM8_FILIAL+QM8->QM8_INSTR+;
					QM8->QM8_REVINS+Dtos(QM8->QM8_DATA)+QM8->QM8_CSEQ+QM8->QM8_ESCALA+;
					QM8->QM8_REVESC+QM8->QM8_PADRAO+QM8->QM8_REVPAD == ;
					xFilial("QM8")+cMtInstr+cMtRevi+Dtos(dMtData)+cSeql+;
					QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO+;
					QM7->QM7_REVPAD

					If QM9->QM9_TIPAFE $ "4,8"
						dbSelectArea("QMG")
						dbSetOrder(1)
						If QMG->(dbSeek(xFilial("QMG")+QM8->QM8_INSTR+QM8->QM8_REVINS+QM7->QM7_PONTO))
							If QMG->QMG_TIPCAL == "A"
								Aadd(aMedi, { IIF(QM8->QM8_ATRIB=="A",STR0067,IIF(QM8->QM8_ATRIB=="R",STR0068,"")) } )  // "Aprovado" ###  "Reprovado"
							ElseIf QM9->QM9_TIPAFE == "4"
								Aadd(aMedi, {QM8->QM8_VLRFIM } )
							ElseIf QM9->QM9_TIPAFE == "8"
  								Aadd( aMedi, {QM8->QM8_VLRINI,QM8->QM8_VLRFIM} )
							EndIf
						EndIf
					Else
						If !empty(QM8->QM8_ATRIB)
								Aadd(aMedi, { IIF(QM8->QM8_ATRIB=="A",STR0067,IIF(QM8->QM8_ATRIB=="R",STR0068,"")) } )  // "Aprovado" ###  "Reprovado"
						Else
							If QM9->QM9_TIPAFE == " "  .And. QM9->QM9_NROMED == 0
								Aadd(aMedi, { IIF(QM8->QM8_ATRIB=="A",STR0067,IIF(QM8->QM8_ATRIB=="R",STR0068,"")) } )  // "Aprovado" ###  "Reprovado"
							ElseIf QM9->QM9_TIPAFE == "1" .Or. QM9->QM9_TIPAFE == "4"
								Aadd(aMedi, {QM8->QM8_VLRFIM } )
							Elseif QM9->QM9_TIPAFE == "2" .Or. QM9->QM9_TIPAFE == "5" .Or.;
								QM9->QM9_TIPAFE == "8"
								Aadd( aMedi, {QM8->QM8_VLRINI,QM8->QM8_VLRFIM} )
							Elseif QM9->QM9_TIPAFE == "3" .Or. QM9->QM9_TIPAFE == "9"
								Aadd( aMedi, {QM8->QM8_VLRINI,QM8->QM8_VLRFIM,;
								QM8->QM8_VLRIND,QM8->QM8_VLRFID} )
							EndIf
						EndIf
					EndIf
					dbSelectArea("QM8")
					dbSkip()
				EndDo

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona no array para o dbtree ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd(aTree, {QM7->QM7_ESCALA, QM7->QM7_PONTO, Aclone(aEscala),;
			 Aclone(aPontos) , Aclone(aMedi), "", cTipoLaudo, Aclone(aSecs) })

			dbSelectArea("QM7")
			dbSkip()
		EndDo
	Else
		aTree := {}
	Endif
Else
	aTree := {}
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020ReSet ³ Autor ³ Fernando Godoy		  ³ Data ³ 3/15/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna para a pagina 1 com todos os Objetos desabilitados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - .T. Habilita e .F. desabilita						  ³±±
±±³			 ³ExpO1 - Handle do listbox									  ³±±
±±³			 ³ExpO2 - Handle do QPages									  ³±±
±±³			 ³ExpO3 - Handle dos botoes									  ³±±
±±³			 ³ExpO4 - Handle do Say acima do ListBox					  ³±±
±±³			 ³ExpA1 - Array com as Calibracoes encontradas				  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020ReSet( lSet,oLbx,oQPages2,oBtn1,oSay17,aDatas,;
	cMtInstr,cMtRevi,oTree,oFolder,cLbx,oMtInstr,oMtRevi,oBtn3,;
	oQPages )

If lSet
	oSay17:Enable()
	oLbx:Enable()
	aDatas := C020DtMed(cMtInstr,cMtRevi)
	If Len(aDatas) <= 0
		Aadd(aDatas, "" )
		Aadd(aDatas, STR0058 ) //"    Não existem calibrações"
		cLbx := ""
		oBtn1:Disable()
		oLbx:Disable()
	Else
		oBtn1:Enable()
	EndIf

	oLbx:SetItems( aDatas )
	oLbx:Refresh()
	oFolder:Refresh()
	oMtInstr:Disable()
	oMtRevi:Disable()
	oMtInstr:Refresh()
	oMtRevi:Refresh()
	oBtn3:cCaption := "<<"
	oBtn3:Refresh()
	oBtn1:Refresh()
Else
	aDatas := {}
	oQPages2:SetOption(1)
	oLbx:Reset()
	oLbx:Disable()
	oBtn1:Disable()
	oSay17:Disable()
	oFolder:Refresh()
	oMtInstr:Enable()
	oMtRevi:Enable()
	cMtInstr := CriaVar("QM2_INSTR")
	cMtRevi	:= CriaVar("QM2_REVINS")
	oMtInstr:Refresh()
	oMtRevi:Refresh()
	oQPages:SetOption(1)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020DtMed ³ Autor ³ Fernando Godoy		³ Data ³ 3/16/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna as Calibracoes efetuadas							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do instrumento								  ³±±
±±³			 ³ExpC2 - Revisao do instrumento 							  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020DtMed(cMtInstr,cMtRevi)
Local aRet	:= {}
Local aArea := GetArea()
Local nLoop := 1

dbSelectArea("QM6")
dbSetOrder(2)
If dbSeek(xFilial("QM6")+cMtInstr+cMtRevi)
	If Len(DtoC(QM6->QM6_DATA)) > 8
		lDtQt := .T.
	Endif
	While !Eof() .And. xFilial("QM6") == QM6->QM6_FILIAL .And.;
		cMtInstr+cMtRevi == QM6->QM6_INSTR+QM6->QM6_REVINS
		Aadd(aRet,"        "+ Dtoc(QM6->QM6_DATA)+"   "+QM6->QM6_CSEQ)
		nLoop ++
		dbSkip()
	EndDo
EndIf

RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020Valid ³ Autor ³ Fernando Godoy		³ Data ³ 3/16/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a existencia de um instrumento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tipo -> 1=Instrumento 2=Revisao e 3=Botao			  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Logico .T. ou .F.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020Valid( cTipo,cMtInstr,cMtRevi,oFolder,oTree,oLbx,;
	oBtn1,oQPages2,oSay17,cLbx,aDatas,oMtInstr,oMtRevi,oBtn3,dMtData )

Local aArea := GetArea()
Local lRet	:= .T.

cTipo := Alltrim(cTipo)

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida campo instrumento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "1"
		dbSelectArea("QM2")
		dbSetOrder(1)
		If !dbSeek(xFilial("QM2")+cMtInstr)
			MessageDlg(STR0059) //"Instrumento não encontrado. Informe um válido."
			cMtRevi := CriaVar("QM2_REVINS")
			oMtRevi:Refresh()
			lRet := .F.
		Else
			cMtRevi := QM2->QM2_REVINS
			oMtRevi:Refresh()
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida campos instrumento + Revisao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "2"
		If !Empty(cMtRevi)
			dbSelectArea("QM2")
			dbSetOrder(1)
			If !dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevi))
				MessageDlg(STR0060) //"Não foi encontrado o Instrumento e Revisão informado. Verifique se o código esta correto."
				lRet := .F.
			EndIf
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida campos instrumento + Revisao no botao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "3"
		If !Empty(cMtInstr) .And. !Empty(cMtRevi)
			dbSelectArea("QM2")
			dbSetOrder(1)
			If !dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevi))
				MessageDlg(STR0060) //"Não foi encontrado o Instrumento e Revisão informado. Verifique se o código esta correto."
				lRet := .F.
			Else
				oSay17:Enable()
				oLbx:Enable()
				aDatas := C020DtMed(cMtInstr,cMtRevi)

				If Len(aDatas) > 0
					If lDtQt
						dMtData := Ctod(SubStr(Alltrim(aDatas[1]),1,10),"DDMMYYYY")
					Else
						dMtData := Ctod(SubStr(Alltrim(aDatas[1]),1,8),"DDMMYY")
					Endif
					cSeql	:= SubStr(Alltrim(aDatas[1]),12)
					oBtn1:Enable()
				Else
					Aadd(aDatas, "" )
					Aadd(aDatas, STR0058 ) //"    Não existem calibrações"
					cLbx := ""
					oLbx:Disable()
					oBtn1:Disable()
					dMtData := Ctod("  /  /  ","DDMMYY")
					cSeql	:= ""
				EndIf
				oLbx:SetItems( aDatas )
				oBtn1:Refresh()
			EndIf
		Else
			lRet := .F.
		Endif
EndCase

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020ActBut³ Autor ³ Fernando Godoy		³ Data ³ 3/16/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a acao do botao >>								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Varios													  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020ActBut( cMtInstr,cMtRevi,oFolder,oTree,oLbx,;
			oBtn1,oQPages2,oSay17,cLbx,aDatas,oMtInstr,oMtRevi,oBtn3,;
			cMtFabr,cMtProCal,cMtFam,cMtFreq,cMtLocal,cMtResp,cMtCCusto,cMtStatus2,oMtFabr,;
			oMtProCal,oMtFam,oMtFreq,oMtLocal,oMtResp,oMtCCusto,oMtStatus2,oBmp,cBmp1,cBmp2,;
			cBmp3,cBmp4,cBmp5,cBmp6,cBmp7,cBmp8,cBmp9,cBmp10,cBmp11,;
			cBmp12,cBmp13,oBmp1,oBmp2,oBmp3,oBmp4,oBmp5,oBmp6,oBmp7,;
			oBmp8,oBmp9,oBmp10,oBmp11,oBmp12,oBmp13,cMtDepto,cMtUsuario,;
			oSay13,oSay14,dMtData,oSay18,oSay19,oMtStatus,oMtProxDtC,;
			oMtRR,oMtIncEnc,oMtErrSis,cMtStatus,dMtProxDtC,;
			cMtRR,cMtIncEnc,cMtErrSis,odMtStatus,odMtProxCal,;
			odMtRR,odMtIncEnc,odMtErrSis,dMtStatus,dMtProxCal,dMtRR,;
			dMtIncEnc,dMtErrSis,oQPages)

If Alltrim(oBtn3:cCaption) <> "<<"
	If C020Valid( "3",@cMtInstr,@cMtRevi,oFolder,oTree,oLbx,;
				oBtn1,oQPages2,oSay17,@cLbx,aDatas,oMtInstr,oMtRevi,;
				oBtn3,@dMtData)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Habilita os Objetos na tela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		C020ReSet( .T.,oLbx,oQPages2,oBtn1,oSay17,aDatas,cMtInstr,cMtRevi,;
			oTree,oFolder,@cLbx,oMtInstr,oMtRevi,oBtn3,oQPages )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega caracteristicas do instrumento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		C020CarIns( @cMtInstr,@cMtRevi,@cMtFabr,@cMtProCal,@cMtFam,;
			@cMtFreq,@cMtLocal,@cMtResp,@cMtCCusto,@cMtStatus2,oMtFabr,oMtProCal,oMtFam,oMtFreq,;
			oMtLocal,oMtResp,oMtCCusto,oMtStatus2,oBmp )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega segunda pagina do Folder ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		C020Pag2(@cBmp1,@cBmp2,@cBmp3,@cBmp4,@cBmp5,@cBmp6,@cBmp7,@cBmp8,;
			@cBmp9,@cBmp10,@cBmp11,@cBmp12,@cBmp13,@cMtInstr,@cMtRevi,oBmp1,;
			oBmp2,oBmp3,oBmp4,oBmp5,oBmp6,oBmp7,oBmp8,oBmp9,oBmp10,oBmp11,;
			oBmp12,oBmp13,@cMtDepto,@cMtUsuario,oSay13,oSay14,dMtData,;
			oSay18,oSay19,cMtFam)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega a terceira pagina do folder ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		C020Pag3(oMtStatus,oMtProxDtC,oMtRR,oMtIncEnc,oMtErrSis,;
			@cMtStatus,@dMtProxDtC,@cMtRR,@cMtIncEnc,@cMtErrSis,;
			odMtStatus,odMtProxCal,odMtRR,odMtIncEnc,odMtErrSis,;
			@dMtStatus,@dMtProxCal,@dMtRR,@dMtIncEnc,@dMtErrSis,@cMtInstr,;
			@cMtRevi,dMtData,cSeql)

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Volta todas as configuracoes padroes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		C020ReSet( .F.,oLbx,oQPages2,oBtn1,oSay17,aDatas,cMtInstr,cMtRevi,;
			oTree,oFolder,@cLbx,oMtInstr,oMtRevi,oBtn3,oQPages )
	Endif
Else
	aDatas := {}
	oQPages2:SetOption(1)
	oLbx:Reset()
	oLbx:Disable()
	oBtn1:Disable()
	oSay17:Disable()
	oFolder:Refresh()
	oMtInstr:Enable()
	oMtRevi:Enable()
	cMtInstr := CriaVar("QM2_INSTR")
	cMtRevi	:= CriaVar("QM2_REVINS")
	oMtInstr:Refresh()
	oMtRevi:Refresh()
	oBtn3:cCaption := ">>"
	oBtn3:Refresh()
	oMtInstr:SetFocus()
	oQPages:SetOption(1)

	cMtFabr	 := ""
	cMtProCal := ""
	cMtFam	 := ""
	cMtFreq	 := ""
	cMtLocal  := ""
	cMtResp	 := ""
	cMtCCusto := ""
	cMtStatus2 := ""

	oMtFabr:Refresh()
	oMtProCal:Refresh()
	oMtFam:Refresh()
	oMtFreq:Refresh()
	oMtLocal:Refresh()
	oMtStatus2:Refresh()
	oMtResp:Refresh()
	oMtCCusto:Refresh()

	ShowBitmap(oBmp,"1HJAFAH1","INSPAD")

	oMtInstr:SetFocus()
	SetFocus(oMtInstr:hWnd)

Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020CarIns³ Autor ³ Fernando Godoy		³ Data ³ 3/17/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega as caracteristicas do instrumento					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Varios 													  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020CarIns( cMtInstr,cMtRevi,cMtFabr,cMtProCal,cMtFam,;
	cMtFreq,cMtLocal,cMtResp,cMtCCusto,cMtStatus2,oMtFabr,oMtProCal,oMtFam,oMtFreq,;
	oMtLocal,oMtResp,oMtCCusto,oMtStatus2,oBmp )

Local aArea := GetArea()

dbSelectArea("QM2")
dbSetOrder(1)


If dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevi))
	cMtFabr	:= QM2->QM2_FABR
	cMtFam	:= QM2->QM2_TIPO
	cMtFreq	:= QM2->QM2_FREQAF
	cMtLocal := QM2->QM2_LOCAL
	cMtCCusto:= QM2->QM2_DEPTO
	cMtStatus2:= QM2->QM2_STATUS

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a descricao do status         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QMP")
	dbSetOrder(1)
        If dbSeek(xFilial("QMP")+QM2->QM2_STATUS)
                cMtStatus2 := cMtStatus2 + " - " + QMP->QMP_DESCR
	EndIf

	dbSelectArea("QM2")

	/* versao antiga do Fernandes
	If !Empty(QM2->QM2_LOCAL)
		cMtLocal := QM2->QM2_LOCAL
	Else
		cMtLocal := QM2->QM2_DEPTO
	EndIf */
	cMtResp := C020Apelido(QM2->QM2_RESP)
	ShowBitmap(oBmp,QM2->QM2_BITMAP,"INSPAD")
	dbSelectArea("QM1")
	dbSetOrder(1)
	If dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
		cMtProCal := QM1->QM1_PROCAL
	EndIf
EndIf

oMtFabr:Refresh()
oMtProCal:Refresh()
oMtFam:Refresh()
oMtFreq:Refresh()
oMtLocal:Refresh()
oMtResp:Refresh()
oMtCCusto:Refresh()
oMtStatus2:Refresh()

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020Pag2	³ Autor ³ Fernando Godoy		³ Data ³ 3/17/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega dados da Segunda pagina							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Varios													  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020Pag2(cBmp1,cBmp2,cBmp3,cBmp4,cBmp5,cBmp6,cBmp7,cBmp8,cBmp9,;
	cBmp10,cBmp11,cBmp12,cBmp13,cMtInstr,cMtRevi,oBmp1,oBmp2,oBmp3,oBmp4,;
	oBmp5,oBmp6,oBmp7,oBmp8,oBmp9,oBmp10,oBmp11,oBmp12,oBmp13,cMtDepto,;
	cMtUsuario,oSay13,oSay14,dMtData,oSay18,oSay19,cMtFam,cLbx)

Local aArea := GetArea()
Local nLoop := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera todos os objetos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBmp1  := "LBNO"
cBmp2  := "LBNO"
cBmp3  := "LBNO"
cBmp4  := "LBNO"
cBmp5  := "LBNO"
cBmp6  := "LBNO"
cBmp7  := "LBNO"
cBmp8  := "LBNO"
cBmp9  := "LBNO"
cBmp10 := "LBNO"
cBmp11 := "LBNO"
cBmp12 := "LBNO"
cBmp13 := "LBNO"
cMtDepto   := ""
cMtUsuario := ""

oBmp1:SetBmp(cBmp1)
oBmp2:SetBmp(cBmp2)
oBmp3:SetBmp(cBmp3)
oBmp4:SetBmp(cBmp4)
oBmp5:SetBmp(cBmp5)
oBmp6:SetBmp(cBmp6)
oBmp7:SetBmp(cBmp7)
oBmp8:SetBmp(cBmp8)
oBmp9:SetBmp(cBmp9)
oBmp10:SetBmp(cBmp10)
oBmp11:SetBmp(cBmp11)
oBmp12:SetBmp(cBmp12)
oBmp13:SetBmp(cBmp13)

If lDtQt
	dMtData := Ctod(SubStr(Alltrim(cLbx),1,10),"DDMMYYYY")
Else
	dMtData := Ctod(SubStr(Alltrim(cLbx),1,8),"DDMMYY")
Endif

cSeql := SubStr(Alltrim(cLbx),12)
cSeql := Alltrim(cSeql)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Salva Guarda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM2")
dbSetOrder(1)
If dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevi))
	For nLoop := 1 To Len(QM2->QM2_SGUARD)
		If Upper(Substr(QM2->QM2_SGUARD,nLoop,1)) == "L"
			cBmp9 := "LBTIK"
		Elseif Upper(Substr(QM2->QM2_SGUARD,nLoop,1)) == "C"
			cBmp10 := "LBTIK"
		Elseif Upper(Substr(QM2->QM2_SGUARD,nLoop,1)) == "T"
			cBmp11 := "LBTIK"
		EndIf
	Next nLoop
	oBmp9:SetBmp( cBmp9 )
	oBmp10:SetBmp( cBmp10 )
	oBmp11:SetBmp( cBmp11 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de Validade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QM1")
	dbSetOrder(1)
	If dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
		If QM1->QM1_VALID == "1"
			cBmp12 := "LBTIK"
			oBmp12:SetBmp( cBmp12 )
		Elseif QM1->QM1_VALID == "2"
			cBmp13 := "LBTIK"
			oBmp13:SetBmp( cBmp13 )
		EndIf

		cMtDepto   := Capital(QM1->QM1_DISTR)
		cMtUsuario := Capital(C020Apelido(QM1->QM1_RDISTR))

	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Com base na fam¡lia procuro a escala, se constar  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM9")
dbSetOrder(1)
dbSelectArea("QMK") // Amarracao tipo x escala
dbSetOrder(1)       // Famílias com revisão invertida e escala
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conf. Metrologica e Calculo de Incerteza   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QMK->(dbSeek(xFilial("QMK")+cMtFam,.T.))
cReviQMK := QMK->QMK_REVTIP // A revisão mais recente...
Do While cMtFam == QMK->QMK_TIPO .And. ;
         QMK->QMK_REVTIP == cReviQMK .And. ;
			!QMK->(EOF())
	QM9->(dbSeek(xFilial("QM9")+QMK->(QMK_ESCALA+QMK_REVINV)) )
	If QM9->QM9_ESCALA == QMK->QMK_ESCALA
		If QM9->(QM9_LAUDO) == "1" // Tipo Incertez com confirmação...
			cBmp1 := "LBTIK"
			oBmp1:SetBmp(cBmp1)
			cBmp2 := "LBTIK"
			oBmp2:SetBmp(cBmp2)
			Exit
		ElseIf QM9->(QM9_LAUDO) == "2"
			cBmp1 := "LBTIK"
			oBmp1:SetBmp(cBmp1)
			Exit
		EndIf
	EndIf
	QMK->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de manutencao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QME")
dbSetOrder(1)
If dbSeek(xFilial("QME")+cMtInstr+cMtRevi)
	cBmp8 := "LBTIK"
	oBmp8:SetBmp( cBmp8 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incerteza do Tipo B ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMX")
dbSetOrder(1)
If dbSeek(xFilial("QMX")+cMtInstr+cMTRevi+Dtos(dMtData))
	cBmp7 := "LBTIK"
	oBmp7:SetBmp( cBmp7 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tendencia ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
dbSetOrder(1)
If dbSeek(xFilial("QMU")+cMtInstr+cMtRevi)
	cBmp4 := "LBTIK"
	oBmp4:SetBmp( cBmp4 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Linearidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
dbSetOrder(1)
If dbSeek(xFilial("QMU")+cMtInstr+cMtRevi)
	cBmp5 := "LBTIK"
	oBmp5:SetBmp( cBmp5 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estabilidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
dbSetOrder(1)
If dbSeek(xFilial("QMU")+cMtInstr+cMtRevi)
	cBmp6 := "LBTIK"
	oBmp6:SetBmp( cBmp6 )
EndIf

//ÚÄÄÄÄÄÄÄ¿
//³ R / R ³
//ÀÄÄÄÄÄÄÄÙ
dbSelectArea("QM4")
dbSetOrder(1)
If dbSeek(xFilial("QM4")+cMtInstr+cMtRevi)
	cBmp3 := "LBTIK"
	oBmp3:SetBmp( cBmp3 )
EndIf

oBmp1:Refresh()
oBmp2:Refresh()
oBmp3:Refresh()
oBmp4:Refresh()
oBmp5:Refresh()
oBmp6:Refresh()
oBmp7:Refresh()
oBmp8:Refresh()
oBmp9:Refresh()
oBmp10:Refresh()
oBmp11:Refresh()
oBmp12:Refresh()
oBmp13:Refresh()
oSay13:Refresh()
oSay14:Refresh()
oSay18:Refresh()
oSay19:Refresh()

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020Apelid³ Autor ³ Fernando Godoy		³ Data ³ 17.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gatilho para preencher o nome do usuario					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QA_NUSR(ExpC1,ExpC2,ExpL1) 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Funcionario 							  ³±±
±±³			 ³ ExpL1 = .T. indica apelido 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020Apelido(cCodDe,lApelido)
Local aArea := GetArea()
Local cNome := ""

Default cCodDe 	:= "00000"
Default lApelido	:= .T.

dbSelectArea("QAA")
dbSetOrder(1)
IF dbSeek( xFilial("QAA") + cCodDe)
	If !lApelido
		cNome := Padr(QAA->QAA_NOME,40)
	Else
		cNome := QAA->QAA_APELID
	Endif
Endif

RestArea( aArea )

Return ( cNome )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020Pag3	³ Autor ³ Fernando Godoy		³ Data ³ 3/17/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³CArrega dados da pagina 3									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Varios 													  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020Pag3(oMtStatus,oMtProxDtC,oMtRR,oMtIncEnc,oMtErrSis,;
	cMtStatus,dMtProxDtC,cMtRR,cMtIncEnc,cMtErrSis,;
	odMtStatus,odMtProxCal,odMtRR,odMtIncEnc,odMtErrSis,;
	dMtStatus,dMtProxCal,dMtRR,dMtIncEnc,dMtErrSis,cMtInstr,cMtRevi,dMtData,cSeql,cLbx)

Local aArea := GetArea()

If lDtQt
	dMtData := Ctod(SubStr(Alltrim(cLbx),1,10),"DDMMYYYY")
Else
	dMtData := Ctod(SubStr(Alltrim(cLbx),1,8),"DDMMYY")
Endif

cSeql := SubStr(Alltrim(cLbx),12)
cSeql := Alltrim(cSeql)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera todos os dados da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMtStatus	:= ""
dMtProxDtC	:= ""
cMtRR 		:= "- - -"
cMtIncEnc	:= "- - -"
cMtErrSis	:= "- - -"
dMtStatus	:= Ctod("  /  /  ","DDMMYY")
dMtProxCal	:= Ctod("  /  /  ","DDMMYY")
dMtRR 		:= Ctod("  /  /  ","DDMMYY")
dMtIncEnc	:= Ctod("  /  /  ","DDMMYY")
dMtErrSis	:= Ctod("  /  /  ","DDMMYY")

cSeql := Alltrim(cSeql)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Encontra a proxima calibracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM2")
dbSetOrder(1)
If dbSeek(xFilial("QM2")+cMtInstr+Inverte(cMtRevi))
	dMtProxDtC := QM2->QM2_VALDAF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Encontra o Status do instrumento e a Incerteza encontrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM6")
dbSetOrder(1)
If dbSeek(xFilial("QM6")+cMtInstr+cMtRevi+DtoS(dMtData)+cSeql)
	If Upper(QM6->QM6_LAUDO) == "A"
		cMtStatus := Capital(GetMv("MV_QAPROV"))   //"Aprovado"
		oMtStatus:nClrText := CLR_BLUE
	Elseif Upper(QM6->QM6_LAUDO) == "R"
		cMtStatus := Capital(GetMv("MV_QREPRO"))   //"Reprovado"
		oMtStatus:nClrText := CLR_HRED
	Elseif Upper(QM6->QM6_LAUDO) == "C"
		cMtStatus := Capital(GetMv("MV_QAPCON"))   //"Aprovado Condicional"
		oMtStatus:nClrText := CLR_YELLOW
	EndIf

	dMtStatus := QM6->QM6_DATA

	dMtProxCal := QM6->QM6_DATA

	If SuperVal(QM6->QM6_INCERT) > 0
		cMtIncEnc := Alltrim(QM6->QM6_INCERT)
		dMtIncEnc := QM6->QM6_DATA
	Else
		cMtIncEnc := "- - -"
	EndIf

	If SuperVal(QM6->QM6_ERSIST) > 0
		cMtErrSis := Alltrim(QM6->QM6_ERSIST)
		dMtErrSis := QM6->QM6_DATA
	Else
		cMtErrSis := "- - -"
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ R / R . Obs E necessario pegar o ultimo RR por isso usamos Do While ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM4")
dbSetOrder(1)
If dbSeek(xFilial("QM4")+cMtInstr+cMtRevi)
	While !Eof() .And. QM4->QM4_FILIAL+QM4->QM4_INSTR+QM4->QM4_REVINS ==;
		xFilial("QM4")+cMtInstr+cMtRevi

		cMtRR := Alltrim(Str(QM4->QM4_PRR)) + " %"
		dMtRR := QM4->QM4_DATA

		dbSkip()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a tela com os novos dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMtStatus:Refresh()
oMtProxDtC:Refresh()
oMtRR:Refresh()
oMtIncEnc:Refresh()
oMtErrSis:Refresh()
odMtStatus:Refresh()
odMtProxCal:Refresh()
odMtRR:Refresh()
odMtIncEnc:Refresh()
odMtErrSis:Refresh()

RestArea( aArea )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020MoEsc ³ Autor ³ Fernando Godoy		³ Data ³ 3/19/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta os dados da escala 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Varios 													  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Change do dbtree											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020MoEsc(cMtCodEsc,cMtRevEsc,cMtEscInc,cMtEscErr,cMtEscTol,cMtEscPre,;
		cMtEscExa,cMtEscAce,cMtEscAde,cMtEscSta,cMtEscRed,cMtEscCer,;
		oMtCodEsc,oMtRevEsc,oMtEscInc,oMtEscErr,oMtEscTol,oMtEscPre,oMtEscExa,;
		oMtEscAce,oMtEscAde,oMtEscSta,oMtEscRed,oMtEscCer,nPosCar,nPosEsc,aTree,;
		oTree,nPosLau,oSyCodEsc,oSyRevEsc,oSyEscInc,oSyEscErr,oSyEscTol,oSyEscPre,;
		oSyEscExa,oSyEscAce,oSyEscAde,oSyEscSta,oSyEscRed)

Local nPos			:= C020RetPos( aTree,nPosCar,oTree )
Local cAprovado	:= Capital(GetMv("MV_QAPROV"))
Local cAproCond	:= Capital(GetMv("MV_QAPCON"))
Local cReprovado	:= Capital(GetMv("MV_QREPRO"))

cMtCodEsc := aTree[nPos,nPosEsc,1,1]
cMtRevEsc := aTree[nPos,nPosEsc,1,2]
cMtEscInc := aTree[nPos,nPosEsc,1,3]
cMtEscErr := aTree[nPos,nPosEsc,1,4]
cMtEscTol := aTree[nPos,nPosEsc,1,5]
cMtEscExa := Iif(aTree[nPos,nPosEsc,1,6],STR0061,STR0062) //"Aceito"###"Rejeitado"
cMtEscAce := Iif(aTree[nPos,nPosEsc,1,7],STR0061,STR0062) //"Aceito"###"Rejeitado"
cMtEscAde := Iif(aTree[nPos,nPosEsc,1,8],STR0061,STR0062) //"Aceito"###"Rejeitado"
cMtEscSta := Iif(aTree[nPos,nPosEsc,1,9]=="A",cAprovado,;
	Iif(aTree[nPos,nPosEsc,1,9]=="C",cAproCond,Iif(Empty(aTree[nPos,nPosEsc,1,9]),"",cReprovado)))

cMtEscRed := aTree[nPos,nPosEsc,1,10]
cMtEscPre := aTree[nPos,nPosEsc,1,11]
cMtEscCer := aTree[nPos,nPosEsc,1,12]

oMtEscExa:nClrText := Iif(aTree[nPos,nPosEsc,1,6],CLR_BLUE,CLR_HRED)
oMtEscAce:nClrText := Iif(aTree[nPos,nPosEsc,1,7],CLR_BLUE,CLR_HRED)
oMtEscAde:nClrText := Iif(aTree[nPos,nPosEsc,1,8],CLR_BLUE,CLR_HRED)
oMtEscSta:nClrText := Iif(aTree[nPos,nPosEsc,1,9]=="A",;
	CLR_BLUE,Iif(aTree[nPos,nPosEsc,1,9]=="C",CLR_YELLOW,CLR_HRED))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os dados a mostrar na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(aTree[nPos,nPosLau]) $ "3#4"
	oMtEscInc:Disable()
	oMtEscErr:Disable()
	oMtEscExa:Disable()
	oMtEscAce:Disable()
	oMtEscAde:Disable()
	cMtEscInc := ""
	cMtEscErr := ""
	cMtEscExa := ""
	cMtEscAce := ""
	cMtEscAde := ""
	oSyEscInc:Disable()
	oSyEscErr:Disable()
	oSyEscExa:Disable()
	oSyEscAce:Disable()
	oSyEscAde:Disable()
Elseif Alltrim(aTree[nPos,nPosLau]) $ "2"
	oMtEscInc:Enable()
	oMtEscErr:Enable()
	oMtEscExa:Disable()
	oMtEscAce:Disable()
	oMtEscAde:Disable()
	cMtEscExa := ""
	cMtEscAce := ""
	cMtEscAde := ""
	oSyEscInc:Enable()
	oSyEscErr:Enable()
	oSyEscExa:Disable()
	oSyEscAce:Disable()
	oSyEscAde:Disable()
Else
	oMtEscInc:Enable()
	oMtEscErr:Enable()
	oMtEscExa:Enable()
	oMtEscAce:Enable()
	oMtEscAde:Enable()
	oSyEscInc:Enable()
	oSyEscErr:Enable()
	oSyEscExa:Enable()
	oSyEscAce:Enable()
	oSyEscAde:Enable()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refresh dos dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMtCodEsc:Refresh()
oMtRevEsc:Refresh()
oMtEscInc:Refresh()
oMtEscErr:Refresh()
oMtEscTol:Refresh()
oMtEscPre:Refresh()
oMtEscExa:Refresh()
oMtEscAce:Refresh()
oMtEscAde:Refresh()
oMtEscSta:Refresh()
oMtEscRed:Refresh()
oMtEscCer:Refresh()
oSyEscInc:Refresh()
oSyEscErr:Refresh()
oSyEscExa:Refresh()
oSyEscAce:Refresh()
oSyEscAde:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020MoPad ³ Autor ³ Fernando Godoy		³ Data ³ 3/19/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta os valores da tela de pontos						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Varios 													  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Change do dbtree											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020MoPad(cMtCodPad,cMtRevPad,cMtPadInc,cMtPadErr,cMtPadExa,;
	cMtPadAce,cMtPadAde,cMtPadSta,oMtCodPad,oMtRevPad,oMtPadInc,oMtPadErr,;
	oMtPadExa,oMtPadAce,oMtPadAde,oMtPadSta,nPosCar,nPosPad,aTree,oTree,;
	nPosLau,oSyCodPad,oSyRevPad,oSyPadInc,oSyPadErr,oSyPadExa,oSyPadAce,;
	oSyPadAde,oSyPadSta)

Local nPos			:= C020RetPos( aTree,nPosCar,oTree )
Local cAprovado	:= Capital(GetMv("MV_QAPROV"))
Local cAproCond	:= Capital(GetMv("MV_QAPCON"))
Local cReprovado	:= Capital(GetMv("MV_QREPRO"))

cMtCodPad := aTree[nPos,nPosPad,1,1]
If !Empty(aTree[nPos,nPosPad,1,2]) // Caso for PADRAEXT (Externa s/medicao - mostrar revisao 00)
	cMtRevPad := aTree[nPos,nPosPad,1,2]
Else
	cMtRevPad := "00"
Endif
cMtPadInc := aTree[nPos,nPosPad,1,3]
cMtPadErr := aTree[nPos,nPosPad,1,4]
cMtPadExa := Iif(aTree[nPos,nPosPad,1,5]=="A",STR0061,STR0062) //"Aceito"###"Rejeitado"
cMtPadAce := Iif(aTree[nPos,nPosPad,1,6]=="A",STR0061,STR0062) //"Aceito"###"Rejeitado"
cMtPadAde := Iif(aTree[nPos,nPosPad,1,7]=="A",STR0061,STR0062) //"Aceito"###"Rejeitado"
cMtPadSta := Iif(aTree[nPos,nPosPad,1,8]=="A",cAprovado,;
	Iif(aTree[nPos,nPosPad,1,8]=="C",cAproCond,Iif(Empty(aTree[nPos,nPosPad,1,8]),"",cReprovado)))

oMtPadExa:nClrText := Iif(aTree[nPos,nPosPad,1,5]=="A",CLR_BLUE,CLR_HRED)
oMtPadAce:nClrText := Iif(aTree[nPos,nPosPad,1,6]=="A",CLR_BLUE,CLR_HRED)
oMtPadAde:nClrText := Iif(aTree[nPos,nPosPad,1,7]=="A",CLR_BLUE,CLR_HRED)
oMtPadSta:nClrText := Iif(aTree[nPos,nPosPad,1,8]=="A",;
	CLR_BLUE,Iif(aTree[nPos,nPosPad,1,8]=="C",CLR_YELLOW,CLR_HRED))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os dados a mostrar na tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(aTree[nPos,nPosLau]) $ "3#4"
	oMtPadInc:Disable()
	oMtPadErr:Disable()
	oMtPadExa:Disable()
	oMtPadAce:Disable()
	oMtPadAde:Disable()
	cMtPadInc := ""
	cMtPadErr := ""
	cMtPadExa := ""
	cMtPadAce := ""
	cMtPadAde := ""
	oSyPadInc:Disable()
	oSyPadErr:Disable()
	oSyPadExa:Disable()
	oSyPadAce:Disable()
	oSyPadAde:Disable()
Elseif Alltrim(aTree[nPos,nPosLau]) $ "2"
	oMtPadInc:Enable()
	oMtPadErr:Enable()
	oMtPadExa:Disable()
	oMtPadAce:Disable()
	oMtPadAde:Disable()
	cMtPadExa := ""
	cMtPadAce := ""
	cMtPadAde := ""
	oSyPadInc:Enable()
	oSyPadErr:Enable()
	oSyPadExa:Disable()
	oSyPadAce:Disable()
	oSyPadAde:Disable()
Else
	oMtPadInc:Enable()
	oMtPadErr:Enable()
	oMtPadExa:Enable()
	oMtPadAce:Enable()
	oMtPadAde:Enable()
	oSyPadInc:Enable()
	oSyPadErr:Enable()
	oSyPadExa:Enable()
	oSyPadAce:Enable()
	oSyPadAde:Enable()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refresh dos dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMtCodPad:Refresh()
oMtRevPad:Refresh()
oMtPadInc:Refresh()
oMtPadErr:Refresh()
oMtPadExa:Refresh()
oMtPadAce:Refresh()
oMtPadAde:Refresh()
oMtPadSta:Refresh()
oSyPadInc:Refresh()
oSyPadErr:Refresh()
oSyPadExa:Refresh()
oSyPadAce:Refresh()
oSyPadAde:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020RetPos³ Autor ³ Fernando Godoy		³ Data ³ 3/19/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpN1 - Posicao no array aTree 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020RetPos( aTree,nPosCar,oTree )
Local nPos	:= 0
Local cCargo := Left(oTree:GetCargo(),8)

nPos := Ascan( aTree, { |x| x[nPosCar] == cCargo })

If nPos == 0
	nPos := 1
EndIf

Return nPos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³C020MoMed ³ Autor ³ Fernando Godoy		³ Data ³ 3/19/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra as medicoes na tela								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Change do dbtree											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020MoMed(oLbx,aTree,oTree,nPosCar,nPosMed,aMedicoes,oBrw,oBrw1,oBrw2)
Local aHeader	 := {}
Local aColSizes := {}
Local nPos		 := C020RetPos(aTree,nPosCar,oTree)
Local lRet		 := .T.

If Len(aTree[nPos,nPosMed]) > 0

	aMedicoes := {}
	aMedicoes := Aclone(aTree[nPos,nPosMed])

	If Len(aMedicoes[1]) == 1
    	oBrw1:SetArray( aMedicoes )
		aHeader	:= { STR0063 } //"Val.Final"
		aColSizes := { 90 }
		oBrw1:bLine	:= { || { aMedicoes[oBrw1:nAt,1] } }
		oBrw1:aHeaders	:= aHeader
		oBrw1:aColSizes := aColSizes
		oBrw1:Refresh()

	Elseif Len(aMedicoes[1]) == 2
		oBrw:SetArray( aMedicoes )
		aHeader	 := { STR0064,STR0063 } //"Val.Inicial"###"Val.Final"
		aColSizes := { 90,90 }
		oBrw:bLine	:= { || { aMedicoes[oBrw:nAt,1],aMedicoes[oBrw:nAt,2] } }
		oBrw:aHeaders	:= aHeader
		oBrw:aColSizes := aColSizes
		oBrw:Refresh()

	Else
		oBrw2:SetArray( aMedicoes )
		aHeader	 := { STR0064,STR0063,STR0064,STR0063 } //"Val.Inicial"###"Val.Final"###"Val.Inicial"###"Val.Final"
		aColSizes := { 90,90,90,90 }

		oBrw2:bLine	:= { || { aMedicoes[oBrw2:nAt,1],aMedicoes[oBrw2:nAt,2],;
									 aMedicoes[oBrw2:nAt,3],aMedicoes[oBrw2:nAt,4] } }

		oBrw2:aHeaders	:= aHeader
		oBrw2:aColSizes := aColSizes
		oBrw2:Refresh()
	EndIf

Else
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A020InsEsc³ Autora³ Iuri Seto             ³ Data ³ 15/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se é instrumento Malha e retorna o codigo do      ³±±
±±³          ³ instrumento que se refere a escalha atual.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do Instrumento         					  ³±±
±±³          ³ ExpC2 : Escala do Instrumento         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 : Código do Instrumento Filho/Escala do Instrumento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMTC020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020InsEsc(cMtInstr,cEscala)
Local cOldAlias := Select()
LocaL nReg := Recno()
Local nOrdem := IndexOrd()
LocaL nQM2Reg := QM2->(Recno())
Local nQM2Ordem := QM2->(IndexOrd())
Local cInsEsc

cInsEsc := cEscala
dbSelectArea("QM2")
dbSetOrder(7)
If QM2->(dbSeek(xFilial("QM2")+"M"+cMtInstr+cEscala))
	cInsEsc := QM2->QM2_INSTR
EndIf
dbSetOrder(nQM2Ordem)
dbGoto(nQM2Reg)


dbSelectArea(cOldAlias)
dbSetOrder(nOrdem)
dbGoto(nReg)
Return(cInsEsc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C020MoPdSecºAutor  ³Denis Martins       º Data ³  08/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta padroes secundarios por escala/padrao                  º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp1:Array Escala/Padroes                                    º±±
±±º          ³Exp2:Posicao Geral                                           º±±
±±º          ³Exp3:Objeto Tree                                             º±±
±±º          ³Exp4:Posicao Padrao Secundario                               º±±
±±º		     ³Exp5:Objeto ListBox                                          º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTC020                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C020MoPdSec(aTree,nPosCar,oTree,nPosSec,oBrw3,aMedicoes)

Local aHeader	 := {}
Local aColSizes	 := {}
Local nPos		 := C020RetPos(aTree,nPosCar,oTree)
Local lRet		 := .T.

If Len(aTree[nPos,nPosSec]) > 0
	aMedicoes := {}
	aMedicoes := Aclone(aTree[nPos,nPosSec])
	If Len(aMedicoes) > 0
		oBrw3:SetArray( aMedicoes )
		aHeader	 :=  { STR0069,STR0070,STR0071}  //"Pad.Secundario"###"Escala"###"Incerteza"
		aColSizes := { 90,90,90 }

		oBrw3:bLine	:= { || { aMedicoes[oBrw3:nAt,1],aMedicoes[oBrw3:nAt,2],;
								 aMedicoes[oBrw3:nAt,3] } }
	Endif
Else
	aMedicoes		 := Array(1,4)
	oBrw3:SetArray( aMedicoes )
	lRet := .F.
Endif

oBrw3:aHeaders	:= aHeader
oBrw3:aColSizes := aColSizes
oBrw3:Refresh()

Return lRet