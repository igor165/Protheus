//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICDI180.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICDI180 ³ Autor ³ AVERAGE/RS            ³ Data ³ 02.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seguro de Transportes Importacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICDI180()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EICDI180()

EICDI180R3(.T.)
Return .t.

Function EICDI180R3(p_R4)

#include "avprint.ch"

#DEFINE   VENCIMENTO  1
#DEFINE   NEGOCIACAO  2
#DEFINE   EMBARQUE    3

#DEFINE   Tit180      STR0001 //" Seguro de Transportes Importacao "
#DEFINE   Largura     80
#DEFINE   Comprime    .T.

#COMMAND E_RESET_AREA => IF(SELECT("TRB")<>0,TRB->(E_EraseArq(cNomArq)),) ; DBSELECTAREA("SW6") 

LOCAL TB_Campos:={}, aRCampos:={}, cOldArea:=ALIAS()
LOCAL TB_Funcoes:={ {"-4", STR0002, "F5", STR0002 } } //"Relatorio"
LOCAL oDlg, oGet
LOCAL oPanel
Local aButtons := {}
// incluir variaveis para o relatorio padrao

LOCAL aDados :={"TRB",;
                STR0003,;//"Este relatório irá exibir uma estatística sobre"
                STR0004,;//"o desempenho de "
                "",;
                "G",;
                Largura,;
                "",;
                "",;
                Tit180,;
                { STR0005, 1,STR0006, 1, 2, 1, "",1 },;//"Zebrado"###"Importa‡Æo"
                STR0007,; //"EICDI180"
                { {|| .T. } , {|| .T.}  }  }

Aadd(aButtons,{"IMPRIMIR", {|| If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos))}, STR0030, STR0030})
PRIVATE WorkFile, L1:=5, indice, TOpcao:=0,TDt_I,TDt_F,MSai
PRIVATE aCampos:={"W6_HAWB","W6_COD_SEG","W6_IDENTVE","W6_ORIGEM","W6_DT_EMB",;
                  "W6_CHEG","W6_DT_DESE","W6_FOB_TOT"}

// aRotina declarada apenas para compatibilizar com GetDadDB
PRIVATE aRotina := { { STR0008       ,"AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                     { STR0009       ,"C210Impor" , 0 , 2} ,; //"Atual"
                     { STR0010       ,"C210Impor" , 0 , 3} }, oPrn //"Todos"
Private cFilSW8:= xFilial("SW8")  
Private aHeader[0],nUsado:=0, nOpcao:=1, Valor[0], cNomArq:=""
PRIVATE lInverte:= .F., cMarca:= GetMark(), aTELA[0][0], aGETS[0]
Private cMoeUSD:=BuscaDolar()//EasyGParam("MV_SIMB2",.F.,"US$")
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()


If Empty(cMoeUSD)
   cMoeUSD:="US$"
EndIf

WHILE .T.

  IF ! Pergunte("EDI180",.T.)
     EXIT
  ENDIF

  cImport :=mv_par01
  TDt_I   :=mv_par02
  TDt_F   :=mv_par03
  cTabela :=mv_par04
  cPict01:=AVSX3("W6_FOB_TOT",6)

  Processa({||DI180GrvWork() },STR0011 ) //"Em Processamento, Aguarde..."
  
  AADD(TB_Campos,{"W6_HAWB"   ,,AVSX3("W6_HAWB"   ,5)})
  AADD(TB_Campos,{"W6_COD_SEG",,AVSX3("W6_COD_SEG",5)})
  AADD(TB_Campos,{"W6_IDENTVE",,AVSX3("W6_IDENTVE",5)})  
  AADD(TB_Campos,{"W6_ORIGEM ",,STR0017})
  AADD(TB_Campos,{"W6_DT_EMB ",,STR0018})
  AADD(TB_Campos,{"YD_DL_NALA",,STR0019})
  AADD(TB_Campos,{"W6_CHEG"   ,,STR0020})
  AADD(TB_Campos,{"W6_DT_DESE",,STR0021})
  AADD(TB_Campos,{{||TRANS(TRB->W6_FOB_TOT,cPict01)},,STR0022})
  AADD(TB_Campos,{{||TRANS(TRB->FRETE     ,cPict01)},,STR0023})
  AADD(TB_Campos,{{||TRANS(TRB->TOTAL_USD ,cPict01)},,STR0024})
  AADD(TB_Campos,{{||TRANS(TRB->DESPESAS  ,"@E 9,999,999.99")},,STR0025}  )
  AADD(TB_Campos,{{||TRANS(TRB->IMPOSTOS  ,"@E 9,999,999.99")},,STR0026}  )
  AADD(TB_Campos,{{||TRANS(TRB->SEGURO    ,"@E 9,999,999.99")},,STR0027})  
  AADD(TB_Campos,{{||TRANS(TRB->PREMIO_SEM,"@E 9,999,999.99")},,STR0028})
  AADD(TB_Campos,{{||TRANS(TRB->PREMIO_COM,"@E 9,999,999.99")},,STR0029})
  aRCampos:=E_CriaRCampos(TB_Campos)
  
  //If lR4
     //AAF - 20/06/2006 - Relatório Personalizavel - Release 4
     //ReportDef cria os objetos.
    // oReport := ReportDef()
  //EndIf
  aDados[7]:="Importador.: "+IF(EMPTY(cImport),"Todos",LEFT(SYT->YT_NOME,25))

  IF TRB->(Easyreccount("TRB")) > 0
     nOpca:=0
     
     oMainWnd:ReadClientCoords()

     DEFINE MSDIALOG oDlg TITLE Tit180+" - "+aDados[7] ;
     FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
     OF oMainWnd PIXEL
     
     @ 00,00 MSPanel oPanel Size 20,45 of oDlg

    dbSelectArea("TRB")  
    
    TRB->(dbGoTop())
    oGet:= MsSelect():New("TRB",,,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
    oGet:oBrowse:Refresh()
	oPanel:Align := CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
    oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
    ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()},,aButtons)) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

     IF  nOpca == 1
        LOOP 
     ENDIF
  Else
     Help("", 1, "AVG0000236")//MSGINFO(OemToAnsi(STR0012),OemToAnsi(STR0013))//"NÆo h  registros para serem processados"###"Informa‡Æo"
     Loop

  ENDIF

  EXIT

ENDDO

E_RESET_AREA

RETURN

*----------------------*
Function DI180GrvWork()
*----------------------*
LOCAL nFob:=0
LOCAL nOldOrdem:=SW9->(IndexOrd())
LOCAL aSemSX3:={;
                {"FRETE"     ,"N",AVSX3("W6_FOB_TOT",3),AVSX3("W6_FOB_TOT",4)},;
                {"TOTAL_USD" ,"N",AVSX3("W2_FOB_TOT",3),AVSX3("W2_FOB_TOT",4)},;
                {"DESPESAS"  ,"N",AVSX3("W4_DESCONT",3),AVSX3("W4_DESCONT",4)},;
                {"IMPOSTOS"  ,"N",AVSX3("W4_PACKING",3),AVSX3("W4_PACKING",4)},;
                {"YK_TXGUEIM","N",AVSX3("YK_TXGUEIM",3),AVSX3("YK_TXGUEIM",4)},;
                {"YK_TXNORMA","N",AVSX3("YK_TXNORMA",3),AVSX3("YK_TXNORMA",4)},;
                {"YK_TXDESCO","N",AVSX3("YK_TXDESCO",3),AVSX3("YK_TXDESCO",4)},;
                {"SEGURO"    ,"N",AVSX3("W4_INLAND",3) ,AVSX3("W4_INLAND" ,4)},;
                {"PREMIO_SEM","N",AVSX3("W4_INLAND",3) ,AVSX3("W4_INLAND" ,4)},;
                {"PREMIO_COM","N",AVSX3("W4_INLAND",3) ,AVSX3("W4_INLAND" ,4)},;
                {"YD_DL_NALA","C",AVSX3("YD_DL_NALA",3),AVSX3("YD_DL_NALA",4)}}
ProcRegua(SW6->(Easyreccount("SW6"))+2)

IncProc(STR0014)//"Criando Aquivo de Trabalho..."

IF(SELECT("TRB")==0,cNomArq:=E_CRIATRAB(,aSemSX3),)

IncProc(STR0015)//"Criando Indice do Arquivo de Trabalho..."

IF(SELECT("TRB")==0,IndRegua("TRB",cNomArq+TEOrdBagExt(),"W6_HAWB"),)

DBSELECTAREA("TRB") ; AvZap()

SW6->(DBSETORDER(2))
SW6->(DBSEEK(xFilial("SW6")+DTOS(TDt_I),.T.))
SW9->(DBSETORDER(3))
WHILE ! SW6->(EOF()) .AND. SW6->W6_FILIAL == xfilial("SW6")

  IF !SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
    SW6->(DBSKIP()) ; LOOP 
  ENDIF  

   IncProc(STR0016+SW6->W6_HAWB)//"Lendo Processo: "
   
   
   IF ! EMPTY(cTabela)
      IF SW6->W6_COD_SEG <> cTabela
         SW6->(DBSKIP()) ; LOOP
      ENDIF
   ENDIF

   IF ! EMPTY(TDt_F)
      IF SW6->W6_DT_DESE > TDt_F
         EXIT
      ENDIF
   ENDIF

   SW7->(DBSETORDER(1))
   SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))

   SW2->(DBSETORDER(1))
   SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))

   IF !EMPTY(cImport)
      IF SW6->W6_IMPORT <> cImport
         SW6->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

   SY9->(DBSETORDER(2))
   SY9->(DBSEEK(xFilial("SY9")+SW2->W2_DEST))

   SYT->(DBSETORDER(1))
   SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))

   SWD->(DBSETORDER(1))
   SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))

   SYK->(DBSETORDER(1))
   SYK->(DBSEEK(xFilial("SYK")+SW6->W6_COD_SEG))

   nImpostos:=0
   WHILE ! SWD->(EOF()) .AND. SWD->WD_HAWB == SW6->W6_HAWB .AND. SWD->WD_FILIAL == xFilial("SWD")
       IF SWD->WD_DESPESA <> EasyGParam("MV_D_II") .AND. SWD->WD_DESPESA <> EasyGParam("MV_D_IPI") .AND. SWD->WD_DESPESA <> EasyGParam("MV_D_PIS") .AND. SWD->WD_DESPESA <> EasyGParam("MV_D_COFINS")
          SWD->(DBSKIP()) ; LOOP
       ENDIF
       nImpostos+=SWD->WD_VALOR_R

       SWD->(DBSKIP())
   END
   TRB->(DBAPPEND())
   TRB->W6_HAWB    := SW6->W6_HAWB
   TRB->W6_COD_SEG := SW6->W6_COD_SEG
   TRB->W6_IDENTVE := SW6->W6_IDENTVE
   TRB->W6_ORIGEM  := SW6->W6_ORIGEM
   TRB->W6_DT_EMB  := SW6->W6_DT_EMB
   TRB->YD_DL_NALA := SY9->Y9_DESCR
   TRB->W6_CHEG    := SW6->W6_CHEG
   TRB->W6_DT_DESE := SW6->W6_DT_DESE
   
   // AST - 26/11/08
   /*lMesmaMoeda:=.F.
   If SW6->W6_VLMLEMN<>0      
      If SW9->W9_MOE_FOB==cMoeUSD
         nFob     :=SW6->W6_VLMLEMN
         nInland  :=SW6->W6_INLAND
         nDescont :=SW6->W6_DESCONT
         nPacking :=SW6->W6_PACKING
         nOutraDes:=SW6->W6_OUTDESP
         lMesmaMoeda:=.T.
      EndIf
   Endif
   If !lMesmaMoeda */
      nFob :=ConvInvMoeda(SW6->W6_HAWB,cMoeUSD,SW6->W6_DT)
      aDesp:=ConvDespFobMoeda(SW6->W6_HAWB,cMoeUSD,SW6->W6_DT,{"INLAND","PACKING","OUTRAS","DESCONTO",;
                                             "FRETE"})
                                             
      nInland  :=aDesp[1,2]
      nPacking :=aDesp[2,2]
      nOutraDes:=aDesp[3,2]
      nDescont :=aDesp[4,2]

      
   //Endif                
   aFreteIN:=ConvDespFobMoeda(SW6->W6_HAWB,cMoeUSD,SW6->W6_DT,"FRETE")
   nFreteInt:= aFreteIn[1][2]
   nFrete:=ValorFrete(SW6->W6_HAWB,cMoeUSD,SW6->W6_DT,3)
   nTaxa := SW6->W6_TX_US_D
   
   TRB->W6_FOB_TOT := nFob
   TRB->FRETE      := nFrete   
   TRB->TOTAL_USD := (nFob+nInland+nPacking+nOutraDes+nFreteInt)-nDescont
   TRB->DESPESAS   := nFob * EasyGParam("MV_PERC_DE")
   TRB->IMPOSTOS  := nImpostos / nTaxa
   TRB->YK_TXGUEIM := SYK->YK_TXGUEIM
   TRB->YK_TXNORMA := SYK->YK_TXNORMA
   TRB->YK_TXDESCO := SYK->YK_TXDESCO
   TRB->SEGURO    := TRB->TOTAL_USD+TRB->DESPESAS + If(SYK->YK_TXGUEIM > 0, TRB->IMPOSTOS, 0)
   TRB->PREMIO_SEM:= (TRB->TOTAL_USD + TRB->DESPESAS) * TRB->YK_TXNORMA + (TRB->IMPOSTOS * TRB->YK_TXGUEIM)//TRB->SEGURO*SYK->YK_TXBASE
   TRB->PREMIO_COM:= ((TRB->TOTAL_USD + TRB->DESPESAS) * SYK->YK_TXFINAL + (TRB->IMPOSTOS * TRB->YK_TXGUEIM)) * (1 - SYK->YK_TXDESCO/100) //TRB->SEGURO*SYK->YK_TXFINAL
   
   SW6->(DBSKIP())
ENDDO
SW9->(DbSetOrder(nOldOrdem))
RETURN 
*--------------------*
Function E_DI180IMP()
*--------------------*
RETURN IF(!EMPTY(mv_par01),ExistCPO("SYT",mv_par01),.T.)

*--------------------*
Function E_DI180TAB()
*--------------------*
RETURN IF(!EMPTY(mv_par04),ExistCPO("SYK",mv_par04),.T.)

//TRP - 20/06/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW6","SY9"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICDI180",STR0001,"EDI180",{|oReport| ReportPrint(oReport)},STR0003+ " " +STR0001)

//ER - 20/10/2006 - Inicia o relatório como paisagem. 
oReport:oPage:lLandScape := .T. 
oReport:oPage:lPortRait := .F. 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Seguros",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"W6_HAWB"       ,"TRB",   /*Titulo*/             ,/*Picture*/                       ,AVSX3("W6_HAWB",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"W6_COD_SEG"    ,"TRB",   /*Titulo*/             ,/*Picture*/                       ,AVSX3("W6_COD_SEG",3)  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"W6_IDENTVE"    ,"TRB",   /*Titulo*/             ,/*Picture*/                       ,AVSX3("W6_IDENTVE",3)  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"W6_ORIGEM"     ,"TRB",   STR0017                ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"W6_DT_EMB "    ,"TRB",   STR0018                ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"YD_DL_NALA"    ,"TRB",   STR0019                ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"W6_CHEG"       ,"TRB",   STR0020                ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"W6_DT_DESE"    ,"TRB",   STR0021                ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"W6_FOB_TOT"    ,"TRB",   STR0022                ,AVSX3("W6_FOB_TOT",6)             ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"FRETE"         ,"TRB",   STR0023                ,AVSX3("W6_FOB_TOT",6)             ,AVSX3("W6_FOB_TOT",3)  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TOTAL_USD"     ,"TRB",   STR0024                ,AVSX3("W6_FOB_TOT",6)             ,AVSX3("W2_FOB_TOT",3)  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DESPESAS"      ,"TRB",   STR0025                ,"@E 9,999,999.99"                 ,AVSX3("W4_DESCONT",3)  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"IMPOSTOS"      ,"TRB",   STR0026                ,"@E 9,999,999.99"                 ,AVSX3("W4_PACKING",3)  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"YK_TXGUEIM"    ,"TRB",   AVSX3("YK_TXGUEIM", 5) ,"@E 9,999,999.99"                 ,AVSX3("YK_TXGUEIM",3)   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"YK_TXNORMA"    ,"TRB",   AVSX3("YK_TXNORMA", 5) ,"@E 9,999,999.99"                 ,AVSX3("YK_TXNORMA",3)   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"YK_TXDESCO"    ,"TRB",   AVSX3("YK_TXDESCO", 5) ,"@E 9,999,999.99"                 ,AVSX3("YK_TXDESCO",3)   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"SEGURO"        ,"TRB",   STR0027                ,"@E 9,999,999.99"                 ,AVSX3("W4_INLAND",3)   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"PREMIO_SEM"    ,"TRB",   STR0028                ,"@E 9,999,999.99"                 ,AVSX3("W4_INLAND",3)   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"PREMIO_COM"    ,"TRB",   STR0029                ,"@E 9,999,999.99"                 ,AVSX3("W4_INLAND",3)   ,/*lPixel*/,/*{|| code-block de impressao }*/)

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Seguros"),"SW6",1,{|| xFilial("SW6") + TRB->W6_HAWB})

TRPosition():New(oReport:Section("Seguros"),"SY9",1,{|| xFilial("SY9") + SW6->W6_DEST})

//oSection:Print()
oReport:SetMeter (TRB->(EasyRecCount("TRB")))
TRB->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Seguros"):Init()


//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Seguros"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Seguros"):Finish()
TRB->( dbGoTop() )
Return .T.


*----------------------------------------------------------------------------*
*                        FIM DO PROGRAMA EICDI180.PRW                        *
*----------------------------------------------------------------------------*

