#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA069.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA069A
Modelo de dados do títulos de adiantamentos.

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
@Obs        Dummy Function
/*/
//------------------------------------------------------------------------------
Function JURA069A()
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta estrutura de funções do Browse

@return     aRotina, array, Array de Rotinas

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, "VIEWDEF.JURA069"  , 0, 2, 0, NIL } ) //"Visualizar"

Return (aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do controle de adiantamento.

@return     oModel, objeto, Estrutura do modelo de dados 

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStructCab  := FWFormStruct(1, "SE1")
	Local oStructSE1  := FWFormStruct(1, "SE1")
	Local bLoadGrid   := {|oModelGrid| LoadGrid(oModelGrid)}
	Local oModel      := Nil
	//------------------------------------
	//Cria campos de escritório e fatura
	//------------------------------------
	CreateField(@oStructSE1, 1)

	oModel := MPFormModel():New("JURA069A")

	oModel:AddFields("CABMASTER",, oStructCab)
	oModel:AddGrid("SE1DETAIL", "CABMASTER", oStructSE1,,,,, bLoadGrid)
	oModel:SetRelation("SE1DETAIL", { { "E1_FILIAL", "E1_FILIAL" }, { "E1_PREFIXO", "E1_PREFIXO" }, { "E1_NUM", "E1_NUM" }, { "E1_PARCELA", "E1_PARCELA" }, { "E1_TIPO", "E1_TIPO" } }, SE1->( IndexKey( 1 ) ))  //CONTRATOS DA FATURA

	oModel:SetDescription(STR0007) //"Controle de adiantamentos"

Return (oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface do Agrupador de Registros

@return     oView, objeto, Interface do Agrupador de Registros

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oStructCab  := FWFormStruct(2, "SE1")
	Local oStructSE1  := FWFormStruct(2, "SE1")
	Local oModel      := FWLoadModel("JURA069A")
	Local oView       := Nil

	CreateField(@oStructSE1, 2) // Cria campos de escritório e fatura

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB", oStructCab, "CABMASTER")
	oView:AddGrid("VIEW_SE1", oStructSE1, "SE1DETAIL")

	oView:CreateHorizontalBox("SUPERIOR",50)
	oView:CreateHorizontalBox("INFERIOR",50)

	oView:SetOwnerView("VIEW_CAB", "SUPERIOR") 
	oView:SetOwnerView("VIEW_SE1", "INFERIOR") 

Return (oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CreateField
Cria campos virtuais de escritório e fatura no model e view

@param      oStruct  , objeto  , Estrutura do modelo de dados
@param      nType    , numerico, Tipo 1 = Model e 2 = View

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function CreateField(oStruct, nType)
	Local aLgpd := {}

	Default oStruct := Nil
	Default nType   := 0

	If nType == 1 // Model
		oStruct:AddField(RetTitle("NXA_CESCR"), "", "E1_CESCR" , "C", TamSX3("NXA_CESCR")[1], 0, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
		oStruct:AddField(RetTitle("NXA_COD"  ), "", "E1_CFATUR", "C", TamSX3("NXA_COD"  )[1], 0, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)

	ElseIf nType == 2 // View
		oStruct:AddField("E1_CESCR", "00", RetTitle("NXA_CESCR"), "", {}, "C", PesqPict("NXA", "NXA_CESCR"), Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
		oStruct:AddField("E1_CFATUR","01", RetTitle("NXA_COD"  ), "", {}, "C", PesqPict("NXA", "NXA_COD"  ), Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)

		aAdd(aLgpd, {"E1_CESCR" , "NXA_CESCR"})
		aAdd(aLgpd, {"E1_CFATUR", "NXA_COD"  })
		
		If FindFunction("JPDOfusca")
			JPDOfusca(@oStruct, aLgpd)
		EndIf

	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Monta array com dados do grid SE1

@param      LoadGrid  , objeto, Estrutura do modelo de dados
@return     aDadosGrid, array , Dados do grid com títulos de compensação do RA

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function LoadGrid(oModelGrid)
	Local aDadosGrid  := {}
	Local cAlsGrid    := GetNextAlias()
	Local cQuery      := ""
	Local cCampos     := GetCampos(oModelGrid)

	Local cChvTit   :=  SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO) // cPrefixo + cNumTit + cParcela + cTipo 
	Local aStru 	:= SE1->( DBStruct() )
	Local nT        := 0
	Local nI        := 0

	cQuery := "SELECT " + cCampos + " " 
	cQuery += "FROM " + RetSqlName("SE1") + " SE1 " 
	cQuery += "INNER JOIN " + RetSqlName("SE5") + " SE5" 
	cQuery += "     ON SE5.E5_FILIAL = '" + xFilial("SE5") + "' " 
	cQuery += "         AND SE5.E5_PREFIXO = E1_PREFIXO "
	cQuery += "         AND SE5.E5_NUMERO = E1_NUM "
	cQuery += "         AND SE5.E5_PARCELA = E1_PARCELA "
	cQuery += "         AND SE5.E5_TIPO = E1_TIPO "
	cQuery += "         AND SE5.E5_TIPODOC = 'CP' "
	cQuery += "         AND SE5.E5_DOCUMEN LIKE '" + cChvTit + "%' "
	// Filtro para desconsiderar títulos de RA estornados
	cQuery += "         AND SE5.E5_NUMERO NOT IN (SELECT SE5B.E5_NUMERO  "
	cQuery += "                                   FROM " + RetSqlName("SE5") + " SE5B "
	cQuery += "                                   WHERE SE5B.E5_FILIAL = '" + xFilial("SE5") + "' "
	cQuery += "                                        AND SE5B.E5_DOCUMEN LIKE '" + cChvTit + "%' "
	cQuery += "                                        AND SE5B.E5_TIPODOC = 'ES' "
	cQuery += "                                        AND SE5B.D_E_L_E_T_ = ' ') "
	// Fim do filtro
	cQuery += "         AND SE5.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
	cQuery += "     AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA"

	DbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAlsGrid, .T., .F.)

	nT := len( aStru )
	For nI := 1 to nT
		If ( aStru[nI][2] $ 'DNL' )
			TCSetField( cAlsGrid, aStru[nI, 1], aStru[nI, 2], aStru[nI, 3], aStru[nI,4] )
		Endif
	Next

	aDadosGrid := FwLoadByAlias(oModelGrid, cAlsGrid, "SE1")

	//----------------------------------------------------------------
	// Função para carregar os campos virtuais de escritório e fatura
	//----------------------------------------------------------------
	SetEscFat(@aDadosGrid) 

	(cAlsGrid)->( DbCloseArea() )

Return (aDadosGrid)

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetEscFat
Função para carregar os campos virtuais de escritório e fatura com base
no valor do campo E1_JURFAT

@param      aDadosGrid, array, Valores do Grid

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function SetEscFat(aDadosGrid)
	Local nTamFil     := TamSX3("NXA_FILIAL")[1]
	Local nTamEsc     := TamSX3("NXA_CESCR")[1]
	Local nTamFat     := TamSX3("NXA_COD")[1]
	Local nPosIniEsc  := nTamFil + 2
	Local nPosIniFat  := nTamFil + nTamEsc + 3
	Local nPosJurFat  := FieldPos("E1_JURFAT")
	Local nPosEscr    := FieldPos("E1_CESCR")
	Local nPosFatur   := FieldPos("E1_CFATUR")

	AEval(aDadosGrid, {|x| x[2][nPosEscr] := SubStr(x[2][nPosJurFat], nPosIniEsc, nTamEsc),;
	x[2][nPosFatur] := SubStr(x[2][nPosJurFat], nPosIniFat, nTamFat)})

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetCampos
Função que retorna os campos do modelo

@param      LoadGrid  , objeto, Estrutura do modelo de dados
@return     aDadosGrid, array , Dados do grid com títulos de compensação do RA

@author     Jonatas Martins
@since      19/02/2018
@version    12.1.20
/*/
//------------------------------------------------------------------------------
Static Function GetCampos(oModelGrid)
	Local oStructGrid := oModelGrid:GetStruct()
	Local aFieldsGrid := oStructGrid:GetFields()
	Local cCampos     := ""

	AEval(aFieldsGrid , {|aCpos| cCampos += IIF(aCpos[MODEL_FIELD_VIRTUAL],;
	"'' " + aCpos[MODEL_FIELD_IDFIELD], aCpos[MODEL_FIELD_IDFIELD]) + ", "})

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2)

Return (cCampos)
