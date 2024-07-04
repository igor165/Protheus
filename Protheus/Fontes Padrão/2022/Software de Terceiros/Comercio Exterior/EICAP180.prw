#INCLUDE "EICAP180.ch"
//#include 'FIVEWIN.ch'
#include "AVERAGE.CH"
#include 'avprint.ch'
//#include 'font.ch'


//Funcao     : EICAP180.PRW
//Autor      : AVERAGE / ALEX WALLAUER 
//Data       : 25/07/99 (Criado p/ Nestle)
//Sintaxe    : EICAP180 - MNU - Controle de Comissao de Corretores
//Sintaxe    : EICAP181 - MNU - Relatorio de Importacoes em Ordem de Dt. Vencto
//Sintaxe    : EICAP182 - MNU - Relatorios de Cambio Fechado
//Sintaxe    : EICAP183 - MNU - Relatorio de Estatisticas
//Revisão	 : Gustavo Cunha - 28/08/2013 - Tratamento para trazer os valores de pagamento antecipado vinculado a PO quanto a Fornecedor
//Convertido : P/ o Protheus V507 e V508 em 4 de Setembro de 2000 / Alex Wallauer


#DEFINE COURIER_07 oFont1
#DEFINE COURIER_08 oFont2
#DEFINE COURIER_10 oFont3
#DEFINE COURIER_12 oFont4
#DEFINE COURIER_14 oFont5

//EICAP180 - MNU - Controle de Comissao de Corretores
Function EICAP180(cOrigemSX3)

EICAP180R3(cOrigemSX3,.T.)
Return .t.

*-------------------------------*
FUNCTION EICAP180R3(cOrigemSX3,p_R4) 
*-------------------------------*
LOCAL cTitulo:=STR0001,oDlg,nOpcao //"Controle de ComissÆo de Corretores"

IF cOrigemSX3 # NIL
   IF !EMPTY(M->WA_HAWB) .AND. !PAlteracao
      M->WA_PRODUTO:=SW2->W2_DES_IPI
   ENDIF
   RETURN .T.
ENDIF

PRIVATE cRel1:=STR0002 //"1-Calculo de Corretagem"
PRIVATE cRel2:=STR0003 //"2-Fechamentos sem Corretora"
PRIVATE aRel :={cRel1,cRel2}
PRIVATE cRel :=cRel1
PRIVATE dDataIni:=AVCTOD('')
PRIVATE dDataFin:=AVCTOD('')
Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 //GFC - 02/12/05
Private cFun := "180"
Private cNome 
Private nVlDolar:= 0
Private nVlReal:= 0
SX3->(DBSETORDER(2))
PRIVATE lCposAntecip:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
SX3->(DBSETORDER(1))

PRIVATE lImpObs := .F.        
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()

                             // legenda ref. a pgto antecipado                             
While .T.

   nOpcao  := 0
   lImpObs := .F.
/* ISS - 18/03/10 - Alteração do tamanho da tela para que a mesma não corte o botão "Confirmar"
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 20,45 Of oMainWnd */
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 25,50 Of oMainWnd
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT                                                                      

   @ 20,10 SAY STR0004 OF oPanel Pixel //"Relat¢rio:"
   @ 16,45 COMBOBOX cRel ITEMS aRel SIZE 90,50 OF oPanel Pixel 

   @ 40,10 SAY STR0005 OF oPanel Pixel //"Data Inicial:"
   @ 40,45 GET dDataIni  SIZE 42,8 OF oPanel Pixel 

   @ 60,10 SAY STR0006 OF oPanel Pixel //"Data Final:"
   @ 60,45 GET dDataFin  SIZE 42,8 OF oPanel Pixel 

   bOk     := {||nOpcao:=1,oDlg:End()}
   bCancel := {||nOpcao:=0,oDlg:End()}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   
   If lR4
      //TRP - 02/08/2006 - Relatório Personalizavel - Release 4
      //ReportDef cria os objetos.
      oReport := ReportDef()
   EndIf

   If nOpcao == 0
      Exit
   Endif

   DBSELECTAREA('SWB')
   SW2->(DBSETORDER(1))
   SA2->(DBSETORDER(1))
   SW7->(DBSETORDER(1))
   SWA->(DBSETORDER(1))
   SWB->(DBSETORDER(1))
   SWB->(DBSEEK(xFILIAL("SWB")))

   lNaoTem:=.T.
   bImp:={||lNaoTem:=.F.}
   bWhi:={||lNaoTem}
   bFor:={||AP180For()}

   SWB->(DBEVAL(bImp,bFor,bWhi))

   IF lNaoTem
      Help("", 1, "AVG0000219")//MSGINFO(STR0007) //"NÆo existe registros a serem listados"
   ELSE
      If(lR4, oReport:PrintDialog(),AP180Relatorio())
   ENDIF

End


Return(NIL)  

*--------------------------*
 STATIC FUNCTION AP180For()
*--------------------------*
IF !lNaoTem
   IncProc(STR0008+SWB->WB_HAWB) //"Imprimindo Processo: "
ENDIF

IF cRel==cRel1 .AND. EMPTY(SWB->WB_CORRETO)
   RETURN .F.
ENDIF

IF cRel==cRel2 .AND.!EMPTY(SWB->WB_CORRETO) 
   RETURN .F.
ENDIF

IF EMPTY(SWB->WB_DT_CONT)
   RETURN .F.
ENDIF

IF !EMPTY(dDataIni) .AND. SWB->WB_DT_CONT < dDataIni
   RETURN .F.
ENDIF

IF !EMPTY(dDataFin) .AND. SWB->WB_DT_CONT >  dDataFin
   RETURN .F.
ENDIF

// WB_TIPOREG for "P" e o cpo WB_NUMPO estiver preenchido, significa que o lancto 
// refere-se ao adiantamento pago na parcela de cambio da DI, portanto estes casos 
// devem ser desprezados, pois ja gerou-se comissao qdo do lancto da parcela de 
// cambio de adiantamento.
IF lCposAntecip .AND. Left(SWB->WB_TIPOREG,1) == "P" .AND. !EMPTY(SWB->WB_NUMPO)
   RETURN .F.
ENDIF

IF lCposAntecip .AND. SWB->WB_PO_DI == "D" .AND. SWB->WB_FOBMOE <= 0
   RETURN .F.
ENDIF

//** GFC - 02/12/05 - Não considerar os registros com tipos de contrato 3 ou 4
If lWB_TP_CON .and. SWB->WB_TP_CON $ ("3/4")
   Return .F.
EndIf
//**

RETURN .T.

*--------------------------------*
 STATIC FUNCTION AP180Relatorio()
*--------------------------------*
oPrn := PrintBegin('',.F.,.F.)
   oSend( oPrn, 'SetLandScape' )
PrintEnd()

AVPRINT oPrn NAME cRel

   DEFINE FONT oFont1  NAME 'Courier New' SIZE 0,07 OF  oPrn
   DEFINE FONT oFont2  NAME 'Courier New' SIZE 0,08 OF  oPrn
   DEFINE FONT oFont3  NAME 'Courier New' SIZE 0,10 OF  oPrn
   DEFINE FONT oFont4  NAME 'Courier New' SIZE 0,12 OF  oPrn

   AVPAGE

      oPrn:oFont:=COURIER_08
      
      lPrimPag:= .T.
      nPag     := 0000
      nLin    := 9999
      nLimPage:= 2150
      nColFim := 3150
      nColIni := 0001
      nTam    := 0075
      nPula   := 0045
      
      cPictFOB:=Alltrim(X3Picture('WB_VL_CORR'))
      cPictCor:=Alltrim(X3Picture('WB_VL_CORR'))
      cPictCtl:=Alltrim(X3Picture('WA_CTRL'))
      nVlrTotUSS:=nVlrTotRS:=nVlrTotCor:=0

      nCol1:=nColIni ; nCol2:=325 ; nCol3:=0600
      nCol4:=1200    ; nCol5:=1500; nCol6:=1950 
      nCol7:=2270    ; nCol8:=2600; nCol9:=nColFim
      
      //** GFC - 05/12/05
      If lWB_TP_CON
         nCol9:=2900
         nCol10:=2990
      EndIf
      //**

      SWB->(DBSEEK(xFilial("SWB")))
      nCont:=SWB->(Easyreccount("SWB"))
      bImp :={||AP180Detalhe()}
      Processa({||ProcRegua(nCont), SWB->(DBEVAL(bImp,bFor)) },STR0009) //"Impressao..."
      AP180Tot()

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

RETURN .T.

*--------------------------------*
 STATIC FUNCTION AP180Cab()
*--------------------------------*
IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF

nLin:= 100
nPag := nPag  + 1

cTitulo1:=STR0010+SUBSTR(UPPER(cRel),3) //"IMPORTACAO - "
cTitulo2:=STR0011+DTOC(dDataIni)+STR0012+DTOC(dDatafin) //"ENTRE "###" E "


cC01:=STR0013 //"Processo"
cC02:=STR0014 //"Processo"
cC03:=IF(cRel==cRel1,STR0015,STR0016) //"CORRETORA"###"BANCO"
cC04:=STR0017 //"DT DO CAMBIO"
cC05:=STR0018 //"MOEDA"
cC06:=STR0019 //"VLR EM MOEDA"
cC07:=STR0020 //"VLR EM US$"
cC08:=STR0021 //"VLR EM R$"
cC09:=STR0022 //"VLR CORRETAGEM"
//** GFC - 05/12/05
If lWB_TP_CON
   cC010:=AvSX3("WB_TP_CON",5)
EndIf
//**

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin+=25

oPrn:Say(nLin,01,SM0->M0_NOME,COURIER_12)
oPrn:Say(nLin,nColFim/2,cTitulo1,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,STR0023+STR(nPag,8),COURIER_12,,,,1) //"Pagina..: "
nLin+=50

oPrn:Say(nLin,01,STR0024,COURIER_12) //"SIGAEIC"
oPrn:Say(nLin,nColFim/2,cTitulo2,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,STR0025+DTOC(dDataBase),COURIER_12,,,,1) //"Emissao.: "
nLin+=50

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin +=50

oPrn:oFont:=COURIER_08
oSend( oPrn, 'SAY',nLin,nCol1,cC01,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol2,cC02,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol3,cC03,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol4,cC04,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol5,cC05,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol6,cC06,COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol7,cC07,COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8,cC08,COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9,cC09,COURIER_08,,,,1)
//** GFC - 05/12/05
If lWB_TP_CON
   oSend( oPrn, 'SAY',nLin,nCol10,cC010,COURIER_08)
EndIf
//**
nLin:=nLin+30

cC01:=SWB->WB_HAWB
cC03:=SPACE(30)
cC06:=LEN(cPictFOB)-3
cC07:=LEN(cPictFOB)-3
cC08:=LEN(cPictFOB)-3
cC09:=LEN(cPictCor)-3

oSend( oPrn, 'SAY',nLin,nCol1,REPL('-',LEN(cC01)),COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol2,REPL('-',LEN(cC02)),COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol3,REPL('-',LEN(cC03)),COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol4,REPL('-',LEN(cC04)),COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol5,REPL('-',LEN(cC05)),COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol6,REPL('-',cC06),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',cC07),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',cC08),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',cC09),COURIER_08,,,,1)
//** GFC - 05/12/05
If lWB_TP_CON
   oSend( oPrn, 'SAY',nLin,nCol10,REPL('-',LEN(cC010)),COURIER_08)
EndIf
//**
nLin:=nLin+nPula          

RETURN .T.

*-----------------------------------*
 STATIC FUNCTION AP180Detalhe()
*------------------------------------*
LOCAL cNumPO, nVlrSWB
LOCAL cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

IF nLin > (nLimPage-nPula)
   AP180Cab()
ENDIF

IF lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 28/08/2013
   SWA->(DBSEEK(xFilial("SWA")+SWB->WB_HAWB+SWB->WB_PO_DI))
   cNumPO  := Alltrim(SWB->WB_HAWB)
   nVlrSWB := SWB->WB_PGTANT
   cHawb   := SWB->WB_HAWB
   lImpObs := .T.
ELSE   
   SWA->(DBSEEK(xFilial("SWA")+SWB->WB_HAWB))   
   SW7->(DBSEEK(xFilial("SW7")+SWB->WB_HAWB))
   cNumPO  := SW7->W7_PO_NUM
   nVlrSWB := SWB->WB_FOBMOE
   cHawb   := SWB->WB_HAWB
ENDIF
SW2->(DBSEEK(xFilial("SW2")+cNumPO))

IF cRel==cRel1
   SYW->(DBSEEK(xFilial("SYW")+SWB->WB_CORRETO))
   cNome:=SYW->YW_NOME
ELSE
   SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO))
   cNome:=MEMOLINE(SA6->A6_NOME,30,1)
ENDIF

IF SWB->WB_MOEDA $ cMoedaDolar        //'US$,USD'
   nVlrUSS := nVlrSWB 
ELSE
   nVlrRS  := nVlrSWB * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_CONT,,.F.)
   nVlrUSS := nVlrRS / BuscaTaxa(cMoedaDolar,SWB->WB_DT_CONT,,.F.)
ENDIF

IF !EMPTY(SWB->WB_CA_TX)
   M->WB_TIPOREG := Left(SWB->WB_TIPOREG,1)
   IF lCposAntecip
      M->WB_PGTANT := SWB->WB_PGTANT
   ENDIF
   M->WB_FOBREAL := Ape_Vl_Real(nVlrSWB,SWB->WB_CA_TX)
ELSE
   M->WB_FOBREAL := nVlrSWB * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_CONT,,.F.)
ENDIF

oPrn:oFont:=COURIER_08
oSend( oPrn, 'SAY',nLin,nCol1, cHawb,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol2+30,TRANS(SWA->WA_CTRL,cPictCtl),COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol3,cNome,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol4+25,DTOC(SWB->WB_DT_CONT),COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol5+15,SWB->WB_MOEDA,COURIER_08)
oSend( oPrn, 'SAY',nLin,nCol6,TRANS(nVlrSWB,cPictFOB),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol7,TRANS(nVlrUSS,cPictFOB),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8,TRANS(M->WB_FOBREAL,cPictFOB),COURIER_08,,,,1)
IF cRel==cRel1
   oSend( oPrn, 'SAY',nLin,nCol9,TRANS(SWB->WB_VL_CORR,cPictCor),COURIER_08,,,,1)
ELSE 
   oSend( oPrn, 'SAY',nLin,nCol9,TRANS(0,cPictCor),COURIER_08,,,,1)
ENDIF
//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   oSend( oPrn, 'SAY',nLin,nCol10,AllTrim(BscXBox("WB_TP_CON",SWB->WB_TP_CON)),COURIER_08)
EndIf
//**
nVlrTotUSS:=nVlrTotUSS+nVlrUSS
nVlrTotRS :=nVlrTotRS +M->WB_FOBREAL
nVlrTotCor:=nVlrTotCor+SWB->WB_VL_CORR

nLin:=nLin+nPula           

RETURN .T.

*-----------------------------*
 STATIC FUNCTION AP180Tot()
*-----------------------------*
Local cMensObs:=STR0108//"Os processos iniciados com * referem-se a Adiantamentos - Número do Pedido"

IF nLin > (nLimPage-nPula*2)
   AP180Cab()
ENDIF

cC07:=LEN(cPictFOB)-3
cC08:=LEN(cPictFOB)-3
cC09:=LEN(cPictCor)-3

oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',cC07),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',cC08),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',cC09),COURIER_08,,,,1)
nLin:=nLin+nPula           
oSend( oPrn, 'SAY',nLin,nCol7,TRANS(nVlrTotUSS,cPictFOB),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8,TRANS(nVlrTotRS ,cPictFOB),COURIER_08,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9,TRANS(nVlrTotCor,cPictCor),COURIER_08,,,,1)

IF lImpObs
   nLin:=nLin+nPula
   oSend( oPrn, 'SAY',nLin,nCol1,cMensObs,COURIER_08,,,,1)
ENDIF
RETURN .T.

//EICAP181 - MNU - Relatorio de Importacoes em Ordem de Dt. Vencto
Function EICAP181()

EICAP181R3(.T.)
Return .t.

*----------------------------------------------------------------------------*
FUNCTION EICAP181R3(p_R4)  
*----------------------------------------------------------------------------*
LOCAL oDlg,cNomArq,nOpcao,;
aSemSX3:={{'WB_USS_DIA','N',15,2},;
          {'WB_RS_DIA' ,'N',15,2},; 
          {'WB_FOBREAL','N',15,2},; 
          {'WB_FOBMOE' ,'N',15,2},; 
          {'WB_FOBUSS' ,'N',15,2},; 
          {'WB_USS_MES','N',15,2},; 
          {'WB_RS_MES' ,'N',15,2}}

Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 //GFC - 02/12/05
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
PRIVATE cMesBrk := ""
cFun := "181"

//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   aAdd(aSemSX3,{'WB_TP_CON' ,'C',25,0})
EndIf
aAdd(aSemSX3,{'WB_TIPOREG' ,'C',25,0})
//**

SX3->(DBSETORDER(2))
PRIVATE lCposAntecip:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
SX3->(DBSETORDER(1))

PRIVATE lImpObs := .F.
aHeader:=ARRAY(0)
aCampos:={'WB_HAWB' ,'WA_PRODUTO','A2_NREDUZ' ,'WB_DT_VEN' ,;
          'W2_MOEDA','WB_PO_DI'  ,'WB_INVOICE','W2_COND_PA',;
          'WB_FORN' ,'WB_LOJA'   ,'WB_LINHA'}  
          
//AOM - 01/02/2011
aSemSX3 := AddWkCpoUser(aSemSX3,"SWB")          

cNomArq:=E_CriaTrab(,aSemSX3)

IndRegua('TRB',cNomArq+TEOrdBagExt(),'WB_DT_VEN')

dDataIni:=AVCTOD('')
dDataFin:=AVCTOD('')

While .T.

   nOpcao :=0
   cTitulo:=STR0026 //"Relat¢rio de Importa‡äes em Ordem de Dt. Vencto"
/* ISS - 18/03/10 - Alteração do tamanho da tela para que a mesma não corte o botão "Confirmar"
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 17,45 Of oMainWnd */
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 24,50 Of oMainWnd
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 24/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT 
   
   @ 20,15 SAY STR0027 OF OPanel Pixel //"Data Vencto. Inicial:"
   @ 20,70 GET dDataIni OF OPanel SIZE 42,8 Pixel 

   @ 40,15 SAY STR0028 OF OPanel Pixel //"Data Vencto. Final:"
   @ 40,70 GET dDataFin  SIZE 42,8 OF OPanel Pixel ;

   bOk     := {||nOpcao:=1,oDlg:End()}
   bCancel := {||nOpcao:=0,oDlg:End()}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   
   If nOpcao == 0
      Exit
   Endif

   If lR4
      //TRP - 02/08/2006 - Relatório Personalizavel - Release 4
      //ReportDef cria os objetos.
      oReport := ReportDef()
   EndIf 
   
   DBSELECTAREA('TRB')
   AvZap()
   SW2->(DBSETORDER(1))
   SA2->(DBSETORDER(1))
   SW7->(DBSETORDER(1))
   SWA->(DBSETORDER(1))
   SWB->(DBSETORDER(1))
   SWB->(DBSEEK(xFilial("SWB")))
   DBSELECTAREA('SWB')

   lNaoTem:=.T.
   bImp:={||AP181Gera()}
   bFor:={||AP181For()}
   nCont:=SWB->(Easyreccount("SWB"))
   Processa({||ProcRegua(nCont), SWB->(DBEVAL(bImp,bFor)) },STR0029) //"Lendo Cambio..."

   IF lNaoTem
      Help("", 1, "AVG0000219")//E_MSG(STR0007,1) //"NÆo existe registros a serem listados"
      LOOP
   ENDIF

   TRB->(DBGOTOP())
   nCont:=TRB->(Easyreccount("TRB"))
   bImp:={||AP181Calc()}
   Processa({||ProcRegua(nCont),EVAL(bImp)},STR0030) //"Calculando..."

   If(lR4,oReport:PrintDialog(),AP181Relatorio())

End

TRB->(E_EraseArq(cNomArq))

DBSELECTAREA('SWB')


Return(NIL) 

*--------------------------------*
 STATIC FUNCTION AP181For()
*--------------------------------*

If SWB->WB_FILIAL != xFilial("SWB")
   Return .F.
EndIf

IF !EMPTY(SWB->WB_CA_DT)
   RETURN .F.
ENDIF

IF EMPTY(WB_DT_VEN)
   RETURN .F.
ENDIF

IF !EMPTY(dDataIni) .AND. SWB->WB_DT_VEN < dDataIni
   RETURN .F.
ENDIF

IF !EMPTY(dDataFin) .AND. SWB->WB_DT_VEN >  dDataFin
   RETURN .F.
ENDIF

IF lCposAntecip .AND. SWB->WB_PO_DI == "D" .AND. SWB->WB_FOBMOE == 0
   RETURN .F.
ENDIF

//** GFC - 02/12/05 - Não considerar os registros com tipos de contrato 3 ou 4
If lWB_TP_CON .and. SWB->WB_TP_CON $ ("3/4")
   Return .F.
EndIf
//**

RETURN .T.

*-----------------------------*
 STATIC FUNCTION AP181Gera()
*-----------------------------*
LOCAL cCodHawb,cCodPo,nVlParc,cChavSWA
LOCAL cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

IncProc(STR0031+SWB->WB_HAWB) //"Lendo Processo: "
cChavSWA := xFilial("SWA")+SWB->WB_HAWB
IF lCposAntecip
   cChavSWA += SWB->WB_PO_DI 
ENDIF
SWA->(DBSEEK(cChavSWA))
IF lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 28/08/2013
   cCodHawb := AvKey(SWB->WB_HAWB, "W2_PO_NUM")   
   cCodPo   := SWB->WB_HAWB         
   nVlParc  := SWB->WB_PGTANT
   lImpObs  := .T.
ELSE
   SW7->(DBSEEK(xFilial("SW7")+SWB->WB_HAWB))
   cCodHawb := SWB->WB_HAWB
   cCodPo   := SW7->W7_PO_NUM
   nVlParc  := SWB->WB_FOBMOE
ENDIF                   
SW2->(DBSEEK(xFilial("SW2")+cCodPo))
SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+SWB->WB_LOJA))

lNaoTem:=.F.

TRB->(DBAPPEND())
//AOM - 01/02/2011
AVREPLACE("SWB","TRB")
TRB->WB_HAWB   :=cCodHawb   
TRB->WB_FOBMOE :=nVlParc 
TRB->WA_PRODUTO:=SWA->WA_PRODUTO
TRB->A2_NREDUZ :=SA2->A2_NREDUZ
TRB->WB_DT_VEN :=SWB->WB_DT_VEN 
TRB->W2_MOEDA  :=SWB->WB_MOEDA 
TRB->WB_PO_DI  :=SWB->WB_PO_DI
TRB->WB_INVOICE:=SWB->WB_INVOICE
TRB->W2_COND_PA:=SW2->W2_COND_PA
TRB->WB_FORN   :=SWB->WB_FORN
TRB->WB_LOJA   :=SWB->WB_LOJA
TRB->WB_LINHA  :=SWB->WB_LINHA

//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   TRB->WB_TP_CON := AllTrim(BscXBox("WB_TP_CON",SWB->WB_TP_CON))
EndIf
   TRB->WB_TIPOREG:= AllTrim(AvTabela("Y6",SWB->WB_TIPOREG))
//**

IF !EMPTY(SWB->WB_CA_TX)
   M->WB_TIPOREG  :=Left(SWB->WB_TIPOREG,1)
   IF lCposAntecip
      M->WB_PGTANT := SWB->WB_PGTANT
   ENDIF
   TRB->WB_FOBREAL:=Ape_Vl_Real(nVlParc,SWB->WB_CA_TX)
ELSE
   TRB->WB_FOBREAL:=nVlParc * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_VEN,,.F.)
ENDIF

IF SWB->WB_MOEDA $ cMoedaDolar //'US$,USD'
   TRB->WB_FOBUSS:=TRB->WB_FOBMOE
ELSE
   nVlrRS :=TRB->WB_FOBMOE * BuscaTaxa(SWB->WB_MOEDA,TRB->WB_DT_VEN,,.F.)
   TRB->WB_FOBUSS:=nVlrRS / BuscaTaxa(cMoedaDolar,TRB->WB_DT_VEN,,.F.)
ENDIF

RETURN .T.

*----------------------------*
 STATIC FUNCTION AP181Calc()
*----------------------------*

cDia :=TRB->WB_DT_VEN
nMes1:=MONTH(TRB->WB_DT_VEN)
nAno1:=YEAR(TRB->WB_DT_VEN)
nUSSDia:=nRSDia:=nUSSMes:=nRSMes:=0

DO WHILE TRB->(!EOF())

   IncProc(STR0032+TRB->WB_HAWB) //"Calculando Processo: "

   IF cDia #TRB->WB_DT_VEN
      TRB->(DBSKIP(-1))
      TRB->WB_USS_DIA:=nUSSDia
      TRB->WB_RS_DIA :=nRSDia 
      TRB->(DBSKIP())
      cDia:=TRB->WB_DT_VEN
      nUSSDia:=0
      nRSDia :=0
   ENDIF

   IF nMes1 #MONTH(TRB->WB_DT_VEN) .OR.;
      nAno1 #YEAR(TRB->WB_DT_VEN)
      TRB->(DBSKIP(-1))
      TRB->WB_USS_MES :=nUSSMes
      TRB->WB_RS_MES  :=nRSMes 
      TRB->(DBSKIP())
      nMes1:=MONTH(TRB->WB_DT_VEN)
      nAno1:=YEAR(TRB->WB_DT_VEN)
      nUSSMes:=0
      nRSMes :=0
   ENDIF

   nUSSDia:=nUSSDia+TRB->WB_FOBUSS
   nRSDia :=nRSDia +TRB->WB_FOBREAL
   nUSSMes:=nUSSMes+TRB->WB_FOBUSS
   nRSMes :=nRSMes +TRB->WB_FOBREAL

   TRB->(DBSKIP())

ENDDO

TRB->(DBSKIP(-1))
TRB->WB_USS_DIA:=nUSSDia
TRB->WB_RS_DIA :=nRSDia 
TRB->WB_USS_MES:=nUSSMes
TRB->WB_RS_MES :=nRSMes 

RETURN .T.

*----------------------------------*
 STATIC FUNCTION AP181Relatorio()
*----------------------------------*

oPrn := PrintBegin('',.F.,.F.)
   oSend( oPrn, 'SetLandScape' )
PrintEnd()

AVPRINT oPrn NAME cTitulo

   DEFINE FONT oFont1  NAME 'Courier New' SIZE 0,07 OF  oPrn
   DEFINE FONT oFont2  NAME 'Courier New' SIZE 0,08 OF  oPrn
   DEFINE FONT oFont3  NAME 'Courier New' SIZE 0,10 OF  oPrn
   DEFINE FONT oFont4  NAME 'Courier New' SIZE 0,12 OF  oPrn

   AVPAGE

      oPrnoFont:=COURIER_07
      
      lPrimPag:= .T.
      nPag    := 0000
      nLin    := 9999
      nLimPage:= 2150
      nColFim := 3150
      nColIni := 0001
      nTam    := 0075
      nPula   := 0045
      
      cPictFOB:=Alltrim(X3Picture('WB_VL_CORR'))
      cPictCor:=Alltrim(X3Picture('WB_VL_CORR'))
      cPictCtl:=Alltrim(X3Picture('WA_CTRL'))
      nVlrME:=nVlrUSS:=nVlrRS:=0
      nVlrUSDia:=nVlrRSDia:=nVlrUSMes:=nVlrRSMes:=0
      nLag:=LEN(cPictFOB)-3

      nCol1:=nColIni ; nCol2:=640 ; nCol3:=0910
      nCol4:=0940    ; nCol5:=1590; nCol6:=1950 
      nCol7:=2370    ; nCol8:=2650; nCol9:=2930
      nCol10:=0290   ; nCol11:=nCol9+50

      TRB->(DBGOTOP())
      nCont:=TRB->(Easyreccount("TRB"))
      bImp :={||AP181Detalhe()}
      Processa({||ProcRegua(nCont), TRB->(DBEVAL(bImp)) },STR0033) //"Impressao"
      AP181Tot()

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

RETURN .T.

*--------------------------*
 STATIC FUNCTION AP181Cab()
*--------------------------*
IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF

nLin:= 100
nPag := nPag  + 1

cTitulo1:=STR0034 //"IMPORTACOES EM ORDEM DE DATA DE VENCIMENTO"
cTitulo2:=STR0035 //"PARA PREVISAO FINANCEIRA E ORCAMENTO DE CAIXA"
nCol:=LEN(cTitulo2)
cTitulo2:=cTitulo2

cC01:=STR0013 //"Processo"
cC010:=STR0018 //"MOEDA"
cC02:=STR0036 //"VLR EM ME"
cC03:=STR0020 //"VLR EM US$"
cC04:=STR0037 //"PRODUTO"
cC05:=STR0038 //"Fornecedor"
cC06:=STR0039 //"DT VENCTO"
cC07:=STR0040 //"VLR EM RS"
cC08:=STR0041 //"US$ POR DIA"
cC09:=STR0042 //"R$ POR DIA"
//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   cC011:=AvSX3("WB_TP_CON",5) //Tipo Contra.
EndIf
//**

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin+=25

oPrn:Say(nLin,01,SM0->M0_NOME,COURIER_12)
oPrn:Say(nLin,nColFim/2,cTitulo1,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,STR0023+STR(nPag,8),COURIER_12,,,,1) //"Pagina..: "
nLin+=50

oPrn:Say(nLin,01,STR0024,COURIER_12) //"SIGAEIC"
oPrn:Say(nLin,nColFim/2,cTitulo2,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,STR0025+DTOC(dDataBase),COURIER_12,,,,1) //"Emissao.: "
nLin+=50

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin +=50

oSend(oPrn,'oFont',COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol1,cC01,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol10,cC010,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol2,cC02,COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol3,cC03,COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol4,cC04,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol5,cC05,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol6,cC06,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol7,cC07,COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8,cC08,COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9,cC09,COURIER_07,,,,1)
//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   oSend( oPrn, 'SAY',nLin,nCol11,cC011,COURIER_07)
EndIf
//**
nLin:=nLin+30

cC04:=LEN(TRB->WA_PRODUTO)

oSend( oPrn, 'SAY',nLin,nCol1,REPL('-',17),COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol10,REPL('-',5),COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol2,REPL('-',nLag),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol3,REPL('-',nLag),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol4,REPL('-',cC04),COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol5,REPL('-',20),COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol6,REPL('-',LEN(cC06)),COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',nLag),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',nLag),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',nLag),COURIER_07,,,,1)
//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   oSend( oPrn, 'SAY',nLin,nCol11,REPL('-',nLag),COURIER_07)
EndIf
//**
nLin:=nLin+nPula          

RETURN .T.

*---------------------------------*
 STATIC FUNCTION AP181Detalhe()
*---------------------------------*
IncProc(STR0008+TRB->WB_HAWB) //"Imprimindo Processo: "

IF nLin > (nLimPage-nPula)
   AP181Cab()
ENDIF

oSend(oPrn,'oFont',COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol1 ,TRB->WB_HAWB ,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol10+15,TRB->W2_MOEDA,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol2 ,TRANS(TRB->WB_FOBMOE,cPictCor),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol3 ,TRANS(TRB->WB_FOBUSS,cPictCor),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol4 ,TRB->WA_PRODUTO,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol5 ,TRB->A2_NREDUZ,COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol6 ,DTOC(TRB->WB_DT_VEN),COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol7 ,TRANS(TRB->WB_FOBREAL,cPictCor),COURIER_07,,,,1)

IF !EMPTY(TRB->WB_USS_DIA)
   oSend( oPrn, 'SAY',nLin,nCol8 ,TRANS(TRB->WB_USS_DIA,cPictCor),COURIER_07,,,,1)
ENDIF
IF !EMPTY(TRB->WB_RS_DIA)
   oSend( oPrn, 'SAY',nLin,nCol9 ,TRANS(TRB->WB_RS_DIA ,cPictCor),COURIER_07,,,,1)
ENDIF

//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   oSend( oPrn, 'SAY',nLin,nCol11 ,TRB->WB_TP_CON,COURIER_07)
EndIf
//**

IF !EMPTY(TRB->WB_USS_MES) .OR. !EMPTY(TRB->WB_RS_MES)
   nLin:=nLin+nPula-10
   IF nLin > (nLimPage-nPula*2)
      AP181Cab()
   ENDIF
   oSend( oPrn, 'SAY',nLin,nCol3,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',nLag),COURIER_07,,,,1)
   nLin:=nLin+nPula-10
   cMes:=STR0043+PADL(MONTH(TRB->WB_DT_VEN),2,"0")+" " //"Total Mes: "
   oSend( oPrn, 'SAY',nLin,nCol3,cMes+TRANS(TRB->WB_USS_MES,cPictCor),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,cMes+TRANS(TRB->WB_RS_MES ,cPictCor),COURIER_07,,,,1)
   nLin:=nLin+20
ENDIF

nVlrUSS  :=nVlrUSS+TRB->WB_FOBUSS
nVlrRS   :=nVlrRS +TRB->WB_FOBREAL
nVlrUSDia:=nVlrUSDia+TRB->WB_USS_DIA 
nVlrRSDia:=nVlrRSDia+TRB->WB_RS_DIA  

nLin:=nLin+nPula           

RETURN .T.

*---------------------------------*
 STATIC FUNCTION AP181Tot()
*---------------------------------*
Local cMensObs:=STR0108//"Os processos iniciados com * referem-se a Adiantamentos - Número do Pedido"

IF nLin > (nLimPage-nPula*2)
   AP181Cab()
ENDIF

oSend( oPrn, 'SAY',nLin,nCol3 ,REPL('-',nLag),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol7 ,REPL('-',nLag),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8 ,REPL('-',nLag),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9 ,REPL('-',nLag),COURIER_07,,,,1)

nLin:=nLin+nPula           
oSend( oPrn, 'SAY',nLin,nCol1 ,STR0044,COURIER_07) //"Total Geral:"
oSend( oPrn, 'SAY',nLin,nCol3 ,TRANS(nVlrUSS  ,cPictFOB),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol7 ,TRANS(nVlrRS   ,cPictCor),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol8 ,TRANS(nVlrUSDia,cPictFOB),COURIER_07,,,,1)
oSend( oPrn, 'SAY',nLin,nCol9 ,TRANS(nVlrRSDia,cPictFOB),COURIER_07,,,,1)

IF lImpObs             
   nLin:=nLin+nPula
   oSend( oPrn, 'SAY',nLin,nCol1 ,cMensObs,COURIER_07,,,,1) 
ENDIF
RETURN .T.

//EICAP182 - MNU - Relatorios de Cambio Fechado
Function EICAP182()

EICAP182R3(.T.)
Return .t.
*----------------------------*
FUNCTION EICAP182R3(p_R4)
*----------------------------*
Local nOpca 
Local cMarca := GetMark(), lInverte := .F. 
LOCAL oPanel182
Local aCamposBr :=;
     { {{||TRB->WB_HAWB    }, "", STR0106 },; //"PROCESSO"
       {{||TRB->WA_PRODUTO }, "", STR0037 },; //"PRODUTO"
       {{||TRB->A2_NREDUZ  }, "", STR0105 },; //"FORNECEDOR"
       {{||TRB->WB_DT_VEN  }, "", STR0039 },; //"DT_VENCTO"
       {{||TRB->WB_DT_CONT }, "", STR0103 },; //"DT CONTRATACAO"
       {{||TRB->WA_CTRL    }, "", STR0104 },; //"NRO CONTR"
       {{||TRB->WB_CA_TX   }, "", STR0073 },; //"TAXA DO CAMBIO"
       {{||TRB->WB_DT_DESE }, "", STR0101 },; //"DT DESEMB."
       {{||TRB->WB_BANCO   }, "", STR0016 }} //"BANCO."
Private cTotal:=0
Private cNome, cData
Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 //GFC - 02/12/05
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
cFun := "182"

//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   aAdd(aCamposBr,{{||TRB->WB_TP_CON }, "", AvSX3("WB_TP_CON",5) }) //Tipo Contra.
EndIf
   aAdd(aCamposBr,{{||TRB->WB_TIPOREG }, "", AvSX3("WB_TIPOREG",5) }) //Tipo Contra.
//**

SX3->(DBSETORDER(2))
PRIVATE lCposAntecip:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
SX3->(DBSETORDER(1))

PRIVATE lImpObs := .F.

cNomArq:=cNomArq1:=cNomArq2:=cNomArq3:=cNomArq4:=cNomArq5:=''

bImp:={||AP182Inicia()}

Processa({||ProcRegua(7),EVAL(bImp)},STR0045) //"Aguarde, Iniciando..."

cTitulo:=STR0046 //"Relat¢rios de Cambio Fechado"
cRel1  :=STR0047 //"1-Controladoria Central"
cRel2  :=STR0048 //"2-Com‚rcio Exterior"
cRel3  :=STR0049 //"3-Import. em Ordem de Prod. e Vencto."
cRel4  :=STR0050 //"4-Importa‡äes - Relat¢rio Mensal"
cRel5  :=STR0051 //"5-Importa‡Æo - Estat¡stica Bancaria"
aRel   :={cRel1,cRel2,cRel3,cRel4,cRel5}
cRel   :=cRel1
cTipo1 :=STR0052 //"1-Data do Cƒmbio"
cTipo2 :=STR0053 //"2-Nr. Processo"
cTipo3 :=STR0054 //"3-Numero File"
cTipo4 :=STR0100 //"4-Data de Desembolso"
aTipo  :={cTipo1,cTipo2,cTipo3,cTipo4}
cTipo  :=cTipo1
dDataIni:=AVCTOD('')
dDataFin:=AVCTOD('')



Do While .T.

   nOpcao :=0
/* ISS - 18/03/10 - Alteração do tamanho da tela para que a mesma não corte o botão "Confirmar"
   oDlg := oSend( MSDialog(), 'New', 9, 0, 23, 45,;
                  cTitulo,,,.F.,,,,,oMainWnd,.F.,,,.F.)*/
   oDlg := oSend( MSDialog(), 'New', 9, 0, 26, 50,;
                  cTitulo,,,.F.,,,,,oMainWnd,.F.,,,.F.)
                  
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT               
   
   @ 02,03 SAY STR0004 OF oPanel //"Relat¢rio:"
   @ 02,07 COMBOBOX cRel ITEMS aRel  SIZE 110,08 OF oPanel

   @ 03,03 SAY STR0005 OF oPanel //"Data Inicial:"
   @ 03,07 GET dDataIni  SIZE 42,8 OF oPanel 

   @ 04,03 SAY STR0006 OF oPanel //"Data Final:"
   @ 04,07 GET dDataFin  SIZE 42,8 OF oPanel ;

   @ 05,03 SAY STR0055 OF oPanel //"Ordenar por:"
   @ 05,07 COMBOBOX cTipo ITEMS aTipo  SIZE 70,80 OF oPanel WHEN (cRel == cRel1) 


   bOk     := {||nOpcao:=1,oDlg:End()}
   bCancel := {||nOpcao:=0,oDlg:End()}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED


   If nOpcao == 0 
      TRB->(E_EraseArq(cNomArq,cNomArq1,cNomArq2))
				
      FERASE(cNomArq3+TEOrdBagExt())
      FERASE(cNomArq4+TEOrdBagExt()) 
      FERASE(cNomArq5+TEOrdBagExt())

      Return
   Endif  

   DBSELECTAREA('TRB')
   AvZap()
   SA6->(DBSETORDER(1))
   SA2->(DBSETORDER(1))
   SW2->(DBSETORDER(1))
   SW7->(DBSETORDER(1))
   SWA->(DBSETORDER(1))
   SWB->(DBSETORDER(1))
   SWB->(DBSEEK(xFilial("SWB")))
   DBSELECTAREA('SWB')
   cTotal := 0

   lNaoTem:=.T.
   bImp:={||AP182Gera()}
   bFor:={||AP182For()}
   bWhile:={||SWB->(WB_FILIAL == xFilial())}
   nCont:=SWB->(Easyreccount("SWB"))
   Processa({||ProcRegua(nCont), SWB->(DBEVAL(bImp,bFor,bWhile)) },STR0029) //"Lendo Cambio..."
			
   IF lNaoTem
      Help("", 1, "AVG0000219")//E_MSG(STR0007,1) //"NÆo existe registros a serem listados"
      LOOP
   ENDIF
			
   IF cRel1==cRel 
      IF     cTipo == cTipo1 ; TRB->(DBSETORDER(1))
      ELSEIF cTipo == cTipo2 ; TRB->(DBSETORDER(3))
      ELSEIF cTipo == cTipo3 ; TRB->(DBSETORDER(4))
      ELSEIF cTipo == cTipo4 ; TRB->(DBSETORDER(6))
      ENDIF
   ELSEIF cRel2==cRel ; TRB->(DBSETORDER(1))
      ELSEIF cRel3==cRel ; TRB->(DBSETORDER(2))
      ELSEIF cRel4==cRel ; TRB->(DBSETORDER(1))
      ELSEIF cRel5==cRel ; TRB->(DBSETORDER(5))
   ENDIF
			
   IF cRel==cRel3 .OR. cRel==cRel5
      TRB->(DBGOTOP())
      nCont:=TRB->(Easyreccount("TRB"))
      bImp:={||AP182Calc()}
      Processa({||ProcRegua(nCont),EVAL(bImp)},STR0030) //"Calculando..."
   ENDIF
			   			    
   TRB->(DBGOTOP())
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE STR0107 ;
      From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
      
      @ 00,00 MsPanel oPanel182 Prompt "" Size 10,35 of oDlg   // ACSJ - 13/05/2004

	  DEFINE SBUTTON FROM 17,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),AP182Relatorio())) ENABLE OF oPanel182

	  @ 1.5,03 SAY "Total" of oPanel182
	  @ 1.5,05 GET cTotal  Picture "@E 9,999,999,999.99" SIZE 70,08 WHEN .F.  of oPanel182

      @ 1.5,50 BUTTON  STR0102 Size 60,12 ACTION (TR350ARQUIVO("TRB")) of oPanel182   //"GERAR ARQUIVO"   
   
      //by GFP - 29/09/2010 :: 10:05 - Inclusão da função para carregar campos criados pelo usuario.
      aCamposBr := AddCpoUser(aCamposBr,"SWB","2","TRB")   
   
      oMark:= MsSelect():New("TRB",,,aCamposBr,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
      oPanel182:Align := CONTROL_ALIGN_TOP
      oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 16/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   // ACSJ - 13/05/2004
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},; //BCO 16/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                                                      {||nOpca:=0,oDlg:End()}))// ACSJ - 13/05/2004
   If nOpca == 0
      EXIT
   Endif                                                        

EndDo

TRB->(E_EraseArq(cNomArq,cNomArq1,cNomArq2))

FERASE(cNomArq3+TEOrdBagExt())
FERASE(cNomArq4+TEOrdBagExt()) 
FERASE(cNomArq5+TEOrdBagExt())

DBSELECTAREA('SWB')

Return(NIL)
*---------------------------------*
 STATIC FUNCTION AP182Inicia()
*---------------------------------*

IncProc(STR0056) //"Criando Arquivo Temporario"

aSemSX3:={{'WB_USS_TOT','N',15,2},;
          {'WB_RS_TOT' ,'N',15,2},; 
          {'WB_FOBREAL','N',15,2},; 
          {'WB_FOBMOE' ,'N',15,2},;           
          {'WB_FOBUSS' ,'N',15,2},;
          {'WB_CA_NUM' ,'C',15,0}}

//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   aAdd(aSemSX3,{'WB_TP_CON' ,'C',25,0})
EndIf
aAdd(aSemSX3,{'WB_TIPOREG' ,'C',25,0})
//**

aHeader:=ARRAY(0)
aCampos:={'WB_HAWB','WA_PRODUTO','A2_NREDUZ','WB_DT_VEN',;
          'WB_DT_CONT','WA_CTRL'}

AADD(aCampos,'W2_MOEDA')
AADD(aCampos,'WB_CA_TX')
AADD(aCampos,'WB_DT_DESE')
AADD(aCampos,'WB_BANCO')
AADD(aCampos,'A6_NOME')  


//AOM - 01/02/2011
aSemSX3 := AddWkCpoUser(aSemSX3,"SWB")

cNomArq:=E_CriaTrab(,aSemSX3)

IncProc(STR0057)//1 //"Criando Indice Temporario 1/5"
IndRegua('TRB',cNomArq+TEOrdBagExt(),'DTOS(WB_DT_CONT)')//1

IncProc(STR0058)//2 //"Criando Indice Temporario 2/5"
cNomArq1:=E_Create(,.F.)
IndRegua('TRB',cNomArq1+TEOrdBagExt(),'WA_PRODUTO+DTOS(WB_DT_VEN)')
                                                                 
IncProc(STR0059)//3                           //"Criando Indice Temporario 3/5"
cNomArq2:=E_Create(,.F.)                                         
IndRegua('TRB',cNomArq2+TEOrdBagExt(),'WB_HAWB')//2                
                                                                 
IncProc(STR0060)//4                           //"Criando Indice Temporario 4/5"
cNomArq3:=E_Create(,.F.)                                         
IndRegua('TRB',cNomArq3+TEOrdBagExt(),'WA_CTRL')//3
                                                                 
IncProc(STR0061)//5                           //"Criando Indice Temporario 5/5"
cNomArq4:=E_Create(,.F.)                                         
IndRegua('TRB',cNomArq4+TEOrdBagExt(),'A6_NOME+WB_BANCO')          

IncProc(STR0100)//6 //"Criando Indice Temporario "
cNomArq5:=E_Create(,.F.)
IndRegua('TRB',cNomArq5+TEOrdBagExt(),'WA_PRODUTO+DTOS(WB_DT_DESE)')

SET INDEX TO (cNomArq+TEOrdBagExt()),(cNomArq1+TEOrdBagExt()),(cNomArq2+TEOrdBagExt()),(cNomArq3+TEOrdBagExt()),(cNomArq4+TEOrdBagExt()),(cNomArq5+TEOrdBagExt())
          

RETURN

*-------------------------------------*
 STATIC FUNCTION AP182For()
*-------------------------------------*
Private g
IF cTipo <> cTipo4
   IF EMPTY(SWB->WB_DT_CONT)
      RETURN .F.
   ENDIF

   IF EMPTY(SWB->WB_DT_VEN)
      RETURN .F.
   ENDIF

   IF !EMPTY(dDataIni) .AND. SWB-> WB_DT_CONT < dDataIni
      RETURN .F.
   ENDIF

   IF !EMPTY(dDataFin) .AND. SWB->WB_DT_CONT >  dDataFin
      RETURN .F.
   ENDIF
Else
   IF EMPTY(SWB->WB_DT_DESE)
      RETURN .F.
   ENDIF
 
   IF EMPTY(SWB->WB_DT_VEN)
      RETURN .F.
   ENDIF
 
   IF !EMPTY(dDataIni) .AND. SWB-> WB_DT_DESE < dDataIni
      RETURN .F.
   ENDIF

   IF !EMPTY(dDataFin) .AND. SWB->WB_DT_DESE >  dDataFin
      RETURN .F.
   ENDIF
ENDIF
IF lCposAntecip .AND. SWB->WB_PO_DI == "D" .AND. SWB->WB_FOBMOE == 0
   RETURN .F.
ENDIF

//** GFC - 02/12/05 - Não considerar os registros com tipos de contrato 3 ou 4
If lWB_TP_CON .and. SWB->WB_TP_CON $ ("3/4")
   Return .F.
EndIf
//**

RETURN .T.

*-----------------------------*
 STATIC FUNCTION AP182Gera()
*-----------------------------*
LOCAL cCodHawb,cCodPo,nVlParc
Local cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

IncProc(STR0031+SWB->WB_HAWB) //"Lendo Processo: "
                              
cChavSWA := xFilial("SWA")+SWB->WB_HAWB
IF lCposAntecip
   cChavSWA += SWB->WB_PO_DI 
ENDIF
SWA->(DBSEEK(cChavSWA))
IF lCposAntecip .And. SWB->WB_PO_DI == "A"
   SW2->(DBSEEK(xFilial("SW2")+SWB->WB_HAWB))
   SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
   cCodHawb := AvKey(SWB->WB_HAWB, "W2_PO_NUM")   
   cCodPo   := SWB->WB_HAWB         
   nVlParc  := SWB->WB_PGTANT   
   lImpObs  := .T.
ElseIf lCposAntecip .And. (SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 28/08/2013 - Tratamento das novas modalidades de pagamento antecipado
   cCodHawb := AvKey(SWB->WB_HAWB, "W2_PO_NUM")   
   cCodPo   := SWB->WB_HAWB         
   nVlParc  := SWB->WB_PGTANT   
   lImpObs  := .T.
Else
   SW7->(DBSEEK(xFilial("SW7")+SWB->WB_HAWB))  
   cCodHawb := SWB->WB_HAWB
   cCodPo   := SW7->W7_PO_NUM
   nVlParc  := SWB->WB_FOBMOE   
ENDIF                          

SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+SWB->WB_LOJA))
SW2->(DBSEEK(xFilial("SW2")+cCodPo))
SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO))

lNaoTem:=.F.

TRB->(DBAPPEND())
//AOM - 01/02/2011
AVREPLACE("SWB","TRB")
TRB->WB_HAWB   :=cCodHawb   
TRB->WB_FOBMOE :=nVlParc 
TRB->WA_PRODUTO:=LEFT(SWA->WA_PRODUTO,30)
TRB->A2_NREDUZ :=SA2->A2_NREDUZ  
TRB->WB_DT_VEN :=SWB->WB_DT_VEN 
TRB->WB_DT_DESE:=SWB->WB_DT_DESE
TRB->W2_MOEDA  :=SWB->WB_MOEDA
TRB->WB_DT_CONT:=SWB->WB_DT_CONT
TRB->WA_CTRL   :=SWA->WA_CTRL
TRB->WB_CA_TX  :=SWB->WB_CA_TX
TRB->WB_BANCO  :=SWB->WB_BANCO
TRB->A6_NOME   :=LEFT(SA6->A6_NOME,20)
TRB->WB_CA_NUM :=SWB->WB_CA_NUM

//** GFC - 02/12/05 - Tipo do Contrato
If lWB_TP_CON
   TRB->WB_TP_CON := AllTrim(BscXBox("WB_TP_CON",SWB->WB_TP_CON))
EndIf
//**
TRB->WB_TIPOREG := AllTrim(AvTabela("Y6",SWB->WB_TIPOREG))
IF !EMPTY(SWB->WB_CA_TX)
   M->WB_TIPOREG := Left(SWB->WB_TIPOREG,1)
   IF lCposAntecip
      M->WB_PGTANT := SWB->WB_PGTANT
   ENDIF
   TRB->WB_FOBREAL:=Ape_Vl_Real(nVlParc,SWB->WB_CA_TX)
   IF SWB->WB_MOEDA $ cMoedaDolar //'US$,USD'
      TRB->WB_FOBUSS:=TRB->WB_FOBMOE
   ELSE
      nVlrRS := TRB->WB_FOBREAL
      TRB->WB_FOBUSS:=TRB->WB_FOBREAL / BuscaTaxa(cMoedaDolar,TRB->WB_DT_CONT,,.F.)
   ENDIF
ELSE
   TRB->WB_FOBREAL:=nVlParc * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_VEN,,.F.)
   IF SWB->WB_MOEDA $ cMoedaDolar //'US$,USD'
      TRB->WB_FOBUSS:=TRB->WB_FOBMOE
   ELSE
      nVlrRS := TRB->WB_FOBREAL
      TRB->WB_FOBUSS:=TRB->WB_FOBREAL / BuscaTaxa(cMoedaDolar,TRB->WB_DT_VEN,,.F.)
   ENDIF
ENDIF    
   
cTotal+=TRB->WB_FOBREAL    


RETURN .T.

*---------------------------------*
 STATIC FUNCTION AP182Calc()
*---------------------------------*
Local CAMPO:= IF(cRel==cRel3,TRB->WA_PRODUTO,TRB->A6_NOME)

cColuna:=CAMPO

nUSSTot:=nRSTot:=0

DO WHILE TRB->(!EOF())

   IncProc(STR0032+TRB->WB_HAWB) //"Calculando Processo: "

   IF cColuna #CAMPO
      TRB->(DBSKIP(-1))
      TRB->WB_USS_TOT:=nUSSTOT
      TRB->WB_RS_TOT :=nRSTOT 
      TRB->(DBSKIP())
      cColuna:=CAMPO
      nUSSTot:=0
      nRSTot :=0
   ENDIF

   nUSSTot:=nUSSTot+TRB->WB_FOBUSS
   nRSTot :=nRSTot +TRB->WB_FOBREAL

   TRB->(DBSKIP())

ENDDO

TRB->(DBSKIP(-1))
TRB->WB_USS_TOT:=nUSSTot
TRB->WB_RS_TOT :=nRSTot 

RETURN .T.

*--------------------------------------*
 STATIC FUNCTION AP182Relatorio()
*--------------------------------------*
LOCAL cMensObs:=STR0108//"Os processos iniciados com * referem-se a Adiantamentos - Número do Pedido"
oPrn := PrintBegin('',.F.,.F.)
   IF cRel2 == cRel 
      oSend( oPrn,'SetPortrait')
   ELSE
      oSend( oPrn,'SetLandScape')
   ENDIF
PrintEnd()


AVPRINT oPrn NAME cTitulo

   DEFINE FONT oFont0  NAME 'Courier New' SIZE 0,07      OF  oPrn
   DEFINE FONT oFont2  NAME 'Courier New' SIZE 0,08      OF  oPrn
   DEFINE FONT oFont3  NAME 'Courier New' SIZE 0,10      OF  oPrn
   DEFINE FONT oFont4  NAME 'Courier New' SIZE 0,12      OF  oPrn
   DEFINE FONT oFont5  NAME 'Courier New' SIZE 0,08 BOLD OF  oPrn 

   AVPAGE

      oFont1:=oFont0
      IF(cRel==cRel3.OR.cRel==cRel5,oFont1:=oFont2,)

      oSend(oPrn,'oFont',COURIER_07)
      
      lPrimPag:= .T.
      nPag     := 0000
      nLin    := 9999
      nLimPage:= 2150
      nColFim := 3155
      nColIni := 0001
      nTam    := 0075
      nPula   := 0045
      
      cPictFOB:=Alltrim(X3Picture('WB_VL_CORR'))
      cPictCor:=Alltrim(X3Picture('WB_VL_CORR'))
      cPictCtl:=Alltrim(X3Picture('WA_CTRL'))
      cPicTaxa:=Alltrim(X3Picture('WB_CA_TX'))
      nVlrUS:=nVlrRS:=0
      nVlrRSTot:=nVlrUSTot:=0
      nLag:=LEN(cPictFOB)-3

      nCol1 :=nColIni
      nCol2 :=nCol1+275
      nCol3 :=nCol2+160
      nCol4 :=nCol3+340
      nCol5 :=nCol4+270
      nCol6 :=nCol5+30
      nCol7 :=nCol6+180
      nCol8 :=nCol7+170
      nCol9 :=nCol8+420
      nCol10:=nCol9+305
      nCol11:=nCol10+500
      nCol12:=nCol11+280
      //** GFC - 05/12/05
      If lWB_TP_CON
         nCol13:=nCol12+80
      EndIf
      //**
      IF cRel == cRel2
         nLimPage:= 3100
         nColFim := 2300
         nCol5:=nCol4+120
         nCol6:=nCol5+200
         nCol7:=nCol6+200 
         nCol8:=nCol7+400
         //** GFC - 05/12/05
         If lWB_TP_CON
            nCol9:=nCol8+210
         EndIf
         //**
      ELSEIF cRel == cRel3
         nCol2:=nCol1+550 
         nCol3:=nCol2+40  
         nCol4:=nCol3+540
         nCol5:=nCol4+380
         nCol6:=nCol5+450
         nCol7:=nCol6+280
         nCol8:=nCol7+310
         nCol9:=nCol8+300
         //** GFC - 05/12/05
         If lWB_TP_CON
            nCol10:=nCol9+100
         EndIf
         //**
      ELSEIF cRel == cRel4
         nCol2:=nCol1+269
         nCol3:=nCol2+350
         nCol4:=nCol3+285
         nCol5:=nCol4+20
         nCol6:=nCol5+350
         nCol7:=nCol6+30
         nCol8:=nCol7+420
         nCol9:=nCol8+330
         nCol10:=nCol9+140
         nCol11:=nCol10+145
         nCol12:=nCol11+140
         nCol13:=nCol12+500
         //** GFC - 05/12/05
         If lWB_TP_CON
            nCol14:=nCol13+100
         EndIf
         //**
         nMes1:=nAno1:=0
      ELSEIF cRel == cRel5
         nCol2:=nCol1+359
         nCol3:=nCol2+240
         nCol4:=nCol3+400
         nCol5:=nCol4+550
         nCol6:=nCol5+340
         nCol7:=nCol6+340
         nCol8:=nCol7+340
         nCol9:=nCol8+340
         //** GFC - 05/12/05
         If lWB_TP_CON
            nCol10:=nCol9+60
         EndIf
         //**
      ENDIF

      TRB->(DBGOTOP())
      nCont:=TRB->(Easyreccount("TRB"))
      bImp :={||AP182Detalhe()}
      Processa({||ProcRegua(nCont), TRB->(DBEVAL(bImp)) },STR0009) //"Impressao..."
      IF cRel #cRel2
         TRB->(DBSKIP(-1))
         AP182Tot()
      ENDIF
      IF lImpObs
         nLin:=nLin+nPula
         oSend( oPrn, 'SAY',nLin,nCol1,cMensObs,COURIER_07,,,,1)
      ENDIF

   AVENDPAGE

AVENDPRINT

oFont0:End( )
oFont2:End( )
oFont3:End( )
oFont4:End( )

RETURN .T.

*------------------------------*
 STATIC FUNCTION AP182Cab()
*------------------------------*
LOCAL cTitulo1:=cTitulo2:=cTitulo3:=""

IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF

nLin:= 100
nPag := nPag  + 1


DO CASE 
   CASE cRel1==cRel .OR. cRel2==cRel
        //cTitulo1:=STR0111 //"Câmbios Fechados - Controladoria Central"
        //cTitulo1:=STR0062 //"DE: FINANCAS"
        //cTitulo2:=STR0063+IF(cRel1==cRel,STR0064,; //"PARA: "###"CONTROLADORIA CENTRAL - UNPUT"
        //                                 STR0065) //"COMERCIO EXTERIOR"
        cTitulo3:=STR0066 //"IMPORTACOES - CAMBIOS FECHADOS"
        cTitulo3:=cTitulo3+STR0067+DTOC(dDataIni)+STR0012+DTOC(dDatafin) //" ENTRE "###" E "

   CASE cRel3==cRel
        cTitulo1:=STR0068 //"IMPORTACOES EM ORDEM DE PRODUTO E VENCIMENTO"

   CASE cRel4==cRel

        nMes1:=MONTH(TRB->WB_DT_CONT)
        nAno1:=YEAR(TRB->WB_DT_CONT)
        cTitulo1:=STR0069 //"IMPORTACOES - RELATORIO MENSAL"
        cTitulo1:=cTitulo1+" - "+UPPER(Nome_Mes(MONTH(TRB->WB_DT_CONT)))+"/"+STR(YEAR(TRB->WB_DT_CONT),4,0)
        
   CASE cRel5==cRel

        cTitulo1:=STR0070 //"IMPORTACAO - ESTATISTICA BANCARIA"
   
ENDCASE

cC01:=STR0013 //"Processo"
cC02:=STR0014 //"Nº FFC"
cC03:=STR0018 //"MOEDA"
cC04:=STR0036 //"VLR EM ME"
cC05:=STR0021 //"VLR EM R$"
cC06:=STR0017 //"DT DO CAMBIO"
cC07:=IF(cTipo == cTipo4,STR0101,STR0071 ) //"DT DESEMB" #### "DT DOS REAIS"
cC08:=STR0037 //"PRODUTO"
cC09:=STR0038 //"Fornecedor"
cC010:=STR0072 //"BANCO - CAMBIO"
cC011:=STR0073 //"TAXA CAMBIO"
cC012:=STR0099 //"NRO CAMBIO"
//** GFC - 05/12/05 - 
If lWB_TP_CON
   cC013:=AvSX3("WB_TP_CON",5)
EndIf
//**

IF cRel == cRel2
   cC05:=STR0074 //"DT VENCIMENTO"
   cC06:=STR0017 //"DT DO CAMBIO"
   cC07:=STR0037//"PRODUTO"
   cC08:=STR0099 //"NRO CAMBIO"
   //** GFC - 05/12/05 - 
   If lWB_TP_CON
      cC09:=AvSX3("WB_TP_CON",5)
   EndIf
   //**
ELSEIF cRel == cRel3
   cC02:=STR0075 //"VALOR EM US$"
   cC03:=STR0037 //"PRODUTO"
   cC04:=STR0038 //"Fornecedor"
   cC05:=STR0074 //"DT VENCIMENTO"
   cC06:=STR0076 //"VALOR EM R$"
   cC07:=STR0077 //"US$ POR PRODUTO"
   cC08:=STR0078 //"R$ POR PRODUTO"
   cC09:=STR0099 //"NRO CAMBIO"
   //** GFC - 05/12/05 - 
   If lWB_TP_CON
      cC10:=AvSX3("WB_TP_CON",5)
   EndIf
   //**
ELSEIF cRel == cRel4
   cC03:=STR0075 //"VALOR EM US$"
   cC04:=STR0076 //"VALOR EM R$"
   cC05:=STR0018 //"MOEDA"
   cC06:=STR0079 //"VALOR EM ME"
   cC07:=STR0037 //"PRODUTO"
   cC08:=STR0038 //"Fornecedor"
   cC09:=STR0074  //"DT VENC."
   cC010:=STR0017 //"DT CAMBIO"
   cC011:=STR0101 //"DT DESEMB"
   cC012:=STR0072+SPACE(6) //"BANCO - CAMBIO"
   cC013:=STR0099 //"NRO CAMBIO"
   //** GFC - 05/12/05 - 
   If lWB_TP_CON
      cC014:=AvSX3("WB_TP_CON",5)
   EndIf
   //**
ELSEIF cRel == cRel5
   cC03:=STR0016 //"BANCO"
   cC04:=STR0017 //"DT DO CAMBIO"
   cC05:=STR0075 //"VALOR EM US$"
   cC06:=STR0080 //"TOTAL US$ BANCO"
   cC07:=STR0076 //"VALOR EM R$"
   cC08:=STR0081 //"TOTAL R$ BANCO"
   cC09:=STR0099 //"NRO CAMBIO"
   //** GFC - 05/12/05 - 
   If lWB_TP_CON
      cC010:=AvSX3("WB_TP_CON",5)
   EndIf
   //**
ENDIF

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin+=25

oPrn:Say(nLin,01,SM0->M0_NOME,COURIER_12)
oPrn:Say(nLin,nColFim/2,cTitulo1,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,STR0023+STR(nPag,8),COURIER_12,,,,1) //"Pagina..: "
nLin+=50

oPrn:Say(nLin,01,STR0024,COURIER_12) //"SIGAEIC"
oPrn:Say(nLin,nColFim/2,cTitulo2,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,STR0025+DTOC(dDataBase),COURIER_12,,,,1) //"Emissao.: "
nLin+=50

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin +=25

oPrn:oFont:=COURIER_07

IF !EMPTY(cTitulo3)
   oSend( oPrn, 'SAY',nLin,nCol1,cTitulo3,COURIER_14)
   nLin:=nLin+25
ENDIF   

nLin +=25

oSend( oPrn, 'SAY',nLin,nCol1,cC01,COURIER_07)

IF cRel #cRel3
   oSend( oPrn, 'SAY',nLin,nCol2,cC02,COURIER_07)
ENDIF

IF cRel==cRel1 .OR. cRel==cRel2
   oSend( oPrn, 'SAY',nLin,nCol3,cC03,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4,cC04,COURIER_07,,,,1)
ENDIF

IF cRel == cRel1
   oSend( oPrn, 'SAY',nLin,nCol5,cC05,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6+05,cC06,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol7+05,cC07,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8,cC08,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol9,cC09,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol10,cC010,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol11,cC011,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol12-70,cC012,COURIER_07,,,,1)   
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol13,cC013,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel2
   oSend( oPrn, 'SAY',nLin,nCol5,cC05,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6,cC06,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol7,cC07,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8,cC08,COURIER_07)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol9,cC09,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel3
   oSend( oPrn, 'SAY',nLin,nCol2,cC02,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol3,cC03,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4,cC04,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol5,cC05,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6,cC06,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,cC07,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8,cC08,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol9-70,cC09,COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol10,cC010,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel4
   oSend( oPrn, 'SAY',nLin,nCol3,cC03,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol4,cC04,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol5,cC05,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6,cC06,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,cC07,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8,cC08,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol9,cC09,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol10,cC010,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol11,cC011,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol12,cC012,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol13-70,cC013,COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol14,cC014,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel5
   oSend( oPrn, 'SAY',nLin,nCol3,cC03,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4,cC04,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol5,cC05,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6,cC06,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,cC07,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8,cC08,COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol9-70,cC09,COURIER_07,,,,1)   
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol10,cC010,COURIER_07)
   EndIf
   //**
ENDIF

nLin:=nLin+30

cC02:=LEN(cC02)
cC06:=LEN(cC06)
cC07:=LEN(cC07)

oSend( oPrn, 'SAY',nLin,nCol1,REPL('-',0017),COURIER_07)

IF cRel #cRel3
   oSend( oPrn, 'SAY',nLin,nCol2,REPL('-',cC02),COURIER_07)
ENDIF

IF cRel==cRel1 .OR. cRel==cRel2
   oSend( oPrn, 'SAY',nLin,nCol3,REPL('-',0005),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4,REPL('-',nLag),COURIER_07,,,,1)
ENDIF

IF cRel == cRel1
   cC011:=LEN(cPicTaxa)-3
   oSend( oPrn, 'SAY',nLin,nCol5,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6,REPL('-',cC06),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',cC07),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',0030),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',0020),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol10,REPL('-',020),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol11,REPL('-',cC011),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol12,REPL('-',15),COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol13,REPL('-',025),COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel2
   cC05:=LEN(cC05) + 2
   oSend( oPrn, 'SAY',nLin,nCol5,REPL('-',cC05),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6,REPL('-',cC06),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',0030),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',0015),COURIER_07)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',025),COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel3
   cC05:=LEN(cC05) + 2
   oSend( oPrn, 'SAY',nLin,nCol2,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol3,REPL('-',0030),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4,REPL('-',0020),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol5,REPL('-',cC05),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',15),COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol10,REPL('-',025),COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel4
   cC09 :=LEN(cC09)
   cC010:=LEN(cC010)
   cC011:=LEN(cC011)
   oSend( oPrn, 'SAY',nLin,nCol3,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol4,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol5,REPL('-',0005),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',0030),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',0020),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',cC09),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol10,REPL('-',cC010),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol11,REPL('-',cC011),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol12,REPL('-',0020),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol13,REPL('-',0015),COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol14,REPL('-',025),COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel5
   cC04:=LEN(cC04)
   oSend( oPrn, 'SAY',nLin,nCol3,REPL('-',0020),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4,REPL('-',cC04),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol5,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol9,REPL('-',15),COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol10,REPL('-',025),COURIER_07)
   EndIf
   //**
ENDIF
nLin:=nLin+nPula          

RETURN .T.

*---------------------------------*
 STATIC FUNCTION AP182Detalhe()
*---------------------------------*
IncProc(STR0008+TRB->WB_HAWB) //"Imprimindo Processo: "

IF cRel4==cRel 
   IF nMes1 #MONTH(TRB->WB_DT_CONT) .OR.;
      nAno1 #YEAR(TRB->WB_DT_CONT)
      TRB->(DBSKIP(-1))
      IF(!lPrimPag,AP182Tot(),)
      IF !lPrimPag
         TRB->(DBSKIP())
      ENDIF
      AP182Cab()
   ENDIF
ENDIF

IF nLin > (nLimPage-nPula)
   AP182Cab()
ENDIF


oSend(oPrn,'oFont',COURIER_07)
oSend( oPrn, 'SAY',nLin,nCol1 ,TRB->WB_HAWB,COURIER_07)

IF cRel #cRel3
   oSend( oPrn, 'SAY',nLin,nCol2,TRANS(TRB->WA_CTRL,cPictCtl),COURIER_07)
ENDIF

IF cRel==cRel1 .OR. cRel==cRel2
   oSend( oPrn, 'SAY',nLin,nCol3+15,TRB->W2_MOEDA,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4 ,TRANS(TRB->WB_FOBMOE,cPictCor),COURIER_07,,,,1)
ENDIF

IF cRel == cRel1
   oSend( oPrn, 'SAY',nLin,nCol5 ,TRANS(TRB->WB_FOBREAL,cPictCor),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6 ,DTOC(TRB->WB_DT_CONT),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol7 ,DTOC(TRB->WB_DT_DESE),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8 ,TRB->WA_PRODUTO,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol9 ,TRB->A2_NREDUZ,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol10,TRB->A6_NOME,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol11,TRANS(TRB->WB_CA_TX,cPicTaxa),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol12,TRB->WB_CA_NUM,COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol13,TRB->WB_TP_CON,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel2
   oSend( oPrn, 'SAY',nLin,nCol5 ,DTOC(TRB->WB_DT_VEN ),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6 ,DTOC(TRB->WB_DT_CONT),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol7 ,TRB->WA_PRODUTO,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol8 ,TRB->WB_CA_NUM,COURIER_07)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol9,TRB->WB_TP_CON,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel3
   oSend( oPrn, 'SAY',nLin,nCol2 ,TRANS(TRB->WB_FOBUSS,cPictCor),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol3 ,TRB->WA_PRODUTO,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol4 ,TRB->A2_NREDUZ,COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol5 ,DTOC(TRB->WB_DT_VEN ),COURIER_07)
   oSend( oPrn, 'SAY',nLin,nCol6 ,TRANS(TRB->WB_FOBREAL,cPictCor),COURIER_07,,,,1)   
   IF !EMPTY(TRB->WB_USS_TOT)
      oSend( oPrn, 'SAY',nLin,nCol7 ,TRANS(TRB->WB_USS_TOT,cPictCor),COURIER_07,,,,1)
   ENDIF
   IF !EMPTY(TRB->WB_RS_TOT)
      oSend( oPrn, 'SAY',nLin,nCol8 ,TRANS(TRB->WB_RS_TOT ,cPictCor),COURIER_07,,,,1)
   ENDIF
   oSend( oPrn, 'SAY',nLin,nCol9,TRB->WB_CA_NUM,COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol10,TRB->WB_TP_CON,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel4
   oSend(oPrn,'SAY',nLin,nCol3    ,TRANS(TRB->WB_FOBUSS,cPictCor),COURIER_07,,,,1)
   oSend(oPrn,'SAY',nLin,nCol4    ,TRANS(TRB->WB_FOBREAL,cPictCor),COURIER_07,,,,1)
   oSend(oPrn,'SAY',nLin,nCol5    ,TRB->W2_MOEDA,COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol6    ,TRANS(TRB->WB_FOBMOE,cPictCor),COURIER_07,,,,1)
   oSend(oPrn,'SAY',nLin,nCol7    ,TRB->WA_PRODUTO,COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol8    ,TRB->A2_NREDUZ,COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol9    ,DTOC(TRB->WB_DT_VEN ),COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol10   ,DTOC(TRB->WB_DT_CONT),COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol11   ,DTOC(TRB->WB_DT_DESE),COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol12   ,LEFT(TRB->A6_NOME,20),COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol13   ,TRB->WB_CA_NUM,COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol14,TRB->WB_TP_CON,COURIER_07)
   EndIf
   //**
ELSEIF cRel == cRel5
   oSend(oPrn,'SAY',nLin,nCol3   ,TRB->A6_NOME,COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol4   ,DTOC(TRB->WB_DT_CONT),COURIER_07)
   oSend(oPrn,'SAY',nLin,nCol5   ,TRANS(TRB->WB_FOBUSS,cPictCor),COURIER_07,,,,1)
   IF !EMPTY(TRB->WB_USS_TOT)
      oSend( oPrn, 'SAY',nLin,nCol6 ,TRANS(TRB->WB_USS_TOT,cPictCor),COURIER_07,,,,1)
   ENDIF
   oSend( oPrn, 'SAY',nLin,nCol7 ,TRANS(TRB->WB_FOBREAL,cPictCor),COURIER_07,,,,1)
   IF !EMPTY(TRB->WB_RS_TOT)
      oSend( oPrn, 'SAY',nLin,nCol8 ,TRANS(TRB->WB_RS_TOT ,cPictCor),COURIER_07,,,,1)
   ENDIF
   oSend( oPrn, 'SAY',nLin,nCol9,TRB->WB_CA_NUM,COURIER_07,,,,1)
   //** GFC - 05/12/05
   If lWB_TP_CON
      oSend( oPrn, 'SAY',nLin,nCol10,TRB->WB_TP_CON,COURIER_07)
   EndIf
   //**
ENDIF

IF cRel #cRel2 

   nVlrRS:=nVlrRS+TRB->WB_FOBREAL//Rel's 1, 3, 4 e 5

   IF cRel #cRel1

      nVlrUS:=nVlrUS+TRB->WB_FOBUSS//Rel's 3, 4 e 5

      IF cRel #cRel4
         nVlrUSTot:=nVlrUSTot+TRB->WB_USS_TOT//Rel 3 e 5
         nVlrRSTot:=nVlrRSTot+TRB->WB_RS_TOT  
      ENDIF

   ENDIF

ENDIF

nLin:=nLin+nPula           

RETURN .T.

*--------------------------------*
 STATIC FUNCTION AP182Tot()
*--------------------------------*
  
IF nLin > (nLimPage-nPula*2)
   AP182Cab()
ENDIF

IF cRel == cRel1

   oSend(oPrn,'SAY',nLin,nCol5 ,REPL('-',nLag),COURIER_07,,,,1)
   nLin:=nLin+nPula
   oSend( oPrn, 'SAY',nLin,nCol5 ,TRANS(nVlrRS   ,cPictCor),COURIER_07,,,,1)

ELSEIF cRel == cRel3

   oSend( oPrn, 'SAY',nLin,nCol2 ,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6 ,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7 ,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8 ,REPL('-',nLag),COURIER_07,,,,1)
   nLin:=nLin+nPula
   oSend( oPrn, 'SAY',nLin,nCol2 ,TRANS(nVlrUS   ,cPictFOB),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6 ,TRANS(nVlrRS   ,cPictCor),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7 ,TRANS(nVlrUSTot,cPictFOB),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8 ,TRANS(nVlrRSTot,cPictFOB),COURIER_07,,,,1)

ELSEIF cRel == cRel4

   oSend( oPrn, 'SAY',nLin,nCol3 ,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol4 ,REPL('-',nLag),COURIER_07,,,,1)
   nLin:=nLin+nPula
   oSend( oPrn, 'SAY',nLin,nCol3 ,TRANS(nVlrUS,cPictFOB),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol4 ,TRANS(nVlrRS,cPictCor),COURIER_07,,,,1)

   nVlrUS:=nVlrRS:=0

ELSEIF cRel == cRel5

   oSend( oPrn, 'SAY',nLin,nCol5 ,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6 ,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7 ,REPL('-',nLag),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8 ,REPL('-',nLag),COURIER_07,,,,1)
   nLin:=nLin+nPula
   oSend( oPrn, 'SAY',nLin,nCol5 ,TRANS(nVlrUS   ,cPictFOB),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6 ,TRANS(nVlrUSTot,cPictFOB),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol7 ,TRANS(nVlrRS   ,cPictCor),COURIER_07,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol8 ,TRANS(nVlrRSTot,cPictFOB),COURIER_07,,,,1)

ENDIF

RETURN .T.
//EICAP183 - MNU - Relatorio de Estatisticas
*---------------------------------------------*
FUNCTION EICAP183()
*---------------------------------------------*
LOCAL I //LRL 23/01/04
PRIVATE cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
aSemSX3:={{'WB_COD'    ,'C',02,0},;
          {'WB_CODITEM','C',03,0},; 
          {'WB_NOME'   ,'C',30,0},; 
          {'WB_FOBAUX' ,'N',16,2},; 
          {'WB_FOB_1'  ,'N',16,2},; 
          {'WB_FOB_2'  ,'N',16,2},; 
          {'WB_FOB_3'  ,'N',16,2},; 
          {'WB_FOB_4'  ,'N',16,2},; 
          {'WB_FOB_5'  ,'N',16,2}}

aHeader:=ARRAY(0)
aCampos:={}
cFun := "183"

SX3->(DBSETORDER(2))
PRIVATE lCposAntecip:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
SX3->(DBSETORDER(1))

Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 //GFC - 02/12/05
PRIVATE lR4       := .f.  

//AOM - 01/02/2011
aSemSX3 := AddWkCpoUser(aSemSX3,"SWB")

cNomArq:=E_CriaTrab(,aSemSX3)

IndRegua('TRB',cNomArq+TEOrdBagExt(),'WB_COD+WB_CODITEM')

cRel1:=STR0082 //"1-Di rio"
cRel2:=STR0083 //"2-Periodo"
aRel :={cRel1,cRel2}
cRel :=cRel1
dDataIni:=AVCTOD('')
dDataFin:=AVCTOD('')

While .T.

   dDataIni:=AVCTOD('')
   dDataFin:=AVCTOD('')
   nOpcao :=0
   cTitulo:=STR0084 //"Relat¢rio de Estat¡sticas"
/* ISS - 18/03/10 - Alteração do tamanho da tela para que a mesma não corte o botão "Confirmar"
   oDlg := oSend( MSDialog(), 'New', 9, 0, 20, 45,;
                  cTitulo,,,.F.,,,,,oMainWnd,.F.,,,.F.) */
   oDlg := oSend( MSDialog(), 'New', 9, 0, 25, 50,;
                  cTitulo,,,.F.,,,,,oMainWnd,.F.,,,.F.)
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT  
                     
   @ 20,10 SAY STR0004 OF oPanel Pixel //"Relat¢rio:"
   @ 20,45 COMBOBOX cRel ITEMS aRel SIZE 50,50 OF oPanel Pixel 

   @ 40,10 SAY STR0005 OF oPanel Pixel //"Data Inicial:"
   @ 40,45 GET dDataIni  SIZE 42,8 WHEN cRel==cRel2 OF oPanel Pixel 

   @ 60,10 SAY STR0006 OF oPanel Pixel //"Data Final:"
   @ 60,45 GET dDataFin  SIZE 42,8 OF oPanel Pixel //VALID AP183Valid() 

   bOk     := {||AP183Valid()}
   bCancel := {||nOpcao:=0,oDlg:End()}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED


   If nOpcao == 0
      Exit
   Endif

   IF cRel==cRel1
      aTaxaDt:={}
      dDataIni:=dDataFin-4
      FOR I := 4 TO 0  STEP -1
          dDT:=(dDataFin-I)
          cDT:=Left(DTOC(dDT),6)+STR(YEAR(dDT),4)
          AADD(aTaxaDt,{cDT,BuscaTaxa(cMoedaDolar,dDT,,.F.)})
      NEXT
   ENDIF

   SysRefresh()

   DBSELECTAREA('TRB')
   AvZAP()
   nAreaTrb:=Select()
   SA6->(DBSETORDER(1))
   SA2->(DBSETORDER(1))
   SYT->(DBSETORDER(1))
   SW2->(DBSETORDER(1))
   SW7->(DBSETORDER(1))
   SWB->(DBSETORDER(1))
   SWB->(DBSEEK(xFilial("SWB")))
   DBSELECTAREA('SWB')

   aTabVlr:=ARRAY(4)
   AEVAL(aTabVlr,{|L,I|aTabVlr[I]:={0,0,0,0,0}})

   Processa({||AP183Proc()},STR0029) //"Lendo Cambio..."

   DBSELECTAREA('TRB')

   IF TRB->(BOF()) .AND. TRB->(EOF())
      Help("", 1, "AVG0000219")//"Nao existe registros a serem listados"
      LOOP
   ENDIF

   AP183Relatorio()

End

TRB->(E_EraseArq(cNomArq))

DBSELECTAREA('SWB')


Return(NIL)
*---------------------------------------------*
 STATIC FUNCTION AP183Valid()
*---------------------------------------------*
IF !EMPTY(dDataFin) .AND.!EMPTY(dDataIni) .AND. dDataFin < dDataIni 
   Help("", 1, "AVG0000220")//E_MSG(STR0085,1) //"Data Final menor que a Data Inicial"
   RETURN .F.
ENDIF

IF cRel==cRel1 .AND. EMPTY(dDataFin)
   Help("", 1, "AVG0000221")//E_MSG(STR0086,1) //"Data Final nÆo peenchida"
   RETURN .F.
ENDIF

nOpcao:=1
oDlg:End()

RETURN .T.
*---------------------------------------------*
 STATIC FUNCTION AP183For()
*---------------------------------------------*

IF EMPTY(WB_DT_CONT)
   RETURN .F.
ENDIF

IF !EMPTY(dDataIni) .AND. WB_DT_CONT < dDataIni
   RETURN .F.
ENDIF

IF !EMPTY(dDataFin) .AND. WB_DT_CONT >  dDataFin
   RETURN .F.
ENDIF

//** GFC - 02/12/05 - Não considerar os registros com tipos de contrato 3 ou 4
If lWB_TP_CON .and. SWB->WB_TP_CON $ ("3/4")
   Return .F.
EndIf
//**

RETURN .T.

*---------------------------------------------*
 STATIC FUNCTION AP183Proc()
*---------------------------------------------*

bImp:={||AP183Gera()}
bFor:={||AP183For()}

ProcRegua(SWB->(Easyreccount("SWB")))
IncProc(STR0087) //"Aguarde, Analisando Cambio..."

SWB->(DBEVAL(bImp,bFor))

DBSELECTAREA('TRB')
IF TRB->(BOF()) .AND. TRB->(EOF())
   Return .F. 
ENDIF

AP183Tit()

RETURN .T.

*---------------------------------------------*
 STATIC FUNCTION AP183Gera()
*---------------------------------------------*
LOCAL cCodPo, nVlParc , nCod

IncProc(STR0031+SWB->WB_HAWB) //"Lendo Processo: "

IF lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 28/08/2013
   cCodPo  := SWB->WB_HAWB
   nVlParc := SWB->WB_PGTANT
ELSE
   SW7->(DBSEEK(xFilial("SW7")+SWB->WB_HAWB))
   cCodPo  := SW7->W7_PO_NUM 
   nVlParc := SWB->WB_FOBMOE 
ENDIF   
   
SW2->(DBSEEK(xFilial("SW2")+cCodPo))
SA2->(DBSEEK(xFilial("SA2")+SWB->WB_FORN+SWB->WB_LOJA))

//Para Dolar
IF SWB->WB_MOEDA $ cMoedaDolar//'US$,USD'
   M->WB_FOB:=nVlParc
ELSE
   IF !EMPTY(SWB->WB_CA_TX)
      nVlrRS:=nVlParc * SWB->WB_CA_TX
   ELSE
      nVlrRS:=nVlParc * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_CONT,,.F.)
   ENDIF
   M->WB_FOB:=nVlrRS / BuscaTaxa(cMoedaDolar,SWB->WB_DT_CONT,,.F.)
ENDIF

FOR nCod := 1 TO 4

   DO CASE 

   CASE nCod==1; SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))
       cCodItem:=SW2->W2_IMPORT  ; cNome:=SYT->YT_NOME_RE

   CASE nCod==2; SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO))
       cCodItem:=SWB->WB_BANCO   ; cNome:=SA6->A6_NREDUZ 

   CASE nCod==3; cCodItem:=SWB->WB_MOEDA   ; cNome:=SWB->WB_MOEDA  

   CASE nCod==4; cCodItem:=SWB->WB_NAT_CON ; cNome:=Alltrim(SWB->WB_NAT_CON)
        IF(EMPTY(cCodItem),cCodItem:=cNome:="5",)
        DO CASE
           CASE cNome=='1' ; cNome:=STR0088 //"At sight"
           CASE cNome=='2' ; cNome:=STR0089 //"Future"
           CASE cNome=='3' ; cNome:=STR0090 //"Antecipado"
           CASE cNome=='4' ; cNome:=STR0091 //"Pronto/Futuro"
           CASE cNome=='5' ; cNome:=STR0092 //"Tourism"
        ENDCASE
   ENDCASE

   IF EMPTY(cCodItem) ; LOOP ; ENDIF

   IF !TRB->(DBSEEK(STR(nCod,1)+"3"+cCodItem))
      TRB->(DBAPPEND())
      TRB->WB_COD :=STR(nCod,1)+"3"
      TRB->WB_CODITEM:=cCodItem
      TRB->WB_NOME   :=cNome
   ENDIF

   TRB->WB_FOBAUX:=M->WB_FOB//Campo para corrigir a diferenca nos totais por causa da picture

   DO CASE 

      CASE SWB->WB_DT_CONT==dDataIni .OR. cRel==cRel2

           TRB->WB_FOB_1:=TRB->WB_FOB_1+M->WB_FOB
           aTabVlr[nCod,1]:=aTabVlr[nCod,1]+TRB->WB_FOBAUX

      CASE SWB->WB_DT_CONT==(dDataFin-3) .AND. cRel==cRel1

           TRB->WB_FOB_2:= TRB->WB_FOB_2+M->WB_FOB
           aTabVlr[nCod,2]:=aTabVlr[nCod,2]+TRB->WB_FOBAUX

      CASE SWB->WB_DT_CONT==(dDataFin-2) .AND. cRel==cRel1

           TRB->WB_FOB_3:= TRB->WB_FOB_3+M->WB_FOB
           aTabVlr[nCod,3]:=aTabVlr[nCod,3]+TRB->WB_FOBAUX

      CASE SWB->WB_DT_CONT==(dDataFin-1) .AND. cRel==cRel1

           TRB->WB_FOB_4:= TRB->WB_FOB_4+M->WB_FOB
           aTabVlr[nCod,4]:=aTabVlr[nCod,4]+TRB->WB_FOBAUX

      CASE SWB->WB_DT_CONT==dDataFin .AND. cRel==cRel1

           TRB->WB_FOB_5:= TRB->WB_FOB_5+M->WB_FOB
           aTabVlr[nCod,5]:=aTabVlr[nCod,5]+TRB->WB_FOBAUX

   ENDCASE

NEXT

RETURN .T.
*---------------------------------------------*
 STATIC FUNCTION AP183Tit()
*---------------------------------------------*
LOCAL P,nCod //LRL 23/01/04
aTit:={"Company","Bank","Currency","Exchange adopted"}
ProcRegua(4)
FOR nCod := 1 TO 4
   IncProc(STR0093) //"Gerando Totais..."
   TRB->(DBAPPEND())
   TRB->WB_COD :=STR(nCod,1)+'4'
   TRB->WB_NOME   :=STR0094 //"Total"
   FOR P := 1 TO 5
      cField:='WB_FOB_'+STR(P,1)
      bGrv:=TRB->(FIELDWBLOCK(cField,nAreaTrb))
      EVAL(bGrv,aTabVlr[nCod,P])
   NEXT
   TRB->(DBAPPEND())
   TRB->WB_COD :=STR(nCod,1)+'2'// Linha Titulo
   TRB->WB_NOME:=aTit[nCod]
   TRB->(DBAPPEND())
   TRB->WB_COD :=STR(nCod,1)+"1"// Linha em Branco
NEXT


RETURN .T.

*---------------------------------------------*
 STATIC FUNCTION AP183Relatorio()
*---------------------------------------------*
oPrn := PrintBegin('',.F.,.F.)
     oSend( oPrn, 'SetPortrait' )
PrintEnd()

AVPRINT oPrn NAME cTitulo

   DEFINE FONT oFont1  NAME 'Courier New' SIZE 0,07 OF  oPrn
   DEFINE FONT oFont0  NAME 'Courier New' SIZE 0,10 OF  oPrn
   DEFINE FONT oFont3  NAME 'Courier New' SIZE 0,10 OF  oPrn BOLD
   DEFINE FONT oFont4  NAME 'Courier New' SIZE 0,12 OF  oPrn 
   DEFINE FONT oFont5  NAME 'Courier New' SIZE 0,14 OF  oPrn BOLD

   AVPAGE

      oPrn:oFont:=COURIER_07
      
      oFont2  := oFont0
      lPrimPag:= .T.
      nPag     := 0000
      nLin    := 9999
      nLimPage:= 3100
      nColFim := 2300
      nColFim2:= 2300
      nColIni := 0000
      nPula   := 0045
      nPula1  := 0020
      nAux1   := 0000
      
      cPictFOB:='@E 9999,999,999,999.99'
      cPicTaxa:=Alltrim(X3Picture('WB_CA_TX'))

      nCol1:=nColIni+10 ; nCol2:=0890; nCol3:=1240; nCol4:=1590
      nCol5:=1940; nCol6:=nColFim-10 ; nCol7:=nCol2-350
      IF cRel==cRel2
         nColFim:=nCol2:=nCol3
         nCol7:=nCol7-30
      ENDIF

      TRB->(DBGOTOP())
      nCont:=TRB->(Easyreccount("TRB"))
      bImp :={||AP183Detalhe()}
      Processa({||ProcRegua(nCont), TRB->(DBEVAL(bImp)) },STR0033) //"Impressao"
      AP183Coluna()

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont0:End()
oFont3:End()
oFont4:End()
oFont5:End()

RETURN .T.

*---------------------------------------------*
 STATIC FUNCTION AP183Cab()
*---------------------------------------------*
IF !lPrimPag
   AVNEWPAGE
ENDIF

nLin:= 100
nPag := nPag  + 1

cTitulo1:=STR0095 //"ESTATISTICA DE CAMBIO EM DOLARES (US$)"
cTitulo2:=STR0011+DTOC(dDataIni)+STR0012+DTOC(dDatafin) //"ENTRE "###" E "

oPrn:Box( nLin,01,nLin+1,nColFim2)
nLin+=25

oPrn:Say(nLin,01,SM0->M0_NOME,COURIER_12)
oPrn:Say(nLin,nColFim2/2,cTitulo1,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim2,STR0023+STR(nPag,8),COURIER_12,,,,1) //"Pagina..: "
nLin+=50

oPrn:Say(nLin,01,STR0024,COURIER_12) //"SIGAEIC"
oPrn:Say(nLin,nColFim2/2,cTitulo2,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim2,STR0025+DTOC(dDataBase),COURIER_12,,,,1) //"Emissao.: "
nLin+=50

oPrn:Box( nLin,01,nLin+1,nColFim2)
nLin +=50


AP183Linha()

nAux1:=nLin-nPula1

IF cRel==cRel1

   oSend( oPrn, 'SAY',nLin,nCol1+85,STR0096,COURIER_12) //"Ptax R$/US$"
   oSend( oPrn, 'SAY',nLin,nCol2-50,TRANS(aTaxaDt[1,2],cPicTaxa),COURIER_08,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol3-50,TRANS(aTaxaDt[2,2],cPicTaxa),COURIER_08,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol4-50,TRANS(aTaxaDt[3,2],cPicTaxa),COURIER_08,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol5-50,TRANS(aTaxaDt[4,2],cPicTaxa),COURIER_08,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6-50,TRANS(aTaxaDt[5,2],cPicTaxa),COURIER_08,,,,1)
   nLin:=nLin+nPula

   AP183Linha()

   oSend( oPrn, 'SAY',nLin,nCol1+85,"business days",COURIER_12)
   oSend( oPrn, 'SAY',nLin,nCol2-50,aTaxaDt[1,1],COURIER_10,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol3-50,aTaxaDt[2,1],COURIER_10,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol4-50,aTaxaDt[3,1],COURIER_10,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol5-50,aTaxaDt[4,1],COURIER_10,,,,1)
   oSend( oPrn, 'SAY',nLin,nCol6-50,aTaxaDt[5,1],COURIER_10,,,,1)
   nLin:=nLin+nPula          

   AP183Linha()

ELSEIF lPrimPag

   oSend( oPrn, 'SAY',nLin,nCol2-270,STR0097,COURIER_12,,,,1) //"Periodo"

ENDIF

IF(lPrimPag,lPrimPag:=.F.,)

RETURN .T.

*-----------------------------------------------------------------*
 STATIC FUNCTION AP183Detalhe()
*-----------------------------------------------------------------*
IncProc(STR0098+TRB->WB_NOME) //"Imprimindo: "

IF nLin > (nLimPage)
   IF(!lPrimPag,AP183Coluna(),)
   AP183Cab()
ENDIF

oPrn:oFont:=COURIER_08
oSend( oPrn, 'SAY',nLin,nCol1 ,TRB->WB_NOME,IF(RIGHT(TRB->WB_COD,1)$'2.4',COURIER_12,COURIER_08))

IF RIGHT(TRB->WB_COD,1) $ '3.4'

   oFont2:=IF(RIGHT(TRB->WB_COD,1)=='3',oFont0,oFont3)
   oSend( oPrn, 'SAY',nLin,nCol2-10,TRANS(TRB->WB_FOB_1,cPictFob),COURIER_08,,,,1)
   IF cRel==cRel1
      oSend( oPrn, 'SAY',nLin,nCol3-10,TRANS(TRB->WB_FOB_2,cPictFob),COURIER_08,,,,1)
      oSend( oPrn, 'SAY',nLin,nCol4-10,TRANS(TRB->WB_FOB_3,cPictFob),COURIER_08,,,,1)
      oSend( oPrn, 'SAY',nLin,nCol5-10,TRANS(TRB->WB_FOB_4,cPictFob),COURIER_08,,,,1)
      oSend( oPrn, 'SAY',nLin,nCol6-10,TRANS(TRB->WB_FOB_5,cPictFob),COURIER_08,,,,1)
   ENDIF
   oFont2:=oFont0

ENDIF

nLin:=nLin+nPula             
AP183Linha()

RETURN .T.

*-----------------------------------------------------------------------------------*
 STATIC FUNCTION AP183Linha()
*-----------------------------------------------------------------------------------*

nLin:=nLin+15
oSend( oPrn, 'BOX',nLin  ,nColIni,nLin+1,nColFim)
oSend( oPrn, 'BOX',nLin+2,nColIni,nLin+3,nColFim)
nLin:=nLin+nPula1

RETURN

*-----------------------------------------------------------------------------------*
 STATIC FUNCTION AP183Coluna()
*-----------------------------------------------------------------------------------*
nLin:=nLin-nPula1

oSend(oPrn,'BOX',nAux1,nColIni+1,nLin,nColIni+2)
oSend(oPrn,'BOX',nAux1,nColIni+3,nLin,nColIni+4)

oSend(oPrn,'BOX',nAux1,nCol7+1,nLin,nCol7+2)
oSend(oPrn,'BOX',nAux1,nCol7+3,nLin,nCol7+4)
oSend(oPrn,'BOX',nAux1,nCol2+1,nLin,nCol2+2)
oSend(oPrn,'BOX',nAux1,nCol2+3,nLin,nCol2+4)

IF cRel==cRel1
   oSend(oPrn,'BOX',nAux1,nCol3+1,nLin,nCol3+2)
   oSend(oPrn,'BOX',nAux1,nCol3+3,nLin,nCol3+4)
   oSend(oPrn,'BOX',nAux1,nCol4+1,nLin,nCol4+2)
   oSend(oPrn,'BOX',nAux1,nCol4+3,nLin,nCol4+4)
   oSend(oPrn,'BOX',nAux1,nCol5+1,nLin,nCol5+2)
   oSend(oPrn,'BOX',nAux1,nCol5+3,nLin,nCol5+4)
ENDIF

oSend(oPrn,'BOX',nAux1,nColFim+1,nLin,nColFim+2)
oSend(oPrn,'BOX',nAux1,nColFim+3,nLin,nColFim+4)

RETURN

//TRP - 02/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
Local cMoedaDolar:=BuscaDolar()
Local  nVlrSWB ,cHawb
Local bIF := {|| IF(lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C"), nVlrSWB := SWB->WB_PGTANT, nVlrSWB := SWB->WB_FOBMOE) } // GCC - 28/08/2013
Local bFobReal := {|| M->WB_TIPOREG := Left(SWB->WB_TIPOREG,1),IF(lCposAntecip,M->WB_PGTANT := SWB->WB_PGTANT,""),M->WB_FOBREAL := Ape_Vl_Real(nVlrSWB,SWB->WB_CA_TX)}

nVlDolar:= 0
nVlReal:= 0
//Local cMensObs:=STR0108//"Os processos iniciados com * referem-se a Adiantamentos - Número do Pedido"
//Private cMes:=STR0043+PADL(MONTH(TRB->WB_DT_VEN),2,"0")+" "
//Private oBreak
If cFun="180"
   If cRel==cRel1
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWB","SWA","SYW","SW2"} 
   
      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem   := {}
      
      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICAP180",STR0010+ " " +STR0002,"",{|oReport| ReportPrint(oReport)},STR0002)
      oReport:cTitle:=STR0010+SUBSTR(UPPER(cRel),3)+ " " +STR0011+DTOC(dDataIni)+STR0012+DTOC(dDatafin)

      oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
      oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

      
      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,"Variação Cambial",aTabelas,aOrdem)
   
      //Definição das colunas de impressão da seção 1
      TRCell():New(oSecao1,"WB_HAWB"       ,"SWB"   ,STR0013                 ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,{|| IF (lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C"),cHawb   := SWB->WB_HAWB,cHawb   := SWB->WB_HAWB)})	// GCC - 28/08/2013
      TRCell():New(oSecao1,"WA_CTRL"       ,"SWA"   ,STR0014                 ,Alltrim(X3Picture('WA_CTRL'))     ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"YW_NOME"       ,"SYW"   ,STR0015                 ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_CONT"    ,"SWB"   ,STR0017                 ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_MOEDA"      ,"SWB"   ,STR0018                 ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"FOB MOE"       ,""      ,STR0019                 ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/	,/*lPixel*/,{|| IF (lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C"),SWB->WB_PGTANT,SWB->WB_FOBMOE)})//TDF-23/03/2012-PARA IMPRIMIR O VALOR DO PAGAMENTO ANTECIPADO	// GCC - 28/08/2013
      TRCell():New(oSecao1,"VL DOLAR"      ,""      ,STR0020                 ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/	,/*lPixel*/,{||EVAL(bIF), CalcVlDolar(nVlrSWB)})         
      TRCell():New(oSecao1,"FOBREAL"       ,""      ,STR0021                 ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/	,/*lPixel*/,{||EVAL(bIF), CalcVlReal(nVlrSWB,bFobReal)})  
      TRCell():New(oSecao1,"WB_VL_CORR"    ,"SWB"   ,STR0022                 ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      //TRP-08/12/06-Coluna tipo do contrato
      If lWB_TP_CON
         TRCell():New(oSecao1,"WB_TP_CON"  ,"SWB"   ,"Tipo de Contrato"      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| If( !EMPTY(SWB->WB_TP_CON),BSCXBOX("WB_TP_CON",SWB->WB_TP_CON),STR0110)})//ITEM NÃO CADASTRADO
      Endif

      TRCell():New(oSecao1,"WB_TIPOREG"  ,"SWB"   ,"Tipo de Registro"        ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| If( !EMPTY(SWB->WB_TIPOREG),AvTabela("Y6",SWB->WB_TIPOREG),STR0110)})//ITEM NÃO CADASTRADO

      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("")
    
      oBreak:= TRBreak():New(oSecao1,{||DTOC(dDataIni)+STR0012+DTOC(dDatafin)},"",.f.)  
      TRFunction():New(oSecao1:Cell("FOB MOE") ,NIL,"SUM",oBreak,,"@E 9,999,999,999.99",/*uFormula*/,.F.,.F.)//TDF-23/03/2012-TOTALIZADOR DO VALOR NA MOEDA DO PROCESSO
      TRFunction():New(oSecao1:Cell("VL DOLAR"),NIL,"SUM",oBreak,,"@E 9,999,999,999.99",/*uFormula*/,.F.,.F.)
      TRFunction():New(oSecao1:Cell("FOBREAL"),NIL,"SUM",oBreak,,"@E 9,999,999,999.99",/*uFormula*/,.F.,.F.)
      TRFunction():New(oSecao1:Cell("WB_VL_CORR"),NIL,"SUM",oBreak,,"@E 9,999,999,999.99",/*uFormula*/,.F.,.F.)
      oReport:Section("Variação Cambial"):SetPageBreak(.T.)
   
   
   ELSEIF cRel==cRel2
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWB","SWA","SA6","SW2"}

      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem   := {}
    
      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICAP180",STR0010+ " " +STR0003,"",{|oReport| ReportPrint(oReport)},STR0003)
      oReport:cTitle:=STR0010+SUBSTR(UPPER(cRel),3)+ " " +STR0011+DTOC(dDataIni)+STR0012+DTOC(dDatafin)
      
      oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
      oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,"Variação Cambial",aTabelas,aOrdem)
      
      //Definição das colunas de impressão da seção 1
      TRCell():New(oSecao1,"WB_HAWB"       ,"SWB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,{|| IF (lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C") ,cHawb   := SWB->WB_HAWB,cHawb   := SWB->WB_HAWB)})	// GCC - 28/08/2013
      TRCell():New(oSecao1,"WA_CTRL"       ,"SWA"   ,STR0014      ,Alltrim(X3Picture('WA_CTRL'))     ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"A6_NOME"       ,"SA6"   ,STR0016      ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_CONT"    ,"SWB"   ,STR0017      ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"W2_MOEDA"      ,"SW2"   ,STR0018      ,/*Picture*/                       ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBMOE"     ,"SWB"   ,STR0019      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"VL DOLAR"      ,""      ,STR0020      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/	,/*lPixel*/,{||EVAL(bIF), IF( SWB->WB_MOEDA $ cMoedaDolar,nVlrUSS := nVlrSWB ,nVlrUSS :=nVlrSWB * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_CONT,,.F.) / BuscaTaxa(cMoedaDolar,SWB->WB_DT_CONT,,.F.))})        
      //TRCell():New(oSecao1,"FOBREAL"       ,""      ,STR0021      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/	,/*lPixel*/,{||If( !EMPTY(SWB->WB_CA_TX),M->WB_FOBREAL := Ape_Vl_Real(nVlrSWB,SWB->WB_CA_TX),M->WB_FOBREAL := nVlrSWB * BuscaTaxa(SW2->W2_MOEDA,SWB->WB_DT_CONT,,.F.))})
      bIF := {|| IF(lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C"), nVlrSWB := SWB->WB_PGTANT, nVlrSWB := SWB->WB_FOBMOE) }	// GCC - 28//08/2013
      TRCell():New(oSecao1,"FOBREAL"       ,""      ,STR0021      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,{||EVAL(bIF),If( !EMPTY(SWB->WB_CA_TX),EVAL(bFOBREAL),M->WB_FOBREAL := nVlrSWB * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_CONT,,.F.))})
      TRCell():New(oSecao1,"WB_VL_CORR"    ,"SWB"   ,STR0022      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,{||0}) 
      //TRP-08/12/06-Coluna Tipo Contrato
      If lWB_TP_CON
          TRCell():New(oSecao1,"WB_TP_CON"  ,"SWB"   ,"Tipo de Contrato"      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| If( !EMPTY(SWB->WB_TP_CON),BSCXBOX("WB_TP_CON",SWB->WB_TP_CON),STR0110)}) //ITEM NÃO CADASTRADO
      Endif
      
      TRCell():New(oSecao1,"WB_TIPOREG"  ,"SWB"   ,"Tipo de Registro"        ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| If( !EMPTY(SWB->WB_TIPOREG),AvTabela("Y6",SWB->WB_TIPOREG),STR0110)})//ITEM NÃO CADASTRADO
      
      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("")
    
      oBreak:= TRBreak():New(oSecao1,{||DTOC(dDataIni)+STR0012+DTOC(dDatafin)},"",.f.)
      TRFunction():New(oSecao1:Cell("VL DOLAR"),NIL,"SUM",oBreak,,"@E 9,999,999,999.99",/*uFormula*/,.F.,.F.)
      TRFunction():New(oSecao1:Cell("FOBREAL"),NIL,"SUM",oBreak,,"@E 9,999,999,999.99",/*uFormula*/,.F.,.F.)
      TRFunction():New(oSecao1:Cell("WB_VL_CORR"),NIL,"SUM",oBreak,,"@E 9,999,999,999.99",/*uFormula*/,.F.,.F.)
      oReport:Section("Variação Cambial"):SetPageBreak(.T.)

   ENDIF
ELSEIF cFun="181"
   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
   aTabelas := {"SWB","SA2","SW2","SWA"}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem   := { }

   //Cria o objeto principal de controle do relatório.
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICAP181",STR0109,"",{|oReport| ReportPrint(oReport)},STR0109)//"Previsão Financeira e Orçamento de Caixa"
   
   oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
   oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

   //Define o objeto com a seção do relatório
   oSecao1 := TRSection():New(oReport,"Orçamento de Caixa",aTabelas,aOrdem)

   //Definição das colunas de impressão da seção 1
   TRCell():New(oSecao1,"WB_HAWB"        ,"TRB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W2_MOEDA"       ,"TRB"   ,STR0018      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WB_FOBMOE"      ,"TRB"   ,STR0036      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WB_FOBUSS"      ,"TRB"   ,STR0020      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//ASR - 10/11/2006 - RETIRADO CONFORME CONVERSADO C/ BETE E REGINA
//   TRCell():New(oSecao1,"WA_PRODUTO"     ,"TRB"   ,STR0037      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"A2_NREDUZ"      ,"TRB"   ,STR0038      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WB_DT_VEN"      ,"TRB"   ,STR0039      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WB_FOBREAL"     ,"TRB"   ,STR0040      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WB_USS_DIA"     ,"TRB"   ,STR0041      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WB_RS_DIA"      ,"TRB"   ,STR0042      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   //TRP-07/12/06- Coluna Tipo do Contrato
   If lWB_TP_CON
      TRCell():New(oSecao1,"WB_TP_CON"   ,"TRB"   ,"Tipo de Contrato"       ,"@!"                  ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TP_CON })   //NCF - 26/05/09 - Adiconado o CodeBlock para impressão
   Endif                                                                                                                                                       //                 do "Tipo de contrato".
   
   TRCell():New(oSecao1,"WB_TIPOREG"     ,"TRB"   ,"Tipo de Registro"       ,"@!"                  ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TIPOREG })

   oBreak := TRBreak():New(oReport:Section("Orçamento de Caixa"),{||MONTH(TRB->WB_DT_VEN)},,.F.) // "Total do mes"
   oBreak:bTotalText := &("{|| TRB->(DBSKIP(-1)), cMesBrk := STRZERO(MONTH(TRB->WB_DT_VEN),2), TRB->(DBSKIP()) , 'TOTAL MES: ' + cMesBrk }")
   //oBreak := TRBreak():New(oReport:Section("Seção 1"),"(TRB->WB_USS_MES>0) .OR. (TRB->WB_RS_MES>0)" ,cMes,.F.) // "Total do mes"
   TRFunction():New(oReport:Section("Orçamento de Caixa"):Cell("WB_FOBUSS"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.)
   TRFunction():New(oReport:Section("Orçamento de Caixa"):Cell("WB_FOBREAL"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.)
   
   oSecao1:SetTotalInLine(.F.)
   oSecao1:SetTotalText("Total Geral:")

   oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBUSS"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBUSS },.T.,.F.)
   oTotal:SetTotalInLine(.F.)

   oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBREAL"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBREAL },.T.,.F.)
   oTotal:SetTotalInLine(.F.)

   oTotal:= TRFunction():New(oSecao1:Cell("WB_USS_DIA"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_USS_DIA },.T.,.F.)
   oTotal:SetTotalInLine(.F.)

   oTotal:= TRFunction():New(oSecao1:Cell("WB_RS_DIA"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_RS_DIA },.T.,.F.)
   oTotal:SetTotalInLine(.F.)


ELSEIF cFun = "182"
   cData := "De: " + DTOC(dDataIni) + " " //JWJ 22/01/07: Impressão dos parâmetros de data.
   cData += "Até: " + DTOC(dDataFin) + " "

   
   If cRel==cRel1
      cNome:= "De Finanças para Controladoria Central"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWB","SWA","SA2","SA6","SW2"}

      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem   := {cTipo}
    
      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo   ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICAP182", STR0111 ,""       ,{|oReport| ReportPrint(oReport)},STR0111)//"Câmbios Fechados - Controladoria Central"
   
      oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
      oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem) 

      //Definição das colunas de impressão da seção 1
      TRCell():New(oSecao1,"WB_HAWB"       ,"TRB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WA_CTRL"       ,"TRB"   ,STR0014      ,Alltrim(X3Picture('WA_CTRL'))     ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"W2_MOEDA"      ,"TRB"   ,STR0018      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBMOE"     ,"TRB"   ,STR0079      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBREAL"    ,"TRB"   ,STR0021      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_CONT"    ,"TRB"   ,STR0017      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_DESE"    ,"TRB"   ,STR0071      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//ASR - 10/11/2006 - RETIRADO CONFORME CONVERSADO C/ BETE E REGINA
//      TRCell():New(oSecao1,"WA_PRODUTO"    ,"TRB"   ,STR0037      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"A2_NREDUZ"     ,"TRB"   ,STR0038      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"A6_NOME"       ,"TRB"   ,STR0072      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_CA_TX"      ,"TRB"   ,STR0073      ,Alltrim(X3Picture('WB_CA_TX'))    ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_CA_NUM"     ,"TRB"   ,STR0099      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      If lWB_TP_CON
         TRCell():New(oSecao1,"WB_TP_CON"  ,"TRB"   ,"Tipo de Contrato"      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TP_CON })
      Endif
      
      TRCell():New(oSecao1,"WB_TIPOREG"     ,"TRB"   ,"Tipo de Registro"       ,"@!"                  ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TIPOREG })

      oReport:Section(cNome):Cell("WA_CTRL"   ):SetColSpace(2)//ASR - 10/11/2006
      oReport:Section(cNome):Cell("WB_FOBREAL"):SetColSpace(2)//ASR - 10/11/2006
      oReport:Section(cNome):Cell("WB_DT_CONT"):SetColSpace(2)//ASR - 10/11/2006
      oReport:Section(cNome):Cell("WB_DT_DESE"):SetColSpace(2)//ASR - 10/11/2006
      oReport:Section(cNome):Cell("WB_CA_TX"  ):SetColSpace(2)//ASR - 10/11/2006

      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("")

      oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBREAL"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBREAL},.T.,.F.)
      oTotal:SetTotalInLine(.F.)

   ELSEIF cRel==cRel2
      cNome:="De Finanças para Comércio Exterior"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWB","SWA","SW2"}

      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem   := { }

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICAP182",STR0062+ "  " +STR0063+STR0065,"",{|oReport| ReportPrint(oReport)},STR0062+ "  " +STR0063+STR0065)

      oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
      oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem) 
    
      //Definição das colunas de impressão da seção 1
      TRCell():New(oSecao1,"WB_HAWB"    ,"TRB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WA_CTRL"    ,"TRB"   ,STR0014      ,Alltrim(X3Picture('WA_CTRL'))     ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"W2_MOEDA"   ,"TRB"   ,STR0018      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBMOE"  ,"TRB"   ,STR0079      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_VEN"  ,"TRB"   ,STR0074      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_CONT" ,"TRB"   ,STR0017      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//ASR - 10/11/2006 - RETIRADO CONFORME CONVERSADO C/ BETE E REGINA
//      TRCell():New(oSecao1,"WA_PRODUTO" ,"TRB"   ,STR0037      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_CA_NUM"  ,"TRB"   ,STR0099      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      If lWB_TP_CON
         TRCell():New(oSecao1,"WB_TP_CON"  ,"TRB"   ,"Tipo de Contrato"      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TP_CON })
      Endif
      
      TRCell():New(oSecao1,"WB_TIPOREG"     ,"TRB"   ,"Tipo de Registro"       ,"@!"                  ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TIPOREG })
   
   ELSEIF cRel==cRel3
      cNome:= "Importações em ordem de produto e vencimento"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWB","SWA","SA2"}

      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem   := { }

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICAP182",STR0068,"",{|oReport| ReportPrint(oReport)},STR0068)
      
      oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
      oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)

      //Definição das colunas de impressão da seção 1
      TRCell():New(oSecao1,"WB_HAWB"     ,"TRB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBUSS"   ,"TRB"   ,STR0075      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//ASR - 10/11/2006 - RETIRADO CONFORME CONVERSADO C/ BETE E REGINA
//      TRCell():New(oSecao1,"WA_PRODUTO"  ,"TRB"   ,STR0037      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"A2_NREDUZ"   ,"TRB"   ,STR0038      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_VEN"   ,"TRB"   ,STR0074      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBREAL"  ,"TRB"   ,STR0076      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      //TRCell():New(oSecao1,"WB_USS_TOT"  ,"TRB"   ,STR0077      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      //TRCell():New(oSecao1,"WB_RS_TOT"   ,"TRB"   ,STR0078      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/) 
      TRCell():New(oSecao1,"WB_CA_NUM"   ,"TRB"   ,STR0099      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      IF lWB_TP_CON
         TRCell():New(oSecao1,"WB_TP_CON","TRB",STR0072,/*Picture*/,/*Tamanho*/28  ,/*lPixel*/,{|| TRB->WB_BANCO + " - " + TRB->WB_TP_CON })
      ENDIF
      
      TRCell():New(oSecao1,"WB_TIPOREG"     ,"TRB"   ,"Tipo de Registro"       ,"@!"                  ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TIPOREG })
      
      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("")

      oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBUSS"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBUSS },.T.,.F.)
      oTotal:SetTotalInLine(.F.)

      oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBREAL"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBREAL },.T.,.F.)
      oTotal:SetTotalInLine(.F.)

      //oTotal:= TRFunction():New(oSecao1:Cell("WB_USS_TOT"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_USS_TOT },.T.,.F.)
      //oTotal:SetTotalInLine(.F.)

      //oTotal:= TRFunction():New(oSecao1:Cell("WB_RS_TOT"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_RS_TOT },.T.,.F.)
      //oTotal:SetTotalInLine(.F.)
  
   ELSEIF cRel==cRel4 
      cNome:= "Importações mensais"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWB","SWA","SW2","SA2"}

      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem   := { }

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICAP182",STR0069,"",{|oReport| ReportPrint(oReport)},STR0069)

      oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
      oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)

      //Definição das colunas de impressão da seção 1
      TRCell():New(oSecao1,"WB_HAWB"       ,"TRB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WA_CTRL"       ,"TRB"   ,STR0014      ,Alltrim(X3Picture('WA_CTRL'))     ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBUSS"     ,"TRB"   ,STR0075      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBREAL"    ,"TRB"   ,STR0076      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"W2_MOEDA"      ,"TRB"   ,STR0018      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBMOE"     ,"TRB"   ,STR0079      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//ASR - 10/11/2006 - RETIRADO CONFORME CONVERSADO C/ BETE E REGINA
//      TRCell():New(oSecao1,"WA_PRODUTO"    ,"TRB"   ,STR0037      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"A2_NREDUZ"     ,"TRB"   ,STR0038      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/) 
      TRCell():New(oSecao1,"WB_DT_VEN"     ,"TRB"   ,STR0074      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_CONT"    ,"TRB"   ,STR0017      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_DESE"    ,"TRB"   ,STR0101      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"A6_NOME"       ,"TRB"   ,STR0072      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/) 
      TRCell():New(oSecao1,"WB_CA_NUM"     ,"TRB"   ,STR0099      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      If lWB_TP_CON
         TRCell():New(oSecao1,"WB_TP_CON"  ,"TRB"   ,"Tipo de Contrato"      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TP_CON })
      Endif
      
      TRCell():New(oSecao1,"WB_TIPOREG"     ,"TRB"   ,"Tipo de Registro"       ,"@!"                  ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TIPOREG })
      
      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("")
    
      oBreak:= TRBreak():New(oSecao1,{||Str(MONTH(TRB->WB_DT_CONT))+Str(YEAR(TRB->WB_DT_CONT))},"",.f.)
      TRFunction():New(oSecao1:Cell("WB_FOBUSS"),NIL,"SUM",oBreak,,Alltrim(X3Picture('WB_VL_CORR')),/*uFormula*/,.F.,.F.)
      TRFunction():New(oSecao1:Cell("WB_FOBREAL"),NIL,"SUM",oBreak,,Alltrim(X3Picture('WB_VL_CORR')),/*uFormula*/,.F.,.F.)
      oReport:Section(cNome):SetPageBreak(.T.)
   
      //oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBUSS"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBUSS },.T.,.F.)
      //oTotal:SetTotalInLine(.F.)

      //oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBREAL"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBREAL },.T.,.F.)
      //oTotal:SetTotalInLine(.F.)

   ELSEIF cRel==cRel5
      cNome:= "Estatística Bancária" 
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWB","SA6","SWA"}

      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem   := { }

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICAP182",STR0070,"",{|oReport| ReportPrint(oReport)},STR0070)

      oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
      oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)

      //Definição das colunas de impressão da seção 1
      TRCell():New(oSecao1,"WB_HAWB"     ,"TRB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WA_CTRL"     ,"TRB"   ,STR0014      ,Alltrim(X3Picture('WA_CTRL'))     ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"A6_NOME"     ,"TRB"   ,STR0016      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_DT_CONT"  ,"TRB"   ,STR0017      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBUSS"   ,"TRB"   ,STR0075      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      //TRCell():New(oSecao1,"WB_USS_TOT"  ,"TRB"   ,STR0080      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WB_FOBREAL"  ,"TRB"   ,STR0076      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      //TRCell():New(oSecao1,"WB_RS_TOT"   ,"TRB"   ,STR0081      ,Alltrim(X3Picture('WB_VL_CORR'))  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/) 
      TRCell():New(oSecao1,"WB_CA_NUM"   ,"TRB"   ,STR0099      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
      If lWB_TP_CON
         TRCell():New(oSecao1,"WB_TP_CON"  ,"TRB"   ,"Tipo de Contrato"      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TP_CON })
      Endif
      
      TRCell():New(oSecao1,"WB_TIPOREG"     ,"TRB"   ,"Tipo de Registro"       ,"@!"                  ,/*Tamanho*/            ,/*lPixel*/,{|| TRB->WB_TIPOREG })

      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("")

      oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBUSS"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBUSS },.T.,.F.)
      oTotal:SetTotalInLine(.F.)

      //oTotal:= TRFunction():New(oSecao1:Cell("WB_USS_TOT"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_USS_TOT },.T.,.F.)
      //oTotal:SetTotalInLine(.F.)

      oTotal:= TRFunction():New(oSecao1:Cell("WB_FOBREAL"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_FOBREAL },.T.,.F.)
      oTotal:SetTotalInLine(.F.)

      //oTotal:= TRFunction():New(oSecao1:Cell("WB_RS_TOT"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->WB_RS_TOT },.T.,.F.)
      //oTotal:SetTotalInLine(.F.)

   ENDIF

   //JWJ 18/01/07: Define o espaçamento para todas as colunas de todos os relatórios.
   AEVAL(oSecao1:aCell, {|X| X:SetColSpace(3)})

ENDIF

//Necessário para carregar os perguntes mv_par**
//Pergunte(oReport:uParam,.F.)TLM 07/11/07 - Nenhum pergunte está sendo passado no TReport

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection
If cFun="180"
   oSection := oReport:Section("Variação Cambial")
   
   //Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
   
   TRPosition():New(oSection,"SWA",1,{|| xFilial("SWA") +IF (lCposAntecip .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C"),SWB->WB_HAWB+SWB->WB_PO_DI,SWB->WB_HAWB)})	// GCC - 28/08/2013
   
   TRPosition():New(oSection,"SYW",1,{|| xFilial("SYW") + SWB->WB_CORRETO})
   
   TRPosition():New(oSection,"SW7",1,{|| xFilial("SW7") + SWB->WB_HAWB})
   
   //oSection:Print()
   oReport:SetMeter (SWB->(EasyRecCount("SWB")))
   SWB->( dbGoTop() )
   
   //Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oSection:Init()

   
   lNaoTem:=.t.
   //Laço principal
   Do While SWB->(!EoF()) .And. !oReport:Cancel()
      If EVAL(bFor)
      
         oSection:PrintLine() //Impressão da linha
         oReport:IncMeter()                     //Incrementa a barra de progresso
      Endif
      SWB->( dbSkip() )
   EndDo

   //TRP-11/10/2006- Imprime mensagem se processo possuir adiantamento
   IF lImpObs
      oReport:SkipLine(3)
      oReport:FatLine()
      oReport:PrintText(STR0108) 
      oReport:FatLine()
   ENDIF
   
   
   //Fim da impressão da seção 1
   oSection:Finish()
   
   If Select("TRB") > 0
      TRB->(DBGOTOP())
   EndIf
   
   Return .T.   


ELSEIF cFun="181"

   oSection := oReport:Section("Orçamento de Caixa")

   //Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
   
   TRPosition():New(oSection,"SWB",1,;
                {|| xFilial("SWB") + TRB->WB_HAWB + TRB->WB_PO_DI + TRB->WB_INVOICE + TRB->WB_FORN + TRB->WB_LOJA + TRB->WB_LINHA})
   
   TRPosition():New(oSection,"SW7",1,{|| xFilial("SW7") + SWB->WB_HAWB})
   
   TRPosition():New(oSection,"SWA",1,{|| xFilial("SWA") + IF (lCposAntecip,SWB->WB_HAWB+SWB->WB_PO_DI,SWB->WB_HAWB)})
   
   TRPosition():New(oSection,"SW2",1,{|| xFilial("SW2") + SW7->W7_PO_NUM})                 
   
   TRPosition():New(oSection,"SA2",1,{|| xFilial("SA2") + SWB->WB_FORN+SWB->WB_LOJA})
   
   //oSection:Print()
   oReport:SetMeter(TRB->(EasyRecCount("TRB")))
   TRB->( dbGoTop() )

   //Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oSection:Init()

   //Laço principal
   Do While TRB->(!EoF()) .And. !oReport:Cancel()
      oSection:PrintLine() //Impressão da linha
      oReport:IncMeter()                     //Incrementa a barra de progresso
   
      TRB->( dbSkip() )
   EndDo

   //Fim da impressão da seção 1
   oSection:Finish() 
   TRB->(DBGOTOP())
   Return .T.


ELSEIF cFun=="182"
   //Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
   TRPosition():New(oReport:Section(cNome),"SA6",1,{|| xFilial("SA6") + TRB->WB_BANCO})
                       
   //oSection:Print()
   oReport:SetMeter (TRB->(EasyRecCount("TRB")))
   TRB->( dbGoTop() )
   
   //Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section(cNome):Init()
   IF !Empty(cData)
      oReport:PrintText(cData) 
      oReport:FatLine()
      oReport:SkipLine(2)
   ENDIF
  
   If cRel==cRel4
      cQuebra := Str(MONTH(TRB->WB_DT_CONT))+Str(YEAR(TRB->WB_DT_CONT))
      AltTit()
   Endif
   
   //Laço principal
   Do While TRB->(!EoF()) .And. !oReport:Cancel()
   
      If cRel==cRel4 .and. cQuebra <> Str(MONTH(TRB->WB_DT_CONT))+Str(YEAR(TRB->WB_DT_CONT))
         AltTit()
         oReport:Section(cNome):Finish()
         oReport:Section(cNome):Init()
      EndIf

      oReport:Section(cNome):PrintLine() //Impressão da linha
      oReport:IncMeter()                     //Incrementa a barra de progresso
   
      cQuebra := Str(MONTH(TRB->WB_DT_CONT))+Str(YEAR(TRB->WB_DT_CONT))
   
      TRB->( dbSkip() )
   EndDo
   

   //TRP-11/10/2006- Imprime mensagem se processo possuir adiantamento
   IF lImpObs
      oReport:SkipLine(3)
      oReport:FatLine()
      oReport:PrintText(STR0108) 
      oReport:FatLine()
   ENDIF
   
   //Fim da impressão da seção 1
   oReport:Section(cNome):Finish()
   
   TRB->(DBGOTOP())   
   Return .T.



ENDIF


//TRP - 02/08/2006 Atualiza o mes e o ano no titulo do relatorio
Static Function AltTit()
oReport:cTitle:=STR0069+" - "+UPPER(Nome_Mes(MONTH(TRB->WB_DT_CONT)))+"/"+STR(YEAR(TRB->WB_DT_CONT),4,0)

Return .t.

*-----------------------------------------------*
Static Function CalcVlDolar(nVlrSWB)
*-----------------------------------------------*

nVlDolar:= IF(SWB->WB_MOEDA $ BuscaDolar(),nVlrUSS := nVlrSWB ,nVlrUSS :=nVlrSWB * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_CONT,,.F.) / BuscaTaxa(BuscaDolar(),SWB->WB_DT_CONT,,.F.))

IF(EasyEntryPoint("EICAP180"),ExecBlock("EICAP180",.F.,.F.,"ALTERA_VLDOLAR"),)

Return nVlDolar

*------------------------------------------*
Static Function CalcVlReal(nVlrSWB,bFobReal)
*------------------------------------------*

nVlReal:= If( !EMPTY(SWB->WB_CA_TX),EVAL(bFOBREAL),M->WB_FOBREAL := nVlrSWB * BuscaTaxa(SWB->WB_MOEDA,SWB->WB_DT_CONT,,.F.))

IF(EasyEntryPoint("EICAP180"),ExecBlock("EICAP180",.F.,.F.,"ALTERA_VLREAL"),)

Return nVlReal


//---------------------------------------------------------------------------//
//                        FIM DO PROGRAMA EICAP180.PRW              
//---------------------------------------------------------------------------// 
