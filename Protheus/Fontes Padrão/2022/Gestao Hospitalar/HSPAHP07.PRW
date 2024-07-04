#INCLUDE "HSPAHP07.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP07  º Autor ³ Manoel Filho       º Data ³  29/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Entrega de Laudos                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP07() 

cAlias := "GAD"
nOpcg  := 4
aRotina := {{OemtoAnsi(STR0001),"HS_PESQ()", 0 , 1},;     // "Pesquisar" //"Pesquisar"
           {OemtoAnsi(STR0002),"HSPAHP71(4)", 0 , 4}}       // "Alterar" //"Confirmar"

cCadastro := OemToAnsi(STR0003) //"Entrega de Laudos"
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

Function HSPAHP71()

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0, _ni := 0
nReg := 0
aGets := {}  // matriz que contem os campos que vao receber digitacao na enchoice
aTela := {}  // matriz que contem os campos que vao aparecer na enchoice
SetPrvt("wVar")
Private aTELA[0][0],aGETS[0] 
Private AHEADER := {}, ACOLS := {}
Private cTudOK  := cFieldOk := "Allwaystrue()"
Private cLinOk  := "HS_LOKP7()"

aRotina := {{OemtoAnsi(""),"", 0 , 1},; 
           {OemtoAnsi("") ,"", 0 , 2},;
           {OemtoAnsi("") ,"", 0 , 3},;
           {OemtoAnsi("") ,"", 0 , 4,2},;
           {OemtoAnsi("") ,"", 0 , 5,1}} 

aCodCli  := {STR0004,STR0005,STR0006,STR0007} //"0=Médica"###"1=Cirurgica"###"2=Obstetrica"###"3=Pediatrica"
aReinte  := {STR0008,STR0009} //"0=Não"###"1=Sim"
      
DbSelectArea("GAD")

M->GAD_REGATE := GAD->GAD_REGATE
M->GAD_NOME   := GAD->GAD_NOME   
M->GAD_CODCRM := GAD->GAD_CODCRM
M->GAD_CIDALT := GAD->GAD_CIDALT
M->GAD_CIDCMP := GAD->GAD_CIDCMP
M->GAD_CODCLI := GAD->GAD_CODCLI 
M->GAD_CODESP := GAD->GAD_CODESP
M->GAD_REINTE := GAD->GAD_REINTE
M->GAD_NOMMED := SPACE(30)
M->GAD_NOMESP := SPACE(30)
M->GAD_DESCID := SPACE(30)
M->GAD_ENTLAU := GAD->GAD_ENTLAU

dbSelectArea("SX5")
DBSetOrder(1)
Dbgotop()                                                       
DBSeek(xfilial("SX5")+"EM"+GAD->GAD_CODESP)
IF FOUND()
   M->GAD_NOMESP := X5_DESCRI
ENDIF

dbSelectArea("GAS")
DBSetOrder(1)
Dbgotop()                                                       
DBSeek(xfilial("GAS")+GAD->GAD_CIDALT)
IF FOUND()
   M->GAD_DESCID := GAS_PATOLO
ENDIF                      


//Tratamento do COMBOBOX Conforme as Variáveis
IF M->GAD_CODCLI == '0'
   M->GAD_CODCLI := STR0004 //"0=Médica"
 ELSEIF M->GAD_CODCLI == '1'
   M->GAD_CODCLI := STR0005 //"1=Cirurgica"
 ELSEIF M->GAD_CODCLI == '2'
   M->GAD_CODCLI := STR0006 //"2=Obstetrica"
 ELSEIF M->GAD_CODCLI == '3'
   M->GAD_CODCLI := STR0007 //"3=Pediatrica"
ENDIF                    

IF M->GAD_REINTE == '0'
   M->GAD_REINTE := STR0009 //"1=Sim"
 ELSE  
   M->GAD_REINTE := STR0008 //"0=Não"
ENDIF                       

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GAX03")
nUsado := 2
nOpc   := 4
nOpcG  := 4   
Altera := .T.
Inclui := .F.
Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
x3_tamanho, x3_decimal,x3_valid,;
x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
wVar  := "M->"+x3_campo
&wVar := CriaVar(x3_campo)

DbGoTop()
DbSeek("GAX04")
Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
x3_tamanho, x3_decimal,x3_valid,;
x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
wVar  := "M->"+x3_campo
&wVar := CriaVar(x3_campo)

DbSelectArea("GAX")
DbGotop()
DbSeek(xFilial("GAX")+M->GAD_REGATE)
aCols := {}
IF FOUND()
   For nCntFor := 1 TO FCount()
       M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next          
   While !eof() .and. GAX->GAX_REGATE == M->GAD_REGATE
         AADD(aCols,Array(nUsado+1))
         For _ni:=1 to 1
             aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
             &("M->"+fieldname(FieldPos(aHeader[_ni,2])))   := FieldGet(FieldPos(aHeader[_ni,2]))
         Next                      
         DbSelectArea("GAR")
         DbSeek(xFilial("GAR")+GAX->GAX_CODAIH)  
         aCols[Len(aCols),nUsado]:= GAR->GAR_DESC
         aCols[Len(aCols),nUsado+1]:=.F.
         DbSelectArea("GAX")
         dbSkip()
    Enddo
  Else
    DbSelectArea("GAX")
    aCols:={Array(nUsado+1)}
    aCols[1,nUsado+1]:=.F.
    For _ni:=1 to nUsado
        aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
    Next
Endif    

dbSelectArea("SRA")
DBSetOrder(11)
Dbgotop()    
DBSeek(XFILIAL("SRA")+GAD->GAD_CODCRM)
IF FOUND()
   M->GAD_NOMMED := SRA->RA_NOME
ENDIF

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) From 11,14 to 30,93	of oMainWnd	 //"Entrega de Laudos"

SetEnch("")
@ 011,000 FOLDER oFolder SIZE 313,133 OF oDlg PROMPTS STR0010,STR0011 PIXEL //"Dados Gerais"###"Procedimentos"
	
&& Abas do Folder
INIFOLDER("oFolder")

FS_ABA(1)
		
@ 011,008 Say OemToAnsi(STR0012) Size 40,0 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Nro Registro"
@ 011,053 MSGet o01 var M->GAD_REGATE Picture "@!" Size 45,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.

@ 022,008 Say OemToAnsi(STR0013) Size 40,0 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Nome"
@ 022,053 MSGet o02 var M->GAD_NOME Picture "@!" Size 200,7 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.

@ 033,008 SAY OemToAnsi(STR0014) Size 40,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Codigo Clinica"
@ 033,053 MSCOMBOBOX o05 VAR M->GAD_CODCLI Valid HS_Gets(01) SIZE 44,9 OF oFolder:aDialogs[1] COLOR CLR_BLACK;
          ITEMS aCodCli PIXEL
	
@ 044,008 Say OemToAnsi(STR0015) Size 40,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Especialidade"
@ 044,053 MSGet o06 var M->GAD_CODESP F3 "EM" Picture "@!" Valid HS_Gets(02) Size 44,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK
@ 044,167 Say OemToAnsi(STR0016) Size 40,9  OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK //"Descr. Espec."
@ 044,205 MSGet o07 var M->GAD_NOMESP Size 100,7 OF oFolder:aDialogs[1]  PIXEL COLOR CLR_BLACK When .f.

@ 055,008 Say OemToAnsi(STR0017) Size 40,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"CRM Medico"
@ 055,053 MSGet o08 var M->GAD_CODCRM F3 "MED" Picture "@!" Valid HS_Gets(03) Size 44,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK
@ 055,167 Say OemToAnsi(STR0018) Size 40,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK //"Nome Medico"
@ 055,205 MSGet o09 var M->GAD_NOMMED Size 100,7 OF oFolder:aDialogs[1]  PIXEL COLOR CLR_BLACK  when .f.

@ 066,008 Say OemToAnsi(STR0019) Size 44,7 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Reinternacao"
@ 066,053 MSCOMBOBOX o10 VAR M->GAD_REINTE Valid HS_Gets(04) SIZE 44,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK;
          ITEMS aReinte 

@ 077,008 Say OemToAnsi(STR0020) Size 34,7 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Cid"
@ 077,053 MSGet o15 var M->GAD_CIDALT F3 "GAS" Picture "@!" Valid HS_Gets(05) size  44,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK 
@ 077,098 MSGet o16 var M->GAD_DESCID size  206,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.

@ 088,008 Say OemToAnsi(STR0021) Size 44,7 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Cid Complementar"
@ 088,053 MSGet o17 var M->GAD_CIDCMP size 200,7 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK 

@ 099,008 Say OemToAnsi(STR0022) Size 44,7 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE //"Data Entrega"
@ 099,053 MSGet o17 var M->GAD_ENTLAU Valid HS_Gets(06) SIZE 44,9 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK

FS_ABA(2)
	
oGetDados:=MsGetDados():New(00,00,120,311,nOpcG,cLinOk,cTudOk,"",.T.,,,,,cFieldOk,,,,oFolder:aDialogs[2])   
oGetDados:oBrowse:bChange := {|| HS_LmpP7() }
	
oFolder:bSetOption := {|| FS_SETOPT(oFolder:nOption) }
oFolder:bChange    := {|| FS_ABA(oFolder:nOption) }
		

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(nOpca==1,oDlg:End(),.f.),FS_SETOPT(oFolder:nOption)},{|| oDlg:End(), FS_ABA(1) })
    
if nOpca == 1
   FS_GRAVAL()
Endif   

Return 

// Validacao dos Gets
///////////////////////////////
Static Function HS_Gets(nPar)

if nPar == 01 // Código da Clínica
	M->GAD_CODCLI := SUBSTR(M->GAD_CODCLI,1,1)  
 Elseif nPar == 02 //Codigo da Especialidade
        if !HS_SeekRet("SX5","'EM'+M->GAD_CODESP",1,.f.,"GAD_NOMESP","X5_DESCRI")
		MsgStop(STR0023,STR0024) //"Especialidade Invalida!"###"Atenção"
		Return .f.
	Endif
 Elseif nPar == 03  //CRM do Médico
        if !HS_SeekRet("SRA","M->GAD_CODCRM",11,.f.,"GAD_NOMMED","RA_NOME")
		MsgStop(STR0025,STR0024) //"CRM Invalido!"###"Atenção"
		Return .f.
	Endif
 Elseif nPar == 04 // Reinternação
	M->GAD_REINTE := SUBSTR(M->GAD_REINTE,1,1)
 Elseif nPar == 05  //CID DA ALTA
        if !HS_SeekRet("GAS","M->GAD_CIDALT",1,.f.,"GAD_DESCID","GAS_PATOLO")
		MsgStop(STR0026,STR0024) //"CID Invalido!"###"Atenção"
		Return .f.
	Endif
 Elseif nPar == 06  // Data da Entrega
    if !EMPTY(M->GAD_ENTLAU)
       if M->GAD_ENTLAU # DATE()
          MsgStop(STR0027,STR0024) //"A Data de Entrega Não Pode Ser Diferente da Data de Hoje!"###"Atenção"
   	      Return .f.
       endif 
    endif   
Endif
Return .t.          
      
Static Function FS_GRAVAL() 
    Local i := 0
    DbSelectArea("GAD")
    RecLock("GAD",.f.)
    GAD->GAD_CODCRM := M->GAD_CODCRM
    GAD->GAD_CIDALT := M->GAD_CIDALT
    GAD->GAD_CIDCMP := M->GAD_CIDCMP
    GAD->GAD_CODCLI := M->GAD_CODCLI
    GAD->GAD_CODESP := M->GAD_CODESP
    GAD->GAD_REINTE := M->GAD_REINTE
    GAD->GAD_ENTLAU := M->GAD_ENTLAU
    MsUnlock()        
	
    For i:=1 to len(aCols)
         dbselectArea("GAX")
         wProcura := dbseek(xFilial("GAX")+M->GAD_REGATE+aCols[i,1])
         If aCols[i,len(aCols[i])] .And. wProcura // exclusao
            RecLock("GAX",.F.,.T.)
            dbdelete()
            MsUnlock()
            WriteSx2("GAX")
  	     Else
            If !aCols[i,len(aCols[i])]
	           RecLock("GAX",If(wProcura,.F.,.T.))
	           GAX->GAX_FILIAL := xFilial("GAX")
	           GAX->GAX_REGATE := M->GAD_REGATE
	           GAX->GAX_CODAIH := aCols[i,1] 
               MsUnlock()                  
	        Endif 
		 Endif
    Next   
       
Return .t.                                                            

Static Function INIFOLDER(oObj)

Local i:=0 , nOpcA := Len(&(oObj):aDialogs)

For i:=1 to nOpcA
	DEFINE SBUTTON  FROM 1000,1000 TYPE 13 ACTION .t.  ENABLE OF &(oObj):aDialogs[i]
Next

Return

////////////////////////////
Static Function FS_ABA(nAba,lVz)
//aHeader := {}
If nAba == 1
	
EndIf    
Return

///////////////////////////////
Static Function FS_SETOPT(nAba,lVz)

// Local nColuna := 0

If nAba == 1
	
	if lVz
		//      aColsPropr   := Aclone( aCols )
	Else
		//      aColsTotal   := Aclone( aCols )
	Endif
	
Else
	
	//   aColsPropr   := Aclone( aCols )
	
EndIf


//Função de Validação de Linhas da GetDados de Procedimentos
Function HS_LOKP7()
 Local lOk := 0
for lOk := 1 to Len(aCols)
    if empty(alltrim(aCols[lOk,1])) .and. !aCols[lOk,len(aCols[lOk])]
       Return .f.
    Endif
Next
Return .t.

//Função de Validação de Linhas da GetDados de Procedimentos
Function HS_LmpP7()
if empty(alltrim(aCols[n,1]))
   aCols[n,2]  := Space(45)
   M->GAX_DESC := Space(45)        
   oGetDados:oBrowse:Refresh()
endif
Return .t.
