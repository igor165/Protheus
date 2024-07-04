#include "topconn.ch"
#include "protheus.ch"

Function SJRP0001()     
 Local oDlgArq, oMosArq, cMosArq := " ", aMosArq := {"1-Vazio", "2-Cheio"}
 Local oLbxSx2, cLbxSx2 := "", aLbxSx2 := {}
 
 Local oPanCBx, aObjects := {}, aInfo := {}, aPObjs := {}
 
 Local oArqIni, cArqIni := Space(Len(SX2->X2_CHAVE))
 Local oArqFin, cArqFin := Space(Len(SX2->X2_CHAVE))
 
 Local oEmpOri, cEmpOri := SM0->M0_CODIGO
 Local oEmpDes, cEmpDes := Space(Len(SM0->M0_CODIGO))
 
 Local oProcessa, oSaida, oDropa, oSx2Base
  
 Local oTik := LoadBitmap( GetResources(), "LBTIK" )
 Local oNo  := LoadBitmap( GetResources(), "LBNO" )   
 
 Local cFiltroSx2 := ""
 
 DbSelectArea("SX2")
 
 cFiltroSx2 := DbFilter()
 
 DbClearFilter()
 
 aAdd(aLbxSx2, {.F., 0, Space(Len(SX2->X2_CHAVE)), Space(Len(SX2->X2_ARQUIVO)), Space(Len(SX2->X2_NOME)), Space(Len(SX2->X2_PATH)), Space(Len(SX2->X2_ARQUIVO))})
 
 aObjects := {}	
 AAdd( aObjects, { 100, 020, .T., .T., .T. } )	
 AAdd( aObjects, { 100, 080, .T., .T., .T. } )	
 
 aInfo  := { 000, 000, 500, 420, 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T.)
 
 DEFINE MSDIALOG oDlgArq TITLE "Verifica arquivos com informação" From 000, 000 To 500, 420 Pixel
  oPanCBx	:=	tPanel():New(aPObjs[1][1], aPObjs[1][2],, oDlgArq,,,,,, aPObjs[1][3], aPObjs[1][4])
  oPanCbx:Align := CONTROL_ALIGN_TOP
  
  @ 010, 004 SAY OemToAnsi("Mostra arquivos")         OF oPanCbx PIXEL COLOR CLR_BLUE
  @ 008, 045 MSCOMBOBOX oMosArq VAR cMosArq SIZE 44,9 OF oPanCbx COLOR CLR_BLACK ITEMS aMosArq PIXEL
  
  @ 025, 004 SAY OemToAnsi("Do arquivo")              OF oPanCbx PIXEL COLOR CLR_RED
  @ 023, 045 MSGET oArqIni VAR cArqIni PICTURE "@!"   OF oPanCbx PIXEL COLOR CLR_BLUE
  
  @ 040, 004 SAY OemToAnsi("Até o arquivo")           OF oPanCbx PIXEL COLOR CLR_RED
  @ 038, 045 MSGET oArqFin VAR cArqFin PICTURE "@!"   OF oPanCbx PIXEL COLOR CLR_BLUE
  
  @ 055, 004 SAY OemToAnsi("Empresa Origem")          OF oPanCbx PIXEL COLOR CLR_RED
  @ 052, 045 MSGET oEmpOri VAR cEmpOri PICTURE "@!" When .F. OF oPanCbx PIXEL COLOR CLR_BLUE
  
  @ 070, 004 SAY OemToAnsi("Empresa Destino")         OF oPanCbx PIXEL COLOR CLR_RED
  @ 068, 045 MSGET oEmpDes VAR cEmpDes PICTURE "@!" VALID FS_AbreSx2(cEmpDes) OF oPanCbx PIXEL COLOR CLR_BLUE
  
  @ 008, 095 BUTTON oProcessa PROMPT "Processa"  SIZE 50,15 ACTION Processa({|| FS_VerifArq(cMosArq, cArqIni, cArqFin, @aLbxSx2, oLbxSx2)}) OF oPanCbx PIXEL
  
  @ 028, 095 BUTTON oDropa    PROMPT "Drop"      SIZE 50,15 ACTION Processa({|| FS_DropaArq(aLbxSx2)}) OF oPanCbx PIXEL
  
  @ 048, 095 BUTTON oSx2Base  PROMPT "SX2 X DB"  SIZE 50,15 ACTION Processa({|| FS_Sx2DB(cArqIni, cArqFin, @aLbxSx2, oLbxSx2)}) OF oPanCbx PIXEL
  
  @ 068, 095 BUTTON oTrfEmpr  PROMPT "Emp 2 Emp" SIZE 50,15 ACTION Processa({|| FS_Emp2Emp(cEmpOri, cEmpDes, aLbxSx2)}) OF oPanCbx PIXEL
    
  @ 008, 155 BUTTON oSaida    PROMPT "Saida"     SIZE 50,15 ACTION oDlgArq:End() OF oPanCbx PIXEL
        
  @ aPObjs[2][1], aPObjs[2][2] LISTBOX oLbxSx2 VAR cLbxSx2 FIELDS HEADER " ", "Registros", "Alias", "Arquivo Origem", "Nome", "Path", "Arquivo Destino" COLSIZES 10, 30, 30, 75, 200, 200, 75 ;
                               SIZE aPObjs[2][3], aPObjs[2][4] OF oDlgArq PIXEL ;
                               ON DBLCLICK (aLbxSx2[oLbxSx2:nAt, 01] := !aLbxSx2[oLbxSx2:nAt, 01])
  oLbxSx2:Align := CONTROL_ALIGN_ALLCLIENT

  oLbxSx2:SetArray(aLbxSx2)

  oLbxSx2:bLine := {|| {IIf(!aLbxSx2[oLbxSx2:nAt, 01], oNo, oTik), aLbxSx2[oLbxSx2:nAt, 02], aLbxSx2[oLbxSx2:nAt, 03], aLbxSx2[oLbxSx2:nAt, 04], aLbxSx2[oLbxSx2:nAt, 05], aLbxSx2[oLbxSx2:nAt, 06], aLbxSx2[oLbxSx2:nAt, 07]}}

 ACTIVATE MSDIALOG oDlgArq CENTERED
 
 If !Empty(cFiltroSx2)
  DbSetFilter({|| &(cFiltroSx2)}, cFiltroSx2)
 EndIf 
Return(Nil)                        

Static Function FS_VerifArq(cMosArq, cArqIni, cArqFin, aLbxSx2, oLbxSx2)
 Local oTik  := LoadBitmap( GetResources(), "LBTIK" )
 Local oNo   := LoadBitmap( GetResources(), "LBNO" )                               
 Local cPath := ""

 If MsgYesNo("Confirma processamento")
 
  aLbxSx2 := {}
  
  DbSelectArea("SX2")               
  DbSetOrder(1)
  
  If Empty(cArqIni)
   DbGoTop()
  Else 
   DbSeek(cArqIni, .T.)
  EndIf 
  
  ProcRegua(RecCount())
  
  While !Eof() .And. IIf(!Empty(cArqFin), SX2->X2_CHAVE <= cArqFin, .T.)
                       
   IncProc("Verificando arquivo " + SX2->X2_CHAVE + "--" + SX2->X2_ARQUIVO)
  
   DbSelectArea(SX2->X2_CHAVE)                                                 
                              
   If (SubStr(cMosArq, 1, 1) == "1" .And. RecCount() == 0) .Or. ;
      (SubStr(cMosArq, 1, 1) == "2" .And. RecCount()  > 0)
                                     
    cPath := AllTrim(SX2->X2_PATH)
    cPath := PadR(IIf(SubStr(cPath, -1, 1) == "\", SubStr(cPath, 1, Len(cPath)-1), cPath), Len(SX2->X2_PATH))
                     
    If Select("SX2DES") > 0
     SX2DES->(DbSeek(SX2->X2_CHAVE))
     aAdd(aLbxSx2, {.T., RecCount(), SX2->X2_CHAVE, SX2->X2_ARQUIVO, SX2->X2_NOME, cPath, SX2DES->X2_ARQUIVO})
    Else                                                                                                      
     aAdd(aLbxSx2, {.T., RecCount(), SX2->X2_CHAVE, SX2->X2_ARQUIVO, SX2->X2_NOME, cPath, Space(Len(SX2->X2_ARQUIVO))})
    EndIf 
   
   EndIf
    
   DbSelectArea(SX2->X2_CHAVE)
   DbCloseArea()
   
   DbSelectArea("SX2")
   DbSkip()
  End      
  
  oLbxSx2:SetArray(aLbxSx2)
  oLbxSx2:bLine := {|| {IIf(!aLbxSx2[oLbxSx2:nAt, 01], oNo, oTik), aLbxSx2[oLbxSx2:nAt, 02], aLbxSx2[oLbxSx2:nAt, 03], aLbxSx2[oLbxSx2:nAt, 04], aLbxSx2[oLbxSx2:nAt, 05], aLbxSx2[oLbxSx2:nAt, 06], aLbxSx2[oLbxSx2:nAt, 07]}}
  oLbxSx2:Refresh()
 
 EndIf
 
Return(Nil)

Static Function FS_DropaArq(aLbxSx2)
 Local nForArq := 0                   
 
 If MsgYesNo("Todos os arquivos marcados serão excluidos. Confirma processamento")
 
  ProcRegua(Len(aLbxSx2))
                   
  For nForArq := 1 To Len(aLbxSx2)
              
   IncProc("Dropando arquivo " + aLbxSx2[nForArq, 3] + "--" + aLbxSx2[nForArq, 4])
              
   If aLbxSx2[nForArq, 1]
    #IFDEF TOP                                                                              
     DbSelectArea(aLbxSx2[nForArq, 3])
     DbCloseArea()                                                                          
     TCDelFile(AllTrim(aLbxSx2[nForArq, 4]))
    #ELSE                                                                                  
     DbSelectArea(aLbxSx2[nForArq, 3])
     DbCloseArea()                                                                          
     FErase(AllTrim(aLbxSx2[nForArq, 6]) + "\" + AllTrim(aLbxSx2[nForArq, 4]) + GetDbExtension())
     FErase(AllTrim(aLbxSx2[nForArq, 6]) + "\" + AllTrim(aLbxSx2[nForArq, 4]) + ".FPT")
     FErase(AllTrim(aLbxSx2[nForArq, 6]) + "\" + AllTrim(aLbxSx2[nForArq, 4]) + OrdBagExt())
    #ENDIF  
   EndIf 
  
  Next
 
 EndIf

Return(Nil)

Static Function FS_Sx2DB(cArqIni, cArqFin, aLbxSx2, oLbxSx2)
 Local oTik  := LoadBitmap( GetResources(), "LBTIK" )
 Local oNo   := LoadBitmap( GetResources(), "LBNO" )                               
 Local cPath := ""

 If MsgYesNo("Confirma processamento")
 
  aLbxSx2 := {}
  
  DbSelectArea("SX2")                                              
  DbSetOrder(1)
  
  If Empty(cArqIni)
   DbGoTop()
  Else 
   DbSeek(cArqIni, .T.)
  EndIf 
  
  ProcRegua(RecCount())
  
  While !Eof() .And. IIf(!Empty(cArqFin), SX2->X2_CHAVE <= cArqFin, .T.)
                       
   IncProc("Verificando arquivo " + SX2->X2_CHAVE + "--" + SX2->X2_ARQUIVO)
   
   cPath := AllTrim(SX2->X2_PATH)
   cPath := PadR(IIf(SubStr(cPath, -1, 1) == "\", SubStr(cPath, 1, Len(cPath)-1), cPath), Len(SX2->X2_PATH))
    
   #IFDEF TOP
    If !TCCanOpen(AllTrim(SX2->X2_ARQUIVO))
     aAdd(aLbxSx2, {.F., RecCount(), SX2->X2_CHAVE, SX2->X2_ARQUIVO, SX2->X2_NOME, cPath, Space(Len(SX2->X2_ARQUIVO))})
    EndIf
   #ELSE
    If !File(AllTrim(cPath) + "\" + AllTrim(SX2->X2_ARQUIVO) + "." + GetDbExtension())
     aAdd(aLbxSx2, {.F., RecCount(), SX2->X2_CHAVE, SX2->X2_ARQUIVO, SX2->X2_NOME, cPath})
    EndIf
   #ENDIF 
   
   DbSelectArea("SX2")
   DbSkip()
  End      
  
  oLbxSx2:SetArray(aLbxSx2)
  oLbxSx2:bLine := {|| {IIf(!aLbxSx2[oLbxSx2:nAt, 01], oNo, oTik), aLbxSx2[oLbxSx2:nAt, 02], aLbxSx2[oLbxSx2:nAt, 03], aLbxSx2[oLbxSx2:nAt, 04], aLbxSx2[oLbxSx2:nAt, 05], aLbxSx2[oLbxSx2:nAt, 06], aLbxSx2[oLbxSx2:nAt, 07]}}
  oLbxSx2:Refresh()
 
 EndIf

Return(Nil)

Static Function FS_Emp2Emp(cEmpOri, cEmpDes, aLbxSx2)
 Local cSql := "", nForArq := 0, cCpos := ""
 Local nRecNoI := 1, nRecNoF := 1024, nRecTot := 0
 
 If MsgYesNo("Todos os arquivos marcados serão importados da empresa [" + cEmpOri + "] para a empresa [" + cEmpDes + "]. Confirma processamento")
 
  ProcRegua(Len(aLbxSx2))
 
  For nForArq := 1 To Len(aLbxSx2)
   
   If aLbxSx2[nForArq, 1] .And. TCCanOpen(AllTrim(aLbxSx2[nForArq, 4])) .And. TCCanOpen(AllTrim(aLbxSx2[nForArq, 7]))
    
    IncProc("Exportando arquivo " + aLbxSx2[nForArq, 4] + " para " + aLbxSx2[nForArq, 7])
  
    DbSelectArea("SX3")
    DbSetOrder(1)
    DbSeek(aLbxSx2[nForArq, 3])  
    
    cCpos := ""
    
    While !Eof() .And. SX3->X3_ARQUIVO == aLbxSx2[nForArq, 3]
    
     If SX3->X3_CONTEXT <> "V" .And. SX3->X3_TIPO <> "M"
      cCpos += IIf(Empty(cCpos), "", ", ") + AllTrim(SX3->X3_CAMPO)
     EndIf 
    
     DbSkip()
    End                                                                   
    
    cCpos += ", R_E_C_N_O_"
    
    cSql := "SELECT MAX(R_E_C_N_O_) nRecTot FROM " + AllTrim(aLbxSx2[nForArq, 4])
    TCQuery cSql New Alias "ARQRCNT"
    
    nRecTot := ARQRCNT->nRecTot
    
    DbCloseArea()
    
    For nRecNoI := 1 To nRecTot Step 1024
                              
     nRecNoF := nRecNoI + 1023
     
     cSql := "DELETE FROM " + AllTrim(aLbxSx2[nForArq, 7]) + " WHERE R_E_C_N_O_ BETWEEN " + AllTrim(Str(nRecNoI)) + " AND " + AllTrim(Str(nRecNoF))
     TCSqlExec(cSql)
         
    Next
    
    For nRecNoI := 1 To nRecTot Step 1024
    
     nRecNoF := nRecNoI + 1023
   
     cSql := "INSERT INTO " + AllTrim(aLbxSx2[nForArq, 7]) + " (" + cCpos + ") SELECT " + cCpos + " FROM " + AllTrim(aLbxSx2[nForArq, 4]) + ;
             " WHERE D_E_L_E_T_ <> '*' AND R_E_C_N_O_ BETWEEN " + AllTrim(Str(nRecNoI)) + " AND " + AllTrim(Str(nRecNoF))
     TCSqlExec(cSql)
     
    Next                         
    
   EndIf 
   
  Next 
 
 EndIf
Return(Nil)

Static Function FS_AbreSx2(cEmpDes)
 Local lRet := .T.
 
 If (lRet := File("SX2" + cEmpDes + "0" + GetDbExtension()))

  If Select("SX2DES") > 0
   DbSelectArea("SX2DES")
   DbCloseArea()
   ConOut("Fechou alias [SX2DES][SX2" + cEmpDes + "0]")
  EndIf
  
  DbUseArea(.T., __LOCALDRIVER, "SX2" + cEmpDes + "0", "SX2DES", .F., .F.)
  
  If Select("SX2DES") > 0
   DbSetIndex("SX2" + cEmpDes + "0")
   ConOut("Arquivo [SX2DES][SX2" + cEmpDes + "0] aberto")
  Else                                                   
   ConOut("falha na abertura do arquivo [SX2DES][SX2" + cEmpDes + "0]")
   HS_MsgInf("falha na abertura do arquivo [SX2DES]", "Atenção", "[SX2" + cEmpDes + "0]")
  EndIF 
  
 Else
  
  ConOut("Arquivo [SX2DES][SX2" + cEmpDes + "0] não encontrado")
  HS_MsgInf("Arquivo não encontrado", "Atenção", "[SX2" + cEmpDes + "0]")   
  
 EndIf
Return(lRet)