#INCLUDE "MATC010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBrowse.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATC010	³ Autor ³ Eveli Morasco         ³ Data ³ 22/06/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Formacao de Precos c/ base na estrutura do produto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rodrigo Sart³13/08/98³16456A³Acerto na insercao de linhas              ³±±
±±³Fernando J. ³18/01/99³19743A³Passar a Filial correta na Func.Posicione.³±±
±±³CesarValadao³24/05/99³PROTHE³Manutencao do metodo :End e :DrawLine.    ³±±
±±³CesarValadao³15/06/99³PROTHE³Inclusao do :bLine em oCusto e oPlan.     ³±±
±±³CesarValadao³13/10/99³22282A³Novo Lay-Out com Celula Percentual com 4  ³±±
±±³            ³        ³      ³Digitos e Formula com 100 Caracteres.     ³±±
±±³CesarValadao³03/01/00³1837  ³Acerto na Exclusao de Linha Total/Formula ³±±
±±³Iuspa       ³28/08/00³5742  ³mv_par03 Inclui produto quant neg estrut? ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATC010
LOCAL cArea       := Alias()

PRIVATE aRotina   := MenuDef()
PRIVATE cArqMemo  := "STANDARD"
PRIVATE cCodPlan  := ""
PRIVATE cCodRev	  := ""
PRIVATE lDirecao  := .T.
PRIVATE lExibeHelp:= .T.
PRIVATE lPesqRev  := .F.
PRIVATE nQualCusto:= 1

PRIVATE aArray    :={}
PRIVATE aHeader   :={}
PRIVATE aTotais   :={}
PRIVATE cCadastro := OemToAnsi(STR0003)	//"Forma‡„o de Pre‡os"
PRIVATE lMC010GRV := (ExistBlock("MC010GRV")) //Ponto de Entrada p/ gravar campos na base de dados
PRIVATE cProg     := "C010"
PRIVATE nQtdFormula
PRIVATE nQtdTotais
PRIVATE cCusto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega variaveis Codigo/Revisao                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   cCodPlan  := StrZero(1,TamSx3("CO_CODIGO")[1])
   cCodRev	 := StrZero(1,TamSx3("CO_REVISAO")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o M¢dulo que chama a fun‡„o seja o SIGALOJA        ³
//³ abre o arquivo SG1. esta implementa‡„o visa a libera‡„o ³
//³ de FILES do MS-DOS para o Sigaloja                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo == 12 .Or. nModulo == 72 // SIGALOJA //SIGAPHOTO
	ChkFile("SG1")
	ChkFile("SGG")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para acionar perguntas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12 To MTC010PERG()

Pergunte("MTC010", .F.)

// Verifica o Nivel de Estrutura
If Empty(mv_par11)
	mv_par11 := 999
EndIf

mBrowse(6,1,22,75,"SB1",,,,,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o M¢dulo que chama a fun‡„o seja o SIGALOJA        ³
//³ Fech o arquivo SG1. esta implementa‡„o visa a libera‡„o ³
//³ de FILES do MS-DOS para o Sigaloja                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo == 12 .Or. nModulo == 72 // SIGALOJA //SIGAPHOTO
	dbSelectArea("SG1")
	dbCloseArea()
	dbSelectArea("SGG")
	dbCloseArea()
	dbSelectArea(cArea)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla que aciona perguntas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12 To

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BrowPlanW ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a tela dos Browses                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BrowPlanW(nMatPrima,aFormulas,nTipo)
LOCAL lAutoCalc, aProd:={}, lMatPrima:=.T., nPos:=1
LOCAL oBtnA, oBtnD, oBtnE, oBtnF, oBtnG
LOCAL oDlg, oFont, oBMP
LOCAL aObjects   :={}
LOCAL aPosObj    :={}
LOCAL aSize		 :=MsAdvSize(.F.)
LOCAL aInfo      :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
LOCAL lLoop      := .F.
LOCAL lRetPEButP := .F.  // Habilita botao 'PLANILHA'
LOCAL lMc10Bgrv  := .F.
Local bVldLbox 	 := { || Ascan( aArray,{ | x | AllTrim( Str( x[1],5 ) ) == AllTrim( aProd[oLbx:nAt,1] ) .And. AllTrim( x[3] ) == AllTrim( aProd[oLbx:nAt,3] ) } ) }
Local bVldTot	 := { || Ascan( aArray,{ | x | AllTrim( Str( x[1],5 ) ) == AllTrim( aTot[oTot:nAt,1]  ) .And. AllTrim( x[3] ) == AllTrim( aTot[oTot:nAt,2] ) } ) }

STATIC oTot,oLbx
PRIVATE cTitulo:=STR0004+cArqMemo+STR0005+cCusto+If(!Empty(mv_par04),STR0035+mv_par04,"") 	//" Planilha "###" - Custo "###" - Revisao "
PRIVATE cBMPName:=If(lDirecao,"VCPGDOWN","VCPGUP")
PRIVATE aMC010Arred
PRIVATE aTot:={}

DEFAULT nTipo := 1

InitArray(.T., @aProd, aFormulas, nMatPrima)
InitArray(.F., @aTot,  aFormulas, nMatPrima)

nTamcol := GetTextWidh(0,"99.999.999,99")

PERGUNTE("MTC010",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado mostrar o botao de gravacao mesmo quando o ntipo for igual a 2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('MC10BGRV')
	lMc10Bgrv := If(ValType(lMc10Bgrv:=ExecBlock('MC10BGRV', .F., .F., {nTipo}))=='L',lMc10Bgrv,.F.)
Endif

lAutoCalc := If(mv_par01==1,.T.,.F.)

AADD(aObjects,{450,50,.T.,.T.,.T.})
AADD(aObjects,{450,50,.T.,.T.,.T.})
aPosObj:=MsObjSize(aInfo,aObjects)
DEFINE MSDIALOG oDlg TITLE cTitulo OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	oFont:= oDlg:oFont
	If cProg == "A318"
		oLbx := TCBROWSE():New(1,1,1,1, , , , , , , , , , ,oFont, , , , , .F., , .T., , .F.,,)
		cCodPlan := SCO->CO_CODIGO
		cCodRev  := SCO->CO_REVISAO
		cArqMemo := SCO->CO_NOME
		lPesqRev:= .T.
	Else
		oLbx := TCBROWSE():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3]-50,aPosObj[1,4], , , , , , , , , , ,oFont, , , , , .F., , .T., , .F.,,)
	EndIf
	oLbx:bLDblClick	:= { | nRow, nCol | ( Eval( oBtnA:bAction ),nPos := Eval( bVldLbox ) ) }
	oLbx:bChange  	:= {|| nPos := Eval( bVldLbox ) }
	oLbx:bGotFocus	:= {|| ( nPos := Eval( bVldLbox ), lMatPrima:=.T. ) }
	oLbx:nAt 		:= nPos

	ADD COLUMN TO oLbx HEADER aHeader[1,1] OEM DATA {|| aProd[oLbx:nAt,1] } ALIGN LEFT SIZE CalcFieldSize("C",03,0,aHeader[1,2],aHeader[1,1]) PIXELS
	ADD COLUMN TO oLbx HEADER aHeader[2,1] OEM DATA {|| aProd[oLbx:nAt,2] } ALIGN LEFT SIZE CalcFieldSize("C",08,0,aHeader[2,2],aHeader[2,1]) PIXELS
	ADD COLUMN TO oLbx HEADER aHeader[3,1] OEM DATA {|| aProd[oLbx:nAt,3] } ALIGN LEFT SIZE CalcFieldSize("C",TamSx3('CO_DESC')[1],0,aHeader[3,2],aHeader[3,1]) PIXELS
	ADD COLUMN TO oLbx HEADER aHeader[4,1] OEM DATA {|| aProd[oLbx:nAt,4] } ALIGN LEFT SIZE CalcFieldSize("C",15,0,aHeader[4,2],aHeader[4,1]) PIXELS
	ADD COLUMN TO oLbx HEADER aHeader[5,1] OEM DATA {|| aProd[oLbx:nAt,5] } ALIGN LEFT SIZE CalcFieldSize("C",Len(aProd[oLbx:nAt,5]),0,,aHeader[5,1]) PIXELS
	ADD COLUMN TO oLbx HEADER aHeader[6,1] OEM DATA {|| aProd[oLbx:nAt,6] } ALIGN LEFT SIZE CalcFieldSize("C",Len(aProd[oLbx:nAt,6]),0,,aHeader[6,1]) PIXELS
	ADD COLUMN TO oLbx HEADER aHeader[7,1] OEM DATA {|| aProd[oLbx:nAt,7] } ALIGN LEFT SIZE CalcFieldSize("C",Len(aProd[oLbx:nAt,7]),0,,aHeader[7,1]) PIXELS
	oLbx:SetArray(aProd)

	If cProg == "A318"
		oLbx:Hide()
		oTot := TCBROWSE():New(aPosObj[1,1],aPosObj[1,2],aPosObj[2,3]-50,aPosObj[1,4] + aPosObj[2,4], , , , , , , , , , ,oFont, , , , , .F., , .T., , .F.,,)
	Else
		oTot := TCBROWSE():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-50,aPosObj[2,4], , , , , , , , , , ,oFont, , , , , .F., , .T., , .F.,,)
	EndIf
	oTot:bLDblClick := { | nRow, nCol | ( Eval(oBtnA:bAction),nPos := Eval( bVldTot ) ) }
	oTot:bChange    := {|| nPos := Eval( bVldTot ) }
	oTot:bGotFocus  := {|| lMatPrima:=.F. }
	oTot:nAt := nPos

	ADD COLUMN TO oTot HEADER aheader[1,1] OEM DATA {|| aTot[oTot:nAt,1] } ALIGN LEFT SIZE CalcFieldSize("C",03,0,aHeader[1,2],aHeader[1,1]) PIXELS
	ADD COLUMN TO oTot HEADER aHeader[3,1] OEM DATA {|| aTot[oTot:nAt,2] } ALIGN LEFT SIZE CalcFieldSize("C",30,0,aHeader[3,2],aHeader[3,1]) PIXELS
	ADD COLUMN TO oTot HEADER aHeader[6,1] OEM DATA {|| aTot[oTot:nAt,4] } ALIGN LEFT SIZE CalcFieldSize("C",Len(aTot[oTot:nAt,4]),0,,aHeader[6,1]) PIXELS
	ADD COLUMN TO oTot HEADER aHeader[7,1] OEM DATA {|| aTot[oTot:nAt,5] } ALIGN LEFT SIZE CalcFieldSize("C",Len(aTot[oTot:nAt,5]),0,,aHeader[7,1]) PIXELS
	ADD COLUMN TO oTot HEADER OemToAnsi(STR0006) OEM DATA {|| aTot[oTot:nAt,3] } ALIGN LEFT SIZE CalcFieldSize("C",Len(aTot[oTot:nAt,3]),0,,STR0006) PIXELS	//"F¢rmula"
 	oTot:SetArray(aTot)

	DEFINE SBUTTON 		 FROM aPosObj[1,4]-65,aPosObj[1,3]-33 TYPE 4  ENABLE OF oDlg Action Insere(IIF(lMatPrima,@aProd,@aTot),lMatPrima,nPos,@aFormulas,@nMatPrima,lAutoCalc,@oLbx,@oTot)
	DEFINE SBUTTON oBtnA FROM aPosObj[1,4]-50,aPosObj[1,3]-33 TYPE 11 ENABLE OF oDlg Action Altera(IIF(lMatPrima,@aProd,@aTot),lMatPrima,nPos,@aFormulas,nMatPrima,lAutoCalc,@oLbx,@oTot)
	DEFINE SBUTTON 		 FROM aPosObj[1,4]-35,aPosObj[1,3]-33 TYPE 3  ENABLE OF oDlg Action Deleta(IIF(lMatPrima,@aProd,@aTot),lMatPrima,nPos,aFormulas,@nMatPrima,lAutoCalc,@oLbx,@oTot)
	If nTipo == 1 .Or. lMc10Bgrv
		If SuperGetMV("MV_REVPLAN",.F.,.F.)
			DEFINE SBUTTON 		 FROM aPosObj[1,4]-20,aPosObj[1,3]-33 TYPE 13 ENABLE OF oDlg Action (MC010GRVEX(.T.),GeraRev(nMatPrima,aFormulas,oDlg))
		Else
			DEFINE SBUTTON 		 FROM aPosObj[1,4]-20,aPosObj[1,3]-33 TYPE 13 ENABLE OF oDlg Action (MC010GRVEX(.T.),Grava(nMatPrima,aFormulas,oDlg))
		EndIf
			DEFINE SBUTTON 		 FROM aPosObj[1,4]-05,aPosObj[1,3]-33 TYPE 2  ENABLE OF oDlg Action (MC010GRVEX(.F.),oDlg:End())
	Else
		DEFINE SBUTTON 		 FROM aPosObj[1,4]-20,aPosObj[1,3]-33 TYPE 2  ENABLE OF oDlg Action (oDlg:End())
	Endif

	@ aPosObj[2,1]+05,aPosObj[2,3]-41 BITMAP oBMP NAME If(lDirecao,"VCPGDOWN","VCPGUP") SIZE 5,6 OF oDlg PIXEL NO BORDER

	@ aPosObj[2,1]+00,aPosObj[2,3]-41 BUTTON oBtnE Prompt OemToAnsi(STR0001) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),Pesquisa(oLbx,aProd,oDlg),DisBut(oBtnD,oBtnE,oBtnF,.F.,lRetPEButP),Def(.F., @oTot, aTot));oBtnE:oFont:=oDlg:oFont	//"&Pesquisar"

	If cProg != "A318"
		If nTipo == 1
			If SuperGetMV("MV_REVPLAN",.F.,.F.)
				@ aPosObj[2,1]+15,aPosObj[2,3]-41 BUTTON oBtnD Prompt OemToAnsi(STR0007) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),IIF(PlanRev(oBtnD,oBtnE,oBtnF),(oDlg:End(),lLoop:=.T.),))
				oBtnD:oFont:= oDlg:oFont	//"&Planilha"
			Else
				@ aPosObj[2,1]+15,aPosObj[2,3]-41 BUTTON oBtnD Prompt OemToAnsi(STR0007) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),IIF(Planilha(oBtnD,oBtnE,oBtnF),(oDlg:End(),lLoop:=.T.),))
				oBtnD:oFont:= oDlg:oFont	//"&Planilha"
			EndIf
		Else
			If SuperGetMV("MV_REVPLAN",.F.,.F.)
				@ aPosObj[2,1]+15,aPosObj[2,3]-41 BUTTON oBtnD Prompt OemToAnsi(STR0007) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),IIF(PlanRev(oBtnD,oBtnE,oBtnF),(oDlg:End(),lLoop:=.T.),))
				oBtnD:oFont:= oDlg:oFont	//"&Planilha"
			Else
				@ aPosObj[2,1]+15,aPosObj[2,3]-41 BUTTON oBtnD Prompt OemToAnsi(STR0007) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),IIF(Planilha(oBtnD,oBtnE,oBtnF),(oDlg:End(),lLoop:=.T.),))
				oBtnD:oFont:= oDlg:oFont	//"&Planilha"
			EndIf
		EndIf
	Else
		If SuperGetMV("MV_REVPLAN",.F.,.F.)
			@ aPosObj[2,1]+15,aPosObj[2,3]-41 BUTTON oBtnD Prompt OemToAnsi(STR0007) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),IIF(PlanRev(oBtnD,oBtnE,oBtnF),(oDlg:End(),lLoop:=.T.),))
			oBtnD:oFont:= oDlg:oFont	//"&Planilha"
		Else
			@ aPosObj[2,1]+15,aPosObj[2,3]-41 BUTTON oBtnD Prompt OemToAnsi(STR0007) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),IIF(Planilha(oBtnD,oBtnE,oBtnF),(oDlg:End(),lLoop:=.T.),))
			oBtnD:oFont:= oDlg:oFont	//"&Planilha"
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MC010BUT - Ponto de Entrada para criar botoes de usuario.		 	 ³
	//³            Outro uso: Retornando .T. inibe o botao 'Planilha'. 		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetPEButP:= .F.
	If (ExistBlock("MC010BUT"))
		lRetPEButP := ExecBlock("MC010BUT",.F.,.F.,{@oDlg,aPosObj,aProd,aFormulas,aTot})
		lRetPEButP := If(ValType(lRetPEButP)=="L",lRetPEButP,.F.)
	EndIf
	If lRetPEButP
		oBtnD:Disable()
	EndIf

	@ aPosObj[2,1]+30,aPosObj[2,3]-41 BUTTON oBtnE Prompt OemToAnsi(STR0008) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),ReCalculo(nMatPrima,@aProd,@aTot,aFormulas),DisBut(oBtnD,oBtnE,oBtnF,.F.,lRetPEButP),Def(.F., @oTot, aTot));oBtnE:oFont:=oDlg:oFont	//"&Rec lculo"
	@ aPosObj[2,1]+45,aPosObj[2,3]-41 BUTTON oBtnF Prompt OemToAnsi(STR0009) SIZE 44, 11 OF oDlg PIXEL Action (DisBut(oBtnD,oBtnE,oBtnF,.T.,lRetPEButP),Custo(@aTot,@aProd,nMatPrima,@aFormulas,oDlg),Def(.F.,@oTot,aTot),Def(.T.,@oLbx,aProd),DisBut(oBtnD,oBtnE,oBtnF,.F.,lRetPEButP));oBtnF:oFont:= oDlg:oFont	//"&Custo"
	@ aPosObj[2,1]+60,aPosObj[2,3]-41 BUTTON oBtnG Prompt OemToAnsi(STR0034) SIZE 44, 11 OF oDlg PIXEL Action (lDirecao:=!lDirecao, oBMP:SetBMP(If(lDirecao,"VCPGDOWN","VCPGUP")))	//"&Dire‡„o"
ACTIVATE MSDIALOG oDlg
If lLoop
	lLoop:=.F.
	If nTipo == 1
		If SuperGetMV("MV_REVPLAN",.F.,.F.)
			MC010Form2(Alias(),Recno(),2,,,,,lPesqRev,cCodPlan,cCodRev)
		Else
			MC010Forma(Alias(),Recno(),2)
		EndIf
	Else
		If SuperGetMV("MV_REVPLAN",.F.,.F.)
			MC010Form2("SB1",SB1->(Recno()),98,1,2)
	    Else
			MC010Forma("SB1",SB1->(Recno()),98,1,2)
		EndIf
	EndIf
EndIf
RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Altera   ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera o conteudo da Linha da planilha                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Altera(aArr,lMatPrima,n,aFormulas,nMatPrima,lAutoCalc,oLbx,oTot)
LOCAL nUltNivel
LOCAL nX,nQuantAnt,nValTotAnt, nTempSet := 0
LOCAL nDec:=0,nTam:=0
LOCAL cProd:="",cDesc:="",nQtd:=0,nValtot:=0,nPerc:=0
LOCAL cDescricao := ""
LOCAL cAlias:=Alias(),nOrder:=IndexOrd(),nRecno:=Recno()
LOCAL cCelPer:=Space(5)
LOCAL cFormula
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas p/ verificar se produto e'fixo/variavel         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nNiv:=1000,lFixo:=.F.

Local lInt 		:=  Len(aArray[n]) >= 15 .And. ValType(aArray[n][15]) == "A" .And. Len(aArray[n][15]) >= 2

Local cIntPv	:= Iif( lInt, aArray[n][15][1], Nil)
Local cIntPub	:= Iif( lInt, aArray[n][15][2], Nil)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis do GET                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesc 		:=aArray[n,3]
cProd 		:=aArray[n,4]
nQtd		:=aArray[n,5]
nQuantAnt	:=aArray[n,5]
nValTot		:=aArray[n,6]
nValTotAnt	:=aArray[n,6]
nPerc 		:=aArray[n,7]
If lMatPrima
	If GetProd(@aArr,lMatPrima,@cProd,@cDesc,@nQtd,@nValTot,@nPerc,n,nMatPrima,lAutoCalc,aFormulas,.F.)
		If n > nMatPrima+nQtdTotais
			nTam := Len(Subs(Trim(aHeader[6,2]),AT("9",Trim(aHeader[6,2])),Len(Trim(aHeader[6,2]))))
			nDec := Len(Subs(Trim(aHeader[6,2]),AT(".",Trim(aHeader[6,2]))+1,Len(Trim(aHeader[6,2]))-AT(".",Trim(aHeader[6,2]))))
			nDec := IIF(nDec==0,2,nDec)
			aFormulas[n-nMatPrima-nQtdTotais,1] := PadR(Str(nValTot,nTam,nDec),100)
		EndIf
		aArray[n][3] := cDesc
		aArray[n][4] := cProd
		aArray[n][5] := nQtd
		aArray[n][6] := nValTot
		If nQtd != nQuantAnt .Or. nValTot != nValTotAnt
			dbSelectArea(If(mv_par09=1,"SG1","SGG"))
			dbSetOrder(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe produto fixo na estrutura                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := n+1 To nMatPrima-2
				If Val(aArray[nx][2]) > Val(aArray[n][2])
					If aArray[nX][13] $ "V "
						If Val(aArray[nx,2]) <= nNiv
							lFixo:=.F.
							nNiv:=Val(aArray[nx,2])
						EndIf
					Else
						If Val(aArray[nx,2]) <= nNiv
							lFixo:=.T.
							nNiv:=Val(aArray[nx,2])
						EndIf
					EndIf
					If !lFixo .And. aArray[nX][13] $ "V "
					    If !(IsProdMod(Upper(aArray[nX][4])))
						   aArray[nX][5] := (aArray[nX][5]/nQuantAnt) * nqtd
						   aArray[nX][6] := (aArray[nX][6]/nQuantAnt) * nqtd
						Else
						   nTempSet:=MC010SETUP(aArray[1][4],aArray[nx,5],nQtd,nQuantAnt,aArray[nx,14])
						   aArray[nX][5] := nTempSet
					       nTempSet:=MC010SETUP(aArray[1][4],aArray[nx,6],nQtd,nQuantAnt,aArray[nx,14])
						   aArray[nX][6] := nTempSet
						Endif
					EndIf
				Else
					Exit
				EndIf
			Next nX
		EndIf
		dbSelectArea(cAlias)
		dbSetOrder(nOrder)
		MsGoto(nRecno)
		nUltNivel := CalcUltNiv()
		CalcTot(nMatPrima,nUltNivel,aFormulas,nQualCusto)
		InitArray(lMatPrima,@aArr,aFormulas, nMatPrima)
		Def(lMatPrima,@oLbx,aArr)
	EndIf
Else
	If n >= nMatPrima .And. n < nMatPrima+nQtdTotais
		cDescricao := aArray[n][3]
		cFormula   := aTotais[(n-nMatPrima)+1]
		If GetFormula(@aArr,@cDescricao,@cFormula,@nValTot,n,nMatPrima,,@cIntPv,@cIntPub)
			aArray[n][3]             := cDescricao
			If lInt
				aArray[n][15][1] := cIntPv
				aArray[n][15][2] := cIntPub
			EndIf
			aTotais[(n-nMatPrima)+1] := cFormula
			If lAutoCalc
				RecalcTot(nMatPrima)
				CalcForm(aFormulas,nMatPrima)
			EndIf
			InitArray(lMatPrima,@aArr,aFormulas, nMatPrima)
			Def(lMatPrima,@oTot,aArr)
		EndIf
	ElseIf n > nMatPrima+nQtdTotais .And. n < Len(aArray)
		cDescricao := aArray[n][3]
		cFormula   := aFormulas[n-nMatPrima-nQtdTotais,1]
		cCelPer	   := Substr(aFormulas[n-nMatPrima-nQtdTotais,2],2,5)
		If GetFormula(@aArr,@cDescricao,@cFormula,@nValTot,n,nMatPrima,@cCelPer,@cIntPv,@cIntPub)
			aArray[n][3] := cDescricao
			If At("#",cFormula) > 0
				aArray[n][10] := .F.
			EndIf
			If lInt
				aArray[n][15][1] := cIntPv
				aArray[n][15][2] := cIntPub
			EndIf
			aFormulas[n-nMatPrima-nQtdTotais,1] := cFormula
			aFormulas[n-nMatPrima-nQtdTotais,2] := If(Empty(cCelPer), Space(6), "#"+cCelPer)
			If lAutoCalc
				RecalcTot(nMatPrima)
				CalcForm(aFormulas,nMatPrima)
			EndIf
			InitArray(lMatPrima,@aArr,aFormulas, nMatPrima)
			Def(lMatPrima,@oTot,aArr)
		EndIf
	EndIf
EndIf
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Deleta   ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta a Linha da planilha                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Deleta(aArr,lMatprima,n,aFormulas,nMatPrima,lAutoCalc,oLbx,oTot)

Local nX := 0
Local nUltNivel
Local cNivEstr
Local nDelet

If lMatPrima
	cNivEstr := aArray[n][2]
	If Val(cNivEstr) == 1
		Help(" ",1,"C010Nivel")
		RETURN .F.
	EndIf
	If Val(cNivEstr) == 0
		RETURN
	EndIf
	nDelet := 0
	aArray := ADel(aArray,n)
	aArray := ASize(aArray,Len(aArray)-1)
	nMatPrima--
	nDelet --
	While Val(aArray[n][2]) > Val(cNivEstr)
		aArray := ADel(aArray,n)
		aArray := ASize(aArray,Len(aArray)-1)
		nMatPrima--
		nDelet --
	End
	For nX := 1 To Len(aFormulas)
		If AT("#",aFormulas[nX,1]) > 0
			aFormulas[nX,1] := AcertaForm(aFormulas[nX,1],nDelet,n)
		EndIf
		If !Empty(aFormulas[nX,2])
			aFormulas[nX,2] := "#"+StrZero(Val(Substr(aFormulas[nx,2],2,5))+nDelet,5)
		EndIf
	Next nX
	For nX := Len(aArray) To 1 Step -1
		If aArray[nX][1] == nX
			Exit
		EndIf
		aArray[nX][1] := nX
	Next nX
	If lAutoCalc
		RecalcTot(nMatPrima)
		CalcForm(aFormulas,nMatPrima)
	EndIf
	Recalculo(nMatPrima,@aArr,@aTot,aFormulas)
	nUltNivel := CalcUltNiv()
	CalcTot(nMatPrima,nUltNivel,aFormulas,nQualCusto)
	InitArray(lMatPrima,@aArr,aFormulas, nMatPrima)
	Def(lMatPrima,@oLbx,aArr)
Else
	If n >= nMatPrima .And. n < nMatPrima+nQtdTotais
		For nX := 1 To Len(aFormulas)
			If AT("#",aFormulas[nX,1]) > 0
				aFormulas[nX,1] := AcertaForm(aFormulas[nX,1],-1,n)
			EndIf
			If !Empty(aFormulas[nX,2])
				aFormulas[nX,2] := "#"+StrZero(Val(Substr(aFormulas[nx,2],2,5))-1,5)
			EndIf
		Next nX
		aTotais := ADel(aTotais,(n-nMatPrima)+1)
		aTotais := ASize(aTotais,Len(aTotais)-1)
		nQtdTotais--
		aArray := ADel(aArray,n)
		aArray := ASize(aArray,Len(aArray)-1)
		For nX := Len(aArray) To 1 Step -1
			If aArray[nX][1] == nX
				Exit
			EndIf
			aArray[nX][1] := nX
		Next nX
		If lAutoCalc
			RecalcTot(nMatPrima)
			CalcForm(aFormulas,nMatPrima)
		EndIf
		Recalculo(nMatPrima,@aArr,@aTot,aFormulas)
	ElseIf n > nMatPrima+nQtdTotais .And. n < Len(aArray)
		For nX := 1 To Len(aFormulas)
			If AT("#",aFormulas[nX,1]) > 0
				aFormulas[nX,1] := AcertaForm(aFormulas[nX,1],-1,n)
			EndIf
			If !Empty(aFormulas[nX,2])
				aFormulas[nX,2] := "#"+StrZero(Val(Substr(aFormulas[nx,2],2,5))-1,5)
			EndIf
		Next nX
		aFormulas := ADel(aFormulas,n-nMatPrima-nQtdTotais)
		aFormulas := ASize(aFormulas,Len(aFormulas)-1)
		nQtdFormula--
		aArray := ADel(aArray,n)
		aArray := ASize(aArray,Len(aArray)-1)
		For nX := Len(aArray) To 1 Step -1
			If aArray[nX][1] == nX
				Exit
			EndIf
			aArray[nX][1] := nX
		Next nX
		If lAutoCalc
			RecalcTot(nMatPrima)
			CalcForm(aFormulas,nMatPrima)
		EndIf
		Recalculo(nMatPrima,@aArr,@aTot,aFormulas)
		InitArray(lMatPrima,@aArr,aFormulas, nMatPrima)
		Def(lMatPrima,@oTot,aArr)
	EndIf
EndIf
IF(lMatPrima,Def(lMatPrima,@oLbx,aArr),Def(lMatPrima,@oTot,aArr))
RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Insere   ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Insere uma linha na planilha                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Insere(aArr,lMatPrima,n,aFormulas,nMatprima,lAutoCalc,oLbx,oTot)
LOCAL cProd:="",nQtd:=0,nValtot:=0,nPerc:=0
LOCAL cDescricao := "",cCelPer:=Space(5)
LOCAL nX := 0
LOCAL cTrt:=If(mv_par09==1,Criavar("G1_TRT",.F.),Criavar("GG_TRT",.F.))
LOCAL cFixVar:=If(mv_par09==1,Criavar("G1_FIXVAR",.F.),Criavar("GG_FIXVAR",.F.))

Local lInt 		:=   Len(aArray[n]) >= 15 .And. ValType(aArray[n][15]) == "A" .And. Len(aArray[n][15]) >= 2
Local cIntPv	:= Iif( lInt, aArray[n][15][1], Nil)
Local cIntPub	:= Iif( lInt, aArray[n][15][2], Nil)


If lMatPrima
	cNivEstr := aArray[n][2]
	If Val(cNivEstr) == 1
		Help(" ",1,"C010Nivel")
		RETURN .F.
	EndIf
	If Val(cNivEstr) == 0
		nNivel := Val(aArray[n-1][2])
		If nNivel > 1
			nNivel--
		EndIf
		cNivEstr:=Space(IIF(nNivel+1<=5,nNivel,4))+LTRIM(STR(nNivel+1,2))
	EndIf
	For nX := 1 To Len(aFormulas)
		If AT("#",aFormulas[nX,1]) > 0
			aFormulas[nX,1] := AcertaForm(aFormulas[nX,1],1,n)
		EndIf
		If !Empty(aFormulas[nX,2])
			aFormulas[nX,2] := "#"+StrZero(Val(Substr(aFormulas[nx,2],2,5))+1,5)
		EndIf
	Next nX
	AAdd(aArray,{})
	aArray := AIns(aArray,If(n==1,2,n))
	nMatPrima++
	aArray[n] := {n,cNivEstr,Space(30),Space(15),1,0,0,.T.,"  ",.T.,cTrt,If(substr(cAcesso,39,1)=="S",.T.,.F.),cFixVar}
	For nX := Len(aArray) To 1 Step -1
		If aArray[nX][1] == nX
			Exit
		EndIf
		aArray[nX][1] := nX
	Next nX
	cProd := aArray[n][4]
	nQtd := 1
	If !GetProd(@aArr,lMatPrima,@cProd,@cDescricao,@nQtd,@nValTot,@nPerc,n,nMatPrima,lAutoCalc,aFormulas,.T.)
		For nX := 1 To Len(aFormulas)
			If AT("#",aFormulas[nX,1]) > 0
				aFormulas[nX,1] := AcertaForm(aFormulas[nX,1],-1,n)
			EndIf
			If !Empty(aFormulas[nX,2])
				aFormulas[nX,2] := "#"+StrZero(Val(Substr(aFormulas[nx,2],2,5))-1,5)
			EndIf
		Next nX
		aArray := ADel(aArray,n)
		aArray := ASize(aArray,Len(aArray)-1)
		nMatPrima--
		For nX := Len(aArray) To 1 Step -1
			If aArray[nX][1] == nX
				Exit
			EndIf
			aArray[nX][1] := nX
		Next nX
	Else
		aArray[n][3] := cDescricao
		aArray[n][4] := cProd
		aArray[n][5] := nQtd
		aArray[n][6] := nValTot
		aArray[n][9] := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_TIPO")
	EndIf
	If lAutoCalc
		RecalcTot(nMatPrima)
		CalcForm(aFormulas,nMatPrima)
	EndIf
	Recalculo(nMatPrima,@aArr,@aTot,aFormulas)
	Def(lMatPrima,@oLbx,aArr)
Else
	If n >= nMatPrima .And. n < nMatPrima+nQtdTotais
		If nQtdTotais == 0
			cDescricao := Space(30)
			cFormula   := Space(100)
		Else
			cDescricao := aArray[n][3]
			cFormula   := aTotais[(n-nMatPrima)+1]
		EndIf
		If !GetFormula(@aArr,@cDescricao,@cFormula,@nValTot,n,nMatPrima,,@cIntPv,@cIntPub)
			RETURN .F.
		Else
			For nX := 1 To Len(aFormulas)
				If AT("#",aFormulas[nX,1]) > 0
					aFormulas[nX,1] := AcertaForm(aFormulas[nX,1],1,n)
				EndIf
				If !Empty(aFormulas[nX,2])
					aFormulas[nX,2] := "#"+StrZero(Val(Substr(aFormulas[nx,2],2,5))+1,5)
				EndIf
			Next nX
			AAdd(aTotais," ")
			aTotais := AIns(aTotais,(n-nMatPrima)+1)
			aTotais[(n-nMatPrima)+1] := cFormula
			nQtdTotais++
			AAdd(aArray,{})
			aArray := AIns(aArray,n)
			aArray[n]    := aClone(aArray[n+1])
			aArray[n][3] := cDescricao
			If lInt
				aArray[n][15][1] := cIntPv
				aArray[n][15][2] := cIntPub
			EndIf
			For nX := Len(aArray) To 1 Step -1
				If aArray[nX][1] == nX
					Exit
				EndIf
				aArray[nX][1] := nX
			Next nX
			If lAutoCalc
				RecalcTot(nMatPrima)
				CalcForm(aFormulas,nMatPrima)
			EndIf
			InitArray(lMatPrima,@aArr,aFormulas, nMatPrima)
			Def(lMatPrima,@oTot,aArr)
		EndIf
	ElseIf n > nMatPrima+nQtdTotais .And. n < Len(aArray)
		cDescricao := aArray[n][3]
		cFormula   := aFormulas[n-nMatPrima-nQtdTotais,1]
		cCelPer	  := Substr(aFormulas[n-nMatPrima-nQtdTotais,2],2,5)
		If !GetFormula(@aArr,@cDescricao,@cFormula,@nValTot,n,nMatPrima,@cCelPer,@cIntPv,@cIntPub)
			RETURN .F.
		Else
			For nX := 1 To Len(aFormulas)
				If AT("#",aFormulas[nX,1]) > 0
					aFormulas[nX,1] := AcertaForm(aFormulas[nX,1],1,n)
				EndIf
				If !Empty(aFormulas[nX,2])
					aFormulas[nX,2] := "#"+StrZero(Val(Substr(aFormulas[nx,2],2,5))+1,5)
				EndIf
			Next nX
			ASize(aFormulas,Len(aFormulas)+1)
			AIns(aFormulas,n-nMatPrima-nQtdTotais)
			AFill(aFormulas,{,},n-nMatPrima-nQtdTotais,1)
			aFormulas[n-nMatPrima-nQtdTotais,1] := cFormula
			aFormulas[n-nMatPrima-nQtdTotais,2] := If(Empty(cCelPer), Space(6), "#"+cCelPer)
			nQtdFormula++
			AAdd(aArray,{})
			aArray := AIns(aArray,n)
			aArray[n]    := aClone(aArray[n+1])
			aArray[n][3] := cDescricao
			If lInt
				aArray[n][15][1] := cIntPv
				aArray[n][15][2] := cIntPub
			EndIf
			For nX := Len(aArray) To 1 Step -1
				If aArray[nX][1] == nX
					Exit
				EndIf
				aArray[nX][1] := nX
			Next nX
			If lAutoCalc
				RecalcTot(nMatPrima)
				CalcForm(aFormulas,nMatPrima)
			EndIf
			InitArray(lMatPrima,@aArr,aFormulas, nMatPrima)
			Def(lMatPrima,@oTot,aArr)
		EndIf
	EndIf
EndIf
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Grava 	³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o arquivo .PDV da planilha                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grava(nMatPrima,aFormulas,oDlg2)
LOCAL lRet := .F.,cArq, oDlg
LOCAL cArqUsu
Local nTamCONome := TamSX3("CO_NOME")[1]
Local cArqAnt

If (ExistBlock("MC010NOM"))
	cArqUsu := ExecBlock("MC010NOM",.F.,.F.,cArqMemo)
	If ValType(cArqUsu) == "C"
		cArqMemo := cArqUsu
	EndIf
EndIf

cArqAnt := cArqMemo+Space(nTamCONome-Len(cArqMemo))
Do While .T.
	lConfirma := .F.
	DEFINE MSDIALOG oDlg FROM 15,1 TO 168,302 PIXEL TITLE OemToAnsi(STR0010) 	//"Grava‡„o em Disco"
		@ 7, 7 TO 52, 135 LABEL "" OF oDlg  PIXEL
		@ 28, 25 MSGET cArqAnt Picture "@!" SIZE 82, 10 OF oDlg PIXEL  Valid !" "$(Trim(cArqAnt))
		@ 19, 25 SAY STR0011 SIZE 53, 7 OF oDlg PIXEL	//"&Nome do Arquivo:"
		DEFINE SBUTTON FROM 58, 081  TYPE 1 ENABLE OF oDlg Action(lRet := .T.,oDlg:End())
		DEFINE SBUTTON FROM 58, 108 TYPE 2 ENABLE OF oDlg Action(lRet := .F.,oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTER
	If !lRet
		RETURN NIL
	Else
	cArq := Trim(cArqAnt)+".PDV"
	If File(cArq)
		If MsgYesNo(OemToAnsi(STR0012+Trim(cArqAnt)+STR0013))	//"Entrada : "###", j  existe, Regrava?"
			lConfirma := .T.
			Exit
		EndIf
	EndIf
	lConfirma := .T.
	Exit
	EndIf
EndDo
If lConfirma
	cTitulo:=STR0004+cArqAnt+STR0005+cCusto	//" Planilha "###" - Custo "
	oDlg2:CTITLE(cTitulo)
	MC010Grava(cArq, cArqAnt, nMatPrima, aFormulas)
EndIf
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Custo    ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera o custo da planilha.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Custo(aTot,aProd,nMatPrima,aFormulas,oDlg2)
LOCAL  nQualCust2:=0,nUltNivel,oCusto,nCusto,oDlg
LOCAL aCustos[8],lRet := .F., oBtnA
nCusto		:= nQualCusto
nQualCust2	:= nQualCusto
aCustos := {STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021} //"STANDARD"###"MEDIO"###"MOEDA2"###"MOEDA3"###"MOEDA4"###"MOEDA5"###"ULTPRECO"###"PLANILHA"
DEFINE MSDIALOG oDlg FROM 15,5 TO 222,309 TITLE STR0022 PIXEL	//"Selecione Tipo de Custo"
	@ 11,12 LISTBOX oCusto FIELDS HEADER  ""  SIZE 131, 69 OF oDlg PIXEL;
		  ON CHANGE (nCusto := oCusto:nAt)
	oCusto:SetArray(aCustos)
	oCusto:bLine := { || {aCustos[oCusto:nAT]} }
	DEFINE SBUTTON oBtnA FROM 83, 088 TYPE 1 ENABLE OF oDlg Action (lRet := .T.,oDlg:End())
	DEFINE SBUTTON FROM 83, 115 TYPE 2 ENABLE OF oDlg Action (lRet:= .F.,ODlg:End())
ACTIVATE MSDIALOG oDlg CENTER
If !lRet
	RETURN NIL
EndIf

If nCusto	  == 1
	cCusto := STR0014	//"STANDARD"
ElseIf nCusto == 2
	cCusto := STR0015+" "+MV_MOEDA1	//"MEDIO"
ElseIf nCusto == 3
	cCusto := STR0015+" "+MV_MOEDA2	//"MEDIO"
ElseIf nCusto == 4
	cCusto := STR0015+" "+MV_MOEDA3	//"MEDIO"
ElseIf nCusto == 5
	cCusto := STR0015+" "+MV_MOEDA4	//"MEDIO"
ElseIf nCusto == 6
	cCusto := STR0015+" "+MV_MOEDA5	//"MEDIO"
ElseIf nCusto == 7
	cCusto := STR0020	//"ULTPRECO"
ElseIf nCusto == 8
	cCusto := STR0021	//"PLANILHA"
EndIf
cTitulo := STR0004+cArqMemo+STR0005+cCusto	//" Planilha "###" - Custo "
oDlg2:CTITLE(cTitulo)
If nCusto != nQualCust2 .And. nCusto != nQualCusto
	nQualCusto := nCusto
	nUltNivel := CalcUltNiv()
	CalcTot(nMatPrima,nUltNivel,aFormulas)
	InitArray(.T., @aProd, aFormulas, nMatPrima)
	InitArray(.F., @aTot,  aFormulas, nMatPrima)
EndIf
RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Recalculo³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula toda a planilha inclusive suas formulas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Recalculo(nMatPrima,aArr,aArr1,aFormulas)

RecalcTot(nMatPrima)
CalcForm(aFormulas,nMatPrima)
InitArray(.T., @aArr,  aFormulas, nMatPrima)
InitArray(.F., @aArr1, aFormulas, nMatPrima)
RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Planilha ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Le planilha gravada no disco                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Planilha(oBtnD,oBtnE,oBtnF)
LOCAL aDiretorio,nX,oPlan, oDlg, oBtnA
LOCAL lRet:=.F.
aDiretorio := Directory("*.PDV")
For nX := 1 To Len(aDiretorio)
	aDiretorio[nX] := SubStr(aDiretorio[nX][1],1,AT(".",aDiretorio[nX][1])-1)
	If aDiretorio[nX] == "STANDARD"
		aDiretorio[nX] := Space(14)
	Else
		aDiretorio[nX] := "   "+aDiretorio[nX]+Space(11-Len(aDiretorio[nX]))
	EndIf
Next nX
Asort(aDiretorio)
If Empty(aDiretorio[1])
	aDiretorio[1] := "   STANDARD   "
EndIf
nX :=1
DisBut(oBtnD,oBtnE,oBtnF,.F.)
DEFINE MSDIALOG oDlg FROM 15,6 TO 222,309 TITLE STR0023 PIXEL	//"Selecione Planilha"
	@ 11,12 LISTBOX oPlan FIELDS HEADER  ""  SIZE 131, 69 OF oDlg PIXEL;
		  ON CHANGE (nX := oPlan:nAt) ON DBLCLICK (Eval(oBtnA:bAction))
	oPlan:SetArray(aDiretorio)
	oPlan:bLine := { || {aDiretorio[oPlan:nAT]} }
	DEFINE SBUTTON oBtnA FROM 83, 088 TYPE 1 ENABLE OF oDlg Action(lRet := .T.,oDlg:End())
	DEFINE SBUTTON FROM 83, 115 TYPE 2 ENABLE OF oDlg Action (lRet:= .F.,ODlg:End())
ACTIVATE MSDIALOG oDlg CENTER
cArqMemo := AllTrim(aDiretorio[nX])
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetFormula³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a tela de Get das formulas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetFormula(aArr,cDescricao,cFormula,nValTot,n,nMatPrima,cCelPer,cIntPv,cIntPub)
LOCAL cCel			:= AArray[n,1], oDlg
LOCAL lGetCelPer	:= IIF(cCelPer == NIL,.F.,.T.)
Local lInt			:= !(cIntPv == Nil) .And. !(cIntPub == Nil)
Local aCBoxPv, oBoxPv
Local aCBoxPub, oBoxPub

cCelPer:=IIF(cCelPer == NIL,Space(5),cCelPer)
lRet := .F.

DEFINE MSDIALOG oDlg FROM 54,63 TO 500,400 TITLE cTitulo PIXEL
	@ 003, 07 TO 040, 165 LABEL "" OF oDlg  PIXEL
	@ 041, 07 TO 194, 165 LABEL "" OF oDlg  PIXEL
	@ 014, 16 SAY OemToAnsi(STR0024) SIZE 21, 7 OF oDlg PIXEL	//"C‚lula:"
	@ 023, 16 MSGET cCel SIZE 25, 10 OF oDlg PIXEL WHen .F.
	@ 014, 57 SAY OemToAnsi(STR0025) SIZE 31, 7 OF oDlg PIXEL	//"Descri‡„o:"
	If lInt
		aCBoxPv	:= MATA315Cmb( .T. /*lRetArray*/)
		oBoxPv	:= Nil

      aCBoxPub := {}
      aEval( RetSx3Box( Posicione("SX3", 2, "CO_INTPUB", "X3CBox()" ),,,1), {| x | aAdd(aCBoxPub,x[1]) })
		oBoxPub	:= Nil

		@ 023, 57 MSGET cDescricao SIZE 85, 10 OF oDlg PIXEL  F3 "SCO1"
		@ 050, 16 SAY OemToAnsi(STR0026) SIZE 25, 7 OF oDlg PIXEL	//"F¢rmula:"
		@ 059, 16 MSGET cFormula SIZE 125, 10 OF oDlg PIXEL  VALID !Empty(cFormula) .And. C10VldForm(cFormula,@cIntPv,@cIntPub) F3 "SCO2"
	Else
		@ 023, 57 MSGET cDescricao SIZE 85, 10 OF oDlg PIXEL  F3 "SCO1"
		@ 050, 16 SAY OemToAnsi(STR0026) SIZE 25, 7 OF oDlg PIXEL	//"F¢rmula:"
		@ 059, 16 MSGET cFormula SIZE 125, 10 OF oDlg PIXEL  VALID !Empty(cFormula)
	EndIf
	@ 078, 16 SAY OemToAnsi(STR0027) SIZE 34, 7 OF oDlg PIXEL	//"Valor Total:"
	@ 087, 16 MSGET nValTot SIZE 125, 10 OF oDlg PIXEL When (aArray[n,8] .and. aArray[n,10])
	@ 106, 16 SAY OemToAnsi(STR0028+" ( # )") SIZE 55, 7 OF oDlg PIXEL	//"C‚lula Percentual:"
	@ 115, 16 MSGET cCelPer Picture "99999" SIZE 25, 10 OF oDlg PIXEL When lGetCelPer  Valid Empty(cCelPer) .Or. (Val(cCelPer)>0 .And. Val(cCelPer)<=(Len(aArray)-1))


	If lInt

		@ 136, 16 SAY RetTitle("CO_INTPV") SIZE 70, 7 OF oDlg PIXEL
		@ 145, 16 combobox oBoxPv var cIntPv items aCBoxPv size 70,08 of oDlg pixel

		@ 166, 16 SAY RetTitle("CO_INTPUB") SIZE 70, 7 OF oDlg PIXEL
		@ 175, 16 COMBOBOX oBoxPub VAR cIntPub ITEMS aCBoxPub SIZE 70,08 OF oDlg PIXEL
	EndIf

	DEFINE SBUTTON FROM 210, 096 TYPE 1 ENABLE OF oDlg Action(lRet := .T.,oDlg:End())
	DEFINE SBUTTON FROM 210, 123 TYPE 2 ENABLE OF oDlg Action(lRet := .F.,oDlg:End())
ACTIVATE MSDIALOG oDlg CENTER

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GetProd	³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a tela de Get dos produtos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetProd(aArr,lMatPrima,cProd,cDesc,nQtd,nValTot,nPerc,n,nMatPrima,lAutoCalc,aFormulas,lInclui)
LOCAL lRet:=.F., nQtdOld:=nQtd, oDesc, oQtd, oValTot, oPerc, oDlg

DEFINE MSDIALOG oDlg FROM 21,5 TO 241,402 TITLE STR0029 PIXEL	//"Alterar"
	@ 34,  5 TO 99, 157  LABEL "" OF oDlg  PIXEL
	@  8,  8 SAY OemToAnsi(STR0030) SIZE 21, 7 OF oDlg PIXEL	//"C¢digo:"
	@ 17,  8 MSGET cProd Picture "@!" SIZE 104, 10 OF oDlg PIXEL Valid ExistCpo("SB1",cProd) .and. MostraDesc(@cDesc,oDesc,cProd) .and. IIF(lInclui,CalcTotal(cProd,nQtd,nQtdOld,@nValTot,oValTot,@nPerc,oPerc,lAutoCalc,aFormulas,nMatprima,lInclui,n),.T.) WHEN lInclui F3 "SB1"
	@  8, 114 SAY OemToAnsi(STR0025) SIZE 35, 7 OF oDlg PIXEL	//"Descri‡„o:"
	@ 17, 114 MSGET oDesc Var cDesc SIZE 84, 10 OF oDlg PIXEL WHEN .F.
	@ 41, 10 SAY OemToAnsi(STR0031) SIZE 38, 7 OF oDlg PIXEL	//"Quantidade:"
	@ 51, 10 MSGET oQtd Var nQtd SIZE 67, 10 OF oDlg PIXEL Picture StrTran(aHeader[5,2],"Z","") Valid CalcTotal(cProd,nQtd,@nQtdOld,@nValTot,oValTot,nPerc,oPerc,lAutoCalc,aFormulas,nMatprima,lInclui,n) WHEN  (lMatPrima)
	@ 41, 86 SAY OemToAnsi(STR0032) SIZE 38, 7 OF oDlg PIXEL	//"Valor Total:"
	@ 51, 86 MSGET oValTot Var nValTot SIZE 67, 10 OF oDlg PIXEL Picture StrTran(aHeader[6,2],"Z","") WHEN(lMatPrima .and. aArray[n][8] .And. nQualCusto = 8)
	@ 69, 10 SAY OemToAnsi(STR0033) SIZE 68, 7 OF oDlg PIXEL	//"Participa‡„o (%)"
	@ 79, 10 MSGET oPerc VAR nPerc SIZE 48, 10 OF oDlg PIXEL Picture aHeader[7,2]
	DEFINE SBUTTON FROM 73, 168 TYPE 1 ENABLE OF oDlg Action (lRet := .T.,oDlg:End())
	DEFINE SBUTTON FROM 87, 168 TYPE 2 ENABLE OF oDlg Action (lRet := .F.,oDlg:End())
ACTIVATE MSDIALOG oDlg CENTER
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CalcTot	³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula os totais da planilha.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcTotal(cProd,nQtd,nQtdOld,nValTot,oValTot,nPerc,oPerc,lAutoCalc,aFormulas,nMatprima,lInclui,n)
If lInclui
	aArray[n][3] := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
	aArray[n][4] := cProd
	aArray[n][5] := nQtd
	aArray[n][6] := IIF(nQualCusto = 8,nValTot,QualCusto(cProd))
	aArray[n][9] := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_TIPO")
	If lAutoCalc
		RecalcTot(nMatPrima)
		CalcForm(aFormulas,nMatPrima)
	EndIf
	nQtd	  := aArray[n][5]
	nValTot := aArray[n][6] * nQtd
	nPerc   := aArray[n][7]
	oValTot:Refresh(.F.)
	oPerc:Refresh(.F.)
	oPerc:Disable()
Else
	nQtdOld := IIF(nQtdOld==0,1,nQtdOld)
	nValTot := (nValTot/nQtdOld) * nQtd
	nQtdOld := nQtd
	oPerc:Disable()
EndIf
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Def      ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Redesenha BROWSE com inclusao/exclusao efetuada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Def(lMatPrima,o,aArr)
o:SetArray(aArr)
If lMatPrima
	o:bLine := {|| {aArr[o:nAt,1],aArr[o:nAt,2],aArr[o:nAt,3],aArr[o:nAt,4],aArr[o:nAt,5],aArr[o:nAt,6],aArr[o:nAt,7]} }
Else
	o:bLine := {|| {aArr[o:nAt,1],aArr[o:nAt,2],aArr[o:nAt,4],aArr[o:nAt,5],aArr[o:nAt,3]} }
EndIf
o:nlen:=Len(aArr)
o:Default()
o:nAt := 1
o:Refresh()
o:Display()
SetFocus(o:hWnd)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ InitArray³ Autor ³ Cesar Eduardo Valadao ³ Data ³05/10/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui items no Array                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InitArray(lMatPrima, aArr, aFormulas, nMatPrima)
Local i, nCont
aArr := {}
If lMatPrima
	For i := 1 To nMatPrima-2
	   If aArray[i][12]  // Monta array de acordo com acesso do usuario
		  AAdd(aArr,{Str(aArray[i,1],5),aArray[i,2],aArray[i,3],aArray[i,4],Transform(aArray[i,5],aHeader[5,2]),Transform(aArray[i,6],aHeader[6,2]),Transform(aArray[i,7],aHeader[7,2])})
	   EndIf
	Next
Else
	i := nMatPrima-1
	AAdd(aArr,{Str(aArray[i,1],5),aArray[i,3],aArray[i,4],Transform(aArray[i,6],aHeader[6,2]),Transform(aArray[i,7],aHeader[7,2])})
	nCont := 1
	For i := nMatPrima To nMatPrima+nQtdTotais-1
		AAdd(aArr,{Str(aArray[i,1],5),aArray[i,3],aTotais[nCont],Transform(aArray[i,6],aHeader[6,2]),Transform(aArray[i,7],aHeader[7,2])})
		nCont++
	Next
	AAdd(aArr,{Str(aArray[i,1],5),aArray[i,3],aArray[i,4],Transform(aArray[i,6],aHeader[6,2]),Transform(aArray[i,7],aHeader[7,2])})
	nCont := 1
	For i := nMatPrima+nQtdTotais+1 To nMatPrima+nQtdTotais+nQtdFormula
		AAdd(aArr,{Str(aArray[i,1],5),aArray[i,3],aFormulas[nCont,1],Transform(aArray[i,6],aHeader[6,2]),Transform(aArray[i,7],aHeader[7,2])})
		nCont++
	Next
	AAdd(aArr,{Str(aArray[i,1],5),aArray[i,3],aArray[i,4],Transform(aArray[i,6],aHeader[6,2]),Transform(aArray[i,7],aHeader[7,2])})
EndIf
RETURN(aArr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MostraDesc³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a descricao do produto                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraDesc(cDesc,oDesc,cProd)
LOCAL cAlias,nOldRecno,nOldOrder
cAlias:=Alias()
dbSelectArea("SB1")
nOldOrder:=IndexOrd()
nOldRecno:=Recno()
dbSetOrder(1)
MsSeek(xFilial("SB1")+cProd)
cDesc:=SB1->B1_DESC
oDesc:Refresh(.F.)
dbSetOrder(nOldOrder)
MsGoTo(nOldRecno)
dbSelectArea(cAlias)
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Posicione³ Autor ³ Ary Medeiros          ³ Data ³ 19/08/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para posicionamento e retorno de um campo de 1 arq. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Posicione(Alias,Ordem,Expressao,Campo)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPLAN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Posicione(cAlias,nOrdem,cExpr,cCpo)
LOCAL cSavAlias := Alias(), cRet
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbSeek(cExpr)
cRet := &(cCpo)
dbSelectArea(cSavAlias)
RETURN cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DisBut   ³ Autor ³ Cristiane Maeda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita / Desabilita Botoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ DisBut(ExpO1,ExpO2,Expo3,ExpL1,ExpL2)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Obj ref. ao Botao 'Planilha'                       ³±±
±±³          ³ ExpO2 = Obj ref. ao Botao 'Recalculo'                      ³±±
±±³          ³ ExpO3 = Obj ref. ao Botao 'Custo'                          ³±±
±±³          ³ ExpL1 = Se .T. desabilita os 3 botoes acima;			      ³±±
±±³          ³         Se .F. habilita botoes acima, mas o botao 'Planilha'±±
±±³          ³         so' habilita se 5o.parametro tambem for igual a .F.³±±
±±³          ³ ExpL2 = Somente habilita Botao 'Planilha' se =.F. (default)³±±
±±³          ³         e o 4o.parametro tambem for igual a .F.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DisBut(oBt1,oBt2,oBt3,lDisable,lRetPEButP)
DEFAULT lRetPEButP :=.F. // Habilita botao 'PLANILHA'
If lDisable
	oBt1:Disable()
	oBt2:Disable()
	oBt3:Disable()
	CursorWait()
Else
	If !lRetPEButP
		oBt1:Enable()
	EndIf
	oBt2:Enable()
	oBt3:Enable()
	CursorArrow()
EndIf
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MTC010PERG³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 16/06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pergunte                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTC010PERG()
PERGUNTE("MTC010",.T.)

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³MC0010GRVEX³ Autor ³ Larson Zordan         ³ Data ³ 30/05/01 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³ Chamada do Pto Entrada p/ gravar campos em base de dados    ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³ Uso      ³ SIGAEST                                                     ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MC010GRVEX(lGrava)
If (ExistTemplate("MC010GRV"))
	ExecTemplate("MC010GRV",.F.,.F.,lGrava)
EndIf
If (ExistBlock("MC010GRV"))
	ExecBlock("MC010GRV",.F.,.F.,lGrava)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡„o    ³MC010SETUP ³ Autor ³Marcos V. Ferreira     ³ Data ³10/11/04  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡„o ³Retorna o Tempo de Setup de uma Operacao                     ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³ Uso      ³ SIGAEST                                                     ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MC010SETUP(cProd,nQtdArray,nQtd,nQuantAnt,cOperac)
LOCAL lSeek,nTempSet := (nQtdArray/nQuantAnt)*nQtd,cRoteiro
LOCAL aAreaSG2:=SG2->(GetArea())
LOCAL aAreaSB1:=SB1->(GetArea())
LOCAL aAreaSH1:=SH1->(GetArea())

// Utilizado na funcao A690HoraCt()
PRIVATE cTipoTemp	:=SuperGetMV("MV_TPHR")

DEFAULT cOperac := ""

If mv_par05 == 2  .Or. mv_par05 == 3
   dbSelectArea("SB1")
   dbSetOrder(1)
   If MsSeek(xFilial("SB1")+cProd)
      If !Empty(mv_par06)
          cRoteiro:=mv_par06
      ElseIf !Empty(SB1->B1_OPERPAD)
          cRoteiro:=SB1->B1_OPERPAD
      EndIf
      dbSelectArea("SG2")
      dbSetOrder(1)
      lSeek:=dbSeek(xFilial("SG2")+cProd+If(Empty(cRoteiro),"01",cRoteiro)+If(!Empty(cOperac),cOperac,""))
   Endif
   If lSeek
	// Calcula Tempo de Dura‡„o baseado no Tipo de Operacao
		If SG2->G2_TPOPER $ " 1"
			nTempSet := Round( (nQtd * ( If(mv_par07 == 3,A690HoraCt(SG2->G2_SETUP) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ), 0) + IIf( SG2->G2_TEMPAD == 0, 1,A690HoraCt(SG2->G2_TEMPAD)) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ))+If(mv_par07 == 2, A690HoraCt(SG2->G2_SETUP), 0) ),5)
			If SH1->H1_MAOOBRA # 0
				nTempSet :=Round( nTempSet / SH1->H1_MAOOBRA,5)
			EndIf
		ElseIf SG2->G2_TPOPER == "4"
			nQtdAloc:=nQtd % IIf(SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD)
			nQtdAloc:=Int(nQtd)+If(nQtdAloc>0,IIf(SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD)-nQtdAloc,0)
			nTempSet := Round(nQtdAloc * ( IIf( SG2->G2_TEMPAD == 0, 1,A690HoraCt(SG2->G2_TEMPAD)) / IIf( SG2->G2_LOTEPAD == 0, 1, SG2->G2_LOTEPAD ) ),5)
			If SH1->H1_MAOOBRA # 0
				nTempSet :=Round( nTempSet / SH1->H1_MAOOBRA,5)
			EndIf
		ElseIf SG2->G2_TPOPER == "2" .Or. SG2->G2_TPOPER == "3"
			nTempSet := IIf( SG2->G2_TEMPAD == 0 , 1 ,A690HoraCt(SG2->G2_TEMPAD) )
		EndIf
		nTempSet:=nTempSet*If(Empty(SG2->G2_MAOOBRA),1,SG2->G2_MAOOBRA)
 EndIf
EndIf

RestArea(aAreaSG2)
RestArea(aAreaSB1)
RestArea(aAreaSH1)

Return nTempSet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MC010SX2   ³ Autor ³Marcos V. Ferreira     ³ Data ³10/11/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica no SX2 se existe uma determinada tabela             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MC010SX2(cTabela)
Local lRet := .F.
Local aAreaAnt := GetArea()
Local aAreaSX2 := SX2->(GetArea())

dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cTabela)
	lRet := .T.
EndIf

RestArea(aAreaSX2)
RestArea(aAreaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Pesquisa	³ Autor ³ Marcos V. Ferreira    ³ Data ³26.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa um determinado produto dentro do Browse			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pesquisa(oLbx2,aProduto,oDlgTela)
Local cProd     := Space(TamSX3("B1_COD")[1])
Local lRet      := .F.
Local nPos      := 0
Local nX        := 0
Local oDlg, oBtnP

Do While .T.
	lRet:= .F.
	DEFINE MSDIALOG oDlg FROM 15,1 TO 168,285 PIXEL TITLE OemToAnsi(STR0036) 	//"Pesquisa por Componente"
	@ 07, 07 TO 52, 135 LABEL "" OF oDlg  PIXEL
	@ 19, 10 SAY STR0037 SIZE 70, 7 OF oDlg PIXEL	//"&Codigo do Produto:"
	@ 28, 10 MSGET cProd F3 "SB1" Picture "@!" SIZE 120, 10 OF oDlg PIXEL
	@ 60, 25 BUTTON oBtnP Prompt OemToAnsi(STR0038) SIZE 44, 11 OF oDlg PIXEL Action(lRet:= .T.,oDlg:End())
	@ 60, 75 BUTTON oBtnP Prompt OemToAnsi(STR0039) SIZE 44, 11 OF oDlg PIXEL Action(lRet:= .F.,oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTER
	If !lRet
		Exit
	Else
	    nPos := 0
	    For nX := 1 to Len(aProduto)
	    	If aProduto[nX,4] == cProd
	    		nPos := nX
	    		nx := Len(aProduto)
	    	EndIf
		Next nX
		If nPos > 0
			oLbx:nAt:=nPos
			oLbx:Refresh()
		Else
			Aviso("MATC010",STR0040,{"Ok"})
		EndIf
	EndIf
EndDo
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³05/10/2006³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados     	  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina	:= {}

AADD (aRotina, {STR0001,"AxPesqui"  	, 0 , 1,0 ,.F.})	//"Pesquisar"
If SuperGetMV("MV_REVPLAN",.F.,.F.)
	AADD (aRotina, 	{STR0002,"MC010Form2", 0 , 2, 0,nil})	//"Revisao Planilhas"
Else
	AADD (aRotina, 	{STR0002,"MC010Forma", 0 , 2, 0,nil})	//"Forma Pre‡os"
EndIf

If ExistBlock ("MTC010MNU")
	ExecBlock ("MTC010MNU",.F.,.F.)
EndIf

Return (aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GeraRev 	³ Autor ³ Turibio Miranda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Revisao da planilha de formacao de precos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraRev(nMatPrima,aFormulas,oDlg2)
LOCAL aArea	  := GetArea()
LOCAL aAreaSB1:= SB1->(GetArea())
LOCAL lRet 	  := .F.,cArq, oDlg
LOCAL cArqUsu
LOCAL cQuery:= cAliasTRB:= ""
Local nTamCONome := TamSX3("CO_NOME")[1]

cAliasTRB := "SCO"

	cAliasTRB := GetNextAlias()
	cQuery:="SELECT CO_CODIGO, CO_REVISAO, CO_NOME FROM "+RetSqlName("SCO")+" "+(cAliasTRB)+" "
	cQuery+="WHERE CO_FILIAL='"+xFilial("SCO")+"'  AND D_E_L_E_T_=' '"
	If cProg == "A318"
		cQuery+= " AND CO_CODIGO ='"+cCodPlan+"'"
	Else
		cQuery+= " AND CO_NOME ='"+cArqMemo+"'"
	EndIf
	cQuery+= "Order By CO_CODIGO Desc, CO_REVISAO Desc "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasTRB),.F.,.T.)

If (cAliasTRB)->(!Eof())
	cCodPlan:= (cAliasTRB)->CO_CODIGO
	cCodRev := Soma1((cAliasTRB)->CO_REVISAO)
	cArqMemo:= (cAliasTRB)->CO_NOME
Else
	cCodPlan:= StrZero(1,TamSx3("CO_CODIGO")[1])
	cCodRev := StrZero(1,TamSx3("CO_REVISAO")[1])
EndIf
(cAliasTRB)->(DbCloseArea())
RestArea(aAreaSB1)

If (ExistBlock("MC010NOM"))
	cArqUsu := ExecBlock("MC010NOM",.F.,.F.,cArqMemo)
	If ValType(cArqUsu) == "C"
		cArqMemo := cArqUsu
	EndIf
EndIf

cArqAnt := cArqMemo+Space(nTamCONome-Len(cArqMemo))
Do While .T.
	lConfirma := .F.
	DEFINE MSDIALOG oDlg FROM 15,1 TO 168,302 PIXEL TITLE OemToAnsi(STR0042) 	//"Gerar Revisão de Planilha"
		@ 7, 7 TO 52, 135 LABEL "" OF oDlg  PIXEL
		@ 16, 15 MSGET cCodPlan Picture "@!" SIZE 30, 10 OF oDlg PIXEL  WHEN VisualSX3('CO_CODIGO') VALID NumRev(cArqAnt,"R") .And. CheckSX3('CO_CODIGO',cCodPlan)
		@ 16, 75 MSGET cCodRev Picture "@!" SIZE 30, 10 OF oDlg PIXEL  WHEN VisualSX3('CO_REVISAO')	 VALID NumRev(cArqAnt,"C") .And. CheckSX3('CO_REVISAO',cCodRev)
		@ 8, 15 SAY STR0043 SIZE 30, 7 OF oDlg PIXEL	//"Cód.Plan:"
		@ 8, 75 SAY STR0044 SIZE 30, 7 OF oDlg PIXEL	//"Revisão:"
		@ 38, 15 MSGET cArqAnt Picture "@!" SIZE 82, 10 OF oDlg PIXEL  WHEN VisualSX3('CO_NOME')
		@ 30, 15 SAY STR0045 SIZE 53, 7 OF oDlg PIXEL	//"Nome da Planilha:"
		DEFINE SBUTTON FROM 58, 054 TYPE 4  ENABLE OF oDlg Action (NumRev(cArqAnt,"S"))
		DEFINE SBUTTON FROM 58, 081  TYPE 1 ENABLE OF oDlg Action(lRet := .T.,oDlg:End())
		DEFINE SBUTTON FROM 58, 108 TYPE 2 ENABLE OF oDlg Action(lRet := .F.,oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTER
	If !lRet
		RETURN NIL
	Else
		lConfirma:= .T.
		Exit
	EndIf
EndDo
If lConfirma
	cTitulo:=STR0004+Alltrim(cArqAnt)+STR0005+cCusto	//" Planilha "###" - Custo "
	oDlg2:CTITLE(cTitulo)
	MC010Rev(cArq, cArqAnt, nMatPrima, aFormulas, cCodPlan)
	cArqMemo:= cArqAnt
EndIf
RestArea(aArea)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PlanRev  ³ Autor ³ Turibio Miranda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Le planilhas e revisoes gravadas na tabela                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlanRev(oBtnD,oBtnE,oBtnF)
LOCAL aPlanilhas,nX,oPlan, oDlg, oBtnA
LOCAL aArea:= GetArea()
LOCAL cQuery:=cAliasTRB:=""
LOCAL lRet:=.F.
Local lTop:=.F.

	cAliasTRB := GetNextAlias()
	cQuery:="SELECT Distinct CO_CODIGO, CO_REVISAO, CO_NOME, CO_DATA FROM "+RetSqlName("SCO")+" "+(cAliasTRB)+" "
	cQuery+="WHERE CO_FILIAL='"+xFilial("SCO")+"'  AND D_E_L_E_T_=' ' "
	cQuery+= "ORDER BY CO_CODIGO DESC, CO_REVISAO DESC, CO_DATA DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasTRB),.F.,.T.)
	ltop:=.T.


If (cAliasTRB)->(!Eof())
	aPlanilhas := {}
	While (cAliasTRB)->(!Eof())
		AADD(aPlanilhas,{(cAliasTRB)->CO_CODIGO,(cAliasTRB)->CO_REVISAO,(cAliasTRB)->CO_NOME,iif(lTop,(cAliasTRB)->CO_DATA ,DTOC((cAliasTRB)->CO_DATA)),})
		(cAliasTRB)->(DbSkip())
	EndDo
	DisBut(oBtnD,oBtnE,oBtnF,.F.)
	DEFINE MSDIALOG oDlg FROM 15,6 TO 240,500 TITLE STR0023 PIXEL	//"Selecione Planilha"
		@ 11,12 LISTBOX oPlan FIELDS HEADER  STR0046,STR0047,STR0048,STR0049  SIZE 231, 75 OF oDlg PIXEL; // Código/ Revisão / Nome , Data
			  ON CHANGE (nX := oPlan:nAt) ON DBLCLICK (Eval(oBtnA:bAction))
		oPlan:SetArray(aPlanilhas)
		oPlan:bLine := { || {aPlanilhas[oPlan:nAT,1],;
							  aPlanilhas[oPlan:nAT,2],;
  							  aPlanilhas[oPlan:nAT,3],;
							  aPlanilhas[oPlan:nAT,4]} }
		DEFINE SBUTTON oBtnA FROM 93, 188 TYPE 1 ENABLE OF oDlg Action(lRet := .T.,oDlg:End())
		DEFINE SBUTTON FROM 93, 215 TYPE 2 ENABLE OF oDlg Action (lRet:= .F.,ODlg:End())
	ACTIVATE MSDIALOG oDlg CENTER
	cCodPlan := AllTrim(aPlanilhas[nX,1])
	cCodRev  := AllTrim(aPlanilhas[nX,2])
	cArqMemo := AllTrim(aPlanilhas[nX,3])
	lPesqRev:= .T.
Else
	Planilha(oBtnD,oBtnE,oBtnF)
	lRet:= .T.
EndIf

(cAliasTRB)->(DbCloseArea())
RestArea(aArea)

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ NumRev   ³ Autor ³ Turibio Miranda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica numeracao Codigo Planilha e Revisao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NumRev(cArqAnt,cTipo)
LOCAL lRet		:=.T.
LOCAL lCalcula	:=.T. //Tratamento para futura customizacao - PE
aArea:= GetArea()

DEFAULT cArqAnt := "STANDARD"
DEFAULT cTipo   := "C"

If cTipo == "S"
	cCodPlan:= Soma1(cCodPlan)
	cTipo:= "R"
EndIf
cAliasTRB := "SCO"
If lCalcula
	If cTipo == "C"
		cAliasTRB := GetNextAlias()
		cQuery:="SELECT Distinct CO_CODIGO, CO_REVISAO, CO_NOME FROM "+RetSqlName("SCO")+" "+(cAliasTRB)+" "
		cQuery+="WHERE CO_FILIAL='"+xFilial("SCO")+"'  AND D_E_L_E_T_=' ' "
		cQuery+= "AND CO_CODIGO='"+cCodPlan+"'"
		cQuery+= "AND CO_CODIGO='"+cCodRev+"'"
		cQuery+= "ORDER BY CO_CODIGO DESC, CO_REVISAO DESC"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasTRB),.F.,.T.)
		If (cAliasTRB)->(!Eof())
			cCodPlan:= Soma1((cAliasTRB)->CO_CODIGO)
		EndIf
		(cAliasTRB)->(DbCloseArea())
	EndIf

	If cTipo == "R"
		cAliasTRB := GetNextAlias()
		cQuery:="SELECT Distinct CO_CODIGO, CO_REVISAO, CO_NOME FROM "+RetSqlName("SCO")+" "+(cAliasTRB)+" "
		cQuery+="WHERE CO_FILIAL='"+xFilial("SCO")+"'  AND D_E_L_E_T_=' ' "
		cQuery+= "AND CO_CODIGO='"+cCodPlan+"'"
		cQuery+= "ORDER BY CO_CODIGO DESC, CO_REVISAO DESC"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasTRB),.F.,.T.)
		If (cAliasTRB)->(!Eof())
			cCodRev:= Soma1((cAliasTRB)->CO_REVISAO)
		Else
			cCodRev:= StrZero(1,TamSx3("CO_REVISAO")[1])
		EndIf
		(cAliasTRB)->(DbCloseArea())
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C010F3Def ³ Autor ³ Daniel Leme           ³ Data ³24.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3 na edição da Descrição de Fórmulas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C010F3Def()                SXB( SCO1 )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function C010F3Def()
Local lRet		:= .F.
Local nTmsItem := 0
Local cTitulo 	:= STR0050 // "Constantes da Planilha de Formação de Preços"
Local aLenCol	:= {30,50}
Local aRet		:= {	{PadR("#PRECO DE VENDA SUGERIDO......",aLenCol[1]), PadR(STR0051,aLenCol[2])},; // "Utilizado como Preço Sugerido no Pedido de Venda"
							{PadR("#PUBLICACAO                   ",aLenCol[1]), PadR(STR0052,aLenCol[2])}}  // "Utilizado como Preço Sugerido na Publicação de Preços"

nTmsItem := TmsF3Array( {STR0046,STR0053}, aRet, cTitulo ) // "Código" ## "Descrição"
If	nTmsItem > 0
	//-- VAR_IXB eh utilizada como retorno da consulta F3
	VAR_IXB	:= aRet[ nTmsItem ][1]
	lRet		:= .T.
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C010F3Form³ Autor ³ Daniel Leme           ³ Data ³24.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3 na edição de Formulas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C010F3Form()               SXB( SCO2 )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function C010F3Form()
Local aArea		:= GetArea()
Local aAreaSXB	:= SXB->(GetArea())
Local cArqF3	:= ''
Local lRet		:= .F.
Local nOpc		:= 1
Local oDlgEsp

DEFINE MSDIALOG oDlgEsp TITLE '' FROM 10,12 to 21,45
	@ 05, 005 TO 65, 130 LABEL '' OF oDlgEsp PIXEL
	@ 10, 030 RADIO nOpc ITEMS STR0054, STR0055 3D SIZE 75, 015 OF oDlgEsp PIXEL // "&Itens de Precificação" ## "&Fórmulas"
	DEFINE SBUTTON FROM 68, 030 TYPE 1 ACTION (lRet:= .T., oDlgEsp:End(), cArqF3:={'SAV2', 'SM4'}[nOpc]) ENABLE OF oDlgEsp
	DEFINE SBUTTON FROM 68, 070 TYPE 2 ACTION (oDlgEsp:End()) ENABLE OF oDlgEsp
ACTIVATE MSDIALOG oDlgEsp CENTERED

If lRet
	VAR_IXB := {}
	If (lRet := ConPad1(,,, cArqF3,"VAR_IXB",, .F.)  )
		If nOpc == 1
			VAR_IXB := "ITPRC('"  +SAV->AV_CODPRC+"')"
		ElseIf nOpc == 2
			VAR_IXB := "FORMULA('"+SM4->M4_CODIGO+"')"
		EndIf
	EndIf
EndIf
RestArea(aAreaSXB)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C10VldForm³ Autor ³ Daniel Leme           ³ Data ³24.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Item de Precificação na Formula                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C10VldForm(cFormula,cIntPv,cIntPub)
Local aArea		:= GetArea()
Local aAreaSAV	:= SAV->(GetArea())
Local lRet 		:= .T.

If "ITPRC" $ cFormula
	If AllTrim(StrTran(cFormula,'"',"'")) == "ITPRC('" + Substr(AllTrim(cFormula),8,Len(SAV->AV_CODPRC)) + "')"

		SAV->(DbSetOrder(1))
		If !SAV->(MsSeek( xFilial("SAV") + Substr(AllTrim(cFormula),8,Len(SAV->AV_CODPRC)) ))
			Help(" ",1,"REGNOIS")
			lRet := .F.
		Else
			cIntPv	:= SAV->AV_INTPV
			cIntPub	:= SAV->AV_PUBLIC
		EndIf

	Else

		Help(" ",1,"ERR_FORM")
		lRet := .F.

	EndIf
EndIf

RestArea( aAreaSAV )
RestArea( aArea )

Return lRet
