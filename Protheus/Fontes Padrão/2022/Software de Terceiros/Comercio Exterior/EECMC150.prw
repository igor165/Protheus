// Programador : Alcir Alves
// Data Desenvolvimento- 26-02-05
// Objetivo - SIGAEEC / SIGAEFF - Imprimir relatório de hanking dos melhores clientes
// exportação para excel/texto/gráfico
//Estrutura em Codebase e SQL
// PRW : EECMC150
#INCLUDE "EECMC150.CH"
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSGRAPHI.CH"

*// Função principal do menu de acesso
*---------------------------------------------------------------------------------------
FUNCTION EECMC150()                                                                                        
*---------------------------------------------------------------------------------------
Local ni:=0
Local i:=0
Local existReg:=.F.
Private Moe_Conv:="US$",aGrpPED:={} //Moeda padrão do relatório e array com resultado do hanking
Private WorkFile,WorkFile2,lTop,cMarca:={} 
Private FilAtu:=""
Private iSfilSA1:=.t.,SQL_FilS:="",cFilSYA:=XFILIAL("SYA")
Private Acampos:=Adata:={} //estrutura da msselect
Private afilSel:={} //filiais selecionadas
Private SQL_PERG:=STR_PERG:=""
Private nTotItem:=0 //totais de clientes no hancking
Private TotPED:=TotCRT:=0
Private aFluxo
      #IFDEF TOP
        lTop := .T.
      #ElSE
        lTop := .F.
      #ENDIF  

      afilSel:=AvgSelectFil(.T.,"EEC") //Alcir 
      if afilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
         for ni:=1 to len(afilSel)
             SQL_FilS+=iif(!empty(SQL_FilS),",","")+"'"+afilSel[ni]+"'" 
         next
         cfilSA1:=AvgSelectFil(.F.,"SA1") //Alcir 
         if len(cfilSA1)==1 .and. alltrim(cfilSA1)=="" //caso sa1 clientes esteja compartilhada
             iSfilSA1:=.f.
         endif
      
         IF Pergunte("EECMC1",.T.)
             EECMCVAL('5')
             //condição para a consulta do relatorio
             nTotItem:=iif(mv_par01<=0,10,int(mv_par01))
             IF lTop
                SQL_PERG:=IIF(!EMPTY(mv_par02)," AND SA1.A1_PAIS='"+mv_par02+"'","")+; //PAIS
                       IIF(!EMPTY(mv_par03)," AND EEC.EEC_DTEMBA>='"+(DTOS(mv_par03))+"'","")+; //PERIODO INICIAL DO EMBARQUE
                       IIF(!EMPTY(mv_par04)," AND EEC.EEC_DTEMBA<='"+(DTOS(mv_par04))+"'","")+; //PERIODO FINAL DO EMBARQUE
                       IIF(!EMPTY(mv_par05)," AND EEC.EEC_MPGEXP='"+mv_par05+"'","") //MODALIDADE DE PAGAMENTO                      
             ELSE
               SQL_PERG:="!EEC->(EOF())"+IIF(!EMPTY(mv_par02)," .AND. SA1->A1_PAIS=mv_par02","")+; //PAIS
                       IIF(!EMPTY(mv_par03)," .AND. EEC->EEC_DTEMBA>=mv_par03","")+; //PERIODO INICIAL DO EMBARQUE
                       IIF(!EMPTY(mv_par04)," .AND. EEC->EEC_DTEMBA<=mv_par04","")+; //PERIODO FINAL DO EMBARQUE
                       IIF(!EMPTY(mv_par05)," .AND. EEC->EEC_MPGEXP=mv_par05","") //MODALIDADE DE PAGAMENTO
             ENDIF
             STR_PERG:=IIF(!EMPTY(mv_par02),"Pais: "+alltrim(POSICIONE("SYA",1,cFilSYA+mv_par02,"YA_DESCR"))+"   ","")+; //PAIS
                    IIF(!EMPTY(mv_par03),"Per.Inic Dt.Emb.: "+dtoc(mv_par03)+"   ","")+; //periodo inicial do embarque
                    IIF(!EMPTY(mv_par04),"Per.Fin Dt.Emb.: "+dtoc(mv_par04)+"   ","")+; //periodo final embarque                    
                    IIF(!EMPTY(mv_par05),"Mod.Pagam.: "+mv_par05+"   ","") //modalidade de pagamento
             //
       
             Adata:={}
             Aadd(Adata,{"POSICAO","N",6,0})   //POSIÇÃO
             Aadd(Adata,{"FILIAL",AVSX3("EEC_FILIAL",2),AVSX3("EEC_FILIAL",3),AVSX3("EEC_FILIAL",4)})   //FILIAL
             Aadd(Adata,{"N_FILIAL","C",15,0})   //NOME FILIAL          
             Aadd(Adata,{"CLIENTE",AVSX3("EEC_IMPORT",2),AVSX3("EEC_IMPORT",3),AVSX3("EEC_IMPORT",4)})  //CLIENTE
             Aadd(Adata,{"CLIENTE_D",AVSX3("A1_NOME",2),AVSX3("A1_NOME",3),AVSX3("A1_NOME",4)})  //DESCRICAO DO CLIENTE
             Aadd(Adata,{"LOJA",AVSX3("EEC_IMLOJA",2),AVSX3("EEC_IMLOJA",3),AVSX3("EEC_IMLOJA",4)})  //LOJA
             Aadd(Adata,{"PAIS",AVSX3("YA_DESCR",2),AVSX3("YA_DESCR",3),AVSX3("YA_DESCR",4)})  //pais
             Aadd(Adata,{"PROC_TOT",AVSX3("EEC_TOTPED",2),AVSX3("EEC_TOTPED",3),AVSX3("EEC_TOTPED",4)}) //PEDIDO TOTAL
             Aadd(Adata,{"SAQUES",AVSX3("EEC_TOTPED",2),AVSX3("EEC_TOTPED",3),AVSX3("EEC_TOTPED",4)})   //SAQUES /TOTAL EM CARTA DE CRÉDITO
             Aadd(Adata,{"LC",AVSX3("EEC_TOTPED",2),AVSX3("EEC_TOTPED",3),AVSX3("EEC_TOTPED",4)})      //DIFERENCA DE PEDIDO TOTAL E CARTA DE CRÉDITO
             Aadd(Adata,{"P_SAQUE","N",6,2})   //PERCENTUAL SAQUE
             Aadd(Adata,{"P_LC","N",6,2})   //PERCENTUAL L/C

             WorkFile := E_CriaTrab(, Adata, "Work1")

             MsAguarde({|| existReg := CRIA_WK()}, "Processando dados, Aguardem...") //gera work
             IF existReg //caso exista dados
                 //Estrutura do MSSELECT
                 Acampos := {{"POSICAO",,"Posição"},;
                      {"FILIAL",,"Filial",""},;   
                      {"N_FILIAL",, "Nome Filial",""},;
                      {"CLIENTE",,"Cod.Cliente",""},;   
                      {"CLIENTE_d",,"Des.Cliente",""},;   
                      {"LOJA",,"Loja",""},;                         
                      {"PAIS",,"País",""},;                                               
                      {"PROC_TOT",,"Tot. Processo",AVSX3("EEC_TOTPED",6)},;                         
                      {"SAQUES",,"Tot. Saque",AVSX3("EEC_TOTPED",6)},;                         
                      {"LC",,"Tot. L/C",AVSX3("EEC_TOTPED",6)},;                         
                      {"P_SAQUE",,"% Saques","@E999.99"},;                         
                      {"P_LC",,"% L/C","@E999.99"}}                         
                 // DEFINE MSDIALOG oDlg2 TITLE STR0001+alltrim(str(mv_par01))+STR0002 FROM oMainWnd:nTop+50, oMainWnd:nLeft+50 TO oMainWnd:nHeight-50,oMainWnd:nWidth-50 OF oMainWnd PIXEL  //"Relação dos maiores clientes - "
                 DEFINE MSDIALOG oDlg2 TITLE STR0001+alltrim(str(mv_par01))+STR0002 FROM 10,10 TO 400,750 OF oMainWnd PIXEL  //"Relação dos maiores clientes - " ASK                                                             
                    @ 6,8 say STR0003+iif(empty(STR_PERG),STR0012,STR_PERG) Of oDlg2 pixel //"Filtrado por: "
                    @ 15,140 BUTTON STR0004 SIZE 35,11 Of oDlg2 pixel ACTION    MsAguarde({|| GERA_RPT1()}, STR0013) //gera work  "Imprimir"
                    @ 15,190 BUTTON STR0005 SIZE 38,11 Of oDlg2 pixel ACTION MsAguarde({|| WORK_EXPORT(.T.)},STR0014)  //"Gerar Excel"
                    @ 15,240 BUTTON STR0006 SIZE 35,11 Of oDlg2 pixel ACTION MsAguarde({|| WORK_EXPORT(.F.)}, STR0015)  //"Gerar Txt"
                    @ 15,290 BUTTON STR0007 SIZE 35,11 Of oDlg2 pixel ACTION Grafico(oDlg2,"","","")                 //"Gráfico"
                    @ 20,700 BTNBMP oBtn RESOURCE "FINAL" SIZE 25,25 Of oDlg2 pixel ACTION oDlg2:End() MESSAGE STR0008 //fechar
                    @ 180,8 say STR0009+Moe_Conv+transform(TotPED,AVSX3("EEC_TOTPED",6)) Of oDlg2 pixel  //"Totais Processo: "
                    @ 180,140 say STR0010+Moe_Conv+transform(TotCRT,AVSX3("EEC_TOTPED",6)) Of oDlg2 pixel //"Totais saques: "
                    @ 180,272 say STR0011+Moe_Conv+transform((TotPED-TotCRT),AVSX3("EEC_TOTPED",6)) Of oDlg2 pixel  //"Totais L/C: "                
                    work1->(dbgotop())
                    oSel:=MsSelect():New("WORK1",,,Acampos,,cMarca,{35,10,170,360})
                    oSel:oBrowse:bwhen:={||(dbSelectArea("WORK1"),.t.)}
                    oSel:oBrowse:bGotop
                    oSel:oBrowse:Refresh()
                 ACTIVATE MSDIALOG oDlg2 centered 
             ELSE
                Msgstop(STR0016) //"Não exitem dados para esta consulta"
             ENDIF
             work1->(dbclosearea())
         ENDIF
      ENDIF
Return .t.

*// Cria Work principal
*---------------------------------------------------------------------------------------
Static Function CRIA_WK()
*---------------------------------------------------------------------------------------
      Local npos:=Temp_vped:=Temp_vcrt:=nConvVal:=0 //array com os resultados do agrupamento com os totais do pedido
      Local i:=0,ntaxa:=0,ntaxa2:=0 //totais gerais de valor FOB e total por carta
      TotPED:=0
      TotCRT:=0
      if ltop //CASO TOP
         cQuery:="SELECT EEC.EEC_FILIAL,EEC.EEC_IMPORT,EEC.EEC_IMLOJA,EEC.EEC_MOEDA,SA1.A1_NOME,SA1.A1_PAIS,EEC.EEC_TOTPED,EEC.EEC_LC_NUM,EEC.EEC_DTEMBA from "+RetSqlName("EEC")+" EEC ,"+RetSqlName("SA1")+" SA1 "+;
              " WHERE (EEC.EEC_DTEMBA<>'"+SPACE(8)+"' OR EEC.EEC_DTEMBA<>'') AND EEC.EEC_FILIAL IN("+SQL_FilS+") AND SA1.A1_FILIAL="+iif(iSfilSA1,"EEC.EEC_FILIAL","'"+xfilial("SA1")+"'")+" and SA1.A1_COD=EEC.EEC_IMPORT "+;
              " AND SA1.A1_LOJA=EEC.EEC_IMLOJA AND "+IIF(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_<>'*'","EEC.@DELETED@<>'*'")+;
              " AND "+IIF(TcSrvType()<>"AS/400","SA1.D_E_L_E_T_<>'*'","SA1.@DELETED@<>'*'")+SQL_PERG+;
              " ORDER BY EEC.EEC_IMPORT,EEC.EEC_IMLOJA,EEC.EEC_MOEDA,EEC.EEC_PREEMB"
         cQuery:=ChangeQuery(cQuery)
         TcQuery cQuery ALIAS "QUERY01" NEW
         TCSetField( "QUERY01", "EEC_DTEMBA", "D", 8, 0 )
         DO WHILE QUERY01->(EOF())==.F.
               Temp_vcrt:=0
               Temp_Vped:=0
               IF QUERY01->EEC_MOEDA<>Moe_Conv //CASO MOEDA DO PROCESSO DIFERENTE DA MOEDA PADRÃO DORELATÓRIO - HAVERÁ A CONVERSÃO
                   IF alltrim(QUERY01->EEC_MOEDA)<>"R$"
                       ntaxa:=BuscaTaxa(QUERY01->EEC_MOEDA,QUERY01->EEC_DTEMBA,,.F.,.T.) 
                       ntaxa2:=BuscaTaxa(Moe_Conv,QUERY01->EEC_DTEMBA,,.F.,.T.)
                       nConvVal := QUERY01->EEC_TOTPED * iif(ntaxa=0,1,ntaxa)
                       Temp_Vped := nConvVal / iif(ntaxa2=0,1,ntaxa2)
                   ELSE //caso real
                       ntaxa:= BuscaTaxa(Moe_Conv,QUERY01->EEC_DTEMBA,,.F.,.T.)
                       Temp_Vped := QUERY01->EEC_TOTPED /iif(ntaxa=0,1,ntaxa)
                   ENDIF
               ELSE //caso moeda do relatório
                   Temp_Vped:=QUERY01->EEC_TOTPED
               ENDIF
               If !empty(QUERY01->EEC_LC_NUM) //caso exista carta de crédito
                     Temp_vcrt := Temp_Vped
               endif
               TotPED+=Temp_Vped //totais gerais do fob na moeda do relatorio
               TotCRT+=Temp_vcrt //totais gerais do contrato
               nPos:=ASCAN(aGrpPED,{ |x| x[1]=(QUERY01->EEC_IMPORT+QUERY01->EEC_IMLOJA)})
               IF nPos>0
                   aGrpPED[nPos,2]+=Temp_Vped //totais fob
                   aGrpPED[nPos,3]+=Temp_vcrt //totais contratos
                   aGrpPED[nPos,4]+=(Temp_Vped-Temp_vcrt)  //diferenca entre fob e contratos
               ELSE
                   //                                 1                       2          3           4                    5                     6                       7              8                  9                  10                  11               12                       13                             14                
                   aadd(aGrpPED,{(QUERY01->EEC_IMPORT+QUERY01->EEC_IMLOJA),Temp_Vped,Temp_vcrt,(Temp_Vped-Temp_vcrt),QUERY01->EEC_IMPORT,QUERY01->EEC_IMLOJA,QUERY01->EEC_MOEDA,QUERY01->A1_NOME,QUERY01->A1_PAIS,QUERY01->EEC_TOTPED,QUERY01->EEC_LC_NUM,QUERY01->EEC_DTEMBA,QUERY01->EEC_FILIAL,POSICIONE("SYA",1,cFilSYA+QUERY01->A1_PAIS,"YA_DESCR")})
               ENDIF   
               QUERY01->(DBSKIP())
         ENDDO
         QUERY01->(DBCLOSEAREA())
      else //CODEBASE
         DBSELECTAREA("EEC")
         EEC->(DBSETORDER(1))
         FOR I:=1 TO LEN(afilSel)
            EEC->(DBSEEK(afilSel[I]))
            DO WHILE EEC->(EOF())==.F. .AND. EEC->EEC_FILIAL==afilSel[I]
                  IF EMPTY(EEC->EEC_DTEMBA)
                      EEC->(DBSKIP())
                      LOOP
                  ENDIF
                  Temp_vcrt:=0
                  Temp_Vped:=0
                  IF EEC->EEC_MOEDA<>Moe_Conv //CASO MOEDA DO PROCESSO DIFERENTE DA MOEDA PADRÃO DORELATÓRIO - HAVERÁ A CONVERSÃO
                      IF alltrim(EEC->EEC_MOEDA)<>"R$"
                          ntaxa:=BuscaTaxa(EEC->EEC_MOEDA,EEC->EEC_DTEMBA,,.F.,.T.) 
                          ntaxa2:=BuscaTaxa(Moe_Conv,EEC->EEC_DTEMBA,,.F.,.T.)
                          nConvVal := EEC->EEC_TOTPED * iif(ntaxa=0,1,ntaxa)
                          Temp_Vped := nConvVal / iif(ntaxa2=0,1,ntaxa2)
                      ELSE //caso real
                          ntaxa:= BuscaTaxa(Moe_Conv,EEC->EEC_DTEMBA,,.F.,.T.)
                          Temp_Vped := EEC->EEC_TOTPED /iif(ntaxa=0,1,ntaxa)
                      ENDIF
                  ELSE //caso moeda do relatório
                      Temp_Vped:=EEC->EEC_TOTPED
                  ENDIF
                  If !empty(EEC->EEC_LC_NUM) //caso exista carta de crédito
                        Temp_vcrt := Temp_Vped
                  endif
            
                  TotPED+=Temp_Vped //totais gerais do fob na moeda do relatorio
                  TotCRT+=Temp_vcrt //totais gerais do contrato
                  nPos:=ASCAN(aGrpPED,{ |x| x[1]=(EEC->EEC_IMPORT+EEC->EEC_IMLOJA)})
                  IF nPos>0
                      aGrpPED[nPos,2]+=Temp_Vped //totais fob
                      aGrpPED[nPos,3]+=Temp_vcrt //totais contratos
                      aGrpPED[nPos,4]+=(Temp_Vped-Temp_vcrt)  //diferenca entre fob e contratos
                  ELSE
                   //                                 1                       2          3           4                    5                     6                       7              8                  9                  10                  11               12                       13                             14                
                      POSICIONE("SA1",1,iif(iSfilSA1,EEC->EEC_FILIAL,xfilial("SA1"))+EEC->EEC_IMPORT,"A1_NOME")
                      IF &SQL_PERG
                          aadd(aGrpPED,{(EEC->EEC_IMPORT+EEC->EEC_IMLOJA),Temp_Vped,Temp_vcrt,(Temp_Vped-Temp_vcrt),EEC->EEC_IMPORT,EEC->EEC_IMLOJA,EEC->EEC_MOEDA,SA1->A1_NOME,SA1->A1_PAIS,EEC->EEC_TOTPED,EEC->EEC_LC_NUM,EEC->EEC_DTEMBA,EEC->EEC_FILIAL,POSICIONE("SYA",1,cFilSYA+SA1->A1_PAIS,"YA_DESCR")})
                      ENDIF
                  ENDIF   
                  EEC->(DBSKIP())
            ENDDO
         NEXT
      endif
      //sorteia array por ordem de total do pedido e cria um lasso apenas dos n "mv_par01" primeiros clientes
      aGrpPED:=asort(aGrpPED,,,{ |x,y| x[2]>y[2] })
      dbselectarea("work1")
      nTotItem:=iif(nTotItem>len(aGrpPED),len(aGrpPED),nTotItem)
      for i:=1 to nTotItem
          work1->(dbappend())
          work1->POSICAO:=i
          work1->FILIAL:=aGrpPED[i,13]   //FILIAL
          work1->N_FILIAL:= AvgFilName({aGrpPED[i,13]})[1]
          work1->CLIENTE:=aGrpPED[i,5]  //CLIENTE
          work1->CLIENTE_D:=aGrpPED[i,8] //DESCRICAO DO CLIENTE
          work1->PAIS:=aGrpPED[i,14] //país DO CLIENTE
          work1->LOJA:=aGrpPED[i,6]   //LOJA
          work1->PROC_TOT:=aGrpPED[i,2]  //PEDIDO TOTAL
          work1->SAQUES:=aGrpPED[i,3]    //SAQUES /TOTAL EM CARTA DE CRÉDITO
          work1->LC:=aGrpPED[i,4]   //DIFERENCA DE PEDIDO TOTAL E CARTA DE CRÉDITO
          work1->P_SAQUE:=round((aGrpPED[i,3]/(TotPED))*100,2)   //PERCENTUAL SAQUE
          work1->P_LC:=round((aGrpPED[i,4]/(TotPED))*100,2)    //PERCENTUAL L/C
      next
Return .t.                           

*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------
Local oExcelApp
//Local cDirDocs := MsDocPath()
Local cPath	:= AllTrim(GetTempPath()) + "avgcrw32\"
//WFS 03/11/08
Local aStruct, cDir


WorkFile2 := E_CriaTrab(, Adata, "Work")

MsAguarde({|| CRIA_WK2()},STR0017) //gera work //Processando dados, Aguardem...
  
// WFS 03/11/08
Begin Sequence

   If lExcel
      /**SVG** - 04/03/2009 - Condição para adequação a esportação utilizando Ctree*/
      cArqOrigem := WorkFile2
      cAlias     := "Work"
      lXml       := .F.   
 
      AvExcel(cArqOrigem,cAlias,lXml)

      Work->(dbCloseArea())
   Else

      TR350ARQUIVO("work")
      Work1->(dbGoTop())         
      Work->(dbCloseArea())
   EndIf                          
End Sequence 

Return .T.  

*---------------------------------------------------------------------------------------------------------------*
static Function GERA_RPT1() //gera relatório para impressão
*---------------------------------------------------------------------------------------------------------------*
Local i
Private cSeqRel
If Select("HEADER_P") = 0
   E_ARQCRW(.T.,,.T.)
EndIf
//SetFil()
cSEQREL := GetSXENum("SY0","Y0_SEQREL")
CONFIRMSX8()
acofil:={}
cFil := ""            
/*for i:=1 to nTotItem
   nPos:=ASCAN(acofil,{ |x| x[1]=(EEC->EEC_IMPORT+EEC->EEC_IMLOJA)})
   IF nPos>0
      aGrpPED[nPos,1]=aGrpPED[i,13] 
   Endif
next*/
for i:=1 to nTotItem
   
//  If cFil <> aGrpPED[i,13]
    If !aGrpPED[i,13] $ cFil   
      //CABEÇALHO
      HEADER_P->(dbAppend())
      HEADER_P->AVG_FILIAL := aGrpPED[i,13]
      HEADER_P->AVG_SEQREL := cSeqRel
      HEADER_P->AVG_C02_10 := cEmpAnt  //Código da Empresa
      //HEADER_P->AVG_CHAVE
      
      //HISTÓRICO
      HEADER_H->(dbAppend())
      AvReplace("HEADER_P","HEADER_H")
      
      cFil += aGrpPED[i,13]+"/"
   Endif

   //DETALHES
   DETAIL_P->(dbAppend())
   DETAIL_P->AVG_FILIAL := aGrpPED[i,13]
   DETAIL_P->AVG_SEQREL := cSeqRel
   //DETAIL_P->AVG_CHAVE:=str(i)
   DETAIL_P->AVG_C03_60:=SUBSTR(STR_PERG,1,60) //LIMITA FILTRO A 60 CARACTERES
   DETAIL_P->AVG_C01_60:=ALLTRIM(aGrpPED[i,8]) //CLIENTE (DESCRICAO)
   DETAIL_P->AVG_C02_60:=aGrpPED[i,14] //PAIS
   DETAIL_P->AVG_C01_10:=aGrpPED[i,6]  //LOJA
   DETAIL_P->AVG_N01_15:=aGrpPED[i,2]  //TOTAL PEDIDO
   DETAIL_P->AVG_N02_15:=aGrpPED[i,3]  //SAQUE TOTAL
   DETAIL_P->AVG_N03_15:=aGrpPED[i,4]  //TOTAL L/C
   DETAIL_P->AVG_N04_15:=round((aGrpPED[i,3]/(TotPED))*100,1)  //PERCENTUAL SAQUE
   DETAIL_P->AVG_N05_15:=round((aGrpPED[i,4]/(TotPED))*100,1) //PERCENTUAL L/C 
   DETAIL_P->AVG_N06_15:=i  //POSICAO RANCKING
   DETAIL_P->AVG_N07_15:=nTotItem  //totais no rancking
   DETAIL_P->AVG_N08_15:=2  //tipo de gráfico
   
   //Gravar Historico de Documentos DO DETALHE
   DETAIL_H->(dbAppend())
   AvReplace("DETAIL_P","DETAIL_H")
next
E_HISTDOC(,STR0036,dDataBase,,,"EECMC150.rpt",cSeqrel)
AvgCrw32("EECMC150.rpt",STR0036)
Return .T.

*---------------------------------------------------------------------------------------------------------------*
STATIC FUNCTION CRIA_WK2() //CRIA WORK PARA EXPORTAÇÃO EXCEL E TEXTO
*---------------------------------------------------------------------------------------------------------------*
  Local i
  DBSELECTAREA("WORK1")
  WORK1->(DBGOTOP())
  DBSELECTAREA("WORK")
  for i=1 to nTotItem
          work->(dbappend())
          work->POSICAO:=work1->POSICAO
          work->FILIAL:=work1->FILIAL   //FILIAL
          work->N_FILIAL:= work1->N_FILIAL
          work->CLIENTE:=work1->CLIENTE  //CLIENTE
          work->CLIENTE_D:=work1->CLIENTE_D //DESCRICAO DO CLIENTE
          work->PAIS:=work1->PAIS //país DO CLIENTE
          work->LOJA:=work1->LOJA   //LOJA
          work->PROC_TOT:=work1->PROC_TOT  //PEDIDO TOTAL
          work->SAQUES:=work1->SAQUES   //SAQUES /TOTAL EM CARTA DE CRÉDITO
          work->LC:=work1->LC   //DIFERENCA DE PEDIDO TOTAL E CARTA DE CRÉDITO
          work->P_SAQUE:=work1->P_SAQUE   //PERCENTUAL SAQUE
          work->P_LC:=work1->P_LC    //PERCENTUAL L/C
          WORK1->(DBSKIP())
  next 
WORK->(DBGOTOP())  
RETURN .T.   


//VALIDA ITENS DO PERGUNTE
*---------------------------------------------------------------------------------------------------------------*
function EECMCVAL(ncampo)  //01-02-05
*---------------------------------------------------------------------------------------------------------------*
local lvalida:=.t.
if ncampo="1" //valida rancking
  if mv_par01<=0
     mv_par01:=10
     lvalida:=.f.
  endif     
endif
return lvalida

*---------------------------------------------------------------------------------------------------------------*
Static Function Grafico(aFluxo,nMoeda) //cria área de seleção de tipo de gráfico
*---------------------------------------------------------------------------------------------------------------*
   Local oDlgSer,i:=0
   Local oSer,oCor
   Local cCbx := STR0043
   Local aCbx := { STR0019, STR0020, STR0021, STR0022}  //"Linha" "Área""Pontos""Barras"
   Local aCor := { STR0028,STR0029,STR0030}  //azul vermelho verde
   Private nCbx := 1 //tipo de série
   Private nCor := STR0028 //tipo de cor
   
   DEFINE MSDIALOG oDlgSer TITLE STR0034 FROM 0,0 TO 100,280 PIXEL OF oDlgSer //"Tipo do gráfico"
   @ 008, 005 SAY STR0035 PIXEL OF oDlgSer //"Escolha o tipo de série:"
   @ 008, 063 MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nCbx := oSer:nAt
   @ 020, 005 SAY "Cor do gráfico: " PIXEL OF oDlgSer 
   @ 020, 063 MSCOMBOBOX oCor VAR nCor ITEMS aCor SIZE 077, 120 OF oDlgSer PIXEL
   @ 035, 045 BUTTON "&Ok"  SIZE 30,12 OF oDlgSer PIXEL ACTION (MontaGrafico())
   @ 035, 075 BUTTON STR0037 SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End() //"&Sair"
   ACTIVATE MSDIALOG oDlgSer CENTER
Return .T.


*---------------------------------------------------------------------------------------------------------------*
Static Function MontaGrafico() //plota gráfico na tela 
*---------------------------------------------------------------------------------------------------------------*
   Local oDlg4,cor:={},SerieAtu,nItens
   Local obmp
   Local oBold
   Local oGraphic
   Local nSerie      := 0
   Local nSerie2     := 0
   Local aArea       := GetArea()
   Local aTabela
   Local i:= 0
   Local nx:=0
   aFluxo:={}
   nItens:=nTotItem
   if nTotItem>10 
      msgstop(STR0031)
      nItens:=10
   endif
   for i=1 to nItens
      aadd(aFluxo,{aGrpPED[i,8],aGrpPED[i,2]})  
   next

   DEFINE MSDIALOG oDlg4 FROM 0,0 TO 450,700 PIXEL TITLE STR0001+alltrim(str(mv_par01))+STR0002
   DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
  
   @ 010, 010 MSGRAPHIC oGraphic SIZE 325, 160 OF oDlg4 PIXEL
   oGraphic:SetMargins( 2, 6, 6, 6 )
   oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW,GRP_SERIES, .F.)  //GRP_VALUES
   oGraphic:SetTitle( STR0001+alltrim(str(mv_par01))+STR0002,"", CLR_HRED , A_LEFTJUST , GRP_TITLE )
   nSerie:=oGraphic:CreateSerie(nCbx)
   oGraphic:l3D:=.F.
   oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
   if !empty(STR_PERG)
       oGraphic:SetTitle( STR_PERG, "", CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //Filtros
   endif

   if nCor==STR0028    //azul
       ncor_fil:=CLR_HBLUE 
   elseif nCor==STR0029  //vermelho
        ncor_fil:=CLR_HRED
   elseif nCor==STR0030
        ncor_fil:=CLR_HGREEN  //verde  
   endif    
      
   If nSerie != GRP_CREATE_ERR 
       for i:=1 to len(aFluxo)
           oGraphic:Add(nSerie,aFluxo[i,2],Transform(alltrim(aFluxo[i,1]),""),ncor_fil) 
       next
   Else                                                       
      msgstop(STR0042)
   Endif                                              
   @ 190, 254 BUTTON o3D PROMPT "&3D" SIZE 40,14 OF oDlg4 PIXEL ACTION (oGraphic:l3D := !oGraphic:l3D, o3d:cCaption := If(oGraphic:l3D, "&2D", "&3D"))
   @ 190, 295 BUTTON STR0039   SIZE 40,14 OF oDlg4 PIXEL ACTION GrafSavBmp( oGraphic ) //"&Salva BMP"
   @ 190, 170 BUTTON STR0043    SIZE 40,14 OF oDlg4 PIXEL ACTION oGraphic:ZoomIn() //zoom in
   @ 190, 212 BUTTON STR0044   SIZE 40,14 OF oDlg4 PIXEL ACTION oGraphic:ZoomOut()  //zomm out
   @ 207, 050 TO 209 ,400 LABEL '' OF oDlg4  PIXEL
   If !__lPyme
      	@ 213,254 BUTTON STR0045 SIZE 40,12 OF oDlg4 PIXEL ACTION PmsGrafMail(oGraphic,STR0036,,,1) // E-Mail
   Endif
   @ 213, 295 BUTTON STR0037 SIZE 40,12 OF oDlg4 PIXEL ACTION oDlg4:End() //"&Sair"
   ACTIVATE MSDIALOG oDlg4 CENTER
   RestArea(aArea)
Return .t.