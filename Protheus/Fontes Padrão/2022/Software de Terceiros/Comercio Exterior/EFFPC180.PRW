
// Programador : Alcir Alves
// Data Desenvolvimento- 04-01-05    06-01-05
// Objetivo - Pesquisa por contratos EEQ (cambio) e EF3( eventos do contrato)
// PRW :EFFPC180
// Módulo - SIGAEFF
//Revisão - Alcir Alves - 29-11-05
//Revisão - Alcir Alves - 06-04-05
//Revisão - Pedro Baroni (PLB) 07/03/06 - Inclusao de Pesquisa na Base de Importação

#INCLUDE "EFFPC180.CH"                 
#INCLUDE "AVERAGE.CH"                 
#INCLUDE "TOPCONN.CH"                  

*// Função principal de acesso ao menu
*---------------------------------------------------------------------------------------
FUNCTION EFFPC180() // 02-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   LOCAL Ni:=0,valor_combo:=""    
   LOCAL oCombo
   Private iSCombo:=.F.
   private aSelecao:=space(AVSX3("EEQ_NROP",3)),aSelecao2:=space(AVSX3("EF3_CONTRA",3)),aFSelEEQ:=cFilEF3:={}
   Private aValores := {""}
   PRIVATE cFilEEQ:= xFilial('EEQ'),cFilEF3:= xFilial('EF3'),lTop,cQuery:=cQuery2:=""
   PRIVATE ArqEEQi:="EEQ_I"+TEOrdBagExt(),ArqWORKi:="WORK_I"+TEOrdBagExt()
   private cMarca:=GetMark()    
   Private lEF3cmp:=(EF3->(FIELDPOS("EF3_PRACA"))>0 .AND. EF3->(FIELDPOS("EF3_BAN_FI"))>0)
   Private lEEQMoe:=(EEQ->(FIELDPOS("EEQ_MOEDA"))>0)
   //definição passada pela braskem no dia 29-11-05
   //Tipos de cambio
   Private cTpCambio:={STR0015,STR0016,STR0017,STR0018}  //"1-Câmbio de Exportação","2-Câmbio de Importação","3-Recebimento","4-Remessa"
   //
   Private lTPCONExt:=(EEQ->(fieldpos("EEQ_TP_CON"))>0)
   #IFDEF TOP
     lTop := .T.
   #ElSE
     lTop := .F.
   #ENDIF  
   //** PLB 07/03/06
   Private aFSelSWB   := {}
   Private cQuery3    := cQuery4:=""
   Private lLincre    := EF1->( FieldPos("EF1_LINCRE") ) > 0
   Private lSeqCnt    := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                         EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                         EF3->( FieldPos("EF3_HAWB")   ) > 0
   If lSeqCnt
      Private cSequencia := space(AVSX3("EF1_SEQCNT",3))
   EndIf
   //Tabela de cadastro de Financiamentos.
   Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")
   //**
   //verifica se é para trazer um combobox com os numeros de operação listados ou somente um campo para digitar o escolhido
   IsCombo := EasyGParam("MV_PCOMBO",,.F.)

   EF1->(DBSETORDER(1))   
   EEQ->(DBSETORDER(8))
   
   aFSelEEQ:=AvgSelectFil(.F.,"EEQ") //Localiza as filias autorizadas
   aFSelSWB:=AvgSelectFil(.F.,"SWB") //** PLB 07/03/06
   //if aFSelEEQ[1]#"WND_CLOSE"  //Alcir Alves - 15-03-05 - caso a janela de sel. multifilial não tenha sido fechada
       aFilEF3:=AvgSelectFil(.F.,"EF3")
       IIF(lSeqCnt, nPos:=oMainWnd:nTop +300, nPos:=oMainWnd:nTop +250)
       DEFINE MSDIALOG oDlg3 TITLE  STR0007 FROM oMainWnd:nTop+150, oMainWnd:nLeft+50 TO nPos, oMainWnd:nLeft + 300 OF oMainWnd PIXEL 
       IF iSCombo
          IF !lTop   //Versão xBase
              DBSELECTAREA("EEQ")
              FOR Ni:=1 TO LEN(aFSelEEQ)    
                 cFilEEQ:=aFSelEEQ[Ni]
                 EEQ->(DBSEEK(cFilEEQ))
                 DO WHILE !EEQ->(EOF()) .and. EEQ->EEQ_FILIAL==cFilEEQ
                    IF !Empty(EEQ->EEQ_NROP) .And. ASCAN(aValores,{|x| x == EEQ->EEQ_NROP})<=0
                       valor_combo:=EEQ->EEQ_NROP
                       AADD(aValores,valor_combo)
                    ENDIF
                    EEQ->(DBSKIP())
                 ENDDO
              NEXT
              //** PLB 07/03/06 - Adiciona Dados do SWB
              DBSELECTAREA("SWB")
              FOR Ni:=1 TO LEN(aFSelSWB)    
                 cFilSWB:=aFSelSWB[Ni]
                 SWB->(DBSEEK(cFilSWB))
                 DO WHILE !SWB->(EOF()) .and. SWB->SWB_FILIAL==cFilSWB
                    IF !Empty(SWB->WB_CA_NUM) .And. ASCAN(aValores,{|x| x == SWB->WB_CA_NUM})<=0
                       valor_combo:=SWB->WB_CA_NUM
                       AADD(aValores,valor_combo)
                    ENDIF
                    SWB->(DBSKIP())
                 ENDDO
              NEXT     
              //**
              aValores:=Asort(aValores)
          ELSE     //Versão TOP
              cQuery2:="()"
              cQuery2:="("
              FOR Ni:=1 TO LEN(aFSelEEQ)    
                 /* ISS - 31/03/10 - Alteração na montagem da query, passando as filiais como caractere e não numérico
                 cQuery2+=iif(cQuery2=="(","",",")+alltrim(aFSelEEQ[Ni]) */
                 cQuery2+=iif(cQuery2=="(","",",")+"'"+alltrim(aFSelEEQ[Ni]+"'") 
              NEXT
              cQuery2+=")"
              cQueryD:=" " 
              //if TcSrvType()==
              cQuery  := "Select distinct(EEQ.EEQ_NROP) from "+RetSqlName("EEQ")+" EEQ where D_E_L_E_T_<>'*'" + IIF(cQuery2<>"()"," AND EEQ.EEQ_FILIAL IN "+cQuery2,"")
              cQuery:=ChangeQuery(cQuery)
              TcQuery cQuery ALIAS "Query01" NEW

              //** PLB 07/03/06
              cQuery4:="("
              FOR Ni:=1 TO LEN(aFSelSWB)    
                 /* ISS - 31/03/10 - Alteração na montagem da query, passando as filiais como caractere e não numérico
                 cQuery4+=iif(cQuery4=="(","",",")+alltrim(aFSelSWB[Ni]) */
                 cQuery4+=iif(cQuery4=="(","",",")+"'"+alltrim(aFSelSWB[Ni]+"'")
              NEXT
              cQuery4+=")"
              cQuery3 := "Select distinct(SWB.WB_CA_NUM) from "+RetSqlName("SWB")+" SWB where D_E_L_E_T_<>'*'"+IIF(cQuery4<>"()"," AND SWB.WB_FILIAL IN "+cQuery4,"")
              cQuery3:=ChangeQuery(cQuery3)
              TcQuery cQuery3 ALIAS "Query02" NEW
              //**

              DO WHILE !Query01->(EOF())
                  If !Empty(Query01->EEQ_NROP)
                     valor_combo:=AvKey(Query01->EEQ_NROP,"EEQ_NROP")
                     AADD(aValores,valor_combo)
                  EndIf
                  Query01->(DBSKIP())
              ENDDO
              Query01->(dbclosearea())

              //** PLB 07/03/06
              DO WHILE !Query02->(EOF())
                  If !Empty(Query02->WB_CA_NUM)
                     valor_combo:=AvKey(Query02->WB_CA_NUM,"WB_CA_NUM")
                     AADD(aValores,valor_combo)
                  EndIf
                  Query02->(DBSKIP())
              ENDDO
              Query02->(dbclosearea())
              //**

          ENDIF
       ENDIF
  
        @ 5,5 say STR0001 Of oDlg3 pixel  //Numero do contrato
        if iSCombo
            @ 16,5 combobox oCombo var aSelecao items aValores size 100,08 of oDlg3 pixel
        else
            @ 16,5 get aSelecao PICT AVSX3("EEQ_NROP",6) size 100,08 of oDlg3 pixel
        endif
        //** PLB 07/03/06 - Caso exista o campo Sequencia do Contrato
        If lSeqCnt
           @ 28,5 Say STR0012 Of oDlg3 Pixel  // "Sequencia:"
           @ 38,5 Get cSequencia PICT "@!" Size 50,08 Of oDlg3 Pixel
           nPos:=56
        Else 
           nPos:=35
        EndIf
        //**
        @nPos,13 BUTTON STR0002 SIZE 34,11 Of oDlg3 pixel ACTION EFFPLISTA() //Consultar
        @nPos,63 BUTTON STR0003 SIZE 34,11 Of oDlg3 pixel ACTION oDLG3:END() //Sair
      ACTIVATE MSDIALOG oDlg3  centered 
   //ENDIF
RETURN .T.


*// Lista POR NUMERO DE OPERACAO 
*---------------------------------------------------------------------------------------
STATIC FUNCTION EFFPLISTA() //04-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
   Local Ni2:=1
   Local nLin:=15 //linha superior da msselect
   Private Adata:={},Acampos:={}//Adata:=Acampos:={} //THTS - 27/09/2017 - O aCampos sera inicializado pela propria E_CriaTrab
   Private oSel
   Private lEveSeq := .F.    //** PLB 07/03/06

   DBSELECTAREA("EEQ")
   IndRegua("EEQ",ArqEEQi,"EEQ_FILIAL+EEQ_NROP")
   
   Aadd(Adata,{"WK_TIPO","C",30,0})
   Aadd(Adata,{"WK_FILIAL",AVSX3("EEQ_FILIAL",2),AVSX3("EEQ_FILIAL",3),AVSX3("EEQ_FILIAL",4)})
   Aadd(Adata,{"WK_FILNOME","C",30,0})
   Aadd(Adata,{"WK_FILIALO",AVSX3("EEQ_FILIAL",2),AVSX3("EEQ_FILIAL",3),AVSX3("EEQ_FILIAL",4)})
   Aadd(Adata,{"WK_FIONOME","C",30,0})
   Aadd(Adata,{"WK_CONTRA",AVSX3("EF3_CONTRA",2),AVSX3("EF3_CONTRA",3),AVSX3("EF3_CONTRA",4)})      
   Aadd(Adata,{"WK_BANCO",AVSX3("EEQ_BANC",2),AVSX3("EEQ_BANC",3),AVSX3("EEQ_BANC",4)})         
   IF lEF3cmp //CASO EXISTA BANCO E PRAÇA
      Aadd(Adata,{"WK_PRACA",AVSX3("EF3_PRACA",2),AVSX3("EF3_PRACA",3),AVSX3("EF3_PRACA",4)})         
   ENDIF
   Aadd(Adata,{"WK_NROP",AVSX3("EEQ_NROP",2),AVSX3("EEQ_NROP",3),AVSX3("EEQ_NROP",4)})
   If lSeqCnt     //** PLB 07/03/06 - Caso exista Sequencia do Contrato
      Aadd(Adata,{"WK_SEQCNT",AVSX3("EF3_SEQCNT",2),AVSX3("EF3_SEQCNT",3),AVSX3("EF3_SEQCNT",4)})      
   EndIf
   If lLincre     //** PLB 07/03/06 - Caso exista Linha de Credito
      Aadd(Adata,{"WK_LINCRE",AVSX3("EF1_LINCRE",2),AVSX3("EF1_LINCRE",3),AVSX3("EF1_LINCRE",4)})
   EndIf
   Aadd(Adata,{"WK_VINC",AVSX3("EF3_DT_EVE",2),AVSX3("EF3_DT_EVE",3),AVSX3("EF3_DT_EVE",4)})      
   Aadd(Adata,{"WK_EVENT",AVSX3("EEQ_EVENT",2),AVSX3("EEQ_EVENT",3),AVSX3("EEQ_EVENT",4)})
   Aadd(Adata,{"WK_EVDES",AVSX3("EC6_DESC",2),AVSX3("EC6_DESC",3),AVSX3("EC6_DESC",4)})   
   Aadd(Adata,{"WK_PREEMB",AVSX3("EEQ_PREEMB",2),AVSX3("EEQ_PREEMB",3),AVSX3("EEQ_PREEMB",4)})
   Aadd(Adata,{"WK_INV",AVSX3("EEQ_NRINVO",2),AVSX3("EEQ_NRINVO",3),AVSX3("EEQ_NRINVO",4)})
   Aadd(Adata,{"WK_PARC",AVSX3("EEQ_PARC",2),AVSX3("EEQ_PARC",3),AVSX3("EEQ_PARC",4)})   
   Aadd(Adata,{"WK_PGT",AVSX3("EEQ_PGT",2),AVSX3("EEQ_PGT",3),AVSX3("EEQ_PGT",4)})   
   Aadd(Adata,{"WK_VALOR",AVSX3("EEQ_VL",2),AVSX3("EEQ_VL",3),AVSX3("EEQ_VL",4)})
   Aadd(Adata,{"WK_VALMOE",AVSX3("EEQ_VL",2),AVSX3("EEQ_VL",3),AVSX3("EEQ_VL",4)})   
   Aadd(Adata,{"WK_MOE",AVSX3("EEC_MOEDA",2),AVSX3("EEC_MOEDA",3),AVSX3("EEC_MOEDA",4)})   
   Aadd(Adata,{"WK_OBS",AVSX3("EEQ_OBS",2),AVSX3("EEQ_OBS",3),AVSX3("EEQ_OBS",4)})   
   Aadd(Adata,{"WK_TIPOC","C",30,0})   
   If lTPCONExt
      Aadd(Adata,{"WK_TP_CON","C",30,0})            
   ENDIF

   //** PLB (TAV095) 18/12/06
   If Select("Work") > 0
      Work->( DBCloseArea() )       
   EndIf
   //**

   WorkFile := E_CriaTrab(,Adata,"Work") //THTS - 27/09/2017 - TE-6431 - Temporario no Banco de Dados

   Processa({||EFFWRKUP()})
   IIF(lSeqCnt, Processa({||EFFWRKIMP()}), )   //** PLB 07/03/06 - Caso exista Sequencia do Contrato, pesquisa Importação
 
   dbselectarea("work")
   
   IF lEF3cmp //CASO EXISTA BANCO E PRAÇA
      if empty(alltrim(aSelecao))
          IndRegua("WORK",ArqWORKi,"WK_PREEMB+WK_INV+WK_PARC")
      else
          indRegua("WORK",ArqWORKi,"WK_PREEMB+WK_INV+WK_PARC+WK_PRACA")             
      endif
   else
      IndRegua("WORK",ArqWORKi,"WK_PREEMB+WK_INV+WK_PARC")      
   ENDIF
   If work->(EasyReccount("Work")) > 0
      //Estrutura do MSSELECT
      Acampos :={}
      Aadd(Acampos,{"WK_FILNOME",,"Nome da Filial "," "})
      Aadd(Acampos,{"WK_FIONOME",,"Filial de origem"," "})
      Aadd(Acampos,{"WK_TIPO",, "Situação "," "})
      Aadd(Acampos,{"WK_TIPOC",,"Tipo"," "})
      if lTPCONExt
         Aadd(Acampos,{"WK_TP_CON",,"Tipo do cambio"," "})
      ENDIF
      if empty(alltrim(aSelecao)) //06-04-05
           Aadd(Acampos,{"WK_NROP",, "Nº Operacao"," "})         
      endif      
      //** PLB 07/03/06 - Caso exista Sequencia do Contrato
      If lSeqCnt .And. Empty(AllTrim(cSequencia))   
         Aadd(Acampos,{"WK_SEQCNT",,"Seq Contrato"," "})
      EndIf
      If lLincre  //  Caso exista Linha de Credito
         Aadd(Acampos,{"WK_LINCRE",,"Linha Credito"," "})
      EndIf
      //**
      Aadd(Acampos,{"WK_PREEMB",,AVSX3("EEQ_PREEMB",5),AVSX3("EEQ_PREEMB",6)})
      Aadd(Acampos,{"WK_INV",,AVSX3("EEQ_NRINVO",5),AVSX3("EEQ_NRINVO",6)})
      IF lEF3cmp
         Aadd(Acampos,{"WK_BANCO",,AVSX3("EF3_BAN_FI",5),AVSX3("EF3_BAN_FI",6)})
         Aadd(Acampos,{"WK_PRACA",,AVSX3("EF3_PRACA",5),AVSX3("EF3_PRACA",6)})
      ENDIF
      Aadd(Acampos,{"WK_PARC",,"Nro Parcela / Linha"/*AVSX3("EEQ_PARC",5)*/,AVSX3("EEQ_PARC",6)}) //**PLB 07/03/06
      Aadd(Acampos,{"WK_VINC",,AVSX3("EF3_DT_EVE",5),AVSX3("EF3_DT_EVE",6)})
      Aadd(Acampos,{"WK_EVENT",,AVSX3("EEQ_EVENT",5),AVSX3("EEQ_EVENT",6)})
      Aadd(Acampos,{"WK_EVDES",,AVSX3("EC6_DESC",5),AVSX3("EC6_DESC",6)})
      Aadd(Acampos,{"WK_PGT",,"Dt.Liq.Cambio",AVSX3("EEQ_PGT",6)})
      Aadd(Acampos,{"WK_MOE",,"Moeda",AVSX3("EEC_MOEDA",6)})
      Aadd(Acampos,{"WK_VALMOE",,"Valor Parcela - Moeda",AVSX3("EEQ_EQVL",6)})
      Aadd(Acampos,{"WK_VALOR",,"Valor Parcela - R$",AVSX3("EEQ_EQVL",6)})      
      Aadd(Acampos,{"WK_OBS",,"Obs",AVSX3("EEQ_OBS",6)})            
      //      {"WK_VALVINC",,"Valor do contrato",AVSX3("EF3_VL_REA",6)}}
      //DEFINE MSDIALOG oDlg2 TITLE STR0007 FROM oMainWnd:nTop+50, oMainWnd:nLeft+50 TO oMainWnd:nHeight-200,oMainWnd:nWidth-250 OF oMainWnd PIXEL 
      DEFINE MSDIALOG oDlg2 TITLE STR0007 FROM 50, 000 TO 450, 750 OF oMainWnd PIXEL
      
      @ 00,00 MsPanel oPanel Prompt "" Size 50,15 of oDlg2

      //** PLB 07/06/03
      If lSeqCnt// .And. ( !Empty(alltrim(aSelecao)) .Or. !Empty(AllTrim(cSequencia)) ) //06-04-05
         @ 5,3 say STR0001+" "+IIF(Empty(aSelecao),"-",AllTrim(aSelecao))+Space(10)+STR0013+IIF(Empty(AllTrim(cSequencia)) .Or. !lEveSeq,"-",AllTrim(cSequencia)) Of oPanel pixel // "Sequencia do Contrato: "
         IIF(!lEveSeq .And. !Empty(AllTrim(cSequencia)),MsgInfo(STR0014+AllTrim(cSequencia)),) // "Nao existem Eventos de Contrato para a Sequencia "
      ElseIf !Empty(alltrim(aSelecao))
         @ 5,3 say STR0001+" "+AllTrim(aSelecao) Of oPanel pixel
      Else
         nLin:=5      
      EndIf            
      //**
      oSel:=MsSelect():New("WORK",,,Acampos,,cMarca,{nLin,3,((oDlg2:nClientHeight-20)/2)-5,(oDlg2:nClientWidth-4)/2})

      @ ((oDlg2:nClientHeight-20)/2)-5,00 MsPanel oPanel2 Prompt "" Size 50,20 of oDlg2
      @ 3,3 say STR0008+" "+alltrim(str(work->(EasyReccount("work")))) Of oPanel2 pixel

      ACTIVATE MSDIALOG oDlg2 ON INIT (oPanel:Align:=CONTROL_ALIGN_TOP,;
                                       oPanel2:Align:=CONTROL_ALIGN_BOTTOM,;
                                       oSel:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT,;
                                       Work->( DBGoTop() ),;
                                       oSel:oBrowse:Refresh(),;
                                       EnchoiceBar(oDlg2, { || oDlg2:End() }, { || oDlg2:End() },,,,,,,.F.) ) CENTERED
   Else
      msgstop(STR0009) // "Não existem registros para este número de operação"
   endif
   Work->(dbclosearea())

   if file(ArqWORKi)
      ferase(ArqWORKi)
   endif

   if file(ArqEEQi)
      ferase(ArqEEQi)
   endif  
   //oDLG:END()
RETURN .T.


*//Cria work com os registros de exportacao filtrados
*---------------------------------------------------------------------------------------
STATIC FUNCTION EFFWRKUP() //04-01-05 - Alcir Alves
*---------------------------------------------------------------------------------------
        LOCAL Ni:=0    
        Local filial_n:={},filNome:=""
        Local cWhere:=""
        
        EF3->(DBSETORDER(1))
        DBSELECTAREA("EEQ")
        FOR Ni:=1 TO LEN(aFSelEEQ)    
           cFilEEQ:=aFSelEEQ[Ni]
           filial_n:=AvgFilName({cFilEEQ})
           filNome:=filial_n[1] 
//           EEQ->(DBSEEK(cFilEEQ+AvKey(aSelecao,"EEQ_NROP")))
           if !empty(alltrim(aSelecao)) //06-04-05
              EEQ->(DBSEEK(cFilEEQ+aSelecao))
              cWhere:="!EEQ->(EOF()) .AND. EEQ->EEQ_FILIAL==AvKey(cFilEEQ,'EEQ_FILIAL') .AND. EEQ->EEQ_NROP==AvKey(aSelecao,'EEQ_NROP')"
           else
              EEQ->(DBSEEK(cFilEEQ))
              cWhere:="!EEQ->(EOF()) .AND. EEQ->EEQ_FILIAL==AvKey(cFilEEQ,'EEQ_FILIAL')"              
           endif
           DO WHILE &cWhere  //AvKey(aSelecao,"EEQ_NROP")
              //lOCALIZA E GRAVA OS DADOS DO EEQ NA WORK 
              Begin Transaction
                 WORK->(RECLOCK("Work",.T.))
                 WORK->WK_FILIAL:=EEQ->EEQ_FILIAL
                 WORK->WK_FILNOME:=iif(!empty(alltrim(filNome)),filNome,"-")
                 IF EMPTY(EEQ->EEQ_PGT) 
                     WORK->WK_TIPO:=STR0004 //Cambio aberto
                 ELSE
                     WORK->WK_TIPO:=STR0005 //Cambio Fechado                
                 ENDIF
                 WORK->WK_FIONOME:="-"
                 WORK->WK_VINC:=EEQ->EEQ_DTNEGO
                 WORK->WK_NROP:=EEQ->EEQ_NROP
                 //** PLB 07/03/06
                 IIF(lSeqCnt,WORK->WK_SEQCNT:="",)
                 IIF(lLincre,WORK->WK_LINCRE:="",)
                 //**
                 WORK->WK_BANCO:=EEQ->EEQ_BANC
                 WORK->WK_TIPOC:=IIF(EEQ->EEQ_TIPO=="A",STR0019,IIF(EEQ->EEQ_TIPO=="P",STR0020,IIF(EEQ->EEQ_TIPO=="R",STR0021,"")))  //"Adiantamento" "Cambio a pagar" "Cambio a Receber"
                 IF lTPCONExt
                    if !empty(EEQ->EEQ_TP_CON) .and. val(EEQ->EEQ_TP_CON)<=len(cTpCambio)
                       WORK->WK_TP_CON:=cTpCambio[val(EEQ->EEQ_TP_CON)]        
                    endif
                 ENDIF
                 IF lEF3cmp //CASO EXISTA BANCO E PRAÇA
                     WORK->WK_PRACA:="-"
                 ENDIF
                 WORK->WK_EVENT:=EEQ->EEQ_EVENT
                 WORK->WK_EVDES:=POSICIONE("EC6",1,XFILIAL("EC6")+"EXPORT"+EEQ->EEQ_EVENT,"EC6_DESC")
                 WORK->WK_PREEMB:=EEQ->EEQ_PREEMB
                 WORK->WK_INV:=EEQ->EEQ_NRINVO 
                 WORK->WK_PARC:=EEQ->EEQ_PARC
                 WORK->WK_PGT:=EEQ->EEQ_PGT
                 WORK->WK_VALOR:=EEQ->EEQ_EQVL
                 WORK->WK_VALMOE:=EEQ->EEQ_VL
                 WORK->WK_OBS:=EEQ->EEQ_OBS
                 IF leeqMoe
                    WORK->WK_MOE:=EEQ->EEQ_MOEDA
                 ELSE
                    WORK->WK_MOE:="-"
                 ENDIF
                 WORK->WK_CONTRA:="-"
                 WORK->(MSUNLOCK())
              End Transaction
              EEQ->(DBSKIP())
           ENDDO
   
           //lOCALIZA E GRAVA OS DADOS DO EF3 NA WORK  
           cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],aFSelEEQ[Ni])
           If (Empty(Alltrim(cFilEF3)) .And. Ni=1) .Or. !Empty(Alltrim(cFilEF3))
              filial_n:=AvgFilName({cFilEF3})
              filNome:=filial_n[1] 
              //EF3->(DBSEEK(cFilEF3+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC))
              aSelecao2:=left(aSelecao,AVSX3("EF3_CONTRA",3))              
              //** PLB 07/03/06
              If !Empty(alltrim(aSelecao))
                 EF3->(DBSEEK(cFilEF3+IIF(lSeqCnt,"E","")+aSelecao2))
                 cWhere:="!EF3->(EOF()) .AND. EF3->(EF3_FILIAL+EF3_CONTRA)==(cFilEF3+AvKey(aSelecao2,'EF3_CONTRA'))"+IIF(lSeqCnt," .And. EF3->EF3_TPMODU=='E'","")
              Else
                 EF3->(DBSEEK(cFilEF3+IIF(lSeqCnt,"E","")))
                 cWhere:="!EF3->(EOF()) .AND. EF3->EF3_FILIAL==cFilEF3 "+IIF(lSeqCnt," .And. EF3->EF3_TPMODU=='E'","")
              Endif
              //**
              Do While &cWhere
                 Begin Transaction               
                    //** PLB 07/03/06 - Nao seleciona registros com Sequencia de Contrato diferente da digitada
                    If lSeqCnt  .And.  !Empty(AllTrim(cSequencia))  .And.  EF3->EF3_SEQCNT <> AVKey(cSequencia,"EF3_SEQCNT")
                       Break
                    EndIf
                    //**
                    if lEF3cmp
                       //** PLB 07/03/06
                       If EF1->EF1_CONTRA # EF3->EF3_CONTRA .Or. EF1->EF1_BAN_FI # EF3->EF3_BAN_FI .Or. EF1->EF1_PRACA # EF3->EF3_PRACA .Or. IIF(lSeqCnt,EF1->EF1_SEQCNT # EF3->EF3_SEQCNT,.T.) 
                          EF1->(DBSEEK(XFILIAL("EF1")+IIF(lSeqCnt,"E","")+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+IIF(lSeqCnt,EF3->EF3_SEQCNT,"")))
                       EndIf
                    else
                       If EF1->EF1_CONTRA # EF3->EF3_CONTRA .Or. IIF(lSeqCnt,EF1->EF1_SEQCNT # EF3->EF3_SEQCNT,.T.)
                          EF1->(DBSEEK(XFILIAL("EF1")+IIF(lSeqCnt,"E","")+EF3->EF3_CONTRA+IIF(lSeqCnt,EF3->EF3_SEQCNT,"")))
                       //**
                       EndIf
                    endif
                    WORK->(RECLOCK("Work",.T.))
                    WORK->WK_FILIAL:=cFilEF3
                    WORK->WK_FILNOME:=iif(!empty(alltrim(filNome)),filNome,"-")
                    WORK->WK_FILIALO:=IIF(EMPTY(ALLTRIM(EF3->EF3_FILORI)),"-",EF3->EF3_FILORI)
                    WORK->WK_FIONOME:=AvgFilName({WORK->WK_FILIALO})[1]
                    IF lEF3cmp //CASO EXISTA BANCO E PRAÇA
                       WORK->WK_BANCO:=EF3->EF3_BAN_FI
                       WORK->WK_PRACA:=EF3->EF3_PRACA
                    ENDIF
                    //** PLB 07/03/06 - Verifica se existe cadastro de Tipos de Financiamento
                    If lCadFin
                       WORK->WK_TIPOC:=Posicione("EF7",1,xFilial("EF1")+EF1->EF1_TP_FIN,"EF7_DESCRI")
                    Else
                       WORK->WK_TIPOC:=Tabela("CG",EF1->EF1_TP_FIN,.F.)
                    EndIf                                                                    
                    //**
                    //definição passada pela braskem no dia 29-11-05
                    //eventos de contrato tipo cambio igual a 100 e demais evento tipo de cambio igual a 4
                    IF lTPCONExt
                       WORK->WK_TP_CON:=iif(EF3->EF3_CODEVE=="100",cTpCambio[3],cTpCambio[4])        
                    ENDIF
                    //
                    WORK->WK_TIPO:=STR0006 //Eventos de contrato
                    WORK->WK_NROP:=aSelecao
                    IIF(lSeqCnt,WORK->WK_SEQCNT:=EF3->EF3_SEQCNT,)
                    IIF(lLincre,WORK->WK_LINCRE:=EF1->EF1_LINCRE,)
                    WORK->WK_EVENT:=EF3->EF3_CODEVE
                    WORK->WK_EVDES:=POSICIONE("EC6",1,XFILIAL("EC6")+"FIEX"+EF1->EF1_TP_FIN+EF3->EF3_CODEVE,"EC6_DESC")
                    WORK->WK_PREEMB:=EF3->EF3_PREEMB
                    WORK->WK_INV:=EF3->EF3_INVOIC
                    IF lTPCONExt
                       WORK->WK_TP_CON:="-"
                    ENDIF
                    WORK->WK_PARC:=EF3->EF3_PARC
                    WORK->WK_CONTRA:=EF3->EF3_CONTRA
                    WORK->WK_VINC:=EF3->EF3_DT_EVE
                    WORK->WK_VALOR:=EF3->EF3_VL_REA
                    WORK->WK_VALMOE:=EF3->EF3_VL_MOE
                    WORK->WK_MOE:=EF3->EF3_MOE_IN  
                    WORK->WK_OBS:=EF3->EF3_OBS
                    WORK->(MSUNLOCK())
                    lEveSeq := .T. //** PLB 07/03/06 - Verifica se existe evento com a sequencia digitada
                 End Transaction                 
                 EF3->(DBSKIP())
              ENDDO 
           EndIf
        NEXT
        work->(dbgotop())
RETURN .T.


//*************************************************************************************/
//* Funcao: EFFWRKIMP  *     Autor: PLB - Pedro Baroni     *        Data:  07/03/06   */
//*************************************************************************************/
//*         Cria work com os registros do cambio de importação filtrados              */
//************************//***********************************************************/
*---------------------------------------------------------------------------------------
STATIC FUNCTION EFFWRKIMP() 
*---------------------------------------------------------------------------------------
        LOCAL Ni:=0    
        Local filial_n:={},filNome:=""
        Local cWhere:=""
        
        SWB->( DBSetOrder(6) )
        FOR Ni:=1 TO LEN(aFSelSWB)    
           cFilSWB:=aFSelSWB[Ni]
           filial_n:=AvgFilName({cFilSWB})
           filNome:=filial_n[1] 
           If !Empty(alltrim(aSelecao))
              SWB->(DBSEEK(cFilSWB+aSelecao))
              cWhere:="!SWB->(EOF()) .AND. SWB->WB_FILIAL==AvKey(cFilSWB,'WB_FILIAL') .AND. SWB->WB_CA_NUM==AvKey(aSelecao,'WB_CA_NUM')"
           Else
              SWB->(DBSEEK(cFilSWB))
              cWhere:="!SWB->(EOF()) .AND. SWB->WB_FILIAL==AvKey(cFilSWB,'WB_FILIAL')"              
           Endif
           Do While &cWhere
              //lOCALIZA E GRAVA OS DADOS DA SWB NA WORK 
              Begin Transaction
                 WORK->(RECLOCK("Work",.T.))
                 WORK->WK_FILIAL:=SWB->WB_FILIAL
                 WORK->WK_FILNOME:=IIF(!Empty(Alltrim(filNome)),filNome,"-")
                 IF EMPTY(SWB->WB_CA_DT) 
                     WORK->WK_TIPO:=STR0004 //Cambio aberto
                 ELSE
                     WORK->WK_TIPO:=STR0005 //Cambio Fechado
                 ENDIF
                 WORK->WK_FIONOME:="-"
                 WORK->WK_VINC:=SWB->WB_DT_CONT
                 WORK->WK_NROP:=SWB->WB_CA_NUM
                 WORK->WK_SEQCNT:=""
                 IIF(lLincre,WORK->WK_LINCRE:="",)
                 WORK->WK_BANCO:=SWB->WB_BANCO
                 WORK->WK_TIPOC:=IIF(SWB->WB_TIPOC=="P",STR0020,IIF(SWB->WB_TIPOC=="R",STR0021,""))  //"Cambio a pagar" "Cambio a Receber"
                 If lTPCONExt
                    If !Empty(SWB->WB_TP_CON) .and. Val(SWB->WB_TP_CON)<=Len(cTpCambio)
                       WORK->WK_TP_CON:=cTpCambio[Val(SWB->WB_TP_CON)]        
                    Endif
                 EndIf
                 If lEF3cmp //CASO EXISTA BANCO E PRAÇA
                     WORK->WK_PRACA:="-"
                 EndIf
                 WORK->WK_EVENT  := SWB->WB_EVENT
                 WORK->WK_EVDES  := POSICIONE("EC6",1,XFILIAL("EC6")+"IMPORT"+SWB->WB_EVENT,"EC6_DESC")
                 WORK->WK_PREEMB := SWB->WB_HAWB
                 WORK->WK_INV    := SWB->WB_INVOICE
                 WORK->WK_PARC   := SWB->WB_LINHA
                 WORK->WK_PGT    := SWB->WB_CA_DT
                 WORK->WK_VALOR  := SWB->WB_FOBMOE*SWB->WB_CA_TX
                 WORK->WK_VALMOE := SWB->WB_FOBMOE
                 WORK->WK_OBS    := MSMM(SWB->WB_OBS,AVSX3("WB_VM_OBS",AV_TAMANHO),,,LERMEMO)
                 WORK->WK_MOE    := SWB->WB_MOEDA
                 WORK->WK_CONTRA := "-"
                 WORK->(MSUNLOCK())
              End Transaction
              SWB->(DBSKIP())
           ENDDO
   
           //lOCALIZA E GRAVA OS DADOS DO EF3 NA WORK
           cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],aFSelSWB[Ni])
           If (Empty(Alltrim(cFilEF3)) .And. Ni=1) .Or. !Empty(Alltrim(cFilEF3))
              filial_n:=AvgFilName({cFilEF3})
              filNome:=filial_n[1] 
              aSelecao2:=left(aSelecao,AVSX3("EF3_CONTRA",3))              
              If !empty(alltrim(aSelecao))
                 EF3->(DBSEEK(cFilEF3+"I"+aSelecao2))              
                 cWhere:="!EF3->(EOF()) .AND. EF3->(EF3_FILIAL+EF3_CONTRA)==(cFilEF3+AvKey(aSelecao2,'EF3_CONTRA')) .And. EF3->EF3_TPMODU=='I'"
              else
                 EF3->(DBSEEK(cFilEF3+"I"))
                 cWhere:="!EF3->(EOF()) .AND. EF3->EF3_FILIAL=cFilEF3 .And. EF3->EF3_TPMODU=='I'"
              endif
              DO WHILE &cWhere
                 Begin Transaction               
                    If !Empty(AllTrim(cSequencia))  .And.  EF3->EF3_SEQCNT <> AVKey(cSequencia,"EF3_SEQCNT")
                       Break
                    EndIf
                    if lEF3cmp
                       If EF1->EF1_CONTRA # EF3->EF3_CONTRA .Or. EF1->EF1_BAN_FI # EF3->EF3_BAN_FI .Or.EF1->EF1_PRACA # EF3->EF3_PRACA .Or. EF1->EF1_SEQCNT # EF3->EF3_SEQCNT
                          EF1->(DBSEEK(XFILIAL("EF1")+"I"+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))
                       EndIf
                    Else
                       If EF1->EF1_CONTRA # EF3->EF3_CONTRA .Or. EF1->EF1_SEQCNT # EF3->EF3_SEQCNT
                          EF1->(DBSEEK(XFILIAL("EF1")+"I"+EF3->EF3_CONTRA+EF3->EF3_SEQCNT))
                       EndIf
                    endif
                    WORK->(RECLOCK("Work",.T.))
                    WORK->WK_FILIAL:=cFilEF3
                    WORK->WK_FILNOME:=iif(!empty(alltrim(filNome)),filNome,"-")
                    WORK->WK_FILIALO:=IIF(EMPTY(ALLTRIM(EF3->EF3_FILORI)),"-",EF3->EF3_FILORI)
                    WORK->WK_FIONOME:=AvgFilName({WORK->WK_FILIALO})[1]
                    IF lEF3cmp //CASO EXISTA BANCO E PRAÇA
                       WORK->WK_BANCO:=EF3->EF3_BAN_FI
                       WORK->WK_PRACA:=EF3->EF3_PRACA
                    ENDIF
                    If lCadFin
                       WORK->WK_TIPOC:=Posicione("EF7",1,xFilial("EF1")+EF1->EF1_TP_FIN,"EF7_DESCRI")
                    Else
                       WORK->WK_TIPOC:=Tabela("CG",EF1->EF1_TP_FIN,.F.) 
                    EndIf
                    IF lTPCONExt
                       WORK->WK_TP_CON:=iif(EF3->EF3_CODEVE=="100",cTpCambio[3],cTpCambio[4])        
                    ENDIF
                    WORK->WK_TIPO:=STR0006 //Eventos de contrato
                    WORK->WK_NROP:=aSelecao
                    WORK->WK_SEQCNT:=EF3->EF3_SEQCNT
                    IIF(lLincre,WORK->WK_LINCRE:=EF1->EF1_LINCRE,)
                    WORK->WK_EVENT:=EF3->EF3_CODEVE
                    WORK->WK_EVDES:=POSICIONE("EC6",1,XFILIAL("EC6")+"FIIM"+EF1->EF1_TP_FIN+EF3->EF3_CODEVE,"EC6_DESC")
                    WORK->WK_PREEMB:=EF3->EF3_PREEMB
                    WORK->WK_INV:=EF3->EF3_INVOIC
                    IF lTPCONExt
                       WORK->WK_TP_CON:="-"
                    ENDIF
                    WORK->WK_PARC:=EF3->EF3_PARC
                    WORK->WK_CONTRA:=EF3->EF3_CONTRA
                    WORK->WK_VINC:=EF3->EF3_DT_EVE
                    WORK->WK_VALOR:=EF3->EF3_VL_REA
                    WORK->WK_VALMOE:=EF3->EF3_VL_MOE
                    WORK->WK_MOE:=EF3->EF3_MOE_IN  
                    WORK->WK_OBS:=EF3->EF3_OBS
                    WORK->(MSUNLOCK())
                    lEveSeq := .T. // Verifica se existem Eventos com a Sequencia digitada
                 End Transaction                 
                 EF3->(DBSKIP())
              ENDDO
           EndIf
        NEXT
        work->(dbgotop())
RETURN .T.
