#INCLUDE "veipc060.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPC060 ³ Autor ³  Andre                ³ Data ³ 16/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Parcelas do Participante na Tela                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPC060

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0003) //"Posicao do Participante"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VP1")

Return

Function AC060(cAlias,nReg,nOpc)

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
   Private aItem  := {}
   Private aItem2 := {}

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cria variaveis M->????? da Enchoice                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   RegToMemory("VP1",.T.)
   DbSelectArea("VP1")
   For nCntFor := 1 TO FCount()
       M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next

   nOpcE:=2
   nOpcG:=2

   cAliasEnchoice:="VP1"
   cAliasGetD    :="VP2"
   cLinOk        :="AllwaysTrue()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="AllwaysTrue()"
   aCpoEnchoice  :={}
   cPic          := "@E 999,999,999.99"

   dbSelectArea("SX3")
   dbSeek("VP1")
   While !Eof().and.(x3_arquivo=="VP1")
      if X3USO(x3_usado).and.cNivel>=x3_nivel
         AADD(aCpoEnchoice,x3_campo)
      Endif
      dbSkip()
   End

   DbSelectArea("VP2")
   DbGotop()
   if DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT)
      Do While !EOF()
         if VP1->VP1_CODGRU+VP1->VP1_NUMCOT == VP2_CODGRU+VP2_NUMCOT
            aadd(aItem2,{VP2_NUMPAR,DTOC(VP2_DATPAR),TRANS(VP2_VALBEM,cPic),TRANS(VP2_PERIDE,"@E 999.9999"),TRANS(VP2_VALPAR,cPic),TRANS(VP2_VALDES,cPic),TRANS(VP2_VALLAN,cPic),TRANS(VP2_PERLAN,"@E 999.9999"),TRANS(VP2_PARPAG,cPic),TRANS(VP2_DESPAG,cPic),TRANS(VP2_TOTPAG,cPic),DTOC(VP2_DATPAG),TRANS(VP2_PERPAG,"@E 999.9999"),TRANS(VP2_PERDIF,"@E 999.9999"),TRANS(VP2_PERSAL,"@E 999.9999")})
         Else
            Exit
         Endif
         DbSkip()
      Enddo
   Else
      aadd(aItem2,{" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "})
   Endif

   DEFINE MSDIALOG oDlg TITLE STR0003 From 2,0 to 34,80 of oMainWnd //"Posicao do Participante"

   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,100,317},,3,,,,,,.F.)

   @ 101, 001 LISTBOX oLbHeader2 FIELDS HEADER	OemToAnsi(STR0004),; //"Parcela   "
                                                OemToAnsi(STR0005),; //"Data      "
          										OemToAnsi(STR0006),; //"Credito   "
               									OemToAnsi(STR0007),; //"% Ideal   "
               									OemToAnsi(STR0008),; //"Sd Parc   "
               									OemToAnsi(STR0009),; //"Vl Desp   "
               									OemToAnsi(STR0010),; //"Vl Lan/Ant"
               									OemToAnsi(STR0011),; //"% Lance   "
               									OemToAnsi(STR0012),; //"Pg Parc   "
               									OemToAnsi(STR0013),; //"Pg Desp   "
               									OemToAnsi(STR0014),; //"Pg Total  "
               									OemToAnsi(STR0015),; //"Data Pg   "
               									OemToAnsi(STR0016),; //"% Pago    "
              									OemToAnsi(STR0017),; //"% Difer   "
               									OemToAnsi(STR0018); //"% Saldo   "
   COLSIZES 28,48,48,48,48,48,48,48,48,48,48,48,48,48,48;
   SIZE 315,141 OF oDlg PIXEL

   oLbHeader2:SetArray(aItem2)
   oLbheader2:bLine := { || { aItem2[oLbHeader2:nAt,1] ,;
         			           aItem2[oLbHeader2:nAt,2] ,;
                  		 	   aItem2[oLbHeader2:nAt,3] ,;
                  		 	   aItem2[oLbHeader2:nAt,4] ,;
                  		 	   aItem2[oLbHeader2:nAt,5] ,;
                  		 	   aItem2[oLbHeader2:nAt,6] ,;
                  		 	   aItem2[oLbHeader2:nAt,7] ,;
                  		 	   aItem2[oLbHeader2:nAt,8] ,;
                  		 	   aItem2[oLbHeader2:nAt,9] ,;
                  		 	   aItem2[oLbHeader2:nAt,10] ,;
                  		 	   aItem2[oLbHeader2:nAt,11] ,;
                  		 	   aItem2[oLbHeader2:nAt,12] ,;
                  		 	   aItem2[oLbHeader2:nAt,13] ,;
                  		 	   aItem2[oLbHeader2:nAt,14] ,;
                  		 	   aItem2[oLbHeader2:nAt,15] }}

   ACTIVATE MSDIALOG oDlg ON INIT FS_CHC2BAR(oDlg,{||nOpca:=1,If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End())},{||oDlg:End()}) CENTER



Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_CHC2BAR ³ Autor ³ Andre                 ³ Data ³ 16/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHC2BAR(oDlg,bOk,bCancel)

Local oBar, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()     TOOLTIP STR0019 //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()     TOOLTIP STR0020 //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()     TOOLTIP STR0021 //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0022 //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION Agenda()      TOOLTIP STR0023 //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()    TOOLTIP STR0024 //"Gerenciador de Impress„o..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar       ACTION HelProg()     TOOLTIP STR0025 //"Help de Programa..."

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "Ok"    OF oBar GROUP ACTION ( lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0026 //"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "Cancel" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP STR0027 //"Cancelar - <Ctrl-X>"


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
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;   //"Pesquisar"
                    { STR0002 ,"AC060"   , 0 , 2}}    //"Consultar"
Return aRotina
