// Programador : Alcir Alves
// Data Desenvolvimento- 31-01-05  
// Objetivo - Relatório de desconto de demurrage
// PRW : AVGDE150  
//Versão Codebase e Topconnect

#INCLUDE "AVGDE150.CH"                 
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"                 
*// Função principal de acesso ao menu       - Alcir Alves Alcir$
*---------------------------------------------------------------------------------------
FUNCTION AVGDE150() // 31-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   PRIVATE afilSel:={},lTop
   PRIVATE aReturn:= {"Zebrado",1,"", 2, 1, 1, "", 1}
   Private nLin:=0,M_pAg:=1,Is_MFill:=.T.,nRegSint:={},nTotTime:={},nTimeUsed:=0  //caso seja multifilial
   Private cFiltro:="",cFiltro_Str:="" //validação com os filtros do pergunte
   Private cNomArq:="worki"+TEOrdBagExt(),WorkFile:="",cModulo:=iif(nModulo==17,"I","E")
   Private aDados:={} 
   PRIVATE lExistDM := if (EG0->( FieldPos( "EG0_DEMURR" ) ) > 0 .AND. EG1->( FieldPos( "EG1_DEMURR" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_NRINVO" ) ) > 0 .AND. EG1->( FieldPos( "EG1_PEDIDO" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_SEQUEN" ) ) > 0 .AND. EG1->( FieldPos( "EG1_COD_I" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_QTDUC" ) ) > 0  .AND. EG1->( FieldPos( "EG1_QTDMT" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_UNMED" ) ) > 0  .AND. EG1->( FieldPos( "EG1_COEF" ) ) > 0 ;
        .AND. EG2->( FieldPos( "EG2_DEMURR" ) ) > 0  ,.T.,.F.)

   #IFDEF TOP
     lTop := .T.
   #ElSE
     lTop := .F.
   #ENDIF  
   // lTop := .F.    

   afilSel:=AvgSelectFil(.T.,"EG0") //Alcir - conceito multifilial
   //caso o EG0 seja compartilhado
   if len(afilSel)==1 .and. alltrim(afilSel[1])==""
      Is_MFill:=.F.
   endif
   
   IF Pergunte("AVGDES",.T.)
          Adados:= {"",;
                   "",; 
                   "",; 
                   "2",;
                   "G",;
                    220,;
                    IIF(mv_par12==1,STR0041,STR0008),; 
                   "",;
                   (STR0001+" - "+IIF(mv_par12==1,STR0039,STR0040)),; 
                   { "Zebrado", 1,"Contabil", 1, 2, 1, "",1 },;
                   "AVGDE150",;             
                    }


       
       Processa({||AVGDEWORK()})
       IF WORK->(EasyRecCount("WORK"))>0
          if mv_par11==1  //Caso destino seja impressora
              wnrel:=SetPrint("WORK","AVGDE150",,STR0001,"","","",.F.,.F.,.F.,"G")
              If lastkey()#27 .and. nlastkey!=27
                 SetDefault(aReturn,"WORK")
                 RptStatus({|lEnd| AVGDER_BD()})
                 OurSpool(wnrel)
              Endif
          else //Caso destino seja texto ou excel
                WORK_EXPORT(iif(mv_par11==2,.f.,.t.))
                return .t.
          endif
       ELSE
           Msgstop(STR0002) //"Não existe dados para esta consulta"	
       ENDIF
       WORK->(DBCLOSEAREA())
   ENDIF
   IF file(cNomArq)
      Ferase(cNomArq) 
   ENDIF
RETURN .T.


*// Função que cria a work
*---------------------------------------------------------------------------------------
STATIC FUNCTION AVGDEWORK() // 17-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
    Local Adata,i:=0,cWhile1:="",cWhile2:="",cWhile3:="" //caso o os filtros de produtos ou embarque estejam preenchidos esta variavel retorna false se não encontrar nenhum registro compativel
    Local cfilEG0:=xfilial("EG0"),cFilEG1:=xfilial("EG1"),cfilEG2:=xfilial("EG2") //Alcir - conceito multifilial
    Local Prod_t:="",Qtd_mt:=0,cEncontrou:=.t.,cCond1:=""

    EG0->(DBSETORDER(1))
    EG1->(DBSETORDER(1))    

    Adata:= {}
    Aadd(Adata,{"WK_DEMURR",AVSX3("EG0_DEMURR",2),AVSX3("EG0_DEMURR",3),AVSX3("EG0_DEMURR",4)}) //DEMURRAGE
    Aadd(Adata,{"WK_FILIAL",AVSX3("EG0_FILIAL",2),AVSX3("EG0_FILIAL",3),AVSX3("EG0_FILIAL",4)}) //FILIAL
    Aadd(Adata,{"WK_VESSEL",AVSX3("EG0_NAVIO",2),AVSX3("EG0_NAVIO",3),AVSX3("EG0_NAVIO",4)}) //NAVIO
    Aadd(Adata,{"WK_VIAGEM",AVSX3("EG0_VIAGEM",2),AVSX3("EG0_VIAGEM",3),AVSX3("EG0_VIAGEM",4)}) //VIAGEM
    Aadd(Adata,{"WK_PORTO",AVSX3("EG0_DEST",2),AVSX3("EG0_DEST",3),AVSX3("EG0_DEST",4)}) //DESTINO
    Aadd(Adata,{"WK_OWNER",AVSX3("EG0_FORNEC",2),AVSX3("EG0_FORNEC",3),AVSX3("EG0_FORNEC",4)}) //ARMADOR/fornecedor
    Aadd(Adata,{"WK_CLIENT",AVSX3("EG0_CLIENT",2),AVSX3("EG0_CLIENT",3),AVSX3("EG0_CLIENT",4)}) //Cliente
    Aadd(Adata,{"WK_MODULO","C",1,0}) //MODULO
    Aadd(Adata,{"WK_PROD","C",30,0})
    Aadd(Adata,{"WK_QTDMT",AVSX3("EG1_QTDMT",2),AVSX3("EG1_QTDMT",3),AVSX3("EG1_QTDMT",4)}) //QTD MT
    Aadd(Adata,{"WK_PARC_C",AVSX3("EG0_PARC_C",2),AVSX3("EG0_PARC_C",3),AVSX3("EG0_PARC_C",4)}) //Parcel cargo      
    Aadd(Adata,{"WK_OBS",AVSX3("EG2_CODMEN",2),AVSX3("EG2_CODMEN",3),AVSX3("EG2_CODMEN",4)}) //Obs padrao
    Aadd(Adata,{"WK_TPD",AVSX3("EG2_TP_LD",2),AVSX3("EG2_TP_LD",3),AVSX3("EG2_TP_LD",4)}) //Tipo Carga / Descarga
    Aadd(Adata,{"WK_DATA",AVSX3("EG2_DATA",2),AVSX3("EG2_DATA",3),AVSX3("EG2_DATA",4)}) //DATA    
    Aadd(Adata,{"WK_TFROM",AVSX3("EG2_FROM",2),AVSX3("EG2_FROM",3),AVSX3("EG2_FROM",4)}) //TIME FROM
    Aadd(Adata,{"WK_TTO",AVSX3("EG2_TO",2),AVSX3("EG2_TO",3),AVSX3("EG2_TO",4)}) //TIME TO
    Aadd(Adata,{"WK_TUSEDIT",AVSX3("EG2_TIMEUS",2),AVSX3("EG2_TIMEUS",3),AVSX3("EG2_TIMEUS",4)}) //TIME USED POR EG2
    Aadd(Adata,{"WK_VAL_DEM",AVSX3("EG0_OW_VL",2),AVSX3("EG0_OW_VL",3),AVSX3("EG0_OW_VL",4)}) //VALOR DO DEMURRAGE
    Aadd(Adata,{"WK_DEM_RAT",AVSX3("EG0_DEM_V",2),AVSX3("EG0_DEM_V",3),AVSX3("EG0_DEM_V",4)}) //DEMURRAGE RATE
    Aadd(Adata,{"WK_DES_RAT",AVSX3("EG0_DES_V",2),AVSX3("EG0_DES_V",3),AVSX3("EG0_DES_V",4)}) //DESPATCH RATE
    Aadd(Adata,{"WK_RATLDHD",AVSX3("EG0_RAT_HD",2),AVSX3("EG0_RAT_HD",3),AVSX3("EG0_RAT_HD",4)}) //RATE L/D  H/D     
    Aadd(Adata,{"WK_PRANCHA",AVSX3("EG0_PARC_C",2),AVSX3("EG0_PARC_C",3),AVSX3("EG0_PARC_C",4)}) //PRANCHA
    Aadd(Adata,{"WK_TUSED",AVSX3("EG0_USED",2),AVSX3("EG0_USED",3),AVSX3("EG0_USED",4)}) //TEMPO USADO

    WorkFile := E_CriaTrab(,Adata,"Work") //THTS - 28/09/2017 - TE-6431 - Temporario no Banco de Dados

    IF mv_par12==1 //caso sintético
        IndRegua("Work",cNomArq,"WK_FILIAL+WK_MODULO+WK_DEMURR+WK_OBS+WK_TPD+DTOC(WK_DATA)")    
    ELSE          //caso analítico   
        IndRegua("Work",cNomArq,"WK_FILIAL+WK_MODULO+WK_DEMURR+WK_OBS+DTOC(WK_DATA)+WK_TFROM")
    ENDIF


//  //Alcir - conceito multifilial
//  //Alcir - conceito multifilial
//  //Cria code block com a avaliação dos filtros do pergunte

    IF !lTop 
        //caso codebase
        cFiltro:=" EG0->(EOF())==.F. "+;
        iif(mv_par01#1,iif(mv_par01==2," .AND. EMPTY(EG0->EG0_CLIENT)"," .and. !EMPTY(EG0->EG0_CLIENT)"),"")+; //ARMADOR
        iif(!EMPTY(mv_par03)," .AND. EG2->EG2_CODMEN==AVKEY(mv_par03,'EG2_CODMEN')","")+; //OBS PADR
        iif(!EMPTY(mv_par04)," .AND. EG0->EG0_NAVIO==AVKEY(mv_par04,'EG0_NAVIO')","")+; //navio
        iif(!EMPTY(mv_par05)," .AND. EG0->EG0_VIAGEM==AVKEY(mv_par05,'EG0_VIAGEM')","")+; //viagem                                   
        iif(!EMPTY(mv_par06)," .AND. EG0->EG0_DEST==AVKEY(mv_par06,'EG0_DEST')","")+; //PORTO destino
        iif(mv_par07>0," .AND. EG0->EG0_PARC_C>=mv_par07","")+; //RANGE PARCEL CARGO
        iif(mv_par08>0," .AND. EG0->EG0_PARC_C<=mv_par08","")+; //RANGE PARCEL CARGO
        iif(mv_par09#1,iif(mv_par09==2," .AND. EG2->EG2_TP_LD=='1'"," .AND. EG2->EG2_TP_LD=='2'"),"")+; // CARGA / DESCARGA
        iif(mv_par10#1,iif(mv_par10==2," .AND. EG0->EG0_RAT_HD=='1'"," .AND. EG0->EG0_RAT_HD=='2'"),"") // hora/dia
    ELSE  
        cFiltro:=" WK_EG0->(EOF())==.F. "+;
        iif(mv_par01#1,iif(mv_par01==2," .AND. EMPTY(WK_EG0->EG0_CLIENT)"," .and. !EMPTY(WK_EG0->EG0_CLIENT)"),"")+; //ARMADOR
        iif(!EMPTY(mv_par03)," .AND. WK_EG2->EG2_CODMEN==AVKEY(mv_par03,'EG2_CODMEN')","")+; //OBS PADRAO
        iif(!EMPTY(mv_par04)," .AND. WK_EG0->EG0_NAVIO==AVKEY(mv_par04,'EG0_NAVIO')","")+; //navio
        iif(!EMPTY(mv_par05)," .AND. WK_EG0->EG0_VIAGEM==AVKEY(mv_par05,'EG0_VIAGEM')","")+; //viagem
        iif(!EMPTY(mv_par06)," .AND. WK_EG0->EG0_DEST==AVKEY(mv_par06,'EG0_DEST')","")+; //PORTO destino
        iif(mv_par07>0," .AND. WK_EG0->EG0_PARC_C>=mv_par07","")+; //RANGE PARCEL CARGO
        iif(mv_par08>0," .AND. WK_EG0->EG0_PARC_C<=mv_par08","")+; //RANGE PARCEL CARGO
        iif(mv_par09#1,iif(mv_par09==2," .AND. WK_EG2->EG2_TP_LD=='1'","  .AND. WK_EG2->EG2_TP_LD=='2'"),"")+; // CARGA / DESCARGA
        iif(mv_par10#1,iif(mv_par10==2," .AND. WK_EG0->EG0_RAT_HD=='1'"," .AND. WK_EG0->EG0_RAT_HD=='2'"),"") // hora/dia
    ENDIF
    cFiltro:="("+cFiltro+")"
  
    //String com os campos filtrados
    cFiltro_Str:=iif(mv_par01#1,STR0029+iif(mv_par01==2,STR0004,STR0005)+"   ","")+;
                 iif(empty(mv_par02),"",STR0005+": "+mv_par02+"   ")+;
                 iif(empty(mv_par03),"",STR0025+": "+mv_par03+"   ")+;
                 iif(empty(mv_par04),"",STR0012+": "+mv_par04+"   ")+;
                 iif(empty(mv_par05),"",STR0030+": "+mv_par05+"   ")+;
                 iif(empty(mv_par06),"",STR0031+": "+str(mv_par06)+"   ")+;
                 iif(empty(mv_par07),"",STR0032+ALLTRIM(str(mv_par07))+"   ")+; 
                 iif(empty(mv_par08),"",STR0033+ALLTRIM(str(mv_par08))+"   ")+; 
                 iif(mv_par09#1,STR0029+iif(mv_par09==2,STR0034,STR0035)+"   ","")+;
                 iif(mv_par10#1,STR0038+iif(mv_par10==2,STR0036,STR0037)+"   ","")


    FOR i:=1 TO LEN(afilSel) //Conceito multifilial 
        cfilEG0:=afilSel[i]
        cfilEG1:=iif(len(afilSel)==1 .and. alltrim(afilSel[1])=="",afilSel[1],afilSel[i]) //Alcir - conceito multifilial
        cfilEG2:=iif(len(afilSel)==1 .and. alltrim(afilSel[1])=="",afilSel[1],afilSel[i]) //Alcir - conceito multifilial        
        IF !lTop
           //Versão codebase
           EG0->(DBSEEK(cfilEG0+cModulo))
           cWhile1:={ || EG0->(EOF())==.F. .AND. EG0->EG0_MODULO=cModulo .AND. EG0->EG0_FILIAL=cfilEG0}
        ELSE
           cQuery:="SELECT * from "+RetSqlName("EG0")+" EG0 "+;
                   " WHERE EG0.EG0_FILIAL='"+cfilEG0+"' AND EG0.EG0_MODULO='"+cModulo+"' "+;
                   " AND "+IIF(TcSrvType()<>"AS/400","EG0.D_E_L_E_T_<>'*'","EG0.@DELETED@<>'*'")
            cQuery:=ChangeQuery(cQuery)
            TcQuery cQuery ALIAS "WK_EG0" NEW
            cWhile1:={ || WK_EG0->(EOF())==.F.}
        ENDIF
           
        DO WHILE EVAL(cWhile1) 
            //LOCALIZA AS HORAS DE DEMURRAGE NO EG2
            //BEGIMCOMM 01
            IF !lTop
                //Versão codebase
                EG2->(DBSEEK(cfilEG2+cModulo+EG0->EG0_DEMURR))
                cWhile2:={ || EG2->(EOF())==.F. .AND. EG2->EG2_FILIAL=cfilEG2 .AND. EG2->EG2_MODULO=cModulo .AND. EG2->EG2_DEMURR=EG0->EG0_DEMURR}
            ELSE
                cQuery:="SELECT * from "+RetSqlName("EG2")+" EG2 "+;
                " WHERE EG2.EG2_FILIAL='"+cfilEG2+"' AND EG2.EG2_MODULO='"+cModulo+"' "+;
                " AND EG2.EG2_DEMURR='"+WK_EG0->EG0_DEMURR+"' AND "+IIF(TcSrvType()<>"AS/400","EG2.D_E_L_E_T_<>'*'","EG2.@DELETED@<>'*'")
                cQuery:=ChangeQuery(cQuery)
                TcQuery cQuery ALIAS "WK_EG2" NEW
                TCSetField("WK_EG2", "EG2_DATA", "D", 8, 0 )
                cWhile2:={ || WK_EG2->(EOF())==.F.}
            ENDIF
            DO WHILE EVAL(cWhile2)    
                 IF &(cFiltro)  
                    WORK->(RECLOCK("WORK",.T.))
                    //LOCALIZA NO EG1 OS PRODUTOS E A SOMATORIA DA QTDMT
                    //BEGINCOMM 02
                    IF !lTop
                       //Versão codebase
                       EG1->(DBSEEK(cfilEG1+cModulo+EG0->EG0_DEMURR))
                       cWhile3:={ || EG1->(EOF())==.F. .AND. EG1->EG1_FILIAL=cfilEG1 .AND. EG1->EG1_MODULO=cModulo .AND. EG1->EG1_DEMURR=EG0->EG0_DEMURR}
                    ELSE
                       cQuery:="SELECT * from "+RetSqlName("EG1")+" EG1 "+;
                       " WHERE EG1.EG1_FILIAL='"+cfilEG1+"' AND EG1.EG1_MODULO='"+cModulo+"' "+;
                       " AND EG1.EG1_DEMURR='"+WK_EG0->EG0_DEMURR+"' AND "+IIF(TcSrvType()<>"AS/400","EG1.D_E_L_E_T_<>'*'","EG1.@DELETED@<>'*'")
                       cQuery:=ChangeQuery(cQuery)
                       TcQuery cQuery ALIAS "WK_EG1" NEW  
                       cWhile3:={ || WK_EG1->(EOF())==.F.}
                    ENDIF
                    Prod_t:=""
                    Qtd_mt:=0
                    
                    IF !empty(mv_par02) //FILTRO POR PRODUTO
                       IF !lTop
                            cCond1:={ || EG1->EG1_COD_I==AVKEY(mv_par02,"EG1_COD_I")}
                       ELSE
                            cCond1:={ || WK_EG1->EG1_COD_I==AVKEY(mv_par02,"EG1_COD_I")}                       
                       ENDIF
                       cEncontrou:=.F.
                    else
                       cCond1:={ || .T. }                       
                    ENDIF
                    
                    DO WHILE EVAL(cWhile3)
                        IF eval(cCond1)
                            cEncontrou:=.T.
                            Prod_t+=ALLTRIM(IIF(EMPTY(Prod_t),"","/")+IIF(!lTop,EG1->EG1_COD_I,WK_EG1->EG1_COD_I))
                            Qtd_mt+=IIF(!lTop,EG1->EG1_QTDMT,WK_EG1->EG1_QTDMT)
                            IF !lTop
                                EG1->(DBSKIP())
                            ELSE
                                WK_EG1->(DBSKIP())               
                            ENDIF   
                        ENDIF
                    ENDDO
                    WORK->WK_PROD:=Prod_t
                    WORK->WK_QTDMT:=Qtd_mt
                    IF lTop
                        WK_EG1->(DBCLOSEAREA())
                    ENDIF   
                    //ENDCOMM 02
                    
                    IF cEncontrou:=.T.
                       WORK->WK_FILIAL:=cfilEG0
                       WORK->WK_DEMURR:=IIF(!lTop,EG0->EG0_DEMURR,WK_EG0->EG0_DEMURR)
                       WORK->WK_VESSEL:=IIF(!lTop,EG0->EG0_NAVIO,WK_EG0->EG0_NAVIO)
                       WORK->WK_VIAGEM:=IIF(!lTop,EG0->EG0_VIAGEM,WK_EG0->EG0_VIAGEM)
                       WORK->WK_PORTO:=IIF(!lTop,EG0->EG0_DEST,WK_EG0->EG0_DEST)
                       WORK->WK_MODULO:=cModulo
                      
                       WORK->WK_OWNER:=IIF(!lTop,EG0->EG0_FORNEC,WK_EG0->EG0_FORNEC)
                       WORK->WK_CLIENT:=IIF(!lTop,EG0->EG0_CLIENT,WK_EG0->EG0_CLIENT)
                       WORK->WK_PARC_C:=IIF(!lTop,EG0->EG0_PARC_C,WK_EG0->EG0_PARC_C)
                       WORK->WK_VAL_DEM:=IIF(!lTop,EG0->EG0_VALPRO,WK_EG0->EG0_VALPRO)
                       WORK->WK_DEM_RAT:=IIF(!lTop,EG0->EG0_DEM_V,WK_EG0->EG0_DEM_V)
                       WORK->WK_DES_RAT:=IIF(!lTop,EG0->EG0_DES_V,WK_EG0->EG0_DES_V)
                       WORK->WK_RATLDHD:=IIF(!lTop,EG0->EG0_RAT_HD,WK_EG0->EG0_RAT_HD)
                       WORK->WK_TUSED:=IIF(!lTop,EG0->EG0_USED,WK_EG0->EG0_USED)
                       IF !EMPTY(WORK->WK_TUSED) .AND. WORK->WK_PARC_C#0
                          //PRANCHA - PARCEL CARGO DIVIDIDO PELO TIME USED CONVERTIDO PARA DIAS OU HORAS CONFORME O RATE D/H
                          IF WORK->WK_RATLDHD=="1" //DIA
                              WORK->WK_PRANCHA:=(WORK->WK_PARC_C / (VAL(Left(WORK->WK_TUSED,2))+(VAL(SubStr(WORK->WK_TUSED,4,2))/24)+(VAL(Right(WORK->WK_TUSED,2))/1440))) 
                          ELSE  //HORA
                              WORK->WK_PRANCHA:=(WORK->WK_PARC_C / ( (VAL(Left(WORK->WK_TUSED,2))*24)+(VAL(SubStr(WORK->WK_TUSED,4,2)))+(VAL(Right(WORK->WK_TUSED,2))/60))) 
                          ENDIF
                       ELSE
                          WORK->WK_PRANCHA:=0                       
                       ENDIF
                       WORK->WK_OBS:=IIF(!lTop,EG2->EG2_CODMEN,WK_EG2->EG2_CODMEN)
                       WORK->WK_TPD:=IIF(!lTop,EG2->EG2_TP_LD,WK_EG2->EG2_TP_LD)
                       WORK->WK_DATA:=IIF(!lTop,EG2->EG2_DATA,WK_EG2->EG2_DATA)
                       WORK->WK_TFROM:=IIF(!lTop,EG2->EG2_FROM,WK_EG2->EG2_FROM)
                       WORK->WK_TTO:=IIF(!lTop,EG2->EG2_TO,WK_EG2->EG2_TO)
                       WORK->WK_TUSEDIT:=IIF(!lTop,EG2->EG2_TIMEUS,WK_EG2->EG2_TIMEUS)                                                   
                       WORK->(MSUNLOCK())
                       WORK->(DBCOMMIT())
                       nTimeUsed:=((VAL(Left(WORK->WK_TUSEDIT,1))*24)+(VAL(SubStr(WORK->WK_TUSEDIT,3,2)))+(VAL(Right(WORK->WK_TUSEDIT,2))/60)) //tempo total por item do eg2
                       nTime_Dem:=((VAL(Left(WORK->WK_TUSED,1))*24)+(VAL(SubStr(WORK->WK_TUSED,3,2)))+(VAL(Right(WORK->WK_TUSED,2))/60)) //tempo total demurrage eg0
                       IF mv_par12==2 //caso analitico
                           nPos:=ascan(nTotTime,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_DEMURR+WORK->WK_OBS)})
                           IF nPos>0
                               nTotTime[nPos,2]+=nTimeUsed
                           ELSE
                               aadd(nTotTime,{(WORK->WK_FILIAL+WORK->WK_DEMURR+WORK->WK_OBS),nTimeUsed,nTime_Dem})
                           ENDIF
                       ELSE
                           nPos:=ascan(nRegSint,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_DEMURR+WORK->WK_OBS+WORK->WK_TPD)})
                           IF nPos>0
                              nRegSint[nPos,2]+=nTimeUsed
                           ELSE
                              aadd(nRegSint,{(WORK->WK_FILIAL+WORK->WK_DEMURR+WORK->WK_OBS+WORK->WK_TPD),nTimeUsed,nTime_Dem})
                           ENDIF
                       ENDIF
                    ENDIF                   
                 ENDIF
                 IF !lTop
                    EG2->(DBSKIP())
                 ELSE
                    WK_EG2->(DBSKIP())               
                 ENDIF  
            ENDDO
            
        	//ENDCOMM 01
        	IF !lTop
               EG0->(DBSKIP())
            ELSE
               WK_EG2->(DBCLOSEAREA())
               WK_EG0->(DBSKIP())               
            ENDIF   
	    ENDDO
	    IF lTop
	       WK_EG0->(DBCLOSEAREA())
	    ENDIF
    NEXT	
RETURN .T.

*// Função que cria o corpo do relatorio
*---------------------------------------------------------------------------------------
STATIC FUNCTION AVGDER_BD() // 31-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   LOCAL cFilAtu:="-",cLDemurr:="-",cObsP:="-"
   LOCAL nTime_c:=nTime_d:=nTime_T:=Tot_dem:=0 //totais de hora do relatorio sintético
   LOCAL cfilSA1:=xfilial("SA1"),cfilSA2:=xfilial("SA2"),cfilEE4:=xfilial("EE4"),lQuebra:=.F. //força quebra caso .t.
   afilSA1:=afilSA2:=afilEE4:={}
  
   afilSA1:=AvgSelectFil(.F.,"SA1")
   afilSA2:=AvgSelectFil(.F.,"SA2")   
   afilEE4:=AvgSelectFil(.F.,"EE4")
   
   nLin:=61
   PLinha()
   DBSELECTAREA("WORK")
   WORK->(dbgotop())
          DO WHILE WORK->(EOF())=.F. 
              cFilSA1:=iif(len(aFilSA1)==1 .and. alltrim(aFilSA1[1])=="",aFilSA1[1],WORK->WK_FILIAL) 
              cFilSA2:=iif(len(aFilSA2)==1 .and. alltrim(aFilSA2[1])=="",aFilSA2[1],WORK->WK_FILIAL) 
              cFilEE4:=iif(len(aFilEE4)==1 .and. alltrim(aFilEE4[1])=="",aFilEE4[1],WORK->WK_FILIAL) 

              //Quebra por filial
                  IF Is_MFill //caso multifilial //QUEBRA POR FILIAL
                     IF cFilAtu#WORK->WK_FILIAL
                         IF mv_par12==2 //caso analitico  
                             IF cObsP#"-"
                                //Totais por demurrage e observação
                                nPos:=ascan(nTotTime,{|x| x[1]==(cFilAtu+cLDemurr+cObsP)})
                                @ nLin,1 PSAY replicate(".",218)
                                IF nPos>0
                                    PLinha()
                                    @ nLin,39 PSAY alltrim(TimeF(nTotTime[nPos,2]))+space(3)+alltrim(str( ( (nTotTime[nPos,2]/nTotTime[nPos,3])*100 ) ))+"%"  //tempo por observação
                                    PLinha()          
                                ENDIF
                                @ nLin,1 PSAY replicate(".",218)      
                                PLinha()
                                cObsP:=WORK->WK_OBS
                             ENDIF
                         ENDIF
                         IF cFilAtu#"-"
                             nLin:=61 //Quebra de página
                             PLinha()
                         ENDIF
                         cLDemurr:=WORK->WK_DEMURR
                         cFilAtu:=WORK->WK_FILIAL
                         @ nLin,1 PSAY __PrtFatLine()
                         PLinha()
                         @ nLin,1 PSAY STR0006+cFilAtu+" - "+AvgFilName({cFilAtu})[1]
                         PLinha()          
                         @ nLin,1 PSAY __PrtFatLine()
                         PLinha()           
                         lQuebra:=.T. //força a quebra do próximo agrupamento
                     ENDIF
                  ELSE
                     cFilAtu:=WORK->WK_FILIAL
                  ENDIF
              
                  IF cLDemurr#WORK->WK_DEMURR .OR. lQuebra==.T.
                         IF mv_par12==2 //caso analitico  
                            IF cObsP#"-"
                                //Totais por demurrage e observação
                                nPos:=ascan(nTotTime,{|x| x[1]==(WORK->WK_FILIAL+cLDemurr+cObsP)})
                                @ nLin,1 PSAY replicate(".",218)
                                IF nPos>0
                                    PLinha()
                                    @ nLin,39 PSAY alltrim(TimeF(nTotTime[nPos,2]))+space(3)+alltrim(str( ( (nTotTime[nPos,2]/nTotTime[nPos,3])*100 ) ))+"%"  //tempo por observação
                                    PLinha()          
                                ENDIF
                                @ nLin,1 PSAY replicate(".",218)      
                                PLinha()
                                cObsP:=WORK->WK_OBS
                            ENDIF
                         ENDIF
                         IF cLDemurr#"-"
                            PLinha()                               
                         ENDIF
                 
                         @ nLin,1 PSAY replicate("-",218) 
                         PLinha()      
                 
                         //"Demurr.: " "Vessel: " "Owner: " "Client.: " "Products.: "  "Qtd(MT): " "Time Used: " "Dem.Rate.USD: " "Des.Rate.USD: " "Rate D/H: ""Prancha: "
                         @ nLin,1 PSAY STR0011+WORK->WK_DEMURR+space(4)+STR0012+WORK->WK_VESSEL+space(4)+STR0030+Alltrim(WORK->WK_VIAGEM)+space(4)+STR0031+Alltrim(WORK->WK_PORTO)+space(4)+;
                                   STR0013+alltrim(WORK->WK_OWNER)+" - "+Alltrim(POSICIONE("SA2",1,cFilSA2+WORK->WK_OWNER,"A2_NREDUZ"))+space(4)+;
                                   STR0014+alltrim(WORK->WK_CLIENT)+" - "+alltrim(POSICIONE("SA1",1,cFilSA1+WORK->WK_CLIENT,"A1_NREDUZ"))+space(4)+STR0015+WORK->WK_PROD
                         PLinha()
                         @ nLin,1 PSAY STR0016+ALLTRIM(transform(WORK->WK_QTDMT,AVSX3("EG1_QTDMT",6)))+space(6)+;
                                   STR0017+ALLTRIM(transform(WORK->WK_PARC_C,AVSX3("EG0_PARC_C",6)))+space(6)+;
                                   STR0018+WORK->WK_TUSED+space(6)+;              
                                   STR0019+ALLTRIM(transform(WORK->WK_DEM_RAT,AVSX3("EG0_DEM_V",6)))+space(6)+;                                   
                                   STR0020+ALLTRIM(transform(WORK->WK_DES_RAT,AVSX3("EG0_DES_V",6)))+space(6)+;
                                   STR0021+iif(WORK->WK_RATLDHD=="1",STR0023,STR0024)+space(6)+;
                                   STR0022+ALLTRIM(transform(WORK->WK_PRANCHA,AVSX3("EG0_PARC_C",6)))
                         PLinha()          
                         @ nLin,1 PSAY replicate("-",218) 
                         PLinha()      
                         cLDemurr:=WORK->WK_DEMURR
                         cObsP:="-"
                         lQuebra:=.T.
                  ENDIF
                  IF cObsP#WORK->WK_OBS .or. lQuebra==.T. //Quebra por Observação padrão
                     lQuebra:=.F.
                     IF mv_par12==2 //caso analitico  
                         IF cObsP#"-"
                            //Totais por demurrage e observação
                            nPos:=ascan(nTotTime,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_DEMURR+cObsP)})
                            @ nLin,1 PSAY replicate(".",218)
                            IF nPos>0
                                PLinha()
                                @ nLin,39 PSAY alltrim(TimeF(nTotTime[nPos,2]))+space(3)+alltrim(str( ( (nTotTime[nPos,2]/nTotTime[nPos,3])*100 ) ))+"%"  //tempo por observação
                                PLinha()          
                            ENDIF
                            @ nLin,1 PSAY replicate(".",218)      
                            PLinha()
                         ENDIF
                        @ nLin,1 PSAY replicate("-",218)   
                        PLinha()
                        @ nLin,1 PSAY STR0025+WORK->WK_OBS+" - "+MSMM(POSICIONE("EE4",1,cfilEE4+WORK->WK_OBS,"EE4_TEXTO"),30,1)+space(3)
                     ELSE  //SINTÉTICO
                         //carga
                         nPos:=ascan(nRegSint,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_DEMURR+WORK->WK_OBS+"1")})
                         Tot_dem:=0
                         nTime_c:=0
                         nTime_d:=0
                         IF nPos>0
                            nTime_c:=nRegSint[npos,2]
                            Tot_dem:=nRegSint[npos,3]
                         endif
                         //descarga
                         nPos:=ascan(nRegSint,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_DEMURR+WORK->WK_OBS+"2")})
                         IF nPos>0
                            nTime_d=nRegSint[npos,2]
                            Tot_dem:=nRegSint[npos,3]
                         endif
                         nTime_T:=nTime_c+nTime_d
                         
                         @ nLin,1 PSAY WORK->WK_OBS+" - "+padr(MSMM(POSICIONE("EE4",1,cfilEE4+WORK->WK_OBS,"EE4_TEXTO"),30,1),40)+space(3)+;
                         alltrim(TimeF(nTime_c))+space(6)+alltrim(TimeF(nTime_d))+space(6)+alltrim(TimeF(nTime_T))+space(6)+alltrim(str( ( (nTime_T/Tot_dem)*100 ) ))+"%"
                     ENDIF
                     cObsP:=WORK->WK_OBS
                     PLinha()                     
                     IF mv_par12==2 //caso analitico

                         @ nLin,1 PSAY replicate("-",218)      
                         PLinha()                                    
                     ENDIF
                  ENDIF
                  IF mv_par12==2 //caso analitico
                      @ nLin,1 PSAY iif(WORK->WK_TPD=="1",STR0026,STR0027)+space(3)+DTOC(WORK->WK_DATA)+space(3) +;
                                WORK->WK_TFROM+space(3)+WORK->WK_TTO+space(3)+WORK->WK_TUSEDIT              
                      PLinha()                        
                  ENDIF
                  WORK->(DBSKIP())
          ENDDO
          
          //Totais por demurrage e observação
          IF mv_par12==2 //caso analitico
             nPos:=ascan(nTotTime,{|x| x[1]==(cFilAtu+cLDemurr+cObsP)})
             @ nLin,1 PSAY replicate(".",218)
             IF nPos>0
                 PLinha()
                 @ nLin,39 PSAY alltrim(TimeF(nTotTime[nPos,2]))+space(3)+alltrim(str( ( (nTotTime[nPos,2]/nTotTime[nPos,3])*100 ) ))+"%"  //tempo por observação
                 PLinha()          
             ENDIF
             @ nLin,1 PSAY replicate(".",218)      
             PLinha() 
          ENDIF
          //
          ms_flush() 
Return .t.

*// Função responsavel pel quebra de linha e página LINEFEED
*---------------------------------------------------------------------------------------
STATIC FUNCTION PLinha() // 12-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   IF nLin>60 
      nLin:=Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5])
      nLin:=nLin+1   
      //string com os filtros dos perguntes concatenados
      if !empty(cFiltro_Str) 
          @ nLin,1 PSAY replicate("-",218)
          nLin:=nLin+1         
          @ nLin,01 psay STR0007+"  "+cFiltro_Str
          nLin:=nLin+1         
          @ nLin,1 PSAY replicate("-",218)
          nLin:=nLin+1         
      endif
   else
      nLin:=nLin+1
      @ nLin,00 psay " "
   endif
Return .t.

*// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------
   Local oExcelApp
   //Local cDirDocs := MsDocPath()
   Local cPath	:= AllTrim(GetTempPath())
   DbSelectArea("Work")
   if lExcel
         Work->(dbCloseArea())
         CpyS2T(".\"+curdir()+WorkFile+".DBF",cPath, .T. )
         If ! ApOleClient( 'MsExcel' )
            MsgStop(STR0009)  //"Ms-Excel não instalado."
            RETURN .F.
         Else
            oExcelApp:= MsExcel():New()
            oExcelApp:WorkBooks:Open( cPath+WorkFile+".dbf" )
            oExcelApp:SetVisible(.T.)
         EndIf
   Else
         TR350ARQUIVO("work")   
         Work->(dbCloseArea())
   EndIf
Return .T.

*---------------------------------------------------------------------------------------
STATIC FUNCTION TimeF(Tempo_hora) // 02-02-05 - Alcir Alves  - converte valor em horas para dia:hora:minuto 
                                  //nHora->dd:hh:mm
*---------------------------------------------------------------------------------------
    local  n_Dias:=n_hora:=n_minuto:=""
    n_Dias:=strzero(int(Tempo_hora/24),1)
    n_hora:=strzero(int(Tempo_hora-(val(n_Dias)*24)),2)
    n_minuto:=strzero( (abs( Tempo_hora-(val(n_Dias)*24)-(val(n_hora)) ))*60 ,2)
Return (n_dias+":"+n_hora+":"+n_minuto)
    
