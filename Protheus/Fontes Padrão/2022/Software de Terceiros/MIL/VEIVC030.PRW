#INCLUDE "veivc030.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVC030 ³ Autor ³  Andre                ³ Data ³ 16/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Posicao do Participante na Tela                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEIVC030

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0003) //"Posicao do Participante"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VP1")

Return


Function AC030(cAlias,nReg,nOpc)

   Local bCampo := { |nCPO| Field(nCPO) }
   Local nCntFor:=0

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

   DbSelectArea("VPA")
   DbGotop()
   if DbSeek(xFilial("VPA")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT)
      Do While !EOF() .and. VPA->VPA_FILIAL == xFilial("VPA")
         if VP1->VP1_CODGRU+VP1->VP1_NUMCOT == VPA_CODGRU+VPA_NUMCOT
            aadd(aItem,{VPA_CODDOC,if(VP8->(DbSeek(xFilial("VP8")+VPA->VPA_CODDOC)),VP8->VP8_DESDOC," "),DTOC(VPA_PREENT),DTOC(VPA_DATENT),VPA_REFDOC})
         Else
            Exit
         Endif
         DbSkip()
      Enddo
   Else
      aadd(aItem,{" "," "," "," "," "})
   Endif

   DbSelectArea("VP2")
   DbGotop()
   if DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT)
      Do While !EOF() .and. VP2->VP2_FILIAL == xFilial("VP2")
         if VP1->VP1_CODGRU+VP1->VP1_NUMCOT == VP2_CODGRU+VP2_NUMCOT
            aadd(aItem2,{VP2_NUMPAR,DTOC(VP2_DATPAR),TRANS(VP2_VALBEM,cPic),TRANS(VP2_VALPAR,cPic),TRANS(VP2_VALDES,cPic),TRANS(VP2_VALLAN,cPic),TRANS(VP2_PERLAN,"@E 999.9999"),TRANS(VP2_PARPAG,cPic),TRANS(VP2_DESPAG,cPic),TRANS(VP2_TOTPAG,cPic),DTOC(VP2_DATPAG),TRANS(VP2_PERPAG,"@E 999.9999"),TRANS(VP2_PERDIF,"@E 999.9999"),TRANS(VP2_PERSAL,"@E 999.9999"),TRANS(VP2_VALDIF,cPic)})
         Else
            Exit
         Endif
         DbSkip()
      Enddo
   Else
      aadd(aItem2,{" "," "," "," "," "," "," "," "," "," "," "," "," "," "})
   Endif

   DEFINE MSDIALOG oDlg TITLE STR0003 From 2,0 to 34,80 of oMainWnd //"Posicao do Participante"

   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,100,317},,3,,,,,,.F.)

   @ 100, 001 LISTBOX oLbHeader FIELDS HEADER	OemToAnsi(STR0004),; //"Codigo   "
                                                OemToAnsi(STR0005),; //"Descricao"
							OemToAnsi(STR0006),; //"Prev Ent "
       						OemToAnsi(STR0007),; //"Data Ent "
              					OemToAnsi(STR0008); //"Refer    "
   COLSIZES 35,80,40,40,80;
   SIZE 315,060 OF oDlg PIXEL

   oLbHeader:SetArray(aItem)
   oLbheader:bLine := { || { aItem[oLbHeader:nAt,1] ,;
         			           aItem[oLbHeader:nAt,2] ,;
                  		 	  aItem[oLbHeader:nAt,3] ,;
                  		 	  aItem[oLbHeader:nAt,4] ,;
                  		 	  aItem[oLbHeader:nAt,5] }}


   @ 161, 001 LISTBOX oLbHeader2 FIELDS HEADER	OemToAnsi(STR0009),; //"Parcela   "
                                                OemToAnsi(STR0010),; //"Data      "
                   										OemToAnsi(STR0011),; //"Credito   "
                     									OemToAnsi(STR0012),; //"Sd Parc   "
                     									OemToAnsi(STR0013),; //"Vl Desp   "
                     									OemToAnsi(STR0014),; //"Vl Lan/Ant"
                     									OemToAnsi(STR0015),; //"% Lance   "
                     									OemToAnsi(STR0016),; //"Pg Parc   "
                     									OemToAnsi(STR0017),; //"Pg Desp   "
                     									OemToAnsi(STR0018),; //"Pg Total  "
                     									OemToAnsi(STR0019),; //"Data Pg   "
                     									OemToAnsi(STR0020),; //"% Pago    "
                     									OemToAnsi(STR0021),; //"% Difer   "
                     									OemToAnsi(STR0022),; //"% Saldo   "
                     									OemToAnsi(STR0023); //"Vl Difer  "
   COLSIZES 28,48,48,48,48,48,48,48,48,48,48,48,48,48;
   SIZE 315,081 OF oDlg PIXEL

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

   ACTIVATE MSDIALOG oDlg ON INIT FS_CHCBAR(oDlg,{||nOpca:=1,If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End())},{||oDlg:End()}) CENTER



Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_CHCBAR  ³ Autor ³ Andre                 ³ Data ³ 16/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHCBAR(oDlg,bOk,bCancel)

Local oBar, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP STR0024 //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP STR0025 //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP STR0026 //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0027 //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda() TOOLTIP STR0028 //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP STR0029 //"Gerenciador de Impress„o..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar ACTION HelProg() TOOLTIP STR0030 //"Help de Programa..."

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "OK"    OF oBar GROUP ACTION ( lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0031 //"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP STR0032 //"Cancelar - <Ctrl-X>"


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
                   { STR0002 ,"AC030"   , 0 , 2}}    //"Consultar"
Return aRotina
