// Programador : Alcir Alves   
// Data Desenvolvimento- 05-02-05  
// Objetivo - Relatório de financiamento - Juros não pagos
// considera itens de contratos com dominio de eventos contabeis de 640 até 649 e 670 até 679 (juros e juros forçado)
// PRW : EFFAJ150
// Versão Codebase e Topconnect    
// Alterações                                
// -----------------------------------------------------------------
//          Alexandre Caetano Sciancalepre Jr
//          02/Março/2005 
//          Retirada as verificações de EF3_BAN_FI/EF3_PRACA        
// -----------------------------------------------------------------
// ----------------------------------------------------------------------
// PLB - Pedro Luiz Baroni
// 26/04/2006
// Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
// Inclusao de Impressao dos Financiamentos de Importacao
// ----------------------------------------------------------------------



#INCLUDE "EFFAJ150.CH"                 
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"                 

*// Função principal de acesso ao menu       - Alcir Alves Alcir$
*---------------------------------------------------------------------------------------
FUNCTION EFFAJ150() // 05-02-05   - Alcir Alves
*---------------------------------------------------------------------------------------
   //**  PLB 26/04/06
   Local cSeqSX1   := "" ,;
         cVarSX1   := "" ,;
         cValidSX1 := "" ,;
         nPergunte := 0
   //**
   PRIVATE afilSel:={},lTop
   PRIVATE aReturn:= {"Zebrado",1,"", 2, 1, 1, "", 1}
   Private nLin:=0,M_pAg:=1,Is_MFill:=.T.,nRegSint:={},nTotTime:={},nTimeUsed:=0  //caso seja multifilial
   Private cFiltro:="",cFiltro_Str:="" //validação com os filtros do pergunte
   Private cNomArq:="worki",cNomArq2:="EF3I",WorkFile:="",cModulo:=iif(nModulo==17,"I","E") //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados
   Private aDados:=afilSel:={} 
   PRIVATE lExistBCO := iif(EF3->(FieldPos("EF3_BAN_FI")) > 0 .AND. EF3->(FieldPos("EF3_PRACA")) > 0 .AND. EF2->(FieldPos("EF2_BAN_FI")) > 0 .AND. EF2->(FieldPos("EF2_PRACA")) > 0 ,.T.,.F.) //ALCIR ALVES -14-02-05  CASO EXISTA NOVOS CAMPOS DA CHAVE EF1,EF2 E EF3
   PRIVATE cfilEF1:=XFILIAL("EF1"),cfilEF3:=XFILIAL("EF3"),cfilEEC:=XFILIAL("EEC"),cfilSA6:=XFILIAL("SA6")
   //** PLB - 25/04/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
   Private cFiltroF3Fin := "E"              // Variavel utilizada no F3 "EFA"
   Private lEvCont := .F.                   // Variavel utilizada no F3 "EFA"
   Private lCadFin := ChkFile("EF7")        // Cadastro de Tipos de Financiamento
   Private cTpModu := "E"       
   Private aDescCpo:= {}
   Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                        EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                        EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                        EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                        EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0
   //**
   
   // ACSJ - 02/03/2005 --------------- INICIO
   if !lExistBCO
      MsgInfo( STR0028 + Chr(13) + Chr(10) +;
               STR0029)   //       #define STR0028 "Existem atualizacöes a serem realizadas no Financiamento"
   	                      //       #define STR0029 "      Atualize o modulo antes de utiliza-lo.      "
      Return .t.   	                      
   Endif   
   // --------------------------------- FIM

   #IFDEF TOP
     lTop := .T.
   #ElSE
     lTop := .F.
   #ENDIF  
   DBSELECTAREA("SX1")
   SX1->( dbSetOrder(1) )
   //** PLB 26/04/06
   nPergunte := 1
   cSeqSX1 := PadL(AllTrim(Str(nPergunte)),2,"0")
   cVarSX1 := IIF(nPergunte<10,Str(nPergunte,1),CHR(ASC("A")+nPergunte-10))

   afilSel:=AvgSelectFil(.T.,"EF1") //Alcir - conceito multifilial
   if afilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
      Is_MFill := Posicione("SX2",1,"EEQ","X2_MODO") == "E" .AND. VerSenha(115) .AND. Posicione("SX2",1,"EF3","X2_MODO") == "C"  //TRP-30/01/08
   
      IF Pergunte("EFFJNP",.T.)
          Adados:= {"",;
                 "",; 
                 "",; 
                 "2",;
                 "G",;
                 220,;
                 IIF(lEFFTpMod,IIF(cTpModu=="I",STR0033,STR0019),STR0019),;
                 "",;
                 STR0001+iif(IIF(lEFFTpMod,mv_par10,mv_par08) == 1, STR0026, STR0027),;
                 { "Zebrado", 1,"", 1, 2, 1, "",1 },;
                 "EFFAJ150",;             
                  }

          If lEFFTpMod
             Do Case
                Case mv_par01 == 1
                   cTpModu := "E"
                Case mv_par01 == 2
                   cTpModu := "I"
             End Case
          EndIf
          Processa({||EFFAJWORK()})
          IF WORK->(EasyReccount("WORK")) > 0
             IF IIF(lEFFTpMod,mv_par11,mv_par09)==1  //Caso destino seja impressora
                 wnrel:=SetPrint("WORK","EFFAJ150",,STR0001+iif(IIF(lEFFTpMod,mv_par10,mv_par08)==1, STR0026, STR0027),"","","",.F.,.F.,.F.,"G")
                 IF lastkey()#27 .and. nlastkey!=27
                    SetDefault(aReturn,"WORK")
                    RptStatus({|lEnd| EFFAJR_BD()})
                    OurSpool(wnrel)
                 ENDIF
             ELSE //Caso destino seja texto ou excel
                   WORK_EXPORT(iif(IIF(lEFFTpMod,mv_par11,mv_par09)==2,.f.,.t.))
                   return .t.
             ENDIF
          ELSE
              Msgstop(STR0006) //"Não existe dados para esta consulta"	
          ENDIF
          WORK->(DBCLOSEAREA())
      ENDIF
   ENDIF
   
   IF file(cNomArq2)
      Ferase(cNomArq2)    
   ENDIF
   IF file(cNomArq)
      Ferase(cNomArq) 
   ENDIF
RETURN .T.


*// Função que cria a work
*---------------------------------------------------------------------------------------
STATIC FUNCTION EFFAJWORK() // 05-02-05 - Alcir Alves
*---------------------------------------------------------------------------------------
    Local Adata,i:=0,cWhile1:="" //caso o os filtros de produtos ou embarque estejam preenchidos esta variavel retorna false se não encontrar nenhum registro compativel
    Local Praca_t:=Banco_t:=Import_t:=Loja_t:=Tipo_ctr:="" //praca e banco 
    Local Data_ctr:=ctod(space(8)) //Data do contrato
    Local Sql_filt:="" //Filtro para consulta em SQL
    Adata:= {}
    Aadd(Adata,{"WK_FILIAL",AVSX3("EF3_FILIAL",2),AVSX3("EF3_FILIAL",3),AVSX3("EF3_FILIAL",4)}) //FILIAL
    Aadd(aDescCpo,{AVSX3("EF3_FILIAL",5)}) //FILIAL
    If lEFFTpMod
       Aadd(Adata,{"WK_TPMODU",AVSX3("EF3_TPMODU",2),AVSX3("EF3_TPMODU",3),AVSX3("EF3_TPMODU",4)}) //TIPO DO MODULO
       Aadd(aDescCpo,{AVSX3("EF3_TPMODU",5)}) //TIPO DO MODULO
    EndIf
    Aadd(Adata,{"WK_BANCO",AVSX3("EF1_BAN_FI",2),AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4)}) //BANCO
    Aadd(aDescCpo,{AVSX3("EF1_BAN_FI",5)}) //BANCO
    Aadd(Adata,{"WK_BNC_D",AVSX3("A6_NOME",2),AVSX3("A6_NOME",3),AVSX3("A6_NOME",4)}) //NOME BANCO    
    Aadd(aDescCpo,{AVSX3("A6_NOME",5)}) //NOME BANCO    
    Aadd(Adata,{"WK_CONTRAT",AVSX3("EF3_CONTRA",2),AVSX3("EF3_CONTRA",3),AVSX3("EF3_CONTRA",4)}) //CONTRATO
    Aadd(aDescCpo,{AVSX3("EF3_CONTRA",5)}) //CONTRATO
    If lEFFTpMod
       Aadd(Adata,{"WK_SEQCNT",AVSX3("EF3_SEQCNT",2),AVSX3("EF3_SEQCNT",3),AVSX3("EF3_SEQCNT",4)}) //SEQUENCIA DO CONTRATO
       Aadd(aDescCpo,{AVSX3("EF3_SEQCNT",5)}) //SEQUENCIA DO CONTRATO
    EndIf
    Aadd(Adata,{"WK_DATAC",AVSX3("EF1_DT_CON",2),AVSX3("EF1_DT_CON",3),AVSX3("EF1_DT_CON",4)}) //DATA DO CONTRATO
    Aadd(aDescCpo,{AVSX3("EF1_DT_CON",5)}) //DATA DO CONTRATO
    Aadd(Adata,{"WK_TPCONT",AVSX3("EF1_TP_FIN",2),AVSX3("EF1_TP_FIN",3),AVSX3("EF1_TP_FIN",4)}) //TIPO DE CONTRATO
    Aadd(aDescCpo,{AVSX3("EF1_TP_FIN",5)}) //TIPO DE CONTRATO
    Aadd(Adata,{"WK_EVENTO",AVSX3("EF3_CODEVE",2),AVSX3("EF3_CODEVE",3),AVSX3("EF3_CODEVE",4)}) //EVENTO
    Aadd(aDescCpo,{AVSX3("EF3_CODEVE",5)}) //EVENTO
    Aadd(Adata,{"WK_DESEVE",AVSX3("EC6_DESC",2),AVSX3("EC6_DESC",3),AVSX3("EC6_DESC",4)}) //DESC.EVENTO    
    Aadd(aDescCpo,{AVSX3("EC6_DESC",5)}) //DESC.EVENTO    
    Aadd(Adata,{"WK_PRACA",AVSX3("EF3_PRACA",2),AVSX3("EF3_PRACA",3),AVSX3("EF3_PRACA",4)}) //PRACA
    Aadd(aDescCpo,{AVSX3("EF3_PRACA",5)}) //PRACA
    Aadd(Adata,{"WK_MOEDA",AVSX3("EF1_MOEDA",2),AVSX3("EF1_MOEDA",3),AVSX3("EF1_MOEDA",4)}) //MOEDA DO CONTRATO
    Aadd(aDescCpo,{AVSX3("EF1_MOEDA",5)}) //MOEDA DO CONTRATO
    Aadd(Adata,{"WK_VLJUROS",AVSX3("EF3_VL_MOE",2),AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4)}) //VALOR DO JUROS NA MOEDA
    Aadd(aDescCpo,{AVSX3("EF3_VL_MOE",5)}) //VALOR DO JUROS NA MOEDA
    Aadd(Adata,{"WK_PROC",AVSX3("EF3_PREEMB",2),AVSX3("EF3_PREEMB",3),AVSX3("EF3_PREEMB",4)}) //PROCESSO
    Aadd(aDescCpo,{AVSX3("EF3_PREEMB",5)}) //PROCESSO
    Aadd(Adata,{"WK_INV",AVSX3("EF3_INVOIC",2),AVSX3("EF3_INVOIC",3),AVSX3("EF3_INVOIC",4)}) //INVOICE
    Aadd(aDescCpo,{AVSX3("EF3_INVOIC",5)}) //INVOICE
    // PLB
    Aadd(Adata,{"WK_INV_P",AVSX3("EF3_PARC",2),AVSX3(IIF(lEFFTpMod,"EF3_LINHA","EF3_PARC"),3),AVSX3(IIF(lEFFTpMod,"EF3_LINHA","EF3_PARC"),4)}) //PARCELA DA INVOICE
    Aadd(aDescCpo,{AVSX3(IIF(lEFFTpMod,"EF3_LINHA","EF3_PARC"),5)}) //PARCELA DA INVOICE
    Aadd(Adata,{"WK_INV_V",AVSX3("EF3_VL_INV",2),AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4)}) //VALOR DA INVOICE
    Aadd(aDescCpo,{AVSX3("EF3_VL_INV",5)}) //VALOR DA INVOICE
    Aadd(Adata,{"WK_INV_M",AVSX3("EF3_MOE_IN",2),AVSX3("EF3_MOE_IN",3),AVSX3("EF3_MOE_IN",4)}) //MOEDA DA INVOICE
    Aadd(aDescCpo,{AVSX3("EF3_MOE_IN",5)}) //MOEDA DA INVOICE
    Aadd(Adata,{"WK_INV_C",AVSX3("EEC_IMPORT",2),AVSX3("EEC_IMPORT",3),AVSX3("EEC_IMPORT",4)}) //CLIENTE DA INVOICE
    Aadd(aDescCpo,{AVSX3("EEC_IMPORT",5)}) //CLIENTE DA INVOICE
    Aadd(Adata,{"WK_LOJA",AVSX3("EEC_IMLOJA",2),AVSX3("EEC_IMLOJA",3),AVSX3("EEC_IMLOJA",4)}) //LOJA CLIENTE DA INVOICE       
    Aadd(aDescCpo,{AVSX3("EEC_IMLOJA",5)}) //LOJA CLIENTE DA INVOICE       
 
     If Select("Work") > 0
       Work->( DBCloseArea() )       
    EndIf
    
    //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados    
    WorkFile := E_CriaTrab(,Adata,"Work")
    IndRegua("Work",cNomArq+TEOrdBagExt(),IIF(lEFFTpMod,"WK_TPMODU+","")+"WK_FILIAL"+"+WK_BANCO+WK_CONTRAT+WK_PRACA"+IIF(lEFFTpMod,"+WK_SEQCNT",""))
 
    IF !lTop
        DBSELECTAREA("EF1")
        EF1->(DBSETORDER(1))
        DBSELECTAREA("EF3")
        IndRegua("EF3",cNomArq2+TEOrdBagEXT(),IIF(lEFFTpMod,"EF3_TPMODU+","")+"EF3_FILIAL+"+"EF3_CODEVE+EF3_BAN_FI+EF3_CONTRATO+"+"EF3_PRACA"+IIF(lEFFTpMod,"EF3_SEQCNT+",""))
    ENDIF   
//   //Alcir - conceito multifilial
//  //Alcir - conceito multifilial
    IF !lTop 
        //caso codebase
        //  //Cria code block com a avaliação dos filtros do pergunte
        cFiltro:=" EF3->(EOF())==.F. "
        //** PLB 26/04/06
        If lEFFTpMod
           cFiltro += IIF(cTpModu $ "E/I"," .AND. EF1->EF1_TPMODU=cTpModu","")+;
                      iif(!empty(mv_par02)," .AND. EF1->EF1_DT_CON>=mv_par02","")+;
                      iif(!empty(mv_par03)," .AND. EF1->EF1_DT_CON<=mv_par03","")+;
                      iif(!empty(mv_par04)," .AND. EF1->EF1_CONTRA=mv_par04","")+;
                      iif(!empty(mv_par05)," .AND. EF1->EF1_SEQCNT=mv_par05","")+;
                      iif(!empty(mv_par06)," .AND. EF1->EF1_TP_FIN=mv_par06","")+;
                      iif(!empty(mv_par07)," .AND. EF3->EF3_CODEVE=mv_par07","")+;
                      iif(!empty(mv_par08)," .AND. EF1->EF1_EXPORT=mv_par08","")+;
                      iif(!empty(mv_par09)," .AND. Loja_t=mv_par09","")
        Else
           cFiltro += iif(!empty(mv_par01)," .AND. EF1->EF1_DT_CON>=mv_par01","")+;
                      iif(!empty(mv_par02)," .AND. EF1->EF1_DT_CON<=mv_par02","")+;     
                      iif(!empty(mv_par03)," .AND. EF1->EF1_CONTRA=mv_par03","")+;        
                      iif(!empty(mv_par04)," .AND. EF1->EF1_TP_FIN=mv_par04","")+;
                      iif(!empty(mv_par05)," .AND. EF3->EF3_CODEVE=mv_par05","")+;
                      iif(!empty(mv_par06)," .AND. EF1->EF1_EXPORT=mv_par06","")+;
                      iif(!empty(mv_par07)," .AND. Loja_t=mv_par07","")
        EndIf
        //**
    ELSE  
        //Caso top
        // Cria complemento de consulta SQL para avaliação dos filtros do pergunte
        cFiltro:=" WK_EF3->(EOF())==.F. "
        //** PLB 26/04/06
        If lEFFTpMod
           Sql_Filt:= IIF(cTpModu $ "E/I"," AND EF1.EF1_TPMODU='"+cTpModu+"'","")+;
                      iif(!empty(mv_par02)," AND EF1.EF1_DT_CON>="+;        
                      (alltrim(str(year(mv_par02)))+alltrim(strzero(month(mv_par02),2,0))+alltrim(strzero(day(mv_par02),2,0))),"")+;
                      iif(!empty(mv_par03)," AND EF1.EF1_DT_CON<="+;
                      (alltrim(str(year(mv_par03)))+alltrim(strzero(month(mv_par03),2,0))+alltrim(strzero(day(mv_par03),2,0))),"")+;
                      iif(!empty(mv_par04)," AND EF1.EF1_CONTRA='"+mv_par04+"'","")+;
                      IIF(!Empty(mv_par05)," AND EF1.EF1_SEQCNT='"+mv_par05+"'","")+;
                      iif(!empty(mv_par06)," AND EF1.EF1_TP_FIN='"+mv_par06+"'","")+;
                      iif(!empty(mv_par07)," AND EF3.EF3_CODEVE='"+mv_par07+"'","")
           Sql_Filt1:=Sql_Filt+;
                      iif(!empty(mv_par08)," AND EF1.EF1_EXPORT='"+mv_par08+"'","")+;
                      iif(!empty(mv_par09)," AND EEC.EEC_IMLOJA='"+mv_par09+"'","")
           Sql_Filt2:=Sql_Filt+;
                      iif(!empty(mv_par08)," AND EF3.EF3_FORN  ='"+mv_par08+"'","")+;
                      iif(!empty(mv_par09)," AND EF3.EF3_LOJAFO='"+mv_par09+"'","")
        //**
        Else
           Sql_Filt:=iif(!empty(mv_par01)," AND EF1.EF1_DT_CON>="+;        
           (alltrim(str(year(mv_par01)))+alltrim(strzero(month(mv_par01),2,0))+alltrim(strzero(day(mv_par01),2,0))),"")+;
           iif(!empty(mv_par02)," AND EF1.EF1_DT_CON<="+;
           (alltrim(str(year(mv_par02)))+alltrim(strzero(month(mv_par02),2,0))+alltrim(strzero(day(mv_par02),2,0))),"")+;
           iif(!empty(mv_par03)," AND EF1.EF1_CONTRA='"+mv_par03+"'","")+;
           iif(!empty(mv_par04)," AND EF1.EF1_TP_FIN='"+mv_par04+"'","")+;
           iif(!empty(mv_par05)," AND EF3.EF3_CODEVE='"+mv_par05+"'","")
           Sql_Filt1 := Sql_Filt+;
                        iif(!empty(mv_par06)," AND EF1.EF1_EXPORT='"+mv_par06+"'","")+;
                        iif(!empty(mv_par07)," AND EEC.EEC_IMLOJA='"+mv_par07+"'","")
           Sql_Filt2 := Sql_Filt
        EndIf
    ENDIF
    cFiltro:="("+cFiltro+")"
    //String com os campos filtrados
    //** PLB 26/04/06
    If lEFFTpMod
       cFiltro_Str:=IIF(cTpModu $ "E/I",STR0030+IIF(cTpModu=="E","Exportacao","Importacao")+"   ","")+;
                    iif(!empty(mv_par02),STR0008+dtoc(mv_par02)+"   ","")+;
                    iif(!empty(mv_par03),STR0009+dtoc(mv_par03)+"   ","")+;
                    iif(!empty(mv_par04),STR0010+mv_par04+"   ","")+;
                    iif(!empty(mv_par05),STR0031+mv_par05+"   ","")+;
                    IIF(!empty(mv_par06),STR0011+IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+mv_par06,"EF7_DESCRI"),Tabela("CG",mv_par06,.F.)),"")+;
                    IIF(!empty(mv_par07),STR0012+mv_par07,"")+;
                    IIF(!empty(mv_par08),STR0013+mv_par08,"")+;
                    IIF(!empty(mv_par09),STR0014+mv_par09,"")
    //**
    Else
       cFiltro_Str:=iif(!empty(mv_par01),STR0008+dtoc(mv_par01)+"   ","")+;
                    iif(!empty(mv_par02),STR0009+dtoc(mv_par02)+"   ","")+;
                    iif(!empty(mv_par03),STR0010+mv_par03+"   ","")+;
                    IIF(!empty(mv_par04),STR0011+IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+mv_par04,"EF7_DESCRI"),Tabela("CG",mv_par04,.F.)),"")+;
                    IIF(!empty(mv_par05),STR0012+mv_par05,"")+;
                    IIF(!empty(mv_par06),STR0013+mv_par06,"")+;
                    IIF(!empty(mv_par07),STR0014+mv_par07,"")
    EndIf
  
    afilEC6:=AvgSelectFil(.F.,"EC6") //CADASTRO DE EVENTOS
    afilSA6:=AvgSelectFil(.F.,"SA6") //CADASTRO DE BANCOS
    FOR i:=1 TO LEN(afilSel) //Conceito multifilial 
        cfilEF1:=afilSel[i]        
        cfilEF3:=afilSel[i]
        cfilEC6:=iif(len(afilEC6)==1 .and. alltrim(afilEC6[1])=="",aFilEC6[1],afilSel[i])
        cfilSA6:=iif(len(afilSA6)==1 .and. alltrim(afilSA6[1])=="",aFilSA6[1],afilSel[i])
        IF !lTop
           //Versão codebase
           EF3->(DBSEEK(cfilEF3+"6"))
           cWhile1:={ || EF3->(EOF())==.F. .AND. EF3->EF3_FILIAL=cfilEF3 .AND. LEFT(ALLTRIM(EF3_CODEVE),1)=="6"}
        ELSE
 
           //cQuery :=    "SELECT * from "+RetSqlName("EF1")+" EF1,"+RetSqlName("EF3")+" EF3,"+RetSqlName("EEC")+" EEC "+;  
           //             " WHERE EF3.EF3_FILIAL='"+cfilEF3+"'"
           cQuery :=    "SELECT EF1.EF1_BAN_FI, EF1.EF1_TP_FIN, EF1.EF1_MOEDA, EF1.EF1_DT_CON, EF3.EF3_CONTRA, "+;
                        IIF(lEFFTpMod,"EF1.EF1_TPMODU, EF3.EF3_SEQCNT, ","")+"EF3.EF3_FILIAL, "+;
                        "EF3.EF3_CODEVE, EF3.EF3_VL_MOE, EF3.EF3_VL_INV, EF3.EF3_MOE_IN, EF3.EF3_PREEMB, "+;
                        "EF3.EF3_INVOIC, EF3.EF3_PARC,"+IIF(lEFFTpMod," EF3.EF3_LINHA, EF3.EF3_ORIGEM, ","")+" EF3.EF3_PRACA, "+;
                        "EEC.EEC_IMPORT, EEC.EEC_IMLOJA "+;
                        "from "+RetSqlName("EF1")+" EF1,"+RetSqlName("EF3")+" EF3,"+RetSqlName("EEC")+" EEC "+;
                        " WHERE EF3.EF3_FILIAL='"+cfilEF3+"' "
                        
           cQuery2 :=   " UNION SELECT EF1.EF1_BAN_FI, EF1.EF1_TP_FIN, EF1.EF1_MOEDA, EF1.EF1_DT_CON, EF3.EF3_CONTRA, "+;
                        IIF(lEFFTpMod,"EF1.EF1_TPMODU, EF3.EF3_SEQCNT, ","")+"EF3.EF3_FILIAL, "+;
                        "EF3.EF3_CODEVE, EF3.EF3_VL_MOE, EF3.EF3_VL_INV, EF3.EF3_MOE_IN, "+;
                        IIF(lEFFTpMod,"EF3.EF3_HAWB, EF3.EF3_INVIMP, EF3.EF3_PARC, EF3.EF3_LINHA, EF3.EF3_ORIGEM, ","'', '', EF3.EF3_PARC, ")+;
                        "EF3.EF3_PRACA, "+;
                        IIF(lEFFTpMod,"EF3.EF3_FORN, EF3.EF3_LOJAFO ","'', '' ")+;
                        "from "+RetSqlName("EF1")+" EF1,"+RetSqlName("EF3")+" EF3"+;
                        " WHERE EF3.EF3_FILIAL='"+cfilEF3+"'"
           
           // ACSJ - 01/03/2005 -------- INICIO
           if IIF(lEFFTpMod,mv_par10,mv_par08) == 1 // Pago
              cQuery += " AND EF3.EF3_DT_EVE <>'"+SPACE(AVSX3("EF3_DT_EVE",3))+"' AND EF3.EF3_TX_MOE>0"
              cQuery2+= " AND EF3.EF3_DT_EVE <>'"+SPACE(AVSX3("EF3_DT_EVE",3))+"' AND EF3.EF3_TX_MOE>0"
           Else                                
              cQuery += " AND EF3.EF3_TX_MOE<=0 "  // PLB 28/04/06   //" AND EF3.EF3_DT_EVE='"+SPACE(AVSX3("EF3_DT_EVE",3))+
              cQuery2+= " AND EF3.EF3_TX_MOE<=0 "  // PLB 28/04/06   //" AND EF3.EF3_DT_EVE='"+SPACE(AVSX3("EF3_DT_EVE",3))+
           Endif    
           // ACSJ - 01/03/2005 -------- FIM
           
           cQuery += " AND EF3.EF3_CODEVE IN ('640','641','642','643','644','645','646','647','648','649','670','671','672','673','674','675','676','677','678','679')"+;
                     " AND "+IIF(TcSrvType()<>"AS/400","EF3.D_E_L_E_T_<>'*'","EF3.@DELETED@<>'*'")+" AND " +;
                     " EF1.EF1_FILIAL='"+cfilEF1+"' AND EF1.EF1_CONTRA=EF3.EF3_CONTRA"+;
                     IIF(lEFFTpMod," AND EF1.EF1_TPMODU=EF3.EF3_TPMODU AND EF1.EF1_SEQCNT=EF3.EF3_SEQCNT","")+;
                     " AND EF1.EF1_BAN_FI=EF3.EF3_BAN_FI AND EF1.EF1_PRACA=EF3.EF3_PRACA "+; //" AND EF3.EF3_ORIGEM<>'SWB'","")+
                     " AND "+IIF(TcSrvType()<>"AS/400","EF1.D_E_L_E_T_<>'*'","EF1.@DELETED@<>'*'")+" AND "+;
                     " EEC.EEC_FILIAL="+If(Is_MFill, "EF3.EF3_FILORI", "'"+cfilEEC+"'")+" AND EEC.EEC_PREEMB=EF3.EF3_PREEMB AND "+IIF(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_<>'*'","EEC.@DELETED@<>'*'")+" "+;
                     Sql_Filt1//+" ORDER BY EF3.EF3_FILIAL,"+IIF(lEFFTpMod,"EF3.EF3_TPMODU,","")+"EF3.EF3_CONTRA,"+IIF(lEFFTpMod,"EF3.EF3_SEQCNT,","")+"EF3.EF3_CODEVE "
                     
           cQuery2 +=" AND EF3.EF3_CODEVE IN ('640','641','642','643','644','645','646','647','648','649','670','671','672','673','674','675','676','677','678','679','710','711','712','713','714','715','716','717','718','719')"+;
                     " AND "+IIF(TcSrvType()<>"AS/400","EF3.D_E_L_E_T_<>'*'","EF3.@DELETED@<>'*'")+" AND " +;
                     " EF1.EF1_FILIAL='"+cfilEF1+"' AND EF1.EF1_CONTRA=EF3.EF3_CONTRA"+;
                     IIF(lEFFTpMod," AND EF1.EF1_TPMODU=EF3.EF3_TPMODU AND EF1.EF1_SEQCNT=EF3.EF3_SEQCNT",;
                     " AND (EF3.EF3_PREEMB=' ' OR EF3.EF3_PREEMB='') ")+; //" AND EF3.EF3_ORIGEM='SWB' ",
                     " AND EF1.EF1_BAN_FI=EF3.EF3_BAN_FI AND EF1.EF1_PRACA=EF3.EF3_PRACA "+;
                     " AND "+IIF(TcSrvType()<>"AS/400","EF1.D_E_L_E_T_<>'*'","EF1.@DELETED@<>'*'")+;
                     Sql_Filt2+" ORDER BY "+IIF(lEFFTpMod,"EF1_TPMODU,","")+" EF3_FILIAL, EF3_CONTRA,"+IIF(lEFFTpMod,"EF3_SEQCNT, ","")+"EF3_CODEVE "

            cQuery:=ChangeQuery(cQuery+cQuery2)
            TcQuery cQuery ALIAS "WK_EF3" NEW
            TCSetField("WK_EF3", "EF1_DT_CON", "D", 8, 0 )
            cWhile1:={ || WK_EF3->(EOF())==.F.}
        ENDIF
           
        DO WHILE EVAL(cWhile1) 
            
            //caso Arquitetura CodeBase
            IF !lTop
               //CASO OS EVENTOS TENHA INICIAIS DIFERENTES DE 64 OU 67 NÃO SÃO CONSIDERADOS JUROS
               IF LEFT(ALLTRIM(EF3->EF3_CODEVE),2)<>"64" .AND. LEFT(ALLTRIM(EF3->EF3_CODEVE),2)<>"67"
                  EF3->(DBSKIP())
                  LOOP
               ENDIF                
               
               // ACSJ - 01/03/2005 --------------- Inicio
               If IIF(lEFFTpMod,mv_par10,mv_par08) == 2 // Em Aberto
                  IF !EMPTY(EF3->EF3_DT_EVE) .OR. !EMPTY(EF3->EF3_TX_MOE) //JUROS FORAM PAGOS - ACSJ
                     EF3->(DBSKIP())
                     LOOP
                  ENDIF
               Else 
                  IF EMPTY(EF3->EF3_DT_EVE) .OR. EMPTY(EF3->EF3_TX_MOE) // JUROS NAO FORAM PAGOS - ACSJ
                     EF3->(DBSKIP())
                     LOOP
                  ENDIF
               Endif
               // ACSJ - 01/03/2005 --------------- Fim               
               
               //caso encontre o processo vinculados
               IF !EEC->(dbseek(If(Is_MFill, EF3->EF3_FILORI, cfilEEC)+EF3->EF3_PREEMB)) //CASO NA EXISTA O PROCESSO 
                   EF3->(DBSKIP())                                          
                   LOOP               
               ENDIF
               
               Import_t:=EEC->EEC_IMPORT  //CLIENTE IMPORTADOR
               Loja_t:=EEC->EEC_IMLOJA //LOJA DO IMPORTADOR
               Praca_t:="-"  //PRACA
               Banco_t:="-"  //BANCO
               If lEFFTpMod
                  cCond1:={ || !EF1->(DBSEEK(cfilEF1+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))}
               Else
                  cCond1:={ || !EF1->(DBSEEK(cfilEF1+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA))}
               EndIf
               IF eval(cCond1)//CASO NÃO EXISTA O CONTRATO 
                  EF3->(DBSKIP())                                          
                  LOOP
               ELSE                  
                  Praca_t:=EF3->EF3_PRACA   //PRAÇA
                  Banco_t:=EF1->EF1_BAN_FI //BANCO
                  If lEFFTpMod //** PLB 26/04/06
                     Seq_ctr := EF1->EF1_SEQCNT  // Sequencia do Contrato
                  EndIf
                  Tipo_ctr:=EF1->EF1_TP_FIN //TIPO DE CONTRATO
                  data_ctr:=EF1->EF1_DT_CON //data do contrato
               ENDIF
            ELSE
               If lEFFTpMod  //** PLB 26/04/06
                  Seq_ctr := WK_EF3->EF3_SEQCNT  // Sequencia do Contrato
               EndIf
               Import_t:=WK_EF3->EEC_IMPORT  //CLIENTE IMPORTADOR
               Loja_t:=WK_EF3->EEC_IMLOJA //LOJA DO IMPORTADOR
               Banco_t:=WK_EF3->EF1_BAN_FI   //BANCO
               Tipo_ctr:=WK_EF3->EF1_TP_FIN   //TIPO DE CONTRATO
               Praca_t:=WK_EF3->EF3_PRACA    //PRAÇA           
               Data_ctr:=WK_EF3->EF1_DT_CON //data do contrato
            ENDIF      
            //--
            IF &(cFiltro)
               Begin Transaction
                  WORK->(RECLOCK("WORK",.T.))  
                  WORK->WK_FILIAL:=cfilEF3 //FILIAL
                  WORK->WK_BANCO:=Banco_t //BANCO
                  WORK->WK_BNC_D:=POSICIONE("SA6",1,cfilSA6+Banco_t,"A6_NOME") //DESCRICAO DO BANCO
                  WORK->WK_PRACA:=Praca_t  //PRACA
                  WORK->WK_TPCONT:=Tipo_ctr   //TIPO DE CONTRATO 01=ACC  02=ACF
                  WORK->WK_CONTRAT:=IIF(!lTop,EF3->EF3_CONTRA,WK_EF3->EF3_CONTRA) //NR.CONTRATO
                  IF lEFFTpMod // PLB 26/04/06
                     WORK->WK_TPMODU := IIF(!lTop,EF1->EF1_TPMODU,WK_EF3->EF1_TPMODU)
                     WORK->WK_SEQCNT := Seq_ctr
                  EndIf
                  WORK->WK_DATAC:=Data_ctr
                  WORK->WK_EVENTO:=IIF(!lTop,EF3->EF3_CODEVE,WK_EF3->EF3_CODEVE)   //EVENTO
                  WORK->WK_DESEVE:=POSICIONE("EC6",1,cfilEC6+"EXPORT"+IIF(!lTop,EF3->EF3_CODEVE,WK_EF3->EF3_CODEVE),"EC6_DESC") //DESC. EVENTO
                  WORK->WK_MOEDA:=IIF(!lTop,EF1->EF1_MOEDA,WK_EF3->EF1_MOEDA) //MOEDA
                  WORK->WK_VLJUROS:=IIF(!lTop,EF3->EF3_VL_MOE,WK_EF3->EF3_VL_MOE)  //JUROS
                  WORK->WK_PROC:=IIF(!lTop,EF3->EF3_PREEMB,WK_EF3->EF3_PREEMB) //PROCESSO
                  WORK->WK_INV:=IIF(!lTop,EF3->EF3_INVOIC,WK_EF3->EF3_INVOIC)  //NUMERO DA INVOICE
                  WORK->WK_INV_P:=AllTrim(IIF(!lTop,EF3->EF3_PARC,IIF(lEFFTpMod .And. WK_EF3->EF3_ORIGEM="SWB",WK_EF3->EF3_LINHA,WK_EF3->EF3_PARC)))  //PARCELA DA INVOICE
                  
                  //WORK->WK_INV_V:=IIF(!lTop,EF3->EF3_VL_INV,WK_EF3->EF3_VL_INV) //VALOR DA INVOICE

                  WORK->WK_INV_V := RetVal600()
                 
                  WORK->WK_INV_M:=IIF(!lTop,EF3->EF3_MOE_IN,WK_EF3->EF3_MOE_IN) //MOEDA DA INVOICE
                  WORK->WK_INV_C:=Import_t //CLIENTE IMPORTADOR
                  WORK->WK_LOJA:=Loja_t // loja do importador
                  WORK->(MSUNLOCK())         
               end Transaction
        	ENDIF
        	
        	IF !lTop
               EF3->(DBSKIP())
            ELSE
               WK_EF3->(DBSKIP())               
            ENDIF   
	    ENDDO
	    IF lTop
	       WK_EF3->(DBCLOSEAREA())
	    ENDIF
    NEXT	
RETURN .T.

Static Function RetVal600()
Local nVal := 0
Local aOrd := SaveOrd("EF3")
   
   EF3->(DbSetOrder(1))
   If EF3->(DbSeek(xFilial("EF3")+Work->(WK_TPMODU+WK_CONTRAT+WK_BANCO+WK_PRACA+WK_SEQCNT+"600"+AvKey(Work->WK_INV_P, "EF3_PARC")+WK_INV)))
      nVal := EF3->EF3_VL_INV
   EndIf

RestOrd(aOrd, .T.)
Return nVal

*// Função que cria o corpo do relatorio
*---------------------------------------------------------------------------------------
STATIC FUNCTION EFFAJR_BD() // 10-02-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   PRIVATE cFilAtu:="-",cBancoAtu:="-",cContAtu:="-",lQuebra:=.F.
   PRIVATE tInv_Moe:={}  //total valor dA invoice  do contrato por moeda
   PRIVATE tCont_Moe:={} //total valor do juros do contrato por moeda
   PRIVATE ftInv_Moe:={}  //total valor dA invoice  por filial e moeda
   PRIVATE ftCont_Moe:={} //total valor do juros por filial e moeda
   Private cTpModuAtu := "-"
   
   nLin:=61
   PLinha()
   DBSELECTAREA("WORK")
   WORK->(dbgotop())
   DO WHILE WORK->(EOF())==.F. 
       //** PLB 26/04/06 - Quebra por Tipo Modulo
       If lEFFTpMod .And. cTpModu=="A" .And. cTpModuAtu#WORK->WK_TPMODU
           If cTpModuAtu#"-" //caso não seja o primeiro cabeçalho
              Bnc_Foot() //imprime o rodapé com os totais por moeda no agrupamento por banco
              Fil_Foot() //Imprime o rodapé com os totais por filial
              If WORK->WK_TPMODU=="I"
                  aDados[7] :=  STR0033
              EndIf
              nLin:=61 //Quebra de página
              PLinha()
           EndIf
           cTpModuAtu:=WORK->WK_TPMODU
           @ nLin,1 PSAY __PrtFatLine()
           PLinha()           
           @ nLin,1 PSAY  __PrtLeft(STR0030+IIF(WORK->WK_TPMODU=="E","Exportacao","Importacao"))
           PLinha()           
           @ nLin,1 PSAY __PrtFatLine()
           lQuebra   := .T.
           cFilAtu   := "-"
           cBancoAtu := "-"
       EndIf
       //**
       //Quebra por filial
       IF Is_MFill //caso multifilial //QUEBRA POR FILIAL
           IF cFilAtu#WORK->WK_FILIAL .or. lQuebra==.T.
                IF cFilAtu#"-"
                    Bnc_Foot() //imprime o rodapé com os totais por moeda no agrupamento por banco
                    Fil_Foot() //Imprime o rodapé com os totais por filial
                    nLin:=61 //Quebra de página
                    PLinha()
                ENDIF
                cFilAtu:=WORK->WK_FILIAL
                FtInv_Moe:={}  //Total da invoice por moeda filial
                FtCont_Moe:={} //total valor do juros do contrato por moeda e filial
                @ nLin,1 PSAY __PrtFatLine()
                PLinha()
                @ nLin,1 PSAY STR0007+cFilAtu+" - "+AvgFilName({cFilAtu})[1]
                PLinha()          
                @ nLin,1 PSAY __PrtFatLine()
                lQuebra=.T.    //força a quebra de subgrupo  
                cBancoAtu:="-"
           ENDIF
       ELSE
           cFilAtu:=WORK->WK_FILIAL
       ENDIF
       IF cBancoAtu#WORK->WK_BANCO .or. lQuebra==.T.
           if cBancoAtu#"-" //caso não seja o primeiro cabeçalho
                Bnc_Foot() //imprime o rodapé com os totais por moeda no agrupamento por banco
           endif
           PLinha()
           @ nLin,1 PSAY  replicate(".",218)
           PLinha()
           @ nLin,1 PSAY  STR0015+WORK->WK_BANCO+"-"+WORK->WK_BNC_D
           PLinha()           
           @ nLin,1 PSAY  replicate(".",218)
           cBancoAtu:=WORK->WK_BANCO
           tInv_Moe:={}  //Total da invoice por moeda
           tCont_Moe:={} //total valor do juros do contrato por moeda
           lQuebra:=.T.
       ENDIF
       IF cContAtu#WORK->WK_CONTRAT .or. lQuebra==.T.
           lQuebra:=.F.
           PLinha()
           @ nLin,1 PSAY  STR0016+WORK->WK_CONTRAT+space(6)+IIF(lEFFTpMod,STR0032+WORK->WK_SEQCNT+Space(6),"")+STR0017+IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+WORK->WK_TPCONT,"EF7_DESCRI"),Tabela("CG",WORK->WK_TPCONT,.F.))+space(6)+STR0020+DTOC(WORK->WK_DATAC) //Contrato + Tipo de Contrato + data do contrato
           PLinha()
           cContAtu:=WORK->WK_CONTRAT
       ENDIF
       @ nLin,1 PSAY WORK->WK_PRACA+SPACE(4)+;
                     WORK->WK_EVENTO+"-"+WORK->WK_DESEVE+space(4)+WORK->WK_MOEDA+space(4)+TRANSFORM(WORK->WK_VLJUROS,AVSX3("EF3_VL_MOE",6))+;
                     space(16)+WORK->WK_PROC+space(4)+WORK->WK_INV+Space(IIF(lEFFTpMod,2,4))+WORK->WK_INV_P+space(16)+WORK->WK_INV_M+space(4)+TRANSFORM(WORK->WK_INV_V,AVSX3("EF3_VL_INV",6))+;
                     space(4)+WORK->WK_INV_C+space(4)+WORK->WK_LOJA
       BancoMoe() //calcula total por moeda agrupado por banco e filial
       PLinha()
       WORK->(DBSKIP())
   ENDDO
   //Totais por banco e filial
   BancoMoe()
   Bnc_Foot()  
   Fil_Foot()
   //
   Ms_flush() 
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
          @ nLin,00 psay STR0021+"  "+cFiltro_Str
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
   DbSelectArea("Work")
   TR350ARQUIVO("work",,aClone(aDescCpo),,,lExcel)

Return .T.

*// Função responsavel pelo calculo de total por moeda agrupado por banco e por filial 11-02-05
*---------------------------------------------------------------------------------------
STATIC FUNCTION BancoMoe()
*---------------------------------------------------------------------------------------
        local nPos:=0
        //Totais por banco
        IF !(empty(WORK->WK_INV_M) .AND. WORK->WK_INV_V<=0 .AND. empty(WORK->WK_MOEDA) .AND. WORK->WK_VLJUROS<=0)
            nPos:=ascan(tInv_Moe,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_BANCO+WORK->WK_INV_M)})
            IF nPos>0
               tInv_Moe[nPos,3]+=WORK->WK_INV_V
            ELSE
               aadd(tInv_Moe,{(WORK->WK_FILIAL+WORK->WK_BANCO+WORK->WK_INV_M),WORK->WK_INV_M,WORK->WK_INV_V})
            ENDIF
            nPos:=ascan(tCont_Moe,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_BANCO+WORK->WK_MOEDA)})
            IF nPos>0
               tCont_Moe[nPos,3]+=WORK->WK_VLJUROS
            ELSE
               aadd(tCont_Moe,{(WORK->WK_FILIAL+WORK->WK_BANCO+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_VLJUROS})
            ENDIF
           //totais por filial
           nPos:=ascan(ftInv_Moe,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_INV_M)})
           IF nPos>0
               ftInv_Moe[nPos,3]+=WORK->WK_INV_V
           ELSE
              aadd(ftInv_Moe,{(WORK->WK_FILIAL+WORK->WK_INV_M),WORK->WK_INV_M,WORK->WK_INV_V})
           ENDIF
           nPos:=ascan(ftCont_Moe,{|x| x[1]==(WORK->WK_FILIAL+WORK->WK_MOEDA)})
           IF nPos>0
              ftCont_Moe[nPos,3]+=WORK->WK_VLJUROS
           ELSE
              aadd(ftCont_Moe,{(WORK->WK_FILIAL+WORK->WK_MOEDA),WORK->WK_MOEDA,WORK->WK_VLJUROS})
           ENDIF
        ENDIF
Return .T.    

*// Função responsavel pela exibição dos totais de moeda por banco  11-02-05
*---------------------------------------------------------------------------------------
Static function Bnc_Foot()
*---------------------------------------------------------------------------------------
      local ni:=0
      @ nLin,1 PSAY  replicate(".",218)
      PLinha()
      @ nLin,1 PSAY  STR0018
      PLinha()
//      For ni=1 to len(tInv_Moe)
//         @ nLin,43 PSAY tCont_Moe[ni,2]+space(4)+transform(tCont_Moe[ni,3],AVSX3("EF3_VL_INV",6))+space(82)+tInv_Moe[ni,2]+space(4)+transform(tInv_Moe[ni,3],AVSX3("EF3_VL_INV",6))
//         PLinha()
//      next 
      //** PLB 27/04/06 - Controla a impressao quando ha mais moedas na invoice do que nos juros (e vice-versa)
      For ni=1 to Len(IIF(Len(tCont_Moe)>Len(tInv_Moe),tCont_Moe,tInv_Moe))
         @ nLin,43 PSAY IIF(ni>Len(tCont_Moe),Space(25),tCont_Moe[ni,2]+space(4)+transform(tCont_Moe[ni,3],AVSX3("EF3_VL_INV",6)))+IIF(ni>Len(tInv_Moe),"",space(82)+tInv_Moe[ni,2]+space(4)+transform(tInv_Moe[ni,3],AVSX3("EF3_VL_INV",6)))
         PLinha()
      Next 
      //**
      @ nLin,1 PSAY  replicate(".",218)
      PLinha()
Return .t.

*// Função responsavel pela exibição dos totais de moeda por filial  11-02-05
*---------------------------------------------------------------------------------------
Static function Fil_Foot()
*---------------------------------------------------------------------------------------
      local ni:=0
      @ nLin,1 PSAY __PrtFatLine()
      PLinha()
      @ nLin,1 PSAY  IIF(Is_MFill,STR0022,STR0024) //CASO MULTIFILIAL 
      PLinha()
//      for ni=1 to len(ftInv_Moe)
//         @ nLin,43 PSAY ftCont_Moe[ni,2]+space(4)+transform(ftCont_Moe[ni,3],AVSX3("EF3_VL_INV",6))+space(82)+ftInv_Moe[ni,2]+space(4)+transform(ftInv_Moe[ni,3],AVSX3("EF3_VL_INV",6))
//         PLinha()
//      next 
      //** PLB 27/04/06 - Controla a impressao quando ha mais moedas na invoice do que nos juros (e vice-versa)
      For ni=1 to Len(IIF(Len(tCont_Moe)>Len(tInv_Moe),tCont_Moe,tInv_Moe))
         @ nLin,43 PSAY IIF(ni>Len(tCont_Moe),Space(25),tCont_Moe[ni,2]+space(4)+transform(tCont_Moe[ni,3],AVSX3("EF3_VL_INV",6)))+IIF(ni>Len(tInv_Moe),"",space(82)+tInv_Moe[ni,2]+space(4)+transform(tInv_Moe[ni,3],AVSX3("EF3_VL_INV",6)))
         PLinha()
      Next 
      //**
      @ nLin,1 PSAY __PrtFatLine()
      PLinha()
Return .t.


//** PLB 27/04/06 - Validacao dos Perguntes SX1
*---------------------------------------------------------------------------------------
Function AJ150ValPerg(cField)
*---------------------------------------------------------------------------------------

 If cField=="TpModu"
   If mv_par01 == 1
      cFiltroF3Fin := cTpModu := "E"
      mv_par06 := "  "
      mv_par07 := "   "
   ElseIf mv_par01 == 2
      cFiltroF3Fin := cTpModu := "I"
      mv_par06 := "  "
      mv_par07 := "   "
   Else
      cFiltroF3Fin := "E/I"
      cTpModu := "A"
   EndIf   
 
 ElseIf cField=="TpFin"
    If lCadFin
       Return AvgExistCpo("EF7",IIF(lEFFTpMod,mv_par06,mv_par04)) .And. Posicione("EF7",1,xFilial("EF7")+IIF(lEFFTpMod,mv_par06,mv_par04),"EF7_TP_FIN")$IIF(cTpModu=="A","E/I",cTpModu)
    Else
       Return AvgExistCpo("SX5","CG"+IIF(lEFFTpMod,mv_par06,mv_par04))
    EndIf
 
// ElseIf cField=="SeqCnt"
//    If !Empty(mv_par04)
//       Return AvgExistCpo('EF1', mv_par04+mv_par05)
//    Else
//       mv_par05 := "  "
//       MsgInfo("Preencha o Numero do Contrato."/*STR0034*/)  // "Preencha o Numero do Contrato."
//       Return .F.
//    EndIf
 
 ElseIf cField=="CodEve"
    Return AvgExistCpo('EC6',IIF(lEFFTpMod,IIF(cTpModu=="I","FIIM",IIF(cTpModu=="E","FIEX",""))+IIF(cTpModu!="A",IIF(!Empty(mv_par06),mv_par06+mv_par07,""),""),"FIEX"+IIF(!Empty(mv_par06),mv_par06+mv_par07,"")))
 
 ElseIf cField=="Contra"
    If lEFFTpMod
       If cTpModu $ "E/I"
          Return AvgExistCpo("EF1", cTpModu+mv_par04)
       Else
          Return Posicione("EF1",1,xFilial("EF1")+"E"+mv_par04,"EF1_CONTRA")==mv_par04 .Or. AvgExistCpo("EF1", "I"+mv_par04)
       EndIf
    Else
       Return AvgExistCpo("EF1", mv_par03)
    EndIf
 EndIf

Return .T.
