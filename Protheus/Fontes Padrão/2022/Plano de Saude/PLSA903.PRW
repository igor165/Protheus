#INCLUDE "PLSA903.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ PLSA903 ณ Autor ณ Paulo Carnelossi       ณ Data ณ 19/05/04 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Cadastro de Equipe de Vendas                               ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณSintaxe   ณ PLSA903()                                                  ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Uso      ณ AP                                                         ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSA903()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aRotina 	:=	MenuDef()
PRIVATE cCadastro 	:= STR0010 //"Equipe de Vendedores"
PRIVATE lVigente    := .F.
PRIVATE cCodInt
Private cCodEmp

lVigente := .F. //If(mv_par01 == 1, .T., .F.)

//SetKey(VK_F12,{|a,b| (Pergunte("PLV905",.T.), lVigente := If(mv_par01 == 1, .T., .F.)) })

BXL->(mBrowse(06,01,350,256,"BXL",,,20))

//SET KEY VK_F12 TO

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณPL903AMov ณ Autor ณ Paulo Carnelossi      ณ Data ณ 04.06.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Modulo de Manutencao da Equipde de Vendedores              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณPL903AMov(cAlias,nReg,nOpc)                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PL903AMov(cAlias,nReg,nOpc)
Local I__f := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis...                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nSaveSX8  := MyGetSX8Len()
Local nOpca := 0
Local oDlg

Local oFont
Local lLock := .F.

Local cVendedor
Local nOpcx        := nOpc
Local oDlgFolder
Local nX, aCpoBXL := {}, aCabBXL := {}
Local dVldIni
Local aSeqNewBXJ := {}, aAuxNewBXJ
Local aPosObj   := {}
Local aObjects  := {}
Local aObjects2 := {}
Local aSize     := {}
Local aInfo     := {}
Local aSavArea
Local cChave
Local aDifSize:= {,,,,35,3,,}//array com dimen็๕es para corre็ใo de telas na versใo 12

PRIVATE aSeqBXJAtual := {}
PRIVATE aNumBXJ := {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Comissao da Equipe de  vendedores...                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aCabBXJ := {}
PRIVATE aDadBXJ := {}
PRIVATE aTrbBXJ := {}

PRIVATE aCabBXK := {}
PRIVATE aDadBXK := {}
PRIVATE aTrbBXK := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Membros da Equipe de  vendedores...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aCabBXM := {}
PRIVATE aDadBXM := {}
PRIVATE aTrbBXM := {}
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Comissao dos Membros da Equipe de  vendedores...                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aCabBXJMEM := {}
PRIVATE aDadBXJMEM := {}
PRIVATE aTrbBXJMEM := {}

PRIVATE aCabBXKMEM := {}
PRIVATE aDadBXKMEM := {}
PRIVATE aTrbBXKMEM := {}

PRIVATE aHeader      := {}
PRIVATE aCols        := {}
PRIVATE oSay01, oSay02
PRIVATE oSay
PRIVATE oEncBXL
PRIVATE oFolder, oBrwBXJ,  oBrwBXM, oBrwBXJMEM, oBrwBXK, oBrwBXKMEM

PRIVATE cCodVen:="", cNomVen:="", cCodEqu:=""
PRIVATE bFilterBXM, bFilterBXJ, bFilterBXK, bFilterBXJMEM, bFilterBXKMEM 
PRIVATE lVisualBXL, aDatasVig, nRecBXL, aGradeVazia
lVisualBXL := (nOpcx==K_Excluir .OR. nOpcx==K_Visualizar)

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

aGradeVazia := {.T.,.T.,.T.}

//DEFINIDO PARA NAO DAR ERRO NA CRIAVAR (X3_RELACAO ) NA MONTAGEM DAS GETDADOS
M->BXL_SEQ 		:= Space(Len(BXL->BXL_SEQ))
M->BXL_VLDINI	:= CtoD(Space(8))
M->BXL_VLDFIM	:= CtoD(Space(8))

M->BXJ_CODEQU 	:= Space(Len(BXJ->BXJ_CODEQU))
M->BXJ_DESEQU  := Space(40)
M->BXJ_CODVEN 	:= Space(Len(BXJ->BXJ_CODVEN))
M->BXJ_DESVEN  := Space(40)
M->BXJ_TIPO 	:= ""
M->BXJ_SEQ		:= ""


If nOpcx == K_Incluir
	aDatasVig := {}
ElseIf (nOpcx == K_Alterar .OR. nOpcx == K_Excluir) .And. ! Empty(BXL->BXL_VLDFIM)
   MsgStop(STR0011) //"Nao permitido alteracao/exclusao com termino de vigencia preenchido!"
   Return
ElseIf nOpcx == K_Excluir .And. (GetNewPar("MV_PLEXEQU",0) == 1  .And. !PL903VldExc(BXL->BXL_CODEQU))
	Aviso(STR0010,STR0060,{"Ok"})
	Return
EndIf

If nOpcx == K_Alterar
	dVldIni   := BXL->BXL_VLDINI
   nRecBXL   := BXL->(Recno())
   cCodEqu   := BXL->BXL_CODEQU
   
   aDatasVig := {}
   dbSelectArea("BXL")
   dbSetOrder(1)
   dbSeek(xFilial("BXL")+cCodEqu)
   While BXL->(!Eof() .And. BXL_FILIAL == xFilial("BXL") .And. ;
   				BXL_CODEQU == cCodEqu)
   	If BXL->(Recno()) <> nRecBXL
	   	aAdd(aDatasVig, {BXL->BXL_VLDINI, BXL->BXL_VLDFIM})
	   EndIf	
   	BXL->(dbSkip())
	End   				
   dbSelectArea("BXL")
   dbGoto(nRecBXL)
EndIf   	

Store Header "BXL" TO aCabBXL For .T.
For nX := 1 TO Len(aCabBXL)
  	If ! (aCabBXL[nX][2] $ "BXL_CODVEN;BXL_DESVEN")
      	aAdd(aCpoBXL, aCabBXL[nX][2])
   	EndIf
Next

If nOpcx == K_Incluir
   Copy "BXL" TO Memory Blank
Else
   Copy "BXL" TO Memory 
   If nOpc == K_Alterar .Or. nOpc == K_Excluir
      If ! BXL->(RecLock("BXL",.F.))
         Return
      Else
         lLock := .T.
      Endif   
   Endif
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Membros da Equipe de Vendedores                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Store Header "BXM" TO aCabBXM For .T.

If nOpcx == K_Incluir
   Store COLS Blank "BXM" TO aDadBXM FROM aCabBXM
Else
   BXM->(DbSetOrder(1))
   If ! BXM->(DbSeek(xFilial("BXM")+BXL->BXL_SEQ)) 
       Store COLS Blank "BXM" TO aDadBXM FROM aCabBXM
   Else
      Store COLS "BXM" TO aDadBXM FROM aCabBXM VETTRAB aTrbBXM While BXM->(BXM_FILIAL+BXM->BXM_SEQBXL) == xFilial("BXM") + BXL->BXL_SEQ 
   Endif                                  
Endif

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 14, .T., .F., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
aInfo    := { 0, 0, aPosObj[2][3]-2, aPosObj[2][4]-12, 3, 3 }
aPosObj2 := MsObjSize( aInfo, aObjects )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define dialogo...                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Folder...PRINCIPAL (PAI)                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlgFolder PIXEL PROMPTS STR0012 ,;  //"Equipe Vendas/Composicao"
                                                                  STR0013 ,;  //"Regras da Equipe"
                                                                  STR0014     //"Regras Equipe/Vendedor"

oFolder:bSetOption := { |nFolder| A903Set(nFolder,nOpcx,oGrupo, oSay) }
oFolder:bChange    := { |nFolder| A903Chg(nFolder,nOpcx) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ ENCHOICE (BXL)                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cAlias:="BXL"
nReg:=BXL->(RecNo())
oEncBXL := MSMGet():New(cAlias,nReg,nOpcx,,,,aCpoBXL,aPosObj2[1],aCpoBXL,,,,,oFolder:aDialogs[1],,,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TPLSBXM -> COMPOSICAO DA EQUIPE DE VENDAS...                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
bFilterBXM := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BXM_SEQBXL",aHeader)]== M->BXL_SEQ}

if Val(GetVersao(.F.)) >= 12 //Valida versใo 12
	oBrwBXM := TPLSBrw():New(aPosObj2[2][1],aPosObj2[2][2],aPosObj2[2][4],aPosObj2[2][3],nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXM,aDadBXM,.F.,"BXM",nOpcx,STR0015,nil,nil,nil,aTrbBXM,,"A903DEL",bFilterBXM,,,,,,,,,,aDifSize ) //"Composicao da Equipe de Vendas"
Else
	oBrwBXM := TPLSBrw():New(aPosObj2[2][1],aPosObj2[2][2],aPosObj2[2][4],aPosObj2[2][3],nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXM,aDadBXM,.F.,"BXM",nOpcx,STR0015,nil,nil,nil,aTrbBXM,,"A903DEL",bFilterBXM ) //"Composicao da Equipe de Vendas"
Endif

oBrwBXM:bLostFocus := {||cCodVen:=oBrwBXM:aCols[oBrwBXM:Linha(),GdFieldPos("BXM_CODVEN",aCabBXM)] ,;
                          cNomVen:=oBrwBXM:aCols[oBrwBXM:Linha(),GdFieldPos("BXM_DESVEN",aCabBXM)]}

oBrwBXM:bGotFocus := {||If(!OBrigatorio(oEncBXL:aGets, oEncBXL:aTela),oEncBXL:SetFocus(),.T.)}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ativa o dialogo...                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 	aPosObj[1][1],	aPosObj[1][2] GROUP oGrupo TO aPosObj[1][3], (aPosObj[1][4]/2)-2 PIXEL OF oDlg LABEL " "+STR0016 +" "  COLOR CLR_HBLUE, CLR_HRED //"Equipe de Vendas"
@	aPosObj[1][1]+5,aPosObj[1][2]+5 SAY oSay PROMPT M->BXL_CODEQU+If(!Empty(M->BXL_CODEQU)," - ","")+M->BXL_DESEQU SIZE (aPosObj[1][4]/2)-10,7 OF oDlg PIXEL COLOR CLR_HBLUE FONT oFont

@ 	aPosObj[1][1], 	aPosObj[1][2]+(aPosObj[1][4]/2)-2 GROUP oGrupo TO aPosObj[1][3], aPosObj[1][4] PIXEL OF oDlg LABEL " "+STR0017 +" "  COLOR CLR_HBLUE, CLR_HRED //"Vendedor"
@	aPosObj[1][1]+5,aPosObj[1][2]+5+(aPosObj[1][4]/2)-1 SAY oSay PROMPT cCodVen + " - " + cNomVen SIZE (aPosObj[1][4]/2)-10,7 OF oDlg PIXEL COLOR CLR_HBLUE FONT oFont

oGrupo:lVisible := .F.
oSay:lVisible := .F.

If nOpcx <> K_Incluir
   //forcar atualizacao dos folders para criar os objetos browses
   oFolder:SetOption(1)
   oFolder:SetOption(2)
   oFolder:SetOption(3)


EndIf

ACTIVATE MSDIALOG oDlgFolder ON INIT (Iif((nOpcx <> K_Incluir),oFolder:SetOption(1),nil),;
		    Iif((nOpcx <> K_Incluir),oBrwBXM:oBrowse:oBrowse:SetFocus(),nil),;
		    EnchoiceBar(oDlgFolder,{|| If( P903TudoOk(nOpcx, oEncBXL) ,(PlsEndBrw(),nOpca := 1,oDlgFolder:End()),.F.)},{|| PlsEndBrw(), nOpca :=2 , oDlgFolder:End() },K_MsgDel))//,aButtons

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Trata atualizacao dos dados...                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpca == K_OK
  
   If nOpcx <> K_Visualizar 

      If  nOpcx == K_Excluir
          cVendedor := BXL->BXL_CODVEN
          cChave    := BXL->(BXL_FILIAL+BXL_CODEQU)
      Endif

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ Equipde de Vendedores                                               ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If nOpcx == K_Incluir
      
      	dbSelectArea("BXJ")
      	nElemBXJ  := Len(aNumBXJ)
      	
      	For nX := nElemBXJ TO 1 STEP -1
					ConfirmSX8()
      	Next
      	
      	dbSelectArea("BXL")
      	dbSetOrder(2)
      	ConfirmSX8()
      	
   	   //se ja existir chama novamente getsx8num
      	If dbSeek(xFilial("BXL")+M->BXL_SEQ)
		      While dbSeek(xFilial("BXL")+M->BXL_SEQ)
		      	M->BXL_SEQ := GetSx8Num("BXL","BXL_SEQ",,2)
		      	ConfirmSX8()
		      End
		      //Acerta o sequencial do BXL em todos os objetos browse
		      a903acertaCpo(oBrwBXM	, "BXM_SEQBXL", M->BXL_SEQ)
		      a903acertaCpo(oBrwBXJ	, "BXJ_SEQBXL", M->BXL_SEQ)
		      a903acertaCpo(oBrwBXK	, "BXK_SEQBXL", M->BXL_SEQ)
		      a903acertaCpo(oBrwBXJMEM, "BXJ_SEQBXL", M->BXL_SEQ)
		      a903acertaCpo(oBrwBXKMEM, "BXK_SEQBXL", M->BXL_SEQ)
	      EndIf
	      
	      dbSelectArea("BXL")
	      dbSetOrder(1)
      
      EndIf
      
	   PLUPTENC("BXL",nOpc,!lLock)   // gravar dados da Enchoice
	   
      //na rotina de alteracao se alterar data validade inicial acertar BXJ
      If nOpcx == K_Alterar .And. dVldIni != NIL .And. dVldIni <> M->BXL_VLDINI
      	a903acertaCpo(oBrwBXJ		, "BXJ_VLDINI", M->BXL_VLDINI)
      	a903acertaCpo(oBrwBXJMEM	, "BXJ_VLDINI", M->BXL_VLDINI)
      EndIf	

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ Cadastrar a equipe de Vendas como vendedor no cadastro SA3-Cad.Vend.ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If nOpcx == K_Incluir
      	If Val(GetVersao(.F.)) >= 12//caso a versใo
      		A903VendEquipe(@cVendedor)
      	Else	
	         While .T.
	      		cVendedor:=""
	   			If A903VendEquipe(@cVendedor)
	   				EXIT
	   			EndIf
	      	End
	      	If SA3->(dbSeek(xFilial("SA3")+cVendedor))
	      	   dbSelectArea("BXL")
	      		RecLock("BXL", .F.) //alteracao
		      	BXL->BXL_CODVEN := SA3->A3_COD
		      	MsUnLock()
		      EndIf
		Endif     	
      EndIf

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ Composicao da Equipe de Vendas   ...                                ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If ValType(oBrwBXM) == "O"
	      aChave := {}
   	   oBrwBXM:Grava(aChave)
      EndIf

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ Regras da da Equipe de Vendas                                       ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If ValType(oBrwBXJ) == "O"
	      aChave := {}
	      aadd(aChave,{"BXJ_CODEQU",M->BXL_CODEQU})
	      aadd(aChave,{"BXJ_CODVEN",""})
	      oBrwBXJ:Grava(aChave)
	      
	      aChave := {}
	      oBrwBXK:Grava(aChave)
	   EndIf   
	
      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ regras dos componentes da equipe de vendas                          ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If ValType(oBrwBXJMEM) == "O"
	      aChave := {}
	      aadd(aChave,{"BXJ_CODEQU",M->BXL_CODEQU})
	      oBrwBXJMEM:Grava(aChave)
	      
	      aChave := {}
	      oBrwBXKMEM:Grava(aChave)
		EndIf
		
		If nOpcx == K_Alterar

			BXJ->(DbSetOrder(2))
			If BXJ->(DbSeek(xFilial("BXJ")+BXL->BXL_SEQ)) //1=Equipe
				While BXJ->(BXJ_FILIAL+BXJ_SEQBXL) == xFilial("BXJ")+BXL->BXL_SEQ 
			      If ASCAN(aSeqBXJAtual,BXJ->BXJ_SEQ)==0 
			         aAdd(aSeqNewBXJ, BXJ->BXJ_SEQ)
			      EndIf
			  		BXJ->(dbSkip())
				End
	      EndIf
	      
	      nElemBXJ  := Len(aNumBXJ)
	      aAuxNewBXJ := Array(nElemBXJ)
			aFill(aAuxNewBXJ, .F.)

			For nX := 1 TO Len(aNumBXJ)
			   If ASCAN(aSeqNewBXJ, aNumBXJ[nX]) > 0
			   	aAuxNewBXJ[nX] := .T.
			   EndIf	
			Next
			
			For nX := nElemBXJ TO 1 STEP -1
			   If aAuxNewBXJ[nX]
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf	
			Next	

		EndIf
		
      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ Verifica se deve excluir o vendedor                                 ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If  nOpcx == K_Excluir
          If  ! BXL->(dbSeek(xFilial("BXL")+M->BXL_CODEQU))
              If  SA3->(dbSeek(xFilial("SA3")+cVendedor))
                  If  SA3->(RecLock("SA3",.F.))
                      SA3->(dbDelete())
                      SA3->(msUnLock())
                  Endif
              Endif
          Endif
		  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		  //ณ BOPS 101909                                                         ณ
		  //ณ Na exclusao de uma equipe, caso exista vigencias anteriores da      ณ
		  //ณ mesma equipe, questiona usuario se deve reabrir a ultima vigencia   ณ
		  //ณ encerrada.                                                          ณ
		  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		  aSavArea := {}
    	  aAdd(aSavArea, { BXL->(IndexOrd()), BXL->(RecNo()) })
    	  BXL->(DbSetOrder(1))
		  BXL->(MsSeek(cChave+"9", .T.))
		  BXL->(DbSkip(-1))
          If BXL->(BXL_FILIAL+BXL_CODEQU) == cChave
				If MsgYesNo(STR0052 + ; // "Deseja reabrir a ๚ltima vig๊ncia desta equipe que estแ sendo excluํda?"
          		   			 Chr(13) + STR0053 + DtoC(BXL->BXL_VLDINI) + STR0054 + DtoC(BXL->BXL_VLDFIM), STR0038) // "ฺltima Vig๊ncia encontrada: "###" a "###"Aten็ใo"
    				PL903Reab("BXL",BXL->(RecNo()),nOpc,,.F.)
    			EndIf
    	  EndIf
		  BXL->(DbSetOrder(aSavArea[1,1]))
		  BXL->(DbGoTo(aSavArea[1,2]))
    	  
      Endif

   Endif   

Else
   If nOpcx == K_Incluir
		While ( MyGetSX8Len() > nSaveSX8 )
			RollBackSX8()
		EndDo
	Endif   
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fim da Rotina Principal...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณA903SET   ณ Autor ณ Marco Paulo           ณ Data ณ 26.09.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Controla mudanca de Folder e Atualiza Operadora na tela    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณA903SET(nFolder,nOpcx)                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A903SET(nFolder,nOpcx,oGrupo, oSay)
If nFolder == 1
 	oGrupo:lVisible := .F.
	oSay:lVisible := .F.

ElseIf nFolder == 2
	oGrupo:lVisible := .F.
	oSay:lVisible := .F.
	M->BXJ_CODVEN 	:= ""
	M->BXJ_DESVEN  := ""
	M->BXJ_TIPO 	:= "3"   // Equipe

ElseIf nFolder == 3
   //If nOpcx == K_Incluir .Or. nOpcX == K_Alterar
		Eval(oBrwBXM:bLostFocus)
	//EndIf
	M->BXJ_CODVEN 	:= cCodVen
	M->BXJ_DESVEN  := cNomVen
	M->BXJ_TIPO 	:= "2" // Vendedor/Equipe

	If ValType(oBrwBXKMEM)=="O"
		oBrwBXKMEM:Atualiza()
	EndIf
	
	If ValType(oBrwBXJMEM)=="O"
		oBrwBXJMEM:Atualiza()
		oBrwBXJMEM:oBrowse:Refresh()
	EndIf	
	
   If !Empty(cCodVen)
		oSay:cCaption := cCodVen + " - " + cNomVen
		oGrupo:lVisible := .T.
		oSay:lVisible := .T.
	EndIf	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณA903CHG   ณ Autor ณ Paulo Carnelossi      ณ Data ณ 18/05/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Controla mudanca de folder                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณA903CHG(nFolder,nOpcx)                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A903Chg(nFolder,nOpcx)
Local nRecBXJ := 0
Local aDifSize:= {,,,,35,3,,}//array com dimen็๕es para corre็ใo de telas na versใo 12

If nFolder == 1 .And. nOpcx == K_Alterar
	oBrwBXM:Refresh()
EndIf	

If Empty(cCodVen) .And. nFolder == 3
   If nOpcx == K_Incluir
		MsgStop(STR0018) //"Regras por Equipe/Vendedor somente poderao ser digitadas para o vendedor selecionado."
   	oFolder:SetOption(1)
	   oFolder:aDialogs[1]:SetFocus()
	EndIf   
Endif

If nFolder == 2 
   
   If !OBrigatorio(oEncBXL:aGets, oEncBXL:aTela)
   
      If nOpcx == K_Incluir
			MsgStop(STR0019) //"Regras por Equipe somente poderao ser digitadas apos cadastro da mesma."
   		oFolder:SetOption(1)
   		oFolder:aDialogs[1]:SetFocus()
   	EndIf	
   
   Else
   
   	If aGradeVazia[nFolder]
   		M->BXJ_CODVEN 	:= ""
			M->BXJ_DESVEN  := ""
   		M->BXJ_TIPO := "3" // Equipe
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Regras de comissoes da equipe de vendas...                          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Store Header "BXJ" TO aCabBXJ For ;
						! (SX3->X3_CAMPO $ "BXJ_CODVEN;BXJ_DESVEN;BXJ_CODEQU;BXJ_DESEQU")
						
			If nOpcx == K_Incluir
			   Store COLS Blank "BXJ" TO aDadBXJ FROM aCabBXJ
			Else
			   BXJ->(DbSetOrder(2))
			   If ! BXJ->(DbSeek(xFilial("BXJ")+BXL->BXL_SEQ)) //1=Equipe
			      If nOpcx <> K_Alterar
			      	Return
			      Else
			      	Store COLS Blank "BXJ" TO aDadBXJ FROM aCabBXJ
			      EndIf	
			   Else
			       nRecBXJ := BXJ->(Recno())
			       While BXJ->(BXJ_FILIAL+BXJ_SEQBXL) == xFilial("BXJ")+BXL->BXL_SEQ 
			          If BXJ_TIPO=="3" // Equipe
			             aAdd(aSeqBXJAtual, BXJ->BXJ_SEQ)
			          EndIf
			          BXJ->(dbSkip())
			       End
			       BXJ->(dbGoto(nRecBXJ))
			       Store COLS "BXJ" TO aDadBXJ FROM aCabBXJ VETTRAB aTrbBXJ ;
			       FOR If(lVigente .And. nOpcx <> K_Excluir, BXJ->((Empty(BXJ_VIGATE) .OR. BXJ_VIGATE >= dDataBase ).And.BXJ_TIPO=="3"), BXJ_TIPO=="3");
			       While BXJ->(BXJ_FILIAL+BXJ_SEQBXL) == xFilial("BXJ")+BXL->BXL_SEQ 
			   Endif
			   If Len(aDadBXJ) == 0
			   	If nOpcx <> K_Alterar
			      	Return
			      Else
			      	Store COLS Blank "BXJ" TO aDadBXJ FROM aCabBXJ
			      EndIf	
			   EndIf
			   BXJ->(DbSetOrder(1))
			Endif     
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Regras da equipe de vendas                                          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			bFilterBXJ	:= {|nLine,aCols,aHeader|;
								aCols[nLine,GdFieldPos("BXJ_SEQBXL",aHeader)]==M->BXL_SEQ .And. ;
								aCols[nLine,GdFieldPos("BXJ_TIPO",aHeader)]=="3" }
			
			if Val(GetVersao(.F.)) >= 12 //Valida versใo 12
				oBrwBXJ := TPLSBrw():New(aPosObj2[1][1],aPosObj2[1][2],aPosObj2[1][4],aPosObj2[1][3],nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXJ,aDadBXJ,.F.,"BXJ",nOpcx,STR0020,nil,nil,nil,aTrbBXJ,,"A903DEL",bFilterBXJ,,,,,,,,,,aDifSize) //"Comissao da Equipe de Vendas"
			Else
				oBrwBXJ := TPLSBrw():New(aPosObj2[1][1],aPosObj2[1][2],aPosObj2[1][4],aPosObj2[1][3],nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXJ,aDadBXJ,.F.,"BXJ",nOpcx,STR0020,nil,nil,nil,aTrbBXJ,,"A903DEL",bFilterBXJ) //"Comissao da Equipe de Vendas"
			Endif
			
			oBrwBXJ:bLostFocus := {|| M->BXJ_SEQ := ;
												oBrwBXJ:aCols[oBrwBXJ:Linha(),GdFieldPos("BXJ_SEQ",aCabBXJ)]}
			
			oBrwBXJ:bChange := {||Eval(oBrwBXJ:bLostFocus), oBrwBXK:ForceRefresh(oBrwBXJ), ;
								   cCodInt := oBrwBXJ:FieldGet("BXJ_CODINT",oBrwBXJ:Linha()), ;
								   cCodEmp := oBrwBXJ:FieldGet("BXJ_CODEMP",oBrwBXJ:Linha()) } 
			oBrwBXJ:bAfterAdd := {||A903Numera(oBrwBXJ,.F.), oBrwBXJ:Refresh()}
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Itens da regras de comissoes da equipe de vendas...                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Len(aCabBXK) == 0
			   
			   Eval(oBrwBXJ:bLostFocus)
			   
				Store Header "BXK" TO aCabBXK For .T.
				If nOpcx == K_Incluir
				   Store COLS Blank "BXK" TO aDadBXK FROM aCabBXK
				Else
				   BXK->(DbSetOrder(2))
				   If ! BXK->(DbSeek(xFilial("BXK")+BXL->BXL_SEQ)) //1=Equipe
				       Store COLS Blank "BXK" TO aDadBXK FROM aCabBXK
				   Else
			   	    Store COLS "BXK" TO aDadBXK FROM aCabBXK VETTRAB aTrbBXK ;
			      	 FOR If(lVigente .And. nOpcx <> K_Excluir, BXK->((Empty(BXK_VIGATE) .OR. BXK_VIGATE >= dDataBase ).And.BXK_TIPO=="3"), BXK_TIPO=="3");
				       While BXK->(BXK_FILIAL+BXK_SEQBXL) == xFilial("BXK")+BXL->BXL_SEQ 
				   Endif
				   If Len(aDadBXK) == 0
				      Store COLS Blank "BXK" TO aDadBXK FROM aCabBXK
			   	EndIf
				   BXK->(DbSetOrder(1))
				Endif     
			
				bFilterBXK	:= {|nLine,aCols,aHeader|;
									aCols[nLine,GdFieldPos("BXK_SEQBXJ",aHeader)]==;
									oBrwBXJ:aCols[oBrwBXJ:Linha(),GdFieldPos("BXJ_SEQ",aCabBXJ)]}
				
				if Val(GetVersao(.F.)) >= 12 //Valida versใo 12
					oBrwBXK := TPLSBrw():New(aPosObj2[2][1],aPosObj2[2][2],aPosObj2[2][4],aPosObj2[2][3],nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXK,aDadBXK,.F.,"BXK",nOpcx,STR0021,nil,nil,nil,aTrbBXK,"A903VALPER","A903DEL",bFilterBXK,,,,,,,,,,aDifSize) //"Comissao da Equipe de Vendas"
				Else
					oBrwBXK := TPLSBrw():New(aPosObj2[2][1],aPosObj2[2][2],aPosObj2[2][4],aPosObj2[2][3],nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXK,aDadBXK,.F.,"BXK",nOpcx,STR0021,nil,nil,nil,aTrbBXK,"A903VALPER","A903DEL",bFilterBXK) //"Itens das Regras de comissao da equipe de vendas"
				Endif
				
				oBrwBXK:oPai    := oBrwBXJ
				oBrwBXK:aOrigem := {"BXJ_SEQ"}
				oBrwBXK:aRelac  := {"BXK_SEQBXJ"}
				
				aGradeVazia[nFolder]	:= .F.
				
			EndIf	
			
	   EndIf	
	   
   EndIf
   
Endif

If ! Empty(cCodVen) .And. nFolder == 3 
   
   If !OBrigatorio(oEncBXL:aGets, oEncBXL:aTela) 
		MsgStop(STR0019) //"Regras por Equipe somente poderao ser digitadas apos cadastro da mesma."
   	oFolder:SetOption(1)
   	oFolder:aDialogs[1]:SetFocus()
   
   Else
   
   	If aGradeVazia[nFolder]
   	
	   	M->BXJ_CODVEN 	:= cCodVen
	   	M->BXJ_DESVEN  := cNomVen
	   	M->BXJ_TIPO		:= "2" // Vendedor/Equipe
	   	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Regras das comissoes dos componentes da equipe de vendas...         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Store Header "BXJ" TO aCabBXJMEM For ;
							! (SX3->X3_CAMPO $ "BXJ_CODEQU;BXJ_DESEQU")
			If nOpcx == K_Incluir
			   Store COLS Blank "BXJ" TO aDadBXJMEM FROM aCabBXJMEM
			Else
			   BXJ->(DbSetOrder(2))
			   If ! BXJ->(DbSeek(xFilial("BXJ")+BXL->BXL_SEQ))
			       If nOpcx <> K_Alterar
				       Return
				    Else
				    	Store COLS Blank "BXJ" TO aDadBXJMEM FROM aCabBXJMEM
				    EndIf	
			   Else
			   	 nRecBXJ := BXJ->(Recno())
			       While BXJ->(BXJ_FILIAL+BXJ_SEQBXL) == xFilial("BXJ")+BXL->BXL_SEQ 
			          If BXJ_TIPO=="2" // Vendedor/Equipe
			             aAdd(aSeqBXJAtual, BXJ->BXJ_SEQ)
			          EndIf
			          BXJ->(dbSkip())
			       End
			       BXJ->(dbGoto(nRecBXJ))

			       Store COLS "BXJ" TO aDadBXJMEM FROM aCabBXJMEM VETTRAB aTrbBXJMEM ;
			       FOR If(lVigente .And. nOpcx <> K_Excluir, BXJ->(Empty(BXJ_VIGATE) .OR. BXJ_VIGATE >= dDataBase.And.BXJ_TIPO=="2"), BXJ_TIPO=="2");
			       While BXJ->(BXJ_FILIAL+BXJ_SEQBXL) == xFilial("BXJ")+BXL->BXL_SEQ
			   Endif
			   If Len(aDadBXJMEM) == 0
			   	If nOpcx <> K_Alterar
			   		Return
			   	Else
						Store COLS Blank "BXJ" TO aDadBXJMEM FROM aCabBXJMEM
					EndIf	
			   EndIf
			   BXJ->(DbSetOrder(1))
			Endif     
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ regras para cada componente da equipe de vendas                     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			bFilterBXJMEM := {|nLine,aCols,aHeader|;
								aCols[nLine,GdFieldPos("BXJ_SEQBXL",aHeader)]==M->BXL_SEQ .And. ;
								aCols[nLine,GdFieldPos("BXJ_CODVEN",aHeader)]==cCodVen .And. ;
								aCols[nLine,GdFieldPos("BXJ_TIPO",aHeader)]=="2" }
			
			oBrwBXJMEM := TPLSBrw():New(aPosObj2[1][1],aPosObj2[1][2],aPosObj2[1][4],aPosObj2[1][3],nil,oFolder:aDialogs[3],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXJMEM,aDadBXJMEM,.F.,"BXJ",nOpcx,STR0022,nil,nil,nil,aTrbBXJMEM,,"A903DEL",bFilterBXJMEM) //"Comissao dos Membros da Equipe de Vendas"
			
			oBrwBXJMEM:bLostFocus := {|| M->BXJ_SEQ := ;
												oBrwBXJMEM:aCols[oBrwBXJMEM:Linha(),GdFieldPos("BXJ_SEQ",aCabBXJMEM)]}
			
			oBrwBXJMEM:bGotFocus := {||If(!OBrigatorio(oEncBXL:aGets, oEncBXL:aTela),oEncBXL:SetFocus(),.T.)}
			                        
			oBrwBXJMEM:bChange := {||Eval(oBrwBXJMEM:bLostFocus), oBrwBXKMEM:ForceRefresh(oBrwBXJMEM), oBrwBXM:ForceRefresh(oBrwBXJMEM),;
								   cCodInt := oBrwBXJMEM:FieldGet("BXJ_CODINT",oBrwBXJMEM:Linha()), ;
								   cCodEmp := oBrwBXJMEM:FieldGet("BXJ_CODEMP",oBrwBXJMEM:Linha()) } 
			oBrwBXJMEM:bAfterAdd := {||A903Numera(oBrwBXJMEM,.T.), oBrwBXJMEM:Refresh()}

			oBrwBXJMEM:oPai    := oBrwBXM
			oBrwBXJMEM:aOrigem := {"BXM_SEQBXL","BXM_CODVEN"}
			oBrwBXJMEM:aRelac  := {"BXJ_SEQBXL","BXJ_CODVEN"}                      

			//AGORA JA PODE COLOCAR BCHANGE DO BXM PARA FUNCIONAR
			oBrwBXM:bChange := {||oBrwBXJMEM:ForceRefresh(oBrwBXM) } 
			aGradeVazia[nFolder]	:= .F.

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Itens da regras de comissoes de cada membro da equipe de vendas...  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Len(aCabBXKMEM) == 0
			   
			   Eval(oBrwBXJMEM:bLostFocus)
			   
				Store Header "BXK" TO aCabBXKMEM For .T.
				If nOpcx == K_Incluir
				   Store COLS Blank "BXK" TO aDadBXKMEM FROM aCabBXKMEM
				Else 
				   BXK->(DbSetOrder(2))
				   If ! BXK->(DbSeek(xFilial("BXK")+BXL->BXL_SEQ)) 
				       Store COLS Blank "BXK" TO aDadBXKMEM FROM aCabBXKMEM
				   Else
				       Store COLS "BXK" TO aDadBXKMEM FROM aCabBXKMEM VETTRAB aTrbBXKMEM ;
				       FOR If(lVigente .And. nOpcx <> K_Excluir, BXK->((Empty(BXK_VIGATE) .OR. BXK_VIGATE >= dDataBase ).And.BXK_TIPO=="2"), BXK_TIPO=="2");
				       While BXK->(BXK_FILIAL+BXK_SEQBXL) == xFilial("BXK")+BXL->BXL_SEQ 
				   Endif
				   If Len(aDadBXKMEM) == 0
				      Store COLS Blank "BXK" TO aDadBXKMEM FROM aCabBXKMEM
				   EndIf
				   BXK->(DbSetOrder(1))
				Endif     
	
				bFilterBXKMEM	:= {|nLine,aCols,aHeader|;
										aCols[nLine,GdFieldPos("BXK_SEQBXJ",aHeader)]==;
										oBrwBXJMEM:aCols[oBrwBXJMEM:Linha(),GdFieldPos("BXJ_SEQ",aCabBXJMEM)]}
										
				oBrwBXKMEM := TPLSBrw():New(aPosObj2[2][1],aPosObj2[2][2],aPosObj2[2][4],aPosObj2[2][3],nil,oFolder:aDialogs[3],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBXKMEM,aDadBXKMEM,.F.,"BXK",nOpcx,STR0023,nil,nil,nil,aTrbBXKMEM,,"A903DEL",bFilterBXKMEM) //"Itens das Regras de comissao de cada membro da equipe de vendas"
				
				oBrwBXKMEM:oPai    := oBrwBXJ
				oBrwBXKMEM:aOrigem := {"BXJ_SEQ"}
				oBrwBXKMEM:aRelac  := {"BXK_SEQBXJ"}                      
				
			EndIf	
			
	   EndIf	
	   
   EndIf
   
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ P903TudoOk ณ Autor ณ Paulo Carnelossi    ณ Data ณ 19/05/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Faz a checagem dos campos e pastas oBrigatorias            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ P903Tudook(nOpc, oEncBXL)                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ nOpc - Opcao do aRotina                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function P903TudoOk(nOpc)
Local lRet := .T.
Local nRecBXL := BXL->(Recno())

BXL->(DbSetOrder(1))
BXL->(DbSeek(xFilial()+M->BXL_CODEQU))
If nOpc == K_Incluir .and. !BXL->(Eof()) // SE FOR INCLUSAO VERIFICA SE O CODIGO JA ESTA GRAVADO NO ARQUIVO E NAO DEIXA CONTINUAR
   Help("",1,"JAGRAVADO")
   oFolder:SetOption(1)
   oFolder:aDialogs[1]:SetFocus()
   lRet := .F.
EndIf
BXL->(DbGoto(nRecBXL))

If lRet .And. ! OBrigatorio(oEncBXL:aGets, oEncBXL:aTela)
   oFolder:SetOption(1)
   oFolder:aDialogs[1]:SetFocus()
	lRet := .F.
EndIf

If lRet .And. ! (oBRWBXM:TudoOk())
   oFolder:SetOption(1)
   oFolder:aDialogs[1]:SetFocus()
   lRet    := .F.
EndIf

If lRet .And. ! A903AvalRateio()
   oFolder:SetOption(1)
   oFolder:aDialogs[1]:SetFocus()
   lRet    := .F.
EndIf

If lRet .And. ! A903AvalVend()
   oFolder:SetOption(1)
   oFolder:aDialogs[1]:SetFocus()
   lRet    := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA903   บAutor  ณPaulo Carnelossi    บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para nao permitir excluir grades da linha qdo        บฑฑ
ฑฑบ          ณrotina de Exclusao / Visualizacao                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A903Del()
Return(!lVisualBXL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA903VendEquipeบAutor  ณPaulo Carnelossiบ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclui um Vendedor no cadastro padrao SA3-Vendedores para   บฑฑ
ฑฑบ          ณrepresentar a equipe                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A903VendEquipe(cVendedor)
Local aCabec    := {}
PRIVATE lMsErroAuto := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Verifica o ultimo vendedor                                   |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SA3")
dbSetOrder(1)
MsSeek(xFilial("SA3")+"zzzzzz",.T.)
dbSkip(-1)
cVendedor := Soma1(SA3->A3_COD)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Teste de Inclusao                                            |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCabec := {}
aadd(aCabec,{"A3_COD"   ,cVendedor,})
aadd(aCabec,{"A3_NOME" ,M->BXL_DESEQU,})
MATA040(aCabec)
Return(!lMsErroAuto)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA903   บAutor  ณPaulo Carnelossi    บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Alteracao do Cadastro de Vendedor (SA3) para  a   บฑฑ
ฑฑบ          ณequipe de vendas correspondente                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL903AVen()
dbSelectArea("SA3")
If dbSeek(xFilial("SA3")+BXL->BXL_CODVEN)
   SA3->(AxAltera("SA3",SA3->(Recno()),K_Alterar))
EndIf
dbSelectArea("BXL")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL903AVig บAutor  ณPaulo Carnelossi    บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Alteracao o termino da vigencia da regra          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL903AVig(cAlias,nReg,nOpc)
Local nOpca 		:= 0
Local aSays 		:= {}, aButtons := {}
Local cCadastro   := STR0024 //"Comissoes por Equipe de Vendas"
Local cTitulo     := STR0025 //"Encerramento da Vigencia das Regras de Comissoes por Equipe"
Local cPerg := "PLS903"
Local dDatAnt 
Local bAltDat := {||If(Aviso( STR0026+DTOC(dDatAnt)+STR0027+DTOC(mv_par01),; //"DATA ALTERADA DE "###" PARA "
 									STR0028, ; //"Confirma a data de encerramento da Vigencia ?"
 									{ STR0029, STR0030}, 2 )==1,; //"Sim"###"Nao"
 									 (FechaBatch(),1), 0)}

If !Empty(BXL->BXL_VLDFIM)
   MsgStop(STR0031) //"Registro ja possui termino de validade das regras."

ElseIf Pergunte(cPerg, .T.)
   dDatAnt := mv_par01
   
	AADD(aSays,cTitulo)
	AADD(aSays,"")
	AADD(aSays,BXL->BXL_CODEQU + "-" + BXL->BXL_DESEQU + "   ("+BXL->BXL_SEQ+")"+STR0032+DTOC(mv_par01)) //"     Vigorar Ate: "

	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )    
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(),;
								 If( dDatAnt==mv_par01, FechaBatch(), nOpca:=Eval(bAltDat)),;
								 nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons,, 160 )
	
	IF nOpca == 1
		Processa( { || PL903VigPro(cAlias,nReg,nOpc)},cTitulo,STR0033) //"Processando...."
	Endif
	
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL903VigPro บAutor  ณPaulo Carnelossi  บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Alteracao o termino da vigencia da regra          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL903VigPro(cAlias,nReg,nOpc)
Local nSaveSX8  := MyGetSX8Len()

Local cCodEqu:="", nRecBXL, aDatasVig, nX, dNewVigIni
Local aDadosBXL:={}, aDadosBXM:={}, aDadosBXJ:={}, aDadosBXK:={}
Local aAuxBXM, aAuxBXJ, aAuxBXK
Local aRecBXL := {}, aRecBXM := {}, aRecBXj := {}, aRecBXK := {}
Local nSeqBXL, nNewRec := 0
Local nAuxSeq

nRecBXL   := BXL->(Recno())
cCodEqu   := BXL->BXL_CODEQU
   
aDatasVig := {}
dbSelectArea("BXL")
dbSetOrder(1)
dbSeek(xFilial("BXL")+cCodEqu)
While BXL->(!Eof() .And. BXL_FILIAL == xFilial("BXL") .And. ;
   				BXL_CODEQU == cCodEqu)
   If BXL->(Recno()) <> nRecBXL
   	aAdd(aDatasVig, {BXL->BXL_VLDINI, BXL->BXL_VLDFIM})
   Else
   	aAdd(aDatasVig, {BXL->BXL_VLDINI, mv_par01})
   EndIf	
   BXL->(dbSkip())
End
   				
dbSelectArea("BXL")
dbGoto(nRecBXL)
dNewVigIni := mv_par01+1
   
If AvFaixaData(dNewVigIni, CTOD(Space(8)), aDatasVig)

   //EQUIPE
   For nX := 1 TO FCOUNT()
   	aAdd(aDadosBXL, { FieldName(nX), FieldGet(nX) })
   Next
   aAdd(aRecBXL, BXL->(Recno()))

   //COMPOSICAO DA EQUIPE
   dbSelectArea("BXM")
   dbSetOrder(1)
   dbSeek(xFilial("BXM")+BXL->BXL_SEQ)
   While BXM->(! Eof() .And. BXM_FILIAL == xFilial("BXM") .And. ;
      				BXM_SEQBXL == BXL->BXL_SEQ )
   	aAuxBXM := {}			
   	For nX := 1 TO FCOUNT()
   		aAdd(aAuxBXM, { FieldName(nX), FieldGet(nX) })
   	Next
   	aAdd(aDadosBXM, aAuxBXM)
   	aAdd(aRecBXM, BXM->(Recno()))
   	BXM->(dbSkip())
   End

   //REGRAS DA EQUIPE E POR EQUIPE/VENDEDOR
   dbSelectArea("BXJ")
   dbSetOrder(2)
   dbSeek(xFilial("BXJ")+BXL->BXL_SEQ)
   While BXJ->(! Eof() .And. BXJ_FILIAL == xFilial("BXJ") .And. ;
      				BXJ_SEQBXL == BXL->BXL_SEQ )
   	aAuxBXJ := {}			
   	For nX := 1 TO FCOUNT()
   		aAdd(aAuxBXJ, { FieldName(nX), FieldGet(nX) })
   	Next
   	aAdd(aDadosBXJ,aAuxBXJ)
   	aAdd(aRecBXJ, BXJ->(Recno()))
     	BXJ->(dbSkip())
   End
   
   dbSelectArea("BXJ")
   dbSetOrder(1)
      
   //ITENS DAS REGRAS DA EQUIPE E POR EQUIPE/VENDEDOR
   dbSelectArea("BXK")
   dbSetOrder(2)
      
   dbSeek(xFilial("BXK")+BXL->BXL_SEQ)
   While BXK->(! Eof() .And. BXK_FILIAL == xFilial("BXK") .And. ;
      				BXK_SEQBXL == BXL->BXL_SEQ )
    	aAuxBXK := {}
   	For nX := 1 TO FCOUNT()
   		aAdd(aAuxBXK, { FieldName(nX), FieldGet(nX) })
   	Next
   	aAdd(aDadosBXK,aAuxBXK)
   	aAdd(aRecBXK, BXK->(Recno()))
   	
      BXK->(dbSkip())
   End
   dbSelectArea("BXK")
   dbSetOrder(1)
      
	If mv_par02 == 1
	   //Renumerar sequencial BXL
	   dbSelectArea("BXL")
	   dbSetOrder(2)
	
	   nSeqBXL := GetSx8Num("BXL","BXL_SEQ",,2)
	      
	   While dbSeek(xFilial("BXL")+nSeqBXL)
	   	nSeqBXL := GetSx8Num("BXL","BXL_SEQ",,2)
	   End
		While ( MyGetSX8Len() > nSaveSX8 )  
			ConfirmSX8()
		EndDo
	   //Acerta o sequencial do BXL em todos os arrays
	   a903Ac_Array(aDadosBXL, "BXL_SEQ"	, nSeqBXL, "BXL")
	   a903Ac_Array(aDadosBXM, "BXM_SEQBXL", nSeqBXL, "BXM")
	   a903Ac_Array(aDadosBXJ, "BXJ_SEQBXL", nSeqBXL, "BXJ")
	   a903Ac_Array(aDadosBXK, "BXK_SEQBXL", nSeqBXL, "BXK")
	
	   //voltar para ambiente anterior
	   dbSelectArea("BXL")
	   dbSetOrder(1)
	   dbGoto(aRecBXL[1])  //somente vai existir um BXL
	      
	   //Renumerar sequencial BXJ --> BXK
	   If Len(aDadosBXJ) > 0
	   	dbSelectArea("BXJ")
	   	dbSetOrder(3)
	      	
	   	For nX := 1 TO Len(aDadosBXJ)
	      	   
	   	   nSeqBXJ := GetSx8Num("BXJ","BXJ_SEQ",,3)
	      
	      	While dbSeek(xFilial("BXJ")+nSeqBXJ)
	   	   	nSeqBXJ := GetSx8Num("BXJ","BXJ_SEQ",,3)
	      	End
				While ( MyGetSX8Len() > nSaveSX8 )
					ConfirmSX8()
				EndDo 
	
	      	//Acerta o sequencial do BXJ em todos os arrays
	      	nAuxSeq := NIL
	      	a903Ac_Array(aDadosBXJ, "BXJ_SEQ"	, nSeqBXJ, "BXJ", nX, @nAuxSeq)
	      	a903Ac_Array(aDadosBXK, "BXK_SEQBXJ", nSeqBXJ, "BXK", nX, nAuxSeq)
	   	Next   
	      
	      dbSelectArea("BXJ")
	      dbSetOrder(1)
	      dbGoto(aRecBXJ[1])  // voltar para primeiro BXJ
	
	   EndIf
	      
	   //Copia das regras de comissoes por equipe
	   a903Copia(aDadosBXL, aDadosBXM, aDadosBXJ, aDadosBXK, dNewVigIni, @nNewRec)
	   
	EndIf

	//Colocar validade final nos registros encontrados (BXM/BXK nao e Necessario)
	dbSelectArea("BXL")
	dbGoto(nRecBXL)
	A903VldFim(aRecBXL, mv_par01, "BXL_VLDFIM", "BXL")
	A903VldFim(aRecBXJ, mv_par01, "BXJ_VLDFIM", "BXJ")
	
	If mv_par03 == 1  .And. nNewRec > 0 //Editar a Copia
	   dbSelectArea("BXL")
	   dbGoto(nNewRec)
	   PL903AMov("BXL",BXL->(Recno()),K_Alterar)
	EndIf
	   
Else

 	MsgStop(STR0034) //"Vigencia nao Efetuada - Verifique a data informada!"
   
EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL903Copy บAutor  ณPaulo Carnelossi    บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Alteracao o termino da vigencia da regra          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL903Copy(cAlias,nReg,nOpc)

Local nRecBXL, aDatasVig, nX, dNewVigIni
Local dUltVig := CtoD(Space(8)), nRecTermina := 0

Local nOpca 		:= 0
Local aSays 		:= {}, aButtons := {}
Local cCadastro   := STR0035 //"Regras de Comissoes por Equipe de Vendas"
Local cTitulo     := STR0036 //"Copia de Regras de Comissoes por Equipe"

If Empty(BXL->BXL_VLDFIM)
   MsgStop(STR0037) //"Registro nao possui termino de validade das regras de comissoes por equipe."

Else

   nRecBXL   := BXL->(Recno())
   cCodEqu   := BXL->BXL_CODEQU
   
   aDatasVig := {}
   dbSelectArea("BXL")
   dbSetOrder(1)
   dbSeek(xFilial("BXL")+cCodEqu)
   While BXL->(!Eof() .And. BXL_FILIAL == xFilial("BXL") .And. ;
   				BXL_CODEQU == cCodEqu)
	   aAdd(aDatasVig, {BXL->BXL_VLDINI, BXL->BXL_VLDFIM, BXL->(Recno())})
   	BXL->(dbSkip())
	End   				
   dbSelectArea("BXL")
   dbGoto(nRecBXL)
   
   For nX := 1 TO Len(aDatasVig)
   	If Empty(aDatasVig[nX][2])
   	   dUltVig  := dDataBase-1
   	   nRecTermina := aDatasVig[nX][3]
   	   If aDatasVig[nX][1] > dUltVig
   	   	dUltVig := aDatasVig[nX][1]
   	   EndIf
   	   aDatasVig[nX][2] 	:= dUltVig
			If Aviso( STR0038,; //"Atencao"
						STR0039, ; //"Nao permitido efetuar copia, pois existem regras com vigencia em aberto! Posicionar na regra com vigencia em aberto ?"
 						{ STR0029, STR0030}, 2 )==1   	    //"Sim"###"Nao"
   	   			dbGoto(nRecTermina)
   	   EndIf			
         Return
   	Else
   	   If aDatasVig[nX][2] > dUltVig
   	      dUltVig := aDatasVig[nX][2]
   	      nRecTermina := aDatasVig[nX][3]
   	   EndIf
   	EndIf      
   Next
   dNewVigIni := dUltVig + 1
   
   If AvFaixaData(dNewVigIni, CTOD(Space(8)), aDatasVig)
      //solicitar confirmacao do Usuario
	 	AADD(aSays,cTitulo)
		AADD(aSays,"")
		AADD(aSays,BXL->BXL_CODEQU + "-" + BXL->BXL_DESEQU + "   ("+BXL->BXL_SEQ+")"+STR0040+DTOC(dNewVigIni)) //"     Vigorar a partir de: "

		AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(),FechaBatch(),nOpca:=0 ) }} )
		AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
		FormBatch( cCadastro, aSays, aButtons,, 160 )
	
		IF nOpca == 1
			Processa( { || A903ProCopy(nRecBXL,dNewVigIni, dUltVig, nRecTermina)},cTitulo,STR0033) //"Processando...."
		Else 
			MsgStop(STR0041) //"Copia nao Efetuada..."
			Return
		EndIf	

   Else
   	MsgStop(STR0042) //"Copia nao Efetuada - Verifique a data informada!"

   EndIf

EndIf   	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA903ProCopy บAutor  ณPaulo Carnelossi  บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de copia da regra de comissao por equipe de vendas   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A903ProCopy(nRecBXL,dNewVigIni, dUltVig, nRecTermina)
Local nSaveSX8  := MyGetSX8Len()
Local  nX 
Local aDadosBXL:={}, aDadosBXM:={}, aDadosBXJ:={}, aDadosBXK:={}
Local aAuxBXM, aAuxBXJ, aAuxBXK
Local aRecBXL := {}, aRecBXM := {}, aRecBXj := {}, aRecBXK := {}
Local nSeqBXL
Local nNewRec := 0
Local nAuxSeq

//EQUIPE
For nX := 1 TO FCOUNT()
	aAdd(aDadosBXL, { FieldName(nX), FieldGet(nX) })
Next
aAdd(aRecBXL, BXL->(Recno()))

//COMPOSICAO DA EQUIPE
dbSelectArea("BXM")
dbSetOrder(1)
dbSeek(xFilial("BXM")+BXL->BXL_SEQ)
While BXM->(! Eof() .And. BXM_FILIAL == xFilial("BXM") .And. ;
	BXM_SEQBXL == BXL->BXL_SEQ )
	aAuxBXM := {}
	For nX := 1 TO FCOUNT()
		aAdd(aAuxBXM, { FieldName(nX), FieldGet(nX) })
	Next
	aAdd(aDadosBXM, aAuxBXM)
	aAdd(aRecBXM, BXM->(Recno()))
	BXM->(dbSkip())
End

//REGRAS DA EQUIPE E POR EQUIPE/VENDEDOR
dbSelectArea("BXJ")
dbSetOrder(2)
dbSeek(xFilial("BXJ")+BXL->BXL_SEQ)
While BXJ->(! Eof() .And. BXJ_FILIAL == xFilial("BXJ") .And. ;
	BXJ_SEQBXL == BXL->BXL_SEQ )
	aAuxBXJ := {}
	For nX := 1 TO FCOUNT()
		aAdd(aAuxBXJ, { FieldName(nX), FieldGet(nX) })
	Next
	aAdd(aDadosBXJ,aAuxBXJ)
	aAdd(aRecBXJ, BXJ->(Recno()))
	BXJ->(dbSkip())
End
dbSelectArea("BXJ")
dbSetOrder(1)

//ITENS DAS REGRAS DA EQUIPE E POR EQUIPE/VENDEDOR
dbSelectArea("BXK")
dbSetOrder(2)

dbSeek(xFilial("BXK")+BXL->BXL_SEQ)
While BXK->(! Eof() .And. BXK_FILIAL == xFilial("BXK") .And. ;
	BXK_SEQBXL == BXL->BXL_SEQ )
	aAuxBXK := {}
	For nX := 1 TO FCOUNT()
		aAdd(aAuxBXK, { FieldName(nX), FieldGet(nX) })
	Next
	aAdd(aDadosBXK,aAuxBXK)
	aAdd(aRecBXK, BXK->(Recno()))
	
	BXK->(dbSkip())
End
dbSelectArea("BXK")
dbSetOrder(1)

//Renumerar sequencial BXL
dbSelectArea("BXL")
dbSetOrder(2)

nSeqBXL := GetSx8Num("BXL","BXL_SEQ",,2)

While dbSeek(xFilial("BXL")+nSeqBXL)
	nSeqBXL := GetSx8Num("BXL","BXL_SEQ",,2)
End
While ( MyGetSX8Len() > nSaveSX8 )
	ConfirmSX8()
EndDo
//Acerta o sequencial do BXL em todos os arrays
a903Ac_Array(aDadosBXL, "BXL_SEQ"	, nSeqBXL, "BXL")
a903Ac_Array(aDadosBXM, "BXM_SEQBXL", nSeqBXL, "BXM")
a903Ac_Array(aDadosBXJ, "BXJ_SEQBXL", nSeqBXL, "BXJ")
a903Ac_Array(aDadosBXK, "BXK_SEQBXL", nSeqBXL, "BXK")

//voltar para ambiente anterior
dbSelectArea("BXL")
dbSetOrder(1)
dbGoto(nRecBXL)

//Renumerar sequencial BXJ --> BXK
If Len(aDadosBXJ) > 0
	dbSelectArea("BXJ")
	dbSetOrder(3)
	
	For nX := 1 TO Len(aDadosBXJ)
		
		nSeqBXJ := GetSx8Num("BXJ","BXJ_SEQ",,3)
		
		While dbSeek(xFilial("BXJ")+nSeqBXJ)
			nSeqBXJ := GetSx8Num("BXJ","BXJ_SEQ",,3)
		End
		While ( MyGetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
		
		//Acerta o sequencial do BXJ em todos os arrays
		nAuxSeq := NIL
		a903Ac_Array(aDadosBXJ, "BXJ_SEQ"	, nSeqBXJ, "BXJ", nX, @nAuxSeq )
		a903Ac_Array(aDadosBXK, "BXK_SEQBXJ", nSeqBXJ, "BXK", nX, nAuxSeq)
	Next
	
	dbSelectArea("BXJ")
	dbSetOrder(1)
	dbGoto(aRecBXJ[1])  // voltar para primeiro BXJ
	
EndIf

//Copia das regras de comissoes por equipe
a903Copia(aDadosBXL, aDadosBXM, aDadosBXJ, aDadosBXK, dNewVigIni, @nNewRec)

/*
//nao e mais necessario, pois nao deixa mais copiar com data vigencia em aberto
//Colocar validade final nos registros encontrados (BXM nao e Necessario)
If nRecTermina > 0
	dbSelectArea("BXL")
	dbGoto(nRecTermina)

	//REGRAS DA EQUIPE E POR EQUIPE/VENDEDOR
	aAuxRecBXJ := {}

	dbSelectArea("BXJ")
	dbSetOrder(2)
	dbSeek(xFilial("BXJ")+BXL->BXL_SEQ)
	While BXJ->(! Eof() .And. BXJ_FILIAL == xFilial("BXJ") .And. ;
	BXJ_SEQBXL == BXL->BXL_SEQ )
		aAdd(aAuxRecBXJ, BXJ->(Recno()))
		BXJ->(dbSkip())
	End
	dbSelectArea("BXJ")
	dbSetOrder(1)

	//nao e mais necessario, pois nao deixa mais copiar com data vigencia em aberto
	If Empty(BXL->BXL_VLDFIM)
		A903VldFim({nRecTermina}, dUltVig, "BXL_VLDFIM", "BXL")
		A903VldFim(aAuxRecBXJ, dUltVig, "BXJ_VLDFIM", "BXJ")
	EndIf
EndIf
*/

dbSelectArea("BXL")
dbGoto(nNewRec)
PL903AMov("BXL",BXL->(Recno()),K_Alterar)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณa903acertaCpo บAutor  ณPaulo Carnelossi บ Data ณ  19/05/04  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para acertar campo em todos os Acols                 บฑฑ
ฑฑบ          ณcomo por exemplo sequencial bxl em todos os arquivos envolv.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a903acertaCpo(oBrowse, cCampo, uValor)
Local nX

If ValType(oBrowse) == "O"
	For nX := 1 TO Len(oBrowse:aCols)
		oBrowse:FieldPut(cCampo,uValor,nX)
	Next
EndIf

Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa903Ac_ArrayบAutor ณPaulo Carnelossi   บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Acerto do array de dados  para usar na copia      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a903Ac_Array(aArray, cCampo, uValor, cAlias, nElem, uValAnt)
Local nX, lCompara := (nElem <> NIL)
Local nPosCpo := 0
Local nZ

If ValType(aArray) == "A"  .And. Len(aArray) > 0
	If cAlias == "BXL"
		nPosCpo := ASCAN(aArray,{|aVal| aVal[1] == cCampo})
	Else
		If Len(aArray[1]) > 0
			nPosCpo := ASCAN(aArray[1],{|aVal| aVal[1] == cCampo})
		EndIf	
	EndIf
EndIf
	
If nPosCpo > 0
   If cAlias == "BXL"
   	aArray[nPosCpo][2] := uValor	
   Else
   	If lCompara .And. uValAnt == NIL
   	   If Len(aArray) >= nElem .And. Len(aArray[nElem]) > 0
	   		uValAnt := aArray[nElem][nPosCpo][2]
	   	EndIf	
   	EndIf	
	   For nZ := 1 TO Len(aArray)
	      If Len(aArray[nZ]) > 0
	      	If lCompara
	      		If uValAnt != NIL .And. aArray[nZ][nPosCpo][2] == uValAnt // qdo passado elemento 
	   				aArray[nZ][nPosCpo][2] := uValor  //compara com valor anterior
	   			EndIf	
	   		Else
	   			aArray[nZ][nPosCpo][2] := uValor
	   		EndIf	
	   	EndIf
	   Next
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA903VldFim  บAutor ณPaulo Carnelossi   บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de gravacao da data fim nos arquivos de dados        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A903VldFim(aArray, uValor, cCampo, cAlias)
Local nPosCpo, nX, cAliasAnt := ALIAS()

dbSelectArea(cAlias)
nPosCpo := FieldPos(cCampo)

If nPosCpo > 0 .And. Len(aArray) > 0
   For nX := 1 TO Len(aArray)
	   dbGoto(aArray[nX])
	   RecLock(cAlias, .F.)
	   FieldPut(nPosCpo, uValor)
	   MsUnLock()
	Next
EndIf
dbSelectArea(cAliasAnt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa903Copia   บAutor ณPaulo Carnelossi   บ Data ณ  19/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de copia da tabela original para novas regras de     บฑฑ
ฑฑบ          ณcomissao por equipe de vendas                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a903Copia(aDadosBXL, aDadosBXM, aDadosBXJ, aDadosBXK, dNewVig, nNewRec) 
Local nX, nZ

dbSelectArea("BXL")
RecLock("BXL", .T.)
nNewRec := BXL->(Recno())
For nX := 1 TO FCount()
	If aDadosBXL[nX][1] == "BXL_VLDINI"
		FieldPut(nX, dNewVig)     
	ElseIf aDadosBXL[nX][1] == "BXL_VLDFIM"
		FieldPut(nX, CtoD(Space(8)))
	Else
		FieldPut(nX, aDadosBXL[nX][2])
	EndIf	
Next
MsUnLock()  


dbSelectArea("BXM")
For nZ := 1 TO LEN(aDadosBXM)
	RecLock("BXM", .T.)
	For nX := 1 TO FCount()
	    FieldPut(nX, aDadosBXM[nZ][nX][2])
	Next
	MsUnLock()  
Next	

dbSelectArea("BXJ")
For nZ := 1 TO LEN(aDadosBXJ)
	RecLock("BXJ", .T.)
	For nX := 1 TO FCount()
		If aDadosBXJ[nZ][nX][1] == "BXJ_VLDINI"
			FieldPut(nX, dNewVig)     
		ElseIf aDadosBXJ[nZ][nX][1] == "BXJ_VLDFIM"
			FieldPut(nX, CtoD(Space(8)))
		Else
	   	FieldPut(nX, aDadosBXJ[nZ][nX][2])
	   EndIf 
	Next
	MsUnLock()  
Next	

dbSelectArea("BXK")
For nZ := 1 TO LEN(aDadosBXK)
	RecLock("BXK", .T.)
	For nX := 1 TO FCount()
	    FieldPut(nX, aDadosBXK[nZ][nX][2])
	Next
	MsUnLock()  
Next	

Return

//----------------------------------------------------------------------------------//

#define QTDINI 1
#define QTDFIM 2
#define DATINI 3
#define DATFIM 4

Function PLSAvFaixaDatNum(nNewElem1, nNewElem2, dNewElem1, dNewElem2, aElemExistente)
Local nCtd, lRet := .F.
Local aNum := {}
Local aDat := {}
//Estrutura do array aElemExistente
//Elemento [x][1] == Numero Inicial
//Elemento [x][2] == Numero Final
//Elemento [x][3] == Data Inicial
//Elemento [x][4] == Data Final

For nCtd := 1 TO Len(aElemExistente)
	aAdd(aNum, {aElemExistente[nCtd][QTDINI],aElemExistente[nCtd][QTDFIM]})
Next

lRet := AvFaixaNum(nNewElem1, nNewElem2, aNum, @lErro)

If ! lErro .And. ! lRet 
   aDatAux 	:= RecFaixaNum(nNewElem1, nNewElem2, aElemExistente)
	For nCtd := 1 TO Len(aDatAux)
		aAdd(aDat, {aDatAux[nCtd][DATINI], aDatAux[nCtd][DATFIM]})
	Next
   lRet 		:= AvFaixaData(dNewElem1, dNewElem2, aDat)
EndIf

Return(lRet)   

//----------------------------------------------------------------------------------//
Function RecFaixaNum(nNewElem1, nNewElem2, aNum)
Local nCtd, nInicio, nFim, aRecNum := {}

For nCtd := 1 TO Len(aNum)
	nInicio	:= aNum[nCtd][QTDINI]
	nFim		:= aNum[nCtd][QTDFIM]
	dInicio  := aNum[nCtd][DATINI]
	dFim     := aNum[nCtd][DATFIM]
	
	//avalia elemento 1
	If nNewElem1 >= nInicio .And. ;
		nNewElem1 <= nFim
		aAdd(aRecNum, {nInicio, nFim, dInicio, dFim})
		LOOP
	EndIf	

	//avalia elemento 2
	If nNewElem2 >= nInicio .And. ;
		nNewElem2 <= nFim
		aAdd(aRecNum, {nInicio, nFim, dInicio, dFim})
		LOOP
	EndIf	
Next

Return(aRecNum)

//----------------------------------------------------------------------------------//
Function AvFaixaNum(nNewElem1, nNewElem2, aElemExistente, lErro)
Local nInicio, nFim, nCtd, nAnterior := 0
Local lRet := .T.

DEFAULT lErro := .F.

If nNewElem1 > nNewElem2
   MsgStop(STR0043) //"Erro: Numero inicial maior que numero final!"
   lErro := .T.
   lRet := .F.
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		//avalia se todos os elementos sao numericos
		If Valtype(aElemExistente[nCtd][1]) != "N" .OR. ;
	    	Valtype(aElemExistente[nCtd][2]) != "N"
	    	MsgStop(STR0044) //"Erro: Array enviado contem elemento nao numerico!"
   		lErro := .T.
   	   lRet := .F.
	    	EXIT
	   EndIf
	   // avalia se elemento inicial e maior que anterior e neste caso
	   // atribui a nAnterior o segundo elemento
	   // senao esta errado - avisa usuario e sai
	   If aElemExistente[nCtd][1] > nAnterior
			nAnterior := aElemExistente[nCtd][2]
		Else	
	    	MsgStop(STR0045) //"Erro: Elemento inicial menor que o anterior!"
	    	lErro := .T.
	    	lRet := .F.
	    	EXIT
		EndIf	
	Next
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		nInicio	:= aElemExistente[nCtd][1]
		nFim		:= aElemExistente[nCtd][2]
		//avalia elemento 1
		If nNewElem1 >= nInicio .And. ;
			nNewElem1 <= nFim
			lRet := .F.
			EXIT
		EndIf	
		//avalia elemento 2
		If nNewElem2 >= nInicio .And. ;
			nNewElem2 <= nFim
			lRet := .F.
			EXIT
		EndIf	
	Next
EndIf

Return(lRet)

//----------------------------------------------------------------------------------//

Function AvFaixaData(dNewElem1, dNewElem2, aElemExistente, lErro)
Local dInicio, dFim, nCtd, dAnterior := CtoD(Space(8))
Local lRet := .T.

DEFAULT lErro := .F.

If Empty(dNewElem2)
	dNewElem2 := CTOD("31/12/49")
EndIf

If dNewElem1 > dNewElem2
   MsgStop(STR0046) //"Erro: Data inicial maior que Data final!"
   lErro := .T.
   lRet := .F.
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		//avalia se todos os elementos sao datas
		If Valtype(aElemExistente[nCtd][1]) != "D" .OR. ;
	    	If(EMPTY(aElemExistente[nCtd][2]),.F.,Valtype(aElemExistente[nCtd][2]) != "D")
	    	MsgStop(STR0047) //"Erro: Array enviado contem elemento que nao e data!"
	    	lErro := .T.
	    	lRet := .F.
	    	EXIT
	   EndIf
	   // avalia se elemento inicial e maior que anterior e neste caso
	   // atribui a nAnterior o segundo elemento
	   // senao esta errado - avisa usuario e sai
	   If nCtd > 1 
		   If aElemExistente[nCtd][1] > dAnterior
				dAnterior := aElemExistente[nCtd][2]
			Else	
		    	MsgStop(STR0048) //"Erro Array: Elemento inicial menor que o anterior!"
		    	lErro := .T.
		    	lRet := .F.
		    	EXIT
			EndIf	
		EndIf
	Next
EndIf
	
If lRet
	For nCtd := 1 TO Len(aElemExistente)
		dInicio	:= aElemExistente[nCtd][1]
		If EMPTY(aElemExistente[nCtd][2])
		   dFim  	:= CTOD("31/12/49")
		Else
			dFim		:= aElemExistente[nCtd][2]
		EndIf	
		//avalia elemento 1
		If dNewElem1 >= dInicio .And. ;
			dNewElem1 <= dFim
			lRet := .F.
			EXIT
		EndIf	
		//avalia elemento 2
		If dNewElem2 >= dInicio .And. ;
			dNewElem2 <= dFim
			lRet := .F.
			EXIT
		EndIf	
	Next
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA903NumBXJบAutor  ณMicrosiga           บ Data ณ  05/27/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao utilizada para numeracao automatica em x3_relacao do บฑฑ
ฑฑบ          ณcampo BXJ_SEQ                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A903NumBXJ(aNumBXJ, lSeqNew)
Local cNumBXJ := ""
DEFAULT aNumBXJ := {}

If lSeqNew
	cNumBXJ := ""
Else
	cNumBXJ := GetSx8Num("BXJ","BXJ_SEQ",,3)
	aAdd(aNumBXJ, cNumBXJ)
EndIf

Return(cNumBXJ)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA903AvalRateio บAutor ณPaulo Carnelossiบ Data ณ  28/05/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para verificar na validacao tudo OK se rateio e igualบฑฑ
ฑฑบ          ณa 0 (zero) ou 100 %                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A903AvalRateio()
Local lRet := .F.
Local nX, aPercent := {}
Local cGruRat

For nX := 1 TO Len(oBrwBXM:aCols)
	If ! oBrwBXM:IsDeleted(nX)                         
        If BXM->(FieldPos("BXM_GRURAT")) > 0
           cGruRat := oBrwBXM:FieldGet("BXM_GRURAT",nX)
         Else
           cGruRat := "   "
        EndIf
	    nInd := aScan(aPercent, { |x| x[1] == cGruRat })
	    If nInd == 0
	       aAdd(aPercent, { cGruRat, 0 })
	       nInd := Len(aPercent)
	    EndIf
		aPercent[nInd, 2] += oBrwBXM:FieldGet("BXM_RATEIO",nX)
	EndIf	
Next
                                 
For nX := 1 To Len(aPercent)
	If aPercent[nX, 2] == 0 .Or. aPercent[nX, 2] == 100
		lRet := .T.
	Else
		MsgStop(STR0049) //"Percentuais de rateio devem atingir 100% para cada Grupo de Rateio. Verificar!"
		lRet := .F.
		Exit
	EndIf
Next nX

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA903AvalVend   บAutor ณPaulo Carnelossiบ Data ณ  28/05/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para verificar na validacao tudo OK se vendedor levarบฑฑ
ฑฑบ          ณcomissao para superior deve ter supervisor informado        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A903AvalVend()
Local lRet := .F.
Local nX, nSupervisor := 0, nComSup := 0, nVendedor := 0, nPerSup := 0

For nX := 1 TO Len(oBrwBXM:aCols)
	If ! oBrwBXM:IsDeleted(nX)
	   
	   If oBrwBXM:FieldGet("BXM_ID_VEN",nX) == "2"
			nSupervisor++
		Else
			nVendedor++
		EndIf	
		
		If oBrwBXM:FieldGet("BXM_COMSUP",nX) == "1"
			nComSup++
			nPerSup += oBrwBXM:FieldGet("BXM_PERSUP",nX)
		EndIf	

	EndIf	
Next

If (nVendedor > 0 .And. nComSup > 0 .And. nSupervisor > 0 .And. nPerSup > 0) .OR. nComSup == 0
	lRet := .T.
Else
	MsgStop(STR0050) //"Supervisor/vendedor/percentual deve ser informado quando informado que comissao / superior. verificar!"
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMyGetSX8Len บAutor  ณMicrosiga         บ Data ณ  05/27/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada na confirmacao do numero SX8               บฑฑ
ฑฑบ          ณna Versao 811 -- mudar para padrao GETSX8LEN()              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyGetSX8Len()
Local nMax
DEFAULT __aKeys := {}
nMax := Max(Len(aSX8),Len(__aKeys))
Return(nMax)

Static Function A903Numera(oBrowse,lMembro)
Local lRet := .T.

If Empty(oBrowse:FieldGet("BXJ_SEQ",oBrowse:Linha()))
	oBrowse:FieldPut("BXJ_SEQ",A903NumBXJ(aNumBXJ, .F.),oBrowse:Linha())
	oBrowse:Atualiza()
	If lMembro
		oBrwBXKMEM:Atualiza()
		oBrwBXKMEM:oBrowse:Refresh()
	Else
		oBrwBXK:Atualiza()
		oBrwBXK:oBrowse:Refresh()
   EndIf
EndIf

Return(lRet)


Function A903ValPer()
Local lRet := .F.
lRet := (M->BXK_PERCON > 0 .AND. M->BXK_VALCON == 0) .OR. (M->BXK_VALCON > 0 .AND. M->BXK_PERCON == 0)

If ! lRet
	MsgStop(STR0051) //"Valor ou percentual de comissao deve ser informado!"
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL903SA3  บAutor  ณAngelo              บ Data ณ  10/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para verificar se o vendedor perntece a equipe       บฑฑ
ฑฑบ          ณna data da inclusao                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PL903SA3(_cCampo)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega campos conforme o alias informado                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cEquipe := ""
Local dData   := ""
Local _cAlias := substr(_cCampo,4,3)

If ! SA3->(ExistCpo("SA3",&(_cCampo),1))
        &(_cCampo) := Space(06)
        lRefresH := .t.
           Return(.F.)
Endif      

Do Case
   Case _cAlias == "BA3"
        cEquipe := M->BA3_EQUIPE
        dData   := M->BA3_DATBAS
   Case _cAlias == "BA1"
        cEquipe := M->BA1_EQUIPE
        dData   := IIf(Empty(M->BA1_DATINC), dDataBase, M->BA1_DATINC)
   Case _cAlias == "BQC"
        cEquipe := M->BQC_EQUIPE
        dData   := M->BQC_DATCON
EndCase
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se nao recebeu Equipe/Data, lista todos os vendedores               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If  empty(cEquipe) .or. empty(dData)
    Return(.T.)
Endif      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o vendedor pertence a equipe na data informada          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BXL->(dbSetOrder(1))
BXL->(dbSeek(xFilial("BXL")+cEquipe+"ZZZZZZZZ",.T.))
BXL->(dbSkip(-1))
While ! BXL->(bof()) .and. BXL->BXL_FILIAL == xFilial("BXL") .and. BXL->BXL_CODEQU == cEquipe
   If  dData >= BXL->BXL_VLDINI .and. ;
      (empty(BXL->BXL_VLDFIM) .or. dData <= BXL->BXL_VLDFIM)
       BXM->(dbSetOrder(1))
       If  BXM->(dbSeek(xFilial("BXM")+BXL->BXL_SEQ+&(_cCampo)))
           Return(.T.)
       Else
           help(" ",1,"PL903SA3")
           &(_cCampo) := Space(06)
           Return(.F.)
       Endif
   Endif
   BXL->(dbSkip(-1))
End
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se chegou ate aqui, eh porque o vendedor nao pertence a equipe      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
help(" ",1,"PL903SA3")
&(_cCampo) := Space(06)
Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณPL903Reab ณ Autor ณ Sandro Hoffman Lopes  ณ Data ณ 08.09.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Reabre a vigencia de uma equipe.                           ณฑฑ
ฑฑณ          ณ Somente permite reabrir a vigencia caso nao haja outra     ณฑฑ
ฑฑณ          ณ vigencia em aberto e seja a ultima vigencia cadastrada     ณฑฑ
ฑฑณ          ณ para a equipe. BOPS 101909                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณPL903Reab(cAlias,nReg,nOpc,,lMsg)                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PL903Reab(cAlias,nReg,nOpc,aCampos,lMsg)

	Local aSavArea, lProc
	Default lMsg := .T.
	
	If Empty(BXL->BXL_VLDFIM)
		MsgStop(STR0056, STR0038) // "Equipe jแ se encontra com a vigencia em aberto"###"Aten็ใo"
	Else
	    aSavArea := {}
        aAdd(aSavArea, { BXL->(IndexOrd()), BXL->(RecNo()), BXL->(BXL_FILIAL+BXL_CODEQU) })
        BXL->(DbSetOrder(1))
        BXL->(DbSkip())
        If ! BXL->(Eof()) .And. BXL->(BXL_FILIAL+BXL_CODEQU) == aSavArea[1, 3]
        	If Empty(BXL->BXL_VLDFIM)
	        	MsgStop(STR0057, STR0038) // "Jแ existe uma vig๊ncia em aberto para esta equipe"###"Aten็ใo"
	        Else
	        	MsgStop(STR0058, STR0038) // "Somente a ๚ltima vig๊ncia da equipe pode ser reaberta"###"Aten็ใo"
	        EndIf
	    Else
			If lMsg
				If MsgYesNo(STR0059, STR0038) //"Confirma a reabertura desta vig๊ncia?"###"Aten็ใo"
					lProc := .T.
				 Else
				 	lProc := .F.
				EndIf
			Else
				lProc := .T.
			EndIf
			
			If lProc

				BXL->(DbGoTo(aSavArea[1,2]))
   	   			RecLock("BXL", .F.)
				BXL->BXL_VLDFIM := StoD("")
				BXL->(MsUnlock())
  				BXJ->(DbSetOrder(2))
  				If BXJ->(MsSeek(xFilial("BXJ")+BXL->BXL_SEQ, .T.))
  					Do While ! BXJ->(Eof()) .And. BXJ->(BXJ_FILIAL+BXJ_SEQBXL) == xFilial("BXJ")+BXL->BXL_SEQ
  						RecLock("BXJ", .F.)
	  					BXJ->BXJ_VLDFIM := StoD("")
						BXJ->(MsUnlock())
						BXJ->(DbSkip())
					EndDo
				EndIf
				
			EndIf
		EndIf
		BXL->(DbSetOrder(aSavArea[1,1]))
		BXL->(DbGoTo(aSavArea[1,2]))
    EndIf
Return 

//**************************************************************************************//
// Para Retornar o nome do Vendedor posicionado corretamente -Luciano                   //
//**************************************************************************************//

Function PL903DVEN()

Local cDesVen := ""
Local cCodVend:= ""

If Inclui 
	cDesVen := M->BXJ_DESVEN
Else
	
	If ValType(oBrwBXJMEM) = "O"  
		cCodVend := oBrwBXJMEM:aCols[1,GdFieldPos("BXJ_CODVEN",aCabBXJMEM)]		
		
	ElseIf ValType(oBrwBXJMEM) = "U"
	
		cCodVend := BXJ->BXJ_CODVEN
		
	Else
	
		cCodVend := M->BXJ_CODVEN
		
	EndIf
	
	cDesVen := POSICIONE("SA3",1,xFilial("SA3")+cCodVend,"A3_NOME")
	
EndIf

Return(cDesVen)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Darcio R. Sporl       ณ Data ณ08/01/2007ณฑฑ
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
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
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
Private aRotina := {	{ STR0001	,'AxPesqui'		, 0 ,K_Pesquisar	, 0, .F.},; //"Pesquisar"
                   		{ STR0002	,'PL903AMov'	, 0 ,K_Visualizar	, 0, Nil},; //"Visualizar"
             			{ STR0003	,'PL903AMov'	, 0 ,K_Incluir   	, 0, Nil},; //"Incluir"
	      	  			{ STR0004	,'PL903AMov'	, 0 ,K_Alterar   	, 0, Nil},; //"Alterar"
                     	{ STR0005	,'PL903AMov'	, 0 ,K_Excluir   	, 0, Nil},; //"Excluir"
						{ STR0006	,'PL903AVig'	, 0 ,K_Alterar 		, 0, Nil},; //"viG๊ncia"
						{ STR0007	,'PL903Copy'	, 0 ,K_Alterar 		, 0, Nil},; //"C๓pia"
						{ STR0008	,'PL903AVen'	, 0 ,K_Alterar 		, 0, Nil},; //"Cfg.Cad.Vend."
						{ STR0055	,'PL903Reab'	, 0 ,K_Alterar 		, 0, Nil} } //"Reabrir Vig"
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ PL903VldExcณ Autor ณ Microsiga         ณ Data ณ 17/06/2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Processamento da validacao de exclusao de equipes.         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PL903VldExc(cEquipe)
Local bRetEx  := .T.

MSAguarde({|| bRetEx := PLVldExc(cEquipe) },STR0010,STR0033, .F.)

Return bRetEx

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | PLVldExc บAutor  ณMicrosiga           บ Data ณ  06/15/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida exclusao de equipe de vendas. Se houver equipe associบฑฑ
ฑฑบ          ณada ao subcontrato (BQC), famiila (BA3) ou usuแrio (BA1) nใoบฑฑ
ฑฑบ          ณpermite exclusใo.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLVldExc(cEquipe)
Local cAlias := ""
Local cQuery := ""
Local bRetEx := .T.

	cAlias := "QRYBQC"
	cQuery := "SELECT BQC.BQC_EQUIPE "
	cQuery += " FROM "
	cQuery += RetSqlName("BQC")+ " BQC "
	cQuery += " WHERE "
	cQuery += "BQC_FILIAL = '"+xFilial("BQC")+"' AND "
	cQuery += "BQC_EQUIPE = '"+cEquipe+"' AND "
	cQuery += "BQC.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	If !Eof()
		bRetEx := .F.
	EndIf
	
	( cAlias )->( DbCloseArea() )
	
	If bRetEx
		cAlias := "QRYBA3"
		cQuery := "SELECT BA3.BA3_EQUIPE "
		cQuery += " FROM "
		cQuery += RetSqlName("BA3")+ " BA3 "
		cQuery += " WHERE "
		cQuery += "BA3_FILIAL = '"+xFilial("BA3")+"' AND "
		cQuery += "BA3_EQUIPE = '"+cEquipe+"' AND "
		cQuery += "BA3.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
		
		If !Eof()
			bRetEx := .F.
		EndIf
		
		( cAlias )->( DbCloseArea() )
	EndIf
	
	If bRetEx
		
		cAlias := "QRYBA1"
		cQuery := "SELECT BA1.BA1_EQUIPE "
		cQuery += " FROM "
		cQuery += RetSqlName("BA1")+ " BA1 "
		cQuery += " WHERE "
		cQuery += "BA1_FILIAL = '"+xFilial("BA1")+"' AND "
		cQuery += "BA1_EQUIPE = '"+cEquipe+"' AND "
		cQuery += "BA1.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
		
		If !Eof()
			bRetEx := .F.
		EndIf
		
		( cAlias )->( DbCloseArea() )
	EndIf	

Return bRetEx
