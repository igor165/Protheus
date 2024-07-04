#INCLUDE "ECOCO150.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"
//Compatibilização com a 8.11- 27-06-05 - Alcir Alves
//Programa..: ECOCO150.PRW
//Data......: 04/11/04
//Descricao.: Relatório de Variação Cambial sobre Comissões



/*
Função..: ECOCO150
Data....: 04/11/04
Objetivo: Relatório de Variação Cambial sobre Comissões
*/
*******************
Function ECOCO150()
*******************
Local cPergunte:= "",i:=0
Private cFilECA:= xFilial("ECA")
Private cFilECF:= xFilial("ECF")
Private cFilSA2:= xFilial("SA2")
Private cFilSY5:= xFilial("SY5") //Alcir Alves - 07-06-05
Private cNomArq:= "",aFilSel:={} //Alcir Alves - 27
Private cFilStr:=""
Private nTot   := 0
Private nTot_Moe := {} 
Private nTot_Rea := {}
Private aRel := {}
Private lCancel:= .F.

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

SY5->(DBSETORDER(1)) //Alcir Alves - 07-06-05
//CO150AcDic()//Verifica e Acerta Dicionário

//Do While .T.
aFilSel:=AvgSelectFil(.T.,"ECF") //Alcir Alves - 27/06/05 - conceito multifilial
//aadd(aFilSel,"02")
if aFilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
   cFilStr:=""
   for i:=1 to len(aFilSel)
     cFilStr+=iif(!empty(cFilStr),",","")+"'"+aFilSel[i]+"'"
   next
   IF Pergunte("CO150",.T.)
   cParAgente:= mv_par01
   cParProc  := mv_par02
   dParIni   := mv_par03
   dParFinal := mv_par04
   nTipImp   := mv_par05
   
//   If !E_Periodo_Ok(dParIni,dParFinal) //Ambos estão preenchidos
//      Loop
//   Endif
   
   Processa({|| iIF(lTop, CO150Query("ECA"), CO150Dbf("ECA") ) },STR0001)//"Pesquisando Dados da Prévia..."
   Processa({|| CO150Dados("ECA")},STR0001)//"Pesquisando Dados da Prévia..."
   Processa({|| iIF(lTop, CO150Query("ECF"), CO150Dbf("ECF") ) },STR0002)//"Pesquisando Dados da Efetivação..."
   Processa({|| CO150Dados("ECF")},STR0002)//"Processando dados da Efetivação..."

   If Select("TRB") > 0
      TRB->( dbCloseArea() )
   ENDIF   

   If !lTop
      E_EraseArq(cNomArq)
   Endif

   If Len(aRel) > 0
      If nTipImp == 1
         //Impressão
         CO150Print()
      ElseIf nTipImp == 2
         //Em Arquivo
         RptStatus({|lCancel| CO150DbfImp(.F.)})
      Else
         //Excel
         RptStatus({|lCancel| CO150DbfImp(.T.)})
      Endif
   Else
      Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
   Endif
   aRel := {}
   Endif   
endif
//EndDo             

Return .T.

/*
Função..: CO150Dbf
Autor...: Alessandro Alves Ferreira - AAF
Data....: 09/10/04
Objetivo: Pesquisa os dados para o relatório em base codebase.
*/
*************************
Function CO150Dbf(cAlias)
*************************
Local cFor_n:=cFor_cod := ""
Private cFil := xFilial(cAlias)

If Select("TRB") == 0
   aEstru := { { "FILIAL"  ,AVSX3("ECF_FILIAL"  ,2),AVSX3("ECF_FILIAL"  ,3),AVSX3("ECF_FILIAL"  ,4) },;
               { "FORN"  ,AVSX3("ECF_FORN"  ,2),AVSX3("ECF_FORN"  ,3),AVSX3("ECF_FORN"  ,4) },;
               { "CODFOR"  ,AVSX3("A2_COD"   ,2),AVSX3("A2_COD"   ,3),AVSX3("A2_COD"   ,4) },;
               { "NOME"  ,AVSX3("A2_NOME"   ,2),AVSX3("A2_NOME"   ,3),AVSX3("A2_NOME"   ,4) },;
               { "PREEMB",AVSX3("ECF_PREEMB",2),AVSX3("ECF_PREEMB",3),AVSX3("ECF_PREEMB",4) },;
               { "MOEDA" ,AVSX3("ECF_MOEDA" ,2),AVSX3("ECF_MOEDA" ,3),AVSX3("ECF_MOEDA" ,4) },;
               { "ID_CAM",AVSX3("ECF_ID_CAM",2),AVSX3("ECF_ID_CAM",3),AVSX3("ECF_ID_CAM",4) },;
               { "VL_MOE",AVSX3("ECF_VL_MOE",2),AVSX3("ECF_VL_MOE",3),AVSX3("ECF_VL_MOE",4) },;
               { "VALOR" ,AVSX3("ECF_VALOR" ,2),AVSX3("ECF_VALOR" ,3),AVSX3("ECF_VALOR" ,4) },;
               { "DT_CON",AVSX3("ECF_DTCONT",2),AVSX3("ECF_DTCONT",3),AVSX3("ECF_DTCONT",4) } }

   Private aCampos:= Array(Len(aEstru))

   cNomArq:= E_CriaTrab("",aEstru,"TRB")
   IndRegua("TRB",cNomArq+TEOrdBagExt(),"FORN+PREEMB+ID_CAM")
Endif

(cAlias)->( dbSetOrder(1) )
(cAlias)->( dbSeek(cFil)  )
nCont:=0

cEventos := "120,123,121,124,122,125,"                        +; //Comissões
            "574,575,534,535,576,577,536,537,578,579,538,539,"+; //Variação Cambial
            "612,805,613,806,614,807"                            //Pagamentos e Descontos

If cAlias == "ECA"
   bCond :={|| ECA_FILIAL == cFil .AND. ECA_TPMODU == 'EXPORT' .AND. ECA_ID_CAM $ cEventos }
   bWhile:={|| !ECA->( EoF() ) .AND. ECA->ECA_FILIAL == cFil }
Else
   bCond:= {|| ECF_FILIAL == cFil .AND. ECF_TPMODU == 'EXPORT' .AND. ECF_ID_CAM $ cEventos }
   bWhile:={|| !ECF->( EoF() ) .AND. ECF->ECF_FILIAL == cFil }
Endif

If !lTop
   (cAlias)->( dbSetFilter( bCond,cAlias+"_TPMODU"+" == 'EXPORT' .AND. "+cAlias+"_ID_CAM $ '"+cEventos+"'") )
Endif

//Conta Registros
(cAlias)->( dbEval( {|| nCont++ },,bWhile,,,.T.) )

ProcRegua( nCont )

(cAlias)->( dbSetOrder(1) )
(cAlias)->( dbSeek(cFil) )

If cAlias == "ECA"
   Do While Eval(bWhile)

      If ( !ECA->ECA_ID_CAM $ cEventos  )                         .OR.; //Filtro Por Eventos
         ( !ECA->ECA_TPMODU == 'EXPORT' )                         .OR.; //Filtro Por Modulo de Exportação
         ( !Empty(cParAgente).AND. !ECA->ECA_FORN   == cParAgente ).OR.; //Filtro por Agente
         ( !Empty(cParProc)  .AND. !ECA->ECA_PREEMB == cParProc   ).OR.; //Filtro por Processo
         ( !Empty(dParFinal) .AND. !ECA->ECA_DT_CON <  dParFinal  )      //Filtro por Data Final

         ECA->( dbSkip() )
         IncProc(STR0001) //"Pesquisando Dados da Prévia..."
         Loop
      Endif
      //Alcir Alves - 07-06-05
      cFor_n   := ""
      cFor_cod := ""
      IF SY5->(DBSEEK(cFilSY5+ECA->ECA_FORN))                    
          cFor_n   := Posicione("SA2",1,(cFilSA2+SY5->Y5_FORNECE+SY5->Y5_LOJAF),"A2_NOME")
          cFor_cod := SA2->A2_COD
          if !empty(cParAgente)
             if SA2->A2_COD!=cParAgente
                (cAlias)->(dbSkip())
                loop             
             endif
          endif
      ENDIF
      //
      IF ECA->ECA_FILIAL$cFilStr
         TRB->( dbAppend() )
         TRB->FILIAL := ECA->ECA_FILIAL
         TRB->FORN   := ECA->ECA_FORN
         TRB->NOME   := cFor_n
         TRB->CODFOR:= cFor_cod
         TRB->PREEMB := ECA->ECA_PREEMB
         TRB->MOEDA  := ECA->ECA_MOEDA
         TRB->ID_CAM := ECA->ECA_ID_CAM
         TRB->VL_MOE := ECA->ECA_VL_MOE
         TRB->VALOR  := ECA->ECA_VALOR
         TRB->DT_CON := ECA->ECA_DT_CON
      ENDIF
      nToT++
      (cAlias)->( dbSkip() )
      IncProc(STR0001) //"Pesquisando Dados da Prévia..."
   EndDo
Else
   Do While Eval(bWhile)
      If ( !ECF->ECF_ID_CAM $ cEventos  )                         .OR.; //Filtro Por Eventos
         ( !ECF->ECF_TPMODU == 'EXPORT' )                         .OR.; //Filtro Por Modulo de Exportação
         ( !Empty(cParAgente).AND. !ECF->ECF_FORN   == cParAgente ).OR.; //Filtro por Agente
         ( !Empty(cParProc)  .AND. !ECF->ECF_PREEMB == cParProc   ).OR.; //Filtro por Processo
         ( !Empty(dParFinal) .AND. !ECF->ECF_DTCONT <  dParFinal  )      //Filtro por Data Final

         ECF->( dbSkip() )
         IncProc(STR0002) //"Pesquisando Dados da Efetivação..."
         Loop
      Endif

      //Alcir Alves - 07-06-05
      cFor_n   := ""
      cFor_cod := ""
      //Alcir Alves - 07-06-05
      IF SY5->(DBSEEK(cFilSY5+ECF->ECF_FORN))                    
           cFor_n   := Posicione("SA2",1,(cFilSA2+SY5->Y5_FORNECE+SY5->Y5_LOJAF),"A2_NOME")
           cFor_cod := SA2->A2_COD
           if !empty(cParAgente)
              if SA2->A2_COD!=cParAgente
                 (cAlias)->(dbSkip())
                 loop             
              endif
           endif
      ENDIF
      //
      IF ECF->ECF_FILIAL$cFilStr
         TRB->( dbAppend() )
         TRB->FILIAL := ECF->ECF_FILIAL
         TRB->FORN   := ECF->ECF_FORN
         TRB->NOME   :=cFor_n
         TRB->CODFOR:=cFor_cod
         TRB->PREEMB := ECF->ECF_PREEMB
         TRB->MOEDA  := ECF->ECF_MOEDA
         TRB->ID_CAM := ECF->ECF_ID_CAM
         TRB->VL_MOE := ECF->ECF_VL_MOE
         TRB->VALOR  := ECF->ECF_VALOR
         TRB->DT_CON := ECF->ECF_DTCONT
      ENDIF     
      nToT++
      (cAlias)->( dbSkip() )
      IncProc(STR0002) //"Pesquisando Dados da Efetivação..."
   EndDo
Endif

If !lTop
   //(cAlias)->( dbClearFilter() )
   dbSelectArea(cAlias)
   SET FILTER TO
Endif

Return .T.

/*
Função..: CO150Query
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Executa Query para retorno dos dados de impressão
*/
***************************
Function CO150Query(cAlias)
***************************
Local cDel := iIF( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
Local cQuery
Local cTab := cAlias+"."+cAlias
Local cDtCont := iIF(cAlias == "ECA","ECA.ECA_DT_CON","ECF.ECF_DTCONT")

//            Agente               Nome Agente                Processo                 Moeda
cCampos  :=   cTab+"_FILIAL AS FILIAL,"+cTab+"_FORN AS FORN, "+cTab+"_PREEMB AS PREEMB, "+cTab+"_MOEDA AS MOEDA,SA2.A2_NOME AS NOME,SA2.A2_COD AS CODFOR, "
//            Evento                    Valor Moeda               Valor Reais
cCampos  +=   cTab+"_ID_CAM AS ID_CAM,"+cTab+"_VL_MOE AS VL_MOE,"+cTab+"_VALOR AS VALOR, "
//            Dt. Contabilização
cCampos  +=   cDtCont+" AS DT_CON"
//
cFrom    := RetSqlName(cAlias)+" "+cAlias +", "+RetSqlName("SY5")+" SY5, "+RetSqlName("SA2")+" SA2 " 
//
//cWhere   := cAlias+"."+cDel+" AND "+cTab+"_FILIAL = '"+xFilial(cAlias)+"' "+;
cWhere   := cAlias+"."+cDel+" AND "+cTab+"_FILIAL in("+cFilStr+") "+;
            " AND "+cTab+"_ID_CAM "+;
            " IN('120','123','121','124','122','125',"+;                                     //Comissões
                "'574','575','534','535','576','577','536','537','578','579','538','539',"+; //Variação Cambial
                "'612','805','613','806','614','807')"                                       //Pagamentos e Descontos

cWhere   += " AND "+cTab+"_TPMODU = 'EXPORT' AND "+cTab+"_tp_for='2' AND SY5.Y5_COD="+cTab+"_FORN AND SA2.A2_COD=SY5.Y5_FORNECE AND SA2.A2_LOJA=SY5.Y5_LOJAF "

//Filtro por Agente
If !Empty(cParAgente)
   cWhere += " AND SA2.A2_COD= '"+cParAgente+"'"
Endif
//Filtro por Processo
If !Empty(cParProc)
   cWhere += " AND "+cTab+"_PREEMB = '"+cParProc+"'"
Endif
//Filtro Por periodo - Data Final
If !Empty(dParFinal)
   cWhere += " AND "+cDtCont+" <= '"+DtoS(dParFinal)  +"'"
Endif

cOrder := cTab+"_FILIAL,"+cTab+"_FORN, "+cTab+"_PREEMB ,"+cTab+"_ID_CAM "

cQuery := " SELECT "+cCampos+" FROM "+cFrom+" WHERE "+cWhere+" ORDER BY "+cOrder

cQuery := ChangeQuery( cQuery )

If Select("TRB") > 0
   TRB->( dbCloseArea() )
Endif

TcQuery cQuery ALIAS "TRB" NEW
TcSetField("TRB","DT_CON","D")

nToT   := CO150TotReg( cQuery )

Return .T.

/*
Função..: CO150TotReg
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Retornar o Numero de Registros retornados em uma Query
*/
Function CO150TotReg(cQuery)
Local nTotalReg

If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

cQuery := SubStr(cQuery,1,RAt("ORDER BY",cQuery) - 1)

//Total de Registros
cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP")
TcQuery cQuery ALIAS "TOTALREG" NEW

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

Return nTotalReg

/*
Função..: CO150Dados
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Gera Array com dados de Impressão
*/
Function CO150Dados(cAlias)
Local i:= 0,cFilAtu:="",cLastFil:=""
Local nCom       := 0, nComRs      := 0
Local nComAnt    := 0, nComAntRs   := 0
Local nLiq       := 0, nLiqRs      := 0
Local nLiqAnt    := 0, nLiqAntRs   := 0
Local nDes       := 0, nDesRs      := 0
Local nDesAnt    := 0, nDesAntRs   := 0
Local nVC        := 0, nVCAnt      := 0
Local nSldAnt    := 0, nSldAntRs   := 0
Local nSldAtu    := 0, nSldAtuRs   := 0
Local dDtCon     := CtoD("  /  /  ")
Local aComis := {}

ProcRegua( nToT )


TRB->( dbGoTop() )
Do While ! TRB->( EoF() )
   cAgente     := ALLTRIM(ALLTRIM(TRB->CODFOR)+" - "+TRB->NOME)
   cProc       := TRB->PREEMB
   cMoeda      := TRB->MOEDA
   dDtCon      := iiF(TRB->DT_CON > dDtCon,TRB->DT_CON,dDtCon)
   
   If dDtCon >= dParIni
      //No Periodo
      Do Case
         Case TRB->ID_CAM $ "123/124/125" //Comissões
            nPos := Ascan(aComis,TRB->PREEMB)
            if nPos = 0            
               nCom       += TRB->VL_MOE
               nComRs     += TRB->VALOR
               AADD(aComis,TRB->PREEMB)
            endif   

         Case TRB->ID_CAM $ "574/575/534/535/576/577/536/537/578/579/538/539" //Variação Cambial
            nVc        += TRB->VALOR
            
         Case TRB->ID_CAM $ "612/613/614" //Pagamentos
            nLiq       += TRB->VL_MOE
            nLiqRs     += TRB->VALOR
            
         Case TRB->ID_CAM $ "805/806/807" //Descontos
            nDes       += TRB->VL_MOE
            nDesRs     += TRB->VALOR
      End Case
   Else
      //Anterior ao Periodo
      Do Case
         Case TRB->ID_CAM $ "123/124/125" //Comissões
            nPos := Ascan(aComis,TRB->PREEMB)
            if nPos = 0                           
               nComAnt    += TRB->VL_MOE
               nComAntRs  += TRB->VALOR
            endif   

         Case TRB->ID_CAM $ "574/575/534/535/576/577/536/537/578/579/538/539" //Variação Cambial
            nVcAnt     += TRB->VALOR

         Case TRB->ID_CAM $ "612/613/614" //Pagamentos
            nLiqAnt    += TRB->VL_MOE
            nLiqAntRs  += TRB->VALOR
            
         Case TRB->ID_CAM $ "805/806/807" //Descontos
            nDesAnt    += TRB->VL_MOE
            nDesAntRs  += TRB->VALOR
      End Case
   Endif
   cLastFil:=TRB->FILIAL
   cLastProc:= TRB->FILIAL+TRB->PREEMB
   IncProc("Processando...")
   TRB->( dbSkip() )

   If (TRB->FILIAL+TRB->PREEMB) <> cLastProc 
      //Saldo Anterior (Vl. Comissões - Liquidações - Descontos)
      nSldAnt   := nComAnt   - nLiqAnt   - nDesAnt
      nSldAntRs := nComAntRs - nLiqAntRs - nDesAntRs + nVcAnt
      
      //Saldo Atual (Saldo Anterior - Liquidações - Descontos)
      nSldAtu   := nSldAnt   + nCom   - nLiq   - nDes
      nSldAtuRs := nSldAntRs + nComRs - nLiqRs - nDesRs + nVc
      begin sequence
      if nSldAnt==0 .and. nSldAntRs==0 .and. nSldAtu==0 .and. nSldAtuRs==0 .and. nCom==0 .and. nComRs==0 .and. nLiq==0 .and. nLiqRs==0
         break
      endif
      aDados := { cAgente, cProc, cMoeda, nSldAnt, nSldAntRs, nCom, nComRs, nVc, nLiq, nLiqRs, nSldAtu, nSldAtuRs, dDtCon,cLastFil}
      nPos := aScan(aRel,{|x| x[14]+x[1]+x[2] == TRB->FILIAL+cAgente+cProc })
      If nPos > 0
         For i:= 1 To Len(aDados)
            If ValType(aRel[nPos][i]) == "N"
               aRel[nPos][i] += aDados[i]
            Else
               aRel[nPos][i] := aDados[i]
            Endif
         Next
      Else
         aAdd(aRel,aDados)
      Endif
      end sequence
      nCom       := 0
      nComRs     := 0
      nComAnt    := 0
      nComAntRs  := 0
      nLiqAnt    := 0
      nLiq       := 0 // MJA 11/10/05
      nLiqRs     := 0 // MJA 11/10/05 
      nLiqAntRs  := 0
      nDesAnt    := 0
      nDesAntRs  := 0
      nVC        := 0
      nVCAnt     := 0
      nSldAnt    := 0
      nSldAntRs  := 0
      nSldAtu    := 0
      nSldAtuRs  := 0
      dDtCon     := CtoD("  /  /  ")
   Endif
EndDo


Return .T.
          
/*
Função..: CO150Print
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Prepara Impressão SetPrint
*/
*********************
Function CO150Print()
*********************
Local cDesc1         := STR0003//"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0004//"de Variação Cambial sobre Comissões "
Local cDesc3         := "", cPict := "", imprime := .T.
Private titulo       := STR0005//"Variação Cambial sobre Comissões"
Private nPagina      := 0
Private nLin         := 99
Private cString      := "ECA"
Private lAbortPrint  := .F., limite := 220, tamanho := "G"
Private nomeprog     := "ECOCO150"
Private aReturn      := {STR0006, 1,STR0007, 1, 1, 1, "", 1}//"Zebrado"###"Administracao"
Private nLastKey     := 0
Private wnrel        := "ECOCO150"

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lCancel| CO150Impr()})

Return .T.

/*
Função..: CO150Impr
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Imprimir o Relatório de ACC/ACE
*/
********************
Function CO150Impr()
********************
Local i
Local cFilAtu:=""
Private cPictVl := AVSX3("ECF_VL_MOE",6)
Private nTamPic := Len(Transform( 1, cPictVl))
Private aColuna := {}

cPictProc := AVSX3("ECF_PREEMB",6)
cPictAgen := AVSX3("A2_COD",6)
cPictMoe  := AVSX3("ECF_MOEDA" ,6)

SetRegua(Len(aRel))

Private nColIni  := 000 //Coluna Inicial
Private nEspaco  := 001 //Espaço entre os campos
Private nRemPict := 002 //Quantos caracteres a remover da Picture
   
cPictVl := "@E "+SubStr(cPictVl,4+nRemPict)//@E 999,999,999.99
nTamPic:= Len(Transform( 1, cPictVl))

//             Cabeçalho          Cabeçalho2 Tamanho da Coluna         Texto                  Picture
aColuna := { { STR0008 ,""      ,AVSX3("A2_COD",3)+20  ,{|x| aRel[x][ 1] }, ""        },;//"Agente"
             { STR0009 ,""      ,AVSX3("ECF_PREEMB",3) ,{|x| aRel[x][ 2] }, cPictProc },;//"Processo"
             { STR0010 ,""      ,AVSX3("ECF_MOEDA" ,3) ,{|x| aRel[x][ 3] }, cPictMoe  },;//"Moeda"
             { STR0011 ,STR0010 ,nTamPic               ,{|x| aRel[x][ 4] }, cPictVl   },;//"Saldo Anterior"###"Moeda"
             { ""      ,STR0017 ,nTamPic               ,{|x| aRel[x][ 5] }, cPictVl   },;//"Em Reais"
             { STR0012 ,STR0010 ,nTamPic               ,{|x| aRel[x][ 6] }, cPictVl   },;//"Comissões"###"Moeda"
             { ""      ,STR0017 ,nTamPic               ,{|x| aRel[x][ 7] }, cPictVl   },;//"Em Reais"
             { STR0013 ,STR0017 ,nTamPic               ,{|x| aRel[x][ 8] }, cPictVl   },;//"Variação Cambial"###"Em Reais"
             { STR0014 ,STR0010 ,nTamPic               ,{|x| aRel[x][ 9] }, cPictVl   },;//"Liquidações"###"Moeda"
             { ""      ,STR0017 ,nTamPic               ,{|x| aRel[x][10] }, cPictVl   },;//"Em Reais"
             { STR0015 ,STR0010 ,nTamPic               ,{|x| aRel[x][11] }, cPictVl   },;//"Saldo Atual"###"Moeda"
             { ""      ,STR0017 ,nTamPic               ,{|x| aRel[x][12] }, cPictVl   },;//"Em Reais"
             { STR0016 ,""      ,AVSX3("ECF_DTCONT",3) ,{|x| aRel[x][13] }, ""        } }//"Dt. Contabil."

Begin Sequence

   For i:= 1 To Len(aRel)
      If lCancel
         BREAK
      Endif

      If nLin > 56
         //Imprime cabeçalho
         CO150RlCab()
         nLin := 8
      Endif
      
      if cFilAtu<>aRel[i][14]
          nLin++
          @nLin,0 PSAY replicate("*",220)
          nLin++
          cFilAtu:=aRel[i][14]
          @ nLin,02 PSAY "Filial"+" "+cFilAtu+" - "+AvgFilName({cFilAtu})[1]
          nLin++
          @nLin,0 PSAY replicate("*",220)
          nLin++  
	   endif

      //Imprime Linha
      CO150ImpLin(i)
      
      //Alcir Alves - 06-10-05 - totais por moeda e reais
      npos:=ASCAN(nTot_Moe,{|a| a[1]==aRel[i][3]}) 
      if npos==0
         //               moeda      sld.ant.moe  comiss.moe    liq.moe        sld.atu
         aadd(nTot_Moe, {aRel[i][3], aRel[i][ 4], aRel[i][ 6] , aRel[i][ 9], aRel[i][11]} )
      else
        nTot_Moe[npos,2]+=aRel[i][4]
        nTot_Moe[npos,3]+=aRel[i][6]
        nTot_Moe[npos,4]+=aRel[i][9]
        nTot_Moe[npos,5]+=aRel[i][11]
      endif
      
      If Len(nTot_Rea) == 0
         aAdd(nTot_Rea,aRel[i][5] )
         aAdd(nTot_Rea,aRel[i][7] )
         aAdd(nTot_Rea,aRel[i][10] )
         aAdd(nTot_Rea,aRel[i][12])
         aAdd(nTot_Rea,aRel[i][8] )
         lInicio := .F.
      Else
         nTot_Rea[1]+=aRel[i][ 5] 
         nTot_Rea[2]+=aRel[i][ 7]
         nTot_Rea[3]+=aRel[i][10]
         nTot_Rea[4]+=aRel[i][12]
         nTot_Rea[5]+=aRel[i][8]
      EndIf
      //
            
      nLin++

      IncRegua()
   Next
   
   //Alcir Alves - Totais gerais - 06-10-05
  If nLin > 56
         //Imprime cabeçalho
         CO150RlCab()
         nLin := 8
   Endif
   nLin++
   @ nLin,0 psay replicate("-",220)
   nLin++
   @ nLin,1 psay "Totais Geral"
   nLin++
   @ nLin,0 psay replicate("-",220)
   nLin++
   If nLin > 56
         //Imprime cabeçalho
         CO150RlCab()
         nLin := 8
   Endif
   @ nLin,5 psay "R$"+space(48)+transform(nTot_Rea[1],AVSX3("ECF_VL_MOE",6))+space(33)+transform(nTot_Rea[2],AVSX3("ECF_VL_MOE",6))+;
     transform(nTot_Rea[5],AVSX3("ECF_VL_MOE",6))+space(16)+transform(nTot_Rea[3],AVSX3("ECF_VL_MOE",6))+space(16)+transform(nTot_Rea[4],AVSX3("ECF_VL_MOE",6))
   nLin++   
   for i:=1 to len(nTot_Moe)
      If nLin > 56
         //Imprime cabeçalho
         CO150RlCab()
         nLin := 8
      Endif
      @ nLin,5 psay nTot_Moe[i,1]+space(47)+transform(nTot_Moe[i,2],AVSX3("ECF_VL_MOE",6))+space(16)+transform(nTot_Moe[i,3],AVSX3("ECF_VL_MOE",6))+;
        space(33)+transform(nTot_Moe[i,4],AVSX3("ECF_VL_MOE",6))+space(16)+transform(nTot_Moe[i,5],AVSX3("ECF_VL_MOE",6))
      nLin++   
   next
   @ nLin,0 psay replicate("-",220)   
   //   

   
   Set Printer To
   OurSpool(wnrel)

End Sequence

MS_FLUSH()

Return .T.       

/*
Função..: CO150ImpLin
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Imprimir uma Linha no Relatório de acordo com o aColuna
*/
Function CO150ImpLin(nLinha)
Local i:= 0
nColuna := nColIni
For i:= 1 To Len(aColuna)
   If aColuna[i][4] <> NIL
      cSay:= ""

      //Imprimi o Texto -Texto                       Picture
      cSay := Transform( Eval(aColuna[i][4],nLinha), aColuna[i][5] )
      
      //Soma a Diferença entre o tamanho da coluna e tamanho do texto
      //Em caso de campo numérico. Para Imprimir alinhado a direita
      If ValType(Eval(aColuna[i][4],nLinha)) $ "N"
         nColuna += CO150TamCol(i,"Cabeçalho") - aColuna[i][3]
      Endif

      If Len(cSay) > 0
         @ nLin,nColuna PSay Left(cSay,CO150TamCol(i,"Cabeçalho"))
      Endif

      //Soma a Diferença entre o tamanho da coluna e tamanho do texto
      //Em caso de campo caracter. Para acertar a diferença para a proxima coluna.
      If ValType(Eval(aColuna[i][4],nLinha)) $ "C"
         nColuna += CO150TamCol(i,"Cabeçalho") - aColuna[i][3]
      Endif

      //Soma o Espaco Impresso nessa coluna
      nColuna += aColuna[i][3] + nEspaco
   Endif
Next

Return .T.

/*
Função..: CO150RlCab
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Imprimir o Cabeçalho do Relatório
*/
***************************
Function CO150RlCab()
***************************
Local i:= 0
nPagina ++
cTitPag := STR0018 + StrZero(nPagina,4,0)//"Pagina "
@ 00, 00 PSay __PrtFatline()
@ 01, 00 PSay STR0019+DtoC(Date())+" - "+Time()//"Emissão: " Data e Hora
@ 01, ( 220 / 2 ) - ( Len(titulo) / 2 ) PSay titulo
@ 01, 220 - Len(cTitPag) PSay cTitPag
@ 02, 00 PSay __PrtFatline()

@ 03, 00 PSay STR0020+DtoC(dParIni)+STR0021+DtoC(dParFinal)//"Periodo de "###" até "

//Cabeçalho
//Primeira Linha
//-----------------------------------------------------------------------------------
nColuna := nColIni
For i:= 1 to Len(aColuna)
   If aColuna[i][1] <> NIL
      nTamCol := CO150TamCol(i,"Cabeçalho")

      nColFim := nColuna+nTamCol
      If i < Len(aColuna) .AND. aColuna[i+1][1] == NIL
         //Pega o Tamanho da Proxima Coluna caso ela não tenha Titulo de cabeçalho
         nColFim += nEspaco+CO150TamCol(i+1)
      Endif

      CO150ImpCen(05,nColuna,nColFim,aColuna[i][1])
      nColuna := nColFim+nEspaco
   Endif
Next
//-----------------------------------------------------------------------------------
//Segunda Linha
nColuna := nColIni
For i:= 1 to Len(aColuna)
   If aColuna[i][2] <> NIL
      nColFim := nColuna+CO150TamCol(i,"Cabeçalho2")

      If aColuna[i][1] <> NIL
         nColFim += CO150TamCol(i,"Cabeçalho") - aColuna[i][3]
      Endif
      If i < Len(aColuna) .AND. aColuna[i+1][2] == NIL
         nColFim += nEspaco+CO150TamCol(i+1,"Cabeçalho2")
      Endif

      CO150ImpCen(06,nColuna,nColFim,aColuna[i][2])

      nColuna := nColFim + nEspaco
   Endif
Next

//-----------------------------------------------------------------------------------
@ 07, 00 PSay __PrtThinLine()

Return .T.

/*
Função..: CO150TamCol
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Retornar o Tamanho da Coluna
*/
***********************************
Function CO150TamCol(nCol,cCab)
***********************************
Local nRet   := aColuna[nCol][3]
Local cTexto := iIF(cCab == "Cabeçalho2",aColuna[nCol][2],aColuna[nCol][1])

If cTexto <> NIL .AND. Len(cTexto) > aColuna[nCol][3]
   If nCol < Len(aColuna) .AND. aColuna[nCol+1][1] == NIL
      //No caso da proxima coluna ser nil, calcula o espaco da outra coluna para junção
      //das colunas.
      If Len(cTexto) > aColuna[nCol][3]+aColuna[nCol+1][3]
         nRet:= Len(cTexto)
      Endif
   Else
      nRet:= Len(cTexto)
   Endif
Endif

Return nRet

/*
Função..: CO150ImpCen
Autor...: Alessandro Alves Ferreira - AAF
Data....: 08/11/04
Objetivo: Imprimir texto centralizado entre duas colunas
*/
Function CO150ImpCen(nLinha,nColIni,nColFim,cTexto)
Local nCol

If ValType(cTexto) <> "C"
   cTexto := ""
Endif

If Len(cTexto) >= nColFim - nColIni
   nCol := nColIni
Else
   nCol := Round( ( nColIni + nColFim) / 2 ,0) - Round( Len(cTexto) / 2 ,0 ) //Posicão Para Imprimir no Centro entre as duas colunas
Endif

cSay := Replicate(" ", nCol - nColIni)
If Len(cSay) > 0
   @ nLinha, nColIni PSay cSay          //Imprimi traços antes do Texto
Endif

@ nLinha, nCol PSay cTexto  //Imprimi o Texto

If Len(cSay) > 0
   cSay := Replicate(" ", nColFim - (nCol+Len(cTexto)))
   @ nLinha, nCol+Len(cTexto) PSay cSay //Imprimi traços depois do Texto
Endif

Return .T.

/*
Função..: CO150DBFImp
Autor...: Alessandro Alves Ferreira - AAF
Data....: 08/11/04
Objetivo: Gera work com o relatório para exportar ao Excel
          ou salvar arquivo DBF/TXT
*/
****************************
Function CO150DbfImp(lExcel)
****************************
Local i:= 0
Local i2:= 0
Local cArquivo := CriaTrab(,.F.)
Local oExcelApp
cDirDocs := MsDocPath()
cPath	:= AllTrim(GetTempPath())

aColuna := { { "AGENTE"    ,AVSX3("A2_COD", 02), AVSX3("A2_COD", 03), AVSX3("A2_COD", 04),{|x| aRel[x][ 1] } },;
             { "PROCESSO"  ,AVSX3("ECF_PREEMB"  , 02), AVSX3("ECF_PREEMB"  , 03), AVSX3("ECF_PREEMB"  , 04),{|x| aRel[x][ 2] } },;
             { "MOEDA"     ,AVSX3("ECF_MOEDA" , 02), AVSX3("ECF_MOEDA" , 03), AVSX3("ECF_MOEDA" , 04),{|x| aRel[x][ 3] } },;
             { "SLD_ANTE"  ,AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][ 4] } },;
             { "SLD_ANTERS",AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][ 5] } },;
             { "COMISSAO"  ,AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][ 6] } },;
             { "COMISSAORS",AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][ 7] } },;
             { "VAR_CAMBIA",AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][ 8] } },;
             { "LIQUIDAD"  ,AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][ 9] } },;
             { "LIQUIDADRS",AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][10] } },;
             { "SLD_ATU"   ,AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][11] } },;
             { "SLD_ATU_RS",AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04),{|x| aRel[x][12] } },;
             { "ULT_CONTAB",AVSX3("ECA_DT_CON", 02), AVSX3("ECA_DT_CON", 03), AVSX3("ECA_DT_CON", 04),{|x| aRel[x][13] } },;
             { "FILIAL"    ,AVSX3("ECF_FILIAL", 02), AVSX3("ECF_FILIAL", 03), AVSX3("ECF_FILIAL", 04),{|x| aRel[x][14] } } }

//Monta Estrutura
aEstru:= {}
For i:= 1 To Len(aColuna)
   aAdd(aEstru,{ aColuna[i][1], aColuna[i][2], aColuna[i][3], aColuna[i][4] } )
Next

cDirDocs := E_CriaTrab(, aEstru, cArquivo)
SetRegua(Len(aRel))

Begin Sequence

   For i := 1 To Len(aRel)
   
      If lCancel
         (cArquivo)->( dbCloseArea() )
         E_EraseArq(cArquivo)
         BREAK
      Endif
   
      (cArquivo)->( dbAppend() )
      For i2:= 1 To Len(aColuna)
         (cArquivo)->( FieldPut(i2, Eval(aColuna[i2][5],i) ) )
      Next
      IncRegua()

   Next

   if lExcel
      (cArquivo)->( dbCloseArea() )
      CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )

      //Envia ao Excel
      If ! ApOleClient( 'MsExcel' )
         MsgStop(STR0022) //"MsExcel não instalado."
         RETURN .F.
      Else
         //Abre Dbf no Excel
         oExcelApp:= MsExcel():New()
         oExcelApp:WorkBooks:Open( cPath+cArquivo+".dbf" )
         oExcelApp:SetVisible(.T.)
      EndIf
   Else
      //Abre para criacao do arquivo TXT/DBF
      TR350ARQUIVO(cArquivo)
      (cArquivo)->( dbCloseArea() )
   EndIf
End Sequence

Return .T.

/*
Função..: CO150AcDic
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Acertar o Dicionário SX1 caso não exista o Pergunte
*/
/*
*************************
Function CO150AcDic()
*************************

If !SX1->( dbSeek("CO150"+Space(5)+"01") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "CO150 "
   SX1->X1_ORDEM   := "01"
   SX1->X1_VARIAVL := "mv_ch1"
   SX1->X1_VAR01   := "mv_par01"
   SX1->X1_PERGUNT := "Agente ?"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := AVSX3("A2_COD",3)
   SX1->X1_GSC     := "G"
   SX1->X1_F3      := "SA2"
   SX1->X1_VALID   := "Vazio() .OR. ExistCpo('SA2',mv_par01)"
   SX1->( MsUnLock() )
Else
   RecLock("SX1",.F.)                                        
   SX1->X1_TAMANHO := AVSX3("A2_COD",3)
   SX1->X1_VALID   := "Vazio() .OR. ExistCpo('SA2',mv_par01)"
   SX1->( MsUnLock() )
EndIf

If !SX1->( dbSeek("CO150"+Space(5)+"02") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "CO150 "
   SX1->X1_ORDEM   := "02"
   SX1->X1_VARIAVL := "mv_ch2"
   SX1->X1_VAR01   := "mv_par02"
   SX1->X1_PERGUNT := "Processo ?"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := AVSX3("ECA_PREEMB",3)
   SX1->X1_GSC     := "G"
   SX1->X1_F3      := "EEC"
   SX1->X1_VALID   := "Vazio() .OR. ExistCpo('EEC',mv_par02)"
   SX1->( MsUnLock() )
EndIf

If !SX1->( dbSeek("CO150"+Space(5)+"03") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "CO150 "
   SX1->X1_ORDEM   := "03"
   SX1->X1_VARIAVL := "mv_ch3"
   SX1->X1_VAR01   := "mv_par03"
   SX1->X1_PERGUNT := "Data Inicial ?"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO :=  8
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "Vazio() .OR. E_Periodo_Ok(mv_par03,mv_par04)"
   SX1->( MsUnLock() )
EndIf

If !SX1->( dbSeek("CO150"+Space(5)+"04") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "CO150 "
   SX1->X1_ORDEM   := "04"
   SX1->X1_VARIAVL := "mv_ch4"
   SX1->X1_VAR01   := "mv_par04"
   SX1->X1_PERGUNT := "Data Final ?"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO :=  8
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "Vazio() .OR. E_Periodo_Ok(mv_par03,mv_par04)"
   SX1->( MsUnLock() )
EndIf

If !SX1->( dbSeek("CO150"+Space(5)+"05") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "CO150 "
   SX1->X1_ORDEM   := "05"
   SX1->X1_VARIAVL := "mv_ch5"
   SX1->X1_VAR01   := "mv_par05"
   SX1->X1_PERGUNT := "Tipo de relatório ?"
   SX1->X1_TIPO    := "N"
   SX1->X1_TAMANHO := 1
   SX1->X1_GSC     := "C"
   SX1->X1_DEF01   := "Impressão"
   SX1->X1_DEF02   := "em Arquivo"
   SX1->X1_DEF03   := "no MsExcel"
   SX1->(msUnlock() )
Endif

Return .T.
*/