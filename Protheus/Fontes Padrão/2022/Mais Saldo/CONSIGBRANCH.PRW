#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


Function CONSIGBRANCH()
	Static _ScreenSelected 	:= {}
	Private aBranchSel 		:= {}
    Private cBranchTable 	:= GetNextAlias()
	Private oBranchBrowse 	:= FWMarkBrowse():New()

	fSetBranchTmp()
	DbSelectArea(cBranchTable)
	oBranchBrowse:SetAlias(cBranchTable)
	aColsBMark := fGColsMark()
	oBranchBrowse:SetFields(aColsBMark)
	oBranchBrowse:SetFieldMark('BCH_OK')
	oBranchBrowse:SetMenuDef('CONSIGBRANCH')
	oBranchBrowse:SetDescription(OemToAnsi("Seleção de Filiais"))
	oBranchBrowse:SetAfterMark({|| fSelBranch() })
	oBranchBrowse:SetAllMark({|| fSelAllMBrowse(oBranchBrowse) })
	oBranchBrowse:Activate()
	DbCloseArea()
Return aBranchSel


/*/{Protheus.doc} function fGetBranch
Consulta Filiais disponíveis para seleção no Grupo de Empresas logado.
@author  hugo.de.oliveira
@since   25/04/2022
@version 1.0
/*/
Static Function fGetBranch()
	Local oBranch
	Local nY 		:= 1
	Local aBranch 	:= {}
	Local aSM0 		:= {}

	aSM0 := FWLoadSM0()

	For nY := 1 To Len(aSM0)
		If AllTrim(aSM0[nY][1]) == cEmpAnt
			oBranch := JsonObject():New()
			oBranch['codigoGrupo']  := AllTrim(aSM0[nY][1])
			oBranch['codigoFilial'] := LTrim(aSM0[nY][2])
			oBranch['nomeFilial']   := AllTrim(aSM0[nY][7])
			oBranch['cnpjFilial']   := AllTrim(aSM0[nY][18])
			Aadd(aBranch, oBranch)
			FreeObj(oBranch)
		EndIf
	Next nY
Return aBranch


/*/{Protheus.doc} function fBranchCol()
Cria estrutura de colunas usadas na tela de Seleção de Filiais.
@author  hugo.de.oliveira
@since   25/04/2022
@version 1.0
/*/
Static Function fBranchCol()
	Local aColumns := {}

	aAdd(aColumns, { "BCH_OK"    , "C", 02,  00 })
	aAdd(aColumns, { "BCH_GROUP" , "C", 02,  00 })
	aAdd(aColumns, { "BCH_CD",     "C", TamSx3("RA_FILIAL")[1], 00 })
	aAdd(aColumns, { "BCH_NAME"  , "C", 40, 00 })
	aAdd(aColumns, { "BCH_CNPJ"  , "C", 14, 00 })
Return aColumns
	

/*/{Protheus.doc} function fSetBranchTmp()
Cria tela temporária de Seleção de Filiais.
@author  hugo.de.oliveira
@since   25/04/2022
@version 1.0
/*/
Static Function fSetBranchTmp()
	Local nX 		:= 1
	Local aColumn	:= {}
	Local lRet		:= .F.
	Local aArea		:= GetArea()

	aColumn  	:= fBranchCol()
	oGroupTable := FWTemporaryTable():New(cBranchTable, aColumn)
	oGroupTable:Create()
	aBranch := fGetBranch()

	DbSelectArea(cBranchTable)
		For nX := 1 To Len(aBranch)
			RecLock(cBranchTable, .T.)
				(cBranchTable)->BCH_GROUP := aBranch[nX]['codigoGrupo']
				(cBranchTable)->BCH_CD    := aBranch[nX]['codigoFilial']
				(cBranchTable)->BCH_NAME  := aBranch[nX]['nomeFilial']
				(cBranchTable)->BCH_CNPJ  := aBranch[nX]['cnpjFilial']
			MsUnLock()
		Next nX
		lRet := .T.
	RestArea(aArea)
Return


/*/{Protheus.doc} function fGColsMark()
Seta os campos da tabela temporária de Seleção de Filiais.
@author  hugo.de.oliveira
@since   25/04/2022
@version 1.0
/*/
Static Function fGColsMark()
	Local nX		  := 0
	Local aColsAux 	  := {}
	Local aFields  	  := { "Grupo", "Filial", "CNPJ", "Nome" }
	Local aFieldValue := {{ ||(cBranchTable)->BCH_GROUP }, { ||(cBranchTable)->BCH_CD }, { ||(cBranchTable)->BCH_CNPJ }, { ||(cBranchTable)->BCH_NAME }}

	For nX := 1 to Len(aFields)
		If !Empty(aFields[nX])
			aAdd(aColsAux, {aFields[nX], aFieldValue[nX], "C", ,1, 11, 2,.F.,,,,,,,,1})
		EndIf
	Next nX
Return aColsAux


/*/{Protheus.doc} function fSelBranch
Seleciona ou remove a marcação de filiais.
@author  hugo.de.oliveira
@since   25/04/2022
@version 1.0
/*/
Static Function fSelBranch()
	Local oSelected
	Local nPosition := fGetMarkPos()

	If oBranchBrowse:IsMark()
			oSelected := JsonObject():New()
			oSelected['codigoGrupo']  := Alltrim((cBranchTable)->BCH_GROUP)
			oSelected['codigoFilial'] := Ltrim((cBranchTable)->BCH_CD)
			oSelected['nomeFilial']   := Alltrim((cBranchTable)->BCH_NAME)
			oSelected['cnpjFilial']   := Alltrim((cBranchTable)->BCH_CNPJ)
			
			Aadd(aBranchSel, oSelected)
			FreeObj(oSelected)
			Aadd(_ScreenSelected, oBranchBrowse:At())
	Else
		If (nPosition > 0)
			nLastSize := Len(aBranchSel)
			aDel(aBranchSel, nPosition)
			aDel(_ScreenSelected, nPosition)
			aSize(aBranchSel, (nLastSize - 1))
			aSize(_ScreenSelected, (nLastSize - 1))
		EndIF
	EndIf
Return


/*/{Protheus.doc} function fGetMarkPos()
Consulta a posição da filial marcada.
@author  hugo.de.oliveira
@since   25/04/2022
@version 1.0
/*/
Static Function fGetMarkPos()
	Local nPos := 0
	Local nX   := 1

	For nX := 1 To Len(aBranchSel)
		If aBranchSel[nX]['codigoGrupo'] + aBranchSel[nX]['codigoFilial'] + aBranchSel[nX]['cnpjFilial'] == Alltrim((cBranchTable)->BCH_GROUP) + Ltrim((cBranchTable)->BCH_CD) + Alltrim((cBranchTable)->BCH_CNPJ)
			Return nX
		EndIf
	Next nX
Return nPos


/*/{Protheus.doc} function fGetMarkPos()
Define o menu da tela temporária.
@author  hugo.de.oliveira
@since   25/04/2022
@version 1.0
/*/
Static Function MenuDef()
	Private aMenu := {}
	ADD OPTION aMenu TITLE OemToAnsi("Avançar") 		 ACTION 'Closebrowse()' 				OPERATION 7 ACCESS 0
	ADD OPTION aMenu TITLE OemToAnsi("Marcar/Desmarcar") ACTION 'fSelAllMBrowse(oBranchBrowse)' OPERATION 8  ACCESS 0
Return aMenu
