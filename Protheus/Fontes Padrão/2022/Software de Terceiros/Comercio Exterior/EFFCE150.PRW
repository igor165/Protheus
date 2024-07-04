#INCLUDE "EFFCE150.CH"

//Autor.....: Alessandro Alves Ferreira - AAF
//Programa..: EFFCE150.PRW
//Data......: 28/02/05
//Descricao.: Relatório de Compromissos de Exportação
//Obs.......: Somente Excel.

#INCLUDE "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"

/*
Função..: EFFCE150
Autor...: Alessandro Alves Ferreira - AAF
Data....: 28/02/05
Objetivo: Relatório de Compromissos de Exportação
*/
*******************
Function EFFCE150()
*******************
//Private cFilEF1  := xFilial("EF1")
//Private cFilEF3  := xFilial("EF3")

Private cFilSX5  := xFilial("SX5")
Private aMeses   := {STR0001, STR0002, STR0003, STR0004, STR0005, STR0006, STR0007, STR0008, STR0009, STR0010, STR0011, STR0012}//"Janeiro"###"Fevereiro"###"Março"###"Abril"###"Maio"###"Junho"###"Julho"###"Agosto"###"Setembro"###"Outubro"###"Novembro"###"Dezembro"
Private cNomArq  := ""
Private aDadosRel:= {}
Private aRel     := {}
Private lCancel  := .F.

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

Private cAlias   := iIF(lTop,"TRB","EF3")
Private cFilter
Private cOldArea := Alias()
Private nToT:= 0
Private dUltData:= CtoD("  /  /  ")
Private lFilOri  := SX3->( dbSeek("EF3_FILORI") )
Private cFileWork
Private cFiliais := "'"
Private cFilEEQ  := "'"
Private aFiliais := AvgSelectFil(.T.,"EF3")
Private aFilEEQ  := AvgSelectFil(.F.,"EEQ")

// ACSJ - 29/03/2005 - Inicio
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA"))
// ----------------- - Fim


If !aFiliais[1] == "WND_CLOSE"

   If lTop
      aEval(aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'","','")})
      aEval(aFilEEQ ,{|x,y| cFilEEQ  += x + iIF(y == Len(aFilEEQ) ,"'","','")})
      Processa({|| nToT:= CE150Query() },STR0013)//"Pesquisando Dados..."
   Else
      aEval(aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'",",")})
      Processa({|| nToT:= CE150Work()},STR0013)//"Pesquisando Dados..."
   Endif

   If nToT > 0
      RptStatus({|lCancel| CE150GrvExc()})
   Else
      Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
   Endif

   If lTop
      TRB->( dbCloseArea() )
   Else
      TRB->( E_EraseArq(cFileWork) )
   Endif
Endif

If Select("WKEXCEL") > 0    // GFP - 05/03/2013
   WKEXCEL->(DbCloseArea())
EndIf

dbSelectArea(cOldArea)

Return .T.

*********************
Function CE150Query()
*********************
Local cDel  := iIF( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
Local cQuery:= ""

//Banco	Contrato	Praça	Negociação	Entrega	Vecto.	Original	Devedor

//          Filial           Banco           Praça          Contrato        Negociação
cCampos  := "EF1.EF1_FILIAL, EF1.EF1_BAN_FI," +;
            iif(lTemChave, "EF1.EF1_PRACA,","") +;     // ACSJ - 29/03/2005
            "EF1.EF1_CONTRA, EF1.EF1_DT_CON, "
//          Data Entrega     Data Encerramento Data de Vencimento Moeda             Saldo Devedor
cCampos  += "EF1.EF1_DT_JUR, EF1.EF1_DT_ENC,   EF1.EF1_DT_VEN,    EF1.EF1_MOEDA, EF1.EF1_VL_MOE - EF1.EF1_LIQPRM AS SLD_DEVEDO, "
//          Tipo Financiam.  Cod. Evento     Data do Evento  Valor Contrato  Vencimento
cCampos  += "EF1.EF1_TP_FIN, EF3.EF3_CODEVE, EF3.EF3_DT_EVE, EF3.EF3_VL_MOE, EEQ.EEQ_VCT "
//
cFrom    := RetSqlName("EF1")+" EF1, "+RetSqlName("EF3")+" EF3, "+RetSqlName("EEQ")+" EEQ "
//
cWhere   := "EF1."+cDel+" AND EF3."+cDel+" AND EEQ."+cDel+" AND EF3.EF3_FILIAL IN("+cFiliais+") "
//
cWhere   += " AND EF1.EF1_FILIAL = EF3.EF3_FILIAL AND EF1.EF1_CONTRA = EF3.EF3_CONTRA AND EF1.EF1_DT_ENC = '' "
//
cWhere   += " AND ((EEQ.EEQ_FILIAL "+iif(lFilOri,"= EF3.EF3_FILORI "," IN ("+cFilEEQ+") ")
//
cWhere   += " AND EEQ.EEQ_PREEMB = EF3.EF3_PREEMB AND EEQ.EEQ_PARC = EF3.EF3_PARC AND EF3.EF3_CODEVE = '600' AND EEQ.EEQ_VCT >= '"+DTOS(dDataBase)+"' And EF1.EF1_TP_FIN <> '03') "
//
cWhere   += " OR ((EF3.EF3_CODEVE = '100' Or (EF3.EF3_CODEVE = '700' And EF3.EF3_DTOREV = '')) AND EEQ.R_E_C_N_O_ = (SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("EEQ")+" WHERE D_E_L_E_T_ <> '*'))) "//Garante apenas um registro no EEQ quando for evento de contrato, para evitar duplicidade de registros.
//
cOrder   := "EF1_FILIAL, EF1_TP_FIN, EF1_CONTRA, EF3_CODEVE " //"EF1_FILIAL, EF3_TP_EVE, EF1_CONTRA, EF3_CODEVE "
//
cQuery   := " SELECT "+cCampos+" FROM "+cFrom+" WHERE "+cWhere
//
cQuery2 := ChangeQuery( cQuery+" ORDER BY "+cOrder )

If Select("TRB") > 0
   TRB->( dbCloseArea() )
Endif

TcQuery cQuery2 ALIAS "TRB" NEW
TcSetField("TRB","EF1_DT_CON","D")
TcSetField("TRB","EF1_DT_JUR","D")
TcSetField("TRB","EF1_DT_ENC","D")
TcSetField("TRB","EF1_DT_VEN","D")
TcSetField("TRB","EF3_DT_EVE","D")
TcSetField("TRB","EEQ_VCT"   ,"D")
TcSetField("TRB","SLD_DEVEDO","N", AVSX3("EEC_TOTPED",3), AVSX3("EEC_TOTPED",4))

//Total de Registros
If Select("ULTDATA") > 0
   TOTALREG->( dbCloseArea() )
Endif

//cQueryUlt:= "SELECT TOP 1(QRY.EEQ_VCT) DATA FROM ("+cQuery+") QRY" //ISS - 11/02/11 - o TOP 1 não pode ser usado em ORACLE
cQueryUlt:= "SELECT MAX(QRY.EEQ_VCT) DATA FROM ("+cQuery+") QRY"
cQueryUlt+= " ORDER BY DATA DESC"
cQueryUlt:= ChangeQuery(cQueryUlt)
TcQuery cQueryUlt ALIAS "ULTDATA" NEW
TcSetField("ULTDATA","DATA","D")

dUltData:= ULTDATA->DATA
ULTDATA->( dbCloseArea() )

//Total de Registros
If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

//Total de Registros
cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP")
TcQuery cQuery ALIAS "TOTALREG" NEW

nToT:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

Return nToT

**********************
Function CE150Work()
**********************
Local i
Private cFilter:= ""

aWork := {}
AADD(aWork,{"EF1_FILIAL", AVSX3("EF1_FILIAL", 02), AVSX3("EF1_FILIAL", 03), AVSX3("EF1_FILIAL", 04)})
AADD(aWork,{"EF1_BAN_FI", AVSX3("EF1_BAN_FI", 02), AVSX3("EF1_BAN_FI", 03), AVSX3("EF1_BAN_FI", 04)})
// ACSJ - 29/03/2005 - Inicio
If lTemChave
   AADD(aWork,{"EF1_PRACA ", AVSX3("EF1_PRACA ", 02), AVSX3("EF1_PRACA ", 03), AVSX3("EF1_PRACA ", 04)})
Endif
// ----------------- - Fim
AADD(aWork,{"EF1_CONTRA", AVSX3("EF1_CONTRA", 02), AVSX3("EF1_CONTRA", 03), AVSX3("EF1_CONTRA", 04)})
AADD(aWork,{"EF1_DT_CON", AVSX3("EF1_DT_CON", 02), AVSX3("EF1_DT_CON", 03), AVSX3("EF1_DT_CON", 04)})
AADD(aWork,{"EF1_DT_JUR", AVSX3("EF1_DT_JUR", 02), AVSX3("EF1_DT_JUR", 03), AVSX3("EF1_DT_JUR", 04)})
AADD(aWork,{"EF1_DT_VEN", AVSX3("EF1_DT_VEN", 02), AVSX3("EF1_DT_VEN", 03), AVSX3("EF1_DT_VEN", 04)})
AADD(aWork,{"EF1_MOEDA" , AVSX3("EF1_MOEDA" , 02), AVSX3("EF1_MOEDA" , 03), AVSX3("EF1_MOEDA" , 04)})
AADD(aWork,{"SLD_DEVEDO", AVSX3("EF3_VL_MOE", 02), AVSX3("EF3_VL_MOE", 03), AVSX3("EF3_VL_MOE", 04)})
AADD(aWork,{"EF1_TP_FIN", AVSX3("EF1_TP_FIN", 02), AVSX3("EF1_TP_FIN", 03), AVSX3("EF1_TP_FIN", 04)})
AADD(aWork,{"EF3_CODEVE", AVSX3("EF3_CODEVE", 02), AVSX3("EF3_CODEVE", 03), AVSX3("EF3_CODEVE", 04)})
AADD(aWork,{"EF3_DT_EVE", AVSX3("EF3_DT_EVE", 02), AVSX3("EF3_DT_EVE", 03), AVSX3("EF3_DT_EVE", 04)})
AADD(aWork,{"EF3_VL_MOE", AVSX3("EF3_VL_MOE", 02), AVSX3("EF3_VL_MOE", 03), AVSX3("EF3_VL_MOE", 04)})
AADD(aWork,{"EEQ_VCT   ", AVSX3("EEQ_VCT   ", 02), AVSX3("EEQ_VCT   ", 03), AVSX3("EEQ_VCT   ", 04)})

If Select("TRB") > 0
   TRB->( DBCloseArea() )
EndIf
cFileWork:=E_CriaTrab(,aWork,"TRB")

cFilter:= "EF3_FILIAL $ "+cFiliais+" .AND. EF3_CODEVE $ '100/600' "
EF3->( dbSetOrder(1) )
EF3->( dbSetFilter( {|| &cFilter},cFilter) )

EF1->( dbSetOrder(1) )
EEQ->( dbSetOrder(1) )

EF3->( dbGoTop() )
For i:= 1 To Len(aFiliais)
   cFilOld:= cFilAnt
   cFilAnt:= aFiliais[i]
   cFilEF1:= xFilial("EF1")
   cFilEEQ:= xFilial("EEQ")

   Do While !EF3->( EoF() )
      EF1->( dbSeek(cFilEF1+EF3->EF3_CONTRA) )

      If ( EF3->EF3_CODEVE == '100' ) .OR.;
         ( EF3->EF3_CODEVE == '600' .AND. EEQ->( dbSeek(cFilEEQ+EF3->( EF3_PREEMB+EF3_PARC )) ) .AND. EEQ->EEQ_VCT > dDataBase )

         TRB->( dbAppend() )

         TRB->( EF1_FILIAL := cFilEF1        ,;
                EF1_BAN_FI := EF1->EF1_BAN_FI,;
                EF1_CONTRA := EF1->EF1_CONTRA,;
                EF1_DT_CON := EF1->EF1_DT_CON,;
                EF1_DT_JUR := EF1->EF1_DT_JUR,;
                EF1_DT_VEN := EF1->EF1_DT_VEN,;
                EF1_MOEDA  := EF1->EF1_MOEDA ,;
                SLD_DEVEDO := EF1->(EF1_VL_MOE-EF1_LIQPRM),;
                EF1_TP_FIN := EF1->EF1_TP_FIN,;
                EF3_CODEVE := EF3->EF3_CODEVE,;
                EF3_DT_EVE := EF3->EF3_DT_EVE,;
                EF3_VL_MOE := EF3->EF3_VL_MOE )
         // ACSJ - 29/03/2005 - Inicio
         If lTemChave
            TRB->EF1_PRACA  := EF1->EF1_PRACA
         Endif
         // ----------------- - Fim
         If EF3->EF3_CODEVE == '600'
            TRB->EEQ_VCT := EEQ->EEQ_VCT
            dUltData := Max(dUltData, EEQ->EEQ_VCT)
         Endif

         nToT++
      Endif

      EF3->( dbSkip() )
   EndDo
Next
cFilAnt:= cFilOld

EF3->( dbClearFilter() )

Return nTot

**********************
Function CE150GrvExc()
**********************
Local nMes     := Month(dDataBase)
Local nUltMes  := (Year(dDataBase)+6) * 12//Year(dUltData) * 12 + Month(dUltData)
Local i
Private cDirDocs := MsDocPath()
Private cArquivo := CriaTrab(,.F.)
Private aEstru   := {}
Private cPath	 := AllTrim(GetTempPath())
Private aTotal   := {}
Private cArqTemp //THTS - 25/09/2017 - Utilizado para criacao de temporario

aAdd(aEstru,{"COMP_EXP"  , "C"                    , 30                     , 0                      })
aAdd(aEstru,{"BANCO"     , AVSX3("EF1_BAN_FI", 02), AVSX3("EF1_BAN_FI", 03), AVSX3("EF1_BAN_FI", 04)})
// ACSJ - 29/03/2005 - Inicio
if lTemChave
   aAdd(aEstru,{"PRACA"     , AVSX3("EF1_PRACA" , 02), AVSX3("EF1_PRACA" , 03), AVSX3("EF1_PRACA" , 04)})
Endif
// ----------------- - Fim
aAdd(aEstru,{"CONTRATO"  , AVSX3("EF3_CONTRA", 02), AVSX3("EF3_CONTRA", 03), AVSX3("EF3_CONTRA", 04)})
aAdd(aEstru,{"DT_NEGOCIA", AVSX3("EF1_DT_CON", 02), AVSX3("EF1_DT_CON", 03), AVSX3("EF1_DT_CON", 04)})
aAdd(aEstru,{"ENTREGA"   , AVSX3("EF1_DT_JUR", 02), AVSX3("EF1_DT_JUR", 03), AVSX3("EF1_DT_JUR", 04)})
aAdd(aEstru,{"MOEDA"     , AVSX3("EF1_MOEDA" , 02), AVSX3("EF1_MOEDA" , 03), AVSX3("EF1_MOEDA" , 04)})
aAdd(aEstru,{"VENCIMENTO", AVSX3("EF1_DT_VEN", 02), AVSX3("EF1_DT_VEN", 03), AVSX3("EF1_DT_VEN", 04)})
aAdd(aEstru,{"ORIGINAL"  , AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04)})
aAdd(aEstru,{"DEVEDOR"   , AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04)})

Begin Sequence

   For i:= 1 To 10
      Do While nMes <= 12
         //Mes
         If nMes > 1 .OR. (Year(dDataBase)+i-1) * 12 + nMes <= nUltMes
            cMes:= Upper(SubStr(aMeses[nMes],1,3))+"_"+Right(Str(Year(dDataBase)+i-1),2)
            aAdd(aEstru,{cMes, "N",AVSX3("EF1_VL_MOE", 03),AVSX3("EF1_VL_MOE", 04)})
            nMes++
         Else
            BREAK
         Endif
      EndDo

      //Total Anual
      cMes:= "TOTAL_"+Right(Str(Year(dDataBase)+i-1),2)
      aAdd(aEstru,{cMes, "N",AVSX3("EF1_VL_MOE", 03),AVSX3("EF1_VL_MOE", 04)})
      nMes:= 1
   Next

End Sequence

//Total Geral
cMes:= "TOT_CONTRA"
aAdd(aEstru,{cMes, "N",AVSX3("EF1_VL_MOE", 03),AVSX3("EF1_VL_MOE", 04)})
nMes:= 1

cArqTemp := E_CriaTrab(,aEstru,cArquivo) //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados

CE150AddLin(STR0014)//"COMPROMISSOS DE EXPORTACAO"
CE150AddLin()

SetRegua(nTot)

Begin Sequence

   TRB->( dbGoTop() )
   Do While !TRB->( EoF() )
      cUltFil:= TRB->EF1_FILIAL
      If !Empty(TRB->EF1_FILIAL)
         CE150AddLin( AvgFilName({TRB->EF1_FILIAL},.T.)[1] )//Nome da Filial.
      Endif
      Do While !TRB->( EoF() ) .AND. TRB->EF1_FILIAL == cUltFil
         cTpFin   := TRB->EF1_TP_FIN
         //CE150AddLin( STR0018 + Posicione("SX5",1,cFilSX5+"CG"+cTpFin,"X5_DESCRI") )//"Contratos " - Tipo de Financiamento.
         CE150AddLin(STR0018 + AllTrim(Posicione("EF7", 1, xFilial("EF7") + cTpFin, "EF7_DESCRI")))//"Contratos " - Tipo de Financiamento.
         Do While !TRB->( EoF() ) .AND. TRB->EF1_FILIAL == cUltFil .AND. TRB->EF1_TP_FIN == cTpFin
            If lCancel
               BREAK
            Endif

            If TRB->EF3_CODEVE == '100'

               CE150AddLin(/*"COMP_EXP"*/,TRB->EF1_BAN_FI,;//"BANCO"
                                          iif(lTemChave,TRB->EF1_PRACA,Nil) ,;//"PRACA"
                                          TRB->EF1_CONTRA,;//"CONTRATO"
                                          TRB->EF1_DT_CON,;//"DT_NEGOCIA"
                                          TRB->EF1_DT_JUR,;//"ENTREGA"
                                          TRB->EF1_DT_VEN,;//"VENCIMENTO"
                                          TRB->EF1_MOEDA ,;//"MOEDA"
                                          TRB->EF3_VL_MOE,;//"ORIGINAL"
                                          TRB->SLD_DEVEDO)//"DEVEDOR"

               //Soma total do Valor Original por Filial
               nPosTot:= aScan(aTotal,{|X| X[1] == TRB->EF1_FILIAL .AND. X[2] == TRB->EF1_TP_FIN .AND. X[3] == TRB->EF1_MOEDA  .AND. x[4] == "ORIGINAL"})
               If nPosTot > 0
                  aTotal[nPosTot][5] += TRB->EF3_VL_MOE
               Else
                  aAdd(aTotal,{TRB->EF1_FILIAL, TRB->EF1_TP_FIN, TRB->EF1_MOEDA , "ORIGINAL", TRB->EF3_VL_MOE})
               Endif

               //Soma total do Saldo Devedor por Filial
               nPosTot:= aScan(aTotal,{|X| X[1] == TRB->EF1_FILIAL .AND. X[2] == TRB->EF1_TP_FIN .AND. X[3] == TRB->EF1_MOEDA  .AND. x[4] == "DEVEDOR"})
               If nPosTot > 0
                   aTotal[nPosTot][5] += TRB->SLD_DEVEDO
               Else
                  aAdd(aTotal,{TRB->EF1_FILIAL, TRB->EF1_TP_FIN, TRB->EF1_MOEDA , "DEVEDOR", TRB->SLD_DEVEDO})
               Endif

               //Soma total geral do Valor Original
               nPosTot:= aScan(aTotal,{|X| X[1] == "GERAL" .AND. X[3] == TRB->EF1_MOEDA  .AND. x[4] == "ORIGINAL"})
               If nPosTot > 0
                  aTotal[nPosTot][5] += TRB->EF3_VL_MOE
               Else
                  aAdd(aTotal,{"GERAL", "", TRB->EF1_MOEDA , "ORIGINAL", TRB->EF3_VL_MOE})
               Endif

               //Soma total Geral do Saldo Devedor
               nPosTot:= aScan(aTotal,{|X| X[1] == "GERAL" .AND. X[3] == TRB->EF1_MOEDA  .AND. x[4] == "DEVEDOR"})
               If nPosTot > 0
                  aTotal[nPosTot][5] += TRB->SLD_DEVEDO
               Else
                  aAdd(aTotal,{"GERAL", "", TRB->EF1_MOEDA , "DEVEDOR", TRB->SLD_DEVEDO})
               Endif

            ElseIf TRB->EF3_CODEVE == '600' .Or. (TRB->EF3_CODEVE == '700' .And. TRB->EF3_DT_EVE >= ((dDataBase - day(dDataBase)) + 1)) //Month(TRB->EF3_DT_EVE) >= Month(dDataBase))
               If TRB->EF3_CODEVE == '600'
                  CE150AddVinc(TRB->EF1_FILIAL, TRB->EF1_TP_FIN, TRB->EEQ_VCT, TRB->EF1_MOEDA , TRB->EF3_VL_MOE)
               EndIf
               If TRB->EF3_CODEVE == '700'
                  CE150AddVinc(TRB->EF1_FILIAL, TRB->EF1_TP_FIN, TRB->EF3_DT_EVE, TRB->EF1_MOEDA , TRB->EF3_VL_MOE)
               EndIf
            Endif

            TRB->( dbSkip() )
            IncRegua()
         EndDo
         CE150Total(cUltFil,cTpFin)
         CE150AddLin()
      EndDo
      If !Empty(cUltFil)
         CE150Total(cUltFil)
      Endif
      CE150AddLin()
   EndDo
   CE150Total()

   If EasyEntryPoint("EFFCE150")
      ExecBlock("EFFCE150", .F., .F., "FINAL_GRAVACAO")
   EndIf

End Sequence

//(cArquivo)->( dbCloseArea() )

If !lCancel

   CE150TReport(cArquivo)
   //AvExcel(cNomArq,cArquivo, .F.)

//   CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )

   //Envia ao Excel
   /*If ! ApOleClient( 'MsExcel' )
      MsgStop(STR0015) //"MsExcel não instalado."
      Return .F.
   Else
      //Abre Dbf no Excel
      oExcelApp:= MsExcel():New()
      oExcelApp:WorkBooks:Open( cPath+cArquivo+".dbf" )
      oExcelApp:SetVisible(.T.)
   EndIf*/
Endif

(cArquivo)->( E_EraseArq(cArqTemp) ) //THTS - 25/09/2017 - Fecha o temporario

Return .T.

//CE150AddLin("COMP_EXP","BANCO","PRACA","CONTRATO","DT_NEGOCIA","ENTREGA","MOEDA","VENCIMENTO","ORIGINAL","DEVEDOR")
**********************************************************************************
Function CE150AddLin(cCol1,cCol2,cCol3,cCol4,dCol5,dCol6,dCol7,cCol8,nCol9,nCol10)
**********************************************************************************
(cArquivo)->( dbAppend() )

If(cCol1<>NIL ,(cArquivo)->COMP_EXP  := cCol1 ,)
If(cCol2<>NIL ,(cArquivo)->BANCO     := cCol2 ,)
If(cCol3<>NIL ,(cArquivo)->PRACA     := cCol3 ,)
If(cCol4<>NIL ,(cArquivo)->CONTRATO  := cCol4 ,)
If(dCol5<>NIL ,(cArquivo)->DT_NEGOCIA:= dCol5 ,)
If(dCol6<>NIL ,(cArquivo)->ENTREGA   := dCol6 ,)
If(dCol7<>NIL ,(cArquivo)->VENCIMENTO:= dCol7 ,)
If(cCol8<>NIL ,(cArquivo)->MOEDA     := cCol8 ,)
If(nCol9<>NIL ,(cArquivo)->ORIGINAL  := nCol9 ,)
If(nCol10<>NIL,(cArquivo)->DEVEDOR   := nCol10,)

Return .T.

*********************************************************
Function CE150AddVinc(cFil, cTpFin, dVct, cMoeda, nVlVin)
*********************************************************
LOCAL cMes := Upper(Left(aMeses[Month(dVct)],3))+"_"+Right(Str(Year(dVct)),2)
LOCAL nPos1:= aScan(aEstru,{|X| X[1]==cMes})

//Soma total
nPosTot:= aScan(aTotal,{|X| X[1] == cFil .AND. X[2] == cTpFin .AND. X[3] == cMoeda .AND. x[4] == cMes})
If nPosTot > 0
   aTotal[nPosTot][5] += nVlVin
Else
   aAdd(aTotal,{cFil, cTpFin, cMoeda, cMes, nVlVin})
Endif

//Soma total Geral
nPosTot:= aScan(aTotal,{|X| X[1] == "GERAL" .AND. X[3] == cMoeda .AND. x[4] == cMes})
If nPosTot > 0
   aTotal[nPosTot][5] += nVlVin
Else
   aAdd(aTotal,{"GERAL", "", cMoeda, cMes, nVlVin})
Endif

//Adiciona valor da vinculação ao mes.
If nPos1 > 0
   (cArquivo)->&(FieldName(nPos1)) += nVlVin
Endif

//Total Anual
cMes := "TOTAL_"+Right(Str(Year(dVct)),2)
nPos2:= aScan(aEstru,{|X| X[1]==cMes})

If nPos2 > 0
   (cArquivo)->&(FieldName(nPos2)) += nVlVin
Endif

//Total Geral
If nPos1 > 0
   (cArquivo)->TOT_CONTRA += nVlVin
Endif

Return .T.

********************************
Function CE150Total(cFil,cTpTot)
********************************
Local i
Default cFil   := "GERAL"
Default cTpTot := ""

aSort(aTotal,,,{|X,Y| X[1]+X[2]+X[3]+X[4] < Y[1]+Y[2]+Y[3]+Y[4] })

If Empty(cTpTot)
   nPosFil:= aScan(aTotal,{|X| X[1] == cFil})

   If cFil == "GERAL"
      CE150AddLin(STR0016, , , , , , ,aTotal[nPosFil][3])//"Total Geral:"
   Else
      CE150AddLin(STR0017+AvgFilName({cFil},.T.)[1]+":", , , , , , ,aTotal[nPosFil][3])//"Total Filial "
   Endif

   For i:= nPosFil To Len(aTotal)
      If aTotal[i][1] <> cFil
         EXIT
      Endif
      If i > nPosFil .AND. aTotal[i][3] <> aTotal[i-1][3]
         CE150AddLin(, , , , , , , aTotal[i][3])
      Endif

      If Val(Right(aTotal[i][4],2)) > 0
         //Total Anual
         cMes := "TOTAL_"+Right(aTotal[i][4],2)
         nPos2:= aScan(aEstru,{|X| X[1]==cMes})

         If nPos2 > 0
            (cArquivo)->&(FieldName(nPos2)) += aTotal[i][5]
         Endif

         (cArquivo)->TOT_CONTRA      += aTotal[i][5]
      Endif

      (cArquivo)->&(aTotal[i][4]) += aTotal[i][5]

   Next
Else
   nPosTp:= aScan(aTotal,{|X| X[1] == cFil .AND. X[2] == cTpTot})
   //CE150AddLin("Total " + AllTrim(SX5->X5_DESCRI) + ":", , , , , , , aTotal[nPosTp][3])
   CE150AddLin("Total " + AllTrim(Posicione("EF7", 1, xFilial("EF7") + cTpTot, "EF7_DESCRI")) + ":", , , , , , , aTotal[nPosTp][3])
   For i:= nPosTp To Len(aTotal)
      If aTotal[i][1] <> cFil .AND. aTotal[i][2] <> cTpTot
         EXIT
      Endif
      If i > nPosTp .AND. aTotal[i][3] <> aTotal[i-1][3]
         CE150AddLin(, , , , , , , aTotal[i][3])
      Endif

      If Val(Right(aTotal[i][4],2)) > 0
         //Total Anual
         cMes := "TOTAL_"+Right(aTotal[i][4],2)
         nPos2:= aScan(aEstru,{|X| X[1]==cMes})

         If nPos2 > 0
            (cArquivo)->&(FieldName(nPos2)) += aTotal[i][5]
         Endif
         (cArquivo)->TOT_CONTRA      += aTotal[i][5]
      Endif

      (cArquivo)->&(aTotal[i][4]) := aTotal[i][5]
   Next
Endif

Return .T.

/*
Função      : CE150TReport()
Parametros  : cAlias - nome da tabela
Retorno     :
Objetivos   : Gerar a impressão em TReport dos dados das movimenteções.
              Usar o TRreport para exportação para o excel
Autor       : WFS
Data/Hora   : ago/2016
*/
Static Function CE150TReport(cAlias)
Local oReport

Begin Sequence

   If FindFunction("TRepInUse") .And. TRepInUse(.T.) //Verificar se existe a função e se o parâmetro MV_TREPORT está habilitado

      oReport:= ReportDef(cAlias)
      Processa({||oReport:PrintDialog()}, "Relatório de Compromissos")

   EndIf

End Sequence
Return

/**********************************/
Static Function ReportDef(cAlias)
Local aTabelas:= {cAlias}
Local aOrdem:= {"1"}
Local oReport
Local oSecao1
Local n

Begin Sequence


   //TReport():New(Nome do relatório, Título do Relatório        , Pergunte,  CodBlock, Descrição do relatório)
   oReport:= TReport():New("RelComp", "Relatório de Compromissos", Nil     , {|oReport| ImprimeTReport(oReport, cAlias)}, "Relatório de compromissos - financiamentos de exportação/ importação")


   //Define a orientação da impressão
   oReport:oPage:lPortrait := .F.
   oReport:oPage:lLandscape:= .T.


   //Define o objeto com a seção do relatório
   //TRSection():New(objeto pai     , nome da seção, array com as tabelas, índice udado das tabelas)
   oSecao1:= TRSection():New(oReport, "Secao1"     , aTabelas            , aOrdem)
   oReport:Section("Secao1"):SetHeaderBreak(.F.)


   //Define as colunas da seção
   //TRCell():New(Seção, Campo, Tabela, Título, Picture, Tamanho, lPixel, code-block de impressao)
   For n:= 1 To (cAlias)->(FCount()) - 1 //dbdelete
      TRCell():New(oSecao1, (cAlias)->(FieldName(n))  , cAlias, (cAlias)->(FieldName(n)), /*Picture*/, aEstru[AScan(aEstru, {|x| x[1] == (cAlias)->(FieldName(n))})][3], /*lPixel*/, /*{|| code-block de impressao }*/)
   Next


End Sequence
Return oReport

/****************************************/
Static Function ImprimeTReport(oReport, cAlias)

Begin Sequence

   //Chamada para posicionamento de registro
   //TRPosition():New(oReport:Section(cAlias), cAlias, 1, {|| (cAlias)->(xFilial()) + XXXXX})

   //Régua
   oReport:SetMeter((cAlias)->(EasyRecCount()))

   (cAlias)->(DBGoTop())

   //Início da impressão da seção - cabeçalho
   oReport:Section("Secao1"):Init()

   While (cAlias)->(!EoF()) .And. !oReport:Cancel()
      oReport:Section("Secao1"):PrintLine() //Impressão da linha
      oReport:IncMeter()                    //Incrementa a barra de progresso

      (cAlias)->(DBSkip())
   EndDo

   //Finalização da seção
   oReport:Section("Secao1"):Finish()

End Sequence

Return
