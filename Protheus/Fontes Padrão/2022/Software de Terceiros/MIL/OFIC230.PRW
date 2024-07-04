#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIC230.CH"

/*/{Protheus.doc} OFIC230
Coletor/Leitor VT100 - Guardar Itens no Estoque partindo do Volume de Entrada

@author Andre Luis Almeida
@since 24/08/2021
@version undefined

@type function
/*/
Function OFIC230()
Private nTamCol := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private aVCX    := {} // VCX do Volume de Entrada selecionado
Private nQtdDias  := 7 // Dias a Retroagir 
Private nLinT1    := 1
Private lVerGrupo := ( GetNewPar("MV_MIL0119","2") == "2" ) // COLETOR DE DADOS NA CONF.DE ITENS - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
//
OC2300011_TELA1(.t.,.t.) // T1 - Escolher qual Volume de Entrada
//
Return

/*/{Protheus.doc} OC2300011_TELA1
T1 - Escolher qual Volume de Entrada

@author Andre Luis Almeida
@since 24/08/2021
@version undefined

@type function
/*/
Static Function OC2300011_TELA1(lPergDias,lPergNF) // T1 - Escolher qual Volume de Entrada
Local nPos     := 0
Local nTamVol  := GetSX3Cache("VCX_VOLUME","X3_TAMANHO")
Local cVolume  := space(nTamVol)
Local aSize    := {nTamCol}
Local aColunas := {STR0001} // Volume de Entrada
Local aLinhas  := {}
Local aTotVCX  := {}
Local cQuery   := ""
Local cQAlVCX  := "SQLVCX"
Local cEnder   := ""
Default lPergDias := .f.
Default lPergNF   := .f.
//
While .t.
	//
	aLinhas := {}
	aTotVCX := {}
	//
	If lPergNF
		cVolume := OC2300051_QualVolume(nTamVol)
		If cVolume == "ESC"
			Exit
		EndIf
	EndIf
	If lPergDias .and. Empty(cVolume)
		If !OC2300041_DiasRetroagir() // Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada que fazem parte do Volume
			lPergDias := .t.
			lPergNF   := .t.
			Loop
		EndIf
	EndIf
	//
	cQuery := "SELECT DISTINCT VCX.VCX_VOLUME "
	cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
	cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
	If !Empty(cVolume)
		cQuery += "   AND VCX.VCX_VOLUME = '"+cVolume+"' "
	Else
		cQuery += "   AND VCX.VCX_VOLUME <> ' ' "
	EndIf
	cQuery += "   AND VCX.D_E_L_E_T_ = ' ' "
	cQuery += "   AND EXISTS ( "
	cQuery += "SELECT SF1.F1_DOC "
	cQuery += "  FROM "+RetSQLName("SF1")+" SF1 "
	cQuery += " WHERE SF1.F1_FILIAL  = '"+xFilial("SF1")+"'"
	cQuery += "   AND SF1.F1_DOC     = VCX.VCX_DOC "
	cQuery += "   AND SF1.F1_SERIE   = VCX.VCX_SERIE "
	cQuery += "   AND SF1.F1_FORNECE = VCX.VCX_FORNEC "
	cQuery += "   AND SF1.F1_LOJA    = VCX.VCX_LOJA "
	If Empty(cVolume)
		cQuery += "   AND SF1.F1_DTDIGIT >= '"+dtos(dDatabase-nQtdDias)+"'"
	EndIf
	cQuery += "   AND SF1.D_E_L_E_T_ = ' ' )"
	cQuery += " ORDER BY VCX_VOLUME "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVCX , .F., .T. )
	While !( cQAlVCX )->( Eof() )
		//
		aAdd(aLinhas,{ right( ( cQAlVCX )->( VCX_VOLUME ) , nTamCol) })
		aAdd(aTotVCX,( cQAlVCX )->( VCX_VOLUME ))
		//
		( cQAlVCX )->( DbSkip() )
	EndDo
	( cQAlVCX )->( DbCloseArea() )
	DbSelectArea("VCX")
	OC2300031_LimpaTelaColetor()
	If len(aLinhas) > 0
		If len(aLinhas) < nLinT1
			nLinT1 := 1
		EndIf
		If len(aLinhas) > 1 .or. Empty(cVolume)
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT1) // Lista os Volumes de Entrada
		Else
			nPos := 1
		EndIf
		If nPos > 0
			If !Empty(aTotVCX[nPos])
				nLinT1 := nPos
				aVCX := {}
				cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
				cQuery += "       SB1.B1_GRUPO   , "
				cQuery += "       SB1.B1_CODITE  , "
				cQuery += "       SB1.B1_DESC    , "
				cQuery += "       SUM(VCX.VCX_QTDITE) AS QTDE "
				cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
				cQuery += "  JOIN " + RetSqlName("SB1") + " SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=VCX.VCX_COD AND SB1.D_E_L_E_T_=' ' ) "
				cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
				cQuery += "   AND VCX.VCX_VOLUME = '"+aTotVCX[nPos]+"' "
				cQuery += "   AND VCX.D_E_L_E_T_ = ' ' "
				cQuery += " GROUP BY SB1.R_E_C_N_O_ , SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVCX , .F., .T. )
				While !( cQAlVCX )->( Eof() )
					DbSelectArea("SB1")
					DbGoTo(( cQAlVCX )->( RECSB1 ))
					If !Localiza(SB1->B1_COD)
						SB5->(DbSetOrder(1))
						SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
						cEnder := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")+" "+FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
					Else
						cEnder := STR0002 // Item Enderecado
					EndIf
					aAdd(aVCX,{ cEnder ,;
								( cQAlVCX )->( B1_GRUPO )  ,;
								( cQAlVCX )->( B1_CODITE ) ,;
								( cQAlVCX )->( B1_DESC )   ,;
								( cQAlVCX )->( QTDE )      })
					( cQAlVCX )->( DbSkip() )
				EndDo
				( cQAlVCX )->( DbCloseArea() )
				DbSelectArea("VCX")
				If lVerGrupo
					aSort(aVCX,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] }) // Ordem: Localizacao + Grupo + Codigo do Item
				Else
					aSort(aVCX,,,{|x,y| x[1] + x[3]        < y[1] + y[3]        }) // Ordem: Localizacao + Codigo do Item
				EndIf
				OC2300021_TELA2(1) // T2 - Listar Endereco/Item para ser guardado
			EndIf
			lPergDias := .f.
			lPergNF   := !Empty(cVolume)
		Else
			lPergDias := .t.
			lPergNF   := .t.
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		If !Empty(cVolume)	
			VTAlert(STR0004,STR0003) // Volume nao encontrado! / Atencao
		Else
			VTAlert(STR0005,STR0003) // Nao existe Volume de Entrada. / Atencao
		EndIf
		lPergDias := .t.
		lPergNF   := .t.
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OC2300021_TELA2
T2 - Listar Endereco/Item para ser guardado

@author Andre Luis Almeida
@since 24/08/2021
@version undefined

@type function
/*/
Static Function OC2300021_TELA2(nPosItem) // T2 - Listar Endereco/Item para ser guardado
Default nPosItem := 1
//
While .t.
	//
	OC2300031_LimpaTelaColetor()
	//
	VtBeep(1) // 1 Beep - Item na Tela
	@ 00, 00 VTSay PadR(STR0006, nTamCol) // Endereco
	@ 01, 00 VTSay PadR(aVCX[nPosItem,1],nTamCol)
	@ 02, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(aVCX[nPosItem,2],nTamCol)
	@ 04, 00 VTSay PadR(aVCX[nPosItem,3],nTamCol)
	@ 05, 00 VTSay PadR(aVCX[nPosItem,4],nTamCol)
	@ 06, 00 VTSay PadR(STR0007+": "+Alltrim(Transform(aVCX[nPosItem,5],VCX->(X3PICTURE("VCX_QTDITE")))),nTamCol) // Qtd.
	@ 07, (nTamCol-1) VTGet ">" Picture "@!"
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If len(aVCX) == nPosItem
			OC2300031_LimpaTelaColetor()
			VtBeep(3) // 3 Beep - Fim do Processo
			VTAlert(STR0008,STR0003) // Todos os Itens foram guardados! / Atencao
			Exit
		ElseIf len(aVCX) > nPosItem
			nPosItem++
		Else
			Exit
		EndIf
	Else
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OC2300031_LimpaTelaColetor
Limpa a Tela do Coletor 

@author Andre Luis Almeida
@since 24/08/2021
@version undefined

@type function
/*/
Static Function OC2300031_LimpaTelaColetor() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OC2300041_DiasRetroagir
Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada

@author Andre Luis Almeida
@since 24/08/2021
@version undefined
@return lRet, logico, Indica se informou os dias ou foi dado ESC

@type function
/*/
Static Function OC2300041_DiasRetroagir()
Local lRet := .t.
OC2300031_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001,nTamCol) // Volume de Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(Transform(dDataBase,"@D"), nTamCol)
@ 04, 00 VTSay PadR(STR0009, nTamCol) // Dias a retroagir?
@ 05, 00 VTGet nQtdDias Picture "@E 999999" Valid nQtdDias>=0
VTRead
If VTLastKey() == 27 // ESC
	lRet := .f.
EndIf
Return lRet

/*/{Protheus.doc} OC2300051_QualVolume
Tela Pergunta o Volume de Entrada

@author Andre Luis Almeida
@since 23/03/2019
@version undefined
@return cRet, caracter, Volume de Entrada

@type function
/*/
Static Function OC2300051_QualVolume(nTam)
Local cRet := space(nTam)
OC2300031_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001,nTamCol) // Volume de Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(STR0010,nTamCol) // Digite
@ 04, 00 VTSay PadR(STR0011,nTamCol) // Codigo do Volume
@ 05, 00 VTGet cRet Picture "@!"
VTRead
If VTLastKey() == 27 // ESC
	cRet := "ESC"
EndIf
Return cRet