#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIC070.CH"

/*/{Protheus.doc} OFIC070
Coletor/Leitor VT100 - Guardar Itens no Estoque partindo da NF de Entrada

@author Andre Luis Almeida
@since 01/04/2019
@version undefined

@type function
/*/
Function OFIC070()
Private nTamCol := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private aSD1    := {} // SD1 da NF de Entrada selecionada
Private nQtdDias  := 7 // Dias a Retroagir 
Private nLinT1    := 1
Private lVerGrupo := ( GetNewPar("MV_MIL0119","2") == "2" ) // COLETOR DE DADOS NA CONF.DE ITENS - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
//
OC0700011_TELA1(.t.,.t.) // T1 - Escolher qual NF de Entrada
//
Return

/*/{Protheus.doc} OC0700011_TELA1
T1 - Escolher qual NF de Entrada

@author Andre Luis Almeida
@since 01/04/2019
@version undefined

@type function
/*/
Static Function OC0700011_TELA1(lPergDias,lPergNF) // T1 - Escolher qual NF de Entrada
Local nPos     := 0
Local nTamNF   := TamSx3("F1_DOC")[1]
Local nTamSer  := TamSx3("F1_SERIE")[1]
Local cNroNF   := space(nTamNF+nTamSer)
Local aSize    := {nTamCol}
Local aColunas := {STR0001} // NF Entrada
Local aLinhas  := {}
Local aRecSF1  := {}
Local cQuery   := ""
Local cQAlSF1  := "SQLSF1"
Local cQAlSD1  := "SQLSD1"
Local cEnder   := ""
Default lPergDias := .f.
Default lPergNF   := .f.
//
While .t.
	//
	aLinhas  := {}
	aRecSF1  := {}
	//
	If lPergNF
		cNroNF := OC0700051_QualNF(nTamNF+nTamSer)
		If cNroNF == "ESC"
			Exit
		EndIf
	EndIf
	If lPergDias .and. Empty(cNroNF)
		If !OC0700041_DiasRetroagir() // Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada
			lPergDias := .t.
			lPergNF   := .t.
			Loop
		EndIf
	EndIf
	cQuery := "SELECT SF1.F1_FILIAL  , "
	cQuery += "       SF1.F1_DOC     , "
	cQuery += "       SF1.F1_SERIE   , "
	cQuery += "       SF1.F1_FORNECE , "
	cQuery += "       SF1.F1_LOJA    , "
	cQuery += "       SF1.F1_TIPO    , "
	cQuery += "       SF1.R_E_C_N_O_ AS RECSF1"
	cQuery += "  FROM "+RetSQLName("SF1")+" SF1 "
	cQuery += " WHERE SF1.F1_FILIAL = '"+xFilial("SF1")+"'"
	If !Empty(cNroNF)
		cQuery += "   AND SF1.F1_DOC = '"+substr(cNroNF,1,nTamNF)+"'"
		If len(Alltrim(cNroNF)) > nTamNF
			cQuery += "   AND SF1.F1_SERIE = '"+substr(cNroNF,nTamNF+1,nTamSer)+"'"
		EndIf
	Else
		cQuery += "   AND SF1.F1_DTDIGIT >= '"+dtos(dDatabase-nQtdDias)+"'"
	EndIf
	cQuery += "   AND SF1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY SF1.F1_DOC , SF1.F1_SERIE "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF1 , .F., .T. )
	While !( cQAlSF1 )->( Eof() )
		//
		If ( cQAlSF1 )->( F1_TIPO ) <> "D"
			cQuery := "SELECT A2_NOME "
			cQuery += "  FROM "+RetSQLName("SA2")
			cQuery += " WHERE A2_FILIAL='"+xFilial("SA2")+"'"
			cQuery += "   AND A2_COD='"+( cQAlSF1 )->( F1_FORNECE )+"'"
			cQuery += "   AND A2_LOJA='"+( cQAlSF1 )->( F1_LOJA )+"'"
			cQuery += "   AND D_E_L_E_T_=' '"
		Else
			cQuery := "SELECT A1_NOME "
			cQuery += "  FROM "+RetSQLName("SA1")
			cQuery += " WHERE A1_FILIAL='"+xFilial("SA1")+"'"
			cQuery += "   AND A1_COD='"+( cQAlSF1 )->( F1_FORNECE )+"'"
			cQuery += "   AND A1_LOJA='"+( cQAlSF1 )->( F1_LOJA )+"'"
			cQuery += "   AND D_E_L_E_T_=' '"
		EndIf
		//
		aAdd(aLinhas,{ left( ( cQAlSF1 )->( F1_DOC )+" "+( cQAlSF1 )->( F1_SERIE )+" "+FM_SQL(cQuery),nTamCol) })
		aAdd(aRecSF1,( cQAlSF1 )->( RECSF1 ))
		//
		( cQAlSF1 )->( DbSkip() )
	EndDo
	( cQAlSF1 )->( DbCloseArea() )
	DbSelectArea("SF1")
	OC0700031_LimpaTelaColetor()
	If len(aLinhas) > 0
		If len(aLinhas) < nLinT1
			nLinT1 := 1
		EndIf
		If len(aLinhas) > 1 .or. Empty(cNroNF)
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT1) // Lista as NFs Entrada
		Else
			nPos := 1
		EndIf
		If nPos > 0
			If aRecSF1[nPos] > 0
				nLinT1 := nPos
				SF1->(DbGoTo(aRecSF1[nPos]))
				aSD1 := {}
				cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
				cQuery += "       SB1.B1_GRUPO   , "
				cQuery += "       SB1.B1_CODITE  , "
				cQuery += "       SB1.B1_DESC    , "
				cQuery += "       SD1.D1_QUANT   "
				cQuery += "  FROM "+RetSQLName("SD1")+" SD1"
				cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "
				cQuery += " WHERE SD1.D1_FILIAL  = '"+SF1->F1_FILIAL +"'"
				cQuery += "   AND SD1.D1_DOC     = '"+SF1->F1_DOC    +"'"
				cQuery += "   AND SD1.D1_SERIE   = '"+SF1->F1_SERIE  +"'"
				cQuery += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"'"
				cQuery += "   AND SD1.D1_LOJA    = '"+SF1->F1_LOJA   +"'"
				cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD1 , .F., .T. )
				While !( cQAlSD1 )->( Eof() )
					DbSelectArea("SB1")
					DbGoTo(( cQAlSD1 )->( RECSB1 ))
					If !Localiza(SB1->B1_COD)
						SB5->(DbSetOrder(1))
						SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
						cEnder := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")+" "+FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
					Else
						cEnder := STR0002 // "Item Enderecado"
					EndIf
					aAdd(aSD1,{ cEnder ,;
								( cQAlSD1 )->( B1_GRUPO )  ,;
								( cQAlSD1 )->( B1_CODITE ) ,;
								( cQAlSD1 )->( B1_DESC )   ,;
								( cQAlSD1 )->( D1_QUANT )  })
					( cQAlSD1 )->( DbSkip() )
				EndDo
				( cQAlSD1 )->( DbCloseArea() )
				DbSelectArea("SD1")
				If lVerGrupo
					aSort(aSD1,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] }) // Ordem: Localizacao + Grupo + Codigo do Item
				Else
					aSort(aSD1,,,{|x,y| x[1] + x[3]        < y[1] + y[3]        }) // Ordem: Localizacao + Codigo do Item
				EndIf
				OC0700021_TELA2(1) // T2 - Listar Endereco/Item para ser guardado
			EndIf
			lPergDias := .f.
			lPergNF   := !Empty(cNroNF)
		Else
			lPergDias := .t.
			lPergNF   := .t.
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		If !Empty(cNroNF)	
			VTAlert(STR0004,STR0003) // Nro.NF + Serie nao encontrada! / Atencao
		Else
			VTAlert(STR0005,STR0003) // Nao existe NF de Entrada. / Atencao
		EndIf
		lPergDias := .t.
		lPergNF   := .t.
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OC0700021_TELA2
T2 - Listar Endereco/Item para ser guardado

@author Andre Luis Almeida
@since 01/04/2019
@version undefined

@type function
/*/
Static Function OC0700021_TELA2(nPosItem) // T2 - Listar Endereco/Item para ser guardado
Default nPosItem := 1
//
While .t.
	//
	OC0700031_LimpaTelaColetor()
	//
	VtBeep(1) // 1 Beep - Item na Tela
	@ 00, 00 VTSay PadR(STR0006, nTamCol) // Endereco
	@ 01, 00 VTSay PadR(aSD1[nPosItem,1],nTamCol)
	@ 02, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(aSD1[nPosItem,2],nTamCol)
	@ 04, 00 VTSay PadR(aSD1[nPosItem,3],nTamCol)
	@ 05, 00 VTSay PadR(aSD1[nPosItem,4],nTamCol)
	@ 06, 00 VTSay PadR(STR0007+": "+Alltrim(Transform(aSD1[nPosItem,5],SD1->(X3PICTURE("D1_QUANT")))),nTamCol) // Qtd.
	@ 07, (nTamCol-1) VTGet ">" Picture "@!"
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If len(aSD1) == nPosItem
			OC0700031_LimpaTelaColetor()
			VtBeep(3) // 3 Beep - Fim do Processo
			VTAlert(STR0008,STR0003) // Todos os Itens foram guardados! / Atencao
			Exit
		ElseIf len(aSD1) > nPosItem
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

/*/{Protheus.doc} OC0700031_LimpaTelaColetor
Limpa a Tela do Coletor 

@author Andre Luis Almeida
@since 01/04/2019
@version undefined

@type function
/*/
Static Function OC0700031_LimpaTelaColetor() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OC0700041_DiasRetroagir
Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada

@author Andre Luis Almeida
@since 01/04/2019
@version undefined
@return lRet, logico, Indica se informou os dias ou foi dado ESC

@type function
/*/
Static Function OC0700041_DiasRetroagir()
Local lRet := .t.
OC0700031_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001,nTamCol) // NF Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(Transform(dDataBase,"@D"), nTamCol)
@ 04, 00 VTSay PadR(STR0009, nTamCol) // Dias a retroagir?
@ 05, 00 VTGet nQtdDias Picture "@E 999999" Valid nQtdDias>=0
VTRead
If VTLastKey() == 27 // ESC
	lRet := .f.
EndIf
Return lRet

/*/{Protheus.doc} OC0700051_QualNF
Tela Pergunta o Nro da NF + Serie

@author Andre Luis Almeida
@since 23/03/2019
@version undefined
@return cRet, caracter, Nro+Serie da NF

@type function
/*/
Static Function OC0700051_QualNF(nTam)
Local cRet := space(nTam)
OC0700031_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001,nTamCol) // NF Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(STR0010,nTamCol) // Digite
@ 04, 00 VTSay PadR(STR0011,nTamCol) // Nro.NF + Serie
@ 05, 00 VTGet cRet Picture "@!"
VTRead
If VTLastKey() == 27 // ESC
	cRet := "ESC"
EndIf
Return cRet