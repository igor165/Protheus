#INCLUDE "JURA109A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

#Define COD		1
#Define CODPAI	2
#Define ANO		3
#Define MES		4

#Define ANOMES	1

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA109A
Cria tela para acompanhar os lançamentos tabeladados gerados pelo lote.

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA109A()
Local oDlg
Local aCoors    := FWGetDialogSize( oMainWnd )
Local oPanelL, oPanelR, oFWLayer
Local aCods := {}

Private lMarcar := .F.
Private oBrowseR

	Define MsDialog oDlg Title STR0007 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel Style nOR( WS_VISIBLE, WS_POPUP ) // "Lançamentos Tabelados"

		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlg, .F.)

		oFWLayer:AddCollumn( 'L', 10, .T.)
		oFWLayer:AddCollumn( 'R', 90, .T.)

		oFWLayer:addWindow('L','L1',STR0008,100,.T.,.F., /*bDown*/, , /*bGotFocus*/ ) // "Ano-Mês"

		oPanelL := oFWLayer:getWinPanel('L','L1')
		oPanelR := oFWLayer:GetColPanel( 'R' )

		//*************************************   Browse   ************************************************
		oBrowseR:= FWMarkBrowse():New()
		oBrowseR:SetOwner( oPanelR )
		oBrowseR:SetDescription( STR0009 ) // "Lançamento Tabelado"
		oBrowseR:SetAlias( 'NV4' )
		oBrowseR:SetLocate()
		oBrowseR:SetMenuDef( 'JURA109A' )
		oBrowseR:SetProfileID( '1' )
		oBrowseR:SetFilterDefault( "!Empty(NV4_CLOTE)" )
		oBrowseR:SetFieldMark( "NV4_OK" )
		oBrowseR:bAllMark := { ||  JurMarkALL(oBrowseR, "NV4", 'NV4_OK', lMarcar := !lMarcar,, .F.), oBrowseR:Refresh()  }
		oBrowseR:ForceQuitButton()
		oBrowseR:oBrowse:SetBeforeClose({|| oBrowseR:oBrowse:VerifyLayout()})
		oBrowseR:SetWalkThru(.F.)
		oBrowseR:SetAmbiente(.F.)
		JurSetLeg( oBrowseR, "NV4" )
		JurSetBSize( oBrowseR )
		oBrowseR:Activate()
		//***********************************   Fim Browse   **********************************************
		//**************************************   Tree  **************************************************
		oTree := DbTree():New( 0, 0, 0, 0, oPanelL,,, .T. )
		oTree:Align 	   := CONTROL_ALIGN_ALLCLIENT
		oTree:BCHANGE 	 := {|| }
		oTree:BLDBLCLICK := {|| }
		oTree:BLCLICKED  := {|| SetNV4(oTree, oBrowseR, aCods) }

		aCods := AtuTree(oTree)
		SetNV4(oTree, oBrowseR, aCods)
		//*************************************  Fim Tree  ************************************************

	Activate MsDialog oDlg Center

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cria o meno do Browse.

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	aAdd( aRotina, { STR0001 , 'PesqBrw'        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0002 , 'VIEWDEF.JURA027', 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0004 , 'VIEWDEF.JURA027', 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0005 , 'VIEWDEF.JURA027', 0, 5, 0, NIL } ) // "Excluir"
	aAdd( aRotina, { STR0010 , 'J109ADSel()'    , 0, 4, 0, NIL } ) // "Excluir Selec."
	aAdd( aRotina, { STR0006 , 'VIEWDEF.JURA027', 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria o model conforme a tela JURA027

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FWLoadModel('JURA027')

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria o view conforme a tela JURA027

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Return FWLoadView('JURA027')

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTree
Atualiza a arvore.

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuTree(oTree)
Local aArea := GetArea()
Local nI	:= 0

	oTree:Reset()
	oTree:BeginUpdate()

	aAnoMes := GetAllAnoMes()

	For nI := 1 to Len(aAnoMes)

		If aAnoMes[nI][COD] == aAnoMes[nI][CODPAI]
			oTree:AddItem(aAnoMes[nI][ANO], aAnoMes[nI][COD],"ENABLE_MDI","ENABLE_MDI",,,1)
		EndIF
		IF oTree:TreeSeek(aAnoMes[nI][CODPAI])
		    oTree:AddItem(aAnoMes[nI][MES],aAnoMes[nI][COD],"ENABLE_MDI","ENABLE_MDI",,,2)
		EndIF

	Next

	IF !Empty(aAnoMes)
		oTree:TreeSeek(aAnoMes[1][COD]) // Retorna ao primeiro nível
	EndIf
	oTree:EndUpdate()

	RestArea(aArea)

Return aAnoMes

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAllAnoMes
Busca todos os anos e meses possíveis.

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetAllAnoMes()
Local aRet    := {}, aSQL := {}
Local cQry    := ""
Local cPai    := ""
Local cPaiAno := ""
Local nI

	cQry += " SELECT DISTINCT(NV4.NV4_ANOMES) ANOMES " + CRLF
	cQry += " FROM " + RetSqlName("NV4") + " NV4 " + CRLF
	cQry += " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' " + CRLF
	cQry +=   " AND NV4.D_E_L_E_T_ = ' ' " + CRLF
	cQry +=   " AND NV4.NV4_CLOTE > '"+ Space(TamSx3('NV4_CLOTE')[1]) +"' " + CRLF
	aSQL := JurSQL(cQry, {"ANOMES"})

	If !Empty(aSQL)

		For nI := 1 to Len(aSQL)
			cCod := Padl(nI, 3, "0")
			cAno := Str(Year(SToD(aSQL[nI][ANOMES]+"01")), 4)
			cMes := StrZero( Month(SToD(aSQL[nI][ANOMES]+"01")), 2 )
			If cPaiAno <> cAno
				aAdd(aRet, {cCod, cCod, cAno, cMes})
				cPai 	:= aRet[nI][COD]
				cPaiAno := aRet[nI][ANO]
			Else
				aAdd(aRet, {cCod, cPai, cAno, cMes})
			EndIF
		Next

	EndIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetNV4
Filtra o Browse.

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetNV4(oTree, oBrowseR, aCods)
Local cFiltro := "!Empty(NV4_CLOTE) .And. (NV4_ANOMES == '" + GetAnoMes(oTree, aCods) + "')"

	oTree:Disable()
	oBrowseR:SetFilterDefault(cFiltro)
	oBrowseR:Refresh()
	oTree:Enable()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAnoMes
Pega o ano-mes do array aCods.

@Return lRet

@author Felipe Bonvicini Conti
@since 29/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetAnoMes(oTree, aCods)
Local cCargo := oTree:GetCargo()
Local cRet   := ""
Local nI

	For nI := 1 to LEN(aCods)
		If aCods[nI][COD] == cCargo
			cRet := aCods[nI][ANO]+aCods[nI][MES]
			Exit
		EndIf
	Next

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} J109ADSel()
Exclui lançamentos selecionados.

@Return cRet

@author Luciano Pereira dos Santos
@since 24/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109ADSel()
Local cRet := " "

MsgRun(STR0013, STR0010,{|| cRet := J109RunDel() } ) // Excluindo Lançamentos... #"Excluir Selec."

If !Empty(cRet)
	JurErrLog(STR0011 + CRLF + CRLF + cRet, STR0009) // "Os seguintes lançamentos não foram excluídos pois estão concluídos ou em pré-fatura:"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J109RunDel()
Processa a Exclusão dos lançamentos selecionados.

@Return cRet Messagens de retorno da rotina

@author Felipe Bonvicini Conti
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109RunDel()
Local cRet        := ""
Local lOk         := .F.
Local cMarca      := oBrowseR:Mark()
Local cFiltroDef  := oBrowseR:GetFilterDefault()
Local aArea       := GetArea()
Local aAreaWO     := NV4->(GetArea())
Local cFiltro     := cFiltroDef
Local cAux        := ""

cFiltro += " .And. (NV4_OK == '" + cMarca + "'" + " .AND. NV4_FILIAL = '" + xFilial("NV4") + "')"
cAux := &( '{|| ' + cFiltro + ' }')

NV4->(dbSetFilter(cAux, cFiltro ))
NV4->(dbSetOrder(1))
NV4->(dbgotop())

If !(NV4->(EOF()))
	lOk := MsgYesNo(STR0012) // "Deseja realmente excluir os registros selecionados?"
EndIf

If lOk

	BEGIN TRANSACTION
		While !(NV4->(EOF()))

			If NV4->NV4_SITUAC <> "2" .And. Empty(NV4->NV4_CPREFT)
				RecLock("NV4", .F.)
				NV4->(dbDelete())
				NV4->(MsUnlock())

				//Grava na fila de sincronização a exclusão
				J170GRAVA("NV4", xFilial("NV4") + NV4->NV4_COD, "5")
			Else
				cRet += STR0014 + NV4->NV4_COD + CRLF //"Código: "
			EndIF

			NV4->(dbSkip())

		End
	END TRANSACTION

	cAux := &( "{|| "+cFiltroDef+" }") //Filtro padrão - somente lançamentos ativos...
	NV4->(dbSetFilter(cAux, cFiltroDef))

	oBrowseR:Refresh()

	While GetSX8Len() > 0
		ConfirmSX8()
	EndDo

EndIf

RestArea( aArea )

Return cRet
