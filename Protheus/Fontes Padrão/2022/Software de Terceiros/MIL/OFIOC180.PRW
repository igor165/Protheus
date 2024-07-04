#Include "OFIOC180.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC180 ³ Autor ³  Thiago               ³ Data ³ 10/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro Diario de Servico                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC180()

Private aTit       := {{"","","","","","","","",ctod("   /   /   "),""}}
Private cCodConsul := space(06)
Private cNomConsul := space(40)
Private dDInicial  := ctod("  /  /  ") 
Private dDFinal    := ctod("  /  /  ")  
Private cNumero    := "1"  
Private aRotina   := MenuDef()
Private inclui := .f.
if !Pergunte("OFC180",.t.) 
   return
endif

nOpca := 1                             

cCodConsul := mv_par03
dDInicial  := mv_par01    
dDFinal    := mv_par02

dbSelectArea("VAI")
dbSetOrder(1)
if !dbSeek(xFilial("VAI")+mv_par03)
   MsgInfo(STR0003,STR0002)
Else
   cNomConsul := VAI->VAI_NOMTEC    
Endif      

   DEFINE MSDIALOG oDlg1 FROM 000,000 TO 023,077 TITLE STR0001 OF oMainWnd

   @ 018,009 SAY STR0004 SIZE 60,20 OF oDlg1 PIXEL COLOR CLR_BLUE
   @ 024,009 MSGET oCodConsul VAR cCodConsul  PICTURE "!!!!!!" VALID FS_CODCONSUL() F3 "VAI" SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
 
   @ 036,009 SAY STR0005 SIZE 60,20 OF oDlg1 PIXEL COLOR CLR_BLUE
   @ 042,009 MSGET oNomConsul VAR cNomConsul  PICTURE "@!"  SIZE 90,08 OF oDlg1 PIXEL COLOR CLR_HBLUE

   @ 018,130 SAY STR0006 SIZE 40,20 OF oDlg1 PIXEL COLOR CLR_BLUE
   @ 024,130 MSGET oDInicial VAR dDInicial PICTURE "@D" SIZE 50,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
   
   @ 036,130 SAY STR0007 SIZE 40,20 OF oDlg1 PIXEL COLOR CLR_BLUE
   @ 042,130 MSGET oDFinal VAR dDFinal  PICTURE "@D" SIZE 50,08 OF oDlg1 PIXEL COLOR CLR_HBLUE
   
   @ 056,003 LISTBOX oLbx1 FIELDS HEADER  OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010),OemToAnsi(STR0011),OemToAnsi(STR0012),OemToAnsi(STR0013),OemToAnsi(STR0014),OemToAnsi(STR0015),OemToAnsi(STR0016),OemToAnsi(STR0017);
     COLSIZES 10,30,10,40,80,30,40,60,30,60 SIZE 300,115 OF oDlg1 PIXEL ON DBLCLICK FS_CONSULTA(olbx1:nAt) 

   oLbx1:SetArray(aTit)
   oLbx1:bLine := { || {  aTit[oLbx1:nAt,1],;
                          aTit[oLbx1:nAt,2],;
                          aTit[oLbx1:nAt,3],;
                          aTit[oLbx1:nAt,4],;
                          aTit[oLbx1:nAt,5],;                    
                          aTit[oLbx1:nAt,6],;
                          aTit[oLbx1:nAt,7],;                                        
                          aTit[oLbx1:nAt,8],;
                          aTit[oLbx1:nAt,9],;
                          aTit[oLbx1:nAt,10]}}                        
     FS_INCLIST(cCodConsul,cNomConsul,dDInicial)
     ACTIVATE MSDIALOG oDlg1 CENTER ON INIT EnchoiceBar(oDlg1, {||  } , {|| nOpca := 2,oDlg1:End() })

Return

Static Function FS_INCLIST(cCodConsul,cNomConsul,dDInicial)  
	Processa( { || FS_LISTAOS(cCodConsul,cNomConsul,dDInicial) } )
Return

Static Function FS_LISTAOS(cCodConsul,cNomConsul,dDInicial)  

Local cDecricao := " "

dbSelectArea("VO1")
dbSetOrder(5)
dbSeek(xFilial("VO1")+dtos(dDInicial),.t.)            
           
cNumero := Str(val(cNumero))
nTit    := 0  
cOk     := "OK"
While !Eof() .and. xFilial("VO1") == VO1->VO1_FILIAL 
    
   if VO1->VO1_DATABE < dDInicial .or. VO1->VO1_DATABE > dDFinal  
      dbSelectArea("VO1")
      dbSkip()
      Loop
   Endif    
   if cCodConsul # VO1->VO1_FUNABE
      dbSelectArea("VO1")
      dbSkip()
      Loop
   Endif   

   dbSelectArea("VO2")
   dbSetOrder(1)
   dbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)  
   
   if VO1->VO1_STATUS == "L"
      cOk := "OK"  
   Else
      cOk := ""   
   Endif   

   While !Eof() .and. xFilial("VO2") == VO2->VO2_FILIAL .and. VO1->VO1_NUMOSV == VO2->VO2_NUMOSV
 
      cNumOs  := "" 
      dbSelectArea("VO4")
      dbSetOrder(1)
      if dbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)  
         While !Eof() .and. xFilial("VO4") == VO4->VO4_FILIAL .and. VO2->VO2_NOSNUM == VO4->VO4_NOSNUM
                     
            dbSelectArea("VV1")
            dbSetOrder(2)
            dbSeek(xFilial("VV1")+VO1->VO1_CHASSI)        
            
            dbSelectArea("SA1")
            dbSetOrder(1)
            dbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
      
            if VO2->VO2_NUMOSV == cNumOs 
               dbSelectArea("VO4")
               dbSkip()
               Loop
            Endif

            if VOK->VOK_AGRTIP == "1"
               cDecricao := STR0018
            Elseif VOK->VOK_AGRTIP == "2"
               cDecricao := STR0019
            Elseif VOK->VOK_AGRTIP == "3" 
               cDecricao := STR0020
            Elseif VOK->VOK_AGRTIP == "4" 
               cDecricao := STR0021
            Elseif VOK->VOK_AGRTIP == "5"
               cDecricao := STR0022
            Elseif VOK->VOK_AGRTIP == "6"
               cDecricao := STR0023
            Elseif VOK->VOK_AGRTIP == "7"
               cDecricao := STR0024
            Else 
               cDecricao := STR0025 
            Endif   

            if nTit == 0
               aTit := {}
               nTit := 1
            Endif
               
            aadd(aTit,{cNumero,VO1->VO1_NUMOSV,VO4->VO4_TIPTEM,VO4->VO4_FATPAR,SA1->A1_NOME,SA1->A1_TEL,VV1->VV1_PLAVEI,cDecricao,VO1->VO1_DATENT,cOk})
            IncProc(STR0001)

            cNumero := Str(val(cNumero)+1)
            cNumOs := VO2->VO2_NUMOSV
            dbSelectArea("VO4")
            dbSkip()
         Enddo   
      Endif 

      dbSelectArea("VO2")
      dbSkip()
   Enddo
   
   dbSelectArea("VO1")
   dbSkip()
Enddo
if len(aTit) > 0 
   oLbx1:SetArray(aTit)
   oLbx1:bLine := { || {  aTit[oLbx1:nAt,1],;
                          aTit[oLbx1:nAt,2],;
                          aTit[oLbx1:nAt,3],;
                          aTit[oLbx1:nAt,4],;
                          aTit[oLbx1:nAt,5],;                    
                          aTit[oLbx1:nAt,6],;
                          aTit[oLbx1:nAt,7],;                                        
                          aTit[oLbx1:nAt,8],;
                          aTit[oLbx1:nAt,9],;
                          aTit[oLbx1:nAt,10]}}                        
Endif
      
Return(.t.)

Static Function FS_CODCONSUL()
lRet := .t.
dbSelectArea("VAI")
dbSetOrder(1)                            
if !dbSeek(xFilial("VAI")+cCodConsul)
   MsgInfo(STR0003,STR0002)
   lRet := .f.
Endif 
Return(lRet)

Static Function FS_CONSULTA(nLin)  
Local cNumOS   := aTit[nLin,2]
dbSelectArea("VO1")
dbSetOrder(1)
dbSeek(xFilial("VO1")+cNumOS)
OC060("VO1",RECNO(),2)
Return

Static Function MenuDef()
Local aRotina := {{"", "",0,1},;
                  {"", "",0,2},;
                  {"", "",0,3},;
                  {"", "",0,4} }
Return aRotina
