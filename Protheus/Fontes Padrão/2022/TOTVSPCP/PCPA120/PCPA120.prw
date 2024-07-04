#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPA120.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} PCPA120
Programa de cadastro de Lista de Componentes
@author Douglas Heydt
@since 25/04/2018
@version 1.0
@return Nil
/*/
Function PCPA120()
	Local aArea   := GetArea()
	Local oBrowse

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	/*If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		HELP(' ',1,"Help" ,,STR0012,2,0,,,,,,) //"Rotina não disponível nesta release."
		Return
	EndIf*/

	oBrowse := BrowseDef()
	oBrowse:Activate()
	RestArea(aArea)

Return NIL

/*/{Protheus.doc} BrowseDef
Função para definição do browse padrão
@author Douglas Heydt
@since 25/04/2018
@version 1.0
@return oBrowse - Objeto do tipo FWMBrowse.
/*/
Static Function BrowseDef()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SMW")
	oBrowse:SetDescription(STR0001) //"Lista de Componentes"
	oBrowse:SetParam({ || Pergunte("PCPA120", .T.) })

Return oBrowse

/*/{Protheus.doc} MenuDef
Definição do Menu do cadastro de lista de componentes
@author Douglas Heydt
@since 25/04/2018
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action "VIEWDEF.PCPA120" OPERATION OP_VISUALIZAR ACCESS 0 //VISUALIZAR
	ADD OPTION aRotina Title STR0003 Action "VIEWDEF.PCPA120" OPERATION OP_INCLUIR    ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0004 Action "VIEWDEF.PCPA120" OPERATION OP_ALTERAR    ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0005 Action "VIEWDEF.PCPA120" OPERATION OP_EXCLUIR    ACCESS 0 //Excluir
	ADD OPTION aRotina Title STR0056 Action "PCPA120COP()" 	  OPERATION OP_COPIA      ACCESS 0 //Copiar
	ADD OPTION aRotina Title STR0059 Action "P120CONSUL()"    OPERATION OP_VISUALIZAR ACCESS 0 //Onde se usa
	
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo do cadastro de lista de componentes
@author Douglas Heydt
@since 25/04/2018
@version 1.0
@return oModel - Modelo de dados definido
/*/
Static Function ModelDef()

	Local oModel
	Local oStruSMW   := FWFormStruct(1,"SMW")
	Local oStruSVG   := FWFormStruct(1,"SVG")
	Local oStruSGG   := FwFormStruct(1,"SGG")
	Local oStruOKSGG := FWFormStruct(1,"SGG" ,{|cCampo| '|'+AllTrim(cCampo)+'|' $ "|GG_COD|"})
	Local oEvent     := PCPA120EVDEF():New()

	oStruSMW:SetProperty("MW_CODIGO" , MODEL_FIELD_NOUPD,.T.)
	oStruSVG:SetProperty("VG_COMP"   , MODEL_FIELD_NOUPD,.T.)
	oStruSVG:SetProperty("VG_TIPVEC" , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "VAZIO() .OR. EXISTCPO('SX5','VC' + FwFldGet('VG_TIPVEC'))" ))
	oStruSVG:SetProperty("VG_VECTOR" , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "VAZIO() .OR. EXISTCPO('SHV', FwFldGet('VG_TIPVEC') + FwFldGet('VG_VECTOR'), 1)" ))

	oModel := MPFormModel():New("PCPA120")

	oStruSVG:AddField("VG_OLDTRT"		,;	// [01]  C   Titulo do campo
	" "									,;	// [02]  C   ToolTip do campo
	"VG_OLDTRT"							,;	// [03]  C   Id do Field
	"C"									,;	// [04]  C   Tipo do campo
	GetSx3Cache("VG_TRT","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	0, NIL, NIL, NIL, .F., ;
	FWBuildFeature(STRUCT_FEATURE_INIPAD,"P120IniTrt()"),;
	NIL, NIL, .T.)

	oStruSVG:AddTrigger("VG_COMP", "VG_TRT",,{|| ProximoTRT(oModel)})

	//Altera os Structs da tela de divergências.
	oEvent:AltStructDivergencia(1, Nil, @oStruSGG, @oStruOKSGG)

	oModel:AddFields( "SMWMASTER", /*cOwner*/, oStruSMW)
	oModel:AddGrid( "SVGDETAIL", "SMWMASTER", oStruSVG, ,)

	//Adiciona os modelos para visualizar as divergências.
	oModel:AddGrid("SVG_NOK", "SMWMASTER", oStruSVG)
	oModel:AddGrid("SG_NOK" , "SMWMASTER", oStruSGG)
	oModel:AddGrid("SG_OK"  , "SMWMASTER", oStruOKSGG)

	oModel:SetPrimaryKey({})
	oModel:SetRelation("SVGDETAIL",{{"VG_FILIAL","xFilial('SVG')"},{"VG_COD" ,"MW_CODIGO"}},SVG->(IndexKey(2)))

	oModel:GetModel("SVGDETAIL"):SetUniqueLine({"VG_TRT","VG_COMP"})
	oModel:GetModel("SVGDETAIL"):SetOptional(.F.)
	oModel:GetModel("SMWMASTER"):SetDescription(STR0001)
	oModel:GetModel("SVGDETAIL"):SetDescription(STR0006)

	oModel:GetModel("SVG_NOK"  ):SetDescription(STR0013) //"Componentes da lista com divergência"
	oModel:GetModel("SVG_NOK"  ):SetOnlyQuery()
	oModel:GetModel("SVG_NOK"  ):SetOptional(.T.)

	oModel:GetModel("SG_NOK"  ):SetDescription(STR0014) //"Estruturas relacionadas com a divergência"
	oModel:GetModel("SG_NOK"  ):SetOnlyQuery()
	oModel:GetModel("SG_NOK"  ):SetOptional(.T.)

	oModel:GetModel("SG_OK"   ):SetDescription(STR0015) //"Estruturas sem divergências"
	oModel:GetModel("SG_OK"   ):SetOnlyQuery()
	oModel:GetModel("SG_OK"   ):SetOptional(.T.)

	oModel:InstallEvent("PCPA120EVDEF", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da view do cadastro de lista de componentes
@author Douglas Heydt
@since 25/04/2018
@version 1.0
@return oView - View definida
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel( "PCPA120" )
	Local oStruSMW := FWFormStruct( 2, "SMW")
	Local oStruSVG := FWFormStruct( 2, "SVG", {|cCampo| ! "|"+AllTrim(cCampo)+"|" $ "|VG_LOCCONS|"})
	Local oView

	oView :=FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_SMW", oStruSMW, "SMWMASTER")
	oView:AddGrid("VIEW_SVG", oStruSVG, "SVGDETAIL")

	oView:CreateHorizontalBox( "SUPERIOR",  76, , .T.)
	oView:CreateHorizontalBox( "INFERIOR", 100 )

	oView:SetOwnerView( "VIEW_SMW", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_SVG", "INFERIOR" )

	oStruSVG:RemoveField("VG_COD")

	oView:AddUserButton(STR0039, "", {|oView| ImpEstrutu(oView)}, , , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}) //"Importar Estrutura"

Return oView

/*/{Protheus.doc} A120VldDt
Função de validação dos campos Data
@author Douglas Heydt
@since 25/04/2018
@version 1.0
@return lRet - indica se a data informada é válida
/*/
Function A120VldDt()

	Local oModel   := FWModelActive()
	Local oGridSVG := oModel:GetModel("SVGDETAIL")
	Local dDtIni   := oGridSVG:GetValue("VG_INI")
	Local dDtFim   := oGridSVG:GetValue("VG_FIM")
	Local lRet     :=.T.

	If !Empty(dDtIni) .And. !Empty(dDtFim)
		If Year(dDtFim) > Year(dDtIni)
			lRet:= .T.
		ElseIf Year(dDtFim) == Year(dDtIni)
			If Month(dDtFim) > Month(dDtIni)
				lRet:= .T.
			ElseIf Month(dDtFim) == Month(dDtIni)
					If Day(dDtFim) >= Day(dDtIni)
						lRet:= .T.
					Else
						lRet:= .F.
					EndIf
			Else
				lRet:= .F.
			EndIf
		Else
			Help(" ",1,"A120VLDT")
			lRet:= .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} A120VldCod
Valida se o codigo da lista já está em uso
@author Douglas Heydt
@since 24/04/2018
@version 1.0
@return lRet - indica se o código informado é válido
/*/
Function A120VldCod()

	Local oModel     := FWModelActive()
	Local oModelSMW := oModel:GetModel("SMWMASTER")
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local cFilSMW	:= xFilial("SMW")
	Local cCodSMW  := oModelSMW:GetValue("MW_CODIGO")

	If !Empty(cCodSMW)
		dbSelectArea("SMW")
		dbSetOrder(1)
		If MsSeek( cFilSMW+cCodSMW)
				Help(" ",1,"A120VLCOD")
				lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} A120VldIt
Valida se o grupo de opcionais e o item selecionado existem
@author Douglas Heydt
@since 26/04/2018
@version 1.0
@return lRet - indica se o grupo e item informados são válidos
/*/
Function A120VldIt()

	Local oModel     := FWModelActive()
	Local oGridSVG	:= oModel:GetModel("SVGDETAIL")
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local cFilSGA	:= xFilial("SGA")
	Local cGROPCVG  := oGridSVG:GetValue("VG_GROPC")
	Local cOPCVG  := oGridSVG:GetValue("VG_OPC")
	Local cFilter := cFilSGA

	dbSelectArea("SGA")
	dbSetOrder(1)

	If !Empty(cGROPCVG)
		cFilter += cGROPCVG
		If !Empty(cOPCVG)
			cFilter += cOPCVG
		EndIf
		If MsSeek(cFilter)
		lRet := .T.
		Else
			Help(" ",1,"A120VLDIT")
			lRet := .F.
		EndIf
	Else
		If Empty(cGROPCVG) .And. !Empty(cOPCVG)
			Help(" ",1,"A120VLDIT")
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} A123Quant
Validação do campos Quantidade
@author Douglas Heydt
@since 26/04/2018
@version 1.0
@return lRet - indica se a quantidade informada é válida
/*/
Function A123Quant(nQuant)

	Local oModel     := FWModelActive()
	Local oGridSVG	:= oModel:GetModel("SVGDETAIL")
	Local nVar       := 0
	Local lRet       := .T.

	nVar := If(nQuant==Nil,&(ReadVar()),nQuant)

	If IsProdMod(oGridSVG:getValue("VG_COMP")) .And. GetMV('MV_TPHR') == 'N'
		nVar := nVar - Int(nVar)
		If nVar > .5999999999
			HELP(' ',1,'NAOMINUTO')
			lRet := .F.
		EndIf
	ElseIf QtdComp(nVar) < QtdComp(0) .And. !GetMV('MV_NEGESTR')
		Help(' ',1,'A200NAONEG')
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} A123Quant
Validação do campo Potência
@author Douglas Heydt
@since 26/04/2018
@version 1.0
@return lRet - indica se a potência informada é válida
/*/
Function A123VldPot()

	Local oModel     := FWModelActive()
	Local oGridSVG	:= oModel:GetModel("SVGDETAIL")
	Local lRet       := .T.
	Local lctrlPot := POSICIONE("SB1", 1, xFilial("SB1") +oGridSVG:getValue("VG_COMP"), "B1_CPOTENC") //1-s 2-n
	Local lctrlLot := POSICIONE("SB1", 1, xFilial("SB1") +oGridSVG:getValue("VG_COMP"), "B1_RASTRO") //S L N

	If oGridSVG:GetValue("VG_POTENCI") <> 0
		If lctrlPot == "1"
			If	lctrlLot == "N"
					Help(' ',1,'A123POT')
					lRet := .F.
			EndIf
		Else
			Help(' ',1,'A123POT')
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} P120IniTrt()
Inicializador padrão do campo VG_OLDTRT
@type  Function
@author lucas.franca
@since 12/02/2019
@version P12
@param param, param_type, param_descr
@return cTrt, Character, Sequência atual do registro
/*/
Function P120IniTrt()
	Local cTrt := SVG->VG_TRT
Return cTrt

/*/{Protheus.doc} ProximoTRT()
Busca o maior TRT informado em tela e retorna o vaor para o próximo TRT
@type Static Function
@author marcelo.neumann
@since 21/03/2019
@version P12
@param oModel, object, modelo principal
@return cProxTrt, character, valor para o próximo TRT
/*/
Static Function ProximoTRT(oModel)

	Local oMdlGrid := oModel:GetModel("SVGDETAIL")
	Local nInd     := 0
	Local nTamTrt  := GetSx3Cache("VG_TRT","X3_TAMANHO")
	Local cComp    := oMdlGrid:GetValue("VG_COMP")
	Local cProxTrt := Space(nTamTrt)
	Local lExiste  := .F.

	//Percorre a grid buscando pelo componente e guardando a maior sequência informada em tela
	For nInd := 1 To oMdlGrid:Length()
		If nInd == oMdlGrid:GetLine() .Or. oMdlGrid:IsDeleted(nInd) .Or. oMdlGrid:GetValue("VG_COMP", nInd) != cComp
			Loop
		EndIf

		If !Empty(oMdlGrid:GetValue("VG_TRT",nInd)) .And. oMdlGrid:GetValue("VG_TRT",nInd) > cProxTrt
			cProxTrt := oMdlGrid:GetValue("VG_TRT",nInd)
		EndIf

		lExiste := .T.
	Next nInd

	If lExiste
		If Empty(cProxTrt)
			cProxTrt := StrZero(1, nTamTrt)
		Else
			If cProxTrt == PadR("Z", nTamTrt, "Z")
				cProxTrt := Space(nTamTrt)
			Else
				cProxTrt := Soma1(cProxTrt)
			EndIf
		EndIf
	EndIf

Return cProxTrt

/*/{Protheus.doc} ImpEstrutu()
Função para importar os componentes de uma estrutura para a lista
@type Static Function
@author marcelo.neumann
@since 21/03/2019
@version P12
@param oView, object, view principal
@return Nil
/*/
Static Function ImpEstrutu(oView)

	If PermiteImp(oView:GetModel())
		PCPA120Imp(oView)
	EndIf

Return

/*/{Protheus.doc} PermiteImp()
Valida se pode acessar a tela de importação de estrutura
@type Static Function
@author marcelo.neumann
@since 21/03/2019
@version P12
@param oModel, object, modelo da view principal
@return lRet, logical, indica se pode ser aberta a tela de importação
/*/
Static Function PermiteImp(oModel)

	Local aError := {}
	Local lRet   := .T.

	If Empty(oModel:GetModel("SMWMASTER"):GetValue("MW_CODIGO"))
		lRet := .F.
		Help( ,  , "Help", ,  STR0043, ; //"Código da lista não informado."
		     1, 0, , , , , , {STR0044})  //"Informe o código da lista para importar uma estrutura."
	Else
		If !oModel:GetModel("SVGDETAIL"):IsEmpty() .And. !oModel:GetModel("SVGDETAIL"):VldLineData()
			lRet   := .F.
			aError := oModel:GetErrorMessage(.T.)
			Help( , , aError[MODEL_MSGERR_ID] + " (" + aError[MODEL_MSGERR_IDFORMERR] + ")";
			      , , aError[MODEL_MSGERR_MESSAGE], 1, 0, , , , , , { aError[MODEL_MSGERR_SOLUCTION] })
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PCPA120COP
Função responsavel pela opção de cópia do menu.
@type  Function
@author Lucas Fagundes
@since 15/12/2021
@version P12
return Nil
/*/
Function PCPA120COP()

	Local aErro      := {}
	Local aStructSVG := {}
	Local cCod       := SMW->MW_CODIGO
	Local cDesc      := SMW->MW_DESCRI
	Local cFiltro    := ""
	Local lTelaOk    := .T.
	Local nCont      := 1
	Local nI         := 1
	Local nRet       := 0
	Local oModel     := FwLoadModel("PCPA120")
	Local oModelMW   := oModel:GetModel("SMWMASTER")
	Local oModelSVG  := oModel:GetModel("SVGDETAIL")

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModelMW:SetValue("MW_DESCRI", cDesc)

	// Consulta na tabela dos componentes
	cFiltro := "VG_FILIAL == '" + xFilial("SVG") + "' .and. VG_COD == '" + cCod + "' "
	DbSelectArea("SVG")
	aStructSVG := SVG->(DbStruct())
	SVG->(DbSetOrder(2))						// VG_FILIAL+VG_COMP+VG_TRT
	SVG->(DbSetFilter({|| &cFiltro}, cFiltro))
	SVG->(DbGoTop())

	While !SVG->(EOF()) .and. lTelaOk
		// Adiciona uma nova linha (Caso for a primeira, não adiciona)
		if nCont > 1
			oModelSVG:AddLine()
		EndIf

		// Adiciona os valores no grid
		For nI := 1 to Len(aStructSVG)
			If !oModelSVG:SetValue(aStructSVG[nI][1], SVG->&(aStructSVG[nI][1]))
				aErro := oModel:GetErrorMessage(.T.)
				Help( , , aErro[5], , aErro[6] + chr(10) + STR0057 + CValToChar(nCont) + STR0058 + "'" + SVG->&(aStructSVG[nI][1]) + "' ",;
					 1, 0, , , , , , { aErro[7] })
				lTelaOk := .F.
				Exit
			EndIf
		Next

		// Valida a linha
		If lTelaOk .and. !oModelSVG:VldLineData()
				aErro := oModel:GetErrorMessage(.T.)
				Help( , , aErro[5] , , aErro[6] + chr(10) + STR0057 + CValToChar(nCont),;
					 1, 0, , , , , , { aErro[7] })
				lTelaOk := .F.
		EndIf

		nCont++
		SVG->(DbSkip())
	End

	SVG->(DbClearFilter())
	oModelSVG:GoLine(1)
	aSize(aStructSVG, 0)

	// Executa a tela, caso esteja tudo certo
	If lTelaOk
		nRet := FWExecView(STR0003, "PCPA120", OP_INCLUIR, /*oDlg*/, {|| .T. }, /*bOk*/ ,;
		 /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel)
	EndIf

Return Nil

/*/{Protheus.doc} P120CONSUL
Função utilizada para consultar os produtos que estão utilizando a lista de componentes.
@type  Function
@author Lucas Fagundes
@since 07/02/2022
@version P12  
@return Nil 
/*/
Function P120CONSUL()

	// Verifica se a lista está em uso para exibir a tela
	If PCPA120Lis(SMW->MW_CODIGO, .F.)
		FWExecView(STR0065, "PCPA120Con", MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. }, /*bOk*/,; // "Lista de Componentes - Onde a Lista de Componentes é Usada"
		65, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/)
	Else
		Help( ,  , "Help", ,  STR0063, 1, 0) // "Não existem estruturas/pré-estruturas vinculadas a esta lista de componentes." 
	EndIf

Return Nil
