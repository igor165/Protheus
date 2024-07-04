// Programador : Alcir Alves
// Data Desenvolvimento- 04-04-05 - 11:30   término - 16-04-05 - 15:00
// Objetivo - Imprimir relatório de Agin List - Valores de cambio vencidos e a vencer - 
// exportação para excel/texto
//Estrutura em Codebase e SQL
// PRW : EFFAL150.PRW
//RPT : EFFAL150.RPT
#INCLUDE "EFFAL150.CH"
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSGRAPHI.CH"
*// Função principal do menu de acesso
*---------------------------------------------------------------------------------------
FUNCTION EFFAL150()   //Alcir Alves - 04-04-05                                                                                     
*---------------------------------------------------------------------------------------
Local ni:=0
Local existReg:=0
Private lTop := .F.
Private WorkFile:=""
Private afilSel:={} //filiais selecionadas EEQ
Private afilEEC:={} //filiais do EEC
Private SQL_FilS:="" //filiais selecionadas para clausula SQL
Private SQL_FilS2:="" //filiais selecionadas para clausula SQL
Private SQL_PERG:="" //condições dos perguntes na clausula SQL
Private STR_Perg:="" //Filtro pergunte
Private cFilECC:=xfilial("EEC")
Private cFilEEQ:=xfilial("EEQ")
SX1->(DBSETORDER(1)) // Nick 20/10/06 Ref Chamado 039724
//** PLB - 15/05/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0
Private cChSX1    := "" ,;
        cParSX1   := "" ,;
        cSeqSX1   := "" ,;
        cValidSX1 := "" 
IF SELECT("WORK") <> 0  // LCS.08/05/2009.11:06
   WORK->(DBCLOSEAREA()) // LCS.08/05/2009.11:06
ENDIF // LCS.08/05/2009.11:06
//**
      #IFDEF TOP
        lTop := .T.
      #ElSE
        lTop := .F.
      #ENDIF  
      
      do while .t. 
         dbselectarea("EEQ")
         afilSel:=AvgSelectFil(.T.,"EEQ") //Alcir 
         afilEEC:=AvgSelectFil(.F.,"EEC") //Alcir 
         IF afilSel[1]#"WND_CLOSE" //Alcir Alves 
            IF Pergunte("EFFAL1",.T.)
               //** PLB 16/05/06
               If  lEFFTpMod
                  Do Case
                     Case mv_par01 == 1  // Exportacao
                        cTpFilt := "E"
                     Case mv_par01 == 2  // Importacao
                        cTpFilt := "I"
                     Case mv_par01 == 3  // Ambos
                        cTpFilt := "E/I"
                  End Case
               EndIf
               //**
               SQL_FilS2:=""
               SQL_FilS:=""
               
               //preenche string com o filtro selecionado
               Str_perg:=""
               If lEFFTpMod  // PLB 15/05/06
                  if !empty(mv_par03) .and. !empty(mv_par04)
                      str_perg:=STR0035+dtoc(mv_par03)+" - "+dtoc(mv_par04)
                  endif
                  if !empty(mv_par05)
                      str_perg:=STR0036+mv_par05
                  endif
               Else
                  if !empty(mv_par01) .and. !empty(mv_par02)
                      str_perg:=STR0035+dtoc(mv_par01)+" - "+dtoc(mv_par02)
                  endif
                  if !empty(mv_par03)
                      str_perg:=STR0036+mv_par03
                  endif
               EndIf
               //str_perg:=IIF(mv_par04==1,'A Pagar','a Receber ')
               
               /*
               if !empty(mv_par04)
                   str_perg:=STR0037+mv_par04
               endif
                */
               
               for ni:=1 to len(afilSel)
                   SQL_FilS+=iif(!empty(SQL_FilS),",","")+"'"+afilSel[ni]+"'" 
               next
//             if (len(afilEEC)==1 .and. alltrim(afilEEC[1])=="",aFil[1],cfilSel[nfil]) 
               if len(afilEEC)==1 .and. alltrim(afilEEC[1])=="" 
                  SQL_FilS2:="'"+xfilial("EEC")+"'"
               else
                  SQL_FilS2:=SQL_FilS
               endif

               Adata:={}
               If lEFFTpMod  // PLB 16/05/06
                  Aadd(Adata,{"TPMODU","C",1,0})   //TIPO MODULO
                  Aadd(Adata,{"TP_CON",AVSX3("EEQ_TP_CON",2),AVSX3("EEQ_TP_CON",3),AVSX3("EEQ_TP_CON",4)})   //TIPO DO CONTRATO
               EndIf
               Aadd(Adata,{"EMPRESA","C",LEN(SM0->M0_NOME),0})   //EMPRESA     
               Aadd(Adata,{"FILIAL",AVSX3("EEQ_FILIAL",2),AVSX3("EEQ_FILIAL",3),AVSX3("EEQ_FILIAL",4)})   //FILIAL           
               Aadd(Adata,{"DFILIAL","C",60,0})   //NOME FILIAL           
               Aadd(Adata,{"CPAIS",AVSX3("YA_CODGI",2),AVSX3("YA_CODGI",3),AVSX3("YA_CODGI",4)})   //PAÍS
               Aadd(Adata,{"DPAIS",AVSX3("YA_DESCR",2),AVSX3("YA_DESCR",3),AVSX3("YA_DESCR",4)})   //DESC PAÍS               
               Aadd(Adata,{"VALORMOE",AVSX3("EEQ_VL",2),AVSX3("EEQ_VL",3),AVSX3("EEQ_VL",4)})   //VALOR NA MOEDA
               Aadd(Adata,{"MOEDA",AVSX3("EEQ_MOEDA",2),AVSX3("EEQ_MOEDA",3),AVSX3("EEQ_MOEDA",4)})   //MOEDA
               Aadd(Adata,{"VALORREA",AVSX3("EEQ_VL",2),AVSX3("EEQ_VL",3),AVSX3("EEQ_VL",4)})   //VALOR NA MOEDA           
               Aadd(Adata,{"SITUACAO","C",15,0})   //SITUACAO DA PARCELA-VENCIDOS /  À VENCER  
               Aadd(Adata,{"TEMPO","C",65,0})   //QUAL CATEGORIA DE TEMPO ESTAR A VENCER OU JÁ VENCEU
               Aadd(Adata,{"ORD","N",2,0})
                
               //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados
               WorkFile := E_CriaTrab(,Adata,"Work")
               //  PLB 17/05/06 - Cria indice para a work
               If lEFFTpMod
                  INDREGUA("Work",WorkFile+TEOrdBagExt(),"TPMODU+FILIAL")
                  Set Index To (WorkFile+TEOrdBagExt())
               EndIf
               MsAguarde({|| existReg := CRIA_WK()}, STR0001) //gera work  //processando dados
               if existReg
                  If lEFFTpMod  // PLB 15/05/06
                      If mv_par07==1  //destino impressora
                         MsAguarde({|| GERA_RPT()}, "Imprimindo registros...")
                      Elseif mv_par07==2 //destino arquivo
                         WORK_EXPORT(.F.)
                      Elseif mv_par07==3  //destino ms-excel
                         WORK_EXPORT(.T.)
                      Elseif mv_par07==4  //gerar grafico
                         GERA_GRAPH()
                      Endif
                  Else
                      If mv_par05==1  //destino impressora
                         MsAguarde({|| GERA_RPT()}, "Imprimindo registros...")
                      Elseif mv_par05==2 //destino arquivo
                         WORK_EXPORT(.F.)
                      Elseif mv_par05==3  //destino ms-excel
                         WORK_EXPORT(.T.)
                      Elseif mv_par05==4  //gerar grafico
                         GERA_GRAPH()
                      Endif
                  EndIf
               else
                  msgstop(STR0012) //"Não existem informações para esta consulta."
               endif
               If lEFFTpMod  // PLB 15/05/06
                  IF mv_par07#2 .and. mv_par07#3
                      Work->(dbclosearea())
                  endif
               Else
                  IF mv_par05#2 .and. mv_par05#3
                      Work->(dbclosearea())
                  endif
               EndIf
            Else
               Exit //sai do loop
            endif 
         else
            Exit //sai do loop
         Endif
      enddo
      
return .t.
                        
//Cria work com os dados processados Top/Codebase      
*---------------------------------------------------------------------------------------      
Static function CRIA_WK()   //Alcir Alves - 04-04-05                                                                                     
*---------------------------------------------------------------------------------------
Local i:=0
Local nDif:=0 //diferença de dias entre data de vencimento e data atual ou vice e versa
Local lRet:=.T.
Local AsqlQ:="",cPais:=""  //cArea:=cRegiao:= //MCF - 06/01/2015
Local cFillEEQ:=cFillEEC:=""
Local cQuery := ""
Local cTpCon := "", lFirstQuery := .T.
   //** PLB 16/05/06
   If lEFFTpMod  
      If mv_par02 == 5  // Todos os contratos
         Do Case 
            Case mv_par01 == 1  // Exportacao
               cTpCon := "1/3"  // Cambio de Export. - Recebimento

            Case mv_par01 == 2  // Importacao
               cTpCon := "2/4"  // Cambio de Import. - Remessa

            Case mv_par01 == 3  // Ambos
               cTpCon := "1/2/3/4"  // Todos os contratos

         End Case
      Else
         cTpCon := AllTrim(Str(mv_par02))
      EndIf
   Else
      cTpCon := "1"
   EndIf
   //**
         If lTop=.T.    //topconnect
           If "1" $ cTpCon
              lFirstQuery := .F.
              If lEFFTpMod  // PLB 15/05/06
                 If !Empty(mv_par03) .and. !Empty(mv_par04)
                    AsqlQ:=" and EEC.EEC_DTEMBA>='"+(dtos(mv_par03))+"' and EEC.EEC_DTEMBA<='"+(dtos(mv_par04))+"'"
                 endif
              Else
                 if !empty(mv_par01) .and. !empty(mv_par02)
                    AsqlQ:=" and EEC.EEC_DTEMBA>='"+(dtos(mv_par01))+"' and EEC.EEC_DTEMBA<='"+(dtos(mv_par02))+"'"
                 endif
              EndIf
              cQuery:="SELECT EEC.EEC_FILIAL AS EEQ_FILIAL,EEC.EEC_PREEMB,EEQ.EEQ_VCT,EEQ.EEQ_VL,EEQ.EEQ_MOEDA,SA1.A1_PAIS "+;
              IIF(lEFFTpMod," ,EEQ.EEQ_TP_CON ","")+;  // PLB 16/05/06
              "from "+RetSqlName("EEQ")+" EEQ ,"+RetSqlName("EEC")+" EEC,"+RetSqlName("SA1")+" SA1 "+;
              " WHERE  EEQ.EEQ_FILIAL IN("+SQL_FilS+") AND (EEQ.EEQ_PGT='"+SPACE(8)+"' OR EEQ.EEQ_PGT='') and"+;
              " EEQ.EEQ_TIPO='"+IIF(IIF(lEFFTpMod,mv_par06,mv_par04)==1,'P','R') +"'" +;
              IIF(lEFFTpMod," AND EEQ.EEQ_TP_CON='1' ","")+" AND SA1.A1_FILIAL='"+xFilial("SA1")+"' "+;
              " AND EEC.EEC_PREEMB=EEQ.EEQ_PREEMB AND EEC.EEC_FILIAL=EEQ.EEQ_FILIAL AND SA1.A1_COD=EEC.EEC_IMPORT"+;
              " AND "+IIF(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_<>'*'","EEQ.@DELETED@<>'*'")+;
              " AND "+IIF(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_<>'*'","EEC.@DELETED@<>'*'")+;
              " AND "+IIF(TcSrvType()<>"AS/400","SA1.D_E_L_E_T_<>'*'","SA1.@DELETED@<>'*'")+AsqlQ
           EndIf
           //** PLB 16/05/06 - Inclusao da nova estrutura e filtros: Tipo do Contrato e Tipo do Modulo
           If lEFFTpMod
              If "2" $ cTpCon   // Cambio de Importacao
                 If !Empty(mv_par03) .and. !Empty(mv_par04)
                    AsqlQ:=" AND SW6.W6_DT_EMB>='"+(dtos(mv_par03))+"' and SW6.W6_DT_EMB<='"+(dtos(mv_par04))+"'"
                 Endif
                 If lFirstQuery
                    lFirstQuery := .F.
                 Else
                    cQuery+=" UNION "
                 EndIf
                 cQuery+="SELECT SW6.W6_FILIAL AS EEQ_FILIAL,SW6.W6_HAWB AS EEC_PREEMB,SWB.WB_DT_VEN AS EEQ_VCT,"+;
                 "SWB.WB_FOBMOE AS EEQ_VL,SWB.WB_MOEDA AS EEQ_MOEDA,SA2.A2_PAIS AS A1_PAIS "+;
                 " ,SWB.WB_TP_CON AS EEQ_TP_CON"+;
                 " from "+RetSqlName("SWB")+" SWB ,"+RetSqlName("SW6")+" SW6,"+RetSqlName("SA2")+" SA2 "+;
                 " WHERE  SWB.WB_FILIAL IN("+SQL_FilS+") AND (SWB.WB_CA_DT='"+SPACE(8)+"' OR SWB.WB_CA_DT='')"+;
                 " and SWB.WB_TIPOC='"+IIF(mv_par06==1,'P','R') +"' AND SWB.WB_TP_CON='2' "+" AND SA2.A2_FILIAL='"+xFilial("SA2")+"' "+;
                 " AND SW6.W6_HAWB=SWB.WB_HAWB AND SW6.W6_FILIAL=SWB.WB_FILIAL AND SA2.A2_COD=SWB.WB_FORN"+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SWB.D_E_L_E_T_<>'*'","SWB.@DELETED@<>'*'")+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SW6.D_E_L_E_T_<>'*'","SW6.@DELETED@<>'*'")+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SA2.D_E_L_E_T_<>'*'","SA2.@DELETED@<>'*'")+AsqlQ
              EndIf
              If "3" $ cTpCon   // Recebimento
                 If !Empty(mv_par03) .and. !Empty(mv_par04)
                    AsqlQ:=" and EEQ.EEQ_VCT>='"+(dtos(mv_par03))+"' and EEQ.EEQ_VCT<='"+(dtos(mv_par04))+"'"
                 endif
                 If lFirstQuery
                    lFirstQuery := .F.
                 Else
                    cQuery+=" UNION "
                 EndIf
                 cQuery+="SELECT EEQ.EEQ_FILIAL,EEQ.EEQ_PREEMB,EEQ.EEQ_VCT,EEQ.EEQ_VL,EEQ.EEQ_MOEDA,SA1.A1_PAIS "+;
                 " ,EEQ.EEQ_TP_CON "+;
                 " from "+RetSqlName("EEQ")+" EEQ ,"+RetSqlName("SA1")+" SA1 "+;
                 " WHERE  EEQ.EEQ_FILIAL IN("+SQL_FilS+") AND (EEQ.EEQ_PGT='"+SPACE(8)+"' OR EEQ.EEQ_PGT='')"+;
                 " and EEQ.EEQ_TIPO='"+IIF(mv_par06==1,'P','R') +"' AND EEQ.EEQ_TP_CON='3' "+;
                 " AND SA1.A1_COD=EEQ.EEQ_IMPORT"+" and SA1.A1_FILIAL='"+xFilial("SA1")+"' "+;
                 " AND "+IIF(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_<>'*'","EEQ.@DELETED@<>'*'")+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SA1.D_E_L_E_T_<>'*'","SA1.@DELETED@<>'*'")+AsqlQ
                 If !Empty(mv_par03) .and. !Empty(mv_par04)
                    AsqlQ:=" AND SWB.WB_DT_VEN>='"+(dtos(mv_par03))+"' and SWB.WB_DT_VEN<='"+(dtos(mv_par04))+"'"
                 Endif
                 cQuery+=" UNION SELECT SWB.WB_FILIAL AS EEQ_FILIAL,SWB.WB_HAWB AS EEC_PREEMB,SWB.WB_DT_VEN AS EEQ_VCT,"+;
                 "SWB.WB_FOBMOE AS EEQ_VL,SWB.WB_MOEDA AS EEQ_MOEDA,SA2.A2_PAIS AS A1_PAIS "+;
                 " ,SWB.WB_TP_CON AS EEQ_TP_CON"+;
                 " from "+RetSqlName("SWB")+" SWB ,"+RetSqlName("SA2")+" SA2 "+;
                 " WHERE  SWB.WB_FILIAL IN("+SQL_FilS+") AND (SWB.WB_CA_DT='"+SPACE(8)+"' OR SWB.WB_CA_DT='')"+;
                 " and SWB.WB_TIPOC='"+IIF(mv_par06==1,'P','R') +"' AND SWB.WB_TP_CON='3' "+;
                 " AND SA2.A2_COD=SWB.WB_FORN"+" AND SA2.A2_FILIAL='"+xFilial("SA2")+"' "+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SWB.D_E_L_E_T_<>'*'","SWB.@DELETED@<>'*'")+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SA2.D_E_L_E_T_<>'*'","SA2.@DELETED@<>'*'")+AsqlQ
              EndIf
              If "4" $ cTpCon   // Remessa
                 If !Empty(mv_par03) .and. !Empty(mv_par04)
                    AsqlQ:=" and EEQ.EEQ_VCT>='"+(dtos(mv_par03))+"' and EEQ.EEQ_VCT<='"+(dtos(mv_par04))+"'"
                 endif
                 If lFirstQuery
                    lFirstQuery := .F.
                 Else
                    cQuery+=" UNION "
                 EndIf
                 cQuery+="SELECT EEQ.EEQ_FILIAL,EEQ.EEQ_PREEMB,EEQ.EEQ_VCT,EEQ.EEQ_VL,EEQ.EEQ_MOEDA,SA2.A2_PAIS AS A1_PAIS "+;
                 " ,EEQ.EEQ_TP_CON "+;
                 " from "+RetSqlName("EEQ")+" EEQ ,"+RetSqlName("SA2")+" SA2 "+;
                 " WHERE  EEQ.EEQ_FILIAL IN("+SQL_FilS+") AND (EEQ.EEQ_PGT='"+SPACE(8)+"' OR EEQ.EEQ_PGT='')"+;
                 " AND EEQ.EEQ_TIPO='"+IIF(mv_par06==1,'P','R') +"' AND EEQ.EEQ_TP_CON='4' "+;
                 " AND SA2.A2_COD=EEQ.EEQ_FORN"+" AND SA2.A2_FILIAL='"+xFilial("SA2")+"' "+;
                 " AND "+IIF(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_<>'*'","EEQ.@DELETED@<>'*'")+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SA2.D_E_L_E_T_<>'*'","SA2.@DELETED@<>'*'")+AsqlQ
                 If !Empty(mv_par03) .and. !Empty(mv_par04)
                    AsqlQ:=" AND SWB.WB_DT_VEN>='"+(dtos(mv_par03))+"' and SWB.WB_DT_VEN<='"+(dtos(mv_par04))+"'"
                 Endif
                 cQuery+=" UNION SELECT SWB.WB_FILIAL AS EEQ_FILIAL,SWB.WB_HAWB AS EEC_PREEMB,SWB.WB_DT_VEN AS EEQ_VCT,"+;
                 "SWB.WB_FOBMOE AS EEQ_VL,SWB.WB_MOEDA AS EEQ_MOEDA,SA2.A2_PAIS AS A1_PAIS "+;
                 " ,SWB.WB_TP_CON AS EEQ_TP_CON"+;
                 " from "+RetSqlName("SWB")+" SWB ,"+RetSqlName("SA2")+" SA2 "+;
                 " WHERE  SWB.WB_FILIAL IN("+SQL_FilS+") AND (SWB.WB_CA_DT='"+SPACE(8)+"' OR SWB.WB_CA_DT='')"+;
                 " and SWB.WB_TIPOC='"+IIF(mv_par06==1,'P','R') +"' AND SWB.WB_TP_CON='4' "+;
                 " AND SA2.A2_COD=SWB.WB_FORN"+" AND SA2.A2_FILIAL='"+xFilial("SA2")+"' "+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SWB.D_E_L_E_T_<>'*'","SWB.@DELETED@<>'*'")+;
                 " AND "+IIF(TcSrvType()<>"AS/400","SA2.D_E_L_E_T_<>'*'","SA2.@DELETED@<>'*'")+AsqlQ
              EndIf
           EndIf
           //**
              If cTpCon == "2"
                 cQuery+=" ORDER BY W6_FILIAL"
              Else
                 cQuery+=" ORDER BY EEQ_FILIAL"
              EndIf
              cQuery:=ChangeQuery(cQuery)
              TcQuery cQuery ALIAS "QUERY01" NEW
              TCSetField( "QUERY01", "EEC_DTEMBA", "D", 8, 0 )
              TCSetField( "QUERY01", "EEQ_VCT", "D", 8, 0 )
              do while !QUERY01->(EOF())
                  If lEFFTpMod  // PLB 15/05/06
                     If !Empty(mv_par05) .And. QUERY01->A1_PAIS#mv_par05
                         Query01->(dbskip())
                         loop
                     endif
                  Else
                     if !empty(mv_par03) .and. QUERY01->A1_PAIS#mv_par03
                         Query01->(dbskip())
                         loop
                     endif
                  EndIf
                  /*
                  cArea:=POSICIONE("SYA",1,XFILIAL("SYA")+QUERY01->A1_PAIS,"YA_AREA") 
                  
                  If !empty(mv_par04) .and. cArea#mv_par04
                      Query01->(dbskip())
                      loop
                  endif
                  */
                  work->(dbappend())
                  If lEFFTpMod  // PLB 16/05/06
                     Work->TPMODU:=IIF(Query01->EEQ_TP_CON $ "1/3","E","I")
                     Work->TP_CON:=Query01->EEQ_TP_CON
                  EndIf
                  work->EMPRESA:=SM0->M0_NOME
                  work->FILIAL:=QUERY01->EEQ_FILIAL 
                  work->DFILIAL:=AvgFilName({QUERY01->EEQ_FILIAL})[1] 
                  if !empty(IIF(lEFFTpMod,mv_par05,mv_par03))
                      work->CPAIS:=QUERY01->A1_PAIS
                      work->DPAIS:=POSICIONE("SYA",1,XFILIAL("SYA")+work->CPAIS,"YA_DESCR") 
                  else
                     work->CPAIS:=""
                     work->DPAIS:=STR0013
                  endif
                  /*
                  if !empty(mv_par04)   
                      //work->REGIAO:= 
                      //work->DREGIAO:=          
                  else
                      work->REGIAO:="" 
                      work->DREGIAO:= STR0013                           
                  endif
                  */
                  /*
                  if !empty(mv_par04)                  
                     work->AREA:=cArea
                     work->DAREA:=POSICIONE("EZ3",1,XFILIAL("EZ3")+work->AREA,"EZ3_DESC") 
                  else
                     work->AREA:=""
                     work->DAREA:=STR0013
                  endif
                  */
                  //work->DTEMBA:=QUERY01->EEC_DTEMBA
                  work->VALORMOE:=QUERY01->EEQ_VL 
                  work->MOEDA:=QUERY01->EEQ_MOEDA
                  //valor em real
                  if ALLTRIM(upper(work->MOEDA))<>"R$"
                      work->VALORREA:=QUERY01->EEQ_VL*BuscaTaxa(QUERY01->EEQ_MOEDA,dDatabase,,.f.,.T.,,"1") 
                  else
                      work->VALORREA:=QUERY01->EEQ_VL
                  endif
                  nDif:=0
                  //situação da parcela
                  IF DTOS(QUERY01->EEQ_VCT)>=DTOS(dDatabase)
                      work->SITUACAO:=STR0002 //a vencer
                      nDif:=QUERY01->EEQ_VCT-dDatabase
                  ELSE 
                      work->SITUACAO:=STR0003 //vencido
                      nDif:=dDatabase-QUERY01->EEQ_VCT
                      //status do tempo de dias vencidos ou a vencer
                  ENDIF
                  if nDif>=0 .and. nDif<=30
                      work->TEMPO:=STR0004    //"0 à 30 dias"
                      Work->ORD := 1  // PLB 16/05/06
                  elseif nDif>=31 .and. nDif<=60
                      work->TEMPO:=STR0005    //"31 à 60 dias"
                      Work->ORD := 2  // PLB 16/05/06
                  elseif nDif>=61 .and. nDif<=90
                      work->TEMPO:=STR0006   //"61 à 90 dias"
                      Work->ORD := 3  // PLB 16/05/06
                  elseif nDif>=91 .and. nDif<=120
                      work->TEMPO:=STR0007   //"91 à 120 dias"                                             
                      Work->ORD := 4  // PLB 16/05/06
                  elseif nDif>=121 .and. nDif<=150
                      work->TEMPO:=STR0008   //"121 à 150 dias"                                             
                      Work->ORD := 5  // PLB 16/05/06
                  elseif nDif>=151 .and. nDif<=180
                      work->TEMPO:=STR0009   //"151 à 180 dias"                                             
                      Work->ORD := 6  // PLB 16/05/06
                  elseif nDif>=181 
                      work->TEMPO:=STR0010   //"Acima de 181 dias"                                             
                      Work->ORD := 7  // PLB 16/05/06
                  endif
                  QUERY01->(dbskip())         
              Enddo
              Query01->(dbclosearea())
         else //codebase
              EEQ->(DBSELECTAREA("EEQ"))
              EEQ->(DBSETORDER(1))
              EEC->(DBSETORDER(1))              
              for i=1 to len(afilSel)
                  cFillEEQ:=iif((len(afilSel)=1 .and. trim(afilSel[1])=""),xfilial("EEQ"),afilSel[i])
                  IF EEQ->(DBSEEK(cFillEEQ))
                       cFillEEC:=iif((len(afilEEC)=1 .and. trim(afilEEC[1])=""),xfilial("EEC"),afilSel[i])                  
                       do while !eeq->(eof()) .and. eeq->eeq_filial==cFillEEQ
                          IF !EMPTY(EEQ->EEQ_PGT)
                              EEQ->(dbskip())
                              loop
                          ENDIF
                          
                          IF EEC->(dbseek(cFilECC+EEQ->EEQ_PREEMB))  
                              If lEFFTpMod  // PLB 15/05/06
                                 If !Empty(mv_par03) .And. !Empty(mv_par04)
                                     If !(EEC->EEC_DTEMBA>=mv_par03 .AND. EEC->EEC_DTEMBA<=mv_par04)
                                         EEQ->(DBSkip())
                                         Loop
                                     EndIf
                                 EndIf
                                 If mv_par02 == 5 // Todos os Tipo de Contrato
                                    If mv_par01 == 1  // Exportacao
                                       If !( EEQ->EEQ_TP_CON $ "1/3")
                                          EEQ->( DBSkip() )
                                          Loop
                                       EndIf
                                    ElseIf mv_par01 == 2  // Importacao
                                       If !( EEQ->EEQ_TP_CON $ "2/4")
                                          EEQ->( DBSkip() )
                                          Loop
                                       EndIf
                                    EndIf
                                 ElseIf ! (EEQ->EEQ_TP_CON $ Str(mv_par02) )
                                    EEQ->( DBSkip() )
                                    Loop
                                 EndIf
                              Else   
                                 if !empty(mv_par01) .and. !empty(mv_par02)
                                     IF !(EEC->EEC_DTEMBA>=mv_par01 .AND. EEC->EEC_DTEMBA<=mv_par02)
                                         EEQ->(dbskip())
                                         loop
                                     ENDIF
                                 endif
                              EndIf
                              
                              cPais:=POSICIONE("SA1",1,XFILIAL("SA1")+EEC->EEC_EXPORT,"A1_PAIS") 
                              If lEFFTpMod  // PLB 15/05/06
                                 If !Empty(mv_par05) .And. cPais#mv_par05
                                     EEQ->( DBSkip() )
                                     Loop
                                 EndIf
                              Else
                                 if !empty(mv_par03) .and. cPais#mv_par03
                                     EEQ->(dbskip())
                                     loop
                                 endif
                              EndIf
                              /*
                              cArea:=POSICIONE("SYA",1,XFILIAL("SYA")+cPais,"YA_AREA") 
                              if !empty(mv_par04) .and. cArea#mv_par04
                                  EEQ->(dbskip())
                                  loop
                              endif
                              */
                              work->(dbappend())
                              If lEFFTpMod  // PLB 16/05/06
                                 Work->TPMODU:=IIF(EEQ->EEQ_TP_CON $ "1/3","E","I")
                                 Work->TP_CON:=EEQ->EEQ_TP_CON
                              EndIf
                              work->EMPRESA:=SM0->M0_NOME
                              work->FILIAL:=cFillEEQ
                              work->DFILIAL:=AvgFilName({cFillEEQ})[1] 
                              if !empty(IIF(lEFFTpMod,mv_par05,mv_par03))
                                  work->CPAIS:=cPais
                                  work->DPAIS:=POSICIONE("SYA",1,XFILIAL("SYA")+work->CPAIS,"YA_DESCR") 
                              else
                                  work->CPAIS:=""
                                  work->DPAIS:=STR0013
                              endif
                              /*
                              if !empty(mv_par04)   
                                  //work->REGIAO:= 
                                  //work->DREGIAO:=          
                              else
                                  work->REGIAO:="" 
                                  work->DREGIAO:= STR0013                           
                              endif
                              if !empty(mv_par04)                  
                                  work->AREA:=cArea
                                  work->DAREA:=POSICIONE("EZ3",1,XFILIAL("EZ3")+work->AREA,"EZ3_DESC") 
                              else
                                  work->AREA:=""
                                  work->DAREA:=STR0013
                              endif
                              */
                              //work->DTEMBA:=EEC->EEC_DTEMBA
                              work->VALORMOE:=EEQ->EEQ_VL 
                              work->MOEDA:=EEQ->EEQ_MOEDA
                              //valor em real
                              if ALLTRIM(upper(work->MOEDA))<>"R$"
                                   work->VALORREA:=EEQ->EEQ_VL*BuscaTaxa(EEQ->EEQ_MOEDA,dDatabase,,.f.,.T.,,"1")
                              else
                                   work->VALORREA:=EEQ->EEQ_VL
                              endif
                              nDif:=0
                              //situação da parcela
                              IF DTOS(EEQ->EEQ_VCT)>=DTOS(dDatabase)
                                   work->SITUACAO:=STR0002 //a vencer
                                   nDif:=EEQ->EEQ_VCT-dDatabase
                              ELSE 
                                   work->SITUACAO:=STR0003 //vencido
                                   nDif:=dDatabase-EEQ->EEQ_VCT
                                   //status do tempo de dias vencidos ou a vencer
                              ENDIF
                              if nDif>=0 .and. nDif<=30
                                   work->TEMPO:=STR0004    //"0 à 30 dias"
                                   Work->ORD := 1  // PLB 16/05/06
                              elseif nDif>=31 .and. nDif<=60
                                   work->TEMPO:=STR0005    //"31 à 60 dias"
                                   Work->ORD := 2  // PLB 16/05/06
                              elseif nDif>=61 .and. nDif<=90
                                   work->TEMPO:=STR0006   //"61 à 90 dias"
                                   Work->ORD := 3  // PLB 16/05/06
                              elseif nDif>=91 .and. nDif<=120
                                   work->TEMPO:=STR0007   //"91 à 120 dias"                                             
                                   Work->ORD := 4  // PLB 16/05/06
                              elseif nDif>=121 .and. nDif<=150
                                   work->TEMPO:=STR0008   //"121 à 150 dias"                                             
                                   Work->ORD := 5  // PLB 16/05/06
                              elseif nDif>=151 .and. nDif<=180
                                   work->TEMPO:=STR0009   //"151 à 180 dias"                                             
                                   Work->ORD := 6  // PLB 16/05/06
                              elseif nDif>=181 
                                   work->TEMPO:=STR0010   //"Acima de 181 dias"                                             
                                   Work->ORD := 7  // PLB 16/05/06
                              endif   
                          endif                  
                          eeq->(dbskip())  
                       enddo
                  ENDIF
              next
         endif
         if work->(EasyReccount("work")) <= 0 
            lRet:=.F.
         endif
return lRet


*---------------------------------------------------------------------------------------------------------------*
static Function GERA_RPT() //Alcir Alves - 05-04-05     //gera relatório para impressão em RPT
*---------------------------------------------------------------------------------------------------------------*
   Local cFilAtu:="-"
   Private cSeqRel
   
   If Select("HEADER_P") = 0
      E_ARQCRW(.T.,,.T.)
   EndIf
   //SetFil()
   cSEQREL := GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()
   If lEFFTpMod  // PLB 17/05/06
      Work->( DBSetOrder(1) )
   EndIf
   WORK->(DBGOTOP())
   Do while !work->(eof())
        If cFilAtu#work->FILIAL
           //CABEÇALHO
           HEADER_P->(dbAppend())
           HEADER_P->AVG_FILIAL := work->FILIAL
           HEADER_P->AVG_SEQREL := cSeqRel
           HEADER_P->AVG_C02_10 := cEmpAnt  
           HEADER_P->AVG_C01_60 := work->EMPRESA
           HEADER_P->AVG_C02_60 := work->DFILIAL
           HEADER_P->AVG_C03_60 := IIF(IIF(lEFFTpMod,mv_par06,mv_par04)==1,"A Pagar","A Receber")
           If lEFFTpMod  // PLB 16/05/06
              HEADER_P->AVG_C06_60 := IIF(mv_par02==5,"Todos",BSCXBOX("EEQ_TP_CON",AllTrim(Str(mv_par02))))
           EndIf
           HEADER_H->(dbAppend())
           AvReplace("HEADER_P","HEADER_H")
           cFilAtu:=work->FILIAL
        endif
        //DETALHES
        DETAIL_P->(dbAppend())
        //** PLB 16/05/06
        If lEFFTpMod
           DETAIL_P->AVG_C01_20 := IIF(Work->TPMODU=="E","Exportacao","Importacao")+Work->FILIAL
        Else
           DETAIL_P->AVG_C01_20 := "Exportacao"+Work->FILIAL
        EndIf
        //**
        DETAIL_P->AVG_FILIAL := work->FILIAL
        DETAIL_P->AVG_SEQREL := cSeqRel
        DETAIL_P->AVG_C01_60:=work->DPAIS
        //DETAIL_P->AVG_C02_60:=work->DREGIAO
        //DETAIL_P->AVG_C03_60:=work->DAREA

        DETAIL_P->AVG_N03_15:=work->VALORMOE
        DETAIL_P->AVG_N02_15:=work->VALORREA
        DETAIL_P->AVG_C05_10:=work->MOEDA
        DETAIL_P->AVG_C04_60:=work->SITUACAO
        DETAIL_P->AVG_C05_60:=work->TEMPO
        DETAIL_P->AVG_N04_15:=WORK->ORD  // PLB 15/05/06
        //Gravar Historico de Documentos DO DETALHE
        DETAIL_H->(dbAppend())
        AvReplace("DETAIL_P","DETAIL_H")
        work->(dbskip())
   enddo   
   E_HISTDOC(,STR0011,dDataBase,,,"EFFAL150.RPT",cSeqRel) //"Agin List"
   AvgCrw32("EFFAL150.RPT",STR0011)  //"Agin List"
Return .T.  

*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------
//   Local oExcelApp
   //Local cDirDocs := MsDocPath()
  // Local cPath	:= AllTrim(GetTempPath())
   DbSelectArea("Work")
   if lExcel
      AvExcel(WorkFile,"Work",.F.)
      Work->(dbCloseArea())
   Else
         TR350ARQUIVO("work")   
         Work->(dbCloseArea())
   EndIf
Return .T.


*---------------------------------------------------------------------------------------------------------------*
Static Function GERA_GRAPH() //cria área de seleção de tipo de gráfico           - 16-04-05
*---------------------------------------------------------------------------------------------------------------*
   Local oDlgSer,i:=0
   Local oSer,oCor,OcATEG
   Local cCbx := STR0018
   Local aCbx := { STR0015, STR0016, STR0017, STR0018}  //"Linha" "Área""Pontos""Barras"
   Local aCor := { STR0019,STR0020,STR0021}  //azul vermelho verde
   Local aCateg := { STR0033,STR0034}  //  "Parcelas a vencer"  "Parcelas vencidas"                
   Private nCbx := 4 //tipo de série
   Private nCor := STR0019 //tipo de cor
   Private nCateg := STR0033
   DEFINE MSDIALOG oDlgSer TITLE STR0022 FROM 0,0 TO 135,280 PIXEL OF oDlgSer //"Tipo do gráfico"
   @ 008, 005 SAY STR0023 PIXEL OF oDlgSer //"Escolha o tipo de série:"
   @ 008, 063 MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nCbx := oSer:nAt
   @ 020, 005 SAY STR0024 PIXEL OF oDlgSer //Cor do gráfico
   @ 020, 063 MSCOMBOBOX oCor VAR nCor ITEMS aCor SIZE 077, 120 OF oDlgSer PIXEL
   @ 035, 005 SAY STR0032 PIXEL OF oDlgSer //"Categoria de Parcelas: "
   @ 035, 063 MSCOMBOBOX oCateg VAR nCateg ITEMS aCateg SIZE 077, 120 OF oDlgSer PIXEL
   @ 050, 045 BUTTON "&Ok"  SIZE 30,12 OF oDlgSer PIXEL ACTION (MontaGrafico())
   @ 050, 075 BUTTON STR0025 SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End() //"&Sair"
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
   Local i:=0
   Local nPos:=0
   Local nx:=0
   local aFluxo:={}
   Local cTitulo:=""
   local ncor_fil   
   //adiciona escalas não existentes
    if (aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(upper(STR0004)) }))=0 //"0 à 30 dias"
       aadd(aFluxo,{SUBSTR(STR0004,1,LEN(STR0004)),0})            
    endif 
    if (aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(upper(STR0005)) }))=0 //"31 à 60 dias"
       aadd(aFluxo,{SUBSTR(STR0005,1,LEN(STR0004)),0})            
    endif 
    if (aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(upper(STR0006)) }))=0 //"61 à 90 dias"
       aadd(aFluxo,{SUBSTR(STR0006,1,LEN(STR0004)),0})            
    endif 
    if (aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(upper(STR0007)) }))=0 //"91 à 120 dias"
       aadd(aFluxo,{SUBSTR(STR0007,1,LEN(STR0004)),0})            
    endif 
    if (aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(upper(STR0008)) }))=0 //"121 à 150 dias"    
       aadd(aFluxo,{SUBSTR(STR0008,1,LEN(STR0004)),0})            
    endif       
    if (aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(upper(STR0009)) }))=0 //"151 à 180 dias"      
       aadd(aFluxo,{SUBSTR(STR0009,1,LEN(STR0004)),0})            
    endif       
    if (aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(upper(STR0010)) }))=0 //"Acima de 181 dias"     
       aadd(aFluxo,{SUBSTR(STR0010,1,LEN(STR0004)),0})            
    endif  
    
   work->(dbgotop())
   do while !(work->(EOF()))
      if nCateg==STR0033 //Parecelas a Vencer
         if work->SITUACAO#STR0002
             work->(dbskip())
             loop
         endif
      else //vencidas
         if work->SITUACAO#STR0003
             work->(dbskip())
             loop
         endif      
      endif

      nPos:=aScan(aFluxo,{|x| Upper(Alltrim(x[1])) == alltrim(SUBSTR(upper(work->TEMPO),1,LEN(STR0004)))}) 
      if nPos==0
         aadd(aFluxo,{work->TEMPO,work->VALORREA})        
      else
         aFluxo[nPos,2]+=work->VALORREA
      endif
      work->(dbskip())
   enddo

   //asort(aFluxo,,,{ |x,y| x[1]>y[1]}) 
   
   DEFINE MSDIALOG oDlg4 FROM 0,0 TO 450,700 PIXEL TITLE STR0026
   DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
  
   @ 010, 010 MSGRAPHIC oGraphic SIZE 325, 160 OF oDlg4 PIXEL
   oGraphic:SetMargins( 2, 6, 6, 6 )
   oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW,GRP_SERIES, .F.)  //GRP_VALUES
   if nCateg==STR0033 //Parcelas a Vencer
      cTitulo:=STR0026+" - "+STR0033+IIF(IIF(lEFFTpMod,mv_par06,mv_par04)==1,' - A Pagar',' - A Receber ') + " - R$"
   else
      cTitulo:=STR0026+" - "+STR0034+IIF(IIF(lEFFTpMod,mv_par06,mv_par04)==1,' - A Pagar',' - A Receber ') + " - R$"
   endif
   oGraphic:SetTitle( cTitulo,"", CLR_HRED , A_LEFTJUST , GRP_TITLE )
   nSerie:=oGraphic:CreateSerie(nCbx)
   oGraphic:l3D:=.F.
   oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
   if !empty(STR_PERG)
       oGraphic:SetTitle( STR_PERG, "", CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //Filtros
   endif

   if nCor==STR0019    //azul
       ncor_fil:=CLR_HBLUE 
   elseif nCor==STR0020  //vermelho
        ncor_fil:=CLR_HRED
   elseif nCor==STR0021
        ncor_fil:=CLR_HGREEN  //verde  
   endif    
      
   If nSerie != GRP_CREATE_ERR 
       for i:=1 to len(aFluxo)
           oGraphic:Add(nSerie,aFluxo[i,2],Transform(alltrim(aFluxo[i,1]),""),ncor_fil) 
       next
   Else                                                       
      msgstop(STR0031)
   Endif                                              
   @ 190, 254 BUTTON o3D PROMPT "&3D" SIZE 40,14 OF oDlg4 PIXEL ACTION (oGraphic:l3D := !oGraphic:l3D, o3d:cCaption := If(oGraphic:l3D, "&2D", "&3D"))
   @ 190, 295 BUTTON STR0027   SIZE 40,14 OF oDlg4 PIXEL ACTION GrafSavBmp( oGraphic ) //"&Salva BMP"
   @ 190, 170 BUTTON STR0028    SIZE 40,14 OF oDlg4 PIXEL ACTION oGraphic:ZoomIn() //zoom in
   @ 190, 212 BUTTON STR0029   SIZE 40,14 OF oDlg4 PIXEL ACTION oGraphic:ZoomOut()  //zomm out
   @ 207, 050 TO 209 ,400 LABEL '' OF oDlg4  PIXEL
   If !__lPyme
      	@ 213,254 BUTTON STR0030 SIZE 40,12 OF oDlg4 PIXEL ACTION PmsGrafMail(oGraphic,STR0026,,,1) // E-Mail
   Endif
   @ 213, 295 BUTTON STR0025 SIZE 40,12 OF oDlg4 PIXEL ACTION oDlg4:End() //"&Sair"
   ACTIVATE MSDIALOG oDlg4 CENTER
   RestArea(aArea)
Return .T.

Function AL150ValPerg(cFiltro)
 Local lRet := .T.

   Do Case

      Case cFiltro == "TpModu"
         mv_par02 := 5  // Todos os contratos
         If mv_par01 == 1  // Exportacao
            mv_par06 := 2  // A receber
         ElseIf mv_par01 == 2  // Importacao
            mv_par06 := 1  // A pagar
         ElseIf mv_par01 != 3
            lRet := .F.
         EndIf

      Case cFiltro == "TpCont"
         If mv_par02 == 1 .Or. mv_par02 == 3  // Cambio Exportacao .Or. Recebimento
            IIF(mv_par01==2,mv_par01:=3,)  // Ambos
            IIF(mv_par06==1,mv_par06:=2,)  // A receber
         ElseIf mv_par02 == 2  .Or. mv_par02 == 4  // Cambio Importacao .Or. Remessa
            IIF(mv_par01==1,mv_par01:=3,)  // Ambos
            IIF(mv_par06==2,mv_par06:=1,)  // A pagar
         EndIf

      Case cFiltro == "TpCamb"
         If mv_par06 == 1  // A pagar
            IIF(mv_par01==1,mv_par01:=3,)  //Ambos
            IIF(mv_par02==1 .Or. mv_par02==3,mv_par02:=5,)  //Todos os contratos
         ElseIf mv_par06 == 2  // A receber
            IIF(mv_par01==2,mv_par01:=3,)  //Ambos
            IIF(mv_par02==2 .Or. mv_par02==4,mv_par02:=5,)  //Todos os contratos
         EndIf
      
   End Case

Return lRet
