#INCLUDE "HSPAHM14.ch"
#include "protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM14  บ Autor ณ MARIO ARIZONO      บ Data ณ  27/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMovimentacao de emprestimo                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM14()

 Private cGcsTipLoc  := "A" 
 Private cCadastro := STR0001 //"Movimenta็๕es do Empr้stimo"
 Private aRotina := MenuDef()


 DbSelectArea("GFG")
 DbSetOrder(1)  //GFG_FILIAL + GFG_SEQEMP                             
 mBrowse(06, 01, 22, 75, "GFG",,,,,,,,,,,,,,)

Return(Nil)            	


Function HS_Mn14(cAliasM14, nRegM14, nOpcM14)
 
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local oEnGfg, oDlgM14, nOpcDlg := 0 
 Local bKeyF4, bkeyF5
 Local nEnOpc := aRotina[nOpcM14, 4]
 Local nGDOpc := IIf(aRotina[nOpcM14, 4] == 2 .OR. nOpcM14 == 4 .OR. aRotina[nOpcM14, 4] == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)     
 Local aButtons := {}
 Local bFS_MosIten := "", bFS_Estorno := ""    
 
 Private aTela := {}, aGets := {}
 Private aCGFH := {}, aHGFH := {}, nUGFH := 0
 Private aHMM  := {}, aCMM  := {}, nUMM  := 0, oGDMM    
 Private aProd := {}

 Private nGFHSeqemp  := 0
 Private nGFIProemp  := 0, nGFITipmov := 0, nGFIDatMov := 0, nGFIHormov := 0, nGFINumSeq := 0
 Private nGFISeqMov  := 0, nGFICbmatm := 0, nGFILoteCT := 0, nGFISeqemp := 0, nGFILoteFo := 0 
 Private nGFIDtVali  := 0, nGFINumlot := 0,    nLenGFI := 0, nGFIQtdmov := 0, nGFIProAlt := 0
 Private nGFIDPrAlt  := 0, nGFIDesPro := 0

 Private oMosItens, oEstorno   
 Private lGravou := .F.    

 Private __aRLote   := {{"oGDMM:aCols[oGDMM:nAt, nGFINumLot]", "SB8->B8_NUMLOTE"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nGFILoteFo]", "SB8->B8_LOTEFOR"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nGFILoteCt]", "SB8->B8_LOTECTL"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nGFIDtVali]", "SB8->B8_DTVALID"}}    
                        
 Private __MMQtdDe   := CRIAVAR("GFI_QTDMOV")                       
            
 Private __fVMatMed  := "IIF(oGDMM:aCols[oGDMM:nAt,nGFITipmov] == '1', HS_M14VSLD(IIF(Empty(__cProAlt), M->GFI_PROEMP, __cProAlt),M->GFG_ALMORI,oGDMM:aCols[oGDMM:nAt,nGFIQtdmov]),.T.)" 
 Private __cProAlt   := ""
 Private   lVldSet   := .F. 

 If nOpcM14 == 5 
  DbselectArea("GFI")
  DbSetOrder(1) // GFI_FILIAL + GFI_SEQEMP + GFI_SEQMOV + GFI_PROEMP + GFI_TIPMOV + GFI_DATMOV + GFI_HORMOV
  If Dbseek(xFilial("GFI") + GFG->GFG_SEQEMP)
   HS_MsgInf(STR0008, STR0009, STR0033) //"Empr้stimo solicitado nใo pode ser excluํdo, pois possui movimenta็๕es."###"Aten็ใo"###"Movimenta็ใo de empr้stimo"
   Return(nil)
  Endif
 Endif
 
 If !HS_VldPar(StrTran(aRotina[nOpcM14, 1], "&", ""))
  Return(Nil)
 Endif 
 
 Aadd(aButtons	,{'PARAMETROS', {||Eval(bFS_MosIten)}, STR0010, STR0011})    //"Mostra Itens da movimenta็ใo"###"Itens"
 bKeyF5 := SetKey( VK_F5, { || Eval(bFS_MosIten)})
 bKeyF4 := SetKey(VK_F4, {|| IIF(oGDMM:aCols[oGDMM:nAt, nGFITipmov] <> "0", HS_SelLote(oGDMM:aCols[oGDMM:nAt, nGFIProemp], M->GFG_ALMORI, oGDMM:aCols[oGDMM:nAt, nGFIQtdmov]), 0)})
    
	RegToMemory("GFG",(nOpcM14 == 3))  
                         
 HS_BDados("GFH", @aHGFH, @aCGFH, @nUGFH, 1, M->GFG_SEQEMP, "GFH->GFH_SEQEMP == '" + M->GFG_SEQEMP + "'")
 
 nGFHSeqemp  := aScan(aHGFH, {|aVet| AllTrim(aVet[2]) == "GFH_SEQEMP"}) 
 nGFHSeqMov  := aScan(aHGFH, {|aVet| AllTrim(aVet[2]) == "GFH_PROEMP"}) 

 nGFHItemSeq := aScan(aHGFH, {|aVet| AllTrim(aVet[2]) == "GFH_ITEEMP"})

 nLenGFI := HS_BDados("GFI", @aHMM, @aCMM, @nUMM, 1, M->GFG_SEQEMP, "GFI->GFI_SEQEMP == '" + M->GFG_SEQEMP + "'",,,,,,,,,,,,,,,,,,,)
 
 nGFISeqemp  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_SEQEMP"}) 
 nGFISeqMov  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_SEQMOV"}) 
 nGFICbMatm  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_CBMATM"}) 
 nGFIProemp  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_PROEMP"})
 nGFITipmov  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_TIPMOV"})
 nGFIDatmov  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_DATMOV"})
 nGFIHormov  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_HORMOV"})     
 nGFILoteFo  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_LOTEFO"})
 nGFILoteCT  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_LOTECT"})
 nGFINumlot  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_NUMLOT"})
 nGFIDtVali  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_DTVALI"})  
 nGFIQtdmov  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_QTDMOV"})    
 nGFINumSeq  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_NUMSEQ"})
 nGFIProAlt  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_PROALT"})  
 nGFIDPrAlt  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_DPRALT"})  
 nGFIDesPro  := aScan(aHMM, {|aVet| AllTrim(aVet[2]) == "GFI_DESPRO"})  
    
 DbSelectArea("GFI")
 DbSetOrder(1) // GFI_FILIAL + GFI_SEQEMP + GFI_SEQMOV + GFI_PROEMP + GFI_TIPMOV + GFI_DATMOV + GFI_HORMOV
 
 If aRotina[nOpcM14, 4]== 3 .OR. aRotina[nOpcM14, 4]<> 3 .AND. !DBSEEK(xFilial("GFI") + M->GFG_SEQEMP)
  aCMM[1, nGFISeqmov] := Soma1(aCMM[1, nGFISeqmov], Len(aCMM[1, nGFISeqmov])) 
 EndIf 
 
 If (nOpcM14 == 4 .and. nLenGFI > 0) .OR. nOpcM14 == 6 .OR. nOpcM14 == 5 
  nEnOpc := 2
 Endif                                    
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 035, .T., .T. } )	                            
 AAdd( aObjects, { 100, 065, .T., .T. } )	
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
  
 DEFINE MSDIALOG oDlgM14 TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oEnGFG := MsMGet():New("GFG", nRegM14,nEnOpc,,,,, aPObjs[1],,,, 2)
  oEnGFG:oBox:align := CONTROL_ALIGN_TOP
       
  oGDMM := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],nGDOpc,,,"+GFI_SEQMOV",,,,,,,, aHMM, aCMM)
  oGDMM:oBrowse:align := CONTROL_ALIGN_ALLCLIENT                
  oGDMM:oBrowse:bdelete:= {|| IIF (nOpcM14 == 3 .OR. nOpcM14 == 6,IIF(FS_VLDDEL("GFI",nOpcm14),oGDMM:DelLine(),.F.),0)} 
  
  bFS_MosIten :={||IIF(FS_CFMGRV(nOpcM14), FS_MosItens(M->GFG_SEQEMP),0)}
     
 ACTIVATE MSDIALOG oDlgM14 ON INIT EnchoiceBar(oDlgM14, ;
                                  {|| nOpcDlg := 1, IIF(Obrigatorio(aGets, aTela) .and. ;
                                  	 HS_M14TOK("GFI", oGDMM, nGFITipmov) .And. ;              
                                    HS_M14TOK("GFI", oGDMM, nGFICbmatm); 
                                    , oDlgM14:End(), nOpcDlg := 0)}, ;
                                  {|| nOpcDlg := 0, oDlgM14:End()},,aButtons)

 If  nOpcDlg == 0
  While __lSx8
   RollBackSxe()
  End
 ElseIf nOpcDlg == 1
  Begin Transaction
   FS_GrvM14(nOpcM14)
  End Transaction
  
  While __lSx8
   ConfirmSx8()
  End  
 Endif     
 
 
 SetKey(VK_F4, bKeyF4)
 SetKey(VK_F5, bKeyF5)    
  
Return(Nil)                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVM14 บ Autor ณ MARIO ARIZONO      บ Data ณ  27/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gravacao dos dados                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvM14(nOpcM14)

 Local nItensGFI := 0, nItensGFH:=0, nItensExc := 0,  nPos := 0, nPosGFH := 0, nPosExc := 0                                          
 Local lFoundGFG := .F., 	lFoundGFI := .F., lFoundGFH := .F.
 Local aVetGFH   := {}, aVetExc := {}
 Local cSeqItem := "000" 
 
 If aRotina[nOpcM14, 4] <> 2
	 Begin Transaction
	  DbSelectArea("GFG")
	  DbSetOrder(1) // GFG_FILIAL + GFG_SEQEMP
	  If aRotina[nOpcM14, 4] == 3 .AND. !lGravou// Inclusao
    M->GFG_SEQEMP := HS_VSxeNum("GFG", "M->GFG_SEQEMP", 1)
   Else
    lFoundGFG := DbSeek(xFilial("GFG") + M->GFG_SEQEMP)
   EndIf
   
   If aRotina[nOpcM14, 4] <> 5
    RecLock("GFG", !lFoundGFG)
     HS_GrvCpo("GFG")
     GFG->GFG_FILIAL := xFilial("GFG")    
     GFG->GFG_DATLOG := Ddatabase
     GFG->GFG_HORLOG := Time()
     GFG->GFG_USULOG := cUserName
     GFG->GFG_LOGARQ := HS_LOGARQ()
    MsUnLock() 
    
    If !Empty(oGDMM:aCols[1,nGfiCbmatm])         
 	   For nItensGFI := 1 To Len(oGDMM:aCols)
	 	   DbSelectArea("GFI")
 	 	  DbSetOrder(1) // GFI_FILIAL + GFI_SEQEMP + GFI_SEQMOV + GFI_PROEMP + GFI_TIPMOV + GFI_DATMOV + GFI_HORMOV 
 	 	  lFoundGFI := DbSeek(xFilial("GFI") + M->GFG_SEQEMP + oGDMM:aCols[nitensGFI, nGfiSeqmov])
	 	   If !oGDMM:aCols[nItensGFI, nUMM + 1]
 	 	   If !lfoundGFI
 	      DbSelectArea("GBI")
 	      DbSetOrder(1) // GBI_FILIAL + GBI_PRODUT
 	      DbSeek(xFilial("GBI")+oGDMM:aCols[nitensGFI, nGfiProemp])
 	      If GBI->GBI_MOVEST <> "0"
 	       aMovEst := HS_MovEst(IIF(M->GFG_TIPEMP == "0",IIF(oGDMM:aCols[nItensGFI,nGFITipmov] == "0","I","D"),IIF(oGDMM:aCols[nItensGFI,nGFITipmov] == "0","R","G")) , IIf(Empty(oGDMM:aCols[nItensGFI,nGFIProAlt]), oGDMM:aCols[nItensGFI,nGFIProemp], oGDMM:aCols[nItensGFI,nGFIProAlt]), oGDMM:aCols[nItensGFI,nGFIQtdmov], M->GFG_ALMORI, cUserName, M->GFG_CODCCU,"", oGDMM:aCols[nItensGFI, nGFINumLot], oGDMM:aCols[nItensGFI, nGFILoteCt], oGDMM:aCols[nItensGFI, nGFIDtVali],,, oGDMM:aCols[nItensGFI,nGFIDatMov])
  	      If aMovEst[1]  
  	       RecLock("GFI", .T.)
     	     HS_GRVCPO("GFI", oGDMM:aCols, aHMM, nItensGFI)
     	     GFI->GFI_FILIAL := xFilial("GFI")
 			       GFI->GFI_SEQEMP := M->GFG_SEQEMP
 			       GFI->GFI_NUMSEQ := aMovEst[2]
           GFI->GFI_LOGARQ := HS_LogArq()
   	      MsUnlock()
         Else
          loop
   	     EndIf   
        Endif
       Endif
       nPos := Ascan(aVetGFH,{|x| x[2] == GFI->GFI_PROEMP })
	      If nPos > 0
  	     If GFI->GFI_TIPMOV == "0" .AND. GFG->GFG_TIPEMP == "0" .OR. GFI->GFI_TIPMOV == "1" .AND. GFG->GFG_TIPEMP == "1"
  	      aVetGFH[nPos,4] := aVetGFH[nPos,4] + GFI->GFI_QTDMOV 
  	     Else
	        aVetGFH[nPos,5] := aVetGFH[nPos,5] + GFI->GFI_QTDMOV  
	       Endif 
	       aVetGFH[nPos,6] := aVetGFH[nPos,4] - aVetGFH[nPos,5]
	      Else 
	       aadd(aVetGFH,{GFI->GFI_SEQEMP,GFI->GFI_PROEMP,HS_INIPADR("SB1",1,GFI->GFI_PROEMP,"B1_DESC",,.F.),IIF(GFI->GFI_TIPMOV == "0" .AND. GFG->GFG_TIPEMP == "0" .OR. GFI->GFI_TIPMOV == "1" .AND. GFG->GFG_TIPEMP == "1", GFI->GFI_QTDMOV,0),IIF(GFI->GFI_TIPMOV == "0" .AND. GFG->GFG_TIPEMP == "1" .OR. GFI->GFI_TIPMOV == "1" .AND. GFG->GFG_TIPEMP == "0", GFI->GFI_QTDMOV,0),GFI->GFI_QTDMOV,cSeqItem:=Soma1(cSeqItem)})
 	     Endif  
 	    Else
  	 	  If lFoundGFI
        nPosGFH:= Ascan(aVetExc,{|x| x[2] == oGDMM:aCols[nitensGFI, nGfiProemp]})
 	    	 If nPosGFH > 0
 	    	  aVetExc[nPosGFH,3] += oGDMM:aCols[nitensGFI, nGfiQtdmov]
 	    	 Else
 	    	  aadd(aVetExc,{M->GFG_SEQEMP,oGDMM:aCols[nitensGFI, nGfiProemp],oGDMM:aCols[nitensGFI, nGfiQtdmov]})
 	    	 Endif
 	    	 RecLock("GFI", .F.)
 	    	  DbDelete()
   	 		 MsUnlock()
   	 		 WriteSx2("GFI")
   	 		 HS_MovEst(,,,,,,,,,,.T.,oGDMM:aCols[nitensGFI, nGfiNumSeq])    
   	 		Endif	
 	    Endif
     Next  

 	   For nItensGFH := 1 to Len(aVetGFH)
 	    DbSelectArea("GFH")
 	    DbSetOrder(2) // GFH_FILIAL + GFH_SEQEMP + GFH_PROEMP  
 	    lFoundGFH := DbSeek(xFilial("GFH") + aVetGFH[nItensGFH,1] + aVetGFH[nItensGFH,2])
 	    Reclock("GFH",!lFoundGFH)
 	     GFH->GFH_FILIAL := xFilial("GFH")
 	     GFH->GFH_SEQEMP := aVetGFH[nItensGFH,1]  
       GFH->GFH_ITEEMP := aVetGFH[nItensGFH,7]
       GFH->GFH_PROEMP := aVetGFH[nItensGFH,2]
 	     GFH->GFH_QTDEMP := aVetGFH[nItensGFH,4]
 	     GFH->GFH_QTDRET := aVetGFH[nItensGFH,5]
 	     GFH->GFH_SLDEMP := aVetGFH[nItensGFH,6]  
 	     GFH->GFH_LOGARQ := HS_LOGARQ()
 	    MSUnlock()  
 	   Next
 	  	
 	    For nItensExc:=1 to Len(aVetExc)
 	     DbSelectArea("GFH")
 	     DbSetOrder(2) // GFH_FILIAL + GFH_SEQEMP + GFH_PROEMP   
 	     lFoundGFH := DbSeek(xFilial("GFH") + aVetExc[nItensExc,1] + aVetExc[nItensExc,2])
 	     If (nPosExc:=Ascan(aVetGFH,{|x|x[1]+ x[2] == aVetExc[nItensExc,1] + aVetExc[nItensExc,2]}))== 0 
 	      If GFH->GFH_SLDEMP == aVetExc[nItensExc,3] 
 	       RecLock("GFH", .F.)
 	        DbDelete()
   	     MsUnlock()
   	     WriteSx2("GFH")
 	      Endif
 	     Endif  
 	    Next
 	    
 	  Endif 
 	 Else 
    RecLock("GFG", .F.)
     DbDelete()
    MsUnLock() 
    WriteSx2("GFG")
 	 EndIf 
	  End Transaction
 EndIf
        
Return(.T.)       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLDM14 บ Autor ณ MARIO ARIZONO      บ Data ณ  27/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validacao dos campos do emprestimo              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

FUNCTION HS_VLDM14()

 Local lRet := .T.

 If ReadVar() == "M->GFG_CODHOS"  // Valida codigo do hospital
	 If !HS_SeekRet("GFF","M->GFG_CODHOS", 1, .F., "GFG_NOMHOS","GFF_NOMHOS")
	 	HS_MsgInf(STR0012, STR0009, STR0032)  //"C๓digo do Hospital invแlido!"###"Aten็ใo"###"Empr้stimo"
		 lRet := .F.
	 Endif	

	ElseIf Readvar() == "M->GFG_CODLOC"
  If !(lRet := !Empty(M->GFG_CODLOC))
   HS_MsgInf(STR0013, STR0009, STR0032) //"C๓digo do setor ้ obrigat๓rio."###"Aten็ใo"###"Empr้stimo"
  ElseIf !(lRet := HS_SeekRet("GCS", "M->GFG_CODLOC", 1, .F., {"GFG_NOMLOC","GFG_ALMORI","GFG_CODCCU"}, {"GCS_NOMLOC","GCS_ARMFAR","GCS_CODCCU"}))
   HS_MsgInf(STR0014, STR0009, STR0032) //"C๓digo do setor invแlido."###"Aten็ใo"###"Empr้stimo"
  EndIf   
  If lRet 
   If GCS->GCS_TIPLOC == "A"
    HS_SeekRet("SX5","'AL'+M->GFG_ALMORI", 1, .F., "M->GFG_DESALM", "X5_DESCRI")
    HS_VldCCU(M->GFG_CODCCU, "M->GFG_DESCCU", .T.)
   Else
    HS_MsgInf(STR0031, STR0009, STR0032)  //"Para esta movimenta็ใo s๓ ้ permitido setor do tipo farmแcia."###"Aten็ใo"###"Empr้stimo"
    lRet := .F.
   Endif  
  EndIf
 Endif                      
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLDMOV บ Autor ณ MARIO ARIZONO      บ Data ณ  27/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validacao dos campos da movimentacao            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

FUNCTION HS_VLDMOV()
 Local    aArea := GetArea()
 Local     lRet := .T.
 Local     nPos := 0, nCont:= 0, nTipIgu := 0, nTipDif := 0
 Local dMvUlmes := GETMV("MV_ULMES") 
 
 If Readvar() == "M->GFI_CBMATM"
  If (nPos := aScan(oGDMM:aCols, {| aVet | aVet[nGFICbMatm] == M->GFI_CBMATM })) == 0  .AND. (M->GFG_TIPEMP == "0" .AND. oGDMM:aCols[oGDMM:nAt,nGFITipmov] == "1" .OR. M->GFG_TIPEMP == "1" .AND. oGDMM:aCols[oGDMM:nAt,nGFITipmov] == "0")
   HS_MsgInf(STR0015, STR0009, STR0034)  //"Para esta movimenta็ใo o tipo tem que ser o mesmo do empr้stimo."###"Aten็ใo"###"Movimenta็ใo"
   lRet := .F.
  ElseIf !Empty(dMvUlmes) .AND. !(oGDMM:aCols[oGDMM:nAt, nGFIDatMov] > dMvUlmes)
   HS_MsgInf(STR0039, STR0009, STR0033) //"A Data da movimenta็ใo ้ menor ou igual ao ๚ltimo fechamento de estoque, nใo serแ possํvel efetuar o lan็amento."###"Aten็ใo"###"Movimenta็ใo de empr้stimo"
   lRet := .F.  
  ElseIf lRet := HS_VCodBar(M->GFI_CBMATM, "GFI_PROEMP",, .F., M->GFG_CODLOC, .F.)
    oGDMM:aCols[oGDMM:nAt, nGFIProemp] := SB1->B1_COD
    oGDMM:aCols[oGDMM:nAt, nGFIDesPro] := SB1->B1_DESC
  EndIf 
  If lRet
   If !Empty(__cProAlt)
    oGDMM:aCols[oGDMM:nAt, nGFIProAlt] := __cProAlt
    oGDMM:aCols[oGDMM:nAt, nGFIDPrAlt] := Posicione("SB1", 1, xFilial("SB1") + __cProAlt, "B1_DESC")
   Endif
   If !Rastro(IIf(Empty(__cProAlt), oGDMM:aCols[oGDMM:nAt, nGFIProemp], __cProAlt))
    oGDMM:aCols[oGDMM:nAt, nGFINumLot] := Space(len(oGDMM:aCols[oGDMM:nAt, nGFINumLot]))  
    oGDMM:aCols[oGDMM:nAt, nGFILoteFo] := Space(len(oGDMM:aCols[oGDMM:nAt, nGFILoteFo])) 
    oGDMM:aCols[oGDMM:nAt, nGFILoteCt] := Space(len(oGDMM:aCols[oGDMM:nAt, nGFILoteCt])) 
    oGDMM:aCols[oGDMM:nAt, nGFIDtVali] := CTOD("  /  /  ") 
   Endif
   For nCont:= 1 to (len(oGDMM:aCols)- 1)
    If oGDMM:aCols[nCont,nGFITipMov] == oGDMM:aCols[oGDMM:nAt,nGFITipMov] .AND. oGDMM:aCols[nCont,nGFICbmatm] == M->GFI_CBMATM 
     nTipIgu += oGDMM:aCols[nCont,nGFIQtdmov]     // tipo da movimentacao igual ao tipo da movimentacao da  linha do acols atual
    ElseIf oGDMM:aCols[nCont,nGFITipMov] <> oGDMM:aCols[oGDMM:nAt,nGFITipMov] .AND. oGDMM:aCols[nCont,nGFICbmatm] == M->GFI_CBMATM  
     nTipDif += oGDMM:aCols[nCont,nGFIQtdmov]   // tipo da movimentacao diferente ao tipo da movimentacao da  linha do acols atual
    Endif
   Next
    
   If (nTipIgu + oGDMM:aCols[oGDMM:nAt, nGFIQtdMov]) > nTipDif .AND. M->GFG_TIPEMP <> oGDMM:aCols[oGDMM:nAt, nGFITipMov]
    If oGDMM:aCols[oGDMM:nAt, nGFITipmov] == "1" 
     HS_MsgInf(STR0017, STR0009, STR0034)  //"Quantidade de saํda maior que a de entrada."###"Aten็ใo"###"Movimenta็ใo"
     lRet := .F.
    Else
     HS_MsgInf(STR0018, STR0009, STR0034)    //"Quantidade de entrada maior que a de saํda."###"Aten็ใo"###"Movimenta็ใo"
     lRet := .F.
    Endif
   Endif  
  Endif 
  
 ElseIf Readvar() == "M->GFI_QTDMOV"
  If Empty(oGDMM:aCols[oGDMM:nAt, nGFICbMatm])
   HS_MsgInf(STR0016, STR0009, STR0034) //"Preencha o c๓digo de barras do produto"###"Aten็ใo"###"Movimenta็ใo"
   lRet := .F.
  ElseIf (oGDMM:aCols[oGDMM:nAt, nGFITipmov]) <> "0" 
   If !(lRet := HS_M14VSLD(IIf(Empty(oGDMM:aCols[oGDMM:nAt, nGFIProAlt]), oGDMM:aCols[oGDMM:nAt, nGFIProemp], oGDMM:aCols[oGDMM:nAt, nGFIProAlt]), M->GFG_ALMORI, M->GFI_QTDMOV))
   Endif
  Endif 
  
  For nCont:= 1 to (len(oGDMM:aCols) - 1)
   If oGDMM:aCols[nCont, nGFITipMov] == oGDMM:aCols[oGDMM:nAt,nGFITipMov] .AND. oGDMM:aCols[nCont, nGFICbmatm] == oGDMM:aCols[oGDMM:nAt, nGFICbmatm] 
    nTipIgu += oGDMM:aCols[nCont,nGFIQtdmov]     // tipo da movimentacao igual ao tipo da movimentacao da  linha do acols atual
   ElseIf oGDMM:aCols[nCont, nGFITipMov] <> oGDMM:aCols[oGDMM:nAt, nGFITipMov] .AND. oGDMM:aCols[nCont, nGFICbmatm] == oGDMM:aCols[oGDMM:nAt, nGFICbmatm] 
    nTipDif += oGDMM:aCols[nCont, nGFIQtdmov]   // tipo da movimentacao diferente ao tipo da movimentacao da  linha do acols atual
   Endif
  Next
    
  If (nTipIgu + M->GFI_QTDMOV) > nTipDif .AND. M->GFG_TIPEMP <> oGDMM:aCols[oGDMM:nAt,nGFITipMov]
   If !Empty(oGDMM:aCols[oGDMM:nAt,nGFICbmatm])
    If oGDMM:aCols[oGDMM:nAt,nGFITipmov] == "1" 
     HS_MsgInf(STR0017, STR0009, STR0034)  //"Quantidade de saํda maior que a de entrada."###"Aten็ใo"###"Movimenta็ใo"
     lRet := .F.
    Else
     HS_MsgInf(STR0018, STR0009, STR0034)    //"Quantidade de entrada maior que a de saํda."###"Aten็ใo"###"Movimenta็ใo"
     lRet := .F.
    Endif
   Endif  
  Endif 
 
 ElseIf ReadVar() == "M->GFI_TIPMOV" .And. M->GFI_TIPMOV <> oGDMM:aCols[oGDMM:nAt, nGFITipMov]
  oGDMM:aCols[oGDMM:nAt, nGFICBMatM] := Space(Len(oGDMM:aCols[oGDMM:nAt, nGFICBMatM]))
  oGDMM:aCols[oGDMM:nAt, nGFIProEmp] := Space(Len(oGDMM:aCols[oGDMM:nAt, nGFIProEmp]))
  oGDMM:aCols[oGDMM:nAt, nGFIDesPro] := Space(Len(oGDMM:aCols[oGDMM:nAt, nGFIDesPro]))
  oGDMM:aCols[oGDMM:nAt, nGFIProAlt] := Space(Len(oGDMM:aCols[oGDMM:nAt, nGFIProAlt]))
  oGDMM:aCols[oGDMM:nAt, nGFIDPrAlt] := Space(Len(oGDMM:aCols[oGDMM:nAt, nGFIDPrAlt]))
 Endif

 RestArea(aArea)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOSITENSบ Autor ณ MARIO ARIZONO      บ Data ณ  27/10/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que mostra os itens do emprestimo e suas moviment.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION FS_MOSITENS(cSeqEmp)    

 Local  aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local  nGDOpc :=0, oDlgM14, nOpcDlg := 0
 
 Private aColGFH := {}, aHeaGFH := {}, nUnGFH := 0, oGFH 
	Private aColGFI := {}, aHeaGFI := {},  nUGFI := 0,  oGFI  
	
	Private nGFHProemp := 0, nGFHItemSeq:= 0                           
 
 HS_BDados("GFH", @aHeaGFH, @aColGFH, @nUnGFH, 1, M->GFG_SEQEMP, "GFH->GFH_SEQEMP == '" + M->GFG_SEQEMP + "'")

 nGFHProemp := aScan(aHeaGFH, {|aVet| AllTrim(aVet[2]) == "GFH_ITEEMP"})
 nGFHProemp := aScan(aHeaGFH, {|aVet| AllTrim(aVet[2]) == "GFH_PROEMP"})
     
 HS_BDados("GFI", @aHeaGFI, @aColGFI, @nUGFI, 1, cSeqemp, "GFI->GFI_Seqemp == '" + cSeqemp + "' .AND. GFI->GFI_PROEMP == '"+ aColGFH[1 ,nGFHProemp] + "'",,,,,,,,,,,,,,,,,,,)   

 aSize := MsAdvSize(.T.)
 aObjects := {}	
 
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
  
 DEFINE MSDIALOG oDlgM14 TITLE STR0035 From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel //"Itens da movimenta็ใo"
  
  oGFH := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],0,,,,,,,,,,, aHeaGFH, aColGFH)
  oGFH:oBrowse:align := CONTROL_ALIGN_TOP  
  oGFH:oBrowse:bchange :={||FS_Atugfi(cSeqEmp)}
  
  oGFI := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],nGDOpc ,,,,,,,,,,, aHeaGFI, aColGFI)
  oGFI :oBrowse:align := CONTROL_ALIGN_ALLCLIENT                            
  
   
 ACTIVATE MSDIALOG oDlgM14 ON INIT EnchoiceBar(oDlgM14,{||nOpcDlg := 1	, oDlgM14:End()},	{||nOpcDlg := 0, oDlgM14:End()})																															                
                                                                       
                               
Return()                          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUGFI  บ Autor ณ MARIO ARIZONO      บ Data ณ  27/10/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que atualiza os dados mostrados na getdados das movi.บฑฑ
ฑฑบ          ณde acordo com o item escolhido.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_ATUGFI(cSeqemp)

 aColGFI := {}     
 
 HS_BDados("GFI", @aHeaGFI, @aColGFI, @nUGFI, 1, cSeqemp, "GFI->GFI_Seqemp == '" + cSeqemp + "' .AND. GFI->GFI_PROEMP == '"+ oGFH:aCols[oGFH:obrowse:nAt,nGFHProemp] + "'",,,,,,,,,,,,,,,,,,,)   
 oGFI:ACols:=aClone(aColGFI)
 oGFI:oBrowse:Refresh()
 
Return()     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDDEL  บ Autor ณ MARIO ARIZONO      บ Data ณ  27/10/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que valida delecao das movimentacoes                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_VLDDEL(cAlias,nOpcm14)

 Local lret    := .T.  
 Local nPos    := 0, nProd := 0
 
 If oGDMM:obrowse:nAt <= nLenGFI  
  DBSelectArea("GFH")
  DbSetOrder(2) // GFH_FILIAL + GFH_SEQEMP + GFH_PROEMP  
  DbSeek(xFilial("GFH")+ GFG->GFG_SEQEMP + oGDMM:aCols[oGDMM:nAt,nGFIProemp])
  If GFG->GFG_TIPEMP == "0" .AND. oGDMM:aCols[oGDMM:nAt,nGFITipmov] == "0" .OR. GFG->GFG_TIPEMP == "1" .AND. oGDMM:aCols[oGDMM:nAt,nGFITipmov] == "1"
   nPos:= Ascan(aProd,{|x| x[1] == oGDMM:aCols[oGDMM:nAt, nGfiProemp]})
   If nPos == 0 
    aadd(aProd,{oGDMM:aCols[oGDMM:nAt,nGFIProemp],oGDMM:aCols[oGDMM:nAt,nGFIQtdmov]})
   Else
    If !oGDMM:aCols[oGDMM:nAt, nUMM + 1] 
     aProd[nPos,2] += oGDMM:aCols[oGDMM:nAt,nGFIQtdmov] 
    ElseIf oGDMM:aCols[oGDMM:nAt, nUMM + 1]
     aProd[nPos,2] -= oGDMM:aCols[oGDMM:nAt,nGFIQtdmov] 
    Endif 
   Endif 
   For nProd := 1 to Len(aProd)
    If GFH->GFH_PROEMP == aProd[nProd,1] 
     If aProd[nProd,2] > GFH->GFH_SLDEMP 
      HS_MsgInf(STR0019, STR0009, STR0036)  //"Produto nใo pode ser excluํdo."###"Aten็ใo"###"Valida exclusใo das movimenta็๕es"
      lRet := .F. 
      aProd[nProd,2] -= oGDMM:aCols[oGDMM:nAt,nGFIQtdmov] 
     Endif
    Endif
   Next   
  Endif
 Endif  
 
Return(lRet)      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CFMGRV  บ Autor ณ MARIO ARIZONO      บ Data ณ  09/11/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para confirmacao da gravacao quando chamada do botao บฑฑ
ฑฑบ          ณitens.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
STATIC FUNCTION FS_CFMGRV(nOpc)

 Local nItens := len(oGDMM:aCols), nItem:=0
 Local lRet   := .T.

 For nItem:=1 to Len(oGDMM:aCols)
  If oGDMM:aCols[nItem, nUMM + 1] .OR. Empty(oGDMM:aCols[nItem, nGFICbmatm])
   nItens --
  Endif
 Next 
 If nItens <> nLenGFI .AND. !Empty(oGDMM:aCols[1, nGFICbmatm]) 
  If MsgYesNo(STR0020, STR0009) //"Deseja gravar as altera็๕es efetuadas ?"###"Aten็ใo"
   lGravou := .T.  
   aProd :={}
   FS_GRVM14(nOpc)
  Endif  
  aCMM := {}
  aHMM := {}
  nUMM := 0
  nLenGFI:=HS_BDados("GFI", @aHMM, @aCMM, @nUMM, 1, M->GFG_SEQEMP, "GFI->GFI_SEQEMP == '" + M->GFG_SEQEMP + "'",,,,,,,,,,,,,,,,,,,) 
  oGDMM:ACols:=aClone(aCMM)
  oGDMM:oBrowse:Refresh()
 Endif
Return(lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M14VAL  บ Autor ณ MARIO ARIZONO      บ Data ณ  09/11/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validacao do botao alterar do browse.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/    

Function HS_M14VAl(nOpcM14) //Validacao do botao alterar no browse

 Local lRet := .T.
 
 If nOpcM14 == 4 .and. nLenGFI > 0
  HS_MsgInf(STR0021, STR0009, STR0037) //"Altera็ใo nใo pode ser efetuada, pois existem movimenta็๕es."###"Aten็ใo"###"Valida็ใo do botใo alterar do browse"
  lRet := .F.
 Endif 
 
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M14TOK บ Autor ณ MARIO ARIZONO      บ Data ณ  10/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verificacao de validade da confirmacao de atualizacao      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_M14TOK(cAlias,oOK,nPos)

 Local lRet 			:= .T.

 If !(Len(oGDMM:aCols) == 1 .And. Empty(oGDMM:aCols[1,nPos]))
  lRet := oGDMM:TudoOK()
 Endif
  
Return(lRet)           

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DescM14บ Autor ณ MARIO ARIZONO      บ Data ณ  09/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao dos campos de descricao.               บฑฑ
ฑฑบ          ณ Chamada do X3_RELACAO do campo de Acordo com o Parametro   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/      

Function HS_DescM14(cAlias, nCpo)

 Local cCodChave := ""
 Local cDescri   := ""  
 
 If cAlias == "GFI"
  cCodChave := IIf(Inclui, "", IIf(Alias() == "TMPGFI", (Alias())->GFI_PROEMP, ""))
  If !EMPTY(cCodChave)
   cDescri := HS_INIPADR("SB1",1,cCodChave,"B1_DESC",,.F.)
  EndIf 
 EndIf
 
Return(cDescri)         

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M14VSLDบ Autor ณ MARIO ARIZONO      บ Data ณ  09/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida saldo do produto na SB2.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_M14VSld(cProemp, cAlmOri, nQAtemp)
 
 Local lRet := .F., cAliasOld := Alias()
 Local cEstNeg := GETMV("MV_ESTNEG")
 
 If cAlmori <> Nil .And. Rastro(cProemp)
  cMsgLot := STR0022 + AllTrim(cProemp) + STR0023 + CHR(13) + CHR(10) + ;  //"O produto ["###"] possui rastreabilidade"
             STR0024 + CHR(13) + CHR(10) + ;                               //"e nใo foi encontrado nenhum lote para ele, "
             STR0025                                                       //"execute a manuten็ใo de lotes."
  If !HS_VldLote(cProemp + cAlmori, 1, cMsgLot)[1]
   lRet := .F.
  Else  
   If Empty(oGDMM:aCols[oGDMM:nAt, nGFINumLot]) 
    HS_SelLote(cProemp, cAlmori, nQAtemp) 
   Endif   
    DbSelectArea("SB8")
    DbsetOrder(1) // B8_FILIAL + B8_PRODUTO + B8_LOCAL + B8_DTVALID + B8_LOTECTL + B8_NUMLOTE   
    DbSeek(xFilial("SB8") + cProemp + cAlmori + DTOS(oGDMM:aCols[oGDMM:nAt, nGFIDtVali]) + oGDMM:aCols[oGDMM:nAt, nGFILoteCt] + oGDMM:aCols[oGDMM:nAt, nGFINumLot])
    If !(lRet := SB8->B8_SALDO >= nQAtemp)
     HS_MsgInf(STR0026, STR0009, STR0038)   //"Quantidade maior que o saldo do lote."###"Aten็ใo"###"Valida saldo do produto"
    Endif
  Endif   
 Else   
  If cEstNeg <> "S"
   DbSelectArea("SB2")
   DbSetOrder(1) // B2_FILIAL + B2_COD + B2_LOCAL
   If !(lRet := DbSeek(xFilial("SB2") + cProEmp + cAlmOri))
    HS_MsgInf(STR0027 + AllTrim(cProEmp) + STR0028 + cAlmOri + STR0029, STR0009, STR0038)  //"Item ["###" ] nใo possui saldo cadastrado para o armaz้m ["###"] (SB2)"###"Aten็ใo"###"Valida saldo do produto"
   ElseIf !(lRet := (SB2->B2_QATU >= nQAtemp))
    HS_MsgInf(STR0027 + AllTrim(cProemp) + STR0030 + cAlmOri + STR0029, STR0009, STR0038)  //"Item ["###" ] nใo possui saldo suficiente no armaz้m ["###"] (SB2)"###"Aten็ใo"###"Valida saldo do produto"
   EndIf
  Else
   lRet := .T.
  Endif  
 Endif 
 DbSelectArea(cAliasOld)
Return(lRet)         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 11/07/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},;  //"Pesquisar"
                     {OemToAnsi(STR0003), "HS_Mn14"  , 0, 2, 0, nil},;  //"Visualizar"
                   	 {OemToAnsi(STR0004), "HS_Mn14"  , 0, 3, 0, nil},;  //"Incluir"
                   	 {OemToAnsi(STR0005), "HS_Mn14"  , 0, 4, 0, nil},;  //"Alterar"
                   	 {OemtoAnsi(STR0006), "HS_Mn14"  , 0, 5, 0, nil},;  //"Excluir"
                	 {OemToAnsi(STR0007), "HS_Mn14"  , 0, 4, 0, nil}}   //"Movimentar" 
Return(aRotina)
