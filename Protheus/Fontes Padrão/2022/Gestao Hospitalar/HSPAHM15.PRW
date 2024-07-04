#INCLUDE "hspahm15.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM15  º Autor ³ José Orfeu         º Data ³  21/04/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Prescricao Eletronica                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM15()                
 Local cFiltro := ""
 Local cIDMaq  := HS_NUMID(2, "C:\") // Retorna o Numero de Serie do Volume do Drive C
 Local cCCuInt := HS_RetCCM(cIdMaq) // Retorna o Centro de Custo que a Maquina esta localizada 
 Local aCores  := {{"GAV->GAV_TIPO=='3'",'BR_VERDE'   }, ;	   
                   {"GAV->GAV_TIPO=='2'",'BR_AMARELO' }, ;	
                   {"GAV->GAV_TIPO=='1'",'BR_AZUL'    }, ;
                   {"GAV->GAV_TIPO=='4'",'BR_VERMELHO'}, ;
                   {"GAV->GAV_TIPO=='0'",'BR_CINZA'   }}
                      
 Private cCadastro := STR0001 //"Prescricao Eletronica"
 Private aMemos    := {{"GBQ_OBSMEM", "GBQ_OBSERV"}}
 Private aRotina   := {{OemtoAnsi(STR0002), "axPesqui"  , 0, 1   }, ; //"Pesquisar"
                       {OemToAnsi(STR0003), 'HSAHM15(2)', 0, 2   }, ; //"Visualizar"
                       {OemToAnsi(STR0004), 'HSAHM15(4)', 0, 4, 2}, ; //"Prescrever"
                       {OemToAnsi(STR0005), 'HS_ImpPE()', 0, 5, 1}  } //"Imprimir"
                     
 DbSelectArea("GAV")
 DbSetOrder(1)      
 cFiltro := "GAV->GAV_REGATE # 'DESATI' .And. GAV->GAV_REGATE # '" + Replicate("Z", Len(GAV->GAV_REGATE)) + "' .And. "

 If !Empty(AllTrim(cCCUInt))
  cFiltro  += "!EMPTY(GAV->GAV_REGATE) .AND. GAV_CODCCU $ '" + cCCuInt + "'"
 Else
  cFiltro  += "!EMPTY(GAV->GAV_REGATE)"
 EndIf 
                                                      
 HS_AtvFilt("GAV", cFiltro)

 mBrowse(006, 001, 022, 075, "GAV",,,,,, aCores)
 
 HS_DtvFilt("GAV")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HSAHM15 ³ Autor ³ José Orfeu          ³ Data ³ 21/04/2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Tratamento da Prescricao Eletronica              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSAHM15(nOpc)
 Local nOpcA := 0, oDlg
 Private aTela := {}, aGets := {}, aHeader := {}, aCols := {}, nUsado := 0
 Private cRegAte := "", cCrmPre := "", oGDGbq
 Private nGbq_OriMMP := 0, nGbq_CodTes := 0, nGbq_CodMMP := 0
 Private nGbq_DesMMP := 0, nGbq_DatPre := 0
 Private cGbq_OriMMP := "0", M->GAI_ALMORI := "", M->GAI_REQUIS := "1", M->GAJ_CODTES := ""
  
 cRegAte := GAV->GAV_REGATE
 
 If !FS_GetCrm()
  Return(.F.)
 EndIf                              
 
 DbSelectArea("GBQ")
          
 HS_BDados("GBQ", @aHeader, @aCols, @nUsado, 1, GAV->GAV_REGATE, "'" + GAV->GAV_REGATE + "' == GBQ->GBQ_REGATE",,,, "GBQ->GBQ_CODCRM # '" + cCrmPre + "'")
 
 DbSelectArea("GAD")
 DbSetOrder(1)
 DbSeek(xFilial("GAD") + cRegAte)
 
 DbSelectArea("GBQ")
 
 nGbq_OriMMP := aScan(aHeader, {| aVet | aVet[2] == "GBQ_ORIMMP"})
 nGbq_DatPre := aScan(aHeader, {| aVet | aVet[2] == "GBQ_DATPRE"})
 nGbq_CodTes := aScan(aHeader, {| aVet | aVet[2] == "GBQ_CODTES"})
 nGbq_CodMMP := aScan(aHeader, {| aVet | aVet[2] == "GBQ_CODMMP"})
 nGbq_DesMMP := aScan(aHeader, {| aVet | aVet[2] == "GBQ_DESMMP"})
 nGbq_Observ := aScan(aHeader, {| aVet | aVet[2] == "GBQ_OBSERV"})

 nOpcA := 0
 DEFINE MSDIALOG oDlg TITLE cCadastro From 009, 000 To 038, 080	Of oMainWnd
  EnChoice("GAD", RecNo(), 2,,,,,{014, 001, 108, 315},, 2,,,, oDlg,, .F.)
  oGDGbq := MsGetDados():New(108, 001, 218, 315, 3,,, "", .T.,,,,, "HS_VldM15()")
  oGDGbq:oBrowse:bChange := {|| HS_F3M15()}
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGDGbq:TudoOk(), oDlg:End(), nOpcA := 0)}, ;
                                                           {|| nOpcA := 0, oDlg:End()})
                                                                
 If nOpcA == 1 .And. nOpc # 2
  GrvHsM15()
 EndIf
Return(Nil)

//////////////////////////
Static Function GrvHsm15()      
 Local nCol := 0, lAchou := .F., nCHead := 0, cCampo := ""

 For nCol := 1 to len(aCols)
  DbSelectArea("GBQ")
  lAchou := DbSeek(xFilial("GBQ") + cRegAte + Dtos(aCols[nCol, nGbq_DatPre]) + aCols[nCol, nGbq_OriMMP] + aCols[nCol, nGbq_CodMMP])
  If aCols[nCol, Len(aCols[nCol])] .And. lAchou // exclusao
   RecLock("GBQ", .F., .T.)
   Dbdelete()
   MsUnlock()
   WriteSx2("GBQ")
  Else
   If !aCols[nCol, len(aCols[nCol])]
    RecLock("GBQ", !lAchou)
    For nCHead := 1 To Len(aHeader)
     cCampo := "M->" + aHeader[nCHead, 2]
     &(cCampo) := aCols[nCol, nCHead]
    Next
     
    HS_GRVCPO("GBQ")   
    MsUnLock()
                     
    RecLock("GBQ", .F.)
     GBQ->GBQ_FILIAL := xFilial("GBQ")
     GBQ->GBQ_REGATE := cRegAte
     GBQ->GBQ_CODCRM := cCrmPre
     GBQ->GBQ_NOMMED := Posicione("SRA", 11, xFilial("SRA") + PadR(AllTrim(cCrmPre), Len(SRA->RA_CODIGO)), "RA_NOME")
     GBQ->GBQ_LOGARQ := HS_LogArq()
    MsUnlock()                  
   Endif 
  Endif
 Next   
Return(.T.)         
 
Function HS_F3M15()
 If     !(ReadVar() == "M->GBQ_ORIMMP")
  M->GBQ_ORIMMP := aCols[n][nGbq_OriMMP]
 EndIf  
 
 M->GAJ_CODTES := aCols[n][nGbq_CodTes]
 
 cGbq_OriMMP := IIF(ReadVar() == "M->GBQ_ORIMMP", M->GBQ_ORIMMP, aCols[n][nGbq_OriMMP])
 
 If     cGbq_OriMMP == "0" // Mat/Med
  oGDGbq:aInfo[nGbq_CodMMP][01] := "G1S" //"B1S"
 ElseIf cGbq_OriMMP == "1" // Procedimento/Honorario 
  oGDGbq:aInfo[nGbq_CodMMP][01] := "GA7"
 ElseIf cGbq_OriMMP == "4" // Kits
  oGDGbq:aInfo[nGbq_CodMMP][01] := "GAF"
 EndIf
 
 oGDGbq:oBrowse:Refresh()
Return(.T.)

Function HS_VldM15(cGbq_OriMMP)
 Local lRet := .F., cAliasOld := Alias()
 
 If ReadVar() == "M->GBQ_CODTES"
  M->GAJ_CODTES := M->GBQ_CODTES
  Return(.T.)
 EndIf 
 
 If cGbq_OriMMP == Nil
  Return(.T.)
 EndIf 
 
 If     cGbq_OriMMP == "0"
  DbSelectArea("SB1")
  DbSetOrder(1)
  lRet := DbSeek(xFilial("SB1") + PadR(AllTrim(M->GBQ_CODMMP), Len(SB1->B1_COD)))
  If lRet
   M->GBQ_DESMMP         := SB1->B1_DESC
   aCols[n, nGbq_DesMMP] := SB1->B1_DESC
  EndIf  
 ElseIf cGbq_OriMMP == "1"
  DbSelectArea("GA7")
  DbSetOrder(1)
  lRet := DbSeek(xFilial("GA7") + PadR(AllTrim(M->GBQ_CODMMP), Len(GA7->GA7_CODPRO)))
  If lRet
   M->GBQ_DESMMP         := GA7->GA7_DESC
   aCols[n, nGbq_DesMMP] := GA7->GA7_DESC
  EndIf  
 ElseIf cGbq_OriMMP == "4"
  DbSelectArea("GAF")
  DbSetOrder(1)
  lRet := DbSeek(xFilial("GAF") + PadR(AllTrim(M->GBQ_CODMMP), Len(GAF->GAF_CODKIT)))
  If lRet
   M->GBQ_DESMMP         := GAF->GAF_DESKIT
   aCols[n, nGbq_DesMMP] := GAF->GAF_DESKIT
  EndIf
 EndIf                  
                                    
 If !lRet
  HS_MsgInf(STR0006, STR0007, STR0001) //"Item inválido"###"Atenção" ###"Prescricao Eletronica"
  M->GBQ_DESMMP         := Space(aHeader[nGbq_DesMMP, 4])
  aCols[n, nGbq_DesMMP] := Space(aHeader[nGbq_DesMMP, 4])
 EndIf
  
 DbSelectArea(cAliasOld)
Return(lRet)

Function HS_DesGbq()
 Local cGbq_OriMMP := IIf(Inclui, M->GBQ_ORIMMP, GBQ->GBQ_ORIMMP)
 Local cGbq_CodMMP := IIf(Inclui, M->GBQ_CODMMP, GBQ->GBQ_CODMMP)
 Local cDesGbq := ""
 
 If     cGbq_OriMMP == "0" // Mat / Med
  cDesGbq := Posicione("SB1", 1, xFilial("SB1") + PadR(AllTrim(cGbq_CodMMP), Len(SB1->B1_COD))    , "B1_DESC")
 ElseIf cGbq_OriMMP == "1" // Procedimentos
  cDesGbq := Posicione("GA7", 1, xFilial("GA7") + PadR(AllTrim(cGbq_CodMMP), Len(GA7->GA7_CODPRO)), "GA7_DESC")
 ElseIf cGbq_OriMMP == "4" // Kits
  cDesGbq := Posicione("GAF", 1, xFilial("GAF") + PadR(AllTrim(cGbq_CodMMP), Len(GAF->GAF_CODKIT)), "GAF_DESKIT")
 EndIf
Return(cDesGbq)
    
/////////////////////////////////////////
// Valida Assinatura eletronica do Medico
Function FS_GetCrm()
 Local nOpcSen := 0, oDlgSen
 Local oCrmMed, cCrmMed := Space(Len(GBJ->GBJ_CRM))
 Local oNomMed, cNomMed := Space(Len(SRA->RA_NOME))
 Local oSenMed, cSenMed := Space(Len(GBJ->GBJ_SENMED))
 
 DEFINE MSDIALOG oDlgSen TITLE OemToAnsi(STR0008) From 005, 014 To 011, 076 Of oMainWnd //"Assinatura Eletronica do Medico"
  @ 016, 004 Say OemToAnsi(STR0009) Of oDlgSen PIXEL COLOR CLR_BLUE //"Nro CRM"
  @ 014, 035 MsGet oCrmMed Var cCrmMed Valid FS_VldCrm(cCrmMed, @cNomMed) Of oDlgSen PIXEL COLOR CLR_BLACK
  @ 014, 075 MSGet oNomMed Var cNomMed Size 160, 10 Of oDlgSen PIXEL COLOR CLR_BLACK When .F.
  @ 029, 004 Say OemToAnsi(STR0010) OF oDlgSen PIXEL COLOR CLR_BLUE //"Senha"
  @ 027, 035 MSGet oSenMed var cSenMed PASSWORD Valid FS_VldSen(cCrmMed, cSenMed, oDlgSen, @nOpcSen) Of oDlgSen PIXEL COLOR CLR_BLACK
 ACTIVATE MSDIALOG oDlgSen CENTERED ON INIT EnchoiceBar(oDlgSen, {|| FS_VldSen(cCrmMed, cSenMed, oDlgSen, @nOpcSen)}, ;
                                                                 {|| nOpcSen := 0, oDlgSen:End()})

 If nOpcSen == 0  
  Return(.F.)
 Else
  cCrmPre := cCrmMed
 Endif                    
Return(.T.) 

Static Function FS_VldCrm(cCrmMed, cNomMed)
 Local cAliasOld := Alias(), lRet := .T.

 // Pesquisa no Cadastro de Medicos
 DbSelectArea("SRA")
 DbSetOrder(11)
 lRet := DbSeek(xFilial("SRA") + cCrmMed)
 If !lRet
  HS_MsgInf(STR0011, STR0012, STR0001) //"CRM não encontrado"###"Atenção" ###"Prescricao Eletronica"
 Else
  cNomMed := SRA->RA_NOME
 EndIf
 
 DbSelectArea(cAliasOld)
Return(lRet)

Static Function FS_VldSen(cCrmMed, cSenMed, oDlgSen, nOpcSen)
 Local nChrSen := 0, cChrSen := "", cAliasOld := Alias(), lRet := .T.

 For nChrSen = 1 To Len(Alltrim(cSenMed))
  cChrSen := cChrSen + Chr(Asc(SubStr(cSenMed, nChrSen, 1)) + 92)
 Next          

 // Pesquisa no Cadastro de Medicos
 DbSelectArea("GBJ")
 DbSetOrder(1)
 DbSeek(xFilial("GBJ") + cCrmMed)
 If GBJ->GBJ_SENMED <> cChrSen
  HS_MsgInf(STR0013, STR0012, STR0001) //"Assinatura Eletrônica do Médico não confere!"###"Atenção" ###"Prescricao Eletronica"
  lRet := .F.
  nOpcSen := 0
 Else         
  nOpcSen := 1
  oDlgSen:End() 
 EndIf
 
 DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ImpPE  º Autor ³ Manoel             º Data ³  14/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao da Prescricao Eletronica                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_ImpPE()
 Local i := 0

 m_pag	 := 1
 cTamanho := "P"          // P/M/G
 nCaracter:= 18
 Limite   := 80           // 80/132/220
 aOrdem   := {}           // Ordem do Relatorio
 cTitulo  := STR0001 //"Prescricao Eletronica"
 nLastKey := 0
 aReturn  := {STR0014, 2, STR0015, 1, 4, "LPT1", "", 1} //"Zebrado"###"Administracao"
 cNomProg := "H0SAHM15"
 cNomeRel := "H0SAHM15"
 cDrive   := "Epson.drv"
 cNomeImp := "LPT1"
 cAlias   := "GBQ"
 nlin     := 0

 ValidPerg()                
 If !Pergunte("HSPM15", .T.)
  Return(Nil)
 Endif     

 DbSelectArea("GAD")
 DbSeek(xFilial("GAD") + MV_PAR01)

 DbSelectArea("GBQ")
 DbSeek(xFilial("GBQ") + MV_PAR01 + DToS(MV_PAR02), .T.)

 DbSelectArea("SRA")
 DbSetOrder(11)
 DbSeek(xFilial("SRA") + MV_PAR01)

 cCabec2  := STR0016 + MV_PAR01 + Space(5) + GAD->GAD_NOME //"PACIENTE: "

 cCabec1  := STR0017 + SRA->RA_NOME + STR0018 + GBQ->GBQ_CODCRM //"PRESCRICAO ELETRONICA DE MAT/MED   -    Medico  "###" - C.R.M. "

 LServer := Nil
 cNaoMostra := .f.
 // Parametros da SetPrint
 // 15 cDrive
 // 16 passa .t. p/ nao chamar tela
 // 17 lserver = .t., imprime no servidor
 // 18 LPT1
 
 cNomeRel := SetPrint(cAlias,cNomeRel,nil ,@cTitulo,"","","",.F.,"",.F.,cTamanho,nil    ,nil    ,nil /*,cDRive,cNaoMostra, LServer,cNomeImp*/)

 If nLastKey == 27
  DbClearFilter()
  Return
 Endif
  
 SetDefault(aReturn, cAlias)

 DbSelectArea("GBQ")
 aVetorM := {}
 aVetorP := {}
	
 While GBQ->GBQ_FILIAL == xFilial("GBQ") .And. ;
       GBQ->GBQ_REGATE == MV_PAR01       .And. ;
       GBQ->GBQ_DATPRE >= MV_PAR02       .And. ;
       GBQ->GBQ_DATPRE <= MV_PAR03       .And. ;
       !Eof() 
       
  If GBQ->GBQ_SUSPEN == "1" // Prescricao Suspensa
   DbSkip()
   Loop
  EndIf

  If !Empty(MV_PAR04) .And. GBQ->GBQ_CODCRM <> MV_PAR04
   DbSkip()
   Loop
  EndIf

  cObserv := Criavar("GBQ_OBSERV")
        
  If GBQ->GBQ_ORIMMP $ "04" // Materiais/Medicamentos ou Kit's
   aAdd(aVetorM, {IIf(GBQ->GBQ_ORIMMP == "4", STR0019 + GBQ->GBQ_CODMMP, GBQ->GBQ_CODMMP), Val(GBQ->GBQ_HORINI), GBQ->GBQ_DOSEAP, Val(GBQ->GBQ_INTERV), cObserv}) //"Kit-"
  ElseIf GBQ->GBQ_ORIMMP == "1" // Procedimentos
   aAdd(aVetorP, {GBQ->GBQ_CODMMP, Val(GBQ->GBQ_HORINI), GBQ->GBQ_DOSEAP, Val(GBQ->GBQ_INTERV), cObserv})
  EndIf

  DbSelectArea("GBQ")
  DbSkip()
 End

 Set Printer to &cNomeRel
 Set Printer On
 Set Device  to Printer

 _Passou := .F.

 If Len(aVetorM) > 0
  nLin := 1
  SETPRC(0, 0)
		
  nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter) + 1
  @ nLin++,00 PSAY ""
  nLin := nLin + 1
  @ nLin++,00 PSAY REPLICATE("-",80)
  @ nLin++,00 PSAY STR0020 //"PRODUTO                           U.CONSUMO  HORA INICIO  DOSE U.C. INTERVALO H"
  @ nLin++,00 PSAY REPLICATE("-",80)
	
  For i = 1 to Len(aVetorM)
   If  !Subs(Alltrim(aVetorM[i,1]),1,3) == "Kit"
    DbSelectArea("SB1")
	DbSetOrder(1)
    DbSeek(xFilial("SB1")+Alltrim(aVetorM[i,1]))
	
	DbSelectArea("GBI")
	DBSetOrder(1)
	DbSeek(xFilial("GBI")+Alltrim(aVetorM[i,1]))
			                                                 
	DbSelectArea("SAH")
	DbSeek(xFilial("SAH")+SB1->B1_SEGUM)
   Else    
    HS_SeekRet("GAF","Subs(Alltrim(aVetorM[" + AllTrim(Str(i)) + ",1]),5)",1,.f.)
   Endif   
   
   If nLin == 30
    _passou := .t.
	nLin := nLin + 1 
	@ nLin++,00 PSAY ""
	nLin := 1
	SETPRC(0,0)
	@ nLin++,00 PSAY ""
	@ nLin++,00 PSAY REPLICATE("-",80)
	@ nLin++,00 PSAY STR0020 //"PRODUTO                           U.CONSUMO  HORA INICIO  DOSE U.C. INTERVALO H"
	@ nLin++,00 PSAY REPLICATE("-",80)
   EndIf
   
   If  Subs(Alltrim(aVetorM[i,1]),1,3) == "Kit"
    @ nLin++,00 PSAY GAF->GAF_CODKIT+" "+GAF->GAF_DESKIT+Space(2)+Subs(strzero(aVetorM[i,2],4),1,2)+":"+Subs(strzero(aVetorM[i,2],4),3,2)+Space(5)+TRANSFORM(aVetorM[i,3],"@E 9999")+Space(9)+Subs(strzero(aVetorM[i,4],4),1,2)+":"+Subs(strzero(aVetorM[i,4],4),3,2)
   Else    
    @ nLin++,00 PSAY Subs(SB1->B1_COD,1,5)+" "+Subs(SB1->B1_DESC,1,27)+" "+Subs(SAH->AH_UMRES,1,10)+Space(5)+Subs(strzero(aVetorM[i,2],4),1,2)+":"+Subs(strzero(aVetorM[i,2],4),3,2)+Space(5)+TRANSFORM(aVetorM[i,3],"@E 9999")+Space(9)+Subs(strzero(aVetorM[i,4],4),1,2)+":"+Subs(strzero(aVetorM[i,4],4),3,2)
   EndIf    
   
   If !empty(aVetorM[i,5])
    @ nLin++,00 PSAY STR0021 //"Observacoes: "
	@ nLin++,00 PSAY aVetorM[i,5]
   EndIf   
   nLin := nLin + 1	 
  Next
 EndIf

 If _Passou
  While nLin < 30
   nLin := nLin + 1
  End
  nLin := nLin + 5
  @ nLin++,00 PSAY ""
 Else
  While nLin < 30
   nLin := nLin + 1
  End                        
  nLin := nLin + 3 // +3
  @ nLin++,00 PSAY ""
 EndIf   

 cCabec1  := STR0022 + SRA->RA_NOME + STR0018 + GBQ->GBQ_CODCRM //"PRESCRICAO ELETRONICA DE PROCEDIMENTOS   -   Medico  "###" - C.R.M. "

 If Len(aVetorP) > 0
  Eject
  nLin := 1
  SETPRC(0,0)
  _Passou := .F.
		
  nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter) + 1
  @ nLin++,00 PSAY ""
  nLin := nLin + 1
  @ nLin++,00 PSAY REPLICATE("-",80)
  @ nLin++,00 PSAY STR0023 //"PROCEDIMENTO                                 HORA INICIO  QUANTIDAD INTERVALO H"
  @ nLin++,00 PSAY REPLICATE("-",80)
	
	
  For i = 1 to Len(aVetorP)
   DbSelectArea("GA7")
   DBSetOrder(1)
   DbSeek(xFilial("GA7")+aVetorP[i,1])
   If nLin == 30
    _Passou := .T.
	nLin := nLin + 1 
	@ nLin++,00 PSAY ""
	nLin := 1
	SETPRC(0,0)
	@ nLin++, 00 PSAY ""
	@ nLin++, 00 PSAY REPLICATE("-",80)
	@ nLin++, 00 PSAY STR0023 //"PROCEDIMENTO                                 HORA INICIO  QUANTIDAD INTERVALO H"
    @ nLin++, 00 PSAY REPLICATE("-",80)
   EndIf
   @ nLin++, 00 PSAY GA7->GA7_CODPRO+" "+Subs(GA7->GA7_DESC,1,33)+Space(5)+Subs(strzero(aVetorP[i,2],4),1,2)+":"+Subs(strzero(aVetorP[i,2],4),3,2)+Space(7)+TRANSFORM(aVetorP[i,3],"@E 9999")+Space(7)+Subs(strzero(aVetorP[i,4],4),1,2)+":"+Subs(strzero(aVetorP[i,4],4),3,2)
   If !Empty(aVetorP[i,5])
	@ nLin++,00 PSAY STR0021 //"Observacoes: "
	@ nLin++,00 PSAY aVetorP[i,5]
   EndIf
  Next
 EndIf

 If _Passou
  While nLin < 30
   nLin := nLin + 1
  End                        
  nLin := nLin + 5
  @ nLin++,00 PSAY ""
 Else
  While nLin < 30
   nLin := nLin + 1
  End                        
  nLin := nLin + 3 // +3
  @ nLin++,00 PSAY ""
 EndIf

 Ms_Flush()              
  
 Set Printer to
 Set Device  to Screen

 If aReturn[5] == 1
  OurSpool(cNomeRel)
 EndIf  
Return(Nil)

Static Function ValidPerg()
 Local i := 0, j := 0, _sAlias := Alias(), aRegs := {}

 DbSelectArea("SX1")
 DbSetOrder(1)
 
 aAdd(aRegs, {"HSPM15", "01", STR0024, "", "", "mv_ch1", "C", 6, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "GAD", "N", ""}) //"Atendimento"
 aAdd(aRegs, {"HSPM15", "02", STR0025    , "", "", "mv_ch2", "D", 8, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",    "", "N", ""}) //"Da data"
 aAdd(aRegs, {"HSPM15", "03", STR0026 , "", "", "mv_ch3", "D", 8, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",    "", "N", ""}) //"Ate a data"
 aAdd(aRegs, {"HSPM15", "04", STR0027        , "", "", "mv_ch4", "C", 6, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "MED", "N", ""}) //"Crm"

 cPerg := aRegs[1, 1]
 For i :=1 to Len(aRegs)
  DbSeek(cPerg + aRegs[i, 2])
  If !found()
   RecLock("SX1", .T.)
   For j := 1 to FCount()
   	If j <= Len(aRegs[i])
	 FieldPut(j, aRegs[i, j])
	Endif
   Next
   MsUnlock()		
  EndIf
 Next
 DbSelectArea(_sAlias)
Return(Nil)