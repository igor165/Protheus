#INCLUDE "EDCRU150.ch"
#INCLUDE "AVERAGE.CH"            

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define NUMLINAN   30
#define NUMLINDI   19
#define TAMDESC    40
#define TAMDESCEXP 60

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função ³EDCRU150.PRW  ³ Autor  ³Thomaz Augusto Netto ³ Data ³26/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Impressao do RUD - Anexo ao Rel. de Comprovacao de Drawback ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAEDC - Drawback                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alteração..: Alessandro J. Porta (AJP)
Data/Hora..: 27/06/2007
Objetivo...: Ajuste para MultiFiliais

*/
*---------------------------*
Function EDCRU150()
*---------------------------*
Local nOldArea := Alias(), aOrd := SaveOrd("ED0")

//Private lEDCDIE:=EasyGParam("MV_EDCDIE",,.F.) - NOPADO POR AOM - 04/11/10
Private cFilSB1 := xFilial("SB1"), cFilED2:= xFilial("ED2"), cFilED1:= xFilial("ED1"),cFilED8:=XFILIAL("ED8")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private lRet, cArqRpt, cTitRpt, cSeqRel:="", aHeader[0]
//AJP 27/06/2007
Private lMultiFil  := VerSenha(115)  ;
                      .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                      .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                      .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                      .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0

//AJP 25/06/2007
Private aFil := IIF(lMultiFil,AvgSelectFil(.F.,,"ED0"),{xFilial("ED0")})
// **
Private cFilED9:= xFilial("ED9")//AWR - 16/04/2009
Private cLastFlag := ""  //GFP - 27/10/2011 - Flag do tipo de Registro presente no Relatorio.
Private lTemED9Cpos:=ED9->(FieldPOs("ED9_VAL_SE")) # 0 .AND. ED9->(FieldPOs("ED9_VALCOM")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_VALORI")) # 0 .AND. ED9->(FieldPOs("ED9_UMNCM" )) # 0 .AND.;
                     ED9->(FieldPOs("ED9_QTDNCM")) # 0 .AND. ED9->(FieldPOs("ED9_TX_USS")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DTAVRB")) # 0 .AND. ED9->(FieldPOs("ED9_ISENTO")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_SALISE")) # 0 .AND. ED9->(FieldPOs("ED9_FASEDR")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DT_INT")) # 0 .AND. SIX->(dbSeek("ED9"+"4"))//AWR - 16/04/2009

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif

If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

// criar todos os campos como caracter
Private aArqs, cNomDbfC := "EDCRUC"
Private aCamposC := {{"WK_SEQREL ","C", 08,0},;
                     {"WK_PED    ","C", 13,0},;
                     {"WK_AC     ","C", 13,0},;
                     {"WK_EMPRESA","C", 25,0},;
                     {"WK_ENDERE ","C", 55,0},;
                     {"WK_ANETEX ","C", 03,0},;
                     {"WK_ANETIM ","C", 03,0},;
                     {"WK_CGC    ","C", 18,0}}
PRivate cNomDbfD := "EDCRUD"
Private aCamposD := {{"WK_SEQREL   ","C", 08,0},;
                     {"WK_PED      ","C", 13,0},;
                     {"WKD_FLAG    ","C", 01,0},;
                     {"WKD_DI_ADI  ","C", 20,0},;
                     {"WKD_NCM     ","C", 15,0},;
                     {"WKD_DTREGI  ","C", 10,0},;
                     {"WKD_DTDESE  ","C", 10,0},;  // GFP - 18/05/2012
                     {"WKD_PARTNU  ","C", 20,0},;
                     {"WKD_DESCR   ","C", 60,0},;
                     {"WKD_PESO    ","C", 20,0},;
                     {"WKD_QTDE    ","C", 20,0},;
                     {"WKD_VAL_F   ","C", 20,0},;
                     {"WKD_LOCAL   ","C", 50,0},;
                     {"WKD_TOT_P   ","C", 20,0},;
                     {"WKD_TOT_Q   ","C", 20,0},;
                     {"WKD_TOT_F   ","C", 20,0},;
                     {"WKD_UNID    ","C", 03,0},;
                     {"WKD_ANEXO   ","C", 03,0},;
                     {"WKD_DIADOR  ","C", 16,0},;  // GFP - 22/03/2012
                     {"WKD_VALEMB  ","C", 15,0},; //Valor no Local de embarque
                     {"WKD_TOT_UN  ","C",100,0},;
                     {"WKD_NF      ","C", 15,0},;
                     {"WKD_DTNF    ","C", 10,0},;
                     {"WKD_SERIE   ","C", 03,0},;    // GFP - 21/10/2011 - Adequação para Compras Nacionais
                     {"WKD_MOD_NF  ","C", 08,0},;     // e Vendas para Exportadores.
                     {"WKD_PEDCOM  ","C", 15,0},;
                     {"WKD_CGC     ","C", 14,0},;
                     {"WKD_QTD_AD  ","C", 02,0},;    // Qtd. - Unidade de medida adotada na NF
                     {"WKD_QTD_ES  ","C", 02,0},;    // Qtd. - Unidade de medida estatistica
                     {"WKD_VAL_R   ","C", 17,0},;    // Valor em R$
                     {"WKD_VAL_D   ","C", 16,0}}     // Valor em US$ 

//Campos utilizados para Informar total por unidade de medida
Aadd(aCamposD,{"WKD_TUNI01","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI02","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI03","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI04","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI05","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI06","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI07","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI08","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI09","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI10","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI11","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI12","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI13","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI14","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI15","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI16","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI17","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI18","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI19","C", 20,0})
Aadd(aCamposD,{"WKD_TUNI20","C", 20,0})
Aadd(aCamposD,{"WKD_UNI01 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI02 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI03 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI04 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI05 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI06 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI07 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI08 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI09 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI10 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI11 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI12 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI13 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI14 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI15 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI16 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI17 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI18 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI19 ","C", 05,0})
Aadd(aCamposD,{"WKD_UNI20 ","C", 05,0})
Aadd(aCamposD,{"WKD_MOEDA ","C", 03,0}) //11/09/02
Aadd(aCamposD,{"WKD_FR_USS","C", 15,0})
Aadd(aCamposD,{"WKD_SEGURO","C", 15,0})
Aadd(aCamposD,{"WKD_ASSRU1","C", 30,0})
Aadd(aCamposD,{"WKD_ASSRU2","C", 30,0})
Aadd(aCamposD,{"WKD_TOTFRT","C", 15,0})
Aadd(aCamposD,{"WKD_TOTSEG","C", 15,0})
Aadd(aCamposD,{"WK_LOCALDT","C", 50,0})
Aadd(aCamposD,{"WKD_TVEM01","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM02","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM03","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM04","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM05","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM06","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM07","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM08","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM09","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM10","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM11","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM12","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM13","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM14","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM15","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM16","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM17","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM18","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM19","C", 15,0})
Aadd(aCamposD,{"WKD_TVEM20","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM01","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM02","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM03","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM04","C", 15,0})
Aadd(aCamposD,{"WKD_MVEM05","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM06","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM07","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM08","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM09","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM10","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM11","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM12","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM13","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM14","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM15","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM16","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM17","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM18","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM19","C", 05,0})
Aadd(aCamposD,{"WKD_MVEM20","C", 05,0})

IF Select("WorkId") > 0
   cArqRpt := WorkId->EEA_ARQUIV
   cTitRpt := AllTrim(WorkId->EEA_TITULO)
Else
   cArqRpt := "EDCRU150.rpt"
   cTitRpt := STR0001 //"Emissao do Anexo de Comprovacao de Drawback"
Endif

aArqs  := {}
AADD(aArqs,{cNomDbfC,aCamposC,"CAB","WK_SEQREL+WK_PED"})
AADD(aArqs,{cNomDbfD,aCamposD,"DET","WK_SEQREL+WK_PED"})

dbSelectArea(nOldArea)

RestOrd(aOrd)
aMarcados := {}
aRotina := {{ STR0002 ,"AxPesqui"  , 0 , 1},; //"Pesquisar"
            { STR0003 ,"Eval({|| RU150Rel() })", 0 , 0}}  //"Emissao" 

cCadastro := STR0004 //"Selecao do Ato Concessorio"
cMarca := GetMark()
lInverte := .F.
oMainWnd:ReadClientCoords()

DbSelectArea("ED0")
ED0->(DbSetFilter({||!EMPTY(ED0->ED0_AC) .AND. EMPTY(ED0->ED0_DT_ENC)},;  // .AND. ED0->ED0_MODAL = "1"
"!EMPTY(ED0->ED0_AC) .AND. EMPTY(ED0->ED0_DT_ENC)")) // .AND. ED0->ED0_MODAL = '1'

ED0->(MarkBrow("ED0","ED0_OK",,,,cMarca,,,,,"U_RU150Marca()")) //EMISSAO

Set Filter To

SW6->(DBSETORDER(1))
SA5->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW8->(DBSETORDER(1))
EE9->(DBSETORDER(1))
EEC->(DBSETORDER(1))
ED1->(DBSETORDER(1))
ED2->(DBSETORDER(1))

Return .F.

*------------------------------------*
User Function RU150Marca()
*------------------------------------*
Local nPos:=aScan(aMarcados,ED0->(RecNo()))
Local cFilSW8:= xFilial("SW8")
Local cFilEE9:= xFilial("EE9")
Local nFilInd:=0
Local lAchou := .F.

SW8->(DBSETORDER(5))
EE9->(DBSETORDER(10))

// AJP 27/06/2007
If !lMultiFil
   //IF lEDCDIE - NOPADO POR AOM - 04/11/10
      ED8->(DBSETORDER(3))
      IF !SW8->(DbSeek(cFilSw8+ED0->ED0_AC))  .And. !EE9->(DbSeek(cFilEe9+ED0->ED0_AC))
         IF !ED8->(DBSEEK(cFilED8+ED0->ED0_AC))
            Help(" ",1,"AVG0005205",,Alltrim(ED0->ED0_AC),2,20) //Msginfo(STR0012+Alltrim(ED0->ED0_AC), STR0006)    //"Nao existem Registros para a Comprovacao do Ato Concessorio "###"Mensagem"
            Return .F.
         Endif
      ENDIF
   //ELSE
      /*IF !SW8->(DbSeek(cFilSw8+ED0->ED0_AC))  .And. !EE9->(DbSeek(cFilEe9+ED0->ED0_AC))
         Help(" ",1,"AVG0005205",,Alltrim(ED0->ED0_AC),2,20) //Msginfo(STR0012+Alltrim(ED0->ED0_AC), STR0006)    //"Nao existem Registros para a Comprovacao do Ato Concessorio "###"Mensagem"
         Return .F.
      Endif*/
   //ENDIF            
Else
   //IF lEDCDIE - NOPADO POR AOM - 04/11/10
      ED8->(DBSETORDER(3))
      For nFilInd:=1 to Len(aFil)
         IF SW8->(DbSeek(aFil[nFilInd]+ED0->ED0_AC))  .OR. EE9->(DbSeek(aFil[nFilInd]+ED0->ED0_AC))
            lAchou := .T.
         ElseIf ED8->(DBSEEK(cFilED8+ED0->ED0_AC))
            lAchou := .T.
         EndIf
      Next    
      If !lAchou   
         Help(" ",1,"AVG0005205",,Alltrim(ED0->ED0_AC),2,20) //Msginfo(STR0012+Alltrim(ED0->ED0_AC), STR0006)    //"Nao existem Registros para a Comprovacao do Ato Concessorio "###"Mensagem"
         Return .F.
      ENDIF
   /*ELSE
      For nFilInd :=1 to Len(aFil)
         IF SW8->(DbSeek(aFil[nFilInd]+ED0->ED0_AC))  .OR. EE9->(DbSeek(aFil[nFilInd]+ED0->ED0_AC))
            lAchou := .T.
         EndIf
      Next
      If !lAchou
         Help(" ",1,"AVG0005205",,Alltrim(ED0->ED0_AC),2,20) //Msginfo(STR0012+Alltrim(ED0->ED0_AC), STR0006)    //"Nao existem Registros para a Comprovacao do Ato Concessorio "###"Mensagem"
         Return .F.
      ENDIF
   EndIf*/
EndIf

If RecLock("ED0",.F.)
   If ED0->ED0_OK == cMarca
      ED0->ED0_OK := "  "
      If nPos > 0
         aDel(aMarcados,nPos)
         aSize(aMarcados,Len(aMarcados)-1)
      Endif
   Else
      ED0->ED0_OK := cMarca
      If nPos = 0
         aAdd(aMarcados,ED0->(Recno()))
      Endif
   Endif
   ED0->(MSUNLOCK())
Endif

Return .T.

*------------------------*
Function RU150Rel()
*------------------------*
Private oFont2
Private dData
Private lCabImp, LCabExp
Private nMarcados:=Len(aMarcados)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conta os registros validos para impressao.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nMarcados == 0
   Help(" ",1,"AVG0005204") //MsgInfo(STR0007, STR0008) //"Não existem registros marcados para a impressão !"###"Atenção"
ELSE
   dbSelectArea("ED0")
   nMarcados:=1
   ED0->(dbGoTo(aMarcados[nMarcados]))

   cSEQREL :=GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()
   aRetCrw := CrwNewFile(aArqs)
  
   Ru150Tela()

   If lRet  .And.  CAB->(EasyRecCount()) > 0
      CAB->(DBGOTOP())
      lRet := CrwPreview(aRetCrw,cArqRpt,cTitRpt,cSeqRel)
   Else
      CrwCloseFile(aRetCrw,.T.) // Fecha e apaga os arquivos temporarios do Crystal...
      RecLock("ED0",.F.)
      ED0->ED0_OK  := "  "  //Pedido Drawback Desmarcado
      ED0->(MsUnLock())
      If lRet
         Help(" ",1,"AVG0005206") //Msginfo(STR0005,STR0011)//"Nao há Registros a serem Impressos!"###"Informacao"
      Endif
   Endif 
Endif

aMarcados:={}
Return(NIL)

*-----------------------------*
STATIC FUNCTION RU150GRAVA()                         
*----------------------------*
Local nValFob := 0, ni:=0, nMarcados, nFilInd :=0
Local nAnexoImp, nAnexoExp, cUnid, cMoeda
Local cPictDi:= AVSX3("ED2_DI_NUM",6), cPictQtd:= AVSX3("W8_QTDE",6)
Local cPictTec:= AVSX3("W8_TEC",6), cPictPeso:= AVSX3("W7_PESO",6)
Local cPictVlAto:= AVSX3("W8_VL_AC",6), cPictRe:= AVSX3("EE9_RE",6)
Local cPictPipi:= AVSX3("EE9_POSIPI",6), cPictPliq:= AVSX3("ED2_PESO",6) //cPictPliq:= AVSX3("EE9_PSLQUN",6)
Local cPictQEmb:= AVSX3("EE9_SLDINI",6), cPictVAc:= AVSX3("EE9_VL_AC",6)
Local cFILEEC:= xFilial("EEC"), cFilED1:= xFilial("ED1"), cFilSYT:=xFilial("SYT")
Local cFilSW6:= xFilial("SW6"), cFilSW7:= xFilial("SW7")
Local cFilSW9:= xFilial("SW9"), cFilSA5:= xFilial("SA5"), i
Local cFILEE9:= xFilial("EE9"), cFil_SB1:= xFilial("SB1"), cFil_SW8:= xFilial("SW8")
Local cPictAg:= AVSX3("ED1_PERCAG",6), cPictUnid:= AVSX3("ED2_UMNCM",6)
Local lAchouNf:= .F.

Private nLIN, cDescr, aRudUnid:={}, aRudVlr :={}, aImp:={}, aExp:={}, nImp, nExp, nPos
Private aComp:={}, aVend:={}, nVend, nComp  // GFP - Criação das variaveis para Compras e Vendas Nacionais.
Private nAneTot :=  nAnePeso := nTotLin:=  nAneQtde := 0, nTotFrete:=0, nTotSeguro:=0
Private nRegPRE_F:=0, nRegVALEMB :=0, nRegPESO :=0, nRegQTDE :=0
Private nTotImp:=nTotExp:= 0, nRegSEGURO :=0, nRegFR_USS :=0

nTotal:=10
nCount:=0
ProcRegua(nTotal)

SW6->(DBSETORDER(1))
SW7->(DBSETORDER(4)) //SW7->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SA5->(DBSETORDER(3))
SB1->(DBSETORDER(1))
SW8->(DBSETORDER(5))
EE9->(DBSETORDER(10))
EEC->(DBSETORDER(1))
ED1->(DBSETORDER(4))
ED2->(DBSETORDER(4))
EE2->(dbSetOrder(1))
SYT->(DBSETORDER(1))

// Buscar Dados do Importador
SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))

For nMarcados:=1 To Len(aMarcados)

   nAnexoImp := 0
   aImp:={}
   aExp:={}
   aComp:={}
   aVend:={}

   ED0->(dbGoTo(aMarcados[nMarcados]))

   IncProc(STR0009) // Atualiza barra de progresso //"Imprimindo..."
   lCabExp:=lCabImp:=.F.
   ED0->(dbGoTo(aMarcados[nMarcados]))

   If Left(cTipo,1) $ "1/3"  //Importações/Compras Nacionais/Todos
      nLIN := 999

      For nFilInd:=1 to Len(aFil)   //AJP 27/06/2007
         If lMultiFil
            cFil_SW8 := aFil[nFilInd]
            cFilEEC  := aFil[nFilInd]
            cFilSW6  := aFil[nFilInd]
            cFilSW7  := aFil[nFilInd]
            cFilSW9  := aFil[nFilInd]
            cFilEE9  := aFil[nFilInd]
         EndIf
      
         // Verifica o Ato Concessorio da Importacao
         If SW8->(DbSeek(cFil_SW8+ED0->ED0_AC))
            Do While SW8->(!EOF()) .And. SW8->W8_FILIAL == cFil_SW8 .And. SW8->W8_AC == ED0->ED0_AC
               SW6->(DbSeek(cFilSW6+SW8->W8_HAWB))
               SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
               //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
               SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
               ED2->(DbSeek(cFilED2+SW8->W8_HAWB))
               IF nCount > nTotal
                  ProcRegua(nTotal)
                  nCount:=0
               ELSE 
                  IncProc(STR0014+"SW8...") //#STR0014->"Lendo "
                  nCount++
               ENDIF

               If (nPos:=aScan(aImp,{|x| x[1]==SW6->W6_DTREG_D .and. x[2]==SW6->W6_DI_NUM .and. x[3]==SW8->W8_ADICAO .and. x[4]==SW8->W8_COD_I})) > 0
                  aImp[nPos,5]  += SW7->W7_PESO * SW8->W8_QTDE
                  aImp[nPos,6]  += SW8->W8_QTDE
                  aImp[nPos,7]  += SW8->W8_VL_AC
                  aImp[nPos,8]  += SW8->W8_VL_AC/SW6->W6_FOB_TOT*SW6->W6_VLSEGMN //ED2->ED2_SE_USS
                  aImp[nPos,9]  += ((SW6->W6_VLFREPP * SW6->W6_TX_FRET / SW6->W6_TX_US_D)/SW6->W6_PESOL)*(SW7->W7_PESO * SW8->W8_QTDE)//ED2->ED2_FR_USS
                  aImp[nPos,10] += (SW8->W8_VL_AC * SW6->W6_TX_US_D) / SW9->W9_TX_FOB //(SW8->W8_PRECO*ED2->ED2_QTD) //(SW8->W8_PRECO*SW8->W8_QTDE)
               Else
                  aAdd(aImp,{SW6->W6_DTREG_D,;
                          SW6->W6_DI_NUM,;
                          SW8->W8_ADICAO,;
                          SW8->W8_COD_I,;
                          SW7->W7_PESO * SW8->W8_QTDE,;
                          SW8->W8_QTDE,;
                          SW8->W8_VL_AC,;
                          SW8->W8_VL_AC/SW6->W6_FOB_TOT*SW6->W6_VLSEGMN,;//ED2->ED2_SE_USS,;
                          ((SW6->W6_VLFREPP*SW6->W6_TX_FRET/SW6->W6_TX_US_D)/SW6->W6_PESOL)*(SW7->W7_PESO * SW8->W8_QTDE),;//ED2->ED2_FR_USS,;
                          (SW8->W8_VL_AC * SW6->W6_TX_US_D) / SW9->W9_TX_FOB,; //(SW8->W8_PRECO*(AVTransUnid(ED2->ED2_UMITEM,SW8->W8_UNID,SW8->W8_COD_I,(ED2->ED2_QTD),.F.))),;
                          SW8->W8_HAWB,;
                          SW8->W8_INVOICE,;
                          SW8->W8_FORN,;
                          SW8->W8_UNID,;
                          SW9->W9_MOE_FOB,;
                          Transf(Alltrim(SW8->W8_TEC), cPictTec)})

                  // ** PLB 29/06/07
                  cDescricao := Alltrim(MSMM(SW8->W8_DESC_DI,65))
                  If Empty(cDescricao)
                     cDescricao := Alltrim(MSMM(SB1->B1_DESC_GI,48))
                     If !Empty(cDescricao)
                        cDescricao += " ("+STR0015+" - "+Alltrim(MSMM(SB1->B1_DESC_I,40))+")" //STR0015#->"Nome Comercial"
                     EndIf
                  EndIf
                  cDescricao := StrTran( cDescricao, CRLF , " " )
                  cDescricao := StrTran( cDescricao, Chr(13), " " )
                  Do While At("  ",cDescricao) > 0
                     cDescricao := StrTran( cDescricao, "  " , " " )
                  EndDo
                  AAdd( aImp[Len(aImp)], cDescricao )
                  // **

                  //Nota fiscal de importação
                  SWN->(DbSetOrder(3))
                  SF1->(DbSetOrder(1))
                  lAchouNf:= .F.
                  If SWN->(DbSeek(xFilial()+SW8->W8_HAWB))
                     While SWN->(!Eof()) .And. SWN->WN_FILIAL == SWN->(xFilial()) .And. SWN->WN_HAWB == SW8->W8_HAWB
                        If SWN->WN_PRODUTO == SW8->W8_COD_I .And. SWN->WN_TIPO_NF $ "1/3/5"

                          SF1->(DBSeek(xFilial() + SWN->WN_DOC + SWN->WN_SERIE))

                          AAdd(aImp[Len(aImp)], SF1->F1_DOC)
                          AAdd(aImp[Len(aImp)], DtoC(SF1->F1_EMISSAO))
                          lAchouNf:= .T.
                          Exit
                        EndIf
                        SWN->(DBSkip())
                     EndDo
                     
                     If !lAchouNf
                        AAdd(aImp[Len(aImp)], "")
                        AAdd(aImp[Len(aImp)], "  /  /   ")
                     EndIf
                  Else
                     AAdd(aImp[Len(aImp)], "")
                     AAdd(aImp[Len(aImp)], "  /  /   ")               
                  EndIf

               EndIf
               SW8->(dbSkip())
            EndDo
	     EndIf
         ED8->(DBSETORDER(3))
         If ed8->(DbSeek(cFilED8+ED0->ED0_AC))
            Do While ED8->(!EOF()) .And. ED8->ED8_FILIAL == cFilED8 .And. ED8->ED8_AC == ED0->ED0_AC
      
               IF nCount > nTotal
                  ProcRegua(nTotal)
                  nCount:=0
               ELSE 
                  IncProc(STR0014+"ED8...")//#STR0014->"Lendo "
                  nCount++
               ENDIF
            
               //NOPADO POR AOM - 22/06/2012
               /*If (nPos:=aScan(aImp,{|x| x[1]==ED8->ED8_DTREG .and. x[2]==ED8->ED8_DI_NUM .and. x[3]==ED8->ED8_ADICAO .and. x[4]==ED8->ED8_COD_I})) > 0
                  aImp[nPos,5]  += ED8->ED8_PESO*ED8->ED8_QTD //
                  aImp[nPos,6]  +=ED8->ED8_QTD
                  aImp[nPos,7]  += ED8->ED8_VL_AC
                  aImp[nPos,8]  += ED8->ED8_SEGURO*ED8->ED8_TX_SE/ED8->ED8_TX_USS //ED2->ED2_SE_USS
                  aImp[nPos,9]  += ED8->ED8_FRETE*ED8->ED8_TX_FR/ED8->ED8_TX_USS //ED2->ED2_FR_USS
                  aImp[nPos,10] += ED8->ED8_VALORI //(SW8->W8_PRECO*SW8->W8_QTDE)
               Else
                  aAdd(aImp,{ED8->ED8_DTREG,;
                          ED8->ED8_DI_NUM,;
                          ED8->ED8_ADICAO,;
                          ED8->ED8_COD_I,;
                          ED8->ED8_PESO*ED8->ED8_QTD,;//
                          ED8->ED8_QTD,;
                          ED8->ED8_VL_AC,;
                          ED8->ED8_SEGURO*ED8->ED8_TX_SE/ED8->ED8_TX_USS,; //ED2->ED2_SE_USS,;
                          ED8->ED8_FRETE*ED8->ED8_TX_FR/ED8->ED8_TX_USS,; //ED2->ED2_FR_USS,;
                          ED8->ED8_VALORI,;
                          "",;
                          ED8->ED8_INVOIC,;
                          "",;
                          ED8->ED8_UM,ED8->ED8_MOEDA,;
                          Transf(Alltrim(ED8->ED8_NCM), cPictTec)})
                  cDescricao := Alltrim(MSMM(ED8->ED8_DES_DI,AVSX3("ED8_DES_VM",AV_TAMANHO),,,LERMEMO))
                  cDescricao := StrTran( cDescricao, CRLF , " " )
                  cDescricao := StrTran( cDescricao, Chr(13), " " )
                  Do While At("  ",cDescricao) > 0
                     cDescricao := StrTran( cDescricao, "  " , " " )
                  EndDo
                  AAdd( aImp[Len(aImp)], cDescricao )

                  AAdd(aImp[Len(aImp)], ED8->ED8_NF)
                  AAdd(aImp[Len(aImp)], DtoC(ED8->ED8_EMISSA))

               EndIf*/
               If ED8->(FieldPos("ED8_PEDIDO")) == 0 .Or. ED8->(Empty(ED8_PEDIDO)) //AOM - 22/06/2012
              
			      If (nPos:=aScan(aImp,{|x| x[1]==ED8->ED8_DTREG .and. x[2]==ED8->ED8_DI_NUM .and. x[3]==ED8->ED8_ADICAO .and. x[4]==ED8->ED8_COD_I})) > 0
                     aImp[nPos,5]  += ED8->ED8_PESO*ED8->ED8_QTD //
                     aImp[nPos,6]  += ED8->ED8_QTD
                     aImp[nPos,7]  += ED8->ED8_VL_AC
                     aImp[nPos,8]  += ED8->ED8_SEGURO*ED8->ED8_TX_SE/ED8->ED8_TX_USS //ED2->ED2_SE_USS
                     aImp[nPos,9]  += ED8->ED8_FRETE*ED8->ED8_TX_FR/ED8->ED8_TX_USS //ED2->ED2_FR_USS
                     aImp[nPos,10] += ED8->ED8_VALORI //(SW8->W8_PRECO*SW8->W8_QTDE)
                  Else
                     aAdd(aImp,{ED8->ED8_DTREG,;
                             ED8->ED8_DI_NUM,;
                             ED8->ED8_ADICAO,;
                             ED8->ED8_COD_I,;
                             ED8->ED8_PESO*ED8->ED8_QTD,;//
                             ED8->ED8_QTD,;
                             ED8->ED8_VL_AC,;
                             ED8->ED8_SEGURO*ED8->ED8_TX_SE/ED8->ED8_TX_USS,; //ED2->ED2_SE_USS,;
                             ED8->ED8_FRETE*ED8->ED8_TX_FR/ED8->ED8_TX_USS,; //ED2->ED2_FR_USS,;
                             ED8->ED8_VALORI,;
                             "",;
                             ED8->ED8_INVOIC,;
                             "",;
                             ED8->ED8_UM,ED8->ED8_MOEDA,;
                             Transf(Alltrim(ED8->ED8_NCM), cPictTec)})
                             
                             cDescricao := Alltrim(MSMM(ED8->ED8_DES_DI,AVSX3("ED8_DES_VM",AV_TAMANHO),,,LERMEMO))
                             cDescricao := StrTran( cDescricao, CRLF , " " )
                             cDescricao := StrTran( cDescricao, Chr(13), " " )
                             Do While At("  ",cDescricao) > 0
                                cDescricao := StrTran( cDescricao, "  " , " " )
                             EndDo
                             AAdd( aImp[Len(aImp)], cDescricao )

                             AAdd(aImp[Len(aImp)], ED8->ED8_NF)
                             AAdd(aImp[Len(aImp)], DtoC(ED8->ED8_EMISSA))
                  EndIf
			   
               Else
			
                  If (nPos:=aScan(aComp,{|x| x[1]==ED8->ED8_PEDIDO .and. x[2]==ED8->ED8_COD_I})) > 0
                     aComp[nPos,9]  += ED8->ED8_PESO
                     aComp[nPos,11] += ED8->ED8_QTD
                     aComp[nPos,12] += ED8->ED8_QTDNCM
                     aComp[nPos,13] += ED8->ED8_VALORI
                     aComp[nPos,14] += ED8->ED8_VALEMB
                  Else
                     SA2->(DBSETORDER(1)) //A2_FILIAL+A2_COD+A2_LOJA
                     SA2->(DBSEEK(ED8->(AvKey(ED8_FILIAL,"A2_FILIAL")+AvKey(ED8_FORN,"A2_COD")+AvKey(ED8_LOJA,"A2_LOJA"))))
                     aAdd(aComp,{ED8->ED8_PEDIDO,;
                  	           ED8->ED8_COD_I,;
                               ED8->ED8_NF,;
                               ED8->ED8_SERIE,;
                               ED8->ED8_MOD_NF,;
                               TRANSF(Alltrim(ED8->ED8_NCM), cPictTec),;
                               SA2->A2_CGC,;                            
                               ED8->ED8_DESC,;
                               ED8->ED8_PESO,;
                               ED8->ED8_UM,;
                               ED8->ED8_QTD,;
                               ED8->ED8_QTDNCM,;
                               ED8->ED8_VALORI,;
                               ED8->ED8_VALEMB})
                  EndIf
			   
               EndIf                

               ED8->(dbSkip())
            EndDo
	     EndIf

         nImp:=1

         Do While nImp <= Len(aImp)

            IF nCount > nTotal
               ProcRegua(nTotal)
               nCount:=0
            ELSE 
               IncProc(STR0016) //#STR0016->"Processando..."
               nCount++
            ENDIF

            SA5->(DbSeek(cFilSA5+aImp[nImp,4]))
            SB1->(DbSeek(cFil_SB1+aImp[nImp,4]))

            If Empty(aImp[nImp,2])
               nImp += 1
               If lCabImp .AND. nImp>Len(aImp)
                  RU150RODAPE()
               EndIF
               Loop
            Endif
            lCabImp:=.T.
            //If nLIN > NUMLINAN  .Or. nLin > NUMLINDI
            If nTotLin > NUMLINAN  .Or. nLin > NUMLINDI
               If nLin # 999
                  RU150RODAPE()
               EndIf

               DET->(DBAPPEND())  //Grava o Cabecalho de Importacao
               nAnexoImp += 1
               DET->WK_SEQREL := cSEQREL
               DET->WKD_FLAG  := "E"
               
               cLastFlag := "E"
               
               DET->WK_PED    := ED0->ED0_PD
               DET->WKD_ANEXO := StrZero(nAnexoImp,3,0)
               nAnePeso := 0
               nAneQtde := 0
               nAneTot  := 0
               nLIN := 0
               nTotLin := 0
            EndIf
            nLIN += 1
            nTotLin += 1
            DET->(DBAPPEND())
            DET->WK_SEQREL   := cSEQREL
            DET->WK_PED      := ED0->ED0_PD
            DET->WKD_FLAG    := "F"
             
            cLastFlag := "F"
             
            //DFS
            //NOPADO por RRC - 11/12/2012 - A Impressão da DI Original vale para Atos de Isenção
            /*If ED2->(FieldPos("ED2_DI_ORI")) > 0 
               RudD->WKD_DIADOR := Transf(Alltrim(aImp[nImp,2]),cPictDi)+"/"+Alltrim(aImp[nImp,3])  // GFP - 22/03/2012
            EndIf
            */ 
            DET->WKD_DI_ADI  := Transf(Alltrim(aImp[nImp,2]),cPictDi)+"/"+Alltrim(aImp[nImp,3])
            DET->WKD_DTREGI  := DtoC(aImp[nImp,1])
            DET->WKD_DTDESE  := If(!Empty(aImp[nImp,11]),DToc(GetDtDesemb(aImp[nImp,2])),"")//RRC - 12/12/2012 - Passa o nº da DI sem concatenação com nº do Aditivo como parâmetro, caso não seja DI externa.//DToC(GetDtDesemb(DET->WKD_DI_ADI)) //DFS
            DET->WKD_NCM     := aImp[nImp,16]
            DET->WKD_PARTNU  := Alltrim(SB1->B1_COD)
            // ** PLB 29/06/07
            cDescricao := aImp[nImp,17]
            If !Empty(cDescricao)
               DET->WKD_DESCR   := MemoLine(cDescricao,60,1)
            Else
               DET->WKD_DESCR   := AllTrim(SB1->B1_DESC)
            EndIf
            // **
            DET->WKD_PESO    := Alltrim(Transf(aImp[nImp,5], cPictPeso))
            DET->WKD_QTDE    := Alltrim(Transf(aImp[nImp,6], cPictQtd))
            DET->WKD_VAL_F   := Alltrim(Transf(aImp[nImp,7], cPictVlAto))
            DET->WKD_SEGURO  := Alltrim(Transf(aImp[nImp,8],"@E 99,999,999,999.99"))        //Vlr.Seguro
            DET->WKD_FR_USS  := Alltrim(Transf(aImp[nImp,9],"@E 99,999,999,999.99"))        //Vlr.Frete
            DET->WKD_UNID    := aImp[nImp,14] // Unidade de Medida
            DET->WKD_MOEDA   := aImp[nImp,15]  //ED2->ED2_MOEDA
            DET->WKD_VALEMB  := Alltrim(Transf(Round(aImp[nImp,10],2),"@E 99,999,999,999.99"))        // Valor Local de Embarque

            /*If ! Empty(MemoLine(SB1->B1_DESC , 23,2))
               DET->(DBAPPEND())
               DET->WK_SEQREL   := cSEQREL
               DET->WK_PED      := ED0->ED0_PD
               DET->WKD_FLAG    := "F"
               DET->WKD_DESCR   := MemoLine(SB1->B1_DESC , 23,2)
               nTotLin += 1
            EndIF */

            //Nota fiscal de importação
            DET->WKD_NF  := aImp[nImp,18]
            DET->WKD_DTNF:= aImp[nImp,19]
             
            For ni := 2 To MlCount(cDescricao,60)
               DET->(DBAPPEND())
               DET->WK_SEQREL   := cSEQREL
               DET->WK_PED      := ED0->ED0_PD
               DET->WKD_FLAG    := "F"
                
               cLastFlag := "F"
                
               DET->WKD_DESCR   := MemoLine(cDescricao,60,ni)
               nTotLin += 1
            Next ni

            nUM:=ASCAN(aRudUnid,{|X| ALLTRIM(X[1]) = Alltrim(aImp[nImp,14])})
            nVL:=ASCAN(aRudVlr ,{|X| ALLTRIM(X[1]) = Alltrim(aImp[nImp,15])})

            If nUM = 0
               AADD(aRudUnid,{Alltrim(aImp[nImp,14]),aImp[nImp,6]})
            Else
               aRudUnid[nUM,2] += aImp[nImp,6]
            EndIf

            If nVL = 0
               AADD(aRudVlr ,{Alltrim(aImp[nImp,15]),Round(aImp[nImp,10],2)})
            Else
               aRudVLR[nVL,2] += Round(aImp[nImp,10],2)
            EndIf

            nAneTot   += aImp[nImp,7]
            nAnePeso  += aImp[nImp,5]
            nAneQtde  += aImp[nImp,6]
            nTotFrete += aImp[nImp,9]
            nTotSeguro+= aImp[nImp,8]
            nImp+=1

            If nImp>Len(aImp)
               RU150RODAPE()
            EndIF
         Enddo 
       
         // GFP - Tratamento para Compras Nacionais
         nComp:=1
         If !Empty(aComp)//RRC 06/12/2012
            nLin := 999
         EndIf
         
         Do While nComp <= Len(aComp)

            IF nCount > nTotal
               ProcRegua(nTotal)
               nCount:=0
            ELSE 
               IncProc(STR0014+"ED8...") //#STR0014->"Lendo "
               nCount++
            ENDIF

            //SA5->(DbSeek(cFilSA5+aImp[nImp,4]))
            SB1->(DbSeek(cFil_SB1+ED8->ED8_COD_I))

            If Empty(aComp[nComp,1])  //ED8_PEDIDO
               nComp += 1
               If lCabImp .AND. nComp>Len(aComp)
                  RU150RODAPE()
               EndIF
               Loop
            Endif
			
            lCabImp:=.T.
			
            If nTotLin > NUMLINAN  .Or. nLin > NUMLINDI
               If nLin # 999
                  RU150RODAPE()
               EndIf
              
               DET->(DBAPPEND())  //Grava o Cabecalho de Compras Nacionais
               nAnexoImp += 1
               DET->WK_SEQREL := cSEQREL
               DET->WKD_FLAG  := "C" //RRC - 26/11/2012
              
               cLastFlag := "C" //RRC - 26/11/2012
              
               DET->WK_PED    := ED0->ED0_PD
               DET->WKD_ANEXO := StrZero(nAnexoImp,3,0)
               nAnePeso := 0
               nAneQtde := 0
               nAneTot  := 0
               nLIN := 0
               nTotLin := 0
            EndIf
			 
            nLIN += 1
            nTotLin += 1
            //GFP - 24/10/2011 -  Grava corpo do RPT
            DET->(DBAPPEND())   
            DET->WK_SEQREL   := cSEQREL
            DET->WK_PED      := ED0->ED0_PD
            DET->WKD_FLAG    := "D" //RRC - 26/11/2012
            
            cLastFlag := "D" //RRC - 26/11/2012
            
            DET->WKD_PEDCOM  := aComp[nComp,1]
            DET->WKD_NCM     := aComp[nComp,6]
            DET->WKD_PARTNU  := Alltrim(SB1->B1_COD)
            DET->WKD_DESCR   := aComp[nComp,8]
            DET->WKD_PESO    := Alltrim(Transf(aComp[nComp,9], cPictPeso))           
            DET->WKD_QTD_AD  := Alltrim(Transf(aComp[nComp,11], cPictQtd))
            DET->WKD_QTD_ES  := Alltrim(Transf(aComp[nComp,12], cPictQtd))
            DET->WKD_VAL_R   := Alltrim(Transf(aComp[nComp,13], "@E 99,999,999,999.99"))
            DET->WKD_VAL_D   := Alltrim(Transf(aComp[nComp,14], "@E 99,999,999,999.99"))

            nUM:=ASCAN(aRudUnid,{|X| ALLTRIM(X[1]) = Alltrim(aComp[nComp,10])})
         // nVL:=ASCAN(aRudVlr ,{|X| ALLTRIM(X[1]) = Alltrim(aImp[nImp,15])})
         
		   /* NOPADO POR RRC - 10/08/2012
            If nUM = 0
               AADD(aRudUnid,{Alltrim(aImp[nImp,14]),aImp[nImp,6]})
            Else
               aRudUnid[nUM,2] += aImp[nImp,6]
            EndIf

            If nVL = 0
               AADD(aRudVlr ,{Alltrim(aImp[nImp,15]),Round(aImp[nImp,10],2)})
            Else
               aRudVLR[nVL,2] += Round(aImp[nImp,10],2)
            EndIf*/
            nAneTot   += aComp[nComp,14]   // Total FOB US$
            nAnePeso  += aComp[nComp,9]    // Peso
            nAneQtde  += aComp[nComp,11]   // Quantidade
            nComp+=1
             
            If nComp>Len(aComp)
               RU150RODAPE()
            EndIF
         Enddo      
      Next 
   Endif


   nTotImp   := nAnexoImp
   nAnexoExp := 0

   If Left(cTipo,1) $ "2/3"   //Exportação/Vendas Nacionais/Todos

      nLin := 999
      ED9->(DbSetOrder(3))
      // Verifica o Ato Concessorio da Exportacao
      If EE9->(DbSeek(cFilEE9+ED0->ED0_AC)) .OR. ( lTemED9Cpos .AND. ED9->(DbSeek(cFilED9+ED0->ED0_AC)) )//AWR - 17/04/2009
         
         nTamDes:=AVSX3('EE9_VM_DRE',3)
         
         Do While EE9->(!EOF()) .And. EE9->EE9_FILIAL == cFilEE9 .And. EE9->EE9_ATOCON == ED0->ED0_AC
            EEC->(DbSeek(cFilEEC+EE9->EE9_PREEMB))
          //ED1->(DbSeek(cFilED1+EE9->EE9_ATOCON))
            IF nCount > nTotal
               ProcRegua(nTotal)
               nCount:=0
            ELSE 
               IncProc(STR0014+"EE9...") //#STR0014->"Lendo "
               nCount++
            ENDIF

            If (nPos:=aScan(aExp,{|x| x[1]==EEC->EEC_DTEMBA .and. x[2]==EE9->EE9_RE .and. x[3]==EE9->EE9_COD_I})) > 0
               aExp[nPos,6]  += (EE9->EE9_PSLQUN * EE9->EE9_SLDINI)
               aExp[nPos,7]  += EE9->EE9_SLDINI
               aExp[nPos,8]  += EE9->EE9_VL_AC //- (EE9->EE9_VL_AC * ED1->ED1_PERCAG/100)
               aExp[nPos,9]  += EE9->EE9_PRCINC
            Else
               aAdd(aExp,{EEC->EEC_DTEMBA,;
                          EE9->EE9_RE    ,;
                          EE9->EE9_COD_I ,;
                          EE9->EE9_FASEDR,;
                          EE9->EE9_POSIPI,;
                         (EE9->EE9_PSLQUN * EE9->EE9_SLDINI),;
                          EE9->EE9_SLDINI,;
                          EE9->EE9_VL_AC ,; //- (EE9->EE9_VL_AC * ED1->ED1_PERCAG/100),;
                          EE9->EE9_PRCINC,;
                          EE9->EE9_UNIDAD,;
                          EEC->EEC_MOEDA})

               AAdd( aExp[Len(aExp)], Alltrim(MSMM_DR(EE9->EE9_DESCRE,nTamDes)) )  // PLB 29/06/07

               //Notas fiscais de exportação
               SF2->(DBSetOrder(1))
               If EasyGParam("MV_EECFAT",,.F.) .And. !Empty(EE9->EE9_NF)
                  SF2->(DBSeek(xFilial() + AvKey(EE9->EE9_NF, "F2_DOC") + AvKey(EE9->EE9_SERIE, "F2_SERIE") +;
                        AvKey(EEC->EEC_IMPORT, "F2_CLIENTE") + AvKey(EEC->EEC_IMLOJA, "F2_LOJA")))
               
                  AAdd(aExp[Len(aExp)], SF2->F2_DOC)
                  AAdd(aExp[Len(aExp)], DtoC(SF2->F2_EMISSAO))
                  
               Else
                  AAdd(aExp[Len(aExp)], "")
                  AAdd(aExp[Len(aExp)], "  /  /   ")
               EndIf

            EndIf
            EE9->(dbSkip())
         EndDo

         IF lTemED9Cpos .AND. ED9->(DbSeek(cFilED9+ED0->ED0_AC))//AWR - 17/04/2009

            Do While ED9->(!EOF()) .And. ED9->ED9_FILIAL == cFilED9 .And. ED9->ED9_AC == ED0->ED0_AC

               IF nCount > nTotal
                  ProcRegua(nTotal)
                  nCount:=0
               ELSE 
                  IncProc(STR0014+"ED9...") //#STR0014->"Lendo "
                  nCount++
               ENDIF

               If ED9->(Empty(ED9_PEDIDO))
                  If (nPos:=aScan(aExp,{|x| x[1]==ED9->ED9_DTEMB .and. x[2]==ED9->ED9_RE .and. x[3]==ED9->ED9_PROD})) > 0
                     aExp[nPos,6]  +=(ED9->ED9_PESO * ED9->ED9_QTD)
                     aExp[nPos,7]  += ED9->ED9_QTD
                     aExp[nPos,8]  += ED9->ED9_VL_AC
                     aExp[nPos,9]  += ED9->ED9_VALORI
                  Else
                     aAdd(aExp,{ED9->ED9_DTEMB ,;
                                ED9->ED9_RE    ,;
                                ED9->ED9_PROD  ,;
                                ED9->ED9_FASEDR,;
                                ED9->ED9_NCM   ,;
                               (ED9->ED9_PESO * ED9->ED9_QTD),;
                                ED9->ED9_QTD   ,;
                                ED9->ED9_VL_AC ,;
                                ED9->ED9_VALORI,;
                                ED9->ED9_UM    ,;
                                ED9->ED9_MOEDA ,;
                             /*Alltrim(ED9->ED9_DESC)*/ALLTRIM(Posicione("SB1",1,xFilial("SB1")+ED9->ED9_PROD,"B1_DESC")),;
                             ED9->ED9_NF    ,;
                             DtoC(ED9->ED9_EMISSA),;
                             })
                   EndIf
               Else   // GFP - 24/10/2011 - VENDAS PARA EXPORTADORES.
                  SA1->(DBSETORDER(1)) //A1_FILIAL+A1_COD+A1_LOJA
                  SA1->(DBSEEK(ED9->(AvKey(ED9_FILIAL,"A1_FILIAL")+AvKey(ED9_CODEXP,"A1_COD")+AvKey(ED9_EXPLOJ,"A1_LOJA"))))
                  
                  If (nPos:=aScan(aVend,{|x| x[1]==ED9->ED9_PEDIDO .and. x[2]==ED9->ED9_AC})) > 0
                     aVend[nPos,6]  +=(ED9->ED9_PESO * ED9->ED9_QTD)
                     aVend[nPos,7]  += ED9->ED9_QTDNCM
                     aVend[nPos,8]  += ED9->ED9_VL_AC
                     aVend[nPos,9]  += ED9->ED9_VALORI
                  Else
                     aAdd(aVend,{ED9->ED9_PEDIDO,;
                     	          ED9->ED9_PROD,;
                     	          ED9->ED9_AC,;
                     	          ED9->ED9_NF,;
                     	          ED9->ED9_SERIE,;
                     	          ED9->ED9_EMISSA,;
                     	          ED9->ED9_MOD_NF,;
                     	          ED9->ED9_NCM,;
                     	          SA1->A1_CGC,;
                     	          /*Alltrim(ED9->ED9_DESC)*/ALLTRIM(Posicione("SB1",1,xFilial("SB1")+ED9->ED9_PROD,"B1_DESC")),;
                     	          ED9->ED9_PESO,;
                     	          ED9->ED9_QTD,;
                     	          ED9->ED9_QTDNCM,;
                     	          ED9->ED9_MOEDA,;
                     	          ED9->ED9_VALMOE,;
                     	          ED9->ED9_VL_FOB })                 	          
                  EndIf
               EndIf
               ED9->(dbSkip())
            EndDo
            ED9->(DbSetOrder(1))

         ENDIF
         
         nExp:=1

         Do While nExp <= Len(aExp)

            IF nCount > nTotal
               ProcRegua(nTotal)
               nCount:=0
            ELSE 
               IncProc(STR0014+"EE9...") //#STR0014->"Lendo " FSM - 23/11/11
               nCount++
            ENDIF

            (cAliasSB1)->(DbSeek(cFilSB1Aux+aExp[nExp,3]))

            If aExp[nExp,4] == "1"  .Or. Empty(aExp[nExp,2])
               nExp += 1
               If lCabExp .AND. nExp>Len(aExp)
                  RU150RODAPE()
               EndIF
               Loop
            Endif
            lCabExp:=.T.
            //If nLIN > NUMLINAN  .Or. nLin > NUMLINDI
            If nTotLin > NUMLINAN  .Or. nLin > NUMLINDI
               If nLin # 999
                  RU150RODAPE()
               EndIf
               DET->(DBAPPEND())  //Grava o Cabecalho de Exportacao
               nAnexoExp += 1
               DET->WK_SEQREL := cSEQREL
               DET->WKD_FLAG  := "K"
               
               cLastFlag := "K"
               
               DET->WK_PED    := ED0->ED0_PD
               DET->WKD_ANEXO := StrZero(nAnexoExp,3,0)
               nAneTot   := 0
               nAnePeso  := 0
               nAneQtde  := 0
               nTotFrete := 0
               nTotSeguro:= 0
               nLIN := 0
               nTotLin := 0
            EndIf
            nLIN += 1
            nTotLin += 1
            //EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey("PORT. -PORTUGUES","EE2_IDIOMA")+AVKey(aExp[nExp,3],"EE2_COD")))
            //cDescr         := MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP)
            // ** PLB 29/06/07
            cDescr := aExp[nExp][12]
            If Empty(cDescr)
               EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(aExp[nExp,3],"EE2_COD")))
               cDescr := Alltrim(MSMM_DR(EE2->EE2_TEXTO,TAMDESCEXP))
            EndIf
            cDescr := StrTran( cDescr, CRLF , " " )
            cDescr := StrTran( cDescr, Chr(13), " " )
            Do While At("  ",cDescr) > 0
               cDescr := StrTran( cDescr, "  " , " " )
            EndDo
            // **
            DET->(DBAPPEND())
            DET->WK_SEQREL   := cSEQREL
            DET->WK_PED      := ED0->ED0_PD
            DET->WKD_FLAG    := "J"//"F"
            
            cLastFlag := "J"
            
            DET->WKD_DI_ADI  := Transf(Alltrim(aExp[nExp,2]), cPictRe)
            DET->WKD_DTREGI  := DtoC(aExp[nExp,1])
            DET->WKD_NCM     := Transf(aExp[nExp,5], cPictPipi)
            DET->WKD_PARTNU  := Alltrim((cAliasSB1)->B1_COD )
            // ** PLB 29/06/07
            If !Empty(cDescr)
               DET->WKD_DESCR := MemoLine(cDescr,TAMDESCEXP,1)
            Else
               DET->WKD_DESCR := Alltrim((cAliasSB1)->B1_DESC)
            EndIf
            // **
            DET->WKD_PESO    := Alltrim(Transf(aExp[nExp,6], cPictPliq))
            DET->WKD_QTDE    := Alltrim(Transf(aExp[nExp,7], cPictQEmb))
            DET->WKD_VAL_F   := Alltrim(Transf(aExp[nExp,8], cPictVAc))
            DET->WKD_SEGURO  := Alltrim(Transf(0,"@E 99,999,999,999.99"))        //Vlr.Seguro
            DET->WKD_FR_USS  := Alltrim(Transf(0,"@E 99,999,999,999.99"))        //Vlr.Frete
            DET->WKD_UNID    := aExp[nExp,10] // Unidade de Medida
            DET->WKD_MOEDA   := aExp[nExp,11]
            DET->WKD_VALEMB  := Alltrim(Transf(Round(aExp[nExp,9],2),"@E 99,999,999,999.99"))        // Valor Local de Embarque

            //Nota fiscal de exportação
            DET->WKD_NF  := aExp[nExp,13]
            DET->WKD_DTNF:= aExp[nExp,14]

            For ni := 2 To MlCount(cDescr,TAMDESCEXP)
               DET->(DBAPPEND())
               DET->WK_SEQREL   := cSEQREL
               DET->WK_PED      := ED0->ED0_PD
               DET->WKD_FLAG    := "J"//"F"
               
               cLastFlag := "J"
               
               DET->WKD_DESCR   := MemoLine(cDescr,TAMDESCEXP,ni)
               nTotLin += 1
            Next ni

            nUM:=ASCAN(aRudUnid,{|X| ALLTRIM(X[1]) = Alltrim(aExp[nExp,10])})
            nVL:=ASCAN(aRudVlr ,{|X| ALLTRIM(X[1]) = Alltrim(aExp[nExp,11])})

            If nUM = 0
               AADD(aRudUnid,{Alltrim(aExp[nExp,10]),aExp[nExp,7]})
            Else
               aRudUnid[nUM,2] += aExp[nExp,7]
            EndIf

            If nVL = 0
               AADD(aRudVlr ,{Alltrim(aExp[nExp,11]),Round(aExp[nExp,8],2)})
            Else
               aRudVLR[nVL,2] += Round(aExp[nExp,8],2)
            EndIf

            nAneTot   += aExp[nExp,8]
            nAnePeso  += aExp[nExp,6]
            nAneQtde  += aExp[nExp,7]
            nTotFrete += 0
            nTotSeguro+= 0

            nExp+=1

            If nExp>Len(aExp)
               RU150RODAPE()
            EndIF

         Enddo
         
         //GFP - 24/10/2011 - Tratamento para Vendas Nacionais
         nVend:=1
                 
         If !Empty(aVend)//RRC - 06/12/2012
            nLin := 999 
         EndIf
         
         Do While nVend <= Len(aVend)

            IF nCount > nTotal
               ProcRegua(nTotal)
               nCount:=0
            ELSE 
               IncProc(STR0014+"EE9...") //#STR0014->"Lendo " FSM - 23/11/11
               nCount++
            ENDIF

            (cAliasSB1)->(DbSeek(cFilSB1Aux+aVend[nVend,2]))

            If Empty(aVend[nVend,1])
               nVend += 1
               If lCabExp .AND. nVend>Len(aVend)
                  RU150RODAPE()
               EndIF
               Loop
            Endif
            lCabExp:=.T.
            If nTotLin > NUMLINAN  .Or. nLin > NUMLINDI
               If nLin # 999
                  RU150RODAPE()
               EndIf
               DET->(DBAPPEND())  //Grava o Cabecalho de Vendas Nacionais
               nAnexoExp += 1
               DET->WK_SEQREL := cSEQREL
               DET->WKD_FLAG  := "V"
               
               cLastFlag := "V"
               
               DET->WK_PED    := ED0->ED0_PD
               DET->WKD_ANEXO := StrZero(nAnexoExp,3,0)
               nAneTot   := 0
               nAnePeso  := 0
               nAneQtde  := 0
               nTotFrete := 0
               nTotSeguro:= 0
               nLIN := 0
               nTotLin := 0
            EndIf
            nLIN += 1
            nTotLin += 1

            DET->(DBAPPEND())
            DET->WK_SEQREL   := cSEQREL
            DET->WK_PED      := ED0->ED0_PD
            DET->WKD_FLAG    := "X"
            
            cLastFlag := "X"
            
            DET->WKD_NF      := aVend[nVend,4]
            DET->WKD_SERIE   := Transform(aVend[nVend,5],AvSx3("F1_SERIE",AV_PICTURE))
            DET->WKD_DTNF    := DtoC(aVend[nVend,6])
            DET->WKD_MOD_NF  := aVend[nVend,7]
            DET->WKD_NCM     := aVend[nVend,8]
            DET->WKD_CGC     := aVend[nVend,9]
            DET->WKD_DESCR   := aVend[nVend,10]       
            DET->WKD_PESO    := Alltrim(Transf(aVend[nVend,11], cPictPliq))
            DET->WKD_QTD_AD  := Alltrim(Transf(aVend[nVend,12], cPictQtd))
            DET->WKD_QTD_ES  := Alltrim(Transf(aVend[nVend,13], cPictQtd))
            DET->WKD_VAL_R   := AllTrim(Transf(aVend[nVend,16],"@E 99,999,999,999.99"))        // Valor Local de Embarque
            DET->WKD_VAL_D   := AllTrim(Transf(aVend[nVend,15],"@E 99,999,999,999.99"))
            /*
            For ni := 2 To MlCount(cDescr,TAMDESCEXP)
               DET->(DBAPPEND())
               DET->WK_SEQREL   := cSEQREL
               DET->WK_PED      := ED0->ED0_PD
               DET->WKD_FLAG    := "F"
               DET->WKD_DESCR   := MemoLine(cDescr,TAMDESCEXP,ni)
               nTotLin += 1
            Next ni
*/
            nUM:=ASCAN(aRudUnid,{|X| ALLTRIM(X[1]) = Alltrim(aExp[nExp,17])})
//          nVL:=ASCAN(aRudVlr ,{|X| ALLTRIM(X[1]) = Alltrim(aExp[nExp,11])})
/*
            If nUM = 0
               AADD(aRudUnid,{Alltrim(aExp[nExp,10]),aExp[nExp,7]})
            Else
               aRudUnid[nUM,2] += aExp[nExp,7]
            EndIf

            If nVL = 0
               AADD(aRudVlr ,{Alltrim(aExp[nExp,11]),Round(aExp[nExp,8],2)})
            Else
               aRudVLR[nVL,2] += Round(aExp[nExp,8],2)
            EndIf
*/
            nAneTot   += aVend[nVend,16]    // Total FOB US$
            nAnePeso  += aVend[nVend,11]    // Peso
            nAneQtde  += aVend[nVend,12]    // Quantidade

            nVend+=1

            If nVend>Len(aVend)
               RU150RODAPE()
            EndIF
         Enddo       
      Endif 
   Endif

   nTotExp:= nAnexoExp

   If lCabImp .OR. lCabExp
      RU150Cabec()
   EndIf

   RecLock("ED0",.F.)
   ED0->ED0_OK  := "  "  //Pedido Drawback Desmarcado
   ED0->(MsUnLock())

Next

CAB->(DBGOTOP())
DET->(DBGOTOP())

Return .T.

*------------------------------*
Static Function RU150Cabec()
*------------------------------*
Local cPictCGC := AVSX3("YT_CGC",6)

CAB->(DBAPPEND())
CAB->WK_SEQREL  := cSEQREL
CAB->WK_PED     := ED0->ED0_PD                   //Pedido de Drawback
CAB->WK_AC      := ED0->ED0_AC                   //Ato Concessorio
CAB->WK_EMPRESA := ALLTRIM(SYT->YT_NOME)         //Empresa
CAB->WK_ENDERE  := ALLTRIM(SYT->YT_ENDE)+" - "+ALLTRIM(SYT->YT_CIDADE)+" - "+ALLTRIM(SYT->YT_ESTADO)// Endereço
CAB->WK_CGC     := Transf(SYT->YT_CGC, cPictCGC) //CGC
CAB->WK_ANETEX  := StrZero(nTotExp,3,0)
CAB->WK_ANETIM  := StrZero(nTotImp,3,0)

Return .T.

*------------------------------*
Static Function RU150RODAPE()
*------------------------------*
Local aMeses, dData, i, b, a
Local cPictPe:= AVSX3("ED2_PESO",6), cPictQtde:= AVSX3("ED2_QTD",6)
Local cPictTot:= AVSX3("ED2_VALCAL",6)

For i:=nTotLin To NUMLINAN
   DET->(DBAPPEND())  // Grava os Registros em Branco até o Limite Max. Permitido
   DET->WK_SEQREL := cSEQREL
   DET->WKD_FLAG  := cLastFlag //"F"
   DET->WK_PED    := ED0->ED0_PD
Next
                                
aMeses:= {"Janeiro", "Fevereiro", "Marco", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}
dData := StrZero(Day(dDataBase),2)+" de "+Alltrim(Left(Upper(aMeses[Month(dDataBase)]),1))+Alltrim(Lower(Substr(aMeses[Month(dDataBase)],2,15)))+;
         " de "+Str(Year(dDataBase),4)+"."

DET->(DBAPPEND())  // Grava o Rodape
DET->WK_SEQREL  := cSEQREL
DET->WKD_FLAG   := "G"
DET->WK_PED     := ED0->ED0_PD
DET->WKD_LOCAL  := Alltrim(Left(Upper(SYT->YT_CIDADE),1))+Alltrim(Lower(Right(SYT->YT_CIDADE,19)))+", "+dData
DET->WKD_TOT_P  := Transf(nAnePeso, cPictPe)
DET->WKD_TOT_Q  := Transf(nAneQtde, cPictQtde)
DET->WKD_TOT_F  := Transf(nAneTot, cPictTot)
DET->WKD_TOTFRT := Transf(nTotFrete,"@E 999,999,999.99")
DET->WKD_TOTSEG := Transf(nTotSeguro,"@E 999,999,999.99")
DET->WKD_ASSRU1 := EasyGParam("MV_ASSRUD1",,"")
DET->WKD_ASSRU2 := EasyGParam("MV_ASSRUD2",,"")

aSort(aRudVlr ,,,{|x,y| x[1] > y[1]})//Imprime totais por moeda
For b := 1 To Len(aRudVlr)
   cCampo_Moeda  := "DET->WKD_TVEM"+StrZero(b,2)
   &cCampo_Moeda := Alltrim(Transf(aRudVlr[b,2],"@E 99,999,999,999.99"))
   cUnidade_Vlr  := "DET->WKD_MVEM"+StrZero(b,2)
   &cUnidade_Vlr := Alltrim(aRudVlr[b,1])+" - "
Next b

aSort(aRudUnid,,,{|x,y| x[1] > y[1]})//Imprimi totais por Vlr de Embarque
For a := 1 To Len(aRudunid)
   cCampo   := "DET->WKD_TUNI"+StrZero(a,2)
   &cCampo  := Alltrim(Transf(aRudUnid[a,2],cPictQtde))
   cUnidade := "DET->WKD_UNI"+StrZero(a,2)
   &cUnidade:= Alltrim(aRudUnid[a,1])+" - "
Next a
aRudUnid:={}
aRudVlr :={}
nTotFrete := 0
nTotSeguro:=0

Return .T.

*--------------------------*
Static Function Ru150Tela()
*--------------------------*
Local oDlg, nOp:=0
Private cTipo:=Space(30)

   DEFINE MSDIALOG oDlg TITLE STR0010 ; //"Comprovacao do Ato Concessorio"
                 FROM 05,05 To 20,55 /*12,05 To 20,50*/ OF GetwndDefault()  // GFP - 27/09/2011 - Ajuste de janela para servir as versões 11.0 e 11.5

      oPanel:= TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.) //LGS-09/12/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      cTipo := "3 - " + STR0011  //STR0011->"Todos"
      @02,05 ComboBox oCbx Var cTipo Items {"1 - "+ STR0012,"2 - "+STR0013,"3 - "+STR0011} Valid (!Empty(cTipo)) SIZE 100,100 of oPanel //#STR0012->"Importação/Compras Nacionais" ##STR0013->"Exportação/Vendas Nacionais" ###STR0011->"Todos"

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()}) CENTERED

   If nOp=1
      nMarcas := nMarcados
      Processa({|| lRet:=RU150Grava()})
   ElseIf nOp=0
      lRet := .F.
   EndIf

Return lRet
