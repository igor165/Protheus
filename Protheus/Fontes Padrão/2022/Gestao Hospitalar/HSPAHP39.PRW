#INCLUDE "HSPAHP39.ch"
#INCLUDE "MSMGADD.CH"
#INCLUDE "Protheus.ch" 
#INCLUDE "Colors.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHP39  บ Autor ณMARCELO JOSE        บ Data ณ  14/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ SOLICITACOES                                               บฑฑ
ฑฑบ          ณ GSA_OK = Status da solicitacao:                            บฑฑ
ฑฑบ          ณ           Vazio = nao atendida                             บฑฑ
ฑฑบ          ณ           0     = Atendida e nao retornada                 บฑฑ
ฑฑบ          ณ           1     = Atendida e retornada                     บฑฑ
ฑฑบ          ณ           2     = Encerrada                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHP39()           

 Local aCor := {}   
 
 Private cCadastro := STR0001 //"Solicita็๕es"
 Private aRotina   := MenuDef()

 Private cDelFunc   := ".T." /* Validacao para a exclusao. Pode-se utilizar ExecBlock */
 Private cGbhDtNasc := CToD(""), cGbhSexo := ""
 Private cString    := "GSA"            
 Private cGsbRegGer := ""
	
 aCor := {	{"Empty(GSA->GSA_OK) .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60)  > 120"                                                                            , "BR_MARRON"  }, ;
          	{"Empty(GSA->GSA_OK) .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60)  >  60 .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60) <=120", "BR_VERMELHO"}, ;
          	{"Empty(GSA->GSA_OK) .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60)  >  30 .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60) <= 60", "BR_AMARELO" }, ;
          	{"Empty(GSA->GSA_OK) .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60)  >  15 .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60) <= 30", "BR_AZUL"    }, ;
          	{"Empty(GSA->GSA_OK) .And. (SubtHoras(GSA->GSA_DATSOL, GSA->GSA_HORSOL,Date(),Time())* 60) <=  15"                                                                            , "BR_VERDE"   }}//, ;
 
 DbSelectArea("GSA")
 DbSetOrder(1) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_DATSOL
 
 mBrowse(6, 1, 20, 50, "GSA",,,,,, aCor,,,,,,,, "GSA_FILIAL = '" + xFilial("GSA") + "' AND GSA_OK = ' '")

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_VAP39  ณ Validacao da alteracao                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_VAP39()

 If Empty(GSA->GSA_OK)
  AxAltera("GSA",, 4)
 Else
  HS_MsgInf(STR0030, STR0034, STR0001)  //"Op็ใo somente disponํvel para prontuแrios ainda Nใo Atendidos."###"Aten็ใo"###"Solicita็๕es"
 EndIf 
Return(Nil)                 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_LegSameณ Legenda da movimentacao                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_LegSame()

 BrwLegenda(cCadastro, STR0009, {	{"BR_VERDE"   , STR0010},; //"Legenda"###"Solicitado at้ 15 min.     "
                                  {"BR_AZUL"    , STR0011},; //"Solicitado at้ 30 min.     "
                              			 {"BR_AMARELO" , STR0012},; //"Solicitado at้  1 hora     "
                              			 {"BR_VERMELHO", STR0013},; //"Solicitado at้  2 horas    "
                              			 {"BR_MARRON"  , STR0014}}) //"Solicitado acima de 2 horas"
                     			  
 Return(.T.)
 
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_Same   ณ Atender a solicitacao e retornar prontuarios               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_Same(nVemOp)

 Local oFont    := Nil
 Local oSay1, oSay2, oSay3, oSay4, oSay5, oMed , oSet , oPro , oMot, oEsp, oDlh , oMemo
 Local cNomeCpo := "", cTitForm := "", cTitUsr := "", nCols := 0, cCodSol := GSA->GSA_CODSOL
 Local bCampo   := {|nCPO| Field(nCPO)}
 Local nOpcA    := 0
 Local oObjMBrw := GetObjBrow()
 Local aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aArea    := GetArea()

 Private nGsaDatSol := 0, nGsaHorSol := 0, nGsaCodEnd := 0, nGsaNomPac := 0, nGsaRegGer := 0, nGsaNomLoc := 0, nGsaNomEnd := 0, nGsaEndRua:= 0, nGsaNumero:= 0, nGsaPrlNum:= 0, nGsaNomPro := 0 ,nGsaRegate:=0
 Private aHeader    := {}, aCols     := {}, oNGDGsa, oBut1, oGet1,oGet2,oGet3,oGet4, oGetZ,oDlg, cMemo := Space(400), nUsado := 0, cCodBar := Iif(GSA->(FieldPos("GSA_REGATE")) > 0,Space(24),Space(18)), cObs := space(50)
 
 HS_BDados("GSA", @aHeader, @aCols, @nUsado, 1, "GSA->GSA_OK == ' '", Nil,,,,,, .T.)

 DbSelectArea("GSA")

 nGsaDatSol := aScan(aHeader, { | aVet | aVet[2] == "GSA_DATSOL"})
 nGsaHorSol := aScan(aHeader, { | aVet | aVet[2] == "GSA_HORSOL"})
 nGsaCodEnd := aScan(aHeader, { | aVet | aVet[2] == "GSA_CODEND"})
 nGsaNomPac := aScan(aHeader, { | aVet | aVet[2] == "GSA_NOMPAC"})
 nGsaRegGer := aScan(aHeader, { | aVet | aVet[2] == "GSA_REGGER"})
 nGsaNomLoc := aScan(aHeader, { | aVet | aVet[2] == "GSA_NOMLOC"})
 nGsaNomMot := aScan(aHeader, { | aVet | aVet[2] == "GSA_NOMMOT"})
 nGsaNomSol := aScan(aHeader, { | aVet | aVet[2] == "GSA_NOMSOL"})
 nGsaCodSol := aScan(aHeader, { | aVet | aVet[2] == "GSA_CODSOL"})
 nGsaNomMed := aScan(aHeader, { | aVet | aVet[2] == "GSA_NOMMED"})
 nGsaNomEnd := aScan(aHeader, { | aVet | aVet[2] == "GSA_NOMEND"})
 nGsaEndRua	:= aScan(aHeader, { | aVet | aVet[2] == "GSA_ENDRUA"})
 nGsaNumero	:= aScan(aHeader, { | aVet | aVet[2] == "GSA_NUMERO"})
 nGsaPrlNum	:= aScan(aHeader, { | aVet | aVet[2] == "GSA_PRLNUM"})
	nGsaNomPro	:= aScan(aHeader, { | aVet | aVet[2] == "GSA_NOMPRO"})
 
 If GSA->(FieldPos("GSA_REGATE")) > 0
 	nGsaRegate	:= aScan(aHeader, { | aVet | aVet[2] == "GSA_REGATE"})
 Endif
 If nGsaDatSol > 0
  aCols[Len(aCols), nGsaDatSol] := Space(8)
 EndIf

 If nGsaHorSol > 0
  aCols[Len(aCols), nGsaHorSol] := Space(5)
 EndIf
 
 If nGsaNomMot > 0
  aCols[Len(aCols), nGsaNomMot] := Space(40)
 EndIf

 If nGsaNomSol > 0
  aCols[Len(aCols), nGsaNomSol] := Space(40)
 EndIf
 
 If nGsaCodSol > 0
  aCols[Len(aCols), nGsaCodSol] := Space(6)
 EndIf
 
 // Atend. solicitacao
 If (nVemOp == 1)
  cTitForm := STR0015	//"SPP - ATENDIMENTO"
  cTitUsr  := STR0016	//"Funcionแrio para Entrega"
 
 // Retorna solicitacao
 ElseIf	(nVemOp == 2)
  cTitForm := STR0017 //"SPP - RETORNO"
  cTitUsr  := STR0018 //"Funcionแrio que Retornou"
 
 // Encerrar solicitacao
 ElseIf	(nVemOp == 4)
   If Empty(GSA_OK)
    cTitForm := STR0019 //"SPP - ENCERRA SOLICITAวรO"
    aCols := {}
   Else 
    Return(Nil)
   EndIf 
 
 // Observacao da solicitacao
 ElseIf	(nVemOp == 5)
   If Empty(GSA_OK)
    cTitForm := STR0031 //"SPP - Observa็ใo da Solicita็ใo"
    aCols    := {}
   Else 
    Return(Nil)
   EndIf 
 EndIf
	 
 aSize 			:= MsAdvSize(.T.)
 aObjects := {}
 
 aAdd(aObjects, {100, 005, .T., .T.})
 AAdd(aObjects, {100, 095, .T., .T.})
 
 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitForm) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd

 // Atend. Solicitacao ou Retorna solicitacao
 If (nVemOp == 1) .Or. (nVemOp == 2)
  // Codigo de barras //
  oSay1 := tSay():New(aPObjs[1, 1] + 15, aPObjs[1, 2] + 002, {||STR0020}, oDlg,, oFont,,,, .T.,,, 130, 10) //"C๓digo de Barras(Pront.+Ender.)"
  oGet1 := tGet():New(aPObjs[1, 1] + 13, aPObjs[1, 2] + 120, {|u| If(PCount()>0, cCodBar :=u , cCodBar)}, oDlg, 70, 10, "@!",{|| HS_ProcA(cCodBar, nVemOp)},,,,,, .T.,,,,,,,,,, "cCodBar") 

  // Grid //
  oNGDGsa := MsNewGetDados():New(aPObjs[2, 1]+12, aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], (GD_INSERT + GD_DELETE ),,,,,, Len(aCols),,,, oDlg, aHeader, aCols)
  oNGDGsa:oBrowse:bDelOk := {|| aCols[oNGDGsa:nAT, nUsado + 1] :=	!aCols[oNGDGsa:nAT, nUsado + 1], oNGDGsa:SetArray(aCols), oNGDGsa:oBrowse:Refresh()}
  oNGDGsa:oBrowse:align := CONTROL_ALIGN_BOTTOM
 EndIf
 
 // Encerrar solicitacao
 If (nVemOp == 4)
  DbSelectArea("GSA")
  DbSetOrder(4) // GSA_FILIAL + GSA_CODSOL
  If DbSeek(xFilial("GSA") + cCodSol)
   oSay1 := tSay():New(aPObjs[1, 1] + 15, aPObjs[1, 2] + 002, {||STR0021}, oDlg,, oFont,,,, .T.,,, 130, 10) //"Nome    : "
   oGet2 := tGet():New(aPObjs[1, 1] + 13, aPObjs[1, 2] + 040, {|u| If(PCount()>0, GSA->GSA_NOMPAC:=u, GSA->GSA_NOMPAC)}, oDlg, 150, 10, "@!",,,,,,, .T.,,,,,,, .T.,,, "GSA->GSA_NOMPAC")    
   oSay2 := tSay():New(aPObjs[1, 1] + 30, aPObjs[1, 2] + 002, {||STR0022}, oDlg,, oFont,,,, .T.,,, 130, 10) //"Endere็o: "
   oGet3 := tGet():New(aPObjs[1, 1] + 28, aPObjs[1, 2] + 040, {|u| If(PCount()>0, GSA->GSA_CODEND:=u, GSA->GSA_CODEND)}, oDlg, 40, 10, "@!",,,,,,, .T.,,,,,,, .T.,,, "GSA->GSA_CODEND")    
   	 		If GSA->(FieldPos("GSA_REGATE")) > 0
   			oSay4 := tSay():New(aPObjs[1, 1] + 46, aPObjs[1, 2] + 002, {||"Reg. Atende"}, oDlg,, oFont,,,, .T.,,, 130, 10) //"Endere็o: "
   			oGet4 := tGet():New(aPObjs[1, 1] + 44, aPObjs[1, 2] + 040, {|u| If(PCount()>0, GSA->GSA_REGATE:=u, GSA->GSA_REGATE)}, oDlg, 40, 10, "@!",,,,,,, .T.,,,,,,, .T.,,, "GSA->GSA_REGATE")    
 		Endif
 		oSay3 := tSay():New(aPObjs[1, 1] + 63, aPObjs[1, 2] + 002, {||STR0023}, oDlg,, oFont,,,, .T., CLR_BLUE,, 200, 10) //"Descreva o Motivo do Encerramento:"
   		oMemo  := tMultiget():New(aPObjs[1, 1] +70 , aPObjs[1, 2] + 002, {|u| If(Pcount()>0, cMemo:=u, cMemo)}, oDlg, 270, 120,,,,,, .T.)
   oMemo:SetFocus()
  EndIf
 EndIf   
 
 // Observacao da solicitacao
 If (nVemOp == 5)
  DbSelectArea("GSA")
  DbSetOrder(4) // GSA_FILIAL + GSA_CODSOL
  If DbSeek(xFilial("GSA") + cCodSol)
   cObs  := GSA->GSA_OBSERV
   oSay1 := tSay():New(aPObjs[1, 1] + 15, aPObjs[1, 2] + 002, {||STR0021}, oDlg,, oFont,,,, .T.,,, 130, 10) //"Nome    : "
   oGet2 := tGet():New(aPObjs[1, 1] + 13, aPObjs[1, 2] + 040, {|u| If(PCount()>0, GSA->GSA_NOMPAC:=u, GSA->GSA_NOMPAC)}, oDlg, 150, 10, "@!",,,,,,, .T.,,,,,,, .T.,,, "GSA->GSA_NOMPAC")    
   oSay2 := tSay():New(aPObjs[1, 1] + 30, aPObjs[1, 2] + 002, {||STR0022}, oDlg,, oFont,,,, .T.,,, 130, 10) //"Endere็o: "
   oGet3 := tGet():New(aPObjs[1, 1] + 28, aPObjs[1, 2] + 040, {|u| If(PCount()>0, GSA->GSA_CODEND:=u, GSA->GSA_CODEND)}, oDlg, 40, 10, "@!",,,,,,, .T.,,,,,,, .T.,,, "GSA->GSA_CODEND")    
 
 		If GSA->(FieldPos("GSA_REGATE")) > 0
 			oSay4 := tSay():New(aPObjs[1, 1] + 46, aPObjs[1, 2] + 002, {||"Reg. Atende"}, oDlg,, oFont,,,, .T.,,, 200, 10) //"Endere็o: "
 			oGet4 := tGet():New(aPObjs[1, 1] + 44, aPObjs[1, 2] + 040, {|u| If(PCount()>0, GSA->GSA_REGATE:=u, GSA->GSA_REGATE)}, oDlg, 40, 10, "@!",,,,,,, .T.,,,,,,, .T.,,, "GSA->GSA_REGATE")    
 		Endif
 		oSay3 := tSay():New(aPObjs[1, 1] + 69, aPObjs[1, 2] + 002, {||STR0032}, oDlg,, oFont,,,, .T., CLR_BLUE,, 200, 10)  //"Observa็ใo: "
 		oGetZ := tGet():New(aPObjs[1, 1] + 70, aPObjs[1, 2] + 040, {|u| If(PCount()>0, cObs:=u, cObs)}, oDlg, 230, 10, "@!",,,,,,, .T.,,,,,,,,,, "cObs")    
   oGetZ:SetFocus()
  EndIf
 EndIf

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()}, {|| nOpcA := 0, oDlg:End()})

 If (nOpcA == 1)
  Begin Transaction 
   HS_Conf(nVemOp)
  End Transaction
  FS_NextGSA()
 EndIf
 
 RestArea(aArea)
 
Return(Nil)   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_ProcA  ณ Monta aCols da Getdados (atualiza matriz)                  บฑฑ
ฑฑบ										ณ	MOVIMENTACAO NO GSA ( ATUALIZACAO NA NEWGETDADOS )									บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function HS_ProcA(cVemEnd, nVemBut)

 Local cAtenCanc  := "", nCtaFor := 1, nCols := 0, lIncOld := Inclui
 Local nBuscaVet  := 0
 Local aArea      := GetArea()
Local cCampRegat :=""
Local cVemEnd1:=""
 
 If Empty(cVemEnd)
  RestArea(aArea)
  Return(.T.)
 EndIf 
 
 cAtenCanc := IIF(nVemBut == 1, " ", "0")
 
 DbSelectArea("GSA")
 DbSetOrder(3) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_CODEND

If GSA->(FieldPos("GSA_REGATE")) > 0 .and. !Empty(SUBS(cVemEnd, 19, 6) )
	cCampRegat:= CriaVar("GSA_REGATE", .F.)
	cVemEnd1:=cVemEnd
Else
	cVemEnd1:=SUBSTR(cVemEnd, 1 ,18)
	cCampRegat:=""
Endif
 If nVemBut == 1 // atender a solicitacao       
	If DbSeek(xFilial("GSA") + "0" + cVemEnd1) //se o prontuario estiver atendido e nao tiver retornado ao same
 		HS_MsgInf(STR0033, STR0034, STR0001)    //"Prontuแrio nใo Retornado ao SPP. A solicita็ใo nใo pode ser atendida."###"Aten็ใo"###"Solicita็๕es"
   DbSetOrder(2) // GSA_FILIAL + GSA_OK + GSA_DATSOL + GSA_HORSOL + GSA_NOMPAC
			RestArea(aArea)

 		// Limpa e seta o focus para o campo do Codigo de Barras
		oGet1:cText := CriaVar("GSA_REGGER", .F.) + CriaVar("GSA_CODEND", .F.) + cCampRegat
			oGet1:SetFocus()
 		Return(.F.)
  EndIf
 EndIf
  

DbSelectArea("GSA")
DbSetOrder(3) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_CODEND 

If DbSeek(xFilial("GSA") + cAtenCanc + cVemEnd1)   
	FOR nCtaFor := 1 To Len(aCols)
		If GSA->(FieldPos("GSA_REGATE")) > 0 .and. !Empty(SUBS(cVemEnd1, 19, 6) )
			If aCols[nCtaFor, nGsaRegGer] == SUBS(cVemEnd1, 1, 6) .And. aCols[nCtaFor, nGsaCodEnd] == SUBS(cVemEnd1, 7, 12) .and. aCols[nCtaFor, nGsaRegAte] == SUBS(cVemEnd1, 19, 6)
				nBuscaVet := nCtaFor
			EndIf
		Else
			If aCols[nCtaFor, nGsaRegGer] == SUBS(cVemEnd1, 1, 6) .And. aCols[nCtaFor, nGsaCodEnd] == SUBS(cVemEnd1, 7, 12) 
				nBuscaVet := nCtaFor
			EndIf	
   EndIf
  Next

  If nBuscaVet > 0

	  // Questiona usuario se deseja deletar o prontuario ou recupera-lo
	  If ApMsgYesNo(IIF (aCols[nBuscaVet, nUsado + 1], STR0057, STR0058)) //"Prontuแrio jแ relacionado. Deseja recuperแ-lo?""###"Prontuแrio jแ relacionado. Deseja excluํ-lo da lista?"
    aCols[nBuscaVet, nUsado + 1] := IIF(aCols[nBuscaVet, nUsado + 1], .F., .T.)
    oNGDGsa:SetArray(aCols)
    oNGDGsa:oBrowse:Refresh()
	  EndIf
  Else 
		If GSA->(FieldPos("GSA_REGATE")) > 0 .and. !Empty(SUBS(cVemEnd1, 19, 6) )
			If Len(aCols) == 0 .Or. !Empty(aCols[Len(aCols), nGsaRegGer]) 	.OR. !Empty(aCols[Len(aCols), nGsaRegate])
			aAdd(aCols, Array(nUsado + 1))
			EndIf 
	    Else
	    	If Len(aCols) == 0 .Or. !Empty(aCols[Len(aCols), nGsaRegGer]) 	
			aAdd(aCols, Array(nUsado + 1))
			EndIf 
			
		Endif
   Inclui := .F. 
   For nCols := 1 To nUsado
    aCols[Len(aCols), nCols] := IIF(aHeader[nCols, 10] # "V", FieldGet(FieldPos(aHeader[nCols, 2])), CriaVar(aHeader[nCols, 2]))
   Next         
   Inclui := lIncOld
   aCols[Len(aCols), nUsado + 1] := .F.
   oNGDGsa:SetArray(aCols)
   oNGDGsa:oBrowse:Refresh()
  EndIf
 Else
	If !Empty(cVemEnd1)
   HS_MsgInf(STR0037, STR0034, STR0001) //"Prontuแrio nใo encontrado."###"Aten็ใo"###"Solicita็๕es"
  EndIf
 EndIf

cCodBar := Iif(GSA->(FieldPos("GSA_REGATE")) > 0,Space(24),Space(18))

 RestArea(aArea)
 
 // Limpa e seta o focus para o campo do Codigo de Barras
oGet1:cText := CriaVar("GSA_REGGER", .F.) + CriaVar("GSA_CODEND", .F.) + cCampRegat
	oGet1:SetFocus()
Return(.F.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_Conf   ณ Gravar os atendimentos e retornos                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function HS_Conf(nVemBut)

 Local nCtaFor		   := 1, lImpr := .F., cAtenCanc := "", cAliasOld
 Local aAgenda 	   := {}
 Local aArea       := GetArea()
 Local cMV_SPPAte  := UPPER(GetMv("MV_SPPATEN"))
 Local cMV_SPPRet  := UPPER(GetMv("MV_SPPRETO"))
 Local cImpProt    := "" 
 cAtenCanc := IIF(nVemBut == 1, " ", "0")

 // Encerrar solicitacao
 IF (nVemBut == 4)
  If Empty(cMemo)
   Return(Nil)    
  EndIf   
 EndIf
 
 If Len(aCols) > 0
  
  // Atend. Solicitacao - Gera Lote
  If (nVemBut == 1)
   cAliasOld := Alias()
   DbSelectArea("GSG")
   DbSetOrder(1) // GSG_FILIAL + GSG_LOTE
   M->GSG_LOTE := CriaVar("GSG_LOTE")
   M->GSG_LOTE := HS_VSxeNum("GSG", "M->GSG_LOTE", 1)
   RecLock("GSG", .T.)
   GSG->GSG_LOTE   := M->GSG_LOTE
   GSG->GSG_DATA   := dDataBase
   GSG->GSG_HORA   := TIME() 
   GSG->GSG_LOGARQ := HS_LOGARQ()
   MsUnLock()
   DbSelectArea(cAliasOld)
  EndIf
  
  DbSelectArea("GSA")
  DbSetOrder(1) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_DATSOL
  For nCtaFor := 1 To Len(aCols)
   If !aCols[nCtaFor, nUsado + 1] 
    If !Empty(aCols[nCtaFor, nGsaDatSol])
     If DbSeek(xFilial("GSA") + cAtenCanc + aCols[nCtaFor, nGsaRegGer] + DTOS(aCols[nCtaFor, nGsaDatSol]))
      RecLock("GSA", .F.)
       If (nVemBut == 1)
        GSA->GSA_OK := "0"
        GSA->GSA_USRENT := Space(HS_CfgSx3("GSA_USRENT")[5])
        GSA->GSA_NOMENT := cUserName
        GSA->GSA_DATENT := DDATABASE
        GSA->GSA_HORENT := TIME()
        GSA->GSA_LOTE   := M->GSG_LOTE
        lImpr := .T.
       ElseIf	(nVemBut == 2)
        GSA->GSA_OK := "1"
        GSA->GSA_USRRET := Space(HS_CfgSx3("GSA_USRRET")[5])
        GSA->GSA_NOMRET := cUserName
        GSA->GSA_DATRET := DDATABASE
        GSA->GSA_HORRET := TIME()
        lImpr := .T.
       EndIf
      	MsUnLock()
							/* Vetor utilizado no Relatorio do HSPAHP42 - Protocolos */
							Aadd(aAgenda,{	.T.,; 
																						GSA->GSA_REGGER,; 
																						aCols[nCtaFor][nGsaNomPac],; 
																						GSA->GSA_CODEND,; 
																						aCols[nCtaFor][nGsaNomEnd],; 
																						aCols[nCtaFor][nGsaEndRua],; 
																						aCols[nCtaFor][nGsaNumero],; 
																						aCols[nCtaFor][nGsaPrlNum],; 
																						GSA->GSA_CODCRM,; 
																						GSA->GSA_CODLOC,; 
																						GSA->GSA_CODPRO,;
																						"",; 
																						"",; 
																						"",; 
																						aCols[nCtaFor][nGsaNomMed],; 
																						aCols[nCtaFor][nGsaNomPro],;
																						"",; 	
																						HS_DTOC(GSA->GSA_DATSOL),;
																						GSA->GSA_HORSOL,;
																						GSA->GSA_NOMSOL,;
																						HS_DTOC(IIF(nVemBut == 1, GSA->GSA_DATENT, GSA->GSA_DATRET)),;
																						IIF(nVemBut == 1, GSA->GSA_HORENT, GSA->GSA_HORRET),;
																						IIF(nVemBut == 1, GSA->GSA_NOMENT, GSA->GSA_NOMRET),;
																						GSA->GSA_CODMOT,;
																						GSA->GSA_OBSERV,;
																						GSA->GSA_CODSOL,;
																						IIf(GSA->(FieldPos("GSA_REGATE")) > 0 ,GSA->GSA_REGATE,"") })		 
     EndIf
    EndIf
   EndIf 
  Next
  If lImpr
   If nVemBut == 1 .Or. nVemBut == 2
    cImpProt := IIF(nVemBut == 1, cMV_SPPAte, cMV_SPPRet) 
    If !Empty(cImpProt) 
     FS_ProtTXT(GSA->GSA_LOTE, cImpProt, aAgenda)
    Else
     HS_ImpSol(GSA->GSA_LOTE, aAgenda, IIF(nVemBut == 1, .T., .F.))
    EndIf
   EndIf
  EndIf 
 Else
  If nVemBut == 4
   RecLock("GSA", .F.)
    GSA->GSA_OK     := "2"
    GSA->GSA_NOMCAN := cUserName
    GSA->GSA_MOTIVO := AllTrim(cMemo)
    GSA->GSA_DATCAN := DDATABASE
    GSA->GSA_HORCAN := TIME()
    GSA->GSA_DATRET := DDATABASE
    GSA->GSA_HORRET := TIME()
   MsUnLock() 
  ElseIf nVemBut == 5
   RecLock("GSA", .F.)
    GSA->GSA_OBSERV := cObs
   MsUnLock()  
  EndIf
 EndIf
 RestArea(aArea)
Return(Nil)


/******************************************************************************************************************/
Function HS_ENDER()
 
 Local cArqAnt   := Alias()
 Local lVerPront := .T.
 Local aArea 				:= GetArea()
 Local nOrd := 3 
 Local cChave:="",cChave1:=""
 
 DbSelectArea("GSD")
 DbSetOrder(1) // GSD_FILIAL + GSD_CODEND + GSD_TIPEND
 If DbSeek(xFilial("GSD") + M->GSA_CODEND)
  If GSD->GSD_EATIVO <> "0" /*0=SIM*/
  	HS_MsgInf(STR0038, STR0034, STR0001) //"Endere็o nใo estแ ativo."###"Aten็ใo"###"Solicita็๕es"
  	RestArea(aArea)
  	Return(.F.)
  EndIf
 EndIf 

 M->GSA_NOMEND := GSD->GSD_DESEND
 M->GSA_ENDRUA := GSD->GSD_ENDRUA
 M->GSA_NUMERO := GSD->GSD_NUMERO
 M->GSA_PRLNUM := GSD->GSD_PRLNUM
 
 DbSelectArea("GSB")
 DbSetOrder(1) // GSB_FILIAL + GSB_REGGER + GSB_CODEND +GSB_REGATE 
 If !DbSeek(xFilial("GSB") + M->GSA_REGGER + M->GSA_CODEND)
 	HS_MsgInf(STR0035, STR0034, STR0001)  //"Relacionamento Prontuแrio x Endere็o nใo existe."###"Aten็ใo"###"Solicita็๕es"
 	lVerPront := .F.  
 Else
 	DbSelectArea("GSA")
 	DbSetOrder(nOrd) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_CODEND  +GSA_REGATE

 If GSA->(FieldPos("GSA_REGATE")) > 0	
 	cChave :=DbSeek(xFilial("GSA") + " " + M->GSA_REGGER + M->GSA_CODEND + M->GSA_REGATE) 
 	cChave1:=DbSeek(xFilial("GSA") + "0" + M->GSA_REGGER + M->GSA_CODEND + M->GSA_REGATE)
 Else
	cChave:=DbSeek(xFilial("GSA") + " " + M->GSA_REGGER + M->GSA_CODEND) 
	cChave1:=DbSeek(xFilial("GSA") + "0" + M->GSA_REGGER + M->GSA_CODEND)
 Endif 
 	
  If cChave
   If HS_CountTB("GSA",	"GSA_OK = ' ' AND GSA_REGGER = '" + M->GSA_REGGER + "' AND GSA_CODEND = '" + M->GSA_CODEND + "' AND GSA_CODLOC = '" + M->GSA_CODLOC + "'" +Iif(GSA->(FieldPos("GSA_REGATE")) > 0 , "AND GSA_REGATE = '" + M->GSA_REGATE+ "'","") ) > 0
  		HS_MsgInf(STR0036, STR0034, STR0001)  //"Prontuแrio jแ solicitado para o setor."###"Aten็ใo"###"Solicita็๕es"
   	lVerPront := .F.
   Else
    If MsgYesNo(STR0061 + GSA->GSA_CODSOL + STR0062 + DTOC(GSA->GSA_DATSOL) + STR0063 + ; //"Jแ existe uma solicita็ใo ["###"] nใo atendida para o prontuแrio/endere็o. A solicita็ใo foi gerada em "###" เs "
     GSA->GSA_HORSOL + STR0064 + GSA->GSA_CODLOC + STR0065, STR0034) //" para o setor "###". Confirma a nova solicita็ใo?"###"Aten็ใo"
     lVerPront := .T.
    Else 
     lverPront := .F.            			
    EndIf      
 	 EndIf
  ElseIf cChave1	
  	If HS_CountTB("GSA",	"GSA_OK = '0' AND GSA_REGGER = '" + M->GSA_REGGER + "' AND GSA_CODEND = '" + M->GSA_CODEND + "' AND GSA_CODLOC = '" + M->GSA_CODLOC + "'" +Iif(GSA->(FieldPos("GSA_REGATE")) > 0 , "AND GSA_REGATE = '" + M->GSA_REGATE+ "'","") ) > 0
	 		HS_MsgInf(STR0036, STR0034, STR0001)  //"Prontuแrio jแ solicitado para o setor."###"Aten็ใo"###"Solicita็๕es"
  		lVerPront := .F.
	 	Else
    If MsgYesNo(STR0061 + GSA->GSA_CODSOL + STR0066 + DTOC(GSA->GSA_DATSOL) + STR0063 + ; //"Jแ existe uma solicita็ใo ["###"] atendida e nใo retornada para o prontuแrio/endere็o. A solicita็ใo foi gerada em "###" เs "
     GSA->GSA_HORSOL + STR0064 + GSA->GSA_CODLOC + STR0065, STR0034) //" para o setor "###". Confirma a nova solicita็ใo?"###"Aten็ใo"
     lVerPront := .T.
    Else 
     lverPront := .F.
    EndIf      
	 	EndIf
  EndIf
 EndIf
 If lVerPront
  If GSD->GSD_ARQEXT == "1"
  	HS_MsgInf(STR0039 + Str(GSD->GSD_DIASEN, 2, 0) + STR0040, STR0034, STR0001)  //"Este endere็o de prontuแrio ้ externo, o prazo para entrega das fichas ้ de: "###" dias."###"Aten็ใo"###"Solicita็๕es"
  EndIf
 EndIf
 
 DbSelectArea(cArqAnt)
 RestArea(aArea)
Return( lVerPront )        


/******************************************************************************************************************/
Function HS_VALP39(nPar)
 Local lRet := .T.

 If nPar == 1
  cGbhSexo := M->GSA_SEXO
 ElseIf nPar == 2
  cGbhDtNasc := M->GSA_DTNASC
 EndIf   
Return(lRet)                          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_P39()  บAutor  ณEduardo Alves       บ Data ณ  06/14/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsultar Prontuarios, Informacoes Paciente, Extrato Atendi บฑฑ
ฑฑบ          ณmento, Saida Multipla                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdministracao Hospitalar                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_P39(cAlias, nReg, nOpc)
	
	Local cRegGer := "", cCodend := ""
	Local cCodLoc := "", cCodPro := "", cCodMed := "", cMotivo := "", cNomMed := "", cCpoNao := ""
	Local nGDOpc := IIF(Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0), nOpcE := 0
	Local oSayCodLoc, oSayNomLoc,	 oSayCodPro, oSayNomPro, oSayCodCrm,	oSayNomMed, oSayObs
	Local nLin := 0, nCol := 0, nCount := 0, nCField := 0
	Local aField := {}, aCpoCTX := {}, aCpoENC := {}, aJoin := {}, aCposIni := {}
	Local oSCodBar, oGCodBar
	Local aArea := GetArea()
 Local oPMemo, oTxtMemo, cTxtMemo := ""
 Local nGsaCodSol := 0, nGsaMotiv := 0
 Local cOrderBy	:= ""

	Private cGsaCodBar := CriaVar("GSA_REGGER", .F.) + CriaVar("GSA_CODEND", .F.), nAtend := 0, oGetCodBar
	Private aTela	:= {}, aGets := {}
	Private aHGSA := {}, aCGSA := {}, nUGSA := 0
	Private oGSA, nGsaNomPac := 0, nGsaNomEnd := 0, nGsaCodEnd := 0, nGsaNumero := 0, nGsaPrlNum := 0, nGsaRegGer := 0,nGsaRegAte:=0
 	
	If nOpc == 12 /* Consultar */
  
		/* Sugere na pergunta o GSA que esta selecionado no momento */
		HS_PosSX1({{"HSP39A", "01", GSA->GSA_REGGER}})

		If !Pergunte("HSP39A", .T.)
			Return()	
		EndIf
	 
	 cRegGer := MV_PAR01
	 cCodend := MV_PAR02
	 
	 DbSelectArea("GBH")              
 	DbSetOrder(1) // GBH_FILIAL + GBH_CODPAC
 	DbSeek(xFilial("GBH") + cRegGer)
	 
	 RegToMemory("GBH", .F.)
	 
	 aCposIni := {"GSA_DATENT", "GSA_HORENT", "GSA_DATRET", "GSA_HORRET", "GSA_DATCAN", "GSA_HORCAN", "GSA_NOMLOC", ;
               "GSA_NOMMED", "GSA_NOMPRO", "GSA_OBSERV", "GSA_NOMMOT", "GSA_MOTIVO", "GSA_LOTE"  , "GSA_CODSOL", "GSA_DATSOL", "GSA_HORSOL",;
               "GSA_NOMSOL", "GSA_NOMENT", "GSA_NOMRET", "GSA_NOMCAN", "GSA_CODEND", "GSA_NOMEND"}
                                   
  cCpoNao := "GSA_REGGER/GSA_NOMPAC/GSA_SEXO  /GSA_DTNASC/GSA_ENDRUA/GSA_NUMERO/GSA_PRLNUM" +Iif(GSA->(FieldPos("GSA_REGATE")) > 0 ,"/GSA_REGATE","")
	 
	 aAdd(aJoin, {"      JOIN " + RetSqlName("GCS") + " GCS" ,"GCS.GCS_NOMLOC", "GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GSA.GSA_CODLOC" , "GSA_NOMLOC"})
  aAdd(aJoin, {" LEFT JOIN " + RetSqlName("SRA") + " SRA" ,"SRA.RA_NOME"   , "SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GSA.GSA_CODCRM" , "GSA_NOMMED"})
  aADD(aJoin, {" LEFT JOIN " + RetSqlName("GA7") + " GA7" ,"GA7.GA7_DESC"  , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GSA.GSA_CODPRO" , "GSA_NOMPRO"})
  aADD(aJoin, {"      JOIN " + RetSqlName("GSC") + " GSC" ,"GSC.GSC_DESMOT", "GSC.GSC_FILIAL = '" + xFilial("GSC") + "' AND GSC.D_E_L_E_T_ <> '*' AND GSC.GSC_CODMOT = GSA.GSA_CODMOT" , "GSA_NOMMOT"})
	 aADD(aJoin, {"      JOIN " + RetSqlName("GSD") + " GSD" ,"GSD.GSD_DESEND", "GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' AND GSD.GSD_CODEND = GSA.GSA_CODEND" , "GSA_NOMEND"})
	
	 cOrderBy := "GSA.GSA_FILIAL, GSA.GSA_CODSOL DESC, GSA.GSA_DATSOL DESC, GSA.GSA_HORSOL DESC"

		HS_BDados("GSA", @aHGSA, @aCGSA, @nUGSA, 1, cRegGer, IIF(!Empty(cCodend), "'"+ cRegGer + "' == GSA->GSA_REGGER AND '"+ cCodend + "' == GSA->GSA_CODEND", "'"+ cRegGer + "' == GSA->GSA_REGGER"),,,,, cCpoNao,,,,,,,,,, aCposIni, aJoin,, cOrderBy)

  nGsaCodSol := aScan(aHGSA, { | aVet | aVet[2] == "GSA_CODSOL"})
  nGsaMotiv  := aScan(aHGSA, {|aVet| aVet[2] == "GSA_MOTIVO"})  

	 aSize 			:= MsAdvSize(.T.)
	 aObjects := {}
	 
	 AAdd(aObjects, { 100, 020, .T., .T.})	
	 AAdd(aObjects, { 100, 070, .T., .T.})	
	 AAdd(aObjects, { 100, 010, .T., .T., .T. })	

	 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
	 aPObjs := MsObjSize(aInfo, aObjects, .T.)        
	 
	 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0041) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Consulta da Movimenta็ใo"
	  
	  oEnchoi := MsMGet():New("GBH", 0, 2,,,, {"GBH_CODPAC", "GBH_NOME", "GBH_DTNASC", "GBH_SEXO"}, aPObjs[1],,,,,, oDlg)
	  oEnchoi:oBox:align := CONTROL_ALIGN_TOP    
	
	  oGSA := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0,,,,,, 99999,,,, oDlg, aHGSA, aCGSA)
	  oGSA:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
   oGSA:oBrowse:BlDblClick := {|| HS_PRECPME(oGSA, nGsaMotiv, "GSA", "_MOTIVO")}

   oGSA:bChange := {|| cTxtMemo := HS_IniPadr("GSA", 4, oGSA:aCols[oGSA:nAt,nGSaCodSol], "GSA_MOTIVO"), oTxtMemo:Refresh()}
 
   oPMemo	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4])
   oPMemo:Align := CONTROL_ALIGN_BOTTOM

   @ 000, 000 GET oTxtMemo VAR OemToAnsi(cTxtMemo) MEMO READONLY /*NO VSCROLL*/ SIZE aPObjs[3, 3], aPObjs[3, 4] OF oPmemo PIXEL
	
	  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| oDlg:End()}, {|| oDlg:End()})
	 
 ElseIf nOpc == 13 /* Paciente */

		HS_PosSX1({{"HSP39C", "01", GSA->GSA_REGGER}})

		If !Pergunte("HSP39C", .T.)
			Return()	
		EndIf
 	
 	DbSelectArea("GBH")              
 	DbSetOrder(1) // GBH_FILIAL + GBH_CODPAC
 	DbSeek(xFilial("GBH") + MV_PAR01)
  HS_A58("GBH", GBH->(RecNo()), nOpc)          
 
 ElseIf nOpc == 14 /* Extrato do Atendimento */



		HS_PosSX1({{"HSP39C", "01", GSA->GSA_REGGER}})		
		If Pergunte("HSP39C", .T.)
			HS_EXTM24C(MV_PAR01, "P", 2)
		EndIf

 ElseIf nOpc == 15 /* Saida Multipla */
 
 	If !Pergunte("HSP39B", .T.)
 		Return()
 	EndIf
 	
		cCodLoc := MV_PAR01
		cCodPro := MV_PAR02
		cCodMed := MV_PAR03
		cMotivo := MV_PAR04
		nAtend 	:= MV_PAR05
  
  RegToMemory("GSA", .F.)
  
  HS_BDados("GSA", @aHGSA, @aCGSA, @nUGSA, 1,, Nil,,, "GSA_REGGER/GSA_CODEND/GSA_NOMEND/GSA_NOMPAC/GSA_NUMERO/GSA_PRLNUM/GSA_ENDRUA " + Iif(GSA->(FieldPos("GSA_REGATE")) > 0,"/GSA_REGATE",""),,,,,, .T.,,,,,,,,,, {"GSA_REGGER", "GSA_CODEND",Iif(GSA->(FieldPos("GSA_REGATE")) > 0,"GSA_REGATE","")})
  nGsaRegGer := aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_REGGER"})
  nGsaNomPac := aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_NOMPAC"})
 	nGsaCodEnd	:= aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_CODEND"})
 	nGsaNomEnd	:= aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_NOMEND"})
		nGsaNumero	:= aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_NUMERO"})
		nGsaPrlNum	:= aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_PRLNUM"}) 	
		nGsaEndRua	:= aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_ENDRUA"}) 	
   If GSA->(FieldPos("GSA_REGATE")) > 0
  nGsaRegAte    := aScan(aHGSA, {| aVet | AllTrim(aVet[2]) == "GSA_REGATE"})	 
  Endif
	 
	 aSize 			:= MsAdvSize(.T.)
	 aObjects := {}
	 
	 AAdd(aObjects, {100, 050, .T., .T. })	
	 AAdd(aObjects, {100, 050, .T., .T. })	
	 	 
	 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
	 aPObjs := MsObjSize(aInfo, aObjects, .T.)        
	 
	 nLin := 15
	 nCol := 50
	 
	 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0042) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Saํda M๚ltipla"
	  
	 aCpoENC	:= {"GSA_CODLOC", "GSA_NOMLOC", "GSA_CODPRO", "GSA_NOMPRO", "GSA_CODCRM", "GSA_NOMMED", "GSA_CODMOT", "GSA_NOMMOT", "GSA_OBSERV", "GSA_CODBAR"}
	 
	 M->GSA_CODLOC := cCodLoc
  M->GSA_NOMLOC := HS_IniPadR('GCS', 1, M->GSA_CODLOC, 'GCS_NOMLOC',, .F.)
	 M->GSA_CODPRO := cCodPro
	 M->GSA_NOMPRO := HS_IniPadR('GA7', 1, M->GSA_CODPRO, 'GA7_DESC',, .F.)
	 M->GSA_CODCRM := cCodMed                                                 
	 M->GSA_NOMMED := HS_IniPadR('SRA',11, M->GSA_CODCRM, 'RA_NOME',, .F.)
	 M->GSA_CODMOT := cMotivo   
	 M->GSA_DESMOT := HS_IniPadR('GSC', 1, M->GSA_CODMOT, 'GSA_NOMMOT',, .F.)
	 M->GSA_ORISOL := "1"


	 	oEnchoice := MsMGet():New("GSA",0,3,,,, aCpoEnc,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},{"GSA_OBSERV","GSA_CODBAR"},,,,, oDlg,, .F.)      
	 	
	 	oEnchoice:oBox:align:= CONTROL_ALIGN_ALLCLIENT
			//oEnchoice:aEntryCtrls[aScan(aCpoEnc, {|aVet| aVet == "GSA_OBSERV"})]:BWHEN := {|| .T.}
			oGetCodBar := oEnchoice:aEntryCtrls[ aScan(aCpoEnc, {|aVet| aVet == "GSA_CODBAR"}) ]
			oEnchoice:Refresh()

	  oGSA := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,, 99999,,,, oDlg, aHGSA, aCGSA)
	  oGSA:oBrowse:align := CONTROL_ALIGN_BOTTOM
			oGSA:Refresh()
			
	 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcE := 1, IIF(oGSA:TudoOk(), oDlg:End(), nOpcE := 0)},;
	                                                   {|| nOpcE := 0, oDlg:End()})
	 
	 If nOpcE == 1
	 	/* Inicia gravacao do Lote */
   Begin Transaction
   
   If (nAtend == 1)
    DbSelectArea("GSG")
    DbSetOrder(1) // GSG_FILIAL + GSG_LOTE
    M->GSG_LOTE := CriaVar("GSG_LOTE")
    M->GSG_LOTE := HS_VSxeNum("GSG", "M->GSG_LOTE", 1)
    RecLock("GSG", .T.)
    GSG->GSG_LOTE   := M->GSG_LOTE
    GSG->GSG_DATA   := dDataBase
    GSG->GSG_HORA   := TIME() 
    GSG->GSG_LOGARQ := HS_LOGARQ()
    MsUnLock()
   EndIf
			 	
	 	/* Inicia gravacao da GSA*/	
	 	For nCount := 1 To Len(oGSA:Acols)
	 		If oGSA:Acols[nCount][nUGSA + 1] == .F. /* Se nao for deletado */
		 		cCodNovo := GetSx8Num("GSA","GSA_CODSOL")
	 			RecLock("GSA", .T.)
     GSA->GSA_CODSOL := cCodNovo
     GSA->GSA_DATSOL := DDATABASE
     GSA->GSA_HORSOL := TIME()
	 			GSA->GSA_REGGER	:= oGSA:Acols[nCount][nGsaRegGer]
	 			GSA->GSA_CODEND	:= oGSA:Acols[nCount][nGsaCodEnd]
	 			GSA->GSA_CODLOC := cCodLoc
	 			GSA->GSA_CODCRM	:= cCodMed
	 			GSA->GSA_NOMPAC	:= oGSA:Acols[nCount][nGsaNomPac]
	 			GSA->GSA_CODPRO	:= cCodPro
	 			GSA->GSA_CODMOT	:= cMotivo
     GSA->GSA_NOMSOL := cUserName
     GSA->GSA_LOGARQ := HS_LOGARQ()
     GSA->GSA_OBSERV := M->GSA_OBSERV
    If GSA->(FieldPos("GSA_REGATE")) > 0
     GSA->GSA_REGATE	:= oGSA:Acols[nCount][nGsaRegAte]
	 Endif				
					If nAtend == 1 
     	GSA->GSA_OK     := "0"
     	GSA->GSA_LOTE   := M->GSG_LOTE
     	GSA->GSA_DATENT := DDATABASE
     	GSA->GSA_HORENT := TIME()
     	GSA->GSA_USRENT := "  "
     	GSA->GSA_NOMENT := cUserName
					EndIf                                   
					
					If Hs_ExisDic({{"C","GSA_ORISOL"}})
					 GSA->GSA_ORISOL := "2"
					EndIf

	 			MsUnLock()
	 		EndIf
	 	 While __lSx8 
	 	  ConfirmSX8() 
	 	 End
	 	Next nCount
	 	
	 	End Transaction
	 	
	 	/* Chama relatorio de Protocolo do HSPAHP42 passando o campo M->GSG_LOTE como parametro */
			If nAtend == 1 
				HSPAHR72("HSPAHP39", M->GSG_LOTE)
			EndIf
	 Else 
	  While __lSx8
    RollBackSx8()
   End
	 EndIf
 
 EndIf
 
 RestArea(aArea)
 
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldP39 บAutor  ณEduardo Alves       บ Data ณ  06/14/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para valida็ใo dos campos.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdministracao Hospitalar                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldP39(cPerg)

	Local aArea := GetArea()
	Local lRet  := .T.
	
	Default cPerg := "" 
	
	If cPerg == "HSP39A"
	
		If ReadVar() == "MV_PAR01"
			DbSelectArea("GSA")     
			DbSetOrder(7) //GSA_FILIAL + GSA_REGGER + GSA_CODEND
			If !DbSeek(xFilial("GSA") + MV_PAR01)
	 		HS_MsgInf(STR0043, STR0034, STR0044) //"Nenhuma solicita็ใo encontrada para o prontuแrio informado."###"Aten็ใo"###"Valida็ใo dos Parโmetros"
	 		lRet := .F.
			Else
			 cGsbRegGer := MV_PAR01
			EndIf
		ElseIf ReadVar() == "MV_PAR02"
		 If !Empty(MV_PAR02)
			 DbSelectArea("GSA")
			 DbSetOrder(7) //GSA_FILIAL + GSA_REGGER + GSA_CODEND
		  If !DbSeek(xFilial("GSA") + MV_PAR01 + MV_PAR02)
			  HS_MsgInf(STR0060, STR0034, STR0044) //"Nenhuma solicita็ใo encontrada para o prontuแrio e endere็o informado."###"Aten็ใo"###"Valida็ใo dos Parโmetros"
 		  lRet := .F.
 		 EndIf
			EndIf 
		EndIf
			
	ElseIf cPerg == "HSP39B"
		
		If ReadVar() == "MV_PAR01" /* Setor */
			DbSelectArea("GCS")
			DbSetOrder(1) // GCS_FILIAL + GCS_CODLOC
			If !DbSeek(xFilial("GCS") + MV_PAR01)
	 		HS_MsgInf(STR0045, STR0034, STR0044) //"Setor nใo cadastrado."###"Aten็ใo"###"Valida็ใo dos Parโmetros"
	 		lRet := .F.
			EndIf
		ElseIf ReadVar() == "MV_PAR02" .And.	!Empty(MV_PAR02) /* Procedimento */
			DbSelectArea("GA7")
			DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
			If !DbSeek(xFilial("GA7") + MV_PAR02)
	 		HS_MsgInf(STR0046, STR0034, STR0044) //"Procedimento nใo cadastrado."###"Aten็ใo"###"Valida็ใo dos Parโmetros"
	 		lRet := .F.
			EndIf
		ElseIf ReadVar() == "MV_PAR03" .And.	!Empty(MV_PAR03) /* Medico */
			DbSelectArea("SRA")
			DbSetOrder(11) // RA_FILIAL + RA_CODIGO
			If !DbSeek(xFilial("SRA") + MV_PAR03)
	 		HS_MsgInf(STR0047, STR0034, STR0044) //"M้dico nใo cadastrado."###"Aten็ใo"###"Valida็ใo dos Parโmetros"
	 		lRet := .F.
			EndIf
		ElseIf ReadVar() == "MV_PAR04" .And.	!Empty(MV_PAR04) /* Motivo */
			DbSelectArea("GSC")
			DbSetOrder(1) // GSC_ FILIAL + GSC_CODMOT
			If !DbSeek(xFilial("GSC") + MV_PAR04)
	 		HS_MsgInf(STR0048, STR0034, STR0044) //"Motivo nใo cadastrado."###"Aten็ใo"###"Valida็ใo dos Parโmetros"
	 		lRet := .F.
			EndIf
		EndIf
	
	ElseIf cPerg == ""

		If ReadVar() == "M->GSA_REGGER"
			DbSelectArea("GSB")
			DbSetOrder(1) // GSB_FILIAL + GSB_REGGER + GSB_CODEND
			If !DbSeek(xFilial("GSB") + M->GSA_REGGER)
	 		HS_MsgInf(STR0052, STR0034, STR0044) //"Prontuแrio nใo estแ relacionado com nenhum endere็o."###"Aten็ใo"###"Valida็ใo dos Parโmetros"
	 		lRet := .F.
			EndIf
		 If lRet
		  DbSelectArea("GBH")
		  DbSetOrder(1)  // GBH_FILIAL + GBH_CODPAC
		  If DbSeek(xFilial("GBH") + M->GSA_REGGER)
		   M->GSA_DTNASC := GBH->GBH_DTNASC
		   M->GSA_SEXO   := GBH->GBH_SEXO
		  Endif
		 Endif  
		EndIf
	
	EndIf
	RestArea(aArea)
Return(lRet)               


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AddSol บAutor  ณEduardo Alves       บ Data ณ  03/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada na saida multipla para adicionar dados na  บฑฑ
ฑฑบ          ณGetDados.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_AddSol(oGetCodBar, nAtend)

 Local nCtaFor := 0, nBuscaVet := 0, cMsgPerg := ""
 Local lInclui := .T.
 Local nOrd := 3
 
 M->GSA_REGGER	:= SubStr(oGetCodBar:cText, 1, Len(CriaVar("GSA_REGGER", .F.)))
 M->GSA_CODEND	:= SubStr(oGetCodBar:cText, Len(CriaVar("GSA_REGGER", .F.)) + 1, Len(CriaVar("GSA_CODEND", .F.)))
 If HS_ENDER()
  If GSA->(FieldPos("GSA_REGATE")) > 0
 	M->GSA_REGATE  := SubStr(oGetCodBar:cText, Len(CriaVar("GSA_CODEND", .F.)) + 1, Len(CriaVar("GSA_REGATE", .F.)))
  Endif
  
		DbSelectArea("GSA")
		DbSetOrder(nOrd) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_CODEND //+ GSA_REGATE

 	// Verifica se o usurio esta tentando atender uma solicitacao onde o prontuario ainda nao retornou ao SPP.
 	If	(nAtend == 1) .And.  IIf(GSA->(FieldPos("GSA_REGATE")) > 0,DbSeek(xFilial("GSA") + "0" + M->GSA_REGGER + M->GSA_CODEND + M->GSA_REGATE),DbSeek(xFilial("GSA") + "0" + M->GSA_REGGER + M->GSA_CODEND))
			HS_MsgInf(STR0054, STR0034, STR0055)//"Nใo ้ possivel atender a esta solicita็ใo, pois o prontuแrio informado ainda nใo retornou ao SPP."###"Aten็ใo"###"Atendimento de solicita็ใo"
 		lInclui := .F.
 	
 	// Questiona o usuario se permiti atender uma solicitacao na frente de uma que ainda nao foi solicitada de outro usuario
 	ElseIf		(nAtend == 1) .And.	 IIf(GSA->(FieldPos("GSA_REGATE")) > 0,DbSeek(xFilial("GSA") + " " + M->GSA_REGGER + M->GSA_CODEND + M->GSA_REGATE),DbSeek(xFilial("GSA") + " " + M->GSA_REGGER + M->GSA_CODEND))
 		If !ApMsgYesNo(STR0056)	//"Jแ existe uma solicita็ใo nใo atendida para o prontuแrio. Deseja atender a esta solicita็ใo?"
 			lInclui := .F.
 		EndIf
 
 	EndIf

		
		If lInclui
		
			// Verifica se o prontuario + endereco ja esta cadastrado
			For nCtaFor := 1 To Len(aCGSA)
		   		If GSA->(FieldPos("GSA_REGATE")) > 0
	 				If aCGSA[nCtaFor, nGsaRegGer] == M->GSA_REGGER .And. aCGSA[nCtaFor, nGsaCodEnd] == M->GSA_CODEND .And. aCGSA[nCtaFor, nGsaRegAte] == M->GSA_REGATE
	  		nBuscaVet := nCtaFor
	  		Exit
	  	EndIf
	  	    	Else                
	  	    		If aCGSA[nCtaFor, nGsaRegGer] == M->GSA_REGGER .And. aCGSA[nCtaFor, nGsaCodEnd] == M->GSA_CODEND 
	  					nBuscaVet := nCtaFor
	  					Exit
	  	    		EndIf
	  	    	Endif
	 	Next
	
	  If (nBuscaVet > 0)
	   // Questiona usuario se deseja deletar o prontuario ou recupera-lo
	   cMsgPerg := IIF (aCGSA[nBuscaVet, nUGsa + 1], STR0057, STR0058)//"Prontuแrio jแ relacionado. Deseja recuperแ-lo?"###"Prontuแrio jแ relacionado. Deseja excluํ-lo da lista?"
	   
	   If ApMsgYesNo(cMsgPerg)
	    aCGSA[nBuscaVet, nUGsa + 1] := IIF(aCGSA[nBuscaVet, nUGsa + 1], .F., .T.)
	    oGsa:SetArray(aCGSA)
	    oGsa:oBrowse:Refresh()
	   EndIf
	  
	  Else
	   
	  	// Inclui prontuario
		  If Len(aCGSA) == 0 .Or. !Empty(aCGSA[Len(aCGSA), nGsaRegGer])
		   aAdd(aCGSA, Array(nUGSA + 1))
		  EndIf
		
		 	aCGSA[Len(aCGSA)][nGsaRegGer] := M->GSA_REGGER
		 	aCGSA[Len(aCGSA)][nGsaNomPac] := HS_IniPadR("GBH", 1, M->GSA_REGGER, "GBH_NOME",, .F.)
		 	aCGSA[Len(aCGSA)][nGsaCodEnd] := M->GSA_CODEND
		 	aCGSA[Len(aCGSA)][nGsaNomEnd] := M->GSA_NOMEND
		 	aCGSA[Len(aCGSA)][nGsaPrlNum] := M->GSA_PRLNUM
		 	aCGSA[Len(aCGSA)][nGsaNumero] := M->GSA_NUMERO
		 	aCGSA[Len(aCGSA)][nGsaEndRua] := M->GSA_ENDRUA
     	 	If GSA->(FieldPos("GSA_REGATE")) > 0
     	    aCGSA[Len(aCGSA)][nGsaRegAte] := M->GSA_REGATE
     	    Endif
		  aCGSA[Len(aCGSA), nUGSA + 1]  	:= .F.
		
		  oGsa:SetArray(aCGSA) 
		  oGsa:oBrowse:Refresh()
		
			EndIf

		EndIf

	EndIf
 
 // Limpa e seta o focus para o campo do Codigo de Barras
 oGetCodBar:cText := CriaVar("GSA_REGGER", .F.) + CriaVar("GSA_CODEND", .F.) +  Iif(GSA->(FieldPos("GSA_REGATE")) > 0,+ CriaVar("GSA_REGATE", .F.),"")
	oGetCodBar:SetFocus()
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_NextGSAบAutor  ณEduardo Alves       บ Data ณ  14/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada para posicionar a GSA no proximo registro  บฑฑ
ฑฑบ          ณque tenha o campo GSA_OK == ' '.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_NextGSA()

	Local cIndexOld := GSA->(IndexOrd())
	
	DbSetOrder(4) // GSA_FILIAL + GSA_CODSOL 
	DbSeek(xFilial("GSA") + GSA->GSA_CODSOL)
	While !Eof() .And. (GSA->GSA_OK # CriaVar("GSA_OK", .F.))
		DbSkip()
 EndDo
 DbSetOrder(cIndexOld)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ProtTXTบAutor  ณMario Arizono       บ Data ณ  23/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada para impressao do protocolo para atendim.  บฑฑ
ฑฑบ          ณe retorno vindo do parametro correspondente, com a funcao   บฑฑ
ฑฑบ           de impressao de fichas.																																					บฑฑ		
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ProtTXT(cLote, cParametro, aAgenda)

	Local aArea  := GetArea()
	Local nPos   := 0   
	Local cAlias := Alias() 

	Default cLote      := ""
	Default cParametro := ""
	Default aAgenda    := {} 

	Private cTitulo  := STR0059 //"Protocolo de Atendimento" 
 Private cNomerel := "HSPAHP39"
 Private Tamanho  := "P"
 Private aReturn  := {STR0024, 1, STR0025, 2, 2, 1, "", 1} //"Zebrado"###"Administra็ใo"  
 Private nLastKey := 0                  
 Private m_pag    := 01      
 Private nLin     := 0    
 
 If !Empty(aAgenda)
 	cNomeRel := SetPrint(cAlias, cNomeRel, "", @cTitulo, "", "", "", .T., "", .T., Tamanho, , .T.)
  SetDefault(aReturn, cAlias)
  nTipo := If(aReturn[4] == 1, 15, 18)  
  If nLastKey == 27
   RestArea(aArea)
   Return(Nil)
  EndIf                              
  
  For nPos := 1 To Len(aAgenda)
   DbSelectArea("GSA")
   DbSetOrder(4) // GSA_FILIAL + GSA_CODSOL
   DbSeek(xFILIAL("GSA") + aAgenda[nPos, 26]) // filial + codsol
       
   If SUBS(cParametro, 1, 8) # "HSPAHR71"
    HSPFITXT(cParametro)  //Executa a Funcao que esta cadastrada no PARAMETRO,  para imprimir o protocolo.
   EndIf
  Next    
	EndIf
	Ms_Flush()  
	If aReturn[5] == 1
  OurSpool(cNomerel)
 EndIf
  
	RestArea(aArea)
	
Return(Nil)                               

Function HS_ConsLot()
 
 Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aHeader := {}, aCols := {}
 Local oNGDGsa := Nil, oGet1 := Nil, oDlg := Nil, oSay := Nil
 Local nUsado  := 0
 Local cCodBar := Space(Len(GSA->GSA_LOTE) + 1)
 
 HS_ProcLot(Nil,, @aHeader, @aCols, @nUsado)

 aSize 			:= MsAdvSize(.T.)
 aObjects := {}
 
 aAdd(aObjects, {100, 005, .T., .T.})
 AAdd(aObjects, {100, 095, .T., .T.})
 
 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0067) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Consulta lote"

 // Codigo de barras //
 oSay1 := tSay():New(aPObjs[1, 1] + 9, aPObjs[1, 2] + 004, {|| STR0068}, oDlg,,,,,, .T.,,, 130, 10) //"C๓digo do Lote.)"
 oGet1 := tGet():New(aPObjs[1, 1] + 7, aPObjs[1, 2] + 050, {|u| If(PCount()>0, cCodBar := u , cCodBar)}, oDlg, 70, 10, "@!",{|| Empty(cCodbar) .Or. HS_ProcLot("GSA->GSA_LOTE == '" + Substr(cCodBar, 1, Len(GSA->GSA_LOTE)) + "'", @oNGDGsa)},,,,,, .T.,,,,,,,,,"GSG", "cCodBar") 

 // Grid //
 oNGDGsa := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],,,,,,, Len(aCols),,,, oDlg, aHeader, aCols)
 oNGDGsa:oBrowse:align := CONTROL_ALIGN_BOTTOM 

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()}, {|| nOpcA := 0, oDlg:End()})

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ProcLotบAutor  ณBruno Santos        บ Data ณ  09/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada para Consulta por lote                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HS_ProcLot(cChave, oGet, aHeader, aCols, nUsado)

 Local aArea     := getArea()
 Local aCposIni  := {}
 Local cCpoNao   := "", cOrderBy := ""
 
 Default aHeader := {}
 Default aCols   := {}
 Default nUsado  := 0
 
 aCposIni := {"GSA_DATENT", "GSA_HORENT", "GSA_DATRET", "GSA_HORRET", "GSA_REGGER", "GSA_NOMPAC", "GSA_NOMLOC", ;
               "GSA_NOMMED", "GSA_NOMPRO", "GSA_OBSERV", "GSA_NOMMOT", "GSA_MOTIVO", "GSA_LOTE"  , "GSA_CODSOL", "GSA_DATSOL", "GSA_HORSOL",;
               "GSA_NOMSOL", "GSA_NOMENT", "GSA_NOMRET",  "GSA_CODEND", "GSA_NOMEND", Iif(GSA->(FieldPos("GSA_REGATE")) > 0,"GSA_REGATE","")}
                                   
 cCpoNao  := "GSA_SEXO  /GSA_DTNASC/GSA_ENDRUA/GSA_NUMERO/GSA_PRLNUM/GSA_DATCAN/GSA_NOMCAN/GSA_HORCAN"
 
 cOrderBy := "GSA.GSA_FILIAL, GSA.GSA_CODSOL DESC, GSA.GSA_DATSOL DESC, GSA.GSA_HORSOL DESC" 
  
 If HS_BDados("GSA" , @aHeader, @aCols , @nUsado, 1,, cChave, Nil,,,, cCpoNao,,,,,,,,,, aCposIni,,, cOrderBy) == 0 .And. ValType(oGet) <> "U"
  HS_MsgInf(STR0069, STR0034, STR0067)//"Nenhum registro foi encontrado"###"Aten็ใo"###"Consulta Lote"
 EndIf
 
 If ValType(oGet) <> "U"
  oGet:SetArray(aCols)
  oGet:oBrowse:Refresh()
 EndIf
 
 RestArea(aArea)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 10/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{STR0002, "AxPesqui"       , 0, 1, 0, nil},; 		//"Pesquisar"
                     {STR0003, "AxVisual"       , 0, 2, 0, nil},; 		//"Visualizar"
                     {STR0004, "AxInclui"       , 0, 3, 0, nil},; 		//"Solicitar Pront."
                     {STR0005, "HS_Same(1)"     , 0, 3, 0, nil},; 		//"Atender Solicit."
                     {STR0006, "HS_Same(2)"     , 0, 3, 0, nil},; 		//"Retorna Pront."
                     {STR0007, "HS_VAP39()"     , 0, 4, 0, nil},; 		//"Alterar Solicit." 
                     {STR0026, "HS_Same(5)"     , 0, 4, 0, nil},; 		//"Observ.Solicit."
                     {STR0008, "HS_Same(4)"     , 0, 4, 0, nil},; 		//"Encerrar Solicit."
                     {STR0027, "HSPAHP42()"     , 0, 3, 0, nil},; 		//"Saida Programada"
                     {STR0028, "HSPAHP40()"     , 0, 3, 0, nil},; 		//"Unificar Pront."
                     {STR0029, "HSPAHRC3()"     , 0, 3, 0, nil},; 		//"Extrato"
                     {STR0049, "HS_P39"         , 0, 3, 0, nil},; 		//"Consultar"
                     {STR0050, "HS_P39"         , 0, 4, 0, nil},; 		//"Paciente"
                     {STR0051, "HS_P39"         , 0, 3, 0, nil},; 		//"Extrato Atend."
                     {STR0042, "HS_P39"         , 0, 3, 0, nil},; 		//"Saํda M๚ltipla"
                     {STR0067, "HS_ConsLot()"   , 0, 2, 0, nil},; 		//"Consulta Lote"                      	 
                 	 {STR0053, "HS_ConsAge('A')", 0, 3, 0, nil},;	    //"Agenda"				
                     {STR0009, "HS_LegSame"     , 0, 1, 0, nil}} 		//"Legenda"
Return(aRotina)
