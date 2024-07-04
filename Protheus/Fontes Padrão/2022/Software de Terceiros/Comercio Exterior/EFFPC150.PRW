#INCLUDE "EFFPC150.ch"
#INCLUDE "AVERAGE.CH"

//Revisão : Alcir - 07-12-05   - considerar apenas eventos do tipo 1 EEQ_TP_CON, desconsiderar dados do EEC quando não houver processo
//Revisão - 27-12-04 - Alcir Alves - tratamento de multifilial
// ----------------------------------------------------------------------
// PLB - Pedro Luiz Baroni
// 05/05/2006
// Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
// Quebras por Tipo de Modulo (EXP/IMP)
// ----------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EFFPC150 Autor ³ Lucas R. R. Lopes       ³ Data ³ 15/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio DE POSICAO DE CARTEIRA EM ABERTO                  ±±
±±       Considerando ou Não , As invoices vinculadas                      ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-------------------------*
Function EFFPC150()
*-------------------------*
LOCAL cAliasOld := Alias()
LOCAL lOk := .F.
Private lTPCONExt:=(EEQ->(fieldpos("EEQ_TP_CON"))>0)
Private cNomeArqA , cNomeArqB , cNomeArqC
Private cFilEEQ := xFilial('EEQ'),cFilEEC:=xFilial('EEC'),cFilEF3:=xFilial('EF3')
Private cFilSA1 := xFilial('SA1'),cFilSA6:=xFilial('SA6'),cfilSel:={} //Alcir Alves - 21/12/04 - conceito multifilial
Private dInicial
Private dFinal
PRIVATE cBanco
Private cCodCli
Private cModo
Private cVinc // Considera invoices Vinculadas
Private cQuebra := " "
Private lMultiFil := Posicione("SX2",1,"EEQ","X2_MODO") == "E" .AND.;
                     Posicione("SX2",1,"EF1","X2_MODO") == "C" .and. VerSenha(115) //AAF 10/01/05 - Verifica se o ambiente é multifilial.
//** PLB - 01/05/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private cTpModu := "E"
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0
//**

// Cria Work
CriaWork()

//ASK 13/02/07 14:31 - Incluso no AtuSx do P9R1
//EFFPC150_ACERTADICIO()

cfilSel:=AvgSelectFil(.T.,"EEQ") //Alcir Alves - 21/12/04 - conceito multifilial
If cfilSel[1]#"WND_CLOSE"  //Alcir Alves - 15-03-05 - caso a janela de sel. multifilial não tenha sido fechada
   If !Pergunte("EFFPC1",.T.)
      Work->(DbCloseArea())
      Erase(cNomeArqA+TEOrdBagExt())
      Erase(cNomeArqB+TEOrdBagExt())
      Erase(cNomeArqC+TEOrdBagExt())
      Return .F.
   EndIf
   If lEFFTpMod  //** PLB 01/05/06
      cTpModu  := IIF(mv_par01==1,"E",IIF(mv_par01==2,"I","A"))
      cBanco   := mv_par02
      dInicial := mv_par03
      dFinal   := mv_par04
      cCodCli  := mv_par05
      cCodFor  := mv_par06
      cModo    := Str(mv_par07,1)
      cVinc    := Str(mv_par08,1)
   Else
      cBanco   := mv_par01
      dInicial := mv_par02
      dFinal   := mv_par03
      cCodCli  := mv_par04
      cModo    := Str(mv_par05,1)
      cVinc    := Str(mv_par06,1)
   EndIf
   lOK :=.T.
   If cModo = "1"
      DEFINE MSDIALOG oDlg TITLE "Tipo de Quebra" FROM 10,0 TO 19,45/*28*/ OF oMainWnd
         @ 45,020/*005*/ SAY "Quebra "  SIZE 232,10 PIXEL
         @ 43,055/*040*/ MSCOMBOBOX oCmb VAR cQuebra ITEMS {"1-Data Vencimento","2-Cliente/Fornec."} SIZE 90, 80 OF oDlg PIXEL
      ACTIVATE MSDIALOG oDlg on Init EnchoiceBar(oDlg, { || lOk := .T. , oDlg:end() } ,{ || lOk := .F. ,oDlg:end() } ,,) CENTERED
   EndIf
   If !lOK
      Work->(DbCloseArea())
      Erase(cNomeArqA+TEOrdBagExt() )
      Erase(cNomeArqB+TEOrdBagExt())
      Erase(cNomeArqC+TEOrdBagExt())
      Return .F.
   EndIf
   // Grava na Work
   MsAguarde({ || GrvWork()}, STR0001 )  //"Lendo Informacoes..."

   Work->(DbGotop())
   IF Work->(EOF()) .AND. Work->(BOF())
      Msginfo(STR0002)  //"Não ha registros disponíveis !!!"
   Else
   // Imprime Relatorio
      If cQuebra = "2"
         Work->( DbSetOrder(3) )
      EndIf
      GeraRel()
   Endif
endif

EEC->(DBSETORDER(1))
EEQ->(DBSETORDER(1))
EF3->(DBSETORDER(1))

Work->(DbCloseArea())
Erase(cNomeArqA+TEOrdBagExt())
Erase(cNomeArqB+TEOrdBagExt())
Erase(cNomeArqC+TEOrdBagExt())
DbSelectArea(cAliasOld)
RETURN .F.

*-----------------------*
Static Function GrvWork()
*-----------------------*
Local aFilEEQ:=aFilEF3:=aFilEEC:={}
Local cQryEEQ := ""
Local cQrySWB := ""
Local Ni
Private cFilSWB:={}

Private Find_moeda

DbSelectArea("Work")
AvZap()

EEQ->(DBSETORDER(1))
EEC->(DBSETORDER(1))
EF3->(DBSETORDER(3))

//Alcir - AAS - tratamento de multifilial
//begin 01
aFilEEQ:=aclone(cfilSel)  //filiais selecionadas
If Len(aFilEEQ) > 1
   lMultiFil := .T.
EndIf
aFilEF3:=AvgSelectFil(.F.,"EF3")
aFilEEC:=AvgSelectFil(.F.,"EEC")
Find_moeda:=iif(EEQ->(FIELDPOS("EEQ_MOEDA"))>0,.T.,.F.)  //verifica se o campo moeda existe

#IFDEF TOP

Begin Sequence

   //verifica se é somente importação.
   If lEFFTpMod .and. cTpModu == "I"
      Break
   EndIf

  //Monta a query para busca de parcelas do EEQ
   cQryEEQ += "Select * From " + RetSqlName("EEQ")

   //Verificação de filiais a serem consultadas.
   For nI:=1 to Len(aFilEEQ)
      If nI == 1
         cQryEEQ += " Where (EEQ_FILIAL = '" + aFilEEQ[nI] + "' "
      Else
         cQryEEQ += "Or EEQ_FILIAL = '" + aFilEEQ[nI] + "' "
      EndIf
   Next
   cQryEEQ += ") "

   If lEFFTpMod
      If cTpModu == "E"
         cQryEEQ += "AND (EEQ_TP_CON In('1', '3') Or EEQ_TIPO = 'R') "
      EndIf
   EndIf

   // Verifica se a invoice foi paga
   cQryEEQ += "AND EEQ_PGT = ' ' "

   // Verifica se esta dentro do periodo
   IF !EMPTY(dInicial)
      cQryEEQ += "AND EEQ_VCT >= '" + DToS(dInicial) + "' "
   Endif
   IF !EMPTY(dFinal)
      cQryEEQ += "AND EEQ_VCT <= '" + DToS(dFinal) + "' "
   Endif

   // Verifica o Banco
   IF !EMPTY(cBanco)
      cQryEEQ += "AND EEQ_BANC = '" + cBanco + "' "
   Endif

   // Verifica o Cliente ou Fornecedor
   If lEFFTpMod
      cQryEEQ += "AND ((EEQ_TP_CON In('1', '3') "
      If !Empty(cCodCli)
         cQryEEQ += "AND EEQ_IMPORT = '" + AvKey(cCodCli, "EEQ_IMPORT") + "'"
      EndIf
      cQryEEQ += ") OR (EEQ_TP_CON In('2', '4') "
      If !Empty(cCodFor)
         cQryEEQ += "AND EEQ_FORN = '" + AvKey(cCodFor, "EEQ_FORN") + "'"
      EndIf
      cQryEEQ += "))
   EndIf

   //WFS
   If TcSrvType() <> "AS/400"
      cQryEEQ += " And D_E_L_E_T_ <> '*' "
   Else
      cQryEEQ += " And @DELETED@ <> '*' "
   EndIf

   //Executa a query
   dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQryEEQ)), "QRYEEQ", .F., .T. )
   SX3->(DbSeek("EEQ"))
   While SX3->(!Eof() .And. X3_ARQUIVO == "EEQ")
      If SX3->X3_TIPO == "D"
         TCSetField("QRYEEQ", SX3->X3_CAMPO, "D")
      EndIf
      SX3->(DbSkip())
   EndDo

   //Alimenta a work com o resultado da query
   While QRYEEQ->(!Eof())
      GravaEEQ("QRYEEQ")
      QRYEEQ->(DbSkip())
   EndDo

   QRYEEQ->(dbCloseArea())

End Sequence

#ELSE

for ni:=1 to len(aFilEEQ)
   cFilEEQ:=cFilSWB:=aFilEEQ[ni]
   cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],aFilEEQ[ni])
   cFilEEC:=iif(len(aFilEEC)==1 .and. alltrim(aFilEEC[1])=="",aFilEEC[1],aFilEEQ[ni])
   EEQ->(DbSeek(cFilEEQ))

   DO WHILE ! EEQ->(EOF()) .AND. EEQ->EEQ_FILIAL==cFilEEQ
      //** PLB 09/05/06 - Verifica Tipo do Modulo
      If lEFFTpMod
         If cTpModu == "E"
            IF EEQ->EEQ_TP_CON $ "2/4" .OR. EEQ->EEQ_TIPO <> "R"
               EEQ->( DBSkip() )
               Loop
            EndIf
         ElseIf cTpModu == "I"  .And.  EEQ->EEQ_TP_CON $ "1/3"
            EEQ->( DBSkip() )
            Loop
         EndIf
      //**
      ElseIf lTPCONExt
         If EEQ->EEQ_TP_CON<>"1"
            EEQ->(DbSkip())
            Loop
         Endif
      EndIf
      // Verifica o Cliente
      EEC->(DbSeek(cFilEEC+EEQ->EEQ_PREEMB))
      // Verifica se a invoice foi paga
      If !Empty(EEQ->EEQ_PGT)
         EEQ->(DbSkip())
         Loop
      Endif
      // Verifica se a invoice esta vinculada
      If cVinc = "2"
         // PLB 01/05/06
         If lEFFTpMod
            If EF3->(DbSeek(cFilEF3+"E"+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC)) .Or. EF3->(DbSeek(cFilEF3+"I"+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC))
               EEQ->(DbSkip())
               Loop
            EndIf
         ElseIf EF3->(DbSeek(cFilEF3+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC))
            EEQ->(DbSkip())
            Loop
         EndIf
      Endif
      // Verifica se esta dentro do periodo
      IF !EMPTY(dInicial)
         If EEQ->EEQ_VCT < dInicial
            EEQ->(DbSkip())
            Loop
         Endif
      Endif
      IF !EMPTY(dFinal)
         //If EEQ->EEQ_VCT < dInicial
         If EEQ->EEQ_VCT > dFinal  // PLB 10/05/06
            EEQ->(DbSkip())
            Loop
         Endif
      Endif
      // Verifica o Banco
      IF !EMPTY(cBanco)
         If EEQ->EEQ_BANC # cBanco
            EEQ->(DbSkip())
            Loop
         Endif
      Endif
      // Verifica o Cliente ou Fornecedor
      //** PLB 09/05/06
      If lEFFTpMod
         If !Empty(cCodCli)  .And.  EEQ->EEQ_TP_CON $ "1/3"  .And.  !EEC->(EOF())  .And.  EEC->EEC_IMPORT # cCodCli
            EEQ->(DbSkip())
            Loop
         ElseIf !Empty(cCodFor)  .And.  EEQ->EEQ_TP_CON $ "2/4"  .And.  EEQ->EEQ_FORN # cCodFor
            EEQ->(DbSkip())
            Loop
         EndIf
      Else
         IF !EMPTY(cCodCli)
            If !EEC->(EOF()) .and. EEC->EEC_IMPORT # cCodCli
               EEQ->(DbSkip())
               Loop
            Endif
         EndIf
      Endif
      //**
      GravaEEQ("EEQ")
      EEQ->(DbSkip())
   EndDo
Next
#ENDIF

//**JVR** 04/02/09 - Verifica registros de Importação
#IFDEF TOP

Begin Sequence
    //verifica se é somente importação.
   If lEFFTpMod .and. cTpModu == "E"
      Break
   EndIf

   cQrySWB += "Select * From " + RetSqlName("SWB")

   For nI:=1 to Len(aFilEEQ)
      If nI == 1
         cQrySWB += " Where (WB_FILIAL = '" + aFilEEQ[nI] + "' "
      Else
         cQrySWB += "Or WB_FILIAL = '" + aFilEEQ[nI] + "' "
      EndIf
   Next
   cQrySWB += ") "

   If lEFFTpMod
      If cTpModu == "I"
         cQrySWB += "AND WB_TP_CON In('2', '4') "
      EndIf
   EndIf


   // Verifica se a invoice foi paga
   cQrySWB += "AND WB_CA_DT <> ' ' "

   // Verifica se esta dentro do periodo
   If !Empty(dInicial)
      cQrySWB += "AND WB_DT_VEN > '" + DToS(dInicial) + "' "
   EndIF
   If !Empty(dFinal)
      cQrySWB += "AND WB_DT_VEN < '" + DToS(dFinal) + "' "
   EndIF

   // Verifica o Banco
   If !EMPTY(cBanco)
      cQrySWB += "AND WB_BANCO = '" + cBanco + "' "
   Endif

   // Verifica o Fornecedor
   If !Empty(cCOdFor)
      cQrySWB += "AND WB_FORN = '" + cCodFor +"' "
   EndIf

   //WFS
   If TcSrvType() <> "AS/400"
      cQrySWB += " And D_E_L_E_T_ <> '*' "
   Else
      cQrySWB += " And @DELETED@ <> '*' "
   EndIf

   //Executa a query
   dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQrySWB)), "QRYSWB", .F., .T. )
   SX3->(DbSetOrder(1))
   SX3->(DbSeek("SWB"))
   While SX3->(!Eof() .And. X3_ARQUIVO == "SWB")
      If SX3->X3_TIPO == "D"
         TCSetField("QRYSWB", SX3->X3_CAMPO, "D")
      EndIf
      SX3->(DbSkip())
   EndDo

   //Alimenta a work com o resultado da query
   While QRYSWB->(!Eof())
      GravaSWB("QRYSWB")
      QRYSWB->(DbSkip())
   EndDo

   QRYSWB->(dbCloseArea())

End Sequence

#ELSE
   for ni:=1 to len(aFilEEQ)
      cFilEEQ:=cFilSWB:=aFilEEQ[ni]
      cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],aFilEEQ[ni])
      cFilEEC:=iif(len(aFilEEC)==1 .and. alltrim(aFilEEC[1])=="",aFilEEC[1],aFilEEQ[ni])
      cFilEEC:=iif(len(aFilEEC)==1 .and. alltrim(aFilEEC[1])=="",aFilEEC[1],aFilEEQ[ni])
      EEQ->(DbSeek(cFilEEQ))

      //**  PLB 09/05/06 - Verifica registros de Importacao
      If lEFFTpMod  .And.  cTpModu $ "I/A"  // Importacao ou Ambos
         SWB->( DBSetOrder(1) )
         EF3->( DBSetOrder(7) )
         SWB->( DBSeek(cFilSWB) )
         DO WHILE ! SWB->( EOF() )  .And.  SWB->WB_FILIAL==cFilSWB
            If SWB->WB_TP_CON $ "1/3"
               SWB->( DBSkip() )
               Loop
            EndIf
            // Verifica se a invoice foi paga
            If !Empty(SWB->WB_CA_DT)
               SWB->( DBSkip() )
               Loop
            Endif
            // Verifica se a invoice esta vinculada
            If cVinc = "2"
               If EF3->( DBSeek(cFilEF3+"I"+SWB->WB_HAWB+SWB->WB_FORN+SWB->WB_LOJA+SWB->WB_INVOICE+SWB->WB_LINHA) )
                  SWB->( DBSkip() )
                  Loop
               EndIf
            EndIf
            // Verifica se esta dentro do periodo
            If !Empty(dInicial)  .And.  SWB->WB_DT_VEN < dInicial
               SWB->( DBSkip() )
               Loop
            EndIf
            If !Empty(dFinal)  .And.  SWB->WB_DT_VEN > dFinal
               SWB->( DBSkip() )
               Loop
            EndIf
            // Verifica o Banco
            If !Empty(cBanco)  .And.  SWB->WB_BANCO # cBanco
               SWB->( DBSkip() )
               Loop
            EndIf
            // Verifica o Fornecedor
            If !Empty(cCodFor)  .And.  SWB->WB_FORN # cCodFor
               SWB->(DbSkip())
               Loop
            EndIf
            GravaSWB("SWB")
            EEQ->(DbSkip())
         EndDo
      EndIf
   //**
   Next

#ENDIF

Work->(DBSETORDER(1))

RETURN .T.


*---------------------------------*
Static Function GravaSWB(cAliasSWB)
*---------------------------------*
Begin Sequence

   // Verifica se a invoice esta vinculada
   If cVinc = "2"
      If EF3->( DBSeek(cFilEF3+"I"+(cAliasSWB)->WB_HAWB+(cAliasSWB)->WB_FORN+(cAliasSWB)->WB_LOJA+(cAliasSWB)->WB_INVOICE+(cAliasSWB)->WB_LINHA) )
         Break
      EndIf
   EndIf


   If cModo = "1"   // Analítico
      // Grava na Work
      Work->(RecLock("Work",.T.))
      Work->EEQ_FILIAL := (cAliasSWB)->WB_FILIAL
      Work->TPMODU := "I"
      Work->EEQ_BANC   := (cAliasSWB)->WB_BANCO
      Work->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6")+(cAliasSWB)->WB_BANCO+(cAliasSWB)->WB_AGENCIA+(cAliasSWB)->WB_CONTA,"A6_NOME")
      Work->EEQ_NRINVO := (cAliasSWB)->WB_INVOICE
      Work->EEQ_PARC   := (cAliasSWB)->WB_LINHA
      Work->EEQ_VCT    := (cAliasSWB)->WB_DT_VEN
      Work->EEQ_VL     := (cAliasSWB)->WB_FOBMOE
      Work->EEQ_PREEMB := (cAliasSWB)->WB_HAWB
      Work->EEC_IMPORT := (cAliasSWB)->WB_FORN
      Work->EEC_IMPODE := Posicione("SA2",1,xFilial("SA2")+(cAliasSWB)->WB_FORN,"A2_NOME")
      Work->EEC_IMLOJA := (cAliasSWB)->WB_LOJA
      Work->EEC_MOEDA  := (cAliasSWB)->WB_MOEDA
   Else		// Sintético
      Work->( DBSetOrder(2))
      If !Work->( DBSeek("I"+(cAliasSWB)->WB_FILIAL+(cAliasSWB)->WB_BANCO+(cAliasSWB)->WB_MOEDA) )
         Work->(RecLock("Work",.T.))
         Work->EEQ_FILIAL := (cAliasSWB)->WB_FILIAL
         Work->EEQ_BANC   := (cAliasSWB)->WB_BANCO
         Work->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6")+(cAliasSWB)->WB_BANCO+(cAliasSWB)->WB_AGENCIA+(cAliasSWB)->WB_CONTA,"A6_NOME")
      Else
         Work->(RecLock("Work",.F.))
         Work->EEQ_FILIAL := (cAliasSWB)->WB_FILIAL
      Endif
      Work->TPMODU := "I"
      Work->EEC_MOEDA  := (cAliasSWB)->WB_MOEDA
      Work->EEQ_VL     += (cAliasSWB)->WB_FOBMOE
   Endif

End Sequence

Return Nil

*---------------------------------*
Static Function GravaEEQ(cAliasEEQ)
*---------------------------------*

Begin Sequence

   If cVinc = "2"
      // PLB 01/05/06
      If lEFFTpMod
         If EF3->(DbSeek(cFilEF3+"E"+(cAliasEEQ)->EEQ_NRINVO+(cAliasEEQ)->EEQ_PARC)) .Or. EF3->(DbSeek(cFilEF3+"I"+(cAliasEEQ)->EEQ_NRINVO+(cAliasEEQ)->EEQ_PARC))
            Break
         EndIf
      ElseIf EF3->(DbSeek(cFilEF3+(cAliasEEQ)->EEQ_NRINVO+(cAliasEEQ)->EEQ_PARC))
         Break
      EndIf
   Endif
   If cModo = "1"   // Analítico
      // Grava na Work
      Work->(RecLock("Work",.T.))
      Work->EEQ_FILIAL := (cAliasEEQ)->EEQ_FILIAL
      If lTPCONExt  .And.  lEFFTpMod
         If (cAliasEEQ)->EEQ_TP_CON $ "1/3"  // Exportacao
            Work->TPMODU := "E"
         ElseIf (cAliasEEQ)->EEQ_TP_CON $ "2/4"  // Importacao
            Work->TPMODU := "I"
         EndIf
      EndIf
      Work->EEQ_BANC   := (cAliasEEQ)->EEQ_BANC
      Work->EEQ_NOMEBC := (cAliasEEQ)->EEQ_NOMEBC
      Work->EEQ_NRINVO := (cAliasEEQ)->EEQ_NRINVO
      Work->EEQ_PARC   := (cAliasEEQ)->EEQ_PARC
      Work->EEQ_VCT    := (cAliasEEQ)->EEQ_VCT
      Work->EEQ_VL     := (cAliasEEQ)->EEQ_VL
      Work->EEQ_PREEMB := (cAliasEEQ)->EEQ_PREEMB
      Work->EEC_IMPORT := (cAliasEEQ)->EEQ_IMPORT
      Work->EEC_IMPODE := Posicione("SA1",1,xFilial("SA1")+(cAliasEEQ)->EEQ_IMPORT,"A1_NOME")
      Work->EEC_IMLOJA := (cAliasEEQ)->EEQ_IMLOJA
      Work->EEC_MOEDA  := IIF(Find_moeda==.t.,(cAliasEEQ)->EEQ_MOEDA,iif(EEC->(EOF()),"",EEC->EEC_MOEDA)) //CONSISTENCIA PARA CONSIDERAR A MOEDA
   Else						// Sintético
      Work->(DbSetOrder(2))
      If  !Work->(Dbseek(IIF(lEFFTpMod,"E","")+(cAliasEEQ)->EEQ_FILIAL+(cAliasEEQ)->EEQ_BANC+IIF(Find_moeda==.t.,(cAliasEEQ)->EEQ_MOEDA,iif(EEC->(EOF()),"",EEC->EEC_MOEDA))))  ;
          .And. !Work->(Dbseek(IIF(lEFFTpMod,"I","")+(cAliasEEQ)->EEQ_FILIAL+(cAliasEEQ)->EEQ_BANC+IIF(Find_moeda==.t.,(cAliasEEQ)->EEQ_MOEDA,iif(EEC->(EOF()),"",EEC->EEC_MOEDA))))
         Work->(RecLock("Work",.T.))
         Work->EEQ_FILIAL := (cAliasEEQ)->EEQ_FILIAL
         Work->EEQ_BANC   := (cAliasEEQ)->EEQ_BANC
         Work->EEQ_NOMEBC := (cAliasEEQ)->EEQ_NOMEBC
      Else
         Work->(RecLock("Work",.F.))
         Work->EEQ_FILIAL := (cAliasEEQ)->EEQ_FILIAL
      Endif
      If lTPCONExt  .And.  lEFFTpMod
         If (cAliasEEQ)->EEQ_TP_CON $ "1/3"  // Exportacao
            Work->TPMODU := "E"
         ElseIf (cAliasEEQ)->EEQ_TP_CON $ "2/4"  // Importacao
            Work->TPMODU := "I"
         EndIf
      EndIf
      Work->EEC_MOEDA  := IIF(Find_moeda==.t.,(cAliasEEQ)->EEQ_MOEDA,iif(EEC->(EOF()),"",EEC->EEC_MOEDA)) //CONSISTENCIA PARA CONSIDERAR A MOEDA
      Work->EEQ_VL     += (cAliasEEQ)->EEQ_VL
   Endif

End Sequence

Return Nil

*-------------------------*
Static Function GeraRel()
*-------------------------*
Local aRCampos     := {}
Private lInvTrans  := .F., cBancoAtu := "XXX", aTotalBanco := {}, aTotalGer := {} , aTotalVCT := {},Fil_sub:={}, FilAtu:="-",TotalFil:={},GraTotFil:={},filial_n:={}
Private dDataAtu   := CTOD(' /  /')
Private cTpModuAtu := "-" , aTotalTpModu := {}
Private cCliAtu := "XXX"
Private aTotalCli := {}
Private TB_Campos    := {}
Private dDataAtuBase
Private cCliBase
Private nInvoice

PRIVATE aDados := {"Work",;
                   STR0003,; //"Este programa tem como objetivo imprimir relatório de acordo com os parâmetros informados pelo usuário."
                   STR0004,;  //"Posição de Carteira em Aberto considerando ou não , as invoices  vinculadas"
                   "",;
                   "M",;
                    132,;
                   "                                                " + If(cVinc='2', STR0005,"C") + STR0006,; //"Não c"###"onsiderando invoices vinculadas"
                   "",;
                   STR0007 + If(cModo='1', STR0008, STR0009) + STR0010+DTOC(dInicial)+ STR0011 + DTOC(dFinal) , ; //"Posição de Carteira em Aberto "###"(Analitico)"###"(Sintetico)"###" - Periodo: "###" Ate "
                   { "Zebrado", 1,"Contabil", 1, 2, 1, "",1 },;
                   "EFFPC150",;
                   { {||AcumTotais()} , {||ImpTotais()} }  }

If cModo = "1"   // Analitico

   AADD(TB_Campos,{{ || PadR(Work->EEQ_NRINVO , 20 , " " ) }          ,"L" , STR0012     } )  //"INVOICE"
   AADD(TB_Campos,{{ || PadR(Work->EEQ_PARC   , 02 , " " ) }          ,"L" , STR0013     } )  //"PARCELA"
   AADD(TB_Campos,{{ || PadR(Work->EEC_MOEDA  , 06 , " " ) }          ,"C" , STR0014     } )  //"MOEDA"
   AADD(TB_Campos,{{ || TRANSF(Work->EEQ_VL, AVSX3("EEQ_VL",6 ) )}    ,"D" , STR0015     } )  //"VALOR"
   AADD(TB_Campos,{{ || PadR(Work->EEQ_PREEMB , 20 , " " ) }          ,"L" , STR0016     } )  //"PROCESSO"
   IF cQuebra = "1"
      AADD(TB_Campos,{{ || PadR(Work->EEC_IMPORT, 06 , " " ) + " " + PadR(Work->EEC_IMPODE, 60 , " ") }        ,"L" , STR0017     } ) //"CLIENTE"
      AADD(TB_Campos,{{ ||Work->EEC_IMLOJA }        ,"L" , "LOJA"     } )   // PLB 09/05/06
   Else
      AADD(TB_Campos,{{ ||DTOC(Work->EEQ_VCT)  }        ,"L" , AVSX3("EEQ_VCT",5 )     } ) //"Data Vencto"
   EndIf

Else    // Sintético

   AADD(TB_Campos,{{ || PadR(Work->EEQ_BANC   , 03 , " " )  + " - " + PadR(Work->EEQ_NOMEBC , 40 , " " )  }      ,"L" , STR0018    } ) //"BANCO"
   AADD(TB_Campos,{{ || PadR(Work->EEC_MOEDA  , 06 , " " )   }            					  ,"C" , STR0014    } )  //"MOEDA"
   AADD(TB_Campos,{{ ||TRANSF(Work->EEQ_VL,      AVSX3("EEQ_VL",6 ))}    ,"D" , STR0015    } ) //"VALOR"

Endif

If !lMultiFil
   FilAtu := "  "
EndIf

aRCampos:= E_CriaRCampos(TB_CAMPOS)

E_Report(aDados,aRCampos)

RETURN .T.

*--------------------------*
Static Function AcumTotais()
*--------------------------*
Local nPosBanco , nPosGer , nPosVCT, i
Local nPosTpModu  // PLB 09/05/06

private aSomaVCT := 0

//** PLB 09/05/06 - Quebra por Tipo de Modulo
If lEFFTpMod  .And. cTpModuAtu # Work->TPMODU .And. cTpModuAtu=="-"
   PulaLinha()
   @ Linha, 000 PSAY Repli("*", 132)
   PulaLinha()
   @ Linha, 001 PSAY "Modulo: " + IIF(Work->TPMODU=="E","Exportação","Importacao")
   cTpModuAtu   := Work->TPMODU
   aTotalTpModu := {}
EndIf
//**

//Alcir - 18-12-04  - tratamento de multifilial
//quebra a cada filial
//begincomm 03
if lMultiFil .AND. FilAtu#Work->EEQ_filial .and. FilAtu="-" //AAF 10/01/05 - Verifica se o ambiente é multifilial.
   //Linha := 99
   PulaLinha()
   @ Linha, 000 PSAY Repli("*", 132)
   PulaLinha()

   filial_n:=AvgFilName({Work->EEQ_FILIAL})
   @ Linha,00 PSAY STR0032+" "+PadR(Work->EEQ_FILIAL,03," ")+" - "+filial_n[1]  //"Filial : "
   TotalFil:={}
   PulaLinha()
   @ Linha, 000 PSAY Repli("*", 132)
   PulaLinha()
   FilAtu:=Work->EEQ_filial
   cBancoAtu="-"
   lPrimFil:=.F.
ENDIF

If cModo = "1"  // Analitico
   // Data de Vencimento
   If cQuebra = "1" //Data
      If dDataAtu # Work->EEQ_VCT .or. FilAtu#Work->EEQ_filial .Or. (cBancoAtu # Work->EEQ_BANC .and. cBancoAtu<>"XXX" .AND. cModo = "1") .Or. IIF(lEFFTpMod,cTpModuAtu#Work->TPMODU,.F.)
         // Imprime Total da Data de Vencimento
         IIf(!empty(dDataAtu),dDataAtubase := dDataAtu,)
         If !Empty(aTotalVCT) .and. (IIF(dDataAtuBase!=Work->EEQ_VCT,;
                                        (dDataAtuBase!=Work->EEQ_VCT),;
                                        (nInvoice!=Work->EEQ_NRINVO ))) // **JVR** - 02/02/09 condição p/ não pular se data for igual
            PulaLinha()
     	      @ Linha, 000 PSAY Repli("-", 132)
            PulaLinha()
     	      @ Linha, 010 PSAY STR0019 //"TOTAL DIA :"
   	      for i:= 1 to len (aTotalVCT)
               Begin Sequence // **JVR** - 02/02/09 condição p/ mostrar valor total de acordo com DT.VENCTO.
                  If (i == len (aTotalVCT)) .and. (i != 1)
                     aSomaVCT += aTotalVCT[i,2]
                     Break
                  EndIf
                     aSomaVCT += aTotalVCT[i,2]
                     @ Linha, 026 PSAY aTotalVCT[i,1]
                     @ Linha, 040 PSAY TRANS(aSomaVCT,AVSX3("EEQ_VL",6 ))
                     PulaLinha(STR0019)  //"TOTAL DIA :"
               End Sequence
            next
            PulaLinha()
            dDataAtu := CToD("  /  /  ")  // PLB - 09/05/06
         Else        // **JVR** - 02/02/09
            dDataAtu := CToD("  /  /  ")
         Endif
      EndIf
   Else
      If cCliAtu # Work->EEC_IMPORT .or. FilAtu#Work->EEQ_filial .Or. (cBancoAtu # Work->EEQ_BANC .and. cBancoAtu<>"XXX" .AND. cModo = "1")  .Or. IIF(lEFFTpMod,cTpModuAtu#Work->TPMODU,.F.)
         // Imprime Total do Cliente
         If ! Empty(aTotalCli) .and. cCliBase != Work->EEC_IMPODE//**JVR** - 09/03/09 verifica se quebra linha ou não.
            PulaLinha()
     	      @ Linha, 000 PSAY Repli("-", 132)
            PulaLinha()
     	      @ Linha, 010 PSAY IIF(lEFFTpMod .And. cTpModuAtu=="I","TOTAL FORNEC. :","TOTAL CLIENTE :")
   	      for i:= 1 to len (aTotalCli)
               Begin Sequence // **JVR** - 09/03/09 - condição para agrupar cliente/fornecedor no mesmo total.
                  If (i == len(aTotalCli)) .and. (i != 1)
                     aSomaVCT += aTotalCli[i,2]
                     Break
                  EndIf
                  aSomaVCT += aTotalCli[i,2]
                  @ Linha, 026 PSAY aTotalCli[i,1]
                  @ Linha, 040 PSAY TRANS(aSomaVCT,AVSX3("EEQ_VL",6 ))
                  PulaLinha()
               End Sequence
            next
            PulaLinha()
            cCliAtu := "XXX"
         Else// **JVR** - 09/03/09
            cCliAtu := "XXX"
         Endif
      EndIf
   EndIf
//endcomm 03
Endif


   // Banco
   If  cModo = "1"  .And.  ((cBancoAtu # Work->EEQ_BANC .and. cBancoAtu<>"XXX")  .Or. IIF(lEFFTpMod,cTpModuAtu#Work->TPMODU,.F.) )
      // Imprime Total do Banco Anterior
      If ! Empty(aTotalBanco)
         PulaLinha()
         @ Linha, 000 PSAY Repli("-", 132)
         PulaLinha()
         @ Linha, 010 PSAY STR0020 //"TOTAL BANCO :"
   	     for i:= 1 to len (aTotalBanco)
            @ Linha, 026 PSAY aTotalBanco[i,1]
            @ Linha, 040 PSAY TRANS(aTotalBanco[i,2],AVSX3("EEQ_VL",6 ))
            PulaLinha(STR0020)  //"TOTAL BANCO :"
         next
         PulaLinha()
         @ Linha, 000 PSAY Repli("-", 132)
         PulaLinha()
      Endif

   Endif

//Alcir - 18-12-04  - tratamento de multifilial
//quebra a cada filial
//begincomm 03
if (lMultiFil .AND. FilAtu#Work->EEQ_filial) .Or. (lEFFTpMod  .And. cTpModuAtu # Work->TPMODU) //AAF 10/01/05 - Verifica se o ambiente é multifilial.
//Alcir - 18-11-04  - tratamento de multifilial
// valor total por filial
//begincomm 04

  If cModo = "1"   // Analitico
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
      filial_n:=AvgFilName({FilAtu})
      If Linha==7
        @ Linha, 000 PSAY " "
        Linha += 1
      EndIf
      @ Linha,00 PSAY  STR0033+" "+FilAtu+" - "+filial_n[1]  //"Total Filial : "
      PulaLinha()
      for i:= 1 to len (TotalFil) //TOTAL POR FILial moeda
         @ Linha, 39 PSAY TotalFil[i,1]
         @ Linha, 46 PSAY TRANS(TotalFil[i,2],AVSX3("EEQ_VL",6 ))
         PulaLinha()
      next
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
  endif

   //linha:=99
   //PulaLinha()
EndIf

//** PLB 09/05/06 - Quebra por Tipo de Modulo
If lEFFTpMod  .And. cTpModuAtu # Work->TPMODU
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
      @ Linha,00 PSAY  "TOTAL "+IIF(cTpModuAtu=="E","EXPORTACAO","IMPORTACAO")
      for i:= 1 to len (aTotalTpModu)
         @ Linha, 39 PSAY aTotalTpModu[i,1]
         @ Linha, 46 PSAY TRANS(aTotalTpModu[i,2],AVSX3("EEQ_VL",6 ))
         PulaLinha()
      next
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
      cTpModuAtu := "-"  // PLB - 09/05/06
EndIf
//**

If (lMultiFil .AND. FilAtu#Work->EEQ_filial) .Or. (lEFFTpMod  .And. cTpModuAtu # Work->TPMODU) //AAF 10/01/05 - Verifica se o ambiente é multifilial.
   PC150IMPCAB() //AAF 10/01/05 - Imprime cabeçalho.
   PulaLinha()
EndIf

//** PLB 09/05/06 - Quebra por Tipo de Modulo
If lEFFTpMod  .And. cTpModuAtu # Work->TPMODU
   PulaLinha()
   @ Linha, 000 PSAY Repli("*", 132)
   PulaLinha()
   @ Linha, 001 PSAY "Modulo: " + IIF(Work->TPMODU=="E","Exportação","Importacao")
   PulaLinha()
   aTotalTpModu := {}
   cBancoAtu  := "-"
EndIf
//**

If (lMultiFil .AND. FilAtu#Work->EEQ_filial ) .Or. (lEFFTpMod  .And. cTpModuAtu # Work->TPMODU) //AAF 10/01/05 - Verifica se o ambiente é multifilial.

   filial_n:=AvgFilName({Work->EEQ_FILIAL})
   @ Linha, 000 PSAY Repli("*", 132)
   PulaLinha()
   @ Linha,00 PSAY STR0032+" "+PadR(Work->EEQ_FILIAL,03," ")+" - "+filial_n[1]  //"Filial : "
   TotalFil:={}
   PulaLinha()
   @ Linha, 000 PSAY Repli("*", 132)
   PulaLinha()
   cTpModuAtu   := Work->TPMODU
   FilAtu:=Work->EEQ_filial
   cBancoAtu="-"
   lPrimFil:=.F.
ENDIF
//endcomm 03

If cModo = "1"  // Analitico
      If cBancoAtu # Work->EEQ_BANC
         PulaLinha()
         @ Linha, 000 PSAY Repli("-", 132)
         PulaLinha()
         @ Linha, 001 PSAY STR0021 + PadR(Work->EEQ_BANC,03," ") + " - "  + PadR(Work->EEQ_NOMEBC,40," ") //"BANCO : "
         PulaLinha()
         cBancoAtu   := Work->EEQ_BANC
         aTotalBanco := {}
      Endif
      If (cQuebra = "1"  .And.  dDataAtu # Work->EEQ_VCT)
         If (IIf(dDataAtuBase!=Work->EEQ_VCT,;
                (dDataAtuBase!=Work->EEQ_VCT),;
                IIf(nInvoice!=Work->EEQ_NRINVO,.T.,.F.) )) // **JVR** - 02/02/09 não cria novamente se for a mesma data e invoice.
            @ Linha, 001 PSAY ""
            PulaLinha()
            @ Linha, 001 PSAY STR0022 + TRANS(Work->EEQ_VCT, AVSX3("EEQ_VCT",6 )) //"DT.VENCTO. : "
            PulaLinha()
            dDataAtu    := Work->EEQ_VCT
            aTotalVCT := {}
         EndIf
      ElseIf (cQuebra="2" .And. cCliAtu # Work->EEC_IMPORT)
            @ Linha, 001 PSAY ""
            PulaLinha()
            @ Linha, 001 PSAY IIF(lEFFTpMod .And. Work->TPMODU=="I","FORNEC. : ","CLIENTE : ") + Work->EEC_IMPODE
            PulaLinha()
            cCliBase := Work->EEC_IMPODE
            cCliAtu  := Work->EEC_IMPORT
            aTotalCli:= {}
      EndIf
Endif


//Alcir - 18-12-04  - tratamento de multifilial
//TOTAL POR MOEDA E banco
If lMultiFil //AAF 10/01/05 - Verifica se o ambiente é multifilial.
   nPosBanco := ASCAN(TotalFil,{ |x| x[1] = Work->EEC_MOEDA })
   if nPosBanco = 0
      AADD(TotalFil,{Work->EEC_MOEDA,Work->EEQ_VL})
   else
      TotalFil[nPosBanco,2] += Work->EEQ_VL
   endif
Endif


//Alcir - 18-12-04  - tratamento de multifilial
//TOTAL POR MOEDA E FILIAL
If lMultiFil //AAF 10/01/05 - Verifica se o ambiente é multifilial.
   nPosBanco := ASCAN(GraTotFil,{ |x| x[1]=FilAtu .AND. x[2] = Work->EEC_MOEDA})
   if nPosBanco = 0
      AADD(GraTotFil,{FilAtu,Work->EEC_MOEDA,Work->EEQ_VL})
   else
      GraTotFil[nPosBanco,3] += Work->EEQ_VL
   endif
Endif


// Acumula Total por Banco e Geral
nPosVCT := ASCAN(aTotalVCT,{ |x| x[1] = Work->EEC_MOEDA })
if nPosVCT = 0
   AADD(aTotalVCT,{Work->EEC_MOEDA,Work->EEQ_VL})
else
   aTotalVCT[nPosVCT,2] += Work->EEQ_VL
endif

nPosCli := ASCAN(aTotalCli,{ |x| x[1] = Work->EEC_MOEDA })
if nPosCli = 0
   AADD(aTotalCli,{Work->EEC_MOEDA,Work->EEQ_VL})
else
   aTotalCli[nPosCli,2] += Work->EEQ_VL  // PLB 09/05/06
   //aTotalVCT[nPosCli,2] += Work->EEQ_VL
endif

//**  PLB 09/05/06 - Totais por Modulo
If lEFFTpMod
   nPosTpModu := ASCAN(aTotalTpModu,{ |x| x[1] = Work->EEC_MOEDA })
   if nPosTpModu = 0
      AADD(aTotalTpModu,{Work->EEC_MOEDA,Work->EEQ_VL})
   else
      aTotalTpModu[nPosTpModu,2] += Work->EEQ_VL
   endif
EndIf
//**

nPosBanco := ASCAN(aTotalBanco,{ |x| x[1] = Work->EEC_MOEDA })
if nPosBanco = 0
   AADD(aTotalBanco,{Work->EEC_MOEDA,Work->EEQ_VL})
else
   aTotalBanco[nPosBanco,2] += Work->EEQ_VL
endif

nPosGer := ASCAN(aTotalGer,{ |x| x[1] = Work->EEC_MOEDA })
if nPosGer = 0
   AADD(aTotalGer,{Work->EEC_MOEDA,Work->EEQ_VL})
else
   aTotalGer[nPosGer,2] += Work->EEQ_VL
endif

nInvoice := Work->EEQ_NRINVO

RETURN .T.

*---------------------------*
Static Function ImpTotais()
*---------------------------*
Local i

// Imprime Total do Banco Anterior
If cModo = "1"    // Analitico
   If cQuebra = "1"  // PLB 09/05/06 - Verifica tipo de quebra
      If ! Empty(aTotalVCT)
            PulaLinha()
     	    @ Linha, 000 PSAY Repli("-", 132)
            PulaLinha()
        	 @ Linha, 010 PSAY STR0019 //"TOTAL DIA :"
      	     for i:= 1 to len (aTotalVCT)
                 @ Linha, 026 PSAY aTotalVCT[i,1]
                 @ Linha, 040 PSAY TRANS(aTotalVCT[i,2],AVSX3("EEQ_VL",6 ))
                 PulaLinha(STR0019)  //"TOTAL DIA :"
            next
            PulaLinha()
      Endif
   Else
      //** PLB 09/05/06 - Caso quebra seja por cliente
      If !Empty(aTotalCli)
         PulaLinha()
     	   @ Linha, 000 PSAY Repli("-", 132)
         PulaLinha()
        	@ Linha, 010 PSAY IIF(lEFFTpMod .And. cTpModuAtu=="I","TOTAL FORNEC.:","TOTAL CLIENTE:")
      	For i:= 1 to len (aTotalCli)
            @ Linha, 026 PSAY aTotalCli[i,1]
            @ Linha, 040 PSAY TRANS(aTotalCli[i,2],AVSX3("EEQ_VL",6 ))
            PulaLinha("TOTAL CLIENTE")
         Next
         PulaLinha()
      Endif
      //**
   EndIf

   If ! Empty(aTotalBanco)
      PulaLinha()
      @ Linha, 000 PSAY Repli("-", 132)
      PulaLinha()
      @ Linha, 010 PSAY STR0020 //"TOTAL BANCO :"
   	for i:= 1 to len (aTotalBanco)
         @ Linha, 026 PSAY aTotalBanco[i,1]
         @ Linha, 040 PSAY TRANS(aTotalBanco[i,2],AVSX3("EEQ_VL",6 ))
         PulaLinha(STR0020)  //"TOTAL BANCO :"
      next
         PulaLinha()
         @ Linha, 000 PSAY Repli("-", 132)
         PulaLinha()
   Endif

   If lMultiFil //AAF 10/01/05 - Verifica se o ambiente é multifilial.
      //TOTAL FILIAL
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
      filial_n:=AvgFilName({FilAtu})
      @ Linha,00 PSAY  STR0033+" "+FilAtu+" - "+filial_n[1]  //"Total Filial : "
      PulaLinha()
      for i:= 1 to len (TotalFil) //TOTAL POR FILial moeda
         @ Linha, 39 PSAY TotalFil[i,1]
         @ Linha, 46 PSAY TRANS(TotalFil[i,2],AVSX3("EEQ_VL",6 ))
         PulaLinha()
      next
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
   Endif

Endif

   //** PLB 09/05/06 - Total por Modulo
   If lEFFTpMod  .And.  !Empty(aTotalTpModu)
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
      @ Linha, 000 PSAY "TOTAL "+IIF(cTpModuAtu=="E","EXPORTACAO","IMPORTACAO")
   	For i:= 1 to len (aTotalTpModu)
         @ Linha, 039 PSAY aTotalTpModu[i,1]
         @ Linha, 046 PSAY TRANS(aTotalTpModu[i,2],AVSX3("EEQ_VL",6 ))
         PulaLinha("TOTAL MODULO:")
      Next
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 132)
      PulaLinha()
   Endif
   //**



   If lMultiFil //AAF 10/01/05 - Verifica se o ambiente é multifilial.
      // Total Geral filial

      // Alcir - 18-12-04  - tratamento de multifilial
      //linha:=99
      //PulaLinha()
      //PC150IMPCAB() //AAF 10/01/05 - Imprime cabeçlho.
      //PulaLinha()
      //** PLB 09/05/06
      LINHA := 0
      Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
      Linha++
      //**
      @Linha, 000 PSAY Repli("-", 132)
      PulaLinha()
      @Linha, 000 PSAY STR0033
      PulaLinha()
      fil_at_tot:="-"
      for i=1 to len(GraTotFil)
         if fil_at_tot#GraTotFil[i,1]
            filial_n:=AvgFilName({GraTotFil[i,1]})
            fil_at_tot:=GraTotFil[i,1]
            @Linha, 000 PSAY GraTotFil[i,1]+"-"+filial_n[1]
         endif
         @Linha, 039 PSAY oemtoansi(GraTotFil[i,2])
         @Linha, 046 PSAY TRANS(GraTotFil[i,3],AVSX3("EEQ_VL",6 ))
         PulaLinha()
      next
      @Linha, 000 PSAY Repli("-", 132)
      PulaLinha()
   Endif

   PulaLinha()
   @Linha, 000 PSAY Repli("-", 132)
   PulaLinha()
   @ Linha, 010 PSAY STR0023 //"TOTAL GERAL :"
   for i:= 1 to len (aTotalGer)
      @ Linha, If(cModo = '1', 035, 047) PSAY aTotalGer[i,1]                           //AAF 10/01/05 - Acerto na Impressão
      @ Linha, If(cModo = '1', 042, 054) PSAY TRANS(aTotalGer[i,2],AVSX3("EEQ_VL",6 )) //AAF 10/01/05 - Acerto na Impressão
      PulaLinha(STR0023) //"TOTAL GERAL :"
   next
   PulaLinha()
   @Linha, 000 PSAY Repli("-", 132)
   PulaLinha()
Return .T.

*-------------------------------*
Static Function PulaLinha(cTexto)
*-------------------------------*
IF(valtype(cTexto) = "U", cTexto:="",.T.)
IF Linha >= 55
   Linha := 0
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   If ! Empty(cTexto)
     Linha += 1
     @ Linha, 010 PSAY cTexto
   EndIf
Else
   Linha++
Endif
Return .T.
*------------------------*
Static Function CriaWork()
*------------------------*
Private aHeader[0],aCampos := {}
PRIVATE aEstru := {}

// Cria Work
// PLB 09/05/06
If lEFFTpMod
AADD(aEstru,{ "EEQ_FILIAL" , "C" , AVSX3("EEQ_FILIAL",3) , 0  })
   AADD(aEstru,{ "TPMODU"     , "C" , 01, 0  })
   AADD(aEstru,{ "EEQ_BANC"   , "C" , Max(AVSX3("EEQ_BANC"  ,3),AVSX3("WB_BANCO"  ,3)), 0 })
   AADD(aEstru,{ "EEQ_NOMEBC" , "C" , Max(AVSX3("EEQ_NOMEBC",3),AVSX3("WB_DES_BCO",3)), 0 })
   AADD(aEstru,{ "EEQ_NRINVO" , "C" , Max(AVSX3("EEQ_NRINVO",3),AVSX3("WB_INVOICE",3)), 0 })
   AADD(aEstru,{ "EEQ_PARC"   , "C" , Max(AVSX3("EEQ_PARC"  ,3),AVSX3("WB_LINHA"  ,3)), 0 })
   AADD(aEstru,{ "EEQ_VCT"    , "D" , 08, 0  })
   AADD(aEstru,{ "EEQ_VL"     , "N" , Max(AVSX3("EEQ_VL"    ,3),AVSX3("WB_FOBMOE" ,3)), Max(AVSX3("EEQ_VL"    ,4),AVSX3("WB_FOBMOE" ,4)) })
   AADD(aEstru,{ "EEQ_PREEMB" , "C" , Max(AVSX3("EEQ_PREEMB",3),AVSX3("WB_HAWB"   ,3)), 0 })
   AADD(aEstru,{ "EEC_IMPORT" , "C" , Max(AVSX3("EEC_IMPORT",3),AVSX3("WB_FORN"   ,3)), 0 })
   AADD(aEstru,{ "EEC_IMPODE" , "C" , AVSX3("EEC_IMPODE",3) , 0  })
   AADD(aEstru,{ "EEC_IMLOJA" , "C" , Max(AVSX3("EEC_IMLOJA",3),AVSX3("WB_LOJA"   ,3)), 0 })
   AADD(aEstru,{ "EEC_MOEDA"  , "C" , AVSX3("EEC_MOEDA" ,3) , 0  })
Else
   AADD(aEstru,{ "EEQ_FILIAL" , "C" , 03, 0  })
   AADD(aEstru,{ "EEQ_BANC"   , "C" , 03, 0  })
   AADD(aEstru,{ "EEQ_NOMEBC" , "C" , 40, 0  })
   AADD(aEstru,{ "EEQ_NRINVO" , "C" , 20, 0  })
   AADD(aEstru,{ "EEQ_PARC"   , "C" , 02, 0  })
   AADD(aEstru,{ "EEQ_VCT"    , "D" , 08, 0  })
   AADD(aEstru,{ "EEQ_VL"     , "N" , 15, 2  })
   AADD(aEstru,{ "EEQ_PREEMB" , "C" , 20, 0  })
   AADD(aEstru,{ "EEC_IMPORT" , "C" , 06, 0  })
   AADD(aEstru,{ "EEC_IMPODE" , "C" , 40, 0  })
   AADD(aEstru,{ "EEC_IMLOJA" , "C" , 06, 0  })
   AADD(aEstru,{ "EEC_MOEDA"  , "C" , 06, 0  })
EndIf

If Select("Work") > 0
   Work->( DBCloseArea() )
EndIf
cNomeArqA:=E_CriaTrab(,aEstru,"Work")
IndRegua("Work",cNomeArqA+TEOrdBagExt(),IIF(lEFFTpMod,"TPMODU+","")+"EEQ_FILIAL+EEQ_BANC+DTOS(EEQ_VCT)+EEQ_NRINVO")
cNomeArqB  := CRIATRAB(,.F.)
INDREGUA("Work",cNomeArqB+TEOrdBagExt(),IIF(lEFFTpMod,"TPMODU+","")+"EEQ_FILIAL+EEQ_BANC+EEC_MOEDA")
cNomeArqC  := CRIATRAB(,.F.)
INDREGUA("Work",cNomeArqC+TEOrdBagExt(),IIF(lEFFTpMod,"TPMODU+","")+"EEQ_FILIAL+EEQ_BANC+EEC_IMPORT")

Set Index to (cNomeArqA+TEOrdBagExt()),(cNomeArqB+TEOrdBagExt()),(cNomeArqC+TEOrdBagExt())


Return

*--------------------------------*
Function EFFPC150VAL(cCampo,cPerg)     //LRL 23/12/2003
*--------------------------------*
Local lRet:=.T.

IF(valtype(cCampo) = "U", cCampo:="",.T.)

If cCampo == "BANCO" .OR. Empty(cCampo)
    If !Empty(cPerg) .And. !ExistCpo("SA6", cPerg)
      lRet:=.F.
    EndIf

ElseIf cCampo == "DATAINICIAL" .OR. Empty(cCampo)
   /** **JVR** - 02/02/09
                Modificado a forma de analise, para que não ocorra o auto preenchimento. */
   If Empty(IIF(lEFFTpMod,mv_par03,mv_par02)) .and. Empty(IIF(lEFFTpMod,mv_par04,mv_par03))
      If !E_Periodo_OK("","")
         lRet := .F.
      EndIf
   ElseIf Empty(IIF(lEFFTpMod,mv_par03,mv_par02)) .and. !Empty(IIF(lEFFTpMod,mv_par04,mv_par03))
      If !E_Periodo_OK("", @IIF(lEFFTpMod,mv_par04,mv_par03))
         lRet := .F.
      EndIf
   ElseIf !Empty(IIF(lEFFTpMod,mv_par03,mv_par02)) .and. Empty(IIF(lEFFTpMod,mv_par04,mv_par03))
      If !E_Periodo_OK(@IIF(lEFFTpMod,mv_par03,mv_par02), "")
         lRet := .F.
      EndIf
   Else
      If !E_Periodo_OK(@IIF(lEFFTpMod,mv_par03,mv_par02),@IIF(lEFFTpMod,mv_par04,mv_par03))
        lRet := .F.
      EndIf
   EndIf
   //**
ElseIf cCampo == "DATAFINAL".OR. Empty(cCampo)
   /** **JVR** - 02/02/09
                Modificado a forma de analise, para que não ocorra o auto preenchimento. */
   If Empty(IIF(lEFFTpMod,mv_par03,mv_par02)) .and. Empty(IIF(lEFFTpMod,mv_par04,mv_par03))
      If !E_Periodo_OK("","")
         lRet := .F.
      EndIf
   ElseIf Empty(IIF(lEFFTpMod,mv_par03,mv_par02)) .and. !Empty(IIF(lEFFTpMod,mv_par04,mv_par03))
      If !E_Periodo_OK("", @IIF(lEFFTpMod,mv_par04,mv_par03))
         lRet := .F.
      EndIf
   ElseIf !Empty(IIF(lEFFTpMod,mv_par03,mv_par02)) .and. Empty(IIF(lEFFTpMod,mv_par04,mv_par03))
      If !E_Periodo_OK(@IIF(lEFFTpMod,mv_par03,mv_par02), "")
         lRet := .F.
      EndIf
   Else
      If !E_Periodo_OK(@IIF(lEFFTpMod,mv_par03,mv_par02),@IIF(lEFFTpMod,mv_par04,mv_par03))
        lRet := .F.
      EndIf
   EndIf
   //**
ElseIf cCampo == "CLIENTE" .OR. Empty(cCampo)

    If !Empty(cPerg) .And. !ExistCpo("SA1", cPerg)
      lRet:=.F.
    EndIf

EndIf
RETURN lRet


//AAF 10/01/05 - Imprime o Cabeçalho de acordo com o array TB_Campos.
//             - Necessário para a quebra de pagina forçada.
*---------------------------*
Static Function PC150IMPCAB()
*---------------------------*
Local i
LINHA := 0
Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
Linha++

cCab := ""
cCab2:= ""
For i:= 1 To Len(TB_Campos)
   cCab += Space(1) //Espaçamento entre as colunas
   cCab2+= Space(1) //Espaçamento entre as colunas
   // PLB 09/05/06 - Altera cabecalho de acordo com o modulo
   If TB_Campos[i][3] $ "CLIENTE"  .And.  lEFFTpMod  .And.  cModo = "1"  .And.  cQuebra = "1"  .And.  Work->TPMODU == "I"
      R_Campos[6,2]:= "FORNECEDOR"   // Altera variavel de cabecalho do E_Report
      cCab += "FORNECEDOR" + Space(Len( Eval(TB_Campos[i][1])) - Len("FORNECEDOR"))
      cCab2+= Replicate("=",Max(Len(Eval(TB_Campos[i][1])),Len("FORNECEDOR")))
   Else
      cCab += TB_Campos[i][3] + Space(Len( Eval(TB_Campos[i][1])) - Len(TB_Campos[i][3]))
      cCab2+= Replicate("=",Max(Len(Eval(TB_Campos[i][1])),Len(TB_Campos[i][3])))
   EndIf
Next

@ LINHA++, 000 PSAY Left(cCab ,aDados[6])
@ LINHA++, 000 PSAY Left(cCab2,aDados[6])

Return .T.
