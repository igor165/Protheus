#INCLUDE "HSPAHA18.ch" 
#INCLUDE "protheus.CH"
#INCLUDE "colors.CH"
#INCLUDE "TopConn.ch"

/*/ 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                             
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HSPAHA18  ∫ Autor ≥ JosÈ Orfeu         ∫ Data ≥  27/11/01   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ CADASTRO DE CONVENIOS                                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/                
Function HSPAHA18()                    
Local aCampos := {{"C", "GA9_CDOPER"},;
                  {"C", "GA9_CNPJOP"},; 
                  {"C", "GA9_OUTDES"},;
                  {"C", "GA9_BLQPRO"},;
                  {"C", "GA9_TBTISS"},;
                  {"C", "GA9_LOGOTP"},;                   
                  {"C", "GA4_CDITEM"},;
                  {"C", "GA5_CDITEM"},;
                  {"C", "GA6_CDITEM"},;
                  {"C", "GAC_CDITEM"},;
                  {"C", "GDG_CDITEM"},;
                  {"C", "GC1_VRTSMA"},;
                  {"C", "GC1_VRTSMI"},;  
                  {"C", "GC1_VRTSDA"},;
                  {"C", "GC1_VRTSDI"},;
                  {"T", "GNF"}}                 
                   
Private cMVNivel := GETMV("MV_NIVEUSU",, 0)
Private cCodPla := "", cG1RTipo := "0" 
Private nGA4ORIDES := 0, nGA4CODDES := 0, nGA4DESDES := 0, nGA4DATVIG := 0, nGA4STAREG := 0, nGA4ITEM := 0

Private nGA5CODGPA := 0, nGA5DESGPA := 0, nGA5VDIFCH := 0, nGa5VDifCO := 0, nGA5DATVIG := 0, nGA5STAREG := 0, nGA5ITEM := 0

Private nGA6TIPCHF := 0, nGA6DATVIG := 0, nGA6CHSVAL := 0, nGA6MODLOC := 0, nGA6CODLOC := 0, nGA6NOMLOC := 0, nGA6STAREG := 0
Private nGA6ITEM := 0

Private nGACDESPLA := 0, nGACARQORI := 0, nGACCODPRO := 0, nGACDESPRO := 0, nGACVALPRO := 0, nGACCODPRE := 0, nGACNOMPRE := 0
Private nGACDATVIG := 0, nGACSTAREG := 0, nGACITEM := 0

Private nGCRITEM   := 0, nGCRCODPRO := 0, nGCRDESPRO := 0, nGCRDatVig := 0, nGCRCODESP := 0, nGCRNOMESP := 0, nGCRHORPRO := 0
Private nGCRCODLOC := 0, nGCRNOMLOC := 0, nGCRSTAREG := 0, nGCRCPROUT := 0, nGCRDPROUT := 0, 	nGCRVLRPRO := 0

Private nGC6TABPRO := 0, nGC6PRIORI := 0, nGC6DATVIG := 0, nGC6ITEPLA := 0, nGC6STAREG := 0, nGC6CODPLA := 0
 
Private nGD8CODTXD := 0, nGD8PRIORI := 0, nGD8DATVIG := 0, nGD8ITEPLA := 0, nGD8STAREG := 0, nGD8CODPLA := 0
 
Private nGD9CODMAT := 0, nGD9PRIORI := 0, nGD9DATVIG := 0, nGD9ITEPLA := 0, nGD9STAREG := 0, nGD9CODPLA := 0
 
Private nGDACODMED := 0, nGDAPRIORI := 0, nGDADATVIG := 0, nGDAITEPLA := 0, nGDASTAREG := 0, nGDACODPLA := 0
 
Private nGDFCODRES := 0, nGDFPRIORI := 0, nGDFDATVIG := 0, nGDFITEPLA := 0, nGDFSTAREG := 0, nGDFCODPLA := 0
 
Private nGDGDIASEM := 0, nGDGHINACR := 0, nGDGHFIACR := 0, nGDGSTAREG := 0, nGDGITEM := 0
 
Private nGC1ITEPLA := 0, nGC1DATVIG := 0, nGC1TPMMED := 0, nGC1STAREG := 0
 
Private nGFVITEPLA := 0, nGFVSTAREG := 0, nGFVCODPLA := 0, nGFVNOMCAT := 0

Private nGGKITEMTO := 0, nGGKTPITEM := 0, nGGKCDITEM := 0, nGGKDSITEM := 0, nGGKQTTETO := 0, nGGKVLTETO := 0, nGGKSTAREG := 0
 
Private nGNFIREGRA := 0, nGNFTREGRA := 0, nGNFLSTPLA := 0
                                                                                       
Private oGA4, oGA5, oGA6, oGAC, oGCR, oSA1, oGA9, oGC6, oGD8, oGD9, oGDA, oGDF, oGDG, oGEE, oGCM, oGC1, oGFV, oGGK, oGNF, oFolder
Private cGa4_OriDes := "0", cGac_ArqOri := "0", cGGK_TpItem := "1"
Private aCGCM	:= {}, aHGCM := {}, nUGCM := 0, nLGCM := 0  
Private aCGA4	:= {}, aHGA4 := {}, nUGA4 := 0, nLGA4 := 0
Private aCGA5	:= {}, aHGA5 := {}, nUGA5 := 0, nLGA5 := 0
Private aCGA6	:= {}, aHGA6 := {}, nUGA6 := 0, nLGA6 := 0
Private aCGAC	:= {}, aHGAC := {}, nUGAC := 0, nLGAC := 0
Private aCGCR	:= {}, aHGCR := {}, nUGCR := 0, nLGCR := 0    
Private aCGC6	:= {}, aHGC6 := {}, nUGC6 := 0, nLGC6 := 0 
Private aCGD8	:= {}, aHGD8 := {}, nUGD8 := 0, nLGD8 := 0 
Private aCGD9	:= {}, aHGD9 := {}, nUGD9 := 0, nLGD9 := 0 
Private aCGDA	:= {}, aHGDA := {}, nUGDA := 0, nLGDA := 0 
Private aCGDF	:= {}, aHGDF := {}, nUGDF := 0, nLGDF := 0 
Private aCGDG	:= {}, aHGDG := {}, nUGDG := 0, nLGDG := 0 
Private aCGC1	:= {}, aHGC1 := {}, nUGC1 := 0, nLGC1 := 0 
Private aCGFV	:= {}, aHGFV := {}, nUGFV := 0, nLGFV := 0 
Private aCGGK	:= {}, aHGGK := {}, nUGGK := 0, nLGGK := 0 
Private aCGNF	:= {}, aHGNF := {}, nUGNF := 0, nLGNF := 0   

Private nGEEITEM   := 0, nGEECODLOC := 0, nGEEDIARET := 0, nGEECODPRO := 0   
Private aCGEE	:= {}, aHGEE := {}, nUGEE := 0, nLGEE := 0      
 
Private nGcmCodPla := 0,  nGcmDesPla := 0, nGCMSTATUS := 0, nGCMDESMAT := 0, nGCMDESMED := 0
Private cMaskTISS  := "BMP" + "|*.bmp|" + "JPG" + "|*.jpg|" + STR0107 + "|*.*|" //"Todos"
Private aRotina   := MenuDef()
Private aVldDelGC6 := {}
Private aVldDelGD8 := {}
Private aVldDelGD9 := {}
Private aVldDelGDA := {}
Private aVldDelGDF := {}
Private aVldDelGFV := {}
Private aVldDelGCM := {}
Private aVldDelGa9 := {}
Private aTravas := {}	
If !HS_ExisDic(aCampos)
	Return(Nil)
EndIf	                     
 
AjustaSXB() 
 
DbSelectArea("GA9")
mBrowse(06, 01, 22, 75, "GA9")
Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_MNTA18 ∫ Autor ≥ JosÈ Orfeu         ∫ Data ≥ 28/01/02    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Chama a Funcao de Cadastro de Profissionais                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_MNTA18(cAlias,nReg,nOpc)   
 Local bCampo  := {|nCPO| Field(nCPO)} , oDlg
 Local nCntFor := 0, oGetDados := {}
 Local nGeeOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 Local aCpoSA1 := {} 
 Local aCpoSA1V:={}
 Local aHGMX   := {}, aCGMX := {}
 Local nUGMX   := 0
 Local nCntFor1 :=0
 Local nCntFor2 :=0
 Private aTela[0][0], aGets[0]
 Private aSvaTela := {{},{},{},{},{}}, aSvaGets := {{},{},{},{},{}} 
 Private cB1Mens  := STR0012 //"Produto n„o encontrado no cadastro (SB1)" 
 Private oGMX
 Private nGMXINTINI := 0, nGMXINTFIN := 0, nGMXTGTISS := 0, nGMXINTPRO := 0, nGMXCODSEQ := 0
 Private nPAcols := 0
 Private cGcaTipo 
 If !Hs_LockTab(@aTravas, cAlias,,aRotina[nOpc, 4])
  Return(nil)
 EndIf
 
 nGEEITEM   := 0
 nGEECODLOC := 0
 nGEEDIARET := 0
 nGEECODPRO := 0   
 aCGEE	:= {}
 aHGEE := {}
 nUGEE := 0
 nLGEE := 0 
 
 nGcmCodPla := 0
 nGcmDesPla := 0
 aCGCM	:= {}
 aHGCM := {}
 nUGCM := 0
 nLGCM := 0 

 nGNFIREGRA := 0
 nGNFTREGRA := 0
 nGNFLSTPLA := 0
 aCGNF	:= {}
 aHGNF := {}
 nUGNF := 0
 

 SetPrvt("wVar")
 If     nOpc == 3
  nOpce := 3
 ElseIf nOpc == 4
  nOpce := 4
 ElseIf nOpc  == 2
  nOpce := 2
 Else // nOpc == 5
  nOpce := 5
 EndIf

 aCpoGA9 := {}
 DbSelectArea("SX3")
 DbSetOrder(1) //GA9_FILIAL + GA9_CODCON
 DbSeek("GA9")
 While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "GA9")
  If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
   Aadd(aCpoGA9, SX3->X3_CAMPO)
  EndIf
  
  wVar := "M->" + x3_campo
  &wVar:= CriaVar(x3_campo) // executa x3_relacao
  DbSkip()
 EndDo

 aCpoSA1 := {}
 DbSelectArea("SX3")
 DbSetOrder(1) //A1_FILIAL + A1_COD + A1_LOJA
 DbSeek("SA1")
 While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "SA1")
  If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. !(AllTrim(SX3->X3_CAMPO) $ "A1_COD/A1_LOJA")
 		If (SX3->X3_CONTEXT <> "V")
			aAdd(aCpoSA1, SX3->X3_CAMPO)                   
 		Else
	 		aAdd(aCpoSA1V, SX3->X3_CAMPO)                     
		EndIf
	 Endif
  DbSkip()
 EndDo
 For nCntFor1 := 1 TO len(aCpoSA1)
 	wVar := "M->" + aCpoSA1[nCntFor1]
 	&wVar:= CriaVar(aCpoSA1[nCntFor1]) // executa x3_relacao
 Next nCntFor1 
 For nCntFor2 := 1 TO len(aCpoSA1V)
 	wVar := "M->" + aCpoSA1V[nCntFor2]
 	&wVar:= CriaVar(aCpoSA1V[nCntFor2]) // executa x3_relacao
 	aadd(aCpoSA1,aCpoSA1V[nCntFor2])
 Next nCntFor2 

 If !Inclui
  DbSelectArea("GA9")
  For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
  Next  

  DbSelectArea("SA1")
  DbSetOrder(1) //A1_FILIAL + A1_COD + A1_LOJA
  DbSeek(xFilial("SA1") + M->GA9_CODCLI)
  For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
  Next
 EndIf
               
 nLGCM := HS_BDados("GCM", @aHGCM, @aCGCM, @nUGCM, 1,, "'" + M->GA9_CODCON + "' == GCM->GCM_CODCON", .T.)
 nGCMSTAREG := aScan(aHGCM, {| aVet | aVet[2] == "HSP_STAREG"})
 nGCMCODPLA := aScan(aHGCM, {| aVet | aVet[2] == "GCM_CODPLA"})
 nGCMDESPLA := aScan(aHGCM, {| aVet | aVet[2] == "GCM_DESPLA"})
 nGCMSTATUS := aScan(aHGCM, {| aVet | aVet[2] == "GCM_STATUS"})
 nGCMDESMAT := aScan(aHGCM, {| aVet | aVet[2] == "GCM_DESMAT"})
 nGCMDESMED := aScan(aHGCM, {| aVet | aVet[2] == "GCM_DESMED"})
 nLGCM      := IIf(Len(aCGCM) == 1 .And. Empty(aCGCM[1, nGCMCODPLA]), 0, nLGCM)
 
 HS_BDados("GEE", @aHGEE, @aCGEE, @nUGEE, 1,, "'" + M->GA9_CODCON + "' == GEE->GEE_CODCON", .T.)
 nGEESTAREG := aScan(aHGEE, {| aVet | aVet[2] == "HSP_STAREG"})
 nGEEITEM   := aScan(aHGEE, {| aVet | aVet[2] == "GEE_ITEM  "})
 nGEECODLOC := aScan(aHGEE, {| aVet | aVet[2] == "GEE_CODLOC"})
 nGEEDIARET := aScan(aHGEE, {| aVet | aVet[2] == "GEE_DIARET"})
 nGEECODPRO := aScan(aHGEE, {| aVet | aVet[2] == "GEE_CODPRO"})
 
 If Empty(aCGEE[1, nGEEITEM])
  aCGEE[1, nGEEITEM] := StrZero(1,Len(GEE->GEE_ITEM))
 EndIf
 nLGEE := IIF(Len(aCGEE) == 1 .And. Empty(aCGEE[1, nGEEDIARET]) .And. Empty(aCGEE[1, nGEECODPRO]), 0, Len(aCGEE)) 

 HS_BDados("GMX", @aHGMX, @aCGMX, @nUGMX, 1,, "'" + M->GA9_CODCON + "' == GMX->GMX_CODCON", .T.) 
 nGMXSTAREG := aScan(aHGMX, {| aVet | aVet[2] == "HSP_STAREG"})
 nGMXINTINI := aScan(aHGMX, {| aVet | aVet[2] == "GMX_INTINI"})
 nGMXINTFIN := aScan(aHGMX, {| aVet | aVet[2] == "GMX_INTFIN"})
 nGMXTGTISS := aScan(aHGMX, {| aVet | aVet[2] == "GMX_TGTISS"})
 nGMXINTPRO := aScan(aHGMX, {| aVet | aVet[2] == "GMX_INTPRO"})
 nGMXCODSEQ := aScan(aHGMX, {| aVet | aVet[2] == "GMX_CODSEQ"}) 
 
 HS_BDados("GNF", @aHGNF, @aCGNF, @nUGNF, 1,, "'" + M->GA9_CODCON + "' == GNF->GNF_CODCON", .T.)
 nGNFSTAREG := aScan(aHGNF, {| aVet | aVet[2] == "HSP_STAREG"})
 nGNFIREGRA := aScan(aHGNF, {| aVet | aVet[2] == "GNF_IREGRA"})
 nGNFTREGRA := aScan(aHGNF, {| aVet | aVet[2] == "GNF_TREGRA"})
 nGNFLSTPLA := aScan(aHGNF, {| aVet | aVet[2] == "GNF_LSTPLA"})
 
 If Empty(aCGNF[1, nGNFIREGRA])
  aCGNF[1, nGNFIREGRA] := StrZero(1,Len(GNF->GNF_IREGRA))
 EndIf
 

 nOpca := 0   
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 045, .T., .T. } )	   
 AAdd( aObjects, { 100, 055, .T., .T., .T.})
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],000 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Convenios" 
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder2 SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0007, STR0015, STR0041, STR0096, STR0112 //"DADOS DO CLIENTE (SA1)"###"Planos"###"Retorno###"NumeraÁ„o da Guia"###"Regras do cÛdigo de operadora"
  oFolder2:Align := CONTROL_ALIGN_BOTTOM
  SetEnch("")
  aGets := {}
  aTela := {}
  DbSelectArea("GA9")         
  oGA9 := MsMGet():New("GA9", nReg, nOpcE,,,, aCpoGA9, aPObjs[1],, 3,,,, oDlg,,, .F., "aSvaTela[1]", .F.)
  oGA9:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  aSvaTela[1] := aClone(aTela)
  aSvaGets[1] := aClone(aGets)
  aGets := {}
  aTela := {}
  
  DbSelectArea("SA1")                                             
  oSA1 := MsMGet():New("SA1", nReg, nOpcE,,,, aCpoSA1, {aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4]},, 3,,,, oFolder2:aDialogs[1],, .T., .F., "aSvaTela[2]", .F.)
  oSA1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  aSvaTela[2] := aClone(aTela)
  aSvaGets[2] := aClone(aGets)    
                                                        
  oGCM := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGeeOpc,,,,,,99999,,,, oFolder2:aDialogs[2], aHGCM, aCGCM)
  oGCM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                                      
  oGCM:cFieldOk := "HS_GDAtrib(oGCM, {{nGCMSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGCM:oBrowse:bDelete := {|| IIF(Fs_VldDel(aVldDelGCM),Eval({|| HS_GDAtrib(oGCM, {{nGCMSTAREG, "BR_CINZA", "BR_VERDE"}}), oGCM:DelLine()}),.F.)}                         

  oGEE := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1,4], nGeeOpc,,,"+GEE_ITEM",,,99999,,,, oFolder2:aDialogs[3], aHGEE, aCGEE)  
  oGEE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                
  oGEE:cFieldOk := "HS_GDAtrib(oGEE, {{nGEESTAREG, 'BR_AMARELO', 'BR_VERDE'}})" 
  oGEE:oBrowse:bDelete := {|| HS_GDAtrib(oGEE, {{nGEESTAREG, "BR_CINZA", "BR_VERDE"}}), oGEE:DelLine()}  
  
  oGMX := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1,4], nGeeOpc,,,,,,99999,,,, oFolder2:aDialogs[4], aHGMX, aCGMX)  
  oGMX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                
  oGMX:cFieldOk := "HS_GDAtrib(oGMX, {{nGMXSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGMX:oBrowse:bDelete := {|| HS_GDAtrib(oGMX, {{nGMXSTAREG, "BR_CINZA", "BR_VERDE"}}), oGMX:DelLine()}    
        
  oGNF := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1,4], nGeeOpc,,,"+GNF_IREGRA",,,99999,,,, oFolder2:aDialogs[5], aHGNF, aCGNF)  
  oGNF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                
  oGNF:cFieldOk := "HS_GDAtrib(oGNF, {{nGNFSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGNF:oBrowse:bDelete := {|| HS_GDAtrib(oGNF, {{nGNFSTAREG, "BR_CINZA", "BR_VERDE"}}), oGNF:DelLine()}    

  Hs_CarVld()

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIf(HS_CpoObr(aSvaGets, aSvaTela, {}) .And. HS_TudoOK("GCM", oGCM, nGCMDESPLA) .And. FS_VldPla(oGCM), (nOpcA := 1, oDlg:End()), .F.)}, ;
                                                  {|| nOpcA := 0, oDlg:End()})
 
 If nOpca == 1
  Begin Transaction 
   FS_GrvHSP18(nOpc)
  End Transaction
 Else     
  While __lSx8
   RollBackSx8() 
  End 
 EndIf
 HS_UnLockT(aTravas)
Return(.T.)
  
  
Static Function FS_GrvHSP18(nOpc)
 Local nItem := 0, lAchou := .F.
 Local nCont := 0

 Private nContGCM := 0
 
 If nOpc # 2 // nao for consulta
 	DbSelectArea("GA9")
  	DbSetOrder(1) //GA9_FILIAL + GA9_CODCON
  	wProcura := DbSeek(xFilial("GA9") + M->GA9_CODCON)
  	If Inclui .Or. Altera 

   		If StrZero(nOpc,2) $ "03/04" //Inclusao
    		MsgRun(STR0055,, {||HS_VLDAHA18()}) //"Atualizando dados de cliente para o convenio. Aguarde..."
   		EndIf 
   
   		RecLock("GA9", If(Altera, .F., .T.))
    	HS_GRVCPO("GA9")
    	GA9->GA9_FILIAL := xFilial("GA9")
    	GA9->GA9_CODCLI := SA1->A1_COD
    	GA9->GA9_LOJA   := SA1->A1_LOJA
   		MsUnlock()
   		ConfirmSx8()
                                                            
   		FS_GrvRel("GCM", 1, oGCM, "M->GA9_CODCON + oGCM:aCols[nPAcols, nGcmCodPla]")   //GCM_FILIAL + GCM_CODCON + GCM_CODPLA
   		FS_GrvRel("GEE", 1, oGEE, "M->GA9_CODCON + oGEE:aCols[nPAcols, nGEEITEM]  ")   //GEE_FILIAL + GEE_CODCON + GEE_ITEM
   		FS_GrvRel("GMX", 1, oGMX, "M->GA9_CODCON + oGMX:aCols[nPAcols, nGMXCODSEQ]", "GCZ")   //GMX_FILIAL + GMX_CODCON + GMX_CODSEQ + GMX_TGTISS
   		FS_GrvRel("GNF", 1, oGNF, "M->GA9_CODCON + oGNF:aCols[nPAcols, nGNFIREGRA]")  //GNF_FILIAL + GNF_CODCON + GNF_IREGRA
  	Else  // Exclusao
		If wProcura    
			FS_ACOLS()  // gera os acols das tabelas da opcao diferenciados
			Hs_CarVld(.T.)
			If(FS_VlDlCon())
				Begin Transaction
					IIF(Len(aCGA4) > 0, FS_Deleta("GA4", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GA4
					IIF(Len(aCGA5) > 0, FS_Deleta("GA5", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GA5
					IIF(Len(aCGA6) > 0, FS_Deleta("GA6", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GA6
					IIF(Len(aCGAC) > 0, FS_Deleta("GAC", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GAC
					IIF(Len(aCGCR) > 0, FS_Deleta("GCR", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GCR
					IIF(Len(aCGC6) > 0, FS_Deleta("GC6", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GC6
					IIF(Len(aCGD8) > 0, FS_Deleta("GD8", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GD8
					IIF(Len(aCGD9) > 0, FS_Deleta("GD9", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GD9
					IIF(Len(aCGDA) > 0, FS_Deleta("GDA", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GDA
					IIF(Len(aCGDF) > 0, FS_Deleta("GDF", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GDF
					IIF(Len(aCGDG) > 0, FS_Deleta("GDG", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GDG 
					IIF(Len(oGEE:aCols) > 0, FS_Deleta("GEE", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GEE
			    	For nCont := 1 To Len(aCGCM)
			     		nContGCM := nCont
			     		IIF(Len(aCGC1) > 0, FS_Deleta("GC1", 1, aCGCM[nContGCM, nGcmCodPla]), Nil) // Excluir relacionamento GC1
			     		IIF(Len(aCGFV) > 0, FS_Deleta("GFV", 1, aCGCM[nContGCM, nGcmCodPla]), Nil) // Excluir relacionamento GFV
			     		IIF(Len(aCGGK) > 0, FS_Deleta("GGK", 1, aCGCM[nContGCM, nGcmCodPla]), Nil) // Excluir relacionamento GGK
			    	Next 
			    	IIF(Len(oGCM:aCols) > 0, FS_Deleta("GCM", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GCM
			    	IIF(Len(oGMX:aCols) > 0, FS_Deleta("GMX", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GMX
			    	IIF(Len(oGNF:aCols) > 0, FS_Deleta("GNF", 1, GA9->GA9_CODCON), Nil)  // Excluir relacionamento GNF
			    	FS_Deleta("GA9", 1, GA9->GA9_CODCON)  // Excluir relacionamento GA9
		    	End Transaction
			EndIf
  		EndIf
  	EndIf              
 EndIf              
Return(.T.)
       

Function HS_VLDAHA18()
 Local aArea  := GetArea()
 Local lAchou := .F.

 DbSelectArea("SA1")
 DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
 If (lAchou := DbSeek(xFilial("SA1") + M->GA9_CODCLI + M->GA9_LOJA))
  M->A1_COD    := SA1->A1_COD
  M->A1_LOJA   := SA1->A1_LOJA
 Else
  M->A1_COD    := HS_VSxeNum("SA1", "M->A1_COD", 1)
  M->A1_LOJA   := "01" 
  M->A1_NOME   := IIF(Empty(M->A1_NOME),   M->GA9_NOME,   M->A1_NOME)
  M->A1_NREDUZ := IIF(Empty(M->A1_NREDUZ), M->GA9_NREDUZ, M->A1_NREDUZ)
  M->A1_END    := IIF(Empty(M->A1_END),    M->GA9_END,    M->A1_END)
  M->A1_MUN    := IIF(Empty(M->A1_MUN),    M->GA9_MUN,    M->A1_MUN)
  M->A1_BAIRRO := IIF(Empty(M->A1_BAIRRO), M->GA9_BAIRRO, M->A1_BAIRRO)
  M->A1_CEP    := IIF(Empty(M->A1_CEP),    M->GA9_CEP,    M->A1_CEP)
  M->A1_FAX    := IIF(Empty(M->A1_FAX),    M->GA9_FAX,    M->A1_FAX)
  M->A1_CGC    := IIF(Empty(M->A1_CGC),    M->GA9_CGC,    M->A1_CGC)
  M->A1_INSCR  := IIF(Empty(M->A1_INSCR),  M->GA9_INSCR,  M->A1_INSCR)
  M->A1_TIPO   := IIF(Empty(M->A1_TIPO),   "J",           M->A1_TIPO)
 EndIf                                          
 
 RecLock("SA1", !lAchou)
  HS_GRVCPO("SA1")                
  SA1->A1_FILIAL := xFilial("SA1")
  SA1->A1_COD    := M->A1_COD
  SA1->A1_LOJA   := M->A1_LOJA  
 MsUnlock()
 
 RestArea(aArea)
Return()


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_ACOLS     ∫ Autor ≥ Gilson da Silva ∫ Data ≥  06/01/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera AHEADER E Acols das Tabelas GA4-GA5-GA6-GAC-GCR-GC6   ∫±±
±±∫          ≥                                  GD8-GD9-GDA-GDF-GC1       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_ACOLS()  
 Local nX      := 0 
 Local nPos    := 0
 Local nCt     := 0
 Local nCont   := 0
 Local cCodGCM := ""
 
 aCGA4	:= {}
 aHGA4 := {}
 nUGA4 := 0
 nLGA4 := 0
 aCGA5	:= {}
 aHGA5 := {}
 nUGA5 := 0
 nLGA5 := 0
 aCGA6	:= {}
 aHGA6 := {}
 nUGA6 := 0
 nLGA6 := 0
 aCGAC	:= {}
 aHGAC := {}
 nUGAC := 0
 nLGAC := 0
 aCGCR	:= {}
 aHGCR := {}
 nUGCR := 0
 nLGCR := 0 
 aCGC6	:= {}
 aHGC6 := {}
 nUGC6 := 0
 nLGC6 := 0 
 aCGD8	:= {}
 aHGD8 := {}
 nUGD8 := 0
 nLGD8 := 0 
 aCGD9	:= {}
 aHGD9 := {}
 nUGD9 := 0
 nLGD9 := 0 
 aCGDA	:= {}
 aHGDA := {}
 nUGDA := 0
 nLGDA := 0 
 aCGDF	:= {}
 aHGDF := {}
 nUGDF := 0
 nLGDF := 0 
 aCGDG	:= {}
 aHGDG := {}
 nUGDG := 0
 nLGDG := 0
 aCGC1	:= {}
 aHGC1 := {}
 nUGC1 := 0
 nLGC1 := 0
 aCGFV	:= {}
 aHGFV := {}
 nUGFV := 0
 nLGFV := 0
 aCGGK	:= {}
 aHGGK := {}
 nUGGK := 0
 nLGGK := 0
   
 HS_BDados("GA4", @aHGA4, @aCGA4, @nUGA4, 1,, "'" + GA9->GA9_CODCON + "' == GA4->GA4_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGA4ORIDES := aScan(aHGA4, {| aVet | aVet[2] == "GA4_ORIDES"})
 nGA4CODDES := aScan(aHGA4, {| aVet | aVet[2] == "GA4_CODDES"})
 nGA4DESDES := aScan(aHGA4, {| aVet | aVet[2] == "GA4_DESDES"})
 nGA4DATVIG := aScan(aHGA4, {| aVet | aVet[2] == "GA4_DATVIG"})
 nLGA4 := IIF(Len(aCGA4) == 1 .And. Empty(aCGA4[1, nGA4CODDES]), 0, Len(aCGA4))

 HS_BDados("GA5", @aHGA5, @aCGA5, @nUGA5, 1,, "'" + GA9->GA9_CODCON + "' == GA5->GA5_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGA5CODGPA := aScan(aHGA5, {| aVet | aVet[2] == "GA5_CODGPA"})
 nGA5DESGPA := aScan(aHGA5, {| aVet | aVet[2] == "GA5_DESGPA"})
 nGA5VDIFCH := aScan(aHGA5, {| aVet | aVet[2] == "GA5_VDIFCH"})
 nGa5VDifCO := aScan(aHGA5, {| aVet | aVet[2] == "GA5_VDIFCO"})
 nGA5DATVIG := aScan(aHGA5, {| aVet | aVet[2] == "GA5_DATVIG"})
 nLGA5 := IIF(Len(aCGA5) == 1 .And. Empty(aCGA5[1, nGA5VDIFCH]) .And. Empty(aCGA5[1, nGA5VDIFCO]), 0, Len(aCGA5))

 HS_BDados("GA6", @aHGA6, @aCGA6, @nUGA6, 1,, "'" + GA9->GA9_CODCON + "' == GA6->GA6_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGA6TIPCHF := aScan(aHGA6, {| aVet | aVet[2] == "GA6_TIPCHF"})
 nGA6DATVIG := aScan(aHGA6, {| aVet | aVet[2] == "GA6_DATVIG"})
 nGA6CHSVAL := aScan(aHGA6, {| aVet | aVet[2] == "GA6_CHSVAL"})
 nGA6MODLOC := aScan(aHGA6, {| aVet | aVet[2] == "GA6_MODLOC"})
 nGA6CODLOC := aScan(aHGA6, {| aVet | aVet[2] == "GA6_CODLOC"})
 nGA6NOMLOC := aScan(aHGA6, {| aVet | aVet[2] == "GA6_NOMLOC"})
 nLGA6 := IIF(Len(aCGA6) == 1 .And. (aCGA6[1, nGA6CHSVAL]) == 0, 0, Len(aCGA6))

 HS_BDados("GAC", @aHGAC, @aCGAC, @nUGAC, 1,, "'" + GA9->GA9_CODCON + "' == GAC->GAC_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGACARQORI := aScan(aHGAC, {| aVet | aVet[2] == "GAC_ARQORI"})
 nGACCODPRO := aScan(aHGAC, {| aVet | aVet[2] == "GAC_CODPRO"})
 nGACDESPRO := aScan(aHGAC, {| aVet | aVet[2] == "GAC_DESPRO"})
 nGACVALPRO := aScan(aHGAC, {| aVet | aVet[2] == "GAC_VALPRO"})
 nGACCODPRE := aScan(aHGAC, {| aVet | aVet[2] == "GAC_CODPRE"})
 nGACNOMPRE := aScan(aHGAC, {| aVet | aVet[2] == "GAC_NOMPRE"})
 nGACDATVIG := aScan(aHGAC, {| aVet | aVet[2] == "GAC_DATVIG"})
 nLGAC := IIF(Len(aCGAC) == 1 .And. Empty(aCGAC[1, nGACCODPRO]), 0, Len(aCGAC))

 HS_BDados("GCR", @aHGCR, @aCGCR, @nUGCR, 3,, "'" + GA9->GA9_CODCON + "' == GCR->GCR_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
	nGCRITEM   := aScan(aHGCR, {| aVet | aVet[2] == "GCR_ITEM  "})
 nGCRCODPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CODPRO"})
 nGCRDESPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_DESPRO"})
 nGCRCODESP := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CODESP"})
 nGCRNOMESP := aScan(aHGCR, {| aVet | aVet[2] == "GCR_NOMESP"})
 nGCRHORPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_HORPRO"})
 nGCRCODLOC := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CODLOC"})
 nGCRNOMLOC := aScan(aHGCR, {| aVet | aVet[2] == "GCR_NOMLOC"})
 nGCRCPROUT := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CPROUT"})
 nGCRDPROUT := aScan(aHGCR, {| aVet | aVet[2] == "GCR_DPROUT"})
 nGCRVLRPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_VLRPRO"})
 nGCRDATVIG := aScan(aHGCR, {| aVet | aVet[2] == "GCR_DATVIG"})
 If Empty(aCGCR[1,nGCRITEM])
  aCGCR[1,nGCRITEM]	:= StrZero(1, Len(aCGCR[1, nGCRITEM]))
 EndIf
 nLGCR := IIF(Len(aCGCR) == 1 .And. Empty(aCGCR[1, nGCRCODPRO]), 0, Len(aCGCR)) 

 HS_BDados("GC6", @aHGC6, @aCGC6, @nUGC6, 2,, "'" + GA9->GA9_CODCON + "' == GC6->GC6_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGC6TABPRO := aScan(aHGC6, {| aVet | aVet[2] == "GC6_TABPRO"})
 nGC6PRIORI := aScan(aHGC6, {| aVet | aVet[2] == "GC6_PRIORI"})
 nGC6DATVIG := aScan(aHGC6, {| aVet | aVet[2] == "GC6_DATVIG"}) 
 nGC6ITEPLA := aScan(aHGC6, {| aVet | aVet[2] == "GC6_ITEPLA"})
 nGC6CODPLA := aScan(aHGC6, {| aVet | aVet[2] == "GC6_CODPLA"})

 If Empty(aCGC6[1,nGC6ITEPLA])
  aCGC6[1,nGC6ITEPLA]	:= StrZero(1, Len(aCGC6[1, nGC6ITEPLA]))
 EndIf
 nLGC6 := IIF(Len(aCGC6) == 1 .And. Empty(aCGC6[1, nGC6TABPRO]), 0, Len(aCGc6))
 
 HS_BDados("GD8", @aHGD8, @aCGD8, @nUGD8, 2,, "'" + GA9->GA9_CODCON + "' == GD8->GD8_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGD8CODTXD := aScan(aHGD8, {| aVet | aVet[2] == "GD8_CODTXD"})
 nGD8PRIORI := aScan(aHGD8, {| aVet | aVet[2] == "GD8_PRIORI"})
 nGD8DATVIG := aScan(aHGD8, {| aVet | aVet[2] == "GD8_DATVIG"})
 nGD8ITEPLA := aScan(aHGD8, {| aVet | aVet[2] == "GD8_ITEPLA"})
 nGD8CODPLA := aScan(aHGD8, {| aVet | aVet[2] == "GD8_CODPLA"})
 If Empty(aCGD8[1,nGD8ITEPLA])
  aCGD8[1, nGD8ITEPLA]	:= StrZero(1, Len(aCGD8[1, nGD8ITEPLA]))
 EndIf
 nLGD8 := IIF(Len(aCGD8) == 1 .And. Empty(aCGD8[1, nGD8CODTXD]), 0, Len(aCGd8))
 
 HS_BDados("GD9", @aHGD9, @aCGD9, @nUGD9, 2,, "'" + GA9->GA9_CODCON + "' == GD9->GD9_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGD9CODMAT := aScan(aHGD9, {| aVet | aVet[2] == "GD9_CODMAT"})
 nGD9PRIORI := aScan(aHGD9, {| aVet | aVet[2] == "GD9_PRIORI"})
 nGD9DATVIG := aScan(aHGD9, {| aVet | aVet[2] == "GD9_DATVIG"})
 nGD9ITEPLA := aScan(aHGD9, {| aVet | aVet[2] == "GD9_ITEPLA"})
 nGD9CODPLA := aScan(aHGD9, {| aVet | aVet[2] == "GD9_CODPLA"})
 If Empty(aCGD9[1,nGD9ITEPLA])
  aCGD9[1, nGD9ITEPLA]	:= StrZero(1, Len(aCGD9[1, nGD9ITEPLA]))
 EndIf
 nLGD9 := IIF(Len(aCGD9) == 1 .And. Empty(aCGD9[1, nGD9CODMAT]), 0, Len(aCGd9))

 HS_BDados("GDA", @aHGDA, @aCGDA, @nUGDA, 2,, "'" + GA9->GA9_CODCON + "' == GDA->GDA_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGDACODMED := aScan(aHGDA, {| aVet | aVet[2] == "GDA_CODMED"})
 nGDAPRIORI := aScan(aHGDA, {| aVet | aVet[2] == "GDA_PRIORI"})
 nGDADATVIG := aScan(aHGDA, {| aVet | aVet[2] == "GDA_DATVIG"})
 nGDAITEPLA := aScan(aHGDA, {| aVet | aVet[2] == "GDA_ITEPLA"})
 nGDACODPLA := aScan(aHGDA, {| aVet | aVet[2] == "GDA_CODPLA"}) 
 If Empty(aCGDA[1,nGDAITEPLA])
  aCGDA[1,nGDAITEPLA]	:= StrZero(1, Len(aCGDA[1, nGDAITEPLA]))
 EndIf
 nLGDA := IIF(Len(aCGDA) == 1 .And. Empty(aCGDA[1, nGDACODMED]), 0, Len(aCGdA))
 
 HS_BDados("GDF", @aHGDF, @aCGDF, @nUGDF, 2,, "'" + GA9->GA9_CODCON + "' == GDF->GDF_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGDFCODRES := aScan(aHGDF, {| aVet | aVet[2] == "GDF_CODRES"})
 nGDFPRIORI := aScan(aHGDF, {| aVet | aVet[2] == "GDF_PRIORI"})
 nGDFDATVIG := aScan(aHGDF, {| aVet | aVet[2] == "GDF_DATVIG"})
 nGDFITEPLA := aScan(aHGDF, {| aVet | aVet[2] == "GDF_ITEPLA"})
 nGDFCODPLA := aScan(aHGDF, {| aVet | aVet[2] == "GDF_CODPLA"})
 If Empty(aCGDF[1,nGDFITEPLA])
  aCGDF[1,nGDFITEPLA]	:= StrZero(1, Len(aCGDF[1, nGDFITEPLA]))
 EndIf
 nLGDF := IIF(Len(aCGDF) == 1 .And. Empty(aCGDF[1, nGDFCODRES]), 0, Len(aCGdF))
 
 HS_BDados("GDG", @aHGDG, @aCGDG, @nUGDG, 1,, "'" + GA9->GA9_CODCON + "' == GDG->GDG_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGDGDIASEM := aScan(aHGDG, {| aVet | aVet[2] == "GDG_DIASEM"})
 nGDGHINACR := aScan(aHGDG, {| aVet | aVet[2] == "GDG_HINACR"})
 nGDGHFIACR := aScan(aHGDG, {| aVet | aVet[2] == "GDG_HFIACR"})
 nLGDG := IIF(Len(aCGDG) == 1 .And. Empty(aCGDG[1,nGDGHINACR]), 0, Len(aCGdG))
 
 For nCont := 1 To Len(aCGCM)
  cCodGCM += IIF(!EMPTY(cCodGCM), ",", "") +  "'" + aCGCM[nCont, 1]+ "'"
 Next 
 
 HS_BDados("GC1", @aHGC1, @aCGC1, @nUGC1, 1,, "GC1->GC1_CODPLA IN (" + cCodGCM + ") ", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGC1ITEPLA := aScan(aHGC1, {| aVet | aVet[2] == "GC1_ITEPLA"})
 nGC1DATVIG := aScan(aHGC1, {| aVet | aVet[2] == "GC1_DATVIG"})
 nGC1TPMMED := aScan(aHGC1, {| aVet | aVet[2] == "GC1_TPMMED"})
 If Empty(aCGC1[1,nGC1ITEPLA])
  aCGC1[1, nGC1ITEPLA]	:= StrZero(1, Len(aCGC1[1, nGC1ITEPLA]))
 EndIf
 nLGC1 := IIF(Len(aCGC1) == 1 .And. Empty(aCGC1[1, nGC1ITEPLA]), 0, Len(aCGC1))

 HS_BDados("GFV", @aHGFV, @aCGFV, @nUGFV, 1,, "'" + GA9->GA9_CODCON + "' == GFV->GFV_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGFVITEPLA := aScan(aHGFV, {| aVet | aVet[2] == "GFV_ITEPLA"})
 nGFVNOMCAT := aScan(aHGFV, {| aVet | aVet[2] == "GFV_NOMCAT"})
 nGFVCODPLA := aScan(aHGFV, {| aVet | aVet[2] == "GFV_CODPLA"})
 If Empty(aCGFV[1, nGFVITEPLA])
  aCGFV[1, nGFVITEPLA]	:= StrZero(1, Len(aCGFV[1, nGFVITEPLA]))
 EndIf
 nLGFV := IIF(Len(aCGFV) == 1 .And. Empty(aCGFV[1, nGFVITEPLA]), 0, Len(aCGFV))
 
 HS_BDados("GGK", @aHGGK, @aCGGK, @nUGGK, 1,, "'" + GA9->GA9_CODCON + "' == GGK->GGK_CODCON", .T., /*cCpoLeg*/, /*cLstCpo*/, /*cElimina*/, /*cCpoNao*/, /*cStaReg*/, /*cCpoMar*/, /*cMarDef*/, .T.)
 nGGKITEMTO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_ITEMTO"})
 nGGKTPITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_TPITEM"})
 nGGKCDITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_CDITEM"})
 nGGKDSITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_DSITEM"})
 nGGKQTTETO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_QTTETO"})
 nGGKVLTETO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_VLTETO"})
 If Empty(aCGGK[1, nGGKITEMTO])
  aCGGK[1, nGGKITEMTO]	:= StrZero(1, Len(aCGGK[1, nGGKITEMTO]))
 EndIf
 nLGGK := IIF(Len(aCGGK) == 1 .And. Empty(aCGGK[1, nGGKCDITEM]), 0, Len(aCGGK))
Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_DIFA18 ∫ Autor ≥ Gilson da Silva    ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Cadastro dos Diferenciados - Tratamento das funcoes        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_DIFA18(cAlias,nReg,nOpc)          
 Local aArea := GetArea() 
 Local nOpcA := 0, nGDOpc := IIf(aRotina[nOpc, 4] == 2 .Or. aRotina[nOpc, 4] == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 Local oDlg
 Local aItensMar := {}, cCpoChave := "GA9->GA9_CODCON+GCM->GCM_CODPLA" 
 Local bFS_FacDif	:= {||FS_FacDif(aRotina[nOpc, 4])} // Facilitador para copia dos diferenciados de um plano para outro
 Local bFS_Teto  	:= {||FS_Teto(aRotina[nOpc, 4],oGGK)} // Teto Orcamentario
 Local aButtons := {}, bKeyf4 
 Local cMVNivel := GETMV("MV_NIVEUSU",, 0)
  
 Private oHS_MBrw 
 Private nCont := 0, cGcaTipo := "0"
   
 //Private aTela := {{},{},{},{},{}}, aGets := {{},{},{},{},{}} 
 Private aTela := {}, aGets := {}
 
 If !(cNivel >= cMVNivel)
  HS_MsgInf(STR0094, STR0009, STR0095) //"Usu·rio com autorizaÁ„o somente para visualizaÁ„o das informaÁıes. NÌvel inferior ao informado no par‚metro MV_NIVEUSU."###"AtenÁ„o"###"ValidaÁ„o de acesso"
 EndIf
 
 If !Hs_LockTab(@aTravas, cAlias,,aRotina[nOpc, 4])
  Return(nil)
 EndIf

 oGa4:= ""
 oGa5:= ""
 oGa6:= ""
 oGaC:= ""
 oGcR:= ""
 oGc6:= ""
 oGd8:= ""
 oGd9:= ""
 oGdA:= ""
 oGdF:= ""
 oGdG:= ""
 oGEE:= ""
 oGCM:= ""
 oGC1:= ""
 oGFV:= ""
 oGGK:= ""
 
 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ Inclusao dos botoes dos facilitadores ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
 Aadd(aButtons	, {'PARAMETROS',{||Eval(bFS_FacDif)},STR0042, STR0051} ) //"Gerar diferenciados de um plano para outro"
 Aadd(aButtons	, {'SIMULACA',{||Eval(bFS_Teto)},STR0070, "Teto"}  )  //"Teto OrÁament·rio"

 bKeyf4 :=	SetKey( VK_F4, { || Eval(bFS_FacDif)} )

 DbSelectArea("GCM")  //Posiciona GCM
 DbSetOrder(1) // GCM_FILIAL + GCM_CODCON + GCM_CODPLA
 DbSeek(xFilial("GCM") + GA9->GA9_CODCON)
 
 HS_GERACOLS(nOpc)
 
 

 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 050, .T., .T. } )	   
 AAdd( aObjects, { 100, 090, .T., .T., .T.})
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )
 nOpcA := 0
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],000 To aSize[6],aSize[5] Of GetWndDefault() PIXEL //"Convenios"

 oHS_MBrw := HS_MBrow(oDlg, "GCM", {005, 000, 435, 110}, ;
                        "'" + GA9->GA9_CODCON + "'", ;
                        "'" + GA9->GA9_CODCON + "'", ;
                        /*"GCM_STATUS"*/, /*aCores*/, /*"GCM_OK"*/, /*aResMar*/, /*@aItensMar*/, ;
                        cCpoChave, /*bViewReg*/, .F.)
  oHS_MBrw:Align := CONTROL_ALIGN_TOP
  oHS_MBrw:bChange := {||HS_GERACOLS(nOpc)}
	 
  
  // Monta o Folder
  @ aPObjs[2, 2],aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3],aSize[5] Pixel OF oDlg PROMPTS STR0016, STR0017, STR0018, STR0019, STR0020, STR0021, STR0024, STR0025, STR0026, STR0032, STR0034, STR0054, STR0067, STR0070 PIXEL  //"Excecoes"###"Grp. AMB"###"CH'S"###"Mat/Med/Proced."###"Cod Proc Convenio"###"Tab. Procedimento###"Tab. Tax/Dia"###"Tab. Materiais"###"Tab. Medicamentos"###"Rest/Frig" ####"Hor. Acrescimo" //"Vigencia Plano"##" Categoria"###"Teto"
  oFolder:Align := CONTROL_ALIGN_ALLCLIENT

  oGA4 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,, "+GA4_CDITEM",,,99999,,,, oFolder:aDialogs[1], aHGA4, aCGA4)
  oGA4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGA4:lF3Header:=.F.   //Instrucao para a MsNewGetDados pegar a Consulta no SXB a partir do que foi modificado atraves da funcao HS_F3A18().
  oGA4:bChange := {|| HS_F3A18("GA4")}
  oGA4:cFieldOk := "HS_GDAtrib(oGA4, {{nGA4STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGA4:oBrowse:bDelete := {|| HS_GDAtrib(oGA4, {{nGA4STAREG, "BR_CINZA", "BR_VERDE"}}), oGA4:DelLine()}
   
   
  oGA5 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,,, "+GA5_CDITEM",,,99999,,,, oFolder:aDialogs[2], aHGA5, aCGA5)  
  oGA5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGA5:cFieldOk := "HS_GDAtrib(oGA5, {{nGA5STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGA5:oBrowse:bDelete := {|| HS_GDAtrib(oGA5, {{nGA5STAREG, "BR_CINZA", "BR_VERDE"}}), oGA5:DelLine()}
  
  
  oGA6 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,,, "+GA6_CDITEM",,,99999,,,, oFolder:aDialogs[3], aHGA6, aCGA6)
  oGA6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 
  oGA6:cFieldOk := "HS_GDAtrib(oGA6, {{nGA6STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGA6:oBrowse:bDelete := {|| HS_GDAtrib(oGA6, {{nGA6STAREG, "BR_CINZA", "BR_VERDE"}}), oGA6:DelLine()}
  
  
  oGAC := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,,, "+GAC_CDITEM",,,99999,,,, oFolder:aDialogs[4], aHGAC, aCGAC)
  oGAC:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGAC:lF3Header:=.F.   //Instrucao para a MsNewGetDados pegar a Consulta no SXB a partir do que foi modificado atraves da funcao HS_F3A18().
  oGAC:bChange := {|| HS_F3A18("GAC")}
  oGAC:cFieldOk := "HS_GDAtrib(oGAC, {{nGACSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGAC:oBrowse:bDelete := {|| HS_GDAtrib(oGAC, {{nGACSTAREG, "BR_CINZA", "BR_VERDE"}}), oGAC:DelLine()}
  
  
  
  oGCR := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,,,"+GCR_ITEM",,,99999,,,, oFolder:aDialogs[5], aHGCR, aCGCR)
  oGCR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGCR:cFieldOk := "HS_GDAtrib(oGCR, {{nGCRSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGCR:oBrowse:bDelete := {|| HS_GDAtrib(oGCR, {{nGCRSTAREG, "BR_CINZA", "BR_VERDE"}}), oGCR:DelLine()}
  
  
  oGC6 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,"HS_DuplAC(oGC6:oBrowse:nAt, oGC6:aCols, {nGC6TABPRO, nGC6DATVIG})",,"+GC6_ITEPLA",,,99999,,,, oFolder:aDialogs[6], aHGC6, aCGC6)
  oGC6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGC6:cFieldOk := "HS_GDAtrib(oGC6, {{nGC6STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGC6:oBrowse:bDelete := {|| IIF(Fs_VldDel(aVldDelGC6),Eval({|| HS_GDAtrib(oGC6, {{nGC6STAREG, "BR_CINZA", "BR_VERDE"}}), oGC6:DelLine()}),.F.)}
  
  
  oGD8 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,"HS_DuplAC(oGD8:oBrowse:nAt, oGD8:aCols, {nGD8CODTXD, nGD8DATVIG})",,"+GD8_ITEPLA",,,99999,,,, oFolder:aDialogs[7], aHGD8, aCGD8)
  oGD8:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGD8:cFieldOk := "HS_GDAtrib(oGD8, {{nGD8STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGD8:oBrowse:bDelete := {|| IIF(Fs_VldDel(aVldDelGD8),Eval({|| HS_GDAtrib(oGD8, {{nGD8STAREG, "BR_CINZA", "BR_VERDE"}}), oGD8:DelLine()}),.F.)}
  
  
  oGD9 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,"HS_DuplAC(oGD9:oBrowse:nAt, oGD9:aCols, {nGD9CODMAT, nGD9DATVIG})",,"+GD9_ITEPLA",,,99999,,,, oFolder:aDialogs[8], aHGD9, aCGD9)
  oGD9:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGD9:cFieldOk := "HS_GDAtrib(oGD9, {{nGD9STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGD9:oBrowse:bDelete := {|| IIF(Fs_VldDel(aVldDelGD9),Eval({|| HS_GDAtrib(oGD9, {{nGD9STAREG, "BR_CINZA", "BR_VERDE"}}), oGD9:DelLine()}),.F.)}
  
  
  oGDA := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,"HS_DuplAC(oGDA:oBrowse:nAt, oGDA:aCols, {nGDACODMED, nGDADATVIG})",,"+GDA_ITEPLA",,,99999,,,, oFolder:aDialogs[9], aHGDA, aCGDA)
  oGDA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGDA:cFieldOk := "HS_GDAtrib(oGDA, {{nGD9STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGDA:oBrowse:bDelete := {|| IIF(Fs_VldDel(aVldDelGDA),Eval({|| HS_GDAtrib(oGDA, {{nGDASTAREG, "BR_CINZA", "BR_VERDE"}}), oGDA:DelLine()}),.F.)}
  
  oGDF := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,"HS_DuplAC(oGDF:oBrowse:nAt, oGDF:aCols, {nGDFCODRES, nGDFDATVIG})",,"+GDF_ITEPLA",,,99999,,,, oFolder:aDialogs[10], aHGDF, aCGDF)
  oGDF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGDF:cFieldOk := "HS_GDAtrib(oGDF, {{nGDFSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGDF:oBrowse:bDelete := {|| IIF(Fs_VldDel(aVldDelGDF),Eval({|| HS_GDAtrib(oGDF, {{nGDFSTAREG, "BR_CINZA", "BR_VERDE"}}), oGDF:DelLine()}),.F.)}
  
  oGDG := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,,, "+GDG_CDITEM",,,99999,,,, oFolder:aDialogs[11], aHGDG, aCGDG)
  oGDG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGDG:cFieldOk := "HS_GDAtrib(oGDG, {{nGDGSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGDG:oBrowse:bDelete := {|| HS_GDAtrib(oGDG, {{nGDGSTAREG, "BR_CINZA", "BR_VERDE"}}), oGDG:DelLine()}
  
  oGC1 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,"HS_DuplAC(oGC1:oBrowse:nAt, oGC1:aCols, {nGC1DATVIG})",,"+GC1_ITEPLA",,,99999,,,, oFolder:aDialogs[12], aHGC1, aCGC1)
  oGC1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGC1:cFieldOk := "HS_GDAtrib(oGC1, {{nGC1STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGC1:oBrowse:bDelete := {|| HS_GDAtrib(oGC1, {{nGC1STAREG, "BR_CINZA", "BR_VERDE"}}), oGC1:DelLine()}
  
  oGFV := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,,,"+GFV_ITEPLA",,,99999,,,, oFolder:aDialogs[13], aHGFV, aCGFV)
  oGFV:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGFV:cFieldOk := "HS_GDAtrib(oGFV, {{nGFVSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGFV:oBrowse:bDelete    := {|| IIF(Fs_VldDel(aVldDelGFV),Eval({|| HS_GDAtrib(oGFV, {{nGFVSTAREG, "BR_CINZA", "BR_VERDE"}}), oGFV:DELLINE()}),.F.)}
    
  oGGK := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aSize[5], nGDOpc,,,"+GGK_ITEMTO",,,99999,,,, oFolder:aDialogs[14], aHGGK, aCGGK)
  oGGK:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGGK:lF3Header:=.F.   //Instrucao para a MsNewGetDados pegar a Consulta no SXB a partir do que foi modificado atraves da funcao HS_F3A18().  
  oGGK:cFieldOk := "HS_GDAtrib(oGGK, {{nGGKSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGGK:oBrowse:bDelete    := {|| HS_GDAtrib(oGGK, {{nGGKSTAREG, "BR_CINZA", "BR_VERDE"}}), oGGK:DELLINE()}
  oGGK:bChange := {|| HS_F3A18("GGK")}  

  Hs_CarVld()
  
		oFolder:bChange    := {|| IIf(oFolder:nOption == 8, cGcaTipo := "0", IIf(oFolder:nOption == 9, cGcaTipo := "1", cGcaTipo := "2"))}
 
 

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, ;
                                                                IIF(Obrigatorio(aGets, aTela) .And. ; 
                                                                  HS_TudoOK("GA4", oGA4, nGA4ORIDES) .And. ;
                                                                  HS_TudoOK("GA5", oGA5, nGA5CODGPA) .And. ;
                                                                  HS_TudoOK("GA6", oGA6, nGA6TIPCHF) .And. ;
                                                                  HS_TudoOK("GAC", oGAC, nGACARQORI) .And. ;
                                                                  HS_TudoOK("GCR", oGCR, nGCRDESPRO) .And. ;
                                                                  HS_TudoOK("GC6", oGC6, nGC6TABPRO) .And. ;
                                                                  HS_TudoOK("GD8", oGD8, nGD8CODTXD) .And. ;
                                                                  HS_TudoOK("GD9", oGD9, nGD9CODMAT) .And. ;
                                                                  HS_TudoOK("GDA", oGDA, nGDACODMED) .And. ;
                                                                  HS_TudoOK("GDF", oGDF, nGDFCODRES) .And. ;
                                                                  HS_TudoOK("GDG", oGDG, nGDGHINACR) .And. ;
                                                                  HS_TudoOK("GFV", oGFV, nGFVNOMCAT) .And. ;
                                                                  HS_TudoOK("GGK", oGGK, nGGKCDITEM) .And. ;
                                                                  HS_TudoOK("GC1", oGC1, nGC1DATVIG)     , ;
                                                                  oDlg:End(), nOpcA == 0)}, ;  
                                                            {|| nOpcA := 0, oDlg:End()},, aButtons) 
                  
	SetKey(VK_F4, bKeyF4)
 If nOpcA == 1
  FS_GrvA18(nOpc)
 EndIf   
 RestArea(aArea)
 HS_UnLockT(@aTravas)
Return(Nil) 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_VldA18 ∫ Autor ≥ Gilson da Silva    ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao dos campos chave dos relacionamentos             ∫±±
±±∫          ≥ para inclusao                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_VldA18(cAlias)
 Local lRet   := .F., cAliasOld := Alias() 
 Local nPos   := 0, nForACols := 0
 Local aArea  := GetArea()
 Local aIntNG := {}
 Local cCampo := ReadVar()
 
 Default cAlias := ""

 If cAlias=="GA4"
	 If     cGa4_OriDes $ "0/3/A"
   If !(lRet := HS_SeekRet("SB1", "PadR(AllTrim(M->GA4_CODDES), Len(SB1->B1_COD))", 1, .F., "GA4_DESDES", "B1_DESC",,, .T.))
    HS_MsgInf(STR0043, STR0009, STR0056) //"Mat/Med nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"###"ValidaÁ„o dos campos chaves"
	  EndIf  
 	ElseIf cGa4_OriDes $ "1/4/5"
 	 If !(lRet := HS_SeekRet("GA7", "PadR(AllTrim(M->GA4_CODDES), Len(GA7->GA7_CODPRO))", 1, .F., "GA4_DESDES", "GA7_DESC",,, .T.))
    HS_MsgInf(STR0045, STR0009, STR0056) //"Procedimento nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf
	 ElseIf cGa4_OriDes $ "6/7/9"
	  If !(lRet := HS_SeekRet("GAQ", "PadR(AllTrim(M->GA4_CODDES), Len(GAQ->GAQ_GRUPRO))", 1, .F., "GA4_DESDES", "GAQ_DESC",,, .T.))
    HS_MsgInf(STR0046, STR0009, STR0056) //"Grupo de Procedimento nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
 	 EndIf 
	 ElseIf cGa4_OriDes $ "2/C"
	  If !(lRet := HS_SeekRet("GAA", "PadR(AllTrim(M->GA4_CODDES), Len(GAA->GAA_CODTXD))", 1, .F., "GA4_DESDES", "GAA_DESC",,, .T.))
    HS_MsgInf(STR0045, STR0009, STR0056) //"Procedimento nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
	  EndIf
 	ElseIf cGa4_OriDes == "8"
   If !(lRet := HS_SeekRet("GCS", "PadR(AllTrim(M->GA4_CODDES), Len(GCS->GCS_CODLOC))", 1, .F., "GA4_DESDES", "GCS_NOMLOC",,, .T.))
    HS_MsgInf(STR0047, STR0009, STR0056) //"Setor nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf 
  ElseIf cGa4_OriDes == "B" // GRUPO DE MATERIAL
   If !(lRet := HS_SeekRet("SBM", "PadR(AllTrim(M->GA4_CODDES), Len(SBM->BM_GRUPO))", 1, .F., "GA4_DESDES", "BM_GRUPO",,, .T.))
    HS_MsgInf(STR0108, STR0009, STR0109) //"Grupo de Material n„o encontrado."###"Atencao"###"ValidaÁ„o de grupo de material"
   EndIf   
  ElseIf cGa4_OriDes == "D" // CATEGORIA DE TAXAS/DIARIAS
   If !(lRet := HS_SeekRet("SX5", "'CT'+M->GA4_CODDES", 1, .F., "GA4_DESDES", "X5_DESCRI",,, .T.))
    HS_MsgInf(STR0110, STR0009, STR0111) //"Categoria de taxa/di·ria n„o encontrada."###"Atencao"###"ValidaÁ„o de categoria de taxa/di·ria"
   EndIf 
	 EndIf                  
 
 ElseIf cAlias == "GAC"
  If  cGac_ArqOri == "0"
   If !(lRet := HS_SeekRet("SB1", "PadR(AllTrim(M->GAC_CODPRO), Len(SB1->B1_COD))", 1, .F., "GAC_DESPRO", "B1_DESC",,, .T.))
    HS_MsgInf(STR0043, STR0009, STR0056)  //"Mat/Med nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf  
  ElseIf cGac_ArqOri == "1"
   If !(lRet := HS_SeekRet("GA7", "PadR(AllTrim(M->GAC_CODPRO), Len(GA7->GA7_CODPRO))", 1, .F., "GAC_DESPRO", "GA7_DESC",,, .T.))
    HS_MsgInf(STR0045, STR0009, STR0056) //"Procedimento nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf  
  ElseIf cGac_ArqOri == "2"
   If !(lRet := HS_SeekRet("GAF", "PadR(AllTrim(M->GAC_CODPRO), Len(GAF->GAF_CODKIT))", 1, .F., "GAC_DESPRO", "GAF_DESKIT",,, .T.))
    HS_MsgInf(STR0048, STR0009, STR0056) //"Kit nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf  
  ElseIf cGac_ArqOri == "3"
   If !(lRet := HS_SeekRet("GAA", "PadR(AllTrim(M->GAC_CODPRO), Len(GAA->GAA_CODTXD))", 1, .F., "GAC_DESPRO", "GAA_DESC",,, .T.))
    HS_MsgInf(STR0049, STR0009, STR0056) //"Tax/Dia nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf
	 ElseIf cGac_ArqOri == "4"
	  If !(lRet := HS_SeekRet("GA1", "PadR(AllTrim(M->GAC_CODPRO), Len(GA1->GA1_CODPCT))", 1, .F., "GAC_DESPRO", "GA1_DESC",,, .T.))
    HS_MsgInf(STR0050, STR0009, STR0056) //"Procedimento Padrao"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf    
  EndIf 
 
 ElseIf cAlias == "GC6P"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGC6TABPRO] <> aCols[n, nGC6TABPRO] .And. aVet[nGC6PRIORI] == M->GC6_PRIORI})
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0022, STR0009, STR0056) //"Prioridade duplicada"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GC6_PRIORI         := Space(aHeader[nGc6Priori, 4])
  ElseIf !(lRet := Len(ALLTRIM(M->GC6_PRIORI)) == 2)
   HS_MsgInf(STR0059, STR0009, STR0044) //"Tamanho do campo n„o pode ser menor que 2 dÌgitos"##"AtenÁ„o"##"Tab. Procedimento"  
   M->GC6_PRIORI         := Space(aHeader[nGc6Priori, 4]) 
  EndIf
	
	ElseIf cAlias == "GC6V"                         
	 If cAlias == "GC6V"
	  nPos:= aScan(aCols, {| aVet | aVet[nGC6TABPRO] == aCols[n, nGc6TabPro] .And. aVet[nGC6DATVIG] == M->GC6_DATVIG})
	 EndIf
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0023, STR0009, STR0056) //"VigÍncia duplicada para esta tabela"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GC6_TABPR := Space(aHeader[nGc6TabPro, 4])
  EndIf  	   
 
 ElseIf cAlias == "GD8P"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGD8CODTXD] <> aCols[n, nGD8CODTXD] .And. aVet[nGD8PRIORI] == M->GD8_PRIORI})
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0022, STR0009, STR0056) //STR0022 "Prioridade duplicada"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GD8_PRIORI         := Space(aHeader[nGd8Priori, 4])
  ElseIf !(lRet := Len(ALLTRIM(M->GD8_PRIORI)) == 2)
   HS_MsgInf(STR0059, STR0009, STR0060) //"Tamanho do campo n„o pode ser menor que 2 dÌgitos"##"AtenÁ„o"##"Tab. Tax/Dia"  
   M->GD8_PRIORI := Space(aHeader[nGd8Priori, 4])
  EndIf
	 	
	ElseIf cAlias == "GD8V"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGD8CODTXD] == aCols[n, nGD8CODTXD] .And. aVet[nGD8DATVIG] == M->GD8_DATVIG })
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0023, STR0009, STR0056) //"VigÍncia duplicada para esta tabela"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GD8_DATVIG := Space(aHeader[nGD8DATVIG, 4])
  EndIf  	   
 
 ElseIf cAlias == "GD9P"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGD9CODMAT] <> aCols[n, nGD9CODMAT] .And. aVet[nGD9PRIORI] == M->GD9_PRIORI})
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0022, STR0009, STR0056) //STR0022 "Prioridade duplicada"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GD9_PRIORI         := Space(aHeader[nGd9Priori, 4])
  ElseIf !(lRet := Len(ALLTRIM(M->GD9_PRIORI)) == 2)
   HS_MsgInf(STR0059, STR0009, STR0061) //"Tamanho do campo n„o pode ser menor que 2 dÌgitos"##"AtenÁ„o"##"Tab. Materiais"  
   M->GD9_PRIORI         := Space(aHeader[nGd9Priori, 4])
  EndIf
	
	ElseIf cAlias == "GD9V"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGD9CODMAT] == aCols[n, nGD9CODMAT] .And. aVet[nGD9DATVIG] == M->GD9_DATVIG })
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0023, STR0009, STR0056) //"VigÍncia duplicada para esta tabela"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GD9_CODMAT := Space(aHeader[nGd9CODMAT, 4])
  EndIf  	   
 
 ElseIf cAlias == "GDAP"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGDACODMED] <> aCols[n, nGDACODMED] .And. aVet[nGDAPRIORI] == M->GDA_PRIORI})
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0022, STR0009, STR0056) //"Prioridade duplicada"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GDA_PRIORI := Space(aHeader[nGdAPRIORI, 4])
  ElseIf !(lRet := Len(ALLTRIM(M->GDA_PRIORI)) == 2)
   HS_MsgInf(STR0059, STR0009, STR0062) //"Tamanho do campo n„o pode ser menor que 2 dÌgitos"##"AtenÁ„o"##"Tab. Medicamentos"  
   M->GDA_PRIORI := Space(aHeader[nGdAPRIORI, 4])
  EndIf
	
	ElseIf cAlias == "GDAV"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGDACODMED] == aCols[n, nGDACODMED] .And. aVet[nGDADATVIG] == M->GDA_DATVIG})
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0023, STR0009, STR0056) //"Tab. Medicamentos Repetida"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GDA_CODMED := Space(aHeader[nGdACODMED, 4])
  EndIf
 
 ElseIf cAlias == "GDFP"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGDFCODRES] <> aCols[n, nGDFCODRES] .And. aVet[nGDFPRIORI] == M->GDF_PRIORI})
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0022, STR0009, STR0056) //"Prioridade duplicada"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GDF_PRIORI := Space(aHeader[nGdFPRIORI, 4])
  ElseIf !(lRet := Len(ALLTRIM(M->GDF_PRIORI)) == 2)
   HS_MsgInf(STR0059,STR0009, STR0063) //"Tamanho do campo n„o pode ser menor que 2 dÌgitos"##"AtenÁ„o"##"Rest/Frig" 
   M->GDF_PRIORI := Space(aHeader[nGdFPRIORI, 4])
  EndIf
	
	ElseIf cAlias == "GDFV"    
	 nPos:= aScan(aCols, {| aVet | aVet[nGDFCODRES] == aCols[n, nGDFCODRES] .And. aVet[nGDFDATVIG] == M->GDF_DATVIG})
	 lRet:= IIf(nPos == 0, .T., .F.)
	 If !lRet
   HS_MsgInf(STR0023, STR0009, STR0056) //"Tab. Restaurante/Frigobar Repetida"###"Atencao"###"ValidaÁ„o dos campos chaves"
   M->GDF_CODRES := Space(aHeader[nGdFCODRES, 4])
  EndIf  
 
	ElseIf cAlias == "GGKT"
	 lRet := .T.
	 If !(lRet := M->GGK_TPITEM $ "01")
    HS_MsgInf(STR0075, STR0009, STR0056) //"Item invalido"###"Atencao"###"ValidaÁ„o dos campos chaves"	 
    M->GGK_TPITEM := Space(aHeader[nGGKTPITEM, 4])   
  	  
	 ElseIf !Empty(aCols[n, nGGKCDITEM])
 	 If !(lRet := (aScan(aCols, {| aVet | aVet[nGGKTPITEM] == M->GGK_TPITEM .And. aVet[nGGKCDITEM] == aCols[n, nGGKCDITEM]}) == 0))
    HS_MsgInf(STR0071, STR0009, STR0056) //"Item duplicado"###"Atencao"###"ValidaÁ„o dos campos chaves"
    M->GGK_TPITEM := Space(aHeader[nGGKTPITEM, 4])
   EndIf  
  Endif
  
  If lRet
   aCols[n][nGGKCDITEM] := Space(aHeader[nGGKCDITEM][4])
   aCols[n][nGGKDSITEM] := Space(aHeader[nGGKDSITEM][4])
   HS_F3A18("GGK")
  Endif 
 
	ElseIf cAlias == "GGKC"
  If cGGK_TpItem == "0"      //Procedimento
 	 If !(lRet := HS_SeekRet("GA7", "PadR(AllTrim(M->GGK_CDITEM), Len(GA7->GA7_CODPRO))", 1, .F., "GGK_DSITEM", "GA7_DESC",,, .T.))
    HS_MsgInf(STR0045, STR0009, STR0056) //"Procedimento nao encontrado"###"Atencao"###"ValidaÁ„o dos campos chaves"
   EndIf
  ElseIf cGGK_TpItem == "1"  //Especialidade
 	 If !(lRet := HS_SeekRet("GFR", "PadR(AllTrim(M->GGK_CDITEM), Len(GFR->GFR_CDESPE))", 1, .F., "GGK_DSITEM", "GFR_DSESPE",,, .T.))
    HS_MsgInf(STR0072, STR0009, STR0056) //"Especialidade n„o encontrada"###"Atencao"###"ValidaÁ„o dos campos chaves"
   Endif 
  Endif
  
  If lRet
 	 If !(lRet := (aScan(aCols, {| aVet | aVet[nGGKTPITEM] == aCols[n, nGGKTPITEM] .And. aVet[nGGKCDITEM] == M->GGK_CDITEM}) == 0))
    HS_MsgInf(STR0071, STR0009, STR0056) //"Item duplicado"###"Atencao"###"ValidaÁ„o dos campos chaves"
    M->GGK_CDITEM := Space(aHeader[nGGKCDITEM, 4])
    M->GGK_DSITEM := Space(aHeader[nGGKDSITEM, 4])
   EndIf  
  EndIf  
  
	ElseIf cAlias == "GGKV" .And. !(lRet := (M->GGK_VLTETO >= 0))
  HS_MsgInf(STR0073, STR0009, STR0070) //"Valor invalido"###"Atencao"###"Teto OrÁament·rio"

	ElseIf cAlias == "GGKQ" .And. !(lRet := (M->GGK_QTTETO >= 0))
  HS_MsgInf(STR0074, STR0009, STR0070) //"Quantidade invalida"###"Atencao"###"Teto OrÁament·rio"
 
 ElseIf cAlias == "GCM"
  If AllTrim(ReadVar()) == "M->GCM_LAYOUT"
   If !(lRet := Vazio() .Or. HS_SeekRet("GG2", "M->GCM_LAYOUT", 1, .F., "GCM_DSLOUT", "GG2_DESCRI",,, .T.))
    HS_MsgInf(STR0082, STR0009, STR0083) //"Layout n„o encontrado"###"Atencao"###"ValidaÁ„o de Plano" //"Layout n„o encontrado"###"ValidaÁ„o de Plano"
   EndIf 
  ElseIf AllTrim(ReadVar()) == "M->GCM_STATUS"
   If M->GCM_STATUS == "1" .And.  M->GA9_STATUS == "0" 
    HS_MsgInf(STR0084, STR0009, STR0083) //"Plano n„o pode ser ativado pois o ConvÍnio est· inativo."###"AtenÁ„o"###"ValidaÁ„o de Plano"
    lRet := .F.
   Else 
    lRet := .T. 
  EndIf
  ElseIf cCampo $ "M->GCM_TABMAT/M->GCM_TABMED"
   DbSelectArea("GCA")
   DbSetOrder(1)
   
   If !(lRet := (DbSeek(xFilial("GCA") + &cCampo) .And. GCA->GCA_TIPO == cGcaTipo))  
    HS_MsgInf(STR0124, STR0009, STR0123)
   Else
    oGCM:aCols[oGCM:nAt, IIf(cCampo == "M->GCM_TABMAT", nGCMDESMAT, nGCMDESMED)] := GCA->GCA_DESCRI
   EndIf
  ElseIf cCampo $ "M->GCM_TABPRO"
   If !(lRet := HS_SeekRet("GDB", cCampo,1,.f.,"GCM_DESPRO","GDB_DESCRI"))
    HS_MsgInf(STR0124, STR0009, STR0125)
   EndIf
  ElseIf cCampo $ "M->GCM_TABTXD"
   If !(lRet := HS_SeekRet("GD2", cCampo,1,.f.,"GCM_DESTXD","GD2_DESCRI"))
    HS_MsgInf(STR0124, STR0009, STR0126)
   EndIf 
 EndIf 
 
 ElseIf cAlias == "GA9"
  If AllTrim(ReadVar()) == "M->GA9_STATUS"
   If M->GA9_STATUS == "0" 
    For nForACols := 1 to Len(oGCM:aCols)
     oGCM:aCols[nForaCols, nGCMSTATUS] := "0"     
    Next
    oGCM:Refresh()
   EndIf
   lRet := .T.
  EndIf 
  
 ElseIf cCampo == "M->GA9_CNDPAG"
  If !(lRet := HS_SeekRet("SE4", "M->GA9_CNDPAG", 1, .F., "GA9_DCNDPG", "E4_DESCRI",,, .T.))
   HS_MsgInf(STR0089, STR0009, STR0090) //"CondiÁ„o de Pagamento n„o encontrada"###"AtenÁ„o"###"ValidaÁ„o dos campos"
  ElseIf Len(Condicao(100, M->GA9_CNDPAG, 0)) > 1
   HS_MsgInf(STR0091 + M->GA9_CNDPAG + STR0092, STR0009, STR0093)  //"CondiÁ„o de Pagamento "###" n„o permitida pois refere-se a mais de uma parcela."###"AtenÁ„o"###"ValidaÁ„o da CondiÁ„o de Pagamento"
   lRet := .F.
  EndIf 
 ElseIf cCampo == "M->GMX_TGTISS" 
  If !(lRet := HS_SeekRet("G17", "M->GMX_TGTISS", 1, .F., "GMX_DTGTIS", "G17_DESCRI",,, .T.))
   HS_MsgInf(STR0098, STR0009, STR0097)
  EndIf
 ElseIf cCampo == "M->GMX_INTINI" .Or. ReadVar() == "M->GMX_INTFIN"
  aIntNG := FS_VlIntNG(oGMX, oGMX:oBrowse:nAt, nGMXINTINI, nGMXINTFIN, nGMXTGTISS)
  If !(lRet := aIntNG[1])
   HS_MsgInf(aIntNG[2], STR0009, STR0099)
  EndIf
 ElseIf cCampo == "M->GA9_TBTISS"
  If !(lRet := HS_SeekRet("G24", "M->GA9_TBTISS", 1, .F., "GA9_DTBTIS", "G24_DESCRI",,, .T.)) 
   HS_MsgInf(STR0105, STR0009, STR0106)  //"Tabela TISS n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o Tabela TISS"
  EndIf
 ElseIf cCampo == "M->GNF_LSTPLA"
  aRetPla := HS_SEPPLA(M->GNF_LSTPLA, M->GA9_CODCON)
  If !(lRet := aRetPla[1])
   HS_MsgInf(STR0113 + ALLTRIM(aRetPla[2]) + STR0114, STR0009, STR0115) //"Plano(s) ["###"] n„o encontrados para o convÍnio selecionado."###"ValidaÁ„o planos"
  Else
   aRetPla := HS_SEPPLA(M->GNF_LSTPLA, M->GA9_CODCON, oGNF, nGNFLSTPLA, .T.) 
   If !(lRet := aRetPla[1])
    HS_MsgInf(STR0113 + ALLTRIM(aRetPla[2]) + STR0116, STR0009, STR0115) //"Plano(s) ["###"] j· possui regra cadastrada."###"ValidaÁ„o planos"
   Endif
  Endif
 ElseIf cCampo == "M->GC1_TPGRET"
  If !Empty(&(cCampo))
   If !( lRet := Hs_IniPadr("GCU", 1, &(cCampo), "GCU_TPGUIA",,.F.) == "7") //Retorno   
   Hs_MsgInf(STR0127,STR0009,STR0097) //"O Tipo de Guia escolhido deve ser igual a RETORNO"###"AtenÁ„o"###"ValidaÁ„o tipo de guia"
  EndIf
 EndIf 
 EndIf 
 
 DbSelectArea(cAliasOld)
 RestArea(aArea)     
Return(lRet)
                              

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_GrvA18 ∫ Autor ≥ Gilson da Silva    ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina de Atualizacao das tabelas                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_GrvA18(nOpc)
 Local wProcura := .F.
 Local lRet := .T.
 
 Private nForTabs := 0
  
 If nOpc # 2 // nao for consulta
  DbSelectArea("GA9")
  DbSetOrder(1) // GA9_FILIAL + GA9_CODCON
  wProcura := DbSeek(xFilial("GA9") + GA9->GA9_CODCON)
  If Inclui .Or. Altera 
   FS_Grava("GA4", 2, "GA9->GA9_CODCON + cCodPla + oGA4:aCols[pForACols, nGA4ITEM]", aHGA4, oGA4:aCols, nUGA4, nGa4OriDes, nGa4StaReg)
   FS_Grava("GA5", 3, "GA9->GA9_CODCON + cCodPla + oGA5:aCols[pForACols, nGA5ITEM]", aHGA5, oGA5:aCols, nUGA5, nGa5CodGpa, nGa5StaReg)
   FS_Grava("GA6", 2, "GA9->GA9_CODCON + cCodPla + oGA6:aCols[pForACols, nGA6ITEM]", aHGA6, oGA6:aCols, nUGA6, nGA6CHSVAL, nGa6StaReg)
   FS_Grava("GAC", 2, "GA9->GA9_CODCON + cCodPla + oGAC:aCols[pForACols, nGACITEM]", aHGAC, oGAC:aCols, nUGAC, nGacArqOri, nGacStaReg)
   FS_Grava("GCR", 1, "GA9->GA9_CODCON + cCodPla + oGCR:aCols[pForACols, nGCRITEM]", aHGCR, oGCR:aCols, nUGCR, nGcrCodPro, nGcrStaReg)   
   FS_Grava("GC6", 2, "cCodPla + oGC6:aCols[pForACols, nGC6ITEPLA]"                , aHGC6, oGC6:aCols, nUGC6, nGC6TABPRO, nGc6StaReg)
   FS_Grava("GD8", 2, "cCodPla + oGD8:aCols[pForACols, nGD8ITEPLA]"                , aHGD8, oGD8:aCols, nUGD8, nGD8CODTXD, nGd8StaReg)
   FS_Grava("GD9", 2, "cCodPla + oGD9:aCols[pForACols, nGD9ITEPLA]"                , aHGD9, oGD9:aCols, nUGD9, nGD9CODMAT, nGd9StaReg)
   FS_Grava("GDA", 2, "cCodPla + oGDA:aCols[pForACols, nGDAITEPLA]"                , aHGDA, oGDA:aCols, nUGDA, nGDACODMED, nGdaStaReg)
   FS_Grava("GDF", 2, "cCodPla + oGDF:aCols[pForACols, nGDFITEPLA]"                , aHGDF, oGDF:aCols, nUGDF, nGDFCODRES, nGdfStaReg)
   FS_Grava("GDG", 2, "GA9->GA9_CODCON + cCodPla + oGDG:aCols[pForACols, nGDGITEM]", aHGDG, oGDG:aCols, nUGDG, nGDGHINACR, nGdgStaReg)
   FS_Grava("GC1", 2, "cCodPla + oGC1:aCols[pForACols, nGC1ITEPLA]"                , aHGC1, oGC1:aCols, nUGC1, nGC1ITEPLA, nGc1StaReg)
   FS_Grava("GFV", 1, "cCodPla + oGFV:aCols[pForACols, nGFVITEPLA]"                , aHGFV, oGFV:aCols, nUGFV, nGFVITEPLA, nGfvStaReg)
   FS_Grava("GGK", 1, "cCodPla + oGGK:aCols[pForACols, nGGKITEMTO]"                , aHGGK, oGGK:aCols, nUGGK, nGGKITEMTO, nGgkStaReg)
  EndIf
 EndIf              
Return(lRet)                      

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_Grava  ∫ Autor ≥ Gilson da Silva    ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Grava arquivos de relacionamento - Ga4, Ga5, GA6, GAC, GCR ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_Grava(cAlias, nOrd, cChave, aHGrv, aCGrv, nUGrv, nPos, nStaReg)
 Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
 Local cPref := cAlias + "->" + PrefixoCpo(cAlias)
 Local lCond := .F.
 Private pForACols := 0
 
 If aScan(aCGrv, {| aVet | aVet[nStaReg] <> "BR_VERDE"}) <= 0
  Return(Nil)
 EndIf 
 
 If Len(aCGrv) > 0
  If ValType(aCGrv[1, nPos]) == "C"
   lCond := !Empty(aCGrv[1, nPos]) 
  ElseIf ValType(aCGrv[1, nPos]) == "N"  
	  lCond := !aCGrv[1, nPos] == 0 
  ElseIf ValType(aCGrv[1, nPos]) == "D"  
	  lCond := !aCGrv[1, nPos] == CTOD("  /  /  ")
	 EndIf   	 
	EndIf 
 
 If Len(aCGrv) > 1 .Or. lCond   
  DbSelectArea(cAlias)
  DbSetOrder(nOrd)
  
  While (nForACols := aScan(aCGrv, {| aVet | aVet[nStaReg] <> "BR_VERDE"}, nForACols + 1)) > 0
  
   pForACols := nForACols
   
   lAchou := (cAlias)->(DbSeek(xFilial(cAlias) + &(cChave)))
   
   If lAchou .And. aCGrv[nForACols, nGA4STAREG] == "BR_CINZA" // exclusao
    RecLock(cAlias, .F.)
     DbDelete()
    MsUnlock()
   Else
    RecLock(cAlias, !lAchou)
     HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
     &(cPref + "_FILIAL") := xFilial(cAlias)
     If cAlias <> "GC1"
      &(cPref + "_CODCON") := GA9->GA9_CODCON
     EndIf 
     &(cPref + "_CODPLA") := cCodPla     
     &(cPref + "_LOGARQ") := HS_LogArq()
    MsUnlock()                  
   EndIf 
  End
 EndIf
 
 DbSelectArea(cAliasOld)
 
Return(Nil)

Static Function Fs_ExcCli()
 Local aARea := GetArea()
 Local lRet  := .T.       
 Local aCliente := {{"A1_FILIAL", xFilial("SA1"), NIL}, ;
                    {"A1_COD"   , GA9->GA9_CODCLI , NIL}, ;
                    {"A1_LOJA"  ,GA9->GA9_LOJA   , NIL}} 
 Private lMsErroAuto
  
   MSExecAuto({|X, Y| Mata030(X, Y)}, aCliente, 5)
     
   If lMsErroAuto   
    DisarmTransaction()
    Mostraerro()
    lRet := .F.
   EndIf     
   
 RestArea(aARea)
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_Deleta ∫ Autor ≥ Gilson da Silva    ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina de DELETE dos relacionamentos dos Diferenciados     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_Deleta(cAlias, nOrd, cChave)

 Local aARea := GetArea()
 
 DbSelectArea(cAlias)
 DbSetOrder(nOrd)
 While DbSeek(xFilial(cAlias) + cChave)
   If(cAlias == "GA9")
    If!(Fs_ExcCli())
     Return(nil) 
    EndIf
   EndIf
 
  RecLock(cAlias, .F.)
   DbDelete()
  MsUnlock()
  DbSkip()
 End
 
 RestArea(aARea)
 
Return(Nil)                          

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_F3A18  ∫ Autor ≥ Gilson da Silva    ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina de validacao qdo pressionar a tecla F3 nos campos.  ∫±±
±±∫          ≥ Chamada do Valid dos Campos.                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_F3A18(cAlias) 

If cAlias == "GA4"
 If !(ReadVar() == "M->GA4_ORIDES")
  M->GA4_ORIDES := aCols[n][nGa4OriDes]
 EndIf  

 cGa4_OriDes := IIF(ReadVar() == "M->GA4_ORIDES", M->GA4_ORIDES, aCols[n][nGa4OriDes])
 
 If     cGa4_OriDes $ "0/3/A" // Mat/Med ou Mat/Med Especial
  oGA4:aInfo[nGa4CodDes][01] := "SB1"
 ElseIf cGa4_OriDes $ "1/4/5" // Procedimento  ou Procedimento Especial ou Urgencia
  oGA4:aInfo[nGa4CodDes][01] := "GA7"
 ElseIf cGa4_OriDes $ "2/C" // Taxas / Diarias
  oGA4:aInfo[nGa4CodDes][01] := "GAA"
 ElseIf cGa4_OriDes $ "6/7/9" // Grupo de Procedimentos
  oGA4:aInfo[nGa4CodDes][01] := "GAQ"
 ElseIf cGa4_OriDes == "8" // SETOR
  oGA4:aInfo[nGa4CodDes][01] := "GCS"
 ElseIf cGa4_OriDes == "B" // GRUPO DE MATERIAL
  oGA4:aInfo[nGa4CodDes][01] := "SBM"
 ElseIf cGa4_OriDes == "D" // CATEGORIA DE TAXAS/DIARIAS
  oGA4:aInfo[nGa4CodDes][01] := "CT"   
 EndIf 

ElseIf cAlias == "GAC" 
 If !(ReadVar() == "M->GAC_ARQORI")
  M->GAC_ARQORI := aCols[n][nGacArqOri]
 Else // sempre limpa o codigo/desc do produto
  oGAC:aCols[n][nGACCODPRO]  := SPACE(Len(GAC->GAC_CODPRO)) 
  oGAC:aCols[n][nGACDESPRO] := SPACE(Len(GA7->GA7_DESC))  
 EndIf  

 cGac_ArqOri := IIF(ReadVar() == "M->GAC_ARQORI", M->GAC_ARQORI, aCols[n][nGacArqOri])
 
 If     cGac_ArqOri == "0" // Mat/Med
  oGAC:aInfo[nGacCodPro][01] := "SB1"
 ElseIf cGac_ArqOri == "1" // Procedimento/Honorario 
  oGAC:aInfo[nGacCodPro][01] := "GA7"
 ElseIf cGac_ArqOri == "2" // Kit
  oGAC:aInfo[nGacCodPro][01] := "GAF"
 ElseIf cGac_ArqOri == "3" // Taxas/Diarias
  oGAC:aInfo[nGacCodPro][01] := "GAA"   
 ElseIf cGac_ArqOri == "4" // Procedimento padrao
  oGAC:aInfo[nGacCodPro][01] := "GA1"   
 EndIf
  
ElseIf cAlias == "GGK"
 If !(ReadVar() == "M->GGK_TPITEM")
  M->GGK_TPITEM := aCols[n][nGGKTPITEM]
 EndIf  

 cGGK_TPITEM := IIF(ReadVar() == "M->GGK_TPITEM", M->GGK_TPITEM, aCols[n][nGGKTPITEM])
 
 If     cGGK_TpItem == "0" // Procedimento
  oGGK:aInfo[nGGKCdItem][01] := "GA7"
 ElseIf cGGK_TpItem == "1" // Especialidade
  oGGK:aInfo[nGGKCdItem][01] := "GFR001"
 Endif

EndIf
Return(.T.)       

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_DescA18∫ Autor ≥ Gilson da Silva    ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina de validacao dos campos de descricao.               ∫±±
±±∫          ≥ Chamada do X3_RELACAO do campo GA4_DESDES.                 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_DescA18(cAlias)
 Local cGa4_OriDes := ""
 Local cGa4_CodDes := ""
 Local cGa5_CodGpa := ""
 Local cGa6_CodLoc := ""
 Local cGac_ArqOri := ""
 Local cGac_CodPro := ""                                      
 Local cGc6_CodTab := ""
 Local cGcr_CodPro := ""
 Local cGd8_CodTxd := ""
 Local cGd9_CodMat := ""   
 Local cGda_CodMed := ""
 Local cGGK_CdItem := ""
 Local cGGK_TpItem := ""
 Local cDescri     := ""  
 
 If cAlias = "GA4"
  cGa4_OriDes := IIf(Inclui, M->GA4_ORIDES, IIf(Alias() == "TMPGA4", (Alias())->GA4_ORIDES, ""/*GA4->GA4_ORIDES*/))
  cGa4_CodDes := IIf(Inclui, M->GA4_CODDES, IIf(Alias() == "TMPGA4", (Alias())->GA4_CODDES, ""/*GA4->GA4_CODDES*/))
  If !EMPTY(cGa4_CodDes)
   If     cGa4_OriDes $ "0/3/A"  // Mat/Med ou Mat/Med Especial
    cDescri := HS_IniPadr("SB1", 1, PadR(AllTrim(cGa4_CodDes), Len(SB1->B1_COD)), "B1_DESC")
   ElseIf cGa4_OriDes $ "1/4/5" // Procedimentos ou Procedimento Especial ou Urgencia
    cDescri := HS_IniPadr("GA7", 1, PadR(AllTrim(cGa4_CodDes), Len(GA7->GA7_CODPRO)), "GA7_DESC")
   ElseIf cGa4_OriDes $ "2/C" // Taxas / Diarias                                                                    	
    cDescri := HS_IniPadr("GAA", 1, PadR(AllTrim(cGa4_CodDes), Len(GAA->GAA_CODTXD)), "GAA_DESC")
   ElseIf cGa4_OriDes $ "6/7/9" // Grupo de Procedimentos
    cDescri := HS_IniPadr("GAQ", 1, PadR(AllTrim(cGa4_CodDes), Len(GAQ->GAQ_GRUPRO)), "GAQ_DESC")
   ElseIf cGa4_OriDes == "B"
    cDescri := HS_IniPadr("SBM", 1, PadR(AllTrim(cGa4_CodDes), Len(SBM->BM_GRUPO)), "BM_DESC")     
   ElseIf cGa4_OriDes == "D"
    cDescri := HS_IniPadr("SX5", 1, "CT" + PadR(AllTrim(cGa4_CodDes), Len(SX5->X5_CHAVE)), "X5_DESCRI")
   ElseIf cGa4_OriDes == "8"
    cDescri := HS_IniPadr("GCS", 1, PadR(AllTrim(cGa4_CodDes), Len(GCS->GCS_CODLOC)), "GCS_NOMLOC")
   EndIf
  EndIf 
  
 ElseIf cAlias == "GA5" 
  cGa5_CodGpa := IIf(Inclui, M->GA5_CODGPA, IIf(Alias() == "TMPGA5", (Alias())->GA5_CODGPA, ""))
  If !EMPTY(cGa5_CodGpa)
   cDescri := HS_IniPadr("GAQ", 1, cGa5_CodGpa, "GAQ_DESC")
  EndIf
  
 ElseIf cAlias == "GA6" 
  cGa6_CodLoc := IIf(Inclui, M->GA6_CODLOC, IIf(Alias() == "TMPGA6", (Alias())->GA6_CODLOC, ""))
  If !EMPTY(cGa6_CodLoc)
   cDescri := HS_IniPadr("GCS", 1, cGa6_CodLoc, "GCS_NOMLOC")
  EndIf
    
 ElseIf cAlias == "GAC" 
  cGac_ArqOri := IIf(Inclui, M->GAC_ARQORI, IIf(Alias() == "TMPGAC", (Alias())->GAC_ARQORI, ""/*GAC->GAC_ARQORI*/))
  cGac_CodPro := IIf(Inclui, M->GAC_CODPRO, IIf(Alias() == "TMPGAC", (Alias())->GAC_CODPRO, ""/*GAC->GAC_CODPRO*/))
  If !EMPTY(cGac_CodPro)
   If     cGac_ArqOri == "0" // Mat / Med
    cDescri := HS_IniPadr("SB1", 1, PadR(AllTrim(cGac_CodPro), Len(SB1->B1_COD)), "B1_DESC")
   ElseIf cGac_ArqOri == "1" // Procedimentos                              
    cDescri := HS_IniPadr("GA7", 1, PadR(AllTrim(cGac_CodPro), Len(GA7->GA7_CODPRO)), "GA7_DESC")
   ElseIf cGac_ArqOri == "2" // Kit                              
    cDescri := HS_IniPadr("GAF", 1, PadR(AllTrim(cGac_CodPro), Len(GAF->GAF_CODKIT)), "GAF_DESKIT")
   ElseIf cGac_ArqOri == "3" // TAXAS/DIARIAS                              
    cDescri := HS_IniPadr("GAA", 1, PadR(AllTrim(cGac_CodPro), Len(GAA->GAA_CODTXD)), "GAA_DESC") 
   ElseIf cGac_ArqOri == "4" // Procedimento Padrao
    cDescri := HS_IniPadr("GA1", 1, PadR(AllTrim(cGac_CodPro), Len(GA1->GA1_CODPCT)), "GA1_DESC")
   EndIf
  EndIf 
 
 ElseIf cAlias == "GCR" 
  cGcr_CodPro := IIf(Inclui, M->GCR_CODPRO, IIf(Alias() == "TMPGCR", (Alias())->GCR_CODPRO, ""))
  If !EMPTY(cGcr_CodPro)
   cDescri := HS_IniPadr("GA7", 1, cGcr_CodPro, "GA7_DESC") 
  EndIf     
  
 ElseIf cAlias == "GC6"
  cGc6_CodTab := IIf(Inclui, "", IIf(Alias() == "TMPGC6", (Alias())->GC6_TABPRO, ""))
 If !EMPTY(cGc6_CodTab)
   cDescri := HS_IniPadr("GDB", 1, cGc6_CodTab, "GDB_DESCRI")
 EndIf 
  
 ElseIf cAlias == "GD8" 
  cGd8_CodTxd := IIf(Inclui, M->GD8_CODTXD, IIf(Alias() == "TMPGD8", (Alias())->GD8_CODTXD, ""))
  If !EMPTY(cGd8_CodTxd)
   cDescri := HS_IniPadr("GD2", 1, cGd8_CodTxd, "GD2_DESCRI")
  EndIf
  
 ElseIf cAlias == "GD9" 
  cGd9_CodMat := IIf(Inclui, M->GD9_CODMAT, IIf(Alias() == "TMPGD9", (Alias())->GD9_CODMAT, ""))
  If !EMPTY(cGd9_CodMat)
   cDescri := HS_IniPadr("GCA", 1, cGd9_CodMat, "GCA_DESCRI")
  EndIf  
 
 ElseIf cAlias == "GDA" 
  cGda_CodMed := IIf(Inclui, M->GDA_CODMED, IIf(Alias() == "TMPGDA", (Alias())->GDA_CODMED, ""))
  If !EMPTY(cGda_CodMed)
   cDescri := HS_IniPadr("GCA", 1, cGda_CodMed, "GCA_DESCRI")
  EndIf
  
 ElseIf cAlias == "GDF" 
  cGdf_CodRes := IIf(Inclui, M->GDF_CODRES, IIf(Alias() == "TMPGDF", (Alias())->GDF_CODRES, ""))
  If !EMPTY(cGdf_CodRes)
   cDescri := HS_IniPadr("GCA", 1, cGdf_CodRes, "GCA_DESCRI")
  EndIf
  
 ElseIf cAlias == "GGK" 
  cGGK_TpItem := IIf(Inclui, M->GGK_TpItem, IIf(Alias() == "TMPGGK", (Alias())->GGK_TpItem, ""))
  cGGK_CdItem := IIf(Inclui, M->GGK_CdItem, IIf(Alias() == "TMPGGK", (Alias())->GGK_CdItem, ""))
  If !EMPTY(cGGK_TpItem) .And. !EMPTY(cGGK_CdItem)
   If cGGK_TpItem == "0"
    cDescri := HS_IniPadr("GA7", 1, Padr(AllTrim(cGGK_CdItem), Len(GA7->GA7_CODPRO)), "GA7_DESC")    
   ElseIf cGGK_TpItem == "1"
    cDescri := HS_IniPadr("GFR", 1, Padr(AllTrim(cGGK_CdItem), Len(GFR->GFR_CDESPE)), "GFR_DSESPE")        
   Endif 
  EndIf

 EndIf
  
Return(cDescri)         

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_GERACOLS ∫ Autor ≥ Gilson da Silva ∫ Data ≥  02/12/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera AHEADER E Acols das Tabelas GA4-GA5-GA6-GAC-GCR-GC6   ∫±±
±±∫          ≥                                  GD8-GD9-GAD-GFV-GGK       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar (Agenda Ambulatorial)             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HS_GERACOLS(nOpc)  
 Local nX := 0 
 Local nPos := 0
 Local lExclui := .F.  
 Local nCt := 0
 
 If ValType(oGa4) == "O"
  nCont++ 
  If nCont > 1
	  //Verifica se foi marcada para exclusao alguma linha do aCols. 
 	 
	  If (aScan(oGA4:aCols,{|aVet|aVet[nUGA4 + 1]}) > 0)
		  lExclui := .T.
			ElseIf (aScan(oGA5:aCols,{|aVet|aVet[nUGA5 + 1]}) > 0)  
				lExclui := .T.
			ElseIf (aScan(oGA6:aCols,{|aVet|aVet[nUGA6 + 1]}) > 0)
		  lExclui := .T.			
			ElseIf (aScan(oGAC:aCols,{|aVet|aVet[nUGAC + 1]}) > 0)
		  lExclui := .T.			
		 ElseIf (aScan(oGCR:aCols,{|aVet|aVet[nUGCR + 1]}) > 0)			
		  lExclui := .T.
		 ElseIf (aScan(oGC6:aCols,{|aVet|aVet[nUGC6 + 1]}) > 0)			
		  lExclui := .T.
		 ElseIf (aScan(oGD8:aCols,{|aVet|aVet[nUGD8 + 1]}) > 0)			
		  lExclui := .T.
		 ElseIf (aScan(oGD9:aCols,{|aVet|aVet[nUGD9 + 1]}) > 0)			
		  lExclui := .T.	
		 ElseIf (aScan(oGDA:aCols,{|aVet|aVet[nUGDA + 1]}) > 0)			
		  lExclui := .T.		  
		 ElseIf (aScan(oGDF:aCols,{|aVet|aVet[nUGDF + 1]}) > 0)			
		  lExclui := .T.
		 ElseIf (aScan(oGDG:aCols,{|aVet|aVet[nUGDG + 1]}) > 0)			
		  lExclui := .T.
		 ElseIf (aScan(oGC1:aCols,{|aVet|aVet[nUGC1 + 1]}) > 0)			
		  lExclui := .T.
		 ElseIf (aScan(oGFV:aCols,{|aVet|aVet[nUGFV + 1]}) > 0)			
		  lExclui := .T.
		 ElseIf (aScan(oGGK:aCols,{|aVet|aVet[nUGGK + 1]}) > 0)			
		  lExclui := .T.
			EndIf

   If oGa4:lChgField .Or. oGa5:lChgField .Or. oGa6:lChgField .Or. oGaC:lChgField .Or. oGCR:lChgField .Or. ;
      oGC6:lChgField .Or. oGD8:lChgField .Or. oGD9:lChgField .Or. oGDA:lChgField .Or. oGDF:lChgField .Or. ;
      oGDG:lChgField .Or. oGC1:lChgField .Or. oGFV:lChgField .Or. oGGK:lChgField .Or. lExclui //Verifica se houve modificacao em uma das linhas dos acols.
    If MsgYesNo(STR0035) //"Deseja Atualizar os Registro(s)? "
     FS_GrvA18(nOpc)
     oGa4:lChgField := .F.   //Retorna o status de nao modificado para as linhas dos acols.
     oGa5:lChgField := .F.
					oGa6:lChgField := .F.
					oGaC:lChgField := .F. 
					oGcR:lChgField := .F. 
					oGc6:lChgField := .F.  
					oGd8:lChgField := .F.  
					oGd9:lChgField := .F.  
					oGda:lChgField := .F.  										
					oGdf:lChgField := .F.  										
					oGdG:lChgField := .F.  										
					oGC1:lChgField := .F.  										
					oGFV:lChgField := .F.
					oGGK:lChgField := .F.
 	  EndIf  
 	 EndIf 
  EndIf	
 EndIf
  
 aCGCM	:= {}
 aHGCM := {}
 nUGCM := 0
 nLGCM := 0
 aCGA4	:= {}
 aHGA4 := {}
 nUGA4 := 0
 nLGA4 := 0
 aCGA5	:= {}
 aHGA5 := {}
 nUGA5 := 0
 nLGA5 := 0
 aCGA6	:= {}
 aHGA6 := {}
 nUGA6 := 0
 nLGA6 := 0
 aCGAC	:= {}
 aHGAC := {}
 nUGAC := 0
 nLGAC := 0
 aCGCR	:= {}
 aHGCR := {}
 nUGCR := 0
 nLGCR := 0 
 aCGC6	:= {}
 aHGC6 := {}
 nUGC6 := 0
 nLGC6 := 0 
 aCGD8	:= {}
 aHGD8 := {}
 nUGD8 := 0
 nLGD8 := 0 
 aCGD9	:= {}
 aHGD9 := {}
 nUGD9 := 0
 nLGD9 := 0 
 aCGDA	:= {}
 aHGDA := {}
 nUGDA := 0
 nLGDA := 0 
 aCGDF	:= {}
 aHGDF := {}
 nUGDF := 0
 nLGDF := 0 
 aCGDG	:= {}
 aHGDG := {}
 nUGDG := 0
 nLGDG := 0 
 aCGC1	:= {}
 aHGC1 := {}
 nUGC1 := 0
 nLGC1 := 0 
 aCGFV	:= {}
 aHGFV := {}
 nUGFV := 0
 nLGFV := 0 
 aCGGK	:= {}
 aHGGK := {}
 nUGGK := 0
 nLGGK := 0 
 
 RegToMemory("GCM") // Gera variavies de memoria para o GCM 
 
 HS_BDados("GA4", @aHGA4, @aCGA4, @nUGA4, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GA4->GA4_CODCON .AND. '" + M->GCM_CODPLA + "' == GA4->GA4_CODPLA", Nil), .T.)
 nGA4STAREG := aScan(aHGA4, {| aVet | aVet[2] == "HSP_STAREG"}) 
 nGA4ORIDES := aScan(aHGA4, {| aVet | aVet[2] == "GA4_ORIDES"}) 
 nGA4CODDES := aScan(aHGA4, {| aVet | aVet[2] == "GA4_CODDES"})
 nGA4DESDES := aScan(aHGA4, {| aVet | aVet[2] == "GA4_DESDES"})
 nGA4DATVIG := aScan(aHGA4, {| aVet | aVet[2] == "GA4_DATVIG"})
 nGA4ITEM   := aScan(aHGA4, {| aVet | aVet[2] == "GA4_CDITEM"})
 If Empty(aCGA4[1, nGA4ITEM])
  aCGA4[1, nGA4ITEM]	:= StrZero(1, Len(aCGA4[1, nGA4ITEM]))
 EndIf
 nLGA4 := IIF(Len(aCGA4) == 1 .And. Empty(aCGA4[1, nGA4CODDES]), 0, Len(aCGA4))

 aJoin := {{" JOIN " + RetSqlName("GAQ") + " GAQ", "GAQ.GAQ_DESC", "GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' AND GAQ.GAQ_GRUPRO = GA5.GA5_CODGPA", "GA5_DESGPA"}}

 HS_BDados("GA5", @aHGA5, @aCGA5, @nUGA5, 3,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GA5->GA5_CODCON .And. '" + M->GCM_CODPLA + "' == GA5->GA5_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGA5STAREG := aScan(aHGA5, {| aVet | aVet[2] == "HSP_STAREG"}) 
 nGA5CODGPA := aScan(aHGA5, {| aVet | aVet[2] == "GA5_CODGPA"})
 nGA5DESGPA := aScan(aHGA5, {| aVet | aVet[2] == "GA5_DESGPA"})
 nGA5VDIFCH := aScan(aHGA5, {| aVet | aVet[2] == "GA5_VDIFCH"})
 nGA5VDIFCO := aScan(aHGA5, {| aVet | aVet[2] == "GA5_VDIFCO"})
 nGA5DATVIG := aScan(aHGA5, {| aVet | aVet[2] == "GA5_DATVIG"})
 nGA5ITEM   := aScan(aHGA5, {| aVet | aVet[2] == "GA5_CDITEM"})
 If Empty(aCGA5[1, nGA5ITEM])
  aCGA5[1, nGA5ITEM]	:= StrZero(1, Len(aCGA5[1, nGA5ITEM]))
 EndIf
 nLGA5 := IIF(Len(aCGA5) == 1 .And. Empty(aCGA5[1, nGA5VDIFCH]) .And. Empty(aCGA5[1, nGA5VDIFCO]), 0, Len(aCGA5))

 aJoin := {{" LEFT JOIN " + RetSqlName("GCS") + " GCS", "GCS.GCS_NOMLOC", "GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GA6.GA6_CODLOC", "GA6_NOMLOC"}}

 HS_BDados("GA6", @aHGA6, @aCGA6, @nUGA6, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GA6->GA6_CODCON .And. '" + M->GCM_CODPLA + "' == GA6->GA6_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGA6STAREG := aScan(aHGA6, {| aVet | aVet[2] == "HSP_STAREG"}) 
 nGA6TIPCHF := aScan(aHGA6, {| aVet | aVet[2] == "GA6_TIPCHF"})  
 nGA6DATVIG := aScan(aHGA6, {| aVet | aVet[2] == "GA6_DATVIG"})
 nGA6CHSVAL := aScan(aHGA6, {| aVet | aVet[2] == "GA6_CHSVAL"})
 nGA6MODLOC := aScan(aHGA6, {| aVet | aVet[2] == "GA6_MODLOC"})
 nGA6CODLOC := aScan(aHGA6, {| aVet | aVet[2] == "GA6_CODLOC"})
 nGA6NOMLOC := aScan(aHGA6, {| aVet | aVet[2] == "GA6_NOMLOC"})
 nGA6ITEM   := aScan(aHGA6, {| aVet | aVet[2] == "GA6_CDITEM"})
 If Empty(aCGA6[1, nGA6ITEM])
  aCGA6[1, nGA6ITEM]	:= StrZero(1, Len(aCGA6[1, nGA6ITEM]))
 EndIf
 nLGA6 := IIF(Len(aCGA6) == 1 .And. (aCGA6[1, nGA6CHSVAL]) == 0, 0, Len(aCGA6))

 HS_BDados("GAC", @aHGAC, @aCGAC, @nUGAC, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GAC->GAC_CODCON .And. '" + M->GCM_CODPLA + "' == GAC->GAC_CODPLA", Nil), .T.)
 nGACSTAREG := aScan(aHGAC, {| aVet | aVet[2] == "HSP_STAREG"}) 
 nGACARQORI := aScan(aHGAC, {| aVet | aVet[2] == "GAC_ARQORI"})  
 nGACCODPRO := aScan(aHGAC, {| aVet | aVet[2] == "GAC_CODPRO"})
 nGACDESPRO := aScan(aHGAC, {| aVet | aVet[2] == "GAC_DESPRO"})
 nGACVALPRO := aScan(aHGAC, {| aVet | aVet[2] == "GAC_VALPRO"})
 nGACCODPRE := aScan(aHGAC, {| aVet | aVet[2] == "GAC_CODPRE"})
 nGACNOMPRE := aScan(aHGAC, {| aVet | aVet[2] == "GAC_NOMPRE"})
 nGACDATVIG := aScan(aHGAC, {| aVet | aVet[2] == "GAC_DATVIG"})
 nGACITEM   := aScan(aHGAC, {| aVet | aVet[2] == "GAC_CDITEM"})  
 If Empty(aCGAC[1, nGACITEM])
  aCGAC[1, nGACITEM]	:= StrZero(1, Len(aCGAC[1, nGACITEM]))
 EndIf 
 nLGAC := IIF(Len(aCGAC) == 1 .And. Empty(aCGAC[1, nGACCODPRO]), 0, Len(aCGAC))

 aJoin := {{" LEFT JOIN " + RetSqlName("GA7") + " GA7", "GA7.GA7_DESC"  , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GCR.GCR_CODPRO", "GCR_DESPRO"},;
 										{" LEFT JOIN " + RetSqlName("GFR") + " GFR", "GFR.GFR_DSESPE", "GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*' AND GFR.GFR_CDESPE = GCR.GCR_CODESP", "GCR_NOMESP"},;
 										{" LEFT JOIN " + RetSqlName("GCS") + " GCS", "GCS.GCS_NOMLOC", "GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GCR.GCR_CODLOC", "GCS_NOMLOC"}}

 HS_BDados("GCR", @aHGCR, @aCGCR, @nUGCR, 3,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GCR->GCR_CODCON .And. '" + M->GCM_CODPLA + "' == GCR->GCR_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGCRSTAREG := aScan(aHGCR, {| aVet | aVet[2] == "HSP_STAREG"}) 
 nGCRITEM   := aScan(aHGCR, {| aVet | aVet[2] == "GCR_ITEM  "})
 nGCRCODPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CODPRO"})
 nGCRDESPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_DESPRO"})
 nGCRCODESP := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CODESP"})
 nGCRNOMESP := aScan(aHGCR, {| aVet | aVet[2] == "GCR_NOMESP"})
 nGCRHORPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_HORPRO"})
 nGCRCODLOC := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CODLOC"})
 nGCRNOMLOC := aScan(aHGCR, {| aVet | aVet[2] == "GCR_NOMLOC"})
 nGCRCPROUT := aScan(aHGCR, {| aVet | aVet[2] == "GCR_CPROUT"})
 nGCRDPROUT := aScan(aHGCR, {| aVet | aVet[2] == "GCR_DPROUT"})
 nGCRVLRPRO := aScan(aHGCR, {| aVet | aVet[2] == "GCR_VLRPRO"})
 nGCRDATVIG := aScan(aHGCR, {| aVet | aVet[2] == "GCR_DATVIG"})
 If Empty(aCGCR[1, nGCRITEM])
  aCGCR[1, nGCRITEM]	:= StrZero(1, Len(aCGCR[1, nGCRITEM]))
 EndIf
 nLGCR := IIF(Len(aCGCR) == 1 .And. Empty(aCGCR[1, nGCRCODPRO]), 0, Len(aCGCR)) 
 
 aJoin := {{" JOIN " + RetSqlName("GDB") + " GDB", "GDB.GDB_DESCRI", "GDB.GDB_FILIAL = '" + xFilial("GDB") + "' AND GDB.D_E_L_E_T_ <> '*' AND GDB.GDB_CHAVE = GC6.GC6_TABPRO", "GC6_NOMTAB"}}

 HS_BDados("GC6", @aHGC6, @aCGC6, @nUGC6, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GC6->GC6_CODCON .And. '" + M->GCM_CODPLA + "' == GC6->GC6_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGC6STAREG := aScan(aHGC6, {| aVet | aVet[2] == "HSP_STAREG"}) 
 nGC6TABPRO := aScan(aHGC6, {| aVet | aVet[2] == "GC6_TABPRO"})
 nGC6PRIORI := aScan(aHGC6, {| aVet | aVet[2] == "GC6_PRIORI"})
 nGC6DATVIG := aScan(aHGC6, {| aVet | aVet[2] == "GC6_DATVIG"}) 
 nGC6ITEPLA := aScan(aHGC6, {| aVet | aVet[2] == "GC6_ITEPLA"}) 
 nGC6CODPLA := aScan(aHGC6, {| aVet | aVet[2] == "GC6_CODPLA"})     
 
 If Empty(aCGC6[1, nGC6ITEPLA])
  aCGC6[1, nGC6ITEPLA]	:= StrZero(1, Len(aCGC6[1, nGC6ITEPLA]))
 EndIf
 nLGC6 := IIF(Len(aCGC6) == 1 .And. Empty(aCGC6[1, nGC6TABPRO]), 0, Len(aCGc6))
    
 aJoin := {{" JOIN " + RetSqlName("GD2") + " GD2", "GD2.GD2_DESCRI", "GD2.GD2_FILIAL = '" + xFilial("GD2") + "' AND GD2.D_E_L_E_T_ <> '*' AND GD2.GD2_CODTAB = GD8.GD8_CODTXD", "GD8_DESTXD"}}

 HS_BDados("GD8", @aHGD8, @aCGD8, @nUGD8, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GD8->GD8_CODCON .And. '" + M->GCM_CODPLA + "' == GD8->GD8_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGD8STAREG := aScan(aHGD8, {| aVet | aVet[2] == "HSP_STAREG"})
 nGD8CODTXD := aScan(aHGD8, {| aVet | aVet[2] == "GD8_CODTXD"})
 nGD8PRIORI := aScan(aHGD8, {| aVet | aVet[2] == "GD8_PRIORI"})
 nGD8DATVIG := aScan(aHGD8, {| aVet | aVet[2] == "GD8_DATVIG"})
 nGD8ITEPLA := aScan(aHGD8, {| aVet | aVet[2] == "GD8_ITEPLA"})
 If Empty(aCGD8[1, nGD8ITEPLA])
  aCGD8[1, nGD8ITEPLA]	:= StrZero(1, Len(aCGD8[1, nGD8ITEPLA]))
 EndIf
 nLGD8 := IIF(Len(aCGD8) == 1 .And. Empty(aCGD8[1, nGD8CODTXD]), 0, Len(aCGd8))
 
 aJoin := {{" JOIN " + RetSqlName("GCA") + " GCA", "GCA.GCA_DESCRI", "GCA.GCA_FILIAL = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' AND GCA.GCA_CODTAB = GD9.GD9_CODMAT", "GD9_DESMAT"}} 

 HS_BDados("GD9", @aHGD9, @aCGD9, @nUGD9, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GD9->GD9_CODCON .And. '" + M->GCM_CODPLA + "' == GD9->GD9_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGD9STAREG := aScan(aHGD9, {| aVet | aVet[2] == "HSP_STAREG"})
 nGD9CODMAT := aScan(aHGD9, {| aVet | aVet[2] == "GD9_CODMAT"})  
 nGD9PRIORI := aScan(aHGD9, {| aVet | aVet[2] == "GD9_PRIORI"})
 nGD9DATVIG := aScan(aHGD9, {| aVet | aVet[2] == "GD9_DATVIG"})
 nGD9ITEPLA := aScan(aHGD9, {| aVet | aVet[2] == "GD9_ITEPLA"})
 If Empty(aCGD9[1, nGD9ITEPLA])
  aCGD9[1, nGD9ITEPLA]	:= StrZero(1, Len(aCGD9[1, nGD9ITEPLA]))
 EndIf
 nLGD9 := IIF(Len(aCGD9) == 1 .And. Empty(aCGD9[1, nGD9CODMAT]), 0, Len(aCGd9))

 aJoin := {{" JOIN " + RetSqlName("GCA") + " GCA", "GCA.GCA_DESCRI", "GCA.GCA_FILIAL = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' AND GCA.GCA_CODTAB = GDA.GDA_CODMED", "GDA_DESMED"}} 

 HS_BDados("GDA", @aHGDA, @aCGDA, @nUGDA, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GDA->GDA_CODCON .And. '" + M->GCM_CODPLA + "' == GDA->GDA_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGDASTAREG := aScan(aHGDA, {| aVet | aVet[2] == "HSP_STAREG"})
 nGDACODMED := aScan(aHGDA, {| aVet | aVet[2] == "GDA_CODMED"}) 
 nGDAPRIORI := aScan(aHGDA, {| aVet | aVet[2] == "GDA_PRIORI"})
 nGDADATVIG := aScan(aHGDA, {| aVet | aVet[2] == "GDA_DATVIG"})
 nGDAITEPLA := aScan(aHGDA, {| aVet | aVet[2] == "GDA_ITEPLA"})
 If Empty(aCGDA[1, nGDAITEPLA])
  aCGDA[1,nGDAITEPLA]	:= StrZero(1, Len(aCGDA[1, nGDAITEPLA]))
 EndIf
 nLGDA := IIF(Len(aCGDA) == 1 .And. Empty(aCGDA[1, nGDACODMED]), 0, Len(aCGdA))
 
 aJoin := {{" JOIN " + RetSqlName("GCA") + " GCA", "GCA.GCA_DESCRI", "GCA.GCA_FILIAL = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' AND GCA.GCA_CODTAB = GDF.GDF_CODRES", "GDF_DESRES"}} 

 HS_BDados("GDF", @aHGDF, @aCGDF, @nUGDF, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GDF->GDF_CODCON .And. '" + M->GCM_CODPLA + "' == GDF->GDF_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGDFSTAREG := aScan(aHGDF, {| aVet | aVet[2] == "HSP_STAREG"})
 nGDFCODRES := aScan(aHGDF, {| aVet | aVet[2] == "GDF_CODRES"}) 
 nGDFPRIORI := aScan(aHGDF, {| aVet | aVet[2] == "GDF_PRIORI"})
 nGDFDATVIG := aScan(aHGDF, {| aVet | aVet[2] == "GDF_DATVIG"})
 nGDFITEPLA := aScan(aHGDF, {| aVet | aVet[2] == "GDF_ITEPLA"})
 If Empty(aCGDF[1, nGDFITEPLA])
  aCGDF[1, nGDFITEPLA]	:= StrZero(1, Len(aCGDF[1, nGDFITEPLA]))
 EndIf
 nLGDF := IIF(Len(aCGDF) == 1 .And. Empty(aCGDF[1, nGDFCODRES]), 0, Len(aCGdF))

 HS_BDados("GDG", @aHGDG, @aCGDG, @nUGDG, 2,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GDG->GDG_CODCON .And. '" + M->GCM_CODPLA + "' == GDG->GDG_CODPLA", Nil), .T.)
 nGDGSTAREG := aScan(aHGDG, {| aVet | aVet[2] == "HSP_STAREG"})
 nGDGDIASEM := aScan(aHGDG, {| aVet | aVet[2] == "GDG_DIASEM"})  
 nGDGHINACR := aScan(aHGDG, {| aVet | aVet[2] == "GDG_HINACR"})
 nGDGHFIACR := aScan(aHGDG, {| aVet | aVet[2] == "GDG_HFIACR"})
 nGDGITEM   := aScan(aHGDG, {| aVet | aVet[2] == "GDG_CDITEM"})
 If Empty(aCGDG[1, nGDGITEM])
  aCGDG[1, nGDGITEM]	:= StrZero(1, Len(aCGDG[1, nGDGITEM]))
 EndIf
 nLGDG := IIF(Len(aCGDG) == 1 .And. Empty(aCGDG[1, nGDGHINACR]), 0, Len(aCGdG))
 
 aJoin := {{" LEFT JOIN " + RetSqlName("GCU") + " GCU", "GCU.GCU_DESTPG", "GCU.GCU_FILIAL = '" + xFilial("GCU") + "' AND GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_CODTPG = GC1.GC1_TPGINT", "GC1_DTPGIN"}}

 HS_BDados("GC1", @aHGC1, @aCGC1, @nUGC1, 1,, IIf(nOpc # 3, "'" + M->GCM_CODPLA + "' == GC1->GC1_CODPLA", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGC1STAREG := aScan(aHGC1, {| aVet | aVet[2] == "HSP_STAREG"})
 nGC1ITEPLA := aScan(aHGC1, {| aVet | aVet[2] == "GC1_ITEPLA"})  
 nGC1DATVIG := aScan(aHGC1, {| aVet | aVet[2] == "GC1_DATVIG"})
 nGC1TPMMED := aScan(aHGC1, {| aVet | aVet[2] == "GC1_TPMMED"})
 If Empty(aCGC1[1, nGC1ITEPLA])
  aCGC1[1, nGC1ITEPLA]	:= StrZero(1, Len(aCGC1[1, nGC1ITEPLA]))
 EndIf
 nLGC1 := IIF(Len(aCGC1) == 1 .And. Empty(aCGC1[1, nGC1DATVIG]), 0, Len(aCGC1))

 HS_BDados("GFV", @aHGFV, @aCGFV, @nUGFV, 1,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GFV->GFV_CODCON .And. '" + M->GCM_CODPLA + "' == GFV->GFV_CODPLA", Nil), .T.)
 nGFVSTAREG := aScan(aHGFV, {| aVet | aVet[2] == "HSP_STAREG"})
 nGFVITEPLA := aScan(aHGFV, {| aVet | aVet[2] == "GFV_ITEPLA"}) 
 nGFVNOMCAT := aScan(aHGFV, {| aVet | aVet[2] == "GFV_NOMCAT"})  
 nGFVCODPLA := aScan(aHGFV, {| aVet | aVet[2] == "GFV_CODPLA"})
 If Empty(aCGFV[1, nGFVITEPLA])
  aCGFV[1,nGFVITEPLA]	:= StrZero(1, Len(aCGC6[1, nGFVITEPLA]))
 EndIf
 nLGFV := IIF(Len(aCGFV) == 1 .And. Empty(aCGFV[1, nGFVITEPLA]), 0, Len(aCGFV))

 HS_BDados("GGK", @aHGGK, @aCGGK, @nUGGK, 1,, IIf(nOpc # 3, "'" + GA9->GA9_CODCON + "' == GGK->GGK_CODCON .And. '" + M->GCM_CODPLA + "' == GGK->GGK_CODPLA", Nil), .T.)
 nGGKSTAREG := aScan(aHGGK, {| aVet | aVet[2] == "HSP_STAREG"})
 nGGKITEMTO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_ITEMTO"})
 nGGKTPITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_TPITEM"}) 
 nGGKCDITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_CDITEM"}) 
 nGGKDSITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_DSITEM"}) 
 nGGKQTTETO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_QTTETO"}) 
 nGGKVLTETO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_VLTETO"}) 
 If Empty(aCGGK[1, nGGKITEMTO])
  aCGGK[1, nGGKITEMTO]	:= StrZero(1, Len(aCGGK[1, nGGKITEMTO]))
 EndIf
 nLGGK := IIF(Len(aCGGK) == 1 .And. Empty(aCGGK[1, nGGKCDITEM]), 0, Len(aCGGK))

 If ValType(oGa4) == "O"
  oGa4:Acols := aClone(ACGA4)
  oGa5:Acols := aClone(ACGA5)  
  oGa6:Acols := aClone(ACGA6)
  oGac:Acols := aClone(ACGAC)
  oGcr:Acols := aClone(ACGCR)
  oGc6:Acols := aClone(ACGC6)
  oGd8:Acols := aClone(ACGD8)
  oGd9:Acols := aClone(ACGD9)
  oGda:Acols := aClone(ACGDA)
  oGdf:Acols := aClone(ACGDF)
  oGdg:Acols := aClone(ACGDG)
  oGC1:Acols := aClone(ACGC1)
  oGFV:Acols := aClone(ACGFV)
  oGGK:Acols := aClone(ACGGK)
  
  oGa4:oBrowse:Refresh()      
  oGa5:oBrowse:Refresh()      
  oGa6:oBrowse:Refresh()      
  oGaC:oBrowse:Refresh()      
  oGcR:oBrowse:Refresh() 
  oGc6:oBrowse:Refresh() 
  oGd8:oBrowse:Refresh() 
  oGd9:oBrowse:Refresh() 
  oGdA:oBrowse:Refresh() 
  oGdF:oBrowse:Refresh() 
  oGdG:oBrowse:Refresh() 
  oGC1:oBrowse:Refresh() 
  oGFV:oBrowse:Refresh() 
  oGGK:oBrowse:Refresh() 
 EndIf 
 cCodPla := GCM->GCM_CODPLA
Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_FacDif ∫ Autor ≥ Cibele Peria       ∫ Data ≥  17/06/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Facilitador: copia os diferenciados de um plano qualquer,  ∫±±
±±∫          ≥ de qualquer convenio, para um plano do convenio posiciona  ∫±±
±±∫          ≥ do.                                                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_FacDif(nOpc)
 Local aAlias     := {"GA4","GA5","GA6","GAC","GCR","GC6","GD8","GD9","GDA","GDF","GDG","GC1","GFV","GGK"}
 Local aParm      := {}
 Local nNum       := 0
 Local lSai       := .F.
 Local lCancel    := .F.
 Local lPgHSPA18  := .F. 
 
 Private cCodCon_Pa := GCM->GCM_CODCON 
 Private cCodPla_Pa := GCM->GCM_CODPLA
 Private cCodCon_De := ""
 Private cCodPla_De := ""
 Private nRegGCM    := 0  
 Private cErros     := ""
 
 DbSelectArea("GCM")
 nRegGCM    := RecNo()
 If Empty(GCM->GCM_CODPLA)
  HS_MsgInf(STR0036, STR0009, STR0057) //"Nenhum plano foi cadastrado. Verifique!"###"Atencao"###"Facilitador, copia os diferenciados"
  Return()
 EndIf
  
 If !MsgYesNo(STR0037 + GCM->GCM_CODPLA + STR0038) //"Tem certeza que deseja copiar os diferenciados para o plano "###"?"
  Return()
 EndIf
 lPgHSPA18 := Pergunte("HSPA18", .T.)                         
 While !lSai

  If !lPgHSPA18
   lCancel := .T.
   lSai    := .T.
  Else
   If mv_par02 == 2 .and. mv_par03 == 2 .and. mv_par04 == 2 .and. mv_par05 == 2 .and. ;
      mv_par06 == 2 .and. mv_par07 == 2 .and. mv_par08 == 2 .and. mv_par09 == 2 .and. ;
      mv_par10 == 2 .and. mv_par11 == 2 .and. mv_par12 == 2 .and. mv_par13 == 2 .and. ;
      mv_par14 == 2 .and. mv_par15 == 2 .And.                                           ;  
      HS_MsgInf(STR0052, STR0009, STR0057) //"Selecione pelo menos un dos itens de diferenciados!"###"Atencao"###"Facilitador, copia os diferenciados"
   Else
    lSai := .T.
   EndIf    
  EndIf
 End
 If lCancel
  Return()
 EndIf
  
 aParm := {mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08, mv_par09, mv_par10, mv_par11, mv_par12,mv_par13,mv_par14, mv_par15}
 
 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ Copia os diferenciados do plano De para o plano selecionado ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
 For nNum := 1 To Len(aAlias)
  
  If aParm[nNum] == 1   //1=Sim   2=Nao
   FS_ACopiar(aAlias[nNum])
  EndIf
 
 Next nNum   
 
 If !EMPTY(cErros)
  HS_MsgInf(STR0064 + CHR(13) + CHR(10) + cErros,; //"Alguns itens n„o foram gravados pois existe(m) prioridade(s) no Plano de origem j· cadastrada(s) no Plano de destino"
            STR0009, STR0065) //"AtenÁ„o"###"Verifique as Prioridades"
 EndIf
              
 DbSelectArea("GCM")
 DbSetOrder(1) // GCM_FILIAL + GCM_CODCON + GCM_CODPLA

 HS_GERACOLS(nOpc)

 DbSelectArea("GCM")
 
Return()

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_FILA18 ∫ Autor ≥ Cibele Peria       ∫ Data ≥  17/06/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina de validacao das perguntas.                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_FilA18()
 Local   cAliasOld := Alias(), lRet := .T.

 cCodPla_De := MV_PAR01
 cCodCon_De := HS_IniPadr("GCM", 2, MV_PAR01, "GCM_CODCON") 
 DbSelectArea("GCM")
 DbGoTo(nRegGCM)

 If Empty(cCodPla_De)
  HS_MsgInf(STR0010, STR0009, STR0058) //"Plano Invalido"###"Atencao"###"Rotina de validaÁ„o das perguntas"
  lRet := .F.

 ElseIf cCodPla_De == GCM->GCM_CODPLA
  HS_MsgInf(STR0039, STR0009, STR0058) //"Planos informados iguais. Verifique!"###"Atencao"###"Rotina de validaÁ„o das perguntas"
  lRet := .F.

 ElseIf Empty(cCodCon_De)
  HS_MsgInf(STR0040, STR0009, STR0058) //"Plano nao cadastrado"###"Atencao"###"Rotina de validaÁ„o das perguntas"
  lRet := .F.
    
 EndIf
 
 DbSelectArea(cAliasOld)
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_ACopiar∫ Autor ≥ Cibele Peria       ∫ Data ≥  20/06/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Copia as ocorrencias de diferenciado do plano de para o    ∫±±
±±∫          ≥ plano selecionado                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_ACopiar(cAlias)
 Local nLCop    := 0
 Local aCCop    := {}
 Local aHCop    := {}
 Local nUCop    := 0
 Local cPref    := cAlias + "->" + PrefixoCpo(cAlias)
 Local nForL    := 0
 Local nForC    := 0
 Local nNroSeq  := 0
 Local nChave   := ""
 Local cCond    := IIF(cAlias <> "GC1", cPref + "_CODCON == '" + cCodCon_De + "' .AND. " + cPref + "_CODPLA == '" + cCodPla_De + "'", cPref + "_CODPLA == '" + cCodPla_De + "'")
 Local lRet     := .F.
 Local nSTAREG  := 0
 
 nLCop   := HS_BDados(cAlias, @aHCop, @aCCop, @nUCop, 1,, cCond, .T.)
 nSTAREG := aScan(aHCop, {| aVet | aVet[2] == "HSP_STAREG"})

 If cAlias == "GA4"
  nChave := nGA4CodDes
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGA4OriDes] + aVet[nGA4CodDes] + DTOS(aVet[nGA4DatVig]) == aCCop[nForL, nGA4OriDes] + aCCop[nForL, nGA4CodDes] + DTOS(aCCop[nForL, nGA4DatVig]) }) > 0
    aCCop[nForL, nUCop+1] := .T.
   EndIf
  Next nForL

 ElseIf cAlias == "GA5"
  nChave := nGA5CodGpa
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGA5CodGpa] + DTOS(aVet[nGA5DatVig]) == aCCop[nForL, nGA5CodGpa] + DTOS(aCCop[nForL, nGA5DatVig]) }) > 0
    aCCop[nForL, nUCop+1] := .T.
   EndIf
  Next nForL

 ElseIf cAlias == "GA6"
  nChave := nGA6TipChf
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGA6TipChf] + aVet[nGA6CodLoc] + DTOS(aVet[nGA6DatVig]) == aCCop[nForL, nGA6TipChf] + aCCop[nForL, nGA6CodLoc]+ DTOS(aCCop[nForL, nGA6DatVig]) }) > 0
    aCCop[nForL, nUCop+1] := .T.
   EndIf
  Next nForL

 ElseIf cAlias == "GAC"
  nChave := nGACCodPro
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGACArqOri] + aVet[nGACCodPro] + DTOS(aVet[nGACDatVig]) == aCCop[nForL, nGACArqOri] + aCCop[nForL, nGACCodPro]+ DTOS(aCCop[nForL, nGACDatVig]) }) > 0
    aCCop[nForL, nUCop+1] := .T.
   EndIf
  Next nForL

 ElseIf cAlias == "GCR"
  nChave  := nGCRCodPro
  nNroSeq := nGCRItem
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGCRCodPro] + DTOS(aVet[nGCRDatVig]) == aCCop[nForL, nGCRCodPro] + DTOS(aCCop[nForL, nGCRDatVig]) }) > 0
    aCCop[nForL, nUCop + 1] := .T.
   EndIf
  Next nForL
  
 ElseIf cAlias == "GC6"  //"Tab. Procedimento"      
  nChave  := nGC6TabPro
  nNroSeq := nGC6ITEPLA
  If !(lRet := FS_PriRep(STR0044, aCCop, &("o"+cAlias+":aCols"), nGC6PRIORI)) 
   For nForL := 1 To nLCop
    If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGC6TabPro] + DTOS(aVet[nGC6DATVIG]) == aCCop[nForL, nGC6TabPro] + DTOS(aCCop[nForL, nGC6DatVig]) }) > 0
     aCCop[nForL, nUCop + 1] := .T.
    EndIf 
   Next nForL
  EndIf 
 
 ElseIf cAlias == "GD8"
  nChave  := nGD8CodTxD 
  nNroSeq := nGD8ITEPLA
  If !(lRet := FS_PriRep(STR0024, aCCop, &("o" + cAlias + ":aCols"), nGD8PRIORI)) //"Tab. Tax/Dia"
   For nForL := 1 To nLCop
    If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGD8CodTxD] + DTOS(aVet[nGD8DATVIG]) == aCCop[nForL, nGD8CodTxD] + DTOS(aCCop[nForL, nGD8DatVig]) }) > 0
     aCCop[nForL, nUCop + 1] := .T.
    EndIf 
   Next nForL
  EndIf
  
 ElseIf cAlias == "GD9"
  nChave  := nGD9CodMat 
  nNroSeq := nGD9ITEPLA
  If !(lRet := FS_PriRep(STR0061, aCCop, &("o" + cAlias + ":aCols"), nGD9PRIORI)) //"Tab. Materiais"
   For nForL := 1 To nLCop
    If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGD9CodMat] + DTOS(aVet[nGD9DATVIG]) == aCCop[nForL, nGD9CodMat] + DTOS(aCCop[nForL, nGD9DatVig]) }) > 0
     aCCop[nForL, nUCop + 1] := .T.
    EndIf 
   Next nForL
  EndIf 
 
 ElseIf cAlias == "GDA"
  nChave  := nGDACodMed
  nNroSeq := nGDAITEPLA
  If !(lRet := FS_PriRep(STR0062, aCCop, &("o" + cAlias + ":aCols"), nGDAPRIORI)) //"Tab. Medicamentos"
   For nForL := 1 To nLCop
    If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGDACodMed] + DTOS(aVet[nGDADATVIG]) == aCCop[nForL, nGDACodMed] + DTOS(aCCop[nForL, nGDADatVig]) }) > 0
     aCCop[nForL, nUCop + 1] := .T.
    EndIf 
   Next nForL
  EndIf 
 
 ElseIf cAlias == "GDF"
  nChave  := nGDFCodRes 
  nNroSeq := nGDFITEPLA
  If !(lRet := FS_PriRep(STR0032, aCCop, &("o" + cAlias + ":aCols"), nGDFPRIORI)) //"Rest/Frig"
   For nForL := 1 To nLCop
    If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGDFCodRes] + DTOS(aVet[nGDFDATVIG]) == aCCop[nForL, nGDFCodRes] + DTOS(aCCop[nForL, nGDFDatVig]) }) > 0
     aCCop[nForL, nUCop + 1] := .T.
    EndIf 
   Next nForL
  EndIf 

 ElseIf cAlias == "GDG"
  nChave  := nGDGHFIACR
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGDGDiaSem] + aVet[nGDGHINACR] + aVet[nGDGHFIACR] == aCCop[nForL, nGDGDiaSem] + aCCop[nForL, nGDGHINACR] + aCCop[nForL, nGDGHFIACR] }) > 0
    aCCop[nForL, nUCop + 1] := .T.
   EndIf 
  Next nForL
  
 ElseIf cAlias == "GC1"
  nChave  := nGC1TpmMed
  nNroSeq := nGC1ITEPLA
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| DTOS(aVet[nGC1DatVig]) + aVet[nGC1TpmMed] == DTOS(aCCop[nForL, nGC1DatVig]) + aCCop[nForL, nGC1TpmMed] }) > 0
    aCCop[nForL, nUCop + 1] := .T.
   EndIf 
  Next nForL
 
 ElseIf cAlias == "GFV"
  nChave  := nGFVITEPLA
  nNroSeq := nGFVITEPLA
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGFVITEPLA] == aCCop[nForL, nGFVITEPLA] }) > 0
    aCCop[nForL, nUCop + 1] := .T.
   EndIf 
  Next nForL
  
 ElseIf cAlias == "GGK"
  nChave  := nGGKCDItem         
  nNroSeq := nGGKITEMTO
  For nForL := 1 To nLCop
   If aScan(&("o" + cAlias):aCols, {|aVet| aVet[nGGKTPItem] + aVet[nGGKCDItem] == aCCop[nForL, nGGKTPITem] + aCCop[nForL, nGGKCDITem] }) > 0
    aCCop[nForL, nUCop + 1] := .T.
   EndIf 
  Next nForL
 EndIf 
 
 If !lRet .And. nLCop > 0
  If LEN(&("o" + cAlias):aCols) > 0 .And. EMPTY(&("o" + cAlias):aCols[1, nChave])
   &("o" + cAlias):aCols := {}
   &("nL" + cAlias) := 0
  EndIf
  
  For nForL := 1 To Len(aCCop) 
   If !aCCop[nForL, nUCop + 1] .And. !EMPTY(aCCop[nForL, nChave])
    &("o" + cAlias):AddLine(.T., .F.)
    &("o" + cAlias):lNewLine := .F.
    &("nL" + cAlias) += 1
    
    For nForC := 1 To Len(aCCop[nForL])
     If nForC <> nNroSeq
      &("o" + cAlias):aCols[&("nL" + cAlias), nForC] := aCCop[nForL, nForC]
     EndIf 
    Next
    HS_GDAtrib(&("o" + cAlias), {{nSTAREG, 'BR_AMARELO', 'BR_VERDE'}})
   EndIf 
  Next
   
  &("o" + cAlias):lChgField := .T.
  &("o" + cAlias):oBrowse:Refresh()
 EndIf  
 
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_PRIREP ∫Autor  ≥Daniel Peixoto      ∫ Data ≥  11/04/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Verifica se existe alguma prioridade ja cadastrada no plano∫±±
±±∫          ≥ destino igual a do plano origem                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_PriRep(cDescTab, aColsOri, aColsDst, nColItem)
Local nCont   := 1, nContFor := 0
Local lRet    := .F.

 While nCont <= Len(aColsOri) .And. !lRet
  For nContFor := 1 To Len(aColsDst)
   If STRZERO(Val(aColsOri[nCont, nColItem]), 2) == STRZERO(Val(aColsDst[nContFor, nColItem]), 2)
    cErros += cDescTab + STR0066 + STRZERO(Val(aColsOri[nCont, nColItem]), 2) + "]" + CHR(13) + CHR(10) //": Prioridade ["
    lRet := .T.
    Exit
   EndIf 
  Next
  nCont ++
 EndDo  

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_Teto   ∫ Autor ≥ Antonio Carlos     ∫ Data ≥  19/01/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Teto Orcamentario:                                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_Teto(nOpc)

 Local lSai  := .T.
 Local cPerg := "HSA18A" 
 Local cSql  := "" 
	Local aArea := GetArea()
 Local nPos  := 0

 If oFolder:nOption == 14 // So executa se for Teto Orcamentario

  If !Pergunte(cPerg, .T.)
   lSai := .F.                                      		
   Return(lSai)
  EndIf

  /*   Abrir tela de perguntas:
  1.Do  Procedimento ?       - MV_PAR01
  2.AtÈ Procedimento ?       - MV_PAR02
  3.Da  Especialidade ?      - MV_PAR03
  4.AtÈ  Especialidade ?     - MV_PAR04
  5.Do  Grupo Procedimento ? - MV_PAR05
  6.AtÈ Grupo Procedimento ? - MV_PAR06*/
 
  cSQL := "SELECT GA7.GA7_CODPRO QRY_CODPRO, GA7.GA7_DESC QRY_DESC, '1' AS QRY_TIPO "
  cSQL += " FROM " + RetSQLName("GA7") + " GA7"
  cSQL += " WHERE " 
  cSQL += "     GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
  cSQL += " AND GA7.GA7_CODPRO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
  cSQL += " UNION "

  cSQL += "SELECT GFR.GFR_CDESPE QRY_CODPRO, GFR.GFR_DSESPE QRY_DESC, '2' AS QRY_TIPO "
  cSQL += " FROM " + RetSQLName("GFR") + " GFR"
  cSQL += " WHERE " 
  cSQL += "     GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*' "
  cSQL += " AND GFR.GFR_CDESPE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
  cSQL += " UNION "

  cSQL += "SELECT GAQ.GAQ_GRUPRO QRY_CODPRO, GAQ.GAQ_DESC QRY_DESC, '3' AS QRY_TIPO "
  cSQL += " FROM " + RetSQLName("GAQ") + " GAQ"
  cSQL += " WHERE " 
  cSQL += "     GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' "
  cSQL += " AND GAQ.GAQ_GRUPRO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
  cSQL += " ORDER BY QRY_TIPO, QRY_CODPRO "
  cSQL :=  ChangeQuery(cSQL)
  TCQUERY cSQL NEW ALIAS "QRY"
 
  DbSelectArea("QRY")
  DbGoTop()

  While !Eof()

   nPos := aScan(oGGK:aCols, {| aVet | aVet[nGGKTPITEM]+ aVet[nGGKCDITEM] == QRY->QRY_TIPO + QRY->QRY_CODPRO})
   If nPos > 0
    DbSkip()  
   EndIf

   oGGK:AddLine(.T.,.F.)
   oGGK:lNewLine := .F.

   oGGK:aCols[oGGK:nAt, nGGKCDITEM] := QRY->QRY_CODPRO
   oGGK:aCols[oGGK:nAt, nGGKDSITEM] := QRY->QRY_DESC
   oGGK:aCols[oGGK:nAt, nGGKTPITEM] := QRY->QRY_TIPO
 
   oGGK:oBrowse:Refresh() 

   DbSkip()
  
  Enddo

  DbCloseArea()
  
 Else
 	HS_MsgInf(STR0085, STR0009, STR0070) //###"AtenÁ„o!"###"Teto OrÁamentario" //"OpÁ„o disponÌvel somente p/Teto OrÁament·rio"
 EndIf

 RestArea(aArea)
 
Return(lSai)

Static Function FS_VldPla(oOK)
 Local lRet := .T.
 Local nForaCols := 0
 
  For nForaCols := 1 to len(oOK:aCols)
   If !oOK:aCols[nForaCols, Len(oOK:aCols[nForaCols])] 
    If oOK:aCols[nForaCols, nGCMSTATUS] == "1" .And. M->GA9_STATUS == "0" 
     HS_MsgInf(STR0086 + oOK:aCols[nForaCols, nGCMCODPLA] + STR0087, STR0009, STR0088) //"Plano ["###"] n„o pode ser ativado pois o convÍnio est· inativo."###"AtenÁ„o"###"ValidaÁ„o da digitaÁ„o"
     lRet := .F.
     Exit
    Endif
   EndIf 
  Next

Return(lRet)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_VlIntNG ∫ Autor ≥ Patricia Queiroz  ∫ Data ≥  02/08/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao dos intervalos de numeracao da guia.             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HS_VldA18                                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_VlIntNG(oGMX, nAtGMX, nIntINI, nIntFIN, nTgTISS)

 Local lRet     := .T.
 Local cCondGMX := "", cMsgTISS := "" 
 Local nPosGMX  := 0    
 Local nValINI  := IIF(ReadVar() == "M->GMX_INTINI", M->GMX_INTINI, oGMX:aCols[nAtGMX, nIntINI])
 Local nValFIN  := IIF(ReadVar() == "M->GMX_INTFIN", M->GMX_INTFIN, oGMX:aCols[nAtGMX, nIntFIN])
 
 If (lRet := !(Empty(oGMX:aCols[nAtGMX, nTgTISS])))
  If !(lRet := !(ReadVar() == "M->GMX_INTINI" .And. nValFIN <> 0 .And. nValINI > nValFIN))
   cMsgTISS := STR0100//"O intervalo inicial n„o pode ser maior que o inicial."
  ElseIf !(lRet := !(nValFIN < nValINI .And. ReadVar() == "M->GMX_INTFIN"))
   cMsgTISS := STR0101//"O intervalo final n„o pode ser menor que o inicial."  
  EndIf   
 
  If lRet 
   If nValINI <> 0 .And. nValFIN <> 0
    cCondGMX := "aVet[" + AllTrim(STR(nTgTISS)) + "]" + " == " + " oGMX:aCols[" + AllTrim(STR(nAtGMX)) + ", " + AllTrim(STR(nTgTISS)) + "]" + " .And. aVet[" + AllTrim(STR(nIntINI)) + "]" + " <= " + AllTrim(STR(nValFIN)) + " .And. aVet[" + AllTrim(STR(nIntFIN)) + "]" + " >= " + AllTrim(STR(nValINI))
   ElseIf nValINI <> 0
    cCondGMX := "aVet[" + AllTrim(STR(nTgTISS)) + "]" + " == " + " oGMX:aCols[" + AllTrim(STR(nAtGMX)) + ", " + AllTrim(STR(nTgTISS)) + "]" + " .And. aVet[" + AllTrim(STR(nIntINI)) + "]" + " <= " + AllTrim(STR(nValINI)) + " .And. aVet[" + AllTrim(STR(nIntFIN)) + "]" + " >= " + AllTrim(STR(nValINI))
   ElseIf !Empty(oGMX:aCols[nAtGMX, nIntFIN])
    cCondGMX := "aVet[" + AllTrim(STR(nTgTISS)) + "]" + " == " + " oGMX:aCols[" + AllTrim(STR(nAtGMX)) + ", " + AllTrim(STR(nTgTISS)) + "]" + " .And. aVet[" + AllTrim(STR(nIntINI)) + "]" + " <= " + AllTrim(STR(nValFIN)) + " .And. aVet[" + AllTrim(STR(nIntFIN)) + "]" + " >= " + AllTrim(STR(nValFIN)) 
   EndIf 
   nPosGMX := aScan(oGMX:aCols, &("{| aVet |" + cCondGMX + "}")) 
   If !(lRet := IIF(nPosGMX == 0, .T., IIF(nPosGMX <> nAtGMX, .F., .T.)))
    cMsgTISS := STR0102//"J· existe este intervalo para este tipo de guia."
   EndIf   
  EndIf 
 Else
  cMsgTISS := STR0103//"Por favor, preencha o tipo de guia." 
 EndIf
 
 If lRet
  oGMX:aCols[oGMX:oBrowse:nAt, nGMXINTPRO] := nValINI 
 EndIf

Return({lRet, cMsgTISS})        


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_GrvRel ∫ Autor ≥ Patricia Queiroz  ∫ Data ≥  02/08/07    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Grava os relacionamentos.                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ FS_GrvHSP18                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/                                         
Static Function FS_GrvRel(cAlias, nOrd, oGREL, cChave, cAliasExc)  

 Local aArea   := GetArea()
 Local nForRel := 1
 Local lAchou  := .T.  
 Local cPref   := cAlias + "->" + PrefixoCpo(cAlias)
 Local aTab    := {"GC6",  "GD8",  "GD9",  "GDA",  "GDF",  "GFV"}  
 For nForRel := 1 To Len(oGREL:aCols)
  nPAcols := nForRel
  DbSelectArea(cAlias)
  DbSetOrder(nOrd) 
  lAchou := DbSeek(xFilial(cAlias) + &cChave)
  If oGREL:aCols[nForRel, Len(oGREL:aCols[nForRel])] .And. lAchou // Exclusao
   If cAlias == "GMX"
    If !FS_VldExcR(cAlias, oGREL, nForRel, cAliasExc) 
     Loop
    EndIf 
   ElseIf cAlias == "GCM"       
    FS_ACOLS()  // gera os acols das tabelas da opcao diferenciados        
  		Private &( "M->GCM_CODPLA") := oGREL:aCols[nForRel, nGcmCodPla]
    Hs_CarVld(,.T.)
    If !FS_VlDlCon(aTab) 
     Loop
    EndIf
    IIF(Len(aCGA4) > 0, FS_Deleta("GA4", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GA4
    IIF(Len(aCGA5) > 0, FS_Deleta("GA5", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GA5
    IIF(Len(aCGA6) > 0, FS_Deleta("GA6", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GA6
    IIF(Len(aCGAC) > 0, FS_Deleta("GAC", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GAC
    IIF(Len(aCGCR) > 0, FS_Deleta("GCR", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GCR
    IIF(Len(aCGC6) > 0, FS_Deleta("GC6", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GC6
    IIF(Len(aCGD8) > 0, FS_Deleta("GD8", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GD8
    IIF(Len(aCGD9) > 0, FS_Deleta("GD9", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GD9
    IIF(Len(aCGDA) > 0, FS_Deleta("GDA", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GDA
    IIF(Len(aCGDF) > 0, FS_Deleta("GDF", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GDF
    IIF(Len(aCGDG) > 0, FS_Deleta("GDG", 1, GA9->GA9_CODCON+oGREL:aCols[nForRel, nGcmCodPla]), Nil)  // Excluir relacionamento GDG 
    IIF(Len(aCGC1) > 0, FS_Deleta("GC1", 1, oGREL:aCols[nForRel, nGcmCodPla]), Nil) // Excluir relacionamento GC1
    IIF(Len(aCGFV) > 0, FS_Deleta("GFV", 1, oGREL:aCols[nForRel, nGcmCodPla]), Nil) // Excluir relacionamento GFV
    IIF(Len(aCGGK) > 0, FS_Deleta("GGK", 1, oGREL:aCols[nForRel, nGcmCodPla]), Nil) // Excluir relacionamento GGK 
    EndIf 
 
    RecLock(cAlias, .F.)
     DbDelete()
    MsUnlock()
  Else
   If !oGREL:aCols[nForRel, Len(oGREL:aCols[nForRel])]
    RecLock(cAlias, !lAchou)
     HS_GRVCPO(cAlias, oGREL:aCols, oGREL:aHeader, nForRel)
     &(cPref + "_FILIAL") := xFilial(cAlias)
     &(cPref + "_CODCON") := M->GA9_CODCON
     If cAlias == "GMX"
      &(cPref + "_SITINT") := "1"
     EndIf
    MsUnlock() 
    ConfirmSx8()                 
   EndIf 
  EndIf 
 Next

 RestArea(aArea)

Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_VldExcR∫ Autor ≥ Patricia Queiroz  ∫ Data ≥  03/08/07    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Valida a exclus„o dos relacionamentos.                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ FS_GrvHSP18                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/                                         
Static Function FS_VldExcR(cAlias, oGREL, nForRel, cAliasExc)
 
 Local aArea  := GetArea()
 Local lRet   := .F.
 Local cSql   := "" 
 Local cCond  := "", cJoin := "", cTabExc := ""       
 
 If cAlias == "GMX"
  If "MSSQL" $ Upper(TCGETDB()) 
   cCond := "GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_CODCON = '" + M->GA9_CODCON + "' AND REPLICATE('0', 12 - LEN(RTRIM(GCZ.GCZ_NRGUIA))) + RTRIM(GCZ.GCZ_NRGUIA) BETWEEN '" + StrZero(oGREL:aCols[nForRel, nGMXINTINI], 12 - Len(AllTrim(oGREL:aCols[nForRel, nGMXINTINI]))) + "' AND '" + StrZero(oGREL:aCols[nForRel, nGMXINTFIN], 12 - Len(AllTrim(oGREL:aCols[nForRel, nGMXINTFIN]))) + "'" 
  ElseIf "ORACLE" $ Upper(TCGETDB()) 
   cCond := "GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_CODCON = '" + M->GA9_CODCON + "' AND LPAD(TRIM(GCZ.GCZ_NRGUIA), 20, '0') BETWEEN '" + StrZero(oGREL:aCols[nForRel, nGMXINTINI], 20 - Len(AllTrim(oGREL:aCols[nForRel, nGMXINTINI]))) + "' AND '" + StrZero(oGREL:aCols[nForRel, nGMXINTFIN], 20 - Len(AllTrim(oGREL:aCols[nForRel, nGMXINTFIN]))) + "'" 
  ElseIf "DB2" $ Upper(TCGETDB()) 
   cCond := "GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_CODCON = '" + M->GA9_CODCON + "' AND LEFT('00000000000000000000'||LTRIM(GCZ.GCZ_NRGUIA), 20) BETWEEN '" + StrZero(oGREL:aCols[nForRel, nGMXINTINI], 20 - Len(AllTrim(oGREL:aCols[nForRel, nGMXINTINI]))) + "' AND '" + StrZero(oGREL:aCols[nForRel, nGMXINTFIN], 20 - Len(AllTrim(oGREL:aCols[nForRel, nGMXINTFIN]))) + "'" 
  EndIf
  cJoin  := "JOIN " + RetSqlName("GCU") + " GCU ON GCU.GCU_FILIAL = '" + xFilial("GCU") + "' AND GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TGTISS = '" + oGREL:aCols[nForRel, nGMXTGTISS] + "' " 
 EndIf 
 
 DbSelectArea("SX2")
 DbSetOrder(1) // X2_CHAVE
 DbSeek(cAliasExc)   
 cTabExc := X2Nome()

 cSql := "SELECT COUNT(*) NCOUNT "
 cSql += "FROM " + RetSqlName(cAliasExc) + " " + cAliasExc + " "
 cSql += IIF(!Empty(cJoin), cJoin, "")
 cSql += "WHERE " + PrefixoCpo(cAliasExc) + "_FILIAL = '" + xFilial(cAliasExc) + "' AND " + cAliasExc + ".D_E_L_E_T_ <> '*' "
 cSql += IIf(!Empty(cCond), "AND " + cCond, "")
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRYREG"
 
 DbSelectArea("QRYREG")
 DbGoTop()

 If !(lRet := QRYREG->NCOUNT == 0)
  HS_MsgInf(STR0104 + cTabExc + ".", STR0009 , STR0069)//"N„o È possÌvel excluir este registro, pois possui relacionamento com [####]"###"AtenÁ„o"###"ValidaÁ„o Exclus„o"
 EndIf
 
 DbCloseArea() 
 RestArea(aArea)

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ MenuDef  ≥ Autor ≥ Tiago Bandeira        ≥ Data ≥ 06/06/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ DefiniÁ„o do aRotina (Menu funcional)                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ MenuDef()                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MenuDef()
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define Array contendo as Rotinas a executar do programa      ≥
//≥ ----------- Elementos contidos por dimensao ------------     ≥
//≥ 1. Nome a aparecer no cabecalho                              ≥
//≥ 2. Nome da Rotina associada                                  ≥
//≥ 3. Usado pela rotina                                         ≥
//≥ 4. Tipo de TransaáÑo a ser efetuada                          ≥
//≥    1 - Pesquisa e Posiciona em um Banco de Dados             ≥
//≥    2 - Simplesmente Mostra os Campos                         ≥
//≥    3 - Gera arquivo TXT para exportacao                      ≥
//≥    4 - Recebe arquivo TXT                                    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Local cMVNivel := GETMV("MV_NIVEUSU",, 0)
Local aRotina :=	{	{OemtoAnsi(STR0001), "axPesqui" , 0, 1, 0, nil}, ;    //"Pesquisar"
                   {OemtoAnsi(STR0002), "HS_MNTA18", 0, 2, 0, nil}, ;    //"Visualizar"
		            	    {OemtoAnsi(STR0003), "HS_MNTA18", 0, 3, 0, nil}, ;    //"Incluir"
		            	    {OemtoAnsi(STR0004), "HS_MNTA18", 0, 4, 0, nil}, ;    //"Alterar"
		                	{OemtoAnsi(STR0005), "HS_MNTA18", 0, 5, 0, nil}, ;    //"Excluir"  
						             {OemtoAnsi(STR0014), "HS_DIFA18", 0, IIF(!Empty(cMVNivel), IIF(cNivel >= cMVNivel, 4, 2), 4), 0, nil}}  	//"Diferenciados"
Return(aRotina)



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_TpOrig ∫ Autor ≥ Heimdall Bergamin  ∫ Data ≥  18/10/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao utilizada para tratar a descricao do campo combo.   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar 																					             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_TpOrig()

Local cDescri := ""

cDescri := "0=Mat/Med;1=Proc.;2=Tas/Dia;3=Mat/Med Esp.;4=Proc.Esp.;5=Urgencia;6=Grupo AMB;7=Grupo AMB Urg.;" 
cDescri += "8=Urgencia Sector;9=Proc.Esp/Grup;A=Tax Serv de Material;B=Tax Serv de Grupo de Material;C=Tax Serv de Taxa/Diaria;D=Tax Serv de Categoria de Taxa/Diaria"
 
Return(cDescri)          

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_SepPla ∫ Autor ≥ Mario Arizono      ∫ Data ≥  23/11/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao utilizada para separar e validar planos informados. ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar 																					             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function HS_SepPla(cPlanos, cCodCon, oObj, nLstCpo, lVldCols)
 
 Local nPos    := 0, nPosDup := 0
 Local cErrPla := ""
 Local lRet    := .T.
 Local aPlanos := {}
 
 Default cPlanos  := ""
 Default cCodCon  := ""
 Default lVldCols := .F.
  
 While (nPos := AT("/", cPlanos)) > 0 
  
  If !lVldCols
		 If HS_CountTB("GCM", "GCM_CODCON = '" + cCodCon + "' AND GCM_CODPLA = '" + Substr(cPlanos, 1,nPos - 1) + "'")  == 0
    cErrPla += Substr(cPlanos, 1,nPos - 1) + "/"
    lRet := .F.
   EndIf
  Else
   nPosDup := (aScan(oObj:aCols, {| aVet | Substr(cPlanos, 1,nPos - 1) $ aVet[nLstCpo] })) 
   If nPosDup > 0 .And. nPosDup <> oObj:oBrowse:nAt
    cErrPla += Substr(cPlanos, 1,nPos - 1) + "/"
    lRet := .F.
   EndIf 
  EndIf

 	aADD(aPlanos, Substr(cPlanos, 1,nPos - 1))
 	
  cPlanos := Substr(cPlanos, nPos + 1)
 
 End
 
 If !Empty(cPlanos)
  If !lVldCols
   If HS_CountTB("GCM", "GCM_CODCON = '" + cCodCon + "' AND GCM_CODPLA = '" + RTrim(cPlanos) + "'")  == 0
    cErrPla += cPlanos
    lRet := .F.
   EndIf 
  Else 
   nPosDup := (aScan(oObj:aCols, {| aVet | RTrim(cPlanos) $ aVet[nLstCpo] })) 
   If nPosDup > 0 .And. nPosDup <> oObj:oBrowse:nAt
    cErrPla += cPlanos 
    lRet := .F.
   EndIf 
  EndIf
  
  aADD(aPlanos, RTrim(cPlanos))
  
 EndIf

Return({lRet, cErrPla, aPlanos})
                

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  |FS_VlDlCon∫ Autor ≥ Bruno Santos       ∫ Data ≥  07/01/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao utilizada para validar a exclus„o do convÍnio.      ∫±±
±±∫          ≥ e do Plano.                                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar 																					             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_VlDlCon(aTab)
Local aArea := getArea()
Local nForCols := 0   
Local nFor    := 0    
Default aTab    := {"GC6",  "GD8",  "GD9",  "GDA",  "GDF",  "GFV",  "GCM", "GA9"}        
          
Private nAt   := 0        
 
 For nFor := 1 to Len(aTab)    
  If aTab[nFor] # "GA9"
   For nForCols := 1 to Len(&("aC"+aTab[nFor]))
    nAt := nForCols     
    If !FS_VldDel(&("aVldDel"+aTab[nFor]))  
     RestArea(aArea)
     return(.F.)
    EndIf
   Next nForCols
  Else
   If !FS_VldDel(&("aVldDel"+aTab[nFor]))  
    RestArea(aArea)
    return(.F.)
   EndIf
  EndIf 
 Next nFor         

 RestArea(aArea)
Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  |Hs_CarVld ∫ Autor ≥ Bruno Santos       ∫ Data ≥  07/01/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Carrega vetores para validaÁ„o da exclus„o do Plano, do    ∫±±
±±∫          ≥ ConvÍnio e dos itens do diferenciados                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar 																					             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function Hs_CarVld(lExclConv, lExclPlano)
 Local cMsgG7  := STR0117+ STR0118 //" Registro n„o pode ser excluido, pois h· referÍncia a esse registro "###"nas despesas de procedimento da conta do paciente"
 Local cMsgG6  := STR0117+ STR0119 //" Registro n„o pode ser excluido, pois h· referÍncia a esse registro "###"nas despesas de taxas\diarias da conta do paciente"
 Local cMsgG5  := STR0117+ STR0120 //" Registro n„o pode ser excluido, pois h· referÍncia a esse registro "###"nas despesas de mat\med da conta do paciente"
 Local cMsgGD4 := STR0117+ STR0121 //" Registro n„o pode ser excluido, pois h· referÍncia a esse registro "###"nos planos utilizados pelos pacientes."

 Default lExclConv  := .F.              
 Default lExclPlano := .F.              
 
 If !(oGC6 == Nil)
  aVldDelGC6 := {{"GD7", IIF(oGC6 # nil,"oGC6:aCols", "aCGC6"), IIF(oGC6 # nil,"oGC6:nAt","nAt"),'"GD7_TABELA  = "+' + Fs_AspasCp(IIF(oGC6 # nil,"oGC6:aCols[oGC6:nAt ", "aCGC6[nAt ") +", nGC6TABPRO]"), cMsgG7, nGC6ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGC6 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGC6[nAt,nGC6CODPLA]")}}},Len(oGC6:aHeader) },; 
                {"GE7", IIF(oGC6 # nil,"oGC6:aCols", "aCGC6"), IIF(oGC6 # nil,"oGC6:nAt","nAt"),'"GE7_TABELA  = "+' + Fs_AspasCp(IIF(oGC6 # nil,"oGC6:aCols[oGC6:nAt ", "aCGC6[nAt ") +", nGC6TABPRO]"), cMsgG7, nGC6ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGC6 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGC6[nAt,nGC6CODPLA]")}}},Len(oGC6:aHeader) },;
                {"GG7", IIF(oGC6 # nil,"oGC6:aCols", "aCGC6"), IIF(oGC6 # nil,"oGC6:nAt","nAt"),'"GG7_TABELA  = "+' + Fs_AspasCp(IIF(oGC6 # nil,"oGC6:aCols[oGC6:nAt ", "aCGC6[nAt ") +", nGC6TABPRO]"), cMsgG7, nGC6ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGC6 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGC6[nAt,nGC6CODPLA]")}}},Len(oGC6:aHeader) }}
 EndIf
 
 If !(oGD8 == Nil) 
  aVldDelGD8 := {{"GD6", IIF(oGD8 # nil,"oGD8:aCols", "aCGD8"), IIF(oGD8 # nil,"oGD8:nAt","nAt"),'"GD6_TABELA  = "+' + Fs_AspasCp(IIF(oGD8 # nil,"oGD8:aCols[oGD8:nAt ", "aCGD8[nAt ") +", nGD8CODTXD]"), cMsgG6, nGD8ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGD8 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGD8[nAt,nGD8CODPLA]")}}},Len(oGD8:aHeader) },; 
                {"GE6", IIF(oGD8 # nil,"oGD8:aCols", "aCGD8"), IIF(oGD8 # nil,"oGD8:nAt","nAt"),'"GE6_TABELA  = "+' + Fs_AspasCp(IIF(oGD8 # nil,"oGD8:aCols[oGD8:nAt ", "aCGD8[nAt ") +", nGD8CODTXD]"), cMsgG6, nGD8ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGD8 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGD8[nAt,nGD8CODPLA]")}}},Len(oGD8:aHeader) },;
                {"GG6", IIF(oGD8 # nil,"oGD8:aCols", "aCGD8"), IIF(oGD8 # nil,"oGD8:nAt","nAt"),'"GG6_TABELA  = "+' + Fs_AspasCp(IIF(oGD8 # nil,"oGD8:aCols[oGD8:nAt ", "aCGD8[nAt ") +", nGD8CODTXD]"), cMsgG6, nGD8ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGD8 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGD8[nAt,nGD8CODPLA]")}}},Len(oGD8:aHeader) }}
 EndIf                 
 
 If !(oGD9 == Nil)                                                                         
  aVldDelGD9 := {{"GD5", IIF(oGD9 # nil,"oGD9:aCols", "aCGD9"), IIF(oGD9 # nil,"oGD9:nAt","nAt"),'"GD5_TABELA  = "+' + Fs_AspasCp(IIF(oGD9 # nil,"oGD9:aCols[oGD9:nAt ", "aCGD9[nAt ") +", nGD9CODMAT]"), cMsgG5, nGD9ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGD9 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGD9[nAt,nGD9CODPLA]")}}},Len(oGD9:aHeader) },; 
                {"GE5", IIF(oGD9 # nil,"oGD9:aCols", "aCGD9"), IIF(oGD9 # nil,"oGD9:nAt","nAt"),'"GE5_TABELA  = "+' + Fs_AspasCp(IIF(oGD9 # nil,"oGD9:aCols[oGD9:nAt ", "aCGD9[nAt ") +", nGD9CODMAT]"), cMsgG5, nGD9ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGD9 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGD9[nAt,nGD9CODPLA]")}}},Len(oGD9:aHeader) },;
                {"GG5", IIF(oGD9 # nil,"oGD9:aCols", "aCGD9"), IIF(oGD9 # nil,"oGD9:nAt","nAt"),'"GG5_TABELA  = "+' + Fs_AspasCp(IIF(oGD9 # nil,"oGD9:aCols[oGD9:nAt ", "aCGD9[nAt ") +", nGD9CODMAT]"), cMsgG5, nGD9ITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGD9 # nil .Or. lExclPlano,'GCM_CODPLA',"aCGD9[nAt,nGD9CODPLA]")}}},Len(oGD9:aHeader) }}
 EndIf
 
 If !(oGDA == Nil) 
  aVldDelGDA := {{"GD5", IIF(oGDA # nil,"oGDA:aCols", "aCGDA"), IIF(oGDA # nil,"oGDA:nAt","nAt"),'"GD5_TABELA  = "+' + Fs_AspasCp(IIF(oGDA # nil,"oGDA:aCols[oGDA:nAt ", "aCGDA[nAt ") +", nGDACODMED]"), cMsgG5, nGDAITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGDA # nil .Or. lExclPlano,'GCM_CODPLA',"aCGDA[nAt,nGDACODPLA]")}}},Len(oGDA:aHeader) },; 
                {"GE5", IIF(oGDA # nil,"oGDA:aCols", "aCGDA"), IIF(oGDA # nil,"oGDA:nAt","nAt"),'"GE5_TABELA  = "+' + Fs_AspasCp(IIF(oGDA # nil,"oGDA:aCols[oGDA:nAt ", "aCGDA[nAt ") +", nGDACODMED]"), cMsgG5, nGDAITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGDA # nil .Or. lExclPlano,'GCM_CODPLA',"aCGDA[nAt,nGDACODPLA]")}}},Len(oGDA:aHeader) },;
                {"GG5", IIF(oGDA # nil,"oGDA:aCols", "aCGDA"), IIF(oGDA # nil,"oGDA:nAt","nAt"),'"GG5_TABELA  = "+' + Fs_AspasCp(IIF(oGDA # nil,"oGDA:aCols[oGDA:nAt ", "aCGDA[nAt ") +", nGDACODMED]"), cMsgG5, nGDAITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGDA # nil .Or. lExclPlano,'GCM_CODPLA',"aCGDA[nAt,nGDACODPLA]")}}},Len(oGDA:aHeader) }}
 EndIf
 
 If !(oGDF == Nil)                                                                              
  aVldDelGDF := {{"GD5",IIF(oGDF # nil,"oGDF:aCols", "aCGDF"), IIF(oGDF # nil,"oGDF:nAt","nAt"),'"GD5_TABELA  = "+' + Fs_AspasCp(IIF(oGDF # nil,"oGDF:aCols[oGDF:nAt ", "aCGDF[nAt ") +", nGDFCODRES]"), cMsgG5, nGDFITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGDF # nil .Or. lExclPlano,'GCM_CODPLA',"aCGDF[nAt,nGDFCODPLA]")}}},Len(oGDF:aHeader) },; 
                {"GE5",IIF(oGDF # nil,"oGDF:aCols", "aCGDF"), IIF(oGDF # nil,"oGDF:nAt","nAt"),'"GE5_TABELA  = "+' + Fs_AspasCp(IIF(oGDF # nil,"oGDF:aCols[oGDF:nAt ", "aCGDF[nAt ") +", nGDFCODRES]"), cMsgG5, nGDFITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGDF # nil .Or. lExclPlano,'GCM_CODPLA',"aCGDF[nAt,nGDFCODPLA]")}}},Len(oGDF:aHeader) },;
                {"GG5",IIF(oGDF # nil,"oGDF:aCols", "aCGDF"), IIF(oGDF # nil,"oGDF:nAt","nAt"),'"GG5_TABELA  = "+' + Fs_AspasCp(IIF(oGDF # nil,"oGDF:aCols[oGDF:nAt ", "aCGDF[nAt ") +", nGDFCODRES]"), cMsgG5, nGDFITEPLA, {{"GCZ",{"GCZ_CODPLA"},{IIF(oGDF # nil .Or. lExclPlano,'GCM_CODPLA',"aCGDF[nAt,nGDFCODPLA]")}}},Len(oGDF:aHeader) }}
 EndIf
 
 If !(oGFV == Nil)                																																																						
  aVldDelGFV := {{"GD4", IIF(oGFV # nil,"oGFV:aCols", "aCGFV"), IIF(oGFV # nil,"oGFV:nAt","nAt"),'"GD4_CODPLA  = "+' + Fs_AspasCp(IIF(oGFV # nil .Or. lExclPlano,"GCM->GCM_CODPLA", "aCGFV[nAt,nGFVCODPLA]")) + '+" AND GD4_SQCATP = "+' + Fs_AspasCp(IIF(oGFV # nil,"oGFV:aCols[oGFV:nAt ", "aCGFV[nAt ") +", nGFVITEPLA]"), cMsgGD4, nGFVITEPLA,,Len(oGFV:aHeader)}}
 EndIf

 If (oGCM # nil) .And. Type("oGCM") == "O"                                                                                 
  aVldDelGCM := {{"GD4", "oGCM:aCols",IIF(!lExclConv,"oGCM:nAt","nAt"),'"GD4_CODPLA  = "+' + Fs_AspasCp(IIF(!lExclConv,"oGCM:aCols[oGCM:nAt ", "oGCM:aCols[nAt ") +", nGcmCodPla]") , cMsgGD4, nGcmCodPla,,nUGCM},;
                 {"GCZ", "oGCM:aCols",IIF(!lExclConv,"oGCM:nAt","nAt"),'"GCZ_CODPLA  = "+' + Fs_AspasCp(IIF(!lExclConv,"oGCM:aCols[oGCM:nAt ", "oGCM:aCols[nAt ") +", nGcmCodPla]") , STR0117+STR0122, nGcmCodPla,,nUGCM} }//" Registro n„o pode ser excluido, pois h· referÍncia a esse registro "###"nas guias de atendimento."   
 EndIf
 
 If lExclConv
  aVldDelGa9 := {{"SE1", nil,"nAt",'"E1_CLIENTE  = "+' + Fs_AspasCp("M->GA9_CODCLI") + '+" AND E1_LOJA = "+' + Fs_AspasCp("M->GA9_LOJA"), cMsgGD4, nGcmCodPla}}
 EndIf
 
return(nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  |Fs_AspasCp∫ Autor ≥  Bruno Santos       ∫ Data ≥  07/01/08  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao utilizada para retornar String entre aspas para     ∫±±
±±∫          ≥ execuÁ„o da macro                                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar 																					             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Fs_AspasCp(cCampo)
Return('"' + "'"+ '"' +  "+"+cCampo+"+" + '"' +"'" + '"')

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  |FS_VldDel ∫ Autor ≥ Bruno Santos       ∫ Data ≥  07/01/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ FunÁ„o que valida a deleÁ„o de cada item(Plano, Convenio,  ∫±±
±±∫          ≥ itens diferenciados).                                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ aVetVld = { {cAlias,                                       ∫±±
±±∫          ≥              aCols,                                        ∫±±
±±∫          ≥              cCond,                																			     ∫±±
±±∫          ≥              cMsg,                                         ∫±±
±±∫          ≥              nPosIte,               																			    ∫±±
±±∫          ≥              aJoin = { {cAliasJoin,                        ∫±±
±±∫          ≥                        {aCampos},    																			   ∫±±
±±∫          ≥                        {aCpValJoin},   																			 ∫±±
±±∫          ≥                         lLeftJoin}                         ∫±±
±±∫          ≥                       },   																			             ∫±±
±±∫          ≥              nDelete }                 																			 ∫±±
±±∫          ≥            }               																			             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar 																					             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VldDel(aVetVld)
 Local aArea   := getArea()
 Local lRet    := .T.        
 Local cAlias  := "", cCond := "", cMsg := ""
 Local aCols   := {}
 Local nPosIte := 0  
 Local nDelete := 0
 Local aJoin   := {}
 Local nLinha  := 0
 Local nI      := 0
 
 For nI := 1 to len(aVetVld)
  cAlias  := aVetVld[nI, 1]
  aCols   := IIF(aVetVld[nI, 2] # nil,&(aVetVld[nI, 2]),nil) 
  nLinha  := &(aVetVld[nI, 3])
  cCond   := aVetVld[nI, 4]
  cMsg    := aVetVld[nI, 5]
  nPosIte := aVetVld[nI, 6]
  aJoin   := IIF(Len(aVetVld[nI]) > 6,aVetVld[nI, 7],{}) 
  nDelete := IIF(Len(aVetVld[nI]) > 7,aVetVld[nI, 8]+1,0) 
  
  If (aCols == nil) .Or. (!aCols[nLinha, nDelete] .And. !Empty(aCols[nLinha, nPosIte]))
   If HS_CountTB(cAlias, &(cCond), aJoin)  > 0
   	HS_MsgInf(cMsg, STR0009, STR0069) //""###"AtenÁ„o!"###"ValidaÁ„o de Exclus„o"
    Return(.F.)
   EndIf                            
  EndIf
  
 Next nI
 RestArea(aArea)
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥AjustaSXB ∫Autor  ≥Microsiga           ∫ Data ≥  11/12/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao criada para ajustar o grupo de perguntas de Layout   ∫±±
±±∫          ≥EDI.                                                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function AjustaSXB()
Local aArea := GetArea()

DbSelectArea("SXB")
DbSetOrder(1)
If SXB->(DbSeek("GG2001501"))

	If !("GG2->" $ SXB->XB_CONTEM)
		RecLock("SXB", .F.)
			SXB->XB_CONTEM := "GG2->" + SXB->XB_CONTEM
		MsUnLock()
	EndIf
EndIf

RestArea(aArea)
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Fs_GerHelp∫Autor  ≥Microsiga           ∫ Data ≥  11/19/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Fs_GerHelp(aCposHelp)

 Local aHelp := {}, aHelpE := {}, aHelpI := {} 
 Local cHelp := ""
 Local nI    := 0
 
 For nI := 1 to Len(aCposHelp) 
  aHelp := aClone(aCposHelp[nI][2])

 	aHelpE := {} 

	 aHelpI := {}

	 cHelp := aCposHelp[nI][1]

	 PutSx1Help("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)
 Next

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_AltCli ∫Autor  ≥Microsiga           ∫ Data ≥  18/10/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao criada para carregar os dados do cliente tanto na    ∫±±
±±∫          ≥consulta padrao quanto na digitacao.                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥SIGAHSP                                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_AltCli()
Local LRet:=.F.
Local bCampo  := {|nCPO| Field(nCPO)}
Local nCnt:=0

DbSelectArea("SX3")
DbSetOrder(2)

If (DbSeek("GA9_CODCLI") .And. SX3->X3_VISUAL == "A" ) .AND. (M->GA9_CODCLI <> SA1->A1_COD) // ALTERAR
	HS_MsgInf(STR0009+" "+STR0128)
	DbSelectArea("SA1")
	DbSetOrder(1) //A1_FILIAL + A1_COD + A1_LOJA
	DbSeek(xFilial("SA1") + M->GA9_CODCLI)
	
	For nCnt := 1 TO FCount()
		M->&(EVAL(bCampo,nCnt)) := FieldGet(nCnt)
	Next
	LRet:=.T.
	
	//Caso o campo loja esteja vazio, ele e carregado com a loja do cadastro de clientes
	If Empty(M->GA9_LOJA)
		M->GA9_LOJA := SA1->A1_LOJA
	EndIf
	
Elseif	(M->GA9_CODCLI = SA1->A1_COD)
	DbSelectArea("SA1")
	DbSetOrder(1) //A1_FILIAL + A1_COD + A1_LOJA
	DbSeek(xFilial("SA1") + SA1->A1_COD)
	
	For nCnt := 1 TO FCount()
		M->&(EVAL(bCampo,nCnt)) := FieldGet(nCnt)
	Next
	LRet:=.T.
	
	//Caso o campo loja esteja vazio, ele e carregado com a loja do cadastro de clientes
	If Empty(M->GA9_LOJA)
		M->GA9_LOJA := SA1->A1_LOJA
	EndIf
	
EndIf

Return(LRet)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  |HS_RCDPROD∫Autor  ≥Rogerio Tabosa      ∫ Data ≥  09/09/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao criada para retornar o campo utilizado como base     ∫±±
±±∫          ≥da tabela de Mat/Med de acordo com a parametrizacao por     ∫±±
±±∫          ≥convenio. caso seja passado os parametros cCodDes e cCodTab ∫±±
±±∫          ≥e retornado tambem o valor desse campo na tabela GCB        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function HS_RCDPROD(cCodCon, cCodDes, cCodTab,cDescXML, nTam,cDescEdi,cDatVig)      
Local aArea := GetArea()
Local cCampo 	:= ""
Local cCpoDes 	:= ""
Local cValCpo 	:= ""
Local cValDesc 	:= ""

Default cCodDes	:= ""
Default cCodTab	:= ""
Default cDescXML:= ""
Default nTam	:= 0
Default cDescEdi:= ""
Default cDatVig := ""

DbSelectArea("GA9")
DbSetorder(1)
If DbSeek(xFilial("GA9") + cCodCon)
	If GA9->GA9_CODPRO == "2"
		cCampo := "GCB_CODPRO" 
		cCpoDes:= "GCB_DESPRO"
	ElseIf GA9->GA9_CODPRO == "1"
		cCampo := "GCB_CODCON"
		cCpoDes:= "GCB_DESCON"		
	ElseIf GA9->GA9_CODPRO == "3"
		cCampo := "GCB_CDTISS"
	Else 
		cCampo := "GCB_PRODUT"				
	EndIf
EndIf

If !Empty(cCodDes) .AND. !Empty(cCodTab) .AND. !Empty(cCampo)
	DbSelectArea("GCB")
	DbSetorder(1) // FILIAL + CODTAB + PRODUT  + DATVIG
	If DbSeek(xFilial("GCB") + cCodTab + cCodDes + cDatVig)
		cValCpo := &("GCB->" + cCampo)
		If !Empty(cCpoDes)  
			cValDesc := &("GCB->" + cCpoDes)
		Else 
			cValDesc := cDescXML
		EndIf
		If nTam > 0 
			cValCpo := IIF (!Empty(cValCpo),PADL(ALLTRIM(cValCpo),nTam,"0"),PADL(ALLTRIM(cCodDes),nTam,"0"))
		EndIf			
		If Empty(cValDesc) 
			cValDesc:= iif(!Empty(cDescXML),cDescXML,cDescEdi)
		EndIf			
	EndIf
EndIf

RestArea(aArea)
Return({cCampo, cValCpo, cValDesc})
