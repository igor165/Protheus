#INCLUDE "ofipa890.ch"
#include "Protheus.ch"
#include "Ofioc120.ch"
#Include "Colors.ch"
Function OFIPA890

   Local cTitle   := OemToAnsi(STR0001) //"Venda Balcao"
   Local aTitles  := {OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)} //"Consulta"###"Orcamento"###"Venda"###"Orcamento de Pecas"###"Orcamento de Servicos"
   Local bCampo   := { |nCPO| Field(nCPO) }
   Local oDlgFolder
   Private oFolder,oDlgConsulta,oDlgVenda
   Private oVar1, oVar2, oVar3, oVar4, oLbItem
   Private aCols := {}
   Private cVar1, cVar2, cVar3, cVar4
   Private aRotina := MenuDef()
   Private aTELA[0][0], aGETS[0], aHeader[0]

   cVar1 := space(30)
   cVar2 := space(30)
   cVar3 := space(30)
   cVar4 := space(30)

   nOpc := 3 && Incluir
   nOpcG:= 3 && Incluir
   nOpcE:= 3 && Incluir

   nOpcf:= 0

/*
   nUsado := 0
   dbSelectArea("SX3")
   dbSeek("VEB")
   aHeader := {}
   While !Eof() .And. (x3_arquivo=="VEB")
      If X3USO(x3_usado) .AND. cNivel >= x3_nivel
         if (alltrim(x3_campo) $ [VEB_GRUITE#VEB_CODITE#VEB_DESCRI#VEB_QUANTI#VEB_VALUNI#VEB_VALTOT])
            nUsado++
            aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
            x3_tamanho, x3_decimal,x3_valid,;
            x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
            wVar := "M->"+x3_campo
            &wVar := CriaVar(x3_campo)
         Endif
      Endif
      dbSkip()
   Enddo

   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next
*/

   aIteRel := {}
   aadd(aIteRel,{"","","",0,0})

   aIteRe2 := {}
   aadd(aIteRe2,{"","","",0,0})


   // Consulta /////////////////////////////////

   Private cCampo1  := Space(27)
   Private cCampo2  := Space(40)
   Private cCampo3  := Space(05)
   Private cCampo4  := Space(04)
   Private cCampo5  := Space(03)
   Private cCampo6  := Space(01)
   Private cCampo7  := Space(01)
   Private cCampo8  := Space(27)
   Private cCampo9  := Space(27)
   Private cCampo10 := 0
   Private cCampo11 := 0
   Private cCampo12 := 0
   Private cCampo13 := 0
   Private cCampo14 := 0
   Private cCampo15 := 0
   Private cCampo16 := 0
   Private cCampo17 := 0
   Private cCampo18 := 0
   Private cCampo19 := 0
   Private cCampo20 := 0
   Private cCampo21 := 0
   Private cCampo22 := 0
   Private cCampo23 := CtoD("")
   Private cCampo24 := CtoD("")
   Private cCampo25 := CtoD("")
   Private cCampo26 := 0
   Private cCampo27 := 0
   Private cCampo28 := 0
   Private cCampo29 := Space(10)
   Private cCampo30 := Space(10)
   Private cCampo31 := Space(01)
   Private cCampo32 := 0
   Private cCampo33 := 0
   Private cCampo34 := 0
   Private cCampo35 := 0
   Private cCampo36 := space(03)
   Private cCampo37 := space(25)
   Private cCampo38 := space(25)

   Private aDsCampo := {}
   AADD(aDsCampo,STR0007)      // 01 //"Codigo     "
   AADD(aDsCampo,STR0008)      // 02 //"Descricao  "
   AADD(aDsCampo,STR0009)      // 03 //"Class ABC  "
   AADD(aDsCampo,STR0010)      // 04 //"Cod. CAI   "
   AADD(aDsCampo,STR0011)      // 05 //"Marca      "
   AADD(aDsCampo,STR0012)      // 06 //"Kit        "
   AADD(aDsCampo,STR0013)      // 07 //"Situacao   "
   AADD(aDsCampo,STR0014)      // 08 //"Nova       "
   AADD(aDsCampo,STR0015)      // 09 //"Velha      "
   AADD(aDsCampo,STR0016)      // 10 //"Venda      "
   AADD(aDsCampo,STR0017)      // 11 //"Preco Venda"
   AADD(aDsCampo,STR0018)      // 12 //"Reposicao  "
   AADD(aDsCampo,STR0019)      // 13 //"Garantia   "
   AADD(aDsCampo,STR0020)      // 14 //"Disponivel "
   AADD(aDsCampo,STR0021)      // 15 //"Oficina    "
   AADD(aDsCampo,STR0019)      // 16 //"Garantia   "
   AADD(aDsCampo,STR0022)      // 17 //"Bloq. Gar. "
   AADD(aDsCampo,STR0023)      // 18 //"Bloqueado  "
   AADD(aDsCampo,STR0024)      // 19 //"Consignacao"
   AADD(aDsCampo,STR0025)      // 20 //"Peca Extra "
   AADD(aDsCampo,STR0026)      // 21 //"IPI (%)    "
   AADD(aDsCampo,STR0027)      // 22 //"Media Calc."
   AADD(aDsCampo,STR0028)      // 23 //"Ult. Venda "
   AADD(aDsCampo,STR0029)      // 24 //"Ult.Entrada"
   AADD(aDsCampo,STR0030)      // 25 //"Ult. Compra"
   AADD(aDsCampo,STR0031)      // 26 //"Custo Medio"
   AADD(aDsCampo,STR0032)      // 27 //"Qtd Embal. "
   AADD(aDsCampo,STR0033)      // 28 //"Peso       "
   AADD(aDsCampo,STR0034)      // 29 //"Locacao 1  "
   AADD(aDsCampo,STR0035)      // 30 //"Locacao 2  "
   AADD(aDsCampo,STR0036)      // 31 //"Gr Desconto"
   AADD(aDsCampo,STR0037)      // 32 //"Tributado  "
   AADD(aDsCampo,STR0038)      // 33 //"Rec. Fornec"
   AADD(aDsCampo,STR0039)      // 34 //"Rec (UP/EM)"
   AADD(aDsCampo,STR0040)      // 35 //"Em Transito"
   AADD(aDsCampo,STR0041)      // 36 //"Grupo      "
   AADD(aDsCampo,STR0042)      // 37 //"Desc Marca "
   AADD(aDsCampo,STR0043)      // 38 //"Desc CAI   "

   /////////////////////////////////////////////


   // Venda ////////////////////////////////////

   Private aDvCampo := {}
   AADD(aDvCampo,STR0044)      // 01 //"Parcelas   "

   /////////////////////////////////////////////

   DEFINE FONT oFnt  NAME "Arial" SIZE 15,20 BOLD
   DEFINE FONT oFnt1 NAME "Arial" SIZE 09,14
   DEFINE FONT oFnt2 NAME "Arial" SIZE 08,12
   DEFINE FONT oFnt3 NAME "Ms Sans Serif" ITALIC
   DEFINE FONT oFnt4 NAME "Times New Roman" BOLD
   DEFINE FONT oFnt5 NAME "Ms Sans Serif" SIZE 08,10
   DEFINE FONT oFnt6 NAME "Ms Sans Serif" BOLD SIZE 08,10

   nOpca := 0

   DEFINE MSDIALOG oDlg FROM 001,000 TO 035,080 TITLE cTitle OF oMainWnd

       @ 012,001 FOLDER oFolder SIZE 316,250 OF oDlg PROMPTS aTitles[1],aTitles[2],aTitles[3] PIXEL

       @ 014, 005 SAY   aDsCampo[36] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ 014, 028 MSGET oCampo36 VAR cCampo36 PICTURE "@!" F3 "SBM" VALID FS_ACHAPROD(1) SIZE 18,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE FONT oFnt4

       @ 014, 059 SAY   aDsCampo[1]  SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ 014, 080 MSGET oCampo1 VAR cCampo1 PICTURE "@!" F3 "B11" VALID FS_ACHAPROD(2) SIZE 58,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE FONT oFnt4

       @ 014, 140 SAY oCampo2  VAR cCampo2 SIZE 180,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HRED FONT oFnt1

       Lin := 025
       Pos := 005

       @  Lin, 002 TO Lin+28,310 LABEL STR0045 OF oFolder:aDialogs[1] PIXEL //"Visualizar"

       Lin := Lin + Pos

       @ Lin, 005 SAY aDsCampo[5] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 025 SAY oCampo5  VAR cCampo5  PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK
       @ Lin, 040 SAY oCampo37 VAR cCampo37 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE  FONT oFnt2

       @ Lin, 120 SAY aDsCampo[4] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 145 SAY oCampo4 VAR cCampo4 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK
       @ Lin, 177 SAY oCampo38 VAR cCampo38 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE  FONT oFnt2

       Lin := Lin + Pos + 6

       @ Lin, 005 SAY aDsCampo[3] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 047 SAY oCampo3 VAR cCampo3 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt2

       @ Lin, 120 SAY aDsCampo[6] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 140 SAY oCampo6 VAR cCampo6 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt2

       Lin := Lin - Pos - 6

       Lin := Lin + 24

       @  Lin, 002 TO Lin+17,103 LABEL ""      OF oFolder:aDialogs[1] PIXEL
       @  Lin, 106 TO Lin+17,310 LABEL STR0046 OF oFolder:aDialogs[1] PIXEL //"Incluir"

       Lin := Lin + Pos

       @ Lin, 005 SAY aDsCampo[7] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 030 SAY oCampo7 VAR cCampo7 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt2

       @ Lin, 110 SAY aDsCampo[8] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 133 SAY oCampo8 VAR cCampo8 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       @ Lin, 200 SAY aDsCampo[9] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 224 SAY oCampo9 VAR cCampo9 PICTURE "@!" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       Lin := Lin + 14

       @  Lin, 002 TO Lin+28,103 LABEL STR0047 OF oFolder:aDialogs[1] PIXEL //"Alterar"
       @  Lin, 106 TO Lin+28,310 LABEL STR0048 OF oFolder:aDialogs[1] PIXEL //"Excluir"
       @  Lin, 210 TO Lin+28,310 LABEL ""      OF oFolder:aDialogs[1] PIXEL

       Lin := Lin + Pos

       @ Lin, 005 SAY aDsCampo[11] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 110 SAY aDsCampo[14] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE

       @ Lin, 215 SAY aDsCampo[21] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 265 SAY oCampo21 VAR cCampo21 PICTURE "@E 999,999,999.99" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       Lin := Lin + Pos + 3

       @ Lin, 005 MSGET oCampo11 VAR cCampo10 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.
       DEFINE SBUTTON oObs1 TYPE 14 FROM Lin,064 OF oFolder:aDialogs[1] ENABLE ONSTOP STR0049 WHEN (!Empty(cCampo36).and.!Empty(cCampo1)) //"Precos"
       oObs1:cToolTip := OemToAnsi(STR0050) //"Outros Precos"

       @ Lin+2, 215 SAY aDsCampo[22] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin+2, 265 SAY oCampo22 VAR cCampo22 PICTURE "@E 999,999,999.99" OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       @ Lin, 110 MSGET oCampo14 VAR cCampo14 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.
       DEFINE SBUTTON oObs2 TYPE 14 FROM Lin,167 OF oFolder:aDialogs[1] ENABLE ONSTOP STR0051 ACTION FS_DISPON() WHEN (!Empty(cCampo36).and.!Empty(cCampo1)) //"Disponibilidade"
       oObs2:cToolTip := OemToAnsi(STR0052) //"Disponibilidade por Almoxarifado"

       Lin := Lin + 18

       @  Lin, 002 TO Lin+62,310 LABEL STR0007 OF oFolder:aDialogs[1] PIXEL

       Lin := Lin + Pos + 3

       @ Lin, 005 SAY aDsCampo[23] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 080 SAY aDsCampo[24] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 160 SAY aDsCampo[25] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 230 SAY aDsCampo[26] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE

       Lin := Lin + Pos + 3

       @ Lin, 005 MSGET oCampo23 VAR cCampo23 PICTURE "@D" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.
       @ Lin, 080 MSGET oCampo24 VAR cCampo24 PICTURE "@D" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.
       @ Lin, 160 MSGET oCampo25 VAR cCampo25 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.
       @ Lin, 230 MSGET oCampo26 VAR cCampo26 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK When .f.

       Lin := Lin + Pos + 12

       @  Lin, 002 TO Lin+1,310 LABEL ""      OF oFolder:aDialogs[1] PIXEL

       Lin := Lin + Pos

       @ Lin, 005 SAY aDsCampo[27] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 044 SAY oCampo27 VAR cCampo27 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       @ Lin, 109 SAY aDsCampo[29] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 142 SAY oCampo29 VAR cCampo29 PICTURE "@!" OF oFolder:aDialogs[1] SIZE 65,08 PIXEL COLOR CLR_BLACK FONT oFnt4

       @ Lin, 207 SAY aDsCampo[30] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 241 SAY oCampo30 VAR cCampo30 PICTURE "@!" OF oFolder:aDialogs[1] SIZE 65,08 PIXEL COLOR CLR_BLACK FONT oFnt4

       Lin := Lin + Pos + 06

       @ Lin, 005 SAY aDsCampo[28] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 044 SAY   oCampo28 VAR cCampo28 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       @ Lin, 109 SAY aDsCampo[31] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 145 SAY oCampo31 VAR cCampo31 PICTURE "@!" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       @ Lin, 207 SAY aDsCampo[32] SIZE 40,08 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE
       @ Lin, 248 SAY oCampo32 VAR cCampo32 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFnt4

       @ 167,002 LISTBOX oLbItem FIELDS HEADER  OemToAnsi(STR0053     ),; //"Grupo"
                                                OemToAnsi(STR0054    ),; //"Codigo"
                                                OemToAnsi(STR0055 ),; //"Descricao"
                                                OemToAnsi(STR0056    ),; //"Qtdade"
                                                OemToAnsi(STR0057     ); //"Valor"
       COLSIZES 20,60,125,30,20,40;
       SIZE 308,060 OF oFolder:aDialogs[1] ON DBLCLICK (FS_ITEREL890(oLbItem:nAt),oLbItem:Refresh()) PIXEL //oGetVenda:oBrowse:SetFocus()

       oLbItem:SetArray(aIteRel)
       oLbItem:bLine := { || { aIteRel[oLbItem:nAt,1] ,;
                               aIteRel[oLbItem:nAt,2] ,;
                               aIteRel[oLbItem:nAt,3] ,;
                               Str(aIteRel[oLbItem:nAt,4]),;
                               Transform(aIteRel[oLbItem:nAt,5],"999,999,999.99")}}


       DEFINE BUTTONBAR oBar1 SIZE 25,25 3D BOTTOM OF oFolder:aDialogs[1]

       DEFINE BUTTON RESOURCE "NEXT"        OF oBar1 ACTION NaoDisp() TOOLTIP STR0058 //"Inclui Item no Orcamento"
       DEFINE BUTTON RESOURCE "BUDGETY"     OF oBar1 ACTION NaoDisp() TOOLTIP STR0059 //"Consulta Demanda e Frequencia do Item"
       DEFINE BUTTON RESOURCE "CADEADO"     OF oBar1 ACTION OFMI900("VE6",0,3,,"2") TOOLTIP STR0060 //"Bloqueia Item"
       DEFINE BUTTON RESOURCE "NOVACELULA"  OF oBar1 ACTION NaoDisp() TOOLTIP STR0061 //"Reserva Item"
//       DEFINE BUTTON RESOURCE "DBG09"   OF oBar1 ACTION NaoDisp() TOOLTIP "Reserva Item"
//       DEFINE BUTTON RESOURCE "AUTOM"   OF oBar1 ACTION NaoDisp() TOOLTIP "Descontos na Venda"
//       DEFINE BUTTON RESOURCE "COLTOT"  OF oBar1 ACTION NaoDisp() TOOLTIP "Totaliza Parcialmente a Venda"
//       DEFINE BUTTON RESOURCE "EXCLUIR" OF oBar1 ACTION NaoDisp() TOOLTIP "Exclui Venda"

       @ 082,001 FOLDER oFolder2 SIZE 316,160 OF oFolder:aDialogs[2] PROMPTS aTitles[4],aTitles[5] PIXEL

//       Zero();MsMGet():New("VEB",0,2,,,,,{5,5,080,280},,,,,,oFolder:aDialogs[2],,,.T.)

       DEFINE BUTTON oBtFab RESOURCE "DBG06" OF oFolder:aDialogs[3] GROUP ACTION FS_PREENCHE() TOOLTIP STR0062 //"Importa Orcamento"

       DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oFolder:aDialogs[3]

//       DEFINE BUTTON RESOURCE "NEXT"    OF oBar ACTION NaoDisp() TOOLTIP "Inclui Item"
//       DEFINE BUTTON RESOURCE "PREV"    OF oBar ACTION NaoDisp() TOOLTIP "Exclui Item"
       DEFINE BUTTON RESOURCE "AUTOM"   OF oBar ACTION NaoDisp() TOOLTIP STR0063 //"Registro de Venda Perdida"
//       DEFINE BUTTON RESOURCE "BUDGETY" OF oBar ACTION NaoDisp() TOOLTIP "STR0021"
       DEFINE BUTTON RESOURCE "CHAVE2"  OF oBar ACTION NaoDisp() TOOLTIP STR0064 //"Libera Venda"
//       DEFINE BUTTON RESOURCE "DBG09"   OF oBar ACTION NaoDisp() TOOLTIP "STR0023"
//       DEFINE BUTTON RESOURCE "COLTOT"  OF oBar ACTION NaoDisp() TOOLTIP "Totaliza Parcialmente a Venda"
//       DEFINE BUTTON RESOURCE "EXCLUIR" OF oBar ACTION NaoDisp() TOOLTIP "Exclui Venda"

//       @ 013,000 LISTBOX oLbIte2 FIELDS HEADER  OemToAnsi("Grupo"     ),;
//                                                OemToAnsi("Codigo"    ),;
//                                                OemToAnsi("Descricao" ),;
//                                                OemToAnsi("Qtdade"    ),;
//                                                OemToAnsi("Valor"     );
//       COLSIZES 20,60,125,30,20,40;
//       SIZE 312,078 OF oFolder:aDialogs[3] ON DBLCLICK (FS_ITEREL890(oLbIte2:nAt),oLbIte2:Refresh()) PIXEL
//
//       oLbIte2:SetArray(aIteRe2)
//       oLbIte2:bLine := { || { aIteRe2[oLbIte2:nAt,1] ,;
//                               aIteRe2[oLbIte2:nAt,2] ,;
//                               aIteRe2[oLbIte2:nAt,3] ,;
//                               Str(aIteRe2[oLbIte2:nAt,4]),;
//                               Transform(aIteRe2[oLbIte2:nAt,5],"999,999,999.99")}}

   ACTIVATE MSDIALOG oDlg CENTER ON INIT (FS_CHBAR890(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()}),FS_ITEREL890())


Return

/*

//////////////////////////
Function FS_ACHAPROD(Arg1)

if nOpca == 2
   Return .t.
Endif

if Arg1 == 1
   if Empty(cCampo36)
      Return .f.
   Endif
   DbSelectArea("SBM")
   DbSetOrder(1)
   if !DbSeek(xFilial("SBM")+cCampo36)
      Return .f.
   Endif
   DbSelectArea("SB1")
   DbSetOrder(7)
Else
   DbSelectArea("SB1")
   DbSetOrder(7)
   DbGotop()
   if !DbSeek(xFilial("SB1")+cCampo36+cCampo1)
      Return(.f.)
   Else
      cCampo36 := SB1->B1_GRUPO
      cCampo2 := SB1->B1_DESC
   Endif
   FS_PREENCHE()
   FS_PESQUDBF()

   oCampo2:refresh()
   oCampo36:refresh()

   aIteRel := FG_ITEREL(VOI->VOI_TIPTEM,SB1->B1_GRUPO,cCampo1,VOI->VOI_VALPEC)
   oLbItem:SetArray(aIteRel)
   oLbItem:bLine := { || { aIteRel[oLbItem:nAt,1] ,;
                           aIteRel[oLbItem:nAt,2] ,;
                           aIteRel[oLbItem:nAt,3] ,;
                           Str(aIteRel[oLbItem:nAt,4]),;
                           Transform(aIteRel[oLbItem:nAt,5],"999,999,999.99")}}
   oLbItem:SetFocus(1)
Endif

Return(.t.)


///////////////////////////
Function FS_ITEREL890(wLin)

if wLin == Nil
   Return(.t.)
Endif

cCampo1 := aIteRel[wLin,2]
cCampo2 := aIteRel[wLin,3]
cCampo36:= aIteRel[wLin,1]

oCampo1:refresh()
oCampo2:refresh()
oCampo36:refresh()

DbSelectArea("SB1")
DbSetOrder(7)
DbGotop()
if !DbSeek(xFilial("SB1")+cCampo36+cCampo1)
   Return(.f.)
Else
   DbSelectArea("VOI")
   DbSetOrder(2)
   DbGotop()
   if !DbSeek(xFilial("VOI")+SB1->B1_LOCPAD)
      Return(.f.)
   Endif
Endif

FS_PESQUDBF()
FS_PREENCHE()

aIteRel := FG_ITEREL(VOI->VOI_TIPTEM,SB1->B1_GRUPO,cCampo1,VOI->VOI_VALPEC)
oLbItem:SetArray(aIteRel)
oLbItem:bLine := { || { aIteRel[oLbItem:nAt,1] ,;
                        aIteRel[oLbItem:nAt,2] ,;
                        aIteRel[oLbItem:nAt,3] ,;
                        Str(aIteRel[oLbItem:nAt,4]),;
                        Transform(aIteRel[oLbItem:nAt,5],"999,999,999.99")}}
oLbItem:SetFocus(1)

Return(.t.)


//////////////////////
Function FS_PREENCHE()

   cCampo7  := SB1->B1_SITPRO
   if cCampo7 == "N"
      cCampo7 := "Normal"
   Elseif cCampo7 == "C"
      cCampo7 := "Cancelada"
   Else
      cCampo7 := "Substituida"
   Endif

   cCampo21 := SB1->B1_IPI
   cCampo11 := SB1->B1_PRV1
   cCampo25 := SB1->B1_UCOM
   cCampo29 := SB1->B1_LOCITE1
   cCampo30 := SB1->B1_LOCITE2
   cCampo31 := SB1->B1_GRUPO

   oCampo3:refresh()
   oCampo4:refresh()
   oCampo5:refresh()
   oCampo6:refresh()
   oCampo7:refresh()
   oCampo8:refresh()
   oCampo9:refresh()
   oCampo11:refresh()
   oCampo14:refresh()
   oCampo21:refresh()
   oCampo22:refresh()
   oCampo25:refresh()
   oCampo29:refresh()
   oCampo30:refresh()
   oCampo31:refresh()
   oCampo37:refresh()
   oCampo38:refresh()

Return


//////////////////////
Function FS_PESQUDBF()

//Substituicao
DbSelectArea("VE9")
DbSetOrder(5)
DbGotop()
if DbSeek(xFilial("VE9")+cCampo36+cCampo1)
   cCampo8 := VE9->VE9_ITENOV
   cCampo9 := VE9->VE9_ITEANT
Else
   cCampo8 := " "
   cCampo9 := " "
Endif

//Kit
DbSelectArea("VE8")
DbSetOrder(2)
DbGotop()
if DbSeek(xFilial("VE8")+cCampo36+cCampo1)
   cCampo6:=VE8->CODKIT
Endif

//Grupo
DbSelectArea("SBM")
DbSetOrder(1)
DbGotop()
wMarca := ""
if DbSeek(xFilial("SBM")+cCampo36)
   wMarca := SBM->BM_CODMAR
Endif

//Marca
DbSelectArea("VE1")
DbSetOrder(1)
DbGotop()
if DbSeek(xFilial("VE1")+wMarca)
   cCampo5 := VE1->VE1_CODMAR
   cCampo37:=VE1->VE1_DESMAR
Else
   cCampo5 :=""
   cCampo37:=""
Endif

//C.A.I.
DbSelectArea("VE2")
DbSetOrder(1)
DbGotop()
if DbSeek(xFilial("VE2")+wMarca+SB1->B1_CODCAI)
   cCampo4 := SB1->B1_CODCAI
   cCampo38:= VE2->VE2_DESCAI
Else
   cCampo4 := ""
   cCampo38:= ""
Endif

//Custo Medio
DbSelectArea("SB2")
DbSetOrder(1)
DbGotop()
if DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
   cCampo22:=SB2->B2_CM1
Else
   cCampo22:=0
Endif

FS_PREENCHE()

Return


////////////////////
Function FS_DISPON()

DbSelectArea("SBE")
DbSetOrder(1)
DbGotop()

xItem := {}
Do while !EOF()
   aadd(xItem,{BE_LOCALIZ,BE_DESCRIC,TRANS(0,"@E 999,999,999.99")})
   DbSkip()
Enddo

if len(xItem) == 0
   aadd(xItem,{"","",""})
Endif

//DbSelectArea("SBF")        {Procurar o Almoxarifado do Produto}
//DbSetOrder(2)
//DbGotop()
//Do while !EOF() .and. SBF->BF_PRODUTO == cCampo1
//Enddo


xOpca := 0

DEFINE MSDIALOG xDlg TITLE "Localizacao do Item" From 9,10 to 28,60 of oMainWnd

   @ 012, 001 LISTBOX oLbHeadx FIELDS HEADER	OemToAnsi("Localizacao"),;
                     				  			   OemToAnsi("Descricao")  ,;
                     								OemToAnsi("Quantidade")  ;
   COLSIZES 50,100,48;
   SIZE 197,131 OF xDlg PIXEL

   oLbHeadx:SetArray(xItem)
   oLbHeadx:bLine := { || { xItem[oLbHeadx:nAt,1] ,;
                      	    xItem[oLbHeadx:nAt,2] ,;
                      	    xItem[oLbHeadx:nAt,3] }}

ACTIVATE MSDIALOG xDlg ON INIT FS_CHC2B910(xDlg,{||xOpca:=1,xDlg:End()},{||xDlg:End()}) CENTER

Return

*/

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHBAR890 ³ Autor ³ Andre                 ³ Data ³03/01/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


Function FS_CHBAR890(oDlg,bOk,bCancel)

Local oBar, bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan, oBtFab
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP STR0020  //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP STR0021  //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP STR0022  //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0023  //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda() TOOLTIP STR0024  //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP OemToAnsi(STR0025)  //"Gerenciador de ImpressÆo..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar ACTION HelProg() TOOLTIP STR0026  //"Help de Programa..."

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE STR0028 OF oBar GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0016  //"OK"###"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE STR0030 OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP STR0031  //"CANCEL"###"Cancelar - <Ctrl-X>"
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

*/

Static Function MenuDef()
Local aRotina := {{"", "",0,1},;
                       {"", "",0,2},;
                       {"", "",0,3},;
                       {"", "",0,4} }
Return aRotina
