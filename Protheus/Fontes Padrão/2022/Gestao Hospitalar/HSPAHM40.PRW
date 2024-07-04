#INCLUDE "HSPAHM40.ch"
#INCLUDE "PROTHEUS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM40  บAutor  ณAlessandro Freire   บ Data ณ  21/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de recursos                                        บฑฑ
ฑฑบ          ณEsta rotina atualiza as tabelas GF0/5/6/7                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHM40()
Private aRotina
Private cCadastro
Private aCores

aCores := {	{"GF0->GF0_STATUS == '1' .AND. Empty(GF0->GF0_NRFATU)"  , "BR_VERDE"   },; // EM RECURSO
            {"GF0->GF0_STATUS == '2' .AND. Empty(GF0->GF0_NRFATU)"  , "BR_AMARELO" },; // ASSOCIADO
            {"GF0->GF0_STATUS != '2' .AND. !Empty(GF0->GF0_NRFATU)" , "BR_VERMELHO"} } // ASSOCIADO COM TITULOS


aRotina := MenuDef()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada - Adiciona rotinas ao aRotina       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If ExistBlock("HSM40ROT")
 	aRotAdic := ExecBlock("HSM40ROT", .F., .F.)
	 If ValType(aRotAdic) == "A"
	 	AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	 EndIf
 EndIf

cCadastro := STR0008 //"Cadastro de Leitos" // //"Recursos"

dbSelectArea("GF0")
dbSetOrder(1)

mBrowse(06, 01, 22, 75, "GF0",,,,,,aCores)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_AHM40  บAutor  ณAlessandro Freire   บ Data ณ  21/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Demonstra o detalhe dos extratos selecionados para que     บฑฑ
ฑฑบ          ณ seja montado o recurso a ser enviado para o convenio       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_AHM40(nOpc)

Local oDlg,oSayRec,oGetNumRec,oChkMarca,oFolder,oSBtnOk,oSBtnCancel

Local cGetNumRec  := ""
Local nContFor	  := 1
Local lTemRec	  := .f.
Local lTemBaixa	  := .f.
Local cCodConv	  := ""
Local nVlRecu	  := 0
Local NopcA       := 0
Local aHGF5		  := {}
Local aCGF5		  := {}
Local nUdadGF5	  := 0

Local aHGF6		  := {}
Local aCGF6		  := {}
Local nUdadGF6	  := 0

Local aHGF7	   	  := {}
Local aCGF7		  := {}
Local nUdadGF7	  := 0
Local cCposDet    := "/_FILATE/_ORIDES/_SEQDES/_CODDES/_DDESPE/_VALAPR/_VALPAG/_VALGLO/_NRRECO/_VALREC/_VALPER/_CDMGLO/_DSMGLO/_CDJGLO/_DSJGLO/_COMJGL/_STATUS/_NREXTM/_NREXTC/_NRSEQG"
Local lPergunte   := .F.
Local cMv_Grpmatm := GetMV("MV_GRPMATM")
Local cMV_GrpTaxd := GetMV("MV_GRPTAXD")
Local lRet		  := .T.

Private oDlgM40

// Caso o usuario cancele a pergunta, a rotina volta para o browse sem fazer nada.
If nOpc == 3
	If Pergunte("HSPM40",.T.)
 		If EMPTY(MV_PAR03)
	  		HS_MsgInf(STR0037,STR0021,STR0008) //###"Atencao",###"Recursos" //"Digite o Codigo do Convenio"
			lRet := .F.
		EndIf
	Else
	 	lRet := .F.
	EndIf
EndIf
If lRet
	RegToMemory("GF0",(nOpc == 3))

	If nOpc == 3
		cGetNumRec	:= M->GF0_NUMREC
		cCodConv	:= mv_par03
	Else

		// Recursos com tํtulo nใo podem mais ser alterados
		If nOpc != 6 .and. nOpc != 2 .and. ! Empty(GF0->GF0_NRFATU)
			HS_MsgInf(STR0035,STR0021,STR0008) //"Recursos com tํtulos nใo podem mais ser modificados",//###"Atencao",###"Recursos"
			Return(nil)
		EndIf

		cGetNumRec	:= GF0->GF0_NUMREC
		cCodConv	:= GF0->GF0_CODCON
	EndIf

	If nOpc == 3
		cCond	:= "GF5_CODCON = '" + mv_par03 + "' AND GF5_NREXTC BETWEEN '" + mv_par01 + "' and '" + mv_par02 + "' "
		cCond	+= " AND GF5_STATUS = '2' "
	Else
		cCond := "GF5_CODCON = '" + GF0->GF0_CODCON + "' "
		cCond	+= "AND GF5_NUMREC = '" + GF0->GF0_NUMREC + "' "
		cCond	+= "AND GF5_STATUS = '3' "
	EndIf


	cMarca	:= "IIf(Empty(GF5->GF5_IMARCA), 'LBTIK', 'LBNO')"
	nQtGF5 := HS_BDados("GF5", @aHGF5, @aCGF5, @nUDadGF5, 2,, cCond,,,STRTRAN(cCposDet, "/_", "/" + PrefixoCpo("GF5") + "_"),,,, "GF5_IMARCA", cMarca, .T.)
	nGF5_OK := aScan(aHGF5, {| aVet | Trim(aVet[2]) == "GF5_IMARCA"} )



	If nOpc == 3
		cCond	:= "GF6_CODCON = '" + mv_par03 + "' AND GF6_NREXTC BETWEEN '" + mv_par01 + "' and '" + mv_par02 + "' "
		cCond	+= " AND GF6_STATUS = '2' "
	Else
		cCond := "GF6_CODCON = '" + GF0->GF0_CODCON + "' "
		cCond	+= "AND GF6_NUMREC = '" + GF0->GF0_NUMREC + "' "
		cCond	+= "AND GF6_STATUS = '3' "
	EndIf
	cMarca	:= "IIf(Empty(GF6->GF6_IMARCA), 'LBTIK', 'LBNO')"
	nQtGF6 := HS_BDados("GF6", @aHGF6, @aCGF6, @nUDadGF6, 2,,cCond,,,STRTRAN(cCposDet, "/_", "/" + PrefixoCpo("GF6") + "_"),,,,"GF6_IMARCA",cMarca, .T.)
	nGF6_OK := aScan(aHGF6, {| aVet | Trim(aVet[2]) == "GF6_IMARCA"} )

	If nOpc == 3
		cCond	:= "GF7_CODCON = '" + mv_par03 + "' AND GF7_NREXTC BETWEEN '" + mv_par01 + "' and '" + mv_par02 + "' "
		cCond	+= " AND GF7_STATUS = '2' "
	Else
		cCond := "GF7_CODCON = '" + GF0->GF0_CODCON + "' "
		cCond	+= "AND GF7_NUMREC = '" + GF0->GF0_NUMREC + "' "
		cCond	+= "AND GF7_STATUS = '3' "
	EndIf
	cMarca	:= "IIf(Empty(GF7->GF7_IMARCA), 'LBTIK', 'LBNO')"
	nQtGF7 := HS_BDados("GF7", @aHGF7, @aCGF7, @nUDadGF7, 2,, cCond,,,STRTRAN(cCposDet, "/_", "/" + PrefixoCpo("GF7") + "_"),,,, "GF7_IMARCA", cMarca, .T.)
	nGF7_OK := aScan(aHGF7, {| aVet | Trim(aVet[2]) == "GF7_IMARCA"} )

	If nQtGF5 + nQtGF6 + nQtGF7 <= 0
		HS_MsgInf(STR0009,STR0021,STR0008) // // //"Nใo hแ registros para selecionar. Verifique os parโmetros informados."//###"Atencao",###"Recursos"
		RollBackSxe()
		Return(nil)
	EndIf

	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 020, .T., .T. } )
	AAdd( aObjects, { 100, 080, .T., .T.,.T. } )

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )

	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
	aPGDs := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlgM40 TITLE OemToAnsi(STR0008) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Recursos"

	// Monta a Enchoice
	oEncGF0 := MsMGet():New("GF0"  ,GF0->(Recno()), nOpc,,,,{"GF0_NUMREC","GF0_OBSERV"},aPObjs[1],,2,,,, oDlgM40)
	oEncGF0 :oBox:Align := CONTROL_ALIGN_ALLCLIENT

	// Monta o Folder
	@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel Of oDlgM40 Prompts STR0011,STR0012,STR0013 //"Material M้dico"###"Taxas Diแrias"###"Procedimentos"
	oFolder:Align := CONTROL_ALIGN_BOTTOM

	oFolder:aDialogs[1]:lActive := !(nQtGF5 == 0)
	oFolder:aDialogs[2]:lActive := !(nQtGF6 == 0)
	oFolder:aDialogs[3]:lActive := !(nQtGF7 == 0)

	// Material Medico
	oGF5 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder:aDialogs[1], aHGF5, aCGF5)
	oGF5:oBrowse:BlDblClick := {|| FS_DblClk( oGF5, nGF5_OK ) }
	oGF5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Taxas Diarias
	oGF6 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder:aDialogs[2], aHGF6, aCGF6)
	oGF6:oBrowse:BlDblClick := {|| FS_DblClk( oGF6, nGF6_OK ) }
	oGF6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Procedimentos
	oGF7 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder:aDialogs[3], aHGF7, aCGF7)
	oGF7:oBrowse:BlDblClick := {|| FS_DblClk( oGF7, nGF7_OK ) }
	oGF7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	ACTIVATE MSDIALOG oDlgM40 ON INIT EnchoiceBar (oDlgM40, {|| nOpcA := 1, oDlgM40:End()}, ;
															{|| nOpcA := 0, oDlgM40:End()})
EndIf
// Incluir
If nOpcA == 1 .and. nOpc > 2
	nQtGF5 := 0
	nQtGF6 := 0
	nQtGF7 := 0
	nGF5_IMARCA := aScan(oGF5:aHeader, {| aVet | aVet[2] == "GF5_IMARCA"} )
	nGF5_NREXTC := aScan(oGF5:aHeader, {| aVet | aVet[2] == "GF5_NREXTC"} )
	nGF5_SEQDES := aScan(oGF5:aHeader, {| aVet | aVet[2] == "GF5_SEQDES"} )
	nGF5_NRSEQG := aScan(oGF5:aHeader, {| aVet | aVet[2] == "GF5_NRSEQG"} )
	nGF5_CODDES := aScan(oGF5:aHeader, {| aVet | aVet[2] == "GF5_CODDES"} )

	nGF6_IMARCA := aScan(oGF6:aHeader, {| aVet | aVet[2] == "GF6_IMARCA"} )
	nGF6_NREXTC := aScan(oGF6:aHeader, {| aVet | aVet[2] == "GF6_NREXTC"} )
	nGF6_SEQDES := aScan(oGF6:aHeader, {| aVet | aVet[2] == "GF6_SEQDES"} )
	nGF6_NRSEQG := aScan(oGF6:aHeader, {| aVet | aVet[2] == "GF6_NRSEQG"} )
	nGF6_CODDES := aScan(oGF6:aHeader, {| aVet | aVet[2] == "GF6_CODDES"} )

	nGF7_IMARCA := aScan(oGF7:aHeader, {| aVet | aVet[2] == "GF7_IMARCA"} )
	nGF7_NREXTC := aScan(oGF7:aHeader, {| aVet | aVet[2] == "GF7_NREXTC"} )
	nGF7_SEQDES := aScan(oGF7:aHeader, {| aVet | aVet[2] == "GF7_SEQDES"} )
	nGF7_ORIDES := aScan(oGF7:aHeader, {| aVet | aVet[2] == "GF7_ORIDES"} )

	dbselectarea("GF5")
	DBSetOrder(1)
	//Posiciona no Registro que esta na matriz
	For nContFor := 1 to len( oGF5:aCols )
		if DbSeek(xFilial("GF5") + oGF5:aCols[nContFor][nGF5_NREXTC] + oGF5:aCols[nContFor][nGF5_SEQDES]  )
			// So altero o STATUS se for 2-disp. para recurso ou 3-em recurso
			If GF5->GF5_STATUS $  "23"
				RecLock("GF5", .F.)
				If oGF5:aCols[nContFor][nGF5_IMARCA] == "LBTIK" .and. ( nOpc == 3 .or. nOpc == 4 )
					GF5->GF5_STATUS	:= "3" // EM RECURSO
					GF5->GF5_NUMREC	:= cGetNumRec
 				GF5->GF5_DATSTA	:= dDataBase
	 			GF5->GF5_HORSTA	:= Time()
					nVlRecu         += GF5->GF5_VALGLO
					nQtGF5++
					lTemRec			     	:= .t.
					If oGF5:aCols[nContFor][nGF5_CODDES] == PADR(cMv_Grpmatm, LEN(GF5->GF5_CODDES)) //Detalha/o por grupo
 					HS_StaGFs("GF5", oGF5:aCols[nContFor][nGF5_NREXTC], oGF5:aCols[nContFor][nGF5_NRSEQG], {{"_NUMREC", cGetNumRec}})
 				EndIf

				Elseif oGF5:aCols[nContFor][nGF5_IMARCA] == "LBNO" .or. nOpc == 5
					GF5->GF5_STATUS := "2" // DISPONIVEL PARA RECURSO
					GF5->GF5_NUMREC := ""
 				GF5->GF5_DATSTA	:= dDataBase
	 			GF5->GF5_HORSTA	:= Time()
					If oGF5:aCols[nContFor][nGF5_CODDES] == PADR(cMv_Grpmatm, LEN(GF5->GF5_CODDES)) //Detalha/o por grupo
 	 			HS_StaGFs("GF5", oGF5:aCols[nContFor][nGF5_NREXTC], oGF5:aCols[nContFor][nGF5_NRSEQG], {{"_NUMREC", ""}})
     EndIf
				endif
				MsUnlock()
			Else
				lTemBaixa	:= .t.
			endif
		EndIf
	next

	dbselectarea("GF6")
	DBSetOrder(1)
	//Posiciona no Registro que esta na matriz
	For nContFor := 1 to len( oGF6:aCols )
		if DbSeek(xFilial("GF6") + oGF6:aCols[nContFor][nGF6_NREXTC] + oGF6:aCols[nContFor][nGF6_SEQDES]  )
			If GF6->GF6_STATUS $ "23"
				RecLock("GF6", .F.)
				if oGF6:aCols[nContFor][nGF6_IMARCA] == "LBTIK" .and. ( nOpc == 3 .or. nOpc == 4 )
					GF6->GF6_STATUS	:= "3" // EM RECURSO
					GF6->GF6_NUMREC	:= cGetNumRec
	 			GF6->GF6_DATSTA	:= dDataBase
 				GF6->GF6_HORSTA	:= Time()
					nVlRecu         += GF6->GF6_VALGLO
					nQtGF6++
					lTemRec				:= .t.
 				GF6->GF6_HORSTA	:= Time()
	 			GF6->GF6_NUMREC	:= cGetNumRec
					If oGF6:aCols[nContFor][nGF6_CODDES] == PADR(cMV_GrpTaxd, LEN(GF6->GF6_CODDES)) //Detalha/o por grupo
 					HS_StaGFs("GF6", oGF6:aCols[nContFor][nGF6_NREXTC], oGF6:aCols[nContFor][nGF6_NRSEQG], {{"_NUMREC", cGetNumRec}})
				 EndIf
				Elseif oGF6:aCols[nContFor][nGF6_IMARCA] == "LBNO" .or. nOpc == 5
					GF6->GF6_STATUS := "2" // DISPONIVEL PARA RECURSO
					GF6->GF6_NUMREC := ""
	 			GF6->GF6_DATSTA	:= dDataBase
 				GF6->GF6_HORSTA	:= Time()
					If oGF6:aCols[nContFor][nGF6_CODDES] == PADR(cMV_GrpTaxd, LEN(GF6->GF6_CODDES)) //Detalha/o por grupo
  				HS_StaGFs("GF6", oGF6:aCols[nContFor][nGF6_NREXTC], oGF6:aCols[nContFor][nGF6_NRSEQG], {{"_NUMREC", ""}})
  			EndIf
				endif
				MsUnlock()
			Else
				lTemBaixa	:= .t.
			endif
		EndIf
	next

	dbselectarea("GF7")
	DBSetOrder(IIF(HS_ExisDic({{"I", "GF7", 8}}, .F.), 8, 1)) //FILIAL+NREXTC+SEQDES+ORIDES
	//Posiciona no Registro que esta na matriz
	For nContFor := 1 to len( oGF7:aCols )
		If DbSeek(xFilial("GF7")+oGF7:aCols[nContFor][nGF7_NREXTC]+oGF7:aCols[nContFor][nGF7_SEQDES]+IIF(nGF7_ORIDES > 0, oGF7:aCols[nContFor][nGF7_ORIDES], "") )
			If GF7->GF7_STATUS $ "23"
				RecLock("GF7", .F.)
				If oGF7:aCols[nContFor][nGF7_IMARCA] == "LBTIK" .and. ( nOpc == 3 .or. nOpc == 4 )
					GF7->GF7_STATUS	:= "3" // EM RECURSO
					GF7->GF7_NUMREC	:= cGetNumRec
 				GF7->GF7_DATSTA	:= dDataBase
 				GF7->GF7_HORSTA	:= Time()
					lTemRec				:= .t.
					nVlRecu    += GF7->GF7_VALGLO
				 nQtGF7++
				Elseif oGF7:aCols[nContFor][nGF7_IMARCA] == "LBNO" .or. nOpc == 5
					GF7->GF7_STATUS := "2" // DISPONIVEL PARA RECURSO
					GF7->GF7_NUMREC := ""
 				GF7->GF7_DATSTA	:= dDataBase
 				GF7->GF7_HORSTA	:= Time()
				endif
				MsUnlock()
			Else
				lTemBaixa	:= .t.
			Endif
		EndIf
	next
EndIf

// Inclui ou altera o cabecalho de recursos
If lTemRec .and. nOpcA == 1
	RecLock( "GF0", nOpc == 3)
 	HS_GrvCpo("GF0")
	 GF0->GF0_FILIAL	:= xFilial("GF0")
	 GF0->GF0_NUMREC	:= cGetNumRec
	 GF0->GF0_CODCON	:= cCodConv
  if HS_ExisDic({{"C","GF0_OBSERV"}})
  	GF0->GF0_OBSERV := M->GF0_OBSERV
  EndIf
	 GF0->GF0_QTDDES	:= nQtGF5 + nQtGF6 + nQtGF7
	 GF0->GF0_DATREC	:= dDataBase
	 GF0->GF0_LOGARQ	:= HS_LogArq()
	 GF0->GF0_VLRECU := nVlRecu
	 GF0->GF0_STATUS	:= "1" // EM RECURSO
	MsUnlock()
EndIf

// Excluir
// Lembre-se, para excluir um recurso, o STATUS das tabelas G5,6 e 7 devem retornar para "1" e nao pode
// haver nenhum item do recurso ja baixado.
If (nOpc == 5 .and. ! lTemBaixa) .or. ( ! lTemRec .and. nOpc > 3)
	If nOpcA == 1
		RecLock("GF0",.F.)
		dbDelete()
		MsUnlock()
	EndIf
EndIf

// Rollback da numeracao automatica.
If nOpcA == 0
	While __lSX8
		RollBackSxe()
	End
Else
	While __lSX8
		ConfirmSx8()
	End
EndIf

Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ Legenda da movimentacao                                                 ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_AHM40Leg()
BrwLegenda(cCadastro,  STR0007, {	{"BR_VERDE"   , STR0017},; //"Legenda"###"Recurso em andamento"
                                  {"BR_AMARELO" , STR0018},;   //"Recurso Fechado"
                                  {"BR_VERMELHO", STR0036}} ) //"Recurso com tํtulos"
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClk บ Autor ณPaulo jose          บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca estrato                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(oNewGetD, nCpoPosi)
Local lRet := .T.
Local cPref := Substr(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2],1,3)
Local nNREXTC := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == cPref+"_NREXTC"} )
Local nSEQDES := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == cPref+"_SEQDES"} )

 If(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2] $ "GF5_COMJGL/GF6_COMJGL/GF7_COMJGL"  ;
  .And. !oNewGetD:aCols[oNewGetD:oBrowse:nAt,Len(oNewGetD:aHeader)+1])
   Hs_ExbMemo(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2],1,oNewGetD:aCols[oNewGetD:oBrowse:nAt, nNREXTC]+oNewGetD:aCols[oNewGetD:oBrowse:nAt, nSEQDES])
 Else
If oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] == "LBNO"
	oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBTIK"
Else
	oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBNO"
Endif
 EndIf

oNewGetD:oBrowse:Refresh()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_cartRecบAutor  ณDaniel Peixoto      บ Data ณ  13/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de impressใo da fichas do setor                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_CartRec()
	Private cGcsTipLoc := "F" //Recurso

 If !Pergunte("HSM40A",.T.)
 	Return(Nil)
 EndIf

 GDN->(dbSetOrder(1))
 If GDN->(DbSeek(xFilial("GDN") + MV_PAR01))
  HSPAHP44(, MV_PAR01)
 EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHs_ExbMemoบ Autor ณMicrosiga           บ Data ณ  10/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Hs_ExbMemo(cCampo, nInd, cChave, lExbTela, nTam)

Local aArea			:= getArea()
Local oDlgMsg		:= Nil
Local oTexto		:= Nil
Local oBtnOk		:= Nil
Local cRet 			:= ""
Local aStruct		:= HS_CfgSx3(cCampo)
Local cAlias		:= Substr(cCampo,1,3)
Local nCont			:= 0
Local cMemo			:= ''

Default lExbTela	:= .T.
Default nTam		:= 80

DBSelectArea(cAlias)
(cAlias)->( DBSetOrder(nInd) )
If (cAlias)->( DBSeek( xFilial(cAlias) + cChave ) )

cMemo := &(cCampo)

	If !lExbTela .And. !Empty(cMemo)

		For nCont := 1 to MLCount(cMemo, nTam)
			cRet += MemoLine(cMemo, nTam, nCont)+chr(13)+chr(10)
		Next

	EndIf

	If lExbTela

		DEFINE MSDIALOG oDlgMsg FROM 062,100 TO 213,400 TITLE OemToAnsi(aStruct[SX3->(FieldPos("X3_TITULO"))]) PIXEL

			@ 001, 001 GET oTexto VAR OemToAnsi(&(cAlias+"->"+cCampo)) MEMO READONLY SIZE 150, 060 OF oDlgMsg PIXEL

			oBtnOk := tButton():New( 062 , 123 , "Ok" , oDlgMsg , {|| oDlgMsg:End()} ,,,,,, .T. )
			oBtnOk:SetFocus()

		ACTIVATE MSDIALOG oDlgMsg CENTERED

	EndIf

EndIf

RestArea(aArea)

Return(cRet)

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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"    , 0, 1, 0, nil},; //"Pesquisar"
					 {OemToAnsi(STR0002), "HS_AHM40(2)" , 0, 2, 0, nil},; //"Visualizar"
					 {OemToAnsi(STR0003), "HS_AHM40(3)" , 0, 3, 0, nil},; //"Incluir"
					 {OemToAnsi(STR0004), "HS_AHM40(4)" , 0, 4, 0, nil},; //"Alterar"
					 {OemToAnsi(STR0005), "HS_AHM40(5)" , 0, 5, 0, nil},; //"Excluir"
		           	 {OemtoAnsi(STR0039), "HS_CARTREC()", 0, 3, 0, nil},; //"Carta"
					 {OemtoAnsi(STR0007), "HS_AHM40Leg" , 0, 3, 0, nil}}  //"Legenda"
Return(aRotina)
