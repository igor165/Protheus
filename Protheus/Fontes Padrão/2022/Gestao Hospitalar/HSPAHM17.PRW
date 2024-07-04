#INCLUDE "HSPAHM17.CH" 
#INCLUDE "Protheus.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "MSMGADD.CH"
#INCLUDE "TopConn.ch

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM17  º Autor ³ José Orfeu         º Data ³  20/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Solicitacao de Exames                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM17
Local aCposGBY	:= {}
Local bKeyF12	:=	SetKey(VK_F12, {|| HS_M17F12()})
Local aCores	:= {	{ "GBY->GBY_STATUS == '0'",	"BR_VERDE" 		},;
						{ "GBY->GBY_STATUS == '1'",	"BR_AMARELO" 	},;
						{ "GBY->GBY_STATUS == '2'",	"BR_AZUL" 		},;
						{ "GBY->GBY_STATUS == '3'",	"BR_VERMELHO"	},;
						{ "GBY->GBY_STATUS == '4'", "BR_CINZA"		}}

Private aRotina, cCadastro
Private cTitulo
Private	lMark			:= .F.
Private cMark			:= GetMark()
Private cFiltro	:= ""
Private cPerg 		:= "HSPM17"
Private lFilGm1 := .T.
Private cGcsTipLoc := "9"
Private cGBYCodLoc := ""

Private __aMarkBrw  := {}

Private cGBJTipPro := "3"
 Private oMB
aRotina := MenuDef()


cCadastro := STR0008 //"Solicitacao de Exames"

aAdd(aCposGBY, { "GBY_IDMARC",, "", "" })

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GBY")
Do While !Eof() .and. SX3->X3_ARQUIVO == "GBY"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. SX3->X3_BROWSE == "S" ;
		.and. SX3->X3_CONTEXT <> "V" .and. !SX3->X3_CAMPO$"GBY_IDMARC/GBY_STATUS"
		aAdd(aCposGBY, {SX3->X3_CAMPO,, SX3->X3_TITULO, SX3->X3_PICTURE })
	Endif
	
	DbSkip()
Enddo

If !Pergunte(cPerg, .T.)
	Return Nil
Endif

FS_M17FILT()

DbSelectArea("GBY")
DbSetOrder(1)

MarkBrowse("GBY", "GBY_IDMARC",, aCposGBY, .F., cMark, "HS_M17MALL(@__aMarkBrw, cFiltro)",,,,,{|| oMB := GetMarkBrow(), oMB:bMark := {|| HS_M17MARK(@__aMarkBrw) }}, cFiltro, .T., aCores)

SetKey(VK_F12, {|| Nil })

Return Nil

Function HS_M17Visu(cAlias, nReg, nOpc )

 HS_M17Roti(cAlias, nReg, nOpc,,, GBY->GBY_CODLAU)
 
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_M17Roti³ Autor ³ Robson Ramiro Oliveira³ Data ³ 18.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_M17Roti      					                              					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_M17Roti(cAlias, nReg, nOpc, cCodQues, lReadOnly, cCodLau, lLiberacao)
 Local aSvKeys		:= GetKeys() 
 Local oDlg 		  := Nil
 Local aCpoAlt  := Nil
 Local nPosNao	:= 0
 Local aCpoNao  :=  {"GBY_NUMAMO","GBY_VOLCOL","GBY_CFGMMM","GBY_DESMAT","GBY_QUESTE","GBY_MTVCAN","GBY_DESMTV",; // Cpos Processo Laboratorial
 					"GBY_CPLCAN","GBY_DATCOL","GBY_HORCOL","GBY_STALAB","GBY_USRCOL","GBY_DATMAP","GBY_HORMAP",;
 					"GBY_USRMAP","GBY_CDQMAP","GBY_NUMMAP","GBY_DTRMAP","GBY_HRRMAP","GBY_USRRMA","GBY_DATRES",;
 					"GBY_HORRES","GBY_USRRES","GBY_LDOGEN","GBY_OBSRES","GBY_DATLIB","GBY_HORLIB","GBY_USRLIB"} 
 Local nOpcA    := 0
 Local aMntperg := {}
 Local aCpoGBY  := {}
 Local aVldCpos := {"GBY_SOLICI","GBY_DATSOL","GBY_REGATE","GBY_PROSOL","GBY_CODCRM","GBY_CRMLAU", ;
                    "GBY_CODLOC","GBY_LOCSOL","GBY_PROLAU","GBY_PROLAU","GBY_STATUS","GBY_RECLAU"}
 
 Private aTela	:= {}
 Private aGets	:= {}
 
 Default cCodQues := GBY->GBY_CDQUES
 Default lLiberacao := .F.
 
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GBY")
While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "GBY")
	If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. ( (nOpc # 3) .Or. (nOpc == 3 .And. SX3->X3_CAMPO # "GBY_CODLAU") )
		If ASCAN(aCpoNao,{|aVet| aVet == SX3->X3_CAMPO}) == 0
			Aadd(aCpoGBY, SX3->X3_CAMPO)
		EndIf
	EndIf
	DbSkip()
EndDo

 
 cGBJTipPro := "0/1/2" 
 
 aSize 			:= MsAdvSize(.T.)
 aObjects := {}
 
 If aRotina[nOpc, 4] == 4
 
  aObjects := {}	
  AAdd( aObjects, { 100, 040, .T., .T. } )
  AAdd( aObjects, { 100, 060, .T., .T., .T. } )
 
  aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPObjs := MsObjSize( aInfo, aObjects, .T. )
  
  aObjects := {}	
  aAdd( aObjects, { 100, 100, .T., .T.} )	
 
  aInfo  := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 	aPGets := MsObjSize( aInfo, aObjects, .T., .T.)
  
  aCpoAlt := {"GBY_CODCRM", "GBY_CRMLAU", IIF(nOpc == 3, "GBY_TECNIC", Nil)}
 Else
 
  AAdd( aObjects, { 100, 100, .T., .T.} )
  
  aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 EndIf

 DbSelectArea("GBY")
 RegToMemory("GBY", .F.)

 cTitulo := OemToAnsi(STR0008) // //"Solicitacao de Exames"

 DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 TO aSize[6], aSize[5] PIXEL of oMainWnd

 oEnc := MsMGet():New(cAlias, nReg, Iif(!lReadOnly,nOpc,2),,,, aCpoGBY, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},aCpoAlt, 3,,,,,, .F.)
 oEnc:oBox:Align := CONTROL_ALIGN_TOP
 
 oEnc:AENTRYCTRLS[aScan(oEnc:aGets, {| aVet | "GBY_CODCRM" $ aVet})]:BGOTFOCUS := {||  cGBJTipPro := "0/1/2" }  

 oEnc:AENTRYCTRLS[aScan(oEnc:aGets, {| aVet | "GBY_CRMLAU" $ aVet})]:BGOTFOCUS := {||  cGBJTipPro := "0/1/2" }  

 oEnc:AENTRYCTRLS[aScan(oEnc:aGets, {| aVet | "GBY_TECNIC" $ aVet})]:BGOTFOCUS := {||  cGBJTipPro := "3" }   

 
 If GBY->GBY_STATUS $ "1#2#3"
  HS_BusResp("GCP", {{"GCP->GCP_SOLICI", cCodLau}}, "GCP")
 EndIf
                                             
 If aRotina[nOpc, 4] == 4        
  aMntperg := HS_MntPerg(cCodQues, oDlg,, aPGets[1], lReadOnly, "GCP" , "oEncQues",, "aTelaQues", CONTROL_ALIGN_BOTTOM,, Iif(lLiberacao,"C","E"), .T.)
 EndIf
 
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| Fs_CpoObr(aVldCpos) .And. IIf(aRotina[nOpc, 4] == 4, IIF(Obrigatorio(aGets,aTela) .And. HS_ObrgPer(aMntPerg[3], aMntPerg[2]), {nOpcA := 1, oDlg:End()},.F.), {nOpcA := 1, oDlg:End()}) }, ;
                                                           {|| nOpcA := 0, oDlg:End()})

 
 If nOpcA == 1 .And. aRotina[nOpc, 4] == 4
 
  HS_GrvResp("GCP", {{"GCP->GCP_SOLICI", cCodLau}, {"GCP->GCP_CDQUES", cCodQues}} , aMntperg[2])
 
  Begin Transaction
   RecLock("GBY", .F.)
    HS_GrvCpo("GBY")   
   MsUnlock()
  End Transaction
  
  //Return(aMntperg[1] == 1)
 EndIf
 RestKeys( aSvKeys , .T. )
Return(nOpcA == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_M17Leg ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 18.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_M17Leg       					                              					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_M17Leg()
 BrwLegenda(cCadastro,STR0007, {	{"BR_VERDE"   ,	STR0009},;	 //"Legenda"###"Nao Gerados"
 																																{"BR_AMARELO" ,	STR0010},;	 //"Gerados"
 																																{"BR_AZUL"    ,	STR0046},;	 //"Liberados"
 																																{"BR_VERMELHO",	STR0011},; //"Entregue"
 																																{"BR_CINZA"   ,"Cancelado"}}) 
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_PRECAU ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 23.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Precaucoes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_PRECAU        					                              					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero da Solicitacao       						                 ³±±
±±³          ³ ExpC2 = Codigo do Procedimento      						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_PRECAU(aDados)

 Local aArea 		:= GetArea()
 Local cCodTmp := ""
 Local x, nI

 Private aHeader2	:= {}
 Private aCols2			:= {}
 Private nUsado			:=	0
 Private oGet					:= NIL

 cCodTmp := aDados[1]

 FS_M17aHead("GCK")

 For x := 1 To Len(aDados)
	
 	cCodPro := aDados[x]
	
 	DbSelectArea("GA7")
 	DbSetOrder(1)
 	DbSeek(xFilial("GA7") + cCodPro)
 	
 	DbSelectArea("GCJ")
 	DbSetOrder(1)
 	DbSeek(xFilial("GCJ") + GA7->GA7_GRPPRE)
 	If GCJ->GCJ_STATUS <> "1"
 		cCodTmp := cCodPro
 		Loop
 	Endif
 	
 	DbSelectArea("GCI")
 	DbSetOrder(1)
 	DbSeek(xFilial("GCI") + GA7->GA7_GRPPRE)
 	
 	If cCodPro <> cCodTMP .and. Len(aCols2) > 1
 		aAdd(aCols2, Array(nUsado+1))
 		aCols2[Len(aCols2),nUsado+1] := .T.
 	Endif
	 
	 Do While !Eof() .and. xFilial("GCI") == GCI->GCI_FILIAL .and. GCI->GCI_GRPPRE == GA7->GA7_GRPPRE
		
		 If GCI->GCI_STATUS <> "1"
		 	DbSkip()
		 Endif
		
	 	DbSelectArea("GCK")
	 	DbSetOrder(1)
 		DbSeek(xFilial("GCK") + GCI->GCI_CODPRE)
		
	 	aAdd(aCols2, Array(nUsado+1))
		
	 	aCols2[Len(aCols2),1]	 := cCodPro
		
	 	For nI := 2 to nUsado
			
		 	If Upper(AllTrim(aHeader2[nI,10])) != "V" 	// Campo Real
		 		aCols2[Len(aCols2),nI] := FieldGet(FieldPos(aHeader2[nI,2]))
 			Else										// Campo Virtual
 				cCpo := AllTrim(Upper(aHeader2[nI,2]))
 				aCols2[Len(aCols2),nI] := CriaVar(aHeader2[nI,2])
 			Endif
			
	 		aCols2[Len(aCols2),nUsado+1] := .F.
 			
	 	Next nI
		
 		DbSelectArea("GCI")
 		DbSkip()
		
 	Enddo
	
 	cCodTmp := cCodPro
	
 Next x

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0005) FROM 120,000 TO 450,780 OF oMainWnd PIXEL // //"Precaucoes"

  oGet := MsNewGetDados():New(02,02,140,390,0,"AllWaysTrue","AllWaysTrue",,,1,999,,,,oDlg,aHeader2,aCols2)

  oGet:bDelOk := {|| oGet:Refresh(), .F.} // block que impede a delecao

  DEFINE SBUTTON FROM 150,350 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg

 ACTIVATE MSDIALOG oDlg CENTERED

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_M17Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 23.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_A91Ahead()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_M17Ahead(cAlias)

 Local aArea  := GetArea()

 aHeader2 := {}
 nUsado 	:= 0
 
 DbSelectArea("SX3")
 DbSetOrder(2)
 DbSeek("GBY_PROSOL")

 nUsado++

 Aadd(aHeader2,{ AllTrim(X3Titulo()),;
 SX3->X3_CAMPO	,;
 SX3->X3_PICTURE,;
 SX3->X3_TAMANHO,;
 SX3->X3_DECIMAL,;
 SX3->X3_VALID	,;
 SX3->X3_USADO	,;
 SX3->X3_TIPO	,;
 SX3->X3_F3	,;
 SX3->X3_CONTEXT } )

 DbSetOrder(1)
 DbSeek(cAlias)

 Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³Ignora campos que nao devem aparecer na getdados³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
 	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
		
		 If X3_CAMPO$"GCK_TIPPRE/GCK_STATUS"
		 	DbSkip()
		 	Loop
		 Endif
		
		 nUsado++
		
 		aAdd(aHeader2,{ AllTrim(X3Titulo()),;
 		SX3->X3_CAMPO	,;
 		SX3->X3_PICTURE,;
 		SX3->X3_TAMANHO,;
 		SX3->X3_DECIMAL,;
 		SX3->X3_VALID	,;
 		SX3->X3_USADO	,;
 		SX3->X3_TIPO	,;
 		SX3->X3_F3	,;
 		SX3->X3_CONTEXT } )
		
 	Endif
	
 	DbSkip()
	
 Enddo

 RestArea(aArea)

Return()


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M17MALL ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 18.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca todos                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M17MALL                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_M17MALL(aMBrow, cCondSql, lDesmarca)
 Local cSql  := ""
 Local aArea := GetArea()

 Default cCondSql := PrefixoCpo("GBY") + "_FILIAL = '" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*'"
 Default lDesmarca := ThisInv()

 CursorWait()

 NewMark()
 
 SetInvert(!lDesmarca)
        
 If !lDesmarca
  aMBrow := {}
  cSql := "SELECT GBY_SOLICI, GBY_CODLAU, GBY_STATUS FROM " + RetSqlName("GBY") + " WHERE " + cCondSql
  cSql += " ORDER BY "+SqlOrder(GBY->(IndexKey()))
  
  TCQUERY cSql NEW ALIAS "QRYMRK"
  
  While !Eof()                                        
   aAdd(aMBrow, {QRYMRK->GBY_SOLICI, QRYMRK->GBY_CODLAU, QRYMRK->GBY_STATUS == "0"})     
   DBSkip()
  End
  
  DbCloseArea()
 Else
  aMBrow := {}
 EndIf 
  
 CursorArrow()        
 
 RestArea(aArea) 

Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M17MARK ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 18.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca 1                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M17MARK                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_M17MARK(aMBrow)

 Local nPSolici := 0
 
 IF IsMark("GBY_IDMARC", ThisMark(), ThisInv())
  aAdd(aMBrow, {GBY->GBY_SOLICI, GBY->GBY_CODLAU, GBY->GBY_STATUS == "0"})
 ElseIf (nPSolici := aScan(aMBrow, {| aVet | aVet[1] == GBY->GBY_SOLICI})) > 0
  aDel(aMBrow, nPSolici)
  aSize(aMBrow, Len(aMBrow) - 1)
 EndIf
	
Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M17RESU ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 19.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Digitacao dos resultados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M17RESU                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_M17RESU(cAlias, nReg, nOpc)
Local lTPLAUDO
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaGBY	:= {}
Local cCodLau	:= "", cCodPro := ""
Local cTmpCod	:= GBY->GBY_CODLAU
Local cTmpPac   := GBY->GBY_REGGER
Local lOk		:= .F.
Local lReadOnly	:= .F.
Local oDlgGGR, oGDGGR
Local aHGGR := {}, aCGGR := {}, nUGGR :=0, nOpcA := 0
Local nGGRCDQUES := 0, cCodQues := GBY->GBY_CDQUES
Local nRecGBY := nReg, nFor := 0, cInSql := ""

Local lLiberacao := IIf(nOpc == 4, .T., .F.)

Private aVetVar := {}

If ExistBlock("HSM17RES")
	If ExecBlock("HSM17RES",.F.,.F.,{cAlias, nReg, nOpc,lLiberacao}) == .F.
		Return (Nil)
	Endif
Endif
If GBY->GBY_IDMARC <> cMark
	HS_MsgInf(STR0012, STR0028, STR0003) //"Marque e posicione o laudo principal !"###"Atenção" ###"Resultados"
	Return(.F.)
EndIf

For nFor := 1 To Len(__aMarkBrw)
	If Len(__aMarkBrw) == 1
		cInSql += "'" + __aMarkBrw[nFor][1] + "'"
	Else
		cInSql += "'" + __aMarkBrw[nFor][1] + "'" + IIf(nFor < Len(__aMarkBrw), ",","")
	EndIf
Next nFor

cSql := "SELECT * FROM " + RetSqlName("GBY") + " "
cSql += "WHERE GBY_FILIAL ='" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*' AND "
cSql +=       "GBY_SOLICI IN (" + cInSql + ")"

cSql := ChangeQuery(cSql)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "TMPGBY", .F., .F.)
DbSelectArea("TMPGBY")
DbGotop()

While !(TMPGBY->(Eof()))
	If cTmpPac <> HS_IniPadr("GCY", 1, TMPGBY->GBY_REGATE, "GCY_REGGER" )
		HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + STR0014, STR0028, STR0003) //"A Solicitacao "###" nao pode ser laudada em conjunto!"###"Solicitacao de Exames" ##"Resultados"
		DbSelectArea("TMPGBY")
		DbCloseArea()
		Return(.F.)
	Elseif TMPGBY->GBY_STATUS == "2"
		HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + STR0029, STR0028, STR0003) //"A Solicitacao "###" já está liberada e não pode ser modificada"###"Solicitacao de Exames" ##"Resultados"
		lReadOnly := .T.
	Elseif TMPGBY->GBY_STATUS == "3"
		HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + STR0015, STR0028, STR0003) //"A Solicitacao "###" ja teve o laudo entregue e sera aberta como somente leitura!""###"Solicitacao de Exames" ##"Resultados"
		lReadOnly := .T.
	ElseIf TMPGBY->GBY_STATUS == '4'
		HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + " está cancelada.", STR0028, STR0003) //"A Solicitacao "###" está cancelada."###"Solicitacao de Exames" ##"Resultados"
		DbSelectArea("TMPGBY")
		DbCloseArea()
		Return(.F.)
	EndIf
	TMPGBY->(DbSkip())
Enddo

DbSelectArea("TMPGBY")
DbCloseArea()

DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY") + GBY->GBY_REGATE)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1") + GCY->GCY_REGGER)

DbSelectArea("GBH")
DbSetOrder(1)
DbSeek(xFilial("GBH") + GCY->GCY_REGGER)

DbSelectArea("GD4")
DbSetOrder(2)
DbSeek(xFilial("GD4") + GCY->GCY_REGGER)

DbSelectArea("GCM")
DbSetOrder(2)
DbSeek(xFilial("GCM") + GD4->GD4_CODPLA)

DbSelectArea("GA9")
DbSetOrder(1)
DbSeek(xFilial("GA9") + GCM->GCM_CODCON)

DbSelectArea("GCS")
DbSetOrder(1)
DbSeek(xFilial("GCS") + GCY->GCY_CODLOC)

aAreaGBY := GBY->(GetArea()) //Salvo o registro que esta posicionado neste momento

Fs_IniVar() //Inicializa Variáveis para word

RestArea(aAreaGBY) //Posiciono novamente no registro que estava antes de entrar na funcao Fs_IniVar

lTPLAUDO := (GetMV("MV_TPLAUDO") == "1")

If Empty(GBY->GBY_CODLAU)
	M->GBX_CODLAU	:= GetSXENum("GBX", "GBX_CODLAU")
	M->GBX_CODLAU	:= HS_VSxeNum("GBX", "M->GBX_CODLAU", 1)
	cCodLau := M->GBX_CODLAU
	ConfirmSX8()
Else
	cCodLau := GBY->GBY_CODLAU
EndIf

cCodPro := GBY->GBY_PROLAU
cCodCrm := GBY->GBY_CODCRM

If !lReadOnly .And. Empty(cCodQues) .And. lTPLAUDO
	
	nLGGR := HS_BDados("GGR", @aHGGR, @aCGGR, @nUGGR, 1, , "GGR_CODPRO = '" + cCodPro + "' AND (GGR_CODCRM IN ('" + cCodCrm + "', '" + Space(Len(cCodCrm)) + "'))")
	nGGRCDQUES := aScan(aHGGR, {| aVet | aVet[2] == "GGR_CDQUES"})
	
	If nLGGR == 0
		HS_MsgInf(STR0030, STR0028, STR0031)//"Nao existe grupo de perguntas associado !"###"Atenção", "Monta Questionário"
		Return(.F.)
	ElseIf nLGGR == 1 // Se for apenas 1 o usuario nao escolhe
		cCodQues := aCGGR[1, nGGRCDQUES]
	Else // Se tiver mais que 1 o usuario escolhe qual ele vai utilizar
		
		Define MsDialog oDlgGGR Title OemToAnsi(STR0047) From 000, 000 To 500, 850 Of oMainWnd PIXEL // "Laudos"
		
		oGDGGR := MsNewGetDados():New(0, 0, 425, 220, 0, ,, ,,,,,,, oDlgGGR, aHGGR, aCGGR)
		oGDGGR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
		Activate MsDialog oDlgGGR Centered On Init EnchoiceBar(oDlgGGR, {|| nOpcA := 1, oDlgGGR:End()}, {|| nOpcA := 0, oDlgGGR:End() } )
		
		If nOpcA == 0
			Return(.F.)
		ElseIf !Empty(oGdGGR:aCols[oGdGGR:nAt, nGGRCDQUES])
			cCodQues := oGdGGR:aCols[oGdGGR:nAt, nGGRCDQUES]
		EndIf
		
	EndIf
	
EndIf

If lTPLAUDO // Laudo via Protheus...
	lOk := HS_DgLaudo(cCodLau, lReadOnly, GBY->GBY_SOLICI, cCodQues, nRecGBY, nOpc, lLiberacao)
Else // Laudo via Word
	If GBY->GBY_STATUS == "0" .OR. GBY->GBY_STATUS == "1"
		lOk := FS_Result(Nil, cCodLau,cCodCrm)
	EndIf
EndIf

If lOk .and. !lReadOnly
	If ExistBlock("HSCFGP31")
		lRet := Execblock("HSCFGP31", .F., .F.,Nil)
	EndIf
	
	Begin Transaction
	
	DbSelectArea("GBX")
	If !Empty(GBY->GBY_CODLAU)
		DbSeek(xFilial("GBX") + cCodLau)
	EndIf
	
	Reclock("GBX", Empty(GBY->GBY_CODLAU))
	GBX->GBX_FILIAL	:= xFilial("GBX")
	GBX->GBX_CODLAU	:=	cCodLau
	GBX->GBX_PROLAU	:=	GBY->GBY_PROSOL
	GBX->GBX_DATGER	:= dDataBase
	GBX->GBX_HORGER	:= Time()
	GBX->GBX_USUGER	:= cUserName
	GBX->GBX_LOGARQ	:= Hs_LogArq()
	MsUnlock()
	
	cSql := "UPDATE " + RetSqlName("GBY") + " "
	cSql += "SET GBY_STATUS = '" + IIf(!lLiberacao,"1","2") + "', "
	cSql +=     "GBY_CODLAU	=	'" + GBX->GBX_CODLAU + "', "
	cSql +=     "GBY_PROLAU	=	'" + GBX->GBX_PROLAU + "', "
	cSql += "        GBY_CDQUES = '" + cCodQues + "', "
	cSql += "        GBY_CODCRM = '" + GBY->GBY_CODCRM + "', "
	cSql += "        GBY_TECNIC = '" + GBY->GBY_TECNIC + "', "
	cSql += "        GBY_CRMLAU = '" + GBY->GBY_CRMLAU + "' "
	cSql += "WHERE GBY_FILIAL = '" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*' "
	cSql +=   "AND GBY_SOLICI IN (" + cInSql + ") "
	
	TcSqlExec(cSql)
	
	If lLiberacao
		cSql := "UPDATE " + RetSqlName("GBY") + " "
		cSql += "SET GBY_STATUS = '2' "
		cSql += "WHERE GBY_FILIAL = '" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*' "
		cSql +=   "AND GBY_CODLAU = '" + cCodLau + "' "
		
		TcSqlExec(cSql)
		
		Hs_GerDesp(__aMarkBrw)
		
	EndIf
	
	End Transaction
	
	If ExistBlock("HSGCFP31")
		Execblock("HSGCFP31", .F., .F.,Nil)
	EndIf
	
EndIf

oMB:oBrowse:Refresh()

RestArea(aArea)
Return(Nil)

Static Function Fs_IniVar()
	 aVetVar := {}
	 If !HS_EXISDIC({{"T","GND"},{"T","GNE"}})
		 aVetVar := HS_PrivVar(GBY->GBY_REGATE, .F.)
		 aAdd(aVetVar, {"cExame"    , GBY->GBY_SOLICI})
		 aAdd(aVetVar, {"cData"     , DtoC(GBY->GBY_DATSOL)})
		 aAdd(aVetVar, {"cHora"     , GBY->GBY_HORSOL})
		 aAdd(aVetVar, {"cPaciente" , GCY->GCY_REGATE + '-' + Substr(GCY->GCY_NOME, 01, 28)})
		 aAdd(aVetVar, {"cIdade"    , FS_Idade(GBH->GBH_DTNASC, GCY->GCY_DATATE)})
		 aAdd(aVetVar, {"cSexo"     , Iif(GBH->GBH_SEXO == '1', 'FEMININO ', 'MASCULINO')})
		 aAdd(aVetVar, {"cConvenio" , GCM->GCM_CODCON + '-' + AllTrim(GA9->GA9_NREDUZ) + '-' + PadR(AllTrim(HS_DesPla(GCM->GCM_CODCON, GD4->GD4_CODPLA)), 09)})
		 aAdd(aVetVar, {"cMedico"   , AllTrim(GBY->GBY_CODCRM) + '-' + Posicione("SRA", 11, xFilial("SRA") + GBY->GBY_CODCRM, "RA_NOME")})
		 aAdd(aVetVar, {"cMedSol"   , AllTrim(GBY->GBY_CRMLAU) + '-' + Posicione("SRA", 11, xFilial("SRA") + GBY->GBY_CRMLAU, "RA_NOME")})
		 aAdd(aVetVar, {"cCodLoc"   , GCY->GCY_CODLOC + "-" + AllTrim(GCS->GCS_NOMLOC)})
		 aAdd(aVetVar, {"cQuarto"   , GCY->GCY_QUAINT})
		 aAdd(aVetVar, {"cLeito"    , GCY->GCY_LEIINT})
		 aAdd(aVetVar, {"cDescricao", Space(01)})
	 Else
	  aVetVar := FS_PrivVar(GBY->GBY_REGATE, .F.) 
	 EndIf
Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_DgLaudo³ Autor ³Luiz Pereira S. Junior ³ Data ³ 01/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta Questionario                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ HS_LAUDO                                    					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero da Solicitacao                              ³±±
±±³          ³ ExpC2 = Codigo do Procedimento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_DgLaudo(cCodLau, lReadOnly, cSolic, cCodQues, nRecGBY, nOpc, lLiberacao)
 Local aArea		:= {}

 Local lTPIMPLA	 := (GetMV("MV_TPIMPLA") == "1")
 Local lHSDTHO31 := ExistBlock("HSDTHO31")
 Local lRet      := .F.
 
 Private lRefresh	:= .T. 
 Private aTelaQues := {}

 Default lReadOnly := .F.
 Default lLiberacao := .F.
 
 aArea := GetArea()
 
 lRet := HS_M17Roti("GBY", nRecGBY, nOpc, cCodQues, lReadOnly, cCodLau, lLiberacao)

 If lRet .And. !lReadOnly //Se o usuario nao cancelou a tela de perguntas e nao eh somente leitura
 	
 	//Ponto de Entrada solicitado pela IDAPI, para gravar a data e hora de digitacao do Laudo.
 	If lHSDTHO31
 		Execblock("HSDTHO31", .F., .F., Nil)
 	EndIf
 	
 	If MsgYesNO(STR0033) // "Imprime Laudo ?"
 		If lTPIMPLA
 			HSPAHRB1({{cSolic, cCodLau}})
 		Else
 			FS_Result(1,cCodLau,cCodCrm)
 		EndIf
 	EndIf
 EndIf

 RestArea(aArea)
Return(lRet)

Function HS_M17CANC(cAlias, nReg, nOpc)

 Local cLogArq := HS_LogArq()
 Local cSolic  := GBY->GBY_SOLICI
 Local cCodLau := GBY->GBY_CODLAU

 If GBY->GBY_IDMARC <> cMark
 	HS_MsgInf(STR0012, STR0028, STR0032) //"Marque e posicione o laudo principal !"###"Atenção" ###"Cancelamento de Liberaçao"
 	Return(.F.)
 Endif

 If GBY->GBY_STATUS <> "2"
  HS_MsgInf(STR0034, STR0028, STR0032)// "Este laudo não pode ter a liberação cancelada"###"Atenção"###"Cancelamento de Liberação"
  Return(.F.)
 EndIf
 
 If !MsgYesNo(STR0049)
  Return(.F.)
 EndIf

 IIF(Alias()         # "GBY"  , DbSelectArea("GBY"), Nil)
 IIF(IndexOrd()      # 3      , DbSetOrder(3), Nil)// GBY_FILIAL+GBY_CODLAU+GBY_SOLICI                     
 DbSeek(xFilial("GBY") + cCodLau)
	 
 If HS_DgLaudo(GBY->GBY_CODLAU, .T., GBY->GBY_SOLICI, GBY->GBY_CDQUES, nReg, nOpc)
  Begin Transaction  
   While GBY->(!EoF()) .And. GBY->GBY_FILIAL == xFilial("GBY") .And. cCodLau == GBY->GBY_CODLAU
  DbSelectArea("GD7")
  DbSetOrder(1)
  If DbSeek(xFilial("GD7")+GBY->GBY_SEQDES)
    RecLock("GD7", .F.)
     DbDelete()
    MsUnLock() 
		  EndIf

				IIF(Alias()         # "GBY"  , DbSelectArea("GBY"), Nil)
				IIF(IndexOrd()      # 3      , DbSetOrder(3), Nil)// GBY_FILIAL+GBY_CODLAU+GBY_SOLICI                     

    RecLock("GBY", .F.)
     GBY->GBY_SEQDES := Space(Len(GBY->GBY_SEQDES)) 
  		 GBY->GBY_STATUS := '1'                       
  		 GBY->GBY_LGCANC := cLogArq  
    MsUnLock()  
  
    DbSkip()     
			EndDo  
  End Transaction
 EndIf
 
 IIF(Alias()         # "GBY"   , DbSelectArea("GBY"), Nil)
 IIF(IndexOrd()      # 1       , DbSetOrder(1), Nil)// GBY_FILIAL+GBY_SOLICI+DTOS(GBY_DATSOL)+GBY_HORSOL
 IIF(cSolic # GBY->GBY_SOLICI  , DbSeek(xFilial("GBY") + cSolic), Nil)	                                                                                                                  
    
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Idade      ³ Autor ³                  ³ Data   /  /     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula a idade do Paciente                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_Idade(dDataI, dDataF)
 Local aIdade := HS_DifData(dDataI, dDataF)

Return(StrZero(aIdade[1], 2) + STR0016 + StrZero(aIdade[2], 2) + STR0017 + StrZero(aIdade[3], 2) + STR0018) //" ano(s) "###" mes(es) "###" dia(s) "

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_Result      ³ Autor ³  José Orfeu      ³ Data 29/08/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digitação do Resultado do Exame                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Result(nLaudAP, cCodLau, cCodCrm)

Local cDirLaud	:= AllTrim(GetMV("MV_DIRLAUD"))
Local cDirMode	:= AllTrim(GetMV("MV_DIRMODE"))
Local cArqLaud	:= "", cArqMode := "", cArqPadr := "", cVarPerg	:= ""
Local aVetTMP	:= {}
Local nCont		:= 0, nOpcA := 0
Local nLGGU		:= 0, aHGGU := {}, aCGGU := {}, nUGGU := 0
Local cSeqMod	:= ""
Local oGDGGU

Private oWord
Private nGGUMODELO := 0, nGGUSEQMOD := 0

Default nLaudAP := 0
Default cCodLau := GBY->GBY_CODLAU
Default cCodCrm := ""

If SubStr(cDirLaud, Len(cDirLaud), 1) == "\"
	cDirLaud := SubStr(cDirLaud, 1, Len(cDirLaud) - 1)
EndIf

If SubStr(cDirMode, Len(cDirMode), 1) == "\"
	cDirMode := SubStr(cDirMode, 1, Len(cDirMode) - 1)
EndIf

nLGGU := HS_BDados("GGU", @aHGGU, @aCGGU, @nUGGU, 1, , "GGU_CODPRO = '" + GBY->GBY_PROLAU + "' AND (GGU_CODCRM IN ('" + cCodCrm + "', '" + Space(Len(cCodCrm)) + "'))")
nGGUSEQMOD := aScan(aHGGU, {| aVet | aVet[2] == "GGU_SEQMOD"})
nGGUMODELO := aScan(aHGGU, {| aVet | aVet[2] == "GGU_MODELO"})

If nLGGU == 0
	HS_MsgInf(STR0035, STR0028, STR0036) // "Nao existe modelo associado !"###"Atenção"###"Laudo e Resultados"
	Return(.F.)
ElseIf nLGGU == 1 // Se for apenas 1 o usuario nao escolhe
	cSeqMod := aCGGU[1, nGGUSEQMOD]
Else // Se tiver mais que 1 o usuario escolhe qual ele vai utilizar
	
	Define MsDialog oDlgGGU Title OemToAnsi(STR0037) From 000, 000 To 500, 850 Of oMainWnd PIXEL //"Modelos Laudo"
	
	oGDGGU := MsNewGetDados():New(0, 0, 425, 220, 0, ,, ,,,,,,, oDlgGGU, aHGGU, aCGGU)
	oGDGGU:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	Activate MsDialog oDlgGGU Centered On Init EnchoiceBar(oDlgGGU, {|| nOpcA := 1, oDlgGGU:End()}, {|| nOpcA := 0, oDlgGGU:End() } )
	
	If nOpcA == 0
		Return(.F.)
	ElseIf !Empty(oGdGGU:aCols[oGdGGU:nAt, nGGUMODELO])
		cSeqMod := oGdGGU:aCols[oGdGGU:nAt, nGGUSEQMOD]
	EndIf
	
EndIf

cType  := "LAUDOS	     | *.DOT"
cTexto := ""
cArqLaud := cDirLaud + "\" + cCodLau +	 ".DOC"
cArqMode := cDirMode + "\" + Alltrim(cSeqMod) + AllTrim(GBY->GBY_PROLAU) +	".DOC"
cArqPadr := cDirMode + "\ExamPadr.Doc"

If nLaudAP == 1
	
	Fs_IniVar() //Inicializa Variáveis para impressão no word
	
	aVetTMP := HS_BusResp("GCP", {{"GCP->GCP_SOLICI", cCodLau}}, "GCP")
	For nCont := 1 To Len(aVetTMP)
		
		aAdd(aVetVar, {aVetTMP[nCont,1], aVetTMP[nCont,2]})
		
	Next nCont
	
Endif

HS_OpeWord(cArqLaud, cArqMode, cArqPadr)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³HS_OPEWORDº Autor ³ José Orfeu           Data     29/08/2002º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Rotina para a abertura do arquivo texto na FunMEMO         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso	     ³ Espec¡fico para clientes Microsiga						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_OpeWord(cArqLaud, cArqMode, cArqPadr)

If !File(cArqLaud)
	If !File(cArqMode)
		_CopyFile(cArqPadr, cArqLaud)
	Else
		_CopyFile(cArqMode, cArqLaud)
	EndIf
EndIf

OpenWord(@oWord, cArqLaud)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OpenWord    ³ Autor ³ Cristina Ogura      ³ Data ³ 19.04.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Trata as variaveis de abertura quando utiliza o Word     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especifico                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OpenWord(oWord,cFile)
Local nVarWord := 0

OLE_CloseFile(oWord)
OLE_CloseLink(oWord)

// Inicializa o Ole com o MS-Word 97 ( 8.0 )
oWord := OLE_CreateLink('TMsOleWord97')

OLE_OpenFile(oWord, cFile)

For nVarWord := 1 To Len(aVetVar)
	OLE_SetDocumentVar(oWord, aVetVar[nVarWord, 1], aVetVar[nVarWord, 2])
Next

//--Atualiza Variaveis
OLE_UpDateFields(oWord)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³HS_M17PREC³ Autor ³ Robson Ramiro Oliveira³ Data ³ 20.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Precaucoes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ HS_M17PREC                              					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ HSP														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_M17PREC

HS_PRECAU({GBY->GBY_PROSOL})

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M17ENTR ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 20.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrega dos resultados                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M17ENTR                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_M17ENTR(cAlias, nReg, nOpc)
Local oDlg, oBt01, oBt02, oMotiv
Local cMotivo	:= CriaVar("GBX_MOTIVO")
Local nOpcA		:= 0
Local cTmpCod	:= GBY->GBY_CODLAU
Local aArea		:= GetArea()
Local oComboBox
Local aItens	:= {STR0019, STR0020, STR0021} //"Paciente"###"Medico"###"Familiar"
Local cChoice	:= "", cSql := "", cInSql := ""
Local nFor		:= 0

If Empty(GBY->GBY_CODLAU)
	HS_MsgInf(STR0022, STR0028, STR0003) //"Essa solicitacao ainda nao possue laudo!""###"Atenção"###"Resultados"
	Return(.F.)
EndIf

If GBY->GBY_IDMARC <> cMark
	HS_MsgInf(STR0012, STR0028 , STR0008) //"Marque e posicione o laudo principal !"###"Atenção"###"Resultados"
	Return(.F.)
EndIf

For nFor := 1 To Len(__aMarkBrw)
	If Len(__aMarkBrw) == 1
		cInSql += "'" + __aMarkBrw[nFor][1] + "'"
	Else
		cInSql += "'" + __aMarkBrw[nFor][1] + "'" + IIf(nFor < Len(__aMarkBrw), ",","")
	EndIf
Next nFor

cSql := "SELECT * FROM " + RetSqlName("GBY") + " "
cSql += "WHERE GBY_FILIAL ='" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*' AND "
cSql +=       "GBY_SOLICI IN (" + cInSql + ")"

cSql := ChangeQuery(cSql)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "TMPGBY", .F., .F.)
DbSelectArea("TMPGBY")
DbGotop()

Do While !TMPGBY->(Eof())
	If cTmpCod	<> TMPGBY->GBY_CODLAU
		HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + STR0023, STR0028, STR0003) //"A Solicitacao "###" nao pode ser entregue em conjunto!"//"Atenção"##"Resultados"
		DbSelectArea("TMPGBY")
		DbCloseArea()
		RestArea(aArea)
		Return(.F.)
	ElseIf TMPGBY->GBY_STATUS <> "2"
		If TMPGBY->GBY_STATUS < "2"
			HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + STR0050, STR0028, STR0003) //"A Solicitacao "###" ja teve o laudo entregue !""###"Atenção"##"Resultados"
		ElseIf TMPGBY->GBY_STATUS > "3"
			HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + STR0051, STR0028, STR0003) //"A Solicitacao "###" ja teve o laudo entregue !""###"Atenção"##"Resultados"
		Else
			HS_MsgInf(STR0013 + TMPGBY->GBY_SOLICI + STR0024, STR0028, STR0003) //"A Solicitacao "###" ja teve o laudo entregue !""###"Atenção"##"Resultados"
		EndIf
		
		DbSelectArea("TMPGBY")
		DbCloseArea()
		RestArea(aArea)
		Return(.F.)
	EndIf
	
	TMPGBY->(DbSkip())
Enddo

DbSelectArea("TMPGBY")
DbCloseArea()

If !Empty(GBY->GBY_RECLAU)
	cChoice := aItens[Val(GBY->GBY_RECLAU)]
Else
	cChoice := aItens[1]
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo From 09, 00 To 18, 65 Of oMainWnd

@ 015, 008 Say OemToAnsi(STR0025) Size 60, 00 PIXEL COLOR CLR_BLUE OF oDlg //"Motivo"
@ 015, 060 MSGet oMotiv Var cMotivo Picture "@!" Valid !Empty(cMotivo) Size 180, 10 PIXEL OF oDlg

@ 030, 008 SAY OemToAnsi(STR0026) SIZE 040,010 PIXEL COLOR CLR_BLUE OF oDlg //"Recebido por:"
@ 030, 060 COMBOBOX oComboBox VAR cChoice ITEMS aItens SIZE 070,015 OF oDlg PIXEL

DEFINE SBUTTON oBt01 From 050, 008 Type 1 Action {|| nOpcA := 1, cChoice := Str(oComboBox:nAt, 1, 0), oDlg:End()} Enable Of oDlg
DEFINE SBUTTON oBt02 From 050, 060 Type 2 Action {|| oDlg:End()} Enable Of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcA == 1
	
	Begin Transaction
	DbSelectArea("GBX")
	DbSeek(xFilial("GBX") + GBY->GBY_CODLAU)
	
	Reclock("GBX", .F.)
	GBX->GBX_DATENT	:= dDataBase
	GBX->GBX_HORENT	:= Time()
	GBX->GBX_USUENT	:= cUserName
	GBX->GBX_MOTIVO := cMotivo
	GBX->GBX_LOGARQ	:= Hs_LogArq()
	MsUnlock()
	
	
	cSql := "UPDATE " + RetSqlName("GBY") + " "
	cSql += "SET GBY_STATUS = '3', "
	cSql +=     "GBY_CODLAU	=	'" + GBX->GBX_CODLAU + "', "
	cSql +=     "GBY_RECLAU	= '" + cChoice + "', "
	cSql +=     "GBY_DATENT	=	'" + DTOS(GBX->GBX_DATENT) + "', "
	cSql +=     "GBY_HORENT	=	'" + GBX->GBX_HORENT + "', "
	cSql +=     "GBY_MOTIVO	=	'" + GBX->GBX_MOTIVO + "' "
	cSql += "WHERE GBY_FILIAL = '" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*' "
	cSql +=   "AND GBY_SOLICI IN (" + cInSql + ") "
	
	TcSqlExec(cSql)
	
	End Transaction
	
	cFicha := GetMV("MV_LAUFENT")
	If !Empty(cFicha)
		&(cFicha)
	EndIf
	
EndIf

RestArea(aArea)

Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M17F12  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 21.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da rotina pelo F12                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M17F12                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_M17F12
Local oMBrw := GetMarkBrow()

If !Pergunte(cPerg, .T.)
	Return(.F.)
Endif

FS_M17FILT()

SetMBTopFilter("GBY", cFiltro)
DbSeek(xFilial("GBY"))

oMBrw:oBrowse:GoTop()
oMBrw:oBrowse:Refresh()

Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_M17FILT ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 21.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da rotina                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_M17FILT                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

/*/

/*
HSPM17   ¦ 01       ¦ Setor ?
HSPM17   ¦ 02       ¦ Da Data ?
HSPM17   ¦ 03       ¦ Ate a Data ?
HSPM17   ¦ 04       ¦ Do Procedimento ?
HSPM17   ¦ 05       ¦ Ate o Procedimento ?
HSPM17   ¦ 06       ¦ Crm Laudo ?
HSPM17   ¦ 07       ¦ CRM Solicitante
HSPM17   ¦ 08       ¦ Tecnico ?
HSPM17   ¦ 09       ¦ Status ?
*/
Static Function FS_M17FILT()

cFiltro := "GBY_FILIAL = '" + xFilial("GBY") + "' "
cFiltro += "AND D_E_L_E_T_ <> '*' "
cFiltro += "AND GBY_CODLOC = '" + MV_PAR01 + "' "
cFiltro += "AND GBY_DATSOL BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' "
cFiltro += "AND GBY_PROSOL BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "

If !Empty(MV_PAR06)
	cFiltro += "AND GBY_CRMLAU = '" + MV_PAR06 + "' "
EndIf

If !Empty(MV_PAR07)
	cFiltro += "AND GBY_CODCRM = '" + MV_PAR07 + "' "
EndIf

If !Empty(MV_PAR08)
	cFiltro += "AND GBY_TECNIC = '" + MV_PAR08 + "' "
EndIf

If (MV_PAR09 - 1) <> 4
	cFiltro += "AND GBY_STATUS = '" + Str((MV_PAR09 - 1), 1, 0) + "' "
EndIf

cGBYCodLoc := MV_PAR01

Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_M17IMPR ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 21.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama Rotina de Impressao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M17IMPR                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function HS_M17IMPR()
Local lTPIMPLA := (GetMV("MV_TPIMPLA") == "1")
Local cDirLaud := AllTrim(GetMV("MV_DIRLAUD"))
Local cArqLaud := ""
Local nIMark   := 0
Local oWord
Local cMsgErro := ""
Local aMBrow   := {}
Local nCopias  := 0
Local lHSM17W  := .F.

If Len(__aMarkBrw) == 1
	__aMarkBrw := {}
	HS_M17MARK(@__aMarkBrw)
EndIf

// Verifica se todos os registros marcados possuem laudo.
For nIMark := 1 To Len(__aMarkBrw)
	If __aMarkBrw[nIMark][3] // .T. (GBY_STATUS == "0") Solicitação ainda não foi laudada
		cMsgErro += STR0013 + __aMarkBrw[nIMark][1] + STR0027 + Chr(10) //"A Solicitacao "###" ainda nao teve laudo!"
	Else
		aAdd(aMBrow, __aMarkBrw[nIMark])
	EndIf
Next

If Len(aMBrow) > 0 // Verifica se existe solicitações laudadas para impressão
	If lTPIMPLA
		HSPAHRB1(aMBrow)
	Else
		
		If IIf(lHSM17W := SX1->(DBSeek("HSM17W")), Pergunte("HSM17W", .T.), .T.)
			
			If SubStr(cDirLaud, Len(cDirLaud), 1) == "\"
				cDirLaud := SubStr(cDirLaud, 1, Len(cDirLaud) - 1)
			EndIf
			
			// Cria integração Protheus X Word
			oWord := OLE_CreateLink("TMsOleWord97")
			
			// .T. Abre tela do Word .F. Não abre tela do Word
			OLE_SetProperty(oWord, oleWdVisible, .F.)
			
			// Não sei a finalidade aindaOr
			OLE_SetProperty(oWord, oleWdPrintBack, .F.)
			
			For nIMark := 1 To Len(aMBrow)
				cArqLaud := cDirLaud + "\" + aMBrow[nIMark][2] +	".DOC"
				
				// Abre ou cria arquivo para impressão
				OLE_NewFile(oWord, cArqLaud)
				
				// Abre arquivo
				//OLE_OpenFile(oWord, cArqLaud)
				
				For nCopias := 1 To IIf(!lHSM17W .Or. MV_PAR01 <= 0, 1, MV_PAR01)
					// Envia documento Word para impressão
					OLE_PrintFile(oWord, "ALL", /*nPagInicial*/, /*nPagFinal*/, /*nCopias*/) // para usar esses parametros não pode passar o parametro "ALL" / "PART"
				Next
				
				// Fecha arquivo
				OLE_CloseFile(oWord)
			Next
			
			//Fecha integração Protheus X Word
			OLE_CloseLink(oWord)
		EndIf
		
		// Restaura MV_PAR's do grupo de pergunta HSPM17
		Pergunte("HSPM17", .F.)
	EndIf
EndIf

If !Empty(cMsgErro)
	HS_MsgInf(cMsgErro, STR0028, STR0006) //"Atenção"###"Impressao"
ElseIf Len(aMBrow) == 0
	HS_MsgInf(STR0038, STR0028, STR0006) //"Marque o(s) laudo(s) antes de clicar na opção impressão"###"Atenção"###"Impressao"
EndIf

Return(Nil)

Function HS_RelM17(cAlias, nReg, nOpc)

GDN->(dbSetOrder(1))
If GDN->(DbSeek(xFilial("GDN") + cGBYCodLoc))
	
	HSPAHP44(.F., cGBYCodLoc)
	
Else
	HS_MsgInf(STR0039, STR0028, STR0040) //"O setor não possui fichas"###"Atenção"###"Docs\Relat."
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldM17 ºAutor  ³Luiz Pereira S. Jr. º Data ³  20/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacoes dos campos                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VldM17()
Local lRet   := .T.
Local aArea  := GetArea()
Local cCampo := ReadVar()

If cCampo == "M->GBY_CODCRM"
	If !(lRet := HS_SeekRet("SRA","M->GBY_CODCRM",11,.f.,"GBY_NOMMED","RA_NOME"))
		HS_MsgInf(STR0041, STR0028, STR0042) //"Código do CRM inválido"###"Atenção"###"Validação"
	EndIf
	
ElseIf cCampo == "M->GBY_CRMLAU"
	If !(lRet := HS_SeekRet("SRA","M->GBY_CRMLAU",11,.f.,"GBY_NOMLAU","RA_NOME"))
		HS_MsgInf(STR0041, STR0028, STR0042) //"Código do CRM inválido"###"Atenção"###"Validação"
	EndIf
	
ElseIf cCampo == "M->GBY_TECNIC"
	If !(lRet := HS_SeekRet("SRA","M->GBY_TECNIC",11,.f.,"GBY_NOMTEC","RA_NOME"))
		HS_MsgInf(STR0043, STR0028, STR0042) //"Código do Técnico inválido"###"Atenção"###"Validação"
	EndIf
	
EndIf

RestArea(aArea)
Return(lRet)

Static Function FS_PrivVar(cRegAte, lPosGcy)
Local aRVet   := {}
Local cMemVar := ""
Local aArea   := GetArea()

If lPosGcy
	DbSelectArea("GCY")
	DbSetOrder(1)
	DbSeek(xFilial("GCY")+cRegAte)
EndIf

DbSelectArea("GND")
DbSetOrder(1)
DbSeek(xFilial("GND"))

While !(GND->(EoF())) .And. xFilial("GND") == GND->GND_FILIAL
	
	DbSelectArea(GND->GND_ALIASM)
	DbSetOrder(HS_NInd(GND->GND_INDICE))
	
	If DbSeek(&(GND->GND_CHAVE))
		
		DbSelectArea("GNE")
		DbSetOrder(1)
		If DbSeek(xFilial("GNE")+GND->GND_CODSEQ)
			While !(GNE->(EoF())) .And. xFilial("GNE") == GNE->GNE_FILIAL .And. GNE->GNE_SEQGND == GND->GND_CODSEQ
				If GNE->GNE_TIPMAC == "0"
					If Hs_ExisDic({{"C",Trim(GNE_CPOMAC)}},.F.)
						cMemVar := "M->"+Trim(GNE_CPOMAC)
						If HS_CfgSx3(GNE->GNE_CPOMAC)[SX3->(FieldPos("X3_CONTEXT"))] == "V"
							&(cMemVar)  := CriaVar(GNE->GNE_CPOMAC)
							aAdd(aRVet, {GNE->GNE_NOMMAC, CriaVar(GNE->GNE_CPOMAC)})
						Else
							&(cMemVar)  := &(GND->GND_ALIASM+"->"+GNE->GNE_CPOMAC)
							aAdd(aRVet, {Trim(GNE->GNE_NOMMAC), &(GND->GND_ALIASM+"->"+GNE->GNE_CPOMAC)})
						EndIf
					Else
						Hs_MsgInf(STR0059+Trim(GNE->GNE_NOMMAC)+STR0060,STR0028,STR0042)
					EndIf
				Else
					aAdd(aRVet, {Trim(GNE->GNE_NOMMAC), &(GNE->GNE_CPOMAC)})
				EndIf
				DbSkip()
			End
		EndIf
	EndIf
	DbSelectArea("GND")
	DbSkip()
End

RestArea(aArea)

Return(aRVet)

Function Hs_GerDesp(aMarkBrw, cRegAte, cRegGer, cAtendi, dDataAte, cLocAte, cCodPla, cCondGuia, cMsgGuia, cMsgGNova, cMsgNGcz, cCodTpg, bFnGerGui)
Local lRet    := .F.
Local aArea   := getArea()
Local cNrGuia := ""
Local cNrSol  := ""
Local nPos    := 0
Local cAtend  := "", cCpoCh := "M->GD7_SEQDES"
Local nFor    := 0
Local cMV_AteSus  := GetMv("MV_ATESUS")
Local __cCodCon  := ""
Local __cCodBPA  := ""
Local __cCodPAC  := ""
Local __cCodAIH  := ""

If cMV_AteSus == "S"
	aVParam     := {{"MV_PCONSUS", ""},{"MV_PSUSBPA", ""},{"MV_PSUSPAC", ""},{"MV_PSUSAIH", ""}}
	If !HS_VMVSUS(@aVParam)
		Return()
	Else
		__cCodCon  := aVparam[1][2]
		__cCodBPA  := aVparam[2][2]
		__cCodPAC  := aVparam[3][2]
		__cCodAIH  := aVparam[4][2]
		aVparam := Nil
	EndIf
EndIf

For nFor := 1 To Len(aMarkBrw)
	
	cNrSol := aMarkBrw[nFor][1]
	
	DbSelectArea("GBY")
	DbSetOrder(1)
	
	If !DbSeek(xFilial("GBY")+cNrSol)
		Loop
	EndIf
	
	If !Empty(GBY->GBY_SEQDES)
		Loop
	EndIF
	
	If cAtend <> GBY->GBY_REGATE
		cNrGuia := Hs_RetGuia(cRegAte, cRegGer, cAtendi, dDataAte, cLocAte, cCodPla, cCondGuia, cMsgGuia, cMsgGNova, cMsgNGcz, cCodTpg, bFnGerGui)
	EndIf
	
	If Empty(cNrGuia)
		cAtend := GBY->GBY_REGATE
		Loop
	EndIF
	
	IIF(Alias()         # "GCY"  , DbSelectArea("GCY"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil)// GCY_FILIAL+GCY_REGATE
	IIf(GCY->GCY_REGATE # GBY->GBY_REGATE, DbSeek(xFilial("GCY") + GBY->GBY_REGATE), Nil)
	
	cAlias  := "GD7"
	cPref   := "GD7->GD7"
	cSeqDes := HS_VSxeNum(cAlias, cCpoCh, 1)
	ConfirmSx8()
	
	aRValDes := HS_RValPr(GBY->GBY_PROSOL, HS_INIPADR("GD4",1, GCY->GCY_REGGER, "GD4_CODPLA",,.T.), IIF(cLocAte == Nil,GBY->GBY_CODLOC,cLocAte), Time(), "2", GBY->GBY_CODCRM, "", {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE}, .T., dDataBase)
	
	If aRValDes[1] <> 0
		//cMsg += "Solicitação - "+GBY->GBY_SOLICI+" Exame - "+GBY->GBY_PROSOL+ CHR(10)
		DbSelectArea(cAlias)
		DbSkip()
		Loop
	EndIf
	
	DbSelectArea(cAlias)
	RecLock(cAlias, .T.)
	&(cPref + "_FILIAL") := xFilial(cAlias)
	&(cPref + "_SEQDES") := cSeqDes
	&(cPref + "_NRSEQG") := cNrGuia
	&(cPref + "_REGATE") := GBY->GBY_REGATE
	&(cPref + "_CODLOC") := IIF(cLocAte == Nil,GCY->GCY_CODLOC,cLocAte)
	&(cPref + "_CODDES") := GBY->GBY_PROSOL
	
	&(cPref + "_HORDES") := HS_DATPAT(.F.)
	&(cPref + "_DATDES") := HS_DATPAT(.T.)
	
	&(cPref + "_CODCRM") := IIf(Empty(GBY->GBY_CRMLAU),GBY->GBY_CODCRM,GBY->GBY_CRMLAU)
	&(cPref + "_CRMLAU") := GBY->GBY_CODCRM
	
	&(cPref + "_CODPCT") := GBY->GBY_CODPCT
	
	&(cPref + "_QTDDES") := 1
	&(cPref + "_SLAUDO") := "1"
	
	&(cPref + "_LOGARQ") := HS_LOGARQ()
	
	&(cPref + "_CODPRE") := aRValDes[14]
	&(cPref + "_COEFAM") := aRValDes[2][1][2]
	&(cPref + "_COEDES") := aRValDes[16][02]
	&(cPref + "_CODESP") := aRValDes[07]
	
	//&(cPref + "_URGDES") := aRValDes[2][14]
	&(cPref + "_URGDES") := IIF(GBY->GBY_URGDES $ "0/1",GBY->GBY_URGDES,aRValDes[2][14])
	&(cPref + "_COECHP") := aRValDes[2][10]
	&(cPref + "_QTDCHP") := aRValDes[2][11]
	&(cPref + "_VLRCOS") := aRValDes[2][24]
	&(cPref + "_PGTMED") := aRValDes[9][1]
	&(cPref + "_COECHM") := aRValDes[9][aRValDes[11]]
	&(cPref + "_REPAMB") := aRValDes[9][aRValDes[10]]
	
	&(cPref + "_VALDES") := aRValDes[02][01][01]
	&(cPref + "_PCUDES") := aRValDes[03]
	&(cPref + "_GLODES") := IIf(aRValDes[04][01], "2", "0")
	&(cPref + "_CODPRT") := aRValDes[02][15]
	&(cPref + "_DESPRT") := aRValDes[02][18]
	&(cPref + "_DOPLER") := "0"
	
	&(cPref + "_ORIDES") := "0"
	
	&(cPref + "_FATPAR") := aRValDes[04][02]
	
	If cMV_AteSus == "S" // Se atende SUS
		If GCZ->GCZ_CODPLA == __cCodBPA // Se atende SUS e o tipo de plano eh BPA
			&(cPref + "_CDGATE") := aRValDes[15][2][1]
			&(cPref + "_CDTATE") := aRValDes[15][3][1]
		EndIf
		If GCZ->GCZ_CODPLA == __cCodBPA .Or. GCZ->GCZ_CODPLA $ __cCodPAC  // Se atende SUS e eh BPA ou APAC
			&(cPref + "_CDAPRO") := aRValDes[15][1][1]
			&(cPref + "_CODCID") := aRValDes[15][4][1]
		EndIf
	EndIf
	
	If HS_ExisDic({{"C", cAlias+"_VALREB"}},.F.)
		&(cPref + "_VALREB") := &(cPref + "_QTDDES") * aRValDes[9][14]
		&(cPref + "_VALREP") := (&(cPref + "_QTDDES") * aRValDes[9][14])
	Else
		&(cPref + "_VALREP") := &(cPref + "_QTDDES") * aRValDes[9][14]
	EndIf
	
	If HS_ExisDic({{"C", cAlias + "_VLREPF"}})
		&(cPref + "_VLREPF") := &(cPref + "_QTDDES") * aRValDes[9][17]
	EndIf
	
	&(cPref + "_VCUSOP") := aRValDes[02][02]
	&(cPref + "_VFILME") := aRValDes[02][03]
	&(cPref + "_VLRCOS") := aRValDes[2][24]
	&(cPref + "_CODPRE") := aRValDes[14]
	
	If Hs_ExisDic({{"C", cAlias + "_TABELA"}}, .F.)
		&(cPref + "_TABELA") := aRValDes[02][20]
	EndIf
	
	MsUnLock()
	
	DbSelectArea("GBY")
	RecLock("GBY",.F.)
	GBY->GBY_SEQDES := cSeqDes
	MsUnLock()
	
	cAtend := GBY->GBY_REGATE
Next nFor
RestArea(aArea)
Return(lRet)

Function Hs_RetGuia(cRegAte, cRegGer, cAtendi, dDataAte, cLocAte, cCodPla, cCondGuia, cMsgGuia, cMsgGNova, cMsgNGcz, cCodTpg, bFnGerGui, lGerRepA)
Local cRet := ""
Local nGuias := 0
Local aArea   := getArea()

Default cRegAte    = GBY->GBY_REGATE
Default cRegGer    = GCY->GCY_REGGER
Default cAtendi    = GCY->GCY_ATENDI
Default dDataAte   = GCY->GCY_DATATE
Default cLocAte    = GCY->GCY_LOCATE
Default cCodPla    = HS_INIPADR("GD4",1, GCY->GCY_REGGER, "GD4_CODPLA",,.T.)
Default cCondGuia  = " GCZ_REGATE = '"+cRegAte+"' AND GCZ_STATUS = '0' "
Default cMsgGuia   = STR0052 //"Há Guia(s) em aberto no Atendimento. Deseja Selecionar uma guia para lançamento da despesa ?"
Default cMsgGNova  = STR0053 //"Deseja lançar nova guia SP/SADT no Atendimento?"
Default cMsgNGcz   = STR0054 //"Não foi encontrado guia(s) SP/SADT em aberto no Atendimento. Deseja lançar nova guia com a despesa ?"
Default cCodTpg    = ""
Default bFnGerGui  = {|| Fs_GerGuia(cRegAte, cRegGer, "0", cAtendi, dDataAte, cLocAte, cCodPla, cCodTpg)}
Default lGerRepA  := .F.

if lGerRepA
	cRet := Eval(bFnGerGui) //Fs_GerGuia(cRegAte, cRegGer, "0", cAtendi, dDataAte, cLocAte, cCodPla, cCodTpg)
else
	If (nGuias := Hs_CountTb("GCZ",cCondGuia)) > 0
		If MsgYesNo(cMsgGuia)
			cRet := Fs_MntGuia(cRegAte, cCondGuia)
		Else
			If MsgYesNo(cMsgGNova)		
			   	If ExistBlock("HSAHM17RTG")
			   		cRet := ExecBlock("HSAHM17RTG",.F.,.F.,{dDataAte,cLocAte,cCodPla,cCodTpg,bFnGerGui})
			  	Else
					cRet := Eval(bFnGerGui) //Fs_GerGuia(cRegAte, cRegGer, "0", cAtendi, dDataAte, cLocAte, cCodPla, cCodTpg)
			  	EndIf		
		  	EndIf
		EndIf
	Else
		If MsgYesNo(cMsgNGcz)
			cRet := Eval(bFnGerGui) //Fs_GerGuia(cRegAte, cRegGer, "0", cAtendi, dDataAte, cLocAte, cCodPla, cCodTpg)
		EndIf
	Endif
endif
RestArea(aArea)
return(cRet)

Static Function Fs_GerGuia(cRegAte, cRegGer, cStatus, cAtendi, dDatAte, cLocAte, cCodPla, cCODTPG, cCond)
Local aArea   := getArea()
Local cRet := ""
Local nTpGuia := 0
Local aHGCU := {}, aCGCU := {}, nUGCU := 0, oGCU
Local nGCUCODTPG := 0
Local cTpGTiss   := ""
Local oDlg
Local nOpca := 0, cNrGuiaP := ""

Private nMv_VldGui := GetMv("MV_VLDGUIA",,0)

Default cCODTPG := ""
Default cCond := 	" GCU.GCU_TGTISS IN (SELECT G17.G17_CODIGO "+ ;
					"                      FROM " + RetSqlName("G17")+" G17 " + ;
					"                     WHERE G17.G17_FILIAL = '"+xFilial('G17')+"' "+ ;
					"                       AND G17.D_E_L_E_T_ <> '*' "+ ;
					"                       AND G17.G17_MODIMP = '1' "+ ;
					"                     UNION "+ ;
					"                    SELECT GN2.GN2_CODTGT "+ ;
					"                      FROM " + RetSqlName("GN2")+ " GN2 "+ ;
					"                     WHERE GN2.GN2_FILIAL = '"+xFilial("GN2")+"' "+ ;
					"                       AND GN2.D_E_L_E_T_ <> '*' "+ ;
                    "                       AND GN2.GN2_MODIMP = '1' ) "+ ;
                    "                       AND GCU_CODTPG IN (SELECT GCV_CODTPG FROM " + RetSqlName("GCV") + " WHERE D_E_L_E_T_=' ' AND GCV_CODPLA='" + GCZ->GCZ_CODPLA + "') "   

If Empty(cCODTPG)
	nTpGuia := HS_BDados("GCU", @aHGCU, @aCGCU, @nUGCU, 1,, cCond,,,"GCU_CODTPG/GCU_DESTPG",,,,,,.T.)
	nGCUCODTPG := aScan(aHGCU,{|aVet|   aVet[2] == "GCU_CODTPG"})
	
	If nTpGuia > 1
		
		DEFINE MSDIALOG oDlg TITLE "Tipo de Guia" From 000, 000 To 300, 500 Of oMainWnd Pixel
		
		oGCU := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlg, aHGCU, aCGCU)
		oGCU:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||nOpca := 1, oDlg:End()}, {|| nOpca := 0, oDlg:End()})
		
		If nOpca == 1
			cCODTPG := oGCU:aCols[oGCU:nAt, nGCUCODTPG]
		EndIf
		
	ElseIf nTpGuia == 1
		cCODTPG := aCGCU[1, nGCUCODTPG]
	Else
		Hs_MsgInf(STR0055,STR0028,STR0056)
		Return(cRet)
	EndIf
EndIf

If !Empty(cCODTPG)
	RegToMemory("GCY",.F.)
	HS_IGuiaP(cRegAte, cRegGer, cStatus, cAtendi, dDatAte, cLocAte, cCodPla, cCODTPG, @cRet)
	
	If GCY->GCY_ATENDI == "0"
		cSql := " SELECT GCZ_NRSEQG, GCZ_NRGUIA "+;
				"   FROM "+RetSqlName("GCZ")+" GCZ "+;
				"   JOIN "+RetSqlName("GCU")+" GCU "+;
				"     ON GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_FILIAL = '"+xFilial("GCU")+"' AND GCU.D_E_L_E_T_ <> '*' "+ ;
				"  WHERE GCZ.GCZ_FILIAL = '"+xFilial("GCZ")+"' AND GCZ.D_E_L_E_T_ <> '*' "+;
				"    AND GCZ.GCZ_REGATE = '"+GCY->GCY_REGATE+"' AND GCZ.GCZ_STATUS = '0' AND GCZ.GCZ_GUIAPR = '"+Space(TamSx3("GCZ_GUIAPR")[1])+"'"+;
				"    AND GCU.GCU_TGTISS IN (SELECT G17.G17_CODIGO "+ ;
				"                             FROM " + RetSqlName("G17")+" G17 " + ;
				"                            WHERE G17.G17_FILIAL = '"+xFilial('G17')+"' "+ ;
				"                              AND G17.D_E_L_E_T_ <> '*' "+ ;
				"                              AND G17.G17_MODIMP = '3' "+ ;
				"                            UNION "+ ;
				"                           SELECT GN2.GN2_CODTGT "+ ;
				"                             FROM " + RetSqlName("GN2")+ " GN2 "+ ;
				"                             WHERE GN2.GN2_FILIAL = '"+xFilial("GN2")+"' "+ ;
				"                               AND GN2.D_E_L_E_T_ <> '*' "+ ;
				"                               AND GN2.GN2_MODIMP = '3' ) "
		
		cSql := ChangeQuery(cSql)
		
		TCQUERY cSQL NEW ALIAS "QRY"
		
		DbSelectArea("QRY")
		DbGoTop()
		
		If QRY->(!Eof())
			cNrGuiaP := QRY->GCZ_NRGUIA
		EndIf
		
		DbCloseArea()
		
		DbSelectArea("GCZ")
		DbSetOrder(1) //GCZ_FILIAL+GCZ_REGATE+GCZ_STATUS+GCZ_NRSEQG
		If DbSeek(xFilial("GCZ")+cRet+"0")
			RecLock("GCZ",.F.)
			GCZ->GCZ_GUIAPR := cNrGuiaP
			MsUnLock()
		EndIf
	EndIf
	
EndIf
RestArea(aArea)
Return(cRet) 

Static Function Fs_MntGuia(cRegAte, cCondGuia)
Local aArea   := getArea()
Local cRet  := ""
Local aHGCZ := {}, aCGCZ := {}, nUGCZ := 0, oGCZ
Local oDlgGuia
Local nOpca := 0
Local nGCZNRSEQG := 0

Private nrGTissAt := .F.

//HS_BDados(cAlias, aHDados, aCDados, nUDados, nOrd, lFilial, cCond                                                                 , lStatus, cCpoLeg, cLstCpo  , cElimina, cCpoNao, cStaReg, cCpoMar, cMarDef, lLstCpo, aLeg, lEliSql, lOrderBy, cCposGrpBy, cGroupBy, aCposIni, aJoin, aCposCalc, cOrderBy, aCposVis, aCposAlt, cCpoFilial)
HS_BDados("GCZ" , @aHGCZ , @aCGCZ , @nUGCZ , 1   ,        , cCondGuia,        ,        ,"/"      ,         ,        ,        ,        ,        ,.T.     ,     ,        ,         ,           ,         ,{"GCZ_NRGUIA","GCZ_CODTPG","GCZ_DESTPG","GCZ_NRSEQG"},      ,          ,         ,         ,         ,           )
nGCZNRSEQG := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRSEQG"})

DEFINE MSDIALOG oDlgGuia TITLE STR0057 From 000, 000 To 300, 500 Of oMainWnd Pixel

oGCZ := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlgGuia, aHGCZ, aCGCZ)
oGCZ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgGuia CENTERED ON INIT EnchoiceBar(oDlgGuia, {||nOpca := 1, oDlgGuia:End()}, {|| nOpca := 0, oDlgGuia:End()})

If nOpca == 1
	cRet := oGCZ:aCols[oGCZ:nAt, nGCZNRSEQG]
EndIf
RestArea(aArea)
return(cRet)

Static Function Fs_CpoObr(aVldCpos)
Local aArea := getArea()
Local lRet  := .T.
Local nI    := 0
Local cMsg  := ""

For nI := 1 to Len(aVldCpos)
	If Empty(&(aVldCpos[nI]))
		cMsg += HS_CfgSx3(aVldCpos[nI])[SX3->(FieldPos("X3_TITULO"))]+" ("+aVldCpos[nI]+")"+chr(10)+chr(13)
	EndIf
Next nI

If !(Empty(cMsg))
	Hs_MsgInf(STR0058+chr(10)+chr(13)+cMsg,STR0028,STR0042)
	lRet := .F.
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemtoAnsi(STR0001), "AxPesqui"  ,	0, 1, 0, nil},;	//"Pesquisar"
 					 {OemToAnsi(STR0002), "HS_M17Visu",	0, 2, 0, nil},;	//"Visualizar"
   					 {OemtoAnsi(STR0003), "HS_M17RESU",	0, 4, 0, nil},;	//"Resultado"
     				 {OemtoAnsi(STR0044), "HS_M17RESU",	0, 4, 0, nil},;	//"Liberar"
            		 {OemtoAnsi(STR0045), "HS_M17CANC",	0, 2, 0, nil},;	//"Cancela Liber."
   					 {OemtoAnsi(STR0004), "HS_M17ENTR",	0, 4, 0, nil},;	//"Entrega"
   					 {OemtoAnsi(STR0005), "HS_M17PREC",	0, 4, 0, nil},;	//"Precaucoes"
 					 {OemtoAnsi(STR0006), "HS_M17IMPR",	0, 2, 0, nil},;	//"Impressao" 													
	      			 {OemtoAnsi(STR0040), "HS_RelM17" ,	0, 2, 0, nil},;	//"Docs/Relat."
 					 {OemtoAnsi(STR0007), "HS_M17LEG" ,	0, 2, 0, nil}}		//"Legenda"
Return(aRotina)
