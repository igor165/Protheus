//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICHC150.ch"

/*Funcao EICHC150 
Descricao:Historico das Ultimas Compras
Uso:Sigaeic
Chamada:Menu*/

// CES - OS 588/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICHC150
// um parametro como .T. identificando que é schedulado 


*---------------------*
FUNCTION EICHC150S
*---------------------*
EICHC150(.T.)
RETURN NIL
       
*------------------------*
FUNCTION EICHC150(lSXD)
*------------------------*
LOCAL oDlg, oPanel, nAscan,lOk,cAno:=Right(Padl(Set(_SET_EPOCH),4,"0"),2)   
LOCAL cPictForne:=AVSX3("A2_COD",6),cPictProd:=AVSX3("B1_COD",6)
              


PRIVATE cFornecedor,cProduto,dDtInicio,dDtFinal
PRIVATE cTitulo:=STR0037 //Historico da Ultimas Compras
PRIVATE cFileWork,cIndex1,cQuebra,cIndex2//igorchiba 06/07/2010 incluir index2
PRIVATE cMarca := GetMark(), lInverte := .F.         
PRIVATE lEmail := !lSXD == NIL  // CES - OS 588/02     

PRIVATE TB_Campos:={}////igorchiba 06/07/2010  para manipular no rdmake
PRIVATE aDados :={"Work",;   //igorchiba 06/07/2010  para manipular no rdmake
                 STR0035,;      //"Este relatório irá exibir um estatística sobre"
                 STR0036,;      //"as ultimas compras efetuadas"
                 "",;
                 "G",;
                 220,;
                 "",;
                 "",;
                 STR0037,;      //"Historico das Ultimas Compras"
                 { "", 1,"", 1, 2, 1, "",1 },;
                 "EICHC150",;
                 { {||HC150QUEBRA()} , {|| .T. }  }  }  

PRIVATE aReturn := aDados[10]//igorchiba 06/07/2010  para manipular no rdmake
PRIVATE aRCampos:={} ////igorchiba 06/07/2010  para manipular no rdmake

AADD(TB_Campos,{{||WORK->WKCODIGO+" "+WORK->WKDESC},"",STR0018,cPictProd  })//item
AADD(TB_Campos,{"WKFORN"  ,"",STR0003,cPictForne})//Fornecedor
AADD(TB_Campos,{"WKFABR"  ,"",STR0002,cPictForne})//Fabricante
AADD(TB_Campos,{"WKPO_NUM","" ,AVSX3("W2_PO_NUM",5) ,AVSX3("W2_PO_NUM",6)})
AADD(TB_Campos,{"WKQTDE"  ,"" ,STR0050,AVSX3("W3_QTDE",6)})//  "Qtde. Solic."
AADD(TB_Campos,{"WKSALDOATU","",STR0023,})//"Saldo Atual"
AADD(TB_Campos,{"WKMOEDA" ,"" ,AVSX3("W2_MOEDA",5),AVSX3("W2_MOEDA",6)})
AADD(TB_Campos,{"WKPRECO" ,"" ,AVSX3("W3_PRECO",5)  ,AVSX3("W3_PRECO",6)})
AADD(TB_Campos,{"WKEMBPO" ,"" ,STR0051,AVSX3("W3_DT_EMB",6)})//"Emb. Previsto"
AADD(TB_Campos,{"WKHAWB" ,"" ,AVSX3("W6_HAWB",5)  ,AVSX3("W6_HAWB",6)})
AADD(TB_Campos,{"WKDINUM" ,"" ,AVSX3("W6_DI_NUM",5)  ,AVSX3("W6_DI_NUM",6)})
AADD(TB_Campos,{"WKEMBQTDE","",STR0052,AVSX3("W7_SALDO_Q",6)}) //"Qtde. Embarcada"
AADD(TB_Campos,{"WKEMBDI" ,"" ,AVSX3("W6_DT_EMB",5)  ,AVSX3("W6_DT_EMB",6)})

IF !lEmail
   PROCESSA({||lOk:=HC150CRIAWORK()})
ELSE   
   lOk:=HC150CRIAWORK()
ENDIF
   
IF !lOk
   RETURN .T.
ENDIF   

DO WHILE .T.    

   aRCampos:={}
   
   AADD(aRCampos,{"WKCODIGO"  ,"",STR0018,cPictProd})                                             //ITEM
   AADD(aRCampos,{"WKDESC"    ,"",STR0001,cPictProd})                                             //DESCRICAO   
   AADD(aRCampos,{"WKFORN"    ,"",STR0003,cPictForne})                                            //Fornecedor
   AADD(aRCampos,{"WKFABR"    ,"",STR0002,cPictForne})                                            //Fabricante
   AADD(aRCampos,{"WKPO_NUM"  ,"",AVSX3("W2_PO_NUM",5),AVSX3("W2_PO_NUM",6)})                     //Nro. PO
   AADD(aRCampos,{{||HC150RELAT(WORK->WKQTDE,AVSX3("W3_QTDE",6))},"",STR0050,})                   //"Qtde. Solic."   
   AADD(aRCampos,{"WKSALDOATU","",STR0023,})                                                      //"Saldo Atual"      
   AADD(aRCampos,{"WKMOEDA"   ,"",AVSX3("W2_MOEDA",5),AVSX3("W2_MOEDA",6)})                       //Moeda              
   AADD(aRCampos,{{||HC150RELAT(WORK->WKPRECO  ,AVSX3("W3_PRECO",6  ))} ,"",AVSX3("W3_PRECO",5),})//Preço
   //AADD(aRCampos,{{||HC150RELAT(WORK->WKEMBPO  ,"@D")},"",STR0051,})                            //"Emb. Previsto" //*** GFP 10/08/2011 - Nopado
   AADD(aRCampos,{"WKHAWB"    ,"",AVSX3("W6_HAWB",5),AVSX3("W6_HAWB",6)})                         //Processo       
   AADD(aRCampos,{{||HC150RELAT(WORK->WKDINUM,AVSX3("W6_DI_NUM",6))} ,"" ,AVSX3("W6_DI_NUM",5),}) //Nro. Processo
   AADD(aRCampos,{{||HC150RELAT(WORK->WKEMBQTDE,AVSX3("W7_SALDO_Q",6))},"",STR0052,})             //"Qtde. Embarcada"
   AADD(aRCampos,{{||HC150RELAT(WORK->WKEMBDI,AVSX3("W6_DT_EMB" ,6))} ,"" ,AVSX3("W6_DT_EMB",5),})//Dt. Embarque
 
   IF(EasyEntryPoint("EICHC150"),Execblock("EICHC150",.F.,.F.,"ARCAMPOS"),)//igorchiba 06/07/2010  para manipular no rdmake
   aRCampos:=E_CriaRCampos(aRCampos)
   
   IF (nAscan:=ASCAN(aRcampos,{|a|a[2]==STR0023}))> 0//"Saldo Atual"
      aRcampos[nAscan,3]:="D"
   ENDIF
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Variaveis utilizadas para parametros                         ³
   //³ mv_par01      // Fornecedor                                  ³
   //  mv_par02      // Loja                                        ³
   //³ mv_par03      // Produto                                     ³  
   //³ mv_par04      // Data inicial                                ³  
   //³ mv_par05      // Data final                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //THTS - nopada a funcao VerLojaSX1, pois nao podera mais dar reclock nos fontes. Os campos loja estao corretos no AtuSX.
   //VerLojaSX1("EIC151")//AOM - 04/01/2011 - Criada função generica para adicionar o campo loja no grupo do SX1
 
   IF !Pergunte("EIC151",IF(lEmail,.F.,.T.)) 
      EXIT
   ENDIF    
  
   IF lEmail
      aDados[11]:=SetPrint(aDados[1],aDados[11],"EIC151",@aDados[9],aDados[2],aDados[3],aDados[4],.F.,"",.T.,aDados[5])    
   ENDIF     
  
   cFornecedor:=mv_par01
   cLoja      :=mv_par02
   cProduto   :=mv_par03
   dDtInicio  :=mv_par04
   dDtFinal   :=mv_par05
   lPadrao:=.T.//igorchiba 06/07/2010  tela padrao 
   lGrvPadr:=.T.//igorchiba 06/07/2010  gravacao padrao
   IF(EasyEntryPoint("EICHC150"),Execblock("EICHC150",.F.,.F.,"LPADRAO"),)//igorchiba 06/07/2010  para manipular no rdmake
  
   IF !lEmail .AND. ( !E_Periodo_OK(@dDtInicio,@dDtFinal) .or. !HC150VALID("LINK") )
      LOOP
   ENDIF
  
   IF !lEmail
      PROCESSA({|| HC150GRVWORK(cFornecedor,cProduto,dDtInicio,dDtFinal,cLoja)})
   ELSE
      HC150GRVWORK(cFornecedor,cProduto,dDtInicio,dDtFinal,cLoja)
   ENDIF   
   
   WORK->(DBGOTOP())
   IF WORK->(EOF()) .AND. WORK->(BOF())
      IF lEmail
         EXIT
      ENDIF
      
      Help(" ",1,"EICSEMREG")
      LOOP 
   ENDIF         

   IF dDtInicio==AVCTOD("01/01/"+cAno) .AND. dDtFinal==AVCTOD("31/12/2999")   
      aDados[7]:=STR0053+": "+STR0054//Geral
   ELSE
      aDados[7]:=STR0053+": "+DTOC(dDtInicio)+" - "+DTOC(dDtFinal)//"data p.o
   ENDIF   
   
   aDados[8]:=" "
   IF lPadrao //igor chiba se for padrao retira estes trechos se nao nao 
      IF (EMPTY(cFornecedor) .AND. IIF(EICLoja(),EMPTY(cLoja),.T.)) .AND. EMPTY(cProduto)  
         IF (nAscan:=ASCAN(aRcampos,{|a|a[2]==STR0002}))> 0//Fabricante
            ADEL(aRCampos,nAscan)
            ASIZE(aRCampos,LEN(aRCampos)-1)
         ENDIF   
      ELSE   
         IF (!EMPTY(cFornecedor) .AND. IIF(EICLoja(),!EMPTY(cLoja),.T.)) .AND. (nAscan:=ASCAN(aRcampos,{|a|a[2]==STR0003}))> 0 //Fornecedor
            ADEL(aRCampos,nAscan)
            ASIZE(aRCampos,LEN(aRCampos)-1)
            SA2->(DBSEEK(xFilial("SA2")+cFornecedor+IIF(EICLoja(),cLoja,"")))            
            aDados[8]:=STR0003+": "+cFornecedor+If(EICLoja()," - "+cLoja,"")+" / "+ALLTRIM(SA2->A2_NREDUZ)
         ENDIF                                                                        
      
         IF !EMPTY(cProduto) .AND. (nAscan:=ASCAN(aRcampos,{|a|a[2]==STR0018}))> 0 //Item
            ADEL(aRCampos,nAscan)                                                        
            ASIZE(aRCampos,LEN(aRCampos)-1)  
         
            IF (nAscan:=ASCAN(aRcampos,{|a|a[2]==STR0001}))> 0 //Descricao
               ADEL(aRCampos,nAscan)                                                        
               ASIZE(aRCampos,LEN(aRCampos)-1)
            ENDIF
                                                       
            SB1->(DBSEEK(xFilial("SB1")+cProduto))
            aDados[8]+=IF(!EMPTY(aDados[8])," - ","")+STR0018+": "+" "+ALLTRIM(SB1->B1_DESC)
         ENDIF   
      ENDIF 
  ENDIF
                   
  WORK->(DBSETORDER(1))                                                         
  Work->(DBGOTOP())
  cQuebra:=WORK->WKCODa+WORK->WKFORNa+WORK->WKFABRa
  
  
  IF lEmail   
     E_Report(aDados,aRCampos,,.F.)
     EXIT 
  ELSE
     IF lPadrao //igorchiba 06/07/2010  
        oMainWnd:ReadClientCoors() 
        DEFINE MSDIALOG oDlg TITLE cTitulo FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
        OF oMainWnd PIXEL
           @ 00,00 MsPanel  oPanel Prompt "" Size 60,20 of oDlg    //LRL 27/04/04
           DEFINE SBUTTON FROM 4,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (E_Report(aDados,aRCampos)) ENABLE OF oPanel

           oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
           oDlg:lMaximized:=.T.
		   
		   oPanel:Align:=CONTROL_ALIGN_TOP                        
           oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		   
        ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})) CENTERED  //LRL 27/04/04 //Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
     ELSE                                                              
        IF(EasyEntryPoint("EICHC150"),Execblock("EICHC150",.F.,.F.,"TELA_01"),)//igorchiba 06/07/2010 tela customizada
     ENDIF 
  ENDIF
ENDDO             

SW2->(DBSETORDER(1))
SW3->(DBSETORDER(1))
SW5->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SA5->(DBSETORDER(1))

WORK->(E_EraseArq(cFileWork,cIndex1,cIndex2))

RETURN .T.

*------------------------------------------------------------------------*
FUNCTION HC150GRVWORK(cFornecedor,cProduto,dDtInicio,dDtFinal)
*------------------------------------------------------------------------*
LOCAL cFilSW2:=xFilial("SW2"),cFilSW3:=xFilial("SW3"),cFilSA2:=xFilial("SA2")
LOCAL cFilSW5:=xFilial("SW5"),cFilSW6:=xFilial("SW6"),cFilSW7:=xFilial("SW7")
LOCAL cFilSB1:=xFilial("SB1")
LOCAL bWhile,nContador:=0,nRegua:=5,cNomeForne:=cNomeFabri:=CriaVar("A2_NREDUZ")
LOCAL lPrimeiro,cPictSaldo:=AVSX3("W3_SALDO_Q",6),lTemItem,lTemForn
PRIVATE oDlgProc

IF !lEmail
  oDlgProc := GetWndDefault()
ENDIF  

SW2->(DBSETORDER(4))//FILIAL+DATA PO   
SW2->(DBSEEK(cFilSW2+DTOS(dDtInicio),.T.))
bWhile:={||SW2->W2_FILIAL==cFilSW2 .AND. SW2->W2_PO_DT<=dDtFinal}
bFor:={||.T.}

IF (!EMPTY(cFornecedor) .AND. IIF(EICLoja(),!EMPTY(cLoja),.T.)) 
   SW2->(DBSETORDER(2))//FILIAL+FORNECEDOR
   SW2->(DBSEEK(cFilSW2+cFornecedor+IIF(EICLoja(),cLoja,"")))
   bWhile:={||SW2->W2_FILIAL+RTRIM(SW2->W2_FORN)+RTRIM(EICRetLoja("SW2","W2_FORLOJ"))==cFilSW2+RTRIM(cFornecedor)+IIF(EICLoja(),RTRIM(cLoja),"")}

   //TRP-19/10/07- Tratamento para as datas (inicial e final) do filtro
   If !EMPTY(dDtInicio) .and. !EMPTY(dDtFinal)
      bFor:={||SW2->W2_PO_DT>=dDtInicio .and. SW2->W2_PO_DT<=dDtFinal}   
   Elseif EMPTY(dDtInicio) .and. !EMPTY(dDtFinal)
      bFor:= {||SW2->W2_PO_DT<=dDtFinal}
   Elseif EMPTY(dDtFinal) .and. !EMPTY(dDtInicio)
      bFor:= {||SW2->W2_PO_DT>=dDtInicio}
   Endif     
ENDIF  

SW3->(DBSETORDER(1))//W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I
SW5->(DBSETORDER(3))//W5_FILIAL+W5_PO_NUM+W5_COD_I+W5_POSICAO
SW6->(DBSETORDER(1))//W6_FILIAL+W6_HAWB
SW7->(DBSETORDER(4))//W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM
SB1->(DBSETORDER(1))//B1_FILIAL+B1_COD

IF !lEmail
   ProcRegua(nRegua)
ENDIF   

WORK->(avzap())

DO WHILE SW2->(!EOF()) .AND. EVAL(bWhile)
   IF !EVAL(bFor)
      SW2->(DBSKIP())
      LOOP
   ENDIF
   
   IF !lEmail
      oDlgProc:SetText(STR0010+": "+ALLTRIM(SW2->W2_PO_NUM))//"P.O. :"
   ENDIF   
   
   IF !SW3->(DBSEEK(cFilSW3+SW2->W2_PO_NUM))
      SW2->(DBSKIP())
      LOOP
   ENDIF
   
   DO WHILE SW3->(!EOF()) .AND. SW3->W3_FILIAL+SW3->W3_PO_NUM==cFilSW3+SW2->W2_PO_NUM   
      IF !lEmail
         Incproc(STR0055+SW3->W3_COD_I)//"Lendo Item: "      
         
         nContador++
         IF nContador==nRegua
            nContador:=0
            ProcRegua(nRegua)
         ENDIF
      ENDIF
      
      IF (!EMPTY(cProduto) .AND. SW3->W3_COD_I<>cProduto) 
         SW3->(DBSKIP())
         LOOP
      ENDIF      

      IF SW3->W3_SEQ<>0
         SW3->(DBSKIP())
         LOOP
      ENDIF
      
      lLoop:=.F.//igorchiba 06/07/2010  para manipular no rdmake
      IF(EasyEntryPoint("EICHC150"),Execblock("EICHC150",.F.,.F.,"LOOP"),)//igorchiba 06/07/2010  validacao rdmake
      IF lLOOp
         SW3->(DBSKIP())
         LOOP                                     
      ENDIF
      
      IF lGrvPadr  //igorchiba 06/07/2010  gravacao padrao
      
      IF SA2->(DBSEEK(cFilSA2+SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ")))
         cNomeForne:=SA2->A2_NREDUZ
      ENDIF
                                   
      cNomeFabri:=SA2->A2_NREDUZ
       IF (SW3->W3_FORN<>SW3->W3_FABR .AND. IIF(EICLoja(),SW3->W3_FORLOJ<>SW3->W3_FABLOJ,.T.)) .AND. SA2->(DBSEEK(cFilSA2+SW3->W3_FABR+EICRetLoja("SW3","W3_FABLOJ")))   
         cNomeFabri:=SA2->A2_NREDUZ
      ENDIF
      
      WORK->(DBSETORDER(1))                       
      lTemItem:=WORK->(DBSEEK(SW3->W3_COD_I))
      
      WORK->(DBSETORDER(2))
      lTemForn:=WORK->(DBSEEK(SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ")))
            
      WORK->(DBAPPEND())
      WORK->WKCODa   :=SW3->W3_COD_I //CAMPOS INDICE DA WORK
      WORK->WKFORNa  :=SW3->W3_FORN
      WORK->WKFABRa  :=SW3->W3_FABR
      WORK->WKPO_NUMa:=SW3->W3_PO_NUM
      
      IF !lTemItem
         WORK->WKCODIGO :=SW3->W3_COD_I
         WORK->WKFORN   :=AllTrim(SW3->W3_FORN)+"-"+EICRetLoja("SW3","W3_FORLOJ")+"/"+cNomeForne
         SB1->(DBSEEK(cFilSB1+SW3->W3_COD_I))
         WORK->WKDESC:=SB1->B1_DESC   
      ELSEIF !lTemForn
         WORK->WKFORN   :=AllTrim(SW3->W3_FORN)+"-"+EICRetLoja("SW3","W3_FORLOJ")+"/"+cNomeForne      
      ENDIF            

      WORK->WKFABR   :=AllTrim(SW3->W3_FABR)+"-"+EICRetLoja("SW3","W3_FABLOJ")+"/"+cNomeFabri
      WORK->WKPO_NUM :=SW3->W3_PO_NUM
      WORK->WKQTDE   :=SW3->W3_QTDE
      WORK->WKSALDO_Q:=SW3->W3_SALDO_Q 
      WORK->WKPRECO  :=SW3->W3_PRECO
      //WORK->WKEMBPO  :=SW3->W3_DT_EMB //ASK 27/09/2007 Previsão de embarque, busca do SW5
      WORK->WKMOEDA  :=SW2->W2_MOEDA
      
      IF SW5->(DBSEEK(cFilSW5+SW3->W3_PO_NUM+SW3->W3_COD_I))
         lPrimeiro:=.T.                 
         
         DO WHILE SW5->(!EOF()) .AND. SW5->W5_FILIAL+SW5->W5_PO_NUM+SW5->W5_COD_I==cFilSW5+SW3->W3_PO_NUM+SW3->W3_COD_I
            
            IF SW3->W3_POSICAO <> SW5->W5_POSICAO
               SW5->(DBSKIP())
               LOOP
            ENDIF
            
            IF SW5->W5_SEQ==0
               WORK->WKSALDO_Q+=SW5->W5_SALDO_Q
               WORK->WKSALDOATU:=ALLTRIM(TRANS(WORK->WKSALDO_Q,cPictSaldo))
            ELSEIF SW7->(DBSEEK(cFilSW7+SW5->W5_HAWB+SW5->W5_PO_NUM+SW5->W5_POSICAO+SW5->W5_PGI_NUM))
               IF !lPrimeiro
                  WORK->(DBAPPEND())
               ENDIF   
               WORK->WKEMBPO    := SW5->W5_DT_EMB //ASK 27/09/2007 Previsão de embarque, busca do SW5
               WORK->WKCODa     := SW3->W3_COD_I //CAMPOS INDICE DA WORK
               WORK->WKFORNa    := SW3->W3_FORN
               WORK->WKFABRa    := SW3->W3_FABR
               WORK->WKPO_NUMa  := SW3->W3_PO_NUM
               WORK->WKEMBQTDE  := SW7->W7_SALDO_Q   
               //DFS - 28/09/12 - Tratamento para considerar o preço do W7, visto que, pode ter havido alteração de preço entre o PO e a DI.
               WORK->WKPRECO    := SW7->W7_PRECO
               WORK->WKHAWB     := SW7->W7_HAWB   
               
               IF SW6->(DBSEEK(cFilSW6+SW7->W7_HAWB))
                  WORK->WKEMBDI  :=SW6->W6_DT_EMB
                  WORK->WKDINUM  :=SW6->W6_DI_NUM
               ENDIF
               lPrimeiro:=.F.               
            ENDIF               
            SW5->(DBSKIP())
         ENDDO      
      ELSE  
         //JAP - Acerto para gravar o saldo quando o item possui anuência e não tem PLI.
         WORK->WKSALDOATU:=ALLTRIM(TRANS(WORK->WKSALDO_Q,cPictSaldo))
      ENDIF
      ELSE
         IF(EasyEntryPoint("EICHC150"),Execblock("EICHC150",.F.,.F.,"GRVCUSTO"),)//igorchiba 06/07/2010 gravacao customizada
      ENDIF
      
      SW3->(DBSKIP())
   ENDDO
   SW2->(DBSKIP())   
ENDDO
RETURN .T.

*------------------------------------------------------*
FUNCTION HC150VALID(cCampo)
*------------------------------------------------------*
LOCAL lReturn:=.T.

DO CASE
  CASE cCampo=="FORNECEDOR"     
  
     IF !Empty(mv_par01) .AND. !ExistCpo("SA2",mv_par01)
        RETURN .F.
     ENDIF
     
     SW2->(DBSETORDER(2))     
     IF !EMPTY(mv_par01) .AND. !SW2->(DBSEEK(xFilial("SW2")+mv_par01))
        MSGINFO(STR0048,STR0049)//"Nao ha P.O.s p/ este Fornecedor"###"Informação"
        lReturn:=.F.
     ENDIF
  CASE cCampo=="LINK"     
     IF !EMPTY(mv_par01) .AND. !EMPTY(mv_par03)
        SA5->(DBSETORDER(2))
        IF SA5->(!DBSEEK(xFilial("SA5")+mv_par03+mv_par01))
           HELP(" ",1,"NOPRODFORN")
           RETURN .F.
        ENDIF   
     ENDIF
  CASE cCampo=="PRODUTO"     
     If !Empty(mv_par03)
        AvgExistCpo('SB1',mv_par03,,{xFilial('SB1')})
     Else
        lReturn:=.T.
     EndIf
ENDCASE

RETURN lReturn
                               
*---------------------------------------*
FUNCTION HC150CRIAWORK()
*---------------------------------------*
LOCAL nPos   := 0
LOCAL aSemSX3:={}
PRIVATE aHeader[0],aCampos:={}//E_CriaTrab utiliza

AADD(aSemSX3,{"WKCODa"   ,"C",AVSX3("B1_COD",3),0})
AADD(aSemSX3,{"WKFORNa"  ,"C",AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3),0})
AADD(aSemSX3,{"WKFABRa"  ,"C",AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3),0})
AADD(aSemSX3,{"WKPO_NUMa","C",AVSX3("W2_PO_NUM",3),0})
AADD(aSemSX3,{"WKCODIGO","C",AVSX3("B1_COD",3),0})
AADD(aSemSX3,{"WKFORN"  ,"C",AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3)+1,0})
AADD(aSemSX3,{"WKFABR"  ,"C",AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3)+1,0})
AADD(aSemSX3,{"WKPO_NUM","C",AVSX3("W2_PO_NUM",3),0})
AADD(aSemSX3,{"WKQTDE"  ,"N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)})
AADD(aSemSX3,{"WKEMBQTDE","N",AVSX3("W7_SALDO_Q",3),AVSX3("W7_SALDO_Q",4)})
AADD(aSemSX3,{"WKSALDOATU","C",AVSX3("W3_SALDO_Q",3),0})
AADD(aSemSX3,{"WKSALDO_Q","N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)})
AADD(aSemSX3,{"WKPRECO" ,"N",AVSX3("W3_PRECO",3),AVSX3("W3_PRECO",4)})
AADD(aSemSX3,{"WKEMBPO" ,"D",8,0})
AADD(aSemSX3,{"WKEMBDI" ,"D",8,0})
AADD(aSemSX3,{"WKMOEDA"  ,"C",AVSX3("W2_MOEDA",3),0})
AADD(aSemSX3,{"WKHAWB"  ,"C",AVSX3("W6_HAWB",3),0})
AADD(aSemSX3,{"WKDINUM" ,"C",AVSX3("W6_DI_NUM",3),0})
AADD(aSemSX3,{"WKDESC" ,"C",AVSX3("B1_DESC",3),0})

If EICLOJA() .And. (nPos := aScan(aSemSX3, {|x| x[1] == "WKFORNa" })) > 0
   aAdd(aSemSX3, Nil)
   aIns(aSemSX3, nPos + 1)
   aSemSX3[nPos+1] := {"WKFORLOJ", "C", AvSx3("W1_FORLOJ", AV_TAMANHO),0}
EndIf  

If EICLOJA() .And. (nPos := aScan(aSemSX3, {|x| x[1] == "WKFABRa" })) > 0
   aAdd(aSemSX3, Nil)
   aIns(aSemSX3, nPos + 1)
   aSemSX3[nPos+1] := {"WKFABLOJ", "C", AvSx3("W1_FABLOJ", AV_TAMANHO),0}
EndIf

cFileWork:=E_CriaTrab(,aSemSX3,"Work")
IndRegua("WORK",cFileWork+TEOrdBagExt(),"WKCODa")

cIndex1:=E_CREATE(,.F.)
If EICLoja()
   IndRegua("WORK",cIndex1+TEOrdBagExt(),"WKFORNa+WKFORLOJ")
Else
   IndRegua("WORK",cIndex1+TEOrdBagExt(),"WKFORNa")
EndIf
                                              
cIndex2:=E_CREATE(,.F.) //igorchiba 06/07/2010  novo indice
IndRegua("WORK",cIndex2+TEOrdBagExt(),"WKFABRa")

SET INDEX TO (cFileWork+TEOrdBagExt()),(cIndex1+TEOrdBagExt()),(cIndex2+TEOrdBagExt())
        

IF !USED() .AND. !lEmail 
   HELP(" ",1,"AVG0000029")
   RETURN .F.
ENDIF          
RETURN .T.

*--------------------------------------------*
FUNCTION HC150RELAT(cCampo,cPicture)
*--------------------------------------------*
LOCAL cRetorno:=" "

IF !EMPTY(cCampo)
   cRetorno:=TRANS(cCampo,cPicture)
ENDIF

RETURN cRetorno
                             
*------------------------------*
FUNCTION HC150QUEBRA()
*------------------------------*
IF cQuebra<>WORK->WKCODa
   LINHA++
   cQuebra:=WORK->WKCODa
ENDIF     

RETURN .T.
 


