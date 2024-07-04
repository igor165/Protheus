#INCLUDE "Eicap151.ch"
//#include "FiveWin.ch"
#include "Average.ch"
#include "avprint.ch"

#COMMAND E_RESET_AREA => Work->(E_EraseArq(cNomArq,WorkNTX)) ;
                       ; DBSELECTAREA(nOldArea) ; RETURN NIL
                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICAP151 ³ Autor ³ AVERAGE/ALEX WALLAUER ³ Data ³ 09.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ PREVISAO DIARIA                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICAP151()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// EOS - OS 590/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICAP151
// um parametro como .T. identificando que é schedulado 
*--------------------------*
FUNCTION EICAP151S()
*--------------------------*
EICAP151(.T.)
RETURN NIL

*-----------------------*
FUNCTION EICAP151(lSXD)
*-----------------------*
LOCAL nOldArea:=SELECT(), TB_Campos3:={}, TB_Campos2:={}, TB_Campos:={}, cSaveMenuh, nCnt, nPosGet, aPos:={}, nPos:= 0
PRIVATE lEMail:=!lSXD = Nil
PRIVATE dDataI := dDataF := AVCTOD(''), aDados:=Array(12)
PRIVATE dDataEmi,nValTot:=0,cQuebra1:='',nQuebra2:='',nQuebra3:='',cImport, nTipRel:=1, aRodape:={},nQuebra:=0,aValTot:={}
PRIVATE nFornec := Space(AVSX3("A2_COD",3)),cForLoj:= Space(AVSX3("A2_LOJA",3)),cCusto:=Space(AVSX3("Y3_COD",3)) //SO.:0026/02 O.S.:0210/02 FCD 01/04/02 
PRIVATE nColTot,nColMoe,nValMoe,nMoeCol,cMoedaF,cCampo
PRIVATE lContabil := EasyGParam("MV_EIC_ECO",,"N") $ cSim

//Campos para o Relatorios 1,2 e 4
AADD(TB_Campos,{"WK_HAWB"   ,"",STR0001}) //"Processo"
AADD(TB_Campos,{"WK_INVOICE","",STR0002}) //"Invoices"
//AADD(TB_Campos,{"WK_FATURA" ,"",STR0003,""}) //"Fatura"
If lContabil //FSY - 02/05/2013
   AADD(TB_Campos,{"Y3_COD"    ,"",STR0004}) //"Cod. CC"
   AADD(TB_Campos,{"Y3_DESC"   ,"",STR0005,/*"!!!!!!!!!!!!!!" FSY - 02/05/2013*/}) //"Centro de Custo"
End If
AADD(TB_Campos,{"W2_MOEDA"  ,"",STR0007}) //"Moeda" 
AADD(TB_Campos,{"WK_FOBMOE" ,"",STR0006,'@E 99,999,999,999.99'}) //"Valor"
AADD(TB_Campos,{"WK_GRUPO"  ,"",STR0008}) //"Grupo"
AADD(TB_Campos,{"WK_CA_TX"  ,"",STR0009}) //"Tx. Baixa"
AADD(TB_Campos,{"WK_DT_VEN" ,"",STR0010 }) //"Dt Vencto"
AADD(TB_Campos,{"WK_CA_DT"  ,"",STR0011}) //"Dt Baixa"
AADD(TB_Campos,{"A6_NOME"   ,"",STR0012}) //"Banco"
AADD(TB_Campos,{"WK_FOB_RS" ,"",STR0013,'@E 99,999,999,999.99'}) //"Valor R$"

//Campos para o Relatorio 3
AADD(TB_Campos2,{"WK_HAWB"   ,"",STR0001}) //"Processo"
AADD(TB_Campos2,{"WK_INVOICE","",STR0002}) //"Invoices"
AADD(TB_Campos2,{"WK_DT_EMIS","",AVSX3("W9_DT_EMIS",5),""})
If lContabil //FSY - 02/05/2013
   AADD(TB_Campos2,{"Y3_COD"    ,"",STR0004,}) //"Cod. CC"
   AADD(TB_Campos2,{"Y3_DESC"   ,"",STR0005,/*"!!!!!!!!!!!!!!" FSY - 02/05/2013*/}) //"Centro de Custo"
End If
AADD(TB_Campos2,{"W2_MOEDA"  ,"",STR0007}) //"Moeda"
AADD(TB_Campos2,{"WK_FOBMOE" ,"",STR0006,'@E 99,999,999,999.99'}) //"Valor"
AADD(TB_Campos2,{"WK_DT_VEN" ,"",STR0010 }) //"Dt Vencto"
AADD(TB_Campos2,{"WK_CA_DT"  ,"",STR0015}) //"Dt Fechamento"
AADD(TB_Campos2,{"A6_NOME"   ,"",STR0012}) //"Banco"
AADD(TB_Campos2,{"WK_CA_TX"  ,"",STR0016}) //"Taxa"

//Campos para o Browse
AADD(TB_Campos3,{"YT_COD_IMP","",STR0017}) //"Cod Imp"
AADD(TB_Campos3,{"YT_NOME_RE","",STR0018}) //"Importador"
AADD(TB_Campos3,{"W7_FORN"   ,"",STR0019}) //"Cod For" 
If EICLoja()
   AADD(TB_Campos3,{"W7_FORLOJ"   ,"","Loja Forn"}) //"Loja Forn" 
EndIf
AADD(TB_Campos3,{"A2_NREDUZ" ,"",STR0020}) //"Fornecedor"
AADD(TB_Campos3,{"WK_HAWB"   ,"",STR0001}) //"Processo"
AADD(TB_Campos3,{"WK_INVOICE","",STR0002}) //"Invoices"
AADD(TB_Campos3,{"WK_DT_EMIS","",STR0014}) //"Dt Fatura"
If lContabil //FSY - 02/05/2013
   AADD(TB_Campos3,{"Y3_COD"    ,"",STR0004}) //"Cod. CC"
   AADD(TB_Campos3,{"Y3_DESC"   ,"",STR0005,/*"!!!!!!!!!!!!!!" FSY - 02/05/2013 */}) //"Centro de Custo"
End If
AADD(TB_Campos3,{"W2_MOEDA"  ,"",STR0007}) //"Moeda"
AADD(TB_Campos3,{"WK_FOBMOE" ,"",STR0006,'@E 99,999,999,999.99'}) //"Valor"
AADD(TB_Campos3,{"WK_FOB_RS" ,"",STR0013,'@E 99,999,999,999.99'}) //"Valor R$"
AADD(TB_Campos3,{"WK_DT_VEN" ,"",STR0010 }) //"Dt Vencto"
AADD(TB_Campos3,{"WK_CA_DT"  ,"",STR0015}) //"Dt Fechamento"
AADD(TB_Campos3,{"WK_GRUPO"  ,"",STR0008}) //"Grupo"
AADD(TB_Campos3,{"A6_NOME"   ,"",STR0012}) //"Banco"
AADD(TB_Campos3,{"WK_CA_TX"  ,"",STR0016}) //"Taxa"
AADD(TB_Campos3,{"WK_DT_DIG" ,"",STR0021}) //"Digit."

aDados[01]:="Work"
aDados[02]:=""
aDados[03]:=""
aDados[04]:=""
aDados[05]:="G"
aDados[06]:=220
aDados[07]:=""
aDados[08]:=""
aDados[09]:=""
aDados[10]:={ STR0047, 1,STR0048, 1, 2, 1, "",1 } //"Zebrado"###"Importa‡Æo"
aDados[11]:="EICAP151"
aDados[12]:={{|| AP151Quebra() },{|| AP151Rodape() } }

Private cMarca := GetMark(), lInverte := .F.
PRIVATE aHeader[0], aReturn := aDados[10]
// EOS - variavel p/ verificar se existem o tratamento do pgto antecipado.
PRIVATE lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
PRIVATE T_TabObs[21] , T_TabUSD[21], cNomArq
PRIVATE aCampos:={"YT_COD_IMP", "YT_NOME_RE", "Y3_COD", "Y3_DESC", "W7_FORN",;
                  "A2_NREDUZ" ,"W2_MOEDA"   , "A6_COD", "A6_NOME"}
PRIVATE aSemSX3:={{"WK_HAWB"   ,"C",AVSX3("WB_HAWB",3),0},; 
                  {"WK_INVOICE","C",AVSX3("WB_INVOICE",3),0},;
                  {"WK_GRUPO"  ,"C",AVSX3("A2_GRUPO",3),0},;
                  {"WK_DT_VEN" ,"D",08,0},;        
                  {"WK_CA_TX"  ,"N",AVSX3("WB_CA_TX",3),AVSX3("WB_CA_TX",4)},;
                  {"WK_CA_DT"  ,"D",08,0},;
                  {"WK_DT_EMIS","D",08,0},;
                  {"WK_DT_DIG" ,"D",08,0},;
                  {"WK_FOBMOE" ,"N",16,2},;
                  {"WK_FOB_RS" ,"N",20,2},;
                  {"WK_FATURA" ,"C",24,0}}

PRIVATE cCadastro := OemtoAnsi(STR0022) //"Posicao por Fornecedor"

If EICLOJA() .And. (nPos := aScan(aCampos, {|x| x == "W7_FORN" })) > 0
   aAdd(aCampos, Nil)
   aIns(aCampos, nPos + 1)
   aCampos[nPos+1] := "W7_FORLOJ"
EndIf

cNomArq:=E_CriaTrab(,aSemSX3,"Work")

AFILL(T_TabUSD, 0)

If EICLoja()
   IndRegua("Work",cNomArq+TEOrdBagExt(),"YT_COD_IMP+W7_FORN+W7_FORLOJ+W2_MOEDA")
   WorkNTX:=E_Create(,.F.)//APENAS GERA UM NOME PARA O INDICE 2
   IndRegua("Work",WorkNTX+TEOrdBagExt(),"W7_FORN+W7_FORLOJ+W2_MOEDA")
Else
   IndRegua("Work",cNomArq+TEOrdBagExt(),"YT_COD_IMP+W7_FORN+W2_MOEDA")
   WorkNTX:=E_Create(,.F.)//APENAS GERA UM NOME PARA O INDICE 2
   IndRegua("Work",WorkNTX+TEOrdBagExt(),"W7_FORN+W2_MOEDA")
EndIf



SET INDEX TO (cNomArq+TEOrdBagExt()),(WorkNTX+TEOrdBagExt())

Private nTotalRS := 0
PRIVATE cArqF3SYT:="SYT"
PRIVATE cArqF3SY3:="SY3"
PRIVATE cArqF3SA2:="SA2"
PRIVATE cArqF3GRU:="GRU"
PRIVATE cPicImp  :=ALLTRIM(X3Picture("W2_IMPORT"))
PRIVATE cPicCC   :=ALLTRIM(X3Picture("Y3_COD"))
PRIVATE cPicFor  :=ALLTRIM(X3Picture("A2_COD"))
Private aRCampos  //VI
PRIVATE lImpObs := .F.    // EOS - OS 397/02 variavel p/ tratar se deve imprimir
                          // legenda ref. a pgto antecipado                             
cImport := SYT->YT_COD_IMP
cOpcGru := SA2->A2_GRUPO
dDataI  := dDataF := AVCTOD('')
dDataTx := dDataBase
cCusto  := SY3->Y3_COD
nFornec := SA2->A2_COD
cForLoj := SA2->A2_LOJA
R_Campos:={}

DO WHILE .T.
   nValTot := 0
   aValTot :={}
   aValMoe := {}
   cQuebra1:= nQuebra := ''
   nQuebra2:= nQuebra3:= nColtot := nColMoe :=0
   aRodape :={}
   R_Campos:={}
   nOpca   :=0
   nLin    :=1.4
   nColS   :=0.9
   nColG   :=8.0
   
   IF !Pergunte("EIC154",IF(!lEmail,.T.,.F.))
      EXIT 
   ENDIF   
   IF lEmail
      aDados[11]:= SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
   ENDIF
               
   cOpcGru:=mv_par01
   nFornec:=mv_par02
   cForLoj:=mv_par03
   nTipRel:=mv_par04
   cImport:=mv_par05
   cCusto :=mv_par06
   dDataI :=mv_par07
   dDataF :=mv_par08
   dDataTx:=mv_par09
   
   cTit2:= STR0036 + IF(EMPTY(cCusto),STR0037,cCusto)+SPACE(5) //"Centro de Custo.: "###"Todos"
   cTit2+= STR0038 + DTOC(dDataI)+' a '+DTOC(dDataF) //"Periodo.: "
   nOpca   :=0

   IF nTipRel = 1
      aDados[2]:=STR0039 //"Este relat¢rio imprimir  as Entradas no Periodo"
      aDados[09]:=OemToAnsi(STR0040) //"1 - Entradas no Periodo"
      WORK->(DBSETORDER(1))
      aRCampos:= E_CriaRCampos(TB_Campos,"C")
      nColMoe:=6
      nMoeCol:=7
      nColToT:=Len(TB_Campos)//12// FSY - 02/05/2013
   ELSEIF nTipRel = 2
      aDados[2]:=STR0041 //"Este relat¢rio imprimir  os Pagamentos Realizados"
      aDados[09]:=STR0024 //"2 - Pagamentos Realizados"
      IF ! EMPTY(ALLTRIM(cImport))
         SYT->(DBSEEK(xFilial("SYT")+cImport))
      ENDIF
      cTit2:= STR0042 + IF(EMPTY(ALLTRIM(cImport)),STR0037,SYT->YT_NOME_RE)+SPACE(5)+cTit2 //"Importador: "###"Todos"
      WORK->(DBSETORDER(1))
      aRCampos:= E_CriaRCampos(TB_Campos,"C")
      nColMoe:=6
      nMoeCol:=7
      nColToT:=Len(TB_Campos)//12// FSY - 02/05/2013
   ELSEIF nTipRel = 3
      aDados[2]:=STR0043 //"Este relat¢rio imprimir  a Posicao do Fornecedor"
      aDados[09]:=STR0044 //"3 - Posicao do Fornecedor"
      WORK->(DBSETORDER(2))
      aRCampos:= E_CriaRCampos(TB_Campos2,"C")
      nColMoe:=2
      nMoeCol:=7
      nColToT:=Len(TB_Campos2)//8// FSY - 02/05/2013
   ELSE
      aDados[2]:=STR0045 //"Este relat¢rio imprimir  o Relat¢rio Aberto para Fornecedor(es)"
      aDados[09]:=STR0046 //"4 - Relatorio Aberto para Fornecedor(es)"
      WORK->(DBSETORDER(2))
      aRCampos:= E_CriaRCampos(TB_Campos,"C")
      nColMoe:=6
      nMoeCol:=7
      nColToT:=Len(TB_Campos)//12// FSY - 02/05/2013
   ENDIF
   aDados[07]:=cTit2   

   lOK:= .F.

   IF lEmail
      lOK:=AP151_GWork()
      IF lOk 
         E_Report(aDados,aRCampos,,.F.)      
      ENDIF
      EXIT   		   
   ELSE      
      Processa({|lEnd|lOK:=AP151_GWork()})
      IF lOK
         oMainWnd:ReadClientCoords()
         DEFINE MSDIALOG oDlg TITLE aDados[09] ;
                From oMainWnd:nTop+125,oMainWnd:nLeft+5 To ;
                     oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

            nOpca:=0

            Work->(DBGOTOP())
            aPos   := PosDlg(oDlg)
            aPos[3] := ((oDlg:nHeight-30)/2)-25
            oMark:= MsSelect():New("Work",,,TB_Campos3,@lInverte,@cMarca,{aPos[1],aPos[2],aPos[3],aPos[4]})            
            
            aPos[3] += 10
            aPos[4] -= 90
            @ aPos[3],aPos[4] Say   "Total em R$:"      of oDlg Pixel
            aPos[3] -= 3
            aPos[4] += 36
            @ aPos[3],aPos[4] msget nTotalRS Picture AvSX3("WB_FOBMOE",AV_PICTURE) /*var nTotalRS*/  size 52,10 of oDlg Pixel of when .F.
            oMark:oBrowse:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         ACTIVATE MSDIALOG oDlg ON INIT ;
                  (AP151Bar(oDlg,{||nOpca:=1,oDlg:End()},;
                                {||nOpca:=0,oDlg:End()})) //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                   //oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT)//LRL 29/04/04

         IF nOpca = 0
            SETKEY(15,{||.T.})
            SETKEY(16,{||.T.})
            SETKEY(24,{||.T.})
			EXIT
         ENDIF
      ELSE
         Help("", 1, "AVG0000197")//MSGINFO(OemToAnsi(STR0049),STR0050) //"NÆo h  Registros a serem Processados"###"Informação"
         LOOP
      ENDIF
   ENDIF
   Work->(avzap())
ENDDO
E_RESET_AREA
RETURN .T.

*---------------------------*
FUNCTION AP151Verif(nVerif)
*---------------------------*
DO CASE
   CASE nVerif=1
        IF !EMPTY(mv_par05)
           IF !SYT->(DBSEEK(xFilial("SYT")+mv_par05))
              Help("", 1, "AVG0000138")//MsgInfo(OemToAnsi(STR0051),STR0050) //"C¢digo do Importador nÆo cadastrado"###"Informação"
              RETURN .F.
           ENDIF
        ENDIF

   CASE nVerif=2
        IF !EMPTY(mv_par06)
           IF !SY3->(DBSEEK(xFilial("SY3")+mv_par06))
              Help("", 1, "AVG0000198")//MSGINFO(OemToAnsi(STR0052),STR0050) //"Centro de Custo nÆo Cadastrado"###"Informação"
              RETURN .F.
           ENDIF
        ENDIF

   CASE nVerif=3
        IF !EMPTY(mv_par08)
           IF mv_par07 > mv_par08
              Help("", 1, "AVG0000199")//MsgInfo(STR0053,STR0054) //"Data Inicial Maior que Data Final"###"Atenção"
              RETURN .F.
           ENDIF
        ENDIF

   Case nVerif=4
        //ISS - 08/02/11 - Alterada a validação para que a mesma funcione quando o forncedor for preenchido manualmente.
        IF !EMPTY(mv_par02) .AND. !SA2->(DBSEEK(xFilial("SA2")+mv_par02+IIF(EICLoja().and.!Empty(mv_par03),mv_par03,"")))
           Help("", 1, "AVG0000217")//MsgInfo(OemToAnsi(STR0055),STR0050) //"C¢digo do Fornecedor nÆo cadastrado"###"Informação"
           RETURN .F.
        ElseIf Empty(MV_PAR03)
           MV_PAR03 := SA2->A2_LOJA  //ISS - 08/02/11 - "Gatilho manual" para o campo de loja.
        ENDIF

   Case nVerif=5
        IF !EMPTY(mv_par01) .AND. !SX5->(DBSEEK(xFilial("SX5")+"Y7"+mv_par01))
           Help("", 1, "AVG0000218")//MsgInfo(OemToAnsi(STR0056),STR0050) //"Grupo nÆo cadastrado"###"Informação"
           RETURN .F.
        ENDIF

ENDCASE

RETURN .T.


*-----------------------*
FUNCTION AP151_GWork()
*-----------------------*
LOCAL cHawb, cTpLanc, cNumPo, cYsSeek, bYsWhile, bSkip,;
      bDtI_Dig:= {|| IF(!EMPTY(dDataI),(SWB->WB_DT_DIG>=dDataI),.T.)}  ,;
      bDtF_Dig:= {|| IF(!EMPTY(dDataF),(SWB->WB_DT_DIG<=dDataF),.T.)}  ,;
      bDtI_Ven:= {|| IF(!EMPTY(dDataI),(SWB->WB_DT_VEN>=dDataI),.T.)}  ,;
      bDtF_Ven:= {|| IF(!EMPTY(dDataF),(SWB->WB_DT_VEN<=dDataF),.T.)}  ,;
      bDtI_Pag:= {|| IF(!EMPTY(dDataI),(SWB->WB_CA_DT>=dDataI),.T.)}   ,;
      bDtF_Pag:= {|| IF(!EMPTY(dDataF),(SWB->WB_CA_DT<=dDataF),.T.)}

Private nTotal:= 0, lLctoDi := .T.

// EOS - Atribui codeblock diferenciado, caso tenha os cpos ref. a adiantamento
IF lCposAdto  
   bSkip := {|| SWB->(DBEVAL({||IncProc(STR0057+SWB->WB_HAWB)},,{||SWB->WB_FILIAL==xFilial("SWB") .AND. SWB->WB_HAWB==cHawb .AND. SWB->WB_PO_DI==cTpLanc},,,.T.))}
ELSE
   bSkip := {|| SWB->(DBEVAL({||IncProc(STR0057+SWB->WB_HAWB)},,{||SWB->WB_FILIAL==xFilial("SWB") .AND. SWB->WB_HAWB==cHawb},,,.T.))}
ENDIF   
SW9->(DBSETORDER(3))
SWB->(DBSETORDER(1))
SWB->(DBSEEK(xFilial("SWB")))
IF !lEmail
   ProcRegua(SWB->(LASTREC()))
ENDIF
DO WHILE !SWB->(EOF()) .AND. SWB->WB_FILIAL==xFilial("SWB")
   cHawb   := SWB->WB_HAWB
   lLctoDi := .T.
   cYSTipo :="I"           
   bWhile:={||SYS->YS_FILIAL ==xFilial("SYS") .AND.;
              SYS->YS_TPMODU =="I"            .AND.;
              SYS->YS_TIPO   ==cYSTipo        .AND.;
              SYS->YS_HAWB   ==SWB->WB_HAWB   .AND.;
              (SYS->YS_FORN   ==SWB->WB_FORN   .AND. IIF(EICLoja(),SYS->YS_FORLOJ ==SWB->WB_LOJA, .T.)) .AND. ;
              SYS->YS_MOEDA  ==SWB->WB_MOEDA  .AND.;
              SYS->YS_INVOICE==SWB->WB_INVOICE}                          

   cSYSChave:=xFilial("SYS")+"II"+SWB->WB_HAWB+SWB->WB_FORN+IIF(EICLoja(),SWB->WB_LOJA,"")+SWB->WB_MOEDA+SWB->WB_INVOICE
   
   IF lCposAdto                  
      cTpLanc := SWB->WB_PO_DI
      IF (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C" )	// GCC - 28/08/2013
         lLctoDi  := .F.
         cNumPo   := If (SWB->WB_PO_DI == "A", SWB->WB_HAWB, "")
         cYSTipo  := "P"
         
         bWhile:={||SYS->YS_FILIAL == xFilial("SYS") .And.;
                    SYS->YS_TPMODU == "I"            .And.;
                    SYS->YS_TIPO   == cYSTipo        .And.;
                    SYS->YS_HAWB   == SWB->WB_HAWB   .And.;
                    (SYS->YS_FORN  == SWB->WB_FORN   .And. IIF(EICLoja(),SYS->YS_FORLOJ ==SWB->WB_LOJA, .T.)) .And. ;
                    SYS->YS_MOEDA  == SWB->WB_MOEDA }           
                    
         cSYSChave:=xFilial("SYS")+"IP"+SWB->WB_HAWB+SWB->WB_FORN+IIF(EICLoja(),SWB->WB_LOJA,"")+SWB->WB_MOEDA

      ENDIF
   ENDIF            
   
   IF !lEmail
      IncProc(STR0057+SWB->WB_HAWB) //"Processando Processo: "
   ENDIF

   IF lLctoDi   
      IF lCposAdto .AND. Left(SWB->WB_TIPOREG,1) == "P" .AND. !EMPTY(SWB->WB_NUMPO)                                
         // EOS - Despreza os registros de adiantamentos das parcelas de cambio de DI
         SWB->(dbSkip())//ASR 25/08/2005 - EVAL(bSkip)
         LOOP
      ENDIF
      
      IF SWB->WB_FOBMOE <= 0
         SWB->(dbSkip())
         LOOP
      ENDIF

      IF !SW6->(DBSEEK(xFilial("SW6")+SWB->WB_HAWB))
         IF !lEmail
            Help("", 1, "AVG0000200",,(SWB->WB_HAWB)+ "nao encontrado nas Declaracoes", 1,10)//MsgInfo(STR0058+ SWB->WB_HAWB + OemToAnsi(STR0059),STR0050) //"Processo: "###" nÆo encontrado nas Declara‡äes"###"Informação"
         ENDIF
         EVAL(bSkip)
         LOOP
      ENDIF

      IF !SW7->(DBSEEK(xFilial("SW7")+SWB->WB_HAWB))
         IF !lEmail
            Help("", 1, "AVG0000200",,(SWB->WB_HAWB)+ "nao encontrado nos Itens Declaracoes", 1,10)//MsgInfo(STR0058+ SWB->WB_HAWB + OemToAnsi(STR0060),STR0050) //"Processo: "###" nÆo encontrado nos Itens Declara‡äes"###"Informação"
         ENDIF
         EVAL(bSkip)
         LOOP
      ENDIF
      SW9->(DBSEEK(xFilial("SW9")+cHawb))
      cNumPO   := SW7->W7_PO_NUM
   ENDIF

   IF !EMPTY(nFornec) .And. IIF(EICLoja(),!Empty(cForLoj),.T.)
      IF (RTRIM(nFornec) # RTRIM(SWB->WB_FORN)) .Or. IIF(EICLoja(),RTRIM(cForLoj) # RTRIM(SWB->WB_LOJA),.T.) //LRS - 04/05/2015 - Correção da Validação do Fornecedor/Forn. Loja.
         //EVAL(bSkip) 
         SWB->(DbSkip())//ASK 26/09/2007 - Alterado para buscar todas as invoices
         LOOP
      ENDIF
   ENDIF

   IF !SA2->(DBSEEK(xFilial()+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")))
      IF !lEmail //MCF - 24/05/2016
         Help("", 1, "AVG0000215",,(SWB->WB_FORN)+IIF(EICLoja()," - "+SWB->WB_LOJA,"")+ " não cadastrado nos Fornecedores", 1,12)//MsgInfo(STR0061+SW7->W7_FORN+OemToAnsi(STR0062),STR0050) //"Forncedor: "###" nÆo Cadastrado nos Fornecedores"###"Informação"
      ENDIF
      EVAL(bSkip)
      LOOP
   ENDIF

   IF !EMPTY(cOpcGru)
      IF ALLTRIM(SA2->A2_GRUPO) # ALLTRIM(cOpcGru)
         EVAL(bSkip)
         LOOP
      ENDIF
   ENDIF

   IF !SW2->(DBSEEK(xFilial("SW2")+cNumPo))
      IF !lEmail
         Help("", 1, "AVG0000216",,(cNumPo)+ "nao encontrado nos Pedidos", 1,08)//MsgInfo(STR0063+ SW7->W7_PO_NUM+OemToAnsi(STR0064),STR0050) //"Pedido: "###" nÆo encontrado nos Pedidos"###"Informação"
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

   IF nTipRel = 1
      IF ! EVAL(bDtI_Dig) .OR. ! EVAL(bDtF_Dig)
         SWB->(DBSKIP())
         LOOP
      ENDIF
   ELSEIF nTipRel = 2
      IF EMPTY(SWB->WB_CA_DT)
         SWB->(DBSKIP())
         LOOP
      ELSE
         IF ! EVAL(bDtI_Pag) .OR. ! EVAL(bDtF_Pag)
            SWB->(DBSKIP())
            LOOP
         ENDIF
      ENDIF
   ELSEIF nTipRel = 3
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
   ELSE
      IF ! EMPTY(SWB->WB_CA_DT)
         SWB->(DBSKIP())
         LOOP
      ELSE
         IF ! EVAL(bDtI_Ven) .OR. ! EVAL(bDtF_Ven)
            SWB->(DBSKIP())
            LOOP
         ENDIF
      ENDIF
   ENDIF

   SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))
   SA6->(DBSEEK(xFilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA))

   If lContabil//JVR - 15/07/2009 - Verificação de integração com contabil.
      If SYS->(DBSEEK(cSYSChave))
         DO WHILE !SYS->(EOF()) .AND. EVAL(bWhile)
            IF !EMPTY(cCusto)
               IF SYS->YS_CC # cCusto
                  SYS->(dbSkip())
                  LOOP
               ENDIF  
            ENDIF
            AppendWork(SYS->YS_CC, SYS->YS_PERC)
            SYS->(DBSKIP())
         ENDDO
      Else
         AppendWork("", 1)  
      EndIf
   Else
      AppendWork("", 1)
   EndIf
   SWB->(DBSKIP())
ENDDO

RETURN IF(nTotal > 0,.T.,.F.)
                                      
/*
Função..: AppendWork
Autor...: Jean Victor Rocha - JVR
Data....: 15/07/2009
Objetivo: Gravar a work de acordo com o contabil.
Parâmetros: cCc, nPerc
Retorno:
*/
*------------------------------------*
Static Function AppendWork(cCC, nPerc)
*------------------------------------*

Work->(DBAPPEND())
Work->YT_COD_IMP := SW2->W2_IMPORT
Work->YT_NOME_RE := SYT->YT_NOME_RE
// EOS - Valida se preve pgto antecipado, tratando cpos da Work     
IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 28/08/2013
   Work->WK_HAWB   := "* " + SWB->WB_HAWB
   Work->WK_FOBMOE := SWB->WB_PGTANT * nPerc//SYS->YS_PERC
   Work->WK_FOB_RS := SWB->WB_PGTANT * /*SYS->YS_PERC*/ nPerc * SWB->WB_CA_TX
   lImpObs := .T.
ELSE
   Work->WK_HAWB := SWB->WB_HAWB 
   Work->WK_FOBMOE  := SWB->WB_FOBMOE * nPerc//SYS->YS_PERC
   Work->WK_FOB_RS  := SWB->WB_FOBMOE * nPerc /*SYS->YS_PERC*/ * SWB->WB_CA_TX
ENDIF
Work->WK_INVOICE := SWB->WB_INVOICE
Work->Y3_COD     := cCC//SYS->YS_CC
Work->Y3_DESC    := BuscaCCusto (cCC /*SYS->YS_CC*/)
Work->WK_GRUPO   := SA2->A2_GRUPO
Work->WK_DT_EMIS := IF(lLctoDi,SW9->W9_DT_EMIS,SW2->W2_PO_DT)
Work->WK_DT_VEN  := SWB->WB_DT_VEN
Work->W7_FORN    := SA2->A2_COD            //SW7->W7_FORN    // GFP - 13/11/2012
If EICLoja()  //.And. cForLoj == SW7->W7_FORLOJ  // GFP - 13/11/2012
   Work->W7_FORLOJ  := SA2->A2_LOJA        //SW7->W7_FORLOJ  // GFP - 13/11/2012
EndIf
Work->A2_NREDUZ  := SA2->A2_NREDUZ
Work->W2_MOEDA   := SWB->WB_MOEDA //SW2->W2_MOEDA  // TLM 26/03/2008 Alteração caso as invoices possuam moedas diferentes.
Work->A6_COD     := SA6->A6_COD
Work->A6_NOME    := SA6->A6_NOME
Work->WK_CA_DT   := SWB->WB_CA_DT
Work->WK_CA_TX   := SWB->WB_CA_TX
Work->WK_DT_DIG  := SWB->WB_DT_DIG
IF nTipRel = 4
   Work->WK_CA_TX   := BuscaTaxa(SW2->W2_MOEDA, dDataTx)
   Work->WK_FOB_RS  := Work->WK_FOBMOE * nPerc /*SYS->YS_PERC*/ * Work->WK_CA_TX
ENDIF
nTotalRS += Work->WK_FOB_RS
nTotal ++

Return Nil

*--------------------------------------*
FUNCTION AP151Quebra()
*--------------------------------------*
Local J //LRL 23/01/04
IF nTipRel = 1 .OR. nTipRel = 2 .OR. nTipRel = 4
   IF cQuebra1 # Work->YT_COD_IMP   
      IF nValTot # 0 .or. !Empty(aValMoe)
         AP151CabRel()
         Linha++
         @ Linha, T_Len[1,2] PSAY STR0066 //"** Total do Fornecedor"
         
         @ Linha, (T_Len[nColTot,2]-1) PSAY TRANS(nValTot,'@E 999,999,999,999.99')
		 Linha+=1
		 FOR J:=1 TO LEN(AVALMOE)
		    cCampo:= TRANS(aValMoe[J,2],'@E 999,999,999,999.99')+' (' + AllTrim(aValMoe[J,1]) + ')'
			@ Linha, (T_Len[nColMoe,2]-1) PSAY cCampo
			Linha+=1
	     NEXT   
		 
		 Linha+=1
		 
	     aValTot:={}		
         nValTot:=0
         aValMoe:={}
         AP151Rodape()
         Linha+=1
      ENDIF
      IF !EMPTY(cQuebra1)
         Linha+=1
      ENDIF
      AP151CabRel()
      Linha++
      @ Linha, T_Len[1,2] PSAY STR0042+Work->YT_COD_IMP+'-'+Work->YT_NOME_RE //"Importador: "
      Linha+=2
      AP151CabRel()
      Linha++
      @ Linha, T_Len[1,2] PSAY STR0067+Work->W7_FORN+IIF(EICLoja()," - "+Work->W7_FORLOJ,"")+'/'+Work->A2_NREDUZ //"Fornecedor: "    //TRP-02/06/08-Inclusão do campo Código do Fornecedor
      Linha+=1
      aRodape:={}
      nValTot:=0
      aValMoe:={}
	  aValTot:={}
      cQuebra1:=Work->YT_COD_IMP
      nQuebra2:=Work->W7_FORN
      If EICLoja()
         nQuebra3:= Work->W7_FORLOJ
      EndIf
   ENDIF

   IF nQuebra2 # Work->W7_FORN .And. IIF(EICLoja(),nQuebra3 # Work->W7_FORLOJ,.T.)
      IF nValTot # 0 .or. !Empty(aValMoe)
         AP151CabRel()
         Linha++
         @ Linha, T_Len[1,2] PSAY STR0066 //"** Total do Fornecedor"
         
         @ Linha, (T_Len[nColTot,2]-1) PSAY TRANS(nValTot,'@E 999,999,999,999.99')
		 Linha+=1
		 FOR J:=1 TO LEN(AVALMOE)
		    cCampo:= TRANS(aValMoe[J,2],'@E 999,999,999,999.99')+' (' + AllTrim(aValMoe[J,1]) + ')'
			@ Linha, (T_Len[nColMoe,2]-1) PSAY cCampo
			Linha+=1
	     NEXT   
         Linha+=1
      ENDIF
      Linha+=2
      AP151CabRel()
      Linha++
      @ Linha, T_Len[1,2] PSAY STR0067+Work->W7_FORN+IIF(EICLoja()," - "+Work->W7_FORLOJ,"")+'/'+Work->A2_NREDUZ //"Fornecedor: "    //TRP-02/06/08-Inclusão do campo Código do Fornecedor
      Linha+=1
      nValTot:=0
      aValMoe:={}
	  aValTot:={}
      nQuebra2:=Work->W7_FORN
      If EICLoja()
         nQuebra3:= Work->W7_FORLOJ
      EndIf
   ENDIF

   nAux:=ASCAN(aRodape,{|x| x[1]==Work->W2_MOEDA})
   IF nAux=0
      AADD(aRodape,{Work->W2_MOEDA,Work->WK_FOBMOE,Work->WK_FOB_RS})
   ELSE
      aRodape[nAux,2]+=Work->WK_FOBMOE
      aRodape[nAux,3]+=Work->WK_FOB_RS
   ENDIF

   nValTot+=Work->WK_FOB_RS
	  	  
   nAsc:=ASCAN(aValMoe,{|x| x[1]==Work->W2_MOEDA})	  
   IF nAsc=0
      AADD(aValMoe,{Work->W2_MOEDA,Work->WK_FOBMOE})
   ELSE
      aValMoe[nAsc,2]+=Work->WK_FOBMOE
   ENDIF
   
ELSE

   nAux:=ASCAN(aRodape,{|x| x[1]==Work->W2_MOEDA})
   IF nAux=0
      AADD(aRodape,{Work->W2_MOEDA,Work->WK_FOBMOE})
   ELSE
      aRodape[nAux,2]+=Work->WK_FOBMOE
   ENDIF
   
   IF nQuebra # Work->W7_FORN  .And. IIF(EICLoja(),nQuebra3 # Work->W7_FORLOJ,.T.)    
      IF !Empty(aValTot)
         Linha+=1	  
         AP151CabRel()
         Linha++ 
         @ Linha, T_Len[1,2] PSAY '** Total do Fornecedor'		 
		 For J:=1 TO LEN(aValTot)
            @ Linha, (T_Len[nMoeCol,2]+1)PSAY aValTot[J,1]
            @ Linha, (T_Len[nColTot,2]-1) PSAY TRANS(aValTot[J,2],'@E 999,999,999,999.99')
            Linha+=1
		 Next   
		 aValTot:={}   
      ENDIF
      	  
      IF !EMPTY(nQuebra) .And. IIF(EICLoja(),!Empty(nQuebra3),.T.) 
         Linha+=1
      ENDIF
	  
      AP151CabRel()
      Linha++ 
      @ Linha, T_Len[1,2] PSAY 'Fornecedor: '+Work->W7_FORN+IIF(EICLoja()," - "+Work->W7_FORLOJ,"")+'/'+Work->A2_NREDUZ    //TRP-02/06/08-Inclusão do campo Código do Fornecedor
      Linha+=1
      nQuebra :=Work->W7_FORN
      If EICLoja()
         nQuebra3:=Work->W7_FORLOJ 
      EndIf
	  	  
	  nAsc1:=ASCAN(aValTot,{|x| x[1]==Work->W2_MOEDA})
	  IF nAsc1==0
         AADD(aValTot,{Work->W2_MOEDA,Work->WK_FOBMOE})
	  ELSE
         aValTot[nAsc1,2]+=Work->WK_FOBMOE
      ENDIF
            
   ELSE
      nScan := Ascan(aValTot, {|x| x[1] == Work->W2_MOEDA})
	  IF nScan == 0
	     AADD(aValTot,{Work->W2_MOEDA,Work->WK_FOBMOE})
	  Else
	     aValTot[nScan,2]+= Work->WK_FOBMOE 	
	  ENDIF
	  
	  nQuebra:=Work->W7_FORN 
	  If EICLoja()
         nQuebra3:=Work->W7_FORLOJ 
      EndIf
   ENDIF    
ENDIF
RETURN .T.

*-----------------------*
FUNCTION AP151Rodape()
*-----------------------*
LOCAL nGeral:=0 , J , I
IF nTipRel = 1 .OR. nTipRel = 2 .OR. nTipRel = 4
   IF nValTot # 0 .or. !Empty(aValMoe)
      Linha+=1
      AP151CabRel()
      Linha++
      @ Linha, T_Len[1,2]  PSAY STR0066 //"** Total do Fornecedor"
      
      @ Linha, (T_Len[nColTot,2]-1) PSAY TRANS(nValTot,'@E 999,999,999,999.99')
	  Linha+=1
	  FOR J:=1 TO LEN(AVALMOE)
	     cCampo:= TRANS(aValMoe[J,2],'@E 999,999,999,999.99')+' (' + AllTrim(aValMoe[J,1]) + ')'
		 @ Linha, (T_Len[nColMoe,2]-1) PSAY cCampo
		 Linha+=1
	  NEXT   

   	  Linha+=1
   ENDIF
   
   Linha+=2
   FOR I=1 TO LEN(aRodape)
       AP151CabRel()
       Linha++
       IF I = 1
          @ Linha, T_Len[1,2] PSAY STR0068 //"** Total Geral do Importador"
       ENDIF
       @ Linha , (T_Len[nColMoe,2]-1) PSAY TRANS(aRodape[I,2],'@E 999,999,999,999.99')+' (' + AllTrim(aRodape[I,1]) + ')'
       @ Linha , (T_Len[nColTot,2]-1) PSAY TRANS(aRodape[I,3],'@E 999,999,999,999.99')
       nGeral+=aRodape[I,3]
       //@ Linha , (T_Len[nMoeCol,2]+5) PSAY aRodape[I,1]
       Linha+=1
   NEXT
   AP151CabRel()
   Linha++
   @ Linha , (T_Len[nColTot,2]-1) PSAY '------------------'
   Linha+=1
   AP151CabRel()
   Linha++
   @ Linha , (T_Len[nColTot,2]-1) PSAY TRANS(nGeral,'@E 999,999,999,999.99')
   Linha+=1
   AP151CabRel()
   Linha++
   @ Linha, 1 PSAY REPL('-',230)

ELSE
   IF nValTot # 0 .or. !Empty(aValTot)
      Linha+=1
      AP151CabRel()
      Linha++
      @ Linha, T_Len[1,2]  PSAY STR0066 //"** Total do Fornecedor"            	  
	  FOR J:=1 TO LEN(aValTot)
	     @ Linha, (T_Len[nMoeCol,2]+1)PSAY aValTot[J,1]
         @ Linha, (T_Len[nColTot,2]-1) PSAY TRANS(aValTot[J,2],'@E 999,999,999,999.99')	     
		 Linha+=1
	  NEXT      
   ENDIF
   Linha+=2
   FOR I=1 TO LEN(aRodape)
       AP151CabRel()
       Linha++
       IF I = 1
          @ Linha, T_Len[1,2] PSAY STR0069 //"** Total Geral"
       ENDIF
       @ Linha , (T_Len[nColTot,2]-1) PSAY TRANS(aRodape[I,2],'@E 999,999,999,999.99')
       @ Linha , (T_Len[nMoeCol,2]+2) PSAY aRodape[I,1]
       Linha+=1
   NEXT
ENDIF
IF lImpObs
   Linha++
   @ Linha, T_Len[1,2] PSAY STR0076  
ENDIF
RETURN .T.

*-----------------------*
FUNCTION AP151CabRel()
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

*----------------------------------------------------------------------*
FUNCTION AP151Bar(oDlg,bOk,bCancel)
*----------------------------------------------------------------------*
LOCAL oBar, bSet15, bSet24, lOk
LOCAL lVolta:=.F., Ind, I
LOCAL bImprimir := { || cQuebra1:='',nQuebra:='',nQuebra2:='',nQuebra3:='',nValTot:=0,nValMoe:=0,E_Report(aDados,aRCampos)} //MCF - 21/07/2015
LOCAL aButtons := {} //MCF - 21/07/2015

AAdd(aButtons, {"EDIT", bImprimir , STR0081, STR0081}) //MCF - 21/07/2015

RETURN EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
