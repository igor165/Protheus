#INCLUDE "ofioc100.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOC100 ³ Autor ³  Andre                ³ Data ³ 09/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cartao Diario de Trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIOC100
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0003) //"Cartao Diario de Trabalho"
//Filtrar "VAI->VAI_FUNPRO == '1'"
mBrowse( 6, 1,22,75,"VAI")
Return

Function OC100(cAlias,nReg,nOpc)

   Local bCampo := { |nCPO| Field(nCPO) }
   Local nCntFor := 0
   Private oDlgLayOut
   Private oGetH
   Private oGetD
   Private oGetT
   Private oLbHeader
   Private oLbDetail
   Private oLbTrail
   Private oBarHeader
   Private oBarDetail
   Private oBarTrail
   Private nHeader := 0
   Private nTree := 0
   Private oOk := LoadBitmap( GetResources(), "LBOK" )
   Private aTELA[0][0],aGETS[0]
   Private aItem := {}

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cria variaveis M->????? da Enchoice                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   RegToMemory("VAI",.T.)
   DbSelectArea("VAI")
   For nCntFor := 1 TO FCount()
       M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next

   nOpcE:=2
   nOpcG:=2

   cAliasEnchoice:="VAI"
   cAliasGetD    :="VO4"
   cLinOk        :="AllwaysTrue()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="AllwaysTrue()"

   aCpoEnchoice  :={}

   dbSelectArea("SX3")
   dbSeek("VAI")
   While !Eof().and.(x3_arquivo=="VAI")
      if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VAI_VALOR/VAI_CC/VAI_CENTRA/VAI_PAGER/VAI_EMAIL/VAI_FONE/VAI_REGIAO])
         AADD(aCpoEnchoice,x3_campo)
      Endif
      dbSkip()
   End

 //aadd(aItem,{"99999999","999999999999999","999","999","9","999:99","999:99","999:99","999:99","99/99/99","99:99","99/99/99","99:99"})
   aadd(aItem,{"        ","               ","   ","   "," ","      ","      ","      ","      ","        ","     ","        ","     "})

   DEFINE MSDIALOG oDlg TITLE STR0003 From 4,0 to 30,80 of oMainWnd //"Cartao Diario de Trabalho"

   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,80,315},,3,,,,,,.F.)

   @ 080, 001 LISTBOX oLbHeader FIELDS HEADER	OemToAnsi(STR0004),; //"Nro OS  "
                                                OemToAnsi(STR0005),; //"Servico "
                   										OemToAnsi(STR0006),; //"TS      "
                     									OemToAnsi(STR0007),; //"Sec     "
                     									OemToAnsi(STR0008),; //"Tp      "
                     									OemToAnsi(STR0009),; //"TpoPad  "
                     									OemToAnsi(STR0010),; //"TpoTra  "
                     									OemToAnsi(STR0011),; //"TpoVen  "
                     									OemToAnsi(STR0012),; //"TpoCob  "
                     									OemToAnsi(STR0013),; //"Dt Inic "
                     									OemToAnsi(STR0014),; //"Hr Inic "
                     									OemToAnsi(STR0015),; //"Dt Final"
                     									OemToAnsi(STR0016); //"Hr Final"
   COLSIZES 28,48,13,13,08,21,21,21,21,26,19,26,19;
   SIZE 314,105 OF oDlg PIXEL

   oLbHeader:SetArray(aItem)
   oLbheader:bLine := { || { aItem[oLbHeader:nAt,1] ,;
         			           aItem[oLbHeader:nAt,2] ,;
                  		 	  aItem[oLbHeader:nAt,3] ,;
                  		 	  aItem[oLbHeader:nAt,4] ,;
                  		 	  aItem[oLbHeader:nAt,5] ,;
                  		 	  aItem[oLbHeader:nAt,6] ,;
                  		 	  aItem[oLbHeader:nAt,7] ,;
                  		 	  aItem[oLbHeader:nAt,8] ,;
                  		 	  aItem[oLbHeader:nAt,9] ,;
                  		 	  aItem[oLbHeader:nAt,10] ,;
                  		 	  aItem[oLbHeader:nAt,11] ,;
                  		 	  aItem[oLbHeader:nAt,12] ,;
                  		 	  aItem[oLbHeader:nAt,13] }}

   @ 187,005 Say OemToAnsi(STR0017) SIZE 110,08 OF oDlg PIXEL COLOR CLR_HBLUE //"Pad:"
   @ 187,050 Say OemToAnsi(STR0018) SIZE 110,08 OF oDlg PIXEL COLOR CLR_HBLUE //"Tra:"
   @ 187,105 Say OemToAnsi(STR0019) SIZE 110,08 OF oDlg PIXEL COLOR CLR_HBLUE //"Cob:"
   @ 187,155 Say OemToAnsi(STR0020) SIZE 110,08 OF oDlg PIXEL COLOR CLR_HBLUE //"Ext:"
   @ 187,205 Say OemToAnsi(STR0021) SIZE 110,08 OF oDlg PIXEL COLOR CLR_HBLUE //"Aus:"
   @ 187,255 Say OemToAnsi(STR0022) SIZE 110,08 OF oDlg PIXEL COLOR CLR_HBLUE //"S/A:"

   FS_MOSTEMPO()

   ACTIVATE MSDIALOG oDlg ON INIT FS_CHOIBAR(oDlg,{||nOpca:=1,if(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()}) CENTER

Return


//////////////////////
Function FS_MOSTEMPO()



Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_CHOIBAR ³ Autor ³ Andre                 ³ Data ³ 13/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHOIBAR(oDlg,bOk,bCancel)

Local oBar, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP STR0023 //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP STR0024 //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP STR0025 //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0026 //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda() TOOLTIP STR0027 //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP STR0028 //"Gerenciador de Impress„o..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar ACTION HelProg() TOOLTIP STR0029 //"Help de Programa..."

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "OK"    OF oBar GROUP ACTION ( lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0030 //"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP STR0031 //"Cancelar - <Ctrl-X>"


SetKEY(24,oBtCan:bAction)
oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}
Return nil

Static Function ButtonOff(bSet15,bSet24,lOk)
DEFAULT lOk := .t.
IF lOk
    SetKey(15,bSet15)
    SetKey(24,bSet24)
Endif

Return .T.

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;   && Pesquisar //"Pesquisar"
                   { STR0002 ,"OC100"   , 0 , 2}}    && Consultar //"Consultar"
Return aRotina
