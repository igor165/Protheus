#INCLUDE "HSPAHA99.ch"
#include "protheus.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA99  บ Autor ณ Gilson da Silva    บ Data ณ  21/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Tipo de Guia                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHA99()
Private aRotina := MenuDef()


mBrowse(06, 01, 22, 75, "GCU")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A99    บ Autor ณ Gilson da Silva    บ Data ณ  21/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Tipo de Guia - Tratamento das funcoes          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A99(cAlias,nReg,nOpc)
Local nOpcA := 0, nGDOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE) 
Local aButtons := {}, bVK_F4

Private aCGCV	:= {}, aHGCV := {}, nUGCV := 0, nLGCV := 0
Private aCGCX	:= {}, aHGCX := {}, nUGCX := 0, nLGCX := 0
Private aCGLT	:= {}, aHGLT := {}, nUGLT := 0, nLGLT := 0

Private aTela := {}, aGets := {}
Private nGCV_CODTPG := 0, nGCV_CODPLA := 0
Private nGCX_CODTPG := 0, nGCX_CODPRO := 0
Private nGLT_CODTPG := 0, nGLT_CODMOD := 0
Private oGLT, oGCV, oGCX, oFolder, pForACols := 0 

Private lTpRet := GCU->GCU_TPGUIA == "7"
Private lAteSUS := GetMv("MV_ATESUS",, "N") == "S"

bVK_F4 := SetKey( VK_F4, { || FS_Busca(oFolder:NOPTION)} )
RegToMemory("GCU",(nOpc == 3)) // Gera variavies de memoria para o GCU

HS_BDados("GCV", @aHGCV, @aCGCV, @nUGCV, 1, M->GCU_CODTPG, IIf(nOpc # 3, "'" + M->GCU_CODTPG + "' == GCV->GCV_CODTPG", Nil))

nGCV_CODTPG := aScan(aHGCV, {| aVet | aVet[2] == "GCV_CODTPG"})
nGCV_CODPLA := aScan(aHGCV, {| aVet | aVet[2] == "GCV_CODPLA"})
nLGCV := IIF(len(aCGCV) == 1 .And. Empty(aCGCV[1,nGCV_CODPLA]),0,len(aCGCV))

HS_BDados("GCX", @aHGCX, @aCGCX, @nUGCX, 1, M->GCU_CODTPG, IIf(nOpc # 3, "'" + M->GCU_CODTPG + "' == GCX->GCX_CODTPG", Nil))
nGCX_CODTPG := aScan(aHGCX, {| aVet | aVet[2] == "GCX_CODTPG"})
nGCX_CODPRO := aScan(aHGCX, {| aVet | aVet[2] == "GCX_CODPRO"})
nLGCX := IIF(len(aCGCX) == 1 .And. Empty(aCGCX[1,nGCX_CODPRO]),0,len(aCGCX))
If lAteSUS
 HS_BDados("GLT", @aHGLT, @aCGLT, @nUGLT, 1, M->GCU_CODTPG, IIf(nOpc # 3, "'" + M->GCU_CODTPG + "' == GLT->GLT_CODTPG", Nil))
 nGLT_CODTPG := aScan(aHGLT, {| aVet | aVet[2] == "GLT_CODTPG"})
 nGLT_CODMOD := aScan(aHGLT, {| aVet | aVet[2] == "GLT_CODMOD"})
 nLGLT := IIF(len(aCGLT) == 1 .And. Empty(aCGLT[1,nGLT_CODMOD]),0,len(aCGLT))
EndIf

nOpcA := 0   

aSize    := MsAdvSize(.T.) 
aObjects := {}
AAdd( aObjects, {100, 30, .T., .T. } ) 
AAdd( aObjects, {100, 70, .T., .T., .T. } )      

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs   := MsObjSize( aInfo, aObjects, .T. )  

aObjects := {}	
AAdd( aObjects, { 100, 100, .T., .T. } )	

aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGDs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Tipo de Guia"
// Monta a Enchoice
oEncGcu := MsMGet():New("GCU", nReg, nOpc,,,,, aPObjs[1],,2,,,,oDlg)
oEncGCU:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
// Monta o Folder   
If lAteSUS
 @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0007, STR0008, STR0039 //"Convenios permitidos"###"Procedimentos permitidos"###"SUS - Modalidades de Atendimento"
Else
@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0007, STR0008 //"Convenios permitidos"###"Procedimentos permitidos"
EndIf
oFolder:Align := CONTROL_ALIGN_BOTTOM
  
oGCV := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,99999,,,, oFolder:aDialogs[1], aHGCV, aCGCV)
oGCV:oBrowse:align := CONTROL_ALIGN_ALLCLIENT   
           
oGCX := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,99999,,,, oFolder:aDialogs[2], aHGCX, aCGCX)
oGCX:oBrowse:align := CONTROL_ALIGN_ALLCLIENT    
If lAteSUS
 oGLT := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,99999,,,, oFolder:aDialogs[3], aHGLT, aCGLT)
 oGLT:oBrowse:align := CONTROL_ALIGN_ALLCLIENT    
EndIf

oEscolhe :={{"Parametros", {|| FS_Busca(oFolder:NOPTION) }, STR0025, "Dados"}} //"Parametros"###"F4 - Busca Dados"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And.;
                                                                   FS_TudoOK("GCV", oGCV, nGCV_CODPLA) .And. ;
                                                                     FS_TudoOK("GCX", oGCX, nGCX_CODPRO) .And. ;
                                                                     FS_VldExcL(M->GCU_CODTPG),;
                                                                     oDlg:End(), nOpcA == 0)}, ;
                                                                     {|| nOpcA := 0, oDlg:End()},,oEscolhe)
If nOpcA == 1
	FS_GrvA99(nOpc)
Else     
  While __lSx8
   RollBackSx8() 
  End 
EndIf

SetKey(VK_F4, bVK_F4)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvA99 บ Autor ณ Gilson da Silva    บ Data ณ  21/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Tipo de Guia                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvA99(nOpc)
Local wProcura := .F.
Local lRet := .T.

aCGCV := aClone(oGCV:aCols)
aCGCX := aClone(oGCX:aCols)
aCGLT := IIF(lAteSus, aClone(oGLT:aCols),{})

If nOpc # 2 // nao for consulta
	DbSelectArea("GCU")
	DBSetOrder(1)
	wProcura := dbseek(xFilial("GCU") + M->GCU_CODTPG)
	If Inclui .or. Altera
		//GRAVA CADASTRO TIPO DE GUIA - GCU
		RecLock("GCU", If(Altera, .F., .T.))
		HS_GRVCPO("GCU")
		MsUnlock()
		ConfirmSx8()
		
		FS_GrvGCU("GCV", 1, "M->GCU_CODTPG + aCGCV[pForACols, nGCV_CODPLA]", aHGCV, aCGCV, nUGCV, nGCV_CODPLA)
		FS_GrvGCU("GCX", 1, "M->GCU_CODTPG + aCGCX[pForACols, nGCX_CODPRO]", aHGCX, aCGCX, nUGCX, nGCX_CODPRO)
  If lAteSus
		FS_GrvGCU("GLT", 1, "M->GCU_CODTPG + aCGLT[pForACols, nGLT_CODMOD]", aHGLT, aCGLT, nUGLT, nGLT_CODMOD)
  EndIf
	Else  // exclusao
		If wProcura
			FS_DelGCU("GCV", 1, "M->GCU_CODTPG + aCGCV[pForACols, nGCV_CODPLA]", aCGCV, nGCV_CODPLA)  // Excluir relacionamento GCV
			FS_DelGCU("GCX", 1, "M->GCU_CODTPG + aCGCX[pForACols, nGCX_CODPRO]", aCGCX, nGCX_CODPRO)  // Excluir relacionamento GCX
			If lAteSus
			FS_DelGCU("GLT", 1, "M->GCU_CODTPG + aCGLT[pForACols, nGLT_CODMOD]", aCGLT, nGLT_CODMOD)  // Excluir relacionamento GLT
			EndIf
			DbSelectArea("GCU")
			RecLock("GCU", .F., .T.)
			DBDelete()
			MsUnlock()
			WriteSx2("GCU")
		Endif
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldA99 บ Autor ณ Gilson da Silva    บ Data ณ  21/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao dos campos chave dos relacionamentos             บฑฑ
ฑฑบ          ณ para inclusao                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldA99(cAlias)
Local lRet := .T., nPos := 0, cAliasW
Local aArea:=GetArea()
Local cCampo := ReadVar()

Default cAlias := ""
     
cAliasW := Substr(cAlias,1,3)
 
If cAlias $ "GCVP"
 DbSelectArea("GCM") //Cadastro de Planos X Convenios
 DbSetOrder(2)
 lRet := DbSeek(xFilial("GCM") + M->GCV_CODPLA)
 GDFieldPut("GCV_DESPLA", GCM->GCM_DESPLA)
 If !lRet
  HS_MsgInf(STR0011, STR0010, STR0033) //"Plano invalido"###"Atencao"###"Valida็ใo do Campos"
 Endif
  
 If lRet .And. !Empty(M->GCV_CODPLA)
  nPos := aScan(oGcv:aCols, {| aVet | aVet[nGcv_CodPla] ==  M->GCV_CODPLA})
  If nPos > 0 .And. nPos # oGcv:oBrowse:nAt  // Verifica se este Plano ja foi cadastrado para o Tipo de Guia 
   HS_MsgInf(STR0012, STR0010, STR0033) //"Convenio/Plano ja cadastrado para este Tipo de Guia"###"Atencao"###"Valida็ใo do Campos"
   lRet := .F.     
  Else
   DbSelectArea("GCM")    //Verifica se existe o relacionamento Convenio/Plano
   DbSetOrder(2)
   If !DbSeek(xFilial("GCM") + M->GCV_CODPLA) 
    HS_MsgInf(STR0013, STR0014, STR0033) //"Nao existe o relacionamento Convenio/Plano informado"###"Verifique"###"Valida็ใo do Campos"
    lRet := .F.
   Endif
  Endif
 EndIf 
ElseIF cAlias == "GCX"     
  DbSelectArea("GA7")     //Cadastro de Procedimento
  DbSetOrder(1)
  lRet := DbSeek(xFilial("GA7") + M->GCX_CODPRO)
  GDFieldPut("GCX_DESPRO", GA7->GA7_DESC)
  If !lRet
   HS_MsgInf(STR0015, STR0010, STR0033) //"Procedimento invalido"###"Atencao"###"Valida็ใo do Campos"
   lRet := .F.
  Else
   nPos := aScan(oGcx:aCols, {| aVet | aVet[nGcx_CODPRO] == M->GCX_CODPRO})
   If nPos > 0 .And. nPos # oGcx:oBrowse:nAt
    HS_MsgInf(STR0016, STR0010, STR0033) //"Procedimento ja cadastrado para este Tipo de Guia"###"Atencao"###"Valida็ใo do Campos"
    lRet := .F.
   EndIf
  Endif 

ElseIf cAlias == "GCU"     
 If ReadVar() == "M->GCU_TGTISS" .AND. !EMPTY(M->GCU_TGTISS)
  If !(lRet := HS_SeekRet("G17", "M->GCU_TGTISS", 1, .F., "GCU_DTGTIS", "G17_DESCRI"))
   HS_MsgInf(STR0036, STR0037, STR0038) //"Tipo de Guia TIIS nใo cadastrada."###"Aten็ใo"###"Valida็ใo dos Campos"
  EndIf
 ElseIf ReadVar() == "M->GCU_TPGUIA" .AND. !EMPTY(M->GCU_TPGUIA)
  If (lTpRet := M->GCU_TPGUIA == "7")
   M->GCU_FATURA := "0"
   M->GCU_MATMED := "0"
   M->GCU_TAXDIA := "0"   
  EndIf
 EndIf 

ElseIf cCampo == "M->GLT_CODMOD"
 If !(lRet := HS_SeekRet("GL5", "M->GLT_CODMOD", 1, .F., "GLT_DESCRI", "GL5_DESCRI"))
  HS_MsgInf(STR0040, STR0010, STR0033) //"C๓digo da modalidade invแlido"###"Atencao"###"Valida็ใo do Campos"
 EndIf
Endif
 
	RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldExcLบ Autor ณ Gilson da Silva    บ Data ณ  21/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Validacao do DELETE de um Tipo de Guia           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldExcL(cCodTpg)
Local lRet := .T.
Local aArea:= GetArea()

If !Inclui .And. !Altera     //Exclusao
 DbSelectArea("GC9")
 DbSetOrder(5)
 If DbSeek(xFilial("GC9") + cCodTpg)
  HS_MsgInf(STR0017, STR0010, STR0034)     //"Tipo de guia utilizado na tabela de controle de guia. Exclusใo nใo permitida"###"Atencao"###"Exclusใo de Tipo de Guia"
  lRet := .F.
 Endif
EndIf 
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGCU บ Autor ณ Gilson da Silva    บ Data ณ  21/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento - GCV, GCX                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGCU(cAlias, nOrd, cChave, aHGrv, aCGrv, nUGrv, nPos)
Local nForACols := 0, lAchou := .F.
Local cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local aArea := GetArea() 
Local lCond   := .F.
 
If ValType(aCGrv[1,nPos])=="C"
 lCond :=  !Empty(aCGrv[1,nPos]) 
ElseIf ValType(aCGrv[1,nPos])=="N"  
 lCond :=   !aCGrv[1,nPos]==0 
ElseIf ValType(aCGrv[1,nPos])=="D"  
 lCond :=   !aCGrv[1,nPos]==CTOD("  /  /  ")
EndIf   	 
 
If len(aCGrv) > 1 .Or. lCond   
 For nForACols := 1 To Len(aCGrv)
	 pForACols := nForACols
	
 	DbSelectArea(cAlias)
	 DbSetOrder(nOrd)
 	lAchou := DbSeek(xFilial(cAlias) + &(cChave))
	 If aCGrv[nForACols, nUGrv + 1] .And. lAchou // exclusao
 		RecLock(cAlias, .F., .T.)
	 	DbDelete()
		 MsUnlock()
 	Else
	 	If !aCGrv[nForACols, nUGrv + 1]
		 	RecLock(cAlias, !lAchou)
			 HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
 			&(cPref + "_FILIAL") := xFilial(cAlias)
	 		&(cPref + "_CODTPG") := M->GCU_CODTPG
		 	
		  MsUnlock()
 		Endif
	 Endif
 Next
EndIf 

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DelGCU บ Autor ณ Gilson da Silva    บ Data ณ  21/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de DELETE dos relacionamentos do Local              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DelGCU(cAlias, nOrd, cChave, aCGrv, nPos)
Local nForDel := 0
Local aArea := GetArea()
Local lCond   := .F.
 
If ValType(aCGrv[1,nPos])=="C"
 lCond :=  !Empty(aCGrv[1,nPos]) 
ElseIf ValType(aCGrv[1,nPos])=="N"  
 lCond :=   !aCGrv[1,nPos]==0 
ElseIf ValType(aCGrv[1,nPos])=="D"  
 lCond :=   !aCGrv[1,nPos]==CTOD("  /  /  ")
EndIf   	 
 
If len(aCGrv) > 1 .Or. lCond   
 For nForDel := 1 To Len(aCGrv)
	 pForACols := nForDel
	
  DbSelectArea(cAlias)
 	DbSetOrder(nOrd)
 	If DbSeek(xFilial(cAlias) + &(cChave))
	 	RecLock(cAlias, .F., .T.)
		 DbDelete()
 		MsUnlock()
	 	WriteSx2(cAlias)
 	Endif
 Next
EndIf
RestArea(aArea)
Return(Nil)                 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TudoOK บ Autor ณ Gilson da Silva    บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verificacao de validade da confirmacao de atualizacao      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_TudoOK(cAlias,oOK,nPos)
 Local lRet 			:= .T. 
 Local lCond   := .F.
 
 If ValType(oOK:aCols[1,nPos])=="C"
  lCond :=  !Empty(oOK:aCols[1,nPos]) 
 ElseIf ValType(oOK:aCols[1,nPos])=="N"  
	 lCond :=   !oOK:aCols[1,nPos]==0 
 ElseIf ValType(oOK:aCols[1,nPos])=="D"  
	 lCond :=   !oOK:aCols[1,nPos]==CTOD("  /  /  ")
	EndIf   	 

 If Len(oOk:aCols) == 1 .And. lCond
  lRet := oOk:TudoOK()
 Endif
Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Busca  บ Autor ณ Gilson da Silva    บ Data ณ  28/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para montar os facilitadores                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Busca(nVem)  
If nVem == 1
	FS_FACPLA()
ElseIf nVem == 2
	FS_FACPRO()
EndIf
Return(Nil)	
       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FACPLA บ Autor ณ Gilson da Silva    บ Data ณ  15/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Facilitador P/incluir Planos na Tabela Tipo Guia X Planos  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_FACPLA()
Local aArea := GetArea()

If Empty(M->GCU_CODTPG)
 HS_MsgInf(STR0022, STR0010, STR0035) //"Por Favor, Informe o Codigo do Tipo de Guia"###"Atencao"###"Facilitador para Inclusใo de Planos na Tabela Tipo Guia X Planos"
Else 
 If Pergunte("HSP99A", .T.)
	 DbSelectArea("GCM") //Cadastro de Planos X Convenios
  DbSetOrder(2)
  DbSeek(xFilial("GCM") + mv_par01,.T.)
  While !Eof() .And. (GCM_CODPLA <= mv_par02) 
  	If GCV->(DbSeek(GCM->GCM_CODPLA))
  	 HS_MsgInf(STR0023, STR0010, STR0035) //"Plano ja cadastrado"###"Atencao"###"Facilitador para Inclusใo de Planos na Tabela Tipo Guia X Planos"
  	 dbSkip()
  	 Loop
  	EndIf
   aCGCV := oGCV:aCols   	
  	If Empty(aCGCV[oGCV:nAt,1])
  		aCGCV[oGCV:nAt,1] := GCM->GCM_CODPLA
   	aCGCV[oGCV:nAt,2] := GCM->GCM_DESPLA
  		aCGCV[oGCV:nAt,3] := .F.
 		ElseIf aScan(aCGCV, {| aVet | aVet[1] == GCM_CODPLA})	== 0 
  		aAdd(aCGCV,{GCM->GCM_CODPLA, GCM->GCM_DESPLA, .F.})
  	EndIf
  		
   dbSkip()
  End 
 EndIf
EndIf 
oGCV:aCols:= aCGCV       
oGCV:Refresh()
RestArea(aArea)
Return(Nil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FACPLA  บ Autor ณ Gilson da Silva    บ Data ณ  15/12/04  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Facilitador P/incluir Planos na Tabela Tipo Guia X Planos  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_FACPRO()
Local aArea := GetArea() 

If Empty(M->GCU_CODTPG)
 HS_MsgInf(STR0022, STR0010, STR0035) //"Por Favor, Informe o Codigo do Tipo de Guia"###"Atencao"###"Facilitador para Inclusใo de Planos na Tabela Tipo Guia X Planos"
Else 
 If Pergunte("HSP99B", .T.)
	 DbSelectArea("GA7") //Cadastro de Procedimentos
  DbSetOrder(1)
  DbSeek(xFilial("GA7") + mv_par01,.T.)
  While !Eof() .And. (GA7->GA7_CODPRO <= mv_par02) 

   If !Empty(GA7->GA7_CODGPP)
    If GA7->GA7_CODGPP < mv_par03 .Or. GA7->GA7_CODGPP > mv_par04 //Consiste Grupo de Procedimento
	    dbSkip()
  	  Loop
  	 EndIf 
   EndIf

  	If !Empty(GA7->GA7_CODGDE)
   	If GA7->GA7_CODGDE < mv_par05 .Or. GA7->GA7_CODGDE > mv_par06 //Consiste Grupo de Despesa
 	   dbSkip()
   	 Loop
   	EndIf 
  	EndIf
 
  	If !Empty(GA7->GA7_CODESP)
    If GA7->GA7_CODESP < mv_par07 .Or. GA7->GA7_CODESP > mv_par08 //Consiste eSPECIALIDADE
 	   dbSkip()
   	 Loop
   	EndIf 
  	EndIf
 
  	If GCX->(DbSeek(GA7->GA7_CODPRO))
  	 HS_MsgInf(STR0024, STR0010, STR0035) //"Procedimento ja cadastrado"###"Atencao"###"Facilitador para Inclusใo de Planos na Tabela Tipo Guia X Planos"
  	 dbSkip()
  	 Loop
  	EndIf 
   aCGCX := oGCX:aCols   	
	 	If Empty(aCGCX[oGCX:nAt,1])
  		aCGCX[oGCX:nAt,1] := GA7->GA7_CODPRO 
  		aCGCX[oGCX:nAt,2] := GA7->GA7_DESC
  		aCGCX[oGCX:nAt,3] := .F.
  	ElseIf aScan(aCGCX, {| aVet | aVet[1] == GA7_CODPRO})	== 0 
	  	aAdd(aCGCX,{GA7->GA7_CODPRO, GA7->GA7_DESC, .F.})
	  EndIf	
   dbSkip()
  End 
 EndIf
EndIf  
oGCX:aCols := aCGCX
oGCX:Refresh()
RestArea(aArea)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 06/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"	, 0, 1, 0, nil},; //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A99"		, 0, 2, 0, nil},; //"Visualizar"
 					 {OemtoAnsi(STR0003), "HS_A99"		, 0, 3, 0, nil},; //"Incluir"
 					 {OemtoAnsi(STR0004), "HS_A99"		, 0, 4, 0, nil},; //"Alterar"
 					 {OemtoAnsi(STR0005), "HS_A99"		, 0, 5, 0, nil}} //"Excluir"
Return(aRotina)
