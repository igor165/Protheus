#INCLUDE "ECOPC150.CH"
//Compatibilização com a 8.11- 28-06-05 - Alcir Alves
//Revisão - 12-05-05 - Alcir Alves
//Autor.....: Alessandro Alves Ferreira
//Programa..: ECOPC150.PRW
//Data......: 18/11/04
//Descricao.: Relatório contabil para PIS e COFINS


#INCLUDE "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"

/*
Função..: ECOPC150
Autor...: Alessandro Alves Ferreira - AAF
Data....: 18/11/04
Objetivo: Relatório contabil para PIS e COFINS
*/
*******************
Function ECOPC150()
*******************
Local i
Private AfilSel:={},cFilStr:=""
Private cFilECA  := xFilial("ECA")
Private cFilECF  := xFilial("ECF")
Private cFilEC6  := xFilial("EC6")
Private cFilEEC  := xFilial("EEC")
Private cFilEEM  := xFilial("EEM")
Private cNomArq  := ""
Private nTot     := 0
Private aDadosRel:= {}
Private aRel     := {}
Private lCancel  := .F.
Private cFilter
Private cOldArea := Alias()
Private cParCliente, cParProc, cParNF, dParIni, dParFinal, nParDtFil, lAnalit, nTipImp

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

//PC150AcDic()//Verifica e Acerta Dicionário

aFilSel:=AvgSelectFil(.T.,"ECF") //Alcir Alves - 27/06/05 - conceito multifilial
//aadd(aFilSel,"02")
if aFilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
Do While .T.
   IF ! Pergunte("PC150",.T.)
      Exit
   Endif
   cFilStr:=""
   for i:=1 to len(aFilSel)
     cFilStr+=iif(!empty(cFilStr),",","")+"'"+aFilSel[i]+"'"
   next

   cParCliente:= mv_par01
   cParProc   := mv_par02
   cParNF     := mv_par03
   dParIni    := mv_par04
   dParFinal  := mv_par05
   nParDtFil  := mv_par06
   lAnalit    := mv_par07 == 2 .AND. mv_par08 == 1
   nTipImp    := mv_par08
   
   If !E_Periodo_Ok(dParIni,dParFinal) //Ambos estão preenchidos
      Loop
   Endif
   
   If lTop
      Processa({|| PC150Query("ECA") ,PC150Dados()},STR0001)//"Pesquisando Dados da Prévia..."
      Processa({|| PC150Query("ECF") ,PC150Dados()},STR0002)//"Pesquisando Dados da Efetivação..."
      TRB->( dbCloseArea() )
   Else
      Processa({|| PC150Filter("ECA",.T.),iIF(nTot > 0,PC150Dados("ECA"),.F.)},STR0001)//"Pesquisando Dados da Prévia..."
      dbSelectArea("ECA")
      SET FILTER TO
      Processa({|| PC150Filter("ECF"),iIF(nTot > 0,PC150Dados("ECF"),.F.)},STR0002)//"Pesquisando Dados da Efetivação..."
      dbSelectArea("ECF")
      SET FILTER TO
   Endif
   
   Processa({|| PC150aRel()},STR0003)//"Processando Dados Encontrados..."
   
   If Len(aRel) > 0
      //Ordena o Relatório por
      MsAguarde({|| aRel := aSort( aRel,,,{|x,y| x[16]+x[1] + x[3] + x[4] < y[16]+y[1] + y[3] + y[4]} ) },STR0004)//"Ordenando Relatório..."
      
      If nTipImp == 1
         //Impressão
         PC150Print()
      ElseIf nTipImp == 2
         //Em Arquivo
         RptStatus({|lCancel| PC150DbfImp(.F.)})
      Else
         //Excel
         RptStatus({|lCancel| PC150DbfImp(.T.)})
      Endif
   Else
      Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
   Endif
   aRel := {}

EndDo
ENDIF
dbSelectArea(cOldArea)

Return .T.

/*
Função..: PC150Filter
Autor...: Alessandro Alves Ferreira - AAF
Data....: 18/11/04
Objetivo: Filtra a tabela para os dados do relatório
*/
*************************
Function PC150Filter(cAlias,lECADT)
*************************
Local nCont    := 0
Default cAlias := "TRB"
Default lECADT := .F.
cFil     := xFilial(cAlias)

cEventos := "101,107,112,116,582,583,584,585,586,587,580,581,607,801,802"
cFilter  := cAlias+"_FILIAL == in ("+cFilStr+") .AND. "+cAlias+"_TPMODU == 'EXPORT' .AND. "+cAlias+"_ID_CAM $ '"+cEventos+"' "

If !Empty(cParCliente)
   cFilter+= ".AND. Posicione('EEC',1,cFilEEC+"+cAlias+"_PREEMB"+",'EEC_IMPORT') == '"+cParCliente+"' "
Endif
If !Empty(cParProc)
   cFilter+= ".AND. "+cAlias+"_PREEMB == '"+cParProc+"' "
Endif

//Recebimento
If nParDtFil == 2
   If !Empty(dParIni)
      If lECADT
         cFilter+= ".AND. "+cAlias+"_DT_CON >= CtoD('"+DtoC(dParIni)+"') "
      Else
         cFilter+= ".AND. "+cAlias+"_DTCONT >= CtoD('"+DtoC(dParIni)+"') "
      Endif
   Endif
   If !Empty(dParFinal)
      If lECADT
         cFilter+= ".AND. "+cAlias+"_DT_CON <= CtoD('"+DtoC(dParFinal)+"') "
      Else
         cFilter+= ".AND. "+cAlias+"_DTCONT <= CtoD('"+DtoC(dParFinal)+"') "
      Endif
   Endif
Endif

cFilter := cAlias+"->( "+cFilter+" )"
(cAlias)->( dbSetFilter( {|| &cFilter},cFilter) )

(cAlias)->( dbSetOrder(1) )
(cAlias)->( dbSeek(cFil)  )
nCont:=0

//Conta Registros
(cAlias)->( dbEval( {|| nCont++ },,{|| !(cAlias)->( EoF() )},,,.T.) )

nToT := nCont

(cAlias)->( dbSetOrder(1) )
(cAlias)->( dbSeek(cFil)  )

Return .T.

//Alcir Alves - revisão - gerar consulta apenas com processos com no minimo uma invoice liquidada - 13-05-05
/*
Função..: PC150Query
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Executa Query para retorno dos dados de impressão
*/
***************************
Function PC150Query(cAlias)
***************************
Local cDel := iIF( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
Local cQuery
Local cTab := cAlias+"."+cAlias
Local cDtCont := iIF(cAlias == "ECA","ECA.ECA_DT_CON","ECF.ECF_DTCONT")

//            Cliente                            Processo                Nota Fiscal
cCampos  :=   "EEC.EEC_IMPORT, EEC.EEC_IMPODE,"+cTab+"_FILIAL AS ECF_FILIAL,"+cTab+"_PREEMB AS ECF_PREEMB,"+cTab+"_NRNF AS ECF_NRNF, "
//            Data                       Valor da Nota
cCampos  +=   cDtCont+" AS ECF_DTCONT, "+cTab+"_VALOR AS ECF_VALOR, "+cTab+"_VL_MOE AS ECF_VL_MOE, "+cTab+"_MOEDA AS ECF_MOEDA, "
//            Taxa
cCampos  +=   +iIF(cAlias=="ECA","ECA.ECA_TX_USD","ECF.ECF_PARIDA")+" AS ECF_PARIDA, " 
//            Evento
cCampos  +=   cTab+"_ID_CAM AS ECF_ID_CAM "
//
cFrom    := RetSqlName(cAlias)+" "+cAlias+", "+RetSqlName("EEC")+" EEC "
//
cWhere   := cAlias+"."+cDel+" AND EEC."+cDel+" AND "+cTab+"_FILIAL IN ("+cFilStr+") AND EEC.EEC_FILIAL IN ("+cFilStr+") "
//
cWhere   += " AND EEC.EEC_PREEMB = "+cTab+"_PREEMB AND "+cTab+"_TPMODU = 'EXPORT' AND "+cTab+"_ID_CAM IN('101','107','112','116','582','583','584','585','586','587','580','581','607','801','802')"
//
//Filtro por Cliente
If !Empty(cParCliente)
   cWhere += " AND EEC.EEC_IMPORT = '"+cParCliente+"'"
Endif
//Filtro por Processo
If !Empty(cParProc)
   cWhere += " AND "+cTab+"_PREEMB = '"+cParProc+"'"
Endif

//Por Recebimento
If nParDtFil == 2
   //Filtro Por periodo
   If !Empty(dParIni)
      cWhere += " AND "+cDtCont+" >= '"+DtoS(dParIni)  +"'"
   Endif
   If !Empty(dParFinal)
      cWhere += " AND "+cDtCont+" <= '"+DtoS(dParFinal)  +"'"
   Endif
Endif

cOrder := "EEC_IMPORT ,"+cTab+"_PREEMB ,"+cTab+"_NRNF, "+cTab+"_ID_CAM "

cQuery := " SELECT "+cCampos+" FROM "+cFrom+" WHERE "+cWhere+" ORDER BY "+cOrder

cQuery := ChangeQuery( cQuery )

If Select("TRB") > 0
   TRB->( dbCloseArea() )
Endif

TcQuery cQuery ALIAS "TRB" NEW
TcSetField("TRB","ECF_DTCONT","D")

nToT   :=  PC150TotReg( cQuery )

Return .T.

/*
Função..: PC150TotReg
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Retornar o Numero de Registros retornados em uma Query
*/
Function PC150TotReg(cQuery)
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
Função..: PC150Dados
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Gera Array com dados de Impressão
*/
Function PC150Dados(cTab)
Default cTab := "TRB"

dbSelectArea(cTab)
ProcRegua( nToT )
(cTab)->( dbGoTop() )

If cTab == "TRB"
   Do While ! EoF()
      aAdd(aDadosRel, { ECF_ID_CAM,;//[ 1] Evento
                        ECF_PREEMB,;//[ 2] Embarque
                        ECF_NRNF  ,;//[ 3] Nota Fiscal
                        ECF_DTCONT,;//[ 4] Data Emissão
                        ECF_MOEDA ,;//[ 5] Moeda
                        ECF_VL_MOE *ECF_PARIDA ,;//[ 6] Valor
                        ECF_VL_MOE,;//[ 7] Valor na Moeda
                        ECF_PARIDA,;//[ 8] Taxa
                        EEC_IMPORT,;//[ 9] Cliente
                        EEC_IMPODE,;//[10] Descrição
                        ECF_FILIAL})

      IncProc(STR0005)//"Processando..."
      dbSkip()
   EndDo
ElseIf cTab == "ECF"
   Do While ! EoF()
      aAdd(aDadosRel, { ECF_ID_CAM,;//[ 1] Evento
                        ECF_PREEMB,;//[ 2] Embarque
                        ECF_NRNF  ,;//[ 3] Nota Fiscal
                        ECF_DTCONT,;//[ 4] Data Emissão
                        ECF_MOEDA ,;//[ 5] Moeda
                        ECF_VL_MOE *ECF_PARIDA ,;//[ 6] Valor
                        ECF_VL_MOE,; //[ 7] Valor na Moeda
                        ECF_PARIDA,; //[ 8] Taxa
                        "",;
                        "",;
                        ECF_FILIAL})

      IncProc(STR0005)//"Processando..."
      dbSkip()
   EndDo
Else
   Do While ! EoF()
      aAdd(aDadosRel, { ECA_ID_CAM,;//[1] Evento
                        ECA_PREEMB,;//[2] Embarque
                        ECA_NRNF  ,;//[3] Nota Fiscal
                        ECA_DT_CON,;//[4] Data Emissão
                        ECA_MOEDA ,;//[5] Moeda
                        ECA_VL_MOE*ECA_TX_USD,;  //ECA_VALOR ,;//[6] Valor da Nota
                        ECA_VL_MOE,;//[7] Valor da Nota na Moeda
                        ECA_TX_USD,;//[8] Taxa
                        "",;
                        "",;
                        ECA_FILIAL })

      IncProc(STR0005)//"Processando..."
      dbSkip()
   EndDo   
Endif

Return .T.

/*
Função..: PC150aRel
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Gera Array com dados de Impressão
*/
Function PC150aRel()
Local Ntot_nf_r:=0
Local Ntot_nf:=0
Local Vl_recbR:=Vl_recb:=0
Local i:=0
Local i2:=0
Local i3:=0
ProcRegua( Len(aDadosRel) )
Private aLiq       := {}
Private aNFs       := {}
Private nToTNF     := 0
Private nToTNFRs   := 0
Private nProcVC    := 0
Private nLiq       := 0
Private nLiqRs     := 0
Private nDescPro   := 0
Private nDescProRs := 0

ProcRegua( Len(aDadosRel) )
MsAguarde({|| aDadosRel := aSort( aDadosRel,,,{|x,y| x[11]+x[2] + x[1] < y[11]+y[2] + y[1]} ) },STR0005)//"Processando..."
EEQ->(DbSetOrder(4)) //Alcir Alves - 11-05-05

For i:= 1 to Len(aDadosRel)
   Do Case
      Case aDadosRel[i][1] == "107" //Nota Fiscal
         aAdd(aNFs, { iIF(lTop,aDadosRel[i][ 9],Posicione("EEC",1,cFilEEC+aDadosRel[i][2],"EEC_IMPORT")),;//[ 1] Cliente
                      iIF(lTop,aDadosRel[i][10],Posicione("EEC",1,cFilEEC+aDadosRel[i][2],"EEC_IMPODE")),;//[ 2] Nome do Cliente
                      aDadosRel[i][2],;                                                                   //[ 3] Processo
                      aDadosRel[i][3],;                                                                   //[ 4] Nota Fiscal
                      aDadosRel[i][4],;                                                                   //[ 5] Data Emissão
                      aDadosRel[i][5],;                                                                   //[ 6] Moeda
                      aDadosRel[i][6],;                                                                   //[ 7] Valor da Nota
                      aDadosRel[i][6] / aDadosRel[i][8],;                                                 //[ 8] Valor na Moeda
                      aDadosRel[i][8],;                                                                   //[ 9] Taxa
                      0,;                                                                                 //[10] V.C.
                      aDadosRel[i][11]} )                                                                               
         // nToTNF   += aDadosRel[i][6] / aDadosRel[i][8]
         // nToTNFRs += aDadosRel[i][6]
         
      Case aDadosRel[i][1] $ "582,583,584,585,586,587" //V.C.
         nProcVC  += aDadosRel[i][6]
         
      Case aDadosRel[i][1] $ "580,581" //V.C. Nota Fiscal
         nPos := aScan(aNFs,{|X| X[3]+X[4] ==  aDadosRel[i][2]+aDadosRel[i][3] })
         if nPos > 0
            aNFs[nPos][10] += aDadosRel[i][6]
         Endif
            
      Case aDadosRel[i][1] $ "112,116,607"     //Pagamento Antecipado e Liquidação Invoice
         //If lAnalit
            aAdd(aLiq,{ aDadosRel[i][4],; //Data de Recebimento
                        aDadosRel[i][6],; //Valor em Reais
                        aDadosRel[i][7],; //Valor na Moeda
                        aDadosRel[i][8]}) //Taxa
                        
         //Endif
         nLiqRs   += aDadosRel[i][6]
         nLiq     += aDadosRel[i][7]
         
      Case aDadosRel[i][1] $ "801,802" //Desconto e Devolução
         nDescProRs += aDadosRel[i][6]
         nDescPro   += aDadosRel[i][7]
   End Case

   IncProc(STR0005)//"Processando..."
   If Len(aDadosRel) == i .OR. aDadosRel[i][2] <> aDadosRel[i+1][2]
      Ntot_nf_r:=0
      Ntot_nf:=0
      For i2 := 1 to Len(aNFs)
         If ( Empty(cParNF)    .OR. cParNF == aNFs[i2][4] ) .AND.;//Filtro por Nota Fiscal
            ( nParDtFil <> 1   .OR. Empty(dParIni)   .OR. dParIni   <= aNFs[i2][5] ) .AND.;//Filtro por Data Inicial em Caso de Filtro por Data de Emissão
            ( nParDtFil <> 1   .OR. Empty(dParFinal) .OR. dParFinal >= aNFs[i2][5] )       //Filtro por Data Final em Caso de Filtro por Data de Emissão
             Ntot_nf_r+=aNFs[i2][7]
             Ntot_nf+=aNFs[i2][8]         
          ENDIF
      NEXT i2
      aSort(aLiq,,,{|x,y| x[1] < y[1]})
      // if PC150TOTNF(cFilEEC,aDadosRel[i][2]) //Alcir Alves - 13-05-05 - caso exista parcelas liquidadas
      For i2 := 1 to Len(aNFs)
         If ( Empty(cParNF)    .OR. cParNF == aNFs[i2][4] ) .AND.;//Filtro por Nota Fiscal
            ( nParDtFil <> 1   .OR. Empty(dParIni)   .OR. dParIni   <= aNFs[i2][5] ) .AND.;//Filtro por Data Inicial em Caso de Filtro por Data de Emissão
            ( nParDtFil <> 1   .OR. Empty(dParFinal) .OR. dParFinal >= aNFs[i2][5] ) .AND. Len(aLiq)>0       //Filtro por Data Final em Caso de Filtro por Data de Emissão

            aLiqNF:= {}
            nToTNF:=0
            nToTNFRs:=0
            For i3:= 1 To Len(aLiq)
               IF aLiq[i3][2]>0
               aAdd(aLiqNF,{ aLiq[i3][1],;                            //Data da Liquidação
                             aLiq[i3][2],; //Valor da Liquidação para a NF em Reais
                             aLiq[i3][3],;   //Valor da Liquidação para a NF na Moeda
                             aLiq[i3][4]})                            //Taxa da Liquidação
               ENDIF
               nToTNF+=aLiq[i3][3]
               nToTNFRs+=aLiq[i3][2]
            Next i3
            if len(Aliqnf)<=0
               aAdd(aLiqNF,{ "",;                            //Data da Liquidação
                             "",; //Valor da Liquidação para a NF em Reais
                             "",;   //Valor da Liquidação para a NF na Moeda
                             ""})                            //Taxa da Liquidação            
            endif
            
            //Adiciona a parte proporcional da Variação Cambial do Processo
            aNFs[i2][10] += nProcVC // * (nToTNFRs)
            
            //Valor de Liquidação do Processo proporcionalizado para a NF
            nReceb   :=   nLiq   // * (nToTNF)
            nRecebRs :=   nLiqRs // * (nToTNFRs)             
            //nRecebRs := ( nLiqRs +  aNFs[i2][10])* (nToTNFRs) 
            
             
            //Valor de Desconto e Devolução do Processo proporcionalizado para a NF
            nDesc    :=  nDescPro // * ( nToTNF)
            nDescRs  :=  nDescProRs // * (nToTNFRs) 
            Vl_recbR:=(aNFs[i2][7]*(nToTNFRs/Ntot_nf_r))
            Vl_recb:=(aNFs[i2][8]*(nToTNF/Ntot_nf))            
            aAdd( aRel,{ aNFs[i2][1],;       //[ 1] - Cliente
                         aNFs[i2][2],;       //[ 2] - Nome do Cliente
                         aNFs[i2][3],;       //[ 3] - Processo
                         aNFs[i2][4],;       //[ 4] - Nota Fiscal
                         aNFs[i2][5],;       //[ 5] - Data de Emissão
                         aNFs[i2][6],;       //[ 6] - Moeda
                         aNFs[i2][7],;       //[ 7] - Valor da Nota
                         aNFs[i2][8],;       //[ 8] - Valor da Nota na Moeda
                         aNFs[i2][9],;       //[ 9] - Taxa da Nota
                         Vl_recbR-aNFs[i2][7],;      //[10] - Variação Cambial
                         Vl_recbR,;          //[11] - Valor Recebido em Reais  //nRecebRs
                         Vl_recb,;            //[12] - Valor Recebido na Moeda  //nReceb
                         nDescRs,;           //[13] - Valor de Desconto em Reais
                         nDesc,;             //[14] - Valor de Desconto na Moeda
                         aLiqNF,;            //[15] - Liquidações
                         aNFs[i2][11]})            
                                     
         Endif
      Next i2
     // endif
      aNFs       := {}
      aLiq       := {}
      aLiqNF     := {}
      nToTNF     := 0
      nToTNFRs   := 0
      nProcVC    := 0
      nLiq       := 0
      nLiqRs     := 0
      nDescPro   := 0
      nDescProRs := 0
   Endif
Next
aDadosRel := {}
Return .T.

/*
Função..: PC150Print
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Prepara Impressão SetPrint
*/
*********************
Function PC150Print()
*********************
Local cDesc1         := STR0006//"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0007//"contábil para PIS E COFINS "
Local cDesc3         := "", cPict := "", imprime := .T.
Private titulo       := STR0008//"Relatório Contabil para PIS e COFINS"
Private nPagina      := 0
Private nLin         := 99
Private cString      := "ECF"
Private lAbortPrint  := .F., limite := 220, tamanho := "G"
Private nomeprog     := "ECOPC150"
Private aReturn      := {STR0009, 1,STR0010, 1, 1, 1, "", 1}//"Zebrado"###"Administracao"
Private nLastKey     := 0
Private wnrel        := "ECOPC150"
Private cFilAtu:="" 

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lCancel| PC150Impr()})

Return .T.

/*
Função..: PC150Impr
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir o Relatório de ACC/ACE
*/
********************
Function PC150Impr()
********************
Local i
Local i2
Local i3
Private cPictVl := AVSX3("ECF_VL_MOE",6)
Private nTamPic := Len(Transform( 1, cPictVl))
Private aColuna := {}

SetRegua( Len(aRel) )

Private nColIni  := 002 //Coluna Inicial
Private nEspaco  := 001 //Espaço entre os campos
Private nRemPict := 002 //Quantos caracteres a remover da Picture
Private aAnalit := {}  //GFP 24/11/2011

cPictVl := "@E "+SubStr(cPictVl,4+nRemPict)//@E 999,999,999.99
nTamPic := Len(Transform( 1, cPictVl))

cPictTx := "@E "+SubStr(cPictVl,4+4)//@E 999,999,999.99
nTamPTx := Len(Transform( 1, cPictTx))

//             Cabeçalho           Texto                  Picture                Tamanho
aColuna := { { STR0011 ,{|x| aRel[x][ 1] }    , AVSX3("EEC_IMPORT",6), AVSX3("EEC_IMPORT",3) },;//"Cliente"
             { STR0012 ,{|x| aRel[x][ 2] }    , AVSX3("EEC_IMPODE",6), AVSX3("EEC_IMPORT",3) },;//""
             { STR0013 ,{|x| aRel[x][ 3] }    , AVSX3("EEC_PREEMB",6), AVSX3("EEC_PREEMB",3) },;//"Embarque"
             { STR0014 ,{|x| aRel[x][ 4] }    , AVSX3("EEM_NRNF"  ,6), AVSX3("EEM_NRNF"  ,3) },;//"Nota Fiscal"
             { STR0015 ,{|x| DtoC(aRel[x][5])}, AVSX3("EEM_DTNF"  ,6), AVSX3("EEM_DTNF"  ,3) },;//"Emissão"
             { STR0016 ,{|x| aRel[x][ 6] }    , AVSX3("EEC_MOEDA" ,6), AVSX3("EEC_MOEDA" ,3) },;//"Moeda"
             { STR0017 ,{|x| aRel[x][ 7] }    , AVSX3("EEM_VLNF"  ,6), AVSX3("EEM_VLNF"  ,3) },;//"Valor da NF"
             { STR0018 ,{|x| aRel[x][ 8] }    , AVSX3("EEM_VLNF"  ,6), AVSX3("EEM_VLNF"  ,3) },;//"Valor Moeda"
             { STR0019 ,{|x| aRel[x][ 9] }    , cPictTx              , nTamPTx               },;//"Tx. Emissão"
             { STR0020 ,{|x| aRel[x][10] }    , cPictVl              , nTamPic               },;//"Variação Cambial"
             { STR0021 ,{|x| aRel[x][11] }    , cPictVl              , nTamPic               },;//"Recebido NF"
             { STR0022 ,{|x| aRel[x][12] }    , cPictVl              , nTamPic               },;//"Recebido Moeda"
             { STR0023 ,{|x| aRel[x][13] }    , cPictVl              , nTamPic               },;//"Descon./Devol."
             { STR0024 ,{|x| aRel[x][14] }    , cPictVl              , nTamPic               } }//"Descon./Devol. Moeda"
If lAnalit
   cStrDtL := STR0025//"Dt. Liq."
   cStrVlR := STR0026//"Valor em Reais"
   cStrVlM := STR0027//"Valor na Moeda"
   cStrTx  := STR0028//"Taxa"
  /* 
   //             Cabeçalho Tamanho do Texto      Texto                      Picture
   aAnalit := { { "cStrDtL",AVSX3("ECF_DTCONT",3),{|x,y| aRel[x][15][y][1] },AVSX3("ECF_DTCONT",6)},;
                { "cStrVlR",nTamPic              ,{|x,y| aRel[x][15][y][2] },cPictVl              },;
                { "cStrVlM",nTamPic              ,{|x,y| aRel[x][15][y][3] },cPictVl              },;
                { "cStrTx" ,nTamPic              ,{|x,y| aRel[x][15][y][4] },cPictVl              } }
                */
Endif

Begin Sequence

   For i:= 1 To Len(aRel)

      If lCancel
         BREAK
      Endif

      If nLin > 56
         //Imprime cabeçalho
         PC150RlCab()
         nLin := 7
      Endif

      if cFilAtu<>aRel[i][16]
          nLin++
          @nLin,0 PSAY replicate("*",220)
          nLin++
          cFilAtu:=aRel[i][16]
          @ nLin,02 PSAY "Filial"+" "+cFilAtu+" - "+AvgFilName({cFilAtu})[1]
          nLin++
          @nLin,0 PSAY replicate("*",220)
          nLin++  
      endif

      //Imprime Linha
      PC150ImpLin(i)
      nLin++

      If lAnalit
         For i2:= 1 To Len(aRel[i][Len(aRel[i])])
            If i2 == 1
               PC150RlCab(.T.)
            Endif
               
            nColuna := nColIni * 2
            For i3:= 1 To Len(aAnalit)              
               cSay := Transform( Eval(aAnalit[i3][3],i,i2), aAnalit[i3][4] )
               
               If Len(cSay) > 0
                  @ nLin,nColuna PSay cSay
               Endif
               
               //Soma o Espaco Impresso
               nColuna += iIF( Len(cSay) > Len(&(aAnalit[i3][1])), Len(cSay), Len(&(aAnalit[i3][1])) ) + nEspaco
            Next
            
            nLin++
         Next
         //nLin++
      Endif

      IncRegua()
   Next
   
   Set Printer To
   OurSpool(wnrel)                 
   
End Sequence

MS_FLUSH()

Return .T.

/*
Função..: PC150ImpLin
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir uma Linha no Relatório de acordo com o aColuna
*/
Function PC150ImpLin(nLinha)
Local i
nColuna := nColIni
For i:= 1 To Len(aColuna)
   If aColuna[i][1] <> NIL
      cSay:= ""

      //Imprimi o Texto -Texto                       Picture
      cSay := Transform( Eval(aColuna[i][2],nLinha), aColuna[i][3] )
      
      If Len(cSay) < PC150TamCol(i)
         If ValType(Eval(aColuna[i][2],nLinha)) $ "N"
            cSay := Space( PC150TamCol(i)-Len(cSay) ) + cSay
         Else
            cSay := cSay + Space( PC150TamCol(i)-Len(cSay) )
         Endif
      Endif
      
      If Len(cSay) > 0
         @ nLin,nColuna PSay Left(cSay,PC150TamCol(i))
      Endif
      
      //Soma o Espaco Impresso nessa coluna
      nColuna += PC150TamCol(i) + nEspaco
   Endif
Next

Return .T.

/*
Função..: PC150RlCab
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir o Cabeçalho do Relatório
*/
****************************
Function PC150RlCab(lSubCab)
****************************
Local i

If lSubCab
   //Cabeçalho de processos
   nCol := nColIni * 2
   For i:= 1 to Len(aAnalit)
   
      nColFim := nCol+iIF(Len(&(aAnalit[i][1])) > aAnalit[i][2],Len(&(aAnalit[i][1])),aAnalit[i][2])
      RC150ImpCen(nLin,nCol,nColFim,&(aAnalit[i][1]))
      nCol    := nColFim+nEspaco
   
   Next
   nLin++
Else
   nPagina ++
   cTitPag := STR0029 + StrZero(nPagina,4,0)//"Pagina "
   @ 00, 00 PSay __PrtFatline()
   @ 01, 00 PSay STR0030+DtoC(Date())+" - "+Time()//"Emissão: " Data e Hora
   @ 01, ( 220 / 2 ) - ( Len(titulo) / 2 ) PSay titulo
   @ 01, 220 - Len(cTitPag) PSay cTitPag
   @ 02, 00 PSay __PrtFatline()

   @ 03, 00 PSay STR0031+DtoC(dParIni)+STR0032+DtoC(dParFinal)+" "+iIF(nParDtFil==1,STR0034,STR0035)//"Periodo de "###" até "###"Por Emissão da Nota Fiscal"###"Por Recebimento"

   //Cabeçalho
   //Primeira Linha
   //-----------------------------------------------------------------------------------
   nColuna := nColIni
   For i:= 1 to Len(aColuna)
      If aColuna[i][1] <> NIL
         nTamCol := PC150TamCol(i)

         nColFim := nColuna+nTamCol
         If i < Len(aColuna) .AND. aColuna[i+1][1] == NIL
            //Pega o Tamanho da Proxima Coluna caso ela não tenha Titulo de cabeçalho
            nColFim += nEspaco+CO150TamCol(i+1)
         Endif

         PC150ImpCen(05,nColuna,nColFim,aColuna[i][1])
         nColuna := nColFim+nEspaco
      Endif
   Next
   //-----------------------------------------------------------------------------------
   @ 06, 00 PSay __PrtThinLine()   
Endif

Return .T.

/*
Função..: PC150TamCol
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Retornar o Tamanho da Coluna
*/
**************************
Function PC150TamCol(nCol)
**************************
RETURN Max(Len(Transform(1,aColuna[nCol][3])),Max( aColuna[nCol][4], Len(aColuna[nCol][1]) ) )

/*
Função..: PC150ImpCen
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir texto centralizado entre duas colunas
*/
Function PC150ImpCen(nLinha,nColIni,nColFim,cTexto)
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
Função..: PC150DBFImp
Autor...: Alessandro Alves Ferreira - AAF
Data....: 12/11/04
Objetivo: Gera work com o relatório para exportar ao Excel
          ou salvar arquivo DBF/TXT
*/
****************************
Function PC150DbfImp(lExcel)
****************************
Local i
Local i2
Local cArquivo := CriaTrab(,.F.)
Local oExcelApp
cDirDocs := MsDocPath()
cPath	:= AllTrim(GetTempPath())

aColuna := { { "CLIENTE"   ,AVSX3("EEC_IMPORT", 02), AVSX3("EEC_IMPORT", 03), AVSX3("EEC_IMPORT", 04),{|x| aRel[x][ 1] } },;
             { "NM_CLIENTE",AVSX3("EEC_IMPODE", 02), AVSX3("EEC_IMPODE", 03), AVSX3("EEC_IMPODE", 04),{|x| aRel[x][ 2] } },;
             { "EMBARQUE"  ,AVSX3("ECF_PREEMB", 02), AVSX3("EEC_PREEMB", 03), AVSX3("EEC_PREEMB", 04),{|x| aRel[x][ 3] } },;
             { "NF"        ,AVSX3("EEM_NRNF"  , 02), AVSX3("EEM_NRNF"  , 03), AVSX3("EEM_NRNF"  , 04),{|x| aRel[x][ 4] } },;
             { "EMISSAO"   ,AVSX3("EEM_DTNF"  , 02), AVSX3("EEM_DTNF"  , 03), AVSX3("EEM_DTNF"  , 04),{|x| aRel[x][ 5] } },;
             { "MOEDA"     ,AVSX3("ECF_MOEDA" , 02), AVSX3("ECF_MOEDA" , 03), AVSX3("ECF_MOEDA" , 04),{|x| aRel[x][ 6] } },;
             { "VALOR_RS"  ,AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04),{|x| aRel[x][ 7] } },;
             { "VALOR_MOE" ,AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04),{|x| aRel[x][ 8] } },;
             { "TX_EMISSAO",AVSX3("EEM_TXTB"  , 02), AVSX3("EEM_TXTB"  , 03), AVSX3("EEM_TXTB"  , 04),{|x| aRel[x][ 9] } },;
             { "VARIA_CAMB",AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04),{|x| aRel[x][10] } },;
             { "VL_REC_RS" ,AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04),{|x| aRel[x][11] } },;
             { "VL_REC_MOE",AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04),{|x| aRel[x][12] } },;
             { "DESC_RS"   ,AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04),{|x| aRel[x][13] } },;
             { "DESC_MOE"  ,AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04),{|x| aRel[x][14] } },; 
             { "FILIAL"    ,AVSX3("ECF_FILIAL", 02), AVSX3("ECF_FILIAL", 03), AVSX3("ECF_FILIAL", 04),{|x| aRel[x][16] } }             }

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
         MsgStop(STR0033) //"MsExcel não instalado."
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

//Autor: Alcir Alves
/*
Função..: PC150AcDic
Data....: 18/11/04
Objetivo: Acertar o Dicionário SX1 caso não exista o Pergunte
*/
/*
*************************
Function PC150AcDic()
*************************
LOCAL cSX1CMP  // LCS.06/05/2009.14:44
//SXB
If !SXB->( dbSeek("EEM"+Space(3)+"1"+"01"+"DB") )
   SXB->( RecLock("SXB",.T.) )
   SXB->XB_ALIAS  := "EEM"
   SXB->XB_TIPO   := "1"
   SXB->XB_SEQ    := "01"
   SXB->XB_COLUNA := "DB"
   SXB->XB_DESCRI := "Nota Fiscal"
   SXB->XB_DESCSPA:= ""
   SXB->XB_DESCENG:= ""
   SXB->XB_CONTEM := "EEM"
   SXB->( MsUnLock() )
EndIf
If !SXB->( dbSeek("EEM"+Space(3)+"2"+"01"+"01") )
   SXB->( RecLock("SXB",.T.) )
   SXB->XB_ALIAS  := "EEM"
   SXB->XB_TIPO   := "2"
   SXB->XB_SEQ    := "01"
   SXB->XB_COLUNA := "01"
   SXB->XB_DESCRI := "Nota Fiscal"
   SXB->XB_DESCSPA:= ""
   SXB->XB_DESCENG:= ""
   SXB->XB_CONTEM := ""
   SXB->( MsUnLock() )
EndIf
If !SXB->( dbSeek("EEM"+Space(3)+"4"+"01"+"01") )
   SXB->( RecLock("SXB",.T.) )
   SXB->XB_ALIAS  := "EEM"
   SXB->XB_TIPO   := "4"
   SXB->XB_SEQ    := "01"
   SXB->XB_COLUNA := "01"
   SXB->XB_DESCRI := "Nota Fiscal"
   SXB->XB_DESCSPA:= ""
   SXB->XB_DESCENG:= ""
   SXB->XB_CONTEM := "EEM->EEM_NRNF"
   SXB->( MsUnLock() )
EndIf
If !SXB->( dbSeek("EEM"+Space(3)+"4"+"01"+"02") )
   SXB->( RecLock("SXB",.T.) )
   SXB->XB_ALIAS  := "EEM"
   SXB->XB_TIPO   := "4"
   SXB->XB_SEQ    := "01"
   SXB->XB_COLUNA := "02"
   SXB->XB_DESCRI := "Embarque"
   SXB->XB_DESCSPA:= ""
   SXB->XB_DESCENG:= ""
   SXB->XB_CONTEM := "EEM->EEM_PREEMB"
   SXB->( MsUnLock() )
EndIf
If !SXB->( dbSeek("EEM"+Space(3)+"4"+"01"+"03") )
   SXB->( RecLock("SXB",.T.) )
   SXB->XB_ALIAS  := "EEM"
   SXB->XB_TIPO   := "4"
   SXB->XB_SEQ    := "01"
   SXB->XB_COLUNA := "03"
   SXB->XB_DESCRI := "Valor"
   SXB->XB_DESCSPA:= ""
   SXB->XB_DESCENG:= ""
   SXB->XB_CONTEM := "Transform(EEM->EEM_VLNF,AVSX3('EEM_VLNF',6))"
   SXB->( MsUnLock() )
EndIf
If !SXB->( dbSeek("EEM"+Space(3)+"5"+"01") )
   SXB->( RecLock("SXB",.T.) )
   SXB->XB_ALIAS  := "EEM"
   SXB->XB_TIPO   := "5"
   SXB->XB_SEQ    := "01"
   SXB->XB_COLUNA := ""
   SXB->XB_DESCRI := ""
   SXB->XB_DESCSPA:= ""
   SXB->XB_DESCENG:= ""
   SXB->XB_CONTEM := "EEM->EEM_NRNF"
   SXB->( MsUnLock() )
EndIf

//SX1
cSX1CMP := PADR("PC150",LEN(SX1->X1_GRUPO)," ")
///If !SX1->( dbSeek("PC150 "+"01") )
If !SX1->( dbSeek(cSX1CMP+"01") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "01"
   SX1->X1_VARIAVL := "mv_ch1"
   SX1->X1_VAR01   := "mv_par01"
   SX1->X1_PERGUNT := "Cliente ?"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := AVSX3("EEC_IMPORT",3)
   SX1->X1_GSC     := "G"
   SX1->X1_F3      := "CLI"
   SX1->X1_VALID   := "Vazio() .OR. ExistCpo('SA1',mv_par01)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("PC150 "+"02") )
If !SX1->( dbSeek(cSX1CMP+"02") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "02"
   SX1->X1_VARIAVL := "mv_ch2"
   SX1->X1_VAR01   := "mv_par02"
   SX1->X1_PERGUNT := "Processo ?"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := AVSX3("ECF_PREEMB",3)
   SX1->X1_GSC     := "G"
   SX1->X1_F3      := "EEC"
   SX1->X1_VALID   := "Vazio() .OR. ExistCpo('EEC',mv_par02)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("PC150 "+"03") )
If !SX1->( dbSeek(cSX1CMP+"03") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "03"
   SX1->X1_VARIAVL := "mv_ch3"
   SX1->X1_VAR01   := "mv_par03"
   SX1->X1_PERGUNT := "Nota Fiscal ?"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO :=  AVSX3("ECF_NRNF",3)
   SX1->X1_GSC     := "G"
   SX1->X1_F3      := "EEM"
   //SX1->X1_VALID   := "Vazio() .OR. ExistCpo('EEM',mv_par03)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("PC150 "+"04") )
If !SX1->( dbSeek(cSX1CMP+"04") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "04"
   SX1->X1_VARIAVL := "mv_ch4"
   SX1->X1_VAR01   := "mv_par04"
   SX1->X1_PERGUNT := "Data Inicial ?"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO :=  8
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "Vazio() .OR. E_Periodo_Ok(mv_par04,mv_par05)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("PC150 "+"05") )
If !SX1->( dbSeek(cSX1CMP+"05") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "05"
   SX1->X1_VARIAVL := "mv_ch5"
   SX1->X1_VAR01   := "mv_par05"
   SX1->X1_PERGUNT := "Data Final ?"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO :=  8
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "Vazio() .OR. E_Periodo_Ok(mv_par04,mv_par05)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("PC150 "+"06") )
If !SX1->( dbSeek(cSX1CMP+"06") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "06"
   SX1->X1_VARIAVL := "mv_ch6"
   SX1->X1_VAR01   := "mv_par06"
   SX1->X1_PERGUNT := "Periodo Por:"
   SX1->X1_TIPO    := "N"
   SX1->X1_TAMANHO :=  1
   SX1->X1_GSC     := "C"
   SX1->X1_DEF01   := "Emissão da NF"
   SX1->X1_DEF02   := "Por Recebimento"
   SX1->(msUnlock() )
Endif

///If !SX1->( dbSeek("PC150 "+"07") )
If !SX1->( dbSeek(cSX1CMP+"07") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "07"
   SX1->X1_VARIAVL := "mv_ch7"
   SX1->X1_VAR01   := "mv_par07"
   SX1->X1_PERGUNT := "Relatório: "
   SX1->X1_TIPO    := "N"
   SX1->X1_TAMANHO :=  1
   SX1->X1_GSC     := "C"
   SX1->X1_DEF01   := "Sintético"
   SX1->X1_DEF02   := "Analitico"
   SX1->(msUnlock() )
Endif

///If !SX1->( dbSeek("PC150 "+"08") )
If !SX1->( dbSeek(cSX1CMP+"08") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "PC150 "
   SX1->X1_ORDEM   := "08"
   SX1->X1_VARIAVL := "mv_ch8"
   SX1->X1_VAR01   := "mv_par08"
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