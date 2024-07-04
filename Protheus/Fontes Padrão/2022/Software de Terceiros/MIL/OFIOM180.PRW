#INCLUDE "ofiom180.ch"
#Include "protheus.ch"
#Include "FileIO.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM180 ³ Autor ³  Emilton              ³ Data ³ 07/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelamento da Liberacao da Ordem de Servico              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ As tratativas das variaveis VOK_INCMOB/VOK_INCTEM estao    ³±±
±±³          ³ desmembradas apenas para documentar e facilitar a analise e³±±
±±³          ³ eventuais implementacoes, caso passe a ser necessario      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM180               

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0003) //"Cancelamento de Liberacao de OS"
Private cKeyAce := ""
Private cMotivo := "000004" 
Private lCancelou
Private cIndex, cChave, cCond

Begin Transaction

   dbSelectArea("VO1")
   cIndex  := CriaTrab(nil,.f.)
   cChave  := IndexKey()
&&   cCond   := 'VO1_STATUS == "A" .or. VO1_STATUS == "D"'
   cCond   := 'VO1_TEMLIB == "S"'
   IndRegua("VO1",cIndex,cChave,,cCond,STR0004) //"Separando OS liberadas"

   mBrowse( 6, 1,22,75,"VO1")

   dbSelectArea("VO1")
   Set Filter to
   RetIndex()
   DbsetOrder(1)
   #IFNDEF TOP
      If File(cIndex+OrdBagExt())
         fErase(cIndex+OrdBagExt())
      Endif
   #ENDIF

End Transaction

Return

*************************************
Function OFIOM180I(cAlias, nReg, nOpc)
*************************************

Local bCampo   := { |nCPO| Field(nCPO) }
Local oSitOsv
Local nCntFor := 0

Private aTELA[0][0], aGETS[0], oDlgCanLib, cTitle
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
        
aRotina := {{STR0001, "AxPesqui",0,1},; //"Pesquisar"
             {STR0002, "OFIOM180I",0,3},; //"Cancelar Lib"
             {STR0002, "OFIOM180I",0,3}} //"Cancelar Lib"

cTitle := STR0003 //"Cancelamento de Liberacao de OS"

nOpc  := 3     && Incluir
nOpcE := 3     && Incluir
nOpcG := 2     && Visualizar

*** Cria Variaveis M->????? da Enchoice ***************************************

//RegToMemory("VO1",.T.)
DbSelectArea("VO1")
For nCntFor := 1 TO FCount()
    &( "M->"+EVAL(bCampo,nCntFor) ) := FieldGet(nCntFor)
Next

dbSelectArea("SX3")
dbSeek("VO1")
aCpoEnchoice := {}

While x3_arquivo == "VO1" .and. !eof()

   if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !(X3_CAMPO $ "VO1_FILIAL/VO1_GETKEY/VO1_CODMOT/VO1_NOMMOT/VO1_DATENT/VO1_HORENT/VO1_STATUS/VO1_TEMGAR/VOI_TEMLIB/VO1_MECREQ/VO1_EXPGAR/VO1_SITGAR/VO1_CODMAR")
      aAdd(aCpoEnchoice,x3_campo)
      
      If x3_context == "V"
	      &( "M->"+x3_campo ) := CriaVar(x3_campo)
	   EndIf   
      
   Endif
   dbSkip()

EndDo

DbSelectArea("VO1")

aSitOsv := {}

If !FS_LEVDIS180()
   return .t.
EndIf

cLinOk     := "AllwaysTrue()"
cTudOOk    := "AllwaysTrue()"
cFieldOk   := "AllwaysTrue()"
nLinhas    := 99
aPos       := { 012,002,123,316 }

dbSelectArea("VO1")
dbSetOrder(1)

DEFINE MSDIALOG oDlgCanLib FROM 001,000 TO 035,080 TITLE cTitle OF oMainWnd

    EnChoice("VO1", nReg, nOpc, , , ,aCpoEnchoice, aPos)

    @ 125,003 LISTBOX oSitOsv FIELDS HEADER OemToAnsi(""),;
                                            OemToAnsi("TT"),; && Tipo de TempoGrupo
                                            OemToAnsi("CodCli"),; && Codigo de Cliente
                                            OemToAnsi(STR0005),; && Nome do Cliente //"Nome do Cliente"
                                            OemToAnsi(STR0006),; && Total de Pecas //"Tt Pecas"
                                            OemToAnsi(STR0007),; && Horas Padrao //"Hrs Padrao"
                                            OemToAnsi(STR0008),; && Horas Padrao //"Hrs Trab."
                                            OemToAnsi(STR0009);  && Total de Servicos //"Tt Srvcs"
    COLSIZES 05,10,25,95,45,35,35,45;
    SIZE 312,131 OF oDlgCanLib ON DBLCLICK If(aSitosv[oSitOsv:nAt,1],aSitOsv[oSitOsv:nAt,1] := .f.,aSitOsv[oSitOsv:nAt,1] := .t.) PIXEL

    oSitOsv:SetArray(aSitOsv)
    oSitOsv:bLine := { || {  If(aSitOsv[oSitOsv:nAt,1],oOk,oNo) ,;                   
                                  aSitOsv[oSitOsv:nAt,2] ,;
                                  aSitOsv[oSitOsv:nAt,3] ,;
                                  aSitOsv[oSitOsv:nAt,4] ,;
                                  Transform(aSitOsv[oSitOsv:nAt,5],"@ez 999,999,999.99") ,;
                                  aSitOsv[oSitOsv:nAt,6] ,;
                                  aSitOsv[oSitOsv:nAt,7] ,;
                                  aSitOsv[oSitOsv:nAt,8]}}
                                                                        && Quando clicar em OK              Quando Clicar no Chizim
&& ACTIVATE MSDIALOG oDlgCanLib CENTER ON INIT (FS_CHBAR180(oDlgCanLib,{|| nOpca := 1,oDlgCanLib:End()},{|| nOpca := 0,oDlgCanLib:End()}))


ACTIVATE MSDIALOG oDlgCanLib CENTER ON INIT (FS_CHBAR180(oDlgCanLib,{|| nOpca := 1,If(FS_LIBDIS(),oDlgCanLib:End(),nOpca := 0)},{|| nOpca := 0,oDlgCanLib:End()}))

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHBAR180 ³ Autor ³ Fabio                 ³ Data ³ 12/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_CHBAR180(oDlg,bOk,bCancel)

Local oBar, bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0010)  // //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0011)  // //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0012)  // //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP OemToAnsi(STR0013)  // //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION Agenda()      TOOLTIP OemToAnsi(STR0014)  // //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()    TOOLTIP OemToAnsi(STR0015)  //"Gerenciador de ImpressÆo..." //"Gerenciador de Impressao..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar       ACTION HelProg()     TOOLTIP OemToAnsi(STR0016)  // //"Help de Programa..."

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "Ok" OF oBar GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0017  //###"Ok - <Ctrl-O>" //"Ok - <Ctl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "Cancel" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP STR0018  //### //"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan:bAction)

oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}

Return nil

Static Function ButtonOff(bSet6,bSet15,bSet24,lOk)

DEFAULT lOk := .t.

IF lOk
    SetKey(6,bSet6)
    SetKey(15,bSet15)
    SetKey(24,bSet24)
Endif

Return .t.

FUNCTION FS_LEVDIS180()
***********************

Local cTTpAnt := ""
Local nTotPec := 0
Local nHorPad := 0
Local nHorTra := 0
Local nValPec := 0
Local nTotSrv := 0
Local nTotTTp := 0
Local ix1     := 0
Local aCodSer := {}
Local aTpoTra := {}

dbSelectArea("VO2")

If FG_SEEK("VO2","VO1->VO1_NUMOSV",1,.f.)

   While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. !eof()

      Do Case
         Case VO2->VO2_TIPREQ == "P"     && Requisicao de Pecas
                                                  
              dbSelectArea("VO3")
              FG_SEEK("VO3","VO2->VO2_NOSNUM",1,.f.)
              cTTpAnt := VO3->VO3_TIPTEM

              While VO2->VO2_NOSNUM == VO3->VO3_NOSNUM .and. !eof()

                 If Empty(VO3->VO3_DATDIS)
                    dbSkip()
                    Loop   
                 EndIf   
                 nValPec := 0
                 FG_SEEK("VOI","VO3->VO3_TIPTEM",1,.f.)
                 FG_SEEK("SA1","VO3->VO3_FATPAR+VO3->VO3_LOJA",1,.f.)
                 FG_SEEK("SBM","VO3->VO3_GRUITE",1,.f.)
                 FG_SEEK("VE4","SBM->BM_CODMAR",1,.f.)

                 If VO2->VO2_DEVOLU == "0"   && Devolucao de Pecas

                    ix1 := aScan(aSitOsv,{|x| x[2] == VO3->VO3_TIPTEM})
                    nValPec := VO3->VO3_VALPEC
                    nTotPec := aSitOsv[ix1,05]
                    nTotPec -= nValPec * VO3->VO3_QTDREQ
                    aSitOsv[ix1] := {.f.,VO3->VO3_TIPTEM,VO3->VO3_FATPAR,SA1->A1_NREDUZ,nTotPec,aSitOsv[ix1,06],aSitOsv[ix1,07],aSitOsv[ix1,08]}
                    dbSkip()
                    Loop

                 Else                        && Requisicao de Pecas

                    If VE4->VE4_PECGAR == "2" .and. VOI->VOI_SITTPO $ "2/4"

                       nValPec := VO3->VO3_VALPEC

                    Else

                       nValPec := FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)

                    Endif

                 Endif

                 dbSelectArea("VO3")
                 ix1 := aScan(aSitOsv,{|x| x[2] == VO3->VO3_TIPTEM})
                 If ix1 == 0
                    nTotPec += nValPec * VO3->VO3_QTDREQ
                    aAdd(aSitOsv,{.f.,VO3->VO3_TIPTEM,VO3->VO3_FATPAR,SA1->A1_NREDUZ,nTotPec,Transform(0,"@R 99999999:99"),Transform(0,"@R 99999999:99"),Transform(0,"@ez 99999999,999.99")})
                 Else
                    nTotPec := aSitOsv[ix1,05]
                    nTotPec += nValPec * VO3->VO3_QTDREQ
                    aSitOsv[ix1] := {.f.,VO3->VO3_TIPTEM,VO3->VO3_FATPAR,SA1->A1_NREDUZ,nTotPec,aSitOsv[ix1,06],aSitOsv[ix1,07],aSitOsv[ix1,08]}
                 EndIf
                 dbskip()

              EndDo

         Case VO2->VO2_TIPREQ == "S"     && Requisicao de Servicos

              dbSelectArea("VO4")
              FG_SEEK("VO4","VO2->VO2_NOSNUM",1,.f.)
              cTTpAnt := VO4->VO4_TIPTEM

              While VO2->VO2_NOSNUM == VO4->VO4_NOSNUM .and. !eof()

                 If Empty(VO4->VO4_DATDIS)
                    dbSkip()
                    Loop   
                 EndIf   
                 FG_SEEK("VOI","VO4->VO4_TIPTEM",1,.f.)
                 FG_SEEK("SA1","VO4->VO4_FATPAR+VO4->VO4_LOJA",1,.f.)
                 FG_SEEK("VOK","VO4->VO4_TIPSER",1,.f.)

                 If VO4->VO4_TIPTEM != cTTpAnt
                    cTTpAnt := VO4->VO4_TIPTEM
                    nTotSrv := 0
                    nHorPad := 0
                    nHorTra := 0
                 EndIf

                 If Empty(VO4->VO4_DATFIN) .and. Empty(VO4->VO4_HORFIN)

                    nHorTra += FG_TEMPTRA(VO4->VO4_CODPRO,VO4->VO4_DATINI,VO4->VO4_HORINI,dDataBase,val(left(time(),2)+substr(time(),4,2)),"N",.f.,"O/E")

                 Else

                    nHorTra += VO4->VO4_TEMTRA

                 EndIf

                 ix1 := aScan(aCodSer,VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSER)

                 If ix1 == 0

                    aAdd(aCodSer,VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSER)

                    Do Case
                       Case VOK->VOK_INCMOB == "1"                     && Mao-de-Obra

                            If VOK->VOK_INCTEM == "3"                  && Tempo Trabalhado
//                               nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR
                               nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
                               nHorPad += VO4->VO4_TEMPAD
                            Else                                       && Tempo Fabrica/Concessionaria/Informado
//                               nTotSrv += (VO4->VO4_TEMPAD / 100) * VOI->VOI_VALHOR
                               nTotSrv += (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
                               nHorPad += VO4->VO4_TEMPAD
                            EndIf

                       Case VOK->VOK_INCMOB == "2"                     && Servico de Terceiro

                            nTotSrv += VO4->VO4_VALVEN

                       Case VOK->VOK_INCMOB == "3"                     && Valor Livre com Base na Tabela

                            If VOK->VOK_INCTEM == "3"                  && Tempo Trabalhado
//                               nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR
                               nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
                               nHorPad += VO4->VO4_TEMPAD
                            Else                                       && Tempo Fabrica/Concessionaria/Informado
//                               nTotSrv += (VO4->VO4_TEMPAD / 100) * VOI->VOI_VALHOR
                               nTotSrv += (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
                               nHorPad += VO4->VO4_TEMPAD
                            EndIf

                       Case VOK->VOK_INCMOB == "4"                     && Retorno de Servico

                            If VOK->VOK_INCTEM == "3"                  && Tempo Trabalhado
//                               nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR
                               nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
                               nHorPad += VO4->VO4_TEMPAD
                            Else                                       && Tempo Fabrica/Concessionaria/Informado
//                               nTotSrv += (VO4->VO4_TEMPAD / 100) * VOI->VOI_VALHOR
                               nTotSrv += (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
                               nHorPad += VO4->VO4_TEMPAD
                            EndIf

                       Case VOK->VOK_INCMOB == "5"                     && Socorro

                            nTotSrv += VO4->VO4_KILROD * VOK->VOK_PREKIL

                    EndCase

                 Else

                    Do Case
                       Case VOK->VOK_INCMOB == "2"      && Servico de Terceiro

                            nTotSrv += VO4->VO4_VALVEN

                       Case VOK->VOK_INCMOB == "5"      && Socorro

                            nTotSrv += VO4->VO4_KILROD * VOK->VOK_PREKIL

                       Case VOK->VOK_INCMOB $ "1/3" .and. VOK->VOK_INCTEM == "3"          && Tempo Trabalhado

//                            nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR          && Tempo Trabalhado
                            nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)          && Tempo Trabalhado

                    EndCase

                 EndIf

                 ix1 := aScan(aSitOsv,{|x| x[2] == VO4->VO4_TIPTEM})
                 If ix1 == 0
                    aAdd(aSitOsv,{.f.,VO4->VO4_TIPTEM,VO4->VO4_FATPAR,SA1->A1_NREDUZ,0.00,Transform(nHorPad,"@R 99999999:99"),Transform(nHorTra,"@R 99999999:99"),Transform(nTotSrv,"@ez 99999999,999.99")})
                 Else
                    aSitOsv[ix1] := {.f.,VO4->VO4_TIPTEM,VO4->VO4_FATPAR,SA1->A1_NREDUZ,aSitOsv[ix1,05],Transform(nHorPad,"@R 99999999:99"),Transform(nHorTra,"@R 99999999:99"),Transform(nTotSrv,"@ez 99999999,999.99")}
                 EndIf

                 dbSkip()

              EndDo

      EndCase

      nTotTTp := nTotPec + nTotSrv
      dbSelectArea("VO2")
      dbSkip()

   EndDo
   
   If len(aSitOsv) == 0
      Help(" ",1,"M180SEMDIS")
      Return .f.
   EndIf
      
Else

   aAdd(aSitOsv,{.f.,"","","",0.00,0,Transform(0,"@R 99999999:99"),Transform(0,"@ez 99999999,999.99")})
   Help(" ",1,"M180SEMDIS")
   Return .f.

EndIf

Return .t.

Function FS_LIBDIS()
********************
                    
Local ix2
Local lTemLib := .f.
lCancelou := .f.


If empty(M->VO1_MOTIVO)
              
   Help(" ",1,"M180CODMOT")
   return .f.
         
EndIf

for ix2 := 1 to len(aSitOsv)
                      
    If aSitOsv[ix2,01] == .t.
    
       If FG_SEEK("VO2","VO1->VO1_NUMOSV",1,.f.)

          lTemLib := .f.
             
          While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. !eof()

             If VO2->VO2_TIPREQ == "P"

                dbSelectArea("VO3")
&&              cKeyAce := Left(VO2->VO2_NOSNUM,8)+SubStr(aSitOsv[ix2,02],1)
                cKeyAce := Left(VO2->VO2_NOSNUM,8)

                If FG_SEEK("VO3","cKeyAce",1,.f.)

&&                 While VO2->VO2_NOSNUM+aSitOsv[ix2,02] == VO3->VO3_NOSNUM+VO3->VO3_TIPTEM .and. !eof()
                   While VO2->VO2_NOSNUM == VO3->VO3_NOSNUM .and. !eof()

                      If aSitOsv[ix2,02] == VO3->VO3_TIPTEM

                         If FS_CANGAR(VO3->VO3_TIPTEM)

                            lCancelou := .t.
                            RecLock("VO3",.f.)
                            VO3->VO3_DATDIS := ctod("  /  /  ")
                            VO3->VO3_HORDIS := 0
                            dbSelectArea("VO1")
                            RecLock("VO1",.f.)
                            VO1->VO1_STATUS := "A"

                            dbSelectArea("VO3")

                         EndIf

                      EndIf

                      If !Empty(VO3->VO3_DATDIS)
                         lTemLib := .t.
                      EndIf

                      dbSkip()

                   EndDo

                EndIf

             Else

                dbSelectArea("VO4")
                cKeyAce := Left(VO2->VO2_NOSNUM,8)
&&              cKeyAce += SubStr(aSitOsv[ix2,02],1)

                If FG_SEEK("VO4","cKeyAce",1,.f.)

&&                 While VO2->VO2_NOSNUM+aSitOsv[ix2,02] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM .and. !eof()
                   While VO2->VO2_NOSNUM == VO4->VO4_NOSNUM .and. !eof()

                      If aSitOsv[ix2,02] == VO4->VO4_TIPTEM

                         If FS_CANGAR(VO4->VO4_TIPTEM)

                            lCancelou := .t.
                            RecLock("VO4",.f.)
                            VO4->VO4_DATDIS := ctod("  /  /  ")
                            VO4->VO4_HORDIS := 0
                            MsUnlock()

                            dbSelectArea("VO1")
                            RecLock("VO1",.f.)
                            VO1->VO1_STATUS := "A"
                            dbSelectArea("VO4")

                         EndIf

                      EndIf

                      If !Empty(VO4->VO4_DATDIS)
                         lTemLib := .t.
                      EndIf

                      dbSkip()

                   EndDo

                EndIf

             EndIf

             dbSelectArea("VO2")
             dbSkip()

          EndDo

          If lTemLib
             dbSelectArea("VO1")
             RecLock("VO1",.f.)
             VO1->VO1_TEMLIB := "S"
          Else
             dbSelectArea("VO1")
             RecLock("VO1",.f.)
             VO1->VO1_TEMLIB := " "
          EndIf

          If lCancelou

             dbSelectArea("VOZ")
          
             cKeyAce := Left(VO1->VO1_NUMOSV,8)
             cKeyAce += SubStr(aSitOsv[ix2,02],1)
          
             RecLock("VOZ",.t.)

             VOZ->VOZ_FILIAL := xFilial("VOZ")
             VOZ->VOZ_NUMOSV := VO1->VO1_NUMOSV
             VOZ->VOZ_TIPTEM := aSitOsv[ix2,02]
             VOZ->VOZ_DATOCO := date()
             VOZ->VOZ_DISCAN := "C"
             VOZ->VOZ_CODCON := POSICIONE("VAI",4,xFilial("VAI")+__cUserID,"VAI_CODTEC")
             VOZ->VOZ_CODMOT := M->VO1_CODMOT
             MsUnlock()

             dbSelectArea("VOO")

             If FG_Seek("VOO","cKeyAce",1,.f.)
                RecLock("VOO",.f.,.t.)
                dbDelete()
                MsUnlock()
                WriteSX2("VOO")
             EndIf

          EndIf

       EndIf
       
    EndIf   

Next

return .t.

Function FS_CANGAR(cTipTem)
**********************

Local cFunExp := ""
Local cFuncao, ix1

FG_SEEK("VOI","VO3->VO3_TIPTEM",1,.f.)

If VOI->VOI_SITTPO != "2"
   Return .t.
EndIf

FG_SEEK("VE4","SBM->BM_CODMAR",1,.f.)

If VE4->VE4_QDOIMP != "1"
   Return .t.
EndIf

If FG_SEEK("VEG","VE4->VE4_FOREXP",1,.f.)

   cFuncao := Alltrim(VEG->VEG_FORMUL)

   For ix1 := 1 to len(cFuncao)

       If SubStr(cFuncao,ix1,1) == "("
          cFunExp += "('C')"
          Exit
       EndIf
       cFunExp += SubStr(cFuncao,ix1,1)

   Next

   If &cFunExp                           && Funcao de Cancelamento da Importacao da Garantia
      Return .t.
   Else
      Return .f.
   EndIf

EndIf

Return .t.

Static Function MenuDef()
Local aRotina := {{STR0001, "AxPesqui",0,1},; //"Pesquisar"
                  {STR0002, "OFIOM180I",0,2}} //"Cancelar Lib"
Return aRotina
