#INCLUDE "plsa496.ch"
#Include 'FWMVCDef.ch'
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA496 ³ Autor ³ Tulio Cesar          ³ Data ³ 05.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tipos de Guias                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA496
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := STR0006 //"Tipos de Guias"
PRIVATE cAlias    := "BCL"
PRIVATE cFiltro
PRIVATE aCdCores  := {}
PRIVATE aCores    := {}
Private cCHV446 := ""
Private cCHV444 := ""
Private cCHV446a := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados do aCores...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSMCorCM(aCores,aCdCores,cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtro padrao...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := "@BCL_FILIAL = '"+xFilial("BCL")+"' AND D_E_L_E_T_ = ' '"
BCL->(DbSetOrder(1))
DbSelectArea("BCL")
SET FILTER TO &cFiltro
BCL->(DbSeek(xFilial("BCL")))

BCL->(mBrowse(006,001,022,075,cAlias, , , , , nil, aCores))
BCL->(DbClearFilter())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA496MOV ³ Autor ³ Tulio Cesar       ³ Data ³ 15.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Movimentacao                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA496()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA496MOV(cAlias,nReg,nOpc)

   Static objCENFUNLGP := CENFUNLGP():New()

Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOpcA      := 0
LOCAL nFor
LOCAL nTrb
LOCAL lAux
LOCAL oDlg
LOCAL oEnchoice
LOCAL bOK      	:= {|| nOpca := 1,If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela) .and. PLSA496Valid() ,oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel  	:= {||oDlg:End()}
LOCAL oFolder		:= Nil
LOCAL aTitles  	:= {}
LOCAL aPages   	:= {}    
LOCAL nControl 	:= 0
LOCAL cAliasTrb	:=	""
LOCAL aCbos			:= { "1-GetDados","2-Enchoice" }
LOCAL bWhen    	:= { || &("lChk"+aFolders[oFolder:nOption,2]) }
Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= {}
Local aInfo     	:= {}
Local cNameChk		:=	""
Local xSelChk		:=	""
Local xReadChk		:=	""
Local xGrvChk		:=	""
Local xObrChk		:=	""

PRIVATE aFolders := {} 
                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa exclusao...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Excluir
   BCI->(DbSetOrder(3))
   If BCI->(DbSeek(xFilial("BCI")+BCL->(BCL_CODOPE+BCL_TIPGUI)))
      Help("",1,"PLSA496DEL")
      Return
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados para exibicao...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
   Copy "BCL" TO Memory Blank
Else
   Copy "BCL" TO Memory  
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a construcao do Dialogo com usuario...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, aSize[4] * 0.33, .T., .F., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchoice := MSMGET():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define folder...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BCQ->(DbSetOrder(1))
If BCQ->(DbSeek(xFilial("BCQ")+PLSINTPAD()))
   nFor := 1
   While ! BCQ->(Eof()) .And. BCQ->(BCQ_FILIAL+BCQ_CODOPE) == xFilial("BCQ")+PLSINTPAD()

         cX2Nome := PLSRetTit(BCQ->BCQ_ALIAS)
         aadd(aFolders,{AllTrim(OemtoAnsi(cX2Nome)),BCQ->BCQ_ALIAS})
         Aadd(aTitles,AllTrim(OemtoAnsi(cX2Nome)))                
         Aadd(aPages,"HEADER "+Trim(Str(nFor,2)))
         nControl++                         
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Dados do folder cabecalho da guia...                                     ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         &("oBrw"+BCQ->BCQ_ALIAS)    := ""
         &("aDad"+BCQ->BCQ_ALIAS)    := {}
         &("oChk"+BCQ->BCQ_ALIAS)    := ""
         &("lChk"+BCQ->BCQ_ALIAS)    := .F.
         &("lGrvAut"+BCQ->BCQ_ALIAS) := .T.
         &("lFldObr"+BCQ->BCQ_ALIAS) := .T.
         &("lRead"+BCQ->BCQ_ALIAS)   := .F.
         &("cOrdem"+BCQ->BCQ_ALIAS)  := StrZero(nFor,2)
         &("nFolder"+BCQ->BCQ_ALIAS) := StrZero(nFor,2)
         &("nLI"+BCQ->BCQ_ALIAS)     := 0
         &("nLF"+BCQ->BCQ_ALIAS)     := 0
         &("nCI"+BCQ->BCQ_ALIAS)     := 0
         &("nCF"+BCQ->BCQ_ALIAS)     := 0
         &("cOrdGrv"+BCQ->BCQ_ALIAS) := StrZero(nFor,2)
         &("bAjuBrw"+BCQ->BCQ_ALIAS) := Space(240)
         &("oOrd"+BCQ->BCQ_ALIAS)    := "" 
         &("cOrd"+BCQ->BCQ_ALIAS)    := Space(02)
         &("oUsu"+BCQ->BCQ_ALIAS)    := ""
         &("oChkIte"+BCQ->BCQ_ALIAS) := ""
         &("lAll"+BCQ->BCQ_ALIAS)    := .F.
         &("oCbx"+BCQ->BCQ_ALIAS)    := ""       
         &("cCbx"+BCQ->BCQ_ALIAS)    := ""
         &("oKey"+BCQ->BCQ_ALIAS)    := ""
         &("cKey"+BCQ->BCQ_ALIAS)    := ""
         &("aKey"+BCQ->BCQ_ALIAS)    := {"F8","F9","F10","F11"}

         &("aCbx"+BCQ->BCQ_ALIAS)    := aClone(aCbos)
         
         MontaDados(BCQ->BCQ_ALIAS,&("aDad"+BCQ->BCQ_ALIAS),nOpc)
         
         nFor ++
   BCQ->(DbSkip())
   Enddo      
Else
   Help("",1,"PLSA496BCQ")
   Return
Endif

oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,,.T.,.F.,aPosObj[2,3],aPosObj[2,4],)
oFolder:bChange := { || cAliasTrb := aFolders[oFolder:nOption,2], &("oBrw"+cAliasTrb):Refresh(),  &("oBrw"+cAliasTrb):SetFocus() }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do cabecalho...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 TO Len(aFolders)               
	cAliasTrb 	:= aFolders[nFor,2]
	xSelChk		:=	"lChk"+cAliasTrb
	xReadChk		:=	"lRead"+cAliasTrb
	xGrvChk		:=	"lGrvAut"+cAliasTrb
	xObrChk		:=	"lFldObr"+cAliasTrb
    
	BCS->(DbSetOrder(1))
	&xSelChk := BCS->(DbSeek(xFilial("BCS")+M->BCL_CODOPE+M->BCL_TIPGUI+cAliasTRB))

	If BCS->(Found())                                                                          
		&xGrvChk	  					:=	If(BCS->BCS_GRVAUT=="1",.T.,.F.)
		&xObrChk						:=	If(BCS->BCS_OBRIG=="1",.T.,.F.)
		&xReadChk					:=	If(BCS->BCS_SOMLEI=="1",.T.,.F.)
      &("cOrdem"+cAliasTrb)  	:= BCS->BCS_ORDMON                         
      &("nFolder"+cAliasTrb) 	:= BCS->BCS_ORDFOL
      &("nLI"+cAliasTrb)     	:= BCS->BCS_LININI
      &("nLF"+cAliasTrb)     	:= BCS->BCS_LINFIN
      &("nCI"+cAliasTrb)     	:= BCS->BCS_COLINI
      &("nCF"+cAliasTrb)     	:= BCS->BCS_COLFIN
      &("cOrdGRV"+cAliasTrb) 	:= BCS->BCS_ORDGRV  
      &("bAjuBrw"+cAliasTrb) 	:= BCS->BCS_EXPF
      nTrb := Ascan(aCbos,{|x| Subs(x,1,1) == BCS->BCS_TIPO})
      &("cCbx"+cAliasTrb)   := aCbos[nTrb]                      
   Else
		&xGrvChk						:=	.T.
		&xObrChk						:=	.T.
		&xReadChk					:=	.F.
      &("cOrdem"+cAliasTrb)  	:= StrZero(nFor,2)
      &("nFolder"+cAliasTrb) 	:= StrZero(nFor,2)
      &("cOrdGrv"+cAliasTrb) 	:= StrZero(nFor,2)
      &("bAjuBrw"+cAliasTrb) 	:= Space(240)
      &("cCbx"+cAliasTrb)    	:= ""                              
      &("nLI"+cAliasTrb)     	:= 0
      &("nLF"+cAliasTrb)     	:= 0
      &("nCI"+cAliasTrb)     	:= 0
      &("nCF"+cAliasTrb)     	:= 0
   Endif   

	cNameChk 				:=	"oSel"+cAliasTrb
	&cNameChk				:= TCheckBox():Create(oFolder:aDialogs[nFor])
	&cNameChk:cCaption	:= STR0007//Em Uso
	&cNameChk:nLeft 		:= 005
	&cNameChk:nTop 		:= 005
	&cNameChk:nWidth 		:= 080
	&cNameChk:nHeight 	:= 009
	&cNameChk:bSetGet 	:= &("{|u| If(pCount() == 0, "+xSelChk+","+xSelChk+" :=u)}")    
	&cNameChk:bLClicked 	:= &("{|| oDlg:Refresh(), oFolder:Refresh()}")
	//
	cNameChk 				:=	"oRea"+cAliasTrb
	&cNameChk				:= TCheckBox():Create(oFolder:aDialogs[nFor])
	&cNameChk:cCaption	:= STR0010//"Somente Leitura"
	&cNameChk:nTop 		:= 005
	&cNameChk:nLeft 		:= 085
	&cNameChk:nWidth 		:= 120
	&cNameChk:nHeight 	:= 009
	&cNameChk:bSetGet 	:= &("{|u| If(pCount() == 0, "+xReadChk+","+xReadChk+" :=u)}")    
	&cNameChk:bWhen		:=	bWhen
	//
	cNameChk 				:=	"oGrv"+cAliasTrb
	&cNameChk				:= TCheckBox():Create(oFolder:aDialogs[nFor])
	&cNameChk:cCaption	:= STR0011//"Inclusao Automatica"
	&cNameChk:nTop 		:= 005
	&cNameChk:nLeft 		:= 205
	&cNameChk:nWidth 		:= 120
	&cNameChk:nHeight 	:= 009
	&cNameChk:bSetGet 	:= &("{|u| If(pCount() == 0, "+xGrvChk+","+xGrvChk+" :=u)}")    
	&cNameChk:bWhen		:=	bWhen
	//
	cNameChk 				:=	"oObr"+cAliasTrb
	&cNameChk				:= TCheckBox():Create(oFolder:aDialogs[nFor])
	&cNameChk:cCaption	:= STR0012//"Obrigatorio"
	&cNameChk:nTop 		:= 005
	&cNameChk:nLeft 		:= 345
	&cNameChk:nWidth 		:= 120
	&cNameChk:nHeight 	:= 009
	&cNameChk:bSetGet 	:= &("{|u| If(pCount() == 0, "+xObrChk+","+xObrChk+" :=u)}")    
	&cNameChk:bWhen		:=	bWhen	

   &("oBrw"+cAliasTrb) := TcBrowse():New( 018, 005, aPosObj[2,3] - 170, aPosObj[2,4] - 45,,,, oFolder:aDialogs[nFor],,,,,,,,,,,, .F.,, .T.,, .F., )
   &("oBrw"+cAliasTrb):bWhen := bWhen
    
   &("oBrw"+cAliasTrb):AddColumn(TcColumn():New("",{ || &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,7] },nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
   &("oBrw"+cAliasTrb):AddColumn(TcColumn():New("",{ || &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,1] },nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
   &("oBrw"+cAliasTrb):AddColumn(TcColumn():New("Ordem",{ || &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,3] },nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
   &("oBrw"+cAliasTrb):AddColumn(TcColumn():New("Campo",{ || &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,8] },nil,nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
   &("oBrw"+cAliasTrb):AddColumn(TcColumn():New(STR0017,{ || &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,4] },nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil)) //"Titulo"
   &("oBrw"+cAliasTrb):AddColumn(TcColumn():New(STR0018,{ || &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,9] },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil)) //"Descricao"
   
//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,.F.,"X3_ORDEM","X3_CAMPO","X3_TITULO","X3_DESCRIC"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		 &("oBrw"+cAliasTrb):aObfuscatedCols := aBls
	endif
   
   &("oBrw"+cAliasTrb):SetArray(&("aDad"+cAliasTrb))

   &("oBrw"+cAliasTrb):bChange     := { || &("cOrd"+cAliasTrb) := &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,3], &("oOrd"+cAliasTrb):SetText(&("cOrd"+cAliasTrb)), &("oOrd"+cAliasTrb):Refresh() }
	&("oBrw"+cAliasTrb):bLDblClick  := { || IF( &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,6] , &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,1] := IF(&("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,1]=="LBOK","LBNO","LBOK"),MsgInfo(STR0019)) } //"Nao e permitido retirar este campo pois e obrigatorio no sistema"
   &("oBrw"+cAliasTrb):bGotFocus   := &("oBrw"+cAliasTrb):bChange
   &("oBrw"+cAliasTrb):bLostFocus  := &("oBrw"+cAliasTrb):bChange

   &("cKey"+cAliasTrb) := BCS->BCS_CKEY

   &("oBrw"+cAliasTrb):bChange := { || oUso:Refresh() }

   @ 005,aPosObj[2,3] -150 SAY STR0013 SIZE 50, 7  OF oFolder:aDialogs[nFor] PIXEL //"Ordem Visualizacao"
   @ 005,aPosObj[2,3] - 97 MSGET &("oOrdem"+cAliasTrb) VAR &("cOrdem"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 06, 06 PIXEL WHEN Eval(bWhen)

   @ 005,aPosObj[2,3] - 76 SAY STR0015 SIZE 50, 7  OF oFolder:aDialogs[nFor] PIXEL //"Ordem Gravacao"
   @ 004,aPosObj[2,3] - 23 MSGET &("oOrdGrv"+cAliasTrb) VAR &("cOrdGrv"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 06, 06 PIXEL WHEN Eval(bWhen)

   @ 016,aPosObj[2,3] -150 SAY STR0008  SIZE 60, 7  OF oFolder:aDialogs[nFor] PIXEL  //"Ordem do Campo"
   @ 016,aPosObj[2,3] - 97 MSGET &("oOrd"+cAliasTrb) VAR &("cOrd"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 15, 06 VALID PLSA496Ord(&("cOrd"+cAliasTrb),&("aDad"+cAliasTrb),&("oBrw"+cAliasTrb)) PIXEL WHEN Eval(bWhen)

   @ 016,aPosObj[2,3] - 76 SAY STR0014  SIZE 60, 7  OF oFolder:aDialogs[nFor] PIXEL  //"Numero Folder"
   @ 016,aPosObj[2,3] - 23 MSGET &("oFolder"+cAliasTrb) VAR &("nFolder"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 06, 06 PIXEL WHEN Eval(bWhen)

   @ 027,aPosObj[2,3] -150 SAY "Linha Inicial"  SIZE 45, 7  OF oFolder:aDialogs[nFor] PIXEL 
   @ 027,aPosObj[2,3] - 76 SAY "Coluna Inicial" SIZE 45, 7  OF oFolder:aDialogs[nFor] PIXEL 
   @ 038,aPosObj[2,3] -150 SAY "Linha Final"    SIZE 45, 7  OF oFolder:aDialogs[nFor] PIXEL 
   @ 038,aPosObj[2,3] - 76 SAY "Coluna Final"   SIZE 45, 7  OF oFolder:aDialogs[nFor] PIXEL 

   @ 027,aPosObj[2,3] -115.5 MSGET &("oLI"+cAliasTrb) VAR &("nLI"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 06, 06 PIXEL WHEN Eval(bWhen) PICTURE "@E 999.99"
   @ 027,aPosObj[2,3] - 41.5 MSGET &("oCI"+cAliasTrb) VAR &("nCI"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 06, 06 PIXEL WHEN Eval(bWhen) PICTURE "@E 999.99"
   @ 038,aPosObj[2,3] -115.5 MSGET &("oLF"+cAliasTrb) VAR &("nLF"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 06, 06 PIXEL WHEN Eval(bWhen) PICTURE "@E 999.99"
   @ 038,aPosObj[2,3] - 41.5 MSGET &("oCF"+cAliasTrb) VAR &("nCF"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 06, 06 PIXEL WHEN Eval(bWhen) PICTURE "@E 999.99"

   @ 049,aPosObj[2,3] -150 CHECKBOX oUso VAR &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,10] PROMPT STR0010 SIZE 66, 10 OF oFolder:aDialogs[nFor] PIXEL ON CLICK &("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,6] := IF(&("aDad"+cAliasTrb)[&("oBrw"+cAliasTrb):nAt,6],.T.,.F.) WHEN Eval(bWhen) //"Somente Leitura"

   @ 049,aPosObj[2,3] - 76 CHECKBOX &("oChkIte"+cAliasTrb) VAR &("lAll"+cAliasTrb) PROMPT STR0009 SIZE 76, 10 OF oFolder:aDialogs[nFor] PIXEL ON CLICK (AEval(&("aDad"+cAliasTrb),{|x| x[1] :=    IF(!&("lAll"+cAliasTrb) .And. x[6],"LBNO","LBOK") })    , &("oBrw"+cAliasTrb):Refresh())  WHEN Eval(bWhen) //"Marca/Desmarca Todos"

   @ 061,aPosObj[2,3] -150 SAY STR0020 SIZE 040, 7  OF oFolder:aDialogs[nFor] PIXEL     //"Tipo Edicao "
   @ 060,aPosObj[2,3] -100 COMBOBOX &("oCbx"+cAliasTrb) Var &("cCbx"+cAliasTrb) ITEMS &("aCbx"+cAliasTrb) SIZE 050,006 OF oFolder:aDialogs[nFor] PIXEL WHEN Eval(bWhen)
    
   @ 072,aPosObj[2,3] -150 SAY STR0021 SIZE 040, 7  OF oFolder:aDialogs[nFor] PIXEL     //"Tecla de Atalho "
   @ 071,aPosObj[2,3] -100 COMBOBOX &("oKey"+cAliasTrb) Var &("cKey"+cAliasTrb) ITEMS &("aKey"+cAliasTrb) SIZE 023,006 OF oFolder:aDialogs[nFor] PIXEL WHEN Eval(bWhen)

   @ aPosObj[2,4] - 24,005 SAY STR0016 SIZE 50, 7  OF oFolder:aDialogs[nFor] PIXEL //"Ajuste Browse"
   @ aPosObj[2,4] - 25,045 MSGET &("oFilter"+cAliasTrb) VAR &("bAjuBrw"+cAliasTrb) OF oFolder:aDialogs[nFor] SIZE 150, 06 PIXEL WHEN Eval(bWhen)
    
Next	             

cAliasTrb := aFolders[1,2]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para atualizacoes...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcA == K_OK
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Trata a exclusao nao podendo haver modificacoes...                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If ( nOpc == K_Incluir .Or. nOpc == K_Alterar ) .Or. ;
      ( nOpc == K_Excluir .And. .T. )
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inicia a transacao...                                                    ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      Begin Transaction
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Atualiza Enchoice...                                                     ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      PLUPTENC("BCL",nOpc)   	
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Agora atualiza os dados do Cabecalho se existir...                       ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      BCS->(DbSetOrder(1))
      
      For nFor := 1 TO Len(aFolders)               
          cAliasTrb := aFolders[nFor,2]
          lAux      := &("lChk"+cAliasTrb)
          lRead     := &("lRead"+cAliasTrb)
          cOrdem    := &("cOrdem"+cAliasTrb)
          nFolder   := &("nFolder"+cAliasTrb)
          cOrdGrv   := &("cOrdGrv"+cAliasTrb)
          bAjuBrw   := &("bAjuBrw"+cAliasTrb)
          lGrvAut   := &("lGrvAut"+cAliasTrb)
          lFldObr   := &("lFldObr"+cAliasTrb)
          nLI       := &("nLI"+cAliasTrb)
          nLF       := &("nLF"+cAliasTrb)
          nCI       := &("nCI"+cAliasTrb)
          nCF       := &("nCF"+cAliasTrb)
          

          GravaDados(cAliasTrb,&("aDad"+cAliasTrb),nOpc)
          
          BCS->(DbSetOrder(1))
          lExist := BCS->(DbSeek(xFilial("BCS")+M->BCL_CODOPE+M->BCL_TIPGUI+cAliasTRB))

          If nOpc <> K_Excluir
             If lAux 
                BCS->(RecLock("BCS",!lExist))
                BCS->BCS_FILIAL := xFilial("BCS")      
                BCS->BCS_CODOPE := M->BCL_CODOPE
                BCS->BCS_TIPGUI := M->BCL_TIPGUI
                BCS->BCS_ALIAS  := cAliasTrb
                BCS->BCS_TIPO   := &("cCbx"+cAliasTrb)
                BCS->BCS_CKEY   := &("cKey"+cAliasTrb)
                BCS->BCS_SOMLEI := IF(lRead,"1","0")
                BCS->BCS_ORDMON := cOrdem
                BCS->BCS_ORDFOL := nFolder
                BCS->BCS_ORDGRV := cOrdGRV
                BCS->BCS_EXPF   := bAjuBrw
                BCS->BCS_GRVAUT := IF(lGrvAut,"1","0")
                BCS->BCS_OBRIG  := IF(lFldObr,"1","0")
                BCS->BCS_LININI := nLI
                BCS->BCS_LINFIN := nLF
                BCS->BCS_COLINI := nCI
                BCS->BCS_COLFIN := nCF
                BCS->(MsUnLock())
            Endif
         
            If ! lAux .And. lExist
                BCS->(RecLock("BCS",.F.))
                BCS->(DbDelete())
                BCS->(MsUnLock())
            Endif    
         Else
            If lExist
                BCS->(RecLock("BCS",.F.))
                BCS->(DbDelete())
                BCS->(MsUnLock())
            Endif    
         Endif   
      Next
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Fianliza a transacao...                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      End Transaction
   Endif  
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA496PRO ³ Autor ³ Tulio Cesar       ³ Data ³ 15.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o proximo codigo disponivel                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA496()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA496PRO(cCodOpe)
LOCAL nRet    := 0
LOCAL nOrdBCL := BCL->(IndexOrd())
LOCAL nTam    := Len(BCL->BCL_TIPGUI)
LOCAL nReg    := BCL->(Recno())

BCL->(DbSetOrder(1))
BCL->(DbSeek(xFilial("BCL")+cCodOpe+Replicate("9",nTam),.T.))
BCL->(DbSkip(-1))
                                                           
If BCL->(BCL_FILIAL+BCL_CODOPE) <> xFilial("BCL")+cCodOpe
   nRet := StrZero(1,nTam)
Else
   nRet := StrZero(Val(BCL->BCL_TIPGUI)+1,nTam)
Endif

BCL->(DbSetOrder(nOrdBCL))
BCL	->(DbGoTo(nReg))

Return(nRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA496ORD ³ Autor ³ Tulio Cesar       ³ Data ³ 15.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera a ordem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA496ORD()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA496Ord(cOrdem,aDados,oBrowse)
LOCAL nFor
LOCAL lRet  := .T.      
LOCAL aAux

If cOrdem == aDados[oBrowse:nAt,3]
   Return(lRet)
Endif   

lRet := ( Val(RetAsc(cOrdem,2,.F.)) > 0 .and. Val(RetAsc(cOrdem,2,.F.)) <= Len(aDados) )

If ! lRet
   Return(lRet)
Endif

aDados[oBrowse:nAt,3] := cOrdem

aAux := aSort(aDados,,, { |x, y| x[3] < y[3] })    

For nFor := 1 To Len(aDados)
    aAux[nFor,3] := StrZero(nFor,2)
Next

aDados := aClone(aAux)

oBrowse:SetArray(aDados)
oBrowse:Refresh()

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDados
BCM x SX3
@author PLS TEAM
@since 16/08/2019
@version P12
/*/
Static Function GravaDados(cAlias,aDados,nOpc)
LOCAL nFor 

If     nOpc == K_Incluir
       For nFor := 1 To Len(aDados)
           If aDados[nFor,1] == "LBOK" .And. aDados[nFor,6]
              BCM->(RecLock("BCM",.T.))
              BCM->BCM_FILIAL := xFilial("BCM")
              BCM->BCM_CODOPE := M->BCL_CODOPE
              BCM->BCM_TIPGUI := M->BCL_TIPGUI
              BCM->BCM_ALIAS  := cAlias
              BCM->BCM_ORDEM  := aDados[nFor,3]
              BCM->BCM_CAMPO  := aDados[nFor,2]
              BCM->BCM_SOMLEI := If(aDados[nFor,10],"1","0")
              BCM->(MsUnLock())
           Endif   
       Next
ElseIf nOpc == K_Alterar
       For nFor := 1 To Len(aDados)
           If aDados[nFor,5] > 0 .And. aDados[nFor,6]
              BCM->(DbGoTo(aDados[nFor,5]))
              BCM->(RecLock("BCM",.F.))
              If aDados[nFor,1] == "LBNO"
                 BCM->(DbDelete())
              Else
                 BCM->BCM_FILIAL := xFilial("BCM")
                 BCM->BCM_CODOPE := M->BCL_CODOPE
                 BCM->BCM_TIPGUI := M->BCL_TIPGUI
                 BCM->BCM_ALIAS  := cAlias
                 BCM->BCM_ORDEM  := aDados[nFor,3]
                 BCM->BCM_CAMPO  := aDados[nFor,2]
                 BCM->BCM_SOMLEI := If(aDados[nFor,10],"1","0")
              Endif   
              BCM->(MsUnLock())
           ElseIf aDados[nFor,1] == "LBOK" .And. aDados[nFor,6]
                  BCM->(RecLock("BCM",.T.))
                  BCM->BCM_FILIAL := xFilial("BCM")
                  BCM->BCM_CODOPE := M->BCL_CODOPE
                  BCM->BCM_TIPGUI := M->BCL_TIPGUI
                  BCM->BCM_ALIAS  := cAlias
                  BCM->BCM_ORDEM  := aDados[nFor,3]
                  BCM->BCM_CAMPO  := aDados[nFor,2]
                  BCM->BCM_SOMLEI := If(aDados[nFor,10],"1","0")
                  BCM->(MsUnLock())
           Endif   
       Next
ElseIf nOpc == K_Excluir
       For nFor := 1 To Len(aDados)
           If aDados[nFor,5] > 0 .And. aDados[nFor,6]
              BCM->(DbGoTo(aDados[nFor,5]))
              BCM->(RecLock("BCM",.F.))
              BCM->(DbDelete())       
              BCM->(MsUnLock())
           Endif      
       Next
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaDados

@author PLS TEAM
@since 16/08/2019
@version P12
/*/
Function MontaDados(cAlias,aDados,nOpc)
LOCAL nFor
LOCAL lAux
LOCAL lUso

SX3->(DbSetOrder(1))
If SX3->(DbSeek(cAlias))
   While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias
         lUso := X3Uso(SX3->X3_USADO)
         aadd(aDados,{If(lUso,"LBNO","LBOK"),SX3->X3_CAMPO,SX3->X3_ORDEM,SX3->X3_TITULO,0,lUso,IF(lUso,"ENABLE","DISABLE"),SX3->X3_CAMPO,SX3->X3_DESCRIC,.T.})
   SX3->(DbSkip())
   Enddo
Endif

If nOpc <> K_Incluir
   For nFor := 1 To Len(aDados)
       If aDados[nFor,6]
          BCM->(DbSetOrder(2))
          lAux := BCM->(DbSeek(xFilial("BCM")+M->BCL_CODOPE+M->BCL_TIPGUI+cAlias+aDados[nFor,2]))
       
          aDados[nFor,1]  := IF(lAux,"LBOK","LBNO")            
          aDados[nFor,3]  := IF(lAux,BCM->BCM_ORDEM,aDados[nFor,3])
          aDados[nFor,5]  := If(lAux,BCM->(Recno()),0)
          aDados[nFor,5]  := If(lAux,BCM->(Recno()),0)
          aDados[nFor,10] := If(!lAux,.F.,IF(BCM->BCM_SOMLEI=="1",.T.,.F.))
       Endif   
   Next    
   aSort(aDados,,, { |x, y| x[3] < y[3] })    
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³05/01/2007³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := {	{ STR0001	,'AxPesqui'    , 0 , K_Pesquisar  , 0, .F.},; //'Pesquisar' //"Pesquisar"
						{ STR0002	,'PLSA496MOV'  , 0 , K_Visualizar , 0, Nil},; //'Visualizar' //"Visualizar"
						{ STR0003	,'PLSA496MOV'  , 0 , K_Incluir    , 0, Nil},; //'Incluir' //"Incluir"
						{ STR0004	,'PLSA496MOV'  , 0 , K_Alterar    , 0, Nil},; //'Alterar' //"Alterar"
						{ "Cfg. Imp. TISS"	,'VIEWDEF.PLSA446'  , 0 , K_Alterar    , 0, Nil},; //'Alterar' //"Alterar"
                        { "Cfg. P.Contas"	   ,'VIEWDEF.PLSA496'  , 0 , K_Alterar    , 0, Nil},; //'Alterar' //"Alterar"
						{ STR0005	,'PLSA496MOV'  , 0 , K_Excluir    , 0, Nil} } //"Excluir"
Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³PLSA496   ºAuthor ³Alexandre Silva     º Date ³  06/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a validacao dos dados antes do cadastro                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PLSA496Valid()
	Local nFor 		:=	0
	Local nFolPos	:=	0
	Local lInUse	:=	.F.
	Local lRet		:=	.T.
	
	For nFor := 1 To Len(aFolders)               
		cAliasTrb	:= aFolders[nFor,2]
		lInUse      := &("lChk"+cAliasTrb)
		If lInUse 
			nFolPos	:= Val(&("nFolder"+cAliasTrb))
			If nFolPos > M->BCL_QTDFOL
				MsgInfo(STR0022 + aFolders[nFor][1] + STR0023,STR0024)//"O Valor do campo Numero Folder na pasta [" + aFolders[nFor][1] + "], não pode ser maior do que o campo BCL_QTDFOL na pasta [Parametrização].","Validação"
			 	lRet := .F. 		
				Exit
			EndIf
		EndIf
 	Next nFor
 	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Lucas Nonato
@since   01/04/2019
@version P12
/*/
static function ModelDef()

local oModel // Modelo de dados construído
local oStrBCL := FWFormStruct(1,'BCL') 
local oStrBCM := FWFormStruct(1,'BCM') 

oModel := MPFormModel():New( 'Configuração Proc Contas', , , )

oModel:addFields('MasterBCL',/*cOwner*/,oStrBCL)
oModel:AddGrid('BCMDetail',  'MasterBCL',  oStrBCM, , )
oModel:AddGrid('BCMDetail2', 'MasterBCL', oStrBCM, , )
oModel:AddGrid('BCMDetail3', 'MasterBCL', oStrBCM, , )
//oModel:AddGrid('BCMDetail4', 'MasterBCL', oStrBCM, , )
							
oModel:SetRelation( 'BCMDetail', { 	{ 	'BCM_FILIAL', 'BCL_FILIAL'},;
									         { 	'BCM_CODOPE', 'BCL_CODOPE'},;
									         { 	'BCM_TIPGUI', 'BCL_TIPGUI'},;
									         { 	'BCM_ALIAS' , "'"+BCL->BCL_ALIAS+"'"}},;  
									            BCM->( IndexKey( 1 ) ))

oModel:SetRelation( 'BCMDetail2', {	{ 	'BCM_FILIAL', 'BCL_FILIAL'},;
									         { 	'BCM_CODOPE', 'BCL_CODOPE'},;
									         { 	'BCM_TIPGUI', 'BCL_TIPGUI'},;
									         { 	'BCM_ALIAS' , "'BD6'"}},;  
									            BCM->( IndexKey( 1 ) ))

oModel:SetRelation( 'BCMDetail3', {	{ 	'BCM_FILIAL', 'BCL_FILIAL'},;
									         { 	'BCM_CODOPE', 'BCL_CODOPE'},;
									         { 	'BCM_TIPGUI', 'BCL_TIPGUI'},;
									         { 	'BCM_ALIAS' , "'BD7'"}},;  
									            BCM->( IndexKey( 1 ) ))

/*oModel:SetRelation( 'BCMDetail4', { { 	'BCM_FILIAL', 'BCL_FILIAL'},;
									         { 	'BCM_CODOPE', 'BCL_CODOPE'},;
									         { 	'BCM_TIPGUI', 'BCL_TIPGUI'},;
									         { 	'BCM_ALIAS' , "'B43'"}},;  
									            BCM->( IndexKey( 1 ) ))*/
																							
oModel:GetModel('MasterBCL'):SetDescription('Configuração Proc Contas') // Adiciona a descrição do Modelo de Dados

oModel:GetModel('BCMDetail'):SetNoInsertLine(.t.)
oModel:GetModel('BCMDetail2'):SetNoInsertLine(.t.)
oModel:GetModel('BCMDetail3'):SetNoInsertLine(.t.)
//oModel:GetModel('BCMDetail4'):SetNoInsertLine(.t.)

oStrBCM:setProperty( "*" , MODEL_FIELD_OBRIGAT , 	.f. )

oModel:GetModel( 'BCMDetail'  ):SetOptional( .T. )
oModel:GetModel( 'BCMDetail2' ):SetOptional( .T. )
oModel:GetModel( 'BCMDetail3' ):SetOptional( .T. )
//oModel:GetModel( 'BCMDetail4' ):SetOptional( .T. )

oModel:SetPrimaryKey({})

return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Lucas Nonato
@since   01/04/2019
@version P12
/*/
static function ViewDef()

local oView  // Interface de visualização construída
local oModel   := FWLoadModel( 'PLSA496' ) // Cria as estruturas a serem usadas na View
local oStrBCL  := FWFormStruct(2, 'BCL', { |cCampo| PLS496FT(cCampo, 'BCL') })
local oStrBCM  := FWFormStruct(2, 'BCM', { |cCampo| PLS496FT(cCampo, 'BCM') })
local oStrBCM2 := FWFormStruct(2, 'BCM', { |cCampo| PLS496FT(cCampo, 'BCM', .t.) })

oView := FWFormView():New() // Cria o objeto de View

//oView:SetOnDemand(.t.)
oView:EnableControlBar(.T.)

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewBCL' , oStrBCL,'MasterBCL' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid( 'ViewBCM'  , oStrBCM,'BCMDetail' )
oView:AddGrid( 'ViewBCM2' , oStrBCM2,'BCMDetail2' )
oView:AddGrid( 'ViewBCM3' , oStrBCM2,'BCMDetail3' )
//oView:AddGrid( 'ViewBCM4' , oStrBCM,'BCMDetail4' )

oView:CreateHorizontalBox( 'CABEC', 20 )
oView:CreateHorizontalBox( 'ITENS', 80 )

oView:AddOtherObject('BOXBTN', {|oPanel| P496BTN(oPanel, oModel, oView, BCL->BCL_ALIAS,'BCMDetail')})
oView:AddOtherObject('BOXBTN1',{|oPanel| P496BTN(oPanel, oModel, oView, "BD6",'BCMDetail2')})
oView:AddOtherObject('BOXBTN2',{|oPanel| P496BTN(oPanel, oModel, oView, "BD7",'BCMDetail3')})
//oView:AddOtherObject('BOXBTN3',{|oPanel| P496BTN(oPanel, oModel, oView, "B43",'BCMDetail4')})

oView:CreateFolder( 'PASTAS', 'ITENS' )
oView:AddSheet( 'PASTAS', 'ABA01', 'Cabeçalho' )
oView:AddSheet( 'PASTAS', 'ABA02', 'Eventos' )
oView:AddSheet( 'PASTAS', 'ABA03', 'Participações' )
//oView:AddSheet( 'PASTAS', 'ABA04', 'Pacotes' )

oView:CreateVerticalBox( 'BCM' , 90,,, 'PASTAS', 'ABA01' )
oView:CreateVerticalBox( 'BCM1', 90,,, 'PASTAS', 'ABA02' )
oView:CreateVerticalBox( 'BCM2', 90,,, 'PASTAS', 'ABA03' )
//oView:CreateVerticalBox( 'BCM3', 90,,, 'PASTAS', 'ABA04' )

oView:CreateVerticalBox( 'BOX' , 10,,, 'PASTAS', 'ABA01' )
oView:CreateVerticalBox( 'BOX1', 10,,, 'PASTAS', 'ABA02' )
oView:CreateVerticalBox( 'BOX2', 10,,, 'PASTAS', 'ABA03' )
//oView:CreateVerticalBox( 'BOX3', 10,,, 'PASTAS', 'ABA04' )

//Relacionando donos dos ids com a tabelas
oView:SetOwnerView('ViewBCL' ,'CABEC')
oView:SetOwnerView('ViewBCM' ,'BCM' ) 
oView:SetOwnerView('ViewBCM2','BCM1') 
oView:SetOwnerView('ViewBCM3','BCM2') 
//oView:SetOwnerView('ViewBCM4','BCM3') 
oView:SetOwnerView('BOXBTN'  ,'BOX' ) 
oView:SetOwnerView('BOXBTN1' ,'BOX1') 
oView:SetOwnerView('BOXBTN2' ,'BOX2') 
//oView:SetOwnerView('BOXBTN3' ,'BOX3') 

oView:SetViewProperty("ViewBCM", "GRIDSEEK",    {.T.})
oView:SetViewProperty("ViewBCM", "GRIDFILTER",  {.T.}) 

oView:SetViewProperty("ViewBCM2", "GRIDSEEK",   {.T.})
oView:SetViewProperty("ViewBCM2", "GRIDFILTER", {.T.}) 

oView:SetViewProperty("ViewBCM3", "GRIDSEEK",   {.T.})
oView:SetViewProperty("ViewBCM3", "GRIDFILTER", {.T.}) 

/*oView:SetViewProperty("ViewBCM4", "GRIDSEEK",   {.T.})
oView:SetViewProperty("ViewBCM4", "GRIDFILTER", {.T.}) */

oStrBCM:SetProperty(  'BCM_CAMPO', MVC_VIEW_CANCHANGE, .f.)
oStrBCM2:SetProperty( 'BCM_CAMPO', MVC_VIEW_CANCHANGE, .f.)
oStrBCL:SetProperty(  '*', MVC_VIEW_CANCHANGE, .f.)

return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS496FT
Tratamento para ajustar os campos a ser utilizados da tabela.
@author Lucas Nonato
@since 01/04/2019
@version P12
/*/
function PLS496FT(cCampo, cAlias, lNaoCab)
local lRet	:= .f.

cCampo := alltrim(cCampo)

if cAlias == "BCL"
   if cCampo == "BCL_CODOPE" .or. cCampo == "BCL_TIPGUI" .or. cCampo == "BCL_DESCRI" .or. cCampo == "BCL_DESOPE" 
   	lRet := .t.
   endif
else
   if !(cCampo == "BCM_CODOPE" .or. cCampo == "BCM_TIPGUI" .or. cCampo == "BCM_ALIAS" .or. iif(lNaoCab, cCampo == "BCM_ALTREP", .f. )) 
   	lRet := .t.
   endif   
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P496BTN
Botão de incluir campo
@author Lucas Nonato
@since 16/08/2019
@version P12
/*/
function P496BTN(oPanel, oModel, oView, cAlias, cModel)
local lOk 		:= .F.
local cTipo

@ 020, 005 Button 'Incluir Campo'  Size 80, 13  Pixel Action ; 
	PLBCMxSX3(oModel, oView, cAlias, cModel) of oPanel 

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLBCMxSX3
BCM x SX3
@author Lucas Nonato
@since 16/08/2019
@version P12
/*/
Function PLBCMxSX3(oModel, oView, cAlias, cModel)

   Static objCENFUNLGP := CENFUNLGP():New()

local oDlg		   := Nil
local cSql		   := ""
local aConjunto   := {}
local nFor		   := 0
local nOpc		   := 0
local bOK		   := { || nOpc := 1, oDlg:End() }
local bCancel	   := { || oDlg:End() }
local aRemove     := {}
local cDado       := ""

cSql := " SELECT BCM_CAMPO "
CSql += " FROM " + RetSqlName("BCM")
cSql += " WHERE BCM_FILIAL = '"+xFilial("BCM")+"' "
cSql += " AND BCM_CODOPE = '"+BCL->BCL_CODOPE+"' "
cSql += " AND BCM_TIPGUI = '"+BCL->BCL_TIPGUI+"' "
cSql += " AND BCM_ALIAS = '"+cAlias+"' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TRB",.f.,.t.)
while TRB->(!eof())
   aadd(aRemove, TRB->BCM_CAMPO)
   TRB->( dbSkip() )
enddo
TRB->(dbclosearea())

SX3->(dbsetorder(1)) //X3_ARQUIVO
SX3->(msseek(cAlias))
while SX3->(!eof()) .and. SX3->X3_ARQUIVO == cAlias .and. ascan(aRemove, SX3->X3_CAMPO) == 0
	aAdd( aConjunto , { SX3->X3_CAMPO, SX3->X3_TITULO,.F. } )
	SX3->( dbSkip() )
enddo

DEFINE MSDIALOG oDlg TITLE 'Campos SX3' FROM 008,010 TO 050,100 OF GetWndDefault()
@ 035,005 SAY oSay PROMPT 'Selecione os campos a serem incluidos' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
oConjunto := TcBrowse():New( 050, 005, 340, 250,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))     
oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,030,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,"X3_CAMPO","X3_TITULO"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oConjunto:aObfuscatedCols := aBls
	endif

oConjunto:SetArray(aConjunto)         
oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 50 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

if nOpc == 1   
   oBCM := oModel:GetModel(cModel)
   oBCM:SetNoInsertLine(.f.)
   oBCM:GoLine(oBCM:length())	
	cQtd := oBCM:GetValue("BCM_ORDEM")
   for nFor := 1 To Len(aConjunto)
      if aConjunto[nFor,3]
         cDado += aConjunto[nFor,1]+","     
         if !oBCM:SeekLine({{"BCM_CAMPO",aConjunto[nFor,1]}})     
            oBCM:AddLine()
            oBCM:LoadValue("BCM_FILIAL",  xFilial("BCM"))         
            oBCM:LoadValue("BCM_CODOPE",  BCL->BCL_CODOPE)
            oBCM:LoadValue("BCM_TIPGUI",  BCL->BCL_TIPGUI)
            oBCM:LoadValue("BCM_ALIAS",   substr(aConjunto[nFor,1],1,3))
            oBCM:LoadValue("BCM_ORDEM",   soma1(cQtd))
            oBCM:LoadValue("BCM_CAMPO",   aConjunto[nFor,1])
            oBCM:LoadValue("BCM_SOMLEI",  '1')
         endif
      endif
   next
   oBCM:SetNoInsertLine(.t.)
endif

oView:Refresh()

return .T.