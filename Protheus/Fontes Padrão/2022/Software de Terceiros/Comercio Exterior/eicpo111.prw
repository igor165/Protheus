#INCLUDE "Eicpo111.ch"
#Include "AVERAGE.CH"
//Funcao:     EICPO111  
//Autor:      AVERAGE/Regina        
//Data:       12.08.99 
//Descricao:  Pedidos Cancelados
//Sintaxe:    EICPO111()
//Uso:        Protheus v507 e v508 (Alex Wallauer 04 de Setembro de 2000)
   
#include "rwmake.ch"
#DEFINE _VlPict := '@E 999,999,999,999.99'
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2

#COMMAND E_RESET_AREA => Work1->(E_EraseArq(cNomArq));
                       ; DBSELECTAREA(nOldArea) ; RETURN NIL

*-----------------------*
Function Eicpo111()
*-----------------------*

i:=1
nOldArea:=SELECT()
aSemSX3:={}
bVisual := {|| nOpc := 2, PO111Visual()}
bRelat  := {|| nOpc := 3, EICPO112()  }

aRotina := MenuDef()

cCadastro := STR0004 //"Pedidos Cancelados"
cTitulo   := STR0005 //"Itens Cancelados"

aCampo2 := {} 
AADD(aCampo2,{{||TRB->EI5_CC}     ,'',AVSX3('EI5_CC'    ,5) })
AADD(aCampo2,{{||TRB->EI5_CC_NOM} ,'',AVSX3('EI5_CC_NOM',5) })
AADD(aCampo2,{{||TRB->EI5_SI_NUM} ,'',AVSX3('EI5_SI_NUM',5) })
AADD(aCampo2,{{||TRB->EI5_COD_I}  ,'',AVSX3('EI5_COD_I' ,5) })
AADD(aCampo2,{{||TRB->EI5_DESC_I} ,'',AVSX3('EI5_DESC_I',5) }) 
AADD(aCampo2,{{||TRB->EI5_PART_N} ,'',AVSX3('EI5_PART_N',5) }) 
AADD(aCampo2,{{||TRB->FLUXO}      ,'',AVSX3('EI5_FLUXO' ,5) }) 
AADD(aCampo2,{{||TRB->FABR}       ,'',AVSX3('EI5_FABR'  ,5) }) 
AADD(aCampo2,{{||TRB->UNI}        ,'',AVSX3('B1_UM'     ,5) }) 
AADD(aCampo2,{{||TRB->EI5_QTDE}   ,'',AVSX3('EI5_QTDE ' ,5),AVSX3('EI5_QTDE ' ,6) }) 
AADD(aCampo2,{{||TRB->EI5_PRECO}  ,'',AVSX3('EI5_PRECO' ,5),AVSX3('EI5_PRECO' ,6) }) 
AADD(aCampo2,{{||TRB->TOTPRECO}   ,'',AVSX3('EI4_FOB_GE',5),AVSX3('EI4_FOB_GE',6) }) 
AADD(aCampo2,{{||TRB->EI5_DT_EMB} ,'',AVSX3('EI5_DT_EMB',5) }) 
AADD(aCampo2,{{||TRB->EI5_DT_ENT} ,'',AVSX3('EI5_DT_ENT',5) }) 
AADD(aCampo2,{{||TRB->EI5_MOTIVO} ,'',AVSX3('EI5_MOTIVO',5) }) 
AADD(aCampo2,{{||TRB->EI5_DT_CAN} ,'',AVSX3('EI5_DT_CAN',5) })

EICAddLoja(aCampo2, "EI5_FABLOJ", "TRB", AVSX3('EI5_FABR'  ,5))  

//GFP 19/10/2010
aCampo2 := AddCpoUser(aCampo2,"EI5","2")

AADD(aSemSX3,{ 'FLUXO'     , 'C' ,03, 0}) 
AADD(aSemSX3,{ 'FABR'      , 'C' ,30, 0}) 
AADD(aSemSX3,{ 'UNI'       , 'C' ,04, 0}) 
AADD(aSemSX3,{ 'TOTPRECO'  , 'N' ,16, 2}) 
AADD(aSemSX3,{ 'TRB_ALI_WT', 'C' ,03, 0})
AADD(aSemSX3,{ 'TRB_REC_WT', 'N' ,10, 0})

//GFP 19/10/2010
aSemSX3 := AddWkCpoUser(aSemSX3,"EI5")

DbSelectArea('EI4')

aPosicao:= { 15,  1, 70, 315 }

mBrowse(6,1,22,75,'EI4')


Return .T.          
         

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 25/01/07 - 15:01
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0001, 'AxPesqui'     , 0 , 1},; //"Pesquisar"
                    { STR0002, 'Eval(bVisual)', 0 , 2},; //"Visual"
                    { STR0003, 'Eval(bRelat)' , 0 , 3}} //"Impressao"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IPO111MNU")
	aRotAdic := ExecBlock("IPO111MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina                    


*--------------------------------------------*
Static Function PO111Visual()
*---------------------------------------------*
Private oEnchoice, oSelect //LRL 22/03/04
dbSelectArea('EI4')
IF EasyRecCount() == 0
   Return (.T.)
EndIf

aTELA:=ARRAY(0,0)
aGETS:=ARRAY(0)
aHeader:={}

nOpc:= 2
aCampos:=ARRAY(EI5->(FCOUNT()))  //E_CriaTrab utiliza

cNomArq:=E_CriaTrab('EI5',aSemSX3,'TRB')

IndRegua('TRB',cNomArq+TEOrdBagExt(),"EI5_PO_NUM")

SET INDEX TO (cNomArq+TEOrdBagExt())
aEI4 := {"EI4_PO_NUM","EI4_PO_DT"  ,"EI4_TIPO_E","EI4_MOEDA" ,"EI4_TIPO_D","EI4_ORIGEM",;
         "EI4_DEST"  ,"EI4_FREPPC" ,"EI4_COND_P","EI4_DIAS_P",;
         "EI4_AGENTE", "EI4_AGENTN","EI4_COMPRA","EI4_COMPRN", "EI4_MOEDA",;
         "EI4_FOB_GE", "EI4_INCOTE","EI4_IMPORT","EI4_IMPNOM"}

If !PO111GrTRB()
   Help(' ',1,'EICSEMITEM')
   TRB->(E_EraseArq(cNomArq))
   dbSelectArea('EI4')
   Return .T.
Endif

dbSelectArea('TRB')
dbGoTop()

oMainWnd:ReadClientCoords()

DEFINE MSDIALOG oDlg TITLE STR0004 ;  //"Pedidos Cancelados"
           FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
             OF oMainWnd PIXEL  

    oEnchoice:=MsMGet():New('EI4' ,EI4->(RECNO()),2,,,,/*aEI4*/,{15,1,MEIO_DIALOG,(oDlg:nClientWidth-4)/2},,3)    
    oSelect:=MsSelect():New('TRB',,,aCampo2,.F.,'X',{MEIO_DIALOG+1,1,FINAL_SELECT,COLUNA_FINAL})

    oEnchoice:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT       
    oSelect:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT	 //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
    oDlg:lMaximized := .T.
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})) //LRL 22/03/04 Alinhamento //na versão MDI  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

TRB->(E_ERASEARQ(cNomArq))
  
Return( nOpc )

*----------------------------------------------------------------------------
Static FUNCTION PO111GrTRB()
*----------------------------------------------------------------------------
lRet := .F.
lFirst:=.T.
dbSelectArea('EI5')
EI5->(DBSEEK(xFilial('EI5')+EI4->EI4_PO_NUM))
DO While !EI5->(EOF()) .AND.EI5_FILIAL==xFilial('EI5').AND.EI5->EI5_PO_NUM==EI4->EI4_PO_NUM
 nChave := EI5->EI5_COD_I  +;
           EI5->EI5_FABR +;
           EI5->EI5_FORN

  SB1->( DBSEEK(xFilial('SB1')+ EI5->EI5_COD_I ) )
  //SA5->( DBSEEK(xFilial('SA5')+ EI5->EI5_COD_I+EI5->EI5_FABR+EI5->EI5_FORN ) )
  EICSFabFor(xFilial("SA5")+EI5->EI5_COD_I+EI5->EI5_FABR+EI5->EI5_FORN, EICRetLoja("EI5","EI5_FABLOJ"), EICRetLoja("EI5","EI5_FORLOJ"))
  SY3->( DBSEEK(xFilial('SY3')+EI5->EI5_CC ) )
  

  TRB->(DBAPPEND())
  //BAK - 05/05/2011 - Campos sendo carregados pela avreplace()
  AvReplace("EI5","TRB")
  //TRB->EI5_CC     := EI5->EI5_CC
  TRB->EI5_CC_NOM := Left( SY3->Y3_DESC,20 )
  //TRB->EI5_SI_NUM := EI5->EI5_SI_NUM
  //TRB->EI5_COD_I  := EI5_COD_I 
  TRB->EI5_PART_N := BuscaPart_N(xFilial('SA5')+TRB->EI5_COD_I+EI5->EI5_FABR+EI5->EI5_FORN,IF(EICLOJA(),EI5->EI5_FORLOJ,""),IF(EICLOJA(),EI5->EI5_FABLOJ,""))
  TRB->FLUXO      := IF(EI5->EI5_FLUXO=='1',STR0006,STR0007) //"Sim"###"Nao"
  TRB->EI5_DESC_I := MSMM(SB1->B1_DESC_I,26,1 )
  SA2->( DBSEEK(xFilial('SA2')+ EI5->EI5_FABR+EICRetLoja("EI5","EI5_FABLOJ") ) )
  TRB->FABR       := EI5->EI5_FABR+ IF(EICLOJA(),EI5->EI5_FABLOJ,"") + " " + SA2->A2_NREDUZ
  TRB->UNI        := BUSCA_UM(EI5->EI5_COD_I+EI5->EI5_FABR +EI5->EI5_FORN,EI5->EI5_CC+EI5->EI5_SI_NUM,IF(EICLOJA(),EI5->EI5_FABLOJ,""),IF(EICLOJA(),EI5->EI5_FORLOJ,""))//SO.:0022/02 OS.: 0153/02 IF( !EMPTY( SA5->A5_UNID ), SA5->A5_UNID, SB1->B1_UM )
  //TRB->EI5_QTDE   := EI5->EI5_QTDE                     
  //TRB->EI5_PRECO  := EI5->EI5_PRECO
  TRB->TOTPRECO   := EI5->(EI5_PRECO*EI5_QTDE)
  //TRB->EI5_DT_EMB := EI5->EI5_DT_EMB                   
  //TRB->EI5_DT_ENT := EI5->EI5_DT_ENT                   
  //TRB->EI5_DT_CAN := EI5->EI5_DT_CAN                    
  //TRB->EI5_MOTIVO := EI5->EI5_MOTIVO                   
  TRB->TRB_ALI_WT := "EI5"
  TRB->TRB_REC_WT := EI5->(RECNO())
  lRet:=.T.
  EI5->(dbSkip())
EndDo
Return lRet
