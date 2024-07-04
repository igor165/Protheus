
#include "PLSMGER.CH"
#include "PLSMLIB.CH"

#IFDEF TOP
       #include "TOPCONN.CH"
#ENDIF       

#include "PROTHEUS.CH"
#include "COLORS.CH"

#define ANTES_LACO 		1
#define COND_LACO 		2
#define PROC_LACO 		3
#define DEPOIS_LACO 	4

#Define C_ALIAS 		1 //X3_ALIAS
#Define C_CAMPO 		2 //X3_CAMPO
#Define C_TIPO 			3 //X3_TIPO
#Define C_TAMANHO 		4 //X3_TAMANHO
#Define C_SUB 			5 //lSub
#Define C_TITLE 		6 //X3Title()
#Define C_PICTURE 		7 //X3_PICTURE
#Define C_CAB 			8 //lCab
#Define C_CBOX 			9 //CBOX

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PLSA086    ณ Autor ณ Paulo Carnelossi   ณ Data ณ 09/02/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Autorizacoes Negadas POS                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ PLSA086()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PLSA086                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/              
Function PLSA086()

Local aCores := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis PRIVATE...                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aRotina   := MenuDef()
PRIVATE cTitulo		:= "Autorizacoes Negadas POS"
PRIVATE cAlias    := "BXE"

PLSA086Fil("BXE", BXE->(Recno()),K_Visualizar)

BXE->(dbSetorder(1))
BXE->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias,,,,,,aCores,,,,, .T. ))
BXE->(DbClearFilter())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fim da Rotina Principal...                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PLSA086Con ณ Autor ณ Paulo Carnelossi   ณ Data ณ 09/02/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Visualizacao Autorizacoes Negadas POS                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ PLSA086Con(cAlias,nReg,nOpc)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PLSA086                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSA086Con(cAlias,nReg,nOpc)
Local I__f := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis da EnchoiceBar...                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
LOCAL bOK     := {|| nOpca := 1, oDialog:End()}
LOCAL bCancel := {|| nOpca := 2, oDialog:End()}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Controle de lock de registro...                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
LOCAL oEncBXE
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis genericas...                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE oDialog
PRIVATE nOpcx        := nOpc
PRIVATE nOpca        := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                        ...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aCabBXF  := {}
PRIVATE aDadBXF  := {}
PRIVATE aTrbBXF  := {}
PRIVATE oBrwBXF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                        ...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aCabBXG  := {}
PRIVATE aDadBXG  := {}
PRIVATE aTrbBXG  := {}
PRIVATE oBrwBXG

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis da enchoice...                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE n
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis para controle de Forma de Cobranca ...             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aSTela  := {}            

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta M->??? para enchoice...                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == K_Incluir
   Copy cAlias To Memory Blank
Else
   Copy cAlias TO MEMORY                                           
EndIf                      

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define dialogo...                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetEnch("") 
DEFINE MSDIALOG oDialog TITLE cTitulo FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Enchoice...                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Zero()
oEncBXE := MsMGet():New(cAlias,nReg,nOpc,,,,,{030,001,090,355},,,,,,oDialog,,,.F.)

@ 091,001 FOLDER oFolder SIZE 355,110 OF oDialog PIXEL PROMPTS  "Procedimentos",;
                                                                 "Informacoes da Critica"
//-------------------------------------//
Store Header "BXF" TO aCabBXF For .T.

BXF->(DbSetOrder(1))
If BXF->(MsSeek(xFilial("BXF")+BXE->BXE_CODSEQ))
	Store COLS "BXF" TO aDadBXF FROM aCabBXF VETTRAB aTrbBXF While BXF->BXF_FILIAL+BXF->BXF_CODSEQ == xFilial("BXF")+BXE->BXE_CODSEQ
EndIf

If Len(aDadBXF) == 0
	Store COLS Blank "BXF" TO aDadBXF FROM aCabBXF
	@ 005, 006 Say oSayFin PROMPT "Nao ha Registros" SIZE 150, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
Else
	oBrwBXF := TPLSBrw():New(001,002,353,090 ,nil  ,oFolder:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBXF   ,aDadBXF ,.F.      ,"BXF" ,nOpcx,"Procedimentos",nil,nil,nil,aTrbBXF,,,)
Endif
      
//------------------------------------------------------//
Store Header "BXG" TO aCabBXG For .T.

BXG->(DbSetOrder(1))
If BXG->(MsSeek(xFilial("BXG")+BXE->BXE_CODSEQ))
	Store COLS "BXG" TO aDadBXG FROM aCabBXG VETTRAB aTrbBXG While BXG->BXG_FILIAL+BXG->BXG_CODSEQ == xFilial("BXG")+BXE->BXE_CODSEQ
EndIf

If Len(aDadBXG) == 0
	Store COLS Blank "BXG" TO aDadBXG FROM aCabBXG
	@ 005, 006 Say oSayFin PROMPT "Nao ha Registros" SIZE 150, 006 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE
Else
	oBrwBXG := TPLSBrw():New(001,002,353,090 ,nil  ,oFolder:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBXG   ,aDadBXG ,.F.      ,"BXG" ,nOpcx,"Informacoes da Critica",nil,nil,nil,aTrbBXG,,,)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ativa o dialogo...                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog,bOK,bCancel,.F.,{})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fim da Rotina Principal...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PLSA086Fil ณ Autor ณ Paulo Carnelossi   ณ Data ณ 09/02/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Filtro Autorizacoes Negadas POS                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ PLSA086Fil(cAlias,nReg,nOpc)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PLSA086                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSA086Fil(cAlias,nReg,nOpc)

Local i, cTpGrv


Pergunte("PLS086", .T.)
              
cTpGrv := "' '"
For i := 1 To Len(mv_par19)
    cTpGrv += ",'" + SubStr(mv_par19, i, 1) + "'"
Next i

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Chama funcao de Browse...                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

#IFDEF TOP
PRIVATE cFil := "@BXE_FILIAL = '"+xFilial("BXE")+"' AND BXE_MATRIC >= '"+MV_PAR01+"' "+;
				" AND BXE_MATRIC <= '"+MV_PAR02+"' AND BXE_DATPRO >= '"+DTOS(mv_par03)+"' "+;
        		" AND BXE_DATPRO  <= '"+DTOS(mv_par04)+"' AND BXE_OPEMOV >= '"+mv_par05+"' "+;
        		" AND BXE_OPEMOV  <= '"+mv_par06+"' AND BXE_CIDPRI >= '"+mv_par07+"' "+;
        		" AND BXE_CIDPRI  <= '"+mv_par08+"' AND BXE_CODRDA >= '"+mv_par09+"' "+;
        		" AND BXE_CODRDA  <= '"+mv_par10+"' AND BXE_CDPFSO >= '"+mv_par11+"' "+; 
        		" AND BXE_CDPFSO  <= '"+mv_par12+"' AND BXE_CODESP >= '"+mv_par13+"' "+; 
        		" AND BXE_CODESP  <= '"+mv_par14+"' AND BXE_HORAPR >= '"+mv_par15+"' "+; 
        		" AND BXE_HORAPR  <= '"+mv_par16+"' AND BXE_NUMTER >= '"+mv_par17+"' "+; 
        		" AND BXE_NUMTER  <= '"+mv_par18+"' AND BXE_TPGRV  IN ("+cTpGrv+") "+; 
				" AND D_E_L_E_T_ <>  '*'"
#ELSE                
PRIVATE cFil := "@BXE_FILIAL = '"+xFilial("BXE")+"' .AND. BXE_MATRIC >= '"+MV_PAR01+"' "+;
				" .AND. BXE_MATRIC <= '"+MV_PAR02+"' .AND. DTOS(BXE_DATPRO) >= '"+DTOS(mv_par03)+"' "+;
        		" .AND. DTOS(BXE_DATPRO)  <= '"+DTOS(mv_par04)+"' .AND. BXE_OPEMOV >= '"+mv_par05+"' "+;
        		" .AND. BXE_OPEMOV  <= '"+mv_par06+"' .AND. BXE_CIDPRI >= '"+mv_par07+"' "+;
        		" .AND. BXE_CIDPRI  <= '"+mv_par08+"' .AND. BXE_CODRDA >= '"+mv_par09+"' "+;
        		" .AND. BXE_CODRDA  <= '"+mv_par10+"' .AND. BXE_CDPFSO >= '"+mv_par11+"' "+; 
        		" .AND. BXE_CDPFSO  <= '"+mv_par12+"' .AND. BXE_CODESP >= '"+mv_par13+"' "+; 
        		" .AND. BXE_CODESP  <= '"+mv_par14+"' .AND. BXE_HORAPR >= '"+mv_par15+"' "+; 
        		" .AND. BXE_HORAPR  <= '"+mv_par16+"' .AND. BXE_NUMTER >= '"+mv_par17+"' "+; 
        		" .AND. BXE_NUMTER  <= '"+mv_par18+"' .AND. BXE_TPGRV  $ "+cTpGrv+" "+; 
				" .AND. D_E_L_E_T_ <>  '*'"
#ENDIF


BXE->(DbSetOrder(1))   
DbSelectArea("BXE")
SET FILTER TO &cFil
BXE->(MsSeek(xFilial("BXE")))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PLSA086Rem ณ Autor ณ Paulo Carnelossi   ณ Data ณ 09/02/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Remove Filtro Autorizacoes Negadas POS                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ PLSA086Rem(cAlias,nReg,nOpc)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PLSA086                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSA086Rem(cAlias,nReg,nOpc)

BXE->(DbClearFilter())
BXE->(MsSeek(xFilial("BXE")))

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA086Imp บAutor  ณPaulo Carnelossi   บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relacao de Autor.Negadas POS                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA086Imp()
PLSR086()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR086    บAutor  ณPaulo Carnelossi   บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relacao de Autor.Negadas POS                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR086()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao de Autor.Negadas POS"
Local cDesc2 := ""
Local cDesc3 := ""
Local cString := "BXE"

Local aOrd := {}

PRIVATE cTitulo	:= "Relatorio de Autorizacoes Negadas POS"
PRIVATE cabec1	:=""
PRIVATE cabec2	:=""
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := ""
Private nomeprog:= "PLSR086" 
Private nLastKey:=0
Private Tamanho := "G"
Private nTipo

//        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLR086"

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)

cPerg   := "PLS086"
Pergunte(cPerg,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| PLSR086Imp(@lEnd,wnRel,cString)},cTitulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR086Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 09/01/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณRelacao de Autorizacoes Negadas POS                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR086Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR086Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt

LOCAL cSQL
Local aCondFinal
Local aCpos, aAuxCab, nZ
Local cCabBXE1, cCabBXE2, cCabBXF1, cCabBXF2,  cCabBXG1, cCabBXG2

Local aExcCpo := {}
Local aExcTam := { 	{"BXG_DESCRI", 60},;
					{"BXG_INFO", 60}}
Local aCabec  := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCpos  := Cpos_PLSR086()

aAuxCab := Linha_Cabec("BXE", aCpos, aExcTam)  
cCabBXE1 := aAuxCab[1]
cCabBXE2 := aAuxCab[2]

aAdd(aCabec, {"BXE", cCabBXE1, cCabBXE2})

aAuxCab  := Linha_Cabec("BXF", aCpos, aExcTam)  
cCabBXF1 := aAuxCab[1]
cCabBXF2 := aAuxCab[2]

aAdd(aCabec, {"BXF", cCabBXF1, cCabBXF2})

aAuxCab  := Linha_Cabec("BXG", aCpos, aExcTam)  
cCabBXG1 := aAuxCab[1]
cCabBXG2 := aAuxCab[2]

aAdd(aCabec, {"BXG", cCabBXG1, cCabBXG2})

dbSelectArea("BXE")
dbSelectArea("BXF")
dbSelectArea("BXG")

//monta array contendo blocos de codigos que serao executados 
// antes while - cond. while - processamento while - apos while      

// Elemento 1 - ANTES_LACO
// Elemento 2 - COND_LACO
// Elemento 3 - PROC_LACO
// Elemento 4 - DEPOIS_LACO
// Elemento 5 - Variavel para comparacao
// Elemento 6 - Contador
// Elemento 7 - Nome do Campo
// Elemento 8 - Titulo do Campo
aCondFinal := {}

//Quebra enquanto nao fim de Arquivo  -----> BXE_FILIAL
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := ""}, ;
	   		{|nNivel|!Eof()}, ;
		   	{|nNivel|Impr_Detalhe(aCabec, aCpos)}, ;
		   	{|nNivel|.T.}, ;
	   		Nil,;
		   	0, ;
		   	"BXE_FILIAL",;  //pode ser qq campo
		   	" ";
	   } )

SetRegua(RecCount())

// Impressao do detalhe do relatorio com quebra
DetalheRel(aCondFinal, 1, "BXE")

Roda(cbcont,cbtxt,tamanho)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("BXE")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Detalhe บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do relatorio                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_Detalhe(aCabec, aCpos)
Local nCol := 000, nX
Local cCabBXE1, cCabBXE2

For nX := 1 TO Len(aCabec)
	If aCabec[nX][1] == "BXE"
		cCabBXE1 := aCabec[nX][2]
		cCabBXE2 := aCabec[nX][3]
        Exit
  	EndIf
Next

If li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	@ li, nCol PSay cCabBXE1
	li++
	If ! Empty(cCabBXE2)
		@ li, nCol PSay cCabBXE2
		li++
	EndIf
	@ li, nCol PSay Replicate("-", 220-nCol)
	li++
EndIf


Impr_Linha("BXE", aCpos, nCol)

ImprimeBXF(aCpos, aCabec)

ImprimeBXG(aCpos, aCabec)
li++

dbSelectArea("BXE")

BXE->(DbSkip())

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeBXF   บAutor  ณPaulo Carnelossi บ Data ณ  09/02/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do alias BXF                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImprimeBXF(aCpos, aCabec)
Local nCol := 015, nX
Local cAlias := Alias()
Local cCabBXF1, cCabBXF2, lCab := .T.

For nX := 1 TO Len(aCabec)
	If aCabec[nX][1] == "BXF"
		cCabBXF1 := aCabec[nX][2]
		cCabBXF2 := aCabec[nX][3]
        Exit
  	EndIf
Next

BXF->(DbSetOrder(1))
If BXF->(MsSeek(xFilial("BXF")+BXE->BXE_CODSEQ))
	While BXF->(!Eof() .And. BXF->BXF_FILIAL+BXF->BXF_CODSEQ == xFilial("BXF")+BXE->BXE_CODSEQ)
		If li > 55
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)	
			lCab := .T.
		EndIf
	  
		If lCab
			li++
			@ li, nCol PSay cCabBXF1
			li++
			If ! Empty(cCabBXF2)
				@ li, nCol PSay cCabBXF2
				li++
			EndIf
			@ li, nCol PSay Replicate("-", 220-nCol)
			li++
			lCab := .F.
		EndIf
		
		Impr_Linha("BXF", aCpos, nCol)
	
		BXF->(dbSkip())
	End
EndIf

dbSelectArea(cAlias)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeBXG   บAutor  ณPaulo Carnelossi บ Data ณ  09/02/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do alias BXG                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImprimeBXG(aCpos, aCabec)
Local nCol := 025, nX
Local cAlias := Alias()
Local cCabBXG1, cCabBXG2, lCab := .T.

For nX := 1 TO Len(aCabec)
	If aCabec[nX][1] == "BXG"
		cCabBXG1 := aCabec[nX][2]
		cCabBXG2 := aCabec[nX][3]
        Exit
  	EndIf
Next

BXG->(DbSetOrder(1))
If BXG->(MsSeek(xFilial("BXG")+BXE->BXE_CODSEQ))
	While BXG->(! Eof() .And. BXG->BXG_FILIAL+BXG->BXG_CODSEQ == xFilial("BXG")+BXE->BXE_CODSEQ)
	
		If li > 55
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			lCab := .T.
		EndIf
		
		If lCab
			li++
			@ li, nCol PSay cCabBXG1
			li++
			If ! Empty(cCabBXG2)
				@ li, nCol PSay cCabBXG2
				li++
			EndIf
			@ li, nCol PSay Replicate("-", 220-nCol)
			li++
			lCab := .F.
		EndIf
		
		Impr_Linha("BXG", aCpos, nCol, , .T.)

		BXG->(dbSkip())

	End
EndIf


dbSelectArea(cAlias)

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCpos_PLSR086 บAutor  ณPaulo Carnelossi   บ Data ณ 09/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Monta array com campos a serem impresso no                 บฑฑ
ฑฑบDesc.     ณ relatorio Autor.Negadas POS                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cpos_PLSR086()
Local aCpoImp := {}, aCampos := {}, nX
Local lTit := .F., aCpoTit := {}, aAlias := {"BXE", "BXF", "BXG"}
Local lSub := .F., aCpoSub := {}

aAdd(aCpoTit, "BXE_FILIAL")

aAdd(aCpoTit, "BXF_FILIAL")
aAdd(aCpoTit, "BXF_CODSEQ")

aAdd(aCpoTit, "BXG_FILIAL")
aAdd(aCpoTit, "BXG_CODSEQ")

dbSelectArea("SX3")
dbSetOrder(1)

For nX := 1 TO Len(aAlias)
    If MsSeek(aAlias[nX])
    	While SX3->(!Eof() .And. X3_ARQUIVO == aAlias[nX])
			aAdd(aCpoImp, Alltrim(SX3->X3_CAMPO))
            SX3->(dbSkip())
   		End
   EndIf
Next

dbSelectArea("SX3")
dbSetOrder(2)

For nX := 1 TO Len(aCpoImp)
	lTit := .F.
	lSub := .F.
    If MsSeek(aCpoImp[nX])
        lTit := ASCAN(aCpoTit, aCpoImp[nX]) > 0
        lSub := ASCAN(aCpoSub, aCpoImp[nX]) > 0
    	aAdd(aCampos, { X3_ARQUIVO, X3_CAMPO, X3_TIPO, X3_TAMANHO, lSub, X3_TITULO, X3_PICTURE, lTit, X3_CBOX })
    EndIf
Next

Return(aCampos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLinha_Cabec บAutor  ณPaulo Carnelossi  บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Linha Cabec para Relatorio                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Linha_Cabec(cAlias, aCampos, aExcTam)
Local nX, aLinCabec, cLinCabec1 := "", cLinCabec2 := "", cTitle, aAuxText
Local nZ, aComboBox, nMaiorTam := 0

For nX := 1 TO Len(aCampos)

	If aCampos[nX][C_ALIAS] == cAlias .And. ! aCampos[nX][C_CAB]
        
        cTitle := AllTrim(aCampos[nX][C_TITLE])
        
		If aCampos[nX][C_TIPO] == "N"
		
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadL(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R086QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadL(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadL(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)
			
       	Else

       		If  (nPosTam := ASCAN(aExcTam, {|aVal| aVal[1] == aCampos[nX][C_CAMPO]})) > 0
       			aCampos[nX][C_TAMANHO] := aExcTam[nPosTam][2]
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    nMaiorTam := aCampos[nX][C_TAMANHO]
       		    AEVAL(aComboBox, {|cValue, nZ|nMaiorTam := If(Len(aComboBox[nZ][1]) > nMaiorTam, Len(aComboBox[nZ][1]), nMaiorTam)} )
       			aCampos[nX][C_TAMANHO] := nMaiorTam
       	    EndIf
       	    
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadR(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R086QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadR(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadR(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)

       	EndIf
       
	EndIf
	
Next

aLinCabec := { cLinCabec1, cLinCabec2 }

Return(aLinCabec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Linha  บAutor  ณPaulo Carnelossi  บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Linha de dados                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_Linha(cAlias, aCampos, nCol, aChvImp, lQuebraLinha)
Local nX, xContCpo, aComboBox, nZ, cValue, cCombo, cCampo, nPosCpo
Local aLinSobra := {}, aAuxCont, aSobra := {}

DEFAULT aChvImp := {}
DEFAULT lQuebraLin := .F.

For nX := 1 TO Len(aCampos)
    
	If aCampos[nX][C_ALIAS] == cAlias .And. ! aCampos[nX][C_CAB]
        
        nPosCpo := (cAlias)->(FieldPos(aCampos[nX][C_CAMPO]))
        If nPosCpo > 0 
        	xContCpo := (cAlias)->(FieldGet(nPosCpo))
       	Else
        	cCampo   :=aCampos[nX][C_CAMPO]
        	xContCpo := &cCampo
        EndIf
        
		If aCampos[nX][C_TIPO] == "N"
		    If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				@ li, nCol PSay PadL(Transform(xContCpo, aCampos[nX][C_PICTURE]), aCampos[nX][C_TAMANHO])
			EndIf	
       	Else
       		If aCampos[nX][C_TIPO] == "D"
       			xContCpo := DTOC(xContCpo)
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    cCombo := NIL
       		    For nZ := 1 To Len(aComboBox)
	       		    If aComboBox[nZ][2] == xContCpo
	       		    	cCombo := aComboBox[nZ][1]
       		    	    Exit
       		    	EndIf
       		    Next	    
       		    xContCpo := If(cCombo == NIL, xContCpo, cCombo)
       	    EndIf
       		
       		If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				@ li, nCol PSay PadR(xContCpo, aCampos[nX][C_TAMANHO])
			EndIf
			
			If lQuebraLinha .And. aCampos[nX][C_TIPO] == "C" .And. Len(xContCpo) > aCampos[nX][C_TAMANHO]
				aAdd(aLinSobra, {li,nCol, xContCpo, aCampos[nX][C_TAMANHO]})
			EndIf

       	EndIf

		nCol += aCampos[nX][C_TAMANHO]+1  //1->separador
        
    EndIf
    
Next

li++

If lQuebraLinha
	aSobra := {}
	For nX := 1 TO Len(aLinSobra)
	    //O STRTRAN E USADO PARA EXTRAIR XCONTCPO O JA IMPRESSO
		xContCpo := AllTrim(StrTran(aLinSobra[nX][3], PadR(aLinSobra[nX][3], aLinSobra[nX][4]), ""))
		If Len(xContCpo) > 0
			aAuxCont := R086QbTexto( xContCpo, aLinSobra[nX][4], Space(1) )
			For nZ := 1 TO Len(aAuxCont)
				aAdd(aSobra, { aLinSobra[nX][1]+nZ, aLinSobra[nX][2], aAuxCont[nZ] })
			Next
		EndIf
	Next
EndIf

If Len(aSobra) > 0 
   //coloca em ordem de linha/coluna
   aSobra := ASORT(aSobra,,, { |x, y| x[1] < y[1] .And. x[2] < y[2] })

   For nX := 1 TO Len(aSobra)
		@ aSobra[nX][1], aSobra[nX][2] PSay aSobra[nX][3]
   Next
   li := aSobra[Len(aSobra)][1]
   li++
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDetalheRel บAutor ณPaulo Carnelossi    บ Data ณ  23/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime detalhe do relatorio quando existir agrupamentos    บฑฑ
ฑฑบ          ณde acordo com aCondFinal (array contendo blocos de codigos) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DetalheRel(aCondFinal, nNivel, cAlias)

AEVAL(aCondFinal,;
				{|cX, nX| (cAlias)->(Eval(aCondFinal[nX][ANTES_LACO],nX)) } ,  1,  nNivel)

//zerar contador
aCondFinal[nNivel][6] := 0

While (cAlias)->( ! Eof() .And. AvaliaCondicao(aCondFinal, nNivel, cAlias) )

		(cAlias)->(Eval(aCondFinal[nNivel][PROC_LACO], nNivel))
		
		If nNivel < Len(aCondFinal)  // avanca para proximo nivel
			DetalheRel(aCondFinal, nNivel+1, cAlias)
		EndIf	
	   
End

(cAlias)->(Eval(aCondFinal[nNivel][DEPOIS_LACO],nNivel))

If nNivel > 1
	aCondFinal[nNivel-1][6] += aCondFinal[nNivel][6]
EndIf
						
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณAvaliaCondicaoบAutor ณPaulo Carnelossi    บ Data ณ 23/09/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณavalia condicao while (auxiliar a funcao DetalheRel()       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AvaliaCondicao(aCondFinal, nNivel, cAlias)
Local aAux := {}, lCond := .T., lRet := .T., nY
AEVAL(aCondFinal,;
				{|cX, nX| aAdd(aAux,lCond:=(cAlias)->(Eval(aCondFinal[nX][COND_LACO], nX))) } ,  1,  nNivel) 

For nY := 1 TO Len(aAux)
    If ! aAux[nY]
    	 lRet := .F.
    	 Exit
    EndIf
Next    

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR086QbTexto บAutor ณPaulo Carnelossi   บ Data ณ  02/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuebra o Texto de acordo com tamnho e separador informado   บฑฑ
ฑฑบ          ณdevolvendo um array com a string quebrada                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R086QbTexto(cTexto, nTamanho, cSeparador)
Local aString := {}, nTamAux := nTamanho
Local nPos, nCtd, nTamOri := Len(cTexto), cAuxTexto

If Len(Trim(cTexto)) > 0

   If Len(Trim(cTexto)) <= nTamanho

      If Len(Trim(cTexto)) > 0
	      aAdd(aString, AllTrim(cTexto) )
      EndIf

   Else
	
		If (nPos := At(cSeparador, cTexto)) != 0
		   
			For nCtd := 1 TO nTamOri STEP nTamAux
		
				cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			
			   If nCtd+nTamanho < nTamOri
				   While Len(Subs(cAuxTexto, Len(cAuxTexto), 1)) > 0 .And. ;
				   				Subs(cAuxTexto, Len(cAuxTexto), 1) <> cSeparador
				   
			   		cAuxTexto := Subs(cAuxTexto, 1, Len(cAuxTexto)-1)
			   		
			      End
			   EndIf
			      
		      If Len(cAuxTexto) > 0
			      cAuxTexto 	:= Subs(cTexto, nCtd, Len(cAuxTexto))
			      nTamAux 		:= Len(cAuxTexto)
		      Else
		      	cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			      nTamAux 		:= nTamanho
		      EndIf
		
		      If Len(Trim(cAuxTexto)) > 0
			      aAdd(aString, Alltrim(cAuxTexto))
		      EndIf
		   Next
		
		Else
		
			For nCtd := 1 TO nTamOri STEP nTamanho
			   If Len(Subs(cTexto, nCtd, nTamanho)) > 0 
			      If Len(Trim(Subs(cTexto, nCtd, nTamanho))) > 0
						aAdd(aString, AllTrim(Subs(cTexto, nCtd, nTamanho)))
					EndIf	
				EndIf	
			Next
		
		EndIf
		
	EndIf
Else
	aAdd(aString, Space(nTamanho))	
EndIf

Return aString


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funcao    ณ fTpGrv    ณ Autor ณ Sandro Hoffman Lopes ณ Data ณ 27.12.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descricao ณ Selecionar os Tipos de Gravacao que serao listados         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fTpGrv(l1Elem,lTipoRet)

   Local cTitulo  := ""
   Local MvPar
   Local MvParDef := ""
   Local aCBOX    := {}
   Local aTpGrv   := {}
   Local cAlias

   Private aSit:={}

   l1Elem := If (l1Elem = Nil , .F. , .T.)

   DEFAULT lTipoRet := .T.

   cAlias := Alias()

   If lTipoRet
	  MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	  MvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
   EndIf
                                         
   aCBOX := RetSx3Box(X3CBox(Posicione('SX3', 2, "BD5_TPGRV", 'X3_CBOX')),,,1)
   aEval(aCBOX, {|x| IIf(!Empty(x[1]), aAdd(aTpGrv, x[1]),) })
   MvParDef := "1234"
   cTitulo  := "Tipo de Gravacao"
   If lTipoRet
      If f_Opcoes(@MvPar, cTitulo, aTpGrv, MvParDef, 12, 49, l1Elem)  // Chama funcao f_Opcoes
         &MvRet := MvPar // Devolve Resultado
      EndIf
   EndIf	

   DbSelectArea(cAlias) // Retorna Alias

Return(If(lTipoRet, .T., MvParDef))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Darcio R. Sporl       ณ Data ณ26/12/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Private aRotina := { 	{	STRPL01						,'AxPesqui'		,0 ,K_Pesquisar  ,0 ,.F.},;
											{ STRPL02						,'PLSA086Con'	,0 ,K_Visualizar ,0 ,Nil},;
											{ "Filtro"					,'PLSA086Fil'	,0 ,K_Visualizar ,0 ,Nil},;
											{ "Remover Filtro"	,'PLSA086Rem'	,0 ,K_Visualizar ,0 ,Nil},;
											{ "Imprimir"				,'PLSA086Imp'	,0 ,K_Visualizar ,0 ,Nil} }
Return(aRotina)