//#include "FiveWin.ch"
#include "Average.ch"
#include "avprint.ch"
#include "EICAP150.ch"
#COMMAND E_RESET_AREA => Work->(E_EraseArq(cNomArq,WorkNTX)) ;
                       ; DBSELECTAREA(nOldArea) ; RETURN NIL
                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICAP150 ³ Autor ³ AVERAGE/ALEX WALLAUER ³ Data ³ 06.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ PREVISAO DIARIA                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICAP150()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// EOS - OS 624/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICAP150
// um parametro como .T. identificando que é schedulado 
******************
Function EICAP150S
******************
EICAP150(.T.)
RETURN NIL
        
***********************
Function EICAP150(lSXD)
***********************
//Função modificada para compatibilidade com o Release 4 da 8.11 - JWJ
Local lR4
lR4 := FindFunction("TRepInUse") .And. TRepInUse()
EICAP150R3(lSXD, lR4)
RETURN NIL

*********************************
Function EICAP150R3(lSXD, lTemR4)
*********************************
LOCAL nOldArea:=SELECT(), TB_Campos2:={}, TB_Campos:={}
LOCAL nSx3Ord:=SX3->(INDEXORD())

DEFAULT lTemR4 := .F.

//oSCabec: seção contendo os dados de cabeçalho
PRIVATE lR4 := lTemR4
PRIVATE oReport, oSecao1, oSecao2, oBreak //, oSCabec

PRIVATE dDataI := dDataF := AVCTOD(''), aDados:=Array(12)
PRIVATE nValTot:=0,nValMoe:=0,cQuebra:='',cImport,cOpcao:=0,cCusto, dDataEmi, aRodape:={}
PRIVATE aHeader[0], cNomArq, cCadastro := STR0031 //"Relat¢rio de Controle de Cƒmbio"
PRIVATE lEmail := !lSXD = NIL // EOS
PRIVATE lContabil := EasyGParam("MV_EIC_ECO",,"N") $ cSim

AADD(TB_Campos,{"WB_HAWB"   ,"",STR0001})//"Processo"
AADD(TB_Campos,{"WB_INVOICE","",STR0002})//"Invoices"
AADD(TB_Campos,{"WK_DT_EMIS","",AVSX3("W9_DT_EMIS",5),""})
AADD(TB_Campos,{"Y3_COD"    ,"",STR0003,ALLTRIM(X3Picture("Y3_COD"))})//"Cod. CC"
AADD(TB_Campos,{"Y3_DESC"   ,"",STR0004,"!!!!!!!!!!!!!!"})//"Centro de Custo"
//AADD(TB_Campos,{"WK_FATURA" ,"",STR0005,""})//"Fatura"
AADD(TB_Campos,{"WK_DT_VEN" ,"",STR0007 })//"Dt Vencto"
AADD(TB_Campos,{"A2_NREDUZ" ,"",STR0008 })//"Fornecedor"
AADD(TB_Campos,{"W2_MOEDA"  ,"",STR0009})//"Moeda"
AADD(TB_Campos,{"WK_FOBMOE" ,"",STR0010,'@E 99,999,999,999.99'}) //"Valor"
AADD(TB_Campos,{"A6_NOME"   ,"",STR0011}) //"Banco"
AADD(TB_Campos,{"WK_DTREG_D","",STR0012}) //"Data DI"
AADD(TB_Campos,{"WK_CA_DT"  ,"",STR0013}) //"Dt Remessa"
AADD(TB_Campos,{"WK_ENV_BAC","",STR0014}) //"Dt Envio"

AADD(TB_Campos2,{"WK_GRUPO"  ,"",STR0015}) //"Grupo"
AADD(TB_Campos2,{"WK_DT_VEN" ,"",STR0016 })//"Dt Vencto"
AADD(TB_Campos2,{"WB_HAWB"   ,"",STR0017}) //"Processo"
AADD(TB_Campos2,{"WB_INVOICE","",STR0018}) // "Invoices"
AADD(TB_Campos2,{"WK_DT_EMIS","",AVSX3("W9_DT_EMIS",5),""})
AADD(TB_Campos2,{"Y3_COD"    ,"",STR0019,ALLTRIM(X3Picture("Y3_COD"))}) //"Cod. CC"
AADD(TB_Campos2,{"Y3_DESC"   ,"",STR0020,"!!!!!!!!!!!!!!"}) //"Centro de Custo"
AADD(TB_Campos2,{"W2_MOEDA"  ,"",STR0021}) //"Moeda"
AADD(TB_Campos2,{"WK_FOBMOE" ,"",STR0010,'@E 99,999,999,999.99'}) //"Moeda"
//AADD(TB_Campos2,{"WK_FATURA" ,"",STR0023,""}) //"Fatura"
AADD(TB_Campos2,{"A2_NREDUZ" ,"",STR0025 }) //"Fornecedor"
AADD(TB_Campos2,{"A6_COD"    ,"",STR0026}) //"Cod Bco"
AADD(TB_Campos2,{"A6_NOME"   ,"",STR0027}) //"Banco"
AADD(TB_Campos2,{"WK_DTREG_D","",STR0012}) //"Data DI"
AADD(TB_Campos2,{"WK_CA_DT"  ,"",STR0029}) //"Dt Remessa"
AADD(TB_Campos2,{"WK_ENV_BAC","",STR0030}) //"Dt Envio"

aRCampos:= E_CriaRCampos(TB_Campos,"C")

PRIVATE aCampos:={"Y3_COD","Y3_DESC","W7_FORN","A2_NREDUZ","W2_MOEDA","A6_COD","A6_NOME"}

PRIVATE aSemSX3:={{"WB_HAWB"   ,"C",AVSX3("WB_HAWB",3),0},;
                  {"WB_INVOICE","C",AVSX3("WB_INVOICE",3),0},;
                  {"WK_GRUPO"  ,"C",AVSX3("A2_GRUPO",3),0},;
                  {"WK_DT_VEN" ,"D", 8,0},;
                  {"WK_DTREG_D","D", 8,0},;
                  {"WK_CA_DT"  ,"D", 8,0},;
                  {"WK_ENV_BAC","D", 8,0},;
                  {"WK_DT_EMIS","D", 8,0},;
                  {"WK_FOBMOE" ,"N",16,2},;
                  {"WK_FOB_RS" ,"N",20,2},;
                  {"WK_FATURA" ,"C",24,0}}

PRIVATE lCposAdto := .F.  // EOS - variavel p/ verificar se existem os 
                          // cpos p/ o tratamento do pgto antecipado.
                             
PRIVATE lImpObs := .F.    // EOS - variavel p/ tratar se deve imprimir
                          // legenda ref. a pgto antecipado                             
                             
SX3->(DBSETORDER(2))                             
lCposAdto:=SX3->(DBSEEK("WB_PO_DI")) .AND. SX3->(DBSEEK("WB_PGTANT")) .AND. SX3->(DBSEEK("WB_NUMPO"))
SX3->(DBSETORDER(1))
cNomArq:=E_CriaTrab(,aSemSX3,"Work")
IndRegua("Work",cNomArq+TEOrdBagExt(),"WK_GRUPO+DTOS(WK_DT_VEN)")

WorkNTX:=E_Create({{"W","N",1,0}},.F.)//APENAS GERA UM NOME PARA O INDICE 2
IndRegua("Work",WorkNTX+TEOrdBagExt(),"W2_MOEDA+DTOS(WK_DT_VEN)")

SET INDEX TO (cNomArq+TEOrdBagExt()),(WorkNTX+TEOrdBagExt())

PRIVATE cPicImp  :=ALLTRIM(X3Picture("W2_IMPORT"))
PRIVATE cPicCC   :=ALLTRIM(X3Picture("Y3_COD"))
PRIVATE aBotoes:={{"S4WB010N" ,{|| IF(lR4,(oReport := ReportDef(),oReport:PrintDialog()), E_Report(aDados,aRCampos)) },STR0083,STR0089}}

cImport:= SYT->YT_COD_IMP
dDataI := dDataF := AVCTOD('')
cCusto := SY3->Y3_COD

aDados[01]:="Work"
aDados[02]:=STR0045 //"Este relat¢rio imprimir  a PrevisÆo Di ria"
aDados[03]:=""
aDados[04]:=""
aDados[05]:="G"
aDados[06]:=220
aDados[08]:=""
aDados[09]:=STR0046 //"1 - Previsao Diaria"
aDados[10]:={STR0049 , 1,STR0050, 1, 2, 1, "",1 } //"Zebrado"###"Importa‡Æo"
aDados[11]:="EICAP150"
aDados[12]:={{|| AP150QUEBRA() },{|| AP150RODAPE() } }



DO WHILE .T.
   IF !Pergunte("EIC150", IF(lEmail, .F., .T.))
      E_RESET_AREA
      RETURN .F.      
   ENDIF 
   IF lEmail
      aReturn   := aDados[10]
      aDados[11]:= SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
   ENDIF
   cImport := mv_par01
   cOpcao  := mv_par02
   cCusto  := mv_par03
   dDataI  := mv_par04
   dDataF  := mv_par05
   
   //IF lR4
      //oReport := ReportDef()
   //ENDIF

   cTit2:= STR0040+AllTrim(cImport)+" "+Alltrim(SYT->YT_NOME_RED)+SPACE(5) //"Importador.: "
   cTit2+= STR0041 + IF(EMPTY(cCusto),STR0042,Alltrim(cCusto))+spac(5)//"Centro de Custo.: "###"Todos"
   cTit2+= STR0043 + DTOC(dDataI)+STR0044+DTOC(dDataF) //"Periodo.: "###' a '

   aDados[07]:=cTit2
   IF cOpcao = 1
      aDados[2]:=STR0045 //"Este relat¢rio imprimir  a PrevisÆo Di ria"
      aDados[09]:=STR0046 //"1 - Previsao Diaria"
      Work->(DBSETORDER(1))
   ELSE
      aDados[02]:=STR0047 //"Este relat¢rio imprimir  a Rela‡Æo por Empresa"
      aDados[09]:=STR0048 //"2 - Relacao por Empresa"
      Work->(DBSETORDER(2))
   ENDIF

   lOK:= .F.
   
   IF !lEmail
      Processa({|lEnd|lOK:=AP150_GWork()})
   ELSE
      lOk:= AP150_GWork()
      IF lOk
         E_Report(aDados,aRCampos,,.F.)         
      ENDIF
      E_RESET_AREA
      EXIT
   ENDIF
   
   IF !lOK
      Help("", 1, "AVG0000197")//MSGINFO(STR0052,STR0053) //"NÆo h  Registros a serem Processados"###"Informação"
      LOOP
   ELSE
      nOpca:=0

      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE cCadastro ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
            TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

         Work->(DBGOTOP())
         oMark:= MsSelect():New("Work",,,TB_Campos2,.F.,"XX",{18,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
         oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      ACTIVATE MSDIALOG oDlg ON INIT ;
               (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                             {||nOpca:=0,oDlg:End()},,aBotoes))  //LRL 29/04/04 - Alinhamento MDI

      IF nOpca = 0
         E_RESET_AREA
      ENDIF
   ENDIF
   
   Work->(avzap())
ENDDO

RETURN .T.

*---------------------------*
FUNCTION AP150Verif(nVerif)
*---------------------------*
DO CASE
   CASE nVerif=1
        IF EMPTY(mv_par01)
           Help("", 1, "AVG0000150")//MsgINFO(STR0054,STR0055) //'C¢digo do Importador deve ser informado'###"Atenção"
           RETURN .F.
        ELSEIF !SYT->(DBSEEK(xFilial("SYT")+mv_par01))
           Help("", 1, "AVG0000138")//MsgInfo(STR0056,STR0057)//'C¢digo do Importador nÆo cadastrado'###"Informação"
           RETURN .F.
        ENDIF

   CASE nVerif=2
        IF !EMPTY(mv_par03)
           IF !SY3->(DBSEEK(xFilial("SY3")+mv_par03))
              Help("", 1, "AVG0000198")//MSGINFO(STR0058,STR0059)//'Centro de Custo nÆo Cadastrado'###"Informação"
              RETURN .F.
           ENDIF
        ENDIF

   CASE nVerif=3
        IF !EMPTY(mv_par05)
           IF mv_par04 > mv_par05
              Help("", 1, "AVG0000199")//MsgInfo(STR0060,STR0061)//'Data Inicial Maior que Data Final'###"Atenção"
              RETURN .F.
           ENDIF
        ENDIF

ENDCASE

RETURN .T.

*-----------------------*
FUNCTION AP150_GWork()
*-----------------------*
Local cHawb, cTpLanc, cNumPO, bSkip,;
      bDtI_Ven:= {|| IF(!EMPTY(dDataI),(SWB->WB_DT_VEN>=dDataI),.T.)}  ,;
      bDtF_Ven:= {|| IF(!EMPTY(dDataF),(SWB->WB_DT_VEN<=dDataF),.T.)}  ,;
      bDtI_Pag:= {|| IF(!EMPTY(dDataI),(SWB->WB_CA_DT>=dDataI),.T.)} ,;
      bDtF_Pag:= {|| IF(!EMPTY(dDataF),(SWB->WB_CA_DT<=dDataF),.T.)}

Private nTotal:= 0, lLctoDi := .T.
// Atribui codeblock diferenciado, caso tenha os cpos ref. a adiantamento
IF lCposAdto  
   bSkip := {|| SWB->(DBEVAL({||IncProc(STR0062+SWB->WB_HAWB)},,{||SWB->WB_FILIAL==xFilial("SWB") .AND. SWB->WB_HAWB==cHawb .AND. SWB->WB_PO_DI==cTpLanc},,,.T.))}
ELSE
   bSkip := {|| SWB->(DBEVAL({||IncProc(STR0062+SWB->WB_HAWB)},,{||SWB->WB_FILIAL==xFilial("SWB") .AND. SWB->WB_HAWB==cHawb},,,.T.))}
ENDIF   

SW9->(DBSETORDER(3))
SWA->(DbSetOrder(1))
SWB->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW1->(DBSETORDER(2))//TDF - 04/05/10
SWB->(DBSEEK(xFilial("SWB")))

IF !lEmail
   ProcRegua(SWB->(LASTREC()))
ENDIF

DO WHILE !SWB->(EOF()) .AND. SWB->WB_FILIAL==xFilial("SWB")
   cHawb  :=SWB->WB_HAWB
   lLctoDi:=.T.
   cYSTipo:="I" 
   bWhile:={||SYS->YS_FILIAL ==xFilial("SYS") .AND.;
              SYS->YS_TPMODU =="I"            .AND.;
              SYS->YS_TIPO   ==cYSTipo        .AND.;
              SYS->YS_HAWB   ==SWB->WB_HAWB   .AND.;
              SYS->YS_FORN   ==SWB->WB_FORN   .AND.;
              SYS->YS_MOEDA  ==SWB->WB_MOEDA  .AND.;
              SYS->YS_INVOICE==SWB->WB_INVOICE}                          
              
   cSYSChave:=xFilial("SYS")+"II"+SWB->WB_HAWB+SWB->WB_FORN+SWB->WB_MOEDA+SWB->WB_INVOICE

   // Tratar lanctos ref. a pgto antecipado
   If lCposAdto                  
      cTpLanc := SWB->WB_PO_DI
      If (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C" )	// GCC - 28/08/2013
         lLctoDi  := .F.
         cNumPo   := If(SWB->WB_PO_DI == "A", SWB->WB_HAWB, )
         cYSTipo  := "P"
         
         bWhile:={||SYS->YS_FILIAL ==xFilial("SYS") .AND.;
                    SYS->YS_TPMODU =="I"            .AND.;
                    SYS->YS_TIPO   ==cYSTipo        .AND.;
                    SYS->YS_HAWB   ==SWB->WB_HAWB   .AND.;
                    SYS->YS_FORN   ==SWB->WB_FORN   .AND.;
                    SYS->YS_MOEDA  ==SWB->WB_MOEDA }           
                    
         cSYSChave:=xFilial("SYS")+"IP"+SWB->WB_HAWB+SWB->WB_FORN+SWB->WB_MOEDA
      EndIf
   EndIf   

   IF !lEmail
      IncProc(STR0063+SWB->WB_HAWB) //'Processando Processo: '
   ENDIF

   IF lLctoDi     
      IF lCposAdto .AND. Left(SWB->WB_TIPOREG,1) == "P" .AND. !EMPTY(SWB->WB_NUMPO)
         // Despreza os registros de adiantamentos das parcelas de cambio de DI
         EVAL(bSkip)
         LOOP
      ENDIF             
      
      IF SWB->WB_FOBMOE <= 0
         SWB->(dbSkip())
         LOOP
      ENDIF

      IF !SW6->(DBSEEK(xFilial("SW6")+SWB->WB_HAWB))
         IF !lEmail
            Help("", 1, "AVG0000200",,(SWB->WB_HAWB)+ "nao encontrado nas Declaracoes", 1,10)//MsgInfo(STR0064+ SWB->WB_HAWB + STR0065,STR0066) //"Processo: "###" nÆo encontrado nas Declara‡äes"###"Informação"
         ENDIF
         EVAL(bSkip)
         LOOP
      ENDIF

      IF !SW7->(DBSEEK(xFilial("SW7")+SWB->WB_HAWB))
         IF !lEmail
            Help("", 1, "AVG0000200",,(SWB->WB_HAWB)+ "nao encontrado nos Itens Declaracoes", 1,10)//MsgInfo(STR0067+ SWB->WB_HAWB + STR0068,STR0069)//"Processo: "###" nÆo encontrado nos Itens Declara‡äes"###"Informação"
         ENDIF
         EVAL(bSkip)
         LOOP
      ENDIF

      SW9->(DBSEEK(xFilial("SW9")+cHawb))
      
      cNumPO   := SW7->W7_PO_NUM

   ENDIF

   If SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "D"
      IF !SW2->(DBSEEK(xFilial("SW2")+cNumPO))
	     IF !lEmail
	        Help("", 1, "AVG0000216",,(cNumPO)+ "nao encontrado nos Pedidos", 1,08)//MsgInfo(STR0084+ SW7->W7_PO_NUM+STR0073,STR0074)//"Pedido: "###" nÆo encontrado nos Pedidos"###"Informação"
	     ENDIF
	     EVAL(bSkip)
	     LOOP
	  ENDIF   
	
	  IF !SA2->(DBSEEK(xFilial()+SW2->W2_FORN))
	     IF !lEmail
	        Help("", 1, "AVG0000215",,(SW2->W2_FORN)+ "nao cadastrado nos Fornecedores", 1,12)//MsgInfo(STR0070+SW7->W7_FORN+STR0071,STR0072)//"Forncedor: "###" nÆo Cadastrado nos Fornecedores"###"Informação"
	     ENDIF
	     EVAL(bSkip)
	     LOOP
	  ENDIF
	
	  IF !EMPTY(ALLTRIM(cImport))
	     IF ALLTRIM(cImport) # ALLTRIM(SW2->W2_IMPORT)
	        EVAL(bSkip)
	        LOOP
	     ENDIF
	  ENDIF
   ElseIf SWB->WB_PO_DI == "C" .Or. SWB->WB_PO_DI == "F"  // GCC - 24/09/2013 - Tratamento para adiantamentos vinculados a Fornecedor / Credito
      If !SWA->(DbSeek(xFilial("SWA")+cHawb+SWB->WB_PO_DI))
	     If !lEmail
	        Help("", 1, "AVG0000217",,(cHawb)+ "nao encontrado nos Adiantamentos", 1,08)//MsgInfo(STR0084+ SW7->W7_PO_NUM+STR0073,STR0074)//"Adiantamento: "###" não encontrado nos Adiantamento"###"Informação" 
	     EndIf
	     Eval(bSkip)
	     Loop
	  EndIf   
	
	  If !SA2->(DbSeek(xFilial()+SWB->WB_FORN))
	     If !lEmail
	        Help("", 1, "AVG0000215",,(SWB->WB_FORN)+ "nao cadastrado nos Fornecedores", 1,12)//MsgInfo(STR0070+SW7->W7_FORN+STR0071,STR0072)//"Forncedor: "###" não Cadastrado nos Fornecedores"###"Informação"
	     EndIf
	     Eval(bSkip)
	     Loop
	  EndIf
   EndIf

   IF cOpcao = 1
      IF ! EMPTY(SWB->WB_CA_DT)
         SWB->(DBSKIP())
         LOOP
      ENDIF
      IF ! EVAL(bDtI_Ven) .OR. ! EVAL(bDtF_Ven)
         SWB->(DBSKIP())
         LOOP
      ENDIF
   ELSE
      IF EMPTY(SWB->WB_CA_DT)
         IF ! EVAL(bDtI_Ven) .OR. ! EVAL(bDtF_Ven)
            SWB->(DBSKIP())
            LOOP
         ENDIF
      ELSE
         IF ! EVAL(bDtI_Pag) .OR. ! EVAL(bDtF_Pag)
            SWB->(DBSKIP())
            LOOP
         ENDIF
      ENDIF
   ENDIF

   SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA))
   IF lContabil//SVG - 14/10/2009 - Verificação de integração com contabil.
      If SYS->(DBSEEK(cSYSChave))
         Do While !SYS->(EOF()) .AND. EVAL(bWhile) 
            If !Empty(cCusto)
               If SYS->YS_CC # cCusto
                  SYS->(dbSkip())
                  LOOP
               ENDIF  
            ENDIF
            AppendWork(SYS->YS_CC, SYS->YS_PERC)
            SYS->(DBSKIP())
         EndDo
      Else
         AppendWork("", 1)
      EndIf
   ELSE //TDF - 04/05/10 - Tratamento diferenciado quando não há integração com contabil.
      SW1->(DBSEEK(xFilial("SW1")+SW2->W2_PO_NUM))
      If !Empty(cCusto)
         If SW1->W1_CC == cCusto 
            AppendWork(SW1->W1_CC, 1)
         EndIf
      Else
         AppendWork(SW1->W1_CC, 1)
      EndIf      
   ENDIF
   
   SWB->(DBSKIP())
ENDDO

SW9->(DBSETORDER(1))

RETURN IF(nTotal>0,.T.,.F.) 

/*
Função..: AppendWork
Autor...: Saimon Vincius Gava - SVG
Data....: 14/10/2009
Objetivo: Gravar a work de acordo com o contabil.
Parâmetros: cCc, nPerc
Retorno:
Revisão: Tamires Daglio(TDF) - 04/05/10 - Utilização dos parâmetros.
*/
*------------------------------------*
Static Function AppendWork(cCC, nPerc)
*------------------------------------*
SA2->(dbSeek(xFilial("SA2")+SWB->WB_FORN+SWB->WB_LOJA)) // SVG - 18/07/2011 - Seek para pegar o forncedor correto
Work->(DBAPPEND())
// Valida se preve pgto antecipado, tratando cpos da Work
IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 28/08/2013
   Work->WB_HAWB   := "* " + SWB->WB_HAWB
   Work->WK_FOBMOE := SWB->WB_PGTANT * nPerc
   Work->WK_FOB_RS := SWB->WB_PGTANT * nPerc * SWB->WB_CA_TX         
   lImpObs := .T.
ELSE
   Work->WB_HAWB   := SWB->WB_HAWB      
   Work->WK_FOBMOE := SWB->WB_FOBMOE * nPerc
   Work->WK_FOB_RS := SWB->WB_FOBMOE * nPerc * SWB->WB_CA_TX
ENDIF
Work->WB_INVOICE := SWB->WB_INVOICE
Work->Y3_COD     := cCC
Work->Y3_DESC    := BuscaCCusto(Work->Y3_COD)
Work->WK_GRUPO   := SA2->A2_GRUPO
Work->WK_DT_VEN  := SWB->WB_DT_VEN
Work->W7_FORN    := SW7->W7_FORN
Work->A2_NREDUZ  := SA2->A2_NREDUZ
Work->W2_MOEDA   := SW2->W2_MOEDA
Work->WK_DT_EMIS := IF(lLctoDi,SW9->W9_DT_EMIS,SW2->W2_PO_DT)
Work->A6_COD     := SA6->A6_COD
Work->A6_NOME    := SA6->A6_NOME
Work->WK_DTREG_D := SW6->W6_DTREG_D
Work->WK_CA_DT   := SWB->WB_CA_DT
Work->WK_ENV_BAC := SWB->WB_ENV_BAC
nTotal++

*--------------------------------------*
FUNCTION AP150Quebra()
*--------------------------------------*
IF cOpcao = 1
   IF cQuebra # Work->WK_GRUPO
      cQuebra:=Work->WK_GRUPO
      AP150CabRel()
      Linha++
      @ Linha, 1 PSAY STR0075 +cQuebra //'* GRUPO: '
   ENDIF
ELSE
   IF cQuebra # Work->W2_MOEDA
      IF ! Empty(Alltrim(cQuebra))
         AADD(aRodape,{cQuebra,TRANS(nValMoe,'@E 999,999,999,999.99')})
      ENDIF
      IF nValMoe # 0
         SYF->(DBSEEK(xFilial("SYF")+cQuebra))
         AP150CabRel()
         Linha++
         @ Linha, T_Len[1,2] PSAY STR0076 //'** TOTAL DA MOEDA: '
         @ Linha, T_Len[5,2] PSAY SYF->YF_DESC_SI
         @ Linha, T_Len[8,2]+1 PSAY cQuebra
         @ Linha, (T_Len[9,2]-1) PSAY TRANS(nValMoe,'@E 999,999,999,999.99')
         Linha++
      ENDIF
      cQuebra:=Work->W2_MOEDA
      nValTot:=Work->WK_FOB_RS
      nValMoe:=Work->WK_FOBMOE
   ELSE
      nValTot+=Work->WK_FOB_RS
      nValMoe+=Work->WK_FOBMOE
   ENDIF
ENDIF
RETURN .T.

*-----------------------*
FUNCTION AP150Rodape()
*-----------------------*
Local I //LRL 23/01/04
IF cOpcao = 2
   IF ! Empty(Alltrim(cQuebra))
      AADD(aRodape,{cQuebra,TRANS(nValMoe,'@E 999,999,999,999.99')})
   ENDIF
   IF nValMoe # 0
      Linha+=1
      SYF->(DBSEEK(xFilial("SYF")+cQuebra))
      AP150CabRel()
      @ Linha, T_Len[1,2]     PSAY STR0077 //'** TOTAL DA MOEDA: '
      @ Linha, T_Len[5,2]     PSAY SYF->YF_DESC_SI
      @ Linha, T_Len[8,2]+1   PSAY cQuebra
      @ Linha, (T_Len[9,2]-1) PSAY TRANS(nValMoe,'@E 999,999,999,999.99')
      Linha+=1
   ENDIF
   Linha+=1
   FOR I=1 TO LEN(aRodape)
       AP150CabRel()
       IF I = 1
          @ Linha, T_Len[1,2] PSAY STR0078 //'** TOTAL GERAL...:'
       ENDIF
       SYF->(DBSEEK(xFilial("SYF")+aRodape[I,1]))
       @ Linha , T_Len[5,2]     PSAY SYF->YF_DESC_SI
       @ Linha , T_Len[8,2]+1   PSAY aRodape[I,1]
       @ Linha , (T_Len[9,2]-1) PSAY aRodape[I,2]
       Linha+=1
   NEXT
ENDIF
IF lImpObs
   Linha+=2
   @ Linha, T_Len[1,2] PSAY STR0084 
ENDIF

RETURN .T.

*-----------------------*
FUNCTION AP150CabRel()
*-----------------------*
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3
LOCAL b_lin :={|valor,ind| F_Ler_Tab(R_Campos,ind)}

IF Linha > 55
   Cabec(titulo,aDados[7],aDados[8],nomeprog,aDados[5],EasyGParam("MV_COMP"))
   If Empty(aDados[7]) .And. Empty(aDados[8])
      @ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
   Endif
   Linha:=PROW()+1
   l_tag:=say_tit
   AEVAL(R_Campos, b_lin)
   Linha++
   l_tag:=say_rep
   AEVAL(R_Campos, b_lin)
End

RETURN .T.

***************************
Static Function ReportDef()
***************************
Local oReport, oTotal, oColl

aTabelas := {'SA2', 'SA6', 'SW2', 'SW7', 'SY3', 'SWB'} 
   
aOrdem   := {}

IF cOpcao == 1  //PREVISAO DIARIA
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICAP150",STR0046,"EIC150"       ,{|oReport| ReportPrint(oReport)}, STR0045)  
ELSE            //RELACAO POR EMPRESA
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICAP150",STR0048,"EIC150"       ,{|oReport| ReportPrint(oReport)}, STR0047)
ENDIF

//Define como padrão o formato Paisagem
oReport:oPage:lLandscape := .T.
oReport:oPage:lPortrait := .F.
   
//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Invoices",aTabelas,aOrdem)

TRCell():New(oSecao1, 'WB_HAWB'   , 'WORK', STR0001              ,                             , LEN(WORK->WB_HAWB)    , ,  )
TRCell():New(oSecao1, 'WB_INVOICE', 'WORK', STR0002              ,                             , LEN(WORK->WB_INVOICE) , ,  )
TRCell():New(oSecao1, 'WK_DT_EMIS', 'WORK', AVSX3("W9_DT_EMIS",5),                             , /*8*/ 14   , ,  )    // GFP - 29/03/2012 - Ajuste de tamanho de data
TRCell():New(oSecao1, 'Y3_COD'    , 'WORK', STR0003              , ALLTRIM(X3Picture("Y3_COD")) , LEN(WORK->Y3_COD) , ,  )
TRCell():New(oSecao1, 'Y3_DESC'   , 'WORK', STR0004              , "@!"                        , LEN(WORK->Y3_DESC), ,  )
TRCell():New(oSecao1, 'WK_DT_VEN' , 'WORK', STR0007              ,                             , /*8*/ 14   , ,  )    // GFP - 29/03/2012 - Ajuste de tamanho de data
TRCell():New(oSecao1, 'A2_NREDUZ' , 'WORK', STR0008              ,                             , LEN(WORK->A2_NREDUZ) , ,  )
TRCell():New(oSecao1, 'W2_MOEDA'  , 'WORK', STR0009              ,                             , LEN(WORK->W2_MOEDA) , ,  )
TRCell():New(oSecao1, 'WK_FOBMOE' , 'WORK', STR0010              , "@E 99,999,999,999.99"      , 16      , ,  )
TRCell():New(oSecao1, 'A6_NOME'   , 'WORK', STR0011              ,                             , LEN(WORK->A6_NOME) , ,  )
TRCell():New(oSecao1, 'WK_DTREG_D', 'WORK', STR0012              ,                             , /*8*/ 14   , ,  )    // GFP - 29/03/2012 - Ajuste de tamanho de data
TRCell():New(oSecao1, 'WK_CA_DT'  , 'WORK', STR0013              ,                             , /*8*/ 14   , ,  )    // GFP - 29/03/2012 - Ajuste de tamanho de data
TRCell():New(oSecao1, 'WK_ENV_BAC', 'WORK', STR0014              ,                             , 8       , ,  )

IF cOpcao == 1
   oSecao2 := TRSection():New(oReport,"Filtros",{"Work"},aOrdem)
   TRCell():New(oSecao2, 'WK_GRUPO', 'WORK', STR0015, ,AVSX3("A2_GRUPO",3) ,,)

ELSE
   oBreak := TRBreak():New(oSecao1, {|| Work->W2_MOEDA}, "", .F. )
   oBreak:bTotalText := {|| Work->(DBSKIP(-1)), cQuebra:=STR0077+Work->W2_MOEDA, Work->(DBSKIP()), cQuebra  }
   
   oTotal := TRFunction():New(oSecao1:Cell("WK_FOBMOE"),NIL,"SUM",oBreak,STR0077,/*cPicture*/,/*uFormula*/{|| Work->WK_FOBMOE} ,.F.,.F.,.F.)
   oTotal:SetTotalInLine(.F.)

   oSecao1:SetTotalInLine(.F.)
   oSecao1:SetTotalText(STR0078)
   
   oColl := TRCollection():New(, "SUM", /*oBreak*/,;
									/*cTitle*/"", /*cPicture*/, /*uFormula*/"W2_MOEDA", /*.lEndSection.*/ .F.,;
									/*.lEndReport.*/ .T., /*oParent*/ oSecao1, /*bCondition*/,;
									/*uContent*/ "WK_FOBMOE" ) //LRS - 29/05/2017 - uFormula e uContent deve ser caracter ou bloco de codigo
//   oColl:bTotalText := {|| STR0078 }
   
//   oReport:SetCustomText("Texto da linha de cabeçalho") // aqui deve ir o conteudo de aDados[7]
   
ENDIF

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local nRec
cQuebra := ''

oReport:SetMeter (WORK->(EasyRecCount()))

Work->(DBGOTOP())

IF cOpcao == 1
    nRec := Work->(RECNO())
	Work->( dbGoTop() )
	lPrimeira := .T.
	//Força a impressao de uma linha em branco para imprimir o cabeçalho da seção 1

    //Imprime a linha de cabeçalho do relatório antigo
    //Substituir pelo método SetCustomText()
  	nRow := oReport:nRow
	oReport:PrintText(aDados[7], oReport:nRow - 120, 10)	   
    oReport:nRow := nRow
	
    oSecao1:Init()
    oReport:SkipLine(9)
	
	Do While WORK->(!EOF()) .And. !oReport:Cancel()
		
		oSecao2:Init()
		oSecao2:PrintLine()
		oSecao2:Finish()

		If !lPrimeira
           oReport:SkipLine()
           oSecao1:PrintHeader()
        EndIf
	
		cQuebra := Work->WK_GRUPO
       	
		Do While WORK->(!EOF()) .And. !oReport:Cancel() .And. (cQuebra == Work->WK_GRUPO)
		   oReport:Section("Invoices"):PrintLine() //Impressão da linha
		   oReport:IncMeter()                     //Incrementa a barra de progresso
           lPrimeira := .F.
		   WORK->( dbSkip() )
		EndDo
	Enddo
	
	Work->(Dbgoto(nRec))
	Work->(DBDELETE())

ELSE
	Work->(DBGOTOP())
	
    oSecao1:Init()
	lHeader := .F.
	
	Do While WORK->(!EOF()) .And. !oReport:Cancel()
	   oSecao1:PrintLine()
	   
	   IF .Not. lHeader
	      //Imprime a linha de cabeçalho do relatório antigo
	      //Substituir pelo método SetCustomText()
	      nRow := oReport:nRow
	      oReport:PrintText(aDados[7], oReport:nRow - 120, 10)	   
	      oReport:nRow := nRow
	      
	      lHeader := .T.
	   ENDIF
	   
	   oReport:IncMeter()                     //Incrementa a barra de progresso
	   
	   WORK->(DBSKIP())
	Enddo
	
	oSecao1:Finish()

ENDIF

WORK->(DBGOTOP())

Return .T.
