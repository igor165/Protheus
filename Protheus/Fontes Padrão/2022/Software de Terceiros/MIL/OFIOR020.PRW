#INCLUDE "ofior020.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR020 ³ Autor ³  Emilton              ³ Data ³ 01/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia da Relacao de Pecas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "protheus.ch"
#Include "FileIO.ch"
Function OFIOR020

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004) //"Copia da Relacao de Pecas"
Private cFinSrv := .f.       
Private cKeyAce := ""
Private lSaiVei := .f.
Private lPerVei := .f.
Private nNroLin := 0
Private lDisponibilizou 

*** Endereca a funcao de BROWSE ***********************************************

Private cIndex, cChave, cCond

mBrowse( 6, 1,22,75,"VO1")

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOR020N  ³ Autor ³ Emilton               ³ Data ³ 01/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pede Impressao de Formulario Normal                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Local                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OFIOR020N(cAlias, nReg, nOpc)
*******************************

FS_TRAOSV(cAlias,nReg,nOpc,"N")

Return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOR020E  ³ Autor ³ Emilton               ³ Data ³ 01/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pede Imperssao de Formulario Especifico                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Local                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OFIOR020E(cAlias, nReg, nOpc)
*******************************
                                      
FS_TRAOSV(cAlias,nReg,nOpc,"E")

Return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_TRAOSV  ³ Autor ³ Emilton               ³ Data ³ 01/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata a Ordem de Servico                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Local                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                                                                               
Static Function FS_TRAOSV(cAlias,nReg,nOpc,cTipFor)
******************************************

Local bCampo   := { |nCPO| Field(nCPO) }
Local oSitOsv
Local nCntFor   := 0

Private aTELA[0][0], aGETS[0], oDlgCopOsv, cTitle
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private aSitOsv := {}
cTitle := OemToAnsi(STR0005) //"Copia da Ordem de Servico"

nOpc  := 2     && Visualizar
nOpcE := 2     && Visualizar
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

   If X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !(X3_CAMPO $ "VO1_FILIAL/VO1_GETKEY/VO1_CODMOT/VO1_NOMMOT/VO1_DATENT/VO1_HORENT/VO1_STATUS/VO1_TEMGAR/VO1_TEMCAN/VO1_TEMFEC/VO1_TEMLIB/VO1_MECREQ/VO1_EXPGAR/VO1_SITGAR/VO1_CODMAR/VO1_MOTIVO/VO1_DESMOT")

      aAdd(aCpoEnchoice,x3_campo)

		If x3_context == "V"      
	      &("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	   EndIf   

   Endif

   dbSkip()

EndDo

aValOsv := {}

If !FS_LEVOSV020()
   return .t.
EndIf

cLinOk     := "AllwaysTrue()"
cTudOOk    := "AllwaysTrue()"
cFieldOk   := "AllwaysTrue()"
nLinhas    := 99
aPos       := { 012,002,123,316 }

dbSelectArea("VO1")
dbSetOrder(1)

DEFINE MSDIALOG oDlgCopOsv FROM 001,000 TO 035,080 TITLE cTitle OF oMainWnd

    EnChoice("VO1", nReg, nOpc, , , ,aCpoEnchoice, aPos)

    @ 125,003 LISTBOX oSitOsv FIELDS HEADER OemToAnsi(""),;
                                            OemToAnsi(STR0006),; && Tipo de TempoGrupo //"Tipo de TempoGrupo"
                                            OemToAnsi(STR0007),;  && Codigo de Cliente //"Codigo de Cliente"
                                            OemToAnsi(STR0008),;    && Nome do Cliente //"Nome do Cliente"
                                            OemToAnsi(STR0009),;     && Total de Pecas //"Total de Pecas"
                                            OemToAnsi(STR0010),;       && Horas Padrao //"Horas Padrao"
                                            OemToAnsi(STR0011),;        && Horas Trab //"Horas Trab."
                                            OemToAnsi(STR0012);   && Total de Servicos //"Total de Servicos"
    COLSIZES 05,10,25,95,45,35,35,45;
    SIZE 312,131 OF oDlgCopOsv ON DBLCLICK ( aSitosv[oSitOsv:nAt,1] := !aSitOsv[oSitOsv:nAt,1] ) PIXEL

    oSitOsv:SetArray(aSitOsv)
    oSitOsv:bLine := { || {  If(aSitOsv[oSitOsv:nAt,1],oOk,oNo) ,;                   
                                  aSitOsv[oSitOsv:nAt,2] ,;
                                  aSitOsv[oSitOsv:nAt,3] ,;
                                  aSitOsv[oSitOsv:nAt,4] ,;
                                  aSitOsv[oSitOsv:nAt,5] ,;
                                  aSitOsv[oSitOsv:nAt,6] ,;
                                  aSitOsv[oSitOsv:nAt,7] ,;
                                  aSitOsv[oSitOsv:nAt,8] }}

ACTIVATE MSDIALOG oDlgCopOsv CENTER ON INIT (FS_CHBAR020(oDlgCopOsv,{|| nOpca := 1,If(FS_PEDORD(cTipFor),oDlgCopOsv:End(),.t.)},{|| nOpca := 0,oDlgCopOsv:End()}))

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHBAR020 ³ Autor ³ Fabio                 ³ Data ³ 12/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_CHBAR020(oDlg,bOk,bCancel)

Local oBar, bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0013)  //"Recortar" //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0014)  //"Copiar" //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0015)  //"Colar" //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP OemToAnsi(STR0016)  //"Calculadora..." //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION Agenda()      TOOLTIP OemToAnsi(STR0017)  //"Agenda..." //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()    TOOLTIP OemToAnsi(STR0018)  //"Gerenciador de ImpressÆo..." //"Gerenciador de Impressao..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar       ACTION HelProg()     TOOLTIP OemToAnsi(STR0019)  //"Help de Programa..." //"Help de Programa..."

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE OemToAnsi("OK") OF oBar GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP OemToAnsi(STR0020)  //"OK"###"Ok - <Ctrl-O>" //"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE OemToAnsi("CANCEL") OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP OemToAnsi(STR0021)  //"CANCEL"###"Cancelar - <Ctrl-X>" //"Cancelar - <Ctrl-X>"
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

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_LEVOSV020³ Autor ³ Emilton               ³ Data ³ 01/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Vetor para listbox na tela                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Local                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_LEVOSV020()
***********************

If !FG_SEEK("VOO","VO1->VO1_NUMOSV",1,.F.)

   Help(" ",1,"R010SEMVOO")  && Nao Existe Nenhum Tipo de Tempo Fechado nesta OS
   Return .f.

Else

   dbSelectArea("VOO")
   While VO1->VO1_NUMOSV == VOO->VOO_NUMOSV .and. !eof()

      If !empty(VOO->VOO_NUMNFI)
         If VOO->VOO_TOTPEC > 0
            FG_SEEK("SA1","VOO->VOO_FATPAR+VO1->VO1_LOJA",1,.f.)
            aAdd(aSitOsv,{.f.,VOO_TIPTEM,VOO_FATPAR,SA1->A1_NREDUZ,Transform(VOO_TOTPEC,"@e 99,999.99"),Transform(VOO_HRSPAD,"@r 999:99"),Transform(VOO_HRSAPL,"@r 999:99"),Transform(VOO_TOTSRV,"@e 99,999.99")})
         EndIf
      EndIf
      dbSkip()

   EndDo

   dbSelectArea("VO1")

   If Len(aSitOsv) == 0
      aAdd(aSitOsv,{.f.,"","","",Transform(0,"@e 99,999.99"),Transform(0,"@r 999:99"),Transform(0,"@r 999:99"),Transform(0,"@e 99,999.99")})
      Help(" ",1,"R020SEMPEC")  && Nao Existe Nenhum Tipo de Tempo Fechado nesta OS
      Return .f.
   EndIf

EndIf

Return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_PEDORD  ³ Autor ³ Emilton               ³ Data ³ 01/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Vetor para listbox na tela                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Local                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_PEDORD(cTipFor)
***************************

local ix1, nNumera

nNumera := 0

for ix1 := 1 to len(aSitOSv)

    If aSitOsv[ix1,1]
                  
       nNumera ++
       FG_PEDREL(VO1->VO1_NUMOSV,aSitOSv[ix1,2],cTipFor)

    EndIf

Next             

If len(aSitOSv) > 0 .and. nNumera == 0

   Help(" ",1,"R010SEMORD")  && Nao Existe Nenhum Tipo de Tempo Selecionado

   Return .f.

EndIf

Return .t.

Static Function MenuDef()
Local aRotina := {{OemToAnsi(STR0001),   "AxPesqui",0,1},; //"Pesquisar"
                    {OemToAnsi(STR0002), "OFIOR020N",0,2},; //"For. Normal"
                    {OemToAnsi(STR0003), "OFIOR020E",0,2}} //"For. Espec."
Return aRotina
