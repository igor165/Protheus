#INCLUDE "HSPAHP08.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP08  º Autor ³ Manoel Filho       º Data ³  29/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Alteração do Nº de AIH                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP08() 

cAlias := "GAD"
nOpcg  := 4
aRotina := {{OemtoAnsi(STR0001),"HS_PESQ()", 0 , 1},;     // "Pesquisar" //"Pesquisar"
           {OemtoAnsi(STR0002),"HSPAHP81(4)", 0 , 4}}       // "Alterar" //"Confirmar"

cCadastro := OemToAnsi(STR0003) //"Alteracao do Nro. da AIH"
lSai  := .F.   
nOpca := 0

SetPrvt("nOpc,nOpcg,aVetTipD","nLinhas")

Private AHEADER  := {}, ACOLS := {}

dbSelectArea("GAD")
Dbgotop()
RetIndex()
                         
dbSelectArea("SX3")
dbSeek("GAD")
While !Eof().and.(x3_arquivo=="GAD")
	wVar := "M->"+x3_campo
	dbSkip()
EndDo

mBrowse( 6, 1,22,75,"GAD",,"GAD_TPALTA")

Return NIL

Function HSPAHP81()

Local bCampo     := { |nCPO| Field(nCPO) }

Private aTELA[0][0],aGETS[0] 
Private AHEADER := {}, ACOLS := {}

aRotina := {{OemtoAnsi(""),"", 0 , 1},; 
           {OemtoAnsi("") ,"", 0 , 2},;
           {OemtoAnsi("") ,"", 0 , 3},;
           {OemtoAnsi("") ,"", 0 , 4,2},;
           {OemtoAnsi("") ,"", 0 , 5,1}} 
      
DbSelectArea("GAD")

M->GAD_REGATE := GAD->GAD_REGATE
M->GAD_NOME   := GAD->GAD_NOME   
M->GAD_NOMMED := SPACE(30)
M->GAD_NRGUIA := GAD_NRGUIA


DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) From 11,14 to 20,93	of oMainWnd	 //"Alteracao do Nro. da AIH"

		
@ 022,008 Say OemToAnsi(STR0004) Size 40,0 OF oDlg PIXEL COLOR CLR_BLUE //"Nro Registro"
@ 022,053 MSGet o01 var M->GAD_REGATE Picture "@!" Size 45,9 OF oDlg PIXEL COLOR CLR_BLACK When .f.

@ 033,008 Say OemToAnsi(STR0005) Size 40,0 OF oDlg PIXEL COLOR CLR_BLUE //"Nome"
@ 033,053 MSGet o02 var M->GAD_NOME Picture "@!" Size 200,7 OF oDlg PIXEL COLOR CLR_BLACK When .f.

@ 044,008 Say OemToAnsi(STR0006) Size 44,7 OF oDlg PIXEL COLOR CLR_BLUE //"Nro.da AIH"
@ 044,053 MSGet o17 var M->GAD_NRGUIA  SIZE 80,9 OF oDlg PIXEL COLOR CLR_BLACK

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,{||nOpca:=1, oDlg:End(),.F.}, {|| oDlg:End(),.F.})
    
if nOpca == 1
   FS_GRAGUIA()
Endif   

Return 
      
Static Function FS_GRAGUIA() 
    DbSelectArea("GAD")
    RecLock("GAD",.f.)
    GAD->GAD_NRGUIA := M->GAD_NRGUIA
    MsUnlock()        
Return .t.                                                            
