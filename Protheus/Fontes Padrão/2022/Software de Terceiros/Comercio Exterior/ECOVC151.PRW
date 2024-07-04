
//Revisão - Alcir Alves - 19-04-05 -  chamado 009290 - compatibilização com a 7.10

#INCLUDE "Ecovc151.ch"
#include "Average.ch"
#include "AvPrint.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOVC151 ³ Autor ³ ALEX WALLAUER         ³ Data ³ 19/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ SALDOS DE FORNECEDORES                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#DEFINE LARGURA     231
#DEFINE ANO         ALLTRIM(STR(YEAR(dDataBase)))
#DEFINE HORA        TIME()
#DEFINE DATA        DTOC(dDataBase)
#DEFINE JANEIRO     3
#DEFINE DEZEMBRO    14
#DEFINE SALDO_INI   1
#DEFINE ENTRADA     2
#DEFINE BAIXAS      3
#DEFINE DIFER_PAR   4
#DEFINE SALDO_FIM   5
#DEFINE PICT_15_2   "@E 999,999,999,999.99"
#DEFINE COL_WIN     15*

Function ECOVC151()

ECOVC151R3(.T.)
Return .t.
*------------------*
Function ECOVC151R3(p_R4)
*------------------*
LOCAL nOldAlias:=SELECT()
Local aSemSX3 := { { "WKIDENTCT", AVSX3("EC5_IDENTC",2),AVSX3("EC5_IDENTC",3),AVSX3("EC5_IDENTC",4) },;
                   { "WK_TIPO"  , "N", 02, 0 },;
                   { "WK_JAN"   , "N", 15, 2 },;
                   { "WK_FEV"   , "N", 15, 2 },;
                   { "WK_MAR"   , "N", 15, 2 },;
                   { "WK_ABR"   , "N", 15, 2 },;
                   { "WK_MAI"   , "N", 15, 2 },;
                   { "WK_JUN"   , "N", 15, 2 },;
                   { "WK_JUL"   , "N", 15, 2 },;
                   { "WK_AGO"   , "N", 15, 2 },;
                   { "WK_SET"   , "N", 15, 2 },;
                   { "WK_OUT"   , "N", 15, 2 },;
                   { "WK_NOV"   , "N", 15, 2 },;
                   { "WK_DEZ"   , "N", 15, 2 } }


Private aDescrReport:={"Sld. Anterior"  ,; //"SALDO ANTERIOR"
                       "Entradas     "  ,; //"ENTRADAS"
                       "Baixas       "  ,; //"BAIXAS"
                       "Dif. Paridade"  ,; //"DIF. PARIDADE"
                       "Sld. Atual   " }   //"SALDO ATUAL"

Private aHeader:={},aCampos:={}//E_CriaTrab utiliza
Private nTotEC5:=EC5->(EasyRecCount("EC5")) ,nTotEC9:= nTotEC9N:= 0, lTop:=.F.
Private cCabec
Private cCabec1
Private cCabec2
Private cText:=""
Private lPrim:=.t.
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse() 
cNomeArq:=E_CriaTrab(,aSemSX3,"Work")

IF ! USED()
   E_Msg(STR0002,1) //"NÆo foi poss¡vel abrir o arquivo tempor rio"
   RETURN .F.
ENDIF

IndRegua("Work",cNomeArq+TeOrdBagExt(),"WKIDENTCT+STR(WK_TIPO,2)")

Private cFilEC5   := xFilial("EC5")
Private cFilEC9   := xFilial("EC9")
Private cMemo     := ""
Private cMesProc  := AllTrim(EasyGParam("MV_MESPROC"))
Private dInicial  := AVCTOD("01/01/"+SUBSTR(cMesProc,3,4))
Private dFinal    := AVCTOD("31/12/"+SUBSTR(cMesProc,3,4))

Private cAnoMesEnc:=STRZERO(YEAR(dInicial),4,0) + STRZERO(MONTH(dInicial),2,0)

//If lR4
   //TRP - 14/08/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef()
//EndIf

#IFDEF TOP
   lTop := .T.
#ENDIF

ContaReg()

While .T.

   nOpca:= 1
   dbSelectArea("Work")
   
   If !Pergunte("ECOVC1",.T.)
      Work->(E_EraseArq(cNomeArq))
      Return .F.
   Endif
   
   If !E_PERIODO_OK(@dInicial,@dFinal)
      Work->(E_EraseArq(cNomeArq))
      Loop
   Endif

   IF nOpca = 0
      EXIT
   ENDIF

   EC5->(DBSETORDER(1))
   EC9->(DBSETORDER(1))
   ECB->(DBSETORDER(1))
   SA2->(DBSETORDER(1))

   If Work->(EasyRecCount("Work")) == 0
      DBSELECTAREA("Work")
      AvZap()
   Endif
      
   If nOpca == 1
      oProcess := MsNewProcess():New({|lEnd| VC151_Gwk(@lEnd) }, STR0040,STR0041,.T.) //"Contábil"###"Gerando Relatório"
      oProcess:Activate()
   Endif   

EndDo

Work->(E_EraseArq(cNomeArq))

SELECT(nOldAlias)

RETURN

*-----------------------*
FUNCTION VC151_Gwk(lEnd)
*-----------------------*
Local nTotal:=EC5->(EasyRecCount("EC5"))
Local cIDENTCT,nRegistro,nProximo,nSaldo,Wind,dData,nMovMes,nEntrada,nBaixas
Local nTxUsd:=ECOBuscaTaxa("US$",dInicial-1,.F.,@cMemo)
Local arec:=array(5)
Local aValWK
Local nRecAux
Local i
EC5->(DBSEEK(cFilEC5))

oProcess:SetRegua1(3)

oProcess:SetRegua2(nTotEC5)

oProcess:IncRegua1(STR0042) //"Lendo Arquivos 1 / 3 Invoices Contábeis"
DO WHILE EC5->(!EOF()) .AND. cFilEC5 == EC5->EC5_FILIAL

   oProcess:IncRegua2(STR0045+Alltrim(EC5->EC5_INVOIC)) //"1 / 1 Invoice "
   //IncProc(STR0006) //"1/2 Processando Invoices..."
   //nTotal--

   If lEnd
      If lEnd:=MsgYesNo(STR0043, STR0044) //"Tem certeza que deseja cancelar?"###"Atenção"
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf

   IF !EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF !EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES)) .AND.;
       EC5->EC5_VCFANO+EC5->EC5_VCFMES < cAnoMesEnc
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF EC5->EC5_AMOS $ cSim
      EC5->(DBSKIP())
      LOOP
   ENDIF

   VC151_Det()

   EC5->(DBSKIP())

ENDDO

/*
FOR I:= 1 TO nTotal
    IncProc(STR0006) //"1/2 Processando Invoices..."
NEXT
*/

Work->(DBGOTOP())

nTotal:=Work->(EasyRecCount("Work"))

DO WHILE Work->(!EOF())

   cIDENTCT := Work->WKIDENTCT
   nRegistro:= Work->(RECNO())
   nProximo := 0
   nSaldo   := 0      
   
   oProcess:IncRegua1(STR0046) //"Lendo Arquivos 2 / 3 Processando Meses"

   oProcess:SetRegua2(12)
   
   FOR Wind:= JANEIRO TO DEZEMBRO

       Work->(DBSEEK(cIDENTCT+STR(6,2)))

       dData   := AVCTOD("01/"+STRZERO(Wind-1,2)+"/"+SUBSTR(cMesProc,3,4))-1
       nMovMes := VAL(STR(Work->(FIELDGET(Wind))/ECOBuscaTaxa("US$",dData,.F.,@cMemo),15,2))
       nEntrada:= 0
       nBaixas := 0

       Work->(DBGOTO(nRegistro))

       oProcess:IncRegua2(STR0047+Alltrim(Str(Wind))) //"1 / 1 Verificando "

       DO WHILE Work->(!EOF()) .AND. Work->WKIDENTCT == cIDENTCT

          DO CASE

             CASE Work->WK_TIPO == SALDO_INI
                  IF Wind == JANEIRO
                     Work->(FIELDPUT(Wind,VAL(STR(FIELDGET(Wind)/nTxUsd,15,2))))
                  ELSE
                     Work->(FIELDPUT(Wind,FIELDGET(Wind)+nSaldo))
                  ENDIF
                  nSaldo:= Work->(FIELDGET(Wind))

             CASE Work->WK_TIPO == ENTRADA
                  nEntrada += Work->(FIELDGET(Wind))

             CASE Work->WK_TIPO == BAIXAS
                  nBaixas  += Work->(FIELDGET(Wind))

             CASE Work->WK_TIPO == DIFER_PAR
                  Work->(FIELDPUT(Wind,nSaldo+nMovMes-nEntrada+nBaixas))
                  nSaldo+= nMovMes

             CASE Work->WK_TIPO == SALDO_FIM
                  Work->(FIELDPUT(Wind,nSaldo))

          ENDCASE

          Work->(DBSKIP())

       ENDDO

       nProximo:= Work->(RECNO())
       Work->(DBGOTO(nRegistro))

   NEXT

   Work->(DBGOTO(nProximo))

ENDDO

/*
FOR I:= 1 TO nTotal
    IncProc(STR0007) //"2/2 Processando Meses..."
NEXT
*/

IF(!EMPTY(cMemo),VC151Obs(),)
if lR4
   For i:=1 to 5
      Work->(dbappend())
      Work->WKIDENTCT:=STR0017  //TOTAL
      Work->WK_TIPO:=i
      arec[i]:=Work->(Recno())
   Next   
   Work->(dbgotop())
   DO WHILE !Work->(EOF()).AND. Work->WKIDENTCT<>STR0017
      nRecAux := Work->(Recno())   
      aValWK  := {Work->WK_JAN,Work->WK_FEV,Work->WK_MAR,Work->WK_ABR,Work->WK_MAI,Work->WK_JUN,;
                  Work->WK_JUL,Work->WK_AGO,Work->WK_SET,Work->WK_OUT,Work->WK_NOV,Work->WK_DEZ}
      if Work->WK_TIPO==6
        Work->(DbSkip())
        Loop
      endif 
      Work->( DBGoTo(arec[Work->WK_TIPO]) )
      For i := 1 to Len(aValWK)
         Work->&(FieldName(i+2)) += aValWK[i]
      Next
      Work->( DBGoTo(nRecAux) )
      Work->( DBSkip() )
   EndDo
ENDIF
If(lR4,(oReport := ReportDef() ,oReport:PrintDialog()),VC151Rel(lEnd))

RETURN

*-------------------*
FUNCTION VC151_Det()
*-------------------*
LOCAL nAux

MTSAL_ANT:= 0

VC151_SLD()

IF EC9->(EOF())                      .OR.;
   EC9->EC9_FILIAL # cFilEC9         .OR.;
   EC9->EC9_INVOIC # EC5->EC5_INVOIC .OR.;
   EC9->EC9_IDENTC # EC5->EC5_IDENTC .OR.;
   EC9->EC9_FORN # EC5->EC5_FORN

   EC9->(DBSKIP(-1))

ENDIF

FOR nAux:= 1 TO 6
    VC151PosWK(nAux)
NEXT

VC151PosWK(1)

Work->(FIELDPUT(3,MTSAL_ANT))

DO WHILE EC9->(!EOF())                      .AND.;
         EC9->EC9_FILIAL == cFilEC9         .AND.;
         EC9->EC9_INVOIC == EC5->EC5_INVOIC .AND.;
         EC9->EC9_IDENTC == EC5->EC5_IDENTC .AND.;
         EC9->EC9_FORN == EC5->EC5_FORN

   IF EC9->EC9_DT_LAN  >= dInicial .AND. EC9->EC9_DT_LAN <= dFinal

      nTx_USD:= ECOBuscaTaxa("US$",EC9->EC9_DT_LAN,.F.,@cMemo)

      DO CASE

         CASE EC9->EC9_ID_CAM = "101" .OR. EC5->EC5_MOE_FO == "US$"
              VC151PosWK(2)
              nValor:= Work->(FIELDGET(MONTH(EC9->EC9_DT_LAN)+2))
              Work->(FIELDPUT(MONTH(EC9->EC9_DT_LAN)+2,nValor+EC5->EC5_FOB_TO))

         CASE EC9->EC9_ID_CAM = "101" .OR. EC9->EC9_ID_CAM = "201"
              VC151PosWK(2)
              nValor:= Work->(FIELDGET(MONTH(EC9->EC9_DT_LAN)+2))
              Work->(FIELDPUT(MONTH(EC9->EC9_DT_LAN)+2,nValor+VC151VlUsd()))

         CASE SUBSTR(EC9->EC9_ID_CAM,1,1) = "6"
              VC151PosWK(3)
              nValor:= Work->(FIELDGET(MONTH(EC9->EC9_DT_LAN)+2))
              Work->(FIELDPUT(MONTH(EC9->EC9_DT_LAN)+2,nValor+VC151VlUsd()))
      ENDCASE

      VC151PosWK(6)
      nValor:= Work->(FIELDGET(MONTH(EC9->EC9_DT_LAN)+2))

      IF SUBSTR(EC9->EC9_ID_CAM,1,1) = "6"
         Work->(FIELDPUT(MONTH(EC9->EC9_DT_LAN)+2,nValor - EC9->EC9_VALOR))
      ELSE
         Work->(FIELDPUT(MONTH(EC9->EC9_DT_LAN)+2,nValor + EC9->EC9_VALOR))
      ENDIF
                         

   ENDIF

   EC9->(DBSKIP())

   IF DTOS(EC9->EC9_DT_LAN) > DTOS(dFinal)
      EXIT
   ENDIF

ENDDO

RETURN

*--------------------*
FUNCTION VC151VlUsd()
*--------------------*
RETURN VAL(STR(EC9->EC9_VALOR/nTx_USD,15,2))

*-------------------------*
FUNCTION VC151PosWK(nTipo)
*-------------------------*
IF !Work->(DBSEEK(EC5->EC5_IDENTC+STR(nTipo,2)))
   Work->(DBAPPEND())
   Work->WKIDENTCT:= EC5->EC5_IDENTC
   Work->WK_TIPO  := nTipo
ENDIF
RETURN

*--------------------*
FUNCTION VC151_SLD()
*--------------------*
DO WHILE EC9->(!EOF())                      .AND.;
         EC9->EC9_FILIAL == cFilEC9         .AND.;
         EC9->EC9_INVOIC == EC5->EC5_INVOIC .AND.;
         EC9->EC9_IDENTC == EC5->EC5_IDENTC .AND.;
         EC9->EC9_FORN == EC5->EC5_FORN

   IF EC9->EC9_DT_LAN >= dInicial
      EXIT
   ENDIF   

   IF SUBSTR(EC9->EC9_ID_CAM,1,1) = "6"
      MTSAL_ANT -= EC9->EC9_VALOR
   ELSE
      MTSAL_ANT += EC9->EC9_VALOR
   ENDIF

   EC9->(DBSKIP())

ENDDO

RETURN

*----------------------*
Function VC151Rel(lEnd)
*----------------------*
Local nQtdeBate:=1, cArea, nTip, aTipo[5][12]
Local aDescricao:={"Sld. Anterior"  ,; //"SALDO ANTERIOR"
                   "Entradas     "  ,; //"ENTRADAS"
                   "Baixas       "  ,; //"BAIXAS"
                   "Dif. Paridade"  ,; //"DIF. PARIDADE"
                   "Sld. Atual   " }   //"SALDO ATUAL"

Private cDesc1       := "Este programa tem como objetivo imprimir relatório de"
Private cDesc2       := "Posição atual por Área"
Private cDesc3       := "", cPict := "", imprime := .T.
Private titulo       := "DEPARTAMENTO FINANCEIRO"
Private nLin         := 80, Cabec1 :="",Cabec2 := ""
Private cString      := "EC5"   //, lEnd := .F.
Private lAbortPrint  := .F., limite:= 225, tamanho:= "G"
Private nomeprog     := "ECOVC151", nTipo := 18
Private aReturn      :={ "Zebrado", 1,"Contabil", 1, 2, 1, "",1 } //"Zebrado"###"Importacao"
Private nLastKey     := 0, cbtxt := Space(10), cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}
Private wnrel        := "ECOVC151" // Coloque aqui o nome do arquivo usado para impressao em disco

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

AEVAL(aTipo,{|aTip|AFILL(aTip,0)})

nCol1_1  := 0
nLin    := 9999
nLimPage:= 55
lBateu  := .F.

Work->(DBGOTOP())

cArea := Work->WKIDENTCT

oProcess:IncRegua1(STR0048) //"Lendo Arquivos 3 / 3 Gerando Relatório"

oProcess:SetRegua2(Work->(EasyRecCount("Work")))

While  !Work->(EOF())

   IF Work->WK_TIPO == 6
      Work->(DBSKIP())
      LOOP
   ENDIF

   If nLin > nLimPage
      VC151_Cabe()
   Endif
   lBateu:=.F.

   IF nQtdeBate = 1
      @ nLin,nCol1_1 PSay __PrtThinLine()
      nLin++
      @ nLin,nCol1_1 Psay STR0016+Alltrim(Work->WKIDENTCT) //"AREA: "
      nLin++
   ENDIF

   oProcess:IncRegua2(STR0049+Alltrim(Work->WKIDENTCT)) //"1 /1 Imprimindo Área "

   @ nLin,00  Psay Alltrim(aDescricao[Work->WK_TIPO])
   @ nLin,13  Psay TRANS(Work->WK_JAN,PICT_15_2)
   @ nLin,30  Psay TRANS(Work->WK_FEV,PICT_15_2)
   @ nLin,47  Psay TRANS(Work->WK_MAR,PICT_15_2)
   @ nLin,64  Psay TRANS(Work->WK_ABR,PICT_15_2)
   @ nLin,82  Psay TRANS(Work->WK_MAI,PICT_15_2)
   @ nLin,98  Psay TRANS(Work->WK_JUN,PICT_15_2)
   @ nLin,115 Psay TRANS(Work->WK_JUL,PICT_15_2)
   @ nLin,132 Psay TRANS(Work->WK_AGO,PICT_15_2)
   @ nLin,149 Psay TRANS(Work->WK_SET,PICT_15_2)
   @ nLin,166 Psay TRANS(Work->WK_OUT,PICT_15_2)
   @ nLin,182 Psay TRANS(Work->WK_NOV,PICT_15_2)
   @ nLin,200 Psay TRANS(Work->WK_DEZ,PICT_15_2)
   nLin++

   nTip:=Work->WK_TIPO
   // Acumula Totais.
   // nTip=1 de SALDO ANTERIORES.
   // nTip=2 de ENTRADAS.
   // nTip=3 de BAIXAS.
   // nTip=4 de DIF. PARIDADE.
   // nTip=5 de SALDO ATUAL.

   aTipo[nTip][01] += Work->WK_JAN
   aTipo[nTip][02] += Work->WK_FEV
   aTipo[nTip][03] += Work->WK_MAR
   aTipo[nTip][04] += Work->WK_ABR
   aTipo[nTip][05] += Work->WK_MAI
   aTipo[nTip][06] += Work->WK_JUN
   aTipo[nTip][07] += Work->WK_JUL
   aTipo[nTip][08] += Work->WK_AGO
   aTipo[nTip][09] += Work->WK_SET
   aTipo[nTip][10] += Work->WK_OUT
   aTipo[nTip][11] += Work->WK_NOV
   aTipo[nTip][12] += Work->WK_DEZ

   Work->(DBSKIP())

   nQtdeBate++

   IF cArea # Work->WKIDENTCT
      nQtdeBate:= 1  // Para bater o 1o. campo.
      lBateu   :=.T.
      cArea    := Work->WKIDENTCT     
   ENDIF

ENDDO

If nLin > nLimPage
   VC151_Cabe()
Endif
      
//nLin++
@ nLin, nCol1_1  PSay __PrtThinLine()
// Bate Totais.    
nLin++
@ nLin,nCol1_1 Psay STR0017 //"TOTAL"
nLin++

FOR nTip := 1 TO 5
    @ nLin,00  Psay aDescricao[nTip]
    @ nLin,13  Psay TRANS(aTipo[nTip][1] ,PICT_15_2)
    @ nLin,30  Psay TRANS(aTipo[nTip][2] ,PICT_15_2)
    @ nLin,47  Psay TRANS(aTipo[nTip][3] ,PICT_15_2)
    @ nLin,64  Psay TRANS(aTipo[nTip][4] ,PICT_15_2)
    @ nLin,82  Psay TRANS(aTipo[nTip][5] ,PICT_15_2)
    @ nLin,98  Psay TRANS(aTipo[nTip][6] ,PICT_15_2)
    @ nLin,115 Psay TRANS(aTipo[nTip][7] ,PICT_15_2)
    @ nLin,132 Psay TRANS(aTipo[nTip][8] ,PICT_15_2)
    @ nLin,149 Psay TRANS(aTipo[nTip][9] ,PICT_15_2)
    @ nLin,166 Psay TRANS(aTipo[nTip][10],PICT_15_2)
    @ nLin,182 Psay TRANS(aTipo[nTip][11],PICT_15_2)
    @ nLin,200 Psay TRANS(aTipo[nTip][12],PICT_15_2)
    nLin++
    If nLin > nLimPage
       VC151_Cabe()
    Endif
NEXT

If nLin > nLimPage
   VC151_Cabe(.F.)
Endif

nLin+=2
@ nLin, nCol1_1  PSay __PrtThinLine()

nLin++
@ nLin,nCol1_1 Psay STR0019+AllTrim(EasyGParam("MV_DISTRI")) //"Distribuicao: "

nLin++
@ nLin, nCol1_1  PSay __PrtThinLine()

nLin++
@ nLin, nCol1_1 PSay STR0020+AllTrim(EasyGParam("MV_ELAB")) //"Elaborado por: "
nLin++
@ nLin, nCol1_1 PSay __PrtThinLine()

Set Printer To
Commit
Ourspool(wnrel)

MS_FLUSH()

Return

*-------------------------------*
FUNCTION VC151_Cabe(lBateSubCab)
*-------------------------------*
Local cTexto2:=STR0022+ ANO +STR0023+ HORA //"DIVIDA ATUAL EM US$ POR AREA - "###"  HORA: "

cabec1:= ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)+Space(80)
cabec2:= "Sigaeco"+Space(80)+cTexto2

Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
nLin:= 08

IF(lBateSubCab=NIL,lBateSubCab:=.T.,)

If lBateSubCab

   nLin++   

   @ nLin,00  PSay STR0026 //"DESCRIÇÃO"
   @ nLin,23  PSay STR0027 //"JANEIRO"
   @ nLin,38  PSay STR0028 //"FEVEREIRO"
   @ nLin,59  PSay STR0029 //"MARCO"
   @ nLin,76  PSay STR0030 //"ABRIL"
   @ nLin,95  PSay STR0031 //"MAIO"
   @ nLin,111 PSay STR0032 //"JUNHO"
   @ nLin,128 PSay STR0033 //"JULHO"
   @ nLin,144 PSay STR0034 //"AGOSTO"
   @ nLin,159 PSay STR0035 //"SETEMBRO"
   @ nLin,177 PSay STR0036 //"OUTUBRO"
   @ nLin,193 PSay STR0037 //"NOVEMBRO"
   @ nLin,211 PSay STR0038 //"DEZEMBRO"

   nLin++
   
Endif

Return

*------------------*
Function VC151Obs()
*------------------*
LOCAL oDlgResumo, oFont1

DEFINE MSDIALOG oDlgResumo TITLE STR0039 From 7,2 To 26,78 OF oMainWnd //'Valores de conversao zerados'

   DEFINE FONT oFont1 NAME "Courier New" SIZE 0,14

   oDlgResumo:SetFont(oFont1)

   @ 06.5,03 GET cMemo MEMO HSCROLL READONLY SIZE 295,120 OF oDlgResumo PIXEL

   DEFINE SBUTTON FROM 130,140 TYPE 1 ACTION (oDlgResumo:End()) ENABLE OF oDlgResumo PIXEL

ACTIVATE MSDIALOG oDlgResumo

Return .T.

*--------------------------*
Static Function ContaReg()
*--------------------------*
Local cQueryEC5, cWhereEC5
Local cCond:=" AND D_E_L_E_T_ <> '*'"// AND EC9.D_E_L_E_T_  <> '*' "
Local cCondAs:= " AND @DELETED@ <> '*'"// AND EC9.@DELETED@ <> '*' "

//nTotEC5  := 0
//nTotEC9  := 0
//nTotEC9N := 0

IF lTop

  cAliasEC5     := "EC5TMP"
  //cAliasEC9     := "EC9TMP"
  //cAliasEC9N    := "EC9NEW"

  // Where EC5
/*cWhereEC5:= " EC5.EC5_FILIAL='"+ cFilEC5 +"' AND EC9.EC9_FILIAL='"+cFilEC9+"' "
  cWhereEC5+= " AND EC5.EC5_FORN = EC9.EC9_FORN "

  cWhereEC5+=" AND EC5.EC5_INVOIC = EC9.EC9_INVOIC AND EC5.EC5_IDENTC = EC9.EC9_IDENTC "
  cWhereEC5+=" AND ((EC5.EC5_VCFANO+EC5.EC5_VCFMES) = '' OR  (EC5.EC5_VCFANO+EC5.EC5_VCFMES) = ' ' "
  cWhereEC5+=" OR (EC5.EC5_VCFANO+EC5.EC5_VCFMES)>'"+cAnoMesEnc+"') AND EC5.EC5_AMOS NOT IN('"+cSim+"')"

  cWhereEC5+= If(TcSrvType()<>"AS/400",cCond,cCondAs)
  
  cQueryEC5 := "SELECT DISTINCT EC5.EC5_VCFANO, EC5.EC5_VCFMES, EC5.EC5_INVOIC, EC5.EC5_FORN, EC5.EC5_IDENTC,"
  cQueryEC5 += "EC5.EC5_AMOS, EC9.EC9_INVOIC, EC9.EC9_IDENTC, EC9.EC9_FORN FROM "+RetSqlName("EC5")+ " EC5, "+RetSqlName("EC9")+ " EC9 WHERE "+cWhereEC5
*/
  //AWR - 18/04/2007 - Não há necessidade de uma SELECT com todas as condicoes
  cQueryEC5:="SELECT COUNT(*) TOTAL FROM "+RetSqlName("EC5")+" WHERE EC5_FILIAL = '"+ cFilEC5 +"'"
  cQueryEC5+= If(TcSrvType()<>"AS/400",cCond,cCondAs)  
  // EC5
  cQueryEC5 := ChangeQuery(cQueryEC5)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC5), cAliasEC5,.F.,.T.)

  IF !USED()
     MSGSTOP("Nao foi possivel executar a SELECT : "+ALLTRIM(cQueryEC5))
     RETURN .F.
  ENDIF

  dbSelectArea(cAliasEC5)
  IF (cAliasEC5)->TOTAL # 0
     nTotEC5:=(cAliasEC5)->TOTAL
  ENDIF
//Do While !(cAliasEC5)->(EOF())
//   nTotEC5++
//   (cAliasEC5)->(dbSkip())
//EndDo
  
  If Select(cAliasEC5) > 0  
     (cAliasEC5)->(DbCloseArea())
  Endif   
  
  /*
  // Where EC9
  cWhereEC9:= " EC9.EC9_FILIAL='"+ cFilEC9 +"' AND EC5.EC5_FILIAL='"+cFilEC5+"' "
  If lExisteFor
     cWhereEC9+= " AND EC9.EC9_FORN = EC5.EC5_FORN "
  Endif

  cWhereEC9+=" AND EC9.EC9_INVOIC = EC5.EC5_INVOIC AND EC9.EC9_IDENTC = EC5.EC5_IDENTC "
  cWhereEC9+=" AND EC9.EC9_DT_LAN >= '"+dtos(dInicial)+"' "
  cWhereEC9+= If(TcSrvType()<>"AS/400",cCond,cCondAs)

  cQueryEC9N := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC9")+ " EC9, "+RetSqlName("EC5")+ " EC5 WHERE "+cWhereEC9
  
  hFile:=EasyCreateFile("Thomaz1.txt")
  fwrite(hFile, cQueryEC9N)
  fclose(hFile)
  
  // EC9 New
  cQueryEC9N := ChangeQuery(cQueryEC9N)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC9N), cAliasEC9N,.F.,.T.)

  If Select(cAliasEC9N) > 0
     nTotEC9N := (cAliasEC9N)->TOTALREG
     (cAliasEC9N)->(DbCloseArea())
  Else
     nTotEC9N := 0
  Endif
  
  //Voltei para o Where EC9
  cWhereEC9+=" AND EC9.EC9_DT_LAN <='"+dtos(dFinal)+"' "

  cQueryEC9 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC9")+ " EC9, "+RetSqlName("EC5")+ " EC5 WHERE "+cWhereEC9

  hFile:=EasyCreateFile("Thomaz2.txt")
  fwrite(hFile, cQueryEC9)
  fclose(hFile)

  // EC9
  cQueryEC9 := ChangeQuery(cQueryEC9)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC9), cAliasEC9,.F.,.T.)
  
  If Select(cAliasEC9) > 0
     nTotEC9 := (cAliasEC9)->TOTALREG
     (cAliasEC9)->(DbCloseArea())
  Else
     nTotEC9 := 0
  Endif
  */
  
Else

  // EC5
  EC5->(DbSeek(cFilEC5,.T.))
  EC9->(DbSeek(cFilEC9,.T.))
  EC5->(DBEVAL({||nTotEC5++, MsProcTxt("Lendo Invoice "+EC5->EC5_INVOIC)},,{|| EC5->(!EOF()) .And. EC5->EC5_FILIAL = cFilEC5 })) //
//             EC5->EC5_FORN == EC9->EC9_FORN .And. EC5->EC5_INVOIC = EC9->EC9_INVOIC .And.;
//             EC5->EC5_IDENTC = EC9->EC9_IDENTC .And. (!Empty((EC5->EC5_VCFANO+EC5->EC5_VCFMES)) .And. (EC5->EC5_VCFANO+EC5->EC5_VCFMES)> cAnoMesEnc) .And.;
//             EC5->EC5_AMOS $ cSim })) //"Lendo Invoice "
  
  
  /*
  // EC9New
  EC9->(DbSeek(cFilEC9,.T.))
  EC9->(DBEVAL({||nTotEC9N++, MsProcTxt("Lendo Invoice "+EC9->EC9_INVOIC)},,{||EC9->(!EOF()) .And. EC9->EC9_FILIAL = cFilEC9 .And. ;
               If(lExisteFor, EC9->EC9_FORN = EC5->EC5_FORN, .T.) .And. EC9->EC9_INVOIC = EC5->EC5_INVOIC .And. ;
               EC9->EC9_IDENTCT = EC5->EC5_IDENTCT .And. EC9->EC9_DT_LAN > dInicial })) //"Lendo Invoice "

  // EC9
  EC9->(DbSeek(cFilEC9,.T.))
  EC9->(DBEVAL({||nTotEC9++, MsProcTxt("Lendo Invoice "+EC9->EC9_INVOIC)},,{||EC9->(!EOF()) .And. EC9->EC9_FILIAL = cFilEC9 .And. ;
               If(lExisteFor, EC9->EC9_FORN = EC5->EC5_FORN, .T.) .And. EC9->EC9_INVOIC = EC5->EC5_INVOIC .And. ;
               EC9->EC9_IDENTCT = EC5->EC5_IDENTCT .And. EC9->EC9_DT_LAN >= dInicial .And. EC9->EC9_DT_LAN <= dFinal })) //"Lendo Invoice "
  */
Endif

Return .T.

*---------------------------------*
Function VC151Valid(cParam)
*---------------------------------*
lRet:= .T.
Do Case
   Case cParam == "MV_PAR01"
      If dInicial <> mv_par01
         Msginfo("A data inicial só pode ser modificada através do Parâmetro 'MV_MESPROC' ", "Atenção")
         mv_par01 := dInicial
         lRet:= .F.
      Endif
   Case cParam == "MV_PAR02"
      If dFinal <> mv_par02
         Msginfo("A data final só pode ser modificada através do Parâmetro 'MV_MESPROC' ", "Atenção")
         mv_par02 := dFinal
         lRet:= .F.
      Endif
EndCase

Return lRet

//TRP - 25/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"EC5"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("ECOVC151",STR0021,"ECOVC1",{|oReport| ReportPrint(oReport)},"")

// Define o relatorio como Landscape Nick 20/10/06
oReport:opage:llandscape := .T.
oReport:opage:lportrait := .F.

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Posições mensais",aTabelas,aOrdem) 

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Cabeçalho",{""},aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WK_TIPO"          ,""       ,STR0026      ,""                                         ,20                              ,/*lPixel*/,{||aDescrReport[Work->WK_TIPO]})
TRCell():New(oSecao1,"WK_JAN"           ,"Work"   ,STR0027      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_FEV"           ,"Work"   ,STR0028      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_MAR"           ,"Work"   ,STR0029      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_ABR"           ,"Work"   ,STR0030      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_MAI"           ,"Work"   ,STR0031      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_JUN"           ,"Work"   ,STR0032      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_JUL"           ,"Work"   ,STR0033      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_AGO"           ,"Work"   ,STR0034      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_SET"           ,"Work"   ,STR0035      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_OUT"           ,"Work"   ,STR0036      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_NOV"           ,"Work"   ,STR0037      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_DEZ"           ,"Work"   ,STR0038      ,"@E 999,999,999.99"                        ,15                              ,/*lPixel*/,/*{|| code-block de impressao }*/)

oReport:Section("Posições mensais"):Cell("WK_JAN"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_FEV"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_MAR"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_ABR"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_MAI"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_JUN"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_JUL"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_AGO"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_SET"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_OUT"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_NOV"   ):SetHeaderAlign("RIGHT")
oReport:Section("Posições mensais"):Cell("WK_DEZ"   ):SetHeaderAlign("RIGHT")


oBreak := TRBreak():New(oReport:Section("Posições mensais"),{||Work->WKIDENTCT},,.F.) // "Quebra por area"
oBreak:bOnBreak:={||oReport:SkipLine(2),oReport:PrintText(if(!Work->(EOF()),if(AllTrim(Work->WKIDENTCT)==STR0017,STR0017,STR0016+Alltrim(Work->WKIDENTCT)),""),,)}

//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"Cabecalho"   ,""   , ""                     ,"@!"                               ,210                     ,/*lPixel*/,{||cCabec})

//oReport:Section("Seção 2"):Cell("Titulo"):SetCellBreak()
oReport:bOnPageBreak :={||cCabec:=cCabec1,oReport:Section("Cabeçalho"):PrintLine(),cCabec:=cCabec2,oReport:Section("Cabeçalho"):PrintLine(),oReport:FatLine()} 
oReport:bOnPageBreak :={||cCabec:=cCabec1,oReport:Section("Cabeçalho"):PrintLine(),cCabec:=cCabec2,oReport:Section("Cabeçalho"):PrintLine(),oReport:FatLine(),if(lPrim,oReport:PrintText(STR0016+Alltrim(Work->WKIDENTCT),,),)}

oReport:Section("Posições mensais"):SetHeaderBreak(.T.)
oReport:Section("Posições mensais"):SetPageBreak(.T.)
//oReport:bOnPageBreak:=if(lPrim,oReport:PrintText(STR0016+Alltrim(Work->WKIDENTCT),,),)


//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
cText:=STR0022+ ANO +STR0023+ HORA
cCabec1:=ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)+Space(80)
cCabec2:="Sigaeco"+Space(80)+cText

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.

TRPosition():New(oReport:Section("Posições mensais"),"EC5",1,{|| xFilial("EC5") })

//oSection:Print()
oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->( dbGoTop() )
lPrim:=.t.

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Posições mensais"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Cabeçalho"):Init()

//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
  if Work->WK_TIPO==6
     Work->(DbSkip())
     Loop
  endif   
  oReport:Section("Posições mensais"):PrintLine() //Impressão da linha
  oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo
oReport:SkipLine(3)
oReport:FatLine()
oReport:PrintText(STR0019+AllTrim(EasyGParam("MV_DISTRI"))) 
oReport:FatLine()
oReport:PrintText(STR0020+AllTrim(EasyGParam("MV_ELAB")))
oReport:FatLine()

//Fim da impressão da seção 1
oReport:Section("Posições mensais"):Finish()
//Fim da impressão da seção 2
oReport:Section("Cabeçalho"):Finish() 

Return .T.


*----------------------------------------------------------------------------*
*                           FIM DO PROGRAMA ECOVC151.PRW
*----------------------------------------------------------------------------*
