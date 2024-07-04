#INCLUDE "Eicor100.ch"
#include "Average.ch"
#include 'ap5mail.ch'
#INCLUDE "TOPCONN.CH"

#Define TY6DIASPA AvSX3("Y6_DIAS_PA", AV_TAMANHO)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EICOR101  ³ Autor ³ AVERAGE-RS            ³ Data ³ 30/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio ao Siscomex                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICOR101
LOCAL cCadastro := ""
LOCAL cTitulo   := STR0001 //"Extra‡ao de Dados para o Orientador"

PRIVATE ENVIA_ORIENTADOR:= 1
PRIVATE ENVIA_GIPLITE   := 2
PRIVATE ENVIA_DESPACHANTE:=3
PRIVATE FASE_PO         := 1
PRIVATE FASE_DI         := 2
PRIVATE cFase           := FASE_PO //Private por causa da validacao no SX1
PRIVATE TOpcao          := ENVIA_ORIENTADOR
PRIVATE lInv            := .F.
Private lLiberaUso      := .F.

If(EasyEntryPoint("EICOR100"),Execblock("EICOR100",.F.,.F.,"LIBERAUSO"),)

if ! lLiberaUso
   MsgStop(STR0222,STR0223)  //"Devido à evolução tecnológica, a integração 'L.I. Easy-Siscomex' que fazia uso do SISC (aplicação em Visual Basic) foi descontinuada.						  
   //Return()				  //Para as integrações da Licença de Importação com o SISCOMEX, passa-se a ser usada a opção:  'Integ. Siscomex WEB' (EICDI100)" ##"Atenção"
else
   Ori100Main(cCADASTRO,cTitulo,ENVIA_ORIENTADOR)
   SX3->(DBSETORDER(1))
endif

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EICOR102  ³ Autor ³ AVERAGE-RS            ³ Data ³ 30/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio ao Gip-Lite                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------------------------------------------------------*
Function EICOR102()
*---------------------------------------------------------------------------*
LOCAL  cCadastro := ""
LOCAL  cTitulo   := STR0002 //"Extra‡ao de Dados para o Gip-Lite"
Local cArqDest := ""
PRIVATE ENVIA_ORIENTADOR:= 1
PRIVATE ENVIA_GIPLITE   := 2
PRIVATE ENVIA_DESPACHANTE:=3
PRIVATE FASE_PO         := 1
PRIVATE FASE_DI         := 2
PRIVATE TOpcao    := ENVIA_GIPLITE
PRIVATE lInv := .F.

// BAK - 23/03/2011 - Alteração feita para nova integração com despachante
If Type("cFaseOR102") == "C"
   cCadastro := cFaseOR102
   cTitulo   := StrTran(STR0002, "Gip-Lite", "Despachante")
EndIf

   // BAK - Alteração realizada para nova integração com despachante
   // Ori100Main(cCADASTRO,cTitulo,ENVIA_GIPLITE)
   cArqDest := Ori100Main(cCADASTRO,cTitulo,ENVIA_GIPLITE)

//RETURN NIL
RETURN cArqDest
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EICOR103  ³ Autor ³ AVERAGE-RS            ³ Data ³ 30/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio a LogimeX                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PHILIPS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*---------------------------------------------------------------------------*
Function EICOR103
*---------------------------------------------------------------------------*
LOCAL  cCadastro := ""
LOCAL  cTitulo   := "Extração de Dados para o Despachante"
PRIVATE ENVIA_ORIENTADOR:= 1
PRIVATE ENVIA_GIPLITE   := 2
PRIVATE ENVIA_DESPACHANTE:=3
PRIVATE FASE_PO         := 1
PRIVATE FASE_DI         := 2

PRIVATE TOpcao    := ENVIA_DESPACHANTE
PRIVATE cFase     := FASE_DI
PRIVATE lInv := .F.

Ori100Main(cCADASTRO,cTitulo,ENVIA_DESPACHANTE)

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ORI100Main³ Autor ³ AVERAGE-MJBARROS/RS   ³ Data ³ 24/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina Principal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*---------------------------------------------------------------------------*
STATIC FUNCTION Ori100Main(cCADASTRO,cTitulo,TOpcao)
*---------------------------------------------------------------------------*
LOCAL cAlias:=SELECT("SX2"), lValid_Maq:=.T.
LOCAL bMarca:={|lTodos|ORI100Marca(lTodos),oMark:oBrowse:Refresh()}
LOCAL cTitulo2:="Envio ao Siscomex (LI/LSI)",oDlgLI
LOCAL TB_Campos:={}, cCodMaq, aSemSx3:={}, cHawb
LOCAL bOk:={||(nOpca:=1,If(cTipo<>0,If(ORI100Val("LI1").AND.ORI100Val("LI2"),oDlg:End(),),))}
LOCAL bCancel:={||(nOpca:=0,oDlg:End())}
LOCAL bPesquisa:={||OR100PESQ(),oMark:oBrowse:REFRESH()}

Local cArqDest := "" // BAK - Alteração feita para a nova integração com o despachante
Local aButtons := "" // BAK - Alteração feita para a nova integração com o despachante

PRIVATE lAdsLocal:=GETNEWPAR("MV_ADSLOCA",.T.) // RJB 18/07/2005
PRIVATE nEscolha:=2// Tem que iniciar com 2 por que pode nao ter LSI
PRIVATE bWhile:={||.T.},bFor:={||.T.},cQuery:=" ", bPrint:={||.T.}//As query's foram desativadas por causa do campo WP_P_FORA - AWR 09/01/2004
PRIVATE lTop:=.T. // TDF - 23/01/13 - Variável para tratamento via query
PRIVATE aMaquinas:={}, nTotalMarca:=0, nColExtra:=0,TOTLIN:=2000
Private aHeader[0], nOpca:=1, Valor[0]
Private aCampos:={"WP_PGI_NUM","WP_SEQ_LI" ,;
                  "WP_NR_MAQ","WP_MICRO"  ,"WP_PROT"   ,;
                  "WP_TRANSM","WP_ENV_ORI","WP_RET_ORI",;
                  "WP_FABR"  ,"WP_NCM"    ,"WP_ERRO"   ,;
                  "WP_ALADI" ,"WP_NALADI" }
PRIVATE cNomArq,cNomWork,FileWk2,FileWk3,FileWk1,FileWk4
PRIVATE cMarca := GetMark(), lInverte := .F.,aMarcados
PRIVATE lSair, cTipo ,cEmpr,cEnvio := .F.
PRIVATE aTab_Marca:={},cPos_Chave,cPos_Data,cPos_Aux,cPos_Codi,cCodigo,cData:=dDataBase
PRIVATE cVarWhile,cArq_Dest,cArqTxt
Private lTemDSI:=GETNEWPAR("MV_TEM_DSI",.F.) //LRL 12/02/04
PRIVATE LETR_ARQ := {|| IF(cFase=2,IF(lInv,"W8_","W7_"),"W3_" )                                       }
PRIVATE COD_I    := {|| (IF(lInv,(NewArea),(OldArea)))->(FIELDGET(FIELDPOS(EVAL(LETR_ARQ)+'COD_I')))}
PRIVATE QTDE     := {|| (IF(lInv,(NewArea),(OldArea)))->(FIELDGET(FIELDPOS(EVAL(LETR_ARQ)+'QTDE')))         }
PRIVATE FABR     := {|| (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'FABR')))         }
PRIVATE FORN     := {|| (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'FORN')))         }
PRIVATE PRECO    := {|| (IF(lInv,(NewArea),(OldArea)))->(FIELDGET(FIELDPOS(EVAL(LETR_ARQ)+'PRECO')))        }
PRIVATE CC       := {|| (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'CC')))           }
PRIVATE REG      := {|| (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'REG')))          }
PRIVATE SEQ      := {|| (OldArea)->(FIELDGET(FIELDPOS(IF(cFase=FASE_DI,"W7_","W3_")+'SEQ')))          }
PRIVATE CAMPO    := {|| IF(cPos_Aux = 0,FIELDGET(cPos_Chave),FIELDGET(cPos_Chave)+FIELDGET(cPos_Aux)) }
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT"))
Private _PictQtde := ALLTRIM(X3Picture("W3_QTDE")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private _FirstYear:= Right(Padl(Set(_SET_EPOCH),4,"0"),2)
Private oPanel //LRL 22/03/04
Private cArqTrabP //TRP 18/06/07
Private nContador //TRP 03/09/07 -Variável utilizada em rdmake
//FILIAL
PRIVATE cFilSWP:=xFilial("SWP"),cFilSW2:=xFilial("SW2"),cFilSW6:=xFilial("SW6")

// variavel p/ verificar se existem os cpos p/ o tratamento do pgto antecipado.
PRIVATE lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado

//VARIAVEIS PARA A HUNTER AWR 11/11/1999
PRIVATE lHunter  := EasyEntryPoint("IC010DI1")

// Variaveis usadas no rdmake EICPOR01.PRW
PRIVATE nTamPad := nTamReg := 350 // Tamanho do registro no arq.de envio
                                  // ao despachante
PRIVATE lEicPOR01 := EasyEntryPoint("EICPOR01"), cRdPad01 := "EICPOR01"

// PLB 06/08/07 - Referente tratamento de Incoterm, Frete e Regime de Tributação na LI (ver chamado 054617)
Private lW4_Reg_Tri := SW4->( FieldPos("W4_REG_TRI") ) > 0
Private lW4_Fre_Inc := SW4->( FieldPos("W4_FREINC" ) ) > 0
Private lSegInc := SW4->(FIELDPOS("W4_SEGINC")) # 0 .AND. SW4->(FIELDPOS("W4_SEGURO")) # 0 .AND.;  // EOB - 14/07/08 - Inclusão do tratamento de incoterm com seguro
                   SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0
//Private lNVE := EasyGParam("MV_EIC0011",,.F.) //BCO - 04/10/12 Checa se o parametro MV_EIC0011 esta ligado  // TRP - 27/02/2013

// BAK - Alteração para Nova Integração com despachante
Private lIntDesp := IsInCallStack("EICEI100")
Private lCposNVEPLI := (EIM->(FIELDPOS("EIM_FASE")) # 0 .And. SW5->(FIELDPOS("W5_NVE")) # 0 .And. EasyGParam("MV_EIC0011",,.F.) )
_PictPGI  := ALLTRIM(X3Picture("W4_PGI_NUM"))

#IFNDEF TOP  //TDF - 23/01/13 - Caso ambiente não seja TOP, desativa variável para tratamento de query
   lTop:=.F.
#ENDIF

EICAddLoja(aCampos, "WP_FABLOJ", Nil, "WP_FABR")
If EasyEntryPoint("EICOR10E")
   ExecBlock("EICOR10E",.f.,.f.)
Endif

WHILE .T.
   ASIZE(Tb_Campos,0)
   TDt_I := TDt_F := dDataBase
   lVazio := .T.
   lSair := .F.

   IF TOpcao == ENVIA_GIPLITE
      cCodigo:=SPACE(03)

      // BAK - Alteração feita para a nova integração com despachante
      If Empty(cCadastro) .And. !lIntDesp
         IF ! Pergunte("EIOR01",.T.)
            ORI100Final() ; RETURN ""
         ENDIF
         cFase:=mv_par01
      Else
         Do Case
            Case cCadastro == "PO"
               cFase := FASE_PO
            Case cCadastro == "DI"
               cFase := FASE_DI
            Otherwise
               Return ""
         End Case
      EndIf
   ENDIF

   DO WHILE .T.

      IF lSair
         EXIT
      ENDIF

      ASIZE(TB_Campos,0)
      DO CASE
         CASE TOpcao == ENVIA_ORIENTADOR .AND. cFase == FASE_PO
              ORI100Final()
              aSemSX3:={{"WP_FLAGWIN","C",AVSX3("WP_FLAGWIN",3),0}}
              cNomArq:=E_CriaTrab(,aSemSX3)
              INDREGUA(ALIAS(),cNOMARQ+TEOrdBagExt(),"WP_PGI_NUM+WP_SEQ_LI")

              AADD(TB_Campos,{"WP_FLAGWIN",,"  "})
              AADD(TB_Campos,{{||Transform(TRB->WP_PGI_NUM,_PictPGI)+' - '+WP_SEQ_LI},,AVSX3("WP_PGI_NUM",05) }) //STR0003"LI (EASY)"
              AADD(TB_Campos,{{||TRB->WP_NR_MAQ+' - '+TRB->WP_MICRO},, AVSX3("WP_NR_MAQ",05)  }) //STR0004 "Maquina"
              AADD(TB_Campos,{{||TRB->WP_PROT+' - '+DTOC(TRB->WP_TRANSM)},,AVSX3("WP_PROT",05)}) //STR0005"Transmissao (Protocolo)"
              AADD(TB_Campos,{"WP_ENV_ORI",,AVSX3("WP_ENV_ORI",05)}) //STR0006"Envio ao ORIENTADOR"
              AADD(TB_Campos,{"WP_RET_ORI",,AVSX3("WP_RET_ORI",05)}) //STR0007"Ultimo Retorno"
              AADD(TB_Campos,{{||ORI100Status()},,"Status"}) //"Status"
              AADD(TB_Campos,{"WP_NCM",,AVSX3("WP_NCM",5),'@R 9999.99.99'}) //"N.C.M."
              AADD(TB_Campos,{{||ORI100Fabricante()},,AVSX3("WP_FABRDES",5)}) //"Fabricante"
              AADD(TB_Campos,{"WP_NALADI",,AVSX3("WP_NALADI",5)}) //"NALADI"
              AADD(TB_Campos,{"WP_ALADI",,AVSX3("WP_ALADI",5)}) //"ALADI"

              cPos_Data  := SWP->(FIELDPOS('WP_ENV_ORI'))
              cPos_Chave := SWP->(FIELDPOS('WP_PGI_NUM'))
              cPos_Aux   := SWP->(FIELDPOS('WP_SEQ_LI'))
              cPos_Codi  := SWP->(FIELDPOS('WP_NR_MAQ'))

              IF lTemDSI
                 nEscolha:=1
                 
                 DEFINE MSDIALOG oDlgLI FROM  50,30 TO 230,380 TITLE cTitulo2 PIXEL Of oMainWnd
                 
                     oPanel:= TPanel():New(0, 0, "", oDlgLI,, .F., .F.,,, 90, 165)
                     oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

                     @ 3, 6 TO 50, 133 LABEL "Tipo de Processo" OF oPanel  PIXEL
                     @ 13,20 RADIO oRad VAR nEscolha ITEMS "LSI","LI" 3D SIZE 37,11 OF oPanel PIXEL

                 ACTIVATE MSDIALOG oDlgLI ON INIT EnchoiceBar(oDlgLI,{||oDlgLI:End()}, {||(oDlgLI:End())}) CENTERED
              ENDIF

              TLi := SPACE(10) ; TSeq := SPACE(3)
              nOpca:=0
              cTipo:=1



              aItensEnv := { STR0014, STR0015 }

              DEFINE MSDIALOG oDlg FROM 91,30 TO 252,435 TITLE cTitulo PIXEL Of oMainWnd

              oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
              oPanel:Align:= CONTROL_ALIGN_ALLCLIENT


              oRadio:= tRadMenu():New(25,07,aItensEnv,;
                 {|u|if(PCount()>0,cTipo:=u,cTipo)},;
                 oPanel,,,,,,,,100,20,,,,.T.)


              IF nEscolha==1
                 @ 14, 6 SAY "No. LSI (EASY)" SIZE 40, 7 OF oPanel PIXEL
              ELSE
                 @ 14, 6 SAY STR0016 SIZE 40, 7 OF oPanel PIXEL //"No. LI (EASY)"
              ENDIF

              @ 13,  51 MSGET TLi  PICTURE _PictPgi VALID (ORI100Val("LI1"))                  SIZE 38, 10 OF oPanel PIXEL //LRL 12/02/04
              @ 13, 110 MSGET TSeq PICTURE "999"    VALID (ORI100Val("LI2")) WHEN !EMPTY(TLi) SIZE 23, 10 OF oPanel PIXEL

              ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

              /*
              DEFINE MSDIALOG oDlg FROM  91,30 TO 252,435 TITLE cTitulo PIXEL Of oMainWnd

              @ 29, 6 TO 73, 133 LABEL STR0013 OF oDlg  PIXEL //"Selecao"

              @ 40,7 RADIO oTipo VAR cTipo ITEMS STR0014,; //"Processos nao Enviados"
                                                 STR0015 ; //"Processos ja  Enviados"
                                           3D SIZE 80,10 PIXEL

              IF nEscolha==1
                 @ 14, 6 SAY "No. LSI (EASY)" SIZE 40, 7 OF oDlg PIXEL
              ELSE
                 @ 14, 6 SAY STR0016 SIZE 40, 7 OF oDlg PIXEL //"No. LI (EASY)"
              ENDIF

              @ 13,  51 MSGET TLi  PICTURE _PictPgi VALID (ORI100Val("LI1"))                  SIZE 38, 10 OF oDlg PIXEL //LRL 12/02/04
              @ 13, 110 MSGET TSeq PICTURE "999"    VALID (ORI100Val("LI2")) WHEN !EMPTY(TLi) SIZE 23, 10 OF oDlg PIXEL

              ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED*/

              If nOpca == 0
                 ORI100Final()
                 Return "" // BAK - Alteração feita para a nova integração com despachante
              Endif

              IF cTipo==2 .AND. lVazio
                lValid_Maq:=ORI100GetData()
              ENDIF

              IF ! lValid_Maq
                 lValid_Maq:=.T.
                 LOOP
              ENDIF

              IF(! EMPTY(TLi).AND.! EMPTY(TSeq),cTipo:=0,)

              bPrint:={|| Processa({|lEnd| ORI100Ret( 'TRB' )}),IF(VALTYPE(oMark)=="O",oMark:oBrowse:Refresh(),)}

              IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"IMPRIME_RET"),)

              IF(lTop)
                 cQuery:=" SELECT * FROM "+RetSqlName("SWP")+" SWP WHERE "+;
                         " SWP.WP_FILIAL='"+cFilSWP+"'"
              ENDIF

              IF lVazio
                 SWP->(DBSETORDER(4))
                 SWP->(DBSEEK(xFilial("SWP")))
                 IF cTipo==1//PROC_NAO_ENVIADO
                    bWhile:={||EMPTY(SWP->WP_ENV_ORI)}
                    cQuery+=" AND SWP.WP_ENV_ORI=' '"
                    IF !EMPTY(cCodigo)
                       bFor :={||SWP->WP_NR_MAQ == cCodigo .AND. SWP->WP_P_FORA==.F.}
                       cQuery+=" AND SWP.WP_NR_MAQ='"+cCodigo+"'AND SWP.WP_P_FORA='F' "
                    ELSE
                       bFor :={||SWP->WP_P_FORA==.F.}
                       cQuery+=" AND SWP.WP_P_FORA='F' "
                    ENDIF
                    IF nEscolha==1//AWR
                       IF !EMPTY(cCodigo)
                          bFor :={|| !SWP->WP_P_FORA .AND. SWP->WP_LSI = "1" .AND. SWP->WP_NR_MAQ == cCodigo }
                       ELSE
                          bFor :={|| !SWP->WP_P_FORA .AND. SWP->WP_LSI = "1" }
                       ENDIF
                       cQuery+=" AND SWP.WP_LSI = '1' "
                    ELSEIF lTemDSI//AWR
                       IF !EMPTY(cCodigo)
                          bFor :={|| !SWP->WP_P_FORA .AND. SWP->WP_LSI # "1" .AND. SWP->WP_NR_MAQ == cCodigo }
                       ELSE
                          bFor :={|| !SWP->WP_P_FORA .AND. SWP->WP_LSI # "1" }
                       ENDIF
                       cQuery+=" AND SWP.WP_LSI <> '1' "
                    ENDIF
                 ELSE  //PROC_JA_ENVIADO
                    E_PERIODO_OK(@TDt_I,@TDt_F)
                    SWP->(DBSEEK(xFilial("SWP")+DTOS(TDt_I),.T.))
                    bWhile:={|| SWP->WP_ENV_ORI <= TDt_F}
                    bFor  :={|| SWP->WP_NR_MAQ  == cCodigo .AND. SWP->WP_P_FORA==.F.}
                    cQuery+=" AND SWP.WP_ENV_ORI BETWEEN '"+DTOS(TDt_I)+"' AND '"+DTOS(TDt_F)+"'"
                    cQuery+=" AND SWP.WP_NR_MAQ='"+cCodigo+"'AND SWP.WP_P_FORA='F' "
                    IF nEscolha==1//AWR
                       bFor:={||SWP->WP_NR_MAQ == cCodigo .AND. !SWP->WP_P_FORA .AND. SWP->WP_LSI = "1" }
                       cQuery+=" AND SWP.WP_LSI = '1' "
                    ELSEIF lTemDSI//AWR
                       bFor:={||SWP->WP_NR_MAQ == cCodigo .AND. !SWP->WP_P_FORA .AND. SWP->WP_LSI # "1" }
                       cQuery+=" AND SWP.WP_LSI <> '1' "
                    ENDIF
                 ENDIF
              ELSE
                 SWP->(DBSETORDER(1))
                 SWP->(DBSEEK(xFilial("SWP")+ALLTRIM(cVarWhile)))
                 bFor:={||.T.}


                 IF Empty(Right(cVarWhile,3))
                    bWhile:={||SWP->WP_PGI_NUM ==LEFT(cVarWhile,10)}
                    cQuery+=" AND SWP.WP_PGI_NUM='" +LEFT(cVarWhile,10)+"'"
                 ELSE
                    bWhile:={||SWP->WP_PGI_NUM+SWP->WP_SEQ_LI ==cVarWhile}
                    cQuery+=" AND SWP.WP_PGI_NUM='"+LEFT(cVarWhile,10)+"'"+;
                            " AND SWP.WP_SEQ_LI='" +RIGHT(cVarWhile,3)+"'"
                 ENDIF
                 IF nEscolha==1
                    bFor:={|| SWP->WP_LSI = "1" }
                    cQuery+=" AND SWP.WP_LSI = '1' "
                 ENDIF
              ENDIF

              cQuery+=" AND SWP.D_E_L_E_T_<>'*'"
              Processa({|| ORI100SWPWORK()})

         CASE TOpcao = ENVIA_GIPLITE .AND. cFase = FASE_PO

              IF !Pergunte("EIOR02",.T.)
                 lSair:=.T.;return ""//exit // BAK - Alteração feita para a nova integração com despachante
              ENDIF

              ASIZE(aCampos,0)
              aCampos:={"W2_PO_NUM"}

              aSemSx3:={ {"WP_FLAGWIN","C",AVSX3("WP_FLAGWIN",3),0},;
                         {"W2_ENV_ORI","D",8,0} ,;
                         {"W2_ARQ","C",12,0} ,;
                         {"W2_DESP","C",TamSx3("W2_DESP")[1],0} }

              ORI100Final()
              cNomArq:=E_CriaTrab(,aSemSx3)
              INDREGUA(ALIAS(),cNOMARQ+TEOrdBagExt(),"W2_PO_NUM+DTOS(W2_ENV_ORI)")

              AEVAL(aSemSx3,{|Campo|AADD(aCampos,Campo[1])})
              AADD(TB_Campos,{"WP_FLAGWIN",,"  "})
              AADD(TB_Campos,{"W2_PO_NUM",,AVSX3("W2_PO_NUM",05),_PictPO}) //STR0017"No. PO"
              AADD(TB_Campos,{"W2_ENV_ORI",, AVSX3("W2_ENV_ORI",05)}) //STR0018"Envio ao GIP - LITE"
              AADD(TB_Campos,{"W2_ARQ",, AVSX3("W2_ARQ",05)}) //STR0019"Nome do Arquivo"
              AADD(TB_Campos,{{||ORI100BuscaDesp(TRB->W2_DESP)},,AVSX3("W2_DESP",05) }) //STR0020"Despachante"


              cPos_Data  := SW2->(FIELDPOS('W2_ENV_ORI'))
              cPos_Chave := SW2->(FIELDPOS('W2_PO_NUM'))
              cPos_Aux   := 0
              cPos_Codi  := SW2->(FIELDPOS('W2_DESP'))


              TPO_NUM:=mv_par01
              cTipo:=mv_par02
              cCodigo:=mv_par03

              // BAK - Alteração para a nova integração com despachante
              SY5->(DbSetOrder(1))
              If SY5->(DBSEEK(xFilial("SY5")+AvKey(cCodigo,"Y5_COD")))
                 If lIntDesp .And. !Empty(cCadastro)
                    cCodDeEI100  := SY5->Y5_COD
                    cDespEI100   := SY5->Y5_NOME
                    cEmailEI100  := SY5->Y5_EMAIL
                 EndIf
              Else
                 Help("", 1, "AVG0000305")
                 Loop
              EndIf

              //If !SY5->(DBSEEK(xFilial("SY5")+cCodigo ))
              //    Help("", 1, "AVG0000305")
              //    Loop
              //EndIf

              // BAK - Alteração realizada para melhoria da impressao de relatorio caso nao fosse selecionado o registro , TRB->(DBGoTop())
	          // bPrint:={|| Processa({|| ORI100Rel(TOpcao,cFase,@cEnvio)}) }
	          bPrint:={|| Processa({|| ORI100Rel(TOpcao,cFase,@cEnvio) , TRB->(DBGoTop()) }) }

              IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ALTERA_BPRINT_1"),)//"IMPRIME_REL"

              IF(lTop)
                 cQuery:=" SELECT * FROM "+RetSqlName("SW2")+" SW2 WHERE "+;
                 " SW2.W2_FILIAL='"+cFilSW2+"'"
              ENDIF
              IF lVazio
                 DO WHILE .T.
                    IF cTipo == 2 //PROC_JA_ENVIADO
                       IF ! Pergunte("EIOR04",.T.)
                          lSair:=.T.
                          EXIT
                       ENDIF
                       TDt_I:=mv_par01
                       TDt_F:=mv_par02
                    ENDIF
                    EXIT
                 ENDDO
                 IF lSair
                    lSair:=.F.
                    LOOP
                 ENDIF
                 SW2->(DBSETORDER(5))

                 IF cTipo==1//PROC_NAO_ENVIADO
                    SW2->(DBSEEK(cFilSW2))

                    //RMD - 30/08/12 - Adicionado o filtro do despachante
                    bWhile := {|| EMPTY(SW2->W2_ENV_ORI) .And. (Empty(cCodigo) .Or. SW2->W2_DESP == cCodigo)}
                    If(!Empty(cCodigo), cQuery += " AND SW2.W2_DESP = '" + cCodigo + "'",)
                    //bWhile:={|| EMPTY(SW2->W2_ENV_ORI)}

                    cQuery+=" AND  SW2.W2_ENV_ORI=' '"
                 ELSE
                    E_PERIODO_OK(@TDt_I,@TDt_F)
                    SW2->(DBSEEK(cFilSW2+DTOS(TDt_I),.T.))

                    //RMD - 30/08/12 - Adicionado o filtro do despachante
                    bWhile:={||SW2->W2_ENV_ORI<=TDt_F .And. (Empty(cCodigo) .Or. SW2->W2_DESP == cCodigo)}
                    If(!Empty(cCodigo), cQuery += " AND SW2.W2_DESP = '" + cCodigo + "'",)
                    //bWhile:={||SW2->W2_ENV_ORI<=TDt_F}

                    cQuery+=" AND  SW2.W2_ENV_ORI BETWEEN '"+DTOS(TDt_I)+"' AND '"+DTOS(TDt_F)+"'"
                 ENDIF
              ELSE
                 SW2->(DBSETORDER(1))
                 SW2->(DBSEEK(cFilSW2+TPO_NUM))

                 //RMD - 30/08/12 - Adicionado o filtro do despachante
                 bWhile:={||SW2->W2_PO_NUM==TPO_NUM .And. (Empty(cCodigo) .Or. SW2->W2_DESP == cCodigo)}
                 If(!Empty(cCodigo), cQuery += " AND SW2.W2_DESP = '" + cCodigo + "'",)
                 //bWhile:={||SW2->W2_PO_NUM==TPO_NUM}

                 cQuery+=" AND SW2.W2_PO_NUM='"+TPO_NUM+"'"
              ENDIF

              cQuery+=" AND SW2.D_E_L_E_T_<>'*'"
              Processa({|| ORI100SW2WORK()})

         CASE (TOpcao = ENVIA_GIPLITE .AND. cFase = FASE_DI) .OR. TOpcao = ENVIA_DESPACHANTE

              ASIZE(aCampos,0)
              aCampos:={"W6_HAWB"}

              aSemSx3:={ {"WP_FLAGWIN","C",Avsx3("WP_FLAGWIN",3),0},;
                         {"W6_ENV_ORI","D",8,0} ,;
                         {"W6_ARQ","C",12,0} ,;
                         {"W6_DESP","C",TamSx3("W6_DESP")[1],0} }


              AADD(TB_Campos,{"WP_FLAGWIN",,"  "})
              AADD(TB_Campos,{"W6_HAWB",,AVSX3("W6_HAWB",05) }) //STR0021"No.Proc."
              AADD(TB_Campos,{"W6_ENV_ORI",,AVSX3("W6_ENV_ORI",05)}) //STR0018"Envio ao GIP - LITE"
              AADD(TB_Campos,{"W6_ARQ",,AVSX3("W6_ARQ",05) }) //STR0019"Nome do Arquivo"
              AADD(TB_Campos,{ {||ORI100BuscaDesp(TRB->W6_DESP)},,AVSX3("W6_DESP",05) }) //STR0020"Despachante"

              ORI100Final()
              cNomArq:=E_CriaTrab(,aSemSx3)
              INDREGUA(ALIAS(),cNomArq+TEOrdBagExt(),"W6_HAWB+DTOS(W6_ENV_ORI)")

              cPos_Data  := SW6->(FIELDPOS('W6_ENV_ORI'))
              cPos_Chave := SW6->(FIELDPOS('W6_HAWB'))
              cPos_Aux   := 0
              cPos_Codi  := SW6->(FIELDPOS('W6_DESP'))

              IF TOpcao = ENVIA_GIPLITE

                 DO WHILE .T.
                    IF ! Pergunte("EIOR03",.T.)
                       lSair:=.T. ; Return ""//EXIT // BAK - Alteração feita para a nova integração com despachante
                    ENDIF

                    cHawb:=mv_par01
                    cTipo:=mv_par02
                    cCodigo:=mv_par03

                    // BAK - Alteração para a nova integração com despachante
                    SY5->(DbSetOrder(1))
                    If SY5->(DBSEEK(xFilial("SY5")+AvKey(cCodigo,"Y5_COD")))
                       If lIntDesp .And. !Empty(cCadastro)
                          cCodDeEI100  := SY5->Y5_COD
                          cDespEI100   := SY5->Y5_NOME
                          cEmailEI100  := SY5->Y5_EMAIL
                       EndIf
                    Else
                       Help("", 1, "AVG0000305")
                       Loop
                    //ElseIf !SY5->(DBSEEK(xFilial("SY5")+cCodigo ))  //JVR - 19/03/09 - Verificação de despachante
                    //   Help("", 1, "AVG0005373")//Despachante não cadastrado.
                    //   Loop
                    EndIf

                    //If Empty(cCodigo)
                    //   Help("", 1, "AVG0000306")
                    //   Loop
                    //ElseIf !SY5->(DBSEEK(xFilial("SY5")+cCodigo ))  //JVR - 19/03/09 - Verificação de despachante
                    //   Help("", 1, "AVG0005373")//Despachante não cadastrado.
                    //   Loop
                    //EndIf

                    // Verifica se o Despachante Digitado e o mesmo do informado no processo
                    If !Empty(cHawb) .And. cCodigo # SW6->W6_DESP
                       If !MsgYesNo(STR0201+CHR(10)+CHR(10)+STR0203+SW6->W6_DESP,STR0202)        //Despachante Informado Difere do Despachante do Processo. Deseja Prosseguir com este Despachante ? ### Atenção
                          Loop
                       Endif
                    Endif
                    EXIT
                 ENDDO

                 IF lSair
                    LOOP
                 ENDIF
                 DO WHILE .T.
                    IF cTipo == 2 //cTipo == PROC_JA_ENVIADO
                       IF ! Pergunte("EIOR04",.T.)
                            lSair:=.T.
                            EXIT
                       ENDIF
                       TDt_I:=mv_par01
                       TDt_F:=mv_par02
                    ENDIF
                    EXIT
                 ENDDO
                 IF lSair
                    lSair:=.F.
                    LOOP
                 ENDIF

              ELSE

                 DO WHILE .T.
                    IF ! Pergunte("EIOR05",.T.)
                       lSair:=.T.
                       EXIT
                    ENDIF
                    cEmpr:=mv_par01
                    cTipo:=mv_par03
                    IF !ORI100VAL()
                       LOOP
                    ENDIF
                    EXIT
                 ENDDO

                 IF lSair
                    lSair:=.F.
                    LOOP
                 ENDIF

                 IF cTipo == 1 //cTipo == PROC_NAO_ENVIADO
                    DO WHILE .T.
                       IF ! Pergunte("EIOR07",.T.)
                          lSair:=.T.
                          EXIT
                       ENDIF
                       cCodigo := mv_par01
                       EXIT
                    ENDDO

                    IF lSair
                       lSair:=.F.
                       LOOP
                    ENDIF
                 ELSE //cTipo == PROC_JA_ENVIADO
                    DO WHILE .T.
                       IF ! Pergunte("EIOR06",.T.)
                          lSair:=.T.
                          EXIT
                       ENDIF
                       IF EMPTY(mv_par01) .AND. EMPTY(mv_par02)
                          TDt_I:=AVCTOD("01/01/"+_FirstYear)
                          TDt_F:=AVCTOD("31/12/49")
                       ELSE
                          TDt_I:=mv_par01
                          TDt_F:=mv_par02
                       ENDIF
                       cCodigo := mv_par03
                       EXIT
                    ENDDO
                    IF lSair
                       lSair:=.F.
                       LOOP
                    ENDIF
              ENDIF

              ENDIF

              // BAK - Alteração realizada para melhoria da impressao de relatorio caso nao fosse selecionado o registro
              //  bPrint:={|| Processa({|lEnd| ORI100Rel(TOpcao,cFase,@cEnvio)}) }
              bPrint:={|| Processa({|lEnd| ORI100Rel(TOpcao,cFase,@cEnvio) , TRB->(DBGoTop()) }) }

              IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ALTERA_BPRINT_2"),)//"IMPRIME_REL"

              IF(lTop)
                 cQuery:=" SELECT * FROM "+RetSqlName("SW6")+" SW6 WHERE "+;
                         " SW6.W6_FILIAL='"+cFilSW6+"'"
              ENDIF

              IF lVazio
                 IF cTipo==1//PROC_NAO_ENVIADO
                    SW6->(DBSETORDER(8))
                    SW6->(DBSEEK(xFilial("SW6")))
                    IF !EMPTY(cCodigo)
                       bWhile:={||EMPTY(SW6->W6_ENV_ORI)}
                       bFor :={||SW6->W6_DESP ==cCodigo}
                       cQuery+=" AND SW6.W6_ENV_ORI=' ' AND SW6.W6_DESP='"+cCodigo+"'"
                    ENDIF
                 ELSE
                    SW6->(DBSETORDER(8))    // RJB 30/12/2005
                    E_PERIODO_OK(@TDt_I,@TDt_F)
                    SW6->(DBSEEK(xFilial()+DTOS(TDt_I),.T.))
                    bWhile:={||SW6->W6_ENV_ORI<=TDt_F}
                    bFor :={||SW6->W6_DESP ==cCodigo}
                    cQuery+=" AND  SW6.W6_ENV_ORI BETWEEN '"+DTOS(TDt_I)+"' AND '"+DTOS(TDt_F)+"'"
                    cQuery+=" AND  SW6.W6_DESP='"+cCodigo+"'"
                 ENDIF
              ELSE
                 SW6->(DBSETORDER(1))
                 SW6->(DBSEEK(xFilial()+cVarWhile))
                 bWhile:={||SW6->W6_HAWB==cVarWhile}
                 bFor :={||SW6->W6_DESP ==cCodigo}
                 cQuery+=" AND  SW6.W6_HAWB='"+cVarWhile+"'"
                 cQuery+=" AND  SW6.W6_DESP='"+cCodigo+"'"
              ENDIF
              cQuery+=" AND SW6.D_E_L_E_T_<>'*'"
              Processa({|| ORI100SW6WORK()})

       ENDCASE

      EXIT
   ENDDO

   IF lSair
      LOOP
   ENDIF

   DBSELECTAREA("TRB")
   TRB->(DBGOTOP())
   ASIZE(aTab_Marca,0)
   lEnvio:=.F.
   nOpca:=2

   DO WHILE ! lEnvio
      IF TOpcao == ENVIA_ORIENTADOR .AND. cFase == FASE_PO
         cTitulo:=Alltrim(cTitulo)+"   Total P.L.I. "+STRZERO(TRB->(EasyRecCount("TRB")),6)
      ELSEIF TOpcao = ENVIA_GIPLITE .AND. cFase = FASE_PO
         cTitulo:=Alltrim(cTitulo)+"   Total P.O. "+STRZERO(TRB->(EasyRecCount("TRB")),6)
      ELSE
         cTitulo:=Alltrim(cTitulo)+"   Total Processos "+STRZERO(TRB->(EasyRecCount("TRB")),6)
      ENDIF

      //BAK - alteração para a nova integração com despachante
      oMainWnd:ReadClientCoords()
      If Empty(cCadastro) .And. !lIntDesp
         DEFINE MSDIALOG oDlg TITLE cTitulo  ;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
             OF oMainWnd PIXEL
         @00,00 MsPanel oPanel Prompt "" SIZE  07,16
         @02,(oDlg:nClientWidth-4)/2-170 BUTTON "Pesquisa"     SIZE 34,11   OF oPanel PIXEL ; //"Pesquisa"
                 ACTION (EVAL(bPesquisa))

         @02,(oDlg:nClientWidth-4)/2-130 BUTTON STR0022     SIZE 34,11   OF oPanel PIXEL ; //"Todos"
                 ACTION (EVAL(bMarca,.T.))

         @02,(oDlg:nClientWidth-4)/2-90 BUTTON STR0023     SIZE 34,11   OF oPanel PIXEL; //"Envio"
                 ACTION (nOpca:=1,lEnvio:=.T.,oDlg:End())

         @02,(oDlg:nClientWidth-4)/2-50 BUTTON STR0024 SIZE 34,11   OF oPanel PIXEL; //"Relatorio"
                 ACTION (EVAL(bPrint))

         oMark:=MsSelect():New("TRB","WP_FLAGWIN",,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
         oMark:bAval:={||EVAL(bMarca,.F.)}
         oMark:oBrowse:Refresh()

		 oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		 oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


         ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},{||nOpca:=2,lEnvio:=.F.,oDlg:End()})) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      Else

         aButtons := {}
         aAdd(aButtons, {"SelectAll", {||ORI100Marca(.T.),oMark:oBrowse:Refresh()}            , "Todos", "Todos"})
         aAdd(aButtons, {"RELATORIO", {|| ORI100Rel(TOpcao,cFase,@cEnvio) , TRB->(DBGoTop()) }, "Relatorio", "Relatorio"})
         bOk      := {||nOpca := 1, lEnvio:= .T. ,oDlg:End()}
         bCancel  := {||nOpca := 2, lEnvio:= .F. ,oDlg:End()}
         DEFINE MSDIALOG oDlg TITLE cTitulo  ;
             FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd Pixel

         oMark:=MsSelect():New("TRB","WP_FLAGWIN",,TB_Campos,@lInverte,@cMarca,PosDlg(oDlg))
         oMark:bAval:={||EVAL(bMarca,.F.)}
         oMark:oBrowse:Refresh()

         ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

      EndIf

      IF nOpca == 2
         EXIT
      ENDIF

       IF nOpca == 3
         EVAL(bPrint)
         LOOP
      ENDIF

      IF lEnvio
         // BAK - Alteração feita para a nova integração com despachante
         // ORI100Env(TOpcao,cFase,@lEnvio)
         cArqDest := ORI100Env(TOpcao,cFase,@lEnvio,cCadastro)
      ENDIF
   ENDDO

   ORI100Final()
   EXIT
ENDDO

ORI100Final()
SX3->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SA5->(DBSETORDER(1))

// BAK - Alteração feita para a nova integração com despachante
//RETURN NIL
RETURN cArqDest

*----------------------------------*
STATIC Function ORI100Marca(lTodos)
*----------------------------------*
LOCAL cChar:=cMarca, nRecno:=TRB->(RECNO()),nReg

Private lMarcaTudo := lTodos// Acb - 14/09/2010 - Ponto de entrada 083358
Private lExibeMsg := .F.

IF TRB->WP_FLAGWIN == cMarca
   cChar:=SPACE(02)
ENDIF

IF lTodos
   TRB->(DBGOTOP())
   TRB->(DBEVAL({|| IF(Ori100Valid(.T.),TRB->WP_FLAGWIN:=cChar,TRB->WP_FLAGWIN:=Space(2)) })) //NCF - 26/09/2011 - Valida a marcação das LI`s para envio
   If lExibeMsg
      MsgAlert(STR0219+CHR(13)+CHR(10)+STR0220+CHR(13)+CHR(10)+STR0221,"AVISO")
   EndIf
ELSE
   If Ori100Valid(.F.)                                                                        //NCF - 26/09/2011 - Valida a marcação da LI para envio
      TRB->WP_FLAGWIN:=cChar
   Else
      TRB->WP_FLAGWIN:=Space(2)
   EndIf
ENDIF
TRB->(DBGOTO(nRecno))

If(EasyEntryPoint("EICOR100"),Execblock("EICOR100",.F.,.F.,"MARCADESMA"),)

RETURN .T.

*-------------------------------*
FUNCTION ORI100Val(PFase,cParam)
*-------------------------------*
LOCAL nOrd
IF PFase ==NIL
   PFase:=IF(cFase==1,"PO","DI")
ENDIF

DO CASE
   CASE SUBSTR(PFase,1,2) = "LI"
        lVazio := .T.
        IF ! EMPTY(TLi) .AND. ! EMPTY(TSeq)
           lVazio := .F.
           SWP->(DBSETORDER(1))
           IF ! SWP->(DBSEEK(xFilial()+TLi+TSeq)) .OR. (lTemDSI .AND. (SWP->WP_LSI=="1" .AND. nEscolha == 2 .OR. SWP->WP_LSI=="2" .AND. nEscolha == 1))
              Help("", 1, "AVG0000306")//E_Msg(STR0028,1000,.T.) //"NUMERO DA LI NO EASY NAO CADASTRADO - TECLE <ENTER>"
              RETURN .F.
           ELSE
              IF ! EMPTY(SWP->WP_RET_ORI) .AND. SWP->WP_ERRO = "1"
                 Help("", 1, "AVG0000307")//E_Msg(STR0029,1000,.T.) //"NUMERO DA LI NO EASY JA ENVIADO E APROVADO - TECLE <ENTER>"
              ELSEIF  ! EMPTY(SWP->WP_RET_ORI) .AND. SWP->WP_ERRO = "2"
                 Help("", 1, "AVG0000308")//E_Msg(STR0030,1000,.T.) //"NUMERO DA LI NO EASY JA ENVIADO E NAO APROVADO - TECLE <ENTER>"
              ENDIF
           ENDIF
        ELSEIF ! EMPTY(TLi) .AND. EMPTY(TSeq)
           lVazio := .F.
           SWP->(DBSETORDER(1))
           IF ! SWP->(DBSEEK(xFilial()+TLi)) .OR. (lTemDSI .AND. (SWP->WP_LSI=="1" .AND. nEscolha == 2 .OR. SWP->WP_LSI=="2" .AND. nEscolha == 1))
              Help("", 1, "AVG0000309")//E_Msg(STR0031,1000,.T.) //"NUMERO DA LI NO EASY NAO CADASTRADO."
              RETURN .F.
           ENDIF
        ELSEIF EMPTY(TLi)
           Tseq:=Space(3)
        ENDIF
        cVarWhile := TLi+TSeq
   CASE PFase = "PO"
        TPO_NUM:=mv_par01
        lVazio := .T.
        IF ! EMPTY(TPO_NUM)
           lVazio := .F.
           IF ! SW2->(DBSEEK(xFilial()+TPO_NUM))
              Help("", 1, "AVG0000310")//E_Msg(STR0032,1000,.T.) //"NUMERO DO PEDIDO NAO CADASTRADO.@"
              RETURN .F.
           ENDIF
        ENDIF
        cVarWhile := SW2->W2_PO_NUM
   CASE PFase = "DI"
        nOrd := SW6->(INDEXORD())
        IF TOpcao == ENVIA_DESPACHANTE
           THouse:=mv_par02
        ELSE
        THouse:=mv_par01
        ENDIF
        lVazio := .T.
        IF ! EMPTY(THouse)
           SW6->(DBSETORDER(1))
           lVazio := .F.
           IF !SW6->(DBSEEK(xFilial("SW6")+THouse))
              Help("", 1, "AVG0000311")//E_Msg(STR0033,1000,.T.) //'NUMERO DO PROCESSO NAO CADASTRADO.'
              RETURN .F.
           ENDIF
          SW6->(DBSETORDER(nOrd))
        ENDIF
        cVarWhile := SW6->W6_HAWB
   CASE PFase== "Maquina"
      IF !SX5->(DBSEEK(xFilial()+'Y5'+cParam))
         Help(" ",1,"EICMAQ")
         RETURN .F.
      ENDIF
      IF !SX5->(DBSEEK(xFilial("SX5")+"CE"+cParam)) .OR. EMPTY(SX5->X5_DESCRI)
         MsgAlert(STR0204) //"Caminho da Maquina nao cadastrado na Tabela CE no SX5"
         RETURN .F.
      ENDIF


ENDCASE
RETURN .T.

*------------------------------------------------------*
STATIC FUNCTION ORI100Env(TOpcao,cFase,cEnvio,cCadastro)
*------------------------------------------------------*
LOCAL lVerItensMarc:=(TOpcao == ENVIA_ORIENTADOR .AND. cFase == FASE_PO)   // RS 05/11/05
/*---ACSJ - 25/06/04 ----------------------------------------------------------------------------------------------|
|  Para o envio de LI para o Siscomex é usada apenas duas variaveis.                                               |
|  1 -  cPathDBF --> SX5 --> "CEA1DBF"                                                                             |
|       O campo X5_DESCRI deve ser preenchido com o caminho onde os arquivos de retorno devem ser gravados no      |
|       SERVIDOR. Este caminho deve ser indicado do ponto apartir do \AP7\                                         |
|       EX.                                                                                                        |
|          \SIGAADV\A1\                                                                                            |
|                                                                                                                  |
|  2 -  cPathMDB --> SX5 --> "CEA1MDB"                                                                             |
|       O campo X5_DESCRI deve ser preenchdo com o caminho onde os arquivos para o Siscomex devem ser gerados na   |
|       maquiba LOCAL. Este parametro foi testado mapeando o diretorio "D:\SISCOTRE\"                              |
|       EX.                                                                                                        |
|          Z:\IMPORT.TRE\                                                                                          |
|---------------------------------------------------------------------------------------------------------------- */

Static cPathDBF
Static cPathMDB
//Static cMaqDesp := ""

LOCAL aItemLi:={},aNcmLi:={}, cSimNao, cMsgTela
LOCAL cMaquina,cDespachante,lMarca:=.F., cPath
LOCAL lErroCpy	:= .f. // ACSJ - 09/06/2004 - Variavel utilizada para controlar se houve erro na copia de arquivos do
                      // Servidor para Local. <-> Local para Servidor
LOCAL lRet := .t.     // ACSJ - 09/06/2004
LOCAL aStruP:={}
Local cDirGerados := "" //BAK - 23/03/2011
/*LOCAL cBusca

If Empty(cMaqDesp)
   cBusca := cCodigo
Else
   cBusca := cMaqDesp
Endif

SX5->(DBSEEK(xFilial("SX5")+"CE"+cCodigo+"DBF"))
cPathDBF := Alltrim(SX5->X5_DESCRI)

SX5->(DBSEEK(xFilial("SX5")+"CE"+cCodigo+"MDB"))
cPathMDB := Alltrim(SX5->X5_DESCRI)*/

//Tratamento correto para os drivers - JWJ 21/11/2006
PRIVATE cDRVOpen := RealRDD() //FDR-18/11/2014
/*PRIVATE cDRVOpen := "DBFCDXADS"
If RealRDD() == "ADSSERVER"
   cDRVOpen := "DBFCDX"
Else
   If IsSrvUnix()
      cDRVOpen := ""
  // ElseIf RealRDD() == "CTREE" - AST 08/08/08 - Caso o servidor não seja UNIX, força a geração de tabelas DBF ao
  //    cDRVOpen := "CTREE"                       invés de DTC
   Else
      cDRVOpen := "DBFCDXADS"
   EndIf
EndIf*/

// Variaveis usadas para enviar e-mail
PRIVATE cEnvMail:= ""
PRIVATE aUsuario,cServer,cAccount,cPassword,cFrom,cTo,cSubject,cBody,lResult
PRIVATE nTimeOut,lAutentica,cUserAut,cPassAut
PRIVATE lTemMail := IF(!EMPTY(AllTrim(EasyGParam("MV_RELSERV"))) .AND.;
                       !EMPTY(AllTrim(EasyGParam("MV_RELACNT"))) ,.T.,.F.)


PRIVATE tBate1vez:=.T.,nPesTotPLI:=0,MDesFrePLI:=0, PGI_Chave:='',lDesvia := .F.
PRIVATE aCapaLi:={},OldAlias :=ALIAS(),Primeiro:=.T.,nOldRecno:=TRB->(RECNO())
PRIVATE lEnviado := cEnvio
PRIVATE lNVEProduto := AvFlags("NVE_POR_PRODUTO")
cBody:=""
cSubject:= ""
TRB->(DBGOTOP())
TRB->(DBEVAL({||IF(TRB->WP_FLAGWIN==cMarca,lMarca:=.T.,)}))
TRB->(DBGOTO(nOldRecno))

IF ! lMarca
   IF ! lVerItensMarc    // RS 05/11/05
      Help("", 1, "AVG0000312")//E_Msg(STR0034,1000,.T.) //"NAO EXISTEM REGISTRO MARCADOS PARA ENVIO - TECLE <ENTER>"
      cEnvio:=.F.
      RETURN .T.
   ENDIF
ENDIF

IF nEscolha == 1 // LSI
   IF EMPTY(cCodigo)
      IF SWP->(DBSEEK(xFilial()+TRB->WP_PGI_NUM+TRB->WP_SEQ_LI))
         cCodigo:=SWP->WP_NR_MAQ
         cData  :=IF(EMPTY(SWP->WP_ENV_ORI),dDataBase,SWP->WP_ENV_ORI)
      ENDIF
   ENDIF
   DO WHILE EMPTY(cCodigo)
      IF !Pergunte("EICMAQ",.T.)
         RETURN .T.
      ENDIF

      cCodigo:=ALLTRIM(MV_PAR01)
      cData  :=MV_PAR02

      IF EMPTY(cCodigo)
         Help("",1,"AVG0000314")//CODIGO DA MAQUINA DEVE SER PREENCHIDO
         LOOP
      ENDIF

      EXIT

   ENDDO
   Processa({|| Or100GrvLSI() } , "Processando LSI's...")
   lDesvia := .T.
ENDIF

IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ADICAO"),)

IF lDesvia
   RETURN .T.
ENDIF

IF TOpcao = ENVIA_ORIENTADOR .AND. cFase = FASE_PO
   AADD(aCapaLi,{"NR_MAQ"      ,"C",02,0}) ; AADD(aCapaLi,{"DT_INTEG"    ,"D",08,0})
   AADD(aCapaLi,{"PROC_EASY"   ,"C",10,0}) ; AADD(aCapaLi,{"SEQ_LI"      ,"C",03,0})
   AADD(aCapaLi,{"STATUS_ATU"  ,"C",01,0}) ; AADD(aCapaLi,{"TRAT_MICRO"  ,"C",08,0})
   AADD(aCapaLi,{"OPTRAT_PRO"  ,"C",10,0}) ; AADD(aCapaLi,{"AUTO_TRANS"  ,"C",01,0})
   AADD(aCapaLi,{"OP_TRAT_PR"  ,"C",10,0}) ; AADD(aCapaLi,{"LI_SUBSTIT"  ,"C",10,0})
   AADD(aCapaLi,{"TIPO_IMPOR"  ,"C",01,0}) ; AADD(aCapaLi,{"NR_IMPORT"   ,"C",14,0})
   AADD(aCapaLi,{"PAIS_IMPOR"  ,"C",03,0}) ; AADD(aCapaLi,{"IMPORTADOR"  ,"C",60,0})
   AADD(aCapaLi,{"TEL_IMPORT"  ,"C",15,0}) ; AADD(aCapaLi,{"LOGR_IMPOR"  ,"C",40,0})
   AADD(aCapaLi,{"ED_NR_IMPO"  ,"C",06,0}) ; AADD(aCapaLi,{"COMPL_IMPO"  ,"C",21,0})
   AADD(aCapaLi,{"BA_IMPORT"   ,"C",25,0}) ; AADD(aCapaLi,{"MUN_IMPORT"  ,"C",25,0})
   AADD(aCapaLi,{"UF_IMPORT"   ,"C",AVSX3("A2_EST",3),0}) ; AADD(aCapaLi,{"CEP_IMPORT"  ,"C",08,0}) //SO.:0032 OS.:0300/02 FCD
   AADD(aCapaLi,{"ATIV_ECO_I"  ,"C",04,0}) ; AADD(aCapaLi,{"CPF_REPLEG"  ,"C",11,0})
   AADD(aCapaLi,{"URF_ENT_ME"  ,"C",07,0}) ; AADD(aCapaLi,{"FORN_ESTR"   ,"C",60,0})
   AADD(aCapaLi,{"LOG_FORN_E"  ,"C",40,0}) ; AADD(aCapaLi,{"NRFORN_EST"  ,"C",06,0})
   AADD(aCapaLi,{"COMP_FORN"   ,"C",21,0}) ; AADD(aCapaLi,{"CID_FORN"    ,"C",25,0})
   AADD(aCapaLi,{"EST_FORN"    ,"C",25,0}) ; AADD(aCapaLi,{"PAIS_AQ_ME"  ,"C",03,0})
   AADD(aCapaLi,{"MERC_NCM"    ,"C",08,0}) ; AADD(aCapaLi,{"PAIS_PROCM"  ,"C",03,0})
   AADD(aCapaLi,{"AUSENCIAFA"  ,"C",01,0}) ; AADD(aCapaLi,{"NM_FABR_ME"  ,"C",60,0})
   AADD(aCapaLi,{"LOGR_FABR"   ,"C",40,0}) ; AADD(aCapaLi,{"NR_FABR"     ,"C",06,0})
   AADD(aCapaLi,{"COMP_FABR"   ,"C",21,0}) ; AADD(aCapaLi,{"CID_FABR"    ,"C",25,0})
   AADD(aCapaLi,{"ESTADO_FAB"  ,"C",25,0}) ; AADD(aCapaLi,{"PAIS_OR_ME"  ,"C",03,0})
   AADD(aCapaLi,{"NALADI_NCC"  ,"C",07,0}) ; AADD(aCapaLi,{"NALADI_SH"   ,"C",08,0})
   AADD(aCapaLi,{"PL_MERC"     ,"C",15,0}) ; AADD(aCapaLi,{"QT_UN_EST"   ,"C",14,0})
   AADD(aCapaLi,{"MOEDA_NEG"   ,"C",03,0}) ; AADD(aCapaLi,{"DIA_LIM_PG"  ,"C", TY6DIASPA, 0})
   AADD(aCapaLi,{"INCOTERM_V"  ,"C",03,0}) ; AADD(aCapaLi,{"VLMERCMOE"   ,"C",15,0})
   AADD(aCapaLi,{"VLTOTUSD"    ,"C",11,0}) ; AADD(aCapaLi,{"TIPO_AC_TA"  ,"C",01,0})
   AADD(aCapaLi,{"TIP_AC_ALA"  ,"C",03,0}) ; AADD(aCapaLi,{"REG_TRIBUT"  ,"C",01,0})
   AADD(aCapaLi,{"FUND_LEG_R"  ,"C",02,0}) ; AADD(aCapaLi,{"COBERT_CAM"  ,"C",01,0})
   AADD(aCapaLi,{"MODAL_PGTO"  ,"C",02,0}) ; AADD(aCapaLi,{"ORG_FIN_IN"  ,"C",02,0})
   AADD(aCapaLi,{"MOT_SEM_CO"  ,"C",02,0}) ; AADD(aCapaLi,{"AGE_SECEX"   ,"C",05,0})
   AADD(aCapaLi,{"URF_DESPAC"  ,"C",07,0}) ; AADD(aCapaLi,{"MAT_USADO"   ,"C",01,0})
   AADD(aCapaLi,{"BEM_ENCOME"  ,"C",01,0}) ; AADD(aCapaLi,{"ATO_DRAWBA"  ,"C",13,0})
   AADD(aCapaLi,{"COMUNI_COM"  ,"C",13,0}) ; AADD(aCapaLi,{"REG_DRAWB"   ,"C",11,0})
   AADD(aCapaLi,{"TEM_DRAWB"   ,"C",01,0}) ; AADD(aCapaLi,{"INF_COMPL"   ,"M",10,0})

   AADD(aItemLi,{"NR_MAQ"      ,"C",02,0}) ; AADD(aItemLi,{"DT_INTEGR"   ,"D",08,0})
   AADD(aItemLi,{"PROC_EASY"   ,"C",10,0}) ; AADD(aItemLi,{"SEQ_LI"      ,"C",03,0})
   AADD(aItemLi,{"STATUS_ATU"  ,"C",01,0}) ; AADD(aItemLi,{"TRAT_MICRO"  ,"C",08,0})
   AADD(aItemLi,{"SEQ_PRODUT"  ,"C",02,0}) ; AADD(aItemLi,{"QTD_MERC"    ,"C",14,0})
   AADD(aItemLi,{"UN_MED_COM"  ,"C",20,0}) ; AADD(aItemLi,{"VL_UNITMER"  ,"C",20,0})
   AADD(aItemLi,{"VL_DRAWB"    ,"C",15,0}) ; AADD(aItemLi,{"QTD_DRAWB"   ,"C",14,0})
   AADD(aItemLi,{"SG_ORG_ANU"  ,"C",10,0}) ; AADD(aItemLi,{"NR_PRO_ANU"  ,"C",20,0})
   AADD(aItemLi,{"SEQ_DRAWB"   ,"C",AVSX3("ED4_SEQSIS",3),0}); AADD(aItemLi,{"DES_DETMER"  ,"M",10,0})

   AADD(aNcmLi,{"NR_MAQ"      ,"C",02,2})  ; AADD(aNcmLi,{"DT_INTEGR"   ,"D",08,0})
   AADD(aNcmLi,{"PROC_EASY"   ,"C",10,0})  ; AADD(aNcmLi,{"SEQ_LI"      ,"C",03,0})
   AADD(aNcmLi,{"STATUS_ATU"  ,"C",01,0})  ; AADD(aNcmLi,{"TRAT_MICRO"  ,"C",08,0})
   AADD(aNcmLi,{"DESTAQUE"    ,"C",03,0})

   FileWk1 := E_CriaTrab(,aCapaLi,"CapaLi") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF ! USED()
      Help("", 1, "AVG0000313")//E_Msg(STR0035,20) //"NAO HA AREA DISPONIVEL PARA ABERTURA DO CADASTRO DE WORK"
      RETURN .F.
   ENDIF

   FileWk2 := E_CriaTrab(,aItemLI,"ItemLi") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF ! USED()
      Help("", 1, "AVG0000313")//E_Msg(STR0035,20) //"NAO HA AREA DISPONIVEL PARA ABERTURA DO CADASTRO DE WORK"
      RETURN .F.
   ENDIF

   FileWk3 := E_CriaTrab(,aNcmLI,"NcmLI") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF ! USED()
      Help("", 1, "AVG0000313")//E_Msg(STR0035,20) //"NAO HA AREA DISPONIVEL PARA ABERTURA DO CADASTRO DE WORK"
      RETURN .F.
   ENDIF

   // TABELA  : PROCESSO_ANUENTE   -  RS 15/10/05 - DEICMAR
   aStruP := {}

   AADD(aStruP, {"NR_MAQ"      ,"C",02,0})
   AADD(aStruP, {"PROC_EASY"   ,"C",10,0})
   AADD(aStruP, {"SEQ_LI"      ,"C",03,0})
   AADD(aStruP, {"TRAT_MICRO"  ,"C",08,0})
   AADD(aStruP, {"DT_INTEG"   ,"D",08,0})
   AADD(aStruP, {"NR_PROC_AN", "C",020,0})
   AADD(aStruP, {"SG_ORG_PRO", "C",010,0})

   IF SELECT("Work_PAnu") # 0
      DbSelectArea("Work_PAnu")
      AvZap()
   ELSE

      cArqTrabP := E_CriaTrab(,aStruP,"Work_PAnu") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

      IF ! USED()
         Help("", 1, "AVG0000313")//E_Msg(STR0035,20) //"NAO HA AREA DISPONIVEL PARA ABERTURA DO CADASTRO DE WORK"
         RETURN .F.
      ENDIF
   ENDIF
   DBSELECTAREA("SWP")
   SWP->(DBSETORDER(1))
   SWP->(DBSEEK(xFilial()+TRB->WP_PGI_NUM+TRB->WP_SEQ_LI))
   cCodigo:=SWP->WP_NR_MAQ
   cData:=IF(EMPTY(SWP->WP_ENV_ORI),dDataBase,SWP->WP_ENV_ORI)
ELSE
  IF TOpcao = ENVIA_DESPACHANTE
    If EasyGParam("MV_LAYDESP",,.F.)    //TRP-19/01/09- Verifica o conteúdo do parâmetro MV_LAYDESP que define se o campo
       nTamPad := nTamReg := 350+10                                            // Código do item possui 15 ou 30 caracteres para geração do txt.
    Else
       nTamPad := nTamReg := 350
    Endif
  ELSE
    If EasyGParam("MV_LAYDESP",,.F.)
       nTamPad := nTamReg := 276+15+(nColExtra*2)
    Else
       nTamPad := nTamReg := 276+(nColExtra*2) // SVG - 12/01/2011 - Alterado o tamanho de 255 para 275 devido a inserção dos campos HOUSE e MASTER na CAPID
    Endif
  ENDIF

   // Permite a altera‡Æo de variaveis Ex. (nTamReg)
   IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"TAM_REG"),)//LCB 11.07.2000
   IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"TAM_REG"),)

   IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ANTES_CRIA_GIP_LITE"),) //TRP 22/11/2007
   AADD(aCapaLi,{"GIPTEXTO"      ,"C",nTamReg,0})

   aCampos:= Nil
   FileWk1 := E_CriaTrab(,aCapaLI,"Gip_Lite",,.T.) //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF ! USED()
      Help("", 1, "AVG0000313")//E_Msg(STR0035,1000,.T.) //"NAO HA AREA DISPONIVEL PARA ABERTURA DO CADASTRO DE WORK"
      RETURN
   ENDIF

   FileWk4 := E_CriaTrab(,aCapaLI,"Gip_Lite2") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF ! USED()
      Help("", 1, "AVG0000313")//E_Msg(STR0035,1000,.T.) //"NAO HA AREA DISPONIVEL PARA ABERTURA DO CADASTRO DE WORK"
      Gip_Lite->(E_EraseArq(FileWk1))
      RETURN
   ENDIF

   IF(cFase==FASE_PO,DBSELECTAREA("SW2"),DBSELECTAREA("SW6"))
   IF(cFase==FASE_PO,DBSETORDER(1),DBSETORDER(1))
   IF(cFase==FASE_PO,DBSEEK(xFilial()+TRB->W2_PO_NUM),DBSEEK(xFilial()+TRB->W6_HAWB))
ENDIF
IF EMPTY(cCodigo) .AND. TOpcao == ENVIA_ORIENTADOR
   IF ! Pergunte("EICMAQ",.T.)
      mv_par01:=0
      cCodigo:=SPACE(02)
   ELSE
      cCodigo:=ALLTRIM(mv_par01)
      cData  :=mv_par02
   ENDIF

   IF EMPTY(cCodigo)
      IF TOpcao = ENVIA_ORIENTADOR
         Help("", 1, "AVG0000314")//E_Msg(STR0036,1000,.T.) //"CODIGO DA MAQUINA DEVE SER PREENCHIDO - TECLE <ENTER>"
         ORI100Final(.T.)
      ELSE
         ORI100Final(.F.)
      ENDIF
      RETUR .T.
   ENDIF
ENDIF

SX5->(DBSEEK(xFilial("SX5")+"CE"+cCodigo+"DBF"))
cPathDBF := Alltrim(SX5->X5_DESCRI)

SX5->(DBSEEK(xFilial("SX5")+"CE"+cCodigo+"MDB"))
cPathMDB := Alltrim(SX5->X5_DESCRI)

cMsgTela:=IF(TOpcao==ENVIA_ORIENTADOR,STR0037,STR0038)   //"Orientador"###"Gip-Lite"

// BAK - alteração para a nova integração - 24/03/2011
If Empty(cCadastro) .And. !lIntDesp
   cSimNao:=SimNao(STR0039,,,,,STR0040+cMsgTela)            //'Confirma o Envio ? '###'Envio ao '
Else
   cSimNao:=SimNao("Confirma a geração?","Aviso")            //'Confirma o Envio ? '###'Envio ao '
EndIf

IF ! (cSimNao $ cSim)
   IF TOpcao = ENVIA_ORIENTADOR
      ORI100Final(.T.)
   ELSE
      ORI100Final(.F.)
   ENDIF
   RETURN .T.
ENDIF

IF TOpcao = ENVIA_ORIENTADOR
   nTotalMarca:=0
   Processa({|lEnd| ;
      ProcRegua(TRB->(Easyreccount("TRB"))),TRB->(DBGOTOP()),;
      TRB->(DBEVAL({||IncProc(STR0041),ORI100Grv(TRB->WP_PGI_NUM+TRB->WP_SEQ_LI,TOpcao,cFase,@Primeiro,{|msg| MsProcTxt(msg)})},{||TRB->WP_FLAGWIN==cMarca}))} ,; //"Processando Itens da LI"
                     AVSX3("WP_ENV_ORI",05)) //STR0006"Envio ao Orientador"
   TRB->(DBGOTO(nOldRecno))

   IF !EMPTY(cPathDBF)
      cEnvio    := .T.
      cNumero   := Seq_Arq_Sis()

      // ACSJ - 14/06/2004 - Alteradas as variaveis abaixo para fazer copia para o path descrito no SX5.
      cArq_Capa := cCodigo+"C"+cNumero
      cArq_Item := cCodigo+"I"+cNumero
      cArq_Dest := cCodigo+"D"+cNumero
      cArq_PAnu := cCodigo+"P"+cNumero   // Tabela de Processo Anuente "EIT"
      cArq_Flg  := cCodigo+"F"+cNumero+".FLG"
      // -------------------------------------------------------------------------------------- ACSJ - 14/06/2004

      //JWJ 16/11/2006: Criei variaveis para guardar o nome das works com a extensão correta
      IF Select("CapaLi") # 0
         FileWk1_EX := SUBSTR(CapaLI->(DBINFO(10)), AT(UPPER(FileWk1), Upper( CapaLi->(DBINFO(10)) )  ))
         CapaLi->(dbcloseAREA())
      ENDIF
      IF Select("ItemLi") # 0
         FileWk2_EX := SUBSTR(ItemLi->(DBINFO(10)), AT(UPPER(FileWk2), Upper( ItemLi->(DBINFO(10)) )  ))
         ItemLi->(dbcloseAREA())
      ENDIF
      IF Select("NcmLI") # 0
         FileWk3_EX := SUBSTR(NcmLI->(DBINFO(10)), AT(UPPER(FileWk3), Upper( NcmLI->(DBINFO(10)) )  ))
         NcmLI->(dbcloseAREA())
      ENDIF

      IF Select("Work_PAnu") # 0
         cArqTrabP_EX := SUBSTR(Work_PAnu->(DBINFO(10)), AT(UPPER(cArqTrabP), Upper( Work_PAnu->(DBINFO(10)) )  ))
         Work_PAnu->(dbcloseAREA())
      ENDIF

      //IF .NOT. ISSRVUNIX() .and. cDRVOpen == "DBFCDXADS" // AST - 08/08/08 - Verifica se as tabelas criadas são DBF // NOPADO POR MCF - 01/04/2015
      IF .NOT. ISSRVUNIX() .and. RealRDD() <> "CTREE" //JWJ
	      if FRENAME(FileWk1+".DBF",cArq_Capa+".DBF") < 0
	         lErroCpy := .t.
	      Endif

	      FRENAME(FileWk1+".FPT",cArq_Capa+".FPT")

	      // ACSJ - 09/06/2004 - Copia dos arquivos do servidor para o terminal usando a função CPYS2T.

	      //                                P1               P2     P3
	      if .not. iif(lErroCpy,.f.,CPYS2T(cArq_Capa+".DBF",cPathMDB,.f.))
	                                                                //  P1 -> Arquivo a ser copiado (a1cSequencia.dbf)
	                                                                //  P2 -> Caminho para onde deve ser copiado, apenas o
	                                                                //        diretório (d:\siscotre\import.tre\)
	                                                                //  P3 -> Compacta o arquivo (.T./.F.) ?
	         lErroCpy := .t.
	      Endif
	      if .not. lErroCpy
	         CPYS2T(cArq_Capa+".FPT",cPathMDB,.f.)

	         FErase(cArq_Capa+".DBF")
	         FErase(cArq_Capa+".FPT")

	         FRename(FileWk2+".DBF",cArq_Item+".DBF")
	         FRename(FileWk2+".FPT",cArq_Item+".FPT")

	         if .not. iif(lErroCpy,.f.,CPYS2T(cArq_Item+".DBF",cPathMDB,.f.))
	             lErroCpy := .t.
	         Endif
	         if .not. lErroCpy
	            CPYS2T(cArq_Item+".FPT",cPathMDB,.f.)

	            FErase(CArq_Item+".DBF")
	            FErase(CArq_Item+".FPT")

	            FRename(FileWk3+".DBF",cArq_Dest+".DBF")

	            CPYS2T(cArq_Dest+".DBF",cPathMDB,.f.)

	            FErase(cArq_Dest+".DBF")
	            FErase(cArq_Dest+".FPT")
	            // Processo Anuente - RS 19/10/05
	            FRename(cArqTrabP+".DBF",cArq_PAnu+".DBF")
	            CPYS2T(cArq_PAnu+".DBF",cPathMDB,.f.)
	            FErase(cArq_PAnu+".DBF")
	         Endif
	      Endif
	  ELSE
	     //JWJ 13/11/2006: Se for Linux, manda como XML para o cliente e usa o AvgXML2DBF
	     //Cria os XML's
	     AVGDBF2XML( FileWk1_EX, UPPER(cArq_Capa+".XML"), "CapaLi")
	     AVGDBF2XML( FileWk2_EX, UPPER(cArq_Item+".XML"), "ItemLi")
   	     AVGDBF2XML( FileWk3_EX, UPPER(cArq_Dest+".XML"), "NcmLI")
   	     AVGDBF2XML( cArqTrabP_EX, UPPER(cArq_PAnu+".XML"), "Work_PAnu")

  	     //Copia para o cliente
  	     lErroCpy := lErroCpy .OR. ! CPYS2T(cArq_Capa+".XML", cPathMDB, .F.)
  	     lErroCpy := lErroCpy .OR. ! CPYS2T(cArq_Item+".XML", cPathMDB, .F.)
  	     lErroCpy := lErroCpy .OR. ! CPYS2T(cArq_Dest+".XML", cPathMDB, .F.)
  	     lErroCpy := lErroCpy .OR. ! CPYS2T(cArq_PAnu+".XML", cPathMDB, .F.)

  	     //Apaga do server
  	     FErase(cArq_Capa+".XML")
  	     FErase(cArq_Item+".XML")
  	     FErase(cArq_Dest+".XML")
  	     FErase(cArq_PAnu+".XML")

  	     WaitRun("AvgXML2DBF.exe "+cPathMDB)
	  ENDIF
      // ------------------------------------------------------------------------ ACSJ - 09/06/2004

      if lErroCpy  // ACSJ - 09/06/2004 - Verifica se houve problemas nas copias dos arquivos para o terminal.
         MsgStop(STR0209 + Chr(13) + Chr(10) +;   // ### "Erro na copia dos arquivos para o local"
                  STR0210)                        // ### "Verifique o caminho indicado como parametro"

         lRet := .f.
      Else
         fHandle:=EasyCreateFile(cArq_Flg)
         FCLOSE(fHandle)
         CPYS2T(cArq_Flg,cPathMDB,.f.)
         FErase(cArq_Flg)
         EICMX100("S",cCodigo)
      Endif

    ELSE
       MsgAlert(STR0204+"(DBF)") //"Caminho da Maquina nao cadastrado na Tabela CE no SX5"
    ENDIF
   ORI100Final(.T.)
ELSE  //------------------------ DESPACHANTE //

   lProcessa:=.T.
   nTotalMarca:=0
   Processa({|lEnd| ;
              ProcRegua(TRB->(Easyreccount("TRB"))),TRB->(DBGOTOP()),;
              TRB->(DBEVAL({||IncProc(STR0043),ORI100Grv(,TOpcao,cFase,@Primeiro,{|msg| MsProcTxt(msg)})},{||TRB->WP_FLAGWIN==cMarca}))} ,STR0044) //"Envio ao Gip-Lite"
   TRB->(DBGOTO(nOldRecno))
   cEnvio    := .T.
   aFaseNVE := If(Type("aFaseNVE")=="U",{.F.,.F.,.F.},aFaseNVE)
   IF cFase = FASE_DI// .AND. lNVE                 //NCF - 09/11/2012
      If OR100PqNVE("DI" ,SW6->W6_HAWB ,.F.)
         MontaNVE("SW8",aFaseNVE[1],aFaseNVE[2],aFaseNVE[3])
      ElseIf OR100PqNVE("LI" ,SW6->W6_HAWB ,.F.) .Or. OR100PqNVE("PO" ,SW6->W6_HAWB ,.F.) 
         MontaNVE("SW7",aFaseNVE[1],aFaseNVE[2],aFaseNVE[3])   
      EndIf
   ElseIf cFase = FASE_PO
      If OR100PqNVE("CD" ,SW2->W2_PO_NUM ,.F.) 
         MontaNVE("SW3",aFaseNVE[1],aFaseNVE[2],aFaseNVE[3])
      EndIf       
   Endif  
   Gip_Lite->(DBAPPEND())
   Gip_Lite->GIPTEXTO := "FTDI"+STRZERO(nTotalMarca,4,0)

   // BAK - 23/03/2011 - Alteração feita para nova integração com despachante
   If Empty(cCadastro) .And. !lIntDesp
      cPath:=ORI100PATH()
   Else
      cDirGerados := "\comex\IntDespachante\gerados\"
      If lIsDir(cDirGerados) .Or. (MakeDir(cDirGerados) == 0)
         cPath := cDirGerados
      Else
         cPath := ""
      EndIf
   EndIf

   IF EMPTY(cPath)
      MSGINFO(STR0213) // ### "Arquivo Despachante nao gerado"
      RETURN .F.
   ENDIF

   SY5->(DBSEEK(xFilial("SY5")+cCodigo))  //FERNANDO//SW6->W6_DESP))
   RecLock("SY5",.F.)
   xNumero := SY5->Y5_SEQ_GIP + 1
   IF xNumero > 9999
      xNumero := 1
   ENDIF
   SY5->Y5_SEQ_GIP := xNumero
   SY5->(MsUnlock())

   cArqTxt:=STRZERO(VAL(cCodigo),Len(cCodigo),0)+IF(cFase=2,"d","p")+STRZERO(xNumero,4,0)+".txt" //RRV - 28/09/2012 - Ajustado para correto funcionamento em ambiente Linux
   cArq_Dest := ALLTRIM(cArqTxt)

   If EasyEntryPoint("EICOR100")
      Execblock("EICOR100",.f.,.f.,"ANTES_CRIA_ARQ")
   End If

   TRB->(DBGOTOP())
   IF cEnvio  .AND. cFase == FASE_PO
      TRB->(DBEVAL({||SW2->(DBSEEK(xFilial("SW2")+TRB->W2_PO_NUM)),;
                                SW2->(RecLock("SW2",.F.))         ,;
                                SW2->W2_ARQ    := cArqTxt         ,;
                                SW2->W2_DESP   := cCodigo         ,;
                                SW2->W2_ENV_ORI:= cData           ,;
                                SW2->(MsUnlock()) },{||TRB->WP_FLAGWIN==cMarca}))
   ENDIF

   IF cEnvio .AND. cFase == FASE_DI
      TRB->(DBEVAL({||SW6->(DBSEEK(xFilial("SW6")+TRB->W6_HAWB)),;
                                SW6->(RecLock("SW6",.F.))       ,;
                                SW6->W6_ARQ    := cArqTxt       ,;
                                SW6->W6_DESP   := cCodigo       ,;
                                SW6->W6_ENV_ORI:= cData         ,;
                                SW6->(MsUnlock()) },{||TRB->WP_FLAGWIN==cMarca}))

   ENDIF
   DBSELECTAREA("Gip_Lite")
   If ":" $ cPath
      COPY TO &cArq_Dest SDF   // ACSJ 14/06/2004 - Gera Arquivo local.

      if .not. CPYS2T(cArq_Dest,cPath,.f.) // ACSJ - 25/06/2004 - Copia arquivo para local indicado no SX5
                                               // neste caso é usado a variavel cPath pois o caminho é criado
                                               // apartir da funcao ORI100PATH()
         MsgStop(STR0211)   // ### "Erro na copia do arquivos"
         lRet := .f.
      Endif
   Else
      // BAK - Tratamento para nova integração com despachante, deixar de criar na pasta do system
      If Empty(cCadastro) .And. !lIntDesp
         COPY TO &cArq_Dest SDF
      EndIf
      COPY TO &(cPath+cArq_Dest) SDF    // ACSJ 14/06/2004 - Gera Arquivo local.
   EndIf

   if lRet // ACSJ - 14/06/2004 - Verifica se a copia foi feita corretamente.

      If lTemMail .AND. cEnvio  .And. !lIntDesp .AND.;   //GFP - 07/08/2012 - Apenas envia email quando utilizado antiga integração de despachante.
         MsgYesNo(STR0196, STR0197) //"Envia arquivo ao despachante por e-mail" # "Confirma envio por e-mail ? "
         SY5->(dbSeek(xFilial("SY5")+cCodigo))//IF(cFase==FASE_DI,SW6->W6_DESP,cCodigo)))
         PswOrder(1)
         PswSeek(__CUSERID,.T.)
         aUsuario    := PswRet(1)
         cServer     := AllTrim(EasyGParam("MV_RELSERV",," "))// "smtp.average.com.br"
         cAccount    := AllTrim(EasyGParam("MV_RELACNT",," "))
         cPassword   := AllTrim(GetNEWPAR("MV_RELPSW"," "))
         nTimeOut    := EasyGParam("MV_RELTIME",,120)//Tempo de Espera antes de abortar a Conexão
         lAutentica  := EasyGParam("MV_RELAUTH",,.F.)//Determina se o Servidor de Email necessita de Autenticação
         cUserAut    := Alltrim(EasyGParam("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email
         cPassAut    := Alltrim(EasyGParam("MV_RELAPSW",,cPassword))//Senha para Autenticação no Servidor de Email
         cFrom       := AllTrim(aUsuario[1,14])
         cTo         := AllTrim(SY5->Y5_EMAIL)

         //TRP-30/07/07- Tratamento para fase do processo no cabeçalho do email.
         If cFase == FASE_DI
            cSubject += AllTrim(STR0193+AllTrim(SW6->W6_HAWB)) // "Envio de processo ao despachante. Processo: "
            cBody += STR0194+AllTrim(SW6->W6_HAWB)+STR0195+AllTrim(SY5->Y5_NOME) // "O arquivo anexo contém informações referente envio do processo " # " ao despachante "
         Elseif cFase == FASE_PO
            cSubject += AllTrim(STR0193+AllTrim(SW2->W2_PO_NUM))// "Envio de processo ao despachante. Processo: "
            cBody += STR0194+AllTrim(SW2->W2_PO_NUM)+STR0195+AllTrim(SY5->Y5_NOME) // "O arquivo anexo contém informações referente envio do processo " # " ao despachante "
         Endif

         cBody += Chr(13)+Chr(10)+STR0199+cArqTXT+STR0200+DTOC(dDataBase)+"  "+Time()
         IF IsSrvUnix() .or. RealRDD() == "CTREE"
            If !lIntDesp  // GFP - 24/07/2012 - Alterado endereço onde encontra-se arquivo para anexo quando for Nova Integração de Despachante
               cPathAttac  := Upper(GetSrvProfString("STARTPATH","/SIGAADV/"))
            Else
               cPathAttac  := Upper("/comex/intdespachante/gerados/")
            EndIf
            cAttachment := cPathAttac + cArq_Dest
         Else
            If !lIntDesp  // GFP - 24/07/2012 - Alterado endereço onde encontra-se arquivo para anexo quando for Nova Integração de Despachante
               cPathAttac  := Upper(GetSrvProfString("STARTPATH","\SIGAADV\"))
            Else
               cPathAttac  := Upper("\comex\intdespachante\gerados\")
            EndIf
            cAttachment := cPathAttac + cArq_Dest
         Endif
         CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk
         // Envio e-mail ao despachante
         If lOk
            If lAutentica
               If !MailAuth(cUserAut,cPassAut)
                  MSGINFO(STR0205,STR0047)//"Falha na Autenticação do Usuário"###"ERRO"
                  DISCONNECT SMTP SERVER RESULT lOk
                  IF !lOk
                     GET MAIL ERROR cErrorMsg
                     MSGINFO(STR0206+cErrorMsg,STR0047)//"Erro na Desconexão: "###"ERRO"
                  ENDIF
                  Return .F.
               EndIf
            EndIf

            SEND MAIL FROM cFrom TO cTo CC cFrom SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOk
            If !lOk
               GET MAIL ERROR cErrorMsg
               Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
               cEnvMail := Chr(13)+Chr(10)+STR0215//"ARQUIVO NÃO ENVIADO AO DESPACHANTE!!!"
            Else
               cEnvMail := Chr(13)+Chr(10)+STR0198 //"ARQUIVO ENVIADO VIA E-MAIL AO DESPACHANTE!!!"
            EndIf
         Else
            GET MAIL ERROR cErrorMsg
            Help("",1,"AVG0001057",,"Error: "+cErrorMsg,2,0)
            cEnvMail := Chr(13)+Chr(10)+STR0215//"ARQUIVO NÃO ENVIADO AO DESPACHANTE!!!"
         EndIf
         DISCONNECT SMTP SERVER RESULT lOk
         IF !lOk
            GET MAIL ERROR cErrorMsg
            MSGINFO(STR0206+cErrorMsg,STR0047)//"Erro na Desconexão: "###"ERRO"
         ENDIF
         //cEnvMail := Chr(13)+Chr(10)+STR0198
      EndIf

   Endif

   if lRet
      //Help("", 1, "AVG0000315",,cArq_Dest+" Anote e Tecle <ENTER>" +cEnvMail,2,16)
      // BAK - Alteração feita para a nova integração com despachante
      If Empty(cCadastro) .And. !lIntDesp
         E_Msg(STR0045+cArq_Dest+STR0046+cEnvMail,1000,.T.) //"ATENCAO : ARQUIVO GERADO P/ O DESPACHANTE E "###" ANOTE E TECLE <ENTER>"
      Else
         MsgInfo("Arquivo gerado para o despachante : " + AllTrim(cCodDeEI100) + " - " + AllTrim(cDespEI100),"Atenção")
      EndIf
   Endif

   ORI100Final(.F.)
ENDIF

// BAK - Alteração feita para a nova integração com despachante
//RETURN NIL
RETURN cArq_Dest

*------------------------------------------*
STATIC FUNCTION ORIBusGip(PDesp,PSeek,PCampo,nFase,cExpFab)
*------------------------------------------*
Local cValRet:= ""
Default nFase := 1 //MCF-19/08/2014 (1-PO, 2-DI)
Default cExpFab := "" //Valida se é E-Exportador, F-Fabricante

If SYU->(DBSEEK(xFilial("SYU")+PDesp+PSeek+PCampo))
    cValRet := SYU->YU_GIP_1
EndIf

If Empty(cValRet)
    cValRet := PCampo
EndIf

RETURN cValRet

*-----------------------------------------------*
FUNCTION ORI100Data(PData,lLogimex)
*-----------------------------------------------*
LOCAL Retorno
IF lLogimex = NIL
   Retorno:= STRZERO(DAY(PData),2)+STRZERO(MONTH(PData),2)+RIGHT(STRZERO(YEAR(PData),4),2)
ELSE
   Retorno := STRZERO(YEAR(PData),4)+STRZERO(MONTH(PData),2)+STRZERO(DAY(PData),2)
ENDIF

RETURN Retorno
*-------------------------------------------------------*
// Rotina sendo acessada pelo EICSU100
// JBS - 09/12/2004 Passadas alterações da versão 7.10
FUNCTION ORI100Numero(PValor,PTam_Int,PTam_Dec,PGip,PAltDec)
*-------------------------------------------------------*
LOCAL Retorno
IF(PGip = NIL,PGip:=.F.,)
IF(PAltDec = NIL,PAltDec:=.F.,)  // GFP - 09/03/2015

//Decimal := RIGHT(STR(PValor - INT(PValor),PTam_Dec+2,PTam_Dec),PTam_Dec+IF(PGip,1,0))
//Retorno := STRZERO(INT(PValor),PTam_Int)+Decimal

Retorno := STRZERO(PValor , PTam_Int+PTam_Dec+1 , PTam_Dec )
IF !PGip// RJB/AWR/JMS - 06/12/2004
   Retorno := STRTRAN(Retorno,".","")
ENDIF
IF PAltDec  // GFP - 09/03/2015
   Retorno := STRTRAN(Retorno,".",",")
ENDIF

RETURN Retorno
*---------------------------------------------------------------------*
FUNCTION ORI100Grv(PChave,TOpcao,cFase,PPrimeiro,bMsg,lProcessa)
*---------------------------------------------------------------------*
LOCAL MAusenciafa,Testa,Peso_L,Qtde_Est,Alias_Proc,;
      aFabr:={},Inclui_Forn,Vlr_Moeda,Vlr_Usd, cFornAux//,cUni410
LOCAL cForLojAux := "",cForLoj:= ""
LOCAL nOrdSW3 := SW3->(INDEXORD()) , nRecSW3 := SW3->(RECNO())
Local I , Wind , Indf
Local nComag:=0 //GFC 02/12/05
LOCAL nY6 := 0 	//Johann 19/09/2005
Local lPartNum := EasyGParam("MV_EICPNUM",,.F.) // AST - 28/11/2008 - Indica se na descrição do item irá contar o nº do Part Number
PRIVATE nPesTotLI:=0,nPesTotItem:=0,MDesFreLI:=0, nDespTot := 0
PRIVATE nPesTotPODI:=0,cIncoterm, MSeq:=0
PRIVATE nTot:=0, nCont:=0,aProcOrg:={},bWhileSWB
// Variaveis usadas no rdmake EICPOR01.PRW
PRIVATE cTexto, cCodItem, aGrv_Gip:={}  ,AreaPrincipal // POR CAUSA DO RDMAKE - RHP
PRIVATE nInland     := nPacking := nDescont := nFreteIntl := 0
PRIVATE MDesFrePODI := nQuantIt := nPrecoIt := nPesoItem  := nPesoTot := 0
PRIVATE nFob:=0, cUni410, nQtdNCM //Usado no Rdmake EICOR100
PRIVATE cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
PRIVATE cDescricaoItem:="", nTamItem:=AVSX3("B1_VM_GI",03)
PRIVATE nFobFre:=0,nIt_Rec,MDesFreMoeda:=0//ASR 06/12/2005
Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 //GFC - 02/12/05
Private lIntDraw := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
Private lDePara2 := EasyGParam("MV_DEPARA2",,.F.) // TDF - 28/07/10
nOrderSX3:=(IndexOrd())
SX3->(DbSetOrder(2))                          //Usado para o Drawback
Private lExisteWP_AC := SX3->(DbSeek("WP_AC"))
Private lInfOrgAnu:=SX3->(DBSEEK("B1_ORG_ANU")) .AND. SX3->(DBSEEK("B1_PRO_ANU"))
Private bProcPE
SX3->(DBSETORDER(nOrderSX3))
Private aFaseNVE := {.F.,.F.,.F., {}} //1=DI(Emb/Desemb.),2=LI(Pli),3=CD(Cad.Prod)

If cFase == FASE_DI //NCF - 24/05/2018 - Verificar em todo o processo se existe NVE nas fase de DI/PLI/PO
   If !OR100PqNVE("DI" ,TRB->W6_HAWB ,.F.)
      If !OR100PqNVE("LI",TRB->W6_HAWB ,.F.) 
         OR100PqNVE("PO",TRB->W6_HAWB ,.F.)
      EndIf  
   EndIf 
EndIf

IF cFase = FASE_PO
   cPos_Chave := TRB->(FIELDPOS('W2_PO_NUM'))//AWR INVOICE
ELSE
   cPos_Chave := TRB->(FIELDPOS('W6_HAWB'))//AWR INVOICE
ENDIF
PChave:=IF(PChave==NIL,EVAL(CAMPO),PChave)

SYF->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SB5->(DBSETORDER(1))

IF TOpcao = ENVIA_ORIENTADOR .AND. cFase = FASE_PO
   SWP->(DBSETORDER(1))
   SWP->(DBSEEK(xFilial()+PChave))
   SW5->(DBSETORDER(7))
   SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
   SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
   SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
   SW4->(DBSEEK(xFilial()+SWP->WP_PGI_NUM))

   MAusenciafa := "1"  ;  Testa := .T.
   Peso_L := Qtde_Est := Vlr_Moeda := Vlr_Usd := 0

   MDespesas := 0

   IF EasyGParam("MV_RATEIO") $ cSim
      MDespesas:= SW4->W4_INLAND + SW4->W4_PACKING - SW4->W4_DESCONTO
      IF SW4->(FIELDPOS("W4_OUT_DES")) # 0
         MDespesas+=SW4->W4_OUT_DES
      ENDIF
      // EOB - 14/07/08 - Tratamento de incoterms com seguro
      IF lSegInc .AND. SW4->W4_SEGINC $ cNao .AND.  AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_SEG")/* FSM - 28/12/10 */  //AllTrim(SW4->W4_INCOTERM) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         MDespesas+=SW4->W4_SEGURO
      ENDIF
   ENDIF

   // PLB 06/08/07 - Tratamento de Frete
   IF lW4_Fre_Inc  .Or.  EasyGParam("MV_RAT_FRE") $ cSim
      IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"DESPESAS"),)
      MDesFrePLI  := SW4->W4_FRETEIN              //<< PESO
   ENDIF

   IF PGI_Chave # SWP->WP_PGI_NUM .OR. tBate1vez
      nPesTotPLI:=0
      IF lW4_Fre_Inc  .Or.  EasyGParam("MV_RAT_FRE") $ cSim

         SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM))

         DO WHILE SWP->WP_PGI_NUM=SW5->W5_PGI_NUM .AND. !SW5->(EOF()).AND.;
                  xFilial("SW5")==SW5->W5_FILIAL    ///AWR

            IF SW5->W5_SEQ # 0
               SW5->(DBSKIP()) ; LOOP
            ENDIF

            SB1->( DBSEEK( xFilial() + SW5->W5_COD_I ) )

            nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) //FCD 04/07/2001   // LDR OS - 1240/03
            IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"7"),)
            IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOITEM"),)
            nPesTotPLI += SW5->W5_QTDE * nPesoItem   //<< PESO

            SW5->( DBSKIP() )

         ENDDO

      ENDIF

      PGI_Chave := SWP->WP_PGI_NUM
      tBate1vez :=.F.
      SW5->( DBSEEK( xFilial() + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI) )
   ENDIF

   cFob_Cli := 0
   nFob:=0
   WHILE ! SW5->(EOF()) .AND.;
           SWP->WP_PGI_NUM+SWP->WP_SEQ_LI == SW5->W5_PGI_NUM+SW5->W5_SEQ_LI .AND.;
           SW5->W5_FILIAL==xFilial("SW5")

      IF SW5->W5_SEQ # 0
         SW5->(DBSKIP()) ; LOOP
      ENDIF
      SJ5->(DBSETORDER(1))
      SB1->(DBSETORDER(1))
      SB1->(DBSEEK(xFilial()+SW5->W5_COD_I))
      SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))

     nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) //FCD 04/07/2001   // LDR OS - 1240/03

     IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"7"),)//AWR 11/11/1999
     IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOITEM"),)
     IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"FOB"),)

     nPesTotLI+= SW5->W5_QTDE * nPesoItem //<< PESO
     cFob_Cli += SW5->W5_QTDE * SW5->W5_PRECO+nFob
     SW5->(DBSKIP())
   ENDDO

   cFob_Aux := cFob_Cli
   MDesFreLI := (MDesFrePLI*(NPesTotLI/IF(NPesTotPLI<=0,1,NPesTotPLI) ))//<< PESO
   MDespesas := (MDespesas * (cFob_Cli/SW4->W4_FOB_TOT))
   //cFob_Cli  += MDespesas+MDesFreLI

   //** PLB 06/08/07
   cFob_Cli  += MDespesas
   If !lW4_Fre_Inc  .Or.  ( SW4->W4_FREINC $ cNao  .And.  AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_FRETE") )/* FSM - 28/12/10 */  //AllTrim(SW4->W4_INCOTERM) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP" )
      cFob_Cli += MDesFreLI
   EndIf
   //**

   SW5->( DBSEEK( xFilial() + SWP->WP_PGI_NUM + SWP->WP_SEQ_LI) )
   cFor_Azul:=cFabr_Azul:=" "
   IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"FAB_FOR_LINAZUL"),)


   WHILE ! SW5->(EOF()) .AND.;
           SWP->WP_PGI_NUM+SWP->WP_SEQ_LI == SW5->W5_PGI_NUM+SW5->W5_SEQ_LI .AND.;
           SW5->W5_FILIAL==xFilial("SW5")

      IF SW5->W5_SEQ # 0
         SW5->(DBSKIP()) ; LOOP
      ENDIF

      SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))

      cUni410:=BUSCA_UM(SW5->W5_COD_I+SW5->W5_FABR +SW5->W5_FORN,SW5->W5_CC+SW5->W5_SI_NUM,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))

      IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"WHILE_SW5_A"),) // JBS - 20/05/2004
      SAH->(DBSEEK(xFilial()+cUni410))
      SYG->(DBSEEK(xFilial()+SW2->W2_IMPORT+SW5->W5_FABR+EICRetLoja("SW5","W5_FABLOJ")+SW5->W5_COD_I))
      SB1->(DBSEEK(xFilial()+SW5->W5_COD_I))

      IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"8"),)//AWR 11/11/1999

      cTx_Conv := 1
      If cUni410 # SWP->WP_UNID
         cFilSJ5 := xFilial("SJ5")
         IF AvVldUn(SWP->WP_UNID) // MPG - 06/02/2018
            cTx_Conv:=B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))  // LDR OS - 1240/03
         ELSEIF SJ5->(DBSEEK(cFilSJ5+AVKEY(cUni410,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")+SW5->W5_COD_I))
            cTx_Conv := SJ5->J5_COEF
         ELSEIF SJ5->(DBSEEK(cFilSJ5+AVKEY(cUni410,"J5_DE")+AVKEY(SWP->WP_UNID,"J5_PARA")))
            DO WHILE !SJ5->(EOF()) .AND. SJ5->J5_FILIAL  == cFilSJ5 .AND.;
                                         SJ5->J5_DE      == AVKEY(cUni410,"J5_DE") .AND.;
                                         SJ5->J5_PARA    == AVKEY(SWP->WP_UNID,"J5_PARA")
               IF EMPTY(SJ5->J5_COD_I)
                  cTx_Conv := SJ5->J5_COEF
                  EXIT
               ENDIF
               SJ5->(dbSkip())
            ENDDO
         ENDIF
      ENDIF

      IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
         cFornAux   := SW2->W2_EXPORTA
         nValParid  := SW2->W2_PARID_US
         If EICLoja()
            cForLojAux := SW2->W2_EXPLOJ
         EndIf
      ELSE
         cFornAux:= SW2->W2_FORN
         nValParid:=1
         If EICLoja()
            cForLojAux := SW2->W2_FORLOJ
         EndIf
      ENDIF

      IF Testa
         IF SW5->W5_FABR # cFornAux .OR. IIF(EICLoja(),SW5->W5_FABLOJ # cForLojAux,.F.)
            IF EMPTY(SW5->W5_FABR_01) .OR. IF(EICLoja(),EICEmptyLJ("SW5","W5_FAB1LOJ"),.F.)
               MAusenciafa:="2"
            ELSE
               MAusenciafa:="3"  ;  Testa := .F.
            ENDIF
         ENDIF
      ENDIF

      ItemLi->(DBAPPEND())
      ItemLi->NR_MAQ     := cCodigo
      ItemLi->DT_INTEGR  := cData
      ItemLi->PROC_EASY  := SW5->W5_PGI_NUM
      ItemLi->SEQ_LI     := SW5->W5_SEQ_LI
      ItemLi->TRAT_MICRO := SWP->WP_MICRO
      ItemLi->SEQ_PRODUT := PADL(++MSeq,2,"0") //PADL(VAL(SW5->W5_POSICAO),2,"0")
      ItemLi->QTD_MERC   := ORI100Numero( (SW5->W5_QTDE ),09,5)  //ACD.
      ItemLi->UN_MED_COM := SAH->AH_DESCPO

      If lInfOrgAnu .And. SB1->(DBSEEK(xFilial("SB1")+SW5->W5_COD_I))
         If (Ascan(aProcOrg,SB1->B1_PRO_ANU+SB1->B1_ORG_ANU))=0
            ItemLi->NR_PRO_ANU:=SB1->B1_PRO_ANU
            ItemLi->SG_ORG_ANU:=SB1->B1_ORG_ANU
            Aadd(aProcOrg,SB1->B1_PRO_ANU+SB1->B1_ORG_ANU)
         Endif
      End If
      nPesTotItem:= SW5->W5_QTDE*If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) //<< PESO //FCD 04/07/2001

      IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"9"),)//AWR 11/11/1999
      IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESTOTITEM"),)

      nFob := SW5->W5_QTDE*SW5->W5_PRECO
      cValor_Tot := nFob + (MDespesas * (nFob/cFob_Aux))
      //cValor_Tot += MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI)) //<< PESO
      //** PLB 06/08/07
      If !lW4_Fre_Inc .Or. ( SW4->W4_FREINC $ cNao  .And.  AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_FRETE") )/* FSM - 28/12/10 */ //AllTrim(SW4->W4_INCOTERM) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP" )
         cValor_Tot += MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI)) //<< PESO
      EndIf
      //**
      cValor_Uni := cValor_Tot / SW5->W5_QTDE
      cFob_Cli   -= SW5->W5_QTDE * cValor_Uni

      If UPPER(cUni410) = UPPER(SWP->WP_UNID)
         nQtdNCM := Round(SW5->W5_QTDE,5)
      ElseIf AvVldUn(SWP->WP_UNID) // MPG - 06/02/2018
         nQtdNCM := Round(SW5->W5_QTDE*If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO),5)    // LDR OS - 1240/03
      Else
         nQtdNCM := Round(SW5->W5_QTDE * cTx_Conv,5)
      ENDIF

      If lIntDraw .and. lExisteWP_AC .and. !Empty(Alltrim(SW5->W5_SEQSIS))
         ItemLi->SEQ_DRAWB := SW5->W5_SEQSIS
         ItemLi->VL_DRAWB  := ORI100Numero( (nFob),13,2)
//       ItemLi->QTD_DRAWB := ORI100Numero( (SW5->W5_QTDE ),09,5)
         ItemLi->QTD_DRAWB := ORI100Numero( nQtdNCM,09,5)
      EndIf

      ItemLi->VL_UNITMER := ORI100Numero(cValor_Uni,13,7) //JBS-19/01/2005 RJB 16/07/2004 nValParid  V 5.08

      //FMB - 01/10/2004
      cDescricaoItem := iif(lPartNum .And. len(alltrim(SA5->A5_PARTOPC)) > 0,"P/N.: "+alltrim(SA5->A5_PARTOPC)+" - ","") +; // AST - 28/11/08 - Inclusão do tratamento do parametro MV_EICPNUM (Part Number)
                        MSMM(SB1->B1_DESC_GI,nTamItem)

      cTexto := AllTrim(cDescricaoItem)  + chr(13)+chr(10)  // FMB - 01/10/2004
      cTexto += SA5->A5_CODPRF + chr(13)+chr(10)  //+ CRLF  + SYG->YG_REG_MIN       // ACSJ - 02/06/2004
      cTexto += iif(SYG->(EoF()),"",STR0214 + SYG->YG_REG_MIN +;                    // ACSJ - 02/06/2004
                    STR0208 + DtoC(SYG->YG_VALIDA) )                                // ACSJ - 02/06/2004
      ItemLi->DES_DETMER := cTexto                                                  // ACSJ - 02/06/2004
     // complementação da descrição do item com o Numero da Autorização do Ministerio e Validade - ACSJ - 02/06/2004

      IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"DESC_LI_SISC"),)

      //IF EasyEntryPoint("EICLOTE")
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Excecuta rdmake que adiciona os lotes na descricao   ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         //ExecBlock("EICLOTE",.F.,.F.,"ENVIO")
      //Endif
      //If ParamIXB == "ENVIO"
         If SWV->(dbSeek(xFilial()+SPACE(17)+SW5->(W5_PGI_NUM+W5_PO_NUM+W5_CC+W5_SI_NUM+W5_COD_I+Str(W5_REG,AVSX3("W5_REG",3)))))
            IF cREPL = NIL
               cREPL:=REPL("=",LEN(SWV->WV_LOTE))+" "+REPL("=",LEN(AVSX3("W5_QTDE",6))-3)+" ========"
            ENDIF
            //Grava os lotes na descricao detalhada da mercadoria ...
            ItemLi->DES_DETMER := ItemLi->DES_DETMER + CRLF
            ItemLi->DES_DETMER := ItemLi->DES_DETMER + STR0224 +CRLF //"Lote            Quantidade Validade"
            ItemLi->DES_DETMER := ItemLi->DES_DETMER + cREPL

            While !SWV->(Eof()) .And. SWV->WV_FILIAL == xFilial("SWV") .And.;
               SWV->WV_HAWB == SPACE(17) .AND.;
               SW5->(W5_PGI_NUM+W5_PO_NUM+W5_CC+W5_SI_NUM+W5_COD_I+Str(W5_REG,AVSX3("W5_REG",3))) == ;
               SWV->(WV_PGI_NUM+WV_PO_NUM+WV_CC+WV_SI_NUM+WV_COD_I+Str(WV_REG,AVSX3("WV_REG",3)))

               ItemLi->DES_DETMER := ItemLi->DES_DETMER+CRLF+SWV->WV_LOTE+" "+Transf(SWV->WV_QTDE,AVSX3("W5_QTDE",6))+" "+Dtoc(SWV->WV_DT_VALI)
               SWV->(dbSkip())  
            End
         Endif
      //EndIf



      nPesoItem:=If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO) //FCD 04/07/2001   // LDR OS - 1240/03

      IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"10"),)//AWR 11/11/1999
      IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOITEM"),)

      Peso_L += SW5->W5_QTDE * nPesoItem

//VI  Qtde_Est += SW5->W5_QTDE * cTx_Conv
      Qtde_Est += nQtdNCM

      Vlr_Moeda += SW5->W5_QTDE * cValor_Uni // JBS-19/01/2005 * nValParid RJB 16/07/2004 v 5.08
      //** PLB 29/08/07
      If lW4_Fre_Inc  /*.And. SW4->W4_FREINC $ cSim*/  .And.  AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_FRETE")/* FSM - 28/12/10 */ //AllTrim(SW4->W4_INCOTERM) $ "CFR,CIF,CIP,CPT,DAF,DES,DEQ,DDU,DDP"
         Vlr_Moeda -= MDesFreLI*(nPesTotItem/IF(nPesTotLI<=0,1,nPesTotLI))
      EndIf

      // EOB - 14/07/08
      IF lSegInc .AND. SW4->W4_SEGINC $ cSim .AND. AvRetInco(AllTrim(SW4->W4_INCOTERM),"CONTEM_SEG")/* FSM - 28/12/10 */ //AllTrim(SW4->W4_INCOTERM) $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         Vlr_Moeda -= (SW4->W4_SEGURO * (nFob/SW4->W4_FOB_TOT))
      ENDIF


      //**
      Vlr_Usd   += SW5->W5_QTDE * cValor_Uni * nValParid

      SW5->(DBSKIP())
   ENDDO

   IF ROUND(cFob_Cli,2) # 0
      ItemLi->VL_UNITMER := ORI100Numero(cValor_Uni+cFob_Cli,13,7)
      Vlr_Moeda-= SW5->W5_QTDE * cValor_Uni // JBS-19/01/2005 * nValParid RJB 16/07/2004 v 5.08
      Vlr_Usd  -= SW5->W5_QTDE * cValor_Uni * nValParid
      Vlr_Moeda+= SW5->W5_QTDE * (cValor_Uni+cFob_Cli) // JBS-19/01/2005 * nValParid RJB 16/07/2004 v 5.08
      Vlr_Usd  += SW5->W5_QTDE * (cValor_Uni+cFob_Cli) * nValParid
   ENDIF

   SW5->(DBSEEK(xFilial()+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
   SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
   SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
   SW4->(DBSEEK(xFilial()+SWP->WP_PGI_NUM))
   SYG->(DBSEEK(xFilial()+SW2->W2_IMPORT+SW5->W5_FABR+EICRetLoja("SW5","W5_FABLOJ")+SW5->W5_COD_I))

   // Gravação dos Processos e Orgao Anuente  RS - 27/10/05

   EIT->(DBSETORDER(1))
   EIT->(DBSEEK(xFilial("EIT")+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))

   DO While !EIT->(Eof()) .And.;
      		EIT->EIT_FILIAL == xFilial("EIT")  .And.;
    		EIT->EIT_PGI_NU == SWP->WP_PGI_NUM .AND.;
 	        EIT->EIT_SEQ_LI == SWP->WP_SEQ_LI

      Work_PAnu->(DBAPPEND())
      Work_PAnu->NR_MAQ    :=cCodigo
      Work_PAnu->DT_INTEG  :=cData
      Work_PAnu->PROC_EASY :=SWP->WP_PGI_NUM
      Work_PAnu->SEQ_LI    :=SWP->WP_SEQ_LI
      Work_PAnu->TRAT_MICRO:= SWP->WP_MICRO
      Work_PAnu->NR_PROC_AN:=EIT->EIT_NUMERO
      Work_PAnu->SG_ORG_PRO:=EIT->EIT_ORGAO

      EIT->(DBSKIP())

   ENDDO
   CapaLi->(DBAPPEND())
   CapaLi->NR_MAQ      := cCodigo
   CapaLi->DT_INTEG    := cData
   CapaLi->PROC_EASY   := SWP->WP_PGI_NUM
   CapaLi->SEQ_LI      := SWP->WP_SEQ_LI
   IF TOpcao = ENVIA_GIPLITE
      RecLock("SWP",.F.)
      SWP->WP_NR_MAQ      := cCodigo
      SWP->WP_ENV_ORI     := cData
      IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"GRAVA_SWP"),)
      SWP->(MsUnlock())
   ENDIF
   DBSELECTAREA("CapaLi")
   CapaLi->TRAT_MICRO  := SWP->WP_MICRO
   CapaLi->LI_SUBSTIT  := SWP->WP_SUBST
   CapaLi->TIPO_IMPOR  := "1"
   CapaLi->NR_IMPORT   := SYT->YT_CGC
   CapaLi->ATIV_ECO_I  := SYT->YT_COD_ATV
   CapaLi->URF_ENT_ME  := PADL(SW4->W4_URF_CHE,7,"0")

   IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")   // A.C.D.
      SA2->(DBSEEK(xFilial()+SW2->W2_EXPORTA+EICRetLoja("SW2","W2_EXPLOJ")))
   ELSE
      SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
   ENDIF

   CapaLi->FORN_ESTR   := SA2->A2_NOME
   CapaLi->LOG_FORN_E  := SA2->A2_END

   //** AAF 16/06/2008 - Adicionado complemento do endereço do fornecedor
   CapaLi->COMP_FORN   := SA2->A2_ENDCOMP
   //**

   CapaLi->NRFORN_EST  := SA2->A2_NR_END
   CapaLi->CID_FORN    := SA2->A2_MUN
   CapaLi->EST_FORN    := SA2->A2_ESTADO // VI
   CapaLi->PAIS_AQ_ME  := PADL(SA2->A2_PAIS,3,"0")

   CapaLi->MERC_NCM    := SWP->WP_NCM
   CapaLi->PAIS_PROCM  := IF(!EMPTY(SWP->WP_PAIS_PR),PADL(SWP->WP_PAIS_PR,3,"0"),PADL(SYR->YR_PAIS_OR,3,"0"))

   IF SWP->(FIELDPOS("WP_TIPFAB")) # 0
      CapaLi->AUSENCIAFA  := SWP->WP_TIPFAB
   ELSE
      CapaLi->AUSENCIAFA  := MAusenciafa
   ENDIF

   /* 1 - Fornecedor é o fabricante
      2 - Fabricante conhecido
      3 - Fabricante desconhecido, campo WP_PAISORI*/

   //IF MAusenciafa = "2"  // JONATO 19-12-2001
   IF MAusenciafa == "1"  // AST - 11/12/08
      CapaLi->PAIS_OR_ME  := PADL(SA2->A2_PAIS,3,"0")
	  CapaLi->COMP_FABR   := SA2->A2_ENDCOMP //LGS - 20/08/2013 - COMPLEMENTO ENDEREÇO FABRICANTE
   ELSEIF MAusenciafa == "2"
      SA2->(DBSEEK(xFilial()+SWP->WP_FABR + EICRetLoja("SWP","WP_FABLOJ")))
      CapaLi->NM_FABR_ME  := SA2->A2_NOME
      CapaLi->LOGR_FABR   := SA2->A2_END
      CapaLi->NR_FABR     := PADL(SA2->A2_NR_END,6,"0")
      CapaLi->CID_FABR    := SA2->A2_MUN
      CapaLi->ESTADO_FAB  := SA2->A2_ESTADO // VI
      CapaLi->PAIS_OR_ME  := PADL(SA2->A2_PAIS,3,"0")
	  CapaLi->COMP_FABR   := SA2->A2_ENDCOMP //LGS - 20/08/2013 - COMPLEMENTO ENDEREÇO FABRICANTE
   ELSE
      CapaLi->PAIS_OR_ME  := PADL(SWP->WP_PAISORI,3,"0") // O SISCOMEX PREENCHE ESSE CAMPO, MESMO QUANDO O FABRICANTE E O FORNECEDOR
   ENDIF

   SY8->(DBSEEK(xFilial()+SW4->W4_REGIMP))
   IF !EMPTY(SW4->W4_COND_PAG)
      SY6->(DBSEEK(xFilial()+SW4->W4_COND_PAG+STR(SW4->W4_DIAS_PAG, TY6DIASPA))) //TY6DIASPA tamanho
   ELSE
      IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
         SY6->(DBSEEK(xFilial()+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
      ELSE
         SY6->(DBSEEK(xFilial()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
      ENDIF
   ENDIF

   If SW4->W4_ACO_TAR == "2"
      CapaLi->NALADI_NCC  := SWP->WP_NALADI
      CapaLi->NALADI_SH   := SWP->WP_NAL_SH
   EndIf
   CapaLi->PL_MERC     := ORI100Numero(Peso_L,10,05)
   CapaLi->QT_UN_EST   := ORI100Numero(Qtde_Est,09,05)

   CapaLi->MOEDA_NEG := IF(SYF->(DBSEEK(xFilial()+SW2->W2_MOEDA)),SYF->YF_COD_GI,SPACE(3))

   IF SY6->Y6_TIPOCOB == "1"	//Johann 19/09/2005
   	IF SY6->Y6_DIAS_PA = -1
	   	CapaLi->DIA_LIM_PG  := STRZERO(0, TY6DIASPA) //TY6DIASPA tamanho
	   ELSEIF SY6->Y6_DIAS_PA >= 900
	   	//Percorre todas as parcelas procurando o número de dias da última - Johann 19/09/2005
	   	nY6 := 1
	   	While nY6 <= 10
	   		IF nY6 > 1 .AND. &("SY6->Y6_DIAS_"+STRZERO(nY6,2)) == 0
	   			IF &("SY6->Y6_DIAS_"+STRZERO(nY6-1,2)) > 0
	   				CapaLi->DIA_LIM_PG := STRZERO(&("SY6->Y6_DIAS_"+STRZERO(nY6-1,2)), AvSX3("Y6_DIAS_" + StrZero(nY6-1,2), AV_TAMANHO))
	   			Else
	   				CapaLi->DIA_LIM_PG := Space(AvSX3("Y6_DIAS_" + StrZero(nY6-1,2), AV_TAMANHO))
	   			Endif
	   			nY6 := 99	//Encontrou a parcela
	   		ENDIF
	   		nY6 += 1
	   	Enddo
	   	IF nY6 == 11	//Se todas estavam preenchidas, pega a última
		   	CapaLi->DIA_LIM_PG := STRZERO(SY6->Y6_DIAS_10, AvSX3("Y6_DIAS_10", AV_TAMANHO))
	   	ENDIF
   	Else
   		CapaLi->DIA_LIM_PG  := IF(EMPTY(SY6->Y6_DIAS_PA),SPACE(TY6DIASPA),STRZERO(SY6->Y6_DIAS_PA, TY6DIASPA)) //TY6DIASPA tamanho
   	Endif
   ELSE
   	CapaLi->DIA_LIM_PG  := SPACE(TY6DIASPA) //TY6DIASPA tamanho
   ENDIF
   CapaLi->INCOTERM_V  := IF(!EMPTY(SW4->W4_INCOTER),SW4->W4_INCOTER,SW2->W2_INCOTER)

   IF CapaLi->INCOTERM_V $ "DEQ/DDU/DAF/DES"
      MsgAlert("Os incoterms DEQ,DDU,DAF e DES foram descontinuados!"+CHR(13)+CHR(10)+;
               "Utilize os incoterms DAT ou DAP","AVISO")
               Return .F.
   ENDIF

   CapaLi->VLMERCMOE   := ORI100Numero(Vlr_Moeda,13,02)
   CapaLi->VLTOTUSD    := ORI100Numero(Vlr_Usd,09,02)
   CapaLi->TIPO_AC_TA  := SW4->W4_ACO_TAR
   CapaLi->TIP_AC_ALA  := IF(EMPTY(SWP->WP_ALADI),SPACE(3),PADL(SWP->WP_ALADI,3,"0"))
   //CapaLi->REG_TRIBUT  := SY8->Y8_REG_TRI
   //CapaLi->FUND_LEG_R  := If(SW4->W4_REGIMP="A9",SPACE(2),SW4->W4_REGIMP)
   //** PLB 06/08/07 - Fundamento Legal direto da LI
   If lW4_Reg_Tri
      CapaLi->REG_TRIBUT  := SWP->WP_REG_TRI
      CapaLi->FUND_LEG_R  := IIF(SWP->WP_FUN_REG == "A9", Space(2), SWP->WP_FUN_REG)
   Else
      CapaLi->REG_TRIBUT  := SY8->Y8_REG_TRI
      CapaLi->FUND_LEG_R  := If(SW4->W4_REGIMP="A9",SPACE(2),SW4->W4_REGIMP)
   EndIf
   //**
   CapaLi->COBERT_CAM  := SY6->Y6_TIPOCOB
   CapaLi->MODAL_PGTO  := IF(SY6->Y6_TIPOCOB = "1".OR.SY6->Y6_TIPOCOB = "2",PADL(SY6->Y6_TABELA,2,"0"),SPACE(2))
   CapaLi->ORG_FIN_IN  := IF(SY6->Y6_TIPOCOB = "3",PADL(SY6->Y6_INST_FI,2,"0"),SPACE(2))
   CapaLi->MOT_SEM_CO  := IF(SY6->Y6_TIPOCOB = "4",PADL(SY6->Y6_MOTIVO,2,"0"),SPACE(2))
   CapaLi->AGE_SECEX   := SW4->W4_AGSECEX
   CapaLi->URF_DESPAC  := PADL(SW4->W4_URF_DES,7,"0")
   CapaLi->COMUNI_COM  := SW4->W4_COMUNICA
   CapaLi->INF_COMPL   := MSMM(SW4->W4_DESC_GE,AVSX3("W4_VM_DESG",03))



   If lIntDraw .and. lExisteWP_AC .and. !Empty(Alltrim(SWP->WP_AC))
      ED0->(dbSetOrder(2))
      If ED0->(dbSeek(xFilial("ED0")+SWP->WP_AC))
         If ED0->ED0_MODAL == "2"      //Para Isençao
            CapaLi->TEM_DRAWB := "3"
            CapaLi->FUND_LEG_R:= "16"  //Fundamento Legal referente ao Drawback TAN
         ElseIf ED0->ED0_TIPOAC == "06"
            CapaLi->TEM_DRAWB := "1"
            CapaLi->FUND_LEG_R:= "16"  //Fundamento Legal referente ao Drawback TAN
         Else
            CapaLi->TEM_DRAWB := "2"
         EndIf
         CapaLi->REG_TRIBUT:= If(ED0->ED0_MODAL == "2", "3", "5")
      EndIf
      ED0->(dbSetOrder(1))
   Else
      CapaLi->TEM_DRAWB := "3"
   EndIf
   If CapaLi->TEM_DRAWB == "3"
      CapaLi->ATO_DRAWBA  := If(lIntDraw .and. lExisteWP_AC .and. Empty(Alltrim(SW4->W4_ATO_CONC)), SUBSTR( SWP->WP_AC, 1, 13 ), SUBSTR( SW4->W4_ATO_CONC, 1, 13 ))
   Else
      CapaLi->REG_DRAWB   := If(lIntDraw .and. lExisteWP_AC .and. Empty(Alltrim(SW4->W4_ATO_CONC)), SUBSTR( SWP->WP_AC, 1, 11 ), SUBSTR( SW4->W4_ATO_CONC, 1, 11 ))
   EndIf

   IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ENVIO_CAPALI"),)

   Inicio := 1
   FOR I=1 TO 10
       IF EMPTY(SUBSTR(SWP->WP_DESTAQ,Inicio,3))
          Inicio+=3
          LOOP
       ENDIF
       NcmLi->(DBAPPEND())
       NcmLi->NR_MAQ       := cCodigo
       NcmLi->DT_INTEGR    := cData
       NcmLi->PROC_EASY    := SWP->WP_PGI_NUM
       NcmLi->SEQ_LI       := SWP->WP_SEQ_LI
       NcmLi->TRAT_MICRO   := SWP->WP_MICRO
       NcmLi->DESTAQUE     := SUBSTR(SWP->WP_DESTAQ,Inicio,3)
       Inicio+=3
   NEXT

ELSE
   lDI_Cambio := .F.
   Gip_Lite2->(avzap())

   IF lProcessa
      lProcessa:=.F.
   ENDIF

   MConta:=1
   nTotalMarca++
   nFreteMoeda:=0
   nFobMoeda  :=0
   bPeso      :={ || W5PESO() }
   nSomaPesoL :=0
   cConsigna  :=""
   cAquisicao :=""
   nPeso_L    :=0
   MSeq       :=0

   SA5->(DBSETORDER(3))
		 DO CASE
		    CASE cFase = FASE_DI
		         SW3->(DBSETORDER(8))

		         SW6->(DBSEEK(xFilial("SW6")+TRB->W6_HAWB))

		         SW9->(DBSETORDER(3))
		         lInv := SW9->(DBSEEK(xFilial("SW9")+TRB->W6_HAWB))

 		         SWA->(dbSetOrder(1))
                 SWB->(dbSetOrder(1))
                 lDI_Cambio := TOpcao = ENVIA_GIPLITE       .And. ;
                               SWA->(dbSeek(xFilial("SWA")+SW6->W6_HAWB)) .And. ;
                               SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB))

		         IF lInv
		            SW7->(DBSETORDER(4))
		            SW8->(DBSETORDER(1))
		            SWP->(DBSETORDER(1))
		            bProcesso:={ ||SW6->W6_HAWB  }
		            bProduto :={ ||SW8->W8_COD_I }
		            bQtde    :={ ||SW8->W8_QTDE  }
		            bFor     :={ ||SW8->W8_FORN+IIF(EICLoja(),SW8->W8_FORLOJ,"")  }
		            bFabr    :={ ||SW8->W8_FABR+IIF(EICLoja(),SW8->W8_FABLOJ,"")  }
		            bIncoterm:={ ||SW9->W9_INCOTER}
		            bRegist  :={ ||SWP->WP_REGIST }
		            bPo_Num  :={ ||SW8->W8_PO_NUM }
		            bPosicao :={ ||SW8->W8_POSICAO }
		            bInvoice :={ ||SW9->W9_INVOICE } // SVG - 03/09/2010 -
		            SYT->(DBSEEK(xFilial()+SW6->W6_IMPORT))
		            cPaisProc:=SW6->W6_PAISPRO
		            DO WHILE ! SW9->(EOF()) .AND. SW9->W9_HAWB == SW6->W6_HAWB
		               SW8->(DBSEEK(xFilial("SW8")+ SW9->W9_HAWB + SW9->W9_INVOICE + SW9->W9_FORN + EICRetLoja("SW9","W9_FORLOJ")))
		               DO WHILE ! SW8->(EOF()) .AND. SW8->W8_HAWB == SW9->W9_HAWB .AND. ;
		                  SW8->W8_INVOICE == SW9->W9_INVOICE .AND. SW8->W8_FORN == SW9->W9_FORN .AND. IIF(EICLoja(),SW8->W8_FORLOJ==SW9->W9_FORLOJ,.T.)
		                  SYF->(DBSEEK(xFilial()+SW9->W9_MOE_FOB))
		                  SW2->(DBSEEK(xFilial("SW2")+ SW8->W8_PO_NUM))
		                  SW4->(DBSEEK(xFilial("SW4") + SW8->W8_PGI_NUM))
		                  SW3->(DBSEEK(xFilial("SW3")+SW8->W8_PO_NUM+SW8->W8_POSICAO))
		                  SW7->(DBSEEK(xFilial()+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
		                  SAH->(DBSEEK(xFilial()+BUSCA_UM(SW8->W8_COD_I+SW8->W8_FABR +SW8->W8_FORN,AvKey(SW8->W8_CC,"W3_CC")+SW8->W8_SI_NUM,EICRetLoja("SW8","W8_FABLOJ"),EICRetLoja("SW8","W8_FORLOJ"))))  // TRP - 15/04/2013
		                  SB1->(DBSEEK(xFilial("SB1") + SW8->W8_COD_I ))
		                  //SA5->(DBSEEK(xFilial("SA5") + SW8->W8_COD_I + SW8->W8_FABR + SW8->W8_FORN ))
		                  EICSFabFor(xFilial("SA5")+ SW8->W8_COD_I + SW8->W8_FABR+ SW8->W8_FORN,EICRetLoja("SW8","W8_FABLOJ"),EICRetLoja("SW8","W8_FORLOJ"))
		                  SYD->(DBSEEK(xFilial("SYD")+Busca_NCM("SW7")))
		                  SWP->(DBSEEK(xFilial("SWP")+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
		                  SYQ->(DBSEEK(xFilial()+SW6->W6_VIA_TRA))
		                  IF ! EMPTY(SW9->W9_COND_PA)
		                     SY6->(DBSEEK(xFilial()+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA, TY6DIASPA))) //TY6DIASPA tamanho
		                  ELSEIF !EMPTY(SW4->W4_COND_PA)
		                     SY6->(DBSEEK(xFilial()+SW4->W4_COND_PA+STR(SW4->W4_DIAS_PA, TY6DIASPA))) //TY6DIASPA tamanho
		                  ELSE
		                     IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
		                        SY6->(DBSEEK(xFilial()+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
		                     ELSE
		                        SY6->(DBSEEK(xFilial()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
		                     ENDIF
		                  ENDIF
		                  SYR->(DBSEEK(xFilial()+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST))
		                  IF !EMPTY(SW2->W2_EXPORTA).And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
		                     cFor:=SW2->W2_EXPORTA
		                     nValParid:=SW2->W2_PARID_US
		                     If EICLoja()
		                         cForLoj := SW2->W2_EXPLOJ
		                     EndIf
		                  ELSE
		                     cFor:=SW8->W8_FORN
		                     nValParid:=1
		                     If EICLoja()
		                         cForLoj := SW8->W8_FORLOJ
		                     EndIf
		                  ENDIF
		                  IF ASCAN(aFabr,{|x| x[1] = cFor+cForLoj}) = 0
		                     AADD(aFabr,{cFor+cForLoj,"FO"})
		                  ENDIF
		                  IF ASCAN(aFabr,{|x| x[1] = SW8->W8_FABR+EICRetLoja("SW8","W8_FABLOJ")}) = 0
		                     AADD(aFabr,{SW8->W8_FABR+EICRetLoja("SW8","W8_FABLOJ"),"FA"})
		                  ENDIF
		                  nQuantIt  := SW8->W8_QTDE
		                  cCodItem  := SW8->W8_COD_I
		                  cValor_Uni:= SW8->W8_PRECO
		                  cValor_Uni+= DI500RetVal("ITEM_INV,SEM_FOB", "TAB",.T.) / SW8->W8_QTDE  // EOB - 14/07/08 - Chamada da função DI500RetVal
		                  cFabigFor:= IF(SW8->W8_FABR==SW8->W8_FORN .And. IIF(EICLoja(),SW8->W8_FABLOJ==SW8->W8_FORLOJ,.T.),"1","2")
		                  cClassificacao:= PesquisaClassificacao(AvKey(SW8->W8_CC,"W3_CC"),SW8->W8_SI_NUM,SW8->W8_COD_I,SW8->W8_PO_NUM,SW8->W8_REG)  // TRP - 15/04/2013

		                  if empty(cConsigna)
		                     cConsigna := IF(EMPTY(SW2->W2_CONSIG),"T","F")
		                  endif
		                  Processa_Itens()
		                  SW8->(DBSKIP())
		               ENDDO
		               SW9->(DBSKIP())
		            ENDDO
		         ELSE
		            SW7->(DBSETORDER(1))
		            SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
		            bProcesso:={ ||SW6->W6_HAWB  }
		            bProduto :={ ||SW7->W7_COD_I }
		            bQtde    :={ ||SW7->W7_QTDE  }
		            bFor     :={ ||SW7->W7_FORN+IIF(EICLoja(),SW7->W7_FORLOJ,"")  }
		            bFabr    :={ ||SW7->W7_FABR+IIF(EICLoja(),SW7->W7_FABLOJ,"")  }
		            bIncoterm:={ ||BuscaIncoterm(.T.) }
		            bRegist  :={ ||SWP->WP_REGIST }
		            bPo_Num  :={ ||SW7->W7_PO_NUM }
		            bPosicao :={ ||SW7->W7_POSICAO }
                    SYQ->(DBSEEK(xFilial()+SW6->W6_VIA_TRA))
		            SYT->(DBSEEK(xFilial()+SW6->W6_IMPORT))
                    SYR->(DBSEEK(xFilial()+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST))
		            cPaisProc:=SW6->W6_PAISPRO
		            DO WHILE ! SW7->(EOF()) .AND. SW7->W7_HAWB == SW6->W6_HAWB
		               SW2->(DBSEEK(xFilial("SW2")+ SW7->W7_PO_NUM))
		               SW4->(DBSEEK(xFilial("SW4") + SW7->W7_PGI_NUM))
		               SW3->(DBSEEK(xFilial("SW3")+SW7->W7_PO_NUM+SW7->W7_POSICAO))
		               SAH->(DBSEEK(xFilial()+BUSCA_UM(SW7->W7_COD_I+SW7->W7_FABR +SW7->W7_FORN,SW7->W7_CC+SW7->W7_SI_NUM,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ"))))
		               SB1->(DBSEEK(xFilial("SB1") + SW7->W7_COD_I ))
		               //SA5->(DBSEEK(xFilial("SA5") + SW7->W7_COD_I + SW7->W7_FABR + SW7->W7_FORN ))
		               EICSFabFor(xFilial("SA5")+ SW7->W7_COD_I + SW7->W7_FABR+ SW7->W7_FORN,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ"))
		               SYD->(DBSEEK(xFilial("SYD")+Busca_NCM("SW7")))
		               SWP->(DBSEEK(xFilial("SWP")+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
                       SYF->(DBSEEK(xFilial()+SW2->W2_MOEDA))

		               IF !EMPTY(SW4->W4_COND_PA)
		                  SY6->(DBSEEK(xFilial()+SW4->W4_COND_PA+STR(SW4->W4_DIAS_PA, TY6DIASPA))) //TY6DIASPA tamanho
		               ELSE
		                  IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
		                     SY6->(DBSEEK(xFilial()+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
		                  ELSE
		                     SY6->(DBSEEK(xFilial()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
		                  ENDIF
		               ENDIF

		               IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
		                  cFor:=SW2->W2_EXPORTA
		                  nValParid:=SW2->W2_PARID_US
		                  IF EICLoja()
		                     cForLoj := SW2->W2_EXPLOJ
		                  EndIf
		               ELSE
		                  cFor:=SW7->W7_FORN
		                  nValParid:=1
		                  IF EICLoja()
		                     cForLoj := SW7->W7_FORLOJ
		                  EndIf
		               ENDIF
		               IF ASCAN(aFabr,{|x| x[1] = cFor+cForLoj}) = 0
		                  AADD(aFabr,{cFor+cForLoj,"FO"})
		               ENDIF
		               IF ASCAN(aFabr,{|x| x[1] = SW7->W7_FABR+EICRetLoja("SW7","W7_FABLOJ")}) = 0
		                  AADD(aFabr,{SW7->W7_FABR+EICRetLoja("SW7","W7_FABLOJ"),"FA"})
		               ENDIF
		               nQuantIt := SW7->W7_QTDE
		               cCodItem := SW7->W7_COD_I
		               cValor_Uni:= SW7->W7_PRECO
		               cFabigFor:= IF(SW7->W7_FABR==SW7->W7_FORN .And. IIF(EICLoja(),SW7->W7_FABLOJ==SW7->W7_FORLOJ,.T.),"1","2")
		               cClassificacao:= PesquisaClassificacao(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_PO_NUM,SW7->W7_REG)
		               if empty(cConsigna)
		                  cConsigna := IF(EMPTY(SW2->W2_CONSIG),"T","F")
		               endif
		               Processa_Itens()
		               SW7->(DBSKIP())
		            ENDDO
		         ENDIF
		    OTHERWISE

		      SW3->(DBSETORDER(1))
    		  SW2->(DBSEEK(xFilial("SW2")+TRB->W2_PO_NUM))
		      SW3->(DBSEEK(xFilial("SW3")+SW2->W2_PO_NUM))
		      bProcesso:={ ||SW2->W2_PO_NUM  }
		      bProduto :={ ||SW3->W3_COD_I   }
		      bQtde    :={ ||SW3->W3_QTDE    }
		      IF !FindFunction("B1PESO")// AWR - 03/02/2003
		         bPeso :={ || SB1->B1_PESO  }
		      ELSE
		         bPeso :={ || B1PESO(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ")) }
		      ENDIF
		      bFor     :={ ||SW3->W3_FORN+IIF(EICLoja(),SW3->W3_FORLOJ,"")    }
		      bFabr    :={ ||SW3->W3_FABR+IIF(EICLoja(),SW3->W3_FABLOJ,"")    }
		      bIncoterm:={ ||SW2->W2_INCOTER }
		      bRegist  :={ ||SPACE(1)        }
		      bPo_Num  :={ ||SW3->W3_PO_NUM  }
		      bPosicao :={ ||SW3->W3_POSICAO }

              IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ALTERAL_BLOCK_PESO"),) //RJB 22/05/2004

		      SYT->(DBSEEK(xFilial()+SW2->W2_IMPORT))
		      SYQ->(DBSEEK(xFilial()+SW2->W2_TIPO_EMB))
              SYF->(DBSEEK(xFilial()+SW2->W2_MOEDA))

		      DO WHILE ! SW3->(EOF()) .AND. Xfilial("SW3") == SW3->W3_FILIAL .AND. SW3->W3_PO_NUM == SW2->W2_PO_NUM
		         IF SW3->(W3_SEQ) # 0
    		         SW3->(DBSKIP())
    		         loop
		         EndIf
   		         SAH->(DBSEEK(xFilial()+BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))))
	             SB1->(DBSEEK(xFilial("SB1") + SW3->W3_COD_I ))
		         //SA5->(DBSEEK(xFilial("SA5") + SW3->W3_COD_I + SW3->W3_FABR+ SW3->W3_FORN ))
		         EICSFabFor(xFilial("SA5")+ SW3->W3_COD_I + SW3->W3_FABR+ SW3->W3_FORN,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ"))
   		         SYD->(DBSEEK(xFilial("SYD")+Busca_NCM("SW3")))
		         SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EMB+SW2->W2_ORIGEM+SW2->W2_DEST))

		         IF !EMPTY(SW2->W2_EXPORTA) .And. !EICEmptyLJ("SW2", "W2_EXPLOJ")
		            cFor:=SW2->W2_EXPORTA
		            nValParid:=SW2->W2_PARID_US
		            IF EICLoja()
		               cForLoj := SW2->W2_EXPLOJ
		            EndIf
		            SY6->(DBSEEK(xFilial()+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
		         ELSE
		            cFor:=SW2->W2_FORN
		            nValParid:=1
		            IF EICLoja()
		               cForLoj := SW2->W2_FORLOJ
		            EndIf
		            SY6->(DBSEEK(xFilial()+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA, TY6DIASPA))) && BYSOFT; TY6DIASPA tamanho
		         ENDIF
		         IF ASCAN(aFabr,{|x| x[1] = cFor+cForLoj}) = 0
		            AADD(aFabr,{cFor+cForLoj,"FO"})
		         ENDIF
		         IF ASCAN(aFabr,{|x| x[1] = SW3->W3_FABR+IIF(EICLoja(),SW3->W3_FABLOJ,"")}) = 0
		            AADD(aFabr,{SW3->W3_FABR+IIF(EICLoja(),SW3->W3_FABLOJ,""),"FA"})
		         ENDIF
		         nQuantIt := SW3->W3_QTDE
		         cCodItem := SW3->W3_COD_I
		         //nrateio:= (SW3->W3_QTDE * SW3->W3_PRECO) / SW2->W2_FOB_TOT
                 // PLB 09/05/07 - Define a porcentagem que o valor unitário do item representa em relacao ao FOB Total
		         nRateio:= SW3->W3_PRECO / SW2->W2_FOB_TOT
		         cValor_Uni:= SW3->W3_PRECO
		         cValor_Uni+= (SW2->W2_INLAND+SW2->W2_OUT_DES+SW2->W2_PACKING+SW2->W2_FRETEIN-SW2->W2_DESCONT ) * nrateio
		         cFabigFor:= IF(SW3->W3_FABR==SW3->W3_FORN .And. IIF(EICLoja(),SW3->W3_FABLOJ == SW3->W3_FORLOJ,.T.),"1","2")
		         cClassificacao:= PesquisaClassificacao(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_PO_NUM,SW3->W3_REG)
		         if empty(cConsigna)
		            cConsigna := IF(EMPTY(SW2->W2_CONSIG),"T","F")
		         endif
		         cPaisProc:=SYR->YR_PAIS_OR
		         Processa_Itens()
		         SW3->(DBSKIP())
		      ENDDO
		 ENDCASE

                 IF cFase=FASE_DI
                    SYQ->(DBSEEK(xFilial()+SW6->W6_VIA_TRA))
                 ELSE
                    SYQ->(DBSEEK(xFilial()+SW2->W2_TIPO_EM))
                 ENDIF

		 SY5->(DBSEEK(xFilial()+cCodigo))
		 IF PPrimeiro
		      PPrimeiro := .F.
		      cTexto := SPACE(nTamReg+(nColExtra*2))
		      cTexto := STUFF(cTexto,001,004,"ITDI")
		      cTexto := STUFF(cTexto,005,006,ORI100Data(cData))
		      cTexto := STUFF(cTexto,011,006,SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2))
		      cTexto := STUFF(cTexto,017,014,SYT->YT_CGC)
		      cTexto := STUFF(cTexto,031,020,cUserName)
		      cTexto := STUFF(cTexto,051,020,SUBSTR(SY5->Y5_NOME,1,40))
		      IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"ITDI"),)
		      IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ITDI"),)
		      AADD(aGrv_GIP,cTexto)
		 ENDIF
		 cTexto := SPACE(nTamReg+(nColExtra*2))
		 cTexto := STUFF(cTexto,001,004,"CAPI")
		 cTexto := STUFF(cTexto,005,015,SUBS(eval(bProcesso),1,15))
         IF(ExistBlock("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ALTERA_PROCESSO"),) //LRS - 05/03/2018
         IF(Empty(bProcPE),bProcPE := bProcesso,) //LRS - 05/03/2018
		 cTexto := STUFF(cTexto,020,020,eval(bProcPE))
//		 cTexto := STUFF(cTexto,040,006,ORI100Data(IF(cFase=FASE_DI,SW6->W6_DT_EMB,SW2->W2_PO_DT)))
		 cTexto := STUFF(cTexto,040+(nColExtra*2),006,IF(cFase=FASE_DI,ORI100Data(SW6->W6_DT_HAWB),ORI100Data(SW2->W2_PO_DT))) // RS - 15/08/07
		 cTexto := STUFF(cTexto,046,002,IF(cFase=FASE_DI,PADL(ALLTRIM(SW6->W6_TIPODESP),2,"0"),SPACE(2)))
		 cTexto := STUFF(cTexto,048,001,cConsigna)
         cTexto := STUFF(cTexto,049,004,If(Empty(LEFT(ORIBusGip(cCodigo,"1",SYT->YT_COD_IMP),4)),SYT->YT_COD_IMP,LEFT(ORIBusGip(cCodigo,"1",SYT->YT_COD_IMP),4)))
		 cTexto := STUFF(cTexto,053,004,IF(!EMPTY(cConsigna),LEFT(ORIBusGip(cCodigo,"1",cConsigna),4),SPACE(4)))
		 cTexto := STUFF(cTexto,057,001,"F")
		 cTexto := STUFF(cTexto,058,001,"F")
		 cTexto := STUFF(cTexto,070+(nColExtra*2),007,IF(cFase=FASE_DI,SW6->W6_URF_DES,SPACE(7)))
		 cTexto := STUFF(cTexto,077+(nColExtra*2),003,SPACE(3))
		 cTexto := STUFF(cTexto,081+(nColExtra*2),001,SPACE(1))
		 cTexto := STUFF(cTexto,082+(nColExtra*2),002,SPACE(2))
		 cTexto := STUFF(cTexto,085+(nColExtra*2),001,SPACE(1))
		 cTexto := STUFF(cTexto,086+(nColExtra*2),001,IF(cFase=FASE_DI,SW6->W6_MODAL_D,SPACE(1)))
		 cTexto := STUFF(cTexto,087+(nColExtra*2),001,"1")
		 cTexto := STUFF(cTexto,088+(nColExtra*2),001,"1")
		 cTexto := STUFF(cTexto,089+(nColExtra*2),002,LEFT(SYQ->YQ_COD_DI,1))
		 cTexto := STUFF(cTexto,091+(nColExtra*2),001,IF(AT(SYQ->YQ_DESCR,"SEA")#0 .AND. AT(SYQ->YQ_DESCR,"AIR")#0,"T","F"))
         cTexto := STUFF(cTexto,092+(nColExtra*2),004,If(Empty(LEFT(ORIBusGip(cCodigo,"3",IF(cFase=FASE_DI,SW6->W6_AGENTE,IF(!EMPTY(SW2->W2_FORWARD),SW2->W2_FORWARD,SW2->W2_AGENTE))),4)),IF(cFase=FASE_DI,SW6->W6_AGENTE,IF(!EMPTY(SW2->W2_FORWARD),SW2->W2_FORWARD,SW2->W2_AGENTE)),LEFT(ORIBusGip(cCodigo,"3",IF(cFase=FASE_DI,SW6->W6_AGENTE,IF(!EMPTY(SW2->W2_FORWARD),SW2->W2_FORWARD,SW2->W2_AGENTE))),4))) && BYSOFT
		 cTexto := STUFF(cTexto,111+(nColExtra*2),030,IF(cFase=FASE_DI,SW6->W6_IDENTVE,SPACE(30)))
		 cTexto := STUFF(cTexto,141+(nColExtra*2),003,IF(cFase=FASE_DI .AND. !EMPTY(SW6->W6_PAISVEI),PADL(ALLTRIM(SW6->W6_PAISVEI),3,"0"),SPACE(3)))
		 cTexto := STUFF(cTexto,144+(nColExtra*2),001,IF(cFase=FASE_DI,SW6->W6_TIPODOC,SPACE(1)))
		 cTexto := STUFF(cTexto,145+(nColExtra*2),015,IF(cFase=FASE_DI,SW6->W6_IDEMANI,SPACE(15)))
		 cTexto := STUFF(cTexto,160+(nColExtra*2),002,IF(cFase=FASE_DI,SW6->W6_TIPOCON,SPACE(2)))
		 cTexto := STUFF(cTexto,162+(nColExtra*2),011,IF(cFase=FASE_DI,SW6->W6_MAWB,SPACE(11)))
		 cTexto := STUFF(cTexto,173+(nColExtra*2),011,IF(cFase=FASE_DI,SUBSTR(SW6->W6_HOUSE,1,11),SPACE(11)))  // estava hawb - na documentacao e nro conhecimto
//		 cTexto := STUFF(cTexto,184+(nColExtra*2),006,IF(cFase=FASE_DI,ORI100Data(SW6->W6_DT_HAWB),SPACE(6)))
		 cTexto := STUFF(cTexto,184,006,ORI100Data(IF(cFase=FASE_DI,SW6->W6_DT_EMB,SW2->W2_PO_DT)))
		 cTexto := STUFF(cTexto,190+(nColExtra*2),010,IF(cFase=FASE_DI .AND. !EMPTY(SW6->W6_ORIGEM),SW6->W6_ORIGEM,SW2->W2_ORIGEM))
		 cTexto := STUFF(cTexto,200+(nColExtra*2),001,IF(cFase=FASE_DI,SW6->W6_UTILCON,SPACE(1)))
		 cTexto := STUFF(cTexto,201+(nColExtra*2),006,IF(cFase=FASE_DI,ORI100Data(SW6->W6_CHEG),SPACE(6)))
		 cTexto := STUFF(cTexto,222+(nColExtra*2),015,ORI100Numero(IF(cFase=FASE_DI,SW6->W6_PESO_BR,SW2->W2_PESO_B),10,04,.T.))
		 cTexto := STUFF(cTexto,237+(nColExtra*2),003,PADL(ALLTRIM(cPaisProc),3,"0"))
		 cTexto := STUFF(cTexto,241+(nColExtra*2),018,IF(cFase=FASE_DI,SW6->W6_HOUSE,SPACE(18)))  // SVG - 12/01/2011 - Inserção dos campos HOUSE e MASTER na CAPID
		 cTexto := STUFF(cTexto,259+(nColExtra*2),018,IF(cFase=FASE_DI,SW6->W6_MAWB,SPACE(18)))   // SVG - 12/01/2011 - Inserção dos campos HOUSE e MASTER na CAPID
		 IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"CAPI"),)
		 IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"CAPI"),)
		 AADD(aGrv_Gip,cTexto)


		 SYF->(DBSEEK(xFilial()+SW2->W2_MOEDA))
		 IF(cFase=2,SYF->(DBSEEK(xFilial()+SW6->W6_FREMOED)),)
		 cTexto := SPACE(nTamReg+(nColExtra*2))
		 cTexto := STUFF(cTexto,001,004,"CAP2")
		 cTexto := STUFF(cTexto,005,015,IF(cFase=FASE_DI,SUBSTR(SW6->W6_HAWB,1,15),SW2->W2_PO_NUM))
		 cTexto := STUFF(cTexto,020,004,If(Empty(LEFT(ORIBusGip(cCodigo,"3",IF(cFase=FASE_DI,SW6->W6_AGENTE,SW2->W2_AGENTE)),4)),IF(cFase=FASE_DI,SW6->W6_AGENTE,SW2->W2_AGENTE),LEFT(ORIBusGip(cCodigo,"3",IF(cFase=FASE_DI,SW6->W6_AGENTE,SW2->W2_AGENTE)),4))) && BYSOFT
		 cTexto := STUFF(cTexto,024,007,IF(cFase=FASE_DI,SW6->W6_URF_ENT,SPACE(7)))
		 cTexto := STUFF(cTexto,031,007,IF(cFase=FASE_DI,SW6->W6_REC_ALF,SPACE(7)))
		 cTexto := STUFF(cTexto,038,003,STRZERO(MSeq,3))
		 cTexto := STUFF(cTexto,041,007,ORI100Numero(0,02,04,.T.))
		 cTexto := STUFF(cTexto,048,007,ORI100Numero(0,02,04,.T.))
		 //** Nopado por GFP - 05/11/2013
		 //** Para qualquer alteração deste bloco, favor avaliar com o coordenador, em conformidade com o documento de layout aprovado.
		 //cTexto := STUFF(cTexto,055,003,SYF->YF_COD_GI) //SW2->W2_MOEDA+If(Len(AllTrim(SW2->W2_MOEDA)) == 2,SPACE(1),""))   //SPACE(3))  // GFP - 26/06/2013
		 //cTexto := STUFF(cTexto,058,003,ORI100Numero(IF(cFase=FASE_DI,SW6->W6_FOB_TOT,SW2->W2_FOB_TOT),12,04,.T./*FSY - 30/07/2013*/))     // GFP - 26/06/2013
		 cTexto := STUFF(cTexto,073,003,SYF->YF_COD_GI)
		 cTexto := STUFF(cTexto,076,015,ORI100Numero(IF(cFase=2,SW6->W6_VLFREPP,0),12,02,.T.))
		 cTexto := STUFF(cTexto,091,015,ORI100Numero(IF(cFase=2,SW6->W6_VLFRECC,0),12,02,.T.))
		 cTexto := STUFF(cTexto,106,015,ORI100Numero(IF(cFase=2,SW6->W6_VLFRETN,0),12,02,.T.))
		 IF(cFase=FASE_DI,SYF->(DBSEEK(xFilial()+SW6->W6_SEGMOED)),)
		 cTexto := STUFF(cTexto,121,003,IF(cFase=2,SYF->YF_COD_GI,SPACE(3)))
		 cTexto := STUFF(cTexto,124,001,IF(cFase=2,"V"," "))
		 cTexto := STUFF(cTexto,125,007,ORI100Numero(0,02,04,.T.))
		 cTexto := STUFF(cTexto,132,015,ORI100Numero(IF(cFase=2,SW6->W6_VL_USSEG,0),12,02,.T.))
		 cTexto := STUFF(cTexto,165,003,SPACE(3))
		 cTexto := STUFF(cTexto,168,010,SPACE(10))
         /*cTexto := STUFF(cTexto,178,001,SPACE(1))*/
         cTexto := STUFF(cTexto,178,001,SY6->Y6_TIPOCOB) // SVG - 25/06/09 - Alteração de Layout Tipo de Cobertura deverá ir na Capa
		 cTexto := STUFF(cTexto,183,006,ORI100Numero(0,02,03,.T.))
		 cTexto := STUFF(cTexto,189,002,SPACE(2))
		 cTexto := STUFF(cTexto,191,001,"F")
		 cTexto := STUFF(cTexto,192,004,SPACE(4))
		 cTexto := STUFF(cTexto,196,015,ORI100Numero(0,08,06,.T.))
		 cTexto := STUFF(cTexto,211,003,SPACE(3))
		 cTexto := STUFF(cTexto,214,003,SPACE(3))
		 cTexto := STUFF(cTexto,217,015,ORI100Numero(0,12,02,.T.))
		 cTexto := STUFF(cTexto,232,002,SPACE(2))

		 If lDI_Cambio
		    bWhileSWB:={|| SWB->WB_FILIAL==xFilial("SWB") .And. SWB->WB_HAWB==SW6->W6_HAWB }
		    If lCposAdto
		       bWhileSWB:={|| SWB->WB_FILIAL==xFilial("SWB") .And. SWB->WB_HAWB==SW6->W6_HAWB .And. ;
		                      SWB->WB_PO_DI=="D"}
		    Endif

		    SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB+If(lCposAdto,"D","")))
		    While !(SWB->(Eof())) .And. Eval(bWhileSWB)
		       If Left(SWB->WB_TIPOREG,1) == "1"
		          Exit
		       EndIf
		       SWB->(dbSkip())
		    EndDo
      //** GFC - 02/12/05 - Utilizar o Valor da parcela de comissão ao invés do campo WB_COMAG
      If lWB_TP_CON
         nComag := OR100Comag()
      Else
         nComag := SWB->WB_COMAG
      EndIf
      //**
      cTexto := STUFF(cTexto,183,006,ORI100Numero(nComag,02,03,.T.))
   EndIf

   IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"CAP2"),)//LCB 11.07.2000
   IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"CAP2"),)
   AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA

		 cTexto := SPACE(nTamReg+(nColExtra*2))
		 cTexto := STUFF(cTexto,001,004,"CAP3")
		 cTexto := STUFF(cTexto,005,015,eval(bProcesso))
		 cTexto := STUFF(cTexto,020,020,ORI100Numero(0,17,02,.T.))
		 cTexto := STUFF(cTexto,040,008,SPACE(8))
		 cTexto := STUFF(cTexto,048,002,SPACE(2))
		 cTexto := STUFF(cTexto,050,015,ORI100Numero(0,12,02,.T.))
		 cTexto := STUFF(cTexto,065,015,ORI100Numero(0,12,02,.T.))
		 cTexto := STUFF(cTexto,080,001,SPACE(1))
		 cTexto := STUFF(cTexto,081,011,SPACE(11))
		 cTexto := STUFF(cTexto,092,011,SPACE(11))
		 cTexto := STUFF(cTexto,103,003,SPACE(3))

		 If lDI_Cambio
      // Já estou posicionado na parcela principal
 		   cTexto := STUFF(cTexto,020,020,ORI100Numero(SW6->W6_VLMLEMN,17,02,.T.)) //G.C-Retirados os campos de seguro,fretes e outras despesas pois não são necessários
	 	   cTexto := STUFF(cTexto,040,008,SWB->WB_NR_ROF)
		 EndIf
		 nFob:=0
		 // Permite a altera‡Æo do Lay-Out
		 IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"CAP3"),)//LCB 11.07.2000
		 IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"CAP3"),)
		 AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA
		 // Permite a altera‡Æo do Lay-Out (InclusÆo de linha na capa)
		 IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"CAPZ"),)//LCB 11.07.2000
		 IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"CAPZ"),)

		 FOR Indf=1 TO LEN(aFabr)
		     SA2->(DBSEEK(xFilial()+aFabr[Indf,1]))
		     cTexto := SPACE(nTamReg+(nColExtra*2))
		     cTexto := STUFF(cTexto,001,004,"AG4A")
		     cTexto := STUFF(cTexto,005,060,SA2->A2_NOME)
		     cTexto := STUFF(cTexto,065,080,SA2->A2_END)
		     cTexto := STUFF(cTexto,145,070,SPACE(70))
		     cTexto := STUFF(cTexto,215,006,PADL(SA2->A2_NR_END,6,"0"))
		     cTexto := STUFF(cTexto,221,003,PADL(ALLTRIM(SA2->A2_PAIS),3,"0"))
		     // TDF - 28/07/10
             //cTexto := STUFF(cTexto,224,003+nColExtra,LEFT(ORIBusGip(cCodigo,IF(aFabr[Indf,2]="FO" .and. lDePara2,"4","2"),SA2->A2_COD),4+nColExtra))             
			 //TRP - 21/09/2012 - Acerto para considerar a Loja.
		     cTexto := STUFF(cTexto,224,003+nColExtra,LEFT(ORIBusGip(cCodigo,IF(aFabr[Indf,2]="FO" .and. lDePara2,"4","2"),SA2->A2_COD+IIF(EICLoja(),SA2->A2_LOJA,"")),4+nColExtra))
		     //cTexto := STUFF(cTexto,224,003+nColExtra,LEFT(ORIBusGip(cCodigo,IF(aFabr[Indf,2]="FO","4","2"),SA2->A2_COD),4+nColExtra))
		     IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"AG4A"),)
		     AADD(aGrv_Gip,cTexto)
		     cTexto := SPACE(nTamReg+(nColExtra*2))
		     cTexto := STUFF(cTexto,001,004,"AG4B")
		     cTexto := STUFF(cTexto,005,025,SA2->A2_NREDUZ)
		     cTexto := STUFF(cTexto,030,025,SA2->A2_ESTADO)
		     cTexto := STUFF(cTexto,055,020,SA2->A2_FAX)
		     cTexto := STUFF(cTexto,075,001,"P")
		     cTexto := STUFF(cTexto,076,040,SA2->A2_CONTATO)
		     IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"AG4B"),)
		     AADD(aGrv_Gip,cTexto)
		 NEXT

		 FOR wind:=1 to LEN(aGrv_Gip)
		    IF SUBS(aGrv_Gip[wind],1,4)=="ITDI"
		       Gera_GipLite(aGrv_Gip[wind])
		    ENDIF
		 NEXT
		 FOR wind:=1 to LEN(aGrv_Gip)
		    IF SUBS(aGrv_Gip[wind],1,4)=="CAPI"
		       Gera_GipLite(aGrv_Gip[wind])
		    ENDIF
		 NEXT
		 FOR wind:=1 to LEN(aGrv_Gip)
		    IF SUBS(aGrv_Gip[wind],1,4)=="CAP2"
		       Gera_GipLite(aGrv_Gip[wind])
		    ENDIF
		 NEXT
		 FOR wind=1 to LEN(aGrv_Gip)
		    IF SUBS(aGrv_Gip[wind],1,4)=="CAP3"
		       Gera_GipLite(aGrv_Gip[wind])
		    ENDIF
		 NEXT

		 FOR wind=1 to LEN(aGrv_Gip)
		     IF SUBS(aGrv_Gip[wind],1,4)=="CAP2" .OR. SUBS(aGrv_Gip[wind],1,4)=="CAPI".OR. ;
		        SUBS(aGrv_Gip[wind],1,4)=="ITDI" .OR. SUBS(aGrv_Gip[wind],1,4)=="CAP3"
		     ELSE
		        Gera_GipLite(aGrv_Gip[wind])
		     ENDIF
		 NEXT
ENDIF
DBSELECTAREA("TRB")
Return .T.

*---------------------------------*
STATIC FUNCTION Gera_GipLite(texto)
*---------------------------------*
Gip_Lite->(DBAPPEND())
Gip_Lite->GIPTEXTO := texto
return

*---------------------------------------*
STATIC FUNCTION Processa_Itens()
*---------------------------------------*
Local Wind,x, cDescItem:=""
Local lPartNum := EasyGParam("MV_EICPNUM",,.F.) // AST - 28/11/2008 - Indica se na descrição do item irá contar o nº do Part Number
//LOCAL lDePara2 := EasyGParam("MV_DEPARA2",,.F.)
Local nInc
Local cLoja := ""  // GFP - 03/04/2013
Local cTabNVE := ""


IF EasyGParam("MV_LAYDESP",,.F.)
   nInc:= 10
Else
   nInc:= 0
Endif

IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ANTES_ITEA"),)
cTexto := SPACE(nTamReg+(nColExtra*2))
cTexto := STUFF(cTexto,001,004,"ITEA")
cTexto := STUFF(cTexto,005,015,eval(bProcesso))
//IF (SX6->(DBSEEK("  MV_ITEDESP")).OR.SX6->(DBSEEK(SM0->M0_CODFIL+"MV_ITEDESP"))).AND.EasyGParam("MV_ITEDESP")
//TDF - 01/02/2012
IF EasyGParam("MV_ITEDESP",.F.).AND.EasyGParam("MV_ITEDESP",,.F.)
 cTexto := STUFF(cTexto,020,020+nInc,SUBSTR(eval(bProduto),1,20+nInc))
ELSE
 cTexto := STUFF(cTexto,020,020+nInc,space(20)+space(nInc))
ENDIF

cTexto := STUFF(cTexto,040+nInc,015,ORI100Numero(eval(bQtde),09,05,.T.))
cTexto := STUFF(cTexto,055+nInc,002,SAH->AH_COD_SIS)
nPesoItem:= eval(bPeso)
IF(lHunter,ExecBlock("IC010DI1",.F.,.F.,"12"),)//AWR 11/11/1999
IF(EasyEntryPoint("ICPADSUF"),ExecBlock("ICPADSUF",.F.,.F.,"PESOIT_W3"),)
nPeso_L := eval(bQtde) * nPesoItem
nSomaPesoL += nPeso_L
If Len(Alltrim(Str(Int(nPeso_L)))) <= 5 //ASK 04/03/2008 PARA NAO ESTOURAR O CAMPO DE PESO.
   cTexto := STUFF(cTexto,057+nInc,012,ORI100Numero(nPeso_L,05,06,.T.))
Else
   cTexto := STUFF(cTexto,057+nInc,012,ORI100Numero(nPeso_L,09,02,.T.))
EndIf
nFob:=0
IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"VAL_FOB"),)
IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ITEA_VALORES"),)//AWR 27/02/02
IF LEN(ALLTRIM(STR(INT(cValor_Uni)))) <= 5 //PARA NAO ESTOURAR O CAMPO   // JBS 29/12/04, RJB 16/07/2004
   cTexto := STUFF(cTexto,069+nInc,012,ORI100Numero(cValor_Uni,05,06,.T.))  // JBS 29/12/04, RJB 16/07/2004 //ACD.
ELSE
   cTexto := STUFF(cTexto,069+nInc,012,ORI100Numero(cValor_Uni,09,02,.T.))  // JBS 29/12/04, RJB 16/07/2004
ENDIF
cTexto := STUFF(cTexto,081+nInc,001,"1")
cTexto := STUFF(cTexto,082+nInc,005,ORI100Numero(0,02,02,.T.))
cTexto := STUFF(cTexto,087+nInc,010,ORI100Numero(0,07,02,.T.))
cTexto := STUFF(cTexto,097+nInc,002,SPACE(2))
cTexto := STUFF(cTexto,099+nInc,001,cFabigFor)
cTexto := STUFF(cTexto,100+nInc,004+nColExtra,LEFT(ORIBusGip(cCodigo,IF(lDePara2,"4","2"),EVAL(bfor),cFase,"E"),4+nColExtra)) && BYSOFT //EXPORTADOR
cTexto := STUFF(cTexto,104+nInc+nColExtra,004+nColExtra,LEFT(ORIBusGip(cCodigo,"2",EVAL(bfabr),cFase,"F"),4+nColExtra)) && BYSOFT //FABRICANTE MCF-19/08/2014
SA2->(DBSEEK(xFilial()+EVAL(bfabr)))
cTexto := STUFF(cTexto,108+nInc+(nColExtra*2),003,PADL(ALLTRIM(SA2->A2_PAIS),3,"0")) //PAS DE ORIGEM
SA2->(DBSEEK(xFilial()+EVAL(bfor)))
cTexto := STUFF(cTexto,111+nInc+(nColExtra*2),003,PADL(ALLTRIM(SA2->A2_PAIS),3,"0"))
cTexto := STUFF(cTexto,114+nInc+(nColExtra*2),010,SYD->YD_TEC)

cTexto := STUFF(cTexto,124+nInc+(nColExtra*2),003,SYD->YD_EX_NCM)

cTexto := STUFF(cTexto,127+nInc+(nColExtra*2),009,SPACE(9))
cTexto := STUFF(cTexto,136+nInc+(nColExtra*2),009,SPACE(9))
cTexto := STUFF(cTexto,145+nInc+(nColExtra*2),004,SPACE(4))
cTexto := STUFF(cTexto,149+nInc+(nColExtra*2),006,SPACE(6))

cTexto := STUFF(cTexto,165+nInc+(nColExtra*2),003,SYD->YD_EX_NBM)

cTexto := STUFF(cTexto,168+nInc+(nColExtra*2),009,SPACE(9))
cTexto := STUFF(cTexto,177+nInc+(nColExtra*2),009,SPACE(9))
cTexto := STUFF(cTexto,186+nInc+(nColExtra*2),004,SPACE(4))
cTexto := STUFF(cTexto,190+nInc+(nColExtra*2),006,SPACE(6))
cTexto := STUFF(cTexto,196+nInc+(nColExtra*2),010,SYD->YD_NAL_SH)
cTexto := STUFF(cTexto,206+nInc+(nColExtra*2),003,SPACE(3))
cTexto := STUFF(cTexto,209+nInc+(nColExtra*2),009,SPACE(9))
cTexto := STUFF(cTexto,218+nInc+(nColExtra*2),009,SPACE(9))
cTexto := STUFF(cTexto,227+nInc+(nColExtra*2),004,SPACE(4))
cTexto := STUFF(cTexto,231+nInc+(nColExtra*2),006,SPACE(6))
cTexto := STUFF(cTexto,237+nInc+(nColExtra*2),004,PADL(++MSeq,4,"0"))
IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"ITEA"),)
IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ITEA"),)
AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA

cTexto := SPACE(nTamReg+(nColExtra*2))
cTexto := STUFF(cTexto,001,004,"ITEB")
cTexto := STUFF(cTexto,005,015,eval(bProcesso))
cTexto := STUFF(cTexto,020,010,SYD->YD_NALADI)
cTexto := STUFF(cTexto,030,003,SPACE(3))
cTexto := STUFF(cTexto,069,001,IF(SW1->W1_CLASS="3","1",IF(SW1->W1_CLASS="5","2"," ")))
cTexto := STUFF(cTexto,070,006,ORI100Numero(0,03,02,.T.))
cTexto := STUFF(cTexto,076,006,ORI100Numero(0,03,02,.T.))
cTexto := STUFF(cTexto,082,003,SYF->YF_COD_GI)
cTexto := STUFF(cTexto,085,003,eval(bIncoterm))

cTexto := STUFF(cTexto,088,010,SPACE(10))
cTexto := STUFF(cTexto,102,003,PADL(SYD->YD_ALADI,3,"0"))
cTexto := STUFF(cTexto,105,009,SPACE(9))
cTexto := STUFF(cTexto,133,007,IF(SYD->YD_PER_II#0,ORI100Numero(SYD->YD_PER_II,03,03,.T.),SPAC(7)))
cTexto := STUFF(cTexto,161,012,ORI100Numero(0,12,00,.T.))
SAH->(DBSEEK(xFilial()+SYD->YD_UNID))
cTexto := STUFF(cTexto,173,002,SAH->AH_COD_SIS)
cTexto := STUFF(cTexto,175,003,"000")
cTexto := STUFF(cTexto,209,007,IF(SYD->YD_PER_IPI#0,ORI100Numero(SYD->YD_PER_IPI,03,03,.T.),SPAC(7)))
cTexto := STUFF(cTexto,230,010,eval(bRegist))
IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"ITEB"),)//LCB 11.07.2000
IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ITEB"),)

AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA

cTexto := SPACE(nTamReg+(nColExtra*2))
cTexto := STUFF(cTexto,001,004,"ITEC")
cTexto := STUFF(cTexto,005,015,eval(bProcesso))
cTexto := STUFF(cTexto,020,012,ORI100Numero(0,09,02,.T.))
cTexto := STUFF(cTexto,034,003,"000")

cTexto := STUFF(cTexto,112,001,SY6->Y6_TIPOCOB)
cTexto := STUFF(cTexto,117,006,ORI100Numero(0,02,03,.T.))
cTexto := STUFF(cTexto,123,002,IF(SY6->Y6_TIPOCOB = "1".OR.SY6->Y6_TIPOCOB = "2",PADL(SY6->Y6_TABELA,2,"0"),SPACE(2)))
cTexto := STUFF(cTexto,125,001,"F")
cTexto := STUFF(cTexto,130,010,ORI100Numero(0,03,06,.T.))
xConta := 0
IF SY6->Y6_DIAS_PA >= 900
   FOR Wind = 1 TO 10
       _Perc:= "Y6_PERC_" + STRZERO(Wind,2) ; _Perc:= SY6->(FIELDGET( FIELDPOS(_Perc) ))
       xConta+= IF(_Perc # 0,1,0)
   NEXT
ENDIF
cTexto := STUFF(cTexto,140,003,STRZERO(xConta,3))
cTexto := STUFF(cTexto,143,003,STRZERO(SY6->Y6_DIAS,3))
cTexto := STUFF(cTexto,146,013,ORI100Numero(0,10,02,.T.))
cTexto := STUFF(cTexto,159,002,IF(SY6->Y6_TIPOCOB = "3",SY6->Y6_INST_FI,SPACE(2)))
cTexto := STUFF(cTexto,161,012,ORI100Numero(0,09,02,.T.))
cTexto := STUFF(cTexto,181,002,IF(SY6->Y6_TIPOCOB = "4",PADL(SY6->Y6_MOTIVO,2,"0"),SPACE(2)))
cTexto := STUFF(cTexto,183,012,ORI100Numero(0,09,02,.T.))
cTexto := STUFF(cTexto,195,012,ORI100Numero(0,09,02,.T.))
cTexto := STUFF(cTexto,225,002,LEFT(SYQ->YQ_COD_DI,1))
cTexto := STUFF(cTexto,237,001,IF(AT(SYQ->YQ_DESCR,"SEA")#0 .AND. AT(SYQ->YQ_DESCR,"AIR")#0,"T","F"))
IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"ITEC"),)//LCB 11.07.2000
IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ITEC"),)
AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA

cTexto := SPACE(nTamReg+(nColExtra*2))
cTexto := STUFF(cTexto,001,004,"ITED")
cTexto := STUFF(cTexto,005,015,eval(bProcesso))
cTexto := STUFF(cTexto,020,019,ORI100Numero(nPeso_L,12,06,.T.))
cTexto := STUFF(cTexto,039,015,eval(bPo_NUm))
cTexto := STUFF(cTexto,054,004,PADL(eval(bPosicao),4,"0"))
cTexto := STUFF(cTexto,058,010,if(cFase==2,SW7->W7_PGI_NUM,SPACE(10)))
cTexto := STUFF(cTexto,241,015,if(cFase==2 .AND. lInv ,eval(bInvoice),SPACE(15)))// SVG - 03/09/2010 -
cTabNVE:= OR100TBNVE(cFase)   //NCF - 23/05/2018
cTexto := STUFF(cTexto,256,3,cTabNVE)

IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ITED_FINAL"),)//AWR 27/02/02
AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA

IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"ITEZ"),)//LCB 11.07.2000
IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ITEZ"),)
nTamItem:=AVSX3("B1_VM_GI",03)//cDescricaoItem,nTamItem sao private por causa do rdmake

cLoja := If(EICLoja(), AvKey(SW3->W3_FABLOJ,"YG_FABLOJ"), "")   // GFP - 03/04/2013

//TRP-04/09/07- Complementação da descrição do item com o Numero da Autorização do Ministerio e Validade
SYG->(DBSEEK(xFilial("SYG")+AvKey(SW2->W2_IMPORT,"YG_IMPORTA")+AvKey(SW3->W3_FABR,"YG_FABRICA");
	+EICRetLoja("SW3", "W3_FABLOJ")+AvKey(SW3->W3_COD_I,"YG_ITEM")))  // GFP - 01/04/2013 //LRS - 30/09/2013- Retirado Alltrim, colocado a função EICRETLOJA

// AST - 28/11/08 - Inclusão do tratamento do parametro MV_EICPNUM (Part Number)
cDescricaoItem := iif(lPartNum .And. len(alltrim(SA5->A5_PARTOPC)) > 0,"P/N.: "+alltrim(SA5->A5_PARTOPC)+" - ","") +;
                  MSMM(SB1->B1_DESC_GI,nTamItem) + Chr(13)+Chr(10) +;
                  iif(SYG->(EoF()),"",LEFT(STR0214,3)+".: " + SYG->YG_REG_MIN +;
                  STR0208+": " + DtoC(SYG->YG_VALIDA) )

IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"DESC_LI_GIP"),)
FOR X:=1 TO MLCOUNT(cDescricaoItem,nTamItem)
    nContador := X
    cTexto := SPACE(nTamReg+(nColExtra*2))
    cTexto := STUFF(cTexto,001,004,"DP"+STRZERO(X,2))
    cTexto := STUFF(cTexto,005,015,SUBSTR(eval(bProcesso),1,15))
    cTexto := STUFF(cTexto,020,020,space(20))

    cDescItem:=MemoLine(cDescricaoItem,nTamItem,X)


    cTexto := STUFF(cTexto,040,201,cDescItem)
    IF lHunter
       cDescricao:=cTexto
       ExecBlock("IC010DI1",.F.,.F.,"13")//AWR 11/11/1999
       cTexto:=cDescricao
//     AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA
    ENDIF

    IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"DPNN"),)//LCB 11.07.2000
    IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"DPNN"),)
    AADD(aGrv_Gip,cTexto)  && GRAVACAO NA TABELA
    IF(lEicPOR01,ExecBlock(cRDPad01,.F.,.F.,"POS_GRV_DPNN"),)//AWR 16/12/2000 P/ Philco
NEXT

MConta++

RETURN NIL



*----------------------------*
STATIC FUNCTION ORI100Status()
*----------------------------*
RETU IF(TRB->WP_ERRO="1",'OK  ',IF(TRB->WP_ERRO='2',STR0047,'    ')) //'ERRO'

*-------------------------------------------*
//protheus STATIC FUNCTION Ori100Memo(Campo,TamOri,nTamanho)
FUNCTION Ori100Memo(Campo,nTamOri,nTamanho)
*-------------------------*
LOCAL cDescStr:=MSMM(Campo,nTamOri), nInd, cStr:="", cStrOri:=""
IF nTamOri # nTamanho
  FOR nInd:=1 TO MLCOUNT(cDescSTR,nTamOri)
    cStrOri+= alltrim(MEMOLINE (cDescStr,nTamOri,nInd))//+ chr(13)+chr(10)
  NEXT
else
  cStrOri:= cDescStr
endif
FOR nInd:=1 TO MLCOUNT(cSTROri,nTamanho)
   cStr+= alltrim(MEMOLINE (cStrOri,nTamanho,nInd))//+ chr(13)+chr(10)
NEXT

RETURN cStr


*-------------------------*
FUNCTION ORI100Fabricante()
*-------------------------*
RETU BuscaFabr_Forn(TRB->WP_FABR+EICRetLoja("TRB","WP_FABLOJ"))


*----------------------------------------------------------------------------*
STATIC FUNCTION Ori100GetData()
*----------------------------------------------------------------------------*


IF cTipo == 1//PROC_NAO_ENVIADO
   RETURN .T.
ENDIF

IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"ANTES_PERG_GETDATA"),)	//Johann - 15/07/2005

IF !Pergunte("EICORI",.T.)
   lSair:=.T.
   RETURN .F.
ENDIF

TDt_I:=mv_par02
TDt_F:=mv_par03
cCodigo:=ALLTRIM(mv_par01)
cData:=mv_par04

IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"FIM_GETDATA"),)	//Johann - 15/07/2005

Return .T.


*----------------------------------------------------------------------------*
Function EICMX100(Atu,cNomeMaquina)
*----------------------------------------------------------------------------*
Static cPathMdb
Static cPathDBF
LOCAL aClose:={},oDlg,nOpc:=0,cTitulo:=AVSX3("WP_NR_MAQ",05)
LOCAL cEasy , nFiles, aDir, cArqLeitura, cFile,cParametro:=" "
LOCAL lOpenError, nHandle:=0
LOCAL cDias    := EasyGParam("MV_SCXDIAS"  ,,"90")        //Numero de dias de retorno da L.I.
LOCAL cVersao  := EasyGParam("MV_SCXVERS",,IF(EMPTY(TCGetDB()),"CDX"," "))
LOCAL lErroCpy := .f.
LOCAL i
Local cArqRef := ""

Private aRefs  := {}
PRIVATE lAdsLocal:=GETNEWPAR("MV_ADSLOCA",.T.) // RJB 09/08/2005

IF(cNomeMaquina==NIL,cNomeMaquina:=SPACE(02),)

IF Atu == NIL     // Somente SISCCAD

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 91,30 TO 250,415 OF oMainWnd PIXEL     //380

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @20,40 SAY  cTitulo SIZE 40,10 OF oPanel PIXEL
   @20,80 MSGET cNomeMaquina F3 "Y5" PICTURE "@!" SIZE 15,07 OF oPanel PIXEL

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IF(ORI100Val("Maquina",cNomeMaquina),(nopc:=1,oDlg:End()),)},{||nOpc:=0,oDlg:End()}) CENTERED

   IF nOpc==0
      Return Nil
   Endif

   SX5->(DBSEEK(xFilial("SX5")+"CE"+cNomeMaquina+"MDB"))
   cPathMdb := ALLTRIM(SX5->X5_DESCRI)

   SX5->(DBSEEK(xFilial("SX5")+"CE"+cNomeMaquina+"DBF"))
   cPathDBF := ALLTRIM(SX5->X5_DESCRI)
   cPathDBF := IF( IsSrvUNIX(), StrTran(cPathDBF, '\', '/'), cPathDBF) //JWJ 23/11/2006: Acerta o caminho do diretório

   IF EMPTY(cPathMdb)
      MsgAlert(STR0204+"(MDB)")//"Caminho da Maquina nao cadastrado na Tabela CE no SX5"
      Return .F.
   ENDIF

   IF EMPTY(cPathDBF)
      MsgAlert(STR0204+"(TF)") //"Caminho da Maquina nao cadastrado na Tabela CE no SX5"
      Return .F.
   ENDIF

   lOpenError:=.F.

/* ACSJ - Retirado dos parametros conforme documentação de Marcio Werneck -------------------------------------
   cParametro:=" "
   cParametro+=" maquina="+cNomeMaquina
   cParametro+=" mdb="+cPathMdb
   cParametro+=" dbf="+cPathTF   ----------------------------------------------------------ACSJ - 25/06/2004 */

   cParametro:=" exec= "
   cParametro+=" dias="+cDias
   cParametro+=" maquina="+cNomeMaquina
   cParametro+=" mdb="+cPathMdb
   cParametro+=" dbf="+cPathMdb
   cParametro+=" versao="+cVersao
   cFile:="SISCCAD.EXE"+cParametro

   PRIVATE T_Files:={ {"TF_SJ0" ,"SJ0"},;
                      {"TF_SJ6" ,"SJ6"},;
                      {"TF_SJ7" ,"SJ7"},;
                      {"TF_SJ8" ,"SJ8"},;
                      {"TF_SJ9" ,"SJ9"},;
                      {"TF_SJA" ,"SJA"},;
                      {"TF_SJB" ,"SJB"},;
                      {"TF_SY8" ,"SY8"},;
                      {"TF_SJ1" ,"SJ1"},;
                      {"TF_SJ2" ,"SJ2"},;
                      {"TF_SYD" ,"SYD"},;
                      {"TF_SAH" ,"SAH"},;
                      {"TF_SJC" ,"SJC"},;
                      {"TF_SJE" ,"SJE"},;
                      {"TF_SJF" ,"SJF"},;
                      {"TF_SJG" ,"SJG"},;
                      {"TF_SJH" ,"SJH"},;
                      {"TF_SJI" ,"SJI"},;
                      {"TF_SJJ" ,"SJJ"},;
                      {"TF_SJK" ,"SJK"},;
                      {"TF_SJL" ,"SJL"},;
                      {"TF_SJM" ,"SJM"},;
                      {"TF_SJN" ,"SJN"},;
                      {"TF_SJO" ,"SJO"},;
                      {"TF_SJP" ,"SJP"},;
                      {"TF_SJR" ,"SJR"},;
                      {"TF_M39" ,"SJR"},;
                      {"TF_M42" ,"SJR"},;
                      {"TF_M72" ,"SJR"},;
                      {"TF_M73" ,"SJR"},;
                      {"TF_SJT" ,"SJT"},;
                      {"TF_SYE" ,"SYE"},;
                      {"TF_SJU" ,"SJU"},;
                      {"TF_YE2" ,"SYE"},;
                      {"TF_SYA" ,"SYA"},;
                      {"TF_SYJ" ,"SYJ"} }

   Do While .T.
      nHandle:=WaitRun(cFile,1)
      If nHandle > 0
         Help("", 1, "AVG0000317",,Str(nHandle,5,0),2,10)//MsgStop(STR0108+Str(nHandle,5,0)) //'Erro na execução do SISCCAD.EXE - código = '
         Return .F.
      Endif

      IF ! FILE(cPathMdb+"Easy.Cad")
         Help("", 1, "AVG0000318")//MsgInfo(STR0109,STR0048) //"NÆo Existem Registros para serem Atualizados"###"Informação"
         Return .F.
      ENDIF
      SX3->(DBSETORDER(1))
      IF SX3->(DBSEEK("SJW"))
         DBSELECTAREA("SJW")
         AADD(T_Files,{"TF_SJW" ,"SJW"})
      ENDIF
      IF SX3->(DBSEEK("SJV"))
         DBSELECTAREA("SJV")
         AADD(T_Files,{"TF_SJV" ,"SJV"})
      ENDIF
      IF SX3->(DBSEEK("SJY"))  //ASR - 20/04/2006
         DBSELECTAREA("SJY")
         AADD(T_Files,{"TF_SJY" ,"SJY"})
      ENDIF
      IF SX3->(DBSEEK("SJZ"))  //ASR - 20/04/2006
         DBSELECTAREA("SJZ")
         AADD(T_Files,{"TF_SJZ" ,"SJZ"})
      ENDIF
      IF SX3->(DBSEEK("EIV"))  //Bete - 02/05/2006
         DBSELECTAREA("EIV")
         AADD(T_Files,{"TF_EIV" ,"EIV"})
      ENDIF

      //JWJ 23/11/2006: Tratamento para servidores Unix/Linux
      IF .Not. IsSrvUNIX() .and. RealRDD() <> "CTREE"
         For i := 1 to Len(T_Files)
            if CPYT2S(cPathMDB+T_Files[i,1]+".DBF",cPathDBF,.F.)
               FErase(cPathMDB+T_Files[i,1]+".DBF")
            Else
               MsgStop(STR0211)   // ### "Erro na copia dos arquivos"
            Endif
         Next
      ELSE
         WaitRun("AvgXML2DBF.EXE "+cPathMDB+" tipo=dbf")
         lErroCpy := .F.
         i := 1
         Do While (i <= Len(T_Files)) .And. !lErroCpy
            IF CPYT2S(cPathMDB+T_Files[i,1]+".XML",cPathDBF,.F.)
               CPYT2S(cPathMDB+T_Files[i,1]+".FPT",cPathDBF,.F.)  //Copia somente o MEMO se tiver. O cdx será criado.
               //AvgXML2DBF(cPathDBF+T_Files[i,1]+".XML", T_Files[i,1])
               //FDR - 05/02/2013
               AvgXML2DBF(cPathDBF+T_Files[i,1]+".XML", cPathDBF+T_Files[i,1])
               FErase(cPathDBF+T_Files[i,1]+".XML")
               //Apaga da maquina cliente
               FErase(cPathMDB+T_Files[i,1]+".XML")
               FErase(cPathMDB+T_Files[i,1]+".DBF")
               FErase(cPathMDB+T_Files[i,1]+".CDX")
               FErase(cPathMDB+T_Files[i,1]+".FPT")
            Endif
            i := i + 1
         Enddo
         If lErroCpy
           Exit //Pula o processamento dos arquivos de retorno
         Endif
      ENDIF

      FERASE(cPathMDB+"Easy.Cad")
      Processa({|| AtuCad(),STR0110}) //"Atualizacao de Cadastros"
      Exit
   Enddo
ELSE              // Somente SISC

   IF EMPTY(cPathMdb)
      MsgAlert(STR0204+"(MDB)")//"Caminho da Maquina nao cadastrado na Tabela CE no SX5"
      Return .F.
   ENDIF

   IF EMPTY(cPathMDB)
      MsgAlert(STR0204+"(MDB)")//"Caminho da Maquina nao cadastrado na Tabela CE no SX5"
      Return .F.
   ENDIF


// ACSJ - Retirado dos parametros conforme documentação de Marcio Werneck -------------------------------------
   cParametro:=" dias="+cDias
   cParametro+=" maquina="+cNomeMaquina
   cParametro+=" mdb="+cPathMdb
   cParametro+=" dbf="+cPathMdb
   cParametro+=" versao="+cVersao
   cFile :="SISC01.EXE"+cParametro+" "

   Do While .T.

      nHandle:=WaitRun(cFile,1)

      If nHandle > 0
         Help("", 1, "AVG0000319",,Str(nHandle,5,0),2,10)//MsgStop(STR0111+Str(nHandle,5,0)) //'Erro na execução do SISC01.EXE - código = '
         Return .F.
      Endif

      cMaq:=cNomeMaquina//GetPvProfString("Usuario","Maquina","A1",cEasy )

      IF IsSrvUNIX() .or. RealRDD() == "CTREE"
         //Converte os DBF's na maquina cliente para XML
         AEVAL( Directory(cPathMDB+"*.XML"), {|f| FErase(cPathMDB+f[1]) } ) //Apaga todos os XML's para gerar novos
         WaitRun("AvgXML2DBF.exe "+cPathMDB+" tipo=dbf")
      ENDIF

      lErroCpy := .f.

      IF IsSrvUNIX() .or. RealRDD() == "CTREE"
	      //JWJ: Faz primeiro o XML para não dar erro
	      aArqsMaq := Directory(cPathMDB+"*.XML")
	      For i := 1 To Len(aArqsMaq)
	         cArqAux := cPathMDB+aArqsMaq[i,1]
	         lErroCpy := lErroCpy .OR. ! CPYT2S(cArqAux,cPathDBF,.F.)

	         IF !lErroCpy
	            FErase(cArqAux)
	            cArqAux := LEFT( aArqsMaq[i,1], RAT(".", aArqsMaq[i,1])-1 )
               cArqRef := cArqAux
	            AvgXML2DBF( StrTran(cPathDBF, '\', '/')+cArqAux+".XML", @cArqRef )  //Gera a work CTREE
               TETempReopen(cArqRef, "XML", cArqAux )
               aadd( aRefs , aClone({cArqAux,cArqRef}) )
	         Else
	            Exit
	         ENDIF
	      Next
      EndIF

      // ACSJ - 24/06/2004
      aArqsMaq := Directory(cPathMDB+cMaq+"*.*")

      For i := 1 to Len(aArqsMaq)
         cArqAux := (cPathMDB+aArqsMaq[i,1])
         IF .Not. ISSRVUNIX() .and. RealRDD() <> "CTREE"
            if CPYT2S(cArqAux,cPathDBF,.F.)
               FErase(cArqAux)
            Else
               lErroCpy := .t.
               Exit
            endif
         Else
            lXML := ( nP:=RAT(".DBF", UPPER(cArqAux)) ) > 0

            IF .Not. lXML  //Se for DBF não copia porque já gerou o DTC via XML
               lErroCpy := lErroCpy .OR. ! CPYT2S(cArqAux, cPathDBF, .F.)
            ENDIF

            IF !lErroCpy
               FErase(cArqAux)
            Else
               Exit
            ENDIF
         Endif
      Next

      If lErroCpy
         MsgStop( STR0212 + Chr(13) + Chr(10) +; // ### "Erro na copia dos arquivos de retorno"
                 STR0210)                        // ### "Verifique o caminho indicado como parametro"
      Endif

      IF .NOT. ISSRVUNIX() .and. RealRDD() <> "CTREE" //JWJ
         CPYT2S(cPathMDB+"TFSISC.DBF",cPathDBF,.F.)
      ELSE
         //Copia para o server
         CPYT2S(cPathMDB+"TFSISC.XML",cPathDBF,.F.)

         //Apaga o xml do cliente
         FErase(cPathMDB+"TFSISC.XML")

         //Cria a work a partir do xml
         AvgXML2DBF(STRTRAN(cPathDBF,'\','/')+"TFSISC.XML", "TFSISC")

      ENDIF

      FErase(cPathMDB+"TFSISC.DBF")
      //-----------------------------------------------------------------------------------------------------------
      aDir:=DIRECTORY(cPathDbf+cMaq+"*.FLH")

      IF LEN(aDir) == 0
         Help("", 1, "AVG0000320")//MsgStop(STR0112) //"Nao foram gerados arquivos de retorno pelo SISC"
         Return .F.
      ENDIF

      Processa({|| OR100AtuSWP()})

      FOR nFiles:=1 TO LEN(aDir)
         cArqLeitura:=cMaq+"S"+SUBS(aDir[nFiles,1],4,5)
         Sisc100(cPathDbf,cArqLeitura,"TFSISC","S")
         FERASE(cPathDbf+aDir[nFiles,1])
         FErase(cPathDbf+"TFSISC.DBF")
      NEXT
      Exit
   Enddo
ENDIF

RETURN NIL
RETURN .T.

*--------------------------------------------------------------------------------------*
FUNCTION AtuCad()
*--------------------------------------------------------------------------------------*
LOCAL cSeek,PIND,lSair
LOCAL aCposGrv:={{"CODIGO"  ,"_CODIGO"},{"DESCRICAO","_DESC" }}
Local i //Para q warning não apareça
local lErroCpy := .f.
local cArqAux  := ""
Local aRecno := {}, cCampoBl
PRIVATE Ind,cXX_,posO,posD,cAliasO,cAliasD

FOR I:= 1 to LEN(T_Files)
    Ind := I
    cAliasO:=UPPER(T_Files[Ind,1]) // RJB 05/10/2004
    cAliasD:=UPPER(T_Files[Ind,2]) // RJB 05/10/2004

**** RJB 15/10/2004
  IF .Not. IsSrvUNIX() .and. RealRDD() <> "CTREE" //JWJ 23/11/2006
    cArqAux := (cPathMDB+cAliasO+".dbf")
    if ! file(cArqAux)
       loop
    endif

    if CPYT2S(cArqAux,cPathDBF,.F.)
       lErroCpy := .f.
       FERASE(cArqAux)
    else
       lErroCpy := .t.
    endif

    If lErroCpy
       MsgStop( STR0212 + Chr(13) + Chr(10) +; // ### "Erro na copia dos arquivos de retorno"
                STR0210 + Chr(13) + Chr(10) +;
                "tabela "+cArqAux)                        // ### "Verifique o caminho indicado como parametro"
    Endif
  Endif
****

    IF !EICMXOpen(cAliasO)
       LOOP
    ENDIF

    DBSELECTAREA(cAliasD)
    (cAliasO)->(DBGOTOP())
    ProcRegua((cAliasO)->(Easyreccount(cAliasO))+1)

    lSair:=.F.
    DO WHILE ! (cAliasO)->(EOF())

       IncProc(STR0113+cAliasD+' ==> '+;
               ALLTRIM(STR((cAliasO)->(RECNO())  ,7))+"  de  "+;
               ALLTRIM(STR((cAliasO)->(Easyreccount(cAliasO)),7))) //"Processando Arquivo: "

       IF cAliasD == 'SYE'
          OR100GrvTaxa(cAliasO)
          (cAliasO)->(DBSKIP())
          LOOP
       ENDIF

       aCposPad:= ACLONE(aCposGrv)
       cSeek   := (cAliasO)->(FIELDGET(1))

       OR100IniTab(cAliasO,cAliasD,aCposPad,@cSeek)

       cXX_:=Right(cAliasD,2)
       IF LEFT(cAliasD,1)=="E"
       	  cXX_ := cAliasD
       ENDIF
       IF !(cAliasD)->(DBSEEK(xFilial()+cSeek))
          (cAliasD)->(RecLock(cAliasD,.T.))
          (cAliasD)->(FIELDPUT(FIELDPOS(cXX_+'_FILIAL'),xFilial() ))
          IF cAliasO = "TF_M" .AND. cAliasD = 'SJR' .AND. SJR->(FIELDPOS("JR_FUNDLEG")#0)
             SJR->JR_FUNDLEG:=SUBSTR(cAliasO,5,2)
          ENDIF
       ELSE
          (cAliasD)->(RecLock(cAliasD,.F.))
       ENDIF

       aAdd(aRecno, (cAliasD)->(Recno()))

      IF EasyEntryPoint("EICOR100")
         ExecBlock("EICOR100",.F.,.F.,"ATUCAD")
      ENDIF

       FOR PInd := 1 TO LEN(aCposPad)
           posO := (cAliasO)->(FIELDPOS( aCposPad[PInd,1]      ))
           posD := (cAliasD)->(FIELDPOS( cXX_+aCposPad[PInd,2] ))
           IF posO = 0
              MSGINFO("Campo origem: "+aCposPad[PInd,1]+" nao existe no Arq.: "+cAliasO)
              lSair:=.T.
              EXIT
           ELSEIF posD = 0
              MSGINFO("Campo destino: "+cXX_+aCposPad[PInd,2]+" nao existe no Arq.: "+cAliasD)
              lSair:=.T.
              EXIT
           ENDIF

           IF VALTYPE( (cAliasD)->(FIELDGET(posD)) ) == "N"
              (cAliasD)->(FIELDPUT(posD,VAL( (cAliasO)->(FIELDGET(posO)))))
           ELSEIF VALTYPE( (cAliasD)->(FIELDGET(posD)) ) == "D"
              (cAliasD)->(FIELDPUT(posD,AVCTOD((cAliasO)->(FIELDGET(posO)))))
           ELSE
              (cAliasD)->(FIELDPUT(posD,(cAliasO)->(FIELDGET(posO))))
           ENDIF

       NEXT
      (cAliasD)->(MsUnlock())
      (cAliasO)->(DBSKIP())
      IF lSair
         MSGINFO("Arquivo: "+cAliasD+" nao foi integrado.")
         EXIT
      ENDIF

    ENDDO

    IF EasyEntryPoint("EICOR100")
         ExecBlock("EICOR100",.F.,.F.,"CARGA_ATUCAD")
     ENDIF

     // GCC - 16/11/2013 - Tratamento para excluir registros excludos no Siscomex

     cCampoBl := If(Left(cAliasD, 1) == "S", SubStr(cAliasD, 2, 2), cAliasD) + "_MSBLQL"

     If (cAliasD)->(FieldPos(cCampoBl)) > 0
	     (cAliasD)->(DbSeek(xFilial()))
	     While (cAliasD)->(!Eof())
	     	If aScan(aRecno, (cAliasD)->(Recno())) == 0
	     		(cAliasD)->(RecLock(cAliasD, .F.))
	     		(cAliasD)->&(cCampoBl) := "1"
	     		(cAliasD)->(MsUnLock())
	     	EndIf
	     	(cAliasD)->(DbSkip())
	     EndDo
	EndIf
	aRecno := {}

    (cAliasO)->(dbcloseAREA())
    FERASE(cPathDbf+cAliasO+GetDBExtension())
    FERASE(cPathDbf+cAliasO+".FPT")
    FERASE(cPathDbf+cAliasO+".CDX")

NEXT

SYF->(DBSETORDER(1))

RETURN NIL
*------------------------------------------------------*
Function OR100IniTab(cAliasO,cAliasD,aCposPad,cSeek)
*------------------------------------------------------*
DO CASE
//ASR - 20/04/2006 - INICI0
   CASE cAliasD == 'SJY'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"   ,"_CODIGO" })
        AADD(aCposPad,{"DESCRICAO","_DESC"   })
        AADD(aCposPad,{"TRIBUT_1" ,"_REGTRI1"}) // Bete 02/05/06
        AADD(aCposPad,{"TRIBUT_2" ,"_REGTRI2"}) // Bete 02/05/06
        AADD(aCposPad,{"TRIBUT_3" ,"_REGTRI3"}) // Bete 02/05/06
        AADD(aCposPad,{"TRIBUT_4" ,"_REGTRI4"}) // Bete 02/05/06
        cSeek:=(cAliasO)->(CODIGO)

   CASE cAliasD == 'SJZ'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"    ,"_CODIGO"})
        AADD(aCposPad,{"DESCRICAO" ,"_DESC"  })
        AADD(aCposPad,{"NCM"       ,"_NCM"   }) // Bete 02/05/06
        AADD(aCposPad,{"PERCENTUAL","_PERRED"}) // Bete 02/05/06
        AADD(aCposPad,{"DATA_INICI","_INIVIG"}) // Bete 02/05/06
        AADD(aCposPad,{"DATA_FIM_V","_FIMVIG"}) // Bete 02/05/06
        cSeek:=(cAliasO)->(CODIGO+NCM)
//ASR - 20/04/2006 - FIM

   CASE cAliasD == 'EIV'// Bete 02/05/06
        aCposPad:={}
        AADD(aCposPad,{"CD_NAT_OPE","_NATOPE"})
        AADD(aCposPad,{"TRIBUTAR"  ,"_REG_PC"})
        AADD(aCposPad,{"CD_FUND_LE","_FUN_PC"})
        cSeek:=(cAliasO)->(CD_NAT_OPE+TRIBUTAR+CD_FUND_LE)

   CASE cAliasD == 'SJW'
        aCposPad:={}
        AADD(aCposPad,{"CD_NAT_OPE","_NAT_OPE"})
        AADD(aCposPad,{"TRIBUTAR"  ,"_REGIME" })
        AADD(aCposPad,{"CD_FUND_LE","_FUND_LE"})
        AADD(aCposPad,{"CD_MOTIVO" ,"_MOTIVO" })
        AADD(aCposPad,{"CLASSIFICA","_CLASSIF"})
        AADD(aCposPad,{"LIMITE"    ,"_LIMITE" })
        AADD(aCposPad,{"PIS_COFINS","_REG_PC" })
        cSeek:=(cAliasO)->(CD_NAT_OPE+TRIBUTAR+CD_FUND_LE+CD_MOTIVO)

   CASE cAliasD == 'SJR'
        IF cAliasO = "TF_M" .AND. cAliasD = 'SJR'
           cSeek:=(cAliasO)->(FIELDGET(1)+SUBSTR(cAliasO,5,2))
        ELSE
           cSeek:=(cAliasO)->(FIELDGET(1))
        ENDIF

   CASE cAliasD == 'SAH'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"   ,"_UNIMED" })
        AADD(aCposPad,{"CODIGO"   ,"_COD_SIS"})
        AADD(aCposPad,{"DESCRICAO","_UMRES"  })
        AADD(aCposPad,{"DESCRICAO","_DESCPO" })
        AADD(aCposPad,{"DESCRICAO","_DESCIN" })
        AADD(aCposPad,{"DESCRICAO","_DESCES" })

   CASE cAliasD == 'SJ9'
        AADD(aCposPad,{"CGC_SECEX","_CGC"   })

   CASE cAliasD == 'SJA'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"   ,"_RECALF"})
        AADD(aCposPad,{"DESCRICAO","_DESCR"})

   CASE cAliasD == 'SJB'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"   ,"_COD"  })
        AADD(aCposPad,{"DESCRICAO","_DESCR"})

   CASE cAliasD == 'SJG'
        aCposPad:={}
        AADD(aCposPad,{"ORGAO"  ,"_ORGAO"  })
        AADD(aCposPad,{"RECINTO","_RECINTO"})
        AADD(aCposPad,{"SETOR"  ,"_CODIGO" })
        AADD(aCposPad,{"NOME"   ,"_DESC"   })
        cSeek:=(cAliasO)->(RECINTO+SETOR+ORGAO)

   CASE cAliasD == 'SJK'
        aCposPad:={}
        AADD(aCposPad,{"CD_NOMENC_","_NCM"    })
        AADD(aCposPad,{"CD_ATRIBUT","_ATRIB"  })
        AADD(aCposPad,{"IN_MULTIPL","_MULTIPL"})
        AADD(aCposPad,{"CD_NIVEL_N","_NIVEL"  })
        AADD(aCposPad,{"NM_ATRIBUT","_DES_ATR"})
        cSeek:=(cAliasO)->(CD_NOMENC_+'  '+CD_ATRIBUT)

   CASE cAliasD == 'SJL'
        aCposPad:={}
        AADD(aCposPad,{"CD_NOMENC_","_NCM"    })
        AADD(aCposPad,{"CD_ATRIBUT","_ATRIB"  })
        AADD(aCposPad,{"CD_ESPECIF","_ESPECIF"})
        AADD(aCposPad,{"CD_NIVEL_N","_NIVEL"  })
        AADD(aCposPad,{"NM_ESPECIF","_DES_ESP"})
        cSeek:=(cAliasO)->(CD_NOMENC_+'  '+CD_ATRIBUT+CD_ESPECIF)

   CASE cAliasD == 'SJU'
        AADD(aCposPad,{"MOEDA","_MOEDA"})

   CASE cAliasD == 'SY8'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"   ,"_COD"})
        AADD(aCposPad,{"DESCRICAO","_DES"})

   CASE cAliasD == 'SYD'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"    ,"_TEC"    })
        AADD(aCposPad,{"DESCRICAO" ,"_DESC_P" })
        AADD(aCposPad,{"UNIDADE_ME","_UNID"   })
        AADD(aCposPad,{"ALIQUOTA_I","_PER_II" })
        AADD(aCposPad,{"ALIQ_IPI"  ,"_PER_IPI"})

   CASE cAliasD == 'SYA'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"   ,"_CODGI"})
        AADD(aCposPad,{"DESCRICAO","_DESCR"})

   CASE cAliasD == 'SYJ'
        aCposPad:={}
        AADD(aCposPad,{"CODIGO"   ,"_COD"})
        AADD(aCposPad,{"DESCRICAO","_DESCR"})

ENDCASE
RETURN .T.

*-----------------------------------*
Function OR100GrvTaxa(cAlias)
*-----------------------------------*
LOCAL cMoeda:=''

SYF->(DBSETORDER(3))
IF !SYF->(DBSEEK(xFilial("SYF")+(cAlias)->CODIGO))
   RETURN .F.
ENDIF
cMoeda:=SYF->YF_MOEDA
cData :=AVCTOD((cAlias)->VIGENCIA_I)

SYE->(DBSETORDER(1))
IF !SYE->(DBSEEK(xFilial()+DTOS(cData)+cMoeda))
   SYE->(RecLock('SYE',.T.))
ELSE
   SYE->(RecLock('SYE',.F.))
ENDIF
SYE->YE_MOEDA  :=cMoeda
SYE->YE_VLFISCA:=VAL(STRTRAN((cAlias)->TAXA_CONVE,",","."))
SYE->YE_DATA   :=cData
IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"GRAVA_TAXA"),)
SYE->(MsUnlock())

RETURN .T.

*-------------------------*
Function EICMXOpen(cAlias)
*-------------------------*
LOCAL lAbre:=.T.
Local cDRVOpen := "DBFCDXADS"
If RealRDD() == "ADSSERVER"
   cDRVOpen := "DBFCDX"
Else
   If IsSrvUnix()
      cDRVOpen := ""
   ElseIf RealRDD() == "CTREE"
      cDRVOpen := "CTREE"
   Else
      cDRVOpen := "DBFCDXADS"
   EndIf
EndIf

IF !FILE(cPathDbf+cAlias+GetDBExtension())  // ACSJ - 02/07/2004 - Por esta usando na criação (DBCreate) e Abertura
                                            // (DBUseArea) o DRIVER "DBFCDXADS" o arquivo sera sempre ".DBF"
   RETURN .F.
ENDIF

//dbUseArea(.T.,cDRVOpen,cPathDbf+cAlias,cAlias, .F. , .F. )  //JWJ 21/11/2006
IF ! USED()
   lAbre:=.F.
ENDIF

IF ! lAbre .AND. ! Empty(cAlias)
   (cAlias[1])->(dbcloseAREA())
ENDIF

RETURN lAbre


*----------------------------------------------------------------------------
STATIC FUNCTION Sisc100(Dir_Easy,Arq_Leitura,Arq_Temp,Atu)
*----------------------------------------------------------------------------
LOCAL ArqItens, ArqDestaque, TamArq, nHandle:=0, campo, aDir
Local cDRVOpen

If RealRDD() == "ADSSERVER"
   cDRVOpen := "DBFCDX"
Else
   If IsSrvUnix()
      cDRVOpen := ""
   ElseIf RealRDD() == "CTREE"
      cDRVOpen := "CTREE"
   Else
      cDRVOpen := "DBFCDXADS"
   EndIf
EndIf

DirEasy:=Upper(Dir_Easy)
ArqLeitura:=Arq_Leitura
ArqTemp:=Arq_Temp
Atualiza:=Atu
ArqItens    :=LEFT(ArqLeitura,2)+"I"+RIGHT(ArqLeitura,5)
ArqDestaque :=LEFT(ArqLeitura,2)+"D"+RIGHT(ArqLeitura,5)
TamArq      :=LEN(ALLTRIM(ArqLeitura))
Arquivo:="SWP"

IF TamArq >= 6

//JWJ 17/11/2006: Acertei para que fique compatível com Linux também
/* 
   IF ! FILE(DirEasy+ArqLeitura+GetDBExtension())
      MsgAlert(STR0114+DirEasy+ArqLeitura+GetDBExtension()+STR0115,"Easy Import Control") //"ARQUIVO "###" NAO ENCONTRADO"
      RETURN NIL
   ENDIF 
   /* DBUSEAREA(.T.,cDRVOpen,DirEasy+ArqLeitura,"ItensTemp",.F.,.F.) //JWJ 17/11/2006
   IF ! USED()
      MsgAlert(STR0114+DirEasy+ArqLeitura+GetDBExtension()+STR0116,"Easy Import Control") //"ARQUIVO "###" NAO FOI ABERTO"
      DBcloseAREA()
      RETURN NIL
   ENDIF */

   Arquivo1:="ItensTemp"

   If Select(Arquivo1) # 0
      (Arquivo1)->(dbcloseAREA())
   EndIf

   if ( nAux := ASCAN( aRefs , {|x| alltrim(x[1]) == ArqLeitura } ) ) > 0
      TETempReopen( "" , ArqLeitura, "ItensTemp" )
      (Arquivo1)->(DBGOTOP())
      (Arquivo)->(DBSETORDER(1))
      Processa({|lEnd|AtuCapaLi()},STR0117) //"Atualizacao da Capa da Li"
      (Arquivo1)->(dbcloseAREA())
   endif
   
ENDIF

/* IF !FILE(cPathDbf+ArqTemp+GetDBExtension())
   MsgAlert(STR0114+cPathDbf+ArqTemp+GetDBExtension()+STR0115,"Easy Import Control") //"ARQUIVO "###" NAO ENCONTRADO"
   RETURN NIL
ENDIF

DBUSEAREA(.T.,cDRVOpen,cPathDbf+ArqTemp,"Temp",.F.,.F.)

IF ! USED()
   MsgAlert(STR0114+ArqTemp+GetDBExtension()+STR0116,"Easy Import Control") //"ARQUIVO "###" NAO FOI ABERTO"
   dbcloseAREA() ; RETURN NIL
ENDIF*/
   Arquivo1:="Temp"

   If Select(Arquivo1) # 0
      (Arquivo1)->(dbcloseAREA())
   EndIf

if ( nAux := ASCAN( aRefs , {|x| alltrim(x[1]) == ArqTemp } ) ) > 0
   TETempReopen( "" , ArqTemp, Arquivo1 )

   If Select(Arquivo1) # 0
      (Arquivo1)->(DBGOTOP())
      IF (Arquivo1)->(FieldPos("TFNR_EASY")) == 0
         (Arquivo)->(DBSETORDER(3))
      ELSE
         (Arquivo)->(DBSETORDER(1))
      ENDIF
      Processa({|lEnd|AtuCapaLi()},STR0117) //"Atualizacao da Capa da Li"

      (Arquivo1)->(dbcloseAREA())
   endif
endif

FERASE(DirEasy+ArqLeitura+GetDBExtension())
FERASE(DirEasy+ArqLeitura+".FPT")
FERASE(DirEasy+ArqLeitura+".CDX")

FERASE(DirEasy+ArqItens+GetDBExtension())
FERASE(DirEasy+ArqItens+".FPT")
FERASE(DirEasy+ArqItens+".CDX")

FERASE(DirEasy+ArqDestaque+GetDBExtension())
FERASE(DirEasy+ArqDestaque+".CDX")

FERASE(DirEasy+LEFT(ArqLeitura,2)+"C"+Subs(ArqLeitura,4,5)+GetDBExtension())
FERASE(DirEasy+LEFT(ArqLeitura,2)+"C"+Subs(ArqLeitura,4,5)+".FPT")
FERASE(DirEasy+LEFT(ArqLeitura,2)+"C"+Subs(ArqLeitura,4,5)+".CDX")

RETURN
*----------------------------------------------------------------------------
STATIC FUNCTION AtuCapaLi()
*----------------------------------------------------------------------------
LOCAL nReg:=IF(Arquivo1=="Temp",Temp->(Easyreccount("Temp")),ItensTemp->(Easyreccount("ItensTemp")))
LOCAL nPosSpace := 0, cNrEasy := "", cSeqLi := ""
LOCAL nTamNrPGI := LEN(SWP->WP_PGI_NUM)
LOCAL nTamSeqLi := LEN(SWP->WP_SEQ_LI)

PRIVATE lExibeMensagem := .T.	// RS - 03/11/05

IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"EXIBEMSG"),) // DEICMAR - 03/11/05

 // O PE "EXIBEMSG" foi criado para DEICMAR para inibir a mensagem ao usuario.
 // Neste PE a variavel lExibeMensagem e colocado com .F. para nao mostrar esta mensagem.
 // RS - 03/11/05.

ProcRegua(nReg+1)
WHILE ! (Arquivo1)->(EOF())

 IF Arquivo1=="Temp" .AND. Atualiza <> "S"
    EXIT
 ENDIF

 IF Arquivo1 == "ItensTemp"
    IncProc(STR0118+ItensTemp->TRAT_MICRO) //"Gravando Capa da Li nr: "
 ELSE
    IncProc(STR0118+Temp->TFNR_MICRO) //"Gravando Capa da Li nr: "
 ENDIF

 IF Arquivo1 == "ItensTemp"
    IF !(Arquivo)->(DBSEEK(xFilial()+ItensTemp->PROC_EASY+ItensTemp->SEQ_LI+ItensTemp->NR_MAQ))
       (Arquivo1)->(DBSKIP())
       LOOP
    ELSE
       RecLock(Arquivo,.F.)
       (Arquivo)->WP_MICRO := (Arquivo1)->TRAT_MICRO
       IF (Arquivo)->WP_MICRO <> (Arquivo1)->TRAT_MICRO
          (Arquivo)->WP_MICRO := (Arquivo1)->TRAT_MICRO
       ENDIF
       (Arquivo)->(MsUnlock())
       (Arquivo1)->(DBSKIP())
       LOOP
    ENDIF
 ENDIF

 IF Temp->(FieldPos("TFNR_EASY")) == 0
    cSeekSWP := Temp->TFNR_MAQ+Temp->TFNR_MICRO
    (Arquivo)->(dbsetorder(3))   // rs - 08/12/05
 ELSE
    //ASR - 25/10/2005 - ESTA ALTERAÇÃO PERMITE USAR TAMANHO VARIAVEL DA PGI
    nPosSpace := LEN(RTRIM(Temp->TFNR_EASY))
    cSeqLi := Right(Rtrim(Temp->TFNR_EASY),nTamSeqLi)  //ASR - 25/10/2005
    IF nPosSpace < nTamNrPGI
       cNrEasy := RTrim(Left(Temp->TFNR_EASY,(nPosSpace - nTamSeqLi))) + SPACE(nTamNrPGI - (nPosSpace - (nTamSeqLi + 1)))  //ASR - 25/10/2005
    ELSE
       cNrEasy := RTrim(Left(Temp->TFNR_EASY,(nPosSpace - nTamSeqLi)))  //ASR - 25/10/2005
    ENDIF
    cSeekSWP := AVKey(cNrEasy,"WP_PGI_NUM") + AVKey(cSeqLi,"WP_SEQ_LI") + Temp->TFNR_MAQ  //ASR - 25/10/2005
    (Arquivo)->(dbsetorder(1))  // rs 08/12/05
 ENDIF
 IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"CHAVE_SWP"),) // rs 08/12/05

 IF !EMPTY(Temp->TF_REGIST)
    (Arquivo)->(dbsetOrder(5))
    IF (Arquivo)->(dbSeek(xFilial()+Temp->TF_REGIST))
       IF ALLTRIM((Arquivo)->WP_PGI_NUM) + ALLTRIM((Arquivo)->WP_SEQ_LI) # ;
          ALLTRIM(cNrEasy) + ALLTRIM(cSeqLi)

          IF lExibeMensagem	// RS - 03/11/05 - USADO NO PONTO DE ENTRADA
             MSGINFO("Numero do registro: " + ALLTRIM(Temp->TF_REGIST) + " ja cadastrado para a " + CHR(13)+CHR(10)+;
                    "PLI " + ALLTRIM((Arquivo)->WP_PGI_NUM) +", sequencia " + ALLTRIM((Arquivo)->WP_SEQ_LI) + ", nao podendo ser gravado" + CHR(13)+CHR(10)+;
                    "para a PLI " + ALLTRIM(cNrEasy) + ", sequencia " + ALLTRIM(cSeqLi) )
          ENDIF

          (Arquivo1)->(DBSKIP())
          (Arquivo)->(dbsetOrder(1))
          LOOP
       ENDIF
    ENDIF
    (Arquivo)->(dbsetOrder(1))
 ENDIF

 IF ! (Arquivo)->(DBSEEK(xFilial()+cSeekSWP))
    (Arquivo1)->(DBSKIP())
    LOOP
 ENDIF

 IF EMPTY((Arquivo)->WP_REGIST)
    RecLock(Arquivo,.F.)
    (Arquivo)->WP_PROT     := (Arquivo1)->TF_PROT
    (Arquivo)->WP_TRANSM   := (Arquivo1)->TF_TRANSM
    (Arquivo)->WP_VENCTO   := If(!Empty((Arquivo1)->TF_VENCTO),(Arquivo1)->TF_VENCTO,(Arquivo)->WP_VENCTO)
    (Arquivo)->WP_REGIST   := (Arquivo1)->TF_REGIST
    (Arquivo)->WP_ERRO     := (Arquivo1)->TF_ERRO
    (Arquivo)->WP_RET_ORI  := (Arquivo1)->TF_RET_ORI
    (Arquivo)->(DBCOMMIT())

    IF (Arquivo)->WP_PROT   <> (Arquivo1)->TF_PROT   .OR. ;
       (Arquivo)->WP_TRANSM <> (Arquivo1)->TF_TRANSM .OR. ;
       (Arquivo)->WP_REGIST <> (Arquivo1)->TF_REGIST

       (Arquivo)->WP_PROT   := (Arquivo1)->TF_PROT
       (Arquivo)->WP_TRANSM := (Arquivo1)->TF_TRANSM
       (Arquivo)->WP_REGIST := (Arquivo1)->TF_REGIST
       (Arquivo)->(DBCOMMIT())
    ENDIF
    IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"GRV_WORK_SWP"),)
    (Arquivo)->(MsUnlock())
 ENDIF
 RecLock(Arquivo1,.F.)
 (Arquivo1)->(DBDELETE())
 (Arquivo1)->(DBSKIP())
END
RETURN NIL

*--------------------*
Function ORI100Desp()
*--------------------*
cCodigo:=mv_par03

IF EMPTY(cCodigo)
   Help("", 1, "AVG0000322")//MsgInfo(STR0119,STR0048) //"DESPACHANTE NAO INFORMADO"###"Informação"
   RETURN .F.
ENDIF
IF !SY5->(DbSeek(xFilial()+cCodigo))//JVR - 19/03/09 - Verificação de Despachante se é cadastrado.
   Help("",1,"AVG0005373")//Despachante não cadastrado.
   Return .F.
endIf
RETURN .T.

*------------------------------------*
STATIC Function ORI100BuscaDesp(cCod)
*------------------------------------*
LOCAL cNome
SY5->(DBSETORDER(1))
cNome:=cCod+' '+BuscaDesp(cCod)
RETURN cNome

*---------------------------------*
STATIC FUNCTION ORI100Final(lFim2)
*---------------------------------*
//IF lFim2 == NIL

// BAK - Alteração feita para a nova integração com despachante
//IF Select("TRB") # 0
IF Select("TRB") > 0 // .And. Type("cNomArq") == "C"
   TRB->(E_EraseArq(cNomArq))
Endif

// BAK - Alteração feita para a nova integração com despachante
// IF Select("Work") # 0
IF Select("Work") > 0
   WORK->(E_EraseArq(cNomWork))
Endif

//ELSEIF lFim2

// BAK - Alteração feita para a nova integração com despachante
// IF Select("CapaLi") # 0
IF Select("CapaLi") > 0
   CapaLi->(E_EraseArq(FileWk1))
ENDIF

// BAK - Alteração feita para a nova integração com despachante
// IF Select("ItemLi") # 0
IF Select("ItemLi") > 0
   ItemLi->(E_EraseArq(FileWk2))
ENDIF

// BAK - Alteração feita para a nova integração com despachante
// IF Select("NcmLI") # 0
IF Select("NcmLI") > 0
   NcmLI ->(E_EraseArq(FileWk3))
ENDIF

// BAK - Alteração feita para a nova integração com despachante
// IF Select("Work_PAnu") # 0
IF Select("Work_PAnu") > 0
   Work_PAnu ->(E_EraseArq(cArqTrabP))
ENDIF
//ELSEIF !lFim2

// BAK - Alteração feita para a nova integração com despachante
// IF Select("Gip_Lite") # 0
IF Select("Gip_Lite") > 0
   Gip_Lite ->(E_EraseArq(FileWk1))
ENDIF

// BAK - Alteração feita para a nova integração com despachante
// IF Select("Gip_Lite2") # 0
IF Select("Gip_Lite2") > 0
   Gip_Lite2->(E_EraseArq(FileWk4))
ENDIF

//ENDIF

DBSELECTAREA("SX3")
SX3->(DBSETORDER(1))


RETURN .T.

*------------------------------*
STATIC FUNCTION OR100AtuSWP()
*------------------------------*
LOCAL nOrdSWP:=SWP->(INDEXORD())
PROCREGUA(TRB->(Easyreccount("TRB")))
SWP->(DBSETORDER(1))
TRB->(DBGOTOP())
DO WHILE TRB->(!EOF())
   IncProc(STR0016+":"+TRB->WP_PGI_NUM)
   IF TRB->WP_FLAGWIN==cMarca .AND. SWP->(DBSEEK(cFilSWP+TRB->WP_PGI_NUM+TRB->WP_SEQ_LI))
      SWP->(RecLock("SWP",.F.))
      SWP->WP_NR_MAQ      :=cCodigo
      SWP->WP_ENV_ORI     :=cData
      IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"GRAVA_SWP"),)
      SWP->(MsUnlock())
   ENDIF
TRB->(DBSKIP())
ENDDO
SWP->(DBSETORDER(nOrdSWP))
TRB->(DBGOTOP())
RETURN

*----------------------------*
STATIC FUNCTION ORI100PATH()
*----------------------------*
LOCAL cFilSW5:=xFilial("SX5"),cCaminho:=" ",nOpc:=0
LOCAL cTitulo:=AVSX3("WP_NR_MAQ",05),cChave:=Space(2)

DO WHILE .T.

   nOpc:=0
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 91,30 TO 200,350 OF oMainWnd PIXEL

   @20,40 SAY  cTitulo SIZE 40,10 OF oDlg PIXEL
   @20,80 MSGET cChave F3 "Y5" SIZE 15,07 OF oDlg PIXEL
   DEFINE SBUTTON FROM 20,130 TYPE 1 ACTION (nOpc:=1,oDlg:End()) ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED

   IF nOpc==0
      Return(" ")
   ENDIF

   IF !ORI100Val("Maquina",cChave)
      LOOP
   ENDIF

   IF SX5->(DBSEEK(cFilSW5+"CE"+cChave+"GIP"))// AWR parametro novo para o envio do GIP
      cCaminho:=ALLTRIM(SX5->X5_DESCRI)
   ELSEIF SX5->(DBSEEK(cFilSW5+"CE"+cChave+"DBF"))
      cCaminho:=ALLTRIM(SX5->X5_DESCRI)
   ELSE
      MsgAlert(STR0204+" ("+cChave+"GIP)")//"Caminho da Maquina nao cadastrado na Tabela CE no SX5"
   ENDIF

   //JVR - 20/03/09 - Verifica se existe a pasta.
   If Len(Directory(cCaminho+"*.*","D")) == 0
      MSGAlert(STR0215)//"Caminho de arquivo não encontrado."
      cCaminho:=("")
   EndIf

   EXIT
ENDDO
Return cCaminho

*-----------------------------------*
STATIC FUNCTION ORI100SWPWORK()
*-----------------------------------*
LOCAL nRegua:=10,nCont:=0,cSWPCol , nColuna
TRB->(avzap())

ProcRegua(nRegua)

IF(lTop)
   IncProc(STR0025) //"Capa da L.I"
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "SWPNEW" NEW

   FOR nColuna:=1 TO SWP->(FCOUNT())
      cSWPCol:=SWP->(FIELDNAME(nColuna))
      IF VALTYPE(SWP->(FIELDGET(nColuna)))=="D"
         TCSETFIELD("SWPNEW",cSWPCol,"D",8,0)
      ELSEIF VALTYPE(SWP->(FIELDGET(nColuna)))=="N"
          TCSETFIELD("SWPNEW",cSWPCol,"N",AVSX3(cSWPCol,3),AVSX3(cSWPCol,4))
      ENDIF

   NEXT



   DBSELECTAREA("TRB")
   APPEND FROM "SWPNEW"
   TRB->(DBGOTOP())
   SWPNEW->(DBCLOSEAREA())
ELSE
   DO WHILE ! SWP->(EOF()) .AND. SWP->WP_FILIAL==cFilSWP .AND. Eval(bWhile)

      IncProc(STR0025+" "+SWP->WP_PGI_NUM) //"Capa da L.I"

      IF nCont>nRegua
        ProcRegua(nRegua)
        nCont:=0
      ENDIF
      nCont++

      IF ! EVAL(bFor)
         SWP->(DBSKIP())
         LOOP
      ENDIF

      TRB->(DBAPPEND())
      AVREPLACE("SWP","TRB")
      SWP->(DBSKIP())

   ENDDO
ENDIF
RETURN .T.

*---------------------------------*
STATIC FUNCTION ORI100SW2WORK()
*---------------------------------*
LOCAL nRegua:=10,nCont:=0,cSW2Col ,nColuna
TRB->(avzap())

ProcRegua(nRegua)

IF(lTop)
   IncProc(STR0026) //"Capa da P.O"
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "SW2NEW" NEW

   FOR nColuna:=1 TO SW2->(FCOUNT())
      cSW2Col:=SW2->(FIELDNAME(nColuna))
      IF VALTYPE(SW2->(FIELDGET(nColuna)))=="D"
         TCSETFIELD("SW2NEW",cSW2Col,"D",8,0)
      ELSEIF VALTYPE(SW2->(FIELDGET(nColuna)))=="N"
          TCSETFIELD("SW2NEW",cSW2Col,"N",AVSX3(cSW2Col,3),AVSX3(cSW2Col,4))
      ENDIF

   NEXT

   DBSELECTAREA("TRB")


   APPEND FROM "SW2NEW"
   TRB->(DBGOTOP())
   SW2NEW->(DBCLOSEAREA())
ELSE

   DO WHILE SW2->(!EOF()) .AND. SW2->W2_FILIAL==cFilSWP .AND. Eval(bWhile)

      IncProc(STR0026+" "+SW2->W2_PO_NUM) //"Capa da P.O"

      IF nCont>nRegua
        ProcRegua(nRegua)
        nCont:=0
      ENDIF
      nCont++

      IF ! EVAL(bFor)
         SW2->(DBSKIP())
         LOOP
      ENDIF

      TRB->(DBAPPEND())
      AVREPLACE("SW2","TRB")
      SW2->(DBSKIP())

   ENDDO
ENDIF
RETURN .T.
*---------------------------------*
STATIC FUNCTION ORI100SW6WORK()
*---------------------------------*
LOCAL nRegua:=10,nCont:=0,nColuna:=1
TRB->(avzap())

ProcRegua(nRegua)

IF(lTop)
   IncProc(STR0027) //"Capa do Desembaraco"
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "SW6NEW" NEW

   FOR nColuna:=1 TO SW6->(FCOUNT())
      cSW6Col:=SW6->(FIELDNAME(nColuna))
      IF VALTYPE(SW6->(FIELDGET(nColuna)))=="D"
         TCSETFIELD("SW6NEW",cSW6Col,"D",8,0)
      ELSEIF VALTYPE(SW6->(FIELDGET(nColuna)))=="N"
          TCSETFIELD("SW6NEW",cSW6Col,"N",AVSX3(cSW6Col,3),AVSX3(cSW6Col,4))
      ENDIF

   NEXT

   DBSELECTAREA("TRB")
   APPEND FROM "SW6NEW"
   TRB->(DBGOTOP())
   SW6NEW->(DBCLOSEAREA())

ELSE

   DO WHILE SW6->(!EOF()) .AND. SW6->W6_FILIAL==cFilSW6 .AND. Eval(bWhile)

      IncProc(STR0027+" "+SW6->W6_HAWB) //"Capa do Desembaraco"

      IF nCont>nRegua
        ProcRegua(nRegua)
        nCont:=0
      ENDIF
      nCont++

      IF ! EVAL(bFor)
         SW6->(DBSKIP())
         LOOP
      ENDIF

      TRB->(DBAPPEND())
      AVREPLACE("SW6","TRB")
      SW6->(DBSKIP())

   ENDDO
ENDIF
*---------------------------*
STATIC FUNCTION OR100PESQ()
*---------------------------*
LOCAL oDlgPesq,nLinha:=19,nOpcao:=0,cPoNum:=SPACE(LEN(SW2->W2_PO_NUM)),cHawb:=SPACE(LEN(SW6->W6_HAWB))
LOCAL bOk:={||nOpcao:=1,oDlgPesq:End()}
LOCAL bCancel:={||oDlgPesq:End()}
LOCAL bValidaPo:={|| IF(!SW2->(DBSEEK(xFilial()+cPoNum)),(Help("", 1, "AVG0000310"),.F.),.T.)}
LOCAL bValidaHawb:={|| IF(!SW6->(DBSEEK(xFilial("SW6")+cHawb)),(Help("", 1, "AVG0000311"),.F.),.T.)}

TLi := SPACE(10)
TSeq := SPACE(3)


IF TOpcao == ENVIA_ORIENTADOR .AND. cFase == FASE_PO

   DEFINE MSDIALOG oDlgPesq FROM  91,30 TO 230,435 TITLE "Pesquisa P.L.I." PIXEL Of oMainWnd

   @ nLinha ,006 SAY STR0016 SIZE 40, 7 OF oDlgPesq PIXEL //"No. LI (EASY)"
   @ nLinha-1,  51 MSGET TLi  F3 "SWP" PICTURE _PictPgi VALID (ORI100Val("LI1"))                  SIZE 23, 10 OF oDlgPesq PIXEL
   @ nLinha-1, 110 MSGET TSeq PICTURE "999"    VALID (ORI100Val("LI2"))  when !empty(tli) SIZE 23, 10 OF oDlgPesq PIXEL

   DEFINE SBUTTON FROM 07,146 TYPE 1 ACTION (nOpcao:=1,oDlgPesq:End()) ENABLE OF oDlgPesq
   DEFINE SBUTTON FROM 28,146 TYPE 2 ACTION (nOpcao:=0,oDlgPesq:End()) ENABLE OF oDlgPesq

   ACTIVATE MSDIALOG oDlgPesq CENTERED

   IF nOpcao=1 .AND. !EMPTY(TLi)
      TRB->(DBSEEK(ALLTRIM(TLi+TSeq)))
   ENDIF

ELSEIF TOpcao = ENVIA_GIPLITE .AND. cFase = FASE_PO


   DEFINE MSDIALOG oDlgPesq FROM  91,30 TO 230,435 TITLE "Pesquisa P.O." PIXEL Of oMainWnd

   @ nLinha ,006 SAY AVSX3("W2_PO_NUM",5) SIZE 40, 7 OF oDlgPesq PIXEL
   @ nLinha-1,  51 MSGET cPoNum  F3 "SW2"  PICTURE AVSX3("W2_PO_NUM",6) VALID EVAL(bValidaPo) SIZE 45, 10 OF oDlgPesq PIXEL


   DEFINE SBUTTON FROM 07,146 TYPE 1 ACTION (nOpcao:=1,oDlgPesq:End()) ENABLE OF oDlgPesq
   DEFINE SBUTTON FROM 28,146 TYPE 2 ACTION (nOpcao:=0,oDlgPesq:End()) ENABLE OF oDlgPesq

   ACTIVATE MSDIALOG oDlgPesq CENTERED

   IF nOpcao=1 .AND. !EMPTY(cPoNum)
      TRB->(DBSEEK(ALLTRIM(cPoNum)))
   ENDIF

ELSE

   DEFINE MSDIALOG oDlgPesq FROM  91,30 TO 230,435 TITLE "Pesquisa Processo" PIXEL Of oMainWnd

   @ nLinha ,006 SAY AVSX3("W6_HAWB",5) SIZE 40, 7 OF oDlgPesq PIXEL
   @ nLinha-1,  51 MSGET cHawb  F3 "SW6" PICTURE AVSX3("W6_HAWB",6) VALID EVAL(bValidaHawb) SIZE 50, 10 OF oDlgPesq PIXEL


   DEFINE SBUTTON FROM 07,146 TYPE 1 ACTION (nOpcao:=1,oDlgPesq:End()) ENABLE OF oDlgPesq
   DEFINE SBUTTON FROM 28,146 TYPE 2 ACTION (nOpcao:=0,oDlgPesq:End()) ENABLE OF oDlgPesq

   ACTIVATE MSDIALOG oDlgPesq CENTERED

   IF nOpcao=1 .AND. !EMPTY(cHawb)
      TRB->(DBSEEK(ALLTRIM(cHawb)))
   ENDIF



ENDIF
RETURN .T.


*-------------------------------------*
FUNCTION OR100GrvLSI()
*-------------------------------------*
Local nCont:=0,mMemo,nItem:=0,nTotal:=10 ,E
Local cTipoVia,nHdl,nSair,aMenslog:={},cWhere,aTabMDBs:={}
Local nTamIMemo:= AvSx3("B1_VM_GI",3)
Local nTamEsp  := AVSX3("WP_ESP_VM",3)
Local nTamInf  := AVSX3("WP_INF_VM",3)
//PRIVATE ENTER:=CHR(13)+CHR(10)
PRIVATE cODBC_LSI:= EasyGParam("MV_ODBCLSI",,"LSI")
PRIVATE oDlgProc := GetWndDefault(), oDLGDescr
PRIVATE aTBCamposC:={}
PRIVATE aTBCamposP:={}

cFilSA2:=xFilial("SA2")
cFilSB1:=xFilial("SB1")
cFilSWP:=xFilial("SWP")
cFilEIT:=xFilial("EIT")
cFilSAH:=xFilial("SAH")
cFilSW5:=xFilial("SW5")
cFilSW2:=xFilial("SW2")
cFilSW4:=xFilial("SW4")
cFilSYT:=xFilial("SYT")
cFilSYF:=xFilial("SYF")
cFilSYD:=xFilial("SYD")

OR100AbreWork()// Cria os arquivos temporarios

ProcRegua(TRB->(Easyreccount("TRB")))

EIT->(dbSetOrder(1))
SAH->(DBSETORDER(1))
SWP->(DBSETORDER(1))
SYT->(dbSetOrder(1)) // YT_FILIAL+YT_COD_IMP
SA2->(dbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
SW2->(dbSetOrder(1)) // W2_FILIAL+W2_PO_NUM
SW5->(DBSETORDER(7))

TRB->(DBGOTOP())

cNumLSI:=cErro:=cErroTotal:=""

DO WHILE TRB->(!EOF())

   IF SWP->(DBSEEK(cFilSWP+TRB->WP_PGI_NUM+TRB->WP_SEQ_LI))
      cNumLSI := cNomeNew := LEFT( ALLTRIM(SWP->WP_PGI_NUM)+"_"+SWP->WP_SEQ_LI,LEN(Work_Capa->NR_TRAT_IM) )
   ELSE
      TRB->(DBSKIP())
      LOOP
   ENDIF

   IncProc("Lendo/enviando LSI: "+cNumLSI)

   IF EMPTY(TRB->WP_FLAGWIN)
      TRB->(DBSKIP())
      LOOP
   ENDIF

   oDlgProc:SetText("Verificacao se existe/atualizando dados no Siscomex...")

   cWhere      :=" WHERE NR_TRAT_IMP_MICRO = '"+cNumLSI+"'"
   aArrayChaves:={{"NR_TRAT_IMP_MICRO","NR_TRAT_IM","",""}}
   aArrayCampos:={{"","","",""}}
   aTabMDBs    :={"OPERAÇÃO_COM_TRATAMENTO","PROCESSO_ANUENTE"}
   cErro       :=""
   DbSelectArea("Work_Capa")
   AvZap()
   DbSelectArea("Work_PAnu")
   AvZap()

   FOR E := 1 TO LEN(aTabMDBs)
       cMenErro:= "A) Erro na Atualizacao dos dados da Tabela: "+aTabMDBs[E]+ENTER
       aMenslog:= {}

       IncProc("Verificando Tabela: "+aTabMDBs[E])
       //Se preencher a arquivo Work_Capa...
       IF EICDLL(cODBC_LSI,aTabMDBs[E],aArrayChaves,aMenslog,"Work_Capa",,cWhere,.F.,.T.)
          Work_Capa->(DBGOTOP())
          Work_Capa->TIPO_MANUT:="E"
          //...exclui os registros existentes p/ incluir os novos registros
          OR100DLLSQL(aTabMDBs[E],"Work_Capa","TIPO_MANUT","E",aArrayCampos,aArrayChaves,cMenErro,.F.)
          DbSelectArea("Work_Capa")
          AvZap()
       ENDIF
       If !Empty(aMenslog)
          IF LEN(aMenslog) # 1 .OR. LEFT(aMenslog[1],2) # "13"
             cErro+="A) Erro na verificacao se existe dados da Tabela: "+aTabMDBs[E]+ENTER
             For nCont = 1 To Len(aMenslog)
                 cErro+=aMensLog[nCont]+ENTER
             Next
             cErro+=ENTER
          ENDIF
       EndIf
   NEXT

   oDlgProc:SetText("Lendo dados p/ gravacao da LSI...")

   SA2->(dbSeek(cFilSA2+SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ")))
   SB1->(dbSeek(cFilSB1+SW5->W5_COD_I))
   SW5->(DBSEEK(cFilSW5+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
   SW2->(DBSEEK(cFilSW2+SW5->W5_PO_NUM))
   SYF->(DBSEEK(cFilSYF+SW2->W2_MOEDA))
   SW4->(DBSEEK(cFilSW4+SWP->WP_PGI_NUM))
   SYT->(dbSeek(cFilSYT+SW4->W4_IMPORT))
// SAH->(DBSEEK(cFilSAH+SYD->YD_UNID))// Nao tem campo p/ gravar a descricao da unidade
   SYD->(dbSeek(cFilSYD+SWP->WP_NCM))

   Work_Capa->(DBAPPEND())
   Work_Capa->NR_TRAT_IM := cNumLSI
   Work_Capa->TIPO_MANUT := "I"
   Work_Capa->NR_LI_SUBS := "0000000000"   // EOS - 27/01/04
   Work_Capa->NR_DECL_IM := "0000000000"   // EOS - 27/01/04
   Work_Capa->NR_ADI_IMP := "000"          // EOS - 27/01/04
   Work_Capa->NR_SEQ_RET := "00"           // EOS - 27/01/04
   Work_Capa->CD_ORIGEM  := "1"
   Work_Capa->CD_TIPO_IM := IF(SYT->YT_TIPO="4","5",SYT->YT_TIPO)
   Work_Capa->NR_IMPORTA := SYT->YT_CGC
// Work_Capa->NR_EMP_DEC := SYT->YT_CGC
   IF VAL(SYT->YT_TIPO) > 2
      Work_Capa->CD_PAIS_IM := SYT->YT_PAIS           //CD_PAIS_IMPORTADOR
      Work_Capa->NM_IMPORTA := SYT->YT_NOME           //NM_IMPORTADOR
      Work_Capa->NR_TEL_IMP := SYT->YT_TEL_IMP        //NR_TEL_IMPORTADOR
      Work_Capa->ED_LOGR_IM := SYT->YT_ENDE           //ED_LOGR_IMPORTADOR
      Work_Capa->ED_NR_IMPO := STR(SYT->YT_NR_END,6)  //ED_NR_IMPORTADOR
      Work_Capa->ED_COMPL_I := SYT->YT_BAIRRO         //ED_COMPL_IMPO
      Work_Capa->ED_MUN_IMP := SYT->YT_CIDADE         //ED_MUN_IMPORTADOR
      Work_Capa->ED_UF_IMPO := Alltrim(SYT->YT_ESTADO)//ED_UF_IMPORTADOR
      Work_Capa->ED_CEP_IMP := SYT->YT_CEP            //ED_CEP_IMPORTADOR
      Work_Capa->CD_PAIS_IM := SYT->YT_PAIS           //CD_PAIS_IMPORTADOR
   ENDIF
   Work_Capa->NR_CPF_REP := SYT->YT_CPF_REP
   Work_Capa->CD_MERCADO := SWP->WP_NCM
   Work_Capa->CD_PAIS_PR := SWP->WP_PAIS_PR
   Work_Capa->CD_PAIS_OR := SA2->A2_PAIS
   Work_Capa->PL_BEM     := OR100STR(SW5->W5_QTDE * If(SW5->W5_PESO==0,B1PESO(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")),SW5->W5_PESO),16,5)
   Work_Capa->PB_BEM     := "000000000000000"         // EOS - 27/01/04
   Work_Capa->CD_MOEDA_N := SYF->YF_COD_GI
   Work_Capa->CD_REGIME  := SWP->WP_REG_TRI
   Work_Capa->CD_FUND_LE := SWP->WP_FUN_REG
   Work_Capa->CD_UL_DESP := SWP->WP_URF_DES
   Work_Capa->IN_MATERIA := (SWP->WP_MATUSA == "1")
   Work_Capa->IN_SALVO_D := .F.//"Não"
   Work_Capa->IN_SELECAO := .F.//"Não"
   Work_Capa->QT_MERC_UN := OR100STR(SW5->W5_QTDE,15,5)
   Work_Capa->VL_UNID_LO := OR100STR(SW5->W5_PRECO,14,2)
   Work_Capa->IN_MERCOSU := (SWP->WP_MERCOS="1")
   Work_Capa->CD_MOTIVO  := SWP->WP_MOTIVO
   Work_Capa->CD_NATUREZ := SWP->WP_NAT_LSI
   Work_Capa->IN_REPR_SE := .F.//"Não"
   IF SWP->WP_TEC_CL = "0" // NCM
      cUMde:=BUSCA_UM(SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN,SW5->W5_CC+SW5->W5_SI_NUM,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
      SAH->(DBSEEK(cFilSAH+cUMde))
      Work_Capa->NM_UN_MEDI := SUBSTR(SAH->AH_DESCPO,1,20)
      Work_Capa->CD_TIPO_CL := "1"
      Work_Capa->CD_MER_TTE := SWP->WP_NCM
      Work_Capa->NR_DESTAQU := SYD->YD_DESTAQU
      Work_Capa->QT_UN_ESTA := OR100STR(SWP->WP_QT_EST,15,5)//Na tela so cabe 9 inteiros e 5 decimais + a virgula = 15
   ELSEIF SWP->WP_TEC_CL = "1"// TSP
      Work_Capa->CD_TIPO_CL := "2"
      Work_Capa->CD_MER_TTE := SUBSTR(SWP->WP_NCM,1,4)
   ENDIF
   IF !EMPTY(SWP->WP_INFCOMP)
      Work_Capa->TX_INFO_CO := STRTRAN(MSMM(SWP->WP_INFCOMP,nTamInf),ENTER,' ')
   ENDIF
   mMemo:=""
   IF !EMPTY(SWP->WP_ESPECIF)
      mMemo:= MSMM(SWP->WP_ESPECIF,nTamEsp)
   ENDIF
   IF EMPTY(mMemo) .AND. !EMPTY(SB1->B1_DESC_GI)
      mMemo:= MSMM(SB1->B1_DESC_GI,nTamIMemo)
   ENDIF
   Work_Capa->TX_DESC_DE := STRTRAN(mMemo,ENTER,' ')
   Work_Capa->IN_REST_DA := "N"               // EOS - 27/01/04
   Work_Capa->NR_EMP_DEC := "00000000000000"  // EOS - 27/01/04
   Work_Capa->NR_MAT_FUN := "00000000"        // EOS - 27/01/04
   Work_Capa->DT_DESEMB_ := "00000000"        // EOS - 27/01/04
   SET CENTURY ON
   Work_Capa->DT_ATU_OPE := DTOC(dDataBase)
   SET CENTURY OFF

   IF(EasyEntryPoint("EICOR100"),ExecBlock("EICOR100",.F.,.F.,"LENDO_DADOS_PARA_GRAVACAO_DA_LSI"),) // JBS - 20/05/2004

   oDlgProc:SetText("Lendo dados p/ gravacao da LSI...")
   EIT->(dbSeek(cFilEIT+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
   DO While !EIT->(Eof()) .And.;
      		EIT->EIT_FILIAL == cFilEIT	        .And.;
    		EIT->EIT_PGI_NU == SWP->WP_PGI_NUM .AND.;
 	        EIT->EIT_SEQ_LI == SWP->WP_SEQ_LI

      Work_PAnu->(DBAPPEND())
      Work_PAnu->TIPO_MANUT:="I"
      Work_PAnu->NR_TRAT_IM:=cNumLSI
      Work_PAnu->NR_PROC_AN:=EIT->EIT_NUMERO
      Work_PAnu->SG_ORG_PRO:=EIT->EIT_ORGAO

      EIT->(DBSKIP())

   ENDDO

   OR100GrvMDB()

   cArqTxt:=""

   IF !EMPTY(cErro)
      cNomeNew := STRTRAN(cNomeNew,"\","")
      cNomeNew := STRTRAN(cNomeNew,"/","")
      cNomeNew := STRTRAN(cNomeNew,".","")
      cNomeNew := STRTRAN(cNomeNew,":","")
      cNomeNew := STRTRAN(cNomeNew,"*","")
      cNomeNew := STRTRAN(cNomeNew,"?","")
      cNomeNew := STRTRAN(cNomeNew,"'","")
      cNomeNew := STRTRAN(cNomeNew,'"',"")
      cNomeNew := STRTRAN(cNomeNew,">","")
      cNomeNew := STRTRAN(cNomeNew,"<","")
      cNomeNew := STRTRAN(cNomeNew,"|","")
      cNomeNew := ALLTRIM(cNomeNew)+SUBSTR(E_Create(,.F.),3)
      cArqTxt  := AllTrim(cNomeNew) + ".txt"
      If File(cArqTxt)
         FErase(cArqTxt)
      EndIf
      nHdl:=EasyCreateFile(cArqTxt)
      If nHdl < 0
         cErro+="Erro na criacao do arquivo: "+cArqTxt+ENTER
         cArqTxt:=''
      ELSE
         FWrite(nHdl,cErro)
         FClose(nHdl)
      EndIf
   EndIf

   oDlgProc:SetText("Gravando LOG da LSI...")

   lRecL:=!EIR->(DBSEEK(xFilial("EIR")+cNumLSI))
   EIR->(RecLock("EIR",lRecL))
   EIR->EIR_FILIAL := xFilial("EIR")
   EIR->EIR_HAWB   := cNumLSI
   EIR->EIR_DATA   := dDataBase
   EIR->EIR_HORA   := Time()
   EIR->EIR_USUARI := SubStr(cUsuario,7,15)
   EIR->EIR_ARQUIV := IF(!EMPTY(cErro),cArqTxt,"Nao houve erros.")
   EIR->(MsUnlock())

   cErroTotal+=cErro
   IF EMPTY(cErro)
      SWP->(RECLOCK("SWP",.F.))
      SWP->WP_NR_MAQ :=cCodigo
      SWP->WP_MICRO  :=cNumLSI
      SWP->WP_ENV_ORI:=dDataBase//cData
      SWP->(MSUNLOCK())
   ENDIF

   TRB->(DBSKIP())

ENDDO

IF !EMPTY(cErroTotal)
   aButtons:={}
   Aadd(aButtons,{"NOTE",{|| nSair:=1,oDLGDescr:End() },"Analisar dados enviados"})

   DEFINE FONT oFont NAME "Courier New" SIZE 0,15
   DO WHILE .T.
      nSair:=0
      DEFINE MSDIALOG oDLGDescr TITLE "Erros na gravacao da LSI";//: "+ALLTRIM(SWP->WP_PGI_NUM)+"_"+SWP->WP_SEQ_LI;
          From 00,00 To 30,70 OF oMainWnd

          oDLGDescr:SetFont(oFont)
          @17,2 GET oGetMemo VAR cErroTotal MEMO HSCROLL SIZE 275,210 OF oDLGDescr PIXEL
          oGetMemo:Align := CONTROL_ALIGN_ALLCLIENT

      ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDLGDescr,{||oDLGDescr:End()},{||oDLGDescr:End()},,aButtons) CENTERED
      IF nSair = 0
         EXIT
      ENDIF
      OR100Analise()
   ENDDO
ENDIF

MsgInfo("Fim do Processamento.")

RETURN .T.
*-----------------------------------*
FUNCTION OR100Analise()
*-----------------------------------*
LOCAL oDLG,nLin:=26
Local xx := ""
Local bShow:={|nTela,o|DBSelectArea(aObjMark[nTela,2]),;
                       o:=aObjMark[nTela,1]:oBrowse,;
                       o:Show(),o:SetFocus() }
Local bHide:={|nTela| aObjMark[nTela,1]:oBrowse:Hide() }

LOCAL aButtons:={},aObjMark:={}
Aadd(aButtons,{"NOTE",{|| OR100Verro(Alias()) },"Mensagem de Erro"})

Work_Capa->(DBGOTOP())
Work_PAnu->(DBGOTOP())

DEFINE MSDIALOG oDLG TITLE "Analise dos dados da LSI, "+cNumLSI;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
         TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

     oFld:=TFolder():New(15,1,{"Operacao com Tratamento","Processo Anuente"},{"1","2"},oDlg,,,,.T.,.F.,150,100)

     oFld:Align:=CONTROL_ALIGN_ALLCLIENT

     aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })

     // Capa     
     oMark1 := MsSelect():New("Work_Capa",,,aTBCamposC,.F.,cMarca,{1,1,1,1},,,oFld:aDialogs[1])
     oMark1:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
     AADD(aObjMark,{oMark1,"Work_Capa"})

     //Item     
     oMark2 := MsSelect():New("Work_PAnu",,,aTBCamposP,.F.,cMarca,{1,1,1,1},,,oFld:aDialogs[2])
     oMark2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
     AADD(aObjMark,{oMark2,"Work_PAnu"})

     AEVAL(aObjMark,{|V,P| Eval(bHide,P)})
     Eval(bShow,1)
     oFld:bChange:={|nFolNew,nFolOld| Eval(bHide,nFolOld),Eval(bShow,nFolNew)}

ACTIVATE MSDIALOG oDLG ON INIT DI500EnchoiceBar(oDLG,,{||oDLG:End()},.F.,aButtons)

RETURN .T.

*-----------------------------------------------*
FUNCTION OR100Verro(cAlias)
*-----------------------------------------------*
LOCAL oDLG,mErro:=(cAlias)->WKERRO

DEFINE FONT oFont NAME "Courier New" SIZE 0,15
DEFINE MSDIALOG oDLG TITLE "Mensagem de Erro, Arquivo: "+cAlias From 15,00 To 32,54 OF oMainWnd

     oDLG:SetFont(oFont)
     @17,2 GET oGetMemo VAR mErro MEMO HSCROLL SIZE 203,100 OF oDLG PIXEL
     oGetMemo:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDLG ON INIT DI500EnchoiceBar(oDLG,,{|| oDLG:End()},.F.) CENTERED

RETURN .T.

*-----------------------------------*
FUNCTION OR100STR(nValor,nTam,Dec)
*-----------------------------------*
LOCAL cVal:=STRTRAN(STRZERO(nValor,nTam,Dec),".","")
RETURN cVal
*-----------------------------------*
FUNCTION OR100AbreWork()
*-----------------------------------*
LOCAL cPict:= "@E 999,999,999,999,999" , S
LOCAL bTipo:={|| IF(TIPO_MANUT="I","Inclusao" ,;
                 IF(TIPO_MANUT="A","Alteracao",;
                 IF(TIPO_MANUT="E","Exclusao" ,"         "))) }
ProcRegua(5)

aTBCamposC:={}
aTBCamposP:={}

IncProc("Criando Estruturas...")

// TABELA  : OPERAÇÃO_COM_TRATAMENTO
aStru := {}
AADD(aStru, { "TIPO_MANUT" , "C",001,0 } )
AADD(aStru, { "NR_TRAT_IM" , "C",015,0 } ) ; AADD(aStru, { "NR_OPER_TR" , "C",010,0 } )
AADD(aStru, { "CD_AUTORIZ" , "C",001,0 } ) ; AADD(aStru, { "NR_OPER_PR" , "C",010,0 } )
AADD(aStru, { "NR_LI_SUBS" , "C",010,0 } ) ; AADD(aStru, { "CD_ORIGEM"  , "C",001,0 } )
AADD(aStru, { "NR_DECL_IM" , "C",010,0 } ) ; AADD(aStru, { "NR_ADI_IMP" , "C",003,0 } )
AADD(aStru, { "NR_SEQ_RET" , "C",002,0 } ) ; AADD(aStru, { "CD_TIPO_IM" , "C",001,0 } )
AADD(aStru, { "NR_IMPORTA" , "C",014,0 } ) ; AADD(aStru, { "CD_PAIS_IM" , "C",003,0 } )
AADD(aStru, { "NM_IMPORTA" , "C",060,0 } ) ; AADD(aStru, { "NR_TEL_IMP" , "C",015,0 } )
AADD(aStru, { "ED_LOGR_IM" , "C",040,0 } ) ; AADD(aStru, { "ED_NR_IMPO" , "C",006,0 } )
AADD(aStru, { "ED_COMPL_I" , "C",021,0 } ) ; AADD(aStru, { "ED_BA_IMPO" , "C",025,0 } )
AADD(aStru, { "ED_MUN_IMP" , "C",025,0 } ) ; AADD(aStru, { "ED_UF_IMPO" , "C",002,0 } )
AADD(aStru, { "ED_CEP_IMP" , "C",008,0 } ) ; AADD(aStru, { "NR_CPF_REP" , "C",011,0 } )
AADD(aStru, { "CD_MERCADO" , "C",008,0 } ) ; AADD(aStru, { "CD_PAIS_PR" , "C",003,0 } )
AADD(aStru, { "CD_PAIS_OR" , "C",003,0 } ) ; AADD(aStru, { "PL_BEM"     , "C",015,0 } )
AADD(aStru, { "PB_BEM"     , "C",015,0 } ) ; AADD(aStru, { "QT_UN_ESTA" , "C",015,0 } )
AADD(aStru, { "CD_MOEDA_N" , "C",003,0 } ) ; AADD(aStru, { "CD_REGIME"  , "C",001,0 } )
AADD(aStru, { "CD_FUND_LE" , "C",003,0 } ) ; AADD(aStru, { "CD_UL_DESP" , "C",007,0 } )
AADD(aStru, { "IN_REST_DA" , "C",001,0 } ) ; AADD(aStru, { "IN_MATERIA" , "L",001,0 } )
AADD(aStru, { "DT_REG_OPE" , "C",010,0 } ) ; AADD(aStru, { "DT_ATU_OPE" , "C",010,0 } )
AADD(aStru, { "IN_SALVO_D" , "L",001,0 } ) ; AADD(aStru, { "IN_SELECAO" , "L",001,0 } )
AADD(aStru, { "TX_INFO_CO" , "M",010,0 } ) ; AADD(aStru, { "CD_SITUAC_" , "C",002,0 } )
AADD(aStru, { "DT_SITUAC_" , "C",010,0 } ) ; AADD(aStru, { "DT_VALID_O" , "C",010,0 } )
AADD(aStru, { "CD_CANCEL_" , "C",001,0 } ) ; AADD(aStru, { "DT_CANCEL_" , "C",010,0 } )
AADD(aStru, { "NR_CPF_CAN" , "C",011,0 } ) ; AADD(aStru, { "NR_LISUBST" , "C",010,0 } )
AADD(aStru, { "DT_REST_EM" , "C",010,0 } ) ; AADD(aStru, { "QT_MERC_UN" , "C",014,0 } )
AADD(aStru, { "NM_UN_MEDI" , "C",020,0 } ) ; AADD(aStru, { "VL_UNID_LO" , "C",013,0 } )
AADD(aStru, { "TX_DESC_DE" , "M",010,0 } ) ; AADD(aStru, { "NR_DESTAQU" , "C",003,0 } )
AADD(aStru, { "IN_MERCOSU" , "L",001,0 } ) ; AADD(aStru, { "CD_MOTIVO"  , "C",002,0 } )
AADD(aStru, { "CD_NATUREZ" , "C",002,0 } ) ; AADD(aStru, { "NR_EMP_DEC" , "C",014,0 } )
AADD(aStru, { "IN_REPR_SE" , "L",001,0 } ) ; AADD(aStru, { "CD_TIPO_CL" , "C",001,0 } )
AADD(aStru, { "NR_MAT_FUN" , "C",008,0 } ) ; AADD(aStru, { "DT_DESEMB_" , "C",008,0 } )
AADD(aStru, { "CD_MER_TTE" , "C",004,0 } ) ; AADD(aStru, { "WKERRO"     , "M",010,0 } )

AADD(aTBCamposC,{bTipo,,"Tipo"})
FOR S := 2 TO LEN(aStru)
    IF aStru[S,2]="N"
       AADD(aTBCamposC,{aStru[S,1],,aStru[S,1],cPict+IF(aStru[S,4]=0,"","."+REPL("9",aStru[S,4]))})
    ELSE
       AADD(aTBCamposC,{aStru[S,1],,aStru[S,1],})
    ENDIF
Next

// TABELA  : PROCESSO_ANUENTE
aStruP := {}
AADD(aStruP, { "TIPO_MANUT", "C",001,0 } )
AADD(aStruP, { "NR_TRAT_IM", "C",015,0 } )
AADD(aStruP, { "NR_PROC_AN", "C",020,0 } )
AADD(aStruP, { "SG_ORG_PRO", "C",010,0 } )
AADD(aStrup, { "WKERRO"    , "M",010,0 } )

AADD(aTBCamposP,{bTipo,,"Tipo"})
FOR S := 2 TO LEN(aStruP)
    IF aStruP[S,2]="N"
       AADD(aTBCamposP,{aStruP[S,1],,aStruP[S,1],cPict+IF(aStruP[S,4]=0,"","."+REPL("9",aStruP[S,4]))})
    ELSE
       AADD(aTBCamposP,{aStruP[S,1],,aStruP[S,1]})
    ENDIF
Next

IncProc("Criando Arq. Temp. Work_Capa...")
IF SELECT("Work_Capa") # 0
   DbSelectArea("Work_Capa")
   AvZap()
ELSE
   cArqTrabC := E_CriaTrab(,aStru,"Work_Capa",,.F.)
   If !USED()
      Help(" ",1,"E_NAOHAREA")
      Return .F.
   EndIf
EndIf

IncProc("Criando Arq. Temp. Work_PAnu...")
IF SELECT("Work_PAnu") # 0
   DbSelectArea("Work_PAnu")
   AvZap()
ELSE
   cArqTrabP := E_CriaTrab(,aStruP,"Work_PAnu",,.F.)
   If !USED()
      IF SELECT("Work_Capa") # 0
         Work_Capa->(E_EraseArq(cArqTrabC))
      ENDIF

      IF SELECT("Work_PAnu") # 0
         Work_PAnu->(E_EraseArq(cArqTrabP))
      ENDIF

      Help(" ",1,"E_NAOHAREA")
      Return .F.
   EndIf
EndIf

Return .T.

*-----------------------------------*
FUNCTION OR100GrvMDB()
*-----------------------------------*
Local aArrayCampos, aArrayChaves

aArrayCampos :={;
{"NR_TRAT_IMP_MICRO"   ,  "NR_TRAT_IM","",""    } , {"NR_OPER_TRAT_PROT"  ,  "NR_OPER_TR","","NULL"},;
{"CD_AUTORIZ_TRANSM"   ,  "CD_AUTORIZ","","NULL"} , {"NR_OPER_TRAT_PREV"  ,  "NR_OPER_PR","","NULL"},;
{"NR_LI_SUBSTITUIDO"   ,  "NR_LI_SUBS","",""    } , {"CD_ORIGEM_LI"       ,  "CD_ORIGEM" ,"",""    },;
{"NR_DECL_IMP_VINC"    ,  "NR_DECL_IM","",""    } , {"NR_ADI_IMP_VINC"    ,  "NR_ADI_IMP","",""    },;
{"NR_SEQ_RETI_VINC"    ,  "NR_SEQ_RET","",""    } , {"CD_TIPO_IMPORTADOR" ,  "CD_TIPO_IM","",""    },;
{"NR_IMPORTADOR"       ,  "NR_IMPORTA","","NULL"} , {"CD_PAIS_IMPORTADOR" ,  "CD_PAIS_IM","","NULL"},;
{"NM_IMPORTADOR"       ,  "NM_IMPORTA","","NULL"} , {"NR_TEL_IMPORTADOR"  ,  "NR_TEL_IMP","","NULL"},;
{"ED_LOGR_IMPORTADOR"  ,  "ED_LOGR_IM","","NULL"} , {"ED_NR_IMPORTADOR"   ,  "ED_NR_IMPO","","NULL"},;
{"ED_COMPL_IMPO"       ,  "ED_COMPL_I","","NULL"} , {"ED_BA_IMPORTADOR"   ,  "ED_BA_IMPO","","NULL"},;
{"ED_MUN_IMPORTADOR"   ,  "ED_MUN_IMP","","NULL"} , {"ED_UF_IMPORTADOR"   ,  "ED_UF_IMPO","","NULL"},;
{"ED_CEP_IMPORTADOR"   ,  "ED_CEP_IMP","","NULL"} , {"NR_CPF_REPR_LEGAL"  ,  "NR_CPF_REP","","NULL"},;
{"CD_MERCADORIA_NCM"   ,  "CD_MERCADO","",""    } , {"CD_PAIS_PROC_CARGA" ,  "CD_PAIS_PR","",""    },;
{"CD_PAIS_ORIG_MERC"   ,  "CD_PAIS_OR","",""    } , {"PL_BEM"             ,  "PL_BEM"    ,"",""    },;
{"PB_BEM"              ,  "PB_BEM"    ,"",""    } , {"QT_UN_ESTATISTICA"  ,  "QT_UN_ESTA","",""    },;
{"CD_MOEDA_NEGOCIADA"  ,  "CD_MOEDA_N","",""    } , {"CD_REGIME_TRIBUTAR" ,  "CD_REGIME" ,"",""    },;
{"CD_FUND_LEG_REGIME"  ,  "CD_FUND_LE","",""    } , {"CD_UL_DESPACHO"     ,  "CD_UL_DESP","",""    },;
{"IN_REST_DATA_EMB_LI" ,  "IN_REST_DA","",""    } , {"IN_MATERIAL_USADO"  ,  "IN_MATERIA","",""    },;
{"DT_REG_OPER_TRAT"    ,  "DT_REG_OPE","","NULL"} , {"DT_ATU_OPER_MICRO"  ,  "DT_ATU_OPE","",""    },;
{"IN_SALVO_DIAG"       ,  "IN_SALVO_D","",""    } , {"IN_SELECAO_DIAG"    ,  "IN_SELECAO","",""    },;
{"TX_INFO_COMPL"       ,  "TX_INFO_CO","",""    } , {"CD_SITUAC_OP_TRAT"  ,  "CD_SITUAC_","",""    },;
{"DT_SITUAC_OP_TRAT"   ,  "DT_SITUAC_","",""    } , {"DT_VALID_OP_TRAT"   ,  "DT_VALID_O","",""    },;
{"CD_CANCEL_OP_TRAT"   ,  "CD_CANCEL_","",""    } , {"DT_CANCEL_OP_TRAT"  ,  "DT_CANCEL_","",""    },;
{"NR_CPF_CANC_ANUENC"  ,  "NR_CPF_CAN","",""    } , {"NR_LI_SUBSTITUTIVO" ,  "NR_LISUBST","",""    },;
{"DT_REST_EMB"         ,  "DT_REST_EM","",""    } , {"QT_MERC_UN_COMERC"  ,  "QT_MERC_UN","",""    },;
{"NM_UN_MEDID_COMER"   ,  "NM_UN_MEDI","",""    } , {"VL_UNID_LOC_EMB"    ,  "VL_UNID_LO","",""    },;
{"TX_DESC_DET_MERC"    ,  "TX_DESC_DE","",""    } , {"NR_DESTAQUE_NCM"    ,  "NR_DESTAQU","",""    },;
{"IN_MERCOSUL"         ,  "IN_MERCOSU","",""    } , {"CD_MOTIVO_FUND_LEG" ,  "CD_MOTIVO" ,"",""    },;
{"CD_NATUREZA_OP"      ,  "CD_NATUREZ","",""    } , {"NR_EMP_DECLARANTE"  ,  "NR_EMP_DEC","",""    },;
{"IN_REPR_SERVIDOR"    ,  "IN_REPR_SE","",""    } , {"CD_TIPO_CLASS"      ,  "CD_TIPO_CL","",""    },;
{"NR_MAT_FUNC_MRE"     ,  "NR_MAT_FUN","",""    } , {"DT_DESEMB_MRE"      ,  "DT_DESEMB_","",""    },;
{"CD_MERCADORIA_TTE"   ,  "CD_MER_TTE","",""    } }

aArrayChaves := { { "NR_TRAT_IMP_MICRO", "NR_TRAT_IM", "", "" } }

cMenErro:="B) Erros na Gravacao da capa da LSI: "+ENTER

oDlgProc:SetText("Gravando dados da LSI...")

OR100DLLSQL("OPERAÇÃO_COM_TRATAMENTO","WORK_CAPA","TIPO_MANUT","I",aArrayCampos,aArrayChaves,cMenErro)

aArrayCampos :={;
{"NR_TRAT_IMP_MICRO"  ,  "NR_TRAT_IM", "", "" },;
{"NR_PROC_ANUENTE"    ,  "NR_PROC_AN", "", "" },;
{"SG_ORG_PROC_ANUENT" ,  "SG_ORG_PRO", "", "" }}

aArrayChaves := {;
{ "NR_TRAT_IMP_MICRO", "NR_TRAT_IM", "", "" }}

cMenErro:="C) Erros na Gravacao dos Proc.Anuentes da LSI: "+ENTER

oDlgProc:SetText("Gravando proc.anuentes da LSI...")

OR100DLLSQL("PROCESSO_ANUENTE","Work_PAnu","TIPO_MANUT","I",aArrayCampos,aArrayChaves,cMenErro)

RETURN .T.

*--------------------------------------------------------------------------------------------------------------------*
FUNCTION OR100DLLSQL(cTabela,cAlias,cCampoTp,cTipo,aArrayCampos,aArrayChaves,cMenErro,lProc)
*--------------------------------------------------------------------------------------------------------------------*
Local nCont, aEicdll := {}, aMensLog := {}, lMensTela := .F.
DEFAULT lProc := .T.
//INCLUSAO
Aadd(aEicdll,{IF(cTipo="I","I"," "),cTabela,aArrayCampos,aArrayChaves})
//ALTERACAO
Aadd(aEicdll,{IF(cTipo="A","A"," "),cTabela,aArrayCampos,aArrayChaves})
//EXCLUSAO
Aadd(aEicdll,{IF(cTipo="E","E"," "),cTabela,aArrayCampos,aArrayChaves})

EICDLLSQL(cODBC_LSI,aEicdll,cCampoTp,aMensLog,cAlias,"WKERRO",lProc,lMensTela)

If !Empty(aMenslog)
    cErro+=cMenErro
    For nCont = 1 To Len(aMenslog)
        cErro += aMensLog[nCont]+ENTER
	Next
    cErro+=ENTER
EndIf

RETURN .T.

/*
Função      : OR100Comag()
Objetivo    : Ao invés de utilizar o campo WB_COMAG como valor da comissão do principal, deve utilizar o valor
              do registro de Comissão, vinculada a invoice e com a mesma data de vencimento.
Parametro   : -
Retorno     : Numérico. Valor da comissão.
Autor       : GFC - Gustavo Fabro da Costa Carreiro
Data        : 12/2005.
*/
*-----------------------------------------------------------------------------------------------------*
Static Function OR100Comag()
*-----------------------------------------------------------------------------------------------------*
Local nValComag:=0, nRecWB:=SWB->(RecNo()), dDtVenc:=SWB->WB_DT_VEN, nOrdWB:=SWB->(IndexOrd())
Local cHawb:=SWB->WB_HAWB, cPo_Di:=SWB->WB_PO_DI, cInvoice:=SWB->WB_INVOICE, cForn:=SWB->WB_FORN, cForLoj:= SWB->WB_LOJA

SWB->(dbSetOrder(1))
SWB->(dbSeek(xFilial("SWB")+cHawb+cPo_Di+cInvoice+cForn+cForLoj))
Do While !SWB->(EOF()) .and. SWB->WB_FILIAL==xFilial("SWB") .and. cHawb==SWB->WB_HAWB .and.;
cPo_Di==SWB->WB_PO_DI .and. cInvoice==SWB->WB_INVOICE .and. cForn==SWB->WB_FORN .and. IIF(EICLoja(),cForLoj==SWB->WB_LOJA,.T.)
   If Left(SWB->WB_TIPOREG,1) == "C" .and. SWB->WB_DT_VEN == dDtVenc
      nValComag += SWB->WB_FOBMOE
   EndIf
   SWB->(dbSkip())
EndDo
SWB->(dbSetOrder(nOrdWB))
SWB->(dbGoTo(nRecWB))

Return If(nValComag=0, SWB->WB_COMAG, nValComag)

/*
Funcao      : Ori100valid()
Parametros  : lTodos - Se a Validação está sendo executada para 1 ou vários registros
Retorno     : lRet
Objetivos   : Retornar se o Pedido de Licença está apto a ser marcado para envio
              ao SISCOMEX.
Autor       : Nilson Cesar
Data/Hora   : 26/09/2011 - 11:50 hs
Revisao     :
Obs.        :
*/
*--------------------------------*
Function Ori100Valid(lTodos)
*--------------------------------*
Local lRet := .T.
Local aOrdSW := SaveOrd({"SWP","SW2","SW4","SW5"})
Local cIncoterm

If TOpcao == ENVIA_ORIENTADOR .AND. cFase == FASE_PO

   SW5->(DBSETORDER(7))
   SW5->(DBSEEK(xFilial()+TRB->WP_PGI_NUM+TRB->WP_SEQ_LI))
   SW2->(DBSEEK(xFilial()+SW5->W5_PO_NUM))
   SW4->(DBSEEK(xFilial()+TRB->WP_PGI_NUM))
   cIncoterm := IF(!EMPTY(SW4->W4_INCOTER),AllTrim(SW4->W4_INCOTER),Alltrim(SW2->W2_INCOTER))

   IF cIncoterm $ 'DEQ/DDU/DAF/DES'
      If lTodos
         lExibeMsg := .T.
      Else
         MsgAlert(STR0216+CHR(13)+CHR(10)+STR0217+CHR(13)+CHR(10)+STR0218,"AVISO")
      EndIf
      lRet := .F.
   EndIf

   RestOrd(aOrdSW,.T.)

Endif

Return lRet

/*
Funcao      : MontaNVE()
Parametros  : cAlias - Alias do Arquivo onde será resgatada as informações das NVES
Retorno     : (Nenhum)
Objetivos   : Montar as Informações de NVE no arquivo txt de envio
Autor       : Bruno Colisse
Data/Hora   : 04/10/2012 - 11:50 hs
Revisao     : Nilson César - 09/11/2012
Obs.        : Adicionado tratamento para carregar NVE da PLI
*/
Function MontaNVE(cAlias,lNveFaseDI,lNveFaseLI,lNveFaseCD) 

local cHAWB := "", cProd := ""
Local cTabNVE := ""
Local cCodAtrib := ""
Local cDscAtrib := ""
Local cEspec := ""
Local cNivel := ""
Local cTexto := "" 
Local aSW7TbNVE := {}, aTabNVEImp := {}
Local cPoNum    := ""
Local cTabNVEImp := cTabNVEPos := 0
Default lNveFaseDI := .F. 
Default lNveFaseLI := !lNveFaseDI 
Default lNveFaseCD := .F.

If cAlias == "SW3" .And. lNveFaseCD

   cPoNum := SW2->W2_PO_NUM
   SW3->(DbSetOrder(1))
   EIM->(DbSetOrder(3))
   SW3->(DbSeek( xFilial("SW3")+cPONum ))
   Do While SW3->(!Eof()) .And. SW3->W3_PO_NUM == cPONum
      If SW3->W3_SEQ > 0
         SW3->(DbSkip())
         Loop
      EndIf
      // NCF - 23/05/2018 - Existência de tabela NVE para o item incluso na fase de Cadastro do Produto (CD)
      //MFR 26/11/2018 OSSME-148
      If EIM->(DbSeek( GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(SW3->W3_COD_I,"EIM_HAWB"))) .And. EIM->EIM_NCM == SW3->W3_TEC .And. aScan(aTabNVEImp,{|x| x ==  EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO)  }) == 0
         aAdd(aTabNVEImp,EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO))
         //MFR 26/11/2018 OSSME-1483
         cKeyWhile :=GetFilEIM("CD") + AvKey("CD","EIM_FASE") + AVKEY(SW3->W3_COD_I,"EIM_HAWB") + EIM->EIM_CODIGO
         cProd  := SW3->W3_COD_I
         GeraGiplit(cKeyWhile, EIM->(EIM_CODIGO), cProd) 
      EndIf
      SW3->(DbSkip())
   EndDo

ElseIf cAlias == "SW7"

   cHawb := SW6->W6_HAWB
   SW7->(DbSetOrder(4))
   SW5->(DbSetOrder(7))
   SW7->(dbGoTop())
   SW7->(dbSeek(xFilial("SW7") + AvKey(cHawb,"W7_HAWB")))
   Do While SW7->W7_HAWB == AvKey(cHawb,"W7_HAWB")
      SW5->(DbSeek( xFilial("SW5") + SW7->W7_PGI_NUM + SW7->W7_SEQ_LI + STR(SW7->W7_SEQ,2,0) + SW7->W7_COD_I )) 
      // NCF - 23/05/2018 - Existência de tabela NVE para o item incluso na fase de Licença de Importação (LI)
      if !empty(SW5->W5_NVE) .And. lNveFaseLI    
         //cTabNVE :=  alltrim(SW5->W5_NVE)
         If ( nPosTbFNVE := aScan(aFaseNVE[4], {|x| x[1] ==   SW5->(W5_FILIAL+W5_PGI_NUM+W5_NVE) } ) ) > 0
            cTabNVEImp := aFaseNVE[4][nPosTbFNVE][3]
            cTabNVEPos := aFaseNVE[4][nPosTbFNVE][2]
         EndIf 

         EIM->(DbSetOrder(3))
        
       
        //mfr ossme-2227 20/02/201
        EIM->(DbSeek(xFilial("EIM") + AvKey("LI","EIM_FASE") + AVKEY(SW5->W5_PGI_NUM,"EIM_HAWB") + AVKEY(cTabNVEPos,"EIM_CODIGO")))
       

         If aScan(aTabNVEImp,{|x| x ==  EIM->(EIM_FILIAL + EIM_FASE + EIM_HAWB + EIM_CODIGO)  }) == 0          
            aAdd(aTabNVEImp,EIM->(EIM_FILIAL + EIM_FASE + EIM_HAWB + EIM_CODIGO))            
            cKeyWhile := xFilial("EIM") + AvKey("LI","EIM_FASE") + AVKEY(SW5->W5_PGI_NUM,"EIM_HAWB") + AVKEY(SW5->W5_NVE,"EIM_CODIGO")    
            cProd := SW5->W5_COD_I   
            GeraGiplit(cKeyWhile, cTabNVEImp, cProd)  
         EndIf
      // NCF - 23/05/2018 - Existência de tabela NVE para o item incluso na fase de Cadastro do Produto (CD)    
      ElseIf lNVEProduto .And. lNveFaseCD  
         EIM->(DbSetOrder(3))  
         //MFR 26/11/2018 OSSME-1483    
         If EIM->(DbSeek(GetFilEIM("CD") + AvKey("CD","EIM_FASE") + AvKey(SW7->W7_COD_I,"EIM_HAWB"))) .And. EIM->EIM_NCM == SW7->W7_NCM .And. aScan(aTabNVEImp,{|x| x ==  EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO)  }) == 0 
            aAdd(aTabNVEImp,EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO))
             //MFR 26/11/2018 OSSME-1483    
            //cKeyWhile := xFilial("EIM") + AvKey("CD","EIM_FASE") + AVKEY(SW7->W7_COD_I,"EIM_HAWB") + EIM->EIM_CODIGO
            cKeyWhile :=GetFilEIM("CD")  + AvKey("CD","EIM_FASE") + AVKEY(SW7->W7_COD_I,"EIM_HAWB") + EIM->EIM_CODIGO
            //MFR OSSME-2227 19/02/2019
            //cProd  := SW3->W3_COD_I
            cProd  := SW7->W7_COD_I

            If ( nPosTbFNVE := aScan(aFaseNVE[4], {|x| x[1] ==   EIM->(EIM_FILIAL + EIM_HAWB + EIM_NCM + EIM_CODIGO) } ) ) > 0
               cTabNVEImp := aFaseNVE[4][nPosTbFNVE][3]
               cTabNVEPos := aFaseNVE[4][nPosTbFNVE][2]
            EndIf 
            GeraGiplit(cKeyWhile, cTabNVEImp, cProd)         
         EndIf
      EndIf
   
      SW7->(DbSkip())  
   EndDo  
      
ElseIf cAlias == "SW8"

   cHawb := alltrim(SW6->W6_HAWB)
   SW8->(DbSetOrder(1))
   SW8->(dbGoTop())
   SW8->(dbSeek(xFilial("SW8") + AvKey(cHAWB,"W8_HAWB")))
   Do While SW8->W8_HAWB == AvKey(cHAWB,"W8_HAWB")
      // NCF - 23/05/2018 - Existência de tabela NVE para o item incluso na fase de Desembaraço (DI)
      if !empty(SW8->W8_NVE)
         cTabNVE :=  alltrim(SW8->W8_NVE)
         EIM->(DbSetOrder(3))
         //MFR 26/11/2018 OSSME-1483
         
          cKeyWhile := GetFilEIM("DI") +AvKey("DI","EIM_FASE") + AVKEY(SW8->W8_HAWB,"EIM_HAWB") + AVKEY(cTabNVE,"EIM_CODIGO")
         if !EIM->(DbSeek(GetFilEIM("DI") +AvKey("DI","EIM_FASE") + AVKEY(SW8->W8_HAWB,"EIM_HAWB") + AVKEY(cTabNVE,"EIM_CODIGO")))
            EIM->(DbSeek(GetFilEIM("DI") +AvKey("","EIM_FASE") + AVKEY(SW8->W8_HAWB,"EIM_HAWB") + AVKEY(cTabNVE,"EIM_CODIGO")))
            cKeyWhile := GetFilEIM("DI") +AvKey("","EIM_FASE") + AVKEY(SW8->W8_HAWB,"EIM_HAWB") + AVKEY(cTabNVE,"EIM_CODIGO")
         endIf
        
         //MFR OSSME-2227 19/02/2019
         cProd := SW8->W8_COD_I
         GeraGiplit(cKeyWhile, EIM->(EIM_CODIGO), cProd)
                  // NCF - 23/05/2018 - Existência de tabela NVE para o item incluso na fase de Licença de Importação (LI)  
      ElseIf lNveFaseLI
         SW7->(DbSetOrder(4))
         SW7->(DbSeek( xFilial("SW7") + SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM) ))
         SW5->(DbSetOrder(7))
         SW5->(DbSeek( xFilial("SW5") + SW7->W7_PGI_NUM + SW7->W7_SEQ_LI + STR(SW7->W7_SEQ,2,0) + SW7->W7_COD_I ))
         If( (nPosW7Arr := aScan(aSW7TbNVE,SW7->(REcno()))) == 0 , aAdd(aSW7TbNVE,SW7->(REcno())) , )
         if !empty(SW5->W5_NVE) .And. nPosW7Arr == 0
            //cTabNVE :=  alltrim(SW5->W5_NVE)

            If ( nPosTbFNVE := aScan(aFaseNVE[4], {|x| x[1] ==   SW5->(W5_FILIAL+W5_PGI_NUM+W5_NVE) } ) ) > 0
               cTabNVEImp := aFaseNVE[4][nPosTbFNVE][3]
               cTabNVEPos := aFaseNVE[4][nPosTbFNVE][2]
            EndIf 

            EIM->(DbSetOrder(3))
             
            EIM->(DbSeek(GetFilEIM("LI") + AvKey("LI","EIM_FASE") + AVKEY(SW5->W5_PGI_NUM,"EIM_HAWB") + AVKEY(cTabNVEPos,"EIM_CODIGO")))
                 
            

            If aScan(aTabNVEImp,{|x| x ==  EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO)  }) == 0
               aAdd(aTabNVEImp,EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO))  
                //MFR OSSME-2227 19/02/2019 VERIFICAR  está usansdo LI mas pode ser DI         
               cKeyWhile := xFilial("EIM") + AvKey("LI","EIM_FASE") + AVKEY(SW5->W5_PGI_NUM,"EIM_HAWB") + AVKEY(SW5->W5_NVE,"EIM_CODIGO")
               cProd := SW5->W5_COD_I
               GeraGiplit(cKeyWhile, cTabNVEImp, cProd)
               
            EndIf
         // NCF - 23/05/2018 - Existência de tabela NVE para o item incluso na fase de Cadastro do Produto (CD)      
         ElseIf lNVEProduto .And. lNveFaseCD
            EIM->(DbSetOrder(3))   
            //MFR 26/11/2018 OSSME-1483   
           
            If EIM->(DbSeek(GetFilEIM("CD") + AvKey("CD","EIM_FASE") + AvKey(SW7->W7_COD_I,"EIM_HAWB"))) .And. EIM->EIM_NCM == SW7->W7_NCM .And. aScan(aTabNVEImp,{|x| x ==  EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO)  }) == 0 
               aAdd(aTabNVEImp,EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO)) 
               //MFR 26/11/2018 OSSME-1483   
               cKeyWhile := GetFilEIM("CD") + AvKey("CD","EIM_FASE") + AVKEY(SW7->W7_COD_I,"EIM_HAWB") + EIM->EIM_CODIGO
               //MFR OSSME-2227 19/02/2019
               //cProd  := SW3->W3_COD_I
               cProd  := SW7->W7_COD_I

               If ( nPosTbFNVE := aScan(aFaseNVE[4], {|x| x[1] ==   EIM->(EIM_FILIAL + EIM_HAWB + EIM_NCM + EIM_CODIGO) } ) ) > 0
                  cTabNVEImp := aFaseNVE[4][nPosTbFNVE][3]
                  cTabNVEPos := aFaseNVE[4][nPosTbFNVE][2]
               EndIf 
               //MFR OSSME-2227 20/02/2019
               GeraGiplit(cKeyWhile, cTabNVEImp, cProd)
            EndIf
         EndIf
      EndIf  
      SW8->(DbSkip())  
   EndDo
   aSW7TbNVE := {}
   aTabNVEImp:= {}  
EndIf

Return

/*
Funcao      : GeraGiplit()
Parametros  : cKeyWhile - valor com o qual  o do whiel será comparado
            : cTabNVEImp - valor do nve
            : cPRod - codigo do produto
Retorno     : Sem retorno
Objetivos   : Gerar o tipo NVAE no arquivo do despachante
Autor       : Maurício Frison
Data/Hora   : 20/02/2019 
Revisao     : 
Obs.        : 
*/
function GeraGiplit(cKeyWhile, cTabNVEImp, cProd)
Do while EIM->(!EOF()) .AND. EIM->(EIM_FILIAL + EIM->EIM_FASE + EIM->EIM_HAWB + EIM_CODIGO) == cKeyWhile
    cTexto := ""
    cCodAtrib := alltrim(EIM->(EIM_ATRIB))
    cDscAtrib := alltrim(EIM->(EIM_DES_AT))
    cEspec    := alltrim(EIM->(EIM_DES_ES))
    Do Case 
      Case (EIM->(EIM_NIVEL) == "1");  cNivel := "C-Capitulo" // BCO - Decide o nivel da NVE
      Case (EIM->(EIM_NIVEL) == "2");  cNivel := "P-Posicao" 
      Case (EIM->(EIM_NIVEL) == "3");  cNivel := "U-SubItem"  
      Case (EIM->(EIM_NIVEL) == "4");  cNivel := "AS-SubPosicao Nivel 1" 
      Case (EIM->(EIM_NIVEL) == "5");  cNivel := "BS-SubPosicao Nivel 2" 
    EndCase 
    cTexto := Space(350)  
    cTexto := Stuff(cTexto, 01,04,"NVAE")
	cTexto := Stuff(cTexto, 05,15,cProd)
	cTexto := Stuff(cTexto, 20,3,cTabNVEImp)
    cTexto := Stuff(cTexto, 24,25,EIM->(EIM_NIVEL) + " " + cNivel)
    cTexto := Stuff(cTexto, 50,40,cDscAtrib)
    cTexto := Stuff(cTexto, 91,40,cEspec)
    If ExistBlock("EICOR100")
       ExecBlock("EICOR100",.F.,.F.,"DESC_IT_NVE")
    Endif     
         
    EIM->(DbSkip())
    Gip_Lite->(DBAPPEND())
    Gip_Lite->GIPTEXTO := cTexto   
EndDo
Return

/*
Funcao      : OR100PqNVE()
Parametros  : cFase  - Fase na qual será verificada a existência de dados na tabela:
                          DI - Itens da Invoice com Classif. NVE informada após invoice
                          LI - Itens do Embarque com Classif. NVE informada na fase PLI
                          PO - Itens do embarque com Classif. NVE informada no cadastro de Produtos
                          CD - Itens do Purchase Order com Classif. NVE informada no Cad. Produtos
              cHawb  - Código do Processo de Embarque(cFase DI/LI/PO) ou Purchase Order(cFase CD)
              lMsg   - Define se será exibida as mensagens de aviso
Retorno     : lTemTabNVE - Define se existe informações de NVE para os itens do processo
Objetivos   : Retornar se existem informações de NVE para os itens do processo  
Autor       : Nilson César
Data/Hora   : 25/05/2018 - 10:00 hrs
Revisao     : 
Obs.        : 
*/
Function OR100PqNVE(cFase,cHawb,lMsg)

Local lTemTabNVE := .F.
Local nOldArea   := 0
Local cQuery     := ""
Local aPergs     := {}
Local cTitRel    := "Relatório de envio p/ despachante"

aAdd(aPergs,{"DI", "Existem itens do Embarque com Invoice que possuem N.V.A.E em suas N.c.m classificadas. Deseja imprimir estas informações no relatório?" })
aAdd(aPergs,{"LI", "Existem itens do Embarque que possuem N.V.A.E em suas N.c.m classificadas na fase de Pedido de Licença da Importação (PLI). Deseja imprimir estas informações no relatório?" })
aAdd(aPergs,{"CD", "Existem itens do Embarque que possuem N.V.A.E em suas N.c.m classificadas na fase de Cadastro do Produto. Deseja imprimir estas informações no relatório?" })

If cFase == "DI"

   cQuery += "SELECT SW8.W8_FILIAL,SW8.W8_HAWB,SW8.W8_INVOICE,SW8.W8_PO_NUM,SW8.W8_POSICAO,SW8.W8_PGI_NUM,SW8.W8_NVE"
   cQuery += " FROM "+RetSqlName("SW7")+" SW7"       
   cQuery += " INNER JOIN "+RetSqlName("SW8")+" SW8" 
   cQuery += " ON  SW8.W8_FILIAL  = SW7.W7_FILIAL"   
   cQuery += " AND SW8.W8_HAWB    = SW7.W7_HAWB"     
   cQuery += " AND SW8.W8_COD_I   = SW7.W7_COD_I"    
   cQuery += " AND SW8.W8_PGI_NUM = SW7.W7_PGI_NUM"  
   cQuery += " AND SW8.W8_SI_NUM  = SW7.W7_SI_NUM"   
   cQuery += " AND SW8.W8_CC      = SW7.W7_CC"       
   cQuery += " AND SW8.W8_REG     = SW7.W7_REG"      
   cQuery += " AND SW8.W8_PO_NUM  = SW7.W7_PO_NUM"   
   cQuery += " AND SW8.W8_NVE     <> ''"             
   cQuery += " AND SW8.D_E_L_E_T_ = ' '"             
   cQuery += " AND SW7.D_E_L_E_T_ = ' '"             
   cQuery += " AND SW7.W7_HAWB = '"+AvKey(cHawb,"W7_HAWB")+"'"

ElseIf cFase == "LI"

   cQuery += "SELECT SW5.W5_FILIAL,SW5.W5_PGI_NUM,SW5.W5_PO_NUM,SW5.W5_POSICAO,SW5.W5_NVE"
   cQuery += " FROM "+RetSqlName("SW7")+" SW7"           
   cQuery += " INNER JOIN "+RetSqlName("SW5")+" SW5"     
   cQuery += " ON  SW5.W5_FILIAL  = SW7.W7_FILIAL"       
   cQuery += " AND SW5.W5_PGI_NUM = SW7.W7_PGI_NUM"      
   cQuery += " AND SW5.W5_PO_NUM  = SW7.W7_PO_NUM"       
   cQuery += " AND SW5.W5_POSICAO = SW7.W7_POSICAO"      
   cQuery += " AND SW5.W5_NVE     <> ''"                 
   cQuery += " AND SW5.D_E_L_E_T_ = ' '"                 
   cQuery += " AND SW7.D_E_L_E_T_ = ' '"                 
   cQuery += " AND SW7.W7_HAWB = '"+AvKey(cHawb,"W7_HAWB")+"'"

ElseIf cFase == "PO"

   cQuery += "SELECT EIM.EIM_FILIAL,EIM.EIM_HAWB,EIM.EIM_FASE,EIM.EIM_NIVEL,EIM.EIM_CODIGO"
   IF lNVEProduto //LRS - 22/08/2018
      cQuery += ",EIM.EIM_NCM"
   EndIF
   cQuery += " FROM(SELECT SW3.W3_FILIAL,SW3.W3_PGI_NUM,SW3.W3_PO_NUM,SW3.W3_POSICAO,SW3.W3_COD_I,SW3.W3_TEC,SW3.D_E_L_E_T_,SW7.W7_NCM"
   cQuery += "     FROM "+RetSqlName("SW7")+" SW7"
   cQuery += "     INNER JOIN "+RetSqlName("SW3")+" SW3"
   cQuery += "     ON  SW3.W3_FILIAL  = SW7.W7_FILIAL"
   cQuery += "     AND SW3.W3_PGI_NUM = SW7.W7_PGI_NUM"
   cQuery += "     AND SW3.W3_PO_NUM  = SW7.W7_PO_NUM"
   cQuery += "     AND SW3.W3_POSICAO = SW7.W7_POSICAO"
   cQuery += "     AND SW3.W3_COD_I   = SW7.W7_COD_I"
   cQuery += "     AND SW3.D_E_L_E_T_ = ' '"
   cQuery += "     AND SW7.D_E_L_E_T_ = ' '"
   cQuery += "     AND SW7.W7_HAWB = '"+AvKey(cHawb,"W7_HAWB")+"') SW3B"
   cQuery += " INNER JOIN "+RetSqlName("EIM")+" EIM"
   //MFR 26/11/2018 OSSME-1483
   //cQuery += " ON  EIM.EIM_FILIAL  = '"+xFilial("EIM")+"'"
   cQuery += " ON  EIM.EIM_FILIAL  = '"+GetFilEIM("CD")+"'"
   cQuery += " AND EIM.EIM_HAWB    = SW3B.W3_COD_I"
   cQuery += " AND EIM.EIM_FASE    = 'CD'"
   IF lNVEProduto //LRS - 22/08/2018
      cQuery += " AND EIM.EIM_NCM     = SW3B.W7_NCM"
   EndIF
   cQuery += " AND EIM.EIM_CODIGO  <> ''"
   cQuery += " AND EIM.D_E_L_E_T_ = ' '"
   cQuery += " AND SW3B.D_E_L_E_T_ = ' '"

ElseIf cFase == "CD"

   cQuery += "SELECT EIM.EIM_FILIAL,EIM.EIM_HAWB,EIM.EIM_FASE,EIM.EIM_NIVEL,EIM.EIM_CODIGO"
   IF lNVEProduto
      cQuery += ",EIM.EIM_NCM"
   EndIF
   cQuery += " FROM "+RetSqlName("SW3")+" SW3"
   cQuery += " INNER JOIN "+RetSqlName("EIM")+" EIM"
   //MFR 26/11/2018 OSSME-1483
   //cQuery += " ON  EIM.EIM_FILIAL  = '"+xFilial("EIM")+"'"
   cQuery += " ON  EIM.EIM_FILIAL  = '"+GetFilEIM("CD")+"'"
   cQuery += " AND EIM.EIM_HAWB    = SW3.W3_COD_I"
   cQuery += " AND EIM.EIM_FASE    = 'CD'"
   IF lNVEProduto //LRS - 22/08/2018
      cQuery += " AND EIM.EIM_NCM     = SW3.W3_TEC"
   EndIF
   cQuery += " AND EIM.EIM_CODIGO  <> ''"
   cQuery += " AND EIM.D_E_L_E_T_ = ' '"
   cQuery += " AND SW3.D_E_L_E_T_ = ' '"
   cQuery += " AND SW3.W3_PO_NUM = '"+AvKey(cHawb,"W3_PO_NUM")+"'"

EndIf

   nOldArea:=SELECT()
   If select("TABNVEFASE") > 0
      TABNVEFASE->(dbClosearea())
   EndIf
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "TABNVEFASE" NEW

   lTemTabNVE := TABNVEFASE->(!Eof()) .And. TABNVEFASE->(!Bof())

   If lMsg
      lTemTabNVE := If( cFase=="DI", MsgYesNo(aPergs[aScan(aPergs,{|x| x[1]=="DI"})][2],cTitRel) ,  If( cFase=="LI", MsgYesNo(aPergs[aScan(aPergs,{|x| x[1]=="LI"})][2],cTitRel) ,  MsgYesNo(aPergs[aScan(aPergs,{|x| x[1]=="CD"})][2],cTitRel)  )  )
   EndIf

   If lTemTabNVE
      aFaseNVE := { cFase == "DI" , cFase == "LI" , cFase $ "PO|CD", {} }
      MontTabChv(cFase,lTemTabNVE) 
   EndIf

   TABNVEFASE->(dbClosearea())
   DBSELECTAREA(nOldArea)

Return lTemTabNVE


/*
Funcao      : OR100TBNVE()
Parametros  : cFase - Fase de geração do arquivo (1-PO, 2-DI)
Retorno     : cTabNVE - Código da tabela NVE caso exista em uma das fases (DI,PO ou Cad.Prod)
Objetivos   : Retornar o código da tabela NVE para o item do processo 
Autor       : Nilson César
Data/Hora   : 23/05/2018 - 10:00 hrs
Revisao     : 
Obs.        : 
*/
Static Function OR100TBNVE(cFase)

Local cTabNVE := ""
Local aOrdTab := SaveOrd({"SW7","SW5","EIM"})
Local nPosTbFNVE
Default cFase := FASE_DI

If cFase == FASE_PO
   If lCposNVEPLI .And. lNVEProduto
      EIM->(DbSetOrder(3))
      //MFR 26/11/2018 OSSME-1483
      //If EIM->(DbSeek( xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(SW3->W3_COD_I,"EIM_HAWB"))) .And. EIM->EIM_NCM == SW3->W3_TEC
      If EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(SW3->W3_COD_I,"EIM_HAWB"))) .And. EIM->EIM_NCM == SW3->W3_TEC
         cTabNVE := EIM->EIM_CODIGO
      EndIf
   EndIf
ElseIf cFase == FASE_DI
   If aFaseNve[1] .And. SW8->(!Eof()) .And. SW7->(W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM) == SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)
      cTabNVE := SW8->W8_NVE
   EndIf

   If aFaseNve[2] .And. Empty(cTabNVE) .And. lCposNVEPLI
      SW5->(dbSetOrder(7))
      SW5->(DbSeek( xFilial("SW5") + SW7->W7_PGI_NUM + SW7->W7_SEQ_LI + STR(SW7->W7_SEQ,2,0) + SW7->W7_COD_I )) 
      If !Empty(SW5->W5_NVE)
         If ( nPosTbFNVE := aScan(aFaseNVE[4], {|x| x[1] ==   SW5->(W5_FILIAL+W5_PGI_NUM+W5_NVE) } ) ) > 0
            cTabNVE := aFaseNVE[4][nPosTbFNVE][3]
         EndIf 
      EndIf
   EndIf

   If aFaseNve[3] .And. Empty(cTabNVE) .And. lCposNVEPLI .And. lNVEProduto
      EIM->(DbSetOrder(3))
      //MFR 26/11/2018 OSSME-1483
      //If EIM->(DbSeek( xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(SW7->W7_COD_I,"EIM_HAWB"))) .And. EIM->EIM_NCM == SW7->W7_NCM
      If EIM->(DbSeek( GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(SW7->W7_COD_I,"EIM_HAWB"))) .And. EIM->EIM_NCM == SW7->W7_NCM
         If ( nPosTbFNVE := aScan(aFaseNVE[4], {|x| x[1] ==   EIM->(EIM_FILIAL + EIM_HAWB + EIM_NCM + EIM_CODIGO) } ) ) > 0
            cTabNVE := aFaseNVE[4][nPosTbFNVE][3]
         EndIf 
      EndIf
   EndIf
EndIf

RestOrd(aOrdTab,.T.)

Return cTabNVE


/*
Funcao      : MontTabChv(cFase)
Parametros  : cFase - Fase de geração do arquivo (LI ou PO/CD)
Retorno     : Nenhum
Objetivos   : Ordenar numeração de tabelas NVEs repetidas para geração no arq. envio ao despachante
Autor       : Nilson César
Data/Hora   : 28/05/2018 - 10:00 hrs
Revisao     : 
Obs.        : 
*/
Static Function MontTabChv(cFase)

Local nTab := 1
Local bGera := {||}
Local nPos

TABNVEFASE->(DbGoTop())
Do While TABNVEFASE->(!Eof()) 
   If cFase == "LI"
      If( nPos := aScan(aFaseNVE[4], {|x| x[1] == TABNVEFASE->W5_FILIAL + TABNVEFASE->W5_PGI_NUM + TABNVEFASE->W5_NVE } )) == 0
         aAdd( aFaseNVE[4],  { TABNVEFASE->W5_FILIAL + TABNVEFASE->W5_PGI_NUM + TABNVEFASE->W5_NVE , TABNVEFASE->W5_NVE , "" } )
      EndIf
   ElseIf cFase $ "PO|CD" .And. AvFlags("NVE_POR_PRODUTO")
      aAdd(aFaseNVE[4], { TABNVEFASE->EIM_FILIAL + TABNVEFASE->EIM_HAWB + TABNVEFASE->EIM_NCM + TABNVEFASE->EIM_CODIGO , TABNVEFASE->EIM_CODIGO , ""   } )
   EndIf   
   TABNVEFASE->(DbSkip())
EndDo

If !Empty(aFaseNVE[4])
   aSort(aFaseNVE[4] ,,,{|x,y| x[1] < y[1]} )
   nTab := 1
   bGera := {|x| If(  !Empty(x[2]) , x[3] := Alltrim(StrZero(nTab++,AvSx3("EIM_CODIGO",3))) ,   )  }
   aEval(aFaseNVE[4], bGera )
EndIf

Return 
