#INCLUDE "HSPAHA29.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA29  บ Autor ณ Patricia Queiroz   บ Data ณ  29/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Tipo de Doacao                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA29()

 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui", 0, 1}, ; //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_A29"		 , 0, 2}, ; //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_A29"		 , 0, 3}, ; //"Incluir"
                      {OemtoAnsi(STR0004), "HS_A29"		 , 0, 4}, ; //"Alterar"
                      {OemtoAnsi(STR0005), "HS_A29"		 , 0, 5} } //"Excluir"
                      
 DbselectArea("GGE")                     
                    
 mBrowse(06, 01, 22, 75, "GGE") 
 
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A29    บ Autor ณ Patricia Queiroz   บ Data ณ  29/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das funcoes                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
                                                                            */
Function HS_A29(cAlias, nReg, nOpc)   

 Local nOpcA := 0
 Local nGGOpc := IIF(aRotina[nOpc, 4] == 3 .Or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGGX := {}, oFolGGX

 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private oGGE, oGGX
 Private aCGGX := {}, aHGGX := {}
 Private nUGGX := 0, nLGGX := 0 
 Private nGGXCDTIPD := 0; nGGXCDITEM := 0
  
 RegToMemory("GGE", (nOpcE == 3)) 

 nOpcA := 0
      
 nLGGX := HS_BDados("GGX", @aHGGX, @aCGGX, @nUGGX, 1, , IIF(aRotina[nOpc, 4] # 3, "GGX->GGX_CDTIPD == '" + M->GGE_CDTIPD + "'", Nil))
 nGGXCDETIQ := aScan(aHGGX, {| aVet | aVet[2] == "GGX_CDETIQ"})
 nGGXCDITEM := aScan(aHGGX, {| aVet | aVet[2] == "GGX_CDITEM"})
 
 If Empty(aCGGX[1, nGGXCDITEM])
  aCGGX[1, nGGXCDITEM] := StrZero(1, Len(GGX->GGX_CDITEM))
 EndIf 

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 050, .T., .T.})
 AAdd(aObjects, {100, 050, .T., .T., .T. })

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
 
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo := {aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGGX := MsObjSize( aInfo, aObjects, .T. )


 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //Tipo de Doa็ใo

 oGGE := MsMGet():New("GGE", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGGE:oBox:align:= CONTROL_ALIGN_ALLCLIENT
 
 @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGGX SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts "Etiquetas"
 oFolGGX:Align := CONTROL_ALIGN_BOTTOM 
 
 oGGX := MsNewGetDados():New(aPGGX[1, 1], aPGGX[1, 2], aPGGX[1, 3], aPGGX[1, 4], nGGOpc, "HS_DuplAC(oGGX:oBrowse:nAt, oGGX:aCols, {nGGXCDETIQ})",, "+GGX_CDITEM",,,,,,, oFolGGX:aDialogs[1], aHGGX, aCGGX)
 oGGX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(nOpcE == 5, FS_ValEx(), .T.) .And. HS_VldEtiq(oGGX, nGGXCDETIQ, nUGGX), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
  Begin Transaction
   FS_GrvA29(nOpcE)
  End Transaction 
  While __lSx8
   ConfirmSx8()
  EndDo  
 Else
  While __lSx8
   RollBackSx8()
  EndDo     
 EndIf
 
Return(Nil)
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvA29 บAutor  ณPatricia Queiroz    บ Data ณ  29/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTrava tabela para Inclusao, Alteracao e Exclusao.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvA29(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
 If nOpcE == 3
  M->GGE_CDTIPD := HS_VSxeNum("GGE", "M->GGE_CDTIPD", 1)                     	
 EndIf 
 RecLock("GGE", (nOpcE == 3))
  HS_GrvCpo("GGE")
 MsUnlock()	
ElseIf nOpcE == 5 //Excluir
 RecLock("GGE", .F.)
  DbDelete()
 MsUnlock()
EndIf

Fs_GrvGX(oGGX, aHGGX, "GGX", nGGXCDITEM, nUGGX, nOpcE)             

Return(nOpcE)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ValEx  บAutor  ณPatricia Queiroz    บ Data ณ  29/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validar a exclusao.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                           
Static Function FS_ValEx()

Local aArea := GetArea()
Local lRet	 := .T.

If HS_CountTB("GCY", "GCY_CDTIPD = '" + GGE->GGE_CDTIPD + "'") > 0
	HS_MsgInf(STR0007, STR0008, STR0009) //"O registro possui relacionamento com Atendimento Doa็ใo"###"Aten็ใo"###"Valida็ใo de Exclusใo"
 lRet := .F.	
EndIf
 
RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldA39 บAutor  ณPatricia Queiroz    บ Data ณ  09/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao dos campos                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/          
Function HS_VldA29()

Local aArea := GetArea()
Local lRet  := .T. 

If ReadVar() == "M->GGE_CODPRO" .And. !Empty(M->GGE_CODPRO)
 If !(lRet := HS_SeekRet("GA7", "M->GGE_CODPRO", 1, .F., "GGE_DESPRO", "GA7_DESC"))
  HS_MsgInf(STR0010, STR0008, STR0011) //"Procedimento nใo cadastrado."###"Aten็ใo"###"Valida็ใo de Procedimento"
 EndIf
ElseIf ReadVar() == "M->GGE_CDMODC" .And. !Empty(M->GGE_CDMODC)
 If !(lRet := HS_SeekRet("GGJ", "GGE_CDMODC", 1, .F., "GGE_DSMODC", "GGJ_DSMODC"))
  HS_MsgInf(STR0012, STR0008, STR0013) //"Modalidade nใo cadastrada."###"Aten็ใo"###"Valida็๕a da Modalidade"  
 EndIf
EndIf 

RestArea(aArea)

Return(lRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGX บAutor  ณPatricia Queiroz    บ Data ณ  11/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao dos campos                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvGX(oGG, aHGG, cAlias, nPos, nUTot, nOpcG)

Local nForI  := 0
Local lAchou := .T.

aCGG := aClone(oGG:aCols)
DbselectArea(cAlias)
DbSetOrder(2) // GGX_FILIAL + GGX_CDTIPD + GGX_CDITEM
For nForI := 1 To Len(aCGG)
	DbselectArea(cAlias)
	DbSetOrder(2) // GGX_FILIAL + GGX_CDTIPD + GGX_CDITEM
	lAchou := DbSeek(xFilial(cAlias) + M->GGE_CDTIPD + aCGG[nForI, nPos])
	If nOpcE == 3 .Or. nOpcE == 4  //Incluir / Alterar
		If aCGG[nForI, nUTot + 1] .And. lAchou  //Excluir
			RecLock(cAlias, .F., .T.)
 			DbDelete()
			MsUnlock()
 			WriteSx2(cAlias)
			MsUnLock()
		ElseIf !aCGG[nForI, nUTot + 1] .And. !Empty(oGG:aCols[nForI, nPos])
			RecLock(cAlias, !lAchou)
 			HS_GRVCPO(cAlias, aCGG, aHGG, nForI)
			 &(cAlias + "->" + cAlias + "_CDTIPD") := M->GGE_CDTIPD
			 &(cAlias + "->" + cAlias + "_FILIAL") := xFilial(cAlias)
			MsUnlock()
		EndIf
	Else
		If lAchou // opcao exclusao do menu
			RecLock(cAlias, .F., .T.)
 			DbDelete()
			MsUnlock()
 			WriteSx2(cAlias)
		EndIf
	EndIf
Next nForI

Return()                                                       




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldGGX บAutor  ณPatricia Queiroz    บ Data ณ  18/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao os itens incluํdos para GGX.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldEtiq(oGGX, nGGXETIQ, nUTGGX)

 Local aArea := GetArea()
 Local lRet  := .T.
 Local nFor  := 0    
 
 For nFor := 1 To Len(oGGX:aCols)
  DbSelectArea("GC7")
  DbSetOrder(1) //GC7_FILIAL + GC7_CODETI
  If !DbSeek(xFilial("GC7") + AllTrim(oGGX:aCols[nFor, nGGXETIQ]))
   If !oGGX:aCols[nFor, nUTGGX + 1]
    HS_MsgInf(STR0014 + AllTrim(oGGX:aCols[nFor, nGGXETIQ]) + STR0015, STR0008, STR0016) //"A etiqueta "###" nใo estแ cadastrada."###"Aten็ใo"###"Valida็ใo de Etiqueta"  
    lRet := .F.
   EndIf 
  EndIf
 Next() 
 
 RestArea(aArea)

Return(lRet)