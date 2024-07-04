#INCLUDE "HSPAHA39.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"  
                      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA39  º Autor ³ Patricia Queiroz   º Data ³  09/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Modalidade de Coleta                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA39()

 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui", 0, 1}, ; //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A39"		 , 0, 2}, ; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_A39"		 , 0, 3}, ; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_A39"		 , 0, 4}, ; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_A39"		 , 0, 5}}   //"Excluir"
                      
 mBrowse(06, 01, 22, 75, "GGJ") 
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_A39    º Autor ³ Patricia Queiroz   º Data ³  09/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tratamento das funcoes                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
                                                                            */
Function HS_A39(cAlias, nReg, nOpc)   

 Local nOpcA  := 0
 Local nGGOpc := IIF(aRotina[nOpc, 4] == 3 .Or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGGs := {}, oFolGGs
 
 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private aCGGL := {}, aHGGL := {}, nUGGL := 0, nLGGL := 0
 Private aCGGM := {}, aHGGM := {}, nUGGM := 0, nLGGM := 0 
 Private nGGLCDTIPA := 0, nGGLCDITEM := 0, nGGMCDPROD := 0, nGGMCDITEM := 0 
 Private oGGJ, oGGL, oGGM
 Private cG1RTipo := "014"
 
 DbSelectArea("GGJ")
 RegToMemory("GGJ", (nOpcE == 3)) 

 nOpcA := 0 
 
 nLGGL := HS_BDados("GGL", @aHGGL, @aCGGL, @nUGGL, 1, , IIF(aRotina[nOpc, 4] # 3, "GGL->GGL_CDMODC == '" + M->GGJ_CDMODC + "'", Nil))
	nGGLCDTIPA := aScan(aHGGL, {| aVet | aVet[2] == "GGL_CDTIPA"})
	nGGLCDITEM := aScan(aHGGL, {| aVet | aVet[2] == "GGL_CDITEM"})
 
 nLGGM := HS_BDados("GGM", @aHGGM, @aCGGM, @nUGGM, 1, , IIF(aRotina[nOpc, 4] # 3, "GGM->GGM_CDMODC == '" + M->GGJ_CDMODC + "'", Nil))
 nGGMCDPROD := aScan(aHGGM, {| aVet | aVet[2] == "GGM_CDPROD"})
 nGGMCDITEM := aScan(aHGGM, {| aVet | aVet[2] == "GGM_CDITEM"})
 
 If Empty(aCGGL[1, nGGLCDITEM])
  aCGGL[1, nGGLCDITEM] := StrZero(1, Len(GGL->GGL_CDITEM))
 EndIf
 
 If Empty(aCGGM[1, nGGMCDITEM])
  aCGGM[1, nGGMCDITEM] := StrZero(1, Len(GGM->GGM_CDITEM))
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
 aPGGs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd   //"Modalidade da Coleta"

 oGGJ := MsMGet():New("GGJ", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGGJ:oBox:align:= CONTROL_ALIGN_ALLCLIENT 
 
 @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGGs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0007, STR0008 //"Tipo de Amostras"###"Itens de Estoque"
 oFolGGs:Align := CONTROL_ALIGN_BOTTOM 
 
 oGGL := MsNewGetDados():New(aPGGs[1, 1], aPGGs[1, 2], aPGGs[1, 3], aPGGs[1, 4], nGGOpc, "HS_DuplAC(oGGL:oBrowse:nAt, oGGL:aCols, {nGGLCDTIPA})",, "+GGL_CDITEM",,,,,,, oFolGGs:aDialogs[1], aHGGL, aCGGL)
 oGGL:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 oGGM := MsNewGetDados():New(aPGGs[1, 1], aPGGs[1, 2], aPGGs[1, 3], aPGGs[1, 4], nGGOpc, "HS_DuplAC(oGGM:oBrowse:nAt, oGGM:aCols, {nGGMCDPROD})",, "+GGM_CDITEM",,,,,,, oFolGGs:aDialogs[2], aHGGM, aCGGM)
 oGGM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA == 0)}, ;
                                                      {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
  Begin Transaction
   FS_GrvA39(nOpcE)
  End Transaction 
 EndIf
 
Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GrvA39 ºAutor  ³Patricia Queiroz    º Data ³  09/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Trava tabela para Inclusao, Alteracao e Exclusao.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GrvA39(nOpcE) 

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
 RecLock("GGJ", (nOpcE == 3))
 HS_GrvCpo("GGJ")
 MsUnlock()	
ElseIf nOpcE == 5 //Excluir
 RecLock("GGJ", .F.)
 DbDelete()
 MsUnlock()
EndIf

FS_GrvGG(oGGL, aHGGL, "GGL", nGGLCDITEM, nUGGL, nOpcE)
FS_GrvGG(oGGM, aHGGM, "GGM", nGGMCDITEM, nUGGM, nOpcE)

Return(nOpcE) 

//Funcao para gravar a tabela GGL e GGM
Static Function FS_GrvGG(oGG, aHGG, cAlias, nPos, nUTot, nOpcG)

Local nForI  := 0
Local lAchou := .T.

aCGG := aClone(oGG:aCols)
DbselectArea(cAlias)
DbSetOrder(1) // GGL_FILIAL + GGL_CDMODC + GGL_CDITEM
For nForI := 1 To Len(aCGG)
	DbselectArea(cAlias)
	DbSetOrder(1) // GGL_FILIAL + GGL_CDMODC + GGL_CDITEM
	lAchou := DbSeek(xFilial(cAlias) + M->GGJ_CDMODC + aCGG[nForI, nPos])
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
			&(cAlias + "->" + cAlias + "_CDMODC") := M->GGJ_CDMODC
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldA39 ºAutor  ³Patricia Queiroz    º Data ³  09/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Validacao dos campos                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Function HS_VldA39()

Local aArea := GetArea()
Local lRet  := .T.                                    


If ReadVar() == "M->GGJ_CDMODC"
 If HS_CountTB("GGJ", "GGJ_CDMODC = '" + M->GGJ_CDMODC + "'") > 0
 	HS_MsgInf(STR0009, STR0010, STR0011)  //"Este código já existe"###"Atenção"###"Validação de Inclusão"
  lRet := .F.	
 EndIf
ElseIf ReadVar() == "M->GGJ_TMPCOL"
 If M->GGJ_TMPCOL > "24"
  HS_MsgInf(STR0012, STR0010, STR0011)  //"O horário não pode ultrapassar 24 horas."###"Atenção"###"Validação de Inclusão"
  lRet := .F.
 EndIf
ElseIf ReadVar() == "M->GGJ_CDKITC" .And. !Empty(M->GGJ_CDKITC)
 If !(lRet := HS_SeekRet("SB1", "M->GGJ_CDKITC", 1, .F., "GGJ_DSKITC", "B1_DESC"))
  HS_MsgInf(STR0013, STR0010, STR0014) //"Produto não cadastrado."###"Atenção"###"Validação de Mat/Med"
 EndIf
EndIf 

RestArea(aArea)

Return(lRet) 