#INCLUDE "HSPAHP01.ch"
#include "protheus.CH"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP01  º Autor ³ Cibele             º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Teto Orcamentario                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                    
Function HSPAHP01()
 Local   lExec       := .T.
 Private cCadastro   := OEmToAnsi(STR0001) //"Análise do Teto Orçamentário"
 Private bKeyF12 := SetKey(VK_F12, {|| FS_MntP01()})  
 
 Private cCodPla     := ""
 Private cNrLote_De  := ""
 Private cNrLote_Ate := ""
 Private cTpItem     := ""
 Private cCdItem_De  := ""
 Private cCdItem_Ate := ""

 Private __cCodConv  := ""  //Variavel utilizada na chamada do HSPAHM50
 Private Inclui      := .F.
 Private aHGGK       := {}
 Private aCGGK       := {}
 Private nUGGK       := 0
 Private aCTot       := {}
 Private oDlg, oGGK, oTot
 
 Private nGGK_CDITEM := 0 
 Private nGGK_DSITEM := 0 
 Private nGGK_QTTETO := 0
 Private nGGK_QTCALC := 0
 Private nGGK_QTDIFE := 0
 Private nGGK_VLTETO := 0
 Private nGGK_VLCALC := 0
 Private nGGK_VLDIFE := 0

 lExec := FS_MntP01()

 While lExec
  lExec := FS_P01()
 End 

 SetKey(VK_F12, bKeyF12)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_MntP01 º Autor ³ Cibele             º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filtra os itens da analise orcamentaria                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_MntP01(lFiltro)
 Local lRet          := .F.
 Local aCposCalc     := {}
 Local aRetVTO       := {}
 Local nFor          := 0
 Local cCond         := "" 
 
 Default lFiltro     := .T.

 DbSelectArea("GA7")
 DbSelectArea("GFR")
 DbSelectArea("GAQ")

 If lFiltro
   If !(Pergunte("HSPP01"))
    Return(.F.)
   ElseIf Empty(mv_par01)
    HS_MsgInf(STR0002, STR0003, STR0004) //"Por favor, informe o código do plano"###"Atenção"###"Validação das perguntas"
    Return(.F.)
   Endif
 Endif 
  
 cCond     := "GGK_CODPLA = '" + mv_Par01 + "' AND GGK_TPITEM = '" + Str(mv_par04, 1) + "'"
 If Str(mv_par04, 1) == "1" //Procedimento
  If !Empty(mv_par05) .And. !Empty(mv_par06) 
   	cCond += " AND GGK_CDITEM BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
  ElseIf !Empty(mv_par05)
   cCond += " AND GGK_CDITEM >= '" + mv_par05 + "'"
  ElseIf !Empty(mv_par06)
   cCond += " AND GGK_CDITEM <= '" + mv_par06 + "'"
  Endif	

 ElseIf Str(mv_par04, 1) == "2" //Especialidade
  If !Empty(mv_par07) .And. !Empty(mv_par08) 
   	cCond += " AND GGK_CDITEM BETWEEN '" + PadR(mv_par07, Len(GGK->GGK_CDITEM)) + "' AND '" + PadR(mv_par08, Len(GGK->GGK_CDITEM)) + "'"
  ElseIf !Empty(mv_par07)
   cCond += " AND GGK_CDITEM >= '" + PadR(mv_par07, Len(GGK->GGK_CDITEM)) + "'"
  ElseIf !Empty(mv_par08)
   cCond += " AND GGK_CDITEM <= '" + PadR(mv_par08, Len(GGK->GGK_CDITEM)) + "'"
  Endif	
  
 Else
  If !Empty(mv_par09) .And. !Empty(mv_par10) 
   	cCond += " AND GGK_CDITEM BETWEEN '" + PadR(mv_par09, Len(GGK->GGK_CDITEM)) + "' AND '" + PadR(mv_par10, Len(GGK->GGK_CDITEM)) + "'"
  ElseIf !Empty(mv_par09)
   cCond += " AND GGK_CDITEM >= '" + PadR(mv_par09, Len(GGK->GGK_CDITEM)) + "'"
  ElseIf !Empty(mv_par10)
   cCond += " AND GGK_CDITEM <= '" + PadR(mv_par10, Len(GGK->GGK_CDITEM)) + "'"
  Endif	
 Endif
  
 aCposCalc := {{"GGK_QTTETO", STR0005, "GGK_QTTETO", "TMPGGK->GGK_QTTETO"}, ; //"Qtd.TETO"
               {"GGK_QTTETO", STR0006, "GGK_QTCALC", "0"}, ; //"Qtd.Calc."
               {"GGK_QTTETO", STR0007, "GGK_QTDIFE", "0"}, ; //"Dif.Qtd."
               {"GGK_VLTETO", STR0008, "GGK_VLTETO", "TMPGGK->GGK_VLTETO"}, ; //"Vlr TETO"
               {"GGK_VLTETO", STR0009, "GGK_VLCALC", "0"}, ; //"Vlr.Calc."
               {"GGK_VLTETO", STR0010, "GGK_VLDIFE", "0"}} //"Dif.Vlr "
 
 aHGGK := {}
 aCGGK := {}
 nUGGK := 0

 If HS_BDados("GGK", @aHGGK, @aCGGK, @nUGGK, 1,, cCond,,,,,"GGK_TPITEM/GGK_VLTETO/GGK_QTTETO", .F.,,,,,,,,,,, aCposCalc) == 0
  HS_MsgInf(STR0011 + mv_par01 + "/ " + AllTrim(HS_IniPadr("GCM", 2, mv_par01, "GCM_DESPLA"	)) + STR0012 + CHR(13)+CHR(10) + ; //"O Teto orçamentário do plano ["###"] não foi encontrado."
            STR0013, ; //"Por favor, verifique no cadastro de Convênio/ Diferenciados."
             STR0014, STR0001) //"Verifique"###"Análise do Teto Orçamentário"
  Return(.F.)
 Endif 
  
 cCodPla     := mv_par01
 cNrLote_De  := mv_par02  
 cNrLote_Ate := mv_par03
 
 __cCodConv  := HS_IniPadr("GCM", 2, cCodPla, "GCM_CODCON"	)
 
 cTpItem     := Str(mv_par04, 1)
 cCdItem_De  := IIf(cTpItem == "1", mv_par05, IIf(cTpItem == "2", mv_par07, mv_par09))
 cCdItem_Ate := IIf(cTpItem == "1", mv_par06, IIf(cTpItem == "2", mv_par08, mv_par10))
 
 nGGK_ITEMTO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_ITEMTO"}) 
 nGGK_CDITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_CDITEM"}) 
 nGGK_DSITEM := aScan(aHGGK, {| aVet | aVet[2] == "GGK_DSITEM"}) 
 nGGK_QTTETO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_QTTETO"})
 nGGK_QTCALC := aScan(aHGGK, {| aVet | aVet[2] == "GGK_QTCALC"})
 nGGK_QTDIFE := aScan(aHGGK, {| aVet | aVet[2] == "GGK_QTDIFE"})
 nGGK_VLTETO := aScan(aHGGK, {| aVet | aVet[2] == "GGK_VLTETO"})
 nGGK_VLCALC := aScan(aHGGK, {| aVet | aVet[2] == "GGK_VLCALC"})
 nGGK_VLDIFE := aScan(aHGGK, {| aVet | aVet[2] == "GGK_VLDIFE"})
 
 If Type("oDlg") == "U"
  aAdd(aCTot, aClone(aCGGK[1]))
  aCTot[1][nGGK_ITEMTO] := Space(aHGGK[nGGK_ITEMTO][4]) 
  aCTot[1][nGGK_CDITEM] := Space(aHGGK[nGGK_CDITEM][4]) 
  aCTot[1][nGGK_DSITEM] := STR0015 //"T o t a l"
 Endif
 
 aCTot[1][nGGK_QTTETO] := 0
 aCTot[1][nGGK_QTCALC] := 0
 aCTot[1][nGGK_QTDIFE] := 0
 aCTot[1][nGGK_VLTETO] := 0
 aCTot[1][nGGK_VLCALC] := 0
 aCTot[1][nGGK_VLDIFE] := 0
 
 //Calcula e acumula valores
 For nFor := 1 to Len(aCGGK)
  aCGGK[nFor][nGGK_QTCALC] := (aRetVTO := HS_CalcVTO(cTpItem, aCGGK[nFor][nGGK_CDITEM], cCodPla, cNrLote_De, cNrLote_Ate))[1]
  aCGGK[nFor][nGGK_QTDIFE] := aCGGK[nFor][nGGK_QTTETO] - aCGGK[nFor][nGGK_QTCALC]

  aCGGK[nFor][nGGK_VLCALC] := aRetVTO[2]
  aCGGK[nFor][nGGK_VLDIFE] := aCGGK[nFor][nGGK_VLTETO] - aCGGK[nFor][nGGK_VLCALC]
  
  //Acumula os valores para apresentar na linha de totais
  aCTot[1, nGGK_QTTETO] += aCGGK[nFor][nGGK_QTTETO]
  aCTot[1, nGGK_QTCALC] += aCGGK[nFor][nGGK_QTCALC]
  aCTot[1, nGGK_QTDIFE] += aCGGK[nFor][nGGK_QTDIFE]

  aCTot[1, nGGK_VLTETO] += aCGGK[nFor][nGGK_VLTETO]
  aCTot[1, nGGK_VLCALC] += aCGGK[nFor][nGGK_VLCALC]
  aCTot[1, nGGK_VLDIFE] += aCGGK[nFor][nGGK_VLDIFE]
 Next nFor
 
 If Type("oDlg") <> "U"
  oGGK:aCols := aClone(aCGGK)
  oTot:aCols := aClone(aCTot)
  oGGK:oBrowse:Refresh()
  oTot:oBrowse:Refresh()
 Endif 
 
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_MntP01 º Autor ³ Cibele             º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filtra os itens da analise orcamentaria                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_P01()
 Local lRet    := .T.
 Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local oCodPla, oDesPla

 Define  FONT oFont NAME "Arial,16," BOLD 
 
 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 06, .T., .T.})	
 AAdd(aObjects, {100, 83, .T., .T.})	
 AAdd(aObjects, {100, 11, .T., .T.})	
 
 aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
 
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Análise do Teto Orçamentário"

  @ aPObjs[1][1]+06, aPObjs[1][2]+12 Say STR0016 + ; //"A N Á L I S E   D O   T E T O   O R Ç A M E N T A R I O  - "
                                           cCodPla + "/ " + AllTrim(HS_IniPadr("GCM", 2, cCodPla, "GCM_DESPLA"	)) + ;
                                           " - (" + AllTrim(HS_RDescrB("GGK_TPITEM", cTpItem)) + ")" Of oDlg Pixel COLOR CLR_RED FONT oFont

  oGGK := MsNewGetDados():New(aPObjs[2][1], aPObjs[2][2], aPObjs[2][3], aPObjs[2][4], 0,,,,,, Len(aCGGK),,,, oDlg, aHGGK, aCGGK)
  oGGK:oBrowse:BlDblClick := {|| FS_P01Lot()}  
  
  oTot := MsNewGetDados():New(aPObjs[3][1], aPObjs[3][2], aPObjs[3][3], aPObjs[3][4], 0,,,,,, 1,,,, oDlg, aHGGK, aCTot)

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()})
 
Return(.F.)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_CalcVTOº Autor ³ Cibele             º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula (valor ou quantidade) do item do teto orcamentario º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CalcVTO(cTpItem, cCdItem, cCodPla, cNrLote_De, cNrLote_Ate, cCond)
 Local   aArea       := GetArea()
 Local   cVTO        := ""
 Local   aRet        := {0, 0}

 Default cCodPla     := Space(Len(GCZ->GCZ_CODPLA))
 Default cNrLote_De  := Space(Len(GCZ->GCZ_NRLOTE))
 Default cNrLote_Ate := Space(Len(GCZ->GCZ_NRLOTE))
 Default cCond       := "" 
 
 cVTO := "SELECT SUM(" + HS_FVALDES("GE7") + ") NVALOR, SUM(GE7.GE7_QTDDES) NQUANT"
	cVTO += " FROM " + RetSqlName("GE7") + " GE7"
	cVTO += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial(	"GCZ") + "'"
	cVTO +=   " AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG"
	cVTO +=   " AND GCZ.GCZ_STATUS = '3'"                         
	cVTO +=   " AND GCZ.GCZ_CANCEL <> '1' "
	If !Empty(cCodPla)
 	cVTO += " AND GCZ.GCZ_CODPLA = '" + cCodPla + "'"
 Endif	
	If !Empty(cNrLote_De) .And. !Empty(cNrLote_Ate)
 	cVTO += " AND GCZ.GCZ_NRLOTE BETWEEN '" + cNrLote_De + "' AND '" + cNrLote_Ate + "'"
 ElseIf !Empty(cNrLote_De)
  cVTO += " AND GCZ.GCZ_NRLOTE >= '" + cNrLote_De + "'"
 ElseIf !Empty(cNrLote_Ate)
  cVTO += " AND GCZ.GCZ_NRLOTE <= '" + cNrLote_Ate + "'"
 Endif	
	cVTO +=  " AND GCZ.D_E_L_E_T_ <> '*'" 

 If cTpItem == "3"      //Grupo de Procedimento
 	cVTO += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial(	"GA7") + "'" 
 	cVTO +=   " AND GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7_CODGPP = '" + Padr(cCdItem, Len(GGK->GGK_CDITEM)) + "'"
  cVTO +=   " AND GA7.D_E_L_E_T_ <> '*'" 	
 Endif	
	
	cVTO += " WHERE GE7_FILIAL = '" + xFilial(	"GE7") + "' AND GE7.GE7_PGTMED <> '0'"

 If cTpItem == "1"       //Procedimento
  cVTO += " AND GE7.GE7_CODDES = '" + Padr(cCdItem, Len(GE7->GE7_CODDES)) + "'"
 ElseIf cTpItem == "2"   //Especialidade
 	cVTO += " AND GE7.GE7_CODESP = '" + Padr(cCdItem, Len(GE7->GE7_CODESP)) + "'"
 Endif
 
	cVTO += " AND GE7.D_E_L_E_T_ <> '*'"

 If !Empty(cCond)
  cVTO += " AND " + cCond
 Endif
   
 cVTO := ChangeQuery(cVTO)
 TCQUERY cVTO NEW ALIAS "VTO"
 
 DbSelectArea("VTO")
 If !Eof()
  aRet[1] := VTO->NQUANT
  aRet[2] := VTO->NVALOR
 Endif
  
 DbSelectArea("VTO") 
 DbCloseArea()
 
 RestArea(aArea)
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_P01Lot º Autor ³ Cibele             º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Acessa rotina de atribuicao de lote                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_P01Lot()
 Local     aArea   := GetArea()
 Local     cCdItem := oGGK:aCols[oGGK:nAt, nGGK_CDITEM]
 Private __cFilM50 := ""
                                
 If oGGK:aCols[oGGK:nAt, nGGK_QTCALC] == 0 .And. oGGK:aCols[oGGK:nAt, nGGK_VLCALC] == 0
  Return()
 Endif
                 
 cCdItem := Padr(cCdItem, Len(IIf(cTpItem == "1", GA7->GA7_CODPRO, IIf(cTpItem == "2", GFR->GFR_CDESPE, GAQ->GAQ_GRUPRO))))

 __cFilM50	:= "GCZ_CODPLA = '" + cCodPla + "' AND GCZ_STATUS = '3' AND GCZ_NRLOTE BETWEEN '" + cNrLote_De + "' AND '" + cNrLote_Ate + "' " 
 __cFilM50	+= " AND GCZ_CANCEL <> '1'"
 __cFilM50 += " AND EXISTS (SELECT GE7.GE7_SEQDES FROM " + RetSQLName("GE7") + " GE7"
 
 If cTpItem == "3" 
	 __cFilM50 += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "'"
	 __cFilM50 += " AND GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_CODGPP = '" + Padr(cCdItem, Len(GA7->GA7_CODGPP)) + "'"
	 __cFilM50 += " AND GA7.D_E_L_E_T_ <> '*'"
	Endif 

 __cFilM50 += " WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.GE7_NRSEQG = GCZ_NRSEQG AND GE7.GE7_PGTMED <> '0'" 
	
 If cTpItem == "1"
  __cFilM50 += " AND GE7.GE7_CODDES = '" + Padr(cCdItem, Len(GE7->GE7_CODDES)) + "'"
 ElseIf cTpItem == "2"
 	__cFilM50 += " AND GE7.GE7_CODESP = '" + Padr(cCdItem, Len(GE7->GE7_CODESP)) + "'"
 Endif
 	
	__cFilM50 += " AND GE7.D_E_L_E_T_ <> '*')"
 	
 HSPAHM50() //Rotina de Atribuição de Lote
 SetKey(VK_F12, {|| FS_MntP01()}) 
 FS_MntP01(.F.)
Return(.T.)
