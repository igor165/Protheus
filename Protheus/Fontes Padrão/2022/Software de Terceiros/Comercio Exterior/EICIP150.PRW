#INCLUDE "Eicip150.ch" 
#include "Average.ch"
//#include "FiveWin.ch"

#DEFINE C_CUSTO     1
#DEFINE COMPRADOR   2
#DEFINE DESPACHANTE 3
#DEFINE CLIENTE    IF(TArquivo==LICENC_PENDENTE .OR. TArquivo==PEDIDO_PENDENTE,3,4)
#DEFINE FORNECEDOR IF(TArquivo == GERAL,3,TIndice)//IF(TArquivo==GERAL,3,9) -- ACB 26/08/2010 - Melhoria filtro por fornecedor


#DEFINE SOLIC_PENDENTE  1
#DEFINE PEDIDO_PENDENTE 2
#DEFINE LICENC_PENDENTE 3
#DEFINE DESEMB_PENDENTE 4
#DEFINE GERAL           5
#DEFINE GERAL_PO        6

#COMMAND E_RESET_AREA => DBSELECTAREA(nOldArea) ; IF(SELECT("TRB")<>0,TRB->(E_EraseArq(cNomArq)),) ;
                       ; IF(SELECT("TRB")<>0,TRB->(FERASE(cNomArq+RetIndExt())),)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICIP150 ³ Autor ³ AVERAGE/RS            ³ Data ³ 11.03.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Itens Pendentes                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICIP150()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------*
Function EICIP150R3()
*--------------------*
//Chamada para o método antigo
EICIP150R4(.F.)
Return NIL

*--------------------*
Function EICIP150()   
*--------------------*
//Chamada padrão do MENU. Testa se é Release 4
Local lTemR4 := .T. /*nopado por RNLP 25/09/2020 - FindFunction("TRepInUse") .And. TRepInUse()*/
EICIP150R4(lTemR4)
Return NIL

*----------------------------------------------------------------------------
Function EicIp150R4(lTemR4)  //Função Principal
*----------------------------------------------------------------------------
// incluir variaveis para o relatorio padrao
LOCAL oGet,nOpcao:=0
Local oDlg //RRV - 04/12/2012
DEFAULT lTemR4 := .F.

PRIVATE cCadastro := OemtoAnsi(STR0001), aCamposTRB:={} //"Itens Pendentes"

Private lR4 := lTemR4
PRIVATE lExisteRD:=EasyEntryPoint("ICPAD150")
PRIVATE nCont:=0
PRIVATE TObs
PRIVATE nLenCC := AVSX3("W0__CC",3) //SO.: 0026 OS.:0273/02 FCD
nOldArea:=SELECT()
PRIVATE aCampos:={}
Private aHeader[0],nUsado:=0,nopc:=2,;
        TArquivo:=1, TCCusto:=Space(nLenCC), TIndice:=1, oRad,oRad1, TComprador:=0,; //FCD 
        TOrder:=1, TDespachante:=SPACE(03), TCliente,TFornec1,TNr_POI, TNr_POF,;
        TCCustoI, TCCustoF, MTemForn:=.F.,lGrvSched:=.F., lComboOrdem:=.T.

//**** TDF - 21/07/11
PRIVATE nTamDesc:= 0
PRIVATE nLinDesc:= 0
PRIVATE cDescTemp, cDescItem
//****

PRIVATE aRotina := { { STR0002    , "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                     { STR0003    , "C210Impor" , 0 , 2} ,; //"Atual"
                     { STR0004    , "C210Impor" , 0 , 3} } //"Todos"

Private T_TabObs[21] , T_TabUSD[21], cNomArq
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
//Tabelas referentes a rotina da Manutenção de Proformas
PRIVATE lNewProforma := ChkFile("EYZ") .AND. ChkFile("EW0")  //TRP-15/08/08
Private aFilSel := {}  //GFP - 14/12/2012
IP150FillTab()
AFILL(T_TabUSD, 0)

cTitulo:=STR0005 //"Itens Pendentes - "

aTArq:={STR0006 ,; //"1-Solicitacoes Pendentes  "
        STR0007 ,; //"2-Pedidos Pendentes       "
        STR0008 ,; //"3-Licenciamentos Pendentes"
        STR0009 ,; //"4-Desembaracos Pendentes  "
        STR0010 ,; //"5-Geral                   "
        STR0011 }  //"6-Geral por P.O.          "

lEmail:=.F.

IF TYPE("__cInternet") == "U"
   __cInternet:= NIL  
EndIf

DO WHILE .T.            

   IF __cInternet # NIL   
      lEmail:= .T.
      E_Init()
      IP150Processa()
      EXIT
   ENDIF

   
   aFilSel:=AvgSelectFil(.T.) //JWJ 25/05/2006  // RS 05/01/06    - Filiais Selecionadas / as que o usuario tem acesso     
    
   IF Len(aFilSel) > 0
      If aFilSel[1] == "WND_CLOSE"    // BOTAO CANCELAR???
         EXIT
      ENDIF
   Else
      aFilSel := {SM0->M0_FILIAL}
   EndIf
  
   nOpcao:= 0
   DEFINE MSDIALOG oDlg TITLE cCadastro From 9,10 To 22,60 OF oMainWnd
   
   @07,05 TO 76,125 LABEL "" OF oDlg PIXEL
   @14,10 RADIO oRad VAR TArquivo ITEMS aTArq[1],aTArq[2],aTArq[3],;
                                        aTArq[4],aTArq[5],aTArq[6] 3D SIZE 110,10 PIXEL

   //ACB - 03/03/2010                                                                               
   // @80,05 CHECKBOX lGrvSched PROMPT "Gravar Informacoes para Schedule" SIZE 110,10 OF oDlg PIXEL 
                                         

   DEFINE SBUTTON FROM 14,150 TYPE 1 ACTION (IP150Menu())           ENABLE OF oDlg
   DEFINE SBUTTON FROM 28,150 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED

   IF nOpcao = 0
      EXIT
   ENDIF
   
ENDDO

SW1->(DBSETORDER(1))
SW3->(DBSETORDER(1))
SW5->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SA5->(DBSETORDER(1))

RETURN NIL
*----------------------------------------------------------------------------*
FUNCTION IP150Processa(aMarcados)
*----------------------------------------------------------------------------*
LOCAL bExecCompartilhado              
LOCAL nInd, nI, aButtons:= {}           
//igorchiba  01/07/2010 passar o adados para private para alterar nos pontos de entrada
PRIVATE aDados :={"TRB",;
                STR0012,; //"Este relatório irá exibir uma estatística sobre"
                STR0013,; //"o desempenho de "
                "",;
                "G",;
                 220,;
                "",;
                "",;
                STR0001,; //"Itens Pendentes"
                { "Zebrado", 1,"Importação", 1, 2, 1, "",1 },;
                "EICIP150",;
                { {||EICIP150QuebraFil()} , {|| .T. }  }  }
                
PRIVATE wnrel   := "EICIP150",nCont:=0,aReturn := aDados[10]
PRIVATE oReport, oBreak //,lR4 

PRIVATE nOpcao:=0 //igorchiba  01/07/2010 deixar private para alterar no ponto de entrada

MontaCampos(TIndice)

//lR4 := FindFunction("TRepInUse") .And. TRepInUse()

IF lEmail
   aDados[11] :=SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
   IP150SX14("SX4","RECUPERAR")
   TRB->(E_EraseArq(cNomArq))
   MontaCampos(TIndice)
ENDIF         

lGrvSched:=.F.

WHILE .T.  .AND. SELECT("TRB") <> 0
   dbselectarea("TRB")
   TRB->(avzap())
   MAbandona = .F.
   DO CASE
      CASE TArquivo = SOLIC_PENDENTE            
           IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")
           MAbandona = .F.
           MInterrompe = .F.                   
                      
           IF !lEmail
              bExecCompartilhado:={||Processa({|lEnd| Grava_IS000()} )}
              cSvFilAnt:=cFilAnt
              FOR nI:=1 TO LEN(aMarcados)
                  aTemp:=aMarcados[nI]
                  cFilSel:=aTemp[1]
                  cFilAnt:=cFilSel                  
                  
                  TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  
                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IS000()} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06
           ELSE
              bExecCompartilhado:={||Grava_IS000()}
              cSvFilAnt:=cFilAnt  
              
              
              FOR nI:=1 TO LEN(aMarcados)
              
                  aTemp:=aMarcados[nI]
                  cFilSel:=aTemp[1]
                  cFilAnt:=cFilSel                  
                  
                  TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  
//                  Grava_IS000()
                  EVAL(bExecCompartilhado)
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06              
           ENDIF   
         
           IF MInterrompe
              MAbandona:=.T.
           ENDIF

           IF MAbandona
              E_RESET_AREA
              RETURN
           ENDIF

      CASE TArquivo = PEDIDO_PENDENTE

           IF TIndice = 1

              IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

           ELSEIF TIndice = 2
              IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+W1_PO_NUM+W3_POSICAO+W1_COD_I")

           ELSEIF TIndice = 3
              If EICLoja()
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+W1_PO_NUM+W3_POSICAO+W1_COD_I")
              Else
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W1_PO_NUM+W3_POSICAO+W1_COD_I")
              EndIf
           ELSEIF TIndice == 4 //ACB 26/08/2010 - Melhoria filtro por fornecedor
              If EICLoja()
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+W1_PO_NUM+W3_POSICAO+W1_COD_I")
              Else
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_PO_NUM+W3_POSICAO+W1_COD_I")
              EndIf
           ENDIF
           MAbandona = .F.
           MInterrompe = .F.
           
           IF !lEmail

              bExecCompartilhado:={||Processa({|lEnd| Grava_IP000(),Grava_IG000()} )}
              cSvFilAnt:=cFilAnt
          
              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)
                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  //ACB 26/08/2010 - Melhoria filtro por fornecedor
                  IF TIndice == FORNECEDOR  .AND. lPegaaTemp
                     TFornec1:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])
                     MTemForn:= IF( EMPTY(TFornec1) , .F. , .T. )
                  ENDIF
                    
                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ELSE
              bExecCompartilhado:={||Grava_IP000(),Grava_IG000()}
              cSvFilAnt:=cFilAnt

              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)

                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  //ACB 26/08/2010 - Melhoria filtro por fornecedor
                  IF TIndice == FORNECEDOR  .AND. lPegaaTemp
                     TFornec1:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])
                     MTemForn:= IF( EMPTY(TFornec1) , .F. , .T. )
                  ENDIF

                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ENDIF   

           IF MInterrompe
              MAbandona:=.T.
           ENDIF

           IF MAbandona
              E_RESET_AREA
              RETURN
           ENDIF         

      CASE TArquivo = LICENC_PENDENTE

           IF TIndice = 1
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSEIF TIndice = 2
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSEIF TIndice = 3
              IF EICLoja()
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ENDIF
              ELSE
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ENDIF
              ENDIF
           ELSEIF TIndice == 4 //ACB - 26/08/2010 - Melhoria filtro por fornecedor
              IF EICLoja()
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")
                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ENDIF
              ELSE
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")
                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ENDIF
              ENDIF   
           ENDIF
           
           MAbandona = .F.
           MInterrompe = .F.

           IF !lEmail

              bExecCompartilhado:={||Processa({|lEnd| Grava_IG000()} )}
              cSvFilAnt:=cFilAnt
          
              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)
                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF
                     

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF
                  
                  //ACB 26/08/2010 - Melhoria filtro por fornecedor
                  IF TIndice == FORNECEDOR  .AND. lPegaaTemp
                     TFornec1:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])
                     MTemForn:= IF( EMPTY(TFornec1) , .F. , .T. )
                  ENDIF

                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ELSE
              bExecCompartilhado:={||Grava_IG000()}
              cSvFilAnt:=cFilAnt

              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)


                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ENDIF   
           
           IF MInterrompe
              MAbandona:=.T.
           ENDIF

           IF MAbandona
              E_RESET_AREA
              RETURN
           ENDIF

      CASE TArquivo = DESEMB_PENDENTE

           IF TIndice = 1
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSEIF TIndice = 2
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSEIF TIndice = 3
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W6_DESP+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W6_DESP+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W6_DESP+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSEIF TIndice = 4
              IF EICLoja()
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ENDIF
              ELSE
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ENDIF

              ENDIF
           ELSEIF  TIndice == 5//ACB - 26/08/2010 -Melhoria filtro por fornecedor
              IF EICLoja()
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")
                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ENDIF
              ELSE
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")
                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")
                 ENDIF
              ENDIF      
           ENDIF
           MAbandona = .F.
           MInterrompe = .F.


           IF !lEmail

              bExecCompartilhado:={||Processa({|lEnd| Grava_ID000()} )}
              cSvFilAnt:=cFilAnt
          
              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)
                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF
                     

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF


                  IF TIndice == DESPACHANTE  .AND. lPegaaTemp
                     TDespachante:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF
                  
                  //ACB 26/08/2010 - Melhoria filtro por fornecedor
                  IF TIndice == FORNECEDOR  .AND. lPegaaTemp
                     TFornec1:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])
                     MTemForn:= IF( EMPTY(TFornec1) , .F. , .T. )
                  ENDIF

                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ELSE
              bExecCompartilhado:={||Grava_ID000()}
              cSvFilAnt:=cFilAnt

              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)

                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  IF TIndice == DESPACHANTE  .AND. lPegaaTemp
                     TDespachante:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ENDIF           
           
           IF MInterrompe
              MAbandona:=.T.
           ENDIF

           IF MAbandona
              E_RESET_AREA
              RETURN
           ENDIF

      CASE TArquivo = GERAL
           IF TIndice = 1
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_CC+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSEIF TIndice = 2
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W0_COMPRA+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSEIF TIndice = 4
              IF EICLoja()
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")

                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W2_CLILOJ+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ENDIF
              ELSE
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+W1_PO_NUM+W3_POSICAO+W1_SI_NUM+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")

                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_CLIENTE+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ENDIF   
              ENDIF
           ELSE
              IF EICLoja()
                 IF TOrder = 1
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ELSEIF TOrder = 2
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")

                 ELSEIF TOrder = 3
                    IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_FORLOJ+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ENDIF
           ELSE
              IF TOrder = 1
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+W1_PO_NUM+W3_POSICAO+W1_COD_I")

              ELSEIF TOrder = 2
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")

              ELSEIF TOrder = 3
                 IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_FORN+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

                 ENDIF
              ENDIF
           ENDIF

           MAbandona = .F.
           MInterrompe = .F.
           
           IF !lEmail
         // MFR-29/09/2020 OSSME-5175                                         //P.O.
         
          bExecCompartilhado:={||Processa({|lEnd| Grava_IS000(),Grava_IP000(),Grava_IG000(),Grava_ID000() } )}
           cSvFilAnt:=cFilAnt
              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)
                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                     TCCustoI:=TCCusto
                     TCCustoF:=IF(EMPTY(aTemp[2][2]),"zzzzz",aTemp[2][2])
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF                    

                  IF TIndice == FORNECEDOR  .AND. lPegaaTemp
                     TFornec1:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                     MTemForn:= IF( EMPTY(TFornec1) , .F. , .T. )
                  ENDIF

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ELSE
              bExecCompartilhado:={||Processa({|lEnd| Grava_IS000(),Grava_IP000(),Grava_IG000(),Grava_ID000() } )}

              cSvFilAnt:=cFilAnt

              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)

                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                  
                  
                  IF TIndice == C_CUSTO   .AND. lPegaaTemp
                     TCCusto:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                     TCCustoI:=TCCusto
                     TCCustoF:=IF(EMPTY(aTemp[2][2]),"zzzzz",aTemp[2][2])
                  ENDIF
                  
                  IF TIndice == COMPRADOR  .AND. lPegaaTemp
                     TComprador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  IF TIndice == FORNECEDOR  .AND. lPegaaTemp
                     TFornec1:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                     MTemForn:= IF( EMPTY(TFornec1) , .F. , .T. )
                  ENDIF

                  IF TIndice == CLIENTE  .AND. lPegaaTemp
                     TCliente:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                  
                  ENDIF

                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ENDIF           

           IF MInterrompe
              MAbandona:=.T.
           ENDIF

           IF MAbandona
              E_RESET_AREA
              RETURN
           ENDIF

      CASE TArquivo = GERAL_PO

           IF TOrder = 1
              IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W1_PO_NUM+W3_POSICAO")

           ELSEIF TOrder = 2
              IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+DTOS(W1_DTENTR_)+W1_PO_NUM+W3_POSICAO")

           ELSEIF TOrder = 3
              IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+WKOBS+W1_PO_NUM+W3_POSICAO+W1_COD_I")

           ENDIF

           MAbandona = .F.
           MInterrompe = .F.

           IF !lEmail

              bExecCompartilhado:={||Processa({|lEnd| Grava_IS000(),Grava_IP000(),Grava_IG000(),Grava_ID000() } )}
              cSvFilAnt:=cFilAnt
          
              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)
                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel                                   
                
                  IF lPegaaTemp
                     TNr_POI:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                     TNr_POF:=IF(LEFT(aTemp[2][2],1)=="*","",aTemp[2][2])
                  ENDIF
                  
                  EVAL(bExecCompartilhado)
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ELSE
              bExecCompartilhado:={||Processa({|lEnd| Grava_IS000(),Grava_IP000(),Grava_IG000(),Grava_ID000() } )}

              cSvFilAnt:=cFilAnt

              lPegaaTemp:=.T.
              IF EMPTY(aMarcados)
                 lPegaaTemp:=.F.
                 aMarcados:=ACLONE(aFilSel)                 
              ENDIF

              FOR nI:=1 TO LEN(aMarcados)

                  aTemp:=aMarcados[nI]
                  cFilSel:=IF(lPegaaTemp,aTemp[1],aTemp)
                  cFilAnt:=cFilSel

                  IF lPegaaTemp  
                     TNr_POI:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])                 
                     TNr_POF:=IF(LEFT(aTemp[2][2],1)=="*","",aTemp[2][2])
                  ENDIF                  
                  EVAL(bExecCompartilhado)
                  //Processa({|lEnd| Grava_IP000(),Grava_IG} )
              NEXT
              cFilAnt:=cSvFilAnt
              IF(EMPTY(aMarcados),EVAL(bExecCompartilhado),)   /// quando for compartilhado - rs 11/12/06   
           ENDIF           

           IF MInterrompe
              MAbandona:=.T.
           ENDIF

           IF MAbandona
              E_RESET_AREA
              RETURN
           ENDIF
   ENDCASE

   IF MAbandona
      E_RESET_AREA
      RETURN
   ENDIF

   nopc:=2
   cTitulo+=RIGHT(aTArq[TArquivo],24)

   IF !lEmail .and. TRB->(Easyreccount("TRB")) <= 0
      Help("",1,"AVG0001039") //"NÇO EXISTEM REGISTROS PARA ESTA SELE€ÇO"###"Informa‡Æo"
      //oDlg:Enable()
      Exit
   ENDIF
   E_CriaCampos(aCamposTRB)

   nPos:=ASCAN(aCamposTRB,{|Campo|Campo[1]=="XX_FLAGWIN"})
   ADEL(aCamposTRB,nPos)
   ASIZE(aCamposTRB,LEN(aCamposTRB)-1)


   nPos:=ASCAN(aCamposTRB,{|Campo|Campo[1]=="A5_CODPRF"})
   ADEL(aCamposTRB,nPos)
   ASIZE(aCamposTRB,LEN(aCamposTRB)-1)

   nPos:=ASCAN(aCamposTRB,{|Campo|Campo[1]=="W3_DT_ENTR"})
   
   IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"CAMPOTRB"),)//igorchiba  01/07/2010 incluir novos campos 
   
   aRCampos:=E_CriaRCampos(aCamposTRB,,1,nPos)
//   AAdd(aRCampos,{"TRANS(TRB->W3_PRECO,'@E 999,999,999,999.99999')","Preco Unit.","E"})   //TRP-16/09/08 - CRF 15/07/2011 - comentado para tirar do relatorio por falta de espaço
   AAdd(aRCampos,{"TRANS(TRB->WKVALOR,'@E 999,999,999,999.99')",STR0106,"E"})//"Vlr FOB Total"
   IF TOrder <> 3    // JBS 19/09/2003   -> Pode ja ter sido adicionado na funcao MontaCampos()
      AAdd(aRCampos,{"WKOBS","Status","E"})  
   ENDIF

   nPos:=ASCAN(aRCampos,{|Campo|"W1_CC"$Campo[1]})
   IF nPos # 0
      aRCampos[nPos][2]:=STR0016 //"U. R."
   ENDIF
   nPos:=ASCAN(aRCampos,{|Campo|"W6_DESP"$Campo[1]})
   IF nPos # 0
      aRCampos[nPos][2]:=STR0017 //"Desp."
   ENDIF
   nPos:=ASCAN(aRCampos,{|Campo|"W1_FORN"$Campo[1]})
   IF nPos # 0
      aRCampos[nPos][2]:=STR0018 //"Forn."
   ENDIF
   If EICLoja()
      nPos:=ASCAN(aRCampos,{|Campo|"W1_FORLOJ"$Campo[1]})
      IF nPos # 0
         aRCampos[nPos][2]:="Loja"//"Loja Forn."  FSM - 08/07/2011
      ENDIF
   ENDIF
   nPos:=ASCAN(aRCampos,{|Campo|"W0_COMPRA"$Campo[1]})
   IF nPos # 0
      aRCampos[nPos][2]:=STR0019 //"Compr."
   ENDIF
   nPos:=ASCAN(aRCampos,{|Campo|"W2_CLIENTE"$Campo[1]})
   IF nPos # 0
      aRCampos[nPos][2]:="Cli." //STR0020 //"Cliente"   CRF 15/07/2011
   ENDIF
   IF EICLoja()
      nPos:=ASCAN(aRCampos,{|Campo|"W2_CLILOJ"$Campo[1]})
      IF nPos # 0
         aRCampos[nPos][2]:="Loja"//"Loja  Cli."  FSM - 08/07/2011
      ENDIF
   ENDIF
   nPos:=ASCAN(aRCampos,{|Campo|"W1_DTENTR_"$Campo[1]}) // JBS 19/09/2003
   IF nPos # 0                                          // JBS 19/09/2003
      aRCampos[nPos][2]:=STR0109 //"Necessidade"        // JBS 19/09/2003
   ENDIF                                                // JBS 19/09/2003
   
   aDados[9]:=cTitulo
   TRB->(DBGOTOP())
   
   //IF lR4
     // oReport := ReportDef()
   //ENDIF

   IF lEmail
      FilAtu:="*"
      E_Report(aDados,aRCampos,.T.,.F.)
      E_RESET_AREA
      EXIT
   ENDIF
      
   aSize(aCamposTRB,len(aCamposTRB)+1)
   aIns(aCamposTRB,1)

   aCamposTRB[1]:={ {||TRB->WKFILIAL+'-'+AvgFilName({TRB->WKFILIAL})[1]},"",AVSX3("W2_FILIAL",5) }
   
   aSize(aCamposTRB,len(aCamposTRB)+1)
   aIns(aCamposTRB,10)
   
   aCamposTRB[10]:={ {||TRB->W3_PRECO},"",AVSX3("W3_PRECO",5),AvSX3("W3_PRECO",6) }  //TRP-16/09/08
   
   lPadrao:=.T.
   IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"ANTESTELA"),)//igorchiba  01/07/2010 desviar tela padrao 
   
   oMainWnd:ReadClientCoors()
   
// Realizadas alterações para ajustar a tela para a versão MDI
// ACSJ - 01/05/2004      
   AAdd(aButtons, {"EDIT", {|| ((FilAtu:="*"),IF(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos)))}, "Imprimir"}) //14/07/2017 - identidade visual
   IF lPadrao
      DEFINE MSDIALOG oDlgBrow TITLE cTitulo ;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
               TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
   


   oMark := MsSelect():New("TRB",,,aCamposTRB,.T.,"XX",{34,1,(oDlgBrow:nHeight-30)/2,(oDlgBrow:nClientWidth-4)/2})
   
   //@ 00,00 MsPanel oPanelBrow Prompt "" SIZE 20,40 of oDlgBrow 
   //DEFINE SBUTTON FROM 10,(oDlgBrow:nClientWidth-4)/2-30 TYPE 6 ACTION ((FilAtu:="*"),IF(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos)) ) ENABLE OF oPanelBrow //JWJ - Testar se é R4. SIM: Chama PrintDialog() //14/07/2017 - retirado: identidade visual
   
   oDlgBrow:lMaximized := .T.
   
   //oPanelBrow:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   

   ACTIVATE MSDIALOG oDlgBrow ON INIT ((EnchoiceBar(oDlgBrow,{||oDlgBrow:End()},;
                                                             {||nOpcao:=0,oDlgBrow:End()},,aButtons))) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ELSE
      IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"TELACUSTO"),)//igorchiba  01/07/2010 nova tela customizada
   ENDIF
   
   IF nOpcao == 0
      EXIT
   ENDIF
ENDDO

E_RESET_AREA

RETURN NIL

*------------------------------------------------------------------------------------------------------*
 FUNCTION IP150CabRel(_Logist,MFlag,_ColPo,_ColItem,_ColDesc,_Col1,_Col2,_MTamItem,_MTamPo,_MTamDesc,MTexto2)
*------------------------------------------------------------------------------------------------------*
LOCAL _MLarg    := 231, _NomeCC
LOCAL _LIT_CC   := AVSX3("W0__CC",5)


MPag += 1 ; MLin := 1

IF _Logist
   _MLarg := _Col1 + 231
ENDIF

MLin ++

IF MFlag = "1"
   IF TIndice = 1
      @ MLin,01 SAY _LIT_CC + "..: "+MQuebra+" - "+BuscaCCusto(MQuebra)
   ELSEIF TIndice = 3 .AND. TArquivo = 4
      @ MLin,01 SAY STR0023+MQuebra+" - "+BuscaDesp(MQuebra) //"Despachante......: "
   ELSEIF TIndice = 3 .AND. TArquivo = 5
      @ MLin,01 SAY STR0024+MQuebra+" - "+BuscaFabr_Forn(MQuebra) //"Fornecedor.......: "
   ENDIF

   MLin ++
   IF ! _Logist
      _NomeCC := SPACE((15-LEN(_LIT_CC))/2) + _LIT_CC + SPACE((15-LEN(_LIT_CC))/2)
      _NomeCC += SPACE( 15 - LEN(_NomeCC) )

      @MLin,_Col1     SAY STR0025 //"                                                                           S.I.          Data     Data    Data da                                    Entrega            "
      MLin ++
      @MLin,_Col1     SAY STR0026 + _NomeCC +  STR0027 //"                              P/N          Quantidade   Valor FOB      "###"  Recbto.   Preco   Necessi- Status                            Prevista           "
      @ MLin,_ColPo   SAY STR0028 //"P.O."
      Mlin ++
      @MLin,_ColItem  SAY STR0029 //"Codigo"
      @MLin,_ColDesc  SAY STR0030 //"Descricao"
      @MLin,_Col1     SAY STR0031+STR0032 //"Fornecedor                 Fornecedor       Pendente   Pendente U$$   Solic. Importacao   S.I.   Inc/Alt  dade SI                                    "###"     Comp Emb. "
      MLin ++

      @MLin,_ColPo    SAY REPLI("-", _MTamPo)
      @MLin,_ColItem  SAY REPLI("-", _MTamItem)
      @MLin,_ColDesc  SAY REPLI("-", _MTamDesc)
      @MLin,_Col1     SAY "--------------------- -------------------- ----------- -------------- ----------------- -------- -------- -------- --------------------------------- -------- ---- -----"

   ELSE
      MLin ++
      @MLin,_Col1    SAY  STR0033 //"Pos AB                   Item          MLFB                         Qtde          Data Cel Data BM  Dt.Desej Dt.Combi Res.Mat. Ruckstand U. Prazo  Pronto Sag C. Exped Prev.MXT M.Brasil Cliente Ext. PLI/REGISTRO  OBS"
      MLin ++
      @MLin,_Col1     SAY "--- -------------------- ------------- ---------------------------- ------------- -------- -------- -------- -------- -------- --------- --------- ---------- -------- -------- -------- ------------ ------------- "+;
      "--------------------"

   ENDIF
   MLin ++
ENDIF

//"                                                                           S.I.          Data     Data    Data da                                    Entrega            "
//"                              P/N          Quantidade   Valor FOB      Centro de Custo  Recbto.   Preco   Necessi- Status                            Prevista           "
//"Fornecedor                 Fornecedor       Pendente   Pendente U$$   Solic. Importacao   S.I.   Inc/Alt  dade SI                                    "+N_F+"  Comp Emb. "
//"--------------------- -------------------- ----------- -------------- ----------------- -------- -------- -------- --------------------------------- -------- ---- -----"
// 1                     23                   44          56             71                89       98       107      116                               150      159  164

//Pos Numero do AB         Codigo Item MLFB               Quantidade  Data BM  Data SC  Dt. Comb Prev.MXT U. Prazo Pronto
//  Ch.Exped Res.Mat. Ruckstand M.Brasil Cliente      P.G.I.       Saida DECEX"
//--- -------------------- ------------------------------ ----------- -------- -------- -------- -------- -------- -------- -------- -------- --------- -------- ------------ ------------ -----------"
//1   5                    26                             57          69       78       87       96       105      114      123      132      141       151      160          173           187

//"Pos AB                   Item          MLFB                            Qtde       Data Cel Data BM  Dt.Desej Dt.Combi Res.Mat. Ruckstand U. Prazo  Pronto Sag  C. Exped Prev.MXT M.Brasil Cliente Ext. P.G.I./G.I  OBS"   // CFE O.S.160/95
//"--- -------------------- ------------- ---------------------------- ------------- -------- -------- -------- -------- -------- --------- --------- ----------  -------- -------- -------- ------------ ----------- ----------"
// 1   5                    26            40                           69            83       92       101      110      119      128       138       148         160      169      178      187          200         212

//Qtde       Data Sel Data BM  Dt.Desej Dt. Comb Res.Mat. Ruckstand U. Prazo  Pronto Seg  C. Exped Prev.MXT M.Brasil Cliente Ext. P.G.I./GI   OBS"   // CFE O.S.160/95 (JONATO)
//--------- -------- -------- -------- -------- -------- --------- --------- ----------  -------- -------- -------- ------------ ----------- ----------"
//          12       21       30       39       48       57        67        77          89       98       106      116          129         141


RETURN

*---------------------*
FUNCTION SelecForn(PForn)
*---------------------*
Local lRet := .F.
/*Local Wind
WIND = 1
FOR WIND = 1 TO 1
    MInd = STRZERO(WInd,1,0)
    IF .NOT. EMPTY( TFornec&MIND )
       IF PForn = TFornec&MIND
          RETURN .T.
       ENDIF
    ENDIF
NEXT
*/
If PForn == TFornec1
   lRet := .T.
EndIf
RETURN lRet
*----------------------------------*
FUNCTION IP150TRACO(PTRACO)
*----------------------------------*
IF PTRACO
   @ MLin,01 SAY REPLICATE('-',231)
   Mlin++ ; RETURN
ENDIF


*----------------------------------------------------------------------------*
* O.B.S.       : AS FUNCOES ABAIXO SAO UTILIZADAS PELOS PROGRAMAS IP155 E
*                IP300 (GERADOR DE RELATORIOS), PORTANTO QUALQUER ALTERACAO
*                DEVE LEVAR EM CONSIDERACAO TAL FATO !
*----------------------------------------------------------------------------*
#COMMAND  TRSEEK   => DBSEEK(xFilial()+" 0        0.001",.T.)
#COMMAND  SKIPLOOP => DBSKIP() ; LOOP
*----------------------------------------------------------------------------*
* Programa     : IP150ROT.prg    Manutencao em Dbedit  -  New Edition 5.0
* Autor        : Robson Luiz S. Dias
* Data Criacao : 14:23 Nov 19,1993
* Finalidade   : PROCEDURES DO IP150.PRG
*
*----------------------------------------------------------------------------*

*---------------------*
 FUNCTION IP150_Status
*---------------------*

MImpCab = .F.
IF MLin > 40

   DBSELECTAREA("Work")
   IP150CabRel(.F.,"2")

   @ MLin,20 SAY REPLI('-',96)
   MLin += 1
   @ MLin,64 SAY STR0034 //"S T A T U S"
   MLin += 1
   @ MLin,20 SAY REPLI('-',96)
   MLin += 2
   MImpCab = .T.
ENDIF

IF .NOT. MImpCab
   @ MLin,20 SAY REPLI('-',96)
   MLin += 1
   @ MLin,64 SAY STR0034 //"S T A T U S"
   MLin += 1
   @ MLin,20 SAY REPLI('-',96)
   MLin += 2
ENDIF

@ MLin,20 SAY STR0035 //"SI EM NEGOCIACAO       - AGUARDANDO COTACAO OU PROFORMA PARA FECHAMENTO DO PEDIDO."
MLin += 2

MLin += 2

@ MLin,20 SAY STR0037 //"PROCESSO EM ANUENCIA   - AGUARDANDO APROVACAO DA LI PELO ORGAO ANUENTE"
MLin += 2

@ MLin,20 SAY STR0038 //"PO AGUARDANDO EMBARQUE - EMBARQUE NAO VENCIDO."
MLin += 2

@ MLin,20 SAY STR0039 //"PO NAO EMBARCADO       - MATERIAL NAO EMBARCADO/FU COM FORNECEDOR."
MLin += 2

@ MLin,20 SAY STR0040 //"EMBARQUE CONFIRMADO    - FORNECEDOR CONFIRMOU DATA DE EMBARQUE/FU."
MLin += 2

@ MLin,20 SAY STR0041 //"EM TRANSITO            - FORNECEDOR INFORMOU LIBERACAO DO MATERIAL PARA EMBARQUE / EM TRANSITO."
MLin += 2

@ MLin,20 SAY STR0042 //"ATRACADO EM            - MATERIAL JA DESCARREGADO NO AEROPORTO/PORTO DE DESCARGA"
MLin += 2

@ MLin,20 SAY STR0043 //"AG. PAGTO IMPOSTOS     - MATERIAL ESTA NA ALFANDEGA / PROVIDENCIANDO PAGTO IMPOSTOS."
MLin += 2

@ MLin,20 SAY STR0044 //"PROCESSO ENTREPOSTADO  - MATERIAL ESTA NO ENTREPOSTO"
MLin += 2

@ MLin,20 SAY STR0045 //"AG. NACIONALIZACAO     - MATERIAL ESTA LIBERADO PARA DESEMBARACO / NACIONALIZACAO"
MLin += 2

@ MLin,20 SAY STR0046 //"AG. DESEMBARACO        - IMPOSTOS JA FORAM PAGOS - AGUARDANDO RECEITA FEDERAL / FISCAL LIBERAR."
MLin += 2

@ MLin,20 SAY STR0047 //"ENTREGUE               - MATERIAL JA ENTREGUE NA "
MLin += 2

@ MLin,20 SAY STR0048 //"AG. PAGTO. ANTECIPADO  - PROCESSO AGUARDANDO PAGAMENTO ANTECIPADO"
MLin += 2

@ MLin,20 SAY STR0049 //"AG. DEF. REQUISITANTE  - AGUARDANDO DEFINICAO DO REQUISITANTE"
MLin += 2

EJECT

RETURN ""
*---------------------*
FUNCTION CheckCliente
*---------------------*
DO WHILE .T.

   IF LASTKEY() = 27
      MSai2 = .T.
      EXIT
   ENDIF

   IF !EMPTY(TCliente)
      IF ! SA1->(DBSEEK(xFilial()+TCliente))
         Help("",1,"AVG0001040") //"CLIENTE NÇO CADASTRADO"###"Informa‡Æo"
         LOOP
      ENDIF
   ENDIF
   EXIT
ENDDO

RETURN ""

*-----------------*
FUNCTION CheckCusto
*-----------------*

DO WHILE .T.

   IF LASTKEY() = 27
      MSai2 = .T.
      EXIT
   ENDIF

   IF !EMPTY(TCCusto)
      IF !SY3->(DBSEEK(xFilial()+TCCusto))
         Help("",1,"AVG0001041") //"Centro de Custo NÇO CADASTRADO"###"Informa‡Æo"
         LOOP
      ENDIF
   ENDIF

   EXIT
ENDDO

RETURN ""

*----------------------*
FUNCTION CheckComprador
*----------------------*

DO WHILE .T.
   IF LASTKEY() = 27
      MSai2 = .T.
      EXIT
   ENDIF

   IF !EMPTY(TComprador)
      IF ! SY1->(DBSEEK(xFilial()+TComprador))
         Help("",1,"AVG0001042") // "COMPRADOR NÇO CADASTRADO"###"Informa‡Æo"
         LOOP
      ENDIF
   ENDIF
   EXIT
ENDDO

RETURN ""

*------------------------*
FUNCTION CheckDespachante
*------------------------*
DO WHILE .T.
   IF LASTKEY() = 27
      MSai2 = .T.
      EXIT
   ENDIF

   IF .NOT. EMPTY(TDespachante)
      DBSELECTAREA("SY5")
      IF ! DBSEEK(xFilial()+TDespachante)
         Help("",1,"AVG0001043") //"DESPACHANTE NÇO CADASTRADO - REENTRE"###"Informa‡Æo"
         LOOP
      ENDIF
   ENDIF
   EXIT
ENDDO

RETURN ""


*---------------------*
FUNCTION DbuIP150    && Controle da Manutencao em DBedit() By MarcioSoft Corp. 07.1990
*---------------------*

PRIVATE Modo,Local, MOldColor
PARAMETER Modo,Local

IF Modo < 4
   Retorno = 1
ENDIF

//Retorno = ControlDbNew( MPFS, MDescPF, MProcPFS, MCodPFS )  // Nopado para Compilar em Windows

IF Retorno = 0 .AND. .NOT. MSai
   //OSSME-5564 RNLP REMOÇÃO DE FUNÇÕES NAO UTILIZADAS RELEASE MMain, MSai
   Retorno = 1
ENDIF

RETURN Retorno

*-------------------*
FUNCTION IP150_Total
*-------------------*
Local Wind
@ MLin,01 SAY CHR(27) + "W" + CHR(01) + CHR(15)

MLin += 2

@ MLin,20 SAY STR0054 //'STATUS'
@ MLin,66 SAY STR0055 //'TOTAL EM US$'
MLin += 2

MTotal_Usd = 0
FOR Wind = 1 TO 21
    IF T_TabUsd[Wind] <> 0
       @ MLin,20 SAY T_TabObs[Wind]
       @ MLin,60 SAY T_TabUsd[Wind]   PICTURE '@E 999,999,999,999.99'
       MTotal_Usd += T_TabUsd[Wind]
       MLin += 1
    ENDIF
NEXT

@ MLin,60 SAY REPLI('-',18)
MLin += 1
@ MLin,60 SAY TRANS(MTotal_USD,'@E 999,999,999,999.99')

MLin += 1
@ MLin,01 SAY CHR(27) + "W" + CHR(00) + CHR(15)

RETURN ""

*----------------------------*
FUNCTION Grava_IS000(PBlock)
*----------------------------*
LOCAL b_condition :={||IF(TIndice==1.AND.!EMPTY(TCCusto),IF(TArquivo<>GERAL,W1_CC==TCCusto,W1_CC<=TCCustoF),W1_CC<="zzzzz")}
LOCAL cPoint:="EICIS01E"
LOCAL lPoint:=EasyEntryPoint(cPoint),nTotal:=SW1->(Easyreccount("SW1"))
//LOCAL cNumProc := SPACE(LEN(SW7->W7_HAWB)) - AAF 28/12/2016 - Retirada variavel nao utilizada.
LOCAL nX:= 0 //TDF - 21/07/11
Local i := 0 //GFP - 25/10/2012
lExisteRD:=EasyEntryPoint("ICPAD150")//Por causa do gerador de relatorios
DBSELECTAREA("SW1")

For i := 1 To Len(aFilSel)  // GFP - 25/10/2012 - Exibir registros das filiais selecionadas.
   IF TIndice = 1 .AND. .NOT. EMPTY(TCCusto)
      SW1->(DBSETORDER(1))
      SW1->(DBSEEK(/*xFilial()*//*aFilSel[i]*/If(IP150Modo("SW1"),xFilial("SW1"),aFilSel[i])+IF(TArquivo<>GERAL,TCCusto,TCCustoI)),.T.)    // GFP - 25/10/2012  //RCR - 19/03/2013
   
   ELSE
      DBSETORDER(4)
      TRSEEK   && DIRETIVA
   ENDIF

   IF !lEmail
      ProcRegua(SW1->(Easyreccount("SW1")))
   ENDIF


   DO WHILE .NOT. EOF() .AND. EVAL(b_Condition) .AND. SW1->W1_FILIAL == If(IP150Modo("SW1"),xFilial("SW1"),aFilSel[i])//aFilSel[i] //xFilial("SW1")  // GFP - 30/10/2012 RCR - 19/03/2013
      nCont+=1
      IF !lEmail
         IncProc(STR0056+STR(nCont)+" / "+ALLTRIM(STR(nTotal))) //'Lendo SI Reg.: '
      ENDIF   
      SysRefresh()
      MQtde := SW1->W1_SALDO_Q
      MValor:= SW1->W1_PRECO * SW1->W1_SALDO_Q    //TRP-06/05/08
      TObs = SPACE(33)

      IF TIndice = 1 .AND. .NOT. EMPTY(TCCusto)

         IF W1_SEQ <> 0
            SKIPLOOP
         ENDIF

         IF W1_SALDO_Q <= 0
            SKIPLOOP
         ENDIF
      ELSE
         IF W1_SEQ <> 0 .OR. W1_SALDO_Q = 0
            EXIT
         ENDIF
      ENDIF

      IF ! IP150_SelPO(W1_PO_NUM)
         SKIPLOOP
      ENDIF

      SW2->(DBSEEK(/*xFilial()aFilSel[i]*/If(IP150Modo("SW2"),xFilial("SW2"),aFilSel[i])+SW1->W1_PO_NUM))  // GFP - 25/10/2012 RCR - 19/03/2013

      IF (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE)) .OR. TIndice = 4
         IF !EMPTY(TCliente)
            IF SW2->W2_CLIENTE # TCliente
               DBSELECTAREA("SW1")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      IF !SB1->(DBSEEK(/*xFilial()*/If(IP150Modo("SB1"),xFilial("SB1"),aFilSel[i])+SW1->W1_COD_I))// GFP - 24/01/2013
         DBSELECTAREA("SW1")
         SKIPLOOP
      ENDIF
      SA5->(DBSETORDER(3))
      //IF ! SA5->(DBSEEK(xFilial()+SW1->W1_COD_I + SW1->W1_FABR + SW1->W1_FORN))
      IF !EICSFabFor(If(IP150Modo("SA5"),xFilial("SA5"),aFilSel[i])+SW1->W1_COD_I + SW1->W1_FABR + SW1->W1_FORN, EICRetLoja("SW1", "W1_FABLOJ"), EICRetLoja("SW1", "W1_FORLOJ")) // GFP - 24/01/2013
         TPart_N = SPACE(20)
      ELSE
         TPart_N = SA5->A5_CODPRF
      ENDIF

      IF ! SW0->(DBSEEK(/*xFilial()aFilSel[i]*/If(IP150Modo("SW0"),xFilial("SW0"),aFilSel[i])+SW1->W1_CC+SW1->W1_SI_NUM))  // GFP - 25/10/2012 RCR - 19/03/2013
         DBSELECTAREA("SW1")
         SKIPLOOP
      ENDIF
      IF TIndice = 2
         IF .NOT. EMPTY(TComprador)
            IF SW0->W0_COMPRA <> TComprador
               DBSELECTAREA("SW1")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      IF TArquivo = GERAL
         IF TIndice = 3 .AND. MTemForn
            IF ! SelecForn(SW1->W1_FORN)
               DBSELECTAREA("SW1")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      IF !EMPTY(SW2->W2_DT_ALTE)
         MDt_IncAlt = SW2->W2_DT_ALTE
      ELSE
         MDt_IncAlt = SW2->W2_PO_DT
      ENDIF   
   
      //IF SW1->W1_DTENTR_ > dDataBase   // > date()
         MWData := SW1->W1_DTENTR_
      //ELSE
         MWData2 := dDataBase+EasyGParam("MV_LT_COMP")+EasyGParam("MV_LT_LICE")+;
                          EasyGParam("MV_LT_DESE")
      //ENDIF

      TObs:=STR0057 //"EM NEGOCIACAO"

      IF lExisteRD
         IF ExecBlock("ICPAD150",.F.,.F.,"2") //AWR 08/06/1999
            DBSELECTAREA("SW1")
            SW1->(DBSKIP())
            LOOP
         ENDIF
      ENDIF

      IF PBlock # NIL
         EVAL(PBlock)
         DBSELECTAREA("SW1")
         DBSKIP()
         LOOP
      ENDIF

      If lPoint .And. !ExecBlock(cPoint)
         DBSELECTAREA("SW1")
         DBSKIP()
         LOOP
      ENDIF
      lLoop:=.F.
      IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"LOOPSI"),)//igorchiba 17/27/2010 validacao fase SI
      IF lLoop
         DBSELECTAREA("SW1")
         DBSKIP()
         LOOP
      ENDIF
   
      TRB->(DBAPPEND())   
      TRB->WKFILIAL := If(IP150Modo("SW1"),xFilial("SW1"),aFilSel[i])//aFilSel[i]//cFilAnt //SW1->W1_FILIAL //JWJ 26/05/2006  // GFP - 25/10/2012 RCR - 19/03/2013
      DO CASE
         CASE TIndice == C_CUSTO  .OR. TIndice == COMPRADOR  .OR. TArquivo == GERAL_PO
              TRB->W1_CC     := SW1->W1_CC
              TRB->W1_SI_NUM := SW1->W1_SI_NUM
              TRB->W1_PO_NUM := SW1->W1_PO_NUM
              TRB->W6_DESP   := SPACE(03)
              TRB->W1_FORN   := SW1->W1_FORN
              TRB->A2_NREDUZ := BuscaFabr_Forn(W1_FORN+EICRetLoja("SW1","W1_FORLOJ"))
              TRB->W0_COMPRA := SW0->W0_COMPRA
              TRB->W2_CLIENTE:= SW2->W2_CLIENTE
              //TRB->W3_PGI_NUM := SW3->W3_PGI_NUM // JBS - 16/09/2003
              //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
              If EICLoja()
                 TRB->W1_FORLOJ := SW1->W1_FORLOJ 
                 TRB->W2_CLILOJ := SW2->W2_CLILOJ
              EndIf
           
         CASE (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE .OR. TArquivo = 4 .OR. TArquivo == GERAL )) .OR. TIndice = DESEMB_PENDENTE .or. TIndice = 5//ACB 26/08/2010 - Melhoria filtro por fornecedor
              TRB->W2_CLIENTE := SW2->W2_CLIENTE
              TRB->W1_PO_NUM  := SW1->W1_PO_NUM
              TRB->W0_COMPRA  := SW0->W0_COMPRA
              TRB->W1_FORN    := SW1->W1_FORN
              TRB->A2_NREDUZ  := BuscaFabr_Forn(SW1->W1_FORN+EICRetLoja("SW1","W1_FORLOJ"))
              TRB->W1_CC      := SW1->W1_CC
              TRB->W1_SI_NUM  := SW1->W1_SI_NUM
              TRB->W6_DESP    := SPACE(3)
              //TRB->W3_PGI_NUM := SW3->W3_PGI_NUM // JBS - 16/09/2003
              //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
              If EICLoja()
                 TRB->W1_FORLOJ := SW1->W1_FORLOJ
                 TRB->W2_CLILOJ := SW2->W2_CLILOJ
              EndIf

      ENDCASE 
      //**** TDF - 21/07/11
      cDescTemp :=MSMM(SB1->B1_DESC_P,nTamDesc)
      nLinDesc  :=MlCount(cDescTemp,nTamDesc)
      cDescItem :=""
   
      For nX:=1 To nLinDesc
         cDescItem += AllTrim(StrTran(Memoline(cDescTemp,nTamDesc,nX), ENTER,""))
         cDescItem += " "
      Next
      //****
         
      TRB->W1_COD_I   := SW1->W1_COD_I
      TRB->W1_REG     := SW1->W1_REG
      TRB->W1_SEQ     := SW1->W1_SEQ
      TRB->B1_DESC    := cDescItem //TDF - 21/07/11
      TRB->A5_CODPRF  := TPart_N
      TRB->W1_QTDE    := MQtde
      TRB->W3_PRECO   := ConvValSI(SW0->W0_MOEDA,SW1->W1_PRECO)    //TRP-06/05/08
      TRB->WKVALOR    := ConvValSI(SW0->W0_MOEDA,MValor)    //TRP-06/05/08
      TRB->W0__DT     := SW0->W0__DT
      TRB->W2_DT_ALTE := MDt_IncAlt
      TRB->W1_DTENTR_ := SW1->W1_DTENTR_
      TRB->W3_DT_ENTR := MWData
      //DFS - 18/08/10 - Adicionado campo para Previsão de Entrega Calculada
      TRB->WK_DT_PREC := MWData2
      TRB->WKOBS      := TObs
      TRB->WK_DTEMB   := SW1->W1_DT_EMB
      TRB->YQ_DESCR   := IF( ! SYQ->(DBSEEK(/*xFilial()*/If(IP150Modo("SYQ"),xFilial("SYQ"),aFilSel[i])+SW2->W2_TIPO_EMB)),SPACE(5),SUBSTR(SYQ->YQ_DESCR,1,5))// GFP - 24/01/2013

      T_TabUsd[01] += TRB->WKVALOR

      IF(lExisteRD,ExecBlock("ICPAD150",.F.,.F.,"3"),) //AWR 08/06/1999
      IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"GRVSI"),)//igorchiba 17/27/2010  gravacao fase SI
      DBSELECTAREA("SW1")
      DBSKIP()
   ENDDO
Next i // GFP - 25/10/2012

RETURN ""

*----------------------------*
FUNCTION Grava_IP000(PBlock)
*----------------------------*
LOCAL b_condition :={||IF(TIndice==1.AND.!EMPTY(TCCusto),IF(TArquivo<>GERAL,W3_CC==TCCusto,W3_CC<=TCCustoF),.T.)}
LOCAL cPoint:="EICIP01E"
LOCAL lPoint:=EasyEntryPoint(cPoint)
LOCAL lDiNac:=.F.
LOCAL nX:= 0//TDF - 21/07/11
LOCAL cNumProc := SPACE(LEN(SW7->W7_HAWB))
//LOCAL cUnid
LOCAL nSaldoPro:= 0
Local i := 0 //GFP - 18/12/2012

lExisteRD:=EasyEntryPoint("ICPAD150")//Por causa do gerador de relatorios

DBSELECTAREA("SW3")
For i := 1 To Len(aFilSel)  // GFP - 18/12/2012 - Buscar registro das filiais selecionadas.
   IF TIndice = 1 .AND. .NOT. EMPTY(TCCusto)
      DBSETORDER(4)
      DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW3"),xFilial("SW3"),aFilSel[i])+IF(TArquivo<>GERAL,TCCusto,TCCustoI),.T.)  // GFP - 18/12/2012 RCR - 19/03/2013
   ELSE
      DBSETORDER(6)
      TRSEEK   && DIRETIVA
   ENDIF

   W_Pont = 0

   IF !lEmail
      ProcRegua(SW3->(Easyreccount("SW3")))
   ENDIF   

   DO WHILE .NOT. EOF() .AND. EVAL(b_Condition) .AND. W3_FILIAL == If(IP150Modo("SW3"),xFilial("SW3"),aFilSel[i]) //aFilSel[i] //xFilial("SW3")  // GFP - 24/01/2013 RCR - 19/03/2013
      nCont+=1
   
      IF !lEmail
         IncProc(STR0058+STR(nCont)+" / "+ALLTRIM(STR(SW3->(Easyreccount("SW3"))))) //'Lendo PO Reg.: '
      ENDIF
      
      MQtde :=SW3->W3_SALDO_Q

      IF TIndice = 1 .AND. .NOT. EMPTY(TCCusto)

         IF W3_SEQ <> 0

            SKIPLOOP
         ENDIF

         IF W3_SALDO_Q <= 0
            SKIPLOOP
         ENDIF
      ELSE
         IF W3_SEQ <> 0 .OR. W3_SALDO_Q = 0
            EXIT
         ENDIF
      ENDIF

      IF ! IP150_SelPO(W3_PO_NUM)
         SKIPLOOP
      ENDIF
            
      DBSELECTAREA("SW2")
      IF ! SW2->(DBSEEK(/*xFilial()aFilSel[i]*/If(IP150Modo("SW2"),xFilial("SW2"),aFilSel[i])+SW3->W3_PO_NUM))  // GFP - 18/12/2012 RCR - 19/03/2013
         DBSELECTAREA("SW3")
         SKIPLOOP
      ENDIF

      If(!Empty(SW2->W2_HAWB_DA),lDINac:=.T.,lDiNac:=.F.)

      IF (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE)) .OR. TIndice = 4
         IF !EMPTY(TCliente)
            IF SW2->W2_CLIENTE # TCliente
               DBSELECTAREA("SW3")
               SKIPLOOP
            ENDIF
         ENDIF
      
         //ACB 26/08/2010 - Melhoria filtro por fornecedor
         IF !EMPTY(TFornec1)
            IF !SelecForn(SW2->W2_FORN)
               DBSELECTAREA("SW3")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      TObs = SPACE(33)
      W_Pont = 0
   
      //TRP-15/08/08
      IF lNewProforma
         //cUnid:= BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM)
         IF (nSaldoPro := PO570SLDPRO(SW3->(W3_PO_NUM+W3_POSICAO), SW3->W3_QTDE)) == 0
            TObs := STR0059 //"CONFECCAO P.L.I."
         ELSEIF (SW3->W3_QTDE - nSaldoPro) == 0       // CCM - 03/06/09 - Caso Qnde Zerada.
            TObs := STR0122 //"AGUARDANDO PROFORMA" 
         ELSE
            TObs   := "Saldo:" + ALLTRIM(STR(nSaldoPro)) + Space(1) /*+ "U.M:" + cUnid + Space(2)*/ + STR0122 + "/"   //"AGUARDANDO PROFORMA" 
            TObs   += "Qtde:"  + ALLTRIM(STR((SW3->W3_QTDE - nSaldoPro)))  + Space(1) /*+ "U.M:" + cUnid + Space(2)*/ + STR0059 //"CONFECCAO P.L.I."
         ENDIF
      ELSE
         IF EMPTY(SW2->W2_DT_PRO) 
            TObs := STR0122 //"AGUARDANDO PROFORMA" 
         ELSE
            TObs := STR0059 //"CONFECCAO P.L.I."
         ENDIF
      ENDIF
   
      W_Pont = 3
      IF TIndice = 2
         IF .NOT. EMPTY(TComprador)
            IF W2_COMPRA <> TComprador
               DBSELECTAREA("SW3")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      IF TArquivo = GERAL
         IF TIndice = 3 .AND. MTemForn
            IF ! SelecForn(SW3->W3_FORN)
               DBSELECTAREA("SW3")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      DBSELECTAREA("SB1")
      IF ! DBSEEK(/*xFilial()*/If(IP150Modo("SB1"),xFilial("SB1"),aFilSel[i])+SW3->W3_COD_I)  // GFP - 24/01/2013
         DBSELECTAREA("SW3")
         SKIPLOOP
      ENDIF

      DBSELECTAREA("SA5")
      SA5->(DBSETORDER(3))
      //IF ! SA5->(DBSEEK(xFilial()+SW3->W3_COD_I + SW3->W3_FABR + SW3->W3_FORN))
      IF !EICSFabFor(/*xFilial("SA5")*/If(IP150Modo("SA5"),xFilial("SA5"),aFilSel[i])+SW3->W3_COD_I + SW3->W3_FABR + SW3->W3_FORN, EICRetLoja("SW3", "W3_FABLOJ"), EICRetLoja("SW3", "W3_FORLOJ"))  // GFP - 24/01/2013
         DBSELECTAREA("SW3")
         SKIPLOOP
      ENDIF

      DBSELECTAREA("SW0")
      IF ! DBSEEK(/*xFilial()aFilSel[i]*/If(IP150Modo("SW0"),xFilial("SW0"),aFilSel[i])+SW3->W3_CC+SW3->W3_SI_NUM)  // GFP - 18/12/2012 RCR - 19/03/2013
         DBSELECTAREA("SW3")
         SKIPLOOP
      ENDIF

      DBSELECTAREA("SW1")
      IF ! PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,;
                          SW3->W3_COD_I,SW3->W3_REG,0,If(IP150Modo("SW1"),xFilial("SW1"),aFilSel[i]))   // GFP - 20/02/2013
         DBSELECTAREA("SW3")
         SKIPLOOP
      ENDIF

      IF .NOT. EMPTY(SW2->W2_DT_ALTE)
         MDt_IncAlt = SW2->W2_DT_ALTE
      ELSE
         MDt_IncAlt = SW2->W2_PO_DT
      ENDIF
      //
      //  JBS - 17/09/2003  - Calculo da Data de Entrega
      //
      //IF !empty(SW3->W3_DT_ENTR)// > dDataBase
         MWData := SW3->W3_DT_ENTR
   //   ELSE
         SYR->(DBSETORDER(1))                                                 
         SYR->(DBSEEK(/*xFilial()*/If(IP150Modo("SYR"),xFilial("SYR"),aFilSel[i])+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))   // GFP - 24/01/2013
         SY9->(dbSetOrder(2))
         MWData2 := dDataBase + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(/*xFilial()*/If(IP150Modo("SY9"),xFilial("SY9"),aFilSel[i])+SW2->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))  // GFP - 24/01/2013
         SY9->(dbSetOrder(1))
     // ENDIF
      //  Fim  - JBS
	  
	  cNumProc := SPACE(LEN(SW7->W7_HAWB)) //AAF 28/12/2016 - Limpa a variavel
      If lDINac    
         SW6->(DBSETORDER(1))
         SW6->(DBSEEK(/*xFILIAL("SW6")aFilSel[i]*/If(IP150Modo("SW6"),xFilial("SW6"),aFilSel[i])+SW2->W2_HAWB_DA))  // GFP - 18/12/2012 RCR - 19/03/2013
         cNumProc := SW6->W6_HAWB
         If SW2->W2_VENCDA < dDataBase
            TObs := STR0115  // "DI NACIONALIZACAO VENCIDA"
            W_Pont = 3
         Else
   //       TObs := STR0116 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0117  // "VENCERA EM " ### " DIAS A DI NAC."
            TObs := STR0121+DTOC(SW6->W6_DT_DTA)+ STR0116 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0117  // "ENTREP."### DA VENCE:" ### " DIAS "
            W_Pont = 3
         EndIf
      EndIf

      IF lExisteRD
         IF ExecBlock("ICPAD150",.F.,.F.,"4") //AWR 08/06/1999
            DBSELECTAREA("SW3")
            SW3->(DBSKIP())
            LOOP
         ENDIF
      ENDIF

      IF PBlock # NIL
         EVAL(PBlock)
         DBSELECTAREA("SW3")
         DBSKIP()
         LOOP
      ENDIF

      If lPoint .And. !ExecBlock(cPoint)
         DBSELECTAREA("SW3")
         DBSKIP()
         LOOP
      ENDIF                                                        
   
      lLoop:=.F.
      IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"LOOPPO"),)//igorchiba 17/27/2010 validacao PO 
      IF lLoop
         DBSELECTAREA("SW3")
         DBSKIP()
         LOOP
      ENDIF

      DBSELECTAREA("TRB")
      DBAPPEND()
      TRB->WKFILIAL := If(IP150Modo("SW3"),xFilial("SW3"),aFilSel[i])//aFilSel[i] //cFilAnt //SW3->W3_FILIAL //JWJ 26/05/2006  // GFP - 19/12/2012 RCR - 19/03/2013
      DO CASE
         CASE TIndice == COMPRADOR   .OR. TIndice == C_CUSTO   .OR. TArquivo == GERAL_PO
              TRB->W0_COMPRA  := SW2->W2_COMPRA
              TRB->W1_PO_NUM  := SW3->W3_PO_NUM
              TRB->W1_FORN    := SW3->W3_FORN
              TRB->A2_NREDUZ  := BuscaFabr_Forn(SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ"))
              TRB->W1_CC      := SW3->W3_CC
              TRB->W1_SI_NUM  := SW3->W3_SI_NUM
              TRB->W6_DESP    := SPACE(3)
              TRB->W2_CLIENTE := SW2->W2_CLIENTE
              TRB->W3_PGI_NUM := SW3->W3_PGI_NUM // JBS - 16/09/2003
              //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
              TRB->W6_HAWB    := cNumProc
              If EICLoja()
                 TRB->W1_FORLOJ := SW3->W3_FORLOJ
                 TRB->W2_CLILOJ := SW2->W2_CLILOJ
              EndIf
      
         CASE (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE .OR. TArquivo = DESEMB_PENDENTE .OR. TArquivo == GERAL)) .OR. TIndice = 4
              TRB->W2_CLIENTE := SW2->W2_CLIENTE
              TRB->W1_PO_NUM  := SW3->W3_PO_NUM
              TRB->W0_COMPRA  := SW2->W2_COMPRA
              TRB->W1_FORN    := SW3->W3_FORN
              TRB->A2_NREDUZ  := BuscaFabr_Forn(SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ"))
              TRB->W1_CC      := SW3->W3_CC
              TRB->W1_SI_NUM  := SW3->W3_SI_NUM
              TRB->W3_PGI_NUM := SW3->W3_PGI_NUM // JBS - 16/09/2003
              TRB->W6_DESP    := SPACE(3)
              //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
              TRB->W6_HAWB    := cNumProc 
              If EICLoja()
                 TRB->W1_FORLOJ := SW3->W3_FORLOJ
                 TRB->W2_CLILOJ := SW2->W2_CLILOJ              
              EndIf         

      ENDCASE
      //**** TDF - 21/07/11
      cDescTemp :=MSMM(SB1->B1_DESC_P,nTamDesc)
      nLinDesc  :=MlCount(cDescTemp,nTamDesc)
      cDescItem :=""
   
      For nX:=1 To nLinDesc
         cDescItem += AllTrim(StrTran(Memoline(cDescTemp,nTamDesc,nX), ENTER,""))
         cDescItem += " "
      Next 
      //****
   
      TRB->W1_COD_I   := SW3->W3_COD_I
      TRB->W1_REG     := SW1->W1_REG
      TRB->W1_SEQ     := SW1->W1_SEQ
      TRB->B1_DESC    := cDescItem//TDF - 21/07/11
    //TRB->A5_CODPRF  := SA5->A5_CODPRF
      TRB->W1_QTDE    := MQtde
      TRB->W3_PRECO   := CalcFob_Us(SW3->W3_PRECO,,,AvSX3("W3_PRECO",4))
      TRB->WKVALOR    := CalcFob_Us(SW3->W3_PRECO,SW3->W3_SALDO_Q)
      TRB->W3_POSICAO := SW3->W3_POSICAO
      TRB->W0__DT     := SW0->W0__DT
      TRB->W2_DT_ALTE := MDt_IncAlt
      TRB->WKOBS      := TObs
      TRB->W1_DTENTR_ := SW1->W1_DTENTR_
      TRB->W3_DT_ENTR := MWData
      //DFS - 18/08/10 - Adicionado campo para Previsão de Entrega Calculada
      TRB->WK_DT_PREC := MWData2
      TRB->WK_DTEMB   := SW3->W3_DT_EMB 
   
      If SW3->(FieldPos("W3_PART_N")) # 0 .And. !Empty(SW3->W3_PART_N) //ASK 08/10/2007
         TRB->A5_CODPRF  := SW3->W3_PART_N
      Else
         TRB->A5_CODPRF  := SA5->A5_CODPRF                                    
      EndIf
   
      IF W_Pont <> 0
         T_TabUsd[W_Pont] += TRB->WKVALOR
      ENDIF

      IF(lExisteRD,ExecBlock("ICPAD150",.F.,.F.,"5"),) //AWR 08/06/1999
      IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"GRVPO"),)//igorchiba 17/27/2010 gravar PO 
      DBSELECTAREA("SW3")
      DBSKIP()
   ENDDO
Next i  // GFP - 18/12/2012

RETURN ""

*----------------------------*
FUNCTION Grava_IG000(PBlock)
*----------------------------*
LOCAL b_condition :={||IF(TIndice==1.AND.!EMPTY(TCCusto),IF(TArquivo<>GERAL,SW5->W5_CC==TCCusto,SW5->W5_CC<=TCCustoF),SW5->W5_CC<="zzzzz")}
LOCAL cPoint:="EICIG01E"
LOCAL lPoint:=EasyEntryPoint(cPoint)
LOCAL lDINac := .F. 
LOCAL nX:= 0 //TDF - 21/07/11                 
LOCAL cNumProc := SPACE(LEN(SW7->W7_HAWB))
Local i := 0 //GFP - 18/12/2012
lExisteRD:=EasyEntryPoint("ICPAD150")//Por causa do gerador de relatorios

DBSELECTAREA("SW5")
For i := 1 To Len(aFilSel)  // GFP - 18/12/2012 - Buscar registro das filiais selecionadas.
   IF /*TIndice = 1 .AND.*/ .NOT. EMPTY(TCCusto)  // GFP - 18/12/2012
      DBSETORDER(4)                                                                                        //MFR 29/09/2020 OSSME-5175
      DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW5"),xFilial("SW5"),aFilSel[i])+IF(TArquivo<>GERAL,TCCusto,TCCustoI),.T.)  //GFP - 18/12/2012 RCR - 19/03/2013
   ELSE
      DBSETORDER(6)
      TRSEEK   && DIRETIVA
   ENDIF

   W_Pont = 0
   IF !lEmail
      ProcRegua(SW5->(Easyreccount("SW5")))
   ENDIF   

   DO WHILE .NOT. EOF() .AND. EVAL(b_Condition) .AND. SW5->W5_FILIAL == If(IP150Modo("SW5"),xFilial("SW5"),aFilSel[i])//aFilSel[i]//xFilial("SW5")  //GFP - 18/12/2012 RCR - 19/03/2013
      nCont+=1
   
      IF !lEmail
         IncProc(STR0060+STR(nCont)+" / "+ALLTRIM(STR(SW5->(Easyreccount("SW5"))))) //'Lendo LI Reg.: '
      ENDIF   
      MQtde := SW5->W5_SALDO_Q

      IF TIndice = 1 .AND. .NOT. EMPTY(TCCusto)

         IF SW5->W5_SEQ <> 0
            SKIPLOOP
         ENDIF

         IF SW5->W5_SALDO_Q <= 0  .OR. (SW5->W5_FLUXO == "1" .AND. TArquivo = PEDIDO_PENDENTE)   //TRP - 26/08/10 - Verificar anuencia do item para impressao do relatório de Pedidos Pendentes. 
            SKIPLOOP
         ENDIF
      ELSE
         IF SW5->W5_SEQ <> 0 .OR. SW5->W5_SALDO_Q == 0
            EXIT
         ENDIF
      ENDIF

      IF ! IP150_SelPO(SW5->W5_PO_NUM)
         SKIPLOOP
      ENDIF

      DBSELECTAREA("SW2")
      IF ! SW2->(DBSEEK( /*xFilial() aFilSel[i]*/If(IP150Modo("SW2"),xFilial("SW2"),aFilSel[i])+SW5->W5_PO_NUM ))  //GFP - 18/12/2012 RCR - 19/03/2013
         DBSELECTAREA("SW5")
         SKIPLOOP
      ENDIF
      If(!Empty(SW2->W2_HAWB_DA),lDINac:=.T.,lDiNac:=.F.)

      IF (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE)) .OR. TIndice = 4
         IF !EMPTY(TCliente)
            IF SW2->W2_CLIENTE # TCliente
               DBSELECTAREA("SW5")
               SKIPLOOP
             ENDIF
         ENDIF

         //ACB 26/08/2010 - Melhoria filtro por fornecedor
         IF !EMPTY(TFornec1)
            IF !SelecForn(SW2->W2_FORN)
               DBSELECTAREA("SW5")
               SKIPLOOP
            ENDIF
         ENDIF

      ENDIF

      IF TIndice = 2
         IF .NOT. EMPTY(TComprador)
            IF W2_COMPRA <> TComprador
               DBSELECTAREA("SW5")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      IF SW5->W5_FLUXO='1'
         SWP->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SWP"),xFilial("SWP"),aFilSel[i])+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI))  //GFP - 18/12/2012 RCR - 19/03/2013
      ENDIF

      DBSELECTAREA("SW4")
      DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW4"),xFilial("SW4"),aFilSel[i])+SW5->W5_PGI_NUM)  //GFP - 18/12/2012 RCR - 19/03/2013

      TObs = SPACE(33)
      W_Pont = 0

      IF !lDiNac
         TObs :=IF(EMPTY(SW5->W5_DT_SHIP),STR0061,; //"AG.EMBARQUE S/ SHIP.INSTRUCTIONS"
                       STR0062) //"AG. EMBARQUE"
      ENDIF

      W_Pont = 6
      IF SW5->W5_DT_EMB > dDataBase .AND. !lDiNac
         TObs := IF(EMPTY(SW5->W5_DT_SHIP),;
                    STR0063,; //"NAO EMBARCADO S/SHIP.INSTRUCTIONS"
                    STR0064) //"NAO EMBARCADO C/SHIP.INSTRUCTIONS"
         W_Pont = 9
      ELSE
         TObs :=IF(EMPTY(SW5->W5_DT_SHIP),STR0061,; //"AG.EMBARQUE S/ SHIP.INSTRUCTIONS"
                       STR0062) //"AG. EMBARQUE"
         W_Pont = 6
      ENDIF
   
      //If SB1->B1_ANUENTE == "1"
         IF .NOT. EMPTY( SW5->W5_DOCTO_F ) .AND. !lDiNac
            TObs = STR0065 + DTOC(SW5->W5_DT_EMB) //"EMBARQUE CONFIRMADO P/ "
            W_Pont = 7
            IF SW5->W5_DT_EMB > dDataBase
               TObs += IF(EMPTY(SW5->W5_DT_SHIP),;
                       STR0066,; //"NAO EMBARCADO - S/ SHIP.INSTRUCTIONS"
                       STR0067) //"NAO EMBARCADO - C/ SHIP.INSTRUCTIONS"
               W_Pont = 9
            ENDIF
         ENDIF
      //Else  //DFS - Tratamento para processos que não utilizam P.L.I
         //If SW5->W5_DT_EMB < dDataBase 
            //TObs = STR0065 + DTOC(SW5->W5_DT_EMB) //"EMBARQUE CONFIRMADO P/ "
         //Endif   
      //Endif
	  
	  cNumProc := SPACE(LEN(SW7->W7_HAWB)) //AAF 28/12/2016 - Limpa a variavel
      IF .NOT. EMPTY(SW5->W5_HAWB)
         DBSELECTAREA("SW6")
         DBSETORDER(1)
         DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW6"),xFilial("SW6"),aFilSel[i])+SW5->W5_HAWB)  //GFP - 18/12/2012 RCR - 19/03/2013
         cNumProc := SW6->W6_HAWB
         IF EMPTY(SW6->W6_CHEG)
            IF SW6->W6_DT_EMB >= dDataBase .AND. !lDiNac
               TObs = STR0065+DTOC(SW6->W6_DT_EMB) //"EMBARQUE CONFIRMADO P/ "
               W_Pont = 7
             ENDIF
          ENDIF
      ENDIF

      DBSELECTAREA("SW5")
      IF SW5->W5_DEF_REQ = 'S'
         TObs = STR0069 //'AG. DEFINICAO DO REQUISITANTE'
         W_Pont = 10
      ENDIF

      DBSELECTAREA("SW4")
      IF SW4->W4_SUFRAMA = "S"
         IF EMPTY(W4_DT_SUFR) && .AND. GIEMITIDA = "S"
            TObs = STR0070 //"AGUARDANDO ENVIO AO SUFRAMA"
            W_Pont = 18
         ENDIF
      ELSE
         IF W4_PORTASN # "S" .AND. W4_FLUXO # "7"
            IF W4_FLUXO # "4"
               IF SWP->(FOUND()) .AND. EMPTY(SWP->WP_MICRO)
                  TObs = "AGUARDANDO ENVIO AO ORIENTADOR"
                  W_Pont = 4
               ELSEIF SWP->(FOUND()) .AND. EMPTY(SWP->WP_TRANSM)
                      TObs = "AGUARDANDO ENVIO AO ORGAO ANUENTE"
                      W_Pont = 4
               ELSEIF SWP->(FOUND()) .AND. !EMPTY(SWP->WP_MICRO) .AND. !EMPTY(SWP->WP_REGIST)
                      TObs = STR0062 //"AG. EMBARQUE"
                      W_Pont = 4
               ELSEIF SWP->(FOUND()) .AND. !EMPTY(SWP->WP_MICRO) .AND. EMPTY(SWP->WP_REGIST)
                      TObs = "AGUARD. RETORNO DA L.I."
                      W_Pont = 4
               ELSEIF SWP->(FOUND()) .AND. EMPTY(SWP->WP_MICRO) .AND. !EMPTY(SWP->WP_REGIST)
                      TObs = STR0062 //"AG. EMBARQUE"
                      W_Pont = 4
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      IF SW4->W4_SUFRAMA = "S"
         IF ! EMPTY(SW4->W4_DT_SUFR)
            IF SW4->W4_PORTASN # "S" .AND. SW4->W4_FLUXO # "7"
               IF EMPTY(SW4->W4_DTEDCEX)
                  TObs = "PROC. NA SUFRAMA DESDE "+DTOC(SW4->W4_DT_SUFR)
                  W_Pont = 19
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      IF SW4->W4_PORTASN # "S" .AND. SW4->W4_FLUXO # "7"
         IF SWP->(FOUND()) .AND. ! EMPTY(SWP->WP_TRANSM) .AND. EMPTY(SWP->WP_VENCTO)
            TObs = "EM ANUENCIA DESDE "+DTOC(SWP->WP_TRANSM)
            W_Pont = 5
         ENDIF
      ENDIF

      If lDINac  
         SW6->(DBSETORDER(1))
         SW6->(DBSEEK(xFILIAL("SW6")+SW2->W2_HAWB_DA))  //GFP - 18/12/2012
         If SW2->W2_VENCDA < dDataBase
            TObs := STR0115  // "DI NACIONALIZACAO VENCIDA"
            W_Pont = 4
         Else
   //       TObs := STR0116 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0117  // "VENCERA EM " ### " DIAS A DI NAC."
            TObs := STR0121+DTOC(SW6->W6_DT_DTA)+ STR0116 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0117  // "ENTREP."### DA VENCE:" ### " DIAS "
            W_Pont = 4
         EndIf
      EndIf

	 IF SW5->W5_DT_EMB > dDataBase //LBL - 13/11/2013
  	    TObs := STR0124 //"EMBARQUE PENDENTE"    
     END IF       

      IF TArquivo = GERAL
         IF TIndice = 3 .AND. MTemForn
            IF ! SelecForn(SW5->W5_FORN)
               DBSELECTAREA("SW5")
               SKIPLOOP
            ENDIF
         ENDIF
      ENDIF

      DBSELECTAREA("SB1")
      IF ! DBSEEK(/*xFilial()*/If(IP150Modo("SB1"),xFilial("SB1"),aFilSel[i])+SW5->W5_COD_I)  //GFP - 24/01/2013
         DBSELECTAREA("SW5")
         SKIPLOOP
      ENDIF

      DBSELECTAREA("SA5")
      SA5->(DBSETORDER(3))
      //IF !SA5->(DBSEEK(xFilial()+SW5->W5_COD_I + SW5->W5_FABR + SW5->W5_FORN))
      IF !EICSFabFor(/*xFilial("SA5")*/If(IP150Modo("SA5"),xFilial("SA5"),aFilSel[i])+SW5->W5_COD_I + SW5->W5_FABR + SW5->W5_FORN, EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"))  //GFP - 24/01/2013
         DBSELECTAREA("SW5")
         SKIPLOOP
      ENDIF

      DBSELECTAREA("SW0")
      IF ! DBSEEK(/*xFilial()aFilSel[i]*/If(IP150Modo("SW0"),xFilial("SW0"),aFilSel[i])+SW5->W5_CC+SW5->W5_SI_NUM)  //GFP - 18/12/2012 RCR - 19/03/2013
         DBSELECTAREA("SW5")
         SKIPLOOP
      ENDIF

      DBSELECTAREA("SW1")
      IF ! PosO1_It_Solic(SW5->W5_CC,SW5->W5_SI_NUM,;
                          SW5->W5_COD_I,SW5->W5_REG,0,If(IP150Modo("SW1"),xFilial("SW1"),aFilSel[i]))  // GFP - 20/02/2013
         DBSELECTAREA("SW5")
         SKIPLOOP
      ENDIF

      IF .NOT. EMPTY(SW2->W2_DT_ALTE)
         MDt_IncAlt = SW2->W2_DT_ALTE
      ELSE
         MDt_IncAlt = SW2->W2_PO_DT
      ENDIF

      SW5->(PosO1_ItPedidos(SW5->W5_PO_NUM,SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_FABR,SW5->W5_FORN,;
                                 SW5->W5_REG,0,EICRetLoja("SW5", "W5_FABLOJ"), EICRetLoja("SW5", "W5_FORLOJ"),If(IP150Modo("SW3"),xFilial("SW3"),aFilSel[i])))  // GFP - 20/02/2013

      IF lExisteRD
         IF ExecBlock("ICPAD150",.F.,.F.,"6") //AWR 08/06/1999
            DBSELECTAREA("SW5")
            DBSKIP()
            LOOP
         ENDIF
      ENDIF

      IF PBlock # NIL
         EVAL(PBlock)
         DBSELECTAREA("SW5")
         DBSKIP()
         LOOP
      ENDIF

      If lPoint .And. !ExecBlock(cPoint)
         DBSELECTAREA("SW5")
         DBSKIP()
         LOOP
      ENDIF
   
      IF LEFT(ALLTRIM(SW5->W5_PGI_NUM),1) == "*" .AND. RIGHT(ALLTRIM(SW5->W5_PGI_NUM),1) == "*" .AND. TArquivo==LICENC_PENDENTE    // NCF - 18/05/09 - Condição para filtrar as LI's automáticas
         DBSELECTAREA("SW5")                                                                                                       //                  quando o relatório for de Licenças Pendentes
         DBSKIP()
         LOOP
      ENDIF
   
      lLoop:=.F.
      IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"LOOPGI"),)//igorchiba 17/27/2010 validacao PGI 
      IF lLoop
         DBSELECTAREA("SW5")
         DBSKIP()
         LOOP
      ENDIF
   
      //
      //  JBS - 17/09/2003  - Calculo da Data de Entrega
      //
      //IF !empty(SW5->W5_DT_ENTR)// > dDataBase
         MWData := SW5->W5_DT_ENTR
      //ELSE
         SYR->(DBSETORDER(1))                                                 
         SYR->(DBSEEK(/*xFilial()*/If(IP150Modo("SYR"),xFilial("SYR"),aFilSel[i])+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))   //GFP - 24/01/2013
         SY9->(dbSetOrder(2))
         MWData2 := dDataBase + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(/*xFilial()*/If(IP150Modo("SY9"),xFilial("SY9"),aFilSel[i])+SW2->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))  //GFP - 24/01/2013
         SY9->(dbSetOrder(1))
      //ENDIF
      //
      //                   Fim  - JBS
      //
      DBSELECTAREA("TRB")    // Rotina Grava_IG000(PBlock)
      DBAPPEND()
      TRB->WKFILIAL := If(IP150Modo("SW5"),xFilial("SW5"),aFilSel[i]) //aFilSel[i] //cFilAnt //SW5->W5_FILIAL //JWJ 26/05/2006  //GFP - 18/12/2012 RCR - 19/03/2013
      DO CASE
         CASE TIndice == COMPRADOR   .OR. TIndice == C_CUSTO .OR. TArquivo == GERAL_PO
              TRB->W0_COMPRA  := SW2->W2_COMPRA
              TRB->W1_PO_NUM  := SW5->W5_PO_NUM
              TRB->W1_FORN    := SW5->W5_FORN
              TRB->A2_NREDUZ  := BuscaFabr_Forn(SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ"))
              TRB->W1_CC      := SW5->W5_CC
              TRB->W1_SI_NUM  := SW5->W5_SI_NUM
              TRB->W6_DESP    := SPACE(3)
              TRB->W2_CLIENTE := SW2->W2_CLIENTE           
              TRB->W3_PGI_NUM := SW5->W5_PGI_NUM // JBS - 16/09/2003
              //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
              TRB->W6_HAWB    := cNumProc 
              If EICLoja()
                 TRB->W1_FORLOJ := SW5->W5_FORLOJ
                 TRB->W2_CLILOJ := SW2->W2_CLILOJ
              EndIf 
           

         CASE (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE .OR. TArquivo = DESEMB_PENDENTE .OR. TArquivo == GERAL)) .OR. TIndice = 4
              TRB->W2_CLIENTE := SW2->W2_CLIENTE
              TRB->W1_PO_NUM  := SW5->W5_PO_NUM
              TRB->W0_COMPRA  := SW2->W2_COMPRA
              TRB->W1_FORN    := SW5->W5_FORN
              TRB->A2_NREDUZ  := BuscaFabr_Forn(SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ"))
              TRB->W1_CC      := SW5->W5_CC
              TRB->W1_SI_NUM  := SW5->W5_SI_NUM
              TRB->W6_DESP    := SPACE(3)
              //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
              TRB->W6_HAWB    := cNumProc
              TRB->W3_PGI_NUM := SW5->W5_PGI_NUM // JBS - 16/09/2003 
              If EICLoja()
                 TRB->W1_FORLOJ := SW5->W5_FORLOJ
                 TRB->W2_CLILOJ := SW2->W2_CLILOJ
              EndIf 
      ENDCASE
      //**** TDF - 21/07/11
      cDescTemp :=MSMM(SB1->B1_DESC_P,nTamDesc)
      nLinDesc  :=MlCount(cDescTemp,nTamDesc)
      cDescItem :=""
   
      For nX:=1 To nLinDesc
         cDescItem += AllTrim(StrTran(Memoline(cDescTemp,nTamDesc,nX), ENTER,""))
         cDescItem += " "
      Next
     //****
      TRB->W1_COD_I   := SW5->W5_COD_I
      TRB->W1_REG     := SW1->W1_REG
      TRB->W1_SEQ     := SW1->W1_SEQ
      TRB->B1_DESC    := cDescItem //TDF - 21/07/11
    //TRB->A5_CODPRF  := SA5->A5_CODPRF
      TRB->W1_QTDE    := MQtde
      TRB->W3_PRECO   := CalcFob_Us(SW5->W5_PRECO,,,AvSX3("W3_PRECO",4))
      TRB->WKVALOR    := CalcFob_Us(SW5->W5_PRECO,SW5->W5_SALDO_Q)
      TRB->W0__DT     := SW0->W0__DT
      TRB->W2_DT_ALTE := MDt_IncAlt
      TRB->W3_DT_ENTR := MWData
      //DFS - 18/08/10 - Adicionado campo para Previsão de Entrega Calculada
      TRB->WK_DT_PREC := MWData2
      TRB->WKOBS      := TObs
      TRB->W1_DTENTR_ := SW1->W1_DTENTR_
      TRB->W3_POSICAO := SW3->W3_POSICAO   
      TRB->WK_DTEMB   := SW5->W5_DT_EMB 

      If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 08/10/2007
         SW3->(DbSetOrder(8))
         SW3->(DbSeek(/*xFilial("SW3") aFilSel[i]*/If(IP150Modo("SW3"),xFilial("SW3"),aFilSel[i]) + SW5->W5_PO_NUM + SW5->W5_POSICAO))  //GFP - 24/01/2013 RCR - 19/03/2013
         If !Empty(SW3->W3_PART_N)
            TRB->A5_CODPRF  := SW3->W3_PART_N
         Else
            TRB->A5_CODPRF  := SA5->A5_CODPRF                                    
         EndIf  
      Else
         TRB->A5_CODPRF  := SA5->A5_CODPRF                                    
      EndIf
      IF W_Pont <> 0
         T_TabUsd[W_Pont] += TRB->WKVALOR
      ENDIF

      IF(lExisteRD,ExecBlock("ICPAD150",.F.,.F.,"7"),) //AWR 08/06/1999
      IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"GRVGI"),)//igorchiba 17/27/2010 gravacao PGI
      DBSELECTAREA("SW5")
      DBSKIP()
   ENDDO
Next i  // GFP - 18/12/2012

RETURN ""

*-------------------------------------------------*
FUNCTION Grava_ID000(PBlock,PDt_I,PDt_F,cLastProc)
*-------------------------------------------------*
LOCAL TData := dDataBase - 20,TVes
LOCAL Chave ,  _Qtde := 0
LOCAL cPoint:="EICID01E"
LOCAL lPoint:=EasyEntryPoint(cPoint)
LOCAL lDiNac:=.F.
LOCAL nX:= 0 //TDF - 21/07/11  
LOCAL cNumProc := SPACE(LEN(SW7->W7_HAWB))
Local lGerCambio := .F.
Local i := 0 //GFP - 18/12/2012

lExisteRD:=EasyEntryPoint("ICPAD150")//Por causa do gerador de relatorios


If SYL->(FieldPos("YL_CAMBIO")) > 0  // ASK 12/12/07 - Gera as parcelas de câmbio do relatório 
   lGerCambio := SYL->YL_CAMBIO $ cSim 
EndIf
   
If lGerCambio = Nil
   lGerCambio := .F.
EndIf
   

IF(cLastProc=Nil,cLastProc:="",)
DBSELECTAREA("SW5")
DBSETORDER(1)

For i := 1 To Len(aFilSel)  // GFP - 18/12/2012 - Buscar registro das filiais selecionadas.
   FOR TVes=1 TO 2
       W_Pont = 0

       SW6->(DBSETORDER(4))         // ordem de data de entrega didt_entr ou
       IF PBlock = NIL              // didt_desem se vier do ip155
          IF TVes = 1
             SW6->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW6"),xFilial("SW6"),aFilSel[i]))) //GFP - 18/12/2012 RCR - 19/03/2013
          ELSE
             SW6->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW6"),xFilial("SW6"),aFilSel[i])+DTOS(TData),.T.)) //GFP - 18/12/2012 RCR - 19/03/2013
          ENDIF
       ELSE
          IF TVes = 1
             IF EMPTY(PDt_I)
                SW6->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW6"),xFilial("SW6"),aFilSel[i]))) //GFP - 18/12/2012 RCR - 19/03/2013
             ELSE
                SW6->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW6"),xFilial("SW6"),aFilSel[i])+DTOS(PDt_I),.T.)) //GFP - 18/12/2012 RCR - 19/03/2013
             ENDIF
          ELSE
             EXIT
          ENDIF
       ENDIF 
    
       IF !lEmail
          ProcRegua(SW6->(Easyreccount("SW6")))
       ENDIF   

       DO WHILE ! SW6->(EOF()) .AND. ((cLastProc == 'IP300' .AND. SW6->W6_FILIAL == xFilial("SW6")) .OR. (cLastProc <> 'IP300' .AND. SW6->W6_FILIAL == If(IP150Modo("SW6"),xFilial("SW6"),aFilSel[i])))  // GFP - 31/08/2015
          nCont+=1
       
          IF !lEmail  
             IncProc(STR0071+STR(nCont)+" / "+ALLTRIM(STR(SW6->(Easyreccount("SW6"))))) //'Lendo DI Reg.: '
          ENDIF   

          IF PBlock = NIL
             IF TVes = 1
                IF .NOT. EMPTY(SW6->W6_DT_ENTR)
                   EXIT
                ENDIF
             ELSE
                IF SW6->W6_DT_ENTR < TData
                   EXIT
                ENDIF
             ENDIF
          ELSE
             IF TVes = 1
                IF ! EMPTY(PDt_F)
                   IF cLastProc = 'IP300'
                      IF  SW6->W6_DT_ENTR > PDt_F
                         EXIT
                      ENDIF
                   ELSEIF SW6->W6_DT_DESEM > PDt_F
                         EXIT
                   ENDIF
                //ELSEIF cLastProc = 'IP300' .AND. ! EMPTY(SW6->W6_DT_ENTR)   // GFP - 31/08/2015
                //   EXIT
                ENDIF
             ELSE
                EXIT
             ENDIF
          ENDIF

          IF EMPTY(SW6->W6_HAWB)
             SW6->(DBSKIP()) ; LOOP
          ENDIF

		   IF cLastProc == 'IP300'   // GFP - 31/08/2015 
		      IF SYL->YL_ABERTO $ cSim .AND. !Empty(SW6->W6_DT_DESE)
		         SW6->(DBSKIP())
		         LOOP
		      ELSEIF SYL->YL_ABERTO $ cNao .AND. Empty(SW6->W6_DT_DESE)
		         SW6->(DBSKIP())
		         LOOP
		      ENDIF         
		      IF SYL->YL_ENTREG $ cSim .AND. Empty(SW6->W6_DT_ENTR)  // GFP - 23/09/2015
		         SW6->(DBSKIP())
		         LOOP
		      ELSEIF SYL->YL_ENTREG $ cNao .AND. !Empty(SW6->W6_DT_ENTR)
		         SW6->(DBSKIP())
		         LOOP
		      ENDIF
		   ENDIF

          IF TIndice = 3 .AND. TArquivo = DESEMB_PENDENTE
             IF .NOT. EMPTY(TDespachante)
                IF SW6->W6_DESP <> TDespachante
                   SW6->(DBSKIP()) ; LOOP
                ENDIF
             ENDIF
          ENDIF

          If lPoint .And. !ExecBlock(cPoint)
             SW6->(DBSKIP()) ; LOOP
          ENDIF

          DBSELECTAREA("SW7")
          dbSetOrder(1)
          DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW7"),xFilial("SW7"),aFilSel[i])+SW6->W6_HAWB)  //GFP - 18/12/2012
       
          cNumProc := SW6->W6_HAWB

          DO WHILE .NOT. EOF() .AND. SW6->W6_HAWB   = W7_HAWB   .AND. ;
                                     SW7->W7_FILIAL = If(IP150Modo("SW7"),xFilial("SW7"),aFilSel[i])//aFilSel[i]//xFilial("SW7") //GFP - 18/12/2012 RCR - 19/03/2013
             IF TIndice = 1
                IF .NOT. EMPTY(TCCusto)
                   IF TArquivo <> GERAL
                      IF TCCusto <> W7_CC
                         SKIPLOOP
                      ENDIF
                   ELSE
                      IF W7_CC < TCCustoI .OR. W7_CC > TCCustoF
                         SKIPLOOP
                      ENDIF
                   ENDIF
                ENDIF
             ENDIF

             IF ! IP150_SelPO(W7_PO_NUM)
                SKIPLOOP
             ENDIF

             IF ! SW2->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW2"),xFilial("SW2"),aFilSel[i])+SW7->W7_PO_NUM)) //GFP - 18/12/2012 RCR - 19/03/2013
                DBSELECTAREA("SW7")
                SKIPLOOP
             ENDIF
          
             lLoop:=.F.
             IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"LOOPDI"),)//igorchiba 17/27/2010 VALIDACAO DI
             IF lLoop
                DBSELECTAREA("SW7")
                DBSKIP()
                LOOP
             ENDIF

             If(!Empty(SW2->W2_HAWB_DA),lDINac:=.T.,lDiNac:=.F.)

             IF (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE)) .OR. TIndice = 4
                IF ! EMPTY(TCliente)
                   IF SW2->W2_CLIENTE # TCliente
                      SKIPLOOP
                   ENDIF
                ENDIF
             ENDIF
          
             IF TIndice = 2
                IF .NOT. EMPTY(TComprador)
                    IF SW2->W2_COMPRA <> TComprador
                       SKIPLOOP
                    ENDIF
                ENDIF
             ENDIF 
          
             //ACB 26/08/2010 - Melhoria filtro por fornecedor
             IF TIndice == 5 .AND. TArquivo == DESEMB_PENDENTE
                IF mTemForn
                   IF ! SelecForn(SW7->W7_FORN)
                      DBSELECTAREA("SW7")
                      SKIPLOOP
                   ENDIF
                ENDIF
             ENDIF
             
             //LRS - 26/05/2015 - Caso o TIndice e TArquivo for 0, quer dizer que o relatorio esta vindo do Miselanea
             IF TIndice == 0 .AND. TArquivo == 0 
                 If cLastProc == 'IP300' .AND. ((SYL->YL_ABERTO $ cSim .AND. !Empty(SW6->W6_DT_DESE)) .OR. (SYL->YL_ABERTO $ cNao .AND. Empty(SW6->W6_DT_DESE))) //Empty(SW6->W6_DT_DESE) 
      		        SKIPLOOP  
    	         Endif
	         Else 
    	         If ! Empty(SW6->W6_DT_DESE) 
                    SKIPLOOP  
                 Endif
	         EndIF     

             IF ! SB1->(DBSEEK(/*xFilial()*/If(IP150Modo("SB1"),xFilial("SB1"),aFilSel[i])+SW7->W7_COD_I )) //GFP - 24/01/2013
                DBSELECTAREA("SW7")
                SKIPLOOP
             ENDIF

             SA5->(DBSETORDER(3))
             //IF ! SA5->(DBSEEK(xFilial()+SW7->W7_COD_I + SW7->W7_FABR + SW7->W7_FORN))
             IF !EICSFabFor(xFilial("SA5")+SW7->W7_COD_I + SW7->W7_FABR + SW7->W7_FORN, EICRetLoja("SW7", "W7_FABLOJ"), EICRetLoja("SW7", "W7_FORLOJ"))
                DBSELECTAREA("SW7")
                SKIPLOOP
             ENDIF

             TObs   := SPACE(33)
             W_Pont := 0

             IF PBlock = NIL
                IF ! EMPTY(SW6->W6_DT_ENTR) .AND. SW6->W6_DT_ENTR < dDataBase - 4
                   SKIPLOOP
                 ENDIF
             ENDIF

             If Empty(SW6->W6_DT_ENCE) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente
  	   	        IF !EMPTY(SW6->W6_DT_EMB)
                   If !lDINac
	                  IF EMPTY(SW6->W6_CHEG)
		   	             TObs   := STR0072 + DTOC(SW6->W6_DT_EMB) //"EM TRANSITO DESDE "
			             W_Pont := 11
			          ELSE
			             TObs   := STR0073 + DTOC(SW6->W6_CHEG) //"ATRACADO EM "
			             W_Pont := 11
			          ENDIF
			       Else    
			          TObs   := STR0118 + DTOC(SW6->W6_DT_HAWB) //"AGUARDANDO NACIONALIZACAO DESDE "
                      W_Pont := 11
			       EndIf
                ENDIF
             ELSE 
               SKIPLOOP
             ENDIF                                                                                                            
          
             If Empty(SW6->W6_DT_ENCE) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente
                IF .NOT. EMPTY(SW6->W6_CHEG)
                   IF EMPTY(SW6->W6_DT) .AND. .NOT. EMPTY(SW6->W6_DT_AVE)
                      If !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04")    //Diferente de DA
			             TObs   := STR0074 + DTOC(SW6->W6_DT_AVE) //"AG. PGTO IMPOSTOS DESDE "
                         W_Pont := 13
				      Else   
		                 TObs   := STR0119 //+ DTOC(SW6->W6_DT_AVE) "AG. DECLARACAO DE ADMISSAO "
                      EndIf
                   ENDIF
                ENDIF 
             ELSE 
                SKIPLOOP
             ENDIF
          
  
             If Empty(SW6->W6_DT_ENCE) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente
                IF .NOT. EMPTY(SW6->W6_DT)
                   IF EMPTY(SW6->W6_DT_DESEM)
                      MDiasUteis := 0
                      MDias := 0
                      If !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .and. !lDINac // DI
                         TObs := STR0075 + DTOC(SW6->W6_DT+MDias) //"AG. DESEMBARACO DESDE "
			             W_Pont := 14
			          ElseIf !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .and. lDINac // DI Nac.
				         IF !EMPTY(SW6->W6_DT_DESE) 
			                TObs := STR0118 + DTOC(SW6->W6_DT_DESE)//"AG. NACIONALIZACAO DESDE "### + DT_DES.
				         Else   
				            TObs := STR0118 + DTOC(SW6->W6_DT)//"AG. NACIONALIZACAO DESDE "### + DT_PAGTO IMP.
				         Endif   
				         //TObs = STR0100 + DTOC(SW6->W6_DT_HAWB)  //"AG. NACIONALIZACAO DESDE"
	                  Else // DA
				         TObs := STR0120 //+ DTOC(SW6->W6_DT+MDias) //"AG. ENTREPOSTAMENTO "
		              EndIf
                   ELSE
                      If !Empty(SW6->W6_DT_ENCE) .OR. (cLastProc <> 'IP300' .AND. !Empty(SW6->W6_DT_DESE)) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente
  	                     SKIPLOOP  
		              ElseIf !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .AND. Empty(SW6->W6_DT_ENCE)  //Diferente de DA
		                 TObs := STR0076 //"AGUARDANDO ENTREGA    "     
		              Else
	                     TObs := STR0120 //"AG. ENTREPOSTAMENTO "
		              EndIf
                      W_Pont := 15
                   ENDIF
             ENDIF
          ELSE 
             SKIPLOOP
          ENDIF

             If Empty(SW6->W6_DT_ENCE) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente
                IF EMPTY(SW6->W6_DT)  && Alterado em 27-04-93 pedido p/ Atilio
                   IF .NOT. EMPTY(SW6->W6_DTRECDOC) .AND. .NOT. EMPTY(SW6->W6_CHEG)
                      IF SY9->(DBSEEK(/*xFilial()*/If(IP150Modo("SY9"),xFilial("SY9"),aFilSel[i])+SW6->W6_LOCAL)) .AND. SY9->Y9_DAP == "S" //GFP - 24/01/2013
                         TObs   = STR0077 //"MAT. AGUARDANDO NO DAP"
                         W_Pont := 12
                      ENDIF
                   ENDIF
                ENDIF
             ELSE
                SKIPLOOP
             ENDIF
           
             MQtde := SW7->W7_QTDE
          
             If Empty(SW6->W6_DT_ENCE) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente          
                IF SW7->W7_FLUXO = "4"
                   IF ! EMPTY(SW6->W6_DA_DT)
                      TObs  := STR0120 //"AG. ENTREPOSTAMENTO"
                      W_Pont:= 21
                      Chave := /*xFilial() aFilSel[i]*/If(IP150Modo("SW7"),xFilial("SW7"),aFilSel[i])+SW7->W7_HAWB+SW7->W7_COD_I //GFP - 18/12/2012 RCR - 19/03/2013
                      _Qtde := 0
                      MQtde := VAL(STR(MQtde - _Qtde,AVSX3("W7_QTDE",3),AVSX3("W7_QTDE",4)))
                      IF VAL(STR(SW7->W7_QTDE - _Qtde,AVSX3("W7_QTDE",3),AVSX3("W7_QTDE",4))) <= 0
                         DBSELECTAREA("SW7")
                         SKIPLOOP
                      ENDIF
                   ENDIF
                ENDIF
             ELSE
                SKIPLOOP
             ENDIF
          
             IF Empty(SW6->W6_DT_ENCE) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente
                IF !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .and. !EMPTY(SW6->W6_DT_ENTR) //Diferente de DA
                   TObs   := STR0079 + DTOC(SW6->W6_DT_ENTR) //"ENTREGUE EM "
                   W_Pont := 16
                ELSEIF ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") // DA
                   IF EMPTY(SW6->W6_DI_NUM)
                      TObs := STR0120 //"AG. ENTREPOSTAMENTO"
                   ELSEIF !SW2->(DbSeek(/*xFilial("SW2") aFilSel[i]*/If(IP150Modo("SW2"),xFilial("SW2"),aFilSel[i])+LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM)))) //GFP - 18/12/2012 RCR - 19/03/2013
                      TObs := STR0045 //"AG. NACIONALIZAÇÃO"
                   ELSE  
                      nRegSW7 := SW7->(Recno()) 
                      cIndSW7 := SW7->(IndexOrd())
                      nPosSW7 := SW7->W7_POSICAO
                      SW7->(DbSetOrder(2))
                      cFilSW7 := If(IP150Modo("SW7"),xFilial("SW7"),aFilSel[i])//aFilSel[i]//xFilial("SW7") //GFP - 18/12/2012 RCR - 19/03/2013
                      SW7->(DBSEEK(cFilSW7+SW2->W2_PO_NUM))
                      lItemSW7 := .F.        
                      DO WHILE SW7->(!EOF()) .And. /*xFilial("SW7") aFilSel[i]*/If(IP150Modo("SW7"),xFilial("SW7"),aFilSel[i]) == cFilSW7 .AND.; //GFP - 18/12/2012 RCR - 19/03/2013
                                                   SW7->W7_PO_NUM = SW2->W2_PO_NUM
                         IF SW7->W7_POSICAO = nPosSW7
                            lItemSW7 := .T.
                            EXIT
                         ENDIF
                         SW7->(DbSkip())                           
                      ENDDO    
                      //JVR - 29/10/2009 - Retirado de dentro do if.
                      SW7->(DbGoto(nRegSW7))
                      SW7->(DbSetOrder(cIndSW7))
                      IF lItemSW7        
                         SW7->(DbSkip()) 
                         LOOP
                      ELSE                      
                         //SW7->(DbGoto(nRegSW7))
                         //SW7->(DbSetOrder(cIndSW7))              
                         TObs := STR0045 //"AG. NACIONALIZAÇÃO"
                      ENDIF  
                   ENDIF 
                ENDIF
             ELSE
                SKIPLOOP
             ENDIF   
             
             
			 IF SW6->W6_DT_EMB > dDataBase //LBL - 13/11/2013
  	    		 TObs := STR0124 //"EMBARQUE PENDENTE"
		     END IF 

             IF ! SW0->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW0"),xFilial("SW0"),aFilSel[i])+SW7->W7_CC+SW7->W7_SI_NUM)) //GFP - 18/12/2012 RCR - 19/03/2013
                DBSELECTAREA("SW7")
                SKIPLOOP
             ENDIF

             IF ! PosO1_It_Solic(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,;
                                 SW7->W7_REG,0,If(IP150Modo("SW1"),xFilial("SW1"),aFilSel[i])) // GFP - 20/02/2013
                DBSELECTAREA("SW7")
                SKIPLOOP
             ENDIF

             IF PosOrd1_It_Guias(SW7->W7_PGI_NUM,SW7->W7_CC,SW7->W7_SI_NUM,;
                                 SW7->W7_COD_I,SW7->W7_FABR,;
                                 SW7->W7_FORN,SW7->W7_REG,0,SW7->W7_PO_NUM,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ"),/*aFilSel[i]*/If(IP150Modo("SW7"),xFilial("SW7"),aFilSel[i])) // LDR 07/04/2004 // GFP - 18/12/2012 RCR - 19/03/2013
				DBSELECTAREA("SW5")
                MChave1 =  SW7->W7_PGI_NUM + SW7->W7_CC + SW7->W7_SI_NUM + ;
                           SW7->W7_COD_I

                MChave2 =  SW5->W5_PGI_NUM + SW5->W5_CC + SW5->W5_SI_NUM + SW5->W5_COD_I

                DO WHILE .NOT. EOF() .AND. MChave1 = MChave2 .AND.  ;
                      SW5->W5_FILIAL = If(IP150Modo("SW5"),xFilial("SW5"),aFilSel[i]) //aFilSel[i]//xFilial("SW5") //GFP - 18/12/2012 RCR - 19/03/2013

                   IF (SW7->W7_FABR <> SW5->W5_FABR .AND. IIF(EICLoja(),SW7->W7_FABLOJ <> SW5->W5_FABLOJ,.T.)) .OR. ;
                      (SW7->W7_FORN <> SW5->W5_FORN .AND. IIF(EICLoja(),SW7->W7_FORLOJ <> SW5->W5_FORLOJ,.T.)) .OR. ;
                      SW7->W7_REG  <> SW5->W5_REG
                      SKIPLOOP
                   ENDIF
   //               Colocado no Do-While esta condicao

                   IF SW5->W5_HAWB = SW7->W7_HAWB
                      EXIT
                   ENDIF

                   DBSKIP()
                ENDDO

                IF EOF() .OR. MChave1 <> MChave2 .OR. SW5->W5_FILIAL <> If(IP150Modo("SW5"),xFilial("SW5"),aFilSel[i])//aFilSel[i]//xFilial("SW5") //GFP - 18/12/2012 RCR - 19/03/2013
                   DBSELECTAREA("SW7")
                   SKIPLOOP
                ENDIF
             ELSE
                DBSELECTAREA("SW7")
                SKIPLOOP
             ENDIF

             DBSELECTAREA("SW7")
             IF TIndice = 3 .AND. TArquivo = GERAL .AND. MTemForn
                IF ! SelecForn(SW7->W7_FORN)
                   SKIPLOOP
                ENDIF
             ENDIF

             IF .NOT. EMPTY(SW2->W2_DT_ALTE)
                MDt_IncAlt = SW2->W2_DT_ALTE
             ELSE
                MDt_IncAlt = SW2->W2_PO_DT
             ENDIF
             //
             //  JBS - 17/09/2003  - Calculo da Data de Entrega
             //
            // IF !empty(SW6->W6_DT_ENTR)
                MWData := SW6->W6_DT_ENTR
            // ELSE
                SY9->(DBSETORDER(2)) 
                SYR->(dbSetOrder(1))  // Filial+Yr_Via+Yr_Origem...
                SYR->(dbSeek(/*xFilial()*/If(IP150Modo("SYR"),xFilial("SYR"),aFilSel[i])+SW6->W6_VIA_TRA+SW6->W6_ORIGEM)) //GFP - 24/01/2013
                MWData2    := AvCtod("") 
                nDiasDese  := IF(SY9->(DBSEEK(/*xFilial()*/If(IP150Modo("SY9"),xFilial("SY9"),aFilSel[i])+SW6->W6_DEST)),SY9->Y9_LT_TRA,0) //GFP - 24/01/2013
                nDiasCheg  := IF(SY9->(FOUND()),(SY9->Y9_LT_TRA+SY9->Y9_LT_DES), EasyGParam("MV_LT_DESE"))
                nDiasEmb   := IF(SY9->(FOUND()),(SY9->Y9_LT_TRA+SY9->Y9_LT_DES), EasyGParam("MV_LT_DESE"))+SYR->YR_TRANS_T
                DO CASE
                   CASE !Empty(SW6->W6_PRVENTR) ; MWData := SW6->W6_PRVENTR //previsão de entrega (14/07/2017)
                   CASE !Empty(SW6->W6_DT_DESE) ; MWData := SW6->W6_DT_DESE + nDiasDese //desembaraço
                   CASE !EMPTY(SW6->W6_PRVDESE) ; MWData := SW6->W6_PRVDESE + nDiasDese //previsão de desembaraço
                   CASE !Empty(SW6->W6_CHEG)    ; MWData := SW6->W6_CHEG    + nDiasCheg //atracação
                   CASE !Empty(SW6->W6_DT_ETA)  ; MWData := SW6->W6_DT_ETA  + nDiasCheg //previsão de chegada
                   CASE !Empty(SW6->W6_DT_EMB)  ; MWData := SW6->W6_DT_EMB  + nDiasEmb //embarque
                   CASE !Empty(SW6->W6_DT_ETD)  ; MWData := SW6->W6_DT_ETD  + nDiasEmb //previsão de embarque
                   OTHERWISE                    ; MWData := SW5->W5_DT_EMB  + nDiasEmb
                ENDCASE           
                SY9->(DBSETORDER(1))
   //          ENDIF
             //
             // Fim - JBS
             //
             If Empty(SW6->W6_DT_ENCE) //DFS - 13/04/11 - Inclusão de status na impressão do relatório de Desembaraço Pendente          
                IF EMPTY(SW6->W6_DT_EMB) .AND. EMPTY(TObs) .AND. !lDiNac
                   TObs := STR0113 //"AGUARD.CONFIRMACAO DE EMBARQUE"
                   W_Pont := 4
                 ENDIF
             ELSE
                SKIPLOOP
             ENDIF

             SW7->(PosO1_ItPedidos(W7_PO_NUM,W7_CC,W7_SI_NUM,W7_COD_I,;
                                             W7_FABR,W7_FORN,W7_REG,0,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ"),If(IP150Modo("SW3"),xFilial("SW3"),aFilSel[i])) )  // GFP - 20/02/2013
               
             IF ! SW7->W7_PGI_NUM == SW4->W4_PGI_NUM
                SW4->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SW4"),xFilial("SW4"),aFilSel[i])+SW7->W7_PGI_NUM)) //GFP - 18/12/2012 RCR - 19/03/2013
             ENDIF

             IF SW7->W7_FLUXO='1'
                SWP->(DBSEEK(/*xFilial() aFilSel[i]*/If(IP150Modo("SWP"),xFilial("SWP"),aFilSel[i])+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI)) //GFP - 18/12/2012 RCR - 19/03/2013
             ENDIF

             IF lExisteRD
                IF ExecBlock("ICPAD150",.F.,.F.,"8") //AWR 08/06/1999
                   DBSELECTAREA("SW7")
                   DBSKIP()
                   LOOP
                ENDIF
             ENDIF

             IF PBlock # NIL 
                If lGerCambio
                   SWB->(DbGoBottom())    
                   SWB->(DbSkip())             
                   SW2->(DbGoBottom())    
                   SW2->(DbSkip())
                EndIf
                EVAL(PBlock,SW6->W6_DT_DESE)
                DBSELECTAREA("SW7")
                DBSKIP()
                LOOP
             ENDIF

             // Este trecho pertence a Rotina Grava_ID000(PBlock,PDt_I,PDt_F)
             TRB->(DBAPPEND())
             TRB->WKFILIAL := If(IP150Modo("SW7"),xFilial("SW7"),aFilSel[i]) //aFilSel[i]//cFilAnt //SW7->W7_FILIAL //JWJ 26/05/2006 RCR - 19/03/2013
          
             DO CASE
                 CASE TIndice == COMPRADOR   .OR. TIndice == C_CUSTO  .OR. TArquivo == GERAL_PO
                      TRB->W0_COMPRA  := SW2->W2_COMPRA
                      TRB->W1_PO_NUM  := SW7->W7_PO_NUM
                      TRB->W1_FORN    := SW7->W7_FORN
                      TRB->A2_NREDUZ  := BuscaFabr_Forn(SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ"))
                      TRB->W1_CC      := SW7->W7_CC
                      TRB->W1_SI_NUM  := SW7->W7_SI_NUM
                      TRB->W6_DESP    := SW6->W6_DESP
                      TRB->W2_CLIENTE := SW2->W2_CLIENTE
                      TRB->W3_PGI_NUM := SW3->W3_PGI_NUM // JBS - 16/09/2003
                      //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
                      TRB->W6_HAWB    := cNumProc 
                      If EICLoja()
                         TRB->W1_FORLOJ := SW7->W7_FORLOJ
                         TRB->W2_CLILOJ := SW2->W2_CLILOJ
                      EndIf 
                   
                 CASE (TIndice = 3 .AND. (TArquivo = PEDIDO_PENDENTE .OR. TArquivo = LICENC_PENDENTE .OR. TArquivo = DESEMB_PENDENTE .OR. TArquivo == GERAL)) .OR. TIndice = 4
                      TRB->W2_CLIENTE := SW2->W2_CLIENTE
                      TRB->W1_PO_NUM  := SW7->W7_PO_NUM
                      TRB->W0_COMPRA  := SW2->W2_COMPRA
                      TRB->W1_FORN    := SW7->W7_FORN
                      TRB->A2_NREDUZ  := BuscaFabr_Forn(SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ"))
                      TRB->W1_CC      := SW7->W7_CC
                      TRB->W1_SI_NUM  := SW7->W7_SI_NUM
                      TRB->W6_DESP    := SW6->W6_DESP
                      //TRB->W6_HAWB    := SW6->W6_HAWB    // JBS - 16/09/2003
                      TRB->W6_HAWB    := cNumProc
                      TRB->W3_PGI_NUM := SW3->W3_PGI_NUM // JBS - 16/09/2003 
                      If EICLoja()
                         TRB->W1_FORLOJ := SW7->W7_FORLOJ
                         TRB->W2_CLILOJ := SW2->W2_CLILOJ
                      EndIf 
             ENDCASE
             //**** TDF - 21/07/11
             cDescTemp :=MSMM(SB1->B1_DESC_P,nTamDesc)
             nLinDesc  :=MlCount(cDescTemp,nTamDesc)
             cDescItem :=""
   
             For nX:=1 To nLinDesc
                cDescItem += AllTrim(StrTran(Memoline(cDescTemp,nTamDesc,nX), ENTER,""))
                cDescItem += " "
             Next
             //****
          
             TRB->W1_COD_I   := SW7->W7_COD_I
             TRB->W1_REG     := SW1->W1_REG
             TRB->W1_SEQ     := SW1->W1_SEQ
             TRB->B1_DESC    := cDescItem //TDF - 21/07/11
           //TRB->A5_CODPRF  := SA5->A5_CODPRF
             TRB->W1_QTDE    := MQtde
             TRB->W3_PRECO   := CalcFob_Us(SW7->W7_PRECO,,,AvSX3("W3_PRECO",4))
             TRB->WKVALOR    := CalcFob_Us(SW7->W7_PRECO,SW7->W7_SALDO_Q)
             TRB->W0__DT     := SW0->W0__DT
             TRB->W2_DT_ALTE := MDt_IncAlt
             TRB->WKOBS      := TObs
             //LGS-06/12/2013 - Verifica se a data do embarque foi informado para incluir a data prevista de entrada calculado pelo sistema
             If TArquivo == DESEMB_PENDENTE
                TRB->W3_DT_ENTR := IIF(Empty(SW6->W6_DT_EMB),CTOD(""),MWData)
             Else
                TRB->W3_DT_ENTR := MWData
             EndIf   
             //DFS - 18/08/10 - Adicionado campo para Previsão de Entrega Calculada
             TRB->WK_DT_PREC := MWData2
             TRB->W1_DTENTR_ := SW1->W1_DTENTR_
             TRB->W3_POSICAO := SW3->W3_POSICAO  
             If TIndice = 5 //ACB 26/08/2010 - Melhoria filtro por fornecedor
                TRB->W1_PO_NUM  := SW7->W7_PO_NUM
                TRB->W1_FORN    := SW7->W7_FORN
                IF EICLOJA()
                   TRB->W1_FORLOJ := SW7->W7_FORLOJ   
                ENDIF
                TRB->W6_HAWB    := SW6->W6_HAWB
             EndIf
                     
             If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 08/10/2007
                SW3->(DbSetOrder(8)) 
                SW3->(DbSeek(/*xFilial("SW3") aFilSel[i]*/If(IP150Modo("SW3"),xFilial("SW3"),aFilSel[i]) + SW5->W5_PO_NUM + SW5->W5_POSICAO)) //GFP - 18/12/2012 RCR - 19/03/2013
                If !Empty(SW3->W3_PART_N)
                   TRB->A5_CODPRF  := SW3->W3_PART_N
                Else
                   TRB->A5_CODPRF  := SA5->A5_CODPRF                                    
                EndIf
             Else
                TRB->A5_CODPRF  := SA5->A5_CODPRF                                    
             EndIf                                   
             
          	 If TArquivo == DESEMB_PENDENTE //LGS-06/12/2013
				TRB->WK_DTEMB:=SW6->W6_DT_EMB
			 Else	          	 	
             	IF !EMPTY(SW6->W6_DT_EMB)
                   TRB->WK_DTEMB:=SW6->W6_DT_EMB
             	ELSEIF !EMPTY(SW6->W6_DT_ETD)       
                   TRB->WK_DTEMB:=SW6->W6_DT_ETD
                ELSE    
                   TRB->WK_DTEMB:=SW5->W5_DT_EMB   
                ENDIF
             EndIf      
          
             IF W_Pont <> 0
                T_TabUsd[W_Pont] += TRB->WKVALOR
             ENDIF

             IF(lExisteRD,ExecBlock("ICPAD150",.F.,.F.,"9"),) //AWR 08/06/1999
             IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"GRVDI"),)//igorchiba 17/27/2010     gravacao DI 
             DBSELECTAREA("SW7")
             DBSKIP()
          ENDDO
       
          //*** ASK 12/12/2007 - Inclusão das parcelas de câmbio no gerador de relatório
          If PBlock # Nil .And. lGerCambio
             SW7->(DbGoBottom()) 
             SW7->(DbSkip())
             SWB->(DbSetOrder(1))
             SWB->(DbSeek(/*xFilial("SWB") aFilSel[i]*/If(IP150Modo("SWB"),xFilial("SWB"),aFilSel[i])+SW6->W6_HAWB)) //GFP - 18/12/2012 RCR - 19/03/2013
             Do While !SWB->(Eof()) .AND. SW6->W6_HAWB == SWB->WB_HAWB .AND. SWB->WB_FILIAL = If(IP150Modo("SWB"),xFilial("SWB"),aFilSel[i])//aFilSel[i]//xFilial("SWB") //GFP - 18/12/2012 RCR - 19/03/2013
                EVAL(PBlock,SW6->W6_DT_DESE)
                DbSelectArea("SWB")
                SWB->(DbSkip())
                Loop 
             EndDo
          EndIf
          //***
       
          IF MAbandona
             EXIT
          ENDIF

          DBSELECTAREA("SW7")
          SW6->(DBSKIP())
       ENDDO


       IF MAbandona
          EXIT
       ENDIF

   NEXT
Next i
   
  
IF .NOT. MAbandona
   DBSELECTAREA("SW5")
   DBSETORDER(4)
ENDIF

RETURN ""

*----------------------------*
FUNCTION IP150_SelPO(PPO_NUM)
*----------------------------*

IF TArquivo = GERAL_PO
   IF ! EMPTY(TNr_POI)
      IF PPO_NUM < TNr_POI
         RETURN .F.
      ENDIF
   ENDIF

   IF ! EMPTY(TNr_POF)
      IF PPO_NUM > TNr_POF
         RETURN .F.
      ENDIF
   ENDIF
ENDIF

RETURN .T.

*--------------------------*
FUNCTION IP150Valid( Flag )
*--------------------------*

DO CASE
   CASE Flag == "I"
        IF EMPTY(TCCustoI)
           Help("",1,"AVG0001044",,_LIT_CC+STR0081,1,1)//" INICIAL NÇO PREENCHIDO"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF ! SY3->(DBSEEK(xFilial()+TCCustoI))
           Help("",1,"AVG0001044",,_LIT_CC+STR0082,1,1)//" INICIAL NÇO CADASTRADO"###"Informa‡Æo"
           RETURN .F.
        ENDIF

   CASE Flag == "F"
        IF EMPTY(TCCustoF)
           Help("",1,"AVG0001044",,_LIT_CC+STR0083,1,1)//" FINAL NÇO PREENCHIDO"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF ! SY3->(DBSEEK(xFilial()+TCCustoF))
           Help("",1,"AVG0001044",,_LIT_CC+STR0084,1,1)//" FINAL NÇO CADASTRADO"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF TCCustoF < TCCustoI
           Help("",1,"AVG0001044",,_LIT_CC+STR0085,1,1)//" FINAL MENOR QUE O INICIAL"###"Informa‡Æo"
           RETURN .F.
       ENDIF
ENDCASE

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION IP150Menu()
*----------------------------------------------------------------------------
LOCAL aTArq2:={STR0086,; //"Por Unid Req."
               STR0087} //"Por Comprador"
LOCAL Titulo:="", lCancel:=.F.

LOCAL aOrder:={STR0094 ,; //"1- P.O.           "
               STR0095 ,; //"2- Dt.Necessidade "
               STR0096 }


LOCAL aTb_Campos,aDBF,bMarca,aRetMarcados,aMarcados:={}, TCod

PRIVATE lProcessa:=.F.
//PRIVATE cMarca := GetMark(), lInverte := .F.


cTitulo:=STR0005 //"Itens Pendentes - "

IF TArquivo == 0
   RETURN NIL
ENDIF

Titulo:=SUBSTR(aTArq[TArquivo],3,LEN(aTArq[TArquivo]))
PRIVATE oDlg2
TIndice:=0
DO CASE
   CASE TArquivo == SOLIC_PENDENTE
        TIndice:=C_CUSTO        
            
        IP150BrowseFil(Titulo,@lCancel,aTArq2)
        
   CASE TArquivo == GERAL_PO
        //TIndice := 9
        Tindice:=1
          
        DEFINE MSDIALOG oDlg2 TITLE Titulo From 7,10 To 14,45 OF oMainWnd

//        @ 12,05 TO 50,79 LABEL "" OF oDlg2 PIXEL

//        @ 18,10 RADIO oRad1 VAR TIndice ITEMS aTArq2[1],aTArq2[2],aTArq2[3];
//                                        3D SIZE 60,9 PIXEL OF oDlg2

        cCombo:=aOrder[1]
        @ 15,05 SAY STR0099 PIXEL OF oDlg2
        @ 22,05 COMBOBOX oCBX VAR cCombo ITEMS aOrder SIZE 73,9 PIXEL OF oDlg2 

        
        DEFINE SBUTTON FROM 14,100 TYPE 1 ACTION (IP150BrowseFil(Titulo,@lCancel,,cCombo)) ENABLE OF oDlg2
        DEFINE SBUTTON FROM 28,100 TYPE 2 ACTION (/*oDlg:enable(),*/oDlg2:End()) ENABLE OF oDlg2

        ACTIVATE MSDIALOG oDlg2 CENTERED
        
//      IP150BrowseFil(Titulo,@lCancel)
        //IP150GET(9,,,Titulo)

   CASE TArquivo == PEDIDO_PENDENTE  .OR. TArquivo == LICENC_PENDENTE
        AADD(aTArq2,STR0088) //"Por Cliente"    
        AADD(aTArq2,STR0091)//"Por Fornecedor" - ACB 26/08/2010 - Melhoria filtro por fornecedor
        TIndice:=1
        //oDlg:disable()
        DEFINE MSDIALOG oDlg2 TITLE Titulo From 7,10 To 18,45 OF oMainWnd

        @ 12,05 TO 60,79 LABEL "" OF oDlg2 PIXEL

        @ 18,10 RADIO oRad1 VAR TIndice ITEMS aTArq2[1],aTArq2[2],aTArq2[3],aTArq2[4];//ACB 26/08/2010 - Melhoria filtro por fornecedor
                                        3D SIZE 60,9 PIXEL OF oDlg2                                         
                                            
        cCombo:=NIL
        IF TArquivo == LICENC_PENDENTE
           cCombo:=aOrder[1]
           @ 61,05 SAY STR0099 PIXEL OF oDlg2
           @ 67,05 COMBOBOX oCBX VAR cCombo ITEMS aOrder SIZE 73,9 PIXEL OF oDlg2 
        ENDIF
        
        DEFINE SBUTTON FROM 14,100 TYPE 1 ACTION (IP150BrowseFil(Titulo,@lCancel,aTARq2,cCombo)) ENABLE OF oDlg2
        DEFINE SBUTTON FROM 28,100 TYPE 2 ACTION (/*oDlg:enable(),*/oDlg2:End()) ENABLE OF oDlg2

        ACTIVATE MSDIALOG oDlg2 CENTERED

   CASE TArquivo == DESEMB_PENDENTE
        TIndice:=1
        AADD(aTArq2,STR0089) //"Por Despachante"
        AADD(aTArq2,STR0090) //"Por Cliente    " 
        AADD(aTArq2,STR0091)//"Por Fornecedor" - ACB 26/08/2010 - Melhoria filtro por fornecedor

        //oDlg:disable()
        DEFINE MSDIALOG oDlg2 TITLE Titulo From 4,10 To 18,48 OF oMainWnd

        @ 12,02 TO 70,75 LABEL "" OF oDlg2 PIXEL

        @ 16,07 RADIO oRad1 VAR TIndice ITEMS aTArq2[1],aTArq2[2],aTArq2[3],aTArq2[4],aTArq2[5];//ACB 26/08/2010 - Melhoria filtro por fornecedor
                                        3D SIZE 70,9 OF oDlg2 PIXEL

        cCombo:=aOrder[1]
        @ 69,05 SAY STR0099 PIXEL OF oDlg2
        @ 75,05 COMBOBOX oCBX VAR cCombo ITEMS aOrder SIZE 73,9 PIXEL OF oDlg2 
       
//      DEFINE SBUTTON FROM 16,100 TYPE 1 ACTION (IP150GET(TIndice,,aTarq2)) ENABLE OF oDlg2
        DEFINE SBUTTON FROM 16,100 TYPE 1 ACTION (IP150BrowseFil(Titulo,@lCancel,aTARq2,cCombo)) ENABLE OF oDlg2
        DEFINE SBUTTON FROM 30,100 TYPE 2 ACTION (/*oDlg:enable(),*/oDlg2:End()) ENABLE OF oDlg2

        ACTIVATE MSDIALOG oDlg2 CENTERED

   CASE TArquivo == GERAL
        TIndice:=1
        AADD(aTArq2,STR0091) //"Por Fornecedor"
        AADD(aTarq2,STR0092) //"Por Cliente   "
        //oDlg:disable()

        DEFINE MSDIALOG oDlg2 TITLE Titulo From 7,10 To 20,45 OF oMainWnd

        @ 12,02 TO 55,79 LABEL "" OF oDlg2 PIXEL

        @ 16,07  RADIO oRad1 VAR TIndice ITEMS aTArq2[1],aTArq2[2],aTArq2[3],aTArq2[4];
                                         3D SIZE 70,9 OF oDlg2 PIXEL

        cCombo:=aOrder[1]
        @ 58,05 SAY STR0099 PIXEL OF oDlg2
        @ 67,05 COMBOBOX oCBX VAR cCombo ITEMS aOrder SIZE 73,9 PIXEL OF oDlg2 

        DEFINE SBUTTON FROM 16,100 TYPE 1 ACTION (IP150BrowseFil(Titulo,@lCancel,aTARq2,cCombo)) ENABLE OF oDlg2
        DEFINE SBUTTON FROM 30,100 TYPE 2 ACTION (/*oDlg:enable(),*/oDlg2:End()) ENABLE OF oDlg2

        ACTIVATE MSDIALOG oDlg2 CENTERED
ENDCASE
RETURN .T.


*--------------------------------------*
FUNCTION IP150BrowseFil(Titulo,lCancel,aTArq,cCombo)
*--------------------------------------*                                 
LOCAL aAreaComp:={ "SY3","SY1","SA1"}, cALIAS
LOCAL aCamposInd:={"W0__CC","Y1_COD","A1_COD"}, ccpo, aMarcados:={}, lBrowseFil:=.F.
LOCAL cCodI, cCodF, aRetGET:={}
LOCAL aParam


cTitulo:=STR0005 //"Itens Pendentes - "

IF cCombo <> NIL
   TOrder:=VAL(LEFT(cCombo,1))
ENDIF
//ACB 26/08/2010 - Melhoria filtro por fornecedor
IF TArquivo == PEDIDO_PENDENTE .Or. TArquivo == LICENC_PENDENTE
   AADD(aAreaComp,"SA2")
   
   AADD(aCamposInd,"A2_COD")
ENDIF

IF TArquivo == DESEMB_PENDENTE 
   aAreaComp[3]:="SY5"   // por Despachante
   AADD(aAreaComp,"SA1") // por Cliente
   AADD(aAreaComp,"SA2") //"Por Fornecedor" --ACB 26/08/2010 - Melhoria filtro por fornecedor
   
   aCamposInd[3]:="Y5_COD"   // Cod Despachante
   AADD(aCamposInd,"A1_COD") // Cod Cliente
   AADD(aCamposInd,"A2_COD")//"Por Fornecedor" --ACB 26/08/2010 - Melhoria filtro por fornecedor
ENDIF

IF TArquivo == GERAL
   aAreaComp[3]:="SA2"        // Por Fornecedor
   AADD(aAreaComp,"SA1")     //  Por Cliente
   
   aCamposInd[3]:="A2_COD"   // Por Fornecedor
   AADD(aCamposInd,"A1_COD") // Por Cliente
ENDIF

IF TArquivo == GERAL_PO
   aAreaComp[1]:="SW2"        // Por P.O
   aCamposInd[1]:="W2_PO_NUM"   // Por P.O
ENDIF

DBSELECTAREA("SW0")
cAlias:=ALIAS()
IF Posicione("SX2",1,"SW0","X2_MODO") == "E"
   lBrowseFil:=.T.
ENDIF
DBSELECTAREA(cAlias)

DBSELECTAREA(aAreaComp[TIndice])
cAlias:=ALIAS()
If Posicione("SX2",1,cAlias,"X2_MODO") == "C" .OR. ! lBrowseFil   // verifica se SY3 - CC é exclusivo ou compartilhado??  -- RS 11/01/06
   //TDF - 07/02/11 - Acrescenta retorno do IP150GET para filtro no aMarcados
   AAdd(aMarcados, {cFilAnt, IP150GET(IF(TArquivo==GERAL_PO,9,TIndice),,aTArq,Titulo,@lCancel)})        //  se compartilhado da get normal.
   DBSELECTAREA(cAlias)
   IF(!lCancel,IP150Processa(aMarcados),)     // lCancel==.T., usuario fechou janela  - RS 12/01/06
   RETURN .T.
Endif
DBSELECTAREA(cAlias)

bCampoI:={||IF(TArquivo==GERAL.AND.TIndice==C_CUSTO,IP150VERMARCA(WorkFil->W0__CC,WorkFil->Y3_COD),IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",STR0004,WorkFil->(FIELDGET(FIELDPOS(ccpo)))))}
bCampoF:={||IF(TArquivo==GERAL.AND.TIndice==C_CUSTO,IP150VERMARCA(WorkFil->Y3_COD),IF(LEFT(WorkFil->Y3_COD,1)=="*",STR0004,WorkFil->Y3_COD))}   // STR0004 = "TODOS"

IF TArquivo == GERAL_PO
   bCampoI:={||IP150VERPOMARCA(WorkFil->W2_PO_NUM,WorkFil->W3_PO_NUM)}
   bCampoF:={||IP150VERPOMARCA(WorkFil->W3_PO_NUM)}
ENDIF

ccpo:=aCamposInd[TIndice]

aTB_Campos:={{bCampoI,"",AVSX3(ccpo,5) 	} }
            
aDBF:= { {ccpo,AVSX3(ccpo,2),AVSX3(ccpo,3),AVSX3(ccpo,4)} }
bMarca:={||lCancel:=.F.,(TCod:=IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",SPACE(AVSX3(ccpo,3)),WorkFil->(FIELDGET(FIELDPOS(ccpo)))),IF(EMPTY(WorkFil->WKMARCA),aRetGET:=IP150GET(IF(TArquivo==GERAL_PO,9,TIndice),,aTArq,Titulo,@lCancel,WorkFil->WKFILIAL),.T.)),IP150ATUWorkFil(aRetMarcados,aRetGET[1],aRetGET[2],lCancel),.T.}

aRetMarcados:={ccpo}

ccPo2:=IF(TArquivo==GERAL .AND. TIndice==C_CUSTO,"Y3_COD","W3_PO_NUM")

IF (TArquivo == GERAL  .AND. TIndice == C_CUSTO)   .OR.  TArquivo == GERAL_PO
   aSize(aTB_Campos,len(aTB_Campos)+1)
   aSize(aDBF,len(aDBF)+1)
   aIns(aDBF,2)
   aIns(aTB_Campos,2)
   
   aTB_Campos[2]:= { bCampoF,"",STR0098 }
   
   aTB_Campos[1][3]:=STR0097
   
   aDBF[2]:={ccpo2,AVSX3(ccpo2,2),AVSX3(ccpo2,3),AVSX3(ccpo2,4)}      
   AADD(aRetMarcados,ccpo2)
ENDIF

aMarcados:=AvgMBrowseFil("",IF(TArquivo==GERAL_PO,STR0011,aTArq[TIndice]),aFilSel,aTb_Campos,"",aDBF,bMarca,aRetMarcados)        

        
IF !EMPTY(aMarcados)
   IP150Processa(aMarcados)
ENDIF

RETURN .T.

*-----------------------*
FUNCTION IP150VERPOMARCA(cCampo) 
*-----------------------*
IF LEFT(WorkFil->W2_PO_NUM,1)=="*"  .AND. LEFT(WorkFil->W3_PO_NUM,1) == "*"   
   RETURN STR0004   // "TODOS"
ENDIF

IF LEFT(WorkFil->W2_PO_NUM,1)=="*" .AND.  LEFT(WorkFil->W3_PO_NUM,1) <> "*"
   WorkFil->W2_PO_NUM:="" 
   cCampo:=""
ENDIF

IF LEFT(WorkFil->W3_PO_NUM,1) == "*"  .AND. LEFT(WorkFil->W2_PO_NUM,1)<>"*"
   WorkFil->W3_PO_NUM:=""
ENDIF
     
RETURN cCampo




*-----------------------*
FUNCTION IP150VERMARCA(cCampo) 
*-----------------------*
IF TIndice <> C_CUSTO
   RETURN 
ENDIF

IF LEFT(WorkFil->W0__CC,1)=="*"  .AND. LEFT(WorkFil->Y3_COD,1) == "*"   
   RETURN "STR0004"
ENDIF

IF LEFT(WorkFil->W0__CC,1)=="*" .AND.  LEFT(WorkFil->Y3_COD,1) <> "*"
   WorkFil->W0__CC:="" 
   cCampo:=""
ENDIF

IF LEFT(WorkFil->Y3_COD,1) == "*"  .AND. LEFT(WorkFil->W0__CC,1)<>"*"
   WorkFil->Y3_COD:=""
ENDIF
     
RETURN cCampo

*--------------------*
FUNCTION IP150Marca(TCod) 
*--------------------*
lCancel:=.F.
TCod:=IF(LEFT(WorkFil->W0__CC,1)=="*",SPACE(LEN(WorkFil->W0__CC)),WorkFil->W0__CC)

IF EMPTY(WorkFil->WKMARCA)
   IP150GET(TIndice,,,Titulo,@lCancel)
ENDIF

IP150ATUWorkFil(aRetMarcados,TCCustoI,,lCancel)
RETURN .T.

*-------------------------------------*
FUNCTION IP150ATUWorkFil(aRetMarcados,TCodI,TCodF,lCancel)
*-------------------------------------*
LOCAL nI, xCampo, xPos

IF lCancel  // Clicou no botao cancelar da janel do get ???  - RS 12/01/06
   RETURN .T.                      
ENDIF

WorkFil->WKMARCA:=IF(EMPTY(WorkFil->WKMARCA),cMarca,SPACE(02))

FOR nI:=1 TO LEN(aRetMarcados)
    xCampo:=aRetMarcados[nI]
    xPos:=WorkFil->(FIELDPOS(xCampo))    
    IF EMPTY(WorkFil->WKMARCA)
       WorkFil->(FIELDPUT(xPos,SPACE(LEN(WORKFIL->(FIELDGET(FIELDPOS(xCampo))))))) 
       LOOP
    ENDIF
    WorkFil->(FIELDPUT(xPos,IF(EMPTY(TCodI),"*Todos",TCodI)))
    
    IF TCodF <> NIL .AND. nI # 1
       WorkFil->(FIELDPUT(xPos,IF(EMPTY(TCodF),"*Todos",TCodF)))
    ENDIF
NEXT
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION IP150GET(TIndice,oDlgOpc,aTab,Titulo,lCancel,cFil)
*----------------------------------------------------------------------------
LOCAL cArqF3, cSvFilAnt:=cFilAnt, cCampoF3 := ""

LOCAL oDlg1, oGetCod, oSayCod, cTexto:=STR0093, cPict:="",TCod , cOldArea:=ALIAS(), TCodF, nOrdSX3:=SX3->(INDEXORD()) //"C¢digo:"
LOCAL aOrder:={STR0094 ,; //"1- P.O.           "
               STR0095 ,; //"2- Dt.Necessidade "
               STR0096 }

LOCAL nCol:=IF((TArquivo==GERAL.AND.TIndice==C_CUSTO).OR.TArquivo==GERAL_PO,50,45) //"3- Status         "

Local cPic := ""


IF TIndice == 0 .AND. TArquivo <> GERAL_PO    // Coloquei porque o evento on click do radio-button
   RETURN NIL                                 // e chamado antes do controle aparecer na tela.
ENDIF

IF(TArquivo==GERAL_PO,TIndice:=9,)
IF((TArquivo==GERAL.AND.TIndice==C_CUSTO).OR.TArquivo==GERAL_PO,cTexto:=STR0097,) //"C¢digo Inicial "
IF(Titulo==NIL,Titulo:=aTab[TIndice],)
//oDlg:disable()
DO CASE

   CASE TArquivo == GERAL_PO
//        SW2->(DBSEEK(xFilial()))
//        TCod:=SW2->W2_PO_NUM

        TCod:=E_TRAN("W2_PO_NUM","SW2")
        TCodF:=TCod
        TIndice:=0
        cPict:=_PictPO
        cArqF3:="SW2" ; cCampoF3:="W2_PO_NUM"
   CASE TIndice == C_CUSTO
        SX3->(DBSETORDER(2))
        TCod:=E_TRAN("Y3_COD","SY3")
        TCodF:=TCod
        cArqF3:="SY3" ; cCampoF3:="Y3_COD"
        cTexto:= "Unid Req. " //LAM - 12/10/06
   CASE TIndice == COMPRADOR    ;  TCod:=E_TRAN("Y1_COD","SY1")
        cArqF3:="SY1" ; cCampoF3:="Y1_COD"
        cTexto:= "Comprador " //LAM - 12/10/06
   CASE TIndice == CLIENTE      ;  TCod:=E_TRAN("A1_COD","SA1")
        cArqF3:="SA1" ; cCampoF3:="A1_COD"
        cTexto:= "Cliente " //LAM - 12/10/06
   CASE TIndice == FORNECEDOR   ;  TCod:=E_TRAN("A2_COD","SA2")
        cArqF3:="SA2" ; cCampoF3:="A2_COD"
        cTexto:= "Fornecedor " //LAM - 12/10/06
   CASE TIndice == DESPACHANTE  ;  TCod:=E_TRAN("Y5_COD","SY5")
        cArqF3:="SY5" ; cCampoF3:="Y5_COD"
        cTexto:= "Despachante " //LAM - 12/10/06
ENDCASE
cPict:=ALLTRIM(SX3->X3_PICTURE)
SX3->(DBSETORDER(nOrdSX3))
IF(TArquivo==GERAL_PO,cPict:=_PictPO,)

DBSELECTAREA(cArqF3)

IF cFil <> NIL .AND. Posicione("SX2",1,cArqF3,"X2_MODO") == "E"   
   cFilAnt:=cFil
ENDIF

DBSELECTAREA(cArqF3)

DEFINE MSDIALOG oDlg1 TITLE Titulo From 15,35 To 23,70  OF oMainWnd

@ 13,10 SAY oSayCod VAR cTexto SIZE 45,10 OF oDlg1 PIXEL
//@ 13,nCol MSGET TCod F3 cArqF3 Picture cPict SIZE IF(TArquivo<>GERAL_PO,40,50),9 VALID ExistCpo(cArqF3,AVKEY(TCod,"W2_PO_NUM")) OF oDlg1 PIXEL //TDF - 28/01/11
//DFS - 11/05/11 - Retirado valid dos GETS para poder deixar em branco o período do filtro
@ 13,nCol MSGET TCod F3 cArqF3 Picture cPict SIZE IF(TArquivo<>GERAL_PO,40,50),9 /*VALID ExistCpo(cArqF3,AVKEY(TCod,cCampoF3))*/ OF oDlg1 PIXEL //TDF - 28/01/11

IF (TArquivo == GERAL  .AND. TIndice == C_CUSTO) .OR. TArquivo == GERAL_PO
   TCodF:=TCod
   cTexto2:=STR0098 //"C¢digo Final"
   @ 27,15 SAY oSayCod VAR cTexto2 SIZE 40,10 OF oDlg1 PIXEL
   //DFS - 11/05/11 - Retirado valid dos GETS para poder deixar em branco o período do filtro  
   @ 27,nCol MSGET TCodF F3 cArqF3 Picture cPict SIZE IF(TArquivo<>GERAL_PO,40,50),9 /*VALID ExistCpo(cArqF3,AVKEY(TCodF,cCampoF3))*/ OF oDlg1 PIXEL //TDF - 28/01/11
ENDIF

//DEFINE SBUTTON FROM 13,100 TYPE 1 ACTION (IF(IP150VERGET(TIndice,TCod,TCodF),(oDlg1:End()),))  ENABLE OF oDlg1
DEFINE SBUTTON FROM 13,100 TYPE 1 ACTION (oDlg1:End())              ENABLE OF oDlg1
DEFINE SBUTTON FROM 27,100 TYPE 2 ACTION (lCancel:=.T.,oDlg1:End()) ENABLE OF oDlg1

ACTIVATE MSDIALOG oDlg1 CENTERED

lCancelDlg :=lCancel    //igorchiba 17/27/2010 se usuario ter cancelar na tela customizada de fabricante entao cancelar processo
IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"POSOPCAO"),)//igorchiba 17/27/2010
lCancel    := lCancelDlg 

cFilAnt:=cSvFilAnt
RETURN {TCod,TCodF}

/* TDF - 28/01/2011 - NÃO HÁ NECESSIDADE DESTAS VALIDAÇÕES,PARTINDO DO PRÍNCIPIO QUE ESTAS INFORMAÇÕES SEMPRE SÃO PREENCHIDAS.
*----------------------------------------------------------------------------
FUNCTION IP150VERGET(TIndice,TCod,TCodF)
*----------------------------------------------------------------------------
DO CASE
   CASE TIndice == C_CUSTO
        TCCusto:=TCod
        TCCustoI:=TCod
        TCCustoF:=TCodF
        IF ! EMPTY(TCCusto) .AND. ! SY3->(DBSEEK(xFilial()+TCCUSTO))
           Help("",1,"AVG0001045") //"Unidade requisitante nÆo cadastrada"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF TArquivo == GERAL
           IF ! EMPTY(TCCustoF) .AND. ! SY3->(DBSEEK(xFilial()+TCCUSTOF))
              Help("",1,"AVG0001045") //"Unidade requisitante nÆo cadastrada"###"Informa‡Æo"
              RETURN .F.
           ENDIF
        ENDIF   
     
   CASE TIndice == COMPRADOR
        TComprador:=TCod
        IF ! EMPTY(VAL(TComprador)) .AND. ! SY1->(DBSEEK(xFilial()+TComprador))
           Help("",1,"AVG0001046") //"Comprador nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF

   CASE TIndice == CLIENTE
        TCliente:=TCod
        IF ! EMPTY(TCliente) .AND. ! SA1->(DBSEEK(xFilial()+TCliente))
           Help("",1,"AVG0001047") //"Cliente nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF
        TCliente:=TCod
   CASE TIndice == FORNECEDOR
        TFornec1:=TCod
        IF ! EMPTY(TFornec1) .AND. ! SA2->(DBSEEK(xFilial()+AvKey(TFornec1,"A2_COD")))
           Help("",1,"AVG0001048") //"Fornecedor nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF
        MTemForn:= IF( EMPTY(TFornec1) , .F. , .T. )
   CASE TIndice == DESPACHANTE
        TDespachante:=TCod
        IF ! EMPTY(TDespachante) .AND. ! SY5->(DBSEEK(xFilial()+TDespachante))
           Help("",1,"AVG0001049") //"Despachante nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF
   CASE TArquivo == GERAL_PO
        TNr_POI:=TCod
        TNr_POF:=TCodF
        IF ! EMPTY( TNr_POI ) .AND. ! SW2->(DBSEEK(xFilial()+TNr_POI))
           Help("",1,"AVG0001050") //"P.O. nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        IF ! EMPTY( TNr_POF ) .AND. ! SW2->(DBSEEK(xFilial()+TNr_POF))
           Help("",1,"AVG0001050") //"P.O. nÆo cadastrado"###"Informa‡Æo"
           RETURN .F.
        ENDIF
ENDCASE
RETURN .T. */

*-------------------------------*
FUNCTION SaldoEnt()  && FUNCAO USADA NO GERADOR DE RELATORIO RJB 10:59 11 Apr,1996
*-------------------------------*  NO ARQUIVO ROR000
RETURN MQtde

*------------------------------*
FUNCTION MontaCampos(TIndice)  //jwj - por as definições de TRCell nesta função
*------------------------------*

Private aSemSX3:={ {"WKFILIAL"  ,"C",AVSX3("W2_FILIAL",3),0},;//igorchiba 17/27/2010 novos campos
                 {"WKVALOR"   ,"N",15,2},;
                 {"W0__DT"    ,"D",08,0},;
                 {"W2_DT_ALTE","D",08,0},;
                 {"WK_DTEMB"   ,"D",08,0},;
                 {"W3_POSICAO","C",LEN(SW3->W3_POSICAO),0},;
                 {"YQ_DESCR"  ,"C",05,0},;
                 {"XX_FLAGWIN","C",02,0} }

Private aCposNewStru := {}//igorchiba 17/27/2010


aCampos := {}
// JBS - 19/09/2003  - Estes ja foram informados acima.
IF TOrder <> 2  // Data de Necessidade   
   AADD(aSemSX3,{"W1_DTENTR_","D",08,0})                 
ENDIF   
/*
IF TOrder <> 3  // Status
   AADD(aSemSX3,{"WKOBS"     ,"C",33,0})
ENDIF
*/
   AADD(aSemSX3,{"WKOBS"     ,"C",/*33*/80,0})
// FIM
AADD(aSemSX3,{"W3_PRECO"  ,"N",AvSX3("W3_PRECO",3),AvSX3("W3_PRECO",4)})   //TRP-16/09/08

DO CASE
   CASE  TIndice = C_CUSTO 
         aCampos:={}  // JBS - 16/05/2003
         IF TArquivo == 1     // S.I.
            AADD(aCampos,"W1_CC")   
            AADD(aCampos,"W1_SI_NUM") 
            AADD(aCampos,"W1_FORN")
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf 
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W0_COMPRA") 
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf  
            AADD(aSemSX3,{"W1_PO_NUM" ,"C", AVSX3("W1_PO_NUM",3) ,AVSX3("W1_PO_NUM",4)})
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
            AADD(aSemSX3,{"W6_HAWB"   ,"C", AVSX3("W6_HAWB",3)   ,AVSX3("W6_HAWB",4)})
         ELSEIF TArquivo == 2 // Mostra PO
            AADD(aCampos,"W1_PO_NUM")   
            AADD(aCampos,"W1_FORN") 
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf 
            AADD(aCampos,"W1_CC") 
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W0_COMPRA") 
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf  
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
            AADD(aSemSX3,{"W6_HAWB"   ,"C", AVSX3("W6_HAWB",3)   ,AVSX3("W6_HAWB",4)})
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         ELSEIF TArquivo == 3 // L.I.
            AADD(aCampos,"W3_PGI_NUM")   
            AADD(aCampos,"W1_PO_NUM")   
            AADD(aCampos,"W1_CC") 
            IF TOrder == 2  // Data de Necessidade
               AADD(aCampos,"W1_DTENTR_")
            ELSEIF TOrder == 3  // Status
               AADD(aCampos,"WKOBS")
            ENDIF
            AADD(aCampos,"W1_FORN")
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf  
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W0_COMPRA") 
            AADD(aCampos,"W2_CLIENTE") 
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf 
            AADD(aSemSX3,{"W6_HAWB"  ,"C",AVSX3("W6_HAWB",3)  ,AVSX3("W6_HAWB",4)})
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         ELSEIF TArquivo == 4 // HAWB
            AADD(aCampos,"W6_HAWB")   
            AADD(aCampos,"W1_PO_NUM") 
            AADD(aCampos,"W1_CC") 
            IF TOrder == 2  // Data de Necessidade
               AADD(aCampos,"W1_DTENTR_")
            ELSEIF TOrder == 3  // Status
               AADD(aCampos,"WKOBS")
            ENDIF
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W0_COMPRA") 
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf  
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
            AADD(aSemSX3,{"W1_FORN","C", AVSX3("W1_FORN",3),AVSX3("W1_FORN",4)})
            If EICLoja()
               AADD(aSemSX3,{"W1_FORLOJ","C", AVSX3("W1_FORLOJ",3),AVSX3("W1_FORLOJ",4)})
            EndIf 
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         ELSEIF TArquivo > 4    
            AADD(aCampos,"W6_HAWB")   
            AADD(aCampos,"W1_PO_NUM") 
            AADD(aCampos,"W1_CC") 
            IF TOrder == 2  // Data de Necessidade
               AADD(aCampos,"W1_DTENTR_")
            ELSEIF TOrder == 3  // Status
               AADD(aCampos,"WKOBS")
            ENDIF
            AADD(aCampos,"W1_FORN")
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf    
            AADD(aCampos,"A2_NREDUZ")                      
            AADD(aCampos,"W0_COMPRA")                      
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf 
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
         ENDIF
         AADD(aSemSX3,{"W6_DESP"   ,"C", AVSX3("W6_DESP",3)   ,AVSX3("W6_DESP",4)})

   CASE TIndice  = COMPRADOR
         aCampos:={}  // JBS - 16/05/2003
         IF TArquivo == 1     // S.I.
            AADD(aCampos,"W1_CC")   
            AADD(aCampos,"W1_SI_NUM") 
            AADD(aCampos,"W0_COMPRA") 
            AADD(aCampos,"W1_FORN")
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf  
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf  
            AADD(aSemSX3,{"W1_PO_NUM" ,"C", AVSX3("W1_PO_NUM",3) ,AVSX3("W1_PO_NUM",4)})
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
            AADD(aSemSX3,{"W6_HAWB"   ,"C", AVSX3("W6_HAWB",3)   ,AVSX3("W6_HAWB",4)})
         ELSEIF TArquivo == 2 // Mostra PO
            AADD(aCampos,"W1_PO_NUM")   
            AADD(aCampos,"W0_COMPRA") 
            AADD(aCampos,"W1_FORN")
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf 
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf  
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
            AADD(aSemSX3,{"W6_HAWB"   ,"C", AVSX3("W6_HAWB",3)   ,AVSX3("W6_HAWB",4)})
            AADD(aSemSX3,{"W1_CC","C",AVSX3("W1_CC",3),AVSX3("W1_CC",4)})
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         ELSEIF TArquivo == 3 // L.I.
            AADD(aCampos,"W3_PGI_NUM")   
            AADD(aCampos,"W1_PO_NUM")   
            AADD(aCampos,"W0_COMPRA") 
            IF TOrder == 2  // Data de Necessidade
               AADD(aCampos,"W1_DTENTR_")
            ELSEIF TOrder == 3  // Status
               AADD(aCampos,"WKOBS")
            ENDIF
            AADD(aCampos,"W1_FORN") 
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf 
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf  
            AADD(aSemSX3,{"W6_HAWB"  ,"C",AVSX3("W6_HAWB",3)  ,AVSX3("W6_HAWB",4)})
            AADD(aSemSX3,{"W1_CC"    ,"C",AVSX3("W1_CC",3)    ,AVSX3("W1_CC",4)})
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         ELSEIF TArquivo == 4 // HAWB
            AADD(aCampos,"W6_HAWB")   
            AADD(aCampos,"W1_PO_NUM") 
            AADD(aCampos,"W0_COMPRA") 
            IF TOrder == 2  // Data de Necessidade
               AADD(aCampos,"W1_DTENTR_")
            ELSEIF TOrder == 3  // Status
               AADD(aCampos,"WKOBS")
            ENDIF
            AADD(aCampos,"A2_NREDUZ") 
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf  
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
            AADD(aSemSX3,{"W1_FORN","C", AVSX3("W1_FORN",3),AVSX3("W1_FORN",4)})
            If EICLoja()
               AADD(aSemSX3,{"W1_FORLOJ","C",AVSX3("W1_FORLOJ",3),AVSX3("W1_FORLOJ",4)})
            EndIf 
            AADD(aSemSX3,{"W1_CC","C",AVSX3("W1_CC",3),AVSX3("W1_CC",4)})
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         ELSEIF TArquivo > 4    
            AADD(aCampos,"W6_HAWB")   
            AADD(aCampos,"W1_PO_NUM") 
            AADD(aCampos,"W0_COMPRA") 
            IF TOrder == 2  // Data de Necessidade
               AADD(aCampos,"W1_DTENTR_")
            ELSEIF TOrder == 3  // Status
               AADD(aCampos,"WKOBS")
            ENDIF
            AADD(aCampos,"W1_FORN") 
            If EICLoja()
               AADD(aCampos,"W1_FORLOJ")
            EndIf   
            AADD(aCampos,"A2_NREDUZ")                      
            AADD(aCampos,"W2_CLIENTE")
            If EICLoja()
               AADD(aCampos,"W2_CLILOJ")
            EndIf 
            AADD(aSemSX3,{"W1_CC","C",AVSX3("W1_CC",3),AVSX3("W1_CC",4)})
            AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
         ENDIF
         AADD(aSemSX3,{"W6_DESP"   ,"C", AVSX3("W6_DESP",3)   ,AVSX3("W6_DESP",4)})

   CASE  (TIndice = 3 .AND. (TArquivo = 2 .OR. TArquivo = 3)) .OR. TIndice = 4
         aCampos:={}
         IF TArquivo = 3  
            AADD(aCampos,"W3_PGI_NUM")   
            AADD(aCampos,"W1_PO_NUM")   
         ELSE   
            AADD(aCampos,"W1_PO_NUM")   
            AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
         ENDIF        
         IF TOrder == 2 .and.TArquivo <> 2  // Data de Necessidade
            AADD(aCampos,"W1_DTENTR_")
         ELSEIF TOrder == 3 .and.TArquivo <> 2 // Status
            AADD(aCampos,"WKOBS")
         ENDIF
         AADD(aCampos,"W2_CLIENTE") 
         If EICLoja()
            AADD(aCampos,"W2_CLILOJ")
         EndIf 
         AADD(aCampos,"W0_COMPRA") 
         AADD(aCampos,"W1_FORN")
         If EICLoja()
            AADD(aCampos,"W1_FORLOJ")
         EndIf
         AADD(aCampos,"A2_NREDUZ") 
         AADD(aSemSX3,{"W1_CC","C",AVSX3("W1_CC",3),AVSX3("W1_CC",4)})
         AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         AADD(aSemSX3,{"W6_DESP","C",AVSX3("W6_DESP",3),AVSX3("W6_DESP",4)})
         AADD(aSemSX3,{"W6_HAWB"   ,"C", AVSX3("W6_HAWB",3)   ,AVSX3("W6_HAWB",4)})
           
   CASE  TIndice = 3 .AND. TArquivo = 4    // D.I. -> Despachante
         aCampos:={}
         AADD(aCampos,"W6_HAWB")
         AADD(aCampos,"W1_PO_NUM")
         IF TOrder == 2  // Data de Necessidade
            AADD(aCampos,"W1_DTENTR_")
         ELSEIF TOrder == 3  // Status
            AADD(aCampos,"WKOBS")
         ENDIF
         AADD(aCampos,"W0_COMPRA")
         AADD(aCampos,"A2_NREDUZ")
         AADD(aCampos,"W6_DESP")
         AADD(aSemSX3,{"W1_CC","C",AVSX3("W1_CC",3),AVSX3("W1_CC",4)})
         AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         AADD(aSemSX3,{"W1_FORN","C",AVSX3("W1_FORN",3),AVSX3("W1_FORN",4)})
         If EICLoja()
            AADD(aSemSX3,{"W1_FORLOJ","C",AVSX3("W1_FORLOJ",3),AVSX3("W1_FORLOJ",4)})
         EndIf 
         AADD(aSemSX3,{"W2_CLIENTE","C",AVSX3("W2_CLIENTE",3),AVSX3("W2_CLIENTE",4)})
         If EICLoja()
            AADD(aSemSX3,{"W2_CLILOJ","C",AVSX3("W2_CLILOJ",3),AVSX3("W2_CLILOJ",4)})
         EndIf 
         AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})

   CASE  TIndice = 3 .AND. TArquivo = GERAL  // Geral -> Fornecedor
         aCampos:={}
         AADD(aCampos,"W1_FORN")
         If EICLoja()
            AADD(aCampos,"W1_FORLOJ")
         EndIf
         AADD(aCampos,"A2_NREDUZ")
         AADD(aCampos,"W1_PO_NUM")
         IF TOrder == 2  // Data de Necessidade
            AADD(aCampos,"W1_DTENTR_")
         ELSEIF TOrder == 3  // Status
            AADD(aCampos,"WKOBS")
         ENDIF
         AADD(aCampos,"W0_COMPRA")
         AADD(aCampos,"W2_CLIENTE") 
         If EICLoja()
            AADD(aCampos,"W2_CLILOJ")
         EndIf
         AADD(aSemSX3,{"W1_CC","C",AVSX3("W1_CC",3),AVSX3("W1_CC",4)})
         AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         AADD(aSemSX3,{"W6_DESP","C",AVSX3("W6_DESP",3),AVSX3("W6_DESP",4)})
         AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
         AADD(aSemSX3,{"W6_HAWB"  ,"C",AVSX3("W6_HAWB",3)  ,AVSX3("W6_HAWB",4)})
                      
   CASE  TIndice = 0
         aCampos:={}
         AADD(aCampos,"W1_FORN")
         If EICLoja()
            AADD(aCampos,"W1_FORLOJ")
         EndIf
         AADD(aCampos,"A2_NREDUZ")
         AADD(aCampos,"W1_PO_NUM")
         IF TOrder == 2  // Data de Necessidade
            AADD(aCampos,"W1_DTENTR_")
         ELSEIF TOrder == 3  // Status
            AADD(aCampos,"WKOBS")
         ENDIF
         AADD(aCampos,"W0_COMPRA")
         AADD(aCampos,"W2_CLIENTE")
         If EICLoja()
            AADD(aCampos,"W2_CLILOJ")
         EndIf
         AADD(aSemSX3,{"W1_CC","C",AVSX3("W1_CC",3),AVSX3("W1_CC",4)})
         AADD(aSemSX3,{"W1_SI_NUM","C",AVSX3("W1_SI_NUM",3),AVSX3("W1_SI_NUM",4)})
         AADD(aSemSX3,{"W6_DESP"   ,"C",AVSX3("W6_DESP",3),AVSX3("W6_DESP",4)})
         AADD(aSemSX3,{"W3_PGI_NUM","C", AVSX3("W3_PGI_NUM",3),AVSX3("W3_PGI_NUM",4)})
         AADD(aSemSX3,{"W6_HAWB"   ,"C",AVSX3("W6_HAWB",3)  ,AVSX3("W6_HAWB",4)})
         
         CASE TIndice == 5
            IF TArquivo == DESEMB_PENDENTE
                  aCampos := {}//ACB 26/08/2010 - Melhoria filtro por fornecedor
                  AADD(aCampos,"W1_FORN") //ACB 26/08/2010 - Melhoria filtro por fornecedor
                  //TRP - 28/07/2011 - Adicionado campo Loja.
                  If EICLoja()
                     AADD(aCampos,"W1_FORLOJ")
                  EndIf
                  //TRP - 05/09/2012 - Adicionado o campo W1_DTENTR_ na TRB pois o mesmo é utilizado no IndRegua.
                  If TOrder == 2  // Data de Necessidade
                     AADD(aCampos,"W1_DTENTR_")
                  Endif
                  AADD(aCampos,"W1_PO_NUM")//ACB 26/08/2010 - Melhoria filtro por fornecedor
                  AADD(aCampos,"W1_CC")//ACB 26/08/2010 - Melhoria filtro por fornecedor
                  AADD(aCampos,"W1_SI_NUM")//ACB 26/08/2010 - Melhoria filtro por fornecedor
            ENDIF            
            AADD(aSemSX3,{"W6_HAWB"   ,"C", AVSX3("W6_HAWB",3)   ,AVSX3("W6_HAWB",4)})

ENDCASE
                                                                               
//DFS - 18/08/10 - Criação de campo para receber a previsão calculada da data de entrega de acordo com o cálculo da variável MWData 
AADD(aSemSX3,{"WK_DT_PREC","D",AVSX3("W3_DT_ENTR",3),AVSX3("W3_DT_ENTR",4)})

//LGS-25/07/14
AADD(aSemSX3,{"W0__DT"    ,"D",AVSX3("W3_DT_ENTR",3),AVSX3("W3_DT_ENTR",4)})
AADD(aSemSX3,{"W2_DT_ALTE","D",AVSX3("W3_DT_ENTR",3),AVSX3("W3_DT_ENTR",4)})
AADD(aSemSX3,{"W1_DTENTR_","D",AVSX3("W3_DT_ENTR",3),AVSX3("W3_DT_ENTR",4)}) 

AADD(aCampos,"W1_COD_I")
AADD(aCampos,"W1_REG")
AADD(aCampos,"W1_SEQ")
AADD(aCampos,"B1_DESC" )
AADD(aCampos,"A5_CODPRF")
AADD(aCampos,"W1_QTDE")
//AADD(aCampos,"W3_PRECO")
AADD(aCampos,"WK_DTEMB")
AADD(aCampos,"W3_DT_ENTR")

IF(lExisteRD,ExecBlock("ICPAD150",.F.,.F.,"1"),) //AWR 08/06/1999

//****TDF-21/07/11 - Quando utiliza TReport o tamanho é com base no campo B1_DESC, quando não utiliza o tamanho padrão é 20
If LR4
   nTamDesc:=AVSX3("B1_DESC",3) 
Else
   nTamDesc:= 20
EndIf
aAdd(aCposNewStru, {"B1_DESC", "C", nTamDesc, 0})
aAdd(aCposNewStru, {"WKOBS", "C", /*20*/35, 0}) // GFP - 18/07/2013
//******

IF(EasyEntryPoint("EICIP150"),Execblock("EICIP150",.F.,.F.,"SEMSX3"),)//igorchiba 17/27/2010 novos campos

cNomArq:=E_CriaTrab(,aSemSX3,,,, aCposNewStru)

//DFS - 18/08/10 - Adicionado campo para Previsão de Entrega Calculada
AADD(aCampos,"WK_DT_PREC")
AADD(aCampos,"WKVALOR")
AADD(aCampos,"W0__DT")
AADD(aCampos,"W2_DT_ALTE")               
// JBS - 19/09/2003  - Estes ja foram informados acima.
IF TOrder <> 2  // Data de Necessidade   
   AADD(aCampos,"W1_DTENTR_")
ENDIF   
IF TOrder <> 3  // Status
   AADD(aCampos,"WKOBS")
ENDIF
// FIM
AADD(aCampos,"YQ_DESCR")

nPosH:=ASCAN(aHeader,{|Campo|Campo[2]=="W1_DTENTR_"})
IF nPosH > 0
   aHeader[nPosH,1] := STR0109
ELSE
   AADD(aHeader,{STR0109,"W1_DTENTR_","@D",08,0," ","   ","D",," "}) //"Necessidade"
ENDIF
AADD(aHeader,{STR0106                  ,"WKVALOR"   ,"@E 999,999,999.99",12,2," ","   ","N",," "}) //"Vlr FOB Total"
AADD(aHeader,{AvSX3("W0__DT",AV_TITULO),"W0__DT"    ,"@D"               ,08,0," ","   ","D",," "}) //"Data da S.I."
AADD(aHeader,{STR0108                  ,"W2_DT_ALTE","@D"               ,08,0," ","   ","D",," "}) //"Dt. Preco I/A"
AADD(aHeader,{STR0110                  ,"W3_DT_ENTR","@D"               ,08,0," ","   ","D",," "}) //"Entrega"
//DFS - 18/08/10 - Adicionado campo para Previsão de Entrega Calculada
AADD(aHeader,{"Entrega Calc"                  ,"WK_DT_PREC","@D"               ,08,0," ","   ","D",," "}) //"Entrega Calc."
AADD(aHeader,{STR0111                  ,"WKOBS"     ,"@!"               ,80,0," ","   ","C",," "}) //"Status"
AADD(aHeader,{STR0114                  ,"YQ_DESCR"  ,"@!"               ,5 ,0," ","   ","C",," "}) //"Via"          
AADD(aHeader,{STR0112                  ,"WK_DTEMB"  ,"@D"               ,08,0," ","   ","D",," "}) //"Embarque"
RETURN NIL
*-------------------------------------*
FUNCTION IP150SX14(cParam1,cParam2)
*-------------------------------------*
LOCAL cCodigoI:=cCodigoF:=cTexto:=""
// Funcao para gravar,recuperar dados  no SX1 ou SX4,conforme parametros passados
// cParam1:=Alias
// cParam2:=Retorna Codigo Inicial ou Final

DO CASE
   CASE cParam1="SX1"
      IF TIndice == C_CUSTO
         cCodigoI:=TCCusto
         cCodigoF:=TCCustoF
      ELSEIF TIndice == COMPRADOR
         cCodigoI:=TComprador   
      ELSEIF TIndice == CLIENTE
         cCodigoI:=TCliente
      ELSEIF TIndice == FORNECEDOR
         cCodigoI:=TFornec1
      ELSEIF TIndice == DESPACHANTE
         cCodigoI:=TDespachante
      ELSEIF TArquivo == GERAL_PO
         cCodigoI:=TNr_POI
         cCodigoF:=TNr_POF
      ENDIF
   
      IF cParam2=="INICIAL"
         RETURN cCodigoI
      ELSE
         RETURN cCodigoF
      ENDIF   
      
   CASE cParam1="SX4"
      IF cParam2=="GRAVAR"
         IF SX1->(DBSEEK("EIP150"))   
            DO WHILE SX1->(!EOF()) .AND. SX1->X1_GRUPO=="EIP150"
               cTexto+=UPPER(ALLTRIM(SX1->X1_VAR01))+SPACE(2)+SX1->X1_TIPO+SPACE(2)+;
               ALLTRIM(SX1->X1_CNT01)+"&#"+CHR(13)+CHR(10)
               SX1->(DBSKIP())
            ENDDO
         ENDIF
      
         IF SX4->(RECLOCK("SX4",.F.))
            SX4->X4_CONFIG:=cTexto
            SX4->(MSUNLOCK())
         ENDIF
      ELSE //RECUPERAR
         TArquivo:=mv_par01
         TIndice :=mv_par02
         TOrder  :=mv_par03
         IF TIndice == C_CUSTO
            TCCusto :=mv_par04+SPACE( AVSX3("Y3_COD",3) -LEN(mv_par04) )
            TCCustoF:=mv_par05+SPACE( AVSX3("Y3_COD",3) -LEN(mv_par05) )
         ELSEIF TIndice == COMPRADOR
            TComprador:=mv_par04+SPACE( AVSX3("Y1_COD",3) -LEN(mv_par04) )
         ELSEIF TIndice == CLIENTE 
            TCliente:=mv_par04+SPACE( AVSX3("A1_COD",3) -LEN(mv_par04) )
         ELSEIF TIndice == FORNECEDOR
            TFornec1:=mv_par04+SPACE( AVSX3("A2_COD",3) -LEN(mv_par04) )
         ELSEIF TIndice == DESPACHANTE
            TDespachante:=mv_par04+SPACE( AVSX3("Y5_COD",3) -LEN(mv_par04) )
         ELSEIF TArquivo == GERAL_PO
            TNr_POI:=mv_par04+SPACE( AVSX3("W2_PO_NUM",3) -LEN(mv_par04) )
            TNr_POF:=mv_par05+SPACE( AVSX3("W2_PO_NUM",3) -LEN(mv_par05) )
         ENDIF
      ENDIF
ENDCASE              


RETURN .T.

*----------------------------*
FUNCTION EICIP150QuebraFil()
*-----------------------------*
IF FilAtu == "*" 
   PulaLinha()
   @ Linha,01 PSAY AVSX3("W2_FILIAL",5)+".: "+TRB->WKFILIAL+'-'+AvgFilName({TRB->WKFILIAL})[1]  //"Filial : "
   PulaLinha()
   FilAtu:=TRB->WKFILIAL
ENDIF   

if FilAtu#TRB->WKFILIAL            
   
   PulaLinha()
   PulaLinha()
        
   FilAtu:=TRB->WKFILIAL
   
   @ Linha,01 PSAY AVSX3("W2_FILIAL",5)+".: "+TRB->WKFILIAL+'-'+AvgFilName({TRB->WKFILIAL})[1]  //"Filial : "    
   PulaLinha()      
ENDIF
RETURN .T.

*--------------------------*                 
Static Function PulaLinha(cTexto)           
*--------------------------*
IF(valtype(cTexto) = "U", cTexto:="",.T.)
IF Linha >= 60
   Linha := 0
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   If ! Empty(cTexto)
     Linha += 1
     @ Linha, 010 PSAY cTexto
   EndIf
Else                                                                     
   Linha++
Endif

Return .T.

//TRP-06/05/08- Conversão de valores de acordo com a Moeda informada na SI.
*--------------------------------------------------------*
Static Function ConvValSI(cMoeda,nVal,dData,cModo,lFiscal)
*--------------------------------------------------------*
Local nConvVal
Local cMoeDolar := EasyGParam("MV_SIMB2",,"US$")

If(lFiscal=NIL,lFiscal:=.F.,)
If(dData=NIL,dData:=dDataBase,)
nConvVal := nVal * BuscaTaxa(cMoeda,dData,If(lFiscal,.T.,),lFiscal)
nConvVal := nConvVal / BuscaTaxa(cMoeDolar,dData,If(lFiscal,.T.,),lFiscal)

Return nConvVal
//JWJ - 08/08/2006 - Definições do relatório personalizável
*-------------------------*
Static Function ReportDef()
*-------------------------*
Local i, nPos
Local oReport
   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório

   aTabelas := {"SW0","SW6","SW1","SA2","SYR","SW2"} //DFS - 23/12/11 - Inclusão da tabela SW0 para que seja possível personalizar a capa da SI no relatório
   
   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem   := {}

   //Cria o objeto principal de controle do relatório.
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICIP150",cTitulo,"",{|oReport| ReportPrint(oReport)},STR0001)

   //Define como padrão o formato Paisagem
   oReport:oPage:lLandscape := .T.
   oReport:oPage:lPortrait := .F.
	
   //Define o objeto com a seção do relatório
   oSecao1 := TRSection():New(oReport,"Itens Pendentes",aTabelas,aOrdem)

   nPos:=ASCAN(aCampos, "W3_DT_ENTR")

   //Definição das colunas de impressão da seção 1
   nPos_Obs := 0
   For i := 1 to nPos //LAM - 13/10/06 - Acerto dos campos Status e Dt Embarque. 
      IF aCampos[i] = "WK_DTEMB" 
         TRCell():New(oSecao1, aCampos[i]  ,"TRB"   , STR0112,/*Picture*/,/*AvSx3("W1_DT_EMB",3)+4*/12,/*lPixel*/,/*{|| code-block de impressao }*/) //LGS-25/07/2014          
       ELSEIF aCampos[i] = "W1_DTENTR_"
         TRCell():New(oSecao1, aCampos[i]  ,"TRB"   , STR0109,/*Picture*/,AvSx3("W1_DTENTR_",3),/*lPixel*/,/*{|| code-block de impressao }*/)      
       ELSEIF aCampos[i] = "W1_COD_I" 
         TRCell():New(oSecao1, aCampos[i]  ,"TRB"   , AllTrim(AvSx3("W1_COD_I",5)),/*Picture*/,AvSx3("W1_COD_I",3),/*lPixel*/,/*{|| code-block de impressao }*/)            
       ELSEIF aCampos[i] = "B1_DESC"
          TRCell():New(oSecao1, aCampos[i]  ,"TRB"   , AllTrim(AvSx3("B1_DESC",5)),/*Picture*/,15/*nTamDesc*/,/*lPixel*/,/*{|| code-block de impressao }*/)
       ElSEIF aCampos[i] $ "W1_FORLOJ,W2_CLILOJ" //LGS-25/07/2014 - As colunas Loja foram retiradas para incluir novas colunas de datas no relatorio.
          //TRCell():New(oSecao1, aCampos[i]  ,"TRB"   ,"Lj"   ,/*Picture*/,2,/*lPixel*/,/*{|| code-block de impressao }*/)
       ELSEIF aCampos[i]<>"A5_CODPRF"
          IF aCampos[i]="WKOBS"
      	      TRCell():New(oSecao1, aCampos[i]  ,"TRB", STR0111,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
              nPos_Obs := i
          ELSE
             TRCell():New(oSecao1, aCampos[i]  ,"TRB"   ,/*Titulo*/   ,/*Picture*/,Len(TRB->(aCampos[i])),/*lPixel*/,/*{|| code-block de impressao }*/)
          ENDIF
      ENDIF
   Next          
   
   //DFS - 18/08/10 - Adicionado campo para Previsão de Entrega Calculada
   //TRCell():New(oSecao1, "WK_DT_PREC"  ,"TRB"   , "Entrega Calc.",/*Picture*/,AvSx3("W3_DT_ENTR",3),/*lPixel*/,/*{|| code-block de impressao }*/)      
      
   
   
   IF nPos_Obs == 0
	   TRCell():New(oSecao1, "WKOBS"  ,"TRB"   ,STR0111   ,/*Picture*/ ,/*32*/15                ,/*lPixel*/,/*{|| code-block de impressao }*/)  //LGS-25/07/2014 // GFP - 18/07/2013
   ENDIF                                                                                        
   
   //LGS-25/07/2014
   TRCell():New(oSecao1, "W2_DT_ALTE","TRB", STR0108        , /*Picture*/ ,Len(TRB->(aCampos[i]))  ,/*lPixel*/,/*{|| code-block de impressao }*/)//Dt. Preco I/A
   TRCell():New(oSecao1, "WK_DT_PREC","TRB", "Entrega Calc" , /*Picture*/ ,Len(TRB->(aCampos[i]))  ,/*lPixel*/,/*{|| code-block de impressao }*/)//Entrega Calc
   
   //TRP-16/09/08   
   TRCell():New(oSecao1, "W3_PRECO"  ,"TRB",         ,AvSX3("W3_PRECO",6) ,Len(AvSX3("W3_PRECO",6)),/*lPixel*/,/*{|| code-block de impressao }*/)//LGS-25/07/2014
   TRCell():New(oSecao1, "WKVALOR"   ,"TRB", STR0106 ,"@E 999,999,999.99",Len(TRB->(aCampos[i])),/*lPixel*/,/*{|| code-block de impressao }*/)
   
   //LGS-25/07/2014
   TRCell():New(oSecao1, "W0__DT"    ,"TRB", AvSX3("W0__DT",AV_TITULO), /*Picture*/ ,Len(TRB->(aCampos[i])) ,/*lPixel*/,/*{|| code-block de impressao }*/)//Dt S.I.
   TRCell():New(oSecao1, "W1_DTENTR_","TRB", STR0109                  , /*Picture*/ ,Len(TRB->(aCampos[i])) ,/*lPixel*/,/*{|| code-block de impressao }*/)//Necessidade
      
   //JWJ 11/01/2007: Acerto para as colunas não ficarem sobrepostas.
   AEVAL( oSecao1:aCell, {|X| X:SetColSpace(1) } )
     
   //Alinhamento das colunas 
   oReport:Section("Itens Pendentes"):Cell("W3_PRECO"):SetHeaderAlign("RIGHT")//ASR - 14/11/2006 - "LEFT"
   
   //Seção 2: Filial (quebra por multi-filial)
   oSecao2 := TRSection():New(oReport,"Filial",{"TRB"}, {})
   //                                                                       Tam:2+3+15 (Filial+' - '+Nome da filial)
   TRCell():New(oSecao2, "WKFILIAL", "TRB", AVSX3("W2_FILIAL",5),/*Picture*/,AVSX3("W2_FILIAL",3)+30,/*lPixel*/,{||TRB->WKFILIAL+'-'+AvgFilName({TRB->WKFILIAL})[1]})


//Necessário para carregar os perguntes mv_par**
//Pergunte(oReport:uParam,.F.)

Return oReport
                                                  

*----------------------------------*
Static Function ReportPrint(oReport)
*----------------------------------*
Local cFil := "*"
//TRP-06/05/08- Posicionamento da tabela SW1 para impressão de campos personalizáveis.
//TDF-21/07/11 - Posicionamento de todas as tabelas para impressão de campos personalizáveis
oSection := oReport:Section("Itens Pendentes")
TRPosition():New(oSection,"SW0",1,{|| xFilial("SW0") + TRB->W1_CC + TRB->W1_SI_NUM}) //DFS - 23/12/11 - Inclusão de posicionamento da tabela para impressão de campos personalizáveis.
TRPosition():New(oSection,"SW1",1,{|| xFilial("SW1") + TRB->W1_CC + TRB->W1_SI_NUM + TRB->W1_COD_I + STR(TRB->W1_REG,AVSX3("W1_REG",3),0) + STR(TRB->W1_SEQ,AVSX3("W1_SEQ",3),0)})
TRPosition():New(oSection,"SW6",1,{|| xFilial("SW6") + TRB->W6_HAWB})
TRPosition():New(oSection,"SW2",1,{|| xFilial("SW2") + TRB->W1_PO_NUM})
If EICLoja()
   TRPosition():New(oSection,"SA2",1,{|| xFilial("SA2") + TRB->W1_FORN + TRB->W1_FORLOJ})
Else                      
   TRPosition():New(oSection,"SA2",1,{|| xFilial("SA2") + TRB->W1_FORN})
EndIf
 
oReport:SetMeter (TRB->(EasyRecCount("TRB")))
TRB->( dbGoTop() )

Do While TRB->(!EoF()) .And. !oReport:Cancel()
	//Imprime o cabeçalho contendo a Filial
	oReport:Section("Filial"):Init()
	oReport:Section("Filial"):PrintLine()
	oReport:Section("Filial"):Finish()
		
	//Imprime os registros dessa mesma Filial
	oReport:Section("Itens Pendentes"):Init()
	cFil := TRB->WKFILIAL
	
	Do While TRB->(!EoF()) .And. !oReport:Cancel() .AND. TRB->WKFilial==cFil //LGS-06/12/2013 - Imprime apenas os registros que atendem ao filtro personalizado caso exista.
	   oReport:Section("Itens Pendentes"):evalposition()
	   If !Empty(TRB->W6_HAWB) //LGS-18/03/2014
         // MFR 12/01/2020 OSSME-5371
		   //If SW6->(DBSEEK(xFilial("SW6") + TRB->W6_HAWB))
         If SW6->(DBSEEK(TRB->WKFilial + TRB->W6_HAWB))
		      If oReport:Section("Itens Pendentes"):exuserfilter()
		   	     oReport:Section("Itens Pendentes"):PrintLine() //Impressão da linha
		   	     oReport:IncMeter()                             //Incrementa a barra de progresso
		      EndIf
		   EndIf
	   Else
	   	   If oReport:Section("Itens Pendentes"):exuserfilter()
		   	  oReport:Section("Itens Pendentes"):PrintLine() //Impressão da linha
		   	  oReport:IncMeter()                             //Incrementa a barra de progresso
		   Else  // GFP - 17/04/2014
		      oReport:Section("Itens Pendentes"):PrintLine() //Impressão da linha
		   	  oReport:IncMeter()                             //Incrementa a barra de progresso
		   EndIf
       EndIf
	   TRB->( dbSkip() )
	EndDo
	
	oReport:Section("Itens Pendentes"):Finish()
Enddo

TRB->(DBGOTOP())
                           
Return .T.

/*
Programa   : IP150Modo
Parâmetros : cAlias - Tabela
Objetivo   : Verificar se tabela é compartilhada ou não
Retorno    : lRet : .T. - Compartilhado / .F. - Exclusivo
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 24/01/2013 : 14:29
*/
*----------------------------* 
Static Function IP150Modo(cAlias)    
*----------------------------*
Local lRet := .F.

SX2->(DbSetOrder(1))  // X2_CHAVE
If SX2->(DbSeek(cAlias))
   lRet := FWModeAccess(cAlias) == "C"
EndIf

Return lRet
