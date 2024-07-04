#INCLUDE "hspahac8.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHAC8  ºAutor  ³Microsiga           º Data ³  22/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro das macros utilizadas na integração do Laudo, com º±±
±±º          ³ o word.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestão Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAHAC8()

 Local aTabela := {{"T", "GND"},{"T", "GNE"}}

 Private aRotina := {{OemtoAnsi(STR0001), "axPesqui" , 0, 1}, ;  //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_AC8"	 , 0, 2}, ;  //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_AC8"	 , 0, 3}, ;  //"Incluir"
                      {OemtoAnsi(STR0004), "HS_AC8"	 , 0, 4}, ;  //"Alterar"
                      {OemtoAnsi(STR0005), "HS_AC8"	 , 0, 5} }   //"Excluir"

 Private cSx3CodTab := "GCY"
 Private cCpoSX3    := "M->GND_CHAVE"
 Private cRetSX3    := ""      
 Private LRdOnlyGNE := .F. 
 
 If HS_ExisDic(aTabela) 
  DbselectArea("GNE")
 	DbSelectArea("GND") 
 	mBrowse(06, 01, 22, 75, "GND")
 EndIf

Return(nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |HS_AC8    ºAutor  ³Bruno Santos        º Data ³  22/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento das funcoes                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_AC8(cAlias, nReg, nOpc)
 Local nOpcA      := 0     
 Local nGDOpc     := IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 
 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela    := {}       
 Private aGets    := {}
 Private aHGNE    := {},   aCGNE := {}
 Private nUGNE    := 0
 Private oGND, oGNE

 RegToMemory("GND",(nOpcE == 3)) //Gera variavies de memoria para o GG9

 nOpcA := 0
                    
 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 020, .T., .T. } )
 AAdd( aObjects, { 100, 080, .T., .T. } )
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Variáveis Word para Laudo"

 oGND := MsMGet():New("GND", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGND:oBox:align:= CONTROL_ALIGN_TOP
  
	nUGNE := HS_BDados("GNE", @aHGNE, @aCGNE, @nUGNE, 1,, IIf((nOpcE == 3), Nil, "GNE->GNE_SEQGND == '" + M->GND_CODSEQGND + "'"))
 
 nCODITE := aScan(aHGNE, {| aVet | AllTrim(aVet[2]) == "GNE_CODITE"})
 nTIPMAC := aScan(aHGNE, {| aVet | AllTrim(aVet[2]) == "GNE_TIPMAC"})
 nNOMMAC := aScan(aHGNE, {| aVet | AllTrim(aVet[2]) == "GNE_NOMMAC"})
 nCPOMAC := aScan(aHGNE, {| aVet | AllTrim(aVet[2]) == "GNE_CPOMAC"})
 If Empty(aCGNE[1,nCODITE])
  aCGNE[1,nCODITE]	:= StrZero(1, Len(aCGNE[1, nCODITE]))
 EndIf
 
 oGNE := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,"HS_DuplAC(oGNE:oBrowse:nAt, oGNE:aCols, {nNOMMAC})",,"+GNE_CODITE",,,99999,,,, oDlg, aHGNE, aCGNE)
 
 oGNE:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT
 oGNE:oBrowse:bGotFocus  := {|| Fs_ChgGNE()}  
 oGNE:oBrowse:bLostFocus := {|| cCpoSX3    := "M->GND_CHAVE", cSx3CodTab := "GCY"}  
 oGNE:bChange            := {|| Fs_ChgGNE()}                      
 
 
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. oGNE:TudoOk(), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 0
  While __lSX8 
   RollBackSXE()
  End
 ElseIf (nOpcA == 1 .And. nOpcE # 2)
  Begin Transaction
 	 FS_GrvGND(nReg)
  End Transaction  
  While __lSX8
   ConfirmSX8()
  End
 EndIf

Return(nil)

Static Function FS_GrvGND(nReg)

 Local lAchou := .T.
 Local nFor   := 0

 DbselectArea("GND")
 DbsetOrder(1) //GND_CODSEQ+GND_ALIASM
 lAchou := DbSeek(xFilial("GND") + M->GND_CODSEQ)

 If nOpcE == 3 .Or. nOpcE == 4   // INCLUSAO ou ALTERACAO
  RecLock("GND", !lAchou)
   HS_GRVCPO("GND")
   GND->GND_FILIAL  := xFilial("GND")
  MsUnlock()         
  
  DbSelectArea("GNE")
		DbSetOrder(1)//GNE_FILIAL+GNE_SEQGND+GNE_CODITE
		
		For nFor :=1 To Len(oGNE:aCols)
			lAchou := DbSeek(xFilial("GNE") + M->GND_CODSEQ + oGNE:aCols[nFor, nCODITE])
			If oGNE:aCols[nFor, Len(oGNE:aHeader)+1 ] == .T. .And. lAchou
			 RecLock("GNE", .F.)
				 DbDelete()
				MsUnlock()
				WriteSx2("GNE")
			Else
				RecLock("GNE", !lAchou )         
		 		GNE->GNE_FILIAL := xFilial("GNE")
     GNE->GNE_SEQGND := M->GND_CODSEQ     
     GNE->GNE_CODITE := oGNE:aCols[nFor, nCODITE]
     GNE->GNE_TIPMAC := oGNE:aCols[nFor, nTIPMAC]
     GNE->GNE_NOMMAC := oGNE:aCols[nFor, nNOMMAC]
     GNE->GNE_CPOMAC := oGNE:aCols[nFor, nCPOMAC]
				MsUnlock()
			EndIf
		Next
  
 Else // EXCLUSAO
  
  DbSelectArea("GNE")
		DbSetOrder(1)//GNE_FILIAL+GNE_SEQGND+GNE_CODITE
 	If DbSeek(xFilial("GNE") + M->GND_CODSEQ)
 		While !Eof() .And. GNE->GNE_FILIAL == xFilial("GNE") .And. GNE->GNE_SEQGND == M->GND_CODSEQ
	 		RecLock("GNE", .F.)
		 	 DbDelete()
			 MsUnlock()
			 WriteSx2("GNE")
		 	DbSkip()
		 End
		
   RecLock("GND", .F.)
    DbDelete()
   MsUnlock()
   WriteSx2("GND") 
  EndIf
 EndIf

Return(nil)

Function Hs_VldAC8()
 Local lRet     := .T.
 Local cCampo   := ReadVar()
 Local aArea    := GetArea()
 Local aAreaSx3 := SX3->(GetArea())
 Local aAreaSx2 := SX2->(GetArea())
 
 cSx3CodTab := "GCY"
 cCpoSX3    := "M->GND_CHAVE"
 
 If cCampo == "M->GND_ALIASM"
  DbSelectArea("SX2")
  DbSetOrder(1)
  If !DbSeek(&(cCampo))
   HS_MsgInf(STR0007, STR0008, STR0009) //"Tabela inexistente no dicionário de dados"###"Atenção"###"Validação de Tabela (SX2)"
   lRet := .F.
  Else 
   M->GND_CHAVE := "xFilial('"+&(cCampo)+"')"
  EndIf
 ElseIf cCampo == "M->GNE_TIPMAC"
  If Empty(&(cCampo))
   HS_MsgInf(STR0010, STR0008, STR0012) //"Necessário informar conteúdo para o campo 'Tipo Macro'"
   lRet := .F.      
  Else
   Fs_ChgGNE()
  EndIf
 ElseIf cCampo == "M->GNE_NOMMAC"        
  If (oGNE:aCols[oGNE:nAt, nTipMac] == '0') .And. ( Empty(oGNE:aCols[oGNE:nAt, nNOMMAC]) .Or. oGNE:aCols[oGNE:nAt, nNOMMAC] <> &(cCampo))
   If lRet := HS_ExisDic({{"C",&(cCampo)}},.F.) 
    oGNE:aCols[oGNE:nAt, nCPOMAC] := &(cCampo)
    &(cCampo) := "__"+lower(HS_CfgSx3(&(cCampo))[SX3->(FieldPos("X3_TIPO"))])+&(cCampo) 
   Else
    HS_MsgInf(STR0011, STR0008, STR0012)  //"Campo não encontrado"###"Campos Macro"
   EndIf
  EndIf                                                                             
  If !(lRet := HS_CountTB("GNE", " UPPER(GNE_NOMMAC) = '" +UPPER(&(cCampo))+"' ") == 0)
   HS_MsgInf(STR0013, STR0008, STR0012)  //"Nome da Macro já existente."
   oGNE:aCols[oGNE:nAt, nCPOMAC] := ""
  EndIf 
  Fs_ChgGNE()
 EndIF

 RestArea(aAreaSx2)
 RestArea(aAreaSx3)
 RestArea(aArea)
Return(lRet)

Static Function Fs_ChgGNE()
 
 lRdOnlyGNE := IIF(!Empty(ReadVar()) .And. ReadVar() == "M->GNE_TIPMAC", &(ReadVar()),oGNE:aCols[oGNE:nAt, nTipMac]) == '0'
 cSx3CodTab := M->GND_ALIASM
  
 If lRdOnlyGNE
  cCpoSX3 := "M->GNE_NOMMAC" 
  oGNE:aHeader[nNOMMAC][9] := "HSPSX3"
 Else
  oGNE:aHeader[nNOMMAC][9] := ""
  cCpoSX3 := "M->GNE_CPOMAC"    
 EndIf

 oGNE:Refresh()

Return(.T.)