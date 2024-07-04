#include "Average.ch"
#include "EIC.CH"
#Include "TOPCONN.CH"

#define FECHTO_EMBARQUE       "1"
#define FECHTO_DESEMBARACO    "2"
#define FECHTO_NACIONALIZACAO "3"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Constantes da funcao AVGravaSC7 - integracao com SIGACOM     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define INCLUSAO  1
#define ALTERACAO 2
#define EXCLUSAO  3
#define NCM_GENERICA  "99999999"
#define GENERICO      "06"

*----------------------------------------------------------------------------
FUNCTION PosO1_It_Solic(PCC,PSi_Num,PCod_I,PReg,PSeq,cFil)
*----------------------------------------------------------------------------
* Posiciona o registro solicitado no arquivo de itens de S.I.s pelo Indice 1
LOCAL cFilialAtu:=If(Empty(cFil),xFilial("SW1"),cFil),nOldArea:=SELECT()   // GFP - 18/12/2012
Local lRet := .F.

/* RMD - 21/03/19 - Substituido por SQL para otimizar a performance
DBSELECTAREA("SW1")
DBSETORDER(1)
DBSEEK(/*xFilial("SW1")/cFilialAtu+PChave_P) // GFP - 18/12/2012

WHILE ! EOF() .AND. PChave_P = PChave_Si .AND. W1_FILIAL == cFilialAtu
   IF PReg # W1_REG .OR. W1_SEQ # PSeq
      DBSKIP()
      PChave_Si := W1_CC+W1_SI_NUM+W1_COD_I
      LOOP
   ENDIF
   SELECT(nOldArea)
   RETURN .T.
ENDDO
*/

//Se já estiver posicionado no registro desejado não executa o SQL
If SW1->(W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I) == cFilialAtu+PCC+PSi_NUM+PCod_I .And. SW1->W1_REG == PReg .And. SW1->W1_SEQ == PSeq
   lRet := .T.
Else
   BeginSQL Alias "ITSW1"
      Select R_E_C_N_O_ RECSW1 From %table:SW1% SW1
      Where SW1.%NotDel% And SW1.W1_FILIAL = %exp:cFilialAtu%
      And SW1.W1_CC = %exp:PCC% And SW1.W1_SI_NUM = %exp:PSi_Num% And SW1.W1_COD_I = %exp:PCod_I%
      And SW1.W1_REG = %exp:PReg% And SW1.W1_SEQ = %exp:PSeq%
   EndSql

   If ITSW1->(!Eof() .And. !Bof())
      SW1->(DbGoTo(ITSW1->RECSW1))
      lRet := .t.
   EndIf
   ITSW1->(DbCloseArea())
EndIf

SELECT(nOldArea)
RETURN lRet
*---------------------------------------------------------------------------
FUNCTION PosO2_It_Solic(PPoNum,PCC,PSi_Num,PCod_I,PFabr,PForn,PReg,PFabLoj,PForLoj)
*---------------------------------------------------------------------------
* Posiciona o registro solicitado no arquivo de itens de S.I.s pelo Indice 2
LOCAL cFilialAtu:=xFilial("SW1")
LOCAL lRet := .F.

/* MFR-12/09/2019 OSSME-3804
DBSELECTAREA("SW1")
DBSETORDER(2)
DBSEEK(cFilialAtu+PPoNum)

WHILE ! EOF() .AND. PPoNum = W1_PO_NUM .AND. cFilialAtu = W1_FILIAL
   IF PCod_I  # W1_COD_I  .OR. PCC    # W1_CC    .OR. ;
      PSi_NUM # W1_SI_NUM .OR. PFabr  # W1_FABR  .Or. (EICLoja() .And. PFabLoj # W1_FABLOJ) .OR. PForn # W1_FORN .OR. ;
      PReg    # W1_REG .Or. (EICLoja() .And. PForLoj # W1_FORLOJ)
      DBSKIP(); LOOP
   ENDIF
   RETURN.T.
ENDDO
*/

//MFR 20/09/2019
If !(SW1->W1_PO_NUM = PPoNum .And. SW1->W1_FILIAL = cFilialAtu .And. SW1->W1_COD_I = PCod_I .And. SW1->W1_CC = PCC .And. SW1->W1_SI_NUM = PSi_Num ;
                             .And. SW1->W1_FABR = PFabr .And. SW1->W1_FABLOJ = PFabLoj .And. SW1->W1_FORN = PForn .And. SW1->W1_FORLOJ = PFORLOJ .And. SW1->W1_REG = PReg)

  BeginSQL Alias "ITSW1"
      Select R_E_C_N_O_ RECSW1 From %table:SW1% SW1
      Where SW1.%NotDel% And SW1.W1_PO_NUM = %exp:PPoNum% And SW1.W1_FILIAL = %exp:cFilialAtu%
      And SW1.W1_COD_I = %exp:PCod_I% And SW1.W1_CC = %exp:PCC% 
      And SW1.W1_SI_NUM = %exp:PSi_Num% And SW1.W1_FABR = %exp:PFabr% And SW1.W1_FABLOJ = %exp:PFabLoj%
      And SW1.W1_FORN = %exp:PForn% And SW1.W1_FORLOJ = %exp:PFORLOJ%
      And SW1.W1_REG = %exp:PReg% 
   EndSql

   If ITSW1->(!Eof() .And. !Bof())
      SW1->(DbGoTo(ITSW1->RECSW1))
      lRet := .t.
   EndIf
   ITSW1->(DbCloseArea())
Else 
    lRet := .t. 
EndIf  
RETURN lRet
*--------------------------------------------------------------------------
FUNCTION PosO1_ItPedidos(PPo_Num,PCC,PSi_Num,PCod_I,PFabr,PForn,PReg,PSeq,PFabLoj,PForLoj,cFil)
*--------------------------------------------------------------------------
* Posiciona o registro solicitado no arquivo de itens de pedidos pelo Indice 1
LOCAL cFilialAtu:=If(Empty(cFil),xFilial("SW3"),cFil)
DBSELECTAREA("SW3")
If Select("EICSW3") > 0
   EICSW3->(DbCloseArea())
EndIf   

BeginSQL Alias "EICSW3"

         SELECT SW3.* FROM %Table:SW3%  SW3
                WHERE SW3.%NotDel% AND 
                      SW3.W3_FILIAL= %exp:cFilialAtu%  AND 
                      SW3.W3_PO_NUM = %exp:PPo_Num% AND 
                      SW3.W3_CC = %exp:PCC% AND
                      SW3.W3_SI_NUM = %exp:PSI_Num% AND
                      SW3.W3_COD_I = %exp:PCod_I% AND
                      SW3.W3_FABR = %exp:PFabr% AND
                      SW3.W3_FABLOJ = %exp:PFabLoj% AND
                      SW3.W3_FORN = %exp:PForn% AND
                      SW3.W3_FORLOJ = %exp:PForLoj% AND
                      SW3.W3_REG = %exp:PReg% AND
                      SW3.W3_SEQ = %exp:PSeq% 
         EndSql
   
      IF !EICSW3->(EOF()) 
         SW3->(DBGOTO(EICSW3->R_E_C_N_O_))
         RETURN .T.
      EndIf      
Return .F.      

*---------------------------------------------------------------------------
FUNCTION PosO2_ItPedidos(PPgi_Num,PCC,PSi_Num,PCod_I,PFabr,PForn,PReg,PFabLoj,PForLoj)
*---------------------------------------------------------------------------
* Posiciona o registro solicitado no arquivo de itens de guias pelo Indice 2
LOCAL cFilialAtu:=xFilial("SW3")
DBSELECTAREA("SW3")
DBSETORDER(2)
DBSEEK(cFilialAtu+PPgi_Num)

WHILE ! EOF() .AND. PPgi_Num = W3_PGI_NUM .AND. cFilialAtu = W3_FILIAL

   IF PFabr # W3_FABR .Or. (EICLoja() .And. PFabLoj # W3_FABLOJ) .OR. PForn   # W3_FORN .Or. (EICLoja() .And. PForLoj # W3_FORLOJ);
      .OR. PReg   # W3_REG .OR. PCC   # W3_CC   .OR. PSi_Num # W3_SI_NUM .OR. PCod_I # W3_COD_I
      DBSKIP() ; LOOP
   ENDIF
   RETURN .T.
ENDD
RETURN .F.
*----------------------------------------------------------------------------
FUNCTION PrxSeq_Is
*----------------------------------------------------------------------------
LOCAL cFilialAtu:=xFilial("SW1")
LOCAL PSeq:=0

   BeginSQL Alias "SEQW1"
      Select Max(W1_SEQ) MAXSEQ From %table:SW1% SW1
      Where SW1.%NotDel% And SW1.W1_FILIAL = %exp:cFilialAtu%
      And SW1.W1_CC = %exp:W1_CC% And SW1.W1_SI_NUM = %exp:W1_SI_NUM% And SW1.W1_COD_I = %exp:W1_COD_I%
      And SW1.W1_REG = %exp:W1_REG%
   EndSql

   If SEQW1->(!Eof() .And. !Bof())
      PSeq := SEQW1->MAXSEQ
   EndIf
   SEQW1->(DbCloseArea())

RETURN PSeq+1
*---------------------------------------------------------------------------
FUNCTION PosOrd1_It_Guias(PPgi_Num,PCC,PSi_Num,PCod_I,PFabr,PForn,PReg,PSeq,PPo_num,PFabLoj,PForLoj,cFil)
*---------------------------------------------------------------------------
* Posiciona o registro solicitado no arquivo de itens de guias pelo Indice 1

LOCAL cFilialAtu  := If(Empty(cFil),xFilial("SW5"),cFil)  // GFP - 18/12/2012
Local cQuery      := ""
Local lRet        := .F.
LOCAL cTmpTabSW5, cAnd
Default PFabLoj   := ""
Default PForLoj   := ""

DBSELECTAREA("SW5")

   cTmpTabSW5 := GetNextAlias()
   If Select(cTmpTabSW5) > 0
      (cTmpTabSW5)->(DbCloseArea())
   EndIf

   cAnd:= "W5.W5_FILIAL  = '" + cFilialAtu + "' "
   If PPo_num # NIL
      cAnd += "AND W5.W5_PO_NUM = '" + PPo_num + "' "
   EndIf
   cAnd += "AND W5.W5_COD_I = '" + PCod_I + "' "
   cAnd += "AND W5.W5_SEQ = " + AllTrim(Str(PSeq)) + " "  
   cAnd += "AND W5.W5_SI_NUM = '" + PSi_Num + "' "
   cAnd += "AND W5.W5_REG = " + AllTrim(Str(PReg)) + " "
   cAnd += "AND W5.W5_CC = '" + PCC + "' "
   cAnd += "AND W5.W5_FABR = '" + PFabr + "' "
   cAnd += "AND W5.W5_FABLOJ = '" + PFabLoj + "' "
   cAnd += "AND W5.W5_PGI_NUM = '"+PPgi_Num+"' " 
   cAnd += "AND W5.W5_FORN = '" + PForn + "' "
   cAnd += "AND W5.W5_FORLOJ = '" + PForLoj + "'"

   cQuery:= "Select W5.R_E_C_N_O_ from " + RetSqlName("SW5") + " W5 where W5.D_E_L_E_T_ <> '*' and " + cAnd
   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias (cTmpTabSW5) New

   If (cTmpTabSW5)->(!Eof()) .and. (cTmpTabSW5)->(!Bof())
      SW5->(DbGoTo( (cTmpTabSW5)->R_E_C_N_O_ ))
      lRet := .T.
   EndIf

   If Select(cTmpTabSW5) > 0
      (cTmpTabSW5)->(DbCloseArea())
   EndIf

RETURN lRet
*---------------------------------------------------------------------------
FUNCTION PosOrd2_It_Guias(PHawb,PCC,PSi_Num,PCod_I,PFabr,PForn,PReg,cPgi,cPO,cPosicao, PFabLoj, PForLoj)
*---------------------------------------------------------------------------
LOCAL cFilialAtu:=xFilial("SW5")
* Posiciona o registro solicitado no arquivo de itens de guias pelo Indice 2
DBSELECTAREA("SW5")

IF cPO == NIL .OR. cPosicao == NIL  .OR. cPgi == NIL  //NCF - 06/10/2010 - Comparação com "NIL" deve ser sinalizada por "=="
   SW5->(DBSETORDER(2))
   SW5->(DBSEEK(cFilialAtu+PHawb))
   WHILE ! EOF() .AND. cFilialAtu+PHawb == SW5->W5_FILIAL + SW5->W5_HAWB
      IF PCod_I  # SW5->W5_COD_I .OR. PCC   # SW5->W5_CC   .OR. PSi_NUM # SW5->W5_SI_NUM .OR. ;
         PFabr   # SW5->W5_FABR  .OR. PForn # SW5->W5_FORN .OR. PReg    # SW5->W5_REG    .OR. ;
         (cPo # NIL .AND. cPo # SW5->W5_PO_NUM)  .OR. (cPgi # NIL .AND. cPgi # SW5->W5_PGI_NUM);
         .Or. (EicLoja() .And. (PForLoj # SW5->W5_FORLOJ .Or. PFabLoj # SW5->W5_FABLOJ))
         SW5->(DBSKIP()); LOOP
      ENDIF
      RETURN .T.
   ENDDO
ELSE
   SW5->(DBSETORDER(8))
   SW5->(DBSEEK(cFilialAtu+cPgi+cPO+cPosicao))
   DO WHILE ! EOF() .AND. cFilialAtu+cPgi+cPO+cPosicao == SW5->W5_FILIAL+SW5->W5_PGI_NUM+SW5->W5_PO_NUM+SW5->W5_POSICAO
      IF SW5->W5_HAWB # PHawb
         SW5->(DBSKIP()); LOOP
      ENDIF
      RETURN .T.
   ENDDO
ENDIF

RETURN .F.
*----------------------------------------------------------------------------
FUNCTION PosO1_ItEs(PPgi_Num,PCod_I,PFabr,PForn,PReg,PSeq)
*----------------------------------------------------------------------------
* Posiciona o registro solicitado no arquivo de itens especiais de guias
* pelo Indice 1
LOCAL cFilialAtu:=xFilial("SWE")
LOCAL PChave_Es:=PChave_P:=PPgi_Num+PCod_I

DBSELECTAREA("SWE")
DBSETORDER(1)
DBSEEK(xFilial("SWE")+PChave_P)

WHILE ! EOF() .AND. PChave_P = PChave_Es .AND. WE_FILIAL == cFilialAtu
   IF PFabr # WE_FABR .OR. PForn # WE_FORN .OR. PReg # WE_REG .OR. WE_SEQ # PSeq
      DBSKIP()
      PChave_Es := WE_PGI_NUM+WE_COD_I
      LOOP
   ENDIF
   RETURN .T.
ENDDO
RETURN .F.

*----------------------------------------------------------------------------
FUNCTION PrxSeq_Ip
*----------------------------------------------------------------------------
LOCAL cFilialAtu:=xFilial("SW3")
LOCAL PSeq:=0

   BeginSQL Alias "SEQW3"
      Select Max(W3_SEQ) MAXSEQ From %table:SW3% SW3
      Where SW3.%NotDel% And SW3.W3_FILIAL = %exp:cFilialAtu%
      And SW3.W3_PO_NUM = %exp:W3_PO_NUM% And SW3.W3_CC = %exp:W3_CC% And SW3.W3_SI_NUM = %exp:W3_SI_NUM% And SW3.W3_COD_I = %exp:W3_COD_I%
      And SW3.W3_FORN = %exp:W3_FORN% And SW3.W3_FORLOJ = %exp:W3_FORLOJ% And SW3.W3_FABR = %exp:W3_FABR% And SW3.W3_FABLOJ = %exp:W3_FABLOJ% And SW3.W3_REG = %exp:W3_REG%
   EndSql

   If SEQW3->(!Eof() .And. !Bof())
      PSeq := SEQW3->MAXSEQ
   EndIf
   SEQW3->(DbCloseArea())

RETURN PSeq+1

*----------------------------------------------------------------------------
FUNCTION PrxSeq_Ie
*----------------------------------------------------------------------------
LOCAL cFilialAtu:=xFilial("SWE")
LOCAL PChave_Co:=PChave_Ie:=WE_PGI_NUM+WE_COD_I,;
      PFabr:=WE_FABR, PForn:=WE_FORN, PReg:=WE_REG, PSeq:=0

WHILE ! EOF() .AND. PChave_Co = PChave_Ie .AND. WE_FILIAL == cFilialAtu
   IF PFabr = WE_FABR  .AND. PForn = WE_FORN .AND. PReg = WE_REG
      PSeq := WE_SEQ
   ENDIF
   DBSKIP()
   PChave_Ie := WE_PGI_NUM+WE_COD_I
ENDD
RETURN PSeq+1

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Dias_Uteis ³ Autor ³ AVERAGE-MJBARROS     ³ Data ³ 16/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula No. Dias entre duas datas, eliminado Sab e Dom     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Dias_Uteis(DataInicial,DataFinal)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Data Inicial e Data Final (opcional, assume date           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
        Last change:  US   12 Mar 99    1:47 pm
*/
FUNCTION Dias_Uteis(PDt_ini,PDt_fim)
#define Sabado  "Saturday"
#define Domingo "Sunday"

LOCAL MDt_fim, MDias, MSemanas, MSab_Dom,;
      MDt_base, MPrazo

IF(Empty(PDt_fim))
   MDt_fim:= dDataBase
Else
   MDt_fim:= PDt_fim
Endif

MSab_Dom:=2 * ( MSemanas:=INT( (MDias:=MDt_fim-PDt_ini) / 7 ) )
MDt_base:=PDt_ini + MSemanas*7

WHILE MDt_base <= MDt_fim

      IF CDOW(MDt_base) = Sabado .OR. CDOW(MDt_base) = Domingo
         MSab_Dom++
      ENDIF

      MDt_base++
ENDDO

MPrazo:=If(MDias-MSab_Dom<0,0,MDias-MSab_Dom)

IF MPrazo > 99999
   MPrazo:=99999
ELSEIF MPrazo < -9999
   MPrazo:=99998
ENDIF
RETURN MPrazo
//TRP - 21/08/07 - Cálculo da quantidade de dias corridos a partir de duas datas
*--------------------------------------------------------------------------------
FUNCTION Dias_Corridos(PDt_ini,PDt_fim)
*--------------------------------------------------------------------------------
LOCAL MDt_fim,MDias,MPrazo

IF(Empty(PDt_fim))
   MDt_fim:= dDataBase
Else
   MDt_fim:= PDt_fim
Endif

MDias:=INT(MDt_fim-PDt_ini)

MPrazo:=If(MDias<0,0,MDias)

IF MPrazo > 99999
   MPrazo:=99999
ELSEIF MPrazo < -9999
   MPrazo:=99998
ENDIF
RETURN MPrazo

/*
Funcao      : Prazo_Prev(nDias,dDataIni,dDataCorridos)
Parametros  : nDias-> Prazo em dias considerando dias uteis
              dDataIni-> Data Inicial
              dDataCorridos-> Data Inicial que será incrementada para o cálculo do prazo baseando-se em dias corridos.
Retorno     : Prazo em dias considerando dias corridos
Objetivos   :
Autor       : Thiago Rinaldi Pinto

Data/Hora   : 21/08/07 10:30
Revisao     :
Obs.        :
*/
*-----------------------------------------------------------------------------
FUNCTION Prazo_Prev(nDias,dDataIni,dDataCorridos)
*-----------------------------------------------------------------------------
Local nDiasUteis := 0, nRetorno := 0
Local lPara := .T.

Begin Sequence
   If nDias == 0
      Break
   Else
      Do While lPara
         If ! (CDOW(dDataCorridos) == "Saturday" .OR. CDOW(dDataCorridos) == "Sunday")
            nDiasUteis+= 1
         Endif
         dDataCorridos+= 1

         If nDiasUteis == nDias
            lPara := .F.
         Endif

      Enddo
      nRetorno := INT(dDataCorridos - dDataIni)
   EndIf
End Sequence

Return nRetorno
*----------------------------------------------------------------------------
FUNCTION PO_Grava(bMsg)
*----------------------------------------------------------------------------
LOCAL Ind_SI ,I
LOCAL cFase:="PO"
LOCAL lGrvMerck:=.T. // lGravaSC7,
LOCAL TabSI_Num:={}, TabSI_DT:={}
LOCAL _PictITem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictQC   := ALLTRIM(X3PICTURE("WR_NR_CONC"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
Local lAltItemPO := .F.
Local aChaves := {}
Local aOrdSC3 := {} //LGS-23/03/2015
Local lSC7    := .F.
Private lW2ConaPro, lGravaSC7 // By JPP - 05/02/2008 - 14:00
PRIVATE lDtEntrega := .T. // RA - 06/08/2003
Private lAltCapPO:=.F.
Private lEXECAUTO_COM := if( IsMemVar("lEXECAUTO_COM") , lEXECAUTO_COM,  /*EasyGParam("MV_EIC0008",,.F.) FIXO .T. OSSME-6437 MFR 06/12/2021.And. */ EasyGParam("MV_EASY",,"N") == "S")
Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL")//AOM - Operacao Especiais
SX3->(DbSetOrder(2))
lW2ConaPro:=SW2->(FIELDPOS("W2_CONAPRO")) # 0 .AND. EasyGParam("MV_AVG0170",,.F.)  //TRP-28/08/08- Teste do parâmetro MV_AVG0170 para definir se habilita Controle de Alçadas no EIC.
SX3->(DbSetOrder(1))

DBSELECTAREA("Work")
SET FILTER TO
DBGOTOP()

If Type("lPoAuto") == "U"
   lPoAuto:= .F.
EndIf

If Type("lCpoCtCust") == "U"
   lCpoCtCust:= .F.
EndIf

If Type("lPesoBruto") == "U"
   lPesoBruto:= .F.
EndIf

If !(lPoAuto) //FSM - 17/05/2012
   ProcRegua(EasyRecCount()+2)
EndIf
Ind_SI  := 1

If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("PURCHASE ORDER")
EndIf

//AOM - 09/04/2011 - Salva controle de operações especiais do PO
If lOperacaoEsp .And. Type("oOperacao") == "0"
   oOperacao:SaveOperacao()
EndIf

*---------------------------------------------------------------------------
* INICIA O CONTROLE DE TRANSACAO
*---------------------------------------------------------------------------
Begin Transaction


   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ GRAVA CAPA DO PEDIDO                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PO420GrvPO000("2")  && ALTERADO POR RJB PARA GRAVAR A PRIMEIRA TELA

   cAlter:=""
   DBSELECTAREA("Work")
   Work->(dbGoTop())
   DO WHILE .NOT. Work->(EOF())
      If !(lPoAuto) //FSM - 17/05/2012
         IncProc(STR0001+ALLTRIM(Work->WKCOD_I))//"Gravando Item: "
      EndIf

      IF ! Work->WK_ALTEROU
         Work->(dbSkip())
         LOOP
      ElseIf !lAltItemPO
         lAltItemPO := .T.
      ENDIF

      IF .NOT. Work->WKFLAG .AND. Work->WKFLAG2 = .F.
         DBSKIP()
         LOOP
      ENDIF

      lGrava_Fluxo:= .F.
      IF EMPTY(nSeq_SLi)
         IF Work->WKFLUXO == "7"
            // GFP - 02/08/2013 - Substituido SetMV por PutMV pois o PutMV possui tratamento de filiais.
            //IF ! PutMv("MV_SEQ_LI",STRZERO(EasyGParam("MV_SEQ_LI")+1,8,0))  //SetMV("MV_SEQ_LI",STRZERO(EasyGParam("MV_SEQ_LI")+1,8,0))
            //   DBSKIP()
            //   LOOP
            //Endif

            nSeq_SLi :="*"+EasyGetMVSeq("MV_SEQ_LI")+"*"
         ENDIF
      ENDIF

      lAtuSW0:=.F.
      IF Work->WKFLAG2
         DO CASE
            CASE .NOT. Work->WKFLAG
                 lAtuSW0:=.T.
            CASE Work->WKFLAG .AND. Work->WKQTDE > Work->WKSALDO_O
                 lAtuSW0:=.T.
            CASE Work->WKFLAG .AND. Work->WKQTDE < Work->WKSALDO_O
                 lAtuSW0:=.T.
            OTHERWISE
                 lAtuSW0:=.F.
         ENDCASE
      ELSE
         lAtuSW0:=.T.
      ENDIF

      IF lAtuSW0

         IF ASCAN(TabSI_Num,Work->WKSI_NUM) = 0
            AAdd(TabSI_Num,Work->WKSI_NUM) //mjb150999
//          DBSELECTAREA("SW0")
            SW0->(DBSEEK(xFilial()+Work->WKCC + Work->WKSI_NUM))
            AAdd(TabSI_DT,SW0->W0__DT) //mjb150999
         ENDIF

      ENDIF

      IF Work->WKFLAG

         IF .NOT. Work->WKFLAG2          // inclusao de P.O.

            DBSELECTAREA("SW1")
            DBSETORDER(1)

            MCla:= SPACE(1)
            IF PosO1_It_Solic(Work->WKCC,Work->WKSI_NUM,;
                              Work->WKCOD_I,Work->WKREG,0)
               RecLock("SW1",.F.)
               SW1->W1_SALDO_Q :=  SW1->W1_SALDO_Q - Work->WKQTDE
               MSUnlock()
               MCla:= SW1->W1_CLASS

               //LGS-23/03/2015 - Atualiza a quantidade utilizada no item correspondente da 'SC3' qdo for 'CONTRATO'
               If SW0->(FieldPos("W0_CONTR"))>0 .And. SW2->(FieldPos("W2_CONTR"))>0 .AND. !lEXECAUTO_COM //AAF 30/12/2016 - Nao executar caso seja execauto, pois o mesmo ja atualiza o contrato.
                  If M->W2_CONTR == '1' .AND. !AvFlags("EIC_EAI")
                     aOrdSC3 := SaveOrd({"SC3"})
                     SC3->(DbSetOrder(1))
                     If SC3->(DbSeek(xFilial("SC3")+SW1->(W1_C3_NUM+W1_POSIT)))
                        If !SC3->(IsLocked())
                           SC3->(RecLock("SC3",.F.))
                           lSC3 := .T.
                        EndIf
                        SC3->C3_QUJE := SW1->(W1_QTDE - W1_SALDO_Q)
                        If lSC3
                           SC3->(MsUnLock())
                        EndIf
                     EndIf
                     RestOrd(aOrdSC3,.T.)
                  EndIf
               EndIf

            ENDIF
            MSeq:= PrxSeq_Is()

            RecLock("SW1",.T.) // lock com append
            REPLACE   W1_COD_I     WITH  Work->WKCOD_I    ,;
                      W1_FABR      WITH  Work->WKFABR     ,;
                      W1_FORN      WITH  Work->WKFORN     ,;
                      W1_REG       WITH  Work->WKREG      ,;
                      W1_FLUXO     WITH  Work->WKFLUXO    ,;
                      W1_QTDE      WITH  Work->WKQTDE     ,;
                      W1_SALDO_Q   WITH  0                ,;
                      W1_SI_NUM    WITH  Work->WKSI_NUM   ,;
                      W1_PO_NUM    WITH  TPO_NUM          ,;
                      W1_DTENTR_   WITH  Work->WKDTENTR_S ,;
                      W1_SEQ       WITH  MSeq             ,;
                      W1_POSICAO   WITH  Work->WKPOSICAO  ,;
                      W1_CLASS     WITH  MCla             ,;
                      W1_CC        WITH  Work->WKCC       ,;
                      W1_FILIAL    WITH  xFilial("SW1")
            If EICLoja()
               SW1->W1_FORLOJ := Work->W3_FORLOJ
               SW1->W1_FABLOJ := Work->W3_FABLOJ
            EndIf

            MSUnlock()

            //FKCOMMIT: P/ forçar a execução do comando no SQL. - Johann - 21/07/05
            FKCOMMIT()

            DBSELECTAREA("SW3")
            TNr_Cont:= TNr_Cont + 1
            RecLock("SW3",.T.) // lock com append

            //AOM - 08/04/2011 - Gravação dos campos com mesmo nome da base
            AVREPLACE("Work","SW3")

            SW3->W3_COD_I    :=   Work->WKCOD_I
            SW3->W3_FABR     :=   Work->WKFABR
            SW3->W3_FABR_01  :=   Work->WKFABR_01
            SW3->W3_FABR_02  :=   Work->WKFABR_02
            SW3->W3_FABR_03  :=   Work->WKFABR_03
            SW3->W3_FABR_04  :=   Work->WKFABR_04
            SW3->W3_FABR_05  :=   Work->WKFABR_05
            SW3->W3_FORN     :=   Work->WKFORN
            SW3->W3_FLUXO    :=   Work->WKFLUXO
            SW3->W3_QTDE     :=   Work->WKQTDE
            SW3->W3_PRECO    :=   Work->WKPRECO
            SW3->W3_SALDO_Q  :=   Work->WKQTDE
            SW3->W3_SI_NUM   :=   Work->WKSI_NUM
            SW3->W3_PO_NUM   :=   TPO_NUM
            SW3->W3_DT_EMB   :=   Work->WKDT_EMB
            SW3->W3_DT_ENTR  :=   Work->WKDT_ENTR
            SW3->W3_POSICAO  :=   Work->WKPOSICAO
            SW3->W3_PORTARI :=   Work->WKPORTARIA
            SW3->W3_SEQ      :=   0
            SW3->W3_REG      :=   Work->WKREG
            SW3->W3_NR_CONT  :=   TNr_Cont
            SW3->W3_CC       :=   Work->WKCC
            SW3->W3_FILIAL   :=   xFilial("SW3")
            SW3->W3_REG_TRI  :=   Work->WK_REG_TRI
            SW3->W3_TEC      :=   Work->WK_TEC
            SW3->W3_EX_NCM   :=   Work->WK_EX_NCM
            SW3->W3_EX_NBM   :=   Work->WK_EX_NBM
            If AvFlags("RATEIO_DESP_PO_PLI")
               SW3->W3_FRETE    :=   Work->WKFRETE
               SW3->W3_SEGURO   :=   Work->WKSEGUR
               SW3->W3_INLAND   :=   Work->WKINLAN
               SW3->W3_DESCONT  :=   Work->WKDESCO
               SW3->W3_PACKING  :=   Work->WKPACKI
               If SW3->(FieldPos("W3_OUT_DES")) > 0
                  SW3->W3_OUT_DES := Work->WKOUTDE
               EndIf
            EndIf
            If EICLoja()
               SW3->W3_FABLOJ	:= Work->W3_FABLOJ
               SW3->W3_FORLOJ	:= Work->W3_FORLOJ
               SW3->W3_FAB1LOJ	:= Work->W3_FAB1LOJ
               SW3->W3_FAB2LOJ	:= Work->W3_FAB2LOJ
               SW3->W3_FAB3LOJ	:= Work->W3_FAB3LOJ
               SW3->W3_FAB4LOJ	:= Work->W3_FAB4LOJ
               SW3->W3_FAB5LOJ	:= Work->W3_FAB5LOJ
            EndIf
            If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
               SW3->W3_PESOL := Work->WKPESOL
            EndIf

            If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
               SW3->W3_PART_N  := Work->WKPART_N
            EndIf

            //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
            If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
               SW3->W3_SOFTWAR := Work->WKSOFTWAR
            Endif

            //EOB- 20/01/10 - Campo Regime de tributação
            SW3->W3_GRUPORT := Work->WKGRUPORT

            If lCpoCtCust                          //NCF - 22/06/2010 - Campo do centro de Custo
               SW3->W3_CTCUSTO := Work->WKCTCUSTO
            EndIf
            If lPesoBruto                          //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
               SW3->W3_PESO_BR := Work->WKPSBRUTO
            EndIf

            //FSM - 16/05/2012 - Admissão em Entreposto
            If EasyGParam("MV_AVG0211",,.F.) .And. SW3->(FieldPos("W3_ALTANU")) > 0
               SW3->W3_ALTANU := Work->WKALTANU
            EndIf

            IF AvFlags("EIC_EAI")//AWF - 25/06/2014
               SW3->W3_UM     :=Work->WKUNI
               SW3->W3_SEGUM  :=Work->WKSEGUM
               SW3->W3_QTSEGUM:=Work->WKQTSEGUM
            ENDIF

            IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"8"),) //AWR 01/10/1999

            If lForeCast
               REPLACE W3_FORECAS WITH Work->WK_FORECAS
            Endif

            If lNestle
               ExecBlock(cArqNestle,.F.,.F.,"7")
            Endif

            IF lRdMake
               Work->(ExecBlock("EICPPO02",.F.,.F.,"23"))
            ENDIF
            IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"GRAVA_DESPESAS"),)

            DBSELECTAREA('Work')

            SW3->(MSUnlock())	//Johann

            IF EasyEntryPoint("IC023PO1")
               EasyExRdm("U_IC023PO1", "Int100Solic_W3",{.F.,.T.})               
            ENDIF

            IF Work->WKFLUXO == "7"
               Po420GrvGI()
               Po420GrvIG(.T.)
               RecLock("SW3",.F.)
               SW3->W3_SALDO_Q:=0
               SW3->(MSUnlock())
               Po420GrvIP()
            ENDIF

            DBSELECTAREA('Work')

            SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
            If cProg#"PN"
            //ACB - 18/03/2011 - Envio do centro custo ao comprras
            If SW3->(FieldPos("W3_CTCUSTO")) > 0
               cCentroCusto := SW3->W3_CTCUSTO
            Else
               cCentroCusto := SW3->W3_CC
            EndIf
               If !lEXECAUTO_COM
                  AVGravaSC7(INCLUSAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                          IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                          SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                          SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;//'01'
                          Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N", SW2->W2_PO_NUM,;
                          If(lW2ConaPro,SW2->W2_CONAPRO,Nil),SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES+W2_FRETEIN),SW2->W2_DESCONT)

                  Alcada_EIC(.T.) //LRS - 22/09/2017
                 
                  If SW0->(FieldPos("W0_CONTR"))>0 .And. SW2->(FieldPos("W2_CONTR"))>0 //MCF-01/04/2015
                     IF (M->W2_CONTR == '1') .AND. !AvFlags("EIC_EAI")
                        If !SC7->(IsLocked())
                           SC7->(RecLock("SC7",.F.))
                           lSC7 := .T.
                        EndIf
                        SC7->C7_TIPO := 2
                        If lSC7
                           SC7->(MsUnLock())
                        EndIf
                     ENDIF
                  EndIf
               /* RMD - 27/03/19 - Não é necessário executar aqui, pois a rotina que efetua o Execauto já chama o controle de alçadas
               ElseIF !lW2ConaPro
                 Alcada_EIC(.T.) //LRS - 22/09/2017*/
               EndIf
            EndIf

         ELSE     // alteracao (pode ter ocorrido inclusao de itens)

            //IF Work->WKQTDE > Work->WKQTDE_O //Work->WKSALDO_O //comentado por wfs
            IF Work->WKQTDE > Work->WKQTDE_O .Or. (AvFlags("EIC_EAI") .And. Work->WK_ALTEROU)

               DBSELECTAREA("SW1")
               DBSETORDER(1)
               IF PosO1_It_Solic(Work->WKCC,Work->WKSI_NUM,;
                                 Work->WKCOD_I,Work->WKREG,0)
                  RecLock("SW1",.F.)
                //REPLACE  W1_SALDO_Q WITH W1_SALDO_Q - ( Work->WKQTDE - Work->WKSALDO_O )
                  SW1->W1_SALDO_Q := SW1->W1_SALDO_Q - ( Work->WKQTDE - Work->WKQTDE_O )
                  MSUnlock()

                  //LGS-23/03/2015 - Atualiza a quantidade utilizada no item correspondente da 'SC3' qdo for 'CONTRATO'
                  If SW0->(FieldPos("W0_CONTR"))>0 .And. SW2->(FieldPos("W2_CONTR"))>0 .AND. !lEXECAUTO_COM //AAF 30/12/2016 - Nao executar caso seja execauto, pois o mesmo ja atualiza o contrato.
                     If M->W2_CONTR == '1'
                        aOrdSC3 := SaveOrd({"SC3"})
                        SC3->(DbSetOrder(1))
                        If SC3->(DbSeek(xFilial("SC3")+SW1->(W1_C3_NUM+W1_POSIT)))
                           If !SC3->(IsLocked())
                              SC3->(RecLock("SC3",.F.))
                              lSC3 := .T.
                           EndIf
                           SC3->C3_QUJE := SW1->(W1_QTDE - W1_SALDO_Q)
                           If lSC3
                              SC3->(MsUnLock())
                           EndIf
                        EndIf
                        RestOrd(aOrdSC3,.T.)
                     EndIf
                  EndIf

               ENDIF

               DBSETORDER(2)

               IF PosO2_It_Solic(Work->WKPO_NUM,Work->WKCC,;
                                 Work->WKSI_NUM,Work->WKCOD_I,;
                                 Work->WKFABR_O,Work->WKFORN_O,;
                                 Work->WKREG,IF(EICLOJA(),Work->W3_FABL_O,""),IF(EICLOJA(), Work->W3_FORL_O,""))

                  RecLock("SW1",.F.)
                //REPLACE W1_QTDE WITH W1_QTDE + ( Work->WKQTDE - Work->WKSALDO_O ) ,;
                  REPLACE W1_QTDE WITH W1_QTDE + ( Work->WKQTDE - Work->WKQTDE_O ) ,;
                          W1_POSICAO  WITH   Work->WKPOSICAO  ,;
                          W1_FABR WITH Work->WKFABR ,;
                          W1_FORN WITH Work->WKFORN
                  If EICLoja()
                     SW1->W1_FORLOJ := Work->W3_FORLOJ
                     SW1->W1_FABLOJ := Work->W3_FABLOJ
                  EndIf
                  MSUnlock()
               ENDIF

               DBSELECTAREA("SW3")
               DBSETORDER(1)

               lGravaSC7 := .F.
               IF PosO1_ItPedidos(Work->WKPO_NUM,Work->WKCC,;
                                  Work->WKSI_NUM,Work->WKCOD_I,;
                                  Work->WKFABR_O,Work->WKFORN_O,;
                                  Work->WKREG,Work->WKSEQ, EICRetLoja("Work", "W3_FABL_O"), EICRetLoja("WORK", "W3_FORL_O"))
                  lGravaSC7 := .T.
                  lGrvMerck := (SW3->W3_DT_ENTR > Work->WKDT_ENTR)
                  RecLock("SW3",.F.) // regrava sequencia zero
                  AVREPLACE("Work","SW3")//AOM - 08/04/2011
                  SW3->W3_QTDE     := Work->WKQTDE//W3_QTDE    +  ( Work->WKQTDE - Work->WKSALDO_O )
                  SW3->W3_SALDO_Q  := W3_SALDO_Q +  ( Work->WKQTDE - Work->WKQTDE_O )//Work->WKSALDO_O )
                  SW3->W3_PRECO    := Work->WKPRECO
                  SW3->W3_DT_EMB   := Work->WKDT_EMB
                  SW3->W3_DT_ENTR  := Work->WKDT_ENTR
                  SW3->W3_POSICAO  := Work->WKPOSICAO
                  SW3->W3_PORTARI := Work->WKPORTARIA
                  SW3->W3_FABR_01  := Work->WKFABR_01
                  SW3->W3_FABR_02  := Work->WKFABR_02
                  SW3->W3_FABR_03  := Work->WKFABR_03
                  SW3->W3_FABR_04  := Work->WKFABR_04
                  SW3->W3_FABR_05  := Work->WKFABR_05
                  SW3->W3_FABR     := Work->WKFABR
                  SW3->W3_FORN     := Work->WKFORN
                  SW3->W3_FLUXO    := Work->WKFLUXO
                  SW3->W3_REG_TRI  := Work->WK_REG_TRI
                  SW3->W3_TEC      := Work->WK_TEC
                  SW3->W3_EX_NCM   := Work->WK_EX_NCM
                  SW3->W3_EX_NBM   := Work->WK_EX_NBM
                  If AvFlags("RATEIO_DESP_PO_PLI")
                     SW3->W3_FRETE    :=   Work->WKFRETE
                     SW3->W3_SEGURO   :=   Work->WKSEGUR
                     SW3->W3_INLAND   :=   Work->WKINLAN
                     SW3->W3_DESCONT  :=   Work->WKDESCO
                     SW3->W3_PACKING  :=   Work->WKPACKI
                     If SW3->(FieldPos("W3_OUT_DES")) > 0
                        SW3->W3_OUT_DES := Work->WKOUTDE
                     EndIf
                  EndIf
                  If EICLoja()
                     SW3->W3_FABLOJ		:= Work->W3_FABLOJ
                     SW3->W3_FORLOJ		:= Work->W3_FORLOJ
                     SW3->W3_FAB1LOJ	:= Work->W3_FAB1LOJ
                     SW3->W3_FAB2LOJ	:= Work->W3_FAB2LOJ
                     SW3->W3_FAB3LOJ	:= Work->W3_FAB3LOJ
                     SW3->W3_FAB4LOJ	:= Work->W3_FAB4LOJ
                     SW3->W3_FAB5LOJ	:= Work->W3_FAB5LOJ
                  EndIf
                  If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
                     SW3->W3_PART_N  := Work->WKPART_N
                  EndIf

                  If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
                     SW3->W3_PESOL := Work->WKPESOL
                  EndIf

                  //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
                  If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
                     SW3->W3_SOFTWAR := Work->WKSOFTWAR
                  Endif

                  If lCpoCtCust                           //NCF - 22/06/2010 - Campo do centro de Custo
                     SW3->W3_CTCUSTO := Work->WKCTCUSTO
                  EndIf

                  If lPesoBruto                           //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
                     SW3->W3_PESO_BR := Work->WKPSBRUTO
                  EndIf

                  //EOB- 20/01/10 - Campo Regime de tributação
                  SW3->W3_GRUPORT := Work->WKGRUPORT

                  IF EasyEntryPoint("IC023PO1")                     
                     EasyExRdm("U_IC023PO1", "Int100Solic_W3",{lGrvMerck,.T.})                     
                  ENDIF

                  IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"8"),) //AWR 01/10/1999

                  If lForeCast
                     REPLACE W3_FORECAS WITH Work->WK_FORECAS
                  Endif

                  //FSM - 16/05/2012 - Admissão em Entreposto
                  If EasyGParam("MV_AVG0211",,.F.) .And. SW3->(FieldPos("W3_ALTANU")) > 0
                     SW3->W3_ALTANU := Work->WKALTANU
                  EndIf

                  If lNestle
                     ExecBlock(cArqNestle,.F.,.F.,"7")
                  Endif
                  IF lRdMake
                    Work->(ExecBlock("EICPPO02",.F.,.F.,"23"))
                  ENDIF

                  IF AvFlags("EIC_EAI")//AWF - 25/06/2014
                     SW3->W3_UM     :=Work->WKUNI
                     SW3->W3_SEGUM  :=Work->WKSEGUM
                     SW3->W3_QTSEGUM:=Work->WKQTSEGUM
                  ENDIF

                  IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"GRAVA_DESPESAS"),)
                  //BHF - 10/09/08
                  //TRP-15/05/07
                  //MFR 16/09/2019 OSSME-3804
                  /*
                  aOrd := SaveOrd("SX3",1)
                  SX3->(dbSeek("SW3"))
                  While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
                     If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
                        Eval(FieldWBlock(SX3->X3_CAMPO, Select("SW3")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work"))))
                     EndIF
                     SX3->(dbSkip())
                  Enddo
                  RestOrd(aOrd)
                  MSUnlock()
                  */
               ENDIF

               lGrava_Fluxo:=.T.

               IF lGravaSC7
                  SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
                  If cProg#"PN"

                  //ACB - 18/03/2011 - Envio do centro de custo ao compras
                  If SW3->(FieldPos("W3_CTCUSTO")) > 0
                     cCentroCusto := SW3->W3_CTCUSTO
                  Else
                     cCentroCusto := SW3->W3_CC
                  EndIf
                     If !lEXECAUTO_COM
                        AVGravaSC7(ALTERACAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                            IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                            SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                            SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;//'01'
                            Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N", SW2->W2_PO_NUM,;
                            If(lW2ConaPro,SW2->W2_CONAPRO,Nil),SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES+W2_FRETEIN),SW2->W2_DESCONT)
                     EndIf
                  EndIf
               Endif

            ELSEIF Work->WKQTDE < Work->WKQTDE_O//Work->WKSALDO_O

               DBSELECTAREA("SW1")
               DBSETORDER(1)
 //MFR Comentada a rotina do LRS e retornada a rotina original, pois estava dando erro no saldo da SI quando tinha mais d euma vez o mesmo produto
 //TE-4945
               IF PosO1_It_Solic(Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I,Work->WKREG,0)
//               IF DBSEEK(xFilial("SW1")+Work->WKCC+Work->WKSI_NUM+Work->WKCOD_I) //LRS - 17/11/2014 - Colocado o DBSEEK para verificar o item na Work
                  RecLock("SW1",.F.)
                //REPLACE  W1_SALDO_Q WITH W1_SALDO_Q + ( Work->WKSALDO_O - Work->WKQTDE )
                  SW1->W1_SALDO_Q := SW1->W1_SALDO_Q + ( Work->WKQTDE_O  - Work->WKQTDE )
                  MSUnlock()
               ENDIF

               DBSETORDER(2)
               IF PosO2_It_Solic(Work->WKPO_NUM,Work->WKCC,;
                                 Work->WKSI_NUM,Work->WKCOD_I,;
                                 Work->WKFABR_O,Work->WKFORN_O,;
                                 Work->WKREG,IF(EICLOJA(),Work->W3_FABL_O,""),IF(EICLOJA(), Work->W3_FORL_O,""))

                  RecLock("SW1",.F.)
                //REPLACE W1_QTDE WITH W1_QTDE - ( Work->WKSALDO_O - Work->WKQTDE ),;
                  REPLACE W1_QTDE WITH W1_QTDE - ( Work->WKQTDE_O - Work->WKQTDE ),;
                          W1_POSICAO  WITH   Work->WKPOSICAO  ,;
                          W1_FABR WITH Work->WKFABR ,;
                          W1_FORN WITH Work->WKFORN
                  If EICLoja()
                     SW1->W1_FORLOJ := Work->W3_FORLOJ
                     SW1->W1_FABLOJ := Work->W3_FABLOJ
                  EndIf
                  MSUnlock()
               ENDIF
               IF lCancelaSaldo
                  EICPO411(1)
               ENDIF

               DBSELECTAREA("SW3")
               DBSETORDER(1)

               lGravaSC7 := .F.
               IF PosO1_ItPedidos(Work->WKPO_NUM,Work->WKCC,;
                                  Work->WKSI_NUM,Work->WKCOD_I,;
                                  Work->WKFABR_O,Work->WKFORN_O,;
                                  Work->WKREG,Work->WKSEQ, EICRetLoja("Work", "W3_FABL_O"), EICRetLoja("WORK", "W3_FORL_O"))

                  lGravaSC7 := .T.
                  lGrvMerck := (SW3->W3_DT_ENTR > Work->WKDT_ENTR)
                  RecLock("SW3",.F.)
                  AVREPLACE("Work","SW3")//AOM - 08/04/2011
                //SW3->W3_QTDE     := SW3->W3_QTDE    -  ( Work->WKSALDO_O - Work->WKQTDE )
                //SW3->W3_SALDO_Q  := SW3->W3_SALDO_Q -  ( Work->WKSALDO_O - Work->WKQTDE )
                  SW3->W3_QTDE     := Work->WKQTDE
                  SW3->W3_SALDO_Q  := Work->WKQTDE //SW3->W3_SALDO_Q -  ( Work->WKQTDE_O - Work->WKQTDE )
                  SW3->W3_POSICAO  := Work->WKPOSICAO
                  SW3->W3_PRECO    := Work->WKPRECO
                  SW3->W3_DT_EMB   := Work->WKDT_EMB
                  SW3->W3_DT_ENTR  := Work->WKDT_ENTR
                  SW3->W3_PORTARI := Work->WKPORTARIA
                  SW3->W3_FABR_01  := Work->WKFABR_01
                  SW3->W3_FABR_02  := Work->WKFABR_02
                  SW3->W3_FABR_03  := Work->WKFABR_03
                  SW3->W3_FABR_04  := Work->WKFABR_04
                  SW3->W3_FABR_05  := Work->WKFABR_05
                  SW3->W3_FABR     := Work->WKFABR
                  SW3->W3_FORN     := Work->WKFORN
                  SW3->W3_FLUXO    := Work->WKFLUXO
                  SW3->W3_REG_TRI  := Work->WK_REG_TRI
                  SW3->W3_TEC    := Work->WK_TEC
                  SW3->W3_EX_NCM := Work->WK_EX_NCM
                  SW3->W3_EX_NBM := Work->WK_EX_NBM
                  If AvFlags("RATEIO_DESP_PO_PLI")
                     SW3->W3_FRETE    :=   Work->WKFRETE
                     SW3->W3_SEGURO   :=   Work->WKSEGUR
                     SW3->W3_INLAND   :=   Work->WKINLAN
                     SW3->W3_DESCONT  :=   Work->WKDESCO
                     SW3->W3_PACKING  :=   Work->WKPACKI
                     If SW3->(FieldPos("W3_OUT_DES")) > 0
                        SW3->W3_OUT_DES := Work->WKOUTDE
                     EndIf
                  EndIf
                  If EICLoja()
                     SW3->W3_FABLOJ		:= Work->W3_FABLOJ
                     SW3->W3_FORLOJ		:= Work->W3_FORLOJ
                     SW3->W3_FAB1LOJ	:= Work->W3_FAB1LOJ
                     SW3->W3_FAB2LOJ	:= Work->W3_FAB2LOJ
                     SW3->W3_FAB3LOJ	:= Work->W3_FAB3LOJ
                     SW3->W3_FAB4LOJ	:= Work->W3_FAB4LOJ
                     SW3->W3_FAB5LOJ	:= Work->W3_FAB5LOJ
                  EndIf
                  If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
                     SW3->W3_PART_N  := Work->WKPART_N
                  EndIf

                  If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
                     SW3->W3_PESOL := Work->WKPESOL
                  EndIf

                  //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
                  If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
                     SW3->W3_SOFTWAR := Work->WKSOFTWAR
                  Endif

                  If lCpoCtCust                           //NCF - 22/06/2010 - Campo do centro de Custo
                     SW3->W3_CTCUSTO := Work->WKCTCUSTO
                  EndIf
                  If lPesoBruto                           //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
                     SW3->W3_PESO_BR := Work->WKPSBRUTO
                  EndIf

                  //FSM - 16/05/2012 - Admissão em Entreposto
                  If EasyGParam("MV_AVG0211",,.F.)  .And. SW3->(FieldPos("W3_ALTANU")) > 0
                     SW3->W3_ALTANU := Work->WKALTANU
                  EndIf

                  IF AvFlags("EIC_EAI")//AWF - 25/06/2014
                     SW3->W3_UM     :=Work->WKUNI
                     SW3->W3_SEGUM  :=Work->WKSEGUM
                     SW3->W3_QTSEGUM:=Work->WKQTSEGUM
                  ENDIF

                  If lForeCast
                     REPLACE W3_FORECAS WITH Work->WK_FORECAS
                  Endif

                  //EOB- 20/01/10 - Campo Regime de tributação
                  SW3->W3_GRUPORT := Work->WKGRUPORT

                  IF EasyEntryPoint("IC023PO1")
                     EasyExRdm("U_IC023PO1", "Int100Solic_W3",{lGrvMerck,.T.})                     
                  ENDIF

                  IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"8"),) //AWR 05/05/1999

                  If lNestle
                     ExecBlock(cArqNestle,.F.,.F.,"7")
                  Endif
                  IF lRdMake
                     Work->(ExecBlock("EICPPO02",.F.,.F.,"23"))
                  ENDIF
                  IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"GRAVA_DESPESAS"),)
                  //BHF - 10/09/08
                  //TRP-15/05/07
                  //MFR 16/09/2019 OSSME-3804
                  /*
                  aOrd := SaveOrd("SX3",1)
                  SX3->(dbSeek("SW3"))
                  While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
                     If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
                        Eval(FieldWBlock(SX3->X3_CAMPO, Select("SW3")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work"))))
                     EndIF
                     SX3->(dbSkip())
                  Enddo
                  RestOrd(aOrd)

                  MSUnlock()
                  */
               ENDIF

               lGrava_Fluxo:= .T.

               IF lGravaSC7
                  SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
                  If cProg#"PN"

                  //ACB - 18/03/2011 - envio do centro de custo ao compras
                  If SW3->(FieldPos("W3_CTCUSTO")) > 0
                     cCentroCusto := SW3->W3_CTCUSTO
                  Else
                     cCentroCusto := SW3->W3_CC
                  EndIf
                     If !lEXECAUTO_COM
                        AVGravaSC7(ALTERACAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                           IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                           SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                           SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;//'01'
                           Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N", SW2->W2_PO_NUM,;
                          If(lW2ConaPro,SW2->W2_CONAPRO,Nil),SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES+W2_FRETEIN),SW2->W2_DESCONT)
                     EndIf
                  EndIf
               Endif

            ELSE
               DBSELECTAREA("SW3")
               DBSETORDER(1)

               lGravaSC7 := .F.
               IF PosO1_ItPedidos(Work->WKPO_NUM,Work->WKCC,;
                                  Work->WKSI_NUM,Work->WKCOD_I,;
                                  Work->WKFABR_O,Work->WKFORN_O,;
                                  Work->WKREG,Work->WKSEQ, EICRetLoja("Work", "W3_FABL_O"), EICRetLoja("WORK", "W3_FORL_O"))
                  lGrvMerck := (SW3->W3_DT_ENTR > Work->WKDT_ENTR)
                  lGravaSC7 := .T.
                  RecLock("SW3",.F.)
                  AVREPLACE("Work","SW3")//AOM - 08/04/2011
                  SW3->W3_PRECO    := Work->WKPRECO
                  SW3->W3_DT_EMB   := Work->WKDT_EMB
                  SW3->W3_DT_ENTR  := Work->WKDT_ENTR
                  SW3->W3_PORTARI := Work->WKPORTARIA
                  SW3->W3_FABR_01  := Work->WKFABR_01
                  SW3->W3_FABR_02  := Work->WKFABR_02
                  SW3->W3_FABR_03  := Work->WKFABR_03
                  SW3->W3_FABR_04  := Work->WKFABR_04
                  SW3->W3_FABR_05  := Work->WKFABR_05
                  SW3->W3_POSICAO  := Work->WKPOSICAO
                  SW3->W3_FABR     := Work->WKFABR
                  SW3->W3_FORN     := Work->WKFORN
                  SW3->W3_FLUXO    := Work->WKFLUXO
                  SW3->W3_REG_TRI  := Work->WK_REG_TRI
                  SW3->W3_TEC      := Work->WK_TEC
                  SW3->W3_EX_NCM   := Work->WK_EX_NCM
                  SW3->W3_EX_NBM   := Work->WK_EX_NBM
                  If AvFlags("RATEIO_DESP_PO_PLI")
                     SW3->W3_FRETE    :=   Work->WKFRETE
                     SW3->W3_SEGURO   :=   Work->WKSEGUR
                     SW3->W3_INLAND   :=   Work->WKINLAN
                     SW3->W3_DESCONT  :=   Work->WKDESCO
                     SW3->W3_PACKING  :=   Work->WKPACKI
                     If SW3->(FieldPos("W3_OUT_DES")) > 0
                        SW3->W3_OUT_DES := Work->WKOUTDE
                     EndIf
                  EndIf
                  If EICLoja()
                     SW3->W3_FABLOJ		:= Work->W3_FABLOJ
                     SW3->W3_FORLOJ		:= Work->W3_FORLOJ
                     SW3->W3_FAB1LOJ	:= Work->W3_FAB1LOJ
                     SW3->W3_FAB2LOJ	:= Work->W3_FAB2LOJ
                     SW3->W3_FAB3LOJ	:= Work->W3_FAB3LOJ
                     SW3->W3_FAB4LOJ	:= Work->W3_FAB4LOJ
                     SW3->W3_FAB5LOJ	:= Work->W3_FAB5LOJ
                  EndIf
                  If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
                     SW3->W3_PART_N  := Work->WKPART_N
                  EndIf

                  If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
                     SW3->W3_PESOL := Work->WKPESOL
                  EndIf

                  //TRP- 01/06/09 - Campo Software para novo Tratamento de Mídia e Software
                  If SW3->(FieldPos("W3_SOFTWAR")) # 0 .And. EasyGParam("MV_CONSOFT",, "N") $ cSim
                     SW3->W3_SOFTWAR := Work->WKSOFTWAR
                  Endif

                  If lCpoCtCust                           //NCF - 22/06/2010 - Campo do centro de Custo
                     SW3->W3_CTCUSTO := Work->WKCTCUSTO
                  EndIf

                  If lPesoBruto                           //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
                     SW3->W3_PESO_BR := Work->WKPSBRUTO
                  EndIf

                   //FSM - 16/05/2012 - Admissão em Entreposto
                  If EasyGParam("MV_AVG0211",,.F.)  .And. SW3->(FieldPos("W3_ALTANU")) > 0
                     SW3->W3_ALTANU := Work->WKALTANU
                  EndIf

                 //NCF - 23/01/2013 - Gravar Regime de Trib. do Item
                 SW3->W3_GRUPORT := Work->WKGRUPORT

                  If lForeCast
                     REPLACE W3_FORECAS WITH Work->WK_FORECAS
                  Endif

                  If lNestle
                     ExecBlock(cArqNestle,.F.,.F.,"7")
                  Endif

                  IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"8"),) //AWR 01/10/1999

                  IF lRdMake
                     Work->(ExecBlock("EICPPO02",.F.,.F.,"23"))
                  ENDIF
                  IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"GRAVA_DESPESAS"),)
                  //BHF - 10/09/08
                  //TRP-15/05/07
                  //MFR 16/09/2019
                  /*
                  aOrd := SaveOrd("SX3",1)
                  SX3->(dbSeek("SW3"))
                  While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW3"
                     If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
                        Eval(FieldWBlock(SX3->X3_CAMPO, Select("SW3")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work"))))
                     EndIF
                     SX3->(dbSkip())
                  Enddo
                  RestOrd(aOrd)
                  MSUnlock()
                   */

                  DBSELECTAREA('Work')
                  IF WKFLUXO_O == "7" .AND. WKFLUXO # "7"
                     RecLock("SW3",.F.)
                     SW3->W3_SALDO_Q:= SW3->W3_QTDE
                     MSUnlock() ; DBSELECTAREA('Work')
                     Po420_IpPos("3",Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
                     PO420_EstIG(Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
                  ENDIF

                  IF EasyEntryPoint("IC023PO1")
                     EasyExRdm("U_IC023PO1", "Int100Solic_W3",{lGrvMerck,.T.})                     
                  ENDIF

                  DBSELECTAREA("SW1")
                  SW1->(DBSETORDER(2))
                  IF PosO2_It_Solic(Work->WKPO_NUM,Work->WKCC,;
                                    Work->WKSI_NUM,Work->WKCOD_I,;
                                    Work->WKFABR_O,Work->WKFORN_O,;
                                    Work->WKREG,IF(EICLOJA(),Work->W3_FABL_O,""),IF(EICLOJA(), Work->W3_FORL_O,""))

                       RecLock("SW1",.F.)
                         REPLACE W1_FABR WITH Work->WKFABR ,;
                                 W1_FORN WITH Work->WKFORN
                                 SW1->(MSUnlock())
                        If EICLoja()
                           SW1->W1_FORLOJ := Work->W3_FORLOJ
                           SW1->W1_FABLOJ := Work->W3_FABLOJ
                        EndIf
                   ENDIF

                  DBSELECTAREA('Work')
                  IF WKFLUXO == "7"
                     lGrava_Fluxo:=.T.
                  ENDIF
               ENDIF

               IF lGravaSC7
                  SW0->(dbSeek(xFilial()+SW3->(W3_CC+W3_SI_NUM)))
                  If cProg#"PN"

                  //ACB - 18/03/2011 - Envio do centro de custo do compras
                  If SW3->(FieldPos("W3_CTCUSTO")) > 0
                     cCentroCusto := SW3->W3_CTCUSTO
                  Else
                     cCentroCusto := SW3->W3_CC
                  EndIf
                     If !lEXECAUTO_COM
                        AVGravaSC7(ALTERACAO,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                           IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),SW0->W0__POLE,cCentroCusto,;
                           SW3->W3_FORN,If(EICLoja(), SW3->W3_FORLOJ, '01'),SW2->W2_PO_DT,;
                           SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;//'01'
                           Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N", SW2->W2_PO_NUM,;
                           If(lW2ConaPro,SW2->W2_CONAPRO,Nil),SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES+W2_FRETEIN),SW2->W2_DESCONT)
                     EndIf
                  EndIf
               Endif

            ENDIF
         ENDIF

      ELSE    // rotina para item desmarcado

         IF ( Work->WKFLUXO_O #  "7" .AND. Work->WKQTDE_GI == 0 ) .OR. ;
            ( Work->WKFLUXO_O == "7" .AND. Work->WKQTDE_GI == Work->WKSALDO_GI )

            DBSELECTAREA("SW3")
            DBSETORDER(1)

            lGravaSC7 := .F.
            IF PosO1_ItPedidos(Work->WKPO_NUM,Work->WKCC,;
                               Work->WKSI_NUM,Work->WKCOD_I,;
                               Work->WKFABR,Work->WKFORN,;
                               Work->WKREG,Work->WKSEQ, EICRetLoja("Work", "W3_FABLOJ"), EICRetLoja("WORK", "W3_FORLOJ"))
               lGravaSC7 := .T.
               RecLock("SW3",.F.,.T.) // lock p/ delecao
               DBDELETE()
               MsUnlock()
            ENDIF

            DBSELECTAREA("SW1")
            DBSETORDER(1)
            IF PosO1_It_Solic(Work->WKCC,Work->WKSI_NUM,;
                              Work->WKCOD_I,Work->WKREG,0)
               RecLock("SW1",.F.)
             //REPLACE W1_SALDO_Q   WITH   W1_SALDO_Q + Work->WKSALDO_O
               SW1->W1_SALDO_Q := SW1->W1_SALDO_Q + Work->WKQTDE_O
               MSUnlock()
            ENDIF

            DBSETORDER(2)
            IF PosO2_It_Solic(Work->WKPO_NUM,Work->WKCC,;
                              Work->WKSI_NUM,Work->WKCOD_I,;
                              Work->WKFABR,Work->WKFORN,;
                              Work->WKREG,IF(EICLOJA(),Work->W3_FABLOJ,""),IF(EICLOJA(), Work->W3_FORLOJ,""))
               RecLock("SW1",.F.,.T.) // lock p/ delecao
               DBDELETE()
               MSUnlock()
            ENDIF

            IF Work->WKFLUXO_O == "7"
               Po420_IpPos("3",Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
               Po420_EstIg(Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
            ENDIF

            IF lGravaSC7
               SW0->(dbSeek(xFilial()+WORK->(WKCC+WKSI_NUM)))
               If cProg#"PN"
                  If !lEXECAUTO_COM
                     AVGravaSC7(EXCLUSAO,Work->WKCOD_I,Work->WKQTDE,Work->WKPRECO,;
                        IF(EMPTY(ALLTRIM(TPO_SIGA)),LEFT(TPO_NUM,6),TPO_SIGA),,IF(lCpoCtCust,Work->WKCTCUSTO,Work->WKCC),;
                        WORK->WKFORN,'01',SW2->W2_PO_DT,;
                        SW0->W0_C1_NUM,,SW3->W3_POSICAO,SW3->W3_POSICAO,;//'01'
                        Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N", SW2->W2_PO_NUM,;
                        If(lW2ConaPro,SW2->W2_CONAPRO,Nil) )
                  EndIf
               EndIf
            ENDIF

            IF lCancelaSaldo
               EICPO411(1)
            ENDIF

         ENDIF
      ENDIF

      IF lGrava_Fluxo
         IF Work->WKFLUXO == "7"
            RecLock("SW3",.F.)
            SW3->W3_SALDO_Q:=0
            MsUnlock()
            Po420GrvGI()
            IF ! Po420_IgPos("2",Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
               Po420GrvIG(.T.)
            ENDIF
            IF ! Po420_IpPos("2",Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
               Po420GrvIP()
            ENDIF
         ELSEIF Work->WKFLUXO_O == "7"
            RecLock("SW3",.F.)
            SW3->W3_SALDO_Q:= SW3->W3_QTDE
            MsUnlock()
            Po420_IpPos("3",Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
            Po420_EstIg(Work->WKFABR_O, IF(EICLOJA(),Work->W3_FABL_O,""))
         ENDIF
      ENDIF

      DBSELECTAREA("Work")

      cAlter:= IF(WFlag=="2",STR0004 + TRAN(TNr_Alter,"99") + " " ,"")//"Alt. "

      IF WKDT_ENTR <> WKDTENTR_S
         MFrase:= STR0005 + DTOC(WKDTENTR_S) + STR0006+ DTOC(WKDT_ENTR) +STR0007+ TRAN(WKCOD_I,_PictItem)//'DT ENTREGA ALTERADA '###' P/ '###' COD. '
         Grava_Ocor(TPO_NUM,dDataBase,MFrase,cFase) // RA - 06/08/2003
      ELSE
         If lDtEntrega // RA - 06/08/2003
            MFrase:= STR0008 + DTOC(WKDT_ENTR) +STR0007  + TRAN(WKCOD_I,_PictItem)//'DT ENTREGA CONFIRMADA ' // RA - 06/08/2003
            Grava_Ocor(TPO_NUM,dDataBase,MFrase,cFase) // RA - 06/08/2003
         EndIf // RA - 06/08/2003
      ENDIF

      //Grava_Ocor(TPO_NUM,dDataBase,MFrase,cFase)  // RA - 06/08/2003

      IF WKDT_EMB <> WKDTEMB_S .AND. ! EMPTY(WKDTEMB_S)
         MFrase:= cAlter+STR0009 + DTOC(WKDTEMB_S) + STR0006+;//'DT EMB. DE '
                  DTOC(WKDT_EMB) + STR0010 + WKCOD_I//' ITEM '
         Grava_Ocor(TPO_NUM,dDataBase,MFrase,cFase)
      ENDIF
      IF WKPRECO <> WKPRECO_S .AND. ! EMPTY(WKPRECO_S)
         MFrase:= cAlter+STR0011 + ALLTRIM(TRAN(WKPRECO_S,_PictPrUn)) +;//'PRECO DE '
                  STR0006+ ALLTRIM(TRAN(WKPRECO,_PictPrUn)) + STR0010 + WKCOD_I
         Grava_Ocor(TPO_NUM,dDataBase,MFrase,cFase)
      ENDIF

      DBSELECTAREA("Work")
      DBSKIP()
   ENDDO
   If !(lPoAuto) //FSM - 17/05/2012
      IncProc(STR0012)//"Processando Ocorrencias"
   EndIf

//mjb150999   FOR I = 1 TO Ind_SI
   For I:=1 To Len(TabSI_Num)
//mjb150999        IF EMPTY(TabSI_Num[I])
//mjb150999             LOOP
//mjb150999          ENDIF
       Grava_Ocor(TPO_NUM,dDataBase,cAlter+STR0013+ TRANSF(TabSI_Num[I],_PictSI) +STR0014 + DTOC(TabSI_DT[I]),cFase)//"ATENDIDA A S.I. "###" DE "
   NEXT

   IF M->W2_DT_PRO <> TDt_Pro_Ant
      Grava_Ocor(TPO_NUM,dDataBase,cAlter+STR0015+DTOC(M->W2_DT_PRO),cFase)//"DATA DE CHEGADA DA PROFORMA "
   ENDIF

   Grava_Ocor(TPO_NUM,dDataBase,cAlter+STR0016 + ALLTRIM(TRANS(M->W2__NR_COT,_PictQc)),cFase)//'FECHAMENTO DO P.O. CONF. COTACAO '

   DBSELECTAREA("SW3")
   DBSETORDER(1)
   IF ! SW3->(DBSEEK(xFilial("SW3")+TPO_NUM))
      DBSELECTAREA("SW2")
      SW2->(DBSETORDER(1))
      IF SW2->(DBSEEK(xFilial("SW2")+TPO_NUM))
         RecLock("SW2",.F.,.T.) // lock p/ delecao
         DBDELETE()
         MSUnlock()
//       IF _Mod_PCal
            SWH->(DBSEEK(xFilial()+TPO_NUM))
            WHILE ! SWH->(EOF())  .AND. ;
               SWH->WH_PO_NUM = TPO_NUM .AND. SWH->WH_FILIAL==xFilial("SWH")
               RecLock("SWH",.F.,.T.) // lock p/ delecao
               SWH->(DBDELETE())
               SWH->(MSUnlock())
               SWH->(DBSKIP())
            END
//       ENDIF
      ENDIF
   ENDIF

   // EOB - 20/01/10 - Gravação da tabela EIJ com os grupos de regime de tributação
   IF SELECT("WorkPO_EIJ") > 0
      EIJ->(dbSetOrder(2))
      cFilEIJ := xFilial("EIJ")
      IF EIJ->(dbSeek(cFilEIJ + TPO_NUM))
         DO WHILE EIJ->EIJ_FILIAL == cFilEIJ .AND. EIJ->EIJ_PO_NUM == TPO_NUM
            Reclock("EIJ", .F.)
            IF WorkPO_EIJ->(dbSeek(EIJ->EIJ_ADICAO))
               AVREPLACE("WorkPO_EIJ", "EIJ")
            ELSE
               EIJ->(DBDELETE())
            ENDIF
            EIJ->(MSUnlock())
            EIJ->(dbSkip())
         ENDDO
      ENDIF
      WorkPO_EIJ->(dbGotop())
      DO While !WorkPO_EIJ->(eof())
         IF !EIJ->(dbSeek(cFilEIJ + TPO_NUM + WorkPO_EIJ->EIJ_ADICAO))
            Reclock("EIJ", .T.)
            AVREPLACE("WorkPO_EIJ", "EIJ")
            EIJ->EIJ_PO_NUM := TPO_NUM
         ENDIF
         WorkPO_EIJ->(dbSkip())
      ENDDO
   ENDIF

   IncProc(STR0012)

   //Tratamento para geração do pedido de compras via rotina automática
   //19/04/11

   If lEXECAUTO_COM .And. (lAltCapPO .OR. lAltItemPO) .And. cProg#"PN" //MCF - 30/06/2015
      If !PO400GravaPC(nOpcAux)
         lRetExecAuto:= .F.
         DisarmTransaction()
         Work->(DBGoTop())
      EndIf
   EndIf

//   lEnvioOK:=.T.
   IF AvFlags("EIC_EAI")
      DBSELECTAREA("Work")
      SET FILTER TO
      Work->(DBGoTop())
      nOpcLogix := IF(INCLUI, 3, 4)
      IF !EICPO420(.T.,nOpcLogix,,"SW2",.T.)
         EasyHelp(STR0090,STR0091)  //"Erro durante a integração de Order para o ERP Externo."  ###  "Aviso"
         lEnvioOK:=.F.
         DisarmTransaction()//RollBackDelTran("")
         Work->(DBGoTop())
      endif
   ENDIF

   EvalTrigger()

End Transaction
*---------------------------------------------------------------------------
* FINALIZA O CONTROLE DE TRANSACAO - DESALOCA TODOS OS REGISTROS
*---------------------------------------------------------------------------

// *** GFP - 23/03/2011 :: 15h05 - Tratamento de WorkFlow no PO.
If AvFlags("WORKFLOW")
   EasyGroupWF("PURCHASE ORDER",aChaves)
EndIf
// *** Fim GFP

Return .T.

*----------------------------------------------------------------------------
FUNCTION PO420GrvPO000(PGrava,cMV_EASY)
*----------------------------------------------------------------------------
   LOCAL nOldArea:=SELECT(), cObs, lInclui, W2_STAT_PC:="",lW2ConaPro:=.F.,lAltPO:=.F.
   LOCAL nMoe_Com := 0 // EOS - Moeda corresponde ao SIGACOM
   //LOCAL cGrAprov := EasyGParam("MV_PCAPROV") // EOS - pega o grupo de aprovadores padrao

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Define variaveis para rdmake que atualiza a data de chegada   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL cPoint2 := "EICPO40C"
   LOCAL lPoint2 := EasyEntryPoint(cPoint2)
   Local i
   DEFAULT cMV_EASY    := EasyGParam("MV_EASY")// AWR
   PRIVATE cGrAprov    := EasyGParam("MV_PCAPROV") //SVG 01/10/08
   Private lValidAlc   := .T. //DFS - 02/12/10 - Inclusão de variável lógica para tratamento no envio de informações das alçadas.
   Private lBlqPOCpAlt := .F. //DFS - 25/04/13 - Inclusão de variável private para tratamento via ponto de entrada.
   //ISS - 27/04/11 - Array para validar se houve alguma alteração de algum campo significativo para a integração com o compras
   Private aValAltCap := {"W2_PO_DT"  ,;
                        "W2_INLAND" ,;
                        "W2_PACKING",;
                        "W2_OUT_DES",;
                        "W2_MOEDA"  ,;
                        "W2_DT_PAR" ,;
                        "W2_COND_PA",;
                        "W2_FRETEIN",;
                        "W2_DESCONT"}

   If ValType(lEXECAUTO_COM) <> "L"
      lEXECAUTO_COM := /*EasyGParam("MV_EIC0008",,.F.) FIXO .T. OSSME-6437 MFR 06/12/2021.And. */ EasyGParam("MV_EASY",,"N") == "S"
   EndIf

   //TRP-28/08/08- Teste do parâmetro MV_AVG0170 para definir se habilita Controle de Alçadas no EIC.
   lW2ConaPro := SW2->(fieldpos("W2_CONAPRO")) > 0 .AND. EasyGParam("MV_AVG0170",,.F.)
   if lW2ConaPro
      aadd(aValAltCap,"W2_COMPRA")
   endif

   SW2->(DBSETORDER(1))
   IF ! SW2->(DBSEEK(xFilial()+TPO_NUM))
      *RecLock("SW2",.T.) // lock com append ( muda area corrente)
      lInclui:=.T.
   ELSE
      *RecLock("SW2",.F.) // lock sem append ( muda area corrente)
      cObs:=SW2->W2_OBS
      lInclui:=.F.
   ENDIF

   IF SW2->W2_STAT_PC = "1"
      IF SW2->W2_FOB_TOT # MTotal .OR. SW2->W2_TIPO_EM # M->W2_TIPO_EM .OR. ;
         SW2->W2_ORIGEM  # M->W2_ORIGEM .OR. SW2->W2_DEST # M->W2_DEST

         M->W2_STAT_PC := "2"
      ENDIF
   ENDIF

   // Vari veis devinidas para gravacao automatica
   IF WFlag <> "2"
      M->W2_NR_ALTE:=0
      M->W2_DT_ALTE:=AVCTOD('')
   ENDIF

   IF PGrava == "2"
      M->W2_FOB_TOT:= MTotal  //TRP - 01/08/2011 - Considerar a variável MTotal para gravar o FOB.
   ENDIF

   M->W2_ENV_ORI:= AVCTOD("")

   IF(EasyEntryPoint("EIC"),ExecBlock("EIC",.F.,.F.,"ALTERA_CAMPO_CAPA"),) //LRS - 21/06/2016

   For i:=1 To Len(aValAltCap)
      If SW2->&(aValAltCap[i]) != M->&(aValAltCap[i])
         lAltCapPO := .T.
         Exit
      End
   Next i

   E_Grava("SW2",lInclui)

   SY1->(dbSetOrder(1))
   IF SY1->(DbSeek(xFilial("SY1")+SW2->W2_COMPRA)) .And. !Empty(SY1->Y1_GRAPROV)
      cGrAprov := SY1->Y1_GRAPROV
   ENDIF

   IF cMV_EASY $ cSim .AND. cProg#"PN" .And. !EMPTY(cGrAprov)
      If SW2->(RecLock("SW2",.F.))
         // EOS - Pegar moeda correspondente ao SIGACOM
         SYF->(dbSetOrder(1))
         IF SYF->(dbSeek(xFilial("SYF") + SW2->W2_MOEDA))
            nMoe_Com := SYF->YF_MOEFAT
         ENDIF

         lValidAlc := .T. //DFS - 02/12/10 - Conteúdo inicial .T. para que o sistema trate da mesma maneira quando não houver customização

         IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ANTESMaAlcDoc"),) //SVG - 01/10/08

         SCR->(DBSETORDER(2))
         If !lInclui .And. SCR->(DBSEEK(xFilial("SCR")+"PC"+SW2->W2_PO_SIGA))
               //SVG - 21/01/10 -
               WORK->(DBGOTOP())
               WHILE WORK->(!EOF())
                  IF WORK->WK_ALTEROU //TDF - 22/11/2010 - Tratamento para o bloqueio da liberação caso o PO seja alterado
                     lAltPo:=.T.
                     Exit
                  EndIf
                  WORK->(DbSkip())
               EndDo
               If lAltPo .AND. lValidAlc .And. !lEXECAUTO_COM //DFS - 02/12/10 - Inclusão de tratamento para tratamento no envio de informações das alçadas.
                  Alcada_EIC(.F.)//LRS - 22/09/2017
                  SW2->(MsUnlock())
               EndIf
         Else
            // AST - 19/01/09 - Adicionado parametro taxa da moeda. BuscaTaxa(SW2->W2_MOEDA,dDataBase)
            If !lEXECAUTO_COM
               //Alcada_EIC(.T.) //LRS - 22/09/2017
               //LRS - 22/09/2017
               //lLiberado:=MaAlcDoc({SW2->W2_PO_SIGA,"PC",SW2->W2_FOB_TOT,,,cGrAprov,,nMoe_Com,BuscaTaxa(SW2->W2_MOEDA,dDataBase),SW2->W2_PO_DT},,1)
               // LRS - Nesse ponto da gravação, a SC7 não foi gerado, por isso não pode ser usada a função ALCADA_EIC
               SW2->W2_CONAPRO:=If(lAlcada,"B","")
               SW2->(MsUnlock())
            Else
               //SW2->W2_CONAPRO:= "B"
               SW2->(MsUnlock())
            EndIf
         EndIf
      EndIf
   EndIf

   IF lPoint2
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³Executa rdmake que atuliza a data de chegada                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      ExecBlock(cPoint2)
   Endif

   MsUnlockAll()

   SW2->(DBCOMMIT())

   // gravacao de campo memo
   MSMM(cObs,TamSx3("W2_VM_OBS")[1],,M->W2_VM_OBS,1,,,"SW2","W2_OBS")

   // Forca a gravacao

   If Type("__lSX8") = "U"
      __lSX8:=.F.
   Endif

   If __lSX8
      ConfirmSX8()
   Endif

   DBSELECTAREA(nOldArea)
RETURN

*--------------------------------------------------------------------------
FUNCTION GI_Grava(bMsg,lInclui)
*--------------------------------------------------------------------------
LOCAL PTotal:=0, TotReg:=Work->(EasyRecCount()),cObs , Wind
LOCAL cReg_Tri, nPreco, cItem
LOCAL _IniPO := SPACE(LEN(SW7->W7_PO_NUM))
LOCAL _PictITem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictPGI  := ALLTRIM(X3PICTURE("W4_PGI_NUM"))
Local _PictPO   := ALLTRIM(X3Picture("W2_PO_NUM"))  // FSM - 04/05/11
Local nRecSW1, nOrdSW1, lResp // RA - 31/10/03 - O.S. 1106/03
Local nRecSA5, nOrdSA5, lExistA5PESO  //  cEasy := EasyGParam("MV_EASY") // LDR
Local lInvAnt

Local aChaves := {}
PRIVATE lGravaB1 // Para o Rdmake que faz nao gravar o peso do B1
Private lAltAto:=.F., cOldSub, cOldAto, GI_Inclui:=lInclui //Variáveis para o Rdmake EICGI400
Private lIntDrawb := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
Private cMV_EASY:=EasyGParam("MV_EASY") // ldr
SX3->(DBSETORDER(2))
lExistA5PESO := SX3->(DBSEEK("A5_PESO")) // LDR
Private lokW5_AC   := SX3->(dbSeek("W5_AC"))
PRIVATE aCapaLi := {}  // JBS - 14/10/2003   - O RDM usa.
// PLB 06/08/07 - Referente tratamento de Incoterm, Frete e Regime de Tributação na LI (ver chamado 054617)
Private lW4_Reg_Tri := SW4->( FieldPos("W4_REG_TRI") ) > 0
Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL") // AOM - Operacao Especiais

IF TYPE("cRotinaOPC") <> "C"
   cRotinaOPC:= ""
EndIf

IF cRotinaOPC == "LSI"
   nTamEsp:=AVSX3("WP_ESP_VM",3)
   nTamInf:=AVSX3("WP_INF_VM",3)
ENDIF

lInvAnt := SX3->(dbSeek("EW4_INVOIC")) .AND. SX3->(dbSeek("EW5_INVOIC")) .AND.; //DRL - 16/09/09 - Invoices Antecipadas
                 SX2->(dbSeek("EW4")) .AND. SX2->(dbSeek("EW5")) .AND. SIX->(dbSeek("EW4")) .AND. SIX->(dbSeek("EW5"))

If Type("aEnv_PO") <> "A"
   aEnv_PO:= {}
EndIf

If Type("lPesoBruto") == "U"
   lPesoBruto:= .F.
EndIf

If Type("lCposNVAE") == "U"
   lCposNVAE:= .F.
EndIf

SX3->(DBSETORDER(1))

IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"INICIO_GI_GRAVA"),) // ldr

// RA - 31/10/03 - O.S. 1106/03 - Inicio
If lInclui .And. GetNewPar("MV_ATUPESO",.F.) .And. ("LI" $ GetNewPar("MV_PESOW57","LI"))
   If cMV_EASY $ cSim // ldr
      lResp := MsgYesNo(STR0083,STR0003)  // "Deseja atualizar o peso líquido do Cadastro de Produtos ? "###"Atenção"
   Else
      lResp := .T.
   EndIf
Else
   lResp := .F.
EndIf
// RA - 31/10/03 - O.S. 1106/03 - Final
If !( Type("lPoAuto")=="L" .And. lPoAuto) //FSM - 17/05/2012
   Eval(bMsg, STR0089) //"Aguarde, gravando dados..."
EndIf

// PLB 06/08/07 - Tratamento para Gravação do Regime de Tributação
If lW4_Reg_Tri
   cReg_Tri := M->W4_REG_TRI
Else
   IF !Empty(M->W4_REGIMP)
      SY8->(dbSeek(xFilial()+M->W4_REGIMP))
      cReg_Tri := SY8->Y8_REG_TRI
   Endif
EndIf

If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("LICENCA IMPORT")
EndIf

//AOM - 09/04/2011
If lOperacaoEsp
   oOperacao:SaveOperacao()
EndIf

*---------------------------------------------------------------------------
* INICIALIZA O CONTROLE DE TRANSACAO
*---------------------------------------------------------------------------
Begin Transaction

WHILE .T.
   EvalTrigger()

   IF MOpcao = 1 .OR. MOpcao = 3 .OR. MOpcao = 4 .OR. MOpcao = 5
      // Estas variaveis sao para gravacao autom tica com E_Grava
      M->W4_PGI_NUM :=IF(lInclui,TNro_Pgi,W4_PGI_NUM)
      M->W4_MOEDA   :=IF(lInclui,MMoeda,M->W4_MOEDA)
      M->W4_POS_NUM :=IF(lInclui,TPos,M->W4_POS_NUM)
      M->W4_GI_NUM  :=IF(lInclui,TNro_Pgi,M->W4_PGI_NUM)
      M->W4_FOB_TOT :=IF(lInclui,MTotal,M->W4_FOB_TOT)
      M->W4_SISCOME :=.T.
      M->W4_ATO_CON :=LEFT(M->W4_ATO_CON,13)
      M->W4_SUB_ATO :=LEFT(M->W4_SUB_ATO,1)
      M->W4_PORTASN :=IF(MOpcao=4,"S","N")
      M->W4_FLUXO   :=IF(MOpcao=3,'7',IF(MOpcao=5,'4','1'))

      IF ! EMPTY(M->W4_TIPO_DO) .OR. ! EMPTY(M->W4_TIPOAPL) .OR. ! EMPTY(M->W4_PROD_SU)
         M->W4_SUFRAMA := "S"
      ELSE
         M->W4_SUFRAMA := "N"
      ENDIF

      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"SALDO"),)

      E_Grava("SW4",lInclui)

      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVASW4"),)
      cObs:=If(!lInclui,SW4->W4_DESC_GE,NIL)
      MSMM(cObs,TamSx3("W4_VM_DESG")[1],,M->W4_VM_DESG,1,,,"SW4","W4_DESC_GE")
   ENDIF

   IF ! lInclui
      IF ! Empty(cReg_Tri)
         GI_GravaReg(cReg_Tri)
      Endif
      EXIT
   ENDIF

   DBSELECTAREA("Work")
   MPo_Num:= _IniPO
   ASIZE(MTabPO,0) && Reapura tabela inicializada anteriormente para acerto do campo tPOS
   DBGOTOP()

   aCapaLi:={}
   If lIntDrawb
      ED0->(dbSetOrder(2))
   EndIf
   SA5->(dbSetOrder(3))
   DO WHILE .NOT. EOF()
      Eval(bMsg,STR0017+TRANS(Work->WKCOD_I,_PictItem)+;  //"Processando item "
                TRAN(++PTotal/TotReg*100,'@E 999.99')+"%")

      IF .NOT. WKFLAG
         DBSKIP()
         LOOP
      ENDIF

      IF ASCAN(MTabPO,Work->WKPO_NUM) = 0
         AADD(MTabPO,Work->WKPO_NUM)
         TPos = ALLTRIM(TPos) + TRANS(Work->WKPO_NUM,_PictPO)+","
      ENDIF

      DBSELECTAREA("SW5")
      RecLock("SW5",.T.)    // efetua append e trava
      //AOM - 08/04/2011 - Gravação dos campos com mesmo nome da base
      AVREPLACE("Work","SW5")

      SW5->W5_COD_I    :=   Work->WKCOD_I
      SW5->W5_FABR     :=   Work->WKFABR
      SW5->W5_FABR_01  :=   Work->WKFABR_01
      SW5->W5_FABR_02  :=   Work->WKFABR_02
      SW5->W5_FABR_03  :=   Work->WKFABR_03
      SW5->W5_FABR_04  :=   Work->WKFABR_04
      SW5->W5_FABR_05  :=   Work->WKFABR_05
      SW5->W5_FORN     :=   Work->WKFORN
      SW5->W5_FLUXO    :=   IF(MOpcao=5,"4",Work->WKFLUXO)
      SW5->W5_QTDE     :=   Work->WKQTDE
      SW5->W5_PRECO    :=   Work->WKPRECO
      SW5->W5_SALDO_Q  :=   Work->WKQTDE  // Work->WKSALDO_Q
      SW5->W5_SI_NUM   :=   Work->WKSI_NUM
      SW5->W5_PO_NUM   :=   Work->WKPO_NUM
      SW5->W5_PGI_NUM  :=   TNro_Pgi
      SW5->W5_DT_EMB   :=   Work->WKDT_EMB
      SW5->W5_DT_ENTR  :=   Work->WKDT_ENTR
      SW5->W5_SEQ      :=   0
      SW5->W5_CC       :=   Work->WKCC
      SW5->W5_REG      :=   Work->WKREG
      SW5->W5_SEQ_LI   :=   Work->WKSEQ_LI
      SW5->W5_POSICAO  :=   Work->WKPOSICAO
      SW5->W5_FILIAL   :=   xFilial("SW5")
      SW5->W5_PESO     :=   Work->WKPESO_L //Dourado 04/07/2001

      If AvFlags("RATEIO_DESP_PO_PLI")
            SW5->W5_FRETE   := Work->WKFRETE 
            SW5->W5_SEGURO  := Work->WKSEGUR 
            SW5->W5_INLAND  := Work->WKINLAN 
            SW5->W5_DESCONT := Work->WKDESCO 
            SW5->W5_PACKING := Work->WKPACKI 
      EndIf

      IF ascan(aEnv_PO,SW5->W5_PO_NUM) == 0  // GFP - 06/10/2014
         aadd(aEnv_PO,SW5->W5_PO_NUM)
      ENDIF

      //FSM - 31/08/2011 - "Peso Bruto Unitário"
      If lPesoBruto
         SW5->W5_PESO_BR := Work->WKW5PESOBR //Grava o peso bruto do produto
      EndIf

      SW5->W5_EX_NCM   :=   Work->WK_EX_NCM
      SW5->W5_EX_NBM   :=   Work->WK_EX_NBM
      If EICLoja()
         SW5->W5_FABLOJ		:= Work->W5_FABLOJ
         SW5->W5_FAB1LOJ	:= Work->W5_FAB1LOJ
         SW5->W5_FAB2LOJ	:= Work->W5_FAB2LOJ
         SW5->W5_FAB3LOJ	:= Work->W5_FAB3LOJ
         SW5->W5_FAB4LOJ	:= Work->W5_FAB4LOJ
         SW5->W5_FAB5LOJ	:= Work->W5_FAB5LOJ
         SW5->W5_FORLOJ		:= WORK->W5_FORLOJ
      EndIf
      If lIntDrawb .and. lokW5_AC .and. !Empty(Work->WKAC)
         SW5->W5_AC       :=   Work->WKAC
         SW5->W5_SEQSIS   :=   Work->WKSEQSIS
         nQtdAux          := 0
         ED4->(dbSetOrder(2))
         ED4->(dbSeek(cFilED4+Work->WKAC+Work->WKSEQSIS))
         ED4->(msUnlock()) //Libera SoftLock
         If ED0->ED0_AC <> ED4->ED4_AC .or. ED0->ED0_FILIAL <> cFilED0
            ED0->(dbSeek(cFilED0+ED4->ED4_AC))
         EndIf
         If Work->WKCOD_I == ED4->ED4_ITEM
            cItem := Work->WKCOD_I
         Else
            cItem := IG400BuscaItem("I",Work->WKCOD_I,ED4->ED4_PD)
         EndIf
         VerificaQTD(.F.,,,ED0->ED0_TIPOAC,cItem)
         ED4->(RECLOCK("ED4",.F.))
         If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
            ED4->ED4_QT_LI  -= nQtdAux
            ED4->ED4_SNCMLI -= nQtdNcmAux  // PLB 18/07/07
         EndIf
         nPreco := GI400ApVal()
         ED4->ED4_VL_LI  -= nPreco
         ED4->(msUnlock())
         If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
            SW5->W5_QT_AC  := nQtdAux
            SW5->W5_QT_AC2 := nQtdNcmAux
         EndIf
         SW5->W5_VL_AC  := nPreco
      EndIf

      If lInvAnt .And. SW5->(FIELDPOS("W5_INVANT")) > 0 .AND. WORK->(FIELDPOS("WKINVOIC")) > 0 //DRL
         SW5->W5_INVANT := WORK->WKINVOIC
      EndIf

      //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
      IF lCposNVAE
         SW5->W5_NVE := Work->WKNVE
      EndIf

      IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"GRAVAW5"),)
      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVAW5"),)
      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVAW5_GI"),)  //JWJ - 10/10/2005: P/ SER USADO APENAS NO EICGI400.

      MSUnlock()

      IF ! EMPTY(Work->WKSEQ_LI)
         nInd:= ASCAN(aCapaLi,{|tab|tab[1]==Work->WKSEQ_LI})

         IF nInd==0
            AADD(aCapaLi,{Work->WKSEQ_LI , Work->WKTEC     ,;
                          Work->WKNALADI , Work->WKALADI   ,;
                          Work->WKFABR   , IF(!EMPTY(Work->WKDESTAQUE),Work->WKDESTAQUE,"") ,;
                          Work->WKNAL_SH , Work->WKUNI_NBM, If(lIntDrawb,Work->WKAC,), "" })
            If EICLoja()
               aCapaLi[Len(aCapaLI)][10] := Work->W5_FABLOJ
            EndIf
         ELSEIF AT(Work->WKDESTAQUE,aCapaLi[nind,6]) == 0
            aCapaLi[nind,6] += " " + Work->WKDESTAQUE
         ENDIF
      ENDIF

      IF MOpcao = 2
         DBSELECTAREA("SWE")
         IF PosO1_ItEs(TNro_Pgi,Work->WKCOD_I,Work->WKFABR,Work->WKFORN,1,0)
            RecLock("SWE",.F.)
            REPLACE WE_SALDO_Q   WITH   WE_SALDO_Q - Work->WKQTDE
            MSUnlock()
         ENDIF

         MSeq:= PrxSeq_Ie()

         RecLock("SWE",.T.)    // efetua append e trava
         REPLACE   WE_COD_I    WITH   Work->WKCOD_I   ,;
                   WE_FABR     WITH   Work->WKFABR    ,;
                   WE_FABR_01  WITH   Work->WKFABR_01 ,;
                   WE_FABR_02  WITH   Work->WKFABR_02 ,;
                   WE_FABR_03  WITH   Work->WKFABR_03 ,;
                   WE_FABR_04  WITH   Work->WKFABR_04 ,;
                   WE_FABR_05  WITH   Work->WKFABR_05 ,;
                   WE_FORN     WITH   Work->WKFORN    ,;
                   WE_FLUXO    WITH   '2'             ,;
                   WE_QTDE     WITH   Work->WKQTDE    ,;
                   WE_PRECO    WITH   Work->WKPRECO   ,;
                   WE_SALDO_Q  WITH   Work->WKQTDE    ,;
                   WE_PGI_NUM  WITH   TNro_Pgi        ,;
                   WE_NBM      WITH   Work->WKNBM     ,;
                   WE_DT_EMB   WITH   Work->WKDT_EMB  ,;
                   WE_DT_ENTR  WITH   Work->WKDT_ENTR ,;
                   WE_SEQ      WITH   MSeq            ,;
                   WE_REG      WITH   1               ,;
                   WE_FILIAL   WITH   xFilial("SWE")
         MSUnlock()
      ENDIF
      lGravaB1:= .T.
      IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"GRAVAB1"),.F.)
      IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ACAPALI_ACUMULA"),)  // JBS - 14/10/2003
      IF SB1->(DBSEEK(xFilial()+Work->WKCOD_I)) .AND. lGravaB1
         // RA - 31/10/03 - O.S. 1106/03 - Inicio
         If lResp
            If cMV_EASY $ cNao  // LDR - OS 1464/03 - Inicio
               If !GetNewPar("MV_PESONEW",.F.)
                  If SB1->B1_PESO <> Work->WKPESO_L
                     SB1->(RecLock("SB1",.F.))
                     SB1->B1_PESO := Work->WKPESO_L
                     SB1->(MSUnlock())
                   EndIf
               ElseIf GetNewPar("MV_PESONEW",.F.) .And. lExistA5PESO
                  nRecSA5 := SA5->(RecNo())
                  nOrdSA5 := SA5->(IndexOrd())
                  SA5->(DbSetOrder(3))
                  //If SA5->(DbSeek(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN))
                  If EICSFabFor(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"))
                     If SA5->A5_PESO <> Work->WKPESO_L
                        SA5->(RecLock("SA5",.F.))
                        SA5->A5_PESO := Work->WKPESO_L
                        SA5->(MSUnlock())
                     EndIf
                  EndIf
                  SA5->(DbSetOrder(nOrdSA5))
                  SA5->(DbGoTo(nRecSA5))
               EndIf
            ElseIf GetNewPar("MV_UNIDCOM",2) == 1 .AND. cMV_EASY $ cSim // ldr
               If SB1->B1_PESO <> Work->WKPESO_L
                  SB1->(RecLock("SB1",.F.))
                  SB1->B1_PESO := Work->WKPESO_L
                  SB1->(MSUnlock())
               EndIf
            ElseIf GetNewPar("MV_UNIDCOM",2) == 2 .AND. cMV_EASY $ cSim // ldr
               nRecSW1 := SW1->(Recno())
               nOrdSW1 := SW1->(IndexOrd())
               If ( SW1->(PosO1_It_Solic(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,0) ) )
                  If SW1->W1_QTSEGUM <> 0
                     If (SB1->B1_PESO <> (Work->WKPESO_L * (SW1->W1_QTDE/SW1->W1_QTSEGUM)))
                        SB1->(RecLock("SB1",.F.))
                        SB1->B1_PESO := Work->WKPESO_L * (SW1->W1_QTDE/SW1->W1_QTSEGUM)
                        SB1->(MSUnlock())
                     EndIf
                  Else
                     If SB1->B1_PESO <> Work->WKPESO_L
                        SB1->(RecLock("SB1",.F.))
                        SB1->B1_PESO := Work->WKPESO_L
                        SB1->(MSUnlock())
                     EndIf
                  EndIf
               EndIf
               SW1->(DbSetOrder(nOrdSW1))
               SW1->(DbGoTo(nRecSW1))
            EndIf
         EndIf
         // RA - 31/10/03 - O.S. 1106/03 - Final
      ENDIF

      DBSELECTAREA("SW3")
      DBGOTO(Work->WKRECNO_IP)
      RecLock("SW3",.F.)
      IF !Empty(cReg_Tri)
         REPLACE W3_REG_TRI   WITH cReg_Tri
      Endif
      REPLACE W3_SALDO_Q   WITH   W3_SALDO_Q - Work->WKQTDE
      SW3->W3_TEC    := Work->WKTEC
      SW3->W3_EX_NCM := Work->WK_EX_NCM
      SW3->W3_EX_NBM := Work->WK_EX_NBM

      MSUnlock()

      MSeq:= PrxSeq_Ip()
      RecLock("SW3",.T.)    // efetua append e trava
      //AOM - 08/04/2011 - Gravação dos campos com mesmo nome da base
      AVREPLACE("Work","SW3")
      REPLACE  W3_COD_I       WITH    Work->WKCOD_I   ,;
               W3_FLUXO       WITH    Work->WKFLUXO   ,;
               W3_QTDE        WITH    Work->WKQTDE    ,;
               W3_PRECO       WITH    Work->WKPRECO   ,;
               W3_SALDO_Q     WITH    0               ,;
               W3_SI_NUM      WITH    WorK->WKSI_NUM  ,;
               W3_PO_NUM      WITH    Work->WKPO_NUM  ,;
               W3_PGI_NUM     WITH    TNro_Pgi        ,;
               W3_DT_EMB      WITH    Work->WKDT_EMB  ,;
               W3_DT_ENTR     WITH    Work->WKDT_ENTR ,;
               W3_SEQ         WITH    MSeq            ,;
               W3_CC          WITH    Work->WKCC      ,;
               W3_FABR        WITH    Work->WKFABR    ,;
               W3_FABR_01     WITH    Work->WKFABR_01 ,;
               W3_FABR_02     WITH    Work->WKFABR_02 ,;
               W3_FABR_03     WITH    Work->WKFABR_03 ,;
               W3_FABR_04     WITH    Work->WKFABR_04 ,;
               W3_FABR_05     WITH    Work->WKFABR_05 ,;
               W3_FORN        WITH    Work->WKFORN    ,;
               W3_REG         WITH    Work->WKREG     ,;
               W3_POSICAO     WITH    Work->WKPOSICAO  ,;
               W3_FILIAL      WITH    xFilial("SW3")
      SW3->W3_TEC    := Work->WKTEC
      SW3->W3_EX_NCM := Work->WK_EX_NCM
      SW3->W3_EX_NBM := Work->WK_EX_NBM
      If AvFlags("RATEIO_DESP_PO_PLI")
         SW3->W3_FRETE    :=   Work->WKFRETE
         SW3->W3_SEGURO   :=   Work->WKSEGUR
         SW3->W3_INLAND   :=   Work->WKINLAN
         SW3->W3_DESCONT  :=   Work->WKDESCO
         SW3->W3_PACKING  :=   Work->WKPACKI
      EndIf
               If EICLoja()
                  SW3->W3_FABLOJ	:= Work->W5_FABLOJ
                  SW3->W3_FORLOJ	:= Work->W5_FORLOJ
                  SW3->W3_FAB1LOJ	:= Work->W5_FAB1LOJ
                  SW3->W3_FAB2LOJ	:= Work->W5_FAB2LOJ
                  SW3->W3_FAB3LOJ	:= Work->W5_FAB3LOJ
                  SW3->W3_FAB4LOJ	:= Work->W5_FAB4LOJ
                  SW3->W3_FAB5LOJ	:= Work->W5_FAB5LOJ
               EndIf

      If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
         SW3->W3_PART_N  := Work->WKPART_N
      EndIf

      MSUnlock()
      IF EMPTY(MPo_Num)
         MPo_Num:= Work->WKPO_NUM
      ELSE
         IF Work->WKPO_NUM <> MPo_Num
            IF MOpcao = 1
               MOcor:= STR0018 + TRANSF(TNro_Pgi, _PictPGI)//'MONTAGEM DO P.L.I. PROVISORIO No. '
            ELSEIF MOpcao = 4
               MOcor:= STR0019 + TRANSF(TNro_Pgi, _PictPGI)//'MONTAGEM DA PORTARIA 15 No. '
            ELSEIF MOpcao = 2
               MOcor:= STR0020 + TRANSF(TNro_Gi, '@R 9999-99/999999-9')//'UTILIZACAO DA G.I. No. '
            ELSEIF MOpcao = 5
               MOcor:= STR0021 + TRANSF(TNro_Pgi, '@R !!!-999-99')//'UTILIZACAO DO Entrepostamento '
            ELSE
               MOcor:= STR0022 + TRANSF(TNro_Pgi, '@R !!!-999-99')//'UTILIZACAO DA Portaria '
            ENDIF
            Grava_Ocor(MPo_Num,dDataBase,MOCor)
            MPo_Num:= Work->WKPO_NUM
         ENDIF
      ENDIF

      DBSELECTAREA("Work")
      IF WKDT_ENTR <> WKDTENTR_S
         MFrase:= STR0023 + DTOC(WKDTENTR_S) + STR0006 + DTOC(WKDT_ENTR) + STR0007 + TRANSF(WKCOD_I,_PictItem)//'DT ENTREGA ALT. DE '
      ELSE
         MFrase:= STR0008 + DTOC(WKDT_ENTR) + STR0007 + TRANSF(WKCOD_I,_PictItem)
      ENDIF
      Grava_Ocor(Work->WKPO_NUM,dDataBase,MFrase)

      DBSELECTAREA("Work")
      DBSKIP()
   ENDDO
   SA5->(dbSetOrder(1))
   If lIntDrawb .and. lokW5_AC
      ED0->(dbSetOrder(1))
   EndIf
   //
   // JBS 14/11/2003
   // Criando Tratamento diferenciado para LI e LSI
   // cRotinaOPC pode assumir "LSI" ou "LI" (Apenas a Gravacao do SWP)
   // Temporario Origem: LSI -> Work_SWP  <=> SWP
   //                    LI  -> Work      <=> SWP
   //
   IF cRotinaOPC == "LSI"
      //
      // Gravando a Work_SWP quando for uma LSI
      //
      Work_SWP->(dbGotop())
      M->WP_PGI_NUM := Work_SWP->WP_PGI_NUM

      nOrdWork := Work->(IndexOrd())    // JBS 26/12/2003
      Work->(dbSetOrder(5))             // JBS 26/12/2003

      Do While work_SWP->(!eof())
         // JBS - 26/12/2003
         If !Work->(dbSeek(Work_SWP->WP_SEQ_LI)).or.!Work->WKFLAG
            Work_SWP->(dbSkip())
            Loop
         EndIf

         If !SWP->(dbseek(xFilial("SWP")+Work_SWP->WP_PGI_NUM+Work_SWP->WP_SEQ_LI))

            SWP->(RecLock("SWP",.T.))    // efetua append e trava
            AVREPLACE("Work_SWP","SWP")
            MSMM(,nTamEsp,,Work_SWP->WP_ESP_VM,1,,,"SWP","WP_ESPECIF")
            MSMM(,nTamInf,,Work_SWP->WP_INF_VM,1,,,"SWP","WP_INFCOMP")
            SWP->WP_FILIAL := xFilial("SWP")
            SWP->(MsUnlock())
         EndIf
         Work_SWP->(dbSkip())
      EndDo

      Work->(dbSetOrder(nOrdWork))

      // JBS 25/11/2003
      // Gravação dos Numeros e Orgaos dos Processo Anuentes...
      // -------------------------------------------------------
      // Apaga no EIT, Todas as ocorrencias da LSI para Evitar
      // Conflitos antes de registrar alterações da Work_EIT.
      //
      //GI400DelEIT(.F.) // Evita Conflitos
      //
      //  Após apagar as Ocorrencias da LSI, Grava os Dados da Work_EIT   - JBS 24/11/2003
      //
      GI400APPEND_EIT() // Grava EIT

   ELSE
   FOR Wind = 1 TO LEN(aCapaLi)
       IF ! SWP->(DBSEEK(xFilial("SWP")+TNro_Pgi+aCapaLi[Wind,1]))

          RecLock("SWP",.T.)    // efetua append e trava
          SWP->WP_FILIAL  := xFilial("SWP")
          SWP->WP_PGI_NUM := TNro_Pgi
          SWP->WP_SEQ_LI  := aCapaLi[Wind,1]
          SWP->WP_NCM     := aCapaLi[Wind,2]
          SWP->WP_NALADI  := aCapaLi[Wind,3]
          SWP->WP_ALADI   := aCapaLi[Wind,4]
          SWP->WP_FABR    := aCapaLi[Wind,5]
          SWP->WP_DESTAQ  := aCapaLi[Wind,6]
          SWP->WP_SUBST   := SW4->W4_LISUBST
          SWP->WP_NAL_SH  := aCapaLi[Wind,7]
          SWP->WP_UNID    := aCapaLi[Wind,8]
          //FSM - 12/11/10
          SWP->WP_URF_DES := M->W4_URF_DES
          //FIM FSM
          IF EICLoja()
             SWP->WP_FABLOJ := aCapaLI[Wind][10]
          EndIf
          If lIntDrawb .and. lokW5_AC
             SWP->WP_AC      := aCapaLi[Wind,9]
          EndIf
          SWP->WP_PAIS_PR := M->W4_COD_PRO
          //** PLB 06/08/07 - Tratamento de Regime de Tributação da PLI
          If lW4_Reg_Tri
             SWP->WP_REG_TRI := M->W4_REG_TRI
             SWP->WP_FUN_REG := M->W4_REGIMP
          EndIf
          //**

             IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"ACAPALI_GRV_SWP"),)  // JBS - 14/10/2003

          SWP->(MsUnlock())
          GI400SWPGrava() //MCF - 15/12/2015
       ENDIF
   NEXT
   ENDIF
   IF MOpcao = 1 .OR. MOpcao = 3 .OR. MOpcao = 4 .OR. MOpcao = 5
      RecLock("SW4",.F.)    // trava
      SW4->W4_POS_NUM := Tpos
      SW4->(MsUnlock())
   ENDIF


   IF MOpcao = 1
      MOcor:= STR0018 + TRANSF(TNro_Pgi, _PictPGI)
   ELSEIF MOpcao = 4
      MOcor:= STR0019 + TRANSF(TNro_Pgi, _PictPGI)
   ELSEIF MOpcao = 2
      MOcor:= STR0020 + TRANSF(TNro_Gi, '@R 9999-99/999999-9')
   ELSEIF MOpcao = 5
      MOcor:= STR0021 + TRANSF(TNro_Pgi, '@R !!!-999-99')
   ELSE
      MOcor:= STR0022 + TRANSF(TNro_Pgi, '@R !!!-999-99')
   ENDIF
   Grava_Ocor(MPo_Num,dDataBase,MOcor)
   EXIT
END

End Transaction
*---------------------------------------------------------------------------
* FINALIZA O CONTROLE DE TRANSACAO
*---------------------------------------------------------------------------
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"FIM_GI_GRAVA"),)  //TRP-05/07/07

// *** GFP - 23/03/2011 :: 17h56 - Tratamento de WorkFlow na PLI.
/*
If lEasyWorkFlow
   SX2->(DbSetOrder(1))
   If SX2->(DbSeek("EJ7"))
      EJ7->(DbSetOrder(1))
      If EJ7->(DbSeek(xFilial("EJ7")+AvKey("PLI","EJ7_COD"))) .AND. EJ7->EJ7_ATIVO == "1" .AND. EJ7->EJ7_OPCENV == "1"
         oWorkFlow := EasyWorkFlow():New("PLI", SW4->(W4_FILIAL+W4_PGI_NUM))
         oWorkFlow:Send()
      Endif
   Endif
EndIf
*/

If AvFlags("WORKFLOW")
   EasyGroupWF("LICENCA IMPORT", aChaves)
Endif

Return .T.

*---------------------------------------------------------------------------
FUNCTION GI_GravaReg(cReg_Tri)
*---------------------------------------------------------------------------

SW5->(dbSetOrder(7))
SW5->(dbSeek(xFilial()+M->W4_PGI_NUM))

While ! SW5->(Eof()) .And. SW5->W5_FILIAL == xFilial("SW5") .And.;
       SW5->W5_PGI_NUM == M->W4_PGI_NUM

   If SW5->W5_SEQ != 0
      SW5->(dbSkip())
      LOOP
   Endif

   IF ! SW3->(PosO1_ItPedidos(SW5->W5_PO_NUM,SW5->W5_CC,SW5->W5_SI_NUM,;
                     SW5->W5_COD_I,SW5->W5_FABR,SW5->W5_FORN,SW5->W5_REG,0,EICRetLoja("SW5", "W5_FABLOJ"),EICRetLoja("SW5", "W5_FORLOJ")))
      Help("", 1, "AVG0000203")//MsgStop(STR0024, STR0003)//"Erro de integridade na base de dados ! (SW3->SW5)"
      SW5->(dbSkip())
      LOOP
   Endif

   SW3->(RecLock("SW3",.F.))
   SW3->W3_REG_TRI := cReg_Tri
   SW3->(MSUnlock())

   SW5->(dbSkip())
End

Return

*----------------------------------------------------------------------------
FUNCTION DI400IdAtuSld ( PProc )
*----------------------------------------------------------------------------
IF PosOrd1_IT_Guias(Work->WKPGI_NUM,Work->WKCC,Work->WKSI_NUM,;
                    Work->WKCOD_I,Work->WKFABR,Work->WKFORN  ,;
                    Work->WKREG,0,Work->WKPO_NUM,WORK->W7_FABLOJ, WORK->W7_FORLOJ)

   MSEQ:=SW5->W5_SEQ
   SW5->(RecLock("SW5",.F.,.F.,.T.))//ASR 23/08/2005 - SW5->(RecLock("SW5",.F.))
   IF PProc="1"
      // EOB - 11/07/08 - Ao fazer o embarque de um item anuente, como a LI não pode ser usada para um outro embarque, o saldo do item da LI ficará
      // zerado e a qtde da LI ficará como foi embarcado. Caso tenha sido embarcado uma qtde menor que a da LI, o saldo voltará para o item do PO.
      // A qtde original da LI será gravada no novo campo W5_QTDELI
      IF SW5->W5_FLUXO == "1" .AND. SW5->(FIELDPOS("W5_QTDELI")) > 0   // Anuente
         nSaldoLI  := SW5->W5_SALDO_Q - Work->WKQTDE
               IF nSaldoLI > 0
            SW5->W5_QTDELI  := SW5->W5_QTDE
            SW5->W5_QTDE    := Work->WKQTDE
            DI400POSld(PProc, nSaldoLi)
            ENDIF
         SW5->W5_SALDO_Q := 0
      ELSE
         SW5->W5_SALDO_Q := SW5->W5_SALDO_Q - Work->WKQTDE
      ENDIF
   ELSEIF PProc =  "2"
      // EOB - 11/07/08 - Ao desmarcar um item anuente do embarque, deve-se voltar o saldo do item para a LI, retirando a diferenca encontrada
      // do saldo do item do PO.
      IF SW5->W5_FLUXO == "1" .AND. SW5->(FIELDPOS("W5_QTDELI")) > 0  // Anuente
         nDifLI := SW5->W5_QTDELI - SW5->W5_QTDE
         IF nDifLI > 0
            // Posiciona na seq 0 do SW3 para pegar o saldo
            nSaldoW3 := DI400POSld("S")
            IF SW5->W5_QTDE + nSaldoW3 > SW5->W5_QTDELI
               nQtde :=  SW5->W5_QTDELI
               nDiferenca := SW5->W5_QTDELI - SW5->W5_QTDE
            ELSE
               nQtde :=  SW5->W5_QTDE + nSaldoW3
               nDiferenca := nSaldoW3
            ENDIF
            SW5->W5_QTDE    := nQtde
            SW5->W5_SALDO_Q := SW5->W5_QTDE
                  DI400POSld(PProc, nDiferenca)
               ELSE
            SW5->W5_SALDO_Q := SW5->W5_SALDO_Q + Work->WKQTDEDORI
         ENDIF
      ELSE
         SW5->W5_SALDO_Q := SW5->W5_SALDO_Q + Work->WKQTDEDORI
      ENDIF
   ELSE
      // EOB - 11/07/08 - Ao alterar um item anuente do embarque, deve-se alterar a LI para que fique com a mesma qtde que o embarque e a diferenca
      // encontrada da alteração do item deverá refletir no saldo do item do PO
      IF Work->WKQTDE > Work->WKQTDEDORI
         IF SW5->W5_FLUXO == "1" .AND. SW5->(FIELDPOS("W5_QTDELI")) > 0  // Anuente
            nDiferenca := Work->WKQTDE - Work->WKQTDEDORI
            IF SW5->W5_QTDELI == 0
               SW5->W5_QTDELI := SW5->W5_QTDE
            ENDIF
            SW5->W5_QTDE    := Work->WKQTDE
            SW5->W5_SALDO_Q := 0

            DI400POSld("2", nDiferenca)
         ELSE
            SW5->W5_SALDO_Q := SW5->W5_SALDO_Q - ( Work->WKQTDE - Work->WKQTDEDORI )
         ENDIF
      ELSE
         IF SW5->W5_FLUXO == "1" .AND. SW5->(FIELDPOS("W5_QTDELI")) > 0  // Anuente
            nDiferenca := Work->WKQTDEDORI - Work->WKQTDE
            IF SW5->W5_QTDELI == 0
               SW5->W5_QTDELI := SW5->W5_QTDE
            ENDIF
            SW5->W5_QTDE    := Work->WKQTDE
            SW5->W5_SALDO_Q := 0
            DI400POSld("1", nDiferenca)
         ELSE
            SW5->W5_SALDO_Q := SW5->W5_SALDO_Q + ( Work->WKQTDEDORI - Work->WKQTDE )
         ENDIF
      ENDIF
   ENDIF
   SW5->(MSUnlock())

ENDIF
return
*------------------------------------------------------------------------------
FUNCTION DI400POSld( cProc, nValDif, lPosW3 )
// EOB - 11/07/08 - Função para atualização do saldo do PO para itens anuentes
// NCF - 22/03/11 - Adicionada a flag lPosW3 para indicar que o arquivo SW3 já
//                  estará posicionado para acerto de saldo uma vez que o item
//                  é anuente já possui PLI antes do Ped.Nacion. (não grava SW5)
*-------------------------------------------------------------------------------
LOCAL nRecSW3 := SW3->(Recno())
LOCAL nIndSW3 := SW3->(IndexOrd())
LOCAL cFilSW3 := xFilial("SW3")
LOCAL nSaldo  := 0
LOCAL bWhile := {||}
DEFAULT lPosW3 := .F.

SW3->(DBSETORDER(8))
IF !lPosW3
   SW3->(DBSEEK(cFilSW3+SW5->W5_PO_NUM+SW5->W5_POSICAO))
   bWhile := {||!SW3->(eof()) .AND. SW3->W3_FILIAL == cFilSW3 .AND. SW3->W3_PO_NUM == SW5->W5_PO_NUM .AND. SW3->W3_POSICAO == SW5->W5_POSICAO}
ELSE
   IF cProc == "1"
      bWhile := {||!SW3->(eof()) .AND. SW3->W3_FILIAL == cFilSW3 .AND. SW3->W3_PO_NUM == Work->WKPO_NUM .AND. SW3->W3_POSICAO == Work->WKPOSICAO}
   ELSE
      bWhile := {||!SW3->(eof()) .AND. SW3->W3_FILIAL == cFilSW3 .AND. SW3->W3_PO_NUM == TRB->W7_PO_NUM .AND. SW3->W3_POSICAO == TRB->W7_POSICAO}
   ENDIF
ENDIF
DO WHILE Eval(bWhile)
   SW3->(RecLock("SW3",.F.))
   IF SW3->W3_SEQ == 0
      IF cProc == "S"
         nSaldo := SW3->W3_SALDO_Q
         EXIT
      ENDIF
      IF cProc = "1" // Gravação do embarque
         SW3->W3_SALDO_Q := SW3->W3_SALDO_Q + nValDif
      ELSE
         SW3->W3_SALDO_Q := SW3->W3_SALDO_Q - nValDif
      ENDIF

   ELSEIF SW3->W3_PGI_NUM == SW5->W5_PGI_NUM
      SW3->W3_QTDE  := SW5->W5_QTDE
   ENDIF
   SW3->(MsUnLock())
   SW3->(dbSkip())
ENDDO
SW3->(dbGoto(nRecSW3))
SW3->(dbSetOrder(nIndSW3))
RETURN nSaldo


*-------------------------------------------------------------------------------------------------------*
FUNCTION DI400Grvddi(PHawb,PDataP,PDespesaP,PValorP,PDiferenca,PDespVar,PDataVar,PDespCheck, cForn, cLojaF)
*-------------------------------------------------------------------------------------------------------*
Default cForn  := ""
Default cLojaF := ""
Private PData:= PdataP, Pvalor := PvalorP, PDespesa := PDespesap //LRS - 26/05/2017 - Usado para o ponto de entrada DELETA_DESP_102

_CalcDespCamb:=EasyGParam("MV_CAMBIL")
IF _CalcDespCamb ; RETURN ; ENDIF
PRIVATE lAvIntFinEIC:= AvFlags("AVINT_FINANCEIRO_EIC")

IF(EasyEntryPoint("EIC"),ExecBlock("EIC",.F.,.F.,"ATUALIZA_DESPESAS_GRVDDI"),) //LRS - 26/05/2017 

//LGS-26/11/2015 - Verifica se as despesas existem e se foi originado a partir do numerario.
If (PDespesa == "102" .Or. PDespesa == "103") .And. EIC->(DbSeek(xFilial("EIC") + PHawb + AvKey(PDespesa,"EIC_DESPES") )) //EIC_FILIAL+EIC_HAWB+EIC_DESPES
   If !Empty(EIC->EIC_DT_EFE) .And. SWD->(DbSeek(xFilial("SWD") + EIC->EIC_HAWB + EIC->EIC_DESPES + DTOS(EIC->EIC_DT_EFE)))
      If PDespesa == "102" //.And. !Empty(SW6->W6_VENCFRE)
		 Return
      ElseIf PDespesa == "103" //.And. !Empty(SW6->W6_VENCSEG)
	     Return
	  EndIf
   EndIf
EndIf

IF !EICFI400("VER_FRETSEG",PHawb+PDespesa) ; RETURN ; ENDIF

SWD->(DBSETORDER(1))
IF ! SWD->(DBSEEK(xFilial("SWD")+PHawb+PDespesa))
   IF PValor # 0
      RecLock("SWD",.T.)
      SWD->WD_FILIAL  := xFilial("SWD")
      SWD->WD_DESPESA := PDespesa
      SWD->WD_HAWB    := PHawb
      SWD->WD_DES_ADI := PData
      SWD->WD_VALOR_R := PValor
      SWD->WD_BASEADI := "2"
      SWD->WD_PAGOPOR := "2"
      SWD->WD_FORN    := cForn
      SWD->WD_LOJA    := cLojaF

      IF SWD->(FieldPos("WD_EMISSAO")) # 0
         SWD->WD_EMISSAO := PData  //TRP - 22/02/2012 - Para os impostos, gravar o campo Data de Emissão com a Data de Pagto de Impostos informada na DI.
      ENDIF

      //TRP - 02/02/2012 - Atualizar o campo Gera Financeiro para as despesas de Frete e Seguro quando título gerado.
      If PDespesa == "102" .AND. !Empty(SW6->W6_NUMDUPF)
         SWD->WD_GERFIN:= "1"
      Endif

      If PDespesa == "103" .AND. !Empty(SW6->W6_NUMDUPS)
         SWD->WD_GERFIN:= "1"
      Endif

      IF PDespesa == "102" //MCF- 21/01/2015
      	SYB->(DBSEEK(xFilial("SYB")+PDespesa))
      		IF SWD->(FieldPos("WD_FGTITUL")) > 0 .AND. SWD->(FieldPos("WD_FGDEBCC")) > 0 .AND.;
      		SYB->(FieldPos("YB_FGTITUL")) > 0 .AND. SYB->(FieldPos("YB_FGDEBCC")) > 0
      			SWD->WD_FGTITUL := SYB->YB_FGTITUL
      			SWD->WD_FGDEBCC := SYB->YB_FGDEBCC
      		ENDIF
      ENDIF

      IF PDespesa == "103" //MCF- 21/01/2015
      	SYB->(DBSEEK(xFilial("SYB")+PDespesa))
      		IF SWD->(FieldPos("WD_FGTITUL")) > 0 .AND. SWD->(FieldPos("WD_FGDEBCC")) > 0 .AND.;
      		SYB->(FieldPos("YB_FGTITUL")) > 0 .AND. SYB->(FieldPos("YB_FGDEBCC")) > 0
      			SWD->WD_FGTITUL := SYB->YB_FGTITUL
      			SWD->WD_FGDEBCC := SYB->YB_FGDEBCC
      		ENDIF
      ENDIF

      //AAF 21/09/2009 - Gravacao do campo linha para chave unica do SWD.
      If lAvIntFinEIC
         SWD->WD_LINHA := DI500SWDLin()
      EndIf

      //RRC - 26/11/2013 - Integração SIGAEIC x SIGAESS
      EICDIESSDesp(PDespesa)

   ENDIF
ELSEIF PDespesa == "101" .OR. PDespesa == "102" .OR. PDespesa == "103" .OR. ;  //ASK - 28/09/2007
       (!SWD->WD_INTEGRA /*.AND. EMPTY(SWD->WD_GERFIN)*/)//Se não vem do numerário //AWR - 09/10/2004
                                                     //Indica que foi gerado por essa funcao DI400Grvddi()
   RecLock("SWD",.F.)

   //AWR - 05/12/03 - Não pode mais apagar
   //CCH - 24/08/09 - Deve apagar a despesa quando não houver valor vinculado na capa do desembaraço e o cliente não possuir integração SAP
   IF PValor # 0
      IF SWD->WD_DES_ADI # PData .OR. SWD->WD_VALOR_R # PValor
         If !Empty(PData)
            SWD->WD_DES_ADI:= PData
         Endif
         SWD->WD_VALOR_R:= PValor
      ENDIF
   ELSE
      IF SWD->(FieldPos("WD_SAPDOC")) # 0 //CCH - Atualiza o valor da Despesa para 0 caso haja integração SAP
         IF SWD->WD_DES_ADI # PData .OR. SWD->WD_VALOR_R # PValor
            SWD->WD_DES_ADI:= PData
            SWD->WD_VALOR_R:= PValor
         ENDIF
      ELSE
         SWD->(DBDELETE())
      ENDIF
   ENDIF

   IF EMPTY(SWD->WD_GERFIN) //LRS - 08/06/2017
      IF cForn # SWD->WD_FORN 
          SWD->WD_FORN:= cForn        
      ENDIF
        
      IF cLojaF # SWD->WD_LOJA
          SWD->WD_LOJA:= cLojaF
      ENDIF
   EndIF

   //RRC - 26/11/2013 - Integração SIGAEIC x SIGAESS
   EICDIESSDesp(PDespesa)

//NCF - 12/07/2011 - Gravar a Despesa Taxa Siscomex da DI caso já exista feita como adiantamento
ELSEIF EasyGParam("MV_CODTXSI",,"") $ SWD->WD_DESPESA
   IF PValor # 0
      RecLock("SWD",.F.)
      IF SWD->WD_DES_ADI # PData .OR. SWD->WD_VALOR_R # PValor
         SWD->WD_DES_ADI := PData
         SWD->WD_VALOR_R := PValor
      ENDIF
      //AAF 21/09/2009 - Gravacao do campo linha para chave unica do SWD.
      If lAvIntFinEIC
         SWD->WD_LINHA := DI500SWDLin()
      EndIf
   ENDIF
ENDIF
SWD->(MSUNLOCK())

IF SWD->(DBSEEK(xFilial("SWD")+PHawb+PDespCheck))
   RETURN
ENDIF

IF !lGrava ; RETURN ; ENDIF

IF ! SWD->(DBSEEK(xFilial("SWD")+PHawb+PDespVar))
   IF PDiferenca # 0
      RecLock("SWD",.T.)
      SWD->WD_FILIAL  := xFilial("SWD")
      SWD->WD_DESPESA := PDespVar
      SWD->WD_HAWB    := PHawb
      SWD->WD_DES_ADI := PDataVar
      SWD->WD_VALOR_R := PDiferenca
      SWD->WD_BASEADI := "2"
      SWD->WD_PAGOPOR := "2"
       //AAF 21/09/2009 - Gravacao do campo linha para chave unica do SWD.
      If lAvIntFinEIC
         SWD->WD_LINHA := DI500SWDLin()
      EndIf
   ENDIF
ELSE
   RecLock("SWD",.F.)
 IF PDiferenca # 0 //- AWR 5/12/03 - Nao pode mais apagar
      IF SWD->WD_DES_ADI # PDataVar .OR. SWD->WD_VALOR_R # PDiferenca
         SWD->WD_DES_ADI:= PDataVar
         SWD->WD_VALOR_R:= PDiferenca
      ENDIF
   ELSE
      IF SWD->(FieldPos("WD_SAPDOC")) # 0 //CCH - Atualiza o valor da Despesa para 0 caso haja integração SAP
         IF SWD->WD_DES_ADI # PData .OR. SWD->WD_VALOR_R # PDiferenca
            SWD->WD_DES_ADI:= PDataVar
            SWD->WD_VALOR_R:= PDiferenca
         ENDIF
      ELSE
         SWD->(DBDELETE())
      ENDIF
   ENDIF
ENDIF
SWD->(MSUNLOCK())

RETURN

*------------------------------------------------------------------*
FUNCTION Mar_DesTodos(PAlias,PCampo,PMar_Des,PCampo_Msg,PPict_Msg)
*------------------------------------------------------------------*
LOCAL MRecno , MOpcao

IF PAlias == NIL
   PAlias := SELECT()
ENDIF

MRecno := (PAlias)->(RECNO())

IF PMar_Des
   MOpcao := MsgYesNo(STR0035,STR0036)//'Deseja desmarcar todos os registros ? '###"Desmarca todos "
ELSE
   MOpcao := MsgYesNo(STR0037,STR0038)//'Deseja marcar todos os registros ? '###"Marca todos "
ENDIF

IF MOpcao == .T.
//  E_MSG("EM PROCESSAMENTO - AGUARDE...",0)
   (PAlias)->(DBGOTOP())
   WHILE ! (PAlias)->(EOF())
      IF PCampo_Msg # NIL
 //       E_Msg("PROCESSANDO ITEM - "+TRANSFORM((PAlias)->(FIELDGET(FIELDPOS(PCampo_Msg))),PPict_Msg)+" - AGUARDE...",0)
      ENDIF

      IF PMar_Des
         IF ! (PAlias)->(FIELDGET(FIELDPOS(PCampo)))
            (PAlias)->(DBSKIP()) ; LOOP
         ENDIF
      ELSE
         IF (PAlias)->(FIELDGET(FIELDPOS(PCampo)))
            (PAlias)->(DBSKIP()) ; LOOP
         ENDIF
      ENDIF

      (PAlias)->(FIELDPUT(FIELDPOS(PCampo),! (PAlias)->(FIELDGET(FIELDPOS(PCampo)))))
      (PAlias)->(DBSKIP())
   ENDDO
ENDIF
(PAlias)->(DBGOTO(MRecno))
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION VerItem()
*----------------------------------------------------------------------------
//IF Date() > AVCTOD("31/07/97")
//   Alert("versão demonstração expirada")
//   Quit
//ENDIF
Return .T.
*----------------------------------------------------------------------------*
FUNCTION Custo_em_US()
*----------------------------------------------------------------------------*
LOCAL MTot_Cus_US:=0, MTx_Usd,cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

SWD->(DBSEEK(xFilial()+SW6->W6_HAWB))

WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL+SWD->WD_HAWB = xFilial("SWD")+SW6->W6_HAWB

      IF SUBSTR(SWD->WD_DESPESA,1,1) = "9"
         SWD->(DBSKIP())
         LOOP
      ENDIF

      MTx_Usd    := BuscaTaxa(cMoedaDolar,SWD->WD_DES_ADI)
      MTot_Cus_US:= MTot_Cus_US + SWD->WD_VALOR_R / MTx_Usd
      SWD->(DBSKIP())
END

RETURN MTot_Cus_US
*----------------------------------------------------------------------------
FUNCTION Seq_Arq_Sis( )  // Retorna a proxima sequencia para nome de arquivo para interacao com SISCOMEX
*----------------------------------------------------------------------------
LOCAL nSeq:=0

IF EasyGParam("MV_SEQARQ") == 99999
   SETMV("MV_SEQARQ",0)
ENDIF
SETMV("MV_SEQARQ",EasyGParam("MV_SEQARQ")+1)

nSeq:= EasyGParam("MV_SEQARQ")
MsUnlock()
RETURN PADL(nSeq,5,'0')

*-------------------------------*
FUNCTION DoctoBase( Codigo,Tipo )
*-------------------------------*
LOCAL Retorno := SPACE(20)
LOCAL _PictPGI  := ALLTRIM(X3PICTURE("W4_PGI_NUM")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))


   DO CASE
      CASE Tipo == "P"
           Retorno :=STR0041+PADR(TRANS(SYH->YH_PO_GI,_PictPo),16)//"PO  "
      CASE Tipo == "G"
           IF SW4->(DBSEEK(xFilial()+LEFT(SYH->YH_PO_GI,10)))
              IF ! SW4->(EMPTY(W4_GI_NUM))
            Retorno :=STR0042+TRANS(SW4->W4_GI_NUM,_PictPGI)//"LI  "
              ELSE
                 Retorno :=STRT0043+PADR(TRANS(SW4->W4_PGI_NUM,_PictPGI),16)// "PLI "
              ENDIF
           ENDIF

   ENDCASE


RETURN Retorno

*------------------------------------------------------------------*
FUNCTION CalcSdoFOB(PCarta,PBase,PFOB,PSaldo,PMoeda,PPgi_PO)
*------------------------------------------------------------------*
LOCAL MFob_GI := 0, MDespesa := 0
LOCAL _bSdoPO := {|| PSaldo+= (SW3->W3_SALDO_Q*SW3->W3_PRECO)+(((SW3->W3_SALDO_Q*SW3->W3_PRECO)/ SW2->W2_FOB_TOT)*MDespesa)}
LOCAL _bSdoGI := {|| PSaldo+= (SW5->W5_SALDO_Q*SW5->W5_PRECO)+(((SW5->W5_SALDO_Q*SW5->W5_PRECO)/ MSub_FOB)*MDespesa)}
LOCAL _bSeq   := {||SW5->W5_SEQ=0}
LOCAL _bCondGI:= {||! SW5->(EOF()) .AND. SW4->W4_PGI_NUM = SW5->W5_PGI_NUM .AND. SW5->W5_FILIAL==xFilial("SW5")}
LOCAL _bCondPO:= {||!SW5->(EOF()) .AND. SW2->W2_PO_NUM = SW5->W5_PO_NUM .AND. SW5->W5_FILIAL==xFilial("SW5")}
LOCAL MInland,MPacking,MDesconto,MSub_FOB,MFrt_Int
LOCAL nIndSW2:=SW2->(INDEXORD()),nIndSW4:=SW4->(INDEXORD())

SW2->(DBSETORDER(1))
SW4->(DBSETORDER(1))

   MSub_FOB  :=0
   MInland   :=0
   MFrt_Int  :=0
   MPacking  :=0
   MDesconto :=0
   MFob_GI   :=0
PSaldo:=0

****** ROTINA PARA APURACAO DE FOB DA GUIA E DO PEDIDO ******************

   IF PBase = "P"
   IF SW2->(DBSEEK(xFilial()+PPgi_PO))
         PMoeda:= SW2->W2_MOEDA
      PFob:= (SW2->W2_FOB_TOT+SW2->W2_INLAND+SW2->W2_FRETEIN+SW2->W2_PACKING-SW2->W2_DESCONTO)
      MInland  := SW2->W2_INLAND
      MPacking := SW2->W2_PACKING
      MFrt_Int := SW2->W2_FRETEIN
      MDesconto:= SW2->W2_DESCONTO

      MDespesa := SW2->W2_INLAND+SW2->W2_FRETEIN+SW2->W2_PACKING-SW2->W2_DESCONTO

         IF SW3->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
            SW3->(DBEVAL(_bSdoPO,;
                         { || SW3->W3_SEQ=0},;
                         { ||!SW3->(EOF()) .AND. SW2->W2_PO_NUM = SW3->W3_PO_NUM .AND. SW3->W3_FILIAL==xFilial("SW3")}))
      ENDIF


      SW5->(DBSETORDER(3))

      IF SW5->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
         SW5->(DBEVAL({||PSaldo+=(SW5->W5_SALDO_Q*SW5->W5_PRECO)+(((SW5->W5_SALDO_Q*SW5->W5_PRECO)/SW2->W2_FOB_TOT)*MDespesa)},;
                         _bSeq,_bCondPO))
   ENDIF

   ENDIF
ELSE
   IF SW4->(DBSEEK(xFilial()+PPgi_PO))
            MInland  :=SW4->W4_INLAND
            MFrt_Int :=SW4->W4_FRETEINT
            MPacking :=SW4->W4_PACKING
            MDesconto:=SW4->W4_DESCONT
      MDespesa := MInland+MFrt_Int+MPacking-MDesconto

      SW5->(DBSETORDER(1))
      SW5->(DBSEEK(xFilial()+LEFT(SW4->W4_PGI_NUM,10)))
      SW5->(DBEVAL({||MFob_GI+= SW5->W5_QTDE*SW5->W5_PRECO},_bSeq,_bCondGI))
      PFob+=(MFob_GI+MDespesa)
      MSub_FOB := PFob
      PMoeda:= SW4->W4_MOEDA
      SW5->(DBSEEK(xFilial()+LEFT(SW4->W4_PGI_NUM,10)))
      SW5->(DBEVAL(_bSdoGI, _bSeq,_bCondGI))
      ENDIF
   ENDIF

SW2->(DBSETORDER(nIndSW2))
SW4->(DBSETORDER(nIndSW4))

RETURN NIL

/*
nopado por RNLP - 18/09/20 - não encontrado em nenhum fonte chamada da Função SayCIDESC
Dentro da função tem a chamada das funções Row() e Col() não compiladas, ocorrências relatadas pelo SonarCube da Totvs
*-------------------------------------------*
FUNCTION SayCIDESC(PLin,PCol_Item,PCol_Fim)
*-------------------------------------------*
LOCAL _PictITem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL MLenItem:=LEN(TRAN(SB1->B1_COD,_PictItem))+1
IF(PLin=NIL,PLin:=ROW(),)
IF(PCol_Item=NIL,PCol_Item:=COL(),) 
IF(PCol_Fim=NIL,PCol_Fim:=78,)
MLenItem+=PCol_Item
IF PCol_Fim > MLenItem+2 // so' exibe se couber mais de 1 caracter
   @ PLin,MLenItem PSAY MSMM(SB1->B1_DESC_P,PCol_Fim-MLenItem+1)
ENDIF
return
*/

*----------------------------------------------------------------------------*
FUNCTION Percentual(PVal,PSobre,PMenos)
*----------------------------------------------------------------------------*
LOCAL _perc:=0

RETURN IF(PSobre = 0,0,IF((_perc:=((PVal/PSobre)-PMenos)*100)<1000,;
                           VAL(STR(_perc,6,2)),999.99))

// EicIp150.prw
*----------------------*
FUNCTION IP150FillTab()
*----------------------*
AFILL(T_TabObs,SPACE(22))
T_TabObs[01] = STR0044//'SI em Negociacao'
T_TabObs[02] = STR0045//'Aguardando Proforma'
T_TabObs[03] = STR0046//'PO Confeccao P.L.I.'
T_TabObs[04] = STR0047//'AG. envio ao DECEX'
T_TabObs[05] = STR0048//'Processo em Anuencia'
T_TabObs[06] = STR0049//'PO Aguardando Embarque'
T_TabObs[07] = STR0050//'Embarque Confirmado'
T_TabObs[08] = STR0051//'AG. Pagamento Antecipado'
T_TabObs[09] = STR0052//'PO Nao Embarcado'
T_TabObs[10] = STR0053//'AG. Def. Requisitante'
T_TabObs[11] = STR0054//'Em Transito/Atracado'
T_TabObs[12] = STR0055//'Material Ag. no DAP'
T_TabObs[13] = STR0056//'Ag. Pagto de Impostos'
T_TabObs[14] = STR0057//'Aguardando Desembaraco'
T_TabObs[15] = STR0058//'Aguardando Entrega'
T_TabObs[16] = STR0059//'Entregue'
T_TabObs[17] = STR0060//'Ag. Guia - Port. 15'
T_TabObs[18] = STR0061//'Ag. Envio ao SUFRAMA'
T_TabObs[19] = STR0062//'PO Processo na SUFRAMA'
T_TabObs[20] = STR0063//'Ag. Nacionalizacao'
T_TabObs[21] = STR0064//'Processo Entrepostado'
return

// EicPo400.prw
*------------------------------------------------------------------------------
FUNCTION Po420GrvGI()
*------------------------------------------------------------------------------
LOCAL OldArea:=Select()  // a funcao reclock muda a area corrente

IF ! SW4->(DbSeek(xFilial()+nSeq_SLi))
   RecLock("SW4",.T.)
ELSE
   RecLock("SW4",.F.)
ENDIF
SW4->W4_FILIAL  := xFilial("SW4")
SW4->W4_GI_NUM  := nSeq_SLi
SW4->W4_PGI_NUM := nSeq_SLi
SW4->W4_PGI_DT  := dDataBase//DATE()
SW4->W4_IMPORT  := SW2->W2_IMPORT
SW4->W4_CONSIG  := SW2->W2_CONSIG
SW4->W4_FLUXO   := "7"
SW4->W4_DTEDCEX := SW2->W2_PO_DT
SW4->W4_DTSDCEX := SW2->W2_PO_DT
SW4->W4_MOEDA   := SW2->W2_MOEDA
SW4->W4_EMITIDA := "S"
SW4->W4_INLAND  := TInland
SW4->W4_FRETEIN := TFreteIntl
SW4->W4_PACKING := TPacking
SW4->W4_DESCONT := TDesconto
IF SW4->(FIELDPOS("W4_OUT_DES")) # 0
   SW4->W4_OUT_DES := TOutDesp
ENDIF
SW4->W4_FOB_TOT := SW2->W2_FOB_TOT
//SW4->W4_SISCOME :=  .T.
SW4->(MsUnlock())

//FKCOMMIT: P/ forçar a execução do comando no SQL. - Johann - 21/07/05
FKCOMMIT()

DbSelectArea(OldArea)
return

*------------------------------------------------------------------------------
FUNCTION Po420GrvIG(lInclui)
*------------------------------------------------------------------------------
LOCAL OldArea:=Select()  // a funcao reclock muda a area corrente
LOCAL lInvAnt := SX3->(dbSeek("EW4_INVOIC")) .AND. SX3->(dbSeek("EW5_INVOIC")) .AND.; //DRL - 16/09/09 - Invoices Antecipadas
                 SX2->(dbSeek("EW4")) .AND. SX2->(dbSeek("EW5")) .AND. SIX->(dbSeek("EW4")) .AND. SIX->(dbSeek("EW5"))
PRIVATE nPacking:=nInland:=nOut_Desp:=nDescont:=0
IF lInclui
   RecLock("SW5",.T.)
ELSE
   RecLock("SW5",.F.)
ENDIF
AVREPLACE("Work","SW5")//AOM - 08/04/2011
SW5->W5_COD_I   := Work->WKCOD_I
SW5->W5_FABR    := Work->WKFABR
SW5->W5_FABR_01 := Work->WKFABR_01
SW5->W5_FABR_02 := Work->WKFABR_02
SW5->W5_FABR_03 := Work->WKFABR_03
SW5->W5_FABR_04 := Work->WKFABR_04
SW5->W5_FABR_05 := Work->WKFABR_05
SW5->W5_FORN    := Work->WKFORN
SW5->W5_FLUXO   := "7"
SW5->W5_QTDE    := Work->WKQTDE
SW5->W5_PRECO   := Work->WKPRECO
SW5->W5_SALDO_Q := Work->WKSALDO_Q//Work->WKQTDE
SW5->W5_SI_NUM  := Work->WKSI_NUM
SW5->W5_PO_NUM  := TPO_NUM
SW5->W5_PGI_NUM := nSeq_SLi
SW5->W5_DT_EMB  := Work->WKDT_EMB
SW5->W5_DT_ENTR := Work->WKDT_ENTR
SW5->W5_SEQ     := 0
SW5->W5_CC      := Work->WKCC
SW5->W5_REG     := Work->WKREG
SW5->W5_POSICAO := Work->WKPOSICAO //AWR 10/02/99
SW5->W5_FILIAL := xFilial("SW5")
SW5->W5_PESO    := If (SW3->(FieldPos("W3_PESOL")) # 0, Work->WKPESOL, Work->WKPESO_L) //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário

//FSM - 31/08/2011 - "Peso Bruto Unitário"
If Type("lPesoBruto") == "L" .And. lPesoBruto
   SW5->W5_PESO_BR := Work->WKPSBRUTO//Grava o peso bruto do produto
EndIf

//1SW5->W5_PESO := Work->WKPESO_L //Dourado 04/07/2001
If EICLoja()
   SW5->W5_FABLOJ	:= Work->W3_FABLOJ
   SW5->W5_FAB1LOJ	:= Work->W3_FAB1LOJ
   SW5->W5_FAB2LOJ	:= Work->W3_FAB2LOJ
   SW5->W5_FAB3LOJ	:= Work->W3_FAB3LOJ
   SW5->W5_FAB4LOJ	:= Work->W3_FAB4LOJ
   SW5->W5_FAB5LOJ	:= Work->W3_FAB5LOJ
   SW5->W5_FORLOJ	:= WORK->W3_FORLOJ
EndIf

If lInvAnt .And. (SW5->(FIELDPOS("W5_INVANT")) > 0 .AND. WORK->(FIELDPOS("WKINVOIC")) > 0) //DRL
   SW5->W5_INVANT := WORK->WKINVOIC
EndIf

 //NCF - 08/08/2011 - Classificação N.V.A.E na PLI
IF Type("lCposNVAE") # "U" .And. lCposNVAE
   SW5->W5_NVE := Work->WKNVE
EndIf

//AAF 03/03/2017 - Carregar a operação do cadastro.
ChkFile("EYJ")
EYJ->(DBSetOrder(1)) //EYJ_FILIAL+EYJ_COD
EYJ->(DBSeek(xFilial() + Work->WKCOD_I))
If EYJ->(FieldPos("EYJ_OPERAC")) > 0 .AND. !Empty(EYJ->EYJ_OPERAC)
   SW5->W5_OPERACA := EYJ->EYJ_OPERAC
EndIf

IF(EasyEntryPoint("ICPADGI2"),ExecBlock("ICPADGI2",.F.,.F.,"GRAVAW5"),)
IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"GRAVAW5"),)

SW5->(MsUnlock())
DbSelectArea(OldArea)
return

*------------------------------------------------------------------------------
FUNCTION Po420GrvIP()
*------------------------------------------------------------------------------
DBSELECTAREA('SW3')
MSeq:= PrxSeq_Ip()
RecLock("SW3",.T.)  // append
AVREPLACE("Work","SW3")//AOM - 08/04/2011
SW3->W3_COD_I   := Work->WKCOD_I
SW3->W3_FLUXO   := "7"
SW3->W3_QTDE    := Work->WKQTDE
SW3->W3_PRECO   := Work->WKPRECO
SW3->W3_SALDO_Q := 0
SW3->W3_SI_NUM  := WorK->WKSI_NUM
SW3->W3_PO_NUM  := TPO_NUM
SW3->W3_PGI_NUM := nSeq_SLi
SW3->W3_DT_EMB  := Work->WKDT_EMB
SW3->W3_DT_ENTR := Work->WKDT_ENTR
SW3->W3_SEQ     := MSeq
SW3->W3_CC      := Work->WKCC
SW3->W3_FABR    := Work->WKFABR
SW3->W3_FABR_01 := Work->WKFABR_01
SW3->W3_FABR_02 := Work->WKFABR_02
SW3->W3_FABR_03 := Work->WKFABR_03
SW3->W3_FABR_04 := Work->WKFABR_04
SW3->W3_FABR_05 := Work->WKFABR_05
SW3->W3_FORN    := Work->WKFORN
SW3->W3_REG     := Work->WKREG
SW3->W3_POSICAO := Work->WKPOSICAO //AWR 11/02/99
SW3->W3_REG_TRI := Work->WK_REG_TRI
If AvFlags("RATEIO_DESP_PO_PLI")
   SW3->W3_FRETE    :=   Work->WKFRETE
   SW3->W3_SEGURO   :=   Work->WKSEGUR
   SW3->W3_INLAND   :=   Work->WKINLAN
   SW3->W3_DESCONT  :=   Work->WKDESCO
   SW3->W3_PACKING  :=   Work->WKPACKI
   If SW3->(FieldPos("W3_OUT_DES")) > 0
      SW3->W3_OUT_DES := Work->WKOUTDE
   EndIf
EndIf
If EICLoja()
   SW3->W3_FABLOJ	:= Work->W3_FABLOJ
   SW3->W3_FORLOJ	:= Work->W3_FORLOJ
   SW3->W3_FAB1LOJ	:= Work->W3_FAB1LOJ
   SW3->W3_FAB2LOJ	:= Work->W3_FAB2LOJ
   SW3->W3_FAB3LOJ	:= Work->W3_FAB3LOJ
   SW3->W3_FAB4LOJ	:= Work->W3_FAB4LOJ
   SW3->W3_FAB5LOJ	:= Work->W3_FAB5LOJ
EndIf
If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
   SW3->W3_PART_N  := Work->WKPART_N
EndIf

If SW3->(FieldPos("W3_PESOL")) # 0 //CCH - 07/08/09 - Gravação do novo campo de Peso Líquido Unitário
   SW3->W3_PESOL := Work->WKPESOL
EndIf

If Type("lCpoCtCust") == "L" .AND. lCpoCtCust                           //NCF - 22/06/2010 - Campo do centro de Custo
   SW3->W3_CTCUSTO := Work->WKCTCUSTO
EndIf
If Type("lPesoBruto") == "L" .AND. lPesoBruto                           //NCF - 25/08/2011 - Campo do Peso Bruto Unitário
   SW3->W3_PESO_BR := Work->WKPSBRUTO
EndIf

//FSM - 16/05/2012 - Admissão em Entreposto
If EasyGParam("MV_AVG0211",,.F.)  .And. SW3->(FieldPos("W3_ALTANU")) > 0
   SW3->W3_ALTANU := Work->WKALTANU
EndIf

IF lForeCast
   SW3->W3_FORECAS := Work->WK_FORECAS
ENDIF
//NCF - 22/01/2013 - Gravar Regime de Trib. do Item
SW3->W3_GRUPORT := Work->WKGRUPORT

IF(lSeal,ExecBlock("IC193PO1",.F.,.F.,"8"),) //AWR 01/10/1999

If lNestle
   ExecBlock(cArqNestle,.F.,.F.,"7")
Endif

SW3->W3_FILIAL := xFilial("SW3")

SW3->(MsUnlock())
DBSELECTAREA('Work')
return 
*------------------------------------------------------------------------------
FUNCTION Po420_IpPos(cFlag,nFabr,cFabLoj)
*------------------------------------------------------------------------------
LOCAL OldArea:=Select()  // a funcao reclock muda a area corrente
If EICLoja()
   Default cFabLoj := WORK->W3_FABLOJ
EndIf
IF nFabr = NIL
   nFabr:= Work->WKFABR
ENDIF

If Select("EICSW3") > 0
         EICSW3->(DbCloseArea())
EndIf   
      BeginSQL Alias "EICSW3"
         Select R_E_C_N_O_ RECSW3 From %table:SW3% SW3
         Where SW3.%NotDel% And 
               SW3.W3_PO_NUM = %exp:TPO_NUM% AND 
               SW3.W3_FILIAL = %exp:xFilial("SW3")% AND 
               SW3.W3_CC = %exp:Work->WKCC% AND 
               SW3.W3_COD_I = %exp:Work->WKCOD_I% AND
               SW3.W3_SI_NUM = %exp:Work->WKSI_NUM% AND
               SW3.W3_REG = %exp:Work->WKREG% AND
               SW3.W3_FABR = %exp:nFabr% AND
               SW3.W3_FABLOJ = %exp:cFabLoj% AND
               SW3.W3_PGI_NUM = %exp:nSeq_Sli% AND
               SW3.W3_SEQ > 0
EndSql

DO WHILE ! EICSW3->(EOF() .OR. BOF()) 
   SW3->(DBGOTO(EICSW3->RECSW3))
         IF cFlag == "2"                                                      
            RecLock("SW3",.F.)
            SW3->W3_QTDE := Work->WKQTDE
         ELSEIF cFlag == "4"
            RecLock("SW3",.F.)
            SW3->W3_QTDE    := Work->WKQTDE
            SW3->W3_PRECO   := Work->WKPRECO
            SW3->W3_PACKING := Work->WKEMB
            SW3->W3_OUT_DES := Work->WKDESP
            SW3->W3_DESCONT := Work->WKDESC
         ENDIF
           IF cFlag == "3"
             RecLock("SW3",.F.)
             SW3->(DBDELETE())
           ELSE
            RecLock("SW3",.F.)
            SW3->W3_FABR    := Work->WKFABR
            SW3->W3_DT_EMB  := Work->WKDT_EMB
            SW3->W3_DT_ENTR := Work->WKDT_ENTR
            If EICLoja()
               SW3->W3_FABLOJ := Work->W3_FABLOJ
            EndIf
         ENDIF
         SW3->(MSUnlock())
         RETURN (DbSelectArea(OldArea),.T.)
   
   
   EICSW3->(DBSKIP())
ENDDO

RETURN (DbSelectArea(OldArea),IF(cFlag=="1",.T.,.F.))

*------------------------------------------------------------------------------
FUNCTION Po420_EstIG(nFabr, cFabloj)
*------------------------------------------------------------------------------
LOCAL OldArea:=Select()  // a funcao reclock muda a area corrente
Local aPgiW5:={}, i, cFil_SW5:=xFilial("SW5"), nOrd_SW5 := SW5->(IndexOrd()), nOrd_SW4
If EICLoja()
   Default cFabLoj := Work->W3_FABLOJ
EndIf

IF nFabr = NIL
   nFabr:= Work->WKFABR
ENDIF

SW5->(dbSetOrder(3))
SW5->(DbSeek(cFil_SW5+TPO_NUM+Work->WKCOD_I))

DO WHILE ! SW5->(EOF()) .AND. SW5->W5_PO_NUM ==  TPO_NUM  .AND. ;
           SW5->W5_COD_I == Work->WKCOD_I .AND. cFil_SW5 == SW5->W5_FILIAL

*       IF SW5->W5_COD_I   == Work->WKCOD_I  .AND. ;
        IF SW5->W5_CC      == Work->WKCC     .AND. ;
           SW5->W5_SI_NUM  == Work->WKSI_NUM .AND. ;
           SW5->W5_REG     == Work->WKREG    .AND. ;
           SW5->W5_FABR    == nFabr          .And. ;
           (!EICLoja() .Or. SW5->W5_FABLOJ == cFabLoj)
           RecLock("SW5",.F.,.T.)
           SW5->(DBDELETE())
           SW5->(MsUnlock())

           // Guarda todas as Pgi's deletadas do SW5.
           IF Ascan( aPgiW5, SW5->W5_PGI_NUM ) = 0
              Aadd( aPgiW5, SW5->W5_PGI_NUM )
           ENDIF

        ENDIF
        SW5->(DBSKIP())
ENDDO

// A.C.D. => O Seek deve ser por Pgi, para deletar as Pgi's que foram deletadas no SW5.
//IF ! SW5->(DbSeek(xFilial()+TPO_NUM))

nOrd_SW4 := SW4->(IndexOrd())

SW5->( DbSetOrder( 1 ) )  // Pgi

For i:=1 TO Len( aPgiW5 )

    IF ! SW5->(DbSeek(xFilial()+aPgiW5[i] ))

         SW4->( DbSetOrder( 1 ) )
         IF SW4->(DbSeek(xFilial()+aPgiW5[i]))

            RecLock("SW4",.F.,.T.)
            SW4->(DBDELETE())
            SW4->(MsUnlock())

         ENDIF
    ENDIF

NEXT

SW4->( dbSetOrder(nOrd_SW4) )
SW5->( dbSetOrder(nOrd_SW5) )

DbSelectArea(OldArea)
return

*------------------------------------------------------------------------------
FUNCTION Po420_IgPos(cFlag,nFabr, cFabLoj)
*------------------------------------------------------------------------------
LOCAL OldArea:=Select(),lGrvMerck  // a funcao reclock muda a area corrente
LOCAL nOrd_SW5 := SW5->(IndexOrd())
Local lRet2 := .F.
Local nRec := 0

Default cFabLoj := SW3->W3_FABLOJ

If Type("lPesoBruto") <> "L"
   lPesoBruto:= .F.
EndIf
//RMD - 21/03/19 - Substituido por SQL para otimizar a performance
/*
SW5->( dbSetOrder(3) )
SW5->(DbSeek(cFil_SW5+SW3->W3_PO_NUM+SW3->W3_COD_I))
*/
IF nFabr = NIL
   nFabr:= SW3->W3_FABR
ENDIF

//Primeiro faz um select no SW5 agrupando pelo item desejado para atualizar as variáveis de totais e saldos
If Type("nQtdEmb") <> "U"
   BeginSql Alias "TOTEMB"
      Select Sum(W5_QTDE) QTDEMB, Sum(W5_SALDO_Q) SLDEMB From %table:SW5% SW5
      Where SW5.%NotDel% And SW5.W5_FILIAL = %xFilial:SW5% 
      And SW5.W5_PO_NUM = %exp:TPO_NUM% And SW5.W5_COD_I = %exp:SW3->W3_COD_I% 
      And SW5.W5_SEQ > 0 And SW5.W5_CC = %exp:SW3->W3_CC% And SW5.W5_SI_NUM = %exp:SW3->W3_SI_NUM% 
      And SW5.W5_REG = %exp:SW3->W3_REG% And SW5.W5_FABR = %exp:nFabr% And SW5.W5_FABLOJ = %exp:cFabLoj%
   EndSql

   If TOTEMB->(!Eof() .And. !Bof())
      nQtdEmb := TOTEMB->QTDEMB
      /* wfs 14/10/19: a quantidade e o saldo da fase devem considerar o registro na sequencia 0 (W5_SEQ).
      nQtd_Gi := TOTEMB->QTDEMB
      nSld_Gi := TOTEMB->SLDEMB */
   EndIf

   TOTEMB->(DbCloseArea())
EndIf
//RMD - 21/03/19 - Substituido pelo SQL acima
//SW5->( dbSetOrder(3) )
//SW5->(DbSeek(cFil_SW5+SW3->W3_PO_NUM+SW3->W3_COD_I))
/*
If Type("nQtdEmb") <> "N"
   nQtdEmb := 0
EndIf
*/

   //RMD - Substituido o Loop no SW5 por SQL/Posicionamento por Recno
   BeginSql Alias "ITSW5"
      Select R_E_C_N_O_ RECSW5 From %table:SW5% SW5
      Where SW5.%NotDel% And SW5.W5_FILIAL = %xFilial:SW5% 
      And SW5.W5_PO_NUM = %exp:TPO_NUM% And SW5.W5_COD_I = %exp:SW3->W3_COD_I% 
      And SW5.W5_SEQ = 0 And SW5.W5_CC = %exp:SW3->W3_CC% And SW5.W5_SI_NUM = %exp:SW3->W3_SI_NUM% 
      And SW5.W5_REG = %exp:SW3->W3_REG% And SW5.W5_FABR = %exp:nFabr% And SW5.W5_FABLOJ = %exp:cFabLoj%
   EndSql

   /*DO WHILE ! SW5->(EOF()) .AND. SW5->W5_PO_NUM == TPO_NUM .AND. ;
            SW5->W5_COD_I == SW3->W3_COD_I .AND. SW5->W5_FILIAL == cFil_SW5*/

Do While ITSW5->(!Eof())
   SW5->(DbGoTo(ITSW5->RECSW5))

   /*
   IF SW5->W5_SEQ # 0

      If SW5->W5_CC     == SW3->W3_CC     .AND. ;
         SW5->W5_SI_NUM == SW3->W3_SI_NUM .AND. ;
         SW5->W5_REG    == SW3->W3_REG    .AND. ;
         SW5->W5_FABR   == nFabr          .And. ;
         (!EicLoja() .Or. SW5->W5_FABLOJ == cFabLoj)

         If !Empty(SW5->W5_HAWB)
            nQtdEmb += SW5->W5_QTDE
         EndIf

      EndIf

      SW5->(DBSKIP())
      LOOP
   ENDIF
   */

   IF SW5->W5_CC     == SW3->W3_CC     .AND. ;
      SW5->W5_SI_NUM == SW3->W3_SI_NUM .AND. ;
      SW5->W5_REG    == SW3->W3_REG    .AND. ;
      SW5->W5_FABR   == nFabr          .And. ;
      (!EicLoja() .Or. SW5->W5_FABLOJ == cFabLoj)

      nQtd_Gi += SW5->W5_QTDE
      nSld_Gi += SW5->W5_SALDO_Q

      IF cFlag == "1"
         IF SW3->W3_FLUXO == "7"
            nSeq_SLi := SW5->W5_PGI_NUM
         ENDIF
      ElseIf !lRet2
         IF cFlag == "2"
            lGrvMerck := (SW5->W5_DT_ENTR > Work->WKDT_ENTR)

            SW5->(RecLock("SW5",.F.))
            //SW5->W5_QTDE    +=(Work->WKQTDE - Work->WKSALDO_O )
            //SW5->W5_SALDO_Q +=(Work->WKQTDE - Work->WKSALDO_O )
            SW5->W5_QTDE    := Work->WKQTDE
            //SW5->W5_SALDO_Q += Work->WKSALDO_Q //(Work->WKQTDE - Work->WKQTDE_O )

            //** AAF 27/05/2008 - Acerto no controle de saldo de PO para item não anuente
            SW5->W5_SALDO_Q := Work->WKSALDO_Q
            //**

            SW5->W5_FABR_01 := Work->WKFABR_01
            SW5->W5_FABR_02 := Work->WKFABR_02
            SW5->W5_FABR_03 := Work->WKFABR_03
            SW5->W5_FABR_04 := Work->WKFABR_04
            SW5->W5_FABR_05 := Work->WKFABR_05
            SW5->W5_PRECO   := Work->WKPRECO
            SW5->W5_DT_EMB  := Work->WKDT_EMB
            SW5->W5_DT_ENTR := Work->WKDT_ENTR
            SW5->W5_FABR    := Work->WKFABR

            If EICLoja()
               SW5->W5_FABLOJ	:= Work->W3_FABLOJ
               SW5->W5_FAB1LOJ	:= Work->W3_FAB1LOJ
               SW5->W5_FAB2LOJ	:= Work->W3_FAB2LOJ
               SW5->W5_FAB3LOJ	:= Work->W3_FAB3LOJ
               SW5->W5_FAB4LOJ	:= Work->W3_FAB4LOJ
               SW5->W5_FAB5LOJ	:= Work->W3_FAB5LOJ
            EndIf

            SW5->W5_PESO := If (SW3->(FieldPos("W3_PESOL")) # 0, Work->WKPESOL, Work->WKPESO_L)

            //FSM - 31/08/2011 - "Peso Bruto Unitário"
            If lPesoBruto
               SW5->W5_PESO_BR := Work->WKPSBRUTO //Grava o peso bruto do produto
            EndIf

            IF(EasyEntryPoint("EICGI400"),ExecBlock("EICGI400",.F.,.F.,"DESPESA_SW5"),)

            SW5->(DBCOMMIT())
            SW5->(MSUnlock())
            //SW5->( dbSetOrder(nOrd_SW5) )
            nRec := SW5->( RecNo() )

            IF EasyEntryPoint("IC023PO1")
               EasyExRdm("U_IC023PO1", "Int100Solic_W5",{lGrvMerck,.T.})               
            ENDIF

            lRet2 := .T.
            //RETURN (DbSelectArea(OldArea),.T.)

         ELSEIF cFlag == "3"
            //SW5->( dbSetOrder(nOrd_SW5) )
            nRec := SW5->( RecNo() )
            lRet2 := .T.
            //RETURN (DbSelectArea(OldArea),.T.)

         ELSEIF cFlag == "4"
            nSeq_SLi := SW5->W5_PGI_NUM
            RecLock("SW5",.F.)
            SW5->W5_QTDE    := SW3->W3_QTDE
            SW5->W5_SALDO_Q := SW3->W3_QTDE
            SW5->W5_PRECO   := SW3->W3_PRECO
            SW5->W5_DESCONT := SW3->W3_DESCONT
            SW5->W5_OUT_DES := SW3->W3_OUT_DES
            SW5->W5_PACKING := SW3->W3_PACKING
            SW5->(DBCOMMIT())
            SW5->(MSUnlock())
            //SW5->( dbSetOrder(nOrd_SW5) )
            nRec := SW5->( RecNo() )
            lRet2 := .T.
            //RETURN (DbSelectArea(OldArea),.T.)
         ENDIF
      ENDIF
   ENDIF

   //SW5->(DBSKIP())
   ITSW5->(DbSkip())//RMD - 21/03/19
ENDDO
ITSW5->(DbCloseArea())

SW5->(dbSetOrder(nOrd_SW5))
If lRet2
   SW5->( DBGoTo(nRec) )
EndIf
//RETURN (DbSelectArea(OldArea),IF(cFlag=="1",.T.,.F.))
RETURN (DbSelectArea(OldArea),IF(cFlag=="1",.T.,lRet2))
*----------------------------------------------------------------------------
FUNCTION DI400AtuOco (PPo_Num)
*----------------------------------------------------------------------------
LOCAL cFrase
IF .NOT. EMPTY(M->W6_CHEG) .AND. M->W6_CHEG # SW6->W6_CHEG
    Grava_Ocor(PPo_Num,dDataBase,STR0071+DTOC(M->W6_CHEG) + STR0072 + M->W6_HAWB )//"ATRACADO EM "###" - Processo "
ENDIF

IF .NOT. EMPTY(M->W6_DTRECDO)  .AND. M->W6_DTRECDO # SW6->W6_DTRECDO
    Grava_Ocor(PPo_Num,dDataBase,STR0073+DTOC(M->W6_DTRECDO) )//"DATA DE RECEBIMENTO DE DOCUMENTO - "
ENDIF

IF .NOT. EMPTY(M->W6_DT)   .AND. M->W6_DT # SW6->W6_DT
    Grava_Ocor(PPo_Num,dDataBase,STR0074+DTOC(M->W6_DT)+STR0075+TRANS(M->W6_DI_NUM,AVSX3("W6_DI_NUM",6)))//"DT. DA DI (PAGTO. DE IMPOSTOS) - "###" DI Nr. "
ENDIF

IF .NOT. EMPTY(M->W6_DA_DT)   .AND. M->W6_DA_DT # SW6->W6_DA_DT
   cFrase:=STR0076+DTOC(M->W6_DA_DT)+STR0077+PADL(M->W6_DA_NUM,6,'0')//"DT. DA DECLARACAO DE ADMISSAO - "###" DA Nr. "
   Grava_Ocor(PPo_Num,dDataBase,cFrase)
ENDIF

IF .NOT. EMPTY(M->W6_DT_DESE)  .AND. M->W6_DT_DESE # SW6->W6_DT_DESE
    Grava_Ocor(PPo_Num,dDataBase,STR0078+DTOC(M->W6_DT_DESE))//"DATA DO DESEMBARACO - "
ENDIF

IF .NOT. EMPTY(M->W6_DT_ENTR)  .AND. M->W6_DT_ENTR # SW6->W6_DT_ENTR
    Grava_Ocor(PPo_Num,dDataBase,STR0079+DTOC(M->W6_DT_ENTR))//"DATA DE ENTREGA - "
ENDIF

IF EMPTY(SW6->W6_DTREG_D) .AND. !EMPTY(M->W6_DTREG_D)               // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07
   cFrase:=STR0085+TRANS(M->W6_DI_NUM,AVSX3("W6_DI_NUM",6))+STR0086+DTOC(M->W6_DTREG_D)               // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07
   Grava_Ocor(PPo_Num,dDataBase,cFrase)// "DI/DA NR: 99/9999999-9 REGISTRADA EM 99/99/99"
ENDIF

IF ! EMPTY(SW6->W6_DTREG_D) .AND. M->W6_DTREG_D # SW6->W6_DTREG_D                    // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07
   cFrase:=STR0084+STR0085+TRANS(M->W6_DI_NUM,AVSX3("W6_DI_NUM",6))+STR0087+DTOC(SW6->W6_DTREG_D)+STR0088+DTOC(M->W6_DTREG_D)   // RS Chamado 055914 Registro da DI não aparece no Status Report em 08/08/07
   Grava_Ocor(PPo_Num,dDataBase,cFrase)// "DT.REG DI NR: 99/9999999-9 ALTERADA DE 99/99/99 P/ 99/99/99"
ENDIF

DBCOMMIT()
return
******************************************************************************
* Alteracao : OS No.0330/95 Arthur C.D. - 14:12 29 Ago 1995                  *
******************************************************************************

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AVGravaSC7³ Autor ³ Cristiano A. Ferreira ³ Data ³ 01/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a funcao GravaSC7 - Microsiga                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AVGravaSC7(nOpcao,cCodProd,nQuant,nPreco,cNumPed,cLocal,;   ³±±
±±³          ³cCusto,cFornece,cLoja,dEmissao,cNumSc,dDataPr,cItem,cSequen,³±±
±±³          ³cObserv,cOrigem,cItemSc,cSiNum,nReg))                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICPO400.PRW / EIC.PRG                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION AVGravaSc7(nOpcao,cCodProd,nQuant,nPreco,cNumPed,cLocal,cCusto,;
          cLFornece,cLLoja,dEmissao,cNumSc,dDataPr,cItem,cSequen,cObserv,;
          cOrigem,cItemSc,cSiNum,nReg,cMoeda,cFluxo,cPO_NUM,cConaProPar,nDespesa,nDesconto)

LOCAL aSegUM,nQtSegUM:=0,cSegUM:=""//AWR 31/03/2000
LOCAL nSYFOrd:=SYF->(IndexOrd()),nMoeda:=NIL, nTaxa:=0
Private cGrAprov := SPACE(LEN(SY1->Y1_GRAPROV))
Private cItemSC7:=cItem //Para usar no RdMake
Private cMV_EASY_FIN:=GetNEWPAR("MV_EASYFIN","N")  // LDR
Private cEASYMV:=EasyGParam("MV_EASY") // LDR
Private cConaPro := cConaProPar
Private cFornece:=cLFornece // igor chiba 02/02/2009
Private cLoja   :=cLLoja    // igor chiba 02/02/2009

IF(EasyEntryPoint("EIC"),ExecBlock("EIC",.F.,.F.,"INICIO_GRV_SC7"),) // ldr
/*EasyGParam("MV_EIC0008",,.F.) FIXO .T. OSSME-6437 MFR 06/12/2021 */
/*If  !EasyGParam("MV_EIC0008")  .AND. cEASYMV $ cSim .AND. cProg#"PN"  
      // EOS
      SY1->(DBSetOrder(1))
      IF SY1->(DbSeek(xFilial("SY1")+SW2->W2_COMPRA)) .And. !Empty(SY1->Y1_GRAPROV)
         cGrAprov := SY1->Y1_GRAPROV
      ENDIF
      If cMoeda <> NIL
         SYF->(dbSetOrder(1))
         If SYF->(dbSeek(xFilial("SYF")+cMoeda))
            nMoeda := SYF->YF_MOEFAT
         EndIf
         SYF->(dbSetOrder(nSYFOrd))

         nTaxa := BuscaTaxa(cMoeda,dDataBase,,.F.)
      //   If nTaxa = 0 // Tirado a mensagem confome chamado - 038614
      //	   MSGINFO(STR0081+cMoeda+STR0082+DTOC(dDataBase),STR0003) //Valor de conversão zerado --> ### Em ### , Atenção
      //   EndIf
      Endif
      ////FCD OS.: 0090/02 S.O.: 0018/02
      SX6->(DBSETORDER(1))
      If lExistcFluxo:=SX6->(DBSEEK(xFilial("SX6")+"MV_EASYFPO"))
         iF EasyGParam("MV_EASYFPO")$cSim
            cFluxo := "N"
         Else
            cFluxo := "S"
         Endif
      Else
         iF cMV_EASY_FIN $ cNao // LDR
            cFluxo := "S"
         Else
            cFluxo := "N"
         Endif

      Endif


   //AWR 31/03/2000
   IF cSiNum # NIL .AND. nReg # NIL

      //aSegUM  :=AV_Seg_Uni(SW3->W3_CC,cSiNum,cCodProd,nReg,nQuant)
      aSegUM  :=AV_Seg_Uni(SW3->W3_CC,cSiNum,cCodProd,nReg,nQuant,,,SW3->W3_FABR, SW3->W3_FABLOJ, SW3->W3_FORLOJ) //WHRS 07/04/17 TE-5311 511739 / MTRADE-770 / 863 - Ao confirmar a inclusão do PO apresenta error log

      IF !EMPTY(aSegUM[2])
         IF EasyGParam("MV_UNIDCOM",,2) == 2
            nPreco  :=( nQuant * nPreco) / aSegUM[2]
            nQtSegUM:=nQuant
            nQuant  :=aSegUM[2]
         ELSE
            nQtSegUM:=aSegUM[2]
         ENDIF
         cSegUM:=aSegUM[1]
      ENDIF

   ENDIF
   SC1->(DBSETORDER(1))
   cLocal:=NIL
   cC1_CC:=cCusto// DFS - 04/02/10 - Alteração do conteúdo recebido na variável cC1_CC (Verificado por SVG)
   IF PosO1_It_Solic(SW3->W3_CC,cSiNum,cCodProd,nReg,0)
      cItemSc := SW1->W1_POSICAO
      IF SC1->(DBSEEK(xFilial("SC1")+cNumSc+cItemSc))
         IF(!EMPTY(SC1->C1_LOCAL),cLocal:=SC1->C1_LOCAL,)
         cC1_CC:=SC1->C1_CC// AWR - JS - 19/04/2004
         RecLock("SC1", .F.)
         SC1->C1_PEDIDO  := cNumPed
         SC1->C1_ITEMPED := cItem
         SC1->(MsUnlock())
      ENDIF
      //DFS - 04/02/10 - Criação de tratamento para não deixar o campo Centro Custo sem preenchimento (Verificado por SVG)
      If (Empty(cC1_CC))
         cC1_CC := SW0->W0__CC
      Endif

   ENDIF

   IF !EasyGParam("MV_GCUSTO",,.T.) //.AND. EMPTY(cCusto)//MCF - 14/01/2016 //LGS-17/10/2014
      cC1_CC := ""
   ENDIF

   If !EICLoja()
      // Ldr -  02/07/05 - Para nao gravar somente '01', mais sim a loja do primeiro fornecedor que encontrar  
      SA2->(DbSetorder(1))
      If SA2->(DbSeek(xFilial("SA2")+cFornece))
         If !Empty(SA2->A2_LOJA)
            cLoja:=SA2->A2_LOJA
         EndIf
      EndIf
   EndIf

   SC7->(DBSETORDER(1))//PARA SER UTILIZADO NA FUNCAO GRAVASC7() DA MICROSIGA.

   IF(EasyEntryPoint("EICPO400"),ExecBlock("EICPO400",.F.,.F.,"GRAVA_SC7"),)

   //AvStAction("203",.F.)//AWR 17/03/2009
   //OAP - Substituição feita no antigo EICPOCO
   IF EasyGParam("MV_EIC_PCO",,.F.)
      Busca_FornImp()
   ENDIF

   cItem := cItemSC7

   GravaSc7(nOpcao,cCodProd,nQuant,nPreco,cNumPed,cLocal,cC1_CC,;
            cFornece,cLoja,dEmissao,cNumSc,dDataPr,cItem,cSequen,cObserv,;
            cOrigem,cItemSc,nQtSegUM,cSegUM,nMoeda,cFluxo,nTaxa, cPO_NUM, cGrAprov,cConaPro,nDespesa,nDesconto)
Endif
*/
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AV_Seg_Uni³ Autor ³ Alex Wallauer         ³ Data ³ 31/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Devlove uma array com Unidade e a quantidade               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AV_Seg_Uni(cCC,cSiNum,cCod_i,nReg,nQtde,nSegUM)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICPO400.PRW / EIC.PRG                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------------------------------------------------------------*
FUNCTION AV_Seg_Uni(cCC,cSiNum,cCod_i,nReg,nQtde,nSegUM,lEmbarque, cFORN, cFABLOJ, cFORLOJ) //WHRS 07/04/17 TE-5311 511739 / MTRADE-770 / 863 - Ao confirmar a inclusão do PO apresenta error log
*---------------------------------------------------------------------------------*
LOCAL aRet, nArea:=SELECT()
/// aRet:={"",0,If(IF(lEmbarque==NIL,lEmbarque:=.F.,lEmbarque),W5peso(),SB1->B1_PESO)} //Dourado 04/07/2001
//aRet:={"",0,If(IF(lEmbarque==NIL,lEmbarque:=.F.,lEmbarque),W5peso(),B1PESO(cCC,cSiNum,cCod_I,nReg))} // LDR 0007/04
  aRet:={"",0,If(IF(lEmbarque==NIL,lEmbarque:=.F.,lEmbarque),W5peso(),B1PESO(cCC,cSiNum,cCod_I,nReg, , cFORN, cFABLOJ, cFORLOJ))} //WHRS 07/04/17 TE-5311 511739 / MTRADE-770 / 863 - Ao confirmar a inclusão do PO apresenta error log

IF PosO1_It_Solic(cCC,cSiNum,cCod_I,nReg,0)
   IF !EMPTY(SW1->W1_QTSEGUM) .AND. !EMPTY(SW1->W1_SEGUM)

      nOrdSW0:= SW0->(INDEXORD())
      SW0->(DBSETORDER(1))
      If SW0->(DBSeek(xFilial("SW0")+cCC+cSiNum))
         nOrdSC1:= SC1->(INDEXORD())
         SC1->(DBSETORDER(2))
         If SC1->(DBSEEK(xFilial('SC1')+cCod_i+SW0->W0_C1_NUM))
            aRet[1]:= SC1->C1_SEGUM
         Endif
         SC1->(DBSETORDER(nOrdSC1))
      Endif
      SW0->(DBSETORDER(nOrdSW0))
      aRet[2]:=(SW1->W1_QTSEGUM/SW1->W1_QTDE) * nQtde
///   IF GetNewPar("MV_UNIDCOM",2) == 2
//       aRet[1]:= SB1->B1_UM//SW1->W1_SEGUM
///      aRet[3]:= IF(lEmbarque,W5Peso(),SB1->B1_PESO) / (SW1->W1_QTDE/SW1->W1_QTSEGUM)
///   Else
//       aRet[1]:= SB1->B1_SEGUM
///      aRet[3]:= IF(lEmbarque,W5Peso(),SB1->B1_PESO)
///   Endif
      aRet[3] := IF(lEmbarque,W5Peso(),B1PESO(cCC,cSiNum,cCod_I,nReg)) // LDR 0007/04
   ENDIF
ENDIF

IF nSegUM # NIL ; aRet:=aRet[nSegUM] ; ENDIF

SELECT(nArea)

Return aRet

*--------------------------------------------------------------------------*
Function B1Peso(M_CC, M_SI_NUM, M_COD_I, M_REG, M_FABR, M_FORN, M_FABLOJ, M_FORLOJ)
// RA - 14/10/03 - O.S. 1030/03
// RA - 16/10/03 - O.S. 1052/03
// RA - 18/12/03 - O.S. 1413/03
// SB1 ja deve estar posicionado.
// MV_PESONEW - Indica se o (Peso vira do SB1)(.F.)(DEFAULT) ou
//              (Peso vira do SA5 ou Conversao de Unidades)(.T.)
//              para o MV_EASY = NAO.
// Casos os parametros M_FABR ou M_FORN nao forem passados continua usando
// o Peso do SB1 para  MV_EASY = NAO, mesmo que MV_PESONEW esteja .T. .
// Para MV_UNIDCOM = 2,MV_EASY = SIM, utiliza o Peso do SB1 com uma
// conversao para segunda unidade baseada no SW1.
*--------------------------------------------------------------------------*
Local nRecSW1, nOrdSW1, nRecSA5, nOrdSA5, lExistA5PESO//, cEasy
Private nB1Peso
Private cEasy	//JWJ - 04/07/2005

//LRS - 20/04/2017 - Declarado as 4 variaveis como default para não dar erro 
//log no Posicione caso umas das 4 não for declarado na chamada da function
Default M_FABR   := ""
Default M_FORN   := ""
Default M_FABLOJ := ""
Default M_FORLOJ := "" 

//RMD - 21/03/19 - Campo já existe na versão 12
//SX3->(DBSETORDER(2))
lExistA5PESO := .T.//SX3->(DBSEEK("A5_PESO")) // (Existe o campo A5_PESO no SA5)
//SX3->(DBSETORDER(1))

cEasy   := EasyGParam("MV_EASY")
IF(EasyEntryPoint("EIC"),ExecBlock("EIC",.F.,.F.,"ANTES_CALC_B1PESO"),) // ldr

If EasyGParam("MV_EIC0041",,1) == 1  // GFP - 05/02/2014
   nB1Peso := SB1->B1_PESO // Peso do Cadastro de Produtos
Else
   nB1Peso := Posicione("SA5",2,xFilial("SA5")+M_COD_I+M_FORN+M_FORLOJ,"A5_PESO") //Peso do Cadastro Produtos x Fornecedor
EndIf

If cEasy $ cNao .And. GetNewPar("MV_PESONEW",.F.) .And. M_FABR != NIL .And. M_FORN != NIL
   nRecSA5 := SA5->(RecNo())
   nOrdSA5 := SA5->(IndexOrd())
   SA5->(DbSetOrder(3))
   //If SA5->(DbSeek(xFilial("SA5")+M_COD_I+M_FABR+M_FORN))
   If EICSFabFor(xFilial("SA5")+M_COD_I+M_FABR+M_FORN, M_FABLOJ, M_FORLOJ)
      If lExistA5PESO .And. SA5->A5_PESO <> 0
         // Peso do Cadastro de Produto X Fornecedor
         nB1Peso := SA5->A5_PESO // Campo Novo no SA5
      ElseIf !Empty(SA5->A5_UNID)
         // Utiliza o Cadastro de Conversao de Unidade de Medida (SJ5) com o B1_PESO
         nB1Peso := AvTransUnid(SB1->B1_UM,SA5->A5_UNID,M_COD_I,SB1->B1_PESO,.F.)
      EndIf
   EndIf
   SA5->(DbSetOrder(nOrdSA5))
   SA5->(DbGoTo(nRecSA5))
ElseIf cEasy $ cSim .And. GetNewPar("MV_UNIDCOM",2) == 2
   nRecSW1 := SW1->(RecNo())
   nOrdSW1 := SW1->(IndexOrd())
   If ( SW1->(PosO1_It_Solic(M_CC,M_SI_NUM,M_COD_I,M_REG,0) ) )
      If SW1->W1_QTSEGUM <> 0
         nB1Peso := SB1->B1_PESO / (SW1->W1_QTDE/SW1->W1_QTSEGUM)
      EndIf
   EndIf
   SW1->(DbSetOrder(nOrdSW1))
   SW1->(DbGoTo(nRecSW1))
EndIf

If(EasyEntryPoint("EIC"),ExecBlock("EIC",.F.,.F.,"DEPOIS_CALC_B1PESO"),)

Return(nB1Peso)

*----------------------------------------------------*
Function BuscaDolar()
/*Autor    : Leandro Delfino Rodrigues              */
/*Data     : 19/10/2005                             */
/*Objetivo : Esta função tem como objetivo retornar */
/* 			 a moeda dolar.                         */
*----------------------------------------------------*
Local cSimbDolar:="US$"

cSimb:=SimbToMoeda("US$")

If cSimb = 0
   cSimb:=SimbToMoeda("USD")
Endif

******************************************************************************
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EIC       ºAutor  ³Luiz Fernando       º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluida a instrução abaixo para tratamento de simbolo da  º±±
±±º          ³ moeda diferente de US$ ultilizada pelo Chile p/ que o cal- º±±
±±º          ³ culo da paridade funcione corretamente no pre-calculo de PRº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
If cSimb = 0 .and. cPaisLoc!='BRA'
   cSimb:=SimbToMoeda("U$S")
Endif
******************************************************************************

If cSimb # 0
   cSimbDolar:=EasyGParam("MV_SIMB"+ALLTRIM(STR(cSimb)))
EndIf

Return cSimbDolar

/*
Funcao     : ExistHAWBNFE(cHAWB)
Parametros : cHAWB - HAWB da SF1 ou da SW6 desejado para busca da NFE.
Retorno    : [.T.] - Se existir HAWB de NFE/NFC posicionado na SF1
             [.F.] - Se existir somente HAWB de NFD's
Objetivos  : Verifica se para o HAWB do SW6 posicionado na chamada da função existe alguma nota lançada que não seja de despesa,
             caso as notas lançadas sejam todas de despesas o programa retorna ".T.", caso tenha alguma nota que não seja de despesa
             o programa retorna ".F.".
Autor      : Ivo Santana Santos
Data/Hora  : 10/12/10
*/
Function ExistHAWBNFE(cHAWB)

Local aOrdTab    := SaveOrd({"SF1","SWD"})
Local lRet       := .F.

SWD->(DbSetOrder(1))
SWD->(DbGoTop())

Begin Sequence


   SWD->(DbSeek(xFilial()+AvKey(cHAWB,"WD_HAWB")))
   While (SWD->WD_HAWB == AvKey(cHAWB,"WD_HAWB")) .AND. !SWD->(Eof())
      If (SWD->WD_DOC+SWD->WD_SERIE) == (SF1->F1_DOC+SF1->F1_SERIE) //.OR. Empty(SWD->WD_DOC+SWD->WD_SERIE)
         SWD->(DbSkip())
         Loop
      Else
         lRet := .T.
      EndIf
      If lRet
         Break
      EndIf
      SWD->(DbSkip())
   EndDo

End Sequence

If !lRet
   RestOrd(aOrdTab,.T.)
EndIf

Return lRet

/*
Autor : Igor de Araújo Chiba
Data  : 02/02/2009
Objetivo: Mudar o fornecedor e a loja,deixar o mesmo do SYT, para serem gravados no pedido de compra do SIGACOM
*/

*------------------------------*
Static Function Busca_FornImp()
*------------------------------*
Local nOldOrder
Local lImportador:=EasyGParam("MV_PCOIMPO",,.T.)

If SW2->(FieldPos("W2_IMPCO")) <> 0
   IF !lImportador .AND. SW2->W2_IMPCO = "1"
      nOldOrder := SYT->(INDEXORD())
      SYT->(DBSETORDER(1))
      IF SYT->(DBSEEK(xFilial("SYT")+ AVKEY(SW2->W2_IMPORT,"W2_IMPORT") ))
         cFornece  := SYT->YT_FORN
         cLoja     := SYT->YT_LOJA
      ENDIF
      SYT->(DBSETORDER(nOldOrder))
   ENDIF
EndIf

Return .T.

/*
Programa   : EICDIESSDesp(cDesp)
Objetivo   : Gravar na SWD (despesas) o conteúdo dos campos referentes ao SIGAESS, quando gravada a capa do Desembaraço
Parâmetros : cDesp - Despesa para geração do Processo de Aquisição de Serviçso no SIGAESS
Autor      : Rafael Ramos Capuano
Data       : 04/12/2013 - 17:00
Revisão    : RMD - 12/09/14 - Novo tratamento para informar o produto do Frete em novo campo na via de
                              Transporte, pois existem várias NBSs para frete.
                              Além disso, grava o produto associado diretamente na despesa (SWD), possibilitando posterior edição.
*/

Function EICDIESSDesp(cDesp)
Local aOrd    := SaveOrd({"SYB","SB5", "SYQ"}) //RRC - 26/11/2013 - Integração SIGAEIC x SIGAESS
Local cItem   := ""
Local cNBS    := ""
Default cDesp := ""

If !Empty(cDesp) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EasyGParam("MV_ESS0022",,.T.) .And. SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0

   cNBS := EICTemNBS(cDesp,SW6->W6_VIA_TRA) //THTS - 29/04/2019 - Verifique se para a despesa informada, existe NBS cadastrada

   //Verifica se a despesa está associada a um serviço
   If !Empty(cNBS) .And. Empty(SWD->WD_CTRFIN1) //RMD - 31/08/17 - Caso a despesa já tenha gerado título, não atualiza a moeda/valor, pois a mesma pode ter sido gerada em reais (e esta informação deve ser preservada)
      If cDesp == "102"
         SWD->WD_MOEDA  := SW6->W6_FREMOED         
         SWD->WD_VL_MOE := SW6->W6_VLFRECC //removido fretepp da composição do valor - DTRADE3010         
         SWD->WD_TX_MOE := SW6->W6_TX_FRET
      ElseIf cDesp == "103"
         SWD->WD_MOEDA  := SW6->W6_SEGMOED
         SWD->WD_VL_MOE := SW6->W6_VL_USSE
         SWD->WD_TX_MOE := SW6->W6_TX_SEG
      EndIf
      If SWD->(FieldPos("WD_PRDSIS")) > 0 .And. cDesp $ "102/103"
         SWD->WD_PRDSIS := cItem
      EndIf
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return

/*
Autor : Lucas Raminelli
Data  : 02/02/2009
Objetivo: Liberação da Solicitação de Compras para o parametro da alçada liberado ou desativado
*/

*------------------------------*
Static Function Alcada_EIC(lLockSW2)
*------------------------------*
LOCAL lLiberado:=.F.
Local nMoe_Com := 0
Local aOrdTAB := SaveOrd({"SYF","SY1"})
Private cGrAprov := EasyGParam("MV_PCAPROV") //LRS - 27/02/2018 - Variavel utilizado no ponto de Entrada ALT_GRUPO_APROV

SYF->(dbSetOrder(1))
IF SYF->(dbSeek(xFilial("SYF") + SW2->W2_MOEDA))
    nMoe_Com := SYF->YF_MOEFAT
ENDIF

SY1->(dbSetOrder(1))
IF SY1->(DbSeek(xFilial("SY1")+SW2->W2_COMPRA)) .And. !Empty(SY1->Y1_GRAPROV)
  cGrAprov := SY1->Y1_GRAPROV
ENDIF

IF(EasyEntryPoint("EIC"),ExecBlock("EIC",.F.,.F.,"ALT_GRUPO_APROV"),) //LRS - 27/02/2018

MaAlcDoc({SW2->W2_PO_SIGA,"PC",SW2->W2_FOB_TOT,,,cGrAprov,,nMoe_Com,,SW2->W2_PO_DT},,3)
lLiberado:=MaAlcDoc({SW2->W2_PO_SIGA,"PC",SW2->W2_FOB_TOT,,,cGrAprov,,nMoe_Com,BuscaTaxa(SW2->W2_MOEDA,dDataBase),SW2->W2_PO_DT},,1)

IF lLockSW2
   SW2->(RecLock("SW2",.F.))
   IF lW2ConaPro 
      SW2->W2_CONAPRO:=If(lLiberado,"L","B")
   EndIF
   SW2->(MsUnlock())
Else
   IF lW2ConaPro 
      SW2->W2_CONAPRO:=If(lLiberado,"L","B") 
   EndIF
EndIF

RestOrd(aOrdTAB,.T.)

Return

/*
Programa   : EICTemNBS()
Objetivo   : Verificar se existe NBS cadastrada para o produto informado nas despesas
Parâmetros : cDesp - codigo da despesa
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 29/04/2019
*/
Function EICTemNBS(cDesp,cVia)
Local cRet      := ""
Local aAreaSYQ  := SYQ->(getArea())
Local aAreaSYB  := SYB->(getArea())
Local aAreaSB5  := SB5->(getArea())
Local cItem     := ""

Default cVia    := ""

//RMD - 12/09/14 - Novo tratamento para informar o produto do Frete em novo campo na via de Transporte, pois existem várias NBSs para frete.
SYQ->(DbSetOrder(1)) //YQ_FILIAL + YQ_VIA
If SYQ->(FieldPos("YQ_PRDSIS")) > 0 .And. !Empty(cVia) .And. SYQ->(DbSeek(xFilial("SYQ") + cVia)) .And. !Empty(SYQ->YQ_PRDSIS) .And. cDesp == "102" //LRS - 21/07/2017
  cItem := SYQ->YQ_PRDSIS
Else
  SYB->(DbSetOrder(1)) //YB_FILIAL + YB_DESP
  If SYB->(DbSeek(xFilial("SYB") + cDesp))
      cItem := SYB->YB_PRODUTO
  EndIf
EndIf

SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
If !Empty(cItem) .And. SB5->(DbSeek(xFilial("SB5") + cItem))
  cRet := SB5->B5_NBS
EndIf

RestArea(aAreaSB5)
RestArea(aAreaSYB)
RestArea(aAreaSYQ)

Return cRet

// EJA - 29/05/2019 - Se o parâmetro MV_NR_ISUF for vazio ou menor que 1, então retornará 78. Senão será retornado o valor do próprio parâmetro.
Function EICParISUF()
  Local nISUF := EasyGParam("MV_NR_ISUF",,78)
  If Empty(nISUF) .Or. nISUF < 1
    nISUF := 78
  EndIf
Return nISUF

// EJA - 30/05/2019 - Se cTipPes estiver como 2, retornará uma máscara do CPF. Se estiver como 1, retornará uma máscara do CNPJ
Function EICPAg(cTipPes)
Local cPict := ""

If cTipPes == "2"
	cPict := "@R 999.999.999-99"	
Else
	If Len(AllTrim(M->EIJ_AGENID)) <> 14
		M->EIJ_AGENID := Space(Len(EIJ->EIJ_AGENID))	
	EndIf
	cPict := "@R 99.999.999/9999-99"
EndIf	

cPict := cPict + "%C"
Return cPict

/*
Programa   : EICPICW6()
Objetivo   : Função para definir as máscaras
Parâmetros : cCampo - campo da máscara, cTipoReg - tipo de registro DI OU DUIMP
Return     : PICPES
Autor      : Ramon Prado
Data       : Setembro/2021
*/
Function EICPICW6()
Local cPict  := ""
Local cCampo := STRTRAN(READVAR(), 'M->') //Retirar o M-> da string cCampo
Local cTipoReg := ""


If M->W6_TIPOREG == "2" //DUIMP
   cPict := "@R! 99AA9999999999-9"
Else //DI
   cPict := "@R 99/9999999-9"
Endif

If cCampo == 'WA_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(M->WA_DI_NUM,"W6_HAWB"),"W6_TIPOREG" )
   If cTipoReg == "2" //DUIMP
      cPict := "@R! 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
EndIf
   
/*   
ElseIf cCampo == 'ED2_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(ED2->ED2_DI_NUM,"W6_HAWB"),"W6_TIPOREG" )
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
ElseIf cCampo == 'ED8_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(ED8->ED8_DI_NUM,"W6_HAWB"),"W6_TIPOREG" )
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
ElseIf cCampo == 'EDF_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(EDF->EDF_DI_NUM,"W6_HAWB"),"W6_TIPOREG" ) 
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
ElseIf cCampo == 'EDH_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(EDH->EDH_DI_NUM,"W6_HAWB"),"W6_TIPOREG" ) 
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
ElseIf cCampo == 'EJD_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(EJD->EJD_DI_NUM,"W6_HAWB"),"W6_TIPOREG" ) 
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
ElseIf cCampo == 'EV1_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(EV1->EV1_DI_NUM,"W6_HAWB"),"W6_TIPOREG" ) 
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
ElseIf cCampo == 'EVC_DI_NUM'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(EVC->EVC_DI_NUM,"W6_HAWB"),"W6_TIPOREG" )
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
ElseIf cCampo == 'WG_NR_DI'
   cTipoReg := Posicione("SW6",11, xFilial("SW6")+AvKey(SWG->WG_NR_DI,"W6_HAWB"),"W6_TIPOREG" )
   If cTipoReg == "2" //DUIMP
      cPict := "@R 99AA9999999999-9"
   Else //DI
      cPict := "@R 99/9999999-9"
   Endif
EndIf   
*/
cPict := cPict + "%C"
Return cPict
/*
Funcao     : EicAlcada
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Retornar, para o módulo de compras, se o controle de alçadas do módulo de importação está habilitado
Autor      : 
Data/Hora  : junho/2022
*/

Function EicAlcada()
Return nModulo != 17 .Or. EasyGParam("MV_AVG0170",,.F.)  
     
*---------------------------------------------------------------------------------*
*                           FIM DO PROGRAMA EIC.PRW
*---------------------------------------------------------------------------------*
