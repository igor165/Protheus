#Include "EICDI900.CH"
#include "Average.ch"
//#include "FiveWin.ch"

*--------------------------------*
FUNCTION EICDI900()
*--------------------------------*
LOCAL nOpca := 0
Local aSays := {}, aButtons := {}
LOCAL aCRA:={ OemToAnsi(STR0001),OemToAnsi(STR0002),OemToAnsi(STR0003)}  //"Confirma"### "Redigita"###"Abandona"
LOCAL cCadastro := OemtoAnsi(STR0004)  //"Lan‡amentos Contabeis Off-Line"

IF EasyGParam("MV_EASYFIN",,"N") $ cNao
   RETURN .T.//RETORNAR SEMPRE VERDADEIRO
ENDIF

PRIVATE aRotina := { { OemToAnsi(STR0005) ,"AllwaysTrue", 0 , 3} }  //"Parametros"
PRIVATE Inclui:=.T.
PRIVATE Altera:=.F.

AADD(aSays,OemToAnsi( STR0006 ) )
AADD(aSays,OemToAnsi( STR0007 ) )
AADD(aSays,OemToAnsi( STR0008 ) )
AADD(aSays,OemToAnsi( STR0009 ) )

AADD(aButtons, { 5,.T.,{|| Pergunte("EICFI4",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons,,240,405 )

If	nOpca ==1
	Processa({|| DI900CONTABOFF() })  // Chamada da funcao de recalculos
Else
	Return .T.
Endif
Return .T.



*------------------------------------------*
STATIC FUNCTION DI900CONTABOFF()      
*------------------------------------------*
LOCAL cFilSW2:= xFilial("SW2")
LOCAL cFilSW6:= xFilial("SW6")
LOCAL cFilSW7:= xFilial("SW7")
LOCAL cFilSW8:= xFilial("SW8")
LOCAL cFilSW9:= xFilial("SW9")
LOCAL cFilSWD:= xFilial("SWD")
LOCAL cFilSA2:= xFilial("SA2")
LOCAL cFilSY4:= xFilial("SY4")
LOCAL cFilSYW:= xFilial("SYW")
SW2->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(3))
SWD->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SY4->(DBSETORDER(1))
SYW->(DBSETORDER(1))
oDlgProc:= GetWndDefault()
nTotal  := 0
nCont   := 0

Contabeic('HEADER',,.F.) 

ProcRegua(50)    
SW6->(DBSEEK(cFILSW6))

DO WHILE !SW6->(EOF()) .AND. SW6->W6_FILIAL == cFilSW6

   DI8900INCPROC("Proc.:"+SW6->W6_HAWB)

   IF SW6->W6_TIPOFEC == "DIN"
      SW6->(DBSKIP())
      LOOP
   ENDIF  

   IF EMPTY(SW6->W6_DTLANCF)
      SW7->(DBSEEK(cFilSW7+SW6->W6_HAWB))
      SW2->(DBSEEK(cFilSW2+SW7->W7_PO_NUM))
      IF BuscaPPCC()=='CC'//FCD 30/04/02                         
         IF SY4->(DBSEEK(cFilSY4+SW6->W6_AGENTE)) .AND. ;
            SA2->(DBSEEK(cFilSA2+SY4->Y4_FORN +SY4->Y4_LOJA))   
            Contabeic('DETAIL','992',.F.) // INCLUSAO FRETE
         ENDIF  
      ENDIF           
   ENDIF   
   
   IF EMPTY(SW6->W6_DTLANCS).AND. SYW->(DBSEEK(cFilSYW+SW6->W6_CORRETO)) .AND.;
      SA2->(DBSEEK(cFilSA2+SYW->YW_FORN+SYW->YW_LOJA))
      Contabeic('DETAIL','993',.F.) // SEGURO INCLUSAO 
   ENDIF                    
      
   // LENDO Invoices
   SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))
   DO WHILE !SW9->(EOF()) .AND. cFilSW9 == SW9->W9_FILIAL .AND. SW6->W6_HAWB == SW9->W9_HAWB
    
      DI8900INCPROC("Inv.:"+SW9->W9_INVOICE)
      SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN))
      IF !FI400FornBanco(SW8->W8_PO_NUM,SW8->W8_PGI_NUM)
         IF !(SW2->W2_E_LC $ cSim)
            SA2->(DBSEEK(cFilSA2+SW9->W9_FORN))
         ELSE
            SA2->(DBSEEK(cFilSA2+SPACE(LEN(SA6->A6_CODFOR+SA6->A6_LOJFOR))))
         ENDIF
      ENDIF
      IF EMPTY(SW9->W9_DTLANC)                                         
         Contabeic('DETAIL','991',.F.)
      ENDIF                    
      
      SW9->(DBSKIP())
   
   ENDDO
   
   // LENDO Despesas
   SWD->(DBSEEK(cFILSWD+SW6->W6_HAWB))
   DO WHILE !SWD->(EOF()) .AND. cFilSWD == SWD->WD_FILIAL .AND. SW6->W6_HAWB == SWD->WD_HAWB                           
   
      DI8900INCPROC("Desp.:"+SWD->WD_DESPESA)
      IF SWD->WD_DESPESA # "901"
         SWD->(DBSKIP())                                                              
         LOOP
      ENDIF  
      SA2->(dbSeek(cFilSA2+SWD->WD_FORN+SWD->WD_LOJA))
      IF EMPTY(SWD->WD_DTLANC)
         Contabeic('DETAIL','994',.F.) // DESPACHANTE INCLUSAO
      ENDIF                    
      SWD->(DBSKIP())
   
   ENDDO
    
   SW6->(DBSKIP())

ENDDO               

SW9->(DBSETORDER(1))

Contabeic('FOOTER',,.F.) 

RETURN .T.

*---------------------------------------------*
STATIC FUNCTION DI8900INCPROC(cTexto)
*---------------------------------------------*
oDlgProc:SetText("Registros Lidos: "+ALLTRIM(STR(nTotal,10)))
nTotal++

IF nCont > 50
   ProcRegua(50)    
   nCont:=0
ENDIF                                

INCPROC(cTexto)
nCont++

RETURN .T.
