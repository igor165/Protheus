// Programador : Alcir Alves
// Data Desenvolvimento- 27-01-05   
// Objetivo - Relatório de performance de carregamento
// Revisão : AAF 14/02/05 - Correções de Problemas encontrados nos testes de qualidade.
// PRW : AVGPF150
//Versão Codebase e Topconnect

#INCLUDE "AVGPF150.CH"                 
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"                 
*// Função principal de acesso ao menu       - Alcir Alves Alcir$
*---------------------------------------------------------------------------------------
FUNCTION AVGPF150() // 27-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   PRIVATE afilSel:={},lTop
   PRIVATE aReturn:= {"Zebrado",1,"", 2, 1, 1, "", 1}
   Private nLin:=0,M_pAg:=1,Is_MFill:=.T.  //caso seja multifilial
   Private cFiltro:="",cFiltro_Str:="" //validação com os filtros do pergunte
   Private cNomArq:="",WorkFile:="",cModulo:=iif(nModulo==17,"I","E")
   Private aDados := {"",;
                   "",; 
                   "",; 
                   "",;
                   "G",;
                    220,;
                   STR0013,; 
                   "",;
                   STR0020,; 
                   { "Zebrado", 1,"Contabil", 1, 2, 1, "",1 },;
                   "AVGMD150",;             
                    }
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

   afilSel:=AvgSelectFil(.T.,"EG0") //Alcir - conceito multifilial
   if afilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
      //caso o EG0 seja compartilhado
      if len(afilSel)==1 .and. alltrim(afilSel[1])==""
         Is_MFill:=.F.
      endif
   
      IF Pergunte("AVGPF ",.T.)
          Processa({||AVGPFWORK()})
          IF WORK->(EasyRecCount("WORK"))>0
             if mv_par07==1  //Caso destino seja impressora
                 wnrel:=SetPrint("WORK","AVGPF150",,STR0018,"","","",.F.,.F.,.F.,"G")
                 If lastkey()#27 .and. nlastkey!=27
                    SetDefault(aReturn,"WORK")
                    RptStatus({|lEnd| AVGPFR_BD()})
                    OurSpool(wnrel)
                 Endif
             else //Caso destino seja texto ou excel
                 WORK_EXPORT(iif(mv_par07==2,.f.,.t.))
                 return .t.
             endif
          ELSE
              Msgstop(STR0014) //"Não existe dados para esta consulta"	
          ENDIF
          WORK->(DBCLOSEAREA())
      ENDIF
   ENDIF
   
   IF file(WorkFile)
      //Ferase(cNomArq) 
      E_EraseArq(WorkFile)
   ENDIF
   
RETURN .T.


*// Função que cria a work
*---------------------------------------------------------------------------------------
STATIC FUNCTION AVGPFWORK() // 27-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
    Local Adata,i:=0,cWhile:="",cWhile2:="",cWhile3:="",cWhile4:="",cEncontrou:=.T. //caso o os filtros de produtos ou embarque estejam preenchidos esta variavel retorna false se não encontrar nenhum registro compativel
    Local cfilEG0:=xfilial("EG0"),cFilEG1:=xfilial("EG1") //Alcir - conceito multifilial

    EG0->(DBSETORDER(1))
    EG1->(DBSETORDER(1))    

    Adata:= {}
    Aadd(Adata,{"WK_FILIAL",AVSX3("EG0_FILIAL",2),AVSX3("EG0_FILIAL",3),AVSX3("EG0_FILIAL",4)}) //FILIAL
    Aadd(Adata,{"WK_VESSEL",AVSX3("EG0_NAVIO",2),AVSX3("EG0_NAVIO",3),AVSX3("EG0_NAVIO",4)}) //NAVIO
    Aadd(Adata,{"WK_VIAGEM",AVSX3("EG0_VIAGEM",2),AVSX3("EG0_VIAGEM",3),AVSX3("EG0_VIAGEM",4)}) //VIAGEM
    Aadd(Adata,{"WK_OWNER",AVSX3("EG0_FORNEC",2),AVSX3("EG0_FORNEC",3),AVSX3("EG0_FORNEC",4)}) //ARMADOR
    Aadd(Adata,{"WK_MODULO","C",1,0}) //MODULO
    IF lExistDM
        Aadd(Adata,{"WK_DEMURR",AVSX3("EG0_DEMURR",2),AVSX3("EG0_DEMURR",3),AVSX3("EG0_DEMURR",4)}) //COD DO DEMURRAGE
    ENDIF
    
    Aadd(Adata,{"WK_MOEDA",AVSX3("EG0_MOEDA",2),AVSX3("EG0_MOEDA",3),AVSX3("EG0_MOEDA",4)}) //VALOR DO DEMURRAGE
    Aadd(Adata,{"WK_VAL_DEM",AVSX3("EG0_OW_VL",2),AVSX3("EG0_OW_VL",3),AVSX3("EG0_OW_VL",4)}) //VALOR DO DEMURRAGE
    Aadd(Adata,{"WK_RATLDHD",AVSX3("EG0_RAT_HD",2),AVSX3("EG0_RAT_HD",3),AVSX3("EG0_RAT_HD",4)}) //RATE L/D  H/D   
    Aadd(Adata,{"WK_PARC_C",AVSX3("EG0_PARC_C",2),AVSX3("EG0_PARC_C",3),AVSX3("EG0_PARC_C",4)}) //Parcel cargo      
    Aadd(Adata,{"WK_PRANCHA",AVSX3("EG0_PARC_C",2),AVSX3("EG0_PARC_C",3),AVSX3("EG0_PARC_C",4)}) //PRANCHA
    Aadd(Adata,{"WK_TUSED",AVSX3("EG0_USED",2),AVSX3("EG0_USED",3),AVSX3("EG0_USED",4)}) //TEMPO USADO
   
    WorkFile := E_CriaTrab(,Adata, "Work") //THTS - 28/09/2017 - TE-6431 - Temporario no Banco de Dados
    cNomArq := "worki"+TEOrdBagExt()
    IF lExistDM
       IndRegua("Work",cNomArq,"WK_FILIAL+WK_MODULO+WK_DEMURR+WK_VESSEL+WK_VIAGEM")
    ELSE
       IndRegua("Work",cNomArq,"WK_FILIAL+WK_MODULO+WK_VESSEL+WK_VIAGEM")    
    ENDIF
//   //Alcir - conceito multifilial
//  //Alcir - conceito multifilial
//  //Cria code block com a avaliação dos filtros do pergunte
    IF !lTop 
        //caso codebase
        cFiltro:=" EG0->(EOF())==.F. "+;
        iif(!empty(mv_par01)," .and. EG0->EG0_NAVIO==mv_par01","")+; //navio
        iif(!empty(mv_par02)," .and. EG0->EG0_VIAGEM==mv_par02","")+; //VIAGEM
        iif(mv_par03#1,iif(mv_par03==2," .and. EG0->EG0_RAT_HD==AVKEY('1','EG0_RAT_HD')"," .and. EG0->EG0_RAT_HD==AVKEY('2','EG0_RAT_HD')"),"")+; //RATE D/H
        iif(!empty(mv_par06)," .and. EG0->EG0_FORNEC==AVKEY(mv_par06,'EG0_FORNEC') .AND. EMPTY(EG0->EG0_CLIENT)","") //ARMADOR
    ELSE  
        cFiltro:=" WK_EG0->(EOF())==.F. "+;
        iif(!empty(mv_par01)," .and. WK_EG0->EG0_NAVIO==mv_par01","")+; //navio
        iif(!empty(mv_par02)," .and. WK_EG0->EG0_VIAGEM==mv_par02","")+; //VIAGEM
        iif(mv_par03#1,iif(mv_par03==2," .and. WK_EG0->EG0_RAT_HD==AVKEY('1','EG0_RAT_HD')"," .and. WK_EG0->EG0_RAT_HD==AVKEY('2','EG0_RAT_HD')"),"")+; //RATE D/H
        iif(!empty(mv_par06)," .and. WK_EG0->EG0_FORNEC==AVKEY(mv_par06,'EG0_FORNEC') .AND. EMPTY(WK_EG0->EG0_CLIENT)","") //ARMADOR        
    ENDIF
    cFiltro:="("+cFiltro+")"

    //String com os campos filtrados
    cFiltro_Str+=iif(!empty(mv_par01),STR0001+alltrim(mv_par01)+"   ","")+;
                 iif(!empty(mv_par02),STR0002+alltrim(mv_par02)+"   ","")+;     
                 iif(mv_par03#1,STR0003+alltrim(iif(mv_par03==2,"Day","Hour"))+"   ","")+;     
                 iif(!empty(mv_par04),STR0004+alltrim(mv_par04)+"   ","")+;     
                 iif(!empty(mv_par05),STR0005+alltrim(mv_par05)+"   ","")+;     
                 iif(!empty(mv_par06),STR0006+alltrim(mv_par06)+"   ","")       
    
    FOR i:=1 TO LEN(afilSel) //Conceito multifilial 
        cfilEG0:=afilSel[i]
        cfilEG1:=iif(len(afilSel)==1 .and. alltrim(afilSel[1])=="",afilSel[1],afilSel[i]) //Alcir - conceito multifilial
        IF !lTop
           //Versão codebase
           EG0->(DBSEEK(cfilEG0+cModulo))
           cWhile4:={ || EG0->(EOF())==.F. .AND. EG0->EG0_MODULO=cModulo .AND. EG0->EG0_FILIAL=cfilEG0}
        ELSE
           cQuery:="SELECT * from "+RetSqlName("EG0")+" EG0 "+;
                   " WHERE EG0.EG0_FILIAL='"+cfilEG0+"' AND EG0.EG0_MODULO='"+cModulo+"' "+;
                   " AND EG0.EG0_CLIENT='"+SPACE(AVSX3("EG0_CLIENT",3))+"' AND "+IIF(TcSrvType()<>"AS/400","EG0.D_E_L_E_T_<>'*'","EG0.@DELETED@<>'*'")
            cQuery:=ChangeQuery(cQuery)
            TcQuery cQuery ALIAS "WK_EG0" NEW
            cWhile4:={ || WK_EG0->(EOF())==.F.}
        ENDIF
           
        DO WHILE EVAL(cWhile4) 
               IF EVAL({ || IIF(!lTop,EMPTY(EG0->EG0_CLIENT),.T.)}) //CASO SEJA ARMADOR
                   IF !EMPTY(mv_par04) .OR. !EMPTY(mv_par05) 
                       //CASO ALGUM DOS PERRGUNTES PROCESSO OU PRODUTO ESTEJA PREENCHIDO
                       //SERÁ ABERTO UM LASSO NO EG1 A PROCURA APENAS DE DEMURRAGES COM O RESPECTIVO EMBARQUE OU PRODUTO                        
                       //CASO EXPORTAÇÃO 
                       IF !EMPTY(mv_par04)
                          cWhile2:={ || IIF(!lTop,EG1->EG1_EMBARQ==mv_par04,WK_EG1->EG1_EMBARQ==mv_par04)}
                       ELSE
                          cWhile2:={ || .T. }                       
                       ENDIF
                       IF !EMPTY(mv_par05)
                          cWhile3:={ || IIF(!lTop,EG1->EG1_COD_I==mv_par05,WK_EG1->EG1_COD_I==mv_par05)}
                       ELSE
                          cWhile3:={ || .T. }                       
                       ENDIF
                       cEncontrou:=.f.
                       DBSELECTAREA("EG1")
                       IF lExistDM //caso base nova cosiderar apenas filial+modulo+demurr na composição da chave
                           IF !lTop
                              EG1->(DBSEEK(cfilEG1+cModulo+EG0->EG0_DEMURR))
                              cWhile:={ || !EG1->(EOF()) .and. EG1->EG1_DEMURR==EG0->EG0_DEMURR .and. EG1->EG1_MODULO==cModulo}
                           ELSE
                              cQuery:="SELECT * from "+RetSqlName("EG1")+" EG1 "+;
                                      " WHERE EG1.EG1_FILIAL='"+cfilEG1+"' AND EG1.EG1_MODULO='"+cModulo+"' AND "+;
                                      " EG1.EG1_DEMURR='"+WK_EG0->EG0_DEMURR+"' AND "+IIF(TcSrvType()<>"AS/400","EG1.D_E_L_E_T_<>'*'","EG1.@DELETED@<>'*'")
                              cQuery:=ChangeQuery(cQuery)
                              TcQuery cQuery ALIAS "WK_EG1" NEW
                              cWhile:={ || !WK_EG1->(EOF()) .and. WK_EG1->EG1_DEMURR==WK_EG0->EG0_DEMURR .and. WK_EG1->EG1_MODULO==cModulo}
                              DBSELECTAREA("WK_EG1")                              
                           ENDIF
                       ELSE //caso base antiga cosiderar filial+modulo+navio+viagem+destino na composição da chave
                           IF !lTop
                              EG1->(DBSEEK(cfilEG1+cModulo+EG0->EG0_NAVIO+EG0->EG0_VIAGEM+EG0->EG0_DEST))
                              cWhile:={ || !EG1->(EOF()) .and. EG1->(EG1_NAVIO+EG1_VIAGEM+EG1_DEST)==EG0->(EG0_NAVIO+EG0_VIAGEM+EG0_DEST)}
                           ELSE
                              cQuery:="SELECT * from "+RetSqlName("EG1")+" EG1 "+;
                                      " WHERE EG1.EG1_FILIAL='"+cfilEG1+"' AND EG1.EG1_MODULO='"+cModulo+"' AND "+;
                                      " EG1.EG1_NAVIO='"+WK_EG0->EG0_NAVIO+"' AND EG1.EG1_VIAGEM='"+WK_EG0->EG0_VIAGEM+"'"+;
                                      " AND EG1.EG1_DEST='"+WK_EG0->EG0_DEST+"'"+;
                                      " AND "+IIF(TcSrvType()<>"AS/400","EG1.D_E_L_E_T_<>'*'","EG1.@DELETED@<>'*'")
                              cQuery:=ChangeQuery(cQuery)
                              TcQuery cQuery ALIAS "WK_EG1" NEW
                              cWhile:={ || !WK_EG1->(EOF()) .and. WK_EG1->(EG1_NAVIO+EG1_VIAGEM+EG1_DEST)==WK_EG0->(EG0_NAVIO+EG0_VIAGEM+EG0_DEST)}
                              DBSELECTAREA("WK_EG1")                              
                           ENDIF
                       ENDIF    
      
                       DO WHILE eval(cWhile) 
                           IF eval(cWhile2) .and. eval(cWhile3)
                               cEncontrou:=.t.                       
                               EXIT
                           ENDIF
                           IF !lTop
                               EG1->(DBSKIP())
                           ELSE
                               WK_EG1->(DBSKIP())                           
                           ENDIF
                       ENDDO
                       WK_EG1->(DBCLOSEAREA())
                   ENDIF   
                   IF cEncontrou==.t. .AND. &(cFiltro)  
                       WORK->(RECLOCK("WORK",.T.))
                       WORK->WK_FILIAL:=cfilEG0
                       WORK->WK_VESSEL:=IIF(!lTop,EG0->EG0_NAVIO,WK_EG0->EG0_NAVIO)
                       WORK->WK_VIAGEM:=IIF(!lTop,EG0->EG0_VIAGEM,WK_EG0->EG0_VIAGEM)
                       WORK->WK_MODULO:=cModulo
                       WORK->WK_OWNER:=IIF(!lTop,EG0->EG0_FORNEC,WK_EG0->EG0_FORNEC)
                       WORK->WK_DEMURR:=IIF(!lTop,EG0->EG0_DEMURR,WK_EG0->EG0_DEMURR)
                       WORK->WK_MOEDA:=IIF(!lTop,EG0->EG0_MOEDA,WK_EG0->EG0_MOEDA)
                       WORK->WK_VAL_DEM:=IIF(!lTop,EG0->EG0_OW_VL,WK_EG0->EG0_OW_VL)
                       WORK->WK_RATLDHD:=IIF(!lTop,EG0->EG0_RAT_HD,WK_EG0->EG0_RAT_HD)
                       WORK->WK_PARC_C:=IIF(!lTop,EG0->EG0_PARC_C,WK_EG0->EG0_PARC_C)
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
                       WORK->(MSUNLOCK())
                   ENDIF  
               ENDIF
        	   IF !lTop
                  EG0->(DBSKIP())
               ELSE
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
STATIC FUNCTION AVGPFR_BD() // 27-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   LOCAL cFilAtu:="-"
   nLin:=61
   PLinha()
   DBSELECTAREA("WORK")
   work->(dbgotop())
          DO WHILE WORK->(EOF())=.F. 
              //Quebra por filial
              IF Is_MFill //caso multifilial //QUEBRA POR FILIAL
                 IF cFilAtu#WORK->WK_FILIAL
                     IF cFilAtu#"-"
                         nLin:=61 //Quebra de página
                         PLinha()
                     ENDIF
                     cFilAtu:=WORK->WK_FILIAL
                     @ nLin,1 PSAY __PrtFatLine()
                     PLinha()
                     @ nLin,1 PSAY STR0015+cFilAtu+" - "+AvgFilName({cFilAtu})[1]
                     PLinha()          
                     @ nLin,1 PSAY __PrtFatLine()
                     PLinha()           
                 ENDIF
              ENDIF
              @ nLin,1 PSAY WORK->WK_VESSEL+space(4)+WORK->WK_VIAGEM+space(4)+WORK->WK_OWNER+space(4)+;
                        WORK->WK_DEMURR+space(4)+WORK->WK_MOEDA+space(4)+TRANSFORM(WORK->WK_VAL_DEM,AVSX3("EG0_OW_VL",6))+space(4)+;
                        iif(WORK->WK_RATLDHD=="1","Day ","Hour")+space(4)+TRANSFORM(WORK->WK_PARC_C,AVSX3("EG0_PARC_C",6))+;
                        space(4)+WORK->WK_TUSED+space(4)+TRANSFORM(WORK->WK_PRANCHA,AVSX3("EG0_PARC_C",6))
              PLinha()
              WORK->(DBSKIP())
          ENDDO
   ms_flush() 
Return .t.

*// Função responsavel pel quebra de linha e página LINEFEED
*---------------------------------------------------------------------------------------
STATIC FUNCTION PLinha() // 12-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   if nLin>60 
      nLin:=Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5])
      nLin:=nLin+1   
      //string com os filtros dos perguntes concatenados
      if !empty(cFiltro_Str) 
          @ nLin,1 PSAY replicate("*",218)
          nLin:=nLin+1         
          @ nLin,01 psay STR0016+"  "+cFiltro_Str
          nLin:=nLin+1         
          @ nLin,1 PSAY replicate("*",218)
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
            MsgStop(STR0017)  //"Ms-Excel não instalado."
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