#INCLUDE "HSPAHA23.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA23  บ Autor ณ Manoel             บ Data ณ  27/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE PROCEDIMENTO  PADRAO                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA23()
 Private cCadastro := STR0006 //"Cadastro de Procedimentos Padrao"
 Private aRotina := MenuDef()
 
 DbSelectArea("GA1")
 DbSetOrder(1)
 mBrowse(06, 01, 22, 75, "GA1")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ HS_MntA23 ณ Autor ณ  Jos้ Orfeu          ณ Data ณ 22/11/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de Tratamento do cadastro de procedimento padrao    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MntA23(cAliasA23, nRegA23, nOpcA23)
 Local nOpcPct := 0, oDlgPct, nGDOpc := IIf(Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local oEnGa1

 Private aHGa2 := {}, aCGa2 := {}, nUGa2 := 0
 Private aTela := {}, aGets := {}, oGDGa2
 Private nGa2OriPac := 0, nGa2CodCpc := 0, nGa2DesPct := 0, nGa2QtdApl := 0
Private nGa2Sessao := 0

 Private cOriPac_Pac := "", cCodCpc_Pac := "", nPos_Pac := 0
 Private cCodCpc_Ant := ""
Private lGa2Sessao := Hs_ExisDic({{"C", "GA2_SESSAO"}}, .F.)
 
 RegToMemory("GA1", aRotina[nOpcA23, 4] == 3)
 
 HS_BDados("GA2", @aHGa2, @aCGa2, @nUGa2, 1, M->GA1_CODPCT, IIf(aRotina[nOpcA23, 4] == 3, Nil, "GA2->GA2_CODPCT == '" + M->GA1_CODPCT + "'"))
     
 nGa2OriPac := aScan(aHGa2, {|aVet| AllTrim(aVet[2]) == "GA2_ORIPAC"})
 nGa2CodCpc := aScan(aHGa2, {|aVet| AllTrim(aVet[2]) == "GA2_CODCPC"})
 nGa2DesPct := aScan(aHGa2, {|aVet| AllTrim(aVet[2]) == "GA2_DESPCT"})
 nGa2QtdApl := aScan(aHGa2, {|aVet| AllTrim(aVet[2]) == "GA2_QTDAPL"})
if lGa2Sessao
	nGa2Sessao := aScan(aHGa2, {|aVet| AllTrim(aVet[2]) == "GA2_SESSAO"})
endif

 If Altera
  If !Empty(M->GA1_CODPRO)
   cOriPac_Pac := "1"
   cCodCpc_Pac := PADR(M->GA1_CODPRO, aHGA2[nGA2CodCpc, 4])
  ElseIf !Empty(M->GA1_CODTXD)
   cOriPac_Pac := "2"
   cCodCpc_Pac := PADR(M->GA1_CODTXD, aHGA2[nGA2CodCpc, 4])
  Endif
  nPos_Pac := aScan(aCGA2, {|aVet| aVet[nGa2ORIPAC] + aVet[nGa2CODCPC] == cOriPac_Pac + cCodCpc_Pac})
 Endif 
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. ) 
 
 DEFINE MSDIALOG oDlgPct TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de Procedimento padrao
  oEnGa1 := MsMGet():New("GA1", nRegA23, nOpcA23,,,,, aPObjs[1],, 2,,,, oDlgPct)
  oEnGa1:oBox:Align := CONTROL_ALIGN_TOP
   
  oGDGa2 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,, 99999,,,, oDlgPct, aHGa2, aCGa2)
  oGDGa2:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
  oGDGa2:lF3Header       := .F.
  oGDGa2:bLinhaOk        := {|| HS_DuplAC(oGDGa2:oBrowse:nAt, oGDGa2:aCols, {nGA2OriPac, nGA2CodCpc}) }  
  oGDGa2:oBrowse:bChange := {|| HS_F3A23()}
 // oGDGa2:oBrowse:bDelOk  := {|| FS_VExGa2()}   

 ACTIVATE MSDIALOG oDlgPct ON INIT EnchoiceBar(oDlgPct, {|| nOpcPct := 1, IIf(FS_A23TOK(), oDlgPct:End(), nOpcPct := 0)}, ;
                                                                 {|| nOpcPct := 0, oDlgPct:End()})
                           
 If nOpcPct == 1 .And. aRotina[nOpcA23, 4] <> 2
  Begin Transaction
   FS_GrvA23(aHGa2, nUGa2)
  End Transaction 
 EndIf
Return

Static Function FS_GrvA23(aHGa2, nUGa2)
 Local nForGrv := 0, lFoundGa2 := .T.
 
 If Inclui .Or. Altera
  RecLock("GA1", Inclui)
   HS_GrvCpo("GA1")
   GA1->GA1_FILIAL := xFilial("GA1")
   GA1->GA1_LOGARQ := HS_LogArq()
  MsUnLock() 
 Else // exclusao
  RecLock("GA1", .F., .T.)
   DbDelete()
  MsUnlock()
  WriteSx2("GA1") 
 Endif
  
 For nForGrv := 1 To Len(oGDGa2:aCols)
  DbSelectArea("GA2")
  lFoundGa2 := DbSeek(xFilial("GA2") + M->GA1_CODPCT + oGDGa2:aCols[nForGrv, nGa2CodCpc] + oGDGa2:aCols[nForGrv, nGa2OriPac])
  If Inclui .Or. Altera
   If oGDGa2:aCols[nForGrv, nUGa2 + 1] .And. lFoundGa2 // exclusao
    RecLock("GA2", .F., .T.)
     DbDelete()
    MsUnlock()
    WriteSx2("GA2")
  	Else
    If !oGDGa2:aCols[nForGrv, Len(oGDGa2:aCols[nForGrv])]
	    RecLock("GA2", If(lFoundGa2, .F., .T.))
		    if lGa2Sessao
				If Valtype(oGDGa2:aCols[nForGrv, nGa2Sessao]) == "N"
					oGDGa2:aCols[nForGrv, nGa2Sessao] := strZero(oGDGa2:aCols[nForGrv, nGa2Sessao] , TamSx3("GA2_SESSAO")[1] )
				Else
					oGDGa2:aCols[nForGrv, nGa2Sessao] := strZero(VAL(oGDGa2:aCols[nForGrv, nGa2Sessao] ), TamSx3("GA2_SESSAO")[1] )
				EndIf
			endif
	     HS_GrvCpo("GA2", oGDGa2:aCols, aHGa2, nForGrv)
	     GA2->GA2_FILIAL := xFilial("GA2")
	     GA2->GA2_CODPCT := M->GA1_CODPCT
	     GA2->GA2_LOGARQ := HS_LogArq()
				If lGa2Sessao
					GA2->GA2_SESSAO := oGDGa2:aCols[nForGrv, nGa2Sessao] 
				endif
	    MsUnlock()
	   EndIf 
	  EndIf
  Else  	
   If lFoundGa2  // opcao exclusao do menu
    RecLock("GA2", .F., .T.)
     dbdelete()
    MsUnlock()
    WriteSx2("GA2")       
   Endif   
  Endif
 Next   
Return(.T.)

Function HS_F3A23()
 Local cGa2OriPac := IIF(ReadVar() == "M->GA2_ORIPAC", M->GA2_ORIPAC, oGDGa2:aCols[oGDGa2:nAt][nGa2OriPac])

	if lGa2Sessao
		if (Empty(oGDGa2:aCols[oGDGa2:oBrowse:nAt, nGa2Sessao]) .and. oGDGa2:oBrowse:nAt -1 == 0 )
			oGDGa2:aCols[oGDGa2:oBrowse:nAt, nGa2Sessao] := "01"
		elseif Empty(oGDGa2:aCols[oGDGa2:oBrowse:nAt, nGa2Sessao])
			oGDGa2:aCols[oGDGa2:oBrowse:nAt, nGa2Sessao] := strzero(val(oGDGa2:aCols[oGDGa2:oBrowse:nAt - 1, nGa2Sessao])+1,2)
		endif
	endif


 If ReadVar() == "M->GA2_ORIPAC" .and. oGDGa2:aCols[oGDGa2:nAt][nGa2OriPac] <> M->GA2_ORIPAC .and. ;
    !oGDGa2:aCols[oGDGa2:nAt][nUGA2+1]
 
  oGDGa2:aCols[oGDGa2:nAt][nGa2CodCPC] := SPACE(aHGA2[nGa2CodCpc, 4])
  oGDGa2:aCols[oGDGa2:nAt][nGa2DesPct] := SPACE(aHGA2[nGa2DesPct, 4]) 
 Endif 
 
 If     cGa2OriPac == "0" // Mat/Med
  oGDGa2:aInfo[nGa2CodCpc][01] := "SB1"
 ElseIf cGa2OriPac == "1" // Procedimento/Honorario 
  oGDGa2:aInfo[nGa2CodCpc][01] := "GA7"
 ElseIf cGa2OriPac == "2" // Taxa/Diaria 
  oGDGa2:aInfo[nGa2CodCpc][01] := "GAA"                                                                 
 ElseIf cGa2OriPac == "4" // Kit               
  oGDGa2:aInfo[nGa2CodCpc][01] := "GAF"
 EndIf                 
               	
 oGDGa2:oBrowse:Refresh()
Return(.T.)

Function HS_VldA23()
 Local lRet := .F., cAliasOld := Alias()
 
 If ReadVar() == "M->GA1_CODPRO"
  If !(lRet := Empty(M->GA1_CODTXD))
   HS_MsgInf(STR0009, STR0008, STR0006) // "Atencao" //"Taxa/Diaria ja informada. Informe um procedimento ou uma taxa diaria para o Procedimentos Padrao"###"Cadastro de Procedimentos Padrao"
  ElseIf !Empty(M->GA1_CODPRO) .AND. !(lRet := HS_SeekRet("GA7", "M->GA1_CODPRO", 1, .F., "M->GA1_DESPRO", "GA7_DESC"))
   HS_MsgInf(STR0010, STR0008, STR0006) // "Aten็ao" //"Procedimento invalido"###"Cadastro de Procedimentos Padrao"
  ElseIf (nPos_Pac := FS_IProTxd("1", M->GA1_CODPRO, M->GA1_DESPRO)) > 0
   cOriPac_Pac := "1"
   cCodCpc_Pac := PADR(M->GA1_CODPRO, aHGA2[nGA2CodCpc, 4])
  Endif 
 
 ElseIf ReadVar() == "M->GA1_CODTXD"
  If !(lRet := Empty(M->GA1_CODPRO))
   HS_MsgInf(STR0011, STR0008, STR0006) // "Atencao" //"Procedimento ja informado. Informe um procedimento ou uma taxa diaria para o Procedimentos Padrao"###"Cadastro de Procedimentos Padrao"
  ElseIf !Empty(M->GA1_CODTXD) .AND. !(lRet := HS_SeekRet("GAA","M->GA1_CODTXD",1,.F.,"M->GA1_DESTXD","GAA_DESC"))
   HS_MsgInf(STR0012, STR0008, STR0006) // "Atencao" //"Taxa diaria invalida"###"Cadastro de Procedimentos Padrao"
  ElseIf (nPos_Pac := FS_IProTxd("2", M->GA1_CODTXD, M->GA1_DESTXD)) > 0
   cOriPac_Pac := "2"
   cCodCpc_Pac := PADR(M->GA1_CODTXD, aHGA2[nGA2CodCpc, 4])
  Endif 
 
 ElseIf ReadVar() $ "M->GA2_ORIPAC/M->GA2_CODCPC"
  lRet := .T.
  If oGDGa2:oBrowse:nAt == nPos_Pac
   HS_MsgInf(STR0020, STR0008, STR0006) //"Item principal do Procedimentos Padrao nao pode ser alterado!"###"Atencao"###"Cadastro de Procedimentos Padrao"
   lRet := .F.
  ElseIf ReadVar() == "M->GA2_CODCPC"
   If oGDGa2:aCols[oGDGa2:nAt, nGa2OriPac] == "0"
    DbSelectArea("SB1")
    DbSetOrder(1)
    If (lRet := DbSeek(xFilial("SB1") + PadR(AllTrim(M->GA2_CODCPC), Len(SB1->B1_COD))))
     oGDGa2:aCols[oGDGa2:nAt, nGa2DesPct] := SB1->B1_DESC
    Else
     HS_MsgInf(STR0013, STR0008, STR0006) // "Atencao" //"Mat/Med nใo encontrado"###"Cadastro de Procedimentos Padrao"
    EndIf  
   ElseIf oGDGa2:aCols[oGDGa2:nAt, nGa2OriPac] == "1"
    DbSelectArea("GA7")
    DbSetOrder(1)
    If (lRet := DbSeek(xFilial("GA7") + PadR(AllTrim(M->GA2_CODCPC), Len(GA7->GA7_CODPRO))))
     oGDGa2:aCols[oGDGa2:nAt, nGa2DesPct] := GA7->GA7_DESC
   Else
     HS_MsgInf(STR0014, STR0008, STR0006) // "Atencao" //"Procedimento nใo encontrado"###"Cadastro de Procedimentos Padrao"
    EndIf
   ElseIf oGDGa2:aCols[oGDGa2:nAt, nGa2OriPac] == "2"
    DbSelectArea("GAA")
    DbSetOrder(1)
    If (lRet := DbSeek(xFilial("GAA") + PadR(AllTrim(M->GA2_CODCPC), Len(GAA->GAA_CODTXD))))
     oGDGa2:aCols[oGDGa2:nAt, nGa2DesPct] := GAA->GAA_DESC
    Else
     HS_MsgInf(STR0015, STR0008, STR0006) // "Atencao" //"Taxa/Diaria nใo encontrada"###"Cadastro de Procedimentos Padrao"
    EndIf
   ElseIf oGDGa2:aCols[oGDGa2:nAt, nGa2OriPac] == "4"
    DbSelectArea("GAF")
    DbSetOrder(1)
    If (lRet := DbSeek(xFilial("GAF") + PadR(AllTrim(M->GA2_CODCPC), Len(GAF->GAF_CODKIT))))
     oGDGa2:aCols[oGDGa2:nAt, nGa2DesPct] := GAF->GAF_DESKIT
    Else
     HS_MsgInf(STR0016, STR0008, STR0006) // "Atencao" //"Kit nใo encontrado"###"Cadastro de Procedimentos Padrao"
    EndIf  
   EndIf                  
   oGDGa2:oBrowse:Refresh()
  Endif 
 EndIf
  
 DbSelectArea(cAliasOld)
Return(lRet)

Static Function FS_A23TOK()
 Local lRet := .T.
                         
 If Inclui .Or. Altera
  If Empty(M->GA1_CODPRO) .and. Empty(M->GA1_CODTXD)
   HS_MsgInf(STR0017, STR0008, STR0006) //"Informe um procedimento ou uma taxa diaria para o Procedimentos Padrao"###"Atencao"###"Cadastro de Procedimentos Padrao"
   lRet := .F.
  ElseIf !Empty(M->GA1_CODPRO) .and. !Empty(M->GA1_CODTXD)
   HS_MsgInf(STR0018, STR0008, STR0006) //"Informe ou um procedimento ou uma taxa diaria para o Procedimentos Padrao. Ambos nao podem ser informados"###"Atencao"###"Cadastro de Procedimentos Padrao"
   lRet := .F.
  //Else
   //lRet := IIF(oGDGA2:aCols[oGDGA2:oBrowse:nAt, nUGA2 + 1], FS_VExGA2(), .T.) .And. oGDGa2:TudoOk() .And. Obrigatorio(aGets, aTela)
  Endif  
 EndIf 
Return(lRet) 

Static Function FS_IProTxd(cOriPac, cCodCpc, cDesPct)
 Local nPosDes := 0
 
 cCodCpc := PADR(cCodCPC, aHGA2[nGa2CodCpc, 4])
 If Empty(cCodCPC)
  If !Empty(cCodCpc_Ant) 
   nPosDes := aScan(oGDGa2:aCols, {|aVet| aVet[nGa2ORIPAC] + aVet[nGa2CODCPC] == cOriPac + cCodCpc_Ant .and. !aVet[nUGA2+1]})
   oGDGa2:aCols[nPosDes, nUGA2+1] := .T.
  Endif 

 Else
  If len(oGDGa2:aCols) == 1 .and. Empty(oGDGa2:aCols[1, nGa2CODCPC]) .and. !oGDGa2:aCols[1, nUGA2+1]
  nPosDes := 1
   
  ElseIf (nPosDes := aScan(oGDGa2:aCols, {|aVet| aVet[nGa2ORIPAC] + aVet[nGa2CODCPC] == cOriPac + cCodCpc .and. !aVet[nUGA2+1]}) ) == 0
   If Empty(cCodCpc_Ant)
    oGDGA2:AddLine(.F., .F.)
    oGDGA2:lNewLine := .F.
    nPosDes := len(oGDGA2:aCols)
   Else
    nPosDes := aScan(oGDGa2:aCols, {|aVet| aVet[nGa2ORIPAC] + aVet[nGa2CODCPC] == cOriPac + cCodCpc_Ant})
   Endif 
  
  ElseIf !MsgYesNo(STR0021) //"Esta despesa ja foi incluida como item do Procedimentos Padrao. Confirma a sua utilizacao como despesa principal?"
   oGDGa2:aCols[nPosDes, nUGA2+1] := .T.  
   cCodCpc_Ant := cCodCpc 
  
  Endif 
  If nPosDes > 0
   oGDGa2:aCols[nPosDes, nGa2OriPac] := cOriPac
   oGDGa2:aCols[nPosDes, nGa2CodCpc] := PADR(cCodCpc, aHGA2[nGA2CodCpc, 4])
   oGDGa2:aCols[nPosDes, nGa2DesPct] := cDesPct
   oGDGa2:aCols[nPosDes, nGa2QtdApl] := 1
  Endif 
   
 Endif
 
 cCodCpc_Ant := cCodCpc
 oGDGA2:oBrowse:Refresh()
Return(nPosDes)

Function HS_DesGa2()
Local cDesGa2 := ""

If IIf(Type("Inclui") <> "U", !Inclui, .T.)
	If TMPGA2->GA2_ORIPAC == "0" // Mat / Med
		cDesGa2 := Posicione("SB1", 1, xFilial("SB1") + PadR(AllTrim(TMPGA2->GA2_CODCPC), Len(SB1->B1_COD))    , "B1_DESC")
	ElseIf TMPGA2->GA2_ORIPAC == "1" // Procedimentos                              
		cDesGa2 := Posicione("GA7", 1, xFilial("GA7") + PadR(AllTrim(TMPGA2->GA2_CODCPC), Len(GA7->GA7_CODPRO)), "GA7_DESC")
	ElseIf TMPGA2->GA2_ORIPAC == "2" // Taxas / Diarias
		cDesGa2 := Posicione("GAA", 1, xFilial("GAA") + PadR(AllTrim(TMPGA2->GA2_CODCPC), Len(GAA->GAA_CODTXD)), "GAA_DESC")
	ElseIf TMPGA2->GA2_ORIPAC == "4" // Kits
		cDesGa2 := Posicione("GAF", 1, xFilial("GAF") + PadR(AllTrim(TMPGA2->GA2_CODCPC), Len(GAF->GAF_CODKIT)), "GAF_DESKIT")
	EndIf
EndIf 
Return(cDesGa2)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA23  บ Autor ณ Cibele Peria       บ Data ณ  25/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida a exclusao de um item da getdados (GA2)             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/*Static Function FS_VExGA2()
 Local lRet    := .T.
 Local cCodCpc := ""

 cCodCpc := PADR(ALLTRIM(oGDGA2:aCols[oGDGA2:oBrowse:nAt, nGA2CodCpc]), aHGA2[nGA2CodCpc, 4])

 If !Empty(cCodCpc_Pac) .and. oGDGA2:aCols[oGDGA2:oBrowse:nAt, nGA2OriPac] == cOriPac_Pac .and. ;
     cCodCpc == cCodCpc_Pac .and. oGDGA2:oBrowse:nAt == nPos_Pac
  lRet := .F.
  MsgStop(STR0019) //"Item principal do 	Procedimentos Padrao nao pode ser eliminado!"
 
  oGDGA2:aCols[oGDGA2:oBrowse:nAt, nUGA2 + 1] := .F.
  oGDGA2:oBrowse:Refresh()
 Endif 

Return(lRet)  */


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 06/06/07 ณฑฑ
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
Local aRotina :=	{{OemToAnsi(STR0001), "axPesqui" , 0, 1, 0, nil}, ; //"Pesquisar"
                     {OemToAnsi(STR0002), 'HS_MntA23', 0, 2, 0, nil}, ; //"Visualizar"
                     {OemToAnsi(STR0003), 'HS_MntA23', 0, 3, 0, nil}, ; //"Incluir"
                     {OemToAnsi(STR0004), 'HS_MntA23', 0, 4, 0, nil}, ; //"Alterar"
                     {OemToAnsi(STR0005), 'HS_MntA23', 0, 5, 0, nil}}   //"Excluir"
Return(aRotina)
