// Programador : Alcir Alves
// Data Desenvolvimento- 13-09-05 até 14-09-05
//Relatório Contábil de eventos do processo
// Objetivo - informar quais os valores efetuados por processo mês a mês, colocando o evento, descrição do evento
//			, vl da moeda, vl reais, taxa inicial, taxa final, número da contabilização, mês / ano da 
//			contabilização, data do evento, data da contabilização
// PRW : ECOEP150.PRW
//Versão 8.11
//REVISÃO - Alcir Alves - 07-11-05 - quebra por processo     
//REVISÃO - Alcir Alves - 04-10-05 - ALCIR ALVES - Inclusão de novas solicitações          
#INCLUDE "ECOEP150.CH"                 
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"                 
*// Função principal do usuário
Function ECOEP150()

ECOEP150R3(.T.)
Return .t.
*---------------------------------------------------------------------------------------
FUNCTION ECOEP150R3(p_R4) // 23-02-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   Local existReg:=.f.
   Private cModulo:="EXPORT" //define se este relatório será chamado para exportação ou importação
   Private WorkFile2:=""
   Private afilSel:={}
   Private nLin:=90
   Private STR_PERG:=""
   Private m_pag    := 1
   Private aReturn  := { "Zebrado", 1,"Contabil", 1, 1, 1, "", 1}
   Private nLastKey := 0
   Private cCabec
   Private cCabec1
   Private cCabec2
   Private cCabec3
   Private lPrim:=.t.
   Private aCampos:={}
   Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
   //Private oProcess
   SY5->(DBSETORDER(1))
   //ASK 12/02/07 17:48 - Incluso no AtuSx do P9R1 
/*  If !SX1->(dbSeek("ECOEP1"+"01"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOEP1"
      SX1->X1_ORDEM   := "01"
      SX1->X1_VARIAVL := "mv_ch1"
      SX1->X1_VAR01   := "mv_par01"
      SX1->X1_PERGUNT := "Dt.inicial Contab."
      SX1->X1_TIPO    := "D"
      SX1->X1_TAMANHO := 8
      SX1->X1_PRESEL  := 0
      SX1->X1_GSC     := "G"                                                    
      SX1->X1_VALID   := "E_Periodo_OK(MV_PAR01,MV_PAR02)"
      SX1->(msUnlock())
   Endif
   If !SX1->(dbSeek("ECOEP1"+"02"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOEP1"
      SX1->X1_ORDEM   := "02"
      SX1->X1_VARIAVL := "mv_ch2"
      SX1->X1_VAR01   := "mv_par02"
      SX1->X1_PERGUNT := "Dt.final Contab."
      SX1->X1_TIPO    := "D"
      SX1->X1_TAMANHO := 8
      SX1->X1_PRESEL  := 0
      SX1->X1_GSC     := "G"                                                    
      SX1->X1_VALID   := "E_Periodo_OK(MV_PAR01,MV_PAR02)"
      SX1->(msUnlock())
   Endif
   If !SX1->(dbSeek("ECOEP1"+"03") )
       SX1->(RecLock("SX1",.T.))
       SX1->X1_GRUPO   := "ECOEP1"
       SX1->X1_ORDEM   := "03"
       SX1->X1_VARIAVL := "mv_ch3"
       SX1->X1_VAR01   := "mv_par03"
       SX1->X1_PERGUNT :="Nr.Contabilizacao"
       SX1->X1_TIPO    := "C"
       SX1->X1_TAMANHO := AVSX3("EC1_NR_CON",3)
       SX1->X1_GSC     := "G"
       //SX1->X1_VALID   := "If(!Empty(mv_par03),AvgExistCpo('EC1',mv_par03),.T.)"
       SX1->(msUnlock())
   Endif
   If !SX1->(dbSeek("ECOEP1"+"04") )
       SX1->(RecLock("SX1",.T.))
       SX1->X1_GRUPO   := "ECOEP1"
       SX1->X1_ORDEM   := "04"
       SX1->X1_VARIAVL := "mv_ch4"
       SX1->X1_VAR01   := "mv_par04"
       SX1->X1_PERGUNT :="Processo"
       SX1->X1_TIPO    := "C"
       SX1->X1_TAMANHO := AVSX3("EEC_PREEMB",3)
       SX1->X1_GSC     := "G"
       SX1->X1_F3      := "EEC"
       SX1->X1_VALID   := "If(!Empty(mv_par04),AvgExistCpo('EEC',mv_par04),.T.)"
       SX1->(msUnlock())
   Endif
   If !SX1->(dbSeek("ECOEP1"+"05") )
       SX1->(RecLock("SX1",.T.))
       SX1->X1_GRUPO   := "ECOEP1"
       SX1->X1_ORDEM   := "05"
       SX1->X1_VARIAVL := "mv_ch5"
       SX1->X1_VAR01   := "mv_par05"
       SX1->X1_PERGUNT :="Codigo Evento"
       SX1->X1_TIPO    := "C"
       SX1->X1_TAMANHO := AVSX3("EEQ_EVENT",3)
       SX1->X1_GSC     := "G"
       SX1->X1_F3      := "EFF"
       //SX1->X1_VALID   := "IF(!Empty(mv_par05),AvgExistCpo('EC6',mv_par05),.T.)"
       SX1->(msUnlock())
   endif
   If !SX1->(dbSeek("ECOEP1"+"06") )
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "ECOEP1"
      SX1->X1_ORDEM   := "06"
      SX1->X1_VARIAVL := "mv_ch6"
      SX1->X1_VAR01   := "mv_par06"
      SX1->X1_PERGUNT := "Nro. Contrato"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := AVSX3("EF1_CONTRA",3)
      SX1->X1_VALID   := "If (!Empty(mv_par06),AvgExistCpo('EF1',mv_par06),.T.)"
      SX1->X1_GSC     := "G"
      SX1->X1_F3      := "EF2" 
      SX1->(msUnlock())
   ENDIF
   If !SX1->(dbSeek("ECOEP1"+"07") )
       RecLock("SX1",.T.)
       SX1->X1_GRUPO   := "ECOEP1"
       SX1->X1_ORDEM   := "07"
       SX1->X1_VARIAVL := "mv_ch7"
       SX1->X1_VAR01   := "mv_par07"
       SX1->X1_PERGUNT := "Origem dos dados?"
       SX1->X1_TIPO    := "N"
       SX1->X1_TAMANHO := 1
       SX1->X1_DECIMAL := 0
       SX1->X1_GSC     := "C"
       SX1->X1_DEF01   := "1 - Ambos"
       SX1->X1_DEF02   := "2 - Previa"
       SX1->X1_DEF03   := "3 - Efetivacao"
       SX1->(msUnlock())
    Endif 
    If !SX1->(dbSeek("ECOEP1"+"08") )
       RecLock("SX1",.T.)
       SX1->X1_GRUPO   := "ECOEP1"
       SX1->X1_ORDEM   := "08"
       SX1->X1_VARIAVL := "mv_ch8"
       SX1->X1_VAR01   := "mv_par08"
       SX1->X1_PERGUNT := "Evt.Contabilizado?"
       SX1->X1_TIPO    := "N"
       SX1->X1_TAMANHO := 1
       SX1->X1_DECIMAL := 0
       SX1->X1_GSC     := "C"
       SX1->X1_DEF01   := "1 - Ambos"
       SX1->X1_DEF02   := "2 - Sim"
       SX1->X1_DEF03   := "3 - Nao"
       SX1->(msUnlock())
    Endif 
    If !SX1->(dbSeek("ECOEP1"+"09") )
       RecLock("SX1",.T.)
       SX1->X1_GRUPO   := "ECOEP1"
       SX1->X1_ORDEM   := "09"
       SX1->X1_VARIAVL := "mv_ch9"
       SX1->X1_VAR01   := "mv_par09"
       SX1->X1_PERGUNT := "Tipo de impressão"
       SX1->X1_TIPO    := "N"
       SX1->X1_TAMANHO := 1
       SX1->X1_DECIMAL := 0
       SX1->X1_GSC     := "C"
       SX1->X1_DEF01   := "1 - Impressora"
       SX1->X1_DEF02   := "2 - Arquivo"
       SX1->X1_DEF03   := "3 - Ms-excel"
       SX1->(msUnlock())
    Endif */
    dbselectarea("sa1")
    afilSel:=AvgSelectFil(.T.,"EEC") //Alcir 
    if afilSel[1] #"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
       IF Pergunte("ECOEP1",.T.)
              //work da consulta do relatorio
              Adata:={}
              Aadd(Adata,{"FILIAL",AVSX3("ECF_FILIAL",2),AVSX3("ECF_FILIAL",3),AVSX3("ECF_FILIAL",4)}) //FILIAL
              Aadd(Adata,{"NRCONT",AVSX3("EC1_NR_CON",2),AVSX3("EC1_NR_CON",3),AVSX3("EC1_NR_CON",4)}) //NR CONTABILIZACAO
              Aadd(Adata,{"DTCONT","D",8,0}) //DT CONTABILIZACAO  -EC1_DT_CON       
              Aadd(Adata,{"PREEMB",AVSX3("ECF_PREEMB",2),AVSX3("ECF_PREEMB",3),AVSX3("ECF_PREEMB",4)}) //PROCESSO
              
              //modificações - 04-10-05 - Alcir Alves
              Aadd(Adata,{"INVOIC",AVSX3("ECF_INVEXP",2),AVSX3("ECF_INVEXP",3),AVSX3("ECF_INVEXP",4)}) //INVOICE
              //   Aadd(Adata,{"INVOIC",AVSX3("ECF_INVOIC",2),AVSX3("ECF_INVOIC",3),AVSX3("ECF_INVOIC",4)}) //INVOICE IMPORTACAO             
              Aadd(Adata,{"FORN",AVSX3("ECF_FORN",2),AVSX3("ECF_FORN",3),AVSX3("ECF_FORN",4)}) //FORNCEDOR
              Aadd(Adata,{"NFORN",AVSX3("A1_NREDUZ",2),AVSX3("A1_NREDUZ",3),AVSX3("A1_NREDUZ",4)}) //NOME DO FORNCEDOR
              Aadd(Adata,{"TPFORN",AVSX3("ECF_TP_FOR",2),AVSX3("ECF_TP_FOR",3),AVSX3("ECF_TP_FOR",4)}) //TIPO FORNCEDOR
              
              Aadd(Adata,{"CONTRA",AVSX3("ECF_CONTRA",2),AVSX3("ECF_CONTRA",3),AVSX3("ECF_CONTRA",4)}) //CONTRATO
              Aadd(Adata,{"CBANCO",AVSX3("ECF_BANCO",2),AVSX3("ECF_BANCO",3),AVSX3("ECF_BANCO",4)}) //BANCO
              Aadd(Adata,{"CPRACA",AVSX3("ECF_PRACA",2),AVSX3("ECF_PRACA",3),AVSX3("ECF_PRACA",4)}) //PRACA
              Aadd(Adata,{"CEXP",AVSX3("EF1_EXPORT",2),AVSX3("EF1_EXPORT",3),AVSX3("EF1_EXPORT",4)}) //EXPORTADOR
              
              Aadd(Adata,{"CONTA_C",AVSX3("ECF_CTA_CR",2),15,AVSX3("ECF_CTA_CR",4)}) //CONTA CREDITO
              Aadd(Adata,{"CONTA_D",AVSX3("ECF_CTA_DB",2),15,AVSX3("ECF_CTA_DB",4)}) //CONTA DEBITO
              
              Aadd(Adata,{"IDENTC",AVSX3("ECF_IDENTC",2),AVSX3("ECF_IDENTC",3),AVSX3("ECF_IDENTC",4)}) //Unidade requisitante
              //              
              Aadd(Adata,{"NEVENT",AVSX3("ECF_ID_CAM",2),AVSX3("ECF_ID_CAM",3),AVSX3("ECF_ID_CAM",4)}) //EVENTO
              Aadd(Adata,{"EVENT",AVSX3("EC6_DESC",2),AVSX3("EC6_DESC",3),AVSX3("EC6_DESC",4)}) //DESCRICAO DO EVENTO
              Aadd(Adata,{"DTEVENT","D",8,0}) //DT EVENTO - ECF_DTCONT
              Aadd(Adata,{"TXINIC",AVSX3("ECF_FLUTUA",2),AVSX3("ECF_FLUTUA",3),AVSX3("ECF_FLUTUA",4)}) //TX.INICIAL
              Aadd(Adata,{"TXFIN",AVSX3("ECF_PARIDA",2),AVSX3("ECF_PARIDA",3),AVSX3("ECF_PARIDA",4)}) //TX.FINAL
              Aadd(Adata,{"MOEDA",AVSX3("ECF_MOEDA",2),AVSX3("ECF_MOEDA",3),AVSX3("ECF_MOEDA",4)}) //VALOR MOE
              Aadd(Adata,{"VLMOE",AVSX3("ECF_VL_MOE",2),AVSX3("ECF_VL_MOE",3),AVSX3("ECF_VL_MOE",4)}) //VALOR MOE
              Aadd(Adata,{"VLREA",AVSX3("ECF_VALOR",2),AVSX3("ECF_VALOR",3),AVSX3("ECF_VALOR",4)}) //VALOR
              Aadd(Adata,{"NRNF",AVSX3("ECF_NRNF",2),AVSX3("ECF_NRNF",3),AVSX3("ECF_NRNF",4)}) //NOTA FISCAL
              Aadd(Adata,{"CONTAB",AVSX3("ECF_CONTAB",2),AVSX3("ECF_CONTAB",3),AVSX3("ECF_CONTAB",4)}) //CONTABILIZA
              
              WorkFile2:=E_criatrab(,Adata,"WORK_ECO",,.F.)

              IndRegua ( "Work_ECO",WorkFile2,"FILIAL+NRCONT+PREEMB")
                                       
              //SVG - 28/08/2009 - 
              SX5->( DBSetOrder(1) )
              If SX5->( DBSeek(xFilial("SX5")+"CJ") )
                 While SX5->X5_TABELA == "CJ"
                    cModulo := SX5->X5_CHAVE
                    MsAguarde({|| If(CRIA_ECO(),existReg := .T.,)},STR0001) //gera work
                    SX5->(DBSKIP())
                 EndDo
              EndIf
              
              if existReg //caso exista dados no eec que antendam os filtros
                  If lR4
                     oReport := ReportDef()
                     oReport:PrintDialog()
                     WORK_ECO->(DBCLOSEAREA())
                  Else
                     GERA_REL()
                  EndIf   
              else
                  msgstop(STR0009)
                  WORK_ECO->(DBCLOSEAREA())    
              endif
       ENDIF
    ENDIF
RETURN .T.


*---------------------------------------------------------------------------------------
STATIC FUNCTION GERA_REL()  //ALCIR ALVES - 13-09-05 - gera relatorio
*---------------------------------------------------------------------------------------
           IF mv_par09==1 //CASO IMPRESSORA
               STR_PERG:=IIF(!empty(MV_PAR01),STR0010+dtoc(MV_PAR01),"")+space(3)+;
               IIF(!empty(MV_PAR02),STR0011+dtoc(MV_PAR02),"")+space(3)+;
               IIF(!empty(MV_PAR03),STR0012+alltrim(MV_PAR03),"")+space(3)+;
               IIF(!empty(MV_PAR04),STR0013+alltrim(MV_PAR04),"")+space(3)+;
               IIF(!empty(MV_PAR05),STR0014+alltrim(MV_PAR05),"")+space(3)+;
               IIF(!empty(MV_PAR06),STR0015+alltrim(MV_PAR06),"")
               Adados:= {"",;
                         "",; 
                         "",; 
                         "2",;
                         "G",;
                         220,;
                         alltrim(STR_PERG),; 
                         "",;
                         STR0002,; 
                         { "Zebrado", 1,"Contabil", 1, 2, 1, "",1 },;
                         "WORK_ECO",;             
                         }
                wnrel:=SetPrint("WORK_ECO","ECOEP150",,"","","","",.F.,.F.,.F.,"G")
                If lastkey()#27 .and. nlastkey!=27
                   SetDefault(aReturn,"WORK_ECO")
                   RptStatus({|lEnd| REL_BD()})
                   OurSpool(wnrel)
                Endif
                WORK_ECO->(DBCLOSEAREA())
           ELSE  //CASO TEXTO OU EXCEL
               WORK_EXPORT(IIF(mv_par09==2,.F.,.T.))                   
           ENDIF
return .t.

*---------------------------------------------------------------------------------------
STATIC FUNCTION REL_BD() // 13-09-05 - Alcir Alves
//CRIA ESTRUTURA DO RELATORIO
*---------------------------------------------------------------------------------------
   Private FilAtu:="-"  //Filial atual do grupo
   Private ContAtu:="-" //contabilizacao atual do grupo
   Private lProc:="-"
     PLinha()   
     //work_eco->(dbgotop())
     SetRegua(work_eco->(EasyRecCount()))
     do while !work_eco->(eof())
        FIL_HEAD() //verifica se é nova filial ou novo numero contabil
        //Alcir Alves - 07-11-05 - quebra por processo      
        if lProc#(WORK_ECO->PREEMB+WORK_ECO->FORN+WORK_ECO->TPFORN)  
           @ nLin,01 PSAY STR0013+alltrim(WORK_ECO->PREEMB)+space(2)+iif(WORK_ECO->TPFORN=="1",STR0016,STR0017)+alltrim(WORK_ECO->FORN)+"-"+alltrim(WORK_ECO->NFORN)
           PLinha()   
        endif
        //
        //REVISÃO 04-10-05 - ALCIR ALVES                    
        @ nLin,03 PSAY WORK_ECO->INVOIC+space(1)+;
        WORK_ECO->IDENTC+space(1)+WORK_ECO->CONTRA+space(1)+;
        WORK_ECO->CBANCO+space(1)+WORK_ECO->CPRACA+space(5)+WORK_ECO->NEVENT+"-"+WORK_ECO->EVENT+space(1)+;
        dtoc(WORK_ECO->DTEVENT)+space(1)+transform(WORK_ECO->TXINIC,AVSX3("ECF_FLUTUA",6))+;
        space(1)+transform(WORK_ECO->TXFIN,AVSX3("ECF_PARIDA",6))+space(1)+WORK_ECO->MOEDA+space(1)+;
        transform(WORK_ECO->VLMOE,AVSX3("ECF_VL_MOE",6))+space(1)+transform(WORK_ECO->VLREA,AVSX3("ECF_VL_MOE",6))+;
        space(2)+WORK_ECO->CONTA_C+space(2)+WORK_ECO->CONTA_D+space(2)+substr(WORK_ECO->NRNF,1,12)+space(1)+IIF(WORK_ECO->CONTAB=="1","SIM","NAO") 
        IncRegua()
        PLinha()   
        if lProc#WORK_ECO->PREEMB
           lProc:=(WORK_ECO->PREEMB+WORK_ECO->FORN+WORK_ECO->TPFORN)
        endif
        work_eco->(dbskip())
     enddo
     MS_FLUSH()        
RETURN .T. 

*---------------------------------------------------------------------------------------
STATIC FUNCTION FIL_HEAD // 23-02-05 - Alcir Alves
*---------------------------------------------------------------------------------------
      if work_eco->filial#FilAtu //quebra por filial
         FilAtu:=work_eco->filial
         ContAtu:="-"
         if m_pag>2
            nLin:=90
            PLinha()  
         endif
         
         @ nLin,01 PSAY Repli("*", 226)
         PLinha()  
         @ nLin,01 PSAY STR0003+FilAtu+" - "+AvgFilName({FilAtu})[1]  
         PLinha()  
         @ nLin, 01 PSAY Repli("*", 226)
         lProc:="-"
      endif 
      if work_eco->NRCONT#ContAtu //quebra por numero contabil
         ContAtu:=work_eco->NRCONT
         if nLin>54 //Força quebra de pagina no final da folha
           nLin:=90
         endif
         PLinha()  
         @ nLin,01 PSAY Repli("-", 226)
         PLinha()  
         @ nLin,01 PSAY IIF(ContAtu#"ZPRE",STR0004+ContAtu,STR0005) //+" - "+AvgFilName({FilAtu})[1]  
         if ContAtu#"ZPRE" //caso diferente de previa
             //PLinha()
             @ nLin,55 PSAY STR0006+dtoc(WORK_ECO->DTCONT) //+" - "+AvgFilName({FilAtu})[1]             
         endif
         PLinha()  
         @ nLin, 01 PSAY Repli("-", 226)
         PLinha()  
         lProc:="-"
      endif 
            
      
return .t.

*---------------------------------------------------------------------------------------
STATIC FUNCTION PLinha() // 13-09-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   if nLin>60
      nLin:=Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5])
      nLin:=nLin+1
      @ nLin, 01 PSAY STR0007   //+" - "+iif(mv_par09==1,STR0018,STR0019) //07-11-05 - sintetico/analitico
      nLin:=nLin+1
   else
      nLin:=nLin+1
      @ nLin,00 psay " "
   endif
Return .t.

*---------------------------------------------------------------------------------------
STATIC FUNCTION CRIA_ECO()  //ALCIR ALVES - 13-08-05
//FUNÇÃO QUE GERAS OS DADOS SOLICITADOS NA WORK
//TRAZ DADOS DO EEC QUE ATENDAM OS FILTROS
*---------------------------------------------------------------------------------------
LOCAL lRet:=.T.
Local i:=0
Local lFilEC6:=.T.
Local aFilEC6:={}
           /*
  
            //gera work com os processos 
            dbselectarea("workEEC2")
            /*cQuery:="SELECT * from "+RetSqlName("EEC")+" EEC "+;
            " WHERE EEC.EEC_FILIAL IN ("+SQL_FilS+") AND "+IIF(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_<>'*'","EEC.@DELETED@<>'*'")+SQL_PERG2+;
            " ORDER BY EEC.EEC_FILIAL,EEC.EEC_PREEMB"
            cQuery:="SELECT DISTINCT EEC.EEC_FILIAL,EEC.EEC_UNINEG, EEC.EEC_PREEMB , EEC.EEC_DTEMBA , EEC.EEC_DTCONT from "+RetSqlName("EEC")+" EEC ,"+RetSqlName("EEQ")+" EEQ ,"+RetSqlName("EEB")+" EEB "+;
           " WHERE EEC.EEC_FILIAL IN ("+SQL_FilS+") AND "+IIF(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_<>'*'","EEC.@DELETED@<>'*'")+;
           " AND EEQ.EEQ_FILIAL=EEC.EEC_FILIAL AND EEQ.EEQ_PREEMB=EEC.EEC_PREEMB AND EEQ.EEQ_EVENT IN ('120','121','122') AND EEB.EEB_OCORRE='Q'  "+;
           " AND "+IIF(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_<>'*'","EEQ.@DELETED@<>'*'")+;
           " AND (EEC.EEC_DTEMBA<>'' OR EEC.EEC_DTEMBA<>'"+SPACE(8)+"') AND EEB.EEB_FILIAL=EEC.EEC_FILIAL and EEB.EEB_PEDIDO=EEC.EEC_PREEMB AND EEB.EEB_CODAGE=EEQ.EEQ_CODEMP"  +;
           " AND "+IIF(TcSrvType()<>"AS/400","EEB.D_E_L_E_T_<>'*'","EEB.@DELETED@<>'*'")+SQL_PERG+;
           " ORDER BY EEC.EEC_FILIAL, EEC.EEC_PREEMB"

            cQuery:=ChangeQuery(cQuery)
            TcQuery cQuery ALIAS "WORK_EEC" NEW
            TCSetField( "WORK_EEC", "EEC_DTEMBA", "D", 8, 0 )
            TCSetField( "WORK_EEC", "EEC_DTCONT", "D", 8, 0 )
           */
   EC1->(dbsetorder(1))
   ECF->(DBSETORDER(4))
   ECA->(DBSETORDER(1))
   EC6->(dbsetorder(1))
   SA1->(dbsetorder(1))
   SA2->(dbsetorder(1))   
   aFilEC6:=AvgSelectFil(.F.,"EC6") //Alcir - conceito multifilial
   if len(aFilEC6)==1 .and. alltrim(aFilEC6[1])==""
      lFilEC6:=.F.
   endif
   dbselectarea("sa1")   
   FOR i:=1 to len(afilSel)
      if mv_par07==1 .or. mv_par07==3 //caso tipo de origem possua dados da efetivação
         IF EC1->(dbseek(afilSel[i]+cModulo))
            Do while !EC1->(EOF()) .and. EC1->EC1_FILIAL==afilSel[i] .and. EC1->EC1_TPMODU==cModulo
               IF !empty(MV_PAR01) .and. EC1->EC1_DT_CON<MV_PAR01 //CASO DATA INICIAL MENOR QUE O FILTRO
                  EC1->(DBSKIP())
                  LOOP
               ENDIF
               IF !empty(MV_PAR02) .and. EC1->EC1_DT_CON>MV_PAR02 //CASO DATA FINAL MAIOR QUE O FILTRO
                  EC1->(DBSKIP())
                  LOOP
               ENDIF
               IF !empty(MV_PAR03) .and. EC1->EC1_NR_CON#MV_PAR03 //CASO O NUMERO CONTABIL SEJA DIFERENTE
                  EC1->(DBSKIP())
                  LOOP
               ENDIF
               //GRAVANDO ECF
               IF ECF->(DBSEEK(afilSel[i]+cModulo+EC1->EC1_NR_CON))
                  DO WHILE !ECF->(EOF()) .AND. ECF->ECF_FILIAL==afilSel[i] .AND. ECF->ECF_TPMODU==cModulo .AND. ECF->ECF_NR_CON==EC1->EC1_NR_CON
                     IF !empty(MV_PAR04) .and. ECF->ECF_PREEMB#MV_PAR04 //CASO O PROCESSO SEJA DIFERENTE
                        ECF->(DBSKIP())
                        LOOP
                     ENDIF
                     IF !empty(MV_PAR05) .and. ECF->ECF_ID_CAM#MV_PAR05 //CASO O EVENTO SEJA DIFERENTE
                        ECF->(DBSKIP())
                        LOOP
                     ENDIF
                     IF !empty(MV_PAR06) .and. ECF->ECF_CONTRA#MV_PAR06 //CASO O CONTRATO SEJA DIFERENTE
                        ECF->(DBSKIP())
                        LOOP
                     ENDIF                                    
                     IF MV_PAR08==2 .and. ECF->ECF_CONTAB#"1" //CASO O CONTRATO SEJA DIFERENTE
                        ECF->(DBSKIP())
                        LOOP
                     ENDIF                                    
                     IF MV_PAR08==3 .and. ECF->ECF_CONTAB#"2" //CASO O CONTRATO SEJA DIFERENTE
                        ECF->(DBSKIP())
                        LOOP
                     ENDIF                                    
                     WORK_ECO->(DBAPPEND())
                     WORK_ECO->FILIAL:=ECF->ECF_FILIAL
                     WORK_ECO->NRCONT:=EC1->EC1_NR_CON
                     WORK_ECO->DTCONT:=EC1->EC1_DT_CON       
                     WORK_ECO->PREEMB:=ECF->ECF_PREEMB
                     WORK_ECO->NEVENT:=ECF->ECF_ID_CAM
                     WORK_ECO->EVENT:=Posicione("EC6",1,iif(lFilEC6,xFilial("EC6"),ECF->ECF_FILIAL)+cModulo+AvKey(ECF->ECF_ID_CAM,"EC6_COD"),"EC6_DESC")    
                     WORK_ECO->DTEVENT:=ECF->ECF_DTCONT
                     WORK_ECO->TXINIC:=ECF->ECF_FLUTUA
                     WORK_ECO->TXFIN:=ECF->ECF_PARIDA
                     WORK_ECO->VLMOE:=ECF->ECF_VL_MOE
                     WORK_ECO->VLREA:=ECF->ECF_VALOR
                     WORK_ECO->CONTRA:=ECF->ECF_CONTRA
                     WORK_ECO->MOEDA:=ECF->ECF_MOEDA
                     //REVISÃO 04-10-05 - ALCIR ALVES          
                     WORK_ECO->INVOIC:=ECF->ECF_INVEXP
                     WORK_ECO->FORN:=ECF->ECF_FORN
                     WORK_ECO->TPFORN:=ECF->ECF_TP_FOR
                     WORK_ECO->NRNF:=ECF->ECF_NRNF
                     IF ECF->ECF_TP_FOR=="2"
                        IF SA2->(DBSEEK(XFILIAL("SA2")+ECF->ECF_FORN))
                             WORK_ECO->NFORN:=SA2->A2_NREDUZ
                        ENDIF
                     ELSE //ECF->ECF_TP_FOR=="2"
                        IF SA1->(DBSEEK(XFILIAL("SA1")+ECF->ECF_FORN))
                             WORK_ECO->NFORN:=SA1->A1_NREDUZ
                        ENDIF
                     ENDIF
                     //iif(empty(),"-"+space(AVSX3("EF1_EXPORT",3)-1),)
                     WORK_ECO->CONTRA:=iif(empty(ECF->ECF_CONTRA),"-"+space(AVSX3("ECF_CONTRA",3)-1),ECF->ECF_CONTRA)
                     WORK_ECO->CBANCO:=iif(empty(ECF->ECF_BANCO),"-"+space(AVSX3("ECF_BANCO",3)-1),ECF->ECF_BANCO) 
                     WORK_ECO->CPRACA:=iif(empty(ECF->ECF_PRACA),"-"+space(AVSX3("ECF_PRACA",3)-1),ECF->ECF_PRACA) 
                     //WORK_ECO->CEXP:=ECF->EF1_EXPORT
                     WORK_ECO->CONTA_C:=substr(alltrim(iif(empty(ECF->ECF_CTA_CR),"-"+space(AVSX3("ECF_CTA_CR",3)-1),ECF->ECF_CTA_CR)),1,15) //ECF->ECF_CTA_CR
                     WORK_ECO->CONTA_D:=substr(alltrim(iif(empty(ECF->ECF_CTA_DB),"-"+space(AVSX3("ECF_CTA_DB",3)-1),ECF->ECF_CTA_DB)),1,15) //ECF->ECF_CTA_DB
                     WORK_ECO->IDENTC:=iif(empty(ECF->ECF_IDENTC),"-"+space(AVSX3("ECF_IDENTC",3)-1),ECF->ECF_IDENTC) //ECF->ECF_IDENTC
                     WORK_ECO->CONTAB:=ECF->ECF_CONTAB
                     //
                     ECF->(DBSKIP())
                  ENDDO
               ENDIF
               EC1->(DBSKIP())
            ENDDO
         ENDIF
      endif

      if mv_par07==1 .or. mv_par07==2 //caso tipo de origem possua dados da prévia
         IF ECA->(DBSEEK(afilSel[i]+cModulo))
            DO WHILE !ECA->(EOF()) .AND. ECA->ECA_FILIAL==afilSel[i] .AND. ECA->ECA_TPMODU==cModulo   
                IF !empty(MV_PAR01) .and. ECA->ECA_DT_CON<MV_PAR01 //CASO DATA INICIAL MENOR QUE O FILTRO
                   ECA->(DBSKIP())
                   LOOP
                ENDIF
                IF !empty(MV_PAR02) .and. ECA->ECA_DT_CON>MV_PAR02 //CASO DATA FINAL MAIOR QUE O FILTRO
                   ECA->(DBSKIP())
                   LOOP
                ENDIF
                IF !empty(MV_PAR04) .and. ECA->ECA_PREEMB#MV_PAR04 //CASO O PROCESSO SEJA DIFERENTE
                   ECA->(DBSKIP())
                   LOOP
                ENDIF
                IF !empty(MV_PAR05) .and. ECA->ECA_ID_CAM#MV_PAR05 //CASO O EVENTO SEJA DIFERENTE
                   ECA->(DBSKIP())
                   LOOP
                ENDIF
                IF !empty(MV_PAR06) .and. ECA->ECA_CONTRA#MV_PAR06 //CASO O CONTRATO SEJA DIFERENTE
                   ECA->(DBSKIP())
                   LOOP
                ENDIF                                    
                IF MV_PAR08==2 .and. ECA->ECA_CONTAB#"1" //CASO O CONTRATO SEJA DIFERENTE
                    ECA->(DBSKIP())
                    LOOP
                ENDIF                                    
                IF MV_PAR08==3 .and. ECA->ECA_CONTAB#"2" //CASO O CONTRATO SEJA DIFERENTE
                    ECA->(DBSKIP())
                    LOOP
                ENDIF                                    
                WORK_ECO->(DBAPPEND())
                WORK_ECO->FILIAL:=ECA->ECA_FILIAL
                WORK_ECO->NRCONT:="ZPRE"   //PRÉVIA
                WORK_ECO->DTCONT:=ECA->ECA_DT_CON       
                WORK_ECO->PREEMB:=ECA->ECA_PREEMB
                WORK_ECO->NEVENT:=ECA->ECA_ID_CAM
                WORK_ECO->EVENT:=Posicione("EC6",1,iif(lFilEC6,xFilial("EC6"),ECA->ECA_FILIAL)+cModulo+AvKey(ECA->ECA_ID_CAM,"EC6_COD"),"EC6_DESC")    
                WORK_ECO->DTEVENT:=ECA->ECA_DT_CON 
                WORK_ECO->TXINIC:=0
                WORK_ECO->TXFIN:=ECA->ECA_TX_USD
                WORK_ECO->VLMOE:=ECA->ECA_VL_MOE
                WORK_ECO->VLREA:=ECA->ECA_VALOR
                WORK_ECO->CONTRA:=ECA->ECA_CONTRA 
                WORK_ECO->MOEDA:=ECA->ECA_MOEDA
                //REVISÃO 04-10-05 - ALCIR ALVES 
                WORK_ECO->INVOIC:=ECA->ECA_INVEXP
                WORK_ECO->FORN:=ECA->ECA_FORN
                WORK_ECO->TPFORN:=ECA->ECA_TP_FOR
                WORK_ECO->NRNF:=""
                IF ECF->ECF_TP_FOR=="1"
                   IF SA2->(DBSEEK(XFILIAL("SA2")+ECA->ECA_FORN))
                      WORK_ECO->NFORN:=SA2->A2_NREDUZ
                   ENDIF
                ELSE //ECF->ECF_TP_FOR=="2"
                   IF SA1->(DBSEEK(XFILIAL("SA1")+ECA->ECA_FORN))
                      WORK_ECO->NFORN:=SA1->A1_NREDUZ
                   ENDIF
                ENDIF

                WORK_ECO->CONTRA:=iif(empty(ECA->ECA_CONTRA),"-"+space(AVSX3("ECA_CONTRA",3)-1),ECA->ECA_CONTRA)
                WORK_ECO->CBANCO:=iif(empty(ECA->ECA_BANCO),"-"+space(AVSX3("ECA_BANCO",3)-1),ECA->ECA_BANCO) 
                WORK_ECO->CPRACA:=iif(empty(ECA->ECA_PRACA),"-"+space(AVSX3("ECA_PRACA",3)-1),ECA->ECA_PRACA) 
                //WORK_ECO->CEXP:=ECF->EF1_EXPORT
                WORK_ECO->CONTA_C:=substr(alltrim(iif(empty(ECA->ECA_CTA_CR),"-"+space(AVSX3("ECA_CTA_CR",3)-1),ECA->ECA_CTA_CR)),1,15)
                WORK_ECO->CONTA_D:=substr(alltrim(iif(empty(ECA->ECA_CTA_DB),"-"+space(AVSX3("ECA_CTA_DB",3)-1),ECA->ECA_CTA_DB)),1,15)
                WORK_ECO->IDENTC:=iif(empty(ECA->ECA_IDENTC),"-"+space(AVSX3("ECA_IDENTC",3)-1),ECA->ECA_IDENTC)
                WORK_ECO->CONTAB:=ECA->ECA_CONTAB
                //
                ECA->(DBSKIP())
            enddo
         ENDIF
      endif
   NEXT
   WORK_ECO->(dbgotop())
   if WORK_ECO->(bof()) .and. WORK_ECO->(eof())
      lRet:=.f.
   endif
RETURN lRet

*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------
   Local oExcelApp
   //Local cDirDocs := MsDocPath()
   Local cPath	:= AllTrim(GetTempPath())
   DbSelectArea("WORK_ECO")
   if lExcel
         WORK_ECo->(dbCloseArea())
         CpyS2T(".\"+curdir()+WorkFile2+".DBF",cPath, .T. )
         If ! ApOleClient( 'MsExcel' )
            MsgStop(STR0008)  
            RETURN .F.
         Else
            oExcelApp:= MsExcel():New()
            oExcelApp:WorkBooks:Open( cPath+WorkFile2+".dbf" )
            oExcelApp:SetVisible(.T.)
         EndIf
   Else
         TR350ARQUIVO("WORK_ECO")   
         WORK_ECo->(dbCloseArea())
   EndIf
Return .T.


//TRP - 23/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
cCabec1:="WORK_ECO->FILIAL"
cCabec2:="WORK_ECO->NRCONT+Space(10)"
cCabec3:="WORK_ECO->DTCONT"

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("ECOEP150",STR0002,"ECOEP1",{|oReport| ReportPrint(oReport)},STR0002)

// Define o relatorio como Landscape Nick 20/10/06
oReport:opage:llandscape := .T.
oReport:opage:lportrait := .F.

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Eventos do processo",aTabelas,aOrdem)

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Filtros",aTabelas,aOrdem)


//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"INVOIC"        ,"WORK_ECO"  ,"Invoice"                ,/*Picture*/                       ,AVSX3("ECF_INVEXP",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"IDENTC"        ,"WORK_ECO"  ,"Unid.Req."              ,/*Picture*/                       ,AVSX3("ECF_IDENTC",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CONTRA"        ,"WORK_ECO"  ,"Cont.Vinc."             ,/*Picture*/                       ,AVSX3("ECF_CONTRA",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CBANCO"        ,"WORK_ECO"  ,"Banco"                  ,/*Picture*/                       ,AVSX3("ECF_BANCO",3)                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CPRACA"        ,"WORK_ECO"  ,"Praca"                  ,/*Picture*/                       ,AVSX3("ECF_PRACA",3)                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EVENT"         ,"WORK_ECO"  ,STR0014                  ,/*Picture*/                       ,20                                              ,/*lPixel*/,{||WORK_ECO->NEVENT+"-"+WORK_ECO->EVENT})
TRCell():New(oSecao1,"DTEVENT"       ,"WORK_ECO"  ,"Dt.Contab."             ,/*Picture*/                       ,8                                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TXINIC"        ,"WORK_ECO"  ,"Tx.Inicial"             ,"@E 999,999,999.999999"           ,AVSX3("ECF_FLUTUA",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TXFIN"         ,"WORK_ECO"  ,"Tx.Final"               ,"@E 999,999,999.999999"           ,AVSX3("ECF_PARIDA",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"MOEDA"         ,"WORK_ECO"  ,"Moeda"                  ,/*Picture*/                       ,AVSX3("ECF_MOEDA",3)                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VLMOE"         ,"WORK_ECO"  ,"Vl.na Moeda"            ,"@E 999,999,999.99"               ,AVSX3("ECF_VL_MOE",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VLREA"         ,"WORK_ECO"  ,"Vl.R$"                  ,"@E 999,999,999.99"               ,AVSX3("ECF_VALOR",3)                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CONTA_C"       ,"WORK_ECO"  ,"Conta Credito"          ,/*Picture*/                       ,15                                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CONTA_D"       ,"WORK_ECO"  ,"Conta Debito"           ,/*Picture*/                       ,15                                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"NRNF"          ,"WORK_ECO"  ,"NF."                    ,/*Picture*/                       ,AVSX3("ECF_NRNF",3)                             ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CONTAB"        ,"WORK_ECO"  ,"Contab."                ,/*Picture*/                       ,AVSX3("ECF_CONTAB",3)                           ,/*lPixel*/,{||IIF(WORK_ECO->CONTAB=="1","SIM","NAO")})

oReport:Section("Eventos do processo"):Cell("EVENT"   ):SetColSpace(5)
oBreak := TRBreak():New(oReport:Section("Eventos do processo"),{||WORK_ECO->(FILIAL+NRCONT)},,.F.)//Quebra por filial e nro de contabilizaçao

oBreak2 := TRBreak():New(oReport:Section("Eventos do processo"),{||WORK_ECO->(PREEMB+FORN+TPFORN)},,.F.) // "Quebra por processo"
oBreak2:bOnBreak:={||oReport:SkipLine(2),oReport:PrintText(if(!WORK_ECO->(EOF()),STR0013+alltrim(WORK_ECO->PREEMB)+space(2)+iif(WORK_ECO->TPFORN=="1",STR0016,STR0017)+alltrim(WORK_ECO->FORN)+"-"+alltrim(WORK_ECO->NFORN),""),,)}

oReport:Section("Eventos do processo"):SetHeaderBreak(.T.)
oReport:Section("Eventos do processo"):SetPageBreak(.T.)
oReport:bOnPageBreak:={||AltCabec(),if(lPrim,oReport:PrintText(STR0013+alltrim(WORK_ECO->PREEMB)+space(2)+iif(WORK_ECO->TPFORN=="1",STR0016,STR0017)+alltrim(WORK_ECO->FORN)+"-"+alltrim(WORK_ECO->NFORN),,),)}

//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"Cabeçalho"        ,""  , ""                  ,/*Picture*/                          ,100                                             ,/*lPixel*/,{||cCabec})


//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

***********************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

TRPosition():New(oReport:Section("Eventos do processo"),"SA2",1,{|| xFilial("SA2") +ECF->ECF_FORN})

TRPosition():New(oReport:Section("Eventos do processo"),"SA1",1,{|| xFilial("SA1") +ECF->ECF_FORN})

TRPosition():New(oReport:Section("Eventos do processo"),"ECA",1,{|| xFilial("ECA") +cModulo})

TRPosition():New(oReport:Section("Eventos do processo"),"ECF",4,{|| xFilial("ECF") +cModulo+EC1->EC1_NR_CON})

TRPosition():New(oReport:Section("Eventos do processo"),"EC1",1,{|| xFilial("EC1") +cModulo})

//oSection:Print()
oReport:SetMeter (WORK_ECO->(EasyRecCount()))
WORK_ECO->( dbGoTop() )
lPrim:=.t.

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Eventos do processo"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Filtros"):Init()

//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()



//Laço principal
Do While WORK_ECO->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Eventos do processo"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work_ECO->( dbSkip() )
   lPrim:=.f.
EndDo

//Fim da impressão da seção 1
oReport:Section("Eventos do processo"):Finish()

//Fim da impressão da seção 2
oReport:Section("Filtros"):Finish()

//WORK_ECO->(DBCLOSEAREA())
//WORK_ECO->(E_EraseArq(WorkFile2))

Return .T.

//TRP - 23/08/2006
Static Function AltCabec()

cCabec:=STR0003+&cCabec1
oReport:Section("Filtros"):PrintLine()
oReport:FatLine()
cCabec:=STR0004+&cCabec2+STR0006+DtoC(&cCabec3)
oReport:Section("Filtros"):PrintLine()
oReport:FatLine()

Return .t.
