#INCLUDE "HSPAHP37.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP37  º Autor ³ José Orfeu            º Data ³25/02/2004º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao de Titulos do Repasse Médico                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP37()
 Local oDlgPM, nOpcPM := 0
 Local oModPM, cModPM := Space(1), aModPM := {STR0001, STR0002, STR0003} //"0=Médico"###"1=Médico X Convenio"###"2=Médico X Atendimento"
 Local oTipPM, cTipPM := Space(1), aTipPM := {STR0004, STR0005, STR0006} //"0=Só Valorizados"###"1=Não Valorizados"###"2=Ambos"
 Local oCodCrm, cCodCrm := Space(Len(SRA->RA_CODIGO )), oNomMed, cNomMed := Space(Len(SRA->RA_NOME   ))
 Local oCodCon, oNomCon, cNomCon := Space(Len(GA9->GA9_NREDUZ))
 Local oLote  , cLote   := Space(Len(GAD->GAD_NUMLOT))
 Local oRegAte, cRegAte := Space(Len(GAD->GAD_REGATE)), oNomPac, cNomPac := Space(Len(GAD->GAD_NOME  ))
 Local dIniFat := CTod(" "), dFinFat := CTod(" ")
 Local aTotRM := {}, aProcRM := {}
 Local aGerTit := {}, lSai := .F., nCrm := 0, nProc := 0, aTit := {}, nItem := 0
 
 Private cCodConFil := Space(Len(GA9->GA9_CODCON))
 
 Define FONT oFont NAME "Arial" BOLD
 
 While !lSai
  DEFINE MSDIALOG oDlgPM TITLE OemtoAnsi(STR0007) FROM  02, 04 TO 18, 52 OF oMainWnd //"Gera Repasse Medico"
   @ 002, 002 TO 022, 094 LABEL OemtoAnsi(STR0008) OF oDlgPM PIXEL //"Gera Titulos Por"
   @ 007, 004 MSCOMBOBOX oModPM VAR cModPM SIZE 089,50 FONT oFont COLOR CLR_BLACK ITEMS aModPM OF oDlgPM PIXEL
   
   @ 002, 097 TO 022, 189 LABEL OemtoAnsi(STR0009) OF oDlgPM PIXEL //"Repasse"
   @ 007, 099 MSCOMBOBOX oTipPM VAR cTipPM SIZE 089,50 FONT oFont COLOR CLR_BLACK ITEMS aTipPM OF oDlgPM PIXEL
   
   @ 025, 002 TO 105, 189 LABEL OemtoAnsi(STR0010) OF oDlgPM PIXEL //"Parametros"
   
   @ 32, 004 SAY OemtoAnsi(STR0011) COLOR CLR_BLUE OF oDlgPM PIXEL //"CRM Medico"
   @ 30, 040 MsGet oCodCrm Var cCodCrm Valid FS_VldCRM(cCodCrm, @cNomMed) F3 "MED" OF oDlgPM PIXEL COLOR CLR_BLACK
   @ 30, 080 MsGet oNomMed Var cNomMed Size 105, 10 When .F. OF oDlgPM PIXEL COLOR CLR_BLACK
   
   @ 47, 004 SAY OemtoAnsi(STR0012) COLOR CLR_BLUE OF oDlgPM PIXEL  //"Convenio"
   @ 45, 040 MsGet oCodCon Var cCodConFil Valid FS_VldCon(@cNomCon) When cModPM == "1" F3 "GA9" OF oDlgPM PIXEL COLOR CLR_BLACK
   @ 45, 080 MsGet oNomCon Var cNomCon Size 105, 10 When .F. OF oDlgPM PIXEL COLOR CLR_BLACK
    
   @ 62, 004 SAY OemtoAnsi(STR0013) COLOR CLR_BLUE OF oDlgPM PIXEL  //"Data Inicial"
   @ 60, 040 MsGet oDIniFat Var dIniFat OF oDlgPM PIXEL COLOR CLR_BLACK
    
   @ 62, 080 SAY OemtoAnsi(STR0014) COLOR CLR_BLUE OF oDlgPM PIXEL  //"Data Final"
   @ 60, 116 MsGet oDFinFat Var dFinFat OF oDlgPM PIXEL COLOR CLR_BLACK
   
   @ 77, 04 SAY OemtoAnsi("Lote") COLOR CLR_BLUE OF oDlgPM PIXEL
   @ 75, 40 MsGet oLote Var cLote Valid FS_VldLote(cLote) F3 "GAT" When cModPM == "1" OF oDlgPM PIXEL COLOR CLR_BLACK
  
   @ 92, 004 SAY OemtoAnsi(STR0015) COLOR CLR_BLUE OF oDlgPM PIXEL  //"Reg. Atendim."
   @ 90, 040 MsGet oRegAte Var cRegAte Valid FS_VldAte(cRegAte, @cNomPac) F3 "GAD" When cModPM == "2" OF oDlgPM PIXEL COLOR CLR_BLACK
   @ 90, 080 MsGet oNomPac Var cNomPac Size 105, 10 When .F. OF oDlgPM PIXEL COLOR CLR_BLACK
  
   DEFINE SBUTTON FROM 108, 25 TYPE 1 ACTION (nOpcPM := 1, oDlgPM:End()) ENABLE OF oDlgPM
   DEFINE SBUTTON FROM 108, 56 TYPE 2 ACTION (nOpcPM := 0, oDlgPM:End()) ENABLE OF oDlgPM
  ACTIVATE MSDIALOG oDlgPM CENTER
 
  If nOpcPM == 0 // Operação cancelada
   lSai := .T.
   Loop
  EndIf
 
  cModPM  := SubStr(cModPM, 1, 1)
  cTipPM  := SubStr(cTipPM, 1, 1)
  aTotRM  := {}                                                                                         
  aProcRM := {}
   
  Processa({|| FS_BscRep(cModPM, cTipPM, cCodCrm, dIniFat, dFinFat, cLote, cRegAte, @aTotRM, @aProcRM)})
  
  aGerTit := FS_TotPgt(aTotRM, cModPM)
          
  Begin Transaction
   If aGerTit[1]
    For nItem := 1 To Len(aGerTit[2])
     If aGerTit[2][nItem][1]
      If !FS_GTitPag(aGerTit[2][nItem], aGerTit[3], aGerTit[4], cModPM, @aTit)
       DisarmTransaction()
       Exit
      Else          
       If     cModPM == "0" // Por Médico
        nCrm := aScan(aProcRM, {| aVet | aVet[1] == aGerTit[2][nItem][6]})
       ElseIf cModPM == "1" // Por Médico x Convenio
        nCrm := aScan(aProcRM, {| aVet | aVet[1] == aGerTit[2][nItem][6] .And. aVet[2] == SubStr(aGerTit[2][nItem][7], 1, Len(GA9->GA9_CODCON))})
       ElseIf cModPM == "2" // Por Médico x Registro de Atendimento
        nCrm := aScan(aProcRM, {| aVet | aVet[1] == aGerTit[2][nItem][6] .And. aVet[3] == SubStr(aGerTit[2][nItem][8], 1, Len(GAD->GAD_REGATE))})
       EndIf                                                             
       DbSelectArea("GBO")
       DbSetOrder(5)
       For nProc := 1 To Len(aProcRM[nCrm][4])
        If DbSeek(xFilial("GBO") + aProcRM[nCrm][4][nProc][1])
         While !Eof()
          If GBO->GBO_SEQDES == aProcRM[nCrm][4][nProc][1] .And. ;
             GBO->GBO_CODPRO == aProcRM[nCrm][4][nProc][2] .And. ;
             GBO->GBO_REGATE == aProcRM[nCrm][4][nProc][3]
           RecLock("GBO", .F.)
            GBO->GBO_NUMTIT := aTit[1]
            GBO->GBO_PRFTIT := aTit[2]
            GBO->GBO_TITGER := "1"
           MsUnLock()
           Exit
          EndIf
          DbSkip()
         End  
        EndIf 
       Next
      EndIf 
     EndIf 
    Next
   EndIf
  End Transaction
 End 
Return(Nil)

Static Function FS_BscRep(cModPM, cTipPM, cCodCrm, dIniFat, dFinFat, cLote, cRegAte, aTotRM, aProcRM)
 Local nPosCrm := 0, nPgtHsp := 0, nPgtRep := 0, nPgtDir := 0, nTotDes := 0
 Local lAmbUrg := .F., nFUConv := 0, nPRepMed := 0
 Local cMVCodFrx := GetMv("MV_CODFRX")  
 
 DbSelectArea("GBO")
 DbSetOrder(2)
 DbSeek(xFilial("GBO") + DTOS(dIniFat), .T.)
 
 ProcRegua(RecCount())                              
 
 If cModPM # "1"
  cCodConFil := Space(len(GAD->GAD_CODCON))
  cLote      := Space(len(GAD->GAD_NUMLOT))
 Else
  cRegAte    := Space(len(GAD->GAD_REGATE))
 EndIf 
 
 While !Eof() .And. xFilial("GBO") == GBO->GBO_FILIAL .And. IIf(!Empty(dFinFat), GBO->GBO_DATDES <= dFinFat, .T.)
  IncProc(STR0016 + DToC(GBO->GBO_DATDES)) //"Processando honorarios médicos - Data "
  
  If GBO->GBO_GLODES # "0" .Or. Empty(GBO->GBO_CODCRM) .Or. ;
     GBO->GBO_TITGER == "1" .Or. ; //1=Titulo Gerado
     AllTrim(GBO->GBO_CODPRO) == AllTrim(cMVCodFrx) .Or. ; // Filmes não fazem parte dos honorarios médicos
     (!Empty(cCodCrm) .And. GBO->GBO_CODCRM # cCodCrm) .Or. ;
     (!Empty(cRegAte) .And. GBO->GBO_REGATE # cRegAte)
   DbSkip()
   Loop
  EndIf
   
  DbSelectArea("GAD")
  DbSetOrder(1)
  DbSeek(xFilial("GAD") + GBO->GBO_REGATE)
  DbSelectArea("GBO")
  
  If GAD->GAD_TPALTA $ "99" .Or. ;
     (!Empty(cCodConFil) .And. cCodConFil # GAD->GAD_CODCON) .Or. ;
     (!Empty(cLote  )    .And. cLote      # GAD->GAD_NUMLOT)
   DbSkip()
   Loop
  EndIf
  
  nPgtHsp := 0
  nPgtRep := 0
  nPgtDir := 0
  
  DbSelectArea("GA9")
  DbSetorder(1)
  DbSeek(xFilial("GA9") + GAD->GAD_CODCON)
  
  DbSelectArea("GBO")
   
  nTotDes := GBO->GBO_QTDPRO * (GBO->GBO_COEDES * GBO->GBO_VALPRO)
   
  lAmbUrg := .F. 
  
  DbSelectArea("GA7")
  DbSetOrder(1)
  DbSeek(xFilial("GA7") + PadR(AllTrim(GBO->GBO_CODPRO), Len(GA7->GA7_CODPRO)))
  
  If AllTrim(GBO->GBO_CODPRO) # AllTrim(cMVCodFrx)
   If HS_FUrgDes(GAD->GAD_REGATE, @nFUConv, GA7->GA7_TIPPRO, GBO->GBO_CODPRO, GBO->GBO_DATDES, GBO->GBO_HORDES, GBO->GBO_URGDES, GBO->GBO_CODCCU)
    nTotDes := nTotDes * nFUConv // Multiplica pelo fator de Urgencia Médica
    lAmbUrg := .T.
   EndIf
  EndIf
    
  If GA7->GA7_HONORA == "1"
   DbSelectArea("GBJ")
   DbSetOrder(1)
   DbSeek(xFilial("GBJ") + GBO->GBO_CODCRM)
 
   nPRepMed := HS_RCfgRM(GAD->GAD_ATENDI, lAmbUrg, GAD->GAD_CODCON, GAD->GAD_CODPLA, GBJ->GBJ_CRM, GBO->GBO_CODPRO, , GBO->GBO_CODESP)
                                                  
   If GBO->GBO_PGTMED == "1" // Se For Repasse soma no total da conta
    nPgtRep := NoRound(((nTotDes * nPRepMed) / 100), 2)
   Else                                            
    nPgtDir := NoRound(((nTotDes * nPRepMed) / 100), 2)
   EndIf   
   nPgtHsp := nTotDes - IIf(GBO->GBO_PGTMED == "1", nPgtRep, nPgtDir)
     
   //aTotRM[n][1] Total do hospital
   //aTotRM[n][2] Total a repassar ao médico
   //aTotRM[n][3] Total do repasse pago direto pelo convenio 
   //aTotRM[n][4] Nome do Médico
   //aTotRM[n][5] Crm Médico   
   //aTotRM[n][6] Codigo do Convenio
   //aTotRM[n][7] Registro de Atendimento
   If (cTipPM == "0" .And. nPgtRep >  0) .Or. ; // Só valorizados
      (cTipPM == "1" .And. nPgtRep <= 0) .Or. ; // Não Valorizados
      (cTipPM == "2")                           // Ambos
                     
    If nPgtRep > 0                                                     
     If     cModPM == "0" // Por Médico
      nPosCrm := aScan(aProcRM, {| aVet | aVet[1] == GBO->GBO_CODCRM})
     ElseIf cModPM == "1" // Por Médico x Convenio
      nPosCrm := aScan(aProcRM, {| aVet | aVet[1] == GBO->GBO_CODCRM .And. aVet[2] == GAD->GAD_CODCON})
     ElseIf cModPM == "2" // Por Médico x Registro de Atendimento
      nPosCrm := aScan(aProcRM, {| aVet | aVet[1] == GBO->GBO_CODCRM .And. aVet[3] == GAD->GAD_REGATE})
     EndIf                                                             
     If nPosCrm == 0 
      aAdd(aProcRM, {GBO->GBO_CODCRM, GAD->GAD_CODCON, GAD->GAD_REGATE, {}})
      nPosCrm := Len(aProcRM)
     EndIf
     aAdd(aProcRM[nPosCrm][4], {GBO->GBO_SEQDES, GBO->GBO_CODPRO, GBO->GBO_REGATE})
    EndIf
                        
    If     cModPM == "0" // Por Médico
     nPosCrm := aScan(aTotRM, {| aVet | aVet[5] == GBO->GBO_CODCRM})
    ElseIf cModPM == "1" // Por Médico x Convenio
     nPosCrm := aScan(aTotRM, {| aVet | aVet[5] == GBO->GBO_CODCRM .And. aVet[6] == GAD->GAD_CODCON})
    ElseIf cModPM == "2" // Por Médico x Registro de Atendimento
     nPosCrm := aScan(aTotRM, {| aVet | aVet[5] == GBO->GBO_CODCRM .And. aVet[7] == GAD->GAD_REGATE})
    EndIf
      
    If nPosCrm == 0                   
     If     cModPM == "0" // Por Médico
      aAdd(aTotRM, {nPgtHsp, nPgtRep, nPgtDir, Posicione("SRA", 11, xFilial("GAJ") + GBO->GBO_CODCRM, "RA_NOME"), GBO->GBO_CODCRM, Space(Len(GAD->GAD_CODCON)), Space(Len(GAD->GAD_REGATE))})
     ElseIf cModPM == "1" // Por Médico x Convenio                                                                                 
      aAdd(aTotRM, {nPgtHsp, nPgtRep, nPgtDir, Posicione("SRA", 11, xFilial("GAJ") + GBO->GBO_CODCRM, "RA_NOME"), GBO->GBO_CODCRM, GAD->GAD_CODCON, Space(Len(GAD->GAD_REGATE))})
     ElseIf cModPM == "2" // Por Médico x Registro de Atendimento                                                                  
      aAdd(aTotRM, {nPgtHsp, nPgtRep, nPgtDir, Posicione("SRA", 11, xFilial("GAJ") + GBO->GBO_CODCRM, "RA_NOME"), GBO->GBO_CODCRM, Space(Len(GAD->GAD_CODCON)), GAD->GAD_REGATE})
     EndIf 
    Else 
     aTotRM[nPosCrm][1] += nPgtHsp
     aTotRM[nPosCrm][2] += nPgtRep
     aTotRM[nPosCrm][3] += nPgtDir
    EndIf 
   EndIf 
  EndIf 
     
  DbSelectArea("GBO")
  DbSkip()
 End
Return(Nil)

Static Function FS_TotPgt(aTotRM)
 Local bCampo := {|nCPO| Field(nCPO)}, oGetDados, oDlg
 Local nTotHsp := 0, nTotRep := 0, nTotDir := 0
 Local wVar := "", nOpcG := 2, nUsado := 0, nOpcA := 0, nItem := 0
 Local cTitulo := OemToAnsi(STR0017) //"Gera Titulos a Pagar (Médicos)"
 Local cLinOk := "AllwaysTrue()", cTudOk := "AllwaysTrue()", cFieldOk := "AllwaysTrue()"
 Local oLbx, cLbx := " ", aLbx := {}
 Local oTik := LoadBitmap(GetResources(), "LBTIK")
 Local oNo := LoadBitmap(GetResources(), "LBNO")
 Local oVctoTit, dVctoTit := dDataBase, oTipoTit, cTipoTit := Space(Len(SE2->E2_TIPO))
 
 Private aRotina := {{"", '', 0, 1},;    && Pesquisar
                     {"", '', 0, 2},;    && Visualizar
                     {"", '', 0, 3},;    && Incluir
                     {"", '', 0, 4, 2},; && Alterar
                     {"", '', 0, 5, 1} } && Excluir
 
 nTotHsp := 0
 nTotRep := 0
 nTotDir := 0
                   
 If Len(aTotRM) == 0
  aAdd(aLbx, {.F., TransForm(0, "@E 999,999.99"), ;
                   TransForm(0, "@E 999,999.99"), ;
                   TransForm(0, "@E 999,999.99"), ;
                   Space(Len(SRA->RA_NOME)), ;
                   Space(Len(GBJ->GBJ_CRM)), ;
                   Space(Len(GA9->GA9_CODCON)) + "-" + Space(Len(GA9->GA9_NREDUZ)), ;
                   Space(Len(GAD->GAD_REGATE)) + "-" + Space(Len(GAD->GAD_NOME  ))})
 Else                    
  For nItem := 1 To Len(aTotRM)   
   aAdd(aLbx, {.F., TransForm(aTotRM[nItem][1], "@E 999,999.99"), ;
                    TransForm(aTotRM[nItem][2], "@E 999,999.99"), ;
                    TransForm(aTotRM[nItem][3], "@E 999,999.99"), ;
                    aTotRM[nItem][4], ;
                    aTotRM[nItem][5], ;
                    aTotRM[nItem, 6] + "-" + IIf(!Empty(aTotRM[nItem, 6]), Posicione("GA9", 1, xFilial("GA9") + aTotRM[nItem, 6], "GA9_NREDUZ"), Space(Len(GA9->GA9_NREDUZ))), ;
                    aTotRM[nItem, 7] + "-" + IIf(!Empty(aTotRM[nItem, 7]), Posicione("GAD", 1, xFilial("GAD") + aTotRM[nItem, 7], "GAD_NOME"  ), Space(Len(GAD->GAD_NOME  )))})
   nTotHsp += aTotRM[nItem][1]
   nTotRep += aTotRM[nItem][2]
   nTotDir += aTotRM[nItem][3]
  Next
  aSort(aLbx,,, {|X, Y| X[5] < Y[5]}) 
 EndIf 
  
 DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 38,80	of oMainWnd
  @ 013, 001 LISTBOX oLbx ;
             VAR cLbx ;
             FIELDS HEADER " ", STR0018, STR0009, STR0019, STR0020, STR0021, STR0012, STR0022 ; //"Hospital"###"Repasse"###"Direto"###"Médico"###"CRM"###"Convenio"###"Atendimento"
             SIZE 316, 180 ;
             FONT oFont ;
             OF oDlg PIXEL ;
             ON DBLCLICK(FS_Marc(oLbx, aLbx))

  oLbx:SetArray(aLbx)
  oLbx:bLine:= {||{IIf(!aLbx[oLbx:nAt, 1], oNo, oTik), aLbx[oLbx:nAt, 2], aLbx[oLbx:nAt, 3], aLbx[oLbx:nAt, 4], aLbx[oLbx:nAt, 5], aLbx[oLbx:nAt, 6], aLbx[oLbx:nAt, 7], aLbx[oLbx:nAt, 8]}}
  
  @ 209, 005 Say STR0023 + TransForm(nTotHsp, "@E 999,999.99") + ; //"Totais - Hospital = "
                       STR0024 + TransForm(nTotRep, "@E 999,999.99") + ; //"    Repasse = "
                        STR0025 + TransForm(nTotDir, "@E 999,999.99") OF oDlg PIXEL COLOR CLR_BLUE FONT oFont //"    Direto = "
                 
  @ 209, 193 Say STR0026 OF oDlg PIXEL COLOR CLR_BLUE FONT oFont //"Vencimento"
  @ 207, 228 MsGet oVctoTit Var dVctoTit OF oDlg PIXEL COLOR CLR_BLACK
  
  @ 209, 273 Say STR0027 OF oDlg PIXEL COLOR CLR_BLUE FONT oFont //"Tipo"
  @ 207, 287 MsGet oTipoTit Var cTipoTit F3 "05" OF oDlg PIXEL COLOR CLR_BLACK  
  
  oMarcaT := tButton():New(195,05,"Marca/Desmarca todos",oDlg,{|| FS_Mtodos(oLbx,aLbx)},65,10,,,,.T.) 
  
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(FS_VldRep(dVctoTit, cTipoTit, aLbx), oDlg:End(), .F.)}, {|| nOpcA := 0, oDlg:End()})
Return({IIf(nOpcA == 1, .T., .F.), aLbx, dVctoTit, cTipoTit})                             

Static Function FS_VldRep(dVctoTit, cTipoTit, aLbx)
 Local lRet := .T.
 
 If Empty(cTipoTit)
  HS_MsgInf(STR0034, STR0033, STR0007) //"Tipo do titulo é campo obrigatório" ###"Atenção"###"Gera Repasse Medico"
  lRet := .F.
 ElseIf Empty(dVctoTit)
  HS_MsgInf(STR0035, STR0033, STR0007) //"Data de vencimento do titulo é campo obrigatório"###"Atenção"###"Gera Repasse Medico"
  lRet := .F.                                     
 ElseIf dVctoTit < dDataBase
  HS_MsgInf(STR0036, STR0033, STR0007) //"Data de vencimento menor que a data base do sistema"###"Atenção"###"Gera Repasse Medico"
  lRet := .F.                                      
 ElseIf aScan(aLbx, {| aVet | aVet[1]}) == 0
  HS_MsgInf(STR0037, STR0033, STR0007) //"Nenhum médico foi selecionado"###"Atenção"###"Gera Repasse Medico"
  lRet := .F.
 EndIf 
Return(lRet)

Static Function FS_VldCon(cNomCon)
 Local lRet := .T., cAliasOld := Alias(), aArea := HS_SavArea({{"GA9", 0, 0}})
 
 If Empty(AllTrim(cCodConFil))               
  cNomCon := PadR(STR0028, Len(GA9->GA9_NREDUZ)) //"Todos"
  Return(.T.)
 EndIf 
                        
 DbSelectArea("GA9")
 DbSetOrder(1)
 lRet := DbSeek(xFilial("GA9") + cCodConFil)
 
 If lRet
  cNomCon := GA9->GA9_NREDUZ
 Else                       
  cNomCon := PadR(STR0029, Len(GA9->GA9_NREDUZ)) //"Código do Convenio não encontrado"
 EndIf
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(lRet)

Static Function FS_VldCRM(cCodCrm, cNomMed)
 Local lRet := .T., cAliasOld := Alias(), aArea := HS_SavArea({{"SRA", 0, 0}})
 
 If Empty(AllTrim(cCodCrm))
  cNomMed := PadR(STR0028, Len(SRA->RA_NOME)) //"Todos"
  Return(.T.)
 EndIf
                        
 DbSelectArea("SRA")
 DbSetOrder(11)
 lRet := DbSeek(xFilial("SRA") + cCodCrm)
      
 If lRet
  cNomMed := SRA->RA_NOME
 Else                       
  cNomMed := PadR(STR0030, Len(SRA->RA_NOME)) //"CRM do Médico não encontrado"
 EndIf
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(lRet)

Static Function FS_VldAte(cRegAte, cNomPac)
 Local lRet := .T., cAliasOld := Alias(), aArea := HS_SavArea({{"GAD", 0, 0}})
 
 If Empty(AllTrim(cRegAte))
  cNomPac := PadR(STR0028, Len(GAD->GAD_NOME)) //"Todos"
  Return(.T.)
 EndIf
                        
 DbSelectArea("GAD")
 DbSetOrder(1)
 lRet := DbSeek(xFilial("GAD") + cRegAte)
 
 If lRet    
  cNomPac := GAD->GAD_NOME
 Else                       
  cNomPac := PadR(STR0031, Len(GAD->GAD_NOME)) //"Registro de Atendimento não encontrado"
 EndIf
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(lRet)

Static Function FS_GTitPag(aDadosTit, dVctoTit, cTipoTit, cModPM, aTit)
 LOCAL aTitulo := {}, cMV_PrefCPH := AllTrim(&(GetMV("MV_PREFCPH")))
 Local cE2_Num := FS_E2Num(cMV_PrefCPH), aArea := HS_SavArea({{"GBJ", 0, 0}, {"SA2", 0, 0}}), cAliasOld := Alias()
 Local cValTit := aDadosTit[3]
 
 If !HS_GeraFor(aDadosTit[6])
  HS_ResArea(aArea)
  DbSelectArea(cAliasOld)  
  Return(.F.)
 EndIf 
 
 DbSelectArea("GBJ")
 DbSetOrder(1)
 DbSeek(xFilial("GBJ") + aDadosTit[6])
 
 DbSelectArea("SA2")
 DbSetOrder(1)
 DbSeek(xFilial("SA2") + GBJ->GBJ_CODFOR + GBJ->GBJ_LOJA)
 
 DbSelectArea("SE2")          
 
 cValTit := StrTran(cValTit, ".", "")
 cValTit := StrTran(cValTit, ",", ".")
 
 aTitulo := {{"E2_FILIAL" , xFilial("SE2")      , Nil}, ;
             {"E2_PREFIXO", cMV_PrefCPH         , Nil}, ;
             {"E2_NUM"	  , cE2_Num             , Nil}, ;
			 {"E2_PARCELA", "1"                 , Nil}, ;
			 {"E2_TIPO"   , cTipoTit            , Nil}, ;
			 {"E2_NATUREZ", SA2->A2_NATUREZ     , Nil}, ;
			 {"E2_FORNECE", GBJ->GBJ_CODFOR     , Nil}, ;
			 {"E2_LOJA"   , GBJ->GBJ_LOJA       , Nil}, ;
			 {"E2_EMISSAO", dDataBase           , Nil}, ;
			 {"E2_VENCTO" , dVctoTit            , Nil}, ;
			 {"E2_VENCREA", DataValida(dVctoTit), Nil}, ;
			 {"E2_VALOR"  , Val(cValTit)        , Nil}, ;
			 {"E2_VLCRUZ" , Val(cValTit)        , Nil}}
			 
 aTit := {cE2_Num, cMv_PrefCPH}
			  
 PRIVATE lMSHelpAuto := .T. // para nao mostrar os erro na tela
 PRIVATE lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e' que deu erro
					
 MSExecAuto({|x,z,y| FINA050(x,z,y)}, aTitulo,, 3)
 
 If lMSErroAuto
  MostraErro()
 EndIf
  
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(!lMSErroAuto)

Function HS_GeraFor(cCodCrm)
 LOCAL aFornec := {}, cAliasOld := Alias(), nOpc := 3, cCodFor := "", cLoja := ""
 Local aArea := HS_SavArea({{"SRA", 0, 0}, {"GBJ", 0, 0}, {"SA2", 0, 0}})
 
 PRIVATE lMSHelpAuto := .T. // para nao mostrar os erro na tela
 PRIVATE lMSErroAuto := .F. // inicializa como falso, se voltar verdadeiro e' que deu erro
              
 DbSelectArea("GBJ")
 DbSetOrder(1)
 DbSeek(xFilial("GBJ") + cCodCrm)
 
 DbSelectArea("SRA")
 DbSetOrder(11)
 DbSeek(xFilial("SRA") + cCodCrm)
 
 DbSelectArea("SA2")
 DbSetOrder(1)
 
 If !Empty(GBJ->GBJ_CODFOR)
  DbSeek(xFilial("SA2") + GBJ->GBJ_CODFOR + GBJ->GBJ_LOJA)
  If Found()
   If !Empty(SA2->A2_NATUREZ)
    HS_ResArea(aArea)
    DbSelectArea(cAliasOld)
    Return(.T.)
   Else
    nOpc := 4 
   EndIf 
  Else 
   nOpc := 3
  EndIf
  cCodFor := GBJ->GBJ_CODFOR
  cLoja   := GBJ->GBJ_LOJA
 Else
  cCodFor := GetSxeNum("SA2", "A2_COD",, 1)
  cLoja   := "01"
 EndIf                                                              
 
 aFornec := {{"A2_FILIAL" , xFilial("SA2")     , Nil}, ;
             {"A2_COD"    , cCodFor            , Nil}, ;
             {"A2_LOJA"   , cLoja              , Nil}, ;
			 {"A2_NOME"   , SRA->RA_NOME       , Nil}, ;
			 {"A2_NREDUZ" , SRA->RA_NOME       , Nil}, ;      
			 {"A2_END"    , GBJ->GBJ_END       , Nil}, ;
			 {"A2_MUN"    , GBJ->GBJ_MUN       , Nil}, ;      
			 {"A2_EST"    , GBJ->GBJ_EST       , Nil}, ;      
			 {"A2_BAIRRO" , GBJ->GBJ_BAI       , Nil}, ;
			 {"A2_CEP"    , GBJ->GBJ_CEP       , Nil}, ;
			 {"A2_TIPO"   , "F"                , Nil}, ;
			 {"A2_CGC"    , GBJ->GBJ_CIC       , Nil}, ;
			 {"A2_NATUREZ", GetMV("MV_NATFORN"), Nil}, ;
			 {"A2_ID_REPR", "2"                , Nil}}
 					
 MSExecAuto({|x, y| Mata020(x, y)}, aFornec, nOpc)
                          
 If lMSErroAuto
  MostraErro()
  DbSelectArea("SA2")
  RollBackSx8()                    
 Else
  RecLock("GBJ", .F.)
   GBJ->GBJ_CODFOR := cCodFor
   GBJ->GBJ_LOJA   := cLoja
  MsUnLock()
  ConfirmSx8()
 EndIf
  
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(!lMSErroAuto)
              
Static Function FS_Marc(oLbx, aLbx)
 If Val(aLbx[oLbx:nAt, 3]) > 0
  aLbx[oLbx:nAt, 1] := !aLbx[oLbx:nAt, 1]
  oLbx:Refresh()
 Else 
  HS_MsgInf(STR0032, STR0033, STR0007) //"Valor do repasse menor ou igual a zero"###"Atenção"###"Gera Repasse Medico"
 EndIf 
Return(Nil)

Static Function FS_Mtodos(oLbx,aLbx)
 Local nCtaMarca
 For nCtaMarca := 1 to Len(aLbx)
  oLbx:nAt := nCtaMarca
  If Val(aLbx[oLbx:nAt, 3]) > 0
   aLbx[oLbx:nAt, 1] := !aLbx[oLbx:nAt, 1]
  Endif 
 Next
 oLbx:Refresh()
 oLbx:nAt := 1
Return(Nil)   

Static Function FS_E2Num(cMV_PrefCPH)
 Local cE2_Num := Space(Len(SE2->E2_NUM)), cAliasOld := Alias(), aArea := HS_SavArea({{"SE2", 0, 0}})
 Local cNextPref := ""
 
 DbSelectArea("SE2")
 DbSetOrder(1)
 DbSeek(xFilial("SE2") + cMV_PrefCPH)
 If !Found()
  cE2_Num := StrZero(1, Len(SE2->E2_NUM))
 Else
  cNextPref := PadR(Soma1(cMV_PrefCPH, Len(cMV_PrefCPH)), Len(SE2->E2_PREFIXO))
  DbSeek(xFilial("SE2") + cNextPref)
  While !Bof() .And. SE2->E2_PREFIXO # cMV_PrefCPH
   DbSkip(-1)
  End
  cE2_Num := Soma1(SE2->E2_NUM, Len(SE2->E2_NUM))
 EndIf
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(cE2_Num)

Static Function FS_VldLote(cLote)
 Local lRet := .T., cAliasOld := Alias(), aArea := HS_SavArea({{"GAT", 0, 0}})
 
 If Empty(AllTrim(cLote))
  Return(.T.)
 EndIf                            
 
 If Empty(cCodConFil) .And. !Empty(cLote)
  HS_MsgInf(STR0038,STR0033,STR0007) //"Para informar o código do lote é obrigatório informar o convenio antes"###"Atenção"###"Gera Repasse Medico"
  Return(.F.)
 EndIf
                        
 DbSelectArea("GAT")
 DbSetOrder(2)
 lRet := DbSeek(xFilial("GAT") + cCodConFil + cLote)
 
 If !lRet
  HS_MsgInf(STR0039,STR0033,STR0007) //"Lote Invalido"###"Atenção"###"Gera Repasse Medico"
 EndIf
 
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(lRet)