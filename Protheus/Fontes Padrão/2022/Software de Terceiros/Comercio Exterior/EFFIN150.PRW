#INCLUDE "EFFIN150.ch"
#include "Average.ch"

//Revisão : Alcir    - 18-12-04
//Revisão : Alcir    - 07-12-05   - considerar apenas eventos do tipo 1 EEQ_TP_CON, desconsiderar dados do EEC quando não houver processo
//Revisão : Henrique - 28-04-06   - imprimir invoices EEQ e do SWB con validações dos novos campos, quebra, e filtros por Imp/Exp, Não Liquidadas e Tipo do Contrato //HVR
//tratamento com o conceito de multifilial
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EFFINV150 ³ Autor ³ Lucas R. R. Lopes  ³ Data ³ 08/12/03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio DE POSICAO DE INVOICES NAO VINCULADAS            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***************************
Function EFFIN150()
***************************

   EFFIN150R3(.T.)

Return .T.

*-------------------------*
Function EFFIN150R3(p_R4)
*-------------------------*

LOCAL cAliasOld := Alias()
LOCAL cTit   := STR0001 //"Posição de Invoices Não Vinculadas"
Private oReport
Private oBreak1
Private oBreak2
Private oBreak3
Private lR4 := .F.
Private cNomArq, cNomArq2
Private cFilEEQ := xFilial('EEQ'),cFilEEC:=xFilial('EEC'),cFilEF3:=xFilial('EF3')
Private cFilSA1 := xFilial('SA1'),cFilSA6:=xFilial('SA6'),cFilEF6:=xFilial('EF6')
Private cFilSA2 := xFilial('SA2'),cFilSWB:=xFilial('SWB')  //HVR SA2 E SWB
Private lTPCONExt:=(EEQ->(fieldpos("EEQ_TP_CON"))>0)

Private dInicial
Private dFinal
PRIVATE cBanco
Private cCodCli
Private cModo
Private cNotLiq //HVR
Private cTpCamb //HVR
Private cTpCont //HVR
Private cfilSel:={}
Private lMultiFil := Posicione("SX2",1,"EEQ","X2_MODO") == "E" .AND. VerSenha(115) .and.;
                     Posicione("SX2",1,"EF1","X2_MODO") == "C" //AAF 08/01/05 - Indica se é multifilial.
PRIVATE lExistBCO := iif(EF3->(FieldPos("EF3_BAN_FI")) > 0 .AND. EF3->(FieldPos("EF3_PRACA")) > 0 .AND. EF2->(FieldPos("EF2_BAN_FI")) > 0 .AND. EF2->(FieldPos("EF2_PRACA")) > 0 ,.T.,.F.) //ALCIR ALVES -18-02-05  CASO EXISTA NOVOS CAMPOS DA CHAVE EF1,EF2 E EF3

Private cQryEEQ := ""
Private cQrySWB := ""
//** HVR - 28/04/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EEQ->( FieldPos("EEQ_TP_CON") ) > 0
//** HVR - 28/04/2006
Private aDescr := {}

If p_R4 != NIL  .And.  FindFunction("TRepInUse")  .And.  TRepInUse()
   lR4 := p_R4
EndIf

// Cria Work
CriaWork()  //HVR 01/05/06 - ADICIONADO CAMPO DE FLAG SWBEEQ
cfilSel:=AvgSelectFil(.T.,"EEQ") //Alcir
If !Pergunte("EFFIN1",.T.)
   Work->(DbCloseArea())
   Erase(cNomArq+TEOrdBagExt())
   Erase(cNomArq2+TEOrdBagExt())
   Return .F.
EndIf

cBanco   := mv_par01
dInicial := mv_par02
dFinal   := mv_par03
cCodCli  := IF( !Empty(mv_par04),mv_par04, IIF(lEFFTpMod,mv_par16,Space(Len(mv_par04))))
cModo    := INT(mv_par11)
cNotLiq  := AllTrim(STR(mv_par13)) //HVR
If lEFFTpMod
   cTpCamb  := Alltrim(STR(mv_par14)) //HVR
   cTpCont  := Alltrim(STR(IF(mv_par15=NIL, "",mv_par15)))  //HVR
EndIf

// Grava na Work
//If !lEFFTpMod .Or. cTpCAMB $ ("2/3")
   MsAguarde({ || GrvWork()}, STR0002) //"Lendo Informacoes..."
//EndIf

IF lEFFTpMod //HVR FILTRA SWB SE FINIMP EXISTE
   //IF cTpCamb $ ("1/3")
      MsAguarde({ || GrvWorkSWB()}, STR0002) //HVR "Lendo Informacoes..." //SWB
   //Endif
ENDIF

Work->(DbGotop())
IF Work->(EOF()) .AND. Work->(BOF())
   Msginfo(STR0003) //"Não ha registros disponíveis !!!"
   Work->(DbCloseArea())
Else

   // Imprime Relatorio
   if mv_par12==1 //Alcir Alves - 19-02-05 - destino impressora
      If lR4
         //ReportDef cria os objetos.
         oReport := ReportDef()
         If cModo == 1  //Analitico
            oBreak1 := BreakDef(1)
         EndIf
         If lMultiFil
            oBreak2 := BreakDef(2)
         EndIf
         oBreak3 := BreakDef(3)
         //O Método PrintDialog mostra a tela do relatório para o usuário que confirma a impressão.
         oReport:PrintDialog()
      Else
         //Versão Antiga - Release 3
            GeraRel()
      EndIf
      Work->(DbCloseArea())
   else
      WORK_EXPORT(iif(mv_par12==2,.f.,.t.))         //gera texto ou excel
   endif
Endif

EF1->(DBSETORDER(1)) //Alcir Alves - 19-05-02
EEC->(DBSETORDER(1))
EEQ->(DBSETORDER(1))
EF3->(DBSETORDER(1))
SWB->(DBSETORDER(1)) //HVR

Erase(cNomArq+TEOrdBagExt())
Erase(cNomArq2+TEOrdBagExt())
DbSelectArea(cAliasOld)

RETURN .F.

//CCM 09/03/09 - Monta query, caso exista conexão TOP
*-----------------------*
Static Function GrvWork()  //HVR 01/05/06 -
*-----------------------*
local Ni:=0

Private cLastCod   := ""
Private cLastBanco := ""
Private cLastMoeda := ""
Private lPreVin := .F.
Private aFilEEQ:=aFilEF3:=aFilEEC:={}
//Local aParc,I
Private cMoeda
Private Find_moeda

DbSelectArea("Work")
AvZap()
EEQ->(DBSETORDER(1))
EEC->(DBSETORDER(1))
EF3->(DBSETORDER(3))

//Alcir - AAS - tratamento de multifilial
//begin 01
aFilEEQ:=aclone(cfilSel)  //filiais selecionadas
aFilEF3:=AvgSelectFil(.F.,"EF3")
aFilEEC:=AvgSelectFil(.F.,"EEC")
aFilEF6:=AvgSelectFil(.F.,"EE6")
Find_moeda   :=iif(EEQ->(FIELDPOS("EEQ_MOEDA"))>0,.T.,.F.)  //verifica se o campo moeda existe

#IFDEF TOP  // ccm

   //*** Monta a query para bsuca de parcelas do EEQ
   cQryEEQ += "Select * From " + RetSqlName("EEQ")  //CCM

   //Verificação de filiais a serem consultadas.
   For nI:=1 to Len(aFilEEQ)
      If nI == 1
         cQryEEQ += " Where (EEQ_FILIAL = '" + aFilEEQ[nI] + "' "
      Else
         cQryEEQ += "Or EEQ_FILIAL = '" + aFilEEQ[nI] + "' "
      EndIf
   Next

   cQryEEQ += " )"

   //** PLB 06/07/06
   If lEFFTpMod
      cQryEEQ += " AND EEQ_TP_CON <> '" + cTpCont + "' "
   EndIf

   // Filtra por Tipo de Cambio
   If cTpCamb == "1" /*Importacao*/
      cQryEEQ += " AND EEQ_TP_CON IN ('2', '4') " // Cambio de Importacao/Remessa
   ElseIf cTpCamb == "2" /*Exportacao*/
      cQryEEQ += " AND EEQ_TP_CON IN ('1', '3') AND EEQ_TIPO <> 'P'" // Cambio de Exportacao/Recebimento ou "P" somente para importação
   Else
      cQryEEQ += " AND (EEQ_TP_CON IN ('2', '4') OR EEQ_TIPO <> 'P')"
   EndIf

   // Verifica se esta dentro do periodo
   IF !EMPTY(dInicial)
      cQryEEQ += "AND EEQ_VCT > '" + DToS(dInicial) + "' "
   Endif

   IF !EMPTY(dFinal)
      cQryEEQ += "AND EEQ_VCT < '" + DToS(dFinal) + "' "
   Endif

   // Verifica o Banco
   IF !EMPTY(cBanco)
        cQryEEQ += "AND (EEQ_BANC = '" + cBanco + "' OR EEQ_BCOEXT = '" + cBanco + "') "
   Endif

   // Verifica o Cliente
   IF !EMPTY(cCodCli) //.And. !EEC->(EOF())   // PLB 05/07/06
      cQryEEQ += "AND EEQ_IMPORT = '" + AvKey(cCodCli, "EEQ_IMPORT") + "' "
   Endif

   //HVR Verifica Liquidada

   IF cNotLiq == "1"//(cNotLiq == "1" .and. Empty(EEQ->EEQ_PGT)) .Or. (cNotLiq == "2" .and. !Empty(EEQ->EEQ_PGT))  //HVR verifica filtro Liquidada Sim e Data Vazia pula registro ou Veirifica filtro Liquidada não e data não esta vazia
      cQryEEQ += " AND EEQ_PGT <> ''"
   ElseIf cNotLiq == "2"
      cQryEEQ += " AND EEQ_PGT = ''"
   Endif

   //ALCIR ALVES - 19-02-05 - VALIDAÇÕES DOS FILTROS PERGUNTE
   IF !EMPTY(mv_par05)  //.and. !EEC->(EOF()) .AND. mv_par05#EEC->EEC_IMLOJA //LOJA DO CLIENTE
      cQryEEQ +="AND EEQ_IMLOJA ='"+ mv_par05+"' "
   ENDIF

   IF !EMPTY(mv_par06)//CODIGO DO EVENTO
      cQryEEQ += "AND EEQ_EVENT = '"+ mv_par06+"' "
   ENDIF

   IF !EMPTY(mv_par07)  //.and. !EEC->(EOF()) .AND. mv_par07#EEC->EEC_PREEMB //PROCESSO
      cQryEEQ +="AND EEQ_PREEMB ='"+mv_par07+"' "
   ENDIF

   IF !EMPTY(mv_par08) //INVOICE
      cQryEEQ += "AND EEQ_NRINVO ='"+ mv_par08+"' "
   ENDIF

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

#ELSE //Não exista conexão TOP

   for ni:=1 to len(aFilEEQ)
      cFilEEQ:=aFilEEQ[ni]
      cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],aFilEEQ[ni])
      cFilEEC:=iif(len(aFilEEC)==1 .and. alltrim(aFilEEC[1])=="",aFilEEC[1],aFilEEQ[ni])
      cFilEF6:=iif(len(aFilEF6)==1 .and. alltrim(aFilEF6[1])=="",aFilEF6[1],aFilEEQ[ni])
      EEQ->(DbSeek(cFilEEQ))
   //end 01


      DO WHILE ! EEQ->(EOF()) .AND. EEQ->EEQ_FILIAL==cFilEEQ

         //** PLB 06/07/06
         If lEFFTpMod
            // Filtra por Tipo de Contrato
            If !(cTpCont $ "5")  .And.  !(EEQ->EEQ_TP_CON $ cTpCont)  // 5-Todos
               EEQ->( DbSkip() )
               Loop
            EndIf
            // Filtra por Tipo de Cambio
            If cTpCamb $ "1" /*Importacao*/ .And. !(EEQ->EEQ_TP_CON $ "2/4")  // Cambio de Importacao/Remessa
               EEQ->( DbSkip() )
               Loop
            ElseIf cTpCamb $ "2" /*Exportacao*/ .And. !(EEQ->EEQ_TP_CON $ "1/3")  // Cambio de Exportacao/Recebimento
               EEQ->( DbSkip() )
               Loop
            EndIf
         EndIf

         if EEC->(DbSeek(cFilEEC+EEQ->EEQ_PREEMB))
            If Empty(EEC->EEC_DTEMBA) .and. mv_par09==1  //Alcir Alves - 08-04-05 - considera o filtro embarcado = Sim
               EEQ->(DbSkip())
               Loop
            EndIf

            If !Empty(EEC->EEC_DTEMBA) .and. mv_par09==2 //Alcir Alves - 08-04-05 - considera o filtro embarcado = Não
               EEQ->(DbSkip())
               Loop
            EndIf
         ElseIf lTpConExt .And. EEQ->EEQ_TP_CON!="1" .And. mv_par09==1  // PLB 05/07/06 - Caso nao encontre no EEC e for Câmbio Tipo 3 ou 4
            EEQ->(DbSkip())
            Loop
         Endif

         // Verifica se a invoice esta vinculada
         If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD, IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC))  //Alcir Alves - 08-04-05 - considera parcela na localização //HVR para EEQ TP_CON pode 1,3 ou 4 para 1,3 tipo do modulo é "E" ou "I" para 2 e 4
            EEQ->(DbSkip())
            Loop
         Endif

         // Verifica se esta dentro do periodo
         IF !EMPTY(dInicial)
            If EEQ->EEQ_VCT < dInicial
               EEQ->(DbSkip())
               Loop
            Endif
         Endif

         IF !EMPTY(dFinal)
            If EEQ->EEQ_VCT > dFinal
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

         // Verifica o Cliente
         IF !EMPTY(cCodCli) //.And. !EEC->(EOF())   // PLB 05/07/06
            If EEQ->EEQ_IMPORT != cCodCli  //EEC->EEC_IMPORT # cCodCli
               EEQ->(DbSkip())
               Loop
            Endif
         Endif

         //HVR Verifica Liquidada
         IF (cNotLiq == "1" .and. Empty(EEQ->EEQ_PGT)) .Or. (cNotLiq == "2" .and. !Empty(EEQ->EEQ_PGT))  //HVR verifica filtro Liquidada Sim e Data Vazia pula registro ou Veirifica filtro Liquidada não e data não esta vazia
            EEQ->(DbSkip())
            Loop
         Endif

         //ALCIR ALVES - 19-02-05 - VALIDAÇÕES DOS FILTROS PERGUNTE
         IF !EMPTY(mv_par05)  //.and. !EEC->(EOF()) .AND. mv_par05#EEC->EEC_IMLOJA //LOJA DO CLIENTE
            If EEQ->EEQ_IMLOJA != mv_par05  // PLB 05/07/06
               EEQ->(DbSkip())
               Loop
            EndIf
         ENDIF

         IF !EMPTY(mv_par06) .AND. mv_par06#EEQ->EEQ_EVENT //CODIGO DO EVENTO
            EEQ->(DbSkip())
            Loop
         ENDIF

         IF !EMPTY(mv_par07)  //.and. !EEC->(EOF()) .AND. mv_par07#EEC->EEC_PREEMB //PROCESSO
            If EEQ->EEQ_PREEMB != mv_par07  // PLB 05/07/06
               EEQ->(DbSkip())
               Loop
            EndIf
         ENDIF
         IF !EMPTY(mv_par08) .AND. mv_par08#EEQ->EEQ_NRINVO //INVOICE
            EEQ->(DbSkip())
            Loop
         ENDIF
         EF6->( DbSetOrder(2) )
         if !EMPTY(mv_par10)    //Alcir Alves - 08-04-05
            IF mv_par10 # 3
               lPreVin := EF6->( DbSeek(cFilEF6+EEQ->EEQ_PREEMB+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC) )
               IF ( ( mv_par10 == 2 .And. lPreVin ) .OR. ( mv_par10 == 1 .And. !lPreVin ) )
                  EEQ->(DbSkip())
                  Loop
               ENDIF
            else
               lPreVin := EF6->( DbSeek(cFilEF6+EEQ->EEQ_PREEMB+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC) )
            ENDIF
            GravaEEQ("EEQ")
            EEQ->(DbSkip())
         ENDIF
      EndDo
   next

#ENDIF
RETURN .T.

// CCM - 09/03/09 - Filtra e grava itens na work, itens selecionados na query.
/**************************************/
Static Function GravaEEQ(cAliasEEQ)
/**************************************/

Begin Sequence

EF6->( DbSetOrder(2) )
If !EMPTY(mv_par10)    //Alcir Alves - 08-04-05
   IF mv_par10 <> 3
      lPreVin := EF6->( DbSeek(cFilEF6+(cAliasEEQ)->EEQ_PREEMB+(cAliasEEQ)->EEQ_NRINVO+(cAliasEEQ)->EEQ_PARC) )
      IF  ( ( mv_par10 == 2 .And. lPreVin ) .OR. ( mv_par10 == 1 .And. !lPreVin ) )
         Break
      ENDIF
   else
      lPreVin := EF6->( DbSeek(cFilEF6+(cAliasEEQ)->EEQ_PREEMB+(cAliasEEQ)->EEQ_NRINVO+(cAliasEEQ)->EEQ_PARC) )
   ENDIF
ENDIF

if EEC->(DbSeek(cFilEEC+(cAliasEEQ)->EEQ_PREEMB))
   If Empty(EEC->EEC_DTEMBA) .and. mv_par09 ==1  //Alcir Alves - 08-04-05 - considera o filtro embarcado = Sim
      Break
   EndIf

   If !Empty(EEC->EEC_DTEMBA) .and. mv_par09 ==2 //Alcir Alves - 08-04-05 - considera o filtro embarcado = Não
      Break
   EndIf
ElseIf lTpConExt .And. (cAliasEEQ)->EEQ_TP_CON!="1" .And. mv_par09==1  // PLB 05/07/06 - Caso nao encontre no EEC e for Câmbio Tipo 3 ou 4
   Break
endif

// Verifica se a invoice esta vinculada
If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD, IF((cAliasEEQ)->EEQ_TP_CON $ ("2/4"),"I","E"),"")+(cAliasEEQ)->EEQ_NRINVO+(cAliasEEQ)->EEQ_PARC))  //Alcir Alves - 08-04-05 - considera parcela na localização //HVR para EEQ TP_CON pode 1,3 ou 4 para 1,3 tipo do modulo é "E" ou "I" para 2 e 4
   Break
Endif

If cModo = 1   // Analítico
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
   //** PLB 09/05/06
   If lEFFTpMod  .And.  (cAliasEEQ)->EEQ_TP_CON $ "2/4"
      Work->EEC_IMPORT := (cAliasEEQ)->EEQ_FORN
      Work->EEC_IMPODE := Posicione("SA2",1,xFilial("SA2")+(cAliasEEQ)->EEQ_FORN,"A2_NOME")
      Work->EEC_IMLOJA := (cAliasEEQ)->EEQ_FOLOJA
      //**
   ElseIf !EEC->(EOF())
      Work->EEC_IMPORT := EEC->EEC_IMPORT
      Work->EEC_IMPODE := EEC->EEC_IMPODE
      Work->EEC_IMLOJA := EEC->EEC_IMLOJA
   EndIf
Work->EEC_MOEDA  := IIF(Find_moeda==.t.,(cAliasEEQ)->EEQ_MOEDA,iif(EEC->(EOF()),"",EEC->EEC_MOEDA)) //CONSISTENCIA PARA CONSIDERAR A MOEDA
Else						// Sintético
  Work->(DbSetOrder(2))

  IF !Work->(Dbseek(IIF(QRYEEQ->EEQ_TP_CON $ ("1/3"),"EEQ","SWB")+(cAliasEEQ)->EEQ_FILIAL+(cAliasEEQ)->EEQ_BANC+(cAliasEEQ)->EEQ_MOEDA))


      Work->(RecLock("Work",.T.))
      Work->EEQ_FILIAL := (cAliasEEQ)->EEQ_FILIAL
      Work->EEQ_BANC   := (cAliasEEQ)->EEQ_BANC
      Work->EEQ_NOMEBC := (cAliasEEQ)->EEQ_NOMEBC
      Work->EEC_MOEDA  := IIF(Find_moeda==.t.,(cAliasEEQ)->EEQ_MOEDA,iif(EEC->(EOF()),"",EEC->EEC_MOEDA)) //CONSISTENCIA PARA CONSIDERAR A MOEDA
      Work->EEQ_VL     := (cAliasEEQ)->EEQ_VL
      Work->EEQSWB     := IIF(QRYEEQ->EEQ_TP_CON $ ("1/3"),"EEQ","SWB")
   Else
      Work->(RecLock("Work",.F.))
//  Work->EEQ_FILIAL := (cAliasEEQ)->EEQ_FILIAL
      Work->EEQ_VL     += (cAliasEEQ)->EEQ_VL
   Endif
   If lTPCONExt  .And.  lEFFTpMod
      If (cAliasEEQ)->EEQ_TP_CON $ "1/3"  // Exportacao
         Work->TPMODU := "E"
      ElseIf (cAliasEEQ)->EEQ_TP_CON $ "2/4"  // Importacao
         Work->TPMODU := "I"
      EndIf
   EndIf

   if EasyEntryPoint("EFFIN150")  //GRAVA CAMPOS NA WORK NO RELATORIO ANALITICO
      ExecBlock("EFFIN150", .F., .F.,"WORK_GRAVA_SINTETICO")
   endif


//If ( !Empty(cLastCod) .AND. !Empty(cLastBanco) .AND. !Empty(cLastMoeda) ) .AND.
//If( cLastCod == Work->EEQ_BANC .AND. cLastBanco == Work->EEQ_NOMEBC .AND. cLastMoeda == Work->EEC_MOEDA )


cLastCod   := Work->EEQ_BANC
cLastBanco := Work->EEQ_NOMEBC
cLastMoeda := IIF(Find_moeda==.t.,(cAliasEEQ)->EEQ_MOEDA,iif(EEC->(EOF()),"",EEC->EEC_MOEDA))

Endif

End Sequence

Return Nil

//HVR 28/04/06 - Grava na Work os registros filtrados do SWB
//CCM 09/03/09 - Monta query, caso exista conexão TOP
*-----------------------*
Static Function GrvWorkSWB()  //HVR 01/05/06 -
*-----------------------*
local Ni:=0
Private aFilSWB:=aFilEF3:=aFilsw6:={}

//Local aParc,I
Private cMoeda

cLastCod   := ""
cLastBanco := ""
cLastMoeda := ""



DbSelectArea("Work")
//Zap
SWB->(DBSETORDER(1))
SW6->(DBSETORDER(1))
EF3->(DBSETORDER(3))

aFilSWB:=aclone(cfilSel)  //filiais selecionadas
aFilEF3:=AvgSelectFil(.F.,"EF3")
aFilSW6:=AvgSelectFil(.F.,"EEC")
aFilEF6:=AvgSelectFil(.F.,"EE6")

#IFDEF TOP  // ccm
//*** Monta a query para bsuca de parcelas do EEQ
   cQrySWB += "Select * From " + RetSqlName("SWB")  //CCM

   //Tratamento de Filiais.   //JVR - 04/03/09
   For nI:=1 to Len(aFilSWB)
      If nI == 1
         cQrySWB += " Where ( WB_FILIAL = '" + aFilSWB[nI] + "' "
      Else
         cQrySWB += "Or WB_FILIAL = '" + aFilSWB[nI] + "' "
      EndIf
   Next

   cQrySWB += " ) "

   If lEFFTpMod
      cQrySWB += " AND WB_TP_CON  <> '" + cTpCont + "' "
   EndIf

   // PLB 06/07/06 - Filtra por Tipo de Cambio
   If cTpCamb $ "1" /*Importacao*/
      cQrySWB += " AND WB_TP_CON IN ('2', '4') AND WB_TIPOC <> 'R'" // Cambio de Importacao/Remessa e Parcelas a Receber(Exportação)
   ElseIf cTpCamb $ "2" /*Exportacao*///
      cQrySWB += " AND WB_TP_CON IN ('1', '3') " // Cambio de Exportacao/Recebimento
   Else
      cQrySWB += " AND (WB_TP_CON IN ('1', '3') or WB_TIPOC <> 'R') "
   EndIf

   // Verifica se esta dentro do periodo
   IF !EMPTY(dInicial)
      cQrySWB += "AND WB_DT_VEN > '" + DToS(dInicial) + "' "
   Endif

   IF !EMPTY(dFinal)
      cQrySWB += "AND WB_DT_VEN < '" + DToS(dFinal) + "' "
   Endif

   // Verifica o Banco
   IF !EMPTY(cBanco)
      cQrySWB += "AND WB_BCO_REC = '" + cBanco + "' "
   Endif

   // Verifica o Cliente
   IF !EMPTY(cCodCli) .and. !SWB->(EOF())
      cQrySWB += "AND WB_FORN = '" + AvKey(cCodCli, "WB_FORN") + "' "
   Endif

   If cNotLiq == "1"
      cQrySWB += " AND WB_CA_DT <> ''"
   ElseIf cNotLiq == "2"
      cQrySWB += " AND WB_CA_DT = ''"
   Endif

   //HVR - VALIDAÇÕES DOS FILTROS PERGUNTE
   IF !EMPTY(mv_par05)  .and. !SWB->(EOF()) .AND. mv_par05#SWB->WB_LOJA //LOJA DO CLIENTE
      cQrySWB +="AND WB_LOJA = '"+ mv_par05+"' "
   ENDIF

   IF !EMPTY(mv_par06) .AND. mv_par06#SWB->WB_EVENT //CODIGO DO EVENTO
      cQrySWB += "AND WB_EVENT = '"+ mv_par06+"' "
   ENDIF

   IF !EMPTY(mv_par07)  .and. !SWB->(EOF()) .AND. mv_par07#SWB->WB_HAWB //PROCESSO
      cQrySWB +="AND WB_HAWB ='"+mv_par07+"'"
   ENDIF

   IF !EMPTY(mv_par08) .AND. mv_par08#SWB->WB_INVOICE //INVOICE
      cQrySWB += "AND '"+ mv_par08+"' <> '' AND WB_INVOICE ='"+ mv_par08+"' "
   ENDIF

   //WFS
   If TcSrvType() <> "AS/400"
      cQrySWB += " And D_E_L_E_T_ <> '*' "
   Else
      cQrySWB += " And @DELETED@ <> '*' "
   EndIf

//Executa a query
   dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQrySWB)), "QRYSWB", .F., .T. )
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

#ELSE

for ni:=1 to len(aFilSWB)
   cFilSWB:=aFilSWB[ni]
   cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],aFilSWB[ni])
   cFilSW6:=iif(len(aFilSW6)==1 .and. alltrim(aFilSW6[1])=="",aFilSW6[1],aFilSWB[ni])
   cFilEF6:=iif(len(aFilEF6)==1 .and. alltrim(aFilEF6[1])=="",aFilEF6[1],aFilSWB[ni])
   SWB->(DbSeek(cFilSWB))

   DO WHILE ! SWB->(EOF()) .AND. SWB->WB_FILIAL==cFilSWB

      // PLB 06/07/06 - Filtra por Tipo de Contrato
      If !(cTpCont $ "5")  .And.  !(SWB->WB_TP_CON $ cTpCont)  // 5-Todos
         SWB->( DbSkip() )
         Loop
      EndIf

      // PLB 06/07/06 - Filtra por Tipo de Cambio
      If cTpCamb $ "1" /*Importacao*/ .And. !(SWB->WB_TP_CON $ "2/4")  // Cambio de Importacao/Remessa
         SWB->( DbSkip() )
         Loop
      ElseIf cTpCamb $ "2" /*Exportacao*/ .And. !(SWB->WB_TP_CON $ "1/3")  // Cambio de Exportacao/Recebimento
         SWB->( DbSkip() )
         Loop
      EndIf

      if SW6->(DbSeek(cFilSW6+SWB->WB_HAWB))
         If Empty(SW6->W6_DT_EMB) .and. mv_par09==1  //HV3 - considera o filtro embarcado = Sim
            SW6->(DbSkip())
            Loop
         EndIf

         If !Empty(SW6->W6_DT_EMB) .and. mv_par09==2 //HVR - considera o filtro embarcado = Não
            SW6->(DbSkip())
            Loop
         EndIf
      endif

      // Verifica se a invoice esta vinculada
      If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD, IF(SWB->WB_TP_CON $ ("2/4"),"I","E"),"")+SWB->WB_INVOICE+SWB->WB_LINHA))  //HVR - considera parcela no filtro //HVR para EEQ TP_CON pode 1,3 ou 4 para 1,3 tipo do modulo é "E" ou "I" para 2 e 4
         SWB->(DbSkip())
         Loop
      Endif

      // Verifica se esta dentro do periodo
      IF !EMPTY(dInicial)
         If SWB->WB_DT_VEN < dInicial
            SWB->(DbSkip())
            Loop
         Endif
      Endif

      IF !EMPTY(dFinal)
         If SWB->WB_DT_VEN > dFinal
            SWB->(DbSkip())
            Loop
         Endif
      Endif

      // Verifica o Banco
      IF !EMPTY(cBanco)
         If SWB->WB_BCO_REC # cBanco
            SWB->(DbSkip())
            Loop
         Endif
      Endif

      // Verifica o Cliente
      IF !EMPTY(cCodCli) .and. !SWB->(EOF())
         If SWB->WB_FORN # cCodCli
            SWB->(DbSkip())
            Loop
         Endif
      Endif

      //HVR Verifica Liquidada
      IF (cNotLiq == "1" .and. Empty(SWB->WB_CA_DT)) .Or. (cNotLiq == "2" .and. !Empty(SWB->WB_CA_DT))  //HVR verifica filtro Liquidada Sim e Data Vazia pula registro ou Veirifica filtro Liquidada não e data não esta vazia
         SWB->(DbSkip())
         Loop
      Endif

      //HVR - VALIDAÇÕES DOS FILTROS PERGUNTE
      IF !EMPTY(mv_par05)  .and. !SWB->(EOF()) .AND. mv_par05#SWB->WB_LOJA //LOJA DO CLIENTE
         SWB->(DbSkip())
         Loop
      ENDIF

      IF !EMPTY(mv_par06) .AND. mv_par06#SWB->WB_EVENT //CODIGO DO EVENTO
         SWB->(DbSkip())
         Loop
      ENDIF

      IF !EMPTY(mv_par07)  .and. !SWB->(EOF()) .AND. mv_par07#SWB->WB_HAWB //PROCESSO
         SWB->(DbSkip())
         Loop
      ENDIF

      IF !EMPTY(mv_par08) .AND. mv_par08#SWB->WB_INVOICE //INVOICE
         SWB->(DbSkip())
         Loop
      ENDIF

      //** PLB 21/11/06 - Verifica se é Câmbio a Receber
      If SWB->( WB_TP_CON $ ("2/4")  .And.  WB_TIPOC == "R" )
         SWB->( DBSkip() )
         Loop
      EndIf
      //**
      GravaSWB("SWB")
      SWB->(DbSkip())
      Work->(DbSetOrder(1))
      //WORK->(DBSETORDER(1))
   EndDo
next
#ENDIF

Return

// CCM - 09/03/09 - Filrra e Grava itens na work, providos do resultado da query
/**************************************/
Static Function GravaSWB(cAliasSWB)
/**************************************/

Begin Sequence

EF6->( DbSetOrder(2) )

if SW6->(DbSeek(QRYSWB->WB_FILIAL+QRYSWB->WB_HAWB))
   If Empty(SW6->W6_DT_EMB) .and. mv_par09==1  //HV3 - considera o filtro embarcado = Sim
      SW6->(DbSkip())
      Break
   EndIf

   If !Empty(SW6->W6_DT_EMB) .and. mv_par09==2 //HVR - considera o filtro embarcado = Não
      SW6->(DbSkip())
      Break
   EndIf
endif

// Verifica se a invoice esta vinculada
If EF3->(DbSeek(cFilEF3+IF(lEFFTPMOD, IF(QRYSWB->WB_TP_CON $ ("2/4"),"I","E"),"")+QRYSWB->WB_INVOICE+QRYSWB->WB_LINHA))  //HVR - considera parcela no filtro //HVR para EEQ TP_CON pode 1,3 ou 4 para 1,3 tipo do modulo é "E" ou "I" para 2 e 4
   Break
Endif

EF6->( DbSetOrder(2) )

If cModo = 1   // Analítico
            // Grava na Work
   Work->(RecLock("Work",.T.))
   Work->EEQ_FILIAL := QRYSWB->WB_FILIAL
   Work->EEQ_BANC   := QRYSWB->WB_BCO_REC
   Work->EEQ_NOMEBC := POSICIONE("SA6",1,cfilSA6+QRYSWB->WB_BCO_REC,"A6_NOME")
   Work->EEQ_NRINVO := QRYSWB->WB_INVOICE
   Work->EEQ_PARC   := QRYSWB->WB_LINHA
   Work->EEQ_VCT    := QRYSWB->WB_DT_VEN
   Work->EEQ_VL     := QRYSWB->WB_FOBMOE
   Work->EEQSWB     := IIF(QRYSWB->WB_TP_CON $ "1/3","EEQ","SWB")  // PLB 06/07/06
   Work->EEC_IMPORT := QRYSWB->WB_FORN
   Work->EEC_IMPODE := POSICIONE("SA2",1,cFilSA2+QRYSWB->WB_FORN,"A2_NREDUZ")
            //Work->EEQ_PREEMB := EEQ->EEQ_PREEMB
            //Work->EEQ_DTCE   := SWV->SWB_DTCE
   if !SW6->(EOF())
      Work->EEC_DTEMBA := SW6->W6_DT_EMB
   endif

   Work->EEC_MOEDA  := QRYSWB->WB_MOEDA //CONSISTENCIA PARA CONSIDERAR A MOEDA

   if EasyEntryPoint("EFFIN150")  //GRAVA CAMPOS NA WORK NO RELATORIO ANALITICO
      ExecBlock("EFFIN150", .F., .F.,"WORK_GRAVA_ANALITICO")
   endif

Else						// Sintético
   Work->(DbSetOrder(2))

   If !Work->(Dbseek(IIF(QRYSWB->WB_TP_CON $ ("1/3"),"EEQ","SWB")+QRYSWB->WB_FILIAL+QRYSWB->WB_BCO_REC+QRYSWB->WB_MOEDA))

      Work->(RecLock("Work",.T.))
      Work->EEQ_FILIAL := QRYSWB->WB_FILIAL
      Work->EEQSWB     := IIF(QRYSWB->WB_TP_CON $ ("1/3"),"EEQ","SWB")  // PLB 06/07/06
      Work->EEQ_BANC   := QRYSWB->WB_BCO_REC
      Work->EEQ_NOMEBC := POSICIONE("SA6",1,cfilSA6+QRYSWB->WB_BCO_REC,"A6_NOME")
      Work->EEC_MOEDA  := QRYSWB->WB_MOEDA //CONSISTENCIA PARA CONSIDERAR A MOEDA
   Else
      Work->(RecLock("Work",.F.))
      //Work->EEQ_FILIAL := QRYSWB->WB_FILIAL
      Work->EEQ_VL     += QRYSWB->WB_FOBMOE
   Endif

   if EasyEntryPoint("EFFIN150")  //GRAVA CAMPOS NA WORK NO RELATORIO ANALITICO
      ExecBlock("EFFIN150", .F., .F.,"WORK_GRAVA_SINTETICO")
   endif


Endif

End Sequence

RETURN .T.

*-------------------------*
Static Function GeraRel()
*-------------------------*
PRIVATE TB_Campos    := {}
PRIVATE aRCampos     := {}

Private lInvTrans  := .F., cModAt := "XXX", cBancoAtu := "XXX", aTotalBanco := {}, aTotalGer := {},Fil_sub:={}, FilAtu:="-",TotalFil:={},GraTotFil:={},filial_n:={}

PRIVATE aDados := {"Work",;
                   STR0004,; //"Este programa tem como objetivo imprimir relatório de acordo com os parâmetros informados pelo usuário."
                   STR0005,;  //"Posição de Invoice não vinculadas"
                   "",;
                   "G",;
                    220,;
                   "",;
                   STR0005 ,; //"Posição de Invoice não vinculadas"
                   STR0006 + If (cModo =1, STR0007, STR0008) + STR0009+DTOC(dInicial)+ STR0010 + DTOC(dFinal),;                    //"Posição de Invoice não vinculadas "###"(Analitico)"###"(Sintetico)"###" - Periodo: "###" Ate "
                   { "Zebrado", 1,"Contabil", 1, 2, 1, "",1 },;
                   "EFFIN150",;
                   { {||AcumTotais()} , {||ImpTotais()} }  }

If cModo = 1   // Analitico
//   AADD(TB_Campos,{{ ||If(Work->EEQSWB == "SWB", STR0024, STR0025) }              				  ,"L" , STR0026} )   //"Modulo"
   AADD(TB_Campos,{{ ||Work->EEQ_NRINVO }              				  ,"L" , STR0011     } )   //"INVOICE"
   AADD(TB_Campos,{{ ||Work->EEQ_PARC   }              				  ,"L" , STR0012     } )   //"PARCELA"
   AADD(TB_Campos,{{ ||Transf(Work->EEQ_VCT, AVSX3("EEQ_VCT",6 ))}  ,"L" , "DT.VCTO."    } )
   AADD(TB_Campos,{{ ||Work->EEC_MOEDA  }            				  ,"C" , STR0013       } ) //"MOEDA"
   AADD(TB_Campos,{{ ||TRANSF(Work->EEQ_VL, AVSX3("EEQ_VL",6 ) )}   ,"D" , STR0014       } ) //"VALOR"
   AADD(TB_Campos,{{ ||Work->EEQ_DTCE   }            					  ,"L" , "DT. CRED."   } )
   //AADD(TB_Campos,{{ ||Work->EEQ_PREEMB   }            			  ,"L" , STR0015    } ) //"PROCESSO"
   AADD(TB_Campos,{{ ||ALLTRIM(Work->EEC_IMPORT)+ " - " + Work->EEC_IMPODE }        ,"L" , STR0016     } ) //"CLIENTE/FORNECEDOR"  + " - " + Work->EEC_IMPODE
   AADD(TB_Campos,{{ ||Transf(Work->EEC_DTEMBA, AVSX3("EEC_DTEMBA",6 ))}            ,"L" , "DT.EMBA."    } )
   AADD(TB_Campos,{{ ||Work->PREVIN}                                                ,"L" , "PRÉ VIN."    } )
   //Alcir Alves - 19-02-05
   if EasyEntryPoint("EFFIN150")  //COLUNAS DO RELATORIO ANALITICO
       ExecBlock("EFFIN150", .F., .F.,"COL_REL_ANALITICO")
   endif
   //
Else    // Sintético
   AADD(TB_Campos,{{ ||Work->EEQ_BANC  + " - " + Work->EEQ_NOMEBC  }      ,"L" , STR0017    } ) //"BANCO"
   AADD(TB_Campos,{{ ||Work->EEC_MOEDA   }            					  ,"C" , STR0013    } ) //"MOEDA"
   AADD(TB_Campos,{{ ||TRANSF(Work->EEQ_VL,       AVSX3("EEQ_VL",6 ))}    ,"D" , STR0014    } ) //"VALOR"
   //AADD(TB_Campos,{{ ||Transf(Work->EEC_DTEMBA, AVSX3("EEC_DTEMBA",6 ))}            ,"L" , "DT.EMBA."    } )
   //AADD(TB_Campos,{{ ||Work->PREVIN}                                                ,"L" , "PRÉ VIN."    } )
   //Alcir Alves - 19-02-05
   if EasyEntryPoint("EFFIN150")  //COLUNAS DO RELATORIO SINTETICO
       ExecBlock("EFFIN150", .F., .F.,"COL_REL_SINTETICO")
   endif
   //
Endif
aRCampos:= E_CriaRCampos(TB_CAMPOS)
E_Report(aDados,aRCampos)
RETURN .T.

*--------------------------*
Static Function AcumTotais()
*--------------------------*
Local nPosBanco , nPosGer, i

 // Imprime Total do Banco Anterior
 If cModo = 1  // Analitico
   If cBancoAtu # Work->EEQ_BANC .or. FilAtu#Work->EEQ_filial
      If ! Empty(aTotalBanco)
         PulaLinha()
         PulaLinha()
     	 @ Linha, 010 PSAY STR0018 //"TOTAL BANCO :"
   	     for i:= 1 to len (aTotalBanco)
            @ Linha, 039 PSAY oemtoansi(aTotalBanco[i,1])
            @ Linha, 046 PSAY TRANS(aTotalBanco[i,2],AVSX3("EEQ_VL",6 ))
            PulaLinha(STR0018) //"TOTAL BANCO :"
         next
    	 PulaLinha()
    	 @ Linha, 000 PSAY Repli("-", 218 )
         PulaLinha()
      Endif
   endif
 endif


IF cModAt # WORK->EEQSWB
 IF cModAt <> "XXX"
    Linha := 100
    PulaLinha()
    PulaLinha()
    //PulaLinha()
    //PulaLinha()
    //PulaLinha()
    If cModo == 1  // PLB 06/07/06 - Analitico
       @ Linha, 000 PSAY " "+STR0011+"              "+STR0012+" "+"DT.VCTO."+" "+STR0013+"  "+STR0014+"              "+"DT. CRED."+" "+STR0016+" DT.EMBA."
       PulaLinha()
       @ Linha, 000 PSAY " ==================== "+   "======= "+  "======== "+    "====== "+ "================== "+    "========= "+  "========================= ======= "
       TB_Campos[7,3]:= "Fornecedor"
       aSize(TB_Campos,Len(TB_Campos)-1)
    Else  // PLB 06/07/06 - Sintetico
       @ Linha, 000 PSAY Space(1)+PadR(STR0017,Len(Eval(TB_Campos[1][1]))," ")+Space(1)+PadR(STR0013,Len(Eval(TB_Campos[2][1]))," ")+Space(1)+PadR(STR0014,Len(Eval(TB_Campos[3][1]))," ")  // BANCO # MOEDA # VALOR
       PulaLinha()
       @ Linha, 000 PSAY Space(1)+Replicate("=",Len(Eval(TB_Campos[1][1])))+Space(1)+Replicate("=",Len(Eval(TB_Campos[2][1])))+Space(1)+Replicate("=",Len(Eval(TB_Campos[3][1])))
    EndIf

 EndIf
 PulaLinha()
 @ Linha, 000 PSAY Repli("*", 218 )
 PulaLinha()
 @ Linha, 000 PSAY IF(WORK->EEQSWB == "SWB", STR0026+": "+STR0024, STR0026+": "+STR0025)
 PulaLinha()
 If cModAt <> "XXX"
    @ Linha, 000 PSAY Repli("*", 218 )
    PulaLinha()
 EndIf
EndIF
cModAt      := Work->EEQSWB

//quebra a cada filial
if lMultiFil .AND. FilAtu#Work->EEQ_filial
// valor total por filial

  If ! Empty(aTotalBanco) .and. cModo = 1   // Analitico
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 218)
      PulaLinha()
      filial_n:=AvgFilName({FilAtu})
      @ Linha,00 PSAY STR0022+" "+FilAtu+" - "+filial_n[1]  //"Total Filial : "
      PulaLinha()
      for i:= 1 to len (TotalFil) //TOTAL POR FILial moeda
         @ Linha, 39 PSAY TotalFil[i,1]
         @ Linha, 46 PSAY TRANS(TotalFil[i,2],AVSX3("EEQ_VL",6 ))
         PulaLinha()
      next
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 218)
      PulaLinha()
  endif
  If ! Empty(aTotalBanco)
     linha:=61
  endif
//endcomm 04

   PulaLinha()
   PulaLinha()
   @ Linha, 000 PSAY Repli("*", 218)
   PulaLinha()


   filial_n:=AvgFilName({Work->EEQ_FILIAL})
   @ Linha,00 PSAY STR0021+" "+Work->EEQ_FILIAL+" - "+filial_n[1]  //"Filial : "
   TotalFil:={}
   PulaLinha()
   @ Linha, 000 PSAY Repli("*", 218)
   PulaLinha()
   FilAtu:=Work->EEQ_filial
   cBancoAtu="-"
   lPrimFil:=.F.
ENDIF
//endcomm 03


If cModo = 1  // Analitico
   If cBancoAtu # Work->EEQ_BANC
       PulaLinha()
      @ Linha, 001 PSAY STR0019 + Work->EEQ_BANC + " - "  + Work->EEQ_NOMEBC //"BANCO : "
      //PulaLinha()
      If !lMultiFil
         FilAtu:=Work->EEQ_filial
      EndIf
      cBancoAtu   := Work->EEQ_BANC
      aTotalBanco := {}
   Endif
Endif

//TOTAL POR MOEDA E banco
If lMultiFil
   nPosBanco := ASCAN(TotalFil,{ |x| x[1] = Work->EEC_MOEDA })
   if nPosBanco = 0
      AADD(TotalFil,{Work->EEC_MOEDA,Work->EEQ_VL})
   else
      TotalFil[nPosBanco,2] += Work->EEQ_VL
   endif

   //TOTAL POR MOEDA E FILIAL
   nPosBanco := ASCAN(GraTotFil,{ |x| x[1]=FilAtu .AND. x[2] = Work->EEC_MOEDA})
   if nPosBanco = 0
      AADD(GraTotFil,{FilAtu,Work->EEC_MOEDA,Work->EEQ_VL})
   else
      GraTotFil[nPosBanco,3] += Work->EEQ_VL
   endif
Endif


// Acumula Total por Banco e Geral
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

RETURN .T.
*---------------------------*
Static Function ImpTotais()
*---------------------------*
Local i

// Imprime Total do Banco Anterior

If cModo = 1
   PulaLinha()
   //@ Linha, 000 PSAY Repli("-", 218)
   PulaLinha()
   @ Linha, 010 PSAY STR0018 //"TOTAL BANCO :"
   for i:= 1 to len (aTotalBanco)
      @ Linha, 039 PSAY oemtoansi(aTotalBanco[i,1])
      @ Linha, 046 PSAY TRANS(aTotalBanco[i,2],AVSX3("EEQ_VL",6 ))
      PulaLinha(STR0018) //"TOTAL BANCO :"
   next
   If lMultiFil
   aadd(Fil_sub,{FilAtu,TotalFil}) //subtotal por filial//
   Endif
   PulaLinha()
   @Linha, 000 PSAY Repli("-", 218)
   PulaLinha()
   PulaLinha()

   If lMultiFil
      @ Linha, 000 PSAY Repli("*", 218)
      PulaLinha()
      filial_n:=AvgFilName({FilAtu})
      @ Linha,00 PSAY STR0022+" "+FilAtu+" - "+filial_n[1]  //"Total Filial : "
      PulaLinha()
      for i:= 1 to len (TotalFil)
         @ Linha, 39 PSAY TotalFil[i,1]
         @ Linha, 46 PSAY TRANS(TotalFil[i,2],AVSX3("EEQ_VL",6 ))
         PulaLinha()
      next
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 218)
      PulaLinha()
   Endif

   linha:=61
   PulaLinha()
   PulaLinha()

   If lMultiFil
      @Linha, 000 PSAY Repli("-", 218)
      PulaLinha()
      @Linha, 000 PSAY STR0022
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
      @Linha, 000 PSAY Repli("-", 218)
   Endif
Endif

// Total Geral
PulaLinha()
@Linha, 000 PSAY Repli("-", 218)
PulaLinha()
@ Linha, 010 PSAY STR0020 //"TOTAL GERAL :"
 for i:= 1 to len (aTotalGer)
     @ Linha, 039 PSAY iif(!empty(aTotalGer[i,1]),alltrim(aTotalGer[i,1]),"-")
     @ Linha, 046 PSAY TRANS(aTotalGer[i,2],AVSX3("EEQ_VL",6 ))
     PulaLinha(STR0020)
 next

PulaLinha()
@Linha, 000 PSAY Repli("-", 218)
PulaLinha()

*--------------------------*
Static Function PulaLinha(cTexto)
*--------------------------*
IF(valtype(cTexto) = "U", cTexto:="",.T.)
IF Linha >= 60
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
*--------------------------*
Static Function CriaWork()    //HVR 01/05/06 - REVISÃO
*--------------------------*
Private aHeader[0],aCampos := {}
PRIVATE aEstru := {}

// Cria Work
AADD(aEstru,{ "EEQ_FILIAL", "C" , AVSX3("EEQ_FILIAL", 3), 0 })
AADD(aDescr                     ,{AVSX3("EEQ_FILIAL", 5)    })
AADD(aEstru,{ "EEQ_BANC"  , "C" , AVSX3("EEQ_BANC"  , 3), 0 })
AADD(aDescr                     ,{AVSX3("EEQ_BANC"  , 5)    })
AADD(aEstru,{ "EEQ_NOMEBC", "C" , AVSX3("EEQ_NOMEBC", 3), 0 })
AADD(aDescr                     ,{AVSX3("EEQ_NOMEBC", 5)    })
AADD(aEstru,{ "EEQ_NRINVO", "C" , AVSX3("EEQ_NRINVO", 3), 0 })
AADD(aDescr                     ,{AVSX3("EEQ_NRINVO", 5)    })
AADD(aEstru,{ "EEQ_PARC"  , "C" , AVSX3("EEQ_PARC"  , 3), 0 })
AADD(aDescr                     ,{AVSX3("EEQ_PARC"  , 5)    })
AADD(aEstru,{ "EEQ_VCT"   , "D" , AVSX3("EEQ_VCT"   , 3), 0 })
AADD(aDescr                     ,{AVSX3("EEQ_VCT"   , 5)    })
AADD(aEstru,{ "EEQ_VL"    , "N" , AVSX3("EEQ_VL"    , 3), 2 })
AADD(aDescr                     ,{AVSX3("EEQ_VL"    , 5)    })
//AADD(aEstru,{ "EEQ_PREEM, "C" , 20, 0  })
AADD(aEstru,{ "EEQ_DTCE"  , "D" , AVSX3("EEQ_DTCE"  , 3), 0 })
AADD(aDescr                     ,{AVSX3("EEQ_DTCE"  , 5)    })
AADD(aEstru,{ "EEC_IMPORT", "C" , AVSX3("EEC_IMPORT", 3), 0 })
AADD(aDescr                     ,{AVSX3("EEC_IMPORT", 5)    })
AADD(aEstru,{ "EEC_IMPODE", "C" , AVSX3("EEC_IMPODE", 3), 0 })
AADD(aDescr                     ,{AVSX3("EEC_IMPODE", 5)    })
AADD(aEstru,{ "EEC_MOEDA" , "C" , AVSX3("EEC_MOEDA" , 3), 0 })
AADD(aDescr                     ,{AVSX3("EEC_MOEDA" , 5)    })
AADD(aEstru,{ "EEC_DTEMBA", "D" , AVSX3("EEC_DTEMBA", 3), 0 })
AADD(aDescr                     ,{AVSX3("EEC_DTEMBA", 5)    })
AADD(aEstru,{ "PREVIN"    , "C" ,03                    , 0  })
AADD(aDescr                     ,{ "Pré Vin."               })
AADD(aEstru,{ "W6_IMPORT" , "C" , AVSX3("W6_IMPORT" , 3), 0 }) //HVR 01/05/06
AADD(aDescr                     ,{AVSX3("W6_IMPORT" , 5)    })
AADD(aEstru,{ "W6_IMPORVM", "C" , AVSX3("W6_IMPORVM", 3), 0 }) //HVR 01/05/06
AADD(aDescr                     ,{AVSX3("W6_IMPORVM", 5)    })
AADD(aEstru,{ "WB_FORN"   , "C" , AVSX3("WB_FORN"   , 3), 0 }) //HVR 01/05/06
AADD(aDescr                     ,{AVSX3("WB_FORN"   , 5)    })
AADD(aEstru,{ "WB_FORNDES", "C" , AVSX3("WB_FORNDES", 3), 0 }) //HVR 01/05/06
AADD(aDescr                     ,{AVSX3("WB_FORNDES", 5)    })
AADD(aEstru,{ "WB_LOJA"   , "C" , AVSX3("WB_LOJA"   , 3), 0 }) //HVR 01/05/06
AADD(aDescr                     ,{AVSX3("WB_LOJA"   , 5)    })
AADD(aEstru,{ "EEQSWB"    , "C" , 03                    , 0 }) //HVR Flag da Origem do Registro
AADD(aDescr                     ,{ "Módulo"                 })
AADD(aEstru,{ "TPMODU"    , "C" , AVSX3("EF1_TPMODU", 3), 0 }) //CCM
AADD(aDescr                     ,{AVSX3("EF1_TPMODU", 5)    })
AADD(aEstru,{ "EEC_IMLOJA", "C" , AVSX3("EEC_IMLOJA", 3), 0 }) //CCM
AADD(aDescr                     ,{AVSX3("EEC_IMLOJA", 5)    })
AADD(aEstru,{ "EEQ_PREEMB", "C" , Max(AVSX3("EEQ_PREEMB",3),AVSX3("WB_HAWB",3)), 0  })
AADD(aDescr                     ,{AVSX3("EEQ_PREEMB", 5)    })
AADD(aEstru,{ "WB_PO_DI"  , "C" , AVSX3("WB_PO_DI"  , 3), 0 })
AADD(aDescr                     ,{AVSX3("WB_PO_DI"  , 5)    })

//Alcir Alves - 19-02-05
if EasyEntryPoint("EFFIN150")  //ESTRUTURA DA WORK
       ExecBlock("EFFIN150", .F., .F.,"WORK_ESTRUTURA")
endif
//

If Select("Work") > 0
   Work->( DBCloseArea() )
EndIf
cNomArq:=E_CriaTrab(,aEstru,"Work")
IndRegua("Work",cNomArq+TEOrdBagExt() ,IF(lEFFTpMod,"EEQSWB+","")+"EEQ_FILIAL+EEQ_BANC+EEQ_NRINVO") //HVR 01/05/06 EEQSWB
cNomArq2  := CRIATRAB(,.F.)
INDREGUA("Work",cNomArq2+TEOrdBagExt(),IF(lEFFTpMod,"EEQSWB+","")+"EEQ_FILIAL+EEQ_BANC+EEC_MOEDA" ) //HVR 01/05/06 EEQSWB
Set Index to (cNomArq+TEOrdBagExt()),(cNomArq2+TEOrdBagExt())

Return


/*
*---------------------------*
Function EFFIN150VAL(cCampo)
*---------------------------*
Local lRet:=.T.

IF(valtype(cCampo) = "U", cCampo:="",.T.)
If cCampo == "DATAINICIAL" .OR. Empty(cCampo)
   //If !E_Periodo_OK(@MV_PAR02,@MV_PAR03)
   //  lRet := .F.
   //EndIf
ElseIf cCampo == "DATAFINAL".OR. Empty(cCampo)
   //If !E_Periodo_OK(@MV_PAR02,@MV_PAR03)
   //  lRet := .F.
   //EndIf
EndIf
RETURN lRet
*/

//*// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 03/03/2009 - Caio Moscatiello  - revisão
*---------------------------------------------------------------------------------------

TR350ARQUIVO("Work",, AClone(aDescr),,, lExcel)

Return

// PLB - 04/08/06 - Definições do relatório personalizável
*********************************
Static Function ReportDef()
*********************************
Local cTitle := ""

   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
   aTabelas := {"EEC","EEQ","SW6","SWB"}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   If cModo == 1  //Analitico
      aOrdem   := { AvSx3("EEQ_NRINVO",5)+" e "+AvSx3("EEQ_PARC",5)+" / "+AvSx3("WB_LINHA",5)  } //Primeira Ordem
   ElseIf cModo == 2  //Sintetico
      aOrdem   := { AvSx3("EEQ_BANC",5)+" e "+AvSx3("EEC_MOEDA",5)  } //Primeira Ordem
   EndIf

   cTitle := STR0001
   If cModo == 1  //Analitico
      cTitle += STR0007
   ElseIf cModo == 2  //Sintetico
      cTitle += STR0008
   EndIf
   cTitle += STR0009  // Periodo
   cTitle += DtoC(dInicial)
   cTitle += STR0010  // Ate
   cTitle += DtoC(dFinal)

   //Cria o objeto principal de controle do relatório.
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EFFIN150",cTitle,"EFFIN1",{||ReportPrint()},STR0004+STR0005)

   oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina
   oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem

   //Define o objeto com a seção do relatório
   oSecao1 := TRSection():New(oReport,"Cabeçalho",aTabelas,aOrdem)
   oSecao2 := TRSection():New(oReport,"Invoices",aTabelas,aOrdem)

   //Definição das colunas de impressão da seção 2
   If cModo == 1  //Analitico
      TRCell():New(oSecao2,"EEQ_NRINVO" ,"Work",STR0011      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"EEQ_PARC"   ,"Work",STR0012      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"EEQ_VCT"    ,"Work","DT.VCTO."   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"EEC_MOEDA"  ,"Work",STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"EEQ_VL"     ,"Work",STR0014      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"EEQ_DTCE"   ,"Work","DT. CRED."  ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"EEC_IMPORT" ,"Work","CLIENTE"    ,"@!"                              ,40                     ,/*lPixel*/,{||AllTrim(Work->EEC_IMPORT)+" - "+AllTrim(Work->EEC_IMPODE)})
      TRCell():New(oSecao2,"EEC_DTEMBA" ,"Work","DT.EMBA."   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"PREVIN"     ,"Work","PRÉ VIN."   ,"@!"                              ,3                      ,/*lPixel*/,/*{|| code-block de impressao }*/)
   ElseIf cModo == 2  //Sintetico
      TRCell():New(oSecao2,"EEQ_BANC"   ,"Work",/*Titulo*/   ,/*Picture*/                       ,40                     ,/*lPixel*/,{||AllTrim(Work->EEQ_BANC)+" - "+AllTrim(Work->EEQ_NOMEBC)})
      TRCell():New(oSecao2,"EEC_MOEDA"  ,"Work",STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao2,"EEQ_VL"     ,"Work",STR0014      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   EndIf

   //Definição das colunas de impressão da seção 1
   TRCell():New(oSecao1,"EEQSWB"     ,"Work","Módulo:   " ,/*Picture*/                       ,Len(STR0024)           ,/*lPixel*/,{||IIF(Work->EEQSWB=="SWB",STR0024,STR0025) })
   If lMultiFil
      TRCell():New(oSecao1,"EEQ_FILIAL" ,"Work",/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   EndIf
   If cModo == 1  //Analitico
      TRCell():New(oSecao1,"EEQ_BANC"   ,"Work",/*Titulo*/   ,/*Picture*/                       ,40                     ,/*lPixel*/,{||AllTrim(Work->EEQ_BANC)+" - "+AllTrim(Work->EEQ_NOMEBC)})
   EndIf

   // Pula uma página ao quebrar uma seção
   oReport:Section("Invoices"):SetPageBreak(.T.)

   // Imprime o cabecalho ao executar um oBreak
   oReport:Section("Invoices"):SetHeaderBreak(.T.)

   // Alinha o cabecalho da celula
   oReport:Section("Invoices"):Cell("EEQ_VL"):SetHeaderAlign("RIGHT")

   AEVAL(oSecao2:aCell, {|X| X:SetColSpace(2) } ) // JWJ 01/02/2007

   // Espacamento entre as celulas
   If cModo == 1  //Analitico
      oReport:Section("Invoices"):Cell("EEQ_VL" ):SetColSpace(5)
      oReport:Section("Invoices"):Cell("EEQ_VCT"):SetColSpace(3)
   EndIf

   oReport:Section("Cabeçalho"):Cell("EEQSWB"    ):SetColSpace(3)
   If lMultiFil
      oReport:Section("Cabeçalho"):Cell("EEQ_FILIAL"):SetColSpace(3)
   EndIf

Return oReport

*********************************
Static Function BreakDef(nBreak)
*********************************
   If nBreak == 1
      //Totalizador por banco
      oBreak := TRBreak():New(oReport:Section("Invoices"),{||Work->(EEQSWB+IIF(lMultiFil,EEQ_FILIAL,"")+EEQ_BANC)},STR0018,.F.) // "Total do Banco"
      TRFunction():New(oReport:Section("Invoices"):Cell("EEQ_VL"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.)
      oBreak:bOnPrintTotal:={||OnBrReport(nBreak)}

   ElseIf nBreak == 2
      //Totalizador por filial
      oBreak := TRBreak():New(oReport:Section("Invoices"),{||Work->(EEQSWB+EEQ_FILIAL)},STR0022,.F.) // "Total da Filial"
      TRFunction():New(oReport:Section("Invoices"):Cell("EEQ_VL"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.)
      oBreak:bOnPrintTotal:={||OnBrReport(nBreak)}

   ElseIf nBreak == 3
      //Totalizador por modulo
      oBreak := TRBreak():New(oReport:Section("Invoices"),{||Work->EEQSWB},STR0027,.F.) // "Total Modulo"
      TRFunction():New(oReport:Section("Invoices"):Cell("EEQ_VL"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.)
      oBreak:bOnPrintTotal:={||oReport:EndPage(),OnBrReport(nBreak)}
   EndIf

Return oBreak

************************************
Static Function ReportPrint()
************************************
//Local oSection := oReport:Section("Invoices")
Private cTpModAtu := ""  ,;
        cFilAtu   := ""

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Invoices"),"EEC",1,{|| xFilial("EEC") + AvKey(Work->EEQ_PREEMB,"EEQ_PREEMB")})
TRPosition():New(oReport:Section("Invoices"),"EEQ",1,{|| xFilial("EEQ") + AvKey(Work->EEQ_PREEMB,"EEQ_PREEMB") + AvKey(Work->EEQ_NRINVO,"EEQ_NRINVO") + AvKey(Work->EEQ_PARC,"EEQ_PARC")})
TRPosition():New(oReport:Section("Invoices"),"SW6",1,{|| xFilial("SW6") + AvKey(Work->EEQ_PREEMB,"W6_HAWB")})
TRPosition():New(oReport:Section("Invoices"),"SWB",1,{|| xFilial("SWB") + AvKey(Work->EEQ_PREEMB,"W6_HAWB")+Work->WB_PO_DI+AvKey(Work->EEQ_NRINVO,"WB_INVOICE")+Work->WB_FORN+Work->WB_LOJA+AvKey(Work->EEQ_PARC,"WB_LINHA")})

//oSection:Print()
oReport:SetMeter(Work->(EasyRecCount() ))
Work->( dbGoTop() )

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Invoices"):Init()


//Laço principal
OnBrReport(3)
i := 1
Do While Work->(!EoF()) .And. !oReport:Cancel()
   i++
   oReport:Section("Invoices"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   cTpModAtu := Work->EEQSWB
   If lMultiFil
      cFilAtu   := Work->EEQ_FILIAL
   EndIf
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 2
oReport:Section("Invoices"):Finish()

Return .T.


************************************
Static Function OnBrReport(nBreak)
************************************
 Local lLastRec := .F.

   Work->( DBSkip() )
   If Work->( EoF() )
      lLastRec := .T.
   EndIf
   Work->( DBSkip(-1) )

   If !lLastRec
      If nBreak == 1  .And.  cTpModAtu+IIF(lMultiFil,cFilAtu,"") == Work->(EEQSWB+IIF(lMultiFil,EEQ_FILIAL,""))
         If lMultiFil
            oReport:Section("Cabeçalho"):Cell("EEQ_FILIAL"):Disable()
         EndIf
         oReport:Section("Cabeçalho"):Cell("EEQSWB"    ):Disable()
         oReport:Section("Cabeçalho"):Init()
         oReport:Section("Cabeçalho"):PrintLine()
         oReport:Section("Cabeçalho"):Finish()

      ElseIf nBreak == 2  .And.  cTpModAtu == Work->EEQSWB
         oReport:Section("Cabeçalho"):Cell("EEQSWB"    ):Disable()
         oReport:Section("Cabeçalho"):Init()
         oReport:Section("Cabeçalho"):PrintLine()
         oReport:Section("Cabeçalho"):Finish()

      ElseIf nBreak == 3
         If Work->EEQSWB == "SWB"  .And.  cModo == 1  //Analitico
            //oReport:Section("Invoices"):Cell("PREVIN"    ):Disable()   // Nopado por GFP - 22/05/2012
            oReport:Section("Invoices"):Cell("EEC_IMPORT"):cTitle:="FORNECEDOR"
         EndIf
         oReport:Section("Cabeçalho"):Init()
         oReport:Section("Cabeçalho"):PrintLine()
         oReport:Section("Cabeçalho"):Finish()
      EndIf
   EndIf

   If lMultiFil
      oReport:Section("Cabeçalho"):Cell("EEQ_FILIAL"):Enable()
   EndIf
   oReport:Section("Cabeçalho"):Cell("EEQSWB"    ):Enable()

Return .T.
