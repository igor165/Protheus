#INCLUDE "TOPCONN.CH"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPGERAT  บAutor  ณ Eduardo Alves      บ Data ณ  14/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera PRW para atualizador padrao.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs       ณCriado com base no programa desen. por Choite em 11/08/2006 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPGERAT()

Local j									:= 0
Local k									:= 0
Local nQtdIt				:= 0
Local cLinha				:= ""

Local cDirSave 	:= 	PadR("C:\VER811\", 60, " ") //Space(60)
Local cBOP 					:= Space(6)
Local nSx1						:= 0

Local oDirSave, oDlg, oFolder, aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDs := {}, nOpcDlg
Local nGDOpc := GD_INSERT + GD_UPDATE + GD_DELETE

Local oCDX1, aHGDX1 := {}, aCGX1 := {}
Local oCDX2, aHGDX2 := {}, aCGX2 := {}
Local oCDX3, aHGDX3 := {}, aCGX3 := {}
Local oCDX6, aHGDX6 := {}, aCGX6 := {}
Local oCDX7, aHGDX7 := {}, aCGX7 := {}
Local oCDIX, aHGDIX := {}, aCGIX := {}
Local oCDXB, aHGDXB := {}, aCGXB := {}

Private cArq			:= ""


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta aCols para as GetDadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aHGDX1,{"Grupo", "X1_GRUPO", "@!",	6, 0, "HS_VldGET('SX1', PADR(M->X1_GRUPO, Len(SX1->X1_GRUPO)))", /* Usado */, "C", /* F3 */, "R",,,, "A"})
aAdd(aHGDX2,{"Chave", "X2_CHAVE", "@!",	3, 0, "HS_VldGET('SX2', M->X2_CHAVE)", /* Usado */, "C", /* F3 */, "R",,,, "A"})
aAdd(aHGDX3,{"Arquivo", "X3_ARQUIVO", "@!",	3, 0, "HS_VldGET('SX3', M->X3_ARQUIVO)", /* Usado */, "C", /* F3 */, "R",,,, "A"})

aAdd(aHGDX6,{"Filial", "X6_FILIAL", "@!",	2, 0, "HS_VldGET('SX6', M->X6_FILIAL)", /* Usado */, "C", /* F3 */, "R",,,, "A"})
aAdd(aHGDX6,{"Variavel", "X6_VAR", "@!",	10, 0, "HS_VldGET('SX6', oGDX6:aCols[oGDX6:oBrowse:nAt, 1] + M->X6_VAR)", /* Usado */, "C", /* F3 */, "R",,,, "A"})

aAdd(aHGDX7,{"Campo", "X7_CAMPO", "@!",	10, 0, "HS_VldGET('SX7', M->X7_CAMPO)", /* Usado */, "C", /* F3 */, "R",,,, "A"})
aAdd(aHGDIX,{"Indice", "IX_INDICE", "@!",	3, 0, "HS_VldGET('SIX', M->IX_INDICE)", /* Usado */, "C", /* F3 */, "R",,,, "A"})
aAdd(aHGDXB,{"Alias", "XB_ALIAS", "@!",	6, 0, "HS_VldGET('SXB', M->XB_ALIAS)", /* Usado */, "C", /* F3 */, "R",,,, "A"})

aSize 			:= MsAdvSize(.T.)
aObjects := {}	
aAdd( aObjects, { 100, 045, .T., .T. } )	
aAdd( aObjects, { 100, 055, .T., .T.,.T. } )	
 
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}	
AAdd( aObjects, { 100, 100, .T., .T. } )	
 
aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGDs := MsObjSize( aInfo, aObjects, .T. )   
 
DEFINE MSDIALOG oDlg TITLE "Atualizador Padrใo" From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd

		@ aPObjs[1,1] + 10, 005 SAY OemtoAnsi("Path: ") OF oDlg PIXEL COLOR CLR_BLUE
  @ aPObjs[1,1] + 10, 032 MSGET oDirSave VAR cDirSave PICTURE "@!" SIZE 150,04              	OF oDlg PIXEL COLOR CLR_BLUE
  @ aPObjs[1,1] + 10, 182 BUTTON oBtn1 PROMPT "..." SIZE 10,10 ACTION FS_RetDir(@cDirSave)  	OF oDlg PIXEL 

		@ aPObjs[1,1] + 25, 005 SAY OemtoAnsi("Nบ Bops: ") OF oDlg PIXEL COLOR CLR_BLUE
		@ aPObjs[1,1] + 25, 032 MSGET oNumBop 	VAR cBOP 	PICTURE "999999" 		SIZE 010,04 OF oDlg PIXEL COLOR CLR_BLACK
 
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts "SX1", "SX2", "SX3", "SX6", "SX7", "SIX", "SXB"
  oFolder:Align := CONTROL_ALIGN_BOTTOM

  oGDX1 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[1], aHGDX1, aCGX1)
  oGDX1:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  oGDX2 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[2], aHGDX2, aCGX2)
  oGDX2:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  oGDX3 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[3], aHGDX3, aCGX3)
  oGDX3:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  oGDX6 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[4], aHGDX6, aCGX6)
  oGDX6:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  oGDX7 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[5], aHGDX7, aCGX7)
  oGDX7:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  oGDIX := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[6], aHGDIX, aCGIX)
  oGDIX:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  oGDXB := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[7], aHGDXB, aCGXB)
  oGDXB:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcDlg := 1, oDlg:End()}, ;
                                                     {|| nOpcDlg := 0, oDlg:End()})


If (nOpcDlg == 0)
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso nenhum folder tenha sido preenchido, finaliza o programaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(oGDX1:aCols[1,1]) .And. Empty(oGDX2:aCols[1,1]) .And. Empty(oGDX3:aCols[1,1]) .And. Empty(oGDX6:aCols[1,2]) .And. Empty(oGDX7:aCols[1,1]) .And. Empty(oGDIX:aCols[1,1]) .And. Empty(oGDXB:aCols[1,1])
	MsgAlert("O fonte nใo serแ gerado, pois nใo foi preenchida nenhuma pasta.", "Aten็ใo")
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNome do arquivo fonte a ser geradoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cBOP	:= "GH" + allTrim(cBOP)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria arquivo fonte no local especificado pelo usuarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cArq	:= fcreate(allTrim(cDirSave) + cBOP + ".PRW")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFuncao PRINCIPAL que chama as funcoes de geracao de dicionariosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GravaLin('#INCLUDE "protheus.ch"')
GravaLin("")
GravaLin("/*/")
GravaLin("ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ")
GravaLin("ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ")
GravaLin("ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤ-ฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ")
GravaLin("ฑฑณFunao    ณ"+PADR(cBOP,10)	 +"ณ Autor ณ MICROSIGA             ณ Data ณ " + DTOC(DDATABASE) + " ณฑฑ")
GravaLin("ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤ-มฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ")
GravaLin("ฑฑณDescriao ณ Funcao Principal                                           ณฑฑ")
GravaLin("ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤ-ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ")
GravaLin("ฑฑณUso       ณ Gestao Hospitalar                                          ณฑฑ")
GravaLin("ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤ-ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ")
GravaLin("ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ")
GravaLin("฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿")
GravaLin("/*/")
GravaLin("Function " + cBOP + "()")
GravaLin("")
GravaLin('cArqEmp 					:= "SigaMat.Emp"')
GravaLin('__cInterNet 	:= Nil')
GravaLin("")
GravaLin('PRIVATE cMessage')
GravaLin('PRIVATE aArqUpd	 := {}')
GravaLin('PRIVATE aREOPEN	 := {}')
GravaLin('PRIVATE oMainWnd ')
GravaLin("Private nModulo 	:= 51 // modulo SIGAHSP")
GravaLin("")
GravaLin('Set Dele On')
GravaLin("")
GravaLin('lEmpenho				:= .F.')
GravaLin('lAtuMnu					:= .F.')
GravaLin("")
GravaLin('Processa({|| ProcATU()},"Processando [' + cBOP + ']","Aguarde , processando prepara็ใo dos arquivos")')
GravaLin("")
GravaLin('Return()')
GravaLin('')
GravaLin('')
GravaLin('/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ')
GravaLin('ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ')
GravaLin('ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ')
GravaLin('ฑฑณFun…o    ณProcATU   ณ Autor ณ                       ณ Data ณ  /  /    ณฑฑ')
GravaLin('ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ')
GravaLin('ฑฑณDescri…o ณ Funcao de processamento da gravacao dos arquivos           ณฑฑ')
GravaLin('ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ')
GravaLin('ฑฑณ Uso      ณ Baseado na funcao criada por Eduardo Riera em 01/02/2002   ณฑฑ')
GravaLin('ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ')
GravaLin('ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ')
GravaLin('฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/')
GravaLin('Static Function ProcATU()')
GravaLin('Local cTexto    	:= ""')
GravaLin('Local cFile     	:= ""')
GravaLin('Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"')
GravaLin('Local nRecno    	:= 0')
GravaLin('Local nI        	:= 0')
GravaLin('Local nX        	:= 0')
GravaLin('Local aRecnoSM0 	:= {} ')    
GravaLin('Local lOpen     	:= .F. ')
GravaLin('')
GravaLin('ProcRegua(1)')
GravaLin('IncProc("Verificando integridade dos dicionแrios....")')
GravaLin('If (lOpen := IIF(Alias() <> "SM0", MyOpenSm0Ex(), .T. ))')
GravaLin('')
GravaLin('	dbSelectArea("SM0")')
GravaLin('	dbGotop()')
GravaLin('	While !Eof() ')
GravaLin('  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0')
GravaLin('			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})')
GravaLin('		EndIf			')
GravaLin('		dbSkip()')
GravaLin('	EndDo	')
GravaLin('')
GravaLin('	If lOpen')
GravaLin('		For nI := 1 To Len(aRecnoSM0)')
GravaLin('			SM0->(dbGoto(aRecnoSM0[nI,1]))')
GravaLin('			RpcSetType(2) ')
GravaLin('			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)')
GravaLin(' 		nModulo := 51 // modulo SIGAHSP')
GravaLin('			lMsFinalAuto := .F.')
GravaLin('			cTexto += Replicate("-",128)+CHR(13)+CHR(10)')
GravaLin('			cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)')
GravaLin("")
GravaLin('			ProcRegua(8)')
GravaLin("")
GravaLin('			Begin Transaction')
GravaLin("")
GravaLin('			conout( "Fun็๕es descontinuadas pelo SGBD: GeraSX1(),GeraSX2(),GeraSX3(),GeraSX6(),GeraSX7(),GeraSIX() e GeraSXB()" )')
GravaLin('	')
GravaLin('			__SetX31Mode(.F.)')
GravaLin('			For nX := 1 To Len(aArqUpd)')
GravaLin('				IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")')
GravaLin('				If Select(aArqUpd[nx])>0')
GravaLin('					dbSelecTArea(aArqUpd[nx])')
GravaLin('					dbCloseArea()')
GravaLin('				EndIf')
GravaLin('				X31UpdTable(aArqUpd[nx])')
GravaLin('				If __GetX31Error()')
GravaLin('					Alert(__GetX31Trace())')
GravaLin('					Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)')
GravaLin('					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)')
GravaLin('				EndIf')
GravaLin('				dbSelectArea(aArqUpd[nx])')
GravaLin('			Next nX		')
GravaLin('')
GravaLin('			RpcClearEnv()')
GravaLin('			If !( lOpen := MyOpenSm0Ex() )')
GravaLin('				Exit ')
GravaLin('		 EndIf')
GravaLin('		Next nI ')
GravaLin('		   ')
GravaLin('		If lOpen')
GravaLin('			')
GravaLin('			cTexto 				:= "Log da atualizacao " + CHR(13) + CHR(10) + cTexto')
GravaLin('			__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)')
GravaLin('			')
GravaLin('			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12')
GravaLin('			DEFINE MSDIALOG oDlg TITLE "Atualizador [' + cBOP + '] - Atualizacao concluida." From 3,0 to 340,417 PIXEL')
GravaLin('				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL')
GravaLin('				oMemo:bRClicked := {||AllwaysTrue()}')
GravaLin('				oMemo:oFont:=oFont')
GravaLin('				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga')
GravaLin('				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."')
GravaLin('			ACTIVATE MSDIALOG oDlg CENTER')
GravaLin('	')
GravaLin('		EndIf ')
GravaLin('		')
GravaLin('	EndIf')
GravaLin('		')
GravaLin('EndIf 	')
GravaLin('')
GravaLin('Return(Nil)')

GravaLin("")
GravaLin("")

GravaLin('/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ')
GravaLin('ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ')
GravaLin('ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ')
GravaLin('ฑฑณFun…o    ณMyOpenSM0Exณ Autor ณSergio Silveira       ณ Data ณ07/01/2003ณฑฑ')
GravaLin('ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ')
GravaLin('ฑฑณDescri…o ณ Efetua a abertura do SM0 exclusivo                         ณฑฑ')
GravaLin('ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ')
GravaLin('ฑฑณ Uso      ณ Atualizacao FIS                                            ณฑฑ')
GravaLin('ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ')
GravaLin('ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ')
GravaLin('฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/')
GravaLin('Static Function MyOpenSM0Ex()')
GravaLin("")
GravaLin('Local lOpen := .F. ')
GravaLin('Local nLoop := 0 ')
GravaLin("")
GravaLin('For nLoop := 1 To 20')
GravaLin('	openSM0( cNumEmp,.F. ) ')
GravaLin('	If !Empty( Select( "SM0" ) ) ')
GravaLin('		lOpen := .T. ')
GravaLin('		dbSetIndex("SIGAMAT.IND") ')
GravaLin('		Exit	')
GravaLin('	EndIf')
GravaLin('	Sleep( 500 )') 
GravaLin('Next nLoop ')
GravaLin("")
GravaLin('If !lOpen')
GravaLin('	Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) ')
GravaLin('EndIf                                 ')
GravaLin("")
GravaLin('Return( lOpen )')

GravaLin("")
GravaLin("")

GravaLin("")
GravaLin("")

FS_GeraFN("SX2",, FS_CriaVet(oGDX2))      
FS_GeraFN("SX3",, FS_CriaVet(oGDX3))      
FS_GeraFN("SX6","X6_FIL+X6_VAR", FS_CriaVet(oGDX6))      
FS_GeraFN("SX7",, FS_CriaVet(oGDX7))      
FS_GeraFN("SIX",, FS_CriaVet(oGDIX))      
FS_GeraFN("SXB",, FS_CriaVet(oGDXB))      

fClose(cArq)

MsgAlert("Processamento concluํdo, criado como " + allTrim(cDirSave) + cBOP + ".PRW", "Sucesso")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GeraFN บAutor  ณEduardo Alves       บ Data ณ  15/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria funcao para os dicionarios:                            บฑฑ
ฑฑบ          ณSX2 SX3 SX6 SX7 SIX SXB                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GeraFN(cAlias, cWhere, aSx)
Local aArea 				:= GetArea()
Local j 								:= 0
Local nSx 						:= 0
Local cLinha				:= ""
Local aTemp					:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se os parametros passados existem											ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias)
dbSetOrder(1)

For nSx := 1 To Len(aSx)
	If DbSeek(aSx[nSx])
		aAdd(aTemp, aSx[nSx])
	EndIf
Next nSx

aSx := aClone(aTemp)

If Len(aSx) == 0
	Return()
EndIf

Default cWhere := IIf( AT("+", IndexKey()) > 0 , SubStr(IndexKey(), 1, AT("+", IndexKey()) - 1), IndexKey())

GravaLin("/*/")
GravaLin("ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ")
GravaLin("ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ")
GravaLin("ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ")
GravaLin("ฑฑณFunao    ณ Gera"+cAlias+"  ณ Autor ณ MICROSIGA             ณ Data ณ   /  /   ณฑฑ")
GravaLin("ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ")
GravaLin("ฑฑณDescriao ณ Funcao generica para copia de dicionarios                  ณฑฑ")
GravaLin("ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ")
GravaLin("ฑฑณUso       ณ Generico                                                   ณฑฑ")
GravaLin("ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ")
GravaLin("ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ")
GravaLin("฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿")
GravaLin("/*/")
GravaLin("Static Function Gera" + cAlias + "()")
GravaLin("Local aArea 			:= GetArea()")
GravaLin("Local i      		:= 0")
GravaLin("Local j      		:= 0")
GravaLin("Local aRegs  		:= {}")
GravaLin("Local cTexto 		:= ''")
GravaLin("Local lInclui		:= .F.")

GravaLin("")

For nSx := 1 To Len(aSx)

	DbSeek(aSx[nSx])
	
	GravaLin("aRegs  := {}")
	
	While !Eof() .And. &(cWhere) == aSx[nSx]
		GravaLin(FS_Linha(1, FCount(), cAlias))
		DbSkip()
	EndDo
	
	GravaLin("")
	GravaLin('dbSelectArea("' + cAlias + '")')
	GravaLin("dbSetOrder(1)")
 GravaLin("")
	GravaLin("For i := 1 To Len(aRegs)")
 GravaLin("")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSX2                                           							ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If 					cAlias == "SX2"
		GravaLin(" dbSetOrder(1)")
		GravaLin(" lInclui := !DbSeek(aRegs[i, 1])")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSX3                                           							ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ElseIf 	cAlias == "SX3"
		GravaLin(' If(Ascan(aArqUpd, aRegs[i,1]) == 0)')
		GravaLin(' 	aAdd(aArqUpd, aRegs[i,1])')
		GravaLin(' EndIf')
		GravaLin('')
		GravaLin(" dbSetOrder(2)")
		GravaLin(" lInclui := !DbSeek(aRegs[i, 3])")
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSX6                                           							ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ElseIf cAlias == "SX6"
		GravaLin(' cTexto += IIf( aRegs[i,1] + aRegs[i,2] $ cTexto, "", aRegs[i,1] + aRegs[i,2] + "\")')
		GravaLin('')
		GravaLin(" dbSetOrder(1)")
		GravaLin(" lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2])")
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSX7                                           							ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ElseIf cAlias == "SX7"
		GravaLin(" dbSetOrder(1)")
		GravaLin(" lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2])")
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSIX                                           							ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ElseIf cAlias $ "SIX"
		GravaLin(' If(Ascan(aArqUpd, aRegs[i,1]) == 0)')
		GravaLin(' 	aAdd(aArqUpd, aRegs[i,1])')
		GravaLin(' EndIf')
		GravaLin('')
		GravaLin(" dbSetOrder(1)")
		GravaLin(" lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2])")
		GravaLin(" If !lInclui")
		GravaLin('  TcInternal(60,RetSqlName(aRegs[i, 1]) + "|" + RetSqlName(aRegs[i, 1]) + aRegs[i, 2])')
		GravaLin(" Endif")
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSXB                                           							ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ElseIf cAlias == "SXB"
		GravaLin(" dbSetOrder(1)")
		GravaLin(" lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2] + aRegs[i, 3] + aRegs[i, 4])")
	EndIF
	
	GravaLin('')
	GravaLin(' cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")')
	GravaLin('')
	GravaLin(' RecLock("'+ cAlias +'", lInclui)')
	GravaLin("  For j := 1 to FCount()")
	GravaLin("   If j <= Len(aRegs[i])") 
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAntes de gravar o campo - Alterar o conteudo do campoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 GravaLin('   	If allTrim(Field(j)) == "X2_ARQUIVO"')
 GravaLin('   		aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"')
 GravaLin('   	EndIf')

	GravaLin('    If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"')
	GravaLin("     Loop")
	GravaLin("    Else")
	GravaLin("     FieldPut(j,aRegs[i,j])")
	GravaLin("    EndIf")

	GravaLin("   Endif")
	GravaLin("  Next")
	GravaLin(" MsUnlock()")
	GravaLin("Next i")
	GravaLin("")

Next nSx

GravaLin("")
GravaLin("RestArea(aArea)")
GravaLin("Return('" + cAlias + " : ' + " + "cTexto  + CHR(13) + CHR(10))")

RestArea(aArea)
Return(cLinha)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaLin  บAutor  ณEduardo Alves       บ Data ณ  15/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que inclui linha no arquivo PRW.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs       ณCriado com base no programa desen. por Choite em 11/08/2006 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaLin(cConteudo)
	FWrite(cArq,Rtrim(cConteudo) + chr(13) + chr(10) )
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldGET บAutor  ณEduardo Alves       บ Data ณ  09/15/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao dos campos da getdados.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldGET(cDic, cChave)
Local aArea 	:= GetArea()
Local lRet			:= .T.

dbSelectArea(cDic)
dbSetOrder(1)
If !(lRet := dbSeek(cChave))
	MsgAlert("Chave informada nใo encontrada no dicionแrio " + cDic, "Aten็ใo")
EndIf

RestArea(aArea)
Return(lRet)    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CriaVetบAutor  ณEduardo Alves       บ Data ณ  09/15/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria vetor com do dados informados nos grids.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CriaVet(oGD)

Local nLinGD := 0, nColGD := 0

Local aTemp := {}
Local cCont := ""

If Len(oGD:aCols) > 0
	For nLinGD := 1 To Len(oGD:aCols)
		For nColGD := 1 To Len(oGD:aHeader)
	 	cCont += oGD:aCols[nLinGD][nColGD]
		Next nCol
		aAdd(aTemp, cCont)
		cCont := ""
	Next nLCol
EndIf

Return(aTemp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Linha  บAutor  ณEduardo Alves       บ Data ณ  09/15/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria a linha do vetor com dados dos dicionarios.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Linha(nCpoINI, nTotCPO, cAlias)
Local cLinha 	:= ""
Local j 						:= 0

cLinha := "AADD(aRegs,{" + IIF(nCpoINI == 2,"cPerg,","")

For j := nCpoINI to nTotCPO
	cCont  := FieldGet(j)
	IF ValType("cCont") == "N"
		cLinha += StrZero(cCont, 2)
	ELSE
		If cCont == ""
			cCont := Space(Len(cCont))
		EndIf
		cLinha += '"' + StrTran(cCont, '"', "'") + '"'
	ENDIF
	IF (j # nTotCPO)
		cLinha += ','
	ENDIF
Next nTotCPO

If cAlias == "SX3"
 cLinha += ',"N","N","N"'
Endif

cLinha += "})"

Return(cLinha)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RetDir บAutor  |Eduardo Alves       บ Data ณ  18/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe locais onde pode ser salvo o fonte gerado.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs       ณBaseado na funcao criada na HSPDATU.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_RetDir(cDir, cDescr)
 cDir := PADR(cGetFile(OemToAnsi(cDescr) + " | ",OemToAnsi("Selecione Diret๓rio"),,"",.F.,GETF_RETDIRECTORY), Len(cDir))
Return(.T.)
