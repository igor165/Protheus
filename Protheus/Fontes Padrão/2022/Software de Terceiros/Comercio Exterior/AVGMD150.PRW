// Programador : Alcir Alves
// Data Desenvolvimento- 07-01-05    
// Objetivo - Mapa de demurrage
// Revisão : Alessandro Alves Ferreira - 10/02/05 - Correção de Erros encontrados nos testes de qualidade.
// PRW : AVGMD150
//Versão Codebase e Topconnect

#INCLUDE "AVGMD150.CH"                 
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"                 
*// Função principal de acesso ao menu       - Alcir Alves Alcir$
*---------------------------------------------------------------------------------------
FUNCTION AVGMD150() // 02-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   PRIVATE afilSel:={},lTop
   PRIVATE aReturn:= {"Zebrado",1,"", 2, 1, 1, "", 1}
   Private nLin:=0,M_pAg:=1,lMultiFil:=.T.  //caso seja multifilial
   Private cFiltro:="",cFiltro_Str:="" //validação com os filtros do pergunte
   Private WorkFile:="",cModulo:=iif(nModulo==17,"I","E"),cNomArq:="" //THTS - 23/10/2017 - Temporario no Banco de Dados
   Private aDados := {"",;
                   "",; 
                   "",; 
                   "",;
                   "G",;
                    220,;
                   "",; 
                   "",;
                   STR0001,; //"Mapa do demurrage"
                   { "Zebrado", 1,"Contabil", 1, 2, 1, "",1 },;
                   "AVGMD150",;
                    }
   PRIVATE lExistDM := if (EG0->( FieldPos( "EG0_DEMURR" ) ) > 0 .AND. EG1->( FieldPos( "EG1_DEMURR" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_NRINVO" ) ) > 0 .AND. EG1->( FieldPos( "EG1_PEDIDO" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_SEQUEN" ) ) > 0 .AND. EG1->( FieldPos( "EG1_COD_I" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_QTDUC" ) ) > 0  .AND. EG1->( FieldPos( "EG1_QTDMT" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_UNMED" ) ) > 0  .AND. EG1->( FieldPos( "EG1_COEF" ) ) > 0 ;
        .AND. EG2->( FieldPos( "EG2_DEMURR" ) ) > 0  ,.T.,.F.)
   
Private cWHENSA2 := "" //THTS - 04/08/2017 - Utilizada em consulta especifica

   IF !lExistDM //CASO A BASE NÃO SEJA ATUALIZADA O MÓDULO NÃO CONTINUARÁ EM EXECUÇÃO
      MSGSTOP(STR0002)//"Para o correto funcionamento deste relatório será necessário a atualização da base de dados do demurrage, contate os analistas de suporte!"
      RETURN .F.
   ENDIF

   #IFDEF TOP
     lTop := .T.
   #ElSE
     lTop := .F.
   #ENDIF  

   If EasyEntryPoint("AVGMD150")
          ExecBlock("AVGMD150", .F., .F.,"ADICIONA_PERGUNTE")
   Endif   
   
  
   //** AAF 10/02/05 - Verifica Campo EG1_FILORI com a Filial de Origem.
   SX3->( dbSetOrder(2) )
   Private lFilOri := SX3->( dbSeek("EG1_FILORI") )
   //**

   afilSel:=AvgSelectFil(.T.,"EG0") //Alcir - conceito multifilial
   if afilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
      //caso o EG0 seja compartilhado
      If (len(afilSel)==1 .and. alltrim(afilSel[1])=="") .or. !VerSenha(115)
         lMultiFil := .F. //AAF 11/02/05
      Endif

      If EasyEntryPoint("AVGMD150")
         ExecBlock("AVGMD150", .F., .F.,"ANTES_PERGUNTE")
      Endif   
   
      IF Pergunte("AVGMD"+cModulo,.T.)
          Processa({||AVGMDWORK()})
          IF WORK->(Easyreccount("WORK"))>0
             if mv_par14==1  //Caso destino seja impressora
                 wnrel:=SetPrint("WORK","AVGMD150",,"Mapa do demurrage","","","",.F.,.F.,.F.,"G")
                 If lastkey()#27 .and. nlastkey!=27
                    SetDefault(aReturn,"WORK")
                    RptStatus({|lEnd| AVGMDREL_BD()})
                    OurSpool(wnrel)
                 Endif
             else //Caso destino seja texto ou excel
                 WORK_EXPORT(iif(mv_par14==2,.f.,.t.))
                 return .t.
             endif
          ELSE
              Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
          ENDIF
          WORK->(DBCLOSEAREA())
      ENDIF
   ENDIF
   
   IF file(WorkFile)
      //Ferase(cNomArq) 
      E_EraseArq(WorkFile) //THTS - 23/10/2017 - Temporario no Banco de Dados
   ENDIF
RETURN .T.


*// Função que cria a work
*---------------------------------------------------------------------------------------
STATIC FUNCTION AVGMDWORK() // 08-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
    Local i:=0,nQTDE:=0
    Local cfilEG0:=xfilial("EG0"),cFilEG1:=xfilial("EG1"),cFilEG2:=xfilial("EG2"),cFilEEC:=xfilial("EEC"),cFilSW6:=xfilial("SW6"),cFilSAH:=xfilial("SAH") //Alcir - conceito multifilial
    Local cWhile:="",cProd_str:=""
    Local nLoadHour:=0,nDispHour:=0,nSomaLoad:=0,nSomaDisp:=0 //variaveis de trabalho para calculo do demurrage at load e at disch
    Local nRate:=0,cTimeAllowed :=0,nTimeAllowed:=0,nTimeNOR :=0,nLoadDay :=0,nDispDay :=0,EG1_QTDMT:=0 //valores demurrage at load e demurrage at port
    Local cQuery:="",cIF:=""
    Private Adata  
    
    EG0->(DBSETORDER(1))
    EG1->(DBSETORDER(1))    
    EG2->(DBSETORDER(1))    
    IF cModulo=="E" //caso módulo de exportação
        EEC->(DBSETORDER(1))
    ELSE
        SW6->(DBSETORDER(1))    
    ENDIF    
    Adata:= {}
    Aadd(Adata,{"WK_FILIAL",AVSX3("EG0_FILIAL",2),AVSX3("EG0_FILIAL",3),AVSX3("EG0_FILIAL",4)})
    Aadd(Adata,{"WK_MODULO",AVSX3("EG0_MODULO",2),AVSX3("EG0_MODULO",3),AVSX3("EG0_MODULO",4)})
    Aadd(Adata,{"WK_VESSEL",AVSX3("EG0_NAVIO",2),AVSX3("EG0_NAVIO",3),AVSX3("EG0_NAVIO",4)}) //NAVIO
    Aadd(Adata,{"WK_VIAGEM",AVSX3("EG0_VIAGEM",2),AVSX3("EG0_VIAGEM",3),AVSX3("EG0_VIAGEM",4)})
    Aadd(Adata,{"WK_DEST",AVSX3("EG0_DEST",2),AVSX3("EG0_DEST",3),AVSX3("EG0_DEST",4)})
    Aadd(Adata,{"WK_OWNER",AVSX3("EG0_FORNEC",2),AVSX3("EG0_FORNEC",3),AVSX3("EG0_FORNEC",4)})
    Aadd(Adata,{"WK_BUYER",AVSX3("EG0_CLIENT",2),AVSX3("EG0_CLIENT",3),AVSX3("EG0_CLIENT",4)})    
    Aadd(Adata,{"WK_PROD","C",30,0})
    Aadd(Adata,{"WK_BLDATE",AVSX3("EEC_DTEMBA",2),AVSX3("EEC_DTEMBA",3),AVSX3("EEC_DTEMBA",4)})
    Aadd(Adata,{"WK_QUANT","N",15,5}) //EG1_QTDMT
    Aadd(Adata,{"WK_MOEDA",AVSX3("EEC_MOEDA",2),AVSX3("EEC_MOEDA",3),AVSX3("EEC_MOEDA",4)})  //EG0_MOEDA
    Aadd(Adata,{"WK_CLAIM",AVSX3("EG0_OW_VL",2),AVSX3("EG0_OW_VL",3),AVSX3("EG0_OW_VL",4)})
    Aadd(Adata,{"WK_FIGURES",AVSX3("EG0_VALPRO",2),AVSX3("EG0_VALPRO",3),AVSX3("EG0_VALPRO",4)})
    Aadd(Adata,{"WK_RFIGURE",AVSX3("EG0_NEG_VL",2),AVSX3("EG0_NEG_VL",3),AVSX3("EG0_NEG_VL",4)})
    Aadd(Adata,{"WK_CLASSI" ,AVSX3("EG0_CLASSI",2),AVSX3("EG0_CLASSI",3),AVSX3("EG0_CLASSI",4)})
    Aadd(Adata,{"WK_DEMLOAD",AVSX3("EG0_OW_VL",2),AVSX3("EG0_OW_VL",3),AVSX3("EG0_OW_VL",4)})
    Aadd(Adata,{"WK_DEMDISP",AVSX3("EG0_OW_VL",2),AVSX3("EG0_OW_VL",3),AVSX3("EG0_OW_VL",4)})
    Aadd(Adata,{"WK_PAYDUE","D",8,0})
    Aadd(Adata,{"WK_PAYDT","D",8,0})
    Aadd(Adata,{"WK_OBS",AVSX3("EG0_OBS",2),AVSX3("EG0_OBS",3),AVSX3("EG0_OBS",4)})
    Aadd(Adata,{"WK_PREEMB",AVSX3("EEC_PREEMB",2),AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4)})
    
    If EasyEntryPoint("AVGMD150")
       ExecBlock("AVGMD150", .F., .F.,"CRIA_WORK")
    Endif
    
    WorkFile := E_CriaTrab(,Adata, "Work")  //THTS - 28/09/2017 - TE-6431 - Temporario no Banco de Dados
    cNomArq := "worki"+TEOrdBagExt()
    IndRegua("Work",cNomArq,"WK_FILIAL+WK_MODULO+WK_VESSEL+WK_VIAGEM+WK_OWNER+WK_BUYER+WK_MOEDA")
//   //Alcir - conceito multifilial
//  //Alcir - conceito multifilial
    IF cModulo=="E" //caso módulo de exportação
       afilEEC:=AvgSelectFil(.F.,"EEC") //Alcir - conceito multifilial
    ELSE
       afilSW6:=AvgSelectFil(.F.,"SW6") //Alcir - conceito multifilial    
    ENDIF

    //Cria code block com a avaliação dos filtros do pergunte
    IF !lTop 
        //caso codebase
        // AAF 11/02/05 - Alterações no Pergunte
        cFiltro:=" EG0->(EOF())==.F. "+;
        iif(mv_par01==1,"",IIF(mv_par01==2," .and. EMPTY(EG0->EG0_CLIENT)"," .and. !EMPTY(EG0->EG0_CLIENT)")) +;//CASO SEJA ARMADOR //CASO SEJA CLIENTE
        iif(!empty(mv_par02)," .and. EG1->EG1_COD_I ==mv_par02","")+; //Produto
        iif(!empty(mv_par03)," .and. EG0->EG0_FORNEC==mv_par03","")+; //Owner
        iif(!empty(mv_par04)," .and. EG0->EG0_FORLOJ==mv_par04","")+; //Owner Unit
        iif(!empty(mv_par05)," .and. EG0->EG0_CLIENT==mv_par05","")+; //Buyer
        iif(!empty(mv_par06)," .and. EG0->EG0_CLILOJ==mv_par06","")+; //Buyer Unit
        iif(!empty(mv_par07)," .and. EG0->EG0_NAVIO ==mv_par07","")+; //Vessel
        iif(!empty(mv_par08)," .and. EG0->EG0_VIAGEM==mv_par08","")+; //Trip
        iif(!empty(mv_par09)," .and. EG0->EG0_CODAGE==mv_par09","")+; //Inspetor
        iif(!empty(mv_par10)," .and. EG1->EG1_EMBARQ==mv_par10","")+; //Processo
        iif(mv_par11==2," .AND. Empty(EG0->EG0_PGT) .and. ( ( EG0->EG0_NEG_TP == '1' .AND. !Empty(EG0->EG0_CLIENT) ).OR. ( EG0->EG0_NEG_TP == '2' .AND. Empty(EG0->EG0_CLIENT) ) )","")+;//a Receber
        iif(mv_par11==3," .AND. Empty(EG0->EG0_PGT) .and. ( ( EG0->EG0_NEG_TP == '2' .AND. !EMPTY(EG0->EG0_CLIENT) ).OR. ( EG0->EG0_NEG_TP == '1' .AND. Empty(EG0->EG0_CLIENT) ) )","")  //a Pagar
        If !empty(mv_par12) .and. !empty(mv_par13)
           cFiltro+=iif(mv_par11==1,iif(cModulo=="E"," .and. (EEC->EEC_DTCONH >= mv_par12 .and. EEC->EEC_DTCONH <= mv_par13)",; //Filtro por data do BL na Exportaçao
                                                     " .and. (SW6->W6_DT_EMB  >= mv_par12 .and. SW6->W6_DT_EMB  <= mv_par13)"),;//Filtro por data de Embarque na Importacao
                                                     " .and. (EG0->EG0_VCT>=mv_par11 .and. EG0->EG0_VCT<=mv_par12)")            //Filtro por Data de Vencimento
        Endif
        If EasyEntryPoint("AVGMD150")
            ExecBlock("AVGMD150",.F.,.F.,"VALIDA_PERGUNTE_DBF")
        EndIf
    ELSE
    
        cFiltro:=" WK_EG0->(EOF())==.F. "+;
          iif(mv_par01==1,"",IIF(mv_par01==2," .and. EMPTY(WK_EG0->EG0_CLIENT)"," .and. !EMPTY(WK_EG0->EG0_CLIENT)")) +;                                                //CASO SEJA ARMADOR                      //CASO SEJA CLIENTE
          iif(!empty(mv_par02)," .and. WK_EG1->EG1_COD_I ==mv_par02","")+; //Produto
          iif(!empty(mv_par03)," .and. WK_EG0->EG0_FORNEC==mv_par03","")+; //Owner
          iif(!empty(mv_par04)," .and. WK_EG0->EG0_FORLOJ==mv_par04","")+; //Owner Unit
          iif(!empty(mv_par05)," .and. WK_EG0->EG0_CLIENT==mv_par05","")+; //Buyer
          iif(!empty(mv_par06)," .and. WK_EG0->EG0_CLILOJ==mv_par06","")+; //Buyer Unit
          iif(!empty(mv_par07)," .and. WK_EG0->EG0_NAVIO ==mv_par07","")+; //Vessel
          iif(!empty(mv_par08)," .and. WK_EG0->EG0_VIAGEM==mv_par08","")+; //Trip
          iif(!empty(mv_par09)," .and. WK_EG0->EG0_CODAGE==mv_par09","")+; //Inspetor
          iif(!empty(mv_par10)," .and. WK_EG1->EG1_EMBARQ==mv_par10","")+; //Processo
          iif(mv_par11==2," .AND. Empty(WK_EG0->EG0_PGT) .and. ( ( WK_EG0->EG0_NEG_TP == '1' .AND. !Empty(WK_EG0->EG0_CLIENT) ).OR. ( WK_EG0->EG0_NEG_TP == '2' .AND. Empty(WK_EG0->EG0_CLIENT) ) )","")+;//a Receber
          iif(mv_par11==3," .AND. Empty(WK_EG0->EG0_PGT) .and. ( ( WK_EG0->EG0_NEG_TP == '2' .AND. !EMPTY(WK_EG0->EG0_CLIENT) ).OR. ( WK_EG0->EG0_NEG_TP == '1' .AND. Empty(WK_EG0->EG0_CLIENT) ) )","")  //a Pagar
          
          if !empty(mv_par12) .and. !empty(mv_par13)
               cFiltro+=iif(mv_par11==1,iif(cModulo=="E"," .and. ( WK_PROC->EEC_DTCONH >= mv_par12 .and. WK_PROC->EEC_DTCONH <= mv_par13)",; //Filtro por data do BL na Exportaçao
                                                         " .and. ( WK_PROC->W6_DT_EMB  >= mv_par12 .and. WK_PROC->W6_DT_EMB  <= mv_par13)"),;//Filtro por data de Embarque na Importacao
                                                         " .and. ( WK_EG0->EG0_VCT >= mv_par11 .and. WK_EG0->EG0_VCT<=mv_par12)")             //Filtro por Data de Vencimento
          endif
          If EasyEntryPoint("AVGMD150")
              ExecBlock("AVGMD150",.F.,.F.,"VALIDA_PERGUNTE_TOP")
          EndIf
    ENDIF
       
    cFiltro:="("+cFiltro+")"


    //String com os campos filtrados
    cFiltro_Str+=iif(mv_par01#1,"Tipo: "+alltrim(iif(mv_par01==2,"Armador","Cliente"))+"   ","")+; //tipo de relatorio
             iif(!empty(mv_par02),"Product: "+alltrim(mv_par02)+"   ","")+;//
             iif(!empty(mv_par03),"Owner: "+alltrim(mv_par03)+"   ","")+;  //Owner
             iif(!empty(mv_par04),"Owner Unit: "+alltrim(mv_par04)+"   ","")+;  //Owner Unit
             iif(!empty(mv_par05),"Buyer: "+alltrim(mv_par05)+"   ","")+; //Buyer
             iif(!empty(mv_par06),"Buyer Unit: "+alltrim(mv_par06)+"   ","")+; //Buyer Unit
             iif(!empty(mv_par07),"Vessel: "+alltrim(mv_par07)+"   ","")+; //NAVIO
             iif(!empty(mv_par08),"Trip: "+alltrim(mv_par08)+"   ","")+; //VIAGEM
             iif(!empty(mv_par09),"Inspetor: "+alltrim(mv_par09)+"   ","")+; //Inspetor
             iif(!empty(mv_par10),"Processo: "+alltrim(mv_par10)+"   ","")+; //Processo
             iif(mv_par11#1,"Situação: "+alltrim(iif(mv_par11==2,"A receber","A pagar"))+"   ","") //
             if !empty(mv_par12) .and. !empty(mv_par13)
                  cFiltro_Str+="Período: "+dtoc(mv_par12)+" - "+dtoc(mv_par13)
             endif
             If EasyEntryPoint("AVGMD150")
                ExecBlock("AVGMD150", .F., .F.,"STRING_FILTROS")
             Endif

    FOR i:=1 TO LEN(afilSel) //Conceito multifilial 
        cfilEG0:=afilSel[i]
        cfilEG1:=iif(len(afilSel)==1 .and. alltrim(afilSel[1])=="",afilSel[1],afilSel[i]) //Alcir - conceito multifilial
        cfilEG2:=iif(len(afilSel)==1 .and. alltrim(afilSel[1])=="",afilSel[1],afilSel[i]) //Alcir - conceito multifilial
        /* AAF 10/02/05 - Não é necessário alterar cFilXXX pois é sempre o valor de xfilial ou o campo XXX_FILORI
        IF cModulo=="E" //caso módulo de exportação
           cfilEEC:=iif(len(afilEEC)==1 .and. alltrim(afilEEC[1])=="",afilEEC[1],afilSel[i]) //Alcir - conceito multifilial
        ELSE
           cfilSW6:=iif(len(afilSW6)==1 .and. alltrim(afilSW6[1])=="",afilSW6[1],afilSel[i]) //Alcir - conceito multifilial        
        ENDIF
        */
        
        IF !lTop
           //Versão codebase
           //CAPA DO DEMURRAGE
           EG0->(DBSEEK(cfilEG0+cModulo))
           DO WHILE EG0->(EOF())==.F. .AND. EG0->EG0_MODULO==cModulo
               //ITENS DO DEMURRAGE
               EG1->(DBSEEK(cfilEG1+cModulo+EG0->EG0_DEMURR))
               cWhile:={||EG1->(EG1_FILIAL+cModulo+EG1_DEMURR)==cfilEG1+EG0->EG0_MODULO+EG0->EG0_DEMURR}  //CBLOCK PARA WHILE NO EG1                  
               cWhile2:={||EG2->(EG2_FILIAL+cModulo+EG2_DEMURR)==cfilEG2+EG0->EG0_MODULO+EG0->EG0_DEMURR} //CBLOCK PARA WHILE NO EG2                  
               IF !EG1->(EOF()) .AND. EVAL(cWhile)
                   //EMBARQUE
                   IF cModulo=="E"
                       EEC->(DBSEEK(iIF(lFilOri,EG1->EG1_FILORI,cfilEEC)+EG1->EG1_EMBARQ))
                       cIF:={ || !EEC->(EOF())}
                   ELSE
                       SW6->(DBSEEK(iIF(lFilOri,EG1->EG1_FILORI,cfilSW6)+EG1->EG1_EMBARQ))
                       cIF:={ || !SW6->(EOF())}
                   ENDIF
                   
                   IF EVAL(cIF)
                       IF &(cFiltro) 
                           Begin Transaction
                           WORK->(RECLOCK("WORK",.T.))
                           WORK->WK_FILIAL:=afilSel[i]
                           WORK->WK_VESSEL:=EG0->EG0_NAVIO
                           WORK->WK_VIAGEM:=EG0->EG0_VIAGEM
                           WORK->WK_DEST:=EG0->EG0_DEST
                           WORK->WK_OWNER:=EG0->EG0_FORNEC
                           WORK->WK_BUYER:=EG0->EG0_CLIENT
                           WORK->WK_PREEMB:=EG1->EG1_EMBARQ
                           WORK->WK_BLDATE:=IIF(cModulo=="E",EEC->EEC_DTCONH,SW6->W6_DT_EMB)
                           WORK->WK_CLAIM:=EG0->EG0_OW_VL
                           WORK->WK_MOEDA:=EG0->EG0_MOEDA
                           WORK->WK_FIGURES:=EG0->EG0_VALPRO  
                           WORK->WK_RFIGURE:=EG0->EG0_NEG_VL  
                           WORK->WK_PAYDUE:=EG0->EG0_VCT
                           WORK->WK_PAYDT:=EG0->EG0_PGT
                           WORK->WK_OBS:=MSMM(EG0->EG0_OBS,30,1)
                           cProd_str:=""
                           EG1_QTDMT:=0
                           DO WHILE !EG1->(EOF()) .AND. EVAL(cWhile) .and. eval(iif(!empty(mv_par02),{ || EG1->EG1_COD_I==mv_par02},{ || .T.}))
                               cProd_str+=IIF(empty(cProd_str),alltrim(EG1->EG1_COD_I),","+alltrim(EG1->EG1_COD_I))
                               EG1_QTDMT+=EG1->EG1_QTDMT
                               EG1->(DBSKIP())
                           ENDDO
                           WORK->WK_QUANT:=EG1_QTDMT
                           WORK->WK_PROD:=cProd_str
                           
                           //** AAF 12/02/05 - Indica o tipo demurrage ou despatch.
                           WORK->WK_CLASSI:= EG0->EG0_CLASSI
                           //**
                                                      
                           //Calcula os campos Demurrage at load port e demurrage at disch port
                           nSomaLoad:=EG0->EG0_TLOAD
                           nSomaDisp:=EG0->EG0_TDISCH
                          /*
                          EG2->(DBSEEK(cfilEG2+cModulo+IIF(lExistDM,EG0->EG0_DEMURR,EG0->EG0_NAVIO+EG0->EG0_VIAGEM+EG0->EG0_DEST))) 
                           DO WHILE !EG2->(eof()) .AND. EVAL(cWhile2)
                               IF EG2->EG2_TP_LD = "1"  //load
                                   nSomaLoad +=((AVDIFTIME(EG2->EG2_FROM,EG2->EG2_TO)*EG2->EG2_RATE) / 1440 )
                               ELSE
                                   nSomaDisp +=((AVDIFTIME(EG2->EG2_FROM,EG2->EG2_TO)*EG2->EG2_RATE) / 1440 )
                               ENDIF
                               EG2->(dbskip())
                           ENDDO
                          */
                           
                           IF EG0->EG0_CLASSI== "2"       // Despatch
                              nRate:=EG0->EG0_DES_V
                           ELSEIF EG0->EG0_CLASSI== "1"   // Demurrage
                              nRate:= EG0->EG0_DEM_V
                           ELSE     // No Demurrage No Despatch
                              nRate:= 0  
                           ENDIF

                           IF EG0->EG0_DEM_TP == "2"      // Hora
                               WORK->WK_DEMLOAD:= (ABS( ((Val( Left(AVTime(nSomaLoad,2),2))*24) + Val(Substr(AVTime(nSomaLoad,2),4,2)) +(Val(Right(AVTime(nSomaLoad,2),2))/60))  )*nRate)
                               WORK->WK_DEMDISP:= (ABS( ((Val( Left(AVTime(nSomaDisp,2),2))*24) + Val(Substr(AVTime(nSomaDisp,2),4,2)) +(Val(Right(AVTime(nSomaDisp,2),2))/60))  )*nRate)                                                             
                           ELSE                          // Dias
                               cTimeAllowed := AVTime((EG0->EG0_CARGO/EG0->EG0_RAT_LD),2)    // Tempo Permitido em dias:horas:minutos
                               nTimeAllowed := Val(Left(cTimeAllowed,2))+(Val(SubStr(cTimeAllowed,4,2))/24)+(Val(Right(cTimeAllowed,2))/1440) //LRL 17/09/04 -Correção de Aredondamento
                               nTimeNOR := Val(Left(EG0->EG0_NOR,2))+(Val(SubStr(EG0->EG0_NOR,4,2))/24)+(Val(Right(EG0->EG0_NOR,2))/1440) 
                               nLoadDay := nSomaLoad - nTimeAllowed - nTimeNOR   
                               nDispDay := nSomaDisp - nTimeAllowed 
                               WORK->WK_DEMLOAD:= Val(Str((ABS(nLoadDay)*nRate),15,2))
                               WORK->WK_DEMDISP:= Val(Str((ABS(nDispDay)*nRate),15,2))
                           ENDIF
                           //FIM DO CALCULO DEMURRAGE AT PORT E DISCH
                           
                           //** AAF 12/02/05 - Demurrage a Pagar
                           If ( EG0->EG0_CLASSI == "1" .AND. Empty(EG0->EG0_CLIENT) ) .OR.;
                              ( EG0->EG0_CLASSI == "2" .AND. !Empty(EG0->EG0_CLIENT) )
                              
                              WORK->WK_DEMLOAD := WORK->WK_DEMLOAD * -1
                              WORK->WK_DEMDISP := WORK->WK_DEMDISP * -1
                           Endif
                           //**
                           
                           if EasyEntryPoint("AVGMD150")
                              ExecBlock("AVGMD150", .F., .F.,"GRV_WORK")
                           endif
                           
                           WORK->(MSUNLOCK())
                           End Transaction
                       ENDIF
                   ENDIF
	           ENDIF
               EG0->(DBSKIP())
	       ENDDO
        ELSE
   	       //VERSÃO TOP
           cQuery:="SELECT * from "+RetSqlName("EG0")+" EG0 "+;
           " WHERE EG0.EG0_FILIAL='"+cfilEG0+"' AND EG0.EG0_MODULO='"+cModulo+"' AND "+IIF(TcSrvType()<>"AS/400","EG0.D_E_L_E_T_<>'*'","EG0.@DELETED@<>'*'")
           cQuery:=ChangeQuery(cQuery)
           TcQuery cQuery ALIAS "WK_EG0" NEW
   	       TCSetField( "WK_EG0", "EG0_VCT", "D", 8, 0 )
   	       TCSetField( "WK_EG0", "EG0_PGT", "D", 8, 0 )
   	       
   	       DO WHILE WK_EG0->(EOF())==.F. 
               //ITENS DO DEMURRAGE
               cQuery:="SELECT * from "+RetSqlName("EG1")+" EG1 "+;
               " WHERE EG1.EG1_FILIAL='"+cfilEG1+"' AND EG1.EG1_MODULO='"+cModulo+"' "+;
               "AND EG1.EG1_DEMURR='"+WK_EG0->EG0_DEMURR+"' AND "+IIF(TcSrvType()<>"AS/400","EG1.D_E_L_E_T_<>'*'","EG1.@DELETED@<>'*'")
               cQuery:=ChangeQuery(cQuery)
               TcQuery cQuery ALIAS "WK_EG1" NEW
               //CODE BLOCK PARA AVALIAÇÃO DO WHILE
               cWhile:={||WK_EG1->(EG1_FILIAL+cModulo+EG1_DEMURR)==cfilEG1+WK_EG0->EG0_MODULO+WK_EG0->EG0_DEMURR}  //CBLOCK PARA WHILE NO EG1                  
               cWhile2:={||EG2->(EG2_FILIAL+cModulo+EG2_DEMURR)==cfilEG2+WK_EG0->EG0_MODULO+WK_EG0->EG0_DEMURR} //CBLOCK PARA WHILE NO EG2                  
               
               IF !WK_EG1->(EOF()) .AND. EVAL(cWhile)
                  //EMBARQUE
                  IF cModulo=="E" //caso módulo de exportação
                     cQuery:="SELECT * from "+RetSqlName("EEC")+" EEC "+;
                     " WHERE EEC.EEC_FILIAL='"+iIF(lFilOri,WK_EG1->EG1_FILORI,cfilEEC)+"' AND EEC.EEC_PREEMB='"+WK_EG1->EG1_EMBARQ+;
                     "' AND "+IIF(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_<>'*'","EEC.@DELETED@<>'*'")
                     cQuery:=ChangeQuery(cQuery)
                     TcQuery cQuery ALIAS "WK_PROC" NEW 
                     TCSetField( "WK_PROC", "EEC_DTCONH", "D", 8, 0 )
                  else//caso módulo de importação
                     cQuery:="SELECT * from "+RetSqlName("SW6")+" SW6 "+;
                     " WHERE SW6.W6_FILIAL='"+iIF(lFilOri,WK_EG1->EG1_FILORI,cfilSW6)+"' AND SW6.W6_HAWB='"+AvKey(WK_EG1->EG1_EMBARQ,"W6_HAWB")+;
                     "' AND "+IIF(TcSrvType()<>"AS/400","SW6.D_E_L_E_T_<>'*'","SW6.@DELETED@<>'*'")
                     cQuery:=ChangeQuery(cQuery)
                     TcQuery cQuery ALIAS "WK_PROC" NEW
                     TCSetField( "WK_PROC", "W6_DT_EMB", "D", 8, 0 )
                  endif

                  IF !WK_PROC->(EOF())
                       IF &(cFiltro)                             
                           Begin Transaction
                           WORK->(RECLOCK("WORK",.T.))
                           WORK->WK_FILIAL:=afilSel[i]
                           WORK->WK_VESSEL:=WK_EG0->EG0_NAVIO
                           WORK->WK_VIAGEM:=WK_EG0->EG0_VIAGEM
                           WORK->WK_DEST:=WK_EG0->EG0_DEST
                           WORK->WK_OWNER:=WK_EG0->EG0_FORNEC
                           WORK->WK_BUYER:=WK_EG0->EG0_CLIENT
                           WORK->WK_PREEMB:=WK_EG1->EG1_EMBARQ
                           WORK->WK_BLDATE:=IIF(cModulo=="E",WK_PROC->EEC_DTCONH,WK_PROC->W6_DT_EMB)
                           WORK->WK_CLAIM:=WK_EG0->EG0_OW_VL
                           WORK->WK_MOEDA:=WK_EG0->EG0_MOEDA
                           WORK->WK_FIGURES:=WK_EG0->EG0_VALPRO  
                           WORK->WK_RFIGURE:=WK_EG0->EG0_NEG_VL  
                           WORK->WK_PAYDUE:=WK_EG0->EG0_VCT
                           WORK->WK_PAYDT:=WK_EG0->EG0_PGT
                           WORK->WK_OBS:=MSMM(WK_EG0->EG0_OBS,30,1)
                           cProd_str:=""
                           EG1_QTDMT:=0
                           DO WHILE !WK_EG1->(EOF()) .AND. EVAL(cWhile) .and. eval(iif(!empty(mv_par02),{ || EG1->EG1_COD_I==mv_par02},{ || .T.}))
                               cProd_str+=IIF(empty(cProd_str),alltrim(WK_EG1->EG1_COD_I),","+alltrim(WK_EG1->EG1_COD_I))
                               EG1_QTDMT+=WK_EG1->EG1_QTDMT
                               WK_EG1->(DBSKIP())
                           ENDDO
                           WORK->WK_QUANT:=EG1_QTDMT
                           WORK->WK_PROD:=cProd_str

                           //** AAF 12/02/05 - Indica o tipo demurrage ou despatch.
                           WORK->WK_CLASSI:= WK_EG0->EG0_CLASSI
                           //**

                           //Calcula os campos Demurrage at load port e demurrage at disch port
                           nSomaLoad:=WK_EG0->EG0_TLOAD
                           nSomaDisp:=WK_EG0->EG0_TDISCH
                           IF WK_EG0->EG0_CLASSI== "2"       // Despatch
                              nRate:=WK_EG0->EG0_DES_V
                           ELSEIF WK_EG0->EG0_CLASSI== "1"   // Demurrage
                              nRate:= WK_EG0->EG0_DEM_V
                           ELSE     // No Demurrage No Despatch
                              nRate:= 0  
                           ENDIF

                           IF WK_EG0->EG0_DEM_TP == "2"      // Hora
                               WORK->WK_DEMLOAD:= (ABS( ((Val( Left(AVTime(nSomaLoad,2),2))*24) + Val(Substr(AVTime(nSomaLoad,2),4,2)) +(Val(Right(AVTime(nSomaLoad,2),2))/60))  )*nRate)
                               WORK->WK_DEMDISP:= (ABS( ((Val( Left(AVTime(nSomaDisp,2),2))*24) + Val(Substr(AVTime(nSomaDisp,2),4,2)) +(Val(Right(AVTime(nSomaDisp,2),2))/60))  )*nRate)
                           ELSE                          // Dias
                               cTimeAllowed := AVTime((WK_EG0->EG0_CARGO/WK_EG0->EG0_RAT_LD),2)    // Tempo Permitido em dias:horas:minutos
                               nTimeAllowed := Val(Left(cTimeAllowed,2))+(Val(SubStr(cTimeAllowed,4,2))/24)+(Val(Right(cTimeAllowed,2))/1440) //LRL 17/09/04 -Correção de Aredondamento
                               nTimeNOR := Val(Left(WK_EG0->EG0_NOR,2))+(Val(SubStr(WK_EG0->EG0_NOR,4,2))/24)+(Val(Right(WK_EG0->EG0_NOR,2))/1440) 
                               nLoadDay := nSomaLoad - nTimeAllowed - nTimeNOR   
                               nDispDay := nSomaDisp - nTimeAllowed 
                               WORK->WK_DEMLOAD:= Val(Str((ABS(nLoadDay)*nRate),15,2))
                               WORK->WK_DEMDISP:= Val(Str((ABS(nDispDay)*nRate),15,2))
                           ENDIF
                           //FIM DO CALCULO DEMURRAGE AT PORT E DISCH

                           //** AAF 12/02/05 - Demurrage a Pagar
                           If ( WK_EG0->EG0_CLASSI == "1" .AND.  Empty(WK_EG0->EG0_CLIENT) ) .OR.;
                              ( WK_EG0->EG0_CLASSI == "2" .AND. !Empty(WK_EG0->EG0_CLIENT) )
                              
                              WORK->WK_DEMLOAD := WORK->WK_DEMLOAD * -1
                              WORK->WK_DEMDISP := WORK->WK_DEMDISP * -1
                           Endif
                           //**

                           if EasyEntryPoint("AVGMD150")
                              ExecBlock("AVGMD150", .F., .F.,"GRV_WORK")
                           endif
                           
                           WORK->(MSUNLOCK())
                           End Transaction
                       ENDIF
                   ENDIF
                   WK_PROC->(DBCLOSEAREA())
	           ENDIF
               WK_EG1->(DBCLOSEAREA())
               WK_EG0->(DBSKIP())
	       ENDDO
	       WK_EG0->(DBCLOSEAREA())
	    ENDIF
    NEXT	
RETURN .T.

*// Função que cria o corpo do relatorio
*---------------------------------------------------------------------------------------
STATIC FUNCTION AVGMDREL_BD() // 08-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   LOCAL cGroup1:="-",cFilAtu:="-",nPos:=0,ni:=0,nif:=0

   LOCAL aFigure:={}  //somatoria por moeda do campo figure por navio/viagem/owner/buyer 
   LOCAL aRfigure:={} //somatoria por moeda do campo revfigure por navio/viagem/owner/buyer 
   LOCAL aClaim:={} //somatoria por moeda do campo claim por navio/viagem/owner/buyer 
   LOCAL aDemLP:={} //somatoria por moeda do campo load port por navio/viagem/owner/buyer 
   LOCAL aDemDP:={} //somatoria por moeda do campo load port por navio/viagem/owner/buyer 
   
   LOCAL Fil_Fig:={}   //somatoria por moeda do campo revfigure por filial
   LOCAL Fil_Rfig:={}   //somatoria por moeda do campo revfigure por filial
   LOCAL Fil_Claim:={}   //somatoria por moeda do campo claim por filial
   LOCAL Fil_DemLP:={}  //somatoria por moeda do campo load port por filial
   LOCAL Fil_DemDP:={} //somatoria por moeda do campo load port por filial

   LOCAL TFil_Fig:={}   //somatoria geral por moeda do campo revfigure por filial
   LOCAL TFil_Rfig:={}   //somatoria  geral por moeda do campo revfigure por filial
   LOCAL TFil_Claim:={}   //somatoria geral por moeda do campo claim por filial
   LOCAL TFil_DemLP:={}  //somatoria geral por moeda do campo load port por filial
   LOCAL TFil_DemDP:={} //somatoria geral por moeda do campo load port por filial

   LOCAL Tot_BlQnt:=0  //totais BL quant por navio/viagem e destino
   LOCAL Tot_BlQnt_F:=0  //totais BL quant filial ou geral
   LOCAL TG_BlQnt_F:=0  //totais geral BL quant filial ou geral

   LOCAL P_footer:=.F. //como falso não trará o rodapé com os totais
   Private cPictVl   := "@E 999,999,999.99"
   Private cBuyer    := ""
   Private cSayGroup := ""
   
   nLin:=61
   PLinha()
   DBSELECTAREA("WORK")
   work->(dbgotop())
  
   FOR nif:=1 TO LEN(afilSel) //Conceito multifilial 
      if work->(dbseek(afilSel[nif]))
          P_footer:=.F. //não imprimirá o ultimo rodapé com os totais do registro anterior no novo agrupamento
          DO WHILE WORK->(EOF())=.F. .and. work->wk_filial==afilSel[nif]
              //Quebra por filial
              if lMultiFil //caso multifilial //QUEBRA POR FILIAL
                 if cFilAtu#WORK->WK_FILIAL
                     if cFilAtu#"-"
                         nLin:=61 //Quebra de página
                         PLinha()
                     endif
                     aFigure:={}  //somatoria por moeda do campo figure por navio/viagem/destino 
                     aRfigure:={} //somatoria por moeda do campo revfigure por navio/viagem/destino
                     aClaim:={} //somatoria por moeda do campo claim por navio/viagem/destino  
                     aDemLP:={} //somatoria por moeda do campo load port por navio/viagem/owner/buyer 
                     aDemDP:={}                      

                     Fil_Fig:={}   //somatoria por moeda do campo revfigure por filial
                     Fil_Rfig:={}   //somatoria por moeda do campo revfigure por filial
                     Fil_Claim:={}   //somatoria por moeda do campo claim por filial
                     Fil_DemLP:={}  //somatoria por moeda do campo load port por filial
                     Fil_DemDP:={} //somatoria por moeda do campo load port por filial

                     Tot_BlQnt:=0  //totais BL quant por navio/viagem e destino
                     Tot_BlQnt_F:=0  //totais BL quant filial ou geral
                     
                     cFilAtu:=WORK->WK_FILIAL
                     @ nLin,1 PSAY __PrtFatLine()
                     PLinha()
                     @ nLin,1 PSAY STR0003+cFilAtu+" - "+AvgFilName({cFilAtu})[1]//"Filial: "
                     PLinha()
                    @ nLin,1 PSAY __PrtFatLine()
                 endif
              endif
 
              IF cGroup1#WORK->(WK_FILIAL+WK_VESSEL+WK_VIAGEM+WK_OWNER+WK_BUYER) //caso novo agrupamento de navio+viagem+porto
                  //TOTAIS POR NAVIO / VIAGEM / DESTINO
                  IF P_footer
                     @ nLin,1 PSAY replicate("-",218)
                     PLinha()          
                     //@ nLin,1 PSAY STR0019
                     //PLinha()                        
                     //@ nLin,1 PSAY replicate("-",218)
                     Tot_BlQnt_F+=Tot_BlQnt
                     Tot_BlQnt:=0
                     //PLinha()
                     //@ nLin,1 PSAY replicate("-",218)
                     //PLinha()
                     @ nLin,1 PSAY STR0004//"Total por Moeda"
                     @ nLin,37 PSAY  oemtoansi(TRANSFORM(Tot_BlQnt,"@E 999999999999999.99999"))
                     //PLinha()                                            
                     for ni:=1 to len(aFigure)
                        //** AAF 12/02/05 - Tipo do Total
                        If aDemDP[ni,3]+aDemLP[ni,3] > 0
                           If Empty(cBuyer)
                              cTipo := STR0005//"DESPATCH"
                           Else
                              cTipo := STR0006//"DEMURRAGE"
                           Endif
                        Elseif aDemDP[ni,3]+aDemLP[ni,3] < 0
                           If !Empty(cBuyer)
                              cTipo := STR0005//"DESPATCH"
                           Else
                              cTipo := STR0006//"DEMURRAGE"
                           Endif
                        Else
                           cTipo:= ""
                        Endif
                        //**
                        
                        @ nLin,60 psay aFigure[ni,2]
                        @ nLin,65 PSAY TRANSFORM(aClaim[ni,3],cPictVl)+"  "+TRANSFORM(aFigure[ni,3],cPictVl)+"  "+TRANSFORM(aRfigure[ni,3],cPictVl)+"   "+PADR(cTipo,16," ")+TRANSFORM(ABS(aDemLP[ni,3]),cPictVl)+"   "+TRANSFORM(ABS(aDemDP[ni,3]),cPictVl)
                        PLinha()          
                        //PLinha()          
                     next 
                     @ nLin,1 PSAY replicate("-",218)
                     PLinha()          
                     aFigure:={}
                     aRfigure:={}
                     aClaim:={}
                     aDemLP:={} 
                     aDemDP:={}
                  ENDIF 
                  P_footer:=.T.
                  PLinha()
                  cGroup1:=WORK->(WK_FILIAL+WK_VESSEL+WK_VIAGEM+WK_OWNER+WK_BUYER)       
                  @ nLin,1 PSAY __PrtFatLine()
                  PLinha()
                  cSayGroup := STR0007+WORK->WK_VESSEL+"   "+STR0008+WORK->WK_VIAGEM+"   "+STR0009+WORK->WK_OWNER+"   "+STR0010+WORK->WK_BUYER//"Vessel: "###"Trip: "###"Owner: "###"Buyer: "
                  
                  if EasyEntryPoint("AVGMD150")
                     ExecBlock("AVGMD150", .F., .F.,"IMP_AGRUPAMENTO")
                  endif
                  
                  @ nLin,1 PSAY cSayGroup
                 PLinha()
                 @ nLin,1 PSAY __PrtFatLine()
                 PLinha()
              ENDIF
              
              @ nLin,1 PSAY WORK->WK_PROD+"  "+LEFT(WORK->WK_PREEMB,17)+"  "+dtoc(WORK->WK_BLDATE)+"  "+TRANSFORM(WORK->WK_QUANT,AVSX3("EG1_QTDMT",6)/*"@E 999999999999999.99999"*/)+"  "+;
              WORK->WK_MOEDA+"  "+TRANSFORM(WORK->WK_CLAIM,cPictVl)+"  "+TRANSFORM(WORK->WK_FIGURES,cPictVl)+"  "+;
              TRANSFORM(WORK->WK_RFIGURE,cPictVl)+"   "+iIF(WORK->WK_CLASSI=="1",PADR(STR0006,13," "),iIF(WORK->WK_CLASSI=="2",PADR(STR0005,13," "),PADR(STR0011,13," ")))+"   "+transform(ABS(WORK->WK_DEMLOAD),cPictVl)+"   "+;//"DEMURRAGE"###"DESPATCH"###"NO DEM./DESP."
              transform(IIF(WORK->WK_DEMDISP=0,"FOB"+SPACE(16),ABS(WORK->WK_DEMDISP)),cPictVl)+"  "+DTOC(WORK->WK_PAYDUE)+"  "+DTOC(WORK->WK_PAYDT)+"  "+WORK->WK_OBS
              
              //Totais gerais
              Tot_BlQnt+=WORK->WK_QUANT     //totais BL quant por navio/viagem e destino
               //totais por navio / viagem e destino
              nPos:=ascan(aFigure,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_VESSEL+WORK->WK_VIAGEM+WORK->WK_OWNER+WORK->WK_BUYER+WORK->WK_MOEDA)})
              if nPos>0
                  aFigure[nPos,3]+=WORK->WK_FIGURES
                  aRfigure[nPos,3]+=WORK->WK_RFIGURE
                  aClaim[nPos,3]+=WORK->WK_CLAIM
                  aDemLP[nPos,3]+=WORK->WK_DEMLOAD
                  aDemDP[nPos,3]+=WORK->WK_DEMDISP
              else
                  aadd(aFigure,{(WORK->WK_FILIAL+WORK->WK_VESSEL+WORK->WK_VIAGEM+WORK->WK_OWNER+WORK->WK_BUYER+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_FIGURES})
                  aadd(aRfigure,{(WORK->WK_FILIAL+WORK->WK_VESSEL+WORK->WK_VIAGEM+WORK->WK_OWNER+WORK->WK_BUYER+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_RFIGURE})
                  aadd(aClaim,{(WORK->WK_FILIAL+WORK->WK_VESSEL+WORK->WK_VIAGEM+WORK->WK_OWNER+WORK->WK_BUYER+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_Claim})
                  aadd(aDemLP,{(WORK->WK_FILIAL+WORK->WK_VESSEL+WORK->WK_VIAGEM+WORK->WK_OWNER+WORK->WK_BUYER+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_DEMLOAD})
                  aadd(aDemDP,{(WORK->WK_FILIAL+WORK->WK_VESSEL+WORK->WK_VIAGEM+WORK->WK_OWNER+WORK->WK_BUYER+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_DEMDISP})
              endif

              //totais por filial
              nPos:=ascan(Fil_Fig,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_MOEDA)})
              if nPos>0
                  Fil_Fig[nPos,3]+=WORK->WK_FIGURES
                  Fil_RFig[nPos,3]+=WORK->WK_RFIGURE
                  Fil_Claim[nPos,3]+=WORK->WK_claim
                  Fil_DemLP[nPos,3]+=WORK->WK_DEMLOAD
                  Fil_DemDP[nPos,3]+=WORK->WK_DEMDISP              
              else
                  aadd(Fil_Fig,{(WORK->WK_FILIAL+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_FIGURES})
                  aadd(Fil_RFig,{(WORK->WK_FILIAL+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_RFIGURE})
                  aadd(Fil_Claim,{(WORK->WK_FILIAL+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_claim})
                  aadd(Fil_DemLP,{(WORK->WK_FILIAL+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_DEMLOAD})
                  aadd(Fil_DemDP,{(WORK->WK_FILIAL+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_DEMDISP})                                    
              endif 

              //totais gerais por filial
              if lMultiFil //se multifilial
                 TG_BlQnt_F+=WORK->WK_QUANT     //totais BL quant geral
                 nPos:=ascan(TFil_Fig,{|x| x[1]==WORK->WK_MOEDA})
                 if nPos>0
                     TFil_Fig[nPos,2]+=WORK->WK_FIGURES
                     TFil_Rfig[nPos,2]+=WORK->WK_RFIGURE
                     TFil_Claim[nPos,2]+=WORK->WK_claim 
                     TFil_DemLP[nPos,2]+=WORK->WK_DEMLOAD  //somatoria geral por moeda do campo load port por filial
                     TFil_DemDP[nPos,2]+=WORK->WK_DEMDISP //somatoria geral por moeda do campo load port por filial
                 else
                     aadd(TFil_Fig,{WORK->WK_MOEDA,WORK->WK_FIGURES})
                     aadd(TFil_Rfig,{WORK->WK_MOEDA,WORK->WK_RFIGURE})
                     aadd(TFil_Claim,{WORK->WK_MOEDA,WORK->WK_claim})
                     aadd(TFil_DemLP,{WORK->WK_MOEDA,WORK->WK_DEMLOAD})
                     aadd(TFil_DemDP,{WORK->WK_MOEDA,WORK->WK_DEMDISP})                                          
                 endif 
              endif
              PLinha()            
              cBuyer := WORK->WK_BUYER
              WORK->(DBSKIP())
          ENDDO
         //Ultimo subtotais
         @ nLin,1 PSAY replicate("-",218)
         PLinha()          
         //@ nLin,1 PSAY STR0019
        
         Tot_BlQnt_F+=Tot_BlQnt
         
         //PLinha()                        
        
         //@ nLin,1 PSAY replicate("-",218)
         //PLinha()
         @ nLin,1 PSAY STR0004//"Total por Moeda"
         @ nLin,37 PSAY oemtoansi(TRANSFORM(Tot_BlQnt,"@E 999999999999999.99999"))
         //PLinha()
         for ni:=1 to len(aFigure)
            //** AAF 12/02/05 - Tipo do Total
            If aDemDP[ni,3]+aDemLP[ni,3] > 0
               If Empty(cBuyer)
                  cTipo := STR0005//"DESPATCH"
               Else
                  cTipo := STR0006//"DEMURRAGE"
               Endif
            Elseif aDemDP[ni,3]+aDemLP[ni,3] < 0
               If !Empty(cBuyer)
                  cTipo := STR0005//"DESPATCH"
               Else
                  cTipo := STR0006//"DEMURRAGE"
               Endif
            Else
               cTipo:= ""
            Endif
            //**
         
            @ nLin,60 psay aFigure[ni,2]
            @ nLin,65 PSAY TRANSFORM(aClaim[ni,3],cPictVl)+"  "+TRANSFORM(aFigure[ni,3],cPictVl)+"  "+TRANSFORM(aRfigure[ni,3],cPictVl)+"   "+PADR(cTipo,16," ")+TRANSFORM(Abs(aDemLP[ni,3]),cPictVl)+"   "+TRANSFORM(Abs(aDemDP[ni,3]),cPictVl)
            PLinha()
            //PLinha()
         next 
         @ nLin,1 PSAY replicate("-",218)
         PLinha() 
         //
         //Totais geral
         PLinha()                            
         if lMultiFil //caso multifilial //QUEBRA POR FILIAL
             //@ nLin,1 PSAY replicate("-",218)
             PLinha()
             @ nLin,1 PSAY STR0012+cFilAtu+" - "+AvgFilName({cFilAtu})[1]//"Total por Filial : "
             //PLinha()
             //@ nLin,1 PSAY replicate("-",218)
             //PLinha()
         Else
             //@ nLin,1 PSAY replicate("-",218)
             PLinha()
             @ nLin,(220/2 - Len(STR0013)/2) PSAY STR0013 //"TOTAL GERAL"
             //PLinha()
             //@ nLin,1 PSAY replicate("-",218)
             //PLinha()
         Endif

         PLinha() 
         @ nLin,1 PSAY replicate("-",218)
         PLinha()          
         //@ nLin,1 PSAY STR0019
         
         //PLinha()                        
        
         //@ nLin,1 PSAY replicate("-",218)
         //PLinha()
         @ nLin,1 PSAY STR0004 //"Total por Moeda"
         @ nLin,37 PSAY oemtoansi(TRANSFORM(Tot_BlQnt_F,"@E 999999999999999.99999"))
         //PLinha()                                            
         for ni:=1 to len(Fil_Fig)
       
            @ nLin,60 psay Fil_Fig[ni,2]
            @ nLin,65 PSAY TRANSFORM(Fil_Claim[ni,3],cPictVl)+"  "+TRANSFORM(Fil_Fig[ni,3],cPictVl)+"  "+TRANSFORM(Fil_Rfig[ni,3],cPictVl)+"   "+Space(16)+TRANSFORM(Fil_DemLP[ni,3],cPictVl)+"   "+TRANSFORM(Fil_DemDP[ni,3],cPictVl)
            PLinha()          
            //PLinha()          
         next 
         @ nLin,1 PSAY replicate("-",218)
         PLinha() 
         Fil_Fig:={} 
         Fil_Rfig:={}   //somatoria por moeda do campo revfigure por filial
         Fil_Claim:={}
         Fil_DemDp:={}
         Fil_DemLp:={}
      endif
   next 
   
   //Total geral 
   if lMultiFil //se multifilial
      nLin:=61
      PLinha()
      @ nLin,(220/2 - Len(STR0013)/2) PSAY STR0013 //"TOTAL GERAL"
      //PLinha()
      //@ nLin,1 PSAY replicate("-",218)
      //PLinha()
      
      PLinha()
      @ nLin,1 PSAY replicate("-",218)
      PLinha()          
      //@ nLin,1 PSAY STR0019

      //PLinha()                        
      //@ nLin,1 PSAY replicate("-",218)
      //PLinha()
      @ nLin,1 PSAY STR0004//"Total por Moeda"
      @ nLin,37 PSAY oemtoansi(TRANSFORM(TG_BlQnt_F,"@E 999999999999999.99999"))
      //PLinha()                                            
      for ni:=1 to len(TFil_Fig)        
         @ nLin,60 psay TFil_Fig[ni,1]
         @ nLin,65 PSAY TRANSFORM(TFil_Claim[ni,2],cPictVl)+"  "+TRANSFORM(TFil_Fig[ni,2],cPictVl)+"  "+TRANSFORM(TFil_Rfig[ni,2],cPictVl)+"   "+Space(16)+TRANSFORM(TFil_DemLP[ni,2],cPictVl)+"   "+TRANSFORM(TFil_DemDP[ni,2],cPictVl)
         PLinha()          
         //PLinha()          
      next 
      @ nLin,1 PSAY replicate("-",218)
      PLinha() 
   endif
   ms_flush() 
Return .t.

*// Função responsavel pel quebra de linha e página LINEFEED
*---------------------------------------------------------------------------------------
STATIC FUNCTION PLinha() // 12-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   private cHtitulo:=STR0014//" Products     Proc.              BL Date      BL Quant(MT)  Currency      Claim         Figures  Revised Figures  Classific.     Vl.at Load Port Vl.at Disch Port  Paym.Due   Paym.Dt  Obs"
   if nLin>60
      if EasyEntryPoint("AVGMD150")
         ExecBlock("AVGMD150", .F., .F.,"QUEBRA_PAGINA")
      endif
      
      nLin:=Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5])
      nLin:=nLin+1   

      //string com os filtros dos perguntes concatenados
      if !empty(cFiltro_Str) 
          //@ nLin,1 PSAY replicate("*",218)
          //nLin:=nLin+1         
          @ nLin,01 psay STR0015+"  "+cFiltro_Str//"Filtrado por "
          nLin:=nLin+1         
          //@ nLin,1 PSAY replicate("*",218)
          //nLin:=nLin+1         
      endif
      @ nLin,00 psay cHtitulo 
      nLin:=nLin+2
   else
      nLin:=nLin+1
      @ nLin,00 psay " "
   endif
Return .t.

*// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
                                    // AAF - 12/02/05 - Correção na Exportação para Excel.
*---------------------------------------------------------------------------------------
   Local oExcelApp
   //Local cDirDocs := MsDocPath()
   Local cPath	:= AllTrim(GetTempPath())
   DbSelectArea("Work")
   if lExcel
         Work->(dbCloseArea())
         CpyS2T(".\"+CurDir()+WorkFile+".DBF" , cPath, .T. )
         If ! ApOleClient( 'MsExcel' )
            MsgStop(STR0016)//"Ms-Excel não instalado"
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
