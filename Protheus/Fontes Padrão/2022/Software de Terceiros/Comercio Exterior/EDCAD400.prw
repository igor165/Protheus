#INCLUDE "EDCAD400.ch"
#include "AVERAGE.CH"
#include 'ap5mail.ch'

#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³EDCAD150  ³ Autor ³ THOMAZ AUGUSTO NETTO                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Manutenção do Termo Aditivo(Drawback)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Drawback                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                      

*-----------------------*
 Function EDCAD400()
*-----------------------*
LOCAL nOrdSX3 := SX3->(IndexOrd())
Private cCadastro := STR0001  //"Manutenção do Termo Aditivo"
Private cAlias  := SELECT("ED5")               

SX3->(DBSetOrder(2))   // ACSJ - 19/11/2004
lED5NrAdi := SX3->(DBSeek("ED5_NRADI"))
SX3->(DBSetOrder(nOrdSX3))             

aRotina := MenuDef()
    
mBrowse(,,,,"ED5")               

ED5->(DBSETORDER(1))    

Return .F.                                            
                

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 31/01/07 - 17:31
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0002  , "AxPesqui"   , 0 , 1},;  //"Pesquisar"
                    { STR0003  , "AD150MANUT" , 0 , 2},;  //"Visualizar"
                    { STR0004  , "AD150MANUT" , 0 , 3},;  //"Incluir"
                    { STR0005  , "AD150MANUT" , 0 , 4},;  //"Alterar"
                    { STR0006  , "AD150MANUT" , 0 , 5}}   //"Excluir"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("DAD400MNU")
	aRotAdic := ExecBlock("DAD400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina           
*---------------------------------------*
Function AD150MANUT(cAlias,nReg,nOpc)
*---------------------------------------*
LOCAL nOpcA:=0,oDlg, oEnch , I
Private aTELA[0][0],aGETS[0]
cTit:= STR0001 //"Manutenção do Termo Aditivo "

dbselectarea(cALIAS)

IF nOpc # 3
   RecLock(cAlias,.F.)
ENDIF

FOR I := 1 TO FCount()
   IF nOpc == 3
      M->&(FIELDNAME(I)):= CRIAVAR(FIELDNAME(I))
   Else                                                        
      M->&(FIELDNAME(I)):= FieldGet(I)
   Endif
NEXT

DEFINE MSDIALOG oDlg TITLE cTit ;
     FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM; //oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
     OF oMainWnd PIXEL

nLinha :=(oDlg:nClientHeight-4)/2

oEnch:=MsMget():New( "ED5",nReg,nOpc,,,,,{15,1,nLinha,COLUNA_FINAL},If(nOpc=5,{},),3)
oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT ;
         (EnchoiceBar(oDlg,{||IF(Obrigatorio(aGets,aTela),(nOpcA:=1,oDlg:End()),)},;
                          {||nOpcA:=0,oDlg:End()},(nOpc=5))) //LRL 30/04/04 -Alinhamento MDI //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                          
IF nOpcA == 1
   DO CASE 
      CASE nOpc = 3
           E_GRAVA(cALIAS,.T.)                   

      CASE nOpc = 4
           E_GRAVA(cALIAS,.F.)

      CASE nOpc = 5
           (cALIAS)->(DBDELETE())
           (cAlias)->(MsUnlock())
   ENDCASE
ENDIF

dbselectarea(cALIAS)

Return nOpc

*-----------------------*
Function ADWHEN(cParam)
*-----------------------*
lRet:= .T.

Do Case
   Case cParam == "ED5_OPCOES"
      If Empty(M->ED5_IM_EX)      
         if lED5NrAdi   // ACSJ - 19/11/2004
            If !Empty(M->ED5_NRADI)
               lRet:= .F.
            Endif
         Else
            lRet:= .F.         
         Endif                     
      Else
         lRet:= .F.
      Endif
EndCase

Return lRet
