//#include "FiveWin.ch"
#include "Average.ch"
#include "EICTR370.CH"
#DEFINE   VENCIMENTO  1
#DEFINE   NEGOCIACAO  2
#DEFINE   EMBARQUE    3

#DEFINE   Tit370      STR0001 //" SALDOS DE CARTAS DE CREDITO "
#DEFINE   Largura     80                            
#DEFINE   Comprime    .T.
#DEFINE   MsgProc     STR0002 //"EM PROCESSAMENTO - AGUARDE..."
#DEFINE   MsgPesq     STR0003 //"PESQUISANDO DADOS - AGUARDE..."
#DEFINE   MsgEsc      STR0004 //"ESC = Abandona"
#DEFINE   K_ESC        27

#COMMAND E_RESET_AREA => IF(SELECT("TRB")<>0,TRB->(E_EraseArq(cNomArq)),) ; DBSELECTAREA(cOldArea) ; RETURN

/*
Funcao      : EICTR370
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 05/09/2006
Obs         :
Revisão     :
*/
*******************
Function EICTR370
*******************
lRet := EICTR370R3(.T.)
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR370R3 ³ Autor ³ AVERAGE/RS          ³ Data ³ 23.05.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Follow-Up Carta de Credito                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR370R3()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function EICTR370R3(p_R4)
LOCAL  aRCampos:={}, cOldArea:=ALIAS(), nInc 
//LOCAL TB_Funcoes:={ {"-4", "Relatorio", "F5", "Relatorio" } }TB_Campos:={},

// incluir variaveis para o relatorio padrao

LOCAL aDados :={"TRB",;
                STR0005,; //"Este relatorio ir  exibir uma estat¡stica sobre"
                STR0006,; //"o desempenho de "
                "",;
                "G",;
                Largura,;
                "",;
                "",;
                STR0007,;//"Follow-up de Carta de Credito"
                { "Zebrado", 1,"Importa‡Æo", 1, 2, 1, "",1 },;
                "EICTR370",;
                { {|| .T. } , {|| TR370Tot() }  }  }


PRIVATE WorkFile, L1:=5, indice, TOpcao:=0,TDt_I,TDt_F,MSai,cBase
PRIVATE MMoeda:=SPACE(3),MVlr_Fob:=0,MVlr_Sdo:=0,TBanco,TAgencia, MTexto
PRIVATE MTabMoe:={},MTabSdo:={},MTabVlr:={}

// aRotina declarada apenas para compatibilizar com GetDadDB

PRIVATE aRotina := { { STR0008       , "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                     { STR0009           , "C210Impor" , 0 , 2} ,; //"Atual"
                     { STR0010           , "C210Impor" , 0 , 3} }//"Todos"

// definir sempre - inicio



PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

Private aHeader[0],nUsado:=0, aCampos:={}, nOpcao:=1, Valor[0],INCLUI:=.F. //PARA MSGETDB

//JPA - 05/09/2006 - Relatório Personalizavel - Release 4
Private oReport
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()

bCampo  := {|nCPO| Field(nCPO) }

WHILE .T.

  IF ! Pergunte("ETR370",.T.)
     DbSelectArea(cOldArea) // sempre deve haver uma area selecionada
     RETURN .F.
  ENDIF
  
  IF !E_Periodo_OK(mv_par02,mv_par03)
     LOOP
  ENDIF    

  TOpcao  :=mv_par01
  TDt_I   :=mv_par02
  TDt_F   :=mv_par03
  TBanco  :=mv_par04
  TAgencia:=mv_par05
  

  IF !EMPTY(TDt_I) .AND. !EMPTY(TDt_F)
     MTexto:="De.: "+DTOC(TDt_I)+ " ate "+DTOC(TDt_F)
  ELSEIF EMPTY(TDt_I) .AND. ! EMPTY(TDt_F)
     MTexto:="De.:  - "+ " ate "+DTOC(TDt_F)
  ELSEIF !EMPTY(TDt_I) .AND. ! EMPTY(TDt_F)
     MTexto:="De.: "+DTOC(TDt_I)+ " ate - "
  ELSE
     MTexto:= STR0011 //"Emissao Total"
  ENDIF

  aDados[7]:=MTexto

  aTitCpo:={STR0012,STR0013,STR0014}//"Vencimento"###"Negociacao"###"Embarque"

  DO CASE
     CASE TOpcao == VENCIMENTO
          aCampos:={"WC_DT_VEN" ,"WC_LC_NUM","A2_NREDUZ","WC_BANCO",;
                    "WC_AGENCIA","WC_DT_NEG","WC_DT_EMB"}
     CASE TOpcao == NEGOCIACAO
          aCampos:={"WC_DT_NEG" ,"WC_LC_NUM","A2_NREDUZ","WC_BANCO",;
                    "WC_AGENCIA","WC_DT_EMB","WC_DT_VEN"}
     CASE TOpcao == EMBARQUE
          aCampos:={"WC_DT_EMB" ,"WC_LC_NUM","A2_NREDUZ","WC_BANCO",;
                    "WC_AGENCIA","WC_DT_VEN","WC_DT_NEG"}
  ENDCASE

  AADD(aCampos,"W2_MOEDA")  
  AADD(aCampos,"WC_PER_FOB")
  AADD(aCampos,"WC_VLR_ABE")                                                 
  
   //If lR4     //JPA - 05/09/2006
      //oReport := ReportDef()
   //EndIf

  cNomArq:=E_CRIATRAB()
  SWC->(DBSETORDER(TOpcao+1))
  
  aHeader[3,1] :="Docto Base"
  aHeader[9,1] :="Valor"
  aHeader[10,1]:="Saldo"

  ASIZE(MTabMoe,0)
  ASIZE(MTabVlr,0)
  ASIZE(MTabSdo,0)

  DBSELECTAREA("TRB") ; AvZap() 
  // Cria Variaveis de Memoria 
  
  FOR nInc := 1 TO TRB->(FCount())
      M->&(TRB->(FIELDNAME(nInc))) := TRB->(FIELDGET(nInc))
  NEXT
  
  
  DBSELECTAREA("SWC")
  IF ! EMPTY(TDt_I)
     SWC->(DBSEEK(xFilial("SWC")+DTOS(TDt_I),.T.))
  ELSE
     SWC->(DBSEEK(xFilial("SWC")))
  ENDIF

  
  Processa({|lEnd| TR370GravaWork() },STR0015 ) //"Lendo Carta de Credito"
  SWC->(DBSEEK(xFilial("SWC")))
  IF TRB->(Easyreccount("TRB")) > 0
     E_CriaCampos(aRCampos,.T.)
     E_SayLeadT(Tit370+" - "+MTexto,,0,aDados,aRCampos,NIL,NIL,NIL, If(lR4, {|| (oReport := ReportDef(),oReport:PrintDialog())},NIL))  // JPA - 05/09/06
     
  Else                                                     //mjb150797
     Help("",1,"AVG0001011") // "Nao ha registros para serem processados"
     TRB->(E_EraseArq(cNomArq))                            //mjb150797
     Loop                                                  //mjb150797
  ENDIF
  EXIT
END
E_RESET_AREA
RETURN

*------------------------*
Function TR370GravaWork()
*------------------------*
Local saldoNow := 0
MTotSdo := 0
MTotVlr := 0
SYH->(DBSETORDER(1))
ProcRegua(50)

WHILE ! SWC->(EOF()) .AND.  SWC->WC_FILIAL==xFilial("SWC")

    saldoNow := SWC->WC_VLRCART
   IF ! EMPTY(TDt_F)
      IF FIELDGET(FIELDPOS(aCampos[1])) > TDt_F
         EXIT
      ENDIF
   ENDIF
   IncProc(STR0017 +SWC->WC_LC_NUM)//"Lendo Codigo "

   IF ! EMPTY(TBanco)
      IF TBanco <> SWC->WC_BANCO
         SWC->(DBSKIP()) ; LOOP
      ENDIF
   ENDIF

   IF ! EMPTY(TAgencia)
      IF TAgencia <> SWC->WC_AGENCIA
         SWC->(DBSKIP()) ; LOOP
      ENDIF
   ENDIF
   
   cBase:=IF(SWC->WC_BASE=="2","P","G")
      
   SYH->(DBSEEK(xFilial("SYH")+SWC->WC_LC_NUM))
   
   DO WHILE SYH->(!EOF()) .AND. SYH->YH_LC_NUM==SWC->WC_LC_NUM .AND. SYH->YH_FILIAL==XFILIAL("SYH")
   
      MVlr_Fob:=0
      MVlr_Sdo:=0
   
      CalcSdoFOB(SWC->WC_LC_NUM,cBase,@MVlr_Fob,@MVlr_Sdo,@MMoeda,SYH->YH_PO_GI)
      saldoNow := saldoNow - MVlr_Fob
      TRB->(DBAPPEND())
      TRB->WC_DT_VEN  := SWC->WC_DT_VEN
      TRB->WC_DT_NEG  := SWC->WC_DT_NEG
      TRB->WC_DT_EMB  := SWC->WC_DT_EMB
      TRB->WC_LC_NUM  := SWC->WC_LC_NUM
      TRB->WC_BANCO   := SWC->WC_BANCO
      TRB->WC_AGENCIA := SWC->WC_AGENCIA
      TRB->W2_MOEDA   := MMoeda
      TRB->WC_VLR_ABE := saldoNow
      TRB->WC_PER_FOB := MVlr_Fob
      TRB->A2_NREDUZ  := DoctoBase(SWC->WC_LC_NUM,cBase)

      nAscan:=ASCAN(MTabMoe,MMoeda)
      
      IF nAscan== 0
         AADD(MTabMoe,MMoeda)
         AADD(MTabSdo,TRB->WC_VLR_ABE)
         AADD(MTabVlr,TRB->WC_PER_FOB)
      ELSE
         MTabSdo[nAscan]+=TRB->WC_VLR_ABE
         MTabVlr[nAscan]+=TRB->WC_PER_FOB 
      ENDIF      
      
      SYH->(DBSKIP())
      
   ENDDO
   
   SWC->(DBSKIP())
   
ENDDO



*-------------------*
FUNCTION TR370Tot()
*-------------------*
LOCAL MLin:=PROW() + 1
LOCAL cPict:=AVSX3("WC_VLR_ABE",6) //MTabSdo
LOCAL cPict1:=AVSX3("WC_PER_FOB",6) //MTabVlr   
Local I

// T_Len --> private array da funcao relatorio, que contem na coluna 1 o
//           tamanho do campo e na coluna 2 a coluna a ser impressa. Cada
//           ocorrencia se refere a um campo em conformidade com o especifi-
//           cado em R_Campos (vide inicio deste programa - MJBarros)

@ MLin,T_Len[08,2] PSAY REPL("-",T_Len[08,1])
@ MLin,T_Len[09,2] PSAY REPL("-",T_Len[09,1])
@ MLin,T_Len[10,2] PSAY REPL("-",T_Len[10,1])

MLin++
FOR I=1 TO LEN(MTabMoe)
    @ MLin,T_Len[08,2]+1 PSAY MTabMoe[I]
    @ MLin,T_Len[09,2]   PSAY TRAN(MTabVlr[I],cPict1)
    @ MLin,T_Len[10,2]   PSAY TRAN(MTabSdo[I],cPict)
    MLin++
NEXT
RETURN .T.
          

//JPA - 05/09/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************
Local oColl, cCol1, cCol2, cCol3

If TOpcao == VENCIMENTO
   cCol1 := "WC_DT_VEN"
   cCol2 := "WC_DT_NEG"
   cCol3 := "WC_DT_EMB"
ElseIf TOpcao == NEGOCIACAO
   cCol1 := "WC_DT_NEG"
   cCol2 := "WC_DT_EMB"
   cCol3 := "WC_DT_VEN"
Else
   cCol1 := "WC_DT_EMB"
   cCol2 := "WC_DT_VEN"
   cCol3 := "WC_DT_NEG"
EndIf
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SWC"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICTR370", STR0007, "ETR370"  , {|oReport| ReportPrint(oReport)}, STR0005 + " " + STR0006)

oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Cartas de Crédito",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1, cCol1       , "TRB", /*Titulo*/  , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WC_LC_NUM" , "TRB", "No. L/C"   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "A2_NREDUZ" , "TRB", "Docto Base", /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WC_BANCO"  , "TRB", /*Titulo*/  , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WC_AGENCIA", "TRB", /*Titulo*/  , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, cCol2       , "TRB", /*Titulo*/  , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, cCol3       , "TRB", /*Titulo*/  , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W2_MOEDA"  , "TRB", /*Titulo*/  , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WC_PER_FOB", "TRB", "Valor"     , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WC_VLR_ABE", "TRB", "Saldo"     , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

oColl := TRCollection():New(, "SUM", /*oBreak*/,;
									/*cTitle*/"Total Valor", /*cPicture*/"@E 999,999,999.99", /*uFormula*/ oSecao1:Cell("W2_MOEDA"),;
									/*.lEndSection.*/ .F., /*.lEndReport.*/ .T., /*oParent*/ oSecao1, /*bCondition*/,;
									/*uContent*/ oSecao1:Cell("WC_PER_FOB") ) 
									
oColl := TRCollection():New(, "SUM", /*oBreak*/,;
									/*cTitle*/"Total Saldo", /*cPicture*/"@E 999,999,999.99", /*uFormula*/ oSecao1:Cell("W2_MOEDA"),;
									/*.lEndSection.*/ .F., /*.lEndReport.*/ .T., /*oParent*/ oSecao1, /*bCondition*/,;
									/*uContent*/ oSecao1:Cell("WC_VLR_ABE") )

Return oReport


************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Cartas de Crédito")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Cartas de Crédito"),"SWC",1,{|| xFilial()+SWC->WC_LC_NUM})

oReport:SetMeter(TRB->(EasyRecCount("TRB")))
TRB->(dbGoTop())


//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Cartas de Crédito"):Init()

//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Cartas de Crédito"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Cartas de Crédito"):Finish()                                

return .T.
                                                                              
*----------------------------------------------------------------------------*
*                       FIM DO PROGRAMA TR370
*----------------------------------------------------------------------------*
