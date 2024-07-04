//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICTR340.CH"
#COMMAND E_RESET_AREA => SW5->(DBSETORDER(1)) ; SYI->(DBSETORDER(1)) ;
                       ; SWE->(DBSETORDER(1)) ; DBSELECTAREA(nOldArea)

#DEFINE OrdemItem STR0001 //"Ordem de Item"
#DEFINE OrdemGuia STR0002 //"Ordem de Guia"
#DEFINE GuiasA    STR0003 //"Guias Aprovadas"
#DEFINE GuiasN    STR0004 //"Guias Normais  "
#DEFINE GuiasB    STR0005 //"Ambas as Guias "
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR340 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 27.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Saldo de Guias                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR340()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR340

LOCAL WorkFile, WorkIndi, nOldArea:=SELECT()

LOCAL T_DBF:= { {"WKGI_NUM"   , "C" , 13 , 0} ,;
                {"WKPGI_NUM"  , "C" , 10 , 0} ,;
                {"WKQTDE"     , "N" , 13 , 3} ,;
                {"WKPRECO"    , "N" , 15 , 5} ,;
                {"WKDT_VEN"   , "D" ,  8 , 0} ,;
                {"WKCOD_I"    , "C" , 15 , 0} ,;
                {"WKAGI_NUM"  , "C" , 13 , 0} ,;
                {"WKFLUXO"    , "C" ,  2 , 0} ,;
                {"WKDTGI_AGI" , "C" ,  1 , 0} ,;
                {"WKPAGI_NUM" , "C" , 10 , 0} ,;
                {"OR_FILIAL"  , "C" ,  2 , 0} ,;
                {"WKFORN"     , "C" , 21 , 0} }

local _PictItem := ALLTRIM(X3Picture("B1_COD"))
local _PictPGI := ALLTRIM(X3Picture("W4_PGI_NUM"))
local _PictGI := ALLTRIM(X3Picture("W4_GI_NUM"))
local _PictPAGI := ALLTRIM(X3Picture("W4_PGI_NUM")), cPictPrUn := ALLTRIM(X3Picture("W3_PRECO"))
Local cPictQtde := ALLTRIM(X3Picture("W3_QTDE"))

LOCAL TB_Campos:=;
    { {"WKGI_NUM"  ,"", OemToAnsi(STR0006)    ,_PictGI        } ,; //"N§ G.I."
      {"WKCOD_I"   ,"", STR0007,_PictItem                        } ,; //"Item"
      {"WKFLUXO"   ,"", " "                                     } ,;
      {"WKFORN"    ,"", STR0008                            } ,; //"Fornecedor"
      {"WKPGI_NUM" ,"", OemToAnsi(STR0009)  ,_PictPGI       } ,; //"N§ P.G.I."
      {"WKAGI_NUM" ,"", OemToAnsi(STR0010),_PictGI       } ,; //"N§ do A.G.I." 
      {"WKPAGI_NUM","", OemToAnsi(STR0011),_PictPAGI   } ,; //"N§ do P.A.G.I."
      {"WKDT_VEN"  ,"", STR0012                            } ,; //"Vencimento"
      {"WKDTGI_AGI","", " "                                     } ,;
      {"WKPRECO"   ,"", OemToAnsi(STR0013),cPictPrUn   } ,; //"Valor Unit rio"
      {"WKQTDE"    ,"", STR0014,_PictQtde                  } } //"Saldo Qtde"

LOCAL cSaveMenuh, nCnt, cTitulo, oDlg, oGet, nOpcA:=0, TipoGuia

LOCAl cArea, cCampo, cFluxo

PRIVATE cMarca := GetMark(), lInverte := .F., _PictPrUn:=cPictPrUn, _PictQtde:=cPictQtde

PRIVATE cCadastro := OemtoAnsi(STR0015), TCod_I, TDt_I, TDt_F //"Saldo de GIs"


//PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
//        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

Private aHeader[0],nUsado:=0

//bHotArea:= {|| HotAreas(10, 4,17,75,nUsado)}
//bCampo  := {|nCPO| Field(nCPO) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F10 para acessar os parametros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SetKey( VK_F12,{ || pergunte("EIC340",.T.) } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Data inicial                               ³
//³ mv_par02      // Data final                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ! Pergunte("EIC340",.T.)
   RETURN .F.
ENDIF

TCod_I     :=mv_par01
MMenu      :=mv_par02
MOrdem_Menu:=mv_par03

IF MMenu = 1
   cTitulo     := OrdemItem
   TB_Campos[1]:= {"WKCOD_I"   ,"", "Item",_PictItem }
   TB_Campos[2]:= {"WKFLUXO"   ,"", " "              }
   TB_Campos[3]:= {"WKGI_NUM"  ,"", OemToAnsi("N§ G.I."),_PictGI}
ELSE
   cTitulo:= OrdemGuia
ENDIF

DO CASE
   CASE MOrdem_Menu = 1
        cTitulo+=" - "+GuiasA
        TipoGuia:= 'A'

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Variaveis utilizadas para parametros ³
        //³ mv_par01       // Data inicial       ³
        //³ mv_par02      // Data final          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        IF ! Pergunte("EIC010",.T.)
           RETURN .F.
        ENDIF
        TDt_I:=mv_par01
        TDt_F:=mv_par02

        IF ! EMPTY(TDt_I) .AND. ! EMPTY(TDt_F)
           cTitulo+= ' Periodo : '+DTOC(TDt_I)+' a '+DTOC(TDt_F)
        ENDIF
        TipoGuia:= 'A'

   CASE MOrdem_Menu = 2
        TipoGuia:= 'N'
        cTitulo+=" - "+GuiasN

   CASE MOrdem_Menu = 3
        TipoGuia:= 'B'
        cTitulo+=" - "+GuiasB

ENDCASE

IF TipoGuia # 'A'
   cArea:="SW5" ; cCampo:="W5_" ; cFluxo:="15"
ELSE
   cArea:="SWE" ; cCampo:="WE_" ; cFluxo:="2"
ENDIF

SW5->(DBSETORDER(5))
SYI->(DBSETORDER(2))
SWE->(DBSETORDER(2))

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IF MMenu = 2
  IndRegua("Work",WorkFile+TEOrdBagExt(),,"WKGI_NUM")
ELSE
  IndRegua("Work",WorkFile+TEOrdBagExt(),"WKCOD_I")
ENDIF

MsAguarde({|lEnd| (cArea)->(TR340Grava({|msg| MsProcTxt(OemToAnsi(msg))},;
                                       cCampo,cFluxo,TipoGuia)) },;
          STR0016)//"Pesquisando informa‡äes..."

IF Work->(Easyreccount("Work")) > 0

   DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo) From 9,0 To 28,80 OF oMainWnd

   DEFINE SBUTTON FROM 18,285 TYPE 6 ACTION (Help(" ",1,"EICEMDESEN")) ENABLE OF oDlg

   oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{35,1,140,315})
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
ENDIF

Set Key VK_F12 To

IF Work->(Easyreccount("Work")) = 0
   Help(" ",1,"EICSEMREG")
ENDIF

If nOpcA==2
// RELATORIO
Endif
Work->(E_EraseArq(WorkFile,WorkIndi))
E_RESET_AREA
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR340Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 27/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR340Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------*
STATIC FUNCTION TR340Grava(bMsg,Prefixo,PFluxo,PTipo)
*----------------------------------------------------------------------------*
Local _PictItem := ALLTRIM(X3Picture("B1_COD"))

LOCAL PSeq, PSaldo_q, PPGI_Num, PCod_I, PPreco, PForn, PFilial

IF(EMPTY(TCod_I), DBGOTOP(), DBSEEK(xFilial()+TCod_I))

WHILE ! EOF()

      PSeq    :=FIELDGET(FIELDPOS(Prefixo+"SEQ"))
      PSaldo_q:=FIELDGET(FIELDPOS(Prefixo+"SALDO_Q"))
      PPGI_Num:=FIELDGET(FIELDPOS(Prefixo+"PGI_NUM"))
      PCod_I  :=FIELDGET(FIELDPOS(Prefixo+"COD_I"))
      PPreco  :=FIELDGET(FIELDPOS(Prefixo+"PRECO"))
      PForn   :=FIELDGET(FIELDPOS(Prefixo+"FORN"))
      PFilial :=FIELDGET(FIELDPOS(Prefixo+"FILIAL"))

      Eval(bMsg,STR0017 + TRAN(PPGI_Num,_PictPGI)+STR0018+TRAN(PCod_I,_PictItem))//"Processando P.G.I. N§ "###" - Ötem "

      IF ! EMPTY(TCOD_I) .AND. TCOD_I # PCod_I
         EXIT
      ENDIF

     IF PSeq # 0 .OR. PSaldo_q = 0
        DBSKIP() ; LOOP
     ENDIF

     SW4->( DBSEEK(PFilial+PPGI_Num) )

     IF ! AT(SW4->W4_FLUXO,PFluxo) # 0 .OR. EMPTY(SW4->W4_GI_NUM)
        DBSKIP() ; LOOP
     ENDIF

     IF PTipo = "A"
        IF ! EMPTY(TDt_I) .AND. TDt_I > SW4->W4_DT
           DBSKIP() ; LOOP
        ENDIF

        IF ! EMPTY(TDt_F) .AND. TDt_F < SW4->W4_DT
           DBSKIP() ; LOOP
        ENDIF
     ENDIF

     Work->( DBAPPEND() )
     Work->WKPGI_NUM:= PPGI_Num
     Work->WKCOD_I  := PCod_I
     Work->WKFLUXO  := IF(AT(PFluxo,'15') # 0,' N',' A')
     Work->WKQTDE   := PSaldo_q
     Work->WKPRECO  := PPreco
     Work->WKFORN   := PForn+" "+(SA2->(DBSEEK(PFilial+PForn)),SA2->A2_NREDUZ)

     IF ! SW4->( EOF() )

          Work->WKGI_NUM:=SW4->W4_GI_NUM
          Work->WKDT_VEN:=SW4->W4_DT_VEN

          IF ! EMPTY(SW4->W4_DT_VEN)
               Work->WKDTGI_AGI:="G"
          ENDIF
     ENDIF

     IF TR174VerAditivo()
        Work->WKAGI_NUM :=SYI->YI_AGI_NUM
        Work->WKPAGI_NUM:=SYI->YI_PAGI_NUM

        IF ! EMPTY(SYI->YI_AGI_VEN)
           Work->WKDT_VEN  :=SYI->YI_AGI_VEN
           Work->WKDTGI_AGI:="A"
        ENDIF
     ENDIF

     IF Work->WKDT_VEN < dDataBase
        Work->(DBDELETE())
     ENDIF

     DBSKIP()
ENDDO

IF PTipo = "B"
   SWE->(TR340Grava(bMsg,"WE_","2","A"))
ENDIF

RETURN .T.
*----------------------------------------------------------------------------
STATIC FUNCTION TR174VerAditivo()
*----------------------------------------------------------------------------
LOCAL MREC:= 0

SYI->( DBSEEK(SW4->W4_FILIAL+SW4->W4_GI_NUM) )

WHILE ! SYI->( EOF() ) .AND. SW4->W4_GI_NUM = SYI->YI_GI_NUM .AND. ;
                             SW4->W4_FILIAL = SYI->YI_FILIAL
   MRec:= RECNO()
   SYI->(DBSKIP())
ENDDO

IF MRec > 0
   SYI->(DBGOTO(MRec))
   RETURN .T.
ENDIF

RETURN .F.
*----------------------------------------------------------------------------
FUNCTION TR340ValItem()
*----------------------------------------------------------------------------
If !Empty(mv_par01) .AND. ! SB1->(DBSeek(xFilial()+mv_par01))
   Help(" ",1,"REGNOIS")
   Return .F.
Endif

Return .T.

