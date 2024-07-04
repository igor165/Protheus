#INCLUDE "HSPAHP38.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP38  º Autor ³ José Orfeu         º Data ³  24/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Recebimento de contas particulares                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP38()          
 Local aCor := {{"GAD->GAD_ATERPD == '0' .AND. !EMPTY(GAD->GAD_TPALTA) .AND. !EMPTY(GAD->GAD_DATFEC)", "BR_VERMELHO"}, ; //At. Normal, Conta com Alta e Fechada
                {"GAD->GAD_ATERPD == '0' .AND. !EMPTY(GAD->GAD_TPALTA) .AND.  EMPTY(GAD->GAD_DATFEC)", "BR_AMARELO" }, ; //At. Normal, Conta com Alta e não Fechada
                {"GAD->GAD_ATERPD == '0' .AND.  EMPTY(GAD->GAD_TPALTA) .AND.  EMPTY(GAD->GAD_DATFEC)", "BR_VERDE"   }, ; //At. Normal, Conta Aberta
                {"GAD->GAD_ATERPD == '1' .AND. !EMPTY(GAD->GAD_TPALTA) .AND. !EMPTY(GAD->GAD_DATFEC)", "BR_PRETO"   }, ; //At. Rapido, Conta com Alta e Fechada
                {"GAD->GAD_ATERPD == '1' .AND. !EMPTY(GAD->GAD_TPALTA) .AND.  EMPTY(GAD->GAD_DATFEC)", "BR_MARROM"  }, ; //At. Rapido, Conta com Alta e não Fechada
                {"GAD->GAD_ATERPD == '1' .AND.  EMPTY(GAD->GAD_TPALTA) .AND.  EMPTY(GAD->GAD_DATFEC)", "BR_AZUL"    }}   //At. Rapido, Conta Aberta
                                                           
 Private aRotina := {{OemtoAnsi(STR0001   ), "axPesqui"  , 0, 1}, ; //"Pesquisar"
                     {OemtoAnsi(STR0002  ), "HSPP38(2)" , 0, 2}, ;  //"Visualizar"
                     {OemtoAnsi(STR0003), "HSPP38(4)" , 0, 4, 2}, ; //"Recebimentos"
                     {OemtoAnsi(STR0004    ), "HSPP38(5)" , 0, 5}, ; //"Estornar"
                     {OemtoAnsi(STR0005      ), "HSPP38(6)" , 0, 2}, ; //"Recibo"
                     {OemToAnsi(STR0006     ), "HSM1_LEG()", 0, 1}} //"Legenda"
            
 Private cCadastro := OemToAnsi(STR0007) //"Recebimento de contas particulares"
 
 DbSelectArea("GAD")
 DbSetOrder(1)
 
 mBrowse(06, 01, 22, 75, "GAD",,,,,, aCor)
Return(Nil)

Function HSPP38(nOpc)
 Local aArea := HS_SavArea({{"GO0", 0, 0}, {"GO1", 0, 0}, {"GAD", 0, 0}, {"GAK", 0, 0}, {"GAL", 0, 0}, {"GAO", 0, 0}})
 Local cAliasOld := Alias(), nPosCTD := 0
 Local nOpcA := 0, oDlg, nPosRec := 1, nIteRec := 1, nValRec := 0, lAchou := .F., dDatRec := CToD("")
 Local oNroCop, nNroCop := 1, oCBDet, lCBDet := .F., oCBMar, lCBMar := .F., oBtnImp
 
 Private cChvGad := GAD->GAD_REGATE
 Private aTela := {}, aGets := {}, aAteDes := {}
 Private oGDGC0, aHGC0 := {}, aCGC0 := {}, nUGC0 := 0
 Private nGC0_DatRec := 0, nGC0_ValRec := 0, nGC0_NroRec := 0
 Private nMarDes := 0, nDatDes := 0, nValDes := 0, nCodDes := 0, nDescri := 0, nOriDes := 0, nSeqDes := 0
 Private oGDDes, aHeader := {}, aCols := {}, nUsado := 0
 Private aCTotDes := {}, lTemOrc := .F.
 
 DbSelectArea("GO0")
 DbSetOrder(2)
 lTemOrc := DbSeek(xFilial("GO0") + GAD->GAD_REGATE)
                                                                                                  
 HS_BDados("GC0", @aHGC0, @aCGC0, @nUGC0, 2, GAD->GAD_REGATE, "'" + GAD->GAD_REGATE + "' == GC0->GC0_REGATE",,,,, "GC0_NOME  /GC0_REGATE", .F., IIf(nOpc == 6, "P38_MARBRW", Nil), IIf(nOpc == 6, "LBNO", Nil))
 
 If nOpc # 4 .And. Len(aCGC0) == 0                     
  If     nOpc == 2
   cMsgRec := STR0008 //"visualizados"
  ElseIf nOpc == 5
   cMsgRec := STR0009 //"estornados"
  ElseIf nOpc == 6
   cMsgRec := STR0010 //"impressos"
  EndIf
   
  HS_MsgInf(STR0011 + cMsgRec, STR0012,STR0007) //"Este atendimento não possue recibos a serem "###"Atenção"###"Recebimento de contas particulares"
  Return(.T.)
 EndIf 
 
 nP38_MarBrw := aScan(aHGC0, {| aVet | aVet[2] == "P38_MARBRW"})
 nGC0_DatRec := aScan(aHGC0, {| aVet | aVet[2] == "GC0_DATREC"})
 nGC0_ValRec := aScan(aHGC0, {| aVet | aVet[2] == "GC0_VALREC"})
 nGC0_NroRec := aScan(aHGC0, {| aVet | aVet[2] == "GC0_NROREC"})
 
 DbSelectArea("GAD")
 DbSetOrder(1)
 DbSeek(xFilial("GAD") + cChvGad)
 
 aAdd(aHeader, {" "        , "nMarDes", "@BMP"         , 01, 0, ".F.", "", "C", "XXX", "V", "LBNO", ""})
 nMarDes := Len(aHeader)
 aAdd(aHeader, {STR0013     , "cDatDes", "@D"           , 08, 0, ".F.", "", "D", "XXX", "V",     "", ""}) //"Data"
 nDatDes := Len(aHeader)
 aAdd(aHeader, {"Valor"    , "cValDes", "@E 999,999.99", 09, 2, ".F.", "", "N", "XXX", "V",     "", ""})
 nValDes := Len(aHeader)
 aAdd(aHeader, {STR0014   , "cCodDes", "@!"           , 15, 0, ".F.", "", "C", "XXX", "V",     "", ""}) //"Codigo"
 nCodDes := Len(aHeader)
 aAdd(aHeader, {STR0015, "cDescri", "@!"           , 40, 0, ".F.", "", "C", "XXX", "V",     "", ""}) //"Descricao"
 nDescri := Len(aHeader)                                   
 
 DbSelectArea("SX3")
 DbSetOrder(2)
 DbSeek("GBG_ORIDES")
 aAdd(aHeader, {TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, ;
                SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, ;
                SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, ;
	            SX3->X3_CONTEXT, SX3->X3_RELACAO, SX3->X3_RESERV})
 nOriDes := Len(aHeader)
 
 aAdd(aHeader, {STR0016, "cSeqDes", "@!"           , 09, 0, ".F.", "", "C", "XXX", "V",     "", ""}) //"Seq.Desp."
 nSeqDes := Len(aHeader)
 
 nUsado := Len(aHeader)
 
 aAteDes := HS_ValAte(GAD->GAD_REGATE)
 
 If Len(aAteDes[1]) + Len(aAteDes[2]) + Len(aAteDes[3]) == 0
  HS_MsgInf(STR0017, STR0012,STR0007) //"Não existe despesas lançadas para o atendimento selecionado"###"Atenção"###"Recebimento de contas particulares"
  Return(.T.)
 EndIf 
 
 FS_MArray(nOpc)         
 
 DbSelectArea("GAD") 
 nOpcA := 0
 DEFINE MSDIALOG oDlg TITLE cCadastro From 009, 000 To 038, 080	Of oMainWnd
  If nOpc # 6
   EnChoice("GAD",, 2,,,,,{014, 001, 070, 315},, 2,,,, oDlg,, .F.)
  Else              
   @ 015, 010 Say STR0018 Of oDlg Pixel //"Numero de cópias por recibo"
   @ 013, 090 MSGet oNroCop Var nNroCop Picture "99" Valid FS_VldP38(nNroCop) Of oDlg Pixel
   @ 030, 010 CheckBox oCBDet Var lCBDet Prompt STR0019 SIZE 50, 10 OF oDlg PIXEL  //"Recibo detalhado"
   @ 045, 010 CheckBox oCBMar Var lCBMar Prompt STR0020 SIZE 50, 10 OF oDlg PIXEL On Click (FS_MRecib(lCBMar)) //"Marca todos"
   oBtnImp := tButton():New(057, 010, STR0021, oDlg, {|| FS_ImpP38(nNroCop, lCBDet)}, 50, 12,,,, .T.) //"Imprime"
  EndIf
   
  oGDGC0 := MsNewGetDados():New(070, 001, 140, 315, 2,,,,,, Len(aCGC0),,,, oDlg, aHGC0, aCGC0)
  oGDGC0:lUpDate := .F.                                                                   
  oGDGC0:oBrowse:bChange := {|| FS_BItens(aCGC0[oGDGC0:oBrowse:nAt, nGC0_NroRec], nOpc)}
  If nOpc == 6
   oGDGC0:oBrowse:BlDblClick := {|| FS_MRecib()}
  EndIf 
  
  oGDDes := MsGetDados():New(142, 001, 218, 315, 2,,,, .F.,,,, Len(aCols),,,,, oDlg)
  oGDDes:oBrowse:BlDblClick := {|| FS_MItens(nOpc)}
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGDGC0:TudoOk(), oDlg:End(), nOpcA := 0)}, ;
                                                           {|| nOpcA := 0, oDlg:End()})
                                                                
 If nOpcA == 1 .And. nOpc # 2 .And. nOpc # 6
  Begin Transaction
   dDatRec := aCGC0[1, nGc0_DatRec]
   nValRec := 0
   For nPosRec := 1 To Len(aCGC0)
    nPosCTD := aScan(aCTotDes, {| aVet | aVet[1] == aCGC0[nPosRec, nGc0_NroRec]})
                                      
    DbSelectArea("GC0")
    DbSetOrder(1)
    If Empty(aCGC0[nPosRec, nGc0_NroRec]) .And. aCGC0[nPosRec, nGc0_ValRec] > 0
     lAchou := .F.
     aCGC0[nPosRec, nGc0_NroRec] := GetSxeNum("GC0", "GC0_NROREC",, 1)
     ConfirmSx8()
    Else
     lAchou := DbSeek(xFilial("GC0") + aCGC0[nPosRec, nGc0_NroRec])
    EndIf 
    
    If aCGC0[nPosRec, nGc0_ValRec] > 0 .And. nOpc # 5
     RecLock("GC0", !lAchou)
      HS_GrvCpo("GC0", aCGC0, aHGC0, nPosRec)
      GC0->GC0_FILIAL := xFilial("GC0")
      GC0->GC0_REGATE := GAD->GAD_REGATE
      GC0->GC0_LOGARQ := HS_LogArq()
     MsUnLock()
     
     dDatRec := IIf(aCGC0[nPosRec, nGc0_DatRec] > dDatRec, aCGC0[nPosRec, nGc0_DatRec], dDatRec)
     nValRec += aCGC0[nPosRec, nGc0_ValRec]
    Else
     If lAchou
      RecLock("GC0", .F.)
       DbDelete()
      MsUnLock()
     EndIf
    EndIf
    
    If nPosCtd > 0
     For nIteRec := 1 To Len(aCTotDes[nPosCTD][2])
      If !lTemOrc
       If     aCTotDes[nPosCTD][2][nIteRec][nOriDes] == "0" // Mat/Med
        DbSelectArea("GAK")
        DbSetOrder(6)
        If DbSeek(xFilial("GAK") + PadR(AllTrim(aCTotDes[nPosCTD][2][nIteRec][nSeqDes]), Len(GAK->GAK_SEQDES)) + ;
                                   PadR(AllTrim(GAD->GAD_REGATE                       ), Len(GAK->GAK_REGATE)) + ;
                                   PadR(AllTrim(aCTotDes[nPosCTD][2][nIteRec][nCodDes]), Len(GAK->GAK_CODMAT)))
         RecLock("GAK", .F.)
          If aCGC0[nPosRec, nGc0_ValRec] > 0 .And. nOpc # 5 .And. AllTrim(aCTotDes[nPosCTD][2][nIteRec][nMarDes]) == "LBTIK"
           GAK->GAK_NROREC := aCGC0[nPosRec][nGc0_NroRec]
          Else
           GAK->GAK_NROREC := Space(Len(GAK->GAK_NROREC))
          EndIf 
         MsUnLock()
        EndIf
       ElseIf aCTotDes[nPosCTD][2][nIteRec][nOriDes] == "1" // Procedimentos
        DbSelectArea("GAO")
        DbSetOrder(5)
        If DbSeek(xFilial("GAO") + PadR(AllTrim(aCTotDes[nPosCTD][2][nIteRec][nSeqDes]), Len(GAO->GAO_SEQDES)) + ;
                                   PadR(AllTrim(GAD->GAD_REGATE                       ), Len(GAO->GAO_REGATE)) + ;
                                   PadR(AllTrim(aCTotDes[nPosCTD][2][nIteRec][nCodDes]), Len(GAO->GAO_CODPRO)))
         RecLock("GAO", .F.)                                                                          
          If aCGC0[nPosRec, nGc0_ValRec] > 0 .And. nOpc # 5 .And. AllTrim(aCTotDes[nPosCTD][2][nIteRec][nMarDes]) == "LBTIK"
           GAO->GAO_NROREC := aCGC0[nPosRec][nGc0_NroRec]
          Else
           GAO->GAO_NROREC := Space(Len(GAO->GAO_NROREC))
          EndIf  
         MsUnLock()
        EndIf
       ElseIf aCTotDes[nPosCTD][2][nIteRec][nOriDes] == "2" // Taxas e Diarias
        DbSelectArea("GAL")
        DbSetOrder(5)
        If DbSeek(xFilial("GAL") + PadR(AllTrim(aCTotDes[nPosCTD][2][nIteRec][nSeqDes]), Len(GAL->GAL_SEQDES)) + ;
                                   PadR(AllTrim(GAD->GAD_REGATE                       ), Len(GAL->GAL_REGATE)) + ;
                                   PadR(AllTrim(aCTotDes[nPosCTD][2][nIteRec][nCodDes]), Len(GAL->GAL_CODTAX)))
         RecLock("GAL", .F.)
          If aCGC0[nPosRec, nGc0_ValRec] > 0 .And. nOpc # 5 .And. AllTrim(aCTotDes[nPosCTD][2][nIteRec][nMarDes]) == "LBTIK"
           GAL->GAL_NROREC := aCGC0[nPosRec][nGc0_NroRec]
          Else 
           GAL->GAL_NROREC := Space(Len(GAL->GAL_NROREC))
          EndIf 
         MsUnLock()
        EndIf
       EndIf
      Else 
       DbSelectArea("GO1")
       DbSetOrder(1)
       If DbSeek(xFilial("GO1") + PadR(AllTrim(aCTotDes[nPosCTD][2][nIteRec][nSeqDes]), Len(GO1->GO1_NUMORC + GO1->GO1_ITEM)))
        RecLock("GO1", .F.)
         If aCGC0[nPosRec, nGc0_ValRec] > 0 .And. nOpc # 5 .And. AllTrim(aCTotDes[nPosCTD][2][nIteRec][nMarDes]) == "LBTIK"
          GO1->GO1_NROREC := aCGC0[nPosRec][nGc0_NroRec]
         Else 
          GO1->GO1_NROREC := Space(Len(GO1->GO1_NROREC))
         EndIf 
        MsUnLock()
       EndIf
      EndIf 
     Next
    EndIf 
   Next
  
   DbSelectArea("GAD")
   DbSetOrder(1)
   If DbSeek(xFilial("GAD") + GAD->GAD_REGATE)
    RecLock("GAD", .F.)
     GAD->GAD_VLRREC := nValRec
     GAD->GAD_DATREC := dDatRec
    MsUnLock() 
   EndIf
  End Transaction 
 EndIf
                         
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(.T.)
 
Static Function FS_BItens(cGc0_NroRec, nOpc)
 Local nItem := 0, nRet := 1, nPosRec := 0
 
 aCols := {}                              
 
 nPosRec := aScan(aCTotDes, {| aVet | aVet[1] == cGc0_NroRec})
                                                              
 If nPosRec > 0
  For nItem := 1 To Len(aCTotDes[nPosRec][2])
   aAdd(aCols, Array(nUsado + 1))
   aCols[Len(aCols), nMarDes   ] := aCTotDes[nPosRec][2][nItem][nMarDes   ]
   aCols[Len(aCols), nCodDes   ] := aCTotDes[nPosRec][2][nItem][nCodDes   ]
   aCols[Len(aCols), nDatDes   ] := aCTotDes[nPosRec][2][nItem][nDatDes   ]
   aCols[Len(aCols), nDescri   ] := aCTotDes[nPosRec][2][nItem][nDescri   ]
   aCols[Len(aCols), nValDes   ] := aCTotDes[nPosRec][2][nItem][nValDes   ]
   aCols[Len(aCols), nOriDes   ] := aCTotDes[nPosRec][2][nItem][nOriDes   ]
   aCols[Len(aCols), nSeqDes   ] := aCTotDes[nPosRec][2][nItem][nSeqDes   ]
   aCols[Len(aCols), nUsado + 1] := aCTotDes[nPosRec][2][nItem][nUsado + 1]
  Next
 EndIf 
       
 If oGDDes # Nil .And. nOpc # 0 // nOpc só é igual a zero quando estiver na funcção HS_ImpP38 - Impressão do recibo
  oGDDes:oBrowse:Refresh()
 EndIf 
Return(.T.)

Static Function FS_MItens(nOpc)
 Local nAtOld := oGDGC0:oBrowse:nAt, nRowPosOld := oGDGC0:oBrowse:nRowPos
 Local nPosRec := aScan(aCTotDes, {| aVet | aVet[1] == aCGC0[oGDGC0:oBrowse:nAt, nGc0_NroRec]})
 
 If nOpc # 4
  Return(.F.)
 EndIf 

 aCols[oGDDes:oBrowse:nAt, nMarDes    ] := IIf(AllTrim(aCols[oGDDes:oBrowse:nAt, nMarDes]) == "LBTIK", "LBNO", "LBTIK")
 If AllTrim(aCols[oGDDes:oBrowse:nAt, nMarDes]) == "LBTIK"
  aCGC0[oGDGC0:oBrowse:nAt, nGc0_ValRec] += aCols[oGDDes:oBrowse:nAt, nValDes]
 Else                                                                         
  aCGC0[oGDGC0:oBrowse:nAt, nGc0_ValRec] -= aCols[oGDDes:oBrowse:nAt, nValDes]
 EndIf
 
 aCTotDes[nPosRec][2][oGDDes:oBrowse:nAt][nMarDes] := aCols[oGDDes:oBrowse:nAt, nMarDes]
 
 oGDGC0:SetArray(aCGC0)
 oGDGC0:oBrowse:nAt := nAtOld        
 oGDGC0:oBrowse:nRowPos := nRowPosOld
 oGDGC0:oBrowse:Refresh()
Return(.T.)

Static Function FS_MArray(nOpc)
 Local nPosRec := 0, nPosPRec := 0, nItem := 0, nRet := 1, lCriaVazio := .F., cMANroRec := "", nMAValRec := 0

 aCTotDes := {}
 
 For nRet := 1 To 3
  For nItem := 1 To Len(aAteDes[nRet])
   nPosRec := aScan(aCTotDes, {| aVet | aVet[1] == aAteDes[nRet][nItem][IIf(nRet == 1, 9, 7)]})
   If nPosRec == 0
    aAdd(aCTotDes, {aAteDes[nRet][nItem][IIf(nRet == 1, 9, 7)], {}, 0})
    nPosRec := Len(aCTotDes)
   EndIf
   
   aAdd(aCTotDes[nPosRec][2], Array(nUsado + 1))
   
   nPosPRec := Len(aCTotDes[nPosRec][2])
   
   aCTotDes[nPosRec][2][nPosPRec][nMarDes] := "LBTIK"
   aCTotDes[nPosRec][2][nPosPRec][nCodDes] := aAteDes[nRet][nItem][IIf(nRet == 1, 02, 01)]
   aCTotDes[nPosRec][2][nPosPRec][nDatDes] := aAteDes[nRet][nItem][IIf(nRet == 1, 10, 08)]
   aCTotDes[nPosRec][2][nPosPRec][nDescri] := aAteDes[nRet][nItem][IIf(nRet == 1, 03, 02)]
   aCTotDes[nPosRec][2][nPosPRec][nValDes] := (aAteDes[nRet][nItem][IIf(nRet == 1, 04, 03)] * aAteDes[nRet][nItem][IIf(nRet == 1, 06, 05)])
   aCTotDes[nPosRec][2][nPosPRec][nOriDes] := IIf(nRet == 1, "1", IIf(nRet == 2, "0", "2"))
   aCTotDes[nPosRec][2][nPosPRec][nSeqDes] := aAteDes[nRet][nItem][IIf(nRet == 1, 11, 09)]
   aCTotDes[nPosRec][2][nPosPRec][nUsado + 1] := .F.
   
   aCTotDes[nPosRec][3] += (aAteDes[nRet][nItem][IIf(nRet == 1, 04, 03)] * aAteDes[nRet][nItem][IIf(nRet == 1, 06, 05)])
  Next
 Next                   
 
 For nItem := 1 To Len(aCTotDes)
  nPosRec := aScan(aCGC0, {| aVet | aVet[nGc0_NroRec] == aCTotDes[nItem][1]})
  If nPosRec > 0
   aCGC0[nPosRec, nGc0_ValRec] := aCTotDes[nItem][3]
  Else                        
   If nOpc # 5 .Or. (nOpc == 5 .And. !Empty(aCTotDes[nItem][1]))
    If !Empty(aCTotDes[nItem][1])
     aAdd(aCGC0, Array(nUGC0 + 1))
     If nOpc == 6 
      aCGC0[Len(aCGC0), nP38_MarBrw] := "LBNO"
     EndIf 
     aCGC0[Len(aCGC0), nGC0_NroRec] := aCTotDes[nItem][1]
     aCGC0[Len(aCGC0), nGC0_DatRec] := dDataBase
     aCGC0[Len(aCGC0), nGC0_ValRec] := aCTotDes[nItem][3]
     aCGC0[Len(aCGC0), nUGC0 + 1  ] := .F.
    Else
     lCriaVazio := .T.
     cMANroRec := aCTotDes[nItem][1]
     nMAValRec := aCTotDes[nItem][3]
    EndIf 
   EndIf 
  EndIf 
 Next             
 
 aSort(aCGC0,,, {| X, Y | DToS(X[nGc0_DatRec]) + X[nGc0_NroRec] < DToS(Y[nGc0_DatRec]) + Y[nGc0_NroRec]})
 
 If lCriaVazio
  aAdd(aCGC0, Array(nUGC0 + 1))              
  If nOpc == 6  
   aCGC0[Len(aCGC0), nP38_MarBrw] := "LBNO"
  EndIf 
  aCGC0[Len(aCGC0), nGC0_NroRec] := cMANroRec
  aCGC0[Len(aCGC0), nGC0_DatRec] := dDataBase
  aCGC0[Len(aCGC0), nGC0_ValRec] := nMAValRec
  aCGC0[Len(aCGC0), nUGC0 + 1  ] := .F.
 EndIf
Return(Nil)

Static Function FS_MRecib(lMarBrw)
 Local nItem := 1, nAtOld := oGDGC0:oBrowse:nAt, nRowPosOld := oGDGC0:oBrowse:nRowPos, nColPosOld := oGDGC0:oBrowse:nColPos
 
 If lMarBrw # Nil
  For nItem := 1 To Len(aCGC0)
   aCGC0[nItem, nP38_MarBrw] := IIf(lMarBrw, "LBTIK", "LBNO")
  Next
 Else
  aCGC0[oGDGC0:oBrowse:nAt, nP38_MarBrw] := IIf(AllTrim(aCGC0[oGDGC0:oBrowse:nAt, nP38_MarBrw]) == "LBNO", "LBTIK", "LBNO")
 EndIf 
 
 oGDGC0:SetArray(aCGC0)
 oGDGC0:oBrowse:nAt     := nAtOld
 oGDGC0:oBrowse:nRowPos := nRowPosOld
 oGDGC0:oBrowse:nColPos := nColPosOld
 oGDGC0:oBrowse:Refresh()
Return(.T.)                                                                  

Static Function FS_VldP38(nNroCop)
 Local lRet := .T.
 If nNroCop <= 0
  HS_MsgInf(STR0022, STR0012,STR0007) //"Quantidade invalida, informe um valor maior que 0"###"Atenção"###"Recebimento de contas particulares"
  lRet := .F.
 EndIf
Return(lRet)

Static Function FS_ImpP38(nNroCop, lCBDet)
 Local cAliasOld  := Alias()
 Local cTamanho   := "M"     // P/M/G
 Local cTitulo    := STR0023 //"Recibo de Pagamento"
 Local nLastKey   := 0
 LOCAL nQImp 	  := 0
 Local nRecImp    := 0
 Local nIteRec    := 0
 Local nPosIte    := 0
 Local cDrive     := "Epson.drv"
 Local cNomeImp   := "LPT1"
 Local cAlias     := "GC0"
 Local LServer    := Nil
 Local nLin       := 0
 Local nLinExt    := 0
 Local cExtenso   := ""
 Local lPerg      := .F.     
 Local aCOld      := aCols
 Local aCImp      := {}
 Local cTipOri    := "@"
 
 Private aReturn   := {"Zebrado", 2,"Administracao", 1, 4, "LPT1", "", 1}
 Private cNomProg  := "HSPAHP38"
 Private cNomeRel  := "HSPAHP38"
 Private nCaracter := 18
 Private Limite    := 80      // 80/132/220
 Private aOrdem    := {}      // Ordem do Relatorio

 cNomeRel := SetPrint(cAlias, cNomeRel, nil, @cTitulo, "", "", "", .F., "", .F., cTamanho, nil, nil, nil, nil)
  
 If nLastKey == 27
  Return(Nil)
 Endif
   
 SetDefault(aReturn, cAlias)
  
 Set Printer to &cNomeRel
 Set Printer On
 Set Device  to Printer          
 
 DbSelectArea("GAD")
 DbSetOrder(1)
 DbSeek(xFilial("GAD") + cChvGad)
                         
 DbSelectArea("GCS")
 DbSetOrder(1)
 DbSeek(xFilial("GCS") + GAD->GAD_CODLOC)
 
 DbSelectArea("SA1")
 DbSetOrder(1)
 DbSeek(xFilial("SA1") + GAD->GAD_CLIFAT + GAD->GAD_LOJA)
                 
 For nRecImp = 1 to Len(aCGC0)
  If AllTrim(aCGC0[nRecImp, nP38_MarBrw]) == "LBTIK"
   FS_BItens(aCGC0[nRecImp, nGC0_NroRec], 0)
   For nQImp := 1 To nNroCop
    nLin := 0
    @ 0000, 0000 PSAY CHR(18)
    @ nLin, 0000 PSAY CHR(14) + AllTrim(SM0->M0_NOMECOM) + Chr(20)
    nLin++            
    @ nLin, 0000 PSAY CHR(15)
    @ nLin, 0000 PSAY AllTrim(SM0->M0_ENDCOB) + ;
                      "    CGC : "    + TransForm(SM0->M0_CGC, "@R 99.999.999/9999-99") + ;
                      STR0026   + TransForm(SM0->M0_CGC, "@R (9999)999-9999") + ; //"    Fone : "
                      STR0027 + AllTrim(SM0->M0_CIDCOB) + "-" + SM0->M0_ESTCOB  //"    Cidade : "
    @ nLin, 0000 PSAY Chr(18)
    nLin += 3
    @ nLin, 0000 PSAY CHR(14) + STR0028 + PadL(AllTrim(TransForm(aCGC0[nRecImp, nGC0_ValRec], "@E 999,999.99")), 10, "*") + Chr(20) //"R E C I B O           R$"
    nLin += 3
    @ nLin, 0055 PSAY STR0029 + PadL(AllTrim(GAD->GAD_ATENDE), 17) //"Usuario "
    nLin++
    @ nLin, 0055 PSAY STR0030    + PadL(GAD->GAD_REGGER, 10)          //"Registro Geral "
    nLin++
    @ nLin, 0055 PSAY STR0031 + TransForm(aCGC0[nRecImp, nGC0_ValRec], "@E 999,999.99") //"Valor Controle "
    nLin++
    @ nLin, 0055 PSAY STR0032  + PadL(AllTrim(GCS->GCS_NOMLOC/*SX5->X5_DESCRI*/), 11) //"Caixa         "
    nLin += 2
    @ nLin, 0000 PSAY PadR(STR0033 + AllTrim(SA1->A1_NOME) + STR0034, 80, "*") //"Recebemos de "###" a importacia supra de : "
    nLin++
    
    cExtenso := PadR(Extenso(aCGC0[nRecImp, nGC0_ValRec]), 320, "*")
    
    For nLinExt := nLin To (nLin + Int(Len(cExtenso) / 80))
     @ nLinExt, 0000 PSAY SubStr(cExtenso, ((nLinExt - nLin) * 80) + 1, 80)
    Next
    
    nLin := nLinExt + 1                                                                       
    @ nLin, 0000 PSAY STR0035 //"referente a serviços de assistencia medica e/ou hospitalar prestados ao paciente"
    nLin++
    @ nLin, 0000 PSAY AllTrim(GAD->GAD_NOME) + STR0036 + GAD->GAD_REGATE  //" conforme o atendimento numero "
    nLin++
    @ nLin, 0000 PSAY STR0037 //"e os itens relacionados abaixo."
    nLin += 3
          
    aCImp := {}
    If !lCBDet                 
     For nIteRec := 1 To Len(aCols)
      nPosIte := aScan(aCImp, {| aVet | aVet[nOriDes] == aCols[nIteRec, nOriDes]})
      If nPosIte > 0
       aCImp[nPosIte, nValDes] += aCols[nIteRec, nValDes]
      Else
       aAdd(aCImp, aCols[nIteRec])
      EndIf
     Next
    Else
     aCImp := aCols     
    Endif 
    
    If !lCBDet
     @ nLin, 0000 PSAY Chr(18)
    Else                      
     @ nLin, 0000 PSAY Chr(15)
    EndIf

    For nIteRec := 1 To Len(aCImp)
     If !lCBDet
      @ nLin, 000 PSay STR0038 + PadR(AllTrim(HS_RDescrB("GBG_ORIDES", aCImp[nIteRec, nOriDes])), 22) + " " + Transform(aCImp[nIteRec, nValDes], "@E 999,999.99") //"Total de "
     Else              
      If cTipOri # aCImp[nIteRec, nOriDes]
       nLin++
       @ nLin, 000 PSay HS_RDescrB("GBG_ORIDES", aCImp[nIteRec, nOriDes])
       nLin++
       cTipOri := aCImp[nIteRec, nOriDes]
      EndIf       
      @ nLin, 000 PSay DToC(aCImp[nIteRec, nDatDes]) + " " + Transform(aCImp[nIteRec, nValDes], "@E 999,999.99") + " " + ;
                       PadR(AllTrim(aCImp[nIteRec, nCodDes]), 15) + " " + PadR(AllTrim(aCImp[nIteRec, nDescri]), 44)
     EndIf
     nLin++
    Next               
    
    nLin += 3
   
    @ nLin, 0000 PSAY PadC(AllTrim(SM0->M0_CIDCOB)    + ", "   + ;
                           StrZero(Day(dDatabase), 2) + STR0039 + ; //" de "
                           MesExtenso(dDatabase)      + STR0039 + ; //" de "
                           StrZero(Year(dDatabase), 4), 80, " ")
    nLin += 3
    
    @ nLin, 0000 PSAY PadC(Replicate("_", Len(AllTrim(SM0->M0_NOMECOM))), 80, " ")
    
    nLin++
    
    @ nLin, 0000 PSAY PadC(AllTrim(SM0->M0_NOMECOM), 80, " ")
    
    nLin++
    @ nLin, 0000 PSAY Replicate("-", 80)
    nLin += 2
   Next 
  EndIf 
 Next 
 
 aCols := aCOld
 
 Ms_Flush()
  
 Set Printer to
 Set Device  to Screen

 If aReturn[5] == 1
  OurSpool(cNomeRel)
 EndIf 
 
 DbSelectArea(cAliasOld)
Return(Nil)