#INCLUDE "Eicip300.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"



#DEFINE  SI              '1S'
#DEFINE  PO              '2P'
#DEFINE  GI              '3G'
#DEFINE  DI              '4D'
#DEFINE  TUDO            '5T'

#DEFINE  ESPACO1         " "
#DEFINE  ESPACO2         "  "
#DEFINE  Show_Rel_Lin    14
#DEFINE  Show_Rel_Len    78
#DEFINE  NUM_REC_CAB      6
#DEFINE  TRACO_DEITADO   "-"

#COMMAND  OLDSET =>  DBGOTO(OldRec) ; RETURN .F.
#COMMAND E_RESET_AREA => SYM->(DBSETORDER(1));SYN->(DBSETORDER(1));SY9->(DBSETORDER(1));
                       ; SYI->(DBSETORDER(1));SYH->(DBSETORDER(1));SYQ->(DBSETORDER(1));
                       ; SYT->(DBSETORDER(1));SY6->(DBSETORDER(1));SYL->(DBSETORDER(1));
                       ; SYO->(DBSETORDER(1));SW8->(DBSETORDER(1));SW0->(DBSETORDER(1));
                       ; SW1->(DBSETORDER(1));SW2->(DBSETORDER(1));SW3->(DBSETORDER(1));
                       ; SW4->(DBSETORDER(1));SW5->(DBSETORDER(1));SW6->(DBSETORDER(1));
                       ; SW7->(DBSETORDER(1))
#DEFINE  IT_PENDENTES    '1'
#DEFINE  FOLLOW_UP       '2'
#DEFINE  SIs             STR0001 //"S.I.s"
#DEFINE  POs             STR0002 //"P.O.s"
#DEFINE  GIs             STR0003 //"G.I.s"
#DEFINE  DIs             STR0004 //"D.I.s"
#DEFINE  TODAS           STR0005 //"Todas"
#DEFINE  EM_ABERTO       STR0006 //"Em aberto "
#DEFINE  ENTREGUES       STR0007 //"Entregues "
#DEFINE  LINHA1              5

#DEFINE GetType(X,xType) IF(xType="N",VAL(ALLTRIM(X)),;
                            IF(xType="D",AVCTOD(LEFT(X,If(IsYear4(),10,8))),;
                               X))

#DEFINE SaveType(X,xType) IF(xType="N",STR(X),IF(xType="D",DTOC(X),X))

#DEFINE LEN_STATUS       IF(POpcaoRel # FOLLOW_UP,33,36)
#DEFINE LEN_STATUS_R     IF(POpcaoRel # FOLLOW_UP,22,28)
#DEFINE COL_STATUS       47
#DEFINE COL_FORM         02



#XTRANSLATE :NOME       => \[1\]
#XTRANSLATE :CONTEUDO   => \[2\]

#XTRANSLATE :INICIAL    => \[2\]
#XTRANSLATE :FINAL      => \[3\]
#XTRANSLATE :TOTALIZA   => \[3\]

#XTRANSLATE :fQTDE      => \[1\]
#XTRANSLATE :fSALDO_Q   => \[2\]
#XTRANSLATE :fPRECO     => \[3\]
#XTRANSLATE :fFOB_TOT   => \[4\]
#XTRANSLATE :fCAMPO     => \[5\]

#XTRANSLATE :POSICAO    => \[1\]
#XTRANSLATE :PICT       => \[2\]
#XTRANSLATE :IMPRIME    => \[3\]
#XTRANSLATE :ALINHA     => \[4\]
#XTRANSLATE :ORDENA     => \[5\]
#XTRANSLATE :SALTAQ     => \[6\]
#XTRANSLATE :TOTALQ     => \[7\]
#XTRANSLATE :TOTALG     => \[8\]

#DEFINE     C_QTDE      "QTDE"
#DEFINE     C_SALDO_Q   "SALDO_Q"
#DEFINE     C_PRECO     "PRECO"
#DEFINE     C_FOB       "FOB"
#DEFINE     C_INLAND    "INLAND"
#DEFINE     C_PACKING   "PACKING"
#DEFINE     C_DESCONTO  "DESCONT"
#DEFINE     C_FRETEINT  "FRETEIN"
#DEFINE     C_FOB_TOT   "FOB_TOT"
#DEFINE     C_OUT_DESP  "OUTDESP"

#DEFINE     C_SALTAQ    "S"
#DEFINE     C_TOTALQ    "T"
#DEFINE     C_MSGPESQ   STR0008 //"PESQUISANDO "
#DEFINE     C_MSGAGUARD STR0009 //" - AGUARDE..."

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICIP300 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 23/07/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gerador de Relatorios - Easy Finder                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICIP300
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL i:=1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()
PRIVATE cDelFunc,lCopia:=.F.//Variavel para controle da Copia
PRIVATE nCont:=0 //Utilizado na função GRAVA_IP000()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0016) //"Pesquisa de Processos"
PRIVATE cTitulo   := OemtoAnsi(STR0017) //"Gerador de Consultas"

PRIVATE aCampos   :={}

PRIVATE bSeek :={||SYM->(DBSEEK(xFilial()+SYL->YL_COD)) }
PRIVATE bWhile:={||xFilial("SYM") == YM_FILIAL  .AND. ;
                   SYM->YM_COD = SYL->YL_COD }, bFor:={||.T.}

// Variaveis definidas para atualizacao no IP150ROT
PRIVATE T_TabObs[21] , T_TabUSD[21], MInterrompe:=MAbandona:=.F., TObs , MQtde
PRIVATE cNextCol, aStatus:=ARRAY(LEN(T_TabObs)), POpcaoRel:=IT_PENDENTES

// Variaveis definidas apenas para validacao no IP150ROT
PRIVATE TIndice:=TArquivo:=TCCusto:=TNr_POI:=TNr_POF:=TComprador:=0,;
       MTemForn:=.F.,TCliente:=0, MInterrompe:=.F., MTot_FOB_US:=0

// Variaveis definidas para uso no Gerador
PRIVATE aRelCab[7], aRelCols:={}, nRelCol, cProcessos, TPrinter, nColPrint, ;
        TFormPeq, TPapel, TLinhas, TFonteC

PRIVATE cAlias := "SYL"

PRIVATE aCamposDic:={ {"YM_CAMPO","C",10,0},{"YM_CTIPO","C",1,0},;
                      {"YM_CTAMA","N",03,0},{"YM_CDECI","N",2,0},;
                      {"RECNO"   ,"N",05,0},{"COLUNOU" ,"L",1,0} }

//** Atualização de incializadores dos campos
AtuCampos()
//Tabelas referentes a rotina da Manutenção de Proformas
PRIVATE lNewProforma := ChkFile("EYZ") .AND. ChkFile("EW0")                        

IP150FillTab()  ; AFILL(T_TabUSD, 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis com nome dos campos de Bancos de Dados        ³
//³ para serem usadas na funcao de inclusao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SYL->(E_InitVar())

E_INIT()//ASK 04/03/2008

DbSelectArea("SYL")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT
DbSelectArea("SYM")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

_PictPO   := AVSX3("W2_PO_NUM",6) 
_PictItem := AVSX3("B1_COD",6) 
_PictPGI  := AVSX3("W4_PGI_NUM",6)
_PictGI   := AVSX3("W4_GI_NUM",6) 
_PictSI   := AVSX3("W0__NUM",6) 
_PictLc   := AVSX3("YH_LC_NUM",6)
aCampos:=ARRAY(FCOUNT())

PRIVATE aPos:= { 15,  1, 70, 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SYL")

E_RESET_AREA

DbSelectArea("SX3")
Return .T.                  

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 06/02/07 - 11:32
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0010 ,"AxPesqui"   , 0 , 1},; //"Pesquisar"
                    { STR0011 ,"IP300Visual", 0 , 2},; //"Visual"
                    { STR0012 ,"IP300Inclui", 0 , 3},; //"Inclui"
                    { STR0013 ,"IP300Altera", 0 , 4, 20 },; //"Altera"
                    { STR0014 ,"IP300Deleta", 0 , 5},; //"Exclui"
                    { STR0015 ,"IP300Gera"  , 0 , 6  } ,; //"Gera‡ao"
                    { STR0071 ,"IP300Copia"  , 0 , 7, , .F.  } } //"Copia"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IIP300MNU")
	aRotAdic := ExecBlock("IIP300MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IP300Visua³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 23.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao dos campos do relatorio         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void IP300Visual(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IP300Visual(cAlias,nReg,nOpc)

LOCAL nOpca := 0
LOCAL oDlg, oGet, nMeio
LOCAL cAlias1:="SYM", cNomArq, cIndice2
LOCAL oEnch1   // ACSJ - 18/05/2004 - Ajustes de telas (MDI)
Local aCpsWk := {}

PRIVATE aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

PRIVATE aHeader[0]

dbSelectArea(cAlias1)
SYM->(dbSetOrder(1))
SYM->(dbSeek(xFilial()+SYL->YL_COD))

If SYM->(EOF())
   Help(" ",1,"EICSEMCAMP")
   Return .T.
Endif

aAdd(aCpsWk,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
cNomArq:=E_CriaTrab(cAlias1,aCpsWk)
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YM_COLUNA")

cIndice2:=E_Create({},.F.)
IndRegua("TRB",cIndice2+TEOrdBagExt(),"YM_TIT_ORI")

Set Index To (cNomArq+TEOrdBagExt()),(cIndice2+TEOrdBagExt())

If ! E_GravaTRB(cAlias1,bSeek,bFor,bWhile)
   Help(" ",1,"IP300SEMIT")
   TRB->(E_EraseArq(cNomArq,cIndice2))
   Return .T.
Endif

While .T.

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTitulo;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL

   nMeio  :=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
   aPos[3]:=nMeio-1 
   aPos[4]:=(oDlg:nClientWidth-2)/2 
   
   //EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3 )
   oEnCh1 := MSMGet():New( cAlias, nReg, nOpc, , , , , aPos, , 3 ) // ACSJ - 18/05/2004 - Ajustes de telas (MDI)
   
   dbSelectArea("TRB")
   TRB->(DBSetOrder(0))    // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                           // ACSJ - 18/05/2004 - conforme Microsiga.

   dbGoTop()          
   oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2,nOpc,"IP300LinOk","IP300TudOk","",.T., , ,.T., ,"TRB")
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}

//   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},;
//                                                   {||oDlg:End()})

   oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()}, {||oDlg:End()}))   // ACSJ - 18/05/2004 - Ajustes de telasv (MDI) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                                  
   Exit

Enddo

TRB->(E_EraseArq(cNomArq,cIndice2))
dbSelectArea(cAlias)

Return( nOpca )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IP300Inclu³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para inclusao de Orcamentos.            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void IP300Inclui(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IP300Inclui(cAlias,nReg,nOpc)

LOCAL nOpca := 0,lGravaOk := .T.,i
LOCAL cAlias1:="SYM", cNomArq, cIndice2
LOCAL oDlg , oGet
LOCAL oEnch1   // ACSJ - 18/05/2004 - Ajustes de telas (MDI)

PRIVATE aTela[0][0],aGets[0],aHeader[0]
PRIVATE bArqF3, bCpoF3, nRegSYL

nRegSYL:=NIL
dbSelectArea(cAlias)
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
NEXT i

If aScan(aCamposDic,{|x| Upper(x[1]) == "DBDELETE"}) == 0
    aAdd(aCamposDic,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
EndIf
cNomArq :=E_CriaTrab(cAlias1,aCamposDic)
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YM_COLUNA")

cIndice2:=E_Create({},.F.)
IndRegua("TRB",cIndice2+TEOrdBagExt(),"YM_TIT_ORI")

Set Index To (cNomArq+TEOrdBagExt()),(cIndice2+TEOrdBagExt())

AFILL(aStatus,.T.)
If lCopia
   Ip300GrvCopia(cNomArq)
EndIf   

nOpca := 0
Continua := .F.

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cTitulo;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL 

nMeio  :=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
aPos[3]:=nMeio-1 
aPos[4]:=(oDlg:nClientWidth-2)/2 

//EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3 )
oEnCh1 := MSMGet():New( cAlias, nReg, nOpc, , , , , aPos, , 3 ) // ACSJ - 18/05/2004 - Ajustes de telas (MDI)

dbSelectArea("TRB")
TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                       // ACSJ - 18/05/2004 - conforme Microsiga.

TRB->(oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2,IF(!lCopia,3,4),"IP300LinOk","IP300TudOk","",.T., , ,.T., ,"TRB"))
oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}

//ACTIVATE MSDIALOG oDlg ON INIT ;
//     EnchoiceBar(oDlg,{||nOpca:=1,If(Obrigatorio(aGets,aTela) .And. IP300Valdt("F"),oDlg:End(),)},{||oDlg:End()})

oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| nOpca:=1, If(Obrigatorio(aGets,aTela) .And. ValidCombo() .And. IP300Valdt("F") .and. IP300VerStatus(),;
                                oDlg:End(),)},{||oDlg:End()}))  // ACSJ - 18/05/2004 - Ajustes de telas (MDI) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

If nOpcA == 1
   Begin Transaction
      lGravaOk := IP300Grava(cAlias,cAlias1,.T.)
      If !lGravaOk
         Help(" ",1,"A110NAOREG")
      Else
         //Processa Gatilhos
         EvalTrigger()
         If __lSX8
            ConfirmSX8()
         Endif
      EndIf
   End Transaction
ElseIf __lSX8
   RollBackSX8()
Endif

TRB->(E_EraseArq(cNomArq,cIndice2))

dbSelectArea(cAlias)

Return( nOpcA )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IP300Alter³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para alteracao de Or‡amentos.           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void IP300Altera(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IP300Altera(cAlias,nReg,nOpc)
LOCAL nOpca := 0,lGravaOk:=.T.
LOCAL cCliOld,nMeio
LOCAL cAlias1:="SYM", cNomArq, cIndice2 , i
LOCAL oEnch1   // ACSJ - 18/05/2004 - Ajustes de telas (MDI)

PRIVATE oDlg, oGet, nRegSYL

PRIVATE aTELA[0][0],aGETS[0],aHeader[0]

nRegSYL:=SYL->(recno())

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

If !SoftLock(cAlias)
   Return .T.
Endif

FOR i := 1 TO FCount()
    M->&(FieldName(i)) := FieldGet(i)
NEXT i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aScan(aCamposDic,{|x| Upper(x[1]) == "DBDELETE"}) == 0
    aAdd(aCamposDic,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
EndIf
cNomArq :=E_CriaTrab(cAlias1,aCamposDic)
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YM_COLUNA")

cIndice2:=E_Create({},.F.)
IndRegua("TRB",cIndice2+TEOrdBagExt(),"YM_TIT_ORI")

Set Index To (cNomArq+TEOrdBagExt()),(cIndice2+TEOrdBagExt())

If !E_GravaTRB(cAlias1,bSeek,bFor,bWhile,aCamposDic,{|_rec|TRB->RECNO:=_rec})
   Help(" ",1,"IP300SEMIT")
   TRB->(E_EraseArq(cNomArq,cIndice2))
   dbSelectArea(cAlias)
   Return .T.
Endif

TRB->(DbSetOrder(1))
aStatus:=IP300Status(.T.,0)
IP300NextCol()

nOpca := 0
Continua := .F.
lTab := .T.

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cTitulo;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL 

nMeio  :=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
aPos[3]:=nMeio-1 
aPos[4]:=(oDlg:nClientWidth-2)/2

//EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3 )
oEnCh1 := MSMGet():New( cAlias, nReg, nOpc, , , , , aPos, , 3 ) // ACJS - 18/05/2004 - Ajustes de telas (MDI)

dbSelectArea("TRB")
TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                       // ACSJ - 18/05/2004 - conforme Microsiga.

dbGoTop()
oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2,nOpc,"IP300LinOk","IP300TudOk","",.T., , ,.T., ,"TRB")
oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}

//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(Obrigatorio(aGets,aTela) .And. IP300TudOk() .And. IP300ValDt("F"),oDlg:End(),)},{||oDlg:End()})

oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1, If(Obrigatorio(aGets,aTela) .And. /*ValidCombo().And.*/ IP300TudOk() .And.;
                                IP300ValDt("F") .and. IP300VerStatus() ,;
                                oDlg:End(),)},{||oDlg:End()})) // ACSJ - Ajustes de telas (MDI) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

If nOpcA == 1
   Begin Transaction
      lGravaOk := IP300Grava(cAlias,cAlias1,.F.)
      If !lGravaOk
         Help(" ",1,"A110NAOREG")
      Else
         //Processa Gatilhos
         EvalTrigger()
         If __lSX8
            ConfirmSX8()
         Endif
      EndIf
   End Transaction
ElseIf __lSX8
   RollBackSX8()
Endif

TRB->(E_EraseArq(cNomArq,cIndice2))
dbSelectArea(cAlias)
(cAlias)->(MSUNLOCK())

Return( nOpca )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IP300Delet³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de exclusao de Orcamentos                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void IP300Deleta(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IP300Deleta(cAlias,nReg,nOpc)

LOCAL nOpca := 0
LOCAL oDlg, oGet, nMeio
LOCAL cAlias1:="SYM", cNomArq
LOCAL oEnch1    // ACSJ - 18/05/2004 - Ajustes de telas (MDI)

PRIVATE aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aHeader[0],Continua, nNumLin:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aScan(aCamposDic,{|x| Upper(x[1]) == "DBDELETE"}) == 0
    aAdd(aCamposDic,{"DBDELETE","L",1,0}) //THTS - 01/11/2017 - Este campo deve sempre ser o ultimo campo da Work
EndIf
cNomArq :=E_CriaTrab(cAlias1,aCamposDic)
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YM_COLUNA")

If ! E_GravaTRB(cAlias1,bSeek,bFor,bWhile)
   Help(" ",1,"IP300SEMIT")
   TRB->(E_EraseArq(cNomArq))
   dbSelectArea(cAlias)
   Return .T.
Endif

While .T.

   nOpca := 0
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTitulo;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL

   nMeio  :=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
   aPos[3]:=nMeio-1 
   aPos[4]:=(oDlg:nClientWidth-2)/2

//   EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3 )
   oEnCh1 := MSMGet():New( cAlias, nReg, nOpc, , , , , aPos, , 3 ) // ACSJ - 18/05/2004 - Ajustes de telas (MDI)
   
   lTab   := .T.

   dbSelectArea("TRB")
   TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                          // ACSJ - 18/05/2004 - conforme Microsiga.
                          
   dbGoTop()
   oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2,nOpc,"IP300LinOk","IP300TudOk","",.T., , ,.T., ,"TRB")
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
   
//   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=2,oDlg:End()},{||nOpcA:=1,oDlg:End()})

   oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Refresh()  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=2,oDlg:End()},{||nOpcA:=1,oDlg:End()}))   // ACSJ - 18/05/2004 - Ajustes de telas (MDI) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                                                         
   
   
   IF nOpcA == 1
      Exit

   ELSEIF nOpcA == 2
      Begin Transaction
         dbSelectArea( cAlias1 )
         dbSeek(xFilial(cAlias1)+SYL->YL_COD)
         nCnt := 0

         While !SYM->(Eof()) .And. SYM->YM_FILIAL == xFilial("SYM") .And.;
               SYL->YL_COD = SYM->YM_COD
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Apagar Colunas        e                             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            RecLock(cAlias1,.F.)
            dbDelete()
            MSUNLOCK()
            nCnt++
            dbSkip()
         Enddo

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Apaga o cabecalho: Gerador                          ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         dbSelectArea("SYL")
         RecLock("SYL",.F.)
         dbDelete()
         MSUNLOCK()

         dbSelectArea( cAlias1 )
      End Transaction
      Exit
   Endif
Enddo

TRB->(E_EraseArq(cNomArq))
dbSelectArea(cAlias)

Return( nOpca )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IP300Grava³ Autor ³ PADRAO GETDADDB       ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as nformacoes nos arquivos SZ1 e SW2.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICIP300                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IP300Grava(cAlias,cAlias1,lInclui)
LOCAL nX, nMaxArray, nCntDel:=0
LOCAL xVar, BVar:={||.t.}
LOCAL nInd, TStatus, TStatusP, TAberto, TEntreg , ny

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de itens                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoBottom()
nMaxArray := EasyRecCount("TRB")
For ny := 1 to Len(aHeader)
    If  Empty(FieldGet(ny))
        If Trim(aHeader[ny][2]) == "YM_COLUNA"  .Or.;
           Trim(aHeader[ny][2]) == "YM_TIT_ORI"
           nMaxArray--
           Exit
        EndIf
    Endif
Next ny

If nMaxArray <= 0
   Return .F.
Endif

dbGoTop()
While !EoF()
   If FieldGet(FCount())
      nCntDel++
   Endif
   dbSkip()
Enddo

If nCntDel >= nMaxArray
   Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SYM (Tarifas de Frete)                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
TRB->(DBGOTOP())

WHILE ! TRB->(EOF())

    If Empty(TRB->YM_TIT_ORI)
       TRB->(DBSKIP()) ; LOOP
    Endif

    IF !Empty(TRB->RECNO)
       SYM->(DbGoTo(TRB->RECNO))
       RecLock(cAlias1,.F.)
    ELSEIF ! TRB->DBDELETE
       RecLock(cAlias1,.T.)  // bloqueia e incluir registro vazio
       SYM->YM_FILIAL := xFilial("SYM")
    ENDIF

    IF TRB->DBDELETE
       IF !Empty(TRB->RECNO) // SYM->(FOUND())
          SYM->(DBDELETE())
          SYM->(MSUNLOCK())
       ENDIF
       TRB->(DBSKIP())
       LOOP
    ENDIF

    For ny := 1 to Len(aHeader)
        xVar:=AllTrim(aHeader[ny][2])
        If "FILIAL" $ xVar  // Ja gravou a filial
           Loop
        Endif
        bVar:=FIELDWBLOCK(xVar,SELECT(cAlias1))
        If aHeader[ny][10] # "V"
           EVAL(bVar,EVAL(FIELDWBLOCK(xVar,SELECT("TRB"))))
        Endif
    Next ny

    SYM->YM_COD  :=M->YL_COD
    SYM->YM_CAMPO:=TRB->YM_CAMPO
    SYM->YM_CTIPO:=TRB->YM_CTIPO
    SYM->YM_CTAMA:=TRB->YM_CTAMA
    SYM->YM_CDECI:=TRB->YM_CDECI

    SYM->(MSUNLOCK())
    TRB->(DBSKIP())
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SYL ( Cabecalho do Gerador )                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbsetorder(1)

If SYM->(DbSeek(xFilial("SYM")+M->YL_COD))
   IF !lCopia
      IF(!lInclui,SYL->(dbgoto(nRegSYL)),)
      E_Grava(cAlias,Inclui,{||IP300GrvStatus()})
   Else
      E_Grava(cAlias,.T.,{||IP300GrvStatus()})   
   EndIf   
Else
   RecLock(cAlias,.F.,.T.)
   SYL->(DBDELETE())
   SYL->(MSUNLOCK())
Endif

Return( .T. )
*----------------------------------------------------------------------------
Function IP300GrvStatus()
*----------------------------------------------------------------------------
TAberto :=( SYL->YL_ABERTO $ cSim )
TEntreg :=( SYL->YL_ENTREG $ cSim )
TStatusP:=( SYL->YL_STATUSP$ cSim )

/*** JWJ 04/01/2007
IF ! TAberto .AND. ! TEntreg   // se nenhuma das duas foi informada
     TAberto:=.T.              // assume-se a opcao mais generica
     AFILL(aStatus,.T.)
     TStatusP:=.T.
ENDIF*/

IF POpcaoRel = FOLLOW_UP .AND. ATAIL(aStatus) // selecionou opcao geral
   AFILL(aStatus,.T.)
ENDIF
/* Nopado por GFP - 31/08/2015
IF ! TAberto
  AFILL(aStatus,.F.)
  TStatusP:=.F.
ELSEIF ASCAN(aStatus,.T.) = 0
  TStatusP:=.F.
ENDIF
*/
TStatus:=""
AEVAL(aStatus,{|True| TStatus+=IF(True,"T","F")})

SYL->YL_ABERTO := If(TAberto,"1","2")
SYL->YL_STATUS := TStatus
//SYL->YL_STATUSP:= If(TStatusP,"1","2")

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IP300LinOk³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas do Orcamento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = IP300LinOk                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function IP300LinOk(o)
Local lRet := .T. 
DbSelectArea("TRB")
// Fazer as consistencias especiais

IF TRB->DBDELETE
   If IP300DelCol(TRB->YM_COLUNA)            // acerta o numero das colunas
      cNextCol:= StrZero(Val(TRB->YM_COLUNA)-1,2)
   Endif
   RETURN lRet
ENDIF

If TRB->COLUNOU                     // estava deletado e foi recuperado
   IP300NextCol()
   IP300SetCol(.F.,TRB->YM_COLUNA)
   TRB->COLUNOU:=.F.
Endif

If Empty(YM_COLUNA) .Or. Val(YM_COLUNA) = 0 .Or. Len(Trim(YM_COLUNA)) < 2
   HELP("",1,"AVG0002061")//N£mero da Coluna Inv lido
   Return .F.
Endif

If Empty(YM_TIT_ORI)
   HELP("",1,"AVG0002062")//Nome do Campo nÆo informado
   Return .F.
Endif

If At(YM_ORDENAR,"SN") = 0 .Or. At(YM_SALTAQ,"SN")  = 0 .Or. ;
   At(YM_TOTALQ,"SN")  = 0 .Or. At(YM_TOTALG,"SN")  = 0
   HELP("",1,"AVG0002063")//Colunas "Ordenar ?","Salta Quebr?","Total Quebr" e "Total Geral" diferentes de "S" (Sim) e "N" (Nao)
   lRet:=.F.
Endif

If At(YM_IMPRIME,"SNQ") = 0
   HELP("",1,"AVG0002064")//Colunas "Imprimir ?" diferentes de "S" (Sim), "N" (Nao) e "Q" (somente na quebra)
   lRet:=.F.
Endif

Return( lRet )

*----------------------------------------------------------------------------
Function IP300TudOk(o)
*----------------------------------------------------------------------------
TRB->(DbGoTop())

While ! TRB->(Eof())
   If TRB->DBDELETE
      IP300DelCol(TRB->YM_COLUNA)
      Return .T.
   Endif
   If TRB->COLUNOU      // estava deletado e foi recuperado
      IP300NextCol()    // pega o numero da proxima coluna
      IP300SetCol(.F.,TRB->YM_COLUNA)
      Return .T.
   Endif

   TRB->(DbSkip())
Enddo
Return .T.
*----------------------------------------------------------------------------
FUNCTION IP300Valid()  // CHAMADA A PARTIR DO SX3
*----------------------------------------------------------------------------
LOCAL cCampo := Subs(ReadVar(),4),lRet:=.T., nInd, xVar
LOCAL uData  := &(Readvar()), nRec:=TRB->(RecNo())

DO CASE
   CASE cCampo == "YM_COLUNA"
//        TRB->(DbSetOrder(1))

        lAlteracao:=(!Empty(TRB->RECNO))

// rejeita em caso de erro ja que nao ‚ possivel corrigir a propria coluna
// neste momento, pois nao ha acesso ao objeto GET

        If Empty(uData) .Or. Val(uData) = 0 .Or. Len(Trim(uData)) < 2 .Or. ;
           (uData = cNextCol .And. lAlteracao)
           HELP("",1,"AVG0002061")//N£mero da Coluna Inv lido
           Return .F.
        ElseIf uData > cNextCol
           HELP("",1,"AVG0002065")//Pr¢xima Coluna deve ser 
           Return .F.
        Endif

        IP300SetCol(lAlteracao,uData)

   CASE cCampo == "YM_TIT_ORI"

        TRB->(DbSetOrder(2))

        If TRB->(DbSeek(uData)) .And. TRB->(RecNo()) # nRec .AND. ;
          !TRB->DBDELETE
           HELP(" ",1,"JAGRAVADO")
           TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                                  // ACSJ - 18/05/2004 - conforme Microsiga.
           
           lRet:=.F.
        Endif

        TRB->(DbSetOrder(1))
        TRB->(DbGoTo(nRec))

        If lRet
           If Empty(uData)
              HELP(" ",1,"OBRIGAT")
              TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                                     // ACSJ - 18/05/2004 - conforme Microsiga.
                            
              lRet:=.F.
           Elseif Empty(TRB->YM_TITULO) .Or. ;
                (!Empty(TRB->YM_TIT_ORI) .And. uData # TRB->YM_TIT_ORI)
                  SYN->(dbsetorder(1))
                  If ! SYN->(DbSeek(xFilial()+uData))
                     HELP("",1,"AVG0002066",,uData+STR0026+STR(LEN(UDATA),3,0),1,06)//"Campo "
                     TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                                            // ACSJ - 18/05/2004 - conforme Microsiga.
                     
                     lRet:=.F.
                  Else
                     TRB->YM_TITULO:=uData
                     TRB->YM_PICT  :=IP300GetPict(SYN->YN_PICT,SYN->YN_CTIPO)
                     TRB->YM_CAMPO :=SYN->YN_CAMPO
                     TRB->YM_CTIPO :=SYN->YN_CTIPO
                     TRB->YM_CTAMA :=SYN->YN_CTAMA
                     TRB->YM_CDECI :=SYN->YN_CDECI
                  Endif
           Endif
        Endif
        TRB->(DBSetOrder(0))  // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                              // ACSJ - 18/05/2004 - conforme Microsiga.

   CASE cCampo == "YM_INTER_F"

        If uData < TRB->YM_INTER_I
           HELP("",1,"AVG0002067")//Intervalo final menor que inicial
           lRet:=.F.
        Endif


   CASE cCampo == "YM_ORDENAR" .Or. cCampo == "YM_SALTAQ" .Or. ;
        cCampo == "YM_TOTALQ"  .Or. cCampo == "YM_TOTALG"

        If At(uData,"SN") = 0
           HELP("",1,"AVG0002068") //Conte£do deve ser "S" (Sim) ou "N" (NÆo)
           lRet:=.F.
        Endif

   CASE cCampo == "YM_IMPRIME"

        If At(uData,"SNQ") = 0
           HELP("",1,"AVG0002069") //Conte£do deve ser "S" (Sim) ,"N" (NÆo) ou "Q" (somente na quebra)
           lRet:=.F.
        Endif

   CASE cCampo == "YM_ALINHA"

        If At(uData,"EDC") = 0
           HELP("",1,"AVG0002070") //Conte£do deve ser "E" (Esquerda), "D" (Direita) ou "C" (Centro)
           lRet:=.F.
        Endif
Endcase
Return lRet
*----------------------------------------------------------------------------
Function IP300SetCol(lAlteracao,cColuna)
*----------------------------------------------------------------------------
LOCAL cSaveCol:=If(lAlteracao,TRB->YM_COLUNA,cNextCol), nRec:=TRB->(RecNo())
LOCAL nCol, nColIni, nColFim, nSoma
TRB->(DbSetOrder(1))
//msginfo(" cColuna "+cColuna+" csavecol "+csavecol+" cnextcol "+cnextcol)
If cColuna = cSaveCol
   TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                          // ACSJ - 18/05/2004 - conforme Microsiga.
   
   Return
Endif

If cColuna > cNextCol
   cColuna:= If(Empty(cSaveCol), StrZero(Val(TRB->YM_COLUNA)+1,2),cNextCol)
Endif

If TRB->(DbSeek(cColuna)) .Or. Empty(cColuna) .OR. Empty(cSaveCol)

   If ! Empty(cColuna) .AND. ! Empty(cSaveCol)
      nColFim:=Val(cColuna)
      nSoma:=1
      If lAlteracao
         If cColuna > cSaveCol
            nSoma:=-1
         Endif
         nColIni:=Val(cSaveCol) + (-1*nSoma)
      Else
         nColIni:=Val(cNextCol) - 1
      Endif
   Else
      If cColuna > cSaveCol
         nColIni:=Val(cNextCol)
         nColFim:=Val(cColuna)
         nSoma:=1
      Else
         nColIni:=Val(cSaveCol) + 1
         nColFim:=Val(cNextCol)
         nSoma:=-1
      Endif
   Endif
// msginfo("col i "+str(ncolini,2)+" col f "+str(ncolfim,2)+" step "+str(-1*nSoma,3,0))
   For nCol:=nColIni To nColFim STEP (-1*nSoma)
       If TRB->(DbSeek(Padl(nCol,2,"0")))
          While TRB->DBDELETE .And. ! Eof()   // despreza coluna deletadas
                TRB->(DbSkip())
          Enddo
          If TRB->YM_COLUNA = StrZero(nCol,2)
             TRB->YM_COLUNA:= StrZero(nCol+nSoma,2)
          Endif
       Endif
   Next
Endif               

TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                       // ACSJ - 18/05/2004 - conforme Microsiga.

TRB->(DbGoto(nRec))
*----------------------------------------------------------------------------
Function IP300DelCol(cCol)
*----------------------------------------------------------------------------
LOCAL nRec:=TRB->(RecNo()), nCol:=Val(cCol)+1

TRB->(DBSetOrder(1))

If TRB->COLUNOU
   Return .F.
Endif
While TRB->(DbSeek(StrZero(nCol,2)))
      TRB->YM_COLUNA:=StrZero(Val(TRB->YM_COLUNA)-1,2)
      ++nCol
Enddo

TRB->(DbGoTo(nRec))
TRB->COLUNOU:=.T.
//oGet:Refresh()
TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                       // ACSJ - 18/05/2004 - conforme Microsiga.

Return .T.

*----------------------------------------------------------------------------
Function IP300NextCol()     // CHAMADA TAMBEM A PARTIR DO SX3
*----------------------------------------------------------------------------
Local nRec:=TRB->(RecNo())
cNextCol:=""

TRB->(DbSetOrder(1))

If !TRB->(Eof() .And. Bof())
   TRB->(DbGoBottom())
   While !TRB->(Bof())
      If !TRB->DBDELETE
         cNextCol:= StrZero(Val(TRB->YM_COLUNA)+1,2)
         Exit
      Endif
      TRB->(DbSkip(-1))
   Enddo
   TRB->(DbGoTo(nRec))
Endif

If Empty(cNextCol)
   cNextCol:= "01"
Endif               

TRB->(DBSetOrder(0))   // ACSJ - 18/05/2004 - Volta o indice a ordem natural por exigencia da função MSGETDB(V811)
                       // ACSJ - 18/05/2004 - conforme Microsiga.

Return cNextCol

*----------------------------------------------------------------------------
FUNCTION IP300GetPict(cPictDet,cTipo)
*----------------------------------------------------------------------------
PRIVATE cPict:=ALLTRIM(cPictDet)

IF ! EMPTY(cPict)
   DO CASE
      CASE LEFT(cPict,1) = '_'
          RETURN ( &cPict. )

      CASE AT('@',cPict) # 0
          RETURN ( cPict )

      CASE cTipo='C'
          RETURN ( IF(AT('9',cPict) # 0,'@R '+cPict,cPict) )

      CASE cTipo='N'
          RETURN ( IF(AT(',',cPict) # 0,'@E '+cPict,cPict) )
   ENDCASE

ELSEIF cTipo = 'D'
   RETURN ( '@D' )
ELSE
   RETURN "" // NIL
ENDIF
*----------------------------------------------------------------------------
FUNCTION IP300ValDt(cQual)  // CHAMADA A PARTIR DO SX3
*----------------------------------------------------------------------------
If M->YL_ENTREG $ cSim

   IF EMPTY(M->YL_DTE_I)
      HELP("",1,"AVG0002071") //Data Inicial nÆo Informada
      RETURN .F.
   ENDIF

   IF cQual == "F"
      IF EMPTY( M->YL_DTE_F ) .AND. !EMPTY(M->YL_DTE_I)
         HELP("",1,"AVG0002072") //Data Final nÆo Informada
         RETURN .F.
      ELSEIF M->YL_DTE_I > M->YL_DTE_F
         HELP("",1,"AVG0002073") //Data Inicial maior que data final
         RETURN .F.
      ENDIF
   ENDIF

Else
   If (cQual = "I" .And. ! Empty(M->YL_DTE_I)) .Or. ;
      (cQual = "F" .And. ! Empty(M->YL_DTE_F))
//      MSGINFO(OemToAnsi(STR0034),OemToAnsi(STR0019)) //"Intervalo de datas p/ processos entregues nÆo informado"###"Informa‡Æo"
      HELP("",1,"AVG0002074")//Data deve ser informada apenas p/ processos entregues
      Return .F.
   Endif
Endif
Return .T.
*--------------------------------------------------------------------------------------------------
Function ValidCombo() //TRP -17/09/07 - Valida o combo Origem para processos entregues e encerrados
*--------------------------------------------------------------------------------------------------
Local lRet := .T.
   
If M->YL_ABERTO $ cNao .And. M->YL_ENTREG $ cSim .And. !(M->YL_ORIGEM $ DI)
   
   MsgStop("Esta fase de origem não pode ser escolhida pois o processo já foi entregue e encerrado!")
   lRet := .F.

Endif
Return lRet
*----------------------------------------------------------------------------
FUNCTION IP300VerStatus()  // CHAMADA A PARTIR DO SX3
*----------------------------------------------------------------------------
LOCAL lRet:=.T., oDlgStatus, nCol:=13, nSize:=90
LOCAL cTit:=STR0036+If(M->YL_ORIGEM $ TUDO ,STR0005,; //"Selecao de Status de "###"Todas"
                                    If(M->YL_ORIGEM $ SI   ,STR0001,; //"S.I.s"
                                    If(M->YL_ORIGEM $ PO   ,STR0002,; //"P.O.s"
                                    If(M->YL_ORIGEM $ GI   ,STR0003,STR0004)))) //"G.I.s"###"D.I.s"
Begin Sequence

   If !ValidCombo()  //TRP-17/09/07
      lRet := .F.
      Break
   EndIf

   If M->YL_ORIGEM $ TUDO .Or. M->YL_ORIGEM $ SI

      AFILL(aStatus,.T.)
    
   Else

      DEFINE MSDIALOG oDlgStatus TITLE cTit From 12,01 To 28,39 OF oMainWnd

      @ .3,.3 TO 8.5,14.0

      DEFINE SBUTTON FROM 10,118 TYPE 1 ACTION (oDlgStatus:End()) ENABLE OF oDlgStatus

      DO CASE	
         CASE M->YL_ORIGEM $ PO

              @013,nCol CHECKBOX aStatus[03] PROMPT T_TabObs[03] Of oDlgStatus SIZE nSize,10

         CASE M->YL_ORIGEM $ GI

              @013,nCol CHECKBOX aStatus[03] PROMPT T_TabObs[03] Of oDlgStatus SIZE nSize,10
              @024,nCol CHECKBOX aStatus[05] PROMPT T_TabObs[05] Of oDlgStatus SIZE nSize,10
              @035,nCol CHECKBOX aStatus[06] PROMPT T_TabObs[06] Of oDlgStatus SIZE nSize,10
              @046,nCol CHECKBOX aStatus[07] PROMPT T_TabObs[07] Of oDlgStatus SIZE nSize,10
              @057,nCol CHECKBOX aStatus[08] PROMPT T_TabObs[08] Of oDlgStatus SIZE nSize,10
              @068,nCol CHECKBOX aStatus[09] PROMPT T_TabObs[09] Of oDlgStatus SIZE nSize,10
              @079,nCol CHECKBOX aStatus[10] PROMPT T_TabObs[10] Of oDlgStatus SIZE nSize,10
              @090,nCol CHECKBOX aStatus[20] PROMPT T_TabObs[20] Of oDlgStatus SIZE nSize,10

         CASE M->YL_ORIGEM $ DI

              @013,nCol CHECKBOX aStatus[11] PROMPT T_TabObs[11] Of oDlgStatus SIZE nSize,10
              @024,nCol CHECKBOX aStatus[12] PROMPT T_TabObs[12] Of oDlgStatus SIZE nSize,10
              @035,nCol CHECKBOX aStatus[13] PROMPT T_TabObs[13] Of oDlgStatus SIZE nSize,10
              @046,nCol CHECKBOX aStatus[14] PROMPT T_TabObs[14] Of oDlgStatus SIZE nSize,10
              @057,nCol CHECKBOX aStatus[15] PROMPT T_TabObs[15] Of oDlgStatus SIZE nSize,10
              @068,nCol CHECKBOX aStatus[16] PROMPT T_TabObs[16] Of oDlgStatus SIZE nSize,10
              @079,nCol CHECKBOX aStatus[18] PROMPT T_TabObs[18] Of oDlgStatus SIZE nSize,10
              @090,nCol CHECKBOX aStatus[19] PROMPT T_TabObs[19] Of oDlgStatus SIZE nSize,10
              @101,nCol CHECKBOX aStatus[21] PROMPT T_TabObs[21] Of oDlgStatus SIZE nSize,10
      ENDCase

      ACTIVATE MSDIALOG oDlgStatus

   Endif

End Sequence
Return lRet
*############################################################################
*----------------------------------------------------------------------------
* Programa     : IP300_P
* Autor        : Mario Jorge de Barros
* Data Criacao : 07:21 18 Oct,1995
* Finalidade   : Gravacao de Work para geracao de relatorio
* O.B.S........: UTILIZA IP150ROT E IP151
* Alterado.....: Por Robson para Inclusao de Uma Funcao que gerasse TXT/DATA
*----------------------------------------------------------------------------
*----------------------------------------------------------------------------
FUNCTION IP300Gera()
*----------------------------------------------------------------------------
Local cFilOld := cFilAnt
LOCAL FileWork, cTemQuebra:=" ", oMark
LOCAL aIntervalo:={}, aStatus:={}, aStruWork:={}, aStruNew:={}, cUnidade
LOCAL TB_Campos:={}, aRelDet:={}, nInd, nCampo, nPos, aChave:={}, cCampo
LOCAL TB_Funcoes:= { ;
{"-3",{||TR350Arquivo("Work")},"F4" , STR0037 }  ,; //"Gera Arquivo"
{"-4", {|| IP300Print(aRelDet,cTemQuebra)},"F5",STR0038} } //"Imprime"

LOCAL oPanel   // ACSJ - 18/05/2004 - Ajustes de telas (MDI)
Local nFil     // JWJ - 12/01/2006 - Contador do loop das filiais

Local nArq
PRIVATE aBuffer:={}, cChave
PRIVATE lEmail := .F.

Private cMarca := GetMark(), lInverte := .F. 

Private lEnd:=.F., lGerou:=.T.

Private aTitulos:= {{"Filial" ,"WKFILIAL"     ,"",,,"",,"C"}}
Private cTitArq:= ""
Private aFilSel  // GFP - 14/12/2012   
IF ! SYM->(DBSeek(xFilial()+SYL->YL_COD))
   HELP("",1,"AVG0002075")//"Nenhum Campo foi selecionado"
   RETURN .T.
ENDIF

SYN->(DBSETORDER(2))

//Johann - Acrescentar no array aStruwork e nos outros arrays um campo para multifilial
// TB_Campo e aRelDet, aChave, cTemQuebra

/* TB_Campos */
AADD(TB_Campos, { {||WORK->WKFILIAL+'-'+AvgFilName({WORK->WKFILIAL})[1]},"",AVSX3("W2_FILIAL",5) } )

/* Chave */
//AADD(aChave, {{|nInd| IP300Chave(nInd,1) }, 1})

AADD(aChave,{1,1})

AADD(aBuffer,{"WKFILIAL",,.F.})
//cChave := "WKFILIAL"
AADD(aStruWork, {"WKFILIAL"  ,"C",FWSizeFilial(),0})

// Relatorio e Quebra 
//AADD(aRelDet,{1,"@!",/*YM_IMPRIME*/ "S", /*YM_ALINHA*/ "S",/*YM_ORDENAR*/ .T.,;
//                         /*YM_SALTAQ*/ .T., /*YM_TOTAL*/ .F., /*YM_TOTALG*/ .F.})
                         
                         
//cTemQuebra := "S"   // Nao pode ser incializado com "S", pois se tivermos um relatorio, no qual nao haja nenhuma quebra de campo escolhida pelo usuario

IP300LerDet({|| IP300StruWork(aStruWork,aIntervalo,TB_Campos,aRelDet,;
                              @cTemQuebra,aChave) })

/* aStruWork */


SYN->(DBSETORDER(1))

IF SYL->YL_STATUSP $ cSim
   AADD(aStruWork, {'WKSTATUS','C',LEN_STATUS,0})
   AADD(TB_Campos, {'WKSTATUS','',STR0040}) //'Status'
   AADD(aRelDet,   {LEN(aStruWork),,'S','E',.F.,.F.,.F.,.F.})
ENDIF

aStatus :=IP300Status(.T.)

IP300ShowRel(,.T.,.T.)     // carrega aRelCab e aRelCols

IF POpcaoRel # FOLLOW_UP
   
   If Select("Work") == 0
      FileWork := E_CriaTrab(,aStruWork,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados
   Endif
   
   IF ! USED()
      HELP("",1,"AVG0002076")//NÆo foi poss¡vel abrir o arquivo tempor rio
      Work->(E_EraseArq(FileWork))
      DBSELECTAREA("SYL")
      RETURN
   ENDIF

   //Johann - aqui deve abrir para selecionar a multifilial. Tratar se foi cancelado
   
   // GCC - 03/07/2013 - Alterado para que possa percorrer o SM0 independente da tabela SW0
   aFilSW0:=AvgSelectFil(.T.)

     
   IF aFilSW0[1] == "WND_CLOSE"    // BOTAO CANCELAR???
	    Return .F.
   ENDIF
   
   IP300Indexa(FileWork)
  
   //Fazer um FOR aqui
   //chamar a ItPendentes p/ cada filial selecionada
   //gravar o campo de filial dentro da função
   
   aFilSel := aClone(aFilSW0)    // GFP - 14/12/2012
   
   For nFil := 1 To LEN(aFilSW0)  
      If !Empty(aFilSW0[nFil]) //ASK 
         cFilAnt := aFilSW0[nFil]
      EndIf
      IP300ItPendentes(aStruWork,aIntervalo,aStatus,aChave)
   Next
   
ENDIF

cTitArq:= "Gerador de Relatórios"

For nArq:= 2 to Len(TB_Campos)
   AADD(aTitulos,{TB_Campos[nArq][3],TB_Campos[nArq][1],"",,,"",,"C"})
Next

If lGerou
   IF Work->(Easyreccount("Work")) == 0
      Help(" ",1,"EICSEMREG")
   ELSE
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo);
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	           OF oMainWnd PIXEL
       
       @00,00 MSPanel oPanel Size 20,45 of oDlg   //  ACSJ - 18/05/2004 - Ajustes de telas (MDI)

       @15,(oDlg:nClientWidth-4)/2-85 BUTTON STR0037 SIZE 40,13 FONT oDlg:oFont ACTION (TR350Arquivo("Work",,aTitulos,cTitArq)) OF oPanel PIXEL //"Gera Arquivo"

       DEFINE SBUTTON FROM 15,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (IP300Print(aRelDet,cTemQuebra)) ENABLE OF oPanel

       dbSelectArea("Work")
       dbGoTop()
       oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{34,5,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2})
       
	   oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
       oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	   oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	   
//      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
        ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})) // ACSJ - 18/05/2004 - Ajustes de telas (MDI) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        
   ENDIF
Endif

cFilAnt := cFilOld
Work->(E_EraseArq(FileWork))

DBSELECTAREA("SYL")

RETURN .T.
*-----------------------------------------------------------------------------------
FUNCTION IP300StruWork(aStruWork,aIntervalo,TB_Campos,aRelDet,cTemQuebra,aChave)
*-----------------------------------------------------------------------------------
LOCAL cCampo:=ALLTRIM(YM_CAMPO), cPict, cInter_I, cInter_F, nPos // , bChave

SYN->(DBSeek(xFilial()+SYM->YM_CAMPO))
If SYM->YM_CAMPO == 'WKCOD_I   '
   Reclock("SYM",.F.)
   SYM->YM_CTAMA := 30
   SYM->(MsUnlock())
EndIf

AADD(aStruWork, {cCampo,YM_CTIPO,YM_CTAMA,YM_CDECI })
AADD(aBuffer,   {cCampo,,SYN->YN_TOTAL})
nPos:=LEN(aStruWork)

IF ! EMPTY(YM_INTER_F)
   cInter_I:=GetType(YM_INTER_I,YM_CTIPO)
   cInter_F:=GetType(YM_INTER_F,YM_CTIPO)
   IF YM_CTIPO = 'C'
      cInter_I:=LEFT(cInter_I,YM_CTAMA)
      cInter_F:=LEFT(cInter_F,YM_CTAMA)
   ENDIF

   AADD(aIntervalo,{nPos,cInter_I,cInter_F})
ENDIF

//IF (cPict:=IP300GetPict(YM_PICT,YM_CTIPO)) # NIL .And. !Empty(cPict)
//   cCampo:="TRAN("+cCampo+",'"+cPict+"')"
//ENDIF

cPict:=IP300GetPict(YM_PICT,YM_CTIPO)

AADD(TB_Campos,{cCampo,"",OemToAnsi(ALLTRIM(YM_TITULO)),;
                If(!Empty(cPict),cPict,)})

IF YM_IMPRIME # 'N'
   AADD(aRelDet,{nPos,cPict,YM_IMPRIME,YM_ALINHA,(YM_ORDENAR="S"),;
                            (YM_SALTAQ="S"),(YM_TOTALQ="S"),(YM_TOTALG="S")})
   IF YM_SALTAQ="S" .AND. AT(C_SALTAQ,cTemQuebra) = 0
      cTemQuebra+=C_SALTAQ
   ENDIF
   IF YM_TOTALQ="S" .AND. AT(C_TOTALQ,cTemQuebra) = 0
      cTemQuebra+=C_TOTALQ
   ENDIF
ENDIF

IF YM_ORDENAR="S"
   DO CASE
      CASE YM_CTIPO = "C"
           cCampo  := YM_CAMPO
//         bChave  := {|nChv| IP300Chave(nChv,1) } //Por causa do Protheus // AWR - 22/06/2005
           nTipo   := 1
      CASE YM_CTIPO = "D"
           cCampo  := "DTOS("+YM_CAMPO+")"
//         bChave  := {|nChv| IP300Chave(nChv,2) } //Por causa do Protheus // AWR - 22/06/2005
           nTipo   := 2
      CASE YM_CTIPO = "N"
           cCampo  := "STR("+YM_CAMPO+")"
//         bChave  := {|nChv| IP300Chave(nChv,3) } //Por causa do Protheus // AWR - 22/06/2005
           nTipo   := 3
   ENDCase
   IF(cChave = NIL, cChave:=cCampo, cChave+="+"+cCampo)
// AADD(aChave,{bChave,nPos}) // AWR - 22/06/2005
   AADD(aChave,{nTipo,nPos})
ENDIF

*----------------------------------------------------------------------------
Static Function IP300Chave(nInd,nTipo)
*----------------------------------------------------------------------------
SysRefresh()
DO CASE 
   CASE nTipo == 1
   Return IF(!Empty(aBuffer[nInd,2]),aBuffer[nInd,2],'')
   CASE nTipo == 2
   Return IF(!Empty(aBuffer[nInd,2]),DTOS(aBuffer[nInd,2]),'')
   CASE nTipo == 3
   Return IF(!Empty(aBuffer[nInd,2]),STR(aBuffer[nInd,2]),'')
ENDCASE
Return ""
*----------------------------------------------------------------------------
FUNCTION IP300Indexa(FileWork)
*----------------------------------------------------------------------------
IF cChave # NIL
   DBSELECTAREA('Work')
   IndRegua("Work",FileWork+TEOrdBagExt(),cChave,,,STR0042) //"Ordenando arquivo de trabalho..."
   DBSELECTAREA('SYL')
ENDIF
*----------------------------------------------------------------------------
FUNCTION IP300ItPendentes(aStruWork,aIntervalo,aStatus,aChave)
*----------------------------------------------------------------------------
LOCAL lCond, lGrava

PRIVATE bOrigem, nInd

PRIVATE aSIs:={}, aPOs:={}, aGIs:={}, aDIs:={}, aIt_SI:={}, aIt_PO:={},;
        aIt_GI:={}, aIt_DI:={}

PRIVATE bCampo:={|x,i| aBuffer[x[1],2]:=EVAL(x[2]),lGrava:=.T. }

PRIVATE cOrigem


Processa({|lEnd| IP300Origem(aStruWork,@lEnd) },;
           STR0043,,.T.) // ultimo parametro -> permite abortar //"Formatando campos selecionados..."

If !lGerou
   HELP("",1,"AVG0002077")//"Processamento Cancelado"
   Return
Endif

WHILE .T.

   IF SYL->YL_ORIGEM $ SI .OR. SYL->YL_ORIGEM $ TUDO
      lGrava:=.F.
      Processa({|lEnd| Grava_IS000({|| AEVAL(aIt_SI,bCampo),;
                                       AEVAL(aSIs,bCampo),;
                                       IP300Buffer(aIntervalo,@lGrava,aChave)} ) },;
               STR0045) //"Pesquisando S.I.s"

      IF MInterrompe .OR. MAbandona
         EXIT
      ENDIF
   ENDIF

   IF SYL->YL_ORIGEM $ PO .OR. SYL->YL_ORIGEM $ TUDO
      lGrava:=.F.
      Processa({|lEnd| Grava_IP000( {|| lCond:=(W_Pont > 0 .AND. ;
                                                aStatus[W_Pont]),;
                                        IF(lCond,IP300PO(bCampo,aIt_PO,aSIs,aPos),),;
                                        IP300Buffer(aIntervalo,@lGrava,aChave) } ) },;
               STR0046) //"Pesquisando P.O.s"

      IF MInterrompe .OR. MAbandona
         EXIT
      ENDIF
   ENDIF

   IF SYL->YL_ORIGEM $ GI .OR. SYL->YL_ORIGEM $ TUDO
      lGrava:=.F.
      Processa({|lEnd| Grava_IG000( {|| lCond:=(W_Pont > 0 .AND. ;
                                                aStatus[W_Pont]),;
                                        IF(lCond,IP300GI(bCampo,aIt_GI,aSIs,aPos,aGIs),),;
                                        IP300Buffer(aIntervalo,@lGrava,aChave) } ) },;
               STR0047) //"Pesquisando L.I.s"

      IF MInterrompe .OR. MAbandona
         EXIT
      ENDIF
   ENDIF

   IF (SYL->YL_ORIGEM $ DI .OR. SYL->YL_ORIGEM $ TUDO)//.AND. SYL->YL_ABERTO $ cSim  // GFP - 31/08/2015
      lGrava:=.F.
      Processa({|lEnd| Grava_ID000( {|| lCond:=(W_Pont > 0 .AND. ;
                                                aStatus[W_Pont]),;
                                        IF(lCond,IP300DI(bCampo,aIt_DI,aSIs,aPos,aGIs,aDIs),),;
                                        IP300Buffer(aIntervalo,@lGrava,aChave) } ,;
                                    AVCTOD(""),AVCTOD(""),"IP300") },;
               STR0048) //"Pesquisando D.I.s em aberto"
   ENDIF
   /* Nopado por GFP - 23/09/2015
   IF SYL->YL_ENTREG $ cSim
      lGrava:=.F.
      Processa({|lEnd| Grava_ID000( {|| IP300DI(bCampo,aIt_DI,aSIs,aPos,aGIs,aDIs),;
                                        IP300Buffer(aIntervalo,@lGrava,aChave) } ,;
                                    SYL->YL_DTE_I,SYL->YL_DTE_F,"IP300" ) },;
               STR0049) //"Pesquisando D.I.s entregues"
   ENDIF
   */
   EXIT
ENDDo

IF MAbandona
   HELP("",1,"AVG0002078")//SISTEMA SERµ ENCERRADO
   QUIT
ENDIF
*----------------------------------------------------------------------------
Function IP300Origem(aStruWork,lEnd)
*----------------------------------------------------------------------------
LOCAL bOrigem, nPos, nAlias, nCampos:=Len(aStruWork), cArq ,nInd

// no clipper o tamanho maximo do alias e' 10

LOCAL aAlias:={{'SI','SW0',{|| AADD(aSIs  ,{nInd,bOrigem}) } },;
               {'IS','SW1',{|| AADD(aIt_SI,{nInd,bOrigem}) } },;
               {'PO','SW2',{|| AADD(aPOs  ,{nInd,bOrigem}) } },;
               {'IP','SW3',{|| AADD(aIt_PO,{nInd,bOrigem}) } },;
               {'GI','SW4',{|| AADD(aGIs  ,{nInd,bOrigem}) } },;
               {'IG','SW5',{|| AADD(aIt_GI,{nInd,bOrigem}) } },;
               {'DI','SW6',{|| AADD(aDIs  ,{nInd,bOrigem}) } },;
               {'ID','SW7',{|| AADD(aIt_DI,{nInd,bOrigem}) } } }

LOCAL aWinDos := {"S","P","G","D","T"},cOrigFase:=""
Local cFilOld := cFilAnt		//JWJ
Local aOrd := SAVEORD("SX2")    //JWJ

ProcRegua(nCampos)

//Johann 12/01/06
IF FWModeAccess("SYO",3) == "C"
	cFilAnt := xFilial("SYO")
Else
	HELP("",1,"AVG0002079") //"Origem nÆo encontrada para o campo 
    lGerou:=.F. ; RETURN
Endif

FOR nInd:=1 TO nCampos

    IncProc(STR0051+aStruWork[nInd,1]) //"Criando Campo: "

    IF (cNome:=aStruWork[nInd,1] ) == 'WKSTATUS'
       LOOP
    ENDIF
    
    IF cNome == "WKFILIAL"	//JWJ 12/01/2006 - SYO não tem campo FILIAL para relatórios
       LOOP
    ENDIF

   IF ! SYO->(DBSeek(xFilial()+cNome))
      HELP("",1,"AVG0002079") //"Origem nÆo encontrada para o campo 
      lGerou:=.F. ; RETURN
   ENDIF
                                         
   WHILE ! SYO->(EOF()) .AND. ALLTRIM(SYO->YO_CAMPO) == cNome .And. SYO->YO_FILIAL == xFilial("SYO")

     // nao inclui campos com origem diferente da selecionada, exceto quando
     // se tratarem de campos especificos de uma determinada fase.
     // Ex: SIPO_LE = local de entrega, encontrado apenas na SI

     IF VAL(SYL->YL_ORIGEM) >= 1 .AND. VAL(SYL->YL_ORIGEM) <= 5
        cOrigFase:=aWinDos[VAL(SYL->YL_ORIGEM)]
     ELSE
        cOrigFase:=SYL->YL_ORIGEM
     ENDIF

     IF !SYL->YL_ORIGEM $ TUDO         .AND. ;
        AT(cOrigFase,SYO->YO_FASE) = 0 .AND. ;
        LEFT(SYO->YO_FASE,1) = 'I'
        SYO->(DBSKIP()) ; LOOP
     ENDIF

     nPos:=ASCAN(aAlias,{|tipo| tipo[1] == SYO->YO_FASE })

     cOrigem:=ALLTRIM(SYO->YO_ORIGEM)

     IF AT("(",cOrigem) # 0
        bOrigem:= &("{|| "+cOrigem+"}")
     ELSE
        cArq:="S"+LEFT(cOrigem,2)
        
        IF (SELECT(cArq) == 0,dbSelectArea(cArq),)   // Robson   29/08/05
        
        If (nAlias:=SELECT(cArq)) > 0
           If (cArq)->(FieldPos(cOrigem)) > 0
              bOrigem := FIELDWBLOCK(cOrigem,nAlias)
           Else
              HELP("",1,"AVG0002080",,cOrigem + STR0053+cArq,1,07)//"Campo "###"nÆo existe no Arquivo"
           Endif
        Else
           HELP("",1,"AVG0002081",,cOrigem+"/"+SYO->YO_FASE,2,1)//"Arquivo indeterminado para o campo/fase 
           Return
        Endif
     ENDIF

     EVAL(aAlias[nPos,3])          // cria tabela correspondente

     SYO->(DBSKIP()) ; LOOP

   ENDDo
NEXT

cFilAnt := cFilOld
RestOrd(aOrd)

Return NIL
*----------------------------------------------------------------------------
FUNCTION IP300PO(bCampo,aIt_PO,aSIs,aPos)
*----------------------------------------------------------------------------
AEVAL(aIt_PO,bCampo)
AEVAL(aSIs  ,bCampo)
AEVAL(aPOs  ,bCampo)
*----------------------------------------------------------------------------
FUNCTION IP300GI(bCampo,aIt_GI,aSIs,aPos,aGIs)
*----------------------------------------------------------------------------
AEVAL(aIt_GI,bCampo)
AEVAL(aSIs  ,bCampo)
AEVAL(aPOs  ,bCampo)
AEVAL(aGIs  ,bCampo)
*----------------------------------------------------------------------------
FUNCTION IP300DI(bCampo,aIt_DI,aSIs,aPos,aGIs,aDIs)
*----------------------------------------------------------------------------
AEVAL(aIt_DI,bCampo)
AEVAL(aSIs  ,bCampo)
AEVAL(aPOs  ,bCampo)
AEVAL(aGIs  ,bCampo)
AEVAL(aDIs  ,bCampo)
*----------------------------------------------------------------------------
FUNCTION IP300Buffer(aIntervalo,lGrava,aChave) //grava Work a partir do buffer
*----------------------------------------------------------------------------
LOCAL aCampo:={}, aValor:={}, nInd, nCampos:=LEN(aIntervalo), cNewKey:=''
LOCAL Campo,i,xConteudo

IF lGrava

   FOR nInd:= 1 TO nCampos
       SysRefresh()
       aValor:=aIntervalo[nInd]
       aCampo:=aBuffer[aValor[1]]

       IF aCampo[2] = NIL            .OR. ;
          aCampo[2] < aValor[2] .OR. ;
          aCampo[2] > aValor[3]
          lGrava:=.F.
          EXIT
       ENDIF
   NEXT
ENDIF

IF lGrava
   
   AEVAL(aChave,{|pos| cNewKey+=IP300Chave(pos[2],pos[1]) }) //EVAL(pos[2],pos[1]) // AWR - 22/06/2005

   IF !(SYL->YL_SUMARIZ $ cSim) .OR. (LEN(cNewKey) == 0) .OR. !(Work->(DBSEEK(cNewKey)))
      Work->(DBAPPEND())
   ENDIF
   SysRefresh()
   AEVAL(aBuffer,{|Campo,Pos|IF(!Campo[2] = NIL,;
        (Work->(FIELDPUT(Pos,IF(!Campo[3],;
                                 Campo[2],;
                                 Campo[2]+Work->(FIELDGET(Pos)))))),)})

   IF SYL->YL_STATUSP $ cSim
      Work->WKSTATUS:=TObs
   ENDIF
   
   Work->WKFILIAL := xFilial()	//Johann - 12/01/2006
ENDIF

AEVAL(aBuffer,{|campo| campo[2]:=NIL })
lGrava:=.F.
SysRefresh()
RETURN .T.
*----------------------------------------------------------------------------
FUNCTION IP300WorkFilter(aIntervalo,aStatus)
*----------------------------------------------------------------------------
LOCAL aValor:={}, nInd, nCampos:=LEN(aIntervalo), Conteudo

FOR nInd:=1 TO nCampos

    aValor  :=aIntervalo[nInd]
    Conteudo:=Work->(FIELDGET(aValor[1]))

    IF Conteudo < aValor[2] .OR. Conteudo > aValor[3]
       Work->(DBDELETE())
       RETURN
    ENDIF
NEXT

IF SYL->YL_ABERTO $ cSim .AND. EMPTY(Work->WKDT_EMB)

   nCampos:=LEN(aStatus)

   FOR nInd:=1 TO nCampos
       IF AT(STR0055,Work->WKSTATUS) # 0 .AND. aStatus[3] //'Ag. Guia'
          EXIT
       ENDIF

       IF ! aStatus[nInd]  .AND. Work->WKNOPC = nInd
          Work->(DBDELETE())
          RETURN
       ENDIF
   NEXT
ENDIF

RETURN
*----------------------------------------------------------------------------
FUNCTION IP300Calcula(cFase,cCampo,lUSD,lUsd_DI)
*----------------------------------------------------------------------------
LOCAL aCalc:={}, nValor:=0, cPrefixoH,PParidade

LOCAL aDespesas:={C_FOB,C_INLAND,C_PACKING,C_DESCONTO,C_FRETEINT,C_OUT_DESP}

IF cFase     == "PO"
   cPrefixoH := "W2_"
   cPrefixoI := "W3_"
   nAreaH    := SELECT("SW2")
   nAreaI    := SELECT("SW3") 
   If (nPos := aScan(aDespesas,C_OUT_DESP)) > 0
      aDespesas[nPos] := "OUT_DES"
   EndIf   
ELSEIF cFase == "GI"
   cPrefixoH := "W4_"
   cPrefixoI := "W5_"
   nAreaH    := SELECT("SW4")
   nAreaI    := SELECT("SW5")
   If (nPos := aScan(aDespesas,C_OUT_DESP)) > 0
      aDespesas[nPos] := "OUT_DES"
   EndIf    
ELSE
   cPrefixoH := "W6_"
   cPrefixoI := "W7_"
   nAreaH    := SELECT("SW6")
   nAreaI    := SELECT("SW7")
   /*
   IF lUsd_DI # NIL
      PParidade := SW6->W6_TX_FOB / IF ( SW6->W6_TX_US_D = 0,1, SW6->W6_TX_US_D)
   ENDIF
   */

ENDIF

aCalc:={FIELDWBLOCK(cPrefixoI+C_QTDE   ,nAreaI),;
        FIELDWBLOCK(cPrefixoI+C_SALDO_Q,nAreaI),;
        FIELDWBLOCK(cPrefixoI+C_PRECO  ,nAreaI),;
        FIELDWBLOCK(cPrefixoH+C_FOB_TOT,nAreaH),;
        FIELDWBLOCK(cPrefixoH+cCampo   ,nAreaH) }

DO CASE
   CASE  cCampo == C_FOB
         nValor:= EVAL(aCalc[2]) * EVAL(aCalc[3])
   CASE  cCampo == C_FOB_TOT
         AEVAL(aDespesas,{|despesa| nValor+=IP300Calcula(cFase,despesa,lUSD)})
   OTHER
         If cFase <> "DI"
            nValor:= ( (EVAL(aCalc[1]) * EVAL(aCalc[3])) / ;
                        EVAL(aCalc[4]) ) * EVAL(aCalc[5])
         Else
            BuscaInvoice(.T.,@nValor,cCampo)
         EndIf
         
         IF cCampo == C_DESCONTO
            nValor*=-1
         ENDIF
ENDCase
RETURN ( IF(lUSD = NIL .OR. cCampo == C_FOB_TOT, nValor, If(lUsd_DI # Nil .And. lUsd_DI, ConvInvMoeda(SW6->W6_HAWB, EasyGParam("MV_SIMB2",,"US$"), SW6->W6_DT),CalcFob_US(nValor,,PParidade)) ) )
*----------------------------------------------------------------------------
FUNCTION IP300Adit(Campo)  // busca ultimo aditivo
*----------------------------------------------------------------------------

SYI->(AVSeekLast(xFilial()+SW4->W4_GI_NUM))

IF VALTYPE(Campo) = 'B'
   RETURN EVAL(Campo)
ELSE
   RETURN EVAL(FIELDWBLOCK(Campo,SELECT("SYI")))
ENDIF
*----------------------------------------------------------------------------
FUNCTION BuscaTudo(cAlias,cChave,Campo,nOrder)
*----------------------------------------------------------------------------
LOCAL nOldArea:=SELECT(),PAlias_10:=LEFT(cAlias,10), nOldOrder
LOCAL xRetorno
Local nRec := (cAlias)->(RecNo()) //ASK 27/12/2007 

DbSelectArea(cAlias)

nOldOrder:=IndexOrd()
If(nOrder#NIL,DbSetOrder(nOrder),)

(cAlias)->(DBSeek(xFilial()+cChave))

IF VALTYPE(Campo) = 'B'
   xRetorno:=EVAL(Campo)
ELSE
   xRetorno:=EVAL(FIELDWBLOCK(Campo,SELECT(PAlias_10)))
ENDIF

(cAlias)->(DBSetOrder(nOldOrder))
(cAlias)->(dbGoTo(nRec))
DbSelectArea(nOldArea)

Return xRetorno

*-------------------------------------------------------------------------------------
FUNCTION BuscaTotalGeral(cAlias,cChave,Campo,nOrder,cFor,cWhile,PMoeda,cCampoData)
*-------------------------------------------------------------------------------------
LOCAL bFor,bWhile,bComando
PRIVATE cTotalGeral:=0

IF PMoeda = NIL     ; PMoeda := STR0056 ; ENDIF //"R$"
IF cCampoData = NIL ; RETURN 0       ; ENDIF

bFor:={|| &cFor. } ; bWhile:={|| &cWhile. }
BuscaTudo(cAlias,cChave,{||(cAlias)->(DBEVAL({||cTotalGeral+=((cAlias)->(FIELDGET(FIELDPOS(Campo)))*BuscaTaxa(PMoeda,(cAlias)->(FIELDGET(FIELDPOS(cCampoData)))))},bFor,bWhile))})

RETURN cTotalGeral
*----------------------------------------------------------------------------
FUNCTION BuscaCarta(PCampo)
*----------------------------------------------------------------------------
SYH->(DBSETORDER(2))
IF ! SYH->(DBSeek(xFilial()+SW3->W3_PO_NUM))
   SYH->(DBSeek(xFilial()+SW5->W5_PGI_NUM))
ENDIF
SWC->(DBSeek(xFilial()+SYH->YH_LC_NUM))

RETURN SWC->(FIELDGET(FIELDPOS(PCampo)))

*----------------------------------------------------------------------------
FUNCTION BuscaVia(cVia)
*----------------------------------------------------------------------------
RETURN IF(SYQ->( DBSeek(xFilial()+cVia) ), SYQ->YQ_DESCR,STR0057) //"VIA NAO CADASTRADA"

*----------------------------------------------------------------------------
FUNCTION BuscaImport(cImport)
*----------------------------------------------------------------------------
RETURN IF(SYT->( DBSeek(xFilial()+cImport) ), SYT->YT_NOME,STR0058) //"IMPORTADOR NAO CADASTRADO"

*----------------------------------------------------------------------------
FUNCTION BuscaCondPag()
*----------------------------------------------------------------------------
RETURN IF(SY6->(DBSeek(xFilial()+SW2->W2_COND_PAG+STR(SW2->W2_DIAS_PAG,3,0))),;
                       MSMM(SY6->Y6_DESC_P,36),;
                      STR0059) //"COND. PAGTO NAO CADASTRADA"

*----------------------------------------------------------------------------
FUNCTION Qtd_Entr()
*----------------------------------------------------------------------------
LOCAL _Qtde := 0

HELP("",1,"AVG0002082")//Nacionaliza‡Æo ainda nÆo dispon¡vel no SIGAEIC
RETURN VAL(STR(SW7->W7_SALDO_Q - _Qtde,13,3))
*----------------------------------------------------------------------------
FUNCTION BuscaPorto(nPorto)
*----------------------------------------------------------------------------
LOCAL cDescricao:=STR0061 //"PORTO NAO CADASTRADO"

SY9->(DBSETORDER(2))
IF SY9->( DBSeek(xFilial()+nPorto) ) 
  cDescricao:=SY9->Y9_DESCR
ENDIF
SY9->(DBSETORDER(1))

RETURN cDescricao
*----------------------------------------------------------------------------
FUNCTION BuscaInvoice(lValorDesp,nValor,cCampo)
*----------------------------------------------------------------------------
LOCAL PChave := SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_SI_NUM+AvKey(SW7->W7_CC, "W8_CC")+SW7->W7_COD_I+STR(SW7->W7_REG,AVSX3("W7_REG",3),0) // GCC - 01/08/2013 - Ajuste para correção do Seek na SW8. Incluido AvKey no campo de Centro de Custo da SW7.
LOCAL PChv_Ivh , rInvoice := SPACE(15), MCont := 0

If lValorDesp = NIL
   lValorDesp := .F.
EndIf

SW8->(DBSETORDER(3))
SW8->(DBSeek(xFilial()+PChave))
PChv_Ivh := SW8->W8_HAWB+SW8->W8_PGI_NUM+SW8->W8_PO_NUM+SW8->W8_SI_NUM+SW8->W8_CC+SW8->W8_COD_I+STR(SW8->W8_REG,AVSX3("W8_REG",3),0)
WHILE ! SW8->(EOF()) .AND. SW8->W8_FILIAL == xFilial("SW8") .AND. PChave == PChv_Ivh

  IF SW8->W8_FABR # SW7->W7_FABR .OR. SW8->W8_FORN # SW7->W7_FORN
     SW8->(DBSKIP())
     PChv_Ivh := SW8->W8_HAWB+SW8->W8_PGI_NUM+SW8->W8_PO_NUM+SW8->W8_SI_NUM+SW8->W8_CC+SW8->W8_COD_I+STR(SW8->W8_REG,AVSX3("W8_REG",3),0)
     LOOP
  ENDIF

  MCont ++

  If !lValorDesp
     IF MCont == 1
        rInvoice := SW8->W8_INVOICE
     ENDIF

     IF MCont >= 2
        rInvoice := SUBSTR(rInvoice,1,14)+"+"
        EXIT
     ENDIF
  Else
     nValor += &("SW8->W8_"+cCampo)
  EndIf

  SW8->(DBSKIP())
  PChv_Ivh := SW8->W8_HAWB+SW8->W8_PGI_NUM+SW8->W8_PO_NUM+SW8->W8_SI_NUM+SW8->W8_CC+SW8->W8_COD_I+STR(SW8->W8_REG,AVSX3("W8_REG",3),0)
ENDDO
SW8->(DBSETORDER(1))
RETURN rInvoice
*----------------------------------------------------------------------------
FUNCTION IP300Print(aRelDet,cTemQuebra)
*----------------------------------------------------------------------------
LOCAL wnrel
LOCAL cDesc1   := STR0062 //"Emite um relatório com os campos selecionados pelo usuário,"
LOCAL cDesc2   := STR0063 //'e que estão aparecendo no "Browse".'
LOCAL cDesc3   := ''
LOCAL cString  := "Work"
LOCAL aOrd     := {}

PRIVATE nRecno   := Work->(RECNO())
PRIVATE Tamanho  := "G"
PRIVATE titulo   := Trim(SYL->YL_HEADER)
PRIVATE nomeprog := "EICIP300"
PRIVATE aReturn  := { STR0064, 1,STR0065, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE nLastKey := 0 ,aInd := {}
PRIVATE nColunas:=LEN(aRelCab[6]) - 1  // contem os 'replicates' de '-', -1 espaco

If nColunas <= 80
   Tamanho:= "P"
Elseif nColunas <= 132
   Tamanho:= "M"
Else
   Tamanho:= "G"
Endif

wnrel:=SetPrint(cString,NomeProg ,,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.T.)

If nLastKey == 27
   Set Filter To
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
   Set Filter To
   Return
Endif

RptStatus({|lEnd| IP300Report(@lEnd,wnRel,cString,aRelDet,cTemQuebra)},titulo)
dbGoTo(nRecNo)
Return
*----------------------------------------------------------------------------
FUNCTION IP300Report(lEnd,wnRel,cString,aRelDet,cTemQuebra)
*----------------------------------------------------------------------------
LOCAL   nCols:=LEN(aRelCols/*aRelDet*/), nInd, Pagina:=0, Linha:=999,;
        nCab:=LEN(aRelCab) - 1

LOCAL   aSave:=ARRAY(nCols), aTotalQ:=ARRAY(nCols), aTotalG:=ARRAY(nCols),;
        aDetalhe:={}, lQuebrou:=.F., lTotalG:=.F., lTotalQ:=.F., lSaltaQ:=.F.,;
        nLen
LOCAL   bCab:={|| IP300RepCab(@Linha,nTipo) }
LOCAL   cRodaTxt := STR0066 //"REGISTRO(S)"
LOCAL   nCntImpr := 0,nTipo := 0

LOCAL   bLen:={|nInd|IF(nInd = nCols,nColunas-(aRelCols[nInd])+1,;
                                     aRelCols[nInd+1]-(aRelCols[nInd]+1)) }

LOCAL   bPad:={|Campo,_Alinha,_Pict,_Len| ;
               IF(_Pict # NIL,Campo:=TRAN(Campo,_Pict),),;
               IF(_Alinha = "D",PADL(Campo,_Len),;
               IF(_Alinha = "C",PADC(Campo,_Len),;
                                PADR(Campo,_Len))) }


LOCAL OldRec:= RECNO()

Local cFilOld

PRIVATE Valor          // devido a macrosubstituicao

WORK->(DBGOTOP())
m_pag    := 1
nTipo := 15  
cFilOld := WORK->WKFILIAL

AFILL(aTotalG,0) ; AFILL(aTotalQ,0)
SetRegua(Easyreccount("Work"))

WHILE ! EOF()

   If lEnd
      @PROW()+1,001 PSAY STR0067 //"CANCELADO PELO OPERADOR"
      Exit
   Endif

   IncRegua()
   
   IF cFilOld # Work->WKFILIAL	//Johann 13/01/2006
//     Eval(bCab)                                                        

      Linha++
      @ Linha,001  PSAY  REPLI('=',nColunas)
      Linha++      
     @ Linha,001 PSAY AVSX3("W2_FILIAL",5) + ': ' + Work->WKFILIAL+'-'+AvgFilName({Work->WKFILIAL})[1]
      ++Linha     

      @ ++Linha,001 PSAY aRelCab[5]
      @ ++Linha,001 PSAY aRelCab[6]     
      cFilOld := Work->WKFILIAL
   ENDIF

   IF !EMPTY(cTemQuebra)               // tem algum campo com salto de pagina
      lQuebrou:=.F.                    // ou sub-total na quebra ?
      FOR nInd:=1 TO nCols
          aDetalhe:=aRelDet[nInd]
          Valor   :=FIELDGET(aDetalhe[1])
          IF aDetalhe[5] .AND. ;
            (lQuebrou:=(aSave[nInd] # NIL .AND. aSave[nInd] # Valor))
             EXIT
          ENDIF
      NEXT
      IF lQuebrou
         IF AT(C_TOTALQ,cTemQuebra) # 0
            IP300PrTotal(lQuebrou,'Q',@Linha,nCols,aRelDet,aRelCols,bLen,bPad,aTotalQ)
         ENDIF
         IF AT(C_SALTAQ,cTemQuebra) # 0
            EVAL(bCab)
         ENDIF
      ENDIF
   ENDIF

   IF ++Linha > SYL->YL_LINHAS
      EVAL(bCab)
   ENDIF

   FOR nInd:=1 TO nCols
       aDetalhe:=aRelDet[nInd]
       Valor:=FIELDGET(aDetalhe[1])

       IF aDetalhe[3] # 'Q' .OR. ;
          aSave[nInd] = NIL      .OR. aSave[nInd] # Valor
          nLen :=EVAL(bLen,nInd)
          @ Linha,aRelCols[nInd] PSAY EVAL(bPad,Valor,aDetalhe[4],;
                                                      aDetalhe[2],nLen)
       ENDIF

       IF aDetalhe[3] = 'Q' .OR. !EMPTY(cTemQuebra)
          aSave[nInd]:=Valor
       ENDIF

       IF aDetalhe[8]
          lTotalG:=.T.
          aTotalG[nInd]+=Valor
       ENDIF

       IF aDetalhe[7]
          lTotalQ:=.T.
          aTotalQ[nInd]+=Valor
       ENDIF

   NEXT

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Adiciona 1 ao contador de registros impressos         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nCntImpr++

   DBSKIP()
ENDDo

IP300PrTotal(lTotalQ,'Q',@Linha,nCols,aRelDet,aRelCols,bLen,bPad,aTotalQ)
IP300PrTotal(lTotalG,'G',@Linha,nCols,aRelDet,aRelCols,bLen,bPad,aTotalG)

If Linha != 80
   Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

Set Device to Screen

If aReturn[5] = 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

OLDSET
RETURN .T.
*----------------------------------------------------------------------------
FUNCTION IP300PrTotal(lTotal,Qual,Linha,nCols,aRelDet,aRelCols,bLen,bPad,aTotal)
*----------------------------------------------------------------------------
LOCAL nInd, aDetalhe:={}, nLen

IF ! lTotal
   RETURN
ENDIF

++Linha
FOR nInd:=1 TO nCols
    aDetalhe:=aRelDet[nInd]
    IF (Qual = 'Q' .AND. aDetalhe[7]) .OR. ;
       (Qual = 'G' .AND. aDetalhe[8])
       @ Linha,aRelCols[nInd] PSAY REPL('-',(nLen:=EVAL(bLen,nInd)))
    ENDIF
NEXT
++Linha
FOR nInd:=1 TO nCols
    aDetalhe:=aRelDet[nInd]
    IF (Qual = 'Q' .AND. aDetalhe[7]) .OR. ;
       (Qual = 'G' .AND. aDetalhe[8])
       nLen:=EVAL(bLen,nInd)
       @ Linha,aRelCols[nInd] PSAY EVAL(bPad,aTotal[nInd],aDetalhe:ALINHA,;
                                                          aDetalhe:PICT,nLen)
       aTotal[nInd]:=0
    ENDIF
NEXT
++Linha
*----------------------------------------------------------------------------
FUNCTION IP300RepCab(Linha,nTipo)
*----------------------------------------------------------------------------
Linha:=Cabec(Trim(SYL->YL_HEADER),Trim(SYL->YL_SUBHEA),"",nomeprog,tamanho,nTipo)
//Linha:=6

//Johann - 13/01/2006
@ ++Linha,001 PSAY AVSX3("W2_FILIAL",5) + ': ' + WORK->WKFILIAL+'-'+AvgFilName({WORK->WKFILIAL})[1]
Linha++

@ ++Linha,001 PSAY aRelCab[5]
@ ++Linha,001 PSAY aRelCab[6]
//++Linha

Linha++

*----------------------------------------------------------------------------
FUNCTION IP300ShowRel(nStart,lMontar,Imprimir)
*----------------------------------------------------------------------------
LOCAL cHeader:=ALLTRIM(SYL->YL_HEADER), cCliente:=ALLTRIM(SM0->M0_NOMECOM)
LOCAL cSubHea:=ALLTRIM(SYL->YL_SUBHEA), nSobra, nTotCols
LOCAL nLargura:= 132 // IP300Colunas()
LOCAL aRelCampos:={}, nLen, nLinha:=Show_Rel_Lin, nKey

IF lMontar

   AFILL(aRelCab,"")
   ASIZE(aRelCols,0)

   nSobra:=(nLargura-(LEN(cHeader)+4))/2

   aRelCab[1]:=REPLICATE(TRACO_DEITADO,nLargura)

   aRelCab[2]:=PADR(PADR(cCliente,nSobra)+;
                  ESPACO2+cHeader+ESPACO2,nLargura-18)+;
              STR0068 //"Pagina..:      001"

   IF EMPTY(cSubHea)
      aRelCab[3]:=PADR("Average Tecnologia",nLargura-18)+STR0069+DTOC(dDataBase) //"Emissao.: "
   ELSE
      nSobra:=(nLargura-LEN(cSubHea)+4) / 2
      aRelCab[3]:=PADR(PADR("Average Tecnologia",nSobra)+ESPACO2+cSubHea+;
                     ESPACO2,nLargura-18)+STR0069+DTOC(dDataBase) //"Emissao.: "
   ENDIF

   aRelCab[4]:=REPLICATE(TRACO_DEITADO,nLargura)

   //Johann - acrescentar o campo WKFILIAL no aRelCampos aqui.
   //AADD(aRelCampos, {"@!","Filial","E"})

   IP300LerDet({||IP300CreateRel(aRelCampos,.F.,.F.)},;
              {||SYM->YM_IMPRIME # 'N'})

   IF SYL->YL_STATUSP $ cSim
      AADD(aRelCampos,{REPL('.',LEN_STATUS),STR0040,'E'}) //'Status'
   ENDIF

   AADD(aRelCols,1)   // coluna inicial

   AEVAL(aRelCampos,{|x,y| nLen:=MAX(LEN(x[1]),LEN(x[2])),;
                        aRelCab[5]+=IF(x[3]="E",PADR(x[2],nLen)+ESPACO1,;
                                    IF(x[3]="C",PADC(x[2],nLen)+ESPACO1,;
                                                PADL(x[2],nLen)+ESPACO1)),;
                        aRelCab[6]+=REPL(TRACO_DEITADO,nLen)+ESPACO1,;
                        aRelCab[7]+=IF(x[3]="E",PADR(x[1],nLen)+ESPACO1,;
                                    IF(x[3]="C",PADC(x[1],nLen)+ESPACO1,;
                                                PADL(x[1],nLen)+ESPACO1)),;
                        AADD(aRelCols,LEN(aRelCab[5])+1)} )

   ASIZE(aRelCols,LEN(aRelCols)-1) // o ultimo elemento nao tem utilidade

   IF Imprimir # NIL                 // funcao chamada da rotina de impressao
      RETURN NIL
   ENDIF

   nRelCol:=nStart
ENDIF

*----------------------------------------------------------------------------
FUNCTION IP300CreateRel(aRelCampos,lValor,lAlteracao)
*----------------------------------------------------------------------------
LOCAL Valor, nPos, cTipo, cPict, cTama

IF ! lValor .OR. lAlteracao
   cTipo:=SYM->YM_CTIPO
   cPict:=SYM->YM_PICT
   cTama:=SYM->YM_CTAMA
ELSE
   cTipo:=SYN->YN_CTIPO
   cPict:=SYN->YN_PICT
   cTama:=SYN->YN_CTAMA
ENDIF

cPict:=IP300GetPict(cPict,cTipo)

If SYM->YM_CAMPO = "WKCOD_I"
   cTama := AVSX3("B1_COD",AV_TAMANHO)
   cPict := ""
EndIf
If SYN->YN_CAMPO = "WKCOD_I"
   cTama := AVSX3("B1_COD",AV_TAMANHO)
   cPict := ""
EndIf
DO CASE
   CASE AT(cTipo,'CN') # 0
       IF cPict # NIL .AND. ! EMPTY(cPict)
          IF (nPos:=AT([@],cPict)) # 0
             Valor:=SUBSTR(cPict,nPos+3)
          ELSE
             Valor:=cPict
          ENDIF
       ELSE
          Valor:=REPL(IF(cTipo='C','x','9'),cTama)
       ENDIF
   CASE cTipo = 'D'

       Valor:=DTOC(dDataBase)

   CASE cTipo = "L"
       Valor:=STR0070 //"Sim"
ENDCASE

IF lValor
   RETURN ( LEN(Valor) )
ENDIF

AADD(aRelCampos,{Valor,ALLTRIM(SYM->YM_TITULO),SYM->YM_ALINHA})
*----------------------------------------------------------------------------
FUNCTION IP300LerDet(bBlock,bFor,lNotSeek)
*----------------------------------------------------------------------------
LOCAL nRec:=SYM->(RECNO())

IF lNotSeek = NIL
   SYM->(DbSeek(xFilial()+SYL->YL_COD))
ENDIF

SYM->(DBEVAL(bBlock,bFor,{|| SYM->YM_FILIAL == xFilial("SYM") .And. SYM->YM_COD == SYL->YL_COD }))

SYM->(DBGOTO(nRec))
*----------------------------------------------------------------------------
FUNCTION IP300Status(lLerStatus,nKey)
*----------------------------------------------------------------------------
LOCAL nInd, nLen, nCount:=0, nQual:=0
LOCAL aStatus:=ARRAY(LEN(T_TabObs))

FOR nInd:=1 TO (nLen:=LEN(aStatus))
    IF SUBSTR(SYL->YL_STATUS,nInd,1) = "T"
       aStatus[nInd]:=.T.
       nQual:=nInd ; ++nCount
    ELSE
       aStatus[nInd]:=.F.
    ENDIF
NEXT

DO CASE
   CASE lLerStatus
       RETURN aStatus
   CASE nCount = 1
       RETURN PADR(T_TabObs[nQual],LEN_STATUS_R)
   OTHERwise
       RETURN SPACE(LEN_STATUS_R)
ENDCase
*--------------------------------------*
FUNCTION IP300Copia(cAlias,nReg,nOpc)
*--------------------------------------*
lCopia:=.T.
IP300Inclui(cAlias,nReg,3)
lCopia:=.F.               

RETURN .T. 

*------------------------------*
Function Ip300GrvCopia(cNomArq)
*------------------------------*
Local nInd

DbSelectArea("SYL")
FOR nInd := 1 TO SYL->(FCount())
    M->&(FieldName(nInd)) := FieldGet(nInd)
NEXT i

M->YL_COD:=CriaVar("YL_COD")
TRB->(avzap())

If !E_GravaTRB("SYM",bSeek,bFor,bWhile,aCamposDic,{|_rec|TRB->RECNO:=_rec})
   Help(" ",1,"IP300SEMIT")
   TRB->(E_EraseArq(cNomArq))
   DbSelectArea(cAlias)
   Return .T.
Endif

TRB->(DbGotop())

Do While !TRB->(Eof())

   TRB->RECNO:=0
   TRB->DBDELETE:=.F.
   
   TRB->(DbSkip())
EndDo

aStatus:=IP300Status(.T.,0)

SYL->(DbGoBottom())
SYL->(DbSkip())
Return .T.

Static Function AtuCampos()

Local lFlag:= .f.

If SYO->(DbSeek(xFilial()+"WKDESC_PRO"))
   If AllTrim(SYO->YO_ORIGEM) == 'BuscaTudo("SYR",SW2->W2_TIPO_EMB+SW2->W2_ORIGEM+SW2->W2_DEST,"YR_PAIS_ORI"),BuscaPais(SYR->YR_PAIS_ORI)'
      SYO->(RecLock("SYO", .F.))
      SYO->YO_ORIGEM := 'BuscaPais(BuscaTudo("SYR",SW2->W2_TIPO_EMB+SW2->W2_ORIGEM+SW2->W2_DEST,"YR_PAIS_ORI"))'
      SYO->(MsUnlock())      
   EndIf
EndIf

// TDF - 06/01/2010
If SYO->(DbSeek(xFilial()+"WKIMPORT"))
   Do While !SYO->(Eof()) .AND. Alltrim(SYO->YO_CAMPO) == "WKIMPORT" 
      If Alltrim(SYO->YO_FASE) == "PO" .AND. Alltrim(SYO->YO_CAMPO) == "WKIMPORT"
         SYO->(RecLock("SYO", .F.))
         SYO->YO_ORIGEM := "W2_IMPORT"
         SYO->(MsUnlock())
      EndIf  
      If Alltrim(SYO->YO_FASE) == "IG" .AND. Alltrim(SYO->YO_CAMPO) == "WKIMPORT"
         SYO->(RecLock("SYO", .F.))
         SYO->YO_ORIGEM := "W4_IMPORT"
         SYO->(MsUnlock())
      EndIf    
      If Alltrim(SYO->YO_FASE) == "DI" .AND. Alltrim(SYO->YO_CAMPO) == "WKIMPORT" // Verifica se o registro da fase DI já existe
         lFlag := .t.
      EndIf 
      
      SYO->(DBSKIP())
           
   EndDo
      If !(lFlag)
         SYO->(RecLock("SYO", .T.))
         SYO->YO_CAMPO  := "WKIMPORT"
         SYO->YO_FASE   := "DI"
         SYO->YO_ORIGEM := "W6_IMPORT"
         SYO->(MsUnlock())
      EndIf 
EndIf
Return Nil
